--------------------------------------------------------
--  DDL for Package Body QP_PRICE_FORMULA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PRICE_FORMULA_PUB" AS
/* $Header: QPXPPRFB.pls 120.4 2006/10/25 08:14:53 nirmkuma ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Price_Formula_PUB';

--  Forward declaration of Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_FORMULA_rec                   IN  Formula_Rec_Type
,   p_FORMULA_LINES_tbl             IN  Formula_Lines_Tbl_Type
,   x_FORMULA_val_rec               OUT NOCOPY /* file.sql.39 change */ Formula_Val_Rec_Type
,   x_FORMULA_LINES_val_tbl         OUT NOCOPY /* file.sql.39 change */ Formula_Lines_Val_Tbl_Type
);

--  Forward declaration of procedure Value_To_Id

PROCEDURE Value_To_Id
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_FORMULA_rec                   IN  Formula_Rec_Type
,   p_FORMULA_val_rec               IN  Formula_Val_Rec_Type
,   p_FORMULA_LINES_tbl             IN  Formula_Lines_Tbl_Type
,   p_FORMULA_LINES_val_tbl         IN  Formula_Lines_Val_Tbl_Type
,   x_FORMULA_rec                   OUT NOCOPY /* file.sql.39 change */ Formula_Rec_Type
,   x_FORMULA_LINES_tbl             OUT NOCOPY /* file.sql.39 change */ Formula_Lines_Tbl_Type
);

--  Start of Comments
--  API name    Process_Price_Formula
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

PROCEDURE Process_Price_Formula
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_FORMULA_rec                   IN  Formula_Rec_Type :=
                                        G_MISS_FORMULA_REC
,   p_FORMULA_val_rec               IN  Formula_Val_Rec_Type :=
                                        G_MISS_FORMULA_VAL_REC
,   p_FORMULA_LINES_tbl             IN  Formula_Lines_Tbl_Type :=
                                        G_MISS_FORMULA_LINES_TBL
,   p_FORMULA_LINES_val_tbl         IN  Formula_Lines_Val_Tbl_Type :=
                                        G_MISS_FORMULA_LINES_VAL_TBL
,   x_FORMULA_rec                   OUT NOCOPY /* file.sql.39 change */ Formula_Rec_Type
,   x_FORMULA_val_rec               OUT NOCOPY /* file.sql.39 change */ Formula_Val_Rec_Type
,   x_FORMULA_LINES_tbl             OUT NOCOPY /* file.sql.39 change */ Formula_Lines_Tbl_Type
,   x_FORMULA_LINES_val_tbl         OUT NOCOPY /* file.sql.39 change */ Formula_Lines_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Price_Formula';
l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_return_status               VARCHAR2(1);
l_qp_status                   VARCHAR2(1);
l_FORMULA_rec                 Formula_Rec_Type;
l_FORMULA_LINES_tbl           Formula_Lines_Tbl_Type;

l_p_FORMULA_rec		      Formula_Rec_Type; --[prarasto]
l_p_FORMULA_LINES_tbl         Formula_Lines_Tbl_Type;--[prarasto]

BEGIN
    SAVEPOINT QP_PPF;
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

    l_qp_status := QP_UTIL.get_qp_status;

    IF l_qp_status = 'S' THEN -- Public API unavailable for Basic Pricing

       l_return_status := FND_API.G_RET_STS_ERROR;
	  FND_MESSAGE.SET_NAME('QP', 'QP_BASIC_PRICING_UNAVAILABLE');
	  OE_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;

    ELSIF l_qp_status = 'N' THEN

       l_return_status := FND_API.G_RET_STS_ERROR;
	  FND_MESSAGE.SET_NAME('QP', 'QP_PRICING_NOT_INSTALLED');
	  OE_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Perform Value to Id conversion

    Value_To_Id
    (   x_return_status               => l_return_status
    ,   p_FORMULA_rec                 => p_FORMULA_rec
    ,   p_FORMULA_val_rec             => p_FORMULA_val_rec
    ,   p_FORMULA_LINES_tbl           => p_FORMULA_LINES_tbl
    ,   p_FORMULA_LINES_val_tbl       => p_FORMULA_LINES_val_tbl
    ,   x_FORMULA_rec                 => l_FORMULA_rec
    ,   x_FORMULA_LINES_tbl           => l_FORMULA_LINES_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call QP_Price_Formula_PVT.Process_Price_Formula
    -- rbagri - set the called_from_ui indicator to 'N', as QP_PRICE_FORMULA_PUB.Process_Price_Formula is
    -- being called from public package

    l_control_rec.called_from_ui := 'N';
    l_p_FORMULA_rec := l_FORMULA_rec;		  --[prarasto]
    l_p_FORMULA_LINES_tbl := l_FORMULA_LINES_tbl; --[prarasto]

    QP_Price_Formula_PVT.Process_Price_Formula
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   p_validation_level            => FND_API.G_VALID_LEVEL_FULL
    ,   p_commit                      => p_commit
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_control_rec                 => l_control_rec
    ,   p_FORMULA_rec                 => l_p_FORMULA_rec
    ,   p_FORMULA_LINES_tbl           => l_p_FORMULA_LINES_tbl
    ,   x_FORMULA_rec                 => l_FORMULA_rec
    ,   x_FORMULA_LINES_tbl           => l_FORMULA_LINES_tbl
    );

    --  Load Id OUT parameters.

    x_FORMULA_rec                  := l_FORMULA_rec;
    x_FORMULA_LINES_tbl            := l_FORMULA_LINES_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_FORMULA_rec                 => l_FORMULA_rec
        ,   p_FORMULA_LINES_tbl           => l_FORMULA_LINES_tbl
        ,   x_FORMULA_val_rec             => x_FORMULA_val_rec
        ,   x_FORMULA_LINES_val_tbl       => x_FORMULA_LINES_val_tbl
        );

    END IF;

--Roll Back the transaction if the return status is not success and it is called from API, bug #5345652

        If x_return_status <> 'S' AND l_control_rec.called_from_ui='N' THEN
                Rollback TO QP_PPF;
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
                Rollback TO QP_PPF;
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
                Rollback TO QP_PPF;
        END IF;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Price_Formula'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
--Roll Back the transaction if the return status is not success and it is called from API, bug #5345652
        If l_control_rec.called_from_ui='N' THEN
                Rollback TO QP_PPF;
        END IF;

END Process_Price_Formula;

--  Start of Comments
--  API name    Lock_Price_Formula
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

PROCEDURE Lock_Price_Formula
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_FORMULA_rec                   IN  Formula_Rec_Type :=
                                        G_MISS_FORMULA_REC
,   p_FORMULA_val_rec               IN  Formula_Val_Rec_Type :=
                                        G_MISS_FORMULA_VAL_REC
,   p_FORMULA_LINES_tbl             IN  Formula_Lines_Tbl_Type :=
                                        G_MISS_FORMULA_LINES_TBL
,   p_FORMULA_LINES_val_tbl         IN  Formula_Lines_Val_Tbl_Type :=
                                        G_MISS_FORMULA_LINES_VAL_TBL
,   x_FORMULA_rec                   OUT NOCOPY /* file.sql.39 change */ Formula_Rec_Type
,   x_FORMULA_val_rec               OUT NOCOPY /* file.sql.39 change */ Formula_Val_Rec_Type
,   x_FORMULA_LINES_tbl             OUT NOCOPY /* file.sql.39 change */ Formula_Lines_Tbl_Type
,   x_FORMULA_LINES_val_tbl         OUT NOCOPY /* file.sql.39 change */ Formula_Lines_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Price_Formula';
l_return_status               VARCHAR2(1);
l_FORMULA_rec                 Formula_Rec_Type;
l_FORMULA_LINES_tbl           Formula_Lines_Tbl_Type;

l_p_FORMULA_rec		      Formula_Rec_Type; --[prarasto]
l_p_FORMULA_LINES_tbl         Formula_Lines_Tbl_Type;--[prarasto]

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
    ,   p_FORMULA_rec                 => p_FORMULA_rec
    ,   p_FORMULA_val_rec             => p_FORMULA_val_rec
    ,   p_FORMULA_LINES_tbl           => p_FORMULA_LINES_tbl
    ,   p_FORMULA_LINES_val_tbl       => p_FORMULA_LINES_val_tbl
    ,   x_FORMULA_rec                 => l_FORMULA_rec
    ,   x_FORMULA_LINES_tbl           => l_FORMULA_LINES_tbl
    );

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call QP_Price_Formula_PVT.Lock_Price_Formula

    l_p_FORMULA_rec := l_FORMULA_rec;		  --[prarasto]
    l_p_FORMULA_LINES_tbl := l_FORMULA_LINES_tbl; --[prarasto]

    QP_Price_Formula_PVT.Lock_Price_Formula
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_FORMULA_rec                 => l_p_FORMULA_rec
    ,   p_FORMULA_LINES_tbl           => l_p_FORMULA_LINES_tbl
    ,   x_FORMULA_rec                 => l_FORMULA_rec
    ,   x_FORMULA_LINES_tbl           => l_FORMULA_LINES_tbl
    );

    --  Load Id OUT parameters.

    x_FORMULA_rec                  := l_FORMULA_rec;
    x_FORMULA_LINES_tbl            := l_FORMULA_LINES_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.to_Boolean(p_return_values) THEN

        Id_To_Value
        (   p_FORMULA_rec                 => l_FORMULA_rec
        ,   p_FORMULA_LINES_tbl           => l_FORMULA_LINES_tbl
        ,   x_FORMULA_val_rec             => x_FORMULA_val_rec
        ,   x_FORMULA_LINES_val_tbl       => x_FORMULA_LINES_val_tbl
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
            ,   'Lock_Price_Formula'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Lock_Price_Formula;

--  Start of Comments
--  API name    Get_Price_Formula
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

PROCEDURE Get_Price_Formula
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_return_values                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_price_formula_id              IN  NUMBER :=
                                        FND_API.G_MISS_NUM
,   p_price_formula                 IN  VARCHAR2 :=
                                        FND_API.G_MISS_CHAR
,   x_FORMULA_rec                   OUT NOCOPY /* file.sql.39 change */ Formula_Rec_Type
,   x_FORMULA_val_rec               OUT NOCOPY /* file.sql.39 change */ Formula_Val_Rec_Type
,   x_FORMULA_LINES_tbl             OUT NOCOPY /* file.sql.39 change */ Formula_Lines_Tbl_Type
,   x_FORMULA_LINES_val_tbl         OUT NOCOPY /* file.sql.39 change */ Formula_Lines_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Price_Formula';
l_price_formula_id            NUMBER := p_price_formula_id;
l_FORMULA_rec                 QP_Price_Formula_PUB.Formula_Rec_Type;
l_FORMULA_LINES_tbl           QP_Price_Formula_PUB.Formula_Lines_Tbl_Type;
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

    IF  p_price_formula = FND_API.G_MISS_CHAR
    THEN

        l_price_formula_id := p_price_formula_id;

    ELSIF p_price_formula_id <> FND_API.G_MISS_NUM THEN

        l_price_formula_id := p_price_formula_id;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
        THEN

            FND_MESSAGE.SET_NAME('QP','FND_BOTH_VAL_AND_ID_EXIST');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_formula');
            OE_MSG_PUB.Add;

        END IF;

    ELSE

        --  Convert Value to Id

        l_price_formula_id := QP_Value_To_Id.price_formula
        (   p_price_formula               => p_price_formula
        );

        IF l_price_formula_id = FND_API.G_MISS_NUM THEN
            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
            THEN

                FND_MESSAGE.SET_NAME('QP','Invalid Business Object Value');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE','price_formula');
                OE_MSG_PUB.Add;

            END IF;
        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;


    --  Call QP_Price_Formula_PVT.Get_Price_Formula

    QP_Price_Formula_PVT.Get_Price_Formula
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_price_formula_id            => l_price_formula_id
    ,   x_FORMULA_rec                 => l_FORMULA_rec
    ,   x_FORMULA_LINES_tbl           => l_FORMULA_LINES_tbl
    );

    --  Load Id OUT parameters.

    x_FORMULA_rec                  := l_FORMULA_rec;
    x_FORMULA_LINES_tbl            := l_FORMULA_LINES_tbl;

    --  If p_return_values is TRUE then convert Ids to Values.

    IF FND_API.TO_BOOLEAN(p_return_values) THEN

        Id_To_Value
        (   p_FORMULA_rec                 => l_FORMULA_rec
        ,   p_FORMULA_LINES_tbl           => l_FORMULA_LINES_tbl
        ,   x_FORMULA_val_rec             => x_FORMULA_val_rec
        ,   x_FORMULA_LINES_val_tbl       => x_FORMULA_LINES_val_tbl
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
            ,   'Get_Price_Formula'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Price_Formula;

--  Procedure Id_To_Value

PROCEDURE Id_To_Value
(   p_FORMULA_rec                   IN  Formula_Rec_Type
,   p_FORMULA_LINES_tbl             IN  Formula_Lines_Tbl_Type
,   x_FORMULA_val_rec               OUT NOCOPY /* file.sql.39 change */ Formula_Val_Rec_Type
,   x_FORMULA_LINES_val_tbl         OUT NOCOPY /* file.sql.39 change */ Formula_Lines_Val_Tbl_Type
)
IS
BEGIN

    --  Convert FORMULA

    x_FORMULA_val_rec := QP_Formula_Util.Get_Values(p_FORMULA_rec);

    --  Convert FORMULA_LINES

    FOR I IN 1..p_FORMULA_LINES_tbl.COUNT LOOP
        x_FORMULA_LINES_val_tbl(I) :=
            QP_Formula_Lines_Util.Get_Values(p_FORMULA_LINES_tbl(I));
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
,   p_FORMULA_rec                   IN  Formula_Rec_Type
,   p_FORMULA_val_rec               IN  Formula_Val_Rec_Type
,   p_FORMULA_LINES_tbl             IN  Formula_Lines_Tbl_Type
,   p_FORMULA_LINES_val_tbl         IN  Formula_Lines_Val_Tbl_Type
,   x_FORMULA_rec                   OUT NOCOPY /* file.sql.39 change */ Formula_Rec_Type
,   x_FORMULA_LINES_tbl             OUT NOCOPY /* file.sql.39 change */ Formula_Lines_Tbl_Type
)
IS
l_FORMULA_rec                 Formula_Rec_Type;
l_FORMULA_LINES_rec           Formula_Lines_Rec_Type;
l_index                       BINARY_INTEGER;
BEGIN

    --  Init x_return_status.

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Convert FORMULA

    l_FORMULA_rec := QP_Formula_Util.Get_Ids
    (   p_FORMULA_rec                 => p_FORMULA_rec
    ,   p_FORMULA_val_rec             => p_FORMULA_val_rec
    );

    x_FORMULA_rec                  := l_FORMULA_rec;

    IF l_FORMULA_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    --  Convert FORMULA_LINES

    x_FORMULA_LINES_tbl := p_FORMULA_LINES_tbl;

    l_index := p_FORMULA_LINES_val_tbl.FIRST;

    WHILE l_index IS NOT NULL LOOP

        l_FORMULA_LINES_rec := QP_Formula_Lines_Util.Get_Ids
        (   p_FORMULA_LINES_rec           => p_FORMULA_LINES_tbl(l_index)
        ,   p_FORMULA_LINES_val_rec       => p_FORMULA_LINES_val_tbl(l_index)
        );

        x_FORMULA_LINES_tbl(l_index)   := l_FORMULA_LINES_rec;

        IF l_FORMULA_LINES_rec.return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        l_index := p_FORMULA_LINES_val_tbl.NEXT(l_index);

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

END QP_Price_Formula_PUB;

/
