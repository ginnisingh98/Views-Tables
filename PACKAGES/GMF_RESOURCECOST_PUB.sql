--------------------------------------------------------
--  DDL for Package GMF_RESOURCECOST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_RESOURCECOST_PUB" AUTHID CURRENT_USER AS
/* $Header: GMFPRESS.pls 120.1.12000000.1 2007/01/17 16:52:55 appldev ship $ */
/*#
 * This is the public interface for OPM Resource Cost API.
 * This API can be used for creation, updation, deletion and
 * retrieval of resource costs from the resource cost details table.
 * @rep:scope public
 * @rep:product GMF
 * @rep:displayname GMF Resource Cost API
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY GMF_RESOURCE_COST
*/

-- Definition of all the entities
TYPE Resource_Cost_Rec_Type IS RECORD
(       resources         cm_rsrc_dtl.resources%TYPE,
        legal_entity_id   cm_rsrc_dtl.legal_entity_id%TYPE ,
        organization_id   cm_rsrc_dtl.organization_id%TYPE ,
        organization_code mtl_parameters.organization_code%TYPE ,
        period_id         cm_rsrc_dtl.period_id%TYPE ,
        calendar_code     cm_rsrc_dtl.calendar_code%TYPE ,
        period_code       cm_rsrc_dtl.period_code%TYPE ,
        cost_type_id      cm_rsrc_dtl.cost_type_id%TYPE ,
        cost_mthd_code    cm_rsrc_dtl.cost_mthd_code%TYPE,
        usage_uom         cm_rsrc_dtl.usage_uom%TYPE,
        nominal_cost      cm_rsrc_dtl.nominal_cost%TYPE,
        delete_mark       cm_rsrc_dtl.delete_mark%TYPE := 0,
        user_name         fnd_user.user_name%TYPE
);

/*#
 * Resource Cost Creation API
 * This API Creates a new Resource Cost in the Resource Cost Details table
 * @param p_api_version Version Number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param p_commit Flag for commiting the data or not
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @param p_resource_cost_rec Resource cost record type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Resource Cost API
*/
PROCEDURE Create_Resource_Cost
(       p_api_version           IN  NUMBER                              ,
        p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE         ,
        p_commit                IN  VARCHAR2 := FND_API.G_FALSE         ,

        x_return_status         OUT NOCOPY VARCHAR2                     ,
        x_msg_count             OUT NOCOPY NUMBER                       ,
        x_msg_data              OUT NOCOPY VARCHAR2                     ,

        p_resource_cost_rec     IN Resource_Cost_Rec_Type
);

/*#
 * Resource Cost Updation API
 * This API Updates a Resource Cost in the Resource Cost Details table
 * @param p_api_version Version Number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param p_commit Flag for commiting the data or not
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @param p_resource_cost_rec Resource cost record type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Resource Cost API
*/
PROCEDURE Update_Resource_Cost
(       p_api_version           IN  NUMBER                              ,
        p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE         ,
        p_commit                IN  VARCHAR2 := FND_API.G_FALSE         ,

        x_return_status         OUT NOCOPY VARCHAR2                     ,
        x_msg_count             OUT NOCOPY NUMBER                       ,
        x_msg_data              OUT NOCOPY VARCHAR2                     ,

        p_resource_cost_rec     IN Resource_Cost_Rec_Type
);

/*#
 * Resource Cost Deletion API
 * This API Deletes a Resource Cost from the Resource Cost Details table
 * @param p_api_version Version Number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param p_commit Flag for commiting the data or not
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @param p_resource_cost_rec Resource cost record type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Resource Cost API
*/
PROCEDURE Delete_Resource_Cost
(       p_api_version           IN  NUMBER                              ,
        p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE         ,
        p_commit                IN  VARCHAR2 := FND_API.G_FALSE         ,

        x_return_status         OUT NOCOPY VARCHAR2                     ,
        x_msg_count             OUT NOCOPY NUMBER                       ,
        x_msg_data              OUT NOCOPY VARCHAR2                     ,

        p_resource_cost_rec     IN Resource_Cost_Rec_Type
);

/*#
 * Resource Cost Retrieval API
 * This API Retrieves a Resource Cost from the Resource Cost Details table
 * @param p_api_version Version Number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @param p_resource_cost_rec Resource cost record type
 * @param x_resource_cost_rec Resource cost record type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Retrieve Resource Cost API
*/
PROCEDURE Get_Resource_Cost
(       p_api_version           IN  NUMBER                              ,
        p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE         ,

        x_return_status         OUT NOCOPY VARCHAR2                     ,
        x_msg_count             OUT NOCOPY NUMBER                       ,
        x_msg_data              OUT NOCOPY VARCHAR2                     ,

        p_resource_cost_rec     IN  Resource_Cost_Rec_Type              ,
        x_resource_cost_rec     OUT NOCOPY Resource_Cost_Rec_Type
);

END GMF_ResourceCost_PUB;


 

/
