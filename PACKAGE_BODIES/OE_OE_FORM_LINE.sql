--------------------------------------------------------
--  DDL for Package Body OE_OE_FORM_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_FORM_LINE" AS
/* $Header: OEXFLINB.pls 120.20.12010000.12 2010/11/19 08:38:42 rmoharan ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'Oe_Oe_Form_Line';

--  Global variables holding cached record.

g_line_rec                    OE_Order_PUB.Line_Rec_Type;
g_db_line_rec                 OE_Order_PUB.Line_Rec_Type;
g_current_header_id           NUMBER := 0;
--retro{Global variables for caching header_id and currency code
g_header_id                   NUMBER;
g_currency_code               VARCHAR2(15);
--retro}

--  for 5331980 start
g_subtotal   NUMBER;
g_charges    NUMBER;
g_discount   NUMBER;
g_total_tax  NUMBER;
-- for 5331980 end

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_line
(   p_line_rec                      IN  OE_Order_PUB.Line_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

-- Bug 1713035
-- Procedure Get_Line is now visible to other packages
/*
PROCEDURE Get_line
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_line_id                       IN  NUMBER
,   x_line_rec                      OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
);
*/

PROCEDURE Clear_line;

PROCEDURE get_customer_details ( p_site_use_id IN NUMBER,
                                 p_site_use_code IN VARCHAR2,
x_customer_id OUT NOCOPY NUMBER,
x_customer_name OUT NOCOPY VARCHAR2,
x_customer_number OUT NOCOPY VARCHAR2
                                   );


FUNCTION Get_Date_Type(p_header_id IN NUMBER)
RETURN VARCHAR2;

--  Global variable holding performed operations.

g_opr__tbl                    OE_Order_PUB.Line_Tbl_Type;

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_header_id                     IN  NUMBER
,   x_line_tbl                      IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type
,   x_old_line_tbl                  IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type
,   x_line_val_tbl                  IN OUT NOCOPY OE_ORDER_PUB.Line_Val_Tbl_Type

)
IS
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_error NUMBER := 0;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE.DEFAULT_ATTRIBUTES' , 1 ) ;
    END IF;

  l_error := 1;
    -- Set UI flag to TRUE
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.check_security        := TRUE;
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
    x_old_line_tbl(1)     :=OE_ORDER_PUB.G_MISS_LINE_REC;
    x_line_tbl(1)         :=OE_ORDER_PUB.G_MISS_LINE_REC;
    x_line_tbl(1).header_id                := p_header_id;

    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

    x_line_tbl(1).attribute1                         := NULL;
    x_line_tbl(1).attribute10                        := NULL;
    x_line_tbl(1).attribute11                        := NULL;
    x_line_tbl(1).attribute12                        := NULL;
    x_line_tbl(1).attribute13                        := NULL;
    x_line_tbl(1).attribute14                        := NULL;
    x_line_tbl(1).attribute15                        := NULL;
    x_line_tbl(1).attribute2                         := NULL;
    x_line_tbl(1).attribute3                         := NULL;
    x_line_tbl(1).attribute4                         := NULL;
    x_line_tbl(1).attribute5                         := NULL;
    x_line_tbl(1).attribute6                         := NULL;
    x_line_tbl(1).attribute7                         := NULL;
    x_line_tbl(1).attribute8                         := NULL;
    x_line_tbl(1).attribute9                         := NULL;
    x_line_tbl(1).context                            := NULL;
    x_line_tbl(1).global_attribute1                  := NULL;
    x_line_tbl(1).global_attribute10                 := NULL;
    x_line_tbl(1).global_attribute11                 := NULL;
    x_line_tbl(1).global_attribute12                 := NULL;
    x_line_tbl(1).global_attribute13                 := NULL;
    x_line_tbl(1).global_attribute14                 := NULL;
    x_line_tbl(1).global_attribute15                 := NULL;
    x_line_tbl(1).global_attribute16                 := NULL;
    x_line_tbl(1).global_attribute17                 := NULL;
    x_line_tbl(1).global_attribute18                 := NULL;
    x_line_tbl(1).global_attribute19                 := NULL;
    x_line_tbl(1).global_attribute2                  := NULL;
    x_line_tbl(1).global_attribute20                 := NULL;
    x_line_tbl(1).global_attribute3                  := NULL;
    x_line_tbl(1).global_attribute4                  := NULL;
    x_line_tbl(1).global_attribute5                  := NULL;
    x_line_tbl(1).global_attribute6                  := NULL;
    x_line_tbl(1).global_attribute7                  := NULL;
    x_line_tbl(1).global_attribute8                  := NULL;
    x_line_tbl(1).global_attribute9                  := NULL;
    x_line_tbl(1).global_attribute_category          := NULL;
    x_line_tbl(1).industry_attribute1                := NULL;
    x_line_tbl(1).industry_attribute10               := NULL;
    x_line_tbl(1).industry_attribute11               := NULL;
    x_line_tbl(1).industry_attribute12               := NULL;
    x_line_tbl(1).industry_attribute13               := NULL;
    x_line_tbl(1).industry_attribute14               := NULL;
    x_line_tbl(1).industry_attribute15               := NULL;
    x_line_tbl(1).industry_attribute16               := NULL;
    x_line_tbl(1).industry_attribute17               := NULL;
    x_line_tbl(1).industry_attribute18               := NULL;
    x_line_tbl(1).industry_attribute19               := NULL;
    x_line_tbl(1).industry_attribute2                := NULL;
    x_line_tbl(1).industry_attribute20               := NULL;
    x_line_tbl(1).industry_attribute21               := NULL;
    x_line_tbl(1).industry_attribute22               := NULL;
    x_line_tbl(1).industry_attribute23               := NULL;
    x_line_tbl(1).industry_attribute24               := NULL;
    x_line_tbl(1).industry_attribute25               := NULL;
    x_line_tbl(1).industry_attribute26               := NULL;
    x_line_tbl(1).industry_attribute27               := NULL;
    x_line_tbl(1).industry_attribute28               := NULL;
    x_line_tbl(1).industry_attribute29               := NULL;
    x_line_tbl(1).industry_attribute3                := NULL;
    x_line_tbl(1).industry_attribute30               := NULL;
    x_line_tbl(1).industry_attribute4                := NULL;
    x_line_tbl(1).industry_attribute5                := NULL;
    x_line_tbl(1).industry_attribute6                := NULL;
    x_line_tbl(1).industry_attribute7                := NULL;
    x_line_tbl(1).industry_attribute8                := NULL;
    x_line_tbl(1).industry_attribute9                := NULL;
    x_line_tbl(1).industry_context                   := NULL;
    x_line_tbl(1).pricing_attribute1                 := NULL;
    x_line_tbl(1).pricing_attribute10                := NULL;
    x_line_tbl(1).pricing_attribute2                 := NULL;
    x_line_tbl(1).pricing_attribute3                 := NULL;
    x_line_tbl(1).pricing_attribute4                 := NULL;
    x_line_tbl(1).pricing_attribute5                 := NULL;
    x_line_tbl(1).pricing_attribute6                 := NULL;
    x_line_tbl(1).pricing_attribute7                 := NULL;
    x_line_tbl(1).pricing_attribute8                 := NULL;
    x_line_tbl(1).pricing_attribute9                 := NULL;
    x_line_tbl(1).pricing_context                    := NULL;
    x_line_tbl(1).return_attribute1                  := NULL;
    x_line_tbl(1).return_attribute10                 := NULL;
    x_line_tbl(1).return_attribute11                 := NULL;
    x_line_tbl(1).return_attribute12                 := NULL;
    x_line_tbl(1).return_attribute13                 := NULL;
    x_line_tbl(1).return_attribute14                 := NULL;
    x_line_tbl(1).return_attribute15                 := NULL;
    x_line_tbl(1).return_attribute2                  := NULL;
    x_line_tbl(1).return_attribute3                  := NULL;
    x_line_tbl(1).return_attribute4                  := NULL;
    x_line_tbl(1).return_attribute5                  := NULL;
    x_line_tbl(1).return_attribute6                  := NULL;
    x_line_tbl(1).return_attribute7                  := NULL;
    x_line_tbl(1).return_attribute8                  := NULL;
    x_line_tbl(1).return_attribute9                  := NULL;
    x_line_tbl(1).return_context                     := NULL;
    x_line_tbl(1).tp_attribute1                         := NULL;
    x_line_tbl(1).tp_attribute10                        := NULL;
    x_line_tbl(1).tp_attribute11                        := NULL;
    x_line_tbl(1).tp_attribute12                        := NULL;
    x_line_tbl(1).tp_attribute13                        := NULL;
    x_line_tbl(1).tp_attribute14                        := NULL;
    x_line_tbl(1).tp_attribute15                        := NULL;
    x_line_tbl(1).tp_attribute2                         := NULL;
    x_line_tbl(1).tp_attribute3                         := NULL;
    x_line_tbl(1).tp_attribute4                         := NULL;
    x_line_tbl(1).tp_attribute5                         := NULL;
    x_line_tbl(1).tp_attribute6                         := NULL;
    x_line_tbl(1).tp_attribute7                         := NULL;
    x_line_tbl(1).tp_attribute8                         := NULL;
    x_line_tbl(1).tp_attribute9                         := NULL;
    x_line_tbl(1).tp_context                            := NULL;

    --  Set Operation to Create

  l_error := 2;
    x_line_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;

    --  Populate line table


    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE CONTROLLER - DEFAULT ATTRIBUTES - CALLING PROCESS' , 2 ) ;
    END IF;

    --  Call Oe_Order_Pvt.Process_order

  l_error := 3;

    Oe_Order_Pvt.Lines
    (   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                 => l_control_rec
    ,   p_x_line_tbl                  => x_line_tbl
    ,   p_x_old_line_tbl              => x_old_line_tbl
    ,   x_return_status               => l_return_status
    );

  l_error := 3;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE CONTROLLER - DEFAULT ATTRIBUTES - AFTER PROCESS' , 2 ) ;
    END IF;

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload OUT

--    l_x_line_rec := x_line_tbl(1);


    --  Load display OUT parameters if any
     x_line_val_tbl(1):=OE_ORDER_PUB.G_MISS_LINE_VAL_REC;
     x_line_val_tbl(1):=OE_Line_Util.Get_Values
    (   p_line_rec                    => x_line_tbl(1)
    );
    --  Write to cache.
    --  Set db_flag to False before writing to cache

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE CONTROLLER - DEFAULT ATTRIBUTES - CALLING WRITE LINE' , 2 ) ;
    END IF;

    x_line_tbl(1).db_flag := FND_API.G_FALSE;

    Write_line
    (   p_line_rec                    => x_line_tbl(1)
    );

    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.count_and_get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE.DEFAULT_ATTRIBUTES' , 1 ) ;
    END IF;

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

       OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Default_Attributes' || l_error
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Default_Attributes;

PROCEDURE Copy_Attribute_To_Rec
(   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   p_line_dff_rec                  IN  OE_OE_FORM_LINE.line_dff_rec_type
,   p_date_format_mask              IN  VARCHAR2 DEFAULT 'DD-MON-YYYY HH24:MI:SS'
,   x_line_tbl                      IN OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
,   x_old_line_tbl                  IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type
)
IS
l_date_format_mask            VARCHAR2(30) := p_date_format_mask;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ATTRIBUTE VALUE : '|| P_ATTR_VALUE ) ;   --bug 5179564
    END IF;

    IF p_attr_id = OE_Line_Util.G_ACCOUNTING_RULE THEN
        x_line_tbl(1).accounting_rule_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_ACCOUNTING_RULE_DURATION THEN
        x_line_tbl(1).accounting_rule_duration := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_ACTUAL_ARRIVAL_DATE THEN
      --  x_line_tbl(1).actual_arrival_date := TO_DATE(p_attr_value, l_date_format_mask);
       x_line_tbl(1).actual_arrival_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_ACTUAL_SHIPMENT_DATE THEN
      --  x_line_tbl(1).actual_shipment_date := TO_DATE(p_attr_value, l_date_format_mask);
      x_line_tbl(1).actual_shipment_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_AGREEMENT THEN
        x_line_tbl(1).agreement_id := TO_NUMBER(p_attr_value);
   ELSIF p_attr_id = OE_Line_Util.G_IB_OWNER THEN
          x_line_tbl(1).ib_owner := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_IB_INSTALLED_AT_LOCATION THEN
          x_line_tbl(1).ib_installed_at_location := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_IB_CURRENT_LOCATION THEN
          x_line_tbl(1).ib_current_location := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_END_CUSTOMER_SITE_USE THEN
          x_line_tbl(1).end_customer_site_use_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_END_CUSTOMER_CONTACT THEN
          x_line_tbl(1).end_customer_contact_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_END_CUSTOMER THEN
          x_line_tbl(1).end_customer_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_ATO_LINE THEN
        x_line_tbl(1).ato_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_AUTO_SELECTED_QUANTITY THEN
        x_line_tbl(1).auto_selected_quantity := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_BLANKET_NUMBER THEN
          x_line_tbl(1).blanket_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_BLANKET_LINE_NUMBER THEN
          x_line_tbl(1).blanket_line_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_BLANKET_VERSION_NUMBER THEN
          x_line_tbl(1).blanket_version_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_BOOKED THEN
        x_line_tbl(1).booked_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_CANCELLED THEN
        x_line_tbl(1).cancelled_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_CANCELLED_QUANTITY THEN
        x_line_tbl(1).cancelled_quantity := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_COMPONENT THEN
        x_line_tbl(1).component_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_COMPONENT_NUMBER THEN
        x_line_tbl(1).component_number := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_COMPONENT_SEQUENCE THEN
        x_line_tbl(1).component_sequence_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_CONFIG_DISPLAY_SEQUENCE THEN
        x_line_tbl(1).config_display_sequence := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_CONFIGURATION THEN
        x_line_tbl(1).configuration_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_CONFIG_HEADER THEN
        x_line_tbl(1).config_header_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_CONFIG_REV_NBR THEN
        x_line_tbl(1).config_rev_nbr := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_CREDIT_INVOICE_LINE THEN
        x_line_tbl(1).credit_invoice_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_CUSTOMER_DOCK THEN
        x_line_tbl(1).customer_dock_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_CUSTOMER_JOB THEN
        x_line_tbl(1).customer_job := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_CUSTOMER_PRODUCTION_LINE THEN
        x_line_tbl(1).customer_production_line := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_CUSTOMER_TRX_LINE THEN
        x_line_tbl(1).customer_trx_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_CUST_MODEL_SERIAL_NUMBER THEN
        x_line_tbl(1).cust_model_serial_number := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_CUST_PO_NUMBER THEN
        x_line_tbl(1).cust_po_number := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_DELIVERY_LEAD_TIME THEN
        x_line_tbl(1).delivery_lead_time := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_DELIVER_TO_CONTACT THEN
        x_line_tbl(1).deliver_to_contact_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_DELIVER_TO_ORG THEN
        x_line_tbl(1).deliver_to_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_DEMAND_BUCKET_TYPE THEN
        x_line_tbl(1).demand_bucket_type_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_DEMAND_CLASS THEN
        x_line_tbl(1).demand_class_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_DEP_PLAN_REQUIRED THEN
        x_line_tbl(1).dep_plan_required_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_EARLIEST_ACCEPTABLE_DATE THEN
       -- x_line_tbl(1).earliest_acceptable_date := TO_DATE(p_attr_value, l_date_format_mask);
          x_line_tbl(1).earliest_acceptable_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_EXPLOSION_DATE THEN
       -- x_line_tbl(1).explosion_date := TO_DATE(p_attr_value, l_date_format_mask);
       x_line_tbl(1).explosion_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_FOB_POINT THEN
        x_line_tbl(1).fob_point_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_FREIGHT_CARRIER THEN
        x_line_tbl(1).freight_carrier_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_FREIGHT_TERMS THEN
        x_line_tbl(1).freight_terms_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_FULFILLED_QUANTITY THEN
        x_line_tbl(1).fulfilled_quantity := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_HEADER THEN
        x_line_tbl(1).header_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_INTERMED_SHIP_TO_CONTACT THEN
        x_line_tbl(1).intermed_ship_to_contact_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_INTERMED_SHIP_TO_ORG THEN
        x_line_tbl(1).intermed_ship_to_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_INVENTORY_ITEM THEN
        x_line_tbl(1).inventory_item_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_INVOICE_INTERFACE_STATUS THEN
        x_line_tbl(1).invoice_interface_status_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_INVOICE_TO_CONTACT THEN
        x_line_tbl(1).invoice_to_contact_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_INVOICE_TO_ORG THEN
        x_line_tbl(1).invoice_to_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_INVOICED_QUANTITY THEN
        x_line_tbl(1).invoiced_quantity := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_INVOICING_RULE THEN
        x_line_tbl(1).invoicing_rule_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_ORDERED_ITEM_ID THEN
        x_line_tbl(1).ordered_item_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_ITEM_IDENTIFIER_TYPE THEN
        x_line_tbl(1).item_identifier_type := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ORDERED_ITEM THEN
        x_line_tbl(1).ordered_item := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ITEM_REVISION THEN
        x_line_tbl(1).item_revision := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ITEM_TYPE THEN
        x_line_tbl(1).item_type_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_LATEST_ACCEPTABLE_DATE THEN
       -- x_line_tbl(1).latest_acceptable_date := TO_DATE(p_attr_value, l_date_format_mask);
       x_line_tbl(1).latest_acceptable_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_LATE_DEMAND_PENALTY_FACTOR THEN
        x_line_tbl(1).late_demand_penalty_factor := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_LINE_CATEGORY THEN
        x_line_tbl(1).line_category_code := p_attr_value;
        x_line_tbl(1).line_type_id := FND_API.G_MISS_NUM;
    ELSIF p_attr_id = OE_Line_Util.G_LINE THEN
        x_line_tbl(1).line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_LINE_NUMBER THEN
        x_line_tbl(1).line_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_LINE_TYPE THEN
        x_line_tbl(1).line_type_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_LINK_TO_LINE THEN
        x_line_tbl(1).link_to_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_MODEL_GROUP_NUMBER THEN
        x_line_tbl(1).model_group_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_OPEN THEN
        x_line_tbl(1).open_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_OPTION_FLAG THEN
        x_line_tbl(1).option_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_OPTION_NUMBER THEN
        x_line_tbl(1).option_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_ORDERED_QUANTITY THEN
        x_line_tbl(1).ordered_quantity := FND_NUMBER.CANONICAL_TO_NUMBER(p_attr_value); --bug 5179564
    ELSIF p_attr_id = OE_Line_Util.G_ORDER_QUANTITY_UOM THEN
        x_line_tbl(1).order_quantity_uom := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ORDERED_QUANTITY2 THEN       --OPM
        x_line_tbl(1).ordered_quantity2 := FND_NUMBER.CANONICAL_TO_NUMBER(p_attr_value); --bug 5179564
    ELSIF p_attr_id = OE_Line_Util.G_ORDERED_QUANTITY_UOM2 THEN   --OPM
        x_line_tbl(1).ordered_quantity_uom2 := p_attr_value;

    ELSIF p_attr_id = OE_Line_Util.G_ORG THEN
        x_line_tbl(1).org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_ORIG_SYS_DOCUMENT_REF THEN
        x_line_tbl(1).orig_sys_document_ref := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ORIG_SYS_LINE_REF THEN
        x_line_tbl(1).orig_sys_line_ref := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ORIG_SYS_SHIPMENT_REF THEN
        x_line_tbl(1).orig_sys_shipment_ref := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ORIGINAL_INVENTORY_ITEM THEN
        x_line_tbl(1).original_inventory_item_id:= to_number(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_ORIGINAL_ORDERED_ITEM THEN
        x_line_tbl(1).original_ordered_item := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ORIGINAL_ORDERED_ITEM_ID THEN
        x_line_tbl(1).original_ordered_item_id := to_number(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_ORIGINAL_ITEM_IDEN_TYPE THEN
        x_line_tbl(1).original_item_identifier_type := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ITEM_RELATIONSHIP_TYPE THEN
        x_line_tbl(1).item_relationship_type := to_number(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_PAYMENT_TERM THEN
        x_line_tbl(1).payment_term_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_PLANNING_PRIORITY THEN
        x_line_tbl(1).planning_priority := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_PREFERRED_GRADE THEN         --OPM
        x_line_tbl(1).preferred_grade := p_attr_value;

    ELSIF p_attr_id = OE_Line_Util.G_PRICE_LIST THEN
        x_line_tbl(1).price_list_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_PRICING_DATE THEN
       -- x_line_tbl(1).pricing_date := TO_DATE(p_attr_value, l_date_format_mask);
       x_line_tbl(1).pricing_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_PRICING_QUANTITY THEN
        x_line_tbl(1).pricing_quantity := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_PRICING_QUANTITY_UOM THEN
        x_line_tbl(1).pricing_quantity_uom := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_PROJECT THEN
        x_line_tbl(1).project_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_PROMISE_DATE THEN
      --  x_line_tbl(1).promise_date := TO_DATE(p_attr_value, l_date_format_mask);
       x_line_tbl(1).promise_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_REFERENCE_CUSTOMER_TRX_LINE THEN
        x_line_tbl(1).reference_customer_trx_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_REFERENCE_HEADER THEN
        x_line_tbl(1).reference_header_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_REFERENCE_LINE THEN
        x_line_tbl(1).reference_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_REFERENCE_TYPE THEN
        NULL;
    ELSIF p_attr_id = OE_Line_Util.G_REQUEST_DATE THEN
       -- x_line_tbl(1).request_date := TO_DATE(p_attr_value, l_date_format_mask);
       x_line_tbl(1).request_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_RESERVED_QUANTITY THEN
        x_line_tbl(1).reserved_quantity := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_RLA_SCHEDULE_TYPE THEN
        x_line_tbl(1).rla_schedule_type_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SCHEDULE_ARRIVAL_DATE THEN
       -- x_line_tbl(1).schedule_arrival_date := TO_DATE(p_attr_value, l_date_format_mask);
       x_line_tbl(1).schedule_arrival_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_SCHEDULE_SHIP_DATE THEN
       /* x_line_tbl(1).schedule_ship_date :=
                  TO_DATE(p_attr_value, l_date_format_mask);*/
       x_line_tbl(1).schedule_ship_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_EARLIEST_SHIP_DATE THEN
      /*  x_line_tbl(1).earliest_ship_date :=
                  TO_DATE(p_attr_value, l_date_format_mask);*/
       x_line_tbl(1).earliest_ship_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_FIRM_DEMAND THEN
        x_line_tbl(1).firm_demand_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SCHEDULE_ACTION THEN
        x_line_tbl(1).schedule_action_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_OVERRIDE_ATP_DATE THEN
       x_line_tbl(1).override_atp_date_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SCHEDULE_STATUS THEN
        x_line_tbl(1).schedule_status_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SHIPMENT_NUMBER THEN
        x_line_tbl(1).shipment_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SHIPMENT_PRIORITY THEN
        x_line_tbl(1).shipment_priority_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SHIPPED_QUANTITY THEN
        x_line_tbl(1).shipped_quantity := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SHIPPING_METHOD THEN
        x_line_tbl(1).shipping_method_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SHIPPING_QUANTITY THEN
        x_line_tbl(1).shipping_quantity := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SHIPPING_QUANTITY_UOM THEN
        x_line_tbl(1).shipping_quantity_uom := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SHIP_FROM_ORG THEN
        x_line_tbl(1).ship_from_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SUBINVENTORY THEN
        x_line_tbl(1).subinventory := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SHIP_TOLERANCE_ABOVE THEN
        x_line_tbl(1).ship_tolerance_above := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SHIP_TOLERANCE_BELOW THEN
        x_line_tbl(1).ship_tolerance_below := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SHIPPING_INTERFACED THEN
        x_line_tbl(1).shipping_interfaced_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SHIP_TO_CONTACT THEN
        x_line_tbl(1).ship_to_contact_id := TO_NUMBER(p_attr_value);
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SHIP TO CONTACT1'|| X_LINE_TBL ( 1 ) .SHIP_TO_CONTACT_ID , 1 ) ;
    END IF;
    ELSIF p_attr_id = OE_Line_Util.G_SHIP_TO_ORG THEN
        x_line_tbl(1).ship_to_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SHIP_MODEL_COMPLETE_FLAG THEN
        x_line_tbl(1).ship_model_complete_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SOLD_TO_ORG THEN
        x_line_tbl(1).sold_to_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SORT_ORDER THEN
        x_line_tbl(1).sort_order := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SOURCE_DOCUMENT THEN
        x_line_tbl(1).source_document_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SOURCE_DOCUMENT_LINE THEN
        x_line_tbl(1).source_document_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SOURCE_DOCUMENT_TYPE THEN
        x_line_tbl(1).source_document_type_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SOURCE_TYPE THEN
        x_line_tbl(1).source_type_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_TASK THEN
        x_line_tbl(1).task_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_TAX THEN
        x_line_tbl(1).tax_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_TAX_DATE THEN
       -- x_line_tbl(1).tax_date := TO_DATE(p_attr_value, l_date_format_mask);
        x_line_tbl(1).tax_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_TAX_EXEMPT THEN
        x_line_tbl(1).tax_exempt_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_TAX_EXEMPT_NUMBER THEN
        x_line_tbl(1).tax_exempt_number := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_TAX_EXEMPT_REASON THEN
        x_line_tbl(1).tax_exempt_reason_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_TAX_POINT THEN
        x_line_tbl(1).tax_point_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_TAX_RATE THEN
        x_line_tbl(1).tax_rate := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_TAX_VALUE THEN
        x_line_tbl(1).tax_value := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_TOP_MODEL_LINE THEN
        x_line_tbl(1).top_model_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_UNIT_LIST_PRICE THEN
        x_line_tbl(1).unit_list_price := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_UNIT_LIST_PRICE_PER_PQTY THEN
        x_line_tbl(1).unit_list_price_per_pqty := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_UNIT_SELLING_PRICE THEN
        x_line_tbl(1).unit_selling_price := FND_NUMBER.CANONICAL_TO_NUMBER(p_attr_value); -- bug 5179564
    ELSIF p_attr_id = OE_Line_Util.G_UNIT_SELLING_PRICE_PER_PQTY THEN
        x_line_tbl(1).unit_selling_price_per_pqty := FND_NUMBER.CANONICAL_TO_NUMBER(p_attr_value); -- bug 5179564
    ELSIF p_attr_id = OE_Line_Util.G_VISIBLE_DEMAND THEN
        x_line_tbl(1).visible_demand_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SPLIT_FROM_LINE THEN
        x_line_tbl(1).split_from_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_CUST_PRODUCTION_SEQ_NUM THEN
        x_line_tbl(1).cust_production_seq_num := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_AUTHORIZED_TO_SHIP THEN
        x_line_tbl(1).authorized_to_ship_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_VEH_CUS_ITEM_CUM_KEY THEN
        x_line_tbl(1).veh_cus_item_cum_key_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SALESREP THEN
        x_line_tbl(1).salesrep_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_RETURN_REASON THEN
        x_line_tbl(1).return_reason_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ARRIVAL_SET THEN
        x_line_tbl(1).arrival_set_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_ARRIVAL_SET_NAME THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RAJ CONTROLLER - ATTRIBUTE CHANGE'|| P_ATTR_VALUE ) ;
    END IF;
    IF p_attr_value IS NULL THEN
        x_line_tbl(1).arrival_set_id := NULL;
        x_line_tbl(1).arrival_set := p_attr_value;
       x_old_line_tbl(1).arrival_set := null;
    ELSE
        x_line_tbl(1).arrival_set := p_attr_value;
        x_line_tbl(1).arrival_set_id := NULL;
    END IF;
    ELSIF p_attr_id = OE_Line_Util.G_SHIP_SET THEN
        x_line_tbl(1).ship_set_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SHIP_SET_NAME THEN
    IF p_attr_value IS NULL THEN
        x_line_tbl(1).ship_set_id := NULL;
        x_line_tbl(1).ship_set := p_attr_value;
       x_old_line_tbl(1).ship_set := null;
    ELSE
        x_line_tbl(1).ship_set := p_attr_value;
        x_line_tbl(1).ship_set_id := NULL;
    END IF;
    ELSIF p_attr_id = OE_Line_Util.G_FULFILLMENT_SET THEN
        x_line_tbl(1).fulfillment_set := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_FULFILLMENT_SET_NAME THEN
    IF p_attr_value IS NULL THEN
        x_line_tbl(1).fulfillment_set_id := NULL;
    ELSE
        x_line_tbl(1).fulfillment_set := p_attr_value;
        x_line_tbl(1).fulfillment_set_id := NULL;
    END IF;
    ELSIF p_attr_id = OE_Line_Util.G_OVER_SHIP_REASON THEN
        x_line_tbl(1).over_ship_reason_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_OVER_SHIP_RESOLVED THEN
        x_line_tbl(1).over_ship_resolved_flag := p_attr_value;
    ELSIF p_attr_id =    OE_Line_Util.G_FIRST_ACK THEN
        x_line_tbl(1).first_ack_code := p_attr_value;
    ELSIF p_attr_id =    OE_Line_Util.G_FIRST_ACK_DATE THEN
       -- x_line_tbl(1).first_ack_date := TO_DATE(p_attr_value, l_date_format_mask);
       x_line_tbl(1).first_ack_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id =    OE_Line_Util.G_LAST_ACK THEN
        x_line_tbl(1).last_ack_code := p_attr_value;
    ELSIF p_attr_id =    OE_Line_Util.G_LAST_ACK_DATE THEN
      --  x_line_tbl(1).last_ack_date := TO_DATE(p_attr_value, l_date_format_mask);
      x_line_tbl(1).last_ack_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id =    OE_Line_Util.G_END_ITEM_UNIT_NUMBER THEN
        x_line_tbl(1).end_item_unit_number := p_attr_value;
    ELSIF p_attr_id =    OE_Line_Util.G_SHIPPING_INSTRUCTIONS THEN
        x_line_tbl(1).shipping_instructions := p_attr_value;
    ELSIF p_attr_id =    OE_Line_Util.G_PACKING_INSTRUCTIONS THEN
        x_line_tbl(1).packing_instructions := p_attr_value;
    ELSIF p_attr_id =    OE_Line_Util.G_SERVICE_TXN_REASON THEN
        x_line_tbl(1).service_txn_reason_code := p_attr_value;
    ELSIF p_attr_id =    OE_Line_Util.G_SERVICE_TXN_COMMENTS THEN
        x_line_tbl(1).service_txn_comments := p_attr_value;
    ELSIF p_attr_id =    OE_Line_Util.G_SERVICE_DURATION THEN
        x_line_tbl(1).service_duration := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id =    OE_Line_Util.G_SERVICE_PERIOD THEN
        x_line_tbl(1).service_period := p_attr_value;
    ELSIF p_attr_id =    OE_Line_Util.G_SERVICE_START_DATE THEN
       -- x_line_tbl(1).service_start_date := TO_DATE(p_attr_value, l_date_format_mask);
       x_line_tbl(1).service_start_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id =    OE_Line_Util.G_SERVICE_END_DATE THEN
       -- x_line_tbl(1).service_end_date := TO_DATE(p_attr_value, l_date_format_mask);
       x_line_tbl(1).service_end_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id =    OE_Line_Util.G_SERVICE_COTERMINATE_FLAG THEN
        x_line_tbl(1).service_coterminate_flag := p_attr_value;
    ELSIF p_attr_id =    OE_Line_Util.G_UNIT_SELLING_PERCENT THEN
        x_line_tbl(1).unit_selling_percent := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id =    OE_Line_Util.G_UNIT_LIST_PERCENT THEN
        x_line_tbl(1).unit_list_percent := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id =    OE_Line_Util.G_UNIT_PERCENT_BASE_PRICE THEN
        x_line_tbl(1).unit_percent_base_price := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id =    OE_Line_Util.G_SERVICE_NUMBER THEN
        x_line_tbl(1).service_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_Service_Reference_Type_Code THEN
        x_line_tbl(1).service_reference_type_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_Service_Reference_Line_Id THEN
        x_line_tbl(1).service_reference_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_Service_Reference_System_Id THEN
        x_line_tbl(1).service_reference_system_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_CHANGE_REASON THEN
        x_line_tbl(1).change_reason := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_CHANGE_COMMENTS THEN
        x_line_tbl(1).change_comments := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_CALCULATE_PRICE_FLAG THEN
        x_line_tbl(1).calculate_price_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_CUSTOMER_LINE_NUMBER THEN
        x_line_tbl(1).customer_line_number := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_CUSTOMER_SHIPMENT_NUMBER THEN
        x_line_tbl(1).customer_shipment_number := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_user_ITEM_DESCRIPTION THEN
        x_line_tbl(1).user_item_description := p_attr_value;
    --recurring charges
    ELSIF p_attr_id = OE_LINE_UTIL.G_CHARGE_PERIODICITY THEN
        x_line_tbl(1).charge_periodicity_code := p_attr_value;
    --Customer Acceptance
    ELSIF p_attr_id = OE_Line_Util.G_CONTINGENCY THEN
        x_line_tbl(1).contingency_id  := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_REVREC_EVENT THEN
        x_line_tbl(1).revrec_event_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_REVREC_EXPIRATION_DAYS THEN
        x_line_tbl(1).revrec_expiration_days := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_REVREC_COMMENTS THEN
        x_line_tbl(1).revrec_comments := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_REVREC_REFERENCE_DOCUMENT THEN
        x_line_tbl(1).revrec_reference_document := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_REVREC_SIGNATURE THEN
        x_line_tbl(1).revrec_signature := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ATTRIBUTE1
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE10
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE11
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE12
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE13
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE14
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE15
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE16   --For bug 2184255
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE17
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE18
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE19
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE2
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE20
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE3
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE4
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE5
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE6
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE7
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE8
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE9
    OR     p_attr_id = OE_Line_Util.G_CONTEXT
    THEN

        x_line_tbl(1).attribute1          := p_line_dff_rec.attribute1;
        x_line_tbl(1).attribute10         := p_line_dff_rec.attribute10;
        x_line_tbl(1).attribute11         := p_line_dff_rec.attribute11;
        x_line_tbl(1).attribute12         := p_line_dff_rec.attribute12;
        x_line_tbl(1).attribute13         := p_line_dff_rec.attribute13;
        x_line_tbl(1).attribute14         := p_line_dff_rec.attribute14;
        x_line_tbl(1).attribute15         := p_line_dff_rec.attribute15;
        x_line_tbl(1).attribute16         := p_line_dff_rec.attribute16;   --For bug 2184255
        x_line_tbl(1).attribute17         := p_line_dff_rec.attribute17;
        x_line_tbl(1).attribute18         := p_line_dff_rec.attribute18;
        x_line_tbl(1).attribute19         := p_line_dff_rec.attribute19;
        x_line_tbl(1).attribute2          := p_line_dff_rec.attribute2;
        x_line_tbl(1).attribute20         := p_line_dff_rec.attribute20;
        x_line_tbl(1).attribute3          := p_line_dff_rec.attribute3;
        x_line_tbl(1).attribute4          := p_line_dff_rec.attribute4;
        x_line_tbl(1).attribute5          := p_line_dff_rec.attribute5;
        x_line_tbl(1).attribute6          := p_line_dff_rec.attribute6;
        x_line_tbl(1).attribute7          := p_line_dff_rec.attribute7;
        x_line_tbl(1).attribute8          := p_line_dff_rec.attribute8;
        x_line_tbl(1).attribute9          := p_line_dff_rec.attribute9;
        x_line_tbl(1).context             := p_line_dff_rec.context;

    ELSIF p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE1
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE10
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE11
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE12
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE13
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE14
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE15
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE16
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE17
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE18
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE19
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE2
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE20
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE3
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE4
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE5
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE6
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE7
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE8
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE9
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE_CATEGORY
    THEN

        x_line_tbl(1).global_attribute1   := p_line_dff_rec.global_attribute1;
        x_line_tbl(1).global_attribute10  := p_line_dff_rec.global_attribute10;
        x_line_tbl(1).global_attribute11  := p_line_dff_rec.global_attribute11;
        x_line_tbl(1).global_attribute12  := p_line_dff_rec.global_attribute12;
        x_line_tbl(1).global_attribute13  := p_line_dff_rec.global_attribute13;
        x_line_tbl(1).global_attribute14  := p_line_dff_rec.global_attribute14;
        x_line_tbl(1).global_attribute15  := p_line_dff_rec.global_attribute15;
        x_line_tbl(1).global_attribute16  := p_line_dff_rec.global_attribute16;
        x_line_tbl(1).global_attribute17  := p_line_dff_rec.global_attribute17;
        x_line_tbl(1).global_attribute18  := p_line_dff_rec.global_attribute18;
        x_line_tbl(1).global_attribute19  := p_line_dff_rec.global_attribute19;
        x_line_tbl(1).global_attribute2   := p_line_dff_rec.global_attribute2;
        x_line_tbl(1).global_attribute20  := p_line_dff_rec.global_attribute20;
        x_line_tbl(1).global_attribute3   := p_line_dff_rec.global_attribute3;
        x_line_tbl(1).global_attribute4   := p_line_dff_rec.global_attribute4;
        x_line_tbl(1).global_attribute5   := p_line_dff_rec.global_attribute5;
        x_line_tbl(1).global_attribute6   := p_line_dff_rec.global_attribute6;
        x_line_tbl(1).global_attribute7   := p_line_dff_rec.global_attribute7;
        x_line_tbl(1).global_attribute8   := p_line_dff_rec.global_attribute8;
        x_line_tbl(1).global_attribute9   := p_line_dff_rec.global_attribute9;
        x_line_tbl(1).global_attribute_category := p_line_dff_rec.global_attribute_category;

    ELSIF p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE1
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE10
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE11
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE12
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE13
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE14
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE15
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE2
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE3
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE4
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE5
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE6
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE7
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE8
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE9
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE16
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE17
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE18
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE19
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE20
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE21
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE22
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE23
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE24
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE25
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE26
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE27
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE28
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE29
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE30
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_CONTEXT
    THEN

        x_line_tbl(1).industry_attribute1 := p_line_dff_rec.industry_attribute1;
        x_line_tbl(1).industry_attribute10 := p_line_dff_rec.industry_attribute10;
        x_line_tbl(1).industry_attribute11 := p_line_dff_rec.industry_attribute11;
        x_line_tbl(1).industry_attribute12 := p_line_dff_rec.industry_attribute12;
        x_line_tbl(1).industry_attribute13 := p_line_dff_rec.industry_attribute13;
        x_line_tbl(1).industry_attribute14 := p_line_dff_rec.industry_attribute14;
        x_line_tbl(1).industry_attribute15 := p_line_dff_rec.industry_attribute15;
        x_line_tbl(1).industry_attribute2 := p_line_dff_rec.industry_attribute2;
        x_line_tbl(1).industry_attribute3 := p_line_dff_rec.industry_attribute3;
        x_line_tbl(1).industry_attribute4 := p_line_dff_rec.industry_attribute4;
        x_line_tbl(1).industry_attribute5 := p_line_dff_rec.industry_attribute5;
        x_line_tbl(1).industry_attribute6 := p_line_dff_rec.industry_attribute6;
        x_line_tbl(1).industry_attribute7 := p_line_dff_rec.industry_attribute7;
        x_line_tbl(1).industry_attribute8 := p_line_dff_rec.industry_attribute8;
        x_line_tbl(1).industry_attribute9 := p_line_dff_rec.industry_attribute9;
        x_line_tbl(1).industry_attribute16 := p_line_dff_rec.industry_attribute16;
        x_line_tbl(1).industry_attribute17 := p_line_dff_rec.industry_attribute17;
        x_line_tbl(1).industry_attribute18 := p_line_dff_rec.industry_attribute18;
        x_line_tbl(1).industry_attribute19 := p_line_dff_rec.industry_attribute19;
        x_line_tbl(1).industry_attribute20 := p_line_dff_rec.industry_attribute20;
        x_line_tbl(1).industry_attribute21 := p_line_dff_rec.industry_attribute21;
        x_line_tbl(1).industry_attribute22 := p_line_dff_rec.industry_attribute22;
        x_line_tbl(1).industry_attribute23 := p_line_dff_rec.industry_attribute23;
        x_line_tbl(1).industry_attribute24 := p_line_dff_rec.industry_attribute24;
        x_line_tbl(1).industry_attribute25 := p_line_dff_rec.industry_attribute25;
        x_line_tbl(1).industry_attribute26 := p_line_dff_rec.industry_attribute26;
        x_line_tbl(1).industry_attribute27 := p_line_dff_rec.industry_attribute27;
        x_line_tbl(1).industry_attribute28 := p_line_dff_rec.industry_attribute28;
        x_line_tbl(1).industry_attribute29 := p_line_dff_rec.industry_attribute29;
        x_line_tbl(1).industry_attribute30 := p_line_dff_rec.industry_attribute30;
        x_line_tbl(1).industry_context    := p_line_dff_rec.industry_context;

    ELSIF p_attr_id = OE_Line_Util.G_PRICING_ATTRIBUTE1
    OR     p_attr_id = OE_Line_Util.G_PRICING_ATTRIBUTE10
    OR     p_attr_id = OE_Line_Util.G_PRICING_ATTRIBUTE2
    OR     p_attr_id = OE_Line_Util.G_PRICING_ATTRIBUTE3
    OR     p_attr_id = OE_Line_Util.G_PRICING_ATTRIBUTE4
    OR     p_attr_id = OE_Line_Util.G_PRICING_ATTRIBUTE5
    OR     p_attr_id = OE_Line_Util.G_PRICING_ATTRIBUTE6
    OR     p_attr_id = OE_Line_Util.G_PRICING_ATTRIBUTE7
    OR     p_attr_id = OE_Line_Util.G_PRICING_ATTRIBUTE8
    OR     p_attr_id = OE_Line_Util.G_PRICING_ATTRIBUTE9
    OR     p_attr_id = OE_Line_Util.G_PRICING_CONTEXT
    THEN

        x_line_tbl(1).pricing_attribute1  := p_line_dff_rec.pricing_attribute1;
        x_line_tbl(1).pricing_attribute10 := p_line_dff_rec.pricing_attribute10;
        x_line_tbl(1).pricing_attribute2  := p_line_dff_rec.pricing_attribute2;
        x_line_tbl(1).pricing_attribute3  := p_line_dff_rec.pricing_attribute3;
        x_line_tbl(1).pricing_attribute4  := p_line_dff_rec.pricing_attribute4;
        x_line_tbl(1).pricing_attribute5  := p_line_dff_rec.pricing_attribute5;
        x_line_tbl(1).pricing_attribute6  := p_line_dff_rec.pricing_attribute6;
        x_line_tbl(1).pricing_attribute7  := p_line_dff_rec.pricing_attribute7;
        x_line_tbl(1).pricing_attribute8  := p_line_dff_rec.pricing_attribute8;
        x_line_tbl(1).pricing_attribute9  := p_line_dff_rec.pricing_attribute9;
        x_line_tbl(1).pricing_context     := p_line_dff_rec.pricing_context;
    /* Amy Return, enable return attributes  */
    ELSIF p_attr_id = OE_Line_Util.G_RETURN_CONTEXT THEN
        x_line_tbl(1).return_context := p_attr_value;
        x_line_tbl(1).return_attribute1   := p_line_dff_rec.return_attribute1;
        x_line_tbl(1).return_attribute10  := p_line_dff_rec.return_attribute10;
        x_line_tbl(1).return_attribute11  := p_line_dff_rec.return_attribute11;
        x_line_tbl(1).return_attribute12  := p_line_dff_rec.return_attribute12;
        x_line_tbl(1).return_attribute13  := p_line_dff_rec.return_attribute13;
        x_line_tbl(1).return_attribute14  := p_line_dff_rec.return_attribute14;
        x_line_tbl(1).return_attribute15  := p_line_dff_rec.return_attribute15;
        x_line_tbl(1).return_attribute2  := p_line_dff_rec.return_attribute2;
        x_line_tbl(1).return_attribute3  := p_line_dff_rec.return_attribute3;
        x_line_tbl(1).return_attribute4  := p_line_dff_rec.return_attribute4;
        x_line_tbl(1).return_attribute5  := p_line_dff_rec.return_attribute5;
        x_line_tbl(1).return_attribute6  := p_line_dff_rec.return_attribute6;
        x_line_tbl(1).return_attribute7  := p_line_dff_rec.return_attribute7;
        x_line_tbl(1).return_attribute8  := p_line_dff_rec.return_attribute8;
        x_line_tbl(1).return_attribute9  := p_line_dff_rec.return_attribute9;
        x_line_tbl(1).line_category_code := OE_GLOBALS.G_RETURN_CATEGORY_CODE;

    ELSIF p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE1
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE10
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE11
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE12
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE13
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE14
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE15
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE2
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE3
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE4
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE5
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE6
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE7
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE8
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE9
    OR     p_attr_id = OE_Line_Util.G_TP_CONTEXT
    THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'JYOTHI: I AM IN CHANGE ATTRIBUTE' ) ;
        END IF;

        x_line_tbl(1).tp_attribute1          := p_line_dff_rec.tp_attribute1;
        x_line_tbl(1).tp_attribute10         := p_line_dff_rec.tp_attribute10;
        x_line_tbl(1).tp_attribute11         := p_line_dff_rec.tp_attribute11;
        x_line_tbl(1).tp_attribute12         := p_line_dff_rec.tp_attribute12;
        x_line_tbl(1).tp_attribute13         := p_line_dff_rec.tp_attribute13;
        x_line_tbl(1).tp_attribute14         := p_line_dff_rec.tp_attribute14;
        x_line_tbl(1).tp_attribute15         := p_line_dff_rec.tp_attribute15;
        x_line_tbl(1).tp_attribute2          := p_line_dff_rec.tp_attribute2;
        x_line_tbl(1).tp_attribute3          := p_line_dff_rec.tp_attribute3;
        x_line_tbl(1).tp_attribute4          := p_line_dff_rec.tp_attribute4;
        x_line_tbl(1).tp_attribute5          := p_line_dff_rec.tp_attribute5;
        x_line_tbl(1).tp_attribute6          := p_line_dff_rec.tp_attribute6;
        x_line_tbl(1).tp_attribute7          := p_line_dff_rec.tp_attribute7;
        x_line_tbl(1).tp_attribute8          := p_line_dff_rec.tp_attribute8;
        x_line_tbl(1).tp_attribute9          := p_line_dff_rec.tp_attribute9;
        x_line_tbl(1).tp_context          := p_line_dff_rec.tp_context;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'JYOTHI- TP ATTRIBUTE IS ' || X_LINE_TBL ( 1 ) .TP_ATTRIBUTE1 ) ;
        END IF;
    ELSIF p_attr_id = OE_Line_Util.G_COMMITMENT THEN
        x_line_tbl(1).commitment_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_COMMITMENT_APPLIED_AMOUNT THEN
        x_line_tbl(1).commitment_applied_amount := TO_NUMBER(p_attr_value);
    --MRG BGN
    ELSIF p_attr_id = OE_LINE_UTIL.G_UNIT_COST Then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'P_ATTR_VALUE='||P_ATTR_VALUE ) ;
        END IF;
        x_line_tbl(1).unit_cost := TO_NUMBER(p_attr_value);
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'FLINB:UNIT_COST:'||P_ATTR_VALUE ) ;
        END IF;
    --MRG END
    --retro{
    ELSIF p_attr_id = OE_Line_Util.G_RETROBILL_REQUEST THEN
        x_line_tbl(1).retrobill_request_id := TO_NUMBER(p_attr_value);

    --retro}
    -- Override Selling price
    ELSIF p_attr_id = OE_Line_Util.G_ORIGINAL_LIST_PRICE THEN
          x_line_tbl(1).original_list_price := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_UNIT_LIST_PRICE_PER_PQTY THEN
          x_line_tbl(1).unit_list_price_per_pqty := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_UNIT_SELLING_PRICE_PER_PQTY THEN
          x_line_tbl(1).unit_selling_price_per_pqty := TO_NUMBER(p_attr_value);
    -- Override Selling price
    -- INVCONV
    ELSIF p_attr_id = OE_Line_Util.G_CANCELLED_QUANTITY2 THEN
        x_line_tbl(1).cancelled_quantity2 := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_FULFILLED_QUANTITY2 THEN
        x_line_tbl(1).fulfilled_quantity2 := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SHIPPED_QUANTITY2 THEN
        x_line_tbl(1).shipped_quantity2 := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SHIPPING_QUANTITY2 THEN
        x_line_tbl(1).shipping_quantity2 := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SHIPPING_QUANTITY_UOM2 THEN
        x_line_tbl(1).shipping_quantity_uom2 := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_RESERVED_QUANTITY2 THEN
        x_line_tbl(1).reserved_quantity2 := p_attr_value;

    ELSE

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UNRECOGNIZED ATTRIBUTE EXCEPTION' , 2 ) ;
        END IF;

        --  Unexpected error, unrecognized attribute

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
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

--  Procedure   :   Change_Attribute
--
-- Commenting OUT all flex attributes because
-- we ran into an odd bug where the client(pld) does not recognize a package
-- at all once it gets over a certain size (255 parameters per procedure)

-- Commenting OUT the pricing attributes for now since the number of
-- parameters increases beyond the 255 parameters.

PROCEDURE Change_Attribute
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_line_id                       IN  NUMBER
,   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   p_attr_id_tbl                   IN  Number_Tbl_Type
,   p_attr_value_tbl                IN  Varchar2_Tbl_Type
,   p_reason                IN  VARCHAR2
,   p_comments              IN  VARCHAR2
,   p_line_dff_rec                  IN OE_OE_FORM_LINE.line_dff_rec_type
,   p_default_cache_line_rec           IN  OE_ORDER_PUB.Line_Rec_Type
,   p_date_format_mask              IN  VARCHAR2 DEFAULT 'DD-MON-YYYY HH24:MI:SS'
,   x_line_tbl                      IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type
,   x_old_line_tbl                  IN OUT NOCOPY OE_ORDER_PUB.Line_Tbl_Type
,   x_line_val_tbl                  IN OUT NOCOPY OE_ORDER_PUB.Line_Val_Tbl_Type
--, x_dualum_ind OUT NOCOPY NUMBER --OPM 02/JUN/00  INVCONV
--, x_grade_ctl OUT NOCOPY NUMBER --OPM 02/JUN/00   INVCONV
, x_process_warehouse_flag OUT NOCOPY VARCHAR2 --OPM 02/JUN/00
--, x_ont_pricing_qty_source OUT NOCOPY NUMBER --OPM 2046190
, x_ont_pricing_qty_source OUT NOCOPY VARCHAR2 -- INVCONV
, x_grade_control_flag OUT NOCOPY VARCHAR2 -- INVCONV
, x_tracking_quantity_ind   OUT NOCOPY VARCHAR2 -- INVCONV
, x_secondary_default_ind OUT NOCOPY VARCHAR2 -- INVCONV
, x_lot_divisible_flag OUT NOCOPY VARCHAR2 -- INVCONV
, x_lot_control_code OUT NOCOPY /* file.sql.39 change */ NUMBER  -- 4172680 INVCONV

)
IS
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_date_format_mask            VARCHAR2(30) := p_date_format_mask;
l_order_date_type_code        VARCHAR2(30) := null;
l_orig_ship_from_org_id       OE_Order_LINES.ship_from_org_id%TYPE;
l_x_item_rec_type             OE_ORDER_CACHE.item_rec_type;    -- OPM 2/JUN/00
file_name varchar2(100);
i                       pls_Integer;
L_PRICE_CONTROL_REC         QP_PREQ_GRP.control_record_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE.CHANGE_ATTRIBUTES' , 1 ) ;
    END IF;

    -- Set UI flag to TRUE
    OE_GLOBALS.G_UI_FLAG := TRUE;


    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.change_attributes    := TRUE;

    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read line from cache

    IF p_default_cache_line_rec.line_id IS NOT NULL THEN
      x_line_tbl(1):=p_default_cache_line_rec;
      x_line_tbl(1).db_flag := FND_API.G_FALSE;
       Write_line
       (   p_line_rec                    => x_line_tbl(1)
       );

    END IF;


    IF p_default_cache_line_rec.line_id IS NOT NULL THEN
      --x_old_line_tbl(1) := OE_ORDER_PUB.G_MISS_LINE_REC;
        x_old_line_tbl(1).line_id := null;
        x_line_tbl(1):=p_default_cache_line_rec;
        l_control_rec.default_attributes   := FALSE;
        l_control_rec.clear_dependents     := FALSE;
        l_control_rec.check_security       := FALSE;

        IF FND_API.To_Boolean(x_line_tbl(1).db_flag) THEN
          x_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
        ELSE
          x_line_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;
        END IF;

        Oe_Order_Pvt.Lines
        (
         p_validation_level            => FND_API.G_VALID_LEVEL_NONE
       , p_init_msg_list               => FND_API.G_TRUE
       , p_control_rec                 => l_control_rec
       , p_x_line_tbl                  => x_line_tbl
       , p_x_old_line_tbl              => x_old_line_tbl
       , x_return_status               => l_return_status
        );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'DATE TYPE RETURNED UNEXP_ERROR' , 2 ) ;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'DATE TYPE RETURN RET_STS_ERROR' , 2 ) ;
           END IF;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       x_old_line_tbl(1) := x_line_tbl(1);
    ELSE

      Get_line
      (   p_db_record                   => FALSE
       ,   p_line_id                     => p_line_id
       ,   x_line_rec                    => x_line_tbl(1)
       );

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'JPN:AFTER LINE QUERY : ' || X_LINE_TBL ( 1 ) .TP_ATTRIBUTE1 ) ;
       END IF;

       x_old_line_tbl(1) := x_line_tbl(1);

    END IF;
    l_control_rec.default_attributes   := TRUE;
    l_control_rec.clear_dependents     := TRUE;
    l_control_rec.check_security        := TRUE;

    IF OE_CODE_CONTROL.Code_Release_Level >= '110509' THEN

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'Code Release is >= 11.5.9') ;
       END IF;

       Copy_Attribute_To_Rec
                (p_attr_id         => p_attr_id
                ,p_attr_value      => p_attr_value
                ,p_line_dff_rec    => p_line_dff_rec
                ,p_date_format_mask  => p_date_format_mask
                ,x_line_tbl        => x_line_tbl
                ,x_old_line_tbl    => x_old_line_tbl
                );

       FOR l_index IN 1..p_attr_id_tbl.COUNT LOOP

           Copy_Attribute_To_Rec
                (p_attr_id         => p_attr_id_tbl(l_index)
                ,p_attr_value      => p_attr_value_tbl(l_index)
                ,p_line_dff_rec    => p_line_dff_rec
                ,p_date_format_mask  => p_date_format_mask
                ,x_line_tbl        => x_line_tbl
                ,x_old_line_tbl    => x_old_line_tbl
                );

       END LOOP;

    ELSE

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'Code Release is < 11.5.9') ;
       END IF;

    -- PLEASE ADD THIS IF LOGIC FOR NEW ATTRIBUTES TO THE PROCEDURE
    -- COPY_ATTRIBUTE_TO_REC ALSO. THIS NEW PROCEDURE WILL REPLACE
    -- THESE IF CALLS POST OM PACK I OR 11.5.9.

    IF p_attr_id = OE_Line_Util.G_ACCOUNTING_RULE THEN
        x_line_tbl(1).accounting_rule_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_ACCOUNTING_RULE_DURATION THEN
        x_line_tbl(1).accounting_rule_duration := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_ACTUAL_ARRIVAL_DATE THEN
      --  x_line_tbl(1).actual_arrival_date := TO_DATE(p_attr_value, l_date_format_mask);
      x_line_tbl(1).actual_arrival_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_ACTUAL_SHIPMENT_DATE THEN
      --  x_line_tbl(1).actual_shipment_date := TO_DATE(p_attr_value, l_date_format_mask);
       x_line_tbl(1).actual_shipment_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_AGREEMENT THEN
        x_line_tbl(1).agreement_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_IB_OWNER THEN
          x_line_tbl(1).ib_owner := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_IB_INSTALLED_AT_LOCATION THEN
          x_line_tbl(1).ib_installed_at_location := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_IB_CURRENT_LOCATION THEN
          x_line_tbl(1).ib_current_location := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_END_CUSTOMER_SITE_USE THEN
          x_line_tbl(1).end_customer_site_use_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_END_CUSTOMER_CONTACT THEN
          x_line_tbl(1).end_customer_contact_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_END_CUSTOMER THEN
          x_line_tbl(1).end_customer_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_ATO_LINE THEN
        x_line_tbl(1).ato_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_AUTO_SELECTED_QUANTITY THEN
        x_line_tbl(1).auto_selected_quantity := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_BLANKET_NUMBER THEN
          x_line_tbl(1).blanket_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_BLANKET_LINE_NUMBER THEN
          x_line_tbl(1).blanket_line_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_BLANKET_VERSION_NUMBER THEN
          x_line_tbl(1).blanket_version_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_BOOKED THEN
        x_line_tbl(1).booked_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_CANCELLED THEN
        x_line_tbl(1).cancelled_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_CANCELLED_QUANTITY THEN
        x_line_tbl(1).cancelled_quantity := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_COMPONENT THEN
        x_line_tbl(1).component_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_COMPONENT_NUMBER THEN
        x_line_tbl(1).component_number := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_COMPONENT_SEQUENCE THEN
        x_line_tbl(1).component_sequence_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_CONFIG_DISPLAY_SEQUENCE THEN
        x_line_tbl(1).config_display_sequence := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_CONFIGURATION THEN
        x_line_tbl(1).configuration_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_CONFIG_HEADER THEN
        x_line_tbl(1).config_header_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_CONFIG_REV_NBR THEN
        x_line_tbl(1).config_rev_nbr := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_CREDIT_INVOICE_LINE THEN
        x_line_tbl(1).credit_invoice_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_CUSTOMER_DOCK THEN
        x_line_tbl(1).customer_dock_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_CUSTOMER_JOB THEN
        x_line_tbl(1).customer_job := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_CUSTOMER_PRODUCTION_LINE THEN
        x_line_tbl(1).customer_production_line := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_CUSTOMER_TRX_LINE THEN
        x_line_tbl(1).customer_trx_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_CUST_MODEL_SERIAL_NUMBER THEN
        x_line_tbl(1).cust_model_serial_number := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_CUST_PO_NUMBER THEN
        x_line_tbl(1).cust_po_number := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_DELIVERY_LEAD_TIME THEN
        x_line_tbl(1).delivery_lead_time := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_DELIVER_TO_CONTACT THEN
        x_line_tbl(1).deliver_to_contact_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_DELIVER_TO_ORG THEN
        x_line_tbl(1).deliver_to_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_DEMAND_BUCKET_TYPE THEN
        x_line_tbl(1).demand_bucket_type_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_DEMAND_CLASS THEN
        x_line_tbl(1).demand_class_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_DEP_PLAN_REQUIRED THEN
        x_line_tbl(1).dep_plan_required_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_EARLIEST_ACCEPTABLE_DATE THEN
      --  x_line_tbl(1).earliest_acceptable_date := TO_DATE(p_attr_value, l_date_format_mask);
       x_line_tbl(1).earliest_acceptable_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_EXPLOSION_DATE THEN
      --  x_line_tbl(1).explosion_date := TO_DATE(p_attr_value, l_date_format_mask);
       x_line_tbl(1).explosion_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_FOB_POINT THEN
        x_line_tbl(1).fob_point_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_FREIGHT_CARRIER THEN
        x_line_tbl(1).freight_carrier_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_FREIGHT_TERMS THEN
        x_line_tbl(1).freight_terms_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_FULFILLED_QUANTITY THEN
        x_line_tbl(1).fulfilled_quantity := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_HEADER THEN
        x_line_tbl(1).header_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_INTERMED_SHIP_TO_CONTACT THEN
        x_line_tbl(1).intermed_ship_to_contact_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_INTERMED_SHIP_TO_ORG THEN
        x_line_tbl(1).intermed_ship_to_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_INVENTORY_ITEM THEN
        x_line_tbl(1).inventory_item_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_INVOICE_INTERFACE_STATUS THEN
        x_line_tbl(1).invoice_interface_status_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_INVOICE_TO_CONTACT THEN
        x_line_tbl(1).invoice_to_contact_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_INVOICE_TO_ORG THEN
        x_line_tbl(1).invoice_to_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_INVOICED_QUANTITY THEN
        x_line_tbl(1).invoiced_quantity := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_INVOICING_RULE THEN
        x_line_tbl(1).invoicing_rule_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_ORDERED_ITEM_ID THEN
        x_line_tbl(1).ordered_item_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_ITEM_IDENTIFIER_TYPE THEN
        x_line_tbl(1).item_identifier_type := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ORDERED_ITEM THEN
        x_line_tbl(1).ordered_item := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ITEM_REVISION THEN
        x_line_tbl(1).item_revision := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ITEM_TYPE THEN
        x_line_tbl(1).item_type_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_LATEST_ACCEPTABLE_DATE THEN
      --  x_line_tbl(1).latest_acceptable_date := TO_DATE(p_attr_value, l_date_format_mask);
       x_line_tbl(1).latest_acceptable_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_LATE_DEMAND_PENALTY_FACTOR THEN
        x_line_tbl(1).late_demand_penalty_factor := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_LINE_CATEGORY THEN
        x_line_tbl(1).line_category_code := p_attr_value;
        x_line_tbl(1).line_type_id := FND_API.G_MISS_NUM;
    ELSIF p_attr_id = OE_Line_Util.G_LINE THEN
        x_line_tbl(1).line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_LINE_NUMBER THEN
        x_line_tbl(1).line_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_LINE_TYPE THEN
        x_line_tbl(1).line_type_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_LINK_TO_LINE THEN
        x_line_tbl(1).link_to_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_MODEL_GROUP_NUMBER THEN
        x_line_tbl(1).model_group_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_OPEN THEN
        x_line_tbl(1).open_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_OPTION_FLAG THEN
        x_line_tbl(1).option_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_OPTION_NUMBER THEN
        x_line_tbl(1).option_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_ORDERED_QUANTITY THEN
        x_line_tbl(1).ordered_quantity := FND_NUMBER.CANONICAL_TO_NUMBER(p_attr_value); --bug 5179564
    ELSIF p_attr_id = OE_Line_Util.G_ORDER_QUANTITY_UOM THEN
        x_line_tbl(1).order_quantity_uom := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ORDERED_QUANTITY2 THEN       --OPM
        x_line_tbl(1).ordered_quantity2 := FND_NUMBER.CANONICAL_TO_NUMBER(p_attr_value); --bug 5179564
    ELSIF p_attr_id = OE_Line_Util.G_ORDERED_QUANTITY_UOM2 THEN   --OPM
        x_line_tbl(1).ordered_quantity_uom2 := p_attr_value;

    ELSIF p_attr_id = OE_Line_Util.G_ORG THEN
        x_line_tbl(1).org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_ORIG_SYS_DOCUMENT_REF THEN
        x_line_tbl(1).orig_sys_document_ref := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ORIG_SYS_LINE_REF THEN
        x_line_tbl(1).orig_sys_line_ref := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ORIG_SYS_SHIPMENT_REF THEN
        x_line_tbl(1).orig_sys_shipment_ref := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ORIGINAL_INVENTORY_ITEM THEN
        x_line_tbl(1).original_inventory_item_id:= to_number(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_ORIGINAL_ORDERED_ITEM THEN
        x_line_tbl(1).original_ordered_item := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ORIGINAL_ORDERED_ITEM_ID THEN
        x_line_tbl(1).original_ordered_item_id := to_number(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_ORIGINAL_ITEM_IDEN_TYPE THEN
        x_line_tbl(1).original_item_identifier_type := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ITEM_RELATIONSHIP_TYPE THEN
        x_line_tbl(1).item_relationship_type := to_number(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_PAYMENT_TERM THEN
        x_line_tbl(1).payment_term_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_PLANNING_PRIORITY THEN
        x_line_tbl(1).planning_priority := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_PREFERRED_GRADE THEN         --OPM
        x_line_tbl(1).preferred_grade := p_attr_value;

    ELSIF p_attr_id = OE_Line_Util.G_PRICE_LIST THEN
        x_line_tbl(1).price_list_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_PRICING_DATE THEN
       -- x_line_tbl(1).pricing_date := TO_DATE(p_attr_value, l_date_format_mask);
        x_line_tbl(1).pricing_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_PRICING_QUANTITY THEN
        x_line_tbl(1).pricing_quantity := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_PRICING_QUANTITY_UOM THEN
        x_line_tbl(1).pricing_quantity_uom := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_PROJECT THEN
        x_line_tbl(1).project_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_PROMISE_DATE THEN
      --  x_line_tbl(1).promise_date := TO_DATE(p_attr_value, l_date_format_mask);
        x_line_tbl(1).promise_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_REFERENCE_CUSTOMER_TRX_LINE THEN
        x_line_tbl(1).reference_customer_trx_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_REFERENCE_HEADER THEN
        x_line_tbl(1).reference_header_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_REFERENCE_LINE THEN
        x_line_tbl(1).reference_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_REFERENCE_TYPE THEN
        NULL;
    ELSIF p_attr_id = OE_Line_Util.G_REQUEST_DATE THEN
      --  x_line_tbl(1).request_date := TO_DATE(p_attr_value, l_date_format_mask);
       x_line_tbl(1).request_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_RESERVED_QUANTITY THEN
        x_line_tbl(1).reserved_quantity := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_RLA_SCHEDULE_TYPE THEN
        x_line_tbl(1).rla_schedule_type_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SCHEDULE_ARRIVAL_DATE THEN
      --  x_line_tbl(1).schedule_arrival_date := TO_DATE(p_attr_value, l_date_format_mask);
        x_line_tbl(1).schedule_arrival_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_SCHEDULE_SHIP_DATE THEN
       /* x_line_tbl(1).schedule_ship_date :=
                  TO_DATE(p_attr_value, l_date_format_mask);*/
         x_line_tbl(1).schedule_ship_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_EARLIEST_SHIP_DATE THEN
      /*  x_line_tbl(1).earliest_ship_date :=
                  TO_DATE(p_attr_value, l_date_format_mask);*/
        x_line_tbl(1).earliest_ship_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_FIRM_DEMAND THEN
        x_line_tbl(1).firm_demand_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SCHEDULE_ACTION THEN
        x_line_tbl(1).schedule_action_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_OVERRIDE_ATP_DATE THEN
       x_line_tbl(1).override_atp_date_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SCHEDULE_STATUS THEN
        x_line_tbl(1).schedule_status_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SHIPMENT_NUMBER THEN
        x_line_tbl(1).shipment_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SHIPMENT_PRIORITY THEN
        x_line_tbl(1).shipment_priority_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SHIPPED_QUANTITY THEN
        x_line_tbl(1).shipped_quantity := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SHIPPING_METHOD THEN
        x_line_tbl(1).shipping_method_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SHIPPING_QUANTITY THEN
        x_line_tbl(1).shipping_quantity := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SHIPPING_QUANTITY_UOM THEN
        x_line_tbl(1).shipping_quantity_uom := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SHIP_FROM_ORG THEN
        x_line_tbl(1).ship_from_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SUBINVENTORY THEN
        x_line_tbl(1).subinventory := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SHIP_TOLERANCE_ABOVE THEN
        x_line_tbl(1).ship_tolerance_above := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SHIP_TOLERANCE_BELOW THEN
        x_line_tbl(1).ship_tolerance_below := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SHIPPING_INTERFACED THEN
        x_line_tbl(1).shipping_interfaced_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SHIP_TO_CONTACT THEN
        x_line_tbl(1).ship_to_contact_id := TO_NUMBER(p_attr_value);
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SHIP TO CONTACT1'|| X_LINE_TBL ( 1 ) .SHIP_TO_CONTACT_ID , 1 ) ;
    END IF;
    ELSIF p_attr_id = OE_Line_Util.G_SHIP_TO_ORG THEN
        x_line_tbl(1).ship_to_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SHIP_MODEL_COMPLETE_FLAG THEN
        x_line_tbl(1).ship_model_complete_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SOLD_TO_ORG THEN
        x_line_tbl(1).sold_to_org_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SORT_ORDER THEN
        x_line_tbl(1).sort_order := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SOURCE_DOCUMENT THEN
        x_line_tbl(1).source_document_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SOURCE_DOCUMENT_LINE THEN
        x_line_tbl(1).source_document_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SOURCE_DOCUMENT_TYPE THEN
        x_line_tbl(1).source_document_type_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SOURCE_TYPE THEN
        x_line_tbl(1).source_type_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_TASK THEN
        x_line_tbl(1).task_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_TAX THEN
        x_line_tbl(1).tax_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_TAX_DATE THEN
      --  x_line_tbl(1).tax_date := TO_DATE(p_attr_value, l_date_format_mask);
         x_line_tbl(1).tax_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Util.G_TAX_EXEMPT THEN
        x_line_tbl(1).tax_exempt_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_TAX_EXEMPT_NUMBER THEN
        x_line_tbl(1).tax_exempt_number := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_TAX_EXEMPT_REASON THEN
        x_line_tbl(1).tax_exempt_reason_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_TAX_POINT THEN
        x_line_tbl(1).tax_point_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_TAX_RATE THEN
        x_line_tbl(1).tax_rate := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_TAX_VALUE THEN
        x_line_tbl(1).tax_value := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_TOP_MODEL_LINE THEN
        x_line_tbl(1).top_model_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_UNIT_LIST_PRICE THEN
        x_line_tbl(1).unit_list_price := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_UNIT_LIST_PRICE_PER_PQTY THEN
        x_line_tbl(1).unit_list_price_per_pqty := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_UNIT_SELLING_PRICE THEN
        x_line_tbl(1).unit_selling_price := FND_NUMBER.CANONICAL_TO_NUMBER(p_attr_value); -- bug 5179564
    ELSIF p_attr_id = OE_Line_Util.G_UNIT_SELLING_PRICE_PER_PQTY THEN
        x_line_tbl(1).unit_selling_price_per_pqty := FND_NUMBER.CANONICAL_TO_NUMBER(p_attr_value); -- bug 5179564
    ELSIF p_attr_id = OE_Line_Util.G_VISIBLE_DEMAND THEN
        x_line_tbl(1).visible_demand_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_SPLIT_FROM_LINE THEN
        x_line_tbl(1).split_from_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_CUST_PRODUCTION_SEQ_NUM THEN
        x_line_tbl(1).cust_production_seq_num := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_AUTHORIZED_TO_SHIP THEN
        x_line_tbl(1).authorized_to_ship_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_VEH_CUS_ITEM_CUM_KEY THEN
        x_line_tbl(1).veh_cus_item_cum_key_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SALESREP THEN
        x_line_tbl(1).salesrep_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_RETURN_REASON THEN
        x_line_tbl(1).return_reason_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ARRIVAL_SET THEN
        x_line_tbl(1).arrival_set_id := TO_NUMBER(p_attr_value);
    --recurring charges
    ELSIF p_attr_id = OE_LINE_UTIL.G_CHARGE_PERIODICITY THEN
        x_line_tbl(1).charge_periodicity_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ARRIVAL_SET_NAME THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'RAJ CONTROLLER - ATTRIBUTE CHANGE'|| P_ATTR_VALUE ) ;
    END IF;
    IF p_attr_value IS NULL THEN
        x_line_tbl(1).arrival_set_id := NULL;
        x_line_tbl(1).arrival_set := p_attr_value;
       x_old_line_tbl(1).arrival_set := null;
    ELSE
        x_line_tbl(1).arrival_set := p_attr_value;
        x_line_tbl(1).arrival_set_id := NULL;
    END IF;
    ELSIF p_attr_id = OE_Line_Util.G_SHIP_SET THEN
        x_line_tbl(1).ship_set_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SHIP_SET_NAME THEN
    IF p_attr_value IS NULL THEN
        x_line_tbl(1).ship_set_id := NULL;
        x_line_tbl(1).ship_set := p_attr_value;
       x_old_line_tbl(1).ship_set := null;
    ELSE
        x_line_tbl(1).ship_set := p_attr_value;
        x_line_tbl(1).ship_set_id := NULL;
    END IF;
    ELSIF p_attr_id = OE_Line_Util.G_FULFILLMENT_SET THEN
        x_line_tbl(1).fulfillment_set := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_FULFILLMENT_SET_NAME THEN
    IF p_attr_value IS NULL THEN
        x_line_tbl(1).fulfillment_set_id := NULL;
    ELSE
        x_line_tbl(1).fulfillment_set := p_attr_value;
        x_line_tbl(1).fulfillment_set_id := NULL;
    END IF;
    ELSIF p_attr_id = OE_Line_Util.G_OVER_SHIP_REASON THEN
        x_line_tbl(1).over_ship_reason_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_OVER_SHIP_RESOLVED THEN
        x_line_tbl(1).over_ship_resolved_flag := p_attr_value;
    ELSIF p_attr_id =    OE_Line_Util.G_FIRST_ACK THEN
        x_line_tbl(1).first_ack_code := p_attr_value;
    ELSIF p_attr_id =    OE_Line_Util.G_FIRST_ACK_DATE THEN
     --   x_line_tbl(1).first_ack_date := TO_DATE(p_attr_value, l_date_format_mask);
      x_line_tbl(1).first_ack_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id =    OE_Line_Util.G_LAST_ACK THEN
        x_line_tbl(1).last_ack_code := p_attr_value;
    ELSIF p_attr_id =    OE_Line_Util.G_LAST_ACK_DATE THEN
       -- x_line_tbl(1).last_ack_date := TO_DATE(p_attr_value, l_date_format_mask);
       x_line_tbl(1).last_ack_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id =    OE_Line_Util.G_END_ITEM_UNIT_NUMBER THEN
        x_line_tbl(1).end_item_unit_number := p_attr_value;
    ELSIF p_attr_id =    OE_Line_Util.G_SHIPPING_INSTRUCTIONS THEN
        x_line_tbl(1).shipping_instructions := p_attr_value;
    ELSIF p_attr_id =    OE_Line_Util.G_PACKING_INSTRUCTIONS THEN
        x_line_tbl(1).packing_instructions := p_attr_value;
    ELSIF p_attr_id =    OE_Line_Util.G_SERVICE_TXN_REASON THEN
        x_line_tbl(1).service_txn_reason_code := p_attr_value;
    ELSIF p_attr_id =    OE_Line_Util.G_SERVICE_TXN_COMMENTS THEN
        x_line_tbl(1).service_txn_comments := p_attr_value;
    ELSIF p_attr_id =    OE_Line_Util.G_SERVICE_DURATION THEN
        x_line_tbl(1).service_duration := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id =    OE_Line_Util.G_SERVICE_PERIOD THEN
        x_line_tbl(1).service_period := p_attr_value;
    ELSIF p_attr_id =    OE_Line_Util.G_SERVICE_START_DATE THEN
      --  x_line_tbl(1).service_start_date := TO_DATE(p_attr_value, l_date_format_mask);
       x_line_tbl(1).service_start_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id =    OE_Line_Util.G_SERVICE_END_DATE THEN
      -- x_line_tbl(1).service_end_date := TO_DATE(p_attr_value, l_date_format_mask);
       x_line_tbl(1).service_end_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id =    OE_Line_Util.G_SERVICE_COTERMINATE_FLAG THEN
        x_line_tbl(1).service_coterminate_flag := p_attr_value;
    ELSIF p_attr_id =    OE_Line_Util.G_UNIT_SELLING_PERCENT THEN
        x_line_tbl(1).unit_selling_percent := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id =    OE_Line_Util.G_UNIT_LIST_PERCENT THEN
        x_line_tbl(1).unit_list_percent := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id =    OE_Line_Util.G_UNIT_PERCENT_BASE_PRICE THEN
        x_line_tbl(1).unit_percent_base_price := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id =    OE_Line_Util.G_SERVICE_NUMBER THEN
        x_line_tbl(1).service_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_Service_Reference_Type_Code THEN
        x_line_tbl(1).service_reference_type_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_Service_Reference_Line_Id THEN
        x_line_tbl(1).service_reference_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_Service_Reference_System_Id THEN
        x_line_tbl(1).service_reference_system_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_CHANGE_REASON THEN
        x_line_tbl(1).change_reason := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_CHANGE_COMMENTS THEN
        x_line_tbl(1).change_comments := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_CALCULATE_PRICE_FLAG THEN
        x_line_tbl(1).calculate_price_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_CUSTOMER_LINE_NUMBER THEN
        x_line_tbl(1).customer_line_number := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_CUSTOMER_SHIPMENT_NUMBER THEN
        x_line_tbl(1).customer_shipment_number := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_user_ITEM_DESCRIPTION THEN
        x_line_tbl(1).user_item_description := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_ATTRIBUTE1
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE10
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE11
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE12
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE13
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE14
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE15
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE16   --For bug 2184255
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE17
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE18
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE19
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE2
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE20
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE3
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE4
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE5
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE6
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE7
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE8
    OR     p_attr_id = OE_Line_Util.G_ATTRIBUTE9
    OR     p_attr_id = OE_Line_Util.G_CONTEXT
    THEN

        x_line_tbl(1).attribute1          := p_line_dff_rec.attribute1;
        x_line_tbl(1).attribute10         := p_line_dff_rec.attribute10;
        x_line_tbl(1).attribute11         := p_line_dff_rec.attribute11;
        x_line_tbl(1).attribute12         := p_line_dff_rec.attribute12;
        x_line_tbl(1).attribute13         := p_line_dff_rec.attribute13;
        x_line_tbl(1).attribute14         := p_line_dff_rec.attribute14;
        x_line_tbl(1).attribute15         := p_line_dff_rec.attribute15;
        x_line_tbl(1).attribute16         := p_line_dff_rec.attribute16;   --For bug 2184255
        x_line_tbl(1).attribute17         := p_line_dff_rec.attribute17;
        x_line_tbl(1).attribute18         := p_line_dff_rec.attribute18;
        x_line_tbl(1).attribute19         := p_line_dff_rec.attribute19;
        x_line_tbl(1).attribute2          := p_line_dff_rec.attribute2;
        x_line_tbl(1).attribute20         := p_line_dff_rec.attribute20;
        x_line_tbl(1).attribute3          := p_line_dff_rec.attribute3;
        x_line_tbl(1).attribute4          := p_line_dff_rec.attribute4;
        x_line_tbl(1).attribute5          := p_line_dff_rec.attribute5;
        x_line_tbl(1).attribute6          := p_line_dff_rec.attribute6;
        x_line_tbl(1).attribute7          := p_line_dff_rec.attribute7;
        x_line_tbl(1).attribute8          := p_line_dff_rec.attribute8;
        x_line_tbl(1).attribute9          := p_line_dff_rec.attribute9;
        x_line_tbl(1).context             := p_line_dff_rec.context;

    ELSIF p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE1
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE10
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE11
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE12
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE13
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE14
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE15
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE16
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE17
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE18
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE19
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE2
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE20
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE3
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE4
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE5
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE6
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE7
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE8
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE9
    OR     p_attr_id = OE_Line_Util.G_GLOBAL_ATTRIBUTE_CATEGORY
    THEN

        x_line_tbl(1).global_attribute1   := p_line_dff_rec.global_attribute1;
        x_line_tbl(1).global_attribute10  := p_line_dff_rec.global_attribute10;
        x_line_tbl(1).global_attribute11  := p_line_dff_rec.global_attribute11;
        x_line_tbl(1).global_attribute12  := p_line_dff_rec.global_attribute12;
        x_line_tbl(1).global_attribute13  := p_line_dff_rec.global_attribute13;
        x_line_tbl(1).global_attribute14  := p_line_dff_rec.global_attribute14;
        x_line_tbl(1).global_attribute15  := p_line_dff_rec.global_attribute15;
        x_line_tbl(1).global_attribute16  := p_line_dff_rec.global_attribute16;
        x_line_tbl(1).global_attribute17  := p_line_dff_rec.global_attribute17;
        x_line_tbl(1).global_attribute18  := p_line_dff_rec.global_attribute18;
        x_line_tbl(1).global_attribute19  := p_line_dff_rec.global_attribute19;
        x_line_tbl(1).global_attribute2   := p_line_dff_rec.global_attribute2;
        x_line_tbl(1).global_attribute20  := p_line_dff_rec.global_attribute20;
        x_line_tbl(1).global_attribute3   := p_line_dff_rec.global_attribute3;
        x_line_tbl(1).global_attribute4   := p_line_dff_rec.global_attribute4;
        x_line_tbl(1).global_attribute5   := p_line_dff_rec.global_attribute5;
        x_line_tbl(1).global_attribute6   := p_line_dff_rec.global_attribute6;
        x_line_tbl(1).global_attribute7   := p_line_dff_rec.global_attribute7;
        x_line_tbl(1).global_attribute8   := p_line_dff_rec.global_attribute8;
        x_line_tbl(1).global_attribute9   := p_line_dff_rec.global_attribute9;
        x_line_tbl(1).global_attribute_category := p_line_dff_rec.global_attribute_category;

    ELSIF p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE1
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE10
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE11
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE12
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE13
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE14
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE15
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE2
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE3
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE4
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE5
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE6
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE7
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE8
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE9
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE16
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE17
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE18
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE19
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE20
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE21
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE22
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE23
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE24
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE25
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE26
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE27
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE28
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE29
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_ATTRIBUTE30
    OR     p_attr_id = OE_Line_Util.G_INDUSTRY_CONTEXT
    THEN

        x_line_tbl(1).industry_attribute1 := p_line_dff_rec.industry_attribute1;
        x_line_tbl(1).industry_attribute10 := p_line_dff_rec.industry_attribute10;
        x_line_tbl(1).industry_attribute11 := p_line_dff_rec.industry_attribute11;
        x_line_tbl(1).industry_attribute12 := p_line_dff_rec.industry_attribute12;
        x_line_tbl(1).industry_attribute13 := p_line_dff_rec.industry_attribute13;
        x_line_tbl(1).industry_attribute14 := p_line_dff_rec.industry_attribute14;
        x_line_tbl(1).industry_attribute15 := p_line_dff_rec.industry_attribute15;
        x_line_tbl(1).industry_attribute2 := p_line_dff_rec.industry_attribute2;
        x_line_tbl(1).industry_attribute3 := p_line_dff_rec.industry_attribute3;
        x_line_tbl(1).industry_attribute4 := p_line_dff_rec.industry_attribute4;
        x_line_tbl(1).industry_attribute5 := p_line_dff_rec.industry_attribute5;
        x_line_tbl(1).industry_attribute6 := p_line_dff_rec.industry_attribute6;
        x_line_tbl(1).industry_attribute7 := p_line_dff_rec.industry_attribute7;
        x_line_tbl(1).industry_attribute8 := p_line_dff_rec.industry_attribute8;
        x_line_tbl(1).industry_attribute9 := p_line_dff_rec.industry_attribute9;
        x_line_tbl(1).industry_attribute16 := p_line_dff_rec.industry_attribute16;
        x_line_tbl(1).industry_attribute17 := p_line_dff_rec.industry_attribute17;
        x_line_tbl(1).industry_attribute18 := p_line_dff_rec.industry_attribute18;
        x_line_tbl(1).industry_attribute19 := p_line_dff_rec.industry_attribute19;
        x_line_tbl(1).industry_attribute20 := p_line_dff_rec.industry_attribute20;
        x_line_tbl(1).industry_attribute21 := p_line_dff_rec.industry_attribute21;
        x_line_tbl(1).industry_attribute22 := p_line_dff_rec.industry_attribute22;
        x_line_tbl(1).industry_attribute23 := p_line_dff_rec.industry_attribute23;
        x_line_tbl(1).industry_attribute24 := p_line_dff_rec.industry_attribute24;
        x_line_tbl(1).industry_attribute25 := p_line_dff_rec.industry_attribute25;
        x_line_tbl(1).industry_attribute26 := p_line_dff_rec.industry_attribute26;
        x_line_tbl(1).industry_attribute27 := p_line_dff_rec.industry_attribute27;
        x_line_tbl(1).industry_attribute28 := p_line_dff_rec.industry_attribute28;
        x_line_tbl(1).industry_attribute29 := p_line_dff_rec.industry_attribute29;
        x_line_tbl(1).industry_attribute30 := p_line_dff_rec.industry_attribute30;
        x_line_tbl(1).industry_context    := p_line_dff_rec.industry_context;

    ELSIF p_attr_id = OE_Line_Util.G_PRICING_ATTRIBUTE1
    OR     p_attr_id = OE_Line_Util.G_PRICING_ATTRIBUTE10
    OR     p_attr_id = OE_Line_Util.G_PRICING_ATTRIBUTE2
    OR     p_attr_id = OE_Line_Util.G_PRICING_ATTRIBUTE3
    OR     p_attr_id = OE_Line_Util.G_PRICING_ATTRIBUTE4
    OR     p_attr_id = OE_Line_Util.G_PRICING_ATTRIBUTE5
    OR     p_attr_id = OE_Line_Util.G_PRICING_ATTRIBUTE6
    OR     p_attr_id = OE_Line_Util.G_PRICING_ATTRIBUTE7
    OR     p_attr_id = OE_Line_Util.G_PRICING_ATTRIBUTE8
    OR     p_attr_id = OE_Line_Util.G_PRICING_ATTRIBUTE9
    OR     p_attr_id = OE_Line_Util.G_PRICING_CONTEXT
    THEN

        x_line_tbl(1).pricing_attribute1  := p_line_dff_rec.pricing_attribute1;
        x_line_tbl(1).pricing_attribute10 := p_line_dff_rec.pricing_attribute10;
        x_line_tbl(1).pricing_attribute2  := p_line_dff_rec.pricing_attribute2;
        x_line_tbl(1).pricing_attribute3  := p_line_dff_rec.pricing_attribute3;
        x_line_tbl(1).pricing_attribute4  := p_line_dff_rec.pricing_attribute4;
        x_line_tbl(1).pricing_attribute5  := p_line_dff_rec.pricing_attribute5;
        x_line_tbl(1).pricing_attribute6  := p_line_dff_rec.pricing_attribute6;
        x_line_tbl(1).pricing_attribute7  := p_line_dff_rec.pricing_attribute7;
        x_line_tbl(1).pricing_attribute8  := p_line_dff_rec.pricing_attribute8;
        x_line_tbl(1).pricing_attribute9  := p_line_dff_rec.pricing_attribute9;
        x_line_tbl(1).pricing_context     := p_line_dff_rec.pricing_context;
    /* Amy Return, enable return attributes  */
    ELSIF p_attr_id = OE_Line_Util.G_RETURN_CONTEXT THEN
        x_line_tbl(1).return_context := p_attr_value;
        x_line_tbl(1).return_attribute1   := p_line_dff_rec.return_attribute1;
        x_line_tbl(1).return_attribute10  := p_line_dff_rec.return_attribute10;
        x_line_tbl(1).return_attribute11  := p_line_dff_rec.return_attribute11;
        x_line_tbl(1).return_attribute12  := p_line_dff_rec.return_attribute12;
        x_line_tbl(1).return_attribute13  := p_line_dff_rec.return_attribute13;
        x_line_tbl(1).return_attribute14  := p_line_dff_rec.return_attribute14;
        x_line_tbl(1).return_attribute15  := p_line_dff_rec.return_attribute15;
        x_line_tbl(1).return_attribute2  := p_line_dff_rec.return_attribute2;
        x_line_tbl(1).return_attribute3  := p_line_dff_rec.return_attribute3;
        x_line_tbl(1).return_attribute4  := p_line_dff_rec.return_attribute4;
        x_line_tbl(1).return_attribute5  := p_line_dff_rec.return_attribute5;
        x_line_tbl(1).return_attribute6  := p_line_dff_rec.return_attribute6;
        x_line_tbl(1).return_attribute7  := p_line_dff_rec.return_attribute7;
        x_line_tbl(1).return_attribute8  := p_line_dff_rec.return_attribute8;
        x_line_tbl(1).return_attribute9  := p_line_dff_rec.return_attribute9;
        x_line_tbl(1).line_category_code := OE_GLOBALS.G_RETURN_CATEGORY_CODE;

    ELSIF p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE1
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE10
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE11
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE12
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE13
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE14
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE15
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE2
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE3
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE4
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE5
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE6
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE7
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE8
    OR     p_attr_id = OE_Line_Util.G_TP_ATTRIBUTE9
    OR     p_attr_id = OE_Line_Util.G_TP_CONTEXT
    THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'JYOTHI: I AM IN CHANGE ATTRIBUTE' ) ;
        END IF;

        x_line_tbl(1).tp_attribute1          := p_line_dff_rec.tp_attribute1;
        x_line_tbl(1).tp_attribute10         := p_line_dff_rec.tp_attribute10;
        x_line_tbl(1).tp_attribute11         := p_line_dff_rec.tp_attribute11;
        x_line_tbl(1).tp_attribute12         := p_line_dff_rec.tp_attribute12;
        x_line_tbl(1).tp_attribute13         := p_line_dff_rec.tp_attribute13;
        x_line_tbl(1).tp_attribute14         := p_line_dff_rec.tp_attribute14;
        x_line_tbl(1).tp_attribute15         := p_line_dff_rec.tp_attribute15;
        x_line_tbl(1).tp_attribute2          := p_line_dff_rec.tp_attribute2;
        x_line_tbl(1).tp_attribute3          := p_line_dff_rec.tp_attribute3;
        x_line_tbl(1).tp_attribute4          := p_line_dff_rec.tp_attribute4;
        x_line_tbl(1).tp_attribute5          := p_line_dff_rec.tp_attribute5;
        x_line_tbl(1).tp_attribute6          := p_line_dff_rec.tp_attribute6;
        x_line_tbl(1).tp_attribute7          := p_line_dff_rec.tp_attribute7;
        x_line_tbl(1).tp_attribute8          := p_line_dff_rec.tp_attribute8;
        x_line_tbl(1).tp_attribute9          := p_line_dff_rec.tp_attribute9;
        x_line_tbl(1).tp_context          := p_line_dff_rec.tp_context;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'JYOTHI- TP ATTRIBUTE IS ' || X_LINE_TBL ( 1 ) .TP_ATTRIBUTE1 ) ;
        END IF;
    ELSIF p_attr_id = OE_Line_Util.G_COMMITMENT THEN
        x_line_tbl(1).commitment_id := TO_NUMBER(p_attr_value);
    --MRG BGN
    ELSIF p_attr_id = OE_LINE_UTIL.G_UNIT_COST Then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'P_ATTR_VALUE='||P_ATTR_VALUE ) ;
        END IF;
        x_line_tbl(1).unit_cost := TO_NUMBER(p_attr_value);
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'FLINB:UNIT_COST:'||P_ATTR_VALUE ) ;
        END IF;
    --MRG END
    -- INVCONV
     ELSIF p_attr_id = OE_Line_Util.G_CANCELLED_QUANTITY2 THEN
        x_line_tbl(1).cancelled_quantity2 := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_FULFILLED_QUANTITY2 THEN
        x_line_tbl(1).fulfilled_quantity2 := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SHIPPED_QUANTITY2 THEN
        x_line_tbl(1).shipped_quantity2 := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SHIPPING_QUANTITY2 THEN
        x_line_tbl(1).shipping_quantity2 := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Util.G_SHIPPING_QUANTITY_UOM2 THEN
        x_line_tbl(1).shipping_quantity_uom2 := p_attr_value;
    ELSIF p_attr_id = OE_Line_Util.G_RESERVED_QUANTITY2 THEN
        x_line_tbl(1).reserved_quantity2 := p_attr_value;

    -- INVCONV
    ELSE

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'UNRECOGNIZED ATTRIBUTE EXCEPTION' , 2 ) ;
        END IF;

        --  Unexpected error, unrecognized attribute

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attribute'
            ,   'Unrecognized attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    -- PLEASE ADD THE ABOVE IF LOGIC FOR NEW ATTRIBUTES TO THE PROCEDURE
    -- COPY_ATTRIBUTE_TO_REC ALSO. THIS NEW PROCEDURE WILL REPLACE
    -- THESE IF CALLS POST OM PACK I OR 11.5.9.

    END IF; -- End if code release >= 11.5.9

    --  Set Operation.

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'SETTING OPERATION' , 2 ) ;
    END IF;

    IF FND_API.To_Boolean(x_line_tbl(1).db_flag) THEN
        x_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        x_line_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate line table
    --  Validate Scheduling Dates Changes, if any.

    IF NVL(x_line_tbl(1).source_type_code,OE_GLOBALS.G_SOURCE_INTERNAL)
               = OE_GLOBALS.G_SOURCE_INTERNAL THEN
    IF NOT OE_GLOBALS.Equal(x_line_tbl(1).schedule_ship_date,
                            x_old_line_tbl(1).schedule_ship_date)
    THEN
       -- If the Order Type is ARRIVAL, the user is not
       -- allowed to change the schedule ship date

       l_order_date_type_code    := Get_Date_Type(x_line_tbl(1).header_id);

       IF nvl(l_order_date_type_code,'SHIP') = 'ARRIVAL' THEN

          FND_MESSAGE.SET_NAME('ONT','OE_SCH_INV_SHP_DATE');
          OE_MSG_PUB.Add;

          l_return_status := FND_API.G_RET_STS_ERROR;

       END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'DATE TYPE RETURNED UNEXP_ERROR' , 2 ) ;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'DATE TYPE RETURN RET_STS_ERROR' , 2 ) ;
           END IF;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;

    IF NOT OE_GLOBALS.Equal(x_line_tbl(1).schedule_arrival_date,
                            x_old_line_tbl(1).schedule_arrival_date)
    THEN

       -- If the Order Type is SHIP (or null), the user is not
       -- allowed to change the schedule arrival date

       l_order_date_type_code    := Get_Date_Type(x_line_tbl(1).header_id);

       IF nvl(l_order_date_type_code,'SHIP') = 'SHIP' THEN

          FND_MESSAGE.SET_NAME('ONT','OE_SCH_INV_ARR_DATE');
          OE_MSG_PUB.Add;

          l_return_status := FND_API.G_RET_STS_ERROR;

       END IF;

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'DATE TYPE RETURNED UNEXP_ERROR' , 2 ) ;
           END IF;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'DATE TYPE RETURN RET_STS_ERROR' , 2 ) ;
           END IF;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;
    END IF;
    -- start for 3998402
    IF (NVL(x_line_tbl(1).source_type_code,OE_GLOBALS.G_SOURCE_INTERNAL)
                                                      = OE_GLOBALS.G_SOURCE_EXTERNAL
       AND (x_line_tbl(1).ship_set_id is not null
            OR x_line_tbl(1).arrival_set_id is not null)) THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Cannot change source type',2);
      END IF;
      FND_MESSAGE.SET_NAME('ONT','ONT_CANT_CHG_SRC_TYPE');
      OE_MSG_PUB.Add;
      l_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- end for 3998402

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING PROCESS ORDER' , 2 ) ;
        oe_debug_pub.add(  'BEFORE CALLING PROCESS ORDER' , 1 ) ;
    END IF;

    --  Call Oe_Order_Pvt.Process_order
    Oe_Order_Pvt.Lines
    (
        p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                 => l_control_rec
    ,   p_x_line_tbl                  => x_line_tbl
    ,   p_x_old_line_tbl              => x_old_line_tbl
    ,   x_return_status               => l_return_status
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER CALLING PROCESS ORDER' , 1 ) ;
    END IF;
    --bug 2438466 begin
    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN -- Fix for bug3546224
        IF p_attr_id = OE_Line_Util.G_RETURN_CONTEXT THEN
            OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
            (p_request_type   =>OE_GLOBALS.G_COPY_ADJUSTMENTS
            ,p_delete        => FND_API.G_TRUE
            ,x_return_status => l_return_status
            );
        END IF;
    END IF;
    --bug 2438466 end

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'PROCESS ORDER RETURN UNEXP_ERROR' , 2 ) ;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'PROCESS ORDER RETURN RET_STS_ERROR' , 2 ) ;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload OUT tbl


    --  Init OUT parameters to missing.

    --  Load display OUT parameters if any

     x_line_val_tbl(1):=OE_Line_Util.Get_Values
    (   p_line_rec                    => x_line_tbl(1)
    ,   p_old_line_rec                => x_old_line_tbl(1)
    );

-- OPM 02/JUN/00 - Load process control attributes
    l_x_item_rec_type                   := OE_Order_Cache.Load_Item
                                         (x_line_tbl(1).inventory_item_id
                                         ,x_line_tbl(1).ship_from_org_id
                                         );

--    x_dualum_ind              := l_x_item_rec_type.dualum_ind; INVCONV
--    x_grade_ctl               := l_x_item_rec_type.grade_ctl;  INVCONV
    x_process_warehouse_flag  := l_x_item_rec_type.process_warehouse_flag;
    x_ont_pricing_qty_source  := l_x_item_rec_type.ont_pricing_qty_source; -- OPM 2046190
    x_grade_control_flag      := l_x_item_rec_type.grade_control_flag;  -- INVCONV
    x_tracking_quantity_ind  := l_x_item_rec_type.tracking_quantity_ind;  -- INVCONV
    x_secondary_default_ind := l_x_item_rec_type.secondary_default_ind; -- INVCONV
      x_lot_control_code      := l_x_item_rec_type.lot_control_code; -- 4172680 INVCONV
      x_lot_divisible_flag := l_x_item_rec_type.lot_divisible_flag; -- INVCONV

    --  Write to cache.
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'WRITING TO CACHE' , 2 ) ;
    END IF;

    Write_line
    (   p_line_rec                    => x_line_tbl(1)
    );

    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.count_and_get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE.CHANGE_ATTRIBUTE' , 1 ) ;
    END IF;

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

       OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attribute'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Change_Attribute;


--  Procedure       Validate_And_Write
--
-- 2806483  All OUT parameters are replaced by validate_write_rec_type
PROCEDURE Validate_And_Write
(x_return_status                  OUT NOCOPY VARCHAR2
, x_msg_count                     OUT NOCOPY NUMBER
, x_msg_data                      OUT NOCOPY VARCHAR2
, x_cascade_flag                  OUT NOCOPY BOOLEAN
, p_line_id                       IN  NUMBER
, p_change_reason_code            IN  VARCHAR2
, p_change_comments               IN  VARCHAR2
, x_line_val_rec                  OUT NOCOPY validate_write_rec_type
)
IS
l_x_line_rec       OE_Order_PUB.Line_Rec_Type;
l_x_line_tbl       OE_Order_PUB.Line_Tbl_Type;
l_x_old_line_tbl   OE_Order_PUB.Line_Tbl_Type;
l_control_rec      OE_GLOBALS.Control_Rec_Type;
l_return_status    VARCHAR2(1);
l_charge_amount    NUMBER := 0.0;
l_last_index       NUMBER;
l_organization_id  NUMBER:= OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
l_set_rec                     OE_ORDER_CACHE.set_rec_type; -- 2806483
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   SAVEPOINT Line_Validate_And_Write;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE.VALIDATE_AND_WRITE' , 1 ) ;
    END IF;

    -- Set UI flag to TRUE
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.check_security        := FALSE;
    l_control_rec.clear_dependents     := FALSE;
    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read line from cache

    Get_line
    (   p_db_record                   => TRUE
    ,   p_line_id                     => p_line_id
    ,   x_line_rec                    => l_x_old_line_tbl(1)
    );

    Get_line
    (   p_db_record                   => FALSE
    ,   p_line_id                     => p_line_id
    ,   x_line_rec                    => l_x_line_tbl(1)
    );

    /* Start Audit Trail -- pass change reason, comments */

    l_x_line_tbl(1).change_reason := p_change_reason_code;
    l_x_line_tbl(1).change_comments := p_change_comments;

    /* End Audit Trail */

    --  Set Operation.

    IF FND_API.To_Boolean(l_x_line_tbl(1).db_flag) THEN
        l_x_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_x_line_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;

        /* We are passing the miss quantity for reserved filed
        since we are not converting this to null in OE_LINE_UTIL_EXT' */
        l_x_old_line_tbl(1).reserved_quantity := FND_API.G_MISS_NUM;

    END IF;

    --  Populate line table



    --  Call Oe_Order_Pvt.Process_order

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'IN VALIDATE_AND_WRITE' ) ;
    END IF;
        oe_debug_pub.add(  'IN VALIDATE_AND_WRITE Change Reason'||p_change_reason_code ) ;
    Oe_Order_Pvt.Lines
    (   p_validation_level              => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list                 => FND_API.G_TRUE
    ,   p_control_rec                   =>   l_control_rec
    ,   p_x_line_tbl                    => l_x_line_tbl
    ,   p_x_old_line_tbl                => l_x_old_line_tbl
    ,   x_return_Status                 => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

 /* The Process Requests and Notify should be invoked for */
 /* Pre-Pack H code level */

    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL < '110508' THEN
    Oe_Order_Pvt.Process_Requests_And_Notify
    (   p_process_requests           => FALSE
    ,   p_init_msg_list              => FND_API.G_FALSE
    ,   p_notify                     => TRUE
    ,   x_return_status              => l_return_status
    ,   p_line_tbl                   => l_x_line_tbl
    ,   p_old_line_tbl               => l_x_old_line_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

   END IF;

    -- bug 1834260, process delayed request for G_COPY_ADJUSTMENTS
    -- before processing for G_PRICE_LINE.
   IF OE_GLOBALS.G_DEFER_PRICING='N' THEN
    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_COPY_ADJUSTMENTS
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;
   END IF;

   IF OE_GLOBALS.G_DEFER_PRICING='N' THEN
    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_PRICE_LINE
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;
   END IF;

   IF OE_GLOBALS.G_DEFER_PRICING='N' THEN
    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_TAX_LINE
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;
   END IF;

    -- lkxu, commitment enhancement
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'CALLING TO PROCESS DELAYED REQUEST FOR COMMITMENT!' , 1 ) ;
    END IF;

   IF OE_GLOBALS.G_DEFER_PRICING='N' THEN
    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_CALCULATE_COMMITMENT
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;

    --bug 3560198
    OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
         (p_request_type   =>OE_GLOBALS.G_UPDATE_COMMITMENT_APPLIED
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;
    --bug 3560198
   END IF;

    x_cascade_flag := OE_GLOBALS.G_CASCADING_REQUEST_LOGGED;

   --fix for bug 4102372
   -- x_line_val_rec.x_lock_control:=l_x_line_tbl(1).lock_control;

    --  Load OUT parameters.

      oe_line_util.query_row(
                                   p_line_id  =>l_x_line_tbl(1).line_id
                                   ,x_line_rec=>l_x_line_rec
                                           );
    x_line_val_rec.x_lock_control     :=l_x_line_rec.lock_control;
    x_line_val_rec.x_creation_date    := l_x_line_rec.creation_date;
    x_line_val_rec.x_created_by                   := l_x_line_rec.created_by;
    x_line_val_rec.x_last_update_date             := l_x_line_rec.last_update_date;
    x_line_val_rec.x_last_updated_by              := l_x_line_rec.last_updated_by;
    x_line_val_rec.x_last_update_login            := l_x_line_rec.last_update_login;

--  Loading Scheduling attributes

    x_line_val_rec.x_schedule_ship_date           := l_x_line_rec.schedule_ship_date;
    x_line_val_rec.x_schedule_arrival_date        := l_x_line_rec.schedule_arrival_date;
    x_line_val_rec.x_schedule_status_code         := l_x_line_rec.schedule_status_code;
    x_line_val_rec.x_schedule_action_code         := l_x_line_rec.schedule_action_code;
    x_line_val_rec.x_earliest_ship_date           := l_x_line_rec.earliest_ship_date;
    x_line_val_rec.x_firm_demand_flag             := l_x_line_rec.firm_demand_flag;

-- Loading Item substitution attributes.

    x_line_val_rec.x_original_inventory_item_id
                             := l_x_line_rec.original_inventory_item_id;
    x_line_val_rec.x_original_item_iden_type
                             := l_x_line_rec.original_item_identifier_type;
    x_line_val_rec.x_original_ordered_item_id
                             := l_x_line_rec.original_ordered_item_id;

    IF x_line_val_rec.x_original_inventory_item_id IS NOT NULL
    OR x_line_val_rec.x_original_ordered_item_id   IS NOT NULL THEN
      OE_ID_TO_VALUE.Ordered_Item
      (p_Item_Identifier_type    => x_line_val_rec.x_original_item_iden_type
      ,p_inventory_item_id       => x_line_val_rec.x_original_inventory_item_id
      ,p_organization_id         => l_organization_id
      ,p_ordered_item_id         => x_line_val_rec.x_original_ordered_item_id
      ,p_sold_to_org_id          => l_x_line_rec.sold_to_org_id
      ,p_ordered_item            => l_x_line_rec.original_ordered_item
      ,x_ordered_item            => x_line_val_rec.x_original_ordered_item
      ,x_inventory_item          => x_line_val_rec.x_original_inventory_item);

    END IF;
    IF x_line_val_rec.x_original_item_iden_type IS NOT NULL THEN
      OE_ID_TO_VALUE.item_identifier
      (p_Item_Identifier_type   => x_line_val_rec.x_original_item_iden_type
      ,x_Item_Identifier        => x_line_val_rec.x_original_item_type);
    END IF;

    -- Update Late Demand Penalty Factor Bug-2478107
    x_line_val_rec.x_late_demand_penalty_factor := l_x_line_rec.late_demand_penalty_factor;

     -- Update Override ATP Flag
    x_line_val_rec.x_override_atp_date_code := l_x_line_rec.override_atp_date_code;

/* The following IF statement is commented to fix bug#1382357 */
--    IF NVL(l_x_old_line_tbl(1).ship_from_org_id,-1) <>
--               NVL(l_x_line_rec.ship_from_org_id,-1) THEN

       OE_ID_TO_VALUE.Ship_From_Org(
                    p_ship_from_org_id   => l_x_line_rec.ship_from_org_id
                   ,x_ship_from_address1 => x_line_val_rec.x_ship_from_address1
                   ,x_ship_from_address2 => x_line_val_rec.x_ship_from_address2
                   ,x_ship_from_address3 => x_line_val_rec.x_ship_from_address3
                   ,x_ship_from_address4 => x_line_val_rec.x_ship_from_address4
                   ,x_ship_from_location => x_line_val_rec.x_ship_from_location
                   ,x_ship_from_org      => x_line_val_rec.x_ship_from_org
                   );

 --   END IF;

    x_line_val_rec.x_ship_from_org_id := l_x_line_rec.ship_from_org_id;
    x_line_val_rec.x_subinventory     := l_x_line_rec.subinventory;
    x_line_val_rec.x_promise_date     := l_x_line_rec.promise_date;
    -- Start 2806483
    x_line_val_rec.x_shipping_method_code
                      := l_x_line_rec.shipping_method_code;
    IF x_line_val_rec.x_shipping_method_code IS NOT NULL THEN
       x_line_val_rec.x_shipping_method
          := OE_ID_TO_VALUE.Ship_Method(p_ship_method_code => x_line_val_rec.x_shipping_method_code);
    END IF;
    x_line_val_rec.x_freight_carrier_code
                      := l_x_line_rec.freight_carrier_code;
    IF x_line_val_rec.x_freight_carrier_code IS NOT NULL THEN
       x_line_val_rec.x_freight_carrier
          := OE_ID_TO_VALUE.Freight_Carrier
                       (p_freight_carrier_code =>x_line_val_rec.x_freight_carrier_code,
                        p_ship_from_org_id     =>x_line_val_rec.x_ship_from_org_id);
    END IF;
    -- End 2806483
    -- 2817915
    IF l_x_line_rec.ship_set_id IS NOT NULL THEN
       l_set_rec := OE_ORDER_CACHE.Load_Set(l_x_line_rec.ship_set_id);
       x_line_val_rec.x_ship_set_id := l_x_line_rec.ship_set_id;
       x_line_val_rec.x_ship_set    := l_set_rec.set_name;
    ELSIF l_x_line_rec.arrival_set_id IS NOT NULL THEN
       l_set_rec := OE_ORDER_CACHE.Load_Set(l_x_line_rec.arrival_set_id);
       x_line_val_rec.x_arrival_set_id := l_x_line_rec.arrival_set_id;
       x_line_val_rec.x_arrival_set    := l_set_rec.set_name;
    END IF;
    -- 2817915

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ARRIVALSET-'|| TO_CHAR ( L_X_LINE_REC.ARRIVAL_SET_ID ) , 2 ) ;
    END IF;
   -- Calculate Tax

    x_line_val_rec.x_line_tax_value := l_x_line_rec.tax_value;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'TAX VALUE IS'|| TO_CHAR ( L_X_LINE_REC.TAX_VALUE ) , 1 ) ;
       oe_debug_pub.add(  'CALLING ORDER TOTAL' , 2 ) ;
   END IF;

    -- Call the charges API to get the Line level charges.
   IF OE_GLOBALS.G_DEFER_PRICING='N' THEN
    OE_CHARGE_PVT.Get_Charge_Amount(
                           p_api_version_number => 1.1 ,
                           p_init_msg_list      => FND_API.G_FALSE ,
                           p_header_id          => l_x_line_rec.header_id ,
                           p_line_id            => l_x_line_rec.line_id ,
                           p_all_charges        => FND_API.G_FALSE ,
                           x_return_status      => l_return_status ,
                           x_msg_count          => x_msg_count ,
                           x_msg_data           => x_msg_data ,
                           x_charge_amount      => l_charge_amount );

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
     END IF;
     x_line_val_rec.x_charges := l_charge_amount;
   END IF;

    -- Update pricing details
    x_line_val_rec.x_unit_selling_price         := l_x_line_rec.unit_selling_price;
    x_line_val_rec.x_unit_list_price            := l_x_line_rec.unit_list_price;
    x_line_val_rec.x_list_percent               := l_x_line_rec.unit_list_percent;
    x_line_val_rec.x_selling_percent            := round(l_x_line_rec.unit_selling_percent,6);
    x_line_val_rec.x_pricing_quantity           := l_x_line_rec.pricing_quantity;
    x_line_val_rec.x_pricing_quantity_uom       := l_x_line_rec.pricing_quantity_uom;
    x_line_val_rec.x_calculate_price_flag       := l_x_line_rec.calculate_price_flag;
    x_line_val_rec.x_calculate_price_descr
                        := OE_Id_To_Value.Calculate_Price_Flag(x_line_val_rec.x_calculate_price_flag);
    x_line_val_rec.x_price_list_id              := l_x_line_rec.price_list_id;
    x_line_val_rec.x_price_list                 := OE_Id_To_Value.Price_List(x_line_val_rec.x_price_list_id);
    x_line_val_rec.x_payment_term_id            := l_x_line_rec.payment_term_id;
    x_line_val_rec.x_payment_term               := OE_Id_To_Value.Payment_Term(x_line_val_rec.x_payment_term_id);

    x_line_val_rec.x_shipment_priority_code     := l_x_line_rec.shipment_priority_code;
    x_line_val_rec.x_shipment_priority
                        := OE_Id_To_Value.Shipment_Priority(x_line_val_rec.x_shipment_priority_code);
    x_line_val_rec.x_freight_terms_code         := l_x_line_rec.freight_terms_code;
    x_line_val_rec.x_freight_terms              := OE_Id_To_Value.Freight_Terms(x_line_val_rec.x_freight_terms_code);
    x_line_val_rec.x_inventory_item_id          := l_x_line_rec.inventory_item_id;
    x_line_val_rec.x_ordered_item_id            := l_x_line_rec.ordered_item_id;

   IF OE_GLOBALS.G_DEFER_PRICING='N' THEN
    -- lkxu, commitment enhancement.
    IF UPPER(Nvl(Fnd_Profile.Value('OE_COMMITMENT_SEQUENCING'),'N')) = 'Y' THEN
      x_line_val_rec.x_commitment_applied_amount := OE_COMMITMENT_PVT.get_commitment_applied_amount
                          (p_header_id          => l_x_line_rec.header_id ,
                           p_line_id            => l_x_line_rec.line_id ,
                           p_commitment_id      => l_x_line_rec.commitment_id);
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
   END IF;
-- Override List Price
   x_line_val_rec.x_original_list_price := l_x_line_rec.original_list_price;
   x_line_val_rec.x_unit_list_price_per_pqty := l_x_line_rec.unit_list_price_per_pqty;
   x_line_val_rec.x_unit_selling_price_per_pqty := l_x_line_rec.unit_selling_price_per_pqty;
-- Override List Price

    --  Clear line record cache

    Clear_line;



    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.count_and_get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE.VALIDATE_AND_WRITE' , 1 ) ;
    END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

       OE_GLOBALS.G_UI_FLAG := FALSE;

        ROLLBACK TO SAVEPOINT Line_Validate_And_Write;
/* From the UI, if we raise an exception here, user can
   make proper change and try to commit again, ended up with multiple
   records in the start flow global table. To avoid that, we
   are deleting the last entry in the global table upon exception.

   This change is only made here, assuming only UI has the
   ability to do something like that.
*/

        l_last_index := OE_GLOBALS.G_START_LINE_FLOWS_TBL.last;
        IF (l_x_line_tbl(1).operation = OE_GLOBALS.G_OPR_CREATE
               AND l_last_index IS NOT NULL    -- 2068070
               AND OE_GLOBALS.G_START_LINE_FLOWS_TBL(l_last_index).line_id = p_line_id) THEN --Bug 3000619
               OE_GLOBALS.G_START_LINE_FLOWS_TBL.delete(l_last_index);
        END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       OE_GLOBALS.G_UI_FLAG := FALSE;

        ROLLBACK TO SAVEPOINT Line_Validate_And_Write;
        l_last_index := OE_GLOBALS.G_START_LINE_FLOWS_TBL.last;
        IF (l_x_line_tbl(1).operation = OE_GLOBALS.G_OPR_CREATE
               AND l_last_index IS NOT NULL    -- 2068070
               AND OE_GLOBALS.G_START_LINE_FLOWS_TBL(l_last_index).line_id = p_line_id) THEN --Bug 3000619
               OE_GLOBALS.G_START_LINE_FLOWS_TBL.delete(l_last_index);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

       OE_GLOBALS.G_UI_FLAG := FALSE;

        ROLLBACK TO SAVEPOINT Line_Validate_And_Write;
        l_last_index := OE_GLOBALS.G_START_LINE_FLOWS_TBL.last;
        IF (l_x_line_tbl(1).operation = OE_GLOBALS.G_OPR_CREATE
               AND l_last_index IS NOT NULL    -- 2068070
               AND OE_GLOBALS.G_START_LINE_FLOWS_TBL(l_last_index).line_id = p_line_id) THEN --Bug 3000619
               OE_GLOBALS.G_START_LINE_FLOWS_TBL.delete(l_last_index);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_And_Write'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.count_and_get
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
,   p_line_id                       IN  NUMBER
, p_change_reason_code            IN  VARCHAR2 Default Null
, p_change_comments               IN  VARCHAR2 Default Null
)
IS
l_x_line_rec                    OE_Order_PUB.Line_Rec_Type;
l_x_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_x_old_line_tbl                    OE_Order_PUB.Line_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    SAVEPOINT LINE_DELETE;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE.DELETE_ROW' , 1 ) ;
    END IF;

    -- Set UI flag to TRUE
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.check_security        := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read DB record from cache

     Get_line
    (   p_db_record                   => TRUE
    ,   p_line_id                     => p_line_id
    ,   x_line_rec                    => l_x_line_rec
    );

    --  Set Operation.

    l_x_line_rec.operation := OE_GLOBALS.G_OPR_DELETE;

    --  Populate line table

    l_x_line_tbl(1) := l_x_line_rec;
    l_x_line_tbl(1).change_reason := p_change_reason_code;
    l_x_line_tbl(1).change_comments := p_change_comments;

    --  Call Oe_Order_Pvt.Process_order

    Oe_Order_Pvt.Lines
    (   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                 => l_control_rec
    ,   p_x_line_tbl                  => l_x_line_tbl
    ,   p_x_old_line_tbl              => l_x_old_line_tbl
    ,   x_return_status               => l_return_status

    );


    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Clear line record cache

    Clear_line;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.count_and_get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE.DELETE_ROW' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO SAVEPOINT Line_Delete;
       OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO SAVEPOINT Line_Delete;

       OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN
       ROLLBACK TO SAVEPOINT Line_Delete;

       OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.count_and_get
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
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_rec            OE_Order_PUB.Header_Adj_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_rec        OE_Order_PUB.Header_Scredit_Rec_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_rec                  OE_Order_PUB.Line_Rec_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_rec          OE_Order_PUB.Line_Scredit_Rec_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_Action_Request_tbl        OE_Order_PUB.Request_Tbl_Type;
l_x_Lot_Serial_Tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
l_x_Header_price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_x_Line_price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
--serla begin
l_x_Header_Payment_tbl        OE_Order_PUB.Header_Payment_Tbl_Type;
l_x_Line_Payment_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
--serla end
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE.PROCESS_ENTITY' , 1 ) ;
    END IF;

    -- Set UI flag to TRUE
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_LINE;

    l_control_rec.check_security        := FALSE;
    l_control_rec.clear_dependents     := FALSE;
    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Call Oe_Order_Pvt.Process_order

    Oe_Order_Pvt.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                  => l_x_header_rec
    ,   p_x_Header_Adj_tbl              => l_x_Header_Adj_tbl
    ,   p_x_header_price_att_tbl        => l_x_header_price_att_tbl
    ,   p_x_Header_Adj_att_tbl          => l_x_Header_Adj_att_tbl
    ,   p_x_Header_Adj_Assoc_tbl        => l_x_Header_Adj_Assoc_tbl
    ,   p_x_Header_Scredit_tbl          => l_x_Header_Scredit_tbl
--serla begin
    ,   p_x_Header_Payment_tbl          => l_x_Header_Payment_tbl
--serla end
    ,   p_x_line_tbl                    => l_x_line_tbl
    ,   p_x_Line_Adj_tbl                => l_x_Line_Adj_tbl
    ,   p_x_Line_Price_att_tbl          => l_x_Line_Price_att_tbl
    ,   p_x_Line_Adj_att_tbl            => l_x_Line_Adj_att_tbl
    ,   p_x_Line_Adj_Assoc_tbl          => l_x_Line_Adj_Assoc_tbl
    ,   p_x_Line_Scredit_tbl            => l_x_Line_Scredit_tbl
--serla begin
    ,   p_x_Line_Payment_tbl            => l_x_Line_Payment_tbl
--serla end
    ,   p_x_action_request_tbl          => l_x_Action_Request_tbl
    ,   p_x_lot_serial_tbl            => l_x_lot_serial_tbl
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

    oe_msg_pub.count_and_get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE.PROCESS_ENTITY' , 1 ) ;
    END IF;

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

       OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Entity'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Entity;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_line_id                       IN  NUMBER
,   p_lock_control                  IN  NUMBER
)

IS
l_return_status               VARCHAR2(1);
l_x_line_rec                  OE_Order_PUB.Line_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE.LOCK_ROW' , 1 ) ;
    END IF;

    --  Load line record

    l_x_line_rec.lock_control        := p_lock_control;
    l_x_line_rec.line_id             := p_line_id;
    l_x_line_rec.operation           := OE_GLOBALS.G_OPR_LOCK; -- not req.

    --Bug 3025978
      OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Call OE_Line_Util.Lock_Row instead of Oe_Order_Pvt.Lock_order
    OE_MSG_PUB.initialize;
    OE_Line_Util.Lock_Row
    ( x_return_status         => l_return_status
    , p_x_line_rec            => l_x_line_rec
    , p_line_id               => p_line_id);

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_line_rec.db_flag := FND_API.G_TRUE;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE.LOCK_ROW'||L_X_LINE_REC.LINE_ID , 1 ) ;
    END IF;

        Write_line
        (   p_line_rec                    => l_x_line_rec
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

    oe_msg_pub.count_and_get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE.LOCK_ROW' , 1 ) ;
    END IF;

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

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );



END Lock_Row;

--  Procedures maintaining line record cache.

PROCEDURE Write_line
(   p_line_rec                      IN  OE_Order_PUB.Line_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE.WRITE_LINE' , 1 ) ;
    END IF;
    g_line_rec := p_line_rec;

    IF p_db_record THEN

        g_db_line_rec := p_line_rec;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE.WRITE_LINE' , 1 ) ;
    END IF;

END Write_Line;

PROCEDURE Get_line
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_line_id                       IN  NUMBER
,   x_line_rec                      OUT NOCOPY  OE_Order_PUB.Line_Rec_Type
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE.GET_LINE'||P_LINE_ID , 1 ) ;
    END IF;
    --reverting back the fix made for bug 2103000 as the problem
    --is fixed in file OEXOEFRM.pld(version 115.251)
    --Fixes the issue reported in bug 2150247
    IF  p_line_id <> NVL(g_line_rec.line_id,FND_API.G_MISS_NUM)
    THEN

        --  Query row from DB
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE.GET_LINE QUERY '||P_LINE_ID , 1 ) ;
    END IF;

        OE_Line_Util.Query_Row
        (   p_line_id                     => p_line_id,
          x_line_rec                    =>g_line_rec
        );

        g_line_rec.db_flag             := FND_API.G_TRUE;

        --  Load DB record

        g_db_line_rec                  := g_line_rec;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE.GET_LINE' , 1 ) ;
    END IF;

    IF p_db_record THEN
      --Added for bug3911285
      IF p_line_id <> g_db_line_rec.line_id THEN
        g_db_line_rec := OE_Order_PUB.G_MISS_LINE_REC;
      END IF;
      --End of bug3911285

        x_line_rec:= g_db_line_rec;

    ELSE

        x_line_rec:= g_line_rec;

    END IF;

END Get_Line;

PROCEDURE Clear_Line
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE.CLEAR_LINE' , 1 ) ;
    END IF;

    g_line_rec                     := OE_Order_PUB.G_MISS_LINE_REC;
    g_db_line_rec                  := OE_Order_PUB.G_MISS_LINE_REC;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE.CLEAR_LINE' , 1 ) ;
    END IF;

END Clear_Line;

PROCEDURE POPULATE_CONTROL_FIELDS
( p_line_rec        IN line_rec_type,
x_line_val_rec OUT NOCOPY line_val_rec_type,
 p_calling_block   IN  VARCHAR2
) IS
  l_flow_meaning VARCHAR2(80);
  released_count NUMBER;
  total_count   NUMBER;
  l_status      VARCHAR2(80);
/*1931163*/
  l_hold_exists        VARCHAR2(1);
  l_ato_line_id        NUMBER;
  l_top_model_line_id  NUMBER;
  l_smc_flag           VARCHAR2(1);
  l_item_type_code     VARCHAR2(30);
  l_link_to_line_id    NUMBER;
--retro{
  l_retrobilled_price_diff NUMBER;
  l_unit_selling_price     NUMBER;
--retro}
--recurring charges
  l_charge_periodicity VARCHAR2(25);
  --bug 10047225
  l_concat_segs	varchar2(2000):='';
  l_valid_kff     boolean;

  CURSOR C1(tax_exempt_reason_code VARCHAR2,
          tax_exempt_flag        VARCHAR2,
            fob_point_code         VARCHAR2,
          return_reason_code     VARCHAR2)
  IS
     SELECT meaning,lookup_type
    FROM   AR_LOOKUPS
    WHERE (lookup_code=tax_exempt_reason_code
    AND    lookup_type='TAX_REASON')
    OR    (lookup_code=tax_exempt_flag
    AND    lookup_type='TAX_CONTROL_FLAG')
    OR    (lookup_code=fob_point_code
    AND    lookup_type='FOB')
    OR    (lookup_code=return_reason_code
    AND    lookup_type='CREDIT_MEMO_REASON');
  CURSOR c2(shipment_priority_code  VARCHAR2,
        freight_terms_code VARCHAR2)
  IS
     SELECT meaning,lookup_type
     FROM FND_LOOKUP_VALUES LV
     WHERE LANGUAGE = userenv('LANG')
     and VIEW_APPLICATION_ID = 660
     and((lookup_code= shipment_priority_code
     and lookup_type='SHIPMENT_PRIORITY')
     or (lookup_code=freight_terms_code
     and lookup_type='FREIGHT_TERMS'))
     and SECURITY_GROUP_ID =fnd_global.Lookup_Security_Group(lv.lookup_type,lv.view_application_id);
  /*l_organization_id  Number:=fnd_profile.value('OE_ORGANIZATION_ID');*/
    -- This change is required since we are dropping the profile OE_ORGANIZATION    -- _ID. Change made by Esha.
    l_organization_id Number;
  /* Need to Change Exception Handling- Not Sure whether we should continue
    to process other attribute when one of the attribute raises exception.
    Checked in 11i and  they are continuing processing of other attributes */
    l_address_id number;
        l_sales_order_id number;
        l_msg_count  number;
        l_msg_data   Varchar2(2000);
        l_return_status VARCHAR2(1);

  /* 1931163 */
  CURSOR line_on_hold(c_line_id NUMBER) IS
  SELECT 'Y' hold_exists
  FROM   oe_order_holds
  WHERE  line_id       = c_line_id
  AND    released_flag = 'N';

  CURSOR line_info(c_line_id NUMBER) IS
  SELECT
    ato_line_id
  , top_model_line_id
  , nvl(ship_model_complete_flag, 'N') smc_flag
  , item_type_code
  , link_to_line_id
  FROM   oe_order_lines
  WHERE  line_id = c_line_id;

 CURSOR ato_lines_on_hold(c_ato_line_id NUMBER, c_top_model_line_id NUMBER) IS
 SELECT 'Y' hold_exists
 FROM   oe_order_holds ooh, oe_order_lines ool
 where  ool.ato_line_id = c_ato_line_id
 and    ool.top_model_line_id = c_top_model_line_id
 and    ooh.line_id = ool.line_id
 and    ooh.released_flag = 'N';

 CURSOR smc_lines_on_hold(c_top_model_line_id NUMBER) IS
 SELECT 'Y' hold_exists
 FROM   oe_order_holds ooh, oe_order_lines ool
 where  ool.top_model_line_id = c_top_model_line_id
 and    ooh.line_id = ool.line_id
 and    ooh.released_flag = 'N';

 CURSOR link_to_line_hold(c_link_to_line_id NUMBER) IS
 SELECT 'Y' hold_exists
 FROM   oe_order_holds ooh, oe_hold_definitions ohd, oe_hold_sources ohs
 where  ooh.line_id = c_link_to_line_id
 and    ooh.released_flag = 'N'
 and    ohs.hold_source_id = ooh.hold_source_id
 and    ohs.hold_id = ohd.hold_id
 and    nvl(ohd.hold_included_items_flag, 'N') = 'Y';

 --MRG BGN
 l_order_margin_percent NUMBER;
 l_order_margin_amount  NUMBER;
 --MRG END

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
--7832836  l_cascade_hold_non_smc VARCHAR2(1) := NVL(OE_SYS_PARAMETERS.VALUE('ONT_CASCADE_HOLD_NONSMC_PTO'),'N'); --ER#7479609
l_cascade_hold_non_smc VARCHAR2(1);  -- 7832836
BEGIN
    l_organization_id := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID',
                               p_line_rec.org_id);
    l_cascade_hold_non_smc := NVL(OE_SYS_PARAMETERS.VALUE('ONT_CASCADE_HOLD_NONSMC_PTO',p_line_rec.org_id),'N'); --7832836
--   Populate Project Number and  Task Number
   IF p_line_rec.project_id is not Null then
    BEGIN
 /*      Select project_number
      into  x_line_val_rec.project_number
      from pjm_projects_org_v
      Where project_id=p_line_rec.project_id;*/

       x_line_val_rec.project_number := pjm_project.all_proj_idtonum(p_line_rec.project_id);
    EXCEPTION
      When no_data_found then
      Null;
       When too_many_rows then
      Null;
     END;
   END IF;

   IF p_line_rec.task_id is not null then
/*  Select task_number
    Into x_line_val_rec.task_number
    From pjm_tasks_v
    Where task_id=p_line_rec.task_id;*/

      x_line_val_rec.task_number := pjm_project.all_task_idtonum(p_line_rec.task_id);
   END IF;
--retro{Previously commented by VMALAPAT. Removed the comment for retrobilling
--This query fires only once per order
 IF(g_header_id is NULL or  p_line_rec.header_id <> g_header_id) THEN
   IF p_line_rec.header_id is not null THEN
  BEGIN  -- Bug 8360952 handle exception
    select transactional_curr_code
     into x_line_val_rec.transactional_curr_code
     from oe_order_headers
    where header_id=p_line_rec.header_id;
     g_header_id := p_line_rec.header_id;
     g_currency_code :=x_line_val_rec. transactional_curr_code;
  EXCEPTION
  WHEN OTHERS THEN
   null;
  END;

   END IF;
 ELSE
     x_line_val_rec.transactional_curr_code := g_currency_code;
 END IF;
--retro}
  IF p_line_rec.line_id IS NOT NULL THEN

    x_line_val_rec.hold_exists_flag := 'N';
    x_line_val_rec.cascaded_hold_exists_flag := 'N';

    /* 1931163: First check if there is ANY unreleased hold on the order/lines */
    BEGIN
      SELECT 'Y'
      INTO   l_hold_exists
      FROM   OE_ORDER_HOLDS
      WHERE  HEADER_ID = p_line_rec.header_id
      AND    RELEASED_FLAG = 'N';
      EXCEPTION
        WHEN TOO_MANY_ROWS THEN
          l_hold_exists := 'Y';
          null;
        WHEN OTHERS THEN
          l_hold_exists := 'N';
          null;
    END;

    IF l_hold_exists = 'Y' THEN

      /* 1931163: Check if Hold Exist on Line */
      FOR line_hold_rec in line_on_hold(p_line_rec.line_id) LOOP

        x_line_val_rec.hold_exists_flag := line_hold_rec.hold_exists;
        EXIT;

      END LOOP;

      /* 1931163: Check if Cascaded Hold Exist on Line */
      IF x_line_val_rec.hold_exists_flag = 'N' THEN

        OPEN line_info(p_line_rec.line_id);

        FETCH line_info
        INTO  l_ato_line_id, l_top_model_line_id, l_smc_flag,
              l_item_type_code, l_link_to_line_id;

        CLOSE line_info;

        /* 1931163: Check Cascaded Hold based on ATO Line(s) */
        IF l_ato_line_id IS NOT NULL AND
        NOT (l_ato_line_id = p_line_rec.line_id AND l_item_type_code = OE_GLOBALS.G_ITEM_OPTION) THEN

          FOR ato_hold_rec in ato_lines_on_hold(l_ato_line_id, l_top_model_line_id)
          LOOP

       IF p_line_rec.cancelled_flag = 'N' and p_line_rec.open_flag = 'Y'
       THEN

            x_line_val_rec.cascaded_hold_exists_flag := ato_hold_rec.hold_exists;
       END IF;
            EXIT;

          END LOOP;
        END IF; -- ATO

        /* 1931163: Check Cascaded Hold based on SMC Line(s) */
        IF l_smc_flag = 'Y' AND x_line_val_rec.cascaded_hold_exists_flag = 'N' THEN

          FOR smc_hold_rec in smc_lines_on_hold(l_top_model_line_id)
          LOOP
       IF p_line_rec.cancelled_flag = 'N' and p_line_rec.open_flag = 'Y'
       THEN

            x_line_val_rec.cascaded_hold_exists_flag := smc_hold_rec.hold_exists;
       END IF;
            EXIT;

          END LOOP;
        END IF; -- SMC


        --5737464
        IF l_smc_flag = 'N' AND x_line_val_rec.cascaded_hold_exists_flag = 'N'
        THEN
           IF l_debug_level > 0 THEN
              oe_debug_pub.add('GOING TO CHECK FOR CONFIG VALIDATION HOLD FOR '||l_top_model_line_id,1);
           END IF;

           BEGIN
              l_hold_exists := NULL;

            IF l_cascade_hold_non_smc <> 'Y' THEN
              SELECT 'Y' hold_exists
              INTO l_hold_exists
              FROM   oe_order_holds ooh, oe_hold_definitions ohd, oe_hold_sources ohs
              where  ooh.line_id = l_top_model_line_id
              and    ooh.released_flag = 'N'
              and    ohs.hold_source_id = ooh.hold_source_id
              and    ohs.hold_id = ohd.hold_id
              and    ohd.hold_id = 3;
            --ER#7479609 start
            ELSE
              SELECT 'Y' hold_exists
              INTO l_hold_exists
              FROM   oe_order_holds ooh, oe_hold_definitions ohd, oe_hold_sources ohs
              where  ooh.line_id = l_top_model_line_id
              and    ooh.released_flag = 'N'
              and    ohs.hold_source_id = ooh.hold_source_id
              and    ohs.hold_id = ohd.hold_id;
            END IF;
            --ER#7479609 end
           EXCEPTION
              WHEN OTHERS THEN
                 NULL;
           END;
           IF l_hold_exists = 'Y' THEN

              IF p_line_rec.cancelled_flag = 'N' and p_line_rec.open_flag = 'Y'
              THEN
                 IF l_debug_level > 0 THEN
                    oe_debug_pub.add('HOLD CASCADED TO LINE ID '||p_line_rec.line_id,1);
                 END IF;
                 x_line_val_rec.cascaded_hold_exists_flag := 'Y';
              END IF;
           END IF;
        END IF;
        --5737464


        /* 1931163: Check Cascaded Hold for Included Item */
        IF l_item_type_code = OE_GLOBALS.G_ITEM_INCLUDED AND x_line_val_rec.cascaded_hold_exists_flag = 'N' THEN

          FOR link_to_hold_rec in link_to_line_hold(l_link_to_line_id)
          LOOP

       IF p_line_rec.cancelled_flag = 'N' and p_line_rec.open_flag = 'Y'
       THEN
            x_line_val_rec.cascaded_hold_exists_flag := link_to_hold_rec.hold_exists;
      END IF;
            EXIT;

          END LOOP;

        END IF; -- Hold on Included Items

      END IF; -- No Real Holds on Line

    END IF; -- Any Hold on Order/Line

  END IF;

 -- Changes for Visibility to Process Messages datafix project begin

  x_line_val_rec.message_exists_flag := 'N';

  IF G_ENABLE_VISIBILITY_MSG = 'Y' AND
             p_line_rec.line_id is NOT NULL THEN
        BEGIN
             SELECT 'Y'
             INTO   x_line_val_rec.message_exists_flag
             FROM   OE_PROCESSING_MSGS
             WHERE  header_id = p_line_rec.header_id
             AND    line_id = p_line_rec.line_id
             AND NVL(message_status_code, '0') <> 'CLOSED'  --datafix_begin_end
             AND    rownum < 2;
        EXCEPTION
              WHEN TOO_MANY_ROWS THEN
                   x_line_val_rec.message_exists_flag  := 'Y';
              WHEN OTHERS THEN
                   x_line_val_rec.message_exists_flag := 'N';
        END;
  END IF;

   IF (p_line_rec.line_category_code = 'RETURN') THEN
    IF (p_line_rec.reference_line_id is not null) THEN
     BEGIN
      select  /* MOAC_SQL_CHANGE */  H.order_number,
             l.line_number,
             l.shipment_number,
             l.option_number,
             l.component_number
      into x_line_val_rec.ref_order_number,
           x_line_val_rec.ref_line_number,
           x_line_val_rec.ref_shipment_number,
           x_line_val_rec.ref_option_number,
           x_line_val_rec.ref_component_number
      from oe_order_headers_all h,
           oe_order_lines_all l
      where l.line_id=p_line_rec.reference_line_id
      and h.header_id=l.header_id;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
      oe_debug_pub.add('In NO Data Found ');
       When too_many_rows then
       Null;
      When others then
      oe_debug_pub.add('In Others Found ');
      Null;
     END;
     END IF;

     IF (p_line_rec.reference_customer_trx_line_id is not null) THEN
     BEGIN
       select /* MOAC_SQL_CHANGE */ rct.trx_number,
              rctl.line_number
       into x_line_val_rec.ref_invoice_number,
            x_line_val_rec.ref_invoice_line_number
       from ra_customer_trx_all rct,
            ra_customer_trx_lines_all rctl
       where rctl.customer_trx_line_id = p_line_rec.reference_customer_trx_line_id
       and rctl.customer_trx_id = rct.customer_trx_id;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
      Null;
      When others then
      Null;
     END;
     END IF;

     IF (p_line_rec.reference_customer_trx_line_id is not null) THEN
     BEGIN
       select /* MOAC_SQL_CHANGE */ rct.trx_number,
              rctl.line_number
       into x_line_val_rec.ref_invoice_number,
            x_line_val_rec.ref_invoice_line_number
       from ra_customer_trx_all rct,
            ra_customer_trx_lines_all rctl
       where rctl.customer_trx_line_id = p_line_rec.reference_customer_trx_line_id
       and rctl.customer_trx_id = rct.customer_trx_id;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
      Null;
      When others then
      Null;
     END;
     END IF;

     IF (p_line_rec.credit_invoice_line_id is not null) THEN
     BEGIN
       select /* MOAC_SQL_CHANGE */ rct.trx_number
       into x_line_val_rec.credit_invoice_number
       from ra_customer_trx_all rct,
         ra_customer_trx_lines_all rctl
       where rctl.customer_trx_line_id = p_line_rec.credit_invoice_line_id
       and rctl.customer_trx_id = rct.customer_trx_id;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       NULL;
       When too_many_rows then
      Null;
      When others then
      Null;
     END;
     END IF;
   END IF;

   IF (p_line_rec.salesrep_id is not null) then
   BEGIN
    Select Name
    INTO x_line_val_rec.salesrep
    FROM  RA_SALESREPS
    WHERE Salesrep_id=p_line_rec.salesrep_id
        AND org_id=p_line_rec.org_id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
     NULL;
     When too_many_rows then
    Null;
   END;
   END IF;

   IF (p_line_rec.tax_exempt_reason_code is not null) or
      (p_line_rec.tax_exempt_flag is not null)or
      (p_line_rec.fob_point_code is not null) or
      (p_line_rec.return_reason_code is not null) then
     BEGIN
       FOR lookups in c1(p_line_rec.tax_exempt_reason_code,
                     p_line_rec.tax_exempt_flag,
                     p_line_rec.fob_point_code,
                     p_line_rec.return_reason_code)
        LOOP
        IF lookups.lookup_type='TAX_REASON'  then
          x_line_val_rec.tax_exempt_reason:=lookups.meaning;
          ELSIF lookups.lookup_type='TAX_CONTROL_FLAG' then
          x_line_val_rec.tax_exempt:=lookups.meaning;
        ELSIF lookups.lookup_type='FOB' then
          x_line_val_rec.fob:=lookups.meaning;
        ELSIF lookups.lookup_type='CREDIT_MEMO_REASON' then
          x_line_val_rec.return_reason:=lookups.meaning;
          END IF;
        END LOOP;
    END;
    END IF;

    IF (p_line_rec.shipment_priority_code is not null) or
       (p_Line_rec.freight_terms_code is not null) THEN
      BEGIN
      FOR oe_lookups in c2(p_line_rec.shipment_priority_code,
                        p_Line_rec.freight_terms_code)
      LOOP
       IF oe_lookups.lookup_type='SHIPMENT_PRIORITY'then
         x_line_val_rec.shipment_priority:=oe_lookups.meaning;
        ELSIF oe_lookups.lookup_type='FREIGHT_TERMS' then
         x_line_val_rec.freight_terms:=oe_lookups.meaning;
       END IF;
      END LOOP;
      END;
    END IF;

    -- Changes for 2748513

     IF p_line_rec.flow_status_code is not NULL THEN

      x_line_val_rec.status :=
            OE_LINE_STATUS_PUB.Get_Line_Status(
                 p_line_id          =>  p_line_rec.line_id
                ,p_flow_status_code =>  p_line_rec.flow_status_code);
     END IF;

/*    IF (p_line_rec.flow_status_code is not null) THEN
      BEGIN
       IF p_line_rec.flow_status_code <> 'AWAITING_SHIPPING' AND
      p_line_rec.flow_status_code <> 'PRODUCTION_COMPLETE' AND
      p_line_rec.flow_status_code <> 'PICKED' AND
      p_line_rec.flow_status_code <> 'PICKED_PARTIAL' AND
      p_line_rec.flow_status_code <> 'PO_RECEIVED'
       THEN
          SELECT meaning
          INTO l_flow_meaning
          FROM fnd_lookup_values lv
          WHERE lookup_type = 'LINE_FLOW_STATUS'
          AND lookup_code = p_line_rec.flow_status_code
          AND LANGUAGE = userenv('LANG')
          AND VIEW_APPLICATION_ID = 660
          AND SECURITY_GROUP_ID =
              fnd_global.Lookup_Security_Group(lv.lookup_type,
                                               lv.view_application_id);

        status is AWAITING_SHIPPING or PRODUCTION_COMPLETE etc.
          get value from shipping table
       ELSE
          l_status := p_line_rec.flow_status_code;

          SELECT sum(decode(released_status, 'Y', 1, 0)), sum(1)
          INTO released_count, total_count
          FROM wsh_delivery_details
          WHERE source_line_id   = p_line_rec.line_id
          AND   source_code      = 'OE'
          AND   released_status  <> 'D';

          IF released_count = total_count THEN
           SELECT meaning
           INTO l_flow_meaning
           FROM fnd_lookup_values lv
           WHERE lookup_type = 'LINE_FLOW_STATUS'
           AND lookup_code = 'PICKED'
           AND LANGUAGE = userenv('LANG')
           AND VIEW_APPLICATION_ID = 660
           AND SECURITY_GROUP_ID =
                fnd_global.Lookup_Security_Group(lv.lookup_type,
                                                 lv.view_application_id);

          ELSIF released_count < total_count and released_count <> 0 THEN
           SELECT meaning
           INTO l_flow_meaning
           FROM fnd_lookup_values lv
           WHERE lookup_type = 'LINE_FLOW_STATUS'
           AND lookup_code = 'PICKED_PARTIAL'
           AND LANGUAGE = userenv('LANG')
           AND VIEW_APPLICATION_ID = 660
           AND SECURITY_GROUP_ID =
                fnd_global.Lookup_Security_Group(lv.lookup_type,
                                                 lv.view_application_id);
          ELSE
           SELECT meaning
           INTO l_flow_meaning
           FROM fnd_lookup_values lv
           WHERE lookup_type = 'LINE_FLOW_STATUS'
           AND lookup_code = l_status
           AND LANGUAGE = userenv('LANG')
           AND VIEW_APPLICATION_ID = 660
           AND SECURITY_GROUP_ID =
                fnd_global.Lookup_Security_Group(lv.lookup_type,
                                                 lv.view_application_id);
          END IF;
       END IF;
       x_line_val_rec.status:= l_flow_meaning;
      END;
     END IF;
*/

   IF NVL(p_line_rec.item_identifier_type, 'INT') = 'INT' THEN
      BEGIN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN OEXFLINB. ITEM IDENTIFIER IS INT' ) ;
         END IF;
         SELECT description
         --,concatenated_segments
         --,concatenated_segments   /*Bug 1766327 chhung*/
         INTO  x_line_val_rec.item_description
          --,x_line_val_rec.ordered_item_dsp
          --,x_line_val_rec.inventory_item /*bug 1766327 chhung*/
         FROM  mtl_system_items_vl
         WHERE inventory_item_id = p_line_rec.inventory_item_id
         AND organization_id = l_organization_id;

         --bug 10047225
         l_valid_kff:= fnd_flex_keyval.validate_ccid(
	               APPL_SHORT_NAME=>'INV',
	               KEY_FLEX_CODE=>'MSTK',
	               STRUCTURE_NUMBER=>101,
	               COMBINATION_ID=>p_line_rec.inventory_item_id,
	               DISPLAYABLE=>'ALL',
	               DATA_SET=>l_organization_id,
	               VRULE=>NULL,
	               SECURITY=>'IGNORE',
	               GET_COLUMNS=>NULL,
	               RESP_APPL_ID=>NULL,
	               RESP_ID=>NULL,
	               USER_ID=>NULL
	             );

	 	if l_valid_kff then
	 		x_line_val_rec.ordered_item_dsp:= fnd_flex_keyval.concatenated_values;
	 		x_line_val_rec.inventory_item:= fnd_flex_keyval.concatenated_values;

	        end if;
         --end of bug 10047225
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'DESCRIPTION: '||X_LINE_VAL_REC.ITEM_DESCRIPTION ) ;
             oe_debug_pub.add(  'ORDERED_ITEM_DSP: '||X_LINE_VAL_REC.ORDERED_ITEM_DSP ) ;
         oe_debug_pub.add(  'INVENTORY_ITEM: '|| X_LINE_VAL_REC.INVENTORY_ITEM ) ;
     END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        Null;
        When too_many_rows then
       Null;
       When others then
       Null;
      END;
    ELSIF NVL(p_line_rec.item_identifier_type, 'INT') = 'CUST' THEN
      BEGIN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'IN OEXFLINB. ITEM IDENTIFIER IS CUST' ) ;
         END IF;
         SELECT nvl(citems.customer_item_desc, sitems.description)
               ,citems.customer_item_number
           --,sitems.concatenated_segments  /*Bug 1766327 chhung*/
         INTO  x_line_val_rec.item_description
          ,x_line_val_rec.ordered_item_dsp
          --,x_line_val_rec.inventory_item /*Bug 1766327 chhung*/
         FROM  mtl_customer_items citems
              ,mtl_customer_item_xrefs cxref
              ,mtl_system_items_vl sitems
          ,mtl_parameters mp  -- bug 3918771
         WHERE citems.customer_item_id = cxref.customer_item_id
           AND cxref.inventory_item_id = sitems.inventory_item_id
           AND sitems.inventory_item_id = p_line_rec.inventory_item_id
           AND sitems.organization_id = l_organization_id
           AND citems.customer_item_id = p_line_rec.ordered_item_id
           AND citems.customer_id = p_line_rec.sold_to_org_id
       AND cxref.master_organization_id = mp.master_organization_id
           AND mp.organization_id = sitems.organization_id ; -- bug 3918771

       --bug 10047225
       l_valid_kff:= fnd_flex_keyval.validate_ccid(
                     APPL_SHORT_NAME=>'INV',
                     KEY_FLEX_CODE=>'MSTK',
                     STRUCTURE_NUMBER=>101,
                     COMBINATION_ID=>p_line_rec.inventory_item_id,
                     DISPLAYABLE=>'ALL',
                     DATA_SET=>l_organization_id,
                     VRULE=>NULL,
                     SECURITY=>'IGNORE',
                     GET_COLUMNS=>NULL,
                     RESP_APPL_ID=>NULL,
                     RESP_ID=>NULL,
                     USER_ID=>NULL
                   );

       	if l_valid_kff then
       		x_line_val_rec.inventory_item := fnd_flex_keyval.concatenated_values;

       end if;
       --end of bug 10047225
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'DESCRIPTION: '||X_LINE_VAL_REC.ITEM_DESCRIPTION ) ;
             oe_debug_pub.add(  'ORDERED_ITEM_DSP: '||X_LINE_VAL_REC.ORDERED_ITEM_DSP ) ;
         oe_debug_pub.add(  'INVENTORY_ITEM: '|| X_LINE_VAL_REC.INVENTORY_ITEM ) ;
     END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          /* Customer Cross Reference relationship changed */
          /* ----------------------------------------------*/
          /* We still need to preserve old value of ordered_item_dsp
             from ordered_item */
          IF p_line_rec.ordered_item IS NOT NULL THEN
             SELECT description
                   ,p_line_rec.ordered_item
                   --,concatenated_segments
             INTO  x_line_val_rec.item_description
                  ,x_line_val_rec.ordered_item_dsp
                  --,x_line_val_rec.inventory_item
              FROM  mtl_system_items_vl
              WHERE inventory_item_id = p_line_rec.inventory_item_id
                AND organization_id = l_organization_id;

           --bug 10047225
           l_valid_kff:= fnd_flex_keyval.validate_ccid(
	                 APPL_SHORT_NAME=>'INV',
	                 KEY_FLEX_CODE=>'MSTK',
	                 STRUCTURE_NUMBER=>101,
	                 COMBINATION_ID=>p_line_rec.inventory_item_id,
	                 DISPLAYABLE=>'ALL',
	                 DATA_SET=>l_organization_id,
	                 VRULE=>NULL,
	                 SECURITY=>'IGNORE',
	                 GET_COLUMNS=>NULL,
	                 RESP_APPL_ID=>NULL,
	                 RESP_ID=>NULL,
	                 USER_ID=>NULL
	               );

	   	if l_valid_kff then
	   		x_line_val_rec.inventory_item := fnd_flex_keyval.concatenated_values;
	        end if;
           --end of bug 10047225

              IF l_debug_level  > 0 THEN
                oe_debug_pub.add('DESCRIPTION: '||X_LINE_VAL_REC.ITEM_DESCRIPTION ) ;
                oe_debug_pub.add('ORDERED_ITEM_DSP: '||X_LINE_VAL_REC.ORDERED_ITEM_DSP ) ;
            oe_debug_pub.add('INVENTORY_ITEM: '|| X_LINE_VAL_REC.INVENTORY_ITEM ) ;
          END IF;
            END IF;
        When too_many_rows then
       Null;
       When others then
       Null;
      END;
    ELSE
      BEGIN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'IN OEXFLINB. ITEM IDENTIFIER IS '||P_LINE_REC.ITEM_IDENTIFIER_TYPE ) ;
           oe_debug_pub.add(  'ORDERED_ITEM_ID: '||P_LINE_REC.ORDERED_ITEM_ID ) ;
       END IF;
       IF p_line_rec.ordered_item_id IS NULL THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'ORDERED_ITEM_ID IS NULL ' ) ;
         oe_debug_pub.add(  'ORDERED_ITEM: '||P_LINE_REC.ORDERED_ITEM ) ;
     END IF;
         SELECT nvl(items.description, sitems.description)
               ,items.cross_reference
           --,sitems.concatenated_segments  /*Bug 1766327 chhung*/
         INTO x_line_val_rec.item_description
         ,x_line_val_rec.ordered_item_dsp
         --,x_line_val_rec.inventory_item /*Bug 1766327 chhung*/
         FROM  mtl_cross_reference_types types
             , mtl_cross_references items
             , mtl_system_items_vl sitems
         WHERE types.cross_reference_type = items.cross_reference_type
           AND items.inventory_item_id = sitems.inventory_item_id
           AND sitems.organization_id = l_organization_id
           AND sitems.inventory_item_id = p_line_rec.inventory_item_id
           AND items.cross_reference_type = p_line_rec.item_identifier_type
           AND items.cross_reference = p_line_rec.ordered_item;

        --bug 10047225
        l_valid_kff:= fnd_flex_keyval.validate_ccid(
	              APPL_SHORT_NAME=>'INV',
	              KEY_FLEX_CODE=>'MSTK',
	              STRUCTURE_NUMBER=>101,
	              COMBINATION_ID=>p_line_rec.inventory_item_id,
	              DISPLAYABLE=>'ALL',
	              DATA_SET=>l_organization_id,
	              VRULE=>NULL,
	              SECURITY=>'IGNORE',
	              GET_COLUMNS=>NULL,
	              RESP_APPL_ID=>NULL,
	              RESP_ID=>NULL,
	              USER_ID=>NULL
	            );

		if l_valid_kff then
			x_line_val_rec.inventory_item := fnd_flex_keyval.concatenated_values;
	        end if;
        --end of bug 10047225
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'DESCRIPTION: '||X_LINE_VAL_REC.ITEM_DESCRIPTION ) ;
            oe_debug_pub.add(  'ORDERED_ITEM_DSP: '||X_LINE_VAL_REC.ORDERED_ITEM_DSP ) ;
        oe_debug_pub.add(  'INVENTORY_ITEM: '|| X_LINE_VAL_REC.INVENTORY_ITEM ) ;
    END IF;
       END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           /* Cross Reference relationship changed */
           /* ----------------------------------------------*/
           /* We still need to preserve old value of ordered_item_dsp
             from ordered_item */
          IF p_line_rec.ordered_item IS NOT NULL THEN
            SELECT description
                  ,p_line_rec.ordered_item
                  --,concatenated_segments
             INTO  x_line_val_rec.item_description
                  ,x_line_val_rec.ordered_item_dsp
                  --,x_line_val_rec.inventory_item
            FROM  mtl_system_items_vl
            WHERE inventory_item_id = p_line_rec.inventory_item_id
              AND organization_id = l_organization_id;

           --bug 10047225
           l_valid_kff:= fnd_flex_keyval.validate_ccid(
	                 APPL_SHORT_NAME=>'INV',
	                 KEY_FLEX_CODE=>'MSTK',
	                 STRUCTURE_NUMBER=>101,
	                 COMBINATION_ID=>p_line_rec.inventory_item_id,
	                 DISPLAYABLE=>'ALL',
	                 DATA_SET=>l_organization_id,
	                 VRULE=>NULL,
	                 SECURITY=>'IGNORE',
	                 GET_COLUMNS=>NULL,
	                 RESP_APPL_ID=>NULL,
	                 RESP_ID=>NULL,
	                 USER_ID=>NULL
	               );

	   	if l_valid_kff then
	   		x_line_val_rec.inventory_item := fnd_flex_keyval.concatenated_values;
	        end if;
           --end of bug 10047225

            IF l_debug_level  > 0 THEN
              oe_debug_pub.add('DESCRIPTION: '||X_LINE_VAL_REC.ITEM_DESCRIPTION ) ;
              oe_debug_pub.add('ORDERED_ITEM_DSP: '||X_LINE_VAL_REC.ORDERED_ITEM_DSP ) ;
              oe_debug_pub.add('INVENTORY_ITEM: '|| X_LINE_VAL_REC.INVENTORY_ITEM ) ;
        END IF;
          END IF;
        When too_many_rows then
       --Null;
    --start bug 3918771
       BEGIN
               SELECT nvl(items.description, sitems.description)
                         ,items.cross_reference
                         --,sitems.concatenated_segments
                   INTO   x_line_val_rec.item_description
                     ,x_line_val_rec.ordered_item_dsp
                     --,x_line_val_rec.inventory_item
                   FROM  mtl_cross_reference_types types
                        ,mtl_cross_references items
                        ,mtl_system_items_vl sitems
          WHERE types.cross_reference_type = items.cross_reference_type
            AND items.inventory_item_id = sitems.inventory_item_id
            AND sitems.organization_id = l_organization_id
            AND sitems.inventory_item_id = p_line_rec.inventory_item_id
            AND items.cross_reference_type = p_line_rec.item_identifier_type
            AND items.cross_reference = p_line_rec.ordered_item
            AND items.org_independent_flag = 'Y' ;

        --bug 10047225
        l_valid_kff:= fnd_flex_keyval.validate_ccid(
	              APPL_SHORT_NAME=>'INV',
	              KEY_FLEX_CODE=>'MSTK',
	              STRUCTURE_NUMBER=>101,
	              COMBINATION_ID=>p_line_rec.inventory_item_id,
	              DISPLAYABLE=>'ALL',
	              DATA_SET=>l_organization_id,
	              VRULE=>NULL,
	              SECURITY=>'IGNORE',
	              GET_COLUMNS=>NULL,
	              RESP_APPL_ID=>NULL,
	              RESP_ID=>NULL,
	              USER_ID=>NULL
	            );

		if l_valid_kff then
			x_line_val_rec.inventory_item := fnd_flex_keyval.concatenated_values;
	        end if;
        --end of bug 10047225
       EXCEPTION
              WHEN No_Data_Found THEN
               BEGIN
                  SELECT nvl(items.description, sitems.description)
                                    ,items.cross_reference
                                    --,sitems.concatenated_segments
                              INTO   x_line_val_rec.item_description
                                ,x_line_val_rec.ordered_item_dsp
                                --,x_line_val_rec.inventory_item
                              FROM  mtl_cross_reference_types types
                                   ,mtl_cross_references items
                                   ,mtl_system_items_vl sitems
                      WHERE types.cross_reference_type = items.cross_reference_type
                    AND items.inventory_item_id = sitems.inventory_item_id
                    AND sitems.organization_id = l_organization_id
                    AND sitems.inventory_item_id = p_line_rec.inventory_item_id
                    AND items.cross_reference_type = p_line_rec.item_identifier_type
                    AND items.cross_reference = p_line_rec.ordered_item
                    AND items.organization_id = l_organization_id ;

               --bug 10047225
               l_valid_kff:= fnd_flex_keyval.validate_ccid(
	                     APPL_SHORT_NAME=>'INV',
	                     KEY_FLEX_CODE=>'MSTK',
	                     STRUCTURE_NUMBER=>101,
	                     COMBINATION_ID=>p_line_rec.inventory_item_id,
	                     DISPLAYABLE=>'ALL',
	                     DATA_SET=>l_organization_id,
	                     VRULE=>NULL,
	                     SECURITY=>'IGNORE',
	                     GET_COLUMNS=>NULL,
	                     RESP_APPL_ID=>NULL,
	                     RESP_ID=>NULL,
	                     USER_ID=>NULL
	                   );

	       	if l_valid_kff then
	       		x_line_val_rec.inventory_item := fnd_flex_keyval.concatenated_values;
	        end if;
               --end of bug 10047225
               EXCEPTION
                WHEN No_Data_Found THEN
                       IF p_line_rec.ordered_item IS NOT NULL THEN
                      SELECT description
                     ,p_line_rec.ordered_item
                     --,concatenated_segments
                      INTO  x_line_val_rec.item_description
                     ,x_line_val_rec.ordered_item_dsp
                     --,x_line_val_rec.inventory_item
                      FROM  mtl_system_items_vl
                                      WHERE inventory_item_id = p_line_rec.inventory_item_id
                                        AND organization_id = l_organization_id;
                      --bug 10047225
                      l_valid_kff:= fnd_flex_keyval.validate_ccid(
		      			APPL_SHORT_NAME=>'INV',
		      			KEY_FLEX_CODE=>'MSTK',
		      			STRUCTURE_NUMBER=>101,
		      			COMBINATION_ID=>p_line_rec.inventory_item_id,
		      			DISPLAYABLE=>'ALL',
		      			DATA_SET=>l_organization_id,
		      			VRULE=>NULL,
		      			SECURITY=>'IGNORE',
		      			GET_COLUMNS=>NULL,
		      			RESP_APPL_ID=>NULL,
		      			RESP_ID=>NULL,
		      			USER_ID=>NULL
		      			);

		      			if l_valid_kff then
		      				x_line_val_rec.inventory_item := fnd_flex_keyval.concatenated_values;
			                end if;
                      --end of bug 10047225
                       END IF ;
                       When Others then
                                    Null ;
               END ;  -- end innermost exception block
       END ;
          -- end bug 3918771
    When others then
       Null;
      END;  -- end outermost exception block
    END IF;

   /*IF (p_line_rec.tax_code IS NOT NULL) THEN
       BEGIN
           x_line_val_rec.tax_group := OE_Id_To_Value.tax_group(
                             p_tax_code => p_line_rec.tax_code);
       EXCEPTION
         WHEN OTHERS THEN
             NULL;
       END;
   END IF; */

   IF (p_line_rec.ship_to_org_id IS NOT NULL) THEN
       BEGIN
         /*OE_Id_To_Value.Ship_To_Customer_Name
          (
           p_ship_to_org_id => p_line_rec.ship_to_org_id,
           x_ship_to_customer_name=>x_line_val_rec.ship_to_customer_name
           );*/

         get_customer_details(
           p_site_use_id => p_line_rec.ship_to_org_id,
           p_site_use_code => 'SHIP_TO',
           x_customer_id => x_line_val_rec.ship_To_customer_id,
           x_customer_name => x_line_val_rec.ship_To_customer_name,
           x_customer_number => x_line_val_rec.ship_To_customer_number
                                 );

       EXCEPTION
         WHEN OTHERS THEN
             NULL;
       END;

   END IF;
IF (p_line_rec.end_customer_site_use_id IS NOT NULL) THEN
         OE_ID_TO_VALUE.END_CUSTOMER_SITE_USE
           (  p_end_customer_site_use_id       => p_line_rec.end_customer_site_use_id,
          x_end_customer_address1 => x_line_val_rec.END_CUSTOMER_SITE_ADDRESS1,
          x_end_customer_address2 => x_line_val_rec.END_CUSTOMER_SITE_ADDRESS2,
          x_end_customer_address3 => x_line_val_rec.END_CUSTOMER_SITE_ADDRESS3,
          x_end_customer_address4 => x_line_val_rec.END_CUSTOMER_SITE_ADDRESS4,
          x_end_customer_location     => x_line_val_rec.END_CUSTOMER_SITE_LOCATION,
          x_end_customer_city => x_line_val_rec.END_CUSTOMER_SITE_CITY,
          x_end_customer_state => x_line_val_rec.END_CUSTOMER_SITE_STATE,
          x_end_customer_postal_code => x_line_val_rec.END_CUSTOMER_SITE_POSTAL_CODE,
          x_end_customer_country => x_line_val_rec.END_CUSTOMER_SITE_COUNTRY
           );

 END IF;

  IF (p_line_rec.end_customer_id IS NOT NULL) THEN
        OE_ID_TO_VALUE.END_CUSTOMER
           (  p_end_customer_id       => p_line_rec.end_customer_id,
          x_end_customer_name => x_line_val_rec.END_CUSTOMER_NAME,
          x_end_customer_number => x_line_val_rec.END_CUSTOMER_NUMBER
          );
  END IF;

  IF (p_line_rec.end_customer_contact_id IS NOT NULL) THEN
        x_line_val_rec.END_CUSTOMER_CONTACT :=  OE_ID_TO_VALUE.END_CUSTOMER_CONTACT
                               (  p_end_customer_contact_id       => p_line_rec.end_customer_contact_id);
  END IF;


   IF (p_line_rec.invoice_to_org_id IS NOT NULL) THEN
       BEGIN
         /*OE_Id_To_Value.Invoice_To_Customer_Name
          (
           p_invoice_to_org_id => p_line_rec.invoice_to_org_id,
           x_invoice_to_customer_name=>x_line_val_rec.invoice_to_customer_name
           ); */

         get_customer_details(
             p_site_use_id => p_line_rec.invoice_to_org_id,
             p_site_use_code =>'BILL_TO',
         x_customer_id =>x_line_val_rec.invoice_To_customer_id,
         x_customer_name =>x_line_val_rec.invoice_To_customer_name,
         x_customer_number => x_line_val_rec.invoice_To_customer_number
               );


       EXCEPTION
         WHEN OTHERS THEN
             NULL;
       END;

   END IF;

   IF p_line_rec.shipping_method_code IS NOT NULL THEN
     BEGIN
         Select meaning
         INTO x_line_val_rec.shipping_method
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
   END IF;
  --3557382
   IF p_line_rec.service_reference_type_code IS NOT NULL THEN
     BEGIN
         Select meaning
         INTO x_line_val_rec.service_reference_type
         FROM   oe_lookups
         WHERE  lookup_code=p_line_rec.service_Reference_type_code
                and lookup_type = 'SERVICE_REFERENCE_TYPE_CODE';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        Null;
        When too_many_rows then
       Null;
       When others then
       Null;
      END;
   END IF;
   --3557382
 --3605052
   IF p_line_rec.service_period IS NOT NULL THEN
     BEGIN
         Select description
         INTO x_line_val_rec.service_period_dsp
         FROM mtl_item_uoms_view
         WHERE uom_code  =p_line_rec.service_period
                and inventory_item_id = p_line_rec.inventory_item_id
            and organization_id = l_organization_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        Null;
        When too_many_rows then
       Null;
       When others then
       Null;
      END;
   END IF;
   --3605052
   IF p_line_rec.freight_carrier_code IS NOT NULL THEN
     BEGIN
         Select description
         INTO x_line_val_rec.freight_carrier
         FROM   org_freight
         WHERE  freight_code=p_line_rec.freight_carrier_code
        and organization_id = p_line_rec.ship_from_org_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        Null;
        When too_many_rows then
       Null;
       When others then
       Null;
      END;
   END IF;

   IF (p_line_rec.source_type_code is not null) THEN
     BEGIN
      select meaning
      into x_line_val_rec.source_type
      from oe_lookups
      where lookup_code=p_line_rec.source_type_code
     AND   lookup_type='SOURCE_TYPE';

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
      When others then
      Null;
     END;
   END IF;

   IF (p_line_rec.demand_class_code is not null) THEN
     BEGIN
      select meaning
      into x_line_val_rec.demand_class
      from oe_fnd_common_lookups_v
      where lookup_code=p_line_rec.demand_class_code
     and lookup_type='DEMAND_CLASS';

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
      When others then
      Null;
     END;
   END IF;



   --   added by jmore

   IF (p_line_rec.intermed_ship_to_org_id is not null) THEN
     BEGIN
      select location,cust_acct_site_id
      into x_line_val_rec.intmed_ship_to,
         l_address_id
      from hz_cust_site_uses_all
      where site_use_id=p_line_rec.intermed_ship_to_org_id;
     x_line_val_rec.intmed_ship_to_location := x_line_val_rec.intmed_ship_to;
/*1621182*/
     select loc.address1,loc.address2,loc.address3,loc.address4,
            DECODE(loc.city, NULL, NULL,loc.city || ', ') ||
            DECODE(loc.state, NULL, loc.province || ', ', loc.state || ', ') || -- 3603600
           DECODE(loc.postal_code, NULL, NULL,loc.postal_code || ', ') ||
           DECODE(loc.country, NULL, NULL,loc.country)
      into x_line_val_rec.intmed_ship_to_address1,
           x_line_val_rec.intmed_ship_to_address2,
           x_line_val_rec.intmed_ship_to_address3,
           x_line_val_rec.intmed_ship_to_address4,
           x_line_val_rec.intmed_ship_to_address5
       from hz_locations loc,
            hz_party_sites ps,
            hz_cust_acct_sites cas
      where cas.cust_acct_site_id = l_address_id
          and   cas.party_site_id = ps.party_site_id
          and   ps.location_id = loc.location_id;

/*1621182*/
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
      When others then
      Null;
     END;
   END IF;


   IF (p_line_rec.intermed_ship_to_contact_id is not null) THEN
     BEGIN
      select name
      into x_line_val_rec.intmed_ship_to_contact
      from oe_contacts_v
      where contact_id=p_line_rec.intermed_ship_to_contact_id;


     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
      When others then
      Null;
     END;
   END IF;


   IF (p_line_rec.deliver_to_org_id is not null) THEN
     BEGIN
      SELECT  /* MOAC_SQL_CHANGE */
       cust_acct.cust_account_id,
       party.party_name,
       cust_acct.account_number,
       cust_site.location,
       location.address1,
       location.address2,
       location.address3,
       location.address4,
       DECODE(location.city, NULL, NULL,location.city || ', ')
       || DECODE(location.state, NULL, location.province || ', ', location.state || ', ') --3603600
       || DECODE(location.postal_code, NULL, NULL,location.postal_code || ', ')
       || DECODE(location.country, NULL, NULL,location.country)
        INTO
       x_line_val_rec.deliver_to_customer_id,
       x_line_val_rec.deliver_to_customer_name,
       x_line_val_rec.deliver_to_customer_number,
       x_line_val_rec.deliver_to,
       x_line_val_rec.deliver_to_address1,
       x_line_val_rec.deliver_to_address2,
       x_line_val_rec.deliver_to_address3,
       x_line_val_rec.deliver_to_address4,
       x_line_val_rec.deliver_to_address5
        FROM
       hz_cust_site_uses_all cust_site,
       hz_cust_acct_sites_all cust_acct_site,
       hz_party_sites party_site,
       hz_parties party,
       hz_cust_accounts cust_acct,
       hz_locations location
       WHERE
       cust_site.site_use_id=p_line_rec.deliver_to_org_id
         and cust_site.site_use_code = 'DELIVER_TO'
         and cust_site.cust_acct_site_id = cust_acct_site.cust_acct_site_id
         and cust_acct_site.party_site_id = party_site.party_site_id
         and party_site.party_id = party.party_id
         and cust_acct.cust_account_id = cust_acct_site.cust_account_id
         and party_site.location_id = location.location_id;

    x_line_val_rec.deliver_to_location := x_line_val_rec.deliver_to;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
      When others then
      Null;
     END;
   END IF;


   IF (p_line_rec.deliver_to_contact_id is not null) THEN
     BEGIN
      select name
      into x_line_val_rec.deliver_to_contact
      from oe_contacts_v
      where contact_id=p_line_rec.deliver_to_contact_id;


     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
      When others then
      Null;
     END;
   END IF;

-- Concatenated Revision with name for Bug-2249065
   IF (p_line_rec.agreement_id is not null) THEN
     BEGIN
      select name||' : '||revision
      into x_line_val_rec.agreement
      from oe_agreements
      where agreement_id=p_line_rec.agreement_id;


     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
      When others then
      Null;
     END;
   END IF;


   IF (p_line_rec.source_document_type_id is not null) THEN
     BEGIN
      select name
      into x_line_val_rec.source_document_type
      from oe_order_sources
      where order_source_id=p_line_rec.source_document_type_id;


     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
      When others then
      Null;
     END;
   END IF;


   IF (p_line_rec.arrival_set_id is not null) THEN
     BEGIN
      select set_name
      into x_line_val_rec.arrival_set
      from oe_sets
      where set_id=p_line_rec.arrival_set_id;


     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
      When others then
      Null;
     END;
   END IF;



   IF (p_line_rec.ship_set_id is not null) THEN
     BEGIN
      select set_name
      into x_line_val_rec.ship_set
      from oe_sets
      where set_id=p_line_rec.ship_set_id;


     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
      When others then
      Null;
     END;
   END IF;


   IF (p_line_rec.commitment_id is not null) THEN
     BEGIN
      select trx_number
      into x_line_val_rec.commitment
      from ra_customer_trx
      where customer_trx_id=p_line_rec.commitment_id;


     EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
      When others then
      Null;
     END;
   END IF;

   -- lkxu, commitment
   IF (p_line_rec.payment_level_code is not null) THEN
     BEGIN
      -- lkxu, commitment enhancement.
     select commitment_applied_amount
         into x_line_val_rec.commitment_applied_amount
     from oe_payments
     where payment_trx_id = p_line_rec.payment_commitment_id
     and   ((line_id = p_line_rec.line_id
            and payment_level_code = 'LINE')
           OR (header_id = p_line_rec.header_id
              and payment_level_code = 'ORDER'));


     EXCEPTION
       WHEN NO_DATA_FOUND THEN
     x_line_val_rec.commitment_applied_amount := 0.0;
       When others then
      Null;
     END;
   END IF;

   IF p_line_rec.header_id IS NOT NULL AND
      p_line_rec.line_id IS NOT NULL THEN
     OE_CHARGE_PVT.Get_Charge_Amount(
                         p_api_version_number=>1.0
                     ,   p_init_msg_list=>'F'
                     ,   p_all_charges=>'F'
                     ,   p_header_id=> p_line_rec.header_id
                     ,   p_line_id=>p_line_rec.line_id
                     ,   x_return_status=>l_return_status
                     ,   x_msg_count=>l_msg_count
                     ,   x_msg_data=>l_msg_data
                     ,   x_charge_amount=>x_line_val_rec.line_charges
                     );
   END IF;

   IF p_line_rec.header_id IS NOT NULL THEN

       IF p_calling_block = 'LINES_SUMMARY' THEN  --FP 3351788

         IF g_current_header_id <> p_line_rec.header_id THEN

        OE_OE_TOTALS_SUMMARY.Order_Totals
                              (
                              p_header_id=>p_line_rec.header_id ,
                              p_subtotal =>x_line_val_rec.subtotal,
                              p_discount =>x_line_val_rec.discount,
                              p_charges  =>x_line_val_rec.charges,
                              p_tax      =>x_line_val_rec.tax
                              );

           --MRG BGN
            IF OE_FEATURES_PVT.IS_MARGIN_AVAIL THEN
               OE_MARGIN_PVT.Get_Order_Margin(p_header_id=>p_line_rec.header_id,
                                   p_org_id => p_line_rec.org_id,
                                   x_order_margin_percent=>l_order_margin_percent,
                                   x_order_margin_amount=>l_order_margin_amount);

               x_line_val_rec.margin := l_order_margin_amount;
               x_line_val_rec.margin_percent := l_order_margin_percent;
            END IF;

            --MRG END
         END IF;
 	    -- for 5331980 start*
     ELSIF p_calling_block = 'LINE' THEN

           IF  OE_GLOBALS.G_CALCULATE_LINE_TOTAL THEN

               OE_OE_TOTALS_SUMMARY.Order_Totals
                                  (
                                  p_header_id=>p_line_rec.header_id ,
                                  p_subtotal =>x_line_val_rec.subtotal,
                                  p_discount =>x_line_val_rec.discount,
                                  p_charges  =>x_line_val_rec.charges,
                                  p_tax      =>x_line_val_rec.tax
                                  );

               OE_GLOBALS.G_CALCULATE_LINE_TOTAL := FALSE;

               g_subtotal := x_line_val_rec.subtotal;
               g_discount := x_line_val_rec.discount;
               g_charges  := x_line_val_rec.charges;
               g_total_tax := x_line_val_rec.tax;

            ELSE

                x_line_val_rec.subtotal := g_subtotal;
                x_line_val_rec.discount := g_discount;
                x_line_val_rec.charges  := g_charges;
                x_line_val_rec.tax := g_total_tax;

            END IF;

            IF  OE_FEATURES_PVT.IS_MARGIN_AVAIL THEN
                OE_MARGIN_PVT.Get_Order_Margin(p_header_id=>p_line_rec.header_id,
                                   x_order_margin_percent=>l_order_margin_percent,
                                   x_order_margin_amount=>l_order_margin_amount);

                x_line_val_rec.margin := l_order_margin_amount;
                x_line_val_rec.margin_percent := l_order_margin_percent;
            END IF;
	    -- for 5331980 end*
    ELSE


             OE_OE_TOTALS_SUMMARY.Order_Totals
                                  (
                                  p_header_id=>p_line_rec.header_id ,
                                  p_subtotal =>x_line_val_rec.subtotal,
                                  p_discount =>x_line_val_rec.discount,
                                  p_charges  =>x_line_val_rec.charges,
                                  p_tax      =>x_line_val_rec.tax
                                  );

   --MRG BGN
    IF OE_FEATURES_PVT.IS_MARGIN_AVAIL THEN
      OE_MARGIN_PVT.Get_Order_Margin(p_header_id=>p_line_rec.header_id,
                                   p_org_id => p_line_rec.org_id,
                                   x_order_margin_percent=>l_order_margin_percent,
                                   x_order_margin_amount=>l_order_margin_amount);

      x_line_val_rec.margin := l_order_margin_amount;
      x_line_val_rec.margin_percent := l_order_margin_percent;
    END IF;
   --MRG END
  END IF;
   END IF;

   IF   p_line_rec.order_quantity_uom IS NOT NULL AND
        p_line_rec.order_quantity_uom='ENR' THEN
    BEGIN
     select tdb.booking_id, bst.name
     into   x_line_val_rec.booking_id,x_line_val_rec.ota_name
     from  ota_delegate_bookings tdb,
           ota_booking_status_types bst
     where tdb.line_id = p_line_rec.line_id
     and    bst.booking_status_type_id = tdb.booking_status_type_id;
    EXCEPTION
     When No_Data_Found THEN
      Null;
     When TOO_MANY_ROWS THEN
      Null;
     When Others THEN
      Null;
    END;
   END IF;

   g_current_header_id := p_line_rec.header_id;

    IF p_line_rec.schedule_status_code is not null THEN

        l_sales_order_id :=
           OE_ORDER_SCH_UTIL.Get_mtl_sales_order_id(p_line_rec.header_id);
        -- INVCONV - SAO MERGED CALLS    FOR OE_LINE_UTIL.Get_Reserved_Quantity and OE_LINE_UTIL.Get_Reserved_Quantity2

             OE_LINE_UTIL.Get_Reserved_Quantities(p_header_id => l_sales_order_id
                                              ,p_line_id   => p_line_rec.line_id
                                              ,p_org_id    => p_line_rec.ship_from_org_id
                                              ,x_reserved_quantity =>  x_line_val_rec.reserved_quantity
                                              ,x_reserved_quantity2 => x_line_val_rec.reserved_quantity2
                                                                                            );

        /*x_line_val_rec.reserved_quantity :=
              OE_LINE_UTIL.Get_Reserved_Quantity
                                (p_header_id => l_sales_order_id
                                ,p_line_id   => p_line_rec.line_id
                               , p_org_id => p_line_rec.ship_from_org_id);
        x_line_val_rec.reserved_quantity2 :=
              OE_LINE_UTIL.Get_Reserved_Quantity2  -- INVCONV
                                (p_header_id => l_sales_order_id
                                ,p_line_id   => p_line_rec.line_id
                               , p_org_id => p_line_rec.ship_from_org_id); */


    END IF;

    IF p_line_rec.line_id IS NOT NULL THEN

     x_line_val_rec.fulfillment_list :=
        oe_set_util.get_fulfillment_list(p_line_id => p_line_rec.line_id);
    END IF;

   IF p_line_rec.calculate_price_flag IS NOT NULL THEN
    BEGIN
        SELECT  MEANING
        INTO    x_line_val_rec.calculate_price_descr
        FROM    OE_LOOKUPS
        WHERE   LOOKUP_CODE = p_line_rec.calculate_price_flag
        AND     LOOKUP_TYPE = 'CALCULATE_PRICE_FLAG';
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
       Null;
       When too_many_rows then
       Null;
       When others then
       Null;
    END;
   END IF;

   IF p_line_rec.svc_ref_order_number IS NOT NULL
   AND p_line_rec.svc_ref_order_type IS NOT NULL  THEN
    BEGIN
     select /* MOAC_SQL_CHANGE */ header_id  into x_line_val_rec.svc_header_id
     from oe_order_headers_all oh,oe_order_types_v ot
     where order_number=p_line_rec.svc_ref_order_number
     and oh.order_type_id=ot.order_type_id
     and ot.name=p_line_rec.svc_ref_order_type;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
      Null;
     WHEN TOO_MANY_ROWS THEN
      Null;
     WHEN OTHERS THEN
      Null;
    END;
   END IF;

   IF p_line_rec.order_source_id IS NOT NULL AND
     p_line_rec.source_document_type_id IS NULL THEN
  -- Order Import
    Begin
    Select name into x_line_val_rec.order_source
    from oe_order_sources
    where order_source_id=p_line_rec.order_source_id;
    Exception
    when no_data_found then
    null;
     when too_many_rows then
    null;
    when others then
     null;
    END;
   ELSIF p_line_rec.source_document_type_id=2 AND
-- The following is commented for bug#1939079
--  p_line_rec.order_source_id IS NULL AND
    p_line_rec.source_document_id IS NOT NULL THEN
-- Copy Orders
    Begin
    Select name into x_line_val_rec.order_source
    from oe_order_sources
    where order_source_id=2;

    Select order_number into x_line_val_rec.order_source_ref
    from oe_order_headers
    where header_id=p_line_rec.source_document_id;

    Select line_number into x_line_val_rec.order_source_line_ref
    from oe_order_lines
    where line_id=p_line_rec.source_document_line_id;
    Exception
    when no_data_found then
    null;
     when too_many_rows then
    null;
    when others then
     null;
    END;

   ELSIF p_line_rec.source_document_type_id=10 AND
    p_line_rec.order_source_id=10  THEN
-- Internal Orders
    Begin
    Select name into x_line_val_rec.order_source
    from oe_order_sources
    where order_source_id=10;

    Exception
    when no_data_found then
    null;
     when too_many_rows then
    null;
    when others then
     null;
    END;
   ELSIF p_line_rec.source_document_type_id IS NOT NULL
        AND p_line_rec.source_document_type_id<>2 THEN

    Begin
    Select name into x_line_val_rec.order_source
    from oe_order_sources
    where order_source_id=p_line_rec.source_document_type_id;

    Exception
    when no_data_found then
    null;
     when too_many_rows then
    null;
    when others then
    null;

    END;
   ELSE
    Null;
   END IF;

   IF p_line_rec.Original_inventory_item_id IS NOT NULL
   OR  p_line_rec.original_ordered_item_id  IS NOT NULL THEN
    OE_ID_TO_VALUE.Ordered_Item
    (p_Item_Identifier_type    => p_line_rec.original_item_identifier_Type
    ,p_inventory_item_id       => p_line_rec.original_Inventory_Item_Id
    ,p_organization_id         => l_organization_id
    ,p_ordered_item_id         => p_line_rec.original_ordered_item_id
    ,p_sold_to_org_id          => p_line_rec.sold_to_org_id
    ,p_ordered_item            => p_line_rec.original_ordered_item
    ,x_ordered_item            => x_line_val_rec.original_ordered_item
    ,x_inventory_item          => x_line_val_rec.original_inventory_item);
   END IF;

   IF p_line_rec.Original_item_identifier_Type IS NOT NULL THEN
    OE_ID_TO_VALUE.item_identifier
         (p_Item_Identifier_type   => p_line_rec.Original_item_identifier_Type
         ,x_Item_Identifier        => x_line_val_rec.Original_item_type);
   END IF;

   IF p_line_rec.item_relationship_type IS NOT NULL THEN
    OE_ID_TO_VALUE.item_relationship_type
         (p_Item_relationship_type     => p_line_rec.item_relationship_type
         ,x_Item_relationship_type_dsp => x_line_val_rec.item_relationship_type_dsp);
   END IF;
   --Spagadal
   IF p_line_rec.blanket_number is not null then
                oe_blanket_util_misc.get_blanketAgrName
                              (p_blanket_number   => p_line_rec.blanket_number,
                               x_blanket_agr_name => x_line_val_rec.blanket_agreement_name);
   END If;
--{ recurring charges
 /* IF p_line_rec.charge_periodicity_code IS NOT NULL AND
     p_line_rec.charge_periodicity_code <> FND_API.G_MISS_CHAR AND
     OE_SYS_PARAMETERS.Value('RECURRING_CHARGES',p_line_rec.org_id) = 'Y' THEN

     SELECT unit_of_measure
     INTO   l_charge_periodicity
     FROM   MTL_UNITS_OF_MEASURE_VL
     WHERE  uom_code = p_line_rec.charge_periodicity_code;
     --AND  uom_class = FND_PROFILE.Value('ONT_UOM_CLASS_CHARGE_PERIODICITY');

     x_line_val_rec.charge_periodicity := l_charge_periodicity;

     IF l_debug_level > 0 THEN
    OE_DEBUG_PUB.Add ('PCode:'||p_line_rec.charge_periodicity_code,5);
        OE_DEBUG_PUB.Add ('Populate value for Charge Periodicity',5);
    OE_DEBUG_PUB.Add ('Periodicity='||l_charge_periodicity,3);
     END IF;
  END IF;
 */
-- recurring charges }

--retro{

/* Sql statements to get the vaues of Retrobilled price for original lines
and Retrobilled order and Retrobilled line information for retrobill lines.    */

  IF(OE_CODE_CONTROL.Code_Release_Level >= 110510) THEN
   IF (p_line_rec.line_id IS NOT NULL AND oe_sys_parameters.value('ENABLE_RETROBILLING',p_line_rec.org_id) = 'Y') THEN
        BEGIN
           SELECT sum(decode(line_category_code,'RETURN',-1*nvl(unit_selling_price,0),nvl(unit_selling_price,0)))
       INTO  l_retrobilled_price_diff
       FROM oe_order_lines
       WHERE  order_source_id=27 AND
              orig_sys_document_ref=to_char(p_line_rec.header_id) AND
              orig_sys_line_ref = to_char(p_line_rec.line_id) AND
                    retrobill_request_id IS NOT NULL;

           SELECT unit_selling_price
           INTO l_unit_selling_price
           FROM oe_order_lines_all
           WHERE line_id=p_line_rec.line_id;

       IF(l_retrobilled_price_diff IS NOT NULL AND l_unit_selling_price IS NOT NULL) THEN
        x_line_val_rec.retrobilled_price := l_unit_selling_price+l_retrobilled_price_diff;
           ELSE
                x_line_val_rec.retrobilled_price := null;
           END IF;
           oe_debug_pub.add( 'RETROBILLED_PRICE: '||x_line_val_rec.retrobilled_price) ;

       IF(p_line_rec.order_source_id=27) THEN
           SELECT orig_head.order_number,
                  orig_lin.line_number,
                  orig_lin.shipment_number,
                  orig_lin.option_number,
                  orig_lin.component_number,
                  orig_lin.service_number
           INTO x_line_val_rec.Retro_Order_Number,
                x_line_val_rec.Retro_Line_Number,
                x_line_val_rec.Retro_Shipment_Number,
                x_line_val_rec.Retro_Option_Number,
                x_line_val_rec.Retro_Component_Number,
                x_line_val_rec.Retro_Service_Number
       FROM oe_order_headers_all orig_head,
                oe_order_lines_all orig_lin
       WHERE line_id =
       (
            SELECT orig_sys_line_ref
            FROM oe_order_lines_all
            WHERE line_id=p_line_rec.line_id
            and order_source_id=27) AND
              orig_head.header_id=orig_lin.header_id;
       END IF;


        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                oe_debug_pub.add( 'IN EXCEPTION: ' ||SQLERRM);
            WHEN OTHERS THEN
                oe_debug_pub.add( 'IN EXCEPTION: ' ||SQLERRM);
        END;
   END IF;
 END IF;
--retro}
--Macd
    IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'MACD configuration_id'||p_line_rec.configuration_id);
             oe_debug_pub.add(  'MACD config_rev_nbr'||p_line_rec.config_rev_nbr);
             oe_debug_pub.add(  'MACD config_header_id'||p_line_rec.config_header_id);
    END IF;
   IF  p_line_rec.configuration_id IS NOT NULL THEN
 BEGIN
  select cz.name
      into x_line_val_rec.instance_name
  from cz_config_details_v cz
  where  cz.config_hdr_id  = p_line_rec.config_header_id
  and    cz.config_rev_nbr = p_line_rec.config_rev_nbr
  and    cz.config_item_id = p_line_rec.configuration_id;
    IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'MACD instance name'||x_line_val_rec.instance_name);
    END IF;

 EXCEPTION

  WHEN NO_DATA_FOUND THEN
    null;
  WHEN TOO_MANY_ROWS THEN
    null;
  WHEN OTHERS THEN
    null;

  END;

 END IF;

  IF  p_line_rec.ib_owner  IS NOT NULL THEN

        BEGIN
           select meaning into x_line_val_rec.ib_owner_dsp
               from oe_lookups
              where
              ( lookup_type='ITEM_OWNER' OR lookup_type='ONT_INSTALL_BASE') and lookup_code=p_line_rec.ib_owner;
        EXCEPTION

         WHEN NO_DATA_FOUND THEN
            null;
         WHEN TOO_MANY_ROWS THEN
            null;
         WHEN OTHERS THEN
            null;
        END;
  END IF;

  IF  p_line_rec.ib_current_location  IS NOT NULL THEN

        BEGIN
           select meaning into x_line_val_rec.ib_current_location_dsp
               from oe_lookups
              where
              ( lookup_type='ITEM_CURRENT_LOCATION' OR lookup_type='ONT_INSTALL_BASE')and lookup_code=p_line_rec.ib_current_location;
        EXCEPTION

         WHEN NO_DATA_FOUND THEN
            null;
         WHEN TOO_MANY_ROWS THEN
            null;
         WHEN OTHERS THEN
            null;
        END;
   END IF;

  IF  p_line_rec.ib_installed_at_location  IS NOT NULL THEN

        BEGIN
           select meaning into x_line_val_rec.ib_installed_at_location_dsp
               from oe_lookups
              where
               (lookup_type='ITEM_INSTALL_LOCATION' OR lookup_type='ONT_INSTALL_BASE')and lookup_code=p_line_rec.ib_installed_at_location;
        EXCEPTION

         WHEN NO_DATA_FOUND THEN
            null;
         WHEN TOO_MANY_ROWS THEN
            null;
         WHEN OTHERS THEN
            null;
        END;
 END IF;
--End OF Macd
--Recurring CHarges
-- Check if recurring Charges is Enabled or not

  IF OE_SYS_PARAMETERS.Value('RECURRING_CHARGES',p_line_rec.org_id)='Y' THEN

   BEGIN

     IF  p_line_rec.charge_periodicity_code  IS NOT NULL THEN

           x_line_val_rec.charge_periodicity_dsp:=OE_ID_TO_VALUE.Charge_periodicity(p_line_rec.charge_periodicity_code);

     END IF;

        EXCEPTION

         WHEN NO_DATA_FOUND THEN
            null;
         WHEN TOO_MANY_ROWS THEN
            null;
         WHEN OTHERS THEN
            null;
   END;

  END IF;
  --Customer Acceptance
  IF p_line_rec.contingency_id is not null then
       OE_ID_TO_VALUE.Get_Contingency_Attributes(
                                         p_contingency_id             => p_line_rec.contingency_id
                                       , x_contingency_name           => x_line_val_rec.contingency_name
                                       , x_contingency_description    => x_line_val_rec.contingency_description
                                       , x_expiration_event_attribute => x_line_val_rec.expiration_event_attribute
       );
       x_line_val_rec.revrec_event := OE_ID_TO_VALUE.Revrec_Event(p_line_rec.revrec_event_code);

  END IF;

  IF p_line_rec.accepted_by is not null THEN
       x_line_val_rec.accepted_by_dsp := OE_ID_TO_VALUE.Accepted_By(p_line_rec.accepted_by);
  END IF;


END POPULATE_CONTROL_FIELDS;

-- OPM 02/JUN/00 overloaded proc below

PROCEDURE POPULATE_CONTROL_FIELDS
( p_line_rec                  IN line_rec_type,
x_line_val_rec OUT NOCOPY line_val_rec_type,
   p_calling_block        IN  VARCHAR2,
x_process_controls_rec OUT NOCOPY process_controls_rec_type

) IS


l_item_rec           OE_Order_Cache.Item_Rec_Type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  POPULATE_CONTROL_FIELDS
                     (
                     p_line_rec => p_line_rec,
                     x_line_val_rec => x_line_val_rec,
              p_calling_block => 'LINE'
              );

 l_item_rec :=
          OE_Order_Cache.Load_Item (p_line_rec.inventory_item_id
                                    ,p_line_rec.ship_from_org_id
                                    ,p_line_rec.org_id); -- R12.MOAC

 -- x_process_controls_rec.dualum_ind := l_item_rec.dualum_ind; -- INVCONV
-- x_process_controls_rec.grade_ctl  := l_item_rec.grade_ctl;  -- INVCONV
 x_process_controls_rec.process_warehouse_flag
                                   := l_item_rec.process_warehouse_flag;
x_process_controls_rec.ont_pricing_qty_source := l_item_rec.ont_pricing_qty_source; -- OPM 2046190
x_process_controls_rec.grade_control_flag := l_item_rec.grade_control_flag; -- INCONV
x_process_controls_rec.tracking_quantity_ind := l_item_rec.tracking_quantity_ind; -- INCONV
x_process_controls_rec.secondary_default_ind := l_item_rec.secondary_default_ind; -- INCONV
x_process_controls_rec.lot_divisible_flag := l_item_rec.lot_divisible_flag; -- INCONV
x_process_controls_rec.lot_control_code := l_item_rec.lot_control_code; -- INCONV 4172680

END POPULATE_CONTROL_FIELDS;


FUNCTION Is_Description_Matched
(p_item_identifier_type  IN   VARCHAR2
,p_ordered_item_id       IN   NUMBER
,p_inventory_item_id     IN   NUMBER
,p_ordered_item          IN   VARCHAR2
,p_sold_to_org_id        IN   NUMBER
,p_description           IN   VARCHAR2
,p_org_id                IN   NUMBER DEFAULT NULL
) RETURN VARCHAR2 IS
/*l_organization_id NUMBER := fnd_profile.value('OE_ORGANIZATION_ID');*/
    -- This change is required since we are dropping the profile OE_ORGANIZATION    -- _ID. Change made by Esha.
l_organization_id Number;/*:= OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');*/
l_count   NUMBER := 0;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
--Bug 9684561
   l_organization_id := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID',
                               p_org_id);

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_ITEM_IDENTIFIER_TYPE:'||P_ITEM_IDENTIFIER_TYPE ) ;
       oe_debug_pub.add(  'P_ORDERED_ITEM_ID: '||P_ORDERED_ITEM_ID ) ;
       oe_debug_pub.add(  'P_INVENTORY_ITEM_ID: '||P_INVENTORY_ITEM_ID ) ;
       oe_debug_pub.add(  'P_ORDERED_ITEM: '||P_ORDERED_ITEM ) ;
       oe_debug_pub.add(  'P_SOLD_TO_ORG_ID: '||P_SOLD_TO_ORG_ID ) ;
       oe_debug_pub.add(  'P_DESCRIPTION: '||P_DESCRIPTION ) ;
       oe_debug_pub.add(  'L_ORGANIZATION_ID: '||L_ORGANIZATION_ID ) ;
   END IF;

   IF NVL(p_item_identifier_type, 'INT') = 'INT' THEN
     IF (Instr(p_description, '%') = 0) THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING INT::EXACT MATCH' ) ;
     END IF;
         SELECT count(*)
         INTO  l_count
         FROM  mtl_system_items_vl
         WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = l_organization_id
         AND description = p_description;
     ELSE
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING INT::PARTIAL' ) ;
     END IF;

         SELECT count(*)
         INTO  l_count
         FROM  mtl_system_items_tl t --3751209
         WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = l_organization_id
         AND description like p_description
     AND language= userenv('LANG');
     END IF;

   ELSIF NVL(p_item_identifier_type, 'INT') = 'CUST' THEN
     IF (Instr(p_description, '%') = 0) THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING CUST::EXACT MATCH' ) ;
     END IF;
         SELECT count(*)
         INTO  l_count
         FROM  mtl_customer_items citems
              ,mtl_customer_item_xrefs cxref
              ,mtl_system_items_vl sitems
         WHERE citems.customer_item_id = cxref.customer_item_id
           AND cxref.inventory_item_id = sitems.inventory_item_id
           AND sitems.inventory_item_id = p_inventory_item_id
           AND sitems.organization_id = l_organization_id
           AND citems.customer_item_id = p_ordered_item_id
           AND citems.customer_id = p_sold_to_org_id
           AND nvl(citems.customer_item_desc, sitems.description) = p_description;
     ELSE
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING CUST::PARTIAL' ) ;
     END IF;
         SELECT count(*)
         INTO  l_count
         FROM  mtl_customer_items citems
              ,mtl_customer_item_xrefs cxref
              ,mtl_system_items_vl sitems
         WHERE citems.customer_item_id = cxref.customer_item_id
           AND cxref.inventory_item_id = sitems.inventory_item_id
           AND sitems.inventory_item_id = p_inventory_item_id
           AND sitems.organization_id = l_organization_id
           AND citems.customer_item_id = p_ordered_item_id
           AND citems.customer_id = p_sold_to_org_id
           AND nvl(citems.customer_item_desc, sitems.description) like p_description;
     END IF;
   ELSE
    IF p_ordered_item_id IS NULL THEN
     IF (Instr(p_description, '%') = 0) THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING GENERIC::EXACT MATCH' ) ;
     END IF;
         SELECT count(*)
         INTO  l_count
         FROM  mtl_cross_reference_types types
             , mtl_cross_references items
             , mtl_system_items_vl sitems
         WHERE types.cross_reference_type = items.cross_reference_type
           AND items.inventory_item_id = sitems.inventory_item_id
           AND sitems.inventory_item_id = p_inventory_item_id
           AND sitems.organization_id = l_organization_id
           AND items.cross_reference_type = p_item_identifier_type
           AND items.cross_reference = p_ordered_item
           AND nvl(items.description, sitems.description) = p_description;
     ELSE
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING GENERIC::PARTIAL' ) ;
     END IF;
         SELECT count(*)
         INTO  l_count
         FROM  mtl_cross_reference_types types
             , mtl_cross_references items
             , mtl_system_items_vl sitems
         WHERE types.cross_reference_type = items.cross_reference_type
           AND items.inventory_item_id = sitems.inventory_item_id
           AND sitems.inventory_item_id = p_inventory_item_id
           AND sitems.organization_id = l_organization_id
           AND items.cross_reference_type = p_item_identifier_type
           AND items.cross_reference = p_ordered_item
           AND nvl(items.description, sitems.description) like p_description;
     END IF;
    END IF;
   END IF;

   IF l_count = 0 THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'NO MATCHES' ) ;
     END IF;
      RETURN 'N';
   ELSE
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'THERE ARE MATCHES' ) ;
     END IF;
      RETURN 'Y';
   END IF;

END Is_Description_Matched;

/* 2913927 - 3348159 start */

FUNCTION Is_Internal_Item_Matched
(p_item_identifier_type  IN   VARCHAR2
,p_ordered_item_id       IN   NUMBER
,p_inventory_item_id     IN   NUMBER
,p_ordered_item          IN   VARCHAR2
,p_sold_to_org_id        IN   NUMBER
,p_inventory_item        IN   VARCHAR2
,p_org_id                IN   NUMBER DEFAULT NULL
) RETURN VARCHAR2 IS
l_organization_id Number;/*:= OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');*/
l_count   NUMBER := 0;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
--Bug 9684561
   l_organization_id := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID',
                               p_org_id);

   IF l_debug_level  > 0 THEN

       oe_debug_pub.add(  'P_ITEM_IDENTIFIER_TYPE: '||P_ITEM_IDENTIFIER_TYPE ) ;
       oe_debug_pub.add(  'P_ORDERED_ITEM_ID: '||P_ORDERED_ITEM_ID ) ;
       oe_debug_pub.add(  'P_INVENTORY_ITEM_ID: '||P_INVENTORY_ITEM_ID ) ;
       oe_debug_pub.add(  'P_ORDERED_ITEM: '||P_ORDERED_ITEM ) ;
       oe_debug_pub.add(  'P_SOLD_TO_ORG_ID: '||P_SOLD_TO_ORG_ID ) ;
       oe_debug_pub.add(  'p_inventory_item: '||p_inventory_item ) ;
       oe_debug_pub.add(  'L_ORGANIZATION_ID: '||L_ORGANIZATION_ID ) ;
   END IF;

   IF NVL(p_item_identifier_type, 'INT') = 'INT' THEN
     IF (Instr(p_inventory_item, '%') = 0) THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING INT::EXACT MATCH' ) ;
     END IF;
         SELECT count(*)
         INTO  l_count
         FROM  mtl_system_items_vl
         WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = l_organization_id
         AND concatenated_segments = p_inventory_item;
     ELSE
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING INT::PARTIAL' ) ;
     END IF;
         SELECT count(*)
         INTO  l_count
         FROM  mtl_system_items_vl
         WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = l_organization_id
         AND concatenated_segments like p_inventory_item;
     END IF;

   ELSIF NVL(p_item_identifier_type, 'INT') = 'CUST' THEN
     IF (Instr(p_inventory_item, '%') = 0) THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING CUST::EXACT MATCH' ) ;
     END IF;
         SELECT count(*)
         INTO  l_count
         FROM  mtl_customer_items citems
              ,mtl_customer_item_xrefs cxref
              ,mtl_system_items_vl sitems
         WHERE citems.customer_item_id = cxref.customer_item_id
           AND cxref.inventory_item_id = sitems.inventory_item_id
           AND sitems.inventory_item_id = p_inventory_item_id
           AND sitems.organization_id = l_organization_id
           AND citems.customer_item_id = p_ordered_item_id
           AND citems.customer_id = p_sold_to_org_id
           AND sitems.concatenated_segments  = p_inventory_item;
     ELSE
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING CUST::PARTIAL' ) ;
     END IF;
         SELECT count(*)
         INTO  l_count
         FROM  mtl_customer_items citems
              ,mtl_customer_item_xrefs cxref
              ,mtl_system_items_vl sitems
         WHERE citems.customer_item_id = cxref.customer_item_id
           AND cxref.inventory_item_id = sitems.inventory_item_id
           AND sitems.inventory_item_id = p_inventory_item_id
           AND sitems.organization_id = l_organization_id
           AND citems.customer_item_id = p_ordered_item_id
           AND citems.customer_id = p_sold_to_org_id
           AND sitems.concatenated_segments like p_inventory_item;

     END IF;
   ELSE
    IF p_ordered_item_id IS NULL THEN
     IF (Instr(p_inventory_item, '%') = 0) THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING GENERIC::EXACT MATCH' ) ;
     END IF;
         SELECT count(*)
         INTO  l_count
         FROM  mtl_cross_reference_types types
             , mtl_cross_references items
             , mtl_system_items_vl sitems
         WHERE types.cross_reference_type = items.cross_reference_type
           AND items.inventory_item_id = sitems.inventory_item_id
           AND sitems.inventory_item_id = p_inventory_item_id
           AND sitems.organization_id = l_organization_id
           AND items.cross_reference_type = p_item_identifier_type
           AND items.cross_reference = p_ordered_item
           AND sitems.concatenated_segments = p_inventory_item;
     ELSE
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING GENERIC::PARTIAL' ) ;
     END IF;
         SELECT count(*)
         INTO  l_count
         FROM  mtl_cross_reference_types types
             , mtl_cross_references items
             , mtl_system_items_vl sitems
         WHERE types.cross_reference_type = items.cross_reference_type
           AND items.inventory_item_id = sitems.inventory_item_id
           AND sitems.inventory_item_id = p_inventory_item_id
           AND sitems.organization_id = l_organization_id
           AND items.cross_reference_type = p_item_identifier_type
           AND items.cross_reference = p_ordered_item
           AND sitems.concatenated_segments like p_inventory_item;
     END IF;
    END IF;
   END IF;

   IF l_count = 0 THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'NO MATCHES' ) ;
     END IF;
      RETURN 'N';
   ELSE
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'THERE ARE MATCHES' ) ;
     END IF;
      RETURN 'Y';
   END IF;
END Is_Internal_Item_Matched;

/*  2913927 - 3348159 end */

/*1477598*/
FUNCTION Is_Item_Matched
(p_item_identifier_type  IN   VARCHAR2
,p_ordered_item_id       IN   NUMBER
,p_inventory_item_id     IN   NUMBER
,p_ordered_item          IN   VARCHAR2
,p_sold_to_org_id        IN   NUMBER
,p_item                  IN   VARCHAR2
,p_org_id                IN   NUMBER DEFAULT NULL
) RETURN VARCHAR2 IS
l_organization_id Number;/*= OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');*/
l_count   NUMBER := 0;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
--Bug 9684561
   l_organization_id := OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID',
                               p_org_id);
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'P_ITEM_IDENTIFIER_TYPE: '||P_ITEM_IDENTIFIER_TYPE ) ;
       oe_debug_pub.add(  'P_ORDERED_ITEM_ID: '||P_ORDERED_ITEM_ID ) ;
       oe_debug_pub.add(  'P_INVENTORY_ITEM_ID: '||P_INVENTORY_ITEM_ID ) ;
       oe_debug_pub.add(  'P_ORDERED_ITEM: '||P_ORDERED_ITEM ) ;
       oe_debug_pub.add(  'P_SOLD_TO_ORG_ID: '||P_SOLD_TO_ORG_ID ) ;
       oe_debug_pub.add(  'P_ITEM: '||P_ITEM ) ;
       oe_debug_pub.add(  'L_ORGANIZATION_ID: '||L_ORGANIZATION_ID ) ;
   END IF;

   IF NVL(p_item_identifier_type, 'INT') = 'INT' THEN
     IF (Instr(p_item, '%') = 0) THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING INT::EXACT MATCH' ) ;
     END IF;
         SELECT count(*)
         INTO  l_count
         FROM  mtl_system_items_vl
         WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = l_organization_id
         AND concatenated_segments = p_item;
     ELSE
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING INT::PARTIAL' ) ;
     END IF;
         SELECT count(*)
         INTO  l_count
         FROM  mtl_system_items_vl
         WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = l_organization_id
         AND concatenated_segments like p_item;
     END IF;

   ELSIF NVL(p_item_identifier_type, 'INT') = 'CUST' THEN
     IF (Instr(p_item, '%') = 0) THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING CUST::EXACT MATCH' ) ;
     END IF;
         SELECT count(*)
         INTO  l_count
         FROM  mtl_customer_items citems
              ,mtl_customer_item_xrefs cxref
              ,mtl_system_items_vl sitems
         WHERE citems.customer_item_id = cxref.customer_item_id
           AND cxref.inventory_item_id = sitems.inventory_item_id
           AND sitems.inventory_item_id = p_inventory_item_id
           AND sitems.organization_id = l_organization_id
           AND citems.customer_item_id = p_ordered_item_id
           AND citems.customer_id = p_sold_to_org_id
           AND nvl(citems.customer_item_number, sitems.concatenated_segments) =p_item;
     ELSE
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING CUST::PARTIAL' ) ;
     END IF;
         SELECT count(*)
         INTO  l_count
         FROM  mtl_customer_items citems
              ,mtl_customer_item_xrefs cxref
              ,mtl_system_items_vl sitems
         WHERE citems.customer_item_id = cxref.customer_item_id
           AND cxref.inventory_item_id = sitems.inventory_item_id
           AND sitems.inventory_item_id = p_inventory_item_id
           AND sitems.organization_id = l_organization_id
           AND citems.customer_item_id = p_ordered_item_id
           AND citems.customer_id = p_sold_to_org_id
           AND nvl(citems.customer_item_number, sitems.concatenated_segments) like  p_item;
     END IF;
   ELSE
    IF p_ordered_item_id IS NULL THEN
     IF (Instr(p_item, '%') = 0) THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING GENERIC::EXACT MATCH' ) ;
     END IF;
         SELECT count(*)
         INTO  l_count
         FROM  mtl_cross_reference_types types
             , mtl_cross_references items
             , mtl_system_items_vl sitems
         WHERE types.cross_reference_type = items.cross_reference_type
           AND items.inventory_item_id = sitems.inventory_item_id
           AND sitems.inventory_item_id = p_inventory_item_id
           AND sitems.organization_id = l_organization_id
           AND items.cross_reference_type = p_item_identifier_type
           AND items.cross_reference = p_ordered_item
           AND nvl(items.cross_reference, sitems.concatenated_segments) = p_item;
     ELSE
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'ENTERING GENERIC::PARTIAL' ) ;
     END IF;
         SELECT count(*)
         INTO  l_count
         FROM  mtl_cross_reference_types types
             , mtl_cross_references items
             , mtl_system_items_vl sitems
         WHERE types.cross_reference_type = items.cross_reference_type
           AND items.inventory_item_id = sitems.inventory_item_id
           AND sitems.inventory_item_id = p_inventory_item_id
           AND sitems.organization_id = l_organization_id
           AND items.cross_reference_type = p_item_identifier_type
           AND items.cross_reference = p_ordered_item
           AND nvl(items.cross_reference, sitems.concatenated_segments) like p_item;
     END IF;
    END IF;
   END IF;

   IF l_count = 0 THEN
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'NO MATCHES' ) ;
     END IF;
      RETURN 'N';
   ELSE
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'THERE ARE MATCHES' ) ;
     END IF;
      RETURN 'Y';
   END IF;
END Is_Item_Matched;
/*1477598*/

PROCEDURE SPLIT_LINE
(
p_split_by      IN  VARCHAR2 DEFAULT null
,x_line_tbl_type IN  split_line_tbl_type
,p_change_reason_code IN VARCHAR2 DEFAULT NULL
,p_change_comments IN VARCHAR2 DEFAULT NULL
,x_return_status OUT NOCOPY VARCHAR2
,x_msg_count OUT NOCOPY NUMBER
,x_msg_data OUT NOCOPY VARCHAR2
 ) IS

 i                             NUMBER;
 l_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
 l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
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
 l_return_status               VARCHAR2(1);
 l_line_id                     NUMBER;
 l_process_add_attributes      Boolean :=FALSE;
 j                             NUMBER;    --   for bug 1988144
 k                             NUMBER;    --   for bug 1988144
 l_rec_count                   NUMBER;    --   for bug 1988144
--serla begin
l_x_Header_Payment_tbl        OE_Order_PUB.Header_Payment_Tbl_Type;
l_x_Line_Payment_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
--serla end
--10278858
l_org_request_date     DATE;
l_org_ship_from_org_id NUMBER;
l_org_ship_to_org_id NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

IF l_debug_level  > 0 THEN
   oe_debug_pub.add(  'LINE CONTROLLER - IN SPLIT ' , 1 ) ;
END IF;

/*  l_control_rec.controlled_operation := TRUE;
  l_control_rec.validate_entity      := TRUE;
  l_control_rec.write_to_DB          := TRUE;

  l_control_rec.default_attributes   := FALSE;
  l_control_rec.change_attributes    := FALSE;
  l_control_rec.process              := FALSE;

  l_control_rec.clear_api_cache      := FALSE;
  l_control_rec.clear_api_requests   := FALSE;   */

--  OE_GLOBALS.G_UI_FLAG := TRUE;  -- FP bug#6968460 (for bug#5727279): reverting the fix done in bug#4751632

IF x_line_tbl_type.count>0 THEN
   for i in  x_line_tbl_type.first .. x_line_tbl_type.last loop

       IF i  =1 THEN
           IF x_line_tbl_type(i).line_id is not null THEN
           l_line_id:=x_line_tbl_type(i).line_id;
	   IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'LINE CONTROLLER - BEFORE GET LINE'|| X_LINE_TBL_TYPE ( I ) .LINE_ID , 1 ) ;
           END IF;
               --    l_x_line_tbl(i):=OE_ORDER_PUB.G_MISS_LINE_REC;
               /*       Get_line
               (   p_db_record       => FALSE
                  ,p_line_id         => x_line_tbl_type(i).line_id
                 ,x_line_rec        => l_x_line_tbl(i));  */
               l_x_line_tbl(i).line_id:=x_line_tbl_type(i).line_id;
               OE_Line_Util.Lock_Row
               ( x_return_status         => l_return_status
               , p_x_line_rec            => l_x_line_tbl(i)
               , p_line_id               => x_line_tbl_type(i).line_id);

               IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
               END IF;

               IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'LINE CONTROLLER - AFTER GET LINE ' , 1 ) ;
               END IF;
	       --10278858
	       l_org_request_date  := l_x_line_tbl(i).request_date;
               l_org_ship_from_org_id  := l_x_line_tbl(i).ship_from_org_id;
               l_org_ship_to_org_id  := l_x_line_tbl(i).ship_to_org_id;
           END IF;

       l_x_line_tbl(i).line_id:=x_line_tbl_type(i).line_id;
       l_x_line_tbl(i).split_action_code:='SPLIT';
           --SAO
           IF p_split_by = 'SCHEDULER' THEN
              l_x_line_tbl(i).split_by:='SYSTEM';
           ELSE
              l_x_line_tbl(i).split_by:='USER';
           END IF;
       l_x_line_tbl(i).operation:= OE_GLOBALS.G_OPR_UPDATE;
           IF l_debug_level > 0 THEN
              OE_DEBUG_PUB.add('Audit Trail Reason Code being passed as '||p_change_reason_code,1);
           END IF;
           l_x_line_tbl(i).change_reason := p_change_reason_code;
           l_x_line_tbl(i).change_comments := p_change_comments;
           -- Bug# 4008409
           -- Pass ship_from_org_id for the update line since the Dual UOM control for the item can be different
          -- l_x_line_tbl(i).ship_from_org_id := x_line_tbl_type(i).ship_from_org_id;
      ELSE
          IF l_line_id is not null then
            l_x_line_tbl(i).split_from_line_id:=l_line_id;
          END IF;
	  l_x_line_tbl(i).operation:= OE_GLOBALS.G_OPR_CREATE;
          --SAO
         IF p_split_by = 'SCHEDULER' THEN
           l_x_line_tbl(i).split_by:='SYSTEM';
         ELSE
           l_x_line_tbl(i).split_by := 'USER'; -- for bug 2211261
         END IF;
    END IF;
    l_x_line_tbl(i).ordered_quantity:= x_line_tbl_type(i).ordered_quantity;
    /* OPM - NC 3/8/02 Bug#2046641 */
    l_x_line_tbl(i).ordered_quantity2:= x_line_tbl_type(i).ordered_quantity2;
    --8706868

    IF x_line_tbl_type(i).ship_to_org_id is not null THEN
       IF nvl(l_x_line_tbl(i).ship_to_org_id,-1)<>nvl(x_line_tbl_type(i).ship_to_org_id,-1)  THEN
          l_x_line_tbl(i).ship_to_org_id:=x_line_tbl_type(i).ship_to_org_id;
          --10278858
	  IF l_x_line_tbl(i).ship_to_org_id <> l_org_ship_to_org_id THEN
             l_x_line_tbl(i).SPLIT_SHIP_TO := 'Y';
          END IF;
       END IF;
    END IF;

    IF x_line_tbl_type(i).request_date is not null THEN
       IF nvl(l_x_line_tbl(i).request_date,sysdate)<> nvl(x_line_tbl_type(i).request_date,sysdate)  THEN
          l_x_line_tbl(i).request_date:=x_line_tbl_type(i).request_date;
          --10278858
	  IF l_x_line_tbl(i).request_date <> l_org_request_date THEN
             l_x_line_tbl(i).SPLIT_REQUEST_DATE := 'Y';
          END IF;
       END IF;
    END IF;

    IF x_line_tbl_type(i).ship_from_org_id is not null THEN
       IF nvl(l_x_line_tbl(i).ship_from_org_id,-1)<>nvl(x_line_tbl_type(i).ship_from_org_id,-1)  THEN
          l_x_line_tbl(i).ship_from_org_id:=x_line_tbl_type(i).ship_from_org_id;
          -- ship_from_org_id is changed during split, null OUT subinventory
          l_x_line_tbl(i).subinventory:= null;
          --10278858
	  IF l_x_line_tbl(i).ship_from_org_id <> l_org_ship_from_org_id THEN
             l_x_line_tbl(i).SPLIT_SHIP_FROM := 'Y';
          END IF;
       END IF;
    END IF;
    --8706868
   end loop;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE CONTROLLER - IN SPLIT - CALLING PROCESS' , 1 ) ;
    END IF;

   Oe_Order_Pvt.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                  => l_x_header_rec
    ,   p_x_Header_Adj_tbl              => l_x_Header_Adj_tbl
    ,   p_x_header_price_att_tbl        => l_x_header_price_att_tbl
    ,   p_x_Header_Adj_att_tbl          => l_x_Header_Adj_att_tbl
    ,   p_x_Header_Adj_Assoc_tbl        => l_x_Header_Adj_Assoc_tbl
    ,   p_x_Header_Scredit_tbl          => l_x_Header_Scredit_tbl
--serla begin
    ,   p_x_Header_Payment_tbl          => l_x_Header_Payment_tbl
--serla end
    ,   p_x_line_tbl                    => l_x_line_tbl
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

  END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'LINE CONTROLLER - IN SPLIT - AFTER CALLING PROCESS' , 1 ) ;
    END IF;

   IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;


   IF l_x_line_tbl.count>0 THEN
    l_line_tbl.delete;
    /* -- 8706868: No need to call again. First call has updated this.
     FOR i in  x_line_tbl_type.first .. x_line_tbl_type.last LOOP
        l_line_tbl(i):=OE_ORDER_PUB.G_MISS_LINE_REC;
        IF x_line_tbl_type(i).ship_to_org_id is not null THEN
        IF nvl(l_x_line_tbl(i).ship_to_org_id,-1)<>nvl(x_line_tbl_type(i).ship_to_org_id,-1)  THEN
              l_line_tbl(i).ship_to_org_id:=x_line_tbl_type(i).ship_to_org_id;
              l_process_add_attributes:=TRUE;
            END IF;
        END IF;

        IF x_line_tbl_type(i).request_date is not null THEN
          IF nvl(l_x_line_tbl(i).request_date,sysdate)<> nvl(x_line_tbl_type(i).request_date,sysdate)  THEN
            l_line_tbl(i).request_date:=x_line_tbl_type(i).request_date;
            l_process_add_attributes:=TRUE;
           END IF;
        END IF;

     -- This is to fix a p1 bug on tst115. The second call should not
     -- come as split
      l_line_tbl(i).operation:= OE_GLOBALS.G_OPR_UPDATE;
      IF l_debug_level > 0 THEN
         OE_DEBUG_PUB.add('Reason code being passed : '||l_line_tbl(i).change_reason,1);
         OE_DEBUG_PUB.add('Warehouse: '||x_line_tbl_type(i).ship_from_org_id,1);
      END IF;
      l_line_tbl(i).change_reason := p_change_reason_code;
      l_line_tbl(i).change_comments := p_change_comments;
      l_line_tbl(i).split_action_code:=fnd_api.g_miss_char;
      l_line_tbl(i).line_id:=l_x_line_tbl(i).line_id;
      l_line_tbl(i).header_id:=l_x_line_tbl(i).header_id;

      IF x_line_tbl_type(i).ship_from_org_id is not null THEN
      IF nvl(l_x_line_tbl(i).ship_from_org_id,-1)<>nvl(x_line_tbl_type(i).ship_from_org_id,-1)  THEN
              l_line_tbl(i).ship_from_org_id:=x_line_tbl_type(i).ship_from_org_id;
              -- ship_from_org_id is changed during split, null OUT subinventory
              l_line_tbl(i).subinventory:= null;
              -- Bug# 4008409
              -- pass the ordered_quantity2 which is entered in the split window
              l_line_tbl(i).ordered_quantity2 := x_line_tbl_type(i).ordered_quantity2;
              l_process_add_attributes:=TRUE;
          END IF;
      END IF;

--      l_line_tbl(i):=l_x_line_tbl(i);
     END LOOP;
*/ -- 8706868
/* Extra loop being handled so as to deal with the service lines */
/* for bug 1988144, added by dbuduru */

-- At this point l_line_tbl contains the order line that was split as well as the
-- the order lines that are  created as a result of the split. Prior to this modification
-- only these records were being passed to the Process Order API ( second call ) and there
-- is no code in the Process Order API that would update the service lines if split attributes
-- are modified in the order lines to which they refer to.
--
-- In order to make the Process Order API handle the service lines, the service lines are
-- explicitly being bundled with the order lines in the l_line_tbl. The Following loop
-- takes care of that. The loop is coded taking Models, standard items and kits into consideration
--
-- Local variables j, k, l_rec_count have been added. The variables j, k
-- are  used as a loop indices
-- and l_rec_count is used to work on the l_line_tbl.
--
-- l_line_id would contain the line_id of the line to which the service line is attached
-- to or the top_most_line_id if the line to which its attached to is a part of a Model.
-- This is done because splitting happens at the top most level.

 -- l_rec_count := l_line_tbl.last + 1;
   l_rec_count :=  1; --8706868
  FOR i in  l_x_line_tbl.first .. l_x_line_tbl.last LOOP
    IF l_x_line_tbl(i).item_type_code = 'SERVICE' THEN

      l_line_tbl(l_rec_count) := OE_ORDER_PUB.G_MISS_LINE_REC;

      FOR j in  l_x_line_tbl.first .. l_x_line_tbl.last LOOP
        IF l_x_line_tbl(i).service_reference_line_id = l_x_line_tbl(j).line_id THEN
          l_line_id :=  nvl( l_x_line_tbl(j).top_model_line_id, l_x_line_tbl(j).line_id );
          EXIT;
        END IF; -- service_Ref_line = line_id
      END LOOP;  -- loop on l_x_line_tbl

      FOR k in x_line_tbl_type.first .. x_line_tbl_type.last LOOP
        IF l_line_id = l_x_line_tbl(k).line_id THEN
          IF x_line_tbl_type(k).ship_to_org_id is not null THEN
            IF nvl(l_x_line_tbl(i).ship_to_org_id,-1)<>nvl(x_line_tbl_type(k).ship_to_org_id,-1)  THEN
              l_line_tbl(l_rec_count).ship_to_org_id := x_line_tbl_type(k).ship_to_org_id;
              l_process_add_attributes:=TRUE;
            END IF; -- if ship_to_changed
          END IF; -- ship_to not null

      -- Code added for bug 2216899

      IF x_line_tbl_type(k).ship_from_org_id is not null THEN
            IF nvl(l_x_line_tbl(i).ship_from_org_id,-1)<>nvl(x_line_tbl_type(k).ship_from_org_id,-1)  THEN
          l_line_tbl(l_rec_count).ship_from_org_id := x_line_tbl_type(k).ship_from_org_id;
          l_line_tbl(l_rec_count).subinventory := null;
              l_process_add_attributes:=TRUE;
            END IF; -- if ship_from_changed
          END IF; -- ship_from not null

      -- end 2216899

          IF x_line_tbl_type(k).request_date is not null THEN
            IF nvl(l_x_line_tbl(i).request_date,sysdate)<> nvl(x_line_tbl_type(k).request_date,sysdate) THEN
              l_line_tbl(l_rec_count).request_date := x_line_tbl_type(k).request_date;
              l_process_add_attributes:=TRUE;
            END IF;
          END IF;

          l_line_tbl(l_rec_count).operation := OE_GLOBALS.G_OPR_UPDATE;
          IF l_debug_level > 0 THEN
             OE_DEBUG_PUB.add('Reason code being passed : '||l_line_tbl(l_rec_count).change_reason,1);
             OE_DEBUG_PUB.add('Warehouse :'||l_line_tbl(l_rec_count).ship_from_org_id,1);
          END IF;
          l_line_tbl(l_rec_count).change_reason := p_change_reason_code;
          l_line_tbl(l_rec_count).change_comments := p_change_comments;
          l_line_tbl(l_rec_count).split_action_code := fnd_api.g_miss_char;
          l_line_tbl(l_rec_count).line_id := l_x_line_tbl(i).line_id;
          l_line_tbl(l_rec_count).header_id := l_x_line_tbl(i).header_id;

          l_rec_count := l_rec_count + 1;
          EXIT;
        END IF;  -- if l_line_id matches a line_id in x_line_tbl_type
      END LOOP;  -- loop on index k
    END IF;  -- If item_type_code = 'SERVICE'
  END LOOP; -- First For Loop

/* end of 1988144 */
/* this l_line_tbl is passed to the process Order API */


     l_x_Header_Adj_tbl.delete;
     l_x_header_price_att_tbl.delete;
     l_x_Header_Adj_att_tbl.delete;
     l_x_Header_Adj_Assoc_tbl.delete;
     l_x_Header_Scredit_tbl.delete;
     l_x_Line_Adj_tbl.delete;
     l_x_Line_Price_att_tbl.delete;
     l_x_Line_Adj_att_tbl.delete;
     l_x_Line_Adj_Assoc_tbl.delete;
     l_x_Line_Scredit_tbl.delete;
     l_x_lot_serial_tbl.delete;


     IF  l_process_add_attributes THEN
      Oe_Order_Pvt.Process_order
       (   p_api_version_number          => 1.0
        ,   p_init_msg_list               => FND_API.G_TRUE
        ,   x_return_status               => l_return_status
        ,   x_msg_count                   => x_msg_count
        ,   x_msg_data                    => x_msg_data
        ,   p_control_rec                 => l_control_rec
        ,   p_x_line_tbl                    => l_line_tbl
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


     END IF;

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;

   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.count_and_get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
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

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Split Lines'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.count_and_get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END SPLIT_LINE;

-- This procedure will be called from the client when the user
-- clears a record
Procedure Clear_Record
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
,   p_line_id                     IN  NUMBER
)
IS
l_return_status                     Varchar2(30);
l_count_to_keep			    NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
/* l_new_line_rec     OE_Order_PUB.Line_Rec_Type; --3445778
 l_old_line_rec     OE_Order_PUB.Line_Rec_Type; --3445778
 l_index            NUMBER;  --3445778 */
 l_header_id        NUMBER;
BEGIN
    OE_MSG_PUB.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Bug 3800577
     -- Clear versioning globals if request was not logged. If request was
     -- logged, that indicates that a change on another record had logged the
     -- request and versioning should still fire.

     IF OE_GLOBALS.G_ROLL_VERSION <> 'N' THEN

        l_header_id := g_line_rec.header_id;

        if l_debug_level > 0 then
        oe_debug_pub.add('Roll version global is set');
        oe_debug_pub.add('Header ID: '||l_header_id);
        end if;

        IF NOT OE_Delayed_Requests_Pvt.Check_For_Request
                                (p_entity_code => OE_GLOBALS.G_ENTITY_ALL
                                ,p_entity_id => l_header_id
                                ,p_request_type => OE_GLOBALS.G_VERSION_AUDIT
                                )
        THEN
           oe_debug_pub.add('Request does not exist, reset versioning globals');
           IF (NOT OE_Versioning_Util.Reset_Globals) THEN
               l_return_status := FND_API.G_RET_STS_ERROR;
               RETURN;
           END IF;
        END IF;

     END IF;

    OE_DELAYED_REQUESTS_PVT.Delete_Reqs_for_Deleted_Entity(
                         p_entity_code  => OE_GLOBALS.G_ENTITY_LINE
                         ,p_entity_id    => p_line_id
                         -- Bug 3800577
                         -- Also delete requests logged by this entity
                         ,p_delete_against => FALSE
                         ,x_return_status => l_return_status);

/*    -- Added for bug 3445778 --Commenting the code for 3575018
    oe_debug_pub.add('Executing code for updating global picture, line_id: ' || p_line_id, 1);

    -- Set the operation on the record so that globals are updated
     l_new_line_rec.operation := OE_GLOBALS.G_OPR_DELETE;
     l_new_line_rec.line_id := p_line_id;
     l_old_line_rec.line_id := p_line_id;

      OE_ORDER_UTIL.Update_Global_Picture(p_Upd_New_Rec_If_Exists => True,
                    p_line_rec => l_new_line_rec,
                    p_line_id => p_line_id,
                    p_old_line_rec => l_old_line_rec,
                    x_index => l_index,
                    x_return_status => l_return_status);

    -- End of 3445778 */

    --bug#3947584
   --Calling procedure to remove fulfillment set info for the record

--bug # 6059554--
   --Before calling procedure OE_Set_Util.Remove_From_Fulfilment to remove the fulfillment information,
   --check whether Order line exists in oe_order_lines_all or not.If it does
   --not exists then only Call OE_Set_Util.Remove_From_Fulfilment to remove the fulfillment set information for the
   --line otherwise we will not remove the fulfillment information from line.

    select count(1) into l_count_to_keep
    from oe_order_lines_all
    where line_id=p_line_id;

    if l_count_to_keep = 0 then

         OE_Set_Util.Remove_From_Fulfillment(p_line_id => p_line_id);

    end if;

--Close for bug #6059554--


    OE_MSG_PUB.Count_And_Get
      (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
       );


   -- Clear the controller cache, so that it will not be used for
   -- next operation on same record

    Clear_line;

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

FUNCTION Get_Date_Type
( p_header_id      IN NUMBER)
RETURN VARCHAR2
IS
l_order_date_type_code   VARCHAR2(30) := null;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  SELECT order_date_type_code
  INTO   l_order_date_type_code
  FROM   oe_order_headers
  WHERE  header_id = p_header_id;

  RETURN l_order_date_type_code;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
        RETURN NULL;
  WHEN OTHERS THEN
       RETURN null;
END Get_Date_Type;

PROCEDURE Ship_To_Customer_Id(
                              p_ship_to_org_id IN Number,
x_ship_to_Customer_id OUT NOCOPY Number
                              ) IS
l_site_use_code VARCHAR2(30);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    l_site_use_code := 'SHIP_TO';

           SELECT  /* MOAC_SQL_CHANGE */ cas.cust_account_id
        INTO    x_ship_to_customer_id
        FROM    HZ_CUST_SITE_USES_ALL site,
                HZ_CUST_ACCT_SITES_ALL cas
        WHERE   site.cust_acct_site_id = cas.cust_acct_site_id
        AND     site.site_use_code=l_site_use_code
        AND     site.site_use_id=p_ship_to_org_id;

EXCEPTION

        WHEN NO_DATA_FOUND THEN
         Null;
        When too_many_rows then
         Null;
        When others then
         Null;
END Ship_To_Customer_Id;


PROCEDURE Invoice_To_Customer_Id(
                              p_invoice_to_org_id IN Number,
x_invoice_to_Customer_id OUT NOCOPY Number
                              ) IS

l_site_use_code VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    l_site_use_code := 'BILL_TO';

           SELECT /* MOAC_SQL_CHANGE */  cas.cust_account_id
        INTO    x_invoice_to_customer_id
        FROM    HZ_CUST_SITE_USES_ALL site,
                HZ_CUST_ACCT_SITES_ALL cas
        WHERE   site.cust_acct_site_id = cas.cust_acct_site_id
        AND     site.site_use_code=l_site_use_code
        AND     site.site_use_id=p_invoice_to_org_id;


EXCEPTION

        WHEN NO_DATA_FOUND THEN
         Null;
        When too_many_rows then
         Null;
        When others then
         Null;
END Invoice_To_Customer_Id;

PROCEDURE GET_LINE_SHIPMENT_NUMBER(
x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
                                  ,   p_header_id                     IN  Number
, x_line_id OUT NOCOPY Number
, x_line_number OUT NOCOPY Number
, x_shipment_number OUT NOCOPY Number
                                   )  IS
l_line_number Number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    SELECT  OE_ORDER_LINES_S.NEXTVAL
    INTO    x_line_id
    FROM    DUAL;

    SELECT  NVL(MAX(LINE_NUMBER)+1,1)
    INTO    x_line_number
    FROM    OE_ORDER_LINES_ALL
    WHERE   HEADER_ID = p_header_id;
    l_line_number:=x_line_number;
  IF x_line_number IS NOT NULL THEN
    SELECT  NVL(MAX(SHIPMENT_NUMBER)+1,1)
    INTO    x_shipment_number
    FROM    OE_ORDER_LINES
    WHERE   HEADER_ID = p_header_id
    AND     LINE_NUMBER = l_line_number;
  END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Line_Shipment_Number'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GET_LINE_SHIPMENT_NUMBER;


/*--- Bug 1823073 start----- */
-- This Get_ORDERED_ITEM procedure is called from OEXOELIN.pld
-- Added this procedure to provide ordered_item
-- and fix the problem cauesd by null ordered_item
PROCEDURE GET_ORDERED_ITEM ( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
                                 ,   p_item_identifier_type          IN VARCHAR2
                                 ,   p_inventory_item_id             IN Number
                                 ,   p_ordered_item_id               IN Number
                                 ,   p_sold_to_org_id                IN Number
, x_ordered_item OUT NOCOPY VARCHAR2
                         ) IS

l_organization_id             Number:= OE_Sys_Parameters.VALUE('MASTER_ORGANIZATION_ID');
--bug 10047225
l_valid_kff	boolean;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTER GET_ORDERED_ITEM PROCEDURE' ) ;
       oe_debug_pub.add(  'ITEM_IDENTIFIER_TYPE : '||P_ITEM_IDENTIFIER_TYPE ) ;
       oe_debug_pub.add(  'INVENTORY_ITEM_ID : '||P_INVENTORY_ITEM_ID ) ;
       oe_debug_pub.add(  'ORDERED_ITEM_ID : '||P_ORDERED_ITEM_ID ) ;
       oe_debug_pub.add(  'SOLD_TO_ORG_ID : '||P_SOLD_TO_ORG_ID ) ;
   END IF;

   IF NVL(p_item_identifier_type, 'INT') = 'INT' THEN

      BEGIN
      --bug 10047225
      l_valid_kff := fnd_flex_keyval.validate_ccid(
                    APPL_SHORT_NAME=>'INV',
                    KEY_FLEX_CODE=>'MSTK',
                    STRUCTURE_NUMBER=>101,
                    COMBINATION_ID=>p_inventory_item_id,
                    DISPLAYABLE=>'ALL',
                    DATA_SET=>l_organization_id,
                    VRULE=>NULL,
                    SECURITY=>'IGNORE',
                    GET_COLUMNS=>NULL,
                    RESP_APPL_ID=>NULL,
                    RESP_ID=>NULL,
                    USER_ID=>NULL
                  );

      	if l_valid_kff then
      		oe_debug_pub.add('10047225: Proc GET_ORDERED_ITEM:l_valid_kff: TRUE');
      		x_ordered_item:= fnd_flex_keyval.concatenated_values;

      	end if;
	oe_debug_pub.add('10047225:Proc GET_ORDERED_ITEM: x_ordered_item:'||x_ordered_item);
      --end of bug 10047225
      /* Commented for Bug 10047225
         SELECT  concatenated_segments
         INTO x_ordered_item
         FROM  MTL_SYSTEM_ITEMS_KFV
         WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = l_organization_id;
      */
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           Null;
        When too_many_rows then
       Null;
    When others then
       Null;
      END;
   ELSIF NVL(p_item_identifier_type, 'INT') = 'CUST' and p_ordered_item_id is not null and p_sold_to_org_id is not null  THEN
      BEGIN
         SELECT citems.customer_item_number
         INTO  x_ordered_item
         FROM  mtl_customer_items citems
              ,mtl_customer_item_xrefs cxref
              ,mtl_system_items_vl sitems
         WHERE citems.customer_item_id = cxref.customer_item_id
           AND cxref.inventory_item_id = sitems.inventory_item_id
           AND sitems.inventory_item_id = p_inventory_item_id
           AND sitems.organization_id = l_organization_id
           AND citems.customer_item_id = p_ordered_item_id
           AND citems.customer_id = p_sold_to_org_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           Null;
        When too_many_rows then
       Null;
    When others then
       Null;
      END;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXIT GET_ORDERED_ITEM PROCEDURE' ) ;
   END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'GET_ORDERED_ITEM'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END GET_ORDERED_ITEM;
/*--- Bug 1823073 end----- */

-- Bug 1713035
-- This procedure is called from OEXOELIN.pld
-- to delete the current line and all associated
-- adjustments.  This new procedure was added
-- to reduce the number of calls to server side
-- packages from the form.
PROCEDURE Delete_Adjustments(x_line_id IN NUMBER) IS

l_return_status Varchar2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   OE_LINE_ADJ_UTIL.Delete_Row(p_line_id=>x_line_id);

   /* 1905650
      This is no longer required, since G_PRICE_ADJ request
      is logged against LINE entity now

   oe_debug_pub.add('delete the request logged for this line too');
   oe_delayed_requests_pvt.delete_request(
               p_entity_code =>OE_GLOBALS.G_ENTITY_LINE_ADJ,
               p_entity_id => x_line_id,
                       p_request_type => OE_GLOBALS.G_PRICE_ADJ,
                       x_return_status => l_return_status);
   */

END Delete_Adjustments;

PROCEDURE get_customer_details( p_site_use_id IN NUMBER,
                                p_site_use_code IN VARCHAR2,
x_customer_id OUT NOCOPY NUMBER,
x_customer_name OUT NOCOPY VARCHAR2,
x_customer_number OUT NOCOPY VARCHAR2
                                     ) IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

/* 2172651*/
        select /* MOAC_SQL_CHANGE */ cust.cust_account_id,
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
/* 2172651*/

EXCEPTION

        WHEN NO_DATA_FOUND THEN
         Null;
        When too_many_rows then
         Null;
       When others then
        Null;

END get_customer_details;

-- for 5331980 start**
PROCEDURE Reset_calculate_line_total IS
BEGIN
OE_GLOBALS.G_CALCULATE_LINE_TOTAL := TRUE;
END Reset_Calculate_line_Total;
--for 5331980 end**

END oe_oe_form_line;

/
