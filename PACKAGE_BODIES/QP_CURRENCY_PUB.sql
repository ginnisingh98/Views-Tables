--------------------------------------------------------
--  DDL for Package Body QP_CURRENCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_CURRENCY_PUB" AS
/* $Header: QPXPCURB.pls 120.2 2005/07/07 04:06:38 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Currency_PUB';

--  Forward declaration of Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_CURR_LISTS_rec                IN  Curr_Lists_Rec_Type
,   p_CURR_DETAILS_tbl              IN  Curr_Details_Tbl_Type
,   x_CURR_LISTS_val_rec            OUT NOCOPY /* file.sql.39 change */ Curr_Lists_Val_Rec_Type
,   x_CURR_DETAILS_val_tbl          OUT NOCOPY /* file.sql.39 change */ Curr_Details_Val_Tbl_Type
);

--  Forward declaration of procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CURR_LISTS_rec                IN  Curr_Lists_Rec_Type
,   p_CURR_LISTS_val_rec            IN  Curr_Lists_Val_Rec_Type
,   p_CURR_DETAILS_tbl              IN  Curr_Details_Tbl_Type
,   p_CURR_DETAILS_val_tbl          IN  Curr_Details_Val_Tbl_Type
,   x_CURR_LISTS_rec                OUT NOCOPY /* file.sql.39 change */ Curr_Lists_Rec_Type
,   x_CURR_DETAILS_tbl              OUT NOCOPY /* file.sql.39 change */ Curr_Details_Tbl_Type
);

--  Start of Comments
--  API name    Process_Currency
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

PROCEDURE Process_Currency
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CURR_LISTS_rec                IN  Curr_Lists_Rec_Type :=
                                        G_MISS_CURR_LISTS_REC
,   p_CURR_LISTS_val_rec            IN  Curr_Lists_Val_Rec_Type :=
                                        G_MISS_CURR_LISTS_VAL_REC
,   p_CURR_DETAILS_tbl              IN  Curr_Details_Tbl_Type :=
                                        G_MISS_CURR_DETAILS_TBL
,   p_CURR_DETAILS_val_tbl          IN  Curr_Details_Val_Tbl_Type :=
                                        G_MISS_CURR_DETAILS_VAL_TBL
,   x_CURR_LISTS_rec                OUT NOCOPY /* file.sql.39 change */ Curr_Lists_Rec_Type
,   x_CURR_LISTS_val_rec            OUT NOCOPY /* file.sql.39 change */ Curr_Lists_Val_Rec_Type
,   x_CURR_DETAILS_tbl              OUT NOCOPY /* file.sql.39 change */ Curr_Details_Tbl_Type
,   x_CURR_DETAILS_val_tbl          OUT NOCOPY /* file.sql.39 change */ Curr_Details_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Currency';
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_CURR_LISTS_rec              Curr_Lists_Rec_Type;
l_p_CURR_LISTS_rec              Curr_Lists_Rec_Type;
l_CURR_DETAILS_tbl            Curr_Details_Tbl_Type;
l_p_CURR_DETAILS_tbl            Curr_Details_Tbl_Type;
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
    ,   p_CURR_LISTS_rec              => p_CURR_LISTS_rec
    ,   p_CURR_LISTS_val_rec          => p_CURR_LISTS_val_rec
    ,   p_CURR_DETAILS_tbl            => p_CURR_DETAILS_tbl
    ,   p_CURR_DETAILS_val_tbl        => p_CURR_DETAILS_val_tbl
    ,   x_CURR_LISTS_rec              => l_CURR_LISTS_rec
    ,   x_CURR_DETAILS_tbl            => l_CURR_DETAILS_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Added by Sunil Pandey
    -- Set control_rec flag to N to identify that the API is not called from UI
    l_control_rec.called_from_ui := 'N';

    --  Call QP_Currency_PVT.Process_Currency
    l_p_CURR_LISTS_rec := l_CURR_LISTS_rec;
    l_p_CURR_DETAILS_tbl := l_CURR_DETAILS_tbl;
    QP_Currency_PVT.Process_Currency
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_commit                      => p_commit
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_CURR_LISTS_rec              => l_p_CURR_LISTS_rec
    ,   p_CURR_DETAILS_tbl            => l_p_CURR_DETAILS_tbl
    ,   x_CURR_LISTS_rec              => l_CURR_LISTS_rec
    ,   x_CURR_DETAILS_tbl            => l_CURR_DETAILS_tbl
    );

    --  Load Id OUT parameters.

    x_CURR_LISTS_rec               := l_CURR_LISTS_rec;
    x_CURR_DETAILS_tbl             := l_CURR_DETAILS_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_CURR_LISTS_rec              => l_CURR_LISTS_rec
        ,   p_CURR_DETAILS_tbl            => l_CURR_DETAILS_tbl
        ,   x_CURR_LISTS_val_rec          => x_CURR_LISTS_val_rec
        ,   x_CURR_DETAILS_val_tbl        => x_CURR_DETAILS_val_tbl
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
            ,   'Process_Currency'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Currency;

--  Start of Comments
--  API name    Lock_Currency
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

PROCEDURE Lock_Currency
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_CURR_LISTS_rec                IN  Curr_Lists_Rec_Type :=
                                        G_MISS_CURR_LISTS_REC
,   p_CURR_LISTS_val_rec            IN  Curr_Lists_Val_Rec_Type :=
                                        G_MISS_CURR_LISTS_VAL_REC
,   p_CURR_DETAILS_tbl              IN  Curr_Details_Tbl_Type :=
                                        G_MISS_CURR_DETAILS_TBL
,   p_CURR_DETAILS_val_tbl          IN  Curr_Details_Val_Tbl_Type :=
                                        G_MISS_CURR_DETAILS_VAL_TBL
,   x_CURR_LISTS_rec                OUT NOCOPY /* file.sql.39 change */ Curr_Lists_Rec_Type
,   x_CURR_LISTS_val_rec            OUT NOCOPY /* file.sql.39 change */ Curr_Lists_Val_Rec_Type
,   x_CURR_DETAILS_tbl              OUT NOCOPY /* file.sql.39 change */ Curr_Details_Tbl_Type
,   x_CURR_DETAILS_val_tbl          OUT NOCOPY /* file.sql.39 change */ Curr_Details_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Currency';
l_return_status               VARCHAR2(1);
l_CURR_LISTS_rec              Curr_Lists_Rec_Type;
l_p_CURR_LISTS_rec              Curr_Lists_Rec_Type;
l_CURR_DETAILS_tbl            Curr_Details_Tbl_Type;
l_p_CURR_DETAILS_tbl            Curr_Details_Tbl_Type;
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
    ,   p_CURR_LISTS_rec              => p_CURR_LISTS_rec
    ,   p_CURR_LISTS_val_rec          => p_CURR_LISTS_val_rec
    ,   p_CURR_DETAILS_tbl            => p_CURR_DETAILS_tbl
    ,   p_CURR_DETAILS_val_tbl        => p_CURR_DETAILS_val_tbl
    ,   x_CURR_LISTS_rec              => l_CURR_LISTS_rec
    ,   x_CURR_DETAILS_tbl            => l_CURR_DETAILS_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call QP_Currency_PVT.Lock_Currency
    l_p_CURR_LISTS_rec := l_CURR_LISTS_rec;
    l_p_CURR_DETAILS_tbl := l_CURR_DETAILS_tbl;
    QP_Currency_PVT.Lock_Currency
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_CURR_LISTS_rec              => l_p_CURR_LISTS_rec
    ,   p_CURR_DETAILS_tbl            => l_p_CURR_DETAILS_tbl
    ,   x_CURR_LISTS_rec              => l_CURR_LISTS_rec
    ,   x_CURR_DETAILS_tbl            => l_CURR_DETAILS_tbl
    );

    --  Load Id OUT parameters.

    x_CURR_LISTS_rec               := l_CURR_LISTS_rec;
    x_CURR_DETAILS_tbl             := l_CURR_DETAILS_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_CURR_LISTS_rec              => l_CURR_LISTS_rec
        ,   p_CURR_DETAILS_tbl            => l_CURR_DETAILS_tbl
        ,   x_CURR_LISTS_val_rec          => x_CURR_LISTS_val_rec
        ,   x_CURR_DETAILS_val_tbl        => x_CURR_DETAILS_val_tbl
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
            ,   'Lock_Currency'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Lock_Currency;

--  Start of Comments
--  API name    Get_Currency
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

PROCEDURE Get_Currency
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_currency_header_id            IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_currency_header               IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_CURR_LISTS_rec                OUT NOCOPY /* file.sql.39 change */ Curr_Lists_Rec_Type
,   x_CURR_LISTS_val_rec            OUT NOCOPY /* file.sql.39 change */ Curr_Lists_Val_Rec_Type
,   x_CURR_DETAILS_tbl              OUT NOCOPY /* file.sql.39 change */ Curr_Details_Tbl_Type
,   x_CURR_DETAILS_val_tbl          OUT NOCOPY /* file.sql.39 change */ Curr_Details_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Currency';
l_currency_header_id          NUMBER := p_currency_header_id;
l_CURR_LISTS_rec              QP_Currency_PUB.Curr_Lists_Rec_Type;
l_CURR_DETAILS_tbl            QP_Currency_PUB.Curr_Details_Tbl_Type;
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

    IF  p_currency_header = FND_API.G_MISS_CHAR
    THEN

        l_currency_header_id := p_currency_header_id;

    ELSIF p_currency_header_id <> FND_API.G_MISS_NUM THEN

        l_currency_header_id := p_currency_header_id;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency_header');
            OE_MSG_PUB.Add;

        END IF;

    ELSE

        --  Convert Value to Id

        l_currency_header_id := QP_Value_To_Id.currency_header
        (   p_currency_header             => p_currency_header
        );

        IF l_currency_header_id = FND_API.G_MISS_NUM THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

                FND_MESSAGE.SET_NAME('QP','Invalid Business Object Value');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency_header');
                OE_MSG_PUB.Add;

            END IF;
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;


    --  Call QP_Currency_PVT.Get_Currency

    QP_Currency_PVT.Get_Currency
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_currency_header_id          => l_currency_header_id
    ,   x_CURR_LISTS_rec              => l_CURR_LISTS_rec
    ,   x_CURR_DETAILS_tbl            => l_CURR_DETAILS_tbl
    );

    --  Load Id OUT parameters.

    x_CURR_LISTS_rec               := l_CURR_LISTS_rec;
    x_CURR_DETAILS_tbl             := l_CURR_DETAILS_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.TO_BOOLEAN(p_return_values) THEN

        Id_To_Value
        (   p_CURR_LISTS_rec              => l_CURR_LISTS_rec
        ,   p_CURR_DETAILS_tbl            => l_CURR_DETAILS_tbl
        ,   x_CURR_LISTS_val_rec          => x_CURR_LISTS_val_rec
        ,   x_CURR_DETAILS_val_tbl        => x_CURR_DETAILS_val_tbl
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
            ,   'Get_Currency'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Currency;

--  Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_CURR_LISTS_rec                IN  Curr_Lists_Rec_Type
,   p_CURR_DETAILS_tbl              IN  Curr_Details_Tbl_Type
,   x_CURR_LISTS_val_rec            OUT NOCOPY /* file.sql.39 change */ Curr_Lists_Val_Rec_Type
,   x_CURR_DETAILS_val_tbl          OUT NOCOPY /* file.sql.39 change */ Curr_Details_Val_Tbl_Type
)
IS
BEGIN

    --  Convert CURR_LISTS

    x_CURR_LISTS_val_rec := QP_Curr_Lists_Util.Get_Values(p_CURR_LISTS_rec);

    --  Convert CURR_DETAILS

    FOR I IN 1..p_CURR_DETAILS_tbl.COUNT LOOP
        x_CURR_DETAILS_val_tbl(I) :=
            QP_Curr_Details_Util.Get_Values(p_CURR_DETAILS_tbl(I));
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
,   p_CURR_LISTS_rec                IN  Curr_Lists_Rec_Type
,   p_CURR_LISTS_val_rec            IN  Curr_Lists_Val_Rec_Type
,   p_CURR_DETAILS_tbl              IN  Curr_Details_Tbl_Type
,   p_CURR_DETAILS_val_tbl          IN  Curr_Details_Val_Tbl_Type
,   x_CURR_LISTS_rec                OUT NOCOPY /* file.sql.39 change */ Curr_Lists_Rec_Type
,   x_CURR_DETAILS_tbl              OUT NOCOPY /* file.sql.39 change */ Curr_Details_Tbl_Type
)
IS
l_CURR_LISTS_rec              Curr_Lists_Rec_Type;
l_CURR_DETAILS_rec            Curr_Details_Rec_Type;
l_index                       BINARY_INTEGER;
BEGIN

    --  Init x_return_status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Convert CURR_LISTS

    l_CURR_LISTS_rec := QP_Curr_Lists_Util.Get_Ids
    (   p_CURR_LISTS_rec              => p_CURR_LISTS_rec
    ,   p_CURR_LISTS_val_rec          => p_CURR_LISTS_val_rec
    );

    x_CURR_LISTS_rec               := l_CURR_LISTS_rec;

    IF l_CURR_LISTS_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    --  Convert CURR_DETAILS

    x_CURR_DETAILS_tbl := p_CURR_DETAILS_tbl;

    l_index := p_CURR_DETAILS_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        l_CURR_DETAILS_rec := QP_Curr_Details_Util.Get_Ids
        (   p_CURR_DETAILS_rec            => p_CURR_DETAILS_tbl(l_index)
        ,   p_CURR_DETAILS_val_rec        => p_CURR_DETAILS_val_tbl(l_index)
        );

        x_CURR_DETAILS_tbl(l_index)    := l_CURR_DETAILS_rec;

        IF l_CURR_DETAILS_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_CURR_DETAILS_val_tbl.NEXT(l_index);

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

END QP_Currency_PUB;

/
