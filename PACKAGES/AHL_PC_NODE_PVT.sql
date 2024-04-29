--------------------------------------------------------
--  DDL for Package AHL_PC_NODE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PC_NODE_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVPCNS.pls 115.4 2002/12/02 14:31:01 pbarman noship $ */

	G_PKG_NAME   	CONSTANT  	VARCHAR2(30) 	:= 'AHL_PC_NODE_PVT';

	G_USER_ID 	CONSTANT 	NUMBER 		:= TO_NUMBER(FND_GLOBAL.LOGIN_ID);

	G_DML_CREATE	CONSTANT	VARCHAR2(1)	:= 'C';
	G_DML_UPDATE	CONSTANT	VARCHAR2(1)	:= 'U';
	G_DML_DELETE	CONSTANT	VARCHAR2(1)	:= 'D';
	G_DML_COPY	CONSTANT	VARCHAR2(1)	:= 'X';
	G_DML_ASSIGN	CONSTANT	VARCHAR2(1)	:= 'A';
	G_DML_LINK	CONSTANT	VARCHAR2(1)	:= 'L';

	G_UNIT		CONSTANT	VARCHAR2(1)	:= 'U';
	G_PART		CONSTANT	VARCHAR2(1)	:= 'I';

	------------------------
	-- Declare Procedures --
	------------------------
	--  Start of Comments  --
	--
	--  Procedure name    	: CREATE_NODE
	--  Type        	: Private
	--  Function    	: Creates a new Product Classification Node.
	--  Pre-reqs    	:
	--
	--  Standard IN  Parameters :
	--      p_api_version                   IN      NUMBER                Required
	--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
	--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
	--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
	--
	--  Standard OUT Parameters :
	--      x_return_status                 OUT     VARCHAR2              Required
	--      x_msg_count                     OUT     NUMBER                Required
	--      x_msg_data                      OUT     VARCHAR2              Required
	--
	--  CREATE_NODES Parameters :
	--      p_x_node_rec           	IN OUT  PC_NODE_REC  Required
	--
	--  Version :
	--  	Initial Version   1.0
	--
	--  End of Comments  --
	PROCEDURE CREATE_NODE (
		p_api_version         IN            NUMBER,
		p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
		p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
		p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		p_x_node_rec          IN OUT NOCOPY AHL_PC_NODE_PUB.PC_NODE_REC,
		x_return_status       OUT    NOCOPY       VARCHAR2,
		x_msg_count           OUT    NOCOPY       NUMBER,
    		x_msg_data            OUT    NOCOPY       VARCHAR2
	);

	--  Start of Comments  --
	--
	--  Procedure name    	: UPDATE_NODE
	--  Type        	: Private
	--  Function    	: Updates an existing Product Classification Node.
	--  Pre-reqs    	:
	--
	--  Standard IN  Parameters :
	--      p_api_version                   IN      NUMBER                Required
	--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
	--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
	--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
	--
	--  Standard OUT Parameters :
	--      x_return_status                 OUT     VARCHAR2              Required
	--      x_msg_count                     OUT     NUMBER                Required
	--      x_msg_data                      OUT     VARCHAR2              Required
	--
	--  UPDATE_NODES Parameters :
	--      p_x_node_rec            	IN OUT  PC_NODE_REC  Required
	--
	--  Version :
	--  	Initial Version   1.0
	--
	--  End of Comments  --
	PROCEDURE UPDATE_NODE (
		p_api_version         IN            NUMBER,
		p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
		p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
		p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		p_x_node_rec          IN OUT NOCOPY AHL_PC_NODE_PUB.PC_NODE_REC,
		x_return_status       OUT    NOCOPY       VARCHAR2,
		x_msg_count           OUT    NOCOPY       NUMBER,
		x_msg_data            OUT    NOCOPY       VARCHAR2
	);

	--  Start of Comments  --
	--
	--  Procedure name    	: DELETE_NODES
	--  Type        	: Private
	--  Function    	: Deletes existing Product Classification Node.
	--  Pre-reqs    	:
	--
	--  Standard IN  Parameters :
	--      p_api_version                   IN      NUMBER                Required
	--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
	--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
	--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
	--
	--  Standard OUT Parameters :
	--      x_return_status                 OUT     VARCHAR2              Required
	--      x_msg_count                     OUT     NUMBER                Required
	--      x_msg_data                      OUT     VARCHAR2              Required
	--
	--  DELETE_NODES Parameters :
	--      p_x_node_rec            	IN OUT  PC_NODE_REC  Required
	--
	--  Version :
	--  	Initial Version   1.0
	--
	--  End of Comments  --
	PROCEDURE DELETE_NODES (
		p_api_version         IN            NUMBER,
		p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
		p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
		p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		p_x_node_rec          IN OUT NOCOPY AHL_PC_NODE_PUB.PC_NODE_REC,
		x_return_status       OUT    NOCOPY       VARCHAR2,
		x_msg_count           OUT    NOCOPY       NUMBER,
		x_msg_data            OUT    NOCOPY       VARCHAR2
	);

END AHL_PC_NODE_PVT;

 

/
