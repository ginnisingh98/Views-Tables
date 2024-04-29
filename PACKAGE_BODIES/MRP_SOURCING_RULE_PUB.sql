--------------------------------------------------------
--  DDL for Package Body MRP_SOURCING_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_SOURCING_RULE_PUB" AS
/* $Header: MRPPSRLB.pls 120.1 2005/06/16 12:39:47 ichoudhu noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'MRP_Sourcing_Rule_PUB';

--  Forward declaration of Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_Sourcing_Rule_rec             IN  Sourcing_Rule_Rec_Type
,   p_Receiving_Org_tbl             IN  Receiving_Org_Tbl_Type
,   p_Shipping_Org_tbl              IN  Shipping_Org_Tbl_Type
,   x_Sourcing_Rule_val_rec         OUT NOCOPY Sourcing_Rule_Val_Rec_Type
,   x_Receiving_Org_val_tbl         OUT NOCOPY Receiving_Org_Val_Tbl_Type
,   x_Shipping_Org_val_tbl          OUT NOCOPY Shipping_Org_Val_Tbl_Type
);

--  Forward declaration of procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_Sourcing_Rule_rec             IN  Sourcing_Rule_Rec_Type
,   p_Sourcing_Rule_val_rec         IN  Sourcing_Rule_Val_Rec_Type
,   p_Receiving_Org_tbl             IN  Receiving_Org_Tbl_Type
,   p_Receiving_Org_val_tbl         IN  Receiving_Org_Val_Tbl_Type
,   p_Shipping_Org_tbl              IN  Shipping_Org_Tbl_Type
,   p_Shipping_Org_val_tbl          IN  Shipping_Org_Val_Tbl_Type
,   x_Sourcing_Rule_rec             OUT NOCOPY Sourcing_Rule_Rec_Type
,   x_Receiving_Org_tbl             OUT NOCOPY Receiving_Org_Tbl_Type
,   x_Shipping_Org_tbl              OUT NOCOPY Shipping_Org_Tbl_Type
);

--  Start of Comments
--  API name    Process_Sourcing_Rule
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

PROCEDURE Process_Sourcing_Rule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_Sourcing_Rule_rec             IN  Sourcing_Rule_Rec_Type :=
                                        G_MISS_SOURCING_RULE_REC
,   p_Sourcing_Rule_val_rec         IN  Sourcing_Rule_Val_Rec_Type :=
                                        G_MISS_SOURCING_RULE_VAL_REC
,   p_Receiving_Org_tbl             IN  Receiving_Org_Tbl_Type :=
                                        G_MISS_RECEIVING_ORG_TBL
,   p_Receiving_Org_val_tbl         IN  Receiving_Org_Val_Tbl_Type :=
                                        G_MISS_RECEIVING_ORG_VAL_TBL
,   p_Shipping_Org_tbl              IN  Shipping_Org_Tbl_Type :=
                                        G_MISS_SHIPPING_ORG_TBL
,   p_Shipping_Org_val_tbl          IN  Shipping_Org_Val_Tbl_Type :=
                                        G_MISS_SHIPPING_ORG_VAL_TBL
,   x_Sourcing_Rule_rec             OUT NOCOPY Sourcing_Rule_Rec_Type
,   x_Sourcing_Rule_val_rec         OUT NOCOPY Sourcing_Rule_Val_Rec_Type
,   x_Receiving_Org_tbl             OUT NOCOPY Receiving_Org_Tbl_Type
,   x_Receiving_Org_val_tbl         OUT NOCOPY Receiving_Org_Val_Tbl_Type
,   x_Shipping_Org_tbl              OUT NOCOPY Shipping_Org_Tbl_Type
,   x_Shipping_Org_val_tbl          OUT NOCOPY Shipping_Org_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Sourcing_Rule';
l_control_rec                 MRP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_Sourcing_Rule_rec           Sourcing_Rule_Rec_Type;
l_Receiving_Org_tbl           Receiving_Org_Tbl_Type;
l_Shipping_Org_tbl            Shipping_Org_Tbl_Type;

-- New variables defined for NOCOPY hint.

l_Sourcing_Rule_rec_out           Sourcing_Rule_Rec_Type;
l_Receiving_Org_tbl_out           Receiving_Org_Tbl_Type;
l_Shipping_Org_tbl_out            Shipping_Org_Tbl_Type;

BEGIN
    -- bug 3138889
    -- Set savepoint
     SAVEPOINT S_Process_Sourcing_Rule ;
    --
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
    ,   p_Sourcing_Rule_rec           => p_Sourcing_Rule_rec
    ,   p_Sourcing_Rule_val_rec       => p_Sourcing_Rule_val_rec
    ,   p_Receiving_Org_tbl           => p_Receiving_Org_tbl
    ,   p_Receiving_Org_val_tbl       => p_Receiving_Org_val_tbl
    ,   p_Shipping_Org_tbl            => p_Shipping_Org_tbl
    ,   p_Shipping_Org_val_tbl        => p_Shipping_Org_val_tbl
    ,   x_Sourcing_Rule_rec           => l_Sourcing_Rule_rec
    ,   x_Receiving_Org_tbl           => l_Receiving_Org_tbl
    ,   x_Shipping_Org_tbl            => l_Shipping_Org_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --  Call MRP_Sourcing_Rule_PVT.Process_Sourcing_Rule

    MRP_Sourcing_Rule_PVT.Process_Sourcing_Rule
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_commit                      => p_commit
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_Sourcing_Rule_rec           => l_Sourcing_Rule_rec
    ,   p_Receiving_Org_tbl           => l_Receiving_Org_tbl
    ,   p_Shipping_Org_tbl            => l_Shipping_Org_tbl
    ,   x_Sourcing_Rule_rec           => l_Sourcing_Rule_rec_out
    ,   x_Receiving_Org_tbl           => l_Receiving_Org_tbl_out
    ,   x_Shipping_Org_tbl            => l_Shipping_Org_tbl_out
    );

    l_Sourcing_Rule_rec            := l_Sourcing_Rule_rec_out;
    l_Receiving_Org_tbl            := l_Receiving_Org_tbl_out;
    l_Shipping_Org_tbl             := l_Shipping_Org_tbl_out;


    --  Load Id OUT parameters.

    x_Sourcing_Rule_rec            := l_Sourcing_Rule_rec;
    x_Receiving_Org_tbl            := l_Receiving_Org_tbl;
    x_Shipping_Org_tbl             := l_Shipping_Org_tbl;


    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_Sourcing_Rule_rec           => l_Sourcing_Rule_rec
        ,   p_Receiving_Org_tbl           => l_Receiving_Org_tbl
        ,   p_Shipping_Org_tbl            => l_Shipping_Org_tbl
        ,   x_Sourcing_Rule_val_rec       => x_Sourcing_Rule_val_rec
        ,   x_Receiving_Org_val_tbl       => x_Receiving_Org_val_tbl
        ,   x_Shipping_Org_val_tbl        => x_Shipping_Org_val_tbl
        );

    END IF;
    -- bug 3138889
    IF p_commit = FND_API.G_TRUE THEN
     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
          COMMIT;
     ELSE
          ROLLBACK TO S_Process_Sourcing_Rule ;
     END IF;
    ELSE
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          ROLLBACK TO S_Process_Sourcing_Rule ;
     END IF;
    END IF;

/** Bug 2263575 **/
/*    IF p_commit = FND_API.G_FALSE THEN
          ROLLBACK;
    ELSIF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
          COMMIT;
    ELSE
          ROLLBACK;
    END IF;
*/


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
            ,   'Process_Sourcing_Rule'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Sourcing_Rule;

--  Start of Comments
--  API name    Lock_Sourcing_Rule
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

PROCEDURE Lock_Sourcing_Rule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_Sourcing_Rule_rec             IN  Sourcing_Rule_Rec_Type :=
                                        G_MISS_SOURCING_RULE_REC
,   p_Sourcing_Rule_val_rec         IN  Sourcing_Rule_Val_Rec_Type :=
                                        G_MISS_SOURCING_RULE_VAL_REC
,   p_Receiving_Org_tbl             IN  Receiving_Org_Tbl_Type :=
                                        G_MISS_RECEIVING_ORG_TBL
,   p_Receiving_Org_val_tbl         IN  Receiving_Org_Val_Tbl_Type :=
                                        G_MISS_RECEIVING_ORG_VAL_TBL
,   p_Shipping_Org_tbl              IN  Shipping_Org_Tbl_Type :=
                                        G_MISS_SHIPPING_ORG_TBL
,   p_Shipping_Org_val_tbl          IN  Shipping_Org_Val_Tbl_Type :=
                                        G_MISS_SHIPPING_ORG_VAL_TBL
,   x_Sourcing_Rule_rec             OUT NOCOPY Sourcing_Rule_Rec_Type
,   x_Sourcing_Rule_val_rec         OUT NOCOPY Sourcing_Rule_Val_Rec_Type
,   x_Receiving_Org_tbl             OUT NOCOPY Receiving_Org_Tbl_Type
,   x_Receiving_Org_val_tbl         OUT NOCOPY Receiving_Org_Val_Tbl_Type
,   x_Shipping_Org_tbl              OUT NOCOPY Shipping_Org_Tbl_Type
,   x_Shipping_Org_val_tbl          OUT NOCOPY Shipping_Org_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Sourcing_Rule';
l_return_status               VARCHAR2(1);
l_Sourcing_Rule_rec           Sourcing_Rule_Rec_Type;
l_Receiving_Org_tbl           Receiving_Org_Tbl_Type;
l_Shipping_Org_tbl            Shipping_Org_Tbl_Type;

l_Sourcing_Rule_rec_out           Sourcing_Rule_Rec_Type;
l_Receiving_Org_tbl_out           Receiving_Org_Tbl_Type;
l_Shipping_Org_tbl_out            Shipping_Org_Tbl_Type;

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
    ,   p_Sourcing_Rule_rec           => p_Sourcing_Rule_rec
    ,   p_Sourcing_Rule_val_rec       => p_Sourcing_Rule_val_rec
    ,   p_Receiving_Org_tbl           => p_Receiving_Org_tbl
    ,   p_Receiving_Org_val_tbl       => p_Receiving_Org_val_tbl
    ,   p_Shipping_Org_tbl            => p_Shipping_Org_tbl
    ,   p_Shipping_Org_val_tbl        => p_Shipping_Org_val_tbl
    ,   x_Sourcing_Rule_rec           => l_Sourcing_Rule_rec
    ,   x_Receiving_Org_tbl           => l_Receiving_Org_tbl
    ,   x_Shipping_Org_tbl            => l_Shipping_Org_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call MRP_Sourcing_Rule_PVT.Lock_Sourcing_Rule

    MRP_Sourcing_Rule_PVT.Lock_Sourcing_Rule
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_Sourcing_Rule_rec           => l_Sourcing_Rule_rec
    ,   p_Receiving_Org_tbl           => l_Receiving_Org_tbl
    ,   p_Shipping_Org_tbl            => l_Shipping_Org_tbl
    ,   x_Sourcing_Rule_rec           => l_Sourcing_Rule_rec_out
    ,   x_Receiving_Org_tbl           => l_Receiving_Org_tbl_out
    ,   x_Shipping_Org_tbl            => l_Shipping_Org_tbl_out
    );

    l_Sourcing_Rule_rec            := l_Sourcing_Rule_rec_out;
    l_Receiving_Org_tbl            := l_Receiving_Org_tbl_out;
    l_Shipping_Org_tbl             := l_Shipping_Org_tbl_out;


    --  Load Id OUT parameters.

    x_Sourcing_Rule_rec            := l_Sourcing_Rule_rec;
    x_Receiving_Org_tbl            := l_Receiving_Org_tbl;
    x_Shipping_Org_tbl             := l_Shipping_Org_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_Sourcing_Rule_rec           => l_Sourcing_Rule_rec
        ,   p_Receiving_Org_tbl           => l_Receiving_Org_tbl
        ,   p_Shipping_Org_tbl            => l_Shipping_Org_tbl
        ,   x_Sourcing_Rule_val_rec       => x_Sourcing_Rule_val_rec
        ,   x_Receiving_Org_val_tbl       => x_Receiving_Org_val_tbl
        ,   x_Shipping_Org_val_tbl        => x_Shipping_Org_val_tbl
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
            ,   'Lock_Sourcing_Rule'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Lock_Sourcing_Rule;

--  Start of Comments
--  API name    Get_Sourcing_Rule
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

PROCEDURE Get_Sourcing_Rule
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_Sourcing_Rule_Id              IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   x_Sourcing_Rule_rec             OUT NOCOPY Sourcing_Rule_Rec_Type
,   x_Sourcing_Rule_val_rec         OUT NOCOPY Sourcing_Rule_Val_Rec_Type
,   x_Receiving_Org_tbl             OUT NOCOPY Receiving_Org_Tbl_Type
,   x_Receiving_Org_val_tbl         OUT NOCOPY Receiving_Org_Val_Tbl_Type
,   x_Shipping_Org_tbl              OUT NOCOPY Shipping_Org_Tbl_Type
,   x_Shipping_Org_val_tbl          OUT NOCOPY Shipping_Org_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Sourcing_Rule';
l_Sourcing_Rule_Id            NUMBER := p_Sourcing_Rule_Id;
l_Sourcing_Rule_rec           MRP_Sourcing_Rule_PUB.Sourcing_Rule_Rec_Type;
l_Sourcing_Rule_val_rec       MRP_Sourcing_Rule_PUB.Sourcing_Rule_Val_Rec_Type;
l_Receiving_Org_tbl           MRP_Sourcing_Rule_PUB.Receiving_Org_Tbl_Type;
l_Receiving_Org_val_tbl       MRP_Sourcing_Rule_PUB.Receiving_Org_Val_Tbl_Type;
l_Shipping_Org_tbl            MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type;
l_Shipping_Org_val_tbl        MRP_Sourcing_Rule_PUB.Shipping_Org_Val_Tbl_Type;
l_x_Shipping_Org_tbl          MRP_Sourcing_Rule_PUB.Shipping_Org_Tbl_Type;
l_x_Shipping_Org_val_tbl      MRP_Sourcing_Rule_PUB.Shipping_Org_Val_Tbl_Type;
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

        --  Get Sourcing_Rule

        MRP_Sourcing_Rule_Handlers.Query_Entity
        (   p_Sourcing_Rule_Id            => l_Sourcing_Rule_Id
        ,   x_Sourcing_Rule_rec           => l_Sourcing_Rule_rec
        ,   x_Sourcing_Rule_val_rec       => l_Sourcing_Rule_val_rec
        );

        --  Get Receiving_Org ( parent = Sourcing_Rule )

        MRP_Receiving_Org_Handlers.Query_Entities
        (   p_Sourcing_Rule_Id            => l_Sourcing_Rule_rec.Sourcing_Rule_Id
        ,   x_Receiving_Org_tbl           => l_Receiving_Org_tbl
        ,   x_Receiving_Org_val_tbl       => l_Receiving_Org_val_tbl
        );


        --  Loop over Receiving_Org's children

        FOR I2 IN 1..l_Receiving_Org_tbl.COUNT LOOP

            --  Get Shipping_Org ( parent = Receiving_Org )

            MRP_Shipping_Org_Handlers.Query_Entities
            (   p_Sr_Receipt_Id               => l_Receiving_Org_tbl(I2).Sr_Receipt_Id
            ,   x_Shipping_Org_tbl            => l_Shipping_Org_tbl
            ,   x_Shipping_Org_val_tbl        => l_Shipping_Org_val_tbl
            );

            FOR I3 IN 1..l_Shipping_Org_tbl.COUNT LOOP
                l_Shipping_Org_tbl(I3).Receiving_Org_Index := I2;
                l_x_Shipping_Org_tbl
                (l_x_Shipping_Org_tbl.COUNT + 1) := l_Shipping_Org_tbl(I3);

                l_x_Shipping_Org_val_tbl
                (l_x_Shipping_Org_val_tbl.COUNT + 1) := l_Shipping_Org_val_tbl(I3);
            END LOOP;

        END LOOP;

        --  Load out parameters

        x_Sourcing_Rule_rec            := l_Sourcing_Rule_rec;
        x_Sourcing_Rule_val_rec        := l_Sourcing_Rule_val_rec;
        x_Receiving_Org_tbl            := l_Receiving_Org_tbl;
        x_Receiving_Org_val_tbl        := l_Receiving_Org_val_tbl;
        x_Shipping_Org_tbl             := l_x_Shipping_Org_tbl;
        x_Shipping_Org_val_tbl         := l_x_Shipping_Org_val_tbl;

    ELSE

        --  Call MRP_Sourcing_Rule_PVT.Get_Sourcing_Rule

        MRP_Sourcing_Rule_PVT.Get_Sourcing_Rule
        (   p_api_version_number          => 1.0
        ,   p_init_msg_list               => p_init_msg_list
        ,   x_return_status               => x_return_status
        ,   x_msg_count                   => x_msg_count
        ,   x_msg_data                    => x_msg_data
        ,   p_Sourcing_Rule_Id            => l_Sourcing_Rule_Id
        ,   x_Sourcing_Rule_rec           => l_Sourcing_Rule_rec
        ,   x_Receiving_Org_tbl           => l_Receiving_Org_tbl
        ,   x_Shipping_Org_tbl            => l_Shipping_Org_tbl
        );

        --  Load Id OUT parameters.

        x_Sourcing_Rule_rec            := l_Sourcing_Rule_rec;
        x_Receiving_Org_tbl            := l_Receiving_Org_tbl;
        x_Shipping_Org_tbl             := l_Shipping_Org_tbl;

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
            ,   'Get_Sourcing_Rule'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Sourcing_Rule;

--  Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_Sourcing_Rule_rec             IN  Sourcing_Rule_Rec_Type
,   p_Receiving_Org_tbl             IN  Receiving_Org_Tbl_Type
,   p_Shipping_Org_tbl              IN  Shipping_Org_Tbl_Type
,   x_Sourcing_Rule_val_rec         OUT NOCOPY Sourcing_Rule_Val_Rec_Type
,   x_Receiving_Org_val_tbl         OUT NOCOPY Receiving_Org_Val_Tbl_Type
,   x_Shipping_Org_val_tbl          OUT NOCOPY Shipping_Org_Val_Tbl_Type
)
IS
BEGIN

    --  Convert Sourcing_Rule

    x_Sourcing_Rule_val_rec := MRP_Sourcing_Rule_Util.Get_Values(p_Sourcing_Rule_rec);

    --  Convert Receiving_Org

    FOR I IN 1..p_Receiving_Org_tbl.COUNT LOOP
        x_Receiving_Org_val_tbl(I) :=
            MRP_Receiving_Org_Util.Get_Values(p_Receiving_Org_tbl(I));
    END LOOP;

    --  Convert Shipping_Org

    FOR I IN 1..p_Shipping_Org_tbl.COUNT LOOP
        x_Shipping_Org_val_tbl(I) :=
            MRP_Shipping_Org_Util.Get_Values(p_Shipping_Org_tbl(I));
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
,   p_Sourcing_Rule_rec             IN  Sourcing_Rule_Rec_Type
,   p_Sourcing_Rule_val_rec         IN  Sourcing_Rule_Val_Rec_Type
,   p_Receiving_Org_tbl             IN  Receiving_Org_Tbl_Type
,   p_Receiving_Org_val_tbl         IN  Receiving_Org_Val_Tbl_Type
,   p_Shipping_Org_tbl              IN  Shipping_Org_Tbl_Type
,   p_Shipping_Org_val_tbl          IN  Shipping_Org_Val_Tbl_Type
,   x_Sourcing_Rule_rec             OUT NOCOPY Sourcing_Rule_Rec_Type
,   x_Receiving_Org_tbl             OUT NOCOPY Receiving_Org_Tbl_Type
,   x_Shipping_Org_tbl              OUT NOCOPY Shipping_Org_Tbl_Type
)
IS
l_Sourcing_Rule_rec           Sourcing_Rule_Rec_Type;
l_Receiving_Org_rec           Receiving_Org_Rec_Type;
l_Shipping_Org_rec            Shipping_Org_Rec_Type;
l_index                       BINARY_INTEGER;
BEGIN

    --  Init x_return_status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Convert Sourcing_Rule

    l_Sourcing_Rule_rec := MRP_Sourcing_Rule_Util.Get_Ids
    (   p_Sourcing_Rule_rec           => p_Sourcing_Rule_rec
    ,   p_Sourcing_Rule_val_rec       => p_Sourcing_Rule_val_rec
    );

    x_Sourcing_Rule_rec            := l_Sourcing_Rule_rec;

    IF l_Sourcing_Rule_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    --  Convert Receiving_Org

    x_Receiving_Org_tbl := p_Receiving_Org_tbl;

    l_index := p_Receiving_Org_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        l_Receiving_Org_rec := MRP_Receiving_Org_Util.Get_Ids
        (   p_Receiving_Org_rec           => p_Receiving_Org_tbl(l_index)
        ,   p_Receiving_Org_val_rec       => p_Receiving_Org_val_tbl(l_index)
        );

        x_Receiving_Org_tbl(l_index)   := l_Receiving_Org_rec;

        IF l_Receiving_Org_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_Receiving_Org_val_tbl.NEXT(l_index);

    END LOOP;

    --  Convert Shipping_Org

    x_Shipping_Org_tbl := p_Shipping_Org_tbl;

    l_index := p_Shipping_Org_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        l_Shipping_Org_rec := MRP_Shipping_Org_Util.Get_Ids
        (   p_Shipping_Org_rec            => p_Shipping_Org_tbl(l_index)
        ,   p_Shipping_Org_val_rec        => p_Shipping_Org_val_tbl(l_index)
        );

        x_Shipping_Org_tbl(l_index)    := l_Shipping_Org_rec;

        IF l_Shipping_Org_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_Shipping_Org_val_tbl.NEXT(l_index);

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

END MRP_Sourcing_Rule_PUB;

/
