--------------------------------------------------------
--  DDL for Package Body OE_BLANKET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BLANKET_PUB" AS
/* $Header: OEXPBSOB.pls 120.0.12010000.5 2009/01/24 01:08:04 smusanna ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Blanket_PUB';

PROCEDURE  set_context   (p_org_id in number) is
   l_org_id number ;
   l_return_status varchar2(1);
   l_debug_level  CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
   l_org_id := p_org_id;
   if l_debug_level  > 0 then
    oe_debug_pub.add('Entering set_context');
    oe_debug_pub.add('Org_id is '||nvl(p_org_id,-1));
   end if;
   MO_GLOBAL.set_policy_context('S',l_org_id);   -- remove this and next line
   oe_debug_pub.add('After Set Policy Context ');
   OE_GLOBALS.Set_Context();
END ;


----------------------------------------------------------
     PROCEDURE Header_Id_Conversion
----------------------------------------------------------
    (   p_header_val_rec         IN  OUT NOCOPY OE_Blanket_PUB.Header_Val_Rec_type
    ,   p_header_rec     IN  OUT NOCOPY  OE_Blanket_PUB.Header_Rec_type
    )IS
       l_header_val_rec     OE_Order_PUB.Header_Val_Rec_Type;
       l_header_rec         OE_Order_PUB.Header_Rec_Type;
       l_order_type_d          INTEGER ;
       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
     BEGIN
          oe_debug_pub.add('In Header Id Conversion ');

l_header_val_rec.accounting_rule               :=	p_header_val_rec.accounting_rule               ;
l_header_val_rec.agreement                     :=	p_header_val_rec.agreement                     ;
l_header_val_rec.conversion_type               :=	p_header_val_rec.conversion_type               ;
l_header_val_rec.deliver_to_address1           :=	p_header_val_rec.deliver_to_address1           ;
l_header_val_rec.deliver_to_address2           :=	p_header_val_rec.deliver_to_address2           ;
l_header_val_rec.deliver_to_address3           :=	p_header_val_rec.deliver_to_address3           ;
l_header_val_rec.deliver_to_address4           :=	p_header_val_rec.deliver_to_address4           ;
l_header_val_rec.deliver_to_contact            :=	p_header_val_rec.deliver_to_contact            ;
l_header_val_rec.deliver_to_location           :=	p_header_val_rec.deliver_to_location           ;
l_header_val_rec.deliver_to_org                :=	p_header_val_rec.deliver_to_org                ;
l_header_val_rec.deliver_to_state              :=	p_header_val_rec.deliver_to_state              ;
l_header_val_rec.deliver_to_city               :=	p_header_val_rec.deliver_to_city               ;
l_header_val_rec.deliver_to_zip                :=	p_header_val_rec.deliver_to_zip                ;
l_header_val_rec.deliver_to_country            :=	p_header_val_rec.deliver_to_country            ;
l_header_val_rec.deliver_to_county             :=	p_header_val_rec.deliver_to_county             ;
l_header_val_rec.deliver_to_province           :=	p_header_val_rec.deliver_to_province           ;
l_header_val_rec.freight_terms                 :=	p_header_val_rec.freight_terms                 ;
l_header_val_rec.invoice_to_address1           :=	p_header_val_rec.invoice_to_address1           ;
l_header_val_rec.invoice_to_address2           :=	p_header_val_rec.invoice_to_address2           ;
l_header_val_rec.invoice_to_address3           :=	p_header_val_rec.invoice_to_address3           ;
l_header_val_rec.invoice_to_address4           :=	p_header_val_rec.invoice_to_address4           ;
l_header_val_rec.invoice_to_state              :=	p_header_val_rec.invoice_to_state              ;
l_header_val_rec.invoice_to_city               :=	p_header_val_rec.invoice_to_city               ;
l_header_val_rec.invoice_to_zip                :=	p_header_val_rec.invoice_to_zip                ;
l_header_val_rec.invoice_to_country            :=	p_header_val_rec.invoice_to_country            ;
l_header_val_rec.invoice_to_county             :=	p_header_val_rec.invoice_to_county             ;
l_header_val_rec.invoice_to_province           :=	p_header_val_rec.invoice_to_province           ;
l_header_val_rec.invoice_to_contact            :=	p_header_val_rec.invoice_to_contact            ;
l_header_val_rec.invoice_to_contact_first_name :=	p_header_val_rec.invoice_to_contact_first_name ;
l_header_val_rec.invoice_to_contact_last_name :=	p_header_val_rec.invoice_to_contact_last_name ;
l_header_val_rec.invoice_to_location           :=	p_header_val_rec.invoice_to_location           ;
l_header_val_rec.invoice_to_org                :=	p_header_val_rec.invoice_to_org                ;
l_header_val_rec.invoicing_rule                :=	p_header_val_rec.invoicing_rule                ;
l_header_val_rec.order_source                  :=	p_header_val_rec.order_source                  ;
l_header_val_rec.order_type                    :=	p_header_val_rec.order_type                    ;
l_header_val_rec.payment_term                  :=	p_header_val_rec.payment_term                  ;
l_header_val_rec.price_list                    :=	p_header_val_rec.price_list                    ;
l_header_val_rec.salesrep               :=	p_header_val_rec.salesrep               ;
l_header_val_rec.ship_from_address1            :=	p_header_val_rec.ship_from_address1            ;
l_header_val_rec.ship_from_address2            :=	p_header_val_rec.ship_from_address2            ;
l_header_val_rec.ship_from_address3            :=	p_header_val_rec.ship_from_address3            ;
l_header_val_rec.ship_from_address4            :=	p_header_val_rec.ship_from_address4            ;
l_header_val_rec.ship_from_location            :=	p_header_val_rec.ship_from_location            ;
l_header_val_rec.SHIP_FROM_CITY               :=	p_header_val_rec.SHIP_FROM_CITY               ;
l_header_val_rec.SHIP_FROM_POSTAL_CODE        :=	p_header_val_rec.SHIP_FROM_POSTAL_CODE        ;
l_header_val_rec.SHIP_FROM_COUNTRY            :=	p_header_val_rec.SHIP_FROM_COUNTRY            ;
l_header_val_rec.SHIP_FROM_REGION1            :=	p_header_val_rec.SHIP_FROM_REGION1            ;
l_header_val_rec.SHIP_FROM_REGION2            :=	p_header_val_rec.SHIP_FROM_REGION2            ;
l_header_val_rec.SHIP_FROM_REGION3            :=	p_header_val_rec.SHIP_FROM_REGION3            ;
l_header_val_rec.ship_from_org                 :=	p_header_val_rec.ship_from_org                 ;
l_header_val_rec.sold_to_address1              :=	p_header_val_rec.sold_to_address1              ;
l_header_val_rec.sold_to_address2              :=	p_header_val_rec.sold_to_address2              ;
l_header_val_rec.sold_to_address3              :=	p_header_val_rec.sold_to_address3              ;
l_header_val_rec.sold_to_address4              :=	p_header_val_rec.sold_to_address4              ;
l_header_val_rec.sold_to_state                 :=	p_header_val_rec.sold_to_state                 ;
l_header_val_rec.sold_to_country               :=	p_header_val_rec.sold_to_country               ;
l_header_val_rec.sold_to_zip                   :=	p_header_val_rec.sold_to_zip                   ;
l_header_val_rec.sold_to_county                :=	p_header_val_rec.sold_to_county                ;
l_header_val_rec.sold_to_province              :=	p_header_val_rec.sold_to_province              ;
l_header_val_rec.sold_to_city                  :=	p_header_val_rec.sold_to_city                  ;
l_header_val_rec.sold_to_contact_last_name     :=	p_header_val_rec.sold_to_contact_last_name     ;
l_header_val_rec.sold_to_contact_first_name    :=	p_header_val_rec.sold_to_contact_first_name    ;
l_header_val_rec.ship_to_address1              :=	p_header_val_rec.ship_to_address1              ;
l_header_val_rec.ship_to_address2              :=	p_header_val_rec.ship_to_address2              ;
l_header_val_rec.ship_to_address3              :=	p_header_val_rec.ship_to_address3              ;
l_header_val_rec.ship_to_address4              :=	p_header_val_rec.ship_to_address4              ;
l_header_val_rec.ship_to_state                 :=	p_header_val_rec.ship_to_state                 ;
l_header_val_rec.ship_to_country               :=	p_header_val_rec.ship_to_country               ;
l_header_val_rec.ship_to_zip                   :=	p_header_val_rec.ship_to_zip                   ;
l_header_val_rec.ship_to_county                :=	p_header_val_rec.ship_to_county                ;
l_header_val_rec.ship_to_province              :=	p_header_val_rec.ship_to_province              ;
l_header_val_rec.ship_to_city                  :=	p_header_val_rec.ship_to_city                  ;
l_header_val_rec.ship_to_contact               :=	p_header_val_rec.ship_to_contact               ;
l_header_val_rec.ship_to_contact_last_name     :=	p_header_val_rec.ship_to_contact_last_name     ;
l_header_val_rec.ship_to_contact_first_name    :=	p_header_val_rec.ship_to_contact_first_name    ;
l_header_val_rec.ship_to_location              :=	p_header_val_rec.ship_to_location              ;
l_header_val_rec.ship_to_org                   :=	p_header_val_rec.ship_to_org                   ;
l_header_val_rec.sold_to_contact               :=	p_header_val_rec.sold_to_contact               ;
l_header_val_rec.sold_to_org                   :=	p_header_val_rec.sold_to_org                   ;
l_header_val_rec.sold_from_org                 :=	p_header_val_rec.sold_from_org                 ;
l_header_val_rec.tax_exempt                    :=	p_header_val_rec.tax_exempt                    ;
l_header_val_rec.tax_exempt_reason             :=	p_header_val_rec.tax_exempt_reason             ;
l_header_val_rec.tax_point                     :=	p_header_val_rec.tax_point                     ;
l_header_val_rec.customer_payment_term         :=	p_header_val_rec.customer_payment_term       ;
l_header_val_rec.freight_carrier               :=	p_header_val_rec.freight_carrier               ;
l_header_val_rec.shipping_method               :=	p_header_val_rec.shipping_method               ;
l_header_val_rec.customer_number               :=	p_header_val_rec.customer_number               ;
l_header_val_rec.ship_to_customer_name         :=	p_header_val_rec.ship_to_customer_name         ;
l_header_val_rec.invoice_to_customer_name      :=	p_header_val_rec.invoice_to_customer_name      ;
l_header_val_rec.ship_to_customer_number       :=	p_header_val_rec.ship_to_customer_number       ;
l_header_val_rec.invoice_to_customer_number    :=	p_header_val_rec.invoice_to_customer_number    ;
l_header_val_rec.deliver_to_customer_number    :=	p_header_val_rec.deliver_to_customer_number    ;
l_header_val_rec.deliver_to_customer_name      :=	p_header_val_rec.deliver_to_customer_name      ;
l_header_val_rec.blanket_agreement_name        :=	p_header_val_rec.blanket_agreement_name            ;
l_header_val_rec.contract_template             :=	p_header_val_rec.contract_template                 ;



        l_header_rec.order_category_code    := p_header_rec.order_category_code;
        l_header_rec.deliver_to_org_id:= p_header_rec.deliver_to_org_id;
        l_header_rec.invoice_to_org_id:= p_header_rec.invoice_to_org_id;
        l_header_rec.ship_to_org_id   := p_header_rec.ship_to_org_id;
        l_header_rec.accounting_rule_id       := p_header_rec.accounting_rule_id;
        l_header_rec.agreement_id     := p_header_rec.agreement_id;
        l_header_rec.price_list_id    := p_header_rec.price_list_id;
        l_header_rec.deliver_to_org_id:= p_header_rec.deliver_to_org_id;
        l_header_rec.invoice_to_org_id:= p_header_rec.invoice_to_org_id;
        l_header_rec.ship_to_org_id   := p_header_rec.ship_to_org_id;
        l_header_rec.salesrep_id      := p_header_rec.salesrep_id;
        l_header_rec.order_type_id   := p_header_rec.order_type_id;
        l_header_rec.invoicing_rule_id:= p_header_rec.invoicing_rule_id;
        l_header_rec.payment_term_id  := p_header_rec.payment_term_id;
        l_header_rec.contract_template_id:= p_header_rec.contract_template_id ;
        l_header_rec.conversion_type_code:= p_header_rec.conversion_type_code ;
        l_header_rec.sold_to_org_id:= p_header_rec.sold_to_org_id  ;
        l_header_rec.ship_from_org_id       := p_header_rec.ship_from_org_id ;
        l_header_rec.shipping_method_code     := p_header_rec.shipping_method_code;
        l_header_rec.freight_terms_code     := p_header_rec.freight_terms_code;

        OE_Header_Util.Get_Ids(p_header_val_rec => l_header_val_rec
                             , p_x_header_rec => l_header_rec);
     --   p_header_rec.order_type_d := l_order_type_id;


        p_header_rec.order_category_code    := l_header_rec.order_category_code;
        p_header_rec.deliver_to_org_id:= l_header_rec.deliver_to_org_id;
        p_header_rec.invoice_to_org_id:= l_header_rec.invoice_to_org_id;
        p_header_rec.ship_to_org_id   := l_header_rec.ship_to_org_id;
        p_header_rec.accounting_rule_id       := l_header_rec.accounting_rule_id;
        p_header_rec.agreement_id     := l_header_rec.agreement_id;
        p_header_rec.price_list_id    := l_header_rec.price_list_id;
        p_header_rec.deliver_to_org_id:= l_header_rec.deliver_to_org_id;
        p_header_rec.invoice_to_org_id:= l_header_rec.invoice_to_org_id;
        p_header_rec.ship_to_org_id   := l_header_rec.ship_to_org_id;
        p_header_rec.salesrep_id      := l_header_rec.salesrep_id;
        p_header_rec.order_type_id   := l_header_rec.order_type_id;
        p_header_rec.invoicing_rule_id:= l_header_rec.invoicing_rule_id;
        p_header_rec.payment_term_id  := l_header_rec.payment_term_id;
        p_header_rec.contract_template_id:= l_header_rec.contract_template_id ;
        p_header_rec.conversion_type_code:= l_header_rec.conversion_type_code ;
        p_header_rec.sold_to_org_id:= l_header_rec.sold_to_org_id  ;
        p_header_rec.ship_from_org_id       := l_header_rec.ship_from_org_id ;
        p_header_rec.shipping_method_code     := l_header_rec.shipping_method_code;
        p_header_rec.freight_terms_code     := l_header_rec.freight_terms_code;

        oe_debug_pub.add(' Price List :'|| p_header_val_rec.price_list);
        oe_debug_pub.add(' Price List Id :'|| p_header_rec.price_list_id);
        oe_debug_pub.add(' Invoice to org id :'|| p_header_rec.invoice_to_org_id );
        oe_debug_pub.add(' Ship to org id :'|| p_header_rec.ship_to_org_id);
        oe_debug_pub.add(' Deliver to Org id :'|| p_header_rec.deliver_to_org_id );

     EXCEPTION


     WHEN OTHERS THEN

       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Header_Id_Conversion'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     END Header_Id_Conversion;



----------------------------------------------------------
     PROCEDURE Line_Id_Conversion
----------------------------------------------------------
    (  p_line_val_rec            IN OUT  NOCOPY  OE_Blanket_PUB.Line_Val_Rec_Type
    ,  p_line_rec        IN OUT  NOCOPY  OE_Blanket_PUB.Line_Rec_Type
    )IS
       l_line_val_rec         OE_Order_PUB.Line_Val_Rec_Type;
       l_line_rec             OE_Order_PUB.Line_Rec_Type;
       l_organization_id      NUMBER := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
     BEGIN
                oe_debug_pub.add('In Line Id Conversion ');


l_line_val_rec.accounting_rule               :=	p_line_val_rec.accounting_rule               ;
l_line_val_rec.agreement                     :=	p_line_val_rec.agreement                     ;
l_line_val_rec.deliver_to_address1           :=	p_line_val_rec.deliver_to_address1           ;
l_line_val_rec.deliver_to_address2           :=	p_line_val_rec.deliver_to_address2           ;
l_line_val_rec.deliver_to_address3           :=	p_line_val_rec.deliver_to_address3           ;
l_line_val_rec.deliver_to_address4           :=	p_line_val_rec.deliver_to_address4           ;
l_line_val_rec.deliver_to_contact            :=	p_line_val_rec.deliver_to_contact            ;
l_line_val_rec.deliver_to_location           :=	p_line_val_rec.deliver_to_location           ;
l_line_val_rec.deliver_to_org                :=	p_line_val_rec.deliver_to_org                ;
l_line_val_rec.deliver_to_state              :=	p_line_val_rec.deliver_to_state              ;
l_line_val_rec.deliver_to_city               :=	p_line_val_rec.deliver_to_city               ;
l_line_val_rec.deliver_to_zip                :=	p_line_val_rec.deliver_to_zip                ;
l_line_val_rec.deliver_to_country            :=	p_line_val_rec.deliver_to_country            ;
l_line_val_rec.deliver_to_county             :=	p_line_val_rec.deliver_to_county             ;
l_line_val_rec.deliver_to_province           :=	p_line_val_rec.deliver_to_province           ;
l_line_val_rec.freight_terms                 :=	p_line_val_rec.freight_terms                 ;
l_line_val_rec.inventory_item                :=	p_line_val_rec.inventory_item                ;
l_line_val_rec.invoice_to_address1           :=	p_line_val_rec.invoice_to_address1           ;
l_line_val_rec.invoice_to_address2           :=	p_line_val_rec.invoice_to_address2           ;
l_line_val_rec.invoice_to_address3           :=	p_line_val_rec.invoice_to_address3           ;
l_line_val_rec.invoice_to_address4           :=	p_line_val_rec.invoice_to_address4           ;
l_line_val_rec.invoice_to_contact            :=	p_line_val_rec.invoice_to_contact            ;
l_line_val_rec.invoice_to_location           :=	p_line_val_rec.invoice_to_location           ;
l_line_val_rec.invoice_to_org                :=	p_line_val_rec.invoice_to_org                ;
l_line_val_rec.invoice_to_state              :=	p_line_val_rec.invoice_to_state              ;
l_line_val_rec.invoice_to_city               :=	p_line_val_rec.invoice_to_city               ;
l_line_val_rec.invoice_to_zip                :=	p_line_val_rec.invoice_to_zip                ;
l_line_val_rec.invoice_to_country            :=	p_line_val_rec.invoice_to_country            ;
l_line_val_rec.invoice_to_county             :=	p_line_val_rec.invoice_to_county             ;
l_line_val_rec.invoice_to_province           :=	p_line_val_rec.invoice_to_province           ;
l_line_val_rec.invoicing_rule                :=	p_line_val_rec.invoicing_rule                ;
l_line_val_rec.line_type                     :=	p_line_val_rec.line_type                     ;
l_line_val_rec.payment_term                  :=	p_line_val_rec.payment_term                  ;
l_line_val_rec.price_list                    :=	p_line_val_rec.price_list                    ;
l_line_val_rec.salesrep                      :=	p_line_val_rec.salesrep               ;
l_line_val_rec.ship_from_address1            :=	p_line_val_rec.ship_from_address1            ;
l_line_val_rec.ship_from_address2            :=	p_line_val_rec.ship_from_address2            ;
l_line_val_rec.ship_from_address3            :=	p_line_val_rec.ship_from_address3            ;
l_line_val_rec.ship_from_address4            :=	p_line_val_rec.ship_from_address4            ;
l_line_val_rec.ship_from_location            :=	p_line_val_rec.ship_from_location            ;
l_line_val_rec.SHIP_FROM_CITY                :=	p_line_val_rec.SHIP_FROM_CITY               ;
l_line_val_rec.SHIP_FROM_POSTAL_CODE         :=	p_line_val_rec.SHIP_FROM_POSTAL_CODE        ;
l_line_val_rec.SHIP_FROM_COUNTRY             :=	p_line_val_rec.SHIP_FROM_COUNTRY            ;
l_line_val_rec.SHIP_FROM_REGION1             :=	p_line_val_rec.SHIP_FROM_REGION1            ;
l_line_val_rec.SHIP_FROM_REGION2             :=	p_line_val_rec.SHIP_FROM_REGION2            ;
l_line_val_rec.SHIP_FROM_REGION3             :=	p_line_val_rec.SHIP_FROM_REGION3            ;
l_line_val_rec.ship_from_org                 :=	p_line_val_rec.ship_from_org                 ;
l_line_val_rec.ship_to_address1              :=	p_line_val_rec.ship_to_address1              ;
l_line_val_rec.ship_to_address2              :=	p_line_val_rec.ship_to_address2              ;
l_line_val_rec.ship_to_address3              :=	p_line_val_rec.ship_to_address3              ;
l_line_val_rec.ship_to_address4              :=	p_line_val_rec.ship_to_address4              ;
l_line_val_rec.ship_to_state                 :=	p_line_val_rec.ship_to_state                 ;
l_line_val_rec.ship_to_country               :=	p_line_val_rec.ship_to_country               ;
l_line_val_rec.ship_to_zip                   :=	p_line_val_rec.ship_to_zip                   ;
l_line_val_rec.ship_to_county                :=	p_line_val_rec.ship_to_county                ;
l_line_val_rec.ship_to_province              :=	p_line_val_rec.ship_to_province              ;
l_line_val_rec.ship_to_city                  :=	p_line_val_rec.ship_to_city                  ;
l_line_val_rec.ship_to_contact               :=	p_line_val_rec.ship_to_contact               ;
l_line_val_rec.ship_to_contact_last_name     :=	p_line_val_rec.ship_to_contact_last_name     ;
l_line_val_rec.ship_to_contact_first_name    :=	p_line_val_rec.ship_to_contact_first_name    ;
l_line_val_rec.ship_to_location              :=	p_line_val_rec.ship_to_location              ;
l_line_val_rec.ship_to_org                   :=	p_line_val_rec.ship_to_org                   ;
l_line_val_rec.source_type                   :=	p_line_val_rec.source_type                   ;
l_line_val_rec.sold_to_org                   :=	p_line_val_rec.sold_to_org                   ;
l_line_val_rec.sold_from_org                 :=	p_line_val_rec.sold_from_org                 ;
l_line_val_rec.ship_to_customer_name         :=	p_line_val_rec.ship_to_customer_name         ;
l_line_val_rec.invoice_to_customer_name      :=	p_line_val_rec.invoice_to_customer_name      ;
l_line_val_rec.ship_to_customer_number       :=	p_line_val_rec.ship_to_customer_number       ;
l_line_val_rec.invoice_to_customer_number    :=	p_line_val_rec.invoice_to_customer_number    ;
l_line_val_rec.deliver_to_customer_number    :=	p_line_val_rec.deliver_to_customer_number    ;
l_line_val_rec.deliver_to_customer_name      :=	p_line_val_rec.deliver_to_customer_name      ;
l_line_val_rec.blanket_agreement_name        :=	p_line_val_rec.blanket_agreement_name        ;


        l_line_rec.accounting_rule_id       := p_line_rec.accounting_rule_id;
        l_line_rec.agreement_id     := p_line_rec.agreement_id;
        l_line_rec.price_list_id    := p_line_rec.price_list_id;
        l_line_rec.deliver_to_org_id:= p_line_rec.deliver_to_org_id;
        l_line_rec.invoice_to_org_id:= p_line_rec.invoice_to_org_id;
        l_line_rec.ship_to_org_id   := p_line_rec.ship_to_org_id;
        l_line_rec.salesrep_id      := p_line_rec.salesrep_id;
        l_line_rec.invoicing_rule_id:= p_line_rec.invoicing_rule_id;
        l_line_rec.payment_term_id  := p_line_rec.payment_term_id;
        l_line_rec.sold_to_org_id   := p_line_rec.sold_to_org_id  ;
        l_line_rec.ship_from_org_id := p_line_rec.ship_from_org_id ;
        l_line_rec.shipping_method_code     := p_line_rec.shipping_method_code;
        l_line_rec.freight_terms_code     := p_line_rec.freight_terms_code;
        l_line_rec.deliver_to_org_id:= p_line_rec.deliver_to_org_id;
        l_line_rec.invoice_to_org_id:= p_line_rec.invoice_to_org_id;
        l_line_rec.ship_to_org_id   := p_line_rec.ship_to_org_id;
        l_line_rec.inventory_item_id := p_line_rec.inventory_item_id;

         oe_debug_pub.add(' inventory_item_id :'|| p_line_rec.inventory_item_id, 1);
        oe_debug_pub.add('  ordered_item_id :'|| p_line_rec.ordered_item_id, 1);
 -- 7695556

      IF p_line_rec.inventory_item_id IS NOT NULL
      OR p_line_rec.ordered_item_id   IS NOT NULL THEN
      OE_ID_TO_VALUE.Ordered_Item
      (p_Item_Identifier_type    => p_line_rec.item_identifier_type
      ,p_inventory_item_id       => p_line_rec.inventory_item_id
      ,p_organization_id         => l_organization_id
      ,p_ordered_item_id         => p_line_rec.ordered_item_id
      ,p_sold_to_org_id          => p_line_rec.sold_to_org_id
      ,p_ordered_item            => p_line_rec.ordered_item
      ,x_ordered_item            => l_line_rec.ordered_item
      ,x_inventory_item          => l_line_val_rec.inventory_item);

      END IF;
         oe_debug_pub.add('  ordered_item :'|| l_line_rec.ordered_item, 1);
         oe_debug_pub.add('  inventory_item :'|| l_line_val_rec.inventory_item, 1);

         OE_Line_Util.Get_Ids(p_line_val_rec => l_line_val_rec
                           , p_x_line_rec => l_line_rec);

        p_line_rec.ordered_item    := l_line_rec.ordered_item;

        oe_debug_pub.add('  ordered_item :'|| p_line_rec.ordered_item, 1);

        p_line_rec.accounting_rule_id       := l_line_rec.accounting_rule_id;
        p_line_rec.agreement_id     := l_line_rec.agreement_id;
        p_line_rec.price_list_id    := l_line_rec.price_list_id;
        p_line_rec.deliver_to_org_id:= l_line_rec.deliver_to_org_id;
        p_line_rec.invoice_to_org_id:= l_line_rec.invoice_to_org_id;
        p_line_rec.ship_to_org_id   := l_line_rec.ship_to_org_id;
        p_line_rec.salesrep_id      := l_line_rec.salesrep_id;
        p_line_rec.invoicing_rule_id:= l_line_rec.invoicing_rule_id;
        p_line_rec.payment_term_id  := l_line_rec.payment_term_id;
        p_line_rec.sold_to_org_id:= l_line_rec.sold_to_org_id  ;
        p_line_rec.ship_from_org_id       := l_line_rec.ship_from_org_id ;
        p_line_rec.shipping_method_code     := l_line_rec.shipping_method_code;
        p_line_rec.freight_terms_code     := l_line_rec.freight_terms_code;
        p_line_rec.deliver_to_org_id:= l_line_rec.deliver_to_org_id;
        p_line_rec.invoice_to_org_id:= l_line_rec.invoice_to_org_id;
        p_line_rec.ship_to_org_id   := l_line_rec.ship_to_org_id;


         oe_debug_pub.add(' Price List :'|| p_line_val_rec.price_list);
        oe_debug_pub.add(' Price List Id :'|| p_line_rec.price_list_id);
        oe_debug_pub.add(' Invoice to org id :'|| p_line_rec.invoice_to_org_id);
        oe_debug_pub.add(' Ship to org id :'|| p_line_rec.ship_to_org_id);
        oe_debug_pub.add(' Deliver to Org id :'|| p_line_rec.deliver_to_org_id);
        oe_debug_pub.add('  ordered_item :'|| p_line_rec.ordered_item, 1);
EXCEPTION



     WHEN OTHERS THEN
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_Id_Conversion'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        null;
     END Line_Id_Conversion;

-- Public Blanket order API
/*#
* Use this procedure to create Blanket Agreement in the Order Management system.
*       @param          p_org_id   Input OU Organization Id
*       @param          p_operating_unit   Input Operating Unit Name
*       @param          p_api_version_number    API version used to check call compatibility
*       @param          x_return_status Return status of API call
*       @param          x_msg_count    Number of stored processing messages
*       @param          x_msg_data      Processing message data
*       @param          p_header_rec    Input record structure containing current header-level information for an Agreement
*       @param          p_line_tbl          Input table containing current line-level information for an Agreement
*       @param          p_control_rec    Input record structure containing current control information for the API call
*       @param          x_header_rec    Output record structure containing current header-level information for an Agreement
*       @param          x_line_tbl      Output table containing current line-level information for an Agreement
*       @rep:scope      public
*       @rep:lifecycle  active
*       @rep:category   BUSINESS_ENTITY  ONT_SALES_AGREEMENT
*       @rep:displayname                 Sales Agreement API
*/

PROCEDURE Process_Blanket
(   p_org_id                        IN  NUMBER := NULL  --MOAC
,   p_operating_unit                IN  VARCHAR2 := NULL -- MOAC
,   p_api_version_number            IN  NUMBER := 1.0
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_header_rec            IN  header_Rec_type :=
                                        G_MISS_header_rec
,   p_header_val_rec        IN  Header_Val_Rec_Type :=
                                        G_MISS_header_Val_rec
,   p_line_tbl              IN  line_tbl_Type :=
                                        G_MISS_line_tbl
,   p_line_val_tbl          IN  line_Val_tbl_Type :=
                                         G_MISS_line_Val_tbl
,   p_control_rec                   IN  Control_rec_type :=
                                G_MISS_CONTROL_REC
,   x_header_rec           OUT NOCOPY header_Rec_type
,   x_line_tbl             OUT NOCOPY line_tbl_Type
) IS

l_control_rec OE_Blanket_Pub.control_rec_type;
l_header_rec  OE_Blanket_Pub.header_Rec_type;
l_header_val_rec  OE_Blanket_Pub.Header_Val_Rec_Type := OE_Blanket_Pub.G_MISS_HEADER_VAL_REC;
l_line_rec    OE_Blanket_Pub.Line_Rec_Type := OE_Blanket_Pub.G_MISS_BLANKET_LINE_REC;
l_line_val_rec    OE_Blanket_Pub.Line_Val_Rec_Type := OE_Blanket_Pub.G_MISS_BLANKET_LINE_VAL_REC;
l_org_id          NUMBER;
l_line_tbl        line_tbl_Type :=  p_line_tbl;
l_line_val_tbl    line_val_tbl_Type :=  p_line_val_tbl;
l_count           INTEGER;
BEGIN
 l_header_rec := p_header_rec ;
 l_header_val_rec :=  p_header_val_rec;
-- Logic added for MOAC

IF (p_org_id IS NOT NULL AND p_org_id <> FND_API.G_MISS_NUM) THEN
        l_org_id :=  p_org_id;
     IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR)
         THEN
          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
             THEN
                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','operating_unit');
                OE_MSG_PUB.Add;
          END IF;
       END IF;

    ELSE
       IF (p_operating_unit IS NOT NULL AND p_operating_unit <> FND_API.G_MISS_CHAR)
           THEN
           -- call value_to_id to get org_id
           l_org_id := OE_Value_To_Id.OPERATING_UNIT(p_operating_unit);

       END IF;
   END IF;

     IF l_header_rec.operation NOT IN ( 'INSERT','CREATE') THEN
        FND_MESSAGE.SET_NAME('ONT','ONT_BSA_BATCH');
        OE_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;
     END IF;


   set_context(p_org_id =>l_org_id);

    oe_debug_pub.add('After Set Context');


  IF    l_header_rec.operation = OE_Globals.G_OPR_CREATE THEN
 -- Pre-default header_id for proper message display
    SELECT OE_ORDER_HEADERS_S.NEXTVAL
    INTO l_header_rec.header_id
    FROM DUAL;
    oe_debug_pub.add('Set Message Context');

OE_MSG_PUB.set_msg_context(
         p_entity_code                  => 'BLANKET_HEADER'
        ,p_entity_id                    => l_header_rec.header_id
        ,p_header_id                    => l_header_rec.header_id
        ,p_line_id                      => null
        ,p_orig_sys_document_ref        => null
        ,p_orig_sys_document_line_ref   => null
        ,p_change_sequence              => null
        ,p_source_document_id           => null
        ,p_source_document_line_id      => null
        ,p_order_source_id              => l_header_rec.source_document_id
        ,p_source_document_type_id      => null);

    x_return_status := FND_API.G_RET_STS_SUCCESS;


    oe_debug_pub.add('3');
    oe_debug_pub.add (' Price List :'|| l_header_val_rec.price_list );
    oe_debug_pub.add (' Price List id :'|| l_header_rec.price_list_id );

   Header_Id_Conversion ( p_header_val_rec =>  l_header_val_rec
                       , p_header_rec => l_header_rec) ;

END IF;

OE_MSG_PUB.set_msg_context(
         p_entity_code                  => 'BLANKET_HEADER'
        ,p_entity_id                    => l_header_rec.header_id
        ,p_header_id                    => l_header_rec.header_id
        ,p_line_id                      => null
        ,p_orig_sys_document_ref        => null
        ,p_orig_sys_document_line_ref   => null
        ,p_change_sequence              => null
        ,p_source_document_id           => null
        ,p_source_document_line_id      => null
        ,p_order_source_id              => l_header_rec.source_document_id
        ,p_source_document_type_id      => null);

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR l_count in 1..l_line_tbl.COUNT LOOP

   oe_debug_pub.add('In Lines Loop', 1);
   oe_debug_pub.add(' Operation :'||  l_line_rec.operation,1);

 IF l_line_tbl(l_count).operation = OE_Globals.G_OPR_CREATE  THEN
    oe_debug_pub.add(' Operation :'||  l_line_tbl(l_count).operation,1);
    l_line_tbl(l_count).header_id := l_header_rec.header_id;

    l_line_rec := l_line_tbl(l_count);
    l_line_val_rec := l_line_val_tbl(l_count);

    oe_debug_pub.add(' Call Line_Id_Conversion' ,1);

     Line_Id_Conversion ( p_line_val_rec =>  l_line_val_rec
                        , p_line_rec => l_line_rec );

    l_line_tbl(l_count) := l_line_rec;

  -- Pre-default header_id for proper message display
    SELECT OE_ORDER_LINES_S.NEXTVAL
    INTO l_line_tbl(l_count).line_id
    FROM DUAL;

 END IF;

  oe_debug_pub.add('In Lines Loop');
 oe_debug_pub.add(' ordered item :'|| l_line_tbl(l_count).ordered_item, 1);

OE_MSG_PUB.set_msg_context(
         p_entity_code                  => 'BLANKET_LINE'
        ,p_entity_id                    => l_line_tbl(l_count).line_id
        ,p_header_id                    => l_line_tbl(l_count).header_id
        ,p_line_id                      => l_line_tbl(l_count).line_id
        ,p_orig_sys_document_ref        => null
        ,p_orig_sys_document_line_ref   => null
        ,p_change_sequence              => null
        ,p_source_document_id           => l_line_tbl(l_count).source_document_id
        ,p_source_document_line_id      => l_line_tbl(l_count).source_document_line_id
        ,p_order_source_id              => null
        ,p_source_document_type_id      => null);

  IF l_line_tbl(l_count).operation NOT IN ( 'INSERT','CREATE') THEN
   FND_MESSAGE.SET_NAME('ONT','ONT_BSA_BATCH');
   OE_MSG_PUB.Add;
   x_return_status := FND_API.G_RET_STS_ERROR;
   RAISE FND_API.G_EXC_ERROR;
  END IF;

END LOOP;
 -- Prepare control record
  l_control_rec.UI_CALL := FALSE;
  l_control_rec.validate_attributes := TRUE;
  l_control_rec.validate_entity := TRUE;
  l_control_rec.check_security := TRUE;
  l_control_rec.default_from_header := TRUE;

  oe_debug_pub.add('Call OE_BLANKET_PVT.Process_Blanket');
 --  E_GLOBALS.g_validate_desc_flex := p_validate_desc_flex ;


OE_BLANKET_PVT.Process_Blanket
(   p_org_id                        => p_org_id  --MOAC
,   p_operating_unit                => p_operating_unit -- MOAC
,   p_api_version_number            => p_api_version_number
,   x_return_status                 => x_return_status
,   x_msg_count                     => x_msg_count
,   x_msg_data                      => x_msg_data
,   p_header_rec            => l_header_rec
,   p_line_tbl              => l_line_tbl
,   p_control_rec        =>  l_control_rec
,   x_header_rec           => x_header_rec
,   x_line_tbl             => x_line_tbl
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
            ,   'Process_Blanket'
            );
        END IF;

      OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


END Process_Blanket;

End OE_BLANKET_PUB;


/
