--------------------------------------------------------
--  DDL for Package EAM_WO_NETWORK_DEFAULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WO_NETWORK_DEFAULT_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVWNDS.pls 120.0 2005/05/25 15:43:30 appldev noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWNDS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_WO_NETWORK_DEFAULT_PVT
--
--  NOTES
--
--  HISTORY
--
--  11-SEP-2003    Basanth Roy     Initial Creation
***************************************************************************/




    l_created_by      NUMBER := FND_GLOBAL.user_id;
    l_last_updated_by NUMBER := FND_GLOBAL.user_id;


    PROCEDURE Add_WO_To_Network
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_child_object_id                     IN      NUMBER,
        p_child_object_type_id                IN      NUMBER,
        p_parent_object_id              IN      NUMBER,
        p_parent_object_type_id         IN      NUMBER,
        p_adjust_parent                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_relationship_type             IN      NUMBER := 1,

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2,
        x_mesg_token_tbl                OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        );

    PROCEDURE Adjust_Parent
        (
        p_parent_object_id              IN NUMBER,
        p_parent_object_type_id         IN NUMBER
        );
/*Bug3521886: Pass requested start date and due date*/
     PROCEDURE Resize_WO
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
        p_object_id                     IN      NUMBER,
        p_object_type_id                IN      NUMBER,
        p_start_date                    IN      DATE,
        p_completion_date               IN      DATE,
	p_required_start_date           IN DATE := NULL,
	p_required_due_date             IN DATE := NULL,
	p_org_id                        IN VARCHAR2,
        p_firm                          IN NUMBER,
        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2
        );



    PROCEDURE Delete_Dependency
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_prior_object_id               IN      NUMBER,
        p_prior_object_type_id          IN      NUMBER,
        p_next_object_id                IN      NUMBER,
        p_next_object_type_id           IN      NUMBER,

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2 ,
        x_mesg_token_tbl                OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        );


     PROCEDURE Add_Dependency
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_prior_object_id               IN      NUMBER,
        p_prior_object_type_id          IN      NUMBER,
        p_next_object_id                IN      NUMBER,
        p_next_object_type_id           IN      NUMBER,

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2 ,
        x_mesg_token_tbl                OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        );


    PROCEDURE Delink_Child_From_Parent
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_child_object_id               IN      NUMBER,
        p_child_object_type_id          IN      NUMBER,
        p_parent_object_id              IN      NUMBER,
        p_parent_object_type_id         IN      NUMBER,
        p_relationship_type             IN      NUMBER,

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2 ,
        x_mesg_token_tbl                OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
        );


    -- This procedure will check whether the operation dates fall within the
    -- WO dates and whether the resource dates fall within the operation dates
    -- This procedure can be used while moving or resizing work orders
    PROCEDURE Check_WO_Dates
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_wip_entity_id                 IN      NUMBER,

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2
        );

  PROCEDURE Check_Resource_Dates
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_wip_entity_id                 IN      NUMBER,

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2
        );


    -- This procedure will check that work order / operation / resource duration cannot be negative
    PROCEDURE Check_Wo_Negative_Dates
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_wip_entity_id                 IN      NUMBER,
        p_organization_id                 IN      NUMBER,

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2
        );


    PROCEDURE Snap_Right
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_work_object_type_id           IN      NUMBER,

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2

        );

    PROCEDURE Snap_Left
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_work_object_type_id           IN      NUMBER,

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2

        );

    PROCEDURE Snap_Right_Window
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_work_object_type_id           IN      NUMBER,

        x_right_snap_window             OUT NOCOPY  NUMBER,
        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2
        --x_Mesg_Token_Tbl                OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type

        );

    PROCEDURE Snap_Left_Window
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_work_object_type_id           IN      NUMBER,

        x_left_snap_window              OUT NOCOPY  NUMBER,
        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2
        --x_Mesg_Token_Tbl                OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type

        );

    PROCEDURE Find_Right_Snap_Window
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_starting_object_id            IN      NUMBER,
        p_starting_obj_type_id          IN      NUMBER,

        p_parent_object_id              IN      NUMBER,
        p_parent_object_type_id         IN      NUMBER,
        p_cur_right_snap_window         IN          NUMBER, -- IN Days

        x_right_snap_window             OUT NOCOPY  NUMBER, -- In Days
        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2
        );

    PROCEDURE Find_Left_Snap_Window
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_starting_object_id            IN      NUMBER,
        p_starting_obj_type_id          IN      NUMBER,

        p_parent_object_id              IN      NUMBER,
        p_parent_object_type_id         IN      NUMBER,
        p_cur_left_snap_window          IN          NUMBER, -- IN Days

        x_left_snap_window              OUT NOCOPY  NUMBER, -- In Days
        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2
        );

--This procedure is called from procedure 'Delink_Child_From_Parent'
--This sets the workorder dates to be the maximum of its operations and child workorders dates
       PROCEDURE Shrink_Parent
        (
        p_parent_object_id              IN NUMBER,
        p_parent_object_type_id         IN NUMBER
        );

END EAM_WO_NETWORK_DEFAULT_PVT;

 

/
