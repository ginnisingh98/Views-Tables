--------------------------------------------------------
--  DDL for Package EAM_WO_NETWORK_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WO_NETWORK_VALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVWNVS.pls 120.0 2005/05/25 15:55:04 appldev noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWNVS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_WO_NETWORK_VALIDATE_PVT
--
--  NOTES
--
--  HISTORY
--
--  11-SEP-2003    Basanth Roy     Initial Creation
***************************************************************************/



    PROCEDURE Validate_Structure
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_TRUE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_work_object_id                IN      NUMBER,
        p_work_object_type_id           IN      NUMBER,
        p_exception_logging             IN      VARCHAR2 := 'N',

	p_validate_status		IN      VARCHAR2 := 'N',
	p_output_errors			IN      VARCHAR2 := 'N',

        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2,
        x_wo_relationship_exc_tbl	OUT NOCOPY  EAM_PROCESS_WO_PUB.wo_relationship_exc_tbl_type
        );


    PROCEDURE Check_Constrained_Children
        (
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2 := FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_validation_level              IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,

        p_parent_object_id                IN      NUMBER,
        p_parent_object_type_id           IN      NUMBER,


        x_return_status                 OUT NOCOPY  VARCHAR2,
        x_msg_count                     OUT NOCOPY  NUMBER,
        x_msg_data                      OUT NOCOPY  VARCHAR2
        );

   --fix for 3433757.added procedure validate_status to validate the statuses of parent and child
   PROCEDURE Validate_Status
       (
          p_work_object_id                IN      NUMBER,
          p_work_object_type_id           IN      NUMBER,
          x_return_status                 OUT NOCOPY  VARCHAR2
       );

  -- Added for Detailed Scheduling
  PROCEDURE Validate_Network_Status
       (
          p_work_object_id                IN      NUMBER,
          p_work_object_type_id           IN      NUMBER,
	  p_wo_relationship_exc_tbl       IN OUT  NOCOPY EAM_PROCESS_WO_PUB.wo_relationship_exc_tbl_type
       );


END EAM_WO_NETWORK_VALIDATE_PVT;

 

/
