--------------------------------------------------------
--  DDL for Package Body OE_OE_FORM_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_FORM_HEADER" AS
/* $Header: OEXFHDRB.pls 120.14.12010000.4 2009/12/08 12:10:34 msundara ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'Oe_Oe_Form_Header';

--  Global variables holding cached record.

g_header_rec                  OE_Order_PUB.Header_Rec_Type;
g_db_header_rec               OE_Order_PUB.Header_Rec_Type;
g_set_of_books_rec            Set_Of_Books_Rec_Type;
--  Forward declaration of procedures maintaining entity record cache.

-- Following record will be used to store the cascading enabled or disabled
-- status for each field.

g_cascade_test_record         OE_OE_FORM_HEADER.Cascade_record;

PROCEDURE Write_header
(   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

PROCEDURE  Get_header
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_header_id                     IN  NUMBER
,   x_header_rec                    OUT NOCOPY OE_Order_PUB.Header_Rec_Type
);


FUNCTION Filter_Phone_Number (
    p_phone_number                IN     VARCHAR2,
    p_isformat                    IN     NUMBER := 0
  ) RETURN VARCHAR2 ;


PROCEDURE get_customer_details ( p_site_use_id IN NUMBER,
                                 p_site_use_code IN VARCHAR2,
x_customer_id OUT NOCOPY NUMBER,
x_customer_name OUT NOCOPY VARCHAR2,
x_customer_number OUT NOCOPY VARCHAR2
                                   );

PROCEDURE Clear_header;

--  Global variable holding performed operations.

g_opr__tbl                    OE_Order_PUB.Header_Tbl_Type;

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   x_header_rec                    IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type
,   x_header_val_rec                IN OUT NOCOPY OE_ORDER_PUB.Header_Val_Rec_Type
,   x_old_header_rec                IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type
,   p_transaction_phase_code        IN VARCHAR2
)
IS
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
BEGIN
    oe_debug_pub.add('Entering OE_OE_FORM_HEADER.DEFAULT_ATTRIBUTES', 1);



    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.check_security       := TRUE;
    l_control_rec.default_attributes   := TRUE;
    l_control_rec.change_attributes    := TRUE;

    l_control_rec.clear_dependents     := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Load IN parameters if any exist

    -- Bug 3433343 Begin
    Clear_Header;
    -- Bug 3433343 End
    x_old_header_rec   :=OE_ORDER_PUB.G_MISS_HEADER_REC;
    x_header_rec       :=OE_ORDER_PUB.G_MISS_HEADER_REC;
    x_header_val_rec   :=OE_ORDER_PUB.G_MISS_HEADER_VAL_REC;

    --kmuruges
      IF p_transaction_phase_code = 'N' THEN
       x_header_rec.transaction_phase_code         := p_transaction_phase_code;
      END IF;
    --kmuruges end

    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

    x_header_rec.attribute1                       := NULL;
    x_header_rec.attribute10                      := NULL;
    x_header_rec.attribute11                      := NULL;
    x_header_rec.attribute12                      := NULL;
    x_header_rec.attribute13                      := NULL;
    x_header_rec.attribute14                      := NULL;
    x_header_rec.attribute15                      := NULL;
    x_header_rec.attribute2                       := NULL;
    x_header_rec.attribute3                       := NULL;
    x_header_rec.attribute4                       := NULL;
    x_header_rec.attribute5                       := NULL;
    x_header_rec.attribute6                       := NULL;
    x_header_rec.attribute7                       := NULL;
    x_header_rec.attribute8                       := NULL;
    x_header_rec.attribute9                       := NULL;
    x_header_rec.context                          := NULL;
    x_header_rec.global_attribute1                := NULL;
    x_header_rec.global_attribute10               := NULL;
    x_header_rec.global_attribute11               := NULL;
    x_header_rec.global_attribute12               := NULL;
    x_header_rec.global_attribute13               := NULL;
    x_header_rec.global_attribute14               := NULL;
    x_header_rec.global_attribute15               := NULL;
    x_header_rec.global_attribute16               := NULL;
    x_header_rec.global_attribute17               := NULL;
    x_header_rec.global_attribute18               := NULL;
    x_header_rec.global_attribute19               := NULL;
    x_header_rec.global_attribute2                := NULL;
    x_header_rec.global_attribute20               := NULL;
    x_header_rec.global_attribute3                := NULL;
    x_header_rec.global_attribute4                := NULL;
    x_header_rec.global_attribute5                := NULL;
    x_header_rec.global_attribute6                := NULL;
    x_header_rec.global_attribute7                := NULL;
    x_header_rec.global_attribute8                := NULL;
    x_header_rec.global_attribute9                := NULL;
    x_header_rec.global_attribute_category        := NULL;
    x_header_rec.tp_context                       := NULL;
    x_header_rec.tp_attribute1                    := NULL;
    x_header_rec.tp_attribute2                    := NULL;
    x_header_rec.tp_attribute3                    := NULL;
    x_header_rec.tp_attribute4                    := NULL;
    x_header_rec.tp_attribute5                    := NULL;
    x_header_rec.tp_attribute6                    := NULL;
    x_header_rec.tp_attribute7                    := NULL;
    x_header_rec.tp_attribute8                    := NULL;
    x_header_rec.tp_attribute9                    := NULL;
    x_header_rec.tp_attribute10                   := NULL;
    x_header_rec.tp_attribute11                   := NULL;
    x_header_rec.tp_attribute12                   := NULL;
    x_header_rec.tp_attribute13                   := NULL;
    x_header_rec.tp_attribute14                   := NULL;
    x_header_rec.tp_attribute15                   := NULL;

    --  Set Operation to Create

    x_header_rec.operation := OE_GLOBALS.G_OPR_CREATE;

    --  Call Oe_Order_Pvt.Header

    Oe_Order_Pvt.Header
    (    p_validation_level    =>FND_API.G_VALID_LEVEL_NONE
    ,    p_init_msg_list       => FND_API.G_TRUE
    ,    p_control_rec         =>l_control_rec
    ,    p_x_header_rec        =>x_header_rec
    ,    p_x_old_header_rec    =>x_old_header_rec
    ,    x_return_status       =>l_return_status

    );

    IF l_return_status  = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT NOCOPY /* file.sql.39 change */ parameters.

    x_header_val_rec := OE_Header_Util.Get_Values
    (   p_header_rec                  => x_header_rec
    );

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    x_header_rec.db_flag := FND_API.G_FALSE;

    Write_header
    (   p_header_rec                  => x_header_rec
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

    oe_debug_pub.add('Exiting OE_OE_FORM_HEADER.DEFAULT_ATTRIBUTES', 1);

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
            ,   'Default_Attributes'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Default_Attributes;

--  Procedure   :   Change_Attribute
--


PROCEDURE Change_Attribute
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
,   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   p_attr_id_tbl                   IN  Number_Tbl_Type
,   p_attr_value_tbl                IN  Varchar2_Tbl_Type
,   p_header_dff_rec                IN  Oe_Oe_Form_Header.Header_Dff_Rec_Type
,   p_date_format_mask            IN  VARCHAR2 DEFAULT 'DD-MON-RRRR HH24:MI:SS'
,   x_header_rec                  IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type
,   x_header_val_rec              IN OUT NOCOPY OE_ORDER_PUB.Header_Val_Rec_Type
,   x_old_header_rec              IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type

)
IS
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_date_format_mask            VARCHAR2(30) := p_date_format_mask;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
template_id NUMBER := x_header_rec.contract_template_id;
BEGIN

    oe_debug_pub.add('Entering OE_OE_FORM_HEADER.CHANGE_ATTRIBUTES', 1);
    oe_debug_pub.add('hash template id in change att start is '|| x_header_rec.contract_template_id);
    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.check_security       := TRUE;
    l_control_rec.clear_dependents     := TRUE;
    l_control_rec.default_attributes   := TRUE;
    l_control_rec.change_attributes    := TRUE;

    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read header from cache

    Get_header
    (   p_db_record                   => FALSE
    ,   p_header_id                   => p_header_id
    ,   x_header_rec                  => x_header_rec
    );
    oe_debug_pub.add('hash template id in change att after get_header is '|| x_header_rec.contract_template_id);
    x_header_rec.contract_template_id :=template_id;
    x_old_header_rec               := x_header_rec;

    IF OE_CODE_CONTROL.Code_Release_Level >= '110509' THEN

     IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'Code Release is >= 11.5.9') ;
     END IF;


     Copy_Attribute_To_Rec
                (p_attr_id         => p_attr_id
                ,p_attr_value      => p_attr_value
                ,p_header_dff_rec    => p_header_dff_rec
                ,p_date_format_mask  => p_date_format_mask
                ,x_header_rec        => x_header_rec
                ,x_old_header_rec    => x_old_header_rec
                );

     FOR l_index IN 1..p_attr_id_tbl.COUNT LOOP

           Copy_Attribute_To_Rec
                (p_attr_id         => p_attr_id_tbl(l_index)
                ,p_attr_value      => p_attr_value_tbl(l_index)
                ,p_header_dff_rec    => p_header_dff_rec
                ,p_date_format_mask  => p_date_format_mask
                ,x_header_rec        => x_header_rec
                ,x_old_header_rec    => x_old_header_rec
                );

     END LOOP;
   END IF;


    -- PLEASE ADD THIS IF LOGIC FOR NEW ATTRIBUTES TO THE PROCEDURE
    -- COPY_ATTRIBUTE_TO_REC ALSO. THIS NEW PROCEDURE WILL REPLACE
    -- THESE CALLS POST OM PACK I OR 11.5.9.


    oe_debuG_pub.add('attri id'||p_attr_id);
    oe_debug_pub.add('attr val ksur'||p_attr_value);
    IF p_attr_id =    OE_Header_Util.G_ACCOUNTING_RULE THEN
        x_header_rec.accounting_rule_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_ACCOUNTING_RULE_DURATION THEN
        x_header_rec.accounting_rule_duration := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_AGREEMENT THEN
        x_header_rec.agreement_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_BLANKET_NUMBER THEN
          x_header_rec.blanket_number := TO_NUMBER(p_attr_value);
    --kmuruges
    ELSIF p_attr_id = OE_Header_Util.G_quote_date THEN
         -- x_header_rec.quote_date := TO_DATE(p_attr_value,l_date_format_mask);
	  x_header_rec.quote_date := fnd_date.string_to_date(p_attr_value,l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Header_Util.G_quote_number THEN
          x_header_rec.quote_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_sales_document_name THEN
          x_header_rec.sales_document_name := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_transaction_phase THEN
          x_header_rec.transaction_phase_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_user_status THEN
          x_header_rec.user_status_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_draft_submitted THEN
          x_header_rec.draft_submitted_flag := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_source_document_version THEN
      x_header_rec.source_document_version_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_sold_to_site_use THEN
      x_header_rec.sold_to_site_use_id := TO_NUMBER(p_attr_value);

   ELSIF p_attr_id = OE_Header_Util.G_ib_owner THEN
          x_header_rec.ib_owner := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_ib_installed_at_location THEN
          x_header_rec.ib_installed_at_location := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_ib_current_location THEN
          x_header_rec.ib_current_location := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_end_customer_site_use THEN
          x_header_rec.end_customer_site_use_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_end_customer_contact THEN
          x_header_rec.end_customer_contact_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_end_customer THEN
          x_header_rec.end_customer_id := TO_NUMBER(p_attr_value);
   --kmuruges end
    ELSIF p_attr_id = OE_Header_Util.G_BOOKED THEN
        x_header_rec.booked_flag := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_BOOKED_DATE THEN
        x_header_rec.booked_date := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_CANCELLED THEN
        x_header_rec.cancelled_flag := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_CONVERSION_RATE THEN
        x_header_rec.conversion_rate := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_CONVERSION_RATE_DATE THEN
       -- x_header_rec.conversion_rate_date := TO_DATE(p_attr_value,l_date_format_mask);
        x_header_rec.conversion_rate_date := fnd_date.string_to_date(p_attr_value,l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Header_Util.G_CONVERSION_TYPE THEN
        x_header_rec.conversion_type_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_CUSTOMER_PREFERENCE_SET THEN
        x_header_rec.CUSTOMER_PREFERENCE_SET_CODE := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_CUST_PO_NUMBER THEN
        x_header_rec.cust_po_number := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_DEFAULT_FULFILLMENT_SET THEN
        x_header_rec.DEFAULT_FULFILLMENT_SET := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_DELIVER_TO_CONTACT THEN
        x_header_rec.deliver_to_contact_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_DELIVER_TO_ORG THEN
        x_header_rec.deliver_to_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_DEMAND_CLASS THEN
        x_header_rec.demand_class_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_EXPIRATION_DATE THEN
       -- x_header_rec.expiration_date := TO_DATE(p_attr_value, l_date_format_mask);
        x_header_rec.expiration_date := fnd_date.string_to_date(p_attr_value, l_date_format_mask);--bug5402396
    ELSIF p_attr_id = OE_Header_Util.G_EARLIEST_SCHEDULE_LIMIT THEN
        x_header_rec.earliest_schedule_limit := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_FOB_POINT THEN
        x_header_rec.fob_point_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_FREIGHT_CARRIER THEN
        x_header_rec.freight_carrier_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_FREIGHT_TERMS THEN
        x_header_rec.freight_terms_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_FULFILLMENT_SET_NAME THEN
        x_header_rec.FULFILLMENT_SET_NAME := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_HEADER THEN
        x_header_rec.header_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_INVOICE_TO_CONTACT THEN
        x_header_rec.invoice_to_contact_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_INVOICE_TO_ORG THEN
        x_header_rec.invoice_to_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_INVOICING_RULE THEN
        x_header_rec.invoicing_rule_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_LATEST_SCHEDULE_LIMIT THEN
        x_header_rec.latest_schedule_limit := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_LINE_SET_NAME THEN
        x_header_rec.LINE_SET_NAME := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_OPEN THEN
        x_header_rec.open_flag := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_ORDERED_DATE THEN
       -- x_header_rec.ordered_date := TO_DATE(p_attr_value, l_date_format_mask);
        x_header_rec.ordered_date := fnd_date.string_to_date(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Header_Util.G_ORDER_DATE_TYPE_CODE THEN
        x_header_rec.order_date_type_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_ORDER_NUMBER THEN
        x_header_rec.order_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_ORDER_SOURCE THEN
        x_header_rec.order_source_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_ORDER_TYPE THEN
        x_header_rec.order_type_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_ORG THEN
        x_header_rec.org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_ORIG_SYS_DOCUMENT_REF THEN
        x_header_rec.orig_sys_document_ref := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_PARTIAL_SHIPMENTS_ALLOWED THEN
        x_header_rec.partial_shipments_allowed := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_PAYMENT_TERM THEN
        x_header_rec.payment_term_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_PRICE_LIST THEN
        x_header_rec.price_list_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_PRICING_DATE THEN
       -- x_header_rec.pricing_date := TO_DATE(p_attr_value, l_date_format_mask);
        x_header_rec.pricing_date := fnd_date.string_to_date(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Header_Util.G_REQUEST_DATE THEN
       -- x_header_rec.request_date := TO_DATE(p_attr_value, l_date_format_mask);
        x_header_rec.request_date := fnd_date.string_to_date(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Header_Util.G_SHIPMENT_PRIORITY THEN
        x_header_rec.shipment_priority_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_SHIPPING_METHOD THEN
        x_header_rec.shipping_method_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_SHIP_FROM_ORG THEN
        x_header_rec.ship_from_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_SHIP_TOLERANCE_ABOVE THEN
        x_header_rec.ship_tolerance_above := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_SHIP_TOLERANCE_BELOW THEN
        x_header_rec.ship_tolerance_below := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_SHIP_TO_CONTACT THEN
        x_header_rec.ship_to_contact_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_SHIP_TO_ORG THEN
        x_header_rec.ship_to_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_SOLD_TO_CONTACT THEN
        x_header_rec.sold_to_contact_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_SOLD_TO_ORG THEN
        x_header_rec.sold_to_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_SOLD_TO_PHONE THEN
        x_header_rec.sold_to_phone_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_SOURCE_DOCUMENT THEN
        x_header_rec.source_document_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_SOURCE_DOCUMENT_TYPE THEN
        x_header_rec.source_document_type_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_TAX_EXEMPT THEN
        x_header_rec.tax_exempt_flag := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_TAX_EXEMPT_NUMBER THEN
        x_header_rec.tax_exempt_number := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_TAX_EXEMPT_REASON THEN
        x_header_rec.tax_exempt_reason_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_TAX_POINT THEN
        x_header_rec.tax_point_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_TRANSACTIONAL_CURR THEN
        x_header_rec.transactional_curr_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_VERSION_NUMBER THEN
        x_header_rec.version_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id =    OE_Header_Util.G_SALESREP THEN
        x_header_rec.salesrep_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id =    OE_Header_Util.G_SALES_CHANNEL THEN
        x_header_rec.sales_channel_code := p_attr_value;
    ELSIF p_attr_id =    OE_Header_Util.G_RETURN_REASON THEN
        x_header_rec.return_reason_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_PAYMENT_TYPE THEN
        x_header_rec.payment_type_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_PAYMENT_AMOUNT THEN
        x_header_rec.payment_amount := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id =    OE_Header_Util.G_CHECK_NUMBER THEN
        x_header_rec.check_number := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_CREDIT_CARD THEN
        x_header_rec.credit_card_code := p_attr_value;
    ELSIF p_attr_id =    OE_Header_Util.G_CREDIT_CARD_HOLDER_NAME THEN
        x_header_rec.credit_card_holder_name := p_attr_value;
    ELSIF p_attr_id =    OE_Header_Util.G_CREDIT_CARD_NUMBER THEN
        x_header_rec.credit_card_number := p_attr_value;
    ELSIF p_attr_id = Oe_header_util.G_INSTRUMENT_SECURITY THEN--R12 CC Encryption
	  x_header_rec.instrument_security_code := p_attr_value;
    ELSIF p_attr_id = Oe_header_util.G_CC_INSTRUMENT THEN
	  x_header_rec.CC_INSTRUMENT_ID := p_attr_value;
    ELSIF p_attr_id = Oe_header_util.G_CC_INSTRUMENT_ASSIGNMENT THEN
	  x_header_rec.CC_INSTRUMENT_ASSIGNMENT_ID := p_attr_value; --R12 CC Encryption
    ELSIF p_attr_id =    OE_Header_Util.G_CREDIT_CARD_EXPIRATION_DATE THEN
       -- x_header_rec.credit_card_expiration_date := TO_DATE(p_attr_value, l_date_format_mask);
        x_header_rec.credit_card_expiration_date := fnd_date.string_to_date(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id =    OE_Header_Util.G_CREDIT_CARD_APPROVAL_DATE   THEN
       -- x_header_rec.credit_card_approval_date   := TO_DATE(p_attr_value, l_date_format_mask);
        x_header_rec.credit_card_approval_date   := fnd_date.string_to_date(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id =    OE_Header_Util.G_CREDIT_CARD_APPROVAL THEN
        x_header_rec.credit_card_approval_code := p_attr_value;
    ELSIF p_attr_id =    OE_Header_Util.G_FIRST_ACK THEN
        x_header_rec.first_ack_code := p_attr_value;
    ELSIF p_attr_id =    OE_Header_Util.G_FIRST_ACK_DATE THEN
       -- x_header_rec.first_ack_date := TO_DATE(p_attr_value, l_date_format_mask);
        x_header_rec.first_ack_date := fnd_date.string_to_date(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id =    OE_Header_Util.G_LAST_ACK THEN
        x_header_rec.last_ack_code := p_attr_value;
    ELSIF p_attr_id =    OE_Header_Util.G_SHIPPING_INSTRUCTIONS THEN
        x_header_rec.shipping_instructions := p_attr_value;
    ELSIF p_attr_id =    OE_Header_Util.G_PACKING_INSTRUCTIONS THEN
        x_header_rec.packing_instructions := p_attr_value;
    ELSIF p_attr_id =    OE_Header_Util.G_LAST_ACK_DATE THEN
       -- x_header_rec.last_ack_date := TO_DATE(p_attr_value, l_date_format_mask);
        x_header_rec.last_ack_date := fnd_date.string_to_date(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id =    OE_Header_Util.G_ORDER_CATEGORY THEN
        x_header_rec.order_category_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_CONTRACT_TEMPLATE THEN
        x_header_rec.contract_template_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_CONTRACT_SOURCE_DOC_TYPE THEN
        x_header_rec.contract_source_doc_type_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_CONTRACT_SOURCE_DOCUMENT THEN
        x_header_rec.contract_source_document_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_SUPPLIER_SIGNATURE THEN
        x_header_rec.supplier_signature := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_CUSTOMER_SIGNATURE THEN
        x_header_rec.customer_signature := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_CUSTOMER_SIGNATURE_DATE THEN
       -- x_header_rec.customer_signature_date := TO_DATE(p_attr_value, l_date_format_mask);
        x_header_rec.customer_signature_date := fnd_date.string_to_date(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Header_Util.G_SUPPLIER_SIGNATURE_DATE THEN
       -- x_header_rec.supplier_signature_date := TO_DATE(p_attr_value, l_date_format_mask);
          x_header_rec.supplier_signature_date := fnd_date.string_to_date(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Header_Util.G_ATTRIBUTE1
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE10
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE11
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE12
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE13
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE14
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE15
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE16   --For bug 2184255
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE17
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE18
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE19
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE2
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE20
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE3
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE4
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE5
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE6
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE7
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE8
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE9
    OR     p_attr_id = OE_Header_Util.G_CONTEXT
    THEN

        x_header_rec.attribute1        := p_header_dff_rec.attribute1;
        x_header_rec.attribute10       := p_header_dff_rec.attribute10;
        x_header_rec.attribute11       := p_header_dff_rec.attribute11;
        x_header_rec.attribute12       := p_header_dff_rec.attribute12;
        x_header_rec.attribute13       := p_header_dff_rec.attribute13;
        x_header_rec.attribute14       := p_header_dff_rec.attribute14;
        x_header_rec.attribute15       := p_header_dff_rec.attribute15;
        x_header_rec.attribute16       := p_header_dff_rec.attribute16;   --For bug 2184255
        x_header_rec.attribute17       := p_header_dff_rec.attribute17;
        x_header_rec.attribute18       := p_header_dff_rec.attribute18;
        x_header_rec.attribute19       := p_header_dff_rec.attribute19;
        x_header_rec.attribute2        := p_header_dff_rec.attribute2;
        x_header_rec.attribute20       := p_header_dff_rec.attribute20;
        x_header_rec.attribute3        := p_header_dff_rec.attribute3;
        x_header_rec.attribute4        := p_header_dff_rec.attribute4;
        x_header_rec.attribute5        := p_header_dff_rec.attribute5;
        x_header_rec.attribute6        := p_header_dff_rec.attribute6;
        x_header_rec.attribute7        := p_header_dff_rec.attribute7;
        x_header_rec.attribute8        := p_header_dff_rec.attribute8;
        x_header_rec.attribute9        := p_header_dff_rec.attribute9;
        x_header_rec.context           := p_header_dff_rec.context;

--        null; -- Kris get desc flec working

    ELSIF p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE1
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE10
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE11
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE12
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE13
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE14
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE15
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE16
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE17
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE18
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE19
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE2
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE20
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE3
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE4
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE5
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE6
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE7
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE8
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE9
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE_CATEGORY
    THEN

        x_header_rec.global_attribute1 := p_header_dff_rec.global_attribute1;
        x_header_rec.global_attribute10 := p_header_dff_rec.global_attribute10;
        x_header_rec.global_attribute11 := p_header_dff_rec.global_attribute11;
        x_header_rec.global_attribute12 := p_header_dff_rec.global_attribute12;
        x_header_rec.global_attribute13 := p_header_dff_rec.global_attribute13;
        x_header_rec.global_attribute14 := p_header_dff_rec.global_attribute14;
        x_header_rec.global_attribute15 := p_header_dff_rec.global_attribute15;
        x_header_rec.global_attribute16 := p_header_dff_rec.global_attribute16;
        x_header_rec.global_attribute17 := p_header_dff_rec.global_attribute17;
        x_header_rec.global_attribute18 := p_header_dff_rec.global_attribute18;
        x_header_rec.global_attribute19 := p_header_dff_rec.global_attribute19;
        x_header_rec.global_attribute2 :=  p_header_dff_rec.global_attribute2;
        x_header_rec.global_attribute20 := p_header_dff_rec.global_attribute20;
        x_header_rec.global_attribute3 := p_header_dff_rec.global_attribute3;
        x_header_rec.global_attribute4 := p_header_dff_rec.global_attribute4;
        x_header_rec.global_attribute5 := p_header_dff_rec.global_attribute5;
        x_header_rec.global_attribute6 := p_header_dff_rec.global_attribute6;
        x_header_rec.global_attribute7 := p_header_dff_rec.global_attribute7;
        x_header_rec.global_attribute8 := p_header_dff_rec.global_attribute8;
        x_header_rec.global_attribute9 := p_header_dff_rec.global_attribute9;
        x_header_rec.global_attribute_category := p_header_dff_rec.global_attribute_category;

        null;  --Kris
    ELSIF  p_attr_id = OE_Header_Util.G_TP_CONTEXT
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE1
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE2
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE3
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE4
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE5
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE6
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE7
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE8
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE9
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE10
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE11
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE12
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE13
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE14
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE15
    THEN

        x_header_rec.tp_attribute1        := p_header_dff_rec.tp_attribute1;
        x_header_rec.tp_attribute10       := p_header_dff_rec.tp_attribute10;
        x_header_rec.tp_attribute11       := p_header_dff_rec.tp_attribute11;
        x_header_rec.tp_attribute12       := p_header_dff_rec.tp_attribute12;
        x_header_rec.tp_attribute13       := p_header_dff_rec.tp_attribute13;
        x_header_rec.tp_attribute14       := p_header_dff_rec.tp_attribute14;
        x_header_rec.tp_attribute15       := p_header_dff_rec.tp_attribute15;
        x_header_rec.tp_attribute2        := p_header_dff_rec.tp_attribute2;
        x_header_rec.tp_attribute3        := p_header_dff_rec.tp_attribute3;
        x_header_rec.tp_attribute4        := p_header_dff_rec.tp_attribute4;
        x_header_rec.tp_attribute5        := p_header_dff_rec.tp_attribute5;
        x_header_rec.tp_attribute6        := p_header_dff_rec.tp_attribute6;
        x_header_rec.tp_attribute7        := p_header_dff_rec.tp_attribute7;
        x_header_rec.tp_attribute8        := p_header_dff_rec.tp_attribute8;
        x_header_rec.tp_attribute9        := p_header_dff_rec.tp_attribute9;
        x_header_rec.tp_context           := p_header_dff_rec.tp_context;
    ELSE

        --  Unexpected error, unrecognized attribute

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attribute'
            ,   'Unrecognized attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    --  Set Operation.

    IF FND_API.To_Boolean(x_header_rec.db_flag) THEN
        x_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        x_header_rec.operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Call Oe_Order_Pvt.Header
    oe_debug_pub.add('Exiting OE_OE_FORM_HEADER.CHANGE_ATTRIBUTES'||x_header_rec.sold_to_phone_id, 1);
    oe_debug_pub.add('hash template id in change att before invoice is '|| x_header_rec.contract_template_id);
    oe_debug_pub.add('Entering invoice'||x_header_rec.invoice_to_org_id, 1);
    oe_debug_pub.add('Entering Invoice'||x_old_header_rec.invoice_to_org_id, 1);

    Oe_Order_Pvt.Header
    (
        p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                => x_header_rec
    ,   p_x_old_header_rec            => x_old_header_rec
    ,   x_return_status                => l_return_status
    );
    oe_debug_pub.add('Exiting invoice'||x_header_rec.invoice_to_org_id, 1);
    oe_debug_pub.add('Exiting invoice'||x_old_header_rec.invoice_to_org_id, 1);
    --oe_debug_pub.add('Holder name new'||x_header_rec.credit_card_holder_name);
    --oe_debug_pub.add('Holder name old'||x_old_header_rec.credit_card_holder_name);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Init OUT NOCOPY parameters to missing.


    --  Load display out NOCOPY parameters if any

    x_header_val_rec := OE_Header_Util.Get_Values
    (   p_header_rec                  => x_header_rec
    ,   p_old_header_rec              => x_old_header_rec
    );

   --  Return changed attributes.

    --If defaulting is enabled for credit card number, then need to populate the
    --instrument id and instrument assignment id returned by the Payments API in
    --OE_Default_Pvt package

    IF OE_Default_Pvt.g_default_instrument_id IS NOT NULL THEN
	x_header_rec.cc_instrument_id := OE_Default_Pvt.g_default_instrument_id;
	oe_debug_pub.add('instr id in fhpmb'||x_header_rec.cc_instrument_id);
	--Setting the value of assignment id to null
	--after passing the value to the library
	OE_Default_Pvt.g_default_instrument_id := null;
    END IF;

    IF OE_Default_Pvt.g_default_instr_assignment_id IS NOT NULL THEN
	x_header_rec.cc_instrument_assignment_id := OE_Default_Pvt.g_default_instr_assignment_id;
	oe_debug_pub.add('assign id in fhpmb'||x_header_rec.cc_instrument_assignment_id	);
	--Setting the value of assignment id to null
	--after passing the value to the library
	OE_Default_Pvt.g_default_instr_assignment_id := null;
    END IF;
    --R12 CC Encryption
   --  Write to cache.

    Write_header
    (   p_header_rec                  => x_header_rec
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

    oe_debug_pub.add('Exiting OE_OE_FORM_HEADER.CHANGE_ATTRIBUTES', 1);

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
            ,   'Change_Attribute'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Change_Attribute;

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
, x_cascade_flag OUT NOCOPY BOOLEAN
,   p_header_id                     IN  NUMBER
,   p_change_reason_code            IN  VARCHAR2
,   p_change_comments               IN  VARCHAR2
, x_creation_date OUT NOCOPY DATE
, x_created_by OUT NOCOPY NUMBER
, x_last_update_date OUT NOCOPY DATE
, x_last_updated_by OUT NOCOPY NUMBER
, x_last_update_login OUT NOCOPY NUMBER
, x_order_number OUT NOCOPY NUMBER
, x_lock_control OUT NOCOPY NUMBER
, x_quote_number OUT NOCOPY NUMBER
,x_shipping_method_code OUT NOCOPY VARCHAR2 --4159701
, x_freight_carrier_code OUT NOCOPY VARCHAR2 --4159701
, x_shipping_method  OUT NOCOPY VARCHAR2--4159701
, x_freight_carrier OUT NOCOPY VARCHAR2 --4159701
, x_freight_terms_code OUT NOCOPY VARCHAR2 --4348011
, x_freight_terms      OUT NOCOPY VARCHAR2
, x_payment_term_id   OUT NOCOPY NUMBER
, x_payment_term      OUT NOCOPY VARCHAR2
)
IS
l_x_old_header_rec              OE_Order_PUB.Header_Rec_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
BEGIN

    SAVEPOINT Header_Validate_And_Write;

    oe_debug_pub.add('Entering OE_OE_FORM_HEADER.VALIDATE_AND_WRITE', 1);

    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.check_security       := FALSE;
    l_control_rec.clear_dependents     := FALSE;
    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read header from cache

    Get_header
    (   p_db_record                   => TRUE
    ,   p_header_id                   => p_header_id
    ,   x_header_rec                  => l_x_old_header_rec
    );

     Get_header
    (   p_db_record                   => FALSE
    ,   p_header_id                   => p_header_id
    ,   x_header_rec                  => l_x_header_rec
    );

    /* Start Audit Trail -- Pass the reason, comments */
	  l_x_header_rec.change_reason := p_change_reason_code;
	  l_x_header_rec.change_comments := p_change_comments;
    /* End Audit Trail */

    --  Set Operation.

    IF FND_API.To_Boolean(l_x_header_rec.db_flag) THEN
        l_x_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
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


    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

/* The Process Requests and Notify should be invoked for */
/* Pre-Pack H code level */

  IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL < '110508' THEN

    Oe_Order_Pvt.Process_Requests_And_Notify
    (   p_process_requests           => FALSE
    ,   p_init_msg_list               => FND_API.G_FALSE
     ,  p_notify                     => TRUE
	,  x_return_status              => l_return_status
	,  p_header_rec                 => l_x_header_rec
	,  p_old_header_rec             => l_x_old_header_rec
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;  /* code release level check */


    x_cascade_flag := OE_GLOBALS.G_CASCADING_REQUEST_LOGGED;
    --  Load OUT NOCOPY parameters.


    x_creation_date                := l_x_header_rec.creation_date;
    x_created_by                   := l_x_header_rec.created_by;
    x_last_update_date             := l_x_header_rec.last_update_date;
    x_last_updated_by              := l_x_header_rec.last_updated_by;
    x_last_update_login            := l_x_header_rec.last_update_login;
    x_order_number                 := l_x_header_rec.order_number;
    x_lock_control                 := l_x_header_rec.lock_control;
    --kmuruges
    x_quote_number                 := l_x_header_rec.quote_number;
    --kmuruges end
     --start 4159701
    x_shipping_method_code         := l_x_header_rec.shipping_method_code;
    x_freight_carrier_code         := l_x_header_rec.freight_carrier_code;
    x_freight_carrier              := OE_ID_TO_VALUE.Freight_Carrier
                                                (   p_freight_carrier_code => l_x_header_rec.freight_carrier_code
                                                ,   p_ship_from_org_id =>l_x_header_rec.ship_from_org_id
                                                );

    x_shipping_method              := OE_ID_TO_VALUE.Ship_Method
                                                (p_ship_method_code =>l_x_header_rec.shipping_method_code
                                                );
    --bug 4348011
    x_freight_terms_code           := l_x_header_rec.freight_terms_code;
    oe_debug_pub.add('ksurendr Freight terms code after PO'||x_freight_terms_code, 1);
    x_freight_terms                := OE_ID_TO_VALUE.Freight_Terms
                                     (p_freight_terms_code => l_x_header_rec.freight_terms_code);
    x_payment_term_id              := l_x_header_rec.payment_term_id;
    x_payment_term                 := OE_ID_TO_VALUE.Payment_Term
                                     (p_payment_term_id => l_x_header_rec.payment_term_id);
    --bug 4348011
    --  Clear header record cache

    Clear_header;

    --  Keep track of performed operations.
/* Is the following assignment Needed- Venkatesh */
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

    oe_debug_pub.add('Exiting OE_OE_FORM_HEADER.VALIDATE_AND_WRITE', 1);

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

END Validate_And_Write;

--  Procedure       Delete_Row
--

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
BEGIN
    SAVEPOINT  Header_Delete;
    oe_debug_pub.add('Entering OE_OE_FORM_HEADER.DELETE_ROW', 1);

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

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
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

    oe_debug_pub.add('Exiting OE_OE_FORM_HEADER.DELETE_ROW', 1);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO SAVEPOINT Header_Delete ;
	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO SAVEPOINT Header_Delete ;

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN
       ROLLBACK TO SAVEPOINT Header_Delete ;

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

--  Procedure       Process_Entity
--

PROCEDURE Process_Entity
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
)
IS
l_return_status               VARCHAR2(1);
BEGIN

    oe_debug_pub.add('Entering OE_OE_FORM_HEADER.PROCESS_ENTITY', 1);

    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.


    Oe_Order_Pvt.Process_Requests_And_Notify
    (   p_process_requests           => TRUE
    ,   p_init_msg_list               => FND_API.G_TRUE
     ,  p_notify                     => FALSE
     ,  x_return_status              => l_return_status
    );


    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Exiting OE_OE_FORM_HEADER.PROCESS_ENTITY', 1);

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
            ,   'Process_Entity'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Entity;

--  Procedure       Process_Object
--

PROCEDURE Process_Object
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
, x_cascade_flag OUT NOCOPY BOOLEAN
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_line_tbl oe_order_pub.line_tbl_type;
BEGIN
    oe_debug_pub.add('Entering OE_OE_FORM_HEADER.PROCESS_OBJECT', 1);

    OE_MSG_PUB.initialize;

     IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >='110510' THEN
       If OE_GLOBALS.G_FTE_REINVOKE = 'Y' Then
        fnd_message.set_name('ONT','ONT_LINE_ATTRIB_CHANGED');
        OE_MSG_PUB.Add;
        OE_GLOBALS.G_FTE_REINVOKE := 'N';
       End If;
     End If;

    -- we are using this flag to selectively requery the block,
    -- if any of the delayed req. get executed changing rows.
    -- currently all the work done in post line process will
    -- eventually set the global cascading flag to TRUE.
    -- if some one adds code to post lines, whcih does not
    -- set cascadinf flga to TURE and still modifes records,
    -- that will be incorrect.
    -- this flag helps to requery the block if any thing changed
    -- after validate and write.

    OE_GLOBALS.G_PROCESS_OBJECTS_FLAG := TRUE;

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

    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    oe_line_util.Post_Line_Process
    (   p_control_rec    => l_control_rec
    ,   p_x_line_tbl   => l_line_tbl );

    Oe_Order_Pvt.Process_Requests_And_Notify
    (   p_process_requests           => TRUE
    ,   p_init_msg_list               => FND_API.G_FALSE
     ,  p_notify                     => TRUE
     ,  x_return_status              => l_return_status
    );


    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_cascade_flag := OE_GLOBALS.G_CASCADING_REQUEST_LOGGED;
    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    OE_GLOBALS.G_UI_FLAG := FALSE;
    OE_GLOBALS.G_PROCESS_OBJECTS_FLAG := FALSE;

    oe_debug_pub.add('Exiting OE_OE_FORM_HEADER.PROCESS_OBJECT', 1);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
           OE_GLOBALS.G_PROCESS_OBJECTS_FLAG := FALSE;
	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           OE_GLOBALS.G_PROCESS_OBJECTS_FLAG := FALSE;
	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN
           OE_GLOBALS.G_PROCESS_OBJECTS_FLAG := FALSE;
	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Object'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Object;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
,   p_lock_control                  IN  NUMBER
)

IS
l_return_status               VARCHAR2(1);
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
BEGIN

    oe_debug_pub.add('Entering OE_OE_FORM_HEADER.LOCK_ROW', 1);

    --  Load header record

    l_x_header_rec.lock_control         := p_lock_control;
    l_x_header_rec.header_id            := p_header_id;
    l_x_header_rec.operation            := OE_GLOBALS.G_OPR_LOCK; -- not req.

    --  Call OE_Header_Util.Lock_Row instead of Oe_Order_Pvt.Lock_order

    oe_debug_pub.add('header_id'|| l_x_header_rec.header_id, 1);

    OE_MSG_PUB.initialize;
    OE_Header_Util.Lock_Row
    (   x_return_status        => l_return_status
    ,   p_x_header_rec         => l_x_header_rec );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_header_rec.db_flag := FND_API.G_TRUE;

        Write_header
        (   p_header_rec                  => l_x_header_rec
        ,   p_db_record                   => TRUE
        );

    END IF;

    --  Set return status.

    x_return_status := l_return_status;
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Exiting OE_OE_FORM_HEADER.LOCK_ROW', 1);

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN

           OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

           OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
         );
    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Lock_Row;

--  Procedures maintaining header record cache.

PROCEDURE Write_header
(   p_header_rec                    IN  OE_Order_PUB.Header_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
BEGIN

    oe_debug_pub.add('Entering OE_OE_FORM_HEADER.WRITE_HEADER', 1);

    g_header_rec := p_header_rec;

    IF p_db_record THEN

        g_db_header_rec := p_header_rec;

    END IF;

    oe_debug_pub.add('Exiting OE_OE_FORM_HEADER.WRITE_HEADER', 1);

END Write_Header;

PROCEDURE Get_header
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_header_id                     IN  NUMBER
,   x_header_rec                    OUT NOCOPY OE_Order_PUB.Header_Rec_Type
)
IS

BEGIN

    oe_debug_pub.add('Entering OE_OE_FORM_HEADER.GET_HEADER', 1);

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

    oe_debug_pub.add('Exiting OE_OE_FORM_HEADER.GET_HEADER', 1);

END Get_Header;

PROCEDURE Clear_Header
IS
BEGIN

    oe_debug_pub.add('Entering OE_OE_FORM_HEADER.CLEAR_HEADER', 1);

    g_header_rec                   := OE_Order_PUB.G_MISS_HEADER_REC;
    g_db_header_rec                := OE_Order_PUB.G_MISS_HEADER_REC;

    oe_debug_pub.add('Exiting OE_OE_FORM_HEADER.CLEAR_HEADER', 1);

END Clear_Header;


-- This procedure will be called from the client when the user
-- clears a record
Procedure Clear_Record
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
)
IS
l_header_id        NUMBER;
l_return_status                     Varchar2(30);
BEGIN
     OE_MSG_PUB.initialize;
     x_return_status := FND_API.G_RET_STS_SUCCESS;


       OE_ORDER_CACHE.g_header_rec:=null;
       OE_DELAYED_REQUESTS_PVT.Delete_Reqs_for_Deleted_Entity(
					p_entity_code  => OE_GLOBALS.G_ENTITY_HEADER
					,p_entity_id    => p_header_id
				     ,x_return_status => l_return_status);

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

     IF OE_GLOBALS.G_ROLL_VERSION <> 'N' THEN

           oe_debug_pub.add('Request does not exist, reset versioning globals');           IF (NOT OE_Versioning_Util.Reset_Globals) THEN
               l_return_status := FND_API.G_RET_STS_ERROR;
               RETURN;
           END IF;
     END IF;

-- Clear the controller cache
	Clear_Header;
--added for bug3716206
	OE_GLOBALS.G_HEADER_CREATED := FALSE;
        OE_ORDER_UTIL.Clear_Global_Picture(l_return_status);
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


-- This procedure will be called from the client when the user
-- clears a block or Form
Procedure Delete_All_Requests
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
)
IS
l_return_status                     Varchar2(30);
BEGIN
     OE_MSG_PUB.initialize;
 	x_return_status := FND_API.G_RET_STS_SUCCESS;
       OE_DELAYED_REQUESTS_PVT.Clear_Request(
				     x_return_status => l_return_status);

EXCEPTION
    WHEN OTHERS THEN
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_All_Requests'
            );
        END IF;
        --  Get message count and data
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
        x_return_status := FND_API.G_RET_STS_ERROR;

END Delete_All_Requests;


Procedure Sales_Person
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
, p_multiple_sales_credits OUT NOCOPY Varchar2
,   p_header_id                     IN  NUMBER
,   p_salesrep_id                   IN  NUMBER
) IS
l_return_status                     Varchar2(30);
Cursor C_HSC_COUNT(p_header_id Number) IS
   Select count(sales_credit_id)
   from oe_sales_credits sc,
        oe_sales_credit_types sct
   where header_id = p_header_id
   and   sct.sales_Credit_type_id = sc.sales_credit_type_id
   and   sct.quota_flag = 'Y'
   and   line_id is null;
l_count   Number;
Begin

   oe_debug_pub.add('Entering OE_OE_FORM_HEADER.SALES_PERSON', 1);

    OE_MSG_PUB.initialize;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   p_multiple_sales_credits := 'N';
   open C_HSC_COUNT(p_header_id);
   fetch C_HSC_COUNT into l_count;
   close C_HSC_COUNT;
   if l_count > 1 then
      p_multiple_sales_credits := 'Y';
      FND_MESSAGE.SET_NAME('ONT','OE_TOO_MANY_HSCREDIT');
      OE_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
   end if;
-- add delayed request to default headers sales credits for the salesrep
           OE_Delayed_Requests_Pvt.Log_Request
                 (p_entity_code=>OE_GLOBALS.G_ENTITY_Header
                 ,p_entity_id=>p_header_id
		 ,p_requesting_entity_code => OE_GLOBALS.G_ENTITY_Header
		 ,p_requesting_entity_id   => p_header_id
                 ,p_request_type=>OE_GLOBALS.G_DFLT_HSCREDIT_FOR_SREP
                 ,p_param1  => to_char(p_header_id)
                 ,p_param2  => to_char(p_salesrep_id)
                 ,x_return_status =>l_return_status);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    oe_debug_pub.add('Exiting OE_OE_FORM_HEADER.SALES_PERSON', 1);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sales_Person'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        x_return_status := FND_API.G_RET_STS_ERROR;

End Sales_Person;

PROCEDURE Get_Form_Startup_Values
(Item_Id_Flex_Code         IN VARCHAR2,
Item_Id_Flex_Num OUT NOCOPY NUMBER) IS

    CURSOR C_Item_Flex(X_Id_Flex_Code VARCHAR2) is
      SELECT id_flex_num
      FROM   fnd_id_flex_structures
      WHERE  id_flex_code = X_Id_Flex_Code;
BEGIN

    oe_debug_pub.add('Entering OE_OE_FORM_HEADER.GET_FORM_STARTUP_VALUES', 1);

    OPEN C_Item_Flex(Item_Id_Flex_Code);
    FETCH C_Item_Flex INTO Item_Id_Flex_Num;
    CLOSE C_Item_Flex;

    oe_debug_pub.add('Exiting OE_OE_FORM_HEADER.GET_FORM_STARTUP_VALUES', 1);

  EXCEPTION
    WHEN OTHERS THEN
      oe_debug_pub.add('In when others exception : OE_OE_FORM_HEADER.GET_FORM_STARTUP_VALUES', 1);
     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Get_Form_Startup_Values'
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Get_Form_Startup_Values;


PROCEDURE Populate_Control_Fields
(
p_header_rec_type IN Header_Rec_Type,
x_header_val_rec OUT NOCOPY Header_Val_Rec_Type
)  IS
 CURSOR C1(fob_point_code    VARCHAR2,
		 tax_exempt_flag   VARCHAR2,
		 tax_exempt_reason_code VARCHAR2,
                 return_reason_code     VARCHAR2,
		 tax_point_code    VARCHAR2
		 )
		 IS
 SELECT meaning,lookup_type
 FROM   AR_LOOKUPS
 WHERE  (lookup_code=fob_point_code
 AND     lookup_type='FOB')
 OR     (lookup_code=tax_exempt_flag
 AND     lookup_type='TAX_CONTROL_FLAG')
 OR     (lookup_code=tax_exempt_reason_code
 AND     lookup_type='TAX_REASON')
 OR     (lookup_code=return_reason_code
 AND     lookup_type='CREDIT_MEMO_REASON')
 OR     (lookup_code=tax_point_code
 AND     lookup_type='TAX_POINT_TYPE');

 CURSOR c2(shipment_priority_code  VARCHAR2,
            freight_terms_code     VARCHAR2,
		  payment_type_code      VARCHAR2,
		  flow_status_code	     VARCHAR2,
		  --credit_card_code       VARCHAR2, --R12 CC Encryption
		  sales_channel_code     VARCHAR2 )
  IS
     SELECT meaning,lookup_type
     FROM FND_LOOKUP_VALUES LV
     WHERE LANGUAGE = userenv('LANG')
     and VIEW_APPLICATION_ID = 660
     and((lookup_code= shipment_priority_code
     and lookup_type='SHIPMENT_PRIORITY')
     or (lookup_code=freight_terms_code
     and lookup_type='FREIGHT_TERMS')
     or (lookup_code=payment_type_code
     and lookup_type='PAYMENT TYPE')
     or (lookup_code=flow_status_code
     and lookup_type='FLOW_STATUS')
     --or (lookup_code=credit_card_code  --R12 CC Encryption
     --and lookup_type='CREDIT_CARD')
     or (lookup_code=sales_channel_code
     and lookup_type='SALES_CHANNEL'))
     and security_group_id =fnd_global.Lookup_Security_Group(lv.lookup_type,lv.view_application_id);

     l_address_id number;
     x_return_status Varchar2(1);
     x_msg_data      Varchar2(2000);
     x_msg_count     Number;
/* START PREPAYMENT */
     l_commitment_amount NUMBER;
     --pnpl
     l_pay_now_subtotal NUMBER;
     l_pay_now_tax      NUMBER;
     l_pay_now_charges  NUMBER;
     l_pay_now_commitment NUMBER;
/* END PREPAYMENT */
--R12 CC Encryption
l_instrument_id				NUMBER;
l_instrument_assignment_id		NUMBER;
l_credit_card_code              	VARCHAR2(80);
l_credit_card_holder_name       	VARCHAR2(80);
l_credit_card_number            	VARCHAR2(80);
l_credit_card_expiration_date   	DATE;
l_credit_card_approval_code     	VARCHAR2(80);
l_credit_card_approval_date     	DATE;
l_instrument_security_code		VARCHAR2(20);
l_trxn_extension_id NUMBER;
x_bank_account_number number;
x_check_number        varchar2(100);
l_return_status      VARCHAR2(30) := NULL ;
l_msg_count          NUMBER := 0 ;
l_msg_data           VARCHAR2(2000) := NULL ;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--R12 CC Encryption

BEGIN
  if l_debug_level > 0 then
	oe_debug_pub.add('Entering OE_OE_Form_Header.Populate_Control_Fields');
	oe_debug_pub.add('Header id'||p_header_rec_type.header_id);
  end if;

  IF p_header_rec_type.salesrep_id is not null THEN
   BEGIN
    SELECT Name
    INTO   x_header_val_rec.salesrep
    FROM   ra_salesreps
    WHERE  salesrep_id=p_header_rec_type.salesrep_id
    AND   org_id=p_header_rec_type.org_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        Null;
        When too_many_rows then
        Null;
        When others then
        Null;
   END;
  END IF;

  IF p_header_rec_type.sold_to_org_id is not null THEN
      Get_GSA_Indicator(p_header_rec_type.sold_to_org_id,
                        x_header_val_rec.gsa_indicator
                       );
  END IF;

  IF p_header_rec_type.sold_to_phone_id is not null THEN
  BEGIN
   Select phone_area_code,phone_number,phone_extension,phone_country_code
   Into x_header_val_rec.phone_area_code,x_header_val_rec.phone_number,
        x_header_val_rec.phone_extension,x_header_val_rec.phone_country_code
   From hz_contact_points
   Where contact_point_id=p_header_rec_type.sold_to_phone_id;
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
    Null;
   When too_many_rows then
    Null;
   When others then
    Null;
  END;
  END IF;

  IF (p_header_rec_type.tax_point_code is not null) or
	(p_header_rec_type.fob_point_code is not null) or
	(p_header_rec_type.tax_exempt_flag is not null) or
	(p_header_rec_type.return_reason_code is not null) or
	(p_header_rec_type.tax_exempt_reason_code is not null) THEN

	   FOR ar_lookups in c1(p_header_rec_type.fob_point_code,
					    p_header_rec_type.tax_exempt_flag,
					    p_header_rec_type.tax_exempt_reason_code,
					    p_header_rec_type.return_reason_code,
					    p_header_rec_type.tax_point_code)
        LOOP

	  IF ar_lookups.lookup_type='FOB' THEN
	    x_header_val_rec.fob:=ar_lookups.meaning;
          ELSIF ar_lookups.lookup_type='TAX_CONTROL_FLAG' THEN
	    x_header_val_rec.tax_exempt:=ar_lookups.meaning;
          ELSIF ar_lookups.lookup_type='TAX_REASON' THEN
	    x_header_val_rec.tax_exempt_reason:=ar_lookups.meaning;
          ELSIF ar_lookups.lookup_type='TAX_POINT' THEN
	    x_header_val_rec.tax_point:=ar_lookups.meaning;
          ELSIF ar_lookups.lookup_type='CREDIT_MEMO_REASON' then
            x_header_val_rec.return_reason:=ar_lookups.meaning;
          END IF;
        END LOOP;
  END IF;

  IF (p_header_rec_type.shipment_priority_code is not null) or
     (p_header_rec_type.freight_terms_code is not null) or
     (p_header_rec_type.payment_type_code is not null) or
     (p_header_rec_type.flow_status_code is not null) or
     --(p_header_rec_type.credit_card_code is not null) or  --R12 CC Encryption
     (p_header_rec_type.sales_channel_code is not null) THEN

        FOR Lookups in c2(p_header_rec_type.shipment_priority_code,
					 p_header_rec_type.freight_terms_Code,
					 p_header_rec_type.payment_type_code,
					 p_header_rec_type.flow_status_code,
					 --p_header_rec_type.credit_card_code, --R12 CC Encryption
					 p_header_rec_type.sales_channel_code)

        LOOP

	     IF lookups.lookup_type='SHIPMENT_PRIORITY' THEN
	       x_header_val_rec.shipment_priority:=lookups.meaning;
          ELSIF lookups.lookup_type='FREIGHT_TERMS' THEN
		  x_header_val_rec.freight_terms:=lookups.meaning;
	     ELSIF lookups.lookup_type='PAYMENT TYPE' THEN
		  x_header_val_rec.payment_type:=lookups.meaning;
	     ELSIF lookups.lookup_type='FLOW_STATUS' THEN
		  x_header_val_rec.status:=lookups.meaning;
	     --ELSIF lookups.lookup_type='CREDIT_CARD' THEN  --R12 CC Encryption
		  --x_header_val_rec.credit_card:=lookups.meaning;
	     ELSIF lookups.lookup_type='SALES_CHANNEL' THEN
		  x_header_val_rec.sales_channel:=lookups.meaning;
          END IF;

        END LOOP;
  END IF;

  IF p_header_rec_type.shipping_method_code is not null THEN
      BEGIN
    Select meaning
    INTO x_header_val_rec.shipping_method
    FROM   oe_ship_methods_v
    WHERE  lookup_code =p_header_rec_type.shipping_method_code ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        Null;
        When too_many_rows then
        Null;
        When others then
        Null;
      END;
  END IF;

   IF p_header_rec_type.freight_carrier_code IS NOT NULL THEN
      BEGIN
         Select description
         INTO x_header_val_rec.freight_carrier
         FROM   org_freight
         WHERE  freight_code=p_header_rec_type.freight_carrier_code
         and organization_id = p_header_rec_type.ship_from_org_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        Null;
        When too_many_rows then
        Null;
        When others then
        Null;
      END;
   END IF;

   x_header_val_rec.hold_exists_flag := 'N';
   IF p_header_rec_type.header_id is NOT NULL THEN
	BEGIN
	   SELECT 'Y'
	   INTO x_header_val_rec.hold_exists_flag
	   FROM OE_ORDER_HOLDS
	   WHERE HEADER_ID = p_header_rec_type.header_id
	   AND   RELEASED_FLAG = 'N';
     EXCEPTION
        WHEN TOO_MANY_ROWS THEN
		   x_header_val_rec.hold_exists_flag := 'Y';
		   null;
        WHEN OTHERS THEN
		   x_header_val_rec.hold_exists_flag := 'N';
		   null;
     END;
   END IF;

  -- Changes for Visibility to Process Messages

  x_header_val_rec.Messages_exists_flag := 'N';

  IF G_ENABLE_VISIBILITY_MSG = 'Y' AND
             p_header_rec_type.header_id is NOT NULL THEN
        BEGIN
             SELECT 'Y'
             INTO   x_header_val_rec.Messages_exists_flag
             FROM   OE_PROCESSING_MSGS
             WHERE  header_id = p_header_rec_type.header_id
             AND NVL(message_status_code, '0') <> 'CLOSED'  --datafix_begin_end
             AND    rownum < 2;
        EXCEPTION
              WHEN TOO_MANY_ROWS THEN
                   x_header_val_rec.Messages_exists_flag  := 'Y';
              WHEN OTHERS THEN
                   x_header_val_rec.Messages_exists_flag := 'N';
        END;
  END IF;

  IF (p_header_rec_type.order_date_type_code is not null) THEN
     BEGIN
      select meaning
      into x_header_val_rec.order_date_type
      from oe_lookups
      where lookup_type = 'REQUEST_DATE_TYPE'
      AND lookup_code=p_header_rec_type.order_date_type_code;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
	  When others then
	  Null;
     END;

  END IF;

  IF (p_header_rec_type.demand_class_code is not null) THEN
     BEGIN
      select meaning
      into x_header_val_rec.demand_class
      from oe_fnd_common_lookups_v
      where lookup_type = 'DEMAND_CLASS'
      AND lookup_code=p_header_rec_type.demand_class_code;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
	  When others then
	  Null;
     END;
  END IF;

  IF (p_header_rec_type.ship_to_org_id IS NOT NULL) THEN
       BEGIN
         get_customer_details(
           p_site_use_id => p_header_rec_type.ship_to_org_id,
           p_site_use_code => 'SHIP_TO',
           x_customer_id => x_header_val_rec.ship_To_customer_id,
           x_customer_name => x_header_val_rec.ship_To_customer_name,
           x_customer_number => x_header_val_rec.ship_To_customer_number
                                 );

          /*OE_Id_To_Value.Ship_To_Customer_Name
          (
          p_ship_to_org_id => p_header_rec_type.ship_to_org_id,
          x_ship_to_customer_name=> x_header_val_rec.ship_to_customer_name
          );*/
       EXCEPTION
         WHEN OTHERS THEN
             NULL;
       END;


       /*BEGIN
         get_ship_to_customer_id(
                   p_site_use_id => p_header_rec_type.ship_to_org_id,
                   x_ship_to_customer_id => x_header_val_rec.ship_To_customer_id
                                );
       EXCEPTION
         WHEN OTHERS THEN
             NULL;
       END; */

   END IF;
--kmuruges
 IF (p_header_rec_type.sold_to_site_use_id IS NOT NULL) THEN
         OE_ID_TO_VALUE.CUSTOMER_LOCATION
           (  p_sold_to_site_use_id       => p_header_rec_type.sold_to_site_use_id,
 	      x_sold_to_location_address1 => x_header_val_rec.SOLD_TO_LOCATION_ADDRESS1,
 	      x_sold_to_location_address2 => x_header_val_rec.SOLD_TO_LOCATION_ADDRESS2,
	      x_sold_to_location_address3 => x_header_val_rec.SOLD_TO_LOCATION_ADDRESS3,
	      x_sold_to_location_address4 => x_header_val_rec.SOLD_TO_LOCATION_ADDRESS4,
	      x_sold_to_location     => x_header_val_rec.SOLD_TO_LOCATION,
	      x_sold_to_location_city => x_header_val_rec.SOLD_TO_LOCATION_CITY,
	      x_sold_to_location_state => x_header_val_rec.SOLD_TO_LOCATION_STATE,
	      x_sold_to_location_postal => x_header_val_rec.SOLD_TO_LOCATION_POSTAL,
 	      x_sold_to_location_country => x_header_val_rec.SOLD_TO_LOCATION_COUNTRY
           );

 END IF;

 IF (p_header_rec_type.transaction_phase_code  IS NOT NULL) THEN
     X_header_val_rec.transaction_phase := oe_id_to_value.transaction_phase(p_header_rec_type.transaction_phase_code);
 END IF;

 IF (p_header_rec_type.User_Status_code  IS NOT NULL) THEN
     X_header_val_rec.User_Status := oe_id_to_value.User_Status(p_header_rec_type.User_Status_code);
 END IF;

 IF (p_header_rec_type.end_customer_site_use_id IS NOT NULL) THEN
         OE_ID_TO_VALUE.END_CUSTOMER_SITE_USE
           (  p_end_customer_site_use_id       => p_header_rec_type.end_customer_site_use_id,
 	      x_end_customer_address1 => x_header_val_rec.END_CUSTOMER_SITE_ADDRESS1,
 	      x_end_customer_address2 => x_header_val_rec.END_CUSTOMER_SITE_ADDRESS2,
	      x_end_customer_address3 => x_header_val_rec.END_CUSTOMER_SITE_ADDRESS3,
	      x_end_customer_address4 => x_header_val_rec.END_CUSTOMER_SITE_ADDRESS4,
	      x_end_customer_location     => x_header_val_rec.END_CUSTOMER_SITE_LOCATION,
	      x_end_customer_city => x_header_val_rec.END_CUSTOMER_SITE_CITY,
	      x_end_customer_state => x_header_val_rec.END_CUSTOMER_SITE_STATE,
	      x_end_customer_postal_code => x_header_val_rec.END_CUSTOMER_SITE_POSTAL_CODE,
 	      x_end_customer_country => x_header_val_rec.END_CUSTOMER_SITE_COUNTRY
           );

 END IF;

  IF (p_header_rec_type.end_customer_id IS NOT NULL) THEN
        OE_ID_TO_VALUE.END_CUSTOMER
           (  p_end_customer_id       => p_header_rec_type.end_customer_id,
 	      x_end_customer_name => x_header_val_rec.END_CUSTOMER_NAME,
	      x_end_customer_number => x_header_val_rec.END_CUSTOMER_NUMBER
	      );
  END IF;

  IF (p_header_rec_type.end_customer_contact_id IS NOT NULL) THEN
        x_header_val_rec.END_CUSTOMER_CONTACT :=  OE_ID_TO_VALUE.END_CUSTOMER_CONTACT
                               (  p_end_customer_contact_id       => p_header_rec_type.end_customer_contact_id);
  END IF;

--kmuruges end
  IF (p_header_rec_type.invoice_to_org_id IS NOT NULL) THEN
       BEGIN
         /*OE_Id_To_Value.Invoice_To_Customer_Name
          (
          p_invoice_to_org_id => p_header_rec_type.invoice_to_org_id,
          x_invoice_to_customer_name=> x_header_val_rec.invoice_to_customer_name
           );*/

         get_customer_details(
             p_site_use_id => p_header_rec_type.invoice_to_org_id,
             p_site_use_code =>'BILL_TO',
	     x_customer_id =>x_header_val_rec.invoice_To_customer_id,
	     x_customer_name =>x_header_val_rec.invoice_To_customer_name,
	     x_customer_number => x_header_val_rec.invoice_To_customer_number
               );

       EXCEPTION
         WHEN OTHERS THEN
             NULL;
       END;

       /*BEGIN
         get_invoice_to_customer_id(
             p_site_use_id => p_header_rec_type.invoice_to_org_id,
	     x_invoice_to_customer_id => x_header_val_rec.invoice_To_customer_id
               );
       EXCEPTION
         WHEN OTHERS THEN
             NULL;
       END;*/

   END IF;



--   added by jmore


   IF (p_header_rec_type.deliver_to_org_id is not null) THEN
     BEGIN
        SELECT   /* MOAC_SQL_CHANGE */   cas.cust_account_id,
                party.party_name,
                cust.account_number,
                site.location,
                addr.address1,
                addr.address2,
                addr.address3,
                addr.address4,
                DECODE(addr.city, NULL, NULL,addr.city || ', ') ||
                DECODE(addr.state, NULL, addr.province || ', ', addr.state || ', ') || -- 3603600
	        DECODE(addr.postal_code, NULL, NULL,addr.postal_code || ', ') ||
	        DECODE(addr.country, NULL, NULL,addr.country)
        INTO    x_header_val_rec.deliver_to_customer_id,
                x_header_val_rec.deliver_to_customer_name,
                x_header_val_rec.deliver_to_customer_number,
                x_header_val_rec.deliver_to,
	        x_header_val_rec.deliver_to_address1,
	        x_header_val_rec.deliver_to_address2,
	        x_header_val_rec.deliver_to_address3,
	        x_header_val_rec.deliver_to_address4,
	        x_header_val_rec.deliver_to_address5

        FROM    HZ_CUST_SITE_USES_ALL site,
                HZ_CUST_ACCT_SITES_ALL cas,
                hz_cust_accounts cust,
                hz_parties party,
                hz_party_sites ps,
                hz_locations addr
        WHERE   site.cust_acct_site_id = cas.cust_acct_site_id
        AND     site.site_use_code='DELIVER_TO'
        AND     site.site_use_id=p_header_rec_type.deliver_to_org_id
        AND     cust.cust_account_id = cas.cust_account_id
        AND     party.party_id = cust.party_id
        AND     cas.party_site_id = ps.party_site_id
        AND     ps.location_id = addr.location_id;

	 x_header_val_rec.deliver_to_location := x_header_val_rec.deliver_to;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
	  When others then
	  Null;
     END;
   END IF;


   IF (p_header_rec_type.deliver_to_contact_id is not null) THEN
     BEGIN
      select name
      into x_header_val_rec.deliver_to_contact
      from oe_contacts_v
      where contact_id=p_header_rec_type.deliver_to_contact_id;


     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
	  When others then
	  Null;
     END;
   END IF;


-- Concatenated name with revision for Bug-2249065

   IF (p_header_rec_type.agreement_id is not null) THEN
     BEGIN
      select name||' : '||revision
      into x_header_val_rec.agreement
      from oe_agreements
      where agreement_id=p_header_rec_type.agreement_id;


     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
	  When others then
	  Null;
     END;
   END IF;


   IF (p_header_rec_type.order_source_id is not null) THEN
     BEGIN
      select name
      into x_header_val_rec.order_source
      from oe_order_sources
      where order_source_id=p_header_rec_type.order_source_id;


     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
	  When others then
	  Null;
     END;
   END IF;



   IF (p_header_rec_type.source_document_type_id is not null) THEN
     BEGIN
      select name
      into x_header_val_rec.source_document_type
      from oe_order_sources
      where order_source_id=p_header_rec_type.source_document_type_id;


     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
	  When others then
	  Null;
     END;
   END IF;


   IF (p_header_rec_type.conversion_type_code is not null) THEN
     BEGIN
      select user_conversion_type
      into x_header_val_rec.conversion_type
      from gl_daily_conversion_types
      where conversion_type=p_header_rec_type.conversion_type_code;


     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
	  When others then
	  Null;
     END;
   END IF;

--Macd
   IF (p_header_rec_type.ib_owner is not null) THEN
    BEGIN
    select meaning into x_header_val_rec.ib_owner_dsp
     from oe_lookups
     where lookup_type='ITEM_OWNER' and lookup_code=p_header_rec_type.ib_owner;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
	  When others then
	  Null;
     END;
   END IF;

   IF (p_header_rec_type.ib_installed_at_location is not null) THEN
    BEGIN
    select meaning into x_header_val_rec.ib_installed_at_location_dsp
     from oe_lookups
     where lookup_type='ITEM_INSTALL_LOCATION' and lookup_code=p_header_rec_type.ib_installed_at_location;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
	  When others then
	  Null;
     END;
   END IF;

   IF (p_header_rec_type.ib_current_location is not null) THEN
    BEGIN
    select meaning into x_header_val_rec.ib_current_location_dsp
     from oe_lookups
     where lookup_type='ITEM_CURRENT_LOCATION' and lookup_code=p_header_rec_type.ib_current_location;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
	  When others then
	  Null;
     END;
   END IF;
--Macd
   -- Spagadal
   IF p_header_rec_type.blanket_number is not null then
              oe_blanket_util_misc.get_blanketAgrName
                              (p_blanket_number   => p_header_rec_type.blanket_number,
                               x_blanket_agr_name => x_header_val_rec.blanket_agreement_name);
   END If;


   IF p_header_rec_type.header_id IS NOT NULL THEN
     OE_OE_TOTALS_SUMMARY.Order_Totals
                              (
                              p_header_id=>p_header_rec_type.header_id,
                              p_subtotal =>x_header_val_rec.subtotal,
                              p_discount =>x_header_val_rec.discount,
                              p_charges  =>x_header_val_rec.charges,
                              p_tax      =>x_header_val_rec.tax
                              );

      OE_CHARGE_PVT.Get_Charge_Amount(
                         p_api_version_number=>1.0
                     ,   p_init_msg_list=>'F'
                     ,   p_all_charges=>'F'
                     ,   p_header_id=>p_header_rec_type.header_id
                     ,   p_line_id=>NULL
                     ,   x_return_status=>x_return_status
                     ,   x_msg_count=>x_msg_count
                     ,   x_msg_data=>x_msg_data
                     ,   x_charge_amount=>x_header_val_rec.header_charges
                     );

/* START PREPAYMENT */
       OE_Prepayment_Util.Get_PrePayment_Info(p_header_id    => p_header_rec_type.header_id
                                       ,x_payment_set_id  => x_header_val_rec.payment_set_id
                                       ,x_prepaid_amount  => x_header_val_rec.prepaid_amount);
       IF x_header_val_rec.payment_set_id IS NOT NULL THEN
          BEGIN
             SELECT NVL(SUM(NVL(commitment_applied_amount, 0)), 0)
             INTO l_commitment_amount
             FROM oe_payments
             WHERE header_id = p_header_rec_type.header_id;
          EXCEPTION
           WHEN NO_DATA_FOUND THEN
            l_commitment_amount := 0;
          END;
          oe_debug_pub.add('prepaid_amount: '||x_header_val_rec.prepaid_amount||'  And commitment_amount: '||l_commitment_amount);
          x_header_val_rec.pending_amount :=  NVL(x_header_val_rec.subtotal,0)+NVL(x_header_val_rec.charges,0)+NVL(x_header_val_rec.tax,0) - NVL(x_header_val_rec.prepaid_amount, 0) - l_commitment_amount;
          oe_debug_pub.add('pending_amount: '||x_header_val_rec.pending_amount);
       ELSE
          x_header_val_rec.pending_amount := NULL;
       END IF;

       --pnpl start
       IF OE_PREPAYMENT_UTIL.Get_Installment_Options(p_header_rec_type.org_id) IN ('ENABLE_PAY_NOW', 'AUTHORIZE_FIRST_INSTALLMENT') THEN
	  OE_Prepayment_PVT.Get_Pay_Now_Amounts
	     (p_header_id 		=> p_header_rec_type.header_id
	     ,p_line_id		        => null
	     ,x_pay_now_subtotal 	=> l_pay_now_subtotal
	     ,x_pay_now_tax   	        => l_pay_now_tax
	     ,x_pay_now_charges  	=> l_pay_now_charges
	     ,x_pay_now_total	        => x_header_val_rec.pay_now_total
	     ,x_pay_now_commitment      => l_pay_now_commitment
	     ,x_msg_count		=> x_msg_count
	     ,x_msg_data		=> x_msg_data
	     ,x_return_status           => x_return_status
	     );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     x_header_val_rec.pay_now_total := null;
	  END IF;
       ELSE
	   x_header_val_rec.pay_now_total := null;
       END IF;
       --pnpl end
/* END PREPAYMENT */

   END IF;

   --R12 CC Encryption
   if l_debug_level > 0 then
	oe_debug_pub.add('payment_type_code in populate control fields'||p_header_rec_type.payment_type_code);
	oe_debug_pub.add('Header id'||p_header_rec_type.header_id);
   end if;

   IF p_header_rec_type.payment_type_code IN ('CREDIT_CARD') THEN

	--Query to verify payment details are existing in
	--oe order headers all before calling card details
	--Only if credit card number is null then call card details...!
	BEGIN
		SELECT
		CREDIT_CARD_CODE
	       ,CREDIT_CARD_HOLDER_NAME
	       ,CREDIT_CARD_NUMBER
	       ,CREDIT_CARD_EXPIRATION_DATE
	       ,CREDIT_CARD_APPROVAL_CODE
	       ,CREDIT_CARD_APPROVAL_DATE
		into
		l_credit_card_code,
		l_credit_card_holder_name,
		l_credit_card_number,
		l_credit_card_expiration_date,
		l_credit_card_approval_code ,
		l_credit_card_approval_date
		FROM OE_ORDER_HEADERS_ALL
		WHERE HEADER_ID = p_header_rec_type.header_id;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		l_credit_card_code := null;
		l_credit_card_holder_name:= null;
		l_credit_card_number:= null;
		l_credit_card_expiration_date:= null;
		l_credit_card_approval_code := null;
		l_credit_card_approval_date:= null;
	END;

        BEGIN
          SELECT trxn_extension_id
          INTO   l_trxn_extension_id
          FROM   oe_payments
          WHERE  header_id = p_header_rec_type.header_id
          AND    nvl(payment_collection_event,'PREPAY') = 'INVOICE'
          AND    payment_type_code = 'CREDIT_CARD'
          AND    line_id is null;
        EXCEPTION WHEN NO_DATA_FOUND THEN
          null;
        END;

    --  bug 5414929
    -- 	IF l_credit_card_number is null
        IF l_trxn_extension_id is not null THEN
		OE_Header_Util.Query_card_details
		(p_header_id	=> p_header_rec_type.header_id,
		 p_credit_card_code => l_credit_card_code,
		 p_credit_card_holder_name => l_credit_card_holder_name,
		 p_credit_card_number => l_credit_card_number,
		 p_credit_Card_expiration_date => l_credit_card_expiration_date,
		 p_credit_card_approval_code => l_credit_card_approval_code,
		 p_credit_card_approval_Date => l_credit_card_approval_date,
		 p_instrument_security_code => l_instrument_security_code,
		 p_instrument_id	=> l_instrument_id,
		 p_instrument_assignment_id => l_instrument_assignment_id
		 );
	END IF;
	x_header_val_rec.credit_card_number := l_credit_card_number;
	x_header_val_rec.credit_card_code := l_credit_card_code;
	x_header_val_rec.credit_card_holder_name := l_credit_card_holder_name;
	x_header_val_rec.credit_card_expiration_date := l_credit_Card_expiration_Date;
	x_header_val_rec.credit_card_approval_code := l_credit_Card_approval_code;
	x_header_val_rec.credit_card_approval_date := l_credit_card_approval_date;
	x_header_val_rec.instrument_security_code := l_instrument_security_code;
	x_header_val_rec.cc_instrument_id	:= l_instrument_id;
	x_header_val_rec.cc_instrument_assignment_id := l_instrument_assignment_id;

	oe_debug_pub.add('After calling OE_Header_Util.Query_card_details');
	oe_debug_pub.add('Security code'||x_header_val_rec.instrument_security_code);
	--oe_debug_pub.add('Credit card code in populate control fields'||x_header_val_rec.credit_card_code);
	BEGIN
		IF x_header_val_rec.credit_card_code is not null then
			x_header_val_rec.credit_card := OE_Id_To_Value.Credit_Card
			(   p_credit_card_code              => x_header_val_rec.credit_card_code
			);
		END IF;
	 exception
	 when no_data_found then
	     x_header_val_rec.credit_card := NULL;
	 end;
   END IF;
   --R12 CC Encryption

EXCEPTION
WHEN NO_DATA_FOUND THEN
	NULL;
WHEN TOO_MANY_ROWS THEN
	NULL;
WHEN OTHERS THEN
	NULL;
END Populate_Control_Fields;

FUNCTION Get_Cascade_Flag return Boolean
IS
BEGIN
	return(OE_GLOBALS.G_CASCADING_REQUEST_LOGGED);
END Get_Cascade_Flag;

PROCEDURE Set_Cascade_Flag_False
IS
BEGIN
	OE_GLOBALS.G_CASCADING_REQUEST_LOGGED := FALSE;
END Set_Cascade_Flag_False;

FUNCTION Load_Set_Of_Books
RETURN Set_Of_Books_Rec_Type
IS
l_set_of_books_id   NUMBER := NULL;
l_debug_level  NUMBER := oe_debug_pub.g_debug_level; -- cc project
BEGIN
    /* commenting below line for cc project*/
    -- OE_DEBUG_PUB.G_DEBUG_LEVEL:=0;
    oe_debug_pub.add('Entering OE_ORDER_CACHE.LOAD_SET_OF_BOOKS', 1);

    --    Get set_of_books_id from profile option.

    --l_set_of_books_id := FND_PROFILE.VALUE('OE_SET_OF_BOOKS_ID');
     l_set_of_books_id := OE_Sys_Parameters.VALUE('SET_OF_BOOKS_ID');


    IF l_set_of_books_id IS NOT NULL THEN

         SELECT  SET_OF_BOOKS_ID
         ,         CURRENCY_CODE
         INTO    g_set_of_books_rec.set_of_books_id
         ,         g_set_of_books_rec.currency_code
         FROM    OE_GL_SETS_OF_BOOKS_V
         WHERE   SET_OF_BOOKS_ID = l_set_of_books_id;

    END IF;
    oe_debug_pub.add('Exiting OE_ORDER_CACHE.LOAD_SET_OF_BOOKS', 1);

    RETURN g_set_of_books_rec;

EXCEPTION
    --vmalapat changes
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;

    WHEN OTHERS THEN

     IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
         OE_MSG_PUB.Add_Exc_Msg
         (     G_PKG_NAME         ,
             'Load_Set_Of_Books'
         );
     END IF;

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Load_Set_Of_Books;



PROCEDURE get_invoice_to_customer_id ( p_site_use_id IN NUMBER,
x_invoice_to_customer_id OUT NOCOPY NUMBER
                                     ) IS
l_site_use_code VARCHAR2(30);
BEGIN
    l_site_use_code := 'BILL_TO';

	   SELECT  /* MOAC_SQL_CHANGE */   cas.cust_account_id
        INTO    x_invoice_to_customer_id
        FROM    HZ_CUST_SITE_USES_ALL site,
                HZ_CUST_ACCT_SITES_ALL cas
        WHERE   site.cust_acct_site_id = cas.cust_acct_site_id
        AND     site.site_use_code=l_site_use_code
        AND     site.site_use_id=p_site_use_id;

EXCEPTION

        WHEN NO_DATA_FOUND THEN
         Null;
        When too_many_rows then
         Null;
	   When others then
	    Null;

END get_invoice_to_customer_id;



PROCEDURE get_ship_to_customer_id ( p_site_use_id IN NUMBER,
x_ship_to_customer_id OUT NOCOPY NUMBER
                                     ) IS
l_site_use_code VARCHAR2(30);
BEGIN
    l_site_use_code := 'SHIP_TO';

	   SELECT  /* MOAC_SQL_CHANGE */   cas.cust_account_id
        INTO    x_ship_to_customer_id
        FROM    HZ_CUST_SITE_USES_ALL site,
                HZ_CUST_ACCT_SITES_ALL cas
        WHERE   site.cust_acct_site_id = cas.cust_acct_site_id
        AND     site.site_use_code=l_site_use_code
        AND     site.site_use_id=p_site_use_id;

EXCEPTION

        WHEN NO_DATA_FOUND THEN
         Null;
        When too_many_rows then
         Null;
	   When others then
	    Null;

END get_ship_to_customer_id;


PROCEDURE RESET_DEBUG_LEVEL
IS

BEGIN
 OE_DEBUG_PUB.G_DEBUG_LEVEL:=0;

END RESET_DEBUG_LEVEL;


PROCEDURE SET_DEBUG_LEVEL (p_debug_level IN NUMBER)
IS

BEGIN
 OE_DEBUG_PUB.G_DEBUG_LEVEL:=p_debug_level;

END SET_DEBUG_LEVEL;


PROCEDURE Get_GSA_Indicator( p_sold_to_org_id IN NUMBER,
x_gsa_indicator OUT NOCOPY VARCHAR2
                           ) IS

BEGIN

   SELECT  nvl(gsa_indicator_flag,'N')
     INTO  x_gsa_indicator
     FROM  hz_parties party,
           hz_cust_accounts acct
    WHERE  acct.cust_account_id=p_sold_to_org_id
      AND  party.party_id = acct.party_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
         Null;
    When too_many_rows then
        Null;
    When others then
        Null;

END Get_GSA_Indicator;

PROCEDURE CASCADE_HEADER_ATTRIBUTES
                            (
                              p_old_db_header_rec  IN OE_ORDER_PUB.Header_Rec_Type
                         ,    p_header_rec         IN OE_ORDER_PUB.Header_Rec_Type
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
                              )  IS
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_old_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_line_rec                    OE_Order_PUB.Line_Rec_Type;
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_Action_Request_tbl        OE_Order_PUB.Request_Tbl_Type;
l_x_Lot_Serial_Tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
l_x_Header_price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_x_Line_price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_count    NUMBER;
l_return_status               VARCHAR2(1);
--serla begin
l_x_Header_Payment_tbl        OE_Order_PUB.Header_Payment_Tbl_Type;
l_x_Line_Payment_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
l_init_msg_list               VARCHAR2(1) := FND_API.G_TRUE;
--serla end
BEGIN
   SAVEPOINT Header_Cascade_Attributes;
    oe_debug_pub.add('Entering OE_OE_FOR_HEADER.Cascade Attribute');
   IF NOT OE_Globals.Equal(
       p_header_rec.cust_po_number,
       p_old_db_header_rec.cust_po_number) OR
      NOT OE_Globals.Equal(
       p_header_rec.payment_term_id,
       p_old_db_header_rec.payment_term_id) OR
      NOT OE_Globals.Equal(
       p_header_rec.shipment_priority_code,
       p_old_db_header_rec.shipment_priority_code) OR
      NOT OE_Globals.Equal(
       p_header_rec.shipping_method_code,
       p_old_db_header_rec.shipping_method_code) OR
      NOT OE_Globals.Equal(
       p_header_rec.ship_to_org_id,
       p_old_db_header_rec.ship_to_org_id)  OR
      NOT OE_Globals.Equal(
       p_header_rec.agreement_id,
       p_old_db_header_rec.agreement_id)  OR
     NOT OE_Globals.Equal(
       p_header_rec.order_firmed_date,
       p_old_db_header_rec.order_firmed_date) OR  --Key Transaction dates
-- Start of Enhanced Cascading
     NOT OE_Globals.Equal(
       p_header_rec.Accounting_Rule_Id,
       p_old_db_header_rec.Accounting_rule_Id) OR
     NOT OE_Globals.Equal(
       p_header_rec.Blanket_Number,
       p_old_db_header_rec.Blanket_Number) OR
     NOT OE_Globals.Equal(
       p_header_rec.Deliver_to_Contact_Id,
       p_old_db_header_rec.Deliver_To_Contact_Id) OR
     NOT OE_Globals.Equal(
       p_header_rec.Deliver_to_Org_Id,
       p_old_db_header_rec.Deliver_To_Org_Id) OR
     NOT OE_Globals.Equal(
       p_header_rec.Demand_Class_Code,
       p_old_db_header_rec.Demand_Class_Code) OR
     NOT OE_Globals.Equal(
       p_header_rec.Fob_point_Code,
       p_old_db_header_rec.Fob_point_Code) OR
     NOT OE_Globals.Equal(
       p_header_rec.Freight_Terms_Code,
       p_old_db_header_rec.Freight_terms_Code) OR
     NOT OE_Globals.Equal(
       p_header_rec.Invoice_To_Contact_Id,
       p_old_db_header_rec.Invoice_To_Contact_Id) OR
     NOT OE_Globals.Equal(
       p_header_rec.Invoice_To_Org_Id,
       p_old_db_header_rec.Invoice_To_Org_Id) OR
     NOT OE_Globals.Equal(
       p_header_rec.Invoicing_Rule_Id,
       p_old_db_header_rec.Invoicing_Rule_Id) OR
     NOT OE_Globals.Equal(
       p_header_rec.Price_List_Id,
       p_old_db_header_rec.Price_List_Id) OR
     NOT OE_Globals.Equal(
       p_header_rec.Request_date,
       p_old_db_header_rec.Request_date) OR
     NOT OE_Globals.Equal(
       p_header_rec.Return_reason_Code,
       p_old_db_header_rec.Return_reason_Code) OR
     NOT OE_Globals.Equal(
       p_header_rec.Salesrep_Id,
       p_old_db_header_rec.Salesrep_id) OR
     NOT OE_Globals.Equal(
       p_header_rec.Ship_From_Org_Id,
       p_old_db_header_rec.Ship_from_Org_id) OR
     NOT OE_Globals.Equal(
       p_header_rec.Ship_To_Contact_Id,
       p_old_db_header_rec.Ship_To_Contact_id) OR
     NOT OE_Globals.Equal(
       p_header_rec.Sold_To_Org_Id,
       p_old_db_header_rec.Sold_To_Org_id) OR
     NOT OE_Globals.Equal(
       p_header_rec.Tax_Exempt_Flag,
       p_old_db_header_rec.Tax_Exempt_Flag)
-- End Of Enhanced Cascading

      THEN
        IF p_header_rec.header_id IS NOT NULL AND
           p_header_rec.header_id <> FND_API.G_MISS_NUM THEN
          OE_Line_Util.Query_Rows
         (   p_header_id             => p_header_rec.header_id
           , x_line_tbl            => l_x_line_tbl
          );
        END IF;

   END IF;

 -- Check if Read_Cascadable_Fields is called or not. If not the call and build  -- the record.

    IF OE_OE_FORM_HEADER.g_cascade_test_record.p_cached='N' THEN
      OE_OE_FORM_HEADER.Read_Cascadable_Fields
        (
          x_cascade_record=>OE_OE_FORM_HEADER.g_cascade_test_record
        );
    END IF;

    IF l_x_line_tbl.count  >0 THEN
      FOR  i IN  l_x_line_tbl.first .. l_x_line_tbl.last LOOP
       /* Fix Bug # 3271580 : Cascade only if line is Open */
       IF l_x_line_tbl(i).open_flag = 'Y' THEN

       /* Fix Bug # 4131746/ base bug# 4056303 : Server Connect */
        l_x_line_tbl(i).change_reason := 'SYSTEM';
        l_x_old_line_tbl(i):=l_x_line_tbl(i);

        IF NOT OE_Globals.Equal(
        p_header_rec.cust_po_number,
        p_old_db_header_rec.cust_po_number) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_customer_po='Y'

        THEN
           l_x_line_tbl(i).cust_po_number:=p_header_rec.cust_po_number;
        END IF;

        IF NOT OE_Globals.Equal(
        p_header_rec.payment_term_id,
        p_old_db_header_rec.payment_term_id) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_payment_term='Y'

        THEN
           l_x_line_tbl(i).payment_term_id:=p_header_rec.payment_term_id;
        END IF;

        IF NOT OE_Globals.Equal(
        p_header_rec.shipment_priority_code,
        p_old_db_header_rec.shipment_priority_code) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_shipment_priority='Y'

        THEN
           l_x_line_tbl(i).shipment_priority_code:=p_header_rec.shipment_priority_code;
        END IF;

        IF NOT OE_Globals.Equal(
        p_header_rec.shipping_method_code,
        p_old_db_header_rec.shipping_method_code) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_shipping_method='Y'

        THEN
           l_x_line_tbl(i).shipping_method_code:=p_header_rec.shipping_method_code;
        END IF;

        IF NOT OE_Globals.Equal(
        p_header_rec.ship_to_org_id,
        p_old_db_header_rec.ship_to_org_id) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_ship_to='Y'

        THEN
           l_x_line_tbl(i).ship_to_org_id:=p_header_rec.ship_to_org_id;
        END IF;

        IF NOT OE_Globals.Equal(
        p_header_rec.agreement_id,
        p_old_db_header_rec.agreement_id) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_agreement='Y'

        THEN
           l_x_line_tbl(i).agreement_id:=p_header_rec.agreement_id;
        END IF;

        --Key Transaction dates
        IF NOT OE_Globals.Equal(
          p_header_rec.order_firmed_date,
          p_old_db_header_rec.order_firmed_date) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_order_firmed_date='Y'

        THEN
             l_x_line_tbl(i).order_firmed_date:=p_header_rec.order_firmed_date;
        END IF;

        IF NOT OE_Globals.Equal(
          p_header_rec.Accounting_Rule_Id,
          p_old_db_header_rec.Accounting_Rule_Id) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_accounting_rule='Y'

        THEN
            l_x_line_tbl(i).Accounting_Rule_Id:=p_header_rec.Accounting_Rule_Id;
        END IF;

        IF NOT OE_Globals.Equal(
          p_header_rec.Blanket_Number,
          p_old_db_header_rec.Blanket_Number) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_blanket_number='Y'

        THEN
            l_x_line_tbl(i).Blanket_Number:=p_header_rec.Blanket_Number;
        END IF;

       IF NOT OE_Globals.Equal(
         p_header_rec.Deliver_to_Contact_Id,
         p_old_db_header_rec.Deliver_To_Contact_Id) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_deliver_to_contact='Y'

        THEN
            l_x_line_tbl(i).Deliver_To_Contact_id:=p_header_rec.Deliver_To_Contact_Id;
        END IF;

        IF NOT OE_Globals.Equal(
         p_header_rec.Deliver_to_Org_Id,
         p_old_db_header_rec.Deliver_To_Org_Id) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_deliver_to='Y'

        THEN
            l_x_line_tbl(i).Deliver_To_Org_id:=p_header_rec.Deliver_to_Org_Id;
       END IF;

       IF NOT OE_Globals.Equal(
         p_header_rec.Demand_Class_Code,
         p_old_db_header_rec.Demand_Class_Code) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_demand_class='Y'

        THEN
            l_x_line_tbl(i).Demand_Class_Code:=p_header_rec.Demand_Class_Code;
       END IF;

      IF NOT OE_Globals.Equal(
        p_header_rec.Fob_point_Code,
        p_old_db_header_rec.Fob_point_Code) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_fob_point='Y'

      THEN
            l_x_line_tbl(i).Fob_Point_Code:=p_header_rec.Fob_Point_Code;
      END IF;

      IF NOT OE_Globals.Equal(
        p_header_rec.Freight_Terms_Code,
        p_old_db_header_rec.Freight_Terms_Code) AND

        -- Bug 8330454 OE_OE_FORM_HEADER.g_cascade_test_record.p_fob_point='Y'
        OE_OE_FORM_HEADER.g_cascade_test_record.p_freight_terms = 'Y'    --Bug 8330454


       THEN
            l_x_line_tbl(i).Freight_Terms_Code:=p_header_rec.Freight_Terms_Code;
      END IF;

      IF NOT OE_Globals.Equal(
        p_header_rec.Invoice_To_Contact_Id,
        p_old_db_header_rec.Invoice_To_Contact_Id) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_bill_to_contact='Y'

      THEN
            l_x_line_tbl(i).Invoice_To_Contact_Id:=p_header_rec.Invoice_To_Contact_Id;
      END IF;

      IF NOT OE_Globals.Equal(
        p_header_rec.Invoice_To_Org_Id,
        p_old_db_header_rec.Invoice_To_Org_Id) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_bill_to='Y'

       THEN
            l_x_line_tbl(i).Invoice_To_Org_Id:=p_header_rec.Invoice_To_Org_Id;
      END IF;

      IF NOT OE_Globals.Equal(
        p_header_rec.Invoicing_Rule_Id,
        p_old_db_header_rec.Invoicing_Rule_Id) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_invoicing_rule='Y'

      THEN
            l_x_line_tbl(i).Invoicing_Rule_Id:=p_header_rec.Invoicing_Rule_Id;
      END IF;

      IF NOT OE_Globals.Equal(
        p_header_rec.Price_List_Id,
        p_old_db_header_rec.Price_List_Id) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_price_list='Y'

      THEN
            l_x_line_tbl(i).Price_List_Id:=p_header_rec.Price_List_Id;
      END IF;


      IF NOT OE_Globals.Equal(
        p_header_rec.Request_date,
        p_old_db_header_rec.Request_date) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_request_date='Y'

      THEN
            l_x_line_tbl(i).Request_Date:=p_header_rec.Request_Date;
      END IF;

      IF NOT OE_Globals.Equal(
        p_header_rec.Return_Reason_Code,
        p_old_db_header_rec.Return_Reason_Code) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_return_reason='Y'

      THEN
            l_x_line_tbl(i).Return_Reason_Code:=p_header_rec.Return_reason_Code;
      END IF;

      IF NOT OE_Globals.Equal(
        p_header_rec.Salesrep_Id,
        p_old_db_header_rec.Salesrep_id) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_salesperson='Y'

      THEN
            l_x_line_tbl(i).Salesrep_Id:=p_header_rec.Salesrep_Id;
      END IF;

      IF NOT OE_Globals.Equal(
        p_header_rec.Ship_From_Org_Id,
        p_old_db_header_rec.Ship_From_Org_id) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_warehouse='Y'

      THEN
            l_x_line_tbl(i).Ship_From_Org_Id:=p_header_rec.Ship_From_Org_Id;
      END IF;

      IF NOT OE_Globals.Equal(
        p_header_rec.Ship_To_Contact_Id,
        p_old_db_header_rec.Ship_To_Contact_Id) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_ship_to_contact='Y'

      THEN
            l_x_line_tbl(i).Ship_To_Contact_Id:=p_header_rec.Ship_To_Contact_Id;
      END IF;

      IF NOT OE_Globals.Equal(
        p_header_rec.Sold_To_Org_Id,
        p_old_db_header_rec.Sold_To_Org_id) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_customer='Y'

      THEN
            l_x_line_tbl(i).Sold_To_Org_Id:=p_header_rec.Sold_To_Org_Id;
      END IF;

      IF NOT OE_Globals.Equal(
        p_header_rec.Tax_Exempt_Flag,
        p_old_db_header_rec.Tax_Exempt_Flag) AND

        OE_OE_FORM_HEADER.g_cascade_test_record.p_tax_exempt='Y'

       THEN
            l_x_line_tbl(i).Tax_Exempt_Flag:=p_header_rec.Tax_Exempt_Flag;
      END IF;

        l_x_line_tbl(i).operation:= OE_GLOBALS.G_OPR_UPDATE;
        l_x_line_tbl(i).change_reason:='SYSTEM';

       END IF; -- Cascade Only if Line is Open
       END LOOP;

     END IF;
    oe_debug_pub.add('Entering OE_OE_FOR_HEADER.Cascade Attribute-Before PO');

    -- Added for cascading in Mass Change ER 7509356
    IF OE_MASS_CHANGE_PVT.IS_MASS_CHANGE = 'T' THEN
       l_init_msg_list :=   FND_API.G_FALSE;
    END IF;

   OE_GLOBALS.G_UI_FLAG := TRUE;
   Oe_Order_Pvt.Process_order
       (   p_api_version_number          => 1.0
        ,   p_init_msg_list               => l_init_msg_list
        ,   x_return_status               => l_return_status
        ,   x_msg_count                   => x_msg_count
        ,   x_msg_data                    => x_msg_data
        ,   p_control_rec                 => l_control_rec
        ,   p_x_line_tbl                  => l_x_line_tbl
        ,   p_old_line_tbl                => l_x_old_line_tbl
        ,   p_x_header_rec                  => l_x_header_rec
        ,   p_x_Header_Adj_tbl              => l_x_Header_Adj_tbl
        ,   p_x_header_price_att_tbl        => l_x_header_price_att_tbl
        ,   p_x_Header_Adj_att_tbl          => l_x_Header_Adj_att_tbl
        ,   p_x_Header_Adj_Assoc_tbl        => l_x_Header_Adj_Assoc_tbl
        ,   p_x_Header_Scredit_tbl          => l_x_Header_Scredit_tbl
--serla begin
        ,   p_x_Header_Payment_tbl          => l_x_Header_Payment_tbl
--serla end
        ,   p_x_Line_Adj_tbl                => l_x_Line_Adj_tbl
        ,   p_x_Line_Price_att_tbl          => l_x_Line_Price_att_tbl
        ,   p_x_Line_Adj_att_tbl            => l_x_Line_Adj_att_tbl
        ,   p_x_Line_Adj_Assoc_tbl          => l_x_Line_Adj_Assoc_tbl
        ,   p_x_Line_Scredit_tbl            => l_x_Line_Scredit_tbl
--serla begin
        ,   p_x_Line_Payment_tbl            => l_x_Line_Payment_tbl
--serla end
        ,   p_x_action_request_tbl          => l_x_Action_Request_tbl
        ,   p_x_lot_serial_tbl              => l_x_lot_serial_tbl

        );

    oe_debug_pub.add('Entering OE_OE_FOR_HEADER.Cascade Attribute-After PO');


    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data
-- Commenting out for now not to display the same messages multiple times
/*
    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    ); */


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO SAVEPOINT Header_Cascade_Attributes;
	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO SAVEPOINT Header_Cascade_Attributes;

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN
     ROLLBACK TO SAVEPOINT Header_Cascade_Attributes;

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'CASCADE_HEADER_ATTRIBUTES'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END  CASCADE_HEADER_ATTRIBUTES;

PROCEDURE get_customer_details( p_site_use_id IN NUMBER,
                                p_site_use_code IN VARCHAR2,
x_customer_id OUT NOCOPY NUMBER,
x_customer_name OUT NOCOPY VARCHAR2,
x_customer_number OUT NOCOPY VARCHAR2
                                     ) IS

BEGIN
/*2172651*/

		select  /* MOAC_SQL_CHANGE */ cust.cust_account_id,
		       party.party_name,
		       cust.account_number
        	INTO   x_customer_id,
               	       x_customer_name,
                       x_customer_number
		from
		       hz_cust_site_uses_all site,
		       hz_cust_acct_sites_all cas,
                       hz_cust_accounts cust,
                       hz_parties party
                where site.site_use_code = p_site_use_code
		and site_use_id = p_site_use_id
		and site.cust_acct_site_id = cas.cust_acct_site_id
		and cas.cust_account_id = cust.cust_account_id
		and cust.party_id=party.party_id;
/*2172651*/
EXCEPTION

        WHEN NO_DATA_FOUND THEN
         Null;
        When too_many_rows then
         Null;
	   When others then
	    Null;

END get_customer_details;


PROCEDURE CREATE_AGREEMENT(
x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_price_list_id                 IN  Number
,   p_agreement_name                IN  VARCHAR2
,   p_term_id                       IN  Number
,   p_sold_to_org_id                IN  Number

)

IS PRAGMA AUTONOMOUS_TRANSACTION;

 l_msg_count number := 0;
 l_msg_data varchar2(2000);

 p_Agreement_rec               OE_Pricing_Cont_PUB.Agreement_Rec_Type;
 p_Agreement_val_rec           OE_Pricing_Cont_PUB.Agreement_Val_Rec_Type;
 p_price_list_rec QP_PRICE_LIST_PUB.Price_List_Rec_Type;
 p_price_list_val_rec QP_PRICE_LIST_PUB.Price_List_Val_Rec_Type;

 p_price_list_line_tbl QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
 p_price_list_line_val_tbl QP_PRICE_LIST_PUB.Price_List_Line_Val_Tbl_Type;

 p_pricing_attr_tbl QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
 p_pricing_attr_val_tbl QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;

 x_Agreement_rec             OE_Pricing_Cont_PUB.Agreement_Rec_Type;
 x_Agreement_val_rec         OE_Pricing_Cont_PUB.Agreement_Val_Rec_Type;

 x_price_list_rec QP_PRICE_LIST_PUB.Price_List_Rec_Type;
 x_price_list_val_rec QP_PRICE_LIST_PUB.Price_List_Val_Rec_Type;

 x_price_list_line_tbl QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
 x_price_list_line_val_tbl QP_PRICE_LIST_PUB.Price_List_Line_Val_Tbl_Type;

 x_pricing_attr_tbl QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
 x_pricing_attr_val_tbl QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;

BEGIN


    oe_debug_pub.add('Entering OE_OE_FORM_HEADER.Create_Agreement', 1);

p_Agreement_rec.name :=  p_agreement_name;
p_agreement_rec.creation_date :=sysdate;
p_agreement_rec.created_by := FND_GLOBAL.USER_ID;
p_agreement_rec.last_update_date := sysdate;
p_agreement_rec.last_updated_by := FND_GLOBAL.USER_ID;
p_agreement_rec.agreement_type_code := 'STANDARD';
--p_agreement_rec.agreement_num := '2001';
p_agreement_rec.revision := '1';
p_agreement_rec.revision_date := sysdate;
p_agreement_rec.term_id := p_term_id;
p_agreement_rec.OVERRIDE_IRULE_FLAG := 'Y';
p_agreement_rec.OVERRIDE_ARULE_FLAG := 'Y';
p_agreement_rec.agreement_id := FND_API.G_MISS_NUM;
p_agreement_rec.operation    := QP_GLOBALS.G_OPR_CREATE;
p_agreement_rec.price_list_id := p_price_list_id;
p_agreement_rec.sold_to_org_id := p_sold_to_org_id;
    oe_debug_pub.add('Before Process_Agreement', 1);

    OE_Pricing_Cont_PUB.Process_Agreement
(   p_api_version_number            => 1.0

,   p_init_msg_list                 => FND_API.G_TRUE
,   p_return_values                 => FND_API.G_FALSE
,   p_commit                        => FND_API.G_FALSE
,   x_return_status                 => x_return_status
,   x_msg_count                     => x_msg_count
,   x_msg_data                      => x_msg_data
,   p_Agreement_rec                 => p_Agreement_rec
,   x_Agreement_rec                 => x_Agreement_rec
,   x_Agreement_val_rec             => x_Agreement_val_rec
,   x_Price_LHeader_rec             => x_price_list_rec
,   x_Price_LHeader_val_rec         => x_price_list_val_rec

,   x_Price_LLine_tbl             => x_price_list_line_tbl
,   x_Price_LLine_val_tbl         => x_price_list_line_val_tbl
,   x_Pricing_Attr_tbl              => x_pricing_attr_tbl
,   x_Pricing_Attr_val_tbl          => x_pricing_attr_val_tbl
);
    oe_debug_pub.add('After Process_Agreement', 1);


   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status  = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;

   END IF;
    oe_debug_pub.add('Before Commit', 1);

   COMMIT;
    oe_debug_pub.add('After Commit', 1);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK;
        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );



    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


    WHEN OTHERS THEN
     ROLLBACK;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


END CREATE_AGREEMENT;

PROCEDURE Clear_Global_PO_Cache IS
  l_return_status               VARCHAR2(1);
BEGIN

  oe_debug_pub.add('hash before prn');

-- bug 3588660
  IF OE_CODE_CONTROL.Code_Release_Level >= '110508' THEN


     IF (( OE_ORDER_UTIL.g_header_rec.header_id is not null
       AND OE_ORDER_UTIL.g_header_rec.header_id <> FND_API.G_MISS_NUM)
       OR  OE_ORDER_UTIL.g_header_adj_tbl.count >0
       OR OE_ORDER_UTIL.g_Header_Scredit_tbl.count >0
       OR OE_ORDER_UTIL.g_line_tbl.count >0
       OR OE_ORDER_UTIL.g_Line_Adj_tbl.count >0
       OR OE_ORDER_UTIL.g_Line_Scredit_tbl.count >0
       OR  OE_ORDER_UTIL.g_Lot_Serial_tbl.count >0 ) THEN

  oe_debug_pub.add('hash calling prn');

         OE_Order_PVT.Process_Requests_And_Notify
		( p_process_requests		=> TRUE
		, p_notify			=> FALSE
		, x_return_status		=> l_return_status
		);

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --zbutt change bug#4772531  begin
        oe_order_util.clear_global_picture(l_return_status) ;
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        --zbutt change bug#4772531 end

      END IF;
   END IF;

-- moved down for bug 3686007

  OE_ORDER_CACHE.g_header_rec.header_id:=null;
  OE_GLOBALS.G_HEADER_CREATED := FALSE;
  g_db_header_rec := OE_Order_PUB.G_MISS_HEADER_REC;


END Clear_Global_PO_Cache;

PROCEDURE Copy_Attribute_To_Rec
(   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   p_header_dff_rec                IN  OE_OE_FORM_HEADER.header_dff_rec_type
,   p_date_format_mask              IN  VARCHAR2 DEFAULT 'DD-MON-YYYY HH24:MI:SS'
,   x_header_rec                    IN OUT NOCOPY OE_Order_PUB.Header_Rec_Type
,   x_old_header_rec                IN OUT NOCOPY OE_ORDER_PUB.Header_Rec_Type
)
IS
l_date_format_mask            VARCHAR2(30) := p_date_format_mask;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF p_attr_id =    OE_Header_Util.G_ACCOUNTING_RULE THEN
        x_header_rec.accounting_rule_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_ACCOUNTING_RULE_DURATION THEN
        x_header_rec.accounting_rule_duration := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_AGREEMENT THEN
        x_header_rec.agreement_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_BLANKET_NUMBER THEN
          x_header_rec.blanket_number := TO_NUMBER(p_attr_value);
    --kmuruges
    ELSIF p_attr_id = OE_Header_Util.G_quote_date THEN
         -- x_header_rec.quote_date := TO_DATE(p_attr_value,l_date_format_mask);
	 x_header_rec.quote_date := fnd_date.string_to_date(p_attr_value,l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Header_Util.G_quote_number THEN
          x_header_rec.quote_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_sales_document_name THEN
          x_header_rec.sales_document_name := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_transaction_phase THEN
          x_header_rec.transaction_phase_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_user_status THEN
          x_header_rec.user_status_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_draft_submitted THEN
          x_header_rec.draft_submitted_flag := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_source_document_version THEN
      x_header_rec.source_document_version_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_sold_to_site_use THEN
      x_header_rec.sold_to_site_use_id := TO_NUMBER(p_attr_value);

    ELSIF p_attr_id = OE_Header_Util.G_ib_owner THEN
          x_header_rec.ib_owner := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_ib_installed_at_location THEN
          x_header_rec.ib_installed_at_location := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_ib_current_location THEN
          x_header_rec.ib_current_location := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_end_customer_site_use THEN
          x_header_rec.end_customer_site_use_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_end_customer_contact THEN
          x_header_rec.end_customer_contact_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_end_customer THEN
          x_header_rec.end_customer_id := TO_NUMBER(p_attr_value);
    --kmuruges end
    ELSIF p_attr_id = OE_Header_Util.G_BOOKED THEN
        x_header_rec.booked_flag := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_BOOKED_DATE THEN
        x_header_rec.booked_date := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_CANCELLED THEN
        x_header_rec.cancelled_flag := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_CONVERSION_RATE THEN
        x_header_rec.conversion_rate := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_CONVERSION_RATE_DATE THEN
        --x_header_rec.conversion_rate_date := TO_DATE(p_attr_value,l_date_format_mask);
	x_header_rec.conversion_rate_date := fnd_date.string_to_date(p_attr_value,l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Header_Util.G_CONVERSION_TYPE THEN
        x_header_rec.conversion_type_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_CUSTOMER_PREFERENCE_SET THEN
        x_header_rec.CUSTOMER_PREFERENCE_SET_CODE := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_CUST_PO_NUMBER THEN
        x_header_rec.cust_po_number := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_DEFAULT_FULFILLMENT_SET THEN
        x_header_rec.DEFAULT_FULFILLMENT_SET := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_DELIVER_TO_CONTACT THEN
        x_header_rec.deliver_to_contact_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_DELIVER_TO_ORG THEN
        x_header_rec.deliver_to_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_DEMAND_CLASS THEN
        x_header_rec.demand_class_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_EXPIRATION_DATE THEN
        --x_header_rec.expiration_date := TO_DATE(p_attr_value, l_date_format_mask);
	x_header_rec.expiration_date := fnd_date.string_to_date(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Header_Util.G_EARLIEST_SCHEDULE_LIMIT THEN
        x_header_rec.earliest_schedule_limit := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_FOB_POINT THEN
        x_header_rec.fob_point_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_FREIGHT_CARRIER THEN
        x_header_rec.freight_carrier_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_FREIGHT_TERMS THEN
        x_header_rec.freight_terms_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_FULFILLMENT_SET_NAME THEN
        x_header_rec.FULFILLMENT_SET_NAME := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_HEADER THEN
        x_header_rec.header_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_INVOICE_TO_CONTACT THEN
        x_header_rec.invoice_to_contact_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_INVOICE_TO_ORG THEN
        x_header_rec.invoice_to_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_INVOICING_RULE THEN
        x_header_rec.invoicing_rule_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_LATEST_SCHEDULE_LIMIT THEN
        x_header_rec.latest_schedule_limit := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_LINE_SET_NAME THEN
        x_header_rec.LINE_SET_NAME := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_OPEN THEN
        x_header_rec.open_flag := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_ORDERED_DATE THEN
       -- x_header_rec.ordered_date := TO_DATE(p_attr_value, l_date_format_mask);
        x_header_rec.ordered_date := fnd_date.string_to_date(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Header_Util.G_ORDER_DATE_TYPE_CODE THEN
        x_header_rec.order_date_type_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_ORDER_NUMBER THEN
        x_header_rec.order_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_ORDER_SOURCE THEN
        x_header_rec.order_source_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_ORDER_TYPE THEN
        x_header_rec.order_type_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_ORG THEN
        x_header_rec.org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_ORIG_SYS_DOCUMENT_REF THEN
        x_header_rec.orig_sys_document_ref := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_PARTIAL_SHIPMENTS_ALLOWED THEN
        x_header_rec.partial_shipments_allowed := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_PAYMENT_TERM THEN
        x_header_rec.payment_term_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_PRICE_LIST THEN
        x_header_rec.price_list_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_PRICING_DATE THEN
        --x_header_rec.pricing_date := TO_DATE(p_attr_value, l_date_format_mask);
	x_header_rec.pricing_date := fnd_date.string_to_date(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Header_Util.G_REQUEST_DATE THEN
        --x_header_rec.request_date := TO_DATE(p_attr_value, l_date_format_mask);
	x_header_rec.request_date := fnd_date.string_to_date(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Header_Util.G_SHIPMENT_PRIORITY THEN
        x_header_rec.shipment_priority_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_SHIPPING_METHOD THEN
        x_header_rec.shipping_method_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_SHIP_FROM_ORG THEN
        x_header_rec.ship_from_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_SHIP_TOLERANCE_ABOVE THEN
        x_header_rec.ship_tolerance_above := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_SHIP_TOLERANCE_BELOW THEN
        x_header_rec.ship_tolerance_below := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_SHIP_TO_CONTACT THEN
        x_header_rec.ship_to_contact_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_SHIP_TO_ORG THEN
        x_header_rec.ship_to_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_SOLD_TO_CONTACT THEN
        x_header_rec.sold_to_contact_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_SOLD_TO_ORG THEN
        x_header_rec.sold_to_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_SOLD_TO_PHONE THEN
        x_header_rec.sold_to_phone_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_SOURCE_DOCUMENT THEN
        x_header_rec.source_document_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_SOURCE_DOCUMENT_TYPE THEN
        x_header_rec.source_document_type_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Header_Util.G_TAX_EXEMPT THEN
        x_header_rec.tax_exempt_flag := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_TAX_EXEMPT_NUMBER THEN
        x_header_rec.tax_exempt_number := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_TAX_EXEMPT_REASON THEN
        x_header_rec.tax_exempt_reason_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_TAX_POINT THEN
        x_header_rec.tax_point_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_TRANSACTIONAL_CURR THEN
        x_header_rec.transactional_curr_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_VERSION_NUMBER THEN
        x_header_rec.version_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id =    OE_Header_Util.G_SALESREP THEN
        x_header_rec.salesrep_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id =    OE_Header_Util.G_SALES_CHANNEL THEN
        x_header_rec.sales_channel_code := p_attr_value;
    ELSIF p_attr_id =    OE_Header_Util.G_RETURN_REASON THEN
        x_header_rec.return_reason_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_PAYMENT_TYPE THEN
        x_header_rec.payment_type_code := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_PAYMENT_AMOUNT THEN
        x_header_rec.payment_amount := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id =    OE_Header_Util.G_CHECK_NUMBER THEN
        x_header_rec.check_number := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_CREDIT_CARD THEN
        x_header_rec.credit_card_code := p_attr_value;
    ELSIF p_attr_id =    OE_Header_Util.G_CREDIT_CARD_HOLDER_NAME THEN
        x_header_rec.credit_card_holder_name := p_attr_value;
    ELSIF p_attr_id =    OE_Header_Util.G_CREDIT_CARD_NUMBER THEN
        x_header_rec.credit_card_number := p_attr_value;
    ELSIF p_attr_id = Oe_header_util.G_INSTRUMENT_SECURITY THEN--R12 CC Encryption
	  x_header_rec.instrument_security_code := p_attr_value;
    ELSIF p_attr_id = Oe_header_util.G_CC_INSTRUMENT THEN
	  x_header_rec.CC_INSTRUMENT_ID := p_attr_value;
    ELSIF p_attr_id = Oe_header_util.G_CC_INSTRUMENT_ASSIGNMENT THEN
	  x_header_rec.CC_INSTRUMENT_ASSIGNMENT_ID := p_attr_value; --R12 CC Encryption
    ELSIF p_attr_id =    OE_Header_Util.G_CREDIT_CARD_EXPIRATION_DATE THEN
        --x_header_rec.credit_card_expiration_date := TO_DATE(p_attr_value, l_date_format_mask);
	x_header_rec.credit_card_expiration_date := fnd_date.string_to_date(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id =    OE_Header_Util.G_CREDIT_CARD_APPROVAL_DATE   THEN
       -- x_header_rec.credit_card_approval_date   := TO_DATE(p_attr_value, l_date_format_mask);
        x_header_rec.credit_card_approval_date   := fnd_date.string_to_date(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id =    OE_Header_Util.G_CREDIT_CARD_APPROVAL THEN
        x_header_rec.credit_card_approval_code := p_attr_value;
    ELSIF p_attr_id =    OE_Header_Util.G_FIRST_ACK THEN
        x_header_rec.first_ack_code := p_attr_value;
    ELSIF p_attr_id =    OE_Header_Util.G_FIRST_ACK_DATE THEN
       -- x_header_rec.first_ack_date := TO_DATE(p_attr_value, l_date_format_mask);
       x_header_rec.first_ack_date := fnd_date.string_to_date(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id =    OE_Header_Util.G_LAST_ACK THEN
        x_header_rec.last_ack_code := p_attr_value;
    ELSIF p_attr_id =    OE_Header_Util.G_SHIPPING_INSTRUCTIONS THEN
        x_header_rec.shipping_instructions := p_attr_value;
    ELSIF p_attr_id =    OE_Header_Util.G_PACKING_INSTRUCTIONS THEN
        x_header_rec.packing_instructions := p_attr_value;
    ELSIF p_attr_id =    OE_Header_Util.G_LAST_ACK_DATE THEN
       --x_header_rec.last_ack_date := TO_DATE(p_attr_value, l_date_format_mask);
       x_header_rec.last_ack_date := fnd_date.string_to_date(p_attr_value, l_date_format_mask);--bug5402396
    ELSIF p_attr_id =    OE_Header_Util.G_ORDER_CATEGORY THEN
        x_header_rec.order_category_code := p_attr_value;

    ELSIF p_attr_id = OE_Header_Util.G_CONTRACT_TEMPLATE THEN
        x_header_rec.contract_template_id := TO_NUMBER(p_attr_value);

    ELSIF p_attr_id = OE_Header_Util.G_CONTRACT_SOURCE_DOC_TYPE THEN
        x_header_rec.contract_source_doc_type_code := p_attr_value;

    ELSIF p_attr_id = OE_Header_Util.G_CONTRACT_SOURCE_DOCUMENT THEN
        x_header_rec.contract_source_document_id := TO_NUMBER(p_attr_value);

    ELSIF p_attr_id = OE_Header_Util.G_SUPPLIER_SIGNATURE THEN
        x_header_rec.supplier_signature := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_CUSTOMER_SIGNATURE THEN
        x_header_rec.customer_signature := p_attr_value;
    ELSIF p_attr_id = OE_Header_Util.G_CUSTOMER_SIGNATURE_DATE THEN
       -- x_header_rec.customer_signature_date := TO_DATE(p_attr_value, l_date_format_mask);
        x_header_rec.customer_signature_date := fnd_date.string_to_date(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Header_Util.G_SUPPLIER_SIGNATURE_DATE THEN
      --  x_header_rec.supplier_signature_date := TO_DATE(p_attr_value, l_date_format_mask);
          x_header_rec.supplier_signature_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask);

    ELSIF p_attr_id = OE_Header_Util.G_ATTRIBUTE1
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE10
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE11
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE12
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE13
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE14
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE15
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE16   --For bug 2184255
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE17
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE18
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE19
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE2
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE20
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE3
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE4
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE5
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE6
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE7
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE8
    OR     p_attr_id = OE_Header_Util.G_ATTRIBUTE9
    OR     p_attr_id = OE_Header_Util.G_CONTEXT
    THEN

        x_header_rec.attribute1        := p_header_dff_rec.attribute1;
        x_header_rec.attribute10       := p_header_dff_rec.attribute10;
        x_header_rec.attribute11       := p_header_dff_rec.attribute11;
        x_header_rec.attribute12       := p_header_dff_rec.attribute12;
        x_header_rec.attribute13       := p_header_dff_rec.attribute13;
        x_header_rec.attribute14       := p_header_dff_rec.attribute14;
        x_header_rec.attribute15       := p_header_dff_rec.attribute15;
        x_header_rec.attribute16       := p_header_dff_rec.attribute16;   --For bug 2184255
        x_header_rec.attribute17       := p_header_dff_rec.attribute17;
        x_header_rec.attribute18       := p_header_dff_rec.attribute18;
        x_header_rec.attribute19       := p_header_dff_rec.attribute19;
        x_header_rec.attribute2        := p_header_dff_rec.attribute2;
        x_header_rec.attribute20       := p_header_dff_rec.attribute20;
        x_header_rec.attribute3        := p_header_dff_rec.attribute3;
        x_header_rec.attribute4        := p_header_dff_rec.attribute4;
        x_header_rec.attribute5        := p_header_dff_rec.attribute5;
        x_header_rec.attribute6        := p_header_dff_rec.attribute6;
        x_header_rec.attribute7        := p_header_dff_rec.attribute7;
        x_header_rec.attribute8        := p_header_dff_rec.attribute8;
        x_header_rec.attribute9        := p_header_dff_rec.attribute9;
        x_header_rec.context           := p_header_dff_rec.context;

--        null; -- Kris get desc flec working

    ELSIF p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE1
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE10
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE11
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE12
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE13
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE14
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE15
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE16
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE17
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE18
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE19
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE2
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE20
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE3
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE4
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE5
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE6
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE7
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE8
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE9
    OR     p_attr_id = OE_Header_Util.G_GLOBAL_ATTRIBUTE_CATEGORY
    THEN

        x_header_rec.global_attribute1 := p_header_dff_rec.global_attribute1;
        x_header_rec.global_attribute10 := p_header_dff_rec.global_attribute10;
        x_header_rec.global_attribute11 := p_header_dff_rec.global_attribute11;
        x_header_rec.global_attribute12 := p_header_dff_rec.global_attribute12;
        x_header_rec.global_attribute13 := p_header_dff_rec.global_attribute13;
        x_header_rec.global_attribute14 := p_header_dff_rec.global_attribute14;
        x_header_rec.global_attribute15 := p_header_dff_rec.global_attribute15;
        x_header_rec.global_attribute16 := p_header_dff_rec.global_attribute16;
        x_header_rec.global_attribute17 := p_header_dff_rec.global_attribute17;
        x_header_rec.global_attribute18 := p_header_dff_rec.global_attribute18;
        x_header_rec.global_attribute19 := p_header_dff_rec.global_attribute19;
        x_header_rec.global_attribute2 :=  p_header_dff_rec.global_attribute2;
        x_header_rec.global_attribute20 := p_header_dff_rec.global_attribute20;
        x_header_rec.global_attribute3 := p_header_dff_rec.global_attribute3;
        x_header_rec.global_attribute4 := p_header_dff_rec.global_attribute4;
        x_header_rec.global_attribute5 := p_header_dff_rec.global_attribute5;
        x_header_rec.global_attribute6 := p_header_dff_rec.global_attribute6;
        x_header_rec.global_attribute7 := p_header_dff_rec.global_attribute7;
        x_header_rec.global_attribute8 := p_header_dff_rec.global_attribute8;
        x_header_rec.global_attribute9 := p_header_dff_rec.global_attribute9;
        x_header_rec.global_attribute_category := p_header_dff_rec.global_attribute_category;

        null;  --Kris
    ELSIF  p_attr_id = OE_Header_Util.G_TP_CONTEXT
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE1
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE2
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE3
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE4
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE5
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE6
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE7
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE8
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE9
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE10
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE11
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE12
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE13
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE14
    OR     p_attr_id = OE_Header_Util.G_TP_ATTRIBUTE15
    THEN

        x_header_rec.tp_attribute1        := p_header_dff_rec.tp_attribute1;
        x_header_rec.tp_attribute10       := p_header_dff_rec.tp_attribute10;
        x_header_rec.tp_attribute11       := p_header_dff_rec.tp_attribute11;
        x_header_rec.tp_attribute12       := p_header_dff_rec.tp_attribute12;
        x_header_rec.tp_attribute13       := p_header_dff_rec.tp_attribute13;
        x_header_rec.tp_attribute14       := p_header_dff_rec.tp_attribute14;
        x_header_rec.tp_attribute15       := p_header_dff_rec.tp_attribute15;
        x_header_rec.tp_attribute2        := p_header_dff_rec.tp_attribute2;
        x_header_rec.tp_attribute3        := p_header_dff_rec.tp_attribute3;
        x_header_rec.tp_attribute4        := p_header_dff_rec.tp_attribute4;
        x_header_rec.tp_attribute5        := p_header_dff_rec.tp_attribute5;
        x_header_rec.tp_attribute6        := p_header_dff_rec.tp_attribute6;
        x_header_rec.tp_attribute7        := p_header_dff_rec.tp_attribute7;
        x_header_rec.tp_attribute8        := p_header_dff_rec.tp_attribute8;
        x_header_rec.tp_attribute9        := p_header_dff_rec.tp_attribute9;
        x_header_rec.tp_context           := p_header_dff_rec.tp_context;
    ELSE

        --  Unexpected error, unrecognized attribute

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attribute'
            ,   'Unrecognized attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
EXCEPTION
    WHEN OTHERS THEN
        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Copy_Attribute_To_Rec'
            );
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Copy_Attribute_To_Rec;

 PROCEDURE Validate_Phone_Number(
                             p_area_code IN VARCHAR2 default Null,
                             p_phone_number     IN VARCHAR2 default null,
                             p_country_code     IN VARCHAR2 default null,
                             x_valid OUT NOCOPY /* file.sql.39 change */ BOOLEAN,
                             x_area_codes OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                             x_phone_number_format OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                             x_phone_number_length OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                             )
 IS
 l_customer_id             Number;
 l_user_id                 Number;
 l_dummy                   varchar2(1);
 l_territory_code          Varchar2(80);
 l_phone_format_style   Varchar2(30);
 l_phone_country_code   Varchar2(30);
 l_area_code_size       number;
 l_msg_name Varchar2(500);
 l_count number:=0;
 l_total_count number:=0;
 CURSOR c_formats( l_territory_code VARCHAR2) IS
      select phone_format_style,area_code_size
      from hz_phone_formats
      where territory_code=l_territory_code;
 l_ph_style_match Boolean;
 l_phone_length number;
 l_temp_phone_format Varchar2(500);
 l_start Number;
 l_bug_count Number;
 l_user_territory_code Varchar2(2);
 l_sql_stmt    VARCHAR2(2000);
 l_area_code_length Number;
 l_filtered_phone_number Varchar2(300);
 l_phone_format Varchar2(300);
 l_AR_Sys_Param_Rec    AR_SYSTEM_PARAMETERS_ALL%ROWTYPE;

 BEGIN
  oe_debug_pub.add('Entering OE_OE_FORM_HEADER.Validate_Phone_Number', 1);
  IF OE_OE_FORM_HEADER.G_HZ_H_Installed IS NULL THEN
    SELECT COUNT(bug_id)
    INTO   l_bug_count
    FROM ad_bugs where bug_number IN ('2116159','2239222','2488745');
    IF l_bug_count>0 THEN
      OE_OE_FORM_HEADER.G_HZ_H_Installed:='Y';
    ELSE
      OE_OE_FORM_HEADER.G_HZ_H_Installed:='N';
    END IF;
  END IF;
  oe_debug_pub.add('Entering OE_OE_FORM_HEADER.Validate_Phone_Number-HZ Minipack'||OE_OE_FORM_HEADER.G_HZ_H_Installed, 1);

  IF OE_OE_FORM_HEADER.G_HZ_H_Installed='N' THEN
    x_valid:=TRUE;
  ELSE
  IF p_country_code IS NULL THEN
  BEGIN
   l_user_id :=   fnd_profile.value('USER_ID');
   select customer_id into l_customer_id
   from fnd_user
   where user_id = l_user_id;

    --check if the record is present in hz_parties
    select 1 into l_dummy
    from hz_parties
    where party_id = l_customer_id;


      ---Get user preferences

      l_user_territory_code:=
      hz_preference_pub.value_varchar2(
      l_customer_id,'TCA Phone','USER_TERRITORY_CODE');

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
   NULL;
  WHEN OTHERS THEN
   NULL;
  END;

  IF l_user_territory_code IS NULL THEN
     IF oe_code_control.code_release_level < '110510' THEN
        select default_country into l_user_territory_code
        from ar_system_parameters;
     ELSE
        l_AR_Sys_Param_Rec := OE_Sys_Parameters_Pvt.Get_AR_Sys_Params;
        l_user_territory_code:= l_AR_Sys_Param_Rec.default_country;
     END IF;

  END IF;
 ELSE
   l_user_territory_code:=p_country_code;
 END IF;
  oe_debug_pub.add('Entering OE_OE_FORM_HEADER.Validate_Phone_Number-User Territory'||
   l_user_territory_code, 1);



  IF l_user_territory_code IS NOT NULL THEN
    IF p_area_code IS NOT NULL THEN
      select Count(territory_code)
      into l_count
      from hz_phone_formats
      where territory_code=l_user_territory_code
      and area_code_size=length(p_area_code);

      IF l_count=0 THEN
       select Count(territory_code)
       into l_count
       from hz_phone_formats
       where territory_code=l_user_territory_code
       and area_code_size=0;

       select Count(territory_code)
       into l_total_count
       from hz_phone_formats
       where territory_code=l_user_territory_code;
        oe_debug_pub.add('Entering Validate_Phone_Number-1x'||l_total_count,1);

       IF l_count=0 AND l_total_count=0 THEN
        l_sql_stmt := 'SELECT Count(territory_code)'||
                      ' FROM hz_phone_country_codes'||
                      ' where territory_code=:1 and'||
                      ' NVL(area_code_length,length(:2))=length(:3)';
         EXECUTE IMMEDIATE l_sql_stmt INTO l_count
         USING l_user_territory_code,p_area_code,p_area_code;
         Null;
         IF l_count=0  THEN
           x_valid:=FALSE;
         ELSE
           x_valid:=TRUE;
         END IF;
        oe_debug_pub.add('Entering Validate_Phone_Number-2x'||l_count,1);
       ELSIF l_count=0 AND l_total_count<>0 THEN
        x_valid:=FALSE;
       ELSE
        x_valid:=TRUE;
       END IF;
      ELSE
       x_valid:=TRUE;
      END IF;

      IF NOT x_valid THEN
       FOR C1 IN c_formats(l_user_territory_code)
       LOOP
        IF x_area_codes IS NULL THEN
          x_area_codes:=c1.area_code_size;
        ELSIF x_area_codes IS NOT NULL THEN
          x_area_codes:=x_area_codes||', '||c1.area_code_size;
        END IF;
       END LOOP;

       IF x_area_codes IS NULL THEN
        l_sql_stmt:='SELECT area_code_length'||
                  ' FROM hz_phone_country_codes'||
                  ' WHERE territory_code=:l_territory_code';
        EXECUTE IMMEDIATE l_sql_stmt INTO l_phone_country_code
        USING l_user_territory_code;
        x_area_codes:=l_phone_country_code;

        IF l_phone_country_code IS NULL THEN
          x_valid:=True;
        END IF;

       END IF;
      END IF;
    END IF;

   IF p_phone_number IS NOT NULL THEN
     FOR C1 IN c_formats(l_user_territory_code)
     LOOP
      IF LENGTH(filter_phone_number(p_phone_number=>c1.phone_format_style,
                                    p_isformat=>1))-
         NVL(c1.area_code_size,0)=
         LENGTH(filter_phone_number(p_phone_number=>p_phone_number)) THEN
       l_ph_style_match:=TRUE;
      ELSE
       l_ph_style_match:=FALSE;
      END IF;
      NULL;
     END LOOP;

     IF l_ph_style_match THEN
       x_valid:=TRUE;
     ELSIF NOT l_ph_style_match THEN
       x_valid:=FALSE;
     ELSE
       x_valid:=FALSE;
     BEGIN
        l_sql_stmt:='SELECT phone_length-NVL(AREA_CODE_LENGTH,0)'||
                    ' FROM hz_phone_country_codes'||
                    ' where territory_code=:l_user_territory_code';
        EXECUTE IMMEDIATE l_sql_stmt INTO l_phone_length
        USING l_user_territory_code;
      IF NVL(l_phone_length,LENGTH(p_phone_number))=LENGTH(p_phone_number) THEN
        x_valid:=TRUE;
      END IF;
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
        x_valid:=TRUE;
     WHEN OTHERS THEN
      NULL;
     END;
     END IF;

     IF NOT x_valid THEN
       FOR C1 IN c_formats(l_user_territory_code)
       LOOP
        l_temp_phone_format:=Null;
        l_start:=0;
        IF x_phone_number_format IS NULL  THEN
         IF c1.area_code_size<>0 THEN
          l_temp_phone_format:=SUBSTR(c1.phone_format_style,(c1.area_code_size+1));
          l_start:=INSTR(l_temp_phone_format,'9');
          IF l_start>0 THEN
            l_temp_phone_format:=SUBSTR(l_temp_phone_format,l_start);
          END IF;
         ELSIF c1.area_code_size=0 THEN
          l_temp_phone_format:=SUBSTR(c1.phone_format_style,1);
         END IF;
          x_phone_number_format:=l_temp_phone_format;
        ELSIF x_phone_number_format IS NOT NULL THEN
         IF c1.area_code_size<>0 THEN
          l_temp_phone_format:=SUBSTR(c1.phone_format_style,(c1.area_code_size+1));
          l_start:=INSTR(l_temp_phone_format,'9');
          IF l_start>0 THEN
            l_temp_phone_format:=SUBSTR(l_temp_phone_format,l_start);
          END IF;
         ELSIF c1.area_code_size=0 THEN
          l_temp_phone_format:=SUBSTR(c1.phone_format_style,1);
         END IF;
          x_phone_number_format:=x_phone_number_format||', '||l_temp_phone_format;
        END IF;
       END LOOP;
       IF x_phone_number_format IS NULL THEN
        l_sql_stmt:='SELECT phone_length - NVL(area_code_length,0)'||
                  ' FROM hz_phone_country_codes'||
                  ' WHERE territory_code=:l_territory_code';
        EXECUTE IMMEDIATE l_sql_stmt INTO l_phone_country_code
        USING l_user_territory_code;
        x_phone_number_length:=l_phone_country_code;

         IF l_phone_country_code IS NULL OR l_phone_country_code<=0 THEN
          x_valid:=true;
        END IF;
       END IF;
     END IF;
   END IF;
 END IF;
 Null;
 END IF;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
   NULL;
  WHEN OTHERS THEN
   NULL;

 END Validate_Phone_Number;

 FUNCTION Filter_Phone_Number (
    p_phone_number                IN     VARCHAR2,
    p_isformat                    IN     NUMBER := 0
  ) RETURN VARCHAR2 IS

    l_filtered_number             VARCHAR2(100);

  BEGIN

    IF p_isformat = 0 THEN
      l_filtered_number := TRANSLATE (
      p_phone_number,
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz()- .+''~`\/@#$%^&*_,|}{[]?<>=";:',
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz');
    ELSE
      l_filtered_number := TRANSLATE (
        p_phone_number,
    '9012345678ABCDEFGHIJKLMNOPQRSTUVWXYZ()- .+''~`\/@#$%^&*_,|}{[]?<>=";:',
        '9');
    END IF;

    RETURN l_filtered_number;

  END Filter_Phone_Number;



PROCEDURE Check_Sec_Header_Attr
 (x_return_status         IN OUT NOCOPY varchar2,
  p_header_id             IN OUT NOCOPY NUMBER,
  p_operation             IN OUT NOCOPY VARCHAR2,
  p_column_name           IN VARCHAR2 DEFAULT NULL,
  x_msg_count             IN OUT NOCOPY NUMBER,
  x_msg_data              IN OUT NOCOPY VARCHAR2,
  x_constrained           IN OUT NOCOPY BOOLEAN)

IS
  l_header_rec           OE_ORDER_PUB.Header_rec_type;
  l_operation                    VARCHAR2(30);
  l_result	    		NUMBER;
  l_rowtype_rec					OE_AK_ORDER_HEADERS_V%ROWTYPE;
  l_action			NUMBER;
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 BEGIN

   IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'ENTER OE_OE_FORM_HEADER.Check_Sec_Header_Attr' , 1 ) ;
   END IF;

   IF p_column_name IS NOT NULL THEN
	-- Initializing return status to SUCCESS
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_header_id IS NOT NULL THEN
        OE_Header_Util.Query_Row
        (   p_header_id                   => p_header_id,
            x_header_rec                  =>l_header_rec
            );
     END IF;

     l_header_rec.operation :=p_operation;

     OE_HEADER_UTIL.API_Rec_To_Rowtype_Rec(l_header_rec,l_rowtype_rec);

     -- Initialize security global record
     OE_Header_SECURITY.g_record := l_rowtype_rec;

     IF l_header_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN
       l_operation := OE_PC_GLOBALS.CREATE_OP;
     ELSIF l_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE then
       l_operation := OE_PC_GLOBALS.UPDATE_OP;
     END IF;

     l_result := OE_Header_Security.Is_OP_Constrained
                                     (p_operation => l_operation
                                     ,p_column_name => p_column_name
                                     ,p_record => l_rowtype_rec
                                     ,x_on_operation_action => l_action
                                     );
     if l_result = OE_PC_GLOBALS.YES then
       x_constrained:=True;
       x_return_status := FND_API.G_RET_STS_ERROR;
     elsif l_result=OE_PC_GLOBALS.NO THEN
       x_constrained:=False;
     end if;

   END IF; -- if column name is not null

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        x_constrained := TRUE;
        x_return_status := FND_API.G_RET_STS_ERROR;
     WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   oe_msg_pub.count_and_get
      (   p_count     => x_msg_count
       ,  p_data      => x_msg_data);

   IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'EXIT OE_OE_FORM_HEADER.Check_Sec_Header_Attr' , 1 ) ;
   END IF;

END Check_Sec_Header_Attr;

--ABH
----------------------------------------------------------
     FUNCTION Get_Opr_Update
----------------------------------------------------------
     RETURN varchar2
     IS
     BEGIN
         RETURN OE_GLOBALS.G_OPR_UPDATE;
     END;
--ABH

-- Start Of Enhanced Cascading

--  Procedure  : Read_Cascadable_Fields

--  Parameters : One out NOCOPY parameter is of type OE_OE_FORM_HEADER.Cascade_record

--  Purpose    : This procedure will be called from Change_Attribute procedure
--               in OEXOEHDR.pld. A new OM look up OM:Header To Line Cascade
--               Attributes( with lookup_type=OM_HEADER_TO_LINE_CASCADE ) is
--               added. This holds the list of attributes that can trigger
--               cascading. User can use this look up to disable or enable
--               cascading for any specific attribute.

--               Read_Cascadable_Fields queries the enabled_flag from oe_lookups--               for each such attributes and store them in a record. Fields of --               this record will be used to determine whether cascading is
--               enabled or not for that specific attribute.One field in this
--               record is p_cached which determine whether the record is set
--               or not. So p_cached is used to make sure Read_Cascadable_Fields--               is called only once in a session.

  PROCEDURE Read_Cascadable_Fields
   (
     x_cascade_record   OUT NOCOPY OE_OE_FORM_HEADER.cascade_record
   )

   IS

    l_lookup_type    Varchar2(40):='OM_HEADER_TO_LINE_CASCADE';
    l_lookup_code    Varchar2(40);
    l_enabled_flag   Varchar2(1);
    p_cascade_record   OE_OE_FORM_HEADER.Cascade_record;

    Cursor C_LOOKUP (p_lookup_code1 Varchar2, p_lookup_type1 Varchar2) IS
   Select enabled_flag from oe_lookups where lookup_type=p_lookup_type1 and lookup_code=p_lookup_code1;


    BEGIN

      OE_DEBUG_PUB.ADD('Entering OE_OE_FORM_HEADER.Read_Cascadable_Fields',1);
       l_lookup_code :='ACCOUNTING_RULE';
        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;


       p_cascade_record.p_accounting_rule:=l_enabled_flag;

       l_lookup_code :='AGREEMENT';

        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;

       p_cascade_record.p_agreement:=l_enabled_flag;

       l_lookup_code :='CUSTOMER_PO';
	open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;


       p_cascade_record.p_customer_po:=l_enabled_flag;

       l_lookup_code :='BLANKET_NUMBER';

        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;

       p_cascade_record.p_blanket_number:=l_enabled_flag;

       l_lookup_code :='DELIVER_TO_CONTACT';
        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;
       p_cascade_record.p_deliver_to_contact:=l_enabled_flag;

       l_lookup_code :='DELIVER_TO';

        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;

       p_cascade_record.p_deliver_to:=l_enabled_flag;

       l_lookup_code :='DEMAND_CLASS';

        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;
       p_cascade_record.p_demand_class:=l_enabled_flag;

       l_lookup_code :='FOB_POINT';

        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;
       p_cascade_record.p_fob_point:=l_enabled_flag;

       l_lookup_code :='FREIGHT_TERMS';

        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;

       p_cascade_record.p_freight_terms:=l_enabled_flag;

       l_lookup_code :='BILL_TO_CONTACT';

        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;
       p_cascade_record.p_bill_to_contact:=l_enabled_flag;

       l_lookup_code :='BILL_TO';

        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;

       p_cascade_record.p_bill_to:=l_enabled_flag;

       l_lookup_code :='INVOICING_RULE';

        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;

       p_cascade_record.p_invoicing_rule:=l_enabled_flag;

       l_lookup_code :='ORDER_FIRMED_DATE';

        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;
       p_cascade_record.p_order_firmed_date:=l_enabled_flag;

       l_lookup_code :='PAYMENT_TERM';

        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;

       p_cascade_record.p_payment_term:=l_enabled_flag;

       l_lookup_code :='PRICE_LIST';
        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;

       p_cascade_record.p_price_list:=l_enabled_flag;


       l_lookup_code :='REQUEST_DATE';

        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;

       p_cascade_record.p_request_date:=l_enabled_flag;

       l_lookup_code :='RETURN_REASON';

        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;

       p_cascade_record.p_return_reason:=l_enabled_flag;

       l_lookup_code :='SALESPERSON';

        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;
       p_cascade_record.p_salesperson:=l_enabled_flag;

       l_lookup_code :='SHIPMENT_PRIORITY';


        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;

       p_cascade_record.p_shipment_priority:=l_enabled_flag;

       l_lookup_code :='SHIPPING_METHOD';

        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;

       p_cascade_record.p_shipping_method:=l_enabled_flag;

       l_lookup_code :='WAREHOUSE';

         open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;

       p_cascade_record.p_warehouse:=l_enabled_flag;

       l_lookup_code :='SHIP_TO_CONTACT';

        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;
       p_cascade_record.p_ship_to_contact:=l_enabled_flag;

       l_lookup_code :='SHIP_TO';

        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;

       p_cascade_record.p_ship_to:=l_enabled_flag;

       l_lookup_code :='CUSTOMER';
        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;

       p_cascade_record.p_customer:=l_enabled_flag;

       l_lookup_code :='TAX_EXEMPT';
        open C_LOOKUP(l_lookup_code,l_lookup_type);
	fetch C_LOOKUP into l_enabled_flag;
	close C_LOOKUP;

       p_cascade_record.p_tax_exempt:=l_enabled_flag;

       x_cascade_record:=p_cascade_record; -- Set the record

       x_cascade_record.p_cached:='Y'; -- Caching is done for this session

       OE_DEBUG_PUB.ADD('Exiting OE_OE_FORM_HEADER.Read_Cascadable_Fields',1);

   EXCEPTION

       WHEN  NO_DATA_FOUND THEN
          x_cascade_record.p_cached:='N';
       WHEN  OTHERS  THEN
          x_cascade_record.p_cached:='N';

END Read_Cascadable_Fields;

--End Of Enhanced Cascading

END Oe_Oe_Form_Header;

/
