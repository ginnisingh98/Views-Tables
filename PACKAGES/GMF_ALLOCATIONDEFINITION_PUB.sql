--------------------------------------------------------
--  DDL for Package GMF_ALLOCATIONDEFINITION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_ALLOCATIONDEFINITION_PUB" AUTHID CURRENT_USER AS
/* $Header: GMFPALCS.pls 120.2 2006/02/03 00:58:32 pmarada noship $ */
/*#
 * This is the public interface for OPM Allocation Definitions API
 * This API can be used to create, update and delete
 * allocation definitions
 * @rep:scope public
 * @rep:product GMF
 * @rep:displayname GMF Allocation Definitions API
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY GMF_ALLOCATION_DEFINITION
*/

-- Definition of all the entities
TYPE Allocation_Definition_Rec_Type IS RECORD
(
        alloc_id                NUMBER                                          ,
        alloc_code              gl_aloc_mst.alloc_code%TYPE                     ,
        legal_entity_id gmf_legal_entities.legal_entity_id%TYPE                 ,
        alloc_method            NUMBER                                          ,
        line_no                 NUMBER                                          ,
        item_id                 NUMBER                                          ,
        item_number             mtl_item_flexfields.item_number%TYPE                    ,
   basis_account_id  gl_aloc_bas.basis_account_id%TYPE,
        basis_account_key       gl_aloc_bas.basis_account_key%TYPE              ,
        balance_type            NUMBER                                          ,
        bas_ytd_ptd             NUMBER                                          ,
   basis_type     NUMBER,
        fixed_percent           NUMBER                                          ,
        cmpntcls_id             NUMBER                                          ,
        cost_cmpntcls_code      cm_cmpt_mst.cost_cmpntcls_code%TYPE             ,
        analysis_code           cm_alys_mst.cost_analysis_code%TYPE             ,
        organization_id         gl_aloc_bas.organization_id%TYPE                        ,
   organization_code   mtl_parameters.organization_code%TYPE,
        delete_mark             gl_aloc_bas.delete_mark%TYPE            := 0    ,
        user_name               fnd_user.user_name%TYPE
);

/*#
 * Allocation Definitions Creation API
 * This API Creates a new Allocation Definitions in Allocation Basis Table
 * @param p_api_version Version Number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param p_commit Flag for commiting the data or not
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @param p_allocation_definition_rec Allocation definitions record type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Allocation Definitions API
*/
PROCEDURE Create_Allocation_Definition
(
        p_api_version                   IN  NUMBER                              ,
        p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE         ,
        p_commit                        IN  VARCHAR2 := FND_API.G_FALSE         ,

        x_return_status                 OUT NOCOPY VARCHAR2                     ,
        x_msg_count                     OUT NOCOPY NUMBER                       ,
        x_msg_data                      OUT NOCOPY VARCHAR2                     ,

        p_allocation_definition_rec     IN  Allocation_Definition_Rec_Type
);

/*#
 * Allocation Definitions Updation API
 * This API Updates a Allocation Definitions in Allocation Basis Table
 * @param p_api_version Version Number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param p_commit Flag for commiting the data or not
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @param p_allocation_definition_rec Allocation definitions record type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Allocation Definitions API
*/
PROCEDURE Update_Allocation_Definition
(
        p_api_version                   IN  NUMBER                              ,
        p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE         ,
        p_commit                        IN  VARCHAR2 := FND_API.G_FALSE         ,

        x_return_status                 OUT NOCOPY VARCHAR2                     ,
        x_msg_count                     OUT NOCOPY NUMBER                       ,
        x_msg_data                      OUT NOCOPY VARCHAR2                     ,

        p_allocation_definition_rec     IN Allocation_Definition_Rec_Type
);

/*#
 * Allocation Definitions Deletion API
 * This API Deletes a new Allocation Definitions from Allocation Basis Table
 * @param p_api_version Version Number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param p_commit Flag for commiting the data or not
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @param p_allocation_definition_rec Allocation definitions record type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Allocation Definitions API
*/
PROCEDURE Delete_Allocation_Definition
(
        p_api_version                   IN  NUMBER                              ,
        p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE         ,
        p_commit                        IN  VARCHAR2 := FND_API.G_FALSE         ,

        x_return_status                 OUT NOCOPY VARCHAR2                     ,
        x_msg_count                     OUT NOCOPY NUMBER                       ,
        x_msg_data                      OUT NOCOPY VARCHAR2                     ,

        p_allocation_definition_rec     IN Allocation_Definition_Rec_Type
);

END GMF_ALLOCATIONDEFINITION_PUB;


 

/
