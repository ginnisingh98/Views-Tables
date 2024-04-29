--------------------------------------------------------
--  DDL for Package Body WIP_WORK_ORDER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WORK_ORDER_PUB" AS
/* $Header: WIPPWORB.pls 115.10 2002/12/01 16:07:49 rmahidha ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'WIP_Work_Order_PUB';

--  Start of Comments

--  Start of Comments
--  API name    Get_Work_Order
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

PROCEDURE Get_Work_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2
,   p_return_values                 IN  VARCHAR2
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_wip_entity_id                 IN  NUMBER
,   x_Wip_Entities_tbl              OUT NOCOPY Wip_Entities_Tbl_Type
,   x_Wip_Entities_val_tbl          OUT NOCOPY Wip_Entities_Val_Tbl_Type
,   x_FlowSchedule_tbl              OUT NOCOPY Flowschedule_Tbl_Type
,   x_FlowSchedule_val_tbl          OUT NOCOPY Flowschedule_Val_Tbl_Type
,   x_DiscreteJob_tbl               OUT NOCOPY Discretejob_Tbl_Type
,   x_DiscreteJob_val_tbl           OUT NOCOPY Discretejob_Val_Tbl_Type
,   x_RepSchedule_tbl               OUT NOCOPY Repschedule_Tbl_Type
,   x_RepSchedule_val_tbl           OUT NOCOPY Repschedule_Val_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Work_Order';
l_wip_entity_id               NUMBER := p_wip_entity_id;
l_Wip_Entities_tbl            WIP_Work_Order_PUB.Wip_Entities_Tbl_Type;
l_FlowSchedule_tbl            WIP_Work_Order_PUB.Flowschedule_Tbl_Type;
l_DiscreteJob_tbl             WIP_Work_Order_PUB.Discretejob_Tbl_Type;
l_RepSchedule_tbl             WIP_Work_Order_PUB.Repschedule_Tbl_Type;
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

    IF p_wip_entity_id <> FND_API.G_MISS_NUM THEN

        l_wip_entity_id := p_wip_entity_id;

    ELSE

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	 THEN
	  FND_MESSAGE.SET_NAME('WIP','Invalid Business Object Value');
	  FND_MESSAGE.SET_TOKEN('ATTRIBUTE','wip_entity');
	  FND_MSG_PUB.Add;
       END IF;

        RAISE FND_API.G_EXC_ERROR;
    END IF;


    --  Call WIP_Work_Order_PVT.Get_Work_Order

    WIP_Work_Order_PVT.Get_Work_Order
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list
    ,   x_return_status               => x_return_status
    ,   x_msg_count                   => x_msg_count
    ,   x_msg_data                    => x_msg_data
    ,   p_wip_entity_id               => l_wip_entity_id
    ,   x_Wip_Entities_tbl            => l_Wip_Entities_tbl
    ,   x_FlowSchedule_tbl            => l_FlowSchedule_tbl
    ,   x_DiscreteJob_tbl             => l_DiscreteJob_tbl
    ,   x_RepSchedule_tbl             => l_RepSchedule_tbl
    );

    --  Load Id OUT parameters.

    x_Wip_Entities_tbl             := l_Wip_Entities_tbl;
    x_FlowSchedule_tbl             := l_FlowSchedule_tbl;
    x_DiscreteJob_tbl              := l_DiscreteJob_tbl;
    x_RepSchedule_tbl              := l_RepSchedule_tbl;

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
            ,   'Get_Work_Order'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Work_Order;

END WIP_Work_Order_PUB;

/
