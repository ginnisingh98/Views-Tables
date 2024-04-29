--------------------------------------------------------
--  DDL for Package AHL_RM_ROUTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_RM_ROUTE_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPROUS.pls 120.0.12000000.2 2007/10/18 13:36:57 adivenka ship $ */
/*#
 * Package containing APIs to create, update and delete Routes and its associated document references, operations, resources
 * requirements, resource costing parameters, alternate resources, disposition effectivities,access panels and materials. It
 * allows users to submit Routes for completion or termination approval flows and to create Route revisions.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Route
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_MAINT_ROUTE
 */

G_PKG_NAME 	CONSTANT 	VARCHAR2(30) 	:= 'AHL_RM_ROUTE_PUB';

-----------------------
-- Define procedures --
-----------------------
--  Start of Comments  --
--
--  Procedure name    	: Create_Route
--  Type        	: Public
--  Function    	: API to create Route and its associations to documents, operations, resources,
--			  resource costing, materials,access panels and disposition effectivities.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER
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
--	p_x_route_rec        	IN OUT  AHL_RM_ROUTE_PVT.route_rec_type			Required
--	p_x_route_doc_tbl  	IN OUT  AHL_RM_ASSO_DOCASO_PVT.doc_association_tbl
--	p_x_route_operation_tbl	IN OUT  AHL_RM_OP_ROUTE_AS_PVT.route_operation_tbl_type
--	p_x_route_resource_tbl	IN OUT  AHL_RM_RT_OPER_RESOURCE_PVT.rt_oper_resource_tbl_type
--	p_x_route_material_tbl 	IN OUT  AHL_RM_MATERIAL_AS_PVT.material_req_tbl_type
--	p_x_route_panel_tbl	IN OUT  AHL_RM_RT_OPER_PANEL_PVT.rt_oper_panel_tbl_type
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * Use this procedure to Create a Route and optionally, create associated document references, operations, resource requirements, resource costing parameters and material requirements.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_x_route_rec Route record of type AHL_RM_ROUTE_PVT.route_rec_type
 * @param p_x_route_doc_tbl Route associated documents table of type AHL_RM_ASSO_DOCASO_PVT.doc_association_tbl that need to be associated to the Route
 * @param p_x_route_operation_tbl Route associated operations table of type AHL_RM_OP_ROUTE_AS_PVT.route_operation_tbl_type that need to be associated to the Route
 * @param p_x_route_resource_tbl Route associated resources table of type AHL_RM_RT_OPER_RESOURCE_PVT.rt_oper_resource_tbl_type that need to be associated to the Route
 * @param p_x_route_material_tbl Route assocaited materials table of type AHL_RM_MATERIAL_AS_PVT.material_req_tbl_type that need to be associated to the Route
 * @param p_x_route_panel_tbl Route associated access panels table of type AHL_RM_RT_OPER_PANEL_PVT.rt_oper_panel_tbl_type that need to be associated to the Route
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Route
 */
PROCEDURE Create_Route
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
	p_x_route_rec        		IN OUT NOCOPY 	AHL_RM_ROUTE_PVT.route_rec_type,
	p_x_route_doc_tbl  		IN OUT NOCOPY  	AHL_RM_ASSO_DOCASO_PVT.doc_association_tbl,
	p_x_route_operation_tbl 	IN OUT NOCOPY  	AHL_RM_OP_ROUTE_AS_PVT.route_operation_tbl_type,
	p_x_route_resource_tbl		IN OUT NOCOPY 	AHL_RM_RT_OPER_RESOURCE_PVT.rt_oper_resource_tbl_type,
	p_x_route_material_tbl 		IN OUT NOCOPY 	AHL_RM_MATERIAL_AS_PVT.material_req_tbl_type,
	p_x_route_panel_tbl		IN OUT NOCOPY	AHL_RM_RT_OPER_PANEL_PVT.rt_oper_panel_tbl_type
);

--  Start of Comments  --
--
--  Procedure name    	: Modify_Route
--  Type        	: Public
--  Function    	: API to modify Route details and its associations to documents, operations, resources,
--			  resource costing, materials and disposition effectivities.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER
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
--	p_x_route_rec        	IN OUT  AHL_RM_ROUTE_PVT.route_rec_type			Required
--	p_x_route_doc_tbl  	IN OUT  AHL_RM_ASSO_DOCASO_PVT.doc_association_tbl
--	p_x_route_operation_tbl	IN OUT  AHL_RM_OP_ROUTE_AS_PVT.route_operation_tbl_type
--	p_x_route_resource_tbl	IN OUT  AHL_RM_RT_OPER_RESOURCE_PVT.rt_oper_resource_tbl_type
--	p_x_route_material_tbl 	IN OUT  AHL_RM_MATERIAL_AS_PVT.material_req_tbl_type
--	p_x_route_panel_tbl	IN OUT  AHL_RM_RT_OPER_PANEL_PVT.rt_oper_panel_tbl_type
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * Use this procedure to modify a Route and optionally, create, modify and delete associated document references, operations, resource requirements, resource costing parameters, access panels and material requirements.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_route_rec Route record of type AHL_RM_ROUTE_PVT.route_rec_type
 * @param p_x_route_doc_tbl Route associated documents table of type AHL_RM_ASSO_DOCASO_PVT.doc_association_tbl that need to be associated to the Route
 * @param p_x_route_operation_tbl Route associated operations table of type AHL_RM_OP_ROUTE_AS_PVT.route_operation_tbl_type that need to be associated to the Route
 * @param p_x_route_resource_tbl Route associated resources table of type AHL_RM_RT_OPER_RESOURCE_PVT.rt_oper_resource_tbl_type that need to be associated to the Route
 * @param p_x_route_material_tbl Route associated materials table of type AHL_RM_MATERIAL_AS_PVT.material_req_tbl_type that need to be associated to the Route
 * @param p_x_route_panel_tbl Route associated access panels table of type AHL_RM_RT_OPER_PANEL_PVT.rt_oper_panel_tbl_type that need to be associated to the Route
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Modify Route
 */
PROCEDURE Modify_Route
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
	p_route_rec        		IN		AHL_RM_ROUTE_PVT.route_rec_type,
	p_x_route_doc_tbl  		IN OUT NOCOPY  	AHL_RM_ASSO_DOCASO_PVT.doc_association_tbl,
	p_x_route_operation_tbl 	IN OUT NOCOPY  	AHL_RM_OP_ROUTE_AS_PVT.route_operation_tbl_type,
	p_x_route_resource_tbl		IN OUT NOCOPY 	AHL_RM_RT_OPER_RESOURCE_PVT.rt_oper_resource_tbl_type,
	p_x_route_material_tbl 		IN OUT NOCOPY 	AHL_RM_MATERIAL_AS_PVT.material_req_tbl_type,
	p_x_route_panel_tbl		IN OUT NOCOPY	AHL_RM_RT_OPER_PANEL_PVT.rt_oper_panel_tbl_type
);

--  Start of Comments  --
--
--  Procedure name    	: Delete_Route
--  Type        	: Public
--  Function    	: API to deletion of routes. All associations to documents, operations, resources,
--			  resource costing, materials,access panels and disposition effectivities are also deleted.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER
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
--	p_route_id 		IN	NUMBER		Required
--	p_route_number		IN	VARCHAR2	Required
--	p_route_revision	IN	NUMBER		Required
--	p_route_object_version  IN      NUMBER		Required
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * Use this procedure to delete a Route. All associations to documents, operations, resource requirements, resource costing parameters and material requirements will be deleted.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_route_id Route unique identifier
 * @param p_route_number Route number
 * @param p_route_revision Route revision number
 * @param p_route_object_version Route object version number
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Route
 */
PROCEDURE Delete_Route
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
	p_route_id			IN		VARCHAR2,
	p_route_number			IN		VARCHAR2,
	p_route_revision		IN		NUMBER,
	p_route_object_version 		IN		NUMBER
);

--  Start of Comments  --
--
--  Procedure name    	: Create_Route_Revision
--  Type        	: Public
--  Function    	: API to create a new revision of a Route.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER
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
--	p_route_id 		IN	NUMBER		Required
--	p_route_number		IN	VARCHAR2	Required
--	p_route_version_number	IN	NUMBER		Required
--	p_route_object version	IN	NUMBER		Required
--	x_new_route_id 		OUT	NUMBER		Required
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * Use this procedure to create a new revision of a existing and completed Route.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_route_id Route unique identifier
 * @param p_route_number Route Number
 * @param p_route_revision Route revision number
 * @param p_route_object_version Route object version number
 * @param x_new_route_id Unique identifier of the new revision of the Route
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Route Revision
 */
PROCEDURE Create_Route_Revision
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
	p_route_id 			IN          	NUMBER,
	p_route_number			IN		VARCHAR2,
	p_route_revision		IN		NUMBER,
	p_route_object_version		IN		NUMBER,
	x_new_route_id         		OUT NOCOPY  	NUMBER
);

--  Start of Comments  --
--
--  Procedure name    	: Initiate_Route_Approval
--  Type        	: Public
--  Function    	: API to submit a Route to complete / terminate approval workflows.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER
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
--	p_route_id 		IN	NUMBER		Required
--	p_route_number		IN	VARCHAR2	Required
--	p_route_revision	IN	NUMBER		Required
--	p_route_object_version 	IN	NUMBER		Required
--	p_apprv_type		IN	VARCHAR2	Required, default 'COMPLETE'
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * Use this procedure to submit a Route for Completion or Termination approval workflows.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_route_id Route unique identifier
 * @param p_route_number Route number
 * @param p_route_revision Route revision number
 * @param p_route_object_version Route object version number
 * @param p_apprv_type Approval type, one of 'COMPLETE' and 'TERMINATE', default is 'COMPLETE'
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Initiate Route Approval
 */
PROCEDURE Initiate_Route_Approval
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
	p_route_id 			IN          	NUMBER,
	p_route_number			IN		VARCHAR2,
	p_route_revision		IN		NUMBER,
	p_route_object_version	     	IN          	NUMBER,
	p_apprv_type		     	IN          	VARCHAR2	:='COMPLETE'
);

--  Start of Comments  --
--
--  Procedure name    	: Process_Route_Dispositions
--  Type        	: Public
--  Function    	: API to process disposition details for routes.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER
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
--      p_route_id                      IN  NUMBER,
-- 	p_route_number			IN		VARCHAR2,
-- 	p_route_revision		IN		NUMBER,
--      p_x_route_efct_rec   	IN OUT 	AHL_RM_MATERIAL_AS_PVT.route_efct_rec_type 	Required
--	p_x_route_efct_mat_tbl	IN OUT	AHL_RM_MATERIAL_AS_PVT.material_req_tbl_type	Required
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * Use this procedure to create, update and delete disposition effectivities and material requirements for a Route.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_route_id Route ID of the Route to which the Disposition is added.
 * @param p_route_number Route Number of the Route to which the Disposition is added.
 * @param p_route_revision Route Revision of the Route to which the Disposition is added.
 * @param p_x_route_efct_rec Disposition effectivities record of type AHL_RM_MATERIAL_AS_PVT.route_efct_rec_type
 * @param p_x_route_efct_mat_tbl Disposition details table of type AHL_RM_MATERIAL_AS_PVT.material_req_tbl_type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Route Disposition
 */
PROCEDURE Process_Route_Dispositions
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
	p_route_id                      IN  NUMBER,
 	p_route_number			IN		VARCHAR2,
 	p_route_revision		IN		NUMBER,
	p_x_route_efct_rec   		IN OUT NOCOPY 	AHL_RM_MATERIAL_AS_PVT.route_efct_rec_type,
	p_x_route_efct_mat_tbl 		IN OUT NOCOPY	AHL_RM_MATERIAL_AS_PVT.material_req_tbl_type
);

--  Start of Comments  --
--
--  Procedure name    	: Process_Route_Alt_Resources
--  Type        	: Public
--  Function    	: API to process alternate resources for routes.
--  Pre-reqs    	:
--
--  Standard IN  Parameters :
--      p_api_version		IN	NUMBER
--	p_init_msg_list		IN	VARCHAR2	Required, default FND_API.G_TRUE
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
--	p_route_number	                IN	VARCHAR2,
--	p_route_revision		IN	NUMBER,
--      p_route_id			IN	NUMBER,
--      p_resource_id			IN	NUMBER,
--      p_resource_name 		IN	VARCHAR2,
--	p_x_alt_resource_tbl	IN OUT	AHL_RM_RT_OPER_RESOURCE_PVT.alt_resource_tbl_type	Required
--
--  Version :
--  	Initial Version   	1.0
--
--  End of Comments  --
/*#
 * Use this procedure to define Alternate Resources for an existing Route-Resource Requirement.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack, Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not, Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_default Parameter to decide whether to default attributes or not, valid values are FND_API.G_TRUE or FND_API.G_FALSE, default value NULL
 * @param p_module_type For Internal use only, should always be NULL, default value NULL
 * @param x_return_status API Return status. Standard API parameter
 * @param x_msg_count API Return message count, if any. Standard API parameter
 * @param x_msg_data API Return message data, if any. Standard API parameter
 * @param p_route_number Route number of the Route to which the resource is associated
 * @param p_route_revision Route revision of the Route to which the resource is associated
 * @param p_route_id Route id of the Route to which the resource is associated
 * @param p_resource_id Resource Id of the resource to be associated
 * @param p_resource_name Resource Name of the resource to be associated
 * @param p_x_alt_resource_tbl Alternate resources table of type AHL_RM_RT_OPER_RESOURCE_PVT.alt_resource_tbl_type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Route Alternate Resource
 */
PROCEDURE Process_Route_Alt_Resources
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
	p_route_number	                IN	VARCHAR2,
	p_route_revision		IN	NUMBER,
        p_route_id			IN	NUMBER,
        p_resource_id			IN	NUMBER,
        p_resource_name 		IN	VARCHAR2,
	p_x_alt_resource_tbl 		IN OUT NOCOPY	AHL_RM_RT_OPER_RESOURCE_PVT.alt_resource_tbl_type
);

END AHL_RM_ROUTE_PUB;


 

/
