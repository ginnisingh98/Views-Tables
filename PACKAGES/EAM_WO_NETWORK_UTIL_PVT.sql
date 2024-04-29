--------------------------------------------------------
--  DDL for Package EAM_WO_NETWORK_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WO_NETWORK_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVWNUS.pls 120.0 2005/05/25 15:38:21 appldev noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWNUS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_WO_NETWORK_UTIL_PVT
--
--  NOTES
--
--  HISTORY
--
--  11-SEP-2003    Basanth Roy     Initial Creation
***************************************************************************/



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
	p_ignore_firm_flag		IN	VARCHAR2 := 'N', -- Move firm work orders

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2

        );

  PROCEDURE Schedule_for_Move
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_work_object_type_id           IN      NUMBER,
        p_offset_days                   IN      NUMBER := 1, -- 1 Day Default
        p_offset_direction              IN      NUMBER  := 1, -- Ahead
        p_schedule_method               IN      NUMBER  := 1, -- Forward Scheduling

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2

        );






END EAM_WO_NETWORK_UTIL_PVT;

 

/
