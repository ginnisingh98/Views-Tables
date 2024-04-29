--------------------------------------------------------
--  DDL for Package AHL_PC_HEADER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PC_HEADER_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPPCHS.pls 120.0 2005/05/25 23:38:28 appldev noship $ */
/*#
 * This is the public interface to create, modify and terminate Product Classifiaction Header
 * depending on the flag that is being passed.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Product Classification Header
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_PROD_CLASS
 */

	G_PKG_NAME   CONSTANT  VARCHAR2(30) := 'AHL_PC_HEADER_PUB';

	G_DML_CREATE    CONSTANT  	VARCHAR2(1)   	:= 'C';
        G_DML_UPDATE    CONSTANT  	VARCHAR2(1)   	:= 'U';
        G_DML_DELETE    CONSTANT  	VARCHAR2(1)   	:= 'D';
        G_DML_COPY      CONSTANT  	VARCHAR2(1)   	:= 'X';
	G_DML_LINK      CONSTANT  	VARCHAR2(1)   	:= 'L';

	-----------------------------------------------------------------
	-- Define Record Type for Product Classification Header Record --
	-----------------------------------------------------------------
	TYPE PC_HEADER_REC IS RECORD (
		PC_HEADER_ID			NUMBER,
		NAME				VARCHAR2(240),
		DESCRIPTION          		VARCHAR2(2000),
		STATUS               		VARCHAR2(30),
		STATUS_DESC	   		VARCHAR2(80),
		PRODUCT_TYPE_CODE    		VARCHAR2(30),
		PRODUCT_TYPE_DESC	    	VARCHAR2(80),
		PRIMARY_FLAG          		VARCHAR2(1),
		PRIMARY_FLAG_DESC      		VARCHAR2(80),
		ASSOCIATION_TYPE_FLAG           VARCHAR2(1),
		ASSOCIATION_TYPE_DESC           VARCHAR2(80),
		DRAFT_FLAG			VARCHAR2(1),
		LINK_TO_PC_ID  			NUMBER,
		OBJECT_VERSION_NUMBER           NUMBER,
		ATTRIBUTE_CATEGORY              VARCHAR2(30),
		ATTRIBUTE1                      VARCHAR2(150),
		ATTRIBUTE2                      VARCHAR2(150),
		ATTRIBUTE3                      VARCHAR2(150),
		ATTRIBUTE4                      VARCHAR2(150),
		ATTRIBUTE5                      VARCHAR2(150),
		ATTRIBUTE6                      VARCHAR2(150),
		ATTRIBUTE7                      VARCHAR2(150),
		ATTRIBUTE8                      VARCHAR2(150),
		ATTRIBUTE9                      VARCHAR2(150),
		ATTRIBUTE10                     VARCHAR2(150),
		ATTRIBUTE11                     VARCHAR2(150),
		ATTRIBUTE12                     VARCHAR2(150),
		ATTRIBUTE13                     VARCHAR2(150),
		ATTRIBUTE14                     VARCHAR2(150),
		ATTRIBUTE15                     VARCHAR2(150),
		OPERATION_FLAG			VARCHAR2(1),
		COPY_ASSOS_FLAG			VARCHAR2(1),
		COPY_DOCS_FLAG			VARCHAR2(1)
	);

	------------------------
	-- Declare Procedures --
	------------------------
	--  Start of Comments  --
	--
	--  Procedure name    	: PROCESS_PC_HEADER
	--  Type        	: Public
	--  Function    	: Processes Product Classification Header.
	--  Pre-reqs    	:
	--
	--  Standard IN  Parameters :
	--      p_api_version                   IN      NUMBER                Required
	--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
	--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
	--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
	--      p_module_type                   IN      VARCHAR2     Default  NULL
	--
	--  Standard OUT Parameters :
	--      x_return_status                 OUT     VARCHAR2              Required
	--      x_msg_count                     OUT     NUMBER                Required
	--      x_msg_data                      OUT     VARCHAR2              Required
	--
	--      p_x_PC_HEADER_rec            	IN OUT NOCOPY PC_HEADER_REC  Required
	--      	PC_HEADER_ID	        	Required / Optional depending on operation  - System Generated Primary Key
	--  		NAME				Required  and should be unique
	--  		DESCRIPTION 			Optional
	--  		STATUS            	   	Required
	--  		STATUS_DES		   	Optional
	--  		PRODUCT_TYPE_CODE 	  	Required
	--  		PRODUCT_TYPE_DESC 	  	Optional
	--  		PRIMARY_FLAG                    Required   Y/N
	--  		ASSOCIATION_TYPE_FLAG           Required   U/I
	--		OPERATION_FLAG			Required,  C - Create, U - Update, D - Delete, X - Copy, L - Link
	--
	--  Version :
	--  	Initial Version   1.0
	--
	--  End of Comments  --
	/*#
	 * The procedure Creates, modifies and deletes Product Classification Header.
	 * @param p_api_version Api Version Number
	 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_FALSE
	 * @param p_commit To decide whether to commit the transaction, default value FND_API.G_FALSE
	 * @param p_validation_level Validation level, default value FND_API.G_VALID_LEVEL_FULL
	 * @param p_module_type whether 'API'or 'JSP', default value NULL
	 * @param p_x_pc_header_rec Product Classification table of type PC_HEADER_REC
	 * @param x_return_status Return status,Standard API parameter
	 * @param x_msg_count Return message count,Standard API parameter
	 * @param x_msg_data Return message data,Standard API parameter
	 * @rep:scope public
	 * @rep:lifecycle active
	 * @rep:displayname Process PC Header
 	*/
	PROCEDURE PROCESS_PC_HEADER (
		p_api_version         IN            NUMBER,
		p_init_msg_list       IN            VARCHAR2  := FND_API.G_FALSE,
		p_commit              IN            VARCHAR2  := FND_API.G_FALSE,
		p_validation_level    IN            NUMBER    := FND_API.G_VALID_LEVEL_FULL,
		p_module_type         IN            VARCHAR2  := NULL,
    		p_x_pc_header_rec     IN OUT NOCOPY AHL_PC_HEADER_PUB.PC_HEADER_REC,
		x_return_status       OUT    NOCOPY       VARCHAR2,
		x_msg_count           OUT    NOCOPY       NUMBER,
		x_msg_data            OUT    NOCOPY       VARCHAR2
	);

END AHL_PC_HEADER_PUB;

 

/
