--------------------------------------------------------
--  DDL for Package Body OE_LINE_ADJ_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LINE_ADJ_UTIL" AS
/* $Header: OEXULADB.pls 120.9.12010000.8 2010/04/14 14:46:12 aambasth ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Line_Adj_Util';


Type pbh_tbl_type             Is Table Of Number Index by Binary_Integer;

Procedure Process_Cancelled_Lines(p_x_new_line_rec In Oe_Order_Pub.line_rec_type, p_ordered_quantity In Number);
  --bug7491829 added p_ordered_quantity

Procedure Log_Pricing_Requests (p_x_new_line_rec in out nocopy Oe_Order_Pub.Line_Rec_Type,
                                p_old_line_rec   in Oe_Order_Pub.Line_Rec_Type,
                                p_no_price_flag  Boolean Default False,
                                p_price_flag     Varchar2 Default 'Y');

FUNCTION G_MISS_OE_AK_LINE_ADJ_REC
RETURN OE_AK_LINE_PRCADJS_V%ROWTYPE IS
l_rowtype_rec				OE_AK_LINE_PRCADJS_V%ROWTYPE;
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
    l_rowtype_rec.LINE_INDEX	:= FND_API.G_MISS_NUM;
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
    --uom begin
    l_rowtype_rec.operand_per_pqty := FND_API.G_MISS_NUM;
    l_rowtype_rec.adjusted_amount_per_pqty := FND_API.G_MISS_NUM;
    --uom end

    l_rowtype_rec.arithmetic_operator	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.cost_id	:= FND_API.G_MISS_NUM;
    l_rowtype_rec.tax_code	:= FND_API.G_MISS_CHAR;
    l_rowtype_rec.tax_exempt_flag := FND_API.G_MISS_CHAR;
    l_rowtype_rec.tax_exempt_number := FND_API.G_MISS_CHAR;
    l_rowtype_rec.tax_exempt_reason_code := FND_API.G_MISS_CHAR;
    l_rowtype_rec.parent_adjustment_id := FND_API.G_MISS_NUM;
    l_rowtype_rec.invoiced_flag := FND_API.G_MISS_CHAR;
    l_rowtype_rec.estimated_flag := FND_API.G_MISS_CHAR;
    l_rowtype_rec.inc_in_sales_performance := FND_API.G_MISS_CHAR;
    l_rowtype_rec.split_action_code := FND_API.G_MISS_CHAR;
    l_rowtype_rec.adjusted_amount := FND_API.G_MISS_NUM;
    l_rowtype_rec.pricing_phase_id := FND_API.G_MISS_NUM;
    l_rowtype_rec.charge_type_code := FND_API.G_MISS_CHAR;
    l_rowtype_rec.charge_subtype_code := FND_API.G_MISS_CHAR;
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
    l_rowtype_rec.AC_ATTRIBUTE1    := FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE10   := FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE11   := FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE12   := FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE13   := FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE14   := FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE15   := FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE2    := FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE3    := FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE4    := FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE5    := FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE6    := FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE7    := FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE8    := FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_ATTRIBUTE9    := FND_API.G_MISS_CHAR;
    l_rowtype_rec.AC_CONTEXT       := FND_API.G_MISS_CHAR;

    RETURN l_rowtype_rec;

END G_MISS_OE_AK_LINE_ADJ_REC;

Procedure Append_Association (p_line_adj_tbl        in     Oe_Order_Pub.line_adj_tbl_type,
                              px_line_adj_assoc_tbl in out nocopy Oe_Order_Pub.line_adj_assoc_tbl_type,
                              p_pbh_tbl in pbh_tbl_type
                              ) As

CURSOR l_price_Adj_assoc_csr(p_price_adjustment_id In Number) IS
		SELECT
		         a.PRICE_ADJUSTMENT_ID
			,a.CREATION_DATE
			,a.CREATED_BY
			,a.LAST_UPDATE_DATE
			,a.LAST_UPDATED_BY
			,a.LAST_UPDATE_LOGIN
			,a.PROGRAM_APPLICATION_ID
			,a.PROGRAM_ID
			,a.PROGRAM_UPDATE_DATE
			,a.REQUEST_ID
			,a.PRICE_ADJ_ASSOC_ID
			,a.LINE_ID
			,a.RLTD_PRICE_ADJ_ID
			,a.LOCK_CONTROL
		from oe_price_adj_Assocs a, oe_price_adjustments b
                where a.price_adjustment_id = p_price_adjustment_id
                     and a.rltd_price_adj_id = b.price_adjustment_id
                     and b.list_line_type_code in ('SUR','DIS');
I PLS_INTEGER;
J PLS_INTEGER;
K PLS_INTEGER;
cnt PLS_INTEGER:=0;
l_found1 Boolean := False;
l_found2 Boolean := False;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTERING OE_LINE_ADJ_UTIL.APPEND_ASSOCIATIONS' , 1 ) ;
	END IF;
  I:=p_pbh_tbl.first;
  while I is not null loop
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'PBH'||P_PBH_TBL ( I ) , 1 ) ;
  END IF;
  I:=p_pbh_tbl.next(I);
  end loop;

  I:=p_line_adj_tbl.first;
  while I is not null loop
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'LINE ADJ'||P_LINE_ADJ_TBL ( I ) .PRICE_ADJUSTMENT_ID||' '||P_LINE_ADJ_TBL ( I ) .LIST_LINE_TYPE_CODE , 1 ) ;
  END IF;
  I:=p_line_adj_tbl.next(I);
  end loop;

 I:=p_pbh_tbl.first;
  While I Is Not Null Loop
       For l_asso In l_price_Adj_assoc_csr(p_line_adj_tbl(p_pbh_tbl(I)).price_adjustment_id) Loop
           l_found1 := False;
           l_found2 := False;
           cnt := cnt +1;
           J := p_line_adj_tbl.first;
           While J Is Not Null Loop
             If p_line_adj_tbl(J).price_adjustment_id = l_asso.rltd_price_adj_id AND p_line_adj_tbl(J).operation = OE_GLOBALS.G_OPR_CREATE Then
               px_line_adj_assoc_tbl(cnt).rltd_adj_index := J;
               l_found1 := True;
             ElsIf p_line_adj_tbl(j).price_adjustment_id = l_asso.price_adjustment_id Then
               px_line_adj_assoc_tbl(cnt).adj_index := J;
               px_line_adj_assoc_tbl(cnt).price_adjustment_id := fnd_api.g_miss_num;
               px_line_adj_assoc_tbl(cnt).price_adj_assoc_id := fnd_api.g_miss_num;
               l_found2 := True;
             End If;
               px_line_adj_assoc_tbl(cnt).operation:=OE_GLOBALS.G_OPR_CREATE;
              Exit When l_found1 and l_found2;
              J:= p_line_adj_tbl.next(J);
           End Loop;
       End Loop;
 I:=p_pbh_tbl.next(I);
 End Loop;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXITING OE_LINE_ADJ_UTIL.APPEND_ASSOCIATIONS' , 1 ) ;
	END IF;
End;

PROCEDURE API_Rec_To_Rowtype_Rec
(   p_LINE_ADJ_rec            IN  OE_Order_PUB.LINE_ADJ_Rec_Type
,   x_rowtype_rec             OUT nocopy OE_AK_LINE_PRCADJS_V%ROWTYPE
) IS
BEGIN

    x_rowtype_rec.ATTRIBUTE1       := p_line_adj_rec.ATTRIBUTE1;
    x_rowtype_rec.ATTRIBUTE10       := p_line_adj_rec.ATTRIBUTE10;
    x_rowtype_rec.ATTRIBUTE11       := p_line_adj_rec.ATTRIBUTE11;
    x_rowtype_rec.ATTRIBUTE12       := p_line_adj_rec.ATTRIBUTE12;
    x_rowtype_rec.ATTRIBUTE13       := p_line_adj_rec.ATTRIBUTE13;
    x_rowtype_rec.ATTRIBUTE14       := p_line_adj_rec.ATTRIBUTE14;
    x_rowtype_rec.ATTRIBUTE15       := p_line_adj_rec.ATTRIBUTE15;
    x_rowtype_rec.ATTRIBUTE2       := p_line_adj_rec.ATTRIBUTE2;
    x_rowtype_rec.ATTRIBUTE3       := p_line_adj_rec.ATTRIBUTE3;
    x_rowtype_rec.ATTRIBUTE4       := p_line_adj_rec.ATTRIBUTE4;
    x_rowtype_rec.ATTRIBUTE5       := p_line_adj_rec.ATTRIBUTE5;
    x_rowtype_rec.ATTRIBUTE6       := p_line_adj_rec.ATTRIBUTE6;
    x_rowtype_rec.ATTRIBUTE7       := p_line_adj_rec.ATTRIBUTE7;
    x_rowtype_rec.ATTRIBUTE8       := p_line_adj_rec.ATTRIBUTE8;
    x_rowtype_rec.ATTRIBUTE9       := p_line_adj_rec.ATTRIBUTE9;
    x_rowtype_rec.CONTEXT       := p_line_adj_rec.CONTEXT;
    x_rowtype_rec.CREATED_BY       := p_line_adj_rec.CREATED_BY;
    x_rowtype_rec.CREATION_DATE       := p_line_adj_rec.CREATION_DATE;
    x_rowtype_rec.DB_FLAG       := p_line_adj_rec.DB_FLAG;
    x_rowtype_rec.HEADER_ID       := p_line_adj_rec.HEADER_ID;
    x_rowtype_rec.LAST_UPDATED_BY       := p_line_adj_rec.LAST_UPDATED_BY;
    x_rowtype_rec.LAST_UPDATE_DATE       := p_line_adj_rec.LAST_UPDATE_DATE;
    x_rowtype_rec.LAST_UPDATE_LOGIN       := p_line_adj_rec.LAST_UPDATE_LOGIN;
    x_rowtype_rec.LINE_ID       := p_line_adj_rec.LINE_ID;
    x_rowtype_rec.OPERATION       := p_line_adj_rec.OPERATION;
    x_rowtype_rec.LINE_INDEX       := p_line_adj_rec.LINE_INDEX;
    x_rowtype_rec.PERCENT       := p_line_adj_rec.PERCENT;
    x_rowtype_rec.RETURN_STATUS       := p_line_adj_rec.RETURN_STATUS;
    x_rowtype_rec.AUTOMATIC_FLAG	:= p_line_adj_rec.AUTOMATIC_FLAG;
    x_rowtype_rec.DISCOUNT_ID	:= p_line_adj_rec.DISCOUNT_ID;
    x_rowtype_rec.DISCOUNT_LINE_ID	:= p_line_adj_rec.DISCOUNT_LINE_ID;
    x_rowtype_rec.PRICE_ADJUSTMENT_ID	:= p_line_adj_rec.PRICE_ADJUSTMENT_ID;
    x_rowtype_rec.PROGRAM_APPLICATION_ID	:= p_line_adj_rec.PROGRAM_APPLICATION_ID;
    x_rowtype_rec.PROGRAM_ID		:= p_line_adj_rec.PROGRAM_ID;
    x_rowtype_rec.PROGRAM_UPDATE_DATE	:= p_line_adj_rec.PROGRAM_UPDATE_DATE;
    x_rowtype_rec.request_id		:= p_line_adj_rec.request_id;
--    x_rowtype_rec.orig_sys_discount_ref	:= p_line_adj_rec.orig_sys_discount_ref;
    x_rowtype_rec.list_header_id	:= p_line_adj_rec.list_header_id;
    x_rowtype_rec.list_line_id	:= p_line_adj_rec.list_line_id;
    x_rowtype_rec.list_line_type_code	:= p_line_adj_rec.list_line_type_code;
    x_rowtype_rec.modifier_mechanism_type_code	:= p_line_adj_rec.modifier_mechanism_type_code;
    x_rowtype_rec.modified_from	:= p_line_adj_rec.modified_from;
    x_rowtype_rec.modified_to	:= p_line_adj_rec.modified_to;
    x_rowtype_rec.updated_flag	:= p_line_adj_rec.updated_flag;
    x_rowtype_rec.update_allowed	:= p_line_adj_rec.update_allowed;
    x_rowtype_rec.applied_flag	:= p_line_adj_rec.applied_flag;
    x_rowtype_rec.change_reason_code	:= p_line_adj_rec.change_reason_code;
    x_rowtype_rec.change_reason_text	:= p_line_adj_rec.change_reason_text;
    x_rowtype_rec.operand	:= p_line_adj_rec.operand;
    x_rowtype_rec.arithmetic_operator	:= p_line_adj_rec.arithmetic_operator;
    x_rowtype_rec.cost_id	:= p_line_adj_rec.cost_id;
    x_rowtype_rec.tax_code	:= p_line_adj_rec.tax_code;
    x_rowtype_rec.tax_exempt_flag := p_line_adj_rec.tax_exempt_flag;
    x_rowtype_rec.tax_exempt_number := p_line_adj_rec.tax_exempt_number;
    x_rowtype_rec.tax_exempt_reason_code := p_line_adj_rec.tax_exempt_reason_code;
    x_rowtype_rec.parent_adjustment_id := p_line_adj_rec.parent_adjustment_id;
    x_rowtype_rec.invoiced_flag := p_line_adj_rec.invoiced_flag;
    x_rowtype_rec.estimated_flag := p_line_adj_rec.estimated_flag;
    x_rowtype_rec.inc_in_sales_performance := p_line_adj_rec.inc_in_sales_performance;
    x_rowtype_rec.split_action_code := p_line_adj_rec.split_action_code;

    x_rowtype_rec.adjusted_amount := p_line_adj_rec.adjusted_amount;
    x_rowtype_rec.pricing_phase_id := p_line_adj_rec.pricing_phase_id;
    x_rowtype_rec.charge_type_code := p_line_adj_rec.charge_type_code;
    x_rowtype_rec.charge_subtype_code := p_line_adj_rec.charge_subtype_code;
    x_rowtype_rec.list_line_no := p_line_adj_rec.list_line_no;
    x_rowtype_rec.source_system_code := p_line_adj_rec.source_system_code;
    x_rowtype_rec.benefit_qty := p_line_adj_rec.benefit_qty;
    x_rowtype_rec.benefit_uom_code := p_line_adj_rec.benefit_uom_code;
    x_rowtype_rec.print_on_invoice_flag := p_line_adj_rec.print_on_invoice_flag;
    x_rowtype_rec.expiration_date := p_line_adj_rec.expiration_date;
    x_rowtype_rec.rebate_transaction_type_code := p_line_adj_rec.rebate_transaction_type_code;
    x_rowtype_rec.rebate_transaction_reference := p_line_adj_rec.rebate_transaction_reference;
    x_rowtype_rec.rebate_payment_system_code := p_line_adj_rec.rebate_payment_system_code;
    x_rowtype_rec.redeemed_date := p_line_adj_rec.redeemed_date;
    x_rowtype_rec.redeemed_flag := p_line_adj_rec.redeemed_flag;
    x_rowtype_rec.accrual_flag := p_line_adj_rec.accrual_flag;
    x_rowtype_rec.range_break_quantity := p_line_adj_rec.range_break_quantity;
    x_rowtype_rec.accrual_conversion_rate := p_line_adj_rec.accrual_conversion_rate;
    x_rowtype_rec.pricing_group_sequence := p_line_adj_rec.pricing_group_sequence;
    x_rowtype_rec.modifier_level_code := p_line_adj_rec.modifier_level_code;
    x_rowtype_rec.price_break_type_code := p_line_adj_rec.price_break_type_code;
    x_rowtype_rec.substitution_attribute := p_line_adj_rec.substitution_attribute;
    x_rowtype_rec.proration_type_code := p_line_adj_rec.proration_type_code;
    x_rowtype_rec.credit_or_charge_flag := p_line_adj_rec.credit_or_charge_flag;
    x_rowtype_rec.include_on_returns_flag := p_line_adj_rec.include_on_returns_flag;
    x_rowtype_rec.AC_ATTRIBUTE1       := p_line_adj_rec.AC_ATTRIBUTE1;
    x_rowtype_rec.AC_ATTRIBUTE10      := p_line_adj_rec.AC_ATTRIBUTE10;
    x_rowtype_rec.AC_ATTRIBUTE11      := p_line_adj_rec.AC_ATTRIBUTE11;
    x_rowtype_rec.AC_ATTRIBUTE12      := p_line_adj_rec.AC_ATTRIBUTE12;
    x_rowtype_rec.AC_ATTRIBUTE13      := p_line_adj_rec.AC_ATTRIBUTE13;
    x_rowtype_rec.AC_ATTRIBUTE14      := p_line_adj_rec.AC_ATTRIBUTE14;
    x_rowtype_rec.AC_ATTRIBUTE15      := p_line_adj_rec.AC_ATTRIBUTE15;
    x_rowtype_rec.AC_ATTRIBUTE2       := p_line_adj_rec.AC_ATTRIBUTE2;
    x_rowtype_rec.AC_ATTRIBUTE3       := p_line_adj_rec.AC_ATTRIBUTE3;
    x_rowtype_rec.AC_ATTRIBUTE4       := p_line_adj_rec.AC_ATTRIBUTE4;
    x_rowtype_rec.AC_ATTRIBUTE5       := p_line_adj_rec.AC_ATTRIBUTE5;
    x_rowtype_rec.AC_ATTRIBUTE6       := p_line_adj_rec.AC_ATTRIBUTE6;
    x_rowtype_rec.AC_ATTRIBUTE7       := p_line_adj_rec.AC_ATTRIBUTE7;
    x_rowtype_rec.AC_ATTRIBUTE8       := p_line_adj_rec.AC_ATTRIBUTE8;
    x_rowtype_rec.AC_ATTRIBUTE9       := p_line_adj_rec.AC_ATTRIBUTE9;
    x_rowtype_rec.AC_CONTEXT          := p_line_adj_rec.AC_CONTEXT;
    --uom begin
    x_rowtype_rec.operand_per_pqty :=p_line_adj_rec.operand_per_pqty;
    x_rowtype_rec.adjusted_amount_per_pqty :=p_line_adj_rec.adjusted_amount_per_pqty;
    x_rowtype_rec.invoiced_amount     := p_line_adj_rec.invoiced_amount;
    --uom end


END API_Rec_To_RowType_Rec;


PROCEDURE Rowtype_Rec_To_API_Rec
(   p_record                        IN  OE_AK_LINE_PRCADJS_V%ROWTYPE
,   x_api_rec                       IN OUT nocopy OE_Order_PUB.LINE_ADJ_Rec_Type
)
iS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'BEFORE ASSIGN COST_ID '||TO_CHAR ( P_RECORD.COST_ID ) , 1 ) ;
END IF;

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
    x_api_rec.LINE_INDEX       := p_record.LINE_INDEX;
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
--    x_api_rec.orig_sys_discount_ref	:= p_record.orig_sys_discount_ref;
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
    x_api_rec.pricing_phase_id := p_record.pricing_phase_id;
    x_api_rec.adjusted_amount := p_record.adjusted_amount;
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
    --uom begin
    x_api_rec.operand_per_pqty         :=p_record.operand_per_pqty;
    x_api_rec.adjusted_amount_per_pqty :=p_record.adjusted_amount_per_pqty;
    --uom end
    x_api_rec.invoiced_amount     := p_record.invoiced_amount;
END Rowtype_Rec_To_API_Rec;


--  Procedure Clear_Dependent_Attr

-- Overloaded procedure .. Please maintain 2 code sets

PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_Line_Adj_rec                IN OUT NOCOPY OE_AK_LINE_PRCADJS_V%ROWTYPE
,   p_old_Line_Adj_rec            IN  OE_AK_LINE_PRCADJS_V%ROWTYPE :=
								G_MISS_OE_AK_LINE_ADJ_REC
-- ,   x_Line_Adj_rec                OUT nocopy OE_AK_LINE_PRCADJS_V%ROWTYPE
)
IS
l_index			NUMBER :=0;
l_src_attr_tbl		OE_GLOBALS.NUMBER_Tbl_Type;
l_dep_attr_tbl		OE_GLOBALS.NUMBER_Tbl_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    --  Load out record

   -- x_Line_Adj_rec := p_Line_Adj_rec;

    --  If attr_id is missing compare old and new records and for
    --  every changed attribute clear its dependent fields.
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING CLEAR_DEPENDENT_ATTR' ) ;
    END IF;
    IF p_attr_id = FND_API.G_MISS_NUM THEN


        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.adjusted_amount,p_old_Line_Adj_rec.adjusted_amount)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_ADJUSTED_AMOUNT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.pricing_phase_id,p_old_Line_Adj_rec.pricing_phase_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_PRICING_PHASE_ID;
        END IF;

-----

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.price_adjustment_id,p_old_Line_Adj_rec.price_adjustment_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_PRICE_ADJUSTMENT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.creation_date,p_old_Line_Adj_rec.creation_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_CREATION_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.created_by,p_old_Line_Adj_rec.created_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_CREATED_BY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.last_update_date,p_old_Line_Adj_rec.last_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_LAST_UPDATE_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.last_updated_by,p_old_Line_Adj_rec.last_updated_by)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_LAST_UPDATED_BY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.last_update_login,p_old_Line_Adj_rec.last_update_login)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_LAST_UPDATE_LOGIN;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.program_application_id,p_old_Line_Adj_rec.program_application_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_PROGRAM_APPLICATION;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.program_id,p_old_Line_Adj_rec.program_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_PROGRAM;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.program_update_date,p_old_Line_Adj_rec.program_update_date)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_PROGRAM_UPDATE_DATE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.request_id,p_old_Line_Adj_rec.request_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_REQUEST;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.header_id,p_old_Line_Adj_rec.header_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_HEADER;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.discount_id,p_old_Line_Adj_rec.discount_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_DISCOUNT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.discount_line_id,p_old_Line_Adj_rec.discount_line_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_DISCOUNT_LINE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.automatic_flag,p_old_Line_Adj_rec.automatic_flag)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_AUTOMATIC;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.percent,p_old_Line_Adj_rec.percent)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_PERCENT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.line_id,p_old_Line_Adj_rec.line_id)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_LINE;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.context,p_old_Line_Adj_rec.context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_CONTEXT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute1,p_old_Line_Adj_rec.attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_ATTRIBUTE1;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute2,p_old_Line_Adj_rec.attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_ATTRIBUTE2;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute3,p_old_Line_Adj_rec.attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_ATTRIBUTE3;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute4,p_old_Line_Adj_rec.attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_ATTRIBUTE4;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute5,p_old_Line_Adj_rec.attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_ATTRIBUTE5;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute6,p_old_Line_Adj_rec.attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_ATTRIBUTE6;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute7,p_old_Line_Adj_rec.attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_ATTRIBUTE7;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute8,p_old_Line_Adj_rec.attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_ATTRIBUTE8;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute9,p_old_Line_Adj_rec.attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_ATTRIBUTE9;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute10,p_old_Line_Adj_rec.attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_ATTRIBUTE10;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute11,p_old_Line_Adj_rec.attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_ATTRIBUTE11;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute12,p_old_Line_Adj_rec.attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_ATTRIBUTE12;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute13,p_old_Line_Adj_rec.attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_ATTRIBUTE13;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute14,p_old_Line_Adj_rec.attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_ATTRIBUTE14;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute15,p_old_Line_Adj_rec.attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_ATTRIBUTE15;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.COST_ID, p_old_Line_Adj_rec.COST_ID)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_COST_ID;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.TAX_CODE, p_old_Line_Adj_rec.TAX_CODE)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_TAX_CODE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.TAX_EXEMPT_FLAG, p_old_Line_Adj_rec.TAX_EXEMPT_FLAG)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_TAX_EXEMPT_FLAG;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.TAX_EXEMPT_NUMBER, p_old_Line_Adj_rec.TAX_EXEMPT_NUMBER)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_TAX_EXEMPT_NUMBER;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.TAX_EXEMPT_REASON_CODE, p_old_Line_Adj_rec.TAX_EXEMPT_REASON_CODE)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_TAX_EXEMPT_REASON_CODE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.PARENT_ADJUSTMENT_ID, p_old_Line_Adj_rec.PARENT_ADJUSTMENT_ID)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_PARENT_ADJUSTMENT_ID;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.INVOICED_FLAG, p_old_Line_Adj_rec.INVOICED_FLAG)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_INVOICED_FLAG;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.ESTIMATED_FLAG, p_old_Line_Adj_rec.ESTIMATED_FLAG)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_ESTIMATED_FLAG;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.INC_IN_SALES_PERFORMANCE, p_old_Line_Adj_rec.INC_IN_SALES_PERFORMANCE)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_INC_IN_SALES_PERFORMANCE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.SPLIT_ACTION_CODE, p_old_Line_Adj_rec.SPLIT_ACTION_CODE)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_SPLIT_ACTION_CODE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.CHARGE_TYPE_CODE, p_old_Line_Adj_rec.CHARGE_TYPE_CODE)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_CHARGE_TYPE_CODE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.CHARGE_SUBTYPE_CODE, p_old_Line_Adj_rec.CHARGE_SUBTYPE_CODE)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_LINE_ADJ_UTIL.G_CHARGE_SUBTYPE_CODE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.list_line_no, p_old_Line_Adj_rec.list_line_no)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_LIST_LINE_NO;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.source_system_code, p_old_Line_Adj_rec.source_system_code)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_SOURCE_SYSTEM_CODE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.benefit_qty, p_old_Line_Adj_rec.benefit_qty)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_BENEFIT_QTY;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.benefit_uom_code, p_old_Line_Adj_rec.benefit_uom_code)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_BENEFIT_UOM_CODE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.print_on_invoice_flag, p_old_Line_Adj_rec.print_on_invoice_flag)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_PRINT_ON_INVOICE_FLAG;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.expiration_date, p_old_Line_Adj_rec.expiration_date)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_EXPIRATION_DATE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.rebate_transaction_type_code, p_old_Line_Adj_rec.rebate_transaction_type_code)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_REBATE_TRANSACTION_TYPE_CODE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.rebate_transaction_reference, p_old_Line_Adj_rec.rebate_transaction_reference)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_REBATE_TRANSACTION_REFERENCE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.rebate_payment_system_code, p_old_Line_Adj_rec.rebate_payment_system_code)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_REBATE_PAYMENT_SYSTEM_CODE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.redeemed_date, p_old_Line_Adj_rec.redeemed_date)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_REDEEMED_DATE;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.redeemed_flag, p_old_Line_Adj_rec.redeemed_flag)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_REDEEMED_FLAG;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.accrual_flag, p_old_Line_Adj_rec.accrual_flag)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_ACCRUAL_FLAG;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.range_break_quantity, p_old_Line_Adj_rec.range_break_quantity)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_range_break_quantity;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.accrual_conversion_rate, p_old_Line_Adj_rec.accrual_conversion_rate)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_accrual_conversion_rate;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.pricing_group_sequence, p_old_Line_Adj_rec.pricing_group_sequence)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_pricing_group_sequence;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.modifier_level_code, p_old_Line_Adj_rec.modifier_level_code)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_modifier_level_code;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.price_break_type_code, p_old_Line_Adj_rec.price_break_type_code)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_price_break_type_code;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.substitution_attribute, p_old_Line_Adj_rec.substitution_attribute)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_substitution_attribute;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.proration_type_code, p_old_Line_Adj_rec.proration_type_code)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_proration_type_code;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.credit_or_charge_flag, p_old_Line_Adj_rec.credit_or_charge_flag)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_credit_or_charge_flag;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.include_on_returns_flag, p_old_Line_Adj_rec.include_on_returns_flag)
	   THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_include_on_returns_flag;
	   END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.ac_context,p_old_Line_Adj_rec.ac_context)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_AC_CONTEXT;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.ac_attribute1,p_old_Line_Adj_rec.ac_attribute1)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_AC_ATTRIBUTE1;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.ac_attribute2,p_old_Line_Adj_rec.ac_attribute2)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_AC_ATTRIBUTE2;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.ac_attribute3,p_old_Line_Adj_rec.ac_attribute3)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_AC_ATTRIBUTE3;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.ac_attribute4,p_old_Line_Adj_rec.ac_attribute4)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_AC_ATTRIBUTE4;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.ac_attribute5,p_old_Line_Adj_rec.ac_attribute5)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_AC_ATTRIBUTE5;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.ac_attribute6,p_old_Line_Adj_rec.ac_attribute6)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_AC_ATTRIBUTE6;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.ac_attribute7,p_old_Line_Adj_rec.ac_attribute7)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_AC_ATTRIBUTE7;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.ac_attribute8,p_old_Line_Adj_rec.ac_attribute8)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_AC_ATTRIBUTE8;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.ac_attribute9,p_old_Line_Adj_rec.ac_attribute9)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_AC_ATTRIBUTE9;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.ac_attribute10,p_old_Line_Adj_rec.ac_attribute10)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_AC_ATTRIBUTE10;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.ac_attribute11,p_old_Line_Adj_rec.ac_attribute11)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_AC_ATTRIBUTE11;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.ac_attribute12,p_old_Line_Adj_rec.ac_attribute12)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_AC_ATTRIBUTE12;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.ac_attribute13,p_old_Line_Adj_rec.ac_attribute13)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_AC_ATTRIBUTE13;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.ac_attribute14,p_old_Line_Adj_rec.ac_attribute14)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_AC_ATTRIBUTE14;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.ac_attribute15,p_old_Line_Adj_rec.ac_attribute15)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_AC_ATTRIBUTE15;
        END IF;

        --uom begin
        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.operand_per_pqty,p_old_Line_Adj_rec.operand_per_pqty)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_OPERAND_PER_PQTY;
        END IF;

        IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.adjusted_amount_per_pqty,p_old_Line_Adj_rec.adjusted_amount_per_pqty)
        THEN
            l_index := l_index + 1;
            l_src_attr_tbl(l_index) := OE_Line_ADJ_UTIL.G_ADJUSTED_AMOUNT_PER_PQTY;
        END IF;

        --uom end

    ELSE

        l_index := l_index + 1;
        l_src_attr_tbl(l_index) := p_attr_id;

    END IF;

    If l_src_attr_tbl.COUNT <> 0 THEN

        OE_Dependencies.Mark_Dependent
        (p_entity_code     => OE_GLOBALS.G_ENTITY_LINE_ADJ,
        p_source_attr_tbl => l_src_attr_tbl,
        p_dep_attr_tbl    => l_dep_attr_tbl);

        FOR I IN 1..l_dep_attr_tbl.COUNT LOOP

            IF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_PRICE_ADJUSTMENT THEN
                p_x_Line_Adj_rec.PRICE_ADJUSTMENT_ID := FND_API.G_MISS_NUM;

            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_ADJUSTED_AMOUNT THEN
                p_x_Line_Adj_rec.ADJUSTED_AMOUNT := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_PRICING_PHASE_ID THEN
                p_x_Line_Adj_rec.PRICING_PHASE_ID := FND_API.G_MISS_NUM;


            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_CREATION_DATE THEN
                p_x_Line_Adj_rec.CREATION_DATE := FND_API.G_MISS_DATE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_CREATED_BY THEN
                p_x_Line_Adj_rec.CREATED_BY := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_LAST_UPDATE_DATE THEN
                p_x_Line_Adj_rec.LAST_UPDATE_DATE := FND_API.G_MISS_DATE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_LAST_UPDATED_BY THEN
                p_x_Line_Adj_rec.LAST_UPDATED_BY := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_LAST_UPDATE_LOGIN THEN
                p_x_Line_Adj_rec.LAST_UPDATE_LOGIN := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_PROGRAM_APPLICATION THEN
                p_x_Line_Adj_rec.PROGRAM_APPLICATION_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_PROGRAM THEN
                p_x_Line_Adj_rec.PROGRAM_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_PROGRAM_UPDATE_DATE THEN
                p_x_Line_Adj_rec.PROGRAM_UPDATE_DATE := FND_API.G_MISS_DATE;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_REQUEST THEN
                p_x_Line_Adj_rec.REQUEST_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_HEADER THEN
                p_x_Line_Adj_rec.HEADER_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_DISCOUNT THEN
                p_x_Line_Adj_rec.DISCOUNT_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_DISCOUNT_LINE THEN
                p_x_Line_Adj_rec.DISCOUNT_LINE_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_AUTOMATIC THEN
                p_x_Line_Adj_rec.AUTOMATIC_FLAG := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_PERCENT THEN
                p_x_Line_Adj_rec.PERCENT := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_LINE THEN
                p_x_Line_Adj_rec.LINE_ID := FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_CONTEXT THEN
                p_x_Line_Adj_rec.CONTEXT := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_ATTRIBUTE1 THEN
                p_x_Line_Adj_rec.ATTRIBUTE1 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_ATTRIBUTE2 THEN
                p_x_Line_Adj_rec.ATTRIBUTE2 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_ATTRIBUTE3 THEN
                p_x_Line_Adj_rec.ATTRIBUTE3 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_ATTRIBUTE4 THEN
                p_x_Line_Adj_rec.ATTRIBUTE4 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_ATTRIBUTE5 THEN
                p_x_Line_Adj_rec.ATTRIBUTE5 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_ATTRIBUTE6 THEN
                p_x_Line_Adj_rec.ATTRIBUTE6 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_ATTRIBUTE7 THEN
                p_x_Line_Adj_rec.ATTRIBUTE7 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_ATTRIBUTE8 THEN
                p_x_Line_Adj_rec.ATTRIBUTE8 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_ATTRIBUTE9 THEN
                p_x_Line_Adj_rec.ATTRIBUTE9 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_ATTRIBUTE10 THEN
                p_x_Line_Adj_rec.ATTRIBUTE10 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_ATTRIBUTE11 THEN
                p_x_Line_Adj_rec.ATTRIBUTE11 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_ATTRIBUTE12 THEN
                p_x_Line_Adj_rec.ATTRIBUTE12 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_ATTRIBUTE13 THEN
                p_x_Line_Adj_rec.ATTRIBUTE13 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_ATTRIBUTE14 THEN
                p_x_Line_Adj_rec.ATTRIBUTE14 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_ATTRIBUTE15 THEN
                p_x_Line_Adj_rec.ATTRIBUTE15 := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_COST_ID THEN
			 p_x_Line_Adj_rec.COST_ID := FND_API.G_MISS_NUM;
		  ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_TAX_CODE THEN
			 p_x_Line_Adj_rec.TAX_CODE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_TAX_EXEMPT_FLAG THEN
			 p_x_Line_Adj_rec.TAX_EXEMPT_FLAG := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_TAX_EXEMPT_NUMBER THEN
			 p_x_Line_Adj_rec.TAX_EXEMPT_NUMBER := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_TAX_EXEMPT_REASON_CODE THEN
			 p_x_Line_Adj_rec.TAX_EXEMPT_REASON_CODE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_PARENT_ADJUSTMENT_ID THEN
			 p_x_Line_Adj_rec.PARENT_ADJUSTMENT_ID := FND_API.G_MISS_NUM;
		  ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_INVOICED_FLAG THEN
			 p_x_Line_Adj_rec.INVOICED_FLAG := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_ESTIMATED_FLAG THEN
			 p_x_Line_Adj_rec.ESTIMATED_FLAG := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_INC_IN_SALES_PERFORMANCE THEN
			 p_x_Line_Adj_rec.INC_IN_SALES_PERFORMANCE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_SPLIT_ACTION_CODE THEN
			 p_x_Line_Adj_rec.SPLIT_ACTION_CODE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_CHARGE_TYPE_CODE THEN
			 p_x_Line_Adj_rec.CHARGE_TYPE_CODE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_CHARGE_SUBTYPE_CODE THEN
			 p_x_Line_Adj_rec.CHARGE_SUBTYPE_CODE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Line_ADJ_UTIL.G_LIST_LINE_NO THEN
			 p_x_Line_Adj_rec.LIST_LINE_NO := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Line_ADJ_UTIL.G_SOURCE_SYSTEM_CODE THEN
			 p_x_Line_Adj_rec.SOURCE_SYSTEM_CODE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Line_ADJ_UTIL.G_BENEFIT_QTY THEN
			 p_x_Line_Adj_rec.BENEFIT_QTY := FND_API.G_MISS_NUM;
		  ELSIF l_dep_attr_tbl(I) = OE_Line_ADJ_UTIL.G_BENEFIT_UOM_CODE THEN
			 p_x_Line_Adj_rec.BENEFIT_UOM_CODE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Line_ADJ_UTIL.G_PRINT_ON_INVOICE_FLAG THEN
			 p_x_Line_Adj_rec.PRINT_ON_INVOICE_FLAG := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Line_ADJ_UTIL.G_EXPIRATION_DATE THEN
			 p_x_Line_Adj_rec.EXPIRATION_DATE := FND_API.G_MISS_DATE;
		  ELSIF l_dep_attr_tbl(I) = OE_Line_ADJ_UTIL.G_REBATE_TRANSACTION_TYPE_CODE THEN
			 p_x_Line_Adj_rec.REBATE_TRANSACTION_TYPE_CODE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Line_ADJ_UTIL.G_REBATE_TRANSACTION_REFERENCE THEN
			 p_x_Line_Adj_rec.REBATE_TRANSACTION_REFERENCE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Line_ADJ_UTIL.G_REBATE_PAYMENT_SYSTEM_CODE THEN
			 p_x_Line_Adj_rec.REBATE_PAYMENT_SYSTEM_CODE := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Line_ADJ_UTIL.G_REDEEMED_DATE THEN
			 p_x_Line_Adj_rec.REDEEMED_DATE := FND_API.G_MISS_DATE;
		  ELSIF l_dep_attr_tbl(I) = OE_Line_ADJ_UTIL.G_REDEEMED_FLAG THEN
			 p_x_Line_Adj_rec.REDEEMED_FLAG := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Line_ADJ_UTIL.G_ACCRUAL_FLAG THEN
			 p_x_Line_Adj_rec.ACCRUAL_FLAG := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Line_ADJ_UTIL.G_range_break_quantity THEN
			 p_x_Line_Adj_rec.range_break_quantity := FND_API.G_MISS_NUM;
		  ELSIF l_dep_attr_tbl(I) = OE_Line_ADJ_UTIL.G_accrual_conversion_rate THEN
			 p_x_Line_Adj_rec.accrual_conversion_rate := FND_API.G_MISS_NUM;
		  ELSIF l_dep_attr_tbl(I) = OE_Line_ADJ_UTIL.G_pricing_group_sequence THEN
			 p_x_Line_Adj_rec.pricing_group_sequence := FND_API.G_MISS_NUM;
		  ELSIF l_dep_attr_tbl(I) = OE_Line_ADJ_UTIL.G_modifier_level_code THEN
			 p_x_Line_Adj_rec.modifier_level_code := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Line_ADJ_UTIL.G_price_break_type_code THEN
			 p_x_Line_Adj_rec.price_break_type_code := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Line_ADJ_UTIL.G_substitution_attribute THEN
			 p_x_Line_Adj_rec.substitution_attribute := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Line_ADJ_UTIL.G_proration_type_code THEN
			 p_x_Line_Adj_rec.proration_type_code := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Line_ADJ_UTIL.G_credit_or_charge_flag THEN
			 p_x_Line_Adj_rec.credit_or_charge_flag := FND_API.G_MISS_CHAR;
		  ELSIF l_dep_attr_tbl(I) = OE_Line_ADJ_UTIL.G_include_on_returns_flag THEN
			 p_x_Line_Adj_rec.include_on_returns_flag := FND_API.G_MISS_CHAR;

            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_AC_CONTEXT THEN
                p_x_LINE_Adj_rec.AC_CONTEXT := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_AC_ATTRIBUTE1 THEN
                p_x_LINE_Adj_rec.AC_ATTRIBUTE1 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_AC_ATTRIBUTE2 THEN
                p_x_LINE_Adj_rec.AC_ATTRIBUTE2 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_AC_ATTRIBUTE3 THEN
                p_x_LINE_Adj_rec.AC_ATTRIBUTE3 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_AC_ATTRIBUTE4 THEN
                p_x_LINE_Adj_rec.AC_ATTRIBUTE4 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_AC_ATTRIBUTE5 THEN
                p_x_LINE_Adj_rec.AC_ATTRIBUTE5 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_AC_ATTRIBUTE6 THEN
                p_x_LINE_Adj_rec.AC_ATTRIBUTE6 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_AC_ATTRIBUTE7 THEN
                p_x_LINE_Adj_rec.AC_ATTRIBUTE7 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_AC_ATTRIBUTE8 THEN
                p_x_LINE_Adj_rec.AC_ATTRIBUTE8 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_AC_ATTRIBUTE9 THEN
                p_x_LINE_Adj_rec.AC_ATTRIBUTE9 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_AC_ATTRIBUTE10 THEN
                p_x_LINE_Adj_rec.AC_ATTRIBUTE10 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_AC_ATTRIBUTE11 THEN
                p_x_LINE_Adj_rec.AC_ATTRIBUTE11 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_AC_ATTRIBUTE12 THEN
                p_x_LINE_Adj_rec.AC_ATTRIBUTE12 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_AC_ATTRIBUTE13 THEN
                p_x_LINE_Adj_rec.AC_ATTRIBUTE13 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_AC_ATTRIBUTE14 THEN
                p_x_LINE_Adj_rec.AC_ATTRIBUTE14 := FND_API.G_MISS_CHAR;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_AC_ATTRIBUTE15 THEN
                p_x_LINE_Adj_rec.AC_ATTRIBUTE15 := FND_API.G_MISS_CHAR;
            --uom begin
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_OPERAND_PER_PQTY THEN
                p_x_LINE_Adj_rec.OPERAND_PER_PQTY:=FND_API.G_MISS_NUM;
            ELSIF l_dep_attr_tbl(I) = OE_LINE_ADJ_UTIL.G_ADJUSTED_AMOUNT_PER_PQTY THEN
                p_x_LINE_Adj_rec.ADJUSTED_AMOUNT_PER_PQTY:=FND_API.G_MISS_NUM;
            --uom end
            END IF;
        END LOOP;
    END IF;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'LEAVING CLEAR_DEPENDENT_ATTR' ) ;
END IF;
END Clear_Dependent_Attr;


PROCEDURE Clear_Dependent_Attr
(   p_attr_id                       IN  NUMBER := FND_API.G_MISS_NUM
,   p_x_Line_Adj_rec                IN  out nocopy OE_Order_PUB.Line_Adj_Rec_Type
,   p_old_Line_Adj_rec              IN  OE_Order_PUB.Line_Adj_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_REC
)
IS
l_Line_Adj_rec                OE_AK_Line_PRCADJS_V%ROWTYPE;
l_old_Line_Adj_rec            OE_AK_Line_PRCADJS_V%ROWTYPE ;
l_initial_Line_Adj_rec        OE_AK_Line_PRCADJS_V%ROWTYPE;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    --  Load out record
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING CLEAR_DEPENDENT_ATTR' ) ;
END IF;
 	API_Rec_To_Rowtype_Rec(p_x_Line_Adj_rec , l_Line_Adj_rec);
	API_Rec_To_Rowtype_Rec(p_Old_Line_Adj_rec , l_Old_Line_Adj_rec);
	l_Initial_Line_Adj_rec := l_Line_Adj_rec;

	Clear_Dependent_Attr
			(   p_attr_id                => p_attr_id
			,   p_x_Line_Adj_rec         =>l_Line_Adj_rec
			,   p_old_Line_Adj_rec       =>l_Old_Line_Adj_rec
		--	,   x_Line_Adj_rec           =>l_Line_Adj_rec
			);

	Rowtype_Rec_To_API_Rec(l_Line_Adj_rec,p_x_Line_Adj_Rec);
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'LEAVING CLEAR_DEPENDENT_ATTR' ) ;
END IF;
END Clear_Dependent_Attr;

--  Procedure Apply_Attribute_Changes

PROCEDURE Apply_Attribute_Changes
(   p_x_Line_Adj_rec                IN out nocopy  OE_Order_PUB.Line_Adj_Rec_Type
,   p_old_Line_Adj_rec              IN  OE_Order_PUB.Line_Adj_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_REC
--,   x_Line_Adj_rec                OUT OE_Order_PUB.Line_Adj_Rec_Type
)
  IS
  l_return_status	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_price_flag		boolean := FALSE;
  l_calculate_commitment_flag	VARCHAR2(1) := 'N';
  l_class 		VARCHAR2(30);
  l_so_source_code	VARCHAR2(30);
  l_oe_installed_flag 	VARCHAR2(30);
  l_commitment_id	NUMBER;
  l_verify_payment_flag   VARCHAR2(30) := 'N';
  l_line_category_code	  VARCHAR2(30);

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

    --  Load out record

    --x_Line_Adj_rec := p_Line_Adj_rec;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTERING OE_LINE_ADJ_UTIL.APPLY ATTRIBUTE CHANGES' ) ;
END IF;
    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.adjusted_amount,p_old_Line_Adj_rec.adjusted_amount)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.adjusted_amount_per_pqty,p_old_Line_Adj_rec.adjusted_amount_per_pqty)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.pricing_phase_id,p_old_Line_Adj_rec.pricing_phase_id)
    THEN
	 		l_price_flag := TRUE;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.price_adjustment_id,p_old_Line_Adj_rec.price_adjustment_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.creation_date,p_old_Line_Adj_rec.creation_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.created_by,p_old_Line_Adj_rec.created_by)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.last_update_date,p_old_Line_Adj_rec.last_update_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.last_updated_by,p_old_Line_Adj_rec.last_updated_by)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.last_update_login,p_old_Line_Adj_rec.last_update_login)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.program_application_id,p_old_Line_Adj_rec.program_application_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.program_id,p_old_Line_Adj_rec.program_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.program_update_date,p_old_Line_Adj_rec.program_update_date)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.request_id,p_old_Line_Adj_rec.request_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.header_id,p_old_Line_Adj_rec.header_id)
    THEN
        NULL;
    END IF;


    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.discount_id,
			    p_old_Line_Adj_rec.discount_id)
    THEN
		Null;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.discount_line_id,
			    p_old_Line_Adj_rec.discount_line_id)
    THEN
		null;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.automatic_flag,p_old_Line_Adj_rec.automatic_flag)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.percent,p_old_Line_Adj_rec.percent)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.line_id,p_old_Line_Adj_rec.line_id)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.context,p_old_Line_Adj_rec.context)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute1,p_old_Line_Adj_rec.attribute1)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute2,p_old_Line_Adj_rec.attribute2)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute3,p_old_Line_Adj_rec.attribute3)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute4,p_old_Line_Adj_rec.attribute4)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute5,p_old_Line_Adj_rec.attribute5)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute6,p_old_Line_Adj_rec.attribute6)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute7,p_old_Line_Adj_rec.attribute7)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute8,p_old_Line_Adj_rec.attribute8)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute9,p_old_Line_Adj_rec.attribute9)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute10,p_old_Line_Adj_rec.attribute10)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute11,p_old_Line_Adj_rec.attribute11)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute12,p_old_Line_Adj_rec.attribute12)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute13,p_old_Line_Adj_rec.attribute13)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute14,p_old_Line_Adj_rec.attribute14)
    THEN
        NULL;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.attribute15,p_old_Line_Adj_rec.attribute15)
    THEN
        NULL;
    END IF;

	IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.list_header_id,
				  p_old_Line_Adj_rec.list_header_id)
     THEN
	  NULL;
	END IF;

	IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.list_line_id,
			p_old_Line_Adj_rec.list_line_id)
     THEN
	  NULL;
     END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.list_line_type_code,
    p_old_Line_Adj_rec.list_line_type_code)
	   THEN
		 NULL;
	END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.modifier_mechanism_type_code,
    p_old_Line_Adj_rec.modifier_mechanism_type_code)
     THEN
		 NULL;
	END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.update_allowed,
		p_old_Line_Adj_rec.update_allowed)
    THEN
		 NULL;
	END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.updated_flag,
		p_old_Line_Adj_rec.updated_flag)
	 THEN
	 	l_price_flag := TRUE;
	  IF p_x_line_Adj_rec.ESTIMATED_FLAG = 'Y' AND
		p_x_line_Adj_rec.updated_flag = 'Y'
	  THEN
		 p_x_line_adj_rec.estimated_flag := 'N';
	  END IF;
	  IF p_x_line_Adj_rec.ESTIMATED_FLAG = 'N' AND
		p_x_line_Adj_rec.updated_flag = 'N'
	  THEN
		 p_x_line_adj_rec.estimated_flag := 'Y';
	  END IF;
	END IF;

    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.applied_flag,
		p_old_Line_Adj_rec.applied_flag)
    THEN
	 	l_price_flag := TRUE;
                --added by ksurendr
		--bug 4060297
		--Delayed request to compute margin
                oe_header_Adj_util.log_request_for_margin(p_x_Line_Adj_rec.header_id);
    END IF;

    -- added by lkxu: populate the change reason when manual adjustment
    -- is applied by user.
    IF p_x_Line_Adj_rec.applied_flag = 'Y'
	  AND p_x_Line_Adj_rec.automatic_flag = 'N'
	  AND p_x_Line_Adj_rec.change_reason_code IS NULL THEN
         BEGIN
	    SELECT lookup_code, meaning
	    INTO   p_x_Line_Adj_rec.change_reason_code,
		      p_x_Line_Adj_rec.change_reason_text
	    FROM   oe_lookups
	    WHERE  lookup_type = 'CHANGE_CODE'
	    AND    lookup_code = 'MANUAL';

	    EXCEPTION WHEN NO_DATA_FOUND THEN
		 null;
         END;
    END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.modified_from,
   p_old_Line_Adj_rec.modified_from)
   THEN
	 NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.modified_to,
		p_old_Line_Adj_rec.modified_to)
   THEN
	 NULL;
   END IF;


    IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.change_reason_code,
		p_old_Line_Adj_rec.change_reason_code)
	THEN
	   NULL;
	END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.change_reason_text,
		p_old_Line_Adj_rec.change_reason_text)
     THEN
	 NULL;
	END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.operand,
		p_old_Line_Adj_rec.operand)
     THEN
	 	l_price_flag := TRUE;
                l_calculate_commitment_flag := 'Y';

                --bug 4060297
                oe_header_Adj_util.log_request_for_margin(p_x_Line_Adj_rec.header_id);

        -- fixed bug 3271297, to log Verify Payment delayed request
        -- when freight charge changes.
        IF p_x_Line_Adj_rec.list_line_type_code='FREIGHT_CHARGE' THEN
                l_verify_payment_flag := 'Y';
        END IF;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.operand_per_pqty,
		p_old_Line_Adj_rec.operand_per_pqty)
     THEN
	 	l_price_flag := TRUE;
	END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.arithmetic_operator,
		p_old_Line_Adj_rec.arithmetic_operator)
     THEN
	 	l_price_flag := TRUE;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.COST_ID, p_old_Line_Adj_rec.COST_ID)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.TAX_CODE, p_old_Line_Adj_rec.TAX_CODE)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.TAX_EXEMPT_FLAG, p_old_Line_Adj_rec.TAX_EXEMPT_FLAG)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.TAX_EXEMPT_NUMBER, p_old_Line_Adj_rec.TAX_EXEMPT_NUMBER)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.TAX_EXEMPT_REASON_CODE, p_old_Line_Adj_rec.TAX_EXEMPT_REASON_CODE)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.PARENT_ADJUSTMENT_ID, p_old_Line_Adj_rec.PARENT_ADJUSTMENT_ID)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.INVOICED_FLAG, p_old_Line_Adj_rec.INVOICED_FLAG)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.ESTIMATED_FLAG, p_old_Line_Adj_rec.ESTIMATED_FLAG)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.INC_IN_SALES_PERFORMANCE, p_old_Line_Adj_rec.INC_IN_SALES_PERFORMANCE)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.SPLIT_ACTION_CODE, p_old_Line_Adj_rec.SPLIT_ACTION_CODE)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.CHARGE_TYPE_CODE, p_old_Line_Adj_rec.CHARGE_TYPE_CODE)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.CHARGE_SUBTYPE_CODE, p_old_Line_Adj_rec.CHARGE_SUBTYPE_CODE)
   THEN
	  NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.list_line_no, p_old_Line_Adj_rec.list_line_no)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.source_system_code, p_old_Line_Adj_rec.source_system_code)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.benefit_qty, p_old_Line_Adj_rec.benefit_qty)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.benefit_uom_code, p_old_Line_Adj_rec.benefit_uom_code)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.print_on_invoice_flag, p_old_Line_Adj_rec.print_on_invoice_flag)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.expiration_date, p_old_Line_Adj_rec.expiration_date)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.rebate_transaction_type_code, p_old_Line_Adj_rec.rebate_transaction_type_code)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.rebate_transaction_reference, p_old_Line_Adj_rec.rebate_transaction_reference)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.rebate_payment_system_code, p_old_Line_Adj_rec.rebate_payment_system_code)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.redeemed_date, p_old_Line_Adj_rec.redeemed_date)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.redeemed_flag, p_old_Line_Adj_rec.redeemed_flag)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.accrual_flag, p_old_Line_Adj_rec.accrual_flag)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.range_break_quantity, p_old_Line_Adj_rec.range_break_quantity)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.accrual_conversion_rate, p_old_Line_Adj_rec.accrual_conversion_rate)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.pricing_group_sequence, p_old_Line_Adj_rec.pricing_group_sequence)
   THEN
	 		l_price_flag := TRUE;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.modifier_level_code, p_old_Line_Adj_rec.modifier_level_code)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.price_break_type_code, p_old_Line_Adj_rec.price_break_type_code)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.substitution_attribute, p_old_Line_Adj_rec.substitution_attribute)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.proration_type_code, p_old_Line_Adj_rec.proration_type_code)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.credit_or_charge_flag, p_old_Line_Adj_rec.credit_or_charge_flag)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_Line_Adj_rec.include_on_returns_flag, p_old_Line_Adj_rec.include_on_returns_flag)
   THEN
          NULL;
   END IF;

   IF NOT OE_GLOBALS.Equal(p_x_line_Adj_rec.INVOICED_AMOUNT, p_old_Line_Adj_rec.INVOICED_AMOUNT)
   THEN
	  NULL;
   END IF;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RECURSION_MODE'||OE_GLOBALS.G_RECURSION_MODE||' PRICING:'||OE_GLOBALS.G_PRICING_RECURSION , 1 ) ;
           oe_debug_pub.add(  'HEADER_ID'||P_X_LINE_ADJ_REC.HEADER_ID , 1 ) ;
           oe_debug_pub.add(  'LINE_ID'||P_X_LINE_ADJ_REC.LINE_ID , 1 ) ;
       END IF;
       if (l_price_flag) then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'PRICE FLAG:Y' , 1 ) ;
         END IF;
       else
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'PRICE FLAG:N' , 1 ) ;
         END IF;
       end if;

        -- bug 2378843: don't log request when g_pricing_recursion is set
    	IF l_price_flag and OE_Globals.G_RECURSION_MODE <> 'Y' AND
                             OE_GLOBALS.G_PRICING_RECURSION <> 'Y' AND
	   p_x_line_adj_rec.list_line_type_code NOT IN ('TAX','COST')
	Then

        IF (p_x_Line_adj_rec.line_id IS NOT NULL) THEN

	 /* 1905650
	    G_PRICE_ADJ request should be logged against LINE entity,
	    not against LINE_ADJ entity
	 */
         If OE_GLOBALS.G_UI_FLAG and nvl(p_x_Line_adj_rec.automatic_flag,'Y') = 'N' Then
            --we need to log different delayed request for manual adjustments.
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  ' UI FLAG IS TRUE , LOGGING UI DELAYED REQUEST FOR ADJ' ) ;
            END IF;
            oe_delayed_requests_pvt.log_request(
	    p_entity_code                => OE_GLOBALS.G_ENTITY_LINE,
	    p_entity_id                     => p_x_Line_adj_rec.Line_id,
	    p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE_ADJ,
	    p_requesting_entity_id   => p_x_Line_adj_rec.Line_id,
	    p_request_type           => OE_GLOBALS.G_PRICE_ADJ,
            p_param1                 => 'UI',
	    x_return_status          => l_return_status);
         Else
	        oe_delayed_requests_pvt.log_request(
		p_entity_code    	     => OE_GLOBALS.G_ENTITY_LINE,
		p_entity_id      		=> p_x_Line_adj_rec.Line_id,
		p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE_ADJ,
		p_requesting_entity_id   => p_x_Line_adj_rec.Line_id,
		p_request_type   		=> OE_GLOBALS.G_PRICE_ADJ,
		x_return_status  		=> l_return_status);
         End If;
        ELSE
	        oe_delayed_requests_pvt.log_request(
		p_entity_code    	     => OE_GLOBALS.G_ENTITY_ALL,
		p_entity_id      		=> p_x_Line_adj_rec.header_id,
		p_requesting_entity_code => OE_GLOBALS.G_ENTITY_HEADER_ADJ,
		p_requesting_entity_id   => p_x_Line_adj_rec.header_id,
		p_request_type   		=> OE_GLOBALS.G_PRICE_ADJ,
		x_return_status  		=> l_return_status);
        END IF;
	  l_price_flag := FALSE;
  End If;

  IF l_calculate_commitment_flag = 'Y' THEN
    l_class := NULL;
    l_so_source_code := FND_PROFILE.VALUE('ONT_SOURCE_CODE');
    l_oe_installed_flag := 'I';
    BEGIN
      SELECT commitment_id
      INTO   l_commitment_id
      FROM   oe_order_lines
      WHERE  line_id = p_old_line_adj_rec.line_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    IF l_commitment_id IS NOT NULL
       AND OE_Commitment_Pvt.Do_Commitment_Sequencing  THEN
      oe_globals.g_commitment_balance := ARP_BAL_UTIL.GET_COMMITMENT_BALANCE(
                 l_commitment_id
                ,l_class
                ,l_so_source_code
                ,l_oe_installed_flag );

	OE_Delayed_Requests_Pvt.Log_Request(
	p_entity_code			=>	OE_GLOBALS.G_ENTITY_LINE,
	p_entity_id			=>	p_x_line_adj_rec.line_id,
	p_requesting_entity_code	=>	OE_GLOBALS.G_ENTITY_LINE,
	p_requesting_entity_id  	=>	p_x_line_adj_rec.line_id,
	p_request_type			=>	OE_GLOBALS.G_CALCULATE_COMMITMENT,
	x_return_status			=>	l_return_status);
    END IF;
  END IF;

   IF (l_verify_payment_flag = 'Y') THEN
           --Start bug# 5961160
           -- Query the Order Header
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add( 'OEXULADB: BEFORE QUERYING HEADER ID : '|| p_x_line_adj_rec.header_id ) ;
           END IF;

           OE_Header_UTIL.Query_Row
             (p_header_id               => p_x_line_adj_rec.header_id
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
              oe_debug_pub.add( 'OEXULADB: BEFORE CALLING WHICH RULE ' ) ;
           END IF;

           l_calling_action := OE_Verify_Payment_PUB.Which_Rule(p_header_id => p_x_line_adj_rec.header_id);

           IF l_debug_level  > 0 THEN
              oe_debug_pub.add( 'OEXULADB: RULE TO BE USED IS : '|| l_calling_action ) ;
           END IF;

           IF l_debug_level  > 0 THEN
              oe_debug_pub.add( 'OEXULADB: BEFORE CHECKING IF THE RULE IS DEFINED OR NOT' ) ;
           END IF;

           l_rule_defined := OE_Verify_Payment_PUB.Check_Rule_Defined
                                ( p_header_rec     => l_header_rec
                                , p_calling_action => l_calling_action
                                ) ;

           IF l_debug_level  > 0 THEN
              oe_debug_pub.add( 'OEXULADB: OUT OF RULE DEFINED : '|| l_rule_defined);
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
                 oe_debug_pub.add( 'OEXULADB: INCL FREIGHT CHARGE FLAG : '|| l_credit_check_rule_rec.incl_freight_charges_flag);
              END IF;

              IF NVL(l_credit_check_rule_rec.incl_freight_charges_flag,'N') = 'Y' THEN
                 BEGIN
                   SELECT line_category_code
                   INTO   l_line_category_code
                   FROM   oe_order_lines_all
                   WHERE  line_id = p_x_line_adj_rec.line_id;
                 EXCEPTION WHEN NO_DATA_FOUND THEN
                   null;
                 END;
                IF l_line_category_code <> 'RETURN' THEN
                    oe_debug_pub.ADD('OEXULADB: Logging delayed request for Verify Payment');
                    OE_delayed_requests_Pvt.log_request
                     (p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
                      p_entity_id              => p_x_line_adj_rec.header_id,
                      p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                      p_requesting_entity_id   => p_x_line_adj_rec.line_id,
                      p_request_type           => OE_GLOBALS.G_VERIFY_PAYMENT,
                      x_return_status          => l_return_status);
                 END IF;
              END IF;
           END IF;
           --End bug#5961160
     END IF;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'OE_LINE_ADJ_UTIL.LEAVING APPLY_ATTRIBUTE_CHANGES' ) ;
END IF;
END Apply_Attribute_Changes;

--  Procedure Complete_Record

PROCEDURE Complete_Record
(   p_x_Line_Adj_rec                IN OUT NOCOPY OE_Order_PUB.Line_Adj_Rec_Type
,   p_old_Line_Adj_rec              IN  OE_Order_PUB.Line_Adj_Rec_Type
)
IS
l_Line_Adj_rec                OE_Order_PUB.Line_Adj_Rec_Type := p_x_Line_Adj_rec;
BEGIN

    IF l_Line_Adj_rec.adjusted_amount = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.adjusted_amount := p_old_Line_Adj_rec.adjusted_amount;
    END IF;

    IF l_Line_Adj_rec.pricing_phase_id = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.pricing_phase_id := p_old_Line_Adj_rec.pricing_phase_id;
    END IF;



    IF l_Line_Adj_rec.price_adjustment_id = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.price_adjustment_id := p_old_Line_Adj_rec.price_adjustment_id;
    END IF;

    IF l_Line_Adj_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_Line_Adj_rec.creation_date := p_old_Line_Adj_rec.creation_date;
    END IF;

    IF l_Line_Adj_rec.created_by = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.created_by := p_old_Line_Adj_rec.created_by;
    END IF;

    IF l_Line_Adj_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_Line_Adj_rec.last_update_date := p_old_Line_Adj_rec.last_update_date;
    END IF;

    IF l_Line_Adj_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.last_updated_by := p_old_Line_Adj_rec.last_updated_by;
    END IF;

    IF l_Line_Adj_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.last_update_login := p_old_Line_Adj_rec.last_update_login;
    END IF;

    IF l_Line_Adj_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.program_application_id := p_old_Line_Adj_rec.program_application_id;
    END IF;

    IF l_Line_Adj_rec.program_id = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.program_id := p_old_Line_Adj_rec.program_id;
    END IF;

    IF l_Line_Adj_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_Line_Adj_rec.program_update_date := p_old_Line_Adj_rec.program_update_date;
    END IF;

    IF l_Line_Adj_rec.request_id = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.request_id := p_old_Line_Adj_rec.request_id;
    END IF;

    IF l_Line_Adj_rec.header_id = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.header_id := p_old_Line_Adj_rec.header_id;
    END IF;

    IF l_Line_Adj_rec.discount_id = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.discount_id := p_old_Line_Adj_rec.discount_id;
    END IF;

    IF l_Line_Adj_rec.discount_line_id = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.discount_line_id := p_old_Line_Adj_rec.discount_line_id;
    END IF;

    IF l_Line_Adj_rec.automatic_flag = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.automatic_flag := p_old_Line_Adj_rec.automatic_flag;
    END IF;

    IF l_Line_Adj_rec.percent = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.percent := p_old_Line_Adj_rec.percent;
    END IF;

    IF l_Line_Adj_rec.line_id = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.line_id := p_old_Line_Adj_rec.line_id;
    END IF;

    IF l_Line_Adj_rec.context = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.context := p_old_Line_Adj_rec.context;
    END IF;

    IF l_Line_Adj_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute1 := p_old_Line_Adj_rec.attribute1;
    END IF;

    IF l_Line_Adj_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute2 := p_old_Line_Adj_rec.attribute2;
    END IF;

    IF l_Line_Adj_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute3 := p_old_Line_Adj_rec.attribute3;
    END IF;

    IF l_Line_Adj_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute4 := p_old_Line_Adj_rec.attribute4;
    END IF;

    IF l_Line_Adj_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute5 := p_old_Line_Adj_rec.attribute5;
    END IF;

    IF l_Line_Adj_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute6 := p_old_Line_Adj_rec.attribute6;
    END IF;

    IF l_Line_Adj_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute7 := p_old_Line_Adj_rec.attribute7;
    END IF;

    IF l_Line_Adj_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute8 := p_old_Line_Adj_rec.attribute8;
    END IF;

    IF l_Line_Adj_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute9 := p_old_Line_Adj_rec.attribute9;
    END IF;

    IF l_Line_Adj_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute10 := p_old_Line_Adj_rec.attribute10;
    END IF;

    IF l_Line_Adj_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute11 := p_old_Line_Adj_rec.attribute11;
    END IF;

    IF l_Line_Adj_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute12 := p_old_Line_Adj_rec.attribute12;
    END IF;

    IF l_Line_Adj_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute13 := p_old_Line_Adj_rec.attribute13;
    END IF;

    IF l_Line_Adj_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute14 := p_old_Line_Adj_rec.attribute14;
    END IF;

    IF l_Line_Adj_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute15 := p_old_Line_Adj_rec.attribute15;
    END IF;

-- new code
    IF l_Line_Adj_rec.list_header_id = FND_API.G_MISS_NUM THEN
	  l_Line_Adj_rec.list_header_id := p_old_Line_Adj_rec.list_header_id;
	END IF;

	IF l_Line_Adj_rec.list_line_id = FND_API.G_MISS_NUM THEN
	   l_Line_Adj_rec.list_line_id := p_old_Line_Adj_rec.list_line_id;
	 END IF;

	 IF l_Line_Adj_rec.modified_from = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.modified_from := p_old_Line_Adj_rec.modified_from;
	  END IF;

	  IF l_Line_Adj_rec.modified_to = FND_API.G_MISS_CHAR THEN
		l_Line_Adj_rec.modified_to := p_old_Line_Adj_rec.modified_to;
	   END IF;

    IF l_Line_Adj_rec.list_line_type_code = FND_API.G_MISS_CHAR THEN
		l_Line_Adj_rec.list_line_type_code :=
			p_old_Line_Adj_rec.list_line_type_code;
	 END IF;

	IF l_Line_Adj_rec.updated_flag = FND_API.G_MISS_CHAR THEN
	   l_Line_Adj_rec.updated_flag := p_old_Line_Adj_rec.updated_flag;
	  END IF;

	 IF l_Line_Adj_rec.update_allowed = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.update_allowed := p_old_Line_Adj_rec.update_allowed;
	   END IF;

	  IF l_Line_Adj_rec.applied_flag = FND_API.G_MISS_CHAR THEN
		l_Line_Adj_rec.applied_flag := p_old_Line_Adj_rec.applied_flag;
	   END IF;

  IF l_Line_Adj_rec.modifier_mechanism_type_code = FND_API.G_MISS_CHAR THEN
	 	l_Line_Adj_rec.modifier_mechanism_type_code :=
	 		p_old_Line_Adj_rec.modifier_mechanism_type_code;
	  END IF;

    IF l_Line_Adj_rec.change_reason_code = FND_API.G_MISS_CHAR THEN
	  l_Line_Adj_rec.change_reason_code :=
			p_old_Line_Adj_rec.change_reason_code;
	 END IF;

	IF l_Line_Adj_rec.change_reason_text = FND_API.G_MISS_CHAR THEN
	   l_Line_Adj_rec.change_reason_text :=
	   p_old_Line_Adj_rec.change_reason_text;
	 END IF;

	IF l_Line_Adj_rec.operand = FND_API.G_MISS_NUM THEN
	   l_Line_Adj_rec.operand :=
	   p_old_Line_Adj_rec.operand;
	 END IF;

	IF l_Line_Adj_rec.arithmetic_operator = FND_API.G_MISS_CHAR THEN
	   l_Line_Adj_rec.arithmetic_operator :=
	   p_old_Line_Adj_rec.arithmetic_operator;
	 END IF;

	IF l_Line_Adj_rec.cost_id = FND_API.G_MISS_NUM THEN
	    l_Line_Adj_rec.cost_id :=  p_old_Line_Adj_rec.cost_id;
	END IF;

	IF l_Line_Adj_rec.tax_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.tax_code := p_old_Line_Adj_rec.tax_code;
	END IF;

	IF l_Line_Adj_rec.tax_exempt_flag = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.tax_exempt_flag :=
	    p_old_Line_Adj_rec.tax_exempt_flag;
	END IF;

	IF l_Line_Adj_rec.tax_exempt_number = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.tax_exempt_number :=
	    p_old_Line_Adj_rec.tax_exempt_number;
	END IF;

	IF l_Line_Adj_rec.tax_exempt_reason_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.tax_exempt_reason_code :=
	    p_old_Line_Adj_rec.tax_exempt_reason_code;
	END IF;

	IF l_Line_Adj_rec.parent_adjustment_id = FND_API.G_MISS_NUM THEN
	    l_Line_Adj_rec.parent_adjustment_id :=
	    p_old_Line_Adj_rec.parent_adjustment_id;
	END IF;

	IF l_Line_Adj_rec.invoiced_flag = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.invoiced_flag :=
	    p_old_Line_Adj_rec.invoiced_flag;
	END IF;

	IF l_Line_Adj_rec.estimated_flag = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.estimated_flag :=
	    p_old_Line_Adj_rec.estimated_flag;
	END IF;

	IF l_Line_Adj_rec.inc_in_sales_performance = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.inc_in_sales_performance :=
	    p_old_Line_Adj_rec.inc_in_sales_performance;
	END IF;

	IF l_Line_Adj_rec.split_action_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.split_action_code :=
	    p_old_Line_Adj_rec.split_action_code;
	END IF;

	IF l_Line_Adj_rec.charge_type_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.charge_type_code :=
	    p_old_Line_Adj_rec.charge_type_code;
	END IF;

	IF l_Line_Adj_rec.charge_subtype_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.charge_subtype_code :=
	    p_old_Line_Adj_rec.charge_subtype_code;
	END IF;

	IF l_Line_Adj_rec.list_line_no = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.list_line_no :=
	    p_old_Line_Adj_rec.list_line_no;
	END IF;

	IF l_Line_Adj_rec.source_system_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.source_system_code :=
	    p_old_Line_Adj_rec.source_system_code;
	END IF;

	IF l_Line_Adj_rec.benefit_qty = FND_API.G_MISS_NUM THEN
	    l_Line_Adj_rec.benefit_qty :=
	    p_old_Line_Adj_rec.benefit_qty;
	END IF;

	IF l_Line_Adj_rec.benefit_uom_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.benefit_uom_code :=
	    p_old_Line_Adj_rec.benefit_uom_code;
	END IF;

	IF l_Line_Adj_rec.print_on_invoice_flag = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.print_on_invoice_flag :=
	    p_old_Line_Adj_rec.print_on_invoice_flag;
	END IF;

	IF l_Line_Adj_rec.expiration_date = FND_API.G_MISS_DATE THEN
	    l_Line_Adj_rec.expiration_date :=
	    p_old_Line_Adj_rec.expiration_date;
	END IF;

	IF l_Line_Adj_rec.rebate_transaction_type_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.rebate_transaction_type_code :=
	    p_old_Line_Adj_rec.rebate_transaction_type_code;
	END IF;

	IF l_Line_Adj_rec.rebate_transaction_reference = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.rebate_transaction_reference :=
	    p_old_Line_Adj_rec.rebate_transaction_reference;
	END IF;

	IF l_Line_Adj_rec.rebate_payment_system_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.rebate_payment_system_code :=
	    p_old_Line_Adj_rec.rebate_payment_system_code;
	END IF;

	IF l_Line_Adj_rec.redeemed_date = FND_API.G_MISS_DATE THEN
	    l_Line_Adj_rec.redeemed_date :=
	    p_old_Line_Adj_rec.redeemed_date;
	END IF;

	IF l_Line_Adj_rec.redeemed_flag = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.redeemed_flag :=
	    p_old_Line_Adj_rec.redeemed_flag;
	END IF;

	IF l_Line_Adj_rec.accrual_flag = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.accrual_flag :=
	    p_old_Line_Adj_rec.accrual_flag;
	END IF;

	IF l_Line_Adj_rec.range_break_quantity = FND_API.G_MISS_NUM THEN
	    l_Line_Adj_rec.range_break_quantity := p_old_Line_Adj_rec.range_break_quantity;
	END IF;

	IF l_Line_Adj_rec.accrual_conversion_rate = FND_API.G_MISS_NUM THEN
	    l_Line_Adj_rec.accrual_conversion_rate := p_old_Line_Adj_rec.accrual_conversion_rate;
	END IF;

	IF l_Line_Adj_rec.pricing_group_sequence = FND_API.G_MISS_NUM THEN
	    l_Line_Adj_rec.pricing_group_sequence := p_old_Line_Adj_rec.pricing_group_sequence;
	END IF;

	IF l_Line_Adj_rec.modifier_level_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.modifier_level_code := p_old_Line_Adj_rec.modifier_level_code;
	END IF;

	IF l_Line_Adj_rec.price_break_type_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.price_break_type_code := p_old_Line_Adj_rec.price_break_type_code;
	END IF;

	IF l_Line_Adj_rec.substitution_attribute = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.substitution_attribute := p_old_Line_Adj_rec.substitution_attribute;
	END IF;

	IF l_Line_Adj_rec.proration_type_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.proration_type_code := p_old_Line_Adj_rec.proration_type_code;
	END IF;

	IF l_Line_Adj_rec.credit_or_charge_flag = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.credit_or_charge_flag := p_old_Line_Adj_rec.credit_or_charge_flag;
	END IF;

	IF l_Line_Adj_rec.include_on_returns_flag = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.include_on_returns_flag := p_old_Line_Adj_rec.include_on_returns_flag;
	END IF;

    IF l_Line_Adj_rec.ac_context = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_context := p_old_Line_Adj_rec.ac_context;
    END IF;

    IF l_Line_Adj_rec.ac_attribute1 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute1 := p_old_Line_Adj_rec.ac_attribute1;
    END IF;

    IF l_Line_Adj_rec.ac_attribute2 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute2 := p_old_Line_Adj_rec.ac_attribute2;
    END IF;

    IF l_Line_Adj_rec.ac_attribute3 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute3 := p_old_Line_Adj_rec.ac_attribute3;
    END IF;

    IF l_Line_Adj_rec.ac_attribute4 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute4 := p_old_Line_Adj_rec.ac_attribute4;
    END IF;

    IF l_Line_Adj_rec.ac_attribute5 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute5 := p_old_Line_Adj_rec.ac_attribute5;
    END IF;

    IF l_Line_Adj_rec.ac_attribute6 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute6 := p_old_Line_Adj_rec.ac_attribute6;
    END IF;

    IF l_Line_Adj_rec.ac_attribute7 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute7 := p_old_Line_Adj_rec.ac_attribute7;
    END IF;

    IF l_Line_Adj_rec.ac_attribute8 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute8 := p_old_Line_Adj_rec.ac_attribute8;
    END IF;

    IF l_Line_Adj_rec.ac_attribute9 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute9 := p_old_Line_Adj_rec.ac_attribute9;
    END IF;

    IF l_Line_Adj_rec.ac_attribute10 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute10 := p_old_Line_Adj_rec.ac_attribute10;
    END IF;

    IF l_Line_Adj_rec.ac_attribute11 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute11 := p_old_Line_Adj_rec.ac_attribute11;
    END IF;

    IF l_Line_Adj_rec.ac_attribute12 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute12 := p_old_Line_Adj_rec.ac_attribute12;
    END IF;

    IF l_Line_Adj_rec.ac_attribute13 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute13 := p_old_Line_Adj_rec.ac_attribute13;
    END IF;

    IF l_Line_Adj_rec.ac_attribute14 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute14 := p_old_Line_Adj_rec.ac_attribute14;
    END IF;

    IF l_Line_Adj_rec.ac_attribute15 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute15 := p_old_Line_Adj_rec.ac_attribute15;
    END IF;

     --uom begin
    IF l_Line_Adj_rec.operand_per_pqty = FND_API.G_MISS_NUM THEN
    --bug 3063549
    --l_Line_Adj_rec.operand_per_pqty := p_old_Line_Adj_rec.operand_per_pqty;
    l_Line_Adj_rec.operand_per_pqty := NULL;
    END IF;

    IF l_Line_Adj_rec.adjusted_amount_per_pqty = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.adjusted_amount_per_pqty := p_old_Line_Adj_rec.adjusted_amount_per_pqty;
    END IF;
    --uom end

    IF l_Line_Adj_rec.invoiced_amount = FND_API.G_MISS_NUM THEN
	l_Line_Adj_rec.invoiced_amount := p_old_Line_Adj_rec.invoiced_amount;
    END IF;

    -- eBTax Changes
    IF p_x_line_adj_rec.tax_rate_id = FND_API.G_MISS_NUM  THEN
        p_x_line_adj_rec.tax_rate_id := p_old_line_adj_rec.tax_rate_id;
    END IF;
    -- end eBTax changes


    -- RETURN l_Line_Adj_rec;
    p_x_Line_Adj_rec := l_Line_Adj_rec;

END Complete_Record;

--  Procedure Convert_Miss_To_Null

PROCEDURE Convert_Miss_To_Null
(   p_x_Line_Adj_rec                  IN OUT NOCOPY OE_Order_PUB.Line_Adj_Rec_Type
)
IS
l_Line_Adj_rec                OE_Order_PUB.Line_Adj_Rec_Type := p_x_Line_Adj_rec;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_Line_Adj_rec.adjusted_amount = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.adjusted_amount := NULL;
    END IF;

    IF l_Line_Adj_rec.pricing_phase_id = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.pricing_phase_id := NULL;
    END IF;

    IF l_Line_Adj_rec.price_adjustment_id = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.price_adjustment_id := NULL;
    END IF;

    IF l_Line_Adj_rec.creation_date = FND_API.G_MISS_DATE THEN
        l_Line_Adj_rec.creation_date := NULL;
    END IF;

    IF l_Line_Adj_rec.created_by = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.created_by := NULL;
    END IF;

    IF l_Line_Adj_rec.last_update_date = FND_API.G_MISS_DATE THEN
        l_Line_Adj_rec.last_update_date := NULL;
    END IF;

    IF l_Line_Adj_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.last_updated_by := NULL;
    END IF;

    IF l_Line_Adj_rec.last_update_login = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.last_update_login := NULL;
    END IF;

    IF l_Line_Adj_rec.program_application_id = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.program_application_id := NULL;
    END IF;

    IF l_Line_Adj_rec.program_id = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.program_id := NULL;
    END IF;

    IF l_Line_Adj_rec.program_update_date = FND_API.G_MISS_DATE THEN
        l_Line_Adj_rec.program_update_date := NULL;
    END IF;

    IF l_Line_Adj_rec.request_id = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.request_id := NULL;
    END IF;

    IF l_Line_Adj_rec.header_id = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.header_id := NULL;
    END IF;

    IF l_Line_Adj_rec.discount_id = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.discount_id := NULL;
    END IF;

    IF l_Line_Adj_rec.discount_line_id = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.discount_line_id := NULL;
    END IF;

    IF l_Line_Adj_rec.automatic_flag = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.automatic_flag := NULL;
    END IF;

    IF l_Line_Adj_rec.percent = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.percent := NULL;
    END IF;

    IF l_Line_Adj_rec.line_id = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.line_id := NULL;
    END IF;

    IF l_Line_Adj_rec.context = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.context := NULL;
    END IF;

    IF l_Line_Adj_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute1 := NULL;
    END IF;

    IF l_Line_Adj_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute2 := NULL;
    END IF;

    IF l_Line_Adj_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute3 := NULL;
    END IF;

    IF l_Line_Adj_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute4 := NULL;
    END IF;

    IF l_Line_Adj_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute5 := NULL;
    END IF;

    IF l_Line_Adj_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute6 := NULL;
    END IF;

    IF l_Line_Adj_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute7 := NULL;
    END IF;

    IF l_Line_Adj_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute8 := NULL;
    END IF;

    IF l_Line_Adj_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute9 := NULL;
    END IF;

    IF l_Line_Adj_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute10 := NULL;
    END IF;

    IF l_Line_Adj_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute11 := NULL;
    END IF;

    IF l_Line_Adj_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute12 := NULL;
    END IF;

    IF l_Line_Adj_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute13 := NULL;
    END IF;

    IF l_Line_Adj_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute14 := NULL;
    END IF;

    IF l_Line_Adj_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.attribute15 := NULL;
    END IF;

    IF l_Line_Adj_rec.list_header_id = FND_API.G_MISS_NUM THEN
		 l_Line_Adj_rec.list_header_id := NULL;
    END IF;

	IF l_Line_Adj_rec.list_line_id = FND_API.G_MISS_NUM THEN
		   l_Line_Adj_rec.list_line_id := NULL;
	END IF;

	IF l_Line_Adj_rec.modified_from = FND_API.G_MISS_CHAR THEN
		    l_Line_Adj_rec.modified_from := NULL;
	END IF;
	IF l_Line_Adj_rec.modified_to = FND_API.G_MISS_CHAR THEN
		l_Line_Adj_rec.modified_to := NULL;
	END IF;

    IF l_Line_Adj_rec.list_line_type_code = FND_API.G_MISS_CHAR THEN
		  l_Line_Adj_rec.list_line_type_code := NULL;
    END IF;

    IF l_Line_Adj_rec.updated_flag = FND_API.G_MISS_CHAR THEN
	   l_Line_Adj_rec.updated_flag := NULL;
    END IF;

	IF l_Line_Adj_rec.update_allowed = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.update_allowed := NULL;
	END IF;

     IF l_Line_Adj_rec.applied_flag = FND_API.G_MISS_CHAR THEN
			l_Line_Adj_rec.applied_flag := NULL;
     END IF;

    IF l_Line_Adj_rec.modifier_mechanism_type_code = FND_API.G_MISS_CHAR THEN
		  l_Line_Adj_rec.modifier_mechanism_type_code := NULL;
    END IF;

	IF l_Line_Adj_rec.change_reason_code = FND_API.G_MISS_CHAR THEN
	   l_Line_Adj_rec.change_reason_code := NULL;
	END IF;

	IF l_Line_Adj_rec.change_reason_text = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.change_reason_text := NULL ;
	END IF;

	IF l_Line_Adj_rec.arithmetic_operator = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.arithmetic_operator := NULL ;
	END IF;

	IF l_Line_Adj_rec.operand = FND_API.G_MISS_NUM THEN
	    l_Line_Adj_rec.operand := NULL ;
	END IF;

	IF l_Line_Adj_rec.cost_id = FND_API.G_MISS_NUM THEN
	    l_Line_Adj_rec.cost_id := NULL ;
	END IF;

	IF l_Line_Adj_rec.tax_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.tax_code := NULL ;
	END IF;

	IF l_Line_Adj_rec.tax_exempt_flag = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.tax_exempt_flag := NULL ;
	END IF;

	IF l_Line_Adj_rec.tax_exempt_number = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.tax_exempt_number := NULL ;
	END IF;

	IF l_Line_Adj_rec.tax_exempt_reason_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.tax_exempt_reason_code := NULL ;
	END IF;

	IF l_Line_Adj_rec.parent_adjustment_id = FND_API.G_MISS_NUM THEN
	    l_Line_Adj_rec.parent_adjustment_id := NULL ;
	END IF;

	IF l_Line_Adj_rec.invoiced_flag = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.invoiced_flag := NULL ;
	END IF;

	IF l_Line_Adj_rec.estimated_flag = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.estimated_flag := NULL ;
	END IF;

	IF l_Line_Adj_rec.inc_in_sales_performance = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.inc_in_sales_performance := NULL ;
	END IF;

	IF l_Line_Adj_rec.split_action_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.split_action_code := NULL ;
	END IF;

	IF l_Line_Adj_rec.charge_type_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.charge_type_code := NULL ;
	END IF;

	IF l_Line_Adj_rec.charge_subtype_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.charge_subtype_code := NULL ;
	END IF;

	IF l_Line_Adj_rec.list_line_no = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.list_line_no := NULL ;
	END IF;

	IF l_Line_Adj_rec.source_system_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.source_system_code := NULL ;
	END IF;

	IF l_Line_Adj_rec.benefit_qty = FND_API.G_MISS_NUM THEN
	    l_Line_Adj_rec.benefit_qty := NULL ;
	END IF;

	IF l_Line_Adj_rec.benefit_uom_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.benefit_uom_code := NULL ;
	END IF;

	IF l_Line_Adj_rec.print_on_invoice_flag = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.print_on_invoice_flag := NULL ;
	END IF;

	IF l_Line_Adj_rec.expiration_date = FND_API.G_MISS_DATE THEN
	    l_Line_Adj_rec.expiration_date := NULL ;
	END IF;

	IF l_Line_Adj_rec.rebate_transaction_type_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.rebate_transaction_type_code := NULL ;
	END IF;

	IF l_Line_Adj_rec.rebate_transaction_reference = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.rebate_transaction_reference := NULL ;
	END IF;

	IF l_Line_Adj_rec.rebate_payment_system_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.rebate_payment_system_code := NULL ;
	END IF;

	IF l_Line_Adj_rec.redeemed_date = FND_API.G_MISS_DATE THEN
	    l_Line_Adj_rec.redeemed_date := NULL ;
	END IF;

	IF l_Line_Adj_rec.redeemed_flag = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.redeemed_flag := NULL ;
	END IF;

	IF l_Line_Adj_rec.accrual_flag = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.accrual_flag := NULL ;
	END IF;

	IF l_Line_Adj_rec.range_break_quantity = FND_API.G_MISS_NUM THEN
	    l_Line_Adj_rec.range_break_quantity := NULL ;
	END IF;

	IF l_Line_Adj_rec.accrual_conversion_rate = FND_API.G_MISS_NUM THEN
	    l_Line_Adj_rec.accrual_conversion_rate := NULL ;
	END IF;

	IF l_Line_Adj_rec.pricing_group_sequence = FND_API.G_MISS_NUM THEN
	    l_Line_Adj_rec.pricing_group_sequence := NULL ;
	END IF;

	IF l_Line_Adj_rec.modifier_level_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.modifier_level_code := NULL ;
	END IF;

	IF l_Line_Adj_rec.price_break_type_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.price_break_type_code := NULL ;
	END IF;

	IF l_Line_Adj_rec.substitution_attribute = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.substitution_attribute := NULL ;
	END IF;

	IF l_Line_Adj_rec.proration_type_code = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.proration_type_code := NULL ;
	END IF;

	IF l_Line_Adj_rec.credit_or_charge_flag = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.credit_or_charge_flag := NULL ;
	END IF;

	IF l_Line_Adj_rec.include_on_returns_flag = FND_API.G_MISS_CHAR THEN
	    l_Line_Adj_rec.include_on_returns_flag := NULL ;
	END IF;

    IF l_Line_Adj_rec.ac_context = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_context := NULL;
    END IF;

    IF l_Line_Adj_rec.ac_attribute1 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute1 := NULL;
    END IF;

    IF l_Line_Adj_rec.ac_attribute2 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute2 := NULL;
    END IF;

    IF l_Line_Adj_rec.ac_attribute3 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute3 := NULL;
    END IF;

    IF l_Line_Adj_rec.ac_attribute4 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute4 := NULL;
    END IF;

    IF l_Line_Adj_rec.ac_attribute5 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute5 := NULL;
    END IF;

    IF l_Line_Adj_rec.ac_attribute6 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute6 := NULL;
    END IF;

    IF l_Line_Adj_rec.ac_attribute7 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute7 := NULL;
    END IF;

    IF l_Line_Adj_rec.ac_attribute8 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute8 := NULL;
    END IF;

    IF l_Line_Adj_rec.ac_attribute9 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute9 := NULL;
    END IF;

    IF l_Line_Adj_rec.ac_attribute10 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute10 := NULL;
    END IF;

    IF l_Line_Adj_rec.ac_attribute11 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute11 := NULL;
    END IF;

    IF l_Line_Adj_rec.ac_attribute12 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute12 := NULL;
    END IF;

    IF l_Line_Adj_rec.ac_attribute13 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute13 := NULL;
    END IF;

    IF l_Line_Adj_rec.ac_attribute14 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute14 := NULL;
    END IF;

    IF l_Line_Adj_rec.ac_attribute15 = FND_API.G_MISS_CHAR THEN
        l_Line_Adj_rec.ac_attribute15 := NULL;
    END IF;

    --uom begin
    IF l_Line_Adj_rec.operand_per_pqty = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.operand_per_pqty := NULL;
    END IF;

    IF l_Line_Adj_rec.adjusted_amount_per_pqty = FND_API.G_MISS_NUM THEN
        l_Line_Adj_rec.adjusted_amount_per_pqty := NULL;
    END IF;

    --uom end

    IF l_Line_Adj_rec.invoiced_amount = FND_API.G_MISS_NUM THEN
	    l_Line_Adj_rec.invoiced_amount := NULL ;
    END IF;

    -- eBTax Changes
    IF p_x_line_adj_rec.tax_rate_id = FND_API.G_MISS_NUM  THEN
        p_x_line_adj_rec.tax_rate_id := NULL;
    END IF;


    -- end eBTax changes

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_LINE_ADJ_UTIL.CONVERT_MISS_TO_NULL' , 1 ) ;
    END IF;

    -- RETURN l_Line_Adj_rec;
    p_x_Line_Adj_rec := l_Line_Adj_rec;

END Convert_Miss_To_Null;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_Line_Adj_rec            IN OUT NOCOPY OE_Order_PUB.Line_Adj_Rec_Type
)
IS
l_lock_control		NUMBER;
l_index                 NUMBER;
l_return_status         VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING OE_LINE_ADJ_UTIL.UPDATE_ROW' , 1 ) ;
     END IF;

    -- increment lock_control by 1 whenever the record is updated
    SELECT lock_control
    INTO   l_lock_control
    FROM   OE_PRICE_ADJUSTMENTS
    WHERE  price_adjustment_id = p_Line_Adj_rec.price_adjustment_id;

    l_lock_control := l_lock_control + 1;

   --calling notification framework to update global picture
   --check code release level first. Notification framework is at Pack H level
   IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'JFC: LINE_PRICE_ADJ_ID=' || P_LINE_ADJ_REC.PRICE_ADJUSTMENT_ID ) ;
        END IF;
       OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_Line_adj_rec =>p_line_adj_rec,
                    p_line_adj_id => p_line_adj_rec.price_adjustment_id,
                    x_index => l_index,
                    x_return_status => l_return_status);
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_LINE_ADJ_UTIL.UPDATE_ROW IS: ' || L_RETURN_STATUS ) ;
         END IF;
         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
                 oe_debug_pub.add(  'EXITING OE_LINE_ADJ_UTIL.UPDATE_ROW' , 1 ) ;
             END IF;
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_LINE_ADJ_UTIL.UPDATE_ROW' ) ;
                oe_debug_pub.add(  'EXITING OE_LINE_ADJ_UTIL.UPDATE_ROW' , 1 ) ;
            END IF;
	    RAISE FND_API.G_EXC_ERROR;
          END IF;
    END IF; /* code_release_level*/
     -- notification framework end

    UPDATE  OE_PRICE_ADJUSTMENTS
    SET     PRICE_ADJUSTMENT_ID    = p_Line_Adj_rec.price_adjustment_id
    ,       CREATION_DATE          = p_Line_Adj_rec.creation_date
    ,       CREATED_BY             = p_Line_Adj_rec.created_by
    ,       LAST_UPDATE_DATE       = p_Line_Adj_rec.last_update_date
    ,       LAST_UPDATED_BY        = p_Line_Adj_rec.last_updated_by
    ,       LAST_UPDATE_LOGIN      = p_Line_Adj_rec.last_update_login
    ,       PROGRAM_APPLICATION_ID = p_Line_Adj_rec.program_application_id
    ,       PROGRAM_ID             = p_Line_Adj_rec.program_id
    ,       PROGRAM_UPDATE_DATE    = p_Line_Adj_rec.program_update_date
    ,       REQUEST_ID             = p_Line_Adj_rec.request_id
    ,       HEADER_ID              = p_Line_Adj_rec.header_id
    ,       DISCOUNT_ID            = p_Line_Adj_rec.discount_id
    ,       DISCOUNT_LINE_ID       = p_Line_Adj_rec.discount_line_id
    ,       AUTOMATIC_FLAG         = p_Line_Adj_rec.automatic_flag
    ,       PERCENT                = p_Line_Adj_rec.percent
    ,       LINE_ID                = p_Line_Adj_rec.line_id
    ,       CONTEXT                = p_Line_Adj_rec.context
    ,       ATTRIBUTE1             = p_Line_Adj_rec.attribute1
    ,       ATTRIBUTE2             = p_Line_Adj_rec.attribute2
    ,       ATTRIBUTE3             = p_Line_Adj_rec.attribute3
    ,       ATTRIBUTE4             = p_Line_Adj_rec.attribute4
    ,       ATTRIBUTE5             = p_Line_Adj_rec.attribute5
    ,       ATTRIBUTE6             = p_Line_Adj_rec.attribute6
    ,       ATTRIBUTE7             = p_Line_Adj_rec.attribute7
    ,       ATTRIBUTE8             = p_Line_Adj_rec.attribute8
    ,       ATTRIBUTE9             = p_Line_Adj_rec.attribute9
    ,       ATTRIBUTE10            = p_Line_Adj_rec.attribute10
    ,       ATTRIBUTE11            = p_Line_Adj_rec.attribute11
    ,       ATTRIBUTE12            = p_Line_Adj_rec.attribute12
    ,       ATTRIBUTE13            = p_Line_Adj_rec.attribute13
    ,       ATTRIBUTE14            = p_Line_Adj_rec.attribute14
    ,       ATTRIBUTE15            = p_Line_Adj_rec.attribute15
    ,       ORIG_SYS_DISCOUNT_REF  = p_Line_Adj_rec.orig_sys_discount_ref
    ,	  LIST_HEADER_ID  	     = p_Line_Adj_rec.list_header_id
    ,	  LIST_LINE_ID  	     = p_Line_Adj_rec.list_line_id
    ,	  LIST_LINE_TYPE_CODE  	    =  p_Line_Adj_rec.list_line_type_code
 , MODIFIER_MECHANISM_TYPE_CODE = p_Line_Adj_rec.modifier_mechanism_type_code
    ,	  MODIFIED_FROM   	     = p_Line_Adj_rec.modified_from
    ,	  MODIFIED_TO  	     = p_Line_Adj_rec.modified_to
    ,	  UPDATED_FLAG  	     = p_Line_Adj_rec.updated_flag
    ,	  UPDATE_ALLOWED  	     = p_Line_Adj_rec.update_allowed
    ,	  APPLIED_FLAG  	     = p_Line_Adj_rec.applied_flag
    ,	  CHANGE_REASON_CODE  	 =     p_Line_Adj_rec.change_reason_code
    ,	  CHANGE_REASON_TEXT  	  =    p_Line_Adj_rec.change_reason_text
    ,	  operand				=  p_Line_Adj_rec.operand
    ,	  Arithmetic_operator	=	p_Line_Adj_rec.arithmetic_operator
    ,	  COST_ID                = p_Line_Adj_rec.cost_id
    ,	  TAX_CODE               = p_Line_Adj_rec.tax_code
    ,	  TAX_EXEMPT_FLAG        = p_Line_Adj_rec.tax_exempt_flag
    ,	  TAX_EXEMPT_NUMBER      = p_Line_Adj_rec.tax_exempt_number
    ,	  TAX_EXEMPT_REASON_CODE = p_Line_Adj_rec.tax_exempt_reason_code
    ,	  PARENT_ADJUSTMENT_ID   = p_Line_Adj_rec.parent_adjustment_id
    ,	  INVOICED_FLAG          = p_Line_Adj_rec.invoiced_flag
    ,	  ESTIMATED_FLAG         = p_Line_Adj_rec.estimated_flag
    ,	  INC_IN_SALES_PERFORMANCE = p_Line_Adj_rec.inc_in_sales_performance
    ,	  SPLIT_ACTION_CODE      = p_Line_Adj_rec.split_action_code
    ,	  ADJUSTED_AMOUNT      = p_Line_Adj_rec.adjusted_amount
    ,	  PRICING_PHASE_ID      = p_Line_Adj_rec.pricing_phase_id
    ,	  CHARGE_TYPE_CODE      = p_Line_Adj_rec.charge_type_code
    ,	  CHARGE_SUBTYPE_CODE      = p_Line_Adj_rec.charge_subtype_code
    ,     LIST_LINE_NO          = p_Line_Adj_rec.list_line_no
    ,     SOURCE_SYSTEM_CODE     = p_Line_Adj_rec.source_system_code
    ,     BENEFIT_QTY           = p_Line_Adj_rec.benefit_qty
    ,     BENEFIT_UOM_CODE      = p_Line_Adj_rec.benefit_uom_code
    ,     PRINT_ON_INVOICE_FLAG = p_Line_Adj_rec.print_on_invoice_flag
    ,     EXPIRATION_DATE       = p_Line_Adj_rec.expiration_date
    ,     REBATE_TRANSACTION_TYPE_CODE  = p_Line_Adj_rec.rebate_transaction_type_code
    ,     REBATE_TRANSACTION_REFERENCE  = p_Line_Adj_rec.rebate_transaction_reference
    ,     REBATE_PAYMENT_SYSTEM_CODE    = p_Line_Adj_rec.rebate_payment_system_code
    ,     REDEEMED_DATE         = p_Line_Adj_rec.redeemed_date
    ,     REDEEMED_FLAG         = p_Line_Adj_rec.redeemed_flag
    ,     ACCRUAL_FLAG         = p_Line_Adj_rec.accrual_flag
    ,     range_break_quantity      = p_Line_Adj_rec.range_break_quantity
    ,     accrual_conversion_rate   = p_Line_Adj_rec.accrual_conversion_rate
    ,     pricing_group_sequence    = p_Line_Adj_rec.pricing_group_sequence
    ,     modifier_level_code       = p_Line_Adj_rec.modifier_level_code
    ,     price_break_type_code     = p_Line_Adj_rec.price_break_type_code
    ,     substitution_attribute    = p_Line_Adj_rec.substitution_attribute
    ,     proration_type_code       = p_Line_Adj_rec.proration_type_code
    ,       CREDIT_OR_CHARGE_FLAG   = p_Line_Adj_rec.credit_or_charge_flag
    ,       INCLUDE_ON_RETURNS_FLAG = p_Line_Adj_rec.include_on_returns_flag
    ,       AC_CONTEXT              = p_Line_Adj_rec.ac_context
    ,       AC_ATTRIBUTE1           = p_Line_Adj_rec.ac_attribute1
    ,       AC_ATTRIBUTE2           = p_Line_Adj_rec.ac_attribute2
    ,       AC_ATTRIBUTE3           = p_Line_Adj_rec.ac_attribute3
    ,       AC_ATTRIBUTE4           = p_Line_Adj_rec.ac_attribute4
    ,       AC_ATTRIBUTE5           = p_Line_Adj_rec.ac_attribute5
    ,       AC_ATTRIBUTE6           = p_Line_Adj_rec.ac_attribute6
    ,       AC_ATTRIBUTE7           = p_Line_Adj_rec.ac_attribute7
    ,       AC_ATTRIBUTE8           = p_Line_Adj_rec.ac_attribute8
    ,       AC_ATTRIBUTE9           = p_Line_Adj_rec.ac_attribute9
    ,       AC_ATTRIBUTE10          = p_Line_Adj_rec.ac_attribute10
    ,       AC_ATTRIBUTE11          = p_Line_Adj_rec.ac_attribute11
    ,       AC_ATTRIBUTE12          = p_Line_Adj_rec.ac_attribute12
    ,       AC_ATTRIBUTE13          = p_Line_Adj_rec.ac_attribute13
    ,       AC_ATTRIBUTE14          = p_Line_Adj_rec.ac_attribute14
    ,       AC_ATTRIBUTE15          = p_Line_Adj_rec.ac_attribute15
    ,	  LOCK_CONTROL			 = l_lock_control
     --uom begin
    ,       OPERAND_PER_PQTY        = p_line_adj_rec.operand_per_pqty
    ,       ADJUSTED_AMOUNT_PER_PQTY = p_line_adj_rec.adjusted_amount_per_pqty
    --uom end
    ,	  INVOICED_AMOUNT           = p_Line_Adj_rec.invoiced_amount
    -- eBTax changes
    ,     TAX_RATE_ID               = p_Line_Adj_rec.tax_rate_id

    WHERE   PRICE_ADJUSTMENT_ID    = p_Line_Adj_rec.price_adjustment_id
    ;

    p_Line_Adj_rec.lock_control := l_lock_control;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_LINE_ADJ_UTIL.UPDATE_ROW.' , 1 ) ;
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
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'EXCEPTION IN UPDATE_ROW'||SQLERRM , 2 ) ;
       END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Row;

--To prevent unique key violation on price_adjustment_table next time
Procedure Reset_Sequence Is
h number;
i number;
k number;
j number;
l number;
begin
  select max(price_adjustment_id)
  into j
  from  oe_price_adjustments;

  Select oe_price_adjustments_s.nextval
  Into h
  From dual;

  If j > h and j <> fnd_api.g_miss_num Then
    l:=j-h+10;
    for i in 1..l loop
      select oe_price_adjustments_s.nextval into k from dual;
    end loop;
  End If;

end;

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_Line_Adj_rec            IN OUT NOCOPY  OE_Order_PUB.Line_Adj_Rec_Type
)
IS
l_lock_control		NUMBER := 1;
l_index                 NUMBER;
l_return_status         VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_LINE_ADJ_UTIL.INSERT_ROW' , 1 ) ;
        oe_debug_pub.add(' list_line_id insert:'|| p_Line_Adj_rec.list_line_id||
                         ' ,operand insert:'||p_line_adj_rec.operand||
                         ' ,operand pqty insert:'||p_line_adj_rec.operand_per_pqty||
                         ' ,applied_flag insert:'||p_line_adj_rec.applied_flag||
                         ' ,list_line_type_code:'||p_line_adj_rec.list_line_type_code||
                         ' ,operator:'||p_line_adj_rec.arithmetic_operator);
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
    ,	  Arithmetic_operator
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
    --RETRO{
    , retrobill_request_id
    --RETRO}
    ,	  INVOICED_AMOUNT
    ,	  LOCK_CONTROL
    -- eBTax Changes
    ,     TAX_RATE_ID
    )
    VALUES
    (       p_Line_Adj_rec.price_adjustment_id
    ,       p_Line_Adj_rec.creation_date
    ,       p_Line_Adj_rec.created_by
    ,       p_Line_Adj_rec.last_update_date
    ,       p_Line_Adj_rec.last_updated_by
    ,       p_Line_Adj_rec.last_update_login
    ,       p_Line_Adj_rec.program_application_id
    ,       p_Line_Adj_rec.program_id
    ,       p_Line_Adj_rec.program_update_date
    ,       p_Line_Adj_rec.request_id
    ,       p_Line_Adj_rec.header_id
    ,       p_Line_Adj_rec.discount_id
    ,       p_Line_Adj_rec.discount_line_id
    ,       p_Line_Adj_rec.automatic_flag
    ,       p_Line_Adj_rec.percent
    ,       p_Line_Adj_rec.line_id
    ,       p_Line_Adj_rec.context
    ,       p_Line_Adj_rec.attribute1
    ,       p_Line_Adj_rec.attribute2
    ,       p_Line_Adj_rec.attribute3
    ,       p_Line_Adj_rec.attribute4
    ,       p_Line_Adj_rec.attribute5
    ,       p_Line_Adj_rec.attribute6
    ,       p_Line_Adj_rec.attribute7
    ,       p_Line_Adj_rec.attribute8
    ,       p_Line_Adj_rec.attribute9
    ,       p_Line_Adj_rec.attribute10
    ,       p_Line_Adj_rec.attribute11
    ,       p_Line_Adj_rec.attribute12
    ,       p_Line_Adj_rec.attribute13
    ,       p_Line_Adj_rec.attribute14
    ,       p_Line_Adj_rec.attribute15
    ,       p_Line_Adj_rec.orig_sys_discount_ref
    ,	  p_Line_Adj_rec.LIST_HEADER_ID
    ,	  p_Line_Adj_rec.LIST_LINE_ID
    ,	  p_Line_Adj_rec.LIST_LINE_TYPE_CODE
    ,	  p_Line_Adj_rec.MODIFIER_MECHANISM_TYPE_CODE
    ,	  p_Line_Adj_rec.MODIFIED_FROM
    ,	  p_Line_Adj_rec.MODIFIED_TO
    ,	  p_Line_Adj_rec.UPDATED_FLAG
    ,	  p_Line_Adj_rec.UPDATE_ALLOWED
    ,	  p_Line_Adj_rec.APPLIED_FLAG
    ,	  p_Line_Adj_rec.CHANGE_REASON_CODE
    ,	  p_Line_Adj_rec.CHANGE_REASON_TEXT
    ,	  p_Line_Adj_rec.operand
    ,	  p_Line_Adj_rec.arithmetic_operator
    ,	  p_line_Adj_rec.COST_ID
    ,	  p_line_Adj_rec.TAX_CODE
    ,	  p_line_Adj_rec.TAX_EXEMPT_FLAG
    ,	  p_line_Adj_rec.TAX_EXEMPT_NUMBER
    ,	  p_line_Adj_rec.TAX_EXEMPT_REASON_CODE
    ,	  p_line_Adj_rec.PARENT_ADJUSTMENT_ID
    ,	  p_line_Adj_rec.INVOICED_FLAG
    ,	  p_line_Adj_rec.ESTIMATED_FLAG
    ,	  p_line_Adj_rec.INC_IN_SALES_PERFORMANCE
    ,	  p_line_Adj_rec.SPLIT_ACTION_CODE
    ,	  p_line_Adj_rec.ADJUSTED_AMOUNT
    ,	  p_line_Adj_rec.PRICING_PHASE_ID
    ,	  p_line_Adj_rec.CHARGE_TYPE_CODE
    ,	  p_line_Adj_rec.CHARGE_SUBTYPE_CODE
    ,       p_Line_Adj_rec.list_line_no
    ,       p_Line_Adj_rec.source_system_code
    ,       p_Line_Adj_rec.benefit_qty
    ,       p_Line_Adj_rec.benefit_uom_code
    ,       p_Line_Adj_rec.print_on_invoice_flag
    ,       p_Line_Adj_rec.expiration_date
    ,       p_Line_Adj_rec.rebate_transaction_type_code
    ,       p_Line_Adj_rec.rebate_transaction_reference
    ,       p_Line_Adj_rec.rebate_payment_system_code
    ,       p_Line_Adj_rec.redeemed_date
    ,       p_Line_Adj_rec.redeemed_flag
    ,       p_Line_Adj_rec.accrual_flag
    ,       p_Line_Adj_rec.range_break_quantity
    ,       p_Line_Adj_rec.accrual_conversion_rate
    ,       p_Line_Adj_rec.pricing_group_sequence
    ,       p_Line_Adj_rec.modifier_level_code
    ,       p_Line_Adj_rec.price_break_type_code
    ,       p_Line_Adj_rec.substitution_attribute
    ,       p_Line_Adj_rec.proration_type_code
    ,       p_Line_Adj_rec.credit_or_charge_flag
    ,       p_Line_Adj_rec.include_on_returns_flag
    ,       p_Line_Adj_rec.ac_context
    ,       p_Line_Adj_rec.ac_attribute1
    ,       p_Line_Adj_rec.ac_attribute2
    ,       p_Line_Adj_rec.ac_attribute3
    ,       p_Line_Adj_rec.ac_attribute4
    ,       p_Line_Adj_rec.ac_attribute5
    ,       p_Line_Adj_rec.ac_attribute6
    ,       p_Line_Adj_rec.ac_attribute7
    ,       p_Line_Adj_rec.ac_attribute8
    ,       p_Line_Adj_rec.ac_attribute9
    ,       p_Line_Adj_rec.ac_attribute10
    ,       p_Line_Adj_rec.ac_attribute11
    ,       p_Line_Adj_rec.ac_attribute12
    ,       p_Line_Adj_rec.ac_attribute13
    ,       p_Line_Adj_rec.ac_attribute14
    ,       p_Line_Adj_rec.ac_attribute15
    --uom begin
    ,       p_line_adj_rec.OPERAND_PER_PQTY
    ,       p_line_adj_rec.ADJUSTED_AMOUNT_PER_PQTY
    --uom end
    --RETRO{
    ,       p_line_adj_rec.retrobill_request_id
    --RETRO}
    ,	    p_line_Adj_rec.INVOICED_AMOUNT
    ,       l_lock_control
    -- eBTax changes
    ,      p_line_adj_rec.tax_rate_id
    );

    p_Line_Adj_rec.lock_control := l_lock_control;

   --calling notification framework to update_global picture
   --check code release level first. Notification framework is at Pack H level
   IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
      OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_old_line_adj_rec => NULL,
                    p_line_adj_rec =>p_line_adj_rec,
                    p_line_adj_id => p_line_adj_rec.price_adjustment_id,
                    x_index => l_index,
                    x_return_status => l_return_status);
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_LINE_ADJ_UTIL.INSERT_RO IS: ' || L_RETURN_STATUS ) ;
           oe_debug_pub.add(  'RETURNED INDEX IS: ' || L_INDEX , 1 ) ;
       END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
               oe_debug_pub.add(  'EXITING OE_LINE_ADJ_UTIL.INSERT_ROW' , 1 ) ;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_LINE_ADJ_UTIL.INSERT_ROW' ) ;
                oe_debug_pub.add(  'EXITINGOE_LINE_ADJ_UTIL.INSERT_ROW' , 1 ) ;
            END IF;
	    RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF; /*code_release_level*/
    -- notification framework end

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_LINE_ADJ_UTIL.INSERT_ROW.' , 1 ) ;
    END IF;

EXCEPTION

    WHEN DUP_VAL_ON_INDEX Then
      Reset_Sequence;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  G_PKG_NAME||':INSER_ROW:'||SQLERRM ) ;
      END IF;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        --FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Insert_Row:'||SQLERRM);

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  G_PKG_NAME||':INSER_ROW:'||SQLERRM ) ;
        END IF;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Insert_Row'
            );
        END IF;

        --FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,'Insert_Row:'||SQLERRM);

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_price_adjustment_id           IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_line_id                       IN  NUMBER :=
                                        FND_API.G_MISS_NUM
)
IS
l_return_status		VARCHAR2(30);
CURSOR price_adj IS
	SELECT price_adjustment_id
	FROM OE_PRICE_ADJUSTMENTS
	WHERE   LINE_ID = p_line_id;

-- added for notification framework
l_new_line_adj_rec     OE_Order_PUB.Line_Adj_Rec_Type;
l_index    NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_LINE_ADJ_UTIL.DELETE_ROW' ) ;
  END IF;
  IF p_line_id <> FND_API.G_MISS_NUM
  THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' P_LINE_ID <> G_MISS_NUM' ) ;
    END IF;
    FOR l_adj IN price_adj LOOP

   --added for notification framework
   --check code release level first. Notification framework is at Pack H level
      IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'JFC: IN DELETE ROW , PRICE_ADJUSTMENT_ID'||L_ADJ.PRICE_ADJUSTMENT_ID , 1 ) ;
           END IF;
      /* Set the operation on the record so that globals are updated as well */
        l_new_line_adj_rec.operation := OE_GLOBALS.G_OPR_DELETE;
        l_new_line_adj_rec.price_adjustment_id := l_adj.price_adjustment_id;
         OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_line_adj_rec =>l_new_line_adj_rec,
                    p_line_adj_id => l_adj.price_adjustment_id,
                    x_index => l_index,
                    x_return_status => l_return_status);
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_LINE_ADJ_UTIL.DELETE_ROW IS: ' || L_RETURN_STATUS ) ;
            END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
               oe_debug_pub.add(  'EXITING OE_LINE_ADJ_UTIL.DELETE_ROW' , 1 ) ;
           END IF;
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_LINE_ADJ_UTIL.DELETE_ROW' ) ;
               oe_debug_pub.add(  'EXITING OE_LINE_ADJ_UTIL.DELETE_ROW' , 1 ) ;
           END IF;
       	RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF; /*code_release_level*/
  -- end notification framework

      OE_Delayed_Requests_Pvt.Delete_Reqs_for_deleted_entity(
        p_entity_code  => OE_GLOBALS.G_ENTITY_LINE_ADJ,
        p_entity_id     => l_adj.price_adjustment_id,
        x_return_status => l_return_status
        );
	  OE_Line_Price_Aattr_Util.delete_row(
			p_price_adjustment_id=>l_adj.price_adjustment_id);

       -- fixed bug 1658300
	  /***
	  OE_Line_Adj_Assocs_Util.delete_row(
			p_price_adjustment_id=>l_adj.price_adjustment_id);
	  ***/

    END LOOP;
    DELETE  FROM OE_PRICE_ADJUSTMENTS
    WHERE   LINE_ID = p_line_id;
  ELSE
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  ' P_LINE_ID = G_MISS_NUM' ) ;
     END IF;

    --added for notification framework
   --check code release level first. Notification framework is at Pack H level
     IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110508' THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'JFC: IN DELETE ROW , LINE_ID IS G_MISS_NUM , PRICE_ADJUSTMENT_ID'||P_PRICE_ADJUSTMENT_ID , 1 ) ;
         END IF;
      /* Set the operation on the record so that globals are updated as well */
       l_new_line_adj_rec.operation := OE_GLOBALS.G_OPR_DELETE;
       l_new_line_adj_rec.price_adjustment_id := p_price_adjustment_id;
          OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_line_adj_rec =>l_new_line_adj_rec,
                    p_line_adj_id => p_price_adjustment_id,
                    x_index => l_index,
                    x_return_status => l_return_status);
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'UPDATE_GLOBAL RETURN STATUS FROM OE_LINE_ADJ_UTIL.DELETE_ROW IS: ' || L_RETURN_STATUS ) ;
          END IF;
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EVENT NOTIFY - UNEXPECTED ERROR' ) ;
              oe_debug_pub.add(  'EXITING OE_LINE_ADJ_UTIL.DELETE_ROW' , 1 ) ;
          END IF;
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'UPDATE_GLOBAL_PICTURE ERROR IN OE_LINE_ADJ_UTIL.DELETE_ROW' ) ;
              oe_debug_pub.add(  'EXITING OE_LINE_ADJ_UTIL.DELETE_ROW' , 1 ) ;
          END IF;
      	RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;  /*code_release_level*/
  -- end notification framework

      OE_Delayed_Requests_Pvt.Delete_Reqs_for_deleted_entity
        (p_entity_code  => OE_GLOBALS.G_ENTITY_LINE_ADJ,
        p_entity_id     => p_price_adjustment_id,
        x_return_status => l_return_status
        );

	  OE_Line_Price_Aattr_Util.delete_row(
			p_price_adjustment_id=>p_price_adjustment_id);

       -- fixed bug 1658300
	  /***
	  OE_Line_Adj_Assocs_Util.delete_row(
			p_price_adjustment_id=>p_price_adjustment_id);
       ***/

--bug3528335 moving the following DELETE statement before deletion of the parent and checking for PBH.
    --bug3405372 deleting the child lines of PBH modifiers as well
    DELETE FROM OE_PRICE_ADJUSTMENTS
    WHERE PRICE_ADJUSTMENT_ID IN (SELECT RLTD_PRICE_ADJ_ID
				  FROM OE_PRICE_ADJ_ASSOCS ASSOCS,
				       OE_PRICE_ADJUSTMENTS PARENT
				  WHERE ASSOCS.PRICE_ADJUSTMENT_ID=PARENT.PRICE_ADJUSTMENT_ID
				  AND PARENT.PRICE_ADJUSTMENT_ID=p_price_adjustment_id
				  AND PARENT.LIST_LINE_TYPE_CODE='PBH');
    IF l_debug_level > 0 THEN
       oe_debug_pub.add('pviprana: Deleted '|| SQL%ROWCOUNT || ' Child Lines');
    END IF;
    --bug3528335 end



    DELETE  FROM OE_PRICE_ADJUSTMENTS
    WHERE   PRICE_ADJUSTMENT_ID = p_price_adjustment_id;

  END IF;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'LEAVING OE_LINE_ADJ_UTIL.DELETE_ROW' ) ;
END IF;
EXCEPTION

    WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  G_PKG_NAME||':DELETE_ROW:'||SQLERRM ) ;
        END IF;
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
,   x_Line_Adj_Rec 			IN OUT NOCOPY OE_Order_PUB.Line_Adj_Rec_Type
)
IS
  l_Line_Adj_Tbl		OE_Order_PUB.Line_Adj_Tbl_Type;
BEGIN

    Query_Rows
        (   p_price_adjustment_id        => p_price_adjustment_id
	   ,   x_Line_Adj_Tbl			 => l_Line_Adj_Tbl
	   );
    x_Line_Adj_Rec := l_Line_Adj_Tbl(1);

END Query_Row;

--  Procedure Query_Rows

PROCEDURE Query_Rows
(   p_price_adjustment_id           IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_line_id                       IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_Header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_Line_Level_Header_id          IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_Line_Adj_Tbl 		           IN OUT NOCOPY OE_Order_PUB.Line_Adj_Tbl_Type
)
IS
l_count			NUMBER;

CURSOR l_Line_Adj_csr IS
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
    ,	  Arithmetic_operator
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
    ,       credit_or_charge_flag
    ,       include_on_returns_flag
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
--uom begin
    ,     OPERAND_PER_PQTY
    ,     ADJUSTED_AMOUNT_PER_PQTY
--uom end
    ,	  INVOICED_AMOUNT
    ,	  orig_sys_discount_ref
    --RETRO{
    , retrobill_request_id
    --RETRO}
    ,	  LOCK_CONTROL
    -- eBTax changes
    ,     TAX_RATE_ID
    FROM  OE_PRICE_ADJUSTMENTS
    WHERE PRICE_ADJUSTMENT_ID = p_price_adjustment_id;

CURSOR l_Line_Adj_csr2 IS
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
    ,	  Arithmetic_operator
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
    ,       credit_or_charge_flag
    ,       include_on_returns_flag
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
--uom begin
    ,     OPERAND_PER_PQTY
    ,     ADJUSTED_AMOUNT_PER_PQTY
--uom end
    ,	  INVOICED_AMOUNT
    ,	  orig_sys_discount_ref
    --RETRO{
    , retrobill_request_id
    --RETRO}
    ,	  LOCK_CONTROL
  -- eBTax changes
    ,     TAX_RATE_ID
    FROM    OE_PRICE_ADJUSTMENTS
    WHERE line_id = p_line_id;

CURSOR l_Line_Adj_csr3 IS
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
    ,	  Arithmetic_operator
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
    ,       credit_or_charge_flag
    ,       include_on_returns_flag
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
--uom begin
    ,     OPERAND_PER_PQTY
    ,     ADJUSTED_AMOUNT_PER_PQTY
--uom end
    ,	  INVOICED_AMOUNT
    ,	  orig_sys_discount_ref
    --RETRO{
    , retrobill_request_id
    --RETRO}
    ,	  LOCK_CONTROL
        -- eBTax changes
    ,     TAX_RATE_ID
    FROM    OE_PRICE_ADJUSTMENTS
    WHERE header_id = p_header_id
    and   line_id is null;

--Line-level adjustments based on header_id
CURSOR l_Line_Adj_csr4 IS
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
    ,	  Arithmetic_operator
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
    ,       credit_or_charge_flag
    ,       include_on_returns_flag
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
--uom begin
    ,     OPERAND_PER_PQTY
    ,     ADJUSTED_AMOUNT_PER_PQTY
--uom end
    ,	  INVOICED_AMOUNT
    ,	  orig_sys_discount_ref
    --RETRO{
    , retrobill_request_id
    --RETRO}
    ,	  LOCK_CONTROL
 -- eBTax changes
    ,     TAX_RATE_ID
    FROM    OE_PRICE_ADJUSTMENTS
    WHERE header_id = p_line_level_header_id
    and   line_id is not null;

    l_implicit_rec l_line_adj_csr%ROWTYPE;
    l_entity                        NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF
    (p_price_adjustment_id IS NOT NULL
     AND
     p_price_adjustment_id <> FND_API.G_MISS_NUM)
    AND
    (p_line_id IS NOT NULL
     AND
     p_line_id <> FND_API.G_MISS_NUM)
    THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Query Rows'
                ,   'Keys are mutually exclusive: price_adjustment_id = '|| p_price_adjustment_id || ', line_id = '|| p_line_id
                );
            END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    IF nvl(p_price_adjustment_id,-1) <> FND_API.G_MISS_NUM THEN
	   l_entity := 1;
           OPEN l_line_adj_csr;
    ELSIF nvl(p_line_id,-1) <> FND_API.G_MISS_NUM THEN
	   l_entity := 2;
           OPEN l_line_adj_csr2;
    ELSIF nvl(p_header_id,-1) <> FND_API.G_MISS_NUM THEN
	   l_entity := 3;
           OPEN l_line_adj_csr3;
    ELSIF nvl(p_line_level_header_id,-1) <> FND_API.G_MISS_NUM THEN
	   l_entity := 4;
           OPEN l_line_adj_csr4;
    END IF;

    l_count := 1;

    --  Loop over fetched records
    LOOP

        IF l_entity = 1 THEN
             FETCH l_line_adj_csr INTO l_implicit_rec;
             EXIT WHEN l_line_adj_csr%NOTFOUND;
        ELSIF l_entity = 2 THEN
             FETCH l_line_adj_csr2 INTO l_implicit_rec;
             EXIT WHEN l_line_adj_csr2%NOTFOUND;
        ELSIF l_entity = 3 THEN
             FETCH l_line_adj_csr3 INTO l_implicit_rec;
             EXIT WHEN l_line_adj_csr3%NOTFOUND;
	--bug3392650 (the condition l_entity=3 was being checked twice)
        ELSIF l_entity = 4 THEN
             FETCH l_line_adj_csr4 INTO l_implicit_rec;
             EXIT WHEN l_line_adj_csr4%NOTFOUND;
        ELSE
          EXIT;
        END IF;

        x_Line_Adj_tbl(l_count).attribute1      := l_implicit_rec.ATTRIBUTE1;
        x_Line_Adj_tbl(l_count).attribute10     := l_implicit_rec.ATTRIBUTE10;
        x_Line_Adj_tbl(l_count).attribute11     := l_implicit_rec.ATTRIBUTE11;
        x_Line_Adj_tbl(l_count).attribute12     := l_implicit_rec.ATTRIBUTE12;
        x_Line_Adj_tbl(l_count).attribute13     := l_implicit_rec.ATTRIBUTE13;
        x_Line_Adj_tbl(l_count).attribute14     := l_implicit_rec.ATTRIBUTE14;
        x_Line_Adj_tbl(l_count).attribute15     := l_implicit_rec.ATTRIBUTE15;
        x_Line_Adj_tbl(l_count).attribute2      := l_implicit_rec.ATTRIBUTE2;
        x_Line_Adj_tbl(l_count).attribute3      := l_implicit_rec.ATTRIBUTE3;
        x_Line_Adj_tbl(l_count).attribute4      := l_implicit_rec.ATTRIBUTE4;
        x_Line_Adj_tbl(l_count).attribute5      := l_implicit_rec.ATTRIBUTE5;
        x_Line_Adj_tbl(l_count).attribute6      := l_implicit_rec.ATTRIBUTE6;
        x_Line_Adj_tbl(l_count).attribute7      := l_implicit_rec.ATTRIBUTE7;
        x_Line_Adj_tbl(l_count).attribute8      := l_implicit_rec.ATTRIBUTE8;
        x_Line_Adj_tbl(l_count).attribute9      := l_implicit_rec.ATTRIBUTE9;
        x_Line_Adj_tbl(l_count).automatic_flag  := l_implicit_rec.AUTOMATIC_FLAG;
        x_Line_Adj_tbl(l_count).context         := l_implicit_rec.CONTEXT;
        x_Line_Adj_tbl(l_count).created_by      := l_implicit_rec.CREATED_BY;
        x_Line_Adj_tbl(l_count).creation_date   := l_implicit_rec.CREATION_DATE;
        x_Line_Adj_tbl(l_count).discount_id     := l_implicit_rec.DISCOUNT_ID;
        x_Line_Adj_tbl(l_count).discount_line_id := l_implicit_rec.DISCOUNT_LINE_ID;
        x_Line_Adj_tbl(l_count).header_id       := l_implicit_rec.HEADER_ID;
        x_Line_Adj_tbl(l_count).last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        x_Line_Adj_tbl(l_count).last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        x_Line_Adj_tbl(l_count).last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        x_Line_Adj_tbl(l_count).line_id         := l_implicit_rec.LINE_ID;
        x_Line_Adj_tbl(l_count).percent         := l_implicit_rec.PERCENT;
        x_Line_Adj_tbl(l_count).price_adjustment_id := l_implicit_rec.PRICE_ADJUSTMENT_ID;
        x_Line_Adj_tbl(l_count).program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        x_Line_Adj_tbl(l_count).program_id      := l_implicit_rec.PROGRAM_ID;
        x_Line_Adj_tbl(l_count).program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        x_Line_Adj_tbl(l_count).request_id      := l_implicit_rec.REQUEST_ID;
        x_Line_Adj_tbl(l_count).list_header_id      := l_implicit_rec.list_header_id;
        x_Line_Adj_tbl(l_count).list_line_id      := l_implicit_rec.list_line_id;
        x_Line_Adj_tbl(l_count).list_line_type_code      := l_implicit_rec.list_line_type_code;
        x_Line_Adj_tbl(l_count).modifier_mechanism_type_code := l_implicit_rec.modifier_mechanism_type_code;
      x_Line_Adj_tbl(l_count).modified_from      := l_implicit_rec.modified_from;
      x_Line_Adj_tbl(l_count).modified_to      := l_implicit_rec.modified_to;
      x_Line_Adj_tbl(l_count).updated_flag      := l_implicit_rec.updated_flag;
      x_Line_Adj_tbl(l_count).update_allowed    := l_implicit_rec.update_allowed;
      x_Line_Adj_tbl(l_count).applied_flag      := l_implicit_rec.applied_flag;
      x_Line_Adj_tbl(l_count).change_reason_code := l_implicit_rec.change_reason_code;
      x_Line_Adj_tbl(l_count).change_reason_text := l_implicit_rec.change_reason_text;
      x_Line_Adj_tbl(l_count).operand := l_implicit_rec.operand;
      x_Line_Adj_tbl(l_count).arithmetic_operator := l_implicit_rec.arithmetic_operator;
        x_Line_Adj_tbl(l_count).adjusted_amount := l_implicit_rec.adjusted_amount;
        x_Line_Adj_tbl(l_count).pricing_phase_id := l_implicit_rec.pricing_phase_id;
        x_Line_Adj_tbl(l_count).cost_id := l_implicit_rec.cost_id;
        x_Line_Adj_tbl(l_count).tax_code := l_implicit_rec.tax_code;
        x_Line_Adj_tbl(l_count).tax_exempt_flag := l_implicit_rec.tax_exempt_flag;
        x_Line_Adj_tbl(l_count).tax_exempt_number := l_implicit_rec.tax_exempt_number;
        x_Line_Adj_tbl(l_count).tax_exempt_reason_code := l_implicit_rec.tax_exempt_reason_code;
        x_Line_Adj_tbl(l_count).parent_adjustment_id := l_implicit_rec.parent_adjustment_id;
        x_Line_Adj_tbl(l_count).invoiced_flag := l_implicit_rec.invoiced_flag;
        x_Line_Adj_tbl(l_count).estimated_flag := l_implicit_rec.estimated_flag;
        x_Line_Adj_tbl(l_count).inc_in_sales_performance := l_implicit_rec.inc_in_sales_performance;
        x_Line_Adj_tbl(l_count).split_action_code := l_implicit_rec.split_action_code;
        x_Line_Adj_tbl(l_count).charge_type_code := l_implicit_rec.charge_type_code;
        x_Line_Adj_tbl(l_count).charge_subtype_code := l_implicit_rec.charge_subtype_code;
        x_Line_Adj_tbl(l_count).list_line_no := l_implicit_rec.list_line_no;
        x_Line_Adj_tbl(l_count).source_system_code := l_implicit_rec.source_system_code;
        x_Line_Adj_tbl(l_count).benefit_qty := l_implicit_rec.benefit_qty;
        x_Line_Adj_tbl(l_count).benefit_uom_code := l_implicit_rec.benefit_uom_code;
        x_Line_Adj_tbl(l_count).print_on_invoice_flag := l_implicit_rec.print_on_invoice_flag;
        x_Line_Adj_tbl(l_count).expiration_date := l_implicit_rec.expiration_date;
        x_Line_Adj_tbl(l_count).rebate_transaction_type_code := l_implicit_rec.rebate_transaction_type_code;
        x_Line_Adj_tbl(l_count).rebate_transaction_reference := l_implicit_rec.rebate_transaction_reference;
        x_Line_Adj_tbl(l_count).rebate_payment_system_code := l_implicit_rec.rebate_payment_system_code;
        x_Line_Adj_tbl(l_count).redeemed_date := l_implicit_rec.redeemed_date;
        x_Line_Adj_tbl(l_count).redeemed_flag := l_implicit_rec.redeemed_flag;
        x_Line_Adj_tbl(l_count).accrual_flag := l_implicit_rec.accrual_flag;
     x_Line_Adj_tbl(l_count).range_break_quantity := l_implicit_rec.range_break_quantity;
     x_Line_Adj_tbl(l_count).accrual_conversion_rate := l_implicit_rec.accrual_conversion_rate;
     x_Line_Adj_tbl(l_count).pricing_group_sequence := l_implicit_rec.pricing_group_sequence;
     x_Line_Adj_tbl(l_count).modifier_level_code := l_implicit_rec.modifier_level_code;
     x_Line_Adj_tbl(l_count).price_break_type_code := l_implicit_rec.price_break_type_code;
     x_Line_Adj_tbl(l_count).substitution_attribute := l_implicit_rec.substitution_attribute;
     x_Line_Adj_tbl(l_count).proration_type_code := l_implicit_rec.proration_type_code;
     x_Line_Adj_tbl(l_count).credit_or_charge_flag := l_implicit_rec.credit_or_charge_flag;
     x_Line_Adj_tbl(l_count).include_on_returns_flag := l_implicit_rec.include_on_returns_flag;
        x_Line_Adj_tbl(l_count).ac_attribute1    := l_implicit_rec.AC_ATTRIBUTE1;
        x_Line_Adj_tbl(l_count).ac_attribute10   := l_implicit_rec.AC_ATTRIBUTE10;
        x_Line_Adj_tbl(l_count).ac_attribute11   := l_implicit_rec.AC_ATTRIBUTE11;
        x_Line_Adj_tbl(l_count).ac_attribute12   := l_implicit_rec.AC_ATTRIBUTE12;
        x_Line_Adj_tbl(l_count).ac_attribute13   := l_implicit_rec.AC_ATTRIBUTE13;
        x_Line_Adj_tbl(l_count).ac_attribute14   := l_implicit_rec.AC_ATTRIBUTE14;
        x_Line_Adj_tbl(l_count).ac_attribute15   := l_implicit_rec.AC_ATTRIBUTE15;
        x_Line_Adj_tbl(l_count).ac_attribute2    := l_implicit_rec.AC_ATTRIBUTE2;
        x_Line_Adj_tbl(l_count).ac_attribute3    := l_implicit_rec.AC_ATTRIBUTE3;
        x_Line_Adj_tbl(l_count).ac_attribute4    := l_implicit_rec.AC_ATTRIBUTE4;
        x_Line_Adj_tbl(l_count).ac_attribute5    := l_implicit_rec.AC_ATTRIBUTE5;
        x_Line_Adj_tbl(l_count).ac_attribute6    := l_implicit_rec.AC_ATTRIBUTE6;
        x_Line_Adj_tbl(l_count).ac_attribute7    := l_implicit_rec.AC_ATTRIBUTE7;
        x_Line_Adj_tbl(l_count).ac_attribute8    := l_implicit_rec.AC_ATTRIBUTE8;
        x_Line_Adj_tbl(l_count).ac_attribute9    := l_implicit_rec.AC_ATTRIBUTE9;
        x_Line_Adj_tbl(l_count).ac_context       := l_implicit_rec.AC_CONTEXT;
--uom begin
       x_Line_Adj_tbl(l_count).operand_per_pqty := l_implicit_rec.operand_per_pqty;
       x_Line_Adj_tbl(l_count).adjusted_amount_per_pqty := l_implicit_rec.adjusted_amount_per_pqty;
--uom end
       x_Line_Adj_tbl(l_count).invoiced_amount    := l_implicit_rec.invoiced_amount;
       x_Line_Adj_tbl(l_count).orig_sys_discount_ref := l_implicit_rec.orig_sys_discount_ref;
        x_Line_Adj_tbl(l_count).lock_control      := l_implicit_rec.LOCK_CONTROL;
 -- eBTax Changes
        x_Line_Adj_tbl(l_count).tax_rate_id      := l_implicit_rec.tax_Rate_id;

        -- set values for non-DB fields
        x_Line_Adj_tbl(l_count).db_flag          := FND_API.G_TRUE;
        x_Line_Adj_tbl(l_count).operation        := FND_API.G_MISS_CHAR;
        x_Line_Adj_tbl(l_count).return_status    := FND_API.G_MISS_CHAR;

     -- bug 2209746   begin
     if (l_entity = 2) then
         if  nvl(l_implicit_rec.adjusted_amount,0) <> 0 then
x_line_Adj_tbl(l_count).group_value := abs(l_implicit_rec.operand/l_implicit_rec.adjusted_amount);
       end if;
     end if;
     --bug 2209746    end
     --RT{
        x_Line_Adj_tbl(l_count).retrobill_request_id:=l_implicit_rec.retrobill_request_id;
     --RT}
	   l_count := l_count + 1;

    END LOOP;

    IF l_entity = 1 THEN
        CLOSE l_line_adj_csr;
    ELSIF l_entity = 2 THEN
        CLOSE l_line_adj_csr2;
    ELSIF l_entity = 3 THEN
        CLOSE l_line_adj_csr3;
    ELSIF l_entity = 4 THEN
        CLOSE l_line_adj_csr4;
    END IF;

    --  PK sent and no rows found

    IF
    (p_price_adjustment_id IS NOT NULL
     AND
     p_price_adjustment_id <> FND_API.G_MISS_NUM)
    AND
    (x_Line_Adj_tbl.COUNT = 0)
    THEN
        RAISE NO_DATA_FOUND;
    END IF;


    --  Return fetched table

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  G_PKG_NAME||':QUERY_ROW:'||SQLERRM ) ;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  G_PKG_NAME||':QUERY_ROW:'||SQLERRM ) ;
        END IF;
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

PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2

,   p_x_Line_Adj_rec                IN OUT NOCOPY OE_Order_PUB.Line_Adj_Rec_Type
--                                      := OE_Order_PUB.G_MISS_LINE_ADJ_REC
,   p_price_adjustment_id           IN  NUMBER
                                        := FND_API.G_MISS_NUM
-- ,   x_Line_Adj_rec                  OUT OE_Order_PUB.Line_Adj_Rec_Type
)
IS
l_price_adjustment_id         NUMBER;
l_Line_Adj_rec                OE_Order_PUB.Line_Adj_Rec_Type;
l_lock_control				NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_LINE_ADJ_UTIL.LOCK_ROW' , 1 ) ;
   END IF;

    SAVEPOINT Lock_Row;

    l_lock_control := NULL;

    -- Retrieve the primary key.
    IF p_price_adjustment_id <> FND_API.G_MISS_NUM THEN
        l_price_adjustment_id := p_price_adjustment_id;
    ELSE
        l_price_adjustment_id := p_x_line_adj_rec.price_adjustment_id;
	   l_lock_control := p_x_Line_Adj_rec.lock_control;
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

    OE_Line_Adj_Util.Query_Row
    (p_price_adjustment_id	=> l_price_adjustment_id
    ,x_Line_Adj_rec 		=> p_x_Line_Adj_rec
    );
    -- If lock_control is not passed(is null or missing), then return the locked record.


    IF l_lock_control is null OR
       l_lock_control = FND_API.G_MISS_NUM
    THEN

        --  Set return status
        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        p_x_line_adj_rec.return_status     := FND_API.G_RET_STS_SUCCESS;

        -- return for lock by ID.
	RETURN;

    END IF;

    --  Row locked. If the whole record is passed, then
    --  Compare lock_control.

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'COMPARE ' , 1 ) ;
    END IF;

    IF      OE_GLOBALS.Equal(p_x_line_adj_rec.lock_control,
                             l_lock_control)
    THEN

        --  Row has not changed. Set out parameter.

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'LOCKED ROW' , 1 ) ;
        END IF;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        p_x_line_adj_rec.return_status       := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ROW CHANGED BY OTHER USER' , 1 ) ;
        END IF;

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_line_adj_rec.return_status       := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            -- Release the lock
            ROLLBACK TO Lock_Row;

            fnd_message.set_name('ONT','OE_LOCK_ROW_CHANGED');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Line_Adj_rec.return_status   := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_LOCK_ROW_DELETED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        p_x_Line_Adj_rec.return_status   := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ONT','OE_LOCK_ROW_ALREADY_LOCKED');
            FND_MSG_PUB.Add;

        END IF;
    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        p_x_Line_Adj_rec.return_status   := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

END Lock_Row;

--  Procedure       lock_Rows

PROCEDURE Lock_Rows
(   p_price_adjustment_id          IN  NUMBER
                                       := FND_API.G_MISS_NUM
,   p_line_id           			IN  NUMBER
                                       := FND_API.G_MISS_NUM
,   x_Line_Adj_tbl                  OUT NOCOPY OE_Order_PUB.Line_Adj_Tbl_Type
, x_return_status OUT NOCOPY VARCHAR2

)
IS

  CURSOR lock_adj_lines(p_line_id IN NUMBER) IS
  SELECT price_adjustment_id
  FROM   oe_price_adjustments
  WHERE  line_id = p_line_id
  FOR UPDATE NOWAIT;

  l_price_adjustment_id         NUMBER;
  l_Line_Adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
  l_lock_control			  NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_LINE_ADJ_UTIL.LOCK_ROWS.' , 1 ) ;
  END IF;

  IF (p_price_adjustment_id IS NOT NULL AND
	 p_price_adjustment_id <> FND_API.G_MISS_NUM) AND
     (p_line_id IS NOT NULL AND
	 p_line_id <> FND_API.G_MISS_NUM)
  THEN
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 OE_MSG_PUB.Add_Exc_Msg
	 (  G_PKG_NAME
	 ,  'Lock_Rows'
	 ,  'Keys are mutually exclusive: price_adjustment_id = ' ||
	    p_price_adjustment_id || ', line_id = ' || p_line_id );
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

  -- null line_id shouldn't be passed in unnecessarily if
  -- price_adjustment_id is passed in already.
  BEGIN
    IF p_line_id <> FND_API.G_MISS_NUM THEN
	 SAVEPOINT LOCK_ROWS;
	 OPEN lock_adj_lines(p_line_id);

	 LOOP
	   FETCH lock_adj_lines INTO l_price_adjustment_id;
	   EXIT WHEN lock_adj_lines%NOTFOUND;
      END LOOP;
      CLOSE lock_adj_lines;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
	 ROLLBACK TO LOCK_ROWS;

	 IF lock_adj_lines%ISOPEN THEN
        CLOSE lock_adj_lines;
      END IF;

	 RAISE;
  END;

  OE_Line_Adj_Util.Query_Rows
  ( p_price_adjustment_id	=> p_price_adjustment_id
  , p_line_id				=> p_line_id
  , x_Line_Adj_tbl			=> x_Line_Adj_tbl
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
       oe_debug_pub.add(  'EXITING OE_LINE_ADJ_UTIL.LOCK_ROWS.' , 1 ) ;
   END IF;

END Lock_Rows;

PROCEDURE Log_Adj_Requests
( x_return_status OUT NOCOPY VARCHAR2

, p_adj_rec		IN	OE_order_pub.Line_Adj_Rec_Type
, p_old_adj_rec		IN	OE_order_pub.Line_Adj_Rec_Type
, p_delete_flag		IN	BOOLEAN DEFAULT FALSE
  ) IS
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- if the adjustment_id changed or the percent changed
   -- or discount or discount_line has changed

    IF (  (p_adj_rec.price_adjustment_id <> p_old_adj_rec.price_adjustment_id
	   OR
	   p_old_adj_rec.price_adjustment_id IS NULL)
	OR
	  (p_adj_rec.operand <> p_old_adj_rec.operand
	   OR
	   p_old_adj_rec.operand IS NULL)
	OR
	  (p_adj_rec.list_line_id <> p_old_adj_rec.list_line_id
	   OR
	   p_old_adj_rec.list_line_id IS NULL)
	OR
	  (p_adj_rec.list_header_id <> p_old_adj_rec.list_header_id
	   OR
	   p_old_adj_rec.list_header_id IS NULL)
	OR
	  p_delete_flag)
      THEN

	  /*
       oe_delayed_requests_pvt.log_request(p_entity_code	=> OE_GLOBALS.G_ENTITY_LINE_ADJ,
		   p_entity_id		=> p_adj_rec.line_id,
		   p_requesting_entity_code        => OE_GLOBALS.G_ENTITY_LINE_ADJ,
                   p_requesting_entity_id          => p_adj_rec.price_adjustment_id,
		   p_request_type	=> OE_GLOBALS.G_PRICE_ADJ,
		   x_return_status	=> x_return_status);
		   */
		   null;

    END IF;

END Log_Adj_Requests;

--  Function Get_Values

FUNCTION Get_Values
(   p_Line_Adj_rec                  IN  OE_Order_PUB.Line_Adj_Rec_Type
,   p_old_Line_Adj_rec              IN  OE_Order_PUB.Line_Adj_Rec_Type :=
                                        OE_Order_PUB.G_MISS_LINE_ADJ_REC
) RETURN OE_Order_PUB.Line_Adj_Val_Rec_Type
IS
l_Line_Adj_val_rec            OE_Order_PUB.Line_Adj_Val_Rec_Type;
BEGIN

    IF (p_Line_Adj_rec.discount_id IS NULL OR
        p_Line_Adj_rec.discount_id <> FND_API.G_MISS_NUM) AND
        NOT OE_GLOBALS.Equal(p_Line_Adj_rec.discount_id,
        p_old_Line_Adj_rec.discount_id)
    THEN
        l_Line_Adj_val_rec.discount := OE_Id_To_Value.Discount
        (   p_discount_id                 => p_Line_Adj_rec.discount_id
        );
    END IF;

    RETURN l_Line_Adj_val_rec;

END Get_Values;

--  Procedure Get_Ids

PROCEDURE Get_Ids
(   p_x_Line_Adj_rec                IN OUT NOCOPY OE_Order_PUB.Line_Adj_Rec_Type
,   p_Line_Adj_val_rec              IN  OE_Order_PUB.Line_Adj_Val_Rec_Type
)
IS
l_Line_Adj_rec                OE_Order_PUB.Line_Adj_Rec_Type;
BEGIN

    --  initialize  return_status.

    l_Line_Adj_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_Line_Adj_rec.

    l_Line_Adj_rec := p_x_Line_Adj_rec;

    IF  p_Line_Adj_val_rec.discount <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_Line_Adj_rec.discount_id <> FND_API.G_MISS_NUM THEN

            l_Line_Adj_rec.discount_id := p_x_Line_Adj_rec.discount_id;

            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','discount');
                FND_MSG_PUB.Add;

            END IF;

        ELSE

            l_Line_Adj_rec.discount_id := OE_Value_To_Id.discount
            (   p_discount                    => p_Line_Adj_val_rec.discount
            );

            IF l_Line_Adj_rec.discount_id = FND_API.G_MISS_NUM THEN
                l_Line_Adj_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    -- RETURN l_Line_Adj_rec;
    p_x_Line_Adj_rec := l_Line_Adj_rec;

END Get_Ids;

-- This function converts a Header adj record to a Line Adjustment record
Function Convert_Hdr_Adj_To_Line_Adj
( p_header_adj_rec IN OE_Order_PUB.Header_adj_rec_type)
RETURN OE_Order_PUB.Line_Adj_Rec_Type
IS
l_line_adj_rec OE_Order_PUB.Line_Adj_Rec_Type;
BEGIN

        l_line_adj_rec.attribute1        := p_header_adj_rec.attribute1;
        l_line_adj_rec.attribute10       := p_header_adj_rec.attribute10;
        l_line_adj_rec.attribute11       := p_header_adj_rec.attribute11;
        l_line_adj_rec.attribute12       := p_header_adj_rec.attribute12;
        l_line_adj_rec.attribute13       := p_header_adj_rec.attribute13;
        l_line_adj_rec.attribute14       := p_header_adj_rec.attribute14;
        l_line_adj_rec.attribute15       := p_header_adj_rec.attribute15;
        l_line_adj_rec.attribute2        := p_header_adj_rec.attribute2;
        l_line_adj_rec.attribute3        := p_header_adj_rec.attribute3;
        l_line_adj_rec.attribute4        := p_header_adj_rec.attribute4;
        l_line_adj_rec.attribute5        := p_header_adj_rec.attribute5;
        l_line_adj_rec.attribute6        := p_header_adj_rec.attribute6;
        l_line_adj_rec.attribute7        := p_header_adj_rec.attribute7;
        l_line_adj_rec.attribute8        := p_header_adj_rec.attribute8;
        l_line_adj_rec.attribute9        := p_header_adj_rec.attribute9;
        l_line_adj_rec.automatic_flag    :=p_header_adj_rec.automatic_flag;
        l_line_adj_rec.context         := p_header_adj_rec.context;
        l_line_adj_rec.created_by        := p_header_adj_rec.created_by;
        l_line_adj_rec.creation_date     := p_header_adj_rec.creation_date;
        l_line_adj_rec.discount_id       := p_header_adj_rec.discount_id;
        l_line_adj_rec.discount_line_id:=p_header_adj_rec.discount_line_id;
        l_line_adj_rec.header_id         := p_header_adj_rec.header_id;
        l_line_adj_rec.last_updated_by := p_header_adj_rec.last_updated_by;
        l_line_adj_rec.last_update_date:= p_header_adj_rec.last_update_date;
        l_line_adj_rec.last_update_login:= p_header_adj_rec.last_update_login;
        l_line_adj_rec.line_id         := p_header_adj_rec.line_id;
        l_line_adj_rec.percent         := p_header_adj_rec.percent;
        l_line_adj_rec.price_adjustment_id        := p_header_adj_rec.price_adjustment_id;
        l_line_adj_rec.program_application_id := p_header_adj_rec.program_application_id;
        l_line_adj_rec.program_id               := p_header_adj_rec.program_id;
        l_line_adj_rec.program_update_date        := p_header_adj_rec.program_update_date;
        l_line_adj_rec.request_id               := p_header_adj_rec.request_id;
        l_line_adj_rec.return_status            := p_header_adj_rec.return_status;
        l_line_adj_rec.db_flag                := p_header_adj_rec.db_flag;
        l_line_adj_rec.operation                := p_header_adj_rec.operation;
    l_line_adj_rec.list_header_id	:= p_header_adj_rec.list_header_id;
    l_line_adj_rec.list_line_id	:= p_header_adj_rec.list_line_id;
    l_line_adj_rec.list_line_type_code	:= p_header_adj_rec.list_line_type_code;
    l_line_adj_rec.modifier_mechanism_type_code	:= p_header_adj_rec.modifier_mechanism_type_code;
    l_line_adj_rec.modified_from	:= p_header_adj_rec.modified_from;
    l_line_adj_rec.modified_to	:= p_header_adj_rec.modified_to;
    l_line_adj_rec.updated_flag	:= p_header_adj_rec.updated_flag;
    l_line_adj_rec.update_allowed	:= p_header_adj_rec.update_allowed;
    l_line_adj_rec.applied_flag	:= p_header_adj_rec.applied_flag;
    l_line_adj_rec.change_reason_code	:= p_header_adj_rec.change_reason_code;
    l_line_adj_rec.change_reason_text	:= p_header_adj_rec.change_reason_text;
    l_line_adj_rec.operand	:= p_header_adj_rec.operand;
    l_line_adj_rec.operand_per_pqty	:= p_header_adj_rec.operand_per_pqty;
    l_line_adj_rec.arithmetic_operator	:= p_header_adj_rec.arithmetic_operator;
    l_line_adj_rec.adjusted_amount	:= p_header_adj_rec.adjusted_amount;
    l_line_adj_rec.adjusted_amount_per_pqty	:= p_header_adj_rec.adjusted_amount_per_pqty;
    l_line_adj_rec.pricing_phase_id	:= p_header_adj_rec.pricing_phase_id;
    l_line_adj_rec.cost_id     := p_header_adj_rec.cost_id;
	l_line_adj_rec.tax_code    := p_header_adj_rec.tax_code;
	l_line_adj_rec.tax_exempt_flag := p_header_adj_rec.tax_exempt_flag;
	l_line_adj_rec.tax_exempt_number := p_header_adj_rec.tax_exempt_number;
	l_line_adj_rec.tax_exempt_reason_code := p_header_adj_rec.tax_exempt_reason_code;
	l_line_adj_rec.parent_adjustment_id := p_header_adj_rec.parent_adjustment_id;
	l_line_adj_rec.invoiced_flag := p_header_adj_rec.invoiced_flag;
	l_line_adj_rec.estimated_flag := p_header_adj_rec.estimated_flag;
	l_line_adj_rec.inc_in_sales_performance := p_header_adj_rec.inc_in_sales_performance;
	l_line_adj_rec.split_action_code := p_header_adj_rec.split_action_code;
	l_line_adj_rec.charge_type_code := p_header_adj_rec.charge_type_code;
	l_line_adj_rec.charge_subtype_code := p_header_adj_rec.charge_subtype_code;

	l_line_adj_rec.adjusted_amount := p_header_adj_rec.adjusted_amount;
	l_line_adj_rec.pricing_phase_id := p_header_adj_rec.pricing_phase_id;
	l_line_adj_rec.list_line_no := p_header_adj_rec.list_line_no;
	l_line_adj_rec.source_system_code := p_header_adj_rec.source_system_code;
	l_line_adj_rec.benefit_qty := p_header_adj_rec.benefit_qty;
	l_line_adj_rec.benefit_uom_code := p_header_adj_rec.benefit_uom_code;
	l_line_adj_rec.print_on_invoice_flag := p_header_adj_rec.print_on_invoice_flag;
	l_line_adj_rec.expiration_date := p_header_adj_rec.expiration_date;
	l_line_adj_rec.rebate_transaction_type_code := p_header_adj_rec.rebate_transaction_type_code;
	l_line_adj_rec.rebate_transaction_reference := p_header_adj_rec.rebate_transaction_reference;
	l_line_adj_rec.rebate_payment_system_code := p_header_adj_rec.rebate_payment_system_code;
	l_line_adj_rec.redeemed_date := p_header_adj_rec.redeemed_date;
	l_line_adj_rec.redeemed_flag := p_header_adj_rec.redeemed_flag;
	l_line_adj_rec.accrual_flag := p_header_adj_rec.accrual_flag;
	l_line_adj_rec.range_break_quantity := p_header_adj_rec.range_break_quantity;
	l_line_adj_rec.accrual_conversion_rate := p_header_adj_rec.accrual_conversion_rate;
	l_line_adj_rec.pricing_group_sequence := p_header_adj_rec.pricing_group_sequence;
	l_line_adj_rec.modifier_level_code := p_header_adj_rec.modifier_level_code;
	l_line_adj_rec.price_break_type_code := p_header_adj_rec.price_break_type_code;
	l_line_adj_rec.substitution_attribute := p_header_adj_rec.substitution_attribute;
	l_line_adj_rec.proration_type_code := p_header_adj_rec.proration_type_code;
	l_line_adj_rec.credit_or_charge_flag := p_header_adj_rec.credit_or_charge_flag;
	l_line_adj_rec.include_on_returns_flag := p_header_adj_rec.include_on_returns_flag;
        l_line_adj_rec.ac_attribute1        := p_header_adj_rec.ac_attribute1;
        l_line_adj_rec.ac_attribute10       := p_header_adj_rec.ac_attribute10;
        l_line_adj_rec.ac_attribute11       := p_header_adj_rec.ac_attribute11;
        l_line_adj_rec.ac_attribute12       := p_header_adj_rec.ac_attribute12;
        l_line_adj_rec.ac_attribute13       := p_header_adj_rec.ac_attribute13;
        l_line_adj_rec.ac_attribute14       := p_header_adj_rec.ac_attribute14;
        l_line_adj_rec.ac_attribute15       := p_header_adj_rec.ac_attribute15;
        l_line_adj_rec.ac_attribute2        := p_header_adj_rec.ac_attribute2;
        l_line_adj_rec.ac_attribute3        := p_header_adj_rec.ac_attribute3;
        l_line_adj_rec.ac_attribute4        := p_header_adj_rec.ac_attribute4;
        l_line_adj_rec.ac_attribute5        := p_header_adj_rec.ac_attribute5;
        l_line_adj_rec.ac_attribute6        := p_header_adj_rec.ac_attribute6;
        l_line_adj_rec.ac_attribute7        := p_header_adj_rec.ac_attribute7;
        l_line_adj_rec.ac_attribute8        := p_header_adj_rec.ac_attribute8;
        l_line_adj_rec.ac_attribute9        := p_header_adj_rec.ac_attribute9;
        l_line_adj_rec.ac_context           := p_header_adj_rec.ac_context;
        l_line_adj_rec.invoiced_amount      := p_header_adj_rec.invoiced_amount;

      RETURN l_line_adj_rec;

END Convert_Hdr_Adj_To_Line_Adj;

Procedure Append_Adjustment_Attribs(
				px_Line_Adj_Att_Tbl    in out nocopy OE_Order_Pub.line_adj_att_tbl_Type
				,p_price_adjustment_id	number
				,p_adj_index			pls_integer
				)
is
l_Line_Adj_Att_Tbl    	OE_Order_Pub.line_adj_att_tbl_Type;
i					pls_integer;
begin

		Oe_Line_Price_Aattr_util.Query_Rows(
						p_price_adjustment_id => p_price_adjustment_id
						, x_Line_Adj_Att_Tbl  => l_Line_Adj_Att_Tbl
						);

		i:= L_Line_Adj_Att_Tbl.First;
		While i is not null loop

			L_Line_Adj_Att_Tbl(i).operation := OE_GLOBALS.G_OPR_CREATE;
			L_Line_Adj_Att_Tbl(i).price_adjustment_id := fnd_api.g_miss_num;
			L_Line_Adj_Att_Tbl(i).adj_index := p_adj_index;
			L_Line_Adj_Att_Tbl(i).price_adj_attrib_id := fnd_api.g_miss_num;

			px_Line_Adj_Att_Tbl(px_Line_Adj_Att_Tbl.count+1) := L_Line_Adj_Att_Tbl(i);

	  	i:= L_Line_Adj_Att_Tbl.Next(i);

		end loop;

end Append_Adjustment_Attribs;

Procedure Prorate_Lumpsum (
px_line_adj_rec  IN OUT NOCOPY OE_Order_Pub.Line_AdJ_Rec_Type
,  p_to_line_id     IN NUMBER
, x_copy_from_line_adj_rec OUT NOCOPY OE_Order_Pub.Line_Adj_Rec_Type

)
IS
l_ordered_quantity              NUMBER;
l_sign                          NUMBER;
l_pricing_quantity              NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING PROCEDURE PRORATE_LUMPSUM' ) ;
  END IF;

  If px_line_adj_rec.operand = 0 or px_line_adj_rec.operand is null Then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' NOTHING TO PRORATE , OPERAND IS 0' ) ;
    END IF;
    x_copy_from_line_adj_rec.operation := OE_GLOBALS.G_OPR_NONE;
    Return;
  End If;

  IF (px_line_adj_rec.list_line_type_code='DIS') THEN
    l_sign := -1;
  ELSE
    l_sign := 1;
  END IF;

   -- First correct the copy_from line adj record
   SELECT ordered_quantity,pricing_quantity
     INTO l_ordered_quantity,
          l_pricing_quantity
     FROM oe_order_lines_all
    WHERE  line_id = px_line_adj_rec.line_id;

   If (round(abs(px_line_adj_rec.operand) -
             abs(l_ordered_quantity * px_line_adj_rec.adjusted_amount/ px_line_adj_rec.operand),20))
     <> 0
   THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OPERAND'||PX_LINE_ADJ_REC.OPERAND ||'<>'||L_ORDERED_QUANTITY||'*'||PX_LINE_ADJ_REC.ADJUSTED_AMOUNT ) ;
      END IF;

     x_copy_from_line_adj_rec := px_line_adj_rec;
     x_copy_from_line_adj_rec.operation := oe_globals.g_opr_update;
     x_copy_from_line_adj_rec.operand := l_ordered_quantity
           * x_copy_from_line_adj_rec.adjusted_amount * l_sign;


     x_copy_from_line_adj_rec.operand_per_pqty := l_pricing_quantity
           *x_copy_from_line_adj_rec.adjusted_amount_per_pqty*l_sign;

     x_copy_from_line_adj_rec.operand_per_pqty:=nvl(x_copy_from_line_adj_rec.operand_per_pqty,
                                                   x_copy_from_line_adj_rec.operand);

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  ' PRORATED ADJUSTED_AMOUNT_PER_PQTY:'||X_COPY_FROM_LINE_ADJ_REC.ADJUSTED_AMOUNT_PER_PQTY ) ;
         oe_debug_pub.add(  ' PRORATED ADJUSTED_AMOUNT:'||X_COPY_FROM_LINE_ADJ_REC.ADJUSTED_AMOUNT ) ;
     END IF;

  ELSE
     x_copy_from_line_adj_rec.operation := OE_GLOBALS.G_OPR_NONE;
  END IF;

   -- Then correct the copy_to line adj record
   SELECT ordered_quantity
     INTO l_ordered_quantity
     FROM oe_order_lines_all
    WHERE  line_id = p_to_line_id;

  IF (round(abs(px_line_adj_rec.operand) -
             abs(l_ordered_quantity * px_line_adj_rec.adjusted_amount/ px_line_adj_rec.operand),20))
     <> 0

   THEN

     px_line_adj_rec.operand := l_ordered_quantity
                                * px_line_adj_rec.adjusted_amount
                                * l_sign;

     px_line_adj_rec.operand_per_pqty := NULL;

  END IF;

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'LEAVING PROCEDURE PRORATE_LUMPSUM' ) ;
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
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'EXCEPTION IN PRORATE_LUMPSUM'||SQLERRM , 2 ) ;
       END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End Prorate_Lumpsum;

Procedure Append_Adjustment_Lines(
				p_header_id 			Number default null,
				p_line_id 			Number default null,
				p_to_line_id 			Number default null,
				p_to_header_id 		        Number default null,
				p_operation			varchar2,
				p_line_category_code	        varchar2,
                                p_split_by                      varchar2 default null,
				px_Line_Adj_Att_Tbl    in out nocopy OE_Order_Pub.line_adj_att_tbl_Type,
				px_Line_Adj_Tbl in out nocopy OE_Order_Pub.Line_Adj_Tbl_Type,
                                px_line_adj_assoc_tbl in out nocopy  OE_Order_PUB.Line_Adj_Assoc_tbl_type,
                                --RT{
                                p_mode                          varchar2 default null,
                                p_retrobill_request_id in Varchar2 default null,
                                p_key_line_id in Number default null
                                --RT}
                                )
is
l_Line_Adj_Tbl			OE_Order_Pub.Line_Adj_Tbl_Type;
i					pls_integer;
l_has_pbh                       VARCHAR2(1):='N';
l_pbh_tbl                       Pbh_Tbl_Type;
cnt                             Pls_Integer:=0;
l_copy_from_line_adj_rec        OE_Order_pub.Line_Adj_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_from_line_category            VARCHAR2(100);
--RT{
l_ulp NUMBER;
cursor get_ulp(p_line_id IN NUMBER) IS
SELECT UNIT_LIST_PRICE
FROM   OE_ORDER_LINES_ALL
WHERE  LINE_ID = p_line_id;
l_sign PLS_INTEGER:=1;
l_line_id NUMBER;
l_header_id NUMBER;
l_has_retrobilled_before Varchar2(1):='N';
--RT}
l_charges_for_backorders     VARCHAR2(1):=NVL(FND_PROFILE.VALUE('ONT_CHARGES_FOR_BACKORDERS'),'N');
begin

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTERING OE_LINE_ADJ_UTIL.APPEND_ADJUSTMENT_LINES' , 1 ) ;
            oe_debug_pub.add(' operation:'|| p_operation);
	END IF;


    -- Manish Changes
   if p_line_id is not null then

      IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' and
         p_operation <> OE_GLOBALS.G_OPR_DELETE  THEN
          --RT{
           --we need to retrieve the latest adjustments if it is a retrobilled line
           --call retrobill api to get the retrobill line id, if none l_line_id will
           --set to the same value as p_line_id

          Oe_Retrobill_Pvt.Get_Last_Retro_LinID(p_line_id=>p_line_id,
                                                x_line_id=>l_line_id);

          if nvl(p_line_id,-1) <> nvl(l_line_id,-1) then
           --Old id and new id difference, line has been retrobilled multiple times
           --new id is actullay a retrobill line, not a regular line.
           --we just need to copy adjustment with retrobill_request_id is not null
           --from this retrobill line over.
           l_has_retrobilled_before:='Y';
          end if;

          --RT}
          OE_Version_History_Util.Query_Rows
            (  p_line_id => l_line_id
             , p_version_number => OE_ORDER_COPY_UTIL.G_LN_VER_NUMBER
             , p_phase_change_flag => OE_ORDER_COPY_UTIL.G_LN_PHASE_CHANGE_FLAG
			 , x_Line_Adj_Tbl => l_Line_Adj_Tbl);

          If l_debug_level > 0 Then
           oe_debug_pub.add(' input line id to retro api:'||p_line_id||' output line id:'|| l_line_id);
           oe_debug_pub.add(' l_line_adj_tbl.count from versioning:'|| l_Line_Adj_Tbl.count);
          End If;

      ELSE
              oe_debug_pub.add('pre 11510, using old query row');
	      OE_Line_Adj_Util.Query_Rows(p_Line_Id => p_line_id
					        , x_Line_Adj_Tbl => l_Line_Adj_Tbl);
      END IF;

   else
	--	l_Line_Adj_Tbl := OE_Line_Adj_Util.Query_Rows(p_header_Id => p_header_id);
      IF OE_CODE_CONTROL.Get_Code_Release_Level >= '110510' and
         p_operation <> OE_GLOBALS.G_OPR_DELETE  THEN
           --RT{
           Oe_Retrobill_Pvt.Get_Last_Retro_HdrID(p_header_id=>p_header_id,
                                           x_header_id=>l_header_id);
          if nvl(p_header_id,-1) <> nvl(l_header_id,-1) then
           l_has_retrobilled_before:='Y';
          end if;
           --RT}

          OE_Version_History_Util.Query_Rows
            (  p_header_id => l_header_id
             , p_version_number => OE_ORDER_COPY_UTIL.G_LN_VER_NUMBER
             , p_phase_change_flag => OE_ORDER_COPY_UTIL.G_LN_PHASE_CHANGE_FLAG
			 , x_Line_Adj_Tbl => l_Line_Adj_Tbl);

          If l_debug_level > 0 Then
           oe_debug_pub.add(' input Header id to retro api:'||p_header_id||' output Header id:'|| l_header_id);
           oe_debug_pub.add(' l_line_adj_tbl.count from versioning:'|| l_Line_Adj_Tbl.count);
          End If;

      ELSE
	      OE_Line_Adj_Util.Query_Rows(p_header_Id => p_header_id
						   , x_Line_Adj_Tbl => l_Line_Adj_Tbl);
      END IF;
	End If;

	i:= l_Line_Adj_Tbl.First;
	While i is not Null Loop


	If p_operation = OE_GLOBALS.G_OPR_DELETE then

	  l_Line_Adj_Tbl(i).operation := p_operation;
	  px_line_adj_tbl(px_line_adj_tbl.count+1) := L_Line_Adj_Tbl(i);

	Else

	  /* Modified IF condition to process only Line Level Freight Charges for Bug # 1559906 */
          -- bug 1937110, added type 'IUE'.
          oe_debug_pub.add('Retro:list line type code:'||l_Line_Adj_Tbl(i).list_line_type_code);

          --RT{
          IF NOT(nvl(p_mode,'xx-') = 'RETROBILL' and l_Line_Adj_Tbl(i).list_line_type_code = 'FREIGHT_CHARGE') AND
             NOT (l_has_retrobilled_before = 'Y' and l_line_adj_tbl(i).retrobill_request_id IS NULL)
          THEN
          --skip processing, freigh charge is not supported for retrobilling
          --skip processing if we copy adjustment from a retrobill order and retrobill request id is null
          --we just want to copy over where retrobill request id is not null if it is a retrobill line
          --RT}
	  If (l_Line_Adj_Tbl(i).list_line_type_code in ('DIS','SUR', 'PBH', 'IUE'))
	  or (l_Line_Adj_Tbl(i).list_line_type_code = 'FREIGHT_CHARGE' and l_Line_Adj_Tbl(i).line_id is not null) then
                If l_line_adj_tbl(i).list_line_type_code = 'PBH' Then
                   l_has_pbh := 'Y';
                   --l_pbh_tbl store the index that has pbh adj line
                   cnt := cnt + 1;
                    l_pbh_tbl(cnt):=px_line_adj_tbl.count+1;
                End If;
                -- FP bug3337324
                 -- changed for the bug 3479388
                  -- changed the below condition for the bug 9494742
		If l_Line_Adj_Tbl(i).list_line_type_code ='FREIGHT_CHARGE' and
			((p_line_category_code = 'RETURN' and
			(NVL(l_Line_Adj_Tbl(i).include_on_returns_flag,'N') <> 'Y' OR
			 NVL(l_Line_Adj_Tbl(i).applied_flag,'N') = 'N' )) OR
                         (p_split_by = 'SYSTEM' and l_charges_for_backorders = 'N' and
                          l_line_adj_tbl(i).arithmetic_operator = 'LUMPSUM')) then
                         oe_debug_pub.add('No Charges are Copied');
			Null;
		Else

                  -- prorate lumpsum
                  IF (l_line_adj_tbl(i).modifier_level_code='LINE'
                  and l_line_adj_tbl(i).arithmetic_operator = 'LUMPSUM')
                  THEN
                                          IF l_debug_level  > 0 THEN
                                              oe_debug_pub.add(  ' P_HEADER_ID:'||P_HEADER_ID|| 'P_TO_HEADER_ID:'||P_TO_HEADER_ID ) ;
                           oe_debug_pub.add(  ' P_SPLIT_BY:'||P_SPLIT_BY ) ;
                       END IF;
                       --BTEA
                       --Only when split we need to do this.
                       --during split we will have same to_ and from_ header_id
                       --and split_by column is not null
                       If p_to_header_id = p_header_id
                          AND p_split_by is Not NULL
                       Then
                         -- added for the bug 3479388
			IF NOT (p_split_by = 'SYSTEM' and l_charges_for_backorders = 'Y'
			      and l_Line_Adj_Tbl(i).list_line_type_code = 'FREIGHT_CHARGE') THEN -- 7363214
                         Prorate_Lumpsum(l_line_adj_tbl(i),
                                         p_to_line_id,
                                         l_copy_from_line_adj_rec);

                         IF l_copy_from_line_adj_rec.operation
                           = OE_GLOBALS.G_OPR_UPDATE THEN
                             IF l_debug_level  > 0 THEN
                                 oe_debug_pub.add(  ' UPDATING OPERAND FOR LINE ID:'||L_COPY_FROM_LINE_ADJ_REC.LINE_ID ) ;
                             END IF;
                           px_line_adj_tbl(px_line_adj_tbl.count+1)
                             := l_copy_from_line_adj_rec;
                         END IF;
                         END IF;
                        End If;
                  End If;

			Append_Adjustment_Attribs(
				px_Line_Adj_Att_Tbl    	=> px_Line_Adj_Att_Tbl
				,p_price_adjustment_id	=> l_Line_Adj_Tbl(i).price_adjustment_id
				,p_adj_index			=> px_line_adj_tbl.count+1
				);

	  		l_Line_Adj_Tbl(i).operation := p_operation;

			-- lkxu, fix bug 1623316
               -- don't populate line_id field if it is a HEADER level adjustment

                   --removed if condn.
                        l_Line_Adj_Tbl(i).line_id := p_to_line_id;

               /* Fixing Bug 2075878  */
             IF l_line_adj_tbl(i).modifier_level_code = 'ORDER' THEN
                l_Line_Adj_Tbl(i).modifier_level_code := 'LINE';
                --RT{
                IF l_Line_Adj_Tbl(i).arithmetic_operator = '%' THEN
                  open  get_ulp(p_key_line_id);
                  fetch get_ulp INTO l_ulp;
                  close get_ulp;
		  oe_debug_pub.add('pviprana: l_ulp :' || l_ulp);
		  --bug3392650 ( Changed the condition l_Line_Adj_Tbl(i).adjusted_amount < 0)
                  IF (l_Line_Adj_Tbl(i).list_line_type_code = 'DIS') THEN
                   l_sign := -1;
                  ELSE
                   l_sign := 1;
                  END IF;
		  --bug3392650 Calculating adjusted amount only if l_ulp is not null
		  oe_debug_pub.add('pviprana: adjusted amt'||l_Line_Adj_Tbl(i).adjusted_amount);
		  IF(l_ulp IS NOT NULL ) THEN
                     l_Line_Adj_Tbl(i).adjusted_amount:= (l_Line_Adj_Tbl(i).operand/100) * l_ulp *l_sign;
		  END IF;
                  oe_debug_pub.add('Converting Order level to line, unit list price:'|| l_ulp);
                  oe_debug_pub.add('Adjusted amount:'||l_Line_Adj_Tbl(i).adjusted_amount);
                END IF;
                --RT}
             END IF;

	  		-- l_Line_Adj_Tbl(i).line_id := p_to_line_id;
	  		l_Line_Adj_Tbl(i).Header_id := p_to_Header_id;
	  		l_Line_Adj_Tbl(i).invoiced_flag := 'N';
			l_Line_Adj_Tbl(i).invoiced_amount := null; --bug 5241848
--	  		l_Line_Adj_Tbl(i).price_adjustment_id := fnd_api.g_miss_num;

			-- Check for refndable charges on return lines. If the charge is
			-- refundable then it should be created as a credit.

	-- Commented for 7683779 Start
	/*
	--Added for bug 7328969 Start
      		select line_category_code into l_from_line_category
      		from oe_order_lines_all
      		where line_id = p_line_id ;

      		oe_debug_pub.add('p_line_category_code :'||p_line_category_code);
      		oe_debug_pub.add('l_from_line_category :'||l_from_line_category);
      		oe_debug_pub.add('l_Line_Adj_Tbl(i).credit_or_charge_flag :'||l_Line_Adj_Tbl(i).credit_or_charge_flag);

	--Added for bug 7328969 End
	*/
	-- Commented for 7683779 End

			If l_Line_Adj_Tbl(i).list_line_type_code ='FREIGHT_CHARGE'
			THEN
			--Added for bug 7683779 Start
			    select line_category_code into l_from_line_category
			    from oe_order_lines_all
			    where line_id = p_line_id ;

			    IF l_debug_level  > 0 THEN
			        oe_debug_pub.add('p_line_category_code :'||p_line_category_code);
			        oe_debug_pub.add('l_from_line_category :'||l_from_line_category);
			        oe_debug_pub.add('l_Line_Adj_Tbl(i).credit_or_charge_flag :'||l_Line_Adj_Tbl(i).credit_or_charge_flag);
			    END IF;

	                --Added for bug 7683779 End

		--Modified for bug 7328969 Start
		--IF p_line_category_code = 'RETURN' THEN
		IF (p_line_category_code = 'RETURN' AND l_from_line_category= 'ORDER' ) OR
		( l_from_line_category = 'RETURN' and  p_line_category_code = 'ORDER') THEN

		--Modified for bug 7328969 End

                       If l_Line_Adj_Tbl(i).credit_or_charge_flag = 'C' THEN
                           l_Line_Adj_Tbl(i).credit_or_charge_flag := 'D';
                       ELSE
                           l_Line_Adj_Tbl(i).credit_or_charge_flag := 'C';
                       END IF;

                       oe_debug_pub.add('l_Line_Adj_Tbl(i).credit_or_charge_flag :'||l_Line_Adj_Tbl(i).credit_or_charge_flag);

                       l_Line_Adj_Tbl(i).updated_flag := 'Y';
                       l_Line_Adj_Tbl(i).change_reason_code := 'MISC';
                       l_Line_Adj_Tbl(i).change_reason_text := 'Reversing Credit';
                   ELSE
/* commented out nocopy the following 3 lines to fix the bug 2594720


                       l_Line_Adj_Tbl(i).updated_flag := 'N';
                       l_Line_Adj_Tbl(i).change_reason_code := NULL;
                       l_Line_Adj_Tbl(i).change_reason_text := NULL;
   */
                       NULL;

/* Added the following code to fix the bug 2888990 */
                 --Commented for bug 7328969 Start
                       /*select line_category_code into l_from_line_category
                       from oe_order_lines_all
                       where line_id = p_line_id ;*/
                 --Commented for bug 7328969 End

                       if l_from_line_category = 'RETURN' and  p_line_category_code = 'ORDER' THEN
                         If l_Line_Adj_Tbl(i).credit_or_charge_flag = 'C' THEN
                          l_Line_Adj_Tbl(i).credit_or_charge_flag := 'D';
                         ELSE
                          l_Line_Adj_Tbl(i).credit_or_charge_flag := 'C';
                         END IF;

                         l_Line_Adj_Tbl(i).updated_flag := 'Y';
                         l_Line_Adj_Tbl(i).change_reason_code := 'MISC';
                         l_Line_Adj_Tbl(i).change_reason_text := 'Reversing Credit';
                       end if;
/* End of code for the bug 2888990 */


			    END IF;
			END IF;

	  		px_line_adj_tbl(px_line_adj_tbl.count+1) := L_Line_Adj_Tbl(i);

		end if; -- For Freight charges

	  End If; -- Copy only certain list line types
         --RT{
         END IF;  --check Retrobill and freight
         --RT}
	End if; -- operation=g_opr_delete

	  i:= l_Line_Adj_Tbl.Next(i);

	end loop;

         If l_has_pbh = 'Y' Then
                   Append_Association(p_line_adj_tbl        => px_line_adj_tbl,
                                      px_line_adj_assoc_tbl => px_line_adj_assoc_tbl,
                                      p_pbh_tbl             => l_pbh_tbl);
         End If;

  IF (p_operation = OE_GLOBALS.G_OPR_CREATE) and l_Line_Adj_Tbl.count > 0 THEN
  I:=px_line_adj_tbl.first;
  while I is not null loop
   IF (px_line_adj_tbl(i).operation = OE_GLOBALS.G_OPR_CREATE) THEN
  px_line_adj_tbl(i).price_adjustment_id:=fnd_api.g_miss_num;
     --RT{
       oe_debug_pub.add('operand:'||px_line_adj_tbl(i).operand);
       oe_debug_pub.add('operand per pqty:'||px_line_adj_tbl(i).operand_per_pqty);
       oe_debug_pub.add('Retro:p_mode:'||p_mode);
     IF nvl(p_mode,'NULLMODE') = 'RETROBILL' THEN
        IF px_line_adj_tbl(i).retrobill_request_id IS NOT NULL
          and px_line_adj_tbl(i).applied_flag = 'N' THEN
          --applied flag needs to remain 'Y'. Becomes 'N' only after
          --the pricing engine call
          px_line_adj_tbl(i).applied_flag := 'Y';
        END IF;

        --replace with new retrobill request id.
        px_line_adj_tbl(i).retrobill_request_id:= p_retrobill_request_id;

        --px_line_adj_tbl(i).applied_flag:='N';
        oe_debug_pub.add('RETRO:ADJ:Copied list line id:'|| px_line_adj_tbl(i).list_line_id);
        oe_debug_pub.add('RETRO:ADJ:Operand:'|| px_line_adj_tbl(i).operand);
        oe_debug_pub.add('RETRO:ADJ:Operand pqty:'||px_line_adj_tbl(i).operand_per_pqty);
     END IF;
     --RT}
   END IF;
  I:=px_line_adj_tbl.next(I);
  end loop;
  END IF;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXITING OE_LINE_ADJ_UTIL.APPEND_ADJUSTMENT_LINES' , 1 ) ;
	END IF;

end Append_Adjustment_Lines;

Procedure copy_adjustment_lines(
	p_from_line_id			number
	,p_to_line_id			number
	,p_from_Header_id		number
	,p_to_Header_id		number
	,p_line_category_code	varchar2
	,p_split_by		varchar2 default null
	,p_booked_flag		varchar2 default null
        ,p_mode                 varchar2 default null
--RT{
        ,p_retrobill_request_id Number   default null
--RT}
        ,x_return_status out nocopy varchar2

	)
is
l_Header_Adj_tbl 	oe_order_pub.Header_adj_tbl_type;
l_Line_Adj_tbl 	oe_order_pub.Line_adj_tbl_type;
l_control_rec				Oe_Globals.Control_rec_type;
l_Line_Adj_Att_tbl            OE_Order_PUB.Line_Adj_Att_tbl_type;
l_Line_Adj_Assoc_tbl          OE_Order_PUB.Line_Adj_Assoc_tbl_type;
-- l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_action_request_tbl        OE_Order_PUB.request_tbl_type;
l_x_lot_serial_tbl            OE_Order_PUB.lot_serial_tbl_type;
l_x_Header_price_Att_tbl      OE_Order_PUB.Header_price_Att_tbl_type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_tbl_type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_tbl_type;
l_x_Line_price_Att_tbl        OE_Order_PUB.Line_price_Att_tbl_type;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_tbl_type;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_tbl_type;
l_x_msg_count                   number;
l_x_msg_data                    Varchar2(2000);
i						pls_integer;
--serla begin
l_x_Header_Payment_tbl        OE_Order_PUB.Header_Payment_Tbl_Type;
l_x_Line_Payment_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
--serla end
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ENTERING OE_LINE_ADJ_UTIL.COPY_ADJUSTMENT_LINES' , 1 ) ;
            oe_debug_pub.add(  'SPLIT BY:'||P_SPLIT_BY ) ;
        END IF;
	-- Set the existing rows to delete
	Append_Adjustment_Lines(
				p_line_id 	 => p_to_line_id
				,p_operation	 => OE_GLOBALS.G_OPR_DELETE
				,p_line_category_code	 => p_line_category_code
				,px_Line_Adj_Att_Tbl => l_Line_Adj_Att_Tbl
                                ,px_Line_Adj_Tbl => l_Line_Adj_tbl
                                ,px_line_adj_assoc_tbl => l_line_adj_assoc_tbl);

	Append_Adjustment_Lines(p_header_id => p_from_header_id
				,p_line_id 	 => p_from_line_id
				,p_to_line_id 	 => p_to_line_id
				,p_to_Header_id => p_to_Header_id
				,p_line_category_code	 => p_line_category_code
				,p_operation	 => OE_GLOBALS.G_OPR_CREATE
                                ,p_split_by      => p_split_by
				,px_Line_Adj_Att_Tbl => l_Line_Adj_Att_Tbl
 			        ,px_Line_Adj_Tbl => l_Line_Adj_tbl
                                ,px_line_adj_assoc_tbl => l_line_adj_assoc_tbl
                             --RT{
                                ,p_mode =>p_mode
                                ,p_retrobill_request_id=>p_retrobill_request_id);
                             --RT});
    --RT{
    IF nvl(p_mode,'xx-') = 'RETROBILL' THEN
      OE_ORDER_COPY_UTIL.G_ORDER_LEVEL_COPY :=0;
    END IF;
    --RT}
    -- Append Header level adjustments only if the order is different
/* Modified the following if condition to fix the bug 2170086 */
        oe_debug_pub.add('pviprana: p_from_header_id'||p_from_header_id);
	oe_debug_pub.add('pviprana: p_to_header_id'||p_to_header_id);
	oe_debug_pub.add('pviprana: p_from_line_id'||p_from_line_id);
	oe_debug_pub.add('pviprana: p_to_line_id'||p_to_line_id);
	If p_from_Header_id <> p_to_Header_id and
       OE_ORDER_COPY_UTIL.G_ORDER_LEVEL_COPY = 0 then
	    --bug3392650 passing an extra parameter p_key_line_id if the mode is 'RETROBILL' so that l_ulp is obtained properly in
            --append_adjustment_lines when the order level modifier is being converted to line level.
	      IF nvl(p_mode,'xx-') = 'RETROBILL' THEN
		Append_Adjustment_Lines(
				p_Header_id 	 => p_from_Header_id
				,p_to_line_id 	 => p_to_line_id
				,p_to_Header_id => p_to_Header_id
				,p_line_category_code	 => p_line_category_code
				,p_operation	 => OE_GLOBALS.G_OPR_CREATE
				,px_Line_Adj_Att_Tbl => l_Line_Adj_Att_Tbl
 			        ,px_Line_Adj_Tbl => l_Line_Adj_tbl
                                ,px_line_adj_assoc_tbl => l_line_adj_assoc_tbl
                                 --RT{
				,p_key_line_id => p_from_line_id
                                ,p_mode =>p_mode
                                ,p_retrobill_request_id=>p_retrobill_request_id
                                 --RT}
                                 );
		ELSE
		   Append_Adjustment_Lines(
				p_Header_id 	 => p_from_Header_id
				,p_to_line_id 	 => p_to_line_id
				,p_to_Header_id => p_to_Header_id
				,p_line_category_code	 => p_line_category_code
				,p_operation	 => OE_GLOBALS.G_OPR_CREATE
				,px_Line_Adj_Att_Tbl => l_Line_Adj_Att_Tbl
 			        ,px_Line_Adj_Tbl => l_Line_Adj_tbl
                                ,px_line_adj_assoc_tbl => l_line_adj_assoc_tbl
                                 );
		END IF;



	End If;
If
		l_Line_Adj_tbl.count > 0 or
		l_Line_Adj_att_tbl.count > 0
Then

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


    --  Call OE_Order_PVT.Process_order

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'BEFORE OE_ORDER_PVT.PROCESS_ORDER'||L_LINE_ADJ_TBL.COUNT , 1 ) ;
	END IF ;

   OE_Globals.G_PRICING_RECURSION := 'Y';

    OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => l_x_msg_count
    ,   x_msg_data                    => l_x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_Line_Adj_tbl              => l_Line_Adj_tbl
    ,   p_x_Line_Adj_att_tbl          => l_Line_Adj_att_tbl
--  ,   x_header_rec                  => l_x_header_rec
    ,   p_x_header_rec                => l_header_rec
    ,   p_x_Header_Adj_tbl            => l_x_Header_Adj_tbl
    ,   p_x_header_price_att_tbl      => l_x_header_price_att_tbl
    ,   p_x_Header_Adj_att_tbl        => l_x_Header_Adj_att_tbl
    ,   p_x_Header_Adj_Assoc_tbl      => l_x_Header_Adj_Assoc_tbl
    ,   p_x_Header_Scredit_tbl        => l_x_Header_Scredit_tbl
--serla begin
    ,   p_x_Header_Payment_tbl          => l_x_Header_Payment_tbl
--serla end
--  ,   p_x_line_tbl                  => l_x_line_tbl
    ,   p_x_line_tbl                  => l_line_tbl
 -- ,   x_Line_Adj_tbl                => l_x_Line_Adj_tbl
    ,   p_x_Line_Price_att_tbl        => l_x_Line_Price_att_tbl
 -- ,   x_Line_Adj_att_tbl            => l_x_Line_Adj_att_tbl
 -- ,   x_Line_Adj_Assoc_tbl          => l_x_Line_Adj_Assoc_tbl
    ,   p_x_Line_Adj_Assoc_tbl        => l_Line_Adj_Assoc_tbl
    ,   p_x_Line_Scredit_tbl          => l_x_Line_Scredit_tbl
--serla begin
    ,   p_x_Line_Payment_tbl            => l_x_Line_Payment_tbl
--serla end
    ,   p_x_Lot_Serial_tbl            => l_x_Lot_Serial_Tbl
    ,   p_x_action_request_tbl        => l_x_Action_Request_tbl
    );

  OE_Globals.G_PRICING_RECURSION := 'N';


  End If;

	IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXITING OE_LINE_ADJ_UTIL.COPY_ADJUSTMENT_LINES' , 1 ) ;
	END IF;

	Exception
	    WHEN FND_API.G_EXC_ERROR THEN
		  x_return_status := FND_API.G_RET_STS_ERROR;

		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  G_PKG_NAME||':COPY_ADJUSTMENT_LINES:'||SQLERRM ) ;
                        END IF;

end copy_adjustment_lines;

/* Start AuditTrail */
PROCEDURE Pre_Write_Process
   (  p_x_line_adj_rec IN OUT NOCOPY OE_ORDER_PUB.line_adj_rec_type,
      p_old_line_adj_rec IN OE_ORDER_PUB.line_adj_rec_type := OE_ORDER_PUB.G_MISS_LINE_ADJ_REC)  IS
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
          IF p_x_line_adj_rec.change_reason_code <> FND_API.G_MISS_CHAR THEN
              OE_GLOBALS.G_REASON_TYPE := 'CHANGE_CODE';
              OE_GLOBALS.G_REASON_CODE := p_x_line_adj_rec.change_reason_code;
              OE_GLOBALS.G_REASON_COMMENTS := p_x_line_adj_rec.change_reason_text;
              OE_GLOBALS.G_CAPTURED_REASON := 'Y';
          ELSE
              if l_debug_level > 0 then
                 OE_DEBUG_PUB.add('Reason code for versioning is missing or invalid', 1);
              end if;
              --bug 3775971
              if OE_GLOBALS.G_UI_FLAG AND
                (OE_GLOBALS.G_PRICING_RECURSION = 'Y' OR
                 OE_GLOBALS.G_RECURSION_MODE = 'Y') then
                 raise FND_API.G_EXC_ERROR;
              end if;
          END IF;
       END IF;

       --log delayed request
        oe_debug_pub.add('log versioning request',1);
          OE_Delayed_Requests_Pvt.Log_Request(p_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                                   p_entity_id => p_x_line_adj_rec.header_id,
                                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE_ADJ,
                                   p_requesting_entity_id => p_x_line_adj_rec.price_adjustment_id,
                                   p_request_type => OE_GLOBALS.G_VERSION_AUDIT,
                                   x_return_status => l_return_status);
     END IF;

if (p_x_line_adj_rec.operation  = OE_GLOBALS.G_OPR_UPDATE) then

   IF OE_GLOBALS.G_AUDIT_REASON_RQD_FLAG = 'Y' OR
	 OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG = 'Y' THEN

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CALL TO RECORD LINE PRICE ADJ HISTORY' , 5 ) ;
      END IF;
     IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
          OE_Versioning_Util.Capture_Audit_Info(p_entity_code => OE_GLOBALS.G_ENTITY_LINE_ADJ,
                                           p_entity_id => p_x_line_adj_rec.price_adjustment_id,
                                           p_hist_type_code =>  'UPDATE');
           --log delayed request
             OE_Delayed_Requests_Pvt.Log_Request(p_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                                   p_entity_id => p_x_line_adj_rec.header_id,
                                   p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE_ADJ,
                                   p_requesting_entity_id => p_x_line_adj_rec.price_adjustment_id,
                                   p_request_type => OE_GLOBALS.G_VERSION_AUDIT,
                                   x_return_status => l_return_status);
          OE_GLOBALS.G_AUDIT_HISTORY_RQD_FLAG := 'N';
     ELSE
      OE_CHG_ORDER_PVT.RecordLPAdjHist
      ( p_line_adj_id => p_x_line_adj_rec.price_adjustment_id,
        p_line_adj_rec => null,
        p_hist_type_code => 'UPDATE',
        p_reason_code => p_x_line_adj_rec.change_reason_code,
        p_comments => p_x_line_adj_rec.change_reason_text,
        p_wf_activity_code => null,
        p_wf_result_code => null,
        x_return_status => l_return_status );
     END IF;

   END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(  'INSERT INTO LINE PRICE ADJUSTMENTS AUDIT HISTORY CAUSED ERROR' , 1 ) ;
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

Function Is_Pricing_Related_Change(p_new_line_rec In Oe_Order_Pub.Line_Rec_Type,
                                   p_old_line_rec   In Oe_Order_Pub.Line_Rec_Type) Return Boolean As
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   Begin

       IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  ' Check if any pricing related changes has occured' ) ;
       END IF;

       IF NOT OE_GLOBALS.Equal(p_new_line_rec.agreement_id,p_old_line_rec.agreement_id)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.cust_po_number,p_old_line_rec.cust_po_number)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.inventory_item_id,p_old_line_rec.inventory_item_id)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.invoice_to_org_id,p_old_line_rec.invoice_to_org_id)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.ordered_item_id,p_old_line_rec.ordered_item_id)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.ordered_item,p_old_line_rec.ordered_item)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.line_category_code,p_old_line_rec.line_category_code)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.line_type_id,p_old_line_rec.line_type_id)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.ordered_quantity,p_old_line_rec.ordered_quantity)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.order_quantity_uom,p_old_line_rec.order_quantity_uom)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.payment_term_id,p_old_line_rec.payment_term_id)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.price_list_id,p_old_line_rec.price_list_id)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.pricing_date,p_old_line_rec.pricing_date)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.pricing_quantity,p_old_line_rec.pricing_quantity)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.pricing_quantity_uom,p_old_line_rec.pricing_quantity_uom)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.request_date,p_old_line_rec.request_date)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.ship_to_org_id,p_old_line_rec.ship_to_org_id)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.sold_to_org_id,p_old_line_rec.sold_to_org_id)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.unit_selling_price,p_old_line_rec.unit_selling_price)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.service_start_date,p_old_line_rec.service_start_date)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.service_end_date,p_old_line_rec.service_end_date)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.service_duration,p_old_line_rec.service_duration)
       OR NOT OE_GLOBALS.Equal(p_new_line_rec.service_period,p_old_line_rec.service_period)
       --Bug 4332307
       OR (
           ((p_new_line_rec.unit_list_price IS NOT NULL AND
             p_new_line_rec.unit_list_price <> FND_API.G_MISS_NUM AND
             p_new_line_rec.unit_list_price <> p_old_line_rec.unit_list_price)
            OR
             (p_new_line_rec.unit_list_price IS NULL))
           AND
            p_old_line_rec.unit_list_price IS NOT NULL AND
            p_old_line_rec.unit_list_price <> FND_API.G_MISS_NUM AND
            p_new_line_rec.original_list_price  IS NOT NULL AND
            p_new_line_rec.original_list_price <> FND_API.G_MISS_NUM AND
            p_new_line_rec.Ordered_Quantity <> fnd_api.g_miss_num and
            p_new_line_rec.order_quantity_uom is not null and
            p_new_line_rec.order_quantity_uom <> fnd_api.g_miss_char
            AND oe_code_control.code_release_level >= '110510'
            AND nvl(fnd_profile.value('ONT_LIST_PRICE_OVERRIDE_PRIV'), 'NONE') = 'UNLIMITED'
            AND  OE_GLOBALS.G_UI_FLAG
            AND  OE_Globals.G_PRICING_RECURSION = 'N'
          )
       --Bug 4332307

    Then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  ' PRICING RELATED FIELDS HAS CHANGED' ) ;
         END IF;
         Return True;

    Else
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  ' NO pricing related Fields Has Changed' ) ;
         END IF;
         Return False;
    End If;


   End;

/* 1503357 - Delete all PRG lines associated with a particular line */
Procedure Delete_PRG_Lines(p_line_id In Number, p_operation In Varchar2) Is

  -- Get all PRG lines
  Cursor prg_lines is
   select adj1.line_id, assoc.rltd_price_adj_id
   from oe_price_adjustments adj1,
	oe_price_adj_assocs  assoc,
	oe_price_adjustments adj2,
        oe_order_lines_all line
   where adj1.price_adjustment_id = assoc.rltd_price_adj_id AND
	 assoc.price_adjustment_id = adj2.price_adjustment_id AND
	 adj2.list_line_type_code = 'PRG' AND
	 adj1.line_id = line.line_id AND   /*Added for bug 4018279*/
         line.open_flag = 'Y' AND
	 adj2.line_id = p_line_id;


  Cursor prg_adjs is
       select price_adjustment_id
        from oe_price_adjustments
        where line_id = p_line_id AND list_line_type_code = 'PRG';

  /* Variables to call process order */
  l_line_tbl                         OE_ORDER_PUB.Line_Tbl_Type;
  l_old_line_tbl		     OE_ORDER_PUB.Line_Tbl_Type;
  l_control_rec                      OE_GLOBALS.Control_Rec_Type;
  l_line_rec			     OE_Order_PUB.Line_Rec_Type;
  x_return_status	             Varchar2(1);
  l_prg_line_id	                     NUMBER;
  l_price_adj_id		     NUMBER;
  l_delete_prg                       varchar2(1);
  l_dummy                            NUMBER;
  l_rltd_price_adj_id                NUMBER;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
  l_reason_code VARCHAR2(30);
  l_reason_comments VARCHAR2(2000);
  l_captured_reason varchar2(1);

  Begin
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OEXULADB.DELETE_PRG_LINES WITH LINE_ID = ' || P_LINE_ID ) ;
   END IF;
  if l_debug_level > 0 then
    oe_debug_pub.add('reason:'||OE_GLOBALS.G_REASON_CODE,3);
    oe_debug_pub.add('captured:'||OE_GLOBALS.G_captured_reason,3);
    oe_debug_pub.add('audit:'||OE_GLOBALS.G_version_audit,3);
   end if;
  l_reason_code := OE_GLOBALS.G_REASON_CODE;
   l_reason_comments := OE_GLOBALS.G_REASON_COMMENTS;
   l_captured_reason := OE_GLOBALS.G_CAPTURED_REASON;
   OPEN prg_lines;
   FETCH prg_lines into l_prg_line_id, l_rltd_price_adj_id;
   WHILE prg_lines%FOUND Loop
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'PRG LINE ID = ' || L_PRG_LINE_ID ) ;
        END IF;
        OE_LINE_UTIL.QUERY_ROW(p_line_id => l_prg_line_id,
	                       x_line_rec => l_line_rec);

	l_old_line_tbl(1) := l_line_rec;

      if (l_line_rec.booked_flag <> 'Y') Then

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ORDER NOT BOOKED' ) ;
	END IF;
	l_line_rec.operation := OE_GLOBALS.G_OPR_DELETE;

      else
	if (l_line_rec.shipped_quantity is NULL) Then
	  IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(  'BOOKED ORDER , LINE NOT SHIPPED' ) ;
	  END IF;
          if (p_operation = OE_GLOBALS.G_OPR_DELETE) Then
            -- bug 2756288, if buy line can be deleted, so can get line
            l_line_rec.operation := OE_GLOBALS.G_OPR_DELETE;
          else
	    l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
	    l_line_rec.ordered_quantity := 0;
	    l_line_rec.pricing_quantity := 0;
          end if;
	else
	  IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(  'BOOKED ORDER , SHIPPED LINE' ) ;
	  END IF;
	  l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
	  l_line_rec.calculate_price_flag := 'Y';
	end if;
      end if;
	 l_line_rec.change_reason := 'SYSTEM';
	 l_line_rec.change_comments := 'REPRICING';

      for i in prg_adjs LOOP
        -- Delete PRG adjustment record and the association
        -- between the buy line and the get line
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'PRICE ADJ ID = ' || I.PRICE_ADJUSTMENT_ID ) ;
        END IF;
        OE_LINE_ADJ_UTIL.DELETE_ROW(p_price_adjustment_id => i.price_adjustment_id);

        DELETE FROM OE_PRICE_ADJ_ASSOCS WHERE PRICE_ADJUSTMENT_ID = i.price_adjustment_id;
       END LOOP;
        BEGIN
          l_delete_prg := 'N';
          SELECT price_adj_assoc_id INTO l_dummy from oe_price_adj_assocs
          WHERE rltd_price_adj_id = l_rltd_price_adj_id and rownum < 2;
          exception
            WHEN NO_DATA_FOUND THEN
             l_delete_prg := 'Y';
         END;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ASSOC ID:'||L_DUMMY ) ;
         END IF;

      IF (l_delete_prg = 'Y') THEN
	-- Call Process Order
	l_control_rec.controlled_operation := TRUE;
	l_control_rec.check_security	   := TRUE;
    	l_control_rec.clear_dependents 	   := TRUE;
	l_control_rec.default_attributes   := TRUE;
	l_control_rec.change_attributes	   := TRUE;
	l_control_rec.validate_entity	   := TRUE;
    	l_control_rec.write_to_DB          := TRUE;
    	l_control_rec.process              := FALSE;

        l_line_tbl(1) 	          := l_line_rec;

	Oe_Order_Pvt.Lines
	(    p_validation_level			=> FND_API.G_VALID_LEVEL_NONE
	,	p_control_rec			=> l_control_rec
	,	p_x_line_tbl			=> l_line_tbl
	,	p_x_old_line_tbl		=> l_old_line_tbl
	,       x_return_status                 => x_return_status
	);

         OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := TRUE;
       END IF;
      FETCH prg_lines into l_prg_line_id, l_rltd_price_adj_id;
   End Loop;
   CLOSE prg_lines;
  if l_debug_level > 0 then
    oe_debug_pub.add('reason:'||OE_GLOBALS.G_REASON_CODE,3);
    oe_debug_pub.add('captured:'||OE_GLOBALS.G_captured_reason,3);
    oe_debug_pub.add('audit:'||OE_GLOBALS.G_version_audit,3);
   end if;
   OE_GLOBALS.G_REASON_CODE := l_reason_code;
   OE_GLOBALS.G_REASON_COMMENTS := l_reason_comments;
   OE_GLOBALS.G_CAPTURED_REASON := l_captured_reason;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING OEXULADB.DELETE_PRG_LINES' ) ;
   END IF;
  EXCEPTION
    WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXCEPTION IN DELETE_PRG_LINES'||SQLERRM , 3 ) ;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  End Delete_PRG_Lines;

Procedure Check_Canceled_PRG(p_old_line_rec in Oe_Order_Pub.line_rec_type,
                             p_new_line_rec in Oe_Order_Pub.line_rec_type) Is
                             --
                             l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
                             --
Begin

IF p_new_line_rec.operation = OE_GLOBALS.G_OPR_DELETE OR NOT OE_GLOBALS.EQUAL(p_new_line_rec.ordered_quantity, p_old_line_rec.ordered_quantity) Then
       IF (nvl(p_new_line_rec.booked_flag, 'X') <> 'Y') Then
        IF (p_new_line_rec.operation = OE_GLOBALS.G_OPR_DELETE OR p_new_line_rec.ordered_quantity = 0) Then
  	  IF l_debug_level  > 0 THEN
  	      oe_debug_pub.add(  'OPEN ORDER , ORDERED QTY CHANGED TO ZERO , DELETE ALL PRG LINES' ) ;
  	  END IF;
 	  Delete_PRG_Lines(p_new_line_rec.line_id, p_new_line_rec.operation);
        END IF;
      ELSE
	IF (p_new_line_rec.ordered_quantity = 0 AND
	  (p_new_line_rec.change_reason is NOT NULL OR
	      p_new_line_rec.change_reason <> FND_API.G_MISS_CHAR))
        OR p_new_line_rec.operation = OE_GLOBALS.G_OPR_DELETE Then
  	     IF l_debug_level  > 0 THEN
  	         oe_debug_pub.add(  'BOOKED ORDER , ORDERED QTY CHANGED TO ZERO , DELETE ALL PRG LINES' ) ;
  	     END IF;
	     Delete_PRG_Lines(p_new_line_rec.line_id, p_new_line_rec.operation);
        END IF;
      END IF;
     End if;
EXCEPTION
  WHEN OTHERS THEN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXCEPTION IN CHECK_CANCELED_PRG'||SQLERRM , 3 ) ;
  END IF;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
End Check_Canceled_PRG;

------------------------------------------------------------------------------------
--Called from OEXULINB.pls apply_attribute_changes to check is a repricing is required
--Not yet fully implemented. Will work in when getting the lock of OEXULINB.pls
------------------------------------------------------------------------------------
Procedure Process_Pricing (p_x_new_line_rec In OUT Nocopy Oe_Order_Pub.Line_Rec_Type,
                           p_old_line_rec   In Oe_Order_Pub.Line_Rec_Type,
                           p_no_price_flag  In Boolean) Is

l_price_flag                 Varchar2(1):='Y';
l_charges_for_included_item  VARCHAR2(1):=NVL(FND_PROFILE.VALUE('ONT_CHARGES_FOR_INCLUDED_ITEM'),'N');
l_return_status              VARCHAR2(10);
l_pricing_related_changes    Boolean :=False;
l_margin_related_changes     Boolean :=False;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_LINE_ADJ_UTIL.PROCESS_PRICING CALLED FROM ULINB' ) ;
    END IF;

    IF NOT OE_GLOBALS.Equal(p_x_new_line_rec.cancelled_quantity,p_old_line_rec.cancelled_quantity)
           and p_x_new_line_rec.cancelled_quantity > 0
    Then
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  ' USER CANCELS LINE , CANCELLED QUANTITY:'||P_X_NEW_LINE_REC.CANCELLED_QUANTITY ) ;
       END IF;

       --bug7491829 added p_ordered_quantity
       Process_Cancelled_Lines(p_x_new_line_rec=>p_x_new_line_rec,
                               p_ordered_quantity => p_old_line_rec.ordered_quantity);
    End If;

    IF  Is_Pricing_Related_Change(p_new_line_rec => p_x_new_line_rec,
                                   p_old_line_rec  => p_old_line_rec)
    THEN
         l_pricing_related_changes := True;
    End If;


  IF     NOT OE_GLOBALS.Equal(p_x_new_line_rec.unit_cost,p_old_line_rec.unit_cost)
  Then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  ' BOOKED FLAG OR UNIT COST CHANGES' ) ;
         END IF;
         l_margin_related_changes := True;
  End If;


  IF l_pricing_related_changes THEN
        Register_Changed_Lines(p_line_id   => p_x_new_line_rec.line_id,
                                p_header_id => p_x_new_line_rec.header_id,
                                p_operation => p_x_new_line_rec.operation);

     --bug 2965218
        If G_GROUP_PRICING_DSP IS NULL and p_x_new_line_rec.source_document_type_id = 5 Then
	    G_GROUP_PRICING_DSP := nvl(fnd_profile.value('ONT_GRP_PRICE_FOR_DSP'),'N');
        End If;
	if p_x_new_line_rec.source_document_type_id = 5 and G_GROUP_PRICING_DSP = 'N' Then
           If nvl(G_SEND_ALL_LINES_FOR_DSP,'N') <> 'Y' Then
              G_SEND_ALL_LINES_FOR_DSP := 'N';
           End If;
        else
            G_SEND_ALL_LINES_FOR_DSP := 'Y';
        end if;
       If l_debug_level > 0 Then
          oe_debug_pub.add('G_GROUP_PRICING_DSP = '||G_GROUP_PRICING_DSP);
       End If;

	If G_CODE_RELEASE_LEVEL IS NULL THEN
	   G_CODE_RELEASE_LEVEL := OE_CODE_CONTROL.CODE_RELEASE_LEVEL;
	End If;

       If l_debug_level > 0 Then
          oe_debug_pub.add('G_CODE_RELEASE_LEVEL = '||G_CODE_RELEASE_LEVEL);
       End If;

       if p_x_new_line_rec.ordered_quantity2 is not null and G_CODE_RELEASE_LEVEL < '110509' Then
          G_OPM_ITEM_CATCHWEIGHT_USED := 'Y';
       End If;
  END IF;


  IF  (l_margin_related_changes or l_pricing_related_changes)
      AND p_x_new_line_rec.booked_flag = 'Y'  THEN
     IF OE_FEATURES_PVT.Is_Margin_Avail THEN
         --attributes affect selling price changes, we log a delayed request to
         --evaluate margin, margin_hold procedure will hold the order if
         --margin falls below a intended setup margin
        IF Oe_Sys_Parameters.Value('COMPUTE_MARGIN') <> 'N' Then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'LOGGING DELAYED REQUEST FOR MARGIN HOLD FOR BOOKED LINE_ID:'||P_X_NEW_LINE_REC.LINE_ID ) ;
         END IF;
         oe_delayed_requests_pvt.log_request(
                     p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
                     p_entity_id              => p_x_new_line_rec.header_id,

                     p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                     p_requesting_entity_id   => p_x_new_line_rec.header_id,

                     p_request_type           => 'MARGIN_HOLD',
                     x_return_status          => l_return_status);
        END IF;
     END IF;
  END IF;



--MRG BGN, performance bug 4580260 (fp of bug 4273309)
IF OE_FEATURES_PVT.Is_Margin_Avail
 AND p_x_new_line_rec.item_type_code NOT IN ('KIT','MODEL','INCLUDED','CLASS','CONFIG','OPTION') THEN
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'NEW INV ITEM ID = '||P_X_NEW_LINE_REC.INVENTORY_ITEM_ID , 1 ) ;
     oe_debug_pub.add(  'OLD INV ITEM ID = '||P_OLD_LINE_REC.INVENTORY_ITEM_ID , 1 ) ;
     oe_debug_pub.add(  'NEW SHIP_FROM_ORG_ID = '||P_X_NEW_LINE_REC.SHIP_FROM_ORG_ID , 1 ) ;
     oe_debug_pub.add(  'OLD SHIP_FROM_ORG_ID = '||P_OLD_LINE_REC.SHIP_FROM_ORG_ID , 1 ) ;
     oe_debug_pub.add(  'NEW PROJECT_ID = '||P_X_NEW_LINE_REC.PROJECT_ID , 1 ) ;
     oe_debug_pub.add(  'OLD PROJECT_ID = '||P_OLD_LINE_REC.PROJECT_ID , 1 ) ;
     oe_debug_pub.add(  'NEW ACTUAL_SHIPMENT_DATE = '||P_X_NEW_LINE_REC.ACTUAL_SHIPMENT_DATE , 1 ) ;
     oe_debug_pub.add(  'OLD ACTUAL_SHIPMENT_DATE = '||P_OLD_LINE_REC.ACTUAL_SHIPMENT_DATE , 1 ) ;
     oe_debug_pub.add(  'NEW FULFILLMENT_DATE = '||P_X_NEW_LINE_REC.FULFILLMENT_DATE , 1 ) ;
     oe_debug_pub.add(  'OLD FULFILLMENT_DATE = '||P_OLD_LINE_REC.FULFILLMENT_DATE , 1 ) ;
     oe_debug_pub.add(  'NEW PRICING_DATE = '||P_X_NEW_LINE_REC.PRICING_DATE , 1 ) ;
     oe_debug_pub.add(  'OLD PRICING_DATE = '||P_OLD_LINE_REC.PRICING_DATE , 1 ) ;
 END IF;

   IF NOT OE_GLOBALS.Equal(p_x_new_line_rec.inventory_item_id,p_old_line_rec.inventory_item_id)
      OR NOT OE_GLOBALS.Equal(p_x_new_line_rec.ship_from_org_id,p_old_line_rec.ship_from_org_id)
      OR NOT OE_GLOBALS.Equal(p_x_new_line_rec.project_id,p_old_line_rec.project_id)
      OR NOT OE_GLOBALS.Equal(p_x_new_line_rec.actual_shipment_date,p_old_line_rec.actual_shipment_date)
      OR NOT OE_GLOBALS.Equal(p_x_new_line_rec.fulfillment_date,p_old_line_rec.fulfillment_date)
      OR NOT OE_GLOBALS.Equal(p_x_new_line_rec.pricing_date,p_old_line_rec.pricing_date)
    THEN
        IF Oe_Sys_Parameters.Value('COMPUTE_MARGIN') <> 'N' Then
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'BEFORE OE_DELAYED_REQUESTS_PVT.LOG_REQUEST CALL' ) ;
             oe_debug_pub.add(  'IN PROCESS_PRICING OEXULADB.PLS' ) ;
         END IF;

           oe_delayed_requests_pvt.log_request(
                       p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
                       p_entity_id              => p_x_new_line_rec.line_id,
                       p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,

                       p_requesting_entity_id   => p_x_new_line_rec.line_id,
                       p_request_type           => 'GET_COST',
                       x_return_status          => l_return_status);
        END IF;
     END IF;

END IF;
--MRG END

l_pricing_related_changes  :=False;
l_margin_related_changes   :=False;
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'LEAVING OE_LINE_ADJ_UTIL.PROCESS_PRICING' ) ;
END IF;
End Process_Pricing;

Procedure Log_Pricing_Requests (p_x_new_line_rec in Out Nocopy Oe_Order_Pub.Line_Rec_Type,
                                p_old_line_rec in Oe_Order_Pub.Line_Rec_Type,
                                p_no_price_flag  Boolean  Default False,
                                p_price_flag     Varchar2 Default 'Y') Is

 l_zero_line_qty     Boolean :=FALSE;
 l_price_control_rec QP_PREQ_GRP.control_record_type;
 l_x_line_tbl        Oe_Order_Pub.Line_Tbl_Type;
 l_return_status     Varchar2(5);
 i PLS_INTEGER;
 l_x_result_out      Varchar2(5);
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
Begin

       IF p_price_flag = 'Y' and
		not p_no_price_flag  and
		nvl(oe_globals.g_pricing_recursion,'N') <> 'Y' and
		p_x_new_line_rec.Ordered_Quantity <> fnd_api.g_miss_num and
		p_x_new_line_rec.order_quantity_uom is not null and
		p_x_new_line_rec.order_quantity_uom <> fnd_api.g_miss_char
	THEN
                --bsadri for cancelled lines l_zero_line_qty is true

                IF nvl(p_x_new_line_rec.ordered_quantity,0) = 0 THEN
                    l_zero_line_qty := TRUE;
                ELSE
                    l_zero_line_qty := FALSE;
                END IF;
		If
		( (p_x_new_line_rec.unit_list_price is null or
		  p_x_new_line_rec.Unit_List_Price = fnd_api.g_miss_num or
		  NOT OE_GLOBALS.Equal(p_x_new_line_rec.ordered_quantity,p_old_line_rec.ordered_quantity) or
		  NOT OE_GLOBALS.Equal(p_x_new_line_rec.cancelled_Quantity,p_old_line_rec.cancelled_Quantity) or
		   NOT OE_GLOBALS.Equal(p_x_new_line_rec.order_quantity_uom,p_old_line_rec.order_quantity_uom) or
		   NOT OE_GLOBALS.Equal(p_x_new_line_rec.inventory_item_id,p_old_line_rec.inventory_item_id) )  --fix bug 1388503 btea
                  and p_x_new_line_rec.item_type_code <> OE_GLOBALS.G_ITEM_SERVICE
		   )
	   then


               IF ((OE_GLOBALS.G_UI_FLAG) and (nvl(Oe_Config_Pvt.oecfg_configuration_pricing,'N')='N'))
               THEN

          	        l_Price_Control_Rec.pricing_event := 'PRICE';
			l_Price_Control_Rec.calculate_flag := QP_PREQ_GRP.G_SEARCH_N_CALCULATE;
			l_Price_Control_Rec.Simulation_Flag := 'N';

			l_x_line_tbl(1) := p_x_new_line_rec;
                        IF NOT l_zero_line_qty THEN
                         --bsadri call the Price_line for non-cancelled lines
			  oe_order_adj_pvt.Price_line(
				X_Return_Status     => l_Return_Status
				,p_Line_id          => p_x_new_line_rec.line_id
				,p_Request_Type_code=> 'ONT'
				,p_Control_rec      => l_Price_Control_Rec
				,p_Write_To_Db		=> FALSE
				,x_Line_Tbl		=> l_x_Line_Tbl
				);

			   -- Populate Line_rec
			    i:= l_x_Line_Tbl.First;
			    While i is not null loop
				  p_x_new_line_rec := l_x_Line_Tbl(i);
				  i:= l_x_Line_Tbl.Next(i);
			    End Loop;
                         END IF;
	   End If;
        End If;  --end if for UI Flag Check

	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'LOGGING DELAYED REQUEST FOR PRICING' ) ;
	   END IF;

        IF ((OE_GLOBALS.G_UI_FLAG) and (nvl(Oe_Config_Pvt.oecfg_configuration_pricing,'N')='N')) OR
            p_x_new_line_rec.item_type_code = 'INCLUDED' THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'UI MODE OR CONFIG , INCLUDED ITEM'||P_X_NEW_LINE_REC.LINE_ID ) ;
          END IF;
          IF NOT l_zero_line_qty THEN
             --bsadri don't call this for a cancelled line
            OE_delayed_requests_Pvt.log_request(
				p_entity_code 			=> OE_GLOBALS.G_ENTITY_LINE,
				p_entity_id         	=> p_x_new_line_rec.line_id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
				p_requesting_entity_id   => p_x_new_line_rec.line_id,
				p_request_unique_key1  	=> 'LINE',
		 		p_param1                 => p_x_new_line_rec.header_id,
                 		p_param2                 => 'LINE',
		 		p_request_type           => OE_GLOBALS.G_PRICE_LINE,
		 		x_return_status          => l_return_status);

         END IF;
         IF p_x_new_line_rec.item_type_code <> 'INCLUDED' THEN
           OE_delayed_requests_Pvt.log_request(
				p_entity_code 			=> OE_GLOBALS.G_ENTITY_ALL,
				p_entity_id         	=> p_x_new_line_rec.Header_Id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
				p_requesting_entity_id   => p_x_new_line_rec.Header_Id,
				p_request_unique_key1  	=> 'ORDER',
		 		p_param1                 => p_x_new_line_rec.header_id,
                 		p_param2                 => 'ORDER',
		 		p_request_type           => OE_GLOBALS.G_PRICE_ORDER,
		 		x_return_status          => l_return_status);
          END IF;
        ELSE
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'BATCH MODE' ) ;
          END IF;

          OE_delayed_requests_Pvt.log_request(
				p_entity_code 			=> OE_GLOBALS.G_ENTITY_ALL,
				p_entity_id         	=> p_x_new_line_rec.Header_Id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
				p_requesting_entity_id   => p_x_new_line_rec.Header_Id,
				p_request_unique_key1  	=> 'BATCH',
		 		p_param1                 => p_x_new_line_rec.header_id,
                 		p_param2                 => 'BATCH',
		 		p_request_type           => OE_GLOBALS.G_PRICE_ORDER,
		 		x_return_status          => l_return_status);
        END IF;

	   If p_x_new_line_rec.booked_flag='Y' and p_x_new_line_rec.item_type_code <> 'INCLUDED' Then
           OE_delayed_requests_Pvt.log_request(
				p_entity_code 		 => OE_GLOBALS.G_ENTITY_ALL,
				p_entity_id         	 => p_x_new_line_rec.Header_Id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
				p_requesting_entity_id   => p_x_new_line_rec.Header_Id,
				p_request_unique_key1  	 => 'BOOK',
		 		p_param1                 => p_x_new_line_rec.header_id,
                 		p_param2                 => 'BOOK',
		 		p_request_type           => OE_GLOBALS.G_PRICE_ORDER,
		 		x_return_status          => l_return_status);
	   End If;

     END IF;

	/* rlanka: Fix for Bug 1729372

            For the new line that is created by Promotional modifier
            need to log a delayed request to PRICE_LINE again to apply
	    freight charges.

         */

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'PRICE_FLAG = ' || P_PRICE_FLAG ) ;
            oe_debug_pub.add(  'G_PRICING_RECURSION = ' || OE_GLOBALS.G_PRICING_RECURSION ) ;
            oe_debug_pub.add(  'ORDERED QUANTITY = '|| TO_CHAR ( P_X_NEW_LINE_REC.ORDERED_QUANTITY ) ) ;
            oe_debug_pub.add(  'ORDERED QTY UOM = ' || P_X_NEW_LINE_REC.ORDER_QUANTITY_UOM ) ;
            oe_debug_pub.add(  'CALCULATE_PRICE_FLAG = '|| P_X_NEW_LINE_REC.CALCULATE_PRICE_FLAG ) ;
        END IF;


	 if (p_price_flag = 'Y' and
            not p_no_price_flag and
            oe_globals.g_pricing_recursion = 'Y' and
            nvl(p_x_new_line_rec.ordered_quantity,0) <> 0 and
            p_x_new_line_rec.Ordered_Quantity <> fnd_api.g_miss_num and
            p_x_new_line_rec.order_quantity_uom is not null and
            p_x_new_line_rec.order_quantity_uom <> fnd_api.g_miss_char and
            p_x_new_line_rec.calculate_price_flag = 'R')
        then

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'NEW LINE CREATED BY PROMOTIONAL MODIFIER' ) ;
                oe_debug_pub.add(  'RESETTING CALC. PRICE. FLAG TO P' ) ;
            END IF;
            p_x_new_line_rec.calculate_price_flag := 'P';
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'LOGGING A REQUEST TO PRICE_LINE IN BATCH MODE' ) ;
            END IF;
            OE_delayed_requests_Pvt.log_request(
				p_entity_code           =>OE_GLOBALS.G_ENTITY_ALL,
                                p_entity_id             => p_x_new_line_rec.line_Id,
                                p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                                p_requesting_entity_id   => p_x_new_line_rec.line_Id,
                                p_request_unique_key1   => 'BATCH',
                                p_param1                 => p_x_new_line_rec.header_id,
                                p_param2                 => 'BATCH',
                                p_request_type           => OE_GLOBALS.G_PRICE_LINE,
                                x_return_status          => l_return_status);

          if (p_x_new_line_rec.booked_flag = 'Y')
          then
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'BOOKED ORDER -- LOG A REQUEST TO PRICE LINE' ) ;
             END IF;
             OE_delayed_requests_Pvt.log_request(
                                p_entity_code           =>OE_GLOBALS.G_ENTITY_ALL,
                                p_entity_id             => p_x_new_line_rec.line_Id,
                                p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
                                p_requesting_entity_id   => p_x_new_line_rec.line_Id,
                                p_request_unique_key1   => 'BOOK',
                                p_param1                 => p_x_new_line_rec.header_id,
                                p_param2                 => 'BOOK',
                                p_request_type           => OE_GLOBALS.G_PRICE_LINE,
                                x_return_status          => l_return_status);
          end if; -- if order is BOOKED

        end if; -- if new line created by Promotional modifier needs to be re-priced.

        -- end of fix for bug 1729372

	If NOT OE_GLOBALS.Equal(p_x_new_line_rec.Shipped_Quantity,p_old_line_rec.Shipped_Quantity)
	Then
           --btea
           IF p_x_new_line_rec.line_category_code <> 'RETURN' Then
              OE_Shipping_Integration_PVT.Check_Shipment_Line(
                 p_line_rec                => p_old_line_rec
              ,  p_shipped_quantity        => p_x_new_line_rec.Shipped_Quantity
              ,  x_result_out              => l_x_result_out
              );

              IF l_x_result_out = OE_GLOBALS.G_PARTIALLY_SHIPPED THEN
               -- This line will split, set the calculate_price_flag  to 'P' if 'Y'
                IF (p_x_new_line_rec.calculate_price_flag = 'Y') THEN
                  p_x_new_line_rec.calculate_price_flag := 'P';
                END IF;


              END IF;

           Elsif p_x_new_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
                 and p_x_new_line_rec.split_by = 'SYSTEM'
                 and p_x_new_line_rec.split_action_code = 'SPLIT'
                 and p_x_new_line_rec.calculate_price_flag = 'Y' Then
                 p_x_new_line_rec.calculate_price_flag :='P';
           End If;

           OE_delayed_requests_Pvt.log_request(
				p_entity_code 		=> OE_GLOBALS.G_ENTITY_ALL,
				p_entity_id         	=> p_x_new_line_rec.line_id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
				p_requesting_entity_id   => p_x_new_line_rec.line_id,
				p_request_unique_key1  	=> 'SHIP',
		 		p_param1                 => p_x_new_line_rec.header_id,
                 		p_param2                 => 'SHIP',
		 		p_request_type           => OE_GLOBALS.G_PRICE_LINE,
		 		x_return_status          => l_return_status);
	End If;

End;


/*---------------------------------------------------------------------*/
 --Will be called by delayed request to reset cache changed line tbl
/*---------------------------------------------------------------------*/
Procedure Delete_Changed_Lines_Tbl Is
Begin
  G_CHANGED_LINE_TBL.delete;
  G_SEND_ALL_LINES_FOR_DSP := NULL;
  G_OPM_ITEM_CATCHWEIGHT_USED := NULL;
End;


/*----------------------------------------------------------------------*/
 --Process_Cancelled_Lines.  This is performance fix on cancel line
 --in which we either combine all events to call pricing engine once
 --or not calling at all depending on the output of QP_UTIL_PUB.Get_Order_Lines_Status
/*----------------------------------------------------------------------*/

Procedure Process_Cancelled_Lines(p_x_new_line_rec In Oe_Order_Pub.line_rec_type, p_ordered_quantity In Number) Is
--bug7491829 added p_ordered_quantity

l_order_status_rec QP_UTIL_PUB.ORDER_LINES_STATUS_REC_TYPE;
l_return_status Varchar2(5);
l_event_str Varchar2(25);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

       --User trying to cancle line, different processing for cancelation due to performance
       --considerations
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  ' ENTERING PROCESS_CANCELLED_LINES' ) ;
       END IF;

       ------------------------------------------------------
       --Special case, bypass regular pricing path
       --we log performant version of pricing delayed request
       ------------------------------------------------------
       OE_GLOBALS.G_PRICE_FLAG := 'N';


       QP_UTIL_PUB.Get_Order_Lines_Status('BATCH,BOOK',l_order_status_rec);
       ----------------------------------------------------------------------
       --User has totally cancelled a line, price changes pertaining to this
       --line has no effect since the quantity is 0.  Therefore, only pass
       --all the lines to pricing engine when all_lines_flag = 'Y'
       ----------------------------------------------------------------------
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  ' ALL LINES FLAG RETURNED FROM QP_UTIL_PUB:'||L_ORDER_STATUS_REC.ALL_LINES_FLAG ) ;
           oe_debug_pub.add(  ' CHANGED LINES FLAG RETURNED FROM QP_UTIL_PUB:'||L_ORDER_STATUS_REC.CHANGED_LINES_FLAG ) ;
	   oe_debug_pub.add(  ' SUMMARY LINE FLAG RETURNED FROM QP_UTIL_PUB:'||L_ORDER_STATUS_REC.SUMMARY_LINE_FLAG ) ;
       END IF;



       If p_x_new_line_rec.ordered_quantity = 0 Then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  ' USER HAS TOTALLY CANCELLED THE LINE' ) ;
          END IF;

          If p_x_new_line_rec.booked_flag = 'Y' Then
            l_event_str:= 'ORDER,BOOK';
          Else
            l_event_str:='ORDER';
          End If;

	  --FP bug 3335024 included summary line flag condition below
          If l_order_status_rec.ALL_LINES_FLAG = 'Y'  or l_order_status_rec.summary_line_flag = 'Y' Then
             IF p_x_new_line_rec.item_type_code not in ('INCLUDED','CONFIG') THEN
               OE_delayed_requests_Pvt.log_request(
				p_entity_code 		=> OE_GLOBALS.G_ENTITY_ALL,
				p_entity_id         	=> p_x_new_line_rec.Header_Id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
				p_requesting_entity_id   => p_x_new_line_rec.Header_Id,
				p_request_unique_key1  	=> 'ORDER,BOOK',
		 		p_param1                 => p_x_new_line_rec.header_id,
                 		p_param2                 => l_event_str,
		 		p_request_type           => OE_GLOBALS.G_PRICE_ORDER,
		 		x_return_status          => l_return_status);

            End If;
          End If;
          /* BUG 2013611 BEGIN */
	  IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(  'LOG REVERSE_LIMITS DELAYED REQUEST FROM PROCESS_CANCELLED_LINES ' , 1 ) ;
	  END IF;
          OE_delayed_requests_Pvt.log_request(
	                        p_entity_code 		 => OE_GLOBALS.G_ENTITY_LINE,
				p_entity_id              => p_x_new_line_rec.line_id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
				p_requesting_entity_id   => p_x_new_line_rec.line_id,
				p_request_unique_key1  	 => 'LINE',
		 		p_param1                 => 'CANCEL',
		 		p_param2                 => p_x_new_line_rec.price_request_code,
		 		p_param3                 => NULL,
		 		p_param4                 => NULL,
		 		p_param5                 => NULL,
		 		p_param6                 => NULL,
		 		p_request_type           => OE_GLOBALS.G_REVERSE_LIMITS,
		 		x_return_status          => l_return_status);
	  IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(  'REVERSE_LIMITS DELAYED REQUEST HAS BEEN LOGGED' , 1 ) ;
	  END IF;
          /* BUG 2013611 END */
       Else        --User partially cancel the line
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  ' USER HAS PARTIALLY CANCELLED THE LINE' ) ;
          END IF;


          If p_x_new_line_rec.booked_flag = 'Y' Then
            -- l_event_str:= 'LINE,ORDER,BOOK';
            -- changed 'LINE,ORDER' to 'BATCH'.
            l_event_str:= 'BATCH,BOOK';
          Else
            -- l_event_str:='LINE,ORDER';
            l_event_str:='BATCH';
          End If;

          If l_order_status_rec.ALL_LINES_FLAG = 'Y' or
             l_order_status_rec.Changed_Lines_Flag = 'Y'
          Then
             --treat changed_lines as all_lines for now, will to
             --differential this 2 type in the future
            IF p_x_new_line_rec.item_type_code not in ('INCLUDED','CONFIG') THEN
               OE_delayed_requests_Pvt.log_request(
				p_entity_code 		 => OE_GLOBALS.G_ENTITY_ALL,
				p_entity_id         	 => p_x_new_line_rec.Header_Id,
				p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
				p_requesting_entity_id   => p_x_new_line_rec.Header_Id,
				p_request_unique_key1  	 => 'BATCH,BOOK',
		 		p_param1                 => p_x_new_line_rec.header_id,
                 		p_param2                 => l_event_str,
		 		p_request_type           => OE_GLOBALS.G_PRICE_ORDER,
		 		x_return_status          => l_return_status);

             End If; --not in ('INCLUDED','CONFIG')
          End If; --ALL_LINES or Change_lines flag

         --bug7491829

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LOG REVERSE_LIMITS DELAYED REQUEST FROM
              PROCESS_CANCELLED_LINES FOR PARTIAL CANCEL CASE' , 1 ) ;
          END IF;

          OE_delayed_requests_Pvt.log_request(
                              p_entity_code            => OE_GLOBALS.G_ENTITY_LINE,
                              p_entity_id              => p_x_new_line_rec.line_id,
                              p_requesting_entity_code => OE_GLOBALS.G_ENTITY_LINE,
                              p_requesting_entity_id   => p_x_new_line_rec.line_id,
                              p_request_unique_key1    => 'LINE',
                              p_param1                 => 'AMEND',
                              p_param2                 => p_x_new_line_rec.price_request_code,
                              p_param3                 => p_ordered_quantity,
                              p_param4                 => p_x_new_line_rec.ordered_quantity,
                              p_param5                 => NULL,
                              p_param6                 => NULL,
                              p_request_type           =>OE_GLOBALS.G_REVERSE_LIMITS,
                              x_return_status          => l_return_status);

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'REVERSE_LIMITS DELAYED REQUEST HAS BEEN LOGGED' , 1 ) ;
          END IF;

       --bug7491829

       End If;

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  ' LEAVING PROCESS_CANCELLED_LINES' ) ;
 END IF;
End;

/*----------------------------------------------------------------------------*/
  --Register Changed lines in cache for performance
/*----------------------------------------------------------------------------*/
Procedure Register_Changed_Lines(p_line_id   in Number,
                                 p_header_id in Number,
                                 p_operation in Varchar2) Is
l_return_status Varchar2(15);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' ENTERING OE_LINE_ADJ_UTIL.REGISTER_CHANGED_LINES' ) ;
      oe_debug_pub.add(  ' P_LINE_ID:'||P_LINE_ID||'+P_HEADER_ID:'||P_HEADER_ID ) ;
  END IF;

  -----------------------------------------------------------------------------------
  --For performance reason, we only need to log delay request to reset the cache once
  --per saving.
  --When G_CHANGED_LINE_TBL has records, we know that the delayed request for reseting
  --the cahce has been logged; therefore, I need not log it.
  ------------------------------------------------------------------------------------
  If G_CHANGED_LINE_TBL.Count = 0 Then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' LOGGING DELAYED REQUEST TO RESET G_CHANGED_LINE_TBL' ) ;
    END IF;
    oe_delayed_requests_pvt.log_request(
		p_entity_code            => OE_GLOBALS.G_ENTITY_ALL,
		p_entity_id      	 => p_header_id,
		p_requesting_entity_code => OE_GLOBALS.G_ENTITY_ALL,
		p_requesting_entity_id   => p_header_id,
		p_request_type   	 => OE_GLOBALS.G_DEL_CHG_LINES,
		x_return_status  	 => l_return_status);
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' RETURN STATUS FROM THE DELAYED REQUEST:'||L_RETURN_STATUS ) ;
    END IF;
  End If;

  If p_operation In (OE_GLOBALS.G_OPR_CREATE,OE_GLOBALS.G_OPR_UPDATE) Then
      --bug 3020702 begin
      G_CHANGED_LINE_TBL(mod(p_line_id,G_BINARY_LIMIT)).line_id :=p_line_id;
      G_CHANGED_LINE_TBL(mod(p_line_id,G_BINARY_LIMIT)).header_id :=p_header_id;
      --bug 3020702 end
  Elsif p_operation = OE_GLOBALS.G_OPR_DELETE Then
    If G_CHANGED_LINE_TBL.exists(mod(p_line_id,G_BINARY_LIMIT)) Then
       G_CHANGED_LINE_TBL.delete(mod(p_line_id,G_BINARY_LIMIT));
    End If;
  End If;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' LEAVING OE_LINE_ADJ_UTIL.REGISTER_CHANGED_LINES' ) ;
  END IF;
End;

Procedure Get_Service_Lines(p_header_id   IN NUMBER,
                            x_line_id_tbl OUT NOCOPY OE_ORDER_ADJ_PVT.Index_TBL_TYPE) IS
Cursor get_service_cur IS
Select line_id,
       service_reference_line_id
From   oe_order_lines_all
Where  header_id = p_header_id
And    service_reference_line_id IS NOT NULL;

Begin
  For J in get_service_cur Loop
     x_line_id_tbl(MOD(J.service_reference_line_id,G_BINARY_LIMIT)):=J.line_id;                      -- Bug 8631297
  End Loop;
End;

/* Added the following procedure to fix the bug 2917690 */

Procedure Change_adj_for_uom_change(p_x_line_rec    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
                                     ) Is
l_return_status Varchar2(15);
l_old_pricing_qty               NUMBER;
l_new_pricing_qty               NUMBER;

Begin
  Oe_Debug_Pub.add(' Entering OE_LINE_ADJ_UTIL.Change_adj_for_uom_change');

  IF  p_x_line_rec.Pricing_quantity is not null and
      p_x_line_rec.Pricing_quantity <> FND_API.G_MISS_NUM and
      p_x_line_rec.Pricing_quantity <> 0 THEN

         l_old_pricing_qty := p_x_line_rec.Pricing_quantity ;
         l_new_pricing_qty :=
                              OE_Order_Misc_Util.convert_uom(
                                        p_x_line_rec.inventory_item_id,
                                        p_x_line_rec.order_quantity_uom,
                                        p_x_line_rec.pricing_quantity_uom,
                                        p_x_line_rec.ordered_quantity
                                                );

         -- Code changes for bug 9014929
         Oe_Debug_Pub.add('   l_old_pricing_qty = ' || l_old_pricing_qty);
         Oe_Debug_Pub.add('   l_new_pricing_qty = ' || l_new_pricing_qty);
         p_x_line_rec.Pricing_quantity := l_new_pricing_qty;
         Oe_Debug_Pub.add('   p_x_line_rec.Pricing_quantity = ' || p_x_line_rec.Pricing_quantity);
         -- End of code changes for bug 9014929

         update oe_price_adjustments
         set adjusted_amount = adjusted_amount * l_new_pricing_qty / l_old_pricing_qty
         where line_id = p_x_Line_rec.line_id
         and list_line_type_code in ('DIS','SUR')
         and applied_flag = 'Y'
         and   updated_flag = 'Y'
         and   arithmetic_operator in ('AMT' , '%' , 'NEWPRICE');

         update oe_price_adjustments
         set operand   = operand * l_new_pricing_qty / l_old_pricing_qty
         where line_id = p_x_Line_rec.line_id
         and list_line_type_code in ('DIS','SUR')
         and applied_flag = 'Y'
         and   updated_flag = 'Y'
         and   arithmetic_operator in ('AMT' , 'NEWPRICE');
  END IF;

  Oe_Debug_Pub.add(' Leaving OE_LINE_ADJ_UTIL.Change_adj_for_uom_change');
End;

/* End of the procedure added to fix the bug 2917690 */

Function has_service_lines(p_header_id IN NUMBER) Return Boolean
IS
l_dummy NUMBER;
Begin
  Select line_id
  INTO   l_dummy
  From   OE_ORDER_LINES_ALL
  Where  header_id = p_header_id
  AND    service_reference_line_id IS NOT NULL
  AND    rownum = 1;

  RETURN True;
Exception
  When NO_DATA_FOUND Then
    Return False;
End;

Procedure Set_PRG_Cache(p_header_id IN NUMBER) AS
   Cursor prg_cur is
   select adj1.line_id line_id
   from oe_price_adjustments adj1,
        oe_price_adj_assocs  assoc,
        oe_price_adjustments adj2
   where adj1.price_adjustment_id = assoc.rltd_price_adj_id AND
         assoc.price_adjustment_id = adj2.price_adjustment_id AND
         adj2.list_line_type_code = 'PRG' AND
         adj2.header_id = p_header_id;
  Begin
     /*open prg_cur;
     fetch prg_cur BULK COLLECT INTO G_PRG_TBL;
     close prg_cur;*/

     FOR prg IN prg_cur LOOP
       G_PRG_TBL(MOD(prg.line_id,G_BINARY_LIMIT)):= prg.line_id;
     END LOOP;
  End;

Procedure Reset_PRG_Cache As
   Begin
      G_PRG_TBL.DELETE;
   End;

Function IS_PRG_LINE(p_line_id IN NUMBER) RETURN BOOLEAN AS
   Begin
      IF G_PRG_TBL.EXISTS(MOD(p_line_id,G_BINARY_LIMIT)) THEN
	 Return TRUE;
      ELSE
	 Return FALSE;
      END IF;
   End;

END OE_Line_Adj_Util;

/
