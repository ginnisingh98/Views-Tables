--------------------------------------------------------
--  DDL for Package Body OE_OE_FORM_PRICE_BREAK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_FORM_PRICE_BREAK" AS
/* $Header: OEXFDPBB.pls 120.1 2005/06/08 04:06:49 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_OE_Form_Price_Break';

--  Global variables holding cached record.

g_Price_Break_rec             OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
g_db_Price_Break_rec          OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
-- g_Price_LLine_rec		     OE_Price_List_PUB.Price_List_Line_Rec_Type;

-- Forward declaration of procedures maintaining entity record cache.
FUNCTION Get_Price_Id
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_price_list_line_id            IN  NUMBER
)
RETURN OE_Price_List_PUB.Price_List_Line_Rec_Type;

PROCEDURE Write_Price_Break
(   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

FUNCTION Get_Price_Break
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_discount_line_id              IN  NUMBER
,   p_method_type_code        IN VARCHAR2
,   p_price_break_high      IN NUMBER
,   p_price_break_low       IN NUMBER
)
RETURN OE_Pricing_Cont_PUB.Price_Break_Rec_Type;

PROCEDURE Clear_Price_Break;

--  Global variable holding performed operations.

g_opr__tbl                    OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_amount                        OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_attribute1                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute10                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute11                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute12                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute13                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute14                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute15                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute2                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute3                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute4                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute5                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute6                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute7                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute8                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute9                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_discount_line_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_method_type_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_percent                       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price                         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_break_high              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_break_low               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_unit_code                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_discount_line                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_method_type                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_unit                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_Price_Break_rec             OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_Price_Break_val_rec         OE_Pricing_Cont_PUB.Price_Break_Val_Rec_Type;
l_Price_Break_tbl             OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Contract_rec              OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_x_Agreement_rec             OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_x_Price_LHeader_rec         OE_Price_List_PUB.Price_List_Rec_Type;
l_x_Discount_Header_rec       OE_Pricing_Cont_PUB.Discount_Header_Rec_Type;
l_x_Price_LLine_rec           OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_Price_LLine_tbl           OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_Discount_Cust_rec         OE_Pricing_Cont_PUB.Discount_Cust_Rec_Type;
l_x_Discount_Cust_tbl         OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_x_Discount_Line_rec         OE_Pricing_Cont_PUB.Discount_Line_Rec_Type;
l_x_Discount_Line_tbl         OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_x_Price_Break_rec           OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_x_Price_Break_tbl           OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
BEGIN

    --  Set control flags.

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Geresh :: in Process Pricing '
            );
        END IF;
    l_control_rec.controlled_operation := TRUE;
    l_control_rec.default_attributes   := TRUE;

    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Load IN parameters if any exist


    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

    l_Price_Break_rec.attribute1                  := 'NULL';
    l_Price_Break_rec.attribute10                 := 'NULL';
    l_Price_Break_rec.attribute11                 := 'NULL';
    l_Price_Break_rec.attribute12                 := 'NULL';
    l_Price_Break_rec.attribute13                 := 'NULL';
    l_Price_Break_rec.attribute14                 := 'NULL';
    l_Price_Break_rec.attribute15                 := 'NULL';
    l_Price_Break_rec.attribute2                  := 'NULL';
    l_Price_Break_rec.attribute3                  := 'NULL';
    l_Price_Break_rec.attribute4                  := 'NULL';
    l_Price_Break_rec.attribute5                  := 'NULL';
    l_Price_Break_rec.attribute6                  := 'NULL';
    l_Price_Break_rec.attribute7                  := 'NULL';
    l_Price_Break_rec.attribute8                  := 'NULL';
    l_Price_Break_rec.attribute9                  := 'NULL';
    l_Price_Break_rec.context                     := 'NULL';

    --  Set Operation to Create

    l_Price_Break_rec.operation := OE_GLOBALS.G_OPR_CREATE;

    --  Populate Price_Break table

    l_Price_Break_tbl(1) := l_Price_Break_rec;

    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Geresh :: Before Process Pricing in Default'
            );
        END IF;

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Price_Break_tbl             => l_Price_Break_tbl
    ,   x_Contract_rec                => l_x_Contract_rec
    ,   x_Agreement_rec               => l_x_Agreement_rec
    ,   x_Price_LHeader_rec           => l_x_Price_LHeader_rec
    ,   x_Discount_Header_rec         => l_x_Discount_Header_rec
    ,   x_Price_LLine_tbl             => l_x_Price_LLine_tbl
    ,   x_Discount_Cust_tbl           => l_x_Discount_Cust_tbl
    ,   x_Discount_Line_tbl           => l_x_Discount_Line_tbl
    ,   x_Price_Break_tbl             => l_x_Price_Break_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl

    l_x_Price_Break_rec := l_x_Price_Break_tbl(1);

    --  Load OUT parameters.

    x_amount                       := l_x_Price_Break_rec.amount;
    x_attribute1                   := l_x_Price_Break_rec.attribute1;
    x_attribute10                  := l_x_Price_Break_rec.attribute10;
    x_attribute11                  := l_x_Price_Break_rec.attribute11;
    x_attribute12                  := l_x_Price_Break_rec.attribute12;
    x_attribute13                  := l_x_Price_Break_rec.attribute13;
    x_attribute14                  := l_x_Price_Break_rec.attribute14;
    x_attribute15                  := l_x_Price_Break_rec.attribute15;
    x_attribute2                   := l_x_Price_Break_rec.attribute2;
    x_attribute3                   := l_x_Price_Break_rec.attribute3;
    x_attribute4                   := l_x_Price_Break_rec.attribute4;
    x_attribute5                   := l_x_Price_Break_rec.attribute5;
    x_attribute6                   := l_x_Price_Break_rec.attribute6;
    x_attribute7                   := l_x_Price_Break_rec.attribute7;
    x_attribute8                   := l_x_Price_Break_rec.attribute8;
    x_attribute9                   := l_x_Price_Break_rec.attribute9;
    x_context                      := l_x_Price_Break_rec.context;
    x_discount_line_id             := l_x_Price_Break_rec.discount_line_id;
    x_end_date_active              := l_x_Price_Break_rec.end_date_active;
    x_method_type_code             := l_x_Price_Break_rec.method_type_code;
    x_percent                      := l_x_Price_Break_rec.percent;
    x_price                        := l_x_Price_Break_rec.price;
    x_price_break_high             := l_x_Price_Break_rec.price_break_high;
    x_price_break_low              := l_x_Price_Break_rec.price_break_low;
    x_start_date_active            := l_x_Price_Break_rec.start_date_active;
    x_unit_code                    := l_x_Price_Break_rec.unit_code;

    --  Load display out parameters if any

    l_Price_Break_val_rec := OE_Price_Break_Util.Get_Values
    (   p_Price_Break_rec             => l_x_Price_Break_rec
    );
    x_discount_line                := l_Price_Break_val_rec.discount_line;
    x_method_type                  := l_Price_Break_val_rec.method_type;
    x_unit                         := l_Price_Break_val_rec.unit;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_Price_Break_rec.db_flag := FND_API.G_FALSE;

    Write_Price_Break
    (   p_Price_Break_rec             => l_x_Price_Break_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
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
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_discount_line_id              IN  NUMBER
,   p_method_type_code              IN  VARCHAR2
,   p_price_break_high              IN  NUMBER
,   p_price_break_low               IN  NUMBER
,   p_attr_id                       IN  NUMBER
,   p_attr_value                    IN  VARCHAR2
,   p_attribute1                    IN  VARCHAR2
,   p_attribute10                   IN  VARCHAR2
,   p_attribute11                   IN  VARCHAR2
,   p_attribute12                   IN  VARCHAR2
,   p_attribute13                   IN  VARCHAR2
,   p_attribute14                   IN  VARCHAR2
,   p_attribute15                   IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
,   p_attribute3                    IN  VARCHAR2
,   p_attribute4                    IN  VARCHAR2
,   p_attribute5                    IN  VARCHAR2
,   p_attribute6                    IN  VARCHAR2
,   p_attribute7                    IN  VARCHAR2
,   p_attribute8                    IN  VARCHAR2
,   p_attribute9                    IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   x_amount                        OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_attribute1                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute10                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute11                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute12                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute13                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute14                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute15                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute2                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute3                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute4                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute5                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute6                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute7                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute8                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_attribute9                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_discount_line_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_method_type_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_percent                       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price                         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_break_high              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_break_low               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_unit_code                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_discount_line                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_method_type                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_unit                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_Price_Break_rec             OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_old_Price_Break_rec         OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_Price_Break_val_rec         OE_Pricing_Cont_PUB.Price_Break_Val_Rec_Type;
l_Price_Break_tbl             OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
l_old_Price_Break_tbl         OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Contract_rec              OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_x_Agreement_rec             OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_x_Price_LHeader_rec         OE_Price_List_PUB.Price_List_Rec_Type;
l_x_Discount_Header_rec       OE_Pricing_Cont_PUB.Discount_Header_Rec_Type;
l_x_Price_LLine_rec           OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_Price_LLine_tbl           OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_Discount_Cust_rec         OE_Pricing_Cont_PUB.Discount_Cust_Rec_Type;
l_x_Discount_Cust_tbl         OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_x_Discount_Line_rec         OE_Pricing_Cont_PUB.Discount_Line_Rec_Type;
l_x_Discount_Line_tbl         OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_x_Price_Break_rec           OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_x_Price_Break_tbl           OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.change_attributes    := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read Price_Break from cache

    l_Price_Break_rec := Get_Price_Break
    (   p_db_record                   => FALSE
    ,   p_discount_line_id            => p_discount_line_id
	   ,   p_method_type_code        => p_method_type_code
	   ,   p_price_break_high      => p_price_break_high
	   ,   p_price_break_low       => p_price_break_low
    );

    l_old_Price_Break_rec          := l_Price_Break_rec;

    IF p_attr_id = OE_Price_Break_Util.G_AMOUNT THEN
        l_Price_Break_rec.amount := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Price_Break_Util.G_DISCOUNT_LINE THEN
        l_Price_Break_rec.discount_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Price_Break_Util.G_END_DATE_ACTIVE THEN
        l_Price_Break_rec.end_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = OE_Price_Break_Util.G_METHOD_TYPE THEN
        l_Price_Break_rec.method_type_code := p_attr_value;
    ELSIF p_attr_id = OE_Price_Break_Util.G_PERCENT THEN
        l_Price_Break_rec.percent := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Price_Break_Util.G_PRICE THEN
        l_Price_Break_rec.price := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Price_Break_Util.G_PRICE_BREAK_HIGH THEN
        l_Price_Break_rec.price_break_high := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Price_Break_Util.G_PRICE_BREAK_LOW THEN
        l_Price_Break_rec.price_break_low := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Price_Break_Util.G_START_DATE_ACTIVE THEN
        l_Price_Break_rec.start_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = OE_Price_Break_Util.G_UNIT THEN
        l_Price_Break_rec.unit_code := p_attr_value;
    ELSIF p_attr_id = OE_Price_Break_Util.G_ATTRIBUTE1
    OR     p_attr_id = OE_Price_Break_Util.G_ATTRIBUTE10
    OR     p_attr_id = OE_Price_Break_Util.G_ATTRIBUTE12
    OR     p_attr_id = OE_Price_Break_Util.G_ATTRIBUTE13
    OR     p_attr_id = OE_Price_Break_Util.G_ATTRIBUTE14
    OR     p_attr_id = OE_Price_Break_Util.G_ATTRIBUTE15
    OR     p_attr_id = OE_Price_Break_Util.G_ATTRIBUTE2
    OR     p_attr_id = OE_Price_Break_Util.G_ATTRIBUTE3
    OR     p_attr_id = OE_Price_Break_Util.G_ATTRIBUTE4
    OR     p_attr_id = OE_Price_Break_Util.G_ATTRIBUTE5
    OR     p_attr_id = OE_Price_Break_Util.G_ATTRIBUTE6
    OR     p_attr_id = OE_Price_Break_Util.G_ATTRIBUTE7
    OR     p_attr_id = OE_Price_Break_Util.G_ATTRIBUTE8
    OR     p_attr_id = OE_Price_Break_Util.G_ATTRIBUTE9
    OR     p_attr_id = OE_Price_Break_Util.G_CONTEXT
    THEN

        l_Price_Break_rec.attribute1   := p_attribute1;
        l_Price_Break_rec.attribute10  := p_attribute10;
        l_Price_Break_rec.attribute12  := p_attribute12;
        l_Price_Break_rec.attribute13  := p_attribute13;
        l_Price_Break_rec.attribute14  := p_attribute14;
        l_Price_Break_rec.attribute15  := p_attribute15;
        l_Price_Break_rec.attribute2   := p_attribute2;
        l_Price_Break_rec.attribute3   := p_attribute3;
        l_Price_Break_rec.attribute4   := p_attribute4;
        l_Price_Break_rec.attribute5   := p_attribute5;
        l_Price_Break_rec.attribute6   := p_attribute6;
        l_Price_Break_rec.attribute7   := p_attribute7;
        l_Price_Break_rec.attribute8   := p_attribute8;
        l_Price_Break_rec.attribute9   := p_attribute9;
        l_Price_Break_rec.context      := p_context;

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

    IF FND_API.To_Boolean(l_Price_Break_rec.db_flag) THEN
        l_Price_Break_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_Price_Break_rec.operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate Price_Break table

    l_Price_Break_tbl(1) := l_Price_Break_rec;
    l_old_Price_Break_tbl(1) := l_old_Price_Break_rec;

    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Price_Break_tbl             => l_Price_Break_tbl
    ,   p_old_Price_Break_tbl         => l_old_Price_Break_tbl
    ,   x_Contract_rec                => l_x_Contract_rec
    ,   x_Agreement_rec               => l_x_Agreement_rec
    ,   x_Price_LHeader_rec           => l_x_Price_LHeader_rec
    ,   x_Discount_Header_rec         => l_x_Discount_Header_rec
    ,   x_Price_LLine_tbl             => l_x_Price_LLine_tbl
    ,   x_Discount_Cust_tbl           => l_x_Discount_Cust_tbl
    ,   x_Discount_Line_tbl           => l_x_Discount_Line_tbl
    ,   x_Price_Break_tbl             => l_x_Price_Break_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl

    l_x_Price_Break_rec := l_x_Price_Break_tbl(1);

    --  Init OUT parameters to missing.

    x_amount                       := FND_API.G_MISS_NUM;
    x_attribute1                   := FND_API.G_MISS_CHAR;
    x_attribute10                  := FND_API.G_MISS_CHAR;
    x_attribute11                  := FND_API.G_MISS_CHAR;
    x_attribute12                  := FND_API.G_MISS_CHAR;
    x_attribute13                  := FND_API.G_MISS_CHAR;
    x_attribute14                  := FND_API.G_MISS_CHAR;
    x_attribute15                  := FND_API.G_MISS_CHAR;
    x_attribute2                   := FND_API.G_MISS_CHAR;
    x_attribute3                   := FND_API.G_MISS_CHAR;
    x_attribute4                   := FND_API.G_MISS_CHAR;
    x_attribute5                   := FND_API.G_MISS_CHAR;
    x_attribute6                   := FND_API.G_MISS_CHAR;
    x_attribute7                   := FND_API.G_MISS_CHAR;
    x_attribute8                   := FND_API.G_MISS_CHAR;
    x_attribute9                   := FND_API.G_MISS_CHAR;
    x_context                      := FND_API.G_MISS_CHAR;
    x_discount_line_id             := FND_API.G_MISS_NUM;
    x_end_date_active              := FND_API.G_MISS_DATE;
    x_method_type_code             := FND_API.G_MISS_CHAR;
    x_percent                      := FND_API.G_MISS_NUM;
    x_price                        := FND_API.G_MISS_NUM;
    x_price_break_high             := FND_API.G_MISS_NUM;
    x_price_break_low              := FND_API.G_MISS_NUM;
    x_start_date_active            := FND_API.G_MISS_DATE;
    x_unit_code                    := FND_API.G_MISS_CHAR;
    x_discount_line                := FND_API.G_MISS_CHAR;
    x_method_type                  := FND_API.G_MISS_CHAR;
    x_unit                         := FND_API.G_MISS_CHAR;

    --  Load display out parameters if any

    l_Price_Break_val_rec := OE_Price_Break_Util.Get_Values
    (   p_Price_Break_rec             => l_x_Price_Break_rec
    ,   p_old_Price_Break_rec         => l_Price_Break_rec
    );

    --  Return changed attributes.

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.amount,
                            l_Price_Break_rec.amount)
    THEN
        x_amount := l_x_Price_Break_rec.amount;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.attribute1,
                            l_Price_Break_rec.attribute1)
    THEN
        x_attribute1 := l_x_Price_Break_rec.attribute1;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.attribute10,
                            l_Price_Break_rec.attribute10)
    THEN
        x_attribute10 := l_x_Price_Break_rec.attribute10;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.attribute11,
                            l_Price_Break_rec.attribute11)
    THEN
        x_attribute11 := l_x_Price_Break_rec.attribute11;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.attribute12,
                            l_Price_Break_rec.attribute12)
    THEN
        x_attribute12 := l_x_Price_Break_rec.attribute12;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.attribute13,
                            l_Price_Break_rec.attribute13)
    THEN
        x_attribute13 := l_x_Price_Break_rec.attribute13;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.attribute14,
                            l_Price_Break_rec.attribute14)
    THEN
        x_attribute14 := l_x_Price_Break_rec.attribute14;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.attribute15,
                            l_Price_Break_rec.attribute15)
    THEN
        x_attribute15 := l_x_Price_Break_rec.attribute15;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.attribute2,
                            l_Price_Break_rec.attribute2)
    THEN
        x_attribute2 := l_x_Price_Break_rec.attribute2;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.attribute3,
                            l_Price_Break_rec.attribute3)
    THEN
        x_attribute3 := l_x_Price_Break_rec.attribute3;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.attribute4,
                            l_Price_Break_rec.attribute4)
    THEN
        x_attribute4 := l_x_Price_Break_rec.attribute4;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.attribute5,
                            l_Price_Break_rec.attribute5)
    THEN
        x_attribute5 := l_x_Price_Break_rec.attribute5;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.attribute6,
                            l_Price_Break_rec.attribute6)
    THEN
        x_attribute6 := l_x_Price_Break_rec.attribute6;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.attribute7,
                            l_Price_Break_rec.attribute7)
    THEN
        x_attribute7 := l_x_Price_Break_rec.attribute7;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.attribute8,
                            l_Price_Break_rec.attribute8)
    THEN
        x_attribute8 := l_x_Price_Break_rec.attribute8;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.attribute9,
                            l_Price_Break_rec.attribute9)
    THEN
        x_attribute9 := l_x_Price_Break_rec.attribute9;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.context,
                            l_Price_Break_rec.context)
    THEN
        x_context := l_x_Price_Break_rec.context;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.discount_line_id,
                            l_Price_Break_rec.discount_line_id)
    THEN
        x_discount_line_id := l_x_Price_Break_rec.discount_line_id;
        x_discount_line := l_Price_Break_val_rec.discount_line;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.end_date_active,
                            l_Price_Break_rec.end_date_active)
    THEN
        x_end_date_active := l_x_Price_Break_rec.end_date_active;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.method_type_code,
                            l_Price_Break_rec.method_type_code)
    THEN
        x_method_type_code := l_x_Price_Break_rec.method_type_code;
        x_method_type := l_Price_Break_val_rec.method_type;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.percent,
                            l_Price_Break_rec.percent)
    THEN
        x_percent := l_x_Price_Break_rec.percent;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.price,
                            l_Price_Break_rec.price)
    THEN
        x_price := l_x_Price_Break_rec.price;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.price_break_high,
                            l_Price_Break_rec.price_break_high)
    THEN
        x_price_break_high := l_x_Price_Break_rec.price_break_high;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.price_break_low,
                            l_Price_Break_rec.price_break_low)
    THEN
        x_price_break_low := l_x_Price_Break_rec.price_break_low;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.start_date_active,
                            l_Price_Break_rec.start_date_active)
    THEN
        x_start_date_active := l_x_Price_Break_rec.start_date_active;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_Break_rec.unit_code,
                            l_Price_Break_rec.unit_code)
    THEN
        x_unit_code := l_x_Price_Break_rec.unit_code;
        x_unit := l_Price_Break_val_rec.unit;
    END IF;


    --  Write to cache.

    Write_Price_Break
    (   p_Price_Break_rec             => l_x_Price_Break_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
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
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_price_list_line_id              IN  NUMBER
,   p_price_list_id				 IN  NUMBER
,   p_method_type_code              IN  VARCHAR2
,   p_price_break_high              IN  NUMBER
,   p_price_break_low               IN  NUMBER
,   p_list_price		   	   IN NUMBER
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_created_by                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_date              OUT NOCOPY /* file.sql.39 change */ DATE
,   x_last_updated_by               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_login             OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_Price_Break_rec             OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_old_Price_Break_rec         OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_Price_Break_tbl             OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
l_old_Price_Break_tbl         OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Contract_rec              OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_x_Agreement_rec             OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_x_Price_LHeader_rec         OE_Price_List_PUB.Price_List_Rec_Type;
l_x_Discount_Header_rec       OE_Pricing_Cont_PUB.Discount_Header_Rec_Type;
l_x_Price_LLine_rec           OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_Price_LLine_tbl           OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_Discount_Cust_rec         OE_Pricing_Cont_PUB.Discount_Cust_Rec_Type;
l_x_Discount_Cust_tbl         OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_x_Discount_Line_rec         OE_Pricing_Cont_PUB.Discount_Line_Rec_Type;
l_x_Discount_Line_tbl         OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_x_Price_Break_rec           OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_x_Price_Break_tbl           OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;

l_Price_LLine_rec           OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_old_Price_LLine_rec           OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_Price_LLine_tbl		   OE_Price_List_PUB.Price_list_Line_Tbl_Type;
l_old_Price_LLine_tbl		   OE_Price_List_PUB.Price_list_Line_Tbl_Type;

I NUMBER := 1;
l_attribute_grouping_no number := 0;
l_pricing_attribute_id number := 0;
l_old_customer_item_id NUMBER ;
l_old_inventory_item_id NUMBER ;

BEGIN


   oe_debug_pub.initialize;
   oe_debug_pub.debug_on;

   oe_debug_pub.add ( 'Geresh  In Procedure Validate and write' );

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;



    l_old_Price_LLine_rec := Get_Price_Id
		(  	p_db_record 	=> TRUE
	 ,	p_price_list_line_id => p_price_list_line_id
		 );

    l_Price_LLine_rec := Get_Price_Id
		(  	p_db_record 	=> FALSE
		 ,	p_price_list_line_id => p_price_list_line_id
		 );



---------------------------------------------------
-- generarting new price list line id for price break lines
--------------------------------------------------
    select qp_list_lines_s.nextval into l_Price_LLine_rec.price_list_line_id
    from dual;
---------------------------------------------
-- Load Price List Line records for price breaks
---------------------------------------------

    l_Price_LLine_rec.operation := OE_GLOBALS.G_OPR_CREATE;
    l_Price_LLine_rec.db_flag := FND_API.G_FALSE;

    select sysdate into l_Price_LLine_rec.creation_date
    from dual;

   oe_debug_pub.add ( 'Geresh 3:: In Procedure Validate and write' );


 l_Price_LLine_rec.price_break_parent_line := p_price_list_line_id;
    l_Price_LLine_rec.price_list_id := p_price_list_id;
    l_Price_LLine_rec.list_line_type_code := 'PLL';
    l_Price_LLine_rec.list_price := p_list_price;

    l_Price_LLine_rec.method_type_code := p_method_type_code;
    l_Price_LLine_rec.price_break_low := p_price_break_low;
    l_Price_LLine_rec.price_break_high := p_price_break_high;


    l_Price_LLine_tbl(1) := l_Price_LLine_rec;
    l_old_Price_LLine_tbl(1) := l_old_Price_LLine_rec;

    l_old_Price_LLine_rec.operation := l_Price_LLine_rec.operation;

-------------------------------------
-- Insert / Update Records
-------------------------------------
oe_debug_pub.add('Price List IDS' || p_price_list_line_id );
oe_debug_pub.add('Price List IDS' || l_Price_LLine_rec.price_list_line_id );

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
	(   		p_api_version_number          => 1.0
		,   	p_init_msg_list               => FND_API.G_TRUE
		,   x_return_status               => l_return_status
		,   x_msg_count                   => x_msg_count
		,   x_msg_data                    => x_msg_data
		,   p_control_rec                 => l_control_rec
		,   p_Price_LLine_tbl             => l_Price_LLine_tbl
		,   p_old_Price_LLine_tbl         => l_old_Price_LLine_tbl
		,   x_Contract_rec                => l_x_Contract_rec
		,   x_Agreement_rec               => l_x_Agreement_rec
		,   x_Price_LHeader_rec           => l_x_Price_LHeader_rec
		,   x_Discount_Header_rec         => l_x_Discount_Header_rec
		,   x_Price_LLine_tbl             => l_x_Price_LLine_tbl
		,   x_Discount_Cust_tbl           => l_x_Discount_Cust_tbl
		, x_Discount_Line_tbl           => l_x_Discount_Line_tbl
		,   x_Price_Break_tbl             => l_x_Price_Break_tbl
	);


   oe_debug_pub.add ( 'Geresh ::Ednd  Proicees Pricing ' || x_return_status );
    --  Load OUT parameters.

    l_x_Price_Break_rec := l_x_Price_Break_tbl(1);

    x_creation_date                := l_x_Price_Break_rec.creation_date;
    x_created_by                   := l_x_Price_Break_rec.created_by;
    x_last_update_date             := l_x_Price_Break_rec.last_update_date;
    x_last_updated_by              := l_x_Price_Break_rec.last_updated_by;
    x_last_update_login            := l_x_Price_Break_rec.last_update_login;



    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
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

	  null;
/*        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_And_Write'
            );
        END IF;   */

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Validate_And_Write;


FUNCTION Get_Price_Id
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_price_list_line_id            IN  NUMBER
)
RETURN OE_Price_List_PUB.Price_List_Line_Rec_Type
IS
l_Price_LLine_rec         OE_Price_List_PUB.Price_List_Line_Rec_Type;
BEGIN


        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_And_Write' || p_price_list_line_id
            );
        END IF;
  IF  p_price_list_line_id is not null
  THEN
		--  Query row from DB
 SELECT  ATTRIBUTE1
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
,       COMMENTS
,       CONTEXT
,       CREATED_BY
,       CREATION_DATE
,       CUSTOMER_ITEM_ID
,       END_DATE_ACTIVE
,       INVENTORY_ITEM_ID
,       LAST_UPDATED_BY
,       LAST_UPDATE_DATE
,       LAST_UPDATE_LOGIN
,       LIST_PRICE
,       METHOD_CODE
,       PRICE_LIST_ID
,       PRICE_LIST_LINE_ID
,       PRICING_ATTRIBUTE1
,       PRICING_ATTRIBUTE10
,       PRICING_ATTRIBUTE11
,       PRICING_ATTRIBUTE12
,       PRICING_ATTRIBUTE13
,       PRICING_ATTRIBUTE14
,       PRICING_ATTRIBUTE15
,       PRICING_ATTRIBUTE2
,       PRICING_ATTRIBUTE3
,       PRICING_ATTRIBUTE4
,       PRICING_ATTRIBUTE5
,       PRICING_ATTRIBUTE6
,       PRICING_ATTRIBUTE7
,       PRICING_ATTRIBUTE8
,       PRICING_ATTRIBUTE9
,       PRICING_CONTEXT
,       PRICING_RULE_ID
,       PRIMARY
,       PROGRAM_APPLICATION_ID
,       PROGRAM_ID
,       PROGRAM_UPDATE_DATE
,       REPRICE_FLAG
,       REQUEST_ID
,       REVISION
,       REVISION_DATE
,       REVISION_REASON_CODE
,       START_DATE_ACTIVE
,       UNIT_CODE
INTO        l_Price_LLine_rec.ATTRIBUTE1
,       l_Price_LLine_rec.ATTRIBUTE10
,       l_Price_LLine_rec.ATTRIBUTE11
,       l_Price_LLine_rec.ATTRIBUTE12
,       l_Price_LLine_rec.ATTRIBUTE13
,       l_Price_LLine_rec.ATTRIBUTE14
,       l_Price_LLine_rec.ATTRIBUTE15
,       l_Price_LLine_rec.ATTRIBUTE2
,       l_Price_LLine_rec.ATTRIBUTE3
,       l_Price_LLine_rec.ATTRIBUTE4
,       l_Price_LLine_rec.ATTRIBUTE5
,       l_Price_LLine_rec.ATTRIBUTE6
,       l_Price_LLine_rec.ATTRIBUTE7
,       l_Price_LLine_rec.ATTRIBUTE8
,       l_Price_LLine_rec.ATTRIBUTE9
,       l_Price_LLine_rec.COMMENTS
,       l_Price_LLine_rec.CONTEXT
,       l_Price_LLine_rec.CREATED_BY
,       l_Price_LLine_rec.CREATION_DATE
,       l_Price_LLine_rec.CUSTOMER_ITEM_ID
,       l_Price_LLine_rec.END_DATE_ACTIVE
,       l_Price_LLine_rec.INVENTORY_ITEM_ID
,       l_Price_LLine_rec.LAST_UPDATED_BY
,       l_Price_LLine_rec.LAST_UPDATE_DATE
,       l_Price_LLine_rec.LAST_UPDATE_LOGIN
,       l_Price_LLine_rec.LIST_PRICE
,       l_Price_LLine_rec.METHOD_CODE
,       l_Price_LLine_rec.PRICE_LIST_ID
,       l_Price_LLine_rec.PRICE_LIST_LINE_ID
,       l_Price_LLine_rec.PRICING_ATTRIBUTE1
,       l_Price_LLine_rec.PRICING_ATTRIBUTE10
,       l_Price_LLine_rec.PRICING_ATTRIBUTE11
,       l_Price_LLine_rec.PRICING_ATTRIBUTE12
,       l_Price_LLine_rec.PRICING_ATTRIBUTE13
,       l_Price_LLine_rec.PRICING_ATTRIBUTE14
,       l_Price_LLine_rec.PRICING_ATTRIBUTE15
,       l_Price_LLine_rec.PRICING_ATTRIBUTE2
,       l_Price_LLine_rec.PRICING_ATTRIBUTE3
,       l_Price_LLine_rec.PRICING_ATTRIBUTE4
,       l_Price_LLine_rec.PRICING_ATTRIBUTE5
,       l_Price_LLine_rec.PRICING_ATTRIBUTE6
,       l_Price_LLine_rec.PRICING_ATTRIBUTE7
,       l_Price_LLine_rec.PRICING_ATTRIBUTE8
,       l_Price_LLine_rec.PRICING_ATTRIBUTE9
,       l_Price_LLine_rec.PRICING_CONTEXT
,       l_Price_LLine_rec.PRICING_RULE_ID
,       l_Price_LLine_rec.PRIMARY
,       l_Price_LLine_rec.PROGRAM_APPLICATION_ID
,       l_Price_LLine_rec.PROGRAM_ID
,       l_Price_LLine_rec.PROGRAM_UPDATE_DATE
,       l_Price_LLine_rec.REPRICE_FLAG
,       l_Price_LLine_rec.REQUEST_ID
,       l_Price_LLine_rec.REVISION
,       l_Price_LLine_rec.REVISION_DATE
,       l_Price_LLine_rec.REVISION_REASON_CODE
,       l_Price_LLine_rec.START_DATE_ACTIVE
,       l_Price_LLine_rec.UNIT_CODE

FROM    	qp_price_list_lines_v WHERE ( PRICE_LIST_LINE_ID = p_price_list_line_id);
-- FROM    OE_PRICE_LIST_LINES WHERE ( PRICE_LIST_LINE_ID = p_price_list_line_id);

 END IF;

--   g_Price_LLine_rec := l_Price_LLine_rec;

	IF p_db_record THEN
	   RETURN l_Price_LLine_rec;
	ELSE
--	   RETURN g_Price_LLine_rec;
	 RETURN l_Price_LLine_rec;

    END IF;
END Get_Price_Id;

--  Procedure       Delete_Row
--
PROCEDURE Delete_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_discount_line_id              IN  NUMBER
,   p_method_type_code              IN  VARCHAR2
,   p_price_break_high              IN  NUMBER
,   p_price_break_low               IN  NUMBER
)
IS
l_Price_Break_rec             OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_Price_Break_tbl             OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Contract_rec              OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_x_Agreement_rec             OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_x_Price_LHeader_rec         OE_Price_List_PUB.Price_List_Rec_Type;
l_x_Discount_Header_rec       OE_Pricing_Cont_PUB.Discount_Header_Rec_Type;
l_x_Price_LLine_rec           OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_Price_LLine_tbl           OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_Discount_Cust_rec         OE_Pricing_Cont_PUB.Discount_Cust_Rec_Type;
l_x_Discount_Cust_tbl         OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_x_Discount_Line_rec         OE_Pricing_Cont_PUB.Discount_Line_Rec_Type;
l_x_Discount_Line_tbl         OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_x_Price_Break_rec           OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_x_Price_Break_tbl           OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read DB record from cache

    l_Price_Break_rec := Get_Price_Break
    (   p_db_record                   => TRUE
    ,   p_discount_line_id            => p_discount_line_id
    ,   p_method_type_code            => p_method_type_code
    ,   p_price_break_high            => p_price_break_high
    ,   p_price_break_low             => p_price_break_low
    );

    --  Set Operation.

    l_Price_Break_rec.operation := OE_GLOBALS.G_OPR_DELETE;

    --  Populate Price_Break table

    l_Price_Break_tbl(1) := l_Price_Break_rec;

    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Price_Break_tbl             => l_Price_Break_tbl
    ,   x_Contract_rec                => l_x_Contract_rec
    ,   x_Agreement_rec               => l_x_Agreement_rec
    ,   x_Price_LHeader_rec           => l_x_Price_LHeader_rec
    ,   x_Discount_Header_rec         => l_x_Discount_Header_rec
    ,   x_Price_LLine_tbl             => l_x_Price_LLine_tbl
    ,   x_Discount_Cust_tbl           => l_x_Discount_Cust_tbl
    ,   x_Discount_Line_tbl           => l_x_Discount_Line_tbl
    ,   x_Price_Break_tbl             => l_x_Price_Break_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear Price_Break record cache

    Clear_Price_Break;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
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
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_Contract_rec              OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_x_Agreement_rec             OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_x_Price_LHeader_rec         OE_Price_List_PUB.Price_List_Rec_Type;
l_x_Discount_Header_rec       OE_Pricing_Cont_PUB.Discount_Header_Rec_Type;
l_x_Price_LLine_rec           OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_Price_LLine_tbl           OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_Discount_Cust_rec         OE_Pricing_Cont_PUB.Discount_Cust_Rec_Type;
l_x_Discount_Cust_tbl         OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_x_Discount_Line_rec         OE_Pricing_Cont_PUB.Discount_Line_Rec_Type;
l_x_Discount_Line_tbl         OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_x_Price_Break_rec           OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_x_Price_Break_tbl           OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_PRICE_BREAK;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   x_Contract_rec                => l_x_Contract_rec
    ,   x_Agreement_rec               => l_x_Agreement_rec
    ,   x_Price_LHeader_rec           => l_x_Price_LHeader_rec
    ,   x_Discount_Header_rec         => l_x_Discount_Header_rec
    ,   x_Price_LLine_tbl             => l_x_Price_LLine_tbl
    ,   x_Discount_Cust_tbl           => l_x_Discount_Cust_tbl
    ,   x_Discount_Line_tbl           => l_x_Discount_Line_tbl
    ,   x_Price_Break_tbl             => l_x_Price_Break_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
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
            ,   'Process_Entity'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Entity;

--  Procedure       lock_Row
--

PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_amount                        IN  NUMBER
,   p_attribute1                    IN  VARCHAR2
,   p_attribute10                   IN  VARCHAR2
,   p_attribute11                   IN  VARCHAR2
,   p_attribute12                   IN  VARCHAR2
,   p_attribute13                   IN  VARCHAR2
,   p_attribute14                   IN  VARCHAR2
,   p_attribute15                   IN  VARCHAR2
,   p_attribute2                    IN  VARCHAR2
,   p_attribute3                    IN  VARCHAR2
,   p_attribute4                    IN  VARCHAR2
,   p_attribute5                    IN  VARCHAR2
,   p_attribute6                    IN  VARCHAR2
,   p_attribute7                    IN  VARCHAR2
,   p_attribute8                    IN  VARCHAR2
,   p_attribute9                    IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_discount_line_id              IN  NUMBER
,   p_end_date_active               IN  DATE
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_method_type_code              IN  VARCHAR2
,   p_percent                       IN  NUMBER
,   p_price                         IN  NUMBER
,   p_price_break_high              IN  NUMBER
,   p_price_break_low               IN  NUMBER
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_request_id                    IN  NUMBER
,   p_start_date_active             IN  DATE
,   p_unit_code                     IN  VARCHAR2
)
IS
l_return_status               VARCHAR2(1);
l_Price_Break_rec             OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_Price_Break_tbl             OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
l_x_Contract_rec              OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_x_Agreement_rec             OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_x_Price_LHeader_rec         OE_Price_List_PUB.Price_List_Rec_Type;
l_x_Discount_Header_rec       OE_Pricing_Cont_PUB.Discount_Header_Rec_Type;
l_x_Price_LLine_rec           OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_Price_LLine_tbl           OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_Discount_Cust_rec         OE_Pricing_Cont_PUB.Discount_Cust_Rec_Type;
l_x_Discount_Cust_tbl         OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_x_Discount_Line_rec         OE_Pricing_Cont_PUB.Discount_Line_Rec_Type;
l_x_Discount_Line_tbl         OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_x_Price_Break_rec           OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_x_Price_Break_tbl           OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
BEGIN

    --  Load Price_Break record

    l_Price_Break_rec.amount       := p_amount;
    l_Price_Break_rec.attribute1   := p_attribute1;
    l_Price_Break_rec.attribute10  := p_attribute10;
    l_Price_Break_rec.attribute11  := p_attribute11;
    l_Price_Break_rec.attribute12  := p_attribute12;
    l_Price_Break_rec.attribute13  := p_attribute13;
    l_Price_Break_rec.attribute14  := p_attribute14;
    l_Price_Break_rec.attribute15  := p_attribute15;
    l_Price_Break_rec.attribute2   := p_attribute2;
    l_Price_Break_rec.attribute3   := p_attribute3;
    l_Price_Break_rec.attribute4   := p_attribute4;
    l_Price_Break_rec.attribute5   := p_attribute5;
    l_Price_Break_rec.attribute6   := p_attribute6;
    l_Price_Break_rec.attribute7   := p_attribute7;
    l_Price_Break_rec.attribute8   := p_attribute8;
    l_Price_Break_rec.attribute9   := p_attribute9;
    l_Price_Break_rec.context      := p_context;
    l_Price_Break_rec.created_by   := p_created_by;
    l_Price_Break_rec.creation_date := p_creation_date;
    l_Price_Break_rec.discount_line_id := p_discount_line_id;
    l_Price_Break_rec.end_date_active := p_end_date_active;
    l_Price_Break_rec.last_updated_by := p_last_updated_by;
    l_Price_Break_rec.last_update_date := p_last_update_date;
    l_Price_Break_rec.last_update_login := p_last_update_login;
    l_Price_Break_rec.method_type_code := p_method_type_code;
    l_Price_Break_rec.percent      := p_percent;
    l_Price_Break_rec.price        := p_price;
    l_Price_Break_rec.price_break_high := p_price_break_high;
    l_Price_Break_rec.price_break_low := p_price_break_low;
    l_Price_Break_rec.program_application_id := p_program_application_id;
    l_Price_Break_rec.program_id   := p_program_id;
    l_Price_Break_rec.program_update_date := p_program_update_date;
    l_Price_Break_rec.request_id   := p_request_id;
    l_Price_Break_rec.start_date_active := p_start_date_active;
    l_Price_Break_rec.unit_code    := p_unit_code;

    --  Populate Price_Break table

    l_Price_Break_tbl(1) := l_Price_Break_rec;

    --  Call OE_Pricing_Cont_PVT.Lock_Pricing_Cont

    OE_Pricing_Cont_PVT.Lock_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_Price_Break_tbl             => l_Price_Break_tbl
    ,   x_Contract_rec                => l_x_Contract_rec
    ,   x_Agreement_rec               => l_x_Agreement_rec
    ,   x_Price_LHeader_rec           => l_x_Price_LHeader_rec
    ,   x_Discount_Header_rec         => l_x_Discount_Header_rec
    ,   x_Price_LLine_tbl             => l_x_Price_LLine_tbl
    ,   x_Discount_Cust_tbl           => l_x_Discount_Cust_tbl
    ,   x_Discount_Line_tbl           => l_x_Discount_Line_tbl
    ,   x_Price_Break_tbl             => l_x_Price_Break_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_Price_Break_rec.db_flag := FND_API.G_TRUE;

        Write_Price_Break
        (   p_Price_Break_rec             => l_x_Price_Break_rec
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

--  Procedures maintaining Price_Break record cache.

PROCEDURE Write_Price_Break
(   p_Price_Break_rec               IN  OE_Pricing_Cont_PUB.Price_Break_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
BEGIN

    g_Price_Break_rec := p_Price_Break_rec;

    IF p_db_record THEN

        g_db_Price_Break_rec := p_Price_Break_rec;

    END IF;

END Write_Price_Break;

FUNCTION Get_Price_Break
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_discount_line_id              IN  NUMBER
,   p_method_type_code              IN  VARCHAR2
,   p_price_break_high              IN  NUMBER
,   p_price_break_low               IN  NUMBER
)
RETURN OE_Pricing_Cont_PUB.Price_Break_Rec_Type
IS
BEGIN

    IF  p_discount_line_id <> g_Price_Break_rec.discount_line_id
    THEN

        --  Query row from DB
        g_Price_Break_rec := OE_Price_Break_Util.Query_Row
        (   p_discount_line_id            => p_discount_line_id
	   ,   p_method_type_code          => p_method_type_code
	   ,   p_price_break_high         => p_price_break_high
	   ,   p_price_break_low           => p_price_break_low
        );

        g_Price_Break_rec.db_flag      := FND_API.G_TRUE;

        --  Load DB record

        g_db_Price_Break_rec           := g_Price_Break_rec;

    END IF;

    IF p_db_record THEN

        RETURN g_db_Price_Break_rec;

    ELSE

        RETURN g_Price_Break_rec;

    END IF;

END Get_Price_Break;

PROCEDURE Clear_Price_Break
IS
BEGIN

    g_Price_Break_rec              := OE_Pricing_Cont_PUB.G_MISS_PRICE_BREAK_REC;
    g_db_Price_Break_rec           := OE_Pricing_Cont_PUB.G_MISS_PRICE_BREAK_REC;

END Clear_Price_Break;

END OE_OE_Form_Price_Break;

/
