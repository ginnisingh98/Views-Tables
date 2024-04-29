--------------------------------------------------------
--  DDL for Package Body ASO_ORDER_FEEDBACK_GET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_ORDER_FEEDBACK_GET_PVT" AS
/* $Header: asovomgb.pls 120.1.12010000.4 2015/08/03 18:49:18 vidsrini ship $ */


-- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------
G_PKG_NAME CONSTANT VARCHAR2(30) := 'ASO_ORDER_FEEDBACK_GET_PVT';
G_USER CONSTANT VARCHAR2(30) := FND_GLOBAL.USER_ID;


-- ---------------------------------------------------------
-- Define Procedures
-- ---------------------------------------------------------

--------------------------------------------------------------------------
-- Header

PROCEDURE Header_Type_To_Rec
(
    p_header_type               IN     SYSTEM.ASO_Header_Type,
    x_header_rec    	        OUT NOCOPY /* file.sql.39 change */       OE_Order_PUB.Header_Rec_Type
)
IS

BEGIN
  IF p_header_type is NULL THEN
     x_header_rec := OE_Order_PUB.G_MISS_HEADER_REC;
     return;
  END IF;

  x_header_rec.accounting_rule_id                     := p_header_type.accounting_rule_id;
  x_header_rec.agreement_id                           := p_header_type.agreement_id;
  x_header_rec.attribute1                             := p_header_type.attribute1;
  x_header_rec.attribute10                            := p_header_type.attribute10;
  x_header_rec.attribute11                            := p_header_type.attribute11;
  x_header_rec.attribute12                            := p_header_type.attribute12;
  x_header_rec.attribute13                            := p_header_type.attribute13;
  x_header_rec.attribute14                            := p_header_type.attribute14;
  x_header_rec.attribute15                            := p_header_type.attribute15;
  x_header_rec.attribute2                             := p_header_type.attribute2;
  x_header_rec.attribute3                             := p_header_type.attribute3;
  x_header_rec.attribute4                             := p_header_type.attribute4;
  x_header_rec.attribute5                             := p_header_type.attribute5;
  x_header_rec.attribute6                             := p_header_type.attribute6;
  x_header_rec.attribute7                             := p_header_type.attribute7;
  x_header_rec.attribute8                             := p_header_type.attribute8;
  x_header_rec.attribute9                             := p_header_type.attribute9;
  x_header_rec.booked_flag                            := p_header_type.booked_flag;
  x_header_rec.cancelled_flag                         := p_header_type.cancelled_flag;
  x_header_rec.context                                := p_header_type.context;
  x_header_rec.conversion_rate                        := p_header_type.conversion_rate;
  x_header_rec.conversion_rate_date                   := p_header_type.conversion_rate_date;
  x_header_rec.conversion_type_code                   := p_header_type.conversion_type_code;
  x_header_rec.created_by                             := p_header_type.created_by;
  x_header_rec.creation_date                          := p_header_type.creation_date;
  x_header_rec.cust_po_number                         := p_header_type.cust_po_number;
  x_header_rec.deliver_to_contact_id                  := p_header_type.deliver_to_contact_id;
  x_header_rec.deliver_to_org_id                      := p_header_type.deliver_to_org_id;
  x_header_rec.demand_class_code                      := p_header_type.demand_class_code;
  x_header_rec.earliest_schedule_limit                := p_header_type.earliest_schedule_limit;
  x_header_rec.expiration_date                        := p_header_type.expiration_date;
  x_header_rec.fob_point_code                         := p_header_type.fob_point_code;
  x_header_rec.freight_carrier_code                   := p_header_type.freight_carrier_code;
  x_header_rec.freight_terms_code                     := p_header_type.freight_terms_code;
  x_header_rec.global_attribute1                      := p_header_type.global_attribute1;
  x_header_rec.global_attribute10                     := p_header_type.global_attribute10;
  x_header_rec.global_attribute11                     := p_header_type.global_attribute11;
  x_header_rec.global_attribute12                     := p_header_type.global_attribute12;
  x_header_rec.global_attribute13                     := p_header_type.global_attribute13;
  x_header_rec.global_attribute14                     := p_header_type.global_attribute14;
  x_header_rec.global_attribute15                     := p_header_type.global_attribute15;
  x_header_rec.global_attribute16                     := p_header_type.global_attribute16;
  x_header_rec.global_attribute17                     := p_header_type.global_attribute17;
  x_header_rec.global_attribute18                     := p_header_type.global_attribute18;
  x_header_rec.global_attribute19                     := p_header_type.global_attribute19;
  x_header_rec.global_attribute2                      := p_header_type.global_attribute2;
  x_header_rec.global_attribute20                     := p_header_type.global_attribute20;
  x_header_rec.global_attribute3                      := p_header_type.global_attribute3;
  x_header_rec.global_attribute4                      := p_header_type.global_attribute4;
  x_header_rec.global_attribute5                      := p_header_type.global_attribute5;
  x_header_rec.global_attribute6                      := p_header_type.global_attribute6;
  x_header_rec.global_attribute7                      := p_header_type.global_attribute7;
  x_header_rec.global_attribute8                      := p_header_type.global_attribute8;
  x_header_rec.global_attribute9                      := p_header_type.global_attribute9;
  x_header_rec.global_attribute_category              := p_header_type.global_attribute_category;
  x_header_rec.TP_CONTEXT                             := p_header_type.TP_CONTEXT;
  x_header_rec.TP_ATTRIBUTE1                          := p_header_type.TP_ATTRIBUTE1;
  x_header_rec.TP_ATTRIBUTE2                          := p_header_type.TP_ATTRIBUTE2;
  x_header_rec.TP_ATTRIBUTE3                          := p_header_type.TP_ATTRIBUTE3;
  x_header_rec.TP_ATTRIBUTE4                          := p_header_type.TP_ATTRIBUTE4;
  x_header_rec.TP_ATTRIBUTE5                          := p_header_type.TP_ATTRIBUTE5;
  x_header_rec.TP_ATTRIBUTE6                          := p_header_type.TP_ATTRIBUTE6;
  x_header_rec.TP_ATTRIBUTE7                          := p_header_type.TP_ATTRIBUTE7;
  x_header_rec.TP_ATTRIBUTE8                          := p_header_type.TP_ATTRIBUTE8;
  x_header_rec.TP_ATTRIBUTE9                          := p_header_type.TP_ATTRIBUTE9;
  x_header_rec.TP_ATTRIBUTE10                         := p_header_type.TP_ATTRIBUTE10;
  x_header_rec.TP_ATTRIBUTE11                         := p_header_type.TP_ATTRIBUTE11;
  x_header_rec.TP_ATTRIBUTE12                         := p_header_type.TP_ATTRIBUTE12;
  x_header_rec.TP_ATTRIBUTE13                         := p_header_type.TP_ATTRIBUTE13;
  x_header_rec.TP_ATTRIBUTE14                         := p_header_type.TP_ATTRIBUTE14;
  x_header_rec.TP_ATTRIBUTE15                         := p_header_type.TP_ATTRIBUTE15;
  x_header_rec.header_id                              := p_header_type.header_id;
  x_header_rec.invoice_to_contact_id                  := p_header_type.invoice_to_contact_id;
  x_header_rec.invoice_to_org_id                      := p_header_type.invoice_to_org_id;
  x_header_rec.invoicing_rule_id                      := p_header_type.invoicing_rule_id;
  x_header_rec.last_updated_by                        := p_header_type.last_updated_by;
  x_header_rec.last_update_date                       := p_header_type.last_update_date;
  x_header_rec.last_update_login                      := p_header_type.last_update_login;
  x_header_rec.latest_schedule_limit                  := p_header_type.latest_schedule_limit;
  x_header_rec.open_flag                              := p_header_type.open_flag;
  x_header_rec.order_category_code                    := p_header_type.order_category_code;
  x_header_rec.ordered_date                           := p_header_type.ordered_date;
  x_header_rec.order_date_type_code		      := p_header_type.order_date_type_code;
  x_header_rec.order_number                           := p_header_type.order_number;
  x_header_rec.order_source_id                        := p_header_type.order_source_id;
  x_header_rec.order_type_id                          := p_header_type.order_type_id;
  x_header_rec.org_id                                 := p_header_type.org_id;
  x_header_rec.orig_sys_document_ref                  := p_header_type.orig_sys_document_ref;
  x_header_rec.partial_shipments_allowed              := p_header_type.partial_shipments_allowed;
  x_header_rec.payment_term_id                        := p_header_type.payment_term_id;
  x_header_rec.price_list_id                          := p_header_type.price_list_id;
  x_header_rec.pricing_date                           := p_header_type.pricing_date;
  x_header_rec.program_application_id                 := p_header_type.program_application_id;
  x_header_rec.program_id                             := p_header_type.program_id;
  x_header_rec.program_update_date                    := p_header_type.program_update_date;
  x_header_rec.request_date                           := p_header_type.request_date;
  x_header_rec.request_id                             := p_header_type.request_id;
  x_header_rec.return_reason_code		      := p_header_type.return_reason_code;
  x_header_rec.salesrep_id			      := p_header_type.salesrep_id;
  x_header_rec.sales_channel_code                     := p_header_type.sales_channel_code;
  x_header_rec.shipment_priority_code                 := p_header_type.shipment_priority_code;
  x_header_rec.shipping_method_code                   := p_header_type.shipping_method_code;
  x_header_rec.ship_from_org_id                       := p_header_type.ship_from_org_id;
  x_header_rec.ship_tolerance_above                   := p_header_type.ship_tolerance_above;
  x_header_rec.ship_tolerance_below                   := p_header_type.ship_tolerance_below;
  x_header_rec.ship_to_contact_id                     := p_header_type.ship_to_contact_id;
  x_header_rec.ship_to_org_id                         := p_header_type.ship_to_org_id;
  x_header_rec.sold_from_org_id			      := p_header_type.sold_from_org_id;
  x_header_rec.sold_to_contact_id                     := p_header_type.sold_to_contact_id;
  x_header_rec.sold_to_org_id                         := p_header_type.sold_to_org_id;
  x_header_rec.source_document_id                     := p_header_type.source_document_id;
  x_header_rec.source_document_type_id                := p_header_type.source_document_type_id;
  x_header_rec.tax_exempt_flag                        := p_header_type.tax_exempt_flag;
  x_header_rec.tax_exempt_number                      := p_header_type.tax_exempt_number;
  x_header_rec.tax_exempt_reason_code                 := p_header_type.tax_exempt_reason_code;
  x_header_rec.tax_point_code                         := p_header_type.tax_point_code;
  x_header_rec.transactional_curr_code                := p_header_type.transactional_curr_code;
  x_header_rec.version_number                         := p_header_type.version_number;
  x_header_rec.return_status                          := p_header_type.return_status;
  x_header_rec.db_flag                                := p_header_type.db_flag;
  x_header_rec.operation                              := p_header_type.operation;
  x_header_rec.first_ack_code                         := p_header_type.first_ack_code;
  x_header_rec.first_ack_date                         := p_header_type.first_ack_date;
  x_header_rec.last_ack_code                          := p_header_type.last_ack_code;
  x_header_rec.last_ack_date                          := p_header_type.last_ack_date;
  x_header_rec.change_reason                          := p_header_type.change_reason;
  x_header_rec.change_comments                        := p_header_type.change_comments;
  x_header_rec.change_sequence	                      := p_header_type.change_sequence;
  x_header_rec.change_request_code		      := p_header_type.change_request_code;
  x_header_rec.ready_flag		  	      := p_header_type.ready_flag;
  x_header_rec.status_flag		  	      := p_header_type.status_flag;
  x_header_rec.force_apply_flag		              := p_header_type.force_apply_flag;
  x_header_rec.drop_ship_flag		              := p_header_type.drop_ship_flag;
  x_header_rec.customer_payment_term_id	              := p_header_type.customer_payment_term_id;
  x_header_rec.payment_type_code                      := p_header_type.payment_type_code;
  x_header_rec.payment_amount                         := p_header_type.payment_amount;
  x_header_rec.check_number                           := p_header_type.check_number;
  x_header_rec.credit_card_code                       := p_header_type.credit_card_code;
  x_header_rec.credit_card_holder_name                := p_header_type.credit_card_holder_name;
  x_header_rec.credit_card_number                     := p_header_type.credit_card_number;
  x_header_rec.credit_card_expiration_date            := p_header_type.credit_card_expiration_date;
  x_header_rec.credit_card_approval_code              := p_header_type.credit_card_approval_code;
  x_header_rec.shipping_instructions	              := p_header_type.shipping_instructions;
  x_header_rec.packing_instructions                   := p_header_type.packing_instructions;
  x_header_rec.flow_status_code                       := p_header_type.flow_status_code;

END Header_Type_To_Rec;


-- Header Adjs


PROCEDURE Header_Adj_Var_To_Tbl
(
    p_header_adj_varray 	IN 	SYSTEM.ASO_Header_Adj_Var_Type,
    x_header_adj_tbl     OUT NOCOPY /* file.sql.39 change */   	OE_Order_PUB.Header_Adj_Tbl_Type
)
IS
i                          NUMBER;

BEGIN
  IF p_header_adj_varray is NULL THEN
     x_header_adj_tbl := OE_Order_PUB.G_MISS_HEADER_ADJ_TBL;
     return;
  END IF;

  i := p_header_adj_varray.FIRST;
  WHILE i IS NOT NULL LOOP
      x_header_adj_tbl(i).attribute1                   := p_header_adj_varray(i).attribute1;
      x_header_adj_tbl(i).attribute10                  := p_header_adj_varray(i).attribute10;
      x_header_adj_tbl(i).attribute11                  := p_header_adj_varray(i).attribute11;
      x_header_adj_tbl(i).attribute12                  := p_header_adj_varray(i).attribute12;
      x_header_adj_tbl(i).attribute13                  := p_header_adj_varray(i).attribute13;
      x_header_adj_tbl(i).attribute14                  := p_header_adj_varray(i).attribute14;
      x_header_adj_tbl(i).attribute15                  := p_header_adj_varray(i).attribute15;
      x_header_adj_tbl(i).attribute2                   := p_header_adj_varray(i).attribute2;
      x_header_adj_tbl(i).attribute3                   := p_header_adj_varray(i).attribute3;
      x_header_adj_tbl(i).attribute4                   := p_header_adj_varray(i).attribute4;
      x_header_adj_tbl(i).attribute5                   := p_header_adj_varray(i).attribute5;
      x_header_adj_tbl(i).attribute6                   := p_header_adj_varray(i).attribute6;
      x_header_adj_tbl(i).attribute7                   := p_header_adj_varray(i).attribute7;
      x_header_adj_tbl(i).attribute8                   := p_header_adj_varray(i).attribute8;
      x_header_adj_tbl(i).attribute9                   := p_header_adj_varray(i).attribute9;
      x_header_adj_tbl(i).automatic_flag               := p_header_adj_varray(i).automatic_flag;
      x_header_adj_tbl(i).context                      := p_header_adj_varray(i).context;
      x_header_adj_tbl(i).created_by                   := p_header_adj_varray(i).created_by;
      x_header_adj_tbl(i).creation_date                := p_header_adj_varray(i).creation_date;
      x_header_adj_tbl(i).discount_id                  := p_header_adj_varray(i).discount_id;
      x_header_adj_tbl(i).discount_line_id             := p_header_adj_varray(i).discount_line_id;
      x_header_adj_tbl(i).header_id                    := p_header_adj_varray(i).header_id;
      x_header_adj_tbl(i).last_updated_by              := p_header_adj_varray(i
).last_updated_by;
      x_header_adj_tbl(i).last_update_date             := p_header_adj_varray(i).last_update_date;
      x_header_adj_tbl(i).last_update_login            := p_header_adj_varray(i).last_update_login;
      x_header_adj_tbl(i).line_id                      := p_header_adj_varray(i).line_id;
      x_header_adj_tbl(i).percent                      := p_header_adj_varray(i).percent;
      x_header_adj_tbl(i).price_adjustment_id          := p_header_adj_varray(i).price_adjustment_id;
      x_header_adj_tbl(i).program_application_id       := p_header_adj_varray(i).program_application_id;
      x_header_adj_tbl(i).program_id                   := p_header_adj_varray(i).program_id;
      x_header_adj_tbl(i).program_update_date          := p_header_adj_varray(i).program_update_date;
      x_header_adj_tbl(i).request_id                   := p_header_adj_varray(i).request_id;
      x_header_adj_tbl(i).return_status                := p_header_adj_varray(i).return_status;
      x_header_adj_tbl(i).db_flag                      := p_header_adj_varray(i).db_flag;
      x_header_adj_tbl(i).operation                    := p_header_adj_varray(i).operation;
      x_header_adj_tbl(i).orig_sys_discount_ref	   := p_header_adj_varray(i).orig_sys_discount_ref;
      x_header_adj_tbl(i).change_request_code	   := p_header_adj_varray(i).change_request_code;
      x_header_adj_tbl(i).status_flag	           := p_header_adj_varray(i).status_flag;
      x_header_adj_tbl(i).list_header_id               := p_header_adj_varray(i).list_header_id;
      x_header_adj_tbl(i).list_line_id	           := p_header_adj_varray(i).list_line_id;
      x_header_adj_tbl(i).list_line_type_code	   := p_header_adj_varray(i).list_line_type_code;
      x_header_adj_tbl(i).modifier_mechanism_type_code := p_header_adj_varray(i).modifier_mechanism_type_code;
      x_header_adj_tbl(i).modified_from	           := p_header_adj_varray(i).modified_from;
      x_header_adj_tbl(i).modified_to	           := p_header_adj_varray(i).modified_to;
      x_header_adj_tbl(i).updated_flag                 := p_header_adj_varray(i).updated_flag;
      x_header_adj_tbl(i).update_allowed	           := p_header_adj_varray(i).update_allowed;
      x_header_adj_tbl(i).applied_flag	           := p_header_adj_varray(i).applied_flag;
      x_header_adj_tbl(i).change_reason_code           := p_header_adj_varray(i).change_reason_code;
      x_header_adj_tbl(i).change_reason_text	   := p_header_adj_varray(i).change_reason_text;
      x_header_adj_tbl(i).operand                      := p_header_adj_varray(i).operand;
      x_header_adj_tbl(i).arithmetic_operator          := p_header_adj_varray(i).arithmetic_operator;
      x_header_adj_tbl(i).cost_id                      := p_header_adj_varray(i).cost_id;
      x_header_adj_tbl(i).tax_code                     := p_header_adj_varray(i).tax_code;
      x_header_adj_tbl(i).tax_exempt_flag              := p_header_adj_varray(i).tax_exempt_flag;
      x_header_adj_tbl(i).tax_exempt_number            := p_header_adj_varray(i).tax_exempt_number;
      x_header_adj_tbl(i).tax_exempt_reason_code       := p_header_adj_varray(i).tax_exempt_reason_code;
      x_header_adj_tbl(i).parent_adjustment_id         := p_header_adj_varray(i).parent_adjustment_id;
      x_header_adj_tbl(i).invoiced_flag                := p_header_adj_varray(i).invoiced_flag;
      x_header_adj_tbl(i).estimated_flag               := p_header_adj_varray(i).estimated_flag;
      x_header_adj_tbl(i).inc_in_sales_performance     := p_header_adj_varray(i).inc_in_sales_performance;
      x_header_adj_tbl(i).split_action_code            := p_header_adj_varray(i).split_action_code;
      x_header_adj_tbl(i).adjusted_amount              := p_header_adj_varray(i).adjusted_amount;
      x_header_adj_tbl(i).pricing_phase_id             := p_header_adj_varray(i).pricing_phase_id;

i := p_header_adj_varray.NEXT(i);

END LOOP;

END Header_Adj_Var_To_Tbl;


-- Header Price Atts

PROCEDURE Header_Price_Att_Var_To_Tbl
(
    p_header_price_att_varray 	IN 	SYSTEM.ASO_Header_Price_Att_Var_Type,
    x_header_price_att_tbl     OUT NOCOPY /* file.sql.39 change */   	OE_Order_PUB.Header_Price_Att_Tbl_Type
)
IS
i                          NUMBER;

BEGIN
  IF p_header_price_att_varray is NULL THEN
     x_header_price_att_tbl := OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_TBL;
     return;
  END IF;

  i := p_header_price_att_varray.FIRST;
  WHILE i IS NOT NULL LOOP
      x_header_price_att_tbl(i).order_price_attrib_id                := p_header_price_att_varray(i).order_price_attrib_id;
      x_header_price_att_tbl(i).header_id                            := p_header_price_att_varray(i).header_id;
      x_header_price_att_tbl(i).line_id                              := p_header_price_att_varray(i).line_id;
      x_header_price_att_tbl(i).creation_date                        := p_header_price_att_varray(i).creation_date;
      x_header_price_att_tbl(i).created_by                           := p_header_price_att_varray(i).created_by;
      x_header_price_att_tbl(i).last_update_date                     := p_header_price_att_varray(i).last_update_date;
      x_header_price_att_tbl(i).last_updated_by                      := p_header_price_att_varray(i).last_updated_by;
      x_header_price_att_tbl(i).last_update_login                    := p_header_price_att_varray(i).last_update_login;
      x_header_price_att_tbl(i).program_application_id               := p_header_price_att_varray(i).program_application_id;
      x_header_price_att_tbl(i).program_id                           := p_header_price_att_varray(i).program_id;
      x_header_price_att_tbl(i).program_update_date                  := p_header_price_att_varray(i).program_update_date;
      x_header_price_att_tbl(i).request_id                           := p_header_price_att_varray(i).request_id;
      x_header_price_att_tbl(i).flex_title                           := p_header_price_att_varray(i).flex_title;
      x_header_price_att_tbl(i).pricing_context                      := p_header_price_att_varray(i).pricing_context;
      x_header_price_att_tbl(i).pricing_attribute1                   := p_header_price_att_varray(i).pricing_attribute1;
      x_header_price_att_tbl(i).pricing_attribute2                   := p_header_price_att_varray(i).pricing_attribute2;
      x_header_price_att_tbl(i).pricing_attribute3                   := p_header_price_att_varray(i).pricing_attribute3;
      x_header_price_att_tbl(i).pricing_attribute4                   := p_header_price_att_varray(i).pricing_attribute4;
      x_header_price_att_tbl(i).pricing_attribute5                   := p_header_price_att_varray(i).pricing_attribute5;
      x_header_price_att_tbl(i).pricing_attribute6                   := p_header_price_att_varray(i).pricing_attribute6;
      x_header_price_att_tbl(i).pricing_attribute7                   := p_header_price_att_varray(i).pricing_attribute7;
      x_header_price_att_tbl(i).pricing_attribute8                   := p_header_price_att_varray(i).pricing_attribute8;
      x_header_price_att_tbl(i).pricing_attribute9                   := p_header_price_att_varray(i).pricing_attribute9;
      x_header_price_att_tbl(i).pricing_attribute10                  := p_header_price_att_varray(i).pricing_attribute10;
      x_header_price_att_tbl(i).pricing_attribute11                  := p_header_price_att_varray(i).pricing_attribute11;
      x_header_price_att_tbl(i).pricing_attribute12                  := p_header_price_att_varray(i).pricing_attribute12;
      x_header_price_att_tbl(i).pricing_attribute13                  := p_header_price_att_varray(i).pricing_attribute13;
      x_header_price_att_tbl(i).pricing_attribute14                  := p_header_price_att_varray(i).pricing_attribute14;
      x_header_price_att_tbl(i).pricing_attribute15                  := p_header_price_att_varray(i).pricing_attribute15;
      x_header_price_att_tbl(i).pricing_attribute16                   := p_header_price_att_varray(i).pricing_attribute16;
      x_header_price_att_tbl(i).pricing_attribute17                   := p_header_price_att_varray(i).pricing_attribute17;
      x_header_price_att_tbl(i).pricing_attribute18                   := p_header_price_att_varray(i).pricing_attribute18;
      x_header_price_att_tbl(i).pricing_attribute19                   := p_header_price_att_varray(i).pricing_attribute19;
      x_header_price_att_tbl(i).pricing_attribute20                   := p_header_price_att_varray(i).pricing_attribute20;
      x_header_price_att_tbl(i).pricing_attribute21                   := p_header_price_att_varray(i).pricing_attribute21;
      x_header_price_att_tbl(i).pricing_attribute22                   := p_header_price_att_varray(i).pricing_attribute22;
      x_header_price_att_tbl(i).pricing_attribute23                   := p_header_price_att_varray(i).pricing_attribute23;
      x_header_price_att_tbl(i).pricing_attribute24                   := p_header_price_att_varray(i).pricing_attribute24;
      x_header_price_att_tbl(i).pricing_attribute25                  := p_header_price_att_varray(i).pricing_attribute25;
      x_header_price_att_tbl(i).pricing_attribute26                  := p_header_price_att_varray(i).pricing_attribute26;
      x_header_price_att_tbl(i).pricing_attribute27                  := p_header_price_att_varray(i).pricing_attribute27;
      x_header_price_att_tbl(i).pricing_attribute28                  := p_header_price_att_varray(i).pricing_attribute28;
      x_header_price_att_tbl(i).pricing_attribute29                  := p_header_price_att_varray(i).pricing_attribute29;
      x_header_price_att_tbl(i).pricing_attribute30                  := p_header_price_att_varray(i).pricing_attribute30;
      x_header_price_att_tbl(i).pricing_attribute31                  := p_header_price_att_varray(i).pricing_attribute31;
      x_header_price_att_tbl(i).pricing_attribute32                   := p_header_price_att_varray(i).pricing_attribute32;
      x_header_price_att_tbl(i).pricing_attribute33                   := p_header_price_att_varray(i).pricing_attribute33;
      x_header_price_att_tbl(i).pricing_attribute34                   := p_header_price_att_varray(i).pricing_attribute34;
      x_header_price_att_tbl(i).pricing_attribute35                   := p_header_price_att_varray(i).pricing_attribute35;
      x_header_price_att_tbl(i).pricing_attribute36                   := p_header_price_att_varray(i).pricing_attribute36;
      x_header_price_att_tbl(i).pricing_attribute37                   := p_header_price_att_varray(i).pricing_attribute37;
      x_header_price_att_tbl(i).pricing_attribute38                   := p_header_price_att_varray(i).pricing_attribute38;
      x_header_price_att_tbl(i).pricing_attribute39                   := p_header_price_att_varray(i).pricing_attribute39;
      x_header_price_att_tbl(i).pricing_attribute40                  := p_header_price_att_varray(i).pricing_attribute40;
      x_header_price_att_tbl(i).pricing_attribute41                  := p_header_price_att_varray(i).pricing_attribute41;
      x_header_price_att_tbl(i).pricing_attribute42                  := p_header_price_att_varray(i).pricing_attribute42;
      x_header_price_att_tbl(i).pricing_attribute43                  := p_header_price_att_varray(i).pricing_attribute43;
      x_header_price_att_tbl(i).pricing_attribute44                  := p_header_price_att_varray(i).pricing_attribute44;
      x_header_price_att_tbl(i).pricing_attribute45                  := p_header_price_att_varray(i).pricing_attribute45;
      x_header_price_att_tbl(i).pricing_attribute46                   := p_header_price_att_varray(i).pricing_attribute46;
      x_header_price_att_tbl(i).pricing_attribute47                   := p_header_price_att_varray(i).pricing_attribute47;
      x_header_price_att_tbl(i).pricing_attribute48                   := p_header_price_att_varray(i).pricing_attribute48;
      x_header_price_att_tbl(i).pricing_attribute49                   := p_header_price_att_varray(i).pricing_attribute49;
      x_header_price_att_tbl(i).pricing_attribute50                  := p_header_price_att_varray(i).pricing_attribute50;
      x_header_price_att_tbl(i).pricing_attribute51                   := p_header_price_att_varray(i).pricing_attribute51;
      x_header_price_att_tbl(i).pricing_attribute52                   := p_header_price_att_varray(i).pricing_attribute52;
      x_header_price_att_tbl(i).pricing_attribute53                   := p_header_price_att_varray(i).pricing_attribute53;
      x_header_price_att_tbl(i).pricing_attribute54                   := p_header_price_att_varray(i).pricing_attribute54;
      x_header_price_att_tbl(i).pricing_attribute55                   := p_header_price_att_varray(i).pricing_attribute55;
      x_header_price_att_tbl(i).pricing_attribute56                   := p_header_price_att_varray(i).pricing_attribute56;
      x_header_price_att_tbl(i).pricing_attribute57                   := p_header_price_att_varray(i).pricing_attribute57;
      x_header_price_att_tbl(i).pricing_attribute58                   := p_header_price_att_varray(i).pricing_attribute58;
      x_header_price_att_tbl(i).pricing_attribute59                   := p_header_price_att_varray(i).pricing_attribute59;
      x_header_price_att_tbl(i).pricing_attribute60                  := p_header_price_att_varray(i).pricing_attribute60;
      x_header_price_att_tbl(i).pricing_attribute61                  := p_header_price_att_varray(i).pricing_attribute61;
      x_header_price_att_tbl(i).pricing_attribute62                  := p_header_price_att_varray(i).pricing_attribute62;
      x_header_price_att_tbl(i).pricing_attribute63                  := p_header_price_att_varray(i).pricing_attribute63;
      x_header_price_att_tbl(i).pricing_attribute64                  := p_header_price_att_varray(i).pricing_attribute64;
      x_header_price_att_tbl(i).pricing_attribute65                  := p_header_price_att_varray(i).pricing_attribute65;
      x_header_price_att_tbl(i).pricing_attribute66                   := p_header_price_att_varray(i).pricing_attribute66;
      x_header_price_att_tbl(i).pricing_attribute67                   := p_header_price_att_varray(i).pricing_attribute67;
      x_header_price_att_tbl(i).pricing_attribute68                   := p_header_price_att_varray(i).pricing_attribute68;
      x_header_price_att_tbl(i).pricing_attribute69                   := p_header_price_att_varray(i).pricing_attribute69;
      x_header_price_att_tbl(i).pricing_attribute70                   := p_header_price_att_varray(i).pricing_attribute70;
      x_header_price_att_tbl(i).pricing_attribute71                   := p_header_price_att_varray(i).pricing_attribute71;
      x_header_price_att_tbl(i).pricing_attribute72                   := p_header_price_att_varray(i).pricing_attribute72;
      x_header_price_att_tbl(i).pricing_attribute73                   := p_header_price_att_varray(i).pricing_attribute73;
      x_header_price_att_tbl(i).pricing_attribute74                   := p_header_price_att_varray(i).pricing_attribute74;
      x_header_price_att_tbl(i).pricing_attribute75                  := p_header_price_att_varray(i).pricing_attribute75;
      x_header_price_att_tbl(i).pricing_attribute76                  := p_header_price_att_varray(i).pricing_attribute76;
      x_header_price_att_tbl(i).pricing_attribute77                  := p_header_price_att_varray(i).pricing_attribute77;
      x_header_price_att_tbl(i).pricing_attribute78                  := p_header_price_att_varray(i).pricing_attribute78;
      x_header_price_att_tbl(i).pricing_attribute79                  := p_header_price_att_varray(i).pricing_attribute79;
      x_header_price_att_tbl(i).pricing_attribute80                  := p_header_price_att_varray(i).pricing_attribute80;
      x_header_price_att_tbl(i).pricing_attribute81                  := p_header_price_att_varray(i).pricing_attribute81;
      x_header_price_att_tbl(i).pricing_attribute82                   := p_header_price_att_varray(i).pricing_attribute82;
      x_header_price_att_tbl(i).pricing_attribute83                   := p_header_price_att_varray(i).pricing_attribute83;
      x_header_price_att_tbl(i).pricing_attribute84                   := p_header_price_att_varray(i).pricing_attribute84;
      x_header_price_att_tbl(i).pricing_attribute85                   := p_header_price_att_varray(i).pricing_attribute85;
      x_header_price_att_tbl(i).pricing_attribute86                   := p_header_price_att_varray(i).pricing_attribute86;
      x_header_price_att_tbl(i).pricing_attribute87                   := p_header_price_att_varray(i).pricing_attribute87;
      x_header_price_att_tbl(i).pricing_attribute88                   := p_header_price_att_varray(i).pricing_attribute88;
      x_header_price_att_tbl(i).pricing_attribute89                   := p_header_price_att_varray(i).pricing_attribute89;
      x_header_price_att_tbl(i).pricing_attribute90                  := p_header_price_att_varray(i).pricing_attribute90;
      x_header_price_att_tbl(i).pricing_attribute91                  := p_header_price_att_varray(i).pricing_attribute91;
      x_header_price_att_tbl(i).pricing_attribute92                  := p_header_price_att_varray(i).pricing_attribute92;
      x_header_price_att_tbl(i).pricing_attribute93                  := p_header_price_att_varray(i).pricing_attribute93;
      x_header_price_att_tbl(i).pricing_attribute94                  := p_header_price_att_varray(i).pricing_attribute94;
      x_header_price_att_tbl(i).pricing_attribute95                  := p_header_price_att_varray(i).pricing_attribute95;
      x_header_price_att_tbl(i).pricing_attribute96                   := p_header_price_att_varray(i).pricing_attribute96;
      x_header_price_att_tbl(i).pricing_attribute97                   := p_header_price_att_varray(i).pricing_attribute97;
      x_header_price_att_tbl(i).pricing_attribute98                   := p_header_price_att_varray(i).pricing_attribute98;
      x_header_price_att_tbl(i).pricing_attribute99                   := p_header_price_att_varray(i).pricing_attribute99;
      x_header_price_att_tbl(i).pricing_attribute100                  := p_header_price_att_varray(i).pricing_attribute100;
      x_header_price_att_tbl(i).context                      := p_header_price_att_varray(i).context;
      x_header_price_att_tbl(i).attribute1                   := p_header_price_att_varray(i).attribute1;
      x_header_price_att_tbl(i).attribute2                   := p_header_price_att_varray(i).attribute2;
      x_header_price_att_tbl(i).attribute3                   := p_header_price_att_varray(i).attribute3;
      x_header_price_att_tbl(i).attribute4                   := p_header_price_att_varray(i).attribute4;
      x_header_price_att_tbl(i).attribute5                   := p_header_price_att_varray(i).attribute5;
      x_header_price_att_tbl(i).attribute6                   := p_header_price_att_varray(i).attribute6;
      x_header_price_att_tbl(i).attribute7                   := p_header_price_att_varray(i).attribute7;
      x_header_price_att_tbl(i).attribute8                   := p_header_price_att_varray(i).attribute8;
      x_header_price_att_tbl(i).attribute9                   := p_header_price_att_varray(i).attribute9;
      x_header_price_att_tbl(i).attribute10                  := p_header_price_att_varray(i).attribute10;
      x_header_price_att_tbl(i).attribute11                  := p_header_price_att_varray(i).attribute11;
      x_header_price_att_tbl(i).attribute12                  := p_header_price_att_varray(i).attribute12;
      x_header_price_att_tbl(i).attribute13                  := p_header_price_att_varray(i).attribute13;
      x_header_price_att_tbl(i).attribute14                  := p_header_price_att_varray(i).attribute14;
      x_header_price_att_tbl(i).attribute15                  := p_header_price_att_varray(i).attribute15;
      x_header_price_att_tbl(i).return_status                := p_header_price_att_varray(i).return_status;
      x_header_price_att_tbl(i).db_flag                      := p_header_price_att_varray(i).db_flag;
      x_header_price_att_tbl(i).operation                  := p_header_price_att_varray(i).operation;

i := p_header_price_att_varray.NEXT(i);

END LOOP;

END Header_Price_Att_Var_To_Tbl;


-- Header Adj Atts


PROCEDURE Header_Adj_Att_Var_To_Tbl
(
    p_header_adj_att_varray 	IN 	SYSTEM.ASO_Header_Adj_Att_Var_Type,
    x_header_adj_att_tbl     OUT NOCOPY /* file.sql.39 change */   	OE_Order_PUB.Header_Adj_Att_Tbl_Type
)
IS
i                          NUMBER;

BEGIN
  IF p_header_adj_att_varray is NULL THEN
     x_header_adj_att_tbl := OE_Order_PUB.G_MISS_HEADER_ADJ_ATT_TBL;
     return;
  END IF;

  i := p_header_adj_att_varray.FIRST;
  WHILE i IS NOT NULL LOOP
      x_header_adj_att_tbl(i).price_adj_attrib_id          := p_header_adj_att_varray(i).price_adj_attrib_id;
      x_header_adj_att_tbl(i).price_adjustment_id          := p_header_adj_att_varray(i).price_adjustment_id;
      x_header_adj_att_tbl(i).adj_index                    := p_header_adj_att_varray(i).adj_index;
      x_header_adj_att_tbl(i).flex_title                   := p_header_adj_att_varray(i).flex_title;
      x_header_adj_att_tbl(i).pricing_context              := p_header_adj_att_varray(i).pricing_context;
      x_header_adj_att_tbl(i).pricing_attribute            := p_header_adj_att_varray(i).pricing_attribute;
      x_header_adj_att_tbl(i).creation_date                := p_header_adj_att_varray(i).creation_date;
      x_header_adj_att_tbl(i).created_by                   := p_header_adj_att_varray(i).created_by;
      x_header_adj_att_tbl(i).last_update_date             := p_header_adj_att_varray(i).last_update_date;
      x_header_adj_att_tbl(i).last_updated_by              := p_header_adj_att_varray(i).last_updated_by;
      x_header_adj_att_tbl(i).last_update_login            := p_header_adj_att_varray(i).last_update_login;
      x_header_adj_att_tbl(i).program_application_id       := p_header_adj_att_varray(i).program_application_id;
      x_header_adj_att_tbl(i).program_id                   := p_header_adj_att_varray(i).program_id;
      x_header_adj_att_tbl(i).program_update_date          := p_header_adj_att_varray(i).program_update_date;
      x_header_adj_att_tbl(i).request_id                   := p_header_adj_att_varray(i).request_id;
      x_header_adj_att_tbl(i).pricing_attr_value_from      := p_header_adj_att_varray(i).pricing_attr_value_from;
      x_header_adj_att_tbl(i).pricing_attr_value_to        := p_header_adj_att_varray(i).pricing_attr_value_to;
      x_header_adj_att_tbl(i).comparison_operator          := p_header_adj_att_varray(i).comparison_operator;
      x_header_adj_att_tbl(i).return_status                := p_header_adj_att_varray(i).return_status;
      x_header_adj_att_tbl(i).db_flag                      := p_header_adj_att_varray(i).db_flag;
      x_header_adj_att_tbl(i).operation                    := p_header_adj_att_varray(i).operation;

i := p_header_adj_att_varray.NEXT(i);

END LOOP;

END Header_Adj_Att_Var_To_Tbl;


-- Header Adj Assocs

PROCEDURE Header_Adj_Assoc_Var_To_Tbl
(
    p_header_adj_assoc_varray 	IN 	SYSTEM.ASO_Header_Adj_Assoc_Var_Type,
    x_header_adj_assoc_tbl     OUT NOCOPY /* file.sql.39 change */   	OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
)
IS
i                          NUMBER;

BEGIN
  IF p_header_adj_assoc_varray is NULL THEN
     x_header_adj_assoc_tbl := OE_Order_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL;
     return;
  END IF;

  i := p_header_adj_assoc_varray.FIRST;
  WHILE i IS NOT NULL LOOP
      x_header_adj_assoc_tbl(i).price_adj_assoc_id           := p_header_adj_assoc_varray(i).price_adj_assoc_id;
      x_header_adj_assoc_tbl(i).line_id                      := p_header_adj_assoc_varray(i).line_id;
      x_header_adj_assoc_tbl(i).line_index                   := p_header_adj_assoc_varray(i).line_index;
      x_header_adj_assoc_tbl(i).price_adjustment_id          := p_header_adj_assoc_varray(i).price_adjustment_id;
      x_header_adj_assoc_tbl(i).adj_index                    := p_header_adj_assoc_varray(i).adj_index;
      x_header_adj_assoc_tbl(i).creation_date                := p_header_adj_assoc_varray(i).creation_date;
      x_header_adj_assoc_tbl(i).created_by                   := p_header_adj_assoc_varray(i).created_by;
      x_header_adj_assoc_tbl(i).last_update_date             := p_header_adj_assoc_varray(i).last_update_date;
      x_header_adj_assoc_tbl(i).last_updated_by              := p_header_adj_assoc_varray(i).last_updated_by;
      x_header_adj_assoc_tbl(i).last_update_login            := p_header_adj_assoc_varray(i).last_update_login;
      x_header_adj_assoc_tbl(i).program_application_id       := p_header_adj_assoc_varray(i).program_application_id;
      x_header_adj_assoc_tbl(i).program_id                   := p_header_adj_assoc_varray(i).program_id;
      x_header_adj_assoc_tbl(i).program_update_date          := p_header_adj_assoc_varray(i).program_update_date;
      x_header_adj_assoc_tbl(i).request_id                   := p_header_adj_assoc_varray(i).request_id;
      x_header_adj_assoc_tbl(i).return_status                := p_header_adj_assoc_varray(i).return_status;
      x_header_adj_assoc_tbl(i).db_flag                      := p_header_adj_assoc_varray(i).db_flag;
      x_header_adj_assoc_tbl(i).operation                    := p_header_adj_assoc_varray(i).operation;

i := p_header_adj_assoc_varray.NEXT(i);

END LOOP;

END Header_Adj_Assoc_Var_To_Tbl;


-- Header Scredits

PROCEDURE Header_Scredit_Var_To_Tbl
(
    p_header_scredit_varray 	IN 	SYSTEM.ASO_Header_Scredit_Var_Type,
    x_header_scredit_tbl     OUT NOCOPY /* file.sql.39 change */   	OE_Order_PUB.Header_Scredit_Tbl_Type
)
IS
i                          NUMBER;

BEGIN
  IF p_header_scredit_varray is NULL THEN
     x_header_scredit_tbl := OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL;
     return;
  END IF;

  i := p_header_scredit_varray.FIRST;
  WHILE i IS NOT NULL LOOP
      x_header_scredit_tbl(i).attribute1                   := p_header_scredit_varray(i).attribute1;
      x_header_scredit_tbl(i).attribute10                  := p_header_scredit_varray(i).attribute10;
      x_header_scredit_tbl(i).attribute11                  := p_header_scredit_varray(i).attribute11;
      x_header_scredit_tbl(i).attribute12                  := p_header_scredit_varray(i).attribute12;
      x_header_scredit_tbl(i).attribute13                  := p_header_scredit_varray(i).attribute13;
      x_header_scredit_tbl(i).attribute14                  := p_header_scredit_varray(i).attribute14;
      x_header_scredit_tbl(i).attribute15                  := p_header_scredit_varray(i).attribute15;
      x_header_scredit_tbl(i).attribute2                   := p_header_scredit_varray(i).attribute2;
      x_header_scredit_tbl(i).attribute3                   := p_header_scredit_varray(i).attribute3;
      x_header_scredit_tbl(i).attribute4                   := p_header_scredit_varray(i).attribute4;
      x_header_scredit_tbl(i).attribute5                   := p_header_scredit_varray(i).attribute5;
      x_header_scredit_tbl(i).attribute6                   := p_header_scredit_varray(i).attribute6;
      x_header_scredit_tbl(i).attribute7                   := p_header_scredit_varray(i).attribute7;
      x_header_scredit_tbl(i).attribute8                   := p_header_scredit_varray(i).attribute8;
      x_header_scredit_tbl(i).attribute9                   := p_header_scredit_varray(i).attribute9;
      x_header_scredit_tbl(i).context                      := p_header_scredit_varray(i).context;
      x_header_scredit_tbl(i).created_by                   := p_header_scredit_varray(i).created_by;
      x_header_scredit_tbl(i).creation_date                := p_header_scredit_varray(i).creation_date;
      x_header_scredit_tbl(i).dw_update_advice_flag        := p_header_scredit_varray(i).dw_update_advice_flag;
      x_header_scredit_tbl(i).header_id                    := p_header_scredit_varray(i).header_id;
      x_header_scredit_tbl(i).last_updated_by              := p_header_scredit_varray(i).last_updated_by;
      x_header_scredit_tbl(i).last_update_date             := p_header_scredit_varray(i).last_update_date;
      x_header_scredit_tbl(i).last_update_login            := p_header_scredit_varray(i).last_update_login;
      x_header_scredit_tbl(i).line_id                      := p_header_scredit_varray(i).line_id;
      x_header_scredit_tbl(i).percent                      := p_header_scredit_varray(i).percent;
      x_header_scredit_tbl(i).salesrep_id                  := p_header_scredit_varray(i).salesrep_id;
      x_header_scredit_tbl(i).sales_credit_id              := p_header_scredit_varray(i).sales_credit_id;
      x_header_scredit_tbl(i).wh_update_date               := p_header_scredit_varray(i).wh_update_date;
      x_header_scredit_tbl(i).return_status                := p_header_scredit_varray(i).return_status;
      x_header_scredit_tbl(i).db_flag                      := p_header_scredit_varray(i).db_flag;
      x_header_scredit_tbl(i).operation                    := p_header_scredit_varray(i).operation;
      x_header_scredit_tbl(i).orig_sys_credit_ref	   := p_header_scredit_varray(i).orig_sys_credit_ref;
      x_header_scredit_tbl(i).change_request_code	   := p_header_scredit_varray(i).change_request_code;
      x_header_scredit_tbl(i).status_flag	           := p_header_scredit_varray(i).status_flag;

i := p_header_scredit_varray.NEXT(i);

END LOOP;

END Header_Scredit_Var_To_Tbl;


-- Lines

PROCEDURE Line_Var_To_Tbl
(
    p_line_varray 	IN 	SYSTEM.ASO_Line_Var_Type,
    x_line_tbl     OUT NOCOPY /* file.sql.39 change */   	OE_Order_PUB.Line_Tbl_Type
)
IS
i                          NUMBER;

BEGIN
  IF p_line_varray is NULL THEN
     x_line_tbl := OE_Order_PUB.G_MISS_LINE_TBL;
     return;
  END IF;

  i := p_line_varray.FIRST;
  WHILE i IS NOT NULL LOOP
      x_line_tbl(i).accounting_rule_id                      := p_line_varray(i).accounting_rule_id;
      x_line_tbl(i).actual_arrival_date                     := p_line_varray(i).actual_arrival_date;
      x_line_tbl(i).actual_shipment_date                    := p_line_varray(i).actual_shipment_date;
      x_line_tbl(i).agreement_id                            := p_line_varray(i).agreement_id;
      x_line_tbl(i).arrival_set_id                          := p_line_varray(i).arrival_set_id;
      x_line_tbl(i).ato_line_id                             := p_line_varray(i).ato_line_id;
      x_line_tbl(i).attribute1                              := p_line_varray(i).attribute1;
      x_line_tbl(i).attribute10                             := p_line_varray(i).attribute10;
      x_line_tbl(i).attribute11                             := p_line_varray(i).attribute11;
      x_line_tbl(i).attribute12                             := p_line_varray(i).attribute12;
      x_line_tbl(i).attribute13                             := p_line_varray(i).attribute13;
      x_line_tbl(i).attribute14                             := p_line_varray(i).attribute14;
      x_line_tbl(i).attribute15                             := p_line_varray(i).attribute15;
      x_line_tbl(i).attribute2                              := p_line_varray(i).attribute2;
      x_line_tbl(i).attribute3                              := p_line_varray(i).attribute3;
      x_line_tbl(i).attribute4                              := p_line_varray(i).attribute4;
      x_line_tbl(i).attribute5                              := p_line_varray(i).attribute5;
      x_line_tbl(i).attribute6                              := p_line_varray(i).attribute6;
      x_line_tbl(i).attribute7                              := p_line_varray(i).attribute7;
      x_line_tbl(i).attribute8                              := p_line_varray(i).attribute8;
      x_line_tbl(i).attribute9                              := p_line_varray(i).attribute9;
      x_line_tbl(i).authorized_to_ship_flag                 := p_line_varray(i).authorized_to_ship_flag;
      x_line_tbl(i).auto_selected_quantity                  := p_line_varray(i).auto_selected_quantity;
      x_line_tbl(i).booked_flag                             := p_line_varray(i).booked_flag;
      x_line_tbl(i).cancelled_flag                          := p_line_varray(i).cancelled_flag;
      x_line_tbl(i).cancelled_quantity                      := p_line_varray(i).cancelled_quantity;
      x_line_tbl(i).commitment_id                           := p_line_varray(i).commitment_id;
      x_line_tbl(i).component_code                          := p_line_varray(i).component_code;
      x_line_tbl(i).component_number                        := p_line_varray(i).component_number;
      x_line_tbl(i).component_sequence_id                   := p_line_varray(i).component_sequence_id;
      x_line_tbl(i).config_header_id                        := p_line_varray(i).config_header_id;
      x_line_tbl(i).config_rev_nbr 	                    := p_line_varray(i).config_rev_nbr;
      x_line_tbl(i).config_display_sequence                 := p_line_varray(i).config_display_sequence;
      x_line_tbl(i).configuration_id                        := p_line_varray(i).configuration_id;
      x_line_tbl(i).context                                 := p_line_varray(i).context;
      x_line_tbl(i).created_by                              := p_line_varray(i).created_by;
      x_line_tbl(i).creation_date                           := p_line_varray(i).creation_date;
      x_line_tbl(i).credit_invoice_line_id                  := p_line_varray(i).credit_invoice_line_id;
      x_line_tbl(i).customer_dock_code                      := p_line_varray(i).customer_dock_code;
      x_line_tbl(i).customer_job                            := p_line_varray(i).customer_job;
      x_line_tbl(i).customer_production_line                := p_line_varray(i).customer_production_line;
      x_line_tbl(i).customer_trx_line_id                    := p_line_varray(i).customer_trx_line_id;
      x_line_tbl(i).cust_model_serial_number                := p_line_varray(i).cust_model_serial_number;
      x_line_tbl(i).cust_po_number                          := p_line_varray(i).cust_po_number;
      x_line_tbl(i).cust_production_seq_num                 := p_line_varray(i).cust_production_seq_num;
      x_line_tbl(i).delivery_lead_time                      := p_line_varray(i).delivery_lead_time;
      x_line_tbl(i).deliver_to_contact_id                   := p_line_varray(i).deliver_to_contact_id;
      x_line_tbl(i).deliver_to_org_id                       := p_line_varray(i).deliver_to_org_id;
      x_line_tbl(i).demand_bucket_type_code                 := p_line_varray(i).demand_bucket_type_code;
      x_line_tbl(i).demand_class_code                       := p_line_varray(i).demand_class_code;
      x_line_tbl(i).dep_plan_required_flag                  := p_line_varray(i).dep_plan_required_flag;
      x_line_tbl(i).earliest_acceptable_date                := p_line_varray(i).earliest_acceptable_date;
      x_line_tbl(i).end_item_unit_number                    := p_line_varray(i).end_item_unit_number;
      x_line_tbl(i).explosion_date                          := p_line_varray(i).explosion_date;
      x_line_tbl(i).fob_point_code                          := p_line_varray(i).fob_point_code;
      x_line_tbl(i).freight_carrier_code                    := p_line_varray(i).freight_carrier_code;
      x_line_tbl(i).freight_terms_code                      := p_line_varray(i).freight_terms_code;
      x_line_tbl(i).fulfilled_quantity                      := p_line_varray(i).fulfilled_quantity;
      x_line_tbl(i).global_attribute1                       := p_line_varray(i).global_attribute1;
      x_line_tbl(i).global_attribute10                      := p_line_varray(i).global_attribute10;
      x_line_tbl(i).global_attribute11                      := p_line_varray(i).global_attribute11;
      x_line_tbl(i).global_attribute12                      := p_line_varray(i).global_attribute12;
      x_line_tbl(i).global_attribute13                      := p_line_varray(i).global_attribute13;
      x_line_tbl(i).global_attribute14                      := p_line_varray(i).global_attribute14;
      x_line_tbl(i).global_attribute15                      := p_line_varray(i).global_attribute15;
      x_line_tbl(i).global_attribute16                      := p_line_varray(i).global_attribute16;
      x_line_tbl(i).global_attribute17                      := p_line_varray(i).global_attribute17;
      x_line_tbl(i).global_attribute18                      := p_line_varray(i).global_attribute18;
      x_line_tbl(i).global_attribute19                      := p_line_varray(i).global_attribute19;
      x_line_tbl(i).global_attribute2                       := p_line_varray(i).global_attribute2;
      x_line_tbl(i).global_attribute20                      := p_line_varray(i).global_attribute20;
      x_line_tbl(i).global_attribute3                       := p_line_varray(i).global_attribute3;
      x_line_tbl(i).global_attribute4                       := p_line_varray(i).global_attribute4;
      x_line_tbl(i).global_attribute5                        := p_line_varray(i).global_attribute5;
      x_line_tbl(i).global_attribute6                        := p_line_varray(i).global_attribute6;
      x_line_tbl(i).global_attribute7                        := p_line_varray(i).global_attribute7;
      x_line_tbl(i).global_attribute8                        := p_line_varray(i).global_attribute8;
      x_line_tbl(i).global_attribute9                        := p_line_varray(i).global_attribute9;
      x_line_tbl(i).global_attribute_category                := p_line_varray(i).global_attribute_category;
      x_line_tbl(i).header_id                                := p_line_varray(i).header_id;
      x_line_tbl(i).industry_attribute1                        := p_line_varray(i).industry_attribute1;
      x_line_tbl(i).industry_attribute10                        := p_line_varray(i).industry_attribute10;
      x_line_tbl(i).industry_attribute11                        := p_line_varray(i).industry_attribute11;
      x_line_tbl(i).industry_attribute12                        := p_line_varray(i).industry_attribute12;
      x_line_tbl(i).industry_attribute13                        := p_line_varray(i).industry_attribute13;
      x_line_tbl(i).industry_attribute14                        := p_line_varray(i).industry_attribute14;
      x_line_tbl(i).industry_attribute15                        := p_line_varray(i).industry_attribute15;
      x_line_tbl(i).industry_attribute16                        := p_line_varray(i).industry_attribute16;
      x_line_tbl(i).industry_attribute17                        := p_line_varray(i).industry_attribute17;
      x_line_tbl(i).industry_attribute18                        := p_line_varray(i).industry_attribute18;
      x_line_tbl(i).industry_attribute19                        := p_line_varray(i).industry_attribute19;
      x_line_tbl(i).industry_attribute20                        := p_line_varray(i).industry_attribute20;
      x_line_tbl(i).industry_attribute21                        := p_line_varray(i).industry_attribute21;
      x_line_tbl(i).industry_attribute22                        := p_line_varray(i).industry_attribute22;
      x_line_tbl(i).industry_attribute23                        := p_line_varray(i).industry_attribute23;
      x_line_tbl(i).industry_attribute24                        := p_line_varray(i).industry_attribute24;
      x_line_tbl(i).industry_attribute25                        := p_line_varray(i).industry_attribute25;
      x_line_tbl(i).industry_attribute26                        := p_line_varray(i).industry_attribute26;
      x_line_tbl(i).industry_attribute27                        := p_line_varray(i).industry_attribute27;
      x_line_tbl(i).industry_attribute28                        := p_line_varray(i).industry_attribute28;
      x_line_tbl(i).industry_attribute29                        := p_line_varray(i).industry_attribute29;
      x_line_tbl(i).industry_attribute30                        := p_line_varray(i).industry_attribute30;
      x_line_tbl(i).industry_attribute2                        := p_line_varray(i).industry_attribute2;
      x_line_tbl(i).industry_attribute3                        := p_line_varray(i).industry_attribute3;
      x_line_tbl(i).industry_attribute4                        := p_line_varray(i).industry_attribute4;
      x_line_tbl(i).industry_attribute5                        := p_line_varray(i).industry_attribute5;
      x_line_tbl(i).industry_attribute6                        := p_line_varray(i).industry_attribute6;
      x_line_tbl(i).industry_attribute7                        := p_line_varray(i).industry_attribute7;
      x_line_tbl(i).industry_attribute8                        := p_line_varray(i).industry_attribute8;
      x_line_tbl(i).industry_attribute9                        := p_line_varray(i).industry_attribute9;
      x_line_tbl(i).industry_context                           := p_line_varray(i).industry_context;
      x_line_tbl(i).TP_CONTEXT                                 := p_line_varray(i).TP_CONTEXT;
      x_line_tbl(i).TP_ATTRIBUTE1                            := p_line_varray(i).TP_ATTRIBUTE1;
      x_line_tbl(i).TP_ATTRIBUTE2                            := p_line_varray(i).TP_ATTRIBUTE2;
      x_line_tbl(i).TP_ATTRIBUTE3                            := p_line_varray(i).TP_ATTRIBUTE3;
      x_line_tbl(i).TP_ATTRIBUTE4                            := p_line_varray(i).TP_ATTRIBUTE4;
      x_line_tbl(i).TP_ATTRIBUTE5                            := p_line_varray(i).TP_ATTRIBUTE5;
      x_line_tbl(i).TP_ATTRIBUTE6                            := p_line_varray(i).TP_ATTRIBUTE6;
      x_line_tbl(i).TP_ATTRIBUTE7                            := p_line_varray(i).TP_ATTRIBUTE7;
      x_line_tbl(i).TP_ATTRIBUTE8                            := p_line_varray(i).TP_ATTRIBUTE8;
      x_line_tbl(i).TP_ATTRIBUTE9                            := p_line_varray(i).TP_ATTRIBUTE9;
      x_line_tbl(i).TP_ATTRIBUTE10                           := p_line_varray(i).TP_ATTRIBUTE10;
      x_line_tbl(i).TP_ATTRIBUTE11                           := p_line_varray(i).TP_ATTRIBUTE11;
      x_line_tbl(i).TP_ATTRIBUTE12                           := p_line_varray(i).TP_ATTRIBUTE12;
      x_line_tbl(i).TP_ATTRIBUTE13                           := p_line_varray(i).TP_ATTRIBUTE13;
      x_line_tbl(i).TP_ATTRIBUTE14                           := p_line_varray(i).TP_ATTRIBUTE14;
      x_line_tbl(i).TP_ATTRIBUTE15                           := p_line_varray(i).TP_ATTRIBUTE15;
      x_line_tbl(i).intermed_ship_to_org_id                  := p_line_varray(i).intermed_ship_to_org_id;
      x_line_tbl(i).intermed_ship_to_contact_id              := p_line_varray(i).intermed_ship_to_contact_id;
      x_line_tbl(i).inventory_item_id                        := p_line_varray(i).inventory_item_id;
      x_line_tbl(i).invoice_interface_status_code            := p_line_varray(i).invoice_interface_status_code;
      x_line_tbl(i).invoice_to_contact_id                    := p_line_varray(i).invoice_to_contact_id;
      x_line_tbl(i).invoice_to_org_id                        := p_line_varray(i).invoice_to_org_id;
      x_line_tbl(i).invoicing_rule_id                        := p_line_varray(i).invoicing_rule_id;
      x_line_tbl(i).ordered_item                             := p_line_varray(i).ordered_item;
      x_line_tbl(i).item_revision                            := p_line_varray(i).item_revision;
      x_line_tbl(i).item_type_code                           := p_line_varray(i).item_type_code;
      x_line_tbl(i).last_updated_by                          := p_line_varray(i).last_updated_by;
      x_line_tbl(i).last_update_date                         := p_line_varray(i).last_update_date;
      x_line_tbl(i).last_update_login                        := p_line_varray(i).last_update_login;
      x_line_tbl(i).latest_acceptable_date                    := p_line_varray(i).latest_acceptable_date;
      x_line_tbl(i).line_category_code                        := p_line_varray(i).line_category_code;
      x_line_tbl(i).line_id                                   := p_line_varray(i).line_id;
      x_line_tbl(i).line_number                               := p_line_varray(i).line_number;
      x_line_tbl(i).line_type_id                              := p_line_varray(i).line_type_id;
      x_line_tbl(i).link_to_line_ref                          := p_line_varray(i).link_to_line_ref;
      x_line_tbl(i).link_to_line_id                           := p_line_varray(i).link_to_line_id;
      x_line_tbl(i).link_to_line_index                        := p_line_varray(i).link_to_line_index;
      x_line_tbl(i).model_group_number                        := p_line_varray(i).model_group_number;
      x_line_tbl(i).mfg_component_sequence_id                 := p_line_varray(i).mfg_component_sequence_id;
      x_line_tbl(i).open_flag                                 := p_line_varray(i).open_flag;
      x_line_tbl(i).option_flag                               := p_line_varray(i).option_flag;
      x_line_tbl(i).option_number                             := p_line_varray(i).option_number;
      x_line_tbl(i).ordered_quantity                          := p_line_varray(i).ordered_quantity;
      x_line_tbl(i).order_quantity_uom                        := p_line_varray(i).order_quantity_uom;
      x_line_tbl(i).org_id                                    := p_line_varray(i).org_id;
      x_line_tbl(i).orig_sys_document_ref                     := p_line_varray(i).orig_sys_document_ref;
      x_line_tbl(i).orig_sys_line_ref                         := p_line_varray(i).orig_sys_line_ref;
      x_line_tbl(i).over_ship_reason_code                     := p_line_varray(i).over_ship_reason_code;
      x_line_tbl(i).over_ship_resolved_flag                   := p_line_varray(i).over_ship_resolved_flag;
      x_line_tbl(i).payment_term_id                           := p_line_varray(i).payment_term_id;
      x_line_tbl(i).planning_priority                         := p_line_varray(i).planning_priority;
      x_line_tbl(i).price_list_id                             := p_line_varray(i).price_list_id;
      x_line_tbl(i).pricing_attribute1                        := p_line_varray(i).pricing_attribute1;
      x_line_tbl(i).pricing_attribute10                        := p_line_varray(i).pricing_attribute10;
      x_line_tbl(i).pricing_attribute2                        := p_line_varray(i).pricing_attribute2;
      x_line_tbl(i).pricing_attribute3                        := p_line_varray(i).pricing_attribute3;
      x_line_tbl(i).pricing_attribute4                        := p_line_varray(i).pricing_attribute4;
      x_line_tbl(i).pricing_attribute5                        := p_line_varray(i).pricing_attribute5;
      x_line_tbl(i).pricing_attribute6                        := p_line_varray(i).pricing_attribute6;
      x_line_tbl(i).pricing_attribute7                        := p_line_varray(i).pricing_attribute7;
      x_line_tbl(i).pricing_attribute8                        := p_line_varray(i).pricing_attribute8;
      x_line_tbl(i).pricing_attribute9                        := p_line_varray(i).pricing_attribute9;
      x_line_tbl(i).pricing_context                           := p_line_varray(i).pricing_context;
      x_line_tbl(i).pricing_date                              := p_line_varray(i).pricing_date;
      x_line_tbl(i).pricing_quantity                          := p_line_varray(i).pricing_quantity;
      x_line_tbl(i).pricing_quantity_uom                      := p_line_varray(i).pricing_quantity_uom;
      x_line_tbl(i).program_application_id                    := p_line_varray(i).program_application_id;
      x_line_tbl(i).program_id                                := p_line_varray(i).program_id;
      x_line_tbl(i).program_update_date                       := p_line_varray(i).program_update_date;
      x_line_tbl(i).project_id                                := p_line_varray(i).project_id;
      x_line_tbl(i).promise_date                              := p_line_varray(i).promise_date;
      x_line_tbl(i).re_source_flag                            := p_line_varray(i).re_source_flag;
      x_line_tbl(i).reference_customer_trx_line_id            := p_line_varray(i).reference_customer_trx_line_id;
      x_line_tbl(i).reference_header_id                       := p_line_varray(i).reference_header_id;
      x_line_tbl(i).reference_line_id                         := p_line_varray(i).reference_line_id;
      x_line_tbl(i).reference_type                            := p_line_varray(i).reference_type;
      x_line_tbl(i).request_date                              := p_line_varray(i).request_date;
      x_line_tbl(i).request_id                                := p_line_varray(i).request_id;
      x_line_tbl(i).reserved_quantity                        := p_line_varray(i).reserved_quantity;
      x_line_tbl(i).return_attribute1                        := p_line_varray(i).return_attribute1;
      x_line_tbl(i).return_attribute10                        := p_line_varray(i).return_attribute10;
      x_line_tbl(i).return_attribute11                        := p_line_varray(i).return_attribute11;
      x_line_tbl(i).return_attribute12                        := p_line_varray(i).return_attribute12;
      x_line_tbl(i).return_attribute13                        := p_line_varray(i).return_attribute13;
      x_line_tbl(i).return_attribute14                        := p_line_varray(i).return_attribute14;
      x_line_tbl(i).return_attribute15                        := p_line_varray(i).return_attribute15;
      x_line_tbl(i).return_attribute2                        := p_line_varray(i).return_attribute2;
      x_line_tbl(i).return_attribute3                        := p_line_varray(i).return_attribute3;
      x_line_tbl(i).return_attribute4                        := p_line_varray(i).return_attribute4;
      x_line_tbl(i).return_attribute5                        := p_line_varray(i).return_attribute5;
      x_line_tbl(i).return_attribute6                        := p_line_varray(i).return_attribute6;
      x_line_tbl(i).return_attribute7                        := p_line_varray(i).return_attribute7;
      x_line_tbl(i).return_attribute8                        := p_line_varray(i).return_attribute8;
      x_line_tbl(i).return_attribute9                        := p_line_varray(i).return_attribute9;
      x_line_tbl(i).return_context                           := p_line_varray(i).return_context;
      x_line_tbl(i).return_reason_code                        := p_line_varray(i).return_reason_code;
      x_line_tbl(i).rla_schedule_type_code                    := p_line_varray(i).rla_schedule_type_code;
      x_line_tbl(i).salesrep_id                               := p_line_varray(i).salesrep_id;
      x_line_tbl(i).schedule_arrival_date                     := p_line_varray(i).schedule_arrival_date;
      x_line_tbl(i).schedule_ship_date                        := p_line_varray(i).schedule_ship_date;
      x_line_tbl(i).schedule_action_code                        := p_line_varray(i).schedule_action_code;
      x_line_tbl(i).schedule_status_code                        := p_line_varray(i).schedule_status_code;
      x_line_tbl(i).shipment_number                            := p_line_varray(i).shipment_number;
      x_line_tbl(i).shipment_priority_code                     := p_line_varray(i).shipment_priority_code;
      x_line_tbl(i).shipped_quantity                           := p_line_varray(i).shipped_quantity;
      x_line_tbl(i).shipping_interfaced_flag                   := p_line_varray(i).shipping_interfaced_flag;
      x_line_tbl(i).shipping_method_code                        := p_line_varray(i).shipping_method_code;
      x_line_tbl(i).shipping_quantity                            := p_line_varray(i).shipping_quantity;
      x_line_tbl(i).shipping_quantity_uom                        := p_line_varray(i).shipping_quantity_uom;
      x_line_tbl(i).ship_from_org_id                            := p_line_varray(i).ship_from_org_id;
      x_line_tbl(i).ship_model_complete_flag                    := p_line_varray(i).ship_model_complete_flag;
      x_line_tbl(i).ship_set_id                                 := p_line_varray(i).ship_set_id;
      x_line_tbl(i).ship_tolerance_above                        := p_line_varray(i).ship_tolerance_above;
      x_line_tbl(i).ship_tolerance_below                        := p_line_varray(i).ship_tolerance_below;
      x_line_tbl(i).ship_to_contact_id                          := p_line_varray(i).ship_to_contact_id;
      x_line_tbl(i).ship_to_org_id                              := p_line_varray(i).ship_to_org_id;
      x_line_tbl(i).sold_to_org_id                          := p_line_varray(i).sold_to_org_id;
      x_line_tbl(i).sold_from_org_id                        := p_line_varray(i).sold_from_org_id;
      x_line_tbl(i).sort_order                              := p_line_varray(i).sort_order;
      x_line_tbl(i).source_document_id                      := p_line_varray(i).source_document_id;
      x_line_tbl(i).source_document_line_id                 := p_line_varray(i).source_document_line_id;
      x_line_tbl(i).source_document_type_id                 := p_line_varray(i).source_document_type_id;
      x_line_tbl(i).source_type_code                        := p_line_varray(i).source_type_code;
      x_line_tbl(i).split_from_line_id                      := p_line_varray(i).split_from_line_id;
      x_line_tbl(i).task_id                                 := p_line_varray(i).task_id;
      x_line_tbl(i).tax_code                                := p_line_varray(i).tax_code;
      x_line_tbl(i).tax_date                                := p_line_varray(i).tax_date;
      x_line_tbl(i).tax_exempt_flag                         := p_line_varray(i).tax_exempt_flag;
      x_line_tbl(i).tax_exempt_number                       := p_line_varray(i).tax_exempt_number;
      x_line_tbl(i).tax_exempt_reason_code                  := p_line_varray(i).tax_exempt_reason_code;
      x_line_tbl(i).tax_point_code                          := p_line_varray(i).tax_point_code;
      x_line_tbl(i).tax_rate                                := p_line_varray(i).tax_rate;
      x_line_tbl(i).tax_value                               := p_line_varray(i).tax_value;
      x_line_tbl(i).top_model_line_ref                      := p_line_varray(i).top_model_line_ref;
      x_line_tbl(i).top_model_line_id                       := p_line_varray(i).top_model_line_id;
      x_line_tbl(i).top_model_line_index                    := p_line_varray(i).top_model_line_index;
      x_line_tbl(i).unit_list_price                        := p_line_varray(i).unit_list_price;
      x_line_tbl(i).unit_selling_price                      := p_line_varray(i).unit_selling_price;
      x_line_tbl(i).veh_cus_item_cum_key_id                 := p_line_varray(i).veh_cus_item_cum_key_id;
      x_line_tbl(i).visible_demand_flag                     := p_line_varray(i).visible_demand_flag;
      x_line_tbl(i).return_status                           := p_line_varray(i).return_status;
      x_line_tbl(i).db_flag                                := p_line_varray(i).db_flag;
      x_line_tbl(i).operation                             := p_line_varray(i).operation;
      x_line_tbl(i).first_ack_code                        := p_line_varray(i).first_ack_code;
      x_line_tbl(i).first_ack_date                        := p_line_varray(i).first_ack_date;
      x_line_tbl(i).last_ack_code                        := p_line_varray(i).last_ack_code;
      x_line_tbl(i).last_ack_date                        := p_line_varray(i).last_ack_date;
      x_line_tbl(i).change_reason                        := p_line_varray(i).change_reason;
      x_line_tbl(i).change_comments                        := p_line_varray(i).change_comments;
      x_line_tbl(i).arrival_set                           := p_line_varray(i).arrival_set;
      x_line_tbl(i).ship_set                              := p_line_varray(i).ship_set;
      x_line_tbl(i).order_source_id                        := p_line_varray(i).order_source_id;
      x_line_tbl(i).orig_sys_shipment_ref                  := p_line_varray(i).orig_sys_shipment_ref;
      x_line_tbl(i).change_sequence                        := p_line_varray(i).change_sequence;
      x_line_tbl(i).change_request_code                    := p_line_varray(i).change_request_code;
      x_line_tbl(i).status_flag                            := p_line_varray(i).status_flag;
      x_line_tbl(i).drop_ship_flag                         := p_line_varray(i).drop_ship_flag;
      x_line_tbl(i).customer_line_number                   := p_line_varray(i).customer_line_number;
      x_line_tbl(i).customer_shipment_number               := p_line_varray(i).customer_shipment_number;
      x_line_tbl(i).customer_item_net_price                 := p_line_varray(i).customer_item_net_price;
      x_line_tbl(i).customer_payment_term_id                := p_line_varray(i).customer_payment_term_id;
      x_line_tbl(i).ordered_item_id                        := p_line_varray(i).ordered_item_id;
      x_line_tbl(i).item_identifier_type                     := p_line_varray(i).item_identifier_type;
      x_line_tbl(i).shipping_instructions                    := p_line_varray(i).shipping_instructions;
      x_line_tbl(i).packing_instructions                     := p_line_varray(i).packing_instructions;
      x_line_tbl(i).calculate_price_flag                     := p_line_varray(i).calculate_price_flag;
      x_line_tbl(i).invoiced_quantity                        := p_line_varray(i).invoiced_quantity;
      x_line_tbl(i).service_txn_reason_code                  := p_line_varray(i).service_txn_reason_code;
      x_line_tbl(i).service_txn_comments                     := p_line_varray(i).service_txn_comments;
      x_line_tbl(i).service_duration                        := p_line_varray(i).service_duration;
      x_line_tbl(i).service_period                          := p_line_varray(i).service_period;
      x_line_tbl(i).service_start_date                      := p_line_varray(i).service_start_date;
      x_line_tbl(i).service_end_date                        := p_line_varray(i).service_end_date;
      x_line_tbl(i).service_coterminate_flag                := p_line_varray(i).service_coterminate_flag;
      x_line_tbl(i).unit_list_percent                        := p_line_varray(i).unit_list_percent;
      x_line_tbl(i).unit_selling_percent                     := p_line_varray(i).unit_selling_percent;
      x_line_tbl(i).unit_percent_base_price                 := p_line_varray(i).unit_percent_base_price;
      x_line_tbl(i).service_number                          := p_line_varray(i).service_number;
      x_line_tbl(i).service_reference_type_code              := p_line_varray(i).service_reference_type_code;
      x_line_tbl(i).service_reference_line_id                 := p_line_varray(i).service_reference_line_id;
      x_line_tbl(i).service_reference_system_id              := p_line_varray(i).service_reference_system_id;
      x_line_tbl(i).service_ref_order_number                 := p_line_varray(i).service_ref_order_number;
      x_line_tbl(i).service_ref_line_number                  := p_line_varray(i).service_ref_line_number;
      x_line_tbl(i).service_ref_shipment_number              := p_line_varray(i).service_ref_shipment_number;
      x_line_tbl(i).service_ref_option_number                := p_line_varray(i).service_ref_option_number;
      x_line_tbl(i).service_line_index                       := p_line_varray(i).service_line_index;
      x_line_tbl(i).Line_set_id                              := p_line_varray(i).Line_set_id;
      x_line_tbl(i).split_by                                 := p_line_varray(i).split_by;
      x_line_tbl(i).Split_Action_Code                        := p_line_varray(i).Split_Action_Code;
      x_line_tbl(i).shippable_flag                           := p_line_varray(i).shippable_flag;
      x_line_tbl(i).model_remnant_flag                        := p_line_varray(i).model_remnant_flag;
      x_line_tbl(i).flow_status_code                         := p_line_varray(i).flow_status_code;
      x_line_tbl(i).fulfilled_flag                           := p_line_varray(i).fulfilled_flag;
      x_line_tbl(i).fulfillment_method_code                   := p_line_varray(i).fulfillment_method_code;
      x_line_tbl(i).semi_processed_flag                      := FND_API.To_Boolean(p_line_varray(i).semi_processed_flag);

i := p_line_varray.NEXT(i);

END LOOP;

END Line_Var_To_Tbl;


-- Line Adjs

PROCEDURE Line_Adj_Var_To_Tbl
(
    p_line_adj_varray 	IN 	SYSTEM.ASO_Line_Adj_Var_Type,
    x_line_adj_tbl     OUT NOCOPY /* file.sql.39 change */   	OE_Order_PUB.Line_Adj_Tbl_Type
)
IS
i                          NUMBER;

BEGIN
  IF p_line_adj_varray is NULL THEN
     x_line_adj_tbl := OE_Order_PUB.G_MISS_LINE_ADJ_TBL;
     return;
  END IF;

  i := p_line_adj_varray.FIRST;
  WHILE i IS NOT NULL LOOP
      x_line_adj_tbl(i).attribute1                   := p_line_adj_varray(i).attribute1;
      x_line_adj_tbl(i).attribute10                  := p_line_adj_varray(i).attribute10;
      x_line_adj_tbl(i).attribute11                  := p_line_adj_varray(i).attribute11;
      x_line_adj_tbl(i).attribute12                  := p_line_adj_varray(i).attribute12;
      x_line_adj_tbl(i).attribute13                  := p_line_adj_varray(i).attribute13;
      x_line_adj_tbl(i).attribute14                  := p_line_adj_varray(i).attribute14;
      x_line_adj_tbl(i).attribute15                  := p_line_adj_varray(i).attribute15;
      x_line_adj_tbl(i).attribute2                   := p_line_adj_varray(i).attribute2;
      x_line_adj_tbl(i).attribute3                   := p_line_adj_varray(i).attribute3;
      x_line_adj_tbl(i).attribute4                   := p_line_adj_varray(i).attribute4;
      x_line_adj_tbl(i).attribute5                   := p_line_adj_varray(i).attribute5;
      x_line_adj_tbl(i).attribute6                   := p_line_adj_varray(i).attribute6;
      x_line_adj_tbl(i).attribute7                   := p_line_adj_varray(i).attribute7;
      x_line_adj_tbl(i).attribute8                   := p_line_adj_varray(i).attribute8;
      x_line_adj_tbl(i).attribute9                   := p_line_adj_varray(i).attribute9;
      x_line_adj_tbl(i).automatic_flag               := p_line_adj_varray(i).automatic_flag;
      x_line_adj_tbl(i).context                      := p_line_adj_varray(i).context;
      x_line_adj_tbl(i).created_by                   := p_line_adj_varray(i).created_by;
      x_line_adj_tbl(i).creation_date                := p_line_adj_varray(i).creation_date;
      x_line_adj_tbl(i).discount_id                  := p_line_adj_varray(i).discount_id;
      x_line_adj_tbl(i).discount_line_id             := p_line_adj_varray(i).discount_line_id;
      x_line_adj_tbl(i).header_id                    := p_line_adj_varray(i).header_id;
      x_line_adj_tbl(i).last_updated_by              := p_line_adj_varray(i).last_updated_by;
      x_line_adj_tbl(i).last_update_date             := p_line_adj_varray(i).last_update_date;
      x_line_adj_tbl(i).last_update_login            := p_line_adj_varray(i).last_update_login;
      x_line_adj_tbl(i).line_id                      := p_line_adj_varray(i).line_id;
      x_line_adj_tbl(i).percent                      := p_line_adj_varray(i).percent;
      x_line_adj_tbl(i).price_adjustment_id          := p_line_adj_varray(i).price_adjustment_id;
      x_line_adj_tbl(i).program_application_id       := p_line_adj_varray(i).program_application_id;
      x_line_adj_tbl(i).program_id                   := p_line_adj_varray(i).program_id;
      x_line_adj_tbl(i).program_update_date          := p_line_adj_varray(i).program_update_date;
      x_line_adj_tbl(i).request_id                   := p_line_adj_varray(i).request_id;
      x_line_adj_tbl(i).return_status                := p_line_adj_varray(i).return_status;
      x_line_adj_tbl(i).db_flag                      := p_line_adj_varray(i).db_flag;
      x_line_adj_tbl(i).operation                    := p_line_adj_varray(i).operation;
      x_line_adj_tbl(i).line_index                   := p_line_adj_varray(i).line_index;
      x_line_adj_tbl(i).orig_sys_discount_ref	   := p_line_adj_varray(i).orig_sys_discount_ref;
      x_line_adj_tbl(i).change_request_code	   := p_line_adj_varray(i).change_request_code;
      x_line_adj_tbl(i).status_flag	           := p_line_adj_varray(i).status_flag;
      x_line_adj_tbl(i).list_header_id               := p_line_adj_varray(i).list_header_id;
      x_line_adj_tbl(i).list_line_id	           := p_line_adj_varray(i).list_line_id;
      x_line_adj_tbl(i).list_line_type_code	   := p_line_adj_varray(i).list_line_type_code;
      x_line_adj_tbl(i).modifier_mechanism_type_code := p_line_adj_varray(i).modifier_mechanism_type_code;
      x_line_adj_tbl(i).modified_from	           := p_line_adj_varray(i).modified_from;
      x_line_adj_tbl(i).modified_to	           := p_line_adj_varray(i).modified_to;
      x_line_adj_tbl(i).updated_flag                 := p_line_adj_varray(i).updated_flag;
      x_line_adj_tbl(i).update_allowed	           := p_line_adj_varray(i).update_allowed;
      x_line_adj_tbl(i).applied_flag	           := p_line_adj_varray(i).applied_flag;
      x_line_adj_tbl(i).change_reason_code           := p_line_adj_varray(i).change_reason_code;
      x_line_adj_tbl(i).change_reason_text	   := p_line_adj_varray(i).change_reason_text;
      x_line_adj_tbl(i).operand                      := p_line_adj_varray(i).operand;
      x_line_adj_tbl(i).arithmetic_operator          := p_line_adj_varray(i).arithmetic_operator;
      x_line_adj_tbl(i).cost_id                      := p_line_adj_varray(i).cost_id;
      x_line_adj_tbl(i).tax_code                     := p_line_adj_varray(i).tax_code;
      x_line_adj_tbl(i).tax_exempt_flag              := p_line_adj_varray(i).tax_exempt_flag;
      x_line_adj_tbl(i).tax_exempt_number            := p_line_adj_varray(i).tax_exempt_number;
      x_line_adj_tbl(i).tax_exempt_reason_code       := p_line_adj_varray(i).tax_exempt_reason_code;
      x_line_adj_tbl(i).parent_adjustment_id         := p_line_adj_varray(i).parent_adjustment_id;
      x_line_adj_tbl(i).invoiced_flag                := p_line_adj_varray(i).invoiced_flag;
      x_line_adj_tbl(i).estimated_flag               := p_line_adj_varray(i).estimated_flag;
      x_line_adj_tbl(i).inc_in_sales_performance     := p_line_adj_varray(i).inc_in_sales_performance;
      x_line_adj_tbl(i).split_action_code            := p_line_adj_varray(i).split_action_code;
      x_line_adj_tbl(i).adjusted_amount              := p_line_adj_varray(i).adjusted_amount;
      x_line_adj_tbl(i).pricing_phase_id             := p_line_adj_varray(i).pricing_phase_id;

i := p_line_adj_varray.NEXT(i);

END LOOP;

END Line_Adj_Var_To_Tbl;


-- Line Price Atts

PROCEDURE Line_Price_Att_Var_To_Tbl
(
    p_line_price_att_varray 	IN 	SYSTEM.ASO_Line_Price_Att_Var_Type,
    x_line_price_att_tbl     OUT NOCOPY /* file.sql.39 change */   	OE_Order_PUB.Line_Price_Att_Tbl_Type
)
IS
i                          NUMBER;

BEGIN
  IF p_line_price_att_varray is NULL THEN
     x_line_price_att_tbl := OE_Order_PUB.G_MISS_LINE_PRICE_ATT_TBL;
     return;
  END IF;

  i := p_line_price_att_varray.FIRST;
  WHILE i IS NOT NULL LOOP
      x_line_price_att_tbl(i).order_price_attrib_id                := p_line_price_att_varray(i).order_price_attrib_id;
      x_line_price_att_tbl(i).header_id                            := p_line_price_att_varray(i).header_id;
      x_line_price_att_tbl(i).line_id                              := p_line_price_att_varray(i).line_id;
      x_line_price_att_tbl(i).line_index                           := p_line_price_att_varray(i).line_index;
      x_line_price_att_tbl(i).creation_date                        := p_line_price_att_varray(i).creation_date;
      x_line_price_att_tbl(i).created_by                           := p_line_price_att_varray(i).created_by;
      x_line_price_att_tbl(i).last_update_date                     := p_line_price_att_varray(i).last_update_date;
      x_line_price_att_tbl(i).last_updated_by                      := p_line_price_att_varray(i).last_updated_by;
      x_line_price_att_tbl(i).last_update_login                    := p_line_price_att_varray(i).last_update_login;
      x_line_price_att_tbl(i).program_application_id               := p_line_price_att_varray(i).program_application_id;
      x_line_price_att_tbl(i).program_id                           := p_line_price_att_varray(i).program_id;
      x_line_price_att_tbl(i).program_update_date                  := p_line_price_att_varray(i).program_update_date;
      x_line_price_att_tbl(i).request_id                           := p_line_price_att_varray(i).request_id;
      x_line_price_att_tbl(i).flex_title                           := p_line_price_att_varray(i).flex_title;
      x_line_price_att_tbl(i).pricing_context                      := p_line_price_att_varray(i).pricing_context;
      x_line_price_att_tbl(i).pricing_attribute1                   := p_line_price_att_varray(i).pricing_attribute1;
      x_line_price_att_tbl(i).pricing_attribute2                   := p_line_price_att_varray(i).pricing_attribute2;
      x_line_price_att_tbl(i).pricing_attribute3                   := p_line_price_att_varray(i).pricing_attribute3;
      x_line_price_att_tbl(i).pricing_attribute4                   := p_line_price_att_varray(i).pricing_attribute4;
      x_line_price_att_tbl(i).pricing_attribute5                   := p_line_price_att_varray(i).pricing_attribute5;
      x_line_price_att_tbl(i).pricing_attribute6                   := p_line_price_att_varray(i).pricing_attribute6;
      x_line_price_att_tbl(i).pricing_attribute7                   := p_line_price_att_varray(i).pricing_attribute7;
      x_line_price_att_tbl(i).pricing_attribute8                   := p_line_price_att_varray(i).pricing_attribute8;
      x_line_price_att_tbl(i).pricing_attribute9                   := p_line_price_att_varray(i).pricing_attribute9;
      x_line_price_att_tbl(i).pricing_attribute10                  := p_line_price_att_varray(i).pricing_attribute10;
      x_line_price_att_tbl(i).pricing_attribute11                  := p_line_price_att_varray(i).pricing_attribute11;
      x_line_price_att_tbl(i).pricing_attribute12                  := p_line_price_att_varray(i).pricing_attribute12;
      x_line_price_att_tbl(i).pricing_attribute13                  := p_line_price_att_varray(i).pricing_attribute13;
      x_line_price_att_tbl(i).pricing_attribute14                  := p_line_price_att_varray(i).pricing_attribute14;
      x_line_price_att_tbl(i).pricing_attribute15                  := p_line_price_att_varray(i).pricing_attribute15;
      x_line_price_att_tbl(i).pricing_attribute16                   := p_line_price_att_varray(i).pricing_attribute16;
      x_line_price_att_tbl(i).pricing_attribute17                   := p_line_price_att_varray(i).pricing_attribute17;
      x_line_price_att_tbl(i).pricing_attribute18                   := p_line_price_att_varray(i).pricing_attribute18;
      x_line_price_att_tbl(i).pricing_attribute19                   := p_line_price_att_varray(i).pricing_attribute19;
      x_line_price_att_tbl(i).pricing_attribute20                   := p_line_price_att_varray(i).pricing_attribute20;
      x_line_price_att_tbl(i).pricing_attribute21                   := p_line_price_att_varray(i).pricing_attribute21;
      x_line_price_att_tbl(i).pricing_attribute22                   := p_line_price_att_varray(i).pricing_attribute22;
      x_line_price_att_tbl(i).pricing_attribute23                   := p_line_price_att_varray(i).pricing_attribute23;
      x_line_price_att_tbl(i).pricing_attribute24                   := p_line_price_att_varray(i).pricing_attribute24;
      x_line_price_att_tbl(i).pricing_attribute25                  := p_line_price_att_varray(i).pricing_attribute25;
      x_line_price_att_tbl(i).pricing_attribute26                  := p_line_price_att_varray(i).pricing_attribute26;
      x_line_price_att_tbl(i).pricing_attribute27                  := p_line_price_att_varray(i).pricing_attribute27;
      x_line_price_att_tbl(i).pricing_attribute28                  := p_line_price_att_varray(i).pricing_attribute28;
      x_line_price_att_tbl(i).pricing_attribute29                  := p_line_price_att_varray(i).pricing_attribute29;
      x_line_price_att_tbl(i).pricing_attribute30                  := p_line_price_att_varray(i).pricing_attribute30;
      x_line_price_att_tbl(i).pricing_attribute31                  := p_line_price_att_varray(i).pricing_attribute31;
      x_line_price_att_tbl(i).pricing_attribute32                   := p_line_price_att_varray(i).pricing_attribute32;
      x_line_price_att_tbl(i).pricing_attribute33                   := p_line_price_att_varray(i).pricing_attribute33;
      x_line_price_att_tbl(i).pricing_attribute34                   := p_line_price_att_varray(i).pricing_attribute34;
      x_line_price_att_tbl(i).pricing_attribute35                   := p_line_price_att_varray(i).pricing_attribute35;
      x_line_price_att_tbl(i).pricing_attribute36                   := p_line_price_att_varray(i).pricing_attribute36;
      x_line_price_att_tbl(i).pricing_attribute37                   := p_line_price_att_varray(i).pricing_attribute37;
      x_line_price_att_tbl(i).pricing_attribute38                   := p_line_price_att_varray(i).pricing_attribute38;
      x_line_price_att_tbl(i).pricing_attribute39                   := p_line_price_att_varray(i).pricing_attribute39;
      x_line_price_att_tbl(i).pricing_attribute40                  := p_line_price_att_varray(i).pricing_attribute40;
      x_line_price_att_tbl(i).pricing_attribute41                  := p_line_price_att_varray(i).pricing_attribute41;
      x_line_price_att_tbl(i).pricing_attribute42                  := p_line_price_att_varray(i).pricing_attribute42;
      x_line_price_att_tbl(i).pricing_attribute43                  := p_line_price_att_varray(i).pricing_attribute43;
      x_line_price_att_tbl(i).pricing_attribute44                  := p_line_price_att_varray(i).pricing_attribute44;
      x_line_price_att_tbl(i).pricing_attribute45                  := p_line_price_att_varray(i).pricing_attribute45;
      x_line_price_att_tbl(i).pricing_attribute46                   := p_line_price_att_varray(i).pricing_attribute46;
      x_line_price_att_tbl(i).pricing_attribute47                   := p_line_price_att_varray(i).pricing_attribute47;
      x_line_price_att_tbl(i).pricing_attribute48                   := p_line_price_att_varray(i).pricing_attribute48;
      x_line_price_att_tbl(i).pricing_attribute49                   := p_line_price_att_varray(i).pricing_attribute49;
      x_line_price_att_tbl(i).pricing_attribute50                  := p_line_price_att_varray(i).pricing_attribute50;
      x_line_price_att_tbl(i).pricing_attribute51                   := p_line_price_att_varray(i).pricing_attribute51;
      x_line_price_att_tbl(i).pricing_attribute52                   := p_line_price_att_varray(i).pricing_attribute52;
      x_line_price_att_tbl(i).pricing_attribute53                   := p_line_price_att_varray(i).pricing_attribute53;
      x_line_price_att_tbl(i).pricing_attribute54                   := p_line_price_att_varray(i).pricing_attribute54;
      x_line_price_att_tbl(i).pricing_attribute55                   := p_line_price_att_varray(i).pricing_attribute55;
      x_line_price_att_tbl(i).pricing_attribute56                   := p_line_price_att_varray(i).pricing_attribute56;
      x_line_price_att_tbl(i).pricing_attribute57                   := p_line_price_att_varray(i).pricing_attribute57;
      x_line_price_att_tbl(i).pricing_attribute58                   := p_line_price_att_varray(i).pricing_attribute58;
      x_line_price_att_tbl(i).pricing_attribute59                   := p_line_price_att_varray(i).pricing_attribute59;
      x_line_price_att_tbl(i).pricing_attribute60                  := p_line_price_att_varray(i).pricing_attribute60;
      x_line_price_att_tbl(i).pricing_attribute61                  := p_line_price_att_varray(i).pricing_attribute61;
      x_line_price_att_tbl(i).pricing_attribute62                  := p_line_price_att_varray(i).pricing_attribute62;
      x_line_price_att_tbl(i).pricing_attribute63                  := p_line_price_att_varray(i).pricing_attribute63;
      x_line_price_att_tbl(i).pricing_attribute64                  := p_line_price_att_varray(i).pricing_attribute64;
      x_line_price_att_tbl(i).pricing_attribute65                  := p_line_price_att_varray(i).pricing_attribute65;
      x_line_price_att_tbl(i).pricing_attribute66                   := p_line_price_att_varray(i).pricing_attribute66;
      x_line_price_att_tbl(i).pricing_attribute67                   := p_line_price_att_varray(i).pricing_attribute67;
      x_line_price_att_tbl(i).pricing_attribute68                   := p_line_price_att_varray(i).pricing_attribute68;
      x_line_price_att_tbl(i).pricing_attribute69                   := p_line_price_att_varray(i).pricing_attribute69;
      x_line_price_att_tbl(i).pricing_attribute70                   := p_line_price_att_varray(i).pricing_attribute70;
      x_line_price_att_tbl(i).pricing_attribute71                   := p_line_price_att_varray(i).pricing_attribute71;
      x_line_price_att_tbl(i).pricing_attribute72                   := p_line_price_att_varray(i).pricing_attribute72;
      x_line_price_att_tbl(i).pricing_attribute73                   := p_line_price_att_varray(i).pricing_attribute73;
      x_line_price_att_tbl(i).pricing_attribute74                   := p_line_price_att_varray(i).pricing_attribute74;
      x_line_price_att_tbl(i).pricing_attribute75                  := p_line_price_att_varray(i).pricing_attribute75;
      x_line_price_att_tbl(i).pricing_attribute76                  := p_line_price_att_varray(i).pricing_attribute76;
      x_line_price_att_tbl(i).pricing_attribute77                  := p_line_price_att_varray(i).pricing_attribute77;
      x_line_price_att_tbl(i).pricing_attribute78                  := p_line_price_att_varray(i).pricing_attribute78;
      x_line_price_att_tbl(i).pricing_attribute79                  := p_line_price_att_varray(i).pricing_attribute79;
      x_line_price_att_tbl(i).pricing_attribute80                  := p_line_price_att_varray(i).pricing_attribute80;
      x_line_price_att_tbl(i).pricing_attribute81                  := p_line_price_att_varray(i).pricing_attribute81;
      x_line_price_att_tbl(i).pricing_attribute82                   := p_line_price_att_varray(i).pricing_attribute82;
      x_line_price_att_tbl(i).pricing_attribute83                   := p_line_price_att_varray(i).pricing_attribute83;
      x_line_price_att_tbl(i).pricing_attribute84                   := p_line_price_att_varray(i).pricing_attribute84;
      x_line_price_att_tbl(i).pricing_attribute85                   := p_line_price_att_varray(i).pricing_attribute85;
      x_line_price_att_tbl(i).pricing_attribute86                   := p_line_price_att_varray(i).pricing_attribute86;
      x_line_price_att_tbl(i).pricing_attribute87                   := p_line_price_att_varray(i).pricing_attribute87;
      x_line_price_att_tbl(i).pricing_attribute88                   := p_line_price_att_varray(i).pricing_attribute88;
      x_line_price_att_tbl(i).pricing_attribute89                   := p_line_price_att_varray(i).pricing_attribute89;
      x_line_price_att_tbl(i).pricing_attribute90                  := p_line_price_att_varray(i).pricing_attribute90;
      x_line_price_att_tbl(i).pricing_attribute91                  := p_line_price_att_varray(i).pricing_attribute91;
      x_line_price_att_tbl(i).pricing_attribute92                  := p_line_price_att_varray(i).pricing_attribute92;
      x_line_price_att_tbl(i).pricing_attribute93                  := p_line_price_att_varray(i).pricing_attribute93;
      x_line_price_att_tbl(i).pricing_attribute94                  := p_line_price_att_varray(i).pricing_attribute94;
      x_line_price_att_tbl(i).pricing_attribute95                  := p_line_price_att_varray(i).pricing_attribute95;
      x_line_price_att_tbl(i).pricing_attribute96                   := p_line_price_att_varray(i).pricing_attribute96;
      x_line_price_att_tbl(i).pricing_attribute97                   := p_line_price_att_varray(i).pricing_attribute97;
      x_line_price_att_tbl(i).pricing_attribute98                   := p_line_price_att_varray(i).pricing_attribute98;
      x_line_price_att_tbl(i).pricing_attribute99                   := p_line_price_att_varray(i).pricing_attribute99;
      x_line_price_att_tbl(i).pricing_attribute100                  := p_line_price_att_varray(i).pricing_attribute100;
      x_line_price_att_tbl(i).context                      := p_line_price_att_varray(i).context;
      x_line_price_att_tbl(i).attribute1                   := p_line_price_att_varray(i).attribute1;
      x_line_price_att_tbl(i).attribute2                   := p_line_price_att_varray(i).attribute2;
      x_line_price_att_tbl(i).attribute3                   := p_line_price_att_varray(i).attribute3;
      x_line_price_att_tbl(i).attribute4                   := p_line_price_att_varray(i).attribute4;
      x_line_price_att_tbl(i).attribute5                   := p_line_price_att_varray(i).attribute5;
      x_line_price_att_tbl(i).attribute6                   := p_line_price_att_varray(i).attribute6;
      x_line_price_att_tbl(i).attribute7                   := p_line_price_att_varray(i).attribute7;
      x_line_price_att_tbl(i).attribute8                   := p_line_price_att_varray(i).attribute8;
      x_line_price_att_tbl(i).attribute9                   := p_line_price_att_varray(i).attribute9;
      x_line_price_att_tbl(i).attribute10                  := p_line_price_att_varray(i).attribute10;
      x_line_price_att_tbl(i).attribute11                  := p_line_price_att_varray(i).attribute11;
      x_line_price_att_tbl(i).attribute12                  := p_line_price_att_varray(i).attribute12;
      x_line_price_att_tbl(i).attribute13                  := p_line_price_att_varray(i).attribute13;
      x_line_price_att_tbl(i).attribute14                  := p_line_price_att_varray(i).attribute14;
      x_line_price_att_tbl(i).attribute15                  := p_line_price_att_varray(i).attribute15;
      x_line_price_att_tbl(i).return_status                := p_line_price_att_varray(i).return_status;
      x_line_price_att_tbl(i).db_flag                      := p_line_price_att_varray(i).db_flag;
      x_line_price_att_tbl(i).operation                  := p_line_price_att_varray(i).operation;

i := p_line_price_att_varray.NEXT(i);

END LOOP;

END Line_Price_Att_Var_To_Tbl;


-- Line Adj Atts

PROCEDURE Line_Adj_Att_Var_To_Tbl
(
    p_line_adj_att_varray 	IN 	SYSTEM.ASO_Line_Adj_Att_Var_Type,
    x_line_adj_att_tbl     OUT NOCOPY /* file.sql.39 change */   	OE_Order_PUB.Line_Adj_Att_Tbl_Type
)
IS
i                          NUMBER;

BEGIN
  IF p_line_adj_att_varray is NULL THEN
     x_line_adj_att_tbl := OE_Order_PUB.G_MISS_LINE_ADJ_ATT_TBL;
     return;
  END IF;

  i := p_line_adj_att_varray.FIRST;
  WHILE i IS NOT NULL LOOP
      x_line_adj_att_tbl(i).price_adj_attrib_id          := p_line_adj_att_varray(i).price_adj_attrib_id;
      x_line_adj_att_tbl(i).price_adjustment_id          := p_line_adj_att_varray(i).price_adjustment_id;
      x_line_adj_att_tbl(i).adj_index                    := p_line_adj_att_varray(i).adj_index;
      x_line_adj_att_tbl(i).flex_title                   := p_line_adj_att_varray(i).flex_title;
      x_line_adj_att_tbl(i).pricing_context              := p_line_adj_att_varray(i).pricing_context;
      x_line_adj_att_tbl(i).pricing_attribute            := p_line_adj_att_varray(i).pricing_attribute;
      x_line_adj_att_tbl(i).creation_date                := p_line_adj_att_varray(i).creation_date;
      x_line_adj_att_tbl(i).created_by                   := p_line_adj_att_varray(i).created_by;
      x_line_adj_att_tbl(i).last_update_date             := p_line_adj_att_varray(i).last_update_date;
      x_line_adj_att_tbl(i).last_updated_by              := p_line_adj_att_varray(i).last_updated_by;
      x_line_adj_att_tbl(i).last_update_login            := p_line_adj_att_varray(i).last_update_login;
      x_line_adj_att_tbl(i).program_application_id       := p_line_adj_att_varray(i).program_application_id;
      x_line_adj_att_tbl(i).program_id                   := p_line_adj_att_varray(i).program_id;
      x_line_adj_att_tbl(i).program_update_date          := p_line_adj_att_varray(i).program_update_date;
      x_line_adj_att_tbl(i).request_id                   := p_line_adj_att_varray(i).request_id;
      x_line_adj_att_tbl(i).pricing_attr_value_from      := p_line_adj_att_varray(i).pricing_attr_value_from;
      x_line_adj_att_tbl(i).pricing_attr_value_to        := p_line_adj_att_varray(i).pricing_attr_value_to;
      x_line_adj_att_tbl(i).comparison_operator          := p_line_adj_att_varray(i).comparison_operator;
      x_line_adj_att_tbl(i).return_status                := p_line_adj_att_varray(i).return_status;
      x_line_adj_att_tbl(i).db_flag                      := p_line_adj_att_varray(i).db_flag;
      x_line_adj_att_tbl(i).operation                    := p_line_adj_att_varray(i).operation;

i := p_line_adj_att_varray.NEXT(i);

END LOOP;

END Line_Adj_Att_Var_To_Tbl;


-- Line Adj Assocs

PROCEDURE Line_Adj_Assoc_Var_To_Tbl
(
    p_line_adj_assoc_varray 	IN 	SYSTEM.ASO_Line_Adj_Assoc_Var_Type,
    x_line_adj_assoc_tbl     OUT NOCOPY /* file.sql.39 change */   	OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
)
IS
i                          NUMBER;

BEGIN
  IF p_line_adj_assoc_varray is NULL THEN
     x_line_adj_assoc_tbl := OE_Order_PUB.G_MISS_LINE_ADJ_ASSOC_TBL;
     return;
  END IF;

  i := p_line_adj_assoc_varray.FIRST;
  WHILE i IS NOT NULL LOOP
      x_line_adj_assoc_tbl(i).price_adj_assoc_id           := p_line_adj_assoc_varray(i).price_adj_assoc_id;
      x_line_adj_assoc_tbl(i).line_id                      := p_line_adj_assoc_varray(i).line_id;
      x_line_adj_assoc_tbl(i).line_index                   := p_line_adj_assoc_varray(i).line_index;
      x_line_adj_assoc_tbl(i).price_adjustment_id          := p_line_adj_assoc_varray(i).price_adjustment_id;
      x_line_adj_assoc_tbl(i).adj_index                    := p_line_adj_assoc_varray(i).adj_index;
      x_line_adj_assoc_tbl(i).creation_date                := p_line_adj_assoc_varray(i).creation_date;
      x_line_adj_assoc_tbl(i).created_by                   := p_line_adj_assoc_varray(i).created_by;
      x_line_adj_assoc_tbl(i).last_update_date             := p_line_adj_assoc_varray(i).last_update_date;
      x_line_adj_assoc_tbl(i).last_updated_by              := p_line_adj_assoc_varray(i).last_updated_by;
      x_line_adj_assoc_tbl(i).last_update_login            := p_line_adj_assoc_varray(i).last_update_login;
      x_line_adj_assoc_tbl(i).program_application_id       := p_line_adj_assoc_varray(i).program_application_id;
      x_line_adj_assoc_tbl(i).program_id                   := p_line_adj_assoc_varray(i).program_id;
      x_line_adj_assoc_tbl(i).program_update_date          := p_line_adj_assoc_varray(i).program_update_date;
      x_line_adj_assoc_tbl(i).request_id                   := p_line_adj_assoc_varray(i).request_id;
      x_line_adj_assoc_tbl(i).return_status                := p_line_adj_assoc_varray(i).return_status;
      x_line_adj_assoc_tbl(i).db_flag                      := p_line_adj_assoc_varray(i).db_flag;
      x_line_adj_assoc_tbl(i).operation                    := p_line_adj_assoc_varray(i).operation;

i := p_line_adj_assoc_varray.NEXT(i);

END LOOP;

END Line_Adj_Assoc_Var_To_Tbl;


-- Line Scredits

PROCEDURE Line_Scredit_Var_To_Tbl
(
    p_line_scredit_varray 	IN 	SYSTEM.ASO_Line_Scredit_Var_Type,
    x_line_scredit_tbl     OUT NOCOPY /* file.sql.39 change */   	OE_Order_PUB.Line_Scredit_Tbl_Type
)
IS
i                          NUMBER;

BEGIN
  IF p_line_scredit_varray is NULL THEN
     x_line_scredit_tbl := OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL;
     return;
  END IF;

  i := p_line_scredit_varray.FIRST;
  WHILE i IS NOT NULL LOOP
      x_line_scredit_tbl(i).attribute1                   := p_line_scredit_varray(i).attribute1;
      x_line_scredit_tbl(i).attribute10                  := p_line_scredit_varray(i).attribute10;
      x_line_scredit_tbl(i).attribute11                  := p_line_scredit_varray(i).attribute11;
      x_line_scredit_tbl(i).attribute12                  := p_line_scredit_varray(i).attribute12;
      x_line_scredit_tbl(i).attribute13                  := p_line_scredit_varray(i).attribute13;
      x_line_scredit_tbl(i).attribute14                  := p_line_scredit_varray(i).attribute14;
      x_line_scredit_tbl(i).attribute15                  := p_line_scredit_varray(i).attribute15;
      x_line_scredit_tbl(i).attribute2                   := p_line_scredit_varray(i).attribute2;
      x_line_scredit_tbl(i).attribute3                   := p_line_scredit_varray(i).attribute3;
      x_line_scredit_tbl(i).attribute4                   := p_line_scredit_varray(i).attribute4;
      x_line_scredit_tbl(i).attribute5                   := p_line_scredit_varray(i).attribute5;
      x_line_scredit_tbl(i).attribute6                   := p_line_scredit_varray(i).attribute6;
      x_line_scredit_tbl(i).attribute7                   := p_line_scredit_varray(i).attribute7;
      x_line_scredit_tbl(i).attribute8                   := p_line_scredit_varray(i).attribute8;
      x_line_scredit_tbl(i).attribute9                   := p_line_scredit_varray(i).attribute9;
      x_line_scredit_tbl(i).context                      := p_line_scredit_varray(i).context;
      x_line_scredit_tbl(i).created_by                   := p_line_scredit_varray(i).created_by;
      x_line_scredit_tbl(i).creation_date                := p_line_scredit_varray(i).creation_date;
      x_line_scredit_tbl(i).dw_update_advice_flag        := p_line_scredit_varray(i).dw_update_advice_flag;
      x_line_scredit_tbl(i).header_id                    := p_line_scredit_varray(i).header_id;
      x_line_scredit_tbl(i).last_updated_by              := p_line_scredit_varray(i).last_updated_by;
      x_line_scredit_tbl(i).last_update_date             := p_line_scredit_varray(i).last_update_date;
      x_line_scredit_tbl(i).last_update_login            := p_line_scredit_varray(i).last_update_login;
      x_line_scredit_tbl(i).line_id                      := p_line_scredit_varray(i).line_id;
      x_line_scredit_tbl(i).percent                      := p_line_scredit_varray(i).percent;
      x_line_scredit_tbl(i).salesrep_id                  := p_line_scredit_varray(i).salesrep_id;
      x_line_scredit_tbl(i).sales_credit_id              := p_line_scredit_varray(i).sales_credit_id;
      x_line_scredit_tbl(i).wh_update_date               := p_line_scredit_varray(i).wh_update_date;
      x_line_scredit_tbl(i).return_status                := p_line_scredit_varray(i).return_status;
      x_line_scredit_tbl(i).db_flag                      := p_line_scredit_varray(i).db_flag;
      x_line_scredit_tbl(i).operation                    := p_line_scredit_varray(i).operation;
      x_line_scredit_tbl(i).line_index                   := p_line_scredit_varray(i).line_index;
      x_line_scredit_tbl(i).orig_sys_credit_ref	   := p_line_scredit_varray(i).orig_sys_credit_ref;
      x_line_scredit_tbl(i).change_request_code	   := p_line_scredit_varray(i).change_request_code;
      x_line_scredit_tbl(i).status_flag	           := p_line_scredit_varray(i).status_flag;

i := p_line_scredit_varray.NEXT(i);

END LOOP;

END Line_Scredit_Var_To_Tbl;


-- Lot Serials

PROCEDURE Lot_Serial_Var_To_Tbl
(
    p_lot_serial_varray 	IN 	SYSTEM.ASO_Lot_Serial_Var_Type,
    x_lot_serial_tbl     OUT NOCOPY /* file.sql.39 change */   	OE_Order_PUB.Lot_Serial_Tbl_Type
)
IS
i                          NUMBER;

BEGIN
  IF p_lot_serial_varray is NULL THEN
     x_lot_serial_tbl := OE_Order_PUB.G_MISS_LOT_SERIAL_TBL;
     return;
  END IF;

  i := p_lot_serial_varray.FIRST;
  WHILE i IS NOT NULL LOOP
      x_lot_serial_tbl(i).attribute1                   := p_lot_serial_varray(i).attribute1;
      x_lot_serial_tbl(i).attribute10                  := p_lot_serial_varray(i).attribute10;
      x_lot_serial_tbl(i).attribute11                  := p_lot_serial_varray(i).attribute11;
      x_lot_serial_tbl(i).attribute12                  := p_lot_serial_varray(i).attribute12;
      x_lot_serial_tbl(i).attribute13                  := p_lot_serial_varray(i).attribute13;
      x_lot_serial_tbl(i).attribute14                  := p_lot_serial_varray(i).attribute14;
      x_lot_serial_tbl(i).attribute15                  := p_lot_serial_varray(i).attribute15;
      x_lot_serial_tbl(i).attribute2                   := p_lot_serial_varray(i).attribute2;
      x_lot_serial_tbl(i).attribute3                   := p_lot_serial_varray(i).attribute3;
      x_lot_serial_tbl(i).attribute4                   := p_lot_serial_varray(i).attribute4;
      x_lot_serial_tbl(i).attribute5                   := p_lot_serial_varray(i).attribute5;
      x_lot_serial_tbl(i).attribute6                   := p_lot_serial_varray(i).attribute6;
      x_lot_serial_tbl(i).attribute7                   := p_lot_serial_varray(i).attribute7;
      x_lot_serial_tbl(i).attribute8                   := p_lot_serial_varray(i).attribute8;
      x_lot_serial_tbl(i).attribute9                   := p_lot_serial_varray(i).attribute9;
      x_lot_serial_tbl(i).context                      := p_lot_serial_varray(i).context;
      x_lot_serial_tbl(i).created_by                   := p_lot_serial_varray(i).created_by;
      x_lot_serial_tbl(i).creation_date                := p_lot_serial_varray(i).creation_date;
      x_lot_serial_tbl(i).from_serial_number           := p_lot_serial_varray(i).from_serial_number;
      x_lot_serial_tbl(i).last_updated_by              := p_lot_serial_varray(i).last_updated_by;
      x_lot_serial_tbl(i).last_update_date             := p_lot_serial_varray(i).last_update_date;
      x_lot_serial_tbl(i).last_update_login            := p_lot_serial_varray(i).last_update_login;
      x_lot_serial_tbl(i).line_id                      := p_lot_serial_varray(i).line_id;
      x_lot_serial_tbl(i).lot_number                   := p_lot_serial_varray(i).lot_number;
      x_lot_serial_tbl(i).lot_serial_id                := p_lot_serial_varray(i).lot_serial_id;
      x_lot_serial_tbl(i).quantity                     := p_lot_serial_varray(i).quantity;
      x_lot_serial_tbl(i).to_serial_number             := p_lot_serial_varray(i).to_serial_number;
      x_lot_serial_tbl(i).return_status                := p_lot_serial_varray(i).return_status;
      x_lot_serial_tbl(i).db_flag                      := p_lot_serial_varray(i).db_flag;
      x_lot_serial_tbl(i).operation                    := p_lot_serial_varray(i).operation;
      x_lot_serial_tbl(i).line_index                   := p_lot_serial_varray(i).line_index;
      x_lot_serial_tbl(i).orig_sys_lotserial_ref       := p_lot_serial_varray(i).orig_sys_lotserial_ref;
      x_lot_serial_tbl(i).change_request_code	       := p_lot_serial_varray(i).change_request_code;
      x_lot_serial_tbl(i).status_flag	               := p_lot_serial_varray(i).status_flag;
      x_lot_serial_tbl(i).line_set_id                  := p_lot_serial_varray(i).line_set_id;

i := p_lot_serial_varray.NEXT(i);

END LOOP;

END Lot_Serial_Var_To_Tbl;


-- Action Requests

PROCEDURE Action_Request_Var_To_Tbl
(
    p_action_request_varray 	IN 	SYSTEM.ASO_Request_Var_Type,
    x_action_request_tbl     OUT NOCOPY /* file.sql.39 change */   	OE_Order_PUB.Request_Tbl_Type
)
IS
i                          NUMBER;

BEGIN
  IF p_action_request_varray is NULL THEN
     x_action_request_tbl := OE_Order_PUB.G_MISS_REQUEST_TBL;
     return;
  END IF;

  i := p_action_request_varray.FIRST;
  WHILE i IS NOT NULL LOOP
      x_action_request_tbl(i).entity_code                  := p_action_request_varray(i).entity_code;
      x_action_request_tbl(i).entity_id                    := p_action_request_varray(i).entity_id;
      x_action_request_tbl(i).entity_index                 := p_action_request_varray(i).entity_index;
      x_action_request_tbl(i).request_type                 := p_action_request_varray(i).request_type;
      x_action_request_tbl(i).return_status                := p_action_request_varray(i).return_status;
      x_action_request_tbl(i).request_unique_key1          := p_action_request_varray(i).request_unique_key1;
      x_action_request_tbl(i).request_unique_key2          := p_action_request_varray(i).request_unique_key2;
      x_action_request_tbl(i).request_unique_key3          := p_action_request_varray(i).request_unique_key3;
      x_action_request_tbl(i).request_unique_key4          := p_action_request_varray(i).request_unique_key4;
      x_action_request_tbl(i).request_unique_key5          := p_action_request_varray(i).request_unique_key5;
      x_action_request_tbl(i).param1                       := p_action_request_varray(i).param1;
      x_action_request_tbl(i).param2                       := p_action_request_varray(i).param2;
      x_action_request_tbl(i).param3                       := p_action_request_varray(i).param3;
      x_action_request_tbl(i).param4                       := p_action_request_varray(i).param4;
      x_action_request_tbl(i).param5                       := p_action_request_varray(i).param5;
      x_action_request_tbl(i).param6                       := p_action_request_varray(i).param6;
      x_action_request_tbl(i).param7                       := p_action_request_varray(i).param7;
      x_action_request_tbl(i).param8                       := p_action_request_varray(i).param8;
      x_action_request_tbl(i).param9                       := p_action_request_varray(i).param9;
      x_action_request_tbl(i).param10                      := p_action_request_varray(i).param10;
      x_action_request_tbl(i).param11                      := p_action_request_varray(i).param11;
      x_action_request_tbl(i).param12                      := p_action_request_varray(i).param12;
      x_action_request_tbl(i).param13                      := p_action_request_varray(i).param13;
      x_action_request_tbl(i).param14                      := p_action_request_varray(i).param14;
      x_action_request_tbl(i).param15                      := p_action_request_varray(i).param15;
      x_action_request_tbl(i).param16                      := p_action_request_varray(i).param16;
      x_action_request_tbl(i).param17                      := p_action_request_varray(i).param17;
      x_action_request_tbl(i).param18                      := p_action_request_varray(i).param18;
      x_action_request_tbl(i).param19                      := p_action_request_varray(i).param19;
      x_action_request_tbl(i).param20                      := p_action_request_varray(i).param20;
      x_action_request_tbl(i).param21                      := p_action_request_varray(i).param21;
      x_action_request_tbl(i).param22                      := p_action_request_varray(i).param22;
      x_action_request_tbl(i).param23                      := p_action_request_varray(i).param23;
      x_action_request_tbl(i).param24                      := p_action_request_varray(i).param24;
      x_action_request_tbl(i).param25                      := p_action_request_varray(i).param25;
      x_action_request_tbl(i).long_param1                  := p_action_request_varray(i).long_param1;
      x_action_request_tbl(i).date_param1                  := p_action_request_varray(i).date_param1;
      x_action_request_tbl(i).date_param2                  := p_action_request_varray(i).date_param2;
      x_action_request_tbl(i).date_param3                  := p_action_request_varray(i).date_param3;
      x_action_request_tbl(i).date_param4                  := p_action_request_varray(i).date_param4;
      x_action_request_tbl(i).date_param5                  := p_action_request_varray(i).date_param5;
      x_action_request_tbl(i).processed                    := p_action_request_varray(i).processed;

i := p_action_request_varray.NEXT(i);

END LOOP;

END Action_Request_Var_To_Tbl;


-- Start of comments
--  API name   : GET_NOTICE
--  Type       : Private
--  Function   : This API is the PRIVATE API that is invoked by CRM Apps
--               to get the data regarding changes (inserts/updates/deletes) to the
--               Order Entities communicated by the Order Management application.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--   p_commit            IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY /* file.sql.39 change */    Parameters:
--   x_return_status     OUT NOCOPY /* file.sql.39 change */     VARCHAR2(1)
--   x_msg_count         OUT NOCOPY /* file.sql.39 change */     NUMBER
--   x_msg_data          OUT NOCOPY /* file.sql.39 change */     VARCHAR2(2000)
--
--  GET_NOTICE API specific IN Parameters:
--   p_app_short_name    IN   VARCHAR2    Required
--   p_queue_type        IN   VARCHAR2    Optional
--                                        Default = OF_QUEUE
--   p_dequeue_mode      IN   NUMBER      Optional
--                                        Default = DBMS_AQ.REMOVE
--   p_dequeue_navigation IN   NUMBER     Optional
--                                        Default = DBMS_AQ.FIRST_MESSAGE
--   p_wait              IN   NUMBER      Optional
--                                        Default = DBMS_AQ.NO_WAIT
--
--  GET_NOTICE API specific OUT NOCOPY /* file.sql.39 change */    Parameters:
--
--   x_no_more_messages              OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--   x_Header_rec                    OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Rec_Type
--   x_old_Header_rec                OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Rec_Type
--   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Adj_Tbl_Type
--   x_old_Header_Adj_tbl            OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Adj_Tbl_Type
--   x_Header_Price_Att_tbl          OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Price_Att_Tbl_Type
--   x_old_Header_Price_Att_tbl      OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Price_Att_Tbl_Type
--   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Adj_Att_Tbl_Type
--   x_old_Header_Adj_Att_tbl        OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Adj_Att_Tbl_Type
--   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
--   x_old_Header_Adj_Assoc_tbl      OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Adj_Assoc_Tbl_Type
--   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Scredit_Tbl_Type
--   x_old_Header_Scredit_tbl        OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Scredit_Tbl_Type
--   x_Line_tbl                      OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Tbl_Type
--   x_old_Line_tbl                  OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Tbl_Type
--   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Adj_Tbl_Type
--   x_old_Line_Adj_tbl              OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Adj_Tbl_Type
--   x_Line_Price_Att_tbl            OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Price_Att_Tbl_Type
--   x_old_Line_Price_Att_tbl        OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Price_Att_Tbl_Type
--   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Adj_Att_Tbl_Type
--   x_old_Line_Adj_Att_tbl          OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Adj_Att_Tbl_Type
--   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
--   x_old_Line_Adj_Assoc_tbl        OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Adj_Assoc_Tbl_Type
--   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Scredit_Tbl_Type
--   x_old_Line_Scredit_tbl          OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Scredit_Tbl_Type
--   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Lot_Serial_Tbl_Type
--   x_old_Lot_Serial_tbl            OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Lot_Serial_Tbl_Type
--   x_Action_Request_tbl            OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Request_Tbl_Type
--
--
--  Version :  Current version   1.0
--             Initial version   1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE GET_NOTICE
(
 p_api_version                   IN   NUMBER,
 p_init_msg_list                 IN   VARCHAR2   DEFAULT FND_API.G_FALSE,
 p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE,
 x_return_status                 OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
 x_msg_count                     OUT NOCOPY /* file.sql.39 change */     NUMBER,
 x_msg_data                      OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
 p_app_short_name                IN   VARCHAR2,
 p_queue_type                    IN   VARCHAR2   DEFAULT 'OF_QUEUE',
 p_dequeue_mode                  IN   NUMBER     DEFAULT DBMS_AQ.REMOVE,
 p_navigation                    IN   NUMBER     DEFAULT DBMS_AQ.FIRST_MESSAGE,
 p_wait                          IN   NUMBER     DEFAULT DBMS_AQ.NO_WAIT,
 p_deq_condition                 IN   VARCHAR2  DEFAULT NULL, /* Bug 9410311 */
 x_no_more_messages              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
 x_Header_rec                    OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Rec_Type,
 x_old_Header_rec                OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Rec_Type,
 x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Adj_Tbl_Type,
 x_old_Header_Adj_tbl            OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Adj_Tbl_Type,
 x_Header_Price_Att_tbl          OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Price_Att_Tbl_Type,
 x_old_Header_Price_Att_tbl      OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Price_Att_Tbl_Type,
 x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Adj_Att_Tbl_Type,
 x_old_Header_Adj_Att_tbl        OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Adj_Att_Tbl_Type,
 x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Adj_Assoc_Tbl_Type,
 x_old_Header_Adj_Assoc_tbl      OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Adj_Assoc_Tbl_Type,
 x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Scredit_Tbl_Type,
 x_old_Header_Scredit_tbl        OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Header_Scredit_Tbl_Type,
 x_Line_tbl                      OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Tbl_Type,
 x_old_Line_tbl                  OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Tbl_Type,
 x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Adj_Tbl_Type,
 x_old_Line_Adj_tbl              OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Adj_Tbl_Type,
 x_Line_Price_Att_tbl            OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Price_Att_Tbl_Type,
 x_old_Line_Price_Att_tbl        OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Price_Att_Tbl_Type,
 x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Adj_Att_Tbl_Type,
 x_old_Line_Adj_Att_tbl          OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Adj_Att_Tbl_Type,
 x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Adj_Assoc_Tbl_Type,
 x_old_Line_Adj_Assoc_tbl        OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Adj_Assoc_Tbl_Type,
 x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Scredit_Tbl_Type,
 x_old_Line_Scredit_tbl          OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Line_Scredit_Tbl_Type,
 x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Lot_Serial_Tbl_Type,
 x_old_Lot_Serial_tbl            OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Lot_Serial_Tbl_Type,
 x_Action_Request_tbl            OUT NOCOPY /* file.sql.39 change */     OE_Order_PUB.Request_Tbl_Type
) IS
   i                          number;
   l_api_name     CONSTANT    VARCHAR2(30)   := 'GET_NOTICE';
   l_api_version  CONSTANT    NUMBER         := 1.0;
   l_queue_name               VARCHAR2(30);
   l_dequeue_options          dbms_aq.dequeue_options_t;
   l_message_properties       dbms_aq.message_properties_t;
   l_msg_id                   RAW(16);
   l_message                  SYSTEM.ASO_Order_Feedback_Type;
   l_Header_rec               OE_Order_PUB.Header_Rec_Type;
   l_old_Header_rec           OE_Order_PUB.Header_Rec_Type;
   l_Header_Adj_tbl           OE_Order_PUB.Header_Adj_Tbl_Type;
   l_old_Header_Adj_tbl       OE_Order_PUB.Header_Adj_Tbl_Type;
   l_Header_Price_Att_tbl     OE_Order_PUB.Header_Price_Att_Tbl_Type;
   l_old_Header_Price_Att_tbl OE_Order_PUB.Header_Price_Att_Tbl_Type;
   l_Header_Adj_Att_tbl       OE_Order_PUB.Header_Adj_Att_Tbl_Type;
   l_old_Header_Adj_Att_tbl   OE_Order_PUB.Header_Adj_Att_Tbl_Type;
   l_Header_Adj_Assoc_tbl     OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
   l_old_Header_Adj_Assoc_tbl OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
   l_Header_Scredit_tbl       OE_Order_PUB.Header_Scredit_Tbl_Type;
   l_old_Header_Scredit_tbl   OE_Order_PUB.Header_Scredit_Tbl_Type;
   l_Line_tbl                 OE_Order_PUB.Line_Tbl_Type;
   l_old_Line_tbl             OE_Order_PUB.Line_Tbl_Type;
   l_Line_Adj_tbl             OE_Order_PUB.Line_Adj_Tbl_Type;
   l_old_Line_Adj_tbl         OE_Order_PUB.Line_Adj_Tbl_Type;
   l_Line_Price_Att_tbl       OE_Order_PUB.Line_Price_Att_Tbl_Type;
   l_old_Line_Price_Att_tbl   OE_Order_PUB.Line_Price_Att_Tbl_Type;
   l_Line_Adj_Att_tbl         OE_Order_PUB.Line_Adj_Att_Tbl_Type;
   l_old_Line_Adj_Att_tbl     OE_Order_PUB.Line_Adj_Att_Tbl_Type;
   l_Line_Adj_Assoc_tbl       OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
   l_old_Line_Adj_Assoc_tbl   OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
   l_Line_Scredit_tbl         OE_Order_PUB.Line_Scredit_Tbl_Type;
   l_old_Line_Scredit_tbl     OE_Order_PUB.Line_Scredit_Tbl_Type;
   l_Lot_Serial_tbl           OE_Order_PUB.Lot_Serial_Tbl_Type;
   l_old_Lot_Serial_tbl       OE_Order_PUB.Lot_Serial_Tbl_Type;
   l_Action_Request_tbl       OE_Order_PUB.Request_Tbl_Type;
   no_message                 EXCEPTION;
   pragma                     EXCEPTION_INIT(no_message, -25228);

BEGIN
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_GET_PVT.GET_NOTICE',1,'Y');
 END IF;
   -- Standard Start of API savepoint

   SAVEPOINT   GET_NOTICE_PVT;

   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version ,
                         p_api_version ,
                         l_api_name ,
                         G_PKG_NAME )  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --  Initialize output no_more_messages to FND_API.G_FALSE;

   x_no_more_messages := FND_API.G_FALSE;

   -- GET_NOTICE API specific input parameter validation logic

   -- API Body

   -- Assign dequeue parameters

   IF UPPER(p_queue_type) = 'OF_QUEUE' THEN
      l_queue_name                 := ASO_QUEUE.ASO_OF_Q;
   ELSIF UPPER(p_queue_type) = 'OF_EXCP_QUEUE' THEN
      l_queue_name                 := ASO_QUEUE.ASO_OF_EXCP_Q;
   END IF;

   l_dequeue_options.consumer_name := p_app_short_name;

   l_dequeue_options.dequeue_mode  := p_dequeue_mode;

   l_dequeue_options.navigation    := p_navigation;

   l_dequeue_options.wait          := p_wait;

   /* Added this deq_condition for OZF product bug 9410311 */
   If p_deq_condition is not null then
      l_dequeue_options.deq_condition := p_deq_condition;
   End if;

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('ASO_ORDER_FEEDBACK_GET_PVT.GET_NOTICE l_dequeue_options.consumer_name' || l_dequeue_options.consumer_name,1,'Y');
			aso_debug_pub.add('ASO_ORDER_FEEDBACK_GET_PVT.GET_NOTICE l_dequeue_options.dequeue_mode' || l_dequeue_options.dequeue_mode,1,'Y');
			aso_debug_pub.add('ASO_ORDER_FEEDBACK_GET_PVT.GET_NOTICE l_dequeue_options.navigation' || l_dequeue_options.navigation,1,'Y');
			aso_debug_pub.add('ASO_ORDER_FEEDBACK_GET_PVT.GET_NOTICE l_dequeue_options.wait ' || l_dequeue_options.wait ,1,'Y');
			aso_debug_pub.add('Before dbms_aq.dequeue' ,1,'Y');

 END IF;
   -- Dequeue a message

   dbms_aq.dequeue(
       queue_name => l_queue_name,
       dequeue_options => l_dequeue_options,
       message_properties => l_message_properties,
       payload => l_message,
       msgid => l_msg_id);

IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	aso_debug_pub.add('After dbms_aq.dequeue' ,1,'Y');
END IF;
-- Convert message object to output records and tables

   Header_Type_To_Rec
   (p_header_type                   => l_message.header_type,
    x_header_rec                    => l_header_rec
   );

   Header_Type_To_Rec
   (p_header_type                   => l_message.old_header_type,
    x_header_rec                    => l_old_header_rec
   );

   Header_Adj_Var_To_Tbl
   (p_header_adj_varray             => l_message.header_adj_varray,
    x_header_adj_tbl                => l_header_adj_tbl
   );

   Header_Adj_Var_To_Tbl
   (p_header_adj_varray             => l_message.old_header_adj_varray,
    x_header_adj_tbl                => l_old_header_adj_tbl
   );

   Header_Price_Att_Var_To_Tbl
   (p_header_price_att_varray       => l_message.header_price_att_varray,
    x_header_price_att_tbl          => l_header_price_att_tbl
   );

   Header_Price_Att_Var_To_Tbl
   (p_header_price_att_varray       => l_message.old_header_price_att_varray,
    x_header_price_att_tbl          => l_old_header_price_att_tbl
   );

   Header_Adj_Att_Var_To_Tbl
   (p_header_adj_att_varray         => l_message.header_adj_att_varray,
    x_header_adj_att_tbl            => l_header_adj_att_tbl
   );

   Header_Adj_Att_Var_To_Tbl
   (p_header_adj_att_varray         => l_message.old_header_adj_att_varray,
    x_header_adj_att_tbl            => l_old_header_adj_att_tbl
   );

   Header_Adj_Assoc_Var_To_Tbl
   (p_header_adj_assoc_varray       => l_message.header_adj_assoc_varray,
    x_header_adj_assoc_tbl          => l_header_adj_assoc_tbl
   );

   Header_Adj_Assoc_Var_To_Tbl
   (p_header_adj_assoc_varray       => l_message.old_header_adj_assoc_varray,
    x_header_adj_assoc_tbl          => l_old_header_adj_assoc_tbl
   );

   Header_Scredit_Var_To_Tbl
   (p_header_scredit_varray         => l_message.header_scredit_varray,
    x_header_scredit_tbl            => l_header_scredit_tbl
   );

   Header_Scredit_Var_To_Tbl
   (p_header_scredit_varray         => l_message.old_header_scredit_varray,
    x_header_scredit_tbl            => l_old_header_scredit_tbl
   );

   Line_Var_To_Tbl
   (p_line_varray                   => l_message.line_varray,
    x_line_tbl                      => l_line_tbl
   );

   Line_Var_To_Tbl
   (p_line_varray                   => l_message.old_line_varray,
    x_line_tbl                      => l_old_line_tbl
   );

   Line_Adj_Var_To_Tbl
   (p_line_adj_varray               => l_message.line_adj_varray,
    x_line_adj_tbl                  => l_line_adj_tbl
   );

   Line_Adj_Var_To_Tbl
   (p_line_adj_varray               => l_message.old_line_adj_varray,
    x_line_adj_tbl                  => l_old_line_adj_tbl
   );

   Line_Price_Att_Var_To_Tbl
   (p_line_price_att_varray         => l_message.line_price_att_varray,
    x_line_price_att_tbl            => l_line_price_att_tbl
   );

   Line_Price_Att_Var_To_Tbl
   (p_line_price_att_varray         => l_message.old_line_price_att_varray,
    x_line_price_att_tbl            => l_old_line_price_att_tbl
   );

   Line_Adj_Att_Var_To_Tbl
   (p_line_adj_att_varray           => l_message.line_adj_att_varray,
    x_line_adj_att_tbl              => l_line_adj_att_tbl
   );

   Line_Adj_Att_Var_To_Tbl
   (p_line_adj_att_varray           => l_message.old_line_adj_att_varray,
    x_line_adj_att_tbl              => l_old_line_adj_att_tbl
   );

   Line_Adj_Assoc_Var_To_Tbl
   (p_line_adj_assoc_varray         => l_message.line_adj_assoc_varray,
    x_line_adj_assoc_tbl            => l_line_adj_assoc_tbl
   );

   Line_Adj_Assoc_Var_To_Tbl
   (p_line_adj_assoc_varray         => l_message.old_line_adj_assoc_varray,
    x_line_adj_assoc_tbl            => l_old_line_adj_assoc_tbl
   );

   Line_Scredit_Var_To_Tbl
   (p_line_scredit_varray           => l_message.line_scredit_varray,
    x_line_scredit_tbl              => l_line_scredit_tbl
   );

   Line_Scredit_Var_To_Tbl
   (p_line_scredit_varray           => l_message.old_line_scredit_varray,
    x_line_scredit_tbl              => l_old_line_scredit_tbl
   );

   Lot_Serial_Var_To_Tbl
   (p_lot_serial_varray             => l_message.lot_serial_varray,
    x_lot_serial_tbl                => l_lot_serial_tbl
   );

   Lot_Serial_Var_To_Tbl
   (p_lot_serial_varray             => l_message.old_lot_serial_varray,
    x_lot_serial_tbl                => l_old_lot_serial_tbl
   );

   Action_Request_Var_To_Tbl
   (p_action_request_varray             => l_message.action_request_varray,
    x_action_request_tbl                => l_action_request_tbl
   );



-- Done processing, load OUT NOCOPY /* file.sql.39 change */    parameters

   x_Header_rec                    :=  l_Header_rec;
   x_old_Header_rec                :=  l_old_Header_rec;
   x_Header_Adj_tbl                :=  l_Header_Adj_tbl;
   x_old_Header_Adj_tbl            :=  l_old_Header_Adj_tbl;
   x_Header_Price_Att_tbl          :=  l_Header_Price_Att_tbl;
   x_old_Header_Price_Att_tbl      :=  l_old_Header_Price_Att_tbl;
   x_Header_Adj_Att_tbl            :=  l_Header_Adj_Att_tbl;
   x_old_Header_Adj_Att_tbl        :=  l_old_Header_Adj_Att_tbl;
   x_Header_Adj_Assoc_tbl          :=  l_Header_Adj_Assoc_tbl;
   x_old_Header_Adj_Assoc_tbl      :=  l_old_Header_Adj_Assoc_tbl;
   x_Header_Scredit_tbl            :=  l_Header_Scredit_tbl;
   x_old_Header_Scredit_tbl        :=  l_old_Header_Scredit_tbl;
   x_Line_tbl                      :=  l_Line_tbl;
   x_old_Line_tbl                  :=  l_old_Line_tbl;
   x_Line_Adj_tbl                  :=  l_Line_Adj_tbl;
   x_old_Line_Adj_tbl              :=  l_old_Line_Adj_tbl;
   x_Line_Price_Att_tbl            :=  l_Line_Price_Att_tbl;
   x_old_Line_Price_Att_tbl        :=  l_old_Line_Price_Att_tbl;
   x_Line_Adj_Att_tbl              :=  l_Line_Adj_Att_tbl;
   x_old_Line_Adj_Att_tbl          :=  l_old_Line_Adj_Att_tbl;
   x_Line_Adj_Assoc_tbl            :=  l_Line_Adj_Assoc_tbl;
   x_old_Line_Adj_Assoc_tbl        :=  l_old_Line_Adj_Assoc_tbl;
   x_Line_Scredit_tbl              :=  l_Line_Scredit_tbl;
   x_old_Line_Scredit_tbl          :=  l_old_Line_Scredit_tbl;
   x_Lot_Serial_tbl                :=  l_Lot_Serial_tbl;
   x_old_Lot_Serial_tbl            :=  l_old_Lot_Serial_tbl;
   x_Action_Request_tbl            :=  l_Action_Request_tbl;


   -- Standard check of p_commit.

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.

   FND_MSG_PUB.Count_And_Get
      (p_count => x_msg_count ,
         p_data => x_msg_data
      );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO  GET_NOTICE_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count ,
          p_data => x_msg_data
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  GET_NOTICE_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count ,
          p_data => x_msg_data
         );
   WHEN no_message then
--      dbms_output.put_line('No more messages');
      x_no_more_messages := FND_API.G_TRUE;
   WHEN OTHERS THEN
      ROLLBACK TO GET_NOTICE_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
         (p_count => x_msg_count ,
          p_data => x_msg_data
         );
END GET_NOTICE;


END ASO_ORDER_FEEDBACK_GET_PVT;

/
