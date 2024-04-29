--------------------------------------------------------
--  DDL for Package AHL_FMP_MR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_FMP_MR_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPMRHS.pls 120.1.12010000.3 2009/10/07 00:11:13 sracha ship $ */
/*#
 * Package containing APIs to create, update and delete Maintenance Requirement(MR) and its associations to Document References,
 * Routes, Effectivities, and Visit Types. It includes APIs to setup Route dependencies within a Maintenance Requirement, define
 * Effectivity details and Interval Thresholds for a Maintenance Requirement Effectivity, setup relationships between Maintenance
 * Requirements, create new revision of a Maintenance Requirement and initiate approval workflows for Maintenance Requirement
 * Completion or Termination.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Maintenance Requirement
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_MAINT_REQUIREMENT
 */

G_PKG_NAME 	CONSTANT 	VARCHAR2(30) 	:= 'AHL_FMP_MR_PUB';

-----------------------
-- Define procedures --
-----------------------
--  Start of Comments  --
--
--  Procedure name    	: Create_Mr
--  Type        	: Public
--  Function    	: API to create Maintenance Requirement and its associations to documents,
--			  routes, visit types, effectivities and relationships.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER 		Required
--	p_init_msg_list		IN	VARCHAR2	Required, default FND_API.G_FALSE
--	p_commit		IN	VARCHAR2	Required, default FND_API.G_FALSE
--	p_validation_level	IN	NUMBER		Required, default FND_API.G_VALID_LEVEL_FULL
--	p_default		IN	VARCHAR2	Required, default FND_API.G_FALSE
--	p_module_type		IN	VARCHAR2	Required, default NULL

--  Standard OUT Parameters :
--      x_return_status		OUT     VARCHAR2	Required
--      x_msg_count		OUT     NUMBER		Required
--      x_msg_data		OUT     VARCHAR2	Required
--
--  Procedure Parameters :
--	p_x_mr_header_rec	IN OUT 	AHL_FMP_MR_HEADER_PVT.mr_header_rec		Required
--	p_x_mr_doc_tbl		IN OUT 	AHL_FMP_MR_DOC_ASSO_PVT.doc_association_tbl
--	p_x_mr_route_tbl	IN OUT 	AHL_FMP_MR_ROUTE_PVT.mr_route_tbl
--	p_x_mr_visit_type_tbl	IN OUT 	AHL_FMP_MR_VISIT_TYPES_PVT.mr_visit_type_tbl_type
--	p_x_effectivity_tbl  	IN OUT 	AHL_FMP_MR_EFFECTIVITY_PVT.effectivity_tbl_type
--	p_x_mr_relation_tbl	IN OUT 	AHL_FMP_MR_RELATION_PVT.mr_relation_tbl
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * Use this procedure to create a Maintenance Requirement and optionally, create associations to Document References, Routes,
 * Visit Types, Effectivities and Relationships to other Maintenance Requirements.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_x_mr_header_rec Maintenance requirement record of type AHL_FMP_MR_HEADER_PVT.mr_header_rec
 * @param p_x_mr_doc_tbl Table of type AHL_FMP_MR_DOC_ASSO_PVT.doc_association_tbl to contain Document References to be associated to the Maintenance Requirement
 * @param p_x_mr_route_tbl Table of type AHL_FMP_MR_ROUTE_PVT.mr_route_tbl to contain Routes to be associated to the Maintenance Requirement
 * @param p_x_mr_visit_type_tbl Table of type AHL_FMP_MR_VISIT_TYPES_PVT.mr_visit_type_tbl_type to contain Visit Types to be associated to the Maintenance Requirement
 * @param p_x_effectivity_tbl Table of type AHL_FMP_MR_EFFECTIVITY_PVT.effectivity_tbl_type to contain Effectivities to be associated to the Maintenance Requirement
 * @param p_x_mr_relation_tbl Table of type AHL_FMP_MR_RELATION_PVT.mr_relation_tbl to contain other Maintenance Requirements to be related to the Maintenance Requirement
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Maintenance Requirement
 */
PROCEDURE Create_Mr
(
	-- standard IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- standard OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- procedure params
	p_x_mr_header_rec		IN OUT NOCOPY	AHL_FMP_MR_HEADER_PVT.mr_header_rec,
	p_x_mr_doc_tbl			IN OUT NOCOPY	AHL_FMP_MR_DOC_ASSO_PVT.doc_association_tbl,
	p_x_mr_route_tbl		IN OUT NOCOPY	AHL_FMP_MR_ROUTE_PVT.mr_route_tbl,
	p_x_mr_visit_type_tbl		IN OUT NOCOPY	AHL_FMP_MR_VISIT_TYPES_PVT.mr_visit_type_tbl_type,
	p_x_effectivity_tbl  		IN OUT NOCOPY 	AHL_FMP_MR_EFFECTIVITY_PVT.effectivity_tbl_type,
	p_x_mr_relation_tbl            	IN OUT NOCOPY 	AHL_FMP_MR_RELATION_PVT.mr_relation_tbl
);

--  Start of Comments  --
--
--  Procedure name    	: Modify_Mr
--  Type        	: Public
--  Function    	: API to modify Maintenance Requirement and its associations to documents,
--			  routes, visit types, effectivities and relationships.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER 		Required
--	p_init_msg_list		IN	VARCHAR2	Required, default FND_API.G_FALSE
--	p_commit		IN	VARCHAR2	Required, default FND_API.G_FALSE
--	p_validation_level	IN	NUMBER		Required, default FND_API.G_VALID_LEVEL_FULL
--	p_default		IN	VARCHAR2	Required, default FND_API.G_FALSE
--	p_module_type		IN	VARCHAR2	Required, default NULL

--  Standard OUT Parameters :
--      x_return_status		OUT     VARCHAR2	Required
--      x_msg_count		OUT     NUMBER		Required
--      x_msg_data		OUT     VARCHAR2	Required
--
--  Procedure Parameters :
--	p_x_mr_header_rec	IN OUT 	AHL_FMP_MR_HEADER_PVT.mr_header_rec
--	p_x_mr_doc_tbl		IN OUT 	AHL_FMP_MR_DOC_ASSO_PVT.doc_association_tbl
--	p_x_mr_route_tbl	IN OUT 	AHL_FMP_MR_ROUTE_PVT.mr_route_tbl
--	p_x_mr_visit_type_tbl	IN OUT 	AHL_FMP_MR_VISIT_TYPES_PVT.mr_visit_type_tbl_type
--	p_x_effectivity_tbl  	IN OUT 	AHL_FMP_MR_EFFECTIVITY_PVT.effectivity_tbl_type
--	p_x_mr_relation_tbl	IN OUT 	AHL_FMP_MR_RELATION_PVT.mr_relation_tbl
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * Use this procedure to modify a Maintenance Requirement and optionally, create, modify, delete associated Document References,
 * Routes, Visit Types, Effectivities and Relationships to other Maintenance Requirements.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_mr_header_rec Maintenance requirement record of type AHL_FMP_MR_HEADER_PVT.mr_header_rec
 * @param p_x_mr_doc_tbl Table of type AHL_FMP_MR_DOC_ASSO_PVT.doc_association_tbl to contain Document References to be associated to the Maintenance Requirement
 * @param p_x_mr_route_tbl Table of type AHL_FMP_MR_ROUTE_PVT.mr_route_tbl to contain Routes to be associated to the Maintenance Requirement
 * @param p_x_mr_visit_type_tbl Table of type AHL_FMP_MR_VISIT_TYPES_PVT.mr_visit_type_tbl_type to contain Visit Types to be associated to the Maintenance Requirement
 * @param p_x_effectivity_tbl Table of type AHL_FMP_MR_EFFECTIVITY_PVT.effectivity_tbl_type to contain Effectivities to be associated to the Maintenance Requirement
 * @param p_x_mr_relation_tbl Table of type AHL_FMP_MR_RELATION_PVT.mr_relation_tbl to contain other Maintenance Requirements to be related to the Maintenance Requirement
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Modify Maintenance Requirement
 */
PROCEDURE Modify_Mr
(
	-- standard IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- standard OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- procedure params
	p_mr_header_rec			IN 		AHL_FMP_MR_HEADER_PVT.mr_header_rec,
	p_x_mr_doc_tbl			IN OUT NOCOPY	AHL_FMP_MR_DOC_ASSO_PVT.doc_association_tbl,
	p_x_mr_route_tbl		IN OUT NOCOPY	AHL_FMP_MR_ROUTE_PVT.mr_route_tbl,
	p_x_mr_visit_type_tbl		IN OUT NOCOPY	AHL_FMP_MR_VISIT_TYPES_PVT.mr_visit_type_tbl_type,
	p_x_effectivity_tbl  		IN OUT NOCOPY 	AHL_FMP_MR_EFFECTIVITY_PVT.effectivity_tbl_type,
	p_x_mr_relation_tbl            	IN OUT NOCOPY 	AHL_FMP_MR_RELATION_PVT.mr_relation_tbl
);

--  Start of Comments  --
--
--  Procedure name    	: Delete_Mr
--  Type        	: Public
--  Function    	: API to delete Maintenance Requirement and all its associations to documents,
--			  routes, visit types, effectivities and relationships.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER 		Required
--	p_init_msg_list		IN	VARCHAR2	Required, default FND_API.G_FALSE
--	p_commit		IN	VARCHAR2	Required, default FND_API.G_FALSE
--	p_validation_level	IN	NUMBER		Required, default FND_API.G_VALID_LEVEL_FULL
--	p_default		IN	VARCHAR2	Required, default FND_API.G_FALSE
--	p_module_type		IN	VARCHAR2	Required, default NULL

--  Standard OUT Parameters :
--      x_return_status		OUT     VARCHAR2	Required
--      x_msg_count		OUT     NUMBER		Required
--      x_msg_data		OUT     VARCHAR2	Required
--
--  Procedure Parameters :
--	p_mr_header_id 		IN	NUMBER		Required
--	p_mr_title		IN	VARCHAR2	Required
--	p_mr_version_number	IN	NUMBER		Required
--	p_mr_object_version  	IN      NUMBER		Required
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * Use this procedure to delete Maintenance Requirement. All associations to Documents, Routes, Visit Types, Effectivities and
 * relationships with other Maintenance Requirements are also deleted.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_mr_header_id Maintenance requirement unique identifier
 * @param p_mr_title Maintenance requirement title
 * @param p_mr_version_number Maintenance requirement revision number
 * @param p_mr_object_version Maintenance requirement object version number
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Maintenance Requirement
 */
PROCEDURE Delete_Mr
(
	-- standard IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- standard OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- procedure params
	p_mr_header_id 			IN          	NUMBER,
	p_mr_title			IN		VARCHAR2,
	p_mr_version_number		IN		NUMBER,
	p_mr_object_version  		IN          	NUMBER
);

--  Start of Comments  --
--
--  Procedure name    	: Create_Mr_Revision
--  Type        	: Public
--  Function    	: API to create a new revision of a Maintenance Requirement.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER 		Required
--	p_init_msg_list		IN	VARCHAR2	Required, default FND_API.G_FALSE
--	p_commit		IN	VARCHAR2	Required, default FND_API.G_FALSE
--	p_validation_level	IN	NUMBER		Required, default FND_API.G_VALID_LEVEL_FULL
--	p_default		IN	VARCHAR2	Required, default FND_API.G_FALSE
--	p_module_type		IN	VARCHAR2	Required, default NULL

--  Standard OUT Parameters :
--      x_return_status		OUT     VARCHAR2	Required
--      x_msg_count		OUT     NUMBER		Required
--      x_msg_data		OUT     VARCHAR2	Required
--
--  Procedure Parameters :
--	p_mr_header_id 		IN	NUMBER		Required
--	p_mr_title		IN	VARCHAR2	Required
--	p_mr_version_number	IN	NUMBER		Required
--	p_mr_object version	IN	NUMBER		Required
--	x_new_mr_header_id  	OUT	NUMBER		Required
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * Use this procedure to create a new revision of an existing and completed Maintenance Requirement.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_mr_header_id Maintenance requirement unique identifier
 * @param p_mr_title Maintenance requirement title
 * @param p_mr_version_number Maintenance requirement revision number
 * @param p_mr_object_version Maintenance requirement object version number
 * @param x_new_mr_header_id Unique identifier of the new revision of the maintenance requirement
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Maintenance Requirement Revision
 */
PROCEDURE Create_Mr_Revision
(
	-- standard IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- standard OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- procedure params
	p_mr_header_id 			IN          	NUMBER,
	p_mr_title			IN		VARCHAR2,
	p_mr_version_number		IN		NUMBER,
	p_mr_object_version		IN		NUMBER,
	x_new_mr_header_id         	OUT NOCOPY  	NUMBER
);

--  Start of Comments  --
--
--  Procedure name    	: Initiate_Mr_Approval
--  Type        	: Public
--  Function    	: API to submit a Maintenance Requirement to complete / terminate approval workflows.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER 		Required
--	p_init_msg_list		IN	VARCHAR2	Required, default FND_API.G_FALSE
--	p_commit		IN	VARCHAR2	Required, default FND_API.G_FALSE
--	p_validation_level	IN	NUMBER		Required, default FND_API.G_VALID_LEVEL_FULL
--	p_default		IN	VARCHAR2	Required, default FND_API.G_FALSE
--	p_module_type		IN	VARCHAR2	Required, default NULL

--  Standard OUT Parameters :
--      x_return_status		OUT     VARCHAR2	Required
--      x_msg_count		OUT     NUMBER		Required
--      x_msg_data		OUT     VARCHAR2	Required
--
--  Procedure Parameters :
--	p_mr_header_id 		IN	NUMBER		Required
--	p_mr_title		IN	VARCHAR2	Required
--	p_mr_version_number	IN	NUMBER		Required
--	p_mr_object_version  	IN	NUMBER		Required
--	p_apprv_type		IN	VARCHAR2	Required, default 'COMPLETE'
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * Use this procedure to submit a Maintenance Requirement for Completion or Termination approval workflows.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_mr_header_id Maintenance requirement unique identifier
 * @param p_mr_title Maintenance requirement title
 * @param p_mr_version_number Maintenance requirement revision number
 * @param p_mr_object_version Maintenance requirement object version number
 * @param p_apprv_type Approval type, one of 'COMPLETE' and 'TERMINATE'
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Initiate Maintenance Requirement Approval
 */
PROCEDURE Initiate_Mr_Approval
(
	-- standard IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- standard OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- procedure params
	p_mr_header_id 			IN          	NUMBER,
	p_mr_title			IN		VARCHAR2,
	p_mr_version_number		IN		NUMBER,
	p_mr_object_version	     	IN          	NUMBER,
	p_apprv_type		     	IN          	VARCHAR2	:='COMPLETE'
);

--  Start of Comments  --
--
--  Procedure name    	: Process_Mr_Route_Seq
--  Type        	: Public
--  Function    	: API to process dependencies among routes associated with a Maintenance Requirement.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER 		Required
--	p_init_msg_list		IN	VARCHAR2	Required, default FND_API.G_FALSE
--	p_commit		IN	VARCHAR2	Required, default FND_API.G_FALSE
--	p_validation_level	IN	NUMBER		Required, default FND_API.G_VALID_LEVEL_FULL
--	p_default		IN	VARCHAR2	Required, default FND_API.G_FALSE
--	p_module_type		IN	VARCHAR2	Required, default NULL

--  Standard OUT Parameters :
--      x_return_status		OUT     VARCHAR2	Required
--      x_msg_count		OUT     NUMBER		Required
--      x_msg_data		OUT     VARCHAR2	Required
--
--  Procedure Parameters :
--	p_x_mr_route_seq_tbl    IN OUT 	AHL_FMP_MR_ROUTE_SEQNCE_PVT.mr_route_seq_tbl	Required
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * Use this procedure to create, modify and delete dependencies within the Maintenance Requirement Routes.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_x_mr_route_seq_tbl Maintenance requirement route dependencies table of type AHL_FMP_MR_ROUTE_SEQNCE_PVT.mr_route_seq_tbl
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Maintenance Requirement Route Dependencies
 */
PROCEDURE Process_Mr_Route_Seq
(
	-- standard IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- standard OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- procedure params
	p_x_mr_route_seq_tbl           	IN OUT NOCOPY 	AHL_FMP_MR_ROUTE_SEQNCE_PVT.mr_route_seq_tbl
);

--  Start of Comments  --
--
--  Procedure name    	: Process_Mr_Effectivities
--  Type        	: Public
--  Function    	: API to process details of Maintenance Requirement effectivities, viz. effectivity
--			  details and interval thresholds.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER 		Required
--	p_init_msg_list		IN	VARCHAR2	Required, default FND_API.G_FALSE
--	p_commit		IN	VARCHAR2	Required, default FND_API.G_FALSE
--	p_validation_level	IN	NUMBER		Required, default FND_API.G_VALID_LEVEL_FULL
--	p_default		IN	VARCHAR2	Required, default FND_API.G_FALSE
--	p_module_type		IN	VARCHAR2	Required, default NULL

--  Standard OUT Parameters :
--      x_return_status		OUT     VARCHAR2	Required
--      x_msg_count		OUT     NUMBER		Required
--      x_msg_data		OUT     VARCHAR2	Required
--
--  Procedure Parameters :
--	p_mr_header_id                 	IN  	NUMBER		Required
--	p_mr_title			IN  	VARCHAR2	Required
--	p_mr_version_number		IN  	NUMBER		Required
--	p_mr_effectivity_id            	IN  	NUMBER		Required
--	p_mr_effectivity_name		IN  	VARCHAR2	Required
--	p_x_mr_effectivity_detail_tbl   IN OUT 	AHL_FMP_EFFECTIVITY_DTL_PVT.effectivity_detail_tbl_type
--	p_x_mr_threshold_rec		IN OUT	AHL_FMP_MR_INTERVAL_PVT.threshold_rec_type
--	p_x_mr_interval_tbl		IN OUT	AHL_FMP_MR_INTERVAL_PVT.interval_tbl_type
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * Use this procedure to create, modify and delete Effectivity Details and Interval thresholds for a Maintenance
 * Requirement Effectivity.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_mr_header_id Maintenance requirement unique identifier
 * @param p_mr_title Maintenance requirement title
 * @param p_mr_version_number Maintenance requirement revision number
 * @param p_super_user Flag to indicate user has super user permissions
 * @param p_mr_effectivity_id Maintenance requirement effectivity unique identifier
 * @param p_mr_effectivity_name Maintenance requirement effectivity name
 * @param p_x_mr_effectivity_detail_tbl Maintenance requirement effectivity details table of type AHL_FMP_EFFECTIVITY_DTL_PVT.effectivity_detail_tbl_type
 * @param p_x_effty_ext_detail_tbl Maintenance requirement extended effectivity details table of type AHL_FMP_EFFECTIVITY_DTL_PVT.effty_ext_detail_tbl_type
 * @param p_x_mr_threshold_rec Maintenance requirement effectivity threshold record of type AHL_FMP_MR_INTERVAL_PVT.threshold_rec_type
 * @param p_x_mr_interval_tbl Maintenance requirement effectivity interval threshold table of type AHL_FMP_MR_INTERVAL_PVT.threshold_tbl_type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Maintenance Requirement Effectivities
 */
PROCEDURE Process_Mr_Effectivities
(
	-- standard IN params
	p_api_version			IN		NUMBER,
	p_init_msg_list			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_commit			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_validation_level		IN		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	p_default			IN		VARCHAR2	:=FND_API.G_FALSE,
	p_module_type			IN		VARCHAR2	:=NULL,
	-- standard OUT params
	x_return_status             	OUT NOCOPY  	VARCHAR2,
	x_msg_count                	OUT NOCOPY  	NUMBER,
	x_msg_data                  	OUT NOCOPY  	VARCHAR2,
	-- procedure params
	p_mr_header_id                 	IN  		NUMBER,
	p_mr_title			IN  		VARCHAR2,
	p_mr_version_number		IN  		NUMBER,
	p_super_user			IN		VARCHAR2 	:='N',
	p_mr_effectivity_id            	IN  		NUMBER,
	p_mr_effectivity_name		IN  		VARCHAR2,
	p_x_mr_effectivity_detail_tbl  	IN OUT NOCOPY   AHL_FMP_EFFECTIVITY_DTL_PVT.effectivity_detail_tbl_type,
        p_x_effty_ext_detail_tbl       IN OUT NOCOPY  AHL_FMP_EFFECTIVITY_DTL_PVT.effty_ext_detail_tbl_type,
	p_x_mr_threshold_rec		IN OUT NOCOPY   AHL_FMP_MR_INTERVAL_PVT.threshold_rec_type,
	p_x_mr_interval_tbl		IN OUT NOCOPY   AHL_FMP_MR_INTERVAL_PVT.interval_tbl_type
);

END AHL_FMP_MR_PUB;

/
