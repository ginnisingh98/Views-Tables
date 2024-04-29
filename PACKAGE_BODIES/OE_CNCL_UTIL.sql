--------------------------------------------------------
--  DDL for Package Body OE_CNCL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CNCL_UTIL" AS
/* $Header: OEXVCGIB.pls 120.3 2008/01/10 12:41:56 sgoli ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_CNCL_Util';


PROCEDURE Get_Header_Ids
(   p_x_header_rec                  IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   p_header_val_rec                IN  OE_Order_PUB.Header_Val_Rec_Type
)
IS
l_sold_to_org_id               NUMBER;
l_ship_to_org_id               NUMBER;
l_invoice_to_org_id            NUMBER;
l_deliver_to_org_id            NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
-- aksingh start on 08/07/2000
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_CNCL_UTIL.GET_HEADER_IDS' , 1 ) ;
    END IF;


    IF  p_header_val_rec.accounting_rule <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.accounting_rule_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','accounting_rule');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.accounting_rule_id :=
		      OE_CNCL_Value_To_Id.accounting_rule
            (   p_accounting_rule     => p_header_val_rec.accounting_rule
            );

            IF p_x_header_rec.accounting_rule_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.agreement <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.agreement_id <> FND_API.G_MISS_NUM THEN



            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','agreement');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.agreement_id := OE_CNCL_Value_To_Id.agreement
            (   p_agreement             => p_header_val_rec.agreement
            );

            IF p_x_header_rec.agreement_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.conversion_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.conversion_type_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','conversion_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.conversion_type_code :=
			 OE_CNCL_Value_To_Id.conversion_type
            (   p_conversion_type      => p_header_val_rec.conversion_type
            );

            IF p_x_header_rec.conversion_type_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.fob_point <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.fob_point_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','fob_point');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.fob_point_code := OE_CNCL_Value_To_Id.fob_point
            (   p_fob_point               => p_header_val_rec.fob_point
            );

            IF p_x_header_rec.fob_point_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.freight_terms <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.freight_terms_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_terms');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.freight_terms_code :=
			 OE_CNCL_Value_To_Id.freight_terms
            (   p_freight_terms               => p_header_val_rec.freight_terms
            );

            IF p_x_header_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.shipping_method <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.shipping_method_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','shipping_method');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.shipping_method_code := OE_CNCL_Value_To_Id.ship_method
            (   p_ship_method           => p_header_val_rec.shipping_method
            );

            IF p_x_header_rec.shipping_method_code = FND_API.G_MISS_CHAR THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'SHIP METHOD CONVERSION ERROR' ) ;
            END IF;
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    IF  p_header_val_rec.freight_carrier <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.freight_carrier_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_carrier');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.freight_carrier_code :=
                OE_CNCL_Value_To_Id.freight_carrier
            (   p_freight_carrier      => p_header_val_rec.freight_carrier
		  ,   p_ship_from_org_id	    => p_x_header_rec.ship_from_org_id
            );

            IF p_x_header_rec.freight_carrier_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.invoicing_rule <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.invoicing_rule_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoicing_rule');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.invoicing_rule_id :=
                OE_CNCL_Value_To_Id.invoicing_rule
            (   p_invoicing_rule        => p_header_val_rec.invoicing_rule
            );

            IF p_x_header_rec.invoicing_rule_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.order_source <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.order_source_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','order_source');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.order_source_id := OE_CNCL_Value_To_Id.order_source
            (   p_order_source                => p_header_val_rec.order_source
            );

            IF p_x_header_rec.order_source_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.order_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.order_type_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','order_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.order_type_id := OE_CNCL_Value_To_Id.order_type
            (   p_order_type             => p_header_val_rec.order_type
            );

            IF p_x_header_rec.order_type_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.payment_term <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.payment_term_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','payment_term');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.payment_term_id := OE_CNCL_Value_To_Id.payment_term
            (   p_payment_term             => p_header_val_rec.payment_term
            );

            IF p_x_header_rec.payment_term_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.price_list <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.price_list_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.price_list_id := OE_CNCL_Value_To_Id.price_list
            (   p_price_list             => p_header_val_rec.price_list
            );

            IF p_x_header_rec.price_list_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.return_reason <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.return_reason_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','return_reason');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.return_reason_code :=
                OE_CNCL_Value_To_Id.return_reason
            (   p_return_reason  => p_header_val_rec.return_reason
            );

	 IF p_x_header_rec.return_reason_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.salesrep <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.salesrep_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','salesrep');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.salesrep_id := OE_CNCL_Value_To_Id.salesrep
            (   p_salesrep  => p_header_val_rec.salesrep
            );
            IF p_x_header_rec.salesrep_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    IF  p_header_val_rec.sales_channel <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.sales_channel_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sales_channel');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.sales_channel_code :=
                OE_CNCL_Value_To_Id.sales_channel
            (   p_sales_channel  => p_header_val_rec.sales_channel
            );
            IF p_x_header_rec.sales_channel_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    IF  p_header_val_rec.shipment_priority <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.shipment_priority_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','shipment_priority');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.shipment_priority_code :=
                OE_CNCL_Value_To_Id.shipment_priority
            (   p_shipment_priority   => p_header_val_rec.shipment_priority
            );

            IF p_x_header_rec.shipment_priority_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

-- aksingh This code is not yet build in the value_to_id procedure, I have to
-- write it to make it work
    IF  p_header_val_rec.ship_from_address1 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.ship_from_address2 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.ship_from_address3 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.ship_from_address4 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.ship_from_location <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.ship_from_org <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.ship_from_org_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_from_org');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.ship_from_org_id := OE_CNCL_Value_To_Id.ship_from_org
            (   p_ship_from_address1   => p_header_val_rec.ship_from_address1
            ,   p_ship_from_address2   => p_header_val_rec.ship_from_address2
            ,   p_ship_from_address3   => p_header_val_rec.ship_from_address3
            ,   p_ship_from_address4   => p_header_val_rec.ship_from_address4
            ,   p_ship_from_location   => p_header_val_rec.ship_from_location
            ,   p_ship_from_org        => p_header_val_rec.ship_from_org
            );

            IF p_x_header_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.tax_exempt <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.tax_exempt_flag <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','tax_exempt');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.tax_exempt_flag := OE_CNCL_Value_To_Id.tax_exempt
            (   p_tax_exempt          => p_header_val_rec.tax_exempt
            );

            IF p_x_header_rec.tax_exempt_flag = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.tax_exempt_reason <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.tax_exempt_reason_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','tax_exempt_reason');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.tax_exempt_reason_code :=
                OE_CNCL_Value_To_Id.tax_exempt_reason
            (   p_tax_exempt_reason      => p_header_val_rec.tax_exempt_reason
            );

            IF p_x_header_rec.tax_exempt_reason_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.tax_point <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.tax_point_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','tax_point');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.tax_point_code := OE_CNCL_Value_To_Id.tax_point
            (   p_tax_point                   => p_header_val_rec.tax_point
            );

            IF p_x_header_rec.tax_point_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.payment_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.payment_type_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','payment_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.payment_type_code :=
			 OE_CNCL_Value_To_Id.payment_type
            (   p_payment_type               => p_header_val_rec.payment_type
            );

            IF p_x_header_rec.payment_type_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.credit_card <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.credit_card_code <> FND_API.G_MISS_CHAR THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','credit_card');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.credit_card_code := OE_CNCL_Value_To_Id.credit_card
            (   p_credit_card               => p_header_val_rec.credit_card
            );

            IF p_x_header_rec.credit_card_code = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    ----------------------------------------------------------------------
    -- For customer related fields, IDs should be retrieved in the
    -- following order.
    ----------------------------------------------------------------------

    IF  p_header_val_rec.sold_to_org <> FND_API.G_MISS_CHAR
    OR  p_header_val_rec.customer_number <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.sold_to_org_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sold_to_org');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.sold_to_org_id := OE_CNCL_Value_To_Id.sold_to_org
            (   p_sold_to_org                 => p_header_val_rec.sold_to_org
		  ,   p_customer_number             => p_header_val_rec.customer_number
            );

            IF p_x_header_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    -- Below IF is not required for CNCL but not removing for now.
    -- Retrieve the sold_to_org_id if not passed on the header record. This
    -- will be needed by the value_to_id functions for related fields.
    -- For e.g. oe_value_to_id.ship_to_org_id requires sold_to_org_id

    IF p_x_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE
	  AND  p_x_header_rec.sold_to_org_id = FND_API.G_MISS_NUM
    THEN

	  SELECT SOLD_TO_ORG_ID
	  INTO l_sold_to_org_id
	  FROM OE_ORDER_HEADERS
	  WHERE HEADER_ID = p_x_header_rec.header_id;

    ELSE

	  l_sold_to_org_id := p_x_header_rec.sold_to_org_id;

    END IF;

    IF  p_header_val_rec.sold_to_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.sold_to_contact_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sold_to_contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.sold_to_contact_id :=
                OE_CNCL_Value_To_Id.sold_to_contact
            (   p_sold_to_contact       => p_header_val_rec.sold_to_contact
		  ,   p_sold_to_org_id        => l_sold_to_org_id
            );

            IF p_x_header_rec.sold_to_contact_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF p_header_val_rec.deliver_to_address1 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.deliver_to_address2 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.deliver_to_address3 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.deliver_to_address4 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.deliver_to_location <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.deliver_to_org <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.deliver_to_org_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','deliver_to_org');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
/*1621182*/
            p_x_header_rec.deliver_to_org_id :=
                OE_CNCL_Value_To_Id.deliver_to_org
            (   p_deliver_to_address1       => p_header_val_rec.deliver_to_address1
            ,   p_deliver_to_address2       => p_header_val_rec.deliver_to_address2
            ,   p_deliver_to_address3       => p_header_val_rec.deliver_to_address3
            ,   p_deliver_to_address4       => p_header_val_rec.deliver_to_address4
            ,   p_deliver_to_location       => p_header_val_rec.deliver_to_location
            ,   p_deliver_to_org            => p_header_val_rec.deliver_to_org
            ,   p_deliver_to_city           => p_header_val_rec.deliver_to_city
            ,   p_deliver_to_state          => p_header_val_rec.deliver_to_state
            ,   p_deliver_to_postal_code    => p_header_val_rec.deliver_to_zip
            ,   p_deliver_to_country        => p_header_val_rec.deliver_to_country
		  ,   p_sold_to_org_id      => l_sold_to_org_id
            );
/*1621182*/

            IF p_x_header_rec.deliver_to_org_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF p_header_val_rec.invoice_to_address1 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.invoice_to_address2 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.invoice_to_address3 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.invoice_to_address4 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.invoice_to_location <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.invoice_to_org <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.invoice_to_org_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_to_org');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
/*1621182*/
            p_x_header_rec.invoice_to_org_id :=
                OE_CNCL_Value_To_Id.invoice_to_org
            (   p_invoice_to_address1     => p_header_val_rec.invoice_to_address1
            ,   p_invoice_to_address2     => p_header_val_rec.invoice_to_address2
            ,   p_invoice_to_address3     => p_header_val_rec.invoice_to_address3
            ,   p_invoice_to_address4     => p_header_val_rec.invoice_to_address4
            ,   p_invoice_to_location     => p_header_val_rec.invoice_to_location
            ,   p_invoice_to_org          => p_header_val_rec.invoice_to_org
            ,   p_invoice_to_city         => p_header_val_rec.invoice_to_city
            ,   p_invoice_to_state        => p_header_val_rec.invoice_to_state
            ,   p_invoice_to_postal_code  => p_header_val_rec.invoice_to_zip
            ,   p_invoice_to_country      => p_header_val_rec.invoice_to_country
		  ,   p_sold_to_org_id    => l_sold_to_org_id
            );
/*1621182*/

            IF p_x_header_rec.invoice_to_org_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF p_header_val_rec.ship_to_address1 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.ship_to_address2 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.ship_to_address3 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.ship_to_address4 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.ship_to_location <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.ship_to_org <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.ship_to_org_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_to_org');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
/*1621182*/
            p_x_header_rec.ship_to_org_id := OE_CNCL_Value_To_Id.ship_to_org
            (   p_ship_to_address1      => p_header_val_rec.ship_to_address1
            ,   p_ship_to_address2      => p_header_val_rec.ship_to_address2
            ,   p_ship_to_address3      => p_header_val_rec.ship_to_address3
            ,   p_ship_to_address4      => p_header_val_rec.ship_to_address4
            ,   p_ship_to_location      => p_header_val_rec.ship_to_location
            ,   p_ship_to_org           => p_header_val_rec.ship_to_org
            ,   p_ship_to_city          => p_header_val_rec.ship_to_city
            ,   p_ship_to_state         => p_header_val_rec.ship_to_state
            ,   p_ship_to_postal_code   => p_header_val_rec.ship_to_zip
            ,   p_ship_to_country       => p_header_val_rec.ship_to_country
		  ,   p_sold_to_org_id  => l_sold_to_org_id
            );

/*1621182*/
            IF p_x_header_rec.ship_to_org_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF p_header_val_rec.sold_to_location_address1 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.sold_to_location_address2 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.sold_to_location_address3 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.sold_to_location_address4 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.sold_to_location          <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.sold_to_site_use_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sold_to_site_use_id');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
            p_x_header_rec.sold_to_site_use_id := OE_CNCL_Value_To_Id.Customer_Location
            (   p_sold_to_location_address1      => p_header_val_rec.sold_to_location_address1
            ,   p_sold_to_location_address2      => p_header_val_rec.sold_to_location_address2
            ,   p_sold_to_location_address3      => p_header_val_rec.sold_to_location_address3
            ,   p_sold_to_location_address4      => p_header_val_rec.sold_to_location_address4
            ,   p_sold_to_location               => p_header_val_rec.sold_to_location
            ,   p_sold_to_location_city          => p_header_val_rec.sold_to_location_city
            ,   p_sold_to_location_state         => p_header_val_rec.sold_to_location_state
            ,   p_sold_to_location_postal        => p_header_val_rec.sold_to_location_postal
            ,   p_sold_to_location_country       => p_header_val_rec.sold_to_location_country
	    ,   p_sold_to_org_id                 => l_sold_to_org_id
            );

            IF p_x_header_rec.sold_to_site_use_id = FND_API.G_MISS_NUM THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  ' customer location error ') ;
              END IF;
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    l_sold_to_org_id := p_x_header_rec.sold_to_org_id;
    l_invoice_to_org_id := p_x_header_rec.invoice_to_org_id;
    l_deliver_to_org_id := p_x_header_rec.deliver_to_org_id;

    IF  p_header_val_rec.deliver_to_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.deliver_to_contact_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','deliver_to_contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.deliver_to_contact_id :=
			 OE_CNCL_Value_To_Id.deliver_to_contact
            (   p_deliver_to_contact  => p_header_val_rec.deliver_to_contact
		  ,   p_deliver_to_org_id   => l_deliver_to_org_id
            );

            IF p_x_header_rec.deliver_to_contact_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.invoice_to_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.invoice_to_contact_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_to_contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.invoice_to_contact_id :=
                OE_CNCL_Value_To_Id.invoice_to_contact
            (   p_invoice_to_contact  => p_header_val_rec.invoice_to_contact
		  ,   p_invoice_to_org_id   => l_invoice_to_org_id
            );

            IF p_x_header_rec.invoice_to_contact_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.ship_to_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.ship_to_contact_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_to_contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.ship_to_contact_id :=
                OE_CNCL_Value_To_Id.ship_to_contact
            (   p_ship_to_contact  => p_header_val_rec.ship_to_contact
		  ,   p_ship_to_org_id   => l_ship_to_org_id
            );

            IF p_x_header_rec.ship_to_contact_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    --{ added for bug 4240715
    IF  p_header_val_rec.end_customer_name <> FND_API.G_MISS_CHAR
    OR  p_header_val_rec.end_customer_number <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.end_customer_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_customer');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
              oe_Debug_pub.add('attribute procedure');
            p_x_header_rec.end_customer_id:=OE_Value_To_Id.end_customer
            ( p_end_customer       => p_header_val_rec.end_customer_name
             ,p_end_customer_number=> p_header_val_rec.end_customer_number
              );

            IF p_x_header_rec.end_customer_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.end_customer_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_header_rec.end_customer_id <>FND_API.G_MISS_NUM and
                p_x_header_rec.end_customer_contact_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_customer_contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
                oe_debug_pub.add('before calling aend customer contact value to id');
            p_x_header_rec.end_customer_contact_id := OE_Value_To_Id.end_customer_contact
            (   p_end_customer_contact             => p_header_val_rec.end_customer_contact
		  ,p_end_customer_id              =>p_x_header_rec.end_customer_id
            );
	    oe_debug_pub.add('End customer contact id is '||p_x_header_rec.end_customer_contact_id);

            IF p_x_header_rec.end_customer_contact_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

  IF (p_header_val_rec.end_customer_name <> FND_API.G_MISS_CHAR
      OR p_header_val_rec.end_customer_number <> FND_API.G_MISS_CHAR)
	 AND
     (p_header_val_rec.end_customer_site_address1 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.end_customer_site_address2 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.end_customer_site_address3 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.end_customer_site_address4 <> FND_API.G_MISS_CHAR
    OR p_header_val_rec.end_customer_site_location          <> FND_API.G_MISS_CHAR)

    THEN

        IF p_x_header_rec.end_customer_site_use_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_customer_Location');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
	   oe_debug_pub.add('Before calling End custoemr site use value to id');
            p_x_header_rec.end_customer_site_use_id := OE_Value_To_Id.end_customer_site
            (   p_end_customer_site_address1            => p_header_val_rec.end_customer_site_address1
            ,   p_end_customer_site_address2            => p_header_val_rec.end_customer_site_address2
            ,   p_end_customer_site_address3            => p_header_val_rec.end_customer_site_address3
            ,   p_end_customer_site_address4            => p_header_val_rec.end_customer_site_address4
            ,   p_end_customer_site_location                     => p_header_val_rec.end_customer_site_location
	    ,   p_end_customer_site_org                       => NULL
		,   p_end_customer_id                         => p_x_header_rec.end_customer_id
            ,   p_end_customer_site_city                => p_header_val_rec.end_customer_site_city
            ,   p_end_customer_site_state               => p_header_val_rec.end_customer_site_state
            ,   p_end_customer_site_postalcode         => p_header_val_rec.end_customer_site_postal_code
            ,   p_end_customer_site_country             => p_header_val_rec.end_customer_site_country
            ,   p_end_customer_site_use_code           => NULL
            );


    oe_debug_pub.add('after hdr sold_to_site_use_id='||p_x_header_rec.end_customer_site_use_id);

            IF p_x_header_rec.end_customer_site_use_id = FND_API.G_MISS_NUM THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.ib_owner_dsp <> FND_API.G_MISS_CHAR
    THEN
        IF p_x_header_rec.ib_owner <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','IB_Owner');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.ib_owner:=OE_Value_To_Id.ib_owner
            ( p_ib_owner       => p_header_val_rec.ib_owner_dsp
              );

            IF p_x_header_rec.ib_owner = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_header_val_rec.ib_installed_at_location_dsp <> FND_API.G_MISS_CHAR
    THEN
        IF p_x_header_rec.ib_installed_at_location <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','IB_Installed_at_location');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.ib_installed_at_location:=OE_Value_To_Id.ib_installed_at_location
            ( p_ib_installed_at_location       => p_header_val_rec.ib_installed_at_location_dsp
              );

            IF p_x_header_rec.ib_installed_at_location = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

     IF  p_header_val_rec.ib_current_location_dsp <> FND_API.G_MISS_CHAR
    THEN
        IF p_x_header_rec.ib_current_location <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','IB_current_location');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_header_rec.ib_current_location:=OE_Value_To_Id.ib_current_location
            ( p_ib_current_location       => p_header_val_rec.ib_current_location_dsp
              );

            IF p_x_header_rec.ib_current_location = FND_API.G_MISS_CHAR THEN
                p_x_header_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

	--bug 4240715}

    ----------------------------------------------------------------------
    -- End of get IDs for customer related fields
    ----------------------------------------------------------------------

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_CNCL_UTIL.GET_HEADER_IDS' , 1 ) ;
    END IF;

END Get_Header_Ids;


PROCEDURE Get_Line_Ids
(   p_x_line_rec                    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
,   p_line_val_rec                  IN  OE_Order_PUB.Line_Val_Rec_Type
)
IS
l_sold_to_org_id           NUMBER;
l_deliver_to_org_id        NUMBER;
l_invoice_to_org_id        NUMBER;
l_ship_to_org_id           NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    p_x_line_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    IF  p_line_val_rec.accounting_rule <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.accounting_rule_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','accounting_rule');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.accounting_rule_id :=
                OE_CNCL_Value_To_Id.accounting_rule
            (   p_accounting_rule  => p_line_val_rec.accounting_rule
            );

            IF p_x_line_rec.accounting_rule_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.agreement <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.agreement_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','agreement');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.agreement_id := OE_CNCL_Value_To_Id.agreement
            (   p_agreement     => p_line_val_rec.agreement
            );

            IF p_x_line_rec.agreement_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.demand_bucket_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.demand_bucket_type_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','demand_bucket_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.demand_bucket_type_code :=
                OE_CNCL_Value_To_Id.demand_bucket_type
            (   p_demand_bucket_type   => p_line_val_rec.demand_bucket_type
            );

            IF p_x_line_rec.demand_bucket_type_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.fob_point <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.fob_point_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','fob_point');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.fob_point_code := OE_CNCL_Value_To_Id.fob_point
            (   p_fob_point         => p_line_val_rec.fob_point
            );

            IF p_x_line_rec.fob_point_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.freight_terms <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.freight_terms_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_terms');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.freight_terms_code :=
                OE_CNCL_Value_To_Id.freight_terms
            (   p_freight_terms    => p_line_val_rec.freight_terms
            );

            IF p_x_line_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.shipping_method <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.shipping_method_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','shipping_method');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.shipping_method_code :=
                OE_CNCL_Value_To_Id.ship_method
            (   p_ship_method    => p_line_val_rec.shipping_method
            );

            IF p_x_line_rec.shipping_method_code = FND_API.G_MISS_CHAR THEN
		  IF l_debug_level  > 0 THEN
		      oe_debug_pub.add(  'SHIP METHOD CONVERSION ERROR' ) ;
		  END IF;
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    IF  p_line_val_rec.freight_carrier <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.freight_carrier_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','freight_carrier');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.freight_carrier_code :=
                OE_CNCL_Value_To_Id.freight_carrier
            (   p_freight_carrier    => p_line_val_rec.freight_carrier
		  ,   p_ship_from_org_id	  => p_x_line_rec.ship_from_org_id
            );

            IF p_x_line_rec.freight_carrier_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.intermed_ship_to_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.intermed_ship_to_contact_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','intermed_ship_to_contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.intermed_ship_to_contact_id :=
                OE_CNCL_Value_To_Id.intermed_ship_to_contact
            (   p_intermed_ship_to_contact => p_line_val_rec.intermed_ship_to_contact
		  ,   p_intermed_ship_to_org_id  => p_x_line_rec.intermed_ship_to_org_id
            );

            IF p_x_line_rec.intermed_ship_to_contact_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.intermed_ship_to_address1 <> FND_API.G_MISS_CHAR
    OR  p_line_val_rec.intermed_ship_to_address2 <> FND_API.G_MISS_CHAR
    OR  p_line_val_rec.intermed_ship_to_address3 <> FND_API.G_MISS_CHAR
    OR  p_line_val_rec.intermed_ship_to_address4 <> FND_API.G_MISS_CHAR
    OR  p_line_val_rec.intermed_ship_to_location <> FND_API.G_MISS_CHAR
    OR  p_line_val_rec.intermed_ship_to_org <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.intermed_ship_to_org_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','intermed_ship_to_org');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
/*1621182*/
            p_x_line_rec.intermed_ship_to_org_id := OE_CNCL_Value_To_Id.intermed_ship_to_org
            (   p_intermed_ship_to_address1     => p_line_val_rec.intermed_ship_to_address1
            ,   p_intermed_ship_to_address2     => p_line_val_rec.intermed_ship_to_address2
            ,   p_intermed_ship_to_address3     => p_line_val_rec.intermed_ship_to_address3
            ,   p_intermed_ship_to_address4     => p_line_val_rec.intermed_ship_to_address4
            ,   p_intermed_ship_to_location     => p_line_val_rec.intermed_ship_to_location
            ,   p_intermed_ship_to_org          => p_line_val_rec.intermed_ship_to_org
            ,   p_intermed_ship_to_city         => p_line_val_rec.intermed_ship_to_city
            ,   p_intermed_ship_to_state        => p_line_val_rec.intermed_ship_to_state
            ,   p_intermed_ship_to_postal_code  => p_line_val_rec.intermed_ship_to_zip
            ,   p_intermed_ship_to_country      => p_line_val_rec.intermed_ship_to_country
		  ,   p_sold_to_org_id          => p_x_line_rec.sold_to_org_id
            );
/*1621182*/

            IF p_x_line_rec.intermed_ship_to_org_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    IF  p_line_val_rec.inventory_item <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.inventory_item_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','inventory_item');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.inventory_item_id := OE_CNCL_Value_To_Id.inventory_item
            (   p_inventory_item      => p_line_val_rec.inventory_item
            );

            IF p_x_line_rec.inventory_item_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.invoicing_rule <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.invoicing_rule_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoicing_rule');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.invoicing_rule_id := OE_CNCL_Value_To_Id.invoicing_rule
            (   p_invoicing_rule           => p_line_val_rec.invoicing_rule
            );

            IF p_x_line_rec.invoicing_rule_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.item_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.item_type_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','item_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.item_type_code := OE_CNCL_Value_To_Id.item_type
            (   p_item_type                   => p_line_val_rec.item_type
            );

            IF p_x_line_rec.item_type_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.line_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.line_type_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','line_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.line_type_id := OE_CNCL_Value_To_Id.line_type
            (   p_line_type                   => p_line_val_rec.line_type
            );

            IF p_x_line_rec.line_type_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.over_ship_reason <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.over_ship_reason_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Over_shipo_reason');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.over_ship_reason_code :=
                OE_CNCL_Value_To_Id.over_ship_reason
            (   p_over_ship_reason  => p_line_val_rec.over_ship_reason
            );

            IF p_x_line_rec.over_ship_reason_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.payment_term <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.payment_term_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','payment_term');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.payment_term_id :=
                OE_CNCL_Value_To_Id.payment_term
            (   p_payment_term                => p_line_val_rec.payment_term
            );

            IF p_x_line_rec.payment_term_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.price_list <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.price_list_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.price_list_id := OE_CNCL_Value_To_Id.price_list
            (   p_price_list                  => p_line_val_rec.price_list
            );

            IF p_x_line_rec.price_list_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.project <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.project_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','project');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.project_id := OE_CNCL_Value_To_Id.project
            (   p_project                     => p_line_val_rec.project
            );

            IF p_x_line_rec.project_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.return_reason <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.return_reason_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','return_reason');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.return_reason_code := OE_CNCL_Value_To_Id.return_reason
            (   p_return_reason  => p_line_val_rec.return_reason
            );

            IF p_x_line_rec.return_reason_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;



    IF  p_line_val_rec.rla_schedule_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.rla_schedule_type_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','rla_schedule_type');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.rla_schedule_type_code :=
                OE_CNCL_Value_To_Id.rla_schedule_type
            (   p_rla_schedule_type    => p_line_val_rec.rla_schedule_type
            );

            IF p_x_line_rec.rla_schedule_type_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.salesrep <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.salesrep_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','salesrep');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.salesrep_id := OE_CNCL_Value_To_Id.salesrep
            (   p_salesrep  => p_line_val_rec.salesrep
            );

            IF p_x_line_rec.salesrep_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.shipment_priority <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.shipment_priority_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','shipment_priority');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.shipment_priority_code :=
                OE_CNCL_Value_To_Id.shipment_priority
            (   p_shipment_priority  => p_line_val_rec.shipment_priority
            );

            IF p_x_line_rec.shipment_priority_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.ship_from_address1 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.ship_from_address2 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.ship_from_address3 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.ship_from_address4 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.ship_from_location <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.ship_from_org <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.ship_from_org_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_from_org');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.ship_from_org_id := OE_CNCL_Value_To_Id.ship_from_org
            (   p_ship_from_address1  => p_line_val_rec.ship_from_address1
            ,   p_ship_from_address2  => p_line_val_rec.ship_from_address2
            ,   p_ship_from_address3  => p_line_val_rec.ship_from_address3
            ,   p_ship_from_address4  => p_line_val_rec.ship_from_address4
            ,   p_ship_from_location  => p_line_val_rec.ship_from_location
            ,   p_ship_from_org       => p_line_val_rec.ship_from_org
            );

            IF p_x_line_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.task <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.task_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','task');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.task_id := OE_CNCL_Value_To_Id.task
            (   p_task           => p_line_val_rec.task
            );

            IF p_x_line_rec.task_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.tax_exempt <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.tax_exempt_flag <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','tax_exempt');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.tax_exempt_flag := OE_CNCL_Value_To_Id.tax_exempt
            (   p_tax_exempt                  => p_line_val_rec.tax_exempt
            );

            IF p_x_line_rec.tax_exempt_flag = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.tax_exempt_reason <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.tax_exempt_reason_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','tax_exempt_reason');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.tax_exempt_reason_code :=
                OE_CNCL_Value_To_Id.tax_exempt_reason
            (   p_tax_exempt_reason   => p_line_val_rec.tax_exempt_reason
            );

            IF p_x_line_rec.tax_exempt_reason_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.tax_point <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.tax_point_code <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','tax_point');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.tax_point_code := OE_CNCL_Value_To_Id.tax_point
            (   p_tax_point                   => p_line_val_rec.tax_point
            );

            IF p_x_line_rec.tax_point_code = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    IF  p_line_val_rec.veh_cus_item_cum_key <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.veh_cus_item_cum_key_id <> FND_API.G_MISS_NUM THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','veh_cus_item_cum_key');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

       p_x_line_rec.veh_cus_item_cum_key_id :=
                OE_CNCL_Value_To_Id.veh_cus_item_cum_key
            (   p_veh_cus_item_cum_key  => p_line_val_rec.veh_cus_item_cum_key
            );

            IF p_x_line_rec.veh_cus_item_cum_key_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    -------------------------------------------------------------------
    -- For customer related fields, IDs should be retrieved in the
    -- following order.
    -------------------------------------------------------------------

    -- Retrieve the sold_to_org_id if not passed on the line record. This
    -- will be needed by the value_to_id functions for related fields.
    -- For e.g. oe_value_to_id.ship_to_org_id requires sold_to_org_id

    IF  p_x_line_rec.sold_to_org_id = FND_API.G_MISS_NUM
    THEN

      IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

	   SELECT SOLD_TO_ORG_ID
	   INTO l_sold_to_org_id
	   FROM OE_ORDER_HEADERS
	   WHERE HEADER_ID = p_x_line_rec.header_id;

      ELSIF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

	   SELECT SOLD_TO_ORG_ID
	   INTO l_sold_to_org_id
	   FROM OE_ORDER_LINES
	   WHERE LINE_ID = p_x_line_rec.line_id;

      END IF;

    ELSE

	  l_sold_to_org_id := p_x_line_rec.sold_to_org_id;

    END IF;

    IF  p_line_val_rec.deliver_to_address1 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.deliver_to_address2 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.deliver_to_address3 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.deliver_to_address4 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.deliver_to_location <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.deliver_to_org <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.deliver_to_org_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','deliver_to_org');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
/*1621182*/
            p_x_line_rec.deliver_to_org_id :=
                OE_CNCL_Value_To_Id.deliver_to_org
            (   p_deliver_to_address1     => p_line_val_rec.deliver_to_address1
            ,   p_deliver_to_address2     => p_line_val_rec.deliver_to_address2
            ,   p_deliver_to_address3     => p_line_val_rec.deliver_to_address3
            ,   p_deliver_to_address4     => p_line_val_rec.deliver_to_address4
            ,   p_deliver_to_location     => p_line_val_rec.deliver_to_location
            ,   p_deliver_to_org          => p_line_val_rec.deliver_to_org
            ,   p_deliver_to_city         => p_line_val_rec.deliver_to_city
            ,   p_deliver_to_state        => p_line_val_rec.deliver_to_state
            ,   p_deliver_to_postal_code  => p_line_val_rec.deliver_to_zip
            ,   p_deliver_to_country      => p_line_val_rec.deliver_to_country
		  ,   p_sold_to_org_id    => l_sold_to_org_id
            );

/*1621182*/
            IF p_x_line_rec.deliver_to_org_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.invoice_to_address1 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.invoice_to_address2 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.invoice_to_address3 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.invoice_to_address4 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.invoice_to_location <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.invoice_to_org <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.invoice_to_org_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_to_org');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
/*1621182*/
            p_x_line_rec.invoice_to_org_id :=
                OE_CNCL_Value_To_Id.invoice_to_org
            (   p_invoice_to_address1     => p_line_val_rec.invoice_to_address1
            ,   p_invoice_to_address2     => p_line_val_rec.invoice_to_address2
            ,   p_invoice_to_address3     => p_line_val_rec.invoice_to_address3
            ,   p_invoice_to_address4     => p_line_val_rec.invoice_to_address4
            ,   p_invoice_to_location     => p_line_val_rec.invoice_to_location
            ,   p_invoice_to_org          => p_line_val_rec.invoice_to_org
            ,   p_invoice_to_city         => p_line_val_rec.invoice_to_city
            ,   p_invoice_to_state        => p_line_val_rec.invoice_to_state
            ,   p_invoice_to_postal_code  => p_line_val_rec.invoice_to_zip
            ,   p_invoice_to_country      => p_line_val_rec.invoice_to_country
		  ,   p_sold_to_org_id    => l_sold_to_org_id
            );

/*1621182*/
            IF p_x_line_rec.invoice_to_org_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.ship_to_address1 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.ship_to_address2 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.ship_to_address3 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.ship_to_address4 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.ship_to_location <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.ship_to_org <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.ship_to_org_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_to_org');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

/*1621182*/
            p_x_line_rec.ship_to_org_id := OE_CNCL_Value_To_Id.ship_to_org
            (   p_ship_to_address1      => p_line_val_rec.ship_to_address1
            ,   p_ship_to_address2      => p_line_val_rec.ship_to_address2
            ,   p_ship_to_address3      => p_line_val_rec.ship_to_address3
            ,   p_ship_to_address4      => p_line_val_rec.ship_to_address4
            ,   p_ship_to_location      => p_line_val_rec.ship_to_location
            ,   p_ship_to_org           => p_line_val_rec.ship_to_org
            ,   p_ship_to_city          => p_line_val_rec.ship_to_city
            ,   p_ship_to_state         => p_line_val_rec.ship_to_state
            ,   p_ship_to_postal_code   => p_line_val_rec.ship_to_zip
            ,   p_ship_to_country       => p_line_val_rec.ship_to_country
		  ,   p_sold_to_org_id  => l_sold_to_org_id
            );
/*1621182*/

            IF p_x_line_rec.ship_to_org_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    -- Retrieve the org_ids if not passed on the line record. These
    -- IDs will be needed by the value_to_id functions for CONTACT fields.
    -- For e.g. oe_value_to_id.ship_to_contact_id requires ship_to_org_id

    IF p_x_line_rec.operation = OE_GLOBALS.G_OPR_UPDATE
	  AND ( p_x_line_rec.ship_to_org_id = FND_API.G_MISS_NUM
	       OR p_x_line_rec.invoice_to_org_id = FND_API.G_MISS_NUM
	       OR p_x_line_rec.deliver_to_org_id = FND_API.G_MISS_NUM )
    THEN

	  SELECT SHIP_TO_ORG_ID, INVOICE_TO_ORG_ID, DELIVER_TO_ORG_ID
	  INTO l_sold_to_org_id, l_invoice_to_org_id, l_deliver_to_org_id
	  FROM OE_ORDER_LINES
	  WHERE LINE_ID = p_x_line_rec.line_id;

	  IF p_x_line_rec.ship_to_org_id <> FND_API.G_MISS_NUM THEN
		l_ship_to_org_id := p_x_line_rec.ship_to_org_id;
       END IF;

	  IF p_x_line_rec.invoice_to_org_id <> FND_API.G_MISS_NUM THEN
		l_invoice_to_org_id := p_x_line_rec.invoice_to_org_id;
       END IF;

	  IF p_x_line_rec.deliver_to_org_id <> FND_API.G_MISS_NUM THEN
		l_deliver_to_org_id := p_x_line_rec.deliver_to_org_id;
       END IF;

    ELSE

	  l_sold_to_org_id := p_x_line_rec.sold_to_org_id;
	  l_invoice_to_org_id := p_x_line_rec.invoice_to_org_id;
	  l_deliver_to_org_id := p_x_line_rec.deliver_to_org_id;

    END IF;

    IF  p_line_val_rec.deliver_to_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.deliver_to_contact_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','deliver_to_contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.deliver_to_contact_id :=
                OE_CNCL_Value_To_Id.deliver_to_contact
            (   p_deliver_to_contact   => p_line_val_rec.deliver_to_contact
		  ,   p_deliver_to_org_id    => l_deliver_to_org_id
            );

            IF p_x_line_rec.deliver_to_contact_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.invoice_to_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.invoice_to_contact_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','invoice_to_contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.invoice_to_contact_id :=
                OE_CNCL_Value_To_Id.invoice_to_contact
            (   p_invoice_to_contact   => p_line_val_rec.invoice_to_contact
		  ,   p_invoice_to_org_id    => l_invoice_to_org_id
            );

            IF p_x_line_rec.invoice_to_contact_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.ship_to_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.ship_to_contact_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_to_contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.ship_to_contact_id :=
                OE_CNCL_Value_To_Id.ship_to_contact
            (   p_ship_to_contact             => p_line_val_rec.ship_to_contact
		  ,   p_ship_to_org_id              => l_ship_to_org_id
            );

            IF p_x_line_rec.ship_to_contact_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    --{added for bug 4240715

    oe_Debug_pub.add('In get line ids procedure');

    IF  p_line_val_rec.end_customer_name <> FND_API.G_MISS_CHAR
    OR  p_line_val_rec.end_customer_number <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.end_customer_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_customer');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.end_customer_id:=OE_Value_To_Id.end_customer
            ( p_end_customer       => p_line_val_rec.end_customer_name
             ,p_end_customer_number=> p_line_val_rec.end_customer_number
              );

	    oe_debug_pub.add('after gettting end customer id'||p_x_line_rec.end_customer_id);
            IF p_x_line_rec.end_customer_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.end_customer_contact <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_line_rec.end_customer_id <>FND_API.G_MISS_NUM and
                p_x_line_rec.end_customer_contact_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_customer_contact');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
                oe_debug_pub.add('before calling aend customer contact value to id');
            p_x_line_rec.end_customer_contact_id := OE_Value_To_Id.end_customer_contact
            (   p_end_customer_contact             => p_line_val_rec.end_customer_contact
		  ,p_end_customer_id              =>p_x_line_rec.end_customer_id
            );
	    oe_debug_pub.add('End customer contact id is '||p_x_line_rec.end_customer_contact_id);

            IF p_x_line_rec.end_customer_contact_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

  IF (p_line_val_rec.end_customer_name <> FND_API.G_MISS_CHAR
      OR p_line_val_rec.end_customer_number <> FND_API.G_MISS_CHAR)
	 AND
     (p_line_val_rec.end_customer_site_address1 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.end_customer_site_address2 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.end_customer_site_address3 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.end_customer_site_address4 <> FND_API.G_MISS_CHAR
    OR p_line_val_rec.end_customer_site_location          <> FND_API.G_MISS_CHAR)

    THEN

        IF p_x_line_rec.end_customer_site_use_id <> FND_API.G_MISS_NUM THEN


            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_customer_Location');
                OE_MSG_PUB.Add;

            END IF;

        ELSE
	   oe_debug_pub.add('Before calling End custoemr site use value to id');
            p_x_line_rec.end_customer_site_use_id := OE_Value_To_Id.end_customer_site
            (   p_end_customer_site_address1            => p_line_val_rec.end_customer_site_address1
            ,   p_end_customer_site_address2            => p_line_val_rec.end_customer_site_address2
            ,   p_end_customer_site_address3            => p_line_val_rec.end_customer_site_address3
            ,   p_end_customer_site_address4            => p_line_val_rec.end_customer_site_address4
            ,   p_end_customer_site_location                     => p_line_val_rec.end_customer_site_location
	    ,   p_end_customer_site_org                       => NULL
		,   p_end_customer_id                         => p_x_line_rec.end_customer_id
            ,   p_end_customer_site_city                => p_line_val_rec.end_customer_site_city
            ,   p_end_customer_site_state               => p_line_val_rec.end_customer_site_state
            ,   p_end_customer_site_postalcode         => p_line_val_rec.end_customer_site_postal_code
            ,   p_end_customer_site_country             => p_line_val_rec.end_customer_site_country
            ,   p_end_customer_site_use_code           => NULL
            );


    oe_debug_pub.add('after hdr sold_to_site_use_id='||p_x_line_rec.end_customer_site_use_id);

            IF p_x_line_rec.end_customer_site_use_id = FND_API.G_MISS_NUM THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    IF  p_line_val_rec.ib_owner_dsp <> FND_API.G_MISS_CHAR
    THEN
        IF p_x_line_rec.ib_owner <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','IB_Owner');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.ib_owner:=OE_Value_To_Id.ib_owner
            ( p_ib_owner       => p_line_val_rec.ib_owner_dsp
              );

            IF p_x_line_rec.ib_owner = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_line_val_rec.ib_installed_at_location_dsp <> FND_API.G_MISS_CHAR
    THEN
        IF p_x_line_rec.ib_installed_at_location <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','IB_Installed_at_location');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.ib_installed_at_location:=OE_Value_To_Id.ib_installed_at_location
            ( p_ib_installed_at_location       => p_line_val_rec.ib_installed_at_location_dsp
              );

            IF p_x_line_rec.ib_installed_at_location = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

     IF  p_line_val_rec.ib_current_location_dsp <> FND_API.G_MISS_CHAR
    THEN
        IF p_x_line_rec.ib_current_location <> FND_API.G_MISS_CHAR THEN

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','IB_current_location');
                OE_MSG_PUB.Add;

            END IF;

        ELSE

            p_x_line_rec.ib_current_location:=OE_Value_To_Id.ib_current_location
            ( p_ib_current_location       => p_line_val_rec.ib_current_location_dsp
              );

            IF p_x_line_rec.ib_current_location = FND_API.G_MISS_CHAR THEN
                p_x_line_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

	--bug 4240715}

    -------------------------------------------------------------------
    -- End of get IDs for customer related fields
    -------------------------------------------------------------------

END Get_Line_Ids;



--  Procedure Get_Header_Scredit_Ids

PROCEDURE Get_Header_Scredit_Ids
(   p_x_Header_Scredit_rec IN OUT NOCOPY  OE_Order_PUB.Header_Scredit_Rec_Type
,   p_Header_Scredit_val_rec        IN  OE_Order_PUB.Header_Scredit_Val_Rec_Type
)
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
-- aksingh working
    --  initialize  return_status.

    p_x_Header_Scredit_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  initialize l_Header_Scredit_rec.



    IF  p_Header_Scredit_val_rec.salesrep <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_Header_Scredit_rec.salesrep_id <> FND_API.G_MISS_NUM THEN



            IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','salesrep');
                oe_msg_pub.Add;

            END IF;

        ELSE

            p_x_Header_Scredit_rec.salesrep_id := OE_CNCL_Value_To_Id.salesrep
            (   p_salesrep       => p_Header_Scredit_val_rec.salesrep
            );

            IF p_x_Header_Scredit_rec.salesrep_id = FND_API.G_MISS_NUM THEN
               p_x_Header_Scredit_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Header_Scredit_val_rec.sales_credit_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_Header_Scredit_rec.sales_credit_type_id <> FND_API.G_MISS_NUM THEN


            IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sales_credit_type');
                oe_msg_pub.Add;

            END IF;

        ELSE

            p_x_Header_Scredit_rec.sales_credit_type_id :=
               OE_CNCL_Value_To_Id.sales_credit_type
            (  p_sales_credit_type => p_Header_Scredit_val_rec.sales_credit_type
            );

            IF p_x_Header_Scredit_rec.sales_credit_type_id = FND_API.G_MISS_NUM THEN
                p_x_Header_Scredit_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;




END Get_Header_Scredit_Ids;


PROCEDURE Get_Line_Scredit_Ids
(   p_x_Line_Scredit_rec              IN OUT NOCOPY OE_Order_PUB.Line_Scredit_Rec_Type
,   p_Line_Scredit_val_rec          IN  OE_Order_PUB.Line_Scredit_Val_Rec_Type
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    --  initialize  return_status.

    p_x_Line_Scredit_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    IF  p_Line_Scredit_val_rec.salesrep <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_Line_Scredit_rec.salesrep_id <> FND_API.G_MISS_NUM THEN

            IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','salesrep');
                oe_msg_pub.Add;

            END IF;

        ELSE

            p_x_Line_Scredit_rec.salesrep_id := OE_CNCL_Value_To_Id.salesrep
            (   p_salesrep                   => p_Line_Scredit_val_rec.salesrep
            );

            IF p_x_Line_Scredit_rec.salesrep_id = FND_API.G_MISS_NUM THEN
                p_x_Line_Scredit_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

    IF  p_Line_Scredit_val_rec.sales_credit_type <> FND_API.G_MISS_CHAR
    THEN

        IF p_x_Line_Scredit_rec.sales_credit_type_id <> FND_API.G_MISS_NUM THEN

            IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
            THEN

                FND_MESSAGE.SET_NAME('ONT','OE_BOTH_VAL_AND_ID_EXIST');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sales_credit_type');
                oe_msg_pub.Add;

            END IF;

        ELSE

            p_x_Line_Scredit_rec.sales_credit_type_id :=
                OE_CNCL_Value_To_Id.sales_credit_type
            (   p_sales_credit_type => p_Line_Scredit_val_rec.sales_credit_type
            );

            IF p_x_Line_Scredit_rec.sales_credit_type_id = FND_API.G_MISS_NUM THEN
                p_x_Line_Scredit_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;
	END IF;

END Get_Line_Scredit_Ids;







PROCEDURE Get_Header_Adj_Ids
(   p_x_Header_Adj_rec              IN OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type
,   p_Header_Adj_val_rec            IN  OE_Order_PUB.Header_Adj_Val_Rec_Type
)
IS
l_Header_Adj_rec              OE_Order_PUB.Header_Adj_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
-- aksingh completed modification
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

            l_Header_Adj_rec.discount_id := OE_CNCL_Value_To_Id.discount
            (   p_discount         => p_Header_Adj_val_rec.discount
            );

            IF l_Header_Adj_rec.discount_id = FND_API.G_MISS_NUM THEN
                l_Header_Adj_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;

  --  RETURN l_Header_Adj_rec;
    p_x_Header_Adj_rec := l_Header_Adj_rec;

END Get_Header_Adj_Ids;


PROCEDURE Get_Line_Adj_Ids
(   p_x_Line_Adj_rec                IN OUT NOCOPY OE_Order_PUB.Line_Adj_Rec_Type
,   p_Line_Adj_val_rec              IN  OE_Order_PUB.Line_Adj_Val_Rec_Type
)
IS
l_Line_Adj_rec                OE_Order_PUB.Line_Adj_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
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

            l_Line_Adj_rec.discount_id := OE_CNCL_Value_To_Id.discount
            (   p_discount                    => p_Line_Adj_val_rec.discount
            );

            IF l_Line_Adj_rec.discount_id = FND_API.G_MISS_NUM THEN
                l_Line_Adj_rec.return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;

    END IF;


    -- RETURN l_Line_Adj_rec;
    p_x_Line_Adj_rec := l_Line_Adj_rec;

END Get_Line_Adj_Ids;


--  Procedure Convert_Miss_To_Null....FOR HEADER
--  copied from OEXUHDRB.pls 115.204 to fix bug 3576009...added TP_ATTRIBUTE1-15 and TP_CONTEXT for completeness

PROCEDURE Convert_Miss_To_Null
(   p_x_header_rec        IN OUT NOCOPY  OE_Order_PUB.Header_Rec_Type
)
IS
--p_x_header_rec                  OE_Order_PUB.Header_Rec_Type := p_header_rec;
BEGIN

    oe_debug_pub.add('Entering OE_CNCL_UTIL.CONVERT_MISS_TO_NULL: HEADER', 1);

    IF p_x_header_rec.accounting_rule_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.accounting_rule_id := NULL;
    END IF;

    IF p_x_header_rec.accounting_rule_duration = FND_API.G_MISS_NUM THEN
        p_x_header_rec.accounting_rule_duration := NULL;
    END IF;

    IF p_x_header_rec.agreement_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.agreement_id := NULL;
    END IF;

    IF p_x_header_rec.blanket_number = FND_API.G_MISS_NUM THEN
       p_x_header_rec.blanket_number := NULL;
    END IF;

    IF p_x_header_rec.booked_flag = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.booked_flag := NULL;
    END IF;

    IF p_x_header_rec.upgraded_flag = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.upgraded_flag := NULL;
    END IF;

    IF p_x_header_rec.booked_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.booked_date := NULL;
    END IF;

    IF p_x_header_rec.cancelled_flag = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.cancelled_flag := NULL;
    END IF;

    IF p_x_header_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute1 := NULL;
    END IF;

    IF p_x_header_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute10 := NULL;
    END IF;

    IF p_x_header_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute11 := NULL;
    END IF;

    IF p_x_header_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute12 := NULL;
    END IF;

    IF p_x_header_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute13 := NULL;
    END IF;

    IF p_x_header_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute14 := NULL;
    END IF;

    IF p_x_header_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute15 := NULL;
    END IF;

    IF p_x_header_rec.attribute16 = FND_API.G_MISS_CHAR THEN    --For bug 2184255
        p_x_header_rec.attribute16 := NULL;
    END IF;

    IF p_x_header_rec.attribute17 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute17 := NULL;
    END IF;

    IF p_x_header_rec.attribute18 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute18 := NULL;
    END IF;

    IF p_x_header_rec.attribute19 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute19 := NULL;
    END IF;

    IF p_x_header_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute2 := NULL;
    END IF;

    IF p_x_header_rec.attribute20 = FND_API.G_MISS_CHAR THEN    --For bug 2184255
        p_x_header_rec.attribute20 := NULL;
    END IF;

    IF p_x_header_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute3 := NULL;
    END IF;

    IF p_x_header_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute4 := NULL;
    END IF;

    IF p_x_header_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute5 := NULL;
    END IF;

    IF p_x_header_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute6 := NULL;
    END IF;

    IF p_x_header_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute7 := NULL;
    END IF;

    IF p_x_header_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute8 := NULL;
    END IF;

    IF p_x_header_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.attribute9 := NULL;
    END IF;

    IF p_x_header_rec.context = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.context := NULL;
    END IF;

    IF p_x_header_rec.conversion_rate = FND_API.G_MISS_NUM THEN
        p_x_header_rec.conversion_rate := NULL;
    END IF;

    IF p_x_header_rec.conversion_rate_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.conversion_rate_date := NULL;
    END IF;

    IF p_x_header_rec.conversion_type_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.conversion_type_code := NULL;
    END IF;

    IF p_x_header_rec.CUSTOMER_PREFERENCE_SET_CODE = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.CUSTOMER_PREFERENCE_SET_CODE := NULL;
    END IF;

    IF p_x_header_rec.created_by = FND_API.G_MISS_NUM THEN
        p_x_header_rec.created_by := NULL;
    END IF;

    IF p_x_header_rec.creation_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.creation_date := NULL;
    END IF;

    IF p_x_header_rec.cust_po_number = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.cust_po_number := NULL;
    END IF;

    IF p_x_header_rec.default_fulfillment_set = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.default_fulfillment_set := NULL;
    END IF;

    IF p_x_header_rec.deliver_to_contact_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.deliver_to_contact_id := NULL;
    END IF;

    IF p_x_header_rec.deliver_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.deliver_to_org_id := NULL;
    END IF;

    IF p_x_header_rec.demand_class_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.demand_class_code := NULL;
    END IF;

    IF p_x_header_rec.expiration_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.expiration_date := NULL;
    END IF;

    IF p_x_header_rec.earliest_schedule_limit = FND_API.G_MISS_NUM THEN
        p_x_header_rec.earliest_schedule_limit := NULL;
    END IF;

    IF p_x_header_rec.fob_point_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.fob_point_code := NULL;
    END IF;

    IF p_x_header_rec.freight_carrier_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.freight_carrier_code := NULL;
    END IF;

    IF p_x_header_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.freight_terms_code := NULL;
    END IF;

    IF p_x_header_rec.fulfillment_set_name = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.fulfillment_set_name := NULL;
    END IF;

    IF p_x_header_rec.global_attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute1 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute10 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute11 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute12 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute13 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute14 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute15 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute16 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute16 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute17 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute17 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute18 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute18 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute19 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute19 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute2 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute20 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute20 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute3 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute4 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute5 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute6 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute7 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute8 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute9 := NULL;
    END IF;

    IF p_x_header_rec.global_attribute_category = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.global_attribute_category := NULL;
    END IF;

    IF p_x_header_rec.header_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.header_id := NULL;
    END IF;

    IF p_x_header_rec.invoice_to_contact_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.invoice_to_contact_id := NULL;
    END IF;

    IF p_x_header_rec.invoice_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.invoice_to_org_id := NULL;
    END IF;

    IF p_x_header_rec.invoicing_rule_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.invoicing_rule_id := NULL;
    END IF;

    IF p_x_header_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        p_x_header_rec.last_updated_by := NULL;
    END IF;

    IF p_x_header_rec.last_update_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.last_update_date := NULL;
    END IF;

    IF p_x_header_rec.last_update_login = FND_API.G_MISS_NUM THEN
        p_x_header_rec.last_update_login := NULL;
    END IF;


    IF p_x_header_rec.latest_schedule_limit = FND_API.G_MISS_NUM THEN
        p_x_header_rec.latest_schedule_limit := NULL;
    END IF;

    IF p_x_header_rec.line_set_name = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.line_set_name := NULL;
    END IF;

    IF p_x_header_rec.open_flag = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.open_flag := NULL;
    END IF;

    IF p_x_header_rec.ordered_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.ordered_date := NULL;
    END IF;

    IF p_x_header_rec.order_date_type_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.order_date_type_code := NULL;
    END IF;

    IF p_x_header_rec.order_number = FND_API.G_MISS_NUM THEN
        p_x_header_rec.order_number := NULL;
    END IF;

    IF p_x_header_rec.order_source_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.order_source_id := NULL;
    END IF;

    IF p_x_header_rec.order_type_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.order_type_id := NULL;
    END IF;
    IF p_x_header_rec.order_category_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.order_category_code := NULL;
    END IF;

    IF p_x_header_rec.org_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.org_id := NULL;
    END IF;

    IF p_x_header_rec.orig_sys_document_ref = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.orig_sys_document_ref := NULL;
    END IF;

    IF p_x_header_rec.partial_shipments_allowed = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.partial_shipments_allowed := NULL;
    END IF;

    IF p_x_header_rec.payment_term_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.payment_term_id := NULL;
    END IF;

    IF p_x_header_rec.price_list_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.price_list_id := NULL;
    END IF;

    IF p_x_header_rec.price_request_code = FND_API.G_MISS_CHAR THEN  -- PROMOTIONS SEP/01
        p_x_header_rec.price_request_code := NULL;
    END IF;

    IF p_x_header_rec.pricing_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.pricing_date := NULL;
    END IF;

    IF p_x_header_rec.program_application_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.program_application_id := NULL;
    END IF;

    IF p_x_header_rec.program_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.program_id := NULL;
    END IF;

    IF p_x_header_rec.program_update_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.program_update_date := NULL;
    END IF;

    IF p_x_header_rec.request_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.request_date := NULL;
    END IF;

    IF p_x_header_rec.request_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.request_id := NULL;
    END IF;

    IF p_x_header_rec.return_reason_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.return_reason_code := NULL;
    END IF;

    IF p_x_header_rec.salesrep_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.salesrep_id := NULL;
    END IF;

    IF p_x_header_rec.sales_channel_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.sales_channel_code := NULL;
    END IF;

    IF p_x_header_rec.shipment_priority_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.shipment_priority_code := NULL;
    END IF;

    IF p_x_header_rec.shipping_method_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.shipping_method_code := NULL;
    END IF;

    IF p_x_header_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.ship_from_org_id := NULL;
    END IF;

    IF p_x_header_rec.ship_tolerance_above = FND_API.G_MISS_NUM THEN
        p_x_header_rec.ship_tolerance_above := NULL;
    END IF;

    IF p_x_header_rec.ship_tolerance_below = FND_API.G_MISS_NUM THEN
        p_x_header_rec.ship_tolerance_below := NULL;
    END IF;

    IF p_x_header_rec.ship_to_contact_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.ship_to_contact_id := NULL;
    END IF;

    IF p_x_header_rec.ship_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.ship_to_org_id := NULL;
    END IF;

    IF p_x_header_rec.sold_from_org_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.sold_from_org_id := NULL;
    END IF;

    IF p_x_header_rec.sold_to_contact_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.sold_to_contact_id := NULL;
    END IF;

    IF p_x_header_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.sold_to_org_id := NULL;
    END IF;

    IF p_x_header_rec.sold_to_phone_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.sold_to_phone_id := NULL;
    END IF;

    IF p_x_header_rec.source_document_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.source_document_id := NULL;
    END IF;

    IF p_x_header_rec.source_document_type_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.source_document_type_id := NULL;
    END IF;

    IF p_x_header_rec.tax_exempt_flag = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.tax_exempt_flag := NULL;
    END IF;

    IF p_x_header_rec.tax_exempt_number = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.tax_exempt_number := NULL;
    END IF;

    IF p_x_header_rec.tax_exempt_reason_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.tax_exempt_reason_code := NULL;
    END IF;

    IF p_x_header_rec.tax_point_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.tax_point_code := NULL;
    END IF;


    IF p_x_header_rec.TP_ATTRIBUTE1 = FND_API.G_MISS_CHAR THEN
     p_x_header_rec.TP_ATTRIBUTE1 := NULL;
    END IF;

    IF p_x_header_rec.TP_ATTRIBUTE10 = FND_API.G_MISS_CHAR THEN
     p_x_header_rec.TP_ATTRIBUTE10 := NULL;
    END IF;

    IF p_x_header_rec.TP_ATTRIBUTE11 = FND_API.G_MISS_CHAR THEN
     p_x_header_rec.TP_ATTRIBUTE11 := NULL;
    END IF;

    IF p_x_header_rec.TP_ATTRIBUTE12 = FND_API.G_MISS_CHAR THEN
     p_x_header_rec.TP_ATTRIBUTE12 := NULL;
    END IF;

    IF p_x_header_rec.TP_ATTRIBUTE13 = FND_API.G_MISS_CHAR THEN
     p_x_header_rec.TP_ATTRIBUTE13 := NULL;
    END IF;

    IF p_x_header_rec.TP_ATTRIBUTE14 = FND_API.G_MISS_CHAR THEN
     p_x_header_rec.TP_ATTRIBUTE14 := NULL;
    END IF;

    IF p_x_header_rec.TP_ATTRIBUTE15 = FND_API.G_MISS_CHAR THEN
     p_x_header_rec.TP_ATTRIBUTE15 := NULL;
    END IF;

    IF p_x_header_rec.TP_ATTRIBUTE2 = FND_API.G_MISS_CHAR THEN
     p_x_header_rec.TP_ATTRIBUTE2 := NULL;
    END IF;

    IF p_x_header_rec.TP_ATTRIBUTE3 = FND_API.G_MISS_CHAR THEN
     p_x_header_rec.TP_ATTRIBUTE3 := NULL;
    END IF;

    IF p_x_header_rec.TP_ATTRIBUTE4 = FND_API.G_MISS_CHAR THEN
     p_x_header_rec.TP_ATTRIBUTE4 := NULL;
    END IF;

    IF p_x_header_rec.TP_ATTRIBUTE5 = FND_API.G_MISS_CHAR THEN
     p_x_header_rec.TP_ATTRIBUTE5 := NULL;
    END IF;

    IF p_x_header_rec.TP_ATTRIBUTE6 = FND_API.G_MISS_CHAR THEN
     p_x_header_rec.TP_ATTRIBUTE6 := NULL;
    END IF;

    IF p_x_header_rec.TP_ATTRIBUTE7 = FND_API.G_MISS_CHAR THEN
     p_x_header_rec.TP_ATTRIBUTE7 := NULL;
    END IF;

    IF p_x_header_rec.TP_ATTRIBUTE8 = FND_API.G_MISS_CHAR THEN
     p_x_header_rec.TP_ATTRIBUTE8 := NULL;
    END IF;

    IF p_x_header_rec.TP_ATTRIBUTE9 = FND_API.G_MISS_CHAR THEN
     p_x_header_rec.TP_ATTRIBUTE9 := NULL;
    END IF;

    IF p_x_header_rec.TP_CONTEXT = FND_API.G_MISS_CHAR THEN
     p_x_header_rec.TP_CONTEXT := NULL;
    END IF;

    IF p_x_header_rec.transactional_curr_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.transactional_curr_code := NULL;
    END IF;

    IF p_x_header_rec.version_number = FND_API.G_MISS_NUM THEN
        p_x_header_rec.version_number := NULL;
    END IF;

    IF p_x_header_rec.payment_type_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.payment_type_code := NULL;
    END IF;

    IF p_x_header_rec.payment_amount = FND_API.G_MISS_NUM THEN
        p_x_header_rec.payment_amount := NULL;
    END IF;

    IF p_x_header_rec.check_number = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.check_number := NULL;
    END IF;

    IF p_x_header_rec.credit_card_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.credit_card_code := NULL;
    END IF;

    IF p_x_header_rec.credit_card_holder_name = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.credit_card_holder_name := NULL;
    END IF;

    IF p_x_header_rec.credit_card_number = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.credit_card_number := NULL;
    END IF;

    IF p_x_header_rec.credit_card_expiration_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.credit_card_expiration_date := NULL;
    END IF;

    IF p_x_header_rec.credit_card_approval_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.credit_card_approval_date := NULL;
    END IF;

    IF p_x_header_rec.credit_card_approval_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.credit_card_approval_code := NULL;
    END IF;

    IF p_x_header_rec.first_ack_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.first_ack_code := NULL;
    END IF;

    IF p_x_header_rec.first_ack_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.first_ack_date := NULL;
    END IF;

    IF p_x_header_rec.last_ack_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.last_ack_code := NULL;
    END IF;

    IF p_x_header_rec.last_ack_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.last_ack_date := NULL;
    END IF;

    IF p_x_header_rec.shipping_instructions = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.shipping_instructions := NULL;
    END IF;

    IF p_x_header_rec.packing_instructions = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.packing_instructions := NULL;
    END IF;

    IF p_x_header_rec.flow_status_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.flow_status_code := NULL;
    END IF;

    IF p_x_header_rec.marketing_source_code_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.marketing_source_code_id := NULL;
    END IF;

     IF p_x_header_rec.change_sequence = FND_API.G_MISS_CHAR THEN --2416561
        p_x_header_rec.change_sequence := NULL;
    END IF;

    -- QUOTING changes

    IF p_x_header_rec.quote_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.quote_date := NULL;
    END IF;

    IF p_x_header_rec.quote_number = FND_API.G_MISS_NUM THEN
        p_x_header_rec.quote_number := NULL;
    END IF;

    IF p_x_header_rec.sales_document_name = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.sales_document_name := NULL;
    END IF;

    IF p_x_header_rec.transaction_phase_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.transaction_phase_code := NULL;
    END IF;

    IF p_x_header_rec.user_status_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.user_status_code := NULL;
    END IF;

    IF p_x_header_rec.draft_submitted_flag = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.draft_submitted_flag := NULL;
    END IF;

    IF p_x_header_rec.source_document_version_number = FND_API.G_MISS_NUM THEN
        p_x_header_rec.source_document_version_number := NULL;
    END IF;

    IF p_x_header_rec.sold_to_site_use_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.sold_to_site_use_id := NULL;
    END IF;

    -- QUOTING changes END

    IF p_x_header_rec.Minisite_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.Minisite_id := NULL;
    END IF;

    IF p_x_header_rec.End_customer_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.End_customer_id := NULL;
    END IF;

    IF p_x_header_rec.End_customer_contact_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.End_customer_contact_id := NULL;
    END IF;

    IF p_x_header_rec.End_customer_site_use_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.End_customer_site_use_id := NULL;
    END IF;

    IF p_x_header_rec.Ib_owner = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.Ib_owner := NULL;
    END IF;

    IF p_x_header_rec.Ib_installed_at_location = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.Ib_installed_at_location := NULL;
    END IF;

    IF p_x_header_rec.Ib_current_location = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.Ib_current_location := NULL;
    END IF;

   IF p_x_header_rec.supplier_signature = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.supplier_signature := NULL;
    END IF;

   IF p_x_header_rec.supplier_signature_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.supplier_signature_date := NULL;
    END IF;

   IF p_x_header_rec.customer_signature = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.customer_signature := NULL;
    END IF;

  IF p_x_header_rec.customer_signature_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.customer_signature_date := NULL;
    END IF;

    IF p_x_header_rec.contract_template_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.contract_template_id := NULL;
    END IF;

    IF p_x_header_rec.contract_source_doc_type_code = FND_API.G_MISS_CHAR THEN
        p_x_header_rec.contract_source_doc_type_code := NULL;
    END IF;

    IF p_x_header_rec.contract_source_document_id = FND_API.G_MISS_NUM THEN
        p_x_header_rec.contract_source_document_id := NULL;
    END IF;

--key Transaction dates
    IF p_x_header_rec.order_firmed_date = FND_API.G_MISS_DATE THEN
        p_x_header_rec.order_firmed_date := NULL;
    END IF;

    oe_debug_pub.add('Exiting OE_CNCL_UTIL.CONVERT_MISS_TO_NULL: HEADER', 1);


END Convert_Miss_To_Null;


--  Procedure Convert_Miss_To_Null...FOR LINE
--  copied from OEXULINB.pls 115.574 to fix bug 3576009...added CHANGE_SEQUENCE, CUSTOMER_ITEM_NET_PRICE, CUSTOMER_PAYMENT_TERM_ID, and USER_ITEM_DESCRIPTION for completeness


PROCEDURE Convert_Miss_To_Null
(   p_x_line_rec                    IN OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
)
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  if l_debug_level > 0 then
    oe_debug_pub.add('Entering OE_CNCL_UTIL.CONVERT_MISS_TO_NULL: LINE', 1);

oe_debug_pub.add('outside margin convert miss to null',1);
  end if;
--MRG BGN
IF OE_FEATURES_PVT.Is_Margin_Avail Then
  if l_debug_level > 0 then
   oe_debug_pub.add('inside margin convert miss to null',1);
  end if;
    IF p_x_line_rec.unit_cost = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_cost := NULL;
    END IF;
END IF;
--MRG END


    IF p_x_line_rec.accounting_rule_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.accounting_rule_id := NULL;
    END IF;

    IF p_x_line_rec.accounting_rule_duration = FND_API.G_MISS_NUM THEN
        p_x_line_rec.accounting_rule_duration := NULL;
    END IF;

    IF p_x_line_rec.actual_arrival_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.actual_arrival_date := NULL;
    END IF;

    IF p_x_line_rec.actual_shipment_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.actual_shipment_date := NULL;
    END IF;

    IF p_x_line_rec.agreement_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.agreement_id := NULL;
    END IF;
    IF p_x_line_rec.arrival_set_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.arrival_set_id := NULL;
    END IF;

    IF p_x_line_rec.ato_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ato_line_id := NULL;
    END IF;
    IF p_x_line_rec.upgraded_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.upgraded_flag := NULL;
    END IF;

    IF p_x_line_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute1 := NULL;
    END IF;

    IF p_x_line_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute10 := NULL;
    END IF;

    IF p_x_line_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute11 := NULL;
    END IF;

    IF p_x_line_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute12 := NULL;
    END IF;

    IF p_x_line_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute13 := NULL;
    END IF;

    IF p_x_line_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute14 := NULL;
    END IF;

    IF p_x_line_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute15 := NULL;
    END IF;

    IF p_x_line_rec.attribute16 = FND_API.G_MISS_CHAR THEN    --For bug 2184255
        p_x_line_rec.attribute16 := NULL;
    END IF;

    IF p_x_line_rec.attribute17 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute17 := NULL;
    END IF;

    IF p_x_line_rec.attribute18 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute18 := NULL;
    END IF;

    IF p_x_line_rec.attribute19 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute19 := NULL;
    END IF;

    IF p_x_line_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute2 := NULL;
    END IF;

    IF p_x_line_rec.attribute20 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute20 := NULL;
    END IF;

    IF p_x_line_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute3 := NULL;
    END IF;

    IF p_x_line_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute4 := NULL;
    END IF;

    IF p_x_line_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute5 := NULL;
    END IF;

    IF p_x_line_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute6 := NULL;
    END IF;

    IF p_x_line_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute7 := NULL;
    END IF;

    IF p_x_line_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute8 := NULL;
    END IF;

    IF p_x_line_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.attribute9 := NULL;
    END IF;

    IF p_x_line_rec.auto_selected_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.auto_selected_quantity := NULL;
    END IF;
     IF p_x_line_rec.authorized_to_ship_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.authorized_to_ship_flag := NULL;
    END IF;

    IF p_x_line_rec.booked_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.booked_flag := NULL;
    END IF;

    IF p_x_line_rec.cancelled_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.cancelled_flag := NULL;
    END IF;

    IF p_x_line_rec.cancelled_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.cancelled_quantity := NULL;
    END IF;

    IF p_x_line_rec.component_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.component_code := NULL;
    END IF;

    IF p_x_line_rec.component_number = FND_API.G_MISS_NUM THEN
        p_x_line_rec.component_number := NULL;
    END IF;

    IF p_x_line_rec.component_sequence_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.component_sequence_id := NULL;
    END IF;

    IF p_x_line_rec.config_header_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.config_header_id := NULL;
    END IF;

    IF p_x_line_rec.config_rev_nbr = FND_API.G_MISS_NUM THEN
        p_x_line_rec.config_rev_nbr := NULL;
    END IF;

    IF p_x_line_rec.config_display_sequence = FND_API.G_MISS_NUM THEN
        p_x_line_rec.config_display_sequence := NULL;
    END IF;

    IF p_x_line_rec.configuration_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.configuration_id := NULL;
    END IF;

    IF p_x_line_rec.context = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.context := NULL;
    END IF;

    --Bug 6661371
    --Recurring charges
    IF p_x_line_rec.charge_periodicity_code = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.charge_periodicity_code := NULL;
    END IF;

    IF p_x_line_rec.created_by = FND_API.G_MISS_NUM THEN
        p_x_line_rec.created_by := NULL;
    END IF;

    IF p_x_line_rec.creation_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.creation_date := NULL;
    END IF;

    IF p_x_line_rec.credit_invoice_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.credit_invoice_line_id := NULL;
    END IF;

    IF p_x_line_rec.customer_dock_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.customer_dock_code := NULL;
    END IF;

    IF p_x_line_rec.customer_job = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.customer_job := NULL;
    END IF;

    IF p_x_line_rec.customer_production_line = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.customer_production_line := NULL;
    END IF;

    IF p_x_line_rec.cust_production_seq_num = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.cust_production_seq_num := NULL;
    END IF;

    IF p_x_line_rec.customer_trx_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.customer_trx_line_id := NULL;
    END IF;

    IF p_x_line_rec.cust_model_serial_number = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.cust_model_serial_number := NULL;
    END IF;

    IF p_x_line_rec.cust_po_number = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.cust_po_number := NULL;
    END IF;

    IF p_x_line_rec.customer_line_number = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.customer_line_number := NULL;
    END IF;

    IF p_x_line_rec.customer_shipment_number = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.customer_shipment_number := NULL;
    END IF;

    IF p_x_line_rec.delivery_lead_time = FND_API.G_MISS_NUM THEN
        p_x_line_rec.delivery_lead_time := NULL;
    END IF;

    IF p_x_line_rec.deliver_to_contact_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.deliver_to_contact_id := NULL;
    END IF;

    IF p_x_line_rec.deliver_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.deliver_to_org_id := NULL;
    END IF;

    IF p_x_line_rec.demand_bucket_type_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.demand_bucket_type_code := NULL;
    END IF;

    IF p_x_line_rec.demand_class_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.demand_class_code := NULL;
    END IF;

    IF p_x_line_rec.dep_plan_required_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.dep_plan_required_flag := NULL;
    END IF;


    IF p_x_line_rec.earliest_acceptable_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.earliest_acceptable_date := NULL;
    END IF;

    IF p_x_line_rec.explosion_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.explosion_date := NULL;
    END IF;

    IF p_x_line_rec.fob_point_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.fob_point_code := NULL;
    END IF;

    IF p_x_line_rec.freight_carrier_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.freight_carrier_code := NULL;
    END IF;

    IF p_x_line_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.freight_terms_code := NULL;
    END IF;

    IF p_x_line_rec.fulfilled_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.fulfilled_quantity := NULL;
    END IF;

    IF p_x_line_rec.fulfilled_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.fulfilled_flag := NULL;
    END IF;

    IF p_x_line_rec.fulfillment_method_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.fulfillment_method_code := NULL;
    END IF;

    IF p_x_line_rec.fulfillment_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.fulfillment_date := NULL;
    END IF;

    IF p_x_line_rec.global_attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute1 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute10 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute11 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute12 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute13 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute14 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute15 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute16 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute16 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute17 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute17 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute18 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute18 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute19 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute19 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute2 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute20 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute20 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute3 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute4 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute5 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute6 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute7 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute8 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute9 := NULL;
    END IF;

    IF p_x_line_rec.global_attribute_category = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.global_attribute_category := NULL;
    END IF;

    IF p_x_line_rec.header_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.header_id := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute1 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute10 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute11 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute12 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute13 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute14 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute15 := NULL;
    END IF;

IF p_x_line_rec.industry_attribute16 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute16 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute17 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute17 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute18 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute18 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute19 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute19 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute20 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute20 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute21 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute21 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute22 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute22 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute23 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute23 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute24 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute24 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute25 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute25 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute26 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute26 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute27 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute27 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute28 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute28 := NULL;
    END IF;
 IF p_x_line_rec.industry_attribute29 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute29 := NULL;
    END IF;
IF p_x_line_rec.industry_attribute30 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute30 := NULL;
    END IF;


    IF p_x_line_rec.industry_attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute2 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute3 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute4 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute5 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute6 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute7 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute8 := NULL;
    END IF;

    IF p_x_line_rec.industry_attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_attribute9 := NULL;
    END IF;

    IF p_x_line_rec.industry_context = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.industry_context := NULL;
    END IF;

    /* TP_ATTRIBUTE */
    IF p_x_line_rec.tp_context = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_context := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute1 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute2 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute3 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute4 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute5 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute6 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute7 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute8 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute9 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute10 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute11 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute12 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute13 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute14 := NULL;
    END IF;
    IF p_x_line_rec.tp_attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tp_attribute15 := NULL;
    END IF;


    IF p_x_line_rec.intermed_ship_to_contact_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.intermed_ship_to_contact_id := NULL;
    END IF;

    IF p_x_line_rec.intermed_ship_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.intermed_ship_to_org_id := NULL;
    END IF;

    IF p_x_line_rec.inventory_item_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.inventory_item_id := NULL;
    END IF;

    IF p_x_line_rec.invoice_interface_status_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.invoice_interface_status_code := NULL;
    END IF;



    IF p_x_line_rec.invoice_to_contact_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.invoice_to_contact_id := NULL;
    END IF;

    IF p_x_line_rec.invoiced_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.invoiced_quantity := NULL;
    END IF;

    IF p_x_line_rec.invoice_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.invoice_to_org_id := NULL;
    END IF;

    IF p_x_line_rec.invoicing_rule_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.invoicing_rule_id := NULL;
    END IF;

    IF p_x_line_rec.ordered_item_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ordered_item_id := NULL;
    END IF;

    IF p_x_line_rec.item_identifier_type = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.item_identifier_type := NULL;
    END IF;

    IF p_x_line_rec.ordered_item = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.ordered_item := NULL;
    END IF;

    IF p_x_line_rec.item_revision = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.item_revision := NULL;
    END IF;

    IF p_x_line_rec.item_type_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.item_type_code := NULL;
    END IF;

    IF p_x_line_rec.last_updated_by = FND_API.G_MISS_NUM THEN
        p_x_line_rec.last_updated_by := NULL;
    END IF;

    IF p_x_line_rec.last_update_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.last_update_date := NULL;
    END IF;

    IF p_x_line_rec.last_update_login = FND_API.G_MISS_NUM THEN
        p_x_line_rec.last_update_login := NULL;
    END IF;

    IF p_x_line_rec.latest_acceptable_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.latest_acceptable_date := NULL;
    END IF;

    IF p_x_line_rec.line_category_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.line_category_code := NULL;
    END IF;

    IF p_x_line_rec.line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.line_id := NULL;
    END IF;

    IF p_x_line_rec.line_number = FND_API.G_MISS_NUM THEN
        p_x_line_rec.line_number := NULL;
    END IF;

    IF p_x_line_rec.line_type_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.line_type_id := NULL;
    END IF;

    IF p_x_line_rec.link_to_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.link_to_line_id := NULL;
    END IF;

    IF p_x_line_rec.model_group_number = FND_API.G_MISS_NUM THEN
        p_x_line_rec.model_group_number := NULL;
    END IF;

    IF p_x_line_rec.mfg_component_sequence_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.mfg_component_sequence_id := NULL;
    END IF;

    IF p_x_line_rec.mfg_lead_time = FND_API.G_MISS_NUM THEN
        p_x_line_rec.mfg_lead_time := NULL;
    END IF;

    IF p_x_line_rec.open_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.open_flag := NULL;
    END IF;

    IF p_x_line_rec.option_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.option_flag := NULL;
    END IF;

    IF p_x_line_rec.option_number = FND_API.G_MISS_NUM THEN
        p_x_line_rec.option_number := NULL;
    END IF;

    IF p_x_line_rec.ordered_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ordered_quantity := NULL;
    END IF;

    IF p_x_line_rec.order_quantity_uom = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.order_quantity_uom := NULL;
    END IF;

    -- OPM 02/JUN/00 - Deal with process attributes
    -- ============================================
    IF p_x_line_rec.ordered_quantity2 = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ordered_quantity2 := NULL;
    END IF;

    IF p_x_line_rec.ordered_quantity_uom2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.ordered_quantity_uom2 := NULL;
    END IF;
    -- OPM 02/JUN/00 - END
    -- ===================

    IF p_x_line_rec.org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.org_id := NULL;
    END IF;

    IF p_x_line_rec.orig_sys_document_ref = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.orig_sys_document_ref := NULL;
    END IF;

    IF p_x_line_rec.orig_sys_line_ref = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.orig_sys_line_ref := NULL;
    END IF;

    IF p_x_line_rec.orig_sys_shipment_ref = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.orig_sys_shipment_ref := NULL;
    END IF;

-- Override List Price
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
       IF p_x_line_rec.original_list_price = FND_API.G_MISS_NUM THEN
          p_x_line_rec.original_list_price:= NULL;
       END IF;
    END IF;
-- Override List Price

    IF p_x_line_rec.over_ship_reason_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.over_ship_reason_code := NULL;
    END IF;
    IF p_x_line_rec.over_ship_resolved_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.over_ship_resolved_flag := NULL;
    END IF;

    IF p_x_line_rec.payment_term_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.payment_term_id := NULL;
    END IF;

    IF p_x_line_rec.planning_priority = FND_API.G_MISS_NUM THEN
        p_x_line_rec.planning_priority := NULL;
    END IF;

    -- OPM 02/JUN/00 - Deal with process attributes
    -- ============================================
    IF p_x_line_rec.preferred_grade = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.preferred_grade := NULL;
    END IF;
    -- OPM 02/JUN/00 - END
    -- ===================

    IF p_x_line_rec.price_list_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.price_list_id := NULL;
    END IF;

     IF p_x_line_rec.price_request_code = FND_API.G_MISS_CHAR THEN -- PROMOTIONS SEP/01
        p_x_line_rec.price_request_code := NULL;
    END IF;

    IF p_x_line_rec.pricing_attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute1 := NULL;
    END IF;

    IF p_x_line_rec.pricing_attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute10 := NULL;
    END IF;

    IF p_x_line_rec.pricing_attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute2 := NULL;
    END IF;

    IF p_x_line_rec.pricing_attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute3 := NULL;
    END IF;

    IF p_x_line_rec.pricing_attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute4 := NULL;
    END IF;

    IF p_x_line_rec.pricing_attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute5 := NULL;
    END IF;

    IF p_x_line_rec.pricing_attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute6 := NULL;
    END IF;

    IF p_x_line_rec.pricing_attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute7 := NULL;
    END IF;

    IF p_x_line_rec.pricing_attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute8 := NULL;
    END IF;

    IF p_x_line_rec.pricing_attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_attribute9 := NULL;
    END IF;

    IF p_x_line_rec.pricing_context = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_context := NULL;
    END IF;

    IF p_x_line_rec.pricing_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.pricing_date := NULL;
    END IF;

    IF p_x_line_rec.pricing_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.pricing_quantity := NULL;
    END IF;

    IF p_x_line_rec.pricing_quantity_uom = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.pricing_quantity_uom := NULL;
    END IF;

    IF p_x_line_rec.program_application_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.program_application_id := NULL;
    END IF;

    IF p_x_line_rec.program_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.program_id := NULL;
    END IF;

    IF p_x_line_rec.program_update_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.program_update_date := NULL;
    END IF;

    IF p_x_line_rec.project_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.project_id := NULL;
    END IF;

    IF p_x_line_rec.promise_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.promise_date := NULL;
    END IF;

    IF p_x_line_rec.re_source_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.re_source_flag := NULL;
    END IF;

    IF p_x_line_rec.reference_customer_trx_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.reference_customer_trx_line_id := NULL;
    END IF;

    IF p_x_line_rec.reference_header_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.reference_header_id := NULL;
    END IF;

    IF p_x_line_rec.reference_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.reference_line_id := NULL;
    END IF;

    IF p_x_line_rec.reference_type = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.reference_type := NULL;
    END IF;



    IF p_x_line_rec.request_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.request_date := NULL;
    END IF;

    IF p_x_line_rec.request_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.request_id := NULL;
    END IF;

    IF p_x_line_rec.return_attribute1 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute1 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute10 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute10 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute11 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute11 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute12 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute12 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute13 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute13 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute14 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute14 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute15 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute15 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute2 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute2 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute3 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute3 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute4 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute4 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute5 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute5 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute6 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute6 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute7 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute7 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute8 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute8 := NULL;
    END IF;

    IF p_x_line_rec.return_attribute9 = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_attribute9 := NULL;
    END IF;

    IF p_x_line_rec.return_context = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_context := NULL;
    END IF;
    IF p_x_line_rec.return_reason_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.return_reason_code := NULL;
    END IF;
    IF p_x_line_rec.salesrep_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.salesrep_id := NULL;
    END IF;

    IF p_x_line_rec.rla_schedule_type_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.rla_schedule_type_code := NULL;
    END IF;

    IF p_x_line_rec.schedule_arrival_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.schedule_arrival_date := NULL;
    END IF;

    IF p_x_line_rec.schedule_ship_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.schedule_ship_date := NULL;
    END IF;

    IF p_x_line_rec.schedule_action_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.schedule_action_code := NULL;
    END IF;

    IF p_x_line_rec.schedule_status_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.schedule_status_code := NULL;
    END IF;

    IF p_x_line_rec.shipment_number = FND_API.G_MISS_NUM THEN
        p_x_line_rec.shipment_number := NULL;
    END IF;

    IF p_x_line_rec.shipment_priority_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.shipment_priority_code := NULL;
    END IF;

    IF p_x_line_rec.shipped_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.shipped_quantity := NULL;
    END IF;

    IF p_x_line_rec.shipped_quantity2 = FND_API.G_MISS_NUM THEN -- OPM B1661023 04/02/01
        p_x_line_rec.shipped_quantity2 := NULL;
    END IF;

    IF p_x_line_rec.shipping_method_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.shipping_method_code := NULL;
    END IF;

    IF p_x_line_rec.shipping_quantity = FND_API.G_MISS_NUM THEN
        p_x_line_rec.shipping_quantity := NULL;
    END IF;

    IF p_x_line_rec.shipping_quantity2 = FND_API.G_MISS_NUM THEN -- OPM B1661023 04/02/01
        p_x_line_rec.shipping_quantity2 := NULL;
    END IF;

    IF p_x_line_rec.shipping_quantity_uom = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.shipping_quantity_uom := NULL;
    END IF;

    IF p_x_line_rec.ship_from_org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ship_from_org_id := NULL;
    END IF;

    IF p_x_line_rec.subinventory = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.subinventory := NULL;
    END IF;

    IF p_x_line_rec.ship_model_complete_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.ship_model_complete_flag := NULL;
    END IF;
    IF p_x_line_rec.ship_set_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ship_set_id := NULL;
    END IF;

    IF p_x_line_rec.ship_tolerance_above = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ship_tolerance_above := NULL;
    END IF;

    IF p_x_line_rec.ship_tolerance_below = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ship_tolerance_below := NULL;
    END IF;

    IF p_x_line_rec.shippable_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.shippable_flag := NULL;
    END IF;

    IF p_x_line_rec.shipping_interfaced_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.shipping_interfaced_flag := NULL;
    END IF;

    IF p_x_line_rec.ship_to_contact_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ship_to_contact_id := NULL;
    END IF;

    IF p_x_line_rec.ship_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.ship_to_org_id := NULL;
    END IF;

    IF p_x_line_rec.sold_from_org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.sold_from_org_id := NULL;
    END IF;

    IF p_x_line_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.sold_to_org_id := NULL;
    END IF;

    IF p_x_line_rec.sort_order = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.sort_order := NULL;
    END IF;

    IF p_x_line_rec.source_document_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.source_document_id := NULL;
    END IF;

    IF p_x_line_rec.source_document_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.source_document_line_id := NULL;
    END IF;

    IF p_x_line_rec.source_document_type_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.source_document_type_id := NULL;
    END IF;

    IF p_x_line_rec.source_type_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.source_type_code := NULL;
    END IF;
    IF p_x_line_rec.split_from_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.split_from_line_id := NULL;
    END IF;
    IF p_x_line_rec.line_set_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.line_set_id := NULL;
    END IF;

    IF p_x_line_rec.split_by = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.split_by := NULL;
    END IF;
    IF p_x_line_rec.model_remnant_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.model_remnant_flag := NULL;
    END IF;
    IF p_x_line_rec.task_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.task_id := NULL;
    END IF;

    IF p_x_line_rec.tax_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tax_code := NULL;
    END IF;

    IF p_x_line_rec.tax_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.tax_date := NULL;
    END IF;

    IF p_x_line_rec.tax_exempt_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tax_exempt_flag := NULL;
    END IF;

    IF p_x_line_rec.tax_exempt_number = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tax_exempt_number := NULL;
    END IF;

    IF p_x_line_rec.tax_exempt_reason_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tax_exempt_reason_code := NULL;
    END IF;

    IF p_x_line_rec.tax_point_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.tax_point_code := NULL;
    END IF;

    IF p_x_line_rec.tax_rate = FND_API.G_MISS_NUM THEN
        p_x_line_rec.tax_rate := NULL;
    END IF;

    IF p_x_line_rec.tax_value = FND_API.G_MISS_NUM THEN
        p_x_line_rec.tax_value := NULL;
    END IF;

    IF p_x_line_rec.top_model_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.top_model_line_id := NULL;
    END IF;

    IF p_x_line_rec.unit_list_price = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_list_price := NULL;
    END IF;

    IF p_x_line_rec.unit_list_price_per_pqty = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_list_price_per_pqty := NULL;
    END IF;

    IF p_x_line_rec.unit_selling_price = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_selling_price := NULL;
    END IF;

    IF p_x_line_rec.unit_selling_price_per_pqty = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_selling_price_per_pqty := NULL;
    END IF;


    IF p_x_line_rec.visible_demand_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.visible_demand_flag := NULL;
    END IF;
    IF p_x_line_rec.veh_cus_item_cum_key_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.veh_cus_item_cum_key_id := NULL;
    END IF;

    IF p_x_line_rec.first_ack_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.first_ack_code := NULL;
    END IF;

    IF p_x_line_rec.first_ack_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.first_ack_date := NULL;
    END IF;

    IF p_x_line_rec.last_ack_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.last_ack_code := NULL;
    END IF;

    IF p_x_line_rec.last_ack_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.last_ack_date := NULL;
    END IF;


    IF p_x_line_rec.end_item_unit_number = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.end_item_unit_number := NULL;
    END IF;

    IF p_x_line_rec.shipping_instructions = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.shipping_instructions := NULL;
    END IF;

    IF p_x_line_rec.packing_instructions = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.packing_instructions := NULL;
    END IF;

    -- Service related columns

    IF p_x_line_rec.service_txn_reason_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.service_txn_reason_code := NULL;
    END IF;

    IF p_x_line_rec.service_txn_comments = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.service_txn_comments := NULL;
    END IF;

    IF p_x_line_rec.service_duration = FND_API.G_MISS_NUM THEN
        p_x_line_rec.service_duration := NULL;
    END IF;

    IF p_x_line_rec.service_period = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.service_period := NULL;
    END IF;

    IF p_x_line_rec.service_start_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.service_start_date := NULL;
    END IF;

    IF p_x_line_rec.service_end_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.service_end_date := NULL;
    END IF;

    IF p_x_line_rec.service_coterminate_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.service_coterminate_flag := NULL;
    END IF;


    IF p_x_line_rec.unit_list_percent = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_list_percent := NULL;
    END IF;

    IF p_x_line_rec.unit_selling_percent = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_selling_percent := NULL;
    END IF;

    IF p_x_line_rec.unit_percent_base_price = FND_API.G_MISS_NUM THEN
        p_x_line_rec.unit_percent_base_price := NULL;
    END IF;

    IF p_x_line_rec.service_number = FND_API.G_MISS_NUM THEN
        p_x_line_rec.service_number := NULL;
    END IF;

    IF p_x_line_rec.service_reference_type_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.service_reference_type_code := NULL;
    END IF;

    IF p_x_line_rec.service_reference_line_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.service_reference_line_id := NULL;
    END IF;

    IF p_x_line_rec.service_reference_system_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.service_reference_system_id := NULL;
    END IF;

    /* Marketing source code related */

    IF p_x_line_rec.marketing_source_code_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.marketing_source_code_id := NULL;
    END IF;

    /* End of Marketing source code related */

    IF p_x_line_rec.order_source_id = FND_API.G_MISS_NUM THEN
  if l_debug_level > 0 then
    oe_debug_pub.add('OEXVCIGB convert_miss_to_null - order_source_id');
  end if;
        p_x_line_rec.order_source_id := NULL;
    END IF;

    IF p_x_line_rec.flow_status_code = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.flow_status_code := NULL;
    END IF;

    -- Commitment related
    IF p_x_line_rec.commitment_id = FND_API.G_MISS_NUM THEN
       p_x_line_rec.commitment_id := NULL;
    END IF;


   -- Item Substitution changes.
   IF p_x_line_rec.Original_Inventory_Item_Id = FND_API.G_MISS_NUM THEN
       p_x_line_rec.Original_Inventory_Item_Id := Null;
   END IF;

   IF p_x_line_rec.Original_item_identifier_Type = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.Original_item_identifier_Type := Null;
   END IF;

   IF p_x_line_rec.Original_ordered_item_id = FND_API.G_MISS_NUM THEN
       p_x_line_rec.Original_ordered_item_id := Null;
   END IF;

   IF p_x_line_rec.Original_ordered_item = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.Original_ordered_item := Null;
   END IF;

   IF p_x_line_rec.item_relationship_type = FND_API.G_MISS_NUM THEN
       p_x_line_rec.item_relationship_type := Null;
   END IF;

   IF p_x_line_rec.Item_substitution_type_code = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.Item_substitution_type_code := Null;
   END IF;

   IF p_x_line_rec.Late_Demand_Penalty_Factor = FND_API.G_MISS_NUM THEN
       p_x_line_rec.Late_Demand_Penalty_Factor := Null;
   END IF;

   IF p_x_line_rec.Override_atp_date_code = FND_API.G_MISS_CHAR THEN
       p_x_line_rec.Override_atp_date_code := Null;
   END IF;

   -- Changes for Blanket Orders

   IF p_x_line_rec.Blanket_Number = FND_API.G_MISS_NUM THEN
      p_x_line_rec.Blanket_Number := NULL;
   END IF;

   IF p_x_line_rec.Blanket_Line_Number = FND_API.G_MISS_NUM THEN
      p_x_line_rec.Blanket_Line_Number := NULL;
   END IF;

   IF p_x_line_rec.Blanket_Version_Number = FND_API.G_MISS_NUM THEN
      p_x_line_rec.Blanket_Version_Number := NULL;
   END IF;

   -- QUOTING changes
   IF p_x_line_rec.transaction_phase_code = FND_API.G_MISS_CHAR THEN
      p_x_line_rec.transaction_phase_code := NULL;
   END IF;

   IF p_x_line_rec.source_document_version_number = FND_API.G_MISS_NUM THEN
      p_x_line_rec.source_document_version_number := NULL;
   END IF;
   -- END QUOTING changes
    IF p_x_line_rec.Minisite_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.Minisite_id := NULL;
    END IF;

    IF p_x_line_rec.End_customer_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.End_customer_id := NULL;
    END IF;

    IF p_x_line_rec.End_customer_contact_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.End_customer_contact_id := NULL;
    END IF;

    IF p_x_line_rec.End_customer_site_use_id = FND_API.G_MISS_NUM THEN
        p_x_line_rec.End_customer_site_use_id := NULL;
    END IF;

    IF p_x_line_rec.ib_owner = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.ib_owner := NULL;
    END IF;

    IF p_x_line_rec.ib_installed_at_location = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.ib_installed_at_location := NULL;
    END IF;

    IF p_x_line_rec.ib_current_location = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.ib_current_location := NULL;
    END IF;

    --retro{
    IF p_x_line_rec.retrobill_request_id = FND_API.G_MISS_NUM THEN
       p_x_line_rec.retrobill_request_id := Null;
    END IF;
    --retro}

    IF p_x_line_rec.firm_demand_flag = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.firm_demand_flag := NULL;
    END IF;

--key Transaction Dates
    IF p_x_line_rec.order_firmed_date = FND_API.G_MISS_DATE THEN
      	p_x_line_rec.order_firmed_date := NULL;
    END IF;

   IF p_x_line_rec.actual_fulfillment_date = FND_API.G_MISS_DATE THEN
	p_x_line_rec.actual_fulfillment_date := NULL;
    END IF;
--end

/*   IF p_x_line_rec.supplier_signature = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.supplier_signature := NULL;
    END IF;

   IF p_x_line_rec.supplier_signature_date = FND_API.G_MISS_DATE THEN
        p_x_line_rec.supplier_signature_date := NULL;
    END IF;

   IF p_x_line_rec.customer_signature = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.customer_signature := NULL;
    END IF;

   IF p_x_line_rec.customer_signature_date = FND_API.G_MISS_CHAR THEN
        p_x_line_rec.customer_signature_date := NULL;
    END IF;
*/


    IF p_x_line_rec.CHANGE_SEQUENCE = FND_API.G_MISS_CHAR THEN
      p_x_line_rec.CHANGE_SEQUENCE := NULL;
    END IF;

    IF p_x_line_rec.CUSTOMER_ITEM_NET_PRICE = FND_API.G_MISS_NUM THEN
      p_x_line_rec.CUSTOMER_ITEM_NET_PRICE := NULL;
    END IF;

    IF p_x_line_rec.CUSTOMER_PAYMENT_TERM_ID = FND_API.G_MISS_NUM THEN
      p_x_line_rec.CUSTOMER_PAYMENT_TERM_ID := NULL;
    END IF;

    IF p_x_line_rec.USER_ITEM_DESCRIPTION = FND_API.G_MISS_CHAR THEN
      p_x_line_rec.USER_ITEM_DESCRIPTION := NULL;
    END IF;

  if l_debug_level > 0 then
   oe_debug_pub.add('Exiting OE_CNCL_UTIL.CONVERT_MISS_TO_NULL: LINE', 1);
  end if;
END Convert_Miss_To_Null;


--  Procedure Convert_Miss_To_Null...FOR HEADER ADJUSTMENT
--  copied from OEXUHADB.pls 115.67 to fix same issue raised by bug 3576009


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
        oe_debug_pub.add(  'ENTERING OE_CNCL_UTIL.CONVERT_MISS_TO_NULL: HEADER ADJUSTMENT' , 1 ) ;
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
        oe_debug_pub.add(  'EXITING OE_CNCL_UTIL.CONVERT_MISS_TO_NULL: HEADER ADJUSTMENT' , 1 ) ;
    END IF;

    -- RETURN l_Header_Adj_rec;
    p_x_Header_Adj_rec := l_Header_Adj_rec;

END Convert_Miss_To_Null;



PROCEDURE Convert_Miss_To_Null
(   p_x_Header_Scredit_rec  IN OUT NOCOPY  OE_Order_PUB.Header_Scredit_Rec_Type
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_CNCL_UTIL.CONVERT_MISS_TO_NULL: HEADER SCREDIT' , 1 ) ;
    END IF;
    IF p_x_Header_Scredit_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR THEN
      p_x_Header_Scredit_rec.ATTRIBUTE1 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR THEN
      p_x_Header_Scredit_rec.ATTRIBUTE10 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR THEN
      p_x_Header_Scredit_rec.ATTRIBUTE11 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR THEN

      p_x_Header_Scredit_rec.ATTRIBUTE12 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR THEN
      p_x_Header_Scredit_rec.ATTRIBUTE13 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR THEN
      p_x_Header_Scredit_rec.ATTRIBUTE14 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR THEN
      p_x_Header_Scredit_rec.ATTRIBUTE15 := NULL;

    END IF;

    IF p_x_Header_Scredit_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR THEN
      p_x_Header_Scredit_rec.ATTRIBUTE2 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR THEN
      p_x_Header_Scredit_rec.ATTRIBUTE3 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR THEN
      p_x_Header_Scredit_rec.ATTRIBUTE4 := NULL;
    END IF;


    IF p_x_Header_Scredit_rec.ATTRIBUTE5 = FND_API.G_MISS_CHAR THEN
      p_x_Header_Scredit_rec.ATTRIBUTE5 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR THEN
      p_x_Header_Scredit_rec.ATTRIBUTE6 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR THEN
      p_x_Header_Scredit_rec.ATTRIBUTE7 := NULL;
    END IF;


    IF p_x_Header_Scredit_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR THEN
      p_x_Header_Scredit_rec.ATTRIBUTE8 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR THEN
      p_x_Header_Scredit_rec.ATTRIBUTE9 := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.CONTEXT = FND_API.G_MISS_CHAR THEN
      p_x_Header_Scredit_rec.CONTEXT := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.CREATED_BY = FND_API.G_MISS_NUM THEN

      p_x_Header_Scredit_rec.CREATED_BY := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.CREATION_DATE = FND_API.G_MISS_DATE THEN

      p_x_Header_Scredit_rec.CREATION_DATE := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.DW_UPDATE_ADVICE_FLAG = FND_API.G_MISS_CHAR THEN
      p_x_Header_Scredit_rec.DW_UPDATE_ADVICE_FLAG := NULL;
    END IF;


    IF p_x_Header_Scredit_rec.HEADER_ID = FND_API.G_MISS_NUM THEN
      p_x_Header_Scredit_rec.HEADER_ID := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.LAST_UPDATED_BY = FND_API.G_MISS_NUM THEN
      p_x_Header_Scredit_rec.LAST_UPDATED_BY := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.LAST_UPDATE_DATE = FND_API.G_MISS_DATE THEN
      p_x_Header_Scredit_rec.LAST_UPDATE_DATE := NULL;
    END IF;


    IF p_x_Header_Scredit_rec.LAST_UPDATE_LOGIN = FND_API.G_MISS_NUM THEN
      p_x_Header_Scredit_rec.LAST_UPDATE_LOGIN := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.LINE_ID = FND_API.G_MISS_NUM THEN
      p_x_Header_Scredit_rec.LINE_ID := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.LOCK_CONTROL = FND_API.G_MISS_NUM THEN
      p_x_Header_Scredit_rec.LOCK_CONTROL := NULL;
    END IF;


    IF p_x_Header_Scredit_rec.ORIG_SYS_CREDIT_REF = FND_API.G_MISS_CHAR THEN
      p_x_Header_Scredit_rec.ORIG_SYS_CREDIT_REF := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.PERCENT = FND_API.G_MISS_NUM THEN
      p_x_Header_Scredit_rec.PERCENT := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.SALESREP_ID = FND_API.G_MISS_NUM THEN
      p_x_Header_Scredit_rec.SALESREP_ID := NULL;
    END IF;


    IF p_x_Header_Scredit_rec.SALES_CREDIT_ID = FND_API.G_MISS_NUM THEN
      p_x_Header_Scredit_rec.SALES_CREDIT_ID := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.SALES_CREDIT_TYPE_ID = FND_API.G_MISS_NUM THEN
      p_x_Header_Scredit_rec.SALES_CREDIT_TYPE_ID := NULL;
    END IF;

    IF p_x_Header_Scredit_rec.WH_UPDATE_DATE = FND_API.G_MISS_DATE THEN
      p_x_Header_Scredit_rec.WH_UPDATE_DATE := NULL;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_CNCL_UTIL.CONVERT_MISS_TO_NULL: HEADER SCREDIT' , 1 ) ;
    END IF;

END Convert_Miss_To_Null;




--  Procedure Convert_Miss_To_Null...FOR LINE ADJUSTMENT
--  copied from OEXULADB.pls 115.117 to fix same issue raised by bug 3576009


PROCEDURE Convert_Miss_To_Null
(   p_x_Line_Adj_rec                  IN OUT NOCOPY OE_Order_PUB.Line_Adj_Rec_Type
)
IS
l_Line_Adj_rec                OE_Order_PUB.Line_Adj_Rec_Type := p_x_Line_Adj_rec;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_CNCL_UTIL.CONVERT_MISS_TO_NULL: LINE ADJUSTMENT' , 1 ) ;
    END IF;

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
    If l_line_Adj_rec.tax_rate_id = FND_API.G_MISS_NUM THEN
       l_line_Adj_rec.tax_rate_id := NULL;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_CNCL_UTIL.CONVERT_MISS_TO_NULL: LINE ADJUSTMENT' , 1 ) ;
    END IF;

    -- RETURN l_Line_Adj_rec;
    p_x_Line_Adj_rec := l_Line_Adj_rec;

END Convert_Miss_To_Null;



PROCEDURE Convert_Miss_To_Null
(   p_x_Line_Scredit_rec              IN OUT NOCOPY  OE_Order_PUB.Line_Scredit_Rec_Type
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_CNCL_UTIL.CONVERT_MISS_TO_NULL: LINE SCREDIT' , 1 ) ;
    END IF;
    IF p_x_Line_Scredit_rec.ATTRIBUTE1 = FND_API.G_MISS_CHAR THEN
      p_x_Line_Scredit_rec.ATTRIBUTE1 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.ATTRIBUTE10 = FND_API.G_MISS_CHAR THEN
      p_x_Line_Scredit_rec.ATTRIBUTE10 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.ATTRIBUTE11 = FND_API.G_MISS_CHAR THEN
      p_x_Line_Scredit_rec.ATTRIBUTE11 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.ATTRIBUTE12 = FND_API.G_MISS_CHAR THEN

      p_x_Line_Scredit_rec.ATTRIBUTE12 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.ATTRIBUTE13 = FND_API.G_MISS_CHAR THEN
      p_x_Line_Scredit_rec.ATTRIBUTE13 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.ATTRIBUTE14 = FND_API.G_MISS_CHAR THEN
      p_x_Line_Scredit_rec.ATTRIBUTE14 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.ATTRIBUTE15 = FND_API.G_MISS_CHAR THEN
      p_x_Line_Scredit_rec.ATTRIBUTE15 := NULL;

    END IF;

    IF p_x_Line_Scredit_rec.ATTRIBUTE2 = FND_API.G_MISS_CHAR THEN
      p_x_Line_Scredit_rec.ATTRIBUTE2 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.ATTRIBUTE3 = FND_API.G_MISS_CHAR THEN
      p_x_Line_Scredit_rec.ATTRIBUTE3 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.ATTRIBUTE4 = FND_API.G_MISS_CHAR THEN
      p_x_Line_Scredit_rec.ATTRIBUTE4 := NULL;
    END IF;


    IF p_x_Line_Scredit_rec.ATTRIBUTE5 = FND_API.G_MISS_CHAR THEN
      p_x_Line_Scredit_rec.ATTRIBUTE5 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.ATTRIBUTE6 = FND_API.G_MISS_CHAR THEN
      p_x_Line_Scredit_rec.ATTRIBUTE6 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.ATTRIBUTE7 = FND_API.G_MISS_CHAR THEN
      p_x_Line_Scredit_rec.ATTRIBUTE7 := NULL;
    END IF;


    IF p_x_Line_Scredit_rec.ATTRIBUTE8 = FND_API.G_MISS_CHAR THEN
      p_x_Line_Scredit_rec.ATTRIBUTE8 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.ATTRIBUTE9 = FND_API.G_MISS_CHAR THEN
      p_x_Line_Scredit_rec.ATTRIBUTE9 := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.CONTEXT = FND_API.G_MISS_CHAR THEN
      p_x_Line_Scredit_rec.CONTEXT := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.CREATED_BY = FND_API.G_MISS_NUM THEN

      p_x_Line_Scredit_rec.CREATED_BY := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.CREATION_DATE = FND_API.G_MISS_DATE THEN
      p_x_Line_Scredit_rec.CREATION_DATE := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.DW_UPDATE_ADVICE_FLAG = FND_API.G_MISS_CHAR THEN
      p_x_Line_Scredit_rec.DW_UPDATE_ADVICE_FLAG := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.HEADER_ID = FND_API.G_MISS_NUM THEN

      p_x_Line_Scredit_rec.HEADER_ID := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.LAST_UPDATED_BY = FND_API.G_MISS_NUM THEN

      p_x_Line_Scredit_rec.LAST_UPDATED_BY := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.LAST_UPDATE_DATE = FND_API.G_MISS_DATE THEN
      p_x_Line_Scredit_rec.LAST_UPDATE_DATE := NULL;
    END IF;


    IF p_x_Line_Scredit_rec.LAST_UPDATE_LOGIN = FND_API.G_MISS_NUM THEN
      p_x_Line_Scredit_rec.LAST_UPDATE_LOGIN := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.LINE_ID = FND_API.G_MISS_NUM THEN
      p_x_Line_Scredit_rec.LINE_ID := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.LOCK_CONTROL = FND_API.G_MISS_NUM THEN
      p_x_Line_Scredit_rec.LOCK_CONTROL := NULL;
    END IF;


    IF p_x_Line_Scredit_rec.ORIG_SYS_CREDIT_REF = FND_API.G_MISS_CHAR THEN
      p_x_Line_Scredit_rec.ORIG_SYS_CREDIT_REF := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.PERCENT = FND_API.G_MISS_NUM THEN
      p_x_Line_Scredit_rec.PERCENT := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.SALESREP_ID = FND_API.G_MISS_NUM THEN
      p_x_Line_Scredit_rec.SALESREP_ID := NULL;
    END IF;


    IF p_x_Line_Scredit_rec.SALES_CREDIT_ID = FND_API.G_MISS_NUM THEN

      p_x_Line_Scredit_rec.SALES_CREDIT_ID := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.SALES_CREDIT_TYPE_ID = FND_API.G_MISS_NUM THEN
      p_x_Line_Scredit_rec.SALES_CREDIT_TYPE_ID := NULL;
    END IF;

    IF p_x_Line_Scredit_rec.WH_UPDATE_DATE = FND_API.G_MISS_DATE THEN

      p_x_Line_Scredit_rec.WH_UPDATE_DATE := NULL;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_CNCL_UTIL.CONVERT_MISS_TO_NULL: LINE SCREDIT' , 1 ) ;
    END IF;
END;


END OE_CNCL_UTIL;

/
