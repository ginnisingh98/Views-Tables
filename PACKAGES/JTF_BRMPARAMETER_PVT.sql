--------------------------------------------------------
--  DDL for Package JTF_BRMPARAMETER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_BRMPARAMETER_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvbps.pls 120.2 2005/07/05 07:44:44 abraina ship $ */

TYPE BRM_Parameter_rec_type IS RECORD
( PARAMETER_ID                NUMBER
, CREATED_BY                  NUMBER(15)
, CREATION_DATE               DATE
, LAST_UPDATED_BY             NUMBER(15)
, LAST_UPDATE_DATE            DATE
, LAST_UPDATE_LOGIN           NUMBER(15)
, BRM_UOM_TYPE                VARCHAR2(30)
, BRM_UOM_CODE                VARCHAR2(30)
, BRM_INTERVAL                NUMBER(9)
, BRM_WF_COMMAND_TYPE         VARCHAR2(30)
, BRM_WF_COMMAND_CODE         VARCHAR2(30)
, WORKFLOW_PROCESS_ID         NUMBER
, WORKFLOW_ITEM_TYPE          VARCHAR2(8)
, WORKFLOW_PROCESS_NAME       VARCHAR2(30)
, ATTRIBUTE1                  VARCHAR2(150)
, ATTRIBUTE2                  VARCHAR2(150)
, ATTRIBUTE3                  VARCHAR2(150)
, ATTRIBUTE4                  VARCHAR2(150)
, ATTRIBUTE5                  VARCHAR2(150)
, ATTRIBUTE6                  VARCHAR2(150)
, ATTRIBUTE7                  VARCHAR2(150)
, ATTRIBUTE8                  VARCHAR2(150)
, ATTRIBUTE9                  VARCHAR2(150)
, ATTRIBUTE10                 VARCHAR2(150)
, ATTRIBUTE11                 VARCHAR2(150)
, ATTRIBUTE12                 VARCHAR2(150)
, ATTRIBUTE13                 VARCHAR2(150)
, ATTRIBUTE14                 VARCHAR2(150)
, ATTRIBUTE15                 VARCHAR2(150)
, ATTRIBUTE_CATEGORY          VARCHAR2(30)
, SECURITY_GROUP_ID           NUMBER
, OBJECT_VERSION_NUMBER       NUMBER
, APPLICATION_ID              NUMBER
);

--------------------------------------------------------------------------
-- Start of comments
--  API name    : Create_BRMParameter
--  Type        : Private
--  Function    : Create record in JTF_BRM_PARAMETER table.
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
--      p_BRMParameter_rec   IN         brm_parameter_rec_type   required
--      x_record_id             OUT     NUMBER  required
--
--  Version : Current    version 1.1
--            Previous   version 1.0
--            Initial    version 1.0
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Create_BRMParameter
( p_api_version      IN     NUMBER
, p_init_msg_list    IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit           IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
, p_bp_rec           IN     BRM_Parameter_rec_type
, x_record_id           OUT NOCOPY NUMBER
);

--------------------------------------------------------------------------
-- Start of comments
--  API name   : Update_BRMParameter
--  Type       : Private
--  Function   : Update record in JTF_BRM_PARAMETERS table.
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
--      p_BRMParameter_rec   IN         brm_parameter_rec_type   required
--
--  Version : Current  version 1.1
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes:
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Update_BRMParameter
( p_api_version      IN     NUMBER
, p_init_msg_list    IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit           IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
, p_bp_rec           IN     BRM_Parameter_rec_type
);


--------------------------------------------------------------------------
-- Start of comments
--  API Name    : Delete_BRMParameter
--  Type        : Private
--  Description : Delete record in JTF_BRM_PARAMETERS table.
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
--      p_parameter_id       IN         NUMBER   required
--
--  Version : Current  version 1.1
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes: :
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Delete_BRMParameter
( p_api_version      IN     NUMBER
, p_init_msg_list    IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit           IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
, p_parameter_id     IN     NUMBER
);

END JTF_BRMParameter_PVT;

 

/
