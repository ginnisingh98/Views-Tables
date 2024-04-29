--------------------------------------------------------
--  DDL for Package AHL_OSP_ORDERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_OSP_ORDERS_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPOSPS.pls 120.1 2005/09/13 22:09:50 jaramana noship $ */
/*#
 * This package provides the procedure to Validate, Insert/Update/Delete an osp order header along with its associated lines.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname Process OSP Order
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_OSP_ORDER
 */
------------------------
-- Declare Procedures --
------------------------

-- Start of Comments --
--  Procedure name    : process_osp_order
--  Type              : Public
--  Function          : For a given set of osp order header and lines, will validate and insert/update/delete
--                      the osp order information.
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
--  process_osp_order Parameters:
--
--       p_x_osp_order_rec         IN OUT  AHL_OSP_ORDERS_PVT.osp_order_rec_type    Required
--         OSP Order Header record
--       p_x_osp_order_lines_tbl        IN OUT  AHL_OSP_ORDERS_PVT.osp_order_lines_tbl_type   Required
--         OSP Order Lines
--
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.
/*#
 * This procedure is used to validate and insert/update/delete an osp order.
 * @param p_api_version API Version Number
 * @param p_init_msg_list Initialize the message stack, default value FND_API.G_TRUE
 * @param p_commit to decide whether to commit the transaction or not, default value FND_API.G_FALSE
 * @param p_validation_level validation level, default value FND_API.G_VALID_LEVEL_FULL
 * @param p_module_type Module type of the caller
 * @param p_x_osp_order_rec OSP Header Record
 * @param p_x_osp_order_lines_tbl Table of OSP Order line Records.
 * @param p_org_id Optional Org Id Parameter for R12 MOAC Compliance.
 * @param x_return_status return status
 * @param x_msg_count return message count
 * @param x_msg_data return message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process OSP Order
 */
PROCEDURE process_osp_order(
    p_api_version           IN              NUMBER    := 1.0,
    p_init_msg_list         IN              VARCHAR2  := FND_API.G_TRUE,
    p_commit                IN              VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN              NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_module_type           IN              VARCHAR2  := NULL,
    p_x_osp_order_rec       IN OUT  NOCOPY  AHL_OSP_ORDERS_PVT.osp_order_rec_type,
    p_x_osp_order_lines_tbl IN OUT  NOCOPY  AHL_OSP_ORDERS_PVT.osp_order_lines_tbl_type,
    p_org_id                IN              NUMBER    := null,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2);


END AHL_OSP_ORDERS_PUB; -- Package spec
----------------------------------------------

 

/
