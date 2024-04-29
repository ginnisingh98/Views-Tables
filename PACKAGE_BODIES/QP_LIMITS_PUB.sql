--------------------------------------------------------
--  DDL for Package Body QP_LIMITS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_LIMITS_PUB" AS
/* $Header: QPXPLMTB.pls 120.5 2006/10/25 06:55:19 nirmkuma ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Limits_PUB';

--  Forward declaration of Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_LIMITS_rec                    IN  Limits_Rec_Type
,   p_LIMIT_ATTRS_tbl               IN  Limit_Attrs_Tbl_Type
,   p_LIMIT_BALANCES_tbl            IN  Limit_Balances_Tbl_Type
,   x_LIMITS_val_rec                OUT NOCOPY /* file.sql.39 change */ Limits_Val_Rec_Type
,   x_LIMIT_ATTRS_val_tbl           OUT NOCOPY /* file.sql.39 change */ Limit_Attrs_Val_Tbl_Type
,   x_LIMIT_BALANCES_val_tbl        OUT NOCOPY /* file.sql.39 change */ Limit_Balances_Val_Tbl_Type
);

--  Forward declaration of procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMITS_rec                    IN  Limits_Rec_Type
,   p_LIMITS_val_rec                IN  Limits_Val_Rec_Type
,   p_LIMIT_ATTRS_tbl               IN  Limit_Attrs_Tbl_Type
,   p_LIMIT_ATTRS_val_tbl           IN  Limit_Attrs_Val_Tbl_Type
,   p_LIMIT_BALANCES_tbl            IN  Limit_Balances_Tbl_Type
,   p_LIMIT_BALANCES_val_tbl        IN  Limit_Balances_Val_Tbl_Type
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ Limits_Rec_Type
,   x_LIMIT_ATTRS_tbl               OUT NOCOPY /* file.sql.39 change */ Limit_Attrs_Tbl_Type
,   x_LIMIT_BALANCES_tbl            OUT NOCOPY /* file.sql.39 change */ Limit_Balances_Tbl_Type
);

--  Start of Comments
--  API name    Process_Limits
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

PROCEDURE Process_Limits
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMITS_rec                    IN  Limits_Rec_Type :=
                                        G_MISS_LIMITS_REC
,   p_LIMITS_val_rec                IN  Limits_Val_Rec_Type :=
                                        G_MISS_LIMITS_VAL_REC
,   p_LIMIT_ATTRS_tbl               IN  Limit_Attrs_Tbl_Type :=
                                        G_MISS_LIMIT_ATTRS_TBL
,   p_LIMIT_ATTRS_val_tbl           IN  Limit_Attrs_Val_Tbl_Type :=
                                        G_MISS_LIMIT_ATTRS_VAL_TBL
,   p_LIMIT_BALANCES_tbl            IN  Limit_Balances_Tbl_Type :=
                                        G_MISS_LIMIT_BALANCES_TBL
,   p_LIMIT_BALANCES_val_tbl        IN  Limit_Balances_Val_Tbl_Type :=
                                        G_MISS_LIMIT_BALANCES_VAL_TBL
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ Limits_Rec_Type
,   x_LIMITS_val_rec                OUT NOCOPY /* file.sql.39 change */ Limits_Val_Rec_Type
,   x_LIMIT_ATTRS_tbl               OUT NOCOPY /* file.sql.39 change */ Limit_Attrs_Tbl_Type
,   x_LIMIT_ATTRS_val_tbl           OUT NOCOPY /* file.sql.39 change */ Limit_Attrs_Val_Tbl_Type
,   x_LIMIT_BALANCES_tbl            OUT NOCOPY /* file.sql.39 change */ Limit_Balances_Tbl_Type
,   x_LIMIT_BALANCES_val_tbl        OUT NOCOPY /* file.sql.39 change */ Limit_Balances_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Limits';
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_LIMITS_rec                  Limits_Rec_Type;
l_p_LIMITS_rec                  Limits_Rec_Type;
l_LIMIT_ATTRS_tbl             Limit_Attrs_Tbl_Type;
l_p_LIMIT_ATTRS_tbl             Limit_Attrs_Tbl_Type;
l_LIMIT_BALANCES_tbl          Limit_Balances_Tbl_Type;
l_p_LIMIT_BALANCES_tbl          Limit_Balances_Tbl_Type;
l_qp_status                   VARCHAR2(1);
BEGIN

     SAVEPOINT QP_Process_Limits;
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

     -- BOI not available when QP not installed

    l_qp_status := QP_UTIL.GET_QP_STATUS;

    IF l_qp_status = 'N'
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('QP','QP_PRICING_NOT_INSTALLED');
        OE_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Perform Value to Id conversion

    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_LIMITS_rec                  => p_LIMITS_rec
    ,   p_LIMITS_val_rec              => p_LIMITS_val_rec
    ,   p_LIMIT_ATTRS_tbl             => p_LIMIT_ATTRS_tbl
    ,   p_LIMIT_ATTRS_val_tbl         => p_LIMIT_ATTRS_val_tbl
    ,   p_LIMIT_BALANCES_tbl          => p_LIMIT_BALANCES_tbl
    ,   p_LIMIT_BALANCES_val_tbl      => p_LIMIT_BALANCES_val_tbl
    ,   x_LIMITS_rec                  => l_LIMITS_rec
    ,   x_LIMIT_ATTRS_tbl             => l_LIMIT_ATTRS_tbl
    ,   x_LIMIT_BALANCES_tbl          => l_LIMIT_BALANCES_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call QP_Limits_PVT.Process_Limits
    -- rbagri - set the called_from_ui indicator to 'N', as  QP_Limits_PVT.Process_Limits is
    -- being called from public package

    l_control_rec.called_from_ui := 'N';
    l_p_LIMITS_rec := l_LIMITS_rec;
    l_p_LIMIT_ATTRS_tbl := l_LIMIT_ATTRS_tbl;
    l_p_LIMIT_BALANCES_tbl := l_LIMIT_BALANCES_tbl;
    QP_Limits_PVT.Process_Limits
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_commit                      => p_commit
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_LIMITS_rec                  => l_p_LIMITS_rec
    ,   p_LIMIT_ATTRS_tbl             => l_p_LIMIT_ATTRS_tbl
    ,   p_LIMIT_BALANCES_tbl          => l_p_LIMIT_BALANCES_tbl
    ,   x_LIMITS_rec                  => l_LIMITS_rec
    ,   x_LIMIT_ATTRS_tbl             => l_LIMIT_ATTRS_tbl
    ,   x_LIMIT_BALANCES_tbl          => l_LIMIT_BALANCES_tbl
    );

    --  Load Id OUT parameters.

    x_LIMITS_rec                   := l_LIMITS_rec;
    x_LIMIT_ATTRS_tbl              := l_LIMIT_ATTRS_tbl;
    x_LIMIT_BALANCES_tbl           := l_LIMIT_BALANCES_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_LIMITS_rec                  => l_LIMITS_rec
        ,   p_LIMIT_ATTRS_tbl             => l_LIMIT_ATTRS_tbl
        ,   p_LIMIT_BALANCES_tbl          => l_LIMIT_BALANCES_tbl
        ,   x_LIMITS_val_rec              => x_LIMITS_val_rec
        ,   x_LIMIT_ATTRS_val_tbl         => x_LIMIT_ATTRS_val_tbl
        ,   x_LIMIT_BALANCES_val_tbl      => x_LIMIT_BALANCES_val_tbl
        );

    END IF;
--Roll Back the transaction if the return status is not success and it is called from API, bug #5345652

        If x_return_status <> 'S' AND l_control_rec.called_from_ui='N' THEN
             --   Rollback;
     Rollback TO QP_Process_Limits;
        END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
--Roll Back the transaction if the return status is not success and it is called from API, bug #5345652
        If l_control_rec.called_from_ui='N' THEN
           Rollback TO QP_Process_Limits;
        END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
--Roll Back the transaction if the return status is not success and it is called from API, bug #5345652
        If l_control_rec.called_from_ui='N' THEN
           Rollback TO QP_Process_Limits;
        END IF;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Limits'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
--Roll Back the transaction if the return status is not success and it is called from API, bug #5345652
        If l_control_rec.called_from_ui='N' THEN
          Rollback TO QP_Process_Limits;
        END IF;

END Process_Limits;

--  Start of Comments
--  API name    Lock_Limits
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

PROCEDURE Lock_Limits
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMITS_rec                    IN  Limits_Rec_Type :=
                                        G_MISS_LIMITS_REC
,   p_LIMITS_val_rec                IN  Limits_Val_Rec_Type :=
                                        G_MISS_LIMITS_VAL_REC
,   p_LIMIT_ATTRS_tbl               IN  Limit_Attrs_Tbl_Type :=
                                        G_MISS_LIMIT_ATTRS_TBL
,   p_LIMIT_ATTRS_val_tbl           IN  Limit_Attrs_Val_Tbl_Type :=
                                        G_MISS_LIMIT_ATTRS_VAL_TBL
,   p_LIMIT_BALANCES_tbl            IN  Limit_Balances_Tbl_Type :=
                                        G_MISS_LIMIT_BALANCES_TBL
,   p_LIMIT_BALANCES_val_tbl        IN  Limit_Balances_Val_Tbl_Type :=
                                        G_MISS_LIMIT_BALANCES_VAL_TBL
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ Limits_Rec_Type
,   x_LIMITS_val_rec                OUT NOCOPY /* file.sql.39 change */ Limits_Val_Rec_Type
,   x_LIMIT_ATTRS_tbl               OUT NOCOPY /* file.sql.39 change */ Limit_Attrs_Tbl_Type
,   x_LIMIT_ATTRS_val_tbl           OUT NOCOPY /* file.sql.39 change */ Limit_Attrs_Val_Tbl_Type
,   x_LIMIT_BALANCES_tbl            OUT NOCOPY /* file.sql.39 change */ Limit_Balances_Tbl_Type
,   x_LIMIT_BALANCES_val_tbl        OUT NOCOPY /* file.sql.39 change */ Limit_Balances_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Limits';
l_return_status               VARCHAR2(1);
l_LIMITS_rec                  Limits_Rec_Type;
l_p_LIMITS_rec                  Limits_Rec_Type;
l_LIMIT_ATTRS_tbl             Limit_Attrs_Tbl_Type;
l_p_LIMIT_ATTRS_tbl             Limit_Attrs_Tbl_Type;
l_LIMIT_BALANCES_tbl          Limit_Balances_Tbl_Type;
l_p_LIMIT_BALANCES_tbl          Limit_Balances_Tbl_Type;
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
    ,   p_LIMITS_rec                  => p_LIMITS_rec
    ,   p_LIMITS_val_rec              => p_LIMITS_val_rec
    ,   p_LIMIT_ATTRS_tbl             => p_LIMIT_ATTRS_tbl
    ,   p_LIMIT_ATTRS_val_tbl         => p_LIMIT_ATTRS_val_tbl
    ,   p_LIMIT_BALANCES_tbl          => p_LIMIT_BALANCES_tbl
    ,   p_LIMIT_BALANCES_val_tbl      => p_LIMIT_BALANCES_val_tbl
    ,   x_LIMITS_rec                  => l_LIMITS_rec
    ,   x_LIMIT_ATTRS_tbl             => l_LIMIT_ATTRS_tbl
    ,   x_LIMIT_BALANCES_tbl          => l_LIMIT_BALANCES_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call QP_Limits_PVT.Lock_Limits
    l_p_LIMITS_rec := l_LIMITS_rec;
    l_p_LIMIT_ATTRS_tbl := l_LIMIT_ATTRS_tbl;
    l_p_LIMIT_BALANCES_tbl := l_LIMIT_BALANCES_tbl;
    QP_Limits_PVT.Lock_Limits
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_LIMITS_rec                  => l_p_LIMITS_rec
    ,   p_LIMIT_ATTRS_tbl             => l_p_LIMIT_ATTRS_tbl
    ,   p_LIMIT_BALANCES_tbl          => l_p_LIMIT_BALANCES_tbl
    ,   x_LIMITS_rec                  => l_LIMITS_rec
    ,   x_LIMIT_ATTRS_tbl             => l_LIMIT_ATTRS_tbl
    ,   x_LIMIT_BALANCES_tbl          => l_LIMIT_BALANCES_tbl
    );

    --  Load Id OUT parameters.

    x_LIMITS_rec                   := l_LIMITS_rec;
    x_LIMIT_ATTRS_tbl              := l_LIMIT_ATTRS_tbl;
    x_LIMIT_BALANCES_tbl           := l_LIMIT_BALANCES_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_LIMITS_rec                  => l_LIMITS_rec
        ,   p_LIMIT_ATTRS_tbl             => l_LIMIT_ATTRS_tbl
        ,   p_LIMIT_BALANCES_tbl          => l_LIMIT_BALANCES_tbl
        ,   x_LIMITS_val_rec              => x_LIMITS_val_rec
        ,   x_LIMIT_ATTRS_val_tbl         => x_LIMIT_ATTRS_val_tbl
        ,   x_LIMIT_BALANCES_val_tbl      => x_LIMIT_BALANCES_val_tbl
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
            ,   'Lock_Limits'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Lock_Limits;

--  Start of Comments
--  API name    Get_Limits
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

PROCEDURE Get_Limits
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_limit_id                      IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_limit                         IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ Limits_Rec_Type
,   x_LIMITS_val_rec                OUT NOCOPY /* file.sql.39 change */ Limits_Val_Rec_Type
,   x_LIMIT_ATTRS_tbl               OUT NOCOPY /* file.sql.39 change */ Limit_Attrs_Tbl_Type
,   x_LIMIT_ATTRS_val_tbl           OUT NOCOPY /* file.sql.39 change */ Limit_Attrs_Val_Tbl_Type
,   x_LIMIT_BALANCES_tbl            OUT NOCOPY /* file.sql.39 change */ Limit_Balances_Tbl_Type
,   x_LIMIT_BALANCES_val_tbl        OUT NOCOPY /* file.sql.39 change */ Limit_Balances_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Limits';
l_limit_id                    NUMBER := p_limit_id;
l_LIMITS_rec                  QP_Limits_PUB.Limits_Rec_Type;
l_LIMIT_ATTRS_tbl             QP_Limits_PUB.Limit_Attrs_Tbl_Type;
l_LIMIT_BALANCES_tbl          QP_Limits_PUB.Limit_Balances_Tbl_Type;
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

    IF  p_limit = FND_API.G_MISS_CHAR
    THEN

        l_limit_id := p_limit_id;

    ELSIF p_limit_id <> FND_API.G_MISS_NUM THEN

        l_limit_id := p_limit_id;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit');
            OE_MSG_PUB.Add;

        END IF;

    ELSE

        --  Convert Value to Id

        l_limit_id := QP_Value_To_Id.limit
        (   p_limit                       => p_limit
        );

        IF l_limit_id = FND_API.G_MISS_NUM THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

                FND_MESSAGE.SET_NAME('QP','Invalid Business Object Value');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','limit');
                OE_MSG_PUB.Add;

            END IF;
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;


    --  Call QP_Limits_PVT.Get_Limits

    QP_Limits_PVT.Get_Limits
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_limit_id                    => l_limit_id
    ,   x_LIMITS_rec                  => l_LIMITS_rec
    ,   x_LIMIT_ATTRS_tbl             => l_LIMIT_ATTRS_tbl
    ,   x_LIMIT_BALANCES_tbl          => l_LIMIT_BALANCES_tbl
    );

    --  Load Id OUT parameters.

    x_LIMITS_rec                   := l_LIMITS_rec;
    x_LIMIT_ATTRS_tbl              := l_LIMIT_ATTRS_tbl;
    x_LIMIT_BALANCES_tbl           := l_LIMIT_BALANCES_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.TO_BOOLEAN(p_return_values) THEN

        Id_To_Value
        (   p_LIMITS_rec                  => l_LIMITS_rec
        ,   p_LIMIT_ATTRS_tbl             => l_LIMIT_ATTRS_tbl
        ,   p_LIMIT_BALANCES_tbl          => l_LIMIT_BALANCES_tbl
        ,   x_LIMITS_val_rec              => x_LIMITS_val_rec
        ,   x_LIMIT_ATTRS_val_tbl         => x_LIMIT_ATTRS_val_tbl
        ,   x_LIMIT_BALANCES_val_tbl      => x_LIMIT_BALANCES_val_tbl
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
            ,   'Get_Limits'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Limits;

--  Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_LIMITS_rec                    IN  Limits_Rec_Type
,   p_LIMIT_ATTRS_tbl               IN  Limit_Attrs_Tbl_Type
,   p_LIMIT_BALANCES_tbl            IN  Limit_Balances_Tbl_Type
,   x_LIMITS_val_rec                OUT NOCOPY /* file.sql.39 change */ Limits_Val_Rec_Type
,   x_LIMIT_ATTRS_val_tbl           OUT NOCOPY /* file.sql.39 change */ Limit_Attrs_Val_Tbl_Type
,   x_LIMIT_BALANCES_val_tbl        OUT NOCOPY /* file.sql.39 change */ Limit_Balances_Val_Tbl_Type
)
IS
BEGIN

    --  Convert LIMITS

    x_LIMITS_val_rec := QP_Limits_Util.Get_Values(p_LIMITS_rec);

    --  Convert LIMIT_ATTRS

    FOR I IN 1..p_LIMIT_ATTRS_tbl.COUNT LOOP
        x_LIMIT_ATTRS_val_tbl(I) :=
            QP_Limit_Attrs_Util.Get_Values(p_LIMIT_ATTRS_tbl(I));
    END LOOP;

    --  Convert LIMIT_BALANCES

    FOR I IN 1..p_LIMIT_BALANCES_tbl.COUNT LOOP
        x_LIMIT_BALANCES_val_tbl(I) :=
            QP_Limit_Balances_Util.Get_Values(p_LIMIT_BALANCES_tbl(I));
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
,   p_LIMITS_rec                    IN  Limits_Rec_Type
,   p_LIMITS_val_rec                IN  Limits_Val_Rec_Type
,   p_LIMIT_ATTRS_tbl               IN  Limit_Attrs_Tbl_Type
,   p_LIMIT_ATTRS_val_tbl           IN  Limit_Attrs_Val_Tbl_Type
,   p_LIMIT_BALANCES_tbl            IN  Limit_Balances_Tbl_Type
,   p_LIMIT_BALANCES_val_tbl        IN  Limit_Balances_Val_Tbl_Type
,   x_LIMITS_rec                    OUT NOCOPY /* file.sql.39 change */ Limits_Rec_Type
,   x_LIMIT_ATTRS_tbl               OUT NOCOPY /* file.sql.39 change */ Limit_Attrs_Tbl_Type
,   x_LIMIT_BALANCES_tbl            OUT NOCOPY /* file.sql.39 change */ Limit_Balances_Tbl_Type
)
IS
l_LIMITS_rec                  Limits_Rec_Type;
l_LIMIT_ATTRS_rec             Limit_Attrs_Rec_Type;
l_LIMIT_BALANCES_rec          Limit_Balances_Rec_Type;
l_index                       BINARY_INTEGER;
BEGIN

    --  Init x_return_status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Convert LIMITS

    l_LIMITS_rec := QP_Limits_Util.Get_Ids
    (   p_LIMITS_rec                  => p_LIMITS_rec
    ,   p_LIMITS_val_rec              => p_LIMITS_val_rec
    );

    x_LIMITS_rec                   := l_LIMITS_rec;

    IF l_LIMITS_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    --  Convert LIMIT_ATTRS

    x_LIMIT_ATTRS_tbl := p_LIMIT_ATTRS_tbl;

    l_index := p_LIMIT_ATTRS_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        l_LIMIT_ATTRS_rec := QP_Limit_Attrs_Util.Get_Ids
        (   p_LIMIT_ATTRS_rec             => p_LIMIT_ATTRS_tbl(l_index)
        ,   p_LIMIT_ATTRS_val_rec         => p_LIMIT_ATTRS_val_tbl(l_index)
        );

        x_LIMIT_ATTRS_tbl(l_index)     := l_LIMIT_ATTRS_rec;

        IF l_LIMIT_ATTRS_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_LIMIT_ATTRS_val_tbl.NEXT(l_index);

    END LOOP;

    --  Convert LIMIT_BALANCES

    x_LIMIT_BALANCES_tbl := p_LIMIT_BALANCES_tbl;

    l_index := p_LIMIT_BALANCES_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        l_LIMIT_BALANCES_rec := QP_Limit_Balances_Util.Get_Ids
        (   p_LIMIT_BALANCES_rec          => p_LIMIT_BALANCES_tbl(l_index)
        ,   p_LIMIT_BALANCES_val_rec      => p_LIMIT_BALANCES_val_tbl(l_index)
        );

        x_LIMIT_BALANCES_tbl(l_index)  := l_LIMIT_BALANCES_rec;

        IF l_LIMIT_BALANCES_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_LIMIT_BALANCES_val_tbl.NEXT(l_index);

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

END QP_Limits_PUB;

/
