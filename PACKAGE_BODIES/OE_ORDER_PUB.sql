--------------------------------------------------------
--  DDL for Package Body OE_ORDER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_PUB" AS
/* $Header: OEXPORDB.pls 120.14.12010000.10 2011/02/25 09:41:40 snimmaga ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Order_PUB';


--  Header record type

FUNCTION G_MISS_HEADER_REC RETURN Header_Rec_Type IS
l_record				Header_Rec_Type;
BEGIN

    l_record.accounting_rule_id              := FND_API.G_MISS_NUM;
    l_record.accounting_rule_duration        := FND_API.G_MISS_NUM;
    l_record.agreement_id                    := FND_API.G_MISS_NUM;
    l_record.attribute1                      := FND_API.G_MISS_CHAR;
    l_record.attribute10                     := FND_API.G_MISS_CHAR;
    l_record.attribute11                     := FND_API.G_MISS_CHAR;
    l_record.attribute12                     := FND_API.G_MISS_CHAR;
    l_record.attribute13                     := FND_API.G_MISS_CHAR;
    l_record.attribute14                     := FND_API.G_MISS_CHAR;
    l_record.attribute15                     := FND_API.G_MISS_CHAR;
    l_record.attribute16                     := FND_API.G_MISS_CHAR;
    l_record.attribute17                     := FND_API.G_MISS_CHAR;
    l_record.attribute18                     := FND_API.G_MISS_CHAR;
    l_record.attribute19                     := FND_API.G_MISS_CHAR;
    l_record.attribute2                      := FND_API.G_MISS_CHAR;
    l_record.attribute20                     := FND_API.G_MISS_CHAR;
    l_record.attribute3                      := FND_API.G_MISS_CHAR;
    l_record.attribute4                      := FND_API.G_MISS_CHAR;
    l_record.attribute5                      := FND_API.G_MISS_CHAR;
    l_record.attribute6                      := FND_API.G_MISS_CHAR;
    l_record.attribute7                      := FND_API.G_MISS_CHAR;
    l_record.attribute8                      := FND_API.G_MISS_CHAR;
    l_record.attribute9                      := FND_API.G_MISS_CHAR;
    l_record.booked_flag                     := FND_API.G_MISS_CHAR;
    l_record.cancelled_flag                  := FND_API.G_MISS_CHAR;
    l_record.context                         := FND_API.G_MISS_CHAR;
    l_record.conversion_rate                 := FND_API.G_MISS_NUM;
    l_record.conversion_rate_date            := FND_API.G_MISS_DATE;
    l_record.conversion_type_code            := FND_API.G_MISS_CHAR;
    l_record.customer_preference_set_code    := FND_API.G_MISS_CHAR;
    l_record.created_by                      := FND_API.G_MISS_NUM;
    l_record.creation_date                   := FND_API.G_MISS_DATE;
    l_record.cust_po_number                  := FND_API.G_MISS_CHAR;
    l_record.deliver_to_contact_id           := FND_API.G_MISS_NUM;
    l_record.deliver_to_org_id               := FND_API.G_MISS_NUM;
    l_record.demand_class_code               := FND_API.G_MISS_CHAR;
    l_record.earliest_schedule_limit	  	:= FND_API.G_MISS_NUM;
    l_record.expiration_date                 := FND_API.G_MISS_DATE;
    l_record.fob_point_code                  := FND_API.G_MISS_CHAR;
    l_record.freight_carrier_code            := FND_API.G_MISS_CHAR;
    l_record.freight_terms_code              := FND_API.G_MISS_CHAR;
    l_record.global_attribute1               := FND_API.G_MISS_CHAR;
    l_record.global_attribute10              := FND_API.G_MISS_CHAR;
    l_record.global_attribute11              := FND_API.G_MISS_CHAR;
    l_record.global_attribute12              := FND_API.G_MISS_CHAR;
    l_record.global_attribute13              := FND_API.G_MISS_CHAR;
    l_record.global_attribute14              := FND_API.G_MISS_CHAR;
    l_record.global_attribute15              := FND_API.G_MISS_CHAR;
    l_record.global_attribute16              := FND_API.G_MISS_CHAR;
    l_record.global_attribute17              := FND_API.G_MISS_CHAR;
    l_record.global_attribute18              := FND_API.G_MISS_CHAR;
    l_record.global_attribute19              := FND_API.G_MISS_CHAR;
    l_record.global_attribute2               := FND_API.G_MISS_CHAR;
    l_record.global_attribute20              := FND_API.G_MISS_CHAR;
    l_record.global_attribute3               := FND_API.G_MISS_CHAR;
    l_record.global_attribute4               := FND_API.G_MISS_CHAR;
    l_record.global_attribute5               := FND_API.G_MISS_CHAR;
    l_record.global_attribute6               := FND_API.G_MISS_CHAR;
    l_record.global_attribute7               := FND_API.G_MISS_CHAR;
    l_record.global_attribute8               := FND_API.G_MISS_CHAR;
    l_record.global_attribute9               := FND_API.G_MISS_CHAR;
    l_record.global_attribute_category       := FND_API.G_MISS_CHAR;
    l_record.TP_CONTEXT                      := FND_API.G_MISS_CHAR;
    l_record.TP_ATTRIBUTE1                   := FND_API.G_MISS_CHAR;
    l_record.TP_ATTRIBUTE2                   := FND_API.G_MISS_CHAR;
    l_record.TP_ATTRIBUTE3                   := FND_API.G_MISS_CHAR;
    l_record.TP_ATTRIBUTE4                   := FND_API.G_MISS_CHAR;
    l_record.TP_ATTRIBUTE5                   := FND_API.G_MISS_CHAR;
    l_record.TP_ATTRIBUTE6                   := FND_API.G_MISS_CHAR;
    l_record.TP_ATTRIBUTE7                   := FND_API.G_MISS_CHAR;
    l_record.TP_ATTRIBUTE8                   := FND_API.G_MISS_CHAR;
    l_record.TP_ATTRIBUTE9                   := FND_API.G_MISS_CHAR;
    l_record.TP_ATTRIBUTE10                  := FND_API.G_MISS_CHAR;
    l_record.TP_ATTRIBUTE11                  := FND_API.G_MISS_CHAR;
    l_record.TP_ATTRIBUTE12                  := FND_API.G_MISS_CHAR;
    l_record.TP_ATTRIBUTE13                  := FND_API.G_MISS_CHAR;
    l_record.TP_ATTRIBUTE14                  := FND_API.G_MISS_CHAR;
    l_record.TP_ATTRIBUTE15                  := FND_API.G_MISS_CHAR;
    l_record.header_id                       := FND_API.G_MISS_NUM;
    l_record.invoice_to_contact_id           := FND_API.G_MISS_NUM;
    l_record.invoice_to_org_id               := FND_API.G_MISS_NUM;
    l_record.invoicing_rule_id               := FND_API.G_MISS_NUM;
    l_record.last_updated_by                 := FND_API.G_MISS_NUM;
    l_record.last_update_date                := FND_API.G_MISS_DATE;
    l_record.last_update_login               := FND_API.G_MISS_NUM;
    l_record.latest_schedule_limit           := FND_API.G_MISS_NUM;
    l_record.open_flag                       := FND_API.G_MISS_CHAR;
    l_record.order_category_code             := FND_API.G_MISS_CHAR;
    l_record.ordered_date                    := FND_API.G_MISS_DATE;
    l_record.order_date_type_code	     := FND_API.G_MISS_CHAR;
    l_record.order_number                    := FND_API.G_MISS_NUM;
    l_record.order_source_id                 := FND_API.G_MISS_NUM;
    l_record.order_type_id                   := FND_API.G_MISS_NUM;
    l_record.org_id                          := FND_API.G_MISS_NUM;
    l_record.orig_sys_document_ref           := FND_API.G_MISS_CHAR;
    l_record.partial_shipments_allowed       := FND_API.G_MISS_CHAR;
    l_record.payment_term_id                 := FND_API.G_MISS_NUM;
    l_record.price_list_id                   := FND_API.G_MISS_NUM;
    l_record.pricing_date                    := FND_API.G_MISS_DATE;
    l_record.program_application_id          := FND_API.G_MISS_NUM;
    l_record.program_id                      := FND_API.G_MISS_NUM;
    l_record.program_update_date             := FND_API.G_MISS_DATE;
    l_record.request_date                    := FND_API.G_MISS_DATE;
    l_record.request_id                      := FND_API.G_MISS_NUM;
    l_record.return_reason_code		     := FND_API.G_MISS_CHAR;
    l_record.salesrep_id		     := FND_API.G_MISS_NUM;
    l_record.sales_channel_code              := FND_API.G_MISS_CHAR;
    l_record.shipment_priority_code          := FND_API.G_MISS_CHAR;
    l_record.shipping_method_code            := FND_API.G_MISS_CHAR;
    l_record.ship_from_org_id                := FND_API.G_MISS_NUM;
    l_record.ship_tolerance_above            := FND_API.G_MISS_NUM;
    l_record.ship_tolerance_below            := FND_API.G_MISS_NUM;
    l_record.ship_to_contact_id              := FND_API.G_MISS_NUM;
    l_record.ship_to_org_id                  := FND_API.G_MISS_NUM;
    l_record.sold_from_org_id		     := FND_API.G_MISS_NUM;
    l_record.sold_to_contact_id              := FND_API.G_MISS_NUM;
    l_record.sold_to_org_id                  := FND_API.G_MISS_NUM;
    l_record.sold_to_phone_id                := FND_API.G_MISS_NUM;
    l_record.source_document_id              := FND_API.G_MISS_NUM;
    l_record.source_document_type_id         := FND_API.G_MISS_NUM;
    l_record.tax_exempt_flag                 := FND_API.G_MISS_CHAR;
    l_record.tax_exempt_number               := FND_API.G_MISS_CHAR;
    l_record.tax_exempt_reason_code          := FND_API.G_MISS_CHAR;
    l_record.tax_point_code                  := FND_API.G_MISS_CHAR;
    l_record.transactional_curr_code         := FND_API.G_MISS_CHAR;
    l_record.version_number                  := FND_API.G_MISS_NUM;
    l_record.return_status                   := FND_API.G_MISS_CHAR;
    l_record.db_flag                         := FND_API.G_MISS_CHAR;
    l_record.operation                       := FND_API.G_MISS_CHAR;
    l_record.first_ack_code                  := FND_API.G_MISS_CHAR;
    l_record.first_ack_date                  := FND_API.G_MISS_DATE;
    l_record.last_ack_code                   := FND_API.G_MISS_CHAR;
    l_record.last_ack_date                   := FND_API.G_MISS_DATE;
    l_record.change_reason                   := FND_API.G_MISS_CHAR;
    l_record.change_comments                 := FND_API.G_MISS_CHAR;
    l_record.change_sequence 	  	     := FND_API.G_MISS_CHAR;
    l_record.change_request_code	     := FND_API.G_MISS_CHAR;
    l_record.ready_flag		  	     := FND_API.G_MISS_CHAR;
    l_record.status_flag		     := FND_API.G_MISS_CHAR;
    l_record.force_apply_flag		     := FND_API.G_MISS_CHAR;
    l_record.drop_ship_flag		     := FND_API.G_MISS_CHAR;
    l_record.customer_payment_term_id	     := FND_API.G_MISS_NUM;
    l_record.payment_type_code               := FND_API.G_MISS_CHAR;
    l_record.payment_amount                  := FND_API.G_MISS_NUM;
    l_record.check_number                    := FND_API.G_MISS_CHAR;
    l_record.credit_card_code                := FND_API.G_MISS_CHAR;
    l_record.credit_card_holder_name         := FND_API.G_MISS_CHAR;
    l_record.credit_card_number              := FND_API.G_MISS_CHAR;
    l_record.credit_card_expiration_date     := FND_API.G_MISS_DATE;
    l_record.credit_card_approval_code       := FND_API.G_MISS_CHAR;
    l_record.credit_card_approval_date       := FND_API.G_MISS_DATE;
    l_record.shipping_instructions           := FND_API.G_MISS_CHAR;
    l_record.packing_instructions            := FND_API.G_MISS_CHAR;
    l_record.flow_status_code                := 'ENTERED';
    l_record.booked_date	    	     := FND_API.G_MISS_DATE;
    l_record.marketing_source_code_id        := FND_API.G_MISS_NUM;
    l_record.upgraded_flag                   := FND_API.G_MISS_CHAR;
    l_record.ship_to_customer_id             := FND_API.G_MISS_NUM;
    l_record.invoice_to_customer_id          := FND_API.G_MISS_NUM;
    l_record.deliver_to_customer_id          := FND_API.G_MISS_NUM;
    l_record.Blanket_Number                  := FND_API.G_MISS_NUM;
    l_record.minisite_Id                     := FND_API.G_MISS_NUM;
    l_record.IB_OWNER                        := FND_API.G_MISS_CHAR;
    l_record.IB_INSTALLED_AT_LOCATION        := FND_API.G_MISS_CHAR;
    l_record.IB_CURRENT_LOCATION             := FND_API.G_MISS_CHAR;
    l_record.END_CUSTOMER_ID                 := FND_API.G_MISS_NUM;
    l_record.END_CUSTOMER_CONTACT_ID         := FND_API.G_MISS_NUM;
    l_record.END_CUSTOMER_SITE_USE_ID        := FND_API.G_MISS_NUM;
    l_record.SUPPLIER_SIGNATURE           := FND_API.G_MISS_CHAR;
    l_record.SUPPLIER_SIGNATURE_DATE      := FND_API.G_MISS_DATE;
    l_record.CUSTOMER_SIGNATURE           := FND_API.G_MISS_CHAR;
    l_record.CUSTOMER_SIGNATURE_DATE      := FND_API.G_MISS_DATE;
----
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN

    l_record.Default_Fulfillment_Set         := FND_API.G_MISS_CHAR;
    l_record.Line_Set_Name                   := FND_API.G_MISS_CHAR;
    l_record.Fulfillment_Set_Name            := FND_API.G_MISS_CHAR;

    -- Quoting Changes
    l_record.quote_date                      := FND_API.G_MISS_DATE;
    l_record.quote_number                    := FND_API.G_MISS_NUM;
    l_record.sales_document_name             := FND_API.G_MISS_CHAR;
    l_record.transaction_phase_code          := FND_API.G_MISS_CHAR;
    l_record.user_status_code                := FND_API.G_MISS_CHAR;
    l_record.draft_submitted_flag            := FND_API.G_MISS_CHAR;
    l_record.source_document_version_number  := FND_API.G_MISS_NUM;
    l_record.sold_to_site_use_id             := FND_API.G_MISS_NUM;
    -- Contract Changes
    l_record.contract_template_id            := FND_API.G_MISS_NUM;
    l_record.contract_source_doc_type_code  := FND_API.G_MISS_CHAR;
    l_record.contract_source_document_id     := FND_API.G_MISS_NUM;

    -- distributed orders
    l_record.IB_owner                        := FND_API.G_MISS_CHAR;
    l_record.IB_installed_at_location        := FND_API.G_MISS_CHAR;
    l_record.IB_current_location             := FND_API.G_MISS_CHAR;
    l_record.end_customer_id                 := FND_API.G_MISS_NUM;
    l_record.end_customer_contact_id         := FND_API.G_MISS_NUM;
    l_record.end_customer_site_use_id        := FND_API.G_MISS_NUM;
    --8219019 start
    l_record.CC_INSTRUMENT_ID               := FND_API.G_MISS_NUM;
    l_record.CC_INSTRUMENT_ASSIGNMENT_ID    := FND_API.G_MISS_NUM;
    --8219019 end
    END IF;

--key Transaction Dates
    IF  OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110509' THEN
    l_record.order_firmed_date  	     := FND_API.G_MISS_DATE;
    END IF ;

    RETURN l_record;

END G_MISS_HEADER_REC;


procedure set_context   (p_org_id in number) is
   l_org_id number ;
   l_return_status varchar2(1);
   l_debug_level  CONSTANT NUMBER := oe_debug_pub.g_debug_level;
begin
   l_org_id := p_org_id;
   if l_debug_level  > 0 then
    oe_debug_pub.add('Entering set_context');
    oe_debug_pub.add('Org_id is '||nvl(p_org_id,-1));
   end if;
   MO_GLOBAL.validate_orgid_pub_api(org_id=>l_org_id , status=>l_return_status);
   if l_debug_level  > 0 then
     oe_debug_pub.add('After call to mo_global.validate_orgid_pub_api Org_id'||l_org_id|| 'Return status'||nvl(l_return_status,'?'));
   end if;
   --If return status is O then we need not do anythinf (backward compatibility)
   --If return status is F then raise error
   --If return status is S (in case org_id was passed to process order API) then set context to the passed org_id
   --If return status is C/D ( in case org_id was not passed to process order API) then check for default org_id
   -- and if this is null raise error else set context to the default org_id .
   --Status C means current_org_id and D means default org_id ,even if mo_global returns C we will get default org_id
       if l_return_status ='O' then
          null;
       elsif l_return_status='F' then
          raise FND_API.G_EXC_ERROR;
       else
	  If p_org_id is null then -- In this case we will look at org_id passed to process order API and not that which is returned by mo_global.validate_pub_api
              if l_debug_level  > 0 then
                 oe_debug_pub.add('Before call to mo_utils.get_default_orgid');
             end if;
             l_org_id :=mo_utils.get_default_org_id ;
             if l_debug_level  > 0 then
                 oe_debug_pub.add('Default org_id is '||l_org_id );
             end if;
	     if l_org_id is null then
               raise FND_API.G_EXC_ERROR;
             end if;
          end if;
          MO_GLOBAL.set_policy_context('S',l_org_id);
          OE_GLOBALS.Set_Context();
       end if;
end ;

--  Header_Adj record type

FUNCTION G_MISS_HEADER_ADJ_REC RETURN Header_Adj_Rec_Type IS
l_record            Header_Adj_Rec_Type;
BEGIN

    l_record.attribute1                      := FND_API.G_MISS_CHAR;
    l_record.attribute10                     := FND_API.G_MISS_CHAR;
    l_record.attribute11                     := FND_API.G_MISS_CHAR;
    l_record.attribute12                     := FND_API.G_MISS_CHAR;
    l_record.attribute13                     := FND_API.G_MISS_CHAR;
    l_record.attribute14                     := FND_API.G_MISS_CHAR;
    l_record.attribute15                     := FND_API.G_MISS_CHAR;
    l_record.attribute2                      := FND_API.G_MISS_CHAR;
    l_record.attribute3                      := FND_API.G_MISS_CHAR;
    l_record.attribute4                      := FND_API.G_MISS_CHAR;
    l_record.attribute5                      := FND_API.G_MISS_CHAR;
    l_record.attribute6                      := FND_API.G_MISS_CHAR;
    l_record.attribute7                      := FND_API.G_MISS_CHAR;
    l_record.attribute8                      := FND_API.G_MISS_CHAR;
    l_record.attribute9                      := FND_API.G_MISS_CHAR;
    l_record.automatic_flag                  := FND_API.G_MISS_CHAR;
    l_record.context                         := FND_API.G_MISS_CHAR;
    l_record.created_by                      := FND_API.G_MISS_NUM;
    l_record.creation_date                   := FND_API.G_MISS_DATE;
    l_record.discount_id                     := FND_API.G_MISS_NUM;
    l_record.discount_line_id                := FND_API.G_MISS_NUM;
    l_record.header_id                       := FND_API.G_MISS_NUM;
    l_record.last_updated_by                 := FND_API.G_MISS_NUM;
    l_record.last_update_date                := FND_API.G_MISS_DATE;
    l_record.last_update_login               := FND_API.G_MISS_NUM;
    l_record.line_id                         := FND_API.G_MISS_NUM;
    l_record.percent                         := FND_API.G_MISS_NUM;
    l_record.price_adjustment_id             := FND_API.G_MISS_NUM;
    l_record.program_application_id          := FND_API.G_MISS_NUM;
    l_record.program_id                      := FND_API.G_MISS_NUM;
    l_record.program_update_date             := FND_API.G_MISS_DATE;
    l_record.request_id                      := FND_API.G_MISS_NUM;
    l_record.return_status                   := FND_API.G_MISS_CHAR;
    l_record.db_flag                         := FND_API.G_MISS_CHAR;
    l_record.operation                       := FND_API.G_MISS_CHAR;
    l_record.orig_sys_discount_ref  	 	:= FND_API.G_MISS_CHAR;
    l_record.change_request_code  	  	:= FND_API.G_MISS_CHAR;
    l_record.status_flag	  	      	:= FND_API.G_MISS_CHAR;
    l_record.list_header_id	  	     := FND_API.G_MISS_NUM;
    l_record.list_line_id	  	 	:= FND_API.G_MISS_NUM;
    l_record.list_line_type_code	    	:= FND_API.G_MISS_CHAR;
    l_record.modifier_mechanism_type_code   	:= FND_API.G_MISS_CHAR;
    l_record.modified_from	  	 	:= FND_API.G_MISS_CHAR;
    l_record.modified_to	  	 	:= FND_API.G_MISS_CHAR;
    l_record.updated_flag	  	 	:= FND_API.G_MISS_CHAR;
    l_record.update_allowed	  	 	:= FND_API.G_MISS_CHAR;
    l_record.applied_flag		      	:= FND_API.G_MISS_CHAR;
    l_record.change_reason_code		    	:= FND_API.G_MISS_CHAR;
    l_record.change_reason_text		     	:= FND_API.G_MISS_CHAR;
    l_record.operand                        	:= FND_API.G_MISS_NUM;
    l_record.operand_per_pqty                   := FND_API.G_MISS_NUM;
    l_record.arithmetic_operator            	:= FND_API.G_MISS_CHAR;
    l_record.cost_id                        	:= FND_API.G_MISS_NUM;
    l_record.tax_code                       	:= FND_API.G_MISS_CHAR;
    l_record.tax_exempt_flag                	:= FND_API.G_MISS_CHAR;
    l_record.tax_exempt_number               := FND_API.G_MISS_CHAR;
    l_record.tax_exempt_reason_code          := FND_API.G_MISS_CHAR;
    l_record.parent_adjustment_id            := FND_API.G_MISS_NUM;
    l_record.invoiced_flag                  	:= FND_API.G_MISS_CHAR;
    l_record.estimated_flag                 	:= FND_API.G_MISS_CHAR;
    l_record.inc_in_sales_performance       	:= FND_API.G_MISS_CHAR;
    l_record.split_action_code              	:= FND_API.G_MISS_CHAR;
    l_record.adjusted_amount				:=  FND_API.G_MISS_NUM;
    l_record.adjusted_amount_per_pqty                   :=  FND_API.G_MISS_NUM;
    l_record.pricing_phase_id		 		:= FND_API.G_MISS_NUM;
    l_record.charge_type_code               	:= FND_API.G_MISS_CHAR;
    l_record.charge_subtype_code            	:= FND_API.G_MISS_CHAR;
    l_record.list_line_no                    := FND_API.G_MISS_CHAR;
    l_record.source_system_code              := FND_API.G_MISS_CHAR;
    l_record.benefit_qty                    	:= FND_API.G_MISS_NUM;
    l_record.benefit_uom_code                := FND_API.G_MISS_CHAR;
    l_record.print_on_invoice_flag          	:= FND_API.G_MISS_CHAR;
    l_record.expiration_date                 := FND_API.G_MISS_DATE;
    l_record.rebate_transaction_type_code   	:= FND_API.G_MISS_CHAR;
    l_record.rebate_transaction_reference	:= FND_API.G_MISS_CHAR;
    l_record.rebate_payment_system_code     	:= FND_API.G_MISS_CHAR;
    l_record.redeemed_date                  	:= FND_API.G_MISS_DATE;
    l_record.redeemed_flag                  	:= FND_API.G_MISS_CHAR;
    l_record.accrual_flag                   	:= FND_API.G_MISS_CHAR;
    l_record.range_break_quantity		     := FND_API.G_MISS_NUM;
    l_record.accrual_conversion_rate	     := FND_API.G_MISS_NUM;
    l_record.pricing_group_sequence	    	:= FND_API.G_MISS_NUM;
    l_record.modifier_level_code			:= FND_API.G_MISS_CHAR;
    l_record.price_break_type_code		   	:= FND_API.G_MISS_CHAR;
    l_record.substitution_attribute		:= FND_API.G_MISS_CHAR;
    l_record.proration_type_code		   	:= FND_API.G_MISS_CHAR;
    l_record.credit_or_charge_flag          	:= FND_API.G_MISS_CHAR;
    l_record.include_on_returns_flag        	:= FND_API.G_MISS_CHAR;
    l_record.ac_attribute1                   := FND_API.G_MISS_CHAR;
    l_record.ac_attribute10                  := FND_API.G_MISS_CHAR;
    l_record.ac_attribute11                  := FND_API.G_MISS_CHAR;
    l_record.ac_attribute12                  := FND_API.G_MISS_CHAR;
    l_record.ac_attribute13                  := FND_API.G_MISS_CHAR;
    l_record.ac_attribute14                  := FND_API.G_MISS_CHAR;
    l_record.ac_attribute15                  := FND_API.G_MISS_CHAR;
    l_record.ac_attribute2                   := FND_API.G_MISS_CHAR;
    l_record.ac_attribute3                   := FND_API.G_MISS_CHAR;
    l_record.ac_attribute4                   := FND_API.G_MISS_CHAR;
    l_record.ac_attribute5                   := FND_API.G_MISS_CHAR;
    l_record.ac_attribute6                   := FND_API.G_MISS_CHAR;
    l_record.ac_attribute7                   := FND_API.G_MISS_CHAR;
    l_record.ac_attribute8                   := FND_API.G_MISS_CHAR;
    l_record.ac_attribute9                   := FND_API.G_MISS_CHAR;
    l_record.ac_context                      := FND_API.G_MISS_CHAR;

    RETURN l_record;

END G_MISS_HEADER_ADJ_REC;


-- Header_Price_Att_Rec_Type

FUNCTION G_MISS_HEADER_PRICE_ATT_REC
RETURN Header_Price_Att_Rec_Type IS
l_record			Header_Price_Att_Rec_Type;
BEGIN

     l_record.order_price_attrib_id 	:=	FND_API.G_MISS_NUM;
     l_record.header_id				:=	FND_API.G_MISS_NUM;
	l_record.line_id			:=	FND_API.G_MISS_NUM;
	l_record.creation_date			:=	FND_API.G_MISS_DATE;
	l_record.created_by			:=	FND_API.G_MISS_NUM;
	l_record.last_update_date		:=	FND_API.G_MISS_DATE;
	l_record.last_updated_by		:=	FND_API.G_MISS_NUM;
	l_record.last_update_login		:=	FND_API.G_MISS_NUM;
	l_record.program_application_id		:=	FND_API.G_MISS_NUM;
	l_record.program_id			:=	FND_API.G_MISS_NUM;
	l_record.program_update_date		:=	FND_API.G_MISS_DATE;
	l_record.request_id			:=	FND_API.G_MISS_NUM;
   	l_record.flex_title			:=	FND_API.G_MISS_CHAR;
	l_record.pricing_context		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute1		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute2		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute3		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute4		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute5		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute6		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute7		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute8		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute9		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute10		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute11		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute12		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute13		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute14		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute15		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute16		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute17		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute18		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute19		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute20		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute21		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute22		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute23		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute24		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute25		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute26		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute27		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute28		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute29		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute30		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute31		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute32		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute33		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute34		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute35		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute36		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute37		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute38		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute39		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute40		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute41		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute42		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute43		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute44		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute45		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute46		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute47		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute48		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute49		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute50		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute51		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute52		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute53		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute54		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute55		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute56		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute57		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute58		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute59		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute60		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute61		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute62		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute63		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute64		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute65		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute66		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute67		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute68		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute69		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute70		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute71		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute72		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute73		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute74		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute75		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute76		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute77		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute78		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute79		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute80		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute81		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute82		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute83		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute84		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute85		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute86		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute87		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute88		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute89		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute90		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute91		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute92		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute93		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute94		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute95		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute96		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute97		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute98		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute99		:=	FND_API.G_MISS_CHAR;
	l_record.pricing_attribute100		:=	FND_API.G_MISS_CHAR;
	l_record.context 			:=	FND_API.G_MISS_CHAR;
	l_record.attribute1			:=	FND_API.G_MISS_CHAR;
	l_record.attribute2			:=	FND_API.G_MISS_CHAR;
	l_record.attribute3			:=	FND_API.G_MISS_CHAR;
	l_record.attribute4			:=	FND_API.G_MISS_CHAR;
	l_record.attribute5			:=	FND_API.G_MISS_CHAR;
	l_record.attribute6			:=	FND_API.G_MISS_CHAR;
	l_record.attribute7			:=	FND_API.G_MISS_CHAR;
	l_record.attribute8			:=	FND_API.G_MISS_CHAR;
	l_record.attribute9			:=	FND_API.G_MISS_CHAR;
	l_record.attribute10			:=	FND_API.G_MISS_CHAR;
	l_record.attribute11			:=	FND_API.G_MISS_CHAR;
	l_record.attribute12			:=	FND_API.G_MISS_CHAR;
	l_record.attribute13			:=	FND_API.G_MISS_CHAR;
	l_record.attribute14			:=	FND_API.G_MISS_CHAR;
	l_record.attribute15			:=	FND_API.G_MISS_CHAR;
	l_record.Override_Flag			:=	FND_API.G_MISS_CHAR;
   	l_record.return_status       		:= 	FND_API.G_MISS_CHAR;
   	l_record.db_flag              		:= 	FND_API.G_MISS_CHAR;
   	l_record.operation            		:= 	FND_API.G_MISS_CHAR;
       l_record.orig_sys_atts_ref        :=      FND_API.G_MISS_CHAR; -- 1433292
       l_record.change_request_code      :=      FND_API.G_MISS_CHAR;
	RETURN l_record;

END G_MISS_HEADER_PRICE_ATT_REC;


-- Header_Adj_Att_Rec_Type

FUNCTION G_MISS_HEADER_ADJ_ATT_REC
RETURN Header_Adj_Att_Rec_Type IS
l_record			Header_Adj_Att_Rec_Type;
BEGIN

   l_record.price_adj_attrib_id		:=	FND_API.G_MISS_NUM;
   l_record.price_adjustment_id      	:=	FND_API.G_MISS_NUM;
   l_record.Adj_index                   := 	FND_API.G_MISS_NUM;
   l_record.flex_title			:=	FND_API.G_MISS_CHAR;
   l_record.pricing_context           	:=	FND_API.G_MISS_CHAR;
   l_record.pricing_attribute        	:=	FND_API.G_MISS_CHAR;
   l_record.creation_date               :=	FND_API.G_MISS_DATE;
   l_record.created_by                  :=	FND_API.G_MISS_NUM;
   l_record.last_update_date            :=	FND_API.G_MISS_DATE;
   l_record.last_updated_by            	:=	FND_API.G_MISS_NUM;
   l_record.last_update_login      	:=	FND_API.G_MISS_NUM;
   l_record.program_application_id 	:=	FND_API.G_MISS_NUM;
   l_record.program_id             	:=	FND_API.G_MISS_NUM;
   l_record.program_update_date    	:=	FND_API.G_MISS_DATE;
   l_record.request_id             	:=	FND_API.G_MISS_NUM;
   l_record.pricing_attr_value_from 	:=	FND_API.G_MISS_CHAR;
   l_record.pricing_attr_value_to  	:=	FND_API.G_MISS_CHAR;
   l_record.comparison_operator    	:=	FND_API.G_MISS_CHAR;
   l_record.return_status              	:= 	FND_API.G_MISS_CHAR;
   l_record.db_flag                    	:= 	FND_API.G_MISS_CHAR;
   l_record.operation                 	:= 	FND_API.G_MISS_CHAR;

   RETURN l_record;

END G_MISS_HEADER_ADJ_ATT_REC;



-- Header_Adj_Assoc_Rec_Type

FUNCTION G_MISS_HEADER_ADJ_ASSOC_REC
RETURN Header_Adj_Assoc_Rec_Type IS
l_record				Header_Adj_Assoc_Rec_Type;
BEGIN

   l_record.price_adj_assoc_id          :=   FND_API.G_MISS_NUM;
   l_record.line_id                    	:=   FND_API.G_MISS_NUM;
   l_record.Line_Index			:=   FND_API.G_MISS_NUM;
   l_record.price_adjustment_id        	:=   FND_API.G_MISS_NUM;
   l_record.Adj_index                  	:=   FND_API.G_MISS_NUM;
   l_record.rltd_Price_Adj_Id          	:=   FND_API.G_MISS_NUM;
   l_record.Rltd_Adj_Index             	:=   FND_API.G_MISS_NUM;
   l_record.creation_date               :=   FND_API.G_MISS_DATE;
   l_record.created_by                 	:=   FND_API.G_MISS_NUM;
   l_record.last_update_date            :=   FND_API.G_MISS_DATE;
   l_record.last_updated_by            	:=   FND_API.G_MISS_NUM;
   l_record.last_update_login          	:=   FND_API.G_MISS_NUM;
   l_record.program_application_id 	:=   FND_API.G_MISS_NUM;
   l_record.program_id                 	:=   FND_API.G_MISS_NUM;
   l_record.program_update_date         :=   FND_API.G_MISS_DATE;
   l_record.request_id                 	:=   FND_API.G_MISS_NUM;
   l_record.return_status              	:=   FND_API.G_MISS_CHAR;
   l_record.db_flag                    	:=   FND_API.G_MISS_CHAR;
   l_record.operation                 	:=   FND_API.G_MISS_CHAR;

   RETURN l_record;

END G_MISS_HEADER_ADJ_ASSOC_REC;


--  Header_Scredit record type

FUNCTION G_MISS_HEADER_SCREDIT_REC
RETURN Header_Scredit_Rec_Type IS
l_record		Header_Scredit_Rec_Type;
BEGIN

    l_record.attribute1                      := FND_API.G_MISS_CHAR;
    l_record.attribute10                     := FND_API.G_MISS_CHAR;
    l_record.attribute11                     := FND_API.G_MISS_CHAR;
    l_record.attribute12                     := FND_API.G_MISS_CHAR;
    l_record.attribute13                     := FND_API.G_MISS_CHAR;
    l_record.attribute14                     := FND_API.G_MISS_CHAR;
    l_record.attribute15                     := FND_API.G_MISS_CHAR;
    l_record.attribute2                      := FND_API.G_MISS_CHAR;
    l_record.attribute3                      := FND_API.G_MISS_CHAR;
    l_record.attribute4                      := FND_API.G_MISS_CHAR;
    l_record.attribute5                      := FND_API.G_MISS_CHAR;
    l_record.attribute6                      := FND_API.G_MISS_CHAR;
    l_record.attribute7                      := FND_API.G_MISS_CHAR;
    l_record.attribute8                      := FND_API.G_MISS_CHAR;
    l_record.attribute9                      := FND_API.G_MISS_CHAR;
    l_record.context                         := FND_API.G_MISS_CHAR;
    l_record.created_by                      := FND_API.G_MISS_NUM;
    l_record.creation_date                   := FND_API.G_MISS_DATE;
    l_record.dw_update_advice_flag           := FND_API.G_MISS_CHAR;
    l_record.header_id                       := FND_API.G_MISS_NUM;
    l_record.last_updated_by                 := FND_API.G_MISS_NUM;
    l_record.last_update_date                := FND_API.G_MISS_DATE;
    l_record.last_update_login               := FND_API.G_MISS_NUM;
    l_record.line_id                         := FND_API.G_MISS_NUM;
    l_record.percent                         := FND_API.G_MISS_NUM;
    l_record.salesrep_id                     := FND_API.G_MISS_NUM;
    l_record.sales_credit_type_id            := FND_API.G_MISS_NUM;
    l_record.sales_credit_id                 := FND_API.G_MISS_NUM;
    l_record.wh_update_date                  := FND_API.G_MISS_DATE;
    l_record.return_status                   := FND_API.G_MISS_CHAR;
    l_record.db_flag                         := FND_API.G_MISS_CHAR;
    l_record.operation                       := FND_API.G_MISS_CHAR;
    l_record.orig_sys_credit_ref	     := FND_API.G_MISS_CHAR;
    l_record.change_request_code	     := FND_API.G_MISS_CHAR;
    l_record.status_flag		     := FND_API.G_MISS_CHAR;

    RETURN l_record;

END G_MISS_HEADER_SCREDIT_REC;

-- Line record type
FUNCTION GET_G_MISS_LINE_REC
RETURN Line_Rec_Type IS
BEGIN
   RETURN G_MISS_LINE_REC;
END;


--  Line_Adj record type

FUNCTION G_MISS_LINE_ADJ_REC
RETURN Line_Adj_Rec_Type IS
l_record				Line_Adj_Rec_Type;
BEGIN

    l_record.attribute1                      := FND_API.G_MISS_CHAR;
    l_record.attribute10                     := FND_API.G_MISS_CHAR;
    l_record.attribute11                     := FND_API.G_MISS_CHAR;
    l_record.attribute12                     := FND_API.G_MISS_CHAR;
    l_record.attribute13                     := FND_API.G_MISS_CHAR;
    l_record.attribute14                     := FND_API.G_MISS_CHAR;
    l_record.attribute15                     := FND_API.G_MISS_CHAR;
    l_record.attribute2                      := FND_API.G_MISS_CHAR;
    l_record.attribute3                      := FND_API.G_MISS_CHAR;
    l_record.attribute4                      := FND_API.G_MISS_CHAR;
    l_record.attribute5                      := FND_API.G_MISS_CHAR;
    l_record.attribute6                      := FND_API.G_MISS_CHAR;
    l_record.attribute7                      := FND_API.G_MISS_CHAR;
    l_record.attribute8                      := FND_API.G_MISS_CHAR;
    l_record.attribute9                      := FND_API.G_MISS_CHAR;
    l_record.automatic_flag                  := FND_API.G_MISS_CHAR;
    l_record.context                         := FND_API.G_MISS_CHAR;
    l_record.created_by                      := FND_API.G_MISS_NUM;
    l_record.creation_date                   := FND_API.G_MISS_DATE;
    l_record.discount_id                     := FND_API.G_MISS_NUM;
    l_record.discount_line_id                := FND_API.G_MISS_NUM;
    l_record.header_id                       := FND_API.G_MISS_NUM;
    l_record.last_updated_by                 := FND_API.G_MISS_NUM;
    l_record.last_update_date                := FND_API.G_MISS_DATE;
    l_record.last_update_login               := FND_API.G_MISS_NUM;
    l_record.line_id                         := FND_API.G_MISS_NUM;
    l_record.percent                         := FND_API.G_MISS_NUM;
    l_record.price_adjustment_id             := FND_API.G_MISS_NUM;
    l_record.program_application_id          := FND_API.G_MISS_NUM;
    l_record.program_id                      := FND_API.G_MISS_NUM;
    l_record.program_update_date             := FND_API.G_MISS_DATE;
    l_record.request_id                      := FND_API.G_MISS_NUM;
    l_record.return_status                   := FND_API.G_MISS_CHAR;
    l_record.db_flag                         := FND_API.G_MISS_CHAR;
    l_record.operation                       := FND_API.G_MISS_CHAR;
    l_record.line_index                      := FND_API.G_MISS_NUM;
    l_record.orig_sys_discount_ref           := FND_API.G_MISS_CHAR;
    l_record.change_request_code	  	  	:= FND_API.G_MISS_CHAR;
    l_record.status_flag		  	      	:= FND_API.G_MISS_CHAR;
    l_record.list_header_id                  := FND_API.G_MISS_NUM;
    l_record.list_line_id                    := FND_API.G_MISS_NUM;
    l_record.list_line_type_code             := FND_API.G_MISS_CHAR;
    l_record.modifier_mechanism_type_code    := FND_API.G_MISS_CHAR;
    l_record.modified_from                   := FND_API.G_MISS_CHAR;
    l_record.modified_to                     := FND_API.G_MISS_CHAR;
    l_record.updated_flag                    := FND_API.G_MISS_CHAR;
    l_record.update_allowed                  := FND_API.G_MISS_CHAR;
    l_record.applied_flag                    := FND_API.G_MISS_CHAR;
    l_record.change_reason_code              := FND_API.G_MISS_CHAR;
    l_record.change_reason_text              := FND_API.G_MISS_CHAR;
    l_record.operand                         := FND_API.G_MISS_NUM;
    l_record.operand_per_pqty                := FND_API.G_MISS_NUM;
    l_record.arithmetic_operator             := FND_API.G_MISS_CHAR;
    l_record.cost_id                         := FND_API.G_MISS_NUM;
    l_record.tax_code                        := FND_API.G_MISS_CHAR;
    l_record.tax_exempt_flag                 := FND_API.G_MISS_CHAR;
    l_record.tax_exempt_number               := FND_API.G_MISS_CHAR;
    l_record.tax_exempt_reason_code          := FND_API.G_MISS_CHAR;
    l_record.parent_adjustment_id            := FND_API.G_MISS_NUM;
    l_record.invoiced_flag                   := FND_API.G_MISS_CHAR;
    l_record.estimated_flag                  := FND_API.G_MISS_CHAR;
    l_record.inc_in_sales_performance        := FND_API.G_MISS_CHAR;
    l_record.split_action_code               := FND_API.G_MISS_CHAR;
    l_record.adjusted_amount			    	:=  FND_API.G_MISS_NUM;
    l_record.adjusted_amount_per_pqty                   :=  FND_API.G_MISS_NUM;
    l_record.pricing_phase_id		    	     := FND_API.G_MISS_NUM;
    l_record.charge_type_code                := FND_API.G_MISS_CHAR;
    l_record.charge_subtype_code             := FND_API.G_MISS_CHAR;
    l_record.list_line_no                    := FND_API.G_MISS_CHAR;
    l_record.source_system_code              := FND_API.G_MISS_CHAR;
    l_record.benefit_qty                     := FND_API.G_MISS_NUM;
    l_record.benefit_uom_code                := FND_API.G_MISS_CHAR;
    l_record.print_on_invoice_flag           := FND_API.G_MISS_CHAR;
    l_record.expiration_date                 := FND_API.G_MISS_DATE;
    l_record.rebate_transaction_type_code    := FND_API.G_MISS_CHAR;
    l_record.rebate_transaction_reference    := FND_API.G_MISS_CHAR;
    l_record.rebate_payment_system_code      := FND_API.G_MISS_CHAR;
    l_record.redeemed_date                   := FND_API.G_MISS_DATE;
    l_record.redeemed_flag                   := FND_API.G_MISS_CHAR;
    l_record.accrual_flag                    := FND_API.G_MISS_CHAR;
    l_record.range_break_quantity			:= FND_API.G_MISS_NUM;
    l_record.accrual_conversion_rate		:= FND_API.G_MISS_NUM;
    l_record.pricing_group_sequence		:=  FND_API.G_MISS_NUM;
    l_record.modifier_level_code			:=  FND_API.G_MISS_CHAR;
    l_record.price_break_type_code		   	:=  FND_API.G_MISS_CHAR;
    l_record.substitution_attribute	   	:=  FND_API.G_MISS_CHAR;
    l_record.proration_type_code		   	:=  FND_API.G_MISS_CHAR;
    l_record.credit_or_charge_flag          	:= FND_API.G_MISS_CHAR;
    l_record.include_on_returns_flag        	:= FND_API.G_MISS_CHAR;
    l_record.ac_attribute1                   := FND_API.G_MISS_CHAR;
    l_record.ac_attribute10                  := FND_API.G_MISS_CHAR;
    l_record.ac_attribute11                  := FND_API.G_MISS_CHAR;
    l_record.ac_attribute12                  := FND_API.G_MISS_CHAR;
    l_record.ac_attribute13                  := FND_API.G_MISS_CHAR;
    l_record.ac_attribute14                  := FND_API.G_MISS_CHAR;
    l_record.ac_attribute15                  := FND_API.G_MISS_CHAR;
    l_record.ac_attribute2                   := FND_API.G_MISS_CHAR;
    l_record.ac_attribute3                   := FND_API.G_MISS_CHAR;
    l_record.ac_attribute4                   := FND_API.G_MISS_CHAR;
    l_record.ac_attribute5                   := FND_API.G_MISS_CHAR;
    l_record.ac_attribute6                   := FND_API.G_MISS_CHAR;
    l_record.ac_attribute7                   := FND_API.G_MISS_CHAR;
    l_record.ac_attribute8                   := FND_API.G_MISS_CHAR;
    l_record.ac_attribute9                   := FND_API.G_MISS_CHAR;
    l_record.ac_context                      := FND_API.G_MISS_CHAR;
    l_record.TAX_RATE_ID                     := FND_API.G_MISS_NUM;

    RETURN l_record;

END G_MISS_LINE_ADJ_REC;


-- Line_Price_Att_Rec_Type

FUNCTION G_MISS_Line_Price_Att_Rec
RETURN Line_Price_Att_Rec_Type IS
l_record			Line_Price_Att_Rec_Type;
BEGIN

    l_record.order_price_attrib_id 		:=	FND_API.G_MISS_NUM;
    l_record.header_id					:=	FND_API.G_MISS_NUM;
    l_record.line_id					:=	FND_API.G_MISS_NUM;
    l_record.line_index					:=	FND_API.G_MISS_NUM;
    l_record.creation_date				:=	FND_API.G_MISS_DATE;
    l_record.created_by					:=	FND_API.G_MISS_NUM;
    l_record.last_update_date				:=	FND_API.G_MISS_DATE;
    l_record.last_updated_by				:=	FND_API.G_MISS_NUM;
    l_record.last_update_login			:=	FND_API.G_MISS_NUM;
    l_record.program_application_id		:=	FND_API.G_MISS_NUM;
    l_record.program_id					:=	FND_API.G_MISS_NUM;
    l_record.program_update_date			:=	FND_API.G_MISS_DATE;
    l_record.request_id					:=	FND_API.G_MISS_NUM;
    l_record.flex_title					:=	FND_API.G_MISS_CHAR;
    l_record.pricing_context				:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute1			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute2			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute3			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute4			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute5			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute6			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute7			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute8			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute9			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute10			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute11			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute12			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute13			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute14			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute15			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute16			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute17			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute18			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute19			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute20			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute21			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute22			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute23			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute24			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute25			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute26			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute27			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute28			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute29			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute30			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute31			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute32			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute33			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute34			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute35			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute36			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute37			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute38			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute39			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute40			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute41			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute42			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute43			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute44			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute45			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute46			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute47			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute48			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute49			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute50			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute51			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute52			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute53			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute54			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute55			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute56			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute57			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute58			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute59			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute60			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute61			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute62			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute63			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute64			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute65			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute66			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute67			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute68			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute69			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute70			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute71			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute72			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute73			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute74			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute75			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute76			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute77			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute78			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute79			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute80			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute81			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute82			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute83			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute84			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute85			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute86			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute87			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute88			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute89			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute90			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute91			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute92			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute93			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute94			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute95			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute96			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute97			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute98			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute99			:=	FND_API.G_MISS_CHAR;
    l_record.pricing_attribute100			:=	FND_API.G_MISS_CHAR;
    l_record.context 					:=	FND_API.G_MISS_CHAR;
    l_record.attribute1					:=	FND_API.G_MISS_CHAR;
    l_record.attribute2					:=	FND_API.G_MISS_CHAR;
    l_record.attribute3					:=	FND_API.G_MISS_CHAR;
    l_record.attribute4					:=	FND_API.G_MISS_CHAR;
    l_record.attribute5					:=	FND_API.G_MISS_CHAR;
    l_record.attribute6					:=	FND_API.G_MISS_CHAR;
    l_record.attribute7					:=	FND_API.G_MISS_CHAR;
    l_record.attribute8					:=	FND_API.G_MISS_CHAR;
    l_record.attribute9					:=	FND_API.G_MISS_CHAR;
    l_record.attribute10					:=	FND_API.G_MISS_CHAR;
    l_record.attribute11					:=	FND_API.G_MISS_CHAR;
    l_record.attribute12					:=	FND_API.G_MISS_CHAR;
    l_record.attribute13					:=	FND_API.G_MISS_CHAR;
    l_record.attribute14					:=	FND_API.G_MISS_CHAR;
    l_record.attribute15					:=	FND_API.G_MISS_CHAR;
    l_record.Override_Flag				:=	FND_API.G_MISS_CHAR;
    l_record.return_status            	     := 	FND_API.G_MISS_CHAR;
    l_record.db_flag                  	     := 	FND_API.G_MISS_CHAR;
    l_record.operation                	    	:= 	FND_API.G_MISS_CHAR;
    l_record.orig_sys_atts_ref        :=      FND_API.G_MISS_CHAR;  -- 1433292
    l_record.change_request_code      :=      FND_API.G_MISS_CHAR;
    RETURN l_record;

END G_MISS_Line_Price_Att_Rec;


-- Line_Adj_Att_Rec_Type

FUNCTION G_MISS_Line_Adj_Att_Rec
RETURN Line_Adj_Att_Rec_Type IS
l_record				Line_Adj_Att_Rec_Type;
BEGIN

    l_record.price_adj_attrib_id      	 	:=   FND_API.G_MISS_NUM;
    l_record.price_adjustment_id      	 	:=   FND_API.G_MISS_NUM;
    l_record.Adj_index					:=   FND_API.G_MISS_NUM;
    l_record.flex_title             	    	:=   FND_API.G_MISS_CHAR;
    l_record.pricing_context        	    	:=   FND_API.G_MISS_CHAR;
    l_record.pricing_attribute      	    	:=   FND_API.G_MISS_CHAR;
    l_record.creation_date          	     :=   FND_API.G_MISS_DATE;
    l_record.created_by             	     :=   FND_API.G_MISS_NUM;
    l_record.last_update_date       	     :=   FND_API.G_MISS_DATE;
    l_record.last_updated_by        	     :=   FND_API.G_MISS_NUM;
    l_record.last_update_login      	    	:=   FND_API.G_MISS_NUM;
    l_record.program_application_id 	    	:=   FND_API.G_MISS_NUM;
    l_record.program_id             	    	:=   FND_API.G_MISS_NUM;
    l_record.program_update_date    	 	:=   FND_API.G_MISS_DATE;
    l_record.request_id             	    	:=   FND_API.G_MISS_NUM;
    l_record.pricing_attr_value_from 	 	:=   FND_API.G_MISS_CHAR;
    l_record.pricing_attr_value_to  	  	:=   FND_API.G_MISS_CHAR;
    l_record.comparison_operator     	   	:=   FND_API.G_MISS_CHAR;
    l_record.return_status            	    	:=   FND_API.G_MISS_CHAR;
    l_record.db_flag                  	    	:=   FND_API.G_MISS_CHAR;
    l_record.operation                	   	:=   FND_API.G_MISS_CHAR;

    RETURN l_record;

END G_MISS_Line_Adj_Att_Rec;



-- Line_Adj_Assoc_Rec_Type

FUNCTION G_MISS_Line_Adj_Assoc_Rec
RETURN Line_Adj_Assoc_Rec_Type IS
l_record				Line_Adj_Assoc_Rec_Type;
BEGIN

   l_record.price_adj_assoc_id              	:=   FND_API.G_MISS_NUM;
   l_record.line_id                	    	:=   FND_API.G_MISS_NUM;
   l_record.Line_index						:=   FND_API.G_MISS_NUM;
   l_record.price_adjustment_id    	    	:=   FND_API.G_MISS_NUM;
   l_record.Adj_index						:=   FND_API.G_MISS_NUM;
   l_record.rltd_Price_Adj_Id      	    	:=   FND_API.G_MISS_NUM;
   l_record.Rltd_Adj_Index         	    	:= 	FND_API.G_MISS_NUM;
   l_record.creation_date          	      	:=   FND_API.G_MISS_DATE;
   l_record.created_by             	    	:=   FND_API.G_MISS_NUM;
   l_record.last_update_date       	      	:=   FND_API.G_MISS_DATE;
   l_record.last_updated_by        	    	:=   FND_API.G_MISS_NUM;
   l_record.last_update_login      	    	:=   FND_API.G_MISS_NUM;
   l_record.program_application_id 	        	:=   FND_API.G_MISS_NUM;
   l_record.program_id             	     	:=   FND_API.G_MISS_NUM;
   l_record.program_update_date    	     		:=   FND_API.G_MISS_DATE;
   l_record.request_id             	     	:=   FND_API.G_MISS_NUM;
   l_record.return_status            	    :=   FND_API.G_MISS_CHAR;
   l_record.db_flag                  	    :=   FND_API.G_MISS_CHAR;
   l_record.operation                	   :=   FND_API.G_MISS_CHAR;

   RETURN l_record;

END G_MISS_Line_Adj_Assoc_Rec;


--  Line_Scredit record type

FUNCTION G_MISS_LINE_SCREDIT_REC
RETURN Line_Scredit_Rec_Type IS
l_record 					Line_Scredit_Rec_Type;
BEGIN

    l_record.attribute1                      := FND_API.G_MISS_CHAR;
    l_record.attribute10                     := FND_API.G_MISS_CHAR;
    l_record.attribute11                     := FND_API.G_MISS_CHAR;
    l_record.attribute12                     := FND_API.G_MISS_CHAR;
    l_record.attribute13                     := FND_API.G_MISS_CHAR;
    l_record.attribute14                     := FND_API.G_MISS_CHAR;
    l_record.attribute15                     := FND_API.G_MISS_CHAR;
    l_record.attribute2                      := FND_API.G_MISS_CHAR;
    l_record.attribute3                      := FND_API.G_MISS_CHAR;
    l_record.attribute4                      := FND_API.G_MISS_CHAR;
    l_record.attribute5                      := FND_API.G_MISS_CHAR;
    l_record.attribute6                      := FND_API.G_MISS_CHAR;
    l_record.attribute7                      := FND_API.G_MISS_CHAR;
    l_record.attribute8                      := FND_API.G_MISS_CHAR;
    l_record.attribute9                      := FND_API.G_MISS_CHAR;
    l_record.context                         := FND_API.G_MISS_CHAR;
    l_record.created_by                      := FND_API.G_MISS_NUM;
    l_record.creation_date                   := FND_API.G_MISS_DATE;
    l_record.dw_update_advice_flag           := FND_API.G_MISS_CHAR;
    l_record.header_id                       := FND_API.G_MISS_NUM;
    l_record.last_updated_by                 := FND_API.G_MISS_NUM;
    l_record.last_update_date                := FND_API.G_MISS_DATE;
    l_record.last_update_login               := FND_API.G_MISS_NUM;
    l_record.line_id                         := FND_API.G_MISS_NUM;
    l_record.percent                         := FND_API.G_MISS_NUM;
    l_record.salesrep_id                     := FND_API.G_MISS_NUM;
    l_record.sales_credit_id                 := FND_API.G_MISS_NUM;
    l_record.sales_credit_type_id            := FND_API.G_MISS_NUM;
    l_record.wh_update_date                  := FND_API.G_MISS_DATE;
    l_record.return_status                   := FND_API.G_MISS_CHAR;
    l_record.db_flag                         := FND_API.G_MISS_CHAR;
    l_record.operation                       := FND_API.G_MISS_CHAR;
    l_record.line_index                      := FND_API.G_MISS_NUM;
    l_record.orig_sys_credit_ref             := FND_API.G_MISS_CHAR;
    l_record.change_request_code	  	  	:= FND_API.G_MISS_CHAR;
    l_record.status_flag		  	      	:= FND_API.G_MISS_CHAR;

    RETURN l_record;

END G_MISS_LINE_SCREDIT_REC;


--  Lot_Serial record type

FUNCTION G_MISS_LOT_SERIAL_REC
RETURN Lot_Serial_Rec_Type IS
l_record					Lot_Serial_Rec_Type;
BEGIN

    l_record.attribute1                      := FND_API.G_MISS_CHAR;
    l_record.attribute10                     := FND_API.G_MISS_CHAR;
    l_record.attribute11                     := FND_API.G_MISS_CHAR;
    l_record.attribute12                     := FND_API.G_MISS_CHAR;
    l_record.attribute13                     := FND_API.G_MISS_CHAR;
    l_record.attribute14                     := FND_API.G_MISS_CHAR;
    l_record.attribute15                     := FND_API.G_MISS_CHAR;
    l_record.attribute2                      := FND_API.G_MISS_CHAR;
    l_record.attribute3                      := FND_API.G_MISS_CHAR;
    l_record.attribute4                      := FND_API.G_MISS_CHAR;
    l_record.attribute5                      := FND_API.G_MISS_CHAR;
    l_record.attribute6                      := FND_API.G_MISS_CHAR;
    l_record.attribute7                      := FND_API.G_MISS_CHAR;
    l_record.attribute8                      := FND_API.G_MISS_CHAR;
    l_record.attribute9                      := FND_API.G_MISS_CHAR;
    l_record.context                         := FND_API.G_MISS_CHAR;
    l_record.created_by                      := FND_API.G_MISS_NUM;
    l_record.creation_date                   := FND_API.G_MISS_DATE;
    l_record.from_serial_number              := FND_API.G_MISS_CHAR;
    l_record.last_updated_by                 := FND_API.G_MISS_NUM;
    l_record.last_update_date                := FND_API.G_MISS_DATE;
    l_record.last_update_login               := FND_API.G_MISS_NUM;
    l_record.line_id                         := FND_API.G_MISS_NUM;
    l_record.lot_number                      := FND_API.G_MISS_CHAR;
 --   l_record.sublot_number                   := FND_API.G_MISS_CHAR; --OPM 2380194  INVCONV
    l_record.lot_serial_id                   := FND_API.G_MISS_NUM;
    l_record.quantity                        := FND_API.G_MISS_NUM;
    l_record.quantity2                       := FND_API.G_MISS_NUM;   --OPM 2380194
    l_record.to_serial_number                := FND_API.G_MISS_CHAR;
    l_record.return_status                   := FND_API.G_MISS_CHAR;
    l_record.db_flag                         := FND_API.G_MISS_CHAR;
    l_record.operation                       := FND_API.G_MISS_CHAR;
    l_record.line_index                      := FND_API.G_MISS_NUM;
    l_record.orig_sys_lotserial_ref          := FND_API.G_MISS_CHAR;
    l_record.change_request_code	  	  	:= FND_API.G_MISS_CHAR;
    l_record.status_flag		  	      	:= FND_API.G_MISS_CHAR;
    l_record.line_set_id                     := FND_API.G_MISS_NUM;

    RETURN l_record;

END G_MISS_LOT_SERIAL_REC;


FUNCTION G_MISS_HEADER_VAL_REC
RETURN Header_Val_Rec_Type IS
l_record		Header_Val_Rec_Type;
BEGIN

    l_record.accounting_rule                 := FND_API.G_MISS_CHAR;
    l_record.agreement                       := FND_API.G_MISS_CHAR;
    l_record.conversion_type                 := FND_API.G_MISS_CHAR;
    l_record.deliver_to_address1             := FND_API.G_MISS_CHAR;
    l_record.deliver_to_address2             := FND_API.G_MISS_CHAR;
    l_record.deliver_to_address3             := FND_API.G_MISS_CHAR;
    l_record.deliver_to_address4             := FND_API.G_MISS_CHAR;
    l_record.deliver_to_contact              := FND_API.G_MISS_CHAR;
    l_record.deliver_to_location             := FND_API.G_MISS_CHAR;
    l_record.deliver_to_org                  := FND_API.G_MISS_CHAR;
    l_record.deliver_to_state                := FND_API.G_MISS_CHAR;
    l_record.deliver_to_city                 := FND_API.G_MISS_CHAR;
    l_record.deliver_to_zip                  := FND_API.G_MISS_CHAR;
    l_record.deliver_to_county               := FND_API.G_MISS_CHAR;
    l_record.deliver_to_country              := FND_API.G_MISS_CHAR;
    l_record.deliver_to_province             := FND_API.G_MISS_CHAR;
    l_record.demand_class                    := FND_API.G_MISS_CHAR;
    l_record.fob_point                       := FND_API.G_MISS_CHAR;
    l_record.freight_terms                   := FND_API.G_MISS_CHAR;
    l_record.invoice_to_address1             := FND_API.G_MISS_CHAR;
    l_record.invoice_to_address2             := FND_API.G_MISS_CHAR;
    l_record.invoice_to_address3             := FND_API.G_MISS_CHAR;
    l_record.invoice_to_address4             := FND_API.G_MISS_CHAR;
    l_record.invoice_to_city                 := FND_API.G_MISS_CHAR;
    l_record.invoice_to_state                := FND_API.G_MISS_CHAR;
    l_record.invoice_to_zip                  := FND_API.G_MISS_CHAR;
    l_record.invoice_to_county               := FND_API.G_MISS_CHAR;
    l_record.invoice_to_country              := FND_API.G_MISS_CHAR;
    l_record.invoice_to_province             := FND_API.G_MISS_CHAR;
    l_record.invoice_to_contact              := FND_API.G_MISS_CHAR;
    l_record.invoice_to_location             := FND_API.G_MISS_CHAR;
    l_record.invoice_to_org                  := FND_API.G_MISS_CHAR;
    l_record.invoicing_rule                  := FND_API.G_MISS_CHAR;
    l_record.order_source                    := FND_API.G_MISS_CHAR;
    l_record.order_type                      := FND_API.G_MISS_CHAR;
    l_record.payment_term                    := FND_API.G_MISS_CHAR;
    l_record.price_list                      := FND_API.G_MISS_CHAR;
    l_record. RETURN_reason            := FND_API.G_MISS_CHAR;
    l_record.salesrep                 := FND_API.G_MISS_CHAR;
    l_record.shipment_priority               := FND_API.G_MISS_CHAR;
    l_record.ship_from_address1              := FND_API.G_MISS_CHAR;
    l_record.ship_from_address2              := FND_API.G_MISS_CHAR;
    l_record.ship_from_address3              := FND_API.G_MISS_CHAR;
    l_record.ship_from_address4              := FND_API.G_MISS_CHAR;
    l_record.ship_from_location              := FND_API.G_MISS_CHAR;
    l_record.ship_from_org                   := FND_API.G_MISS_CHAR;
    l_record.ship_to_address1                := FND_API.G_MISS_CHAR;
    l_record.ship_to_address2                := FND_API.G_MISS_CHAR;
    l_record.ship_to_address3                := FND_API.G_MISS_CHAR;
    l_record.ship_to_address4                := FND_API.G_MISS_CHAR;
    l_record.ship_to_city                    := FND_API.G_MISS_CHAR;
    l_record.ship_to_state                   := FND_API.G_MISS_CHAR;
    l_record.ship_to_zip                     := FND_API.G_MISS_CHAR;
    l_record.ship_to_country                 := FND_API.G_MISS_CHAR;
    l_record.ship_to_county                  := FND_API.G_MISS_CHAR;
    l_record.ship_to_province                := FND_API.G_MISS_CHAR;
    l_record.ship_to_contact                 := FND_API.G_MISS_CHAR;
    l_record.ship_to_location                := FND_API.G_MISS_CHAR;
    l_record.ship_to_org                     := FND_API.G_MISS_CHAR;
    l_record.sold_to_contact                 := FND_API.G_MISS_CHAR;
    l_record.sold_to_org                     := FND_API.G_MISS_CHAR;
    l_record.sold_from_org                   := FND_API.G_MISS_CHAR;
    l_record.tax_exempt                      := FND_API.G_MISS_CHAR;
    l_record.tax_exempt_reason               := FND_API.G_MISS_CHAR;
    l_record.tax_point                       := FND_API.G_MISS_CHAR;
    l_record.customer_payment_term         := FND_API.G_MISS_CHAR;
    l_record.payment_type                    := FND_API.G_MISS_CHAR;
    l_record.credit_card                     := FND_API.G_MISS_CHAR;
    l_record.status                          := FND_API.G_MISS_CHAR;
    l_record.freight_carrier                 := FND_API.G_MISS_CHAR;
    l_record.shipping_method                 := FND_API.G_MISS_CHAR;
    l_record.order_date_type                 := FND_API.G_MISS_CHAR;
    l_record.customer_number                  := FND_API.G_MISS_CHAR;
    l_record.sales_channel                   := FND_API.G_MISS_CHAR;
    l_record.ship_to_customer_name           := FND_API.G_MISS_CHAR;
    l_record.invoice_to_customer_name        := FND_API.G_MISS_CHAR;
    l_record.ship_to_customer_number        := FND_API.G_MISS_CHAR;
    l_record.invoice_to_customer_number    := FND_API.G_MISS_CHAR;
    l_record.ship_to_customer_id            := FND_API.G_MISS_NUM;
    l_record.invoice_to_customer_id        := FND_API.G_MISS_NUM;
    l_record.deliver_to_customer_id       := FND_API.G_MISS_NUM;
    l_record.deliver_to_customer_number      := FND_API.G_MISS_CHAR;
    l_record.deliver_to_customer_name        := FND_API.G_MISS_CHAR;
    l_record.deliver_to_customer_Number_oi    := FND_API.G_MISS_CHAR;
    l_record.deliver_to_customer_Name_oi     := FND_API.G_MISS_CHAR;
    l_record.ship_to_customer_Number_oi     := FND_API.G_MISS_CHAR;
    l_record.ship_to_customer_Name_oi      := FND_API.G_MISS_CHAR;
    l_record.invoice_to_customer_Number_oi    := FND_API.G_MISS_CHAR;
    l_record.invoice_to_customer_Name_oi     := FND_API.G_MISS_CHAR;
--added for Ac Desc, Reg ID proj
    l_record.account_description	    := FND_API.G_MISS_CHAR;
    l_record.registry_id		    := FND_API.G_MISS_CHAR;


    RETURN l_record;

END G_MISS_HEADER_VAL_REC;

FUNCTION G_MISS_HEADER_ADJ_VAL_REC
RETURN Header_Adj_Val_Rec_Type IS
l_record		Header_Adj_Val_Rec_Type;
BEGIN

    l_record.discount                       := FND_API.G_MISS_CHAR;
    l_record.list_name                      := FND_API.G_MISS_CHAR;
    l_record.version_no                     := FND_API.G_MISS_CHAR;

    RETURN l_record;

END G_MISS_HEADER_ADJ_VAL_REC;

FUNCTION G_MISS_HEADER_SCREDIT_VAL_REC RETURN Header_Scredit_Val_Rec_Type IS
l_record		Header_Scredit_Val_Rec_Type;
BEGIN

    l_record.salesrep                        := FND_API.G_MISS_CHAR;
    l_record.sales_credit_type               := FND_API.G_MISS_CHAR;

    RETURN l_record;

END G_MISS_HEADER_SCREDIT_VAL_REC;

FUNCTION G_MISS_LINE_VAL_REC RETURN Line_Val_Rec_Type IS
l_record		Line_Val_Rec_Type;
BEGIN

    l_record.accounting_rule                 := FND_API.G_MISS_CHAR;
    l_record.agreement                       := FND_API.G_MISS_CHAR;
    l_record.commitment               := FND_API.G_MISS_CHAR;
    l_record.commitment_applied_amount       := FND_API.G_MISS_NUM;
    l_record.deliver_to_address1             := FND_API.G_MISS_CHAR;
    l_record.deliver_to_address2             := FND_API.G_MISS_CHAR;
    l_record.deliver_to_address3             := FND_API.G_MISS_CHAR;
    l_record.deliver_to_address4             := FND_API.G_MISS_CHAR;
    l_record.deliver_to_contact              := FND_API.G_MISS_CHAR;
    l_record.deliver_to_location             := FND_API.G_MISS_CHAR;
    l_record.deliver_to_org                  := FND_API.G_MISS_CHAR;
    l_record.deliver_to_state                := FND_API.G_MISS_CHAR;
    l_record.deliver_to_city                 := FND_API.G_MISS_CHAR;
    l_record.deliver_to_zip                  := FND_API.G_MISS_CHAR;
    l_record.deliver_to_county               := FND_API.G_MISS_CHAR;
    l_record.deliver_to_country              := FND_API.G_MISS_CHAR;
    l_record.deliver_to_province             := FND_API.G_MISS_CHAR;
    l_record.demand_class                    := FND_API.G_MISS_CHAR;
    l_record.demand_bucket_type              := FND_API.G_MISS_CHAR;
    l_record.fob_point                       := FND_API.G_MISS_CHAR;
    l_record.freight_terms                   := FND_API.G_MISS_CHAR;
    l_record.inventory_item                  := FND_API.G_MISS_CHAR;
    l_record.invoice_to_address1             := FND_API.G_MISS_CHAR;
    l_record.invoice_to_address2             := FND_API.G_MISS_CHAR;
    l_record.invoice_to_address3             := FND_API.G_MISS_CHAR;
    l_record.invoice_to_address4             := FND_API.G_MISS_CHAR;
    l_record.invoice_to_contact              := FND_API.G_MISS_CHAR;
    l_record.invoice_to_location             := FND_API.G_MISS_CHAR;
    l_record.invoice_to_org                  := FND_API.G_MISS_CHAR;
    l_record.invoice_to_city                 := FND_API.G_MISS_CHAR;
    l_record.invoice_to_state                := FND_API.G_MISS_CHAR;
    l_record.invoice_to_zip                  := FND_API.G_MISS_CHAR;
    l_record.invoice_to_county               := FND_API.G_MISS_CHAR;
    l_record.invoice_to_country              := FND_API.G_MISS_CHAR;
    l_record.invoice_to_province             := FND_API.G_MISS_CHAR;
    l_record.invoicing_rule                  := FND_API.G_MISS_CHAR;
    l_record.item_type                       := FND_API.G_MISS_CHAR;
    l_record.line_type                       := FND_API.G_MISS_CHAR;
    l_record.over_ship_reason              := FND_API.G_MISS_CHAR;
    l_record.payment_term                    := FND_API.G_MISS_CHAR;
    l_record.price_list                      := FND_API.G_MISS_CHAR;
    l_record.project                         := FND_API.G_MISS_CHAR;
    l_record. RETURN_reason                   := FND_API.G_MISS_CHAR;
    l_record.rla_schedule_type               := FND_API.G_MISS_CHAR;
    l_record.salesrep                 := FND_API.G_MISS_CHAR;
    l_record.shipment_priority               := FND_API.G_MISS_CHAR;
    l_record.ship_from_address1              := FND_API.G_MISS_CHAR;
    l_record.ship_from_address2              := FND_API.G_MISS_CHAR;
    l_record.ship_from_address3              := FND_API.G_MISS_CHAR;
    l_record.ship_from_address4              := FND_API.G_MISS_CHAR;
    l_record.ship_from_location              := FND_API.G_MISS_CHAR;
    l_record.ship_from_org                   := FND_API.G_MISS_CHAR;
    l_record.ship_to_address1                := FND_API.G_MISS_CHAR;
    l_record.ship_to_address2                := FND_API.G_MISS_CHAR;
    l_record.ship_to_address3                := FND_API.G_MISS_CHAR;
    l_record.ship_to_address4                := FND_API.G_MISS_CHAR;
    l_record.ship_to_contact                 := FND_API.G_MISS_CHAR;
    l_record.ship_to_location                := FND_API.G_MISS_CHAR;
    l_record.ship_to_org                     := FND_API.G_MISS_CHAR;
    l_record.ship_to_city                    := FND_API.G_MISS_CHAR;
    l_record.ship_to_state                   := FND_API.G_MISS_CHAR;
    l_record.ship_to_zip                     := FND_API.G_MISS_CHAR;
    l_record.ship_to_country                 := FND_API.G_MISS_CHAR;
    l_record.ship_to_county                  := FND_API.G_MISS_CHAR;
    l_record.ship_to_province                := FND_API.G_MISS_CHAR;
    l_record.source_type                     := FND_API.G_MISS_CHAR;
    l_record.intermed_ship_to_address1       := FND_API.G_MISS_CHAR;
    l_record.intermed_ship_to_address2       := FND_API.G_MISS_CHAR;
    l_record.intermed_ship_to_address3       := FND_API.G_MISS_CHAR;
    l_record.intermed_ship_to_address4       := FND_API.G_MISS_CHAR;
    l_record.intermed_ship_to_contact        := FND_API.G_MISS_CHAR;
    l_record.intermed_ship_to_location       := FND_API.G_MISS_CHAR;
    l_record.intermed_ship_to_org            := FND_API.G_MISS_CHAR;
    l_record.intermed_ship_to_city           := FND_API.G_MISS_CHAR;
    l_record.intermed_ship_to_state          := FND_API.G_MISS_CHAR;
    l_record.intermed_ship_to_zip            := FND_API.G_MISS_CHAR;
    l_record.intermed_ship_to_country        := FND_API.G_MISS_CHAR;
    l_record.intermed_ship_to_county         := FND_API.G_MISS_CHAR;
    l_record.intermed_ship_to_province       := FND_API.G_MISS_CHAR;
    l_record.sold_to_org                     := FND_API.G_MISS_CHAR;
    l_record.sold_from_org                   := FND_API.G_MISS_CHAR;
    l_record.task                            := FND_API.G_MISS_CHAR;
    l_record.tax_exempt                      := FND_API.G_MISS_CHAR;
    l_record.tax_exempt_reason               := FND_API.G_MISS_CHAR;
    l_record.tax_point                       := FND_API.G_MISS_CHAR;
    l_record.veh_cus_item_cum_key            := FND_API.G_MISS_CHAR;
    l_record.visible_demand                  := FND_API.G_MISS_CHAR;
    l_record.customer_payment_term         := FND_API.G_MISS_CHAR;
    l_record.ref_order_number              := FND_API.G_MISS_NUM;
    l_record.ref_line_number               := FND_API.G_MISS_NUM;
    l_record.ref_shipment_number           := FND_API.G_MISS_NUM;
    l_record.ref_option_number             := FND_API.G_MISS_NUM;
    l_record.ref_invoice_number                := FND_API.G_MISS_CHAR;
    l_record.ref_invoice_line_number       := FND_API.G_MISS_NUM;
    l_record.credit_invoice_number            := FND_API.G_MISS_CHAR;
    l_record.tax_group                         := FND_API.G_MISS_CHAR;
    l_record.status                          := FND_API.G_MISS_CHAR;
    l_record.freight_carrier                 := FND_API.G_MISS_CHAR;
    l_record.shipping_method                 := FND_API.G_MISS_CHAR;
    l_record.calculate_price_descr              := FND_API.G_MISS_CHAR;
    l_record.deliver_to_customer_Number_oi    := FND_API.G_MISS_CHAR;
    l_record.deliver_to_customer_Name_oi     := FND_API.G_MISS_CHAR;
    l_record.ship_to_customer_Number_oi     := FND_API.G_MISS_CHAR;
    l_record.ship_to_customer_Name_oi      := FND_API.G_MISS_CHAR;
    l_record.invoice_to_customer_Number_oi    := FND_API.G_MISS_CHAR;
    l_record.invoice_to_customer_Name_oi     := FND_API.G_MISS_CHAR;
    l_record.original_ordered_item           := FND_API.G_MISS_CHAR;
    l_record.original_inventory_item         := FND_API.G_MISS_CHAR;
    l_record.original_item_identifier_type   := FND_API.G_MISS_CHAR;
    l_record.item_relationship_type_dsp      := FND_API.G_MISS_CHAR;

    RETURN l_record;

END G_MISS_LINE_VAL_REC;

FUNCTION G_MISS_LINE_ADJ_VAL_REC RETURN Line_Adj_Val_Rec_Type IS
l_record		Line_Adj_Val_Rec_Type;
BEGIN

    l_record.discount                        := FND_API.G_MISS_CHAR;
    l_record.List_name                := FND_API.G_MISS_CHAR;
    l_record.version_no                     := FND_API.G_MISS_CHAR;

    RETURN l_record;

END G_MISS_LINE_ADJ_VAL_REC;


FUNCTION G_MISS_LINE_SCREDIT_VAL_REC RETURN Line_Scredit_Val_Rec_Type IS
l_record		Line_Scredit_Val_Rec_Type;
BEGIN

    l_record.salesrep                        := FND_API.G_MISS_CHAR;
    l_record.sales_credit_type                := FND_API.G_MISS_CHAR;

    RETURN l_record;

END G_MISS_LINE_SCREDIT_VAL_REC;

FUNCTION G_MISS_LOT_SERIAL_VAL_REC RETURN Lot_Serial_Val_Rec_Type IS
l_record		Lot_Serial_Val_Rec_Type;
BEGIN

    l_record.line                            := FND_API.G_MISS_CHAR;
    l_record.lot_serial                      := FND_API.G_MISS_CHAR;

    RETURN l_record;

END G_MISS_LOT_SERIAL_VAL_REC;


-- lkxu
FUNCTION G_MISS_PAYMENT_TYPES_REC RETURN Payment_Types_Rec_Type IS
l_record		Payment_Types_Rec_Type;
BEGIN

    l_record.payment_trx_id                  := FND_API.G_MISS_NUM;
    l_record.commitment_applied_amount       := FND_API.G_MISS_NUM;
    l_record.commitment_interfaced_amount    := FND_API.G_MISS_NUM;
    l_record.payment_level_code  	     := FND_API.G_MISS_CHAR;
    l_record.header_id 			     := FND_API.G_MISS_NUM;
    l_record.line_id 			     := FND_API.G_MISS_NUM;
    l_record.creation_date                   := FND_API.G_MISS_DATE;
    l_record.created_by	                     := FND_API.G_MISS_NUM;
    l_record.last_update_date                := FND_API.G_MISS_DATE;
    l_record.last_updated_by                 := FND_API.G_MISS_NUM;
    l_record.last_update_login               := FND_API.G_MISS_NUM;
    l_record.request_id                      := FND_API.G_MISS_NUM;
    l_record.program_application_id          := FND_API.G_MISS_NUM;
    l_record.program_id  	             := FND_API.G_MISS_NUM;
    l_record.program_update_date             := FND_API.G_MISS_DATE;
    l_record.context  			     := FND_API.G_MISS_CHAR;
    l_record.attribute1			     := FND_API.G_MISS_CHAR;
    l_record.attribute2			     := FND_API.G_MISS_CHAR;
    l_record.attribute3			     := FND_API.G_MISS_CHAR;
    l_record.attribute4			     := FND_API.G_MISS_CHAR;
    l_record.attribute5			     := FND_API.G_MISS_CHAR;
    l_record.attribute6			     := FND_API.G_MISS_CHAR;
    l_record.attribute7			     := FND_API.G_MISS_CHAR;
    l_record.attribute8			     := FND_API.G_MISS_CHAR;
    l_record.attribute9			     := FND_API.G_MISS_CHAR;
    l_record.attribute10		     := FND_API.G_MISS_CHAR;
    l_record.attribute11		     := FND_API.G_MISS_CHAR;
    l_record.attribute12		     := FND_API.G_MISS_CHAR;
    l_record.attribute13		     := FND_API.G_MISS_CHAR;
    l_record.attribute14		     := FND_API.G_MISS_CHAR;
    l_record.attribute15		     := FND_API.G_MISS_CHAR;


    RETURN l_record;

END G_MISS_PAYMENT_TYPES_REC;

--serla begin
--  Header_Payment record type

FUNCTION G_MISS_HEADER_PAYMENT_REC
RETURN Header_Payment_Rec_Type IS
l_record                Header_Payment_Rec_Type;
BEGIN
              l_record.ATTRIBUTE1                     := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE2                     := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE3                     := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE4                     := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE5                     := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE6                     := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE7                     := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE8                     := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE9                     := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE10                    := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE11                    := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE12                    := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE13                    := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE14                    := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE15                    := FND_API.G_MISS_CHAR;
              l_record.CHECK_NUMBER                   := FND_API.G_MISS_CHAR;
              l_record.CREATED_BY                     := FND_API.G_MISS_NUM;
              l_record.CREATION_DATE                  := FND_API.G_MISS_DATE;
              l_record.CREDIT_CARD_APPROVAL_CODE      := FND_API.G_MISS_CHAR;
              l_record.CREDIT_CARD_APPROVAL_DATE      := FND_API.G_MISS_DATE;
              l_record.CREDIT_CARD_CODE               := FND_API.G_MISS_CHAR;
              l_record.CREDIT_CARD_EXPIRATION_DATE    := FND_API.G_MISS_DATE;
              l_record.CREDIT_CARD_HOLDER_NAME        := FND_API.G_MISS_CHAR;
              l_record.CREDIT_CARD_NUMBER             := FND_API.G_MISS_CHAR;
              l_record.PAYMENT_LEVEL_CODE             := FND_API.G_MISS_CHAR;
              l_record.COMMITMENT_APPLIED_AMOUNT      := FND_API.G_MISS_NUM;
              l_record.COMMITMENT_INTERFACED_AMOUNT   := FND_API.G_MISS_NUM;
              l_record.CONTEXT                        := FND_API.G_MISS_CHAR;
              l_record.PAYMENT_NUMBER                 := FND_API.G_MISS_NUM;
              l_record.HEADER_ID                      := FND_API.G_MISS_NUM;
              l_record.LAST_UPDATED_BY                := FND_API.G_MISS_NUM;
              l_record.LAST_UPDATE_DATE               := FND_API.G_MISS_DATE;
              l_record.LAST_UPDATE_LOGIN              := FND_API.G_MISS_NUM;
              l_record.LINE_ID                        := FND_API.G_MISS_NUM;
              l_record.PAYMENT_AMOUNT                 := FND_API.G_MISS_NUM;
              l_record.PAYMENT_PERCENTAGE             := FND_API.G_MISS_NUM; -- Added for bug 8478559
              l_record.PAYMENT_COLLECTION_EVENT       := FND_API.G_MISS_CHAR;
              l_record.PAYMENT_TRX_ID                 := FND_API.G_MISS_NUM;
              l_record.PAYMENT_TYPE_CODE              := FND_API.G_MISS_CHAR;
              l_record.PAYMENT_SET_ID                 := FND_API.G_MISS_NUM;
              l_record.PREPAID_AMOUNT                 := FND_API.G_MISS_NUM;
              l_record.PROGRAM_APPLICATION_ID         := FND_API.G_MISS_NUM;
              l_record.PROGRAM_ID                     := FND_API.G_MISS_NUM;
              l_record.PROGRAM_UPDATE_DATE            := FND_API.G_MISS_DATE;
              l_record.RECEIPT_METHOD_ID              := FND_API.G_MISS_NUM;
              l_record.REQUEST_ID                     := FND_API.G_MISS_NUM;
              l_record.TANGIBLE_ID                    := FND_API.G_MISS_CHAR;
              l_record.RETURN_STATUS                  := FND_API.G_MISS_CHAR;
              l_record.DB_FLAG                        := FND_API.G_MISS_CHAR;
              l_record.OPERATION                      := FND_API.G_MISS_CHAR;
              l_record.LOCK_CONTROL                   := FND_API.G_MISS_NUM;
              l_record.DEFER_PAYMENT_PROCESSING_FLAG  := FND_API.G_MISS_CHAR;
              l_record.TRXN_EXTENSION_ID              := FND_API.G_MISS_NUM;
              --8219019 start
              l_record.CC_INSTRUMENT_ID               := FND_API.G_MISS_NUM;
              l_record.CC_INSTRUMENT_ASSIGNMENT_ID    := FND_API.G_MISS_NUM;
              --8219019 end

   RETURN l_record;

END G_MISS_HEADER_PAYMENT_REC;

--  Line_Payment record type

FUNCTION G_MISS_LINE_PAYMENT_REC
RETURN Line_Payment_Rec_Type IS
l_record                Line_Payment_Rec_Type;
BEGIN
              l_record.ATTRIBUTE1                     := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE2                     := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE3                     := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE4                     := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE5                     := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE6                     := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE7                     := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE8                     := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE9                     := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE10                    := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE11                    := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE12                    := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE13                    := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE14                    := FND_API.G_MISS_CHAR;
              l_record.ATTRIBUTE15                    := FND_API.G_MISS_CHAR;
              l_record.CHECK_NUMBER                   := FND_API.G_MISS_CHAR;
              l_record.CREATED_BY                     := FND_API.G_MISS_NUM;
              l_record.CREATION_DATE                  := FND_API.G_MISS_DATE;
              l_record.CREDIT_CARD_APPROVAL_CODE      := FND_API.G_MISS_CHAR;
              l_record.CREDIT_CARD_APPROVAL_DATE      := FND_API.G_MISS_DATE;
              l_record.CREDIT_CARD_CODE               := FND_API.G_MISS_CHAR;
              l_record.CREDIT_CARD_EXPIRATION_DATE    := FND_API.G_MISS_DATE;
              l_record.CREDIT_CARD_HOLDER_NAME        := FND_API.G_MISS_CHAR;
              l_record.CREDIT_CARD_NUMBER             := FND_API.G_MISS_CHAR;
              l_record.PAYMENT_LEVEL_CODE             := FND_API.G_MISS_CHAR;
              l_record.COMMITMENT_APPLIED_AMOUNT      := FND_API.G_MISS_NUM;
              l_record.COMMITMENT_INTERFACED_AMOUNT   := FND_API.G_MISS_NUM;
              l_record.CONTEXT                        := FND_API.G_MISS_CHAR;
              l_record.PAYMENT_NUMBER                 := FND_API.G_MISS_NUM;
              l_record.HEADER_ID                      := FND_API.G_MISS_NUM;
              l_record.LAST_UPDATED_BY                := FND_API.G_MISS_NUM;
              l_record.LAST_UPDATE_DATE               := FND_API.G_MISS_DATE;
              l_record.LAST_UPDATE_LOGIN              := FND_API.G_MISS_NUM;
              l_record.LINE_ID                        := FND_API.G_MISS_NUM;
              l_record.PAYMENT_AMOUNT                 := FND_API.G_MISS_NUM;
              l_record.PAYMENT_COLLECTION_EVENT       := FND_API.G_MISS_CHAR;
              l_record.PAYMENT_TRX_ID                 := FND_API.G_MISS_NUM;
              l_record.PAYMENT_TYPE_CODE              := FND_API.G_MISS_CHAR;
              l_record.PAYMENT_SET_ID                 := FND_API.G_MISS_NUM;
              l_record.PREPAID_AMOUNT                 := FND_API.G_MISS_NUM;
              l_record.PROGRAM_APPLICATION_ID         := FND_API.G_MISS_NUM;
              l_record.PROGRAM_ID                     := FND_API.G_MISS_NUM;
              l_record.PROGRAM_UPDATE_DATE            := FND_API.G_MISS_DATE;
              l_record.RECEIPT_METHOD_ID              := FND_API.G_MISS_NUM;
              l_record.REQUEST_ID                     := FND_API.G_MISS_NUM;
              l_record.TANGIBLE_ID                    := FND_API.G_MISS_CHAR;
              l_record.RETURN_STATUS                  := FND_API.G_MISS_CHAR;
              l_record.DB_FLAG                        := FND_API.G_MISS_CHAR;
              l_record.OPERATION                      := FND_API.G_MISS_CHAR;
              l_record.LOCK_CONTROL                   := FND_API.G_MISS_NUM;
              l_record.DEFER_PAYMENT_PROCESSING_FLAG  := FND_API.G_MISS_CHAR;
              l_record.TRXN_EXTENSION_ID              := FND_API.G_MISS_NUM;

  RETURN l_record;

END G_MISS_LINE_PAYMENT_REC;

FUNCTION G_MISS_HEADER_PAYMENT_VAL_REC
RETURN Header_Payment_Val_Rec_Type IS
l_record                Header_Payment_Val_Rec_Type;
BEGIN
      l_record.PAYMENT_COLLECTION_EVENT_NAME    := FND_API.G_MISS_CHAR;
      l_record.RECEIPT_METHOD                   := FND_API.G_MISS_CHAR;
      l_record.PAYMENT_TYPE                     := FND_API.G_MISS_CHAR;
      l_record.PAYMENT_PERCENTAGE               := FND_API.G_MISS_NUM; -- Added for bug 8478559


  RETURN l_record;

END G_MISS_HEADER_PAYMENT_VAL_REC;

FUNCTION G_MISS_LINE_PAYMENT_VAL_REC
RETURN Line_Payment_Val_Rec_Type IS
l_record                Line_Payment_Val_Rec_Type;
BEGIN
      l_record.PAYMENT_COLLECTION_EVENT_NAME    := FND_API.G_MISS_CHAR;
      l_record.RECEIPT_METHOD                   := FND_API.G_MISS_CHAR;
      l_record.PAYMENT_TYPE                     := FND_API.G_MISS_CHAR;

  RETURN l_record;

END G_MISS_LINE_PAYMENT_VAL_REC;


--ER7675548
FUNCTION G_MISS_CUSTOMER_INFO_REC RETURN CUSTOMER_INFO_REC_TYPE
IS
l_cust_info_rec CUSTOMER_INFO_REC_TYPE;
BEGIN
l_cust_info_rec.customer_info_ref         := NULL;
l_cust_info_rec.parent_customer_info_ref  := NULL;
l_cust_info_rec.customer_type             := NULL;
l_cust_info_rec.customer_info_type_code   := NULL;
l_cust_info_rec.customer_id               := NULL;
l_cust_info_rec.site_use_id               := NULL;
l_cust_info_rec.contact_id                := NULL;
l_cust_info_rec.organization_name         := NULL;
l_cust_info_rec.account_description       := NULL;
l_cust_info_rec.person_first_name         := NULL;
l_cust_info_rec.person_middle_name        := NULL;
l_cust_info_rec.person_last_name          := NULL;
l_cust_info_rec.person_name_suffix        := NULL;
l_cust_info_rec.person_title              := NULL;
l_cust_info_rec.email_address             := NULL;
l_cust_info_rec.customer_number           := NULL;
l_cust_info_rec.party_number              := NULL;
l_cust_info_rec.location_number           := NULL;
l_cust_info_rec.site_number               := NULL;
l_cust_info_rec.contact_number            := NULL;
l_cust_info_rec.party_id                  := NULL;
l_cust_info_rec.phone_country_code        := NULL;
l_cust_info_rec.phone_area_code           := NULL;
l_cust_info_rec.phone_number              := NULL;
l_cust_info_rec.phone_extension           := NULL;
l_cust_info_rec.address_style             := NULL;
l_cust_info_rec.country                   := NULL;
l_cust_info_rec.address1                  := NULL;
l_cust_info_rec.address2                  := NULL;
l_cust_info_rec.address3                  := NULL;
l_cust_info_rec.address4                  := NULL;
l_cust_info_rec.city                      := NULL;
l_cust_info_rec.postal_code               := NULL;
l_cust_info_rec.state                     := NULL;
l_cust_info_rec.province                  := NULL;
l_cust_info_rec.county                    := NULL;
l_cust_info_rec.address_line_phonetic     := NULL;
l_cust_info_rec.new_account_id            := NULL;
l_cust_info_rec.attribute_category        := NULL;
l_cust_info_rec.attribute1                := NULL;
l_cust_info_rec.attribute2                := NULL;
l_cust_info_rec.attribute3                := NULL;
l_cust_info_rec.attribute4                := NULL;
l_cust_info_rec.attribute5                := NULL;
l_cust_info_rec.attribute6                := NULL;
l_cust_info_rec.attribute7                := NULL;
l_cust_info_rec.attribute8                := NULL;
l_cust_info_rec.attribute9                := NULL;
l_cust_info_rec.attribute10               := NULL;
l_cust_info_rec.attribute11               := NULL;
l_cust_info_rec.attribute12               := NULL;
l_cust_info_rec.attribute13               := NULL;
l_cust_info_rec.attribute14               := NULL;
l_cust_info_rec.attribute15               := NULL;
l_cust_info_rec.attribute16               := NULL;
l_cust_info_rec.attribute17               := NULL;
l_cust_info_rec.attribute18               := NULL;
l_cust_info_rec.attribute19               := NULL;
l_cust_info_rec.attribute20               := NULL;
l_cust_info_rec.attribute21               := NULL;
l_cust_info_rec.attribute22               := NULL;
l_cust_info_rec.attribute23               := NULL;
l_cust_info_rec.attribute24               := NULL;
l_cust_info_rec.attribute25               := NULL;
l_cust_info_rec.global_attribute_category := NULL;
l_cust_info_rec.global_attribute1         := NULL;
l_cust_info_rec.global_attribute2         := NULL;
l_cust_info_rec.global_attribute3         := NULL;
l_cust_info_rec.global_attribute4         := NULL;
l_cust_info_rec.global_attribute5         := NULL;
l_cust_info_rec.global_attribute6         := NULL;
l_cust_info_rec.global_attribute7         := NULL;
l_cust_info_rec.global_attribute8         := NULL;
l_cust_info_rec.global_attribute9         := NULL;
l_cust_info_rec.global_attribute10        := NULL;
l_cust_info_rec.global_attribute11        := NULL;
l_cust_info_rec.global_attribute12        := NULL;
l_cust_info_rec.global_attribute13        := NULL;
l_cust_info_rec.global_attribute14        := NULL;
l_cust_info_rec.global_attribute15        := NULL;
l_cust_info_rec.global_attribute16        := NULL;
l_cust_info_rec.global_attribute17        := NULL;
l_cust_info_rec.global_attribute18        := NULL;
l_cust_info_rec.global_attribute19        := NULL;
l_cust_info_rec.global_attribute20        := NULL;
l_cust_info_rec.orig_system               := NULL;
l_cust_info_rec.orig_system_reference     := NULL;

return l_cust_info_rec;

END G_MISS_CUSTOMER_INFO_REC;

--ER7675548


--serla end
--  Start of Comments
--  API name    Process_Order
--  Type        Public
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Process_Order
(   p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC
,   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_action_commit                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  Header_Rec_Type :=
                                        G_MISS_HEADER_REC
,   p_old_header_rec                IN  Header_Rec_Type :=
                                        G_MISS_HEADER_REC
,   p_header_val_rec                IN  Header_Val_Rec_Type :=
                                        G_MISS_HEADER_VAL_REC
,   p_old_header_val_rec            IN  Header_Val_Rec_Type :=
                                        G_MISS_HEADER_VAL_REC
,   p_Header_Adj_tbl                IN  Header_Adj_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_TBL
,   p_old_Header_Adj_tbl            IN  Header_Adj_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_TBL
,   p_Header_Adj_val_tbl            IN  Header_Adj_Val_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_VAL_TBL
,   p_old_Header_Adj_val_tbl        IN  Header_Adj_Val_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_VAL_TBL
,   p_Header_price_Att_tbl          IN  Header_Price_Att_Tbl_Type :=
                                        G_MISS_HEADER_PRICE_ATT_TBL
,   p_old_Header_Price_Att_tbl      IN  Header_Price_Att_Tbl_Type :=
                                        G_MISS_HEADER_PRICE_ATT_TBL
,   p_Header_Adj_Att_tbl            IN  Header_Adj_Att_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_ATT_TBL
,   p_old_Header_Adj_Att_tbl        IN  Header_Adj_Att_Tbl_Type :=
    G_MISS_HEADER_ADJ_ATT_TBL
,   p_Header_Adj_Assoc_tbl            IN  Header_Adj_Assoc_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_old_Header_Adj_Assoc_tbl        IN  Header_Adj_Assoc_Tbl_Type :=
    G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_Header_Scredit_tbl            IN  Header_Scredit_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_TBL
,   p_old_Header_Scredit_tbl        IN  Header_Scredit_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_TBL
,   p_Header_Scredit_val_tbl        IN  Header_Scredit_Val_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_old_Header_Scredit_val_tbl    IN  Header_Scredit_Val_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_line_tbl                      IN  Line_Tbl_Type :=
                                        G_MISS_LINE_TBL
,   p_old_line_tbl                  IN  Line_Tbl_Type :=
                                        G_MISS_LINE_TBL
,   p_line_val_tbl                  IN  Line_Val_Tbl_Type :=
                                        G_MISS_LINE_VAL_TBL
,   p_old_line_val_tbl              IN  Line_Val_Tbl_Type :=
                                        G_MISS_LINE_VAL_TBL
,   p_Line_Adj_tbl                  IN  Line_Adj_Tbl_Type :=
                                        G_MISS_LINE_ADJ_TBL
,   p_old_Line_Adj_tbl              IN  Line_Adj_Tbl_Type :=
                                        G_MISS_LINE_ADJ_TBL
,   p_Line_Adj_val_tbl              IN  Line_Adj_Val_Tbl_Type :=
                                        G_MISS_LINE_ADJ_VAL_TBL
,   p_old_Line_Adj_val_tbl          IN  Line_Adj_Val_Tbl_Type :=
                                        G_MISS_LINE_ADJ_VAL_TBL
,   p_Line_price_Att_tbl            IN  Line_Price_Att_Tbl_Type :=
                                        G_MISS_LINE_PRICE_ATT_TBL
,   p_old_Line_Price_Att_tbl        IN  Line_Price_Att_Tbl_Type :=
                                        G_MISS_LINE_PRICE_ATT_TBL
,   p_Line_Adj_Att_tbl              IN  Line_Adj_Att_Tbl_Type :=
                                        G_MISS_LINE_ADJ_ATT_TBL
,   p_old_Line_Adj_Att_tbl          IN  Line_Adj_Att_Tbl_Type :=
    G_MISS_LINE_ADJ_ATT_TBL
,   p_Line_Adj_Assoc_tbl              IN  Line_Adj_Assoc_Tbl_Type :=
                                        G_MISS_LINE_ADJ_ASSOC_TBL
,   p_old_Line_Adj_Assoc_tbl          IN  Line_Adj_Assoc_Tbl_Type :=
    G_MISS_LINE_ADJ_ASSOC_TBL
,   p_Line_Scredit_tbl              IN  Line_Scredit_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_TBL
,   p_old_Line_Scredit_tbl          IN  Line_Scredit_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_TBL
,   p_Line_Scredit_val_tbl          IN  Line_Scredit_Val_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_VAL_TBL
,   p_old_Line_Scredit_val_tbl      IN  Line_Scredit_Val_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_VAL_TBL
,   p_Lot_Serial_tbl                IN  Lot_Serial_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_TBL
,   p_old_Lot_Serial_tbl            IN  Lot_Serial_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  Lot_Serial_Val_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_VAL_TBL
,   p_old_Lot_Serial_val_tbl        IN  Lot_Serial_Val_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_VAL_TBL
,   p_action_request_tbl	    IN  Request_Tbl_Type :=
					G_MISS_REQUEST_TBL
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */ Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Val_Tbl_Type
,   x_action_request_tbl	    OUT NOCOPY /* file.sql.39 change */ Request_Tbl_Type
--For bug 3390458
,   p_rtrim_data                    IN  Varchar2 :='N'
,   p_validate_desc_flex            in varchar2 default 'Y'  --bug4343612
--ER7675548
,   p_header_customer_info_tbl      IN OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE :=
                                         OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_TBL
,   p_line_customer_info_tbl      IN OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE :=
                                       OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_TBL
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Order';
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_header_rec                  Header_Rec_Type;
l_Header_Adj_tbl              Header_Adj_Tbl_Type;
l_Header_price_Att_tbl        Header_Price_Att_Tbl_Type ;
l_Header_Adj_Att_tbl          Header_Adj_Att_Tbl_Type ;
l_Header_Adj_Assoc_tbl        Header_Adj_Assoc_Tbl_Type ;
l_Header_Scredit_tbl          Header_Scredit_Tbl_Type;
l_line_tbl                    Line_Tbl_Type;
l_Line_Adj_tbl                Line_Adj_Tbl_Type;
l_Line_price_Att_tbl          Line_Price_Att_Tbl_Type ;
l_Line_Adj_Att_tbl            Line_Adj_Att_Tbl_Type ;
l_Line_Adj_Assoc_tbl          Line_Adj_Assoc_Tbl_Type ;
l_Line_Scredit_tbl            Line_Scredit_Tbl_Type;
l_Lot_Serial_tbl              Lot_Serial_Tbl_Type;
l_old_header_rec              Header_Rec_Type;
l_old_Header_Adj_tbl          Header_Adj_Tbl_Type;
l_old_Header_price_Att_tbl    Header_Price_Att_Tbl_Type ;
l_old_Header_Adj_Att_tbl      Header_Adj_Att_Tbl_Type ;
l_old_Header_Adj_Assoc_tbl    Header_Adj_Assoc_Tbl_Type ;
l_old_Header_Scredit_tbl      Header_Scredit_Tbl_Type;
l_old_line_tbl                Line_Tbl_Type;
l_old_Line_Adj_tbl            Line_Adj_Tbl_Type;
l_old_Line_price_Att_tbl      Line_Price_Att_Tbl_Type ;
l_old_Line_Adj_Att_tbl        Line_Adj_Att_Tbl_Type ;
l_old_Line_Adj_Assoc_tbl      Line_Adj_Assoc_Tbl_Type ;
l_old_Line_Scredit_tbl        Line_Scredit_Tbl_Type;
l_old_Lot_Serial_tbl          Lot_Serial_Tbl_Type;
x_Header_Payment_tbl          Header_Payment_Tbl_Type;
x_Header_Payment_val_tbl      Header_Payment_Val_Tbl_Type;
x_Line_Payment_tbl            Line_Payment_Tbl_Type;
x_Line_Payment_val_tbl        Line_Payment_Val_Tbl_Type;

BEGIN

 -- Call over loaded process_order to pass payment tables

       Process_Order
(   p_org_id                            => p_org_id --MOAC
,   p_operating_unit                    => p_operating_unit
,   p_api_version_number            	=> p_api_version_number
,   p_init_msg_list                 	=> p_init_msg_list
,   p_return_values                 	=> p_return_values
,   p_action_commit                	=> p_action_commit
,   x_return_status                 	=> x_return_status
,   x_msg_count                     	=> x_msg_count
,   x_msg_data                      	=> x_msg_data
,   p_header_rec                    	=> p_header_rec
,   p_old_header_rec                	=> p_old_header_rec
,   p_header_val_rec                	=> p_header_val_rec
,   p_old_header_val_rec            	=> p_old_header_val_rec
,   p_Header_Adj_tbl                	=> p_Header_Adj_tbl
,   p_old_Header_Adj_tbl            	=> p_old_Header_Adj_tbl
,   p_Header_Adj_val_tbl            	=> p_Header_Adj_val_tbl
,   p_old_Header_Adj_val_tbl            => p_old_Header_Adj_val_tbl
,   p_Header_price_Att_tbl              => p_Header_price_Att_tbl
,   p_old_Header_Price_Att_tbl          => p_old_Header_Price_Att_tbl
,   p_Header_Adj_Att_tbl                => p_Header_Adj_Att_tbl
,   p_old_Header_Adj_Att_tbl            => p_old_Header_Adj_Att_tbl
,   p_Header_Adj_Assoc_tbl              => p_Header_Adj_Assoc_tbl
,   p_old_Header_Adj_Assoc_tbl          => p_old_Header_Adj_Assoc_tbl
,   p_Header_Scredit_tbl            	=> p_Header_Scredit_tbl
,   p_old_Header_Scredit_tbl            => p_old_Header_Scredit_tbl
,   p_Header_Scredit_val_tbl            => p_Header_Scredit_val_tbl
,   p_old_Header_Scredit_val_tbl        => p_old_Header_Scredit_val_tbl
,   p_Header_Payment_tbl            	=> G_MISS_HEADER_PAYMENT_TBL
,   p_old_Header_Payment_tbl            => G_MISS_HEADER_PAYMENT_TBL
,   p_Header_Payment_val_tbl            => G_MISS_HEADER_PAYMENT_VAL_TBL
,   p_old_Header_Payment_val_tbl        => G_MISS_HEADER_PAYMENT_VAL_TBL
,   p_line_tbl                      	=> p_line_tbl
,   p_old_line_tbl                  	=> p_old_line_tbl
,   p_line_val_tbl                  	=> p_line_val_tbl
,   p_old_line_val_tbl              	=> p_old_line_val_tbl
,   p_Line_Adj_tbl                  	=> p_Line_Adj_tbl
,   p_old_Line_Adj_tbl              	=> p_old_Line_Adj_tbl
,   p_Line_Adj_val_tbl              	=> p_Line_Adj_val_tbl
,   p_old_Line_Adj_val_tbl          	=> p_old_Line_Adj_val_tbl
,   p_Line_price_Att_tbl                => p_Line_price_Att_tbl
,   p_old_Line_Price_Att_tbl            => p_old_Line_Price_Att_tbl
,   p_Line_Adj_Att_tbl                  => p_Line_Adj_Att_tbl
,   p_old_Line_Adj_Att_tbl              => p_old_Line_Adj_Att_tbl
,   p_Line_Adj_Assoc_tbl                => p_Line_Adj_Assoc_tbl
,   p_old_Line_Adj_Assoc_tbl            => p_old_Line_Adj_Assoc_tbl
,   p_Line_Scredit_tbl              	=> p_Line_Scredit_tbl
,   p_old_Line_Scredit_tbl          	=> p_old_Line_Scredit_tbl
,   p_Line_Scredit_val_tbl          	=> p_Line_Scredit_val_tbl
,   p_old_Line_Scredit_val_tbl      	=> p_old_Line_Scredit_val_tbl
,   p_Line_Payment_tbl            	=> G_MISS_LINE_PAYMENT_TBL
,   p_old_Line_Payment_tbl              => G_MISS_LINE_PAYMENT_TBL
,   p_Line_Payment_val_tbl              => G_MISS_LINE_PAYMENT_VAL_TBL
,   p_old_Line_Payment_val_tbl          => G_MISS_LINE_PAYMENT_VAL_TBL
,   p_Lot_Serial_tbl              	=> p_Lot_Serial_tbl
,   p_old_Lot_Serial_tbl          	=> p_old_Lot_Serial_tbl
,   p_Lot_Serial_val_tbl          	=> p_Lot_Serial_val_tbl
,   p_old_Lot_Serial_val_tbl      	=> p_old_Lot_Serial_val_tbl
,   p_action_request_tbl                => p_action_request_tbl
,   x_header_rec                    	=> x_header_rec
,   x_header_val_rec                	=> x_header_val_rec
,   x_Header_Adj_tbl                	=> x_Header_Adj_tbl
,   x_Header_Adj_val_tbl            	=> x_Header_Adj_val_tbl
,   x_Header_price_Att_tbl              => x_Header_price_Att_tbl
,   x_Header_Adj_Att_tbl                => x_Header_Adj_Att_tbl
,   x_Header_Adj_Assoc_tbl              => x_Header_Adj_Assoc_tbl
,   x_Header_Scredit_tbl            	=> x_Header_Scredit_tbl
,   x_Header_Scredit_val_tbl        	=> x_Header_Scredit_val_tbl
,   x_Header_Payment_tbl            	=> x_Header_Payment_tbl
,   x_Header_Payment_val_tbl        	=> x_Header_Payment_val_tbl
,   x_line_tbl                   	=> x_line_tbl
,   x_line_val_tbl                  	=> x_line_val_tbl
,   x_Line_Adj_tbl                  	=> x_Line_Adj_tbl
,   x_Line_Adj_val_tbl              	=> x_Line_Adj_val_tbl
,   x_Line_price_Att_tbl                => x_Line_price_Att_tbl
,   x_Line_Adj_Att_tbl                  => x_Line_Adj_Att_tbl
,   x_Line_Adj_Assoc_tbl                => x_Line_Adj_Assoc_tbl
,   x_Line_Scredit_tbl              	=> x_Line_Scredit_tbl
,   x_Line_Scredit_val_tbl          	=> x_Line_Scredit_val_tbl
,   x_Line_Payment_tbl              	=> x_Line_Payment_tbl
,   x_Line_Payment_val_tbl          	=> x_Line_Payment_val_tbl
,   x_Lot_Serial_tbl                    => x_Lot_Serial_tbl
,   x_Lot_Serial_Val_tbl                => x_Lot_Serial_Val_tbl
,   x_action_request_tbl	        => x_action_request_tbl
--For bug 3390458
,   p_rtrim_data                        =>p_rtrim_data
,   p_validate_desc_flex                =>p_validate_desc_flex --for bug4343612
--ER7675548
,   p_header_customer_info_tbl         =>p_header_customer_info_tbl
,   p_line_customer_info_tbl           =>p_line_customer_info_tbl
);


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Order'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Order;


--  Start of Comments
--  API name    Lock_Order
--  Type        Public
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Lock_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,  p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC

,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  Header_Rec_Type :=
                                        G_MISS_HEADER_REC
,   p_header_val_rec                IN  Header_Val_Rec_Type :=
                                        G_MISS_HEADER_VAL_REC
,   p_Header_Adj_tbl                IN  Header_Adj_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_TBL
,   p_Header_Adj_val_tbl            IN  Header_Adj_Val_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_VAL_TBL
,   p_Header_price_Att_tbl          IN  Header_Price_Att_Tbl_Type :=
                                        G_MISS_HEADER_PRICE_ATT_TBL
,   p_Header_Adj_Att_tbl            IN  Header_Adj_Att_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_ATT_TBL
,   p_Header_Adj_Assoc_tbl            IN  Header_Adj_Assoc_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_Header_Scredit_tbl            IN  Header_Scredit_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_TBL
,   p_Header_Scredit_val_tbl        IN  Header_Scredit_Val_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_line_tbl                      IN  Line_Tbl_Type :=
                                        G_MISS_LINE_TBL
,   p_line_val_tbl                  IN  Line_Val_Tbl_Type :=
                                        G_MISS_LINE_VAL_TBL
,   p_Line_Adj_tbl                  IN  Line_Adj_Tbl_Type :=
                                        G_MISS_LINE_ADJ_TBL
,   p_Line_Adj_val_tbl              IN  Line_Adj_Val_Tbl_Type :=
                                        G_MISS_LINE_ADJ_VAL_TBL
,   p_Line_price_Att_tbl            IN  Line_Price_Att_Tbl_Type :=
                                        G_MISS_LINE_PRICE_ATT_TBL
,   p_Line_Adj_Att_tbl              IN  Line_Adj_Att_Tbl_Type :=
                                        G_MISS_LINE_ADJ_ATT_TBL
,   p_Line_Adj_Assoc_tbl              IN  Line_Adj_Assoc_Tbl_Type :=
                                        G_MISS_LINE_ADJ_ASSOC_TBL
,   p_Line_Scredit_tbl              IN  Line_Scredit_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_TBL
,   p_Line_Scredit_val_tbl          IN  Line_Scredit_Val_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_VAL_TBL
,   p_Lot_Serial_tbl                IN  Lot_Serial_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  Lot_Serial_Val_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_VAL_TBL
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Order';
l_return_status               VARCHAR2(1);
l_header_rec                  Header_Rec_Type;
l_Header_Adj_tbl              Header_Adj_Tbl_Type;
l_Header_price_Att_tbl        Header_Price_Att_Tbl_Type ;
l_Header_Adj_Att_tbl          Header_Adj_Att_Tbl_Type ;
l_Header_Adj_Assoc_tbl        Header_Adj_Assoc_Tbl_Type ;
l_Header_Scredit_tbl          Header_Scredit_Tbl_Type;
l_line_tbl                    Line_Tbl_Type;
l_Line_Adj_tbl                Line_Adj_Tbl_Type;
l_Line_price_Att_tbl          Line_Price_Att_Tbl_Type ;
l_Line_Adj_Att_tbl            Line_Adj_Att_Tbl_Type ;
l_Line_Adj_Assoc_tbl          Line_Adj_Assoc_Tbl_Type ;
l_Line_Scredit_tbl            Line_Scredit_Tbl_Type;
l_Lot_Serial_tbl              Lot_Serial_Tbl_Type;
x_Header_Payment_tbl        	Header_Payment_Tbl_Type;
x_Header_Payment_val_tbl        	Header_Payment_Val_Tbl_Type;
x_Line_Payment_tbl          	Line_Payment_Tbl_Type;
x_Line_Payment_val_tbl          	Line_Payment_Val_Tbl_Type;

BEGIN

-- Calling over loaded lock_order
Lock_Order
(   p_api_version_number            	=> p_api_version_number
,   p_init_msg_list                     => p_init_msg_list
,   p_return_values                 	=> p_return_values
,   p_org_id				=> p_org_id
,   p_operating_unit			=> p_operating_unit
,   x_return_status                 	=> x_return_status
,   x_msg_count                     	=> x_msg_count
,   x_msg_data                      	=> x_msg_data
,   p_header_rec                    	=> p_header_rec
,   p_header_val_rec                	=> p_header_val_rec
,   p_Header_Adj_tbl                	=> p_Header_Adj_tbl
,   p_Header_Adj_val_tbl            	=> p_Header_Adj_val_tbl
,   p_Header_price_Att_tbl              => p_Header_price_Att_tbl
,   p_Header_Adj_Att_tbl                => p_Header_Adj_Att_tbl
,   p_Header_Adj_Assoc_tbl              => p_Header_Adj_Assoc_tbl
,   p_Header_Scredit_tbl            	=> p_Header_Scredit_tbl
,   p_Header_Scredit_val_tbl            => p_Header_Scredit_val_tbl
,   p_Header_Payment_tbl                => G_MISS_HEADER_PAYMENT_TBL
,   p_Header_Payment_val_tbl            => G_MISS_HEADER_PAYMENT_VAL_TBL
,   p_line_tbl                      	=> p_line_tbl
,   p_line_val_tbl                  	=> p_line_val_tbl
,   p_Line_Adj_tbl                  	=> p_Line_Adj_tbl
,   p_Line_Adj_val_tbl              	=> p_Line_Adj_val_tbl
,   p_Line_price_Att_tbl                => p_Line_price_Att_tbl
,   p_Line_Adj_Att_tbl                  => p_Line_Adj_Att_tbl
,   p_Line_Adj_Assoc_tbl                => p_Line_Adj_Assoc_tbl
,   p_Line_Scredit_tbl              	=> p_Line_Scredit_tbl
,   p_Line_Scredit_val_tbl          	=> p_Line_Scredit_val_tbl
,   p_Line_Payment_tbl                	=> G_MISS_LINE_PAYMENT_TBL
,   p_Line_Payment_val_tbl              => G_MISS_LINE_PAYMENT_VAL_TBL
,   p_Lot_Serial_tbl                    => p_Lot_Serial_tbl
,   p_Lot_Serial_val_tbl                => p_Lot_Serial_val_tbl
,   x_header_rec                    	=> x_header_rec
,   x_header_val_rec                	=> x_header_val_rec
,   x_Header_Adj_tbl                	=> x_Header_Adj_tbl
,   x_Header_Adj_val_tbl            	=> x_Header_Adj_val_tbl
,   x_Header_price_Att_tbl              => x_Header_price_Att_tbl
,   x_Header_Adj_Att_tbl                => x_Header_Adj_Att_tbl
,   x_Header_Adj_Assoc_tbl              => x_Header_Adj_Assoc_tbl
,   x_Header_Scredit_tbl            	=> x_Header_Scredit_tbl
,   x_Header_Scredit_val_tbl        	=> x_Header_Scredit_val_tbl
,   x_Header_Payment_tbl        	=> x_Header_Payment_tbl
,   x_Header_Payment_val_tbl            => x_Header_Payment_val_tbl
,   x_line_tbl                      	=> x_line_tbl
,   x_line_val_tbl                  	=> x_line_val_tbl
,   x_Line_Adj_tbl                  	=> x_Line_Adj_tbl
,   x_Line_Adj_val_tbl              	=> x_Line_Adj_val_tbl
,   x_Line_price_Att_tbl                => x_Line_price_Att_tbl
,   x_Line_Adj_Att_tbl                  => x_Line_Adj_Att_tbl
,   x_Line_Adj_Assoc_tbl                => x_Line_Adj_Assoc_tbl
,   x_Line_Scredit_tbl              	=> x_Line_Scredit_tbl
,   x_Line_Scredit_val_tbl          	=> x_Line_Scredit_val_tbl
,   x_Line_Payment_tbl          	=> x_Line_Payment_tbl
,   x_Line_Payment_val_tbl          	=> x_Line_Payment_val_tbl
,   x_Lot_Serial_tbl                    => x_Lot_Serial_tbl
,   x_Lot_Serial_val_tbl                => x_Lot_Serial_val_tbl
);


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Order'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Lock_Order;


--  Start of Comments
--  API name    Get_Order
--  Type        Public
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Get_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header                        IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Order';
l_header_id                   NUMBER := p_header_id;
x_Header_Payment_tbl        	Header_Payment_Tbl_Type;
x_Header_Payment_val_tbl        	Header_Payment_Val_Tbl_Type;
x_Line_Payment_tbl          	Line_Payment_Tbl_Type;
x_Line_Payment_val_tbl          	Line_Payment_Val_Tbl_Type;

BEGIN

-- Calling over loaded get_order
Get_Order
    (   p_api_version_number          => p_api_version_number
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_return_values               => p_return_values
,   p_org_id                            => p_org_id --MOAC
,   p_operating_unit                    => p_operating_unit
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_header_id                   => p_header_id
    ,   p_header                      => p_header
    ,   x_header_rec                  => x_header_rec
    ,   x_header_val_rec              => x_header_val_rec
    ,   x_Header_Adj_tbl              => x_Header_Adj_tbl
    ,   x_Header_Adj_val_tbl          => x_Header_Adj_val_tbl
    ,   x_Header_price_Att_tbl        => x_Header_price_Att_tbl
    ,   x_Header_Adj_Att_tbl          => x_Header_Adj_Att_tbl
    ,   x_Header_Adj_Assoc_tbl        => x_Header_Adj_Assoc_tbl
    ,   x_Header_Scredit_tbl          => x_Header_Scredit_tbl
    ,   x_Header_Scredit_val_tbl      => x_Header_Scredit_val_tbl
    ,   x_Header_Payment_tbl          => x_Header_Payment_tbl
    ,   x_Header_Payment_val_tbl      => x_Header_Payment_val_tbl
    ,   x_line_tbl                    => x_line_tbl
    ,   x_line_val_tbl                => x_line_val_tbl
    ,   x_Line_Adj_tbl                => x_Line_Adj_tbl
    ,   x_Line_Adj_val_tbl            => x_Line_Adj_val_tbl
    ,   x_Line_price_Att_tbl          => x_Line_price_Att_tbl
    ,   x_Line_Adj_Att_tbl            => x_Line_Adj_Att_tbl
    ,   x_Line_Adj_Assoc_tbl          => x_Line_Adj_Assoc_tbl
    ,   x_Line_Scredit_tbl            => x_Line_Scredit_tbl
    ,   x_Line_Scredit_val_tbl        => x_Line_Scredit_val_tbl
    ,   x_Line_Payment_tbl            => x_Line_Payment_tbl
    ,   x_Line_Payment_val_tbl        => x_Line_Payment_val_tbl
    ,   x_Lot_Serial_tbl              => x_Lot_Serial_tbl
    ,   x_Lot_Serial_val_tbl          => x_Lot_Serial_val_tbl
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Order'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Order;



--  Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_header_rec                    IN  Header_Rec_Type
,   p_Header_Adj_tbl                IN  Header_Adj_Tbl_Type
,   p_Header_Scredit_tbl            IN  Header_Scredit_Tbl_Type
,   p_line_tbl                      IN  Line_Tbl_Type
,   p_Line_Adj_tbl                  IN  Line_Adj_Tbl_Type
,   p_Line_Scredit_tbl              IN  Line_Scredit_Tbl_Type
,   p_Lot_Serial_tbl                IN  Lot_Serial_Tbl_Type
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC

,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ Header_Val_Rec_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Val_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Val_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Val_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Val_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Val_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Val_Tbl_Type
)
IS
x_Header_Payment_val_tbl        	Header_Payment_Val_Tbl_Type;
x_Line_Payment_val_tbl          	Line_Payment_Val_Tbl_Type;

BEGIN

-- Calling over loaded Id_To_Value
Id_To_Value
(   p_header_rec                        => p_header_rec
,   p_Header_Adj_tbl                    => p_Header_Adj_tbl
,   p_Header_Scredit_tbl                => p_Header_Scredit_tbl
,   p_Header_Payment_tbl                => G_MISS_HEADER_PAYMENT_TBL
,   p_line_tbl                          => p_line_tbl
,   p_Line_Adj_tbl                      => p_Line_Adj_tbl
,   p_Line_Scredit_tbl                  => p_Line_Scredit_tbl
,   p_Line_Payment_tbl                  => G_MISS_LINE_PAYMENT_TBL
,   p_Lot_Serial_tbl                    => p_Lot_Serial_tbl
,   p_org_id                            => p_org_id --MOAC
,   p_operating_unit                    => p_operating_unit
,   x_header_val_rec                    => x_header_val_rec
,   x_Header_Adj_val_tbl                => x_Header_Adj_val_tbl
,   x_Header_Scredit_val_tbl            => x_Header_Scredit_val_tbl
,   x_Header_Payment_val_tbl            => x_Header_Payment_val_tbl
,   x_line_val_tbl                      => x_line_val_tbl
,   x_Line_Adj_val_tbl                  => x_Line_Adj_val_tbl
,   x_Line_Scredit_val_tbl              => x_Line_Scredit_val_tbl
,   x_Line_Payment_val_tbl              => x_Line_Payment_val_tbl
,   x_Lot_Serial_val_tbl                => x_Lot_Serial_val_tbl
);


EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Id_To_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Id_To_Value;

--  Procedure Value_To_Id

PROCEDURE Value_To_Id (
    p_header_rec                    IN  Header_Rec_Type
,   p_header_val_rec                IN  Header_Val_Rec_Type
,   p_Header_Adj_tbl                IN  Header_Adj_Tbl_Type
,   p_Header_Adj_val_tbl            IN  Header_Adj_Val_Tbl_Type
,   p_Header_Scredit_tbl            IN  Header_Scredit_Tbl_Type
,   p_Header_Scredit_val_tbl        IN  Header_Scredit_Val_Tbl_Type
,   p_line_tbl                      IN  Line_Tbl_Type
,   p_line_val_tbl                  IN  Line_Val_Tbl_Type
,   p_Line_Adj_tbl                  IN  Line_Adj_Tbl_Type
,   p_Line_Adj_val_tbl              IN  Line_Adj_Val_Tbl_Type
,   p_Line_Scredit_tbl              IN  Line_Scredit_Tbl_Type
,   p_Line_Scredit_val_tbl          IN  Line_Scredit_Val_Tbl_Type
,   p_Lot_Serial_tbl                IN  Lot_Serial_Tbl_Type
,   p_Lot_Serial_val_tbl            IN  Lot_Serial_Val_Tbl_Type
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC

,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ Header_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ Header_Adj_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ Line_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Adj_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Tbl_Type
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
x_Header_Payment_tbl        	Header_Payment_Tbl_Type;
x_Line_Payment_tbl          	Line_Payment_Tbl_Type;

BEGIN

    --  Init x_return_status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Calling over loaded Value_To_Id
Value_To_Id
 (  p_header_rec                  => p_header_rec
,   p_header_val_rec              => p_header_val_rec
,   p_Header_Adj_tbl              => p_Header_Adj_tbl
,   p_Header_Adj_val_tbl          => p_Header_Adj_val_tbl
,   p_Header_Scredit_tbl          => p_Header_Scredit_tbl
,   p_Header_Scredit_val_tbl      => p_Header_Scredit_val_tbl
,   p_Header_Payment_tbl          => G_MISS_HEADER_PAYMENT_TBL
,   p_Header_Payment_val_tbl      => G_MISS_HEADER_PAYMENT_VAL_TBL
,   p_line_tbl                    => p_line_tbl
,   p_line_val_tbl                => p_line_val_tbl
,   p_Line_Adj_tbl                => p_Line_Adj_tbl
,   p_Line_Adj_val_tbl            => p_Line_Adj_val_tbl
,   p_Line_Scredit_tbl            => p_Line_Scredit_tbl
,   p_Line_Scredit_val_tbl        => p_Line_Scredit_val_tbl
,   p_Line_Payment_tbl            => G_MISS_LINE_PAYMENT_TBL
,   p_Line_Payment_val_tbl        => G_MISS_LINE_PAYMENT_VAL_TBL
,   p_Lot_Serial_tbl              => p_Lot_Serial_tbl
,   p_Lot_Serial_val_tbl          => p_Lot_Serial_val_tbl
,   p_org_id                            => p_org_id --MOAC
,   p_operating_unit                    => p_operating_unit
,   x_header_rec                  => x_header_rec
,   x_Header_Adj_tbl              => x_Header_Adj_tbl
,   x_Header_Scredit_tbl          => x_Header_Scredit_tbl
,   x_Header_Payment_tbl          => x_Header_Payment_tbl
,   x_line_tbl                    => x_line_tbl
,   x_Line_Adj_tbl                => x_Line_Adj_tbl
,   x_Line_Scredit_tbl            => x_Line_Scredit_tbl
,   x_Line_Payment_tbl            => x_Line_Payment_tbl
,   x_Lot_Serial_tbl              => x_Lot_Serial_tbl
,   x_return_status               => x_return_status
);


EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Value_To_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Value_To_Id;


PROCEDURE Process_Line(
    p_line_tbl                      IN  Line_Tbl_Type :=
                                        G_MISS_LINE_TBL
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC

,   x_line_out_tbl                      OUT NOCOPY /* file.sql.39 change */ Line_Tbl_Type
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
) IS
l_line_tbl                      OE_ORDER_PUB.Line_Tbl_Type;
l_control_rec                   OE_GLOBALS.control_rec_type;
l_api_name                      CONSTANT VARCHAR2(30) := 'Update Line';
l_header_out_rec                OE_ORDER_PUB.Header_Rec_Type;
l_line_adj_out_tbl              oe_order_pub.line_Adj_Tbl_Type;
l_header_adj_out_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_Header_Scredit_out_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_Line_Scredit_out_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_Header_Payment_out_tbl        OE_Order_PUB.Header_Payment_Tbl_Type;
l_Line_Payment_out_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
l_action_request_out_tbl        OE_Order_PUB.request_tbl_type;
l_Lot_Serial_tbl                OE_Order_PUB.Lot_Serial_Tbl_Type;
l_Header_price_Att_tbl		OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_Header_Adj_Att_tbl		OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_Header_Adj_Assoc_tbl		OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_Line_price_Att_tbl		OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_Line_Adj_Att_tbl		OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_Line_Adj_Assoc_tbl		OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
l_return_status                 VARCHAR2(30);
l_org_id number;

BEGIN

    -- Logic added for MOAC


    -- FIND Org_Id logic :
    -- We first look at p_org_id to set Context.
    -- If p_org_id passed in, we ignore p_operating_unit.
    -- If p_org_id not passed in, then we look at p_operating_unit to get org_id.
    -- If both are not passed in, we get the context from MO Get_Default_Org API.
    --
    IF (p_org_id IS NOT NULL AND p_org_id <> FND_API.G_MISS_NUM) THEN
       l_org_id :=  p_org_id;

       -- ignore p_operating_unit since p_org_id has passed in.
       -- We check if both p_org_id and p_operating_unit pass in,
       -- add a message just for the information.
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR)  THEN
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN
                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','operating_unit');
                OE_MSG_PUB.Add;
            END IF;
       END IF;

    ELSE
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR) THEN
           -- call value_to_id to get org_id
           l_org_id := OE_Value_To_Id.OPERATING_UNIT(p_operating_unit);
       -- comment out due to new call to MO_GLOBAL.validate_orgid_pub_api
       /*
        ELSE
           -- Both p_org_id and p_operating_unit are not passed in.
           l_org_id := MO_UTILS.get_default_org_id ;
        */
        END IF;
     END IF;

    -- Validate Org_Id
    -- call new API : MO_GLOBAL.validate_orgid_pub_api
    -- Instead of calling old function - MO_GLOBAL.check_valid_org
    -- MO_GLOBAL.validate_orgid_pub_api provides backward compatibility
    -- without adding code to call MO_GLOBAL.init
    --Calling MO_GLOBAL.validate_orgid_pub_api has been shifted to set_context as it has to be called by all procedures
   /* MO_GLOBAL.validate_orgid_pub_api
    (   ORG_ID  =>  l_org_id
     ,  Status  =>  l_return_status
    ) ;*/
   /* IF(l_return_status ='F') THEN
       -- return Failure
       raise FND_API.G_EXC_ERROR;
    END IF;*/

    -- Set Application Context
    -- Since we pass validation, we start to Set Application Context
    -- Call MO set_policy_context to set application context by sending
    -- p_access_mode ='S' (Single Operating Unit Access) and org_id
    -- Then call OE_GLOBALS.Set_Context to set OE_GLOBALS.G_ORG_ID
    --
   -- MO_GLOBAL.set_policy_context('S',l_org_id);
   -- OE_GLOBALS.Set_Context();
   --Moved the logic to set context to new procedure set_context
     set_context(p_org_id =>l_org_id);
    --  From now on, we are in single access mode.



 x_line_out_tbl := p_line_tbl;

 OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_line_tbl                  => x_line_out_tbl
    ,   p_x_header_rec                  => l_header_out_rec
    ,   p_x_Header_Adj_tbl              => l_Header_Adj_out_tbl
    ,   p_x_Header_Scredit_tbl          => l_Header_Scredit_out_tbl
    ,   p_x_Header_Payment_tbl          => l_Header_Payment_out_tbl
    ,   p_x_Line_Adj_tbl                => l_Line_Adj_out_tbl
    ,   p_x_Line_Scredit_tbl            => l_Line_Scredit_out_tbl
    ,   p_x_Line_Payment_tbl            => l_Line_Payment_out_tbl
    ,   p_x_Action_Request_tbl          => l_Action_Request_out_Tbl
    ,   p_x_lot_serial_tbl              => l_lot_serial_tbl
    ,   p_x_Header_price_Att_tbl		=> l_Header_price_Att_tbl
    ,   p_x_Header_Adj_Att_tbl			=> l_Header_Adj_Att_tbl
    ,   p_x_Header_Adj_Assoc_tbl		=> l_Header_Adj_Assoc_tbl
    ,   p_x_Line_price_Att_tbl			=> l_Line_price_Att_tbl
    ,   p_x_Line_Adj_Att_tbl			=> l_Line_Adj_Att_tbl
    ,   p_x_Line_Adj_Assoc_tbl		=> l_Line_Adj_Assoc_tbl
    );

    x_return_status := l_return_status;
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data


        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Gen_Gapless_Sequence'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Line;

PROCEDURE Process_header
(
    p_header_rec                      IN  Header_Rec_Type :=
                                        G_MISS_HEADER_REC
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC

,   x_header_out_rec                      OUT NOCOPY /* file.sql.39 change */ Header_Rec_Type
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS
l_control_rec                   OE_GLOBALS.Control_Rec_Type;
l_api_name                      CONSTANT VARCHAR2(30) := 'Process_header';
l_line_out_tbl                  OE_ORDER_PUB.Line_Tbl_Type;
l_line_adj_out_tbl              oe_order_pub.line_Adj_Tbl_Type;
l_header_adj_out_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_Header_Scredit_out_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_Line_Scredit_out_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_Header_Payment_out_tbl        OE_Order_PUB.Header_Payment_Tbl_Type;
l_Line_Payment_out_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
l_action_request_out_tbl        OE_Order_PUB.request_tbl_type;
l_Lot_Serial_tbl                OE_Order_PUB.Lot_Serial_Tbl_Type;
l_Header_price_Att_tbl		OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_Header_Adj_Att_tbl		OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_Header_Adj_Assoc_tbl		OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_Line_price_Att_tbl		OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_Line_Adj_Att_tbl		OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_Line_Adj_Assoc_tbl		OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
l_return_status                 VARCHAR2(30);
l_org_id number;

Begin

    -- Logic added for MOAC


    -- FIND Org_Id logic :
    -- We first look at p_org_id to set Context.
    -- If p_org_id passed in, we ignore p_operating_unit.
    -- If p_org_id not passed in, then we look at p_operating_unit to get org_id.
    -- If both are not passed in, we get the context from MO Get_Default_Org API.
    --
    IF (p_org_id IS NOT NULL AND p_org_id <> FND_API.G_MISS_NUM) THEN
       l_org_id :=  p_org_id;

       -- ignore p_operating_unit since p_org_id has passed in.
       -- We check if both p_org_id and p_operating_unit pass in,
       -- add a message just for the information.
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR)  THEN
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN
                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','operating_unit');
                OE_MSG_PUB.Add;
            END IF;
       END IF;

    ELSE
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR) THEN
           -- call value_to_id to get org_id
           l_org_id := OE_Value_To_Id.OPERATING_UNIT(p_operating_unit);
       -- comment out due to new call to MO_GLOBAL.validate_orgid_pub_api
       /*
        ELSE
           -- Both p_org_id and p_operating_unit are not passed in.
           l_org_id := MO_UTILS.get_default_org_id ;
        */
        END IF;
     END IF;

    -- Validate Org_Id
    -- call new API : MO_GLOBAL.validate_orgid_pub_api
    -- Instead of calling old function - MO_GLOBAL.check_valid_org
    -- MO_GLOBAL.validate_orgid_pub_api provides backward compatibility
    -- without adding code to call MO_GLOBAL.init

   /* MO_GLOBAL.validate_orgid_pub_api
    (   ORG_ID  =>  l_org_id
     ,  Status  =>  l_return_status
    ) ;*/
   /* IF(l_return_status ='F') THEN
       -- return Failure
       raise FND_API.G_EXC_ERROR;
    END IF;*/

    -- Set Application Context
    -- Since we pass validation, we start to Set Application Context
    -- Call MO set_policy_context to set application context by sending
    -- p_access_mode ='S' (Single Operating Unit Access) and org_id
    -- Then call OE_GLOBALS.Set_Context to set OE_GLOBALS.G_ORG_ID
    --
    --MO_GLOBAL.set_policy_context('S',l_org_id);
    --OE_GLOBALS.Set_Context();
    --Moved the logic to set context to new procedure set_context
     set_context(p_org_id =>l_org_id);

    --  From now on, we are in single access mode.



 x_header_out_rec := p_header_rec;

   OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level => FND_API.G_VALID_LEVEL_FULL
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                  => x_header_out_rec
    ,   p_x_Header_Adj_tbl              => l_Header_Adj_out_tbl
    ,   p_x_Header_Scredit_tbl          => l_Header_Scredit_out_tbl
    ,   p_x_Header_Payment_tbl          => l_Header_Payment_out_tbl
    ,   p_x_line_tbl                    => l_line_out_tbl
    ,   p_x_Line_Adj_tbl                => l_Line_Adj_out_tbl
    ,   p_x_Line_Scredit_tbl            => l_Line_Scredit_out_tbl
    ,   p_x_Line_Payment_tbl            => l_Line_Payment_out_tbl
    ,   p_x_Action_Request_tbl          => l_Action_Request_out_Tbl
    ,   p_x_lot_serial_tbl              => l_lot_serial_tbl
    ,   p_x_Header_price_Att_tbl		=> l_Header_price_Att_tbl
    ,   p_x_Header_Adj_Att_tbl			=> l_Header_Adj_Att_tbl
    ,   p_x_Header_Adj_Assoc_tbl		=> l_Header_Adj_Assoc_tbl
    ,   p_x_Line_price_Att_tbl			=> l_Line_price_Att_tbl
    ,   p_x_Line_Adj_Att_tbl			=> l_Line_Adj_Att_tbl
    ,   p_x_Line_Adj_Assoc_tbl		=> l_Line_Adj_Assoc_tbl
    );

    x_return_status := l_return_status;
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data


        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Gen_Gapless_Sequence'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Header;


PROCEDURE Delete_Order
(
    p_header_id                      NUMBER
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC

,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS
l_header_rec                OE_ORDER_PUB.Header_Rec_Type;
l_old_header_rec            OE_ORDER_PUB.Header_Rec_Type;
l_control_rec               OE_GLOBALS.Control_Rec_Type;
l_api_name         CONSTANT VARCHAR2(30) := 'Delete Order';
l_header_out_rec            OE_ORDER_PUB.Header_Rec_Type;
l_line_out_tbl              OE_ORDER_PUB.Line_Tbl_Type;
l_line_adj_out_tbl          oe_order_pub.line_Adj_Tbl_Type;
l_header_adj_out_tbl        OE_Order_PUB.Header_Adj_Tbl_Type;
l_Header_Scredit_out_tbl    OE_Order_PUB.Header_Scredit_Tbl_Type;
l_Line_Scredit_out_tbl      OE_Order_PUB.Line_Scredit_Tbl_Type;
l_Header_Payment_out_tbl    OE_Order_PUB.Header_Payment_Tbl_Type;
l_Line_Payment_out_tbl      OE_Order_PUB.Line_Payment_Tbl_Type;
l_action_request_out_tbl    OE_Order_PUB.request_tbl_type;
l_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
l_Header_price_Att_tbl		OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_Header_Adj_Att_tbl		OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_Header_Adj_Assoc_tbl		OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_Line_price_Att_tbl		OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_Line_Adj_Att_tbl		OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_Line_Adj_Assoc_tbl		OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
l_return_status         VARCHAR2(30);
l_org_id number;

Begin
    -- Logic added for MOAC


    -- FIND Org_Id logic :
    -- We first look at p_org_id to set Context.
    -- If p_org_id passed in, we ignore p_operating_unit.
    -- If p_org_id not passed in, then we look at p_operating_unit to get org_id.
    -- If both are not passed in, we get the context from MO Get_Default_Org API.
    --
    IF (p_org_id IS NOT NULL AND p_org_id <> FND_API.G_MISS_NUM) THEN
       l_org_id :=  p_org_id;

       -- ignore p_operating_unit since p_org_id has passed in.
       -- We check if both p_org_id and p_operating_unit pass in,
       -- add a message just for the information.
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR)  THEN
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN
                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','operating_unit');
                OE_MSG_PUB.Add;
            END IF;
       END IF;

    ELSE
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR) THEN
           -- call value_to_id to get org_id
           l_org_id := OE_Value_To_Id.OPERATING_UNIT(p_operating_unit);
       -- comment out due to new call to MO_GLOBAL.validate_orgid_pub_api
       /*
        ELSE
           -- Both p_org_id and p_operating_unit are not passed in.
           l_org_id := MO_UTILS.get_default_org_id ;
        */
        END IF;
     END IF;

    -- Validate Org_Id
    -- call new API : MO_GLOBAL.validate_orgid_pub_api
    -- Instead of calling old function - MO_GLOBAL.check_valid_org
    -- MO_GLOBAL.validate_orgid_pub_api provides backward compatibility
    -- without adding code to call MO_GLOBAL.init

    /*MO_GLOBAL.validate_orgid_pub_api
    (   ORG_ID  =>  l_org_id
     ,  Status  =>  l_return_status
    ) ;*/
    /*IF(l_return_status ='F') THEN
       -- return Failure
       raise FND_API.G_EXC_ERROR;
    END IF;*/

    -- Set Application Context
    -- Since we pass validation, we start to Set Application Context
    -- Call MO set_policy_context to set application context by sending
    -- p_access_mode ='S' (Single Operating Unit Access) and org_id
    -- Then call OE_GLOBALS.Set_Context to set OE_GLOBALS.G_ORG_ID
    --
    --MO_GLOBAL.set_policy_context('S',l_org_id);
    --OE_GLOBALS.Set_Context();
    --Moved the logic to set context to new procedure set_context
     set_context(p_org_id =>l_org_id);

    --  From now on, we are in single access mode.




    l_header_rec              := OE_Order_PUB.G_MISS_HEADER_REC;
    l_header_rec.header_id    := p_header_id;
    --  Set Operation.  Bug #1198949
    l_header_rec.operation := OE_GLOBALS.G_OPR_DELETE;



    OE_ORDER_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                => l_header_rec
    ,   p_x_Header_Adj_tbl              => l_Header_Adj_out_tbl
    ,   p_x_Header_Scredit_tbl          => l_Header_Scredit_out_tbl
    ,   p_x_Header_Payment_tbl          => l_Header_Payment_out_tbl
    ,   p_x_line_tbl                    => l_line_out_tbl
    ,   p_x_Line_Adj_tbl                => l_Line_Adj_out_tbl
    ,   p_x_Line_Scredit_tbl            => l_Line_Scredit_out_tbl
    ,   p_x_Line_Payment_tbl            => l_Line_Payment_out_tbl
    ,   p_x_Action_Request_tbl          => l_Action_Request_out_Tbl
    ,   p_x_lot_serial_tbl              => l_lot_serial_tbl
    ,   p_x_Header_price_Att_tbl		=> l_Header_price_Att_tbl
    ,   p_x_Header_Adj_Att_tbl			=> l_Header_Adj_Att_tbl
    ,   p_x_Header_Adj_Assoc_tbl		=> l_Header_Adj_Assoc_tbl
    ,   p_x_Line_price_Att_tbl			=> l_Line_price_Att_tbl
    ,   p_x_Line_Adj_Att_tbl			=> l_Line_Adj_Att_tbl
    ,   p_x_Line_Adj_Assoc_tbl		=> l_Line_Adj_Assoc_tbl
   );
    x_return_status := l_return_status;
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data


        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Order'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

NULL;
END Delete_Order;



PROCEDURE Delete_Line
(
    p_line_id                       NUMBER
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC

,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS
l_line_tbl                  OE_ORDER_PUB.Line_tbl_Type;
l_control_rec               OE_GLOBALS.control_rec_type;
l_api_name         CONSTANT VARCHAR2(30) := 'Update Line';
l_header_out_rec            OE_ORDER_PUB.Header_Rec_Type;
l_line_out_tbl              OE_ORDER_PUB.Line_Tbl_Type;
l_line_adj_out_tbl          oe_order_pub.line_Adj_Tbl_Type;
l_header_adj_out_tbl        OE_Order_PUB.Header_Adj_Tbl_Type;
l_Header_Scredit_out_tbl    OE_Order_PUB.Header_Scredit_Tbl_Type;
l_Line_Scredit_out_tbl      OE_Order_PUB.Line_Scredit_Tbl_Type;
l_Header_Payment_out_tbl    OE_Order_PUB.Header_Payment_Tbl_Type;
l_Line_Payment_out_tbl      OE_Order_PUB.Line_Payment_Tbl_Type;
l_action_request_out_tbl    OE_Order_PUB.request_tbl_type;
l_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
l_Header_price_Att_tbl		OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_Header_Adj_Att_tbl		OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_Header_Adj_Assoc_tbl		OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_Line_price_Att_tbl		OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_Line_Adj_Att_tbl			OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_Line_Adj_Assoc_tbl		OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
l_return_status         VARCHAR2(30);
l_org_id number;

Begin
    -- Logic added for MOAC


    -- FIND Org_Id logic :
    -- We first look at p_org_id to set Context.
    -- If p_org_id passed in, we ignore p_operating_unit.
    -- If p_org_id not passed in, then we look at p_operating_unit to get org_id.
    -- If both are not passed in, we get the context from MO Get_Default_Org API.
    --
    IF (p_org_id IS NOT NULL AND p_org_id <> FND_API.G_MISS_NUM) THEN
       l_org_id :=  p_org_id;

       -- ignore p_operating_unit since p_org_id has passed in.
       -- We check if both p_org_id and p_operating_unit pass in,
       -- add a message just for the information.
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR)  THEN
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN
                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','operating_unit');
                OE_MSG_PUB.Add;
            END IF;
       END IF;

    ELSE
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR) THEN
           -- call value_to_id to get org_id
           l_org_id := OE_Value_To_Id.OPERATING_UNIT(p_operating_unit);
       -- comment out due to new call to MO_GLOBAL.validate_orgid_pub_api
       /*
        ELSE
           -- Both p_org_id and p_operating_unit are not passed in.
           l_org_id := MO_UTILS.get_default_org_id ;
        */
        END IF;
     END IF;

    -- Validate Org_Id
    -- call new API : MO_GLOBAL.validate_orgid_pub_api
    -- Instead of calling old function - MO_GLOBAL.check_valid_org
    -- MO_GLOBAL.validate_orgid_pub_api provides backward compatibility
    -- without adding code to call MO_GLOBAL.init

   /* MO_GLOBAL.validate_orgid_pub_api
    (   ORG_ID  =>  l_org_id
     ,  Status  =>  l_return_status
    ) ;*/
   /* IF(l_return_status ='F') THEN
       -- return Failure
       raise FND_API.G_EXC_ERROR;
    END IF;*/

    -- Set Application Context
    -- Since we pass validation, we start to Set Application Context
    -- Call MO set_policy_context to set application context by sending
    -- p_access_mode ='S' (Single Operating Unit Access) and org_id
    -- Then call OE_GLOBALS.Set_Context to set OE_GLOBALS.G_ORG_ID
    --
    --MO_GLOBAL.set_policy_context('S',l_org_id);
    --OE_GLOBALS.Set_Context();
    --Moved the logic to set context to new procedure set_context
     set_context(p_org_id =>l_org_id);


    --  From now on, we are in single access mode.




    l_line_tbl(1)		 := OE_Order_PUB.G_MISS_LINE_REC;
    l_line_tbl(1).line_id := p_line_id;

    --  Set Operation.

    l_line_tbl(1).operation := OE_GLOBALS.G_OPR_DELETE;

    OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_line_tbl                    => l_line_tbl
    ,   p_x_header_rec                  => l_header_out_rec
    ,   p_x_Header_Adj_tbl              => l_Header_Adj_out_tbl
    ,   p_x_Header_Scredit_tbl          => l_Header_Scredit_out_tbl
    ,   p_x_Header_Payment_tbl          => l_Header_Payment_out_tbl
    ,   p_x_Line_Adj_tbl                => l_Line_Adj_out_tbl
    ,   p_x_Line_Scredit_tbl            => l_Line_Scredit_out_tbl
    ,   p_x_Line_Payment_tbl            => l_Line_Payment_out_tbl
    ,   p_x_Action_Request_tbl          => l_Action_Request_out_Tbl
    ,   p_x_lot_serial_tbl              => l_lot_serial_tbl
    ,   p_x_Header_price_Att_tbl		=> l_Header_price_Att_tbl
    ,   p_x_Header_Adj_Att_tbl			=> l_Header_Adj_Att_tbl
    ,   p_x_Header_Adj_Assoc_tbl		=> l_Header_Adj_Assoc_tbl
    ,   p_x_Line_price_Att_tbl			=> l_Line_price_Att_tbl
    ,   p_x_Line_Adj_Att_tbl			=> l_Line_Adj_Att_tbl
    ,   p_x_Line_Adj_Assoc_tbl		=> l_Line_Adj_Assoc_tbl
    );

	x_return_status := l_return_status;
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data


        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Gen_Gapless_Sequence'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


END Delete_Line;


PROCEDURE update_header
(
    p_header_id                    IN  NUMBER
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC
,   p_header_val_rec               IN  Header_val_Rec_Type :=
                                        G_MISS_HEADER_VAL_REC

,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS
l_header_rec                OE_ORDER_PUB.Header_Rec_Type;
l_old_header_rec            OE_ORDER_PUB.Header_Rec_Type;
l_control_rec               OE_GLOBALS.Control_Rec_Type;
l_api_name         CONSTANT VARCHAR2(30) := 'Process_header';
l_header_out_rec            OE_ORDER_PUB.Header_Rec_Type;
l_line_out_tbl              OE_ORDER_PUB.Line_Tbl_Type;
l_line_adj_out_tbl          oe_order_pub.line_Adj_Tbl_Type;
l_header_adj_out_tbl        OE_Order_PUB.Header_Adj_Tbl_Type;
l_Header_Scredit_out_tbl    OE_Order_PUB.Header_Scredit_Tbl_Type;
l_Line_Scredit_out_tbl      OE_Order_PUB.Line_Scredit_Tbl_Type;
l_Header_Payment_out_tbl    OE_Order_PUB.Header_Payment_Tbl_Type;
l_Line_Payment_out_tbl      OE_Order_PUB.Line_Payment_Tbl_Type;
l_action_request_out_tbl    OE_Order_PUB.request_tbl_type;
l_Lot_Serial_tbl        OE_Order_PUB.Lot_Serial_Tbl_Type;
l_Header_price_Att_tbl		OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_Header_Adj_Att_tbl		OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_Header_Adj_Assoc_tbl		OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_Line_price_Att_tbl		OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_Line_Adj_Att_tbl			OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_Line_Adj_Assoc_tbl		OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
l_return_status         VARCHAR2(30);
l_org_id number;

BEGIN
    -- Logic added for MOAC


    -- FIND Org_Id logic :
    -- We first look at p_org_id to set Context.
    -- If p_org_id passed in, we ignore p_operating_unit.
    -- If p_org_id not passed in, then we look at p_operating_unit to get org_id.
    -- If both are not passed in, we get the context from MO Get_Default_Org API.
    --
    IF (p_org_id IS NOT NULL AND p_org_id <> FND_API.G_MISS_NUM) THEN
       l_org_id :=  p_org_id;

       -- ignore p_operating_unit since p_org_id has passed in.
       -- We check if both p_org_id and p_operating_unit pass in,
       -- add a message just for the information.
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR)  THEN
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN
                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','operating_unit');
                OE_MSG_PUB.Add;
            END IF;
       END IF;

    ELSE
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR) THEN
           -- call value_to_id to get org_id
           l_org_id := OE_Value_To_Id.OPERATING_UNIT(p_operating_unit);
       -- comment out due to new call to MO_GLOBAL.validate_orgid_pub_api
       /*
        ELSE
           -- Both p_org_id and p_operating_unit are not passed in.
           l_org_id := MO_UTILS.get_default_org_id ;
        */
        END IF;
     END IF;

    -- Validate Org_Id
    -- call new API : MO_GLOBAL.validate_orgid_pub_api
    -- Instead of calling old function - MO_GLOBAL.check_valid_org
    -- MO_GLOBAL.validate_orgid_pub_api provides backward compatibility
    -- without adding code to call MO_GLOBAL.init

    /*MO_GLOBAL.validate_orgid_pub_api
    (   ORG_ID  =>  l_org_id
     ,  Status  =>  l_return_status
    ) ;*/
    /*IF(l_return_status ='F') THEN
       -- return Failure
       raise FND_API.G_EXC_ERROR;
    END IF;*/

    -- Set Application Context
    -- Since we pass validation, we start to Set Application Context
    -- Call MO set_policy_context to set application context by sending
    -- p_access_mode ='S' (Single Operating Unit Access) and org_id
    -- Then call OE_GLOBALS.Set_Context to set OE_GLOBALS.G_ORG_ID
    --
    --MO_GLOBAL.set_policy_context('S',l_org_id);
    --OE_GLOBALS.Set_Context();
    --Moved the logic to set context to new procedure set_context
     set_context(p_org_id =>l_org_id);

    --  From now on, we are in single access mode.




    l_header_rec		:= OE_Order_PUB.G_MISS_HEADER_REC;
    l_header_rec.header_id := p_header_id;
    l_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;     -- Bug 8340976




    OE_Header_Util.Get_Ids
	( p_x_header_rec	=> l_header_rec
         ,p_header_val_rec	=> p_header_val_rec
	);

    l_return_status := l_header_rec.return_status;
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


   -- Bug 8340976 l_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;

   OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                  => l_header_rec
    ,   p_x_Header_Adj_tbl              => l_Header_Adj_out_tbl
    ,   p_x_Header_Scredit_tbl          => l_Header_Scredit_out_tbl
    ,   p_x_Header_Payment_tbl          => l_Header_Payment_out_tbl
    ,   p_x_line_tbl                    => l_line_out_tbl
    ,   p_x_Line_Adj_tbl                => l_Line_Adj_out_tbl
    ,   p_x_Line_Scredit_tbl            => l_Line_Scredit_out_tbl
    ,   p_x_Line_Payment_tbl            => l_Line_Payment_out_tbl
    ,   p_x_Action_Request_tbl          => l_Action_Request_out_Tbl
    ,   p_x_lot_serial_tbl              => l_lot_serial_tbl
    ,   p_x_Header_price_Att_tbl		=> l_Header_price_Att_tbl
    ,   p_x_Header_Adj_Att_tbl			=> l_Header_Adj_Att_tbl
    ,   p_x_Header_Adj_Assoc_tbl		=> l_Header_Adj_Assoc_tbl
    ,   p_x_Line_price_Att_tbl			=> l_Line_price_Att_tbl
    ,   p_x_Line_Adj_Att_tbl			=> l_Line_Adj_Att_tbl
    ,   p_x_Line_Adj_Assoc_tbl		=> l_Line_Adj_Assoc_tbl
    );
    x_return_status := l_return_status;
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data


        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update Header'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END update_header;

PROCEDURE Update_Line
(
    p_line_id                      IN  NUMBER
,   p_line_val_rec                 IN  Line_Val_rec_Type :=
                                        G_MISS_LINE_VAL_REC
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC

,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS
l_line_rec                 OE_ORDER_PUB.Line_rec_Type;
l_line_tbl                 OE_ORDER_PUB.Line_tbl_Type;
l_control_rec               OE_GLOBALS.control_rec_type;
l_api_name         CONSTANT VARCHAR2(30) := 'Update Line';
l_header_out_rec            OE_ORDER_PUB.Header_Rec_Type;
l_line_out_tbl              OE_ORDER_PUB.Line_Tbl_Type;
l_line_adj_out_tbl          oe_order_pub.line_Adj_Tbl_Type;
l_header_adj_out_tbl        OE_Order_PUB.Header_Adj_Tbl_Type;
l_Header_Scredit_out_tbl    OE_Order_PUB.Header_Scredit_Tbl_Type;
l_Line_Scredit_out_tbl      OE_Order_PUB.Line_Scredit_Tbl_Type;
l_Header_Payment_out_tbl    OE_Order_PUB.Header_Payment_Tbl_Type;
l_Line_Payment_out_tbl      OE_Order_PUB.Line_Payment_Tbl_Type;
l_action_request_out_tbl    OE_Order_PUB.request_tbl_type;
l_Lot_Serial_tbl        OE_Order_PUB.Lot_Serial_Tbl_Type;
l_Header_price_Att_tbl		OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_Header_Adj_Att_tbl		OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_Header_Adj_Assoc_tbl		OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_Line_price_Att_tbl		OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_Line_Adj_Att_tbl			OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_Line_Adj_Assoc_tbl		OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
l_return_status         VARCHAR2(30);
l_org_id number;

Begin
    -- Logic added for MOAC


    -- FIND Org_Id logic :
    -- We first look at p_org_id to set Context.
    -- If p_org_id passed in, we ignore p_operating_unit.
    -- If p_org_id not passed in, then we look at p_operating_unit to get org_id.
    -- If both are not passed in, we get the context from MO Get_Default_Org API.
    --
    IF (p_org_id IS NOT NULL AND p_org_id <> FND_API.G_MISS_NUM) THEN
       l_org_id :=  p_org_id;

       -- ignore p_operating_unit since p_org_id has passed in.
       -- We check if both p_org_id and p_operating_unit pass in,
       -- add a message just for the information.
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR)  THEN
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN
                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','operating_unit');
                OE_MSG_PUB.Add;
            END IF;
       END IF;

    ELSE
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR) THEN
           -- call value_to_id to get org_id
           l_org_id := OE_Value_To_Id.OPERATING_UNIT(p_operating_unit);
       -- comment out due to new call to MO_GLOBAL.validate_orgid_pub_api
       /*
        ELSE
           -- Both p_org_id and p_operating_unit are not passed in.
           l_org_id := MO_UTILS.get_default_org_id ;
        */
        END IF;
     END IF;

    -- Validate Org_Id
    -- call new API : MO_GLOBAL.validate_orgid_pub_api
    -- Instead of calling old function - MO_GLOBAL.check_valid_org
    -- MO_GLOBAL.validate_orgid_pub_api provides backward compatibility
    -- without adding code to call MO_GLOBAL.init

    /*MO_GLOBAL.validate_orgid_pub_api
    (   ORG_ID  =>  l_org_id
     ,  Status  =>  l_return_status
    ) ;*/
    /*IF(l_return_status ='F') THEN
       -- return Failure
       raise FND_API.G_EXC_ERROR;
    END IF;*/

    -- Set Application Context
    -- Since we pass validation, we start to Set Application Context
    -- Call MO set_policy_context to set application context by sending
    -- p_access_mode ='S' (Single Operating Unit Access) and org_id
    -- Then call OE_GLOBALS.Set_Context to set OE_GLOBALS.G_ORG_ID
    --
    --MO_GLOBAL.set_policy_context('S',l_org_id);
    --OE_GLOBALS.Set_Context();
    --Moved the logic to set context to new procedure set_context
     set_context(p_org_id =>l_org_id);

    --  From now on, we are in single access mode.




    l_line_rec	        := OE_Order_PUB.G_MISS_LINE_REC;
    l_line_rec.line_id := p_line_id;
    OE_Line_Util.Get_Ids
	(p_x_line_rec		=> l_line_rec
	 ,p_line_val_rec	=> p_Line_val_rec
	);
    l_return_status := l_line_rec.return_status;
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_line_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    l_line_tbl(1) := l_line_rec;


    OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_line_tbl                    => l_line_tbl
    ,   p_x_header_rec                  => l_header_out_rec
    ,   p_x_Header_Adj_tbl              => l_Header_Adj_out_tbl
    ,   p_x_Header_Scredit_tbl          => l_Header_Scredit_out_tbl
    ,   p_x_Header_Payment_tbl          => l_Header_Payment_out_tbl
    ,   p_x_Line_Adj_tbl                => l_Line_Adj_out_tbl
    ,   p_x_Line_Scredit_tbl            => l_Line_Scredit_out_tbl
    ,   p_x_Line_Payment_tbl            => l_Line_Payment_out_tbl
    ,   p_x_Action_Request_tbl          => l_Action_Request_out_Tbl
    ,   p_x_lot_serial_tbl              => l_lot_serial_tbl
    ,   p_x_Header_price_Att_tbl		=> l_Header_price_Att_tbl
    ,   p_x_Header_Adj_Att_tbl			=> l_Header_Adj_Att_tbl
    ,   p_x_Header_Adj_Assoc_tbl		=> l_Header_Adj_Assoc_tbl
    ,   p_x_Line_price_Att_tbl			=> l_Line_price_Att_tbl
    ,   p_x_Line_Adj_Att_tbl			=> l_Line_Adj_Att_tbl
    ,   p_x_Line_Adj_Assoc_tbl		=> l_Line_Adj_Assoc_tbl
    );

    x_return_status := l_return_status;
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data


        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Line'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
NULL;
END update_Line;

-- serla
-- All new Overloaded APIs for the Multiple Payments

PROCEDURE Process_Order
(   p_org_id                        IN  NUMBER := NULL --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC
,   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_action_commit                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  Header_Rec_Type :=
                                        G_MISS_HEADER_REC
,   p_old_header_rec                IN  Header_Rec_Type :=
                                        G_MISS_HEADER_REC
,   p_header_val_rec                IN  Header_Val_Rec_Type :=
                                        G_MISS_HEADER_VAL_REC
,   p_old_header_val_rec            IN  Header_Val_Rec_Type :=
                                        G_MISS_HEADER_VAL_REC
,   p_Header_Adj_tbl                IN  Header_Adj_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_TBL
,   p_old_Header_Adj_tbl            IN  Header_Adj_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_TBL
,   p_Header_Adj_val_tbl            IN  Header_Adj_Val_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_VAL_TBL
,   p_old_Header_Adj_val_tbl        IN  Header_Adj_Val_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_VAL_TBL
,   p_Header_price_Att_tbl          IN  Header_Price_Att_Tbl_Type :=
                                        G_MISS_HEADER_PRICE_ATT_TBL
,   p_old_Header_Price_Att_tbl      IN  Header_Price_Att_Tbl_Type :=
                                        G_MISS_HEADER_PRICE_ATT_TBL
,   p_Header_Adj_Att_tbl            IN  Header_Adj_Att_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_ATT_TBL
,   p_old_Header_Adj_Att_tbl        IN  Header_Adj_Att_Tbl_Type :=
    G_MISS_HEADER_ADJ_ATT_TBL
,   p_Header_Adj_Assoc_tbl            IN  Header_Adj_Assoc_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_old_Header_Adj_Assoc_tbl        IN  Header_Adj_Assoc_Tbl_Type :=
    G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_Header_Scredit_tbl            IN  Header_Scredit_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_TBL
,   p_old_Header_Scredit_tbl        IN  Header_Scredit_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_TBL
,   p_Header_Scredit_val_tbl        IN  Header_Scredit_Val_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_old_Header_Scredit_val_tbl    IN  Header_Scredit_Val_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_Header_Payment_tbl            IN  Header_Payment_Tbl_Type :=
                                        G_MISS_HEADER_PAYMENT_TBL
,   p_old_Header_Payment_tbl        IN  Header_Payment_Tbl_Type :=
                                        G_MISS_HEADER_PAYMENT_TBL
,   p_Header_Payment_val_tbl        IN  Header_Payment_Val_Tbl_Type :=
                                        G_MISS_HEADER_PAYMENT_VAL_TBL
,   p_old_Header_Payment_val_tbl    IN  Header_Payment_Val_Tbl_Type :=
                                        G_MISS_HEADER_PAYMENT_VAL_TBL
,   p_line_tbl                      IN  Line_Tbl_Type :=
                                        G_MISS_LINE_TBL
,   p_old_line_tbl                  IN  Line_Tbl_Type :=
                                        G_MISS_LINE_TBL
,   p_line_val_tbl                  IN  Line_Val_Tbl_Type :=
                                        G_MISS_LINE_VAL_TBL
,   p_old_line_val_tbl              IN  Line_Val_Tbl_Type :=
                                        G_MISS_LINE_VAL_TBL
,   p_Line_Adj_tbl                  IN  Line_Adj_Tbl_Type :=
                                        G_MISS_LINE_ADJ_TBL
,   p_old_Line_Adj_tbl              IN  Line_Adj_Tbl_Type :=
                                        G_MISS_LINE_ADJ_TBL
,   p_Line_Adj_val_tbl              IN  Line_Adj_Val_Tbl_Type :=
                                        G_MISS_LINE_ADJ_VAL_TBL
,   p_old_Line_Adj_val_tbl          IN  Line_Adj_Val_Tbl_Type :=
                                        G_MISS_LINE_ADJ_VAL_TBL
,   p_Line_price_Att_tbl            IN  Line_Price_Att_Tbl_Type :=
                                        G_MISS_LINE_PRICE_ATT_TBL
,   p_old_Line_Price_Att_tbl        IN  Line_Price_Att_Tbl_Type :=
                                        G_MISS_LINE_PRICE_ATT_TBL
,   p_Line_Adj_Att_tbl              IN  Line_Adj_Att_Tbl_Type :=
                                        G_MISS_LINE_ADJ_ATT_TBL
,   p_old_Line_Adj_Att_tbl          IN  Line_Adj_Att_Tbl_Type :=
    G_MISS_LINE_ADJ_ATT_TBL
,   p_Line_Adj_Assoc_tbl              IN  Line_Adj_Assoc_Tbl_Type :=
                                        G_MISS_LINE_ADJ_ASSOC_TBL
,   p_old_Line_Adj_Assoc_tbl          IN  Line_Adj_Assoc_Tbl_Type :=
    G_MISS_LINE_ADJ_ASSOC_TBL
,   p_Line_Scredit_tbl              IN  Line_Scredit_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_TBL
,   p_old_Line_Scredit_tbl          IN  Line_Scredit_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_TBL
,   p_Line_Scredit_val_tbl          IN  Line_Scredit_Val_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_VAL_TBL
,   p_old_Line_Scredit_val_tbl      IN  Line_Scredit_Val_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_VAL_TBL
,   p_Line_Payment_tbl              IN  Line_Payment_Tbl_Type :=
                                        G_MISS_LINE_PAYMENT_TBL
,   p_old_Line_Payment_tbl          IN  Line_Payment_Tbl_Type :=
                                        G_MISS_LINE_PAYMENT_TBL
,   p_Line_Payment_val_tbl          IN  Line_Payment_Val_Tbl_Type :=
                                        G_MISS_LINE_PAYMENT_VAL_TBL
,   p_old_Line_Payment_val_tbl      IN  Line_Payment_Val_Tbl_Type :=
                                        G_MISS_LINE_PAYMENT_VAL_TBL
,   p_Lot_Serial_tbl                IN  Lot_Serial_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_TBL
,   p_old_Lot_Serial_tbl            IN  Lot_Serial_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  Lot_Serial_Val_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_VAL_TBL
,   p_old_Lot_Serial_val_tbl        IN  Lot_Serial_Val_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_VAL_TBL
,   p_action_request_tbl	    IN  Request_Tbl_Type :=
					G_MISS_REQUEST_TBL
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl          OUT NOCOPY /* file.sql.39 change */ Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Val_Tbl_Type
,   x_Header_Payment_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Payment_Tbl_Type
,   x_Header_Payment_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Payment_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Val_Tbl_Type
,   x_Line_Payment_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Payment_Tbl_Type
,   x_Line_Payment_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Payment_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Val_Tbl_Type
,   x_action_request_tbl	    OUT NOCOPY /* file.sql.39 change */ Request_Tbl_Type
--For bug 3390458
,   p_rtrim_data                    IN  Varchar2 :='N'
,   p_validate_desc_flex            in varchar2 default 'Y'  --bug4343612
--ER7675548
,   p_header_customer_info_tbl      IN OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE :=
                                         OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_TBL
,   p_line_customer_info_tbl      IN OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE :=
                                       OE_ORDER_PUB.G_MISS_CUSTOMER_INFO_TBL
)
IS
--MOAC
l_org_id                      NUMBER;
l_operating_unit              VARCHAR2(240);

l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Order';
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_header_rec                  Header_Rec_Type;
l_Header_Adj_tbl              Header_Adj_Tbl_Type;
l_Header_price_Att_tbl        Header_Price_Att_Tbl_Type ;
l_Header_Adj_Att_tbl          Header_Adj_Att_Tbl_Type ;
l_Header_Adj_Assoc_tbl        Header_Adj_Assoc_Tbl_Type ;
l_Header_Scredit_tbl          Header_Scredit_Tbl_Type;
l_Header_Payment_tbl          Header_Payment_Tbl_Type;
l_line_tbl                    Line_Tbl_Type;
l_Line_Adj_tbl                Line_Adj_Tbl_Type;
l_Line_price_Att_tbl          Line_Price_Att_Tbl_Type ;
l_Line_Adj_Att_tbl            Line_Adj_Att_Tbl_Type ;
l_Line_Adj_Assoc_tbl          Line_Adj_Assoc_Tbl_Type ;
l_Line_Scredit_tbl            Line_Scredit_Tbl_Type;
l_Line_Payment_tbl            Line_Payment_Tbl_Type;
l_Lot_Serial_tbl              Lot_Serial_Tbl_Type;
l_old_header_rec              Header_Rec_Type;
l_old_Header_Adj_tbl          Header_Adj_Tbl_Type;
l_old_Header_price_Att_tbl    Header_Price_Att_Tbl_Type ;
l_old_Header_Adj_Att_tbl      Header_Adj_Att_Tbl_Type ;
l_old_Header_Adj_Assoc_tbl    Header_Adj_Assoc_Tbl_Type ;
l_old_Header_Scredit_tbl      Header_Scredit_Tbl_Type;
l_old_Header_Payment_tbl      Header_Payment_Tbl_Type;
l_old_line_tbl                Line_Tbl_Type;
l_old_Line_Adj_tbl            Line_Adj_Tbl_Type;
l_old_Line_price_Att_tbl      Line_Price_Att_Tbl_Type ;
l_old_Line_Adj_Att_tbl        Line_Adj_Att_Tbl_Type ;
l_old_Line_Adj_Assoc_tbl      Line_Adj_Assoc_Tbl_Type ;
l_old_Line_Scredit_tbl        Line_Scredit_Tbl_Type;
l_old_Line_Payment_tbl        Line_Payment_Tbl_Type;
l_old_Lot_Serial_tbl          Lot_Serial_Tbl_Type;

l_aac_header_rec              OE_Order_PUB.Header_Rec_Type;
l_aac_line_tbl                OE_Order_PUB.Line_Tbl_Type;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_cust_info_tbl OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE; --ER7675548
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Logic added for MOAC


    -- FIND Org_Id logic :
    -- We first look at p_org_id to set Context.
    -- If p_org_id passed in, we ignore p_operating_unit.
    -- If p_org_id not passed in, then we look at p_operating_unit to get org_id.
    -- If both are not passed in, we get the context from MO Get_Default_Org API.
    --
    IF (p_org_id IS NOT NULL AND p_org_id <> FND_API.G_MISS_NUM) THEN
       l_org_id :=  p_org_id;

       -- ignore p_operating_unit since p_org_id has passed in.
       -- We check if both p_org_id and p_operating_unit pass in,
       -- add a message just for the information.
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR)  THEN
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN
                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','operating_unit');
                OE_MSG_PUB.Add;
            END IF;
       END IF;

    ELSE
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR) THEN
           -- call value_to_id to get org_id
           l_org_id := OE_Value_To_Id.OPERATING_UNIT(p_operating_unit);
       -- comment out due to new call to MO_GLOBAL.validate_orgid_pub_api
       /*
        ELSE
           -- Both p_org_id and p_operating_unit are not passed in.
           l_org_id := MO_UTILS.get_default_org_id ;
        */
        END IF;
     END IF;

    -- Validate Org_Id
    -- call new API : MO_GLOBAL.validate_orgid_pub_api
    -- Instead of calling old function - MO_GLOBAL.check_valid_org
    -- MO_GLOBAL.validate_orgid_pub_api provides backward compatibility
    -- without adding code to call MO_GLOBAL.init

   /* MO_GLOBAL.validate_orgid_pub_api
    (   ORG_ID  =>  l_org_id
     ,  Status  =>  l_return_status
    ) ;*/
    /*IF(l_return_status ='F') THEN
       -- return Failure
       raise FND_API.G_EXC_ERROR;
    END IF;*/

    -- Set Application Context
    -- Since we pass validation, we start to Set Application Context
    -- Call MO set_policy_context to set application context by sending
    -- p_access_mode ='S' (Single Operating Unit Access) and org_id
    -- Then call OE_GLOBALS.Set_Context to set OE_GLOBALS.G_ORG_ID
    --
    --MO_GLOBAL.set_policy_context('S',l_org_id);
    --OE_GLOBALS.Set_Context();
     --Moved the logic to set context to new procedure set_context
     set_context(p_org_id =>l_org_id);


    --  From now on, we are in single access mode.



    x_action_request_tbl := p_action_request_tbl;
    l_Line_Price_Att_tbl := p_Line_Price_Att_tbl; --bug3160327
    l_old_Line_Price_Att_tbl :=p_old_Line_Price_Att_tbl; --bug3160327

    --Begin bug #5679661

    l_Header_price_Att_tbl        := p_Header_price_Att_tbl ;
    l_Header_Adj_Att_tbl          := p_Header_Adj_Att_tbl ;
    l_Header_Adj_Assoc_tbl        := p_Header_Adj_Assoc_tbl ;
    l_old_Header_price_Att_tbl    := p_old_Header_price_Att_tbl ;
    l_old_Header_Adj_Att_tbl      := p_old_Header_Adj_Att_tbl ;
    l_old_Header_Adj_Assoc_tbl    := p_old_Header_Adj_Assoc_tbl ;
    l_Line_price_Att_tbl          := p_Line_price_Att_tbl ;
    l_Line_Adj_Att_tbl            := p_Line_Adj_Att_tbl ;
    l_Line_Adj_Assoc_tbl          := p_Line_Adj_Assoc_tbl ;
    l_old_Line_price_Att_tbl      := p_old_Line_price_Att_tbl ;
    l_old_Line_Adj_Att_tbl        := p_old_Line_Adj_Att_tbl ;
    l_old_Line_Adj_Assoc_tbl      := p_old_Line_Adj_Assoc_tbl ;

    --End bug #5679661


    -- automatic account creation

    -- use local variables to replace p_ paramters after AAC
    -- so value_to_id can see it
    l_aac_header_rec   := p_header_rec;
    l_aac_line_tbl     := p_line_tbl;

    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'
    THEN

       oe_debug_pub.add('calling AAC from Pub Prcoess Order');
       OE_Order_GRP.automatic_account_creation(p_header_rec     => p_header_rec,
					       p_header_val_rec => p_header_val_rec,
					       p_line_tbl       => p_line_tbl,
					       p_line_val_tbl   => p_line_val_tbl,
					       x_header_rec     => l_aac_header_Rec,
					       x_line_tbl       => l_aac_line_tbl,
					       x_return_status  => x_return_status,
					       x_msg_count      => x_msg_count,
					       x_msg_data       => x_msg_data);

    END IF;


----ER7675548
savepoint ADD_CUSTOMER_INFO;

l_cust_info_tbl := p_header_customer_info_tbl;

OE_HEADER_UTIL.Get_customer_info_ids
(
 p_header_customer_info_tbl => l_cust_info_tbl,
 p_x_header_rec => l_aac_header_Rec,
 x_return_status => x_return_status,
 x_msg_count  => x_msg_count,
 x_msg_data   => x_msg_data
);

IF l_debug_level > 0 THEN
	oe_debug_pub.add('Call OE_HEADER_UTIL.Get_customer_info_ids :'||x_return_status);
END IF;

IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	ROLLBACK TO SAVEPOINT ADD_CUSTOMER_INFO;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
	ROLLBACK TO SAVEPOINT ADD_CUSTOMER_INFO;
        RAISE FND_API.G_EXC_ERROR;
END IF;


l_cust_info_tbl := p_line_customer_info_tbl;

OE_LINE_UTIL.Get_customer_info_ids
(
 p_line_customer_info_tbl => l_cust_info_tbl,
 p_x_line_tbl => l_aac_line_tbl,
 x_return_status => x_return_status,
 x_msg_count  => x_msg_count,
 x_msg_data   => x_msg_data
);

IF l_debug_level > 0 THEN
	oe_debug_pub.add('Call OE_LINE_UTIL.Get_customer_info_ids :'||x_return_status);
END IF;

IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	ROLLBACK TO SAVEPOINT ADD_CUSTOMER_INFO;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
	ROLLBACK TO SAVEPOINT ADD_CUSTOMER_INFO;
        RAISE FND_API.G_EXC_ERROR;
END IF;

--ER7675548

 --  Perform Value to Id conversion

    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_header_rec                  => l_aac_header_rec
    ,   p_header_val_rec              => p_header_val_rec
    ,   p_Header_Adj_tbl              => p_Header_Adj_tbl
    ,   p_Header_Adj_val_tbl          => p_Header_Adj_val_tbl
    ,   p_Header_Scredit_tbl          => p_Header_Scredit_tbl
    ,   p_Header_Scredit_val_tbl      => p_Header_Scredit_val_tbl
    ,   p_Header_Payment_tbl          => p_Header_Payment_tbl
    ,   p_Header_Payment_val_tbl      => p_Header_Payment_val_tbl
    ,   p_line_tbl                    => l_aac_line_tbl
    ,   p_line_val_tbl                => p_line_val_tbl
    ,   p_Line_Adj_tbl                => p_Line_Adj_tbl
    ,   p_Line_Adj_val_tbl            => p_Line_Adj_val_tbl
    ,   p_Line_Scredit_tbl            => p_Line_Scredit_tbl
    ,   p_Line_Scredit_val_tbl        => p_Line_Scredit_val_tbl
    ,   p_Line_Payment_tbl            => p_Line_Payment_tbl
    ,   p_Line_Payment_val_tbl        => p_Line_Payment_val_tbl
    ,   p_Lot_Serial_tbl              => p_Lot_Serial_tbl
    ,   p_Lot_Serial_val_tbl          => p_Lot_Serial_val_tbl
    ,   x_header_rec                  => l_header_rec
    ,   x_Header_Adj_tbl              => l_Header_Adj_tbl
    ,   x_Header_Scredit_tbl          => l_Header_Scredit_tbl
    ,   x_Header_Payment_tbl          => l_Header_Payment_tbl
    ,   x_line_tbl                    => l_line_tbl
    ,   x_Line_Adj_tbl                => l_Line_Adj_tbl
    ,   x_Line_Scredit_tbl            => l_Line_Scredit_tbl
    ,   x_Line_Payment_tbl            => l_Line_Payment_tbl
    ,   x_Lot_Serial_tbl              => l_Lot_Serial_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Perform Value to Id conversion (for old)

    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_header_rec                  => p_old_header_rec
    ,   p_header_val_rec              => p_old_header_val_rec
    ,   p_Header_Adj_tbl              => p_old_Header_Adj_tbl
    ,   p_Header_Adj_val_tbl          => p_old_Header_Adj_val_tbl
    ,   p_Header_Scredit_tbl          => p_old_Header_Scredit_tbl
    ,   p_Header_Scredit_val_tbl      => p_old_Header_Scredit_val_tbl
    ,   p_Header_Payment_tbl          => p_old_Header_Payment_tbl
    ,   p_Header_Payment_val_tbl      => p_old_Header_Payment_val_tbl
    ,   p_line_tbl                    => p_old_line_tbl
    ,   p_line_val_tbl                => p_old_line_val_tbl
    ,   p_Line_Adj_tbl                => p_old_Line_Adj_tbl
    ,   p_Line_Adj_val_tbl            => p_old_Line_Adj_val_tbl
    ,   p_Line_Scredit_tbl            => p_old_Line_Scredit_tbl
    ,   p_Line_Scredit_val_tbl        => p_old_Line_Scredit_val_tbl
    ,   p_Line_Payment_tbl            => p_old_Line_Payment_tbl
    ,   p_Line_Payment_val_tbl        => p_old_Line_Payment_val_tbl
    ,   p_Lot_Serial_tbl              => p_Lot_Serial_tbl
    ,   p_Lot_Serial_val_tbl          => p_Lot_Serial_val_tbl
    ,   x_header_rec                  => l_old_header_rec
    ,   x_Header_Adj_tbl              => l_old_Header_Adj_tbl
    ,   x_Header_Scredit_tbl          => l_old_Header_Scredit_tbl
    ,   x_Header_Payment_tbl          => l_old_Header_Payment_tbl
    ,   x_line_tbl                    => l_old_line_tbl
    ,   x_Line_Adj_tbl                => l_old_Line_Adj_tbl
    ,   x_Line_Scredit_tbl            => l_old_Line_Scredit_tbl
    ,   x_Line_Payment_tbl            => l_old_Line_Payment_tbl
    ,   x_Lot_Serial_tbl              => l_Lot_Serial_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --added for bug 3390458
    IF p_rtrim_data ='Y'
    THEN
       OE_ORDER_GRP.RTrim_data
          (  p_x_header_rec => l_header_rec
           , p_x_line_tbl => l_line_tbl
           , x_return_status =>x_return_status);
    END IF;

    OE_GLOBALS.g_validate_desc_flex :=p_validate_desc_flex; --bug 4343612
    --  Call OE_Order_PVT.Process_Order

    OE_Order_PVT.Process_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_action_commit               => p_action_commit
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                => l_header_rec
    ,   p_old_header_rec              => l_old_header_rec
    ,   p_x_Header_Adj_tbl            => l_Header_Adj_tbl
    ,   p_old_Header_Adj_tbl          => l_old_Header_Adj_tbl
    ,   p_x_Header_Price_Att_tbl      => l_Header_Price_Att_tbl
    ,   p_old_Header_Price_Att_tbl    => l_old_Header_Price_Att_tbl
    ,   p_x_Header_Adj_Att_tbl	      => l_Header_Adj_Att_tbl
    ,   p_old_Header_Adj_Att_tbl      => l_old_Header_Adj_Att_tbl
    ,   p_x_Header_Adj_Assoc_tbl      => l_Header_Adj_Assoc_tbl
    ,   p_old_Header_Adj_Assoc_tbl    => l_old_Header_Adj_Assoc_tbl
    ,   p_x_Header_Scredit_tbl        => l_Header_Scredit_tbl
    ,   p_old_Header_Scredit_tbl      => l_old_Header_Scredit_tbl
    ,   p_x_Header_Payment_tbl        => l_Header_Payment_tbl
    ,   p_old_Header_Payment_tbl      => l_old_Header_Payment_tbl
    ,   p_x_line_tbl                  => l_line_tbl
    ,   p_old_line_tbl                => l_old_line_tbl
    ,   p_x_Line_Adj_tbl              => l_Line_Adj_tbl
    ,   p_old_Line_Adj_tbl            => l_old_Line_Adj_tbl
    ,   p_x_Line_Price_Att_tbl	      => l_Line_Price_Att_tbl
    ,   p_old_Line_Price_Att_tbl      => l_old_Line_Price_Att_tbl
    ,   p_x_Line_Adj_Att_tbl	      => l_Line_Adj_Att_tbl
    ,   p_old_Line_Adj_Att_tbl	      => l_old_Line_Adj_Att_tbl
    ,   p_x_Line_Adj_Assoc_tbl	      => l_Line_Adj_Assoc_tbl
    ,   p_old_Line_Adj_Assoc_tbl      => l_old_Line_Adj_Assoc_tbl
    ,   p_x_Line_Scredit_tbl          => l_Line_Scredit_tbl
    ,   p_old_Line_Scredit_tbl        => l_old_Line_Scredit_tbl
    ,   p_x_Line_Payment_tbl          => l_Line_Payment_tbl
    ,   p_old_Line_Payment_tbl        => l_old_Line_Payment_tbl
    ,   p_x_Lot_Serial_tbl            => l_Lot_Serial_tbl
    ,   p_old_Lot_Serial_tbl          => l_old_Lot_Serial_tbl
    ,   p_x_action_request_tbl	      => x_action_request_tbl
    );

    --  Load Id OUT NOCOPY /* file.sql.39 change */ parameters.

    x_header_rec                   := l_header_rec;
    x_Header_Adj_tbl               := l_Header_Adj_tbl;
    x_Header_Price_Att_tbl	   := l_Header_Price_Att_tbl;
    x_Header_Adj_Att_tbl	   := l_Header_Adj_Att_tbl;
    x_Header_Adj_Assoc_tbl	   := l_Header_Adj_Assoc_tbl;
    x_Header_Scredit_tbl           := l_Header_Scredit_tbl;
    x_Header_Payment_tbl           := l_Header_Payment_tbl;
    x_line_tbl                     := l_line_tbl;
    x_Line_Adj_tbl                 := l_Line_Adj_tbl;
    x_Line_Price_Att_tbl	   := l_Line_Price_Att_tbl;
    x_Line_Adj_Att_tbl		   := l_Line_Adj_Att_tbl;
    x_Line_Adj_Assoc_tbl	   := l_Line_Adj_Assoc_tbl;
    x_Line_Scredit_tbl             := l_Line_Scredit_tbl;
    x_Line_Payment_tbl             := l_Line_Payment_tbl;
    x_Lot_Serial_tbl               := l_Lot_Serial_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_header_rec                  => l_header_rec
        ,   p_Header_Adj_tbl              => l_Header_Adj_tbl
        ,   p_Header_Scredit_tbl          => l_Header_Scredit_tbl
        ,   p_Header_Payment_tbl          => l_Header_Payment_tbl
        ,   p_line_tbl                    => l_line_tbl
        ,   p_Line_Adj_tbl                => l_Line_Adj_tbl
        ,   p_Line_Scredit_tbl            => l_Line_Scredit_tbl
        ,   p_Line_Payment_tbl            => l_Line_Payment_tbl
        ,   p_Lot_Serial_tbl              => l_Lot_Serial_tbl
        ,   x_header_val_rec              => x_header_val_rec
        ,   x_Header_Adj_val_tbl          => x_Header_Adj_val_tbl
        ,   x_Header_Scredit_val_tbl      => x_Header_Scredit_val_tbl
	,   x_Header_Payment_val_tbl      => x_Header_Payment_val_tbl
        ,   x_line_val_tbl                => x_line_val_tbl
        ,   x_Line_Adj_val_tbl            => x_Line_Adj_val_tbl
        ,   x_Line_Scredit_val_tbl        => x_Line_Scredit_val_tbl
	,   x_Line_Payment_val_tbl        => x_Line_Payment_val_tbl
        ,   x_Lot_Serial_val_tbl          => x_Lot_Serial_val_tbl
        );

    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Order'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Order;

PROCEDURE Lock_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,  p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_rec                    IN  Header_Rec_Type :=
                                        G_MISS_HEADER_REC
,   p_header_val_rec                IN  Header_Val_Rec_Type :=
                                        G_MISS_HEADER_VAL_REC
,   p_Header_Adj_tbl                IN  Header_Adj_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_TBL
,   p_Header_Adj_val_tbl            IN  Header_Adj_Val_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_VAL_TBL
,   p_Header_price_Att_tbl          IN  Header_Price_Att_Tbl_Type :=
                                        G_MISS_HEADER_PRICE_ATT_TBL
,   p_Header_Adj_Att_tbl            IN  Header_Adj_Att_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_ATT_TBL
,   p_Header_Adj_Assoc_tbl            IN  Header_Adj_Assoc_Tbl_Type :=
                                        G_MISS_HEADER_ADJ_ASSOC_TBL
,   p_Header_Scredit_tbl            IN  Header_Scredit_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_TBL
,   p_Header_Scredit_val_tbl        IN  Header_Scredit_Val_Tbl_Type :=
                                        G_MISS_HEADER_SCREDIT_VAL_TBL
,   p_Header_Payment_tbl            IN  Header_Payment_Tbl_Type :=
                                    	G_MISS_HEADER_PAYMENT_TBL
,   p_Header_Payment_val_tbl        IN  Header_Payment_Val_Tbl_Type :=
                                     	G_MISS_HEADER_PAYMENT_VAL_TBL
,   p_line_tbl                      IN  Line_Tbl_Type :=
                                        G_MISS_LINE_TBL
,   p_line_val_tbl                  IN  Line_Val_Tbl_Type :=
                                        G_MISS_LINE_VAL_TBL
,   p_Line_Adj_tbl                  IN  Line_Adj_Tbl_Type :=
                                        G_MISS_LINE_ADJ_TBL
,   p_Line_Adj_val_tbl              IN  Line_Adj_Val_Tbl_Type :=
                                        G_MISS_LINE_ADJ_VAL_TBL
,   p_Line_price_Att_tbl            IN  Line_Price_Att_Tbl_Type :=
                                        G_MISS_LINE_PRICE_ATT_TBL
,   p_Line_Adj_Att_tbl              IN  Line_Adj_Att_Tbl_Type :=
                                        G_MISS_LINE_ADJ_ATT_TBL
,   p_Line_Adj_Assoc_tbl              IN  Line_Adj_Assoc_Tbl_Type :=
                                        G_MISS_LINE_ADJ_ASSOC_TBL
,   p_Line_Scredit_tbl              IN  Line_Scredit_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_TBL
,   p_Line_Scredit_val_tbl          IN  Line_Scredit_Val_Tbl_Type :=
                                        G_MISS_LINE_SCREDIT_VAL_TBL
,   p_Line_Payment_tbl              IN  Line_Payment_Tbl_Type :=
                                        G_MISS_LINE_PAYMENT_TBL
,   p_Line_Payment_val_tbl          IN  Line_Payment_Val_Tbl_Type :=
                                        G_MISS_LINE_PAYMENT_VAL_TBL
,   p_Lot_Serial_tbl                IN  Lot_Serial_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_TBL
,   p_Lot_Serial_val_tbl            IN  Lot_Serial_Val_Tbl_Type :=
                                        G_MISS_LOT_SERIAL_VAL_TBL
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Val_Tbl_Type
,   x_Header_Payment_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Payment_Tbl_Type
,   x_Header_Payment_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Payment_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Val_Tbl_Type
,   x_Line_Payment_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Payment_Tbl_Type
,   x_Line_Payment_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Payment_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Order';
l_return_status               VARCHAR2(1);
l_header_rec                  Header_Rec_Type;
l_Header_Adj_tbl              Header_Adj_Tbl_Type;
l_Header_price_Att_tbl        Header_Price_Att_Tbl_Type ;
l_Header_Adj_Att_tbl          Header_Adj_Att_Tbl_Type ;
l_Header_Adj_Assoc_tbl        Header_Adj_Assoc_Tbl_Type ;
l_Header_Scredit_tbl          Header_Scredit_Tbl_Type;
l_Header_Payment_tbl          Header_Payment_Tbl_Type;
l_line_tbl                    Line_Tbl_Type;
l_Line_Adj_tbl                Line_Adj_Tbl_Type;
l_Line_price_Att_tbl          Line_Price_Att_Tbl_Type ;
l_Line_Adj_Att_tbl            Line_Adj_Att_Tbl_Type ;
l_Line_Adj_Assoc_tbl          Line_Adj_Assoc_Tbl_Type ;
l_Line_Scredit_tbl            Line_Scredit_Tbl_Type;
l_Line_Payment_tbl            Line_Payment_Tbl_Type;
l_Lot_Serial_tbl              Lot_Serial_Tbl_Type;
l_org_id number;
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Logic added for MOAC


    -- FIND Org_Id logic :
    -- We first look at p_org_id to set Context.
    -- If p_org_id passed in, we ignore p_operating_unit.
    -- If p_org_id not passed in, then we look at p_operating_unit to get org_id.
    -- If both are not passed in, we get the context from MO Get_Default_Org API.
    --
    IF (p_org_id IS NOT NULL AND p_org_id <> FND_API.G_MISS_NUM) THEN
       l_org_id :=  p_org_id;

       -- ignore p_operating_unit since p_org_id has passed in.
       -- We check if both p_org_id and p_operating_unit pass in,
       -- add a message just for the information.
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR)  THEN
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN
                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','operating_unit');
                OE_MSG_PUB.Add;
            END IF;
       END IF;

    ELSE
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR) THEN
           -- call value_to_id to get org_id
           l_org_id := OE_Value_To_Id.OPERATING_UNIT(p_operating_unit);
       -- comment out due to new call to MO_GLOBAL.validate_orgid_pub_api
       /*
        ELSE
           -- Both p_org_id and p_operating_unit are not passed in.
           l_org_id := MO_UTILS.get_default_org_id ;
        */
        END IF;
     END IF;

    -- Validate Org_Id
    -- call new API : MO_GLOBAL.validate_orgid_pub_api
    -- Instead of calling old function - MO_GLOBAL.check_valid_org
    -- MO_GLOBAL.validate_orgid_pub_api provides backward compatibility
    -- without adding code to call MO_GLOBAL.init

   /* MO_GLOBAL.validate_orgid_pub_api
    (   ORG_ID  =>  l_org_id
     ,  Status  =>  l_return_status
    ) ;*/
    /*IF(l_return_status ='F') THEN
       -- return Failure
       raise FND_API.G_EXC_ERROR;
    END IF;*/

    -- Set Application Context
    -- Since we pass validation, we start to Set Application Context
    -- Call MO set_policy_context to set application context by sending
    -- p_access_mode ='S' (Single Operating Unit Access) and org_id
    -- Then call OE_GLOBALS.Set_Context to set OE_GLOBALS.G_ORG_ID
    --
    --MO_GLOBAL.set_policy_context('S',l_org_id);
    --OE_GLOBALS.Set_Context();
    --Moved the logic to set context to new procedure set_context
     set_context(p_org_id =>l_org_id);

    --  From now on, we are in single access mode.


    --  Perform Value to Id conversion

    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_header_rec                  => p_header_rec
    ,   p_header_val_rec              => p_header_val_rec
    ,   p_Header_Adj_tbl              => p_Header_Adj_tbl
    ,   p_Header_Adj_val_tbl          => p_Header_Adj_val_tbl
    ,   p_Header_Scredit_tbl          => p_Header_Scredit_tbl
    ,   p_Header_Scredit_val_tbl      => p_Header_Scredit_val_tbl
    ,   p_Header_Payment_tbl          => p_Header_Payment_tbl
    ,   p_Header_Payment_val_tbl      => p_Header_Payment_val_tbl
    ,   p_line_tbl                    => p_line_tbl
    ,   p_line_val_tbl                => p_line_val_tbl
    ,   p_Line_Adj_tbl                => p_Line_Adj_tbl
    ,   p_Line_Adj_val_tbl            => p_Line_Adj_val_tbl
    ,   p_Line_Scredit_tbl            => p_Line_Scredit_tbl
    ,   p_Line_Scredit_val_tbl        => p_Line_Scredit_val_tbl
    ,   p_Line_Payment_tbl            => p_Line_Payment_tbl
    ,   p_Line_Payment_val_tbl        => p_Line_Payment_val_tbl
    ,   p_Lot_Serial_tbl              => p_Lot_Serial_tbl
    ,   p_Lot_Serial_val_tbl          => p_Lot_Serial_val_tbl
    ,   x_header_rec                  => l_header_rec
    ,   x_Header_Adj_tbl              => l_Header_Adj_tbl
    ,   x_Header_Scredit_tbl          => l_Header_Scredit_tbl
    ,   x_Header_Payment_tbl          => l_Header_Payment_tbl
    ,   x_line_tbl                    => l_line_tbl
    ,   x_Line_Adj_tbl                => l_Line_Adj_tbl
    ,   x_Line_Scredit_tbl            => l_Line_Scredit_tbl
    ,   x_Line_Payment_tbl            => l_Line_Payment_tbl
    ,   x_Lot_Serial_tbl              => l_Lot_Serial_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call OE_Order_PVT.Lock_Order

    OE_Order_PVT.Lock_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_x_header_rec                => l_header_rec
    ,   p_x_Header_Adj_tbl            => l_Header_Adj_tbl
    ,   p_x_Header_Price_Att_tbl      => l_Header_Price_Att_tbl
    ,   p_x_Header_Adj_Att_tbl	      => l_Header_Adj_Att_tbl
    ,   p_x_Header_Adj_Assoc_tbl      => l_Header_Adj_Assoc_tbl
    ,   p_x_Header_Scredit_tbl        => l_Header_Scredit_tbl
    ,   p_x_Header_Payment_tbl        => l_Header_Payment_tbl
    ,   p_x_line_tbl                  => l_line_tbl
    ,   p_x_Line_Adj_tbl              => l_Line_Adj_tbl
    ,   p_x_Line_Price_Att_tbl	      => l_Line_Price_Att_tbl
    ,   p_x_Line_Adj_Att_tbl	      => l_Line_Adj_Att_tbl
    ,   p_x_Line_Adj_Assoc_tbl	      => l_Line_Adj_Assoc_tbl
    ,   p_x_Line_Scredit_tbl          => l_Line_Scredit_tbl
    ,   p_x_Line_Payment_tbl          => l_Line_Payment_tbl
    ,   p_x_Lot_Serial_tbl            => l_Lot_Serial_tbl
    );

    --  Load Id OUT NOCOPY /* file.sql.39 change */ parameters.

    x_header_rec                   := l_header_rec;
    x_Header_Adj_tbl               := l_Header_Adj_tbl;
    x_Header_Price_Att_tbl	   := l_Header_Price_Att_tbl;
    x_Header_Adj_Att_tbl	   := l_Header_Adj_Att_tbl;
    x_Header_Adj_Assoc_tbl	   := l_Header_Adj_Assoc_tbl;
    x_Header_Scredit_tbl           := l_Header_Scredit_tbl;
    x_Header_Payment_tbl           := l_Header_Payment_tbl;
    x_line_tbl                     := l_line_tbl;
    x_Line_Adj_tbl                 := l_Line_Adj_tbl;
    x_Line_Price_Att_tbl	   := l_Line_Price_Att_tbl;
    x_Line_Adj_Att_tbl		   := l_Line_Adj_Att_tbl;
    x_Line_Adj_Assoc_tbl	   := l_Line_Adj_Assoc_tbl;
    x_Line_Scredit_tbl             := l_Line_Scredit_tbl;
    x_Line_Payment_tbl             := l_Line_Payment_tbl;
    x_Lot_Serial_tbl               := l_Lot_Serial_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_header_rec                  => l_header_rec
        ,   p_Header_Adj_tbl              => l_Header_Adj_tbl
        ,   p_Header_Scredit_tbl          => l_Header_Scredit_tbl
        ,   p_Header_Payment_tbl          => l_Header_Payment_tbl
        ,   p_line_tbl                    => l_line_tbl
        ,   p_Line_Adj_tbl                => l_Line_Adj_tbl
        ,   p_Line_Scredit_tbl            => l_Line_Scredit_tbl
        ,   p_Line_Payment_tbl            => l_Line_Payment_tbl
        ,   p_Lot_Serial_tbl              => l_Lot_Serial_tbl
        ,   x_header_val_rec              => x_header_val_rec
        ,   x_Header_Adj_val_tbl          => x_Header_Adj_val_tbl
        ,   x_Header_Scredit_val_tbl      => x_Header_Scredit_val_tbl
        ,   x_Header_Payment_val_tbl      => x_Header_Payment_val_tbl
        ,   x_line_val_tbl                => x_line_val_tbl
        ,   x_Line_Adj_val_tbl            => x_Line_Adj_val_tbl
        ,   x_Line_Scredit_val_tbl        => x_Line_Scredit_val_tbl
        ,   x_Line_Payment_val_tbl        => x_Line_Payment_val_tbl
        ,   x_Lot_Serial_val_tbl          => x_Lot_Serial_val_tbl
        );

    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Order'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Lock_Order;

PROCEDURE Get_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_header_id                     IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_header                        IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC
,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ Header_Rec_Type
,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ Header_Val_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ Header_Adj_Tbl_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Val_Tbl_Type
,   x_Header_price_Att_tbl          OUT NOCOPY /* file.sql.39 change */ Header_Price_Att_Tbl_Type
,   x_Header_Adj_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Att_Tbl_Type
,   x_Header_Adj_Assoc_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Assoc_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Val_Tbl_Type
,   x_Header_Payment_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Payment_Tbl_Type
,   x_Header_Payment_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Payment_Val_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ Line_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Val_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Adj_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Val_Tbl_Type
,   x_Line_price_Att_tbl            OUT NOCOPY /* file.sql.39 change */ Line_Price_Att_Tbl_Type
,   x_Line_Adj_Att_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Att_Tbl_Type
,   x_Line_Adj_Assoc_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Assoc_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Val_Tbl_Type
,   x_Line_Payment_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Payment_Tbl_Type
,   x_Line_Payment_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Payment_Val_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Order';
l_header_id                   NUMBER := p_header_id;
l_org_id number;
l_return_status                 VARCHAR2(30);
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Logic added for MOAC


    -- FIND Org_Id logic :
    -- We first look at p_org_id to set Context.
    -- If p_org_id passed in, we ignore p_operating_unit.
    -- If p_org_id not passed in, then we look at p_operating_unit to get org_id.
    -- If both are not passed in, we get the context from MO Get_Default_Org API.
    --
    IF (p_org_id IS NOT NULL AND p_org_id <> FND_API.G_MISS_NUM) THEN
       l_org_id :=  p_org_id;

       -- ignore p_operating_unit since p_org_id has passed in.
       -- We check if both p_org_id and p_operating_unit pass in,
       -- add a message just for the information.
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR)  THEN
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN
                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','operating_unit');
                OE_MSG_PUB.Add;
            END IF;
       END IF;

    ELSE
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR) THEN
           -- call value_to_id to get org_id
           l_org_id := OE_Value_To_Id.OPERATING_UNIT(p_operating_unit);
       -- comment out due to new call to MO_GLOBAL.validate_orgid_pub_api
       /*
        ELSE
           -- Both p_org_id and p_operating_unit are not passed in.
           l_org_id := MO_UTILS.get_default_org_id ;
        */
        END IF;
     END IF;

    -- Validate Org_Id
    -- call new API : MO_GLOBAL.validate_orgid_pub_api
    -- Instead of calling old function - MO_GLOBAL.check_valid_org
    -- MO_GLOBAL.validate_orgid_pub_api provides backward compatibility
    -- without adding code to call MO_GLOBAL.init

   /* MO_GLOBAL.validate_orgid_pub_api
    (   ORG_ID  =>  l_org_id
     ,  Status  =>  l_return_status
    ) ;*/
    /*IF(l_return_status ='F') THEN
       -- return Failure
       raise FND_API.G_EXC_ERROR;
    END IF;*/

    -- Set Application Context
    -- Since we pass validation, we start to Set Application Context
    -- Call MO set_policy_context to set application context by sending
    -- p_access_mode ='S' (Single Operating Unit Access) and org_id
    -- Then call OE_GLOBALS.Set_Context to set OE_GLOBALS.G_ORG_ID
    --
    --MO_GLOBAL.set_policy_context('S',l_org_id);
    --OE_GLOBALS.Set_Context();
    --Moved the logic to set context to new procedure set_context
     set_context(p_org_id =>l_org_id);


    --  From now on, we are in single access mode.



    --  Standard check for Val/ID conversion

    IF  p_header = FND_API.G_MISS_CHAR
    THEN

        l_header_id := p_header_id;

    ELSIF p_header_id <> FND_API.G_MISS_NUM THEN

        l_header_id := p_header_id;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','header');
            OE_MSG_PUB.Add;

        END IF;

    ELSE

        --  Convert Value to Id

        /*l_header_id := OE_Value_To_Id.header
        (   p_header                      => p_header
        );*/

        IF l_header_id = FND_API.G_MISS_NUM THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

                fnd_message.set_name('ONT','Invalid Business Object Value');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','header');
                OE_MSG_PUB.Add;

            END IF;
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;


    --  Call OE_Order_PVT.Get_Order

    OE_Order_PVT.Get_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_header_id                   => l_header_id
    ,   x_header_rec                  => x_header_rec
    ,   x_Header_Adj_tbl              => x_Header_Adj_tbl
    ,   x_Header_Price_Att_tbl	      => x_Header_Price_Att_tbl
    ,   x_Header_Adj_Att_tbl	      => x_Header_Adj_Att_tbl
    ,   x_Header_Adj_Assoc_tbl	      => x_Header_Adj_Assoc_tbl
    ,   x_Header_Scredit_tbl          => x_Header_Scredit_tbl
    ,   x_Header_Payment_tbl          => x_Header_Payment_tbl
    ,   x_line_tbl                    => x_line_tbl
    ,   x_Line_Adj_tbl                => x_Line_Adj_tbl
    ,   x_Line_Price_Att_tbl	      => x_Line_Price_Att_tbl
    ,   x_Line_Adj_Att_tbl	      => x_Line_Adj_Att_tbl
    ,   x_Line_Adj_Assoc_tbl	      => x_Line_Adj_Assoc_tbl
    ,   x_Line_Scredit_tbl            => x_Line_Scredit_tbl
    ,   x_Line_Payment_tbl            => x_Line_Payment_tbl
    ,   x_Lot_Serial_tbl              => x_Lot_Serial_tbl
    );


    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.TO_BOOLEAN(p_return_values) THEN

        Id_To_Value
        (   p_header_rec                  => x_header_rec
        ,   p_Header_Adj_tbl              => x_Header_Adj_tbl
        ,   p_Header_Scredit_tbl          => x_Header_Scredit_tbl
        ,   p_Header_Payment_tbl          => x_Header_Payment_tbl
        ,   p_line_tbl                    => x_line_tbl
        ,   p_Line_Adj_tbl                => x_Line_Adj_tbl
        ,   p_Line_Scredit_tbl            => x_Line_Scredit_tbl
        ,   p_Line_Payment_tbl            => x_Line_Payment_tbl
        ,   p_Lot_Serial_tbl              => x_Lot_Serial_tbl
        ,   x_header_val_rec              => x_header_val_rec
        ,   x_Header_Adj_val_tbl          => x_Header_Adj_val_tbl
        ,   x_Header_Scredit_val_tbl      => x_Header_Scredit_val_tbl
        ,   x_Header_Payment_val_tbl      => x_Header_Payment_val_tbl
        ,   x_line_val_tbl                => x_line_val_tbl
        ,   x_Line_Adj_val_tbl            => x_Line_Adj_val_tbl
        ,   x_Line_Scredit_val_tbl        => x_Line_Scredit_val_tbl
        ,   x_Line_Payment_val_tbl        => x_Line_Payment_val_tbl
        ,   x_Lot_Serial_val_tbl          => x_Lot_Serial_val_tbl
        );

    END IF;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Order'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Order;

--  Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_header_rec                    IN  Header_Rec_Type
,   p_Header_Adj_tbl                IN  Header_Adj_Tbl_Type
,   p_Header_Scredit_tbl            IN  Header_Scredit_Tbl_Type
,   p_Header_Payment_tbl            IN  Header_Payment_Tbl_Type
,   p_line_tbl                      IN  Line_Tbl_Type
,   p_Line_Adj_tbl                  IN  Line_Adj_Tbl_Type
,   p_Line_Scredit_tbl              IN  Line_Scredit_Tbl_Type
,   p_Line_Payment_tbl              IN  Line_Payment_Tbl_Type
,   p_Lot_Serial_tbl                IN  Lot_Serial_Tbl_Type
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC

,   x_header_val_rec                OUT NOCOPY /* file.sql.39 change */ Header_Val_Rec_Type
,   x_Header_Adj_val_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Adj_Val_Tbl_Type
,   x_Header_Scredit_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Val_Tbl_Type
,   x_Header_Payment_val_tbl        OUT NOCOPY /* file.sql.39 change */ Header_Payment_Val_Tbl_Type
,   x_line_val_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Val_Tbl_Type
,   x_Line_Adj_val_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Adj_Val_Tbl_Type
,   x_Line_Scredit_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Val_Tbl_Type
,   x_Line_Payment_val_tbl          OUT NOCOPY /* file.sql.39 change */ Line_Payment_Val_Tbl_Type
,   x_Lot_Serial_val_tbl            OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Val_Tbl_Type
)
IS
l_org_id number;
l_return_status                 VARCHAR2(30);
BEGIN

    -- Logic added for MOAC


    -- FIND Org_Id logic :
    -- We first look at p_org_id to set Context.
    -- If p_org_id passed in, we ignore p_operating_unit.
    -- If p_org_id not passed in, then we look at p_operating_unit to get org_id.
    -- If both are not passed in, we get the context from MO Get_Default_Org API.
    --
    IF (p_org_id IS NOT NULL AND p_org_id <> FND_API.G_MISS_NUM) THEN
       l_org_id :=  p_org_id;

       -- ignore p_operating_unit since p_org_id has passed in.
       -- We check if both p_org_id and p_operating_unit pass in,
       -- add a message just for the information.
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR)  THEN
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN
                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','operating_unit');
                OE_MSG_PUB.Add;
            END IF;
       END IF;

    ELSE
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR) THEN
           -- call value_to_id to get org_id
           l_org_id := OE_Value_To_Id.OPERATING_UNIT(p_operating_unit);
       -- comment out due to new call to MO_GLOBAL.validate_orgid_pub_api

        ELSE
           -- Both p_org_id and p_operating_unit are not passed in.
          -- This is required since this procedure is called from process order
         -- The mo init is already run and the org id is not passed
		 l_org_id := MO_GLOBAL.get_current_org_id;

        END IF;
     END IF;

    -- Validate Org_Id
    -- call new API : MO_GLOBAL.validate_orgid_pub_api
    -- Instead of calling old function - MO_GLOBAL.check_valid_org
    -- MO_GLOBAL.validate_orgid_pub_api provides backward compatibility
    -- without adding code to call MO_GLOBAL.init

   /* MO_GLOBAL.validate_orgid_pub_api
    (   ORG_ID  =>  l_org_id
     ,  Status  =>  l_return_status
    ) ;*/
    /*IF(l_return_status ='F') THEN
       -- return Failure
       raise FND_API.G_EXC_ERROR;
    END IF;*/

    -- Set Application Context
    -- Since we pass validation, we start to Set Application Context
    -- Call MO set_policy_context to set application context by sending
    -- p_access_mode ='S' (Single Operating Unit Access) and org_id
    -- Then call OE_GLOBALS.Set_Context to set OE_GLOBALS.G_ORG_ID
    --
    --MO_GLOBAL.set_policy_context('S',l_org_id);
    --OE_GLOBALS.Set_Context();
    --Moved the logic to set context to new procedure set_context
     set_context(p_org_id =>l_org_id);


    --  From now on, we are in single access mode.




    OE_Order_GRP.ID_To_Value
        (   p_header_rec                  => p_header_rec
        ,   p_Header_Adj_tbl              => p_Header_Adj_tbl
        ,   p_Header_Scredit_tbl          => p_Header_Scredit_tbl
        ,   p_Header_Payment_tbl          => p_Header_Payment_tbl
        ,   p_line_tbl                    => p_line_tbl
        ,   p_Line_Adj_tbl                => p_Line_Adj_tbl
        ,   p_Line_Scredit_tbl            => p_Line_Scredit_tbl
        ,   p_Line_Payment_tbl            => p_Line_Payment_tbl
        ,   p_Lot_Serial_tbl              => p_Lot_Serial_tbl
        ,   x_header_val_rec              => x_header_val_rec
        ,   x_Header_Adj_val_tbl          => x_Header_Adj_val_tbl
        ,   x_Header_Scredit_val_tbl      => x_Header_Scredit_val_tbl
        ,   x_Header_Payment_val_tbl      => x_Header_Payment_val_tbl
        ,   x_line_val_tbl                => x_line_val_tbl
        ,   x_Line_Adj_val_tbl            => x_Line_Adj_val_tbl
        ,   x_Line_Scredit_val_tbl        => x_Line_Scredit_val_tbl
        ,   x_Line_Payment_val_tbl        => x_Line_Payment_val_tbl
        ,   x_Lot_Serial_val_tbl          => x_Lot_Serial_val_tbl
        );

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Id_To_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Id_To_Value;

--  Procedure Value_To_Id

PROCEDURE Value_To_Id (
    p_header_rec                    IN  Header_Rec_Type
,   p_header_val_rec                IN  Header_Val_Rec_Type
,   p_Header_Adj_tbl                IN  Header_Adj_Tbl_Type
,   p_Header_Adj_val_tbl            IN  Header_Adj_Val_Tbl_Type
,   p_Header_Scredit_tbl            IN  Header_Scredit_Tbl_Type
,   p_Header_Scredit_val_tbl        IN  Header_Scredit_Val_Tbl_Type
,   p_Header_Payment_tbl            IN  Header_Payment_Tbl_Type
,   p_Header_Payment_val_tbl        IN  Header_Payment_Val_Tbl_Type
,   p_line_tbl                      IN  Line_Tbl_Type
,   p_line_val_tbl                  IN  Line_Val_Tbl_Type
,   p_Line_Adj_tbl                  IN  Line_Adj_Tbl_Type
,   p_Line_Adj_val_tbl              IN  Line_Adj_Val_Tbl_Type
,   p_Line_Scredit_tbl              IN  Line_Scredit_Tbl_Type
,   p_Line_Scredit_val_tbl          IN  Line_Scredit_Val_Tbl_Type
,   p_Line_Payment_val_tbl          IN  Line_Payment_Val_Tbl_Type
,   p_Line_Payment_tbl              IN  Line_Payment_Tbl_Type
,   p_Lot_Serial_tbl                IN  Lot_Serial_Tbl_Type
,   p_Lot_Serial_val_tbl            IN  Lot_Serial_Val_Tbl_Type
, p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC

,   x_header_rec                    OUT NOCOPY /* file.sql.39 change */ Header_Rec_Type
,   x_Header_Adj_tbl                OUT NOCOPY /* file.sql.39 change */ Header_Adj_Tbl_Type
,   x_Header_Scredit_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Scredit_Tbl_Type
,   x_Header_Payment_tbl            OUT NOCOPY /* file.sql.39 change */ Header_Payment_Tbl_Type
,   x_line_tbl                      OUT NOCOPY /* file.sql.39 change */ Line_Tbl_Type
,   x_Line_Adj_tbl                  OUT NOCOPY /* file.sql.39 change */ Line_Adj_Tbl_Type
,   x_Line_Scredit_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Scredit_Tbl_Type
,   x_Line_Payment_tbl              OUT NOCOPY /* file.sql.39 change */ Line_Payment_Tbl_Type
,   x_Lot_Serial_tbl                OUT NOCOPY /* file.sql.39 change */ Lot_Serial_Tbl_Type
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_org_id number;
l_return_status                 VARCHAR2(30);
BEGIN

    -- Logic added for MOAC


    -- FIND Org_Id logic :
    -- We first look at p_org_id to set Context.
    -- If p_org_id passed in, we ignore p_operating_unit.
    -- If p_org_id not passed in, then we look at p_operating_unit to get org_id.
    -- If both are not passed in, we get the context from MO Get_Default_Org API.
    --
    IF (p_org_id IS NOT NULL AND p_org_id <> FND_API.G_MISS_NUM) THEN
       l_org_id :=  p_org_id;

       -- ignore p_operating_unit since p_org_id has passed in.
       -- We check if both p_org_id and p_operating_unit pass in,
       -- add a message just for the information.
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR)  THEN
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN
                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','operating_unit');
                OE_MSG_PUB.Add;
            END IF;
       END IF;

    ELSE
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR) THEN
           -- call value_to_id to get org_id
           l_org_id := OE_Value_To_Id.OPERATING_UNIT(p_operating_unit);
       -- comment out due to new call to MO_GLOBAL.validate_orgid_pub_api

        ELSE
           -- Both p_org_id and p_operating_unit are not passed in.
           --this is required since some APIs such as process order will
        -- set the org already so no need to pass org id agai
		  l_org_id := MO_GLOBAL.get_current_org_id;

        END IF;
     END IF;

    -- Validate Org_Id
    -- call new API : MO_GLOBAL.validate_orgid_pub_api
    -- Instead of calling old function - MO_GLOBAL.check_valid_org
    -- MO_GLOBAL.validate_orgid_pub_api provides backward compatibility
    -- without adding code to call MO_GLOBAL.init

   /*MO_GLOBAL.validate_orgid_pub_api
    (   ORG_ID  =>  l_org_id
     ,  Status  =>  l_return_status
    ) ;*/
    /*IF(l_return_status ='F') THEN
       -- return Failure
       raise FND_API.G_EXC_ERROR;
    END IF;*/

    -- Set Application Context
    -- Since we pass validation, we start to Set Application Context
    -- Call MO set_policy_context to set application context by sending
    -- p_access_mode ='S' (Single Operating Unit Access) and org_id
    -- Then call OE_GLOBALS.Set_Context to set OE_GLOBALS.G_ORG_ID
    --
    --MO_GLOBAL.set_policy_context('S',l_org_id);
    --OE_GLOBALS.Set_Context();
    --Moved the logic to set context to new procedure set_context
     set_context(p_org_id =>l_org_id);



    --  From now on, we are in single access mode.



    --  Init x_return_status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OE_Order_GRP.Value_To_ID
    (   x_return_status               => x_return_status
    ,   p_header_rec                  => p_header_rec
    ,   p_header_val_rec              => p_header_val_rec
    ,   p_Header_Adj_tbl              => p_Header_Adj_tbl
    ,   p_Header_Adj_val_tbl          => p_Header_Adj_val_tbl
    ,   p_Header_Scredit_tbl          => p_Header_Scredit_tbl
    ,   p_Header_Scredit_val_tbl      => p_Header_Scredit_val_tbl
    ,   p_Header_Payment_tbl          => p_Header_Payment_tbl
    ,   p_Header_Payment_val_tbl      => p_Header_Payment_val_tbl
    ,   p_line_tbl                    => p_line_tbl
    ,   p_line_val_tbl                => p_line_val_tbl
    ,   p_Line_Adj_tbl                => p_Line_Adj_tbl
    ,   p_Line_Adj_val_tbl            => p_Line_Adj_val_tbl
    ,   p_Line_Scredit_tbl            => p_Line_Scredit_tbl
    ,   p_Line_Scredit_val_tbl        => p_Line_Scredit_val_tbl
    ,   p_Line_Payment_tbl            => p_Line_Payment_tbl
    ,   p_Line_Payment_val_tbl        => p_Line_Payment_val_tbl
    ,   p_Lot_Serial_tbl              => p_Lot_Serial_tbl
    ,   p_Lot_Serial_val_tbl          => p_Lot_Serial_val_tbl
    ,   x_header_rec                  => x_header_rec
    ,   x_Header_Adj_tbl              => x_Header_Adj_tbl
    ,   x_Header_Scredit_tbl          => x_Header_Scredit_tbl
    ,   x_Header_Payment_tbl          => x_Header_Payment_tbl
    ,   x_line_tbl                    => x_line_tbl
    ,   x_Line_Adj_tbl                => x_Line_Adj_tbl
    ,   x_Line_Scredit_tbl            => x_Line_Scredit_tbl
    ,   x_Line_Payment_tbl            => x_Line_Payment_tbl
    ,   x_Lot_Serial_tbl              => x_Lot_Serial_tbl
    );

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Value_To_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Value_To_Id;

Procedure Process_MACD_Order
(P_api_version_number     IN  NUMBER,
 P_organization_id        IN  NUMBER,
 P_sold_to_org_id         IN  NUMBER,
 P_header_id              IN  NUMBER,
 P_MACD_Action            IN  VARCHAR2,
 P_Instance_Tbl           IN  csi_datastructures_pub.instance_cz_tbl,
 p_x_line_tbl             IN  OUT NOCOPY Line_Tbl_Type,
 P_Extended_Attrib_Tbl    IN  csi_datastructures_pub.ext_attrib_values_tbl,
 p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC

, X_container_line_id      OUT NOCOPY NUMBER,
 x_return_status          OUT NOCOPY VARCHAR2,
 x_msg_count              OUT NOCOPY VARCHAR2,
 x_msg_data               OUT NOCOPY VARCHAR2)
IS

 l_org_id                NUMBER;
 l_return_status         VARCHAR2(30);
 l_header_id             NUMBER;
 l_debug_level  CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 l_number_of_containers  NUMBER;
BEGIN
    -- Logic added for MOAC


    -- FIND Org_Id logic :
    -- We first look at p_org_id to set Context.
    -- If p_org_id passed in, we ignore p_operating_unit.
    -- If p_org_id not passed in, then we look at p_operating_unit to get org_id.
    -- If both are not passed in, we get the context from MO Get_Default_Org API.
    --
    IF (p_org_id IS NOT NULL AND p_org_id <> FND_API.G_MISS_NUM) THEN
       l_org_id :=  p_org_id;

       -- ignore p_operating_unit since p_org_id has passed in.
       -- We check if both p_org_id and p_operating_unit pass in,
       -- add a message just for the information.
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR)  THEN
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN
                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','operating_unit');
                OE_MSG_PUB.Add;
            END IF;
       END IF;

    ELSE
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR) THEN
           -- call value_to_id to get org_id
           l_org_id := OE_Value_To_Id.OPERATING_UNIT(p_operating_unit);
       -- comment out due to new call to MO_GLOBAL.validate_orgid_pub_api
       /*
        ELSE
           -- Both p_org_id and p_operating_unit are not passed in.
           l_org_id := MO_UTILS.get_default_org_id ;
        */
        END IF;
     END IF;

    -- Validate Org_Id
    -- call new API : MO_GLOBAL.validate_orgid_pub_api
    -- Instead of calling old function - MO_GLOBAL.check_valid_org
    -- MO_GLOBAL.validate_orgid_pub_api provides backward compatibility
    -- without adding code to call MO_GLOBAL.init

    /*MO_GLOBAL.validate_orgid_pub_api
    (   ORG_ID  =>  l_org_id
     ,  Status  =>  l_return_status
    ) ;*/
    /*IF(l_return_status ='F') THEN
       -- return Failure
       raise FND_API.G_EXC_ERROR;
    END IF;*/

    -- Set Application Context
    -- Since we pass validation, we start to Set Application Context
    -- Call MO set_policy_context to set application context by sending
    -- p_access_mode ='S' (Single Operating Unit Access) and org_id
    -- Then call OE_GLOBALS.Set_Context to set OE_GLOBALS.G_ORG_ID
    --
    --MO_GLOBAL.set_policy_context('S',l_org_id);
    --OE_GLOBALS.Set_Context();
    --Moved the logic to set context to new procedure set_context
     set_context(p_org_id =>l_org_id);


    --  From now on, we are in single access mode.

    l_header_id := p_header_id;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(' Before calling private Process_MACD_Order',   1 ) ;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   Oe_config_tso_pvt.Process_MACD_Order
   (p_API_VERSION_NUMBER     => P_API_VERSION_NUMBER,
    p_caller                 => 'P', -- public
    p_sold_to_org_id         => p_sold_to_org_id,
    p_x_header_id            => l_header_id,
    p_MACD_Action            => p_macd_action,
    p_Instance_Tbl           => p_instance_tbl,
    p_x_Line_Tbl             => p_x_line_tbl,
    p_Extended_Attrib_Tbl    => p_Extended_Attrib_Tbl,
    x_container_line_id      => x_container_line_id,
    x_number_of_containers   => l_number_of_containers,
    x_return_status          => x_return_status,
    x_msg_count              => x_msg_count,
    x_msg_data               => x_msg_data);

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(' After calling private Process_MACD_Order ' || x_return_status,  1 ) ;
   END IF;


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Entering into  public Process_MACD_Order', 1 ) ;
  END IF;

  Null;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Order'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
END Process_MACD_Order;

--  performance bug 4571373, replace g_miss_line_rec
--  function with global record initialized only once

BEGIN

    G_MISS_LINE_REC.accounting_rule_id              := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.accounting_rule_duration        := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.actual_arrival_date             := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.actual_shipment_date            := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.agreement_id                    := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.arrival_set_id                  := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.ato_line_id                     := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.attribute1                      := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.attribute10                     := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.attribute11                     := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.attribute12                     := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.attribute13                     := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.attribute14                     := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.attribute15                     := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.attribute16                     := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.attribute17                     := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.attribute18                     := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.attribute19                     := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.attribute2                      := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.attribute20                     := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.attribute3                      := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.attribute4                      := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.attribute5                      := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.attribute6                      := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.attribute7                      := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.attribute8                      := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.attribute9                      := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.authorized_to_ship_flag         := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.auto_selected_quantity          := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.booked_flag                     := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.cancelled_flag                  := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.cancelled_quantity              := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.cancelled_quantity2             := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.commitment_id                   := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.component_code                  := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.component_number                := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.component_sequence_id           := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.config_header_id                := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.config_rev_nbr 	                := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.config_display_sequence         := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.configuration_id                := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.context                         := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.created_by                      := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.creation_date                   := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.credit_invoice_line_id          := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.customer_dock_code              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.customer_job                    := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.customer_production_line        := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.customer_trx_line_id            := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.cust_model_serial_number        := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.cust_po_number                  := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.cust_production_seq_num         := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.delivery_lead_time              := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.deliver_to_contact_id           := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.deliver_to_org_id               := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.demand_bucket_type_code         := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.demand_class_code               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.dep_plan_required_flag          := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.earliest_acceptable_date        := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.end_item_unit_number            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.explosion_date                  := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.fob_point_code                  := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.freight_carrier_code            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.freight_terms_code              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.fulfilled_quantity              := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.fulfilled_quantity2             := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.global_attribute1               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.global_attribute10              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.global_attribute11              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.global_attribute12              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.global_attribute13              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.global_attribute14              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.global_attribute15              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.global_attribute16              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.global_attribute17              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.global_attribute18              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.global_attribute19              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.global_attribute2               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.global_attribute20              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.global_attribute3               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.global_attribute4               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.global_attribute5               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.global_attribute6               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.global_attribute7               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.global_attribute8               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.global_attribute9               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.global_attribute_category       := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.header_id                       := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.industry_attribute1             := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute10            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute11            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute12            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute13            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute14            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute15            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute16            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute17            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute18            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute19            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute20            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute21            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute22            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute23            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute24            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute25            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute26            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute27            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute28            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute29            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute30            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute2             := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute3             := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute4             := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute5             := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute6             := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute7             := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute8             := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_attribute9             := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.industry_context                := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.TP_CONTEXT                      := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.TP_ATTRIBUTE1                   := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.TP_ATTRIBUTE2                   := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.TP_ATTRIBUTE3                   := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.TP_ATTRIBUTE4                   := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.TP_ATTRIBUTE5                   := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.TP_ATTRIBUTE6                   := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.TP_ATTRIBUTE7                   := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.TP_ATTRIBUTE8                   := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.TP_ATTRIBUTE9                   := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.TP_ATTRIBUTE10                  := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.TP_ATTRIBUTE11                  := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.TP_ATTRIBUTE12                  := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.TP_ATTRIBUTE13                  := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.TP_ATTRIBUTE14                  := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.TP_ATTRIBUTE15                  := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.intermed_ship_to_org_id         := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.intermed_ship_to_contact_id     := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.inventory_item_id               := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.invoice_interface_status_code   := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.invoice_to_contact_id           := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.invoice_to_org_id               := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.invoicing_rule_id               := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.ordered_item                    := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.item_revision                   := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.item_type_code                  := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.last_updated_by                 := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.last_update_date                := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.last_update_login               := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.latest_acceptable_date          := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.line_category_code              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.line_id                         := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.line_number                     := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.line_type_id                    := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.link_to_line_ref                := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.link_to_line_id                 := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.link_to_line_index              := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.model_group_number              := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.mfg_component_sequence_id       := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.open_flag                       := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.option_flag                     := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.option_number                   := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.ordered_quantity                := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.ordered_quantity2               := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.order_quantity_uom              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.ordered_quantity_uom2           := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.org_id                          := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.orig_sys_document_ref           := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.orig_sys_line_ref               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.over_ship_reason_code	        := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.over_ship_resolved_flag	        := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.payment_term_id                 := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.planning_priority               := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.preferred_grade                 := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.price_list_id                   := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.pricing_attribute1              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.pricing_attribute10             := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.pricing_attribute2              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.pricing_attribute3              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.pricing_attribute4              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.pricing_attribute5              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.pricing_attribute6              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.pricing_attribute7              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.pricing_attribute8              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.pricing_attribute9              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.pricing_context                 := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.pricing_date		            := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.pricing_quantity                := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.pricing_quantity_uom            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.program_application_id          := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.program_id                      := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.program_update_date             := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.project_id                      := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.promise_date                    := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.re_source_flag                  := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.reference_customer_trx_line_id  := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.reference_header_id             := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.reference_line_id               := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.reference_type                  := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.request_date                    := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.request_id                      := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.reserved_quantity               := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.return_attribute1               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.return_attribute10              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.return_attribute11              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.return_attribute12              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.return_attribute13              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.return_attribute14              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.return_attribute15              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.return_attribute2               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.return_attribute3               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.return_attribute4               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.return_attribute5               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.return_attribute6               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.return_attribute7               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.return_attribute8               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.return_attribute9               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.return_context                  := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.return_reason_code		        := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.rla_schedule_type_code          := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.salesrep_id	 	                := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.schedule_arrival_date           := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.schedule_ship_date              := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.schedule_action_code            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.schedule_status_code            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.shipment_number                 := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.shipment_priority_code          := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.shipped_quantity                := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.shipped_quantity2               := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.shipping_interfaced_flag        := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.shipping_method_code            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.shipping_quantity               := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.shipping_quantity2              := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.shipping_quantity_uom           := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.shipping_quantity_uom2          := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.ship_from_org_id                := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.ship_model_complete_flag        := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.ship_set_id                     := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.fulfillment_set_id              := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.ship_tolerance_above            := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.ship_tolerance_below            := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.ship_to_contact_id              := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.ship_to_org_id                  := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.sold_to_org_id                  := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.sold_from_org_id                := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.sort_order                      := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.source_document_id              := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.source_document_line_id         := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.source_document_type_id         := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.source_type_code                := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.split_from_line_id              := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.task_id                         := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.tax_code                        := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.tax_date                        := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.tax_exempt_flag                 := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.tax_exempt_number               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.tax_exempt_reason_code          := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.tax_point_code                  := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.tax_rate                        := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.tax_value                       := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.top_model_line_ref              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.top_model_line_id               := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.top_model_line_index            := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.unit_list_price                 := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.unit_list_price_per_pqty        := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.unit_selling_price              := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.unit_selling_price_per_pqty     := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.veh_cus_item_cum_key_id         := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.visible_demand_flag             := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.return_status                   := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.db_flag                         := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.operation                       := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.first_ack_code                  := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.first_ack_date                  := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.last_ack_code                   := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.last_ack_date                   := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.change_reason                   := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.change_comments                 := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.arrival_set	                    := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.ship_set			            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.fulfillment_set	                := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.order_source_id                 := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.orig_sys_shipment_ref	        := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.change_sequence	  	            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.change_request_code	            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.status_flag		                := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.drop_ship_flag		            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.customer_line_number            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.customer_shipment_number	    := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.customer_item_net_price	        := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.customer_payment_term_id	    := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.ordered_item_id                 := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.item_identifier_type            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.shipping_instructions	        := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.packing_instructions            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.calculate_price_flag            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.invoiced_quantity               := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.service_txn_reason_code         := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.service_txn_comments            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.service_duration                := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.service_period                  := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.service_start_date		        := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.service_end_date                := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.service_coterminate_flag        := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.unit_list_percent               := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.unit_selling_percent            := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.unit_percent_base_price         := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.service_number                  := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.service_reference_type_code     := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.service_reference_line_id       := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.service_reference_system_id     := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.service_line_index              := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.Line_set_id	                    := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.split_by                        := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.Split_Action_Code               := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.shippable_flag		            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.model_remnant_flag		        := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.flow_status_code                := 'ENTERED';
    G_MISS_LINE_REC.fulfilled_flag                  := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.fulfillment_method_code         := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.revenue_amount    		        := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.marketing_source_code_id        := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.fulfillment_date		        := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.semi_processed_flag	            := FALSE;
    G_MISS_LINE_REC.upgraded_flag                   := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.subinventory                    := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.Original_Inventory_Item_Id      := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.Original_item_identifier_Type   := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.Original_ordered_item_id        := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.Original_ordered_item           := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.item_relationship_type          := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.Item_substitution_type_code     := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.Late_Demand_Penalty_Factor      := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.Override_atp_date_code          := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.ship_to_customer_id             := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.invoice_to_customer_id          := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.deliver_to_customer_id          := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.user_item_description           := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.Blanket_Number                  := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.Blanket_Line_Number             := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.Blanket_Version_Number          := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.Minisite_Id                     := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.IB_OWNER                        := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.IB_INSTALLED_AT_LOCATION        := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.IB_CURRENT_LOCATION             := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.END_CUSTOMER_ID                 := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.END_CUSTOMER_CONTACT_ID         := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.END_CUSTOMER_SITE_USE_ID        := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.SUPPLIER_SIGNATURE              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.SUPPLIER_SIGNATURE_DATE         := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.CUSTOMER_SIGNATURE              := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.CUSTOMER_SIGNATURE_DATE         := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.unit_cost                       := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.transaction_phase_code          := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.source_document_version_number  := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.retrobill_request_id            := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.original_list_price             := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.IB_owner                        := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.IB_installed_at_location        := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.IB_current_location             := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.end_customer_id                 := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.end_customer_contact_id         := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.end_customer_site_use_id        := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.firm_demand_flag                := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.order_firmed_date  	            := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.actual_fulfillment_date         := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.charge_periodicity_code         := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.CONTINGENCY_ID  	            := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.REVREC_EVENT_CODE	            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.REVREC_EXPIRATION_DAYS	        := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.ACCEPTED_QUANTITY	            := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.REVREC_COMMENTS	                := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.REVREC_SIGNATURE	            := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.REVREC_SIGNATURE_DATE	        := FND_API.G_MISS_DATE;
    G_MISS_LINE_REC.ACCEPTED_BY 	                := FND_API.G_MISS_NUM;
    G_MISS_LINE_REC.REVREC_REFERENCE_DOCUMENT       := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.REVREC_IMPLICIT_FLAG 	        := FND_API.G_MISS_CHAR;
    G_MISS_LINE_REC.mfg_lead_time                   := FND_API.G_MISS_NUM;

    G_MISS_LINE_REC.earliest_ship_date              := FND_API.G_MISS_DATE; -- 8497317
    G_MISS_LINE_REC.price_request_code              := FND_API.G_MISS_CHAR; -- Bug 9790479

    -- For DOO/O2C Integration purpose.
    G_MISS_LINE_REC.bypass_sch_flag                 := Fnd_Api.G_Miss_Char;
    G_MISS_LINE_REC.pre_exploded_flag               := Fnd_Api.G_Miss_Char;

END OE_Order_PUB;

/
