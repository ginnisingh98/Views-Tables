--------------------------------------------------------
--  DDL for Package WIP_WORK_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WORK_ORDER_PVT" AUTHID CURRENT_USER AS
/* $Header: WIPVWORS.pls 115.8 2002/12/01 16:31:03 rmahidha ship $ */

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
);

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
);

PROCEDURE Get_Work_Order
(   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_wip_entity_id                 IN  NUMBER
,   x_FlowSchedule_rec              OUT NOCOPY WIP_Work_Order_PUB.Flowschedule_Rec_Type
,   x_DiscreteJob_rec               OUT NOCOPY WIP_Work_Order_PUB.Discretejob_Rec_Type
,   x_RepSchedule_rec               OUT NOCOPY WIP_Work_Order_PUB.Repschedule_Rec_Type
);

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
			      );

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
			       ,x_msg_data          OUT NOCOPY VARCHAR2);

function component_exist (p_wip_entity_id               number,
                           p_operation_seq_num  number,
                           p_rep_schedule_id    number,
                           p_organization_id    number) return varchar2;
PRAGMA RESTRICT_REFERENCES(component_exist, WNDS, WNPS);

END WIP_Work_Order_PVT;

 

/
