--------------------------------------------------------
--  DDL for Package Body CN_SYIN_RULESETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SYIN_RULESETS_PKG" AS
-- $Header: cnsyinib.pls 120.9 2006/01/13 03:55:37 hanaraya ship $


-- =================================================================================
-- Procedure Name : Populate_Fields
-- History
--			Tony Lower		Created
-- =================================================================================
PROCEDURE Populate_fields (X_column_id		number,
			   X_column_name IN OUT NOCOPY	varchar2) IS
  BEGIN

    IF X_column_id IS NOT NULL THEN
      SELECT name INTO X_column_name FROM cn_obj_columns_v
	WHERE column_id = X_column_id;
    END IF;

  END Populate_Fields;



-- =================================================================================
-- Procedure Name : insert_row
-- History
--			Tony Lower		Created
--  Feb-25-99         Harlen Chen             Change to new insert_row for MLS
-- =================================================================================

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
   X_ORG_ID in NUMBER := FND_API.G_MISS_NUM)
  IS


     l_rowid ROWID;

BEGIN


  insert into CN_RULESETS_ALL_B
    (
     RULESET_STATUS,
     RULESET_ID,
     DESTINATION_COLUMN_ID,
     REPOSITORY_ID,
     start_date,
     end_date,
     module_type,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     OBJECT_VERSION_NUMBER,
     ORG_ID
     ) values
    (
     x_RULESET_STATUS,
     x_RULESET_ID,
     x_DESTINATION_COLUMN_ID,
     x_REPOSITORY_ID,
     x_start_date,
     x_end_date,
     x_module_type,
     x_CREATION_DATE,
     x_CREATED_BY,
     x_LAST_UPDATE_DATE,
     x_LAST_UPDATED_BY,
     x_LAST_UPDATE_LOGIN,
     1,
     x_org_id
     );

  insert into CN_RULESETS_ALL_TL (
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    NAME,
    RULESET_ID,
    LANGUAGE,
    SOURCE_LANG,
    ORG_ID
  ) select
    x_CREATED_BY,
    x_LAST_UPDATE_DATE,
    x_LAST_UPDATED_BY,
    x_LAST_UPDATE_LOGIN,
    x_CREATION_DATE,
    x_NAME,
    x_RULESET_ID,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    x_org_id
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
 and not exists
    (select NULL
    from CN_RULESETS_ALL_TL T
    where T.RULESET_ID = x_RULESET_ID
    and T.LANGUAGE = L.language_code AND
    T.ORG_ID=x_org_id);



-- 04-MAR-99 RC Commented out following code since rule_id
-- for base rule should be -1002
--  SELECT cn_rules_s.NEXTVAL
--    INTO  l_new_rule_id
--    FROM dual;

 cn_syin_rules_pkg.insert_row_into_cn_rules_only(
  x_rowid => l_rowid,
  X_RULE_ID => -1002,
  X_RULESET_ID => X_ruleset_id,
  X_NAME => 'BASE_RULE',
  X_ORG_ID => X_ORG_ID);


end INSERT_ROW;



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
) is
BEGIN

  update CN_RULESETS_ALL_B set
    RULESET_STATUS = X_RULESET_STATUS,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    DESTINATION_COLUMN_ID = X_DESTINATION_COLUMN_ID,
    REPOSITORY_ID = X_REPOSITORY_ID,
    start_date = x_start_date,
    end_date = x_end_date,
    module_type = x_module_type,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where RULESET_ID = x_ruleset_id  AND
  ORG_ID=X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CN_RULESETS_ALL_TL set
    NAME = X_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where RULESET_ID = X_RULESET_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG)  AND
   ORG_ID=X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RULESET_ID in NUMBER,
  X_ORG_ID IN NUMBER
) is
begin
  delete from CN_RULESETS_ALL_TL
  where RULESET_ID = x_ruleset_id  AND
  ORG_ID=X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CN_RULESETS_ALL_B
  where RULESET_ID = x_ruleset_id  AND
  ORG_ID=X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from CN_RULESETS_ALL_TL T
  where not exists
    (select NULL
    from CN_RULESETS_ALL_B B
    where B.RULESET_ID = T.ruleset_id
    and   B.ORG_ID = T.ORG_ID
    );

  update CN_RULESETS_ALL_TL T set (
      NAME
    ) = (select
      B.NAME
    from CN_RULESETS_ALL_TL B
    where B.RULESET_ID = T.RULESET_ID
    and B.LANGUAGE = T.source_lang
    and   B.ORG_ID = T.ORG_ID 	 )
  where (
      T.RULESET_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RULESET_ID,
      SUBT.LANGUAGE
    from CN_RULESETS_ALL_TL SUBB, CN_RULESETS_ALL_TL SUBT
    where SUBB.RULESET_ID = SUBT.RULESET_ID
    and SUBB.LANGUAGE = SUBT.source_lang
    and   SUBB.ORG_ID = SUBT.ORG_ID
    and (SUBB.NAME <> SUBT.name
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
  ));

  insert into CN_RULESETS_ALL_TL (
    ORG_ID,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    NAME,
    RULESET_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ORG_ID,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.NAME,
    B.RULESET_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CN_RULESETS_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CN_RULESETS_ALL_TL T
    where T.RULESET_ID = B.RULESET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE
    and   T.ORG_ID = B.ORG_ID );
end ADD_LANGUAGE;

-- --------------------------------------------------------------------+
-- Procedure : LOAD_ROW
-- Description : Called by FNDLOAD to upload seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+

PROCEDURE LOAD_ROW
  ( x_ruleset_id IN NUMBER,
    x_destination_column_id  IN NUMBER,
    x_repository_id   IN NUMBER,
    x_name IN VARCHAR2,
    x_ruleset_status in VARCHAR2,
    x_start_date IN DATE,
    x_end_date IN DATE,
    x_owner IN VARCHAR2,
    x_org_id IN NUMBER) IS

       user_id NUMBER;

BEGIN
   -- Validate input data
   IF (x_ruleset_id IS NULL) OR (x_name IS NULL)
     OR (x_destination_column_id IS NULL) OR (x_repository_id IS NULL)
       OR (x_ruleset_status IS NULL) THEN
      GOTO end_load_row;
   END IF;

   IF (x_owner IS NOT NULL) AND (x_owner = 'SEED') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;
   -- Load The record to _B table
   UPDATE cn_rulesets_all_b SET
     destination_column_id = x_destination_column_id,
     repository_id = x_repository_id,
     ruleset_status = x_ruleset_status,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0
     WHERE ruleset_id = x_ruleset_id and org_id=x_org_id ;

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _B table
      INSERT INTO cn_rulesets_all_b
	(RULESET_ID,
	 DESTINATION_COLUMN_ID,
	 REPOSITORY_ID,
	 RULESET_STATUS,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 LAST_UPDATE_LOGIN,
	 ORG_ID
	 ) VALUES
	(X_RULESET_ID,
	 X_DESTINATION_COLUMN_ID,
	 X_REPOSITORY_ID,
	 X_RULESET_STATUS,
	 sysdate,
	 user_id,
	 sysdate,
	 user_id,
	 0,
	 x_org_id
	 );
   END IF;
   -- Load The record to _TL table
   UPDATE cn_rulesets_all_tl  SET
     name = x_name,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     source_lang = userenv('LANG')
     WHERE ruleset_id = x_ruleset_id AND org_id=x_org_id
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _TL table
      INSERT INTO cn_rulesets_all_tl
	(ruleset_id,
	 name,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 language,
	 source_lang,
	 org_id)
	SELECT
	x_ruleset_id,
	x_name,
	sysdate,
	user_id,
	sysdate,
	user_id,
	0,
	l.language_code,
	userenv('LANG'),
	x_org_id
	FROM fnd_languages l
	WHERE l.installed_flag IN ('I', 'B')
	AND NOT EXISTS
	(SELECT NULL
	 FROM cn_rulesets_all_tl t
	 WHERE t.ruleset_id = x_ruleset_id and t.org_id=x_org_id
	 AND t.language = l.language_code);
   END IF;
   << end_load_row >>
     NULL;
END LOAD_ROW ;

-- --------------------------------------------------------------------+
-- Procedure : TRANSLATE_ROW
-- Description : Called by FNDLOAD to translate seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
PROCEDURE TRANSLATE_ROW
  ( x_ruleset_id IN NUMBER,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2,
    x_org_id in number) IS
    user_id NUMBER;
BEGIN
    -- Validate input data
   IF (x_ruleset_id IS NULL) OR (x_name IS NULL) THEN
      GOTO end_translate_row;
   END IF;

   IF (x_owner IS NOT NULL) AND (x_owner = 'SEED') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;
   -- Update the translation
   UPDATE cn_rulesets_all_tl  SET
     name = x_name,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     source_lang = userenv('LANG')
     WHERE ruleset_id = x_ruleset_id and org_id=x_org_id
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   << end_translate_row >>
     NULL;
END TRANSLATE_ROW ;


END cn_syin_rulesets_pkg;

/
