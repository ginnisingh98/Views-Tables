--------------------------------------------------------
--  DDL for Package AHL_UMP_UNPLANNED_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UMP_UNPLANNED_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVUUNS.pls 120.0 2005/05/26 00:09:02 appldev noship $ */

G_PKG_NAME 	CONSTANT 	VARCHAR2(30) 	:= 'AHL_UMP_UNPLANNED_PVT';

-------------------------------
-- Define records and tables --
-------------------------------

-----------------------
-- Define procedures --
-----------------------
--  Start of Comments  --
--
--  Procedure name    	: Create_Unit_Effectivity
--  Type        	: Private
--  Function    	: API to create Unit Effectivities for a particular Instance Number and  Maintenance Requirement
--			  and all the related MRS of that MR and the corresponding Unit Effectivity Relationsships
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER                	Required
--
--  Standard OUT Parameters :
--      x_return_status		OUT     VARCHAR2	Required
--      x_msg_count		OUT     NUMBER		Required
--      x_msg_data		OUT     VARCHAR2	Required
--
--  Create_Unit_Effectivity :
--	p_mr_header_id	IN	NUMBER 		Required
--	p_instance_id 	IN	NUMBER 		Required
--	x_orig_ue_id	        OUT
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --


PROCEDURE Create_Unit_Effectivity
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list         IN              VARCHAR2  := FND_API.G_TRUE,
	p_commit                IN              VARCHAR2  := FND_API.G_FALSE,
	p_validation_level      IN              NUMBER    := FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_mr_header_id	        IN	NUMBER 		,
	p_instance_id 	        IN	NUMBER 		,
	x_orig_ue_id	        OUT	NOCOPY NUMBER
);

-----------------------
-- Define procedures --
-----------------------
--  Start of Comments  --
--
--  Procedure name    	: Delete_Unit_Effectivity
--  Type        	: Private
--  Function    	: API to delete Unit Effectivities and the corresponding Unit Effectivities relationships
--                        for a particular Unit Effectivity Id given as input.
--
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER                	Required
--
--  Standard OUT Parameters :
--      x_return_status		OUT     VARCHAR2	Required
--      x_msg_count		OUT     NUMBER		Required
--      x_msg_data		OUT     VARCHAR2	Required
--
--  Delete_Unit_Effectivity :
--	p_ue_effectivity_id	        IN	NUMBER
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --

PROCEDURE Delete_Unit_Effectivity
(
	p_api_version		IN 		NUMBER,
	p_init_msg_list         IN              VARCHAR2  := FND_API.G_TRUE,
	p_commit                IN              VARCHAR2  := FND_API.G_FALSE,
	p_validation_level      IN              NUMBER    := FND_API.G_VALID_LEVEL_FULL,
	x_return_status       	OUT 	NOCOPY  VARCHAR2,
	x_msg_count           	OUT 	NOCOPY  NUMBER,
	x_msg_data            	OUT 	NOCOPY  VARCHAR2,
	p_unit_effectivity_id	        IN	NUMBER
);

End AHL_UMP_UNPLANNED_PVT;

 

/
