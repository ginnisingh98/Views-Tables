--------------------------------------------------------
--  DDL for Package Body QP_QP_FORM_PLL_PRICING_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_QP_FORM_PLL_PRICING_ATTR" AS
/* $Header: QPXFPLAB.pls 120.5 2008/06/12 07:42:04 kdurgasi ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'Qp_Qp_Form_pll_pricing_attr';

--  Global variables holding cached record.

g_PRICING_ATTR_rec            QP_Price_List_PUB.Pricing_Attr_Rec_Type;
g_db_PRICING_ATTR_rec         QP_Price_List_PUB.Pricing_Attr_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_PRICING_ATTR
(   p_PRICING_ATTR_rec              IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

FUNCTION Get_PRICING_ATTR
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_pricing_attribute_id          IN  NUMBER
)
RETURN QP_Price_List_PUB.Pricing_Attr_Rec_Type;

PROCEDURE Clear_PRICING_ATTR;

--  Global variable holding performed operations.

g_opr__tbl                    QP_Price_List_PUB.Pricing_Attr_Tbl_Type;

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_header_id                IN NUMBER DEFAULT NULL
,   p_list_line_id                  IN NUMBER
,   x_accumulate_flag               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
,   x_attribute_grouping_no         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_excluder_flag                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_attribute             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute_context     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute_id          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_attr_value_from       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attr_value_to         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_attribute             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_attribute_context     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_attr_value            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_uom_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_accumulate                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_excluder                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_uom                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_from_rltd_modifier_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_comparison_operator_code      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute_datatype    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_attribute_datatype    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_from_rltd_modifier_id         IN  NUMBER := NULL
,   p_pricing_attribute_context     IN  VARCHAR2 := NULL
,   p_pricing_attribute             IN  VARCHAR2 := NULL
)
IS
l_PRICING_ATTR_rec            QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_PRICING_ATTR_val_rec        QP_Price_List_PUB.Pricing_Attr_Val_Rec_Type;
l_PRICING_ATTR_tbl            QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_QUALIFIERS_rec            Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
BEGIN

    oe_debug_pub.add('Ren: inside default attr of prc attr 1');
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


    l_PRICING_ATTR_rec.list_header_id := p_list_header_id;
    l_PRICING_ATTR_rec.list_line_id := p_list_line_id;
    l_PRICING_ATTR_rec.from_rltd_modifier_id := p_from_rltd_modifier_id;
 l_PRICING_ATTR_rec.pricing_attribute_context := p_pricing_attribute_context;
 l_PRICING_ATTR_rec.pricing_attribute := p_pricing_attribute;



    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

    l_PRICING_ATTR_rec.attribute1                 := NULL;
    l_PRICING_ATTR_rec.attribute10                := NULL;
    l_PRICING_ATTR_rec.attribute11                := NULL;
    l_PRICING_ATTR_rec.attribute12                := NULL;
    l_PRICING_ATTR_rec.attribute13                := NULL;
    l_PRICING_ATTR_rec.attribute14                := NULL;
    l_PRICING_ATTR_rec.attribute15                := NULL;
    l_PRICING_ATTR_rec.attribute2                 := NULL;
    l_PRICING_ATTR_rec.attribute3                 := NULL;
    l_PRICING_ATTR_rec.attribute4                 := NULL;
    l_PRICING_ATTR_rec.attribute5                 := NULL;
    l_PRICING_ATTR_rec.attribute6                 := NULL;
    l_PRICING_ATTR_rec.attribute7                 := NULL;
    l_PRICING_ATTR_rec.attribute8                 := NULL;
    l_PRICING_ATTR_rec.attribute9                 := NULL;
    l_PRICING_ATTR_rec.context                    := NULL;

    --  Set Operation to Create

    l_PRICING_ATTR_rec.operation := QP_GLOBALS.G_OPR_CREATE;

    --  Populate PRICING_ATTR table

    l_PRICING_ATTR_tbl(1) := l_PRICING_ATTR_rec;

    --  Call QP_LIST_HEADERS_PVT.Process_PRICE_LIST

    QP_LIST_HEADERS_PVT.Process_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

    oe_debug_pub.add('Ren: after process price list 1');

    oe_debug_pub.add('return status is : ' || l_return_status);

    oe_debug_pub.add('ren: msg data 1 is : ' || x_msg_data);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl

    l_x_PRICING_ATTR_rec := l_x_PRICING_ATTR_tbl(1);

    --  Load OUT parameters.

    x_accumulate_flag              := l_x_PRICING_ATTR_rec.accumulate_flag;
    x_attribute1                   := l_x_PRICING_ATTR_rec.attribute1;
    x_attribute10                  := l_x_PRICING_ATTR_rec.attribute10;
    x_attribute11                  := l_x_PRICING_ATTR_rec.attribute11;
    x_attribute12                  := l_x_PRICING_ATTR_rec.attribute12;
    x_attribute13                  := l_x_PRICING_ATTR_rec.attribute13;
    x_attribute14                  := l_x_PRICING_ATTR_rec.attribute14;
    x_attribute15                  := l_x_PRICING_ATTR_rec.attribute15;
    x_attribute2                   := l_x_PRICING_ATTR_rec.attribute2;
    x_attribute3                   := l_x_PRICING_ATTR_rec.attribute3;
    x_attribute4                   := l_x_PRICING_ATTR_rec.attribute4;
    x_attribute5                   := l_x_PRICING_ATTR_rec.attribute5;
    x_attribute6                   := l_x_PRICING_ATTR_rec.attribute6;
    x_attribute7                   := l_x_PRICING_ATTR_rec.attribute7;
    x_attribute8                   := l_x_PRICING_ATTR_rec.attribute8;
    x_attribute9                   := l_x_PRICING_ATTR_rec.attribute9;
    x_attribute_grouping_no        := l_x_PRICING_ATTR_rec.attribute_grouping_no;
    x_context                      := l_x_PRICING_ATTR_rec.context;
    x_excluder_flag                := l_x_PRICING_ATTR_rec.excluder_flag;
    x_list_line_id                 := l_x_PRICING_ATTR_rec.list_line_id;
    x_pricing_attribute            := l_x_PRICING_ATTR_rec.pricing_attribute;
    x_pricing_attribute_context    := l_x_PRICING_ATTR_rec.pricing_attribute_context;
    x_pricing_attribute_id         := l_x_PRICING_ATTR_rec.pricing_attribute_id;
    x_pricing_attr_value_from      := l_x_PRICING_ATTR_rec.pricing_attr_value_from;
    x_pricing_attr_value_to        := l_x_PRICING_ATTR_rec.pricing_attr_value_to;
    x_product_attribute            := l_x_PRICING_ATTR_rec.product_attribute;
    x_product_attribute_context    := l_x_PRICING_ATTR_rec.product_attribute_context;
    x_product_attr_value           := l_x_PRICING_ATTR_rec.product_attr_value;
    x_product_uom_code             := l_x_PRICING_ATTR_rec.product_uom_code;
    x_from_rltd_modifier_id        := l_x_PRICING_ATTR_rec.from_rltd_modifier_id;
    x_comparison_operator_code     := l_x_PRICING_ATTR_rec.comparison_operator_code;
    x_pricing_attribute_datatype := l_x_PRICING_ATTR_rec.pricing_attribute_datatype;
    x_product_attribute_datatype := l_x_PRICING_ATTR_rec.product_attribute_datatype;

    --  Load display out parameters if any

    oe_debug_pub.add('Ren: before get_values 1');
    oe_debug_pub.add('ren : msg data 0.5 is : ' || x_msg_data);

    l_PRICING_ATTR_val_rec := Qp_pll_pricing_attr_Util.Get_Values
    (   p_PRICING_ATTR_rec            => l_x_PRICING_ATTR_rec
    );
    x_accumulate                   := l_PRICING_ATTR_val_rec.accumulate;
    x_excluder                     := l_PRICING_ATTR_val_rec.excluder;
    x_list_line                    := l_PRICING_ATTR_val_rec.list_line;
    x_product_uom                  := l_PRICING_ATTR_val_rec.product_uom;


    oe_debug_pub.add('Ren: after get_values 1 ');

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_PRICING_ATTR_rec.db_flag := FND_API.G_FALSE;

    oe_debug_pub.add('Ren: before write prc attr 1');
    oe_debug_pub.add('Ren: msg data 1 is :' || x_msg_data);

    Write_PRICING_ATTR
    (   p_PRICING_ATTR_rec            => l_x_PRICING_ATTR_rec
    );

    oe_debug_pub.add('Ren: msg data 2 is :' || x_msg_data);

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

   oe_debug_pub.add('Ren: msg data 2.5 is :' || x_msg_data);

   oe_debug_pub.add('exiting default attributes');


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
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
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_pricing_attribute_id          IN  NUMBER
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
,   x_accumulate_flag               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
,   x_attribute_grouping_no         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_excluder_flag                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_attribute             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute_context     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute_id          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_attr_value_from       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attr_value_to         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_attribute             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_attribute_context     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_attr_value            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_uom_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_accumulate                    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_excluder                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_line                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_uom                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_from_rltd_modifier_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_comparison_operator_code      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute_datatype    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_product_attribute_datatype    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_PRICING_ATTR_rec            QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_old_PRICING_ATTR_rec        QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_PRICING_ATTR_val_rec        QP_Price_List_PUB.Pricing_Attr_Val_Rec_Type;
l_PRICING_ATTR_tbl            QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_old_PRICING_ATTR_tbl        QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_QUALIFIERS_rec            Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
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

    --  Read PRICING_ATTR from cache

    l_PRICING_ATTR_rec := Get_PRICING_ATTR
    (   p_db_record                   => FALSE
    ,   p_pricing_attribute_id        => p_pricing_attribute_id
    );

    l_old_PRICING_ATTR_rec         := l_PRICING_ATTR_rec;

    IF p_attr_id = Qp_pll_pricing_attr_Util.G_ACCUMULATE THEN
        l_PRICING_ATTR_rec.accumulate_flag := p_attr_value;
    ELSIF p_attr_id = Qp_pll_pricing_attr_Util.G_ATTRIBUTE_GROUPING_NO THEN
        l_PRICING_ATTR_rec.attribute_grouping_no := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = Qp_pll_pricing_attr_Util.G_EXCLUDER THEN
        l_PRICING_ATTR_rec.excluder_flag := p_attr_value;
    ELSIF p_attr_id = Qp_pll_pricing_attr_Util.G_LIST_LINE THEN
        l_PRICING_ATTR_rec.list_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = Qp_pll_pricing_attr_Util.G_PRICING_ATTRIBUTE THEN
        l_PRICING_ATTR_rec.pricing_attribute := p_attr_value;
    ELSIF p_attr_id = Qp_pll_pricing_attr_Util.G_PRICING_ATTRIBUTE_CONTEXT THEN
        l_PRICING_ATTR_rec.pricing_attribute_context := p_attr_value;
/*
    ELSIF p_attr_id = Qp_pll_pricing_attr_Util.G_PRICING_ATTRIBUTE THEN
        l_PRICING_ATTR_rec.pricing_attribute_id := TO_NUMBER(p_attr_value);
*/
    ELSIF p_attr_id = Qp_pll_pricing_attr_Util.G_PRICING_ATTR_VALUE_FROM THEN
        l_PRICING_ATTR_rec.pricing_attr_value_from := p_attr_value;
    ELSIF p_attr_id = Qp_pll_pricing_attr_Util.G_PRICING_ATTR_VALUE_TO THEN
        l_PRICING_ATTR_rec.pricing_attr_value_to := p_attr_value;
    ELSIF p_attr_id = Qp_pll_pricing_attr_Util.G_PRODUCT_ATTRIBUTE THEN
        l_PRICING_ATTR_rec.product_attribute := p_attr_value;
    ELSIF p_attr_id = Qp_pll_pricing_attr_Util.G_PRODUCT_ATTRIBUTE_CONTEXT THEN
        l_PRICING_ATTR_rec.product_attribute_context := p_attr_value;
    ELSIF p_attr_id = Qp_pll_pricing_attr_Util.G_PRODUCT_ATTR_VALUE THEN
        l_PRICING_ATTR_rec.product_attr_value := p_attr_value;
    ELSIF p_attr_id = Qp_pll_pricing_attr_Util.G_PRODUCT_UOM THEN
        l_PRICING_ATTR_rec.product_uom_code := p_attr_value;
    ELSIF p_attr_id = Qp_pll_pricing_attr_Util.G_FROM_RLTD_MODIFIER THEN
        l_PRICING_ATTR_rec.from_rltd_modifier_id := to_number(p_attr_value);
    ELSIF p_attr_id = Qp_pll_pricing_attr_Util.G_COMPARISON_OPERATOR_CODE THEN
	   l_PRICING_ATTR_rec.comparison_operator_code := p_attr_value;
  ELSIF p_attr_id = Qp_pll_pricing_attr_Util.G_PRICING_ATTRIBUTE_DATATYPE THEN
	   l_PRICING_ATTR_rec.pricing_attribute_datatype := p_attr_value;
  ELSIF p_attr_id = Qp_pll_pricing_attr_Util.G_PRODUCT_ATTRIBUTE_DATATYPE THEN
	   l_PRICING_ATTR_rec.product_attribute_datatype := p_attr_value;
    ELSIF p_attr_id = Qp_pll_pricing_attr_Util.G_ATTRIBUTE1
    OR     p_attr_id = Qp_pll_pricing_attr_Util.G_ATTRIBUTE10
    OR     p_attr_id = Qp_pll_pricing_attr_Util.G_ATTRIBUTE11
    OR     p_attr_id = Qp_pll_pricing_attr_Util.G_ATTRIBUTE12
    OR     p_attr_id = Qp_pll_pricing_attr_Util.G_ATTRIBUTE13
    OR     p_attr_id = Qp_pll_pricing_attr_Util.G_ATTRIBUTE14
    OR     p_attr_id = Qp_pll_pricing_attr_Util.G_ATTRIBUTE15
    OR     p_attr_id = Qp_pll_pricing_attr_Util.G_ATTRIBUTE2
    OR     p_attr_id = Qp_pll_pricing_attr_Util.G_ATTRIBUTE3
    OR     p_attr_id = Qp_pll_pricing_attr_Util.G_ATTRIBUTE4
    OR     p_attr_id = Qp_pll_pricing_attr_Util.G_ATTRIBUTE5
    OR     p_attr_id = Qp_pll_pricing_attr_Util.G_ATTRIBUTE6
    OR     p_attr_id = Qp_pll_pricing_attr_Util.G_ATTRIBUTE7
    OR     p_attr_id = Qp_pll_pricing_attr_Util.G_ATTRIBUTE8
    OR     p_attr_id = Qp_pll_pricing_attr_Util.G_ATTRIBUTE9
    OR     p_attr_id = Qp_pll_pricing_attr_Util.G_CONTEXT
    THEN

        l_PRICING_ATTR_rec.attribute1  := p_attribute1;
        l_PRICING_ATTR_rec.attribute10 := p_attribute10;
        l_PRICING_ATTR_rec.attribute11 := p_attribute11;
        l_PRICING_ATTR_rec.attribute12 := p_attribute12;
        l_PRICING_ATTR_rec.attribute14 := p_attribute14;
        l_PRICING_ATTR_rec.attribute15 := p_attribute15;
        l_PRICING_ATTR_rec.attribute2  := p_attribute2;
        l_PRICING_ATTR_rec.attribute3  := p_attribute3;
        l_PRICING_ATTR_rec.attribute4  := p_attribute4;
        l_PRICING_ATTR_rec.attribute5  := p_attribute5;
        l_PRICING_ATTR_rec.attribute6  := p_attribute6;
        l_PRICING_ATTR_rec.attribute7  := p_attribute7;
        l_PRICING_ATTR_rec.attribute8  := p_attribute8;
        l_PRICING_ATTR_rec.attribute9  := p_attribute9;
        l_PRICING_ATTR_rec.context     := p_context;

    ELSE

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

    --  Set Operation.

    IF FND_API.To_Boolean(l_PRICING_ATTR_rec.db_flag) THEN
        l_PRICING_ATTR_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_PRICING_ATTR_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate PRICING_ATTR table

    l_PRICING_ATTR_tbl(1) := l_PRICING_ATTR_rec;
    l_old_PRICING_ATTR_tbl(1) := l_old_PRICING_ATTR_rec;

    --  Call QP_LIST_HEADERS_PVT.Process_PRICE_LIST

    QP_LIST_HEADERS_PVT.Process_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    ,   p_old_PRICING_ATTR_tbl        => l_old_PRICING_ATTR_tbl
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl

    l_x_PRICING_ATTR_rec := l_x_PRICING_ATTR_tbl(1);

    --  Init OUT parameters to missing.

    x_accumulate_flag              := FND_API.G_MISS_CHAR;
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
    x_attribute_grouping_no        := FND_API.G_MISS_NUM;
    x_context                      := FND_API.G_MISS_CHAR;
    x_excluder_flag                := FND_API.G_MISS_CHAR;
    x_list_line_id                 := FND_API.G_MISS_NUM;
    x_pricing_attribute            := FND_API.G_MISS_CHAR;
    x_pricing_attribute_context    := FND_API.G_MISS_CHAR;
    x_pricing_attribute_id         := FND_API.G_MISS_NUM;
    x_pricing_attr_value_from      := FND_API.G_MISS_CHAR;
    x_pricing_attr_value_to        := FND_API.G_MISS_CHAR;
    x_product_attribute            := FND_API.G_MISS_CHAR;
    x_product_attribute_context    := FND_API.G_MISS_CHAR;
    x_product_attr_value           := FND_API.G_MISS_CHAR;
    x_product_uom_code             := FND_API.G_MISS_CHAR;
    x_accumulate                   := FND_API.G_MISS_CHAR;
    x_excluder                     := FND_API.G_MISS_CHAR;
    x_list_line                    := FND_API.G_MISS_CHAR;
    x_product_uom                  := FND_API.G_MISS_CHAR;
    x_from_rltd_modifier_id        := FND_API.G_MISS_NUM;
    x_comparison_operator_code     := FND_API.G_MISS_CHAR;
    x_pricing_attribute_datatype   := FND_API.G_MISS_CHAR;
    x_product_attribute_datatype   := FND_API.G_MISS_CHAR;

    --  Load display out parameters if any

    l_PRICING_ATTR_val_rec := Qp_pll_pricing_attr_Util.Get_Values
    (   p_PRICING_ATTR_rec            => l_x_PRICING_ATTR_rec
    ,   p_old_PRICING_ATTR_rec        => l_PRICING_ATTR_rec
    );

    --  Return changed attributes.

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.accumulate_flag,
                            l_PRICING_ATTR_rec.accumulate_flag)
    THEN
        x_accumulate_flag := l_x_PRICING_ATTR_rec.accumulate_flag;
        x_accumulate := l_PRICING_ATTR_val_rec.accumulate;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.from_rltd_modifier_id,
                            l_PRICING_ATTR_rec.from_rltd_modifier_id)
    THEN
        x_from_rltd_modifier_id := l_x_PRICING_ATTR_rec.from_rltd_modifier_id;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.attribute1,
                            l_PRICING_ATTR_rec.attribute1)
    THEN
        x_attribute1 := l_x_PRICING_ATTR_rec.attribute1;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.attribute10,
                            l_PRICING_ATTR_rec.attribute10)
    THEN
        x_attribute10 := l_x_PRICING_ATTR_rec.attribute10;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.attribute11,
                            l_PRICING_ATTR_rec.attribute11)
    THEN
        x_attribute11 := l_x_PRICING_ATTR_rec.attribute11;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.attribute12,
                            l_PRICING_ATTR_rec.attribute12)
    THEN
        x_attribute12 := l_x_PRICING_ATTR_rec.attribute12;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.attribute13,
                            l_PRICING_ATTR_rec.attribute13)
    THEN
        x_attribute13 := l_x_PRICING_ATTR_rec.attribute13;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.attribute14,
                            l_PRICING_ATTR_rec.attribute14)
    THEN
        x_attribute14 := l_x_PRICING_ATTR_rec.attribute14;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.attribute15,
                            l_PRICING_ATTR_rec.attribute15)
    THEN
        x_attribute15 := l_x_PRICING_ATTR_rec.attribute15;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.attribute2,
                            l_PRICING_ATTR_rec.attribute2)
    THEN
        x_attribute2 := l_x_PRICING_ATTR_rec.attribute2;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.attribute3,
                            l_PRICING_ATTR_rec.attribute3)
    THEN
        x_attribute3 := l_x_PRICING_ATTR_rec.attribute3;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.attribute4,
                            l_PRICING_ATTR_rec.attribute4)
    THEN
        x_attribute4 := l_x_PRICING_ATTR_rec.attribute4;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.attribute5,
                            l_PRICING_ATTR_rec.attribute5)
    THEN
        x_attribute5 := l_x_PRICING_ATTR_rec.attribute5;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.attribute6,
                            l_PRICING_ATTR_rec.attribute6)
    THEN
        x_attribute6 := l_x_PRICING_ATTR_rec.attribute6;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.attribute7,
                            l_PRICING_ATTR_rec.attribute7)
    THEN
        x_attribute7 := l_x_PRICING_ATTR_rec.attribute7;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.attribute8,
                            l_PRICING_ATTR_rec.attribute8)
    THEN
        x_attribute8 := l_x_PRICING_ATTR_rec.attribute8;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.attribute9,
                            l_PRICING_ATTR_rec.attribute9)
    THEN
        x_attribute9 := l_x_PRICING_ATTR_rec.attribute9;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.attribute_grouping_no,
                            l_PRICING_ATTR_rec.attribute_grouping_no)
    THEN
        x_attribute_grouping_no := l_x_PRICING_ATTR_rec.attribute_grouping_no;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.context,
                            l_PRICING_ATTR_rec.context)
    THEN
        x_context := l_x_PRICING_ATTR_rec.context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.excluder_flag,
                            l_PRICING_ATTR_rec.excluder_flag)
    THEN
        x_excluder_flag := l_x_PRICING_ATTR_rec.excluder_flag;
        x_excluder := l_PRICING_ATTR_val_rec.excluder;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.list_line_id,
                            l_PRICING_ATTR_rec.list_line_id)
    THEN
        x_list_line_id := l_x_PRICING_ATTR_rec.list_line_id;
        x_list_line := l_PRICING_ATTR_val_rec.list_line;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.pricing_attribute,
                            l_PRICING_ATTR_rec.pricing_attribute)
    THEN
        x_pricing_attribute := l_x_PRICING_ATTR_rec.pricing_attribute;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.pricing_attribute_context,
                            l_PRICING_ATTR_rec.pricing_attribute_context)
    THEN
        x_pricing_attribute_context := l_x_PRICING_ATTR_rec.pricing_attribute_context;
    END IF;

/*  IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.pricing_attribute_id,
                            l_PRICING_ATTR_rec.pricing_attribute_id)
    THEN
        x_pricing_attribute_id := l_x_PRICING_ATTR_rec.pricing_attribute_id;
        x_pricing_attribute := l_PRICING_ATTR_val_rec.pricing_attribute;
    END IF;
*/
    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.pricing_attr_value_from,
                            l_PRICING_ATTR_rec.pricing_attr_value_from)
    THEN
        x_pricing_attr_value_from := l_x_PRICING_ATTR_rec.pricing_attr_value_from;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.pricing_attr_value_to,
                            l_PRICING_ATTR_rec.pricing_attr_value_to)
    THEN
        x_pricing_attr_value_to := l_x_PRICING_ATTR_rec.pricing_attr_value_to;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.product_attribute,
                            l_PRICING_ATTR_rec.product_attribute)
    THEN
        x_product_attribute := l_x_PRICING_ATTR_rec.product_attribute;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.product_attribute_context,
                            l_PRICING_ATTR_rec.product_attribute_context)
    THEN
        x_product_attribute_context := l_x_PRICING_ATTR_rec.product_attribute_context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.product_attr_value,
                            l_PRICING_ATTR_rec.product_attr_value)
    THEN
        x_product_attr_value := l_x_PRICING_ATTR_rec.product_attr_value;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.product_uom_code,
                            l_PRICING_ATTR_rec.product_uom_code)
    THEN
        x_product_uom_code := l_x_PRICING_ATTR_rec.product_uom_code;
        x_product_uom := l_PRICING_ATTR_val_rec.product_uom;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.comparison_operator_code,
					   l_PRICING_ATTR_rec.comparison_operator_code)
    THEN
	   x_comparison_operator_code := l_PRICING_ATTR_rec.comparison_operator_code;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.pricing_attribute_datatype,
					   l_PRICING_ATTR_rec.pricing_attribute_datatype)
    THEN
	   x_pricing_attribute_datatype := l_PRICING_ATTR_rec.pricing_attribute_datatype;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.product_attribute_datatype,
					   l_PRICING_ATTR_rec.product_attribute_datatype)
    THEN
	   x_product_attribute_datatype := l_PRICING_ATTR_rec.product_attribute_datatype;
    END IF;



    --  Write to cache.

    Write_PRICING_ATTR
    (   p_PRICING_ATTR_rec            => l_x_PRICING_ATTR_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
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

--  Procedure       Validate_And_Write
--

PROCEDURE Validate_And_Write
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_pricing_attribute_id          IN  NUMBER
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_created_by                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_date              OUT NOCOPY /* file.sql.39 change */ DATE
,   x_last_updated_by               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_login             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_program_application_id        OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_program_id                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_program_update_date           OUT NOCOPY /* file.sql.39 change */ DATE
,   x_request_id                    OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_PRICING_ATTR_rec            QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_old_PRICING_ATTR_rec        QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_PRICING_ATTR_tbl            QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_old_PRICING_ATTR_tbl        QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_QUALIFIERS_rec            Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
BEGIN

   oe_debug_pub.add('entering validate_and_write');
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

    --  Read PRICING_ATTR from cache

    l_old_PRICING_ATTR_rec := Get_PRICING_ATTR
    (   p_db_record                   => TRUE
    ,   p_pricing_attribute_id        => p_pricing_attribute_id
    );

    l_PRICING_ATTR_rec := Get_PRICING_ATTR
    (   p_db_record                   => FALSE
    ,   p_pricing_attribute_id        => p_pricing_attribute_id
    );

    --  Set Operation.

    IF FND_API.To_Boolean(l_PRICING_ATTR_rec.db_flag) THEN
        l_PRICING_ATTR_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_PRICING_ATTR_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate PRICING_ATTR table

    l_PRICING_ATTR_tbl(1) := l_PRICING_ATTR_rec;
    l_old_PRICING_ATTR_tbl(1) := l_old_PRICING_ATTR_rec;

    --  Call QP_LIST_HEADERS_PVT.Process_PRICE_LIST

    QP_LIST_HEADERS_PVT.Process_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    ,   p_old_PRICING_ATTR_tbl        => l_old_PRICING_ATTR_tbl
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.

    l_x_PRICING_ATTR_rec := l_x_PRICING_ATTR_tbl(1);

    x_creation_date                := l_x_PRICING_ATTR_rec.creation_date;
    x_created_by                   := l_x_PRICING_ATTR_rec.created_by;
    x_last_update_date             := l_x_PRICING_ATTR_rec.last_update_date;
    x_last_updated_by              := l_x_PRICING_ATTR_rec.last_updated_by;
    x_last_update_login            := l_x_PRICING_ATTR_rec.last_update_login;
    x_program_application_id       := l_x_PRICING_ATTR_rec.program_application_id;
    x_program_id                   := l_x_PRICING_ATTR_rec.program_id;
    x_program_update_date          := l_x_PRICING_ATTR_rec.program_update_date;
    x_request_id                   := l_x_PRICING_ATTR_rec.request_id;

    --  Clear PRICING_ATTR record cache

    Clear_PRICING_ATTR;

    --  Keep track of performed operations.

    l_old_PRICING_ATTR_rec.operation := l_PRICING_ATTR_rec.operation;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

   oe_debug_pub.add('Ren: msg data in val_and_write of attr 1 is :' || x_msg_data);

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );
   oe_debug_pub.add('Ren: msg data in val_and_write of attr 2 is :' || x_msg_data);

  oe_debug_pub.add('exiting validate_and_write');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
   oe_debug_pub.add('Ren: msg data in val_and_write of attr 10 is :' || x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
   oe_debug_pub.add('Ren: msg data in val_and_write of attr 11 is :' || x_msg_data);

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
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
   oe_debug_pub.add('Ren: msg data in val_and_write of attr 12 is :' || x_msg_data);

END Validate_And_Write;

--  Procedure       Delete_Row
--

PROCEDURE Delete_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_pricing_attribute_id          IN  NUMBER
)
IS
l_PRICING_ATTR_rec            QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_PRICING_ATTR_tbl            QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_QUALIFIERS_rec            Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
-- start bug2301959
l_revision VARCHAR2(30);
l_start_date_active DATE;
l_end_date_active DATE;
l_list_header_id NUMBER;
-- end bug2301959
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE; -- Changed back to false. bug 7165334

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Read DB record from cache

    l_PRICING_ATTR_rec := Get_PRICING_ATTR
    (   p_db_record                   => TRUE
    ,   p_pricing_attribute_id        => p_pricing_attribute_id
    );

    --  Set Operation.

    l_PRICING_ATTR_rec.operation := QP_GLOBALS.G_OPR_DELETE;

    --  Populate PRICING_ATTR table

    l_PRICING_ATTR_tbl(1) := l_PRICING_ATTR_rec;

    --  Call QP_LIST_HEADERS_PVT.Process_PRICE_LIST

--start bug 2301959

select start_date_active, end_date_active , revision, list_header_id
    into l_start_date_active, l_end_date_active, l_revision, l_list_header_id
    from qp_list_lines
    where list_line_id = l_pricing_attr_rec.list_line_id;

IF (QP_GLOBALS.G_CHECK_DUP_PRICELIST_LINES <> 'N' or QP_GLOBALS.G_CHECK_DUP_PRICELIST_LINES IS NULL)
THEN -- 5018856, 5024919 do not log request if N

   oe_debug_pub.add('about to log a request to check duplicate list lines ');

   QP_DELAYED_REQUESTS_PVT.Log_Request
    ( p_entity_code		=> QP_GLOBALS.G_ENTITY_ALL
,     p_entity_id		=> l_pricing_attr_rec.list_line_id
,   p_requesting_entity_code	=> QP_GLOBALS.G_ENTITY_ALL
,   p_requesting_entity_id	=> l_pricing_attr_rec.list_line_id
,   p_request_type		=> QP_GLOBALS.G_DUPLICATE_LIST_LINES
,   p_param1			=> l_list_header_id
,   p_param2			=> fnd_date.date_to_canonical(l_start_date_active)		--2739511
,   p_param3			=> fnd_date.date_to_canonical(l_end_date_active)		--2739511
,   p_param4			=> l_revision
,   x_return_status		=> l_return_status
);

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

	  oe_debug_pub.add('failed in logging a delayed request in delete_row ');

        RAISE FND_API.G_EXC_ERROR;

    END IF;

  oe_debug_pub.add('after logging delayed request ');

-- end bug2301959
END IF; -- END IF QP_GLOBALS.G_CHECK_DUP_PRICELIST_LINES <> 'N' -- 5018856,, 5024919

    oe_debug_pub.add('Logging a request to update qualification_ind  ', 1);
         qp_delayed_requests_PVT.log_request(
                 p_entity_code => QP_GLOBALS.G_ENTITY_Price_List_Line,
                 p_entity_id  => l_PRICING_ATTR_rec.list_line_id,
                 p_requesting_entity_code=> QP_GLOBALS.G_ENTITY_Price_List_Line,
                 p_requesting_entity_id => l_PRICING_ATTR_rec.list_line_id,
                 p_request_type =>QP_GLOBALS.G_UPDATE_LINE_QUAL_IND,
                 x_return_status => l_return_status);

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

          oe_debug_pub.add('failed in logging a delayed request in delete_row ');

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    QP_LIST_HEADERS_PVT.Process_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear PRICING_ATTR record cache

    Clear_PRICING_ATTR;

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
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
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_QUALIFIERS_rec            Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := QP_GLOBALS.G_ENTITY_PRICING_ATTR;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Call QP_LIST_HEADERS_PVT.Process_PRICE_LIST

    QP_LIST_HEADERS_PVT.Process_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
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
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_accumulate_flag               IN  VARCHAR2
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
,   p_attribute_grouping_no         IN  NUMBER
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_excluder_flag                 IN  VARCHAR2
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_list_line_id                  IN  NUMBER
,   p_pricing_attribute             IN  VARCHAR2
,   p_pricing_attribute_context     IN  VARCHAR2
,   p_pricing_attribute_id          IN  NUMBER
,   p_pricing_attr_value_from       IN  VARCHAR2
,   p_pricing_attr_value_to         IN  VARCHAR2
,   p_product_attribute             IN  VARCHAR2
,   p_product_attribute_context     IN  VARCHAR2
,   p_product_attr_value            IN  VARCHAR2
,   p_product_uom_code              IN  VARCHAR2
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_request_id                    IN  NUMBER
,   p_comparison_operator_code      IN VARCHAR2
,   p_pricing_attribute_datatype    IN VARCHAR2
,   p_product_attribute_datatype    IN VARCHAR2
)
IS
l_return_status               VARCHAR2(1);
l_PRICING_ATTR_rec            QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_PRICING_ATTR_tbl            QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_QUALIFIERS_rec            Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
BEGIN

    --  Load PRICING_ATTR record

    l_PRICING_ATTR_rec.accumulate_flag := p_accumulate_flag;
    l_PRICING_ATTR_rec.attribute1  := p_attribute1;
    l_PRICING_ATTR_rec.attribute10 := p_attribute10;
    l_PRICING_ATTR_rec.attribute11 := p_attribute11;
    l_PRICING_ATTR_rec.attribute12 := p_attribute12;
    l_PRICING_ATTR_rec.attribute13 := p_attribute13;
    l_PRICING_ATTR_rec.attribute14 := p_attribute14;
    l_PRICING_ATTR_rec.attribute15 := p_attribute15;
    l_PRICING_ATTR_rec.attribute2  := p_attribute2;
    l_PRICING_ATTR_rec.attribute3  := p_attribute3;
    l_PRICING_ATTR_rec.attribute4  := p_attribute4;
    l_PRICING_ATTR_rec.attribute5  := p_attribute5;
    l_PRICING_ATTR_rec.attribute6  := p_attribute6;
    l_PRICING_ATTR_rec.attribute7  := p_attribute7;
    l_PRICING_ATTR_rec.attribute8  := p_attribute8;
    l_PRICING_ATTR_rec.attribute9  := p_attribute9;
    l_PRICING_ATTR_rec.attribute_grouping_no := p_attribute_grouping_no;
    l_PRICING_ATTR_rec.context     := p_context;
    l_PRICING_ATTR_rec.created_by  := p_created_by;
    l_PRICING_ATTR_rec.creation_date := p_creation_date;
    l_PRICING_ATTR_rec.excluder_flag := p_excluder_flag;
    l_PRICING_ATTR_rec.last_updated_by := p_last_updated_by;
    l_PRICING_ATTR_rec.last_update_date := p_last_update_date;
    l_PRICING_ATTR_rec.last_update_login := p_last_update_login;
    l_PRICING_ATTR_rec.list_line_id := p_list_line_id;
    l_PRICING_ATTR_rec.pricing_attribute := p_pricing_attribute;
    l_PRICING_ATTR_rec.pricing_attribute_context := p_pricing_attribute_context;
    l_PRICING_ATTR_rec.pricing_attribute_id := p_pricing_attribute_id;
    l_PRICING_ATTR_rec.pricing_attr_value_from := p_pricing_attr_value_from;
    l_PRICING_ATTR_rec.pricing_attr_value_to := p_pricing_attr_value_to;
    l_PRICING_ATTR_rec.product_attribute := p_product_attribute;
    l_PRICING_ATTR_rec.product_attribute_context := p_product_attribute_context;
    l_PRICING_ATTR_rec.product_attr_value := p_product_attr_value;
    l_PRICING_ATTR_rec.product_uom_code := p_product_uom_code;
    l_PRICING_ATTR_rec.program_application_id := p_program_application_id;
    l_PRICING_ATTR_rec.program_id  := p_program_id;
    l_PRICING_ATTR_rec.program_update_date := p_program_update_date;
    l_PRICING_ATTR_rec.request_id  := p_request_id;
    l_PRICING_ATTR_rec.operation  := QP_GLOBALS.G_OPR_LOCK;
    l_PRICING_ATTR_rec.comparison_operator_code := p_comparison_operator_code;
 l_PRICING_ATTR_rec.pricing_attribute_datatype := p_pricing_attribute_datatype;
 l_PRICING_ATTR_rec.product_attribute_datatype := p_product_attribute_datatype;

    --  Populate PRICING_ATTR table

    l_PRICING_ATTR_tbl(1) := l_PRICING_ATTR_rec;

    --  Call QP_LIST_HEADERS_PVT.Lock_PRICE_LIST

    QP_LIST_HEADERS_PVT.Lock_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_PRICING_ATTR_rec.db_flag := FND_API.G_TRUE;

        Write_PRICING_ATTR
        (   p_PRICING_ATTR_rec            => l_x_PRICING_ATTR_rec
        ,   p_db_record                   => TRUE
        );

    END IF;

    --  Set return status.

    x_return_status := l_return_status;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

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

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );



END Lock_Row;

--  Procedures maintaining PRICING_ATTR record cache.

PROCEDURE Write_PRICING_ATTR
(   p_PRICING_ATTR_rec              IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
BEGIN

    g_PRICING_ATTR_rec := p_PRICING_ATTR_rec;

    IF p_db_record THEN

        g_db_PRICING_ATTR_rec := p_PRICING_ATTR_rec;

    END IF;

END Write_Pricing_Attr;

FUNCTION Get_PRICING_ATTR
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_pricing_attribute_id          IN  NUMBER
)
RETURN QP_Price_List_PUB.Pricing_Attr_Rec_Type
IS
BEGIN

    IF  p_pricing_attribute_id <> g_PRICING_ATTR_rec.pricing_attribute_id
    THEN

        --  Query row from DB

        g_PRICING_ATTR_rec := Qp_pll_pricing_attr_Util.Query_Row
        (   p_pricing_attribute_id        => p_pricing_attribute_id
        );

        g_PRICING_ATTR_rec.db_flag     := FND_API.G_TRUE;

        --  Load DB record

        g_db_PRICING_ATTR_rec          := g_PRICING_ATTR_rec;

    END IF;

    IF p_db_record THEN

        RETURN g_db_PRICING_ATTR_rec;

    ELSE

        RETURN g_PRICING_ATTR_rec;

    END IF;

END Get_Pricing_Attr;

PROCEDURE Clear_Pricing_Attr
IS
BEGIN

    g_PRICING_ATTR_rec             := QP_Price_List_PUB.G_MISS_PRICING_ATTR_REC;
    g_db_PRICING_ATTR_rec          := QP_Price_List_PUB.G_MISS_PRICING_ATTR_REC;

END Clear_Pricing_Attr;

-- This procedure will be called from the client when the user
-- clears a record

Procedure Clear_Record
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_pricing_attribute_id                  IN  NUMBER
)
IS
l_return_status                     Varchar2(30);
BEGIN
     OE_MSG_PUB.initialize;
 	x_return_status := FND_API.G_RET_STS_SUCCESS;
       QP_DELAYED_REQUESTS_PVT.Delete_Reqs_for_Deleted_Entity(
					p_entity_code  => QP_GLOBALS.G_ENTITY_PRICING_ATTR
					,p_entity_id    => p_pricing_attribute_id
				     ,x_return_status => l_return_status);

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

-- Clear the controller cache
	Clear_Pricing_Attr;

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
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_return_status                     Varchar2(30);
BEGIN
     OE_MSG_PUB.initialize;
 	x_return_status := FND_API.G_RET_STS_SUCCESS;
       QP_DELAYED_REQUESTS_PVT.Clear_Request(
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

Procedure Dup_record
(  p_x_old_list_line_id                   IN NUMBER,
   p_x_new_list_line_id                   IN NUMBER,
   x_msg_count                            OUT NOCOPY /* file.sql.39 change */ NUMBER,
   x_msg_data                             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_new_pricing_attribute_id    Number;
--added for related lines duplication
l_new_list_line_id            Number;
l_list_line_type_code         Varchar2(30);
l_PRICE_LIST_LINE_rec         QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_PRICE_LIST_LINE_tbl         QP_Price_List_PUB.Price_List_Line_Tbl_Type;
--added for related lines duplication
l_PRICING_ATTR_rec            QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_PRICING_ATTR_tbl            QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_x_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_x_PRICE_LIST_LINE_rec       QP_Price_List_PUB.Price_List_Line_Rec_Type;
l_x_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_x_QUALIFIERS_rec            Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               varchar2(1);
l_continuous_price_break_flag varchar2(1);


--added for related lines duplication

CURSOR l_LIST_LINE_csr(p_list_line_id Number) IS
 SELECT
   L.ACCRUAL_QTY
,L.ACCRUAL_UOM_CODE
,L.ARITHMETIC_OPERATOR
,L.ATTRIBUTE1
,L.ATTRIBUTE10
,L.ATTRIBUTE11
,L.ATTRIBUTE12
,L.ATTRIBUTE13
,L.ATTRIBUTE14
,L.ATTRIBUTE15
,L.ATTRIBUTE2
,L.ATTRIBUTE3
,L.ATTRIBUTE4
,L.ATTRIBUTE5
,L.ATTRIBUTE6
,L.ATTRIBUTE7
,L.ATTRIBUTE8
,L.ATTRIBUTE9
,L.AUTOMATIC_FLAG
,L.BASE_QTY
,L.BASE_UOM_CODE
,L.COMMENTS
,L.CONTEXT
,L.CREATED_BY
,L.CREATION_DATE
,L.EFFECTIVE_PERIOD_UOM
,L.END_DATE_ACTIVE
,L.ESTIM_ACCRUAL_RATE
,L.GENERATE_USING_FORMULA_ID
,L.INVENTORY_ITEM_ID
,L.LAST_UPDATED_BY
,L.LAST_UPDATE_DATE
,L.LAST_UPDATE_LOGIN
,L.LIST_HEADER_ID
,L.LIST_LINE_ID
,L.LIST_LINE_TYPE_CODE
,L.LIST_PRICE
,L.MODIFIER_LEVEL_CODE
,L.NUMBER_EFFECTIVE_PERIODS
,L.OPERAND
,L.ORGANIZATION_ID
,L.OVERRIDE_FLAG
,L.PERCENT_PRICE
,L.PRICE_BREAK_TYPE_CODE
,L.PRICE_BY_FORMULA_ID
,L.PRIMARY_UOM_FLAG
,L.PRINT_ON_INVOICE_FLAG
,L.PROGRAM_APPLICATION_ID
,L.PROGRAM_ID
,L.PROGRAM_UPDATE_DATE
,L.REBATE_TRANSACTION_TYPE_CODE
,L.RELATED_ITEM_ID
,L.RELATIONSHIP_TYPE_ID
,L.REPRICE_FLAG
,L.REQUEST_ID
,L.REVISION
,L.REVISION_DATE
,L.REVISION_REASON_CODE
,L.START_DATE_ACTIVE
,L.SUBSTITUTION_ATTRIBUTE
,L.SUBSTITUTION_CONTEXT
,L.SUBSTITUTION_VALUE
,RM.RLTD_MODIFIER_ID
,RM.FROM_RLTD_MODIFIER_ID
,RM.TO_RLTD_MODIFIER_ID
,RM.RLTD_MODIFIER_GRP_NO
,RM.RLTD_MODIFIER_GRP_TYPE
,L.PRODUCT_PRECEDENCE
,L.LIST_LINE_NO
,L.QUALIFICATION_IND
,L.RECURRING_VALUE
,L.CUSTOMER_ITEM_ID
,L.BREAK_UOM_CODE
,L.BREAK_UOM_CONTEXT
,L.BREAK_UOM_ATTRIBUTE
 FROM    QP_LIST_LINES L, QP_RLTD_MODIFIERS RM
 WHERE   L.LIST_LINE_ID  = RM.TO_RLTD_MODIFIER_ID
 AND     RM.FROM_RLTD_MODIFIER_ID = p_list_line_id;

--added for related lines duplication

CURSOR l_PRICING_ATTR_csr(p_list_line_id Number) IS
    SELECT  ACCUMULATE_FLAG
    ,       ATTRIBUTE1
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
    ,       ATTRIBUTE_GROUPING_NO
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       EXCLUDER_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_LINE_ID
    ,       LIST_HEADER_ID
    ,       PRICING_PHASE_ID
    ,       PRICING_ATTRIBUTE
    ,       PRICING_ATTRIBUTE_CONTEXT
    ,       PRICING_ATTRIBUTE_ID
    ,       PRICING_ATTR_VALUE_FROM
    ,       PRICING_ATTR_VALUE_TO
    ,       PRODUCT_ATTRIBUTE
    ,       PRODUCT_ATTRIBUTE_CONTEXT
    ,       PRODUCT_ATTR_VALUE
    ,       PRODUCT_UOM_CODE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       COMPARISON_OPERATOR_CODE
    ,       PRICING_ATTRIBUTE_DATATYPE
    ,       PRODUCT_ATTRIBUTE_DATATYPE
    ,       PRICING_ATTR_VALUE_FROM_NUMBER
    ,       PRICING_ATTR_VALUE_TO_NUMBER
    ,       QUALIFICATION_IND
    FROM    QP_PRICING_ATTRIBUTES
    WHERE     LIST_LINE_ID = p_list_line_id
              AND PRICING_ATTRIBUTE_CONTEXT IS NOT NULL;



--added for related lines duplication

CURSOR l_PRICING_ATTR_RLTD_csr(p_list_line_id Number) IS
SELECT  ACCUMULATE_FLAG
    ,       ATTRIBUTE1
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
    ,       ATTRIBUTE_GROUPING_NO
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       EXCLUDER_FLAG
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_LINE_ID
    ,       LIST_HEADER_ID
    ,       PRICING_PHASE_ID
    ,       PRICING_ATTRIBUTE
    ,       PRICING_ATTRIBUTE_CONTEXT
    ,       PRICING_ATTRIBUTE_ID
    ,       PRICING_ATTR_VALUE_FROM
    ,       PRICING_ATTR_VALUE_TO
    ,       PRODUCT_ATTRIBUTE
    ,       PRODUCT_ATTRIBUTE_CONTEXT
    ,       PRODUCT_ATTR_VALUE
    ,       PRODUCT_UOM_CODE
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REQUEST_ID
    ,       COMPARISON_OPERATOR_CODE
    ,       PRICING_ATTRIBUTE_DATATYPE
    ,       PRODUCT_ATTRIBUTE_DATATYPE
    ,       PRICING_ATTR_VALUE_FROM_NUMBER
    ,       PRICING_ATTR_VALUE_TO_NUMBER
    ,       QUALIFICATION_IND
    FROM    QP_PRICING_ATTRIBUTES
    WHERE   LIST_LINE_ID = p_list_line_id;


--added for related lines duplication

BEGIN
    FOR l_implicit_rec IN l_PRICING_ATTR_csr(p_x_old_list_line_id) LOOP

    SELECT qp_pricing_attributes_s.nextval INTO l_new_pricing_attribute_id
    FROM dual;

        l_PRICING_ATTR_rec.accumulate_flag := l_implicit_rec.ACCUMULATE_FLAG;
        l_PRICING_ATTR_rec.attribute1  := l_implicit_rec.ATTRIBUTE1;
        l_PRICING_ATTR_rec.attribute10 := l_implicit_rec.ATTRIBUTE10;
        l_PRICING_ATTR_rec.attribute11 := l_implicit_rec.ATTRIBUTE11;
        l_PRICING_ATTR_rec.attribute12 := l_implicit_rec.ATTRIBUTE12;
        l_PRICING_ATTR_rec.attribute13 := l_implicit_rec.ATTRIBUTE13;
        l_PRICING_ATTR_rec.attribute14 := l_implicit_rec.ATTRIBUTE14;
        l_PRICING_ATTR_rec.attribute15 := l_implicit_rec.ATTRIBUTE15;
        l_PRICING_ATTR_rec.attribute2  := l_implicit_rec.ATTRIBUTE2;
        l_PRICING_ATTR_rec.attribute3  := l_implicit_rec.ATTRIBUTE3;
        l_PRICING_ATTR_rec.attribute4  := l_implicit_rec.ATTRIBUTE4;
        l_PRICING_ATTR_rec.attribute5  := l_implicit_rec.ATTRIBUTE5;
        l_PRICING_ATTR_rec.attribute6  := l_implicit_rec.ATTRIBUTE6;
        l_PRICING_ATTR_rec.attribute7  := l_implicit_rec.ATTRIBUTE7;
        l_PRICING_ATTR_rec.attribute8  := l_implicit_rec.ATTRIBUTE8;
        l_PRICING_ATTR_rec.attribute9  := l_implicit_rec.ATTRIBUTE9;
        l_PRICING_ATTR_rec.attribute_grouping_no := l_implicit_rec.ATTRIBUTE_GROUPING_NO;
        l_PRICING_ATTR_rec.context     := l_implicit_rec.CONTEXT;
        l_PRICING_ATTR_rec.created_by  := l_implicit_rec.CREATED_BY;
        l_PRICING_ATTR_rec.creation_date := l_implicit_rec.CREATION_DATE;
        l_PRICING_ATTR_rec.excluder_flag := l_implicit_rec.EXCLUDER_FLAG;
        l_PRICING_ATTR_rec.last_updated_by := l_implicit_rec.LAST_UPDATED_BY;
        l_PRICING_ATTR_rec.last_update_date := l_implicit_rec.LAST_UPDATE_DATE;
        l_PRICING_ATTR_rec.last_update_login := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_PRICING_ATTR_rec.list_line_id := p_x_new_list_line_id;
        l_PRICING_ATTR_rec.list_header_id := l_implicit_rec.LIST_HEADER_ID;
        l_PRICING_ATTR_rec.pricing_phase_id := l_implicit_rec.PRICING_PHASE_ID;
        l_PRICING_ATTR_rec.pricing_attribute := l_implicit_rec.PRICING_ATTRIBUTE;
        l_PRICING_ATTR_rec.pricing_attribute_context := l_implicit_rec.PRICING_ATTRIBUTE_CONTEXT;
        l_PRICING_ATTR_rec.pricing_attribute_id := l_new_pricing_attribute_id;
        l_PRICING_ATTR_rec.pricing_attr_value_from := l_implicit_rec.PRICING_ATTR_VALUE_FROM;
        l_PRICING_ATTR_rec.pricing_attr_value_to := l_implicit_rec.PRICING_ATTR_VALUE_TO;
        l_PRICING_ATTR_rec.product_attribute := l_implicit_rec.PRODUCT_ATTRIBUTE;
        l_PRICING_ATTR_rec.product_attribute_context := l_implicit_rec.PRODUCT_ATTRIBUTE_CONTEXT;
        l_PRICING_ATTR_rec.product_attr_value := l_implicit_rec.PRODUCT_ATTR_VALUE;
        l_PRICING_ATTR_rec.product_uom_code := l_implicit_rec.PRODUCT_UOM_CODE;
        l_PRICING_ATTR_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_PRICING_ATTR_rec.program_id  := l_implicit_rec.PROGRAM_ID;
        l_PRICING_ATTR_rec.program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_PRICING_ATTR_rec.request_id  := l_implicit_rec.REQUEST_ID;
	l_PRICING_ATTR_rec.comparison_operator_code := l_implicit_rec.comparison_operator_code;
	l_PRICING_ATTR_rec.pricing_attribute_datatype := l_implicit_rec.pricing_attribute_datatype;
	l_PRICING_ATTR_rec.product_attribute_datatype := l_implicit_rec.product_attribute_datatype;
	l_PRICING_ATTR_rec.pricing_attr_value_from_number := l_implicit_rec.PRICING_ATTR_VALUE_FROM_NUMBER;
	l_PRICING_ATTR_rec.pricing_attr_value_to_number := l_implicit_rec.PRICING_ATTR_VALUE_TO_NUMBER;
	l_PRICING_ATTR_rec.qualification_ind := l_implicit_rec.QUALIFICATION_IND;
        l_PRICING_ATTR_rec.operation := QP_GLOBALS.G_OPR_CREATE;

        l_PRICING_ATTR_tbl(l_PRICING_ATTR_tbl.COUNT + 1) := l_PRICING_ATTR_rec;

    END LOOP;

--added for related lines duplication

SELECT list_line_type_code into l_list_line_type_code from QP_LIST_LINES where list_line_id=p_x_old_list_line_id;
  If l_list_line_type_code IN ('PBH') Then

--Storing continuous_price_break_flag value for later use,to convert non continuous price break lines into continuous line.

        SELECT continuous_price_break_flag INTO l_continuous_price_break_flag
        FROM QP_LIST_LINES
        WHERE list_line_id=p_x_old_list_line_id;
      FOR l_implicit_rec IN l_LIST_LINE_csr(p_x_old_list_line_id) LOOP


        SELECT qp_List_lines_s.nextval INTO l_new_list_line_id
        FROM dual;



l_PRICE_LIST_LINE_rec.accrual_qty                      := l_implicit_rec.ACCRUAL_QTY;
l_PRICE_LIST_LINE_rec.accrual_uom_code                 := l_implicit_rec.ACCRUAL_UOM_CODE;
l_PRICE_LIST_LINE_rec.arithmetic_operator              := l_implicit_rec.ARITHMETIC_OPERATOR;
l_PRICE_LIST_LINE_rec.attribute1                       := l_implicit_rec.ATTRIBUTE1;
l_PRICE_LIST_LINE_rec.attribute10                      := l_implicit_rec.ATTRIBUTE10;
l_PRICE_LIST_LINE_rec.attribute11                      := l_implicit_rec.ATTRIBUTE11;
l_PRICE_LIST_LINE_rec.attribute12                      := l_implicit_rec.ATTRIBUTE12;
l_PRICE_LIST_LINE_rec.attribute13                      := l_implicit_rec.ATTRIBUTE13;
l_PRICE_LIST_LINE_rec.attribute14                      := l_implicit_rec.ATTRIBUTE14;
l_PRICE_LIST_LINE_rec.attribute15                      := l_implicit_rec.ATTRIBUTE15;
l_PRICE_LIST_LINE_rec.attribute2                       := l_implicit_rec.ATTRIBUTE2;
l_PRICE_LIST_LINE_rec.attribute3                       := l_implicit_rec.ATTRIBUTE3;
l_PRICE_LIST_LINE_rec.attribute4                       := l_implicit_rec.ATTRIBUTE4;
l_PRICE_LIST_LINE_rec.attribute5                       := l_implicit_rec.ATTRIBUTE5;
l_PRICE_LIST_LINE_rec.attribute6                       := l_implicit_rec.ATTRIBUTE6;
l_PRICE_LIST_LINE_rec.attribute7                       := l_implicit_rec.ATTRIBUTE7;
l_PRICE_LIST_LINE_rec.attribute8                       := l_implicit_rec.ATTRIBUTE8;
l_PRICE_LIST_LINE_rec.attribute9                       := l_implicit_rec.ATTRIBUTE9;
l_PRICE_LIST_LINE_rec.automatic_flag                   := l_implicit_rec.AUTOMATIC_FLAG;
l_PRICE_LIST_LINE_rec.base_qty                         := l_implicit_rec.BASE_QTY;
l_PRICE_LIST_LINE_rec.base_uom_code                    := l_implicit_rec.BASE_UOM_CODE;
l_PRICE_LIST_LINE_rec.comments                         := l_implicit_rec.COMMENTS;
l_PRICE_LIST_LINE_rec.context                          := l_implicit_rec.CONTEXT;
l_PRICE_LIST_LINE_rec.created_by                       := l_implicit_rec.CREATED_BY;
l_PRICE_LIST_LINE_rec.creation_date                    := l_implicit_rec.CREATION_DATE;
l_PRICE_LIST_LINE_rec.effective_period_uom             := l_implicit_rec.EFFECTIVE_PERIOD_UOM;
l_PRICE_LIST_LINE_rec.end_date_active                  := l_implicit_rec.END_DATE_ACTIVE;
l_PRICE_LIST_LINE_rec.estim_accrual_rate               := l_implicit_rec.ESTIM_ACCRUAL_RATE;
l_PRICE_LIST_LINE_rec.generate_using_formula_id        := l_implicit_rec.GENERATE_USING_FORMULA_ID;
l_PRICE_LIST_LINE_rec.inventory_item_id                := l_implicit_rec.INVENTORY_ITEM_ID;
l_PRICE_LIST_LINE_rec.last_updated_by                  := l_implicit_rec.LAST_UPDATED_BY;
l_PRICE_LIST_LINE_rec.last_update_date                 := l_implicit_rec.LAST_UPDATE_DATE;
l_PRICE_LIST_LINE_rec.last_update_login                := l_implicit_rec.LAST_UPDATE_LOGIN;
l_PRICE_LIST_LINE_rec.list_header_id                   := l_implicit_rec.LIST_HEADER_ID;
l_PRICE_LIST_LINE_rec.list_line_id                     := l_new_list_line_id;
l_PRICE_LIST_LINE_rec.list_line_type_code              := l_implicit_rec.LIST_LINE_TYPE_CODE;
l_PRICE_LIST_LINE_rec.list_price                       := l_implicit_rec.LIST_PRICE;
l_PRICE_LIST_LINE_rec.modifier_level_code              := l_implicit_rec.MODIFIER_LEVEL_CODE;
l_PRICE_LIST_LINE_rec.number_effective_periods         := l_implicit_rec.NUMBER_EFFECTIVE_PERIODS;
l_PRICE_LIST_LINE_rec.operand                          := l_implicit_rec.OPERAND;
l_PRICE_LIST_LINE_rec.organization_id                  := l_implicit_rec.ORGANIZATION_ID;
l_PRICE_LIST_LINE_rec.override_flag                    := l_implicit_rec.OVERRIDE_FLAG;
l_PRICE_LIST_LINE_rec.percent_price                    := l_implicit_rec.PERCENT_PRICE;
l_PRICE_LIST_LINE_rec.price_break_type_code            := l_implicit_rec.PRICE_BREAK_TYPE_CODE;
l_PRICE_LIST_LINE_rec.price_by_formula_id              := l_implicit_rec.PRICE_BY_FORMULA_ID;
l_PRICE_LIST_LINE_rec.primary_uom_flag                 := l_implicit_rec.PRIMARY_UOM_FLAG;
l_PRICE_LIST_LINE_rec.print_on_invoice_flag            := l_implicit_rec.PRINT_ON_INVOICE_FLAG;
l_PRICE_LIST_LINE_rec.program_application_id           := l_implicit_rec.PROGRAM_APPLICATION_ID;
l_PRICE_LIST_LINE_rec.program_id                       := l_implicit_rec.PROGRAM_ID;
l_PRICE_LIST_LINE_rec.program_update_date              := l_implicit_rec.PROGRAM_UPDATE_DATE;
l_PRICE_LIST_LINE_rec.rebate_trxn_type_code            := l_implicit_rec.REBATE_TRANSACTION_TYPE_CODE;
l_PRICE_LIST_LINE_rec.related_item_id                  := l_implicit_rec.RELATED_ITEM_ID;
l_PRICE_LIST_LINE_rec.relationship_type_id             := l_implicit_rec.RELATIONSHIP_TYPE_ID;
l_PRICE_LIST_LINE_rec.reprice_flag                     := l_implicit_rec.REPRICE_FLAG;
l_PRICE_LIST_LINE_rec.request_id                       := l_implicit_rec.REQUEST_ID;
l_PRICE_LIST_LINE_rec.revision                         := l_implicit_rec.REVISION;
l_PRICE_LIST_LINE_rec.revision_date                    := l_implicit_rec.REVISION_DATE;
l_PRICE_LIST_LINE_rec.revision_reason_code             := l_implicit_rec.REVISION_REASON_CODE;
l_PRICE_LIST_LINE_rec.start_date_active                := l_implicit_rec.START_DATE_ACTIVE;
l_PRICE_LIST_LINE_rec.substitution_attribute           := l_implicit_rec.SUBSTITUTION_ATTRIBUTE;
l_PRICE_LIST_LINE_rec.substitution_context             := l_implicit_rec.SUBSTITUTION_CONTEXT;
l_PRICE_LIST_LINE_rec.substitution_value               := l_implicit_rec.SUBSTITUTION_VALUE;
l_PRICE_LIST_LINE_rec.from_rltd_modifier_id            := p_x_new_list_line_id;
l_PRICE_LIST_LINE_rec.to_rltd_modifier_id              := l_new_list_line_id;
l_PRICE_LIST_LINE_rec.rltd_modifier_group_no           := l_implicit_rec.RLTD_MODIFIER_GRP_NO;
l_PRICE_LIST_LINE_rec.rltd_modifier_grp_type           := l_implicit_rec.RLTD_MODIFIER_GRP_TYPE;
l_PRICE_LIST_LINE_rec.product_precedence               := l_implicit_rec.PRODUCT_PRECEDENCE;
l_PRICE_LIST_LINE_rec.list_line_no                     := l_new_list_line_id;
l_PRICE_LIST_LINE_rec.qualification_ind                := l_implicit_rec.QUALIFICATION_IND;
l_PRICE_LIST_LINE_rec.recurring_value                  := l_implicit_rec.RECURRING_VALUE;
l_PRICE_LIST_LINE_rec.customer_item_id                 := l_implicit_rec.CUSTOMER_ITEM_ID;
l_PRICE_LIST_LINE_rec.break_uom_code                   := l_implicit_rec.BREAK_UOM_CODE;
l_PRICE_LIST_LINE_rec.break_uom_context                := l_implicit_rec.BREAK_UOM_CONTEXT;
l_PRICE_LIST_LINE_rec.break_uom_attribute              := l_implicit_rec.BREAK_UOM_ATTRIBUTE;
l_PRICE_LIST_LINE_rec.db_flag 		               := FND_API.G_TRUE;
l_PRICE_LIST_LINE_rec.operation 	               := QP_GLOBALS.G_OPR_CREATE;


    l_PRICE_LIST_LINE_tbl(l_PRICE_LIST_LINE_tbl.COUNT + 1) := l_PRICE_LIST_LINE_rec;


--	Related Lines Pricing Attributes Duplication

 FOR l_implicit_attr_rec IN l_PRICING_ATTR_rltd_csr(l_implicit_rec.list_line_id) LOOP

   SELECT qp_pricing_attributes_s.nextval INTO l_new_pricing_attribute_id FROM dual;

	        l_PRICING_ATTR_rec.accumulate_flag 		:= l_implicit_attr_rec.ACCUMULATE_FLAG;
        	l_PRICING_ATTR_rec.attribute1      		:= l_implicit_attr_rec.ATTRIBUTE1;
	        l_PRICING_ATTR_rec.attribute10 			:= l_implicit_attr_rec.ATTRIBUTE10;
	        l_PRICING_ATTR_rec.attribute11 			:= l_implicit_attr_rec.ATTRIBUTE11;
        	l_PRICING_ATTR_rec.attribute12 			:= l_implicit_attr_rec.ATTRIBUTE12;
	        l_PRICING_ATTR_rec.attribute13 			:= l_implicit_attr_rec.ATTRIBUTE13;
        	l_PRICING_ATTR_rec.attribute14 			:= l_implicit_attr_rec.ATTRIBUTE14;
        	l_PRICING_ATTR_rec.attribute15 			:= l_implicit_attr_rec.ATTRIBUTE15;
	        l_PRICING_ATTR_rec.attribute2  			:= l_implicit_attr_rec.ATTRIBUTE2;
	        l_PRICING_ATTR_rec.attribute3  			:= l_implicit_attr_rec.ATTRIBUTE3;
        	l_PRICING_ATTR_rec.attribute4  			:= l_implicit_attr_rec.ATTRIBUTE4;
	        l_PRICING_ATTR_rec.attribute5  			:= l_implicit_attr_rec.ATTRIBUTE5;
	        l_PRICING_ATTR_rec.attribute6  			:= l_implicit_attr_rec.ATTRIBUTE6;
	        l_PRICING_ATTR_rec.attribute7  			:= l_implicit_attr_rec.ATTRIBUTE7;
	        l_PRICING_ATTR_rec.attribute8  			:= l_implicit_attr_rec.ATTRIBUTE8;
        	l_PRICING_ATTR_rec.attribute9  			:= l_implicit_attr_rec.ATTRIBUTE9;
        	l_PRICING_ATTR_rec.attribute_grouping_no 	:= l_implicit_attr_rec.ATTRIBUTE_GROUPING_NO;
	        l_PRICING_ATTR_rec.context     			:= l_implicit_attr_rec.CONTEXT;
        	l_PRICING_ATTR_rec.created_by  			:= l_implicit_attr_rec.CREATED_BY;
	        l_PRICING_ATTR_rec.creation_date 		:= l_implicit_attr_rec.CREATION_DATE;
        	l_PRICING_ATTR_rec.excluder_flag 		:= l_implicit_attr_rec.EXCLUDER_FLAG;
	        l_PRICING_ATTR_rec.last_updated_by 		:= l_implicit_attr_rec.LAST_UPDATED_BY;
	        l_PRICING_ATTR_rec.last_update_date 		:= l_implicit_attr_rec.LAST_UPDATE_DATE;
	        l_PRICING_ATTR_rec.last_update_login 		:= l_implicit_attr_rec.LAST_UPDATE_LOGIN;
	        l_PRICING_ATTR_rec.list_line_id 		:= l_new_list_line_id;
	        l_PRICING_ATTR_rec.list_header_id 		:= l_implicit_attr_rec.LIST_HEADER_ID;
        	l_PRICING_ATTR_rec.pricing_phase_id 		:= l_implicit_attr_rec.PRICING_PHASE_ID;
	        l_PRICING_ATTR_rec.pricing_attribute 		:= l_implicit_attr_rec.PRICING_ATTRIBUTE;
        	l_PRICING_ATTR_rec.pricing_attribute_context 	:= l_implicit_attr_rec.PRICING_ATTRIBUTE_CONTEXT;
	        l_PRICING_ATTR_rec.pricing_attribute_id 	:= l_new_pricing_attribute_id;
        	l_PRICING_ATTR_rec.pricing_attr_value_from 	:= l_implicit_attr_rec.PRICING_ATTR_VALUE_FROM;
	        l_PRICING_ATTR_rec.pricing_attr_value_to 	:= l_implicit_attr_rec.PRICING_ATTR_VALUE_TO;
	        l_PRICING_ATTR_rec.product_attribute 		:= l_implicit_attr_rec.PRODUCT_ATTRIBUTE;
	        l_PRICING_ATTR_rec.product_attribute_context 	:= l_implicit_attr_rec.PRODUCT_ATTRIBUTE_CONTEXT;
	        l_PRICING_ATTR_rec.product_attr_value 		:= l_implicit_attr_rec.PRODUCT_ATTR_VALUE;
	        l_PRICING_ATTR_rec.product_uom_code 		:= l_implicit_attr_rec.PRODUCT_UOM_CODE;
        	l_PRICING_ATTR_rec.program_application_id 	:= l_implicit_attr_rec.PROGRAM_APPLICATION_ID;
	        l_PRICING_ATTR_rec.program_id  			:= l_implicit_attr_rec.PROGRAM_ID;
	        l_PRICING_ATTR_rec.program_update_date 		:= l_implicit_attr_rec.PROGRAM_UPDATE_DATE;
	        l_PRICING_ATTR_rec.request_id  			:= l_implicit_attr_rec.REQUEST_ID;
	        l_PRICING_ATTR_rec.comparison_operator_code 	:= l_implicit_attr_rec.comparison_operator_code;
        	l_PRICING_ATTR_rec.pricing_attribute_datatype 	:= l_implicit_attr_rec.pricing_attribute_datatype;
	        l_PRICING_ATTR_rec.product_attribute_datatype 	:= l_implicit_attr_rec.product_attribute_datatype;
        	l_PRICING_ATTR_rec.pricing_attr_value_from_number := l_implicit_attr_rec.PRICING_ATTR_VALUE_FROM_NUMBER;
	        l_PRICING_ATTR_rec.pricing_attr_value_to_number := l_implicit_attr_rec.PRICING_ATTR_VALUE_TO_NUMBER;
	        l_PRICING_ATTR_rec.qualification_ind 		:= l_implicit_attr_rec.QUALIFICATION_IND;
        	l_PRICING_ATTR_rec.operation 			:= QP_GLOBALS.G_OPR_CREATE;

        	l_PRICING_ATTR_tbl(l_PRICING_ATTR_tbl.COUNT + 1) := l_PRICING_ATTR_rec;

         END LOOP;
      END LOOP;
    END IF;

 IF ((l_PRICE_LIST_LINE_tbl.COUNT    <> 0) OR
        (l_PRICING_ATTR_tbl.COUNT <> 0))

 -- added for related lines duplication

    THEN
    l_control_rec.controlled_operation := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.validate_entity      := FALSE;
    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;


    QP_LIST_HEADERS_PVT.Process_PRICE_LIST
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl   /* added for related lines duplication*/
    ,   p_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    ,   x_PRICE_LIST_rec              => l_x_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_x_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

-- Upgrade Non Continuous Price Break Lines into Continuous Price Break Lines.
IF (l_continuous_price_break_flag<>'Y' OR  l_continuous_price_break_flag IS NULL )and l_list_line_type_code='PBH' THEN
qp_delayed_requests_PVT.log_request
      (  p_entity_code            => QP_GLOBALS.G_ENTITY_PRICING_ATTR
       , p_entity_id              =>p_x_new_list_line_id
       , p_requesting_entity_code => QP_GLOBALS.G_ENTITY_PRICING_ATTR
       , p_requesting_entity_id   => p_x_new_list_line_id
       , p_request_type           => QP_Globals.G_UPGRADE_PRICE_BREAKS
       , p_param1                 => null
       , p_param2                 => null
       , p_param3                 => null
       , x_return_status          => l_return_status);


     QP_DELAYED_REQUESTS_PVT.Process_Request_for_Entity
      (  p_entity_code            => QP_GLOBALS.G_ENTITY_PRICING_ATTR
       , x_return_status          => l_return_status);
END IF;
     oe_debug_pub.add('QPXFPLAB - l_return_status = ' || l_return_status);
      	 IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        	 RAISE FND_API.G_EXC_ERROR;
	 END IF;
    END IF;

    -- Added following 3 lines to avoid NullPointerException when called from Mass Maintenance
    if x_msg_count is null then
       x_msg_count := 0;
    end if;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

   --        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    --    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

     --   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Write to DB'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Dup_record;

END QP_QP_Form_pll_pricing_attr;

/
