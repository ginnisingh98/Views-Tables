--------------------------------------------------------
--  DDL for Package Body FND_DESCRIPTIVE_FLEXS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DESCRIPTIVE_FLEXS_PKG" as
/* $Header: AFFFDFFB.pls 120.11.12010000.2 2016/12/13 22:05:23 hgeorgi ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME in VARCHAR2,
  X_CONCATENATED_SEGS_VIEW_NAME in VARCHAR2,
  X_APPLICATION_TABLE_NAME in VARCHAR2,
  X_TABLE_APPLICATION_ID in NUMBER,
  X_CONTEXT_REQUIRED_FLAG in VARCHAR2,
  X_CONTEXT_COLUMN_NAME in VARCHAR2,
  X_CONTEXT_USER_OVERRIDE_FLAG in VARCHAR2,
  X_CONCATENATED_SEGMENT_DELIMIT in VARCHAR2,
  X_FREEZE_FLEX_DEFINITION_FLAG in VARCHAR2,
  X_PROTECTED_FLAG in VARCHAR2,
  X_DEFAULT_CONTEXT_FIELD_NAME in VARCHAR2,
  X_DEFAULT_CONTEXT_VALUE in VARCHAR2,
  X_CONTEXT_DEFAULT_TYPE in VARCHAR2,
  X_CONTEXT_DEFAULT_VALUE in VARCHAR2,
  X_CONTEXT_OVERRIDE_VALUE_SET_I in NUMBER,
  X_CONTEXT_RUNTIME_PROPERTY_FUN in VARCHAR2,
  X_CONTEXT_SYNCHRONIZATION_FLAG in VARCHAR2 DEFAULT NULL,
  X_TITLE in VARCHAR2,
  X_FORM_CONTEXT_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER /*,
  X_CONTEXT_SEGMENT_INSERT_FLAG in VARCHAR2,
  X_CONTEXT_SEGMENT_UPDATE_FLAG in VARCHAR2 */
) is
  cursor C is select ROWID from FND_DESCRIPTIVE_FLEXS
    where APPLICATION_ID = X_APPLICATION_ID
    and DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME
    ;

  l_context_synchronization_flag	VARCHAR2(1);
begin
  IF X_CONTEXT_SYNCHRONIZATION_FLAG IS NULL THEN
    IF ( SUBSTR(X_DESCRIPTIVE_FLEXFIELD_NAME, 1, 6) = '$SRS$.' ) THEN
      l_context_synchronization_flag := 'N';
    ELSE
      l_context_synchronization_flag := 'X';
    END IF;
  ELSE
    l_context_synchronization_flag := X_CONTEXT_SYNCHRONIZATION_FLAG;
  END IF;
  insert into FND_DESCRIPTIVE_FLEXS (
    CONCATENATED_SEGS_VIEW_NAME,
    APPLICATION_ID,
    APPLICATION_TABLE_NAME,
    DESCRIPTIVE_FLEXFIELD_NAME,
    TABLE_APPLICATION_ID,
    CONTEXT_REQUIRED_FLAG,
    CONTEXT_COLUMN_NAME,
    CONTEXT_USER_OVERRIDE_FLAG,
    CONCATENATED_SEGMENT_DELIMITER,
    FREEZE_FLEX_DEFINITION_FLAG,
    PROTECTED_FLAG,
    DEFAULT_CONTEXT_FIELD_NAME,
    DEFAULT_CONTEXT_VALUE,
    CONTEXT_DEFAULT_TYPE,
    CONTEXT_DEFAULT_VALUE,
    CONTEXT_OVERRIDE_VALUE_SET_ID,
    CONTEXT_RUNTIME_PROPERTY_FUNCT,
    CONTEXT_SYNCHRONIZATION_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN /*,
    CONTEXT_SEGMENT_INSERT_FLAG,
    CONTEXT_SEGMENT_UPDATE_FLAG */
  ) values (
    X_CONCATENATED_SEGS_VIEW_NAME,
    X_APPLICATION_ID,
    X_APPLICATION_TABLE_NAME,
    X_DESCRIPTIVE_FLEXFIELD_NAME,
    X_TABLE_APPLICATION_ID,
    X_CONTEXT_REQUIRED_FLAG,
    X_CONTEXT_COLUMN_NAME,
    X_CONTEXT_USER_OVERRIDE_FLAG,
    X_CONCATENATED_SEGMENT_DELIMIT,
    X_FREEZE_FLEX_DEFINITION_FLAG,
    X_PROTECTED_FLAG,
    X_DEFAULT_CONTEXT_FIELD_NAME,
    X_DEFAULT_CONTEXT_VALUE,
    X_CONTEXT_DEFAULT_TYPE,
    X_CONTEXT_DEFAULT_VALUE,
    X_CONTEXT_OVERRIDE_VALUE_SET_I,
    X_CONTEXT_RUNTIME_PROPERTY_FUN,
    l_context_synchronization_flag,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN /*,
    X_CONTEXT_SEGMENT_INSERT_FLAG,
    X_CONTEXT_SEGMENT_UPDATE_FLAG */
  );

  insert into FND_DESCRIPTIVE_FLEXS_TL (
    APPLICATION_ID,
    DESCRIPTIVE_FLEXFIELD_NAME,
    TITLE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    FORM_CONTEXT_PROMPT,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_DESCRIPTIVE_FLEXFIELD_NAME,
    X_TITLE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_FORM_CONTEXT_PROMPT,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_DESCRIPTIVE_FLEXS_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME
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
  X_APPLICATION_ID in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME in VARCHAR2,
  X_CONCATENATED_SEGS_VIEW_NAME in VARCHAR2,
  X_APPLICATION_TABLE_NAME in VARCHAR2,
  X_TABLE_APPLICATION_ID in NUMBER,
  X_CONTEXT_REQUIRED_FLAG in VARCHAR2,
  X_CONTEXT_COLUMN_NAME in VARCHAR2,
  X_CONTEXT_USER_OVERRIDE_FLAG in VARCHAR2,
  X_CONCATENATED_SEGMENT_DELIMIT in VARCHAR2,
  X_FREEZE_FLEX_DEFINITION_FLAG in VARCHAR2,
  X_PROTECTED_FLAG in VARCHAR2,
  X_DEFAULT_CONTEXT_FIELD_NAME in VARCHAR2,
  X_DEFAULT_CONTEXT_VALUE in VARCHAR2,
  X_CONTEXT_DEFAULT_TYPE in VARCHAR2,
  X_CONTEXT_DEFAULT_VALUE in VARCHAR2,
  X_CONTEXT_OVERRIDE_VALUE_SET_I in NUMBER,
  X_CONTEXT_RUNTIME_PROPERTY_FUN in VARCHAR2,
  X_CONTEXT_SYNCHRONIZATION_FLAG in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_FORM_CONTEXT_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2 /*,
  X_CONTEXT_SEGMENT_INSERT_FLAG in VARCHAR2,
  X_CONTEXT_SEGMENT_UPDATE_FLAG in VARCHAR2 */
) is
  cursor c is select
      CONCATENATED_SEGS_VIEW_NAME,
      APPLICATION_TABLE_NAME,
      TABLE_APPLICATION_ID,
      CONTEXT_REQUIRED_FLAG,
      CONTEXT_COLUMN_NAME,
      CONTEXT_USER_OVERRIDE_FLAG,
      CONCATENATED_SEGMENT_DELIMITER,
      FREEZE_FLEX_DEFINITION_FLAG,
      PROTECTED_FLAG,
      DEFAULT_CONTEXT_FIELD_NAME,
      DEFAULT_CONTEXT_VALUE,
      CONTEXT_DEFAULT_TYPE,
      CONTEXT_DEFAULT_VALUE,
      CONTEXT_OVERRIDE_VALUE_SET_ID,
      CONTEXT_RUNTIME_PROPERTY_FUNCT,
      CONTEXT_SYNCHRONIZATION_FLAG /*,
      CONTEXT_SEGMENT_INSERT_FLAG,
      CONTEXT_SEGMENT_UPDATE_FLAG */
    from FND_DESCRIPTIVE_FLEXS
    where APPLICATION_ID = X_APPLICATION_ID
    and DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TITLE,
      FORM_CONTEXT_PROMPT,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_DESCRIPTIVE_FLEXS_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of APPLICATION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.CONCATENATED_SEGS_VIEW_NAME = X_CONCATENATED_SEGS_VIEW_NAME)
           OR ((recinfo.CONCATENATED_SEGS_VIEW_NAME is null) AND (X_CONCATENATED_SEGS_VIEW_NAME is null)))
      AND (recinfo.APPLICATION_TABLE_NAME = X_APPLICATION_TABLE_NAME)
      AND (recinfo.TABLE_APPLICATION_ID = X_TABLE_APPLICATION_ID)
      AND (recinfo.CONTEXT_REQUIRED_FLAG = X_CONTEXT_REQUIRED_FLAG)
      AND (recinfo.CONTEXT_COLUMN_NAME = X_CONTEXT_COLUMN_NAME)
      AND (recinfo.CONTEXT_USER_OVERRIDE_FLAG = X_CONTEXT_USER_OVERRIDE_FLAG)
      AND (recinfo.CONCATENATED_SEGMENT_DELIMITER = X_CONCATENATED_SEGMENT_DELIMIT)
      AND (recinfo.FREEZE_FLEX_DEFINITION_FLAG = X_FREEZE_FLEX_DEFINITION_FLAG)
      AND (recinfo.PROTECTED_FLAG = X_PROTECTED_FLAG)
      AND ((recinfo.DEFAULT_CONTEXT_FIELD_NAME = X_DEFAULT_CONTEXT_FIELD_NAME)
           OR ((recinfo.DEFAULT_CONTEXT_FIELD_NAME is null) AND (X_DEFAULT_CONTEXT_FIELD_NAME is null)))
      AND ((recinfo.DEFAULT_CONTEXT_VALUE = X_DEFAULT_CONTEXT_VALUE)
           OR ((recinfo.DEFAULT_CONTEXT_VALUE is null) AND (X_DEFAULT_CONTEXT_VALUE is null)))
      AND ((recinfo.CONTEXT_DEFAULT_TYPE = X_CONTEXT_DEFAULT_TYPE)
           OR ((recinfo.CONTEXT_DEFAULT_TYPE is null) AND (X_CONTEXT_DEFAULT_TYPE is null)))
      AND ((recinfo.CONTEXT_DEFAULT_VALUE = X_CONTEXT_DEFAULT_VALUE)
           OR ((recinfo.CONTEXT_DEFAULT_VALUE is null) AND (X_CONTEXT_DEFAULT_VALUE is null)))
      AND ((recinfo.CONTEXT_OVERRIDE_VALUE_SET_ID = X_CONTEXT_OVERRIDE_VALUE_SET_I)
           OR ((recinfo.CONTEXT_OVERRIDE_VALUE_SET_ID is null) AND (X_CONTEXT_OVERRIDE_VALUE_SET_I is null)))
      AND ((recinfo.CONTEXT_RUNTIME_PROPERTY_FUNCT = X_CONTEXT_RUNTIME_PROPERTY_FUN)
           OR ((recinfo.CONTEXT_RUNTIME_PROPERTY_FUNCT is null) AND (X_CONTEXT_RUNTIME_PROPERTY_FUN is null)))
      AND ((recinfo.CONTEXT_SYNCHRONIZATION_FLAG = X_CONTEXT_SYNCHRONIZATION_FLAG)
	   OR ((recinfo.CONTEXT_SYNCHRONIZATION_FLAG is null) AND (X_CONTEXT_SYNCHRONIZATION_FLAG is null)))
/*
      AND ((recinfo.CONTEXT_SEGMENT_INSERT_FLAG = X_CONTEXT_SEGMENT_INSERT_FLAG)
	   OR ((recinfo.CONTEXT_SEGMENT_INSERT_FLAG is null) AND (X_CONTEXT_SEGMENT_INSERT_FLAG is null)))
      AND ((recinfo.CONTEXT_SEGMENT_UPDATE_FLAG = X_CONTEXT_SEGMENT_UPDATE_FLAG)
	   OR ((recinfo.CONTEXT_SEGMENT_UPDATE_FLAG is null) AND (X_CONTEXT_SEGMENT_UPDATE_FLAG is null)))
*/
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.TITLE = X_TITLE)
          AND (tlinfo.FORM_CONTEXT_PROMPT = X_FORM_CONTEXT_PROMPT)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME in VARCHAR2,
  X_CONCATENATED_SEGS_VIEW_NAME in VARCHAR2,
  X_APPLICATION_TABLE_NAME in VARCHAR2,
  X_TABLE_APPLICATION_ID in NUMBER,
  X_CONTEXT_REQUIRED_FLAG in VARCHAR2,
  X_CONTEXT_COLUMN_NAME in VARCHAR2,
  X_CONTEXT_USER_OVERRIDE_FLAG in VARCHAR2,
  X_CONCATENATED_SEGMENT_DELIMIT in VARCHAR2,
  X_FREEZE_FLEX_DEFINITION_FLAG in VARCHAR2,
  X_PROTECTED_FLAG in VARCHAR2,
  X_DEFAULT_CONTEXT_FIELD_NAME in VARCHAR2,
  X_DEFAULT_CONTEXT_VALUE in VARCHAR2,
  X_CONTEXT_DEFAULT_TYPE in VARCHAR2,
  X_CONTEXT_DEFAULT_VALUE in VARCHAR2,
  X_CONTEXT_OVERRIDE_VALUE_SET_I in NUMBER,
  X_CONTEXT_RUNTIME_PROPERTY_FUN in VARCHAR2,
  X_CONTEXT_SYNCHRONIZATION_FLAG in VARCHAR2 DEFAULT NULL,
  X_TITLE in VARCHAR2,
  X_FORM_CONTEXT_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER /*,
  X_CONTEXT_SEGMENT_INSERT_FLAG in VARCHAR2,
  X_CONTEXT_SEGMENT_UPDATE_FLAG in VARCHAR2 */
) is
  l_context_synchronization_flag	VARCHAR2(1);
begin
  IF X_CONTEXT_SYNCHRONIZATION_FLAG IS NULL THEN
    IF ( SUBSTR(X_DESCRIPTIVE_FLEXFIELD_NAME, 1, 6) = '$SRS$.' ) THEN
      l_context_synchronization_flag := 'N';
    ELSE
      l_context_synchronization_flag := 'X';
    END IF;
  ELSE
    l_context_synchronization_flag := X_CONTEXT_SYNCHRONIZATION_FLAG;
  END IF;
  update FND_DESCRIPTIVE_FLEXS set
    CONCATENATED_SEGS_VIEW_NAME = X_CONCATENATED_SEGS_VIEW_NAME,
    APPLICATION_TABLE_NAME = X_APPLICATION_TABLE_NAME,
    TABLE_APPLICATION_ID = X_TABLE_APPLICATION_ID,
    CONTEXT_REQUIRED_FLAG = X_CONTEXT_REQUIRED_FLAG,
    CONTEXT_COLUMN_NAME = X_CONTEXT_COLUMN_NAME,
    CONTEXT_USER_OVERRIDE_FLAG = X_CONTEXT_USER_OVERRIDE_FLAG,
    CONCATENATED_SEGMENT_DELIMITER = X_CONCATENATED_SEGMENT_DELIMIT,
    FREEZE_FLEX_DEFINITION_FLAG = X_FREEZE_FLEX_DEFINITION_FLAG,
    PROTECTED_FLAG = X_PROTECTED_FLAG,
    DEFAULT_CONTEXT_FIELD_NAME = X_DEFAULT_CONTEXT_FIELD_NAME,
    DEFAULT_CONTEXT_VALUE = X_DEFAULT_CONTEXT_VALUE,
    CONTEXT_DEFAULT_TYPE = X_CONTEXT_DEFAULT_TYPE,
    CONTEXT_DEFAULT_VALUE = X_CONTEXT_DEFAULT_VALUE,
    CONTEXT_OVERRIDE_VALUE_SET_ID = X_CONTEXT_OVERRIDE_VALUE_SET_I,
    CONTEXT_RUNTIME_PROPERTY_FUNCT = X_CONTEXT_RUNTIME_PROPERTY_FUN,
    CONTEXT_SYNCHRONIZATION_FLAG = l_context_synchronization_flag,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN /*,
    CONTEXT_SEGMENT_INSERT_FLAG = X_CONTEXT_SEGMENT_INSERT_FLAG,
    CONTEXT_SEGMENT_UPDATE_FLAG = X_CONTEXT_SEGMENT_UPDATE_FLAG */
  where APPLICATION_ID = X_APPLICATION_ID
  and DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_DESCRIPTIVE_FLEXS_TL set
    TITLE = X_TITLE,
    FORM_CONTEXT_PROMPT = X_FORM_CONTEXT_PROMPT,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME in VARCHAR2
) is
begin
  delete from FND_DESCRIPTIVE_FLEXS_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_DESCRIPTIVE_FLEXS
  where APPLICATION_ID = X_APPLICATION_ID
  and DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
 is
 begin

/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*
   delete from FND_DESCRIPTIVE_FLEXS_TL T
   where not exists
     (select NULL
     from FND_DESCRIPTIVE_FLEXS B
     where B.APPLICATION_ID = T.APPLICATION_ID
     and B.DESCRIPTIVE_FLEXFIELD_NAME = T.DESCRIPTIVE_FLEXFIELD_NAME
     );

   update FND_DESCRIPTIVE_FLEXS_TL T set (
       TITLE,
       FORM_CONTEXT_PROMPT,
       DESCRIPTION
     ) = (select
       B.TITLE,
       B.FORM_CONTEXT_PROMPT,
       B.DESCRIPTION
     from FND_DESCRIPTIVE_FLEXS_TL B
     where B.APPLICATION_ID = T.APPLICATION_ID
     and B.DESCRIPTIVE_FLEXFIELD_NAME = T.DESCRIPTIVE_FLEXFIELD_NAME
     and B.LANGUAGE = T.SOURCE_LANG)
   where (
       T.APPLICATION_ID,
       T.DESCRIPTIVE_FLEXFIELD_NAME,
       T.LANGUAGE
   ) in (select
       SUBT.APPLICATION_ID,
       SUBT.DESCRIPTIVE_FLEXFIELD_NAME,
       SUBT.LANGUAGE
     from FND_DESCRIPTIVE_FLEXS_TL SUBB, FND_DESCRIPTIVE_FLEXS_TL SUBT
     where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
     and SUBB.DESCRIPTIVE_FLEXFIELD_NAME = SUBT.DESCRIPTIVE_FLEXFIELD_NAME
     and SUBB.LANGUAGE = SUBT.SOURCE_LANG
     and (SUBB.TITLE <> SUBT.TITLE
       or SUBB.FORM_CONTEXT_PROMPT <> SUBT.FORM_CONTEXT_PROMPT
       or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
       or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
       or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
   ));
*/

  insert into FND_DESCRIPTIVE_FLEXS_TL (
    APPLICATION_ID,
    DESCRIPTIVE_FLEXFIELD_NAME,
    TITLE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    FORM_CONTEXT_PROMPT,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.APPLICATION_ID,
    B.DESCRIPTIVE_FLEXFIELD_NAME,
    B.TITLE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.FORM_CONTEXT_PROMPT,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_DESCRIPTIVE_FLEXS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_DESCRIPTIVE_FLEXS_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.DESCRIPTIVE_FLEXFIELD_NAME = B.DESCRIPTIVE_FLEXFIELD_NAME
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE load_row
  (x_application_short_name       IN VARCHAR2,
   x_descriptive_flexfield_name   IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_table_application_short_name IN VARCHAR2,
   x_application_table_name       IN VARCHAR2,
   x_concatenated_segs_view_name  IN VARCHAR2,
   x_context_required_flag        IN VARCHAR2,
   x_context_column_name          IN VARCHAR2,
   x_context_user_override_flag   IN VARCHAR2,
   x_concatenated_segment_delimit IN VARCHAR2,
   x_freeze_flex_definition_flag  IN VARCHAR2,
   x_protected_flag               IN VARCHAR2,
   x_default_context_field_name   IN VARCHAR2,
   x_default_context_value        IN VARCHAR2,
   x_context_default_type         IN VARCHAR2,
   x_context_default_value        IN VARCHAR2,
   x_context_override_value_set_n IN VARCHAR2,
   x_context_runtime_property_fun IN VARCHAR2,
   x_context_synchronization_flag IN VARCHAR2 DEFAULT NULL,
   x_title                        IN VARCHAR2,
   x_form_context_prompt          IN VARCHAR2,
   x_description                  IN VARCHAR2 /*,
   x_context_segment_insert_flag  IN VARCHAR2,
   x_context_segment_update_flag  IN VARCHAR2*/)
  IS
     l_application_id               NUMBER;
     l_table_application_id         NUMBER;
     l_rowid                        VARCHAR2(64);
     l_context_override_value_set_i NUMBER := NULL;
BEGIN
   SELECT application_id
     INTO l_application_id
     FROM fnd_application
     WHERE application_short_name = x_application_short_name;

   SELECT application_id
     INTO l_table_application_id
     FROM fnd_application
     WHERE application_short_name = x_table_application_short_name;

   IF (x_context_override_value_set_n IS NOT NULL) THEN
      SELECT flex_value_set_id
	INTO l_context_override_value_set_i
	FROM fnd_flex_value_sets
	WHERE flex_value_set_name = x_context_override_value_set_n;
   END IF;

   BEGIN
      fnd_descriptive_flexs_pkg.update_row
	(X_APPLICATION_ID               => l_application_id,
	 X_DESCRIPTIVE_FLEXFIELD_NAME   => x_descriptive_flexfield_name,
	 X_APPLICATION_TABLE_NAME       => x_application_table_name,
	 X_TABLE_APPLICATION_ID         => l_table_application_id,
         X_CONCATENATED_SEGS_VIEW_NAME  => x_concatenated_segs_view_name,
	 X_CONTEXT_REQUIRED_FLAG        => x_context_required_flag,
	 X_CONTEXT_COLUMN_NAME          => x_context_column_name,
	 X_CONTEXT_USER_OVERRIDE_FLAG   => x_context_user_override_flag,
	 X_CONCATENATED_SEGMENT_DELIMIT => x_concatenated_segment_delimit,
	 X_FREEZE_FLEX_DEFINITION_FLAG  => x_freeze_flex_definition_flag,
	 X_PROTECTED_FLAG               => x_protected_flag,
	 X_DEFAULT_CONTEXT_FIELD_NAME   => x_default_context_field_name,
	 X_DEFAULT_CONTEXT_VALUE        => x_default_context_value,
	 X_CONTEXT_DEFAULT_TYPE         => x_context_default_type,
	 X_CONTEXT_DEFAULT_VALUE        => x_context_default_value,
	 X_CONTEXT_OVERRIDE_VALUE_SET_I => l_context_override_value_set_i,
	 X_CONTEXT_RUNTIME_PROPERTY_FUN => x_context_runtime_property_fun,
	 X_CONTEXT_SYNCHRONIZATION_FLAG => x_context_synchronization_flag,
	 X_TITLE                        => x_title,
	 X_FORM_CONTEXT_PROMPT          => x_form_context_prompt,
	 X_DESCRIPTION                  => x_description,
	 X_LAST_UPDATE_DATE             => x_who.last_update_date,
	 X_LAST_UPDATED_BY              => x_who.last_updated_by,
	 X_LAST_UPDATE_LOGIN            => x_who.last_update_login /*,
         X_CONTEXT_SEGMENT_INSERT_FLAG  => x_context_segment_insert_flag,
         X_CONTEXT_SEGMENT_UPDATE_FLAG  => x_context_segment_update_flag*/);
   EXCEPTION
      WHEN no_data_found THEN
	 fnd_descriptive_flexs_pkg.insert_row
	   (X_ROWID                        => l_rowid,
	    X_APPLICATION_ID               => l_application_id,
	    X_DESCRIPTIVE_FLEXFIELD_NAME   => x_descriptive_flexfield_name,
	    X_APPLICATION_TABLE_NAME       => x_application_table_name,
	    X_TABLE_APPLICATION_ID         => l_table_application_id,
            X_CONCATENATED_SEGS_VIEW_NAME  => x_concatenated_segs_view_name,
	    X_CONTEXT_REQUIRED_FLAG        => x_context_required_flag,
	    X_CONTEXT_COLUMN_NAME          => x_context_column_name,
	    X_CONTEXT_USER_OVERRIDE_FLAG   => x_context_user_override_flag,
	    X_CONCATENATED_SEGMENT_DELIMIT => x_concatenated_segment_delimit,
	    X_FREEZE_FLEX_DEFINITION_FLAG  => x_freeze_flex_definition_flag,
	    X_PROTECTED_FLAG               => x_protected_flag,
	    X_DEFAULT_CONTEXT_FIELD_NAME   => x_default_context_field_name,
	    X_DEFAULT_CONTEXT_VALUE        => x_default_context_value,
	    X_CONTEXT_DEFAULT_TYPE         => x_context_default_type,
	    X_CONTEXT_DEFAULT_VALUE        => x_context_default_value,
	    X_CONTEXT_OVERRIDE_VALUE_SET_I => l_context_override_value_set_i,
	    X_CONTEXT_RUNTIME_PROPERTY_FUN => x_context_runtime_property_fun,
	    X_CONTEXT_SYNCHRONIZATION_FLAG => x_context_synchronization_flag,
	    X_TITLE                        => x_title,
	    X_FORM_CONTEXT_PROMPT          => x_form_context_prompt,
	    X_DESCRIPTION                  => x_description,
	    X_CREATION_DATE                => x_who.creation_date,
  	    X_CREATED_BY                   => x_who.created_by,
	    X_LAST_UPDATE_DATE             => x_who.last_update_date,
	    X_LAST_UPDATED_BY              => x_who.last_updated_by,
	    X_LAST_UPDATE_LOGIN            => x_who.last_update_login /*,
            X_CONTEXT_SEGMENT_INSERT_FLAG  => x_context_segment_insert_flag,
            X_CONTEXT_SEGMENT_UPDATE_FLAG  => x_context_segment_update_flag*/);
   END;
END load_row;

PROCEDURE translate_row
  (x_application_short_name       IN VARCHAR2,
   x_descriptive_flexfield_name   IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_title                        IN VARCHAR2,
   x_form_context_prompt          IN VARCHAR2,
   x_description                  IN VARCHAR2)
  IS
BEGIN
   UPDATE fnd_descriptive_flexs_tl SET
     title               = Nvl(x_title, title),
     form_context_prompt = Nvl(x_form_context_prompt, form_context_prompt),
     description         = Nvl(x_description, description),
     last_update_date    = x_who.last_update_date,
     last_updated_by     = x_who.last_updated_by,
     last_update_login   = x_who.last_update_login,
     source_lang         = userenv('LANG')
     WHERE application_id = (SELECT application_id
			     FROM fnd_application
			     WHERE application_short_name = x_application_short_name)
     AND descriptive_flexfield_name = x_descriptive_flexfield_name
     AND userenv('LANG') in (language, source_lang);
END translate_row;

end FND_DESCRIPTIVE_FLEXS_PKG;

/
