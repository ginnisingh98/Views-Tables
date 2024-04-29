--------------------------------------------------------
--  DDL for Package Body QP_QP_FORM_CON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_QP_FORM_CON" AS
/* $Header: QPXFCONB.pls 120.1 2005/06/13 00:29:16 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_QP_Form_Con';

--  Global variables holding cached record.

g_CON_rec                     QP_Attributes_PUB.Con_Rec_Type;
g_db_CON_rec                  QP_Attributes_PUB.Con_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_CON
(   p_CON_rec                       IN  QP_Attributes_PUB.Con_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

FUNCTION Get_CON
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_prc_context_id                IN  NUMBER
)
RETURN QP_Attributes_PUB.Con_Rec_Type;

PROCEDURE Clear_CON;

--  Global variable holding performed operations.

g_opr__tbl                    QP_Attributes_PUB.Con_Tbl_Type;

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
,   x_enabled_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_prc_context_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_prc_context_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_prc_context_type              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_description            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_flag                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_prc_context_name       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_user_description              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_user_prc_context_name         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_enabled                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_prc_context                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded                        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_CON_rec                     QP_Attributes_PUB.Con_Rec_Type;
l_CON_val_rec                 QP_Attributes_PUB.Con_Val_Rec_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_CON_rec                   QP_Attributes_PUB.Con_Rec_Type;
l_x_SEG_rec                   QP_Attributes_PUB.Seg_Rec_Type;
l_x_SEG_tbl                   QP_Attributes_PUB.Seg_Tbl_Type;
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

    l_CON_rec.attribute1                          := NULL;
    l_CON_rec.attribute10                         := NULL;
    l_CON_rec.attribute11                         := NULL;
    l_CON_rec.attribute12                         := NULL;
    l_CON_rec.attribute13                         := NULL;
    l_CON_rec.attribute14                         := NULL;
    l_CON_rec.attribute15                         := NULL;
    l_CON_rec.attribute2                          := NULL;
    l_CON_rec.attribute3                          := NULL;
    l_CON_rec.attribute4                          := NULL;
    l_CON_rec.attribute5                          := NULL;
    l_CON_rec.attribute6                          := NULL;
    l_CON_rec.attribute7                          := NULL;
    l_CON_rec.attribute8                          := NULL;
    l_CON_rec.attribute9                          := NULL;
    l_CON_rec.context                             := NULL;

    --  Set Operation to Create

    l_CON_rec.operation := QP_GLOBALS.G_OPR_CREATE;

    --  Call QP_Attributes_PVT.Process_Attributes

    QP_Attributes_PVT.Process_Attributes
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_CON_rec                     => l_CON_rec
    ,   x_CON_rec                     => l_x_CON_rec
    ,   x_SEG_tbl                     => l_x_SEG_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.

    x_attribute1                   := l_x_CON_rec.attribute1;
    x_attribute10                  := l_x_CON_rec.attribute10;
    x_attribute11                  := l_x_CON_rec.attribute11;
    x_attribute12                  := l_x_CON_rec.attribute12;
    x_attribute13                  := l_x_CON_rec.attribute13;
    x_attribute14                  := l_x_CON_rec.attribute14;
    x_attribute15                  := l_x_CON_rec.attribute15;
    x_attribute2                   := l_x_CON_rec.attribute2;
    x_attribute3                   := l_x_CON_rec.attribute3;
    x_attribute4                   := l_x_CON_rec.attribute4;
    x_attribute5                   := l_x_CON_rec.attribute5;
    x_attribute6                   := l_x_CON_rec.attribute6;
    x_attribute7                   := l_x_CON_rec.attribute7;
    x_attribute8                   := l_x_CON_rec.attribute8;
    x_attribute9                   := l_x_CON_rec.attribute9;
    x_context                      := l_x_CON_rec.context;
    x_enabled_flag                 := l_x_CON_rec.enabled_flag;
    x_prc_context_code          := l_x_CON_rec.prc_context_code;
    x_prc_context_id               := l_x_CON_rec.prc_context_id;
    x_prc_context_type             := l_x_CON_rec.prc_context_type;
    x_seeded_description           := l_x_CON_rec.seeded_description;
    x_seeded_flag                  := l_x_CON_rec.seeded_flag;
    x_seeded_prc_context_name      := l_x_CON_rec.seeded_prc_context_name;
    x_user_description             := l_x_CON_rec.user_description;
    x_user_prc_context_name        := l_x_CON_rec.user_prc_context_name;

    --  Load display out parameters if any

    l_CON_val_rec := QP_Con_Util.Get_Values
    (   p_CON_rec                     => l_x_CON_rec
    );
    x_enabled                      := l_CON_val_rec.enabled;
    x_prc_context                  := l_CON_val_rec.prc_context;
    x_seeded                       := l_CON_val_rec.seeded;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_CON_rec.db_flag := FND_API.G_FALSE;

    Write_CON
    (   p_CON_rec                     => l_x_CON_rec
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
,   p_prc_context_id                IN  NUMBER
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
,   x_enabled_flag                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_prc_context_code              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_prc_context_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_prc_context_type              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_description            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_flag                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_prc_context_name       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_user_description              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_user_prc_context_name         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_enabled                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_prc_context                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded                        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_CON_rec                     QP_Attributes_PUB.Con_Rec_Type;
l_old_CON_rec                 QP_Attributes_PUB.Con_Rec_Type;
l_CON_val_rec                 QP_Attributes_PUB.Con_Val_Rec_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_CON_rec                   QP_Attributes_PUB.Con_Rec_Type;
l_x_SEG_rec                   QP_Attributes_PUB.Seg_Rec_Type;
l_x_SEG_tbl                   QP_Attributes_PUB.Seg_Tbl_Type;
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

    --  Read CON from cache

    l_CON_rec := Get_CON
    (   p_db_record                   => FALSE
    ,   p_prc_context_id              => p_prc_context_id
    );

    l_old_CON_rec                  := l_CON_rec;

    IF p_attr_id = QP_Con_Util.G_ENABLED THEN
        l_CON_rec.enabled_flag := p_attr_value;
    ELSIF p_attr_id = QP_Con_Util.G_PRC_CONTEXT_code THEN
        l_CON_rec.prc_context_code := p_attr_value;
    ELSIF p_attr_id = QP_Con_Util.G_PRC_CONTEXT THEN
        l_CON_rec.prc_context_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Con_Util.G_PRC_CONTEXT_TYPE THEN
        l_CON_rec.prc_context_type := p_attr_value;
    ELSIF p_attr_id = QP_Con_Util.G_SEEDED_DESCRIPTION THEN
        l_CON_rec.seeded_description := p_attr_value;
    ELSIF p_attr_id = QP_Con_Util.G_SEEDED THEN
        l_CON_rec.seeded_flag := p_attr_value;
    ELSIF p_attr_id = QP_Con_Util.G_SEEDED_PRC_CONTEXT_NAME THEN
        l_CON_rec.seeded_prc_context_name := p_attr_value;
    ELSIF p_attr_id = QP_Con_Util.G_USER_DESCRIPTION THEN
        l_CON_rec.user_description := p_attr_value;
    ELSIF p_attr_id = QP_Con_Util.G_USER_PRC_CONTEXT_NAME THEN
        l_CON_rec.user_prc_context_name := p_attr_value;
    ELSIF p_attr_id = QP_Con_Util.G_ATTRIBUTE1
    OR     p_attr_id = QP_Con_Util.G_ATTRIBUTE10
    OR     p_attr_id = QP_Con_Util.G_ATTRIBUTE11
    OR     p_attr_id = QP_Con_Util.G_ATTRIBUTE12
    OR     p_attr_id = QP_Con_Util.G_ATTRIBUTE13
    OR     p_attr_id = QP_Con_Util.G_ATTRIBUTE14
    OR     p_attr_id = QP_Con_Util.G_ATTRIBUTE15
    OR     p_attr_id = QP_Con_Util.G_ATTRIBUTE2
    OR     p_attr_id = QP_Con_Util.G_ATTRIBUTE3
    OR     p_attr_id = QP_Con_Util.G_ATTRIBUTE4
    OR     p_attr_id = QP_Con_Util.G_ATTRIBUTE5
    OR     p_attr_id = QP_Con_Util.G_ATTRIBUTE6
    OR     p_attr_id = QP_Con_Util.G_ATTRIBUTE7
    OR     p_attr_id = QP_Con_Util.G_ATTRIBUTE8
    OR     p_attr_id = QP_Con_Util.G_ATTRIBUTE9
    OR     p_attr_id = QP_Con_Util.G_CONTEXT
    THEN

        l_CON_rec.attribute1           := p_attribute1;
        l_CON_rec.attribute10          := p_attribute10;
        l_CON_rec.attribute11          := p_attribute11;
        l_CON_rec.attribute12          := p_attribute12;
        l_CON_rec.attribute13          := p_attribute13;
        l_CON_rec.attribute14          := p_attribute14;
        l_CON_rec.attribute15          := p_attribute15;
        l_CON_rec.attribute2           := p_attribute2;
        l_CON_rec.attribute3           := p_attribute3;
        l_CON_rec.attribute4           := p_attribute4;
        l_CON_rec.attribute5           := p_attribute5;
        l_CON_rec.attribute6           := p_attribute6;
        l_CON_rec.attribute7           := p_attribute7;
        l_CON_rec.attribute8           := p_attribute8;
        l_CON_rec.attribute9           := p_attribute9;
        l_CON_rec.context              := p_context;

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

    IF FND_API.To_Boolean(l_CON_rec.db_flag) THEN
        l_CON_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_CON_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Call QP_Attributes_PVT.Process_Attributes

    QP_Attributes_PVT.Process_Attributes
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_CON_rec                     => l_CON_rec
    ,   p_old_CON_rec                 => l_old_CON_rec
    ,   x_CON_rec                     => l_x_CON_rec
    ,   x_SEG_tbl                     => l_x_SEG_tbl
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
    x_enabled_flag                 := FND_API.G_MISS_CHAR;
    x_prc_context_code          := FND_API.G_MISS_CHAR;
    x_prc_context_id               := FND_API.G_MISS_NUM;
    x_prc_context_type             := FND_API.G_MISS_CHAR;
    x_seeded_description           := FND_API.G_MISS_CHAR;
    x_seeded_flag                  := FND_API.G_MISS_CHAR;
    x_seeded_prc_context_name      := FND_API.G_MISS_CHAR;
    x_user_description             := FND_API.G_MISS_CHAR;
    x_user_prc_context_name        := FND_API.G_MISS_CHAR;
    x_enabled                      := FND_API.G_MISS_CHAR;
    x_prc_context                  := FND_API.G_MISS_CHAR;
    x_seeded                       := FND_API.G_MISS_CHAR;

    --  Load display out parameters if any

    l_CON_val_rec := QP_Con_Util.Get_Values
    (   p_CON_rec                     => l_x_CON_rec
    ,   p_old_CON_rec                 => l_CON_rec
    );

    --  Return changed attributes.

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.attribute1,
                            l_CON_rec.attribute1)
    THEN
        x_attribute1 := l_x_CON_rec.attribute1;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.attribute10,
                            l_CON_rec.attribute10)
    THEN
        x_attribute10 := l_x_CON_rec.attribute10;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.attribute11,
                            l_CON_rec.attribute11)
    THEN
        x_attribute11 := l_x_CON_rec.attribute11;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.attribute12,
                            l_CON_rec.attribute12)
    THEN
        x_attribute12 := l_x_CON_rec.attribute12;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.attribute13,
                            l_CON_rec.attribute13)
    THEN
        x_attribute13 := l_x_CON_rec.attribute13;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.attribute14,
                            l_CON_rec.attribute14)
    THEN
        x_attribute14 := l_x_CON_rec.attribute14;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.attribute15,
                            l_CON_rec.attribute15)
    THEN
        x_attribute15 := l_x_CON_rec.attribute15;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.attribute2,
                            l_CON_rec.attribute2)
    THEN
        x_attribute2 := l_x_CON_rec.attribute2;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.attribute3,
                            l_CON_rec.attribute3)
    THEN
        x_attribute3 := l_x_CON_rec.attribute3;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.attribute4,
                            l_CON_rec.attribute4)
    THEN
        x_attribute4 := l_x_CON_rec.attribute4;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.attribute5,
                            l_CON_rec.attribute5)
    THEN
        x_attribute5 := l_x_CON_rec.attribute5;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.attribute6,
                            l_CON_rec.attribute6)
    THEN
        x_attribute6 := l_x_CON_rec.attribute6;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.attribute7,
                            l_CON_rec.attribute7)
    THEN
        x_attribute7 := l_x_CON_rec.attribute7;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.attribute8,
                            l_CON_rec.attribute8)
    THEN
        x_attribute8 := l_x_CON_rec.attribute8;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.attribute9,
                            l_CON_rec.attribute9)
    THEN
        x_attribute9 := l_x_CON_rec.attribute9;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.context,
                            l_CON_rec.context)
    THEN
        x_context := l_x_CON_rec.context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.enabled_flag,
                            l_CON_rec.enabled_flag)
    THEN
        x_enabled_flag := l_x_CON_rec.enabled_flag;
        x_enabled := l_CON_val_rec.enabled;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.prc_context_code,
                            l_CON_rec.prc_context_code)
    THEN
        x_prc_context_code := l_x_CON_rec.prc_context_code;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.prc_context_id,
                            l_CON_rec.prc_context_id)
    THEN
        x_prc_context_id := l_x_CON_rec.prc_context_id;
        x_prc_context := l_CON_val_rec.prc_context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.prc_context_type,
                            l_CON_rec.prc_context_type)
    THEN
        x_prc_context_type := l_x_CON_rec.prc_context_type;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.seeded_description,
                            l_CON_rec.seeded_description)
    THEN
        x_seeded_description := l_x_CON_rec.seeded_description;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.seeded_flag,
                            l_CON_rec.seeded_flag)
    THEN
        x_seeded_flag := l_x_CON_rec.seeded_flag;
        x_seeded := l_CON_val_rec.seeded;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.seeded_prc_context_name,
                            l_CON_rec.seeded_prc_context_name)
    THEN
        x_seeded_prc_context_name := l_x_CON_rec.seeded_prc_context_name;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.user_description,
                            l_CON_rec.user_description)
    THEN
        x_user_description := l_x_CON_rec.user_description;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_CON_rec.user_prc_context_name,
                            l_CON_rec.user_prc_context_name)
    THEN
        x_user_prc_context_name := l_x_CON_rec.user_prc_context_name;
    END IF;


    --  Write to cache.

    Write_CON
    (   p_CON_rec                     => l_x_CON_rec
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
,   p_prc_context_id                IN  NUMBER
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_created_by                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_date              OUT NOCOPY /* file.sql.39 change */ DATE
,   x_last_updated_by               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_login             OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_CON_rec                     QP_Attributes_PUB.Con_Rec_Type;
l_old_CON_rec                 QP_Attributes_PUB.Con_Rec_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_CON_rec                   QP_Attributes_PUB.Con_Rec_Type;
l_x_SEG_rec                   QP_Attributes_PUB.Seg_Rec_Type;
l_x_SEG_tbl                   QP_Attributes_PUB.Seg_Tbl_Type;
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

    --  Read CON from cache

    l_old_CON_rec := Get_CON
    (   p_db_record                   => TRUE
    ,   p_prc_context_id              => p_prc_context_id
    );

    l_CON_rec := Get_CON
    (   p_db_record                   => FALSE
    ,   p_prc_context_id              => p_prc_context_id
    );

    --  Set Operation.

    IF FND_API.To_Boolean(l_CON_rec.db_flag) THEN
        l_CON_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_CON_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Call QP_Attributes_PVT.Process_Attributes

    QP_Attributes_PVT.Process_Attributes
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_CON_rec                     => l_CON_rec
    ,   p_old_CON_rec                 => l_old_CON_rec
    ,   x_CON_rec                     => l_x_CON_rec
    ,   x_SEG_tbl                     => l_x_SEG_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.


    x_creation_date                := l_x_CON_rec.creation_date;
    x_created_by                   := l_x_CON_rec.created_by;
    x_last_update_date             := l_x_CON_rec.last_update_date;
    x_last_updated_by              := l_x_CON_rec.last_updated_by;
    x_last_update_login            := l_x_CON_rec.last_update_login;

    --  Clear CON record cache

    Clear_CON;

    --  Keep track of performed operations.

    l_old_CON_rec.operation := l_CON_rec.operation;


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
,   p_prc_context_id                IN  NUMBER
)
IS
l_CON_rec                     QP_Attributes_PUB.Con_Rec_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_CON_rec                   QP_Attributes_PUB.Con_Rec_Type;
l_x_SEG_rec                   QP_Attributes_PUB.Seg_Rec_Type;
l_x_SEG_tbl                   QP_Attributes_PUB.Seg_Tbl_Type;
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

    l_CON_rec := Get_CON
    (   p_db_record                   => TRUE
    ,   p_prc_context_id              => p_prc_context_id
    );

    --  Set Operation.

    l_CON_rec.operation := QP_GLOBALS.G_OPR_DELETE;

    --  Call QP_Attributes_PVT.Process_Attributes

    QP_Attributes_PVT.Process_Attributes
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_CON_rec                     => l_CON_rec
    ,   x_CON_rec                     => l_x_CON_rec
    ,   x_SEG_tbl                     => l_x_SEG_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear CON record cache

    Clear_CON;

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
l_x_CON_rec                   QP_Attributes_PUB.Con_Rec_Type;
l_x_SEG_rec                   QP_Attributes_PUB.Seg_Rec_Type;
l_x_SEG_tbl                   QP_Attributes_PUB.Seg_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := QP_GLOBALS.G_ENTITY_CON;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Call QP_Attributes_PVT.Process_Attributes

    QP_Attributes_PVT.Process_Attributes
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   x_CON_rec                     => l_x_CON_rec
    ,   x_SEG_tbl                     => l_x_SEG_tbl
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
l_x_CON_rec                   QP_Attributes_PUB.Con_Rec_Type;
l_x_SEG_rec                   QP_Attributes_PUB.Seg_Rec_Type;
l_x_SEG_tbl                   QP_Attributes_PUB.Seg_Tbl_Type;
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

    --  Call QP_Attributes_PVT.Process_Attributes

    QP_Attributes_PVT.Process_Attributes
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   x_CON_rec                     => l_x_CON_rec
    ,   x_SEG_tbl                     => l_x_SEG_tbl
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
,   p_enabled_flag                  IN  VARCHAR2
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_prc_context_code              IN  VARCHAR2
,   p_prc_context_id                IN  NUMBER
,   p_prc_context_type              IN  VARCHAR2
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_seeded_description            IN  VARCHAR2
,   p_seeded_flag                   IN  VARCHAR2
,   p_seeded_prc_context_name       IN  VARCHAR2
,   p_user_description              IN  VARCHAR2
,   p_user_prc_context_name         IN  VARCHAR2
)
IS
l_return_status               VARCHAR2(1);
l_CON_rec                     QP_Attributes_PUB.Con_Rec_Type;
l_x_CON_rec                   QP_Attributes_PUB.Con_Rec_Type;
l_x_SEG_rec                   QP_Attributes_PUB.Seg_Rec_Type;
l_x_SEG_tbl                   QP_Attributes_PUB.Seg_Tbl_Type;
BEGIN

    --  Load CON record

    l_CON_rec.attribute1           := p_attribute1;
    l_CON_rec.attribute10          := p_attribute10;
    l_CON_rec.attribute11          := p_attribute11;
    l_CON_rec.attribute12          := p_attribute12;
    l_CON_rec.attribute13          := p_attribute13;
    l_CON_rec.attribute14          := p_attribute14;
    l_CON_rec.attribute15          := p_attribute15;
    l_CON_rec.attribute2           := p_attribute2;
    l_CON_rec.attribute3           := p_attribute3;
    l_CON_rec.attribute4           := p_attribute4;
    l_CON_rec.attribute5           := p_attribute5;
    l_CON_rec.attribute6           := p_attribute6;
    l_CON_rec.attribute7           := p_attribute7;
    l_CON_rec.attribute8           := p_attribute8;
    l_CON_rec.attribute9           := p_attribute9;
    l_CON_rec.context              := p_context;
    l_CON_rec.created_by           := p_created_by;
    l_CON_rec.creation_date        := p_creation_date;
    l_CON_rec.enabled_flag         := p_enabled_flag;
    l_CON_rec.last_updated_by      := p_last_updated_by;
    l_CON_rec.last_update_date     := p_last_update_date;
    l_CON_rec.last_update_login    := p_last_update_login;
    l_CON_rec.prc_context_code  := p_prc_context_code;
    l_CON_rec.prc_context_id       := p_prc_context_id;
    l_CON_rec.prc_context_type     := p_prc_context_type;
    l_CON_rec.program_application_id := p_program_application_id;
    l_CON_rec.program_id           := p_program_id;
    l_CON_rec.program_update_date  := p_program_update_date;
    l_CON_rec.seeded_description   := p_seeded_description;
    l_CON_rec.seeded_flag          := p_seeded_flag;
    l_CON_rec.seeded_prc_context_name := p_seeded_prc_context_name;
    l_CON_rec.user_description     := p_user_description;
    l_CON_rec.user_prc_context_name := p_user_prc_context_name;

    --  Call QP_Attributes_PVT.Lock_Attributes

    QP_Attributes_PVT.Lock_Attributes
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_CON_rec                     => l_CON_rec
    ,   x_CON_rec                     => l_x_CON_rec
    ,   x_SEG_tbl                     => l_x_SEG_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_CON_rec.db_flag := FND_API.G_TRUE;

        Write_CON
        (   p_CON_rec                     => l_x_CON_rec
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

--  Procedures maintaining CON record cache.

PROCEDURE Write_CON
(   p_CON_rec                       IN  QP_Attributes_PUB.Con_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
BEGIN

    g_CON_rec := p_CON_rec;

    IF p_db_record THEN

        g_db_CON_rec := p_CON_rec;

    END IF;

END Write_Con;

FUNCTION Get_CON
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_prc_context_id                IN  NUMBER
)
RETURN QP_Attributes_PUB.Con_Rec_Type
IS
BEGIN

    IF  p_prc_context_id <> g_CON_rec.prc_context_id
    THEN

        --  Query row from DB

        g_CON_rec := QP_Con_Util.Query_Row
        (   p_prc_context_id              => p_prc_context_id
        );

        g_CON_rec.db_flag              := FND_API.G_TRUE;

        --  Load DB record

        g_db_CON_rec                   := g_CON_rec;

    END IF;

    IF p_db_record THEN

        RETURN g_db_CON_rec;

    ELSE

        RETURN g_CON_rec;

    END IF;

END Get_Con;

PROCEDURE Clear_Con
IS
BEGIN

    g_CON_rec                      := QP_Attributes_PUB.G_MISS_CON_REC;
    g_db_CON_rec                   := QP_Attributes_PUB.G_MISS_CON_REC;

END Clear_Con;

END QP_QP_Form_Con;

/
