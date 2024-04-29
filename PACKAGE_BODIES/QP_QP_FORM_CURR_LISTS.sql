--------------------------------------------------------
--  DDL for Package Body QP_QP_FORM_CURR_LISTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_QP_FORM_CURR_LISTS" AS
/* $Header: QPXFCURB.pls 120.1 2005/06/13 00:35:52 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_QP_Form_Curr_Lists';

--  Global variables holding cached record.

g_CURR_LISTS_rec              QP_Currency_PUB.Curr_Lists_Rec_Type;
g_db_CURR_LISTS_rec           QP_Currency_PUB.Curr_Lists_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_CURR_LISTS
(   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

FUNCTION Get_CURR_LISTS
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_currency_header_id            IN  NUMBER
)
RETURN QP_Currency_PUB.Curr_Lists_Rec_Type;

PROCEDURE Clear_CURR_LISTS;

--  Global variable holding performed operations.

g_opr__tbl                    QP_Currency_PUB.Curr_Lists_Tbl_Type;

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
,   x_base_currency_code            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_header_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_description                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_name                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
-- ,   x_row_id                        OUT NOCOPY /* file.sql.39 change */ ROWID  -- Commented by Sunil
,   x_base_currency                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_header               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_base_rounding_factor          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_base_markup_operator          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_base_markup_value             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_base_markup_formula           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_base_markup_formula_id        OUT NOCOPY /* file.sql.39 change */ NUMBER
-- ,   x_row                           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_CURR_LISTS_rec              QP_Currency_PUB.Curr_Lists_Rec_Type;
l_CURR_LISTS_val_rec          QP_Currency_PUB.Curr_Lists_Val_Rec_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_CURR_LISTS_rec            QP_Currency_PUB.Curr_Lists_Rec_Type;
l_x_CURR_DETAILS_rec          QP_Currency_PUB.Curr_Details_Rec_Type;
l_x_CURR_DETAILS_tbl          QP_Currency_PUB.Curr_Details_Tbl_Type;
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


    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

    l_CURR_LISTS_rec.attribute1                   := NULL;
    l_CURR_LISTS_rec.attribute10                  := NULL;
    l_CURR_LISTS_rec.attribute11                  := NULL;
    l_CURR_LISTS_rec.attribute12                  := NULL;
    l_CURR_LISTS_rec.attribute13                  := NULL;
    l_CURR_LISTS_rec.attribute14                  := NULL;
    l_CURR_LISTS_rec.attribute15                  := NULL;
    l_CURR_LISTS_rec.attribute2                   := NULL;
    l_CURR_LISTS_rec.attribute3                   := NULL;
    l_CURR_LISTS_rec.attribute4                   := NULL;
    l_CURR_LISTS_rec.attribute5                   := NULL;
    l_CURR_LISTS_rec.attribute6                   := NULL;
    l_CURR_LISTS_rec.attribute7                   := NULL;
    l_CURR_LISTS_rec.attribute8                   := NULL;
    l_CURR_LISTS_rec.attribute9                   := NULL;
    l_CURR_LISTS_rec.context                      := NULL;

    --  Set Operation to Create

    l_CURR_LISTS_rec.operation := QP_GLOBALS.G_OPR_CREATE;

    -- oe_debug_pub.add('Calling  QP_Currency_PVT.Process_Currency from F package; Default_Attributes');
    --  Call QP_Currency_PVT.Process_Currency

    QP_Currency_PVT.Process_Currency
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_CURR_LISTS_rec              => l_CURR_LISTS_rec
    ,   x_CURR_LISTS_rec              => l_x_CURR_LISTS_rec
    ,   x_CURR_DETAILS_tbl            => l_x_CURR_DETAILS_tbl
    );
    -- oe_debug_pub.add('AFTER Calling  QP_Currency_PVT.Process_Currency from F package; Default_Attributes');

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.

    x_attribute1                   := l_x_CURR_LISTS_rec.attribute1;
    x_attribute10                  := l_x_CURR_LISTS_rec.attribute10;
    x_attribute11                  := l_x_CURR_LISTS_rec.attribute11;
    x_attribute12                  := l_x_CURR_LISTS_rec.attribute12;
    x_attribute13                  := l_x_CURR_LISTS_rec.attribute13;
    x_attribute14                  := l_x_CURR_LISTS_rec.attribute14;
    x_attribute15                  := l_x_CURR_LISTS_rec.attribute15;
    x_attribute2                   := l_x_CURR_LISTS_rec.attribute2;
    x_attribute3                   := l_x_CURR_LISTS_rec.attribute3;
    x_attribute4                   := l_x_CURR_LISTS_rec.attribute4;
    x_attribute5                   := l_x_CURR_LISTS_rec.attribute5;
    x_attribute6                   := l_x_CURR_LISTS_rec.attribute6;
    x_attribute7                   := l_x_CURR_LISTS_rec.attribute7;
    x_attribute8                   := l_x_CURR_LISTS_rec.attribute8;
    x_attribute9                   := l_x_CURR_LISTS_rec.attribute9;
    x_base_currency_code           := l_x_CURR_LISTS_rec.base_currency_code;
    x_context                      := l_x_CURR_LISTS_rec.context;
    x_currency_header_id           := l_x_CURR_LISTS_rec.currency_header_id;
    x_description                  := l_x_CURR_LISTS_rec.description;
    x_name                         := l_x_CURR_LISTS_rec.name;
    x_base_rounding_factor         := l_x_CURR_LISTS_rec.base_rounding_factor;
    x_base_markup_operator         := l_x_CURR_LISTS_rec.base_markup_operator;
    x_base_markup_value            := l_x_CURR_LISTS_rec.base_markup_value;
    x_base_markup_formula_id       := l_x_CURR_LISTS_rec.base_markup_formula_id;
    -- x_row_id                       := l_x_CURR_LISTS_rec.row_id; -- Commented by Sunil

    --  Load display out parameters if any

    l_CURR_LISTS_val_rec := QP_Curr_Lists_Util.Get_Values
    (   p_CURR_LISTS_rec              => l_x_CURR_LISTS_rec
    );
    x_base_currency                := l_CURR_LISTS_val_rec.base_currency;
    x_currency_header              := l_CURR_LISTS_val_rec.currency_header;
    x_base_markup_formula          := l_CURR_LISTS_val_rec.base_markup_formula;
    -- x_row                          := l_CURR_LISTS_val_rec.row;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_CURR_LISTS_rec.db_flag := FND_API.G_FALSE;

    Write_CURR_LISTS
    (   p_CURR_LISTS_rec              => l_x_CURR_LISTS_rec
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
,   p_currency_header_id            IN  NUMBER
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
,   x_base_currency_code            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_header_id            OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_description                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_name                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
-- ,   x_row_id                        OUT NOCOPY /* file.sql.39 change */ ROWID -- Commented by Sunil
,   x_base_currency                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_currency_header               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_base_rounding_factor          OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_base_markup_operator          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_base_markup_value             OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_base_markup_formula           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_base_markup_formula_id        OUT NOCOPY /* file.sql.39 change */ NUMBER
-- ,   x_row                           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_CURR_LISTS_rec              QP_Currency_PUB.Curr_Lists_Rec_Type;
l_old_CURR_LISTS_rec          QP_Currency_PUB.Curr_Lists_Rec_Type;
l_CURR_LISTS_val_rec          QP_Currency_PUB.Curr_Lists_Val_Rec_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_CURR_LISTS_rec            QP_Currency_PUB.Curr_Lists_Rec_Type;
l_x_CURR_DETAILS_rec          QP_Currency_PUB.Curr_Details_Rec_Type;
l_x_CURR_DETAILS_tbl          QP_Currency_PUB.Curr_Details_Tbl_Type;
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

    --  Read CURR_LISTS from cache

    -- oe_debug_pub.add('BEFORE CALLING Get_CURR_LISTS in Change_Attribute');
    l_CURR_LISTS_rec := Get_CURR_LISTS
    (   p_db_record                   => FALSE
    ,   p_currency_header_id          => p_currency_header_id
    );

    -- oe_debug_pub.add('Cache HDR_ID: '||NVL(g_CURR_LISTS_rec.currency_header_id, -999999));
    -- oe_debug_pub.add('Passed HDR_ID: '||p_currency_header_id);
    -- oe_debug_pub.add('Passed Attribute_id: '||p_attr_id);
    -- oe_debug_pub.add('Passed Attribute_id: '||p_attr_value);
    -- oe_debug_pub.add('DB_FLAG:'|| l_CURR_LISTS_rec.db_flag );

    l_old_CURR_LISTS_rec           := l_CURR_LISTS_rec;

    IF p_attr_id = QP_Curr_Lists_Util.G_BASE_CURRENCY THEN
        l_CURR_LISTS_rec.base_currency_code := p_attr_value;
    ELSIF p_attr_id = QP_Curr_Lists_Util.G_CURRENCY_HEADER THEN
        l_CURR_LISTS_rec.currency_header_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Curr_Lists_Util.G_DESCRIPTION THEN
        l_CURR_LISTS_rec.description := p_attr_value;
    ELSIF p_attr_id = QP_Curr_Lists_Util.G_NAME THEN
        l_CURR_LISTS_rec.name := p_attr_value;
    ELSIF p_attr_id = QP_Curr_Lists_Util.G_base_rounding_factor THEN
        l_CURR_LISTS_rec.base_rounding_factor := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Curr_Lists_Util.G_base_markup_operator THEN
        l_CURR_LISTS_rec.base_markup_operator := p_attr_value;
    ELSIF p_attr_id = QP_Curr_Lists_Util.G_base_markup_value THEN
        -- oe_debug_pub.add('Assigning Base Markup Value');
        l_CURR_LISTS_rec.base_markup_value := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Curr_Lists_Util.G_base_markup_formula THEN
        l_CURR_LISTS_rec.base_markup_formula_id := TO_NUMBER(p_attr_value);
    -- ELSIF p_attr_id = QP_Curr_Lists_Util.G_ROW THEN
        -- l_CURR_LISTS_rec.row_idELSIF
    ELSIF p_attr_id = QP_Curr_Lists_Util.G_ATTRIBUTE1
    OR     p_attr_id = QP_Curr_Lists_Util.G_ATTRIBUTE10
    OR     p_attr_id = QP_Curr_Lists_Util.G_ATTRIBUTE11
    OR     p_attr_id = QP_Curr_Lists_Util.G_ATTRIBUTE12
    OR     p_attr_id = QP_Curr_Lists_Util.G_ATTRIBUTE13
    OR     p_attr_id = QP_Curr_Lists_Util.G_ATTRIBUTE14
    OR     p_attr_id = QP_Curr_Lists_Util.G_ATTRIBUTE15
    OR     p_attr_id = QP_Curr_Lists_Util.G_ATTRIBUTE2
    OR     p_attr_id = QP_Curr_Lists_Util.G_ATTRIBUTE3
    OR     p_attr_id = QP_Curr_Lists_Util.G_ATTRIBUTE4
    OR     p_attr_id = QP_Curr_Lists_Util.G_ATTRIBUTE5
    OR     p_attr_id = QP_Curr_Lists_Util.G_ATTRIBUTE6
    OR     p_attr_id = QP_Curr_Lists_Util.G_ATTRIBUTE7
    OR     p_attr_id = QP_Curr_Lists_Util.G_ATTRIBUTE8
    OR     p_attr_id = QP_Curr_Lists_Util.G_ATTRIBUTE9
    OR     p_attr_id = QP_Curr_Lists_Util.G_CONTEXT
    THEN

        l_CURR_LISTS_rec.attribute1    := p_attribute1;
        l_CURR_LISTS_rec.attribute10   := p_attribute10;
        l_CURR_LISTS_rec.attribute11   := p_attribute11;
        l_CURR_LISTS_rec.attribute12   := p_attribute12;
        l_CURR_LISTS_rec.attribute13   := p_attribute13;
        l_CURR_LISTS_rec.attribute14   := p_attribute14;
        l_CURR_LISTS_rec.attribute15   := p_attribute15;
        l_CURR_LISTS_rec.attribute2    := p_attribute2;
        l_CURR_LISTS_rec.attribute3    := p_attribute3;
        l_CURR_LISTS_rec.attribute4    := p_attribute4;
        l_CURR_LISTS_rec.attribute5    := p_attribute5;
        l_CURR_LISTS_rec.attribute6    := p_attribute6;
        l_CURR_LISTS_rec.attribute7    := p_attribute7;
        l_CURR_LISTS_rec.attribute8    := p_attribute8;
        l_CURR_LISTS_rec.attribute9    := p_attribute9;
        l_CURR_LISTS_rec.context       := p_context;

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

    IF FND_API.To_Boolean(l_CURR_LISTS_rec.db_flag) THEN
        l_CURR_LISTS_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_CURR_LISTS_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Call QP_Currency_PVT.Process_Currency
    -- oe_debug_pub.add('Calling  QP_Currency_PVT.Process_Currency from F package; Change_Attribute');

    QP_Currency_PVT.Process_Currency
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_CURR_LISTS_rec              => l_CURR_LISTS_rec
    ,   p_old_CURR_LISTS_rec          => l_old_CURR_LISTS_rec
    ,   x_CURR_LISTS_rec              => l_x_CURR_LISTS_rec
    ,   x_CURR_DETAILS_tbl            => l_x_CURR_DETAILS_tbl
    );
    -- oe_debug_pub.add('AFTER Calling  QP_Currency_PVT.Process_Currency from F package; Change_Attribute');
    -- oe_debug_pub.add('AFTER Calling  QP_Currency_PVT.Process_Currency from F package; Change_Attribute; l_x_CURR_LISTS_rec.base_markup_value: '||l_x_CURR_LISTS_rec.base_markup_value);
    -- oe_debug_pub.add('AFTER Calling  QP_Currency_PVT.Process_Currency from F package; Change_Attribute; l_x_CURR_LISTS_rec.Description: '||l_x_CURR_LISTS_rec.Description);

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
    x_base_currency_code           := FND_API.G_MISS_CHAR;
    x_context                      := FND_API.G_MISS_CHAR;
    x_currency_header_id           := FND_API.G_MISS_NUM;
    x_description                  := FND_API.G_MISS_CHAR;
    x_name                         := FND_API.G_MISS_CHAR;
    -- x_row_id                       := FND_API.G_MISS_CHAR; -- Commented by Sunil
    x_base_currency                := FND_API.G_MISS_CHAR;
    x_currency_header              := FND_API.G_MISS_CHAR;
    -- x_row                          := FND_API.G_MISS_CHAR;
    x_base_rounding_factor         := FND_API.G_MISS_NUM;
    x_base_markup_operator         := FND_API.G_MISS_CHAR;
    x_base_markup_value            := FND_API.G_MISS_NUM;
    x_base_markup_formula_id       := FND_API.G_MISS_NUM;
    x_base_markup_formula          := FND_API.G_MISS_CHAR;


    -- oe_debug_pub.add('%%Inside F- Change_Attribute; CHECK-POINT-1');
    --  Load display out parameters if any

    l_CURR_LISTS_val_rec := QP_Curr_Lists_Util.Get_Values
    (   p_CURR_LISTS_rec              => l_x_CURR_LISTS_rec
    ,   p_old_CURR_LISTS_rec          => l_CURR_LISTS_rec
    );

    -- oe_debug_pub.add('%%Inside F- Change_Attribute; CHECK-POINT-2');
    --  Return changed attributes.

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.attribute1,
                            l_CURR_LISTS_rec.attribute1)
    THEN
        x_attribute1 := l_x_CURR_LISTS_rec.attribute1;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.attribute10,
                            l_CURR_LISTS_rec.attribute10)
    THEN
        x_attribute10 := l_x_CURR_LISTS_rec.attribute10;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.attribute11,
                            l_CURR_LISTS_rec.attribute11)
    THEN
        x_attribute11 := l_x_CURR_LISTS_rec.attribute11;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.attribute12,
                            l_CURR_LISTS_rec.attribute12)
    THEN
        x_attribute12 := l_x_CURR_LISTS_rec.attribute12;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.attribute13,
                            l_CURR_LISTS_rec.attribute13)
    THEN
        x_attribute13 := l_x_CURR_LISTS_rec.attribute13;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.attribute14,
                            l_CURR_LISTS_rec.attribute14)
    THEN
        x_attribute14 := l_x_CURR_LISTS_rec.attribute14;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.attribute15,
                            l_CURR_LISTS_rec.attribute15)
    THEN
        x_attribute15 := l_x_CURR_LISTS_rec.attribute15;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.attribute2,
                            l_CURR_LISTS_rec.attribute2)
    THEN
        x_attribute2 := l_x_CURR_LISTS_rec.attribute2;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.attribute3,
                            l_CURR_LISTS_rec.attribute3)
    THEN
        x_attribute3 := l_x_CURR_LISTS_rec.attribute3;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.attribute4,
                            l_CURR_LISTS_rec.attribute4)
    THEN
        x_attribute4 := l_x_CURR_LISTS_rec.attribute4;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.attribute5,
                            l_CURR_LISTS_rec.attribute5)
    THEN
        x_attribute5 := l_x_CURR_LISTS_rec.attribute5;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.attribute6,
                            l_CURR_LISTS_rec.attribute6)
    THEN
        x_attribute6 := l_x_CURR_LISTS_rec.attribute6;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.attribute7,
                            l_CURR_LISTS_rec.attribute7)
    THEN
        x_attribute7 := l_x_CURR_LISTS_rec.attribute7;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.attribute8,
                            l_CURR_LISTS_rec.attribute8)
    THEN
        x_attribute8 := l_x_CURR_LISTS_rec.attribute8;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.attribute9,
                            l_CURR_LISTS_rec.attribute9)
    THEN
        x_attribute9 := l_x_CURR_LISTS_rec.attribute9;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.base_currency_code,
                            l_CURR_LISTS_rec.base_currency_code)
    THEN
        x_base_currency_code := l_x_CURR_LISTS_rec.base_currency_code;
        x_base_currency := l_CURR_LISTS_val_rec.base_currency;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.context,
                            l_CURR_LISTS_rec.context)
    THEN
        x_context := l_x_CURR_LISTS_rec.context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.currency_header_id,
                            l_CURR_LISTS_rec.currency_header_id)
    THEN
        x_currency_header_id := l_x_CURR_LISTS_rec.currency_header_id;
        x_currency_header := l_CURR_LISTS_val_rec.currency_header;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.description,
                            l_CURR_LISTS_rec.description)
    THEN
        x_description := l_x_CURR_LISTS_rec.description;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.name,
                            l_CURR_LISTS_rec.name)
    THEN
        x_name := l_x_CURR_LISTS_rec.name;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.base_rounding_factor,
                            l_CURR_LISTS_rec.base_rounding_factor)
    THEN
        x_base_rounding_factor := l_x_CURR_LISTS_rec.base_rounding_factor;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.base_markup_operator,
                            l_CURR_LISTS_rec.base_markup_operator)
    THEN
        x_base_markup_operator := l_x_CURR_LISTS_rec.base_markup_operator;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.base_markup_value,
                            l_CURR_LISTS_rec.base_markup_value)
    THEN
        x_base_markup_value := l_x_CURR_LISTS_rec.base_markup_value;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.base_markup_formula_id,
                            l_CURR_LISTS_rec.base_markup_formula_id)
    THEN
        x_base_markup_formula_id := l_x_CURR_LISTS_rec.base_markup_formula_id;
        x_base_markup_formula := l_CURR_LISTS_val_rec.base_markup_formula;
    END IF;
    -- oe_debug_pub.add('%%Inside F- Change_Attribute; CHECK-POINT-3');

/* Commented by Sunil
    IF NOT QP_GLOBALS.Equal(l_x_CURR_LISTS_rec.row_id,
                            l_CURR_LISTS_rec.row_id)
    THEN
        x_row_id := l_x_CURR_LISTS_rec.row_id;
        x_row := l_CURR_LISTS_val_rec.row;
    END IF;
   Commented by Sunil */


    -- oe_debug_pub.add('%%Inside F- Change_Attribute; l_x_CURR_LISTS_rec.base_markup_value: '||l_x_CURR_LISTS_rec.base_markup_value);
    -- oe_debug_pub.add('%%Inside F- Change_Attribute; l_x_CURR_LISTS_rec.description: '||l_x_CURR_LISTS_rec.description);
    --  Write to cache.

    Write_CURR_LISTS
    (   p_CURR_LISTS_rec              => l_x_CURR_LISTS_rec
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
,   p_currency_header_id            IN  NUMBER
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_created_by                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_date              OUT NOCOPY /* file.sql.39 change */ DATE
,   x_last_updated_by               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_login             OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_CURR_LISTS_rec              QP_Currency_PUB.Curr_Lists_Rec_Type;
l_old_CURR_LISTS_rec          QP_Currency_PUB.Curr_Lists_Rec_Type;
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

    --  Read CURR_LISTS from cache

    l_old_CURR_LISTS_rec := Get_CURR_LISTS
    (   p_db_record                   => TRUE
    ,   p_currency_header_id          => p_currency_header_id
    );

    l_CURR_LISTS_rec := Get_CURR_LISTS
    (   p_db_record                   => FALSE
    ,   p_currency_header_id          => p_currency_header_id
    );

    -- oe_debug_pub.add('Inside QPXFCURB; After calling get_curr_lists; l_CURR_LISTS_rec.base_markup_value: '||l_CURR_LISTS_rec.base_markup_value);
    -- oe_debug_pub.add('Inside QPXFCURB; After calling get_curr_lists; l_CURR_LISTS_rec.description: '||l_CURR_LISTS_rec.description);

    --  Set Operation.

    IF FND_API.To_Boolean(l_CURR_LISTS_rec.db_flag) THEN
        l_CURR_LISTS_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_CURR_LISTS_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Call QP_Currency_PVT.Process_Currency

    -- oe_debug_pub.add('Calling  QP_Currency_PVT.Process_Currency from F package; Validate_and_Write');
    QP_Currency_PVT.Process_Currency
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_CURR_LISTS_rec              => l_CURR_LISTS_rec
    ,   p_old_CURR_LISTS_rec          => l_old_CURR_LISTS_rec
    ,   x_CURR_LISTS_rec              => l_x_CURR_LISTS_rec
    ,   x_CURR_DETAILS_tbl            => l_x_CURR_DETAILS_tbl
    );
    -- oe_debug_pub.add('AFTER Calling  QP_Currency_PVT.Process_Currency from F package; Validate_and_Write');

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.


    x_creation_date                := l_x_CURR_LISTS_rec.creation_date;
    x_created_by                   := l_x_CURR_LISTS_rec.created_by;
    x_last_update_date             := l_x_CURR_LISTS_rec.last_update_date;
    x_last_updated_by              := l_x_CURR_LISTS_rec.last_updated_by;
    x_last_update_login            := l_x_CURR_LISTS_rec.last_update_login;

    --  Clear CURR_LISTS record cache

    Clear_CURR_LISTS;

    --  Keep track of performed operations.

    l_old_CURR_LISTS_rec.operation := l_CURR_LISTS_rec.operation;


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
,   p_currency_header_id            IN  NUMBER
)
IS
l_CURR_LISTS_rec              QP_Currency_PUB.Curr_Lists_Rec_Type;
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

    l_CURR_LISTS_rec := Get_CURR_LISTS
    (   p_db_record                   => TRUE
    ,   p_currency_header_id          => p_currency_header_id
    );

    --  Set Operation.

    l_CURR_LISTS_rec.operation := QP_GLOBALS.G_OPR_DELETE;

    -- oe_debug_pub.add('Calling  QP_Currency_PVT.Process_Currency from F package; Delete_Row');
    --  Call QP_Currency_PVT.Process_Currency

    QP_Currency_PVT.Process_Currency
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_CURR_LISTS_rec              => l_CURR_LISTS_rec
    ,   x_CURR_LISTS_rec              => l_x_CURR_LISTS_rec
    ,   x_CURR_DETAILS_tbl            => l_x_CURR_DETAILS_tbl
    );
    -- oe_debug_pub.add('AFTER Calling  QP_Currency_PVT.Process_Currency from F package; Delete_Row');

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear CURR_LISTS record cache

    Clear_CURR_LISTS;

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
    l_control_rec.process_entity       := QP_GLOBALS.G_ENTITY_CURR_LISTS;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    -- oe_debug_pub.add('Calling  QP_Currency_PVT.Process_Currency from F package; Process_Entity');
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
    -- oe_debug_pub.add('AFTER Calling  QP_Currency_PVT.Process_Currency from F package; Process_Entity');

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

--  Procedure       Process_Object
--

PROCEDURE Process_Object
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
    l_control_rec.process_entity       := QP_GLOBALS.G_ENTITY_ALL;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := TRUE;

    -- oe_debug_pub.add('Calling  QP_Currency_PVT.Process_Currency from F package; Process_Object');
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
    -- oe_debug_pub.add('AFTER Calling  QP_Currency_PVT.Process_Currency from F package; Process_Object');

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
            ,   'Process_Object'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Object;

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
,   p_base_currency_code            IN  VARCHAR2
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_currency_header_id            IN  NUMBER
,   p_description                   IN  VARCHAR2
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_name                          IN  VARCHAR2
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_request_id                    IN  NUMBER
,   p_base_rounding_factor          IN NUMBER
,   p_base_markup_operator          IN VARCHAR2
,   p_base_markup_value             IN NUMBER
,   p_base_markup_formula_id        IN NUMBER
-- ,   p_row_id                        IN  ROWID  -- Commented by Sunil
)
IS
l_return_status               VARCHAR2(1);
l_CURR_LISTS_rec              QP_Currency_PUB.Curr_Lists_Rec_Type;
l_x_CURR_LISTS_rec            QP_Currency_PUB.Curr_Lists_Rec_Type;
l_x_CURR_DETAILS_rec          QP_Currency_PUB.Curr_Details_Rec_Type;
l_x_CURR_DETAILS_tbl          QP_Currency_PUB.Curr_Details_Tbl_Type;
BEGIN

    --  Load CURR_LISTS record

    l_CURR_LISTS_rec.attribute1    := p_attribute1;
    l_CURR_LISTS_rec.attribute10   := p_attribute10;
    l_CURR_LISTS_rec.attribute11   := p_attribute11;
    l_CURR_LISTS_rec.attribute12   := p_attribute12;
    l_CURR_LISTS_rec.attribute13   := p_attribute13;
    l_CURR_LISTS_rec.attribute14   := p_attribute14;
    l_CURR_LISTS_rec.attribute15   := p_attribute15;
    l_CURR_LISTS_rec.attribute2    := p_attribute2;
    l_CURR_LISTS_rec.attribute3    := p_attribute3;
    l_CURR_LISTS_rec.attribute4    := p_attribute4;
    l_CURR_LISTS_rec.attribute5    := p_attribute5;
    l_CURR_LISTS_rec.attribute6    := p_attribute6;
    l_CURR_LISTS_rec.attribute7    := p_attribute7;
    l_CURR_LISTS_rec.attribute8    := p_attribute8;
    l_CURR_LISTS_rec.attribute9    := p_attribute9;
    l_CURR_LISTS_rec.base_currency_code := p_base_currency_code;
    l_CURR_LISTS_rec.context       := p_context;
    l_CURR_LISTS_rec.created_by    := p_created_by;
    l_CURR_LISTS_rec.creation_date := p_creation_date;
    l_CURR_LISTS_rec.currency_header_id := p_currency_header_id;
    l_CURR_LISTS_rec.description   := p_description;
    l_CURR_LISTS_rec.last_updated_by := p_last_updated_by;
    l_CURR_LISTS_rec.last_update_date := p_last_update_date;
    l_CURR_LISTS_rec.last_update_login := p_last_update_login;
    l_CURR_LISTS_rec.name          := p_name;
    l_CURR_LISTS_rec.program_application_id := p_program_application_id;
    l_CURR_LISTS_rec.program_id    := p_program_id;
    l_CURR_LISTS_rec.program_update_date := p_program_update_date;
    l_CURR_LISTS_rec.request_id    := p_request_id;
    l_CURR_LISTS_rec.base_rounding_factor    := p_base_rounding_factor;
    l_CURR_LISTS_rec.base_markup_operator    := p_base_markup_operator;
    l_CURR_LISTS_rec.base_markup_value    := p_base_markup_value;
    l_CURR_LISTS_rec.base_markup_formula_id    := p_base_markup_formula_id;
    -- l_CURR_LISTS_rec.row_id        := p_row_id;  -- Commented by Sunil

    -- oe_debug_pub.add('Inside QPXFCURB Lock_Row; p_base_markup_value: '||p_base_markup_value);
    -- oe_debug_pub.add('Inside QPXFCURB Lock_Row; l_CURR_LISTS_rec.operation: '||l_CURR_LISTS_rec.operation);
    --  Call QP_Currency_PVT.Lock_Currency

    QP_Currency_PVT.Lock_Currency
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_CURR_LISTS_rec              => l_CURR_LISTS_rec
    ,   x_CURR_LISTS_rec              => l_x_CURR_LISTS_rec
    ,   x_CURR_DETAILS_tbl            => l_x_CURR_DETAILS_tbl
    );

    -- oe_debug_pub.add('Inside QPXFCURB Lock_Row; l_return_status: '||l_return_status);

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        -- oe_debug_pub.add('Inside QPXFCURB Lock_Row; p_base_markup_value: '||p_base_markup_value);

        --  Set DB flag and write record to cache.

        l_x_CURR_LISTS_rec.db_flag := FND_API.G_TRUE;

        Write_CURR_LISTS
        (   p_CURR_LISTS_rec              => l_x_CURR_LISTS_rec
        ,   p_db_record                   => TRUE
        );

    END IF;
        -- oe_debug_pub.add('Inside QPXFCURB Lock_Row; g_CURR_LISTS_rec.base_markup_value: '||g_CURR_LISTS_rec.base_markup_value);
        -- oe_debug_pub.add('Inside QPXFCURB Lock_Row; g_CURR_LISTS_rec.description: '||g_CURR_LISTS_rec.description);

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

--  Procedures maintaining CURR_LISTS record cache.

PROCEDURE Write_CURR_LISTS
(   p_CURR_LISTS_rec                IN  QP_Currency_PUB.Curr_Lists_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
BEGIN

    g_CURR_LISTS_rec := p_CURR_LISTS_rec;

    IF p_db_record THEN

        g_db_CURR_LISTS_rec := p_CURR_LISTS_rec;

    END IF;

END Write_Curr_Lists;

FUNCTION Get_CURR_LISTS
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_currency_header_id            IN  NUMBER
)
RETURN QP_Currency_PUB.Curr_Lists_Rec_Type
IS
BEGIN

    -- oe_debug_pub.add('Inside QPXFCURB.Get_CURR_LISTS; p_currency_header_id :'||p_currency_header_id);
    -- oe_debug_pub.add('Inside QPXFCURB.Get_CURR_LISTS; g_CURR_LISTS_rec.currency_header_id :'||g_CURR_LISTS_rec.currency_header_id);
    -- oe_debug_pub.add('Inside QPXFCURB.Get_CURR_LISTS; g_CURR_LISTS_rec.base_markup_value :'||g_CURR_LISTS_rec.base_markup_value);
    -- oe_debug_pub.add('Inside QPXFCURB.Get_CURR_LISTS; g_CURR_LISTS_rec.description :'||g_CURR_LISTS_rec.description);
    IF  p_currency_header_id <> g_CURR_LISTS_rec.currency_header_id
    THEN

        -- oe_debug_pub.add('BEFORE CALLING QP_Curr_Lists_Util.Query_Row');
        --  Query row from DB

        g_CURR_LISTS_rec := QP_Curr_Lists_Util.Query_Row
        (   p_currency_header_id          => p_currency_header_id
        );

        g_CURR_LISTS_rec.db_flag       := FND_API.G_TRUE;

        --  Load DB record

        g_db_CURR_LISTS_rec            := g_CURR_LISTS_rec;

    END IF;

    IF p_db_record THEN

        RETURN g_db_CURR_LISTS_rec;

    ELSE

        RETURN g_CURR_LISTS_rec;

    END IF;

END Get_Curr_Lists;

PROCEDURE Clear_Curr_Lists
IS
BEGIN

    -- oe_debug_pub.add('CLEARING g_CURR_LISTS_rec and g_db_CURR_LISTS_rec from Clear_Curr_Lists');
    g_CURR_LISTS_rec               := QP_Currency_PUB.G_MISS_CURR_LISTS_REC;
    g_db_CURR_LISTS_rec            := QP_Currency_PUB.G_MISS_CURR_LISTS_REC;

END Clear_Curr_Lists;

END QP_QP_Form_Curr_Lists;

/
