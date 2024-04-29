--------------------------------------------------------
--  DDL for Package Body QP_QP_FORM_PRICING_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_QP_FORM_PRICING_ATTR" AS
/* $Header: QPXFPRAB.pls 120.5 2008/06/10 10:25:54 kdurgasi ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_QP_Form_Pricing_Attr';

--  Global variables holding cached record.

g_PRICING_ATTR_rec            QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
g_db_PRICING_ATTR_rec         QP_Modifiers_PUB.Pricing_Attr_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_PRICING_ATTR
(   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

FUNCTION Get_PRICING_ATTR
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_pricing_attribute_id          IN  NUMBER
)
RETURN QP_Modifiers_PUB.Pricing_Attr_Rec_Type;

PROCEDURE Clear_PRICING_ATTR;

--  Global variable holding performed operations.

g_opr__tbl                    QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   p_list_line_id                  IN  NUMBER
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
,   x_product_attribute_datatype    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute_datatype    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_comparison_operator_code      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_PRICING_ATTR_rec            QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_PRICING_ATTR_val_rec        QP_Modifiers_PUB.Pricing_Attr_Val_Rec_Type;
l_PRICING_ATTR_tbl            QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_MODIFIER_LIST_rec         QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_x_MODIFIERS_rec             QP_Modifiers_PUB.Modifiers_Rec_Type;
l_x_MODIFIERS_tbl             QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_x_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
BEGIN

oe_debug_pub.add('BEGIN Default_Attributes in QPXFPRAB');

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

    l_PRICING_ATTR_rec.list_line_id              := p_list_line_id;


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

oe_debug_pub.add(to_char(l_PRICING_ATTR_rec.attribute_grouping_no)||'attr_grp_no QPXFPRAB');
    l_PRICING_ATTR_tbl(1) := l_PRICING_ATTR_rec;

    --  Call QP_Modifiers_PVT.Process_MODIFIERS

    QP_Modifiers_PVT.Process_MODIFIERS
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    ,   x_MODIFIER_LIST_rec           => l_x_MODIFIER_LIST_rec
    ,   x_MODIFIERS_tbl               => l_x_MODIFIERS_tbl
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
    x_product_attribute_datatype   := l_x_PRICING_ATTR_rec.product_attribute_datatype;
    x_pricing_attribute_datatype   := l_x_PRICING_ATTR_rec.pricing_attribute_datatype;
    x_comparison_operator_code     := l_x_PRICING_ATTR_rec.comparison_operator_code;

    --  Load display out parameters if any

    l_PRICING_ATTR_val_rec := QP_Pricing_Attr_Util.Get_Values
    (   p_PRICING_ATTR_rec            => l_x_PRICING_ATTR_rec
    );
    x_accumulate                   := l_PRICING_ATTR_val_rec.accumulate;
    x_excluder                     := l_PRICING_ATTR_val_rec.excluder;
    x_list_line                    := l_PRICING_ATTR_val_rec.list_line;
    x_product_uom                  := l_PRICING_ATTR_val_rec.product_uom;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_PRICING_ATTR_rec.db_flag := FND_API.G_FALSE;

    Write_PRICING_ATTR
    (   p_PRICING_ATTR_rec            => l_x_PRICING_ATTR_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


oe_debug_pub.add('END Default_Attributes in QPXFPRAB');

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
,   x_product_attribute_datatype    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute_datatype    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_comparison_operator_code      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_PRICING_ATTR_rec            QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_old_PRICING_ATTR_rec        QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_PRICING_ATTR_val_rec        QP_Modifiers_PUB.Pricing_Attr_Val_Rec_Type;
l_PRICING_ATTR_tbl            QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
l_old_PRICING_ATTR_tbl        QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_MODIFIER_LIST_rec         QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_x_MODIFIERS_rec             QP_Modifiers_PUB.Modifiers_Rec_Type;
l_x_MODIFIERS_tbl             QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_x_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
BEGIN

oe_debug_pub.add('BEGIN Change_Attribute in QPXFPRAB');

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
    OE_Debug_PUB.add('here');

    l_PRICING_ATTR_rec := Get_PRICING_ATTR
    (   p_db_record                   => FALSE
    ,   p_pricing_attribute_id        => p_pricing_attribute_id
    );

    OE_Debug_PUB.add('here1');
    l_old_PRICING_ATTR_rec         := l_PRICING_ATTR_rec;

    IF p_attr_id = QP_Pricing_Attr_Util.G_ACCUMULATE THEN
        l_PRICING_ATTR_rec.accumulate_flag := p_attr_value;
    ELSIF p_attr_id = QP_Pricing_Attr_Util.G_ATTRIBUTE_GROUPING_NO THEN
        l_PRICING_ATTR_rec.attribute_grouping_no := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Pricing_Attr_Util.G_EXCLUDER THEN
        l_PRICING_ATTR_rec.excluder_flag := p_attr_value;
    OE_Debug_PUB.add(p_attr_value||'exclude here1');
    ELSIF p_attr_id = QP_Pricing_Attr_Util.G_LIST_LINE THEN
        l_PRICING_ATTR_rec.list_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Pricing_Attr_Util.G_PRICING_ATTRIBUTE THEN
    OE_Debug_PUB.add(p_attr_id||'attr_value'||QP_Pricing_attr_Util.G_PRICING_ATTRIBUTE);
        l_PRICING_ATTR_rec.pricing_attribute := p_attr_value;
    ELSIF p_attr_id = QP_Pricing_Attr_Util.G_PRICING_ATTRIBUTE_CONTEXT THEN
        l_PRICING_ATTR_rec.pricing_attribute_context := p_attr_value;
    ELSIF p_attr_id = QP_Pricing_Attr_Util.G_PRICING_ATTRIBUTE THEN
        l_PRICING_ATTR_rec.pricing_attribute_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Pricing_Attr_Util.G_PRICING_ATTR_VALUE_FROM THEN
        l_PRICING_ATTR_rec.pricing_attr_value_from := p_attr_value;
    ELSIF p_attr_id = QP_Pricing_Attr_Util.G_PRICING_ATTR_VALUE_TO THEN
        l_PRICING_ATTR_rec.pricing_attr_value_to := p_attr_value;
    ELSIF p_attr_id = QP_Pricing_Attr_Util.G_PRODUCT_ATTRIBUTE THEN
        l_PRICING_ATTR_rec.product_attribute := p_attr_value;
    ELSIF p_attr_id = QP_Pricing_Attr_Util.G_PRODUCT_ATTRIBUTE_CONTEXT THEN
        l_PRICING_ATTR_rec.product_attribute_context := p_attr_value;
    ELSIF p_attr_id = QP_Pricing_Attr_Util.G_PRODUCT_ATTR_VALUE THEN
        l_PRICING_ATTR_rec.product_attr_value := p_attr_value;
    ELSIF p_attr_id = QP_Pricing_Attr_Util.G_PRODUCT_UOM THEN
        l_PRICING_ATTR_rec.product_uom_code := p_attr_value;
    ELSIF p_attr_id = QP_Pricing_Attr_Util.G_PRODUCT_ATTRIBUTE_DATATYPE THEN
        l_PRICING_ATTR_rec.product_attribute_datatype := p_attr_value;
    ELSIF p_attr_id = QP_Pricing_Attr_Util.G_PRICING_ATTRIBUTE_DATATYPE THEN
        l_PRICING_ATTR_rec.pricing_attribute_datatype := p_attr_value;
    ELSIF p_attr_id = QP_Pricing_Attr_Util.G_COMPARISON_OPERATOR THEN
        l_PRICING_ATTR_rec.comparison_operator_code := p_attr_value;
    ELSIF p_attr_id = QP_Pricing_Attr_Util.G_ATTRIBUTE1
    OR     p_attr_id = QP_Pricing_Attr_Util.G_ATTRIBUTE10
    OR     p_attr_id = QP_Pricing_Attr_Util.G_ATTRIBUTE11
    OR     p_attr_id = QP_Pricing_Attr_Util.G_ATTRIBUTE12
    OR     p_attr_id = QP_Pricing_Attr_Util.G_ATTRIBUTE13
    OR     p_attr_id = QP_Pricing_Attr_Util.G_ATTRIBUTE14
    OR     p_attr_id = QP_Pricing_Attr_Util.G_ATTRIBUTE15
    OR     p_attr_id = QP_Pricing_Attr_Util.G_ATTRIBUTE2
    OR     p_attr_id = QP_Pricing_Attr_Util.G_ATTRIBUTE3
    OR     p_attr_id = QP_Pricing_Attr_Util.G_ATTRIBUTE4
    OR     p_attr_id = QP_Pricing_Attr_Util.G_ATTRIBUTE5
    OR     p_attr_id = QP_Pricing_Attr_Util.G_ATTRIBUTE6
    OR     p_attr_id = QP_Pricing_Attr_Util.G_ATTRIBUTE7
    OR     p_attr_id = QP_Pricing_Attr_Util.G_ATTRIBUTE8
    OR     p_attr_id = QP_Pricing_Attr_Util.G_ATTRIBUTE9
    OR     p_attr_id = QP_Pricing_Attr_Util.G_CONTEXT
    THEN

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
        l_PRICING_ATTR_rec.context     := p_context;

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

    OE_Debug_PUB.add('operation');
    --  Set Operation.

    IF FND_API.To_Boolean(l_PRICING_ATTR_rec.db_flag) THEN
        l_PRICING_ATTR_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_PRICING_ATTR_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate PRICING_ATTR table

    l_PRICING_ATTR_tbl(1) := l_PRICING_ATTR_rec;
    l_old_PRICING_ATTR_tbl(1) := l_old_PRICING_ATTR_rec;

    --  Call QP_Modifiers_PVT.Process_MODIFIERS

    OE_Debug_PUB.add('process mod');
    QP_Modifiers_PVT.Process_MODIFIERS
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    ,   p_old_PRICING_ATTR_tbl        => l_old_PRICING_ATTR_tbl
    ,   x_MODIFIER_LIST_rec           => l_x_MODIFIER_LIST_rec
    ,   x_MODIFIERS_tbl               => l_x_MODIFIERS_tbl
    ,   x_QUALIFIERS_tbl              => l_x_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_x_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    OE_Debug_PUB.add('after process mod');
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
    x_product_attribute_datatype   := FND_API.G_MISS_CHAR;
    x_pricing_attribute_datatype   := FND_API.G_MISS_CHAR;
    x_comparison_operator_code     := FND_API.G_MISS_CHAR;

    --  Load display out parameters if any

    l_PRICING_ATTR_val_rec := QP_Pricing_Attr_Util.Get_Values
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

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.product_attribute_datatype,
                            l_PRICING_ATTR_rec.product_attribute_datatype)
    THEN
        x_product_attribute_datatype := l_x_PRICING_ATTR_rec.product_attribute_datatype;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.pricing_attribute_datatype,
                            l_PRICING_ATTR_rec.pricing_attribute_datatype)
    THEN
        x_pricing_attribute_datatype := l_x_PRICING_ATTR_rec.pricing_attribute_datatype;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PRICING_ATTR_rec.comparison_operator_code,
                            l_PRICING_ATTR_rec.comparison_operator_code)
    THEN
        x_comparison_operator_code := l_x_PRICING_ATTR_rec.comparison_operator_code;
    END IF;


    --  Write to cache.

    Write_PRICING_ATTR
    (   p_PRICING_ATTR_rec            => l_x_PRICING_ATTR_rec
    );

    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

oe_debug_pub.add('END Change_Attribute in QPXFPRAB');

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
,   p_pricing_attribute_id          IN  NUMBER
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_created_by                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_date              OUT NOCOPY /* file.sql.39 change */ DATE
,   x_last_updated_by               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_login             OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_PRICING_ATTR_rec            QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_old_PRICING_ATTR_rec        QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_PRICING_ATTR_tbl            QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
l_old_PRICING_ATTR_tbl        QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_MODIFIER_LIST_rec         QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_x_MODIFIERS_rec             QP_Modifiers_PUB.Modifiers_Rec_Type;
l_x_MODIFIERS_tbl             QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_x_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
BEGIN

oe_debug_pub.add('BEGIN Validate_And_Write in QPXFPRAB');

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

    --  Call QP_Modifiers_PVT.Process_MODIFIERS

    QP_Modifiers_PVT.Process_MODIFIERS
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    ,   p_old_PRICING_ATTR_tbl        => l_old_PRICING_ATTR_tbl
    ,   x_MODIFIER_LIST_rec           => l_x_MODIFIER_LIST_rec
    ,   x_MODIFIERS_tbl               => l_x_MODIFIERS_tbl
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

    --  Clear PRICING_ATTR record cache

    Clear_PRICING_ATTR;

    --  Keep track of performed operations.

    l_old_PRICING_ATTR_rec.operation := l_PRICING_ATTR_rec.operation;


    --  Set return status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

oe_debug_pub.add('END Validate_And_Write in QPXFPRAB');

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
,   p_pricing_attribute_id          IN  NUMBER
)
IS
l_PRICING_ATTR_rec            QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_PRICING_ATTR_tbl            QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_MODIFIER_LIST_rec         QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_x_MODIFIERS_rec             QP_Modifiers_PUB.Modifiers_Rec_Type;
l_x_MODIFIERS_tbl             QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_x_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
BEGIN

oe_debug_pub.add('BEGIN Delete_Row in QPXFPRAB');

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.process              := FALSE;  -- Changed back to false. Regression bug of 5261328

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

    --  Call QP_Modifiers_PVT.Process_MODIFIERS
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


    QP_Modifiers_PVT.Process_MODIFIERS
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    ,   x_MODIFIER_LIST_rec           => l_x_MODIFIER_LIST_rec
    ,   x_MODIFIERS_tbl               => l_x_MODIFIERS_tbl
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

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

oe_debug_pub.add('END Delete_Row in QPXFPRAB');

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
l_x_MODIFIER_LIST_rec         QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_x_MODIFIERS_rec             QP_Modifiers_PUB.Modifiers_Rec_Type;
l_x_MODIFIERS_tbl             QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_x_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
BEGIN

oe_debug_pub.add('BEGIN Process_Entity in QPXFPRAB');

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

    --  Call QP_Modifiers_PVT.Process_MODIFIERS

    QP_Modifiers_PVT.Process_MODIFIERS
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   x_MODIFIER_LIST_rec           => l_x_MODIFIER_LIST_rec
    ,   x_MODIFIERS_tbl               => l_x_MODIFIERS_tbl
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

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

oe_debug_pub.add('END Process_Entity in QPXFPRAB');

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
,   p_product_attribute_datatype    IN  VARCHAR2
,   p_pricing_attribute_datatype    IN  VARCHAR2
,   p_comparison_operator_code      IN  VARCHAR2
)
IS
l_return_status               VARCHAR2(1);
l_PRICING_ATTR_rec            QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_PRICING_ATTR_tbl            QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
l_x_MODIFIER_LIST_rec         QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_x_MODIFIERS_rec             QP_Modifiers_PUB.Modifiers_Rec_Type;
l_x_MODIFIERS_tbl             QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_x_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_rec          QP_Modifiers_PUB.Pricing_Attr_Rec_Type;
l_x_PRICING_ATTR_tbl          QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
BEGIN

oe_debug_pub.add('BEGIN Lock_Row in QPXFPRAB');
oe_debug_pub.add('BEGIN Lock_Row in QPXFPRAB');

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
    l_PRICING_ATTR_rec.product_attribute_datatype  := p_product_attribute_datatype;
    l_PRICING_ATTR_rec.pricing_attribute_datatype  := p_pricing_attribute_datatype;
    l_PRICING_ATTR_rec.comparison_operator_code  := p_comparison_operator_code;
    l_PRICING_ATTR_rec.operation   := QP_GLOBALS.G_OPR_LOCK;

    --  Populate PRICING_ATTR table

    l_PRICING_ATTR_tbl(1) := l_PRICING_ATTR_rec;

    --  Call QP_Modifiers_PVT.Lock_MODIFIERS

    QP_Modifiers_PVT.Lock_MODIFIERS
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    ,   x_MODIFIER_LIST_rec           => l_x_MODIFIER_LIST_rec
    ,   x_MODIFIERS_tbl               => l_x_MODIFIERS_tbl
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

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


oe_debug_pub.add('END Lock_Row in QPXFPRAB');

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

--  Procedures maintaining PRICING_ATTR record cache.

PROCEDURE Write_PRICING_ATTR
(   p_PRICING_ATTR_rec              IN  QP_Modifiers_PUB.Pricing_Attr_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
BEGIN

oe_debug_pub.add('BEGIN Write_PRICING_ATTR in QPXFPRAB');

    g_PRICING_ATTR_rec := p_PRICING_ATTR_rec;

    IF p_db_record THEN

        g_db_PRICING_ATTR_rec := p_PRICING_ATTR_rec;

    END IF;

oe_debug_pub.add('END Write_PRICING_ATTR in QPXFPRAB');

END Write_Pricing_Attr;

FUNCTION Get_PRICING_ATTR
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_pricing_attribute_id          IN  NUMBER
)
RETURN QP_Modifiers_PUB.Pricing_Attr_Rec_Type
IS
BEGIN
OE_Debug_PUB.Add('Begin Get_Pricing_Attr in QPXFPRAB');

    IF  p_pricing_attribute_id <> g_PRICING_ATTR_rec.pricing_attribute_id
    THEN

        --  Query row from DB

        g_PRICING_ATTR_rec := QP_Pricing_Attr_Util.Query_Row
        (   p_pricing_attribute_id        => p_pricing_attribute_id
        );

        g_PRICING_ATTR_rec.db_flag     := FND_API.G_TRUE;

        --  Load DB record

        g_db_PRICING_ATTR_rec          := g_PRICING_ATTR_rec;

    END IF;

    IF p_db_record THEN

OE_Debug_PUB.Add('ENd Get_Pricing_Attr in QPXFPRAB');
        RETURN g_db_PRICING_ATTR_rec;

    ELSE

OE_Debug_PUB.Add('else ENd Get_Pricing_Attr in QPXFPRAB');
        RETURN g_PRICING_ATTR_rec;

    END IF;
  EXCEPTION WHEN OTHERS THEN
        RETURN g_PRICING_ATTR_rec;

END Get_Pricing_Attr;

PROCEDURE Clear_Pricing_Attr
IS
BEGIN

oe_debug_pub.add('BEGIN Clear_Pricing_Attr in QPXFPRAB');
    g_PRICING_ATTR_rec             := QP_Modifiers_PUB.G_MISS_PRICING_ATTR_REC;
    g_db_PRICING_ATTR_rec          := QP_Modifiers_PUB.G_MISS_PRICING_ATTR_REC;

oe_debug_pub.add('END Clear_Pricing_Attr in QPXFPRAB');
END Clear_Pricing_Attr;

--for canonical datafix in tst115
FUNCTION Get_DATATYPE
(   p_flexfield_name               IN  VARCHAR2
,   p_Context                     	IN  QP_PRICING_ATTRIBUTES.Pricing_Attribute_Context%type
,   p_Attribute                    IN  QP_PRICING_ATTRIBUTES.Pricing_Attribute%Type
)
RETURN QP_PRICING_ATTRIBUTES.Pricing_Attribute_Datatype%Type IS
x_Datatype 		QP_PRICING_ATTRIBUTES.Pricing_Attribute_Datatype%Type;
l_Segment_Name 	VARCHAR2(240);
l_vsid 			NUMBER;
l_Validation_Type 	VARCHAR2(240);

BEGIN

	l_Segment_Name := Get_Segment_Name( p_flexfield_name
				 			    , p_context
				                   , p_attribute);

	QP_UTIL.Get_Valueset_ID( p_flexfield_name
					   , p_context
					   , l_Segment_Name
					   , l_vsid
					   , x_datatype
					   , l_validation_type);

RETURN x_Datatype;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_DATATYPE;





FUNCTION Get_MEANING
(   p_lookup_code                     IN  QP_LOOKUPS.lookup_code%type
 ,  p_lookup_type                     IN  QP_LOOKUPS.lookup_type%type
)
RETURN QP_LOOKUPS.Meaning%Type IS
l_Meaning QP_LOOKUPS.Meaning%Type;
BEGIN

select meaning into l_Meaning from qp_lookups where
lookup_code = p_lookup_code and lookup_type = p_lookup_type ;

RETURN l_Meaning;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_MEANING;

FUNCTION Get_Pricing_Phase
(   p_pricing_phase_id                     IN  QP_PRICING_PHASES.Pricing_Phase_ID%type
)
RETURN QP_PRICING_PHASES.Name%Type IS
l_Pricing_Phase QP_PRICING_PHASES.Name%Type;
BEGIN

select name into l_Pricing_Phase from QP_Pricing_Phases where
Pricing_Phase_Id = p_Pricing_Phase_Id;

RETURN l_Pricing_Phase;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_Pricing_Phase;

FUNCTION Get_Charge_name
(   p_list_header_id                       IN  qp_list_headers_b.list_header_id%type
,   p_Charge_Type_code                     IN  QP_CHARGE_LOOKUP.lookup_code%type
 ,  p_Charge_Subtype_code                  IN  QP_LOOKUPS.lookup_code%type
 ,  p_list_line_type_code                  IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LOOKUPS.Meaning%Type IS
l_Charge_Name QP_LOOKUPS.Meaning%Type;
l_profile_source_system_code   qp_list_headers_b.source_system_code%type := fnd_profile.value('QP_SOURCE_SYSTEM_CODE');
l_profile_pte_code             qp_list_headers_b.pte_code%type :=  fnd_profile.value('QP_PRICING_TRANSACTION_ENTITY');
l_source_system_code   qp_list_headers_b.source_system_code%type;
l_pte_code             qp_list_headers_b.pte_code%type;
BEGIN

IF p_list_line_type_code = 'FREIGHT_CHARGE' THEN

/*  Added the validation for  freight and spl. charges Bug#4562869   */
    qp_util.get_pte_and_ss( p_list_header_id
                           ,l_pte_code
                           ,l_source_system_code
                         );

       IF  (  l_pte_code = 'PO' and l_source_system_code = 'PO' ) OR ( l_profile_source_system_code = 'PO' and
                    l_profile_pte_code = 'PO')  THEN

                    SELECT name
                    INTO l_charge_name
                    FROM pon_cost_factors_vl
                    WHERE price_element_type_id > 0
                    AND NVL(enabled_flag,'Y') <> 'N'
                    AND TO_CHAR(price_element_type_id) =  p_charge_type_code;

        ELSIF  (  l_pte_code <> 'PO' and l_source_system_code <> 'PO' ) OR ( l_profile_source_system_code <> 'PO' and
                    l_profile_pte_code <> 'PO') THEN

/* changes made in select statement by dhgupta for bug 2047030 */
/* LKP1 rewritten from qp_charge_lookup to fnd_lookup_values (plus additional
   where conditions of the qp_charge_lookup view definition) to get rid of
   non-mergable view, bug 4865226 */
SELECT nvl(DECODE(lkp1.lookup_type,'FREIGHT_COST_TYPE',lkp1.meaning,lkp2.meaning),lkp1.meaning)
	   INTO l_Charge_Name
	   FROM  fnd_lookup_values LKP1, QP_LOOKUPS LKP2
	   WHERE lkp1.language = userenv('LANG')
           and lkp1.security_group_id = 0
           and ((lkp1.view_application_id = 661 and
                 lkp1.lookup_type = 'FREIGHT_CHARGES_TYPE')
                or
                (lkp1.view_application_id = 665 and
                 lkp1.lookup_type = 'FREIGHT_COST_TYPE'))
           AND lkp1.lookup_code = lkp2.lookup_type(+)
	   AND lkp1.enabled_flag = 'Y'
	   AND sysdate BETWEEN NVL(lkp1.start_date_active,sysdate)
    	   AND NVL(lkp1.end_date_active,sysdate)
	   AND (lkp2.enabled_flag = 'Y' OR lkp2.enabled_flag IS NULL)
	   AND sysdate BETWEEN NVL(lkp2.start_date_active,sysdate)
	   AND NVL(lkp2.end_date_active,sysdate)
	   AND lkp1.lookup_code = p_Charge_Type_Code
	   AND DECODE(lkp1.lookup_type,'FREIGHT_COST_TYPE','0',NVL(lkp2.lookup_code,0))
	   = nvl(p_Charge_Subtype_Code, '0');

       ELSE

          l_Charge_Name := NULL;

          END IF;

END IF;

RETURN l_Charge_Name;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_Charge_Name;

FUNCTION Get_Formula
(   p_Price_By_Formula_Id                     IN  QP_PRICE_FORMULAS_VL.Price_Formula_ID%type
)
RETURN QP_PRICE_FORMULAS_VL.Name%Type IS
l_Price_By_Formula QP_PRICE_FORMULAS_VL.Name%Type;
BEGIN

select Name into l_Price_By_Formula from QP_Price_Formulas_Vl where
Price_Formula_ID = p_Price_By_Formula_ID;

RETURN l_Price_By_Formula;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_Formula;

FUNCTION Get_Expiration_Date
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.Expiration_Date%Type IS
l_Expiration_Date QP_LIST_LINES.Expiration_Date%Type;
BEGIN

select decode(p_modifier_type_code, ql.list_line_type_code, ql.Expiration_Date,
Null) into l_Expiration_Date from QP_LIST_LINES ql where
ql.list_line_id = p_list_line_id;

RETURN l_Expiration_Date;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_Expiration_Date;

FUNCTION Get_Exp_Period_Start_Date
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.Expiration_Period_Start_Date%Type IS
l_Exp_Period_Start_Date QP_LIST_LINES.Expiration_Period_Start_Date%Type;
BEGIN

select decode(p_modifier_type_code, ql.list_line_type_code, ql.Expiration_Period_Start_Date,
Null) into l_Exp_Period_Start_Date from QP_LIST_LINES ql where
ql.list_line_id = p_list_line_id;

RETURN l_Exp_Period_Start_Date;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_Exp_Period_Start_Date;

FUNCTION Get_Number_Expiration_Periods
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.Number_Expiration_Periods%Type IS
l_Number_Expiration_Periods QP_LIST_LINES.Number_Expiration_Periods%Type;
BEGIN

select decode(p_modifier_type_code, ql.list_line_type_code, ql.Number_Expiration_Periods,
Null) into l_Number_Expiration_Periods from QP_LIST_LINES ql where
ql.list_line_id = p_list_line_id;

RETURN l_Number_Expiration_Periods;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_Number_Expiration_Periods;

FUNCTION Get_Expiration_Period_UOM
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.Expiration_Period_UOM%Type IS
l_Expiration_Period_UOM QP_LIST_LINES.Expiration_Period_UOM%Type;
BEGIN

select decode(p_modifier_type_code, ql.list_line_type_code, ql.Expiration_Period_UOM,
Null) into l_Expiration_Period_UOM from QP_LIST_LINES ql where
ql.list_line_id = p_list_line_id;

RETURN l_Expiration_Period_UOM;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_Expiration_Period_UOM;

--changes for bug 1496839 to improve performance
FUNCTION Get_Rebate_Txn_Type
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
,   p_list_line_type_code			IN QP_LIST_LINES.list_line_type_code%type
,   p_rebate_transaction_type_code		IN QP_LIST_LINES.REBATE_TRANSACTION_TYPE_CODE%type
)
RETURN QP_LOOKUPS.Meaning%Type IS
l_Rebate_Txn_Type QP_LOOKUPS.Meaning%Type;
BEGIN

select decode(p_modifier_type_code, p_list_line_type_code,
qlook.meaning, Null) into
l_Rebate_Txn_Type from QP_LOOKUPS qlook where
qlook.lookup_type = 'REBATE_TRANSACTION_TYPE_CODE' and
qlook.lookup_code = p_rebate_transaction_type_code;

/*
select decode(p_modifier_type_code, ql.list_line_type_code,
qlook.meaning, Null) into
l_Rebate_Txn_Type from QP_LIST_LINES ql, QP_LOOKUPS qlook where
ql.list_line_id = p_list_line_id and
qlook.lookup_code = ql.rebate_transaction_type_code;
*/

RETURN l_Rebate_Txn_Type;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_Rebate_Txn_Type;

FUNCTION Get_Benefit_Qty
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.Benefit_Qty%Type IS
l_Benefit_Qty QP_LIST_LINES.Benefit_Qty%Type;
BEGIN

select decode(p_modifier_type_code, ql.list_line_type_code, ql.Benefit_Qty,
Null) into l_Benefit_Qty from QP_LIST_LINES ql where
ql.list_line_id = p_list_line_id;

RETURN l_Benefit_Qty;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_Benefit_Qty;

FUNCTION Get_Benefit_UOM_Code
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.Benefit_UOM_Code%Type IS
l_Benefit_UOM_Code QP_LIST_LINES.Benefit_UOM_Code%Type;
BEGIN

select decode(p_modifier_type_code, ql.list_line_type_code, ql.Benefit_UOM_Code,
Null) into l_Benefit_UOM_Code from QP_LIST_LINES ql where
ql.list_line_id = p_list_line_id;

RETURN l_Benefit_UOM_Code;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_Benefit_UOM_Code;

PROCEDURE Get_Rltd_Modifier_Flds
	(p_List_Line_Id IN QP_LIST_LINES.List_Line_ID%Type
	,x_To_Rltd_Modifier_ID OUT NOCOPY /* file.sql.39 change */ NUMBER
	,x_Rltd_Modifier_Grp_Type OUT NOCOPY /* file.sql.39 change */ NUMBER
	,x_Rltd_Modifier_Grp_No OUT NOCOPY /* file.sql.39 change */ NUMBER
	,x_Rltd_Modifier_ID OUT NOCOPY /* file.sql.39 change */ NUMBER
	);

PROCEDURE Get_Rltd_Modifier_Flds
	(p_List_Line_Id IN QP_LIST_LINES.List_Line_ID%Type
	,x_To_Rltd_Modifier_ID OUT NOCOPY /* file.sql.39 change */ NUMBER
	,x_Rltd_Modifier_Grp_Type OUT NOCOPY /* file.sql.39 change */ NUMBER
	,x_Rltd_Modifier_Grp_No OUT NOCOPY /* file.sql.39 change */ NUMBER
	,x_Rltd_Modifier_ID OUT NOCOPY /* file.sql.39 change */ NUMBER
	) IS

l_List_Line_Id 			QP_LIST_LINES.List_Line_ID%Type;
l_To_Rltd_Modifier_ID 		QP_RLTD_MODIFIERS.To_Rltd_Modifier_ID%Type;
l_Rltd_Modifier_Grp_Type 	QP_RLTD_MODIFIERS.Rltd_Modifier_Grp_Type%Type;
l_Rltd_Modifier_Grp_No 		QP_RLTD_MODIFIERS.Rltd_Modifier_Grp_No%Type;
l_Rltd_Modifier_ID 			QP_RLTD_MODIFIERS.Rltd_Modifier_ID%Type;

BEGIN

select to_rltd_modifier_id,
	rltd_modifier_grp_type, rltd_modifier_grp_no, rltd_modifier_id
	into x_to_rltd_modifier_id,
	x_rltd_modifier_grp_type, x_rltd_modifier_grp_no, x_rltd_modifier_id
	from qp_rltd_modifiers
	where
	from_rltd_modifier_id = p_list_line_id;

EXCEPTION

When NO_DATA_FOUND Then

Null;

When OTHERS Then

Null;

END Get_Rltd_Modifier_Flds;

FUNCTION Get_To_Rltd_Modifier_ID
(   p_list_line_id 	 		IN QP_LIST_LINES.List_Line_ID%Type
,   p_modifier_type_code      IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_RLTD_MODIFIERS.To_Rltd_Modifier_ID%Type IS
l_To_Rltd_Modifier_ID 		QP_RLTD_MODIFIERS.To_Rltd_Modifier_ID%Type;
l_Rltd_Modifier_Grp_Type 	QP_RLTD_MODIFIERS.Rltd_Modifier_Grp_Type%Type;
l_Rltd_Modifier_Grp_No 		QP_RLTD_MODIFIERS.Rltd_Modifier_Grp_No%Type;
l_Rltd_Modifier_ID 			QP_RLTD_MODIFIERS.Rltd_Modifier_ID%Type;
BEGIN

	IF p_modifier_type_code = 'CIE' THEN
	--only for coupon issue
	Get_Rltd_Modifier_Flds(p_List_Line_ID
				  , l_To_Rltd_Modifier_ID
				  , l_Rltd_Modifier_Grp_Type
				  , l_Rltd_Modifier_Grp_No
				  , l_Rltd_Modifier_ID);
	END IF;

RETURN l_To_Rltd_Modifier_ID;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_To_Rltd_Modifier_ID;

FUNCTION Get_Rltd_Modifier_ID
(   p_list_line_id 	 		IN QP_LIST_LINES.List_Line_ID%Type
,   p_modifier_type_code      IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_RLTD_MODIFIERS.Rltd_Modifier_ID%Type IS
l_To_Rltd_Modifier_ID 		QP_RLTD_MODIFIERS.To_Rltd_Modifier_ID%Type;
l_Rltd_Modifier_Grp_Type 	QP_RLTD_MODIFIERS.Rltd_Modifier_Grp_Type%Type;
l_Rltd_Modifier_Grp_No 		QP_RLTD_MODIFIERS.Rltd_Modifier_Grp_No%Type;
l_Rltd_Modifier_ID 			QP_RLTD_MODIFIERS.Rltd_Modifier_ID%Type;
BEGIN

	IF p_modifier_type_code = 'CIE' THEN
	--only for coupon issue
	Get_Rltd_Modifier_Flds(p_List_Line_ID
				  , l_To_Rltd_Modifier_ID
				  , l_Rltd_Modifier_Grp_Type
				  , l_Rltd_Modifier_Grp_No
				  , l_Rltd_Modifier_ID);
	END IF;

RETURN l_Rltd_Modifier_ID;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_Rltd_Modifier_ID;

FUNCTION Get_Rltd_Modifier_Grp_Type
(   p_list_line_id 	 		IN QP_LIST_LINES.List_Line_ID%Type
,   p_modifier_type_code      IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_RLTD_MODIFIERS.Rltd_Modifier_Grp_Type%Type IS
l_To_Rltd_Modifier_ID 		QP_RLTD_MODIFIERS.To_Rltd_Modifier_ID%Type;
l_Rltd_Modifier_Grp_Type 	QP_RLTD_MODIFIERS.Rltd_Modifier_Grp_Type%Type;
l_Rltd_Modifier_Grp_No 		QP_RLTD_MODIFIERS.Rltd_Modifier_Grp_No%Type;
l_Rltd_Modifier_ID 			QP_RLTD_MODIFIERS.Rltd_Modifier_ID%Type;
BEGIN

	IF p_modifier_type_code = 'CIE' THEN
	--only for coupon issue
	Get_Rltd_Modifier_Flds(p_List_Line_ID
				  , l_To_Rltd_Modifier_ID
				  , l_Rltd_Modifier_Grp_Type
				  , l_Rltd_Modifier_Grp_No
				  , l_Rltd_Modifier_ID);
	END IF;

RETURN l_Rltd_Modifier_Grp_Type;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_Rltd_Modifier_Grp_Type;

FUNCTION Get_Rltd_Modifier_Grp_No
(   p_list_line_id 	 		IN QP_LIST_LINES.List_Line_ID%Type
,   p_modifier_type_code      IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_RLTD_MODIFIERS.Rltd_Modifier_Grp_No%Type IS
l_To_Rltd_Modifier_ID 		QP_RLTD_MODIFIERS.To_Rltd_Modifier_ID%Type;
l_Rltd_Modifier_Grp_Type 	QP_RLTD_MODIFIERS.Rltd_Modifier_Grp_Type%Type;
l_Rltd_Modifier_Grp_No 		QP_RLTD_MODIFIERS.Rltd_Modifier_Grp_No%Type;
l_Rltd_Modifier_ID 			QP_RLTD_MODIFIERS.Rltd_Modifier_ID%Type;
BEGIN

	IF p_modifier_type_code = 'CIE' THEN
	--only for coupon issue
	Get_Rltd_Modifier_Flds(p_List_Line_ID
				  , l_To_Rltd_Modifier_ID
				  , l_Rltd_Modifier_Grp_Type
				  , l_Rltd_Modifier_Grp_No
				  , l_Rltd_Modifier_ID);
	END IF;

RETURN l_Rltd_Modifier_Grp_No;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_Rltd_Modifier_Grp_No;


FUNCTION Get_Benefit_list_Line_No
(   p_list_line_id 	 		IN QP_LIST_LINES.List_Line_ID%Type
,   p_modifier_type_code      IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.List_Line_No%Type IS
l_To_Rltd_Modifier_ID 		QP_RLTD_MODIFIERS.To_Rltd_Modifier_ID%Type;
l_Rltd_Modifier_Grp_Type 	QP_RLTD_MODIFIERS.Rltd_Modifier_Grp_Type%Type;
l_Rltd_Modifier_Grp_No 		QP_RLTD_MODIFIERS.Rltd_Modifier_Grp_No%Type;
l_Rltd_Modifier_ID 			QP_RLTD_MODIFIERS.Rltd_Modifier_ID%Type;
l_Benefit_List_Line_No QP_LIST_LINES.List_Line_No%Type;
BEGIN

	IF p_modifier_type_code = 'CIE' THEN
	--only for coupon issue
	Get_Rltd_Modifier_Flds(p_List_Line_ID
				  , l_To_Rltd_Modifier_ID
				  , l_Rltd_Modifier_Grp_Type
				  , l_Rltd_Modifier_Grp_No
				  , l_Rltd_Modifier_ID);

	select list_line_no into l_benefit_list_line_no from
		qp_list_lines where list_line_id = l_to_rltd_modifier_id;

	END IF;

RETURN l_benefit_list_line_no;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_Benefit_list_Line_No;



/*
FUNCTION Get_Benefit_List_Line_No
(   p_to_rltd_modifier_id              IN  QP_RLTD_MODIFIERS.to_rltd_modifier_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.List_Line_No%Type IS
l_Benefit_List_Line_No QP_LIST_LINES.List_Line_No%Type;
BEGIN

select decode(p_modifier_type_code, ql.list_line_type_code, ql.List_Line_No,
Null) into l_Benefit_List_Line_No from QP_LIST_LINES ql  where
ql.list_line_id = p_to_rltd_modifier_id;

RETURN l_Benefit_List_Line_No;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_Benefit_List_Line_No;
*/

FUNCTION Get_Accrual_Flag
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.Accrual_Flag%Type IS
l_Accrual_Flag QP_LIST_LINES.Accrual_Flag%Type;
BEGIN

select decode(p_modifier_type_code, ql.list_line_type_code, ql.Accrual_Flag,
Null) into l_Accrual_Flag from QP_LIST_LINES ql where
ql.list_line_id = p_list_line_id;

RETURN l_Accrual_Flag;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_Accrual_Flag;

FUNCTION Get_Accrual_Conversion_Rate
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.Accrual_Conversion_Rate%Type IS
l_Accrual_Conversion_Rate QP_LIST_LINES.Accrual_Conversion_Rate%Type;
BEGIN

select decode(p_modifier_type_code, ql.list_line_type_code,
ql.Accrual_Conversion_Rate, Null) into l_Accrual_Conversion_Rate
from QP_LIST_LINES ql where ql.list_line_id = p_list_line_id;

RETURN l_Accrual_Conversion_Rate;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_Accrual_Conversion_Rate;

FUNCTION Get_Estim_Accrual_Rate
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.Estim_Accrual_Rate%Type IS
l_Estim_Accrual_Rate QP_LIST_LINES.Estim_Accrual_Rate%Type;
BEGIN

select decode(p_modifier_type_code, ql.list_line_type_code,
ql.Estim_Accrual_Rate, Null) into l_Estim_Accrual_Rate from
QP_LIST_LINES ql where ql.list_line_id = p_list_line_id;

RETURN l_Estim_Accrual_Rate;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_Estim_Accrual_Rate;

--changes for bug 1496839 to improve performance
FUNCTION Get_Break_Line_Type_Code
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LIST_LINES.List_Line_Type_Code%Type IS
l_Break_Line_Type_Code QP_LIST_LINES.List_Line_Type_Code%Type;
BEGIN

IF p_modifier_type_code = 'PBH' then

select ql.list_line_type_code into l_Break_Line_Type_Code
from QP_LIST_LINES ql
where ql.list_line_id = (select to_rltd_modifier_id from
qp_rltd_modifiers where from_rltd_modifier_id = p_list_line_id and
rownum < 2);

ELSE

l_break_line_type_code := null;

END IF;

RETURN l_Break_Line_Type_Code;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_Break_Line_Type_Code;

--changes for bug 1496839 to improve performance
FUNCTION Get_Break_Line_Type
(   p_list_line_id                     IN  QP_LIST_LINES.list_line_id%type
,   p_modifier_type_code               IN  QP_LIST_LINES.list_line_type_code%type
,   p_break_line_type_code			IN QP_LIST_LINES.list_line_type_code%type
)
RETURN QP_LOOKUPS.Meaning%Type IS
l_Break_Line_Type QP_LOOKUPS.Meaning%Type;
BEGIN

IF p_modifier_type_code = 'PBH' then

select qlook.Meaning into l_Break_Line_Type
from qp_lookups qlook
where qlook.lookup_type = 'LIST_LINE_TYPE_CODE' and
qlook.lookup_code = p_break_line_type_code;


/*
select qlook.Meaning into l_Break_Line_Type
from QP_LIST_LINES ql, qp_lookups qlook
where qlook.lookup_code = ql.list_line_type_code and
ql.list_line_id = (select to_rltd_modifier_id from
qp_rltd_modifiers where from_rltd_modifier_id = p_list_line_id and
rownum < 2);
*/

ELSE

l_break_line_type := null;

END IF;

RETURN l_Break_Line_Type;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_Break_Line_Type;


  FUNCTION Get_Context(p_FlexField_Name  IN VARCHAR2
				  ,p_context    IN VARCHAR2)RETURN VARCHAR2 IS
/* commented for attribute manager change
  Flexfield FND_DFLEX.dflex_r;
  Flexinfo  FND_DFLEX.dflex_dr;
  Contexts  FND_DFLEX.contexts_dr;
*/

  x_context_code        VARCHAR2(240);

  BEGIN
  x_context_code := QP_UTIL.Get_Context(p_FlexField_Name
                                       ,p_context);

/* commented for attribute manager change
  -- Call Flexapi to get contexts

  FND_DFLEX.get_flexfield('QP',p_FlexField_Name,Flexfield,Flexinfo);
  FND_DFLEX.get_contexts(Flexfield,Contexts);


  For i in 1..Contexts.ncontexts LOOP

    If(Contexts.is_enabled(i) AND (NOT (Contexts.is_global(i)))) Then

       If p_context = Contexts.context_code(i) Then
          x_context_code :=Contexts.context_name(i);
		EXIT;
       End If;

    End if;
  End Loop;
*/

  RETURN x_context_code;

  END Get_Context;

/*-------------------------------------------------------------------------
CHANGED THIS PROCEDURE TO SHOW THE ID IF THE ATTRIBUTE IS INVALID OR
THE ATTRIBUTE HAS BEEN DELETED.
CHANGES MADE BASED ON SWATI'S CHANGES TO QP_CON_ATTR_PACKAGE IN QPXCORE
-------------------------------------------------------------------------*/

PROCEDURE Get_Attribute_Code(p_FlexField_Name 	IN VARCHAR2
                            ,p_Context_Name   	IN VARCHAR2
				        ,p_attribute      	IN VARCHAR2
					   ,p_attribute_col_name IN VARCHAR2
					   ,x_attribute_code 	OUT NOCOPY /* file.sql.39 change */ VARCHAR2
					   ,x_segment_name   	OUT NOCOPY /* file.sql.39 change */ VARCHAR2
					   ) 	IS
/* commented for attribute manager change
  Flexfield FND_DFLEX.dflex_r;
  Flexinfo  FND_DFLEX.dflex_dr;
  Contexts  FND_DFLEX.contexts_dr;
  segments  FND_DFLEX.segments_dr;
  i BINARY_INTEGER;

  VALID_ATTRIBUTE BOOLEAN := FALSE;
*/

BEGIN
   QP_UTIL.Get_Attribute_Code(p_FlexField_Name
                             ,p_Context_Name
                             ,p_attribute
                             ,x_attribute_code
                             ,x_segment_name
                             );

/* commented for attribute manager change
  FND_DFLEX.get_flexfield('QP',p_FlexField_Name,Flexfield,Flexinfo);

	--removing  the check for the  enabled segments as well as per the upgrade
	--requirement.
	--While upgrading ,there may be some segments which were enabled in the
	--past but disabled now.
	--In such cases ,we still need to show the data in the post query.
	--Hence commented out the call with 'TRUE' which looks only for enabled
	--segments.
	--And added 'FALSE' which reads all the segments.


  --FND_DFLEX.get_segments(FND_DFLEX.make_context(Flexfield,p_Context_Name),
          --            segments,TRUE);
  FND_DFLEX.get_segments(FND_DFLEX.make_context(Flexfield,p_Context_Name), segments,FALSE);

  For i in 1..segments.nsegments LOOP

    --removing  the check for the  enabled segments as well as per the upgrade
   --requirement.
  --While upgrading ,there may be some segments which were enabled in the past
  --but disabled now.
 --In such cases ,we still need to show the data in the post query.

    IF segments.is_enabled(i)  THEN

	    IF segments.application_column_name(i) = p_attribute Then
		  x_attribute_code := segments.row_prompt(i);
		  x_segment_name   := segments.segment_name(i);
		  VALID_ATTRIBUTE  := TRUE;
		  EXIT;
         End if;
    END IF;
  END LOOP;

       --added to show invalid values brought in by upgrade.
		IF NOT VALID_ATTRIBUTE THEN
		--fnd_message.debug('invalid attr');
		oe_debug_pub.add('invalid attr');
			x_attribute_code  := p_attribute;
			--Not applicable for database package; will handle in the UI
			set_item_instance_property(
			p_attribute_col_name
			,CURRENT_RECORD
			,VISUAL_ATTRIBUTE
			,'DATA_RED');

		END IF;
	  -- end of additions for the upgrade.
*/


 END Get_Attribute_Code;

FUNCTION Get_Attribute
(   p_FlexField_Name IN VARCHAR2
,   p_Context_Name   IN VARCHAR2
,   p_attribute      IN VARCHAR2
)
RETURN VARCHAR2 IS
l_product_attr VARCHAR2(240);
l_prod_segment_name VARCHAR2(240);
BEGIN

	Get_Attribute_Code(p_FlexField_Name
				  , p_context_name
				  , p_attribute
				  , NULL
				  , l_product_attr
				  , l_prod_segment_name);

RETURN l_Product_attr;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then

Return Null;

END Get_Attribute;

FUNCTION Get_Segment_name
(   p_FlexField_Name IN VARCHAR2
,   p_Context_Name   IN VARCHAR2
,   p_attribute      IN VARCHAR2
)
RETURN VARCHAR2 IS
l_product_attr VARCHAR2(240);
l_prod_segment_name VARCHAR2(240);
BEGIN

	Get_Attribute_Code(p_FlexField_Name
				  , p_context_name
				  , p_attribute
				  , NULL
				  , l_product_attr
				  , l_prod_segment_name);

RETURN l_prod_segment_name;

EXCEPTION

When NO_DATA_FOUND Then

Return Null;

When OTHERS Then


Return Null;

END Get_Segment_name;

/*-------------------------------------------------------------------------
CHANGED THIS FUNCTION TO SHOW THE ID IF THE VALUE IS INVALID OR THE VALUE
HAS BEEN DELETED FROM THE VALUE SET.
CHANGES MADE BASED ON SWATI'S CHANGES TO QP_CON_ATTR_PACKAGE IN QPXCORE
-------------------------------------------------------------------------*/


FUNCTION Get_Attribute_Value(p_FlexField_Name       IN VARCHAR2
                            ,p_Context_Name         IN VARCHAR2
		            	   ,p_attribute         	  IN VARCHAR2
			    		   ,p_attr_value IN VARCHAR2
                            ,p_attribute_val_col_name   IN VARCHAR2 := NULL
                            ,p_comparison_operator_code IN VARCHAR2 := NULL
			    		   ) RETURN VARCHAR2 IS

  Vset  FND_VSET.valueset_r;
  Fmt   FND_VSET.valueset_dr;

  Found BOOLEAN;
  Row   NUMBER;
  Value FND_VSET.value_dr;



  x_Format_Type Varchar2(1);
  x_Validation_Type Varchar2(1);
  x_Vsid  NUMBER;


  x_attr_value_code     VARCHAR2(240);
  l_segment_name	    VARCHAR2(240);


  l_attr_value     VARCHAR2(2000);


  Value_Valid_In_Valueset BOOLEAN := FALSE;
  l_id VARCHAR2(150);
  l_value VARCHAR2(150);

  BEGIN
  /* Added for 2332139 */

  IF p_FlexField_Name IS NULL OR p_Context_Name IS NULL OR p_attribute IS NULL THEN
     RETURN NULL;
  ELSE

	l_segment_name := get_segment_name(p_flexfield_name,
								p_context_name, p_attribute);

         QP_UTIL.get_valueset_id(p_FlexField_Name,p_Context_Name,
								   l_Segment_Name,x_Vsid,
								   x_Format_Type, x_Validation_Type);


		l_attr_value := p_attr_value;

  -- if comparison operator is other than '=' then no need to get the
  -- meaning as the value itself will be stored in qualifier_attr_value


--change made by spgopal. added parameter called p_comparison_operator_code
--to generalise the code for all forms and packages

	    If  nvl(p_comparison_operator_code, '0') <>  'BETWEEN' THEN

         		IF x_Validation_Type In('F' ,'I')  AND x_Vsid  IS NOT NULL THEN


				IF x_Validation_Type = 'I' Then

            			FND_VSET.get_valueset(x_Vsid,Vset,Fmt);
            			FND_VSET.get_value_init(Vset,TRUE);
            			FND_VSET.get_value(Vset,Row,Found,Value);


            			IF Fmt.Has_Id Then --id is defined.Hence compare for id

                     		While(Found) Loop


                        		If  l_attr_value  = Value.id  Then

	                       		x_attr_value_code  := Value.value;
                            		Value_Valid_In_Valueset := TRUE;
                            		EXIT;
                        		End If;
                        		FND_VSET.get_value(Vset,Row,Found,Value);

                     		End Loop;
            			Else      -- id not defined.Hence compare for value

                     		While(Found) Loop

                        		If  l_attr_value  = Value.value  Then

                            		x_attr_value_code  := l_attr_value;
					   		Value_Valid_In_Valueset := TRUE;
                            		EXIT;
                        		End If;
                        		FND_VSET.get_value(Vset,Row,Found,Value);

                     		End Loop;

            			End If; ---end of Fmt.Has_Id


             			FND_VSET.get_value_end(Vset);

				ELSIF x_Validation_Type = 'F' THEN

					FND_VSET.get_valueset(x_Vsid,Vset,Fmt);

					IF (QP_UTIL.value_exists_in_table(Vset.table_info,
							l_attr_value,l_id,l_value)) THEN

							IF Fmt.Has_Id Then
							--id is defined. Hence compare id

								IF l_attr_value = l_id Then

									x_attr_value_code := l_value;
									Value_Valid_In_Valueset := TRUE;
								END IF;
							ELSE
								IF l_attr_value = l_value THEN
									x_attr_value_code := l_attr_value;
									Value_Valid_In_Valueset := TRUE;
								END IF;
							END IF; 	--End of Fmt.Has_ID
					ELSE
						Value_Valid_In_Valueset := FALSE;
					END IF;
				END IF;


        		ELSE -- if validation type is not F or I or valueset id is null (not defined)

             		x_attr_value_code := l_attr_value;
        		END IF;
   ELSE -- if comparison operator is 'between'

        x_attr_value_code  := l_attr_value;
   END IF;


 RETURN x_attr_value_code;
END IF;
END Get_Attribute_Value;



FUNCTION Get_Attr_Value_To(p_FlexField_Name       IN VARCHAR2
                          ,p_Context_Name         IN VARCHAR2
			  		 ,p_segment_name         IN VARCHAR2
		          	 ,p_attr_value_To        IN VARCHAR2
		          	 ) RETURN VARCHAR2 IS

  Vset  FND_VSET.valueset_r;
  Fmt   FND_VSET.valueset_dr;

  Found BOOLEAN;
  Row   NUMBER;
  Value FND_VSET.value_dr;



  x_Format_Type Varchar2(1);
  x_Validation_Type Varchar2(1);
  x_Vsid  NUMBER;


  x_attr_value_code     VARCHAR2(240);
  l_attr_value_to     VARCHAR2(2000);

  BEGIN


         QP_UTIL.get_valueset_id(p_FlexField_Name,p_Context_Name,
	                             p_Segment_Name,x_Vsid,
                                 x_Format_Type, x_Validation_Type);
/*
         IF x_Validation_Type In('F' ,'I')  AND x_Vsid  IS NOT NULL THEN
            FND_VSET.get_valueset(x_Vsid,Vset,Fmt);
            FND_VSET.get_value_init(Vset,TRUE);
            FND_VSET.get_value(Vset,Row,Found,Value);

            While(Found) Loop

             --fnd_message.debug(Value.value);
             --fnd_message.debug(Value.meaning);
             --fnd_message.debug(Value.id);

             If  p_attr_value_to  = Value.value  Then

	            x_attr_value_code  := Value.Meaning;
                 EXIT;
             End If;
             FND_VSET.get_value(Vset,Row,Found,Value);

             End Loop;
             FND_VSET.get_value_end(Vset);
        ELSE

             x_attr_value_code := p_attr_value_to;
        END IF;
   --ELSE

   --     x_attr_value_code  := p_attr_value;
   --END IF;
        --fnd_message.debug(x_attr_value_code);
*/

--this function is going to be used in the summary block of modifiers form.
--the pricing context can only be VOLUME. so returning the value to directly
--the post query of the block handles canonical conversion

	x_attr_value_code := p_attr_value_to;

 RETURN x_attr_value_code;
END Get_Attr_Value_to;





--added by svdeshmu
-- This procedure will be called from the client when the user
-- clears a record
Procedure Clear_Record
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_line_id                  IN  NUMBER
)
IS
l_return_status                     Varchar2(30);
BEGIN
     OE_MSG_PUB.initialize;
 	x_return_status := FND_API.G_RET_STS_SUCCESS;
     QP_DELAYED_REQUESTS_PVT.Delete_Reqs_for_Deleted_Entity(
					p_entity_code  => QP_GLOBALS.G_ENTITY_PRICING_ATTR
					,p_entity_id    => p_list_line_id
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


--added by svdeshmu




END QP_QP_Form_Pricing_Attr;

/
