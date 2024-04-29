--------------------------------------------------------
--  DDL for Package AHL_MC_ITEM_COMP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MC_ITEM_COMP_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPICXS.pls 120.0 2005/05/26 01:02:22 appldev noship $ */
/*#
 * This is the public package that handles Creation,Modification,Termination and copying of
 * Item Composition,depending on the flag that is being passes to the package
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Master Configuration
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_MASTER_CONFIG
 */

/*#
 * It handles creation , updation, deletion and copying of Item Composition
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_FALSE
 * @param p_commit To decide whether to commit the transaction, default value FND_API.G_FALSE
 * @param p_validation_level Validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_module_type whether 'API'or 'JSP', default value NULL
 * @param x_return_status Return status,Standard API parameter
 * @param x_msg_count Return message count,Standard API parameter
 * @param x_msg_data Return message data, Standard API parameter
 * @param p_x_ic_header_rec Master Configuration record of type AHL_MC_ITEM_COMP_PVT.Header_Rec_Type
 * @param p_x_ic_det_tbl Master Configuration table  of type AHL_MC_ITEM_COMP_PVT.Det_Tbl_Type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Item Composition
 */
 PROCEDURE Process_Item_Composition(
	p_api_version         IN NUMBER,
	p_init_msg_list       IN VARCHAR2  := FND_API.G_FALSE,
	p_commit              IN VARCHAR2  := FND_API.G_FALSE,
	p_validation_level    IN NUMBER    := FND_API.G_VALID_LEVEL_FULL,
	p_module_type         IN VARCHAR2  := NULL,
	x_return_status       OUT NOCOPY        VARCHAR2,
	x_msg_count           OUT NOCOPY        NUMBER,
	x_msg_data            OUT NOCOPY        VARCHAR2,
	p_x_ic_header_rec     IN OUT NOCOPY AHL_MC_ITEM_COMP_PVT.Header_Rec_Type,
	p_x_ic_det_tbl        IN OUT NOCOPY AHL_MC_ITEM_COMP_PVT.Det_Tbl_Type
);


End AHL_MC_ITEM_COMP_PUB;

 

/
