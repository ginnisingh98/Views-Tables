--------------------------------------------------------
--  DDL for Package Body QP_PRICE_LIST_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PRICE_LIST_GRP" AS
/* $Header: QPXGPRLB.pls 120.2 2005/07/07 23:18:24 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Price_List_GRP';

--  Forward declaration of Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type
,   p_PRICE_LIST_LINE_tbl           IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   p_QUALIFIERS_tbl                IN  Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   p_PRICING_ATTR_tbl              IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   x_PRICE_LIST_val_rec            OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Val_Rec_Type
,   x_PRICE_LIST_LINE_val_tbl       OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type
,   x_PRICING_ATTR_val_tbl          OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type
);

--  Forward declaration of procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type
,   p_PRICE_LIST_val_rec            IN  QP_Price_List_PUB.Price_List_Val_Rec_Type
,   p_PRICE_LIST_LINE_tbl           IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   p_PRICE_LIST_LINE_val_tbl       IN  QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type
,   p_QUALIFIERS_tbl                IN  Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   p_QUALIFIERS_val_tbl            IN  Qp_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type
,   p_PRICING_ATTR_tbl              IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   p_PRICING_ATTR_val_tbl          IN  QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
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
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   p_PRICE_LIST_val_rec            IN  QP_Price_List_PUB.Price_List_Val_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_VAL_REC
,   p_PRICE_LIST_LINE_tbl           IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_TBL
,   p_PRICE_LIST_LINE_val_tbl       IN  QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_VAL_TBL
,   p_QUALIFIERS_tbl                IN  Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_QUALIFIERS_TBL
,   p_QUALIFIERS_val_tbl            IN  Qp_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_QUALIFIERS_VAL_TBL
,   p_PRICING_ATTR_tbl              IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_TBL
,   p_PRICING_ATTR_val_tbl          IN  QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_VAL_TBL
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_val_rec            OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Val_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_PRICE_LIST_LINE_val_tbl       OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   x_PRICING_ATTR_val_tbl          OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Price_List';
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_PRICE_LIST_rec              QP_Price_List_PUB.Price_List_Rec_Type;
l_p_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_PRICE_LIST_LINE_tbl         QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_p_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_QUALIFIERS_tbl              Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_p_QUALIFIERS_tbl            Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_PRICING_ATTR_tbl            QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_p_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_installed_status            VARCHAR2(1);
l_request_type_code	      VARCHAR2(3);
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

   /* check for installation status ; if it's basic then this api
      is not available */


    -- shulin, calls from FTE
    IF (QP_PRL_LOADER_PUB.G_PROCESS_LST_REQ_TYPE='FTE' or QP_MOD_LOADER_PUB.G_PROCESS_LST_REQ_TYPE='FTE' ) THEN
    	l_request_type_code := 'FTE';
    END IF;


  /* Raise error if  Rounding factor is NULL.Code added to fix bug # 1641559 */

  IF p_PRICE_LIST_rec.rounding_factor IS NULL THEN
    FND_MESSAGE.SET_NAME('QP','SO_PR_NO_ROUNDING_FACTOR');
    OE_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;




    --  Perform Value to Id conversion

    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_PRICE_LIST_rec              => p_PRICE_LIST_rec
    ,   p_PRICE_LIST_val_rec          => p_PRICE_LIST_val_rec
    ,   p_PRICE_LIST_LINE_tbl         => p_PRICE_LIST_LINE_tbl
    ,   p_PRICE_LIST_LINE_val_tbl     => p_PRICE_LIST_LINE_val_tbl
    ,   p_QUALIFIERS_tbl              => p_QUALIFIERS_tbl
    ,   p_QUALIFIERS_val_tbl          => p_QUALIFIERS_val_tbl
    ,   p_PRICING_ATTR_tbl            => p_PRICING_ATTR_tbl
    ,   p_PRICING_ATTR_val_tbl        => p_PRICING_ATTR_val_tbl
    ,   x_PRICE_LIST_rec              => l_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call QP_LIST_HEADERS_PVT.Process_Price_List
    -- mkarya - set the called_from_ui indicator to 'N', as QP_LIST_HEADERS_PVT.Process_Price_List is
    -- being called from public package

    l_control_rec.called_from_ui := 'N';
    l_p_PRICE_LIST_rec := l_PRICE_LIST_rec;
    l_p_PRICE_LIST_LINE_tbl := l_PRICE_LIST_LINE_tbl;
    l_p_QUALIFIERS_tbl := l_QUALIFIERS_tbl;
    l_p_PRICING_ATTR_tbl := l_PRICING_ATTR_tbl;

    QP_LIST_HEADERS_PVT.Process_Price_List
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_commit                      => p_commit
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_PRICE_LIST_rec              => l_p_PRICE_LIST_rec
    ,   p_PRICE_LIST_LINE_tbl         => l_p_PRICE_LIST_LINE_tbl
    ,   p_QUALIFIERS_tbl              => l_p_QUALIFIERS_tbl
    ,   p_PRICING_ATTR_tbl            => l_p_PRICING_ATTR_tbl
    ,   x_PRICE_LIST_rec              => l_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    );

    --  Load Id OUT parameters.

    x_PRICE_LIST_rec               := l_PRICE_LIST_rec;
    x_PRICE_LIST_LINE_tbl          := l_PRICE_LIST_LINE_tbl;
    x_QUALIFIERS_tbl               := l_QUALIFIERS_tbl;
    x_PRICING_ATTR_tbl             := l_PRICING_ATTR_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_PRICE_LIST_rec              => l_PRICE_LIST_rec
        ,   p_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
        ,   p_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
        ,   p_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
        ,   x_PRICE_LIST_val_rec          => x_PRICE_LIST_val_rec
        ,   x_PRICE_LIST_LINE_val_tbl     => x_PRICE_LIST_LINE_val_tbl
        ,   x_QUALIFIERS_val_tbl          => x_QUALIFIERS_val_tbl
        ,   x_PRICING_ATTR_val_tbl        => x_PRICING_ATTR_val_tbl
        );

    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Price_List'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
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
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   p_PRICE_LIST_val_rec            IN  QP_Price_List_PUB.Price_List_Val_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_VAL_REC
,   p_PRICE_LIST_LINE_tbl           IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_TBL
,   p_PRICE_LIST_LINE_val_tbl       IN  QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_LINE_VAL_TBL
,   p_QUALIFIERS_tbl                IN  Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_QUALIFIERS_TBL
,   p_QUALIFIERS_val_tbl            IN  Qp_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_QUALIFIERS_VAL_TBL
,   p_PRICING_ATTR_tbl              IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_TBL
,   p_PRICING_ATTR_val_tbl          IN  QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_VAL_TBL
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_val_rec            OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Val_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_PRICE_LIST_LINE_val_tbl       OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   x_PRICING_ATTR_val_tbl          OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Price_List';
l_return_status               VARCHAR2(1);
l_PRICE_LIST_rec              QP_Price_List_PUB.Price_List_Rec_Type;
l_p_PRICE_LIST_rec            QP_Price_List_PUB.Price_List_Rec_Type;
l_PRICE_LIST_LINE_tbl         QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_p_PRICE_LIST_LINE_tbl       QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_QUALIFIERS_tbl              Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_p_QUALIFIERS_tbl            Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_PRICING_ATTR_tbl            QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_p_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
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
    ,   p_QUALIFIERS_tbl              => p_QUALIFIERS_tbl
    ,   p_QUALIFIERS_val_tbl          => p_QUALIFIERS_val_tbl
    ,   p_PRICING_ATTR_tbl            => p_PRICING_ATTR_tbl
    ,   p_PRICING_ATTR_val_tbl        => p_PRICING_ATTR_val_tbl
    ,   x_PRICE_LIST_rec              => l_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call QP_LIST_HEADERS_PVT.Lock_Price_List
     l_p_PRICE_LIST_rec := l_PRICE_LIST_rec;
     l_p_PRICE_LIST_LINE_tbl := l_PRICE_LIST_LINE_tbl;
     l_p_QUALIFIERS_tbl := l_QUALIFIERS_tbl;
     l_p_PRICING_ATTR_tbl := l_PRICING_ATTR_tbl;

    QP_LIST_HEADERS_PVT.Lock_Price_List
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_PRICE_LIST_rec              => l_p_PRICE_LIST_rec
    ,   p_PRICE_LIST_LINE_tbl         => l_p_PRICE_LIST_LINE_tbl
    ,   p_QUALIFIERS_tbl              => l_p_QUALIFIERS_tbl
    ,   p_PRICING_ATTR_tbl            => l_p_PRICING_ATTR_tbl
    ,   x_PRICE_LIST_rec              => l_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    );

    --  Load Id OUT parameters.

    x_PRICE_LIST_rec               := l_PRICE_LIST_rec;
    x_PRICE_LIST_LINE_tbl          := l_PRICE_LIST_LINE_tbl;
    x_QUALIFIERS_tbl               := l_QUALIFIERS_tbl;
    x_PRICING_ATTR_tbl             := l_PRICING_ATTR_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_PRICE_LIST_rec              => l_PRICE_LIST_rec
        ,   p_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
        ,   p_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
        ,   p_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
        ,   x_PRICE_LIST_val_rec          => x_PRICE_LIST_val_rec
        ,   x_PRICE_LIST_LINE_val_tbl     => x_PRICE_LIST_LINE_val_tbl
        ,   x_QUALIFIERS_val_tbl          => x_QUALIFIERS_val_tbl
        ,   x_PRICING_ATTR_val_tbl        => x_PRICING_ATTR_val_tbl
        );

    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Price_List'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
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
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_list_header_id                IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_list_header                   IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_val_rec            OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Val_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_PRICE_LIST_LINE_val_tbl       OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   x_PRICING_ATTR_val_tbl          OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Price_List';
l_list_header_id              NUMBER := p_list_header_id;
l_PRICE_LIST_rec              QP_Price_List_PUB.Price_List_Rec_Type;
l_PRICE_LIST_LINE_tbl         QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_QUALIFIERS_tbl              Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_PRICING_ATTR_tbl            QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
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

    IF  p_list_header = FND_API.G_MISS_CHAR
    THEN

        l_list_header_id := p_list_header_id;

    ELSIF p_list_header_id <> FND_API.G_MISS_NUM THEN

        l_list_header_id := p_list_header_id;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_header');
            oe_msg_pub.Add;

        END IF;

    ELSE

        --  Convert Value to Id

        l_list_header_id := QP_Value_To_Id.list_header
        (   p_list_header                 => p_list_header
        );

        IF l_list_header_id = FND_API.G_MISS_NUM THEN
            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
            THEN

                FND_MESSAGE.SET_NAME('QP','Invalid Business Object Value');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_header');
                oe_msg_pub.Add;

            END IF;
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;


    --  Call QP_LIST_HEADERS_PVT.Get_Price_List

    QP_LIST_HEADERS_PVT.Get_Price_List
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_list_header_id              => l_list_header_id
    ,   x_PRICE_LIST_rec              => l_PRICE_LIST_rec
    ,   x_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
    ,   x_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
    ,   x_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
    );

    --  Load Id OUT parameters.

    x_PRICE_LIST_rec               := l_PRICE_LIST_rec;
    x_PRICE_LIST_LINE_tbl          := l_PRICE_LIST_LINE_tbl;
    x_QUALIFIERS_tbl               := l_QUALIFIERS_tbl;
    x_PRICING_ATTR_tbl             := l_PRICING_ATTR_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.TO_BOOLEAN(p_return_values) THEN

        Id_To_Value
        (   p_PRICE_LIST_rec              => l_PRICE_LIST_rec
        ,   p_PRICE_LIST_LINE_tbl         => l_PRICE_LIST_LINE_tbl
        ,   p_QUALIFIERS_tbl              => l_QUALIFIERS_tbl
        ,   p_PRICING_ATTR_tbl            => l_PRICING_ATTR_tbl
        ,   x_PRICE_LIST_val_rec          => x_PRICE_LIST_val_rec
        ,   x_PRICE_LIST_LINE_val_tbl     => x_PRICE_LIST_LINE_val_tbl
        ,   x_QUALIFIERS_val_tbl          => x_QUALIFIERS_val_tbl
        ,   x_PRICING_ATTR_val_tbl        => x_PRICING_ATTR_val_tbl
        );

    END IF;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    oe_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Price_List'
            );
        END IF;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Price_List;

--  Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type
,   p_PRICE_LIST_LINE_tbl           IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   p_QUALIFIERS_tbl                IN  Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   p_PRICING_ATTR_tbl              IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   x_PRICE_LIST_val_rec            OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Val_Rec_Type
,   x_PRICE_LIST_LINE_val_tbl       OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type
,   x_QUALIFIERS_val_tbl            OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type
,   x_PRICING_ATTR_val_tbl          OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type
)
IS
BEGIN

    --  Convert PRICE_LIST

    x_PRICE_LIST_val_rec := QP_Price_List_Util.Get_Values(p_PRICE_LIST_rec);

    --  Convert PRICE_LIST_LINE

    FOR I IN 1..p_PRICE_LIST_LINE_tbl.COUNT LOOP
        x_PRICE_LIST_LINE_val_tbl(I) :=
            QP_Price_List_Line_Util.Get_Values(p_PRICE_LIST_LINE_tbl(I));
    END LOOP;

    --  Convert QUALIFIERS

    FOR I IN 1..p_QUALIFIERS_tbl.COUNT LOOP
        x_QUALIFIERS_val_tbl(I) :=
            QP_Qualifiers_Util.Get_Values(p_QUALIFIERS_tbl(I));
    END LOOP;


    --  Convert PRICING_ATTR

    FOR I IN 1..p_PRICING_ATTR_tbl.COUNT LOOP
        x_PRICING_ATTR_val_tbl(I) :=
            QP_pll_pricing_attr_Util.Get_Values(p_PRICING_ATTR_tbl(I));
    END LOOP;

EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Id_To_Value'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Id_To_Value;

--  Procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type
,   p_PRICE_LIST_val_rec            IN  QP_Price_List_PUB.Price_List_Val_Rec_Type
,   p_PRICE_LIST_LINE_tbl           IN  QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   p_PRICE_LIST_LINE_val_tbl       IN  QP_Price_List_PUB.Price_List_Line_Val_Tbl_Type
,   p_QUALIFIERS_tbl                IN  Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   p_QUALIFIERS_val_tbl            IN  Qp_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type
,   p_PRICING_ATTR_tbl              IN  QP_Price_List_PUB.Pricing_Attr_Tbl_Type
,   p_PRICING_ATTR_val_tbl          IN  QP_Price_List_PUB.Pricing_Attr_Val_Tbl_Type
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type
,   x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type
)
IS
l_PRICE_LIST_rec              QP_Price_List_PUB.Price_List_Rec_Type;
l_PRICE_LIST_LINE_rec         QP_Price_list_PUB.Price_List_Line_Rec_Type;
l_QUALIFIERS_rec              Qp_Qualifier_Rules_Pub.Qualifiers_Rec_Type;
l_PRICING_ATTR_rec            QP_Price_List_PUB.Pricing_Attr_Rec_Type;
l_index                       BINARY_INTEGER;
BEGIN

    --  Init x_return_status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Convert PRICE_LIST

    l_PRICE_LIST_rec := QP_Price_List_Util.Get_Ids
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

        l_PRICE_LIST_LINE_rec := QP_Price_List_Line_Util.Get_Ids
        (   p_PRICE_LIST_LINE_rec         => p_PRICE_LIST_LINE_tbl(l_index)
        ,   p_PRICE_LIST_LINE_val_rec     => p_PRICE_LIST_LINE_val_tbl(l_index)
        );

        x_PRICE_LIST_LINE_tbl(l_index) := l_PRICE_LIST_LINE_rec;

        IF l_PRICE_LIST_LINE_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_PRICE_LIST_LINE_val_tbl.NEXT(l_index);

    END LOOP;

    --  Convert QUALIFIERS

    x_QUALIFIERS_tbl := p_QUALIFIERS_tbl;

    l_index := p_QUALIFIERS_val_tbl.FIRST;


    WHILE l_index IS NOT NULL LOOP

        l_QUALIFIERS_rec := QP_Qualifiers_Util.Get_Ids
        (   p_QUALIFIERS_rec              => p_QUALIFIERS_tbl(l_index)
        ,   p_QUALIFIERS_val_rec          => p_QUALIFIERS_val_tbl(l_index)
        );

        x_QUALIFIERS_tbl(l_index)      := l_QUALIFIERS_rec;

        IF l_QUALIFIERS_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_QUALIFIERS_val_tbl.NEXT(l_index);

    END LOOP;


    --  Convert PRICING_ATTR

    x_PRICING_ATTR_tbl := p_PRICING_ATTR_tbl;

    l_index := p_PRICING_ATTR_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        l_PRICING_ATTR_rec := QP_pll_pricing_attr_Util.Get_Ids
        (   p_PRICING_ATTR_rec            => p_PRICING_ATTR_tbl(l_index)
        ,   p_PRICING_ATTR_val_rec        => p_PRICING_ATTR_val_tbl(l_index)
        );

        x_PRICING_ATTR_tbl(l_index)    := l_PRICING_ATTR_rec;

        IF l_PRICING_ATTR_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_PRICING_ATTR_val_tbl.NEXT(l_index);

    END LOOP;

EXCEPTION

    WHEN OTHERS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Value_To_Id'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Value_To_Id;

END QP_Price_List_GRP;

/
