--------------------------------------------------------
--  DDL for Package Body OE_OE_FORM_LINE_PAYMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_FORM_LINE_PAYMENT" AS
/* $Header: OEXFLPMB.pls 120.4.12010000.5 2009/12/08 12:48:31 msundara ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_OE_Form_Line_Payment';

--  Global variables holding cached record.

g_Line_Payment_rec          OE_Order_PUB.Line_PAYMENT_Rec_Type;
g_db_Line_Payment_rec       OE_Order_PUB.Line_PAYMENT_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_Line_Payment
(   p_Line_Payment_rec            IN  OE_Order_PUB.Line_PAYMENT_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

PROCEDURE Get_Line_Payment
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_payment_number                IN  NUMBER
,   p_line_id                       IN  NUMBER
,   p_header_id                     IN  NUMBER
,   x_line_Payment_rec            OUT NOCOPY OE_Order_PUB.Line_PAYMENT_Rec_Type
);

PROCEDURE Clear_Line_Payment;

--  Global variable holding performed operations.

g_opr__tbl                    OE_Order_PUB.Line_Payment_Tbl_Type;

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_payment_number                IN  NUMBER
,   p_line_id                       IN  NUMBER
,   x_payment_number                OUT NOCOPY NUMBER
,   x_attribute1                    OUT NOCOPY VARCHAR2
,   x_attribute2                    OUT NOCOPY VARCHAR2
,   x_attribute3                    OUT NOCOPY VARCHAR2
,   x_attribute4                    OUT NOCOPY VARCHAR2
,   x_attribute5                    OUT NOCOPY VARCHAR2
,   x_attribute6                    OUT NOCOPY VARCHAR2
,   x_attribute7                    OUT NOCOPY VARCHAR2
,   x_attribute8                    OUT NOCOPY VARCHAR2
,   x_attribute9                    OUT NOCOPY VARCHAR2
,   x_attribute10                   OUT NOCOPY VARCHAR2
,   x_attribute11                   OUT NOCOPY VARCHAR2
,   x_attribute12                   OUT NOCOPY VARCHAR2
,   x_attribute13                   OUT NOCOPY VARCHAR2
,   x_attribute14                   OUT NOCOPY VARCHAR2
,   x_attribute15                   OUT NOCOPY VARCHAR2
,   x_context                       OUT NOCOPY VARCHAR2
,   x_header_id                     OUT NOCOPY NUMBER
,   x_line_id                       OUT NOCOPY NUMBER
,   x_check_number                  OUT NOCOPY VARCHAR2
,   x_credit_card_approval_code     OUT NOCOPY VARCHAR2
,   x_credit_card_approval_date     OUT NOCOPY DATE
,   x_credit_card_code              OUT NOCOPY VARCHAR2
,   x_credit_card_expiration_date   OUT NOCOPY DATE
,   x_credit_card_holder_name       OUT NOCOPY VARCHAR2
,   x_credit_card_number            OUT NOCOPY VARCHAR2
,   x_payment_level_code            OUT NOCOPY VARCHAR2
,   x_commitment_applied_amount     OUT NOCOPY NUMBER
,   x_commitment_interfaced_amount  OUT NOCOPY NUMBER
,   x_payment_amount                OUT NOCOPY NUMBER
,   x_payment_collection_event      OUT NOCOPY VARCHAR2
,   x_payment_trx_id                OUT NOCOPY NUMBER
,   x_payment_type_code             OUT NOCOPY VARCHAR2
,   x_payment_set_id                OUT NOCOPY NUMBER
,   x_prepaid_amount                OUT NOCOPY NUMBER
,   x_receipt_method_id             OUT NOCOPY NUMBER
,   x_tangible_id                   OUT NOCOPY VARCHAR2
,   x_receipt_method                 OUT NOCOPY VARCHAR2
,   x_pmt_collection_event_name  OUT NOCOPY VARCHAR2
,   x_payment_type                  OUT NOCOPY VARCHAR2
,   x_defer_processing_flag         OUT NOCOPY VARCHAR2
,   x_trxn_extension_id             OUT NOCOPY NUMBER  --R12 process order api changes
,   x_instrument_security_code OUT NOCOPY VARCHAR2 --R12 CC Encryption
)
IS
l_Line_Payment_val_rec      OE_Order_PUB.Line_Payment_Val_Rec_Type;
l_control_rec               OE_GLOBALS.Control_Rec_Type;
l_return_status             VARCHAR2(1);
l_x_Line_Payment_tbl        OE_Order_PUB.Line_Payment_Tbl_Type;
l_x_Old_Line_Payment_tbl    OE_Order_PUB.Line_Payment_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_header_id NUMBER := NULL;

BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_PAYMENT.DEFAULT_ATTRIBUTES' , 1 ) ;
    END IF;

    BEGIN

      IF p_line_id is not null THEN

        select header_id into l_header_id
        from oe_order_lines_all
        where line_id = p_line_id;

      END IF;

    END;

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
    l_x_Line_Payment_tbl(1):=OE_ORDER_PUB.G_MISS_LINE_PAYMENT_REC;
    l_x_old_Line_Payment_Tbl(1):=OE_ORDER_PUB.G_MISS_LINE_PAYMENT_REC;

    l_x_Line_Payment_tbl(1).payment_number         := p_payment_number;
    l_x_Line_Payment_tbl(1).line_id                := p_line_id;
    l_x_Line_Payment_tbl(1).header_id                := l_header_id;
    l_x_Line_Payment_tbl(1).payment_collection_event := 'INVOICE';
    l_x_Line_Payment_tbl(1).payment_level_code := 'LINE';


    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

    l_x_line_Payment_tbl(1).attribute1               := NULL;
    l_x_line_Payment_tbl(1).attribute2               := NULL;
    l_x_line_Payment_tbl(1).attribute3               := NULL;
    l_x_line_Payment_tbl(1).attribute4               := NULL;
    l_x_line_Payment_tbl(1).attribute5               := NULL;
    l_x_line_Payment_tbl(1).attribute6               := NULL;
    l_x_line_Payment_tbl(1).attribute7               := NULL;
    l_x_line_Payment_tbl(1).attribute8               := NULL;
    l_x_line_Payment_tbl(1).attribute9               := NULL;
    l_x_line_Payment_tbl(1).attribute10              := NULL;
    l_x_line_Payment_tbl(1).attribute11              := NULL;
    l_x_line_Payment_tbl(1).attribute12              := NULL;
    l_x_line_Payment_tbl(1).attribute13              := NULL;
    l_x_line_Payment_tbl(1).attribute14              := NULL;
    l_x_line_Payment_tbl(1).attribute15              := NULL;
    l_x_line_Payment_tbl(1).context                  := NULL;

    --  Set Operation to Create

    l_x_Line_Payment_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;

    --  Populate Line_Payment table


    --  Call OE_Order_PVT.Process_order


    OE_Order_PVT.Line_Payments
    (   p_validation_level          => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list             => FND_API.G_TRUE
    ,   p_control_rec               => l_control_rec
    ,   p_x_Line_Payment_tbl        => l_x_Line_Payment_tbl
    ,   p_x_old_Line_Payment_tbl    => l_x_old_Line_Payment_tbl
    ,   x_return_Status             => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --  Load OUT parameters.

    x_attribute1                   := l_x_line_Payment_tbl(1).attribute1;
    x_attribute10                  := l_x_line_Payment_tbl(1).attribute10;
    x_attribute11                  := l_x_line_Payment_tbl(1).attribute11;
    x_attribute12                  := l_x_line_Payment_tbl(1).attribute12;
    x_attribute13                  := l_x_line_Payment_tbl(1).attribute13;
    x_attribute14                  := l_x_line_Payment_tbl(1).attribute14;
    x_attribute15                  := l_x_line_Payment_tbl(1).attribute15;
    x_attribute2                   := l_x_line_Payment_tbl(1).attribute2;
    x_attribute3                   := l_x_line_Payment_tbl(1).attribute3;
    x_attribute4                   := l_x_line_Payment_tbl(1).attribute4;
    x_attribute5                   := l_x_line_Payment_tbl(1).attribute5;
    x_attribute6                   := l_x_line_Payment_tbl(1).attribute6;
    x_attribute7                   := l_x_line_Payment_tbl(1).attribute7;
    x_attribute8                   := l_x_line_Payment_tbl(1).attribute8;
    x_attribute9                   := l_x_line_Payment_tbl(1).attribute9;
    x_context                      := l_x_line_Payment_tbl(1).context;
    x_payment_number               := l_x_line_Payment_tbl(1).payment_number;
    x_header_id                    := l_x_line_Payment_tbl(1).header_id;
    x_line_id                      := l_x_line_Payment_tbl(1).line_id;
    x_check_number                 := l_x_line_Payment_tbl(1).check_number;
    x_credit_card_approval_code    := l_x_line_Payment_tbl(1).credit_card_approval_code;
    x_credit_card_approval_date    := l_x_line_Payment_tbl(1).credit_card_approval_date;
    x_credit_card_code             := l_x_line_Payment_tbl(1).credit_card_code;
    x_credit_card_expiration_date  := l_x_line_Payment_tbl(1).credit_card_expiration_date;
    x_credit_card_holder_name      := l_x_line_Payment_tbl(1).credit_card_holder_name;
    x_credit_card_number           := l_x_line_Payment_tbl(1).credit_card_number;
    x_payment_level_code           := l_x_line_Payment_tbl(1).payment_level_code;
    x_commitment_applied_amount    := l_x_line_Payment_tbl(1).commitment_applied_amount;
    x_commitment_interfaced_amount := l_x_line_Payment_tbl(1).commitment_interfaced_amount;
    x_payment_amount               := l_x_line_Payment_tbl(1).payment_amount;
    x_payment_collection_event     := l_x_line_Payment_tbl(1).payment_collection_event;
    x_defer_processing_flag     := l_x_line_Payment_tbl(1).defer_payment_processing_flag;
    x_payment_trx_id               := l_x_line_Payment_tbl(1).payment_trx_id;
    x_payment_type_code            := l_x_line_Payment_tbl(1).payment_type_code;
    x_payment_set_id               := l_x_line_Payment_tbl(1).payment_set_id;
    x_prepaid_amount               := l_x_line_Payment_tbl(1).prepaid_amount;
    x_receipt_method_id            := l_x_line_Payment_tbl(1).receipt_method_id;
    x_tangible_id                  := l_x_line_Payment_tbl(1).tangible_id;
    x_trxn_extension_id            := l_x_line_Payment_tbl(1).trxn_extension_id;   --R12 process order api changes
    x_instrument_security_code := l_x_line_Payment_tbl(1).instrument_security_code; --R12 CC Encryption

    --  Load display out parameters if any

    l_Line_Payment_val_rec := OE_Line_Payment_Util.Get_Values
    (   p_Line_Payment_rec          => l_x_Line_Payment_tbl(1)
    );
    x_receipt_method                    := l_Line_Payment_val_rec.receipt_method;
    x_pmt_collection_event_name     := l_Line_Payment_val_rec.payment_collection_event_name;
    x_payment_type                      := l_Line_Payment_val_rec.payment_type;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_Line_Payment_tbl(1).db_flag := FND_API.G_FALSE;

    Write_Line_Payment
    (   p_Line_Payment_rec          => l_x_Line_PAYMENT_tbl(1)
    );

    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE_Payment.DEFAULT_ATTRIBUTES' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Default_Attributes'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Default_Attributes;

--  Procedure   :   Change_Attribute
--

PROCEDURE Change_Attribute
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_payment_number                IN  NUMBER
,   p_line_id                       IN  NUMBER
,   p_header_id                     IN  NUMBER
,   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   p_attr_id_tbl                   IN  Number_Tbl_Type --R12 CC Encryption
,   p_attr_value_tbl                IN  Varchar2_Tbl_Type --R12 CC Encryption
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
,   p_context                       IN  VARCHAR2
,   x_attribute1                    OUT NOCOPY VARCHAR2
,   x_attribute2                    OUT NOCOPY VARCHAR2
,   x_attribute3                    OUT NOCOPY VARCHAR2
,   x_attribute4                    OUT NOCOPY VARCHAR2
,   x_attribute5                    OUT NOCOPY VARCHAR2
,   x_attribute6                    OUT NOCOPY VARCHAR2
,   x_attribute7                    OUT NOCOPY VARCHAR2
,   x_attribute8                    OUT NOCOPY VARCHAR2
,   x_attribute9                    OUT NOCOPY VARCHAR2
,   x_attribute10                   OUT NOCOPY VARCHAR2
,   x_attribute11                   OUT NOCOPY VARCHAR2
,   x_attribute12                   OUT NOCOPY VARCHAR2
,   x_attribute13                   OUT NOCOPY VARCHAR2
,   x_attribute14                   OUT NOCOPY VARCHAR2
,   x_attribute15                   OUT NOCOPY VARCHAR2
,   x_context                       OUT NOCOPY VARCHAR2
,   x_payment_number                OUT NOCOPY NUMBER
,   x_header_id                     OUT NOCOPY NUMBER
,   x_line_id                       OUT NOCOPY NUMBER
,   x_check_number                  OUT NOCOPY VARCHAR2
,   x_credit_card_approval_code     OUT NOCOPY VARCHAR2
,   x_credit_card_approval_date     OUT NOCOPY DATE
,   x_credit_card_code              OUT NOCOPY VARCHAR2
,   x_credit_card_expiration_date   OUT NOCOPY DATE
,   x_credit_card_holder_name       OUT NOCOPY VARCHAR2
,   x_credit_card_number            OUT NOCOPY VARCHAR2
,   x_payment_level_code            OUT NOCOPY VARCHAR2
,   x_commitment_applied_amount     OUT NOCOPY NUMBER
,   x_commitment_interfaced_amount  OUT NOCOPY NUMBER
,   x_payment_amount                OUT NOCOPY NUMBER
,   x_payment_collection_event      OUT NOCOPY VARCHAR2
,   x_payment_trx_id                OUT NOCOPY NUMBER
,   x_payment_type_code             OUT NOCOPY VARCHAR2
,   x_payment_set_id                OUT NOCOPY NUMBER
,   x_prepaid_amount                OUT NOCOPY NUMBER
,   x_receipt_method_id             OUT NOCOPY NUMBER
,   x_tangible_id                   OUT NOCOPY VARCHAR2
,   x_receipt_method                OUT NOCOPY VARCHAR2
,   x_pmt_collection_event_name  OUT NOCOPY VARCHAR2
,   x_payment_type                  OUT NOCOPY VARCHAR2
,   x_defer_processing_flag         OUT NOCOPY VARCHAR2
,   x_instrument_security_code OUT NOCOPY VARCHAR2 --R12 CC Encryption
)
IS
l_Line_Payment_rec          OE_Order_PUB.Line_PAYMENT_Rec_Type;
l_Line_Payment_val_rec      OE_Order_PUB.Line_PAYMENT_Val_Rec_Type;
l_x_Line_Payment_tbl          OE_Order_PUB.Line_PAYMENT_Tbl_Type;
l_x_old_Line_Payment_tbl      OE_Order_PUB.Line_PAYMENT_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_date_format_mask            VARCHAR2(30) := 'DD-MON-RRRR HH24:MI:SS';

BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_PAYMENT.CHANGE_ATTRIBUTE' , 1 ) ;
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

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read Line_Payment from cache
    Get_Line_Payment
    (   p_db_record                   => FALSE
    ,   p_payment_number              => p_payment_number
    ,   p_line_id                     => p_line_id
    ,   p_header_id		      => p_header_id
    ,   x_line_Payment_rec          => l_x_Line_PAYMENT_tbl(1)
    );

    l_x_old_Line_Payment_tbl(1)       := l_x_Line_PAYMENT_tbl(1);



    --R12 CC Encryption
    --The change attribute is now changed to handle change attributes
    --for multiple attributes in a single call. To support this, a
    --new procedure Copy_Attribute_To_Rec has been introduced. For any
    --new attributes that is added, the handling is done in this new
    --procedure going forward.

    Copy_Attribute_To_Rec
    (   p_attr_id         => p_attr_id
    ,   p_attr_value      => p_attr_value
    ,   x_line_payment_tbl => l_x_Line_PAYMENT_tbl
    ,   x_old_line_payment_tbl => l_x_old_Line_Payment_tbl
    ,   p_attribute1 => p_attribute1
    ,   p_attribute2 => p_attribute2
    ,   p_attribute3 => p_attribute3
    ,   p_attribute4 => p_attribute4
    ,   p_attribute5 => p_attribute5
    ,   p_attribute6 => p_attribute6
    ,   p_attribute7 => p_attribute7
    ,   p_attribute8 => p_attribute8
    ,   p_attribute9  => p_attribute9
    ,   p_attribute10 => p_attribute10
    ,   p_attribute11 => p_attribute11
    ,   p_attribute12 => p_attribute12
    ,   p_attribute13 => p_attribute13
    ,   p_attribute14 => p_attribute14
    ,   p_attribute15 => p_attribute15
    ,   p_context     => p_context
    );

    FOR l_index IN 1..p_attr_id_tbl.COUNT LOOP

           Copy_Attribute_To_Rec
	    (p_attr_id         => p_attr_id_tbl(l_index)
	    ,p_attr_value      => p_attr_value_tbl(l_index)
	    ,x_line_payment_tbl     => l_x_Line_PAYMENT_tbl
	    ,x_old_line_payment_tbl => l_x_old_Line_Payment_tbl
	    ,   p_attribute1 => p_attribute1
	    ,   p_attribute2 => p_attribute2
	    ,   p_attribute3 => p_attribute3
	    ,   p_attribute4 => p_attribute4
	    ,   p_attribute5 => p_attribute5
	    ,   p_attribute6 => p_attribute6
	    ,   p_attribute7 => p_attribute7
	    ,   p_attribute8 => p_attribute8
	    ,   p_attribute9  => p_attribute9
	    ,   p_attribute10 => p_attribute10
	    ,   p_attribute11 => p_attribute11
	    ,   p_attribute12 => p_attribute12
	    ,   p_attribute13 => p_attribute13
	    ,   p_attribute14 => p_attribute14
	    ,   p_attribute15 => p_attribute15
	    ,   p_context     => p_context
            );

    END LOOP;


    --  Set Operation.

    IF FND_API.To_Boolean(l_x_Line_Payment_tbl(1).db_flag) THEN
        l_x_Line_Payment_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_x_Line_Payment_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate Line_Payment table
    l_line_Payment_rec:=l_x_Line_PAYMENT_Tbl(1);
    --  Call OE_Order_PVT.Process_order
    oe_debug_pub.add('ren: before Line_Payments:  ' || p_attr_id);
    --oe_debug_pub.add('New Card number'||l_x_Line_PAYMENT_tbl(1).credit_card_number);
    --oe_debug_pub.add('New Card holder'||l_x_Line_PAYMENT_tbl(1).credit_card_holder_name);
    --oe_debug_pub.add('Old card number'||l_x_old_Line_PAYMENT_tbl(1).credit_card_number);

    OE_Order_PVT.Line_Payments
    (
        p_validation_level              => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                   => l_control_rec
    ,   p_x_Line_Payment_tbl          => l_x_Line_PAYMENT_tbl
    ,   p_x_old_Line_Payment_tbl      => l_x_old_Line_PAYMENT_tbl
    ,   x_return_status                 => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    oe_debug_pub.add('ren: before Line_Payments:  ' || p_attr_id);
    --oe_debug_pub.add('New Card number'||l_x_Line_PAYMENT_tbl(1).credit_card_number);
    --oe_debug_pub.add('New Card holder'||l_x_Line_PAYMENT_tbl(1).credit_card_holder_name);
    --oe_debug_pub.add('Old card number'||l_Line_Payment_rec.credit_card_number);
    --  Init OUT parameters to missing.

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
    x_context                      := FND_API.G_MISS_CHAR;
    x_check_number                 := FND_API.G_MISS_CHAR;
    x_credit_card_approval_code    := FND_API.G_MISS_CHAR;
    x_credit_card_approval_date    := FND_API.G_MISS_DATE;
    x_credit_card_code             := FND_API.G_MISS_CHAR;
    x_credit_card_expiration_date  := FND_API.G_MISS_DATE;
    x_credit_card_holder_name      := FND_API.G_MISS_CHAR;
    x_credit_card_number           := FND_API.G_MISS_CHAR;
    x_payment_level_code           := FND_API.G_MISS_CHAR;
    x_commitment_applied_amount    := FND_API.G_MISS_NUM;
    x_commitment_interfaced_amount := FND_API.G_MISS_NUM;
    x_payment_number               := FND_API.G_MISS_NUM;
    x_header_id                    := FND_API.G_MISS_NUM;
    x_line_id                      := FND_API.G_MISS_NUM;
    x_payment_amount               := FND_API.G_MISS_NUM;
    x_payment_collection_event     := FND_API.G_MISS_CHAR;
    x_payment_trx_id               := FND_API.G_MISS_NUM;
    x_payment_type_code            := FND_API.G_MISS_CHAR;
    x_payment_set_id               := FND_API.G_MISS_NUM;
    x_prepaid_amount               := FND_API.G_MISS_NUM;
    x_receipt_method_id            := FND_API.G_MISS_NUM;
    x_tangible_id                  := FND_API.G_MISS_CHAR;
    x_defer_processing_flag        := FND_API.G_MISS_CHAR;
    x_instrument_security_code     := FND_API.G_MISS_CHAR; --R12 Cc encryption

    --  Load display out parameters if any

    l_Line_Payment_val_rec := OE_Line_PAYMENT_Util.Get_Values
    (   p_Line_Payment_rec          => l_x_Line_PAYMENT_tbl(1)
    ,   p_old_Line_Payment_rec      => l_Line_PAYMENT_rec
    );

    --  Return changed attributes.

    IF NOT OE_GLOBALS.Equal(l_x_line_Payment_tbl(1).attribute1,
                            l_Line_Payment_rec.attribute1)
    THEN
        x_attribute1 := l_x_line_Payment_tbl(1).attribute1;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).attribute2,
                            l_Line_Payment_rec.attribute2)
    THEN
        x_attribute2 := l_x_Line_Payment_Tbl(1).attribute2;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).attribute3,
                            l_Line_Payment_rec.attribute3)
    THEN
        x_attribute3 := l_x_Line_Payment_Tbl(1).attribute3;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).attribute4,
                            l_Line_Payment_rec.attribute4)
    THEN
        x_attribute4 := l_x_Line_Payment_Tbl(1).attribute4;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).attribute5,
                            l_Line_Payment_rec.attribute5)
    THEN
        x_attribute5 := l_x_Line_Payment_Tbl(1).attribute5;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).attribute6,
                            l_Line_Payment_rec.attribute6)
    THEN
        x_attribute6 := l_x_Line_Payment_Tbl(1).attribute6;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).attribute7,
                            l_Line_Payment_rec.attribute7)
    THEN
        x_attribute7 := l_x_Line_Payment_Tbl(1).attribute7;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).attribute8,
                            l_Line_Payment_rec.attribute8)
    THEN
        x_attribute8 := l_x_Line_Payment_Tbl(1).attribute8;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).attribute9,
                            l_Line_Payment_rec.attribute9)
    THEN
        x_attribute9 := l_x_Line_Payment_Tbl(1).attribute9;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_line_Payment_tbl(1).attribute10,
                            l_Line_Payment_rec.attribute10)
    THEN
        x_attribute10 := l_x_line_Payment_tbl(1).attribute10;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_line_Payment_tbl(1).attribute11,
                            l_Line_Payment_rec.attribute11)
    THEN
        x_attribute11 := l_x_line_Payment_tbl(1).attribute11;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_line_Payment_tbl(1).attribute12,
                            l_Line_Payment_rec.attribute12)
    THEN
        x_attribute12 := l_x_line_Payment_tbl(1).attribute12;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_line_Payment_tbl(1).attribute13,
                            l_Line_Payment_rec.attribute13)
    THEN
        x_attribute13 := l_x_line_Payment_tbl(1).attribute13;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_line_Payment_tbl(1).attribute14,
                            l_Line_Payment_rec.attribute14)
    THEN
        x_attribute14 := l_x_line_Payment_tbl(1).attribute14;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_line_Payment_tbl(1).attribute15,
                            l_Line_Payment_rec.attribute15)
    THEN
        x_attribute15 := l_x_line_Payment_tbl(1).attribute15;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).context,
                            l_Line_Payment_rec.context)
    THEN
        x_context := l_x_Line_Payment_Tbl(1).context;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).payment_number,
                            l_Line_Payment_rec.payment_number)
    THEN
        x_payment_number := l_x_Line_Payment_Tbl(1).payment_number;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).header_id,
                            l_Line_Payment_rec.header_id)
    THEN
        x_header_id := l_x_Line_Payment_Tbl(1).header_id;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).line_id,
                            l_Line_Payment_rec.line_id)
    THEN
        x_line_id := l_x_Line_Payment_Tbl(1).line_id;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).check_number,
                            l_Line_Payment_rec.check_number)
    THEN
        x_check_number := l_x_Line_Payment_Tbl(1).check_number;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).credit_card_approval_code,
                            l_Line_Payment_rec.credit_card_approval_code)
    THEN
        x_credit_card_approval_code := l_x_Line_Payment_Tbl(1).credit_card_approval_code;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).credit_card_approval_date,
                            l_Line_Payment_rec.credit_card_approval_date)
    THEN
        x_credit_card_approval_date := l_x_Line_Payment_Tbl(1).credit_card_approval_date;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).credit_card_code,
                            l_Line_Payment_rec.credit_card_code)
    THEN
        x_credit_card_code := l_x_Line_Payment_Tbl(1).credit_card_code;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).credit_card_expiration_date,
                            l_Line_Payment_rec.credit_card_expiration_date)
    THEN
        x_credit_card_expiration_date := l_x_Line_Payment_Tbl(1).credit_card_expiration_date;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).credit_card_holder_name,
                            l_Line_Payment_rec.credit_card_holder_name)
    THEN
        x_credit_card_holder_name := l_x_Line_Payment_Tbl(1).credit_card_holder_name;
    END IF;

    IF NOT OE_GLOBALS.Is_Same_Credit_Card(l_Line_Payment_rec.credit_card_number,
                          l_x_Line_Payment_Tbl(1).credit_card_number,
			  l_Line_Payment_rec.cc_instrument_id,
 			  l_x_Line_Payment_Tbl(1).cc_instrument_id)
    THEN
        x_credit_card_number := l_x_Line_Payment_Tbl(1).credit_card_number;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).payment_level_code,
                            l_Line_Payment_rec.payment_level_code)
    THEN
        x_payment_level_code := l_x_Line_Payment_Tbl(1).payment_level_code;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).commitment_applied_amount,
                            l_Line_Payment_rec.commitment_applied_amount)
    THEN
        x_commitment_applied_amount := l_x_Line_Payment_Tbl(1).commitment_applied_amount;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).commitment_interfaced_amount,
                            l_Line_Payment_rec.commitment_interfaced_amount)
    THEN
        x_commitment_interfaced_amount := l_x_Line_Payment_Tbl(1).commitment_interfaced_amount;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).payment_amount,
                            l_Line_Payment_rec.payment_amount)
    THEN
        x_payment_amount := l_x_Line_Payment_Tbl(1).payment_amount;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).payment_collection_event,
                            l_Line_Payment_rec.payment_collection_event)
    THEN
        x_payment_collection_event := l_x_Line_Payment_Tbl(1).payment_collection_event;
        x_pmt_collection_event_name := l_Line_Payment_Val_Rec.payment_collection_event_name;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).defer_payment_processing_flag,
                            l_Line_Payment_rec.defer_payment_processing_flag)
    THEN
        x_defer_processing_flag := l_x_Line_Payment_Tbl(1).defer_payment_processing_flag;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).payment_trx_id,
                            l_Line_Payment_rec.payment_trx_id)
    THEN
        x_payment_trx_id := l_x_Line_Payment_Tbl(1).payment_trx_id;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).payment_type_code,
                            l_Line_Payment_rec.payment_type_code)
    THEN
        x_payment_type_code := l_x_Line_Payment_Tbl(1).payment_type_code;
        x_payment_type := l_Line_Payment_Val_rec.payment_type;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).payment_set_id,
                            l_Line_Payment_rec.payment_set_id)
    THEN
        x_payment_set_id := l_x_Line_Payment_Tbl(1).payment_set_id;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).prepaid_amount,
                            l_Line_Payment_rec.prepaid_amount)
    THEN
        x_prepaid_amount := l_x_Line_Payment_Tbl(1).prepaid_amount;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).receipt_method_id,
                            l_Line_Payment_rec.receipt_method_id)
    THEN
        x_receipt_method_id := l_x_Line_Payment_Tbl(1).receipt_method_id;
        x_receipt_method := l_Line_Payment_Val_rec.receipt_method;
    END IF;

    --R12 CC Encryption
    IF NOT OE_GLOBALS.Equal(l_x_Line_Payment_Tbl(1).instrument_security_code,
                            l_Line_Payment_rec.instrument_security_code)    THEN
	x_instrument_security_code := l_x_Line_Payment_Tbl(1).instrument_security_code;
    END IF;

    --If defaulting is enabled for credit card number, then need to populate the
    --instrument id and instrument assignment id returned by the Payments API in
    --OE_Default_Pvt package

    IF OE_Default_Pvt.g_default_instrument_id IS NOT NULL THEN
	l_x_Line_PAYMENT_tbl(1).cc_instrument_id := OE_Default_Pvt.g_default_instrument_id;
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('instr id in fhpmb for defaulting'||l_x_Line_PAYMENT_tbl(1).cc_instrument_id);
	END IF;
	--Setting the value of assignment id to null
	--after passing the value to the cache
	OE_Default_Pvt.g_default_instrument_id := null;
    END IF;

    IF OE_Default_Pvt.g_default_instr_assignment_id IS NOT NULL THEN
	l_x_Line_PAYMENT_tbl(1).cc_instrument_assignment_id := OE_Default_Pvt.g_default_instr_assignment_id;
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('assign id in fhpmb for defaulting'||l_x_Line_PAYMENT_tbl(1).cc_instrument_assignment_id);
	END IF;
	--Setting the value of assignment id to null
	--after passing the value to the cache
	OE_Default_Pvt.g_default_instr_assignment_id := null;
    END IF;
    --R12 CC Encryption

    --  Write to cache.

    Write_Line_Payment
    (   p_Line_Payment_rec          => l_x_Line_PAYMENT_tbl(1)
    );

    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE_PAYMENT.CHANGE_ATTRIBUTE' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Change_Attribute'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Change_Attribute;

--  R12 CC Encryption
--  Procedure       Copy_Attribute_To_Rec
--  This procedure is introduced in R12 to support
--  change attribute call for multiple attributes at one time
--  New attributes introduced going forward would have the code
--  in this procedure for change attributes.

PROCEDURE Copy_Attribute_To_Rec
(   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   x_line_payment_tbl            IN OUT NOCOPY OE_Order_PUB.Line_PAYMENT_Tbl_Type
,   x_old_line_payment_tbl        IN OUT NOCOPY OE_Order_PUB.Line_PAYMENT_Tbl_Type
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
,   p_context                       IN  VARCHAR2)
IS
l_date_format_mask            VARCHAR2(30) := 'DD-MON-RRRR HH24:MI:SS';
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_PAYMENT.Copy_Attribute_To_Rec' , 1 ) ;
        oe_debug_pub.add(' p_attr_id is : ' || p_attr_id);
	oe_debug_pub.add(' value is '||p_attr_value);
    END IF;

    IF p_attr_id = OE_Line_Payment_Util.G_CHECK_NUMBER THEN
        x_line_payment_tbl(1).check_number := p_attr_value;
    ELSIF p_attr_id = OE_Line_Payment_Util.G_CREDIT_CARD_APPROVAL_CODE THEN
        x_line_payment_tbl(1).credit_card_approval_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Payment_Util.G_CREDIT_CARD_APPROVAL_DATE THEN
      --  x_line_payment_tbl(1).credit_card_approval_date := TO_DATE(p_attr_value, l_date_format_mask);
       x_line_payment_tbl(1).credit_card_approval_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Payment_Util.G_CREDIT_CARD_CODE THEN
        x_line_payment_tbl(1).credit_card_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Payment_Util.G_CREDIT_CARD_EXPIRATION_DATE THEN
      --  x_line_payment_tbl(1).credit_card_expiration_date := TO_DATE(p_attr_value, l_date_format_mask);
        x_line_payment_tbl(1).credit_card_expiration_date := fnd_date.string_TO_DATE(p_attr_value, l_date_format_mask); --bug5402396
    ELSIF p_attr_id = OE_Line_Payment_Util.G_CREDIT_CARD_HOLDER_NAME THEN
        x_line_payment_tbl(1).credit_card_holder_name := p_attr_value;
    ELSIF p_attr_id = OE_Line_Payment_Util.G_CREDIT_CARD_NUMBER THEN
        x_line_payment_tbl(1).credit_card_number := p_attr_value;
    ELSIF p_attr_id = OE_Line_Payment_Util.G_PAYMENT_LEVEL_CODE THEN
        x_line_payment_tbl(1).payment_level_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Payment_Util.G_COMMITMENT_APPLIED_AMOUNT THEN
        x_line_Payment_tbl(1).commitment_applied_amount := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Payment_Util.G_COMMITMENT_INTERFACED_AMOUNT THEN
        x_line_Payment_tbl(1).commitment_interfaced_amount := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Payment_Util.G_PAYMENT_NUMBER THEN
        x_line_Payment_tbl(1).payment_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Payment_Util.G_LINE THEN
        x_line_Payment_tbl(1).line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Payment_Util.G_LINE THEN
        x_line_Payment_tbl(1).line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Payment_Util.G_PAYMENT_AMOUNT THEN
        x_line_Payment_tbl(1).payment_amount := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Payment_Util.G_PAYMENT_COLLECTION_EVENT THEN
        x_line_Payment_tbl(1).payment_collection_event := p_attr_value;
    ELSIF p_attr_id = OE_Line_Payment_Util.G_PAYMENT_TRX_ID THEN
        x_line_Payment_tbl(1).payment_trx_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Payment_Util.G_PAYMENT_TYPE_CODE THEN
        x_line_Payment_tbl(1).payment_type_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Payment_Util.G_PAYMENT_SET_ID THEN
        x_line_Payment_tbl(1).payment_set_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Payment_Util.G_PREPAID_AMOUNT THEN
        x_line_Payment_tbl(1).prepaid_amount := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Payment_Util.G_RECEIPT_METHOD_ID THEN
        x_line_Payment_tbl(1).receipt_method_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Line_Payment_Util.G_TANGIBLE_ID THEN
        x_line_Payment_tbl(1).tangible_id := p_attr_value;
    ELSIF p_attr_id = OE_Line_Payment_Util.G_INSTRUMENT_SECURITY_CODE THEN --R12 Cc encryption
        x_line_Payment_tbl(1).instrument_security_code := p_attr_value;
    ELSIF p_attr_id = OE_Line_Payment_Util.G_CC_INSTRUMENT_ID THEN --R12 CC encryption
        x_line_Payment_tbl(1).cc_instrument_id := p_attr_value;
    ELSIF p_attr_id = OE_Line_Payment_Util.G_CC_INSTRUMENT_ASSIGNMENT_ID THEN --R12 CC encryption
        x_line_Payment_tbl(1).cc_instrument_assignment_id := p_attr_value;
    ELSIF p_attr_id = OE_LINE_PAYMENT_UTIL.G_DEFER_PROCESSING_FLAG THEN
        x_line_Payment_tbl(1).defer_payment_processing_flag := p_attr_value;
    ELSIF p_attr_id = OE_Line_Payment_Util.G_ATTRIBUTE1
    OR     p_attr_id = OE_Line_Payment_Util.G_ATTRIBUTE2
    OR     p_attr_id = OE_Line_Payment_Util.G_ATTRIBUTE3
    OR     p_attr_id = OE_Line_Payment_Util.G_ATTRIBUTE4
    OR     p_attr_id = OE_Line_Payment_Util.G_ATTRIBUTE5
    OR     p_attr_id = OE_Line_Payment_Util.G_ATTRIBUTE6
    OR     p_attr_id = OE_Line_Payment_Util.G_ATTRIBUTE7
    OR     p_attr_id = OE_Line_Payment_Util.G_ATTRIBUTE8
    OR     p_attr_id = OE_Line_Payment_Util.G_ATTRIBUTE9
    OR     p_attr_id = OE_Line_Payment_Util.G_ATTRIBUTE10
    OR     p_attr_id = OE_Line_Payment_Util.G_ATTRIBUTE11
    OR     p_attr_id = OE_Line_Payment_Util.G_ATTRIBUTE12
    OR     p_attr_id = OE_Line_Payment_Util.G_ATTRIBUTE13
    OR     p_attr_id = OE_Line_Payment_Util.G_ATTRIBUTE14
    OR     p_attr_id = OE_Line_Payment_Util.G_ATTRIBUTE15
    OR     p_attr_id = OE_Line_Payment_Util.G_CONTEXT
    THEN

        x_line_Payment_tbl(1).attribute1 := p_attribute1;
        x_line_Payment_tbl(1).attribute2 := p_attribute2;
        x_line_Payment_tbl(1).attribute3 := p_attribute3;
        x_line_Payment_tbl(1).attribute4 := p_attribute4;
        x_line_Payment_tbl(1).attribute5 := p_attribute5;
        x_line_Payment_tbl(1).attribute6 := p_attribute6;
        x_line_Payment_tbl(1).attribute7 := p_attribute7;
        x_line_Payment_tbl(1).attribute8 := p_attribute8;
        x_line_Payment_tbl(1).attribute9 := p_attribute9;
        x_line_Payment_tbl(1).attribute10 := p_attribute10;
        x_line_Payment_tbl(1).attribute11 := p_attribute11;
        x_line_Payment_tbl(1).attribute12 := p_attribute12;
        x_line_Payment_tbl(1).attribute13 := p_attribute13;
        x_line_Payment_tbl(1).attribute14 := p_attribute14;
        x_line_Payment_tbl(1).attribute15 := p_attribute15;
        x_line_Payment_tbl(1).context   := p_context;

    ELSE

        --  Unexpected error, unrecognized attribute

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Copy_Attribute_To_Rec'
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
--  R12 CC Encryption


--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
( x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY NUMBER
, x_msg_data OUT NOCOPY VARCHAR2
, p_payment_number               IN  NUMBER
, p_line_id                      IN  NUMBER
, p_header_id                    IN  NUMBER
, x_creation_date OUT NOCOPY DATE
, x_created_by OUT NOCOPY NUMBER
, x_last_update_date OUT NOCOPY DATE
, x_last_updated_by OUT NOCOPY NUMBER
, x_last_update_login OUT NOCOPY NUMBER
,   x_program_id                    OUT NOCOPY NUMBER
,   x_program_application_id        OUT NOCOPY NUMBER
,   x_program_update_date           OUT NOCOPY DATE
,   x_request_id                    OUT NOCOPY NUMBER
, x_lock_control OUT NOCOPY NUMBER
)
IS
l_x_old_Line_Payment_tbl      OE_Order_PUB.Line_PAYMENT_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Line_Payment_tbl        OE_Order_PUB.Line_PAYMENT_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_Payment.VALIDATE_AND_WRITE' , 1 ) ;
    END IF;

    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.clear_dependents     := FALSE;
    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read Line_Payment from cache
    Get_Line_Payment
    (   p_db_record                   => TRUE
    ,   p_payment_number              => p_payment_number
    ,   p_line_id                     => p_line_id
    ,   p_header_id                   => p_header_id
    ,   x_line_Payment_rec          => l_x_old_Line_PAYMENT_tbl(1)
    );


    Get_Line_Payment
    (   p_db_record                   => FALSE
    ,   p_payment_number              => p_payment_number
    ,   p_line_id                     => p_line_id
    ,   p_header_id                   => p_header_id
    ,   x_line_Payment_rec          => l_x_Line_Payment_tbl(1)
    );

    --  Set Operation.

    IF FND_API.To_Boolean(l_x_Line_Payment_tbl(1).db_flag) THEN
        l_x_Line_Payment_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_x_Line_Payment_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate Line_Payment table

    --  Call OE_Order_PVT.Process_order


    OE_Order_PVT.Line_Payments
    (   p_validation_level              => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_control_rec                   => l_control_rec
    ,   p_x_Line_Payment_tbl          => l_x_Line_PAYMENT_tbl
    ,   p_x_old_Line_Payment_tbl      => l_x_old_Line_PAYMENT_tbl
    ,   x_return_status                 => l_return_status
    );

    IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --  Load OUT parameters.

    x_creation_date                := l_x_Line_Payment_tbl(1).creation_date;
    x_created_by                   := l_x_Line_Payment_tbl(1).created_by;
    x_last_update_date             := l_x_Line_Payment_tbl(1).last_update_date;
    x_last_updated_by              := l_x_Line_Payment_tbl(1).last_updated_by;
    x_last_update_login            := l_x_Line_Payment_tbl(1).last_update_login;
    x_lock_control                 := l_x_Line_Payment_tbl(1).lock_control;

    --  Clear Line_Payment record cache

    Clear_Line_Payment;

    --  Keep track of performed operations.

--    l_old_Line_Payment_rec.operation := l_Line_PAYMENT_rec.operation;


    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE_Payment.VALIDATE_AND_WRITE' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_And_Write'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
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
, p_payment_number               IN  NUMBER
, p_line_id                      IN  NUMBER
, p_header_id                    IN  NUMBER
)
IS
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Line_Payment_tbl        OE_Order_PUB.Line_Payment_Tbl_Type;
l_x_Old_Line_Payment_tbl    OE_Order_PUB.Line_Payment_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_Payment.DELETE_ROW' , 1 ) ;
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

    Get_Line_Payment
    (   p_db_record                   => TRUE
    ,   p_payment_number              => p_payment_number
    ,   p_line_id                     => p_line_id
    ,   p_header_id                   => p_header_id
    ,   x_line_Payment_rec            => l_x_Line_Payment_tbl(1)
    );

    --  Set Operation.

    l_x_Line_Payment_tbl(1).operation := OE_GLOBALS.G_OPR_DELETE;

    --  Populate Line_Payment table


    --  Call OE_Order_PVT.Process_order


    OE_Order_PVT.Line_Payments
    (   p_validation_level          => FND_API.G_VALID_LEVEL_NONE
    ,   p_init_msg_list             => FND_API.G_TRUE
    ,   p_control_rec               => l_control_rec
    ,   p_x_Line_Payment_tbl        => l_x_Line_Payment_tbl
    ,   p_x_old_Line_Payment_tbl    => l_x_old_Line_Payment_tbl
    ,   x_return_status             => l_return_status
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear Line_Payment record cache

    Clear_Line_Payment;

    -- Re-set the UI flag to FALSE
    OE_GLOBALS.G_UI_FLAG := FALSE;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE_Payment.DELETE_ROW' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Delete_Row'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
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
l_x_header_rec                OE_Order_PUB.Header_Rec_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_x_Header_Adj_rec            OE_Order_PUB.Header_Adj_Rec_Type;
l_x_Header_Adj_tbl            OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_rec        OE_Order_PUB.Header_Scredit_Rec_Type;
l_x_Header_Scredit_tbl        OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_Header_Payment_rec        OE_Order_PUB.Header_PAYMENT_Rec_Type;
l_x_Header_Payment_tbl        OE_Order_PUB.Header_PAYMENT_Tbl_Type;
l_x_line_rec                  OE_Order_PUB.Line_Rec_Type;
l_x_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_x_Line_Adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_rec          OE_Order_PUB.Line_Scredit_Rec_Type;
l_x_Line_Scredit_tbl          OE_Order_PUB.Line_Scredit_Tbl_Type;
l_x_Line_Payment_rec          OE_Order_PUB.Line_PAYMENT_Rec_Type;
l_x_Line_Payment_tbl          OE_Order_PUB.Line_PAYMENT_Tbl_Type;
l_x_Lot_Serial_rec            OE_Order_PUB.Lot_Serial_Rec_Type;
l_x_Lot_Serial_tbl            OE_Order_PUB.Lot_Serial_Tbl_Type;
l_x_action_request_tbl        OE_Order_PUB.request_tbl_type;
l_x_Header_price_Att_tbl        OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_x_Header_Adj_Att_tbl          OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_x_Header_Adj_Assoc_tbl        OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_x_Line_price_Att_tbl          OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_x_Line_Adj_Att_tbl            OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_x_Line_Adj_Assoc_tbl          OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_PAYMENT.PROCESS_ENTITY' , 1 ) ;
    END IF;

    -- Set the UI flag
    OE_GLOBALS.G_UI_FLAG := TRUE;

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_LINE_Payment;

    l_control_rec.check_security       := FALSE;
    l_control_rec.clear_dependents   := FALSE;
    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Call OE_Order_PVT.Process_order

    OE_Order_PVT.Process_order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_x_header_rec                => l_x_header_rec
    ,   p_x_Header_Adj_tbl            => l_x_Header_Adj_tbl
    ,   p_x_Header_Scredit_tbl        => l_x_Header_Scredit_tbl
    ,   p_x_Header_Payment_tbl        => l_x_Header_Payment_tbl
    ,   p_x_line_tbl                  => l_x_line_tbl
    ,   p_x_Line_Adj_tbl              => l_x_Line_Adj_tbl
    ,   p_x_Line_Scredit_tbl          => l_x_Line_Scredit_tbl
    ,   p_x_Line_Payment_tbl          => l_x_Line_Payment_tbl
    ,   p_x_Lot_Serial_tbl            => l_x_Lot_Serial_tbl
    ,   p_x_action_request_tbl        => l_x_action_request_tbl
    ,   p_x_Header_price_Att_tbl      => l_x_Header_price_Att_tbl
    ,   p_x_Header_Adj_Att_tbl        => l_x_Header_Adj_Att_tbl
    ,   p_x_Header_Adj_Assoc_tbl      => l_x_Header_Adj_Assoc_tbl
    ,   p_x_Line_price_Att_tbl        => l_x_Line_price_Att_tbl
    ,   p_x_Line_Adj_Att_tbl          => l_x_Line_Adj_Att_tbl
    ,   p_x_Line_Adj_Assoc_tbl        => l_x_Line_Adj_Assoc_tbl

    );

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

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE_Payment.PROCESS_ENTITY' , 1 ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

	   OE_GLOBALS.G_UI_FLAG := FALSE;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Entity'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
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
, p_payment_number                IN  NUMBER
, p_line_id                       IN  NUMBER
, p_header_id			  IN  NUMBER
, p_lock_control                  IN  NUMBER
)
IS
l_return_status               VARCHAR2(1);
l_x_Line_Payment_rec          OE_Order_PUB.Line_PAYMENT_Rec_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_PAYMENT.LOCK_ROW' , 1 ) ;
    END IF;

    --  Load Line_Payment record

    l_x_Line_Payment_rec.operation    :=  OE_GLOBALS.G_OPR_LOCK;
    l_x_Line_Payment_rec.payment_number := p_payment_number;
    l_x_Line_Payment_rec.line_id := p_line_id;
    l_x_Line_Payment_rec.header_id := p_header_id;
    l_x_Line_Payment_rec.lock_control :=  p_lock_control;

    --  Call oe_lines_Payments_util.lock_row instead of OE_Order_PVT.Lock_order

    OE_Line_Payment_Util.Lock_Row
    (   x_return_status           => l_return_status
    ,   p_x_line_Payment_rec    => l_x_line_payment_rec );
    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_Line_Payment_rec.db_flag := FND_API.G_TRUE;

        Write_Line_Payment
        (   p_Line_Payment_rec          => l_x_Line_Payment_rec
        ,   p_db_record                 => TRUE
        );

    END IF;

    --  Set return status.

    x_return_status := l_return_status;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE_Payment.LOCK_ROW' , 1 ) ;
    END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Row'
            );
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );



END Lock_Row;

--  Procedures maintaining Line_Payment record cache.

PROCEDURE Write_Line_Payment
(   p_Line_Payment_rec            IN  OE_Order_PUB.Line_PAYMENT_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_PAYMENT.WRITE_LINE_PAYMENT' , 1 ) ;
    END IF;

    g_Line_Payment_rec := p_Line_Payment_rec;

    IF p_db_record THEN

        g_db_Line_Payment_rec := p_Line_Payment_rec;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE_PAYMENT.WRITE_LINE_PAYMENT' , 1 ) ;
    END IF;

END Write_Line_Payment;

PROCEDURE Get_Line_Payment
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_payment_number                IN  NUMBER
,   p_line_id                       IN  NUMBER
,   p_header_id                     IN  NUMBER
,   x_line_Payment_rec            OUT NOCOPY OE_Order_PUB.Line_PAYMENT_Rec_Type
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_PAYMENT.GET_LINE_PAYMENT' , 1 ) ;
    END IF;

    IF  nvl(p_payment_number, -1) <> NVL(g_Line_Payment_rec.payment_number,-1)
    OR p_line_id <> NVL(g_Line_Payment_rec.line_id,-1)
    THEN

        --  Query row from DB
        OE_Line_Payment_Util.Query_Row
        (   p_payment_number             => p_payment_number
        ,   p_line_id                    => p_line_id
        ,   p_header_id                  => p_header_id
        ,   x_line_Payment_rec           => g_Line_Payment_rec
        );

        g_Line_Payment_rec.db_flag   := FND_API.G_TRUE;

        --  Load DB record

        g_db_Line_Payment_rec        := g_Line_PAYMENT_rec;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE_Payment.GET_LINE_PAYMENT' , 1 ) ;
    END IF;

    IF p_db_record THEN

        x_line_Payment_rec:= g_db_Line_PAYMENT_rec;

    ELSE

        x_line_Payment_rec:= g_Line_PAYMENT_rec;

    END IF;

END Get_Line_Payment;

PROCEDURE Clear_Line_Payment
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENTERING OE_OE_FORM_LINE_Payment.CLEAR_LINE_PAYMENT' , 1 ) ;
    END IF;

    g_Line_Payment_rec           := OE_Order_PUB.G_MISS_LINE_PAYMENT_REC;
    g_db_Line_Payment_rec        := OE_Order_PUB.G_MISS_LINE_PAYMENT_REC;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING OE_OE_FORM_LINE_Payment.CLEAR_LINE_PAYMENT' , 1 ) ;
    END IF;

END Clear_Line_Payment;

END OE_OE_Form_Line_Payment;

/
