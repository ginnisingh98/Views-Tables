--------------------------------------------------------
--  DDL for Package Body AMS_LIST_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_RULES_PKG" as
/* $Header: amsllrub.pls 120.1 2005/10/19 03:34:41 batoleti noship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_LIST_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LIST_RULE_NAME in VARCHAR2,
  X_WEIGHTAGE_FOR_DEDUPE in NUMBER,
  X_ACTIVE_FROM_DATE in DATE,
  X_ACTIVE_TO_DATE in DATE,
  X_LIST_RULE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  x_LIST_SOURCE_TYPE in        VARCHAR2,
  x_ENABLED_FLAG      in       VARCHAR2,
  x_SEEDED_FLAG       in       VARCHAR2
) is
  cursor C is select ROWID from AMS_LIST_RULES_ALL
    where LIST_RULE_ID = X_LIST_RULE_ID
    ;
begin
  insert into AMS_LIST_RULES_ALL (
    LIST_RULE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    LIST_RULE_NAME,
    WEIGHTAGE_FOR_DEDUPE,
    ACTIVE_FROM_DATE,
    ACTIVE_TO_DATE,
    DESCRIPTION,
    LIST_RULE_TYPE,
    LIST_SOURCE_TYPE,
    ENABLED_FLAG,
    SEEDED_FLAG
  ) values (
    X_LIST_RULE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER,
    X_LIST_RULE_NAME,
    X_WEIGHTAGE_FOR_DEDUPE,
    X_ACTIVE_FROM_DATE,
    X_ACTIVE_TO_DATE,
    X_DESCRIPTION,
    X_LIST_RULE_TYPE,
    x_LIST_SOURCE_TYPE,
    x_ENABLED_FLAG,
    x_SEEDED_FLAG
  );

  insert into AMS_LIST_RULES_ALL_TL (
    LIST_RULE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LIST_RULE_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LIST_RULE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LIST_RULE_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_LIST_RULES_ALL_TL T
    where T.LIST_RULE_ID = X_LIST_RULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_LIST_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LIST_RULE_NAME in VARCHAR2,
  X_WEIGHTAGE_FOR_DEDUPE in NUMBER,
  X_ACTIVE_FROM_DATE in DATE,
  X_ACTIVE_TO_DATE in DATE,
  X_LIST_RULE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c1 is select
      OBJECT_VERSION_NUMBER,
      LIST_RULE_NAME,
      WEIGHTAGE_FOR_DEDUPE,
      ACTIVE_FROM_DATE,
      ACTIVE_TO_DATE,
      LIST_RULE_TYPE,
      DESCRIPTION
    from AMS_LIST_RULES_ALL
    where LIST_RULE_ID = X_LIST_RULE_ID
    for update of LIST_RULE_ID nowait;
begin
  for tlinfo in c1 loop
      if (    ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND ((tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
               OR ((tlinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
          AND (tlinfo.LIST_RULE_NAME = X_LIST_RULE_NAME)
          AND (tlinfo.WEIGHTAGE_FOR_DEDUPE = X_WEIGHTAGE_FOR_DEDUPE)
          AND (tlinfo.ACTIVE_FROM_DATE = X_ACTIVE_FROM_DATE)
          AND ((tlinfo.ACTIVE_TO_DATE = X_ACTIVE_TO_DATE)
               OR ((tlinfo.ACTIVE_TO_DATE is null) AND (X_ACTIVE_TO_DATE is null)))
          AND ((tlinfo.LIST_RULE_TYPE = X_LIST_RULE_TYPE)
               OR ((tlinfo.LIST_RULE_TYPE is null) AND (X_LIST_RULE_TYPE is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_LIST_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LIST_RULE_NAME in VARCHAR2,
  X_WEIGHTAGE_FOR_DEDUPE in NUMBER,
  X_ACTIVE_FROM_DATE in DATE,
  X_ACTIVE_TO_DATE in DATE,
  X_LIST_RULE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  x_LIST_SOURCE_TYPE in        VARCHAR2,
  x_ENABLED_FLAG      in       VARCHAR2,
  x_SEEDED_FLAG       in       VARCHAR2
) is
begin
  update AMS_LIST_RULES_ALL set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LIST_RULE_NAME = X_LIST_RULE_NAME,
    WEIGHTAGE_FOR_DEDUPE = X_WEIGHTAGE_FOR_DEDUPE,
    ACTIVE_FROM_DATE = X_ACTIVE_FROM_DATE,
    ACTIVE_TO_DATE = X_ACTIVE_TO_DATE,
    LIST_RULE_TYPE = X_LIST_RULE_TYPE,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    LIST_SOURCE_TYPE = x_LIST_SOURCE_TYPE,
    ENABLED_FLAG = x_ENABLED_FLAG,
    SEEDED_FLAG = x_SEEDED_FLAG
  where LIST_RULE_ID = X_LIST_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
  update AMS_LIST_RULES_ALL_TL set
    LIST_RULE_NAME = X_LIST_RULE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where LIST_RULE_ID = X_LIST_RULE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LIST_RULE_ID in NUMBER
) is
begin
  delete from AMS_LIST_RULES_ALL_TL
  where LIST_RULE_ID = X_LIST_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_LIST_RULES_ALL
  where LIST_RULE_ID = X_LIST_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

PROCEDURE load_row (
  X_LIST_RULE_ID in NUMBER,
  X_LIST_RULE_NAME in VARCHAR2,
  X_WEIGHTAGE_FOR_DEDUPE in NUMBER,
  X_ACTIVE_FROM_DATE in VARCHAR2,
  X_ACTIVE_TO_DATE in VARCHAR2,
  X_LIST_RULE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  x_owner IN VARCHAR2,
  x_LIST_SOURCE_TYPE in        VARCHAR2,
  x_ENABLED_FLAG      in       VARCHAR2,
  x_SEEDED_FLAG       in       VARCHAR2,
    x_custom_mode IN VARCHAR2

)
IS
   l_user_id   number := 0;
   l_obj_verno  number;
   l_dummy_char  varchar2(1);
   l_row_id    varchar2(100);
   l_list_rule_id   number;
   l_last_updated_by number;

   CURSOR  c_obj_verno IS
     SELECT object_version_number, last_updated_by
     FROM   ams_list_rules_all
     WHERE  list_rule_id =  x_list_rule_id;

   CURSOR c_chk_exists is
     SELECT 'x'
     FROM   ams_list_rules_all
     WHERE  list_rule_id = x_list_rule_id;

   CURSOR c_get_id is
      SELECT ams_list_rules_all_s.NEXTVAL
      FROM DUAL;
BEGIN
   if X_OWNER = 'SEED' then
      l_user_id := 1;
      elsif X_OWNER = 'ORACLE' then
         l_user_id := 2;
     elsif X_OWNER = 'SYSADMIN' THEN
        l_user_id := 0;
      end if;

   OPEN c_chk_exists;
   FETCH c_chk_exists INTO l_dummy_char;
   IF c_chk_exists%notfound THEN
      CLOSE c_chk_exists;

      IF x_list_rule_id IS NULL THEN
         OPEN c_get_id;
         FETCH c_get_id INTO l_list_rule_id;
         CLOSE c_get_id;
      ELSE
         l_list_rule_id := x_list_rule_id;
      END IF;
      l_obj_verno := 1;

      ams_list_rules_pkg.Insert_Row (
         X_ROWID                 => l_row_id,
         X_LIST_RULE_ID          => l_list_rule_id,
         X_OBJECT_VERSION_NUMBER => l_obj_verno,
         X_LIST_RULE_NAME        => x_list_rule_name,
         X_WEIGHTAGE_FOR_DEDUPE  => x_weightage_for_dedupe,
         X_ACTIVE_FROM_DATE      => SYSDATE,
         X_ACTIVE_TO_DATE        => SYSDATE,
         X_LIST_RULE_TYPE        => x_list_rule_type,
         X_DESCRIPTION           => x_description,
         X_CREATION_DATE         => SYSDATE,
         X_CREATED_BY            => l_user_id,
         X_LAST_UPDATE_DATE      => SYSDATE,
         X_LAST_UPDATED_BY       => l_user_id,
         X_LAST_UPDATE_LOGIN     => 0,
         x_LIST_SOURCE_TYPE      => x_LIST_SOURCE_TYPE,
         x_ENABLED_FLAG          => x_ENABLED_FLAG,
         x_SEEDED_FLAG           => x_SEEDED_FLAG
      );
   ELSE
      CLOSE c_chk_exists;
      OPEN c_obj_verno;
      FETCH c_obj_verno INTO l_obj_verno, l_last_updated_by;
      CLOSE c_obj_verno;

 if (l_last_updated_by in (1,2,0) OR
          NVL(x_custom_mode,'PRESERVE')='FORCE') THEN

      ams_list_rules_pkg.Update_Row (
         X_LIST_RULE_ID          => x_list_rule_id,
         X_OBJECT_VERSION_NUMBER => l_obj_verno,
         X_LIST_RULE_NAME        => x_list_rule_name,
         X_WEIGHTAGE_FOR_DEDUPE  => x_weightage_for_dedupe,
         X_ACTIVE_FROM_DATE      => TO_DATE (x_active_from_date, 'YYYY/MM/DD'),
         X_ACTIVE_TO_DATE        => TO_DATE (x_active_to_date, 'YYYY/MM/DD'),
         X_LIST_RULE_TYPE        => x_list_rule_type,
         X_DESCRIPTION           => x_description,
         X_LAST_UPDATE_DATE      => SYSDATE,
         X_LAST_UPDATED_BY       => l_user_id,
         X_LAST_UPDATE_LOGIN     => 0,
         x_LIST_SOURCE_TYPE      => x_LIST_SOURCE_TYPE,
         x_ENABLED_FLAG          => x_ENABLED_FLAG,
         x_SEEDED_FLAG           => x_SEEDED_FLAG
      );

    end if;
   END IF;
END load_row;

PROCEDURE TRANSLATE_ROW (
  X_LIST_RULE_ID            IN NUMBER,
  X_LIST_RULE_NAME          IN VARCHAR2,
  X_DESCRIPTION             IN VARCHAR2,
  X_OWNER                   IN VARCHAR2,
  x_custom_mode IN VARCHAR2

) IS

  cursor c_last_updated_by is
                  select last_updated_by
                  FROM AMS_LIST_RULES_ALL_TL
                  where  LIST_RULE_ID =  X_LIST_RULE_ID
                  and  USERENV('LANG') = LANGUAGE;

        l_last_updated_by number;

BEGIN

     open c_last_updated_by;
     fetch c_last_updated_by into l_last_updated_by;
     close c_last_updated_by;

     if (l_last_updated_by in (1,2,0) OR
            NVL(x_custom_mode,'PRESERVE')='FORCE') THEN


    -- only UPDATE rows that have not been altered by user
    UPDATE AMS_LIST_RULES_ALL_TL
    SET
        LIST_RULE_NAME = NVL(X_LIST_RULE_NAME, LIST_RULE_NAME),
        DESCRIPTION = NVL(X_DESCRIPTION, DESCRIPTION),
        SOURCE_LANG = userenv('LANG'),
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = decode(x_owner, 'SEED', 1, 0),
        LAST_UPDATE_LOGIN = 0
    WHERE LIST_RULE_ID = X_LIST_RULE_ID
    AND   userenv('LANG') IN (language, source_lang);

    end if;
END TRANSLATE_ROW;


------------------ AMS_LIST_RULE_FIELDS -------------------------------
procedure INSERT_FIELD (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_LIST_RULE_FIELD_ID in NUMBER,
  X_FIELD_COLUMN_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SUBSTRING_LENGTH in NUMBER,
  X_WEIGHTAGE in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_LIST_RULE_ID in NUMBER,
  X_FIELD_TABLE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  x_WORD_REPLACEMENT_CODE  in VARCHAR2,
  x_LIST_SOURCE_FIELD_ID in NUMBER
) is
  cursor C is select ROWID from AMS_LIST_RULE_FIELDS
    where LIST_RULE_FIELD_ID = X_LIST_RULE_FIELD_ID
    ;
begin
  insert into AMS_LIST_RULE_FIELDS (
    FIELD_COLUMN_NAME,
    OBJECT_VERSION_NUMBER,
    SUBSTRING_LENGTH,
    WEIGHTAGE,
    SEQUENCE_NUMBER,
    LIST_RULE_FIELD_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LIST_RULE_ID,
    FIELD_TABLE_NAME,
    WORD_REPLACEMENT_CODE,
    LIST_SOURCE_FIELD_ID
  ) values (
    X_FIELD_COLUMN_NAME,
    X_OBJECT_VERSION_NUMBER,
    X_SUBSTRING_LENGTH,
    X_WEIGHTAGE,
    X_SEQUENCE_NUMBER,
    X_LIST_RULE_FIELD_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LIST_RULE_ID,
    X_FIELD_TABLE_NAME,
    x_WORD_REPLACEMENT_CODE,
    x_LIST_SOURCE_FIELD_ID
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_FIELD;

procedure LOCK_FIELD (
  X_LIST_RULE_FIELD_ID in NUMBER,
  X_FIELD_COLUMN_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SUBSTRING_LENGTH in NUMBER,
  X_WEIGHTAGE in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_LIST_RULE_ID in NUMBER,
  X_FIELD_TABLE_NAME in VARCHAR2
) is
  cursor c1 is select
      FIELD_COLUMN_NAME,
      OBJECT_VERSION_NUMBER,
      SUBSTRING_LENGTH,
      WEIGHTAGE,
      SEQUENCE_NUMBER,
      LIST_RULE_ID,
      FIELD_TABLE_NAME
    from AMS_LIST_RULE_FIELDS
    where LIST_RULE_FIELD_ID = X_LIST_RULE_FIELD_ID
    for update of LIST_RULE_FIELD_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.FIELD_TABLE_NAME = X_FIELD_TABLE_NAME)
          AND (tlinfo.FIELD_COLUMN_NAME = X_FIELD_COLUMN_NAME)
          AND ((tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
               OR ((tlinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
          AND ((tlinfo.SUBSTRING_LENGTH = X_SUBSTRING_LENGTH)
               OR ((tlinfo.SUBSTRING_LENGTH is null) AND (X_SUBSTRING_LENGTH is null)))
          AND ((tlinfo.WEIGHTAGE = X_WEIGHTAGE)
               OR ((tlinfo.WEIGHTAGE is null) AND (X_WEIGHTAGE is null)))
          AND ((tlinfo.SEQUENCE_NUMBER = X_SEQUENCE_NUMBER)
               OR ((tlinfo.SEQUENCE_NUMBER is null) AND (X_SEQUENCE_NUMBER is null)))
          AND (tlinfo.LIST_RULE_ID = X_LIST_RULE_ID)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;
  return;
end LOCK_FIELD;

procedure UPDATE_FIELD (
  X_LIST_RULE_FIELD_ID in NUMBER,
  X_FIELD_COLUMN_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SUBSTRING_LENGTH in NUMBER,
  X_WEIGHTAGE in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_LIST_RULE_ID in NUMBER,
  X_FIELD_TABLE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  x_WORD_REPLACEMENT_CODE  in VARCHAR2,
  x_LIST_SOURCE_FIELD_ID in NUMBER
) is
begin
  update AMS_LIST_RULE_FIELDS set
    FIELD_COLUMN_NAME = X_FIELD_COLUMN_NAME,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    SUBSTRING_LENGTH = X_SUBSTRING_LENGTH,
    WEIGHTAGE = X_WEIGHTAGE,
    SEQUENCE_NUMBER = X_SEQUENCE_NUMBER,
    LIST_RULE_ID = X_LIST_RULE_ID,
    FIELD_TABLE_NAME = X_FIELD_TABLE_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    WORD_REPLACEMENT_CODE = x_WORD_REPLACEMENT_CODE,
    LIST_SOURCE_FIELD_ID = x_LIST_SOURCE_FIELD_ID
  where LIST_RULE_FIELD_ID = X_LIST_RULE_FIELD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_FIELD;

procedure DELETE_FIELD (
  X_LIST_RULE_FIELD_ID in NUMBER
) is
begin
  delete from AMS_LIST_RULE_FIELDS
  where LIST_RULE_FIELD_ID = X_LIST_RULE_FIELD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_FIELD;

PROCEDURE load_field (
  X_LIST_RULE_FIELD_ID in NUMBER,
  X_FIELD_COLUMN_NAME in VARCHAR2,
  X_SUBSTRING_LENGTH in NUMBER,
  X_WEIGHTAGE in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_LIST_RULE_ID in NUMBER,
  X_FIELD_TABLE_NAME in VARCHAR2,
  x_owner IN VARCHAR2,
  x_WORD_REPLACEMENT_CODE  in VARCHAR2,
  x_LIST_SOURCE_FIELD_ID in NUMBER,
  x_custom_mode IN VARCHAR2

)
IS
   l_user_id   number := 0;
   l_obj_verno  number;
   l_dummy_char  varchar2(1);
   l_row_id    varchar2(100);
   l_list_rule_field_id   number;
   l_last_updated_by number;

   CURSOR  c_obj_verno IS
     SELECT object_version_number, last_updated_by
     FROM   ams_list_rule_fields
     WHERE  list_rule_field_id =  x_list_rule_field_id;

   CURSOR c_chk_exists is
     SELECT 'x'
     FROM   ams_list_rule_fields
     WHERE  list_rule_field_id = x_list_rule_field_id;

   CURSOR c_mod_rule is
     SELECT  'x'
     FROM   ams_list_rule_fields
     WHERE  LIST_RULE_ID = X_LIST_RULE_ID
       AND  LAST_UPDATED_BY     <> 1 and last_updated_by <> 2 and last_updated_by <> 0;

   CURSOR c_get_id is
      SELECT ams_list_rule_fields_s.NEXTVAL
      FROM DUAL;
l_dummy_rule_char varchar2(1);
BEGIN
   if X_OWNER = 'SEED' then
      l_user_id := 1;
     elsif X_OWNER = 'ORACLE' then
        l_user_id := 2;
    elsif X_OWNER = 'SYSADMIN' THEN
       l_user_id := 0;

   end if;

OPEN c_mod_rule ;
FETCH c_mod_rule INTO l_dummy_rule_char;
IF c_mod_rule%notfound THEN
 CLOSE c_mod_rule;
   OPEN c_chk_exists;
   FETCH c_chk_exists INTO l_dummy_char;
   IF c_chk_exists%notfound THEN
      CLOSE c_chk_exists;

      IF x_list_rule_id IS NULL THEN
         OPEN c_get_id;
         FETCH c_get_id INTO l_list_rule_field_id;
         CLOSE c_get_id;
      ELSE
         l_list_rule_field_id := x_list_rule_field_id;
      END IF;
      l_obj_verno := 1;

      ams_list_rules_pkg.Insert_Field (
         X_ROWID                 => l_row_id,
         X_LIST_RULE_FIELD_ID    => l_list_rule_field_id,
         X_FIELD_COLUMN_NAME     => x_field_column_name,
         X_OBJECT_VERSION_NUMBER => l_obj_verno,
         X_SUBSTRING_LENGTH      => x_substring_length,
         X_WEIGHTAGE             => x_weightage,
         X_SEQUENCE_NUMBER       => x_sequence_number,
         X_LIST_RULE_ID          => x_list_rule_id,
         X_FIELD_TABLE_NAME      => x_field_table_name,
         X_CREATION_DATE         => SYSDATE,
         X_CREATED_BY            => l_user_id,
         X_LAST_UPDATE_DATE      => SYSDATE,
         X_LAST_UPDATED_BY       => l_user_id,
         X_LAST_UPDATE_LOGIN     => 0,
         x_WORD_REPLACEMENT_CODE => x_WORD_REPLACEMENT_CODE,
         x_LIST_SOURCE_FIELD_ID  => x_LIST_SOURCE_FIELD_ID
      );
   ELSE
      CLOSE c_chk_exists;
      OPEN c_obj_verno;
      FETCH c_obj_verno INTO l_obj_verno, l_last_updated_by;
      CLOSE c_obj_verno;

 if (l_last_updated_by in (1,2,0) OR
          NVL(x_custom_mode,'PRESERVE')='FORCE') THEN

      ams_list_rules_pkg.Update_Field (
         X_LIST_RULE_FIELD_ID    => x_list_rule_field_id,
         X_FIELD_COLUMN_NAME     => x_field_column_name,
         X_OBJECT_VERSION_NUMBER => l_obj_verno,
         X_SUBSTRING_LENGTH      => x_substring_length,
         X_WEIGHTAGE             => x_weightage,
         X_SEQUENCE_NUMBER       => x_sequence_number,
         X_LIST_RULE_ID          => x_list_rule_id,
         X_FIELD_TABLE_NAME      => x_field_table_name,
         X_LAST_UPDATE_DATE      => SYSDATE,
         X_LAST_UPDATED_BY       => l_user_id,
         X_LAST_UPDATE_LOGIN     => 0,
         x_WORD_REPLACEMENT_CODE => x_WORD_REPLACEMENT_CODE,
         x_LIST_SOURCE_FIELD_ID  => x_LIST_SOURCE_FIELD_ID
      );
   END IF;

   end if;
ELSE
 CLOSE c_mod_rule;
END IF;

END load_field;


PROCEDURE TRANSLATE_FIELD (
  X_LIST_RULE_FIELD_ID            IN NUMBER,
  X_OWNER                   IN VARCHAR2,
  x_custom_mode 	    IN VARCHAR2

) IS
BEGIN
    -- There is no _TL table, so nothing to translate
    NULL;
END TRANSLATE_FIELD;



end ams_list_rules_pkg;

/
