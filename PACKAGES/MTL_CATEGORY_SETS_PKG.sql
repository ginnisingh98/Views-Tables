--------------------------------------------------------
--  DDL for Package MTL_CATEGORY_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_CATEGORY_SETS_PKG" AUTHID CURRENT_USER as
/* $Header: INVICSHS.pls 120.3 2006/06/05 12:06:46 lparihar ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CATEGORY_SET_ID in NUMBER,
  X_CATEGORY_SET_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_STRUCTURE_ID in NUMBER,
  X_VALIDATE_FLAG in VARCHAR2,
  X_MULT_ITEM_CAT_ASSIGN_FLAG IN VARCHAR2,
  X_CONTROL_LEVEL_UPDT_FLAG     IN    VARCHAR2  DEFAULT NULL,
  X_MULT_ITEM_CAT_UPDT_FLAG     IN    VARCHAR2  DEFAULT NULL,
  X_VALIDATE_FLAG_UPDT_FLAG     IN    VARCHAR2  DEFAULT NULL,
  X_HIERARCHY_ENABLED           IN    VARCHAR2 DEFAULT  NULL,
  X_CONTROL_LEVEL in NUMBER,
  X_DEFAULT_CATEGORY_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
--  X_REQUEST_ID in NUMBER,
);

procedure LOCK_ROW (
  X_CATEGORY_SET_ID in NUMBER,
  X_CATEGORY_SET_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_STRUCTURE_ID in NUMBER,
  X_VALIDATE_FLAG in VARCHAR2,
  X_MULT_ITEM_CAT_ASSIGN_FLAG in VARCHAR2,
  X_CONTROL_LEVEL in NUMBER,
  X_DEFAULT_CATEGORY_ID in NUMBER
--  X_REQUEST_ID in NUMBER,
);

procedure UPDATE_ROW (
  X_CATEGORY_SET_ID           IN NUMBER,
  X_CATEGORY_SET_NAME         IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
  X_DESCRIPTION               IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
  X_STRUCTURE_ID              IN NUMBER   DEFAULT FND_API.G_MISS_NUM,
  X_VALIDATE_FLAG             IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
  X_MULT_ITEM_CAT_ASSIGN_FLAG IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
  X_CONTROL_LEVEL_UPDT_FLAG   IN VARCHAR2 DEFAULT NULL,
  X_MULT_ITEM_CAT_UPDT_FLAG   IN VARCHAR2 DEFAULT NULL,
  X_VALIDATE_FLAG_UPDT_FLAG   IN VARCHAR2 DEFAULT NULL,
  X_HIERARCHY_ENABLED         IN VARCHAR2 DEFAULT  NULL,
  X_CONTROL_LEVEL             IN NUMBER   DEFAULT FND_API.G_MISS_NUM,
  X_DEFAULT_CATEGORY_ID       IN NUMBER   DEFAULT FND_API.G_MISS_NUM,
  X_LAST_UPDATE_DATE          IN DATE,
  X_LAST_UPDATED_BY           IN NUMBER,
  X_LAST_UPDATE_LOGIN         IN NUMBER

);

procedure DELETE_ROW (
  X_CATEGORY_SET_ID in NUMBER
);

procedure ADD_LANGUAGE;


-- ----------------------------------------------------------------------
-- PROCEDURE:  Translate_Row
--
-- PARAMETERS:
--  x_<developer key>
--  x_<translated columns>
--  x_owner             user owning the row (SEED or other)
--
-- COMMENT:
--  Called from the FNDLOAD config file in 'NLS' mode to upload
--  translations.
-- ----------------------------------------------------------------------

PROCEDURE Translate_Row
(
   x_category_set_id     IN  NUMBER
,  x_category_set_name   IN  VARCHAR2
,  x_description         IN  VARCHAR2
,  x_owner               IN  VARCHAR2
,  x_custom_mode         IN  VARCHAR2
,  x_lud                 IN  DATE DEFAULT SYSDATE
);

-- ----------------------------------------------------------------------
-- PROCEDURE:  Load_Row
--
-- PARAMETERS:
--  x_<developer key>
--  x_<table_data>
--  x_owner             user owning the row (SEED or other)
--
-- COMMENT:
--  Called from the FNDLOAD config file in 'MLS' mode to upload a
--  multi-lingual entity.
-- ----------------------------------------------------------------------

PROCEDURE Load_Row
(
   x_category_set_id      IN  NUMBER
,  x_category_set_name    IN  VARCHAR2
,  x_description          IN  VARCHAR2
,  X_STRUCTURE_ID         IN  NUMBER
,  X_VALIDATE_FLAG        IN  VARCHAR2
,  X_MULT_ITEM_CAT_ASSIGN_FLAG IN VARCHAR2
,  X_CONTROL_LEVEL_UPDT_FLAG   IN VARCHAR2
,  X_MULT_ITEM_CAT_UPDT_FLAG   IN VARCHAR2
,  X_VALIDATE_FLAG_UPDT_FLAG   IN VARCHAR2
,  X_HIERARCHY_ENABLED         IN VARCHAR2
,  X_CONTROL_LEVEL        IN  NUMBER
,  X_DEFAULT_CATEGORY_ID  IN  NUMBER
,  x_owner                IN  VARCHAR2
,  x_custom_mode          IN  VARCHAR2
,  x_msg_name             OUT NOCOPY VARCHAR2
,  x_lud                  IN  DATE DEFAULT SYSDATE
);

-- ----------------------------------------------------------------------
-- PROCEDURE:  Load_Row
--
--
-- COMMENT:
--  Overloaded procedure
-- ----------------------------------------------------------------------
PROCEDURE Load_Row
(
   X_CATEGORY_SET_ID           IN  NUMBER
,  X_CATEGORY_SET_NAME         IN  VARCHAR2
,  X_DESCRIPTION               IN  VARCHAR2
,  X_STRUCTURE_CODE            IN  VARCHAR2
,  X_VALIDATE_FLAG             IN  VARCHAR2
,  X_MULT_ITEM_CAT_ASSIGN_FLAG IN  VARCHAR2
,  X_CONTROL_LEVEL             IN  NUMBER
,  X_DEFAULT_CATEGORY_CD       IN  VARCHAR2
,  X_OWNER                     IN  VARCHAR2
,  X_LAST_UPDATE_DATE          IN  VARCHAR2
,  X_CONTROL_LEVEL_UPDT_FLAG   IN  VARCHAR2
,  X_MULT_ITEM_CAT_UPDT_FLAG   IN  VARCHAR2
,  X_VALIDATE_FLAG_UPDT_FLAG   IN  VARCHAR2
,  X_HIERARCHY_ENABLED         IN  VARCHAR2
);

end MTL_CATEGORY_SETS_PKG;

 

/
