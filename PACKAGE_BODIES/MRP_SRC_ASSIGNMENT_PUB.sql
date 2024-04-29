--------------------------------------------------------
--  DDL for Package Body MRP_SRC_ASSIGNMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_SRC_ASSIGNMENT_PUB" AS
/* $Header: MRPPASNB.pls 120.2 2005/06/27 17:09:55 ichoudhu noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Src_Assignment_PUB';

--  Forward declaration of Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_Assignment_Set_rec            IN  Assignment_Set_Rec_Type
,   p_Assignment_tbl                IN  Assignment_Tbl_Type
,   x_Assignment_Set_val_rec        OUT NOCOPY Assignment_Set_Val_Rec_Type
,   x_Assignment_val_tbl            OUT NOCOPY Assignment_Val_Tbl_Type
);

--  Forward declaration of procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_Assignment_Set_rec            IN  Assignment_Set_Rec_Type
,   p_Assignment_Set_val_rec        IN  Assignment_Set_Val_Rec_Type
,   p_Assignment_tbl                IN  Assignment_Tbl_Type
,   p_Assignment_val_tbl            IN  Assignment_Val_Tbl_Type
,   x_Assignment_Set_rec            OUT NOCOPY Assignment_Set_Rec_Type
,   x_Assignment_tbl                OUT NOCOPY Assignment_Tbl_Type
);

--  Start of Comments
--  API name    Process_Assignment
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

PROCEDURE Process_Assignment
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_Assignment_Set_rec            IN  Assignment_Set_Rec_Type :=
                                        G_MISS_ASSIGNMENT_SET_REC
,   p_Assignment_Set_val_rec        IN  Assignment_Set_Val_Rec_Type :=
                                        G_MISS_ASSIGNMENT_SET_VAL_REC
,   p_Assignment_tbl                IN  Assignment_Tbl_Type :=
                                        G_MISS_ASSIGNMENT_TBL
,   p_Assignment_val_tbl            IN  Assignment_Val_Tbl_Type :=
                                        G_MISS_ASSIGNMENT_VAL_TBL
,   x_Assignment_Set_rec            OUT NOCOPY Assignment_Set_Rec_Type
,   x_Assignment_Set_val_rec        OUT NOCOPY Assignment_Set_Val_Rec_Type
,   x_Assignment_tbl                OUT NOCOPY Assignment_Tbl_Type
,   x_Assignment_val_tbl            OUT NOCOPY Assignment_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Assignment';
l_control_rec                 MRP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_Assignment_Set_rec          Assignment_Set_Rec_Type;
l_Assignment_tbl              Assignment_Tbl_Type;
l_Assignment_Set_rec_out          Assignment_Set_Rec_Type;
l_Assignment_tbl_out              Assignment_Tbl_Type;
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
    ,   p_Assignment_Set_rec          => p_Assignment_Set_rec
    ,   p_Assignment_Set_val_rec      => p_Assignment_Set_val_rec
    ,   p_Assignment_tbl              => p_Assignment_tbl
    ,   p_Assignment_val_tbl          => p_Assignment_val_tbl
    ,   x_Assignment_Set_rec          => l_Assignment_Set_rec
    ,   x_Assignment_tbl              => l_Assignment_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call MRP_Assignment_PVT.Process_Assignment

    MRP_Assignment_PVT.Process_Assignment
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_commit                      => p_commit
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Assignment_Set_rec          => l_Assignment_Set_rec
    ,   p_Assignment_tbl              => l_Assignment_tbl
    ,   x_Assignment_Set_rec          => l_Assignment_Set_rec_out
    ,   x_Assignment_tbl              => l_Assignment_tbl_out
    );

    l_Assignment_Set_rec := l_Assignment_Set_rec_out;
    l_Assignment_tbl := l_Assignment_tbl_out;

    --  Load Id OUT parameters.

    x_Assignment_Set_rec           := l_Assignment_Set_rec;
    x_Assignment_tbl               := l_Assignment_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_Assignment_Set_rec          => l_Assignment_Set_rec
        ,   p_Assignment_tbl              => l_Assignment_tbl
        ,   x_Assignment_Set_val_rec      => x_Assignment_Set_val_rec
        ,   x_Assignment_val_tbl          => x_Assignment_val_tbl
        );

    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN


        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Assignment'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Assignment;

--  Start of Comments
--  API name    Lock_Assignment
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

PROCEDURE Lock_Assignment
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_Assignment_Set_rec            IN  Assignment_Set_Rec_Type :=
                                        G_MISS_ASSIGNMENT_SET_REC
,   p_Assignment_Set_val_rec        IN  Assignment_Set_Val_Rec_Type :=
                                        G_MISS_ASSIGNMENT_SET_VAL_REC
,   p_Assignment_tbl                IN  Assignment_Tbl_Type :=
                                        G_MISS_ASSIGNMENT_TBL
,   p_Assignment_val_tbl            IN  Assignment_Val_Tbl_Type :=
                                        G_MISS_ASSIGNMENT_VAL_TBL
,   x_Assignment_Set_rec            OUT NOCOPY Assignment_Set_Rec_Type
,   x_Assignment_Set_val_rec        OUT NOCOPY Assignment_Set_Val_Rec_Type
,   x_Assignment_tbl                OUT NOCOPY Assignment_Tbl_Type
,   x_Assignment_val_tbl            OUT NOCOPY Assignment_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Assignment';
l_return_status               VARCHAR2(1);
l_Assignment_Set_rec          Assignment_Set_Rec_Type;
l_Assignment_tbl              Assignment_Tbl_Type;
l_Assignment_Set_rec_out          Assignment_Set_Rec_Type;
l_Assignment_tbl_out              Assignment_Tbl_Type;
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
    ,   p_Assignment_Set_rec          => p_Assignment_Set_rec
    ,   p_Assignment_Set_val_rec      => p_Assignment_Set_val_rec
    ,   p_Assignment_tbl              => p_Assignment_tbl
    ,   p_Assignment_val_tbl          => p_Assignment_val_tbl
    ,   x_Assignment_Set_rec          => l_Assignment_Set_rec
    ,   x_Assignment_tbl              => l_Assignment_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call MRP_Assignment_PVT.Lock_Assignment

    MRP_Assignment_PVT.Lock_Assignment
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_Assignment_Set_rec          => l_Assignment_Set_rec
    ,   p_Assignment_tbl              => l_Assignment_tbl
    ,   x_Assignment_Set_rec          => l_Assignment_Set_rec_out
    ,   x_Assignment_tbl              => l_Assignment_tbl_out
    );

    l_Assignment_Set_rec := l_Assignment_Set_rec_out;
    l_Assignment_tbl := l_Assignment_tbl_out;
    --  Load Id OUT parameters.

    x_Assignment_Set_rec           := l_Assignment_Set_rec;
    x_Assignment_tbl               := l_Assignment_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_Assignment_Set_rec          => l_Assignment_Set_rec
        ,   p_Assignment_tbl              => l_Assignment_tbl
        ,   x_Assignment_Set_val_rec      => x_Assignment_Set_val_rec
        ,   x_Assignment_val_tbl          => x_Assignment_val_tbl
        );

    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN


        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Assignment'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Lock_Assignment;

--  Start of Comments
--  API name    Get_Assignment
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

PROCEDURE Get_Assignment
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_Assignment_Set_Id             IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_Assignment_Set_rec            OUT NOCOPY Assignment_Set_Rec_Type
,   x_Assignment_Set_val_rec        OUT NOCOPY Assignment_Set_Val_Rec_Type
,   x_Assignment_tbl                OUT NOCOPY Assignment_Tbl_Type
,   x_Assignment_val_tbl            OUT NOCOPY Assignment_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Assignment';
l_Assignment_Set_Id           NUMBER := p_Assignment_Set_Id;
l_Assignment_Set_rec          MRP_Src_Assignment_PUB.Assignment_Set_Rec_Type;
l_Assignment_Set_val_rec      MRP_Src_Assignment_PUB.Assignment_Set_Val_Rec_Type;
l_Assignment_tbl              MRP_Src_Assignment_PUB.Assignment_Tbl_Type;
l_Assignment_val_tbl          MRP_Src_Assignment_PUB.Assignment_Val_Tbl_Type;
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

    --  Value to ID conversion


    --  If p_return_values is TRUE then query read views

    IF FND_API.TO_BOOLEAN(p_return_values) THEN

        --  Get Assignment_Set

        MRP_Assignment_Set_Handlers.Query_Entity
        (   p_Assignment_Set_Id           => l_Assignment_Set_Id
        ,   x_Assignment_Set_rec          => l_Assignment_Set_rec
        ,   x_Assignment_Set_val_rec      => l_Assignment_Set_val_rec
        );

        --  Get Assignment ( parent = Assignment_Set )

        MRP_Assignment_Handlers.Query_Entities
        (   p_Assignment_Set_Id           => l_Assignment_Set_rec.Assignment_Set_Id
        ,   x_Assignment_tbl              => l_Assignment_tbl
        ,   x_Assignment_val_tbl          => l_Assignment_val_tbl
        );


        --  Load out parameters

        x_Assignment_Set_rec           := l_Assignment_Set_rec;
        x_Assignment_Set_val_rec       := l_Assignment_Set_val_rec;
        x_Assignment_tbl               := l_Assignment_tbl;
        x_Assignment_val_tbl           := l_Assignment_val_tbl;

    ELSE

        --  Call MRP_Assignment_PVT.Get_Assignment

        MRP_Assignment_PVT.Get_Assignment
        (   p_api_version_number          => 1.0
        ,   p_init_msg_list               => p_init_msg_list
        ,   x_return_status               => x_return_status
        ,   x_msg_count                   => x_msg_count
        ,   x_msg_data                    => x_msg_data
        ,   p_Assignment_Set_Id           => l_Assignment_Set_Id
        ,   x_Assignment_Set_rec          => l_Assignment_Set_rec
        ,   x_Assignment_tbl              => l_Assignment_tbl
        );

        --  Load Id OUT parameters.

        x_Assignment_Set_rec           := l_Assignment_Set_rec;
        x_Assignment_tbl               := l_Assignment_tbl;

    END IF;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN


        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Assignment'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Assignment;

--  Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_Assignment_Set_rec            IN  Assignment_Set_Rec_Type
,   p_Assignment_tbl                IN  Assignment_Tbl_Type
,   x_Assignment_Set_val_rec        OUT NOCOPY Assignment_Set_Val_Rec_Type
,   x_Assignment_val_tbl            OUT NOCOPY Assignment_Val_Tbl_Type
)
IS
BEGIN


    --  Convert Assignment_Set

    x_Assignment_Set_val_rec := MRP_Assignment_Set_Util.Get_Values(p_Assignment_Set_rec);

    --  Convert Assignment

    FOR I IN 1..p_Assignment_tbl.COUNT LOOP
        x_Assignment_val_tbl(I) :=
            MRP_Assignment_Util.Get_Values(p_Assignment_tbl(I));
    END LOOP;

EXCEPTION

    WHEN OTHERS THEN


        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Id_To_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Id_To_Value;

--  Procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_Assignment_Set_rec            IN  Assignment_Set_Rec_Type
,   p_Assignment_Set_val_rec        IN  Assignment_Set_Val_Rec_Type
,   p_Assignment_tbl                IN  Assignment_Tbl_Type
,   p_Assignment_val_tbl            IN  Assignment_Val_Tbl_Type
,   x_Assignment_Set_rec            OUT NOCOPY Assignment_Set_Rec_Type
,   x_Assignment_tbl                OUT NOCOPY Assignment_Tbl_Type
)
IS
l_Assignment_Set_rec          Assignment_Set_Rec_Type;
l_Assignment_rec              Assignment_Rec_Type;
l_index                       BINARY_INTEGER;
BEGIN


    --  Init x_return_status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Convert Assignment_Set

    l_Assignment_Set_rec := MRP_Assignment_Set_Util.Get_Ids
    (   p_Assignment_Set_rec          => p_Assignment_Set_rec
    ,   p_Assignment_Set_val_rec      => p_Assignment_Set_val_rec
    );

    x_Assignment_Set_rec           := l_Assignment_Set_rec;

    IF l_Assignment_Set_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    --  Convert Assignment

    x_Assignment_tbl := p_Assignment_tbl;

    l_index := p_Assignment_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        l_Assignment_rec := MRP_Assignment_Util.Get_Ids
        (   p_Assignment_rec              => p_Assignment_tbl(l_index)
        ,   p_Assignment_val_rec          => p_Assignment_val_tbl(l_index)
        );

        x_Assignment_tbl(l_index)      := l_Assignment_rec;

        IF l_Assignment_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_Assignment_val_tbl.NEXT(l_index);

    END LOOP;

EXCEPTION

    WHEN OTHERS THEN


        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Value_To_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Value_To_Id;

END MRP_Src_Assignment_PUB;

/
