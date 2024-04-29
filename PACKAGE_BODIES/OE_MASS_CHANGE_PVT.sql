--------------------------------------------------------
--  DDL for Package Body OE_MASS_CHANGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_MASS_CHANGE_PVT" AS
/* $Header: OEXVMSCB.pls 120.8.12010000.6 2009/04/27 12:34:14 nitagarw ship $ */

-- 4020312
g_sel_rec_tbl OE_GLOBALS.Selected_Record_Tbl;

--bug4529937 start
G_BLK_NAME        VARCHAR2(30);
G_NUM_OF_LINES    NUMBER;
G_HEADER_CHANGED  NUMBER;      --- added for  bug 6850537,7210480

Function Lines_Remaining Return Varchar2
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  IF l_debug_level > 0 THEN
     oe_debug_pub.add('In function Lines_Remaining',1);
     oe_debug_pub.add('G_BLK_NAME' || G_BLK_NAME);
     oe_debug_pub.add('G_NUM_OF_LINES' || G_NUM_OF_LINES);
  END IF;

   --Start  Bug 6850537 ,7210480

    IF G_BLK_NAME = 'LINES_SUMMARY' THEN
          IF G_NUM_OF_LINES = 0 OR G_HEADER_CHANGED =1 THEN
           IF l_debug_level>0    THEN
             oe_debug_pub.ADD('NO more lines remains or header_id has changed');
           END IF;
          RETURN('N');
        ELSE
           IF l_debug_level >0  THEN
             oe_debug_pub.ADD('There are some line remaining ');
           END IF;
          RETURN('Y');
        END IF;
    END IF;
   --End  Bug 6850537,7210480

  IF G_BLK_NAME = 'LINE' THEN
     IF G_NUM_OF_LINES = 0 THEN
	IF l_debug_level > 0 THEN
	   oe_debug_pub.add('No more lines remaining');
	END IF;
        RETURN('N');
     ELSE
	IF l_debug_level > 0 THEN
	   oe_debug_pub.add('There are some more lines remaining');
	END IF;
        RETURN('Y');
     END IF;
  ELSE
     RETURN('N');
  END IF;
END Lines_Remaining;
--bug4529937 end

--===================================================================
-- PROCEDURE: Process_Order_Scalar : Performs mass change of header attributes
-- by calling Oe_Order_Pvt.Header for every header in p_sel_rec_tbl.
--
--    Caller : OE_MASSUPDATE.UpdateOrderAttributes (OEXOELIB.pld)
-- PARAMETERS:
--  p_sel_rec_tbl - List of selected header records for mass change.

--===================================================================

Procedure Process_Order_Scalar

(   p_num_of_records       		 IN NUMBER
,   p_sel_rec_tbl                   IN Oe_Globals.Selected_Record_Tbl
,   p_multi_OU                      IN Boolean
--,   p_record_ids            		 IN VARCHAR2
,   p_change_reason                 IN VARCHAR2
,   p_change_comments               IN VARCHAR2
, p_msg_count OUT NOCOPY NUMBER
, p_msg_data OUT NOCOPY VARCHAR2
, p_return_status OUT NOCOPY VARCHAR2
,   p_mc_err_handling_flag  		 IN NUMBER DEFAULT  FND_API.G_MISS_NUM
, p_error_count OUT NOCOPY NUMBER
,   p_accounting_rule_id            IN NUMBER
,   p_accounting_rule_duration      IN NUMBER
,   p_agreement_id                  IN NUMBER
,   p_attribute1                    IN VARCHAR2
,   p_attribute10                   IN VARCHAR2
,   p_attribute11                   IN VARCHAR2
,   p_attribute12                   IN VARCHAR2
,   p_attribute13                   IN VARCHAR2
,   p_attribute14                   IN VARCHAR2
,   p_attribute15                   IN VARCHAR2
,   p_attribute16                   IN VARCHAR2   --For bug 2184255
,   p_attribute17                   IN VARCHAR2
,   p_attribute18                   IN VARCHAR2
,   p_attribute19                   IN VARCHAR2
,   p_attribute2                    IN VARCHAR2
,   p_attribute20                   IN VARCHAR2
,   p_attribute3                    IN VARCHAR2
,   p_attribute4                    IN VARCHAR2
,   p_attribute5                    IN VARCHAR2
,   p_attribute6                    IN VARCHAR2
,   p_attribute7                    IN VARCHAR2
,   p_attribute8                    IN VARCHAR2
,   p_attribute9                    IN VARCHAR2
,   p_blanket_number                IN NUMBER
,   p_context                       IN VARCHAR2
,   p_conversion_rate               IN NUMBER
,   p_conversion_rate_date          IN DATE
,   p_conversion_type_code          IN VARCHAR2
,   p_cust_po_number                IN VARCHAR2
,   p_deliver_to_contact_id         IN NUMBER
,   p_deliver_to_org_id             IN NUMBER
,   p_demand_class_code             IN VARCHAR2
,   p_expiration_date               IN DATE
,   p_earliest_schedule_limit       IN NUMBER
,   p_fob_point_code                IN VARCHAR2
,   p_freight_carrier_code          IN VARCHAR2
,   p_freight_terms_code            IN VARCHAR2
,   p_global_attribute1             IN VARCHAR2
,   p_global_attribute10            IN VARCHAR2
,   p_global_attribute11            IN VARCHAR2
,   p_global_attribute12            IN VARCHAR2
,   p_global_attribute13            IN VARCHAR2
,   p_global_attribute14            IN VARCHAR2
,   p_global_attribute15            IN VARCHAR2
,   p_global_attribute16            IN VARCHAR2
,   p_global_attribute17            IN VARCHAR2
,   p_global_attribute18            IN VARCHAR2
,   p_global_attribute19            IN VARCHAR2
,   p_global_attribute2             IN VARCHAR2
,   p_global_attribute20            IN VARCHAR2
,   p_global_attribute3             IN VARCHAR2
,   p_global_attribute4             IN VARCHAR2
,   p_global_attribute5             IN VARCHAR2
,   p_global_attribute6             IN VARCHAR2
,   p_global_attribute7             IN VARCHAR2
,   p_global_attribute8             IN VARCHAR2
,   p_global_attribute9             IN VARCHAR2
,   p_global_attribute_category     IN VARCHAR2
,   p_header_id                     IN NUMBER
,   p_invoice_to_contact_id         IN NUMBER
,   p_invoice_to_org_id             IN NUMBER
,   p_invoicing_rule_id             IN NUMBER
,   p_latest_schedule_limit         IN NUMBER
,   p_ordered_date                  IN DATE
,   p_order_date_type_code          IN VARCHAR2
,   p_order_number                  IN NUMBER
,   p_order_source_id               IN NUMBER
,   p_order_type_id                 IN NUMBER
,   p_org_id                        IN NUMBER
,   p_orig_sys_document_ref         IN VARCHAR2
,   p_partial_shipments_allowed     IN VARCHAR2
,   p_payment_term_id               IN NUMBER
,   p_price_list_id                 IN NUMBER
,   p_pricing_date                  IN DATE
,   p_request_date                  IN DATE
,   p_shipment_priority_code        IN VARCHAR2
,   p_shipping_method_code          IN VARCHAR2
,   p_ship_from_org_id              IN NUMBER
,   p_ship_tolerance_above          IN NUMBER
,   p_ship_tolerance_below          IN NUMBER
,   p_ship_to_contact_id            IN NUMBER
,   p_ship_to_org_id                IN NUMBER
,   p_sold_to_contact_id            IN NUMBER
,   p_sold_to_org_id                IN NUMBER
,   p_source_document_id            IN NUMBER
,   p_source_document_type_id       IN NUMBER
,   p_tax_exempt_flag               IN VARCHAR2
,   p_tax_exempt_number             IN VARCHAR2
,   p_tax_exempt_reason_code        IN VARCHAR2
,   p_tax_point_code                IN VARCHAR2
,   p_transactional_curr_code       IN VARCHAR2
,   p_version_number                IN NUMBER
,   p_accounting_rule               IN VARCHAR2
,   p_agreement                     IN VARCHAR2
,   p_conversion_type               IN VARCHAR2
,   p_deliver_to_address1           IN VARCHAR2
,   p_deliver_to_address2           IN VARCHAR2
,   p_deliver_to_address3           IN VARCHAR2
,   p_deliver_to_address4           IN VARCHAR2
,   p_deliver_to_contact            IN VARCHAR2
,   p_deliver_to_location           IN VARCHAR2
,   p_deliver_to_org                IN VARCHAR2
,   p_fob_point                     IN VARCHAR2
,   p_freight_terms                 IN VARCHAR2
,   p_invoice_to_address1           IN VARCHAR2
,   p_invoice_to_address2           IN VARCHAR2
,   p_invoice_to_address3           IN VARCHAR2
,   p_invoice_to_address4           IN VARCHAR2
,   p_invoice_to_contact            IN VARCHAR2
,   p_invoice_to_location           IN VARCHAR2
,   p_invoice_to_org                IN VARCHAR2
,   p_invoicing_rule                IN VARCHAR2
,   p_order_source                  IN VARCHAR2
,   p_order_type                    IN VARCHAR2
,   p_payment_term                  IN VARCHAR2
,   p_price_list                    IN VARCHAR2
,   p_shipment_priority             IN VARCHAR2
,   p_ship_from_address1            IN VARCHAR2
,   p_ship_from_address2            IN VARCHAR2
,   p_ship_from_address3            IN VARCHAR2
,   p_ship_from_address4            IN VARCHAR2
,   p_ship_from_location            IN VARCHAR2
,   p_ship_from_org                 IN VARCHAR2
,   p_ship_to_address1              IN VARCHAR2
,   p_ship_to_address2              IN VARCHAR2
,   p_ship_to_address3              IN VARCHAR2
,   p_ship_to_address4              IN VARCHAR2
,   p_ship_to_contact               IN VARCHAR2
,   p_ship_to_location              IN VARCHAR2
,   p_ship_to_org                   IN VARCHAR2
,   p_sold_to_contact               IN VARCHAR2
,   p_sold_to_org                   IN VARCHAR2
,   p_tax_exempt                    IN VARCHAR2
,   p_tax_exempt_reason             IN VARCHAR2
,   p_tax_point                     IN VARCHAR2
,   p_salesrep_id                   IN NUMBER
,   p_return_reason_code            IN VARCHAR2
,   p_salesrep                      IN VARCHAR2
,   p_return_reason                 IN VARCHAR2
,   p_payment_type_code             IN VARCHAR2
,   p_payment_amount                IN NUMBER
,   p_check_number                  IN VARCHAR2
,   p_credit_card_code              IN VARCHAR2
,   p_credit_card_holder_name       IN VARCHAR2
,   p_credit_card_number            IN VARCHAR2
,   p_instrument_security_code      IN VARCHAR2  --bug 5191301
,   p_credit_card_expiration_date   IN DATE
,   p_credit_card_approval_date     IN DATE
,   p_credit_card_approval_code     IN VARCHAR2
,   p_payment_type                  IN VARCHAR2
,   p_credit_card                   IN VARCHAR2
,   p_first_ack_code                IN VARCHAR2
,   p_first_ack_date                IN DATE
,   p_last_ack_code                 IN VARCHAR2
,   p_last_ack_date                 IN DATE
,   p_tp_attribute1                    IN VARCHAR2
,   p_tp_attribute10                   IN VARCHAR2
,   p_tp_attribute11                   IN VARCHAR2
,   p_tp_attribute12                   IN VARCHAR2
,   p_tp_attribute13                   IN VARCHAR2
,   p_tp_attribute14                   IN VARCHAR2
,   p_tp_attribute15                   IN VARCHAR2
,   p_tp_attribute2                    IN VARCHAR2
,   p_tp_attribute3                    IN VARCHAR2
,   p_tp_attribute4                    IN VARCHAR2
,   p_tp_attribute5                    IN VARCHAR2
,   p_tp_attribute6                    IN VARCHAR2
,   p_tp_attribute7                    IN VARCHAR2
,   p_tp_attribute8                    IN VARCHAR2
,   p_tp_attribute9                    IN VARCHAR2
,   p_tp_context                       IN VARCHAR2
,   p_shipping_instructions            IN VARCHAR2
,   p_packing_instructions             IN VARCHAR2
,   p_sales_channel_code               IN VARCHAR2
--My Addition
,   p_sold_to_address1                 IN VARCHAR2
,   p_sold_to_address2                 IN VARCHAR2
,   p_sold_to_address3                 IN VARCHAR2
,   p_sold_to_address4                 IN VARCHAR2
,   p_sold_to_location                 IN VARCHAR2
,   p_sold_to_site_use_id              IN NUMBER
--end custoemr chagnes
,   p_end_customer_contact_id          IN NUMBER
,   p_end_customer_id                  IN NUMBER
,   p_end_customer_site_use_id         IN NUMBER
,   p_end_customer_address1            IN VARCHAR2
,   p_end_customer_address2            IN VARCHAR2
,   p_end_customer_address3            IN VARCHAR2
,   p_end_customer_address4            IN VARCHAR2
,   p_end_customer_contact             IN VARCHAR2
,   p_end_customer_location            IN VARCHAR2
,   p_ib_owner                         IN VARCHAR2
,   p_ib_installed_at_location         IN VARCHAR2
,   p_ib_current_location              IN VARCHAR2
,   p_cascade_header_changes           IN VARCHAR2 -- Added for Cascade Header changes in Mass Change  ER 7509356


) IS
l_header_rec                OE_Order_PUB.Header_Rec_Type;
l_old_header_rec            OE_Order_PUB.Header_Rec_Type;
l_control_rec               OE_GLOBALS.Control_Rec_Type;
l_x_header_rec              OE_Order_PUB.Header_Rec_Type;
l_mc_err_handling_flag      NUMBER  := p_mc_err_handling_flag ;
l_init_msg_list             VARCHAR2(1) := 'F';
l_return_status             VARCHAR2(30);
l_api_name         CONSTANT VARCHAR2(30)         := 'Process_Order_Scalar';
l_line_id         Number;
l_header_id         Number;
l_sold_to_org_id NUMBER := p_sold_to_org_id;
l_ship_to_org_id NUMBER := p_ship_to_org_id;
l_error_count   NUMBER :=0;
l_line_tbl oe_order_pub.line_tbl_type;

j Integer;
initial Integer;
nextpos Integer;
l_current_org_id    Number;
begin
/*j := 1;
initial := 1;
nextpos := INSTR(p_record_ids,',',1,j) ;
*/
OE_MSG_PUB.initialize;
--MOAC PI
 IS_MASS_CHANGE := 'T'; -- Added for cascading header changes ER 7509356
FOR i IN p_sel_rec_tbl.first..p_sel_rec_tbl.last LOOP
--{
 BEGIN
     l_header_id := p_sel_rec_tbl(i).id1;
     If p_multi_OU Then
        If l_Current_org_id Is Null or l_current_org_id<> p_sel_rec_tbl(i).org_id THEN
           MO_GLOBAL.SET_POLICY_CONTEXT('S',p_sel_rec_tbl(i).org_id);
	   OE_Order_Cache.Clear_Price_List(); --Added to clear price-list cache when there is org change (Bug # 5168409)
           L_current_org_id:= p_sel_rec_tbl(i).org_id;
        End If;
     Else
        If i = 1 Then
           MO_GLOBAL.SET_POLICY_CONTEXT('S',p_sel_rec_tbl(i).org_id);
        End If;
     End If;
    --MOAC PI
   G_COUNTER:=G_COUNTER+1;
 --dbms_output.put_line('ini='||to_char(initial)||'next='||to_char(nextpos));
   l_header_rec := OE_Order_PUB.G_MISS_HEADER_REC;
   l_old_header_rec := OE_Order_PUB.G_MISS_HEADER_REC;
 --  l_header_id := to_number(substr(p_record_ids,initial, nextpos-initial));
   --dbms_output.put_line('id='||to_char(l_header_id));
--   initial := nextpos + 1;
 /*  j := j + 1;
   nextpos := INSTR(p_record_ids,',',1,j);
 */
   l_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
   l_header_rec.header_id := l_header_id;
--   l_old_header_rec.header_id := l_header_id;

   SAVEPOINT Process_Order_Scalar;
   OE_Header_Util.Lock_Row
    (   x_return_status        => l_return_status
    ,   p_x_header_rec         => l_x_header_rec
    ,   p_header_id            => l_header_id);

     IF l_return_status  = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;




   if p_accounting_rule_id is not null then
     l_header_rec.accounting_rule_id:=p_accounting_rule_id;
   end if;

   if p_accounting_rule_duration is not null then
     l_header_rec.accounting_rule_duration:=p_accounting_rule_duration;
   end if;

   if p_agreement_id is not null then
     l_header_rec.agreement_id:=p_agreement_id;
   end if;

   if p_attribute1 is not null then
     l_header_rec.attribute1:=p_attribute1;
   end if;

   if p_attribute10 is not null then
     l_header_rec.attribute10:=p_attribute10;
   end if;

   if p_attribute11 is not null then
     l_header_rec.attribute11:=p_attribute11;
   end if;

   if p_attribute12 is not null then
     l_header_rec.attribute12:=p_attribute12;
   end if;

   if p_attribute13 is not null then
     l_header_rec.attribute13:=p_attribute13;
   end if;

   if p_attribute14 is not null then
     l_header_rec.attribute14:=p_attribute14;
   end if;

   if p_attribute15 is not null then
     l_header_rec.attribute15:=p_attribute15;
   end if;

-- for bug 2184255
   if p_attribute16 is not null then
     l_header_rec.attribute16:=p_attribute16;
   end if;

   if p_attribute17 is not null then
     l_header_rec.attribute17:=p_attribute17;
   end if;

   if p_attribute18 is not null then
     l_header_rec.attribute18:=p_attribute18;
   end if;

   if p_attribute19 is not null then
     l_header_rec.attribute19:=p_attribute19;
   end if;

   if p_attribute2 is not null then
     l_header_rec.attribute2:=p_attribute2;
   end if;

   if p_attribute20 is not null then
     l_header_rec.attribute20:=p_attribute20;
   end if;

   if p_attribute3 is not null then
     l_header_rec.attribute3:=p_attribute3;
   end if;

   if p_attribute4 is not null then
     l_header_rec.attribute4:=p_attribute4;
   end if;

   if p_attribute5 is not null then
     l_header_rec.attribute5:=p_attribute5;
   end if;

   if p_attribute6 is not null then
     l_header_rec.attribute6:=p_attribute6;
   end if;

   if p_attribute7 is not null then
     l_header_rec.attribute7:=p_attribute7;
   end if;

   if p_attribute8 is not null then
     l_header_rec.attribute8:=p_attribute8;
   end if;

   if p_attribute9 is not null then
     l_header_rec.attribute9:=p_attribute9;
   end if;

   IF p_blanket_number is not null THEN
     l_header_rec.blanket_number:=p_blanket_number;
   END IF;

   if p_context is not null then
     l_header_rec.context:=p_context;
   end if;

   if p_conversion_rate_date is not null then
     l_header_rec.conversion_rate_date:=p_conversion_rate_date;
   end if;

   if p_conversion_rate is not null then
     l_header_rec.conversion_rate:=p_conversion_rate;
   end if;

   if p_conversion_type_code is not null then
     l_header_rec.conversion_type_code:=p_conversion_type_code;
   end if;

   if p_sales_Channel_Code is not null then
     l_header_rec.sales_channel_code:=p_sales_channel_code;
   end if;

   if p_shipping_instructions is not null then
     l_header_rec.shipping_instructions:=p_shipping_instructions;
   end if;

   if p_packing_instructions is not null then
     l_header_rec.packing_instructions:=p_packing_instructions;
   end if;

   if p_cust_po_number is not null then
     l_header_rec.cust_po_number:=p_cust_po_number;
   end if;

   if p_deliver_to_contact_id is not null then
     l_header_rec.deliver_to_contact_id:=p_deliver_to_contact_id;
   end if;

   if p_deliver_to_org_id is not null then
     l_header_rec.deliver_to_org_id:=p_deliver_to_org_id;
   end if;

   if p_demand_class_code is not null then
     l_header_rec.demand_class_code:=p_demand_class_code;
   end if;

   if p_expiration_date is not null then
     l_header_rec.expiration_date:=p_expiration_date;
   end if;

   if p_earliest_schedule_limit is not null then
     l_header_rec.earliest_schedule_limit:=p_earliest_schedule_limit;
   end if;

   if p_fob_point_code is not null then
     l_header_rec.fob_point_code:=p_fob_point_code;
   end if;

   if p_freight_carrier_code is not null then
     l_header_rec.freight_carrier_code:=p_freight_carrier_code;
   end if;

   if p_freight_terms_code is not null then
     l_header_rec.freight_terms_code:=p_freight_terms_code;
   end if;

   if p_global_attribute1 is not null then
     l_header_rec.global_attribute1:=p_global_attribute1;
   end if;

   if p_global_attribute10 is not null then
     l_header_rec.global_attribute10:=p_global_attribute10;
   end if;

   if p_global_attribute11 is not null then
     l_header_rec.global_attribute11:=p_global_attribute11;
   end if;


   if p_global_attribute12 is not null then
     l_header_rec.global_attribute12:=p_global_attribute12;
   end if;

   if p_global_attribute13 is not null then
     l_header_rec.global_attribute13:=p_global_attribute13;
   end if;

   if p_global_attribute14 is not null then
     l_header_rec.global_attribute14:=p_global_attribute14;
   end if;

   if p_global_attribute15 is not null then
     l_header_rec.global_attribute15:=p_global_attribute15;
   end if;

   if p_global_attribute16 is not null then
     l_header_rec.global_attribute16:=p_global_attribute16;
   end if;

   if p_global_attribute17 is not null then
     l_header_rec.global_attribute17:=p_global_attribute17;
   end if;

   if p_global_attribute18 is not null then
     l_header_rec.global_attribute18:=p_global_attribute18;
   end if;

   if p_global_attribute19 is not null then
     l_header_rec.global_attribute19:=p_global_attribute19;
   end if;

   if p_global_attribute20 is not null then
     l_header_rec.global_attribute20:=p_global_attribute20;
   end if;

   if p_global_attribute2 is not null then
     l_header_rec.global_attribute2:=p_global_attribute2;
   end if;

   if p_global_attribute3 is not null then
     l_header_rec.global_attribute3:=p_global_attribute3;
   end if;

   if p_global_attribute4 is not null then
     l_header_rec.global_attribute4:=p_global_attribute4;
   end if;

   if p_global_attribute5 is not null then
     l_header_rec.global_attribute5:=p_global_attribute5;
   end if;

   if p_global_attribute6 is not null then
     l_header_rec.global_attribute6:=p_global_attribute6;
   end if;

   if p_global_attribute7 is not null then
     l_header_rec.global_attribute7:=p_global_attribute7;
   end if;

   if p_global_attribute8 is not null then
     l_header_rec.global_attribute8:=p_global_attribute8;
   end if;

   if p_global_attribute9 is not null then
     l_header_rec.global_attribute9:=p_global_attribute9;
   end if;

   if p_global_attribute_category is not null then
     l_header_rec.global_attribute_category:=p_global_attribute_category;
   end if;

   if p_header_id is not null then
     l_header_rec.header_id:=p_header_id;
   end if;

   if p_invoice_to_contact_id  is not null then
     l_header_rec.invoice_to_contact_id :=p_invoice_to_contact_id ;
   end if;

   if p_invoice_to_org_id is not null then
     l_header_rec.invoice_to_org_id:=p_invoice_to_org_id;
   end if;

   if p_invoicing_rule_id is not null then
	l_header_rec.invoicing_rule_id:=p_invoicing_rule_id;
   end if;

   if p_latest_schedule_limit  is not null then
     l_header_rec.latest_schedule_limit:=p_latest_schedule_limit;
   end if;

   if p_ordered_date is not null then
     l_header_rec.ordered_date:=p_ordered_date;
   end if;

   if p_order_date_type_code is not null then
	l_header_rec.order_date_type_code:=p_order_date_type_code;
   end if;

   if p_order_number is not null then
	l_header_rec.order_number:=p_order_number;
   end if;

   if p_order_source_id  is not null then
     l_header_rec.order_source_id:=p_order_source_id;
   end if;

   if p_order_type_id is not null then
     l_header_rec.order_type_id:=p_order_type_id;
   end if;

   if  p_org_id is not null then
	l_header_rec.org_id:= p_org_id ;
   end if;

   if p_orig_sys_document_ref is not null then
	l_header_rec.orig_sys_document_ref:=p_orig_sys_document_ref;
   end if;

   if p_partial_shipments_allowed  is not null then
     l_header_rec.partial_shipments_allowed:=p_partial_shipments_allowed;
   end if;

   if p_payment_term_id is not null then
     l_header_rec.payment_term_id:=p_payment_term_id;
   end if;

   if  p_price_list_id is not null then
	l_header_rec.price_list_id:=p_price_list_id;
   end if;

   if p_pricing_date  is not null then
     l_header_rec.pricing_date:=p_pricing_date;
   end if;

   if p_request_date is not null then
     l_header_rec.request_date:=p_request_date;
   end if;

   if  p_shipment_priority_code is not null then
	l_header_rec.shipment_priority_code:=p_shipment_priority_code;
   end if;

   if p_shipping_method_code  is not null then
     l_header_rec.shipping_method_code:=p_shipping_method_code;
   end if;

   if p_ship_from_org_id is not null then
     l_header_rec.ship_from_org_id:=p_ship_from_org_id;
   end if;

   if   p_ship_tolerance_above is not null then
	l_header_rec.ship_tolerance_above:= p_ship_tolerance_above;
   end if;

   if   p_ship_tolerance_below is not null then
	l_header_rec.ship_tolerance_below:= p_ship_tolerance_below;
   end if;

   if p_ship_to_contact_id   is not null then
     l_header_rec.ship_to_contact_id :=p_ship_to_contact_id ;
   end if;

   if p_ship_to_org_id is not null then
     l_header_rec.ship_to_org_id:=p_ship_to_org_id;
   end if;

   if   p_sold_to_contact_id is not null then
	l_header_rec.sold_to_contact_id:=p_sold_to_contact_id;
   end if;

   if   p_sold_to_org_id  is not null then
	l_header_rec.sold_to_org_id :=p_sold_to_org_id;
   end if;

   if p_source_document_id   is not null then
     l_header_rec.source_document_id:=p_source_document_id;
   end if;

   if p_source_document_type_id is not null then
     l_header_rec.source_document_type_id:=p_source_document_type_id;
   end if;

   if   p_tax_exempt_flag is not null then
	l_header_rec.tax_exempt_flag:=p_tax_exempt_flag;
   end if;

   if   p_tax_exempt_number  is not null then
	l_header_rec.tax_exempt_number:=p_tax_exempt_number;
   end if;

   if p_tax_exempt_reason_code   is not null then
     l_header_rec.tax_exempt_reason_code:=p_tax_exempt_reason_code;
   end if;

   if p_tax_point_code is not null then
     l_header_rec.tax_point_code:=p_tax_point_code;
   end if;

   if p_transactional_curr_code is not null then
	l_header_rec.transactional_curr_code:=p_transactional_curr_code;
   end if;

   if  p_version_number  is not null then
	l_header_rec.version_number:=p_version_number;
   end if;

   if p_salesrep_id is not null then
     l_header_rec.salesrep_id:=p_salesrep_id;
   end if;

   if p_return_reason_code is not null then
	l_header_rec.return_reason_code:=p_return_reason_code;
   end if;

   if  p_version_number  is not null then
	l_header_rec.version_number:=p_version_number;
   end if;

   if p_payment_type_code is not null then
     l_header_rec.payment_type_code:=p_payment_type_code;
   end if;

   if p_payment_amount is not null then
	l_header_rec.payment_amount:=p_payment_amount;
   end if;

   if  p_check_number  is not null then
	l_header_rec.check_number:=p_check_number;
   end if;

   if p_credit_card_code is not null then
     l_header_rec.credit_card_code:=p_credit_card_code;
   end if;

   if p_credit_card_holder_name is not null then
	l_header_rec.credit_card_holder_name:=p_credit_card_holder_name;
   end if;

   if  p_credit_card_number  is not null then
	l_header_rec.credit_card_number:=p_credit_card_number;
   end if;

   --bug 5191301
   if p_instrument_security_code is not null then
      l_header_rec.instrument_security_code := p_instrument_security_code;
   end if;
   --bug 5191301

   if p_credit_card_expiration_date is not null then
     l_header_rec.credit_card_expiration_date:=p_credit_card_expiration_date;
   end if;

   if p_credit_card_approval_date is not null then
     l_header_rec.credit_card_approval_date :=p_credit_card_approval_date;
   end if;

   if p_credit_card_approval_code is not null then
	l_header_rec.credit_card_approval_code:=p_credit_card_approval_code;
   end if;

   if p_credit_card_approval_code is not null then
	l_header_rec.credit_card_approval_code:=p_credit_card_approval_code;
   end if;

   if  p_first_ack_code  is not null then
	l_header_rec.first_ack_code:=p_first_ack_code;
   end if;

   if  p_first_ack_date  is not null then
	l_header_rec.first_ack_date:=p_first_ack_date;
   end if;

   if  p_last_ack_code  is not null then
	l_header_rec.last_ack_code:=p_last_ack_code;
   end if;

   if  p_last_ack_date  is not null then
	l_header_rec.last_ack_date:=p_last_ack_date;
   end if;

   if p_tp_context is not null then
     l_header_rec.tp_context:=p_tp_context;
   end if;

   if p_tp_attribute1 is not null then
     l_header_rec.tp_attribute1:=p_tp_attribute1;
   end if;

   if p_tp_attribute2 is not null then
     l_header_rec.tp_attribute2:=p_tp_attribute2;
   end if;

   if p_tp_attribute3 is not null then
     l_header_rec.tp_attribute3:=p_tp_attribute3;
   end if;

   if p_tp_attribute4 is not null then
     l_header_rec.tp_attribute4:=p_tp_attribute4;
   end if;

   if p_tp_attribute5 is not null then
     l_header_rec.tp_attribute5:=p_tp_attribute5;
   end if;

   if p_tp_attribute6 is not null then
     l_header_rec.tp_attribute6:=p_tp_attribute6;
   end if;

   if p_tp_attribute7 is not null then
     l_header_rec.tp_attribute7:=p_tp_attribute7;
   end if;

   if p_tp_attribute8 is not null then
     l_header_rec.tp_attribute8:=p_tp_attribute8;
   end if;

   if p_tp_attribute9 is not null then
     l_header_rec.tp_attribute9:=p_tp_attribute9;
   end if;

   if p_tp_attribute10 is not null then
     l_header_rec.tp_attribute10:=p_tp_attribute10;
   end if;

   if p_tp_attribute11 is not null then
     l_header_rec.tp_attribute11:=p_tp_attribute11;
   end if;

   if p_tp_attribute12 is not null then
     l_header_rec.tp_attribute12:=p_tp_attribute12;
   end if;

   if p_tp_attribute13 is not null then
     l_header_rec.tp_attribute13:=p_tp_attribute13;
   end if;

   if p_tp_attribute14 is not null then
     l_header_rec.tp_attribute14:=p_tp_attribute14;
   end if;

   if p_tp_attribute15 is not null then
     l_header_rec.tp_attribute15:=p_tp_attribute15;
   end if;

  --My Addition
   if p_sold_to_site_use_id is not null then
     l_header_rec.sold_to_site_use_id:=p_sold_to_site_use_id;
   end if;

   /* Start Audit Trail */
   if p_change_reason is not null then
     l_header_rec.change_reason := p_change_reason;
   end if;

   if p_change_comments is not null then
     l_header_rec.change_comments := p_change_comments;
   end if;
   /* End Audit Trail */

   /*End Customer Changes */
   if p_end_customer_contact_id  is not null then
      l_header_rec.end_customer_contact_id := p_end_customer_contact_id;
   end if;
   if p_end_customer_id is not null then
      l_header_rec.end_customer_id := p_end_customer_id;
   end if;
   if   p_end_customer_site_use_id is not null then
      l_header_rec.end_customer_site_use_id := p_end_customer_site_use_id;
   end if;
  if  p_ib_owner is not null then
      l_header_rec.ib_owner := p_ib_owner;
      end if;
  if  p_ib_installed_at_location  is not null then
     l_header_rec.ib_installed_at_location := p_ib_installed_at_location;
     end if;
  if  p_ib_current_location  is not null then
     l_header_rec.ib_current_location := p_ib_current_location;
     end if;


   l_control_rec.controlled_operation:=TRUE;
   l_control_rec.process:=FALSE;
   l_control_rec.process_entity:=OE_GLOBALS.G_ENTITY_ALL;

   --added for bug 4882981
   l_control_rec.check_security       := TRUE;
   l_control_rec.clear_dependents     := TRUE;
   l_control_rec.default_attributes   := TRUE;
   l_control_rec.change_attributes    := TRUE;
   l_control_rec.validate_entity      := TRUE;
   l_control_rec.write_to_DB          := TRUE;
   --End of bug 4882981

   Oe_Order_Pvt.Header
    (
        p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_init_msg_list               => l_init_msg_list
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                => l_header_rec
    ,   p_x_old_header_rec            => l_old_header_rec
    ,   x_return_status               => l_return_status
    );


     p_return_status := l_return_status;
     OE_DEBUG_PUB.Add('return_status='||l_return_status);
     if l_return_status in(FND_API.G_RET_STS_ERROR,
					  FND_API.G_RET_STS_UNEXP_ERROR) then
	  ROLLBACK TO SAVEPOINT Process_Order_Scalar;
	  G_ERROR_COUNT := G_ERROR_COUNT + 1;

         l_error_count := l_error_count + 1;
         p_error_count := l_error_count;
         OE_MSG_PUB.Count_And_Get
            ( p_count => p_msg_count,
              p_data  => p_msg_data
            );
      if l_mc_err_handling_flag in (EXIT_FIRST_ERROR,SKIP_CONTINUE) then
          OE_DEBUG_PUB.Add('EXIT_FIRST_ERROR  SKIP_CONTINUE');
          exit;
      else
               OE_DEBUG_PUB.Add('SKIP_ALL');
      end if;

     end if;
 -- loop exception handling
 Exception
    WHEN FND_API.G_EXC_ERROR THEN
        p_return_status := FND_API.G_RET_STS_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => p_msg_count,
              p_data  => p_msg_data
            );
        l_error_count := l_error_count + 1;
        p_error_count := l_error_count;

       G_ERROR_COUNT := G_ERROR_COUNT + 1;
       ROLLBACK TO SAVEPOINT Process_Order_Scalar;

     if l_mc_err_handling_flag in (EXIT_FIRST_ERROR,SKIP_CONTINUE) then
                exit;
        end if;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => p_msg_count,
              p_data  => p_msg_data
            );
        l_error_count := l_error_count + 1;
        p_error_count := l_error_count;

       G_ERROR_COUNT := G_ERROR_COUNT + 1;
       ROLLBACK TO SAVEPOINT Process_Order_Scalar;

     if l_mc_err_handling_flag in (EXIT_FIRST_ERROR,SKIP_CONTINUE) then
                exit;
     end if;


   WHEN OTHERS THEN
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF OE_MSG_PUB.Check_Msg_Level
            (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
  OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,l_api_name
                );
        END IF;
        OE_MSG_PUB.Count_And_Get
            ( p_count => p_msg_count,
              p_data  => p_msg_data);
        l_error_count := l_error_count + 1;
        p_error_count := l_error_count;

       G_ERROR_COUNT := G_ERROR_COUNT + 1;
       ROLLBACK TO SAVEPOINT Process_Order_Scalar;

     if l_mc_err_handling_flag in (EXIT_FIRST_ERROR,SKIP_CONTINUE) then
                exit;
        end if;

END;

--End LOOP; /* end of FOR loop */
  -- moved execution of delayed request inside the for loop for bug 4882981
 IF p_return_status = FND_API.G_RET_STS_SUCCESS THEN
 --{ SUCCESS from OE_ORDER_PVT.Header
 BEGIN
  -- call to post_line_process is not needed for headers mass change
  /*

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_ALL;

    l_control_rec.check_security       := FALSE;
    l_control_rec.clear_dependents     := FALSE;
    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := TRUE;

     oe_line_util.Post_Line_Process
    (   p_control_rec    => l_control_rec
    ,   p_x_line_tbl   => l_line_tbl );

    */

    --added call to PRN for bug 4882981
	 OE_Order_PVT.Process_Requests_And_Notify
            ( p_process_requests          => TRUE
            , p_notify                    => TRUE
            , x_return_status             => l_return_status
	    , p_old_header_rec		  => l_old_header_rec
	    , p_header_rec		  => l_header_rec );


     /*
     OE_DELAYED_REQUESTS_PVT.Process_Delayed_Requests(
                                             x_return_status => l_return_status
                                              );

					      */
       oe_debug_pub.ADD('OEXVMSCB: Completed Process_Delayed_Requests '
                    || ' with return status' || l_return_status, 1);

	oe_debug_pub.add('calling count and get to display errors');

       -- Bug 1809955
       -- Display any errors/messages that were caused
       -- as a result of the delayed request execution
       OE_MSG_PUB.Count_and_Get(
				p_count => p_msg_count,
				p_data => p_msg_data
				);

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;


     oe_debug_pub.add('p_cascade_header_changes' || p_cascade_header_changes);
--   Begin of Cascade Header changes in Mass Change ER 7509356
     IF p_cascade_header_changes = 'Y' THEN
     --{
     oe_debug_pub.add('Just before calling cascade_header_attributes from process_order_scalar for header_id :' || l_header_rec.header_id);

     OE_OE_FORM_HEADER.CASCADE_HEADER_ATTRIBUTES
                      (
                        p_old_db_header_rec      => l_old_header_rec
                       ,p_header_rec             => l_header_rec
                       ,x_return_status          => l_return_status
                       ,x_msg_count              => p_msg_count
                       ,x_msg_data               => p_msg_data
                      );

     oe_debug_pub.add('return_status from cascade_header_attributes '|| l_return_status);
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;
       --}
       END IF;
--   End  of Cascade Header changes in Mass Change ER 7509356



EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         l_error_count := l_error_count + 1;
         p_error_count := l_error_count;
       p_return_status := FND_API.G_RET_STS_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => p_msg_count,
              p_data  => p_msg_data
            );
       l_error_count := l_error_count + 1;
       p_error_count := l_error_count;

       G_ERROR_COUNT := G_ERROR_COUNT + 1;
       ROLLBACK TO SAVEPOINT Process_Order_Scalar;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         l_error_count := l_error_count + 1;
         p_error_count := l_error_count;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => p_msg_count,
              p_data  => p_msg_data
           );
      l_error_count := l_error_count + 1;
      p_error_count := l_error_count;

       G_ERROR_COUNT := G_ERROR_COUNT + 1;
       ROLLBACK TO SAVEPOINT Process_Order_Scalar;

    WHEN OTHERS THEN
         l_error_count := l_error_count + 1;
         p_error_count := l_error_count;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF OE_MSG_PUB.Check_Msg_Level
            (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
             OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                );
        END IF;
        OE_MSG_PUB.Count_And_Get
            ( p_count => p_msg_count,
              p_data  => p_msg_data);
         l_error_count := l_error_count + 1;
        p_error_count := l_error_count;

       G_ERROR_COUNT := G_ERROR_COUNT + 1;
       ROLLBACK TO SAVEPOINT Process_Order_Scalar;

END ;

--} SUCCESS from OE_ORDER_PVT.Header
END IF;
--}
END LOOP ; /* end for loop */  -- end bug 4882981
 IS_MASS_CHANGE := 'F'; -- Added for ER 7509356
end Process_Order_Scalar;

-- 4020312
-- Process_Line_Scalar has been changed to group lines together before calling
-- OE_ORDER_PVT.Lines so that lines belonging together like models and sets go
-- for processing at one go.
Procedure Process_Line_Scalar
(   p_num_of_records                IN NUMBER
,   p_sel_rec_tbl                   IN Oe_Globals.Selected_Record_Tbl --MOAC PI
,   p_multi_OU                      IN Boolean --MOAC PI
,   p_change_reason                 IN VARCHAR2
,   p_change_comments               IN VARCHAR2
,   p_msg_count                     OUT NOCOPY NUMBER
,   p_msg_data                      OUT NOCOPY VARCHAR2
,   p_return_status                 OUT NOCOPY VARCHAR2
,   p_mc_err_handling_flag          IN NUMBER := FND_API.G_MISS_NUM
,   p_error_count                   OUT NOCOPY NUMBER
,   p_header_id                     IN  NUMBER
,   p_accounting_rule_id            IN NUMBER
,   p_accounting_rule_duration      IN NUMBER
,   p_actual_arrival_date           IN DATE
,   p_actual_shipment_date          IN DATE
,   p_agreement_id                  IN NUMBER
,   p_ato_line_id                   IN NUMBER
,   p_attribute1                    IN VARCHAR2
,   p_attribute10                   IN VARCHAR2
,   p_attribute11                   IN VARCHAR2
,   p_attribute12                   IN VARCHAR2
,   p_attribute13                   IN VARCHAR2
,   p_attribute14                   IN VARCHAR2
,   p_attribute15                   IN VARCHAR2
,   p_attribute16                   IN VARCHAR2   --For bug 2184255
,   p_attribute17                   IN VARCHAR2
,   p_attribute18                   IN VARCHAR2
,   p_attribute19                   IN VARCHAR2
,   p_attribute2                    IN VARCHAR2
,   p_attribute20                   IN VARCHAR2
,   p_attribute3                    IN VARCHAR2
,   p_attribute4                    IN VARCHAR2
,   p_attribute5                    IN VARCHAR2
,   p_attribute6                    IN VARCHAR2
,   p_attribute7                    IN VARCHAR2
,   p_attribute8                    IN VARCHAR2
,   p_attribute9                    IN VARCHAR2
,   p_blanket_number                IN NUMBER
,   p_blanket_line_number           IN NUMBER
,   p_blanket_version_number        IN NUMBER
,   p_context                       IN VARCHAR2
,   p_auto_selected_quantity        IN NUMBER
,   p_cancelled_quantity            In NUMBER
,   p_component_code                IN VARCHAR2
,   p_component_number              IN NUMBER
,   p_component_sequence_id         IN NUMBER
,   p_config_display_sequence       IN NUMBER
,   p_configuration_id              IN NUMBER
,   p_config_header_id              IN NUMBER
,   p_config_rev_nbr                IN NUMBER
,   p_credit_invoice_line_id        IN NUMBER
,   p_customer_dock_code            IN VARCHAR2
,   p_customer_job                  IN VARCHAR2
,   p_customer_production_line      IN VARCHAR2
,   p_customer_trx_line_id          IN NUMBER
,   p_cust_model_serial_number      IN VARCHAR2
,   p_cust_po_number                IN VARCHAR2
,   p_delivery_lead_time            IN NUMBER
,   p_deliver_to_contact_id         IN NUMBER
,   p_deliver_to_org_id             IN NUMBER
,   p_demand_bucket_type_code       IN VARCHAR2
,   p_demand_class_code             IN VARCHAR2
,   p_dep_plan_required_flag        IN VARCHAR2
,   p_earliest_acceptable_date      IN DATE
,   p_explosion_date                IN DATE
,   p_fob_point_code                IN VARCHAR2
,   p_freight_carrier_code          IN VARCHAR2
,   p_freight_terms_code            IN VARCHAR2
,   p_fulfilled_quantity            IN NUMBER
,   p_global_attribute1             IN VARCHAR2
,   p_global_attribute10            IN VARCHAR2
,   p_global_attribute11            IN VARCHAR2
,   p_global_attribute12            IN VARCHAR2
,   p_global_attribute13            IN VARCHAR2
,   p_global_attribute14            IN VARCHAR2
,   p_global_attribute15            IN VARCHAR2
,   p_global_attribute16            IN VARCHAR2
,   p_global_attribute17            IN VARCHAR2
,   p_global_attribute18            IN VARCHAR2
,   p_global_attribute19            IN VARCHAR2
,   p_global_attribute2             IN VARCHAR2
,   p_global_attribute20            IN VARCHAR2
,   p_global_attribute3             IN VARCHAR2
,   p_global_attribute4             IN VARCHAR2
,   p_global_attribute5             IN VARCHAR2
,   p_global_attribute6             IN VARCHAR2
,   p_global_attribute7             IN VARCHAR2
,   p_global_attribute8             IN VARCHAR2
,   p_global_attribute9             IN VARCHAR2
,   p_global_attribute_category     IN VARCHAR2
,   p_industry_attribute1           IN VARCHAR2
,   p_industry_attribute10          IN VARCHAR2
,   p_industry_attribute11          IN VARCHAR2
,   p_industry_attribute12          IN VARCHAR2
,   p_industry_attribute13          IN VARCHAR2
,   p_industry_attribute14          IN VARCHAR2
,   p_industry_attribute15          IN VARCHAR2
,   p_industry_attribute2           IN VARCHAR2
,   p_industry_attribute3           IN VARCHAR2
,   p_industry_attribute4           IN VARCHAR2
,   p_industry_attribute5           IN VARCHAR2
,   p_industry_attribute6           IN VARCHAR2
,   p_industry_attribute7           IN VARCHAR2
,   p_industry_attribute8           IN VARCHAR2
,   p_industry_attribute9           IN VARCHAR2
,   p_industry_context              IN VARCHAR2
,   p_intermed_ship_to_contact_id   IN NUMBER
,   p_intermed_ship_to_org_id       IN NUMBER
,   p_inventory_item_id             IN NUMBER
,   p_invoice_interface_status      IN VARCHAR2
,   p_invoice_to_contact_id         IN NUMBER
,   p_invoice_to_org_id             IN NUMBER
,   p_invoicing_rule_id             IN NUMBER
,   p_ordered_item_id               IN NUMBER
,   p_item_identifier_type          IN VARCHAR2
,   p_ordered_item                  IN VARCHAR2
,   p_item_revision                 IN VARCHAR2
,   p_item_type_code                IN VARCHAR2
,   p_latest_acceptable_date        IN DATE
,   p_line_category_code            IN VARCHAR2
,   p_line_id                       IN NUMBER
,   p_line_number                   IN NUMBER
,   p_line_type_id                  IN NUMBER
,   p_link_to_line_id               IN NUMBER
,   p_model_group_number            IN NUMBER
,   p_option_flag                   IN VARCHAR2
,   p_option_number                 IN NUMBER
,   p_ordered_quantity              IN NUMBER
,   p_order_quantity_uom            IN VARCHAR2
,   p_org_id                        IN NUMBER
,   p_orig_sys_document_ref         IN VARCHAR2
,   p_orig_sys_line_ref             IN VARCHAR2
,   p_payment_term_id               IN NUMBER
,   p_price_list_id                 IN NUMBER
,   p_pricing_attribute1            IN VARCHAR2
,   p_pricing_attribute10           IN VARCHAR2
,   p_pricing_attribute2            IN VARCHAR2
,   p_pricing_attribute3            IN VARCHAR2
,   p_pricing_attribute4            IN VARCHAR2
,   p_pricing_attribute5            IN VARCHAR2
,   p_pricing_attribute6            IN VARCHAR2
,   p_pricing_attribute7            IN VARCHAR2
,   p_pricing_attribute8            IN VARCHAR2
,   p_pricing_attribute9            IN VARCHAR2
,   p_pricing_context               IN VARCHAR2
,   p_pricing_date                  IN DATE
,   p_pricing_quantity              IN NUMBER
,   p_pricing_quantity_uom          IN VARCHAR2
,   p_project_id                    IN NUMBER
,   p_promise_date                  IN DATE
,   p_reference_header_id           IN NUMBER
,   p_reference_line_id             IN NUMBER
,   p_reference_type                IN VARCHAR2
,   p_request_date                  IN DATE
,   p_reserved_quantity             IN NUMBER
,   p_return_attribute1             IN VARCHAR2
,   p_return_attribute10            IN VARCHAR2
,   p_return_attribute11            IN VARCHAR2
,   p_return_attribute12            IN VARCHAR2
,   p_return_attribute13            IN VARCHAR2
,   p_return_attribute14            IN VARCHAR2
,   p_return_attribute15            IN VARCHAR2
,   p_return_attribute2             IN VARCHAR2
,   p_return_attribute3             IN VARCHAR2
,   p_return_attribute4             IN VARCHAR2
,   p_return_attribute5             IN VARCHAR2
,   p_return_attribute6             IN VARCHAR2
,   p_return_attribute7             IN VARCHAR2
,   p_return_attribute8             IN VARCHAR2
,   p_return_attribute9             IN VARCHAR2
,   p_return_context                IN VARCHAR2
,   p_rla_schedule_type_code        IN VARCHAR2
,   p_schedule_arrival_date         IN DATE
,   p_schedule_ship_date            IN DATE
,   p_schedule_action_code          IN VARCHAR2
,   p_schedule_status_code          IN VARCHAR2
,   p_shipment_number               IN NUMBER
,   p_shipment_priority_code        IN VARCHAR2
,   p_shipped_quantity              IN NUMBER
,   p_shipping_method_code          IN VARCHAR2
,   p_shipping_quantity             IN NUMBER
,   p_shipping_quantity_uom         IN VARCHAR2
,   p_ship_from_org_id              IN NUMBER
,   p_ship_tolerance_above          IN NUMBER
,   p_ship_tolerance_below          IN NUMBER
,   p_shipping_interfaced_flag      IN VARCHAR2
,   p_ship_to_contact_id            IN NUMBER
,   p_ship_to_org_id                IN NUMBER
,   p_ship_model_complete_flag      IN VARCHAR2
,   p_sold_to_org_id                IN NUMBER
,   p_sort_order                    IN VARCHAR2
,   p_source_document_id            IN NUMBER
,   p_source_document_line_id       IN NUMBER
,   p_source_document_type_id       IN NUMBER
,   p_source_type_code              IN VARCHAR2
,   p_task_id                       IN NUMBER
,   p_tax_code                      IN VARCHAR2
,   p_tax_date                      IN DATE
,   p_tax_exempt_flag               IN VARCHAR2
,   p_tax_exempt_number             IN VARCHAR2
,   p_tax_exempt_reason_code        IN VARCHAR2
,   p_tax_point_code                IN VARCHAR2
,   p_tax_rate                      IN NUMBER
,   p_tax_value                     IN NUMBER
,   p_top_model_line_id             IN NUMBER
,   p_unit_list_price               IN NUMBER
,   p_unit_selling_price            IN NUMBER
,   p_visible_demand_flag           IN VARCHAR2
,   p_accounting_rule               IN VARCHAR2
,   p_agreement                     IN VARCHAR2
,   p_customer_item                 IN VARCHAR2
,   p_deliver_to_address1           IN VARCHAR2
,   p_deliver_to_address2           IN VARCHAR2
,   p_deliver_to_address3           IN VARCHAR2
,   p_deliver_to_address4           IN VARCHAR2
,   p_deliver_to_contact            IN VARCHAR2
,   p_deliver_to_location           IN VARCHAR2
,   p_deliver_to_org                IN VARCHAR2
,   p_demand_bucket_type            IN VARCHAR2
,   p_fob_point                     IN VARCHAR2
,   p_freight_terms                 IN VARCHAR2
,   p_inventory_item                IN VARCHAR2
,   p_invoice_to_address1           IN VARCHAR2
,   p_invoice_to_address2           IN VARCHAR2
,   p_invoice_to_address3           IN VARCHAR2
,   p_invoice_to_address4           IN VARCHAR2
,   p_invoice_to_contact            IN VARCHAR2
,   p_invoice_to_location           IN VARCHAR2
,   p_invoice_to_org                IN VARCHAR2
,   p_invoicing_rule                IN VARCHAR2
,   p_intermed_ship_to_address1     IN VARCHAR2
,   p_intermed_ship_to_address2     IN VARCHAR2
,   p_intermed_ship_to_address3     IN VARCHAR2
,   p_intermed_ship_to_address4     IN VARCHAR2
,   p_intermed_ship_to_contact      IN VARCHAR2
,   p_intermed_ship_to_location     IN VARCHAR2
,   p_intermed_ship_to_org          IN VARCHAR2
,   p_item                          IN VARCHAR2
,   p_item_type                     IN VARCHAR2
,   p_line_type                     IN VARCHAR2
,   p_payment_term                  IN VARCHAR2
,   p_price_list                    IN VARCHAR2
,   p_project                       IN VARCHAR2
,   p_rla_schedule_type             IN VARCHAR2
,   p_shipment_priority             IN VARCHAR2
,   p_ship_from_address1            IN VARCHAR2
,   p_ship_from_address2            IN VARCHAR2
,   p_ship_from_address3            IN VARCHAR2
,   p_ship_from_address4            IN VARCHAR2
,   p_ship_from_location            IN VARCHAR2
,   p_ship_from_org                 IN VARCHAR2
,   p_ship_to_address1              IN VARCHAR2
,   p_ship_to_address2              IN VARCHAR2
,   p_ship_to_address3              IN VARCHAR2
,   p_ship_to_address4              IN VARCHAR2
,   p_ship_to_contact               IN VARCHAR2
,   p_ship_to_location              IN VARCHAR2
,   p_ship_to_org                   IN VARCHAR2
,   p_sold_to_org                   IN VARCHAR2
,   p_task                          IN VARCHAR2
,   p_tax_exempt                    IN VARCHAR2
,   p_tax_exempt_reason             IN VARCHAR2
,   p_tax_point                     IN VARCHAR2
,   p_split_from_line_id            IN NUMBER
,   p_cust_production_seq_num       IN VARCHAR2
,   p_authorized_to_ship_flag       IN VARCHAR2
,   p_veh_cus_item_cum_key_id       IN NUMBER
,   p_salesrep_id                   IN NUMBER
,   p_return_reason_code            IN VARCHAR2
,   p_arrival_set_id                IN NUMBER
,   p_ship_set_id                   IN NUMBER
,   p_over_ship_reason_code         IN VARCHAR2
,   p_over_ship_resolved_flag       IN VARCHAR2
,   p_industry_attribute16          IN VARCHAR2
,   p_industry_attribute17          IN VARCHAR2
,   p_industry_attribute18          IN VARCHAR2
,   p_industry_attribute19          IN VARCHAR2
,   p_industry_attribute20          IN VARCHAR2
,   p_industry_attribute21          IN VARCHAR2
,   p_industry_attribute22          IN VARCHAR2
,   p_industry_attribute23          IN VARCHAR2
,   p_industry_attribute24          IN VARCHAR2
,   p_industry_attribute25          IN VARCHAR2
,   p_industry_attribute26          IN VARCHAR2
,   p_industry_attribute27          IN VARCHAR2
,   p_industry_attribute28          IN VARCHAR2
,   p_industry_attribute29          IN VARCHAR2
,   p_industry_attribute30          IN VARCHAR2
,   p_veh_cus_item_cum_key          IN VARCHAR2
,   p_salesrep                      IN VARCHAR2
,   p_return_reason                 IN VARCHAR2
,   p_delivery                      IN VARCHAR2
,   p_arrival_set                   IN VARCHAR2
,   p_ship_set                      IN VARCHAR2
,   p_over_ship_reason              IN VARCHAR2
,   p_first_ack_code                IN VARCHAR2
,   p_first_ack_date                IN DATE
,   p_last_ack_code                 IN VARCHAR2
,   p_last_ack_date                 IN DATE
,   p_service_txn_reason_code       IN VARCHAR2
,   p_service_txn_comments          IN VARCHAR2
,   p_unit_selling_percent          IN NUMBER
,   p_unit_list_percent             IN NUMBER
,   p_unit_percent_base_price       IN NUMBER
,   p_service_duration              IN NUMBER
,   p_service_period                IN VARCHAR2
,   p_service_start_date            IN DATE
,   p_service_end_date              IN DATE
,   p_service_coterminate_flag      IN VARCHAR2
,   p_service_number                IN NUMBER
,   p_service_reference_type_code   IN VARCHAR2
,   p_service_reference_line_id     IN NUMBER
,   p_service_reference_system_id   IN NUMBER
,   p_tp_attribute1                 IN VARCHAR2
,   p_tp_attribute10                IN VARCHAR2
,   p_tp_attribute11                IN VARCHAR2
,   p_tp_attribute12                IN VARCHAR2
,   p_tp_attribute13                IN VARCHAR2
,   p_tp_attribute14                IN VARCHAR2
,   p_tp_attribute15                IN VARCHAR2
,   p_tp_attribute2                 IN VARCHAR2
,   p_tp_attribute3                 IN VARCHAR2
,   p_tp_attribute4                 IN VARCHAR2
,   p_tp_attribute5                 IN VARCHAR2
,   p_tp_attribute6                 IN VARCHAR2
,   p_tp_attribute7                 IN VARCHAR2
,   p_tp_attribute8                 IN VARCHAR2
,   p_tp_attribute9                 IN VARCHAR2
,   p_tp_context                    IN VARCHAR2
,   p_shipping_instructions         IN VARCHAR2
,   p_packing_instructions          IN VARCHAR2
,   p_planning_priority             IN VARCHAR2
,   p_calculate_price_flag          IN VARCHAR2
--end custoemr chagnes
,   p_end_customer_contact_id       IN NUMBER
,   p_end_customer_id               IN NUMBER
,   p_end_customer_site_use_id      IN NUMBER
,   p_end_customer_address1         IN VARCHAR2
,   p_end_customer_address2         IN VARCHAR2
,   p_end_customer_address3         IN VARCHAR2
,   p_end_customer_address4         IN VARCHAR2
,   p_end_customer_contact          IN VARCHAR2
,   p_end_customer_location         IN VARCHAR2
,   p_ib_owner                      IN VARCHAR2
,   p_ib_installed_at_location      IN VARCHAR2
,   p_ib_current_location           IN VARCHAR2
,   p_block_name                    IN VARCHAR2 DEFAULT NULL
) IS
initial                  Integer;
j                        Integer;
l_api_name      CONSTANT VARCHAR2(30) := 'Process_Line_Scalar';
l_arrival_set_id         number;
l_control_rec            OE_GLOBALS.Control_Rec_Type;
l_counter                Integer := 0;
l_current_org_id         Number;
l_debug_level CONSTANT   NUMBER := oe_debug_pub.g_debug_level;
l_error_count            NUMBER := 0;
l_header_id              Number;
l_init_msg_list          VARCHAR2(1) := FND_API.G_TRUE;
l_line_id                Number;
l_line_tbl               OE_ORDER_PUB.Line_Tbl_Type;
l_mc_err_handling_flag   NUMBER := p_mc_err_handling_flag;
l_num_of_records         NUMBER;
l_old_arrival_set_id     number;
l_old_header_id          number;
l_old_line_tbl           OE_ORDER_PUB.Line_Tbl_Type;
l_old_org_id             number;
l_old_ship_set_id        number;
l_old_top_model_line_id  number;
l_rec                    number;
l_return_status          VARCHAR2(30);
l_ship_set_id            number;
l_top_model_line_id      number;
l_x_line_rec             OE_ORDER_PUB.Line_Rec_Type;
nextpos                  Integer;

CURSOR c1 IS SELECT x.id1, x.org_id, l.header_id, l.arrival_set_id,
                    l.ship_set_id, l.top_model_line_id
             FROM TABLE(OE_MASS_CHANGE_PVT.get_sel_rec_tbl) x,
                  oe_order_lines_all l
             WHERE l.line_id = x.id1
             ORDER BY l.header_id,
                      nvl(l.arrival_set_id, -1),
                      nvl(l.ship_set_id, -1),
                      nvl(l.top_model_line_id, -1);

--Bug 7566697
--Will be used to set the header level savepoint
l_header_changed  BOOLEAN := TRUE;


BEGIN
   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Entering OE_MASS_CHANGE_PVT.Process_Line_Scalar');
   END IF;

   p_error_count := l_error_count;

   --bug4529937 start ----bug 6850537,7210480 added p_block_name ='LINES_SUMMARY'
   IF p_block_name = 'LINE' or p_block_name ='LINES_SUMMARY' THEN
      G_BLK_NAME := p_block_name;
      G_NUM_OF_LINES := p_num_of_records;
   END IF;

   IF l_debug_level > 0 THEN
      oe_debug_pub.add(' block_name:'|| p_block_name);
      oe_debug_pub.add(' num of records:'|| p_num_of_records);
   END IF;
   --bug4529937 end

 IS_MASS_CHANGE := 'T'; --Added for bug 4911340

   g_sel_rec_tbl := p_sel_rec_tbl;
   OPEN c1;
   FETCH c1 into l_line_id, l_current_org_id, l_header_id, l_arrival_set_id,
                 l_ship_set_id, l_top_model_line_id;

   l_old_org_id := l_current_org_id;

   MO_GLOBAL.SET_POLICY_CONTEXT('S',l_current_org_id);

   LOOP -- Outer loop
      -- Setting context whenever org_id changes.
      IF p_multi_ou AND l_current_org_id <> l_old_org_id THEN
         IF l_debug_level > 0 THEN
            oe_debug_pub.add('Setting policy - ' || l_current_org_id);
         END IF;

         MO_GLOBAL.SET_POLICY_CONTEXT('S',l_current_org_id);
      END IF;

      BEGIN
         IF l_debug_level > 0 THEN
            oe_debug_pub.add('l_rec - ' || l_rec);
         END IF;

         IF l_rec > 0 THEN
            l_init_msg_list :=   FND_API.G_FALSE;
         END IF;

         --Bug 7566697
         --Will be creating new savepoint only if the header has changed
         --This savepoint will used to rollback changes done to the whole order, in case of pricing error
         IF l_header_changed
         THEN
            OE_MASS_CHANGE_PVT.G_PRICING_ERROR := 'N';
            SAVEPOINT Pricing_Header_Savepoint;
         END IF;

         SAVEPOINT Process_Line_Scalar;

         l_rec     := 0;

         l_line_tbl      := OE_ORDER_PUB.G_MISS_LINE_TBL;
         l_old_line_tbl  := OE_ORDER_PUB.G_MISS_LINE_TBL;
         l_return_status := NULL;

         LOOP -- Inner loop

            G_COUNTER := G_COUNTER + 1;

            IF l_debug_level > 0 THEN
               oe_debug_pub.add('Line Id           - ' || l_line_id);
               oe_debug_pub.add('Org Id            - ' || l_current_org_id);
               oe_debug_pub.add('Header Id         - ' || l_header_id);
               oe_debug_pub.add('Arrival Set Id    - ' || l_arrival_set_id);
               oe_debug_pub.add('Ship Set Id       - ' || l_ship_set_id);
               oe_debug_pub.add('Top Model Line Id - ' || l_top_model_line_id);
            END IF;

            l_old_header_id         := l_header_id;
            l_old_arrival_set_id    := l_arrival_set_id;
            l_old_ship_set_id       := l_ship_set_id;
            l_old_top_model_line_id := l_top_model_line_id;
            l_old_org_id            := l_current_org_id;

            l_rec                       := l_rec + 1;
            l_line_tbl(l_rec)           := OE_ORDER_PUB.G_MISS_LINE_REC;
            l_line_tbl(l_rec).line_id   := l_line_id;
            l_line_tbl(l_rec).header_id := l_header_id;

            OE_Line_Util.Lock_Row ( x_return_status         => l_return_status,
                                    p_x_line_rec            => l_x_line_rec,
                                    p_line_id               => l_line_id );

            IF l_debug_level > 0 THEN
               OE_DEBUG_PUB.Add('After Lock Row - ' || l_return_status);
            END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

            l_line_tbl(l_rec).operation := OE_GLOBALS.G_OPR_UPDATE;

            if p_ordered_quantity is NOT NULL then
               l_line_tbl(l_rec).ordered_quantity := p_ordered_quantity;
            end if;

            if p_change_reason is NOT NULL then
               l_line_tbl(l_rec).change_reason := p_change_reason;
            end if;

            if p_change_comments is not null then
               l_line_tbl(l_rec).change_comments := p_change_comments;
            end if;

            if p_order_quantity_uom is NOT NULL then
               l_line_tbl(l_rec).order_quantity_uom := p_order_quantity_uom;
            end if;

            if p_promise_date is NOT NULL then
               l_line_tbl(l_rec).promise_date  := p_promise_date;
            end if;

            if p_request_date is NOT NULL then
               l_line_tbl(l_rec).request_date  := p_request_date;
            end if;

            if p_schedule_ship_date is NOT NULL then
               l_line_tbl(l_rec).schedule_ship_date  := p_schedule_ship_date;
            end if;

            if p_price_list_id  is NOT NULL then
               l_line_tbl(l_rec).price_list_id  := p_price_list_id;
            end if;

            if  p_inventory_item_id is NOT NULL then
               l_line_tbl(l_rec).inventory_item_id := p_inventory_item_id;
               l_line_tbl(l_rec).ordered_item := p_ordered_item;
            end if;

            if p_accounting_rule_id  is NOT NULL then
               l_line_tbl(l_rec).accounting_rule_id  := p_accounting_rule_id;
            end if;

            if p_accounting_rule_duration  is NOT NULL then
               l_line_tbl(l_rec).accounting_rule_duration  := p_accounting_rule_duration;
            end if;

            if p_actual_arrival_date  is NOT NULL then
               l_line_tbl(l_rec).actual_arrival_date := p_actual_arrival_date;
            end if;

            if p_actual_shipment_date  is NOT NULL then
               l_line_tbl(l_rec).actual_shipment_date := p_actual_shipment_date;
            end if;

            if p_agreement_id  is NOT NULL then
               l_line_tbl(l_rec).agreement_id := p_agreement_id;
            end if;

            if p_shipping_instructions is not null then
               l_line_tbl(l_rec).shipping_instructions:=p_shipping_instructions;
            end if;

            if p_planning_priority is not null then
               l_line_tbl(l_rec).planning_priority:=p_planning_priority;
            end if;

            if p_packing_instructions is not null then
               l_line_tbl(l_rec).packing_instructions:=p_packing_instructions;
            end if;

            if p_ato_line_id  is NOT NULL then
               l_line_tbl(l_rec).ato_line_id := p_ato_line_id;
            end if;

            if p_attribute1  is NOT NULL then
               l_line_tbl(l_rec).attribute1 := p_attribute1;
            end if;

            if p_attribute10  is NOT NULL then
               l_line_tbl(l_rec).attribute10 := p_attribute10;
            end if;

            if p_attribute11  is NOT NULL then
               l_line_tbl(l_rec).attribute11 := p_attribute11;
            end if;

            if p_attribute12  is NOT NULL then
               l_line_tbl(l_rec).attribute12 := p_attribute12;
            end if;

            if p_attribute13  is NOT NULL then
               l_line_tbl(l_rec).attribute13 := p_attribute13;
            end if;

            if p_attribute14  is NOT NULL then
               l_line_tbl(l_rec).attribute14 := p_attribute14;
            end if;

            if p_attribute15  is NOT NULL then
               l_line_tbl(l_rec).attribute15 := p_attribute15;
            end if;

            -- For bug 2184255
            if p_attribute16  is NOT NULL then
               l_line_tbl(l_rec).attribute16 := p_attribute16;
            end if;

            if p_attribute17  is NOT NULL then
               l_line_tbl(l_rec).attribute17 := p_attribute17;
            end if;

            if p_attribute18  is NOT NULL then
               l_line_tbl(l_rec).attribute18 := p_attribute18;
            end if;

            if p_attribute19  is NOT NULL then
               l_line_tbl(l_rec).attribute19 := p_attribute19;
            end if;

            if p_attribute2  is NOT NULL then
               l_line_tbl(l_rec).attribute2 := p_attribute2;
            end if;

            if p_attribute20  is NOT NULL then
               l_line_tbl(l_rec).attribute20 := p_attribute20;
            end if;

            if p_attribute3  is NOT NULL then
               l_line_tbl(l_rec).attribute3 := p_attribute3;
            end if;

            if p_attribute4  is NOT NULL then
               l_line_tbl(l_rec).attribute4 := p_attribute4;
            end if;

            if p_attribute5  is NOT NULL then
               l_line_tbl(l_rec).attribute5 := p_attribute5;
            end if;

            if p_attribute6  is NOT NULL then
               l_line_tbl(l_rec).attribute6 := p_attribute6;
            end if;

            if p_attribute7  is NOT NULL then
               l_line_tbl(l_rec).attribute7 := p_attribute7;
            end if;

            if p_attribute8  is NOT NULL then
               l_line_tbl(l_rec).attribute8 := p_attribute8;
            end if;

            if p_attribute9  is NOT NULL then
               l_line_tbl(l_rec).attribute9 := p_attribute9;
            end if;

            if p_blanket_number is not null then
               l_line_tbl(l_rec).blanket_number:=p_blanket_number;
            end if;

            if p_blanket_line_number is not null then
               l_line_tbl(l_rec).blanket_line_number:=p_blanket_line_number;
            end if;

            if p_blanket_version_number is not null then
               l_line_tbl(l_rec).blanket_version_number:=p_blanket_version_number;
            end if;

            if p_context  is NOT NULL then
               l_line_tbl(l_rec).context := p_context;
            end if;

            if p_auto_selected_quantity  is NOT NULL then
               l_line_tbl(l_rec).auto_selected_quantity := p_auto_selected_quantity;
            end if;

            if p_cancelled_quantity  is NOT NULL then
               l_line_tbl(l_rec).cancelled_quantity := p_cancelled_quantity;
            end if;

            if p_component_code  is NOT NULL then
               l_line_tbl(l_rec).component_code := p_component_code;
            end if;

            if p_component_number  is NOT NULL then
               l_line_tbl(l_rec).component_number := p_component_number;
            end if;

            if p_component_sequence_id  is NOT NULL then
               l_line_tbl(l_rec).component_sequence_id := p_component_sequence_id;
            end if;

            if p_config_display_sequence  is NOT NULL then
               l_line_tbl(l_rec).config_display_sequence := p_config_display_sequence;
            end if;

            if p_configuration_id  is NOT NULL then
               l_line_tbl(l_rec).configuration_id := p_configuration_id;
            end if;

            if p_credit_invoice_line_id  is NOT NULL then
               l_line_tbl(l_rec).credit_invoice_line_id := p_credit_invoice_line_id;
            end if;

            if p_customer_dock_code  is NOT NULL then
               l_line_tbl(l_rec).customer_dock_code := p_customer_dock_code;
            end if;

            if p_customer_job  is NOT NULL then
               l_line_tbl(l_rec).customer_job := p_customer_job;
            end if;

            if p_customer_production_line  is NOT NULL then
               l_line_tbl(l_rec).customer_production_line := p_customer_production_line;
            end if;

            if p_customer_trx_line_id  is NOT NULL then
               l_line_tbl(l_rec).customer_trx_line_id := p_customer_trx_line_id;
            end if;

            if p_cust_model_serial_number  is NOT NULL then
               l_line_tbl(l_rec).cust_model_serial_number := p_cust_model_serial_number;
            end if;

            if p_cust_po_number  is NOT NULL then
               l_line_tbl(l_rec).cust_po_number := p_cust_po_number;
            end if;

            if p_delivery_lead_time  is NOT NULL then
               l_line_tbl(l_rec).delivery_lead_time := p_delivery_lead_time;
            end if;

            if p_deliver_to_contact_id  is NOT NULL then
               l_line_tbl(l_rec).deliver_to_contact_id := p_deliver_to_contact_id;
            end if;

            if p_deliver_to_org_id  is NOT NULL then
               l_line_tbl(l_rec).deliver_to_org_id := p_deliver_to_org_id;
            end if;

            if p_demand_bucket_type_code  is NOT NULL then
               l_line_tbl(l_rec).demand_bucket_type_code := p_demand_bucket_type_code;
            end if;

            if p_demand_class_code  is NOT NULL then
               l_line_tbl(l_rec).demand_class_code := p_demand_class_code;
            end if;

            if p_dep_plan_required_flag  is NOT NULL then
               l_line_tbl(l_rec).dep_plan_required_flag := p_dep_plan_required_flag;
            end if;

            if p_earliest_acceptable_date  is NOT NULL then
               l_line_tbl(l_rec).earliest_acceptable_date := p_earliest_acceptable_date;
            end if;

            if p_explosion_date  is NOT NULL then
               l_line_tbl(l_rec).explosion_date:= p_explosion_date;
            end if;

            if p_fob_point_code  is NOT NULL then
               l_line_tbl(l_rec).fob_point_code := p_fob_point_code;
            end if;

            if p_freight_carrier_code  is NOT NULL then
               l_line_tbl(l_rec).freight_carrier_code := p_freight_carrier_code;
            end if;

            if p_freight_terms_code  is NOT NULL then
               l_line_tbl(l_rec).freight_terms_code := p_freight_terms_code;
            end if;

            if p_fulfilled_quantity  is NOT NULL then
               l_line_tbl(l_rec).fulfilled_quantity := p_fulfilled_quantity;
            end if;

            if p_global_attribute1  is NOT NULL then
               l_line_tbl(l_rec).global_attribute1 := p_global_attribute1;
            end if;

            if p_global_attribute2  is NOT NULL then
               l_line_tbl(l_rec).global_attribute2 :=p_global_attribute2;
            end if;

            if p_global_attribute3  is NOT NULL then
               l_line_tbl(l_rec).global_attribute3 := p_global_attribute3;
            end if;

            if p_global_attribute4  is NOT NULL then
               l_line_tbl(l_rec).global_attribute4 := p_global_attribute4;
            end if;

            if p_global_attribute5  is NOT NULL then
               l_line_tbl(l_rec).global_attribute5 := p_global_attribute5;
            end if;

            if p_global_attribute6  is NOT NULL then
               l_line_tbl(l_rec).global_attribute6 := p_global_attribute6;
            end if;

            if p_global_attribute7  is NOT NULL then
               l_line_tbl(l_rec).global_attribute7 := p_global_attribute7;
            end if;

            if p_global_attribute8  is NOT NULL then
               l_line_tbl(l_rec).global_attribute8 := p_global_attribute8;
            end if;

            if p_global_attribute9  is NOT NULL then
               l_line_tbl(l_rec).global_attribute9 := p_global_attribute9;
            end if;

            if p_global_attribute10  is NOT NULL then
               l_line_tbl(l_rec).global_attribute10 := p_global_attribute10;
            end if;

            if p_global_attribute11  is NOT NULL then
               l_line_tbl(l_rec).global_attribute11 := p_global_attribute11;
            end if;

            if p_global_attribute12  is NOT NULL then
               l_line_tbl(l_rec).global_attribute12 := p_global_attribute12;
            end if;

            if p_global_attribute13  is NOT NULL then
               l_line_tbl(l_rec).global_attribute13 := p_global_attribute13;
            end if;

            if p_global_attribute14  is NOT NULL then
               l_line_tbl(l_rec).global_attribute14 := p_global_attribute14;
            end if;

            if p_global_attribute15  is NOT NULL then
               l_line_tbl(l_rec).global_attribute15 := p_global_attribute15;
            end if;

            if p_global_attribute16  is NOT NULL then
               l_line_tbl(l_rec).global_attribute16 := p_global_attribute16;
            end if;

            if p_global_attribute17  is NOT NULL then
               l_line_tbl(l_rec).global_attribute17 := p_global_attribute17;
            end if;

            if p_global_attribute18  is NOT NULL then
               l_line_tbl(l_rec).global_attribute18 := p_global_attribute18;
            end if;

            if p_global_attribute19  is NOT NULL then
               l_line_tbl(l_rec).global_attribute19 := p_global_attribute19;
            end if;

            if p_global_attribute20  is NOT NULL then
               l_line_tbl(l_rec).global_attribute20 := p_global_attribute20;
            end if;

            if p_global_attribute_category  is NOT NULL then
               l_line_tbl(l_rec).global_attribute_category := p_global_attribute_category;
            end if;

            if  p_industry_attribute1   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute1  :=  p_industry_attribute1 ;
            end if;

            if  p_industry_attribute2   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute2  :=  p_industry_attribute2 ;
            end if;

            if  p_industry_attribute3   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute3  :=  p_industry_attribute3 ;
            end if;

            if  p_industry_attribute4   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute4  :=  p_industry_attribute4 ;
            end if;

            if  p_industry_attribute5   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute5  :=  p_industry_attribute5 ;
            end if;

            if  p_industry_attribute6   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute6  :=  p_industry_attribute6 ;
            end if;

            if  p_industry_attribute7   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute7  :=  p_industry_attribute7 ;
            end if;

            if  p_industry_attribute8   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute8  :=  p_industry_attribute8 ;
            end if;

            if  p_industry_attribute9   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute9  :=  p_industry_attribute9 ;
            end if;

            if  p_industry_attribute10   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute10  :=  p_industry_attribute10 ;
            end if;

            if  p_industry_attribute11   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute11  :=  p_industry_attribute11 ;
            end if;

            if  p_industry_attribute12   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute12  :=  p_industry_attribute12 ;
            end if;

            if  p_industry_attribute13   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute13  :=  p_industry_attribute13 ;
            end if;

            if  p_industry_attribute14   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute14  :=  p_industry_attribute14 ;
            end if;

            if  p_industry_attribute15   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute15  :=  p_industry_attribute15 ;
            end if;

            if  p_industry_attribute16   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute16  :=  p_industry_attribute16 ;
            end if;

            if  p_industry_attribute17   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute17  :=  p_industry_attribute17 ;
            end if;

            if  p_industry_attribute18   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute18  :=  p_industry_attribute18 ;
            end if;

            if  p_industry_attribute19   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute19  :=  p_industry_attribute19 ;
            end if;

            if  p_industry_attribute20   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute20  :=  p_industry_attribute20 ;
            end if;

            if  p_industry_attribute21   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute21  :=  p_industry_attribute21 ;
            end if;

            if  p_industry_attribute22   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute22  :=  p_industry_attribute22 ;
            end if;

            if  p_industry_attribute23   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute23  :=  p_industry_attribute23 ;
            end if;

            if  p_industry_attribute24   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute24  :=  p_industry_attribute24 ;
            end if;

            if  p_industry_attribute25   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute25  :=  p_industry_attribute25 ;
            end if;

            if  p_industry_attribute26   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute26  :=  p_industry_attribute26 ;
            end if;

            if  p_industry_attribute27   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute27  :=  p_industry_attribute27 ;
            end if;

            if  p_industry_attribute28   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute28  :=  p_industry_attribute28 ;
            end if;

            if  p_industry_attribute29   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute29  :=  p_industry_attribute29 ;
            end if;

            if  p_industry_attribute30   is NOT NULL then
               l_line_tbl(l_rec).industry_attribute30  :=  p_industry_attribute30 ;
            end if;

            if p_industry_context  is NOT NULL then
               l_line_tbl(l_rec).industry_context := p_industry_context;
            end if;

            if  p_intermed_ship_to_contact_id  is NOT NULL then
               l_line_tbl(l_rec).intermed_ship_to_contact_id := p_intermed_ship_to_contact_id;
            end if;

            if  p_intermed_ship_to_org_id   is NOT NULL then
               l_line_tbl(l_rec).intermed_ship_to_org_id :=p_intermed_ship_to_org_id ;
            end if;

            if  p_inventory_item_id is NOT NULL then
               l_line_tbl(l_rec).inventory_item_id:=  p_inventory_item_id;
            end if;

            if  p_invoice_interface_status is NOT NULL then
               l_line_tbl(l_rec).invoice_interface_status_code:= p_invoice_interface_status;
            end if;

            if   p_invoice_to_contact_id is NOT NULL then
               l_line_tbl(l_rec).invoice_to_contact_id:=  p_invoice_to_contact_id;
            end if;

            if  p_invoice_to_org_id is NOT NULL then
               l_line_tbl(l_rec).invoice_to_org_id:= p_invoice_to_org_id;
            end if;

            if  p_invoicing_rule_id is NOT NULL then
               l_line_tbl(l_rec).invoicing_rule_id :=p_invoicing_rule_id;
            end if;

            if  p_ordered_item_id is NOT NULL then
               l_line_tbl(l_rec).ordered_item_id:=  p_ordered_item_id;
            end if;

            if  p_item_identifier_type is NOT NULL then
               l_line_tbl(l_rec).item_identifier_type:= p_item_identifier_type;
                 IF p_item_identifier_type NOT IN ('INT','CUST') then --Bug 8306353
		 l_line_tbl(l_rec).ordered_item_id:= NULL;
	         END IF;

            end if;

            if  p_ordered_item is NOT NULL then
               l_line_tbl(l_rec).ordered_item := p_ordered_item;
            end if;

            if  p_item_revision is NOT NULL then
               l_line_tbl(l_rec).item_revision:= p_item_revision;
            end if;

            if p_item_type_code is NOT NULL then
               l_line_tbl(l_rec).item_type_code :=p_item_type_code;
            end if;

            if p_latest_acceptable_date is NOT NULL then
               l_line_tbl(l_rec).latest_acceptable_date := p_latest_acceptable_date;
            end if;

            if p_line_category_code is NOT NULL then
               l_line_tbl(l_rec).line_category_code:= p_line_category_code;
            end if;

            if p_line_id is NOT NULL then
               l_line_tbl(l_rec).line_id := p_line_id;
            end if;

            if  p_line_number is NOT NULL then
               l_line_tbl(l_rec).line_number :=p_line_number;
            end if;

            if  p_line_type_id is NOT NULL then
               l_line_tbl(l_rec).line_type_id :=p_line_type_id;
            end if;

            if   p_link_to_line_id is NOT NULL then
               l_line_tbl(l_rec).link_to_line_id  :=p_link_to_line_id;
            end if;

            if  p_model_group_number is NOT NULL then
               l_line_tbl(l_rec).model_group_number:= p_model_group_number;
            end if;

            if  p_option_flag is NOT NULL then
               l_line_tbl(l_rec).option_flag := p_option_flag;
            end if;

            if  p_option_number is NOT NULL then
               l_line_tbl(l_rec).option_number :=p_option_number;
            end if;

            if  p_ordered_quantity is NOT NULL then
               l_line_tbl(l_rec).ordered_quantity :=p_ordered_quantity;
            end if;

            if  p_order_quantity_uom is NOT NULL then
               l_line_tbl(l_rec).order_quantity_uom :=p_order_quantity_uom;
            end if;

            if  p_orig_sys_document_ref is NOT NULL then
               l_line_tbl(l_rec).orig_sys_document_ref :=p_orig_sys_document_ref;
            end if;

            if  p_orig_sys_line_ref is NOT NULL then
               l_line_tbl(l_rec).orig_sys_line_ref :=p_orig_sys_line_ref;
            end if;

            if  p_payment_term_id is NOT NULL then
               l_line_tbl(l_rec).payment_term_id :=p_payment_term_id;
            end if;

            if  p_price_list_id is NOT NULL then
               l_line_tbl(l_rec).price_list_id :=p_price_list_id;
            end if;

            if  p_pricing_attribute1 is NOT NULL then
               l_line_tbl(l_rec).pricing_attribute1:= p_pricing_attribute1;
            end if;

            if  p_pricing_attribute10 is NOT NULL then
               l_line_tbl(l_rec).pricing_attribute10 :=p_pricing_attribute10;
            end if;

            if  p_pricing_attribute2 is NOT NULL then
               l_line_tbl(l_rec).pricing_attribute2 :=p_pricing_attribute2;
            end if;

            if  p_pricing_attribute3 is NOT NULL then
               l_line_tbl(l_rec).pricing_attribute3 :=p_pricing_attribute3;
            end if;

            if  p_pricing_attribute4 is NOT NULL then
               l_line_tbl(l_rec).pricing_attribute4 :=p_pricing_attribute4;
            end if;

            if  p_pricing_attribute5 is NOT NULL then
               l_line_tbl(l_rec).pricing_attribute5 :=p_pricing_attribute5;
            end if;

            if  p_pricing_attribute6 is NOT NULL then
               l_line_tbl(l_rec).pricing_attribute6 :=p_pricing_attribute6;
            end if;

            if  p_pricing_attribute7 is NOT NULL then
               l_line_tbl(l_rec).pricing_attribute7 :=p_pricing_attribute7;
            end if;

            if  p_pricing_attribute8 is NOT NULL then
               l_line_tbl(l_rec).pricing_attribute8 :=p_pricing_attribute8;
            end if;

            if  p_pricing_attribute9 is NOT NULL then
               l_line_tbl(l_rec).pricing_attribute9 :=p_pricing_attribute9;
            end if;

            if  p_pricing_context is NOT NULL then
               l_line_tbl(l_rec).pricing_context :=p_pricing_context;
            end if;

            if   p_pricing_date is NOT NULL then
               l_line_tbl(l_rec).pricing_date  :=p_pricing_date;
            end if;

            if   p_pricing_quantity is NOT NULL then
               l_line_tbl(l_rec).pricing_quantity :=p_pricing_quantity;
            end if;

            if   p_pricing_quantity_uom is NOT NULL then
               l_line_tbl(l_rec).pricing_quantity_uom:= p_pricing_quantity_uom;
            end if;

            if   p_project_id is NOT NULL then
               l_line_tbl(l_rec).project_id:= p_project_id;
            end if;

            if   p_promise_date is NOT NULL then
               l_line_tbl(l_rec).promise_date:= p_promise_date;
            end if;

            if    p_reference_header_id is NOT NULL then
               l_line_tbl(l_rec).reference_header_id  :=p_reference_header_id;
            end if;

            if  p_reference_line_id is NOT NULL then
               l_line_tbl(l_rec).reference_line_id :=p_reference_line_id;
            end if;

            if   p_reference_type is NOT NULL then
               l_line_tbl(l_rec).reference_type :=p_reference_type;
            end if;

            if    p_request_date  is NOT NULL then
               l_line_tbl(l_rec).request_date   :=p_request_date ;
            end if;

            if    p_reserved_quantity  is NOT NULL then
               l_line_tbl(l_rec).reserved_quantity :=p_reserved_quantity;
            end if;

            if    p_return_attribute1  is NOT NULL then
               l_line_tbl(l_rec).return_attribute1 :=p_return_attribute1;
            end if;

            if    p_return_attribute10  is NOT NULL then
               l_line_tbl(l_rec).return_attribute10 :=p_return_attribute10;
            end if;

            if    p_return_attribute11  is NOT NULL then
               l_line_tbl(l_rec).return_attribute11 :=p_return_attribute11;
            end if;

            if    p_return_attribute12  is NOT NULL then
               l_line_tbl(l_rec).return_attribute12 :=p_return_attribute12;
            end if;

            if    p_return_attribute13  is NOT NULL then
               l_line_tbl(l_rec).return_attribute13 :=p_return_attribute13;
            end if;

            if    p_return_attribute14  is NOT NULL then
               l_line_tbl(l_rec).return_attribute14 :=p_return_attribute14;
            end if;

            if    p_return_attribute2  is NOT NULL then
               l_line_tbl(l_rec).return_attribute2 :=p_return_attribute2;
            end if;

            if    p_return_attribute3  is NOT NULL then
               l_line_tbl(l_rec).return_attribute3 :=p_return_attribute3;
            end if;

            if    p_return_attribute4  is NOT NULL then
               l_line_tbl(l_rec).return_attribute4 :=p_return_attribute4;
            end if;

            if    p_return_attribute5  is NOT NULL then
               l_line_tbl(l_rec).return_attribute5 :=p_return_attribute5;
            end if;

            if    p_return_attribute6  is NOT NULL then
               l_line_tbl(l_rec).return_attribute6 :=p_return_attribute6;
            end if;

            if    p_return_attribute7  is NOT NULL then
               l_line_tbl(l_rec).return_attribute7 :=p_return_attribute7;
            end if;

            if    p_return_attribute8  is NOT NULL then
               l_line_tbl(l_rec).return_attribute8 :=p_return_attribute8;
            end if;

            if    p_return_attribute9  is NOT NULL then
               l_line_tbl(l_rec).return_attribute9 :=p_return_attribute9;
            end if;

            if    p_return_context  is NOT NULL then
               l_line_tbl(l_rec).return_context :=p_return_context;
            end if;

            if  p_rla_schedule_type_code  is NOT NULL then
               l_line_tbl(l_rec).rla_schedule_type_code :=p_rla_schedule_type_code;
            end if;

            if    p_schedule_arrival_date  is NOT NULL then
               l_line_tbl(l_rec).schedule_arrival_date :=p_schedule_arrival_date;
            end if;

            if    p_schedule_ship_date  is NOT NULL then
               l_line_tbl(l_rec).schedule_ship_date :=p_schedule_ship_date;
            end if;

            if    p_schedule_action_code  is NOT NULL then
               l_line_tbl(l_rec).schedule_action_code :=p_schedule_action_code;
            end if;

            if    p_schedule_status_code  is NOT NULL then
               l_line_tbl(l_rec).schedule_status_code :=p_schedule_status_code;
            end if;

            if    p_shipped_quantity  is NOT NULL then
               l_line_tbl(l_rec).shipped_quantity :=p_shipped_quantity;
            end if;

            if    p_shipment_number  is NOT NULL then
               l_line_tbl(l_rec).shipment_number :=p_shipment_number;
            end if;

            if     p_shipment_priority_code  is NOT NULL then
               l_line_tbl(l_rec).shipment_priority_code  :=p_shipment_priority_code;
            end if;

            if    p_shipping_method_code  is NOT NULL then
               l_line_tbl(l_rec).shipping_method_code:=p_shipping_method_code;
            end if;

            if    p_shipping_quantity  is NOT NULL then
               l_line_tbl(l_rec).shipping_quantity :=p_shipping_quantity;
            end if;

            if    p_shipping_quantity_uom  is NOT NULL then
               l_line_tbl(l_rec).shipping_quantity_uom :=p_shipping_quantity_uom;
            end if;

            if    p_ship_from_org_id  is NOT NULL then
               l_line_tbl(l_rec).ship_from_org_id :=p_ship_from_org_id;
            end if;

            if    p_ship_tolerance_above  is NOT NULL then
               l_line_tbl(l_rec).ship_tolerance_above :=p_ship_tolerance_above;
            end if;

            if    p_ship_tolerance_below  is NOT NULL then
               l_line_tbl(l_rec).ship_tolerance_below :=p_ship_tolerance_below;
            end if;

            if    p_shipping_interfaced_flag  is NOT NULL then
               l_line_tbl(l_rec).shipping_interfaced_flag :=p_shipping_interfaced_flag;
            end if;

            if    p_ship_to_contact_id  is NOT NULL then
               l_line_tbl(l_rec).ship_to_contact_id:=p_ship_to_contact_id;
            end if;

            if    p_ship_to_org_id  is NOT NULL then
               l_line_tbl(l_rec).ship_to_org_id :=p_ship_to_org_id;
            end if;

            if     p_ship_model_complete_flag  is NOT NULL then
               l_line_tbl(l_rec).ship_model_complete_flag := p_ship_model_complete_flag;
            end if;

            if    p_sold_to_org_id  is NOT NULL then
               l_line_tbl(l_rec).sold_to_org_id:=p_sold_to_org_id;
            end if;

            if    p_sort_order  is NOT NULL then
               l_line_tbl(l_rec).sort_order :=p_sort_order;
            end if;

            if    p_source_document_id  is NOT NULL then
               l_line_tbl(l_rec).source_document_id:=p_source_document_id;
            end if;

            if    p_source_document_line_id  is NOT NULL then
               l_line_tbl(l_rec).source_document_line_id :=p_source_document_line_id;
            end if;

            if    p_source_document_type_id  is NOT NULL then
               l_line_tbl(l_rec).source_document_type_id :=p_source_document_type_id;
            end if;

            if    p_source_type_code  is NOT NULL then
               l_line_tbl(l_rec).source_type_code :=p_source_type_code;
            end if;

            if    p_task_id  is NOT NULL then
               l_line_tbl(l_rec).task_id :=p_task_id;
            end if;

            if    p_tax_code  is NOT NULL then
               l_line_tbl(l_rec).tax_code :=p_tax_code;
            end if;

            if    p_tax_date is NOT NULL then
               l_line_tbl(l_rec).tax_date :=p_tax_date;
            end if;

            if     p_tax_exempt_flag  is NOT NULL then
               l_line_tbl(l_rec).tax_exempt_flag := p_tax_exempt_flag;
            end if;

            if    p_tax_exempt_number  is NOT NULL then
               l_line_tbl(l_rec).tax_exempt_number :=p_tax_exempt_number;
            end if;

            if    p_tax_exempt_reason_code  is NOT NULL then
               l_line_tbl(l_rec).tax_exempt_reason_code :=p_tax_exempt_reason_code;
            end if;

            if    p_tax_point_code  is NOT NULL then
               l_line_tbl(l_rec).tax_point_code :=p_tax_point_code;
            end if;

            if    p_tax_rate  is NOT NULL then
               l_line_tbl(l_rec).tax_rate :=p_tax_rate;
            end if;

            if    p_tax_value  is NOT NULL then
               l_line_tbl(l_rec).tax_value :=p_tax_value;
            end if;

            if    p_top_model_line_id  is NOT NULL then
               l_line_tbl(l_rec).top_model_line_id :=p_top_model_line_id;
            end if;

            if    p_unit_list_price  is NOT NULL then
               l_line_tbl(l_rec).unit_list_price :=p_unit_list_price;
            end if;

            if    p_unit_selling_price  is NOT NULL then
               l_line_tbl(l_rec).unit_selling_price :=p_unit_selling_price;
               --  bug 3926188 l_line_tbl(l_rec).calculate_price_flag := 'P';
            end if;

            if  p_visible_demand_flag  is NOT NULL then
               l_line_tbl(l_rec).visible_demand_flag :=p_visible_demand_flag;
            end if;


            if     p_split_from_line_id  is NOT NULL then
               l_line_tbl(l_rec).split_from_line_id := p_split_from_line_id;
            end if;

            if    p_cust_production_seq_num  is NOT NULL then
               l_line_tbl(l_rec).cust_production_seq_num :=p_cust_production_seq_num;
            end if;

            if    p_authorized_to_ship_flag  is NOT NULL then
               l_line_tbl(l_rec).authorized_to_ship_flag :=p_authorized_to_ship_flag;
            end if;

            if    p_veh_cus_item_cum_key_id  is NOT NULL then
               l_line_tbl(l_rec).veh_cus_item_cum_key_id :=p_veh_cus_item_cum_key_id;
            end if;

            if     p_salesrep_id  is NOT NULL then
               l_line_tbl(l_rec).salesrep_id:= p_salesrep_id;
            end if;

            if    p_return_reason_code  is NOT NULL then
               l_line_tbl(l_rec).return_reason_code :=p_return_reason_code;
            end if;

            if p_arrival_set_id  is NOT NULL then
               l_line_tbl(l_rec).arrival_set_id :=p_arrival_set_id;
            end if;

            if    p_ship_set_id  is NOT NULL then
               l_line_tbl(l_rec).ship_set_id :=p_ship_set_id;
            end if;

            if    p_over_ship_reason_code  is NOT NULL then
               l_line_tbl(l_rec).over_ship_reason_code :=p_over_ship_reason_code;
            end if;

            if    p_over_ship_resolved_flag  is NOT NULL then
               l_line_tbl(l_rec).over_ship_resolved_flag :=p_over_ship_resolved_flag;
            end if;

            if     p_first_ack_code  is NOT NULL then
               l_line_tbl(l_rec).first_ack_code := p_first_ack_code;
            end if;

            if    p_first_ack_date  is NOT NULL then
               l_line_tbl(l_rec).first_ack_date:=p_first_ack_date;
            end if;

            if    p_last_ack_code  is NOT NULL then
               l_line_tbl(l_rec).last_ack_code:=p_last_ack_code;
            end if;

            if    p_last_ack_date  is NOT NULL then
               l_line_tbl(l_rec).last_ack_date:=p_last_ack_date;
            end if;

            if    p_service_txn_reason_code is NOT NULL then
               l_line_tbl(l_rec).service_txn_reason_code := p_service_txn_reason_code;
            end if;

            if    p_service_txn_comments is NOT NULL then
               l_line_tbl(l_rec).service_txn_comments := p_service_txn_comments;
            end if;

            if    p_unit_selling_percent is NOT NULL then
               l_line_tbl(l_rec).unit_selling_percent := p_unit_selling_percent;
            end if;

            if    p_unit_list_percent is NOT NULL then
               l_line_tbl(l_rec).unit_list_percent := p_unit_list_percent;
            end if;

            if    p_unit_percent_base_price is NOT NULL then
               l_line_tbl(l_rec).unit_percent_base_price := p_unit_percent_base_price;
            end if;

            if    p_service_duration is NOT NULL then
               l_line_tbl(l_rec).service_duration := p_service_duration;
            end if;

            if    p_service_start_date is NOT NULL then
               l_line_tbl(l_rec).service_start_date := p_service_start_date;
            end if;

            if    p_service_period is NOT NULL then
               l_line_tbl(l_rec).service_period := p_service_period;
            end if;

            if    p_service_end_date is NOT NULL then
               l_line_tbl(l_rec).service_end_date := p_service_end_date;
            end if;

            if    p_service_coterminate_flag is NOT NULL then
               l_line_tbl(l_rec).service_coterminate_flag := p_service_coterminate_flag;
            end if;

            if    p_service_number is NOT NULL then
               l_line_tbl(l_rec).service_number := p_service_number;
            end if;

            if    p_service_reference_type_code is NOT NULL then
               l_line_tbl(l_rec).service_reference_type_code := p_service_reference_type_code;
            end if;

            if    p_service_reference_line_id is NOT NULL then
               l_line_tbl(l_rec).service_reference_line_id := p_service_reference_line_id;
            end if;

            if    p_service_reference_system_id is NOT NULL then
               l_line_tbl(l_rec).service_reference_system_id := p_service_reference_system_id;
            end if;

            if p_tp_context  is NOT NULL then
               l_line_tbl(l_rec).tp_context := p_tp_context;
            end if;

            if p_tp_attribute1  is NOT NULL then
               l_line_tbl(l_rec).tp_attribute1 := p_tp_attribute1;
            end if;

            if p_tp_attribute2  is NOT NULL then
               l_line_tbl(l_rec).tp_attribute2 := p_tp_attribute2;
            end if;

            if p_tp_attribute3  is NOT NULL then
               l_line_tbl(l_rec).tp_attribute3 := p_tp_attribute3;
            end if;

            if p_tp_attribute4  is NOT NULL then
               l_line_tbl(l_rec).tp_attribute4 := p_tp_attribute4;
            end if;

            if p_tp_attribute5  is NOT NULL then
               l_line_tbl(l_rec).tp_attribute5 := p_tp_attribute5;
            end if;

            if p_tp_attribute6  is NOT NULL then
               l_line_tbl(l_rec).tp_attribute6 := p_tp_attribute6;
            end if;

            if p_tp_attribute7  is NOT NULL then
               l_line_tbl(l_rec).tp_attribute7 := p_tp_attribute7;
            end if;

            if p_tp_attribute8  is NOT NULL then
               l_line_tbl(l_rec).tp_attribute8 := p_tp_attribute8;
            end if;

            if p_tp_attribute9  is NOT NULL then
               l_line_tbl(l_rec).tp_attribute9 := p_tp_attribute9;
            end if;

            if p_tp_attribute10  is NOT NULL then
               l_line_tbl(l_rec).tp_attribute10 := p_tp_attribute10;
            end if;

            if p_tp_attribute11  is NOT NULL then
               l_line_tbl(l_rec).tp_attribute11 := p_tp_attribute11;
            end if;

            if p_tp_attribute12  is NOT NULL then
               l_line_tbl(l_rec).tp_attribute12 := p_tp_attribute12;
            end if;

            if p_tp_attribute13  is NOT NULL then
               l_line_tbl(l_rec).tp_attribute13 := p_tp_attribute13;
            end if;

            if p_tp_attribute14  is NOT NULL then
               l_line_tbl(l_rec).tp_attribute14 := p_tp_attribute14;
            end if;

            if p_tp_attribute15  is NOT NULL then
               l_line_tbl(l_rec).tp_attribute15 := p_tp_attribute15;
            end if;

            if p_calculate_price_flag  is NOT NULL then
               l_line_tbl(l_rec).calculate_price_flag := p_calculate_price_flag;
            end if;

            if p_end_customer_contact_id is not null then
               l_line_tbl(l_rec).end_customer_contact_id := p_end_customer_contact_id;
            end if;

            if p_end_customer_id is not null then
               l_line_tbl(l_rec).end_customer_id :=  p_end_customer_id;
            end if;

            if  p_end_customer_site_use_id is not null then
               l_line_tbl(l_rec).end_customer_site_use_id := p_end_customer_site_use_id;
            end if;

            if  p_ib_owner is not null then
               l_line_tbl(l_rec).ib_owner := p_ib_owner;
            end if;

            if  p_ib_installed_at_location  is not null then
               l_line_tbl(l_rec).ib_installed_at_location := p_ib_installed_at_location;
            end if;

            if  p_ib_current_location  is not null then
               l_line_tbl(l_rec).ib_current_location := p_ib_current_location;
            end if;

            FETCH c1 into l_line_id, l_current_org_id, l_header_id, l_arrival_set_id,
                          l_ship_set_id, l_top_model_line_id;
            EXIT WHEN c1%notfound;
            --- Start bug 6850537,7210480

           IF l_header_id <> l_old_header_id
            THEN
              IF l_debug_level>0 THEN
                oe_debug_pub.ADD('header id got changed'||l_header_id||' '||l_old_header_id);
               END IF;
             G_HEADER_CHANGED :=1;

             --Bug 7566697
             l_header_changed := TRUE;
           ELSE
             l_header_changed := FALSE;
           END IF;

        -- End bug 6850537 ,7210480

            -- If all old values are null then old line was a standard line.
            if ( l_old_arrival_set_id is null
                 and l_old_ship_set_id is null
                 and l_old_top_model_line_id is null )
            then
               exit;
            end if;

            if l_header_id <> l_old_header_id or
               nvl(l_arrival_set_id, 0) <> nvl(l_old_arrival_set_id, 0) or
               nvl(l_ship_set_id, 0) <> nvl(l_old_ship_set_id, 0) or
               nvl(l_top_model_line_id, 0) <> nvl(l_old_top_model_line_id, 0)
            then
               exit;
            end if;

         END LOOP;

         l_control_rec.controlled_operation := TRUE;
         l_control_rec.process              := FALSE;
         l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_ALL;
         l_control_rec.Process_Partial      := FALSE;
         l_control_rec.check_security       := TRUE;
         l_control_rec.clear_dependents     := TRUE;
         l_control_rec.default_attributes   := TRUE;
         l_control_rec.change_attributes    := TRUE;
         l_control_rec.validate_entity      := TRUE;
         l_control_rec.write_to_DB          := TRUE;

         --bug4529937 start --bug 6850537,7210480 added  p_block_name='LINES_SUMMARY'
         IF p_block_name = 'LINE' or p_block_name='LINES_SUMMARY' THEN
            G_NUM_OF_LINES := G_NUM_OF_LINES - l_line_tbl.count;
         END IF;

         IF l_debug_level > 0 THEN
            oe_debug_pub.add('Lines Remaining: ' || G_NUM_OF_LINES);
            OE_DEBUG_PUB.Add('Before Call to Process Order From MC');
         END IF;
         --bug4529937 end

         -- bug 4339639
         OE_Versioning_Util.G_UI_CALLED := TRUE;

         Oe_Order_Pvt.Lines
            (   p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
                p_init_msg_list               => l_init_msg_list,
                p_control_rec                 => l_control_rec,
                p_x_line_tbl                  => l_line_tbl,
                p_x_old_line_tbl              => l_old_line_tbl,
                x_return_status               => l_return_status);

         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('After Call to Process Order From MC - ' || l_return_status);
         END IF;

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         l_control_rec.controlled_operation := TRUE;
         l_control_rec.process              := TRUE;
         l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_ALL;

         l_control_rec.check_security       := FALSE;
         l_control_rec.clear_dependents     := FALSE;
         l_control_rec.default_attributes   := FALSE;
         l_control_rec.change_attributes    := FALSE;
         l_control_rec.validate_entity      := FALSE;
         l_control_rec.write_to_DB          := FALSE;

         --  Instruct API to clear its request table

         l_control_rec.clear_api_cache      := FALSE;
         l_control_rec.clear_api_requests   := TRUE;

         oe_line_util.Post_Line_Process
            (   p_control_rec    => l_control_rec,
                p_x_line_tbl   => l_line_tbl );

         -- added a call to PRN for bug 4882981
         OE_Order_PVT.Process_Requests_And_Notify
                   ( p_process_requests          => TRUE,
                     p_notify                    => TRUE,
                     x_return_status             => l_return_status,
                     p_old_line_tbl                  => l_old_line_tbl,
                     p_line_tbl              => l_line_tbl) ;

         IF l_debug_level > 0 THEN
            oe_debug_pub.ADD('OEXVMSCB: Completed Process_Delayed_Requests '
                             || ' with return status' || l_return_status, 2);
         END IF;
         G_HEADER_CHANGED :=NULL ;  -- - bug 6850537,7210480
         -- Bug 1809955
         -- Display any errors/messages that were caused
         -- as a result of the delayed request execution
         OE_MSG_PUB.Count_and_Get(p_count => p_msg_count,
                                  p_data => p_msg_data);

         IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN
            IF l_debug_level > 0 THEN
               oe_debug_pub.ADD('Exception - FND_API.G_EXC_ERROR');
            END IF;

            p_return_status := FND_API.G_RET_STS_ERROR ;
            OE_SET_UTIL.G_SET_TBL.delete; --bug#2428456
            OE_SET_UTIL.G_SET_OPT_TBL.delete; -- bug#2428456

            oe_delayed_requests_pvt.Clear_Request(x_return_status=> l_return_status);

            OE_ORDER_UTIL.Clear_Global_Picture(l_return_status);

            IF l_debug_level > 0 THEN
               oe_debug_pub.ADD ('OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.COUNT - '
                                 || OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.COUNT);
            END IF;

            IF OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.COUNT > 0 THEN -- moved for the bug 3726337
               OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.DELETE;
            END IF;

            OE_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                       p_data  => p_msg_data);

            l_error_count := l_error_count + 1;
            p_error_count := l_error_count;

            IF l_debug_level > 0 THEN
               oe_debug_pub.ADD ('l_line_tbl.count - ' || l_line_tbl.count);
            END IF;

            IF (l_line_tbl.count >0 ) then
               G_ERROR_COUNT := G_ERROR_COUNT +  l_line_tbl.COUNT;
            END IF;

            ROLLBACK TO SAVEPOINT Process_Line_Scalar;

            --Bug 7566697
            OE_Globals.G_PRICING_RECURSION := 'N';
            IF OE_MASS_CHANGE_PVT.G_PRICING_ERROR = 'Y'
            THEN
               oe_debug_pub.add('Pricing error has occured. Rolling back changes done to all lines');
               ROLLBACK TO SAVEPOINT Pricing_Header_Savepoint;
            END IF;

            IF l_debug_level > 0 THEN
               oe_debug_pub.ADD ('l_mc_err_handling_flag - ' || l_mc_err_handling_flag);
            END IF;

            if l_mc_err_handling_flag in (EXIT_FIRST_ERROR,SKIP_CONTINUE) then
               OE_DEBUG_PUB.Add('EXIT_FIRST_ERROR  SKIP_CONTINUE');
               exit;
            else
               OE_DEBUG_PUB.Add('SKIP_ALL');
            end if;

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF l_debug_level > 0 THEN
               oe_debug_pub.ADD('Exception - FND_API.G_EXC_UNEXPECTED_ERROR');
            END IF;

            p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            OE_SET_UTIL.G_SET_TBL.delete; --bug#2428456
            OE_SET_UTIL.G_SET_OPT_TBL.delete; -- bug#2428456

            oe_delayed_requests_pvt.Clear_Request(x_return_status=> l_return_status);

            OE_ORDER_UTIL.Clear_Global_Picture(l_return_status);

            IF l_debug_level > 0 THEN
               oe_debug_pub.ADD ('OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.COUNT - '
                                 || OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.COUNT);
            END IF;

            IF OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.COUNT > 0 THEN -- moved for the bug 3726337
               OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.DELETE;
            END IF;

            OE_MSG_PUB.Count_And_Get( p_count => p_msg_count,
                                      p_data  => p_msg_data);

            l_error_count := l_error_count + 1;
            p_error_count := l_error_count;

            IF l_debug_level > 0 THEN
               oe_debug_pub.ADD ('l_line_tbl.count - ' || l_line_tbl.count);
            END IF;

            IF (l_line_tbl.count >0 ) then
               G_ERROR_COUNT := G_ERROR_COUNT +  l_line_tbl.COUNT;
            END IF;

            ROLLBACK TO SAVEPOINT Process_Line_Scalar;

            --Bug 7566697
            OE_Globals.G_PRICING_RECURSION := 'N';
            IF OE_MASS_CHANGE_PVT.G_PRICING_ERROR = 'Y'
            THEN
               oe_debug_pub.add('Pricing error has occured. Rolling back changes done to all lines');
               ROLLBACK TO SAVEPOINT Pricing_Header_Savepoint;
            END IF;

            IF l_debug_level > 0 THEN
               oe_debug_pub.ADD ('l_mc_err_handling_flag - ' || l_mc_err_handling_flag);
            END IF;

            if l_mc_err_handling_flag in (EXIT_FIRST_ERROR,SKIP_CONTINUE) then
               OE_DEBUG_PUB.Add('EXIT_FIRST_ERROR  SKIP_CONTINUE');
               exit;
            else
               OE_DEBUG_PUB.Add('SKIP_ALL');
            end if;

         WHEN OTHERS THEN
            IF l_debug_level > 0 THEN
               oe_debug_pub.ADD('Exception - FND_API.G_EXC_ERROR');
            END IF;

            p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            OE_SET_UTIL.G_SET_TBL.delete; --bug#2428456
            OE_SET_UTIL.G_SET_OPT_TBL.delete; -- bug#2428456

            oe_delayed_requests_pvt.Clear_Request(x_return_status=> l_return_status);

            OE_ORDER_UTIL.Clear_Global_Picture(l_return_status);

            IF l_debug_level > 0 THEN
               oe_debug_pub.ADD ('OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.COUNT - '
                                 || OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.COUNT);
            END IF;

            IF OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.COUNT > 0 THEN -- moved for the bug 3726337
               OE_Config_Pvt.OE_MODIFY_INC_ITEMS_TBL.DELETE;
            END IF;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                       l_api_name);
            END IF;

            OE_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
                                       p_data  => p_msg_data);

            l_error_count := l_error_count + 1;
            p_error_count := l_error_count;

            IF l_debug_level > 0 THEN
               oe_debug_pub.ADD ('l_line_tbl.count - ' || l_line_tbl.count);
            END IF;

            IF (l_line_tbl.count >0 ) then
               G_ERROR_COUNT := G_ERROR_COUNT +  l_line_tbl.COUNT;
            END IF;

            ROLLBACK TO SAVEPOINT Process_Line_Scalar;

            --Bug 7566697
            OE_Globals.G_PRICING_RECURSION := 'N';
            IF OE_MASS_CHANGE_PVT.G_PRICING_ERROR = 'Y'
            THEN
               oe_debug_pub.add('Pricing error has occured. Rolling back changes done to all lines');
               ROLLBACK TO SAVEPOINT Pricing_Header_Savepoint;
            END IF;


            IF l_debug_level > 0 THEN
               oe_debug_pub.ADD ('l_mc_err_handling_flag - ' || l_mc_err_handling_flag);
            END IF;

            if l_mc_err_handling_flag in (EXIT_FIRST_ERROR,SKIP_CONTINUE) then
               OE_DEBUG_PUB.Add('EXIT_FIRST_ERROR  SKIP_CONTINUE');
               exit;
            else
               OE_DEBUG_PUB.Add('SKIP_ALL');
            end if;
      END;

      exit when c1%notfound;
   END LOOP;

   G_BLK_NAME := NULL;
   G_NUM_OF_LINES := NULL;
G_HEADER_CHANGED :=NULL ;  -- - bug 6850537,7210480
   IS_MASS_CHANGE := 'F'; --Added for bug 4911340

   IF l_debug_level > 0 THEN
      oe_debug_pub.add('Exiting OE_MASS_CHANGE_PVT.Process_Line_Scalar');
   END IF;
end Process_Line_Scalar;

Procedure MC_Rollback
IS
begin
  rollback;
end;

Procedure Set_Counter
IS
begin
   G_COUNTER := 0;
end;

Function Get_Counter  return NUMBER
IS
begin
   return G_COUNTER;
end;

Procedure Set_Error_Count
IS
begin
   G_ERROR_COUNT := 0;
end;

Function Get_Error_Count  return NUMBER
IS
begin
   return G_ERROR_COUNT;
end;

Procedure save_messages
IS
l_count_msg NUMBER := OE_MSG_PUB.Count_Msg;
begin
   OE_DEBUG_PUB.ADD('Inside save_messages',1);
   FOR I IN 1..l_count_msg  LOOP
   OE_DEBUG_PUB.ADD('calling insert_message',1);
    insert_message(I);
   End Loop;
   OE_DEBUG_PUB.ADD('exiting save_messages',1);
   commit;
end;

procedure insert_message (
         p_msg_index         IN NUMBER )
IS
l_msg_data        	       VARCHAR2(2000);
l_entity_code                  VARCHAR2(30);
l_entity_id                    NUMBER;
l_header_id                    NUMBER;
l_line_id                      NUMBER;
l_orig_sys_document_ref        VARCHAR2(50);
l_orig_sys_document_line_ref   VARCHAR2(50);
l_source_document_id           NUMBER;
l_source_document_line_id      NUMBER;
l_attribute_code               VARCHAR2(30);

BEGIN
 l_msg_data := OE_MSG_PUB.get(p_msg_index, 'F');

 /*OE_MSG_PUB.get_msg_context(
         p_msg_index
	,l_entity_code
	,l_entity_id
	,l_header_id
	,l_line_id
	,l_orig_sys_document_ref
	,l_orig_sys_document_line_ref
	,l_source_document_id
	,l_source_document_line_id
	,l_attribute_code);*/

OE_DEBUG_PUB.ADd('l_msg_data='||l_msg_data);

/*
if p_msg_index IS NOT NULL then
   insert into OE_ERROR_MESSAGES
   (  Transaction_id
     ,batch_request_Id
     ,message_text
     ,entity_code
     ,entity_id
     ,header_id
     ,line_id
     ,original_sys_document_ref
     ,original_sys_document_line_ref
     ,source_document_id
     ,source_document_line_id
     ,attribute_code
     ,CREATION_DATE
     ,CREATED_BY
     ,LAST_UPDATE_DATE
     ,LAST_UPDATED_BY
     ,LAST_UPDATE_LOGIN
     ,PROGRAM_APPLICATION_ID
     ,PROGRAM_ID
     ,PROGRAM_UPDATE_DATE
    ) VALUES
    ( oe_msg_id_S.NEXTVAL
     ,NULL
     ,l_msg_data
     ,l_entity_code
     ,l_entity_id
     ,l_header_id
     ,l_line_id
     ,l_orig_sys_document_ref
     ,l_orig_sys_document_line_ref
     ,l_source_document_id
     ,l_source_document_line_id
     ,l_attribute_code
     ,sysdate
     ,-1
     ,sysdate
     ,-1
     ,-1
     ,NULL
     ,NULL
     ,NULL
     );
  end if;
*/
End insert_message;

-- 4020312
-- Function to pipeline the table of selected lines for mass change.
FUNCTION get_sel_rec_tbl RETURN Sel_Rec_Tbl
PIPELINED IS
   l_row OE_GLOBALS.Selected_Record_Type;
BEGIN
   FOR i IN g_sel_rec_tbl.first..g_sel_rec_tbl.last LOOP
      l_row.id1    := g_sel_rec_tbl(i).id1;
      l_row.id2    := g_sel_rec_tbl(i).id2;
      l_row.id3    := g_sel_rec_tbl(i).id3;
      l_row.id4    := g_sel_rec_tbl(i).id4;
      l_row.id5    := g_sel_rec_tbl(i).id5;
      l_row.org_id := g_sel_rec_tbl(i).org_id;
      PIPE ROW (l_row);
   END LOOP;
   RETURN;
END get_sel_rec_tbl;

end OE_MASS_CHANGE_PVT;

/
