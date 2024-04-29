--------------------------------------------------------
--  DDL for Package Body QP_QP_FORM_PSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_QP_FORM_PSG" AS
/* $Header: QPXFPSGB.pls 120.2 2005/07/18 18:33:10 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_QP_Form_Psg';

--  Global variables holding cached record.

g_PSG_rec                     QP_Attr_Map_PUB.Psg_Rec_Type;
g_db_PSG_rec                  QP_Attr_Map_PUB.Psg_Rec_Type;

--  Forward declaration of procedures maintaining entity record cache.

PROCEDURE Write_PSG
(   p_PSG_rec                       IN  QP_Attr_Map_PUB.Psg_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
);

FUNCTION Get_PSG
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_segment_pte_id                IN  NUMBER
)
RETURN QP_Attr_Map_PUB.Psg_Rec_Type;

PROCEDURE Clear_PSG;

--  Global variable holding performed operations.

g_opr__tbl                    QP_Attr_Map_PUB.Psg_Tbl_Type;

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
,   x_limits_enabled                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_lov_enabled                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pte_code                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_sourcing_method        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_segment_id                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_segment_level                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_segment_pte_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_sourcing_enabled              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_sourcing_status               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_user_sourcing_method          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pte                           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_segment                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_segment_pte                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_PSG_rec                     QP_Attr_Map_PUB.Psg_Rec_Type;
l_PSG_val_rec                 QP_Attr_Map_PUB.Psg_Val_Rec_Type;
l_PSG_tbl                     QP_Attr_Map_PUB.Psg_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_PTE_rec                   QP_Attr_Map_PUB.Pte_Rec_Type;
l_x_RQT_rec                   QP_Attr_Map_PUB.Rqt_Rec_Type;
l_x_RQT_tbl                   QP_Attr_Map_PUB.Rqt_Tbl_Type;
l_x_SSC_rec                   QP_Attr_Map_PUB.Ssc_Rec_Type;
l_x_SSC_tbl                   QP_Attr_Map_PUB.Ssc_Tbl_Type;
l_x_PSG_rec                   QP_Attr_Map_PUB.Psg_Rec_Type;
l_x_PSG_tbl                   QP_Attr_Map_PUB.Psg_Tbl_Type;
l_x_SOU_rec                   QP_Attr_Map_PUB.Sou_Rec_Type;
l_x_SOU_tbl                   QP_Attr_Map_PUB.Sou_Tbl_Type;
l_x_FNA_rec                   QP_Attr_Map_PUB.Fna_Rec_Type;
l_x_FNA_tbl                   QP_Attr_Map_PUB.Fna_Tbl_Type;
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

    l_PSG_rec.attribute1                          := NULL;
    l_PSG_rec.attribute10                         := NULL;
    l_PSG_rec.attribute11                         := NULL;
    l_PSG_rec.attribute12                         := NULL;
    l_PSG_rec.attribute13                         := NULL;
    l_PSG_rec.attribute14                         := NULL;
    l_PSG_rec.attribute15                         := NULL;
    l_PSG_rec.attribute2                          := NULL;
    l_PSG_rec.attribute3                          := NULL;
    l_PSG_rec.attribute4                          := NULL;
    l_PSG_rec.attribute5                          := NULL;
    l_PSG_rec.attribute6                          := NULL;
    l_PSG_rec.attribute7                          := NULL;
    l_PSG_rec.attribute8                          := NULL;
    l_PSG_rec.attribute9                          := NULL;
    l_PSG_rec.context                             := NULL;

    --  Set Operation to Create

    l_PSG_rec.operation := QP_GLOBALS.G_OPR_CREATE;

    --  Populate PSG table

    l_PSG_tbl(1) := l_PSG_rec;

    --  Call QP_Attr_Map_PVT.Process_Attr_Mapping

    QP_Attr_Map_PVT.Process_Attr_Mapping
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PSG_tbl                     => l_PSG_tbl
    ,   x_PTE_rec                     => l_x_PTE_rec
    ,   x_RQT_tbl                     => l_x_RQT_tbl
    ,   x_SSC_tbl                     => l_x_SSC_tbl
    ,   x_PSG_tbl                     => l_x_PSG_tbl
    ,   x_SOU_tbl                     => l_x_SOU_tbl
    ,   x_FNA_tbl                     => l_x_FNA_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl

    l_x_PSG_rec := l_x_PSG_tbl(1);

    --  Load OUT parameters.

    x_attribute1                   := l_x_PSG_rec.attribute1;
    x_attribute10                  := l_x_PSG_rec.attribute10;
    x_attribute11                  := l_x_PSG_rec.attribute11;
    x_attribute12                  := l_x_PSG_rec.attribute12;
    x_attribute13                  := l_x_PSG_rec.attribute13;
    x_attribute14                  := l_x_PSG_rec.attribute14;
    x_attribute15                  := l_x_PSG_rec.attribute15;
    x_attribute2                   := l_x_PSG_rec.attribute2;
    x_attribute3                   := l_x_PSG_rec.attribute3;
    x_attribute4                   := l_x_PSG_rec.attribute4;
    x_attribute5                   := l_x_PSG_rec.attribute5;
    x_attribute6                   := l_x_PSG_rec.attribute6;
    x_attribute7                   := l_x_PSG_rec.attribute7;
    x_attribute8                   := l_x_PSG_rec.attribute8;
    x_attribute9                   := l_x_PSG_rec.attribute9;
    x_context                      := l_x_PSG_rec.context;
    x_limits_enabled               := l_x_PSG_rec.limits_enabled;
    x_lov_enabled                  := l_x_PSG_rec.lov_enabled;
    x_pte_code                     := l_x_PSG_rec.pte_code;
    x_seeded_sourcing_method       := l_x_PSG_rec.seeded_sourcing_method;
    x_segment_id                   := l_x_PSG_rec.segment_id;
    x_segment_level                := l_x_PSG_rec.segment_level;
    x_segment_pte_id               := l_x_PSG_rec.segment_pte_id;
    x_sourcing_enabled             := l_x_PSG_rec.sourcing_enabled;
    x_sourcing_status              := l_x_PSG_rec.sourcing_status;
    x_user_sourcing_method         := l_x_PSG_rec.user_sourcing_method;

    --  Load display out parameters if any

    l_PSG_val_rec := QP_Psg_Util.Get_Values
    (   p_PSG_rec                     => l_x_PSG_rec
    );
    x_pte                          := l_PSG_val_rec.pte;
    x_segment                      := l_PSG_val_rec.segment;
    x_segment_pte                  := l_PSG_val_rec.segment_pte;

    --  Write to cache.
    --  Set db_flag to False before writing to cache

    l_x_PSG_rec.db_flag := FND_API.G_FALSE;

    Write_PSG
    (   p_PSG_rec                     => l_x_PSG_rec
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
,   p_segment_pte_id                IN  NUMBER
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
,   x_limits_enabled                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_lov_enabled                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pte_code                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_seeded_sourcing_method        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_segment_id                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_segment_level                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_segment_pte_id                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_sourcing_enabled              OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_sourcing_status               OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_user_sourcing_method          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_pte                           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_segment                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_segment_pte                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_PSG_rec                     QP_Attr_Map_PUB.Psg_Rec_Type;
l_old_PSG_rec                 QP_Attr_Map_PUB.Psg_Rec_Type;
l_PSG_val_rec                 QP_Attr_Map_PUB.Psg_Val_Rec_Type;
l_PSG_tbl                     QP_Attr_Map_PUB.Psg_Tbl_Type;
l_old_PSG_tbl                 QP_Attr_Map_PUB.Psg_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_PTE_rec                   QP_Attr_Map_PUB.Pte_Rec_Type;
l_x_RQT_rec                   QP_Attr_Map_PUB.Rqt_Rec_Type;
l_x_RQT_tbl                   QP_Attr_Map_PUB.Rqt_Tbl_Type;
l_x_SSC_rec                   QP_Attr_Map_PUB.Ssc_Rec_Type;
l_x_SSC_tbl                   QP_Attr_Map_PUB.Ssc_Tbl_Type;
l_x_PSG_rec                   QP_Attr_Map_PUB.Psg_Rec_Type;
l_x_PSG_tbl                   QP_Attr_Map_PUB.Psg_Tbl_Type;
l_x_SOU_rec                   QP_Attr_Map_PUB.Sou_Rec_Type;
l_x_SOU_tbl                   QP_Attr_Map_PUB.Sou_Tbl_Type;
l_x_FNA_rec                   QP_Attr_Map_PUB.Fna_Rec_Type;
l_x_FNA_tbl                   QP_Attr_Map_PUB.Fna_Tbl_Type;
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

    --  Read PSG from cache

    l_PSG_rec := Get_PSG
    (   p_db_record                   => FALSE
    ,   p_segment_pte_id              => p_segment_pte_id
    );

    l_old_PSG_rec                  := l_PSG_rec;

    IF p_attr_id = QP_Psg_Util.G_LIMITS_ENABLED THEN
        l_PSG_rec.limits_enabled := p_attr_value;
    ELSIF p_attr_id = QP_Psg_Util.G_LOV_ENABLED THEN
        l_PSG_rec.lov_enabled := p_attr_value;
    ELSIF p_attr_id = QP_Psg_Util.G_PTE THEN
        l_PSG_rec.pte_code := p_attr_value;
    ELSIF p_attr_id = QP_Psg_Util.G_SEEDED_SOURCING_METHOD THEN
        l_PSG_rec.seeded_sourcing_method := p_attr_value;
    ELSIF p_attr_id = QP_Psg_Util.G_SEGMENT THEN
        l_PSG_rec.segment_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Psg_Util.G_SEGMENT_LEVEL THEN
        l_PSG_rec.segment_level := p_attr_value;
    ELSIF p_attr_id = QP_Psg_Util.G_SEGMENT_PTE THEN
        l_PSG_rec.segment_pte_id := TO_NUMBER(p_attr_value);
    ELSIF p_attr_id = QP_Psg_Util.G_SOURCING_ENABLED THEN
        l_PSG_rec.sourcing_enabled := p_attr_value;
    ELSIF p_attr_id = QP_Psg_Util.G_SOURCING_STATUS THEN
        l_PSG_rec.sourcing_status := p_attr_value;
    ELSIF p_attr_id = QP_Psg_Util.G_USER_SOURCING_METHOD THEN
        l_PSG_rec.user_sourcing_method := p_attr_value;
    ELSIF p_attr_id = QP_Psg_Util.G_ATTRIBUTE1
    OR     p_attr_id = QP_Psg_Util.G_ATTRIBUTE10
    OR     p_attr_id = QP_Psg_Util.G_ATTRIBUTE11
    OR     p_attr_id = QP_Psg_Util.G_ATTRIBUTE12
    OR     p_attr_id = QP_Psg_Util.G_ATTRIBUTE13
    OR     p_attr_id = QP_Psg_Util.G_ATTRIBUTE14
    OR     p_attr_id = QP_Psg_Util.G_ATTRIBUTE15
    OR     p_attr_id = QP_Psg_Util.G_ATTRIBUTE2
    OR     p_attr_id = QP_Psg_Util.G_ATTRIBUTE3
    OR     p_attr_id = QP_Psg_Util.G_ATTRIBUTE4
    OR     p_attr_id = QP_Psg_Util.G_ATTRIBUTE5
    OR     p_attr_id = QP_Psg_Util.G_ATTRIBUTE6
    OR     p_attr_id = QP_Psg_Util.G_ATTRIBUTE7
    OR     p_attr_id = QP_Psg_Util.G_ATTRIBUTE8
    OR     p_attr_id = QP_Psg_Util.G_ATTRIBUTE9
    OR     p_attr_id = QP_Psg_Util.G_CONTEXT
    THEN

        l_PSG_rec.attribute1           := p_attribute1;
        l_PSG_rec.attribute10          := p_attribute10;
        l_PSG_rec.attribute11          := p_attribute11;
        l_PSG_rec.attribute12          := p_attribute12;
        l_PSG_rec.attribute13          := p_attribute13;
        l_PSG_rec.attribute14          := p_attribute14;
        l_PSG_rec.attribute15          := p_attribute15;
        l_PSG_rec.attribute2           := p_attribute2;
        l_PSG_rec.attribute3           := p_attribute3;
        l_PSG_rec.attribute4           := p_attribute4;
        l_PSG_rec.attribute5           := p_attribute5;
        l_PSG_rec.attribute6           := p_attribute6;
        l_PSG_rec.attribute7           := p_attribute7;
        l_PSG_rec.attribute8           := p_attribute8;
        l_PSG_rec.attribute9           := p_attribute9;
        l_PSG_rec.context              := p_context;

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

    IF FND_API.To_Boolean(l_PSG_rec.db_flag) THEN
        l_PSG_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_PSG_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate PSG table

    l_PSG_tbl(1) := l_PSG_rec;
    l_old_PSG_tbl(1) := l_old_PSG_rec;

    --  Call QP_Attr_Map_PVT.Process_Attr_Mapping

    QP_Attr_Map_PVT.Process_Attr_Mapping
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_NONE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PSG_tbl                     => l_PSG_tbl
    ,   p_old_PSG_tbl                 => l_old_PSG_tbl
    ,   x_PTE_rec                     => l_x_PTE_rec
    ,   x_RQT_tbl                     => l_x_RQT_tbl
    ,   x_SSC_tbl                     => l_x_SSC_tbl
    ,   x_PSG_tbl                     => l_x_PSG_tbl
    ,   x_SOU_tbl                     => l_x_SOU_tbl
    ,   x_FNA_tbl                     => l_x_FNA_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Unload out tbl

    l_x_PSG_rec := l_x_PSG_tbl(1);

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
    x_limits_enabled               := FND_API.G_MISS_CHAR;
    x_lov_enabled                  := FND_API.G_MISS_CHAR;
    x_pte_code                     := FND_API.G_MISS_CHAR;
    x_seeded_sourcing_method       := FND_API.G_MISS_CHAR;
    x_segment_id                   := FND_API.G_MISS_NUM;
    x_segment_level                := FND_API.G_MISS_CHAR;
    x_segment_pte_id               := FND_API.G_MISS_NUM;
    x_sourcing_enabled             := FND_API.G_MISS_CHAR;
    x_sourcing_status              := FND_API.G_MISS_CHAR;
    x_user_sourcing_method         := FND_API.G_MISS_CHAR;
    x_pte                          := FND_API.G_MISS_CHAR;
    x_segment                      := FND_API.G_MISS_CHAR;
    x_segment_pte                  := FND_API.G_MISS_CHAR;

    --  Load display out parameters if any

    l_PSG_val_rec := QP_Psg_Util.Get_Values
    (   p_PSG_rec                     => l_x_PSG_rec
    ,   p_old_PSG_rec                 => l_PSG_rec
    );

    --  Return changed attributes.

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.attribute1,
                            l_PSG_rec.attribute1)
    THEN
        x_attribute1 := l_x_PSG_rec.attribute1;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.attribute10,
                            l_PSG_rec.attribute10)
    THEN
        x_attribute10 := l_x_PSG_rec.attribute10;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.attribute11,
                            l_PSG_rec.attribute11)
    THEN
        x_attribute11 := l_x_PSG_rec.attribute11;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.attribute12,
                            l_PSG_rec.attribute12)
    THEN
        x_attribute12 := l_x_PSG_rec.attribute12;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.attribute13,
                            l_PSG_rec.attribute13)
    THEN
        x_attribute13 := l_x_PSG_rec.attribute13;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.attribute14,
                            l_PSG_rec.attribute14)
    THEN
        x_attribute14 := l_x_PSG_rec.attribute14;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.attribute15,
                            l_PSG_rec.attribute15)
    THEN
        x_attribute15 := l_x_PSG_rec.attribute15;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.attribute2,
                            l_PSG_rec.attribute2)
    THEN
        x_attribute2 := l_x_PSG_rec.attribute2;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.attribute3,
                            l_PSG_rec.attribute3)
    THEN
        x_attribute3 := l_x_PSG_rec.attribute3;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.attribute4,
                            l_PSG_rec.attribute4)
    THEN
        x_attribute4 := l_x_PSG_rec.attribute4;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.attribute5,
                            l_PSG_rec.attribute5)
    THEN
        x_attribute5 := l_x_PSG_rec.attribute5;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.attribute6,
                            l_PSG_rec.attribute6)
    THEN
        x_attribute6 := l_x_PSG_rec.attribute6;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.attribute7,
                            l_PSG_rec.attribute7)
    THEN
        x_attribute7 := l_x_PSG_rec.attribute7;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.attribute8,
                            l_PSG_rec.attribute8)
    THEN
        x_attribute8 := l_x_PSG_rec.attribute8;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.attribute9,
                            l_PSG_rec.attribute9)
    THEN
        x_attribute9 := l_x_PSG_rec.attribute9;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.context,
                            l_PSG_rec.context)
    THEN
        x_context := l_x_PSG_rec.context;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.limits_enabled,
                            l_PSG_rec.limits_enabled)
    THEN
        x_limits_enabled := l_x_PSG_rec.limits_enabled;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.lov_enabled,
                            l_PSG_rec.lov_enabled)
    THEN
        x_lov_enabled := l_x_PSG_rec.lov_enabled;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.pte_code,
                            l_PSG_rec.pte_code)
    THEN
        x_pte_code := l_x_PSG_rec.pte_code;
        x_pte := l_PSG_val_rec.pte;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.seeded_sourcing_method,
                            l_PSG_rec.seeded_sourcing_method)
    THEN
        x_seeded_sourcing_method := l_x_PSG_rec.seeded_sourcing_method;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.segment_id,
                            l_PSG_rec.segment_id)
    THEN
        x_segment_id := l_x_PSG_rec.segment_id;
        x_segment := l_PSG_val_rec.segment;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.segment_level,
                            l_PSG_rec.segment_level)
    THEN
        x_segment_level := l_x_PSG_rec.segment_level;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.segment_pte_id,
                            l_PSG_rec.segment_pte_id)
    THEN
        x_segment_pte_id := l_x_PSG_rec.segment_pte_id;
        x_segment_pte := l_PSG_val_rec.segment_pte;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.sourcing_enabled,
                            l_PSG_rec.sourcing_enabled)
    THEN
        x_sourcing_enabled := l_x_PSG_rec.sourcing_enabled;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.sourcing_status,
                            l_PSG_rec.sourcing_status)
    THEN
        x_sourcing_status := l_x_PSG_rec.sourcing_status;
    END IF;

    IF NOT QP_GLOBALS.Equal(l_x_PSG_rec.user_sourcing_method,
                            l_PSG_rec.user_sourcing_method)
    THEN
        x_user_sourcing_method := l_x_PSG_rec.user_sourcing_method;
    END IF;


    --  Write to cache.

    Write_PSG
    (   p_PSG_rec                     => l_x_PSG_rec
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
,   p_segment_pte_id                IN  NUMBER
,   x_creation_date                 OUT NOCOPY /* file.sql.39 change */ DATE
,   x_created_by                    OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_date              OUT NOCOPY /* file.sql.39 change */ DATE
,   x_last_updated_by               OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_last_update_login             OUT NOCOPY /* file.sql.39 change */ NUMBER
)
IS
l_PSG_rec                     QP_Attr_Map_PUB.Psg_Rec_Type;
l_old_PSG_rec                 QP_Attr_Map_PUB.Psg_Rec_Type;
l_PSG_tbl                     QP_Attr_Map_PUB.Psg_Tbl_Type;
l_old_PSG_tbl                 QP_Attr_Map_PUB.Psg_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_PTE_rec                   QP_Attr_Map_PUB.Pte_Rec_Type;
l_x_RQT_rec                   QP_Attr_Map_PUB.Rqt_Rec_Type;
l_x_RQT_tbl                   QP_Attr_Map_PUB.Rqt_Tbl_Type;
l_x_SSC_rec                   QP_Attr_Map_PUB.Ssc_Rec_Type;
l_x_SSC_tbl                   QP_Attr_Map_PUB.Ssc_Tbl_Type;
l_x_PSG_rec                   QP_Attr_Map_PUB.Psg_Rec_Type;
l_x_PSG_tbl                   QP_Attr_Map_PUB.Psg_Tbl_Type;
l_x_SOU_rec                   QP_Attr_Map_PUB.Sou_Rec_Type;
l_x_SOU_tbl                   QP_Attr_Map_PUB.Sou_Tbl_Type;
l_x_FNA_rec                   QP_Attr_Map_PUB.Fna_Rec_Type;
l_x_FNA_tbl                   QP_Attr_Map_PUB.Fna_Tbl_Type;
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

    --  Read PSG from cache

    l_old_PSG_rec := Get_PSG
    (   p_db_record                   => TRUE
    ,   p_segment_pte_id              => p_segment_pte_id
    );

    l_PSG_rec := Get_PSG
    (   p_db_record                   => FALSE
    ,   p_segment_pte_id              => p_segment_pte_id
    );

    --  Set Operation.

    IF FND_API.To_Boolean(l_PSG_rec.db_flag) THEN
        l_PSG_rec.operation := QP_GLOBALS.G_OPR_UPDATE;
    ELSE
        l_PSG_rec.operation := QP_GLOBALS.G_OPR_CREATE;
    END IF;

    --  Populate PSG table

    l_PSG_tbl(1) := l_PSG_rec;
    l_old_PSG_tbl(1) := l_old_PSG_rec;

    --  Call QP_Attr_Map_PVT.Process_Attr_Mapping

    QP_Attr_Map_PVT.Process_Attr_Mapping
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PSG_tbl                     => l_PSG_tbl
    ,   p_old_PSG_tbl                 => l_old_PSG_tbl
    ,   x_PTE_rec                     => l_x_PTE_rec
    ,   x_RQT_tbl                     => l_x_RQT_tbl
    ,   x_SSC_tbl                     => l_x_SSC_tbl
    ,   x_PSG_tbl                     => l_x_PSG_tbl
    ,   x_SOU_tbl                     => l_x_SOU_tbl
    ,   x_FNA_tbl                     => l_x_FNA_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Load OUT parameters.

    l_x_PSG_rec := l_x_PSG_tbl(1);

    x_creation_date                := l_x_PSG_rec.creation_date;
    x_created_by                   := l_x_PSG_rec.created_by;
    x_last_update_date             := l_x_PSG_rec.last_update_date;
    x_last_updated_by              := l_x_PSG_rec.last_updated_by;
    x_last_update_login            := l_x_PSG_rec.last_update_login;

    --  Clear PSG record cache

    Clear_PSG;

    --  Keep track of performed operations.

    l_old_PSG_rec.operation := l_PSG_rec.operation;


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
,   p_segment_pte_id                IN  NUMBER
)
IS
l_PSG_rec                     QP_Attr_Map_PUB.Psg_Rec_Type;
l_PSG_tbl                     QP_Attr_Map_PUB.Psg_Tbl_Type;
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_x_PTE_rec                   QP_Attr_Map_PUB.Pte_Rec_Type;
l_x_RQT_rec                   QP_Attr_Map_PUB.Rqt_Rec_Type;
l_x_RQT_tbl                   QP_Attr_Map_PUB.Rqt_Tbl_Type;
l_x_SSC_rec                   QP_Attr_Map_PUB.Ssc_Rec_Type;
l_x_SSC_tbl                   QP_Attr_Map_PUB.Ssc_Tbl_Type;
l_x_PSG_rec                   QP_Attr_Map_PUB.Psg_Rec_Type;
l_x_PSG_tbl                   QP_Attr_Map_PUB.Psg_Tbl_Type;
l_x_SOU_rec                   QP_Attr_Map_PUB.Sou_Rec_Type;
l_x_SOU_tbl                   QP_Attr_Map_PUB.Sou_Tbl_Type;
l_x_FNA_rec                   QP_Attr_Map_PUB.Fna_Rec_Type;
l_x_FNA_tbl                   QP_Attr_Map_PUB.Fna_Tbl_Type;
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

    l_PSG_rec := Get_PSG
    (   p_db_record                   => TRUE
    ,   p_segment_pte_id              => p_segment_pte_id
    );

    --  Set Operation.

    l_PSG_rec.operation := QP_GLOBALS.G_OPR_DELETE;

    --  Populate PSG table

    l_PSG_tbl(1) := l_PSG_rec;

    --  Call QP_Attr_Map_PVT.Process_Attr_Mapping

    QP_Attr_Map_PVT.Process_Attr_Mapping
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PSG_tbl                     => l_PSG_tbl
    ,   x_PTE_rec                     => l_x_PTE_rec
    ,   x_RQT_tbl                     => l_x_RQT_tbl
    ,   x_SSC_tbl                     => l_x_SSC_tbl
    ,   x_PSG_tbl                     => l_x_PSG_tbl
    ,   x_SOU_tbl                     => l_x_SOU_tbl
    ,   x_FNA_tbl                     => l_x_FNA_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Clear PSG record cache

    Clear_PSG;

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
l_x_PTE_rec                   QP_Attr_Map_PUB.Pte_Rec_Type;
l_x_RQT_rec                   QP_Attr_Map_PUB.Rqt_Rec_Type;
l_x_RQT_tbl                   QP_Attr_Map_PUB.Rqt_Tbl_Type;
l_x_SSC_rec                   QP_Attr_Map_PUB.Ssc_Rec_Type;
l_x_SSC_tbl                   QP_Attr_Map_PUB.Ssc_Tbl_Type;
l_x_PSG_rec                   QP_Attr_Map_PUB.Psg_Rec_Type;
l_x_PSG_tbl                   QP_Attr_Map_PUB.Psg_Tbl_Type;
l_x_SOU_rec                   QP_Attr_Map_PUB.Sou_Rec_Type;
l_x_SOU_tbl                   QP_Attr_Map_PUB.Sou_Tbl_Type;
l_x_FNA_rec                   QP_Attr_Map_PUB.Fna_Rec_Type;
l_x_FNA_tbl                   QP_Attr_Map_PUB.Fna_Tbl_Type;
BEGIN

    --  Set control flags.

    l_control_rec.controlled_operation := TRUE;
    l_control_rec.process              := TRUE;
    l_control_rec.process_entity       := QP_GLOBALS.G_ENTITY_PSG;

    l_control_rec.default_attributes   := FALSE;
    l_control_rec.change_attributes    := FALSE;
    l_control_rec.validate_entity      := FALSE;
    l_control_rec.write_to_DB          := FALSE;

    --  Instruct API to clear its request table

    l_control_rec.clear_api_cache      := FALSE;
    l_control_rec.clear_api_requests   := FALSE;

    --  Call QP_Attr_Map_PVT.Process_Attr_Mapping

    QP_Attr_Map_PVT.Process_Attr_Mapping
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   x_PTE_rec                     => l_x_PTE_rec
    ,   x_RQT_tbl                     => l_x_RQT_tbl
    ,   x_SSC_tbl                     => l_x_SSC_tbl
    ,   x_PSG_tbl                     => l_x_PSG_tbl
    ,   x_SOU_tbl                     => l_x_SOU_tbl
    ,   x_FNA_tbl                     => l_x_FNA_tbl
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
,   p_last_updated_by               IN  NUMBER
,   p_last_update_date              IN  DATE
,   p_last_update_login             IN  NUMBER
,   p_limits_enabled                IN  VARCHAR2
,   p_lov_enabled                   IN  VARCHAR2
,   p_program_application_id        IN  NUMBER
,   p_program_id                    IN  NUMBER
,   p_program_update_date           IN  DATE
,   p_pte_code                      IN  VARCHAR2
,   p_seeded_sourcing_method        IN  VARCHAR2
,   p_segment_id                    IN  NUMBER
,   p_segment_level                 IN  VARCHAR2
,   p_segment_pte_id                IN  NUMBER
,   p_sourcing_enabled              IN  VARCHAR2
,   p_sourcing_status               IN  VARCHAR2
,   p_user_sourcing_method          IN  VARCHAR2
)
IS
l_return_status               VARCHAR2(1);
l_PSG_rec                     QP_Attr_Map_PUB.Psg_Rec_Type;
l_PSG_tbl                     QP_Attr_Map_PUB.Psg_Tbl_Type;
l_x_PTE_rec                   QP_Attr_Map_PUB.Pte_Rec_Type;
l_x_RQT_rec                   QP_Attr_Map_PUB.Rqt_Rec_Type;
l_x_RQT_tbl                   QP_Attr_Map_PUB.Rqt_Tbl_Type;
l_x_SSC_rec                   QP_Attr_Map_PUB.Ssc_Rec_Type;
l_x_SSC_tbl                   QP_Attr_Map_PUB.Ssc_Tbl_Type;
l_x_PSG_rec                   QP_Attr_Map_PUB.Psg_Rec_Type;
l_x_PSG_tbl                   QP_Attr_Map_PUB.Psg_Tbl_Type;
l_x_SOU_rec                   QP_Attr_Map_PUB.Sou_Rec_Type;
l_x_SOU_tbl                   QP_Attr_Map_PUB.Sou_Tbl_Type;
l_x_FNA_rec                   QP_Attr_Map_PUB.Fna_Rec_Type;
l_x_FNA_tbl                   QP_Attr_Map_PUB.Fna_Tbl_Type;
BEGIN

    --  Load PSG record

    l_PSG_rec.attribute1           := p_attribute1;
    l_PSG_rec.attribute10          := p_attribute10;
    l_PSG_rec.attribute11          := p_attribute11;
    l_PSG_rec.attribute12          := p_attribute12;
    l_PSG_rec.attribute13          := p_attribute13;
    l_PSG_rec.attribute14          := p_attribute14;
    l_PSG_rec.attribute15          := p_attribute15;
    l_PSG_rec.attribute2           := p_attribute2;
    l_PSG_rec.attribute3           := p_attribute3;
    l_PSG_rec.attribute4           := p_attribute4;
    l_PSG_rec.attribute5           := p_attribute5;
    l_PSG_rec.attribute6           := p_attribute6;
    l_PSG_rec.attribute7           := p_attribute7;
    l_PSG_rec.attribute8           := p_attribute8;
    l_PSG_rec.attribute9           := p_attribute9;
    l_PSG_rec.context              := p_context;
    l_PSG_rec.created_by           := p_created_by;
    l_PSG_rec.creation_date        := p_creation_date;
    l_PSG_rec.last_updated_by      := p_last_updated_by;
    l_PSG_rec.last_update_date     := p_last_update_date;
    l_PSG_rec.last_update_login    := p_last_update_login;
    l_PSG_rec.limits_enabled       := p_limits_enabled;
    l_PSG_rec.lov_enabled          := p_lov_enabled;
    l_PSG_rec.program_application_id := p_program_application_id;
    l_PSG_rec.program_id           := p_program_id;
    l_PSG_rec.program_update_date  := p_program_update_date;
    l_PSG_rec.pte_code             := p_pte_code;
    l_PSG_rec.seeded_sourcing_method := p_seeded_sourcing_method;
    l_PSG_rec.segment_id           := p_segment_id;
    l_PSG_rec.segment_level        := p_segment_level;
    l_PSG_rec.segment_pte_id       := p_segment_pte_id;
    l_PSG_rec.sourcing_enabled     := p_sourcing_enabled;
    l_PSG_rec.sourcing_status      := p_sourcing_status;
    l_PSG_rec.user_sourcing_method := p_user_sourcing_method;

    --  Populate PSG table

    l_PSG_tbl(1) := l_PSG_rec;

    --  Call QP_Attr_Map_PVT.Lock_Attr_Mapping

    QP_Attr_Map_PVT.Lock_Attr_Mapping
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => FND_API.G_TRUE
    ,   x_return_status               => l_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_PSG_tbl                     => l_PSG_tbl
    ,   x_PTE_rec                     => l_x_PTE_rec
    ,   x_RQT_tbl                     => l_x_RQT_tbl
    ,   x_SSC_tbl                     => l_x_SSC_tbl
    ,   x_PSG_tbl                     => l_x_PSG_tbl
    ,   x_SOU_tbl                     => l_x_SOU_tbl
    ,   x_FNA_tbl                     => l_x_FNA_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --  Set DB flag and write record to cache.

        l_x_PSG_rec.db_flag := FND_API.G_TRUE;

        Write_PSG
        (   p_PSG_rec                     => l_x_PSG_rec
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

--  Procedures maintaining PSG record cache.

PROCEDURE Write_PSG
(   p_PSG_rec                       IN  QP_Attr_Map_PUB.Psg_Rec_Type
,   p_db_record                     IN  BOOLEAN := FALSE
)
IS
BEGIN

    g_PSG_rec := p_PSG_rec;

    IF p_db_record THEN

        g_db_PSG_rec := p_PSG_rec;

    END IF;

END Write_Psg;

FUNCTION Get_PSG
(   p_db_record                     IN  BOOLEAN := FALSE
,   p_segment_pte_id                IN  NUMBER
)
RETURN QP_Attr_Map_PUB.Psg_Rec_Type
IS
BEGIN

    IF  p_segment_pte_id <> g_PSG_rec.segment_pte_id
    THEN

        --  Query row from DB

        g_PSG_rec := QP_Psg_Util.Query_Row
        (   p_segment_pte_id              => p_segment_pte_id
        );

        g_PSG_rec.db_flag              := FND_API.G_TRUE;

        --  Load DB record

        g_db_PSG_rec                   := g_PSG_rec;

    END IF;

    IF p_db_record THEN

        RETURN g_db_PSG_rec;

    ELSE

        RETURN g_PSG_rec;

    END IF;

END Get_Psg;

PROCEDURE Clear_Psg
IS
BEGIN

    g_PSG_rec                      := QP_Attr_Map_PUB.G_MISS_PSG_REC;
    g_db_PSG_rec                   := QP_Attr_Map_PUB.G_MISS_PSG_REC;

END Clear_Psg;

END QP_QP_Form_Psg;

/