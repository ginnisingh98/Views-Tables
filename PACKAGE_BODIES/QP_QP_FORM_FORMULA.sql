--------------------------------------------------------
--  DDL for Package Body QP_QP_FORM_FORMULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_QP_FORM_FORMULA" AS
/* $Header: QPXFPRFB.pls 120.1 2005/06/13 23:36:20 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_QP_Form_Formula';

--  Global variables holding cached record.

g_FORMULA_rec                 QP_Price_Formula_PUB.Formula_Rec_Type;
g_db_FORMULA_rec              QP_Price_Formula_PUB.Formula_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_FORMULA
(   p_FORMULA_rec                   IN  QP_Price_Formula_PUB.Formula_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

FUNCTION Get_FORMULA
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_price_formula_id              IN  NUMBER
)
RETURN QP_Price_Formula_PUB.Formula_Rec_Type;

PROCEDURE Clear_FORMULA;

--  Global variable holding performed operations.

g_opr__tbl                    QP_Price_Formula_PUB.Formula_Tbl_Type;

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
,   x_context                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_description                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_formula                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_name                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_formula_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_price_formula                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_FORMULA_rec                 QP_Price_Formula_PUB.Formula_Rec_Type;
l_FORMULA_val_rec             QP_Price_Formula_PUB.Formula_Val_Rec_Type;
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


    --  Defaulting of flex values is currently done by the form.
    --  Set flex attributes to NULL in order to avoid defaulting them.

    l_FORMULA_rec.attribute1                      := NULL;
    l_FORMULA_rec.attribute10                     := NULL;
    l_FORMULA_rec.attribute11                     := NULL;
    l_FORMULA_rec.attribute12                     := NULL;
    l_FORMULA_rec.attribute13                     := NULL;
    l_FORMULA_rec.attribute14                     := NULL;
    l_FORMULA_rec.attribute15                     := NULL;
    l_FORMULA_rec.attribute2                      := NULL;
    l_FORMULA_rec.attribute3                      := NULL;
    l_FORMULA_rec.attribute4                      := NULL;
    l_FORMULA_rec.attribute5                      := NULL;
    l_FORMULA_rec.attribute6                      := NULL;
    l_FORMULA_rec.attribute7                      := NULL;
    l_FORMULA_rec.attribute8                      := NULL;
    l_FORMULA_rec.attribute9                      := NULL;
    l_FORMULA_rec.context                         := NULL;

    --  Set Operation to Create

    l_FORMULA_rec.operation := QP_GLOBALS.G_OPR_CREATE;

    --  Call QP_Price_Formula_PVT.Process_Price_Formula

    QP_Price_Formula_PVT.Process_Price_Formula
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_FORMULA_rec                 => l_FORMULA_rec
    ,   x_FORMULA_rec                 => l_x_FORMULA_rec
    ,   x_FORMULA_LINES_tbl           => l_x_FORMULA_LINES_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.

    x_attribute1                   := l_x_FORMULA_rec.attribute1;
    x_attribute10                  := l_x_FORMULA_rec.attribute10;
    x_attribute11                  := l_x_FORMULA_rec.attribute11;
    x_attribute12                  := l_x_FORMULA_rec.attribute12;
    x_attribute13                  := l_x_FORMULA_rec.attribute13;
    x_attribute14                  := l_x_FORMULA_rec.attribute14;
    x_attribute15                  := l_x_FORMULA_rec.attribute15;
    x_attribute2                   := l_x_FORMULA_rec.attribute2;
    x_attribute3                   := l_x_FORMULA_rec.attribute3;
    x_attribute4                   := l_x_FORMULA_rec.attribute4;
    x_attribute5                   := l_x_FORMULA_rec.attribute5;
    x_attribute6                   := l_x_FORMULA_rec.attribute6;
    x_attribute7                   := l_x_FORMULA_rec.attribute7;
    x_attribute8                   := l_x_FORMULA_rec.attribute8;
    x_attribute9                   := l_x_FORMULA_rec.attribute9;
    x_context                      := l_x_FORMULA_rec.context;
    x_description                  := l_x_FORMULA_rec.description;
    x_end_date_active              := l_x_FORMULA_rec.end_date_active;
    x_formula                      := l_x_FORMULA_rec.formula;
    x_name                         := l_x_FORMULA_rec.name;
    x_price_formula_id             := l_x_FORMULA_rec.price_formula_id;
    x_start_date_active            := l_x_FORMULA_rec.start_date_active;

    --  Load display out parameters if any

    l_FORMULA_val_rec := QP_Formula_Util.Get_Values
    (   p_FORMULA_rec                 => l_x_FORMULA_rec
    );
    x_price_formula                := l_FORMULA_val_rec.price_formula;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_FORMULA_rec.db_flag := FND_API.G_FALSE;

    Write_FORMULA
    (   p_FORMULA_rec                 => l_x_FORMULA_rec
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
,   p_price_formula_id              IN  NUMBER
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
,   x_description                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_end_date_active               OUT NOCOPY /* file.sql.39 change */ DATE
,   x_formula                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_name                          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_price_formula_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_start_date_active             OUT NOCOPY /* file.sql.39 change */ DATE
,   x_price_formula                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_FORMULA_rec                 QP_Price_Formula_PUB.Formula_Rec_Type;
l_old_FORMULA_rec             QP_Price_Formula_PUB.Formula_Rec_Type;
l_FORMULA_val_rec             QP_Price_Formula_PUB.Formula_Val_Rec_Type;
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

    --  Read FORMULA from cache

    l_FORMULA_rec := Get_FORMULA
    (   p_db_record                   => FALSE
    ,   p_price_formula_id            => p_price_formula_id
    );

    l_old_FORMULA_rec              := l_FORMULA_rec;

    IF p_attr_id = QP_Formula_Util.G_DESCRIPTION THEN
        l_FORMULA_rec.description := p_attr_value;
    ELSIF p_attr_id = QP_Formula_Util.G_END_DATE_ACTIVE THEN
        l_FORMULA_rec.end_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Formula_Util.G_FORMULA THEN
        l_FORMULA_rec.formula := p_attr_value;
    ELSIF p_attr_id = QP_Formula_Util.G_NAME THEN
        l_FORMULA_rec.name := p_attr_value;
    ELSIF p_attr_id = QP_Formula_Util.G_PRICE_FORMULA THEN
        l_FORMULA_rec.price_formula_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Formula_Util.G_START_DATE_ACTIVE THEN
        l_FORMULA_rec.start_date_active := TO_DATE(p_attr_value,'DD/MM/YYYY');
    ELSIF p_attr_id = QP_Formula_Util.G_ATTRIBUTE1
    OR     p_attr_id = QP_Formula_Util.G_ATTRIBUTE10
    OR     p_attr_id = QP_Formula_Util.G_ATTRIBUTE11
    OR     p_attr_id = QP_Formula_Util.G_ATTRIBUTE12
    OR     p_attr_id = QP_Formula_Util.G_ATTRIBUTE13
    OR     p_attr_id = QP_Formula_Util.G_ATTRIBUTE14
    OR     p_attr_id = QP_Formula_Util.G_ATTRIBUTE15
    OR     p_attr_id = QP_Formula_Util.G_ATTRIBUTE2
    OR     p_attr_id = QP_Formula_Util.G_ATTRIBUTE3
    OR     p_attr_id = QP_Formula_Util.G_ATTRIBUTE4
    OR     p_attr_id = QP_Formula_Util.G_ATTRIBUTE5
    OR     p_attr_id = QP_Formula_Util.G_ATTRIBUTE6
    OR     p_attr_id = QP_Formula_Util.G_ATTRIBUTE7
    OR     p_attr_id = QP_Formula_Util.G_ATTRIBUTE8
    OR     p_attr_id = QP_Formula_Util.G_ATTRIBUTE9
    OR     p_attr_id = QP_Formula_Util.G_CONTEXT
    THEN

        l_FORMULA_rec.attribute1       := p_attribute1;
        l_FORMULA_rec.attribute10      := p_attribute10;
        l_FORMULA_rec.attribute11      := p_attribute11;
        l_FORMULA_rec.attribute12      := p_attribute12;
        l_FORMULA_rec.attribute13      := p_attribute13;
        l_FORMULA_rec.attribute14      := p_attribute14;
        l_FORMULA_rec.attribute15      := p_attribute15;
        l_FORMULA_rec.attribute2       := p_attribute2;
        l_FORMULA_rec.attribute3       := p_attribute3;
        l_FORMULA_rec.attribute4       := p_attribute4;
        l_FORMULA_rec.attribute5       := p_attribute5;
        l_FORMULA_rec.attribute6       := p_attribute6;
        l_FORMULA_rec.attribute7       := p_attribute7;
        l_FORMULA_rec.attribute8       := p_attribute8;
        l_FORMULA_rec.attribute9       := p_attribute9;
        l_FORMULA_rec.context          := p_context;

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

    IF FND_API.To_Boolean(l_FORMULA_rec.db_flag) THEN
        l_FORMULA_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_FORMULA_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Call QP_Price_Formula_PVT.Process_Price_Formula

    QP_Price_Formula_PVT.Process_Price_Formula
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_FORMULA_rec                 => l_FORMULA_rec
    ,   p_old_FORMULA_rec             => l_old_FORMULA_rec
    ,   x_FORMULA_rec                 => l_x_FORMULA_rec
    ,   x_FORMULA_LINES_tbl           => l_x_FORMULA_LINES_tbl
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
    x_context                      := FND_API.G_MISS_CHAR;
    x_description                  := FND_API.G_MISS_CHAR;
    x_end_date_active              := FND_API.G_MISS_DATE;
    x_formula                      := FND_API.G_MISS_CHAR;
    x_name                         := FND_API.G_MISS_CHAR;
    x_price_formula_id             := FND_API.G_MISS_NUM;
    x_start_date_active            := FND_API.G_MISS_DATE;
    x_price_formula                := FND_API.G_MISS_CHAR;

    --  Load display out parameters if any

    l_FORMULA_val_rec := QP_Formula_Util.Get_Values
    (   p_FORMULA_rec                 => l_x_FORMULA_rec
    ,   p_old_FORMULA_rec             => l_FORMULA_rec
    );

    --  Return changed attributes.

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.attribute1,
                            l_FORMULA_rec.attribute1)
    THEN
        x_attribute1 := l_x_FORMULA_rec.attribute1;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.attribute10,
                            l_FORMULA_rec.attribute10)
    THEN
        x_attribute10 := l_x_FORMULA_rec.attribute10;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.attribute11,
                            l_FORMULA_rec.attribute11)
    THEN
        x_attribute11 := l_x_FORMULA_rec.attribute11;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.attribute12,
                            l_FORMULA_rec.attribute12)
    THEN
        x_attribute12 := l_x_FORMULA_rec.attribute12;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.attribute13,
                            l_FORMULA_rec.attribute13)
    THEN
        x_attribute13 := l_x_FORMULA_rec.attribute13;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.attribute14,
                            l_FORMULA_rec.attribute14)
    THEN
        x_attribute14 := l_x_FORMULA_rec.attribute14;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.attribute15,
                            l_FORMULA_rec.attribute15)
    THEN
        x_attribute15 := l_x_FORMULA_rec.attribute15;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.attribute2,
                            l_FORMULA_rec.attribute2)
    THEN
        x_attribute2 := l_x_FORMULA_rec.attribute2;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.attribute3,
                            l_FORMULA_rec.attribute3)
    THEN
        x_attribute3 := l_x_FORMULA_rec.attribute3;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.attribute4,
                            l_FORMULA_rec.attribute4)
    THEN
        x_attribute4 := l_x_FORMULA_rec.attribute4;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.attribute5,
                            l_FORMULA_rec.attribute5)
    THEN
        x_attribute5 := l_x_FORMULA_rec.attribute5;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.attribute6,
                            l_FORMULA_rec.attribute6)
    THEN
        x_attribute6 := l_x_FORMULA_rec.attribute6;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.attribute7,
                            l_FORMULA_rec.attribute7)
    THEN
        x_attribute7 := l_x_FORMULA_rec.attribute7;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.attribute8,
                            l_FORMULA_rec.attribute8)
    THEN
        x_attribute8 := l_x_FORMULA_rec.attribute8;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.attribute9,
                            l_FORMULA_rec.attribute9)
    THEN
        x_attribute9 := l_x_FORMULA_rec.attribute9;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.context,
                            l_FORMULA_rec.context)
    THEN
        x_context := l_x_FORMULA_rec.context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.description,
                            l_FORMULA_rec.description)
    THEN
        x_description := l_x_FORMULA_rec.description;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.end_date_active,
                            l_FORMULA_rec.end_date_active)
    THEN
        x_end_date_active := l_x_FORMULA_rec.end_date_active;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.formula,
                            l_FORMULA_rec.formula)
    THEN
        x_formula := l_x_FORMULA_rec.formula;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.name,
                            l_FORMULA_rec.name)
    THEN
        x_name := l_x_FORMULA_rec.name;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.price_formula_id,
                            l_FORMULA_rec.price_formula_id)
    THEN
        x_price_formula_id := l_x_FORMULA_rec.price_formula_id;
        x_price_formula := l_FORMULA_val_rec.price_formula;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_FORMULA_rec.start_date_active,
                            l_FORMULA_rec.start_date_active)
    THEN
        x_start_date_active := l_x_FORMULA_rec.start_date_active;
    END IF;


    --  Write to cache.

    Write_FORMULA
    (   p_FORMULA_rec                 => l_x_FORMULA_rec
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
,   p_price_formula_id              IN  NUMBER
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_created_by                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_date              OUT NOCOPY /* file.sql.39 change */ DATE
,   x_last_updated_by               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_login             OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_FORMULA_rec                 QP_Price_Formula_PUB.Formula_Rec_Type;
l_old_FORMULA_rec             QP_Price_Formula_PUB.Formula_Rec_Type;
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

    --  Read FORMULA from cache

    l_old_FORMULA_rec := Get_FORMULA
    (   p_db_record                   => TRUE
    ,   p_price_formula_id            => p_price_formula_id
    );

    l_FORMULA_rec := Get_FORMULA
    (   p_db_record                   => FALSE
    ,   p_price_formula_id            => p_price_formula_id
    );

    --  Set Operation.

    IF FND_API.To_Boolean(l_FORMULA_rec.db_flag) THEN
        l_FORMULA_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_FORMULA_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Call QP_Price_Formula_PVT.Process_Price_Formula

    QP_Price_Formula_PVT.Process_Price_Formula
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_FORMULA_rec                 => l_FORMULA_rec
    ,   p_old_FORMULA_rec             => l_old_FORMULA_rec
    ,   x_FORMULA_rec                 => l_x_FORMULA_rec
    ,   x_FORMULA_LINES_tbl           => l_x_FORMULA_LINES_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.


    x_creation_date                := l_x_FORMULA_rec.creation_date;
    x_created_by                   := l_x_FORMULA_rec.created_by;
    x_last_update_date             := l_x_FORMULA_rec.last_update_date;
    x_last_updated_by              := l_x_FORMULA_rec.last_updated_by;
    x_last_update_login            := l_x_FORMULA_rec.last_update_login;

    --  Clear FORMULA record cache

    Clear_FORMULA;

    --  Keep track of performed operations.

    l_old_FORMULA_rec.operation := l_FORMULA_rec.operation;


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
,   p_price_formula_id              IN  NUMBER
)
IS
l_FORMULA_rec                 QP_Price_Formula_PUB.Formula_Rec_Type;
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

    l_FORMULA_rec := Get_FORMULA
    (   p_db_record                   => TRUE
    ,   p_price_formula_id            => p_price_formula_id
    );

    --  Set Operation.

    l_FORMULA_rec.operation := QP_GLOBALS.G_OPR_DELETE;

    --  Call QP_Price_Formula_PVT.Process_Price_Formula

    QP_Price_Formula_PVT.Process_Price_Formula
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_FORMULA_rec                 => l_FORMULA_rec
    ,   x_FORMULA_rec                 => l_x_FORMULA_rec
    ,   x_FORMULA_LINES_tbl           => l_x_FORMULA_LINES_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear FORMULA record cache

    Clear_FORMULA;

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
    l_control_rec.process_entity       := QP_GLOBALS.G_ENTITY_FORMULA;

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
l_x_FORMULA_rec               QP_Price_Formula_PUB.Formula_Rec_Type;
l_x_FORMULA_LINES_rec         QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
l_x_FORMULA_LINES_tbl         QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;
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
,   p_context                       IN  VARCHAR2
,   p_created_by                    IN  NUMBER
,   p_creation_date                 IN  DATE
,   p_description                   IN  VARCHAR2
,   p_end_date_active               IN  DATE
,   p_formula                       IN  VARCHAR2
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_name                          IN  VARCHAR2
,   p_price_formula_id              IN  NUMBER
,   p_start_date_active             IN  DATE
)
IS
l_return_status               VARCHAR2(1);
l_FORMULA_rec                 QP_Price_Formula_PUB.Formula_Rec_Type;
l_x_FORMULA_rec               QP_Price_Formula_PUB.Formula_Rec_Type;
l_x_FORMULA_LINES_rec         QP_Price_Formula_PUB.Formula_Lines_Rec_Type;
l_x_FORMULA_LINES_tbl         QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;
BEGIN

    --  Load FORMULA record

    l_FORMULA_rec.attribute1       := p_attribute1;
    l_FORMULA_rec.attribute10      := p_attribute10;
    l_FORMULA_rec.attribute11      := p_attribute11;
    l_FORMULA_rec.attribute12      := p_attribute12;
    l_FORMULA_rec.attribute13      := p_attribute13;
    l_FORMULA_rec.attribute14      := p_attribute14;
    l_FORMULA_rec.attribute15      := p_attribute15;
    l_FORMULA_rec.attribute2       := p_attribute2;
    l_FORMULA_rec.attribute3       := p_attribute3;
    l_FORMULA_rec.attribute4       := p_attribute4;
    l_FORMULA_rec.attribute5       := p_attribute5;
    l_FORMULA_rec.attribute6       := p_attribute6;
    l_FORMULA_rec.attribute7       := p_attribute7;
    l_FORMULA_rec.attribute8       := p_attribute8;
    l_FORMULA_rec.attribute9       := p_attribute9;
    l_FORMULA_rec.context          := p_context;
    l_FORMULA_rec.created_by       := p_created_by;
    l_FORMULA_rec.creation_date    := p_creation_date;
    l_FORMULA_rec.description      := p_description;
    l_FORMULA_rec.end_date_active  := p_end_date_active;
    l_FORMULA_rec.formula          := p_formula;
    l_FORMULA_rec.last_updated_by  := p_last_updated_by;
    l_FORMULA_rec.last_update_date := p_last_update_date;
    l_FORMULA_rec.last_update_login := p_last_update_login;
    l_FORMULA_rec.name              := p_name;
    l_FORMULA_rec.price_formula_id := p_price_formula_id;
    l_FORMULA_rec.start_date_active := p_start_date_active;

    --  Call QP_Price_Formula_PVT.Lock_Price_Formula

--    l_FORMULA_rec.operation := QP_GLOBALS.G_OPR_LOCK;

    QP_Price_Formula_PVT.Lock_Price_Formula
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_FORMULA_rec                 => l_FORMULA_rec
    ,   x_FORMULA_rec                 => l_x_FORMULA_rec
    ,   x_FORMULA_LINES_tbl           => l_x_FORMULA_LINES_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_FORMULA_rec.db_flag := FND_API.G_TRUE;

        Write_FORMULA
        (   p_FORMULA_rec                 => l_x_FORMULA_rec
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

--  Procedures maintaining FORMULA record cache.

PROCEDURE Write_FORMULA
(   p_FORMULA_rec                   IN  QP_Price_Formula_PUB.Formula_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
BEGIN

    g_FORMULA_rec := p_FORMULA_rec;

    IF p_db_record THEN

        g_db_FORMULA_rec := p_FORMULA_rec;

    END IF;

END Write_Formula;

FUNCTION Get_FORMULA
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_price_formula_id              IN  NUMBER
)
RETURN QP_Price_Formula_PUB.Formula_Rec_Type
IS
BEGIN

    IF  p_price_formula_id <> g_FORMULA_rec.price_formula_id
    THEN

        --  Query row from DB

        g_FORMULA_rec := QP_Formula_Util.Query_Row
        (   p_price_formula_id            => p_price_formula_id
        );

        g_FORMULA_rec.db_flag          := FND_API.G_TRUE;

        --  Load DB record

        g_db_FORMULA_rec               := g_FORMULA_rec;

    END IF;

    IF p_db_record THEN

        RETURN g_db_FORMULA_rec;

    ELSE

        RETURN g_FORMULA_rec;

    END IF;

END Get_Formula;

PROCEDURE Clear_Formula
IS
BEGIN

    g_FORMULA_rec                  := QP_Price_Formula_PUB.G_MISS_FORMULA_REC;
    g_db_FORMULA_rec               := QP_Price_Formula_PUB.G_MISS_FORMULA_REC;

END Clear_Formula;

END QP_QP_Form_Formula;

/
