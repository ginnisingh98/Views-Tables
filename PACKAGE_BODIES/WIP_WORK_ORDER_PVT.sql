--------------------------------------------------------
--  DDL for Package Body WIP_WORK_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WORK_ORDER_PVT" AS
/* $Header: WIPVWORB.pls 115.9 2002/12/01 16:32:07 rmahidha ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'WIP_Work_Order_PVT';


--  Start of Comments
--  API name    Lock_Work_Order
--  Type        Private
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

PROCEDURE Lock_Work_Order
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_Wip_Entities_tbl              IN  WIP_Work_Order_PUB.Wip_Entities_Tbl_Type :=
                                        WIP_Work_Order_PUB.G_MISS_WIP_ENTITIES_TBL
,   p_FlowSchedule_tbl              IN  WIP_Work_Order_PUB.Flowschedule_Tbl_Type :=
                                        WIP_Work_Order_PUB.G_MISS_FLOWSCHEDULE_TBL
,   p_DiscreteJob_tbl               IN  WIP_Work_Order_PUB.Discretejob_Tbl_Type :=
                                        WIP_Work_Order_PUB.G_MISS_DISCRETEJOB_TBL
,   p_RepSchedule_tbl               IN  WIP_Work_Order_PUB.Repschedule_Tbl_Type :=
                                        WIP_Work_Order_PUB.G_MISS_REPSCHEDULE_TBL
,   x_Wip_Entities_tbl              IN OUT NOCOPY WIP_Work_Order_PUB.Wip_Entities_Tbl_Type
,   x_FlowSchedule_tbl              IN OUT NOCOPY WIP_Work_Order_PUB.Flowschedule_Tbl_Type
,   x_DiscreteJob_tbl               IN OUT NOCOPY WIP_Work_Order_PUB.Discretejob_Tbl_Type
,   x_RepSchedule_tbl               IN OUT NOCOPY WIP_Work_Order_PUB.Repschedule_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Work_Order';
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_Wip_Entities_rec            WIP_Work_Order_PUB.Wip_Entities_Rec_Type;
l_FlowSchedule_rec            WIP_Work_Order_PUB.Flowschedule_Rec_Type;
l_DiscreteJob_rec             WIP_Work_Order_PUB.Discretejob_Rec_Type;
l_RepSchedule_rec             WIP_Work_Order_PUB.Repschedule_Rec_Type;
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

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Set Savepoint

    SAVEPOINT Lock_Work_Order_PVT;

    --  Lock Wip_Entities

    FOR I IN 1..p_Wip_Entities_tbl.COUNT LOOP

        IF p_Wip_Entities_tbl(I).action = WIP_GLOBALS.G_OPR_LOCK THEN

            WIP_Wip_Entities_Util.Lock_Row
            (   p_Wip_Entities_rec            => p_Wip_Entities_tbl(I)
            ,   x_Wip_Entities_rec            => l_Wip_Entities_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_Wip_Entities_tbl(I)          := l_Wip_Entities_rec;

        END IF;

    END LOOP;

    --  Lock FlowSchedule

    FOR I IN 1..p_FlowSchedule_tbl.COUNT LOOP

        IF p_FlowSchedule_tbl(I).action = WIP_GLOBALS.G_OPR_LOCK THEN

            WIP_Flowschedule_Util.Lock_Row
            (   p_FlowSchedule_rec            => p_FlowSchedule_tbl(I)
            ,   x_FlowSchedule_rec            => l_FlowSchedule_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_FlowSchedule_tbl(I)          := l_FlowSchedule_rec;

        END IF;

    END LOOP;

    --  Lock DiscreteJob

    FOR I IN 1..p_DiscreteJob_tbl.COUNT LOOP

        IF p_DiscreteJob_tbl(I).action = WIP_GLOBALS.G_OPR_LOCK THEN

            WIP_Discretejob_Util.Lock_Row
            (   p_DiscreteJob_rec             => p_DiscreteJob_tbl(I)
            ,   x_DiscreteJob_rec             => l_DiscreteJob_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_DiscreteJob_tbl(I)           := l_DiscreteJob_rec;

        END IF;

    END LOOP;

    --  Lock RepSchedule

    FOR I IN 1..p_RepSchedule_tbl.COUNT LOOP

        IF p_RepSchedule_tbl(I).action = WIP_GLOBALS.G_OPR_LOCK THEN

            WIP_Repschedule_Util.Lock_Row
            (   p_RepSchedule_rec             => p_RepSchedule_tbl(I)
            ,   x_RepSchedule_rec             => l_RepSchedule_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_RepSchedule_tbl(I)           := l_RepSchedule_rec;

        END IF;

    END LOOP;

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

        --  Rollback

        ROLLBACK TO Lock_Work_Order_PVT;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Work_Order_PVT;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Work_Order'
            );
        END IF;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Work_Order_PVT;

END Lock_Work_Order;

--  Start of Comments
--  API name    Get_Work_Order
--  Type        Private
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
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_wip_entity_id                 IN  NUMBER
,   x_Wip_Entities_tbl              OUT NOCOPY WIP_Work_Order_PUB.Wip_Entities_Tbl_Type
,   x_FlowSchedule_tbl              OUT NOCOPY WIP_Work_Order_PUB.Flowschedule_Tbl_Type
,   x_DiscreteJob_tbl               OUT NOCOPY WIP_Work_Order_PUB.Discretejob_Tbl_Type
,   x_RepSchedule_tbl               OUT NOCOPY WIP_Work_Order_PUB.Repschedule_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Work_Order';
l_Wip_Entities_rec            WIP_Work_Order_PUB.Wip_Entities_Rec_Type;
l_Wip_Entities_tbl            WIP_Work_Order_PUB.Wip_Entities_Tbl_Type;
l_FlowSchedule_tbl            WIP_Work_Order_PUB.Flowschedule_Tbl_Type;
l_x_FlowSchedule_tbl          WIP_Work_Order_PUB.Flowschedule_Tbl_Type;
l_DiscreteJob_tbl             WIP_Work_Order_PUB.Discretejob_Tbl_Type;
l_x_DiscreteJob_tbl           WIP_Work_Order_PUB.Discretejob_Tbl_Type;
l_RepSchedule_tbl             WIP_Work_Order_PUB.Repschedule_Tbl_Type;
l_x_RepSchedule_tbl           WIP_Work_Order_PUB.Repschedule_Tbl_Type;
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

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Get Wip_Entities ( parent = Wip_Entities )
    -- Goofed up !!!!!

    l_Wip_Entities_rec :=  WIP_Wip_Entities_Util.Query_Row
    (   p_wip_entity_id       => p_wip_entity_id
    );

    --  Loop over Wip_Entities's children

    FOR I1 IN 1..l_Wip_Entities_tbl.COUNT LOOP

        --  Get FlowSchedule ( parent = Wip_Entities )

        l_FlowSchedule_tbl :=  WIP_Flowschedule_Util.Query_Rows
        (   p_wip_entity_id         => l_Wip_Entities_tbl(I1).wip_entity_id
        );

        FOR I2 IN 1..l_FlowSchedule_tbl.COUNT LOOP
            l_FlowSchedule_tbl(I2).Wip_Entities_Index := I1;
            l_x_FlowSchedule_tbl
            (l_x_FlowSchedule_tbl.COUNT + 1) := l_FlowSchedule_tbl(I2);
        END LOOP;


        --  Get DiscreteJob ( parent = Wip_Entities )

        l_DiscreteJob_tbl :=  WIP_Discretejob_Util.Query_Rows
        (   p_wip_entity_id         => l_Wip_Entities_tbl(I1).wip_entity_id
        );

        FOR I2 IN 1..l_DiscreteJob_tbl.COUNT LOOP
            l_DiscreteJob_tbl(I2).Wip_Entities_Index := I1;
            l_x_DiscreteJob_tbl
            (l_x_DiscreteJob_tbl.COUNT + 1) := l_DiscreteJob_tbl(I2);
        END LOOP;


        --  Get RepSchedule ( parent = Wip_Entities )

        l_RepSchedule_tbl :=  WIP_Repschedule_Util.Query_Rows
        (   p_wip_entity_id         => l_Wip_Entities_tbl(I1).wip_entity_id
        );

        FOR I2 IN 1..l_RepSchedule_tbl.COUNT LOOP
            l_RepSchedule_tbl(I2).Wip_Entities_Index := I1;
            l_x_RepSchedule_tbl
            (l_x_RepSchedule_tbl.COUNT + 1) := l_RepSchedule_tbl(I2);
        END LOOP;


    END LOOP;


    --  Load out parameters

    x_Wip_Entities_tbl             := l_Wip_Entities_tbl;
    x_FlowSchedule_tbl             := l_x_FlowSchedule_tbl;
    x_DiscreteJob_tbl              := l_x_DiscreteJob_tbl;
    x_RepSchedule_tbl              := l_x_RepSchedule_tbl;

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


PROCEDURE Get_Work_Order
(   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_wip_entity_id                 IN  NUMBER
,   x_FlowSchedule_rec              OUT NOCOPY WIP_Work_Order_PUB.Flowschedule_Rec_Type
,   x_DiscreteJob_rec               OUT NOCOPY WIP_Work_Order_PUB.Discretejob_Rec_Type
,   x_RepSchedule_rec               OUT NOCOPY WIP_Work_Order_PUB.Repschedule_Rec_Type
)
IS
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Work_Order';
l_Wip_Entities_rec            WIP_Work_Order_PUB.Wip_Entities_Rec_Type:=WIP_Work_Order_PUB.G_MISS_WIP_ENTITIES_REC;
l_FlowSchedule_rec            WIP_Work_Order_PUB.Flowschedule_Rec_Type:=WIP_Work_Order_PUB.G_MISS_FLOWSCHEDULE_REC;
l_DiscreteJob_rec             WIP_Work_Order_PUB.Discretejob_Rec_Type:=WIP_Work_Order_PUB.G_MISS_DISCRETEJOB_REC;
l_RepSchedule_rec             WIP_Work_Order_PUB.Repschedule_Rec_Type:=WIP_Work_Order_PUB.G_MISS_REPSCHEDULE_REC;
BEGIN

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    l_Wip_Entities_rec :=  WIP_Wip_Entities_Util.Query_Row
    (   p_wip_entity_id       => p_wip_entity_id
    );

    IF l_wip_entities_rec.entity_type = FND_API.G_MISS_NUM THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    --  Loop over Wip_Entities's children

    IF l_wip_entities_rec.entity_type = 1 THEN
        l_DiscreteJob_rec :=  WIP_Discretejob_Util.Query_Row
        (   p_wip_entity_id         => p_wip_entity_id
	    );
     ELSIF l_wip_entities_rec.entity_type = 2 THEN
        l_RepSchedule_rec :=  WIP_Repschedule_Util.Query_Row
        (   p_wip_entity_id         => p_wip_entity_id
        );
     ELSIF l_wip_entities_rec.entity_type = 4 THEN
        l_FlowSchedule_rec :=  WIP_Flowschedule_Util.Query_Row
        (   p_wip_entity_id         => p_wip_entity_id
	    );
     ELSE
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_FlowSchedule_rec := l_FlowSchedule_rec;
    x_DiscreteJob_rec := l_DiscreteJob_rec;
    x_RepSchedule_rec := l_RepSchedule_rec;

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

PROCEDURE Get_Kanban_Details( p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
			      ,p_wip_entity_id      IN NUMBER := FND_API.G_MISS_NUM
			      ,kanban_card_id       IN OUT NOCOPY NUMBER
			      ,x_kanban_card_number OUT NOCOPY VARCHAR2
			      ,x_subinventory       OUT NOCOPY VARCHAR2
			      ,x_locator_id         OUT NOCOPY NUMBER
			      ,x_line_id            OUT NOCOPY NUMBER
			      ,x_supply_status      OUT NOCOPY NUMBER
			      ,x_return_status      OUT NOCOPY VARCHAR2
			      ,x_msg_count          OUT NOCOPY NUMBER
			      ,x_msg_data           OUT NOCOPY VARCHAR2
			      )
  IS
     l_FlowSchedule_rec            WIP_Work_Order_PUB.Flowschedule_Rec_Type;
     l_DiscreteJob_rec             WIP_Work_Order_PUB.Discretejob_Rec_Type;
     l_RepSchedule_rec             WIP_Work_Order_PUB.Repschedule_Rec_Type;
     l_kanban_rec                  INV_Kanban_PVT.Kanban_Card_Rec_Type;
     l_return_status               VARCHAR2(1);
     l_msg_count                   NUMBER;
     l_msg_data                    VARCHAR2(1000);
     l_locator_control             NUMBER;

BEGIN


   x_kanban_card_number := NULL;
   x_subinventory := NULL;
   x_locator_id := NULL;
   x_line_id := NULL;
   x_supply_status := NULL;

    --  Initialize message list.

   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

    -- Initialize the kanban_card_id only if deriving from wip_entity_id

   IF Nvl(kanban_card_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
     AND
     Nvl(p_wip_entity_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
     THEN
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (   G_PKG_NAME
	       ,   'Get Kanban Details'
	       ,   'Keys are mutually exclusive: wip_entity_id = '|| p_wip_entity_id || ', kanban_card_id = '|| kanban_card_id
	       );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    ELSIF Nvl(p_wip_entity_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
      kanban_card_id := NULL;

    ELSIF Nvl(kanban_card_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
      l_kanban_rec.kanban_card_id := kanban_card_id;

    ELSE
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (   G_PKG_NAME
	       ,   'Get Kanban Details'
	       ,   'Either wip_entity_id or kanban_card_id has to be provided'
	       );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;


   IF Nvl(p_wip_entity_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN

      Get_Work_Order(
		     p_init_msg_list  => FND_API.G_TRUE
		     ,x_return_status => x_return_status
		     ,x_msg_count     => x_msg_count
		     ,x_msg_data      => x_msg_data
		     ,p_wip_entity_id => p_wip_entity_id
		     ,x_FlowSchedule_rec => l_FlowSchedule_rec
		     ,x_DiscreteJob_rec  => l_DiscreteJob_rec
		     ,x_RepSchedule_rec  => l_RepSchedule_rec);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_FlowSchedule_rec.kanban_card_id <> FND_API.G_MISS_NUM THEN
	 l_kanban_rec.kanban_card_id := l_FlowSchedule_rec.kanban_card_id;
       ELSIF l_DiscreteJob_rec.kanban_card_id <> FND_API.G_MISS_NUM THEN
	 l_kanban_rec.kanban_card_id := l_DiscreteJob_rec.kanban_card_id;
      END IF;

   END IF;


   IF Nvl(l_kanban_rec.kanban_card_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
      l_kanban_rec := INV_KanbanCard_PKG.Query_Row(p_kanban_card_id  => l_kanban_rec.kanban_card_id);
            kanban_card_id := l_kanban_rec.kanban_card_id;
      x_kanban_card_number := l_kanban_rec.kanban_card_number;
      x_line_id := l_kanban_rec.wip_line_id;
      x_supply_status := l_kanban_rec.supply_status;
      x_subinventory := l_kanban_rec.subinventory_name;
      x_locator_id := l_kanban_rec.locator_id;
      IF Nvl(x_locator_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
	 Wip_Globals.Get_Locator_Control(l_kanban_rec.organization_id,
					x_subinventory,
					l_kanban_rec.inventory_item_id,
					l_return_status,
					l_msg_count,
					l_msg_data,
					l_locator_control
					);
	 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	      THEN
	       FND_MSG_PUB.Add_Exc_Msg
		 (G_PKG_NAME
		  ,'Get Kanban Details'
		  ,'Get Locator Control was not successful. ' || l_msg_data
		  );
	    END IF;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

	 IF l_locator_control = 1 THEN
	    --  Donot default the locator if there is no locator control.
	    x_locator_id := NULL;
	 END IF;
      END IF;

   END IF;


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
            ,   'Get_Kanban_Details'
            );
        END IF;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Kanban_Details;

PROCEDURE Check_Build_Sequence(p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
			       ,p_wip_entity_id     IN NUMBER := FND_API.G_MISS_NUM
			       ,p_organization_id   IN NUMBER := FND_API.G_MISS_NUM
			       ,p_build_sequence    IN NUMBER := FND_API.G_MISS_NUM
			       ,p_schedule_group_id IN NUMBER := FND_API.G_MISS_NUM
			       ,p_line_id           IN NUMBER := FND_API.G_MISS_NUM
			       ,p_FlowSchedule_rec  IN WIP_Work_Order_PUB.FlowSchedule_Rec_Type := WIP_Work_Order_PUB.G_MISS_FLOWSCHEDULE_REC
			       ,p_DiscreteJob_rec   IN WIP_Work_Order_PUB.Discretejob_Rec_Type := WIP_Work_Order_PUB.G_MISS_DISCRETEJOB_REC
			       ,x_build_seq_valid   OUT NOCOPY VARCHAR2
			       ,x_return_status     OUT NOCOPY VARCHAR2
			       ,x_msg_count         OUT NOCOPY NUMBER
			       ,x_msg_data          OUT NOCOPY VARCHAR2)
  IS
l_wip_entity_id NUMBER;
l_org_id NUMBER;
l_build_seq NUMBER;
l_schedule_gp_id NUMBER;
l_line_id NUMBER;

BEGIN
   x_build_seq_valid := FND_API.G_FALSE;
   x_msg_count := 0;
   x_msg_data := NULL;

   --  Initialize message list.

   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF    p_wip_entity_id <> FND_API.G_MISS_NUM
     AND p_organization_id <> FND_API.G_MISS_NUM
     AND (p_build_sequence IS NULL OR p_build_sequence <> FND_API.G_MISS_NUM)
     AND (p_schedule_group_id IS NULL OR p_schedule_group_id <> FND_API.G_MISS_NUM)
     AND (p_line_id IS NULL OR p_line_id <> FND_API.G_MISS_NUM)
     THEN
      l_wip_entity_id := p_wip_entity_id;
      l_org_id := p_organization_id;
      l_build_seq := p_build_sequence;
      l_schedule_gp_id := p_schedule_group_id;
      l_line_id := p_line_id;
    ELSIF p_FlowSchedule_rec.wip_entity_id = FND_API.G_MISS_NUM
      AND p_DiscreteJob_rec.wip_entity_id <> FND_API.G_MISS_NUM
      THEN
        l_wip_entity_id := p_DiscreteJob_rec.wip_entity_id;
	l_org_id := p_DiscreteJob_rec.organization_id;
	l_build_seq := p_DiscreteJob_rec.build_sequence;
	l_schedule_gp_id := p_DiscreteJob_rec.schedule_group_id;
	l_line_id := p_DiscreteJob_rec.line_id;
    ELSIF p_FlowSchedule_rec.wip_entity_id <> FND_API.G_MISS_NUM
      AND p_DiscreteJob_rec.wip_entity_id = FND_API.G_MISS_NUM
      THEN
        l_wip_entity_id := p_FlowSchedule_rec.wip_entity_id;
	l_org_id := p_FlowSchedule_rec.organization_id;
	l_build_seq := p_FlowSchedule_rec.build_sequence;
	l_schedule_gp_id := p_FlowSchedule_rec.schedule_group_id;
	l_line_id := p_FlowSchedule_rec.line_id;
    ELSIF p_FlowSchedule_rec.wip_entity_id <> FND_API.G_MISS_NUM
      AND p_DiscreteJob_rec.wip_entity_id <> FND_API.G_MISS_NUM
      THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (   G_PKG_NAME
	       ,   'Check Build Sequence'
	       ,   'Mutually exclusive parameters: p_FlowSchedule_rec, p_DiscreteJob_rec '
	       );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    ELSE
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (   G_PKG_NAME
	       ,   'Check Build Sequence'
	       ,   'Insufficient Arguments. '
	       );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;
   IF    l_wip_entity_id = FND_API.G_MISS_NUM
     OR l_org_id = FND_API.G_MISS_NUM
     OR l_build_seq = FND_API.G_MISS_NUM
     OR l_schedule_gp_id = FND_API.G_MISS_NUM
     OR l_line_id = FND_API.G_MISS_NUM
     THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (   G_PKG_NAME
	       ,   'Check Build Sequence'
	       ,   'Insufficient Arguments in p_FlowSchedule_rec or p_DiscreteJob_rec. '
	       );
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;
   IF WIP_Validate.Build_Sequence(p_build_sequence     => l_build_seq,
				  p_wip_entity_id      => l_wip_entity_id,
				  p_organization_id    => l_org_id,
				  p_line_id            => l_line_id,
				  p_schedule_group_id  => l_schedule_gp_id) THEN

      x_build_seq_valid := FND_API.G_TRUE;
   END IF;
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
            ,   'Get_Build_Sequence'
            );
        END IF;
        --  Get message count and data
        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Check_Build_Sequence;

function component_exist (p_wip_entity_id       number,
                           p_operation_seq_num  number,
                           p_rep_schedule_id    number,
                           p_organization_id    number) return varchar2 IS
x_exists        varchar2(1);
begin

  SELECT 'Y'
    INTO x_exists
    FROM dual
   WHERE EXISTS (SELECT 1
        from WIP_REQUIREMENT_OPERATIONS
        where wip_entity_id = p_wip_entity_id
        and   organization_id = p_organization_id
        and   operation_seq_num = p_operation_seq_num
        and   NVL(repetitive_schedule_id, -1) = NVL(p_rep_schedule_id, -1));

 IF (x_exists<>'Y') THEN
   return('N');
 ELSE
   return('Y');
 END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN('N');
end;


END WIP_Work_Order_PVT;

/
