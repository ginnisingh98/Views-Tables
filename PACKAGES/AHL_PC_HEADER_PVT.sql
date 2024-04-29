--------------------------------------------------------
--  DDL for Package AHL_PC_HEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PC_HEADER_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVPCHS.pls 115.6 2003/12/10 14:02:12 sjayacha noship $ */

	G_PKG_NAME   	CONSTANT  	VARCHAR2(30) 	:= 'AHL_PC_HEADER_PVT';

	G_USER_ID 	CONSTANT	NUMBER 		:= FND_GLOBAL.LOGIN_ID;

        G_DML_CREATE    CONSTANT  	VARCHAR2(1)   	:= 'C';
        G_DML_UPDATE    CONSTANT  	VARCHAR2(1)   	:= 'U';
        G_DML_DELETE    CONSTANT  	VARCHAR2(1)   	:= 'D';
        G_DML_COPY      CONSTANT  	VARCHAR2(1)   	:= 'X';
	G_DML_LINK      CONSTANT  	VARCHAR2(1)   	:= 'L';

	G_UNIT		CONSTANT	VARCHAR2(1)	:= 'U';
	G_PART		CONSTANT	VARCHAR2(1)	:= 'I';
	G_NODE		CONSTANT	VARCHAR2(1)	:= 'N';

	-- For COPY_PC_HEADER...
        TYPE PC_NODE_ID_REC IS RECORD
        (
		NODE_ID			NUMBER,
		NEW_NODE_ID		NUMBER
	);

        TYPE PC_NODE_ID_TBL IS TABLE OF PC_NODE_ID_REC INDEX BY BINARY_INTEGER;

	--  Start of Comments  --
	--
	--  Procedure name    	: CREATE_PC_HEADER
	--  Type        	: Private
	--  Function    	: Creates a new Product Classification Header.
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
	--  CREATE_PC_HEADER Parameters :
	--       p_x_pc_header_rec      	IN OUT  PC_HEADER_REC  Required
	--       For every PC_HEADER record :
	--		PC_HEADER_ID			NULL for CREATE_PC_HEADER
	--		NAME				Required
	--		DESCRIPTION
	--		STATUS               	        Required and present in FND_LOOKUPS
	--		PRODUCT_TYPE_CODE    	        Required and present in FND_LOOKUPS
	--		PRIMARY_FLAG          		Required, Default P
	--		ASSOCIATION_TYPE_FLAG           Required, Default U
	--		OPERATION_FLAG			Required, I
	--
	--  Version :
	--  	Initial Version   1.0
	--
	--  End of Comments  --
	PROCEDURE CREATE_PC_HEADER (
		p_api_version         IN            NUMBER,
		p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
		p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
		p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		p_x_pc_header_rec     IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC,
		x_return_status       OUT    NOCOPY       VARCHAR2,
		x_msg_count           OUT    NOCOPY       NUMBER,
    		x_msg_data            OUT    NOCOPY       VARCHAR2);

	--  Start of Comments  --
	--
	--  Procedure name    	: UPDATE_PC_HEADER
	--  Type        	: Private
	--  Function    	: Updates an existing Product Classification Header.
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
	--  UPDATE_PC_HEADER Parameters :
	--       p_x_pc_header_rec      	IN OUT  PC_HEADER_REC  Required
	--       For every PC_HEADER record :
	--		PC_HEADER_ID			Required and existing for UPDATE_PC_HEADER
	--		NAME				Required
	--		DESCRIPTION
	--		STATUS               	        Required and present in FND_LOOKUPS
	--		PRODUCT_TYPE_CODE    	        Required and present in FND_LOOKUPS
	--		PRIMARY_FLAG          Required, Default P
	--		ASSOCIATION_TYPE_FLAG           Required, Default U
	--		OPERATION_FLAG			Required, U
	--
	--  Version :
	--  	Initial Version   1.0
	--
	--  End of Comments  --
	PROCEDURE UPDATE_PC_HEADER (
		p_api_version         IN            NUMBER,
		p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
		p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
		p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		p_x_pc_header_rec     IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC,
		x_return_status       OUT    NOCOPY       VARCHAR2,
		x_msg_count           OUT    NOCOPY       NUMBER,
		x_msg_data            OUT    NOCOPY       VARCHAR2);

	--  Start of Comments  --
	--
	--  Procedure name    	: DELETE_PC_HEADER
	--  Type        	: Private
	--  Function    	: Deletes an existing Product Classification Header and Nodes.
	--  Pre-reqs    	: AHL_PC_NODES_PVT.VALIDATE_NODES
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
	--  DELETE_PC_HEADER Parameters :
	--       p_x_pc_header_rec      	IN OUT  PC_HEADER_REC  Required
	--       For every PC_HEADER record :
	--		PC_HEADER_ID			Required and existing for DELETE_PC_HEADER
	--		OPERATION_FLAG			Required, D
	--
	--  Version :
	--  	Initial Version   1.0
	--
	--  End of Comments  --
	PROCEDURE DELETE_PC_HEADER (
		p_api_version         IN            NUMBER,
		p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
		p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
		p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		p_x_pc_header_rec     IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC,
		x_return_status       OUT    NOCOPY       VARCHAR2,
		x_msg_count           OUT    NOCOPY       NUMBER,
		x_msg_data            OUT    NOCOPY       VARCHAR2);

	--  Start of Comments  --
	--
	--  Procedure name    	: COPY_PC_HEADER
	--  Type        	: Private
	--  Function    	: Copies an existing Product Classification Header and Nodes.
	--  Pre-reqs    	: AHL_PC_NODES_PVT.COPY_NODES
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
	--  COPY_PC_HEADER Parameters :
	--       p_x_pc_header_rec      	IN OUT  PC_HEADER_REC  Required
	--       For every PC_HEADER record :
	--		PC_HEADER_ID			Required and existing for COPY_PC_HEADER
	--		NAME				Required
	--		DESCRIPTION
	--		STATUS                  	Required and present in FND_LOOKUPS
	--		PRODUCT_TYPE_CODE               Required and present in FND_LOOKUPS
	--		PRIMARY_FLAG         		Required, Default P
	--		ASSOCIATION_TYPE_FLAG           Required, Default U
	--		OPERATION_FLAG			Required, C
	--
	--  Version :
	--  	Initial Version   1.0
	--
	--  End of Comments  --
	PROCEDURE COPY_PC_HEADER (
		p_api_version         IN            NUMBER,
		p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
		p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
		p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		p_x_pc_header_rec     IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC,
		x_return_status       OUT    NOCOPY       VARCHAR2,
		x_msg_count           OUT    NOCOPY       NUMBER,
		x_msg_data            OUT    NOCOPY       VARCHAR2);

	--  Start of Comments  --
	--
	--  Procedure name    	: INITIATE_PC_APPROVAL
	--  Type        	: Private
	--  Function    	: Initiates an Approval Process for a Product Classification
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
	--  INITIATE_PC_APPROVAL Parameters :
	--       p_source_pc_header_id       IN         NUMBER
	--       p_object_Version_number     IN         NUMBER
	--
	--  Version :
	--  	Initial Version   1.0
	--
	--  End of Comments  --
	PROCEDURE INITIATE_PC_APPROVAL (
		p_api_version               IN         NUMBER,
		p_init_msg_list       	    IN         VARCHAR2 := FND_API.G_FALSE,
		p_commit                    IN         VARCHAR2 := FND_API.G_FALSE,
		p_validation_level          IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
		p_default                   IN         VARCHAR2 := FND_API.G_FALSE,
		x_return_status             OUT   NOCOPY     VARCHAR2,
		x_msg_count                 OUT   NOCOPY     NUMBER,
		x_msg_data                  OUT   NOCOPY     VARCHAR2,
		p_x_pc_header_rec           IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC
	 );

END AHL_PC_HEADER_PVT;

 

/
