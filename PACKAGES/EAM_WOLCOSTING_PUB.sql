--------------------------------------------------------
--  DDL for Package EAM_WOLCOSTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WOLCOSTING_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMWWOHS.pls 115.4 2004/04/02 03:44:07 samjain noship $ */
   -- Start of comments
   -- API name    : insert_into_snapshot_pub
   -- Type     :  Private.
   -- Function : Insert the hierarchy into the CST_EAM_HIERARCHY_SNAPSHOT table.
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN       p_api_version           IN NUMBER
   --	p_init_msg_list    	 VARCHAR2:= FND_API.G_FALSE
   --	p_commit 		 VARCHAR2:= FND_API.G_FALSE
   --	p_validation_level 	 NUMBER:= FND_API.G_VALID_LEVEL_FULL
   --	p_wip_entity_id 	 NUMBER
   --	p_object_type 		 NUMBER
   --	p_parent_object_type 	 NUMBER
   --   p_org_id                 NUMBER
   --   p_relationship_type      NUMBER := 3
   -- OUT      x_group_id       NOCOPY  NUMBER,
   --	x_return_status		NOCOPY VARCHAR2
   --	x_msg_count		NOCOPY NUMBER
   --	x_msg_data		NOCOPY VARCHAR2
   -- Notes    : None
   --
   -- End of comments
--Bug3544656: Added a parameter to pass the relationship type
   PROCEDURE insert_into_snapshot_pub(
	p_api_version           IN NUMBER   ,
	p_init_msg_list    	IN VARCHAR2:= FND_API.G_FALSE,
	p_commit 		IN VARCHAR2:= FND_API.G_FALSE ,
	p_validation_level 	IN NUMBER:= FND_API.G_VALID_LEVEL_FULL,
	p_wip_entity_id 	IN NUMBER,
	p_object_type 		IN NUMBER,
	p_parent_object_type 	IN NUMBER,
	x_group_id      OUT NOCOPY  NUMBER,
	x_return_status		OUT	NOCOPY VARCHAR2	,
	x_msg_count		OUT	NOCOPY NUMBER	,
	x_msg_data		OUT	NOCOPY VARCHAR2	,
	p_org_id                IN NUMBER ,
	p_relationship_type IN NUMBER := 3
);

END eam_wolcosting_pub;

 

/
