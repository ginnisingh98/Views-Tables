--------------------------------------------------------
--  DDL for Package INV_KANBAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_KANBAN_PUB" AUTHID CURRENT_USER as
/* $Header: INVPKBNS.pls 120.1 2005/06/14 06:02:33 appldev  $ */
/*#
 * This package provides routines for performing replenishment through
 * Kanban cards
 * @rep:scope public
 * @rep:product INV
 * @rep:lifecycle active
 * @rep:displayname Kanban Replenishment
 * @rep:category BUSINESS_ENTITY INV_REPLENISHMENT
 */
--  API name    Update_Card_Supply_Status
--  Type        Public
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
-- Name
--    PROCEDURE Update_Card_Supply_Status
--
-- Purpose
--    This procedure updates the supply status of the kanban card.
-- Input parameters
--  p_api_version      IN  NUMBER (required)
--                API Version of this procedure
--  p_init_msg_level   IN  VARCHAR2 (optional)
--                     DEFAULT = FND_API.G_FALSE,
--  p_commit           IN  VARCHAR2 (optional)
--                     DEFAULT = FND_API.G_FALSE,
--  p_kanban_card_id   In VARCHAR2 (required)
--                     kanban card id to be updated
--  p_supply_status    IN varchar2 (required)
--                       INV_KANBAN_PVT.G_Supply_Status_New
--                       INV_KANBAN_PVT.G_Supply_Status_Full
--                       INV_KANBAN_PVT.G_Supply_Status_Empty
--                       INV_KANBAN_PVT.G_Supply_Status_InProcess
--                       INV_KANBAN_PVT.G_Supply_Status_InTransit
--
-- Output Parameters
--    x_msg_count - number of error messages in the buffer
--    x_msg_data  - error messages
--    x_return_status - fnd_api.g_ret_sts_error, fnd_api.g_ret_sts_success,
--                      fnd_api.g_ret_unexp_error
--
/*#
 * This procedure updates the supply status of the kanban card to the given
 * status, triggering
 * a replenishment if the status is being changed to Empty.
 * @param p_api_version_number API Version of this procedure. Current version is 1.0
 * @param p_init_msg_list Indicates whether message stack is to be initialized
 * @param p_commit Indicates whether a commit has to performed within the procedure on successful processing
 * @param p_kanban_card_id Kanban Card Identifier to be processed
 * @param p_supply_status Indicates the supply status to which kanban card is to be updated to.
 * @param x_msg_data return variable holding the error message
 * @param x_msg_count return variable holding the number of error messages returned
 * @param x_return_status return variable holding the status of the procedure call
 * @rep:displayname Update Kanban Card Supply Status
*/
Procedure Update_Card_Supply_Status
(p_api_version_number            IN  NUMBER,
 p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE,
 p_commit                        IN  VARCHAR2 := FND_API.G_FALSE,
 x_msg_count                     OUT NOCOPY NUMBER,
 x_msg_data                      OUT NOCOPY VARCHAR2,
 X_Return_Status                 OUT NOCOPY Varchar2,
 p_Kanban_Card_Id                    Number,
 p_Supply_Status                     Number);

END INV_Kanban_PUB;

 

/
