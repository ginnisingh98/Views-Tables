--------------------------------------------------------
--  DDL for Package Body OE_BLANKET_FORM_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BLANKET_FORM_CONTROL" AS
/* $Header: OEXFBSOB.pls 120.5 2006/02/16 16:36:50 spagadal noship $ */

-----------------------------------------------------------
  -- Package Globals
-----------------------------------------------------------

     TYPE HEADER_CACHE IS TABLE OF oe_blanket_pub.header_rec_type INDEX BY BINARY_INTEGER;
     TYPE LINE_CACHE   IS TABLE OF oe_blanket_pub.line_rec_type   INDEX BY BINARY_INTEGER;

     G_Header_Cache_Rec         Header_Cache;
     G_Line_Cache_Rec           Line_Cache;
     G_Blanket_Line_Number      Number;

     G_Header_Security_Cache  oe_blanket_pub.header_rec_type;
     G_Line_Security_Cache    oe_blanket_pub.line_rec_type;



----------------------------------------------------------
     PROCEDURE Header_Value_Conversion
----------------------------------------------------------
    (   p_header_rec         IN  OUT NOCOPY OE_Blanket_PUB.Header_Rec_type
    ,   p_header_val_rec     IN  OUT NOCOPY OE_Order_PUB.Header_Val_Rec_Type
    )IS
       l_header_rec                            OE_Order_PUB.Header_Rec_Type;
       l_order_type          varchar2(240);
       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
     BEGIN
		OE_MSG_PUB.initialize;
        l_header_rec.accounting_rule_id               := p_header_rec.accounting_rule_id;
        l_header_rec.agreement_id                     := p_header_rec.agreement_id;
        l_header_rec.price_list_id                    := p_header_rec.price_list_id;
        l_header_rec.deliver_to_org_id                := p_header_rec.deliver_to_org_id;
        l_header_rec.invoice_to_org_id                := p_header_rec.invoice_to_org_id;
        l_header_rec.ship_to_org_id                   := p_header_rec.ship_to_org_id;
        l_header_rec.salesrep_id                      := p_header_rec.salesrep_id;
        l_header_rec.shipping_method_code             := p_header_rec.shipping_method_code;
        l_header_rec.conversion_type_code             := p_header_rec.conversion_type_code;
        l_header_rec.order_type_id                    := p_header_rec.order_type_id;
        l_header_rec.invoicing_rule_id                := p_header_rec.invoicing_rule_id;
        l_header_rec.freight_terms_code               := p_header_rec.freight_terms_code;
        l_header_rec.payment_term_id                  := p_header_rec.payment_term_id;
-- hashraf pack J
        l_header_rec.sold_to_site_use_id                   := p_header_rec.sold_to_site_use_id;
        l_order_type :=  OE_Blanket_Form_Control.sales_order_type(p_header_rec.order_type_id);
        p_header_val_rec := OE_Header_Util.Get_Values(p_header_rec => l_header_rec);
        p_header_val_rec.order_type := l_order_type;
     EXCEPTION

     WHEN NO_DATA_FOUND THEN

       /* IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Header_Value_Conversion');
            OE_MSG_PUB.Add;

        END IF; */
        null;


     WHEN OTHERS THEN

       /* IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Header_Value_Conversion'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR; */
        null;

     END Header_Value_Conversion;



----------------------------------------------------------
     PROCEDURE Line_Value_Conversion
----------------------------------------------------------
    (  p_line_rec            IN OUT  NOCOPY  OE_Blanket_PUB.Line_Rec_Type
    ,  p_line_val_rec        IN OUT  NOCOPY  OE_Order_PUB.Line_Val_Rec_Type
    )IS
       l_line_rec                            OE_Order_PUB.Line_Rec_Type;
       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
     BEGIN

		OE_MSG_PUB.initialize;
        l_line_rec.invoice_to_org_id                := p_line_rec.invoice_to_org_id;
        l_line_rec.ship_to_org_id                   := p_line_rec.ship_to_org_id;
        l_line_rec.deliver_to_org_id                := p_line_rec.deliver_to_org_id;
        l_line_rec.accounting_rule_id               := p_line_rec.accounting_rule_id;
        l_line_rec.invoicing_rule_id                := p_line_rec.invoicing_rule_id;
        l_line_rec.agreement_id                     := p_line_rec.agreement_id;
        l_line_rec.price_list_id                    := p_line_rec.price_list_id;
        l_line_rec.shipping_method_code             := p_line_rec.shipping_method_code;
        l_line_rec.freight_terms_code               := p_line_rec.freight_terms_code;
        l_line_rec.ordered_item_id                  := p_line_rec.ordered_item_id;
        l_line_rec.ship_from_org_id                 := p_line_rec.ship_from_org_id;

        p_line_val_rec := OE_Line_Util.Get_Values(p_line_rec => l_line_rec);

        OE_ID_TO_VALUE.Ship_From_Org(
                    p_ship_from_org_id   => l_line_rec.ship_from_org_id
                   ,x_ship_from_address1 => p_line_val_rec.ship_from_address1
                   ,x_ship_from_address2 => p_line_val_rec.ship_from_address2
                   ,x_ship_from_address3 => p_line_val_rec.ship_from_address3
                   ,x_ship_from_address4 => p_line_val_rec.ship_from_address4
                   ,x_ship_from_location => p_line_val_rec.ship_from_location
                   ,x_ship_from_org      => p_line_val_rec.ship_from_org
                   );
     EXCEPTION

     WHEN NO_DATA_FOUND THEN

        /* IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Line_Value_Conversion');
            OE_MSG_PUB.Add;

        END IF; */
        null;


     WHEN OTHERS THEN

        /* IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Line_Value_Conversion'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR; */
        null;
     END Line_Value_Conversion;

----------------------------------------------------------
     PROCEDURE Populate_Header_Values_ID
----------------------------------------------------------
    (  p_Header_rec            IN OUT  NOCOPY  OE_Blanket_PUB.Header_Rec_Type
    ,  p_Header_val_rec        IN OUT  NOCOPY  OE_Order_PUB.Header_Val_Rec_Type
    )IS
     l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

     BEGIN

        OE_MSG_PUB.initialize;

        OE_ID_TO_VALUE.Ship_From_Org(
                    p_ship_from_org_id   => p_header_rec.ship_from_org_id
                   ,x_ship_from_address1 => p_header_val_rec.ship_from_address1
                   ,x_ship_from_address2 => p_header_val_rec.ship_from_address2
                   ,x_ship_from_address3 => p_header_val_rec.ship_from_address3
                   ,x_ship_from_address4 => p_header_val_rec.ship_from_address4
                   ,x_ship_from_location => p_header_val_rec.ship_from_location
                   ,x_ship_from_org      => p_header_val_rec.ship_from_org
                   );



       if p_header_rec.ship_to_org_id is not null then
                     OE_ID_TO_VALUE.Ship_To_Org
                            (   p_ship_to_org_id        => p_header_rec.ship_To_org_id
                                , x_ship_to_address1    => p_header_val_rec.ship_to_address1
                                , x_ship_to_address2    => p_header_val_rec.ship_to_address2
                                , x_ship_to_address3    => p_header_val_rec.ship_to_address3
                                , x_ship_to_address4    => p_header_val_rec.ship_to_address4
                                , x_ship_to_location    => p_header_val_rec.ship_to_location
                                , x_ship_to_org         => p_header_val_rec.ship_to_org
                                , x_ship_to_city        => p_header_val_rec.ship_to_city
                                , x_ship_to_state       => p_header_val_rec.ship_to_state
                                , x_ship_to_postal_code => p_header_val_rec.ship_to_zip
                                , x_ship_to_country     => p_header_val_rec.ship_to_country
                                );
       end if;

       if p_header_rec.deliver_to_org_id is not null then
                     OE_ID_TO_VALUE.deliver_To_Org
                            (   p_deliver_to_org_id        => p_header_rec.deliver_To_org_id
                                , x_deliver_to_address1    => p_header_val_rec.deliver_to_address1
                                , x_deliver_to_address2    => p_header_val_rec.deliver_to_address2
                                , x_deliver_to_address3    => p_header_val_rec.deliver_to_address3
                                , x_deliver_to_address4    => p_header_val_rec.deliver_to_address4
                                , x_deliver_to_location    => p_header_val_rec.deliver_to_location
                                , x_deliver_to_org         => p_header_val_rec.deliver_to_org
                                , x_deliver_to_city        => p_header_val_rec.deliver_to_city
                                , x_deliver_to_state       => p_header_val_rec.deliver_to_state
                                , x_deliver_to_postal_code => p_header_val_rec.deliver_to_zip
                                , x_deliver_to_country     => p_header_val_rec.deliver_to_country
                                );
       end if;


       if p_header_rec.invoice_to_org_id is not null then
                     OE_ID_TO_VALUE.invoice_To_Org
                            (   p_invoice_to_org_id        => p_header_rec.invoice_To_org_id
                                , x_invoice_to_address1    => p_header_val_rec.invoice_to_address1
                                , x_invoice_to_address2    => p_header_val_rec.invoice_to_address2
                                , x_invoice_to_address3    => p_header_val_rec.invoice_to_address3
                                , x_invoice_to_address4    => p_header_val_rec.invoice_to_address4
                                , x_invoice_to_location    => p_header_val_rec.invoice_to_location
                                , x_invoice_to_org         => p_header_val_rec.invoice_to_org
                                , x_invoice_to_city        => p_header_val_rec.invoice_to_city
                                , x_invoice_to_state       => p_header_val_rec.invoice_to_state
                                , x_invoice_to_postal_code => p_header_val_rec.invoice_to_zip
                                , x_invoice_to_country     => p_header_val_rec.invoice_to_country
                                );
       end if;

-- hashraf ... start of pack J
       if p_header_rec.sold_to_site_use_id is not null then
	   OE_ID_TO_VALUE.CUSTOMER_LOCATION
           (  p_sold_to_site_use_id       => p_header_rec.sold_to_site_use_id,
 	      x_sold_to_location_address1 => p_header_val_rec.SOLD_TO_LOCATION_ADDRESS1,
 	      x_sold_to_location_address2 => p_header_val_rec.SOLD_TO_LOCATION_ADDRESS2,
	      x_sold_to_location_address3 => p_header_val_rec.SOLD_TO_LOCATION_ADDRESS3,
	      x_sold_to_location_address4 => p_header_val_rec.SOLD_TO_LOCATION_ADDRESS4,
	      x_sold_to_location     => p_header_val_rec.SOLD_TO_LOCATION,

	      x_sold_to_location_city => p_header_val_rec.SOLD_TO_LOCATION_CITY,
	      x_sold_to_location_state => p_header_val_rec.SOLD_TO_LOCATION_STATE,
	      x_sold_to_location_postal => p_header_val_rec.SOLD_TO_LOCATION_POSTAL,
 	      x_sold_to_location_country => p_header_val_rec.SOLD_TO_LOCATION_COUNTRY
);
       end if;
       if p_header_rec.transaction_phase_code is not null then
          p_header_val_rec.Transaction_Phase  := OE_ID_TO_VALUE.Transaction_Phase(p_header_rec.Transaction_Phase_Code);
       end if;
       if p_header_rec.flow_status_code is not null then
          p_header_val_rec.Status  := OE_ID_TO_VALUE.Flow_Status(p_header_rec.Flow_Status_Code);
       end if;
       if p_header_rec.user_status_code is not null then
          p_header_val_rec.User_Status  := OE_ID_TO_VALUE.User_Status(p_header_rec.User_Status_Code);
       end if;

-- hashraf ... end of pack J

       if p_header_rec.freight_terms_code is not null then
          p_header_val_rec.Freight_Terms   := OE_ID_TO_VALUE.Freight_Terms(p_header_rec.freight_terms_code);
       end if;
       if p_header_rec.price_list_id is not null then
          p_header_val_rec.Price_List      := OE_ID_TO_VALUE.Price_List(p_header_rec.price_list_id);
       end if;
       if p_header_rec.conversion_type_code is not null then
          p_header_val_rec.Conversion_Type := OE_ID_TO_VALUE.Conversion_Type(p_header_rec.conversion_type_code);
       end if;
       if p_header_rec.payment_term_id is not null then
          p_header_val_rec.Payment_Term    := OE_ID_TO_VALUE.Payment_Term(p_header_rec.payment_term_id);
       end if;
       if p_header_rec.accounting_rule_id is not null then
          p_header_val_rec.Accounting_Rule := OE_ID_TO_VALUE.Accounting_Rule(p_header_rec.accounting_rule_id);
       end if;
       if p_header_rec.invoicing_rule_id is not null then
          p_header_val_rec.Invoicing_Rule  := OE_ID_TO_VALUE.Invoicing_Rule(p_header_rec.invoicing_rule_id);
       end if;
       if p_header_rec.Salesrep_id is not null then
          p_header_val_rec.salesrep        := OE_ID_TO_VALUE.Salesrep(p_header_rec.Salesrep_id);
       end if;

       BEGIN
           Select meaning
                  INTO p_header_val_rec.shipping_method
           FROM   oe_ship_methods_v
           WHERE  lookup_code=p_header_rec.shipping_method_code;
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
             Null;
           When too_many_rows then
             Null;
           When others then
             Null;
       END;


     Exception
        when others then
          null;
     END;

----------------------------------------------------------
     PROCEDURE Populate_Line_Values_ID
----------------------------------------------------------
    (  p_Line_rec            IN OUT  NOCOPY  OE_Blanket_PUB.Line_Rec_Type
    ,  p_line_val_rec        IN OUT  NOCOPY  OE_Order_PUB.Line_Val_Rec_Type
    )IS
     BEGIN
          oe_debug_pub.add('enter Populate_Line_Values_ID');

		OE_MSG_PUB.initialize;
        OE_ID_TO_VALUE.Ship_From_Org(
                    p_ship_from_org_id   => p_line_rec.ship_from_org_id
                   ,x_ship_from_address1 => p_line_val_rec.ship_from_address1
                   ,x_ship_from_address2 => p_line_val_rec.ship_from_address2
                   ,x_ship_from_address3 => p_line_val_rec.ship_from_address3
                   ,x_ship_from_address4 => p_line_val_rec.ship_from_address4
                   ,x_ship_from_location => p_line_val_rec.ship_from_location
                   ,x_ship_from_org      => p_line_val_rec.ship_from_org
                   );
       oe_debug_pub.add('before Populate_Line_Values_ID ship_to_org_id '||p_line_rec.ship_to_org_id);
       if p_line_rec.ship_to_org_id is not null then
          oe_debug_pub.add('ship to : '||p_line_rec.ship_To_org_id);
                     OE_ID_TO_VALUE.Ship_To_Org
                            (   p_ship_to_org_id        => p_line_rec.ship_To_org_id
                                , x_ship_to_address1    => p_line_val_rec.ship_to_address1
                                , x_ship_to_address2    => p_line_val_rec.ship_to_address2
                                , x_ship_to_address3    => p_line_val_rec.ship_to_address3
                                , x_ship_to_address4    => p_line_val_rec.ship_to_address4
                                , x_ship_to_location    => p_line_val_rec.ship_to_location
                                , x_ship_to_org         => p_line_val_rec.ship_to_org
                                , x_ship_to_city        => p_line_val_rec.ship_to_city
                                , x_ship_to_state       => p_line_val_rec.ship_to_state
                                , x_ship_to_postal_code => p_line_val_rec.ship_to_zip
                                , x_ship_to_country     => p_line_val_rec.ship_to_country
                                );
       end if;
       oe_debug_pub.add('After Populate_Line_Values_ID ship_to_org_id '||p_line_rec.ship_to_org_id);

       if p_line_rec.deliver_to_org_id is not null then
                     OE_ID_TO_VALUE.deliver_To_Org
                            (   p_deliver_to_org_id        => p_line_rec.deliver_To_org_id
                                , x_deliver_to_address1    => p_line_val_rec.deliver_to_address1
                                , x_deliver_to_address2    => p_line_val_rec.deliver_to_address2
                                , x_deliver_to_address3    => p_line_val_rec.deliver_to_address3
                                , x_deliver_to_address4    => p_line_val_rec.deliver_to_address4
                                , x_deliver_to_location    => p_line_val_rec.deliver_to_location
                                , x_deliver_to_org         => p_line_val_rec.deliver_to_org
                                , x_deliver_to_city        => p_line_val_rec.deliver_to_city
                                , x_deliver_to_state       => p_line_val_rec.deliver_to_state
                                , x_deliver_to_postal_code => p_line_val_rec.deliver_to_zip
                                , x_deliver_to_country     => p_line_val_rec.deliver_to_country
                                );
       end if;

       if p_line_rec.invoice_to_org_id is not null then
                     OE_ID_TO_VALUE.invoice_To_Org
                            (   p_invoice_to_org_id        => p_line_rec.invoice_To_org_id
                                , x_invoice_to_address1    => p_line_val_rec.invoice_to_address1
                                , x_invoice_to_address2    => p_line_val_rec.invoice_to_address2
                                , x_invoice_to_address3    => p_line_val_rec.invoice_to_address3
                                , x_invoice_to_address4    => p_line_val_rec.invoice_to_address4
                                , x_invoice_to_location    => p_line_val_rec.invoice_to_location
                                , x_invoice_to_org         => p_line_val_rec.invoice_to_org
                                , x_invoice_to_city        => p_line_val_rec.invoice_to_city
                                , x_invoice_to_state       => p_line_val_rec.invoice_to_state
                                , x_invoice_to_postal_code => p_line_val_rec.invoice_to_zip
                                , x_invoice_to_country     => p_line_val_rec.invoice_to_country
                                );
       end if;


       if p_line_rec.freight_terms_code is not null then
          p_line_val_rec.Freight_Terms   := OE_ID_TO_VALUE.Freight_Terms(p_line_rec.freight_terms_code);
       end if;
       if p_line_rec.agreement_id is not null then
          p_line_val_rec.Agreement       := OE_ID_TO_VALUE.Agreement(p_line_rec.agreement_id);
       end if;
       if p_line_rec.price_list_id is not null then
          p_line_val_rec.Price_List      := OE_ID_TO_VALUE.Price_List(p_line_rec.price_list_id);
       end if;
       if p_line_rec.payment_term_id is not null then
          p_line_val_rec.Payment_Term    := OE_ID_TO_VALUE.Payment_Term(p_line_rec.payment_term_id);
       end if;
       if p_line_rec.accounting_rule_id is not null then
          p_line_val_rec.Accounting_Rule := OE_ID_TO_VALUE.Accounting_Rule(p_line_rec.accounting_rule_id);
       end if;
       if p_line_rec.invoicing_rule_id is not null then
          p_line_val_rec.Invoicing_Rule  := OE_ID_TO_VALUE.Invoicing_Rule(p_line_rec.invoicing_rule_id);
       end if;

-- hashraf ... start of pack J
       if p_line_rec.transaction_phase_code is not null then
          p_line_val_rec.transaction_phase  := OE_ID_TO_VALUE.Transaction_Phase(p_line_rec.transaction_phase_code);
       end if;
-- hashraf ... end of pack J

       if p_line_rec.Salesrep_id is not null then
          p_line_val_rec.salesrep        := OE_ID_TO_VALUE.Salesrep(p_line_rec.Salesrep_id);
       end if;

       BEGIN

           Select meaning
                  INTO p_Line_val_rec.shipping_method
           FROM   oe_ship_methods_v
           WHERE  lookup_code=p_line_rec.shipping_method_code;

       EXCEPTION
           WHEN NO_DATA_FOUND THEN
             Null;
           When too_many_rows then
             Null;
           When others then
             Null;
       END;

     Exception
        when others then
          null;
     END;

----------------------------------------------------------
     PROCEDURE Validate_Entity
----------------------------------------------------------
     (p_header_rec         IN OUT NOCOPY       OE_Blanket_PUB.Header_rec_type,
      x_return_status      OUT    NOCOPY       VARCHAR2,
      x_msg_count          OUT    NOCOPY       NUMBER,
      x_msg_data           OUT    NOCOPY       VARCHAR2
     )IS
          l_old_header_rec      oe_blanket_pub.header_rec_type;
          l_old_blanket_number  number;
          l_api_name            CONSTANT VARCHAR2(30)  := 'Validate_Entity';
          l_debug_level         CONSTANT NUMBER        := oe_debug_pub.g_debug_level;
     BEGIN
		OE_MSG_PUB.initialize;


         l_old_blanket_number := p_header_rec.order_number;

         IF p_header_rec.header_id is null THEN

              l_old_header_rec := NULL;

         ELSE

              Load_Blanket_Header_Rec (p_header_rec,l_old_header_rec);

         END IF;

         oe_debug_pub.add('Before sending to the API New Blanket MAX number FROM the API '
                        ||p_header_rec.blanket_max_amount);
         oe_debug_pub.add('Before sending to the API OLd Blanket MAX number FROM the API '
                        ||l_old_header_rec.blanket_max_amount);
         oe_debug_pub.add('Before sending to the API New Blanket MIN number FROM the API '
                        ||p_header_rec.blanket_min_amount);
         oe_debug_pub.add('Before sending to the API OLd Blanket MIN number FROM the API '
                        ||l_old_header_rec.blanket_min_amount);

         OE_Blanket_Util.Validate_Entity(p_header_rec,
                                         l_old_header_rec,
                                         x_return_status);

         oe_debug_pub.add('After returning from the API New Blanket MAX number FROM the API '
                        ||p_header_rec.blanket_max_amount);
         oe_debug_pub.add('After returning from the API OLd Blanket MAX number FROM the API '
                        ||l_old_header_rec.blanket_max_amount);
         oe_debug_pub.add('After returning from the API New Blanket MIN number FROM the API '
                        ||p_header_rec.blanket_min_amount);
         oe_debug_pub.add('After returning from the API OLd Blanket MIN number FROM the API '
                        ||l_old_header_rec.blanket_min_amount);

         oe_debug_pub.add('Return status of validate entity API '
                        ||x_return_status);

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN

           oe_debug_pub.add('Return status int the IF Expected error API '
                        ||x_return_status);
           RAISE FND_API.G_EXC_ERROR;

         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

           oe_debug_pub.add('Return status int the ELSE in the unexpected errorAPI '
                        ||x_return_status);
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         END IF;

         oe_debug_pub.add('Before udation of the cache New Blanket MAX number after exp FROM the API '
                        ||p_header_rec.blanket_max_amount);
         oe_debug_pub.add('Before udation of the cache OLd Blanket MAX number after exp FROM the API '
                        ||l_old_header_rec.blanket_max_amount);
         oe_debug_pub.add('Before udation of the cache New Blanket MIN number after exp FROM the API '
                        ||p_header_rec.blanket_min_amount);
         oe_debug_pub.add('Before udation of the cache OLd Blanket MIN number after exp FROM the API '
                        ||l_old_header_rec.blanket_min_amount);

         Update_Header_Cache(p_header_rec);

         oe_debug_pub.add('After udation of the cache New Blanket MAX number after exp FROM the API '
                        ||p_header_rec.blanket_max_amount);
         oe_debug_pub.add('After udation of the cache OLd Blanket MAX number after exp FROM the API '
                        ||l_old_header_rec.blanket_max_amount);
         oe_debug_pub.add('After udation of the cache New Blanket MIN number after exp FROM the API '
                        ||p_header_rec.blanket_min_amount);
         oe_debug_pub.add('After udation of the cache OLd Blanket MIN number after exp FROM the API '
                        ||l_old_header_rec.blanket_min_amount);

         oe_msg_pub.count_and_get
         (   p_count     => x_msg_count
          ,  p_data      => x_msg_data);

         oe_debug_pub.add('After Validate Entity of the cache x_msg_count Header' ||x_msg_count);
         oe_debug_pub.add('After Validate Entity of the cache x_msg_data Header' ||x_msg_data);

     EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN

             x_return_status := FND_API.G_RET_STS_ERROR;
             --  Get message count and data

             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
              ,  p_data                        => x_msg_data
              );

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             --  Get message count and data
             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
             ,   p_data                        => x_msg_data
             );

         WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

             OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name);

         END IF;

         --  Get message count and data

         OE_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
          p_data  => x_msg_data);

     END Validate_Entity;


----------------------------------------------------------
     PROCEDURE Validate_Entity
----------------------------------------------------------
     (p_line_rec           IN OUT NOCOPY   OE_Blanket_PUB.line_rec_type,
      x_return_status      IN OUT NOCOPY   VARCHAR2,
      x_msg_count          OUT    NOCOPY   NUMBER,
      x_msg_data           OUT    NOCOPY   VARCHAR2

     ) IS
       l_old_line_rec    oe_blanket_pub.line_rec_type;
       l_api_name         CONSTANT VARCHAR2(30)         := 'Validate_Entity';
       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
     BEGIN

         OE_MSG_PUB.initialize;

         x_return_status := FND_API.G_RET_STS_SUCCESS;

         if p_line_rec.line_id is null then

              l_old_line_rec := NULL;

         else

            Load_Blanket_line_Rec (p_line_rec,l_old_line_rec);

         end if;

         oe_debug_pub.add('Inventory item id - RAJ' || p_line_rec.inventory_item_id);

         OE_Blanket_Util.Validate_Entity(p_line_rec,
				l_old_line_rec,
				x_return_status);

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         Update_Line_Cache(p_line_rec);

         if nvl(G_Blanket_Line_Number,0) < nvl(p_line_rec.line_number,0) then
             G_Blanket_Line_Number := p_line_rec.line_Number;
         end if;

         oe_msg_pub.count_and_get
         (   p_count     => x_msg_count
          ,  p_data      => x_msg_data);

         oe_debug_pub.add('After Validate Entity of the cache x_msg_count Line' ||x_msg_count);
         oe_debug_pub.add('After Validate Entity of the cache x_msg_data Line' ||x_msg_data);

     EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN
                   oe_debug_pub.add('Return Status is-Exp ' || X_return_status);
                   x_return_status := FND_API.G_RET_STS_ERROR;

                   --  Get message count and data

                   oe_msg_pub.count_and_get
                       (   p_count                       => x_msg_count
                        ,  p_data                        => x_msg_data
                       );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                  --  Get message count and data

                  oe_msg_pub.count_and_get
                  (   p_count                       => x_msg_count
                  ,   p_data                        => x_msg_data
                  );

          WHEN OTHERS THEN
                  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                  IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

                      OE_MSG_PUB.Add_Exc_Msg
                             (G_PKG_NAME,
                              l_api_name);

                  END IF;

                 --  Get message count and data

                  OE_MSG_PUB.Count_And_Get
                  ( p_count => x_msg_count,
                   p_data  => x_msg_data);

     END Validate_Entity;


----------------------------------------------------------
     PROCEDURE Insert_Row
----------------------------------------------------------
     (p_header_rec     IN OUT NOCOPY  OE_Blanket_PUB.Header_rec_type,
      x_return_status  OUT NOCOPY VARCHAR2,
      x_msg_count      OUT NOCOPY NUMBER,
      x_msg_data       OUT NOCOPY VARCHAR2
     )
     IS
       l_api_name         CONSTANT VARCHAR2(30)         := 'Insert_Row';
       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
     BEGIN
		OE_MSG_PUB.initialize;
         oe_debug_pub.add('Entering Header OE_Blanket_Form_Control.Insert_row', 1);

         OE_Blanket_Util.Insert_Row(p_header_rec,X_RETURN_STATUS);

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         oe_msg_pub.count_and_get
         (   p_count     => x_msg_count
          ,  p_data      => x_msg_data);

         oe_debug_pub.add('Entering Header OE_Blanket_Form_Control.Insert_row', 1);

     EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;

             --  Get message count and data

             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
              ,  p_data                        => x_msg_data
              );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             --  Get message count and data

             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
             ,   p_data                        => x_msg_data
             );

     WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                 OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                );
             END IF;

             --  Get message count and data

             OE_MSG_PUB.Count_And_Get
             ( p_count => x_msg_count,
              p_data  => x_msg_data);

     End Insert_Row;


----------------------------------------------------------
     PROCEDURE Update_Row
----------------------------------------------------------
     (p_header_rec     IN  OUT NOCOPY OE_Blanket_PUB.Header_rec_type,
      x_return_status  OUT NOCOPY VARCHAR2,
      x_msg_count      OUT NOCOPY NUMBER,
      x_msg_data       OUT NOCOPY VARCHAR2
     )
     IS
       l_api_name         CONSTANT VARCHAR2(30)     := 'Update_Row';
       l_debug_level      CONSTANT NUMBER           := oe_debug_pub.g_debug_level;

     BEGIN
		OE_MSG_PUB.initialize;
         oe_debug_pub.add('Entering Header OE_Blanket_Form_Control.Update_row', 1);

         OE_Blanket_Util.Update_Row(p_header_rec,X_RETURN_STATUS);

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         oe_msg_pub.count_and_get
         (   p_count     => x_msg_count
          ,  p_data      => x_msg_data);

         oe_debug_pub.add('Existing Header OE_Blanket_Form_Control.Update_row', 1);

     EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN

             x_return_status := FND_API.G_RET_STS_ERROR;

             --  Get message count and data

             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
              ,  p_data                        => x_msg_data
              );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             --  Get message count and data

             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
             ,   p_data                        => x_msg_data
             );

     WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                 OE_MSG_PUB.Add_Exc_Msg
                        (G_PKG_NAME,
                         l_api_name
                    );
             END IF;

             --  Get message count and data

             OE_MSG_PUB.Count_And_Get
             ( p_count => x_msg_count,
              p_data  => x_msg_data);

     End Update_Row;

----------------------------------------------------------
     PROCEDURE Delete_Row
----------------------------------------------------------
     (p_header_id     IN NUMBER,
      x_return_status  OUT NOCOPY VARCHAR2,
      x_msg_count      OUT NOCOPY NUMBER,
      x_msg_data       OUT NOCOPY VARCHAR2
     )
     IS
       l_api_name         CONSTANT VARCHAR2(30)         := 'Delete_Row';
       l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
     BEGIN
-- hashraf ... start of pack J

		OE_MSG_PUB.initialize;
         oe_debug_pub.add('Entering Header OE_Blanket_Form_Control.Delete_row', 1);

         OE_Blanket_Util.Delete_Row(p_header_id => p_header_id
				,X_RETURN_STATUS => x_return_status);

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         oe_msg_pub.count_and_get
         (   p_count     => x_msg_count
          ,  p_data      => x_msg_data);

         oe_debug_pub.add('Exiting Header OE_Blanket_Form_Control.Delete_row', 1);

     EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;

             --  Get message count and data

             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
              ,  p_data                        => x_msg_data
              );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             --  Get message count and data

             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
             ,   p_data                        => x_msg_data
             );

     WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                 OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                );
             END IF;

             --  Get message count and data

             OE_MSG_PUB.Count_And_Get
             ( p_count => x_msg_count,
              p_data  => x_msg_data);

     End Delete_Row;


----------------------------------------------------------
     PROCEDURE Insert_Row
----------------------------------------------------------
     (p_line_rec       IN  OUT NOCOPY OE_Blanket_PUB.line_rec_type,
      x_return_status  OUT NOCOPY  VARCHAR2,
      x_msg_count      OUT NOCOPY NUMBER,
      x_msg_data       OUT NOCOPY VARCHAR2
     )
     IS
       l_api_name         CONSTANT VARCHAR2(30)     := 'Update_Row';
       l_debug_level      CONSTANT NUMBER           := oe_debug_pub.g_debug_level;
     BEGIN
		OE_MSG_PUB.initialize;
         oe_debug_pub.add('Entering Lines OE_Blanket_Form_Control.Insert_row', 1);

         OE_Blanket_Util.Insert_Row(p_line_rec,X_RETURN_STATUS);

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         oe_msg_pub.count_and_get
         (   p_count     => x_msg_count
          ,  p_data      => x_msg_data);

         oe_debug_pub.add('Existing Lines OE_Blanket_Form_Control.Insert_row', 1);

     EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;

             --  Get message count and data

             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
              ,  p_data                        => x_msg_data
              );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             --  Get message count and data

             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
             ,   p_data                        => x_msg_data
             );

     WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                 OE_MSG_PUB.Add_Exc_Msg
                        (G_PKG_NAME,
                         l_api_name
                    );
             END IF;

             --  Get message count and data

             OE_MSG_PUB.Count_And_Get
             ( p_count => x_msg_count,
              p_data  => x_msg_data);

     End Insert_Row;


----------------------------------------------------------
     PROCEDURE Update_Row
----------------------------------------------------------
     (   p_line_rec       IN  OUT NOCOPY OE_Blanket_PUB.line_rec_type,
         x_return_status  OUT  NOCOPY  VARCHAR2,
         x_msg_count      OUT  NOCOPY NUMBER,
         x_msg_data       OUT  NOCOPY VARCHAR2
     )
     IS
       l_api_name         CONSTANT VARCHAR2(30)     := 'Update_Row';
       l_debug_level      CONSTANT NUMBER           := oe_debug_pub.g_debug_level;
     BEGIN
		OE_MSG_PUB.initialize;
         oe_debug_pub.add('Entering Lines OE_Blanket_Form_Control.Update_row', 1);
         OE_Blanket_Util.Update_Row(p_line_rec,X_RETURN_STATUS);

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         oe_msg_pub.count_and_get
         (   p_count     => x_msg_count
          ,  p_data      => x_msg_data);

         oe_debug_pub.add('Existing Lines OE_Blanket_Form_Control.Update_row', 1);

     EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;

             --  Get message count and data

             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
              ,  p_data                        => x_msg_data
              );

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             --  Get message count and data

             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
             ,   p_data                        => x_msg_data
             );

         WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                 OE_MSG_PUB.Add_Exc_Msg
                        (G_PKG_NAME,
                         l_api_name
                    );
             END IF;

             --  Get message count and data

             OE_MSG_PUB.Count_And_Get
             ( p_count => x_msg_count,
              p_data  => x_msg_data);

     End Update_Row;

----------------------------------------------------------
     PROCEDURE Delete_Row
----------------------------------------------------------
     (p_line_id       IN NUMBER,
      x_return_status  OUT NOCOPY  VARCHAR2,
      x_msg_count      OUT NOCOPY NUMBER,
      x_msg_data       OUT NOCOPY VARCHAR2
     )
     IS
       l_api_name         CONSTANT VARCHAR2(30)     := 'Delete_Row';
       l_debug_level      CONSTANT NUMBER           := oe_debug_pub.g_debug_level;
     BEGIN
-- hashraf ... start of pack J
		OE_MSG_PUB.initialize;
         oe_debug_pub.add('Entering Lines OE_Blanket_Form_Control.Delete_row', 1);

         OE_Blanket_Util.Delete_Row(p_line_id => p_line_id
				,x_return_status => X_RETURN_STATUS);

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         oe_msg_pub.count_and_get
         (   p_count     => x_msg_count
          ,  p_data      => x_msg_data);

         oe_debug_pub.add('Exiting Lines OE_Blanket_Form_Control.Delete_row', 1);

     EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;

             --  Get message count and data

             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
              ,  p_data                        => x_msg_data
              );

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             --  Get message count and data

             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
             ,   p_data                        => x_msg_data
             );

     WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                 OE_MSG_PUB.Add_Exc_Msg
                        (G_PKG_NAME,
                         l_api_name
                    );
             END IF;

             --  Get message count and data

             OE_MSG_PUB.Count_And_Get
             ( p_count => x_msg_count,
              p_data  => x_msg_data);

     End Delete_Row;


----------------------------------------------------------
     PROCEDURE Default_Attributes
----------------------------------------------------------
     (p_x_header_rec          IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      x_return_status         OUT NOCOPY VARCHAR2
     )
     IS
     l_error            NUMBER := 0;
     l_api_name         CONSTANT VARCHAR2(30)         := 'Default_Attributes';
     l_debug_level      CONSTANT NUMBER               := oe_debug_pub.g_debug_level;
     BEGIN
         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Entering Header OE_Blanket_Form_Control.DEFAULT_ATTRIBUTES', 1);
         END IF;
         OE_MSG_PUB.initialize;
         --Clearing the line cache Bug#4878846.
         g_line_cache_rec.delete;
         l_error := 1;

         --p_x_header_rec.operation := OE_GLOBALS.G_OPR_CREATE;

         OE_Blanket_Util.Default_Attributes (p_x_header_rec,x_return_status);

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         oe_msg_pub.count_and_get
         (   p_count     => x_msg_count
          ,  p_data      => x_msg_data);

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Exiting Header OE_Blanket_Form_Control.DEFAULT_ATTRIBUTES', 1);
         END IF;

     EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             --  Get message count and data
             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
              ,  p_data                        => x_msg_data
              );
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Exiting Header OE_Blanket_Form_Control.DEFAULT_ATTRIBUTES expected errors', 1);
             END IF;

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             --  Get message count and data
             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
             ,   p_data                        => x_msg_data
             );

         WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             IF OE_MSG_PUB.Check_Msg_Level
                (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
             THEN
                 OE_MSG_PUB.Add_Exc_Msg
                        (G_PKG_NAME,
                         l_api_name
                    );
             END IF;
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add('Exiting Header OE_Blanket_Form_Control.DEFAULT_ATTRIBUTES unexpected errors', 1);
             END IF;

             --  Get message count and data
             OE_MSG_PUB.Count_And_Get
             ( p_count => x_msg_count,
              p_data  => x_msg_data);

     END Default_Attributes;


----------------------------------------------------------
     PROCEDURE Default_Attributes
----------------------------------------------------------
     (p_x_line_rec            IN OUT NOCOPY OE_Blanket_PUB.line_rec_type,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      x_return_status         OUT NOCOPY VARCHAR2
     )
     IS
         l_old_blanket_line_number    number;
         l_error                      NUMBER;
         p_default_from_header        BOOLEAN := TRUE;
     BEGIN
         OE_MSG_PUB.initialize;
         oe_debug_pub.add('Entering Lines OE_Blanket_Form_Control.DEFAULT_ATTRIBUTES', 1);

         l_error := 1;
         l_old_blanket_line_number := p_x_line_rec.line_number;

         --p_x_line_rec.operation := OE_GLOBALS.G_OPR_CREATE;

         OE_Blanket_Util.Default_Attributes (p_x_line_rec,p_default_from_header,x_return_status);

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         -- Defaulting for Line Number

         if nvl(l_old_blanket_line_number,0) = 0 then
               g_blanket_line_number := nvl(g_blanket_line_number,0);
               p_x_line_rec.line_number := g_blanket_line_number;
         else
               p_x_line_rec.line_number := l_old_blanket_line_number;
         end if;

         oe_msg_pub.count_and_get
         (   p_count     => x_msg_count
          ,  p_data      => x_msg_data);

         oe_debug_pub.add('Existing Lines OE_Blanket_Form_Control.DEFAULT_ATTRIBUTES', 1);

     EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             --  Get message count and data
             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
              ,  p_data                        => x_msg_data
              );

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             --  Get message count and data
             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
             ,   p_data                        => x_msg_data
             );

         WHEN OTHERS THEN

             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             --  Get message count and data
             OE_MSG_PUB.Count_And_Get
             ( p_count => x_msg_count,
               p_data  => x_msg_data);

     END Default_Attributes;


----------------------------------------------------------
     PROCEDURE Process_Object
----------------------------------------------------------
     (   x_return_status  IN OUT NOCOPY VARCHAR2,
         x_msg_count      IN OUT NOCOPY NUMBER,
         x_msg_data       IN OUT NOCOPY VARCHAR2
     )
     IS
     ctr                number := 1;
     l_api_name         CONSTANT VARCHAR2(30)         := 'Process_Object';
     l_debug_level      CONSTANT NUMBER               := oe_debug_pub.g_debug_level;
     --bug#4691643
     I                  number := 1;
     l_dummy_header_rec oe_blanket_pub.header_rec_type;
     l_dummy_line_rec   oe_blanket_pub.line_rec_type;
     l_request_rec      OE_Order_PUB.Request_Rec_Type;
     l_return_status    varchar2(30);
     BEGIN


         OE_MSG_PUB.initialize;


         oe_debug_pub.add('Entering OE_Blanket_Form_Control.Process_object', 0);
         --bug#4691643
         --Log delayed requests again ,if delayed requests for the corresponding
         --entity doesn't exist because of exception
        While ctr <= G_header_Cache_Rec.count loop
        If G_header_cache_rec(ctr).operation IN
        (OE_GLOBALS.G_OPR_CREATE,OE_GLOBALS.G_OPR_UPDATE) then
		IF G_header_cache_rec(ctr).operation =OE_GLOBALS.G_OPR_CREATE
		THEN
        	l_dummy_header_rec := NULL;
		ELSIF G_header_cache_rec(ctr).operation
				=OE_GLOBALS.G_OPR_UPDATE THEN
                	OE_Blanket_util.Query_Header(
              				p_header_id =>G_header_cache_rec(ctr).header_id,
              				x_header_rec =>l_dummy_header_Rec,
              		 		x_return_status =>l_return_status);

			IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			RAISE FND_API.G_EXC_ERROR;
			END IF;
		END IF;
        	I := oe_delayed_requests_pvt.g_delayed_requests.first;
                WHILE I IS NOT NULL LOOP
                l_request_rec := oe_delayed_requests_pvt.g_delayed_requests(I);
                if l_request_rec.entity_id=G_header_cache_rec(ctr).header_id
                        then EXIT;
                end if;
                I := oe_delayed_requests_pvt.g_delayed_requests.next(I);
                END LOOP;
                IF I IS NULL THEN
                OE_Blanket_Util.Validate_Entity(G_header_cache_rec(ctr),
                                         l_dummy_header_rec,
                                         x_return_status);

                IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
                ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                END IF;
        END IF;
        ctr := ctr + 1;
        End Loop;

	ctr := 1;
        while ctr <= G_Line_Cache_Rec.count loop
        If G_line_cache_rec(ctr).operation IN
        (OE_GLOBALS.G_OPR_CREATE,OE_GLOBALS.G_OPR_UPDATE) then
		If G_line_cache_rec(ctr).operation = OE_GLOBALS.G_OPR_CREATE
		THEN
        	l_dummy_line_rec := NULL;
		ELSIF G_line_cache_rec(ctr).operation = OE_GLOBALS.G_OPR_UPDATE
		THEN
		l_dummy_line_rec := OE_Blanket_util.Query_Row(p_line_id => 											G_LIne_cache_rec(ctr).line_id);
		END IF;
        	I := oe_delayed_requests_pvt.g_delayed_requests.first;
                WHILE I IS NOT NULL LOOP
                l_request_rec := oe_delayed_requests_pvt.g_delayed_requests(I);
                if l_request_rec.entity_id=G_LIne_cache_rec(ctr).line_id
                then EXIT;
                end if;
                I := oe_delayed_requests_pvt.g_delayed_requests.next(I);
                END LOOP;
                IF I IS NULL THEN
                OE_Blanket_Util.Validate_Entity(G_line_cache_rec(ctr),
                                         l_dummy_line_rec,
                                         x_return_status);

                IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
                ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                END IF;
        END IF;
       ctr := ctr + 1;
       end loop;

ctr := 1;
    oe_debug_pub.add('Entering OE_Blanket_Form_Control.Process_object', 0);
    --bug#4691643 end
      ----------------------------------------------------------
         -- Insert or Update Header Records into the Database
         ----------------------------------------------------------

         --x_return_status := FND_API.G_RET_STS_SUCCESS;

         --For bug 3217764. Altered the Exception Logic.
         --1. Moved the savepoint out of the loop
         --2. Commented out all the exception block and having a common exception block for the fn.

         SAVEPOINT Save_Blanket_Changes;

         While ctr <= G_header_Cache_Rec.count loop
              oe_debug_pub.add('Operation IS: '||G_header_cache_rec(ctr).operation);
              x_return_status := FND_API.G_RET_STS_SUCCESS;

              If G_header_cache_rec(ctr).operation = OE_GLOBALS.G_OPR_UPDATE then
                 oe_debug_pub.add('Operation in Update Condi: '||G_header_cache_rec(ctr).operation);
                 OE_Blanket_Util.Update_Row(G_header_Cache_Rec(ctr),x_return_status);
              ElsIf G_header_cache_rec(ctr).operation = OE_GLOBALS.G_OPR_CREATE then
                 oe_debug_pub.add('Operation IN Insert Condi: '||G_header_cache_rec(ctr).operation);
                 OE_Blanket_Util.Insert_Row(G_header_Cache_Rec(ctr),x_return_status);

                 --Workflow changes for 11i10.
                 --For the bug3230820
                 -- Move this particular code to Oe_Blanket_Util.Process_object.
                 -- Where we are calling directly to accomaidate both for backend creation of BSA and
                 -- Through BSA UI.

              -- hashraf ... start of pack J
              ElsIf G_header_cache_rec(ctr).operation = OE_GLOBALS.G_OPR_DELETE then
                    oe_debug_pub.add('Operation IS Delete Condi: '||G_header_cache_rec(ctr).operation);
                    OE_Blanket_Util.Delete_Row(p_header_id     => G_header_Cache_Rec(ctr).header_id,
                                               x_return_status => x_return_status);
              -- hashraf ... end of pack J
              End if;

              IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 ROLLBACK TO SAVEPOINT Save_Blanket_Changes;
              END IF;

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

              oe_msg_pub.count_and_get
                       (   p_count     => x_msg_count
                        ,  p_data      => x_msg_data);

              --for bug 3217764, the exception block was removed
              /*   Exception
                   End;
              */

              ctr := ctr + 1;

         End Loop;

         ----------------------------------------------------------
         -- Insert or Update Line Records into the Database
         ----------------------------------------------------------
         ctr := 1;

         while ctr <= G_Line_Cache_Rec.count loop

               If G_line_cache_rec(ctr).operation = OE_GLOBALS.G_OPR_UPDATE then
                  oe_debug_pub.add('Process_object for Lines update', 4);
                  OE_Blanket_Util.Update_Row(G_line_Cache_Rec(ctr),x_return_status);
               ElsIf G_line_cache_rec(ctr).operation = OE_GLOBALS.G_OPR_CREATE then
                  oe_debug_pub.add('Process_object for Lines Insert', 5);
                  OE_Blanket_Util.Insert_Row(G_line_Cache_Rec(ctr),x_return_status);
               -- hashraf ... start of pack J
               ElsIf G_line_cache_rec(ctr).operation = OE_GLOBALS.G_OPR_DELETE then
                  oe_debug_pub.add('Process_object for Lines Delete', 6);
                  OE_Blanket_Util.Delete_Row(p_line_id => G_line_Cache_Rec(ctr).line_id, x_return_status => x_return_status);
               -- hashraf ... end of pack J
               End if;

               IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

               oe_msg_pub.count_and_get
                       (   p_count     => x_msg_count
                        ,  p_data      => x_msg_data);

               --for bug 3217764, the exception block code has been removed.
               /*  Exception
                  End;
               */
               ctr := ctr + 1;

         end loop;
         if x_return_status = FND_API.G_RET_STS_SUCCESS then
            OE_Blanket_Util.Process_Object(x_return_status);
         end if;

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            --only delete cache if successfully processed delayed requests
            g_header_cache_rec.delete;
            g_line_cache_rec.delete;
         END IF;

         oe_msg_pub.count_and_get
         (   p_count     => x_msg_count
          ,  p_data      => x_msg_data);

         oe_debug_pub.add(' oe_msg_pub.count_and_get x_msg_count'||x_msg_count);
         oe_debug_pub.add(' oe_msg_pub.count_and_get x_msg_data'||x_msg_data);
         oe_debug_pub.add('Leaving from the Process Object OE_Blanket_Form_Control.Process_object ', 5);

     EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;

             --  Get message count and data
             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
              ,  p_data                        => x_msg_data
              );
             --for bug 3217764
             oe_debug_pub.add('Leaving the Process Object with excepted errors', 5);
             ROLLBACK TO SAVEPOINT Save_Blanket_Changes;

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             --  Get message count and data

             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
             ,   p_data                        => x_msg_data
             );
             --for bug 3217764
             oe_debug_pub.add('Leaving the Process Object with unexcepted errors', 5);
             ROLLBACK TO SAVEPOINT Save_Blanket_Changes;

         WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

             IF OE_MSG_PUB.Check_Msg_Level
                (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
             THEN
                 OE_MSG_PUB.Add_Exc_Msg
                        (G_PKG_NAME,
                         l_api_name
                    );
             END IF;

             --  Get message count and data
             OE_MSG_PUB.Count_And_Get
             ( p_count => x_msg_count,
              p_data  => x_msg_data);
              --for bug 3217764
              oe_debug_pub.add('Leaving the Process Object with other errors', 5);
              ROLLBACK TO SAVEPOINT Save_Blanket_Changes;
     END Process_Object;


----------------------------------------------------------
    PROCEDURE Check_Sec_Header_Attr
----------------------------------------------------------
    (x_return_status         IN OUT NOCOPY varchar2,
     p_header_rec            IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type,
     p_old_header_rec        IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type,
     -- 11i10 Pricing Changes
     p_column_name           IN VARCHAR2 DEFAULT NULL,
     x_msg_count             IN OUT NOCOPY NUMBER,
     x_msg_data              IN OUT NOCOPY VARCHAR2)
    IS
     l_result NUMBER;
     -- 11i10 Pricing Changes
     l_operation             varchar2(30);
     l_action                number;
     l_rowtype_rec           oe_ak_blanket_headers_v%rowtype;
     l_api_name            CONSTANT VARCHAR2(30)  := 'Check_Sec_Header_Attr';
    BEGIN
           oe_debug_pub.add('Entering oe_blanket_form_control.check_sec_header_attr');
		OE_MSG_PUB.initialize;


        IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN

           -- 11i10 Pricing Changes
           -- Check security for a specific attribute
           IF p_column_name IS NOT NULL THEN

              OE_BLANKET_UTIL.API_Rec_To_Rowtype_Rec
                               (p_header_rec,l_rowtype_rec);
              if p_header_rec.operation = OE_GLOBALS.G_OPR_CREATE then
                 l_operation := OE_PC_GLOBALS.CREATE_OP;
              elsif p_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE then
                 l_operation := OE_PC_GLOBALS.UPDATE_OP;
              end if;

              -- Initialize security global record
              OE_Blanket_Header_Security.g_record := l_rowtype_rec;

              l_result := OE_Blanket_Header_Security.Is_OP_Constrained
                               (p_operation => l_operation
                               ,p_column_name => p_column_name
                               ,p_record => l_rowtype_rec
                               ,x_on_operation_action => l_action
                               );
              if l_result = OE_PC_GLOBALS.YES then
                 raise fnd_api.g_exc_error;
              end if;

           -- Check security for all attributes that changed
           ELSE

              OE_Blanket_Header_Security.Attributes(p_header_rec => p_header_rec,
                      p_old_header_rec => p_old_header_rec,
                      x_result => l_result,
                      x_return_status => x_return_status);

              IF l_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
              END IF;

           END IF; -- if column name is not null

         END IF; -- if code release level >= 11i10

         oe_msg_pub.count_and_get
         (   p_count     => x_msg_count
          ,  p_data      => x_msg_data);

           oe_debug_pub.add('Exiting oe_blanket_form_control.check_sec_header_attr');
    EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN

             x_return_status := FND_API.G_RET_STS_ERROR;
             --  Get message count and data

             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
              ,  p_data                        => x_msg_data
              );

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             --  Get message count and data
             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
             ,   p_data                        => x_msg_data
             );

         WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

             OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name);

         END IF;

         --  Get message count and data

         OE_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
          p_data  => x_msg_data);

    END Check_Sec_Header_Attr;

----------------------------------------------------------
    PROCEDURE Check_Sec_Line_Attr
----------------------------------------------------------
    (x_return_status         IN OUT NOCOPY varchar2,
     p_line_rec            IN OUT NOCOPY OE_Blanket_PUB.Line_rec_type,
     p_old_line_rec        IN OUT NOCOPY OE_Blanket_PUB.Line_rec_type,
     x_msg_count             IN OUT NOCOPY NUMBER,
     x_msg_data              IN OUT NOCOPY VARCHAR2)
    IS
     l_result NUMBER;
     l_api_name            CONSTANT VARCHAR2(30)  := 'Check_Sec_Line_Attr';

    BEGIN
		OE_MSG_PUB.initialize;

        IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN

         OE_Blanket_Line_Security.Attributes(p_line_rec => p_line_rec,
                      p_old_line_rec => p_old_line_rec,
                      x_result => l_result,
                      x_return_status => x_return_status);

           IF l_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;

         oe_msg_pub.count_and_get
         (   p_count     => x_msg_count
          ,  p_data      => x_msg_data);

    EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN

             x_return_status := FND_API.G_RET_STS_ERROR;
             --  Get message count and data

             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
              ,  p_data                        => x_msg_data
              );

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             --  Get message count and data
             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
             ,   p_data                        => x_msg_data
             );

         WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

             OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name);

         END IF;

         --  Get message count and data

         OE_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
          p_data  => x_msg_data);

    END Check_Sec_Line_Attr;

----------------------------------------------------------
    PROCEDURE Check_Sec_Header_Entity
----------------------------------------------------------
    (x_return_status         IN OUT NOCOPY varchar2,
     p_header_rec            IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type,
     x_msg_count             IN OUT NOCOPY NUMBER,
     x_msg_data              IN OUT NOCOPY VARCHAR2)
    IS
     l_result NUMBER;
     l_api_name            CONSTANT VARCHAR2(30)  := 'Check_Sec_Header_Entity';

    BEGIN
           oe_debug_pub.add('Entering oe_blanket_form_control.check_sec_header_Entity');
		OE_MSG_PUB.initialize;

        IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN

         OE_Blanket_Header_Security.Entity(p_header_rec => p_header_rec,
                      x_result => l_result,
                      x_return_status => x_return_status);

           IF l_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

        END IF;

         oe_msg_pub.count_and_get
         (   p_count     => x_msg_count
          ,  p_data      => x_msg_data);

           oe_debug_pub.add('Exiting oe_blanket_form_control.check_sec_header_Entity');
    EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN

             x_return_status := FND_API.G_RET_STS_ERROR;
             --  Get message count and data

             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
              ,  p_data                        => x_msg_data
              );

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             --  Get message count and data
             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
             ,   p_data                        => x_msg_data
             );

         WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

             OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name);

         END IF;

         --  Get message count and data

         OE_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
          p_data  => x_msg_data);

    END Check_Sec_Header_Entity;

----------------------------------------------------------
    PROCEDURE Check_Sec_Line_Entity
----------------------------------------------------------
    (x_return_status         IN OUT NOCOPY varchar2,
     p_line_rec            IN OUT NOCOPY OE_Blanket_PUB.Line_rec_type,
     x_msg_count             IN OUT NOCOPY NUMBER,
     x_msg_data              IN OUT NOCOPY VARCHAR2)
    IS
     l_result NUMBER;
     l_api_name            CONSTANT VARCHAR2(30)  := 'Check_Sec_Line_Entity';

    BEGIN
		OE_MSG_PUB.initialize;

        IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN

         OE_Blanket_Line_Security.Entity(p_line_rec => p_line_rec,
                      x_result => l_result,
                      x_return_status => x_return_status);

           IF l_result = OE_PC_GLOBALS.YES THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;

        END IF;

         oe_msg_pub.count_and_get
         (   p_count     => x_msg_count
          ,  p_data      => x_msg_data);

    EXCEPTION

         WHEN FND_API.G_EXC_ERROR THEN

             x_return_status := FND_API.G_RET_STS_ERROR;
             --  Get message count and data

             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
              ,  p_data                        => x_msg_data
              );

         WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
             --  Get message count and data
             oe_msg_pub.count_and_get
             (   p_count                       => x_msg_count
             ,   p_data                        => x_msg_data
             );

         WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

             OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name);

         END IF;

         --  Get message count and data

         OE_MSG_PUB.Count_And_Get
         ( p_count => x_msg_count,
          p_data  => x_msg_data);

    END Check_Sec_Line_Entity;

----------------------------------------------------------
     PROCEDURE Update_Header_Cache
----------------------------------------------------------
     (p_x_header_rec            IN OUT NOCOPY OE_Blanket_PUB.header_rec_type,
      delete_flag               IN            Varchar2 )
     IS
         ctr                    number;
         found_flag             varchar2(1);
         l_return_status        varchar2(80);
     BEGIN

         oe_debug_pub.add('Entering Update_Header_Cache OE_Blanket_Form_Control.Update_Header_Cache ', 0);

         found_flag := 'N';
         ctr := 1;

         if G_Header_Cache_Rec.count = 0 then
            oe_debug_pub.add('Update_Header_Cache is Zero ', 1);
            if delete_flag <> 'Y' THEN
               G_Header_Cache_Rec(ctr) := p_x_header_rec;
            end if;
         else
            oe_debug_pub.add('Update_Header_Cache is greater then Zero ', 2);
            while ctr <= G_Header_Cache_Rec.count and found_flag = 'N' loop
                  if G_Header_Cache_Rec(ctr).header_id = p_x_header_rec.header_id then
                     found_flag := 'Y';
                  else
                     ctr := ctr + 1;
                  end if;
            end loop;
         end if;

         /* Later change it to update only for changed attributes */

         If delete_flag = 'Y' then
            If found_flag = 'Y' then
               G_Header_Cache_Rec(ctr) := NULL;
               OE_DELAYED_REQUESTS_PVT.Delete_Reqs_for_Deleted_Entity(
                         p_entity_code  => OE_BLANKET_PUB.G_ENTITY_BLANKET_HEADER
                         ,p_entity_id    => p_x_header_rec.header_id
			 , p_delete_against => FALSE
                         ,x_return_status => l_return_status);
            End if;
         Else
            oe_debug_pub.add('Update_Header_Cache is  OE_Blanket_Form_Control.Update_Header_Cache ', 3);
            oe_debug_pub.add('Header Operation Code :'||p_x_header_rec.operation);
            G_Header_Cache_Rec(ctr) := p_x_header_rec;
         End if;
         oe_debug_pub.add('Exiting Update_Header_Cache OE_Blanket_Form_Control.Update_Header_Cache ', 4);

     END Update_Header_Cache;


----------------------------------------------------------
     PROCEDURE Update_Line_Cache
----------------------------------------------------------
         (p_x_line_rec            IN OUT NOCOPY OE_Blanket_PUB.line_rec_type,
          delete_flag             IN            VARCHAR2 := NULL)
     IS
         ctr                      number;
         found_flag               varchar2(1);
         l_return_status          varchar2(80);
     BEGIN

         oe_debug_pub.add('Entering Update_line_Cache OE_Blanket_Form_Control.Update_line_Cache ', 0);

         found_flag := 'N';
         ctr := 1;

         if G_Line_Cache_Rec.count = 0 then
            oe_debug_pub.add('Update_line_Cache is Zero ', 1);
            if  delete_flag <> 'Y' then
                G_Line_Cache_Rec(ctr) := p_x_Line_rec;
            end if;
         else
            oe_debug_pub.add('Update_line_Cache is greater then Zero ', 2);
            while ctr <= G_Line_Cache_Rec.count and found_flag = 'N' loop
                  if G_Line_Cache_Rec(ctr).Line_id = p_x_Line_rec.Line_id then
                     found_flag := 'Y';
                  else
                     ctr := ctr + 1;
                  end if;
            end loop;

         end if;

         /* Later change it to update only changed attributes */

         If delete_flag = 'Y' then

            If found_flag = 'Y' then
               OE_DELAYED_REQUESTS_PVT.Delete_Reqs_for_Deleted_Entity(
                         p_entity_code  => OE_BLANKET_PUB.G_ENTITY_BLANKET_LINE
                         ,p_entity_id    => p_x_Line_rec.Line_id
			, p_delete_against => FALSE
                         ,x_return_status => l_return_status);

               G_Line_Cache_Rec(ctr) := NULL;
            End if;
         Else
            oe_debug_pub.add('Line Operation Code :'||p_x_Line_rec.operation);
            G_Line_Cache_Rec(ctr) := p_x_Line_rec;
         End if;
         oe_debug_pub.add('Exiting Update_line_Cache OE_Blanket_Form_Control.Update_line_Cache ', 4);
     END Update_Line_Cache;


----------------------------------------------------------
     PROCEDURE Lock_Header_Row
----------------------------------------------------------
     (p_row_id IN VARCHAR2)
     IS
         dummy_id number;
     BEGIN

         select order_number into dummy_id from oe_blanket_headers
         where rowid = p_row_id for update;

     END Lock_Header_Row;


----------------------------------------------------------
     PROCEDURE Lock_Line_Row
----------------------------------------------------------
     (p_row_id IN VARCHAR2)
     IS
         dummy_id number;
     BEGIN

         select line_id into dummy_id from oe_blanket_Lines
         where rowid = p_row_id for update;

     END Lock_Line_Row;


----------------------------------------------------------
     PROCEDURE Load_Blanket_Line_Number
----------------------------------------------------------
     (l_x_header_id IN Varchar2)
     IS
         l_blanket_line_number  number;
     BEGIN

         select max(line_number) into l_blanket_line_number
         from oe_blanket_lines
         where header_id = l_x_header_id;

         g_blanket_line_number :=
                     greatest(nvl(g_blanket_line_number,0),nvl(l_blanket_line_number,0));

     END Load_Blanket_Line_Number;


----------------------------------------------------------
     PROCEDURE Load_Blanket_Header_Rec
----------------------------------------------------------
     (p_x_Header_rec            IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type
     ,p_x_old_Header_rec        IN OUT NOCOPY OE_Blanket_PUB.Header_rec_type)
     IS
         ctr               number      := 1;
         found_flag        varchar2(1) := 'N';
         l_x_return_status varchar2(30);
     BEGIN
		OE_MSG_PUB.initialize;

         while ctr <= G_header_Cache_Rec.count loop

              if g_header_cache_rec(ctr).header_id = p_x_header_rec.header_id then

                   p_x_old_header_rec := g_header_cache_rec(ctr);
                   found_flag := 'Y';
                   exit;

              else

                   ctr :=  ctr + 1;

              end if;

         end loop;

         if found_flag = 'N' then

             Begin
		OE_MSG_PUB.initialize;

                  OE_Blanket_Util.Query_Header
                   (p_header_id     => p_x_header_rec.header_id,
                    x_header_rec    => p_x_old_header_rec,
                    x_return_status => l_x_return_status);

             Exception

                 When others then
                     p_x_old_header_rec := NULL;

             End;

         end if;

     END Load_Blanket_Header_Rec;


----------------------------------------------------------
     PROCEDURE Load_Blanket_Line_Rec
----------------------------------------------------------
     (p_x_line_rec            IN  OE_Blanket_PUB.line_rec_type
     ,p_x_old_line_rec        IN OUT NOCOPY OE_Blanket_PUB.line_rec_type)
     IS
         ctr            number      := 1;
         found_flag     varchar2(1) := 'N';
         l_x_return_status         varchar2(1);
         l_line_tbl                oe_blanket_pub.line_tbl_type;
     BEGIN

         while ctr <= G_line_Cache_Rec.count loop

              if g_line_cache_rec(ctr).line_id = p_x_line_rec.line_id then

                   p_x_old_line_rec := g_line_cache_rec(ctr);
                   found_flag := 'Y';
                   exit;

              else

                   ctr :=  ctr + 1;

              end if;

         end loop;

         if found_flag = 'N' then

             -- 11i10 Pricing Changes
             -- Comment out the query here and call query_line
             -- instead to populate the line record.
             begin

             OE_Blanket_Util.Query_Lines
                   (p_line_id     => p_x_line_rec.line_id,
                    x_line_tbl    => l_line_tbl,
                    x_return_status => l_x_return_status);

             p_x_old_line_rec := l_line_tbl(1);

             exception
               when others then
                  p_x_old_line_rec := null;
             end;

/*
             Begin

                  SELECT
                          ACCOUNTING_RULE_ID
                  ,       AGREEMENT_ID
                  ,       ATTRIBUTE1
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
                  ,       CONTEXT
                  ,       CREATED_BY
                  ,       CREATION_DATE
                  ,       CUST_PO_NUMBER
                  ,       DELIVER_TO_ORG_ID
                  ,       FREIGHT_TERMS_CODE
                  ,       header_id
                  ,       INVENTORY_ITEM_ID
                  ,       INVOICE_TO_ORG_ID
                  ,       INVOICING_RULE_ID
                  ,       ORDERED_ITEM_ID
                  ,       ITEM_IDENTIFIER_TYPE
                  ,       ORDERED_ITEM
                  ,       ITEM_TYPE_CODE
                  ,       LAST_UPDATED_BY
                  ,       LAST_UPDATE_DATE
                  ,       LAST_UPDATE_LOGIN
                  ,       line_id
                  ,       line_number
                  ,       PAYMENT_TERM_ID
                  ,       PREFERRED_GRADE
                  ,       PRICE_LIST_ID
                  ,       PROGRAM_APPLICATION_ID
                  ,       PROGRAM_ID
                  ,       PROGRAM_UPDATE_DATE
                  ,       REQUEST_ID
                  ,       SALESREP_ID
                  ,       SHIPPING_METHOD_CODE
                  ,       ship_from_org_id
                  ,       SHIP_TO_ORG_ID
                  ,       SHIPPING_INSTRUCTIONS
                  ,       PACKING_INSTRUCTIONS
                  ,       START_DATE_ACTIVE
                  ,       END_DATE_ACTIVE
                  ,       MAX_RELEASE_AMOUNT
                  ,       MIN_RELEASE_AMOUNT
                  ,       MAX_RELEASE_QUANTITY
                  ,       MIN_RELEASE_QUANTITY
                  ,       BLANKET_LINE_MAX_AMOUNT
                  ,       BLANKET_LINE_MIN_AMOUNT
                  ,       BLANKET_MAX_QUANTITY
                  ,       BLANKET_MIN_QUANTITY
                  ,       OVERRIDE_BLANKET_CONTROLS_FLAG
                  ,       ENFORCE_PRICE_LIST_FLAG
                  ,       ORDER_QUANTITY_UOM
                  ,       RELEASED_QUANTITY
                  ,       FULFILLED_QUANTITY
                  ,       RETURNED_QUANTITY
                  ,       RELEASED_AMOUNT
                  ,       LOCK_CONTROL
                  ,       fulfilled_amount
		  ,	  transaction_phase_code   -- hashraf ... pack J
                  ,       source_document_version_number
                  INTO
                          p_x_old_line_rec.ACCOUNTING_RULE_ID
                  ,       p_x_old_line_rec.AGREEMENT_ID
                  ,       p_x_old_line_rec.ATTRIBUTE1
                  ,       p_x_old_line_rec.ATTRIBUTE10
                  ,       p_x_old_line_rec.ATTRIBUTE11
                  ,       p_x_old_line_rec.ATTRIBUTE12
                  ,       p_x_old_line_rec.ATTRIBUTE13
                  ,       p_x_old_line_rec.ATTRIBUTE14
                  ,       p_x_old_line_rec.ATTRIBUTE15
                  ,       p_x_old_line_rec.ATTRIBUTE2
                  ,       p_x_old_line_rec.ATTRIBUTE3
                  ,       p_x_old_line_rec.ATTRIBUTE4
                  ,       p_x_old_line_rec.ATTRIBUTE5
                  ,       p_x_old_line_rec.ATTRIBUTE6
                  ,       p_x_old_line_rec.ATTRIBUTE7
                  ,       p_x_old_line_rec.ATTRIBUTE8
                  ,       p_x_old_line_rec.ATTRIBUTE9
                  ,       p_x_old_line_rec.CONTEXT
                  ,       p_x_old_line_rec.CREATED_BY
                  ,       p_x_old_line_rec.CREATION_DATE
                  ,       p_x_old_line_rec.CUST_PO_NUMBER
                  ,       p_x_old_line_rec.DELIVER_TO_ORG_ID
                  ,       p_x_old_line_rec.FREIGHT_TERMS_CODE
                  ,       p_x_old_line_rec.header_id
                  ,       p_x_old_line_rec.INVENTORY_ITEM_ID
                  ,       p_x_old_line_rec.INVOICE_TO_ORG_ID
                  ,       p_x_old_line_rec.INVOICING_RULE_ID
                  ,       p_x_old_line_rec.ORDERED_ITEM_ID
                  ,       p_x_old_line_rec.ITEM_IDENTIFIER_TYPE
                  ,       p_x_old_line_rec.ORDERED_ITEM
                  ,       p_x_old_line_rec.ITEM_TYPE_CODE
                  ,       p_x_old_line_rec.LAST_UPDATED_BY
                  ,       p_x_old_line_rec.LAST_UPDATE_DATE
                  ,       p_x_old_line_rec.LAST_UPDATE_LOGIN
                  ,       p_x_old_line_rec.line_id
                  ,       p_x_old_line_rec.line_number
                  ,       p_x_old_line_rec.PAYMENT_TERM_ID
                  ,       p_x_old_line_rec.PREFERRED_GRADE
                  ,       p_x_old_line_rec.PRICE_LIST_ID
                  ,       p_x_old_line_rec.PROGRAM_APPLICATION_ID
                  ,       p_x_old_line_rec.PROGRAM_ID
                  ,       p_x_old_line_rec.PROGRAM_UPDATE_DATE
                  ,       p_x_old_line_rec.REQUEST_ID
                  ,       p_x_old_line_rec.SALESREP_ID
                  ,       p_x_old_line_rec.SHIPPING_METHOD_CODE
                  ,       p_x_old_line_rec.ship_from_org_id
                  ,       p_x_old_line_rec.SHIP_TO_ORG_ID
                  ,       p_x_old_line_rec.SHIPPING_INSTRUCTIONS
                  ,       p_x_old_line_rec.PACKING_INSTRUCTIONS
                  ,       p_x_old_line_rec.START_DATE_ACTIVE
                  ,       p_x_old_line_rec.END_DATE_ACTIVE
                  ,       p_x_old_line_rec.MAX_RELEASE_AMOUNT
                  ,       p_x_old_line_rec.MIN_RELEASE_AMOUNT
                  ,       p_x_old_line_rec.MAX_RELEASE_QUANTITY
                  ,       p_x_old_line_rec.MIN_RELEASE_QUANTITY
                  ,       p_x_old_line_rec.blanket_max_amount
                  ,       p_x_old_line_rec.blanket_min_amount
                  ,       p_x_old_line_rec.BLANKET_MAX_QUANTITY
                  ,       p_x_old_line_rec.BLANKET_MIN_QUANTITY
                  ,       p_x_old_line_rec.OVERRIDE_BLANKET_CONTROLS_FLAG
                  ,       p_x_old_line_rec.ENFORCE_PRICE_LIST_FLAG
                  ,       p_x_old_line_rec.order_quantity_UOM
                  ,       p_x_old_line_rec.RELEASED_QUANTITY
                  ,       p_x_old_line_rec.FULFILLED_QUANTITY
                  ,       p_x_old_line_rec.RETURNED_QUANTITY
                  ,       p_x_old_line_rec.RELEASED_AMOUNT
                  ,       p_x_old_line_rec.LOCK_CONTROL
                  ,       p_x_old_line_rec.fulfilled_amount
		  ,	  p_x_old_line_rec.transaction_phase_code -- hashraf pack J
		  ,	  p_x_old_line_rec.source_document_version_number
                  FROM    OE_BLANKET_LINES_V bl
                  WHERE   line_id = p_x_line_rec.line_id;

             Exception

                 When others then

                     p_x_old_line_rec := NULL;

             End;
*/

         end if;

     END Load_Blanket_Line_Rec;
----------------------------------------------------------
     FUNCTION Line_Number
----------------------------------------------------------
    ( p_header_id          IN  NUMBER
    ) RETURN number
    IS
    l_line_number number;
    Begin

        if (p_header_id is null or p_header_id = '')then

           l_line_number := null;
           RETURN l_line_number;

        else

           begin
               select max(line_number) into l_line_number
               from oe_blanket_lines
               where header_id = p_header_id;
           exception
               when no_data_found then
                   l_line_number :=0;
           end;

           RETURN nvl(l_line_number,0);
        end if;

    END Line_Number;

----------------------------------------------------------
     FUNCTION Line_Number_reset
----------------------------------------------------------
    RETURN varchar2
    IS
    l_return_status varchar2(10);
    Begin
      G_Blanket_Line_Number := G_Blanket_Line_Number-1;
      l_return_status := 'TRUE';
      return l_return_status;
    end Line_Number_reset;

----------------------------------------------------------
     FUNCTION Sales_Order_Type
----------------------------------------------------------
    (p_order_type_id   IN NUMBER)
    RETURN varchar2
    IS
    l_order_type varchar2(240);
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    Begin
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Entering  OE_Blanket_Form_Control.Sales_Order_Type order Type Id : '||p_order_type_id);
        END IF;
        select
	name into l_order_type
        from 	oe_transaction_types_vl
        where 	SALES_DOCUMENT_TYPE_CODE = 'B'
        AND     transaction_type_id = p_order_type_id;

        return l_order_type;
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Exiting OE_Blanket_Form_Control.Sales_Order_Type order type: '||l_order_type);
        END IF;

    EXCEPTION

    WHEN NO_DATA_FOUND THEN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('IN NO_DATA_FOUND OE_Blanket_Form_Control.Sales_Order_Type for order type ID: '||p_order_type_id);
        END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN
            fnd_message.set_name('ONT','OE_ID_TO_VALUE_ERROR');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Sales_Order_Type');
            OE_MSG_PUB.Add;

        END IF;

        RETURN NULL;

    WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('IN OTEHRS OE_Blanket_Form_Control.Sales_Order_Type for order type ID: '||p_order_type_id);
        END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sales_Order_Type'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end Sales_Order_Type;
----------------------------------------------------------
     FUNCTION item_identifier
----------------------------------------------------------
    (p_item_identifier_type   IN VARCHAR2)
    RETURN varchar2
    IS
    l_item_identifier varchar2(240);
    Begin

        SELECT meaning
        INTO  l_item_identifier
        FROM oe_lookups
        WHERE lookup_type = 'ITEM_IDENTIFIER_TYPE'
        AND   lookup_code = p_item_identifier_type;

        return l_item_identifier;

    end item_identifier;
----------------------------------------------------------
     FUNCTION Get_Currency_Format
----------------------------------------------------------
    (p_currency_code    IN VARCHAR2,
     p_field_length     IN NUMBER,
     p_percision        IN NUMBER,
     p_min_acct_unit    IN NUMBER)
     RETURN VARCHAR2
     IS
     l_format_mask       VARCHAR2(500);
     X_precision         NUMBER := 6;
     X_Ext_precision     NUMBER;
     X_min_acct_unit     NUMBER;
     l_precision_type    VARCHAR2(30);
     Begin
         -- For the bug #4106882
         -- Originally we use to format based on the hardcoded precision
         -- , now we have changed to get the precision based on the QP profile
         -- else we will hard coded to 6 digits.
         -- This new format will affect all the amounts fields on BSA UI.
         FND_CURRENCY.Get_Info(p_currency_code, X_precision,
                              X_Ext_precision, X_min_acct_unit);
         fnd_profile.get('QP_UNIT_PRICE_PRECISION_TYPE', l_precision_type);
         IF (l_precision_type = 'EXTENDED') THEN
            FND_CURRENCY.Build_Format_Mask(l_format_mask, p_field_length,
            X_Ext_precision,X_min_acct_unit, TRUE);
         ELSE
            FND_CURRENCY.Build_Format_Mask(l_format_mask, p_field_length,
            X_precision,X_min_acct_unit, TRUE);
         END IF;
         RETURN l_format_mask;

     END;

----------------------------------------------------------
     FUNCTION Get_Opr_Create
----------------------------------------------------------
     RETURN varchar2
     IS
     BEGIN
         RETURN OE_GLOBALS.G_OPR_CREATE;
     END;

----------------------------------------------------------
     FUNCTION Get_Opr_Update
----------------------------------------------------------
     RETURN varchar2
     IS
     BEGIN
         RETURN OE_GLOBALS.G_OPR_UPDATE;
     END;

----------------------------------------------------------
     FUNCTION Get_Opr_Delete
----------------------------------------------------------
     RETURN varchar2
     IS
     BEGIN
         -- hashraf new function for pack J
         RETURN OE_GLOBALS.G_OPR_DELETE;
     END;

----------------------------------------------------------
     FUNCTION chk_for_header_release
----------------------------------------------------------
    (p_blanket_number   IN number)
    RETURN varchar2
    IS
    l_return    varchar2(10):= 'FALSE';
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    Begin

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('IN OE_Blanket_Form_Control.chk_for_header_release '||p_blanket_number);
        END IF;

        if p_blanket_number is not null then

            begin

               SELECT 'TRUE'
               INTO  l_return
               FROM oe_order_headers
               WHERE blanket_number = p_blanket_number
               AND ROWNUM = 1;

            exception

               when no_data_found then

                    SELECT 'TRUE'
                    INTO  l_return
                    FROM oe_order_lines
                    WHERE blanket_number = p_blanket_number
                    AND ROWNUM = 1;
            end;

        end if;

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('IN OE_Blanket_Form_Control.chk_for_header_release ');
        END IF;

        return l_return;

    EXCEPTION

        WHEN NO_DATA_FOUND THEN

            oe_debug_pub.add('IN OE_Blanket_Form_Control.chk_for_header_release WHEN no_data_found');
            RETURN l_return;

        WHEN OTHERS THEN

            oe_debug_pub.add('IN OE_Blanket_Form_Control.chk_for_header_release WHEN OTEHRS');
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'chk_for_header_release'
                );
            END IF;
            RETURN l_return;

    end chk_for_header_release;

----------------------------------------------------------
     FUNCTION chk_for_line_release
----------------------------------------------------------
    (p_blanket_number   IN number,
     p_blanket_line_number in number)
    RETURN varchar2
    IS
    l_return    varchar2(10):= 'FLASE';
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    Begin

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'IN OE_Blanket_Form_Control.chk_for_line_release '||p_blanket_number);
        END IF;

        if p_blanket_number is not null then

               SELECT 'TRUE'
               INTO  l_return
               FROM oe_order_lines
               WHERE blanket_number = p_blanket_number
               AND BLANKET_LINE_NUMBER = p_blanket_line_number
               AND rownum = 1;

         end if;

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'IN OE_Blanket_Form_Control.chk_for_line_release ');
        END IF;

        return l_return;

    EXCEPTION

        WHEN NO_DATA_FOUND THEN

            oe_debug_pub.add(  'IN OE_Blanket_Form_Control.chk_for_line_release WHEN no_data_found');
            RETURN l_return;

        WHEN OTHERS THEN

            oe_debug_pub.add(  'IN OE_Blanket_Form_Control.chk_for_line_release WHEN OTEHRS');
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'chk_for_header_release'
                );
            END IF;
            RETURN l_return;

    end chk_for_line_release;

----------------------------------------------------------
    PROCEDURE Set_Include_All_Revisions(p_value IN VARCHAR2)
----------------------------------------------------------
    IS
    BEGIN

      G_INCLUDE_ALL_REVISIONS := p_value;

    END Set_Include_All_Revisions;

----------------------------------------------------------
    FUNCTION INCLUDE_ALL_REVISIONS
----------------------------------------------------------
    RETURN varchar2
    IS
    BEGIN

      RETURN G_INCLUDE_ALL_REVISIONS;

    END INCLUDE_ALL_REVISIONS;

----------------------------------------------------------
     FUNCTION chk_active_revision
----------------------------------------------------------
    (p_blanket_number   IN number,
     p_version_number   IN number)
    RETURN varchar2
    IS
    l_return    varchar2(10):= 'FLASE';
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    Begin

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'IN OE_Blanket_Form_Control.chk_active_revision '||p_blanket_number);
        END IF;

        if p_blanket_number is not null then

               SELECT 'TRUE'
               INTO  l_return
               FROM  oe_blanket_headers_all
               WHERE order_number     = p_blanket_number
               AND   version_number   = p_version_number
               AND   rownum           = 1;

         end if;

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'IN OE_Blanket_Form_Control.chk_active_revision ');
        END IF;

        return l_return;

    EXCEPTION

        WHEN NO_DATA_FOUND THEN

            oe_debug_pub.add('IN OE_Blanket_Form_Control.chk_active_revision WHEN no_data_found');
            RETURN l_return;

        WHEN OTHERS THEN

            oe_debug_pub.add('IN OE_Blanket_Form_Control.chk_active_revision WHEN OTEHRS');
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'chk_active_revision'
                );
            END IF;
            RETURN l_return;

    end chk_active_revision;

-- This procedure will be called from the client when the user
-- clears a record
Procedure Clear_Record
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   block_name                     IN  VARCHAR2
)
IS
l_return_status                     Varchar2(30);
BEGIN
-- hashraf ... start of pack J
     OE_MSG_PUB.initialize;
 	x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Clear the controller cache
--	Clear_Header;

     if block_name in ('BLANKET_HEADER') then

       g_header_cache_rec.delete;

     elsif block_name in ('BLANKET_LINE') then
       g_line_cache_rec.delete;

     end if;

EXCEPTION
    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Clear_Record'
            );
        END IF;
        --  Get message count and data
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_ERROR;

END Clear_Record;

----------------------------------------------------------
     FUNCTION get_trxt_phase_from_order_type
----------------------------------------------------------
    (p_order_type_id   IN number)
    RETURN varchar2
    IS
    l_return    varchar2(10);
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    Begin

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('IN OE_Blanket_Form_Control.get_trxt_phase_from_order_type '||p_order_type_id);
        END IF;

        if p_order_type_id is not null then

            begin

               SELECT DEF_TRANSACTION_PHASE_CODE
               INTO  l_return
               FROM oe_transaction_types_all
               WHERE TRANSACTION_TYPE_ID = p_order_type_id;
            EXCEPTION

               WHEN NO_DATA_FOUND THEN
                    oe_debug_pub.add('IN OE_Blanket_Form_Control.get_trxt_phas WHEN no_data_found');
                    RETURN l_return;
            end;

        end if;

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add('IN OE_Blanket_Form_Control.get_trxt_phase_from_order_type ');
        END IF;

        return l_return;

    EXCEPTION

        WHEN NO_DATA_FOUND THEN

            oe_debug_pub.add('IN OE_Blanket_Form_Control.chk_for_Submit_Draft_flag WHEN no_data_found');
            RETURN l_return;

        WHEN OTHERS THEN

            oe_debug_pub.add('IN OE_Blanket_Form_Control.chk_for_header_release WHEN OTEHRS');
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'get_trxt_phase_from_order_type'
                );
            END IF;
            RETURN l_return;

    end get_trxt_phase_from_order_type;

END OE_Blanket_Form_Control;

/
