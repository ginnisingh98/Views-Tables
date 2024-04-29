--------------------------------------------------------
--  DDL for Package Body OE_OE_FORM_HEADER_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_FORM_HEADER_ADJ" AS
/* $Header: OEXFHADB.pls 120.1 2006/07/25 11:43:52 ppnair noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_OE_Form_Header_Adj';

--  Global variables holding cached record.

g_Header_Adj_rec      OE_Order_PUB.Header_Adj_Rec_Type
					:= OE_ORDER_PUB.G_MISS_HEADER_ADJ_REC;
g_db_Header_Adj_rec   OE_Order_PUB.Header_Adj_Rec_Type
					:= OE_ORDER_PUB.G_MISS_HEADER_ADJ_REC;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_Header_Adj
(   p_Header_Adj_rec                IN  OE_Order_PUB.Header_Adj_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

PROCEDURE Get_Header_Adj
(   p_db_record               IN  BOOLEAN := FALSE
,   p_price_adjustment_id     IN  NUMBER
,   x_Header_Adj_Rec		IN OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type
);

PROCEDURE Clear_Header_Adj;

--  Global variable holding performed operations.

g_opr__tbl                    OE_Order_PUB.Header_Adj_Tbl_Type;

--  Procedure : Default_Attributes
--


PROCEDURE Default_Attributes
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_header_id                     IN  NUMBER
,   p_line_id			    IN  NUMBER
, x_price_adjustment_id OUT NOCOPY NUMBER

, x_header_id OUT NOCOPY NUMBER

, x_discount_id OUT NOCOPY NUMBER

, x_discount_line_id OUT NOCOPY NUMBER

, x_automatic_flag OUT NOCOPY VARCHAR2

, x_percent OUT NOCOPY NUMBER

, x_line_id OUT NOCOPY NUMBER

, x_context OUT NOCOPY VARCHAR2

, x_attribute1 OUT NOCOPY VARCHAR2

, x_attribute2 OUT NOCOPY VARCHAR2

, x_attribute3 OUT NOCOPY VARCHAR2

, x_attribute4 OUT NOCOPY VARCHAR2

, x_attribute5 OUT NOCOPY VARCHAR2

, x_attribute6 OUT NOCOPY VARCHAR2

, x_attribute7 OUT NOCOPY VARCHAR2

, x_attribute8 OUT NOCOPY VARCHAR2

, x_attribute9 OUT NOCOPY VARCHAR2

, x_attribute10 OUT NOCOPY VARCHAR2

, x_attribute11 OUT NOCOPY VARCHAR2

, x_attribute12 OUT NOCOPY VARCHAR2

, x_attribute13 OUT NOCOPY VARCHAR2

, x_attribute14 OUT NOCOPY VARCHAR2

, x_attribute15 OUT NOCOPY VARCHAR2

, x_discount OUT NOCOPY VARCHAR2

, x_list_header_id OUT NOCOPY NUMBER

, x_list_line_id OUT NOCOPY NUMBER

, x_list_line_type_code OUT NOCOPY VARCHAR2

, x_modifier_mechanism_type_code OUT NOCOPY VARCHAR2

, x_updated_flag OUT NOCOPY VARCHAR2

, x_update_allowed OUT NOCOPY VARCHAR2

, x_applied_flag OUT NOCOPY VARCHAR2

, x_change_reason_code OUT NOCOPY VARCHAR2

, x_change_reason_text OUT NOCOPY VARCHAR2

, x_modified_from OUT NOCOPY VARCHAR2

, x_modified_to OUT NOCOPY VARCHAR2

, x_operand OUT NOCOPY NUMBER

, x_arithmetic_operator OUT NOCOPY varchar2

, x_adjusted_amount OUT NOCOPY NUMBER

, x_pricing_phase_id OUT NOCOPY NUMBER

, x_list_line_no OUT NOCOPY varchar2

, x_source_system_code OUT NOCOPY varchar2

, x_benefit_qty OUT NOCOPY NUMBER

, x_benefit_uom_code OUT NOCOPY varchar2

, x_print_on_invoice_flag OUT NOCOPY varchar2

, x_expiration_date OUT NOCOPY DATE

, x_rebate_transaction_type_code OUT NOCOPY varchar2

, x_rebate_transaction_reference OUT NOCOPY varchar2

, x_rebate_payment_system_code OUT NOCOPY varchar2

, x_redeemed_date OUT NOCOPY DATE

, x_redeemed_flag OUT NOCOPY varchar2

, x_accrual_flag OUT NOCOPY varchar2

, x_invoiced_flag OUT NOCOPY varchar2

, x_estimated_flag OUT NOCOPY varchar2

, x_credit_or_charge_flag OUT NOCOPY varchar2

, x_include_on_returns_flag OUT NOCOPY varchar2

, x_charge_type_code OUT NOCOPY varchar2

, x_charge_subtype_code OUT NOCOPY varchar2

, x_ac_context OUT NOCOPY VARCHAR2

, x_ac_attribute1 OUT NOCOPY VARCHAR2

, x_ac_attribute2 OUT NOCOPY VARCHAR2

, x_ac_attribute3 OUT NOCOPY VARCHAR2

, x_ac_attribute4 OUT NOCOPY VARCHAR2

, x_ac_attribute5 OUT NOCOPY VARCHAR2

, x_ac_attribute6 OUT NOCOPY VARCHAR2

, x_ac_attribute7 OUT NOCOPY VARCHAR2

, x_ac_attribute8 OUT NOCOPY VARCHAR2

, x_ac_attribute9 OUT NOCOPY VARCHAR2

, x_ac_attribute10 OUT NOCOPY VARCHAR2

, x_ac_attribute11 OUT NOCOPY VARCHAR2

, x_ac_attribute12 OUT NOCOPY VARCHAR2

, x_ac_attribute13 OUT NOCOPY VARCHAR2

, x_ac_attribute14 OUT NOCOPY VARCHAR2

, x_ac_attribute15 OUT NOCOPY VARCHAR2

--uom begin
, x_operand_per_pqty OUT NOCOPY NUMBER

, x_adjusted_amount_per_pqty OUT NOCOPY NUMBER

--uom end
)
IS
l_Header_Adj_rec              OE_Order_PUB.Header_Adj_Rec_Type;
l_Header_Adj_tbl              OE_Order_PUB.Header_Adj_Tbl_Type;
l_Header_Adj_val_rec          OE_Order_Pub.Header_Adj_Val_Rec_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_action_request_tbl		OE_Order_PUB.Request_Tbl_Type;
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_rec            OE_Order_PUB.Header_Adj_Rec_Type;
l_x_old_Header_Adj_rec            OE_Order_PUB.Header_Adj_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_old_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_rec        OE_Order_PUB.Header_Scredit_Rec_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_rec                  OE_Order_PUB.Line_Rec_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_rec          OE_Order_PUB.Line_Scredit_Rec_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_Lot_Serial_rec            OE_Order_PUB.Lot_Serial_Rec_Type;
l_x_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;


--New out parameters
l_x_Header_price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;

l_x_Line_price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


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


    l_x_old_header_adj_rec := OE_ORDER_PUB.G_MISS_HEADER_ADJ_REC;
    l_x_header_adj_rec := OE_ORDER_PUB.G_MISS_HEADER_ADJ_REC;

    --  Load IN parameters if any exist
    l_x_Header_adj_rec.header_id	:= p_header_id;
    l_x_Header_adj_rec.line_id		:= p_line_id;


    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.
    l_x_Header_Adj_rec.context                      := NULL;
    l_x_Header_Adj_rec.attribute1                   := NULL;
    l_x_Header_Adj_rec.attribute2                   := NULL;
    l_x_Header_Adj_rec.attribute3                   := NULL;
    l_x_Header_Adj_rec.attribute4                   := NULL;
    l_x_Header_Adj_rec.attribute5                   := NULL;
    l_x_Header_Adj_rec.attribute6                   := NULL;
    l_x_Header_Adj_rec.attribute7                   := NULL;
    l_x_Header_Adj_rec.attribute8                   := NULL;
    l_x_Header_Adj_rec.attribute9                   := NULL;
    l_x_Header_Adj_rec.attribute10                  := NULL;
    l_x_Header_Adj_rec.attribute11                  := NULL;
    l_x_Header_Adj_rec.attribute12                  := NULL;
    l_x_Header_Adj_rec.attribute13                  := NULL;
    l_x_Header_Adj_rec.attribute14                  := NULL;
    l_x_Header_Adj_rec.attribute15                  := NULL;
    l_x_Header_Adj_rec.ac_context                   := NULL;
    l_x_Header_Adj_rec.ac_attribute1                := NULL;
    l_x_Header_Adj_rec.ac_attribute2                := NULL;
    l_x_Header_Adj_rec.ac_attribute3                := NULL;
    l_x_Header_Adj_rec.ac_attribute4                := NULL;
    l_x_Header_Adj_rec.ac_attribute5                := NULL;
    l_x_Header_Adj_rec.ac_attribute6                := NULL;
    l_x_Header_Adj_rec.ac_attribute7                := NULL;
    l_x_Header_Adj_rec.ac_attribute8                := NULL;
    l_x_Header_Adj_rec.ac_attribute9                := NULL;
    l_x_Header_Adj_rec.ac_attribute10               := NULL;
    l_x_Header_Adj_rec.ac_attribute11               := NULL;
    l_x_Header_Adj_rec.ac_attribute12               := NULL;
    l_x_Header_Adj_rec.ac_attribute13               := NULL;
    l_x_Header_Adj_rec.ac_attribute14               := NULL;
    l_x_Header_Adj_rec.ac_attribute15               := NULL;
    /*
    l_Header_Adj_rec.list_header_id	:=null;
   l_Header_Adj_rec.list_line_id	:=NULL;
   l_Header_Adj_rec.list_line_type_code	:=NULL;
   l_Header_Adj_rec.modifier_mechanism_type_code	:=NULL;
   l_Header_Adj_rec.updated_flag	:=NULL;
   l_Header_Adj_rec.update_allowed	:=NULL;
   l_Header_Adj_rec.applied_flag	:=NULL;
   l_Header_Adj_rec.change_reason_code	:=NULL;
   l_Header_Adj_rec.change_reason_text	:=NULL;
   l_Header_Adj_rec.modified_from	:=NULL;
   l_Header_Adj_rec.modified_to	:=NULL;
   l_Header_Adj_rec.operand	:=NULL;
   l_Header_Adj_rec.arithmetic_operator	:=NULL;
  */

    --  Set Operation to Create
    l_x_Header_Adj_rec.operation := OE_GLOBALS.G_OPR_CREATE;

    --  Populate Header_Adj table
    l_x_Header_Adj_tbl(1) := l_x_Header_Adj_rec;
    l_x_old_Header_Adj_tbl(1) := l_x_old_Header_Adj_rec;

    -- Call Oe_Order_Adj_Pvt.Header_Adj
    oe_order_adj_pvt.Header_Adjs
    (	p_init_msg_list	=> FND_API.G_TRUE
    ,	p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL
    ,	p_control_rec		=> l_control_rec
    ,	p_x_header_adj_tbl	=> l_x_Header_Adj_tbl
    ,	p_x_old_header_adj_tbl	=> l_x_old_Header_Adj_tbl
    );

   /*********************************************************************
** commented out nocopy for performance changes **


    --  Call OE_Order_PVT.Process_order
    OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Header_Adj_tbl              => l_Header_Adj_tbl
    ,   x_header_rec                  => l_x_header_rec
    ,   x_Header_Adj_tbl              => l_x_Header_Adj_tbl
-- New Parameters
    ,   x_Header_price_Att_tbl         => l_x_Header_price_Att_tbl
    ,   x_Header_Adj_Att_tbl           => l_x_Header_Adj_Att_tbl
    ,   x_Header_Adj_Assoc_tbl         => l_x_Header_Adj_Assoc_tbl

    ,   x_Header_Scredit_tbl          => l_x_Header_Scredit_tbl
    ,   x_line_tbl                    => l_x_line_tbl
    ,   x_Line_Adj_tbl                => l_x_Line_Adj_tbl

-- New Parameters
    ,   x_Line_price_Att_tbl          => l_x_Line_price_Att_tbl
    ,   x_Line_Adj_Att_tbl            => l_x_Line_Adj_Att_tbl
    ,   x_Line_Adj_Assoc_tbl          => l_x_Line_Adj_Assoc_tbl

    ,   x_Line_Scredit_tbl            => l_x_Line_Scredit_tbl
    ,   x_Lot_Serial_tbl              => l_x_Lot_Serial_tbl
    ,	x_action_request_tbl	      => l_action_request_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    ******************************************************************/

    --  Unload out tbl
    l_x_Header_Adj_rec := l_x_Header_Adj_tbl(1);

    IF l_x_header_adj_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_x_header_adj_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --  Load OUT parameters.
    x_price_adjustment_id          := l_x_Header_Adj_rec.price_adjustment_id;
    x_header_id                    := l_x_Header_Adj_rec.header_id;
    x_discount_id                  := l_x_Header_Adj_rec.discount_id;
    x_discount_line_id             := l_x_Header_Adj_rec.discount_line_id;
    x_automatic_flag               := l_x_Header_Adj_rec.automatic_flag;
    x_percent                      := l_x_Header_Adj_rec.percent;
    x_line_id                      := l_x_Header_Adj_rec.line_id;
    x_context                      := l_x_Header_Adj_rec.context;
    x_attribute1                   := l_x_Header_Adj_rec.attribute1;
    x_attribute2                   := l_x_Header_Adj_rec.attribute2;
    x_attribute3                   := l_x_Header_Adj_rec.attribute3;
    x_attribute4                   := l_x_Header_Adj_rec.attribute4;
    x_attribute5                   := l_x_Header_Adj_rec.attribute5;
    x_attribute6                   := l_x_Header_Adj_rec.attribute6;
    x_attribute7                   := l_x_Header_Adj_rec.attribute7;
    x_attribute8                   := l_x_Header_Adj_rec.attribute8;
    x_attribute9                   := l_x_Header_Adj_rec.attribute9;
    x_attribute10                  := l_x_Header_Adj_rec.attribute10;
    x_attribute11                  := l_x_Header_Adj_rec.attribute11;
    x_attribute12                  := l_x_Header_Adj_rec.attribute12;
    x_attribute13                  := l_x_Header_Adj_rec.attribute13;
    x_attribute14                  := l_x_Header_Adj_rec.attribute14;
    x_attribute15                  := l_x_Header_Adj_rec.attribute15;
    x_ac_context                   := l_x_Header_Adj_rec.ac_context;
    x_ac_attribute1                := l_x_Header_Adj_rec.ac_attribute1;
    x_ac_attribute2                := l_x_Header_Adj_rec.ac_attribute2;
    x_ac_attribute3                := l_x_Header_Adj_rec.ac_attribute3;
    x_ac_attribute4                := l_x_Header_Adj_rec.ac_attribute4;
    x_ac_attribute5                := l_x_Header_Adj_rec.ac_attribute5;
    x_ac_attribute6                := l_x_Header_Adj_rec.ac_attribute6;
    x_ac_attribute7                := l_x_Header_Adj_rec.ac_attribute7;
    x_ac_attribute8                := l_x_Header_Adj_rec.ac_attribute8;
    x_ac_attribute9                := l_x_Header_Adj_rec.ac_attribute9;
    x_ac_attribute10               := l_x_Header_Adj_rec.ac_attribute10;
    x_ac_attribute11               := l_x_Header_Adj_rec.ac_attribute11;
    x_ac_attribute12               := l_x_Header_Adj_rec.ac_attribute12;
    x_ac_attribute13               := l_x_Header_Adj_rec.ac_attribute13;
    x_ac_attribute14               := l_x_Header_Adj_rec.ac_attribute14;
    x_ac_attribute15               := l_x_Header_Adj_rec.ac_attribute15;
    x_list_header_id 		     := l_x_Header_Adj_rec.list_header_id;
    x_list_line_id			     := l_x_Header_Adj_rec.list_line_id;
    x_list_line_type_code 		:= l_x_Header_Adj_rec.list_line_type_code;
    x_modifier_mechanism_type_code	:= l_x_Header_Adj_rec.modifier_mechanism_type_code;
    x_updated_flag		     := l_x_Header_Adj_rec.updated_flag;
    x_update_allowed	     := l_x_Header_Adj_rec.update_allowed;
    x_applied_flag			:= l_x_Header_Adj_rec.applied_flag;
    x_change_reason_code 	:= l_x_Header_Adj_rec.change_reason_code;
    x_change_reason_text     	:= l_x_Header_Adj_rec.change_reason_text;
    x_modified_from		     := l_x_Header_Adj_rec.modified_from;
    x_modified_to		     := l_x_Header_Adj_rec.modified_to;
    x_operand			     := l_x_Header_Adj_rec.operand;
    x_arithmetic_operator	:= l_x_Header_Adj_rec.arithmetic_operator;

    x_adjusted_amount		:= l_x_Header_Adj_rec.adjusted_amount;
    x_pricing_phase_id		:= l_x_Header_Adj_rec.pricing_phase_id;
    x_list_line_no           := l_x_Header_Adj_rec.list_line_no;
    x_source_system_code     := l_x_Header_Adj_rec.source_system_code;
    x_benefit_qty            := l_x_Header_Adj_rec.benefit_qty;
    x_benefit_uom_code       := l_x_Header_Adj_rec.benefit_uom_code;
    x_print_on_invoice_flag  := l_x_Header_Adj_rec.print_on_invoice_flag;
    x_expiration_date        := l_x_Header_Adj_rec.expiration_date;
    x_rebate_transaction_type_code  := l_x_Header_Adj_rec.rebate_transaction_type_code;
    x_rebate_transaction_reference  := l_x_Header_Adj_rec.rebate_transaction_reference;
    x_rebate_payment_system_code    := l_x_Header_Adj_rec.rebate_payment_system_code;
    x_redeemed_date          := l_x_Header_Adj_rec.redeemed_date;
    x_redeemed_flag          := l_x_Header_Adj_rec.redeemed_flag;
    x_accrual_flag           := l_x_Header_Adj_rec.accrual_flag;
    x_estimated_flag         := l_x_Header_Adj_rec.estimated_flag;
    x_invoiced_flag          := l_x_Header_Adj_rec.invoiced_flag;
    x_charge_type_code       := l_x_Header_Adj_rec.charge_type_code;
    x_charge_subtype_code    := l_x_Header_Adj_rec.charge_subtype_code;
    x_credit_or_charge_flag  := l_x_Header_Adj_rec.credit_or_charge_flag;
    x_include_on_returns_flag := l_x_Header_Adj_rec.include_on_returns_flag;
    --uom begin
	 x_operand_per_pqty        := l_x_Header_Adj_rec.operand_per_pqty;
      x_adjusted_amount_per_pqty := l_x_Header_Adj_rec.adjusted_amount_per_pqty;
    --uom end
        --  Load display out parameters if any

    l_Header_Adj_val_rec := OE_Header_Adj_Util.Get_Values
    (   p_Header_Adj_rec              => l_x_Header_Adj_rec
    );
    x_discount                     := l_Header_Adj_val_rec.discount;

    --  Write to cache.
    --  Set db_flag to False before writing to cache
    l_x_Header_Adj_rec.db_flag := FND_API.G_FALSE;

    Write_Header_Adj
    (   p_Header_Adj_rec              => l_x_Header_Adj_rec
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

PROCEDURE Change_Attributes
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_price_adjustment_id           IN  NUMBER
,   p_attr_id                       IN  NUMBER
,   p_attr_value1                   IN  VARCHAR2
,   p_attr_value2                   IN  VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
,   p_context                       IN  VARCHAR2
,   p_attribute1                    IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
,   p_attribute3                    IN  VARCHAR2
,   p_attribute4                    IN  VARCHAR2
,   p_attribute5                    IN  VARCHAR2
,   p_attribute6                    IN  VARCHAR2
,   p_attribute7                    IN  VARCHAR2
,   p_attribute8                    IN  VARCHAR2
,   p_attribute9                    IN  VARCHAR2
,   p_attribute10                   IN  VARCHAR2
,   p_attribute11                   IN  VARCHAR2
,   p_attribute12                   IN  VARCHAR2
,   p_attribute13                   IN  VARCHAR2
,   p_attribute14                   IN  VARCHAR2
,   p_attribute15                   IN  VARCHAR2
,   p_ac_context                    IN  VARCHAR2
,   p_ac_attribute1                 IN  VARCHAR2
,   p_ac_attribute2                 IN  VARCHAR2
,   p_ac_attribute3                 IN  VARCHAR2
,   p_ac_attribute4                 IN  VARCHAR2
,   p_ac_attribute5                 IN  VARCHAR2
,   p_ac_attribute6                 IN  VARCHAR2
,   p_ac_attribute7                 IN  VARCHAR2
,   p_ac_attribute8                 IN  VARCHAR2
,   p_ac_attribute9                 IN  VARCHAR2
,   p_ac_attribute10                IN  VARCHAR2
,   p_ac_attribute11                IN  VARCHAR2
,   p_ac_attribute12                IN  VARCHAR2
,   p_ac_attribute13                IN  VARCHAR2
,   p_ac_attribute14                IN  VARCHAR2
,   p_ac_attribute15                IN  VARCHAR2
, x_price_adjustment_id OUT NOCOPY NUMBER

, x_header_id OUT NOCOPY NUMBER

, x_discount_id OUT NOCOPY NUMBER

, x_discount_line_id OUT NOCOPY NUMBER

, x_automatic_flag OUT NOCOPY VARCHAR2

, x_percent OUT NOCOPY NUMBER

, x_line_id OUT NOCOPY NUMBER

, x_context OUT NOCOPY VARCHAR2

, x_attribute1 OUT NOCOPY VARCHAR2

, x_attribute2 OUT NOCOPY VARCHAR2

, x_attribute3 OUT NOCOPY VARCHAR2

, x_attribute4 OUT NOCOPY VARCHAR2

, x_attribute5 OUT NOCOPY VARCHAR2

, x_attribute6 OUT NOCOPY VARCHAR2

, x_attribute7 OUT NOCOPY VARCHAR2

, x_attribute8 OUT NOCOPY VARCHAR2

, x_attribute9 OUT NOCOPY VARCHAR2

, x_attribute10 OUT NOCOPY VARCHAR2

, x_attribute11 OUT NOCOPY VARCHAR2

, x_attribute12 OUT NOCOPY VARCHAR2

, x_attribute13 OUT NOCOPY VARCHAR2

, x_attribute14 OUT NOCOPY VARCHAR2

, x_attribute15 OUT NOCOPY VARCHAR2

, x_ac_context OUT NOCOPY VARCHAR2

, x_ac_attribute1 OUT NOCOPY VARCHAR2

, x_ac_attribute2 OUT NOCOPY VARCHAR2

, x_ac_attribute3 OUT NOCOPY VARCHAR2

, x_ac_attribute4 OUT NOCOPY VARCHAR2

, x_ac_attribute5 OUT NOCOPY VARCHAR2

, x_ac_attribute6 OUT NOCOPY VARCHAR2

, x_ac_attribute7 OUT NOCOPY VARCHAR2

, x_ac_attribute8 OUT NOCOPY VARCHAR2

, x_ac_attribute9 OUT NOCOPY VARCHAR2

, x_ac_attribute10 OUT NOCOPY VARCHAR2

, x_ac_attribute11 OUT NOCOPY VARCHAR2

, x_ac_attribute12 OUT NOCOPY VARCHAR2

, x_ac_attribute13 OUT NOCOPY VARCHAR2

, x_ac_attribute14 OUT NOCOPY VARCHAR2

, x_ac_attribute15 OUT NOCOPY VARCHAR2

, x_discount OUT NOCOPY VARCHAR2

,   p_enforce_fixed_price	    IN  VARCHAR2

-- New code added
, x_list_header_id OUT NOCOPY NUMBER

, x_list_line_id OUT NOCOPY NUMBER

, x_list_line_type_code OUT NOCOPY VARCHAR2

, x_modifier_mechanism_type_code OUT NOCOPY VARCHAR2

, x_updated_flag OUT NOCOPY VARCHAR2

, x_update_allowed OUT NOCOPY VARCHAR2

, x_applied_flag OUT NOCOPY VARCHAR2

, x_change_reason_code OUT NOCOPY VARCHAR2

, x_change_reason_text OUT NOCOPY VARCHAR2

, x_modified_from OUT NOCOPY VARCHAR2

, x_modified_to OUT NOCOPY VARCHAR2

, x_operand OUT NOCOPY NUMBER

, x_arithmetic_operator OUT NOCOPY varchar2


, x_adjusted_amount OUT NOCOPY NUMBER

, x_pricing_phase_id OUT NOCOPY NUMBER

, x_list_line_no OUT NOCOPY varchar2

, x_source_system_code OUT NOCOPY varchar2

, x_benefit_qty OUT NOCOPY NUMBER

, x_benefit_uom_code OUT NOCOPY varchar2

, x_print_on_invoice_flag OUT NOCOPY varchar2

, x_expiration_date OUT NOCOPY DATE

, x_rebate_transaction_type_code OUT NOCOPY varchar2

, x_rebate_transaction_reference OUT NOCOPY varchar2

, x_rebate_payment_system_code OUT NOCOPY varchar2

, x_redeemed_date OUT NOCOPY DATE

, x_redeemed_flag OUT NOCOPY varchar2

, x_accrual_flag OUT NOCOPY varchar2

, x_invoiced_flag OUT NOCOPY varchar2

, x_estimated_flag OUT NOCOPY varchar2

, x_credit_or_charge_flag OUT NOCOPY varchar2

, x_include_on_returns_flag OUT NOCOPY varchar2

, x_charge_type_code OUT NOCOPY varchar2

, x_charge_subtype_code OUT NOCOPY varchar2

--uom begin
, x_operand_per_pqty OUT NOCOPY number

, x_adjusted_amount_per_pqty OUT NOCOPY number

--uom end
)
IS
l_request_rec		      OE_Order_Pub.Request_Rec_Type;
l_request_tbl		      OE_Order_Pub.Request_Tbl_Type;
l_Header_Adj_rec              OE_Order_PUB.Header_Adj_Rec_Type;
l_old_Header_Adj_rec          OE_Order_PUB.Header_Adj_Rec_Type;
l_x_old_Header_Adj_rec          OE_Order_PUB.Header_Adj_Rec_Type;
l_Header_Adj_tbl              OE_Order_PUB.Header_Adj_Tbl_Type;
l_old_Header_Adj_tbl          OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_old_Header_Adj_tbl          OE_Order_PUB.Header_Adj_Tbl_Type;
l_Header_Adj_val_rec          OE_Order_PUB.Header_Adj_Val_Rec_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_action_request_tbl		OE_Order_PUB.Request_Tbl_Type;
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
l_x_Lot_Serial_rec            OE_Order_PUB.Lot_Serial_Rec_Type;
l_x_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;

--New out parameters
l_x_Header_price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;

l_x_Line_price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type ;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
l_date_format                 Varchar2(22) := 'DD-MON-YYYY HH24:MI:SS';
stmt NUMBER:=0;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_HEADER_ADJ.CHANGE_ATTRIBUTES' , 1 ) ;
    END IF;

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
    l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_HEADER_ADJ;


    --  Instruct API to retain its caches
    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;


    -- Save point to rollback to if there were
    -- any errors
    SAVEPOINT change_attributes;

    --  Read Header_Adj from cache
    Get_Header_Adj
    (   p_db_record                   => FALSE
    ,   p_price_adjustment_id         => p_price_adjustment_id
    ,   x_Header_Adj_rec			   => l_x_Header_Adj_rec
    );


   l_x_old_Header_Adj_rec           := l_x_Header_Adj_rec;


    IF p_attr_id = OE_Header_Adj_Util.G_PRICE_ADJUSTMENT THEN
        l_x_Header_Adj_rec.price_adjustment_id := TO_NUMBER(p_attr_value1);
    ELSIF p_attr_id = OE_Header_Adj_Util.G_HEADER THEN
        l_x_Header_Adj_rec.header_id := TO_NUMBER(p_attr_value1);

    -- The following has been done because a discount can only
    -- be uniquely identified with a discount_id and discount_line_id
    --
    -- The form will now be sending in both attribute_values
    --
    -- It ATTR_ID       is discount_id then
    --    ATTR_VALUE1   is discount_id
    --    ATTR_VALUE2   is discount_line_id
    ELSIF p_attr_id = OE_Header_Adj_Util.G_DISCOUNT THEN
        l_x_Header_Adj_rec.discount_id	  := TO_NUMBER(p_attr_value1);
        l_x_Header_Adj_rec.discount_line_id := TO_NUMBER(p_attr_value2);

    -- It ATTR_ID       is discount_line_id then
    --    ATTR_VALUE1   is discount_line_id
    --    ATTR_VALUE2   is discount_id
    ELSIF p_attr_id = OE_Header_Adj_Util.G_DISCOUNT_LINE THEN
        l_x_Header_Adj_rec.discount_line_id := TO_NUMBER(p_attr_value1);
        l_x_Header_Adj_rec.discount_id	  := TO_NUMBER(p_attr_value2);

-- New code Added :: Column Changes
    ELSIF p_attr_id = OE_Header_Adj_Util.G_LIST_HEADER_ID  then
		l_x_Header_Adj_rec.list_header_id := to_number(p_attr_value1) ;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_LIST_LINE_ID  then
		l_x_Header_Adj_rec.list_line_id := to_number(p_attr_value1) ;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_LIST_LINE_TYPE_CODE then
		l_x_Header_Adj_rec.list_line_type_code := p_attr_value1 ;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_MODIFIER_MECHANISM_TYPE_CODE then
		l_x_Header_Adj_rec.modifier_mechanism_type_code := p_attr_value1 ;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_MODIFIED_FROM  then
		l_x_Header_Adj_rec.modified_from := p_attr_value1;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_MODIFIED_TO  then
		l_x_Header_Adj_rec.modified_to := p_attr_value1;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_UPDATE_ALLOWED  then
		l_x_Header_Adj_rec.update_allowed := p_attr_value1 ;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_UPDATED_FLAG  then
		l_x_Header_Adj_rec.updated_flag := p_attr_value1 ;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_APPLIED_FLAG  then
		l_x_Header_Adj_rec.applied_flag := p_attr_value1 ;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_CHANGE_REASON_CODE then
		l_x_Header_Adj_rec.change_reason_code := p_attr_value1 ;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_CHANGE_REASON_TEXT  then
		l_x_Header_Adj_rec.change_reason_text := p_attr_value1 ;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_OPERAND  then
		l_x_Header_Adj_rec.operand := p_attr_value1 ;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_ARITHMETIC_OPERATOR  then
		l_x_Header_Adj_rec.arithmetic_operator := p_attr_value1 ;

    ELSIF p_attr_id = OE_Header_Adj_Util.G_ADJUSTED_AMOUNT  then
		l_x_Header_Adj_rec.adjusted_amount := p_attr_value1 ;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_PRICING_PHASE_ID  then
		l_x_Header_Adj_rec.pricing_phase_id := p_attr_value1 ;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_LIST_LINE_NO then
	  l_x_Header_Adj_rec.list_line_no := p_attr_value1 ;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_SOURCE_SYSTEM_CODE then
          l_x_Header_Adj_rec.source_system_code := p_attr_value1;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_BENEFIT_QTY then
          l_x_Header_Adj_rec.benefit_qty := TO_NUMBER(p_attr_value1);
    ELSIF p_attr_id = OE_Header_Adj_Util.G_BENEFIT_UOM_CODE then
          l_x_Header_Adj_rec.benefit_uom_code := p_attr_value1;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_PRINT_ON_INVOICE_FLAG then
          l_x_Header_Adj_rec.print_on_invoice_flag := p_attr_value1;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_EXPIRATION_DATE then
          --l_x_Header_Adj_rec.expiration_date := TO_DATE(p_attr_value1, l_date_format);
	  l_x_Header_Adj_rec.expiration_date := fnd_date.string_TO_DATE(p_attr_value1, l_date_format); --bug5402396
    ELSIF p_attr_id = OE_Header_Adj_Util.G_REBATE_TRANSACTION_TYPE_CODE then
          l_x_Header_Adj_rec.rebate_transaction_type_code := p_attr_value1;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_REBATE_TRANSACTION_REFERENCE then
          l_x_Header_Adj_rec.rebate_transaction_reference := p_attr_value1;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_REBATE_PAYMENT_SYSTEM_CODE then
          l_x_Header_Adj_rec.rebate_payment_system_code := p_attr_value1;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_REDEEMED_DATE then
          --l_x_Header_Adj_rec.redeemed_date := TO_DATE(p_attr_value1, l_date_format);
	  l_x_Header_Adj_rec.redeemed_date := fnd_date.string_TO_DATE(p_attr_value1, l_date_format); --bug5402396
    ELSIF p_attr_id = OE_Header_Adj_Util.G_REDEEMED_FLAG then
          l_x_Header_Adj_rec.redeemed_flag  := p_attr_value1;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_ACCRUAL_FLAG then
          l_x_Header_Adj_rec.accrual_flag := p_attr_value1;

    ELSIF p_attr_id = OE_Header_Adj_Util.G_AUTOMATIC THEN
        l_x_Header_Adj_rec.automatic_flag := p_attr_value1;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_PERCENT THEN
        l_x_Header_Adj_rec.percent := TO_NUMBER(p_attr_value1);
    --Manual begin
    ELSIF p_attr_id = OE_Header_Adj_Util.G_LINE THEN
        If p_attr_value1 is Not Null Then
          l_x_Header_Adj_rec.line_id := TO_NUMBER(p_attr_value1);
        Else
          l_x_Header_Adj_rec.line_id := NULL;
        End If;
    --Manual end
    ELSIF p_attr_id = OE_Header_Adj_Util.G_ESTIMATED_FLAG THEN
        l_x_Header_Adj_rec.estimated_flag := p_attr_value1;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_INVOICED_FLAG THEN
        l_x_Header_Adj_rec.INVOICED_FLAG := p_attr_value1;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_credit_or_charge_flag THEN
        l_x_Header_Adj_rec.credit_or_charge_flag := p_attr_value1;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_include_on_returns_flag THEN
        l_x_Header_Adj_rec.include_on_returns_flag := p_attr_value1;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_charge_type_code THEN
        l_x_Header_Adj_rec.charge_type_code := p_attr_value1;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_charge_subtype_code THEN
        l_x_Header_Adj_rec.charge_subtype_code := p_attr_value1;
    --uom begin
    ELSIF p_attr_id = OE_Header_Adj_Util.G_operand_per_pqty Then
	 l_x_Header_Adj_rec.operand_per_pqty := to_number(p_attr_value1);
    ELSIF  p_attr_id = OE_Header_Adj_Util.G_adjusted_amount_per_pqty Then
      l_x_Header_Adj_rec.adjusted_amount_per_pqty := to_number(p_attr_value1);
    --uom end
    --Manual begin
    ELSIF p_attr_id = OE_Header_Adj_Util.G_modifier_level_code Then
         l_x_Header_Adj_rec.modifier_level_code := p_attr_value1;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_OVERRIDE_ALLOWED_FLAG Then
         l_x_Header_Adj_rec.update_allowed:= p_attr_value1;
    --Manual end
    ELSIF p_attr_id = OE_Header_Adj_Util.G_CONTEXT
    OR     p_attr_id = OE_Header_Adj_Util.G_ATTRIBUTE1
    OR     p_attr_id = OE_Header_Adj_Util.G_ATTRIBUTE2
    OR     p_attr_id = OE_Header_Adj_Util.G_ATTRIBUTE3
    OR     p_attr_id = OE_Header_Adj_Util.G_ATTRIBUTE4
    OR     p_attr_id = OE_Header_Adj_Util.G_ATTRIBUTE5
    OR     p_attr_id = OE_Header_Adj_Util.G_ATTRIBUTE6
    OR     p_attr_id = OE_Header_Adj_Util.G_ATTRIBUTE7
    OR     p_attr_id = OE_Header_Adj_Util.G_ATTRIBUTE8
    OR     p_attr_id = OE_Header_Adj_Util.G_ATTRIBUTE9
    OR     p_attr_id = OE_Header_Adj_Util.G_ATTRIBUTE10
    OR     p_attr_id = OE_Header_Adj_Util.G_ATTRIBUTE11
    OR     p_attr_id = OE_Header_Adj_Util.G_ATTRIBUTE12
    OR     p_attr_id = OE_Header_Adj_Util.G_ATTRIBUTE13
    OR     p_attr_id = OE_Header_Adj_Util.G_ATTRIBUTE14
    OR     p_attr_id = OE_Header_Adj_Util.G_ATTRIBUTE15
    THEN

        l_x_Header_Adj_rec.context       := p_context;
        l_x_Header_Adj_rec.attribute1    := p_attribute1;
        l_x_Header_Adj_rec.attribute2    := p_attribute2;
        l_x_Header_Adj_rec.attribute3    := p_attribute3;
        l_x_Header_Adj_rec.attribute4    := p_attribute4;
        l_x_Header_Adj_rec.attribute5    := p_attribute5;
        l_x_Header_Adj_rec.attribute6    := p_attribute6;
        l_x_Header_Adj_rec.attribute7    := p_attribute7;
        l_x_Header_Adj_rec.attribute8    := p_attribute8;
        l_x_Header_Adj_rec.attribute9    := p_attribute9;
        l_x_Header_Adj_rec.attribute10   := p_attribute10;
        l_x_Header_Adj_rec.attribute11   := p_attribute11;
        l_x_Header_Adj_rec.attribute12   := p_attribute12;
        l_x_Header_Adj_rec.attribute13   := p_attribute13;
        l_x_Header_Adj_rec.attribute14   := p_attribute14;
        l_x_Header_Adj_rec.attribute15   := p_attribute15;
    ELSIF p_attr_id = OE_Header_Adj_Util.G_AC_CONTEXT
    OR     p_attr_id = OE_Header_Adj_Util.G_AC_ATTRIBUTE1
    OR     p_attr_id = OE_Header_Adj_Util.G_AC_ATTRIBUTE2
    OR     p_attr_id = OE_Header_Adj_Util.G_AC_ATTRIBUTE3
    OR     p_attr_id = OE_Header_Adj_Util.G_AC_ATTRIBUTE4
    OR     p_attr_id = OE_Header_Adj_Util.G_AC_ATTRIBUTE5
    OR     p_attr_id = OE_Header_Adj_Util.G_AC_ATTRIBUTE6
    OR     p_attr_id = OE_Header_Adj_Util.G_AC_ATTRIBUTE7
    OR     p_attr_id = OE_Header_Adj_Util.G_AC_ATTRIBUTE8
    OR     p_attr_id = OE_Header_Adj_Util.G_AC_ATTRIBUTE9
    OR     p_attr_id = OE_Header_Adj_Util.G_AC_ATTRIBUTE10
    OR     p_attr_id = OE_Header_Adj_Util.G_AC_ATTRIBUTE11
    OR     p_attr_id = OE_Header_Adj_Util.G_AC_ATTRIBUTE12
    OR     p_attr_id = OE_Header_Adj_Util.G_AC_ATTRIBUTE13
    OR     p_attr_id = OE_Header_Adj_Util.G_AC_ATTRIBUTE14
    OR     p_attr_id = OE_Header_Adj_Util.G_AC_ATTRIBUTE15
    THEN

        l_x_Header_Adj_rec.ac_context       := p_ac_context;
        l_x_Header_Adj_rec.ac_attribute1    := p_ac_attribute1;
        l_x_Header_Adj_rec.ac_attribute2    := p_ac_attribute2;
        l_x_Header_Adj_rec.ac_attribute3    := p_ac_attribute3;
        l_x_Header_Adj_rec.ac_attribute4    := p_ac_attribute4;
        l_x_Header_Adj_rec.ac_attribute5    := p_ac_attribute5;
        l_x_Header_Adj_rec.ac_attribute6    := p_ac_attribute6;
        l_x_Header_Adj_rec.ac_attribute7    := p_ac_attribute7;
        l_x_Header_Adj_rec.ac_attribute8    := p_ac_attribute8;
        l_x_Header_Adj_rec.ac_attribute9    := p_ac_attribute9;
        l_x_Header_Adj_rec.ac_attribute10   := p_ac_attribute10;
        l_x_Header_Adj_rec.ac_attribute11   := p_ac_attribute11;
        l_x_Header_Adj_rec.ac_attribute12   := p_ac_attribute12;
        l_x_Header_Adj_rec.ac_attribute13   := p_ac_attribute13;
        l_x_Header_Adj_rec.ac_attribute14   := p_ac_attribute14;
        l_x_Header_Adj_rec.ac_attribute15   := p_ac_attribute15;

    ELSE

        --  Unexpected error, unrecognized attribute
        stmt:=5;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attributes'
            ,   'Unrecognized attribute:'||p_attr_id
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    stmt:=10;

    --  Set Operation.
    IF FND_API.To_Boolean(l_x_Header_Adj_rec.db_flag) THEN
        l_x_Header_Adj_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_x_Header_Adj_rec.operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;


    -- Request execution of delayed request on if a discount is
    -- applied
   /* IF p_attr_id = OE_Header_Adj_Util.G_DISCOUNT_LINE
      OR
      p_attr_id = OE_Header_Adj_Util.G_DISCOUNT
      THEN

       -- Assign requests that are to be executed
       l_request_rec.entity_code:= OE_GLOBALS.G_ENTITY_HEADER_ADJ;
       l_request_rec.entity_id	:= l_header_adj_rec.price_adjustment_id;
       l_request_rec.param1	:= l_header_adj_rec.discount_id;
       l_request_rec.param2	:= l_header_adj_rec.header_id;
       l_request_rec.request_type	:= OE_GLOBALS.G_CHECK_DUPLICATE;
       l_request_tbl(1) := l_request_rec;

    END IF; */

    --  Populate Header_Adj table
    -- l_Header_Adj_tbl(1) := l_Header_Adj_rec;
    l_x_Header_Adj_tbl(1) := l_x_Header_Adj_rec;
    l_old_Header_Adj_tbl(1) := l_old_Header_Adj_rec;

    -- Call Oe_Order_Adj_Pvt.Header_Adj
    l_Header_Adj_rec := l_x_Header_Adj_rec;
        stmt:=15;
    oe_order_adj_pvt.Header_Adjs
    (	p_init_msg_list	=> FND_API.G_TRUE
    ,	p_validation_level 	=> FND_API.G_VALID_LEVEL_NONE
    ,	p_control_rec		=> l_control_rec
    ,	p_x_header_adj_tbl	=> l_x_Header_Adj_tbl
    ,   p_x_old_header_adj_tbl 	=> l_x_old_header_adj_tbl
    );

    --  Unload out tbl
    l_x_Header_Adj_rec := l_x_Header_Adj_tbl(1);

            stmt:=20;
    IF l_x_header_adj_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_x_header_adj_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
               stmt:=25;
       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
          (p_request_type   => OE_GLOBALS.G_CHECK_DUPLICATE
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

	OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
          (p_request_type   => OE_GLOBALS.G_CHECK_FIXED_PRICE
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
	IF p_enforce_fixed_price = 'YES' THEN
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;
	ELSE
		l_return_status := FND_API.G_RET_STS_SUCCESS;
	END IF;


            stmt:=30;
    --  Init OUT parameters to missing.

    x_price_adjustment_id          := FND_API.G_MISS_NUM;
    x_header_id                    := FND_API.G_MISS_NUM;
    x_discount_id                  := FND_API.G_MISS_NUM;
    x_discount                     := FND_API.G_MISS_CHAR;
    x_discount_line_id             := FND_API.G_MISS_NUM;
    x_automatic_flag               := FND_API.G_MISS_CHAR;
    x_percent                      := FND_API.G_MISS_NUM;
    x_line_id                      := FND_API.G_MISS_NUM;
    x_context                      := FND_API.G_MISS_CHAR;
    x_attribute1                   := FND_API.G_MISS_CHAR;
    x_attribute2                   := FND_API.G_MISS_CHAR;
    x_attribute3                   := FND_API.G_MISS_CHAR;
    x_attribute4                   := FND_API.G_MISS_CHAR;
    x_attribute5                   := FND_API.G_MISS_CHAR;
    x_attribute6                   := FND_API.G_MISS_CHAR;
    x_attribute7                   := FND_API.G_MISS_CHAR;
    x_attribute8                   := FND_API.G_MISS_CHAR;
    x_attribute9                   := FND_API.G_MISS_CHAR;
    x_attribute10                  := FND_API.G_MISS_CHAR;
    x_attribute11                  := FND_API.G_MISS_CHAR;
    x_attribute12                  := FND_API.G_MISS_CHAR;
    x_attribute13                  := FND_API.G_MISS_CHAR;
    x_attribute14                  := FND_API.G_MISS_CHAR;
    x_attribute15                  := FND_API.G_MISS_CHAR;
    x_ac_context                   := FND_API.G_MISS_CHAR;
    x_ac_attribute1                := FND_API.G_MISS_CHAR;
    x_ac_attribute2                := FND_API.G_MISS_CHAR;
    x_ac_attribute3                := FND_API.G_MISS_CHAR;
    x_ac_attribute4                := FND_API.G_MISS_CHAR;
    x_ac_attribute5                := FND_API.G_MISS_CHAR;
    x_ac_attribute6                := FND_API.G_MISS_CHAR;
    x_ac_attribute7                := FND_API.G_MISS_CHAR;
    x_ac_attribute8                := FND_API.G_MISS_CHAR;
    x_ac_attribute9                := FND_API.G_MISS_CHAR;
    x_ac_attribute10               := FND_API.G_MISS_CHAR;
    x_ac_attribute11               := FND_API.G_MISS_CHAR;
    x_ac_attribute12               := FND_API.G_MISS_CHAR;
    x_ac_attribute13               := FND_API.G_MISS_CHAR;
    x_ac_attribute14               := FND_API.G_MISS_CHAR;
    x_ac_attribute15               := FND_API.G_MISS_CHAR;

        stmt:=35;
-- New  columns names added
	x_list_header_id	:= FND_API.G_MISS_NUM;
	x_list_line_id	:= FND_API.G_MISS_NUM;
	x_list_line_type_code := FND_API.G_MISS_CHAR;
	x_modifier_mechanism_type_code := FND_API.G_MISS_CHAR;
	x_modified_from	:= FND_API.G_MISS_CHAR;
	x_modified_to	:= FND_API.G_MISS_CHAR;
	x_update_allowed	:= FND_API.G_MISS_CHAR;
	x_updated_flag	:= FND_API.G_MISS_CHAR;
	x_applied_flag	:= FND_API.G_MISS_CHAR;
	x_change_reason_code := FND_API.G_MISS_CHAR;
	x_change_reason_text := FND_API.G_MISS_CHAR;
	x_operand	:= FND_API.G_MISS_NUM;
	x_arithmetic_operator	:= FND_API.G_MISS_CHAR;

	x_adjusted_amount	:= FND_API.G_MISS_NUM;
	x_pricing_phase_id	:= FND_API.G_MISS_NUM;
        x_list_line_no                          := FND_API.G_MISS_CHAR;
        x_source_system_code                    := FND_API.G_MISS_CHAR;
        x_benefit_qty                           := FND_API.G_MISS_NUM;
        x_benefit_uom_code                      := FND_API.G_MISS_CHAR;
        x_print_on_invoice_flag                 := FND_API.G_MISS_CHAR;
        x_expiration_date                       := FND_API.G_MISS_DATE;
        x_rebate_transaction_type_code          := FND_API.G_MISS_CHAR;
        x_rebate_transaction_reference          := FND_API.G_MISS_CHAR;
        x_rebate_payment_system_code            := FND_API.G_MISS_CHAR;
        x_redeemed_date                         := FND_API.G_MISS_DATE;
        x_redeemed_flag                         := FND_API.G_MISS_CHAR;
        x_accrual_flag                          := FND_API.G_MISS_CHAR;
        x_invoiced_flag                         := FND_API.G_MISS_CHAR;
        x_estimated_flag                        := FND_API.G_MISS_CHAR;
        x_credit_or_charge_flag                 := FND_API.G_MISS_CHAR;
        x_include_on_returns_flag               := FND_API.G_MISS_CHAR;
        x_charge_type_code                      := FND_API.G_MISS_CHAR;
        x_charge_subtype_code                   := FND_API.G_MISS_CHAR;

    --uom begin
	   x_operand_per_pqty := FND_API.G_MISS_NUM;
	   x_adjusted_amount_per_pqty := FND_API.G_MISS_NUM;
    --uom end

    -- Load display out parameters if any
    stmt:=40;
    l_Header_Adj_val_rec := OE_Header_Adj_Util.Get_Values
    (   p_Header_Adj_rec              => l_x_Header_Adj_rec
    ,   p_old_Header_Adj_rec          => l_Header_Adj_rec
    );
   stmt:=45;
-- New column changes :: new code

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.list_header_id,
                            l_Header_Adj_rec.list_header_id)
    THEN
        x_list_header_id := l_x_Header_Adj_rec.list_header_id;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.list_line_id,
                            l_Header_Adj_rec.list_line_id)
    THEN
        x_list_line_id := l_x_Header_Adj_rec.list_line_id;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.list_line_type_code,

                            l_Header_Adj_rec.list_line_type_code)
    THEN
        x_list_line_type_code := l_x_Header_Adj_rec.list_line_type_code;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.modifier_mechanism_type_code,

                            l_Header_Adj_rec.modifier_mechanism_type_code)
    THEN
        x_modifier_mechanism_type_code := l_x_Header_Adj_rec.modifier_mechanism_type_code;
    END IF;

    stmt:=50;
    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.update_allowed,

                            l_Header_Adj_rec.update_allowed)
    THEN
        x_update_allowed := l_x_Header_Adj_rec.update_allowed;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.updated_flag,

                            l_Header_Adj_rec.updated_flag)
    THEN
        x_updated_flag := l_x_Header_Adj_rec.updated_flag;
    END IF;
    stmt:=55;
    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.modified_from,

                            l_Header_Adj_rec.modified_from)
    THEN
        x_modified_from := l_x_Header_Adj_rec.modified_from;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.modified_to,

                            l_Header_Adj_rec.modified_to)
    THEN
        x_modified_to := l_x_Header_Adj_rec.modified_to;
    END IF;
    stmt:=60;
    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.applied_flag,
                            l_Header_Adj_rec.applied_flag)
    THEN
        x_applied_flag := l_x_Header_Adj_rec.applied_flag;
    END IF;
    stmt:=65;
    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.change_reason_code,
                            l_Header_Adj_rec.change_reason_code)
    THEN
        x_change_reason_code := l_x_Header_Adj_rec.change_reason_code;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.change_reason_text,
                            l_Header_Adj_rec.change_reason_text)
    THEN
        x_change_reason_text := l_x_Header_Adj_rec.change_reason_text;
    END IF;
    stmt:=70;
    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.operand,
                            l_Header_Adj_rec.operand)
    THEN
        x_operand := l_x_Header_Adj_rec.operand;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.arithmetic_operator,
                            l_Header_Adj_rec.arithmetic_operator)
    THEN
        x_arithmetic_operator := l_x_Header_Adj_rec.arithmetic_operator;
    END IF;


    --  Return changed attributes.

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.attribute1,
                            l_Header_Adj_rec.attribute1)
    THEN
        x_attribute1 := l_x_Header_Adj_rec.attribute1;
    END IF;
    stmt:=75;
    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.attribute10,
                            l_Header_Adj_rec.attribute10)
    THEN
        x_attribute10 := l_x_Header_Adj_rec.attribute10;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.attribute11,
                            l_Header_Adj_rec.attribute11)
    THEN
        x_attribute11 := l_x_Header_Adj_rec.attribute11;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.attribute12,
                            l_Header_Adj_rec.attribute12)
    THEN
        x_attribute12 := l_x_Header_Adj_rec.attribute12;
    END IF;
    stmt:=80;
    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.attribute13,
                            l_Header_Adj_rec.attribute13)
    THEN
        x_attribute13 := l_x_Header_Adj_rec.attribute13;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.attribute14,
                            l_Header_Adj_rec.attribute14)
    THEN
        x_attribute14 := l_x_Header_Adj_rec.attribute14;
    END IF;
    stmt:=85;
    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.attribute15,
                            l_Header_Adj_rec.attribute15)
    THEN
        x_attribute15 := l_x_Header_Adj_rec.attribute15;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.attribute2,
                            l_Header_Adj_rec.attribute2)
    THEN
        x_attribute2 := l_x_Header_Adj_rec.attribute2;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.attribute3,
                            l_Header_Adj_rec.attribute3)
    THEN
        x_attribute3 := l_x_Header_Adj_rec.attribute3;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.attribute4,
                            l_Header_Adj_rec.attribute4)
    THEN
        x_attribute4 := l_x_Header_Adj_rec.attribute4;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.attribute5,
                            l_Header_Adj_rec.attribute5)
    THEN
        x_attribute5 := l_x_Header_Adj_rec.attribute5;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.attribute6,
                            l_Header_Adj_rec.attribute6)
    THEN
        x_attribute6 := l_x_Header_Adj_rec.attribute6;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.attribute7,
                            l_Header_Adj_rec.attribute7)
    THEN
        x_attribute7 := l_x_Header_Adj_rec.attribute7;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.attribute8,
                            l_Header_Adj_rec.attribute8)
    THEN
        x_attribute8 := l_x_Header_Adj_rec.attribute8;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.attribute9,
                            l_Header_Adj_rec.attribute9)
    THEN
        x_attribute9 := l_x_Header_Adj_rec.attribute9;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.automatic_flag,
                            l_Header_Adj_rec.automatic_flag)
    THEN
        x_automatic_flag := l_x_Header_Adj_rec.automatic_flag;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.context,
                            l_Header_Adj_rec.context)
    THEN
        x_context := l_x_Header_Adj_rec.context;
    END IF;
    stmt:=95;
    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.discount_id,
                            l_Header_Adj_rec.discount_id)
    THEN
        x_discount_id := l_x_Header_Adj_rec.discount_id;
        x_discount := l_Header_Adj_val_rec.discount;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.discount_line_id,
                            l_Header_Adj_rec.discount_line_id)
    THEN
        x_discount_line_id := l_x_Header_Adj_rec.discount_line_id;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.header_id,
                            l_Header_Adj_rec.header_id)
    THEN
        x_header_id := l_x_Header_Adj_rec.header_id;
    END IF;
    stmt:=100;
    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.line_id,
                            l_Header_Adj_rec.line_id)
    THEN
        x_line_id := l_x_Header_Adj_rec.line_id;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.percent,
                            l_Header_Adj_rec.percent)
    THEN
        x_percent := l_x_Header_Adj_rec.percent;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.price_adjustment_id,
                            l_Header_Adj_rec.price_adjustment_id)
    THEN
        x_price_adjustment_id := l_x_Header_Adj_rec.price_adjustment_id;
    END IF;


    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.adjusted_amount,
                            l_Header_Adj_rec.adjusted_amount)
    THEN
        x_adjusted_amount := l_x_Header_Adj_rec.adjusted_amount;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.pricing_phase_id,
                            l_Header_Adj_rec.pricing_phase_id)
    THEN
        x_pricing_phase_id := l_x_Header_Adj_rec.pricing_phase_id;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.list_line_no, l_Header_Adj_rec.list_line_no)
    THEN
       x_list_line_no := l_x_Header_Adj_rec.list_line_no;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.source_system_code, l_Header_Adj_rec.source_system_code)
    THEN
       x_source_system_code := l_x_Header_Adj_rec.source_system_code;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.benefit_qty, l_Header_Adj_rec.benefit_qty)
    THEN
       x_benefit_qty := l_x_Header_Adj_rec.benefit_qty;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.benefit_uom_code, l_Header_Adj_rec.benefit_uom_code)
    THEN
       x_benefit_uom_code := l_x_Header_Adj_rec.benefit_uom_code;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.print_on_invoice_flag, l_Header_Adj_rec.print_on_invoice_flag)
    THEN
       x_print_on_invoice_flag := l_x_Header_Adj_rec.print_on_invoice_flag;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.expiration_date, l_Header_Adj_rec.expiration_date)
    THEN
       x_expiration_date := l_x_Header_Adj_rec.expiration_date;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.rebate_transaction_type_code, l_Header_Adj_rec.rebate_transaction_type_code)
    THEN
       x_rebate_transaction_type_code := l_x_Header_Adj_rec.rebate_transaction_type_code;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.rebate_transaction_reference, l_Header_Adj_rec.rebate_transaction_reference)
    THEN
       x_rebate_transaction_reference := l_x_Header_Adj_rec.rebate_transaction_reference;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.rebate_payment_system_code, l_Header_Adj_rec.rebate_payment_system_code)
    THEN
       x_rebate_payment_system_code := l_x_Header_Adj_rec.rebate_payment_system_code;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.redeemed_date, l_Header_Adj_rec.redeemed_date)
    THEN
       x_redeemed_date := l_x_Header_Adj_rec.redeemed_date;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.redeemed_flag, l_Header_Adj_rec.redeemed_flag)
    THEN
       x_redeemed_flag := l_x_Header_Adj_rec.redeemed_flag;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.accrual_flag, l_Header_Adj_rec.accrual_flag)
    THEN
       x_accrual_flag := l_x_Header_Adj_rec.accrual_flag;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.estimated_flag, l_Header_Adj_rec.estimated_flag)
    THEN
       x_estimated_flag := l_x_Header_Adj_rec.estimated_flag;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.invoiced_flag, l_Header_Adj_rec.invoiced_flag)
    THEN
       x_invoiced_flag := l_x_Header_Adj_rec.invoiced_flag;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.charge_type_code, l_Header_Adj_rec.charge_type_code)
    THEN
       x_charge_type_code := l_x_Header_Adj_rec.charge_type_code;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.charge_subtype_code, l_Header_Adj_rec.charge_subtype_code)
    THEN
       x_charge_subtype_code := l_x_Header_Adj_rec.charge_subtype_code;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.credit_or_charge_flag, l_Header_Adj_rec.credit_or_charge_flag)
    THEN
       x_credit_or_charge_flag := l_x_Header_Adj_rec.credit_or_charge_flag;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.include_on_returns_flag, l_Header_Adj_rec.include_on_returns_flag)
    THEN
       x_include_on_returns_flag := l_x_Header_Adj_rec.include_on_returns_flag;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.ac_attribute1,
                            l_Header_Adj_rec.ac_attribute1)
    THEN
        x_ac_attribute1 := l_x_Header_Adj_rec.ac_attribute1;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.ac_attribute10,
                            l_Header_Adj_rec.ac_attribute10)
    THEN
        x_ac_attribute10 := l_x_Header_Adj_rec.ac_attribute10;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.ac_attribute11,
                            l_Header_Adj_rec.ac_attribute11)
    THEN
        x_ac_attribute11 := l_x_Header_Adj_rec.ac_attribute11;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.ac_attribute12,
                            l_Header_Adj_rec.ac_attribute12)
    THEN
        x_ac_attribute12 := l_x_Header_Adj_rec.ac_attribute12;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.ac_attribute13,
                            l_Header_Adj_rec.ac_attribute13)
    THEN
        x_ac_attribute13 := l_x_Header_Adj_rec.ac_attribute13;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.ac_attribute14,
                            l_Header_Adj_rec.ac_attribute14)
    THEN
        x_ac_attribute14 := l_x_Header_Adj_rec.ac_attribute14;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.ac_attribute15,
                            l_Header_Adj_rec.ac_attribute15)
    THEN
        x_ac_attribute15 := l_x_Header_Adj_rec.ac_attribute15;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.ac_attribute2,
                            l_Header_Adj_rec.ac_attribute2)
    THEN
        x_ac_attribute2 := l_x_Header_Adj_rec.ac_attribute2;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.ac_attribute3,
                            l_Header_Adj_rec.ac_attribute3)
    THEN
        x_ac_attribute3 := l_x_Header_Adj_rec.ac_attribute3;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.ac_attribute4,
                            l_Header_Adj_rec.ac_attribute4)
    THEN
        x_ac_attribute4 := l_x_Header_Adj_rec.ac_attribute4;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.ac_attribute5,
                            l_Header_Adj_rec.ac_attribute5)
    THEN
        x_ac_attribute5 := l_x_Header_Adj_rec.ac_attribute5;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.ac_attribute6,
                            l_Header_Adj_rec.ac_attribute6)
    THEN
        x_ac_attribute6 := l_x_Header_Adj_rec.ac_attribute6;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.ac_attribute7,
                            l_Header_Adj_rec.ac_attribute7)
    THEN
        x_ac_attribute7 := l_x_Header_Adj_rec.ac_attribute7;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.ac_attribute8,
                            l_Header_Adj_rec.ac_attribute8)
    THEN
        x_ac_attribute8 := l_x_Header_Adj_rec.ac_attribute8;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.ac_attribute9,
                            l_Header_Adj_rec.ac_attribute9)
    THEN
        x_ac_attribute9 := l_x_Header_Adj_rec.ac_attribute9;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.ac_context,
                            l_Header_Adj_rec.ac_context)
    THEN
        x_ac_context := l_x_Header_Adj_rec.ac_context;
    END IF;
    stmt:=120;
    --uom begin
    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.operand_per_pqty,
                            l_Header_Adj_rec.operand_per_pqty)
    THEN
	   x_operand_per_pqty := l_x_Header_Adj_rec.operand_per_pqty;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Header_Adj_rec.adjusted_amount_per_pqty,
  				        l_Header_Adj_rec.adjusted_amount_per_pqty)
    THEN
	 x_adjusted_amount_per_pqty := l_x_Header_Adj_rec.adjusted_amount_per_pqty;
    END IF;

   --uom end
    stmt:=130;

    --  Write to cache.

    Write_Header_Adj
    (   p_Header_Adj_rec              => l_x_Header_Adj_rec
    );

   stmt:=140;
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
        oe_debug_pub.add(  'EXITING OE_OE_FORM_HEADER_ADJ.CHANGE_ATTRIBUTES' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

/* Msg is commented out nocopy for the bug #2485694 */

         /* OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attributes'||stmt
            ); */

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  G_PKG_NAME|| 'CHANGE_ATTRIBUTES'||STMT , 1 ) ;
        END IF;

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'STMT:'||STMT ) ;
        END IF;
	ROLLBACK TO SAVEPOINT change_attributes;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'STMT:'||STMT ) ;
           END IF;
	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'STMT:'||STMT ) ;
         END IF;
         OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attributes:'||stmt
            );
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

	ROLLBACK TO SAVEPOINT change_attributes;

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attributes:'||stmt
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

	ROLLBACK TO SAVEPOINT change_attributes;

END Change_Attributes;


--  Procedure       Validate_And_Write
--


PROCEDURE Validate_And_Write
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_price_adjustment_id           IN  NUMBER
, x_creation_date OUT NOCOPY DATE

, x_created_by OUT NOCOPY NUMBER

, x_last_update_date OUT NOCOPY DATE

, x_last_updated_by OUT NOCOPY NUMBER

, x_last_update_login OUT NOCOPY NUMBER

,   p_ok_flag			    		 IN  VARCHAR2
, x_program_id OUT NOCOPY NUMBER

, x_program_application_id OUT NOCOPY NUMBER

, x_program_update_date OUT NOCOPY DATE

, x_request_id OUT NOCOPY NUMBER

, x_lock_control OUT NOCOPY NUMBER

)
IS
l_request_rec		      OE_order_pub.Request_Rec_Type;
l_request_tbl		      OE_order_pub.Request_Tbl_Type;
l_Header_Adj_rec              OE_Order_PUB.Header_Adj_Rec_Type;
l_old_Header_Adj_rec          OE_Order_PUB.Header_Adj_Rec_Type;
l_x_old_Header_Adj_rec          OE_Order_PUB.Header_Adj_Rec_Type;
l_Header_Adj_tbl              OE_Order_PUB.Header_Adj_Tbl_Type;
l_old_Header_Adj_tbl          OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_old_Header_Adj_tbl          OE_Order_PUB.Header_Adj_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_action_request_tbl		OE_Order_PUB.Request_Tbl_Type;
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
l_x_Lot_Serial_rec            OE_Order_PUB.Lot_Serial_Rec_Type;
l_x_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;

--New out parameters
l_x_Header_price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;

l_x_Line_price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
    --3340264{
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    --3340264}
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_HEADER_ADJ.VALIDATE_AND_WRITE' , 1 ) ;
    END IF;

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
    l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_HEADER_ADJ;


    --  Instruct API to retain its caches
    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;


    -- Save point to rollback to if there were
    -- any errors
    SAVEPOINT validate_and_write;


    --  Read Header_Adj from cache
    Get_Header_Adj
    (   p_db_record                   => TRUE
    ,   p_price_adjustment_id         => p_price_adjustment_id
    ,   x_Header_Adj_Rec			   => l_x_old_Header_Adj_rec
    );

    Get_Header_Adj
    (   p_db_record                   => FALSE
    ,   p_price_adjustment_id         => p_price_adjustment_id
    ,   x_Header_Adj_rec			   => l_x_Header_Adj_rec
    );

    --  Set Operation.
    --3340264{
    IF(l_x_Header_Adj_rec.db_flag= FND_API.G_MISS_CHAR) THEN
       return;
    ELSE
       IF FND_API.To_Boolean(l_x_Header_Adj_rec.db_flag) THEN
          l_x_Header_Adj_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
       ELSE
          l_x_Header_Adj_rec.operation := OE_GLOBALS.G_OPR_CREATE;
       END IF;
    END IF;
    --3340264}

    --  Populate Header_Adj table
    l_x_Header_Adj_tbl(1) := l_x_Header_Adj_rec;
    l_x_old_Header_Adj_tbl(1) := l_x_old_Header_Adj_rec;

    -- Call Oe_Order_Adj_Pvt.Header_Adj
    oe_order_adj_pvt.Header_Adjs
    (	p_init_msg_list	=> FND_API.G_TRUE
    ,	p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL
    ,	p_control_rec		=> l_control_rec
    ,	p_x_header_adj_tbl	=> l_x_Header_Adj_tbl
    ,   p_x_old_header_adj_tbl  => l_x_old_header_adj_tbl
    );

    /***************************************************************
** commented out nocopy for performance changes **

    --  Call OE_Order_PVT.Process_order
    OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    --,   p_request_tbl		      => l_request_tbl
    ,   p_Header_Adj_tbl              => l_Header_Adj_tbl
    ,   p_old_Header_Adj_tbl          => l_old_Header_Adj_tbl
    ,   x_header_rec                  => l_x_header_rec
    ,   x_Header_Adj_tbl              => l_x_Header_Adj_tbl
 -- New Parameters
    ,   x_Header_price_Att_tbl         => l_x_Header_price_Att_tbl
    ,   x_Header_Adj_Att_tbl           => l_x_Header_Adj_Att_tbl
    ,   x_Header_Adj_Assoc_tbl         => l_x_Header_Adj_Assoc_tbl

    ,   x_Header_Scredit_tbl          => l_x_Header_Scredit_tbl
    ,   x_line_tbl                    => l_x_line_tbl
    ,   x_Line_Adj_tbl                => l_x_Line_Adj_tbl

-- New Parameters
    ,   x_Line_price_Att_tbl          => l_x_Line_price_Att_tbl
    ,   x_Line_Adj_Att_tbl            => l_x_Line_Adj_Att_tbl
    ,   x_Line_Adj_Assoc_tbl          => l_x_Line_Adj_Assoc_tbl

    ,   x_Line_Scredit_tbl            => l_x_Line_Scredit_tbl
    ,   x_Lot_Serial_tbl              => l_x_Lot_Serial_tbl
    ,	x_action_request_tbl	      => l_action_request_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    **********************************************************/

    --  Load OUT parameters.
    l_x_Header_Adj_rec := l_x_Header_Adj_tbl(1);

    IF l_x_header_adj_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_x_header_adj_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    /*******
    Oe_Order_Pvt.Process_Requests_And_Notify
    (	p_process_requests	=> FALSE
    ,	p_notify		=> TRUE
    ,	p_header_adj_tbl	=> l_x_header_adj_tbl
    ,	p_old_header_adj_tbl	=> l_x_old_header_adj_tbl
    ,	x_return_status		=> l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    *******/

    x_lock_control := l_x_Header_Adj_rec.lock_control;

	OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
          (p_request_type   => OE_GLOBALS.G_CHECK_PERCENTAGE
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- fixed bug 3271297
       OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
          (p_request_type   => OE_GLOBALS.G_VERIFY_PAYMENT
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;

	/*****
	IF p_ok_flag = 'Y' THEN
	OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
          (p_request_type   => OE_GLOBALS.G_PRICE_ADJ
          ,p_delete        => FND_API.G_TRUE
          ,x_return_status => l_return_status
          );
       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
       END IF;
	END IF;
	******/

    x_creation_date                := l_x_Header_Adj_rec.creation_date;
    x_created_by                   := l_x_Header_Adj_rec.created_by;
    x_last_update_date             := l_x_Header_Adj_rec.last_update_date;
    x_last_updated_by              := l_x_Header_Adj_rec.last_updated_by;
    x_last_update_login            := l_x_Header_Adj_rec.last_update_login;
    x_program_id            		:= l_x_Line_Adj_rec.program_id;
    x_program_application_id      	:= l_x_Line_Adj_rec.program_application_id;
    x_program_update_date      	:= l_x_Line_Adj_rec.program_update_date;
    x_request_id      			:= l_x_Line_Adj_rec.request_id;


    --  Clear Header_Adj record cache
    Clear_Header_Adj;


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
        oe_debug_pub.add(  'EXITING OE_OE_FORM_HEADER_ADJ.VALIDATE_AND_WRITE' , 1 ) ;
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

      ROLLBACK TO SAVEPOINT validate_and_write;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

	ROLLBACK TO SAVEPOINT validate_and_write;

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

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

	ROLLBACK TO SAVEPOINT validate_and_write;

END Validate_And_Write;


--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_price_adjustment_id           IN  NUMBER
, p_change_reason_code            IN  VARCHAR2 Default Null
, p_change_comments               IN  VARCHAR2 Default Null
)
IS
l_Header_Adj_rec              OE_Order_PUB.Header_Adj_Rec_Type;
l_Header_Adj_tbl              OE_Order_PUB.Header_Adj_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_action_request_tbl		OE_Order_PUB.Request_Tbl_Type;
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_rec            OE_Order_PUB.Header_Adj_Rec_Type;
l_x_old_Header_Adj_rec            OE_Order_PUB.Header_Adj_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_old_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_rec        OE_Order_PUB.Header_Scredit_Rec_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_rec                  OE_Order_PUB.Line_Rec_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_rec          OE_Order_PUB.Line_Scredit_Rec_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_Lot_Serial_rec            OE_Order_PUB.Lot_Serial_Rec_Type;
l_x_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;


--New out parameters

l_x_Header_price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;

l_x_Line_price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_HEADER_ADJ.DELETE_ROW' , 1 ) ;
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
    Get_Header_Adj
    (   p_db_record                   => TRUE
    ,   p_price_adjustment_id         => p_price_adjustment_id
    ,   x_Header_Adj_rec			   => l_x_Header_Adj_rec
    );


    --  Set Operation.
    l_x_Header_Adj_rec.operation := OE_GLOBALS.G_OPR_DELETE;


    --  Populate Header_Adj table
    l_x_Header_Adj_tbl(1) := l_x_Header_Adj_rec;
    l_x_Header_Adj_tbl(1).change_reason_code := p_change_reason_code;
    l_x_Header_Adj_tbl(1).change_reason_text := p_change_comments;

    -- Call Oe_Order_Adj_Pvt.Header_Adj
    oe_order_adj_pvt.Header_Adjs
    (	p_init_msg_list	=> FND_API.G_TRUE
    ,	p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL
    ,	p_control_rec		=> l_control_rec
    ,	p_x_header_adj_tbl	=> l_x_Header_Adj_tbl
    ,     p_x_old_header_adj_tbl  => l_x_old_header_adj_tbl
    );

    /*****************************************************************
    --  Call OE_Order_PVT.Process_order
    OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_Header_Adj_tbl              => l_x_Header_Adj_tbl
    ,   p_x_header_rec                  => l_x_header_rec
 --   ,   x_Header_Adj_tbl              => l_x_Header_Adj_tbl
-- New Parameters
    ,   p_x_Header_price_Att_tbl         => l_x_Header_price_Att_tbl
    ,   p_x_Header_Adj_Att_tbl           => l_x_Header_Adj_Att_tbl
    ,   p_x_Header_Adj_Assoc_tbl         => l_x_Header_Adj_Assoc_tbl

    ,   p_x_Header_Scredit_tbl          => l_x_Header_Scredit_tbl
    ,   p_x_line_tbl                    => l_x_line_tbl
    ,   p_x_Line_Adj_tbl                => l_x_Line_Adj_tbl

-- New Parameters
    ,   p_x_Line_price_Att_tbl          => l_x_Line_price_Att_tbl
    ,   p_x_Line_Adj_Att_tbl            => l_x_Line_Adj_Att_tbl
    ,   p_x_Line_Adj_Assoc_tbl          => l_x_Line_Adj_Assoc_tbl

    ,   p_x_Line_Scredit_tbl            => l_x_Line_Scredit_tbl
    ,   p_x_Lot_Serial_tbl              => l_x_Lot_Serial_tbl
    ,	p_x_action_request_tbl	      => l_action_request_tbl
    );
    *********************************************************************/

    --  Load OUT parameters.
    l_x_Header_Adj_rec := l_x_Header_Adj_tbl(1);

    IF l_x_Header_Adj_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_x_Header_Adj_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear Header_Adj record cache
    Clear_Header_Adj;


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
        oe_debug_pub.add(  'EXITING OE_OE_FORM_HEADER_ADJ.DELETE_ROW' , 1 ) ;
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


--  Procedure       Process_Entity
--


PROCEDURE Process_Delayed_Requests
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_header_id			    IN  NUMBER
)
IS
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_action_request_tbl		OE_Order_PUB.Request_Tbl_Type;
l_request_rec		      OE_Order_Pub.Request_Rec_Type;
l_request_tbl		      OE_Order_Pub.Request_Tbl_Type;
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
l_x_Lot_Serial_rec            OE_Order_PUB.Lot_Serial_Rec_Type;
l_x_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;

--New out parameters
l_x_Header_price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;

l_x_Line_price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_x_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_x_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_HEADER_ADJ.PROCESS_DELAYED_REQUESTS' , 1 ) ;
    END IF;

   /*
	OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
		(p_request_type   => OE_GLOBALS.G_PRICE_ADJ
		,p_delete        => FND_API.G_TRUE
		,x_return_status => l_return_status
		);
	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

     -- process delayed requests for tax calculation.
	OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
		(p_request_type   => OE_GLOBALS.G_TAX_LINE
		,p_delete        => FND_API.G_TRUE
		,x_return_status => l_return_status
		);
	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

        oe_debug_pub.ADD('Processing delayed request for Verify Payment for price adjustments changes.', 3);
        OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
		(p_request_type   => OE_GLOBALS.G_VERIFY_PAYMENT
		,p_delete        => FND_API.G_TRUE
		,x_return_status => l_return_status
		);
     */
     Oe_Order_Pvt.Process_Requests_And_Notify
    (	p_process_requests	=> TRUE
    ,	p_notify			=> TRUE
    ,   p_process_ack           => TRUE
    ,	x_return_status	=> l_return_status
    );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR;
	END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_HEADER_ADJ.PROCESS_DELAYED_REQUESTS' , 1 ) ;
    END IF;
Return;


/*

    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_HEADER_ADJ;

    l_control_rec.check_security       := FALSE;
    l_control_rec.clear_dependents     := FALSE;
    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;


    -- Assign requests in the order that is to be executed
    l_request_rec.request_type	:= OE_GLOBALS.G_CHECK_PERCENTAGE;

    -- 1905650
    -- G_PRICE_ADJ request should be logged using entity ALL
    l_request_rec.entity_code	:= OE_GLOBALS.G_ENTITY_ALL;
    l_request_rec.entity_id	:= p_header_id;
    l_request_tbl(1) := l_request_rec;

    l_request_rec.request_type	:= OE_GLOBALS.G_PRICE_ADJ;
    l_request_rec.entity_code	:= OE_GLOBALS.G_ENTITY_HEADER_ADJ;
    l_request_rec.entity_id	:= p_header_id;
    l_request_tbl(2) := l_request_rec;


    --  Call OE_Order_PVT.Process_order

    OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_action_request_tbl	      => l_request_tbl
    ,   x_header_rec                  => l_x_header_rec
    ,   x_Header_Adj_tbl              => l_x_Header_Adj_tbl

-- New Parameters
    ,   x_Header_price_Att_tbl         => l_x_Header_price_Att_tbl
    ,   x_Header_Adj_Att_tbl           => l_x_Header_Adj_Att_tbl
    ,   x_Header_Adj_Assoc_tbl         => l_x_Header_Adj_Assoc_tbl

    ,   x_Header_Scredit_tbl          => l_x_Header_Scredit_tbl
    ,   x_line_tbl                    => l_x_line_tbl
    ,   x_Line_Adj_tbl                => l_x_Line_Adj_tbl

-- New Parameters
    ,   x_Line_price_Att_tbl          => l_x_Line_price_Att_tbl
    ,   x_Line_Adj_Att_tbl            => l_x_Line_Adj_Att_tbl
    ,   x_Line_Adj_Assoc_tbl          => l_x_Line_Adj_Assoc_tbl

    ,   x_Line_Scredit_tbl            => l_x_Line_Scredit_tbl
    ,   x_Lot_Serial_tbl              => l_x_Lot_Serial_tbl
    ,	x_action_request_tbl	      => l_action_request_tbl
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

    oe_debug_pub.add('Exiting OE_OE_FORM_HEADER_ADJ.PROCESS_DELAYED_REQUESTS', 1);

*/

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

END Process_Delayed_Requests;

--  Procedure       lock_Row
--


PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_price_adjustment_id	IN NUMBER
,   p_lock_control		 	IN  NUMBER
)
IS
l_return_status               VARCHAR2(1);
l_Header_Adj_rec              OE_Order_PUB.Header_Adj_Rec_Type;
l_Header_Adj_tbl              OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_rec            OE_Order_PUB.Header_Adj_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_HEADER_ADJ.LOCK_ROW' , 1 ) ;
    END IF;

    --  Load Header_Adj record

    l_x_Header_Adj_rec.operation := OE_GLOBALS.G_OPR_LOCK;

    l_x_Header_Adj_rec.lock_control := p_lock_control;
    l_x_Header_Adj_rec.price_adjustment_id := p_price_adjustment_id;

    OE_Header_Adj_Util.Lock_Row
    ( x_return_status	=> l_return_status
    , p_x_header_adj_rec	=> l_x_header_adj_rec
    );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.
        l_x_Header_Adj_rec.db_flag := FND_API.G_TRUE;

        Write_Header_Adj
        (   p_Header_Adj_rec              => l_x_Header_Adj_rec
        ,   p_db_record                   => TRUE
        );

    END IF;


    --  Set return status.
    x_return_status := l_return_status;


    --  Get message count and data
    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_HEADER_ADJ.LOCK_ROW' , 1 ) ;
    END IF;

EXCEPTION

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

--  Procedures maintaining Header_Adj record cache.

PROCEDURE Write_Header_Adj
(   p_Header_Adj_rec                IN  OE_Order_PUB.Header_Adj_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_HEADER_ADJ.WRITE_HEADER_ADJ' , 1 ) ;
    END IF;

    g_Header_Adj_rec := p_Header_Adj_rec;

    IF p_db_record THEN

        g_db_Header_Adj_rec := p_Header_Adj_rec;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_HEADER_ADJ.WRITE_HEADER_ADJ' , 1 ) ;
    END IF;

END Write_Header_Adj;


PROCEDURE Get_Header_Adj
(   p_db_record               IN  BOOLEAN := FALSE
,   p_price_adjustment_id     IN  NUMBER
,   x_Header_Adj_Rec		IN OUT NOCOPY OE_Order_PUB.Header_Adj_Rec_Type
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_HEADER_ADJ.GET_HEADER_ADJ' , 1 ) ;
    END IF;

    IF  p_price_adjustment_id <> g_Header_Adj_rec.price_adjustment_id
    THEN

        --  Query row from DB

        OE_Header_Adj_Util.Query_Row
        (   p_price_adjustment_id         => p_price_adjustment_id
	,   x_Header_Adj_rec		  => g_Header_Adj_rec
        );

        g_Header_Adj_rec.db_flag       := FND_API.G_TRUE;

        --  Load DB record

        g_db_Header_Adj_rec            := g_Header_Adj_rec;

    END IF;

    IF p_db_record THEN

        -- RETURN g_db_Header_Adj_rec;
        x_header_adj_rec := g_db_Header_Adj_rec;

    ELSE

        -- RETURN g_Header_Adj_rec;
        x_header_adj_rec := g_Header_Adj_rec;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_HEADER_ADJ.GET_HEADER_ADJ' , 1 ) ;
    END IF;

END Get_Header_Adj;


PROCEDURE Clear_Header_Adj
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_HEADER_ADJ.CLEAR_HEADER_ADJ' , 1 ) ;
    END IF;

    g_Header_Adj_rec               := OE_Order_PUB.G_MISS_HEADER_ADJ_REC;
    g_db_Header_Adj_rec            := OE_Order_PUB.G_MISS_HEADER_ADJ_REC;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_HEADER_ADJ.CLEAR_HEADER_ADJ' , 1 ) ;
    END IF;

END Clear_Header_Adj;

END OE_OE_Form_Header_Adj;

/
