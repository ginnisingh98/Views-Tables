--------------------------------------------------------
--  DDL for Package Body QP_QP_FORM_CURR_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_QP_FORM_CURR_DETAILS" AS
/* $Header: QPXFCDTB.pls 120.1 2005/06/12 23:57:58 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_QP_Form_Curr_Details';

--  Global variables holding cached record.

g_CURR_DETAILS_rec            QP_Currency_PUB.Curr_Details_Rec_Type;
g_db_CURR_DETAILS_rec         QP_Currency_PUB.Curr_Details_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_CURR_DETAILS
(   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

FUNCTION Get_CURR_DETAILS
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_currency_detail_id            IN  NUMBER
)
RETURN QP_Currency_PUB.Curr_Details_Rec_Type;

PROCEDURE Clear_CURR_DETAILS;

--  Global variable holding performed operations.

g_opr__tbl                    QP_Currency_PUB.Curr_Details_Tbl_Type;

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_currency_header_id            IN  NUMBER -- Added by Sunil
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
,   x_conversion_date               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_conversion_date_type          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_conversion_method             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_conversion_type               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_detail_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_currency_header_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_fixed_value                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_markup_formula_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_markup_operator               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_markup_value                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_formula_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_rounding_factor               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_selling_rounding_factor       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_to_currency_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_detail               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_header               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_markup_formula                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_formula                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_to_currency                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_curr_attribute_type           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_curr_attribute_context        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_curr_attribute                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_curr_attribute_value          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_precedence                    OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_CURR_DETAILS_rec            QP_Currency_PUB.Curr_Details_Rec_Type;
l_CURR_DETAILS_val_rec        QP_Currency_PUB.Curr_Details_Val_Rec_Type;
l_CURR_DETAILS_tbl            QP_Currency_PUB.Curr_Details_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_CURR_LISTS_rec            QP_Currency_PUB.Curr_Lists_Rec_Type;
l_x_CURR_DETAILS_rec          QP_Currency_PUB.Curr_Details_Rec_Type;
l_x_CURR_DETAILS_tbl          QP_Currency_PUB.Curr_Details_Tbl_Type;
BEGIN

    -- oe_debug_pub.add('Inside CDT-F Default_Attributes');
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
    l_CURR_DETAILS_rec.currency_header_id  := p_currency_header_id; -- Added by Sunil


    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

    l_CURR_DETAILS_rec.attribute1                 := NULL;
    l_CURR_DETAILS_rec.attribute10                := NULL;
    l_CURR_DETAILS_rec.attribute11                := NULL;
    l_CURR_DETAILS_rec.attribute12                := NULL;
    l_CURR_DETAILS_rec.attribute13                := NULL;
    l_CURR_DETAILS_rec.attribute14                := NULL;
    l_CURR_DETAILS_rec.attribute15                := NULL;
    l_CURR_DETAILS_rec.attribute2                 := NULL;
    l_CURR_DETAILS_rec.attribute3                 := NULL;
    l_CURR_DETAILS_rec.attribute4                 := NULL;
    l_CURR_DETAILS_rec.attribute5                 := NULL;
    l_CURR_DETAILS_rec.attribute6                 := NULL;
    l_CURR_DETAILS_rec.attribute7                 := NULL;
    l_CURR_DETAILS_rec.attribute8                 := NULL;
    l_CURR_DETAILS_rec.attribute9                 := NULL;
    l_CURR_DETAILS_rec.context                    := NULL;

    --  Set Operation to Create

    l_CURR_DETAILS_rec.operation := QP_GLOBALS.G_OPR_CREATE;

    --  Populate CURR_DETAILS table

    l_CURR_DETAILS_tbl(1) := l_CURR_DETAILS_rec;

    --  Call QP_Currency_PVT.Process_Currency

-- oe_debug_pub.add('BEF CDT F package; l_x_CURR_LISTS_rec.currency_header_id : '||l_x_CURR_LISTS_rec.currency_header_id);
-- oe_debug_pub.add('l_CURR_LISTS_rec.currency_header_id : '||l_CURR_DETAILS_rec.currency_header_id);
    QP_Currency_PVT.Process_Currency
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_CURR_DETAILS_tbl            => l_CURR_DETAILS_tbl
    ,   x_CURR_LISTS_rec              => l_x_CURR_LISTS_rec
    ,   x_CURR_DETAILS_tbl            => l_x_CURR_DETAILS_tbl
    );
-- oe_debug_pub.add('AFT CDT F package; currency_header_id: '||l_x_CURR_DETAILS_tbl(1).currency_header_id);


    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl

    l_x_CURR_DETAILS_rec := l_x_CURR_DETAILS_tbl(1);

    --  Load OUT parameters.

    x_attribute1                   := l_x_CURR_DETAILS_rec.attribute1;
    x_attribute10                  := l_x_CURR_DETAILS_rec.attribute10;
    x_attribute11                  := l_x_CURR_DETAILS_rec.attribute11;
    x_attribute12                  := l_x_CURR_DETAILS_rec.attribute12;
    x_attribute13                  := l_x_CURR_DETAILS_rec.attribute13;
    x_attribute14                  := l_x_CURR_DETAILS_rec.attribute14;
    x_attribute15                  := l_x_CURR_DETAILS_rec.attribute15;
    x_attribute2                   := l_x_CURR_DETAILS_rec.attribute2;
    x_attribute3                   := l_x_CURR_DETAILS_rec.attribute3;
    x_attribute4                   := l_x_CURR_DETAILS_rec.attribute4;
    x_attribute5                   := l_x_CURR_DETAILS_rec.attribute5;
    x_attribute6                   := l_x_CURR_DETAILS_rec.attribute6;
    x_attribute7                   := l_x_CURR_DETAILS_rec.attribute7;
    x_attribute8                   := l_x_CURR_DETAILS_rec.attribute8;
    x_attribute9                   := l_x_CURR_DETAILS_rec.attribute9;
    x_context                      := l_x_CURR_DETAILS_rec.context;
    x_conversion_date              := l_x_CURR_DETAILS_rec.conversion_date;
    x_conversion_date_type         := l_x_CURR_DETAILS_rec.conversion_date_type;
    --x_conversion_method            := l_x_CURR_DETAILS_rec.conversion_method;
    x_conversion_type              := l_x_CURR_DETAILS_rec.conversion_type;
    x_currency_detail_id           := l_x_CURR_DETAILS_rec.currency_detail_id;
    x_currency_header_id           := l_x_CURR_DETAILS_rec.currency_header_id;
    x_end_date_active              := l_x_CURR_DETAILS_rec.end_date_active;
    x_fixed_value                  := l_x_CURR_DETAILS_rec.fixed_value;
    x_markup_formula_id            := l_x_CURR_DETAILS_rec.markup_formula_id;
    x_markup_operator              := l_x_CURR_DETAILS_rec.markup_operator;
    x_markup_value                 := l_x_CURR_DETAILS_rec.markup_value;
    x_price_formula_id             := l_x_CURR_DETAILS_rec.price_formula_id;
    x_rounding_factor              := l_x_CURR_DETAILS_rec.rounding_factor;
    x_selling_rounding_factor      := l_x_CURR_DETAILS_rec.selling_rounding_factor;
    x_start_date_active            := l_x_CURR_DETAILS_rec.start_date_active;
    x_to_currency_code             := l_x_CURR_DETAILS_rec.to_currency_code;
    x_curr_attribute_type          := l_x_CURR_DETAILS_rec.curr_attribute_type;
    x_curr_attribute_context       := l_x_CURR_DETAILS_rec.curr_attribute_context;
    x_curr_attribute               := l_x_CURR_DETAILS_rec.curr_attribute;
    x_curr_attribute_value         := l_x_CURR_DETAILS_rec.curr_attribute_value;
    x_precedence                   := l_x_CURR_DETAILS_rec.precedence;

    --  Load display out parameters if any

    l_CURR_DETAILS_val_rec := QP_Curr_Details_Util.Get_Values
    (   p_CURR_DETAILS_rec            => l_x_CURR_DETAILS_rec
    );
    x_currency_detail              := l_CURR_DETAILS_val_rec.currency_detail;
    x_currency_header              := l_CURR_DETAILS_val_rec.currency_header;
    x_markup_formula               := l_CURR_DETAILS_val_rec.markup_formula;
    x_price_formula                := l_CURR_DETAILS_val_rec.price_formula;
    x_to_currency                  := l_CURR_DETAILS_val_rec.to_currency;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_CURR_DETAILS_rec.db_flag := FND_API.G_FALSE;

    Write_CURR_DETAILS
    (   p_CURR_DETAILS_rec            => l_x_CURR_DETAILS_rec
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
,   p_currency_detail_id            IN  NUMBER
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
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_conversion_date               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_conversion_date_type          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
--,   x_conversion_method             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_conversion_type               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_detail_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_currency_header_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_fixed_value                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_markup_formula_id             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_markup_operator               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_markup_value                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_formula_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_rounding_factor               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_selling_rounding_factor       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_to_currency_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_detail               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_header               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_markup_formula                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_formula                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_to_currency                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_curr_attribute_type           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_curr_attribute_context        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_curr_attribute                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_curr_attribute_value          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_precedence                    OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_CURR_DETAILS_rec            QP_Currency_PUB.Curr_Details_Rec_Type;
l_old_CURR_DETAILS_rec        QP_Currency_PUB.Curr_Details_Rec_Type;
l_CURR_DETAILS_val_rec        QP_Currency_PUB.Curr_Details_Val_Rec_Type;
l_CURR_DETAILS_tbl            QP_Currency_PUB.Curr_Details_Tbl_Type;
l_old_CURR_DETAILS_tbl        QP_Currency_PUB.Curr_Details_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_CURR_LISTS_rec            QP_Currency_PUB.Curr_Lists_Rec_Type;
l_x_CURR_DETAILS_rec          QP_Currency_PUB.Curr_Details_Rec_Type;
l_x_CURR_DETAILS_tbl          QP_Currency_PUB.Curr_Details_Tbl_Type;
BEGIN

    -- oe_debug_pub.add('Inside CDT-F Change_Attribute');
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

    --  Read CURR_DETAILS from cache

    l_CURR_DETAILS_rec := Get_CURR_DETAILS
    (   p_db_record                   => FALSE
    ,   p_currency_detail_id          => p_currency_detail_id
    );

    l_old_CURR_DETAILS_rec         := l_CURR_DETAILS_rec;

    IF p_attr_id = QP_Curr_Details_Util.G_CONVERSION_DATE THEN
        l_CURR_DETAILS_rec.conversion_date := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Curr_Details_Util.G_CONVERSION_DATE_TYPE THEN
        l_CURR_DETAILS_rec.conversion_date_type := p_attr_value;
    --ELSIF p_attr_id = QP_Curr_Details_Util.G_CONVERSION_METHOD THEN
        --l_CURR_DETAILS_rec.conversion_method := p_attr_value;
    ELSIF p_attr_id = QP_Curr_Details_Util.G_CONVERSION_TYPE THEN
        l_CURR_DETAILS_rec.conversion_type := p_attr_value;
    ELSIF p_attr_id = QP_Curr_Details_Util.G_CURRENCY_DETAIL THEN
        l_CURR_DETAILS_rec.currency_detail_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Curr_Details_Util.G_CURRENCY_HEADER THEN
        l_CURR_DETAILS_rec.currency_header_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Curr_Details_Util.G_END_DATE_ACTIVE THEN
        l_CURR_DETAILS_rec.end_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Curr_Details_Util.G_FIXED_VALUE THEN
        l_CURR_DETAILS_rec.fixed_value := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Curr_Details_Util.G_MARKUP_FORMULA THEN
        l_CURR_DETAILS_rec.markup_formula_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Curr_Details_Util.G_MARKUP_OPERATOR THEN
        l_CURR_DETAILS_rec.markup_operator := p_attr_value;
    ELSIF p_attr_id = QP_Curr_Details_Util.G_MARKUP_VALUE THEN
        l_CURR_DETAILS_rec.markup_value := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Curr_Details_Util.G_PRICE_FORMULA THEN
        l_CURR_DETAILS_rec.price_formula_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Curr_Details_Util.G_ROUNDING_FACTOR THEN
        l_CURR_DETAILS_rec.rounding_factor := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Curr_Details_Util.G_SELLING_ROUNDING_FACTOR THEN
        l_CURR_DETAILS_rec.selling_rounding_factor := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Curr_Details_Util.G_START_DATE_ACTIVE THEN
        l_CURR_DETAILS_rec.start_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Curr_Details_Util.G_TO_CURRENCY THEN
        l_CURR_DETAILS_rec.to_currency_code := p_attr_value;
    ELSIF p_attr_id = QP_Curr_Details_Util.G_CURR_ATTRIBUTE_TYPE THEN
        l_CURR_DETAILS_rec.curr_attribute_type := p_attr_value;
    ELSIF p_attr_id = QP_Curr_Details_Util.G_CURR_ATTRIBUTE_CONTEXT THEN
        l_CURR_DETAILS_rec.curr_attribute_context := p_attr_value;
    ELSIF p_attr_id = QP_Curr_Details_Util.G_CURR_ATTRIBUTE THEN
        l_CURR_DETAILS_rec.curr_attribute := p_attr_value;
    ELSIF p_attr_id = QP_Curr_Details_Util.G_CURR_ATTRIBUTE_VALUE THEN
        l_CURR_DETAILS_rec.curr_attribute_value := p_attr_value;
    ELSIF p_attr_id = QP_Curr_Details_Util.G_PRECEDENCE THEN
        l_CURR_DETAILS_rec.precedence := p_attr_value;
    ELSIF p_attr_id = QP_Curr_Details_Util.G_ATTRIBUTE1
    OR     p_attr_id = QP_Curr_Details_Util.G_ATTRIBUTE10
    OR     p_attr_id = QP_Curr_Details_Util.G_ATTRIBUTE11
    OR     p_attr_id = QP_Curr_Details_Util.G_ATTRIBUTE12
    OR     p_attr_id = QP_Curr_Details_Util.G_ATTRIBUTE13
    OR     p_attr_id = QP_Curr_Details_Util.G_ATTRIBUTE14
    OR     p_attr_id = QP_Curr_Details_Util.G_ATTRIBUTE15
    OR     p_attr_id = QP_Curr_Details_Util.G_ATTRIBUTE2
    OR     p_attr_id = QP_Curr_Details_Util.G_ATTRIBUTE3
    OR     p_attr_id = QP_Curr_Details_Util.G_ATTRIBUTE4
    OR     p_attr_id = QP_Curr_Details_Util.G_ATTRIBUTE5
    OR     p_attr_id = QP_Curr_Details_Util.G_ATTRIBUTE6
    OR     p_attr_id = QP_Curr_Details_Util.G_ATTRIBUTE7
    OR     p_attr_id = QP_Curr_Details_Util.G_ATTRIBUTE8
    OR     p_attr_id = QP_Curr_Details_Util.G_ATTRIBUTE9
    OR     p_attr_id = QP_Curr_Details_Util.G_CONTEXT
    THEN

        l_CURR_DETAILS_rec.attribute1  := p_attribute1;
        l_CURR_DETAILS_rec.attribute10 := p_attribute10;
        l_CURR_DETAILS_rec.attribute11 := p_attribute11;
        l_CURR_DETAILS_rec.attribute12 := p_attribute12;
        l_CURR_DETAILS_rec.attribute13 := p_attribute13;
        l_CURR_DETAILS_rec.attribute14 := p_attribute14;
        l_CURR_DETAILS_rec.attribute15 := p_attribute15;
        l_CURR_DETAILS_rec.attribute2  := p_attribute2;
        l_CURR_DETAILS_rec.attribute3  := p_attribute3;
        l_CURR_DETAILS_rec.attribute4  := p_attribute4;
        l_CURR_DETAILS_rec.attribute5  := p_attribute5;
        l_CURR_DETAILS_rec.attribute6  := p_attribute6;
        l_CURR_DETAILS_rec.attribute7  := p_attribute7;
        l_CURR_DETAILS_rec.attribute8  := p_attribute8;
        l_CURR_DETAILS_rec.attribute9  := p_attribute9;
        l_CURR_DETAILS_rec.context     := p_context;

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

    IF FND_API.To_Boolean(l_CURR_DETAILS_rec.db_flag) THEN
        l_CURR_DETAILS_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_CURR_DETAILS_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate CURR_DETAILS table

    l_CURR_DETAILS_tbl(1) := l_CURR_DETAILS_rec;
    l_old_CURR_DETAILS_tbl(1) := l_old_CURR_DETAILS_rec;

    --  Call QP_Currency_PVT.Process_Currency

    QP_Currency_PVT.Process_Currency
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_CURR_DETAILS_tbl            => l_CURR_DETAILS_tbl
    ,   p_old_CURR_DETAILS_tbl        => l_old_CURR_DETAILS_tbl
    ,   x_CURR_LISTS_rec              => l_x_CURR_LISTS_rec
    ,   x_CURR_DETAILS_tbl            => l_x_CURR_DETAILS_tbl
    );

    -- oe_debug_pub.add(' Insdie F package inside Change_Attributes; G_MSG_COUNT: '||OE_MSG_PUB.G_MSG_COUNT);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl

    l_x_CURR_DETAILS_rec := l_x_CURR_DETAILS_tbl(1);

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
    x_context                      := FND_API.G_MISS_CHAR;
    x_conversion_date              := FND_API.G_MISS_DATE;
    x_conversion_date_type         := FND_API.G_MISS_CHAR;
    --x_conversion_method            := FND_API.G_MISS_CHAR;
    x_conversion_type              := FND_API.G_MISS_CHAR;
    x_currency_detail_id           := FND_API.G_MISS_NUM;
    x_currency_header_id           := FND_API.G_MISS_NUM;
    x_end_date_active              := FND_API.G_MISS_DATE;
    x_fixed_value                  := FND_API.G_MISS_NUM;
    x_markup_formula_id            := FND_API.G_MISS_NUM;
    x_markup_operator              := FND_API.G_MISS_CHAR;
    x_markup_value                 := FND_API.G_MISS_NUM;
    x_price_formula_id             := FND_API.G_MISS_NUM;
    x_rounding_factor              := FND_API.G_MISS_NUM;
    x_selling_rounding_factor      := FND_API.G_MISS_NUM;
    x_start_date_active            := FND_API.G_MISS_DATE;
    x_to_currency_code             := FND_API.G_MISS_CHAR;
    x_currency_detail              := FND_API.G_MISS_CHAR;
    x_currency_header              := FND_API.G_MISS_CHAR;
    x_markup_formula               := FND_API.G_MISS_CHAR;
    x_price_formula                := FND_API.G_MISS_CHAR;
    x_to_currency                  := FND_API.G_MISS_CHAR;
    x_curr_attribute_type          := FND_API.G_MISS_CHAR;
    x_curr_attribute_context       := FND_API.G_MISS_CHAR;
    x_curr_attribute               := FND_API.G_MISS_CHAR;
    x_curr_attribute_value         := FND_API.G_MISS_CHAR;
    x_precedence                   := FND_API.G_MISS_NUM;

    --  Load display out parameters if any

    l_CURR_DETAILS_val_rec := QP_Curr_Details_Util.Get_Values
    (   p_CURR_DETAILS_rec            => l_x_CURR_DETAILS_rec
    ,   p_old_CURR_DETAILS_rec        => l_CURR_DETAILS_rec
    );

    --  Return changed attributes.

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.attribute1,
                            l_CURR_DETAILS_rec.attribute1)
    THEN
        x_attribute1 := l_x_CURR_DETAILS_rec.attribute1;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.attribute10,
                            l_CURR_DETAILS_rec.attribute10)
    THEN
        x_attribute10 := l_x_CURR_DETAILS_rec.attribute10;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.attribute11,
                            l_CURR_DETAILS_rec.attribute11)
    THEN
        x_attribute11 := l_x_CURR_DETAILS_rec.attribute11;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.attribute12,
                            l_CURR_DETAILS_rec.attribute12)
    THEN
        x_attribute12 := l_x_CURR_DETAILS_rec.attribute12;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.attribute13,
                            l_CURR_DETAILS_rec.attribute13)
    THEN
        x_attribute13 := l_x_CURR_DETAILS_rec.attribute13;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.attribute14,
                            l_CURR_DETAILS_rec.attribute14)
    THEN
        x_attribute14 := l_x_CURR_DETAILS_rec.attribute14;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.attribute15,
                            l_CURR_DETAILS_rec.attribute15)
    THEN
        x_attribute15 := l_x_CURR_DETAILS_rec.attribute15;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.attribute2,
                            l_CURR_DETAILS_rec.attribute2)
    THEN
        x_attribute2 := l_x_CURR_DETAILS_rec.attribute2;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.attribute3,
                            l_CURR_DETAILS_rec.attribute3)
    THEN
        x_attribute3 := l_x_CURR_DETAILS_rec.attribute3;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.attribute4,
                            l_CURR_DETAILS_rec.attribute4)
    THEN
        x_attribute4 := l_x_CURR_DETAILS_rec.attribute4;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.attribute5,
                            l_CURR_DETAILS_rec.attribute5)
    THEN
        x_attribute5 := l_x_CURR_DETAILS_rec.attribute5;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.attribute6,
                            l_CURR_DETAILS_rec.attribute6)
    THEN
        x_attribute6 := l_x_CURR_DETAILS_rec.attribute6;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.attribute7,
                            l_CURR_DETAILS_rec.attribute7)
    THEN
        x_attribute7 := l_x_CURR_DETAILS_rec.attribute7;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.attribute8,
                            l_CURR_DETAILS_rec.attribute8)
    THEN
        x_attribute8 := l_x_CURR_DETAILS_rec.attribute8;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.attribute9,
                            l_CURR_DETAILS_rec.attribute9)
    THEN
        x_attribute9 := l_x_CURR_DETAILS_rec.attribute9;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.context,
                            l_CURR_DETAILS_rec.context)
    THEN
        x_context := l_x_CURR_DETAILS_rec.context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.conversion_date,
                            l_CURR_DETAILS_rec.conversion_date)
    THEN
        x_conversion_date := l_x_CURR_DETAILS_rec.conversion_date;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.conversion_date_type,
                            l_CURR_DETAILS_rec.conversion_date_type)
    THEN
        x_conversion_date_type := l_x_CURR_DETAILS_rec.conversion_date_type;
    END IF;

    /*
    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.conversion_method,
                            l_CURR_DETAILS_rec.conversion_method)
    THEN
        x_conversion_method := l_x_CURR_DETAILS_rec.conversion_method;
    END IF;
    */

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.conversion_type,
                            l_CURR_DETAILS_rec.conversion_type)
    THEN
        x_conversion_type := l_x_CURR_DETAILS_rec.conversion_type;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.currency_detail_id,
                            l_CURR_DETAILS_rec.currency_detail_id)
    THEN
        x_currency_detail_id := l_x_CURR_DETAILS_rec.currency_detail_id;
        x_currency_detail := l_CURR_DETAILS_val_rec.currency_detail;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.currency_header_id,
                            l_CURR_DETAILS_rec.currency_header_id)
    THEN
        x_currency_header_id := l_x_CURR_DETAILS_rec.currency_header_id;
        x_currency_header := l_CURR_DETAILS_val_rec.currency_header;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.end_date_active,
                            l_CURR_DETAILS_rec.end_date_active)
    THEN
        x_end_date_active := l_x_CURR_DETAILS_rec.end_date_active;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.fixed_value,
                            l_CURR_DETAILS_rec.fixed_value)
    THEN
        x_fixed_value := l_x_CURR_DETAILS_rec.fixed_value;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.markup_formula_id,
                            l_CURR_DETAILS_rec.markup_formula_id)
    THEN
        x_markup_formula_id := l_x_CURR_DETAILS_rec.markup_formula_id;
        x_markup_formula := l_CURR_DETAILS_val_rec.markup_formula;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.markup_operator,
                            l_CURR_DETAILS_rec.markup_operator)
    THEN
        x_markup_operator := l_x_CURR_DETAILS_rec.markup_operator;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.markup_value,
                            l_CURR_DETAILS_rec.markup_value)
    THEN
        x_markup_value := l_x_CURR_DETAILS_rec.markup_value;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.price_formula_id,
                            l_CURR_DETAILS_rec.price_formula_id)
    THEN
        x_price_formula_id := l_x_CURR_DETAILS_rec.price_formula_id;
        x_price_formula := l_CURR_DETAILS_val_rec.price_formula;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.rounding_factor,
                            l_CURR_DETAILS_rec.rounding_factor)
    THEN
        x_rounding_factor := l_x_CURR_DETAILS_rec.rounding_factor;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.selling_rounding_factor,
                            l_CURR_DETAILS_rec.selling_rounding_factor)
    THEN
        x_selling_rounding_factor := l_x_CURR_DETAILS_rec.selling_rounding_factor;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.start_date_active,
                            l_CURR_DETAILS_rec.start_date_active)
    THEN
        x_start_date_active := l_x_CURR_DETAILS_rec.start_date_active;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.to_currency_code,
                            l_CURR_DETAILS_rec.to_currency_code)
    THEN
        x_to_currency_code := l_x_CURR_DETAILS_rec.to_currency_code;
        x_to_currency := l_CURR_DETAILS_val_rec.to_currency;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.curr_attribute_type,
                            l_CURR_DETAILS_rec.curr_attribute_type)
    THEN
        x_curr_attribute_type := l_x_CURR_DETAILS_rec.curr_attribute_type;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.curr_attribute_context,
                            l_CURR_DETAILS_rec.curr_attribute_context)
    THEN
        x_curr_attribute_context := l_x_CURR_DETAILS_rec.curr_attribute_context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.curr_attribute,
                            l_CURR_DETAILS_rec.curr_attribute)
    THEN
        x_curr_attribute := l_x_CURR_DETAILS_rec.curr_attribute;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.curr_attribute_value,
                            l_CURR_DETAILS_rec.curr_attribute_value)
    THEN
        x_curr_attribute_value := l_x_CURR_DETAILS_rec.curr_attribute_value;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_DETAILS_rec.precedence,
                            l_CURR_DETAILS_rec.precedence)
    THEN
        x_precedence := l_x_CURR_DETAILS_rec.precedence;
    END IF;


    --  Write to cache.

    Write_CURR_DETAILS
    (   p_CURR_DETAILS_rec            => l_x_CURR_DETAILS_rec
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
,   p_currency_detail_id            IN  NUMBER
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_created_by                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_date              OUT NOCOPY /* file.sql.39 change */ DATE
,   x_last_updated_by               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_login             OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_CURR_DETAILS_rec            QP_Currency_PUB.Curr_Details_Rec_Type;
l_old_CURR_DETAILS_rec        QP_Currency_PUB.Curr_Details_Rec_Type;
l_CURR_DETAILS_tbl            QP_Currency_PUB.Curr_Details_Tbl_Type;
l_old_CURR_DETAILS_tbl        QP_Currency_PUB.Curr_Details_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_CURR_LISTS_rec            QP_Currency_PUB.Curr_Lists_Rec_Type;
l_x_CURR_DETAILS_rec          QP_Currency_PUB.Curr_Details_Rec_Type;
l_x_CURR_DETAILS_tbl          QP_Currency_PUB.Curr_Details_Tbl_Type;
BEGIN

    -- oe_debug_pub.add('Inside CDT-F Validate_And_Write');
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

    --  Read CURR_DETAILS from cache

    l_old_CURR_DETAILS_rec := Get_CURR_DETAILS
    (   p_db_record                   => TRUE
    ,   p_currency_detail_id          => p_currency_detail_id
    );

    l_CURR_DETAILS_rec := Get_CURR_DETAILS
    (   p_db_record                   => FALSE
    ,   p_currency_detail_id          => p_currency_detail_id
    );

    --  Set Operation.

    IF FND_API.To_Boolean(l_CURR_DETAILS_rec.db_flag) THEN
        l_CURR_DETAILS_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_CURR_DETAILS_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate CURR_DETAILS table

    l_CURR_DETAILS_tbl(1) := l_CURR_DETAILS_rec;
    l_old_CURR_DETAILS_tbl(1) := l_old_CURR_DETAILS_rec;

    --  Call QP_Currency_PVT.Process_Currency

    QP_Currency_PVT.Process_Currency
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_CURR_DETAILS_tbl            => l_CURR_DETAILS_tbl
    ,   p_old_CURR_DETAILS_tbl        => l_old_CURR_DETAILS_tbl
    ,   x_CURR_LISTS_rec              => l_x_CURR_LISTS_rec
    ,   x_CURR_DETAILS_tbl            => l_x_CURR_DETAILS_tbl
    );

    -- oe_debug_pub.add(' Insdie F package after V_A_W; G_MSG_COUNT: '||OE_MSG_PUB.G_MSG_COUNT);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.

    l_x_CURR_DETAILS_rec := l_x_CURR_DETAILS_tbl(1);

    x_creation_date                := l_x_CURR_DETAILS_rec.creation_date;
    x_created_by                   := l_x_CURR_DETAILS_rec.created_by;
    x_last_update_date             := l_x_CURR_DETAILS_rec.last_update_date;
    x_last_updated_by              := l_x_CURR_DETAILS_rec.last_updated_by;
    x_last_update_login            := l_x_CURR_DETAILS_rec.last_update_login;

    --  Clear CURR_DETAILS record cache

    Clear_CURR_DETAILS;

    --  Keep track of performed operations.

    l_old_CURR_DETAILS_rec.operation := l_CURR_DETAILS_rec.operation;


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
,   p_currency_detail_id            IN  NUMBER
)
IS
l_CURR_DETAILS_rec            QP_Currency_PUB.Curr_Details_Rec_Type;
l_CURR_DETAILS_tbl            QP_Currency_PUB.Curr_Details_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_CURR_LISTS_rec            QP_Currency_PUB.Curr_Lists_Rec_Type;
l_x_CURR_DETAILS_rec          QP_Currency_PUB.Curr_Details_Rec_Type;
l_x_CURR_DETAILS_tbl          QP_Currency_PUB.Curr_Details_Tbl_Type;
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

    l_CURR_DETAILS_rec := Get_CURR_DETAILS
    (   p_db_record                   => TRUE
    ,   p_currency_detail_id          => p_currency_detail_id
    );

    --  Set Operation.

    l_CURR_DETAILS_rec.operation := QP_GLOBALS.G_OPR_DELETE;

    --  Populate CURR_DETAILS table

    l_CURR_DETAILS_tbl(1) := l_CURR_DETAILS_rec;

    --  Call QP_Currency_PVT.Process_Currency

    QP_Currency_PVT.Process_Currency
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_CURR_DETAILS_tbl            => l_CURR_DETAILS_tbl
    ,   x_CURR_LISTS_rec              => l_x_CURR_LISTS_rec
    ,   x_CURR_DETAILS_tbl            => l_x_CURR_DETAILS_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear CURR_DETAILS record cache

    Clear_CURR_DETAILS;

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
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_CURR_LISTS_rec            QP_Currency_PUB.Curr_Lists_Rec_Type;
l_x_CURR_DETAILS_rec          QP_Currency_PUB.Curr_Details_Rec_Type;
l_x_CURR_DETAILS_tbl          QP_Currency_PUB.Curr_Details_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := QP_GLOBALS.G_ENTITY_CURR_DETAILS;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Call QP_Currency_PVT.Process_Currency

    QP_Currency_PVT.Process_Currency
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   x_CURR_LISTS_rec              => l_x_CURR_LISTS_rec
    ,   x_CURR_DETAILS_tbl            => l_x_CURR_DETAILS_tbl
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
,   p_context                       IN  VARCHAR2
,   p_conversion_date               IN  DATE
,   p_conversion_date_type          IN  VARCHAR2
-- ,   p_conversion_method             IN  VARCHAR2
,   p_conversion_type               IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_currency_detail_id            IN  NUMBER
,   p_currency_header_id            IN  NUMBER
,   p_end_date_active               IN  DATE
,   p_fixed_value                   IN  NUMBER
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_markup_formula_id             IN  NUMBER
,   p_markup_operator               IN  VARCHAR2
,   p_markup_value                  IN  NUMBER
,   p_price_formula_id              IN  NUMBER
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_request_id                    IN  NUMBER
,   p_rounding_factor               IN  NUMBER
,   p_selling_rounding_factor       IN  NUMBER
,   p_start_date_active             IN  DATE
,   p_to_currency_code              IN  VARCHAR2
,   p_curr_attribute_type           IN  VARCHAR2
,   p_curr_attribute_context        IN  VARCHAR2
,   p_curr_attribute                IN  VARCHAR2
,   p_curr_attribute_value          IN  VARCHAR2
,   p_precedence                    IN  NUMBER
)
IS
l_return_status               VARCHAR2(1);
l_CURR_DETAILS_rec            QP_Currency_PUB.Curr_Details_Rec_Type;
l_CURR_DETAILS_tbl            QP_Currency_PUB.Curr_Details_Tbl_Type;
l_x_CURR_LISTS_rec            QP_Currency_PUB.Curr_Lists_Rec_Type;
l_x_CURR_DETAILS_rec          QP_Currency_PUB.Curr_Details_Rec_Type;
l_x_CURR_DETAILS_tbl          QP_Currency_PUB.Curr_Details_Tbl_Type;
BEGIN

 -- oe_debug_pub.add('inside lock list currency');

    --  Load CURR_DETAILS record

    l_CURR_DETAILS_rec.attribute1  := p_attribute1;
    l_CURR_DETAILS_rec.attribute10 := p_attribute10;
    l_CURR_DETAILS_rec.attribute11 := p_attribute11;
    l_CURR_DETAILS_rec.attribute12 := p_attribute12;
    l_CURR_DETAILS_rec.attribute13 := p_attribute13;
    l_CURR_DETAILS_rec.attribute14 := p_attribute14;
    l_CURR_DETAILS_rec.attribute15 := p_attribute15;
    l_CURR_DETAILS_rec.attribute2  := p_attribute2;
    l_CURR_DETAILS_rec.attribute3  := p_attribute3;
    l_CURR_DETAILS_rec.attribute4  := p_attribute4;
    l_CURR_DETAILS_rec.attribute5  := p_attribute5;
    l_CURR_DETAILS_rec.attribute6  := p_attribute6;
    l_CURR_DETAILS_rec.attribute7  := p_attribute7;
    l_CURR_DETAILS_rec.attribute8  := p_attribute8;
    l_CURR_DETAILS_rec.attribute9  := p_attribute9;
    l_CURR_DETAILS_rec.context     := p_context;
    l_CURR_DETAILS_rec.conversion_date := p_conversion_date;
    l_CURR_DETAILS_rec.conversion_date_type := p_conversion_date_type;
    -- l_CURR_DETAILS_rec.conversion_method := p_conversion_method;
    l_CURR_DETAILS_rec.conversion_type := p_conversion_type;
    l_CURR_DETAILS_rec.created_by  := p_created_by;
    l_CURR_DETAILS_rec.creation_date := p_creation_date;
    l_CURR_DETAILS_rec.currency_detail_id := p_currency_detail_id;
    l_CURR_DETAILS_rec.currency_header_id := p_currency_header_id;
    l_CURR_DETAILS_rec.end_date_active := p_end_date_active;
    l_CURR_DETAILS_rec.fixed_value := p_fixed_value;
    l_CURR_DETAILS_rec.last_updated_by := p_last_updated_by;
    l_CURR_DETAILS_rec.last_update_date := p_last_update_date;
    l_CURR_DETAILS_rec.last_update_login := p_last_update_login;
    l_CURR_DETAILS_rec.markup_formula_id := p_markup_formula_id;
    l_CURR_DETAILS_rec.markup_operator := p_markup_operator;
    l_CURR_DETAILS_rec.markup_value := p_markup_value;
    l_CURR_DETAILS_rec.price_formula_id := p_price_formula_id;
    l_CURR_DETAILS_rec.program_application_id := p_program_application_id;
    l_CURR_DETAILS_rec.program_id  := p_program_id;
    l_CURR_DETAILS_rec.program_update_date := p_program_update_date;
    l_CURR_DETAILS_rec.request_id  := p_request_id;
    l_CURR_DETAILS_rec.rounding_factor := p_rounding_factor;
    l_CURR_DETAILS_rec.selling_rounding_factor := p_selling_rounding_factor;
    l_CURR_DETAILS_rec.start_date_active := p_start_date_active;
    l_CURR_DETAILS_rec.to_currency_code := p_to_currency_code;
    l_CURR_DETAILS_rec.curr_attribute_type := p_curr_attribute_type;
    l_CURR_DETAILS_rec.curr_attribute_context := p_curr_attribute_context;
    l_CURR_DETAILS_rec.curr_attribute := p_curr_attribute;
    l_CURR_DETAILS_rec.curr_attribute_value := p_curr_attribute_value;
    l_CURR_DETAILS_rec.precedence := p_precedence;

    --  Populate CURR_DETAILS table

    l_CURR_DETAILS_tbl(1) := l_CURR_DETAILS_rec;

     -- oe_debug_pub.add('before calling QP_Currency_PVT.Lock_Currency');
    --  Call QP_Currency_PVT.Lock_Currency

    QP_Currency_PVT.Lock_Currency
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_CURR_DETAILS_tbl            => l_CURR_DETAILS_tbl
    ,   x_CURR_LISTS_rec              => l_x_CURR_LISTS_rec
    ,   x_CURR_DETAILS_tbl            => l_x_CURR_DETAILS_tbl
    );
     -- oe_debug_pub.add('after calling QP_Currency_PVT.Lock_Currency');

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_CURR_DETAILS_rec.db_flag := FND_API.G_TRUE;

        Write_CURR_DETAILS
        (   p_CURR_DETAILS_rec            => l_x_CURR_DETAILS_rec
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

--  Procedures maintaining CURR_DETAILS record cache.

PROCEDURE Write_CURR_DETAILS
(   p_CURR_DETAILS_rec              IN  QP_Currency_PUB.Curr_Details_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
BEGIN

    g_CURR_DETAILS_rec := p_CURR_DETAILS_rec;

    IF p_db_record THEN

        g_db_CURR_DETAILS_rec := p_CURR_DETAILS_rec;

    END IF;

END Write_Curr_Details;

FUNCTION Get_CURR_DETAILS
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_currency_detail_id            IN  NUMBER
)
RETURN QP_Currency_PUB.Curr_Details_Rec_Type
IS
BEGIN

    IF  p_currency_detail_id <> g_CURR_DETAILS_rec.currency_detail_id
    THEN

        --  Query row from DB

        g_CURR_DETAILS_rec := QP_Curr_Details_Util.Query_Row
        (   p_currency_detail_id          => p_currency_detail_id
        );

        g_CURR_DETAILS_rec.db_flag     := FND_API.G_TRUE;

        --  Load DB record

        g_db_CURR_DETAILS_rec          := g_CURR_DETAILS_rec;

    END IF;

    IF p_db_record THEN

        RETURN g_db_CURR_DETAILS_rec;

    ELSE

        RETURN g_CURR_DETAILS_rec;

    END IF;

END Get_Curr_Details;

PROCEDURE Clear_Curr_Details
IS
BEGIN

    g_CURR_DETAILS_rec             := QP_Currency_PUB.G_MISS_CURR_DETAILS_REC;
    g_db_CURR_DETAILS_rec          := QP_Currency_PUB.G_MISS_CURR_DETAILS_REC;

END Clear_Curr_Details;

END QP_QP_Form_Curr_Details;

/
