--------------------------------------------------------
--  DDL for Package JTF_BRMPROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_BRMPROCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvbprs.pls 120.3 2005/07/05 07:44:39 abraina ship $ */
/*#
 * Private APIs for the Business Rule module.
 * @rep:scope private
 * @rep:product JTA
 * @rep:displayname JTF BRM Process Private API
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY JTA_BUSINESS_RULE
 */

TYPE BRM_Process_rec_type IS RECORD
( PROCESS_ID              NUMBER
, RULE_ID                 NUMBER
, CREATED_BY              NUMBER(15)
, CREATION_DATE           DATE
, LAST_UPDATED_BY         NUMBER(15)
, LAST_UPDATE_DATE        DATE
, LAST_UPDATE_LOGIN       NUMBER(15)
, SEEDED_FLAG             VARCHAR2(1)
, LAST_BRM_CHECK_DATE     DATE
, BRM_UOM_TYPE            VARCHAR2(30)
, BRM_CHECK_UOM_CODE      VARCHAR2(30)
, BRM_CHECK_INTERVAL      NUMBER(9)
, BRM_TOLERANCE_UOM_CODE  VARCHAR2(30)
, BRM_TOLERANCE_INTERVAL  NUMBER(9)
, WORKFLOW_ITEM_TYPE      VARCHAR2(8)
, WORKFLOW_PROCESS_NAME   VARCHAR2(30)
, START_DATE_ACTIVE       DATE
, END_DATE_ACTIVE         DATE
, ATTRIBUTE1              VARCHAR2(150)
, ATTRIBUTE2              VARCHAR2(150)
, ATTRIBUTE3              VARCHAR2(150)
, ATTRIBUTE4              VARCHAR2(150)
, ATTRIBUTE5              VARCHAR2(150)
, ATTRIBUTE6              VARCHAR2(150)
, ATTRIBUTE7              VARCHAR2(150)
, ATTRIBUTE8              VARCHAR2(150)
, ATTRIBUTE9              VARCHAR2(150)
, ATTRIBUTE10             VARCHAR2(150)
, ATTRIBUTE11             VARCHAR2(150)
, ATTRIBUTE12             VARCHAR2(150)
, ATTRIBUTE13             VARCHAR2(150)
, ATTRIBUTE14             VARCHAR2(150)
, ATTRIBUTE15             VARCHAR2(150)
, ATTRIBUTE_CATEGORY      VARCHAR2(30)
, SECURITY_GROUP_ID       NUMBER
, OBJECT_VERSION_NUMBER   NUMBER
, APPLICATION_ID          NUMBER
);

--------------------------------------------------------------------------
-- Start of comments
--  API name    : Create_BRMProcess
--  Type        : Private
--  Function    : Create record in JTF_BRM_PROCESSES table.
--  Pre-reqs    : None.
--  Parameters  :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      p_api_version        IN         NUMBER   required
--      p_init_msg_list      IN         VARCHAR2 optional
--      p_commit             IN         VARCHAR2 optional
--      p_validation_level   IN         NUMBER   optional
--      x_return_status         OUT     VARCHAR2 required
--      x_msg_count             OUT     NUMBER   required
--      x_msg_data              OUT     VARCHAR2 required
--      p_BRMProcess_rec     IN         brm_process_rec_type   required
--      x_record_id             OUT     NUMBER  required
--
--  Version : Current  version 1.1
--            Previous version 1.0
--            Initial  version 1.0
--
-- End of comments
--------------------------------------------------------------------------
/*#
 * Create record in JTF_BRM_PROCESSES table.
 * @param p_api_version API Version Required
 * @param p_init_msg_list Initialize message list flag, Optional Default = FND_API.G_FALSE
 * @param p_commit Optional Default = FND_API.G_FALSE
 * @param p_validation_level Optional DEFAULT fnd_api.g_valid_level_full
 * @param x_return_status Required Length  = 1
 * @param x_msg_count API Error message count, Required
 * @param x_msg_data API Error message data, Required Length  = 2000
 * @param p_bpr_rec Required take input record type object "BRM_Process_rec_type"
 * @param x_record_id Required
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create BRM Process
 */
PROCEDURE Create_BRMProcess
( p_api_version      IN     NUMBER
, p_init_msg_list    IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit           IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
, p_bpr_rec          IN     BRM_Process_rec_type
, x_record_id           OUT NOCOPY NUMBER
);

--------------------------------------------------------------------------
-- Start of comments
--  API name   : Update_BRMParameter
--  Type       : Private
--  Function   : Update record in JTF_BRM_PROCESSES table.
--  Pre-reqs   : None.
--  Parameters :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      p_api_version        IN         NUMBER   required
--      p_init_msg_list      IN         VARCHAR2 optional
--      p_commit             IN         VARCHAR2 optional
--      p_validation_level   IN         NUMBER   optional
--      x_return_status         OUT     VARCHAR2 required
--      x_msg_count             OUT     NUMBER   required
--      x_msg_data              OUT     VARCHAR2 required
--      p_BRMProcess_rec     IN         brm_Process_rec_type   required
--
--  Version : Current  version 1.1
--            Previous version 1.0
--            Initial  Version 1.0
--
--  Notes:
--
-- End of comments
--------------------------------------------------------------------------
/*#
 * Update record in JTF_BRM_PROCESSES table.
 * @param p_api_version API Version Required
 * @param p_init_msg_list Initialize message list flag, Optional Default = FND_API.G_FALSE
 * @param p_commit Optional Default = FND_API.G_FALSE
 * @param p_validation_level Optional DEFAULT fnd_api.g_valid_level_full
 * @param x_return_status Required Length  = 1
 * @param x_msg_count API Error message count, Required
 * @param x_msg_data API Error message data, Required Length  = 2000
 * @param p_bpr_rec Required take input record type object "BRM_Process_rec_type"
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update BRM Process
 */
PROCEDURE Update_BRMProcess
( p_api_version      IN     NUMBER
, p_init_msg_list    IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit           IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
, p_bpr_rec          IN     BRM_Process_rec_type
);

--------------------------------------------------------------------------
-- Start of comments
--  API Name    : Delete_BRMParameter
--  Type        : Private
--  Description : Delete record in JTF_BRM_PROCESSES table.
--  Pre-reqs    : None
--  Parameters  :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      p_api_version        IN         NUMBER   required
--      p_init_msg_list      IN         VARCHAR2 optional
--      p_commit             IN         VARCHAR2 optional
--      p_validation_level   IN         NUMBER   optional
--      x_return_status         OUT     VARCHAR2 required
--      x_msg_count             OUT     NUMBER   required
--      x_msg_data              OUT     VARCHAR2 required
--      p_Process_id         IN         NUMBER   required
--
--  Version : Current  version 1.1
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes: :
--
-- End of comments
--------------------------------------------------------------------------
/*#
 * Delete record in JTF_BRM_PROCESSES table.
 * @param p_api_version API Version Required
 * @param p_init_msg_list Initialize message list flag, Optional Default = FND_API.G_FALSE
 * @param p_commit Optional Default = FND_API.G_FALSE
 * @param p_validation_level Optional DEFAULT fnd_api.g_valid_level_full
 * @param x_return_status Required Length  = 1
 * @param x_msg_count API Error message count, Required
 * @param x_msg_data API Error message data, Required Length  = 2000
 * @param p_process_id Required input process id to be deleted.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete BRM Process
 */
PROCEDURE Delete_BRMProcess
( p_api_version      IN     NUMBER
, p_init_msg_list    IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit           IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
, p_process_id       IN NUMBER
);

END JTF_BRMProcess_PVT;

 

/
