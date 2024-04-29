--------------------------------------------------------
--  DDL for Package AHL_RM_OPERATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_RM_OPERATION_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPOPES.pls 120.0.12000000.2 2007/10/18 13:28:19 adivenka ship $ */
/*#
 * Package containing APIs to create, update and delete Operations and its associated document references, resource requirements,
 * resource costing parameters, alternate resources, access panels and material requirements. It allows users to submit Operations for completion
 * or termination approval flows and to create Operation revisions.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Operation
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_MAINT_OPERATION
 */

G_PKG_NAME 	CONSTANT 	VARCHAR2(30) 	:= 'AHL_RM_OPERATION_PUB';

-----------------------
-- Define procedures --
-----------------------
--  Start of Comments  --
--
--  Procedure name    	: Create_Operation
--  Type        	: Public
--  Function    	: API to create Operation and its associations to documents, resources,
--			  resource costing parameters, access panels and materials.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER 		Required, default 1.0
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
--	p_x_oper_rec        	IN OUT  AHL_RM_OPERATION_PVT.operation_rec_type			Required
--	p_x_oper_doc_tbl  	IN OUT  AHL_RM_ASSO_DOCASO_PVT.doc_association_tbl
--	p_x_oper_resource_tbl	IN OUT  AHL_RM_RT_OPER_RESOURCE_PVT.rt_oper_resource_tbl_type
--	p_x_oper_material_tbl 	IN OUT  AHL_RM_MATERIAL_AS_PVT.material_req_tbl_type
--	p_x_oper_panel_tbl	IN OUT  AHL_RM_RT_OPER_PANEL_PVT.rt_oper_panel_tbl_type
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * Use this procedure to create an Operation and optionally, create associated document references, resource requirements, resource costing parameters and material requirements.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_x_oper_rec Operation record of type AHL_RM_OPERATION_PVT.operation_rec_type
 * @param p_x_oper_doc_tbl Table of Documents of type AHL_RM_ASSO_DOCASO_PVT.doc_association_tbl that need to be associated to the Operation
 * @param p_x_oper_resource_tbl Table of Resource Requirements of type AHL_RM_RT_OPER_RESOURCE_PVT.rt_oper_resource_tbl_type that need to be associated to the Operation
 * @param p_x_oper_material_tbl Table of Material Requirements of type AHL_RM_MATERIAL_AS_PVT.material_req_tbl_type that need to be associated to the Operation
 * @param p_x_oper_panel_tbl Table of Access Panels of type AHL_RM_RT_OPER_PANEL_PVT.rt_oper_panel_tbl_type that need to be associated to the Operation
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Operation
 */
PROCEDURE Create_Operation
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
	p_x_oper_rec        		IN OUT NOCOPY 	AHL_RM_OPERATION_PVT.operation_rec_type,
	p_x_oper_doc_tbl  		IN OUT NOCOPY  	AHL_RM_ASSO_DOCASO_PVT.doc_association_tbl,
	p_x_oper_resource_tbl		IN OUT NOCOPY 	AHL_RM_RT_OPER_RESOURCE_PVT.rt_oper_resource_tbl_type,
	p_x_oper_material_tbl 		IN OUT NOCOPY 	AHL_RM_MATERIAL_AS_PVT.material_req_tbl_type,
	p_x_oper_panel_tbl		IN OUT NOCOPY	AHL_RM_RT_OPER_PANEL_PVT.rt_oper_panel_tbl_type
);

--  Start of Comments  --
--
--  Procedure name    	: Modify_Operation
--  Type        	: Public
--  Function    	: API to modify Operation details and its associations to documents, resources,
--			  resource costing parameters, access panels and materials.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER 		Required, default 1.0
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
--	p_oper_rec        	IN      AHL_RM_OPERATION_PVT.operation_rec_type			Required
--	p_x_oper_doc_tbl  	IN OUT  AHL_RM_ASSO_DOCASO_PVT.doc_association_tbl
--	p_x_oper_resource_tbl	IN OUT  AHL_RM_RT_OPER_RESOURCE_PVT.rt_oper_resource_tbl_type
--	p_x_oper_material_tbl 	IN OUT  AHL_RM_MATERIAL_AS_PVT.material_req_tbl_type
--	p_x_oper_panel_tbl	IN OUT  AHL_RM_RT_OPER_PANEL_PVT.rt_oper_panel_tbl_type
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * Use this procedure to modify an Operation and optionally, create, modify and delete associated document references, resource requirements, resource costing parameters and material requirements.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_oper_rec Operation record of type AHL_RM_OPERATION_PVT.operation_rec_type
 * @param p_x_oper_doc_tbl Table of Documents of type AHL_RM_ASSO_DOCASO_PVT.doc_association_tbl that need to be associated to the Operation
 * @param p_x_oper_resource_tbl Table of Resource Requirements of type AHL_RM_RT_OPER_RESOURCE_PVT.rt_oper_resource_tbl_type that need to be associated to the Operation
 * @param p_x_oper_material_tbl Table of Material Requirements of type AHL_RM_MATERIAL_AS_PVT.material_req_tbl_type that need to be associated to the Operation
 * @param p_x_oper_panel_tbl Table of Access Panels of type AHL_RM_RT_OPER_PANEL_PVT.rt_oper_panel_tbl_type that need to be associated to the Operation
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Modify Operation
 */
PROCEDURE Modify_Operation
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
	p_oper_rec        	        IN 	        AHL_RM_OPERATION_PVT.operation_rec_type,
	p_x_oper_doc_tbl  		IN OUT NOCOPY  	AHL_RM_ASSO_DOCASO_PVT.doc_association_tbl,
	p_x_oper_resource_tbl		IN OUT NOCOPY 	AHL_RM_RT_OPER_RESOURCE_PVT.rt_oper_resource_tbl_type,
	p_x_oper_material_tbl 		IN OUT NOCOPY 	AHL_RM_MATERIAL_AS_PVT.material_req_tbl_type,
	p_x_oper_panel_tbl		IN OUT NOCOPY	AHL_RM_RT_OPER_PANEL_PVT.rt_oper_panel_tbl_type
);

--  Start of Comments  --
--
--  Procedure name    	: Delete_Operation
--  Type        	: Public
--  Function    	: API to deletion of operations. All associations to documents, resources,
--			  resource costing parameters and materials are also deleted.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER 		Required, default 1.0
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
--	p_oper_id 		IN	NUMBER		Required
--	p_oper_number		IN	VARCHAR2	Required
--	p_oper_revision		IN	NUMBER		Required
--	p_oper_object_version  	IN      NUMBER		Required
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * Use this procedure to delete an Operation. All associations to documents, resource requirements, resource costing parameters and material requirements are deleted.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_oper_id Operation unique identifier
 * @param p_oper_number Operation number
 * @param p_oper_revision Operation revision number
 * @param p_oper_object_version Operation object version number
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Operation
 */
PROCEDURE Delete_Operation
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
	p_oper_id			IN		NUMBER,
	p_oper_number			IN		VARCHAR2,
	p_oper_revision			IN		NUMBER,
	p_oper_object_version 		IN		NUMBER
);

--  Start of Comments  --
--
--  Procedure name    	: Create_Oper_Revision
--  Type        	: Public
--  Function    	: API to create a new revision of a Operation.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER 		Required, default 1.0
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
--	p_oper_id 		IN	NUMBER		Required
--	p_oper_number		IN	VARCHAR2	Required
--	p_oper_revision		IN	NUMBER		Required
--	p_oper_object version	IN	NUMBER		Required
--	x_new_operation_id 	OUT	NUMBER		Required
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * Use this procedure to create a new revision of an existing and completed Operation.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_oper_id Operation unique identifier
 * @param p_oper_number Operation number
 * @param p_oper_revision Operation revision number
 * @param p_oper_object_version Operation object version number
 * @param x_new_oper_id Unique identifier of the new revision of the Operation
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Operation Revision
 */
PROCEDURE Create_Oper_Revision
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
	p_oper_id 			IN          	NUMBER,
	p_oper_number			IN		VARCHAR2,
	p_oper_revision			IN		NUMBER,
	p_oper_object_version		IN		NUMBER,
	x_new_oper_id         		OUT NOCOPY  	NUMBER
);

--  Start of Comments  --
--
--  Procedure name    	: Initiate_Oper_Approval
--  Type        	: Public
--  Function    	: API to submit a Operation to complete / terminate approval workflows.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER 		Required, default 1.0
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
--	p_oper_id 		IN	NUMBER		Required
--	p_oper_number		IN	VARCHAR2	Required
--	p_oper_revision		IN	NUMBER		Required
--	p_oper_object_version 	IN	NUMBER		Required
--	p_apprv_type		IN	VARCHAR2	Required, default 'COMPLETE'
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * Use this procedure to submit an Operation for Completion or Termination approval workflows.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_oper_id Operation unique identifier
 * @param p_oper_number Operation number
 * @param p_oper_revision Operation revision number
 * @param p_oper_object_version Operation object version number
 * @param p_apprv_type Approval type, one of 'COMPLETE' and 'TERMINATE', default is 'COMPLETE'
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Initiate Operation Approval
 */
PROCEDURE Initiate_Oper_Approval
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
	p_oper_id 			IN          	NUMBER,
	p_oper_number			IN		VARCHAR2,
	p_oper_revision			IN		NUMBER,
	p_oper_object_version		IN          	NUMBER,
	p_apprv_type		     	IN          	VARCHAR2	:='COMPLETE'
);

--  Start of Comments  --
--
--  Procedure name    	: Process_Oper_Alt_Resources
--  Type        	: Public
--  Function    	: API to process alternate resources for operations.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER 		Required, default 1.0
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
--	p_operation_number		IN	VARCHAR2,
--	p_operation_revision		IN	NUMBER,
--      p_operation_id			IN	NUMBER,
--      p_resource_id			IN	NUMBER,
--      p_resource_name 		IN	VARCHAR2,
---	p_x_alt_resource_tbl	IN OUT	AHL_RM_RT_OPER_RESOURCE_PVT.alt_resource_tbl_type	Required
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * Use this procedure to define Alternate Resources for an existing Operation-Resource Requirement.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_operation_number Operation number of the Operation to which the resource is associated
 * @param p_operation_revision Operation revision of the Operation to which the resource is associated
 * @param p_operation_id Operation id of the Operation to which the resource is associated
 * @param p_resource_id Resource Id of the resource to be associated
 * @param p_resource_name Resource Name of the resource to be associated
 * @param p_x_alt_resource_tbl Alternate resources table of type AHL_RM_RT_OPER_RESOURCE_PVT.alt_resource_tbl_type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Operation Alternate Resource
 */
PROCEDURE Process_Oper_Alt_Resources
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
	p_operation_number		IN	VARCHAR2,
	p_operation_revision		IN	NUMBER,
        p_operation_id			IN	NUMBER,
        p_resource_id			IN	NUMBER,
        p_resource_name 		IN	VARCHAR2,
	p_x_alt_resource_tbl 		IN OUT NOCOPY	AHL_RM_RT_OPER_RESOURCE_PVT.alt_resource_tbl_type
);

END AHL_RM_OPERATION_PUB;


 

/
