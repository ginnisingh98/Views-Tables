--------------------------------------------------------
--  DDL for Package AHL_UMP_UF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UMP_UF_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPUMFS.pls 120.0 2005/05/25 23:57:58 appldev noship $ */
/*#
 * This is the public interface to process utilization forecast for Product Classification node, item, unit or item instance.  It allows
 * creation, modification or deletion of utilization forecast.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Utilization Forecast
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_PROD_CLASS
 */
------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : process_utilization_forecast
--  Type              : Public
--  Function          : For a given set of utilization forecast header and details, will validate and insert/update
--                      the utilization forecast information.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Default  1.0
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  p_module_type                       IN      VARCHAR2               Required.
--
--      This parameter indicates the front-end form interface. The default value is 'JSP'. If the value
--      is JSP, then this API clears out all id columns and validations are done using the values based
--      on which the Id's are populated.
--
--  process_utilization_forecast Parameters:
--
--       p_x_uf_header_rec         IN OUT  AHL_UMP_UF_PVT.uf_header_rec_type    Required
--         Utilization Forecast Header Details
--       p_x_uf_detail_tbl        IN OUT  AHL_UMP_UF_PVT.uf_detail_tbl_type   Required
--         Utilization Forecast details
--
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.
/*#
 * Process Utilization Forecast for CMRO product classification nodes and associated units and items. Allows definition and updates
 * for utilization forecast for install base item instances and inventory items for other applications like Prevetive Maintenance
 * @param p_api_version Api Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_module_type whether 'API'or 'JSP', default value NULL
 * @param p_x_uf_header_rec Utilization Forecast Header Record of type AHL_UMP_UF_PVT.uf_header_rec_type
 * @param p_x_uf_details_tbl Utilization Forecast Details Table of type AHL_UMP_UF_PVT.uf_details_tbl_type
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Utilization Forecast
 */
PROCEDURE process_utilization_forecast(
    p_api_version           IN             NUMBER    := 1.0,
    p_init_msg_list         IN             VARCHAR2  := FND_API.G_TRUE,
    p_commit                IN             VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN             NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN             VARCHAR2  := NULL,
    p_x_uf_header_rec       IN OUT NOCOPY  AHL_UMP_UF_PVT.uf_header_rec_type,
    p_x_uf_details_tbl      IN OUT NOCOPY  AHL_UMP_UF_PVT.uf_details_tbl_type,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2);

END AHL_UMP_UF_PUB;

 

/
