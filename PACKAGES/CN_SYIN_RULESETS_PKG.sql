--------------------------------------------------------
--  DDL for Package CN_SYIN_RULESETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SYIN_RULESETS_PKG" AUTHID CURRENT_USER as
-- $Header: cnsyinis.pls 120.6 2005/12/27 04:00:28 hanaraya ship $


-- =====================================================================================
-- Procedure Name    :  populate_fields
-- Purpose
--
-- History
--   01/26/94		Tony Lower		Created
-- =====================================================================================
PROCEDURE Populate_fields (X_column_id		number,
			   X_column_name IN OUT NOCOPY	varchar2);


-- =====================================================================================
-- Procedure Name : insert_row
-- Purpose
--
-- History
--   01/26/94		Tony Lower		Created
--   Feb-25-99        Harlen Chen               Use new insert_row for MLS
-- =====================================================================================

procedure INSERT_ROW
  (
   X_ROWID in out NOCOPY VARCHAR2,
   X_RULESET_ID in NUMBER := FND_API.G_MISS_NUM,
   X_RULESET_STATUS in VARCHAR2 := FND_API.G_MISS_CHAR,
   X_DESTINATION_COLUMN_ID in NUMBER := FND_API.G_MISS_NUM,
   X_REPOSITORY_ID in NUMBER := FND_API.G_MISS_NUM,
   X_NAME in VARCHAR2 := FND_API.G_MISS_CHAR,
   x_module_type IN VARCHAR2 := fnd_api.g_miss_char,
   x_start_date IN DATE := fnd_api.g_miss_date,
   x_end_date IN DATE := fnd_api.g_miss_date,
   X_CREATION_DATE in DATE := FND_API.G_MISS_DATE,
   X_CREATED_BY in NUMBER := FND_API.G_MISS_NUM,
   X_LAST_UPDATE_DATE in DATE := FND_API.G_MISS_DATE,
   X_LAST_UPDATED_BY in NUMBER := FND_API.G_MISS_NUM,
   X_LAST_UPDATE_LOGIN in NUMBER := FND_API.G_MISS_NUM,
   X_ORG_ID in NUMBER := FND_API.G_MISS_NUM);



procedure UPDATE_ROW
  (
   X_RULESET_ID in NUMBER,
   X_OBJECT_VERSION_NUMBER IN NUMBER,
   X_RULESET_STATUS in VARCHAR2,
   X_DESTINATION_COLUMN_ID in NUMBER,
   X_REPOSITORY_ID in NUMBER,
   x_start_date IN DATE,
   x_end_date IN DATE,
   X_NAME in VARCHAR2,
   x_module_type IN VARCHAR2,
   X_LAST_UPDATE_DATE in DATE,
   X_LAST_UPDATED_BY in NUMBER,
   X_LAST_UPDATE_LOGIN in NUMBER,
   X_ORG_ID in NUMBER
   );
procedure DELETE_ROW (
		      X_RULESET_ID in NUMBER,
		      X_ORG_ID IN NUMBER
		      );

procedure ADD_LANGUAGE;
--
-- Procedure : LOAD_ROW
-- Description : Called by FNDLOAD to upload seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
--
PROCEDURE LOAD_ROW
  ( x_ruleset_id IN NUMBER,
    x_destination_column_id  IN NUMBER,
    x_repository_id   IN NUMBER,
    x_name IN VARCHAR2,
    x_ruleset_status in VARCHAR2,
    x_start_date IN DATE,
    x_end_date IN DATE,
    x_owner IN VARCHAR2,
    x_org_id IN NUMBER);

--
-- Procedure : TRANSLATE_ROW
-- Description : Called by FNDLOAD to translate seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
--
PROCEDURE TRANSLATE_ROW
  ( x_ruleset_id IN NUMBER,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2,
    x_org_id IN NUMBER);


END CN_SYIN_Rulesets_PKG;
 

/
