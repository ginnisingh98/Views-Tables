--------------------------------------------------------
--  DDL for Package WIP_EAM_PROCESS_WO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_EAM_PROCESS_WO_PUB" AUTHID CURRENT_USER AS
/* $Header: WIPPWOPS.pls 115.1 2003/12/23 12:16:15 baroy noship $ */





--    API name    : Update_Firm_Planned_Flag
--    Type        : Private.
--    Function    :
--    Pre-reqs    : None.
--    Parameters  :
--    IN          : p_api_version          IN     NUMBER       Required
--                  p_init_msg_list        IN     VARCHAR2     Optional
--                    Default = FND_API.G_FALSE
--                  p_commit               IN     VARCHAR2     Optional
--                    Default = FND_API.G_FALSE
--                  p_validation_level     IN     NUMBER       Optional
--                    Default = FND_API.G_VALID_LEVEL_FULL
--                  parameter1
--                  parameter2
--                  .
--    OUT         : x_return_status        OUT    VARCHAR2(1)
--                  x_msg_count            OUT    NUMBER
--                  x_msg_data             OUT    VARCHAR2(2000)
--                  parameter1
--                  parameter2
--                  .
--    Version     : Initial version     1.0
--
--    Notes       : Note text
--
-- End of comments

PROCEDURE Update_Firm_Planned_Flag
(   p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level          IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status             OUT NOCOPY   VARCHAR2,
    x_msg_count                 OUT NOCOPY   NUMBER,
    x_msg_data                  OUT NOCOPY   VARCHAR2,
    p_wip_entity_id             IN  NUMBER,
    p_organization_id           IN  NUMBER,
    p_firm_planned_flag          IN  NUMBER
);





PROCEDURE Move_WO
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_work_object_type_id           IN      NUMBER,
        p_offset_days                   IN      NUMBER := 1,  -- 1 Day Default
        p_offset_direction              IN      NUMBER  := 1, -- Forward
        p_start_date                    IN      DATE    := null,
        p_completion_date               IN      DATE    := null,
        p_schedule_method               IN      NUMBER  := 1, -- Forward Scheduling

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2

        );




    PROCEDURE Validate_Structure
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_work_object_type_id           IN      NUMBER,
        p_exception_logging             IN      VARCHAR2 := 'N',

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2
        --x_Mesg_Token_Tbl                OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type

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






END WIP_EAM_PROCESS_WO_PUB;


 

/
