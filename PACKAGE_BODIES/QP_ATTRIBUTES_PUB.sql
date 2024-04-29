--------------------------------------------------------
--  DDL for Package Body QP_ATTRIBUTES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_ATTRIBUTES_PUB" AS
/* $Header: QPXPATRB.pls 120.2 2005/07/06 04:52:05 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Attributes_PUB';

--  Forward declaration of Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_CON_rec                       IN  Con_Rec_Type
,   p_SEG_tbl                       IN  Seg_Tbl_Type
,   x_CON_val_rec                   OUT NOCOPY /* file.sql.39 change */ Con_Val_Rec_Type
,   x_SEG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Seg_Val_Tbl_Type
);

--  Forward declaration of procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CON_rec                       IN  Con_Rec_Type
,   p_CON_val_rec                   IN  Con_Val_Rec_Type
,   p_SEG_tbl                       IN  Seg_Tbl_Type
,   p_SEG_val_tbl                   IN  Seg_Val_Tbl_Type
,   x_CON_rec                       OUT NOCOPY /* file.sql.39 change */ Con_Rec_Type
,   x_SEG_tbl                       OUT NOCOPY /* file.sql.39 change */ Seg_Tbl_Type
);

--  Start of Comments
--  API name    Process_Attributes
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Process_Attributes
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CON_rec                       IN  Con_Rec_Type :=
                                        G_MISS_CON_REC
,   p_CON_val_rec                   IN  Con_Val_Rec_Type :=
                                        G_MISS_CON_VAL_REC
,   p_SEG_tbl                       IN  Seg_Tbl_Type :=
                                        G_MISS_SEG_TBL
,   p_SEG_val_tbl                   IN  Seg_Val_Tbl_Type :=
                                        G_MISS_SEG_VAL_TBL
,   x_CON_rec                       OUT NOCOPY /* file.sql.39 change */ Con_Rec_Type
,   x_CON_val_rec                   OUT NOCOPY /* file.sql.39 change */ Con_Val_Rec_Type
,   x_SEG_tbl                       OUT NOCOPY /* file.sql.39 change */ Seg_Tbl_Type
,   x_SEG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Seg_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Attributes';
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_CON_rec                     Con_Rec_Type;
l_p_CON_rec                     Con_Rec_Type;
l_SEG_tbl                     Seg_Tbl_Type;
l_p_SEG_tbl                     Seg_Tbl_Type;
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Perform Value to Id conversion

    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_CON_rec                     => p_CON_rec
    ,   p_CON_val_rec                 => p_CON_val_rec
    ,   p_SEG_tbl                     => p_SEG_tbl
    ,   p_SEG_val_tbl                 => p_SEG_val_tbl
    ,   x_CON_rec                     => l_CON_rec
    ,   x_SEG_tbl                     => l_SEG_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call QP_Attributes_PVT.Process_Attributes

    l_p_CON_rec := l_CON_rec;
    l_p_SEG_tbl := l_SEG_tbl;

    QP_Attributes_PVT.Process_Attributes
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_commit                      => p_commit
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_CON_rec                     => l_p_CON_rec
    ,   p_SEG_tbl                     => l_p_SEG_tbl
    ,   x_CON_rec                     => l_CON_rec
    ,   x_SEG_tbl                     => l_SEG_tbl
    );

    --  Load Id OUT parameters.

    x_CON_rec                      := l_CON_rec;
    x_SEG_tbl                      := l_SEG_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_CON_rec                     => l_CON_rec
        ,   p_SEG_tbl                     => l_SEG_tbl
        ,   x_CON_val_rec                 => x_CON_val_rec
        ,   x_SEG_val_tbl                 => x_SEG_val_tbl
        );

    END IF;

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
            ,   'Process_Attributes'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Attributes;

--  Start of Comments
--  API name    Lock_Attributes
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Lock_Attributes
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CON_rec                       IN  Con_Rec_Type :=
                                        G_MISS_CON_REC
,   p_CON_val_rec                   IN  Con_Val_Rec_Type :=
                                        G_MISS_CON_VAL_REC
,   p_SEG_tbl                       IN  Seg_Tbl_Type :=
                                        G_MISS_SEG_TBL
,   p_SEG_val_tbl                   IN  Seg_Val_Tbl_Type :=
                                        G_MISS_SEG_VAL_TBL
,   x_CON_rec                       OUT NOCOPY /* file.sql.39 change */ Con_Rec_Type
,   x_CON_val_rec                   OUT NOCOPY /* file.sql.39 change */ Con_Val_Rec_Type
,   x_SEG_tbl                       OUT NOCOPY /* file.sql.39 change */ Seg_Tbl_Type
,   x_SEG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Seg_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Attributes';
l_return_status               VARCHAR2(1);
l_CON_rec                     Con_Rec_Type;
l_p_CON_rec                     Con_Rec_Type;
l_SEG_tbl                     Seg_Tbl_Type;
l_p_SEG_tbl                     Seg_Tbl_Type;
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Perform Value to Id conversion

    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_CON_rec                     => p_CON_rec
    ,   p_CON_val_rec                 => p_CON_val_rec
    ,   p_SEG_tbl                     => p_SEG_tbl
    ,   p_SEG_val_tbl                 => p_SEG_val_tbl
    ,   x_CON_rec                     => l_CON_rec
    ,   x_SEG_tbl                     => l_SEG_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call QP_Attributes_PVT.Lock_Attributes
    l_p_CON_rec := l_CON_rec;
    l_p_SEG_tbl := l_SEG_tbl;
    QP_Attributes_PVT.Lock_Attributes
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_CON_rec                     => l_p_CON_rec
    ,   p_SEG_tbl                     => l_p_SEG_tbl
    ,   x_CON_rec                     => l_CON_rec
    ,   x_SEG_tbl                     => l_SEG_tbl
    );

    --  Load Id OUT parameters.

    x_CON_rec                      := l_CON_rec;
    x_SEG_tbl                      := l_SEG_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_CON_rec                     => l_CON_rec
        ,   p_SEG_tbl                     => l_SEG_tbl
        ,   x_CON_val_rec                 => x_CON_val_rec
        ,   x_SEG_val_tbl                 => x_SEG_val_tbl
        );

    END IF;

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
            ,   'Lock_Attributes'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Lock_Attributes;

--  Start of Comments
--  API name    Get_Attributes
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Get_Attributes
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_prc_context_id                IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_prc_context                   IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_CON_rec                       OUT NOCOPY /* file.sql.39 change */ Con_Rec_Type
,   x_CON_val_rec                   OUT NOCOPY /* file.sql.39 change */ Con_Val_Rec_Type
,   x_SEG_tbl                       OUT NOCOPY /* file.sql.39 change */ Seg_Tbl_Type
,   x_SEG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Seg_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Attributes';
l_prc_context_id              NUMBER := p_prc_context_id;
l_CON_rec                     QP_Attributes_PUB.Con_Rec_Type;
l_SEG_tbl                     QP_Attributes_PUB.Seg_Tbl_Type;
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Standard check for Val/ID conversion

    IF  p_prc_context = FND_API.G_MISS_CHAR
    THEN

        l_prc_context_id := p_prc_context_id;

    ELSIF p_prc_context_id <> FND_API.G_MISS_NUM THEN

        l_prc_context_id := p_prc_context_id;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','prc_context');
            OE_MSG_PUB.Add;

        END IF;

    ELSE

        --  Convert Value to Id

        l_prc_context_id := QP_Value_To_Id.prc_context
        (   p_prc_context                 => p_prc_context
        );

        IF l_prc_context_id = FND_API.G_MISS_NUM THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

                FND_MESSAGE.SET_NAME('QP','Invalid Business Object Value');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','prc_context');
                OE_MSG_PUB.Add;

            END IF;
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;


    --  Call QP_Attributes_PVT.Get_Attributes

    QP_Attributes_PVT.Get_Attributes
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_prc_context_id              => l_prc_context_id
    ,   x_CON_rec                     => l_CON_rec
    ,   x_SEG_tbl                     => l_SEG_tbl
    );

    --  Load Id OUT parameters.

    x_CON_rec                      := l_CON_rec;
    x_SEG_tbl                      := l_SEG_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.TO_BOOLEAN(p_return_values) THEN

        Id_To_Value
        (   p_CON_rec                     => l_CON_rec
        ,   p_SEG_tbl                     => l_SEG_tbl
        ,   x_CON_val_rec                 => x_CON_val_rec
        ,   x_SEG_val_tbl                 => x_SEG_val_tbl
        );

    END IF;

    --  Set return status

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
            ,   'Get_Attributes'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Attributes;

--  Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_CON_rec                       IN  Con_Rec_Type
,   p_SEG_tbl                       IN  Seg_Tbl_Type
,   x_CON_val_rec                   OUT NOCOPY /* file.sql.39 change */ Con_Val_Rec_Type
,   x_SEG_val_tbl                   OUT NOCOPY /* file.sql.39 change */ Seg_Val_Tbl_Type
)
IS
BEGIN

    --  Convert CON

    x_CON_val_rec := QP_Con_Util.Get_Values(p_CON_rec);

    --  Convert SEG

    FOR I IN 1..p_SEG_tbl.COUNT LOOP
        x_SEG_val_tbl(I) :=
            QP_Seg_Util.Get_Values(p_SEG_tbl(I));
    END LOOP;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Id_To_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Id_To_Value;

--  Procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CON_rec                       IN  Con_Rec_Type
,   p_CON_val_rec                   IN  Con_Val_Rec_Type
,   p_SEG_tbl                       IN  Seg_Tbl_Type
,   p_SEG_val_tbl                   IN  Seg_Val_Tbl_Type
,   x_CON_rec                       OUT NOCOPY /* file.sql.39 change */ Con_Rec_Type
,   x_SEG_tbl                       OUT NOCOPY /* file.sql.39 change */ Seg_Tbl_Type
)
IS
l_CON_rec                     Con_Rec_Type;
l_SEG_rec                     Seg_Rec_Type;
l_index                       BINARY_INTEGER;
BEGIN

    --  Init x_return_status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Convert CON

    l_CON_rec := QP_Con_Util.Get_Ids
    (   p_CON_rec                     => p_CON_rec
    ,   p_CON_val_rec                 => p_CON_val_rec
    );

    x_CON_rec                      := l_CON_rec;

    IF l_CON_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    --  Convert SEG

    x_SEG_tbl := p_SEG_tbl;

    l_index := p_SEG_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        l_SEG_rec := QP_Seg_Util.Get_Ids
        (   p_SEG_rec                     => p_SEG_tbl(l_index)
        ,   p_SEG_val_rec                 => p_SEG_val_tbl(l_index)
        );

        x_SEG_tbl(l_index)             := l_SEG_rec;

        IF l_SEG_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_SEG_val_tbl.NEXT(l_index);

    END LOOP;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Value_To_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Value_To_Id;

END QP_Attributes_PUB;

/
