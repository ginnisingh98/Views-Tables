--------------------------------------------------------
--  DDL for Package Body OE_OE_FORM_LINE_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_FORM_LINE_ADJ" AS
/* $Header: OEXFLADB.pls 120.2 2006/07/25 11:47:16 ppnair noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_OE_Form_Line_Adj';

--  Global variables holding cached record.

g_Line_Adj_rec     OE_Order_PUB.Line_Adj_Rec_Type
				:= OE_ORDER_PUB.G_MISS_LINE_ADJ_REC;
g_db_Line_Adj_rec  OE_Order_PUB.Line_Adj_Rec_Type
				:= OE_ORDER_PUB.G_MISS_LINE_ADJ_REC;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_Line_Adj
(   p_Line_Adj_rec                  IN  OE_Order_PUB.Line_Adj_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

PROCEDURE Get_Line_Adj
(   p_db_record               IN  BOOLEAN := FALSE
,   p_price_adjustment_id     IN  NUMBER
,   x_Line_Adj_rec			IN OUT NOCOPY OE_Order_PUB.Line_Adj_Rec_Type
);

Procedure Get_Option_Service_Lines(p_top_model_line_id In Number,
                                   p_service_line_id   In Number Default null,
                                   p_mode              In VARCHAR2 Default 'SERVICE',
x_line_id_tbl out nocopy Oe_Order_Adj_Pvt.Index_Tbl_Type);


Procedure Process_Adj(p_parent_adj_rec In Oe_Order_Pub.Line_Adj_Rec_Type,
                      p_line_id_tbl    In Oe_Order_Adj_Pvt.Index_Tbl_Type,
                      p_delete_flag    In Varchar2 default 'N',
                      p_create_adj_no_validate In Boolean Default FALSE);

PROCEDURE Clear_Line_Adj;

--  Global variable holding performed operations.

g_opr__tbl                    OE_Order_PUB.Line_Adj_Tbl_Type;

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_header_id                     IN  NUMBER
,   p_line_id			    		 IN  NUMBER
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

, x_arithmetic_operator OUT NOCOPY VARCHAR2

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
l_Line_Adj_rec                OE_Order_PUB.Line_Adj_Rec_Type;
l_Line_Adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
l_Line_Adj_val_rec            OE_Order_PUB.Line_Adj_Val_Rec_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_action_request_tbl	      OE_Order_PUB.Request_Tbl_Type;
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_rec            OE_Order_PUB.Header_Adj_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_rec        OE_Order_PUB.Header_Scredit_Rec_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_rec                  OE_Order_PUB.Line_Rec_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_x_old_Line_Adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_old_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
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
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_ADJ.DEFAULT_ATTRIBUTES' , 1 ) ;
    END IF;

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

    l_x_old_line_adj_rec := OE_ORDER_PUB.G_MISS_LINE_ADJ_REC;
    l_x_line_adj_rec := OE_ORDER_PUB.G_MISS_LINE_ADJ_REC;

    --  Load IN parameters if any exist
    l_x_Line_adj_rec.header_id	:= p_header_id;
    l_x_Line_adj_rec.line_id		:= p_line_id;


    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.
    l_x_Line_Adj_rec.context                        := NULL;
    l_x_Line_Adj_rec.attribute1                     := NULL;
    l_x_Line_Adj_rec.attribute2                     := NULL;
    l_x_Line_Adj_rec.attribute3                     := NULL;
    l_x_Line_Adj_rec.attribute4                     := NULL;
    l_x_Line_Adj_rec.attribute5                     := NULL;
    l_x_Line_Adj_rec.attribute6                     := NULL;
    l_x_Line_Adj_rec.attribute7                     := NULL;
    l_x_Line_Adj_rec.attribute8                     := NULL;
    l_x_Line_Adj_rec.attribute9                     := NULL;
    l_x_Line_Adj_rec.attribute10                    := NULL;
    l_x_Line_Adj_rec.attribute11                    := NULL;
    l_x_Line_Adj_rec.attribute12                    := NULL;
    l_x_Line_Adj_rec.attribute13                    := NULL;
    l_x_Line_Adj_rec.attribute14                    := NULL;
    l_x_Line_Adj_rec.attribute15                    := NULL;
    l_x_Line_Adj_rec.ac_context                     := NULL;
    l_x_Line_Adj_rec.ac_attribute1                  := NULL;
    l_x_Line_Adj_rec.ac_attribute2                  := NULL;
    l_x_Line_Adj_rec.ac_attribute3                  := NULL;
    l_x_Line_Adj_rec.ac_attribute4                  := NULL;
    l_x_Line_Adj_rec.ac_attribute5                  := NULL;
    l_x_Line_Adj_rec.ac_attribute6                  := NULL;
    l_x_Line_Adj_rec.ac_attribute7                  := NULL;
    l_x_Line_Adj_rec.ac_attribute8                  := NULL;
    l_x_Line_Adj_rec.ac_attribute9                  := NULL;
    l_x_Line_Adj_rec.ac_attribute10                 := NULL;
    l_x_Line_Adj_rec.ac_attribute11                 := NULL;
    l_x_Line_Adj_rec.ac_attribute12                 := NULL;
    l_x_Line_Adj_rec.ac_attribute13                 := NULL;
    l_x_Line_Adj_rec.ac_attribute14                 := NULL;
    l_x_Line_Adj_rec.ac_attribute15                 := NULL;
   /*
   l_x_Line_Adj_rec.list_line_id	:=NULL;
   l_x_Line_Adj_rec.list_line_type_code	:=NULL;
   l_x_Line_Adj_rec.modifier_mechanism_type_code	:=NULL;
   l_x_Line_Adj_rec.updated_flag	:=NULL;
   l_x_Line_Adj_rec.update_allowed	:=NULL;
   l_x_Line_Adj_rec.applied_flag	:=NULL;
   l_x_Line_Adj_rec.change_reason_code	:=NULL;
   l_x_Line_Adj_rec.change_reason_text	:=NULL;
   l_x_Line_Adj_rec.modified_from	:=NULL;
   l_x_Line_Adj_rec.modified_to	:=NULL;
   l_x_Line_Adj_rec.operand	:=NULL;
   l_x_Line_Adj_rec.arithmetic_operator	:=NULL;
  */


    --  Set Operation to Create
    l_x_Line_Adj_rec.operation := OE_GLOBALS.G_OPR_CREATE;

    --  Populate Line_Adj table
    l_x_Line_Adj_tbl(1) := l_x_Line_Adj_rec;
    l_x_old_Line_Adj_tbl(1) := l_x_old_Line_Adj_rec;

    -- Call Oe_Order_Adj_Pvt.Line_Adj
    oe_order_adj_pvt.Line_Adjs
    (	p_init_msg_list	=> FND_API.G_TRUE
    , 	p_validation_level 	=> FND_API.G_VALID_LEVEL_FULL
    ,	p_control_rec		=> l_control_rec
    ,	p_x_line_adj_tbl	=> l_x_Line_Adj_tbl
    ,	p_x_old_line_adj_tbl	=> l_x_old_Line_Adj_tbl
    );

    /*****************************************************************
** commented out nocopy for performance changes **

    --  Call OE_Order_PVT.Process_order
    OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Line_Adj_tbl                => l_Line_Adj_tbl
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
    ,   x_action_request_tbl	      => l_action_request_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    ***********************************************************************/

    --  Unload out tbl
    l_x_Line_Adj_rec := l_x_Line_Adj_tbl(1);

    IF l_x_Line_Adj_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_x_Line_Adj_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --  Load OUT parameters.
    x_price_adjustment_id          := l_x_Line_Adj_rec.price_adjustment_id;
    x_header_id                    := l_x_Line_Adj_rec.header_id;
    x_discount_id                  := l_x_Line_Adj_rec.discount_id;
    x_discount_line_id             := l_x_Line_Adj_rec.discount_line_id;
    x_automatic_flag               := l_x_Line_Adj_rec.automatic_flag;
    x_percent                      := l_x_Line_Adj_rec.percent;
    x_line_id                      := l_x_Line_Adj_rec.line_id;
    x_context                      := l_x_Line_Adj_rec.context;
    x_attribute1                   := l_x_Line_Adj_rec.attribute1;
    x_attribute2                   := l_x_Line_Adj_rec.attribute2;
    x_attribute3                   := l_x_Line_Adj_rec.attribute3;
    x_attribute4                   := l_x_Line_Adj_rec.attribute4;
    x_attribute5                   := l_x_Line_Adj_rec.attribute5;
    x_attribute6                   := l_x_Line_Adj_rec.attribute6;
    x_attribute7                   := l_x_Line_Adj_rec.attribute7;
    x_attribute8                   := l_x_Line_Adj_rec.attribute8;
    x_attribute9                   := l_x_Line_Adj_rec.attribute9;
    x_attribute10                  := l_x_Line_Adj_rec.attribute10;
    x_attribute11                  := l_x_Line_Adj_rec.attribute11;
    x_attribute12                  := l_x_Line_Adj_rec.attribute12;
    x_attribute13                  := l_x_Line_Adj_rec.attribute13;
    x_attribute14                  := l_x_Line_Adj_rec.attribute14;
    x_attribute15                  := l_x_Line_Adj_rec.attribute15;
    x_ac_context                   := l_x_Line_Adj_rec.ac_context;
    x_ac_attribute1                := l_x_Line_Adj_rec.ac_attribute1;
    x_ac_attribute2                := l_x_Line_Adj_rec.ac_attribute2;
    x_ac_attribute3                := l_x_Line_Adj_rec.ac_attribute3;
    x_ac_attribute4                := l_x_Line_Adj_rec.ac_attribute4;
    x_ac_attribute5                := l_x_Line_Adj_rec.ac_attribute5;
    x_ac_attribute6                := l_x_Line_Adj_rec.ac_attribute6;
    x_ac_attribute7                := l_x_Line_Adj_rec.ac_attribute7;
    x_ac_attribute8                := l_x_Line_Adj_rec.ac_attribute8;
    x_ac_attribute9                := l_x_Line_Adj_rec.ac_attribute9;
    x_ac_attribute10               := l_x_Line_Adj_rec.ac_attribute10;
    x_ac_attribute11               := l_x_Line_Adj_rec.ac_attribute11;
    x_ac_attribute12               := l_x_Line_Adj_rec.ac_attribute12;
    x_ac_attribute13               := l_x_Line_Adj_rec.ac_attribute13;
    x_ac_attribute14               := l_x_Line_Adj_rec.ac_attribute14;
    x_ac_attribute15               := l_x_Line_Adj_rec.ac_attribute15;
    x_list_header_id         := l_x_Line_Adj_rec.list_header_id;
    x_list_line_id           := l_x_Line_Adj_rec.list_line_id;
    x_list_line_type_code    := l_x_Line_Adj_rec.list_line_type_code;
    x_modifier_mechanism_type_code     :=
					   l_x_Line_Adj_rec.modifier_mechanism_type_code;
    x_updated_flag      		:= l_x_Line_Adj_rec.updated_flag;
    x_update_allowed    		:= l_x_Line_Adj_rec.update_allowed;
    x_applied_flag           	:= l_x_Line_Adj_rec.applied_flag;
    x_change_reason_code     	:= l_x_Line_Adj_rec.change_reason_code;
    x_change_reason_text     	:= l_x_Line_Adj_rec.change_reason_text;
    x_modified_from          	:= l_x_Line_Adj_rec.modified_from;
    x_modified_to       		:= l_x_Line_Adj_rec.modified_to;
    x_operand       		:= l_x_Line_Adj_rec.operand;
    x_arithmetic_operator     := l_x_Line_Adj_rec.arithmetic_operator;
    x_adjusted_amount       	:= l_x_Line_Adj_rec.adjusted_amount;
    x_pricing_phase_id       	:= l_x_Line_Adj_rec.pricing_phase_id;
    x_list_line_no           	:= l_x_Line_Adj_rec.list_line_no;
    x_source_system_code     	:= l_x_Line_Adj_rec.source_system_code;
    x_benefit_qty            	:= l_x_Line_Adj_rec.benefit_qty;
    x_benefit_uom_code       	:= l_x_Line_Adj_rec.benefit_uom_code;
    x_print_on_invoice_flag  	:= l_x_Line_Adj_rec.print_on_invoice_flag;
    x_expiration_date        	:= l_x_Line_Adj_rec.expiration_date;
    x_rebate_transaction_type_code  := l_x_Line_Adj_rec.rebate_transaction_type_code;
    x_rebate_transaction_reference  := l_x_Line_Adj_rec.rebate_transaction_reference;
    x_rebate_payment_system_code    := l_x_Line_Adj_rec.rebate_payment_system_code;
    x_redeemed_date          	:= l_x_Line_Adj_rec.redeemed_date;
    x_redeemed_flag          	:= l_x_Line_Adj_rec.redeemed_flag;
    x_accrual_flag           	:= l_x_Line_Adj_rec.accrual_flag;
    x_estimated_flag         	:= l_x_Line_Adj_rec.estimated_flag;
    x_invoiced_flag          	:= l_x_Line_Adj_rec.invoiced_flag;
    x_charge_type_code       	:= l_x_Line_Adj_rec.charge_type_code;
    x_charge_subtype_code    	:= l_x_Line_Adj_rec.charge_subtype_code;
    x_credit_or_charge_flag  	:= l_x_Line_Adj_rec.credit_or_charge_flag;
    x_include_on_returns_flag := l_x_Line_Adj_rec.include_on_returns_flag;
   --uom begin
     x_operand_per_pqty        := l_x_line_adj_rec.operand_per_pqty;
	x_adjusted_amount_per_pqty:= l_x_line_adj_rec.adjusted_amount_per_pqty;
   --uom end

    --  Load display out parameters if any


    l_Line_Adj_val_rec := OE_Line_Adj_Util.Get_Values
    (   p_Line_Adj_rec                => l_x_Line_Adj_rec
    );
    x_discount                     := l_Line_Adj_val_rec.discount;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_Line_Adj_rec.db_flag := FND_API.G_FALSE;

    Write_Line_Adj
    (   p_Line_Adj_rec                => l_x_Line_Adj_rec
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

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE_ADJ.DEFAULT_ATTRIBUTES' , 1 ) ;
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
            ,   'Default_Attributes'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Default_Attributes;

--  Procedure   :   Change_Attributes
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

, x_arithmetic_operator OUT NOCOPY VARCHAR2

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
, x_operand_per_pqty OUT NOCOPY NUMBER

, x_adjusted_amount_per_pqty OUT NOCOPY NUMBER

--uom end
)
IS
l_request_rec		      OE_Order_Pub.Request_Rec_Type;
l_request_tbl		      OE_Order_Pub.Request_Tbl_Type;
l_Line_Adj_rec                OE_Order_PUB.Line_Adj_Rec_Type;
l_Line_Adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
l_Line_Adj_val_rec            OE_Order_PUB.Line_Adj_Val_Rec_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_action_request_tbl	      OE_Order_PUB.Request_Tbl_Type;
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_rec            OE_Order_PUB.Header_Adj_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_rec        OE_Order_PUB.Header_Scredit_Rec_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_rec                  OE_Order_PUB.Line_Rec_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_x_old_Line_Adj_rec            OE_Order_PUB.Line_Adj_Rec_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_old_Line_Adj_tbl            OE_Order_PUB.Line_Adj_Tbl_Type;
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

--1790502
l_line_rec    OE_Order_Pub.Line_Rec_Type;
l_line_id_tbl OE_Order_Adj_Pvt.Index_Tbl_Type;
l_top_model_line_id Number;

l_profile_cascade_adjustments Varchar2(1):= NVL(FND_PROFILE.VALUE('ONT_CASCADE_ADJUSTMENTS'),'N');
l_orcl_customization  Varchar2(1):= NVL(FND_PROFILE.VALUE('ONT_ACTIVATE_ORACLE_CUSTOMIZATION'),'N');
l_date_format                 Varchar2(22) := 'DD-MON-YYYY HH24:MI:SS';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_ADJ.CHANGE_ATTRIBUTES' , 1 ) ;
    END IF;

    --initialize record.
    l_line_rec.line_id := NULL;
    l_line_id_tbl.delete;

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
    l_control_rec.process_entity      := OE_GLOBALS.G_ENTITY_LINE_ADJ;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    -- Save point to rollback to if there were
    -- any errors
    SAVEPOINT change_attributes;

    --  Read Line_Adj from cache

    Get_Line_Adj
    (   p_db_record                => FALSE
    ,   p_price_adjustment_id      => p_price_adjustment_id
    ,   x_Line_Adj_rec			=> l_x_Line_Adj_rec
    );

    l_x_old_Line_Adj_rec           := l_x_Line_Adj_rec;

    IF p_attr_id = OE_Line_Adj_Util.G_PRICE_ADJUSTMENT THEN
        l_x_Line_Adj_rec.price_adjustment_id := TO_NUMBER(p_attr_value1);
    ELSIF p_attr_id = OE_Line_Adj_Util.G_HEADER THEN
        l_x_Line_Adj_rec.header_id := TO_NUMBER(p_attr_value1);


    -- The following has been done because a discount can only
    -- be uniquely identified with a discount_id and discount_line_id
    --
    -- The form will now be sending in both attribute_values
    --
    -- It ATTR_ID       is discount_id then
    --    ATTR_VALUE1   is discount_id
    --    ATTR_VALUE2   is discount_line_id
    ELSIF p_attr_id = OE_Line_Adj_Util.G_DISCOUNT THEN
       l_x_Line_Adj_rec.discount_id := TO_NUMBER(p_attr_value1);
       l_x_Line_Adj_rec.discount_line_id := TO_NUMBER(p_attr_value2);

    -- It ATTR_ID       is discount_line_id then
    --    ATTR_VALUE1   is discount_line_id
    --    ATTR_VALUE2   is discount_id
    ELSIF p_attr_id = OE_Line_Adj_Util.G_DISCOUNT_LINE THEN
        l_x_Line_Adj_rec.discount_line_id := TO_NUMBER(p_attr_value1);
	l_x_Line_Adj_rec.discount_id := TO_NUMBER(p_attr_value2);

-- New column changes
-- New code Added :: Column Changes
    ELSIF p_attr_id = OE_Line_Adj_Util.G_LIST_HEADER_ID then
    	  l_x_Line_Adj_rec.list_header_id := to_number(p_attr_value1) ;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_LIST_LINE_ID then
	   l_x_Line_Adj_rec.list_line_id := to_number(p_attr_value1) ;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_LIST_LINE_TYPE_CODE then
	  l_x_Line_Adj_rec.list_line_type_code := p_attr_value1 ;

          IF l_x_Line_Adj_rec.list_line_type_code = 'PBH'
          AND nvl(l_x_Line_Adj_rec.list_line_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
            BEGIN
              SELECT ldets.line_quantity
              INTO   l_x_Line_Adj_rec.range_break_quantity
              FROM   qp_preq_ldets_tmp ldets,
		     qp_preq_lines_tmp lin
              WHERE  ldets.created_from_list_line_id = l_x_Line_Adj_rec.list_line_id
              AND    ldets.pricing_status_code = 'N'
	      AND    lin.line_index = ldets.line_index
	      AND    nvl(lin.line_id,l_x_Line_Adj_rec.line_id) = l_x_Line_Adj_rec.line_id
              AND    rownum = 1;
            EXCEPTION WHEN OTHERS THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  ' IN OE_OE_FORM_LINE_ADJ:'||SQLERRM ) ;
              END IF;
            END;
          END IF;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_MODIFIER_MECHANISM_TYPE_CODE then
	 l_x_Line_Adj_rec.modifier_mechanism_type_code := p_attr_value1 ;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_MODIFIED_FROM then
	  l_x_Line_Adj_rec.modified_from := p_attr_value1;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_MODIFIED_TO then
      l_x_Line_Adj_rec.modified_to := p_attr_value1;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_UPDATE_ALLOWED then
       l_x_Line_Adj_rec.update_allowed := p_attr_value1 ;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_UPDATED_FLAG then
	l_x_Line_Adj_rec.updated_flag := p_attr_value1 ;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_APPLIED_FLAG then
    l_x_Line_Adj_rec.applied_flag := p_attr_value1 ;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_CHANGE_REASON_CODE then
	   l_x_Line_Adj_rec.change_reason_code := p_attr_value1 ;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_CHANGE_REASON_TEXT then
	  l_x_Line_Adj_rec.change_reason_text := p_attr_value1 ;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_OPERAND then
	  l_x_Line_Adj_rec.operand := p_attr_value1 ;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_ARITHMETIC_OPERATOR then
	  l_x_Line_Adj_rec.arithmetic_operator := p_attr_value1 ;

    ELSIF p_attr_id = OE_Line_Adj_Util.G_ADJUSTED_AMOUNT then
	  l_x_Line_Adj_rec.adjusted_amount := p_attr_value1 ;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_PRICING_PHASE_ID then
	  l_x_Line_Adj_rec.pricing_phase_id := p_attr_value1 ;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_LIST_LINE_NO then
	  l_x_Line_Adj_rec.list_line_no := p_attr_value1 ;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_SOURCE_SYSTEM_CODE then
          l_x_Line_Adj_rec.source_system_code := p_attr_value1;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_BENEFIT_QTY then
          l_x_Line_Adj_rec.benefit_qty := TO_NUMBER(p_attr_value1);
    ELSIF p_attr_id = OE_Line_Adj_Util.G_BENEFIT_UOM_CODE then
          l_x_Line_Adj_rec.benefit_uom_code := p_attr_value1;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_PRINT_ON_INVOICE_FLAG then
          l_x_Line_Adj_rec.print_on_invoice_flag := p_attr_value1;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_EXPIRATION_DATE then
         -- l_x_Line_Adj_rec.expiration_date := TO_DATE(p_attr_value1, l_date_format);
	 l_x_Line_Adj_rec.expiration_date := fnd_date.string_TO_DATE(p_attr_value1, l_date_format); --bug5402396
    ELSIF p_attr_id = OE_Line_Adj_Util.G_REBATE_TRANSACTION_TYPE_CODE then
          l_x_Line_Adj_rec.rebate_transaction_type_code := p_attr_value1;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_REBATE_TRANSACTION_REFERENCE then
          l_x_Line_Adj_rec.rebate_transaction_reference := p_attr_value1;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_REBATE_PAYMENT_SYSTEM_CODE then
          l_x_Line_Adj_rec.rebate_payment_system_code := p_attr_value1;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_REDEEMED_DATE then
         -- l_x_Line_Adj_rec.redeemed_date := TO_DATE(p_attr_value1, l_date_format);
	 l_x_Line_Adj_rec.redeemed_date := fnd_date.string_TO_DATE(p_attr_value1, l_date_format); --bug5402396
    ELSIF p_attr_id = OE_Line_Adj_Util.G_REDEEMED_FLAG then
          l_x_Line_Adj_rec.redeemed_flag  := p_attr_value1;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_ACCRUAL_FLAG then
          l_x_Line_Adj_rec.accrual_flag := p_attr_value1;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_AUTOMATIC THEN
        l_x_Line_Adj_rec.automatic_flag := p_attr_value1;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_PERCENT THEN
        l_x_Line_Adj_rec.percent := TO_NUMBER(p_attr_value1);
    --Manual Begin
    ELSIF p_attr_id = OE_Line_Adj_Util.G_LINE THEN
        If p_attr_value1 Is Not Null Then
          l_x_Line_Adj_rec.line_id := TO_NUMBER(p_attr_value1);
        Else
          l_x_Line_Adj_rec.line_id := NULL;
        End If;
    --Manual End
    ELSIF p_attr_id = OE_Line_Adj_Util.G_ESTIMATED_FLAG THEN
	   l_x_Line_Adj_rec.estimated_flag := p_attr_value1;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_INVOICED_FLAG THEN
	   l_x_Line_Adj_rec.INVOICED_FLAG := p_attr_value1;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_CHARGE_TYPE_CODE THEN
	   l_x_Line_Adj_rec.CHARGE_TYPE_CODE := p_attr_value1;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_CHARGE_SUBTYPE_CODE THEN
	   l_x_Line_Adj_rec.CHARGE_SUBTYPE_CODE := p_attr_value1;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_CREDIT_OR_CHARGE_FLAG THEN
	   l_x_Line_Adj_rec.CREDIT_OR_CHARGE_FLAG := p_attr_value1;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_INCLUDE_ON_RETURNS_FLAG THEN
	   l_x_Line_Adj_rec.INCLUDE_ON_RETURNS_FLAG := p_attr_value1;
    --Manual Begin
    ELSIF p_attr_id = OE_LINE_Adj_Util.G_modifier_level_code Then
         l_x_Line_Adj_rec.modifier_level_code := p_attr_value1;
    ELSIF p_attr_id = OE_LINE_Adj_Util.G_OVERRIDE_ALLOWED_FLAG Then
         l_x_Line_Adj_rec.update_allowed:= p_attr_value1;
    --Manual end
    --uom begin
	   ELSIF p_attr_id = OE_Line_Adj_Util.G_OPERAND_PER_PQTY THEN
			 l_x_Line_Adj_rec.OPERAND_PER_PQTY := p_attr_value1;
  	   ELSIF p_attr_id = OE_Line_Adj_Util.G_ADJUSTED_AMOUNT_PER_PQTY THEN
		      l_x_Line_Adj_rec.ADJUSTED_AMOUNT_PER_PQTY := p_attr_value1;
    --uom end
    ELSIF p_attr_id = OE_LINE_Adj_Util.G_RANGE_BREAK_QUANTITY THEN
       l_x_Line_Adj_rec.range_break_quantity := p_attr_value1;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_CONTEXT
    OR     p_attr_id = OE_Line_Adj_Util.G_ATTRIBUTE1
    OR     p_attr_id = OE_Line_Adj_Util.G_ATTRIBUTE2
    OR     p_attr_id = OE_Line_Adj_Util.G_ATTRIBUTE3
    OR     p_attr_id = OE_Line_Adj_Util.G_ATTRIBUTE4
    OR     p_attr_id = OE_Line_Adj_Util.G_ATTRIBUTE5
    OR     p_attr_id = OE_Line_Adj_Util.G_ATTRIBUTE6
    OR     p_attr_id = OE_Line_Adj_Util.G_ATTRIBUTE7
    OR     p_attr_id = OE_Line_Adj_Util.G_ATTRIBUTE8
    OR     p_attr_id = OE_Line_Adj_Util.G_ATTRIBUTE9
    OR     p_attr_id = OE_Line_Adj_Util.G_ATTRIBUTE10
    OR     p_attr_id = OE_Line_Adj_Util.G_ATTRIBUTE11
    OR     p_attr_id = OE_Line_Adj_Util.G_ATTRIBUTE12
    OR     p_attr_id = OE_Line_Adj_Util.G_ATTRIBUTE13
    OR     p_attr_id = OE_Line_Adj_Util.G_ATTRIBUTE14
    OR     p_attr_id = OE_Line_Adj_Util.G_ATTRIBUTE15
    THEN

        l_x_Line_Adj_rec.context         := p_context;
        l_x_Line_Adj_rec.attribute1      := p_attribute1;
        l_x_Line_Adj_rec.attribute2      := p_attribute2;
        l_x_Line_Adj_rec.attribute3      := p_attribute3;
        l_x_Line_Adj_rec.attribute4      := p_attribute4;
        l_x_Line_Adj_rec.attribute5      := p_attribute5;
        l_x_Line_Adj_rec.attribute6      := p_attribute6;
        l_x_Line_Adj_rec.attribute7      := p_attribute7;
        l_x_Line_Adj_rec.attribute8      := p_attribute8;
        l_x_Line_Adj_rec.attribute9      := p_attribute9;
        l_x_Line_Adj_rec.attribute10     := p_attribute10;
        l_x_Line_Adj_rec.attribute11     := p_attribute11;
        l_x_Line_Adj_rec.attribute12     := p_attribute12;
        l_x_Line_Adj_rec.attribute13     := p_attribute13;
        l_x_Line_Adj_rec.attribute14     := p_attribute14;
        l_x_Line_Adj_rec.attribute15     := p_attribute15;
    ELSIF p_attr_id = OE_Line_Adj_Util.G_AC_CONTEXT
    OR    p_attr_id = OE_Line_Adj_Util.G_AC_ATTRIBUTE1
    OR    p_attr_id = OE_Line_Adj_Util.G_AC_ATTRIBUTE2
    OR    p_attr_id = OE_Line_Adj_Util.G_AC_ATTRIBUTE3
    OR    p_attr_id = OE_Line_Adj_Util.G_AC_ATTRIBUTE4
    OR    p_attr_id = OE_Line_Adj_Util.G_AC_ATTRIBUTE5
    OR    p_attr_id = OE_Line_Adj_Util.G_AC_ATTRIBUTE6
    OR    p_attr_id = OE_Line_Adj_Util.G_AC_ATTRIBUTE7
    OR    p_attr_id = OE_Line_Adj_Util.G_AC_ATTRIBUTE8
    OR    p_attr_id = OE_Line_Adj_Util.G_AC_ATTRIBUTE9
    OR    p_attr_id = OE_Line_Adj_Util.G_AC_ATTRIBUTE10
    OR    p_attr_id = OE_Line_Adj_Util.G_AC_ATTRIBUTE11
    OR    p_attr_id = OE_Line_Adj_Util.G_AC_ATTRIBUTE12
    OR    p_attr_id = OE_Line_Adj_Util.G_AC_ATTRIBUTE13
    OR    p_attr_id = OE_Line_Adj_Util.G_AC_ATTRIBUTE14
    OR    p_attr_id = OE_Line_Adj_Util.G_AC_ATTRIBUTE15
    THEN

        l_x_Line_Adj_rec.ac_context         := p_ac_context;
        l_x_Line_Adj_rec.ac_attribute1      := p_ac_attribute1;
        l_x_Line_Adj_rec.ac_attribute2      := p_ac_attribute2;
        l_x_Line_Adj_rec.ac_attribute3      := p_ac_attribute3;
        l_x_Line_Adj_rec.ac_attribute4      := p_ac_attribute4;
        l_x_Line_Adj_rec.ac_attribute5      := p_ac_attribute5;
        l_x_Line_Adj_rec.ac_attribute6      := p_ac_attribute6;
        l_x_Line_Adj_rec.ac_attribute7      := p_ac_attribute7;
        l_x_Line_Adj_rec.ac_attribute8      := p_ac_attribute8;
        l_x_Line_Adj_rec.ac_attribute9      := p_ac_attribute9;
        l_x_Line_Adj_rec.ac_attribute10     := p_ac_attribute10;
        l_x_Line_Adj_rec.ac_attribute11     := p_ac_attribute11;
        l_x_Line_Adj_rec.ac_attribute12     := p_ac_attribute12;
        l_x_Line_Adj_rec.ac_attribute13     := p_ac_attribute13;
        l_x_Line_Adj_rec.ac_attribute14     := p_ac_attribute14;
        l_x_Line_Adj_rec.ac_attribute15     := p_ac_attribute15;

    ELSE

        --  Unexpected error, unrecognized attribute

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attributes'
            ,   'Unrecognized attribute'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'RL:ADJUSTED AMT = ' || L_X_LINE_ADJ_REC.ADJUSTED_AMOUNT ) ;
 END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'RL:ADJ PQTY = ' || L_X_LINE_ADJ_REC.ADJUSTED_AMOUNT_PER_PQTY ) ;
	END IF;

    --  Set Operation.

    IF FND_API.To_Boolean(l_x_Line_Adj_rec.db_flag) THEN
        l_x_Line_Adj_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_x_Line_Adj_rec.operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;

    --Bug 1790502
    --For cascading adjustments to service lines
    --Only applicable to Service lines reference to options of a Model line
    --Only applicable to % arithmetic_operator

/*Legend:
  Top model line has prefix of T
  Option line has prefix of    O
  Service line has prefix of  S
  Adjustment has prefix of    A
  Adjustment for service lines has prefix of AS

  T1--A1
  |--S1----AS2
  |
  |
  |--O1--A3
  |  |-----S2----AS4
  |
  |--O2--A5
      |-----S3----AS6

Top model line T1 has adjusment A1 and Service line S1.  Service line S1
(service line for top model) has adjustment AS2.  If you make % change
on AS2, the same change will propagate the change to AS4 and AS6 which are the
adjustments for option service lines S2 and S3. It will not propagate the
same adjustment to A3 and A5 (because these are adjustments for Option lines
not for service lines). */

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' ARITHMETIC_OPERATOR:'||L_X_LINE_ADJ_REC.ARITHMETIC_OPERATOR ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' P_ATTR_ID:'|| P_ATTR_ID ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' G_OPERAND_PER_PQTY:'||OE_LINE_ADJ_UTIL.G_OPERAND_PER_PQTY ) ;
    END IF;


    If (l_x_line_adj_rec.arithmetic_operator = '%' and
       p_attr_id = OE_Line_Adj_Util.G_OPERAND_PER_PQTY)
       or p_attr_id = OE_Line_Adj_Util.G_CHANGE_REASON_CODE
    Then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  ' CS BEFORE GETTING LINE' ) ;
      END IF;
      Oe_Oe_Form_Line.Get_Line(p_line_id=>l_x_line_adj_rec.line_id,
                               x_line_rec=>l_line_rec);
    End If;

    --Cascading adjustments for service lines
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' CS QUERIED LINE_ID:'||L_LINE_REC.LINE_ID ) ;
    END IF;
    If nvl(l_line_rec.line_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM and
       l_line_rec.service_reference_line_id Is Not Null  --make sure is adjustment for a service line
    Then
       --To determine if this is an adjustment for service line of a top model line
       Begin
       Select line_id
       Into   l_top_model_line_id
       From   Oe_Order_Lines_All
       Where  line_id = l_line_rec.service_reference_line_id
       and    top_model_line_id = line_id;

       --This is a service line of a top model line, need to cascade the change to adjustments
       --for service lines of option items.
       get_option_service_lines(p_top_model_line_id=>l_top_model_line_id,
                                p_service_line_id=>l_line_rec.line_id,
                                x_line_id_tbl=>l_line_id_tbl);

      --setting p_create_adj_no_validation to TRUE to maintain
      --behavior of bug 1790502 in which adjustment for service option line are not being validated
      If l_line_id_tbl.first is Not Null Then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CS CREATING OR CHANGING' ) ;
        END IF;
        Process_Adj(p_parent_adj_rec           => l_x_line_adj_rec,
                    p_line_id_tbl              => l_line_id_tbl,
                    p_create_adj_no_validate   => TRUE);
      End If;

      Exception when no_data_found Then
       Null;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  ' CS THIS IS NOT A ADJUSTMENT FOR TOP SERVICE LINE' ) ;
       END IF;
       --No data found, this is not an adjustment for service line for top model line item.
      End;
    End If;

If l_orcl_customization = 'Y'  Then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' CS BEFORE CHECKING TOP MODEL LINE' ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' TOP MODEL LINE ID:'||L_LINE_REC.TOP_MODEL_LINE_ID ) ;
    END IF;
    --Cascading adjustments from top model to option lines
    If nvl(l_line_rec.line_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM and
       l_line_rec.line_id = l_line_rec.top_model_line_id  --to make sure this is a top model line
    Then
        get_option_service_lines(p_top_model_line_id=>l_line_rec.top_model_line_id,
                                 p_mode      => 'OPTION',
                                 x_line_id_tbl=>l_line_id_tbl);

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  ' LINE ID COUNT:'||L_LINE_ID_TBL.COUNT ) ;
      END IF;
      If l_line_id_tbl.first is Not Null Then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'CS CASCADING OPTION ADJUSTMENTS' ) ;
        END IF;
        Process_Adj(p_parent_adj_rec => l_x_line_adj_rec,
                    p_line_id_tbl       => l_line_id_tbl);
      End If;

    End If;

   --we will need to cascade change reason code too, if it got changed
  If  p_attr_id = OE_Line_Adj_Util.G_CHANGE_REASON_CODE Then

       --If no line queried, requery again else just use this to
       If nvl(l_line_rec.line_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM Then
            Oe_Oe_Form_Line.Get_Line(p_line_id=>l_x_line_adj_rec.line_id,
                                     x_line_rec=>l_line_rec);
       End If;

       --Only do that for top model line
       If l_line_rec.line_id = l_line_rec.top_model_line_id Then
           get_option_service_lines(p_top_model_line_id=>l_line_rec.top_model_line_id,
                                    p_mode      => 'OPTION',
                                    x_line_id_tbl=>l_line_id_tbl);

             If l_line_id_tbl.first is Not Null Then
               Process_Adj(p_parent_adj_rec => l_x_line_adj_rec,
                           p_line_id_tbl       => l_line_id_tbl);
             End If;
       End If;

   End If;


End If; --cascade adjustment lines

    --Reset l_line_rec.line_id after used
    l_line_rec.line_id := NULL;
    l_line_id_tbl.delete;

    --  Populate Line_Adj table
    l_x_Line_Adj_tbl(1) := l_x_Line_Adj_rec;
    l_x_old_Line_Adj_tbl(1) := l_x_old_Line_Adj_rec;

    -- Call Oe_Order_Adj_Pvt.Line_Adj
    l_Line_Adj_rec := l_x_Line_Adj_rec;

    oe_order_adj_pvt.Line_Adjs
    (	p_init_msg_list		=> FND_API.G_TRUE
    ,	p_validation_level 		=> FND_API.G_VALID_LEVEL_NONE
    ,	p_control_rec			=> l_control_rec
    ,	p_x_line_adj_tbl		=> l_x_Line_Adj_tbl
    ,	p_x_old_line_adj_tbl	=> l_x_old_Line_Adj_tbl
    );

    /************************************************************************
    --  Call OE_Order_PVT.Process_order
    OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_action_request_tbl	      => l_request_tbl
    ,   p_Line_Adj_tbl                => l_Line_Adj_tbl
    ,   p_old_Line_Adj_tbl            => l_old_Line_Adj_tbl
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
    ,   x_action_request_tbl	      => l_action_request_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    ******************************************************************/

    --  Unload out tbl
    l_x_Line_Adj_rec := l_x_Line_Adj_tbl(1);

    IF l_x_Line_Adj_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_x_Line_Adj_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

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

-- New  columns names added
	x_list_header_id        := FND_API.G_MISS_NUM;
	x_list_line_id := FND_API.G_MISS_NUM;
	x_list_line_type_code := FND_API.G_MISS_CHAR;
	x_modifier_mechanism_type_code := FND_API.G_MISS_CHAR;
	x_modified_from     := FND_API.G_MISS_CHAR;
	x_modified_to  := FND_API.G_MISS_CHAR;
	x_update_allowed    := FND_API.G_MISS_CHAR;
	x_updated_flag := FND_API.G_MISS_CHAR;
	x_applied_flag := FND_API.G_MISS_CHAR;
	x_change_reason_code := FND_API.G_MISS_CHAR;
	x_change_reason_text := FND_API.G_MISS_CHAR;
	x_operand  := FND_API.G_MISS_NUM;
	x_arithmetic_operator  := FND_API.G_MISS_CHAR;

    x_adjusted_amount              := FND_API.G_MISS_NUM;
    x_pricing_phase_id             := FND_API.G_MISS_NUM;
    x_list_line_no                 := FND_API.G_MISS_CHAR;
    x_source_system_code           := FND_API.G_MISS_CHAR;
    x_benefit_qty                  := FND_API.G_MISS_NUM;
    x_benefit_uom_code             := FND_API.G_MISS_CHAR;
    x_print_on_invoice_flag        := FND_API.G_MISS_CHAR;
    x_expiration_date              := FND_API.G_MISS_DATE;
    x_rebate_transaction_type_code := FND_API.G_MISS_CHAR;
    x_rebate_transaction_reference := FND_API.G_MISS_CHAR;
    x_rebate_payment_system_code   := FND_API.G_MISS_CHAR;
    x_redeemed_date                := FND_API.G_MISS_DATE;
    x_redeemed_flag                := FND_API.G_MISS_CHAR;
    x_accrual_flag                 := FND_API.G_MISS_CHAR;
    x_estimated_flag               := FND_API.G_MISS_CHAR;
    x_invoiced_flag                := FND_API.G_MISS_CHAR;
    x_charge_type_code             := FND_API.G_MISS_CHAR;
    x_charge_subtype_code          := FND_API.G_MISS_CHAR;
    x_credit_or_charge_flag        := FND_API.G_MISS_CHAR;
    x_include_on_returns_flag      := FND_API.G_MISS_CHAR;
    --uom begin
	   x_operand_per_pqty             := FND_API.G_MISS_NUM;
	   x_adjusted_amount_per_pqty     := FND_API.G_MISS_NUM;
    --uom end

    --  Load display out parameters if any

    l_Line_Adj_val_rec := OE_Line_Adj_Util.Get_Values
    (   p_Line_Adj_rec                =>l_x_Line_Adj_rec
    ,   p_old_Line_Adj_rec            => l_Line_Adj_rec
    );

-- New Column changes

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.adjusted_amount, l_Line_Adj_rec.adjusted_amount)
    THEN
       x_adjusted_amount := l_x_Line_Adj_rec.adjusted_amount;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.pricing_phase_id, l_Line_Adj_rec.pricing_phase_id)
    THEN
       x_pricing_phase_id := l_x_Line_Adj_rec.pricing_phase_id;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.list_line_no, l_Line_Adj_rec.list_line_no)
    THEN
       x_list_line_no := l_x_Line_Adj_rec.list_line_no;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.source_system_code, l_Line_Adj_rec.source_system_code)
    THEN
       x_source_system_code := l_x_Line_Adj_rec.source_system_code;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.benefit_qty, l_Line_Adj_rec.benefit_qty)
    THEN
       x_benefit_qty := l_x_Line_Adj_rec.benefit_qty;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.benefit_uom_code, l_Line_Adj_rec.benefit_uom_code)
    THEN
       x_benefit_uom_code := l_x_Line_Adj_rec.benefit_uom_code;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.print_on_invoice_flag, l_Line_Adj_rec.print_on_invoice_flag)
    THEN
       x_print_on_invoice_flag := l_x_Line_Adj_rec.print_on_invoice_flag;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.expiration_date, l_Line_Adj_rec.expiration_date)
    THEN
       x_expiration_date := l_x_Line_Adj_rec.expiration_date;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.rebate_transaction_type_code, l_Line_Adj_rec.rebate_transaction_type_code)
    THEN
       x_rebate_transaction_type_code := l_x_Line_Adj_rec.rebate_transaction_type_code;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.rebate_transaction_reference, l_Line_Adj_rec.rebate_transaction_reference)
    THEN
       x_rebate_transaction_reference := l_x_Line_Adj_rec.rebate_transaction_reference;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.rebate_payment_system_code, l_Line_Adj_rec.rebate_payment_system_code)
    THEN
       x_rebate_payment_system_code := l_x_Line_Adj_rec.rebate_payment_system_code;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.redeemed_date, l_Line_Adj_rec.redeemed_date)
    THEN
       x_redeemed_date := l_x_Line_Adj_rec.redeemed_date;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.redeemed_flag, l_Line_Adj_rec.redeemed_flag)
    THEN
       x_redeemed_flag := l_x_Line_Adj_rec.redeemed_flag;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.accrual_flag, l_Line_Adj_rec.accrual_flag)
    THEN
       x_accrual_flag := l_x_Line_Adj_rec.accrual_flag;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.list_header_id, l_Line_Adj_rec.list_header_id)
    THEN
       x_list_header_id := l_x_Line_Adj_rec.list_header_id;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.list_line_id,l_Line_Adj_rec.list_line_id)
    THEN
	  x_list_line_id := l_x_Line_Adj_rec.list_line_id;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.list_line_type_code,
					l_Line_Adj_rec.list_line_type_code)
	THEN
	    x_list_line_type_code := l_x_Line_Adj_rec.list_line_type_code;
     END IF;

	  IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.modifier_mechanism_type_code,
	  l_Line_Adj_rec.modifier_mechanism_type_code)
	 THEN
	  x_modifier_mechanism_type_code :=
				   l_x_Line_Adj_rec.modifier_mechanism_type_code;
	  END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.update_allowed,
l_Line_Adj_rec.update_allowed)
    THEN
    x_update_allowed := l_x_Line_Adj_rec.update_allowed;
    END IF;

  IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.updated_flag, l_Line_Adj_rec.updated_flag)
  THEN
	x_updated_flag := l_x_Line_Adj_rec.updated_flag;
  END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.modified_from, l_Line_Adj_rec.modified_from)
    THEN
	    x_modified_from := l_x_Line_Adj_rec.modified_from;
    END IF;

  IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.modified_to, l_Line_Adj_rec.modified_to)
  THEN
	x_modified_to := l_x_Line_Adj_rec.modified_to;
  END IF;

   IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.applied_flag, l_Line_Adj_rec.applied_flag)
   THEN
    x_applied_flag := l_x_Line_Adj_rec.applied_flag;
   END IF;

   IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.change_reason_code, l_Line_Adj_rec.change_reason_code)
   THEN
	 x_change_reason_code := l_x_Line_Adj_rec.change_reason_code;
   END IF;

   IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.change_reason_text, l_Line_Adj_rec.change_reason_text)
   THEN
	 x_change_reason_text := l_x_Line_Adj_rec.change_reason_text;
   END IF;
   IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.operand, l_Line_Adj_rec.operand)
   THEN
	 x_operand := l_x_Line_Adj_rec.operand;
   END IF;
   IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.arithmetic_operator, l_Line_Adj_rec.arithmetic_operator)
   THEN
	 x_arithmetic_operator := l_x_Line_Adj_rec.arithmetic_operator;
   END IF;


    --  Return changed attributes.

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.attribute1,
                            l_Line_Adj_rec.attribute1)
    THEN
        x_attribute1 := l_x_Line_Adj_rec.attribute1;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.attribute10,
                            l_Line_Adj_rec.attribute10)
    THEN
        x_attribute10 := l_x_Line_Adj_rec.attribute10;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.attribute11,
                            l_Line_Adj_rec.attribute11)
    THEN
        x_attribute11 := l_x_Line_Adj_rec.attribute11;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.attribute12,
                            l_Line_Adj_rec.attribute12)
    THEN
        x_attribute12 := l_x_Line_Adj_rec.attribute12;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.attribute13,
                            l_Line_Adj_rec.attribute13)
    THEN
        x_attribute13 := l_x_Line_Adj_rec.attribute13;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.attribute14,
                            l_Line_Adj_rec.attribute14)
    THEN
        x_attribute14 := l_x_Line_Adj_rec.attribute14;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.attribute15,
                            l_Line_Adj_rec.attribute15)
    THEN
        x_attribute15 := l_x_Line_Adj_rec.attribute15;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.attribute2,
                            l_Line_Adj_rec.attribute2)
    THEN
        x_attribute2 := l_x_Line_Adj_rec.attribute2;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.attribute3,
                            l_Line_Adj_rec.attribute3)
    THEN
        x_attribute3 := l_x_Line_Adj_rec.attribute3;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.attribute4,
                            l_Line_Adj_rec.attribute4)
    THEN
        x_attribute4 := l_x_Line_Adj_rec.attribute4;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.attribute5,
                            l_Line_Adj_rec.attribute5)
    THEN
        x_attribute5 := l_x_Line_Adj_rec.attribute5;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.attribute6,
                            l_Line_Adj_rec.attribute6)
    THEN
        x_attribute6 := l_x_Line_Adj_rec.attribute6;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.attribute7,
                            l_Line_Adj_rec.attribute7)
    THEN
        x_attribute7 := l_x_Line_Adj_rec.attribute7;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.attribute8,
                            l_Line_Adj_rec.attribute8)
    THEN
        x_attribute8 := l_x_Line_Adj_rec.attribute8;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.attribute9,
                            l_Line_Adj_rec.attribute9)
    THEN
        x_attribute9 := l_x_Line_Adj_rec.attribute9;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.automatic_flag,
                            l_Line_Adj_rec.automatic_flag)
    THEN
        x_automatic_flag := l_x_Line_Adj_rec.automatic_flag;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.context,
                            l_Line_Adj_rec.context)
    THEN
        x_context := l_x_Line_Adj_rec.context;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.discount_id,
                            l_Line_Adj_rec.discount_id)
    THEN
        x_discount_id := l_x_Line_Adj_rec.discount_id;
        x_discount := l_Line_Adj_val_rec.discount;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.discount_line_id,
                            l_Line_Adj_rec.discount_line_id)
    THEN
        x_discount_line_id := l_x_Line_Adj_rec.discount_line_id;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.header_id,
                            l_Line_Adj_rec.header_id)
    THEN
        x_header_id := l_x_Line_Adj_rec.header_id;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.line_id,
                            l_Line_Adj_rec.line_id)
    THEN
        x_line_id := l_x_Line_Adj_rec.line_id;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.percent,
                            l_Line_Adj_rec.percent)
    THEN
        x_percent := l_x_Line_Adj_rec.percent;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.price_adjustment_id,
                            l_Line_Adj_rec.price_adjustment_id)
    THEN
        x_price_adjustment_id := l_x_Line_Adj_rec.price_adjustment_id;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.invoiced_flag,
                            l_Line_Adj_rec.invoiced_flag)
    THEN
        x_invoiced_flag := l_x_Line_Adj_rec.invoiced_flag;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.estimated_flag,
                            l_Line_Adj_rec.estimated_flag)
    THEN
        x_estimated_flag := l_x_Line_Adj_rec.estimated_flag;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.charge_type_code,
                            l_Line_Adj_rec.charge_type_code)
    THEN
        x_charge_type_code := l_x_Line_Adj_rec.charge_type_code;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.charge_subtype_code,
                            l_Line_Adj_rec.charge_subtype_code)
    THEN
        x_charge_subtype_code := l_x_Line_Adj_rec.charge_subtype_code;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.credit_or_charge_flag,
                            l_Line_Adj_rec.credit_or_charge_flag)
    THEN
        x_credit_or_charge_flag := l_x_Line_Adj_rec.credit_or_charge_flag;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.include_on_returns_flag,
                            l_Line_Adj_rec.include_on_returns_flag)
    THEN
        x_include_on_returns_flag := l_x_Line_Adj_rec.include_on_returns_flag;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.ac_attribute1,
                            l_Line_Adj_rec.ac_attribute1)
    THEN
        x_ac_attribute1 := l_x_Line_Adj_rec.ac_attribute1;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.ac_attribute10,
                            l_Line_Adj_rec.ac_attribute10)
    THEN
        x_ac_attribute10 := l_x_Line_Adj_rec.ac_attribute10;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.ac_attribute11,
                            l_Line_Adj_rec.ac_attribute11)
    THEN
        x_ac_attribute11 := l_x_Line_Adj_rec.ac_attribute11;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.ac_attribute12,
                            l_Line_Adj_rec.ac_attribute12)
    THEN
        x_ac_attribute12 := l_x_Line_Adj_rec.ac_attribute12;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.ac_attribute13,
                            l_Line_Adj_rec.ac_attribute13)
    THEN
        x_ac_attribute13 := l_x_Line_Adj_rec.ac_attribute13;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.ac_attribute14,
                            l_Line_Adj_rec.ac_attribute14)
    THEN
        x_ac_attribute14 := l_x_Line_Adj_rec.ac_attribute14;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.ac_attribute15,
                            l_Line_Adj_rec.ac_attribute15)
    THEN
        x_ac_attribute15 := l_x_Line_Adj_rec.ac_attribute15;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.ac_attribute2,
                            l_Line_Adj_rec.ac_attribute2)
    THEN
        x_ac_attribute2 := l_x_Line_Adj_rec.ac_attribute2;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.ac_attribute3,
                            l_Line_Adj_rec.ac_attribute3)
    THEN
        x_ac_attribute3 := l_x_Line_Adj_rec.ac_attribute3;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.ac_attribute4,
                            l_Line_Adj_rec.ac_attribute4)
    THEN
        x_ac_attribute4 := l_x_Line_Adj_rec.ac_attribute4;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.ac_attribute5,
                            l_Line_Adj_rec.ac_attribute5)
    THEN
        x_ac_attribute5 := l_x_Line_Adj_rec.ac_attribute5;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.ac_attribute6,
                            l_Line_Adj_rec.ac_attribute6)
    THEN
        x_ac_attribute6 := l_x_Line_Adj_rec.ac_attribute6;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.ac_attribute7,
                            l_Line_Adj_rec.ac_attribute7)
    THEN
        x_ac_attribute7 := l_x_Line_Adj_rec.ac_attribute7;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.ac_attribute8,
                            l_Line_Adj_rec.ac_attribute8)
    THEN
        x_ac_attribute8 := l_x_Line_Adj_rec.ac_attribute8;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.ac_attribute9,
                            l_Line_Adj_rec.ac_attribute9)
    THEN
        x_ac_attribute9 := l_x_Line_Adj_rec.ac_attribute9;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.ac_context,
                            l_Line_Adj_rec.ac_context)
    THEN
        x_ac_context := l_x_Line_Adj_rec.ac_context;
    END IF;
    --uom begin
    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.operand_per_pqty,
					   l_Line_Adj_rec.operand_per_pqty)
    THEN
	  x_operand_per_pqty := l_x_Line_Adj_rec.operand_per_pqty;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Adj_rec.adjusted_amount_per_pqty,
					   l_Line_Adj_rec.adjusted_amount_per_pqty)
    THEN
	 x_adjusted_amount_per_pqty := l_x_Line_Adj_rec.adjusted_amount_per_pqty;
    END IF;
    --uom end




    --  Write to cache.
    Write_Line_Adj
    (   p_Line_Adj_rec                => l_x_Line_Adj_rec
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

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE_ADJ.CHANGE_ATTRIBUTES' , 1 ) ;
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

	ROLLBACK TO SAVEPOINT change_attributes;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

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
            ,   'Change_Attributes'
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
l_request_rec		      OE_Order_Pub.Request_Rec_Type;
l_request_tbl		      OE_Order_Pub.Request_Tbl_Type;
l_Line_Adj_rec                OE_Order_PUB.Line_Adj_Rec_Type;
l_x_old_Line_Adj_rec            OE_Order_PUB.Line_Adj_Rec_Type;
l_Line_Adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_old_Line_Adj_tbl            OE_Order_PUB.Line_Adj_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_action_request_tbl	      OE_Order_PUB.Request_Tbl_Type;
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
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_ADJ.VALIDATE_AND_WRITE' , 1 ) ;
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
    l_control_rec.process_entity      := OE_GLOBALS.G_ENTITY_LINE_ADJ;


    --  Instruct API to retain its caches
    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;


    -- Save point to rollback to if there were
    -- any errors
    SAVEPOINT validate_and_write;


    --  Read Line_Adj from cache
    Get_Line_Adj
    (   p_db_record                => TRUE
    ,   p_price_adjustment_id      => p_price_adjustment_id
    ,   x_Line_adj_rec			=> l_x_old_Line_Adj_rec
    );

    Get_Line_Adj
    (   p_db_record                => FALSE
    ,   p_price_adjustment_id      => p_price_adjustment_id
    ,   x_Line_Adj_rec			=> l_x_Line_Adj_rec
    );


    --  Set Operation.
  --  IF FND_API.To_Boolean(l_Line_Adj_rec.db_flag) THEN
    IF FND_API.To_Boolean(l_x_Line_Adj_rec.db_flag) THEN
        l_x_Line_Adj_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_x_Line_Adj_rec.operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;



    --  Populate Line_Adj table
    l_x_Line_Adj_tbl(1) := l_x_Line_Adj_rec;
    l_x_old_Line_Adj_tbl(1) := l_x_old_Line_Adj_rec;
/*	IF p_ok_flag = 'Y' THEN

       l_request_rec.entity_code:= OE_GLOBALS.G_ENTITY_LINE_ADJ;
       l_request_rec.entity_id	:= l_line_adj_rec.line_id;
       l_request_rec.request_type	:= OE_GLOBALS.G_PRICE_ADJ;
       l_request_tbl(1) := l_request_rec;

	END IF; */


    -- Call Oe_Order_Adj_Pvt.Line_Adj
    oe_order_adj_pvt.Line_Adjs
    (	p_init_msg_list		=> FND_API.G_TRUE
    ,	p_validation_level 		=> FND_API.G_VALID_LEVEL_FULL
    ,	p_control_rec			=> l_control_rec
    ,	p_x_line_adj_tbl		=> l_x_Line_Adj_tbl
    ,	p_x_old_line_adj_tbl	=> l_x_old_Line_Adj_tbl
    );

    /*********************************************************************
    --  Call OE_Order_PVT.Process_order
    OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_action_request_tbl	      => l_request_tbl
    ,   p_Line_Adj_tbl                => l_Line_Adj_tbl
    ,   p_old_Line_Adj_tbl            => l_old_Line_Adj_tbl
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
    ,   x_action_request_tbl	      => l_action_request_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    *************************************************************************/

    --  Load OUT parameters.
    l_x_Line_Adj_rec := l_x_Line_Adj_tbl(1);

    IF l_x_Line_Adj_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_x_Line_Adj_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    /*****
    Oe_Order_Pvt.Process_Requests_And_Notify
    (	p_process_requests	=> FALSE
    ,	p_notify			=> TRUE
    ,	p_line_adj_tbl		=> l_x_line_adj_tbl
    ,	p_old_line_adj_tbl	=> l_x_old_line_adj_tbl
    ,	x_return_status	=> l_return_status
    );
    ******/

    x_lock_control := l_x_Line_Adj_rec.lock_control;

     -- commented out by linda
	/****
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
	  ***/

	/***
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
	***/

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

    x_creation_date                := l_x_Line_Adj_rec.creation_date;
    x_created_by                   := l_x_Line_Adj_rec.created_by;
    x_last_update_date             := l_x_Line_Adj_rec.last_update_date;
    x_last_updated_by              := l_x_Line_Adj_rec.last_updated_by;
    x_last_update_login            := l_x_Line_Adj_rec.last_update_login;
    x_program_id            		:= l_x_Line_Adj_rec.program_id;
    x_program_application_id      	:= l_x_Line_Adj_rec.program_application_id;
    x_program_update_date      	:= l_x_Line_Adj_rec.program_update_date;
    x_request_id      			:= l_x_Line_Adj_rec.request_id;


    --  Clear Line_Adj record cache
    Clear_Line_Adj;

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
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE_ADJ.VALIDATE_AND_WRITE' , 1 ) ;
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
l_Line_Adj_rec                OE_Order_PUB.Line_Adj_Rec_Type;
l_Line_Adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_action_request_tbl	      OE_Order_PUB.Request_Tbl_Type;
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_rec            OE_Order_PUB.Header_Adj_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_rec        OE_Order_PUB.Header_Scredit_Rec_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_rec                  OE_Order_PUB.Line_Rec_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_x_old_Line_Adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_old_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
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

--1790502
l_line_rec          OE_Order_Pub.Line_Rec_Type;
l_line_id_tbl       OE_Order_Adj_Pvt.Index_Tbl_Type;
l_top_model_line_id Number;
l_profile_cascade_adjustments Varchar2(1):= NVL(FND_PROFILE.VALUE('ONT_CASCADE_ADJUSTMENTS'),'N');

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_ADJ.DELETE_ROW' , 1 ) ;
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
    Get_Line_Adj
    (   p_db_record                => TRUE
    ,   p_price_adjustment_id      => p_price_adjustment_id
    ,   x_Line_adj_rec			=> l_x_Line_Adj_rec
    );


    --  Set Operation.
    l_x_Line_Adj_rec.operation := OE_GLOBALS.G_OPR_DELETE;


    --  Populate Line_Adj table
    l_x_Line_Adj_tbl(1) := l_x_Line_Adj_rec;
    l_x_Line_Adj_tbl(1).change_reason_code := p_change_reason_code;
    l_x_Line_Adj_tbl(1).change_reason_text := p_change_comments;


    -- Bug 1790502
     If l_x_line_adj_rec.arithmetic_operator = '%' Then
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  ' CS BEFORE GETTING LINE' ) ;
       END IF;
       Oe_Oe_Form_Line.Get_Line(p_line_id=>l_x_line_adj_rec.line_id,
                               x_line_rec=>l_line_rec);

        If nvl(l_line_rec.line_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM and
           l_line_rec.service_reference_line_id Is Not Null  --make sure is adjustment for a service line
        Then
         --To determine if this is an adjustment for service line of a top model line
         Begin
         Select line_id
         Into   l_top_model_line_id
         From   Oe_Order_Lines_All
         Where  line_id = l_line_rec.service_reference_line_id
         and    top_model_line_id = line_id;

         --this is a top model line, need to cascade the change to adjustments
         --for service lines of option items.
         get_option_service_lines(p_top_model_line_id=>l_top_model_line_id,
                                  p_service_line_id=>l_line_rec.line_id,
                                  x_line_id_tbl=>l_line_id_tbl);

        If l_line_id_tbl.first is Not Null Then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  ' CS DELETING CHILDREN OPTION SERVICE ADJUSTMENT LINES' ) ;
          END IF;
          Process_Adj(p_parent_adj_rec => l_x_line_adj_rec,
                      p_line_id_tbl    => l_line_id_tbl,
                      p_delete_flag    => 'Y');
        End If;

      Exception when no_data_found Then
       Null;
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  ' CS THIS IS NOT A ADJUSTMENT FOR TOP SERVICE LINE' ) ;
       END IF;
       --No data found, this is not an adjustment for service line for top model line item.
      End;

     If l_profile_cascade_adjustments = 'Y' Then
      --handling delete for adjustment for options of a top model
      If nvl(l_line_rec.line_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM and
           l_line_rec.top_model_line_id = l_line_rec.line_id
      Then
          get_option_service_lines(p_top_model_line_id =>l_line_rec.top_model_line_id,
                                   p_mode              =>'OPTION',
                                   x_line_id_tbl       =>l_line_id_tbl);

          If l_line_id_tbl.first is Not Null Then
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  ' CS DELETING CHILDREN OPTION ADJUSTMENT LINES' ) ;
            END IF;
            Process_Adj(p_parent_adj_rec => l_x_line_adj_rec,
                        p_line_id_tbl    => l_line_id_tbl,
                        p_delete_flag    => 'Y');
          End If;

      End If;




     End If; --l_profile_cascade_adjustments

    End If;

    End If;

    -- Call Oe_Order_Adj_Pvt.Line_Adj
    oe_order_adj_pvt.Line_Adjs
    (	p_init_msg_list		=> FND_API.G_TRUE
    ,	p_validation_level 		=> FND_API.G_VALID_LEVEL_FULL
    ,	p_control_rec			=> l_control_rec
    ,	p_x_line_adj_tbl		=> l_x_Line_Adj_tbl
    ,	p_x_old_line_adj_tbl	=> l_x_old_Line_Adj_tbl
    );


    --  Load OUT parameters.
    l_x_Line_Adj_rec := l_x_Line_Adj_tbl(1);

    IF l_x_Line_Adj_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_x_Line_Adj_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear Line_Adj record cache
    Clear_Line_Adj;

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
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE_ADJ.DELETE_ROW' , 1 ) ;
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
,   p_line_id			    IN  NUMBER
)
IS
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_request_rec		      OE_Order_Pub.Request_Rec_Type;
l_request_tbl		      OE_Order_Pub.Request_Tbl_Type;
l_action_request_tbl	      OE_Order_PUB.Request_Tbl_Type;
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
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_ADJ.PROCESS_DELAYED_REQUESTS' , 1 ) ;
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

        IF OE_Commitment_Pvt.Do_Commitment_Sequencing  THEN
        -- process delayed requests for commitment calculation.
	  OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
		(p_request_type   => OE_GLOBALS.G_CALCULATE_COMMITMENT
		,p_delete        => FND_API.G_TRUE
		,x_return_status => l_return_status
		);
	  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	  END IF;
        END IF;

        oe_debug_pub.ADD('Processing delayed request for Verify Payment for price adjustments changes.', 3);
        OE_DELAYED_REQUESTS_PVT.Process_Request_for_Reqtype
		(p_request_type   => OE_GLOBALS.G_VERIFY_PAYMENT
		,p_delete        => FND_API.G_TRUE
		,x_return_status => l_return_status
		);

    */
    --2366123: all requests should be executed
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

--btea begin fix bug 1398294
    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );
--btea end fix bug 1398294

    x_return_status := FND_API.G_RET_STS_SUCCESS;

Return;

    /********************************************************************
    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_LINE_ADJ;

    l_control_rec.check_security       := FALSE;
    l_control_rec.clear_dependents     := FALSE;
    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;


    -- Assign requests that are to be executed
    -- l_request_rec.request_type	:= OE_GLOBALS.G_CHECK_PERCENTAGE;
    -- l_request_rec.entity_code	:= OE_GLOBALS.G_ENTITY_LINE_ADJ;
    -- l_request_rec.entity_id	:= p_line_id;
    -- l_request_rec.param1	:= p_header_id;
    -- l_request_tbl(1) := l_request_rec;

    -- l_request_rec.request_type	:= OE_GLOBALS.G_PRICE_ADJ;
    -- l_request_rec.entity_code	:= OE_GLOBALS.G_ENTITY_LINE_ADJ;
    -- l_request_rec.entity_id	:= p_line_id;
    -- l_request_tbl(2) := l_request_rec;


    --  Call OE_Order_PVT.Process_order

    OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_action_request_tbl	        => l_request_tbl
    ,   p_x_header_rec                => l_x_header_rec
    ,   p_x_Header_Adj_tbl            => l_x_Header_Adj_tbl
-- New Parameters
    ,   p_x_Header_price_Att_tbl      => l_x_Header_price_Att_tbl
    ,   p_x_Header_Adj_Att_tbl        => l_x_Header_Adj_Att_tbl
    ,   p_x_Header_Adj_Assoc_tbl      => l_x_Header_Adj_Assoc_tbl


    ,   p_x_Header_Scredit_tbl        => l_x_Header_Scredit_tbl
    ,   p_x_line_tbl                  => l_x_line_tbl
    ,   p_x_Line_Adj_tbl              => l_x_Line_Adj_tbl
-- New Parameters
    ,   p_x_Line_price_Att_tbl        => l_x_Line_price_Att_tbl
    ,   p_x_Line_Adj_Att_tbl          => l_x_Line_Adj_Att_tbl
    ,   p_x_Line_Adj_Assoc_tbl        => l_x_Line_Adj_Assoc_tbl

    ,   p_x_Line_Scredit_tbl          => l_x_Line_Scredit_tbl
    ,   p_x_Lot_Serial_tbl            => l_x_Lot_Serial_tbl
    ,   p_x_action_request_tbl	   => l_action_request_tbl
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

    oe_debug_pub.add('Exiting OE_OE_FORM_LINE_ADJ.PROCESS_DELAYED_REQUESTS', 1);

    ****************************************************************/

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


PROCEDURE replace_attributes
(x_return_status OUT NOCOPY VARCHAR2,

x_msg_count OUT NOCOPY NUMBER,

x_msg_data OUT NOCOPY VARCHAR2,

   p_price_adjustment_id	IN  NUMBER,
   p_adjusted_amount	        IN  NUMBER,
   p_adjusted_amount_per_pqty	IN  NUMBER DEFAULT NULL,
   p_arithmetic_operator	IN  VARCHAR2,
   p_operand			IN  NUMBER,
   p_operand_per_pqty 	        IN  NUMBER DEFAULT NULL,
   p_applied_flag		IN  VARCHAR2,
   p_updated_flag		IN  VARCHAR2,
   p_change_reason_code         IN  Varchar2 :=NULL,
   p_change_reason_text         IN  VARCHAR2 :=NULL
   )
  IS
l_Line_Adj_rec                OE_Order_PUB.Line_Adj_Rec_Type;
l_x_Line_Adj_rec                OE_Order_PUB.Line_Adj_Rec_Type;
l_x_old_Line_Adj_rec            OE_Order_PUB.Line_Adj_Rec_Type;
l_Line_Adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_old_Line_Adj_tbl            OE_Order_PUB.Line_Adj_Tbl_Type;
l_Line_Adj_val_rec            OE_Order_PUB.Line_Adj_Val_Rec_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_action_request_tbl	      OE_Order_PUB.Request_Tbl_Type;
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
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

l_line_rec     Oe_Order_Pub.line_rec_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_ADJ.REPLACE_ATTRIBUTES' , 1 ) ;
   END IF;

    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

   --  Set control flags.
   l_control_rec.controlled_operation := TRUE;
   l_control_rec.clear_dependents     := FALSE;
   l_control_rec.change_attributes    := TRUE;
   l_control_rec.default_attributes   := TRUE;
   l_control_rec.validate_entity      := FALSE;
   l_control_rec.write_to_DB          := TRUE;
   l_control_rec.process              := FALSE;


   --  Instruct API to retain its caches
   l_control_rec.clear_api_cache      := FALSE;
   l_control_rec.clear_api_requests   := FALSE;


   -- Save point to rollback to if there were
   -- any errors
   SAVEPOINT replace_attributes;

    Get_Line_Adj
    (   p_db_record                => FALSE
    ,   p_price_adjustment_id      => p_price_adjustment_id
    ,   x_Line_Adj_rec			=> l_x_Line_Adj_rec
    );
   -- included to fix bug 1717501 begin
    l_x_old_Line_Adj_rec			:= l_x_Line_Adj_rec;
   -- included to fix bug 1717501 end

   l_x_line_adj_rec.price_adjustment_id	:= p_price_adjustment_id;
   l_x_line_adj_rec.adjusted_amount		:= p_adjusted_amount;


   /* Bug 1944975 - dual UOMs
      We pass the per_pqty values also
   */
   IF (p_adjusted_amount_per_pqty is NOT NULL) Then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'NOT NULL ADJPQTY ' || P_ADJUSTED_AMOUNT_PER_PQTY ) ;
     END IF;
     l_x_line_adj_rec.adjusted_amount_per_pqty := p_adjusted_amount_per_pqty;
   END IF;

   IF (p_operand_per_pqty is NOT NULL) Then
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'NOT NULL OPQTY ' || P_OPERAND_PER_PQTY ) ;
       END IF;
       l_x_line_adj_rec.operand_per_pqty := p_operand_per_pqty;
   ELSE
   --IF (p_operand_per_pqty IS NULL) THEN
    If l_x_line_adj_rec.line_id is not Null
       and l_x_line_adj_rec.list_line_type_code <> 'LUMPSUM'
    Then
        Oe_Oe_Form_Line.Get_Line(p_line_id=>l_x_line_adj_rec.line_id,
                                x_line_rec=>l_line_rec);

        If nvl(l_line_rec.pricing_quantity,0) <> 0 Then
            l_x_line_adj_rec.adjusted_amount_per_pqty := (p_adjusted_amount * l_line_rec.Ordered_Quantity)/l_line_rec.pricing_quantity;
        End If;
    End If;
   --End If;
 END IF; -- if p_operand_per_pqty is NOT NULL


   If l_x_line_adj_rec.adjusted_amount_per_pqty is Null Then
     l_x_line_adj_rec.adjusted_amount_per_pqty := p_adjusted_amount;
   END IF;

   l_x_line_adj_rec.arithmetic_operator	:= p_arithmetic_operator;
   l_x_line_adj_rec.operand			:= p_operand;

   IF (p_operand_per_pqty IS NULL) THEN
    If l_x_line_adj_rec.line_id is not Null
       and l_x_line_adj_rec.list_line_type_code <> 'LUMPSUM'
    Then
        Oe_Oe_Form_Line.Get_Line(p_line_id=>l_x_line_adj_rec.line_id,
                                x_line_rec=>l_line_rec);

        If nvl(l_line_rec.pricing_quantity,0) <> 0 Then
            l_x_line_adj_rec.operand_per_pqty := (p_operand * l_line_rec.Ordered_Quantity)/l_line_rec.pricing_quantity;
        End If;
    End If;
   End If;

   IF l_x_line_adj_rec.operand_per_pqty is Null  THEN
     l_x_line_adj_rec.operand_per_pqty := p_operand;
   END IF;

   l_x_line_adj_rec.applied_flag		:= p_applied_flag;
   l_x_line_adj_rec.updated_flag		:= p_updated_flag;

   If p_change_reason_code Is Not Null Then
     l_x_line_adj_rec.change_reason_code := p_change_reason_code;
   End If;

   If p_change_reason_text Is Not Null Then
     l_x_line_adj_rec.change_reason_text := p_change_reason_text;
   End If;

   l_x_Line_Adj_rec.operation			:= OE_GLOBALS.G_OPR_UPDATE;

   l_x_Line_Adj_tbl(1)			:= l_x_Line_Adj_rec;
  -- commented to fix bug 1717501 Begin
  --   l_x_old_Line_Adj_rec			:= l_x_Line_Adj_rec;
  -- commented to fix bug 1717501 end
   l_x_old_line_adj_rec.operand := null;
   l_x_old_Line_Adj_tbl(1)		:= l_x_old_Line_Adj_rec;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE EXECUTING PROCESS_ORDER...' , 1 ) ;
    END IF;

    -- Call Oe_Order_Adj_Pvt.Line_Adj
    oe_order_adj_pvt.Line_Adjs
    (	p_init_msg_list		=> FND_API.G_TRUE
    ,	p_validation_level 		=> FND_API.G_VALID_LEVEL_NONE
    ,	p_control_rec			=> l_control_rec
    ,	p_x_line_adj_tbl		=> l_x_Line_Adj_tbl
    ,	p_x_old_line_adj_tbl	=> l_x_old_Line_Adj_tbl
    );



    --  Load OUT parameters.
    l_x_Line_Adj_rec := l_x_Line_Adj_tbl(1);

    IF l_x_Line_Adj_rec.return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_x_Line_Adj_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER EXECUTING PROCESS_ORDER...' , 1 ) ;
    END IF;

    --  Write to cache.
    Write_Line_Adj
      (   p_Line_Adj_rec                => l_x_line_adj_tbl(1),
	  p_db_record			=> TRUE
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

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE_ADJ.REPLACE_ATTRIBUTES' , 1 ) ;
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

	ROLLBACK TO SAVEPOINT replace_attributes;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

	ROLLBACK TO SAVEPOINT replace_attributes;

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Replace_Attributes'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

	ROLLBACK TO SAVEPOINT replace_attributes;

END replace_attributes;



--  Procedure       lock_Row
--

PROCEDURE Lock_Row
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_price_adjustment_id           IN  NUMBER
,   p_lock_control		           IN  NUMBER
)
IS
l_return_status               VARCHAR2(1);
l_Line_Adj_rec                OE_Order_PUB.Line_Adj_Rec_Type;
l_Line_Adj_tbl                OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_ADJ.LOCK_ROW' , 1 ) ;
    END IF;

    --  Load Line_Adj record

    l_x_Line_Adj_rec.operation := OE_GLOBALS.G_OPR_LOCK;
    l_x_Line_Adj_rec.lock_control := p_lock_control;
    l_x_Line_Adj_rec.price_adjustment_id := p_price_adjustment_id;

    OE_Line_Adj_Util.Lock_Row
    ( x_return_status	=> l_return_status
    , p_x_line_adj_rec	=> l_x_line_adj_rec
    );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.
        l_x_Line_Adj_rec.db_flag := FND_API.G_TRUE;

        Write_Line_Adj
        (   p_Line_Adj_rec                => l_x_Line_Adj_rec
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
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE_ADJ.LOCK_ROW' , 1 ) ;
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

PROCEDURE Write_Line_Adj
(   p_Line_Adj_rec                IN  OE_Order_PUB.Line_Adj_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_ADJ.WRITE_LINE_ADJ' , 1 ) ;
    END IF;

    g_Line_Adj_rec := p_Line_Adj_rec;

    IF p_db_record THEN

        g_db_Line_Adj_rec := p_Line_Adj_rec;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE_ADJ.WRITE_LINE_ADJ' , 1 ) ;
    END IF;

END Write_Line_Adj;


PROCEDURE Get_Line_Adj
(   p_db_record               IN  BOOLEAN := FALSE
,   p_price_adjustment_id     IN  NUMBER
,   x_Line_Adj_rec			IN OUT NOCOPY	OE_Order_PUB.Line_Adj_Rec_Type
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_ADJ.GET_LINE_ADJ' , 1 ) ;
    END IF;

    IF  p_price_adjustment_id <> g_Line_Adj_rec.price_adjustment_id
    THEN

        --  Query row from DB

        OE_Line_Adj_Util.Query_Row
        (   p_price_adjustment_id       => p_price_adjustment_id
	   ,   x_Line_Adj_rec			=> g_Line_Adj_rec
        );

        g_Line_Adj_rec.db_flag         := FND_API.G_TRUE;

        --  Load DB record

        g_db_Line_Adj_rec              := g_Line_Adj_rec;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE_ADJ.GET_LINE_ADJ' , 1 ) ;
    END IF;

    IF p_db_record THEN

        -- RETURN g_db_Line_Adj_rec;
        x_Line_Adj_rec :=  g_db_Line_Adj_rec;

    ELSE

       -- RETURN g_Line_Adj_rec;
        x_Line_Adj_rec := g_Line_Adj_rec;

    END IF;

END Get_Line_Adj;


PROCEDURE Clear_Line_Adj
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_ADJ.CLEAR_LINE_ADJ' , 1 ) ;
    END IF;

    g_Line_Adj_rec                 := OE_Order_PUB.G_MISS_LINE_ADJ_REC;
    g_db_Line_Adj_rec              := OE_Order_PUB.G_MISS_LINE_ADJ_REC;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE_ADJ.CLEAR_LINE_ADJ' , 1 ) ;
    END IF;

END Clear_Line_Adj;

--Manual Begin
Procedure Insert_Row(p_line_adj_rec In Oe_Order_Pub.line_adj_rec_type
,x_return_status OUT NOCOPY VARCHAR2

,x_msg_count OUT NOCOPY NUMBER

,x_msg_data OUT NOCOPY VARCHAR2

,x_price_adjustment_id OUT NOCOPY NUMBER) Is

l_Control_Rec OE_GLOBALS.Control_Rec_Type;
l_line_adj_tbl Oe_Order_Pub.line_adj_tbl_type;
l_line_rec     Oe_Order_Pub.line_rec_type;
l_dummy_tbl    Oe_Order_Pub.line_adj_tbl_type;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  l_line_adj_tbl(1) := p_line_adj_rec;
  l_control_rec.private_call      := TRUE;
  l_control_rec.controlled_operation :=TRUE;
  l_control_rec.check_security    := TRUE;
  l_control_rec.validate_entity   := FALSE;
  l_control_rec.write_to_db       := TRUE;
  --l_control_rec.change_attributes := FALSE;
  l_control_rec.change_attributes := TRUE;

  -- lagrawal Bug 3673050
  OE_GLOBALS.G_UI_FLAG := TRUE;

  If l_line_adj_tbl(1).operand_per_pqty is NULL Then
    If l_line_adj_tbl(1).line_id is not Null
       and l_line_adj_tbl(1).list_line_type_code Not In ('%','LUMPSUM')
    Then
       Oe_Oe_Form_Line.Get_Line(p_line_id=>l_line_adj_tbl(1).line_id,
                                x_line_rec=>l_line_rec);

       If nvl(l_line_rec.pricing_quantity,0) <> 0 Then
            l_line_adj_tbl(1).operand_per_pqty := (l_line_adj_tbl(1).operand * l_line_rec.Ordered_Quantity)/l_line_rec.pricing_quantity;
       End If;
    End If;

      If l_line_adj_tbl(1).operand_per_pqty is Null Then
        --still null after above deriviation
        l_line_adj_tbl(1).operand_per_pqty:=l_line_adj_tbl(1).operand;
      End If;

  End If;

  If l_line_adj_tbl(1).adjusted_amount_per_pqty is NULL  Then

       If l_line_rec.line_id Is Null and l_line_adj_tbl(1).line_id is not null Then
         --get line only if this line_rec does not exists
         Oe_Oe_Form_Line.Get_Line(p_line_id=>l_line_adj_tbl(1).line_id,
                                x_line_rec=>l_line_rec);
       End If;

        If nvl(l_line_rec.pricing_quantity,0) <> 0
           and  l_line_adj_tbl(1).list_line_type_code <> 'LUMPSUM' Then
            l_line_adj_tbl(1).adjusted_amount_per_pqty := (l_line_adj_tbl(1).adjusted_amount * l_line_rec.Ordered_Quantity)/l_line_rec.pricing_quantity;
       End If;

    If l_line_adj_tbl(1).adjusted_amount_per_pqty is Null Then
       l_line_adj_tbl(1).adjusted_amount_per_pqty:=l_line_adj_tbl(1).adjusted_amount;
    End If;
  End If;

  l_line_adj_tbl(1).operation          := OE_GLOBALS.G_OPR_CREATE;


  IF l_line_adj_tbl(1).range_break_quantity IS NULL
     AND l_line_adj_tbl(1).list_line_type_code = 'PBH'
     AND  nvl(l_Line_Adj_Tbl(1).list_line_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
  THEN

     IF  l_line_adj_tbl(1).UPDATED_FLAG IS NULL THEN
        l_line_adj_tbl(1).UPDATED_FLAG := 'Y';
     END IF;

     BEGIN
              SELECT line_quantity
              INTO   l_Line_Adj_tbl(1).range_break_quantity
              FROM   qp_preq_ldets_tmp
              WHERE  created_from_list_line_id = l_Line_Adj_tbl(1).list_line_id
              AND    pricing_status_code = 'N'
              AND    rownum = 1;

     EXCEPTION WHEN OTHERS THEN
              -- lagrawal bug 3673050
	      OE_GLOBALS.G_UI_FLAG := FALSE;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  ' IN OE_OE_FORM_LINE_ADJ.INSER_ROW:'||SQLERRM ) ;
              END IF;
     END;
  END IF;

  IF l_debug_level  > 0 THEN
   oe_debug_pub.add(' FLADB:l_line_adj_tbl(1).automatic_flag:'||l_line_adj_tbl(1).automatic_flag);
   oe_debug_pub.add(' FLADB:l_line_adj_tbl(1).updated_flag IS:'||l_line_adj_tbl(1).updated_flag);
  END IF;

  IF l_line_adj_tbl(1).applied_flag = 'Y'
     AND l_line_adj_tbl(1).updated_flag IS NULL THEN
      l_line_adj_tbl(1).updated_flag := 'Y';
  END IF;

  IF l_line_adj_tbl(1).automatic_flag IS NULL THEN
     l_line_adj_tbl(1).automatic_flag:='N';
  END IF;

  SELECT  OE_PRICE_ADJUSTMENTS_S.NEXTVAL
  INTO    l_line_adj_tbl(1).price_adjustment_id
  FROM    Dual;


  Oe_Order_Adj_Pvt.Line_Adjs(p_validation_level => FND_API.G_VALID_LEVEL_NONE,
                                      p_control_rec      => l_control_rec,
                                      p_x_line_adj_tbl   => l_line_adj_tbl,
                                      p_x_old_line_adj_tbl => l_dummy_tbl);
 x_price_adjustment_id := l_line_adj_tbl(1).price_adjustment_id;

 -- lagrawal bug 3673050
 OE_GLOBALS.G_UI_FLAG := FALSE;
Exception
   WHEN OTHERS THEN

	OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Oe_Oe_Form_Line_Adj.Insert_Row:'||SQLERRM
                );
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OE_OE_FORM_LINE_ADJ.INSERT_ROW:'||SQLERRM ) ;
        END IF;
        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

	--ROLLBACK TO SAVEPOINT

End;
--Manual End;


--This procedure returns related line ids given a top_model_line_Id.
--If p_mode is set to 'OPTION' it will return options for this top_model_line
--If p_mode is set to 'SERVICE' it will return service lines for options line of a top_model_line
Procedure Get_Option_Service_Lines(p_top_model_line_id In Number,
                                   p_service_line_id   In Number Default null,
                                   p_mode              In VARCHAR2 Default 'SERVICE',
x_line_id_tbl out nocopy Oe_Order_Adj_Pvt.Index_Tbl_Type) Is

Cursor service_cur is
Select b.line_id
From   oe_order_lines_all a,
       oe_order_lines_all b,
       oe_order_lines_all c
Where  a.top_model_line_id = p_top_model_line_id
and    a.line_id <> p_top_model_line_id
and    a.line_id = b.service_reference_line_id
and    c.line_id = p_service_line_id
and    c.inventory_item_id = b.inventory_item_id
and    nvl(c.service_start_date,SYSDATE) = nvl(b.service_start_date,SYSDATE)
and    nvl(c.service_end_date,SYSDATE) = nvl(b.service_end_date,SYSDATE)
and    nvl(c.service_duration,0) = nvl(b.service_duration,0);



Cursor option_cur is
Select line_id
From oe_order_lines_all
Where top_model_line_id = p_top_model_line_id
and   line_id <> p_top_model_line_id;

j PLS_INTEGER := 1;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  ' P_MODE:'||P_MODE ) ;
 END IF;
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  ' P_TOP_MODEL_LINE_ID:'||P_TOP_MODEL_LINE_ID ) ;
 END IF;
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  ' P_SERVICE_LINE_ID:'||P_SERVICE_LINE_ID ) ;
 END IF;

If p_mode = 'SERVICE' Then
 For i in service_cur Loop
   x_line_id_tbl(j):= i.line_id;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' SERVICE CHILD LINES ID:'||I.LINE_ID ) ;
   END IF;
   j:=j+1;
 End Loop;
Elsif p_mode = 'OPTION' Then
 For i in option_cur Loop
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' LINE ID:'||I.LINE_ID ) ;
   END IF;
   x_line_id_tbl(j):= i.line_id;
   j:=j+1;
 End Loop;
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  ' X_LINE_ID_TBL.COUNT:'|| X_LINE_ID_TBL.COUNT ) ;
 END IF;
End If;
Exception When Others Then
IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  ' EXECPTION IN OE_OE_FORM_LINE_ADJ:'||SQLERRM ) ;
END IF;
End;

--This Procedure will either change,create or delete adjustments
--based on parent adjustment record
Procedure Process_Adj(p_parent_adj_rec In Oe_Order_Pub.Line_Adj_Rec_Type,
                      p_line_id_tbl    In Oe_Order_Adj_Pvt.Index_Tbl_Type,
                      p_delete_flag    In Varchar2 Default 'N' ,
                      p_create_adj_no_validate In Boolean Default FALSE) Is

Cursor adjustment_cur(p_list_line_id Number ,p_line_id Number) Is
Select price_adjustment_id,operand,change_reason_code
From   oe_price_adjustments
Where  line_id = p_line_id
and    list_line_id = p_list_line_id;

i PLS_INTEGER;
l_price_adjustment_id Number;
l_operand Number;
l_line_adj_rec Oe_Order_Pub.line_adj_rec_type;
l_return_status VARCHAR2(5);
l_msg_count     Number;
l_msg_data      VARCHAR2(500);
lx_price_adjustment_id Number;
l_reason_code Varchar2(30);
stmt Number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

  If nvl(p_parent_adj_rec.operand,FND_API.G_MISS_NUM) =  FND_API.G_MISS_NUM Then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' CS PARENT OPERAND IS NULL' ) ;
    END IF;
    Return;
  End If;

  i := p_line_id_tbl.First;
  While i is Not Null Loop
   stmt:=1;
   l_price_adjustment_id := Null;
   Open adjustment_cur(p_parent_adj_rec.list_line_id,p_line_id_tbl(i));
   Fetch adjustment_cur into l_price_adjustment_id,l_operand,l_reason_code;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' CS PRICE ADJUSTMENT ID:'||L_PRICE_ADJUSTMENT_ID ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' CS L_OPERAND:'||L_OPERAND ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' CS PARENT OPERAND:'||P_PARENT_ADJ_REC.OPERAND ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' CS SERVICE OPTION LINE ID:'|| P_LINE_ID_TBL ( I ) ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' CS PARENT LIST_LINE_ID:'||P_PARENT_ADJ_REC.LIST_LINE_ID ) ;
   END IF;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' CS PARENT CHANGE REASON CODE:'||P_PARENT_ADJ_REC.CHANGE_REASON_CODE ) ;
   END IF;
   If p_delete_flag = 'N' Then
    If l_price_adjustment_id is Not Null Then
     --Update required, a same adjustment exists
     If l_operand     <> p_parent_adj_rec.operand or
        nvl(l_reason_code,'NULLreasonCode+') <> p_parent_adj_rec.change_reason_code Then

      If p_parent_adj_rec.change_reason_code is Null Then
        l_reason_code:='MISC';
      Else
        l_reason_code:=p_parent_adj_rec.change_reason_code;
      End If;
      stmt:=2;
      Replace_Attributes(x_return_status       => l_return_status,
                        x_msg_count           => l_msg_count,
                        x_msg_data            => l_msg_data,
                        p_price_adjustment_id => l_price_adjustment_id,
                        p_adjusted_amount     => p_parent_adj_rec.adjusted_amount,
			p_adjusted_amount_per_pqty =>p_parent_adj_rec.adjusted_amount_per_pqty,
			p_arithmetic_operator =>   p_parent_adj_rec.arithmetic_operator,
			p_operand             =>   p_parent_adj_rec.operand,
			p_operand_per_pqty    =>   p_parent_adj_rec.operand_per_pqty,
			p_applied_flag        =>   'Y',
			p_updated_flag        =>   'Y',
                        p_change_reason_code  =>   l_reason_code,
                        p_change_reason_text  =>   'Top model line adjustments has been changed');
     End If;
    Else
     If p_create_adj_no_validate Then  --just create adjustment without revalidation against engine
     --Create requiredx
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  ' CS INSERTING NEW CHILDREN' ) ;
     END IF;
     l_line_adj_Rec := p_parent_adj_rec;
     l_line_adj_rec.line_id := p_line_id_tbl(i);
     stmt:=3;
     Insert_Row(l_line_adj_Rec,l_return_status,l_msg_count,l_msg_data,lx_price_adjustment_id);
      /* 1905650
	 G_PRICE_ADJ request should be logged against LINE entity, not
	 against LINE_ADJ entity
      */
      oe_delayed_requests_pvt.log_request(
		p_entity_code    	     => OE_GLOBALS.G_ENTITY_LINE,
		p_entity_id      	     => p_line_id_tbl(i),
		p_requesting_entity_code     => OE_GLOBALS.G_ENTITY_LINE_ADJ,
		p_requesting_entity_id       => p_line_id_tbl(i),
		p_request_type   	     => OE_GLOBALS.G_PRICE_ADJ,
		x_return_status  	     => l_return_status);
     End If;  --end if for create_adj_no_validate
    End If;
   Elsif p_delete_flag = 'Y' Then
           If l_price_adjustment_id is not Null Then
            stmt:=4;
            OE_Header_Adj_Util.Delete_Row
                (   p_price_adjustment_id         => l_price_adjustment_id
                );

	      /* 1905650
	         G_PRICE_ADJ request should be logged against LINE entity,
	         not against LINE_ADJ entity
	      */
              oe_delayed_requests_pvt.log_request(
		p_entity_code    	     => OE_GLOBALS.G_ENTITY_LINE,
		p_entity_id      	     => p_line_id_tbl(i),
		p_requesting_entity_code     => OE_GLOBALS.G_ENTITY_LINE_ADJ,
		p_requesting_entity_id       => p_line_id_tbl(i),
		p_request_type   	     => OE_GLOBALS.G_PRICE_ADJ,
		x_return_status  	     => l_return_status);

           End If;
   End If;





   Close adjustment_cur;
   i:=p_line_id_tbl.next(i);
  End Loop;

Exception When Others Then
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'IN OE_OE_FORM_LINE_ADJ.PROCESS_ADJ:'||SQLERRM||':'||STMT ) ;
  END IF;
End;


END OE_OE_Form_Line_Adj;

/
