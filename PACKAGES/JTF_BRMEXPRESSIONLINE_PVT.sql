--------------------------------------------------------
--  DDL for Package JTF_BRMEXPRESSIONLINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_BRMEXPRESSIONLINE_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvbels.pls 120.2 2005/07/05 07:44:23 abraina ship $ */

TYPE brm_expression_line_rec_type IS RECORD
  ( EXPRESSION_LINE_ID               NUMBER
  , RULE_ID                          NUMBER
  , CREATED_BY                       NUMBER(15)
  , CREATION_DATE                    DATE
  , LAST_UPDATED_BY                  NUMBER(15)
  , LAST_UPDATE_DATE                 DATE
  , LAST_UPDATE_LOGIN                NUMBER(15)
  , SORT_SEQUENCE                    NUMBER(9)
  , BRM_LEFT_PARENTHESIS_TYPE        VARCHAR2(30)
  , BRM_LEFT_PARENTHESIS_CODE        VARCHAR2(30)
  , LEFT_VALUE                       VARCHAR2(50)
  , BRM_OPERATOR_TYPE                VARCHAR2(30)
  , BRM_OPERATOR_CODE                VARCHAR2(30)
  , RIGHT_VALUE                      VARCHAR2(50)
  , BRM_RIGHT_PARENTHESIS_TYPE       VARCHAR2(30)
  , BRM_RIGHT_PARENTHESIS_CODE       VARCHAR2(30)
  , BRM_BOOLEAN_OPERATOR_TYPE        VARCHAR2(30)
  , BRM_BOOLEAN_OPERATOR_CODE        VARCHAR2(30)
  , ATTRIBUTE1                       VARCHAR2(150)
  , ATTRIBUTE2                       VARCHAR2(150)
  , ATTRIBUTE3                       VARCHAR2(150)
  , ATTRIBUTE4                       VARCHAR2(150)
  , ATTRIBUTE5                       VARCHAR2(150)
  , ATTRIBUTE6                       VARCHAR2(150)
  , ATTRIBUTE7                       VARCHAR2(150)
  , ATTRIBUTE8                       VARCHAR2(150)
  , ATTRIBUTE9                       VARCHAR2(150)
  , ATTRIBUTE10                      VARCHAR2(150)
  , ATTRIBUTE11                      VARCHAR2(150)
  , ATTRIBUTE12                      VARCHAR2(150)
  , ATTRIBUTE13                      VARCHAR2(150)
  , ATTRIBUTE14                      VARCHAR2(150)
  , ATTRIBUTE15                      VARCHAR2(150)
  , ATTRIBUTE_CATEGORY               VARCHAR2(30)
  , SECURITY_GROUP_ID                NUMBER
  , OBJECT_VERSION_NUMBER            NUMBER
  , APPLICATION_ID                   NUMBER
  );

--------------------------------------------------------------------------
-- Start of comments
--  API name    : Create_ExpressionLine
--  Type        : Private
--  Function    : Create record in JTF_BRM_EXPRESSION_LINE table.
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
--      p_bel_rec            IN         brm_expression_line_rec_type   required
--      x_record_id             OUT     NUMBER   required
--
--  Version : Current  version 1.1
--            Previous version 1.0
--            Initial  version 1.0
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Create_ExpressionLine
( p_api_version       IN     NUMBER
, p_init_msg_list     IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit            IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level  IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
, p_bel_rec           IN     brm_expression_line_rec_type
, x_record_id            OUT NOCOPY NUMBER
);

--------------------------------------------------------------------------
-- Start of comments
--  API name   : Update_ExpressionLine
--  Type       : Private
--  Function   : Update record in JTF_BRM_EXPRESSION_LINE table.
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
--      p_bel_rec            IN         brm_expression_line_rec_type required
--
--  Version : Current  version 1.1
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes:
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Update_ExpressionLine
( p_api_version      IN     NUMBER
, p_init_msg_list    IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit           IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
, p_bel_rec          IN     brm_expression_line_rec_type
);


--------------------------------------------------------------------------
-- Start of comments
--  API Name    : Delete_ExpressionLine
--  Type        : Private
--  Description : Delete record in JTF_BRM_EXPRESSION_LINE table.
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
--      p_expression_line_id IN         NUMBER   required
--
--  Version : Current  version 1.1
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes: :
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Delete_ExpressionLine
( p_api_version        IN     NUMBER
, p_init_msg_list      IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit             IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level   IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, p_expression_line_id IN     NUMBER
);


END JTF_BRMExpressionLine_PVT;

 

/
