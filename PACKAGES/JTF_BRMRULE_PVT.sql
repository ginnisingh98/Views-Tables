--------------------------------------------------------
--  DDL for Package JTF_BRMRULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_BRMRULE_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvbrs.pls 120.2 2005/07/05 07:45:04 abraina ship $ */

TYPE BRM_Rule_rec_type IS RECORD
  ( RULE_ID                 NUMBER
  , BRM_OBJECT_TYPE         VARCHAR2(30)
  , BRM_OBJECT_CODE         VARCHAR2(30)
  , SEEDED_FLAG             VARCHAR2(1)
  , VIEW_DEFINITION         LONG
  , VIEW_NAME               VARCHAR2(30)
  , RULE_OWNER              NUMBER(15)
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
  , ATTRIBUTE_CATEGORY      VARCHAR2(150)
  , RULE_NAME               VARCHAR2(30)
  , RULE_DESCRIPTION        VARCHAR2(2000)
  , CREATION_DATE           DATE
  , CREATED_BY              NUMBER(15)
  , LAST_UPDATE_DATE        DATE
  , LAST_UPDATED_BY         NUMBER(15)
  , LAST_UPDATE_LOGIN       NUMBER(15)
  , SECURITY_GROUP_ID       NUMBER
  , OBJECT_VERSION_NUMBER   NUMBER
  , APPLICATION_ID          NUMBER
  );

--------------------------------------------------------------------------
-- Start of comments
--  API name    : Create_BRMRule
--  Type        : Private
--  Function    : Create record in JTF_BRM_RULES_B and _TL tables.
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
--      p_br_rec             IN         BRM_Rule_rec_type   required
--      x_record_id             OUT     NUMBER  required
--
--  Version : Current  version 1.1
--            Previous version 1.0
--            Initial  version 1.1
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Create_BRMRule
( p_api_version       IN     NUMBER
, p_init_msg_list     IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit            IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level  IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
, p_br_rec            IN     BRM_Rule_rec_type
, x_record_id            OUT NOCOPY NUMBER
);

--------------------------------------------------------------------------
-- Start of comments
--  API name   : Update_BRMRule
--  Type       : Private
--  Function   : Update record in JTF_BRM_RULES_B and _TL tables.
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
--      p_br_rec             IN         BRM_Rule_rec_type   required
--
--  Version : Current  version 1.1
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes:
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Update_BRMRule
( p_api_version      IN     NUMBER
, p_init_msg_list    IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit           IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
, p_br_rec           IN     BRM_Rule_rec_type
);

--------------------------------------------------------------------------
-- Start of comments
--  API Name    : Delete_BRMRule
--  Type        : Private
--  Description : Delete record in JTF_BRM_RULES_B and _TL tables.
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
--      p_rule_id            IN         NUMBER   required
--
--  Version : Current  version 1.1
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes: :
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Delete_BRMRule
( p_api_version      IN      NUMBER
, p_init_msg_list    IN      VARCHAR2 DEFAULT fnd_api.g_false
, p_commit           IN      VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level IN      NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
, p_rule_id          IN     NUMBER
);
--------------------------------------------------------------------------
-- Start of comments
--  API Name    : Add_Language
--  Type        : Private
--  Description : Additional Language processing for JTF_BRM_RULES_B and
--                _TL tables.
--  Pre-reqs    : None
--  Parameters  : None
--  Version     : Current  version 1.0
--                Previous version none
--                Initial  version 1.0
--
--  Notes:
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Add_Language;

--------------------------------------------------------------------------
-- Start of comments
--  API Name    : Translate_Row
--  Type        : Private
--  Description : Additional Language processing for JTF_BRM_RULES_B and
--                _TL tables. Used in the FNDLOAD definition file (.lct)
--  Pre-reqs    : None
--  Parameters  : None
--  Version     : Current  version 1.0
--                Previous version none
--                Initial  version 1.0
--
--  Notes:
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Translate_Row
( p_rule_id          IN NUMBER
, p_rule_name        IN VARCHAR2
, p_rule_description IN VARCHAR2
, p_owner            IN VARCHAR2
);

--------------------------------------------------------------------------
-- Start of comments
--  API Name    : Load_Row
--  Type        : Private
--  Description : Additional Language processing for JTF_BRM_RULES_B and
--                _TL tables. Used in the FNDLOAD definition file (.lct)
--  Pre-reqs    : None
--  Parameters  : None
--  Version     : Current  version 1.0
--                Previous version none
--                Initial  version 1.0
--
--  Notes:
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Load_Row
( p_rule_id  IN NUMBER
, p_br_rec   IN BRM_Rule_rec_type
, p_owner    IN VARCHAR2
);

END JTF_BRMRule_PVT;

 

/
