--------------------------------------------------------
--  DDL for Package CN_MODULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_MODULES_PKG" AUTHID CURRENT_USER AS
  -- $Header: cnsymods.pls 120.4 2005/09/22 07:57:49 vensrini noship $


  --+
  -- Procedure Name
  --   sync_module
  -- Purpose
  --   Generate a module for a Commissions function.
  -- History
  --+

  PROCEDURE sync_module (
			 x_module_id             NUMBER,
			 x_module_status IN OUT NOCOPY  VARCHAR2);


  --+
  -- Procedure Name
  --   unsync_module
  -- Purpose
  --   Mark a module as UNSYNC.
  -- History
  --+
  PROCEDURE unsync_module (
            x_module_id             NUMBER,
            x_module_status IN OUT NOCOPY  VARCHAR2,
		    x_org_id IN NUMBER);

  procedure INSERT_ROW (
			X_ROWID in out nocopy VARCHAR2,
			X_MODULE_ID in NUMBER,
			X_MODULE_TYPE in VARCHAR2,
			X_REPOSITORY_ID in NUMBER,
			X_DESCRIPTION in VARCHAR2,
			X_PARENT_MODULE_ID in NUMBER,
			X_SOURCE_REPOSITORY_ID in NUMBER,
			X_MODULE_STATUS in VARCHAR2,
			X_EVENT_ID in NUMBER,
			X_LAST_MODIFICATION in DATE,
			X_LAST_SYNCHRONIZATION in DATE,
			X_OUTPUT_FILENAME in VARCHAR2,
			X_COLLECT_FLAG in VARCHAR2,
			X_NAME in VARCHAR2,
			X_CREATION_DATE in DATE,
			X_CREATED_BY in NUMBER,
			X_LAST_UPDATE_DATE in DATE,
			X_LAST_UPDATED_BY in NUMBER,
			X_LAST_UPDATE_LOGIN in NUMBER,
            X_ORG_ID in NUMBER -- Modified For R12 MOAC
			);

  procedure LOCK_ROW (
		      X_MODULE_ID in NUMBER,
		      X_MODULE_TYPE in VARCHAR2,
		      X_REPOSITORY_ID in NUMBER,
		      X_DESCRIPTION in VARCHAR2,
		      X_PARENT_MODULE_ID in NUMBER,
		      X_SOURCE_REPOSITORY_ID in NUMBER,
		      X_MODULE_STATUS in VARCHAR2,
		      X_EVENT_ID in NUMBER,
		      X_LAST_MODIFICATION in DATE,
		      X_LAST_SYNCHRONIZATION in DATE,
		      X_OUTPUT_FILENAME in VARCHAR2,
		      X_COLLECT_FLAG in VARCHAR2,
		      X_NAME in VARCHAR2,
              X_ORG_ID IN NUMBER   -- Modified For R12 MOAC
		      );

  procedure UPDATE_ROW (
			X_MODULE_ID in NUMBER := FND_API.G_MISS_NUM,
			X_MODULE_TYPE in VARCHAR2 := FND_API.G_MISS_CHAR,
			X_REPOSITORY_ID in NUMBER := FND_API.G_MISS_NUM,
			X_DESCRIPTION in VARCHAR2 := FND_API.G_MISS_CHAR,
			X_PARENT_MODULE_ID in NUMBER := FND_API.G_MISS_NUM,
			X_SOURCE_REPOSITORY_ID in NUMBER := FND_API.G_MISS_NUM,
			X_MODULE_STATUS in VARCHAR2 := FND_API.G_MISS_CHAR,
			X_EVENT_ID in NUMBER := FND_API.G_MISS_NUM,
			X_LAST_MODIFICATION in DATE := FND_API.G_MISS_DATE,
			X_LAST_SYNCHRONIZATION in DATE := FND_API.G_MISS_DATE,
			X_OUTPUT_FILENAME in VARCHAR2 := FND_API.G_MISS_CHAR,
			X_COLLECT_FLAG in VARCHAR2 := FND_API.G_MISS_CHAR,
			X_NAME in VARCHAR2 := FND_API.G_MISS_CHAR,
			X_LAST_UPDATE_DATE in DATE := FND_API.G_MISS_DATE,
			X_LAST_UPDATED_BY in NUMBER := FND_API.G_MISS_NUM,
			X_LAST_UPDATE_LOGIN in NUMBER := FND_API.G_MISS_NUM,
            X_ORG_ID IN NUMBER  := FND_API.G_MISS_NUM -- Modified For R12 MOAC
			);

  procedure DELETE_ROW (
			X_MODULE_ID in NUMBER,
            X_ORG_ID IN NUMBER -- Modified For R12 MOAC
			);

  procedure ADD_LANGUAGE;


-- --------------------------------------------------------------------+
-- Procedure : LOAD_ROW
-- Description : Called by FNDLOAD to upload seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
  PROCEDURE  LOAD_ROW
    (x_module_id IN NUMBER,
     x_name IN VARCHAR2,
     x_description IN VARCHAR2,
     x_module_type IN VARCHAR2,
     x_module_status IN VARCHAR2,
     x_event_id IN NUMBER,
     x_repository_id IN NUMBER,
     x_parent_module_id IN NUMBER,
     x_source_repository_id IN NUMBER,
     x_last_modification IN DATE,
     x_last_synchronization IN DATE,
     x_output_filename IN VARCHAR2,
     x_collect_flag IN VARCHAR2,
     x_org_id IN NUMBER,
     x_owner IN VARCHAR2);

-- --------------------------------------------------------------------+
-- Procedure : TRANSLATE_ROW
-- Description : Called by FNDLOAD to translate seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
  PROCEDURE TRANSLATE_ROW
  ( x_module_id IN NUMBER,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2);

END cn_modules_pkg;

 

/
