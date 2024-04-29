--------------------------------------------------------
--  DDL for Package AHL_PC_ASSOCIATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PC_ASSOCIATION_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPPCAS.pls 120.0 2005/05/26 01:47:48 appldev noship $ */
/*#
 * This is the public interface to associate the Product Classification with Units/Parts
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Units/Parts Association
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_PROD_CLASS
 */

	G_PKG_NAME   CONSTANT  VARCHAR2(30) := 'AHL_PC_ASSOCIATION_PUB';

	-----------------------------------------------------------------
	-- Define Record Type for Product Classification Node Record --
	-----------------------------------------------------------------
	TYPE PC_ASSOS_REC IS RECORD (
		PC_ASSOCIATION_ID		NUMBER		:= NULL,
		OBJECT_VERSION_NUMBER		NUMBER		:= NULL,
		PC_NODE_ID			NUMBER		:= NULL,
		UNIT_ITEM_ID			NUMBER		:= NULL,
		UNIT_ITEM_NAME			VARCHAR2(240)	:= NULL,
		ASSOCIATION_TYPE_FLAG		VARCHAR2(1)	:= NULL,
		OPERATION_STATUS_FLAG		VARCHAR2(1)	:= NULL,
		DRAFT_FLAG			VARCHAR2(1)	:= NULL,
		INVENTORY_ORG_ID		NUMBER		:= NULL,
		LINK_TO_ASSOCIATION_ID		NUMBER		:= NULL,
		ATTRIBUTE_CATEGORY		VARCHAR2(30)	:= NULL,
		ATTRIBUTE1			VARCHAR2(150)	:= NULL,
		ATTRIBUTE2			VARCHAR2(150)	:= NULL,
		ATTRIBUTE3			VARCHAR2(150)	:= NULL,
		ATTRIBUTE4			VARCHAR2(150)	:= NULL,
		ATTRIBUTE5			VARCHAR2(150)	:= NULL,
		ATTRIBUTE6			VARCHAR2(150)	:= NULL,
		ATTRIBUTE7			VARCHAR2(150)	:= NULL,
		ATTRIBUTE8			VARCHAR2(150)	:= NULL,
		ATTRIBUTE9			VARCHAR2(150)	:= NULL,
		ATTRIBUTE10			VARCHAR2(150)	:= NULL,
		ATTRIBUTE11			VARCHAR2(150)	:= NULL,
		ATTRIBUTE12			VARCHAR2(150)	:= NULL,
		ATTRIBUTE13			VARCHAR2(150)	:= NULL,
		ATTRIBUTE14			VARCHAR2(150)	:= NULL,
		ATTRIBUTE15			VARCHAR2(150)	:= NULL,
		OPERATION_FLAG			VARCHAR2(1)	:= NULL
	);

	---------------------------------
	-- Define Table Type for Node --
	---------------------------------
	TYPE PC_ASSOS_TBL IS TABLE OF AHL_PC_ASSOCIATION_PUB.PC_ASSOS_REC INDEX BY BINARY_INTEGER;

	------------------------
	-- Declare Procedures --
	------------------------
	--  Start of Comments  --
	--
	--  Procedure name    	: PROCESS_ASSOCIATION
	--  Type        	: Public
	--  Function    	: Processes Product Classification Associations with Units/Parts.
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
	--  PROCESS_TEMP_NODES Parameters :
	--      p_x_assos_tbl            	IN OUT  PC_ASSOS_TBL  Required
	--      For every node record in the node table :
	--
	--  Version :
	--  	Initial Version   1.0
	--
	--  End of Comments  --

	/*#
	 * It allows association of Units/Parts to the Product Classification
	 * @param p_api_version Api Version Number
	 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
	 * @param p_commit To decide whether to commit the transaction, default value FND_API.G_FALSE
	 * @param p_validation_level Validation level, default value FND_API.G_VALID_LEVEL_FULL
	 * @param p_module_type whether 'API'or 'JSP', default value NULL
	 * @param p_x_assos_tbl Product Classification table of type PC_ASSOS_TBL
	 * @param x_return_status Return status,,Standard API parameter
	 * @param x_msg_count Return message count,Standard API parameter
	 * @param x_msg_data Return message data,Standard API parameter
	 * @rep:scope public
	 * @rep:lifecycle active
	 * @rep:displayname Process Units/Parts Association
 	 */
	PROCEDURE PROCESS_ASSOCIATIONS (
		p_api_version         IN            NUMBER,
		p_init_msg_list       IN            VARCHAR2  := FND_API.G_TRUE,
		p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
		p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		p_module_type         IN            VARCHAR2  := NULL,
    		p_x_assos_tbl         IN OUT NOCOPY AHL_PC_ASSOCIATION_PUB.PC_ASSOS_TBL,
		x_return_status       OUT   NOCOPY        VARCHAR2,
		x_msg_count           OUT   NOCOPY        NUMBER,
		x_msg_data            OUT   NOCOPY       VARCHAR2
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
	--      p_x_assos_tbl            	IN OUT  AHL_DI_ASSO_DOC_GEN_PUB.association_tbl  Required
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
		p_module_type         IN            VARCHAR2  := NULL,
		p_x_assos_tbl         IN OUT NOCOPY AHL_DI_ASSO_DOC_GEN_PUB.association_tbl,
		x_return_status       OUT    NOCOPY       VARCHAR2,
		x_msg_count           OUT    NOCOPY       NUMBER,
		x_msg_data            OUT    NOCOPY       VARCHAR2
	);

END AHL_PC_ASSOCIATION_PUB;

 

/
