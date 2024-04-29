--------------------------------------------------------
--  DDL for Package Body WIP_TRANSACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_TRANSACTION_PUB" AS
/* $Header: WIPPTXNB.pls 115.8 2002/12/05 23:26:14 seli ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'WIP_Transaction_PUB';

--  Start of Comments
--  API name    Get_Transaction
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

PROCEDURE Get_Transaction
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := NULL
,   p_return_values                 IN  VARCHAR2 := NULL
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_dummy                         IN  VARCHAR2
,   x_WIPTransaction_tbl            OUT NOCOPY Wiptransaction_Tbl_Type
,   x_WIPTransaction_val_tbl        OUT NOCOPY Wiptransaction_Val_Tbl_Type
,   x_Res_tbl                       OUT NOCOPY Res_Tbl_Type
,   x_Res_val_tbl                   OUT NOCOPY Res_Val_Tbl_Type
,   x_ShopFloorMove_tbl             OUT NOCOPY Shopfloormove_Tbl_Type
,   x_ShopFloorMove_val_tbl         OUT NOCOPY Shopfloormove_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Transaction';
l_dummy                       VARCHAR2(1) := p_dummy;
l_WIPTransaction_tbl          WIP_Transaction_PUB.Wiptransaction_Tbl_Type;
l_Res_tbl                     WIP_Transaction_PUB.Res_Tbl_Type;
l_ShopFloorMove_tbl           WIP_Transaction_PUB.Shopfloormove_Tbl_Type;
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


    --  Call WIP_Transaction_PVT.Get_Transaction

    WIP_Transaction_PVT.Get_Transaction
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => nvl(p_init_msg_list,FND_API.G_FALSE)
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_dummy                       => l_dummy
    ,   x_WIPTransaction_tbl          => l_WIPTransaction_tbl
    ,   x_Res_tbl                     => l_Res_tbl
    ,   x_ShopFloorMove_tbl           => l_ShopFloorMove_tbl
    );

    --  Load Id OUT parameters.

    x_WIPTransaction_tbl           := l_WIPTransaction_tbl;
    x_Res_tbl                      := l_Res_tbl;
    x_ShopFloorMove_tbl            := l_ShopFloorMove_tbl;

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
            ,   'Get_Transaction'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Transaction;

END WIP_Transaction_PUB;

/
