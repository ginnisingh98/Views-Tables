--------------------------------------------------------
--  DDL for Package AHL_PC_ASSOCIATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PC_ASSOCIATION_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVPCAS.pls 115.6 2003/07/29 10:09:59 rroy noship $ */

	G_PKG_NAME	CONSTANT  	VARCHAR2(30) 	:= 'AHL_PC_ASSOCIATION_PVT';

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
	--  Procedure name    	: ATTACH_UNIT
	--  Type        	: Private
	--  Function    	: Attached a Unit to a Product Classification Node.
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
	--  CREATE_ASSOCIATIONS Parameters :
	--      p_x_assos_rec           	IN OUT  PC_ASSOS_REC  Required
	--
	--  Version :
	--  	Initial Version   1.0
	--
	--  End of Comments  --
	PROCEDURE ATTACH_UNIT (
		p_api_version         IN            NUMBER,
		p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
		p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
		p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		p_x_assos_rec         IN OUT NOCOPY AHL_PC_ASSOCIATION_PUB.PC_ASSOS_REC,
		x_return_status       OUT    NOCOPY       VARCHAR2,
		x_msg_count           OUT    NOCOPY       NUMBER,
    		x_msg_data            OUT    NOCOPY       VARCHAR2
	);

	--  Start of Comments  --
	--
	--  Procedure name    	: DETACH_UNIT
	--  Type        	: Private
	--  Function    	: Detaches a Unit from a Product Classification Node.
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
	--  UPDATE_ASSOCIATIONS Parameters :
	--      p_x_assos_rec            	IN OUT  PC_ASSOS_REC  Required
	--
	--  Version :
	--  	Initial Version   1.0
	--
	--  End of Comments  --
	PROCEDURE DETACH_UNIT (
		p_api_version         IN            NUMBER,
		p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
		p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
		p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		p_x_assos_rec         IN OUT NOCOPY AHL_PC_ASSOCIATION_PUB.PC_ASSOS_REC,
		x_return_status       OUT    NOCOPY       VARCHAR2,
		x_msg_count           OUT    NOCOPY       NUMBER,
		x_msg_data            OUT    NOCOPY       VARCHAR2
	);

	--  Start of Comments  --
	--
	--  Procedure name    	: ATTACH_ITEM
	--  Type        	: Private
	--  Function    	: Attaches an Item to a Product Classification Node.
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
	--  DELETE_ASSOCIATIONS Parameters :
	--      p_x_assos_rec            	IN OUT  PC_ASSOS_REC  Required
	--
	--  Version :
	--  	Initial Version   1.0
	--
	--  End of Comments  --
	PROCEDURE ATTACH_ITEM (
		p_api_version         IN            NUMBER,
		p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
		p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
		p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		p_x_assos_rec         IN OUT NOCOPY AHL_PC_ASSOCIATION_PUB.PC_ASSOS_REC,
		x_return_status       OUT    NOCOPY       VARCHAR2,
		x_msg_count           OUT    NOCOPY       NUMBER,
		x_msg_data            OUT    NOCOPY       VARCHAR2
	);

	--  Start of Comments  --
	--
	--  Procedure name    	: DETACH_ITEM
	--  Type        	: Private
	--  Function    	: Detaches an Item from a Product Classification Node.
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
	--  DELETE_ASSOCIATIONS Parameters :
	--      p_x_assos_rec            	IN OUT  PC_ASSOS_REC  Required
	--
	--  Version :
	--  	Initial Version   1.0
	--
	--  End of Comments  --
	PROCEDURE DETACH_ITEM (
		p_api_version         IN            NUMBER,
		p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
		p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
		p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		p_x_assos_rec         IN OUT NOCOPY AHL_PC_ASSOCIATION_PUB.PC_ASSOS_REC,
		x_return_status       OUT    NOCOPY       VARCHAR2,
		x_msg_count           OUT    NOCOPY       NUMBER,
		x_msg_data            OUT    NOCOPY       VARCHAR2
	);

	--  Start of Comments  --
	--
	--  Procedure name    	: PROCESS_DOCUMENT
	--  Type        	: Private
	--  Function    	: Creates/Modifies a document association with a PC node.
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
	--  PROCESS_DOCUMENT Parameters :
	--      p_x_assos_tblc            	IN OUT  AHL_DI_ASSO_DOC_ASO_PUB.association_tbl  Required
	--      p_x_assos_tblm            	IN OUT  AHL_DI_ASSO_DOC_ASO_PUB.association_tbl  Required
	--
	--  Version :
	--  	Initial Version   1.0
	--
	--  End of Comments  --
	PROCEDURE PROCESS_DOCUMENT (
		p_api_version         IN            NUMBER,
		p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
		p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
		p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		p_module_type	      IN	    VARCHAR2  := NULL,
		p_x_assos_tbl         IN OUT NOCOPY AHL_DI_ASSO_DOC_GEN_PUB.association_tbl,
		x_return_status       OUT    NOCOPY       VARCHAR2,
		x_msg_count           OUT    NOCOPY       NUMBER,
		x_msg_data            OUT    NOCOPY       VARCHAR2
	);

END AHL_PC_ASSOCIATION_PVT;

 

/
