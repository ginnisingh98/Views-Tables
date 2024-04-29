--------------------------------------------------------
--  DDL for Package GMF_ALLOCATIONDEFINITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_ALLOCATIONDEFINITION_PVT" AUTHID CURRENT_USER AS
/* $Header: GMFVALCS.pls 120.3 2006/10/03 15:47:35 rseshadr noship $ */
PROCEDURE Create_Allocation_Definition
(
        p_api_version                   IN  NUMBER                      ,
        p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE ,
        p_commit                        IN  VARCHAR2 := FND_API.G_FALSE ,

        x_return_status                 OUT NOCOPY VARCHAR2                    ,
        x_msg_count                     OUT NOCOPY NUMBER                      ,
        x_msg_data                      OUT NOCOPY VARCHAR2                    ,

        p_allocation_definition_rec     IN  GMF_ALLOCATIONDEFINITION_PUB.Allocation_Definition_Rec_Type
,
        p_user_id                       IN  NUMBER
) ;

PROCEDURE Update_Allocation_Definition
(
        p_api_version                   IN  NUMBER                      ,
        p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE ,
        p_commit                        IN  VARCHAR2 := FND_API.G_FALSE ,

        x_return_status                 OUT NOCOPY VARCHAR2                    ,
        x_msg_count                     OUT NOCOPY NUMBER                      ,
        x_msg_data                      OUT NOCOPY VARCHAR2                    ,

        p_allocation_definition_rec     IN  GMF_ALLOCATIONDEFINITION_PUB.Allocation_Definition_Rec_Type ,
        p_user_id                       IN  NUMBER
) ;
/*
PROCEDURE Delete_Allocation_Definition
(
        p_api_version                   IN  NUMBER                      ,
        p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE ,
        p_commit                        IN  VARCHAR2 := FND_API.G_FALSE ,

        x_return_status                 OUT NOCOPY VARCHAR2                    ,
        x_msg_count                     OUT NOCOPY NUMBER                      ,
        x_msg_data                      OUT NOCOPY VARCHAR2                    ,

        p_allocation_definition_rec     IN  GMF_ALLOCATIONDEFINITION_PUB.Allocation_Definition_Rec_Type ,
        p_user_id                       IN  NUMBER
) ;
*/
END GMF_ALLOCATIONDEFINITION_PVT;

 

/
