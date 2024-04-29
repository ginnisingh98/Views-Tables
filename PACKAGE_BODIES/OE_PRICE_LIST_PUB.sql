--------------------------------------------------------
--  DDL for Package Body OE_PRICE_LIST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PRICE_LIST_PUB" AS
/* $Header: OEXPPRLB.pls 115.2 99/10/14 22:17:10 porting ship  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Price_List_PUB';

--  Forward declaration of Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_PRICE_LIST_rec                IN  Price_List_Rec_Type
,   p_PRICE_LIST_LINE_tbl           IN  Price_List_Line_Tbl_Type
,   x_PRICE_LIST_val_rec            OUT Price_List_Val_Rec_Type
,   x_PRICE_LIST_LINE_val_tbl       OUT Price_List_Line_Val_Tbl_Type
);

--  Forward declaration of procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT VARCHAR2
,   p_PRICE_LIST_rec                IN  Price_List_Rec_Type
,   p_PRICE_LIST_val_rec            IN  Price_List_Val_Rec_Type
,   p_PRICE_LIST_LINE_tbl           IN  Price_List_Line_Tbl_Type
,   p_PRICE_LIST_LINE_val_tbl       IN  Price_List_Line_Val_Tbl_Type
,   x_PRICE_LIST_rec                OUT Price_List_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT Price_List_Line_Tbl_Type
);

--  Start of Comments
--  API name    Process_Price_List
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

PROCEDURE Process_Price_List
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_PRICE_LIST_rec                IN  Price_List_Rec_Type :=
                                        G_MISS_PRICE_LIST_REC
,   p_PRICE_LIST_val_rec            IN  Price_List_Val_Rec_Type :=
                                        G_MISS_PRICE_LIST_VAL_REC
,   p_PRICE_LIST_LINE_tbl           IN  Price_List_Line_Tbl_Type :=
                                        G_MISS_PRICE_LIST_LINE_TBL
,   p_PRICE_LIST_LINE_val_tbl       IN  Price_List_Line_Val_Tbl_Type :=
                                        G_MISS_PRICE_LIST_LINE_VAL_TBL
,   x_PRICE_LIST_rec                OUT Price_List_Rec_Type
,   x_PRICE_LIST_val_rec            OUT Price_List_Val_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT Price_List_Line_Tbl_Type
,   x_PRICE_LIST_LINE_val_tbl       OUT Price_List_Line_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Price_List';
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_PRICE_LIST_rec              Price_List_Rec_Type;
l_PRICE_LIST_LINE_tbl         Price_List_Line_Tbl_Type;
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
    ,   p_PRICE_LIST_rec              => p_PRICE_LIST_rec
    ,   p_PRICE_LIST_val_rec          => p_PRICE_LIST_val_rec
    ,   p_PRICE_LIST_LINE_tbl         => p_PRICE_LIST_LINE_tbl
    ,   p_PRICE_LIST_LINE_val_tbl     => p_PRICE_LIST_LINE_val_tbl
    ,   x_PRICE_LIST_rec              => l_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call qp_price_list_pvt.Process_Price_List

    qp_price_list_pvt.Process_Price_List
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_commit                      => p_commit
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PRICE_LIST_rec              => l_PRICE_LIST_rec
    ,   p_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
    ,   x_PRICE_LIST_rec              => l_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
    );

    --  Load Id OUT parameters.

    x_PRICE_LIST_rec               := l_PRICE_LIST_rec;
    x_PRICE_LIST_LINE_tbl          := l_PRICE_LIST_LINE_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_PRICE_LIST_rec              => l_PRICE_LIST_rec
        ,   p_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
        ,   x_PRICE_LIST_val_rec          => x_PRICE_LIST_val_rec
        ,   x_PRICE_LIST_LINE_val_tbl     => x_PRICE_LIST_LINE_val_tbl
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
            ,   'Process_Price_List'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Price_List;

--  Start of Comments
--  API name    Lock_Price_List
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

PROCEDURE Lock_Price_List
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_PRICE_LIST_rec                IN  Price_List_Rec_Type :=
                                        G_MISS_PRICE_LIST_REC
,   p_PRICE_LIST_val_rec            IN  Price_List_Val_Rec_Type :=
                                        G_MISS_PRICE_LIST_VAL_REC
,   p_PRICE_LIST_LINE_tbl           IN  Price_List_Line_Tbl_Type :=
                                        G_MISS_PRICE_LIST_LINE_TBL
,   p_PRICE_LIST_LINE_val_tbl       IN  Price_List_Line_Val_Tbl_Type :=
                                        G_MISS_PRICE_LIST_LINE_VAL_TBL
,   x_PRICE_LIST_rec                OUT Price_List_Rec_Type
,   x_PRICE_LIST_val_rec            OUT Price_List_Val_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT Price_List_Line_Tbl_Type
,   x_PRICE_LIST_LINE_val_tbl       OUT Price_List_Line_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Price_List';
l_return_status               VARCHAR2(1);
l_PRICE_LIST_rec              Price_List_Rec_Type;
l_PRICE_LIST_LINE_tbl         Price_List_Line_Tbl_Type;
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
    ,   p_PRICE_LIST_rec              => p_PRICE_LIST_rec
    ,   p_PRICE_LIST_val_rec          => p_PRICE_LIST_val_rec
    ,   p_PRICE_LIST_LINE_tbl         => p_PRICE_LIST_LINE_tbl
    ,   p_PRICE_LIST_LINE_val_tbl     => p_PRICE_LIST_LINE_val_tbl
    ,   x_PRICE_LIST_rec              => l_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call qp_price_list_pvt.Lock_Price_List

    qp_price_list_pvt.Lock_Price_List
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_PRICE_LIST_rec              => l_PRICE_LIST_rec
    ,   p_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
    ,   x_PRICE_LIST_rec              => l_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
    );

    --  Load Id OUT parameters.

    x_PRICE_LIST_rec               := l_PRICE_LIST_rec;
    x_PRICE_LIST_LINE_tbl          := l_PRICE_LIST_LINE_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_PRICE_LIST_rec              => l_PRICE_LIST_rec
        ,   p_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
        ,   x_PRICE_LIST_val_rec          => x_PRICE_LIST_val_rec
        ,   x_PRICE_LIST_LINE_val_tbl     => x_PRICE_LIST_LINE_val_tbl
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
            ,   'Lock_Price_List'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Lock_Price_List;

--  Start of Comments
--  API name    Get_Price_List
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

PROCEDURE Get_Price_List
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT VARCHAR2
,   x_msg_count                     OUT NUMBER
,   x_msg_data                      OUT VARCHAR2
,   p_name                          IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   p_price_list_id                 IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_price_list                    IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_PRICE_LIST_rec                OUT Price_List_Rec_Type
,   x_PRICE_LIST_val_rec            OUT Price_List_Val_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT Price_List_Line_Tbl_Type
,   x_PRICE_LIST_LINE_val_tbl       OUT Price_List_Line_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Price_List';
l_name                        VARCHAR2(240) := p_name;
l_price_list_id               NUMBER := p_price_list_id;
l_PRICE_LIST_rec              OE_Price_List_PUB.Price_List_Rec_Type;
l_PRICE_LIST_LINE_tbl         OE_Price_List_PUB.Price_List_Line_Tbl_Type;
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

    IF  p_price_list = FND_API.G_MISS_CHAR
    THEN

        l_price_list_id := p_price_list_id;

    ELSIF p_price_list_id <> FND_API.G_MISS_NUM THEN

        l_price_list_id := p_price_list_id;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('OE','FND_BOTH_VAL_AND_ID_EXIST');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list');
            OE_MSG_PUB.Add;

        END IF;

    ELSE

        --  Convert Value to Id

        l_price_list_id := OE_Value_To_Id.price_list
        (   p_price_list                  => p_price_list
        );

        IF l_price_list_id = FND_API.G_MISS_NUM THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

                FND_MESSAGE.SET_NAME('OE','Invalid Business Object Value');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_list');
                OE_MSG_PUB.Add;

            END IF;
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;


    --  Call qp_price_list_pvt.Get_Price_List

    qp_price_list_pvt.Get_Price_List
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_name                        => l_name
    ,   p_price_list_id               => l_price_list_id
    ,   x_PRICE_LIST_rec              => l_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
    );

    --  Load Id OUT parameters.

    x_PRICE_LIST_rec               := l_PRICE_LIST_rec;
    x_PRICE_LIST_LINE_tbl          := l_PRICE_LIST_LINE_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.TO_BOOLEAN(p_return_values) THEN

        Id_To_Value
        (   p_PRICE_LIST_rec              => l_PRICE_LIST_rec
        ,   p_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
        ,   x_PRICE_LIST_val_rec          => x_PRICE_LIST_val_rec
        ,   x_PRICE_LIST_LINE_val_tbl     => x_PRICE_LIST_LINE_val_tbl
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
            ,   'Get_Price_List'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Price_List;

--  Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_PRICE_LIST_rec                IN  Price_List_Rec_Type
,   p_PRICE_LIST_LINE_tbl           IN  Price_List_Line_Tbl_Type
,   x_PRICE_LIST_val_rec            OUT Price_List_Val_Rec_Type
,   x_PRICE_LIST_LINE_val_tbl       OUT Price_List_Line_Val_Tbl_Type
)
IS
BEGIN

    --  Convert PRICE_LIST

    x_PRICE_LIST_val_rec := OE_Price_List_Util.Get_Values(p_PRICE_LIST_rec);

    --  Convert PRICE_LIST_LINE

    FOR I IN 1..p_PRICE_LIST_LINE_tbl.COUNT LOOP
        x_PRICE_LIST_LINE_val_tbl(I) :=
            OE_Price_List_Line_Util.Get_Values(p_PRICE_LIST_LINE_tbl(I));
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
(   x_return_status                 OUT VARCHAR2
,   p_PRICE_LIST_rec                IN  Price_List_Rec_Type
,   p_PRICE_LIST_val_rec            IN  Price_List_Val_Rec_Type
,   p_PRICE_LIST_LINE_tbl           IN  Price_List_Line_Tbl_Type
,   p_PRICE_LIST_LINE_val_tbl       IN  Price_List_Line_Val_Tbl_Type
,   x_PRICE_LIST_rec                OUT Price_List_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT Price_List_Line_Tbl_Type
)
IS
l_PRICE_LIST_rec              Price_List_Rec_Type;
l_PRICE_LIST_LINE_rec         Price_List_Line_Rec_Type;
l_index                       BINARY_INTEGER;
BEGIN

    --  Init x_return_status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Convert PRICE_LIST

    l_PRICE_LIST_rec := OE_Price_List_Util.Get_Ids
    (   p_PRICE_LIST_rec              => p_PRICE_LIST_rec
    ,   p_PRICE_LIST_val_rec          => p_PRICE_LIST_val_rec
    );

    x_PRICE_LIST_rec               := l_PRICE_LIST_rec;

    IF l_PRICE_LIST_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    --  Convert PRICE_LIST_LINE

    x_PRICE_LIST_LINE_tbl := p_PRICE_LIST_LINE_tbl;

    l_index := p_PRICE_LIST_LINE_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        l_PRICE_LIST_LINE_rec := OE_Price_List_Line_Util.Get_Ids
        (   p_PRICE_LIST_LINE_rec         => p_PRICE_LIST_LINE_tbl(l_index)
        ,   p_PRICE_LIST_LINE_val_rec     => p_PRICE_LIST_LINE_val_tbl(l_index)
        );

        x_PRICE_LIST_LINE_tbl(l_index) := l_PRICE_LIST_LINE_rec;

        IF l_PRICE_LIST_LINE_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_PRICE_LIST_LINE_val_tbl.NEXT(l_index);

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

END OE_Price_List_PUB;

/
