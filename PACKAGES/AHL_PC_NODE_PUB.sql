--------------------------------------------------------
--  DDL for Package AHL_PC_NODE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PC_NODE_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPPCNS.pls 120.0 2005/05/26 11:00:56 appldev noship $ */
/*#
 * This is the public interface to Create /Modify and Delete Product Classification Nodes
 * depending on the flag that is being passed
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Product Classification Nodes
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_PROD_CLASS
 */

	G_PKG_NAME   	CONSTANT  	VARCHAR2(30) 	:= 'AHL_PC_NODE_PUB';

	G_DML_CREATE	CONSTANT	VARCHAR2(1)	:= 'C';
	G_DML_UPDATE	CONSTANT	VARCHAR2(1)	:= 'U';
	G_DML_DELETE	CONSTANT	VARCHAR2(1)	:= 'D';
	G_DML_COPY	CONSTANT	VARCHAR2(1)	:= 'X';
	G_DML_ASSIGN	CONSTANT	VARCHAR2(1)	:= 'A';
	G_DML_LINK	CONSTANT	VARCHAR2(1)	:= 'L';

	-----------------------------------------------------------------
	-- Define Record Type for Product Classification Node Record --
	-----------------------------------------------------------------
	TYPE PC_NODE_REC IS RECORD (
		PC_NODE_ID			NUMBER		:= NULL,
		OBJECT_VERSION_NUMBER		NUMBER		:= NULL,
		NAME				VARCHAR2(240)	:= NULL,
		DESCRIPTION			VARCHAR2(2000)	:= NULL,
		PC_HEADER_ID			NUMBER		:= NULL,
		PARENT_NODE_ID			NUMBER		:= NULL,
		CHILD_COUNT			NUMBER		:= NULL,
		OPERATION_STATUS_FLAG		VARCHAR2(1)	:= NULL,
		DRAFT_FLAG			VARCHAR2(1)	:= NULL,
		LINK_TO_NODE_ID			NUMBER		:= NULL,
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
	TYPE PC_NODE_TBL IS TABLE OF AHL_PC_NODE_PUB.PC_NODE_REC INDEX BY BINARY_INTEGER;

	------------------------
	-- Declare Procedures --
	------------------------
	--  Start of Comments  --
	--
	--  Procedure name    	: PROCESS_NODES
	--  Type        	: Public
	--  Function    	: Processes Product Classification Nodes.
	--  Pre-reqs    	:
	--
	--  Standard IN  Parameters :
	--      p_api_version                   IN      NUMBER       1.0      Required
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
	--      p_x_node_tbl            	IN OUT  PC_NODE_TBL  Required
	--      For every node record in the node table :
	--		PC_HEADER_ID			Required and existing in AHL_PC_HEADERS_VL
	--		PC_NODE_ID			Required / Optional depending on operation
	--		PC_PARENT_NODE_ID		Required [Optional for root node]
	--		PC_NODE_NAME			Required
	--		PC_NODE_DESCRIPTION		Optional
	--		NODE_CHILD_COUNT		Required for Update, Default 0 for Create
	--		OPERATION_FLAG			Required, C - Create, U - Update, D - Delete, X - Copy, A - Assign, L - Link
	--
	--  Version :
	--  	Initial Version   1.0
	--
	--  End of Comments  --
	/*#
	 * It Creates,Modifies and Deletes Product Classification Nodes.
	 * @param p_api_version Api Version Number
	 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
	 * @param p_commit To decide whether to commit the transaction, default value FND_API.G_FALSE
	 * @param p_validation_level Validation level, default value FND_API.G_VALID_LEVEL_FULL
	 * @param p_module_type whether 'API'or 'JSP', default value NULL
	 * @param p_x_nodes_tbl Product Classification table of type PC_NODE_TBL
	 * @param x_return_status Return status,Standard API parameter
	 * @param x_msg_count Return message count,Standard API parameter
	 * @param x_msg_data Return message data,Standard API parameter
	 * @rep:scope public
	 * @rep:lifecycle active
	 * @rep:displayname Process PC Nodes
 	*/
	PROCEDURE PROCESS_NODES (
		p_api_version         IN            NUMBER,
		p_init_msg_list       IN            VARCHAR2  := FND_API.G_TRUE,
		p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
		p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		p_module_type         IN            VARCHAR2  := NULL,
    		p_x_nodes_tbl         IN OUT NOCOPY AHL_PC_NODE_PUB.PC_NODE_TBL,
		x_return_status       OUT    NOCOPY       VARCHAR2,
		x_msg_count           OUT    NOCOPY       NUMBER,
		x_msg_data            OUT    NOCOPY       VARCHAR2
	);


END AHL_PC_NODE_PUB;

 

/
