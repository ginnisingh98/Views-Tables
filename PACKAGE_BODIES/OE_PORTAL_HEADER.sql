--------------------------------------------------------
--  DDL for Package Body OE_PORTAL_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PORTAL_HEADER" AS
/* $Header: OEXHPORB.pls 120.0 2005/06/01 01:56:56 appldev noship $ */

G_PKG_NAME            CONSTANT VARCHAR2(30) := 'OE_Portal_Header';

Procedure Write_Header
(    p_header_rec       IN OE_ORDER_PUB.Header_Rec_Type
,    p_db_record        IN BOOLEAN := FALSE
);


PROCEDURE  Get_header
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_header_id                     IN  NUMBER
,   x_header_rec                    OUT NOCOPY OE_Order_PUB.Header_Rec_Type
);

PROCEDURE Clear_header;



PROCEDURE Default_Header_Attributes
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_sold_to_org_id                IN NUMBER
, x_agreement_id OUT NOCOPY NUMBER

, x_freight_carrier_code OUT NOCOPY VARCHAR2

, x_freight_terms_code OUT NOCOPY VARCHAR2

--, x_header_id            OUT NUMBER
, x_header_id OUT NOCOPY VARCHAR2

, x_invoice_to_org_id OUT NOCOPY NUMBER

, x_order_type_id OUT NOCOPY NUMBER

, x_org_id OUT NOCOPY NUMBER

, x_partial_shipments_allowed OUT NOCOPY VARCHAR2

, x_payment_term_id OUT NOCOPY NUMBER

, x_price_list_id OUT NOCOPY NUMBER

, x_shipment_priority_code OUT NOCOPY VARCHAR2

, x_shipping_method_code OUT NOCOPY VARCHAR2

, x_ship_to_org_id OUT NOCOPY NUMBER

, x_sold_to_org_id OUT NOCOPY NUMBER

, x_tax_exempt_flag OUT NOCOPY VARCHAR2

, x_tax_exempt_number OUT NOCOPY VARCHAR2

, x_tax_point_code OUT NOCOPY VARCHAR2

, x_transactional_curr_code OUT NOCOPY VARCHAR2

, x_payment_type_code OUT NOCOPY VARCHAR2

, x_shipping_instructions OUT NOCOPY VARCHAR2

, x_shipping_method OUT NOCOPY VARCHAR2

, x_freight_terms OUT NOCOPY VARCHAR2

, x_invoice_to_address1 OUT NOCOPY VARCHAR2

, x_invoice_to_address2 OUT NOCOPY VARCHAR2

, x_invoice_to_address3 OUT NOCOPY VARCHAR2

, x_invoice_to_address4 OUT NOCOPY VARCHAR2

, x_payment_term OUT NOCOPY VARCHAR2

, x_shipment_priority OUT NOCOPY varchar2

, x_ship_to_address1 OUT NOCOPY VARCHAR2

, x_ship_to_address2 OUT NOCOPY VARCHAR2

, x_ship_to_address3 OUT NOCOPY VARCHAR2

, x_ship_to_address4 OUT NOCOPY VARCHAR2

, x_sold_to_org OUT NOCOPY VARCHAR2

, x_tax_point OUT NOCOPY VARCHAR2

,x_request_date OUT NOCOPY DATE

, x_tax_exempt OUT NOCOPY VARCHAR2

, x_partial_shipments OUT NOCOPY VARCHAR2

, x_order_type OUT NOCOPY VARCHAR2

, x_customer_number OUT NOCOPY VARCHAR2

) IS
    l_header_rec                    OE_Order_PUB.Header_Rec_Type;
    l_header_val_rec                OE_Order_PUB.Header_Val_Rec_Type;
    l_old_header_rec                OE_Order_PUB.Header_Rec_Type;
    l_control_rec                   OE_GLOBALS.Control_Rec_Type;
    l_return_status                 VARCHAR2(1);
    --
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --
BEGIN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_PORTAL_HEADER.DEFAULT_HEADER_ATTRIBUTES' , 1 ) ;
    END IF;

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'ESHAS TEST' ) ;
 END IF;

    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.check_security       := TRUE;
    l_control_rec.default_attributes   := TRUE;
   -- l_control_rec.change_attributes    := TRUE;
    l_control_rec.change_attributes    := FALSE;

    l_control_rec.clear_dependents     := TRUE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Load IN parameters if any exist

    l_old_header_rec   :=OE_ORDER_PUB.G_MISS_HEADER_REC;
    l_header_rec       :=OE_ORDER_PUB.G_MISS_HEADER_REC;
    l_header_rec.sold_to_org_id := p_sold_to_org_id;
    l_header_val_rec   :=OE_ORDER_PUB.G_MISS_HEADER_VAL_REC;

    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

    l_header_rec.attribute1                       := NULL;
    l_header_rec.attribute10                      := NULL;
    l_header_rec.attribute11                      := NULL;
    l_header_rec.attribute12                      := NULL;
    l_header_rec.attribute13                      := NULL;
    l_header_rec.attribute14                      := NULL;
    l_header_rec.attribute15                      := NULL;
    l_header_rec.attribute2                       := NULL;
    l_header_rec.attribute3                       := NULL;
    l_header_rec.attribute4                       := NULL;
    l_header_rec.attribute5                       := NULL;
    l_header_rec.attribute6                       := NULL;
    l_header_rec.attribute7                       := NULL;
    l_header_rec.attribute8                       := NULL;
    l_header_rec.attribute9                       := NULL;
    l_header_rec.context                          := NULL;
    l_header_rec.global_attribute1                := NULL;
    l_header_rec.global_attribute10               := NULL;
    l_header_rec.global_attribute11               := NULL;
    l_header_rec.global_attribute12               := NULL;
    l_header_rec.global_attribute13               := NULL;
    l_header_rec.global_attribute14               := NULL;
    l_header_rec.global_attribute15               := NULL;
    l_header_rec.global_attribute16               := NULL;
    l_header_rec.global_attribute17               := NULL;
    l_header_rec.global_attribute18               := NULL;
    l_header_rec.global_attribute19               := NULL;
    l_header_rec.global_attribute2                := NULL;
    l_header_rec.global_attribute20               := NULL;
    l_header_rec.global_attribute3                := NULL;
    l_header_rec.global_attribute4                := NULL;
    l_header_rec.global_attribute5                := NULL;
    l_header_rec.global_attribute6                := NULL;
    l_header_rec.global_attribute7                := NULL;
    l_header_rec.global_attribute8                := NULL;
    l_header_rec.global_attribute9                := NULL;
    l_header_rec.global_attribute_category        := NULL;
    l_header_rec.tp_context                       := NULL;
    l_header_rec.tp_attribute1                    := NULL;
    l_header_rec.tp_attribute2                    := NULL;
    l_header_rec.tp_attribute3                    := NULL;
    l_header_rec.tp_attribute4                    := NULL;
    l_header_rec.tp_attribute5                    := NULL;
    l_header_rec.tp_attribute6                    := NULL;
    l_header_rec.tp_attribute7                    := NULL;
    l_header_rec.tp_attribute8                    := NULL;
    l_header_rec.tp_attribute9                    := NULL;
    l_header_rec.tp_attribute10                   := NULL;
    l_header_rec.tp_attribute11                   := NULL;
    l_header_rec.tp_attribute12                   := NULL;
    l_header_rec.tp_attribute13                   := NULL;
    l_header_rec.tp_attribute14                   := NULL;
    l_header_rec.tp_attribute15                   := NULL;

    --  Set Operation to Create

    l_header_rec.operation := OE_GLOBALS.G_OPR_CREATE;

    --  Call Oe_Order_Pvt.Header

    Oe_Order_Pvt.Header
    (    p_validation_level    =>FND_API.G_VALID_LEVEL_NONE
    ,    p_init_msg_list       => FND_API.G_TRUE
    ,    p_control_rec         =>l_control_rec
    ,    p_x_header_rec        =>l_header_rec
    ,    p_x_old_header_rec    =>l_old_header_rec
    ,    x_return_status       =>l_return_status
    );

    IF l_return_status  = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'L_HEADER_REC.TAX_EXEMPT_FLAG ' || L_HEADER_REC.TAX_EXEMPT_FLAG ) ;
    END IF;
    --  Load OUT parameters.

    l_header_val_rec := OE_Header_Util.Get_Values
    (   p_header_rec                  => l_header_rec
    );

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_header_rec.db_flag := FND_API.G_FALSE;

    Write_header
    (   p_header_rec                  => l_header_rec
    );


    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


x_request_date := l_header_rec.request_date;
x_agreement_id := l_header_rec.agreement_id;
x_freight_carrier_code := l_header_rec.freight_carrier_code;
x_freight_terms_code := l_header_rec.freight_terms_code;
x_header_id := l_header_rec.header_id;
x_invoice_to_org_id := l_header_rec.invoice_to_org_id;
x_order_type_id := l_header_rec.order_type_id;
x_org_id := l_header_rec.org_id;
x_partial_shipments_allowed := l_header_rec.partial_shipments_allowed;
x_payment_term_id := l_header_rec.payment_term_id;
x_price_list_id := l_header_rec.price_list_id;
x_shipment_priority_code := l_header_rec.shipment_priority_code;
x_shipping_method_code := l_header_rec.shipping_method_code;
x_ship_to_org_id := l_header_rec.ship_to_org_id;
x_sold_to_org_id := l_header_rec.sold_to_org_id;
x_tax_exempt_flag := l_header_rec.tax_exempt_flag;
x_tax_exempt_number := l_header_rec.tax_exempt_number;
x_tax_point_code := l_header_rec.tax_point_code;
x_transactional_curr_code := l_header_rec.transactional_curr_code;
x_payment_type_code := l_header_rec.payment_type_code;
x_shipping_instructions := l_header_rec.shipping_instructions;

x_freight_terms := l_header_val_rec.freight_terms;
x_invoice_to_address1 := l_header_val_rec.invoice_to_address1;
x_invoice_to_address2 := l_header_val_rec.invoice_to_address2;
x_invoice_to_address3 := l_header_val_rec.invoice_to_address3;
x_invoice_to_address4 := l_header_val_rec.invoice_to_address4;
x_payment_term := l_header_val_rec.payment_term;
x_shipment_priority := l_header_val_rec.shipment_priority;
x_ship_to_address1 := l_header_val_rec.ship_to_address1;
x_ship_to_address2 := l_header_val_rec.ship_to_address2;
x_ship_to_address3 := l_header_val_rec.ship_to_address3;
x_ship_to_address4 := l_header_val_rec.ship_to_address4;
x_sold_to_org := l_header_val_rec.sold_to_org;
x_tax_point := l_header_val_rec.tax_point;
x_shipping_method := l_header_val_rec.shipping_method;
x_tax_exempt := l_header_val_rec.tax_exempt;
x_order_type := l_header_val_rec.order_type;
x_customer_number := l_header_val_rec.customer_number;
if upper(x_partial_shipments_allowed) = 'Y' then
   x_partial_shipments := 'Yes';
elsif upper(x_partial_shipments_allowed) = 'N' then
   x_partial_shipments := 'No';
end if;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING OE_PORTAL_HEADER.DEFAULT_ATTRIBUTES' , 1 ) ;
   END IF;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Default__Header_Attributes'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );




END;


PROCEDURE Validate_Write_Header
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_header_id                     IN  NUMBER
, p_db_record                       IN  VARCHAR2
, p_freight_terms_code   IN VARCHAR2
, p_invoice_to_org_id    IN NUMBER
, p_partial_shipments_allowed IN VARCHAR2
, p_shipment_priority_code IN  VARCHAR2
, p_shipping_method_code  IN  VARCHAR2
, p_ship_to_org_id        IN NUMBER
, p_tax_exempt_flag      IN VARCHAR2
, p_request_date         IN  VARCHAR2
, p_cust_po_number       IN VARCHAR2
, p_shipping_instructions IN VARCHAR2
, p_sold_to_org_id        IN NUMBER
, x_order_number OUT NOCOPY NUMBER

, x_agreement_id OUT NOCOPY NUMBER

, x_freight_carrier_code OUT NOCOPY VARCHAR2

, x_freight_terms_code OUT NOCOPY VARCHAR2

, x_header_id OUT NOCOPY NUMBER

, x_invoice_to_org_id OUT NOCOPY NUMBER

, x_order_type_id OUT NOCOPY NUMBER

, x_org_id OUT NOCOPY NUMBER

, x_partial_shipments_allowed OUT NOCOPY VARCHAR2

, x_payment_term_id OUT NOCOPY NUMBER

, x_price_list_id OUT NOCOPY NUMBER

, x_shipment_priority_code OUT NOCOPY VARCHAR2

, x_shipping_method_code OUT NOCOPY VARCHAR2

, x_ship_to_org_id OUT NOCOPY NUMBER

, x_sold_to_org_id OUT NOCOPY NUMBER

, x_tax_exempt_flag OUT NOCOPY VARCHAR2

, x_tax_exempt_number OUT NOCOPY VARCHAR2

, x_tax_point_code OUT NOCOPY VARCHAR2

, x_transactional_curr_code OUT NOCOPY VARCHAR2

, x_payment_type_code OUT NOCOPY VARCHAR2

, x_shipping_instructions OUT NOCOPY VARCHAR2

, x_shipping_method OUT NOCOPY VARCHAR2

, x_freight_terms OUT NOCOPY VARCHAR2

, x_invoice_to_address1 OUT NOCOPY VARCHAR2

, x_invoice_to_address2 OUT NOCOPY VARCHAR2

, x_invoice_to_address3 OUT NOCOPY VARCHAR2

, x_invoice_to_address4 OUT NOCOPY VARCHAR2

, x_payment_term OUT NOCOPY VARCHAR2

, x_shipment_priority OUT NOCOPY varchar2

, x_ship_to_address1 OUT NOCOPY VARCHAR2

, x_ship_to_address2 OUT NOCOPY VARCHAR2

, x_ship_to_address3 OUT NOCOPY VARCHAR2

, x_ship_to_address4 OUT NOCOPY VARCHAR2

, x_sold_to_org OUT NOCOPY VARCHAR2

, x_tax_point OUT NOCOPY VARCHAR2

, x_request_date OUT NOCOPY DATE

, x_cust_po_number OUT NOCOPY VARCHAR2

, x_tax_exempt OUT NOCOPY VARCHAR2

, x_partial_shipments OUT NOCOPY VARCHAR2

, x_order_type OUT NOCOPY VARCHAR2

, x_customer_number OUT NOCOPY VARCHAR2

/*, x_cascade_flag OUT NOCOPY VARCHAR2*/

)
IS
l_db_record                   BOOLEAN;
l_cascade_flag                BOOLEAN;
l_lock_control                NUMBER;
l_x_old_header_rec            OE_Order_PUB.Header_Rec_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_header_val_rec            OE_Order_Pub.Header_Val_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    SAVEPOINT Header_Validate_And_Write;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_PORTAL_HEADER.VALIDATE_WRITE_HEADER' , 1 ) ;
        oe_debug_pub.add(  'HEADER ID' || P_HEADER_ID , 1 ) ;
        oe_debug_pub.add(  'DB FLAG' || P_DB_RECORD , 1 ) ;
    END IF;

    if p_db_record = 'Y' THEN
	  l_db_record := TRUE;
    else
	  l_db_record := FALSE;
    END IF;

    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.check_security       := TRUE;
    l_control_rec.clear_dependents     := TRUE;
    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := TRUE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    l_x_old_header_rec := OE_ORDER_PUB.G_MISS_HEADER_REC;

	Get_header
    (   p_db_record                   => l_db_record
    ,   p_header_id                   => p_header_id
    ,   x_header_rec                  => l_x_header_rec
    );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'HEADER ID' || L_X_HEADER_REC.HEADER_ID , 1 ) ;
    END IF;

   if p_freight_terms_code is not null then
    l_x_header_rec.freight_terms_code :=  p_freight_terms_code;
    end if;
   if p_invoice_to_org_id is not null then
    l_x_header_rec.invoice_to_org_id :=  p_invoice_to_org_id;
    end if;
   if p_partial_shipments_allowed is not null then
    l_x_header_rec.partial_shipments_allowed :=  p_partial_shipments_allowed;
    end if;
   if p_shipment_priority_code is not null then
    l_x_header_rec.shipment_priority_code :=  p_shipment_priority_code;
    end if;
   if p_shipping_method_code is not null then
    l_x_header_rec.shipping_method_code :=  p_shipping_method_code;
    end if;
   if p_ship_to_org_id is not null then
    l_x_header_rec.ship_to_org_id := p_ship_to_org_id;
    end if;
   if p_tax_exempt_flag is not null then
  l_x_header_rec.tax_exempt_flag :=  p_tax_exempt_flag;
  end if;
   if p_request_date is not null then
   l_x_header_rec.request_date :=  fnd_date.canonical_to_date(p_request_date);
   end if;
   if p_cust_po_number is not null then
    l_x_header_rec.cust_po_number :=  p_cust_po_number;
    end if;
   if p_shipping_instructions is not null then
    l_x_header_rec.shipping_instructions :=  p_shipping_instructions;
   end if;

   if p_sold_to_org_id is not null then
    l_x_header_rec.sold_to_org_id := p_sold_to_org_id;
   end if;
    --  Set Operation.

    IF FND_API.To_Boolean(l_x_header_rec.db_flag) THEN
        l_x_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;

	   /* Start Audit Trail - if it is update, set reason,comments */
	   l_x_header_rec.change_reason := 'SYSTEM';
	   /* End Audit Trail */
    ELSE
        l_x_header_rec.operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Call Oe_Order_Pvt.Header

    Oe_Order_Pvt.Header
    (   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                  => l_x_header_rec
    ,   p_x_old_header_rec              => l_x_old_header_rec
    ,   x_return_status               =>  l_return_status
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'L_X_HEADER_REC.TAX_EXEMPT_FLA_G ' || L_X_HEADER_REC.TAX_EXEMPT_FLAG ) ;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'HEADER ID' || L_X_HEADER_REC.HEADER_ID , 1 ) ;
    END IF;
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    Oe_Order_Pvt.Process_Requests_And_Notify
    (   p_process_requests           => FALSE
    ,   p_init_msg_list               => FND_API.G_FALSE
     ,  p_notify                     => TRUE
	,  x_return_status              => l_return_status
	,  p_header_rec                 => l_x_header_rec
	,  p_old_header_rec             => l_x_old_header_rec
    );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'L_HEADER_REC.TAX_EXEMPT_FLAG ' || L_X_HEADER_REC.TAX_EXEMPT_FLAG ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_cascade_flag := OE_GLOBALS.G_CASCADING_REQUEST_LOGGED;


  /*  IF l_cascade_flag THEN
	  x_cascade_flag := 'Y';
    ELSE
	  x_cascade_flag := 'N';
    END IF;
*/

    --  Load OUT parameters.

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'L_HEADER_REC.TAX_EXEMPT_FLAG ' || L_X_HEADER_REC.TAX_EXEMPT_FLAG ) ;
    END IF;

    x_order_number                 := l_x_header_rec.order_number;
    l_lock_control                 := l_x_header_rec.lock_control;

    IF l_cascade_flag  then
	Get_header
    (   p_db_record                   => TRUE
    ,   p_header_id                   => p_header_id
    ,   x_header_rec                  => l_x_header_rec
    );
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'HEADER ID' || L_X_HEADER_REC.HEADER_ID , 1 ) ;
    END IF;

    l_header_val_rec := OE_Header_Util.Get_Values
    (   p_header_rec                  => l_x_header_rec
    );

x_request_date := l_x_header_rec.request_date;
x_agreement_id := l_x_header_rec.agreement_id;
x_freight_carrier_code := l_x_header_rec.freight_carrier_code;
x_freight_terms_code := l_x_header_rec.freight_terms_code;
x_header_id := l_x_header_rec.header_id;
x_invoice_to_org_id := l_x_header_rec.invoice_to_org_id;
x_order_type_id := l_x_header_rec.order_type_id;
x_org_id := l_x_header_rec.org_id;
x_partial_shipments_allowed := l_x_header_rec.partial_shipments_allowed;
x_payment_term_id := l_x_header_rec.payment_term_id;
x_price_list_id := l_x_header_rec.price_list_id;
x_shipment_priority_code := l_x_header_rec.shipment_priority_code;
x_shipping_method_code := l_x_header_rec.shipping_method_code;
x_ship_to_org_id := l_x_header_rec.ship_to_org_id;
x_sold_to_org_id := l_x_header_rec.sold_to_org_id;
x_tax_exempt_flag := l_x_header_rec.tax_exempt_flag;
x_tax_exempt_number := l_x_header_rec.tax_exempt_number;
x_tax_point_code := l_x_header_rec.tax_point_code;
x_transactional_curr_code := l_x_header_rec.transactional_curr_code;
x_payment_type_code := l_x_header_rec.payment_type_code;
x_shipping_instructions := l_x_header_rec.shipping_instructions;

x_freight_terms := l_header_val_rec.freight_terms;
x_invoice_to_address1 := l_header_val_rec.invoice_to_address1;
x_invoice_to_address2 := l_header_val_rec.invoice_to_address2;
x_invoice_to_address3 := l_header_val_rec.invoice_to_address3;
x_invoice_to_address4 := l_header_val_rec.invoice_to_address4;
x_payment_term := l_header_val_rec.payment_term;
x_shipment_priority := l_header_val_rec.shipment_priority;
x_ship_to_address1 := l_header_val_rec.ship_to_address1;
x_ship_to_address2 := l_header_val_rec.ship_to_address2;
x_ship_to_address3 := l_header_val_rec.ship_to_address3;
x_ship_to_address4 := l_header_val_rec.ship_to_address4;
x_sold_to_org := l_header_val_rec.sold_to_org;
x_tax_point := l_header_val_rec.tax_point;
x_shipping_method := l_header_val_rec.shipping_method;
x_customer_number := l_header_val_rec.customer_number;
x_tax_exempt := l_header_val_rec.tax_exempt;
x_order_type := l_header_val_rec.order_type;

if upper(x_partial_shipments_allowed) = 'Y' then
   x_partial_shipments := 'Yes';
elsif upper(x_partial_shipments_allowed) = 'N' then
   x_partial_shipments := 'No';
end if;
    --  Clear header record cache
    Clear_Header;

    --  Keep track of performed operations.
--  l_x_old_header_rec.operation := l_x_header_rec.operation;

    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RETURN STATUS'|| X_RETURN_STATUS , 1 ) ;
        oe_debug_pub.add(  'HEADER_ID'|| X_HEADER_ID , 1 ) ;
        oe_debug_pub.add(  'EXITING OE_PORTAL_HEADER.VALIDATE_WRITE_HEADER' , 1 ) ;
    END IF;

/*
oe_debug_pub.add('no. of OE messages :'||x_msg_count,1);
dbms_output.put_line('no. of OE messages :'||x_msg_count);
for k in 1 .. x_msg_count loop
        x_msg_data := oe_msg_pub.get( p_msg_index => k,
                        p_encoded => 'F'
                        );
oe_debug_pub.add(substr(x_msg_data,1,255));
        dbms_output.put_line('Error msg: '||substr(x_msg_data,1,2000));
end loop;

fnd_msg_pub.count_and_get( p_encoded    => 'F'
                         , p_count      => x_msg_count
                        , p_data        => x_msg_data);
oe_debug_pub.add('no. of FND messages :'||x_msg_count,1);
dbms_output.put_line('no. of FND messages :'||x_msg_count);
for k in 1 .. x_msg_count loop
       x_msg_data := fnd_msg_pub.get( p_msg_index => k,
                        p_encoded => 'F'
                        );
        dbms_output.put_line('Error msg: '||substr(x_msg_data,1,200));
oe_debug_pub.add(substr(x_msg_data,1,255));

end loop;
*/
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        ROLLBACK TO SAVEPOINT Header_Validate_And_Write;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        ROLLBACK TO SAVEPOINT Header_Validate_And_Write;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        ROLLBACK TO SAVEPOINT Header_Validate_And_Write;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_And_Write'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Validate_Write_Header;


PROCEDURE Delete_Row
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_header_id                     IN  NUMBER
)
IS
l_x_old_header_rec                  OE_Order_PUB.Header_Rec_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_HEADER.DELETE_ROW' , 1 ) ;
    END IF;

    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.check_security       := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.clear_dependents     := FALSE;
    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read DB record from cache

     Get_header
    (   p_db_record                   => TRUE
    ,   p_header_id                   => p_header_id
    ,   x_header_rec                  => l_x_header_rec
    );

    --  Set Operation.

    l_x_header_rec.operation := OE_GLOBALS.G_OPR_DELETE;

    --  Call Oe_Order_Pvt.Header

    Oe_Order_Pvt.Header
    (   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                  => l_x_header_rec
    ,   p_x_old_header_rec            => l_x_old_header_rec
    ,   x_return_status               => l_return_status
    );


    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN


    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.check_security       := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.clear_dependents     := TRUE;
    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := TRUE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    l_x_old_header_rec := OE_ORDER_PUB.G_MISS_HEADER_REC;
    l_x_header_rec.cancelled_flag := 'Y';
    --  Set Operation.

    l_x_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;

    --  Call Oe_Order_Pvt.Header

    Oe_Order_Pvt.Header
    (   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                  => l_x_header_rec
    ,   p_x_old_header_rec            => l_x_old_header_rec
    ,   x_return_status               => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;



    END IF;


    --  Clear header record cache

    Clear_header;

    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_HEADER.DELETE_ROW' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Delete_Row;



PROCEDURE GET_HEADER_TOTALS
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_header_id                     IN  NUMBER
, x_line_total OUT NOCOPY NUMBER

, x_tax_total OUT NOCOPY NUMBER

, x_charge_total OUT NOCOPY NUMBER

, x_order_total OUT NOCOPY NUMBER

)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF p_header_id is NULL OR p_header_id = FND_API.G_MISS_NUM THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_CONFIG_PARAMETER_REQUIRED');
            FND_MESSAGE.SET_TOKEN('PARAMETER','Header_Id');
            OE_MSG_PUB.Add;

        END IF;
        RAISE FND_API.G_EXC_ERROR;

    END IF;


   x_line_total := OE_Totals_Grp.Get_Order_Total(p_header_id,
                                                 null,
									    'LINES');

   x_tax_total := OE_Totals_Grp.Get_Order_Total(p_header_id,
									   null,
									   'TAXES');

    x_charge_total := OE_Totals_Grp.Get_Order_Total(p_header_id,
									   null,
									   'CHARGES');

    x_order_total := OE_Totals_Grp.Get_Order_Total(p_header_id,
									   null,
									   'ALL');


    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_PORTAL_HEADER.GET_ORDER_TOTALS' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Header_Totals;


PROCEDURE Get_header
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_header_id                     IN  NUMBER
,   x_header_rec                    OUT NOCOPY OE_Order_PUB.Header_Rec_Type
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_PORTAL_HEADER.GET_HEADER' , 1 ) ;
        oe_debug_pub.add(  'CACHED HEADER ID ' || G_HEADER_REC.HEADER_ID , 1 ) ;
    END IF;

    IF  p_header_id <> NVL(g_header_rec.header_id,FND_API.G_MISS_NUM)
    THEN

        --  Query row from DB

         OE_Header_Util.Query_Row
        (   p_header_id                   => p_header_id,
		  x_header_rec                  =>g_header_rec
        );

        g_header_rec.db_flag           := FND_API.G_TRUE;

        --  Load DB record

        g_db_header_rec                := g_header_rec;

    END IF;

    IF p_db_record THEN

        x_header_rec:= g_db_header_rec;

    ELSE

        x_header_rec:= g_header_rec;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_PORTAL_HEADER.GET_HEADER' , 1 ) ;
    END IF;

END Get_Header;

PROCEDURE Clear_Header
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_PORTAL_HEADER.CLEAR_HEADER' , 1 ) ;
    END IF;

    g_header_rec                   := OE_Order_PUB.G_MISS_HEADER_REC;
    g_db_header_rec                := OE_Order_PUB.G_MISS_HEADER_REC;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_PORTAL_HEADER.CLEAR_HEADER' , 1 ) ;
    END IF;

END Clear_Header;



PROCEDURE Write_header
(   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_PORTAL_HEADER.WRITE_HEADER' , 1 ) ;
    END IF;

    g_header_rec := p_header_rec;

    IF p_db_record THEN

        g_db_header_rec := p_header_rec;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_PORTAL_HEADER.WRITE_HEADER' , 1 ) ;
        oe_debug_pub.add(  'G_HEADER_REC.HEADER_ID ' || G_HEADER_REC.HEADER_ID , 1 ) ;
    END IF;
END Write_Header;


END OE_Portal_Header;

/
