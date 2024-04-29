--------------------------------------------------------
--  DDL for Package Body QP_QP_FORM_FORMULA_LINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_QP_FORM_FORMULA_LINES" AS
/* $Header: QPXFPFLB.pls 120.1 2005/06/13 04:04:26 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_QP_Form_Formula_Lines';

--  Global variables holding cached record.

g_FORMULA_LINES_rec           QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
g_db_FORMULA_LINES_rec        QP_Price_Formula_PUB.Formula_Lines_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_FORMULA_LINES
(   p_FORMULA_LINES_rec             IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

FUNCTION Get_FORMULA_LINES
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_price_formula_line_id         IN  NUMBER
)
RETURN QP_Price_Formula_PUB.Formula_Lines_Rec_Type;

PROCEDURE Clear_FORMULA_LINES;

--  Global variable holding performed operations.

g_opr__tbl                    QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;


--  Procedure : Create_Factor_List
--

PROCEDURE Create_Factor_List
(   p_name                          IN  VARCHAR2
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_list_header_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_name                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_MODIFIER_LIST_rec           QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_MODIFIER_LIST_rec         QP_Modifiers_PUB.Modifier_List_Rec_Type;
l_x_MODIFIERS_tbl             QP_Modifiers_PUB.Modifiers_Tbl_Type;
l_x_QUALIFIERS_tbl            QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type;
l_x_PRICING_ATTR_tbl          QP_Modifiers_PUB.Pricing_Attr_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.default_attributes   := TRUE;

    l_control_rec.change_attributes    := TRUE;
    l_control_rec.validate_entity      := TRUE;
    l_control_rec.write_to_DB          := TRUE;
    l_control_rec.process              := FALSE;

    --  Instruct API to retain its caches

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Load IN parameters if any exist


    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

    l_MODIFIER_LIST_rec.attribute1                := NULL;
    l_MODIFIER_LIST_rec.attribute10               := NULL;
    l_MODIFIER_LIST_rec.attribute11               := NULL;
    l_MODIFIER_LIST_rec.attribute12               := NULL;
    l_MODIFIER_LIST_rec.attribute13               := NULL;
    l_MODIFIER_LIST_rec.attribute14               := NULL;
    l_MODIFIER_LIST_rec.attribute15               := NULL;
    l_MODIFIER_LIST_rec.attribute2                := NULL;
    l_MODIFIER_LIST_rec.attribute3                := NULL;
    l_MODIFIER_LIST_rec.attribute4                := NULL;
    l_MODIFIER_LIST_rec.attribute5                := NULL;
    l_MODIFIER_LIST_rec.attribute6                := NULL;
    l_MODIFIER_LIST_rec.attribute7                := NULL;
    l_MODIFIER_LIST_rec.attribute8                := NULL;
    l_MODIFIER_LIST_rec.attribute9                := NULL;
    l_MODIFIER_LIST_rec.context                   := NULL;

    l_MODIFIER_LIST_rec.name := p_name;
    l_MODIFIER_LIST_rec.list_type_code := 'PML';

    --  Set Operation to Create

    l_MODIFIER_LIST_rec.operation := QP_GLOBALS.G_OPR_CREATE;

    --  Call QP_Modifiers_PVT.Process_Modifiers

    QP_Modifiers_PVT.Process_Modifiers
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_MODIFIER_LIST_rec           => l_MODIFIER_LIST_rec
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

    x_attribute1                   := l_x_MODIFIER_LIST_rec.attribute1;
    x_attribute10                  := l_x_MODIFIER_LIST_rec.attribute10;
    x_attribute11                  := l_x_MODIFIER_LIST_rec.attribute11;
    x_attribute12                  := l_x_MODIFIER_LIST_rec.attribute12;
    x_attribute13                  := l_x_MODIFIER_LIST_rec.attribute13;
    x_attribute14                  := l_x_MODIFIER_LIST_rec.attribute14;
    x_attribute15                  := l_x_MODIFIER_LIST_rec.attribute15;
    x_attribute2                   := l_x_MODIFIER_LIST_rec.attribute2;
    x_attribute3                   := l_x_MODIFIER_LIST_rec.attribute3;
    x_attribute4                   := l_x_MODIFIER_LIST_rec.attribute4;
    x_attribute5                   := l_x_MODIFIER_LIST_rec.attribute5;
    x_attribute6                   := l_x_MODIFIER_LIST_rec.attribute6;
    x_attribute7                   := l_x_MODIFIER_LIST_rec.attribute7;
    x_attribute8                   := l_x_MODIFIER_LIST_rec.attribute8;
    x_attribute9                   := l_x_MODIFIER_LIST_rec.attribute9;
    x_context                      := l_x_MODIFIER_LIST_rec.context;
    x_list_header_id               := l_x_MODIFIER_LIST_rec.list_header_id;
    x_name                         := l_x_MODIFIER_LIST_rec.name;

    --  Load display out parameters if any


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
            ,   'Create_Factor_List'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Create_Factor_List;

--  Procedure : Default_Attributes
--

PROCEDURE Default_Attributes
(   p_price_formula_id              IN  NUMBER
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
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
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_numeric_constant              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_formula_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_formula_line_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_formula_line_type_code        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_line_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_modifier_list_id        OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_attribute             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute_context     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_step_number                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_formula                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_formula_line            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_formula_line_type       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_line               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_modifier_list           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_reqd_flag                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_FORMULA_LINES_rec           QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
l_FORMULA_LINES_val_rec       QP_Price_Formula_PUB.Formula_Lines_Val_Rec_Type;
l_FORMULA_LINES_tbl           QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_FORMULA_rec               QP_Price_Formula_PUB.Formula_Rec_Type;
l_x_FORMULA_LINES_rec         QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
l_x_FORMULA_LINES_tbl         QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;
BEGIN

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

    l_FORMULA_LINES_rec.price_formula_id := p_price_formula_id;

    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

    l_FORMULA_LINES_rec.attribute1                := NULL;
    l_FORMULA_LINES_rec.attribute10               := NULL;
    l_FORMULA_LINES_rec.attribute11               := NULL;
    l_FORMULA_LINES_rec.attribute12               := NULL;
    l_FORMULA_LINES_rec.attribute13               := NULL;
    l_FORMULA_LINES_rec.attribute14               := NULL;
    l_FORMULA_LINES_rec.attribute15               := NULL;
    l_FORMULA_LINES_rec.attribute2                := NULL;
    l_FORMULA_LINES_rec.attribute3                := NULL;
    l_FORMULA_LINES_rec.attribute4                := NULL;
    l_FORMULA_LINES_rec.attribute5                := NULL;
    l_FORMULA_LINES_rec.attribute6                := NULL;
    l_FORMULA_LINES_rec.attribute7                := NULL;
    l_FORMULA_LINES_rec.attribute8                := NULL;
    l_FORMULA_LINES_rec.attribute9                := NULL;
    l_FORMULA_LINES_rec.context                   := NULL;

    --  Set Operation to Create

    l_FORMULA_LINES_rec.operation := QP_GLOBALS.G_OPR_CREATE;

    --  Populate FORMULA_LINES table

    l_FORMULA_LINES_tbl(1) := l_FORMULA_LINES_rec;

    --  Call QP_Price_Formula_PVT.Process_Price_Formula

    QP_Price_Formula_PVT.Process_Price_Formula
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_FORMULA_LINES_tbl           => l_FORMULA_LINES_tbl
    ,   x_FORMULA_rec                 => l_x_FORMULA_rec
    ,   x_FORMULA_LINES_tbl           => l_x_FORMULA_LINES_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl

    l_x_FORMULA_LINES_rec := l_x_FORMULA_LINES_tbl(1);

    --  Load OUT parameters.

    x_attribute1                   := l_x_FORMULA_LINES_rec.attribute1;
    x_attribute10                  := l_x_FORMULA_LINES_rec.attribute10;
    x_attribute11                  := l_x_FORMULA_LINES_rec.attribute11;
    x_attribute12                  := l_x_FORMULA_LINES_rec.attribute12;
    x_attribute13                  := l_x_FORMULA_LINES_rec.attribute13;
    x_attribute14                  := l_x_FORMULA_LINES_rec.attribute14;
    x_attribute15                  := l_x_FORMULA_LINES_rec.attribute15;
    x_attribute2                   := l_x_FORMULA_LINES_rec.attribute2;
    x_attribute3                   := l_x_FORMULA_LINES_rec.attribute3;
    x_attribute4                   := l_x_FORMULA_LINES_rec.attribute4;
    x_attribute5                   := l_x_FORMULA_LINES_rec.attribute5;
    x_attribute6                   := l_x_FORMULA_LINES_rec.attribute6;
    x_attribute7                   := l_x_FORMULA_LINES_rec.attribute7;
    x_attribute8                   := l_x_FORMULA_LINES_rec.attribute8;
    x_attribute9                   := l_x_FORMULA_LINES_rec.attribute9;
    x_context                      := l_x_FORMULA_LINES_rec.context;
    x_end_date_active              := l_x_FORMULA_LINES_rec.end_date_active;
    x_numeric_constant             := l_x_FORMULA_LINES_rec.numeric_constant;
    x_price_formula_id             := l_x_FORMULA_LINES_rec.price_formula_id;
    x_price_formula_line_id        := l_x_FORMULA_LINES_rec.price_formula_line_id;
    x_formula_line_type_code       := l_x_FORMULA_LINES_rec.formula_line_type_code;
    x_price_list_line_id           := l_x_FORMULA_LINES_rec.price_list_line_id;
    x_price_modifier_list_id       := l_x_FORMULA_LINES_rec.price_modifier_list_id;
    x_pricing_attribute            := l_x_FORMULA_LINES_rec.pricing_attribute;
    x_pricing_attribute_context    := l_x_FORMULA_LINES_rec.pricing_attribute_context;
    x_start_date_active            := l_x_FORMULA_LINES_rec.start_date_active;
    x_step_number                  := l_x_FORMULA_LINES_rec.step_number;
    x_reqd_flag                    := l_x_FORMULA_LINES_rec.reqd_flag;

    --  Load display out parameters if any

    l_FORMULA_LINES_val_rec := QP_Formula_Lines_Util.Get_Values
    (   p_FORMULA_LINES_rec           => l_x_FORMULA_LINES_rec
    );
    x_price_formula                := l_FORMULA_LINES_val_rec.price_formula;
    x_price_formula_line           := l_FORMULA_LINES_val_rec.price_formula_line;
    x_price_formula_line_type      := l_FORMULA_LINES_val_rec.price_formula_line_type;
    x_price_list_line              := l_FORMULA_LINES_val_rec.price_list_line;
    x_price_modifier_list          := l_FORMULA_LINES_val_rec.price_modifier_list;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_FORMULA_LINES_rec.db_flag := FND_API.G_FALSE;

    Write_FORMULA_LINES
    (   p_FORMULA_LINES_rec           => l_x_FORMULA_LINES_rec
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
,   p_price_formula_line_id         IN  NUMBER
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
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_numeric_constant              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_formula_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_formula_line_id         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_formula_line_type_code        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_line_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_modifier_list_id        OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_attribute             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pricing_attribute_context     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_step_number                   OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_formula                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_formula_line            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_formula_line_type       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_list_line               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_modifier_list           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_reqd_flag                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_FORMULA_LINES_rec           QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
l_old_FORMULA_LINES_rec       QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
l_FORMULA_LINES_val_rec       QP_Price_Formula_PUB.Formula_Lines_Val_Rec_Type;
l_FORMULA_LINES_tbl           QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;
l_old_FORMULA_LINES_tbl       QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_FORMULA_rec               QP_Price_Formula_PUB.Formula_Rec_Type;
l_x_FORMULA_LINES_rec         QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
l_x_FORMULA_LINES_tbl         QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;
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

    --  Read FORMULA_LINES from cache

    l_FORMULA_LINES_rec := Get_FORMULA_LINES
    (   p_db_record                   => FALSE
    ,   p_price_formula_line_id       => p_price_formula_line_id
    );

    l_old_FORMULA_LINES_rec        := l_FORMULA_LINES_rec;

    IF p_attr_id = QP_Formula_Lines_Util.G_END_DATE_ACTIVE THEN
        l_FORMULA_LINES_rec.end_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Formula_Lines_Util.G_NUMERIC_CONSTANT THEN
        l_FORMULA_LINES_rec.numeric_constant := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Formula_Lines_Util.G_PRICE_FORMULA THEN
        l_FORMULA_LINES_rec.price_formula_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Formula_Lines_Util.G_PRICE_FORMULA_LINE THEN
        l_FORMULA_LINES_rec.price_formula_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Formula_Lines_Util.G_PRICE_FORMULA_LINE_TYPE THEN
        l_FORMULA_LINES_rec.formula_line_type_code := p_attr_value;
    ELSIF p_attr_id = QP_Formula_Lines_Util.G_PRICE_LIST_LINE THEN
        l_FORMULA_LINES_rec.price_list_line_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Formula_Lines_Util.G_PRICE_MODIFIER_LIST THEN
        l_FORMULA_LINES_rec.price_modifier_list_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Formula_Lines_Util.G_PRICING_ATTRIBUTE THEN
        l_FORMULA_LINES_rec.pricing_attribute := p_attr_value;
    ELSIF p_attr_id = QP_Formula_Lines_Util.G_PRICING_ATTRIBUTE_CONTEXT THEN
        l_FORMULA_LINES_rec.pricing_attribute_context := p_attr_value;
    ELSIF p_attr_id = QP_Formula_Lines_Util.G_START_DATE_ACTIVE THEN
        l_FORMULA_LINES_rec.start_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Formula_Lines_Util.G_STEP_NUMBER THEN
        l_FORMULA_LINES_rec.step_number := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Formula_Lines_Util.G_REQD_FLAG THEN
        l_FORMULA_LINES_rec.reqd_flag := p_attr_value;
    ELSIF p_attr_id = QP_Formula_Lines_Util.G_ATTRIBUTE1
    OR     p_attr_id = QP_Formula_Lines_Util.G_ATTRIBUTE10
    OR     p_attr_id = QP_Formula_Lines_Util.G_ATTRIBUTE11
    OR     p_attr_id = QP_Formula_Lines_Util.G_ATTRIBUTE12
    OR     p_attr_id = QP_Formula_Lines_Util.G_ATTRIBUTE13
    OR     p_attr_id = QP_Formula_Lines_Util.G_ATTRIBUTE14
    OR     p_attr_id = QP_Formula_Lines_Util.G_ATTRIBUTE15
    OR     p_attr_id = QP_Formula_Lines_Util.G_ATTRIBUTE2
    OR     p_attr_id = QP_Formula_Lines_Util.G_ATTRIBUTE3
    OR     p_attr_id = QP_Formula_Lines_Util.G_ATTRIBUTE4
    OR     p_attr_id = QP_Formula_Lines_Util.G_ATTRIBUTE5
    OR     p_attr_id = QP_Formula_Lines_Util.G_ATTRIBUTE6
    OR     p_attr_id = QP_Formula_Lines_Util.G_ATTRIBUTE7
    OR     p_attr_id = QP_Formula_Lines_Util.G_ATTRIBUTE8
    OR     p_attr_id = QP_Formula_Lines_Util.G_ATTRIBUTE9
    OR     p_attr_id = QP_Formula_Lines_Util.G_CONTEXT
    THEN

        l_FORMULA_LINES_rec.attribute1 := p_attribute1;
        l_FORMULA_LINES_rec.attribute10 := p_attribute10;
        l_FORMULA_LINES_rec.attribute11 := p_attribute11;
        l_FORMULA_LINES_rec.attribute12 := p_attribute12;
        l_FORMULA_LINES_rec.attribute13 := p_attribute13;
        l_FORMULA_LINES_rec.attribute14 := p_attribute14;
        l_FORMULA_LINES_rec.attribute15 := p_attribute15;
        l_FORMULA_LINES_rec.attribute2 := p_attribute2;
        l_FORMULA_LINES_rec.attribute3 := p_attribute3;
        l_FORMULA_LINES_rec.attribute4 := p_attribute4;
        l_FORMULA_LINES_rec.attribute5 := p_attribute5;
        l_FORMULA_LINES_rec.attribute6 := p_attribute6;
        l_FORMULA_LINES_rec.attribute7 := p_attribute7;
        l_FORMULA_LINES_rec.attribute8 := p_attribute8;
        l_FORMULA_LINES_rec.attribute9 := p_attribute9;
        l_FORMULA_LINES_rec.context    := p_context;

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

    IF FND_API.To_Boolean(l_FORMULA_LINES_rec.db_flag) THEN
        l_FORMULA_LINES_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_FORMULA_LINES_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate FORMULA_LINES table

    l_FORMULA_LINES_tbl(1) := l_FORMULA_LINES_rec;
    l_old_FORMULA_LINES_tbl(1) := l_old_FORMULA_LINES_rec;

    --  Call QP_Price_Formula_PVT.Process_Price_Formula

    QP_Price_Formula_PVT.Process_Price_Formula
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_FORMULA_LINES_tbl           => l_FORMULA_LINES_tbl
    ,   p_old_FORMULA_LINES_tbl       => l_old_FORMULA_LINES_tbl
    ,   x_FORMULA_rec                 => l_x_FORMULA_rec
    ,   x_FORMULA_LINES_tbl           => l_x_FORMULA_LINES_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl

    l_x_FORMULA_LINES_rec := l_x_FORMULA_LINES_tbl(1);

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
    x_end_date_active              := FND_API.G_MISS_DATE;
    x_numeric_constant             := FND_API.G_MISS_NUM;
    x_price_formula_id             := FND_API.G_MISS_NUM;
    x_price_formula_line_id        := FND_API.G_MISS_NUM;
    x_formula_line_type_code       := FND_API.G_MISS_CHAR;
    x_price_list_line_id           := FND_API.G_MISS_NUM;
    x_price_modifier_list_id       := FND_API.G_MISS_NUM;
    x_pricing_attribute            := FND_API.G_MISS_CHAR;
    x_pricing_attribute_context    := FND_API.G_MISS_CHAR;
    x_start_date_active            := FND_API.G_MISS_DATE;
    x_step_number                  := FND_API.G_MISS_NUM;
    x_price_formula                := FND_API.G_MISS_CHAR;
    x_price_formula_line           := FND_API.G_MISS_CHAR;
    x_price_formula_line_type      := FND_API.G_MISS_CHAR;
    x_price_list_line              := FND_API.G_MISS_CHAR;
    x_price_modifier_list          := FND_API.G_MISS_CHAR;
    x_reqd_flag                    := FND_API.G_MISS_CHAR;

    --  Load display out parameters if any

    l_FORMULA_LINES_val_rec := QP_Formula_Lines_Util.Get_Values
    (   p_FORMULA_LINES_rec           => l_x_FORMULA_LINES_rec
    ,   p_old_FORMULA_LINES_rec       => l_FORMULA_LINES_rec
    );

    --  Return changed attributes.

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.attribute1,
                            l_FORMULA_LINES_rec.attribute1)
    THEN
        x_attribute1 := l_x_FORMULA_LINES_rec.attribute1;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.attribute10,
                            l_FORMULA_LINES_rec.attribute10)
    THEN
        x_attribute10 := l_x_FORMULA_LINES_rec.attribute10;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.attribute11,
                            l_FORMULA_LINES_rec.attribute11)
    THEN
        x_attribute11 := l_x_FORMULA_LINES_rec.attribute11;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.attribute12,
                            l_FORMULA_LINES_rec.attribute12)
    THEN
        x_attribute12 := l_x_FORMULA_LINES_rec.attribute12;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.attribute13,
                            l_FORMULA_LINES_rec.attribute13)
    THEN
        x_attribute13 := l_x_FORMULA_LINES_rec.attribute13;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.attribute14,
                            l_FORMULA_LINES_rec.attribute14)
    THEN
        x_attribute14 := l_x_FORMULA_LINES_rec.attribute14;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.attribute15,
                            l_FORMULA_LINES_rec.attribute15)
    THEN
        x_attribute15 := l_x_FORMULA_LINES_rec.attribute15;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.attribute2,
                            l_FORMULA_LINES_rec.attribute2)
    THEN
        x_attribute2 := l_x_FORMULA_LINES_rec.attribute2;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.attribute3,
                            l_FORMULA_LINES_rec.attribute3)
    THEN
        x_attribute3 := l_x_FORMULA_LINES_rec.attribute3;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.attribute4,
                            l_FORMULA_LINES_rec.attribute4)
    THEN
        x_attribute4 := l_x_FORMULA_LINES_rec.attribute4;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.attribute5,
                            l_FORMULA_LINES_rec.attribute5)
    THEN
        x_attribute5 := l_x_FORMULA_LINES_rec.attribute5;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.attribute6,
                            l_FORMULA_LINES_rec.attribute6)
    THEN
        x_attribute6 := l_x_FORMULA_LINES_rec.attribute6;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.attribute7,
                            l_FORMULA_LINES_rec.attribute7)
    THEN
        x_attribute7 := l_x_FORMULA_LINES_rec.attribute7;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.attribute8,
                            l_FORMULA_LINES_rec.attribute8)
    THEN
        x_attribute8 := l_x_FORMULA_LINES_rec.attribute8;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.attribute9,
                            l_FORMULA_LINES_rec.attribute9)
    THEN
        x_attribute9 := l_x_FORMULA_LINES_rec.attribute9;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.context,
                            l_FORMULA_LINES_rec.context)
    THEN
        x_context := l_x_FORMULA_LINES_rec.context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.end_date_active,
                            l_FORMULA_LINES_rec.end_date_active)
    THEN
        x_end_date_active := l_x_FORMULA_LINES_rec.end_date_active;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.numeric_constant,
                            l_FORMULA_LINES_rec.numeric_constant)
    THEN
        x_numeric_constant := l_x_FORMULA_LINES_rec.numeric_constant;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.reqd_flag,
                            l_FORMULA_LINES_rec.reqd_flag)
    THEN
        x_reqd_flag := l_x_FORMULA_LINES_rec.reqd_flag;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.price_formula_id,
                            l_FORMULA_LINES_rec.price_formula_id)
    THEN
        x_price_formula_id := l_x_FORMULA_LINES_rec.price_formula_id;
        x_price_formula := l_FORMULA_LINES_val_rec.price_formula;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.price_formula_line_id,
                            l_FORMULA_LINES_rec.price_formula_line_id)
    THEN
        x_price_formula_line_id := l_x_FORMULA_LINES_rec.price_formula_line_id;
        x_price_formula_line := l_FORMULA_LINES_val_rec.price_formula_line;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.formula_line_type_code,
                            l_FORMULA_LINES_rec.formula_line_type_code)
    THEN
        x_formula_line_type_code := l_x_FORMULA_LINES_rec.formula_line_type_code;
        x_price_formula_line_type := l_FORMULA_LINES_val_rec.price_formula_line_type;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.price_list_line_id,
                            l_FORMULA_LINES_rec.price_list_line_id)
    THEN
        x_price_list_line_id := l_x_FORMULA_LINES_rec.price_list_line_id;
        x_price_list_line := l_FORMULA_LINES_val_rec.price_list_line;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.price_modifier_list_id,
                            l_FORMULA_LINES_rec.price_modifier_list_id)
    THEN
        x_price_modifier_list_id := l_x_FORMULA_LINES_rec.price_modifier_list_id;
        x_price_modifier_list := l_FORMULA_LINES_val_rec.price_modifier_list;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.pricing_attribute,
                            l_FORMULA_LINES_rec.pricing_attribute)
    THEN
        x_pricing_attribute := l_x_FORMULA_LINES_rec.pricing_attribute;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.pricing_attribute_context,
                            l_FORMULA_LINES_rec.pricing_attribute_context)
    THEN
        x_pricing_attribute_context := l_x_FORMULA_LINES_rec.pricing_attribute_context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.start_date_active,
                            l_FORMULA_LINES_rec.start_date_active)
    THEN
        x_start_date_active := l_x_FORMULA_LINES_rec.start_date_active;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_LINES_rec.step_number,
                            l_FORMULA_LINES_rec.step_number)
    THEN
        x_step_number := l_x_FORMULA_LINES_rec.step_number;
    END IF;


    --  Write to cache.

    Write_FORMULA_LINES
    (   p_FORMULA_LINES_rec           => l_x_FORMULA_LINES_rec
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
,   p_price_formula_line_id         IN  NUMBER
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_created_by                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_date              OUT NOCOPY /* file.sql.39 change */ DATE
,   x_last_updated_by               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_login             OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_FORMULA_LINES_rec           QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
l_old_FORMULA_LINES_rec       QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
l_FORMULA_LINES_tbl           QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;
l_old_FORMULA_LINES_tbl       QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_FORMULA_rec               QP_Price_Formula_PUB.Formula_Rec_Type;
l_x_FORMULA_LINES_rec         QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
l_x_FORMULA_LINES_tbl         QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;
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

    --  Read FORMULA_LINES from cache

    l_old_FORMULA_LINES_rec := Get_FORMULA_LINES
    (   p_db_record                   => TRUE
    ,   p_price_formula_line_id       => p_price_formula_line_id
    );

    l_FORMULA_LINES_rec := Get_FORMULA_LINES
    (   p_db_record                   => FALSE
    ,   p_price_formula_line_id       => p_price_formula_line_id
    );

    --  Set Operation.

    IF FND_API.To_Boolean(l_FORMULA_LINES_rec.db_flag) THEN
        l_FORMULA_LINES_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_FORMULA_LINES_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate FORMULA_LINES table

    l_FORMULA_LINES_tbl(1) := l_FORMULA_LINES_rec;
    l_old_FORMULA_LINES_tbl(1) := l_old_FORMULA_LINES_rec;

    --  Call QP_Price_Formula_PVT.Process_Price_Formula

    QP_Price_Formula_PVT.Process_Price_Formula
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_FORMULA_LINES_tbl           => l_FORMULA_LINES_tbl
    ,   p_old_FORMULA_LINES_tbl       => l_old_FORMULA_LINES_tbl
    ,   x_FORMULA_rec                 => l_x_FORMULA_rec
    ,   x_FORMULA_LINES_tbl           => l_x_FORMULA_LINES_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.

    l_x_FORMULA_LINES_rec := l_x_FORMULA_LINES_tbl(1);

    x_creation_date                := l_x_FORMULA_LINES_rec.creation_date;
    x_created_by                   := l_x_FORMULA_LINES_rec.created_by;
    x_last_update_date             := l_x_FORMULA_LINES_rec.last_update_date;
    x_last_updated_by              := l_x_FORMULA_LINES_rec.last_updated_by;
    x_last_update_login            := l_x_FORMULA_LINES_rec.last_update_login;

    --  Clear FORMULA_LINES record cache

    Clear_FORMULA_LINES;

    --  Keep track of performed operations.

    l_old_FORMULA_LINES_rec.operation := l_FORMULA_LINES_rec.operation;


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
,   p_price_formula_line_id         IN  NUMBER
)
IS
l_FORMULA_LINES_rec           QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
l_FORMULA_LINES_tbl           QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_FORMULA_rec               QP_Price_Formula_PUB.Formula_Rec_Type;
l_x_FORMULA_LINES_rec         QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
l_x_FORMULA_LINES_tbl         QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;
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

    l_FORMULA_LINES_rec := Get_FORMULA_LINES
    (   p_db_record                   => TRUE
    ,   p_price_formula_line_id       => p_price_formula_line_id
    );

    --  Set Operation.

    l_FORMULA_LINES_rec.operation := QP_GLOBALS.G_OPR_DELETE;

    --  Populate FORMULA_LINES table

    l_FORMULA_LINES_tbl(1) := l_FORMULA_LINES_rec;

    --  Call QP_Price_Formula_PVT.Process_Price_Formula

    QP_Price_Formula_PVT.Process_Price_Formula
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_FORMULA_LINES_tbl           => l_FORMULA_LINES_tbl
    ,   x_FORMULA_rec                 => l_x_FORMULA_rec
    ,   x_FORMULA_LINES_tbl           => l_x_FORMULA_LINES_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear FORMULA_LINES record cache

    Clear_FORMULA_LINES;

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
l_x_FORMULA_rec               QP_Price_Formula_PUB.Formula_Rec_Type;
l_x_FORMULA_LINES_rec         QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
l_x_FORMULA_LINES_tbl         QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := QP_GLOBALS.G_ENTITY_FORMULA_LINES;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Call QP_Price_Formula_PVT.Process_Price_Formula

    QP_Price_Formula_PVT.Process_Price_Formula
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   x_FORMULA_rec                 => l_x_FORMULA_rec
    ,   x_FORMULA_LINES_tbl           => l_x_FORMULA_LINES_tbl
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
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_end_date_active               IN  DATE
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_numeric_constant              IN  NUMBER
,   p_price_formula_id              IN  NUMBER
,   p_price_formula_line_id         IN  NUMBER
,   p_formula_line_type_code        IN  VARCHAR2
,   p_price_list_line_id            IN  NUMBER
,   p_price_modifier_list_id        IN  NUMBER
,   p_pricing_attribute             IN  VARCHAR2
,   p_pricing_attribute_context     IN  VARCHAR2
,   p_start_date_active             IN  DATE
,   p_step_number                   IN  NUMBER
,   p_reqd_flag                     IN  VARCHAR2
)
IS
l_return_status               VARCHAR2(1);
l_FORMULA_LINES_rec           QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
l_FORMULA_LINES_tbl           QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;
l_x_FORMULA_rec               QP_Price_Formula_PUB.Formula_Rec_Type;
l_x_FORMULA_LINES_rec         QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
l_x_FORMULA_LINES_tbl         QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;
BEGIN

    --  Load FORMULA_LINES record

    l_FORMULA_LINES_rec.attribute1 := p_attribute1;
    l_FORMULA_LINES_rec.attribute10 := p_attribute10;
    l_FORMULA_LINES_rec.attribute11 := p_attribute11;
    l_FORMULA_LINES_rec.attribute12 := p_attribute12;
    l_FORMULA_LINES_rec.attribute13 := p_attribute13;
    l_FORMULA_LINES_rec.attribute14 := p_attribute14;
    l_FORMULA_LINES_rec.attribute15 := p_attribute15;
    l_FORMULA_LINES_rec.attribute2 := p_attribute2;
    l_FORMULA_LINES_rec.attribute3 := p_attribute3;
    l_FORMULA_LINES_rec.attribute4 := p_attribute4;
    l_FORMULA_LINES_rec.attribute5 := p_attribute5;
    l_FORMULA_LINES_rec.attribute6 := p_attribute6;
    l_FORMULA_LINES_rec.attribute7 := p_attribute7;
    l_FORMULA_LINES_rec.attribute8 := p_attribute8;
    l_FORMULA_LINES_rec.attribute9 := p_attribute9;
    l_FORMULA_LINES_rec.context    := p_context;
    l_FORMULA_LINES_rec.created_by := p_created_by;
    l_FORMULA_LINES_rec.creation_date := p_creation_date;
    l_FORMULA_LINES_rec.end_date_active := p_end_date_active;
    l_FORMULA_LINES_rec.last_updated_by := p_last_updated_by;
    l_FORMULA_LINES_rec.last_update_date := p_last_update_date;
    l_FORMULA_LINES_rec.last_update_login := p_last_update_login;
    l_FORMULA_LINES_rec.numeric_constant := p_numeric_constant;
    l_FORMULA_LINES_rec.price_formula_id := p_price_formula_id;
    l_FORMULA_LINES_rec.price_formula_line_id := p_price_formula_line_id;
    l_FORMULA_LINES_rec.formula_line_type_code := p_formula_line_type_code;
    l_FORMULA_LINES_rec.price_list_line_id := p_price_list_line_id;
    l_FORMULA_LINES_rec.price_modifier_list_id := p_price_modifier_list_id;
    l_FORMULA_LINES_rec.pricing_attribute := p_pricing_attribute;
    l_FORMULA_LINES_rec.pricing_attribute_context := p_pricing_attribute_context;
    l_FORMULA_LINES_rec.start_date_active := p_start_date_active;
    l_FORMULA_LINES_rec.step_number := p_step_number;
    l_FORMULA_LINES_rec.reqd_flag := p_reqd_flag;

    l_FORMULA_LINES_rec.operation := QP_GLOBALS.G_OPR_LOCK;

    --  Populate FORMULA_LINES table

    l_FORMULA_LINES_tbl(1) := l_FORMULA_LINES_rec;

    --  Call QP_Price_Formula_PVT.Lock_Price_Formula

    QP_Price_Formula_PVT.Lock_Price_Formula
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_FORMULA_LINES_tbl           => l_FORMULA_LINES_tbl
    ,   x_FORMULA_rec                 => l_x_FORMULA_rec
    ,   x_FORMULA_LINES_tbl           => l_x_FORMULA_LINES_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_FORMULA_LINES_rec.db_flag := FND_API.G_TRUE;

        Write_FORMULA_LINES
        (   p_FORMULA_LINES_rec           => l_x_FORMULA_LINES_rec
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

--  Procedures maintaining FORMULA_LINES record cache.

PROCEDURE Write_FORMULA_LINES
(   p_FORMULA_LINES_rec             IN  QP_Price_Formula_PUB.Formula_Lines_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
BEGIN

    g_FORMULA_LINES_rec := p_FORMULA_LINES_rec;

    IF p_db_record THEN

        g_db_FORMULA_LINES_rec := p_FORMULA_LINES_rec;

    END IF;

END Write_Formula_Lines;

FUNCTION Get_FORMULA_LINES
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_price_formula_line_id         IN  NUMBER
)
RETURN QP_Price_Formula_PUB.Formula_Lines_Rec_Type
IS
BEGIN

    IF  p_price_formula_line_id <> g_FORMULA_LINES_rec.price_formula_line_id
    THEN

        --  Query row from DB

        g_FORMULA_LINES_rec := QP_Formula_Lines_Util.Query_Row
        (   p_price_formula_line_id       => p_price_formula_line_id
        );

        g_FORMULA_LINES_rec.db_flag    := FND_API.G_TRUE;

        --  Load DB record

        g_db_FORMULA_LINES_rec         := g_FORMULA_LINES_rec;

    END IF;

    IF p_db_record THEN

        RETURN g_db_FORMULA_LINES_rec;

    ELSE

        RETURN g_FORMULA_LINES_rec;

    END IF;

END Get_Formula_Lines;

PROCEDURE Clear_Formula_Lines
IS
BEGIN

    g_FORMULA_LINES_rec            := QP_Price_Formula_PUB.G_MISS_FORMULA_LINES_REC;
    g_db_FORMULA_LINES_rec         := QP_Price_Formula_PUB.G_MISS_FORMULA_LINES_REC;

END Clear_Formula_Lines;

END QP_QP_Form_Formula_Lines;

/
