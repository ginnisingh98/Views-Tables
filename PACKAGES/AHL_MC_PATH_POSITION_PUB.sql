--------------------------------------------------------
--  DDL for Package AHL_MC_PATH_POSITION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_MC_PATH_POSITION_PUB" AUTHID CURRENT_USER AS
/* $Header: AHLPPOSS.pls 120.0 2008/02/20 23:28:13 jaramana noship $ */
/*#
 * Package containing public API to create Master Configuration Path Positions.
 * @rep:scope public
 * @rep:product AHL
 * @rep:displayname MC Path Positions
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY AHL_MASTER_CONFIG
 */

-------------------------------------------------------------------------------------------
-- Start of Comments
--  Procedure name    : Create_Position_ID
--  Type              : Public
--  Function          : Does user input validation and calls private API Create_Position_ID
--  Pre-reqs          :
--  Parameters        :
--
--  Create_Position_ID Parameters:
--       p_path_position_tbl  IN  AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type  Required
--
--  End of Comments

/*#
 * Procedure for creating an MC Path Position.
 * @param p_api_version API Version Number.
 * @param p_init_msg_list Initialize the message stack. Standard API parameter, default value FND_API.G_FALSE
 * @param p_commit Parameter to decide whether to commit the transaction or not. Standard API parameter, default value FND_API.G_FALSE
 * @param p_validation_level Validation level. Standard API parameter, default value FND_API.G_VALID_LEVEL_FULL
 * @param x_return_status API Return status. Standard API parameter.
 * @param x_msg_count API Return message count, if any. Standard API parameter.
 * @param x_msg_data API Return message data, if any. Standard API parameter.
 * @param p_path_position_tbl Path position table of type AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type
 * @param p_position_ref_meaning Position reference for the path. Used for copying positions.
 * @param p_position_ref_code Position reference for the path. Used for copying positions.
 * @param x_position_id Return Id of the new Path Position created.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Position Id
 */
PROCEDURE Create_Position_ID (
    p_api_version           IN           NUMBER,
    p_init_msg_list         IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit                IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level      IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_path_position_tbl     IN           AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type,
    p_position_ref_meaning  IN           VARCHAR2,
    p_position_ref_code     IN           VARCHAR2,
    x_position_id           OUT  NOCOPY  NUMBER,
    x_return_status         OUT  NOCOPY  VARCHAR2,
    x_msg_count             OUT  NOCOPY  NUMBER,
    x_msg_data              OUT  NOCOPY  VARCHAR2
);

End AHL_MC_PATH_POSITION_PUB;

/
