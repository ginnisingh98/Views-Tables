--------------------------------------------------------
--  DDL for Package Body OE_OE_FORM_PRICE_LHEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_FORM_PRICE_LHEADER" AS
/* $Header: OEXFPLHB.pls 120.1 2005/06/08 23:49:48 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_OE_Form_Price_Lheader';

--  Global variables holding cached record.

g_Price_LHeader_rec           OE_Price_List_PUB.Price_List_Rec_Type;
g_db_Price_LHeader_rec        OE_Price_List_PUB.Price_List_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_Price_LHeader
(   p_Price_LHeader_rec             IN  OE_Price_List_PUB.Price_List_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

FUNCTION Get_Price_LHeader
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_price_list_id                 IN  NUMBER
)
RETURN OE_Price_List_PUB.Price_List_Rec_Type;

PROCEDURE Clear_Price_LHeader;

--  Global variable holding performed operations.

g_opr__tbl                    OE_Price_List_PUB.Price_List_Tbl_Type;

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
,   x_comments                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_code                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_description                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_freight_terms_code            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_name                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_id                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_rounding_factor               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_secondary_price_list_id       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_ship_method_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_terms_id                      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_currency                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_freight_terms                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_secondary_price_list          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_method                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_terms                         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_Price_LHeader_rec           OE_Price_List_PUB.Price_List_Rec_Type;
l_Price_LHeader_val_rec       OE_Price_List_PUB.Price_List_Val_Rec_Type;
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


    oe_debug_pub.add('entering default attr 1');

    --  Set control flags.

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

    l_Price_LHeader_rec.attribute1                := 'NULL';
    l_Price_LHeader_rec.attribute10               := 'NULL';
    l_Price_LHeader_rec.attribute11               := 'NULL';
    l_Price_LHeader_rec.attribute12               := 'NULL';
    l_Price_LHeader_rec.attribute13               := 'NULL';
    l_Price_LHeader_rec.attribute14               := 'NULL';
    l_Price_LHeader_rec.attribute15               := 'NULL';
    l_Price_LHeader_rec.attribute2                := 'NULL';
    l_Price_LHeader_rec.attribute3                := 'NULL';
    l_Price_LHeader_rec.attribute4                := 'NULL';
    l_Price_LHeader_rec.attribute5                := 'NULL';
    l_Price_LHeader_rec.attribute6                := 'NULL';
    l_Price_LHeader_rec.attribute7                := 'NULL';
    l_Price_LHeader_rec.attribute8                := 'NULL';
    l_Price_LHeader_rec.attribute9                := 'NULL';
    l_Price_LHeader_rec.context                   := 'NULL';

    --  Set Operation to Create

    l_Price_LHeader_rec.operation := OE_GLOBALS.G_OPR_CREATE;

    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Price_LHeader_rec           => l_Price_LHeader_rec
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

    oe_debug_pub.add('after process pricing cont');


    --  Load OUT parameters.

    x_attribute1                   := l_x_Price_LHeader_rec.attribute1;
    x_attribute10                  := l_x_Price_LHeader_rec.attribute10;
    x_attribute11                  := l_x_Price_LHeader_rec.attribute11;
    x_attribute12                  := l_x_Price_LHeader_rec.attribute12;
    x_attribute13                  := l_x_Price_LHeader_rec.attribute13;
    x_attribute14                  := l_x_Price_LHeader_rec.attribute14;
    x_attribute15                  := l_x_Price_LHeader_rec.attribute15;
    x_attribute2                   := l_x_Price_LHeader_rec.attribute2;
    x_attribute3                   := l_x_Price_LHeader_rec.attribute3;
    x_attribute4                   := l_x_Price_LHeader_rec.attribute4;
    x_attribute5                   := l_x_Price_LHeader_rec.attribute5;
    x_attribute6                   := l_x_Price_LHeader_rec.attribute6;
    x_attribute7                   := l_x_Price_LHeader_rec.attribute7;
    x_attribute8                   := l_x_Price_LHeader_rec.attribute8;
    x_attribute9                   := l_x_Price_LHeader_rec.attribute9;
    x_comments                     := l_x_Price_LHeader_rec.comments;
    x_context                      := l_x_Price_LHeader_rec.context;
    x_currency_code                := l_x_Price_LHeader_rec.currency_code;
    x_description                  := l_x_Price_LHeader_rec.description;
    x_end_date_active              := l_x_Price_LHeader_rec.end_date_active;
    x_freight_terms_code           := l_x_Price_LHeader_rec.freight_terms_code;
    x_name                         := l_x_Price_LHeader_rec.name;
    x_price_list_id                := l_x_Price_LHeader_rec.price_list_id;
    x_rounding_factor              := l_x_Price_LHeader_rec.rounding_factor;
    x_secondary_price_list_id      := l_x_Price_LHeader_rec.secondary_price_list_id;
    x_ship_method_code             := l_x_Price_LHeader_rec.ship_method_code;
    x_start_date_active            := l_x_Price_LHeader_rec.start_date_active;
    x_terms_id                     := l_x_Price_LHeader_rec.terms_id;

    --  Load display out parameters if any

    l_Price_LHeader_val_rec := OE_Price_List_Util.Get_Values
    (   p_Price_List_rec           => l_x_Price_LHeader_rec
    );
    x_currency                     := l_Price_LHeader_val_rec.currency;
    x_freight_terms                := l_Price_LHeader_val_rec.freight_terms;
    x_price_list                   := l_Price_LHeader_val_rec.price_list;
    x_secondary_price_list         := l_Price_LHeader_val_rec.secondary_price_list;
    x_ship_method                  := l_Price_LHeader_val_rec.ship_method;
    x_terms                        := l_Price_LHeader_val_rec.terms;

   oe_debug_pub.add('after oe_price_list_util.get_values');

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_Price_LHeader_rec.db_flag := FND_API.G_FALSE;

    Write_Price_LHeader
    (   p_Price_LHeader_rec           => l_x_Price_LHeader_rec
    );

   oe_debug_pub.add('after writing to cache ');


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
,   p_price_list_id                 IN  NUMBER
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
,   x_comments                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_code                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_description                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_freight_terms_code            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_name                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_id                 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_rounding_factor               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_secondary_price_list_id       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_ship_method_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_terms_id                      OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_currency                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_freight_terms                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_secondary_price_list          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_method                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_terms                         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_Price_LHeader_rec           OE_Price_List_PUB.Price_List_Rec_Type;
l_old_Price_LHeader_rec       OE_Price_List_PUB.Price_List_Rec_Type;
l_Price_LHeader_val_rec       OE_Price_List_PUB.Price_List_Val_Rec_Type;
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

    --  Read Price_LHeader from cache

    l_Price_LHeader_rec := Get_Price_LHeader
    (   p_db_record                   => FALSE
    ,   p_price_list_id               => p_price_list_id
    );

    l_old_Price_LHeader_rec        := l_Price_LHeader_rec;

    IF p_attr_id = OE_Price_List_Util.G_COMMENTS THEN
        l_Price_LHeader_rec.comments := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Util.G_CURRENCY THEN
        l_Price_LHeader_rec.currency_code := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Util.G_DESCRIPTION THEN
        l_Price_LHeader_rec.description := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Util.G_END_DATE_ACTIVE THEN
        l_Price_LHeader_rec.end_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = OE_Price_List_Util.G_FREIGHT_TERMS THEN
        l_Price_LHeader_rec.freight_terms_code := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Util.G_NAME THEN
        l_Price_LHeader_rec.name := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Util.G_PRICE_LIST THEN
        l_Price_LHeader_rec.price_list_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Price_List_Util.G_ROUNDING_FACTOR THEN
        l_Price_LHeader_rec.rounding_factor := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Price_List_Util.G_SECONDARY_PRICE_LIST THEN
        l_Price_LHeader_rec.secondary_price_list_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Price_List_Util.G_SHIP_METHOD THEN
        l_Price_LHeader_rec.ship_method_code := p_attr_value;
    ELSIF p_attr_id = OE_Price_List_Util.G_START_DATE_ACTIVE THEN
        l_Price_LHeader_rec.start_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = OE_Price_List_Util.G_TERMS THEN
        l_Price_LHeader_rec.terms_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = OE_Price_List_Util.G_ATTRIBUTE1
    OR     p_attr_id = OE_Price_List_Util.G_ATTRIBUTE10
    OR     p_attr_id = OE_Price_List_Util.G_ATTRIBUTE11
    OR     p_attr_id = OE_Price_List_Util.G_ATTRIBUTE12
    OR     p_attr_id = OE_Price_List_Util.G_ATTRIBUTE13
    OR     p_attr_id = OE_Price_List_Util.G_ATTRIBUTE14
    OR     p_attr_id = OE_Price_List_Util.G_ATTRIBUTE15
    OR     p_attr_id = OE_Price_List_Util.G_ATTRIBUTE2
    OR     p_attr_id = OE_Price_List_Util.G_ATTRIBUTE3
    OR     p_attr_id = OE_Price_List_Util.G_ATTRIBUTE4
    OR     p_attr_id = OE_Price_List_Util.G_ATTRIBUTE5
    OR     p_attr_id = OE_Price_List_Util.G_ATTRIBUTE6
    OR     p_attr_id = OE_Price_List_Util.G_ATTRIBUTE7
    OR     p_attr_id = OE_Price_List_Util.G_ATTRIBUTE8
    OR     p_attr_id = OE_Price_List_Util.G_ATTRIBUTE9
    OR     p_attr_id = OE_Price_List_Util.G_CONTEXT
    THEN

        l_Price_LHeader_rec.attribute1 := p_attribute1;
        l_Price_LHeader_rec.attribute10 := p_attribute10;
        l_Price_LHeader_rec.attribute11 := p_attribute11;
        l_Price_LHeader_rec.attribute12 := p_attribute12;
        l_Price_LHeader_rec.attribute13 := p_attribute13;
        l_Price_LHeader_rec.attribute14 := p_attribute14;
        l_Price_LHeader_rec.attribute15 := p_attribute15;
        l_Price_LHeader_rec.attribute2 := p_attribute2;
        l_Price_LHeader_rec.attribute3 := p_attribute3;
        l_Price_LHeader_rec.attribute4 := p_attribute4;
        l_Price_LHeader_rec.attribute5 := p_attribute5;
        l_Price_LHeader_rec.attribute6 := p_attribute6;
        l_Price_LHeader_rec.attribute7 := p_attribute7;
        l_Price_LHeader_rec.attribute8 := p_attribute8;
        l_Price_LHeader_rec.attribute9 := p_attribute9;
        l_Price_LHeader_rec.context    := p_context;

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

    IF FND_API.To_Boolean(l_Price_LHeader_rec.db_flag) THEN
        l_Price_LHeader_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_Price_LHeader_rec.operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Price_LHeader_rec           => l_Price_LHeader_rec
    ,   p_old_Price_LHeader_rec       => l_old_Price_LHeader_rec
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


    --  Init OUT parameters to missing.

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
    x_comments                     := FND_API.G_MISS_CHAR;
    x_context                      := FND_API.G_MISS_CHAR;
    x_currency_code                := FND_API.G_MISS_CHAR;
    x_description                  := FND_API.G_MISS_CHAR;
    x_end_date_active              := FND_API.G_MISS_DATE;
    x_freight_terms_code           := FND_API.G_MISS_CHAR;
    x_name                         := FND_API.G_MISS_CHAR;
    x_price_list_id                := FND_API.G_MISS_NUM;
    x_rounding_factor              := FND_API.G_MISS_NUM;
    x_secondary_price_list_id      := FND_API.G_MISS_NUM;
    x_ship_method_code             := FND_API.G_MISS_CHAR;
    x_start_date_active            := FND_API.G_MISS_DATE;
    x_terms_id                     := FND_API.G_MISS_NUM;
    x_currency                     := FND_API.G_MISS_CHAR;
    x_freight_terms                := FND_API.G_MISS_CHAR;
    x_price_list                   := FND_API.G_MISS_CHAR;
    x_secondary_price_list         := FND_API.G_MISS_CHAR;
    x_ship_method                  := FND_API.G_MISS_CHAR;
    x_terms                        := FND_API.G_MISS_CHAR;

    --  Load display out parameters if any

    l_Price_LHeader_val_rec := OE_Price_List_Util.Get_Values
    (   p_Price_List_rec           => l_x_Price_LHeader_rec
    ,   p_old_Price_List_rec       => l_Price_LHeader_rec
    );

    --  Return changed attributes.

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.attribute1,
                            l_Price_LHeader_rec.attribute1)
    THEN
        x_attribute1 := l_x_Price_LHeader_rec.attribute1;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.attribute10,
                            l_Price_LHeader_rec.attribute10)
    THEN
        x_attribute10 := l_x_Price_LHeader_rec.attribute10;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.attribute11,
                            l_Price_LHeader_rec.attribute11)
    THEN
        x_attribute11 := l_x_Price_LHeader_rec.attribute11;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.attribute12,
                            l_Price_LHeader_rec.attribute12)
    THEN
        x_attribute12 := l_x_Price_LHeader_rec.attribute12;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.attribute13,
                            l_Price_LHeader_rec.attribute13)
    THEN
        x_attribute13 := l_x_Price_LHeader_rec.attribute13;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.attribute14,
                            l_Price_LHeader_rec.attribute14)
    THEN
        x_attribute14 := l_x_Price_LHeader_rec.attribute14;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.attribute15,
                            l_Price_LHeader_rec.attribute15)
    THEN
        x_attribute15 := l_x_Price_LHeader_rec.attribute15;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.attribute2,
                            l_Price_LHeader_rec.attribute2)
    THEN
        x_attribute2 := l_x_Price_LHeader_rec.attribute2;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.attribute3,
                            l_Price_LHeader_rec.attribute3)
    THEN
        x_attribute3 := l_x_Price_LHeader_rec.attribute3;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.attribute4,
                            l_Price_LHeader_rec.attribute4)
    THEN
        x_attribute4 := l_x_Price_LHeader_rec.attribute4;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.attribute5,
                            l_Price_LHeader_rec.attribute5)
    THEN
        x_attribute5 := l_x_Price_LHeader_rec.attribute5;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.attribute6,
                            l_Price_LHeader_rec.attribute6)
    THEN
        x_attribute6 := l_x_Price_LHeader_rec.attribute6;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.attribute7,
                            l_Price_LHeader_rec.attribute7)
    THEN
        x_attribute7 := l_x_Price_LHeader_rec.attribute7;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.attribute8,
                            l_Price_LHeader_rec.attribute8)
    THEN
        x_attribute8 := l_x_Price_LHeader_rec.attribute8;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.attribute9,
                            l_Price_LHeader_rec.attribute9)
    THEN
        x_attribute9 := l_x_Price_LHeader_rec.attribute9;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.comments,
                            l_Price_LHeader_rec.comments)
    THEN
        x_comments := l_x_Price_LHeader_rec.comments;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.context,
                            l_Price_LHeader_rec.context)
    THEN
        x_context := l_x_Price_LHeader_rec.context;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.currency_code,
                            l_Price_LHeader_rec.currency_code)
    THEN
        x_currency_code := l_x_Price_LHeader_rec.currency_code;
        x_currency := l_Price_LHeader_val_rec.currency;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.description,
                            l_Price_LHeader_rec.description)
    THEN
        x_description := l_x_Price_LHeader_rec.description;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.end_date_active,
                            l_Price_LHeader_rec.end_date_active)
    THEN
        x_end_date_active := l_x_Price_LHeader_rec.end_date_active;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.freight_terms_code,
                            l_Price_LHeader_rec.freight_terms_code)
    THEN
        x_freight_terms_code := l_x_Price_LHeader_rec.freight_terms_code;
        x_freight_terms := l_Price_LHeader_val_rec.freight_terms;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.name,
                            l_Price_LHeader_rec.name)
    THEN
        x_name := l_x_Price_LHeader_rec.name;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.price_list_id,
                            l_Price_LHeader_rec.price_list_id)
    THEN
        x_price_list_id := l_x_Price_LHeader_rec.price_list_id;
        x_price_list := l_Price_LHeader_val_rec.price_list;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.rounding_factor,
                            l_Price_LHeader_rec.rounding_factor)
    THEN
        x_rounding_factor := l_x_Price_LHeader_rec.rounding_factor;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.secondary_price_list_id,
                            l_Price_LHeader_rec.secondary_price_list_id)
    THEN
        x_secondary_price_list_id := l_x_Price_LHeader_rec.secondary_price_list_id;
        x_secondary_price_list := l_Price_LHeader_val_rec.secondary_price_list;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.ship_method_code,
                            l_Price_LHeader_rec.ship_method_code)
    THEN
        x_ship_method_code := l_x_Price_LHeader_rec.ship_method_code;
        x_ship_method := l_Price_LHeader_val_rec.ship_method;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.start_date_active,
                            l_Price_LHeader_rec.start_date_active)
    THEN
        x_start_date_active := l_x_Price_LHeader_rec.start_date_active;
    END IF;

    IF NOT OE_GLOBALS.Equal(l_x_Price_LHeader_rec.terms_id,
                            l_Price_LHeader_rec.terms_id)
    THEN
        x_terms_id := l_x_Price_LHeader_rec.terms_id;
        x_terms := l_Price_LHeader_val_rec.terms;
    END IF;


    --  Write to cache.

    Write_Price_LHeader
    (   p_Price_LHeader_rec           => l_x_Price_LHeader_rec
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
,   p_price_list_id                 IN  NUMBER
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_created_by                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_date              OUT NOCOPY /* file.sql.39 change */ DATE
,   x_last_updated_by               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_login             OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_Price_LHeader_rec           OE_Price_List_PUB.Price_List_Rec_Type;
l_old_Price_LHeader_rec       OE_Price_List_PUB.Price_List_Rec_Type;
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

    --  Read Price_LHeader from cache

    l_old_Price_LHeader_rec := Get_Price_LHeader
    (   p_db_record                   => TRUE
    ,   p_price_list_id               => p_price_list_id
    );

    l_Price_LHeader_rec := Get_Price_LHeader
    (   p_db_record                   => FALSE
    ,   p_price_list_id               => p_price_list_id
    );

    --  Set Operation.

    IF FND_API.To_Boolean(l_Price_LHeader_rec.db_flag) THEN
        l_Price_LHeader_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_Price_LHeader_rec.operation := OE_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Price_LHeader_rec           => l_Price_LHeader_rec
    ,   p_old_Price_LHeader_rec       => l_old_Price_LHeader_rec
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


    --  Load OUT parameters.


    x_creation_date                := l_x_Price_LHeader_rec.creation_date;
    x_created_by                   := l_x_Price_LHeader_rec.created_by;
    x_last_update_date             := l_x_Price_LHeader_rec.last_update_date;
    x_last_updated_by              := l_x_Price_LHeader_rec.last_updated_by;
    x_last_update_login            := l_x_Price_LHeader_rec.last_update_login;

    --  Clear Price_LHeader record cache

    Clear_Price_LHeader;

    --  Keep track of performed operations.

    l_old_Price_LHeader_rec.operation := l_Price_LHeader_rec.operation;


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
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_price_list_id                 IN  NUMBER
)
IS
l_Price_LHeader_rec           OE_Price_List_PUB.Price_List_Rec_Type;
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

    l_Price_LHeader_rec := Get_Price_LHeader
    (   p_db_record                   => TRUE
    ,   p_price_list_id               => p_price_list_id
    );

    --  Set Operation.

    l_Price_LHeader_rec.operation := OE_GLOBALS.G_OPR_DELETE;

    --  Call OE_Pricing_Cont_PVT.Process_Pricing_Cont

    OE_Pricing_Cont_PVT.Process_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Price_LHeader_rec           => l_Price_LHeader_rec
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


    --  Clear Price_LHeader record cache

    Clear_Price_LHeader;

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
    l_control_rec.process_entity       := OE_GLOBALS.G_ENTITY_PRICE_LHEADER;

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
,   p_comments                      IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_currency_code                 IN  VARCHAR2
,   p_description                   IN  VARCHAR2
,   p_end_date_active               IN  DATE
,   p_freight_terms_code            IN  VARCHAR2
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_name                          IN  VARCHAR2
,   p_price_list_id                 IN  NUMBER
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_request_id                    IN  NUMBER
,   p_rounding_factor               IN  NUMBER
,   p_secondary_price_list_id       IN  NUMBER
,   p_ship_method_code              IN  VARCHAR2
,   p_start_date_active             IN  DATE
,   p_terms_id                      IN  NUMBER
,   p_currency_header_id            IN  NUMBER -- Multi-Currency SunilPandey
)
IS
l_return_status               VARCHAR2(1);
l_Price_LHeader_rec           OE_Price_List_PUB.Price_List_Rec_Type;
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

    --  Load Price_LHeader record

    l_Price_LHeader_rec.attribute1 := p_attribute1;
    l_Price_LHeader_rec.attribute10 := p_attribute10;
    l_Price_LHeader_rec.attribute11 := p_attribute11;
    l_Price_LHeader_rec.attribute12 := p_attribute12;
    l_Price_LHeader_rec.attribute13 := p_attribute13;
    l_Price_LHeader_rec.attribute14 := p_attribute14;
    l_Price_LHeader_rec.attribute15 := p_attribute15;
    l_Price_LHeader_rec.attribute2 := p_attribute2;
    l_Price_LHeader_rec.attribute3 := p_attribute3;
    l_Price_LHeader_rec.attribute4 := p_attribute4;
    l_Price_LHeader_rec.attribute5 := p_attribute5;
    l_Price_LHeader_rec.attribute6 := p_attribute6;
    l_Price_LHeader_rec.attribute7 := p_attribute7;
    l_Price_LHeader_rec.attribute8 := p_attribute8;
    l_Price_LHeader_rec.attribute9 := p_attribute9;
    l_Price_LHeader_rec.comments   := p_comments;
    l_Price_LHeader_rec.context    := p_context;
    l_Price_LHeader_rec.created_by := p_created_by;
    l_Price_LHeader_rec.creation_date := p_creation_date;
    l_Price_LHeader_rec.currency_code := p_currency_code;
    l_Price_LHeader_rec.description := p_description;
    l_Price_LHeader_rec.end_date_active := p_end_date_active;
    l_Price_LHeader_rec.freight_terms_code := p_freight_terms_code;
    l_Price_LHeader_rec.last_updated_by := p_last_updated_by;
    l_Price_LHeader_rec.last_update_date := p_last_update_date;
    l_Price_LHeader_rec.last_update_login := p_last_update_login;
    l_Price_LHeader_rec.name       := p_name;
    l_Price_LHeader_rec.price_list_id := p_price_list_id;
    l_Price_LHeader_rec.program_application_id := p_program_application_id;
    l_Price_LHeader_rec.program_id := p_program_id;
    l_Price_LHeader_rec.program_update_date := p_program_update_date;
    l_Price_LHeader_rec.request_id := p_request_id;
    l_Price_LHeader_rec.rounding_factor := p_rounding_factor;
    l_Price_LHeader_rec.secondary_price_list_id := p_secondary_price_list_id;
    l_Price_LHeader_rec.ship_method_code := p_ship_method_code;
    l_Price_LHeader_rec.start_date_active := p_start_date_active;
    l_Price_LHeader_rec.terms_id   := p_terms_id;
    l_Price_LHeader_rec.currency_header_id  := p_currency_header_id; -- Multi-Currency SunilPandey

    --  Call OE_Pricing_Cont_PVT.Lock_Pricing_Cont

    OE_Pricing_Cont_PVT.Lock_Pricing_Cont
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_Price_LHeader_rec           => l_Price_LHeader_rec
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

        l_x_Price_LHeader_rec.db_flag := FND_API.G_TRUE;

        Write_Price_LHeader
        (   p_Price_LHeader_rec           => l_x_Price_LHeader_rec
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

--  Procedures maintaining Price_LHeader record cache.

PROCEDURE Write_Price_LHeader
(   p_Price_LHeader_rec             IN  OE_Price_List_PUB.Price_List_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
BEGIN

    g_Price_LHeader_rec := p_Price_LHeader_rec;

    IF p_db_record THEN

        g_db_Price_LHeader_rec := p_Price_LHeader_rec;

    END IF;

END Write_Price_Lheader;

FUNCTION Get_Price_LHeader
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_price_list_id                 IN  NUMBER
)
RETURN OE_Price_List_PUB.Price_List_Rec_Type
IS
BEGIN

    IF  p_price_list_id <> g_Price_LHeader_rec.price_list_id
    THEN

        --  Query row from DB

        g_Price_LHeader_rec := OE_Price_List_Util.Query_Row
        (   p_name               => g_Price_LHeader_rec.name ,
           p_price_list_id               => p_price_list_id
        );

        g_Price_LHeader_rec.db_flag    := FND_API.G_TRUE;

        --  Load DB record

        g_db_Price_LHeader_rec         := g_Price_LHeader_rec;

    END IF;

    IF p_db_record THEN

        RETURN g_db_Price_LHeader_rec;

    ELSE

        RETURN g_Price_LHeader_rec;

    END IF;

END Get_Price_Lheader;

PROCEDURE Clear_Price_Lheader
IS
BEGIN

    g_Price_LHeader_rec            := OE_Price_List_PUB.G_MISS_PRICE_List_REC;
    g_db_Price_LHeader_rec         := OE_Price_List_PUB.G_MISS_PRICE_List_REC;

END Clear_Price_Lheader;

END OE_OE_Form_Price_Lheader;

/
