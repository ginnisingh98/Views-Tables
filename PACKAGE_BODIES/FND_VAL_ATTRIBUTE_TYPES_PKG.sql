--------------------------------------------------------
--  DDL for Package Body FND_VAL_ATTRIBUTE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_VAL_ATTRIBUTE_TYPES_PKG" as
/* $Header: AFFFVATB.pls 120.2.12010000.1 2008/07/25 14:14:45 appldev ship $ */

procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_SEGMENT_ATTRIBUTE_TYPE in VARCHAR2,
  X_VALUE_ATTRIBUTE_TYPE in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_APPLICATION_COLUMN_NAME in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_DERIVATION_RULE_CODE in VARCHAR2,
  X_DERIVATION_RULE_VALUE1 in VARCHAR2,
  X_DERIVATION_RULE_VALUE2 in VARCHAR2,
  X_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_VALUE_ATTRIBUTE_TYPES
    where APPLICATION_ID = X_APPLICATION_ID
    and ID_FLEX_CODE = X_ID_FLEX_CODE
    and SEGMENT_ATTRIBUTE_TYPE = X_SEGMENT_ATTRIBUTE_TYPE
    and VALUE_ATTRIBUTE_TYPE = X_VALUE_ATTRIBUTE_TYPE
    ;
begin
  insert into FND_VALUE_ATTRIBUTE_TYPES (
    APPLICATION_ID,
    ID_FLEX_CODE,
    SEGMENT_ATTRIBUTE_TYPE,
    VALUE_ATTRIBUTE_TYPE,
    REQUIRED_FLAG,
    APPLICATION_COLUMN_NAME,
    DEFAULT_VALUE,
    LOOKUP_TYPE,
    DERIVATION_RULE_CODE,
    DERIVATION_RULE_VALUE1,
    DERIVATION_RULE_VALUE2,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_ID_FLEX_CODE,
    X_SEGMENT_ATTRIBUTE_TYPE,
    X_VALUE_ATTRIBUTE_TYPE,
    X_REQUIRED_FLAG,
    X_APPLICATION_COLUMN_NAME,
    X_DEFAULT_VALUE,
    X_LOOKUP_TYPE,
    X_DERIVATION_RULE_CODE,
    X_DERIVATION_RULE_VALUE1,
    X_DERIVATION_RULE_VALUE2,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_VAL_ATTRIBUTE_TYPES_TL (
    APPLICATION_ID,
    ID_FLEX_CODE,
    SEGMENT_ATTRIBUTE_TYPE,
    VALUE_ATTRIBUTE_TYPE,
    PROMPT,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_ID_FLEX_CODE,
    X_SEGMENT_ATTRIBUTE_TYPE,
    X_VALUE_ATTRIBUTE_TYPE,
    X_PROMPT,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_VAL_ATTRIBUTE_TYPES_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.ID_FLEX_CODE = X_ID_FLEX_CODE
    and T.SEGMENT_ATTRIBUTE_TYPE = X_SEGMENT_ATTRIBUTE_TYPE
    and T.VALUE_ATTRIBUTE_TYPE = X_VALUE_ATTRIBUTE_TYPE
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
  X_ID_FLEX_CODE in VARCHAR2,
  X_SEGMENT_ATTRIBUTE_TYPE in VARCHAR2,
  X_VALUE_ATTRIBUTE_TYPE in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_APPLICATION_COLUMN_NAME in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_DERIVATION_RULE_CODE in VARCHAR2,
  X_DERIVATION_RULE_VALUE1 in VARCHAR2,
  X_DERIVATION_RULE_VALUE2 in VARCHAR2,
  X_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      REQUIRED_FLAG,
      APPLICATION_COLUMN_NAME,
      DEFAULT_VALUE,
      LOOKUP_TYPE,
      DERIVATION_RULE_CODE,
      DERIVATION_RULE_VALUE1,
      DERIVATION_RULE_VALUE2
    from FND_VALUE_ATTRIBUTE_TYPES
    where APPLICATION_ID = X_APPLICATION_ID
    and ID_FLEX_CODE = X_ID_FLEX_CODE
    and SEGMENT_ATTRIBUTE_TYPE = X_SEGMENT_ATTRIBUTE_TYPE
    and VALUE_ATTRIBUTE_TYPE = X_VALUE_ATTRIBUTE_TYPE
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      PROMPT,
      DESCRIPTION
    from FND_VAL_ATTRIBUTE_TYPES_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and ID_FLEX_CODE = X_ID_FLEX_CODE
    and SEGMENT_ATTRIBUTE_TYPE = X_SEGMENT_ATTRIBUTE_TYPE
    and VALUE_ATTRIBUTE_TYPE = X_VALUE_ATTRIBUTE_TYPE
    and LANGUAGE = userenv('LANG')
    for update of APPLICATION_ID nowait;
  tlinfo c1%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.REQUIRED_FLAG = X_REQUIRED_FLAG)
      AND (recinfo.APPLICATION_COLUMN_NAME = X_APPLICATION_COLUMN_NAME)
      AND ((recinfo.DEFAULT_VALUE = X_DEFAULT_VALUE)
           OR ((recinfo.DEFAULT_VALUE is null) AND (X_DEFAULT_VALUE is null)))
      AND ((recinfo.LOOKUP_TYPE = X_LOOKUP_TYPE)
           OR ((recinfo.LOOKUP_TYPE is null) AND (X_LOOKUP_TYPE is null)))
      AND ((recinfo.DERIVATION_RULE_CODE = X_DERIVATION_RULE_CODE)
           OR ((recinfo.DERIVATION_RULE_CODE is null) AND (X_DERIVATION_RULE_CODE is null)))
      AND ((recinfo.DERIVATION_RULE_VALUE1 = X_DERIVATION_RULE_VALUE1)
           OR ((recinfo.DERIVATION_RULE_VALUE1 is null) AND (X_DERIVATION_RULE_VALUE1 is null)))
      AND ((recinfo.DERIVATION_RULE_VALUE2 = X_DERIVATION_RULE_VALUE2)
           OR ((recinfo.DERIVATION_RULE_VALUE2 is null) AND (X_DERIVATION_RULE_VALUE2 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    return;
  end if;
  close c1;

  if (    (tlinfo.PROMPT = X_PROMPT)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_SEGMENT_ATTRIBUTE_TYPE in VARCHAR2,
  X_VALUE_ATTRIBUTE_TYPE in VARCHAR2,
  X_REQUIRED_FLAG in VARCHAR2,
  X_APPLICATION_COLUMN_NAME in VARCHAR2,
  X_DEFAULT_VALUE in VARCHAR2,
  X_LOOKUP_TYPE in VARCHAR2,
  X_DERIVATION_RULE_CODE in VARCHAR2,
  X_DERIVATION_RULE_VALUE1 in VARCHAR2,
  X_DERIVATION_RULE_VALUE2 in VARCHAR2,
  X_PROMPT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_VALUE_ATTRIBUTE_TYPES set
    REQUIRED_FLAG = X_REQUIRED_FLAG,
    APPLICATION_COLUMN_NAME = X_APPLICATION_COLUMN_NAME,
    DEFAULT_VALUE = X_DEFAULT_VALUE,
    LOOKUP_TYPE = X_LOOKUP_TYPE,
    DERIVATION_RULE_CODE = X_DERIVATION_RULE_CODE,
    DERIVATION_RULE_VALUE1 = X_DERIVATION_RULE_VALUE1,
    DERIVATION_RULE_VALUE2 = X_DERIVATION_RULE_VALUE2,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and ID_FLEX_CODE = X_ID_FLEX_CODE
  and SEGMENT_ATTRIBUTE_TYPE = X_SEGMENT_ATTRIBUTE_TYPE
  and VALUE_ATTRIBUTE_TYPE = X_VALUE_ATTRIBUTE_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_VAL_ATTRIBUTE_TYPES_TL set
    PROMPT = X_PROMPT,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and ID_FLEX_CODE = X_ID_FLEX_CODE
  and SEGMENT_ATTRIBUTE_TYPE = X_SEGMENT_ATTRIBUTE_TYPE
  and VALUE_ATTRIBUTE_TYPE = X_VALUE_ATTRIBUTE_TYPE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_SEGMENT_ATTRIBUTE_TYPE in VARCHAR2,
  X_VALUE_ATTRIBUTE_TYPE in VARCHAR2
) is
begin
  delete from FND_VALUE_ATTRIBUTE_TYPES
  where APPLICATION_ID = X_APPLICATION_ID
  and ID_FLEX_CODE = X_ID_FLEX_CODE
  and SEGMENT_ATTRIBUTE_TYPE = X_SEGMENT_ATTRIBUTE_TYPE
  and VALUE_ATTRIBUTE_TYPE = X_VALUE_ATTRIBUTE_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_VAL_ATTRIBUTE_TYPES_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and ID_FLEX_CODE = X_ID_FLEX_CODE
  and SEGMENT_ATTRIBUTE_TYPE = X_SEGMENT_ATTRIBUTE_TYPE
  and VALUE_ATTRIBUTE_TYPE = X_VALUE_ATTRIBUTE_TYPE;

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

   delete from FND_VAL_ATTRIBUTE_TYPES_TL T
   where not exists
     (select NULL
     from FND_VALUE_ATTRIBUTE_TYPES B
     where B.APPLICATION_ID = T.APPLICATION_ID
     and B.ID_FLEX_CODE = T.ID_FLEX_CODE
     and B.SEGMENT_ATTRIBUTE_TYPE = T.SEGMENT_ATTRIBUTE_TYPE
     and B.VALUE_ATTRIBUTE_TYPE = T.VALUE_ATTRIBUTE_TYPE
     );

   update FND_VAL_ATTRIBUTE_TYPES_TL T set (
       PROMPT,
       DESCRIPTION
     ) = (select
       B.PROMPT,
       B.DESCRIPTION
     from FND_VAL_ATTRIBUTE_TYPES_TL B
     where B.APPLICATION_ID = T.APPLICATION_ID
     and B.ID_FLEX_CODE = T.ID_FLEX_CODE
     and B.SEGMENT_ATTRIBUTE_TYPE = T.SEGMENT_ATTRIBUTE_TYPE
     and B.VALUE_ATTRIBUTE_TYPE = T.VALUE_ATTRIBUTE_TYPE
     and B.LANGUAGE = T.SOURCE_LANG)
   where (
       T.APPLICATION_ID,
       T.ID_FLEX_CODE,
       T.SEGMENT_ATTRIBUTE_TYPE,
       T.VALUE_ATTRIBUTE_TYPE,
       T.LANGUAGE
   ) in (select
       SUBT.APPLICATION_ID,
       SUBT.ID_FLEX_CODE,
       SUBT.SEGMENT_ATTRIBUTE_TYPE,
       SUBT.VALUE_ATTRIBUTE_TYPE,
       SUBT.LANGUAGE
     from FND_VAL_ATTRIBUTE_TYPES_TL SUBB, FND_VAL_ATTRIBUTE_TYPES_TL SUBT
     where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
     and SUBB.ID_FLEX_CODE = SUBT.ID_FLEX_CODE
     and SUBB.SEGMENT_ATTRIBUTE_TYPE = SUBT.SEGMENT_ATTRIBUTE_TYPE
     and SUBB.VALUE_ATTRIBUTE_TYPE = SUBT.VALUE_ATTRIBUTE_TYPE
     and SUBB.LANGUAGE = SUBT.SOURCE_LANG
     and (SUBB.PROMPT <> SUBT.PROMPT
       or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
       or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
       or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
   ));
*/

   insert into FND_VAL_ATTRIBUTE_TYPES_TL (
     APPLICATION_ID,
     ID_FLEX_CODE,
     SEGMENT_ATTRIBUTE_TYPE,
     VALUE_ATTRIBUTE_TYPE,
     PROMPT,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_LOGIN,
     DESCRIPTION,
     LANGUAGE,
     SOURCE_LANG
   ) select
     B.APPLICATION_ID,
     B.ID_FLEX_CODE,
     B.SEGMENT_ATTRIBUTE_TYPE,
     B.VALUE_ATTRIBUTE_TYPE,
     B.PROMPT,
     B.LAST_UPDATE_DATE,
     B.LAST_UPDATED_BY,
     B.CREATION_DATE,
     B.CREATED_BY,
     B.LAST_UPDATE_LOGIN,
     B.DESCRIPTION,
     L.LANGUAGE_CODE,
     B.SOURCE_LANG
   from FND_VAL_ATTRIBUTE_TYPES_TL B, FND_LANGUAGES L
   where L.INSTALLED_FLAG in ('I', 'B')
   and B.LANGUAGE = userenv('LANG')
   and not exists
     (select NULL
     from FND_VAL_ATTRIBUTE_TYPES_TL T
     where T.APPLICATION_ID = B.APPLICATION_ID
     and T.ID_FLEX_CODE = B.ID_FLEX_CODE
     and T.SEGMENT_ATTRIBUTE_TYPE = B.SEGMENT_ATTRIBUTE_TYPE
     and T.VALUE_ATTRIBUTE_TYPE = B.VALUE_ATTRIBUTE_TYPE
     and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE load_row
  (x_application_short_name       IN VARCHAR2,
   x_id_flex_code                 IN VARCHAR2,
   x_segment_attribute_type       IN VARCHAR2,
   x_value_attribute_type         IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_required_flag                IN VARCHAR2,
   x_application_column_name      IN VARCHAR2,
   x_default_value                IN VARCHAR2,
   x_lookup_type                  IN VARCHAR2,
   x_derivation_rule_code         IN VARCHAR2,
   x_derivation_rule_value1       IN VARCHAR2,
   x_derivation_rule_value2       IN VARCHAR2,
   x_prompt                       IN VARCHAR2,
   x_description                  IN VARCHAR2)
  IS
     l_application_id    NUMBER;
     l_rowid             VARCHAR2(64);
BEGIN
   SELECT application_id
     INTO l_application_id
     FROM fnd_application
     WHERE application_short_name = x_application_short_name;

   BEGIN
      fnd_val_attribute_types_pkg.update_row
	(X_APPLICATION_ID               => l_application_id,
	 X_ID_FLEX_CODE                 => x_id_flex_code,
	 X_SEGMENT_ATTRIBUTE_TYPE       => x_segment_attribute_type,
	 X_VALUE_ATTRIBUTE_TYPE         => x_value_attribute_type,
	 X_REQUIRED_FLAG                => x_required_flag,
	 X_APPLICATION_COLUMN_NAME      => x_application_column_name,
	 X_DEFAULT_VALUE                => x_default_value,
	 X_LOOKUP_TYPE                  => x_lookup_type,
	 X_DERIVATION_RULE_CODE         => x_derivation_rule_code,
	 X_DERIVATION_RULE_VALUE1       => x_derivation_rule_value1,
	 X_DERIVATION_RULE_VALUE2       => x_derivation_rule_value2,
	 X_PROMPT                       => x_prompt,
	 X_DESCRIPTION                  => x_description,
	 X_LAST_UPDATE_DATE             => x_who.last_update_date,
	 X_LAST_UPDATED_BY              => x_who.last_updated_by,
	 X_LAST_UPDATE_LOGIN            => x_who.last_update_login);
   EXCEPTION
      WHEN no_data_found THEN
	 fnd_val_attribute_types_pkg.insert_row
	   (X_ROWID                        => l_rowid,
	    X_APPLICATION_ID               => l_application_id,
	    X_ID_FLEX_CODE                 => x_id_flex_code,
	    X_SEGMENT_ATTRIBUTE_TYPE       => x_segment_attribute_type,
	    X_VALUE_ATTRIBUTE_TYPE         => x_value_attribute_type,
	    X_REQUIRED_FLAG                => x_required_flag,
	    X_APPLICATION_COLUMN_NAME      => x_application_column_name,
	    X_DEFAULT_VALUE                => x_default_value,
	    X_LOOKUP_TYPE                  => x_lookup_type,
	    X_DERIVATION_RULE_CODE         => x_derivation_rule_code,
	    X_DERIVATION_RULE_VALUE1       => x_derivation_rule_value1,
	    X_DERIVATION_RULE_VALUE2       => x_derivation_rule_value2,
	    X_PROMPT                       => x_prompt,
	    X_DESCRIPTION                  => x_description,
	    X_CREATION_DATE                => x_who.creation_date,
  	    X_CREATED_BY                   => x_who.created_by,
	    X_LAST_UPDATE_DATE             => x_who.last_update_date,
	    X_LAST_UPDATED_BY              => x_who.last_updated_by,
	    X_LAST_UPDATE_LOGIN            => x_who.last_update_login);
   END;
END load_row;

PROCEDURE translate_row
  (x_application_short_name       IN VARCHAR2,
   x_id_flex_code                 IN VARCHAR2,
   x_segment_attribute_type       IN VARCHAR2,
   x_value_attribute_type         IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_prompt                       IN VARCHAR2,
   x_description                  IN VARCHAR2)
  IS
BEGIN
   UPDATE fnd_val_attribute_types_tl SET
     prompt             = Nvl(x_prompt, prompt),
     description        = Nvl(x_description, description),
     last_update_date   = x_who.last_update_date,
     last_updated_by    = x_who.last_updated_by,
     last_update_login  = x_who.last_update_login,
     source_lang        = userenv('LANG')
     WHERE application_id = (SELECT application_id
			     FROM fnd_application
			     WHERE application_short_name = x_application_short_name)
     AND id_flex_code = x_id_flex_code
     AND segment_attribute_type = x_segment_attribute_type
     AND value_attribute_type = x_value_attribute_type
     AND userenv('LANG') in (language, source_lang);
END translate_row;

end FND_VAL_ATTRIBUTE_TYPES_PKG;

/
