--------------------------------------------------------
--  DDL for Package GMF_RESOURCECOST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_RESOURCECOST_PVT" AUTHID CURRENT_USER AS
/* $Header: GMFVRESS.pls 120.3 2006/10/03 15:48:40 rseshadr noship $ */
PROCEDURE Create_Resource_Cost
(       p_api_version           IN  NUMBER                              ,
        p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE         ,
        p_commit                IN  VARCHAR2 := FND_API.G_FALSE         ,

        x_return_status         OUT NOCOPY VARCHAR2                             ,
        x_msg_count             OUT NOCOPY NUMBER                               ,
        x_msg_data              OUT NOCOPY VARCHAR2                             ,

        p_resource_cost_rec     IN  GMF_ResourceCost_PUB.Resource_Cost_Rec_Type         ,
        p_user_id               IN  NUMBER
);

PROCEDURE Update_Resource_Cost
(       p_api_version           IN  NUMBER                              ,
        p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE         ,
        p_commit                IN  VARCHAR2 := FND_API.G_FALSE         ,

        x_return_status         OUT NOCOPY VARCHAR2                             ,
        x_msg_count             OUT NOCOPY NUMBER                               ,
        x_msg_data              OUT NOCOPY VARCHAR2                             ,

        p_resource_cost_rec     IN  GMF_ResourceCost_PUB.Resource_Cost_Rec_Type         ,
        p_user_id               IN  NUMBER
);

PROCEDURE Get_Resource_Cost
(       p_api_version           IN  NUMBER                              ,
        p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE         ,

        x_return_status         OUT NOCOPY VARCHAR2                             ,
        x_msg_count             OUT NOCOPY NUMBER                               ,
        x_msg_data              OUT NOCOPY VARCHAR2                             ,

        p_resource_cost_rec     IN  GMF_ResourceCost_PUB.Resource_Cost_Rec_Type         ,
        x_resource_cost_rec     OUT NOCOPY GMF_ResourceCost_PUB.Resource_Cost_Rec_Type
);

END GMF_ResourceCost_PVT;


 

/
