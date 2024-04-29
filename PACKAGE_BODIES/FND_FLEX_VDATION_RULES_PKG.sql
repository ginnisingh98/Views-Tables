--------------------------------------------------------
--  DDL for Package Body FND_FLEX_VDATION_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_VDATION_RULES_PKG" as
/* $Header: AFFFVDRB.pls 120.2.12010000.1 2008/07/25 14:14:48 appldev ship $ */

procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_ID_FLEX_NUM in NUMBER,
  X_FLEX_VALIDATION_RULE_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_ERROR_SEGMENT_COLUMN_NAME in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ERROR_MESSAGE_TEXT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_FLEX_VALIDATION_RULES
    where APPLICATION_ID = X_APPLICATION_ID
    and ID_FLEX_CODE = X_ID_FLEX_CODE
    and ID_FLEX_NUM = X_ID_FLEX_NUM
    and FLEX_VALIDATION_RULE_NAME = X_FLEX_VALIDATION_RULE_NAME
    ;
begin
  insert into FND_FLEX_VALIDATION_RULES (
    APPLICATION_ID,
    ID_FLEX_CODE,
    ID_FLEX_NUM,
    FLEX_VALIDATION_RULE_NAME,
    ENABLED_FLAG,
    ERROR_SEGMENT_COLUMN_NAME,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_ID_FLEX_CODE,
    X_ID_FLEX_NUM,
    X_FLEX_VALIDATION_RULE_NAME,
    X_ENABLED_FLAG,
    X_ERROR_SEGMENT_COLUMN_NAME,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_FLEX_VDATION_RULES_TL (
    DESCRIPTION,
    APPLICATION_ID,
    ID_FLEX_CODE,
    ID_FLEX_NUM,
    FLEX_VALIDATION_RULE_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    ERROR_MESSAGE_TEXT,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DESCRIPTION,
    X_APPLICATION_ID,
    X_ID_FLEX_CODE,
    X_ID_FLEX_NUM,
    X_FLEX_VALIDATION_RULE_NAME,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ERROR_MESSAGE_TEXT,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_FLEX_VDATION_RULES_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.ID_FLEX_CODE = X_ID_FLEX_CODE
    and T.ID_FLEX_NUM = X_ID_FLEX_NUM
    and T.FLEX_VALIDATION_RULE_NAME = X_FLEX_VALIDATION_RULE_NAME
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
  X_ID_FLEX_NUM in NUMBER,
  X_FLEX_VALIDATION_RULE_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_ERROR_SEGMENT_COLUMN_NAME in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ERROR_MESSAGE_TEXT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ENABLED_FLAG,
      ERROR_SEGMENT_COLUMN_NAME,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE
    from FND_FLEX_VALIDATION_RULES
    where APPLICATION_ID = X_APPLICATION_ID
    and ID_FLEX_CODE = X_ID_FLEX_CODE
    and ID_FLEX_NUM = X_ID_FLEX_NUM
    and FLEX_VALIDATION_RULE_NAME = X_FLEX_VALIDATION_RULE_NAME
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      ERROR_MESSAGE_TEXT,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_FLEX_VDATION_RULES_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and ID_FLEX_CODE = X_ID_FLEX_CODE
    and ID_FLEX_NUM = X_ID_FLEX_NUM
    and FLEX_VALIDATION_RULE_NAME = X_FLEX_VALIDATION_RULE_NAME
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
  if (    (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND ((recinfo.ERROR_SEGMENT_COLUMN_NAME = X_ERROR_SEGMENT_COLUMN_NAME)
           OR ((recinfo.ERROR_SEGMENT_COLUMN_NAME is null) AND (X_ERROR_SEGMENT_COLUMN_NAME is null)))
      AND ((recinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((recinfo.START_DATE_ACTIVE is null) AND (X_START_DATE_ACTIVE is null)))
      AND ((recinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((recinfo.END_DATE_ACTIVE is null) AND (X_END_DATE_ACTIVE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.ERROR_MESSAGE_TEXT = X_ERROR_MESSAGE_TEXT)
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
  X_ID_FLEX_CODE in VARCHAR2,
  X_ID_FLEX_NUM in NUMBER,
  X_FLEX_VALIDATION_RULE_NAME in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_ERROR_SEGMENT_COLUMN_NAME in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ERROR_MESSAGE_TEXT in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_FLEX_VALIDATION_RULES set
    ENABLED_FLAG = X_ENABLED_FLAG,
    ERROR_SEGMENT_COLUMN_NAME = X_ERROR_SEGMENT_COLUMN_NAME,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and ID_FLEX_CODE = X_ID_FLEX_CODE
  and ID_FLEX_NUM = X_ID_FLEX_NUM
  and FLEX_VALIDATION_RULE_NAME = X_FLEX_VALIDATION_RULE_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_FLEX_VDATION_RULES_TL set
    ERROR_MESSAGE_TEXT = X_ERROR_MESSAGE_TEXT,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and ID_FLEX_CODE = X_ID_FLEX_CODE
  and ID_FLEX_NUM = X_ID_FLEX_NUM
  and FLEX_VALIDATION_RULE_NAME = X_FLEX_VALIDATION_RULE_NAME
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_ID_FLEX_NUM in NUMBER,
  X_FLEX_VALIDATION_RULE_NAME in VARCHAR2
) is
begin
  delete from FND_FLEX_VDATION_RULES_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and ID_FLEX_CODE = X_ID_FLEX_CODE
  and ID_FLEX_NUM = X_ID_FLEX_NUM
  and FLEX_VALIDATION_RULE_NAME = X_FLEX_VALIDATION_RULE_NAME;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_FLEX_VALIDATION_RULES
  where APPLICATION_ID = X_APPLICATION_ID
  and ID_FLEX_CODE = X_ID_FLEX_CODE
  and ID_FLEX_NUM = X_ID_FLEX_NUM
  and FLEX_VALIDATION_RULE_NAME = X_FLEX_VALIDATION_RULE_NAME;

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

   delete from FND_FLEX_VDATION_RULES_TL T
   where not exists
     (select NULL
     from FND_FLEX_VALIDATION_RULES B
     where B.APPLICATION_ID = T.APPLICATION_ID
     and B.ID_FLEX_CODE = T.ID_FLEX_CODE
     and B.ID_FLEX_NUM = T.ID_FLEX_NUM
     and B.FLEX_VALIDATION_RULE_NAME = T.FLEX_VALIDATION_RULE_NAME
     );

   update FND_FLEX_VDATION_RULES_TL T set (
       ERROR_MESSAGE_TEXT,
       DESCRIPTION
     ) = (select
       B.ERROR_MESSAGE_TEXT,
       B.DESCRIPTION
     from FND_FLEX_VDATION_RULES_TL B
     where B.APPLICATION_ID = T.APPLICATION_ID
     and B.ID_FLEX_CODE = T.ID_FLEX_CODE
     and B.ID_FLEX_NUM = T.ID_FLEX_NUM
     and B.FLEX_VALIDATION_RULE_NAME = T.FLEX_VALIDATION_RULE_NAME
     and B.LANGUAGE = T.SOURCE_LANG)
   where (
       T.APPLICATION_ID,
       T.ID_FLEX_CODE,
       T.ID_FLEX_NUM,
       T.FLEX_VALIDATION_RULE_NAME,
       T.LANGUAGE
   ) in (select
       SUBT.APPLICATION_ID,
       SUBT.ID_FLEX_CODE,
       SUBT.ID_FLEX_NUM,
       SUBT.FLEX_VALIDATION_RULE_NAME,
       SUBT.LANGUAGE
     from FND_FLEX_VDATION_RULES_TL SUBB, FND_FLEX_VDATION_RULES_TL SUBT
     where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
     and SUBB.ID_FLEX_CODE = SUBT.ID_FLEX_CODE
     and SUBB.ID_FLEX_NUM = SUBT.ID_FLEX_NUM
     and SUBB.FLEX_VALIDATION_RULE_NAME = SUBT.FLEX_VALIDATION_RULE_NAME
     and SUBB.LANGUAGE = SUBT.SOURCE_LANG
     and (SUBB.ERROR_MESSAGE_TEXT <> SUBT.ERROR_MESSAGE_TEXT
       or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
       or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
       or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
   ));
*/

   insert /*+ append parallel(tt) */ into FND_FLEX_VDATION_RULES_TL tt (
     DESCRIPTION,
     APPLICATION_ID,
     ID_FLEX_CODE,
     ID_FLEX_NUM,
     FLEX_VALIDATION_RULE_NAME,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_LOGIN,
     ERROR_MESSAGE_TEXT,
     LANGUAGE,
     SOURCE_LANG
   )
     select /*+ parallel(v) parallel(t) use_nl(t) */ v.* from
     (select /*+ no_merge ordered parallel(b) */
     B.DESCRIPTION,
     B.APPLICATION_ID,
     B.ID_FLEX_CODE,
     B.ID_FLEX_NUM,
     B.FLEX_VALIDATION_RULE_NAME,
     B.LAST_UPDATE_DATE,
     B.LAST_UPDATED_BY,
     B.CREATION_DATE,
     B.CREATED_BY,
     B.LAST_UPDATE_LOGIN,
     B.ERROR_MESSAGE_TEXT,
     L.LANGUAGE_CODE,
     B.SOURCE_LANG
   from FND_FLEX_VDATION_RULES_TL B, FND_LANGUAGES L
   where L.INSTALLED_FLAG in ('I', 'B')
   and B.LANGUAGE = userenv('LANG')
   ) v, FND_FLEX_VDATION_RULES_TL t
   where t.application_id(+) = v.application_id
   and t.id_flex_code(+) = v.id_flex_code
   and t.id_flex_num(+) = v.id_flex_num
   and t.flex_validation_rule_name(+) = v.flex_validation_rule_name
   and t.language(+) = v.language_code
   and t.application_id is NULL
   and t.id_flex_code is NULL
   and t.id_flex_num is NULL
   and t.flex_validation_rule_name is NULL;

end ADD_LANGUAGE;

PROCEDURE load_row
  (x_application_short_name       IN VARCHAR2,
   x_id_flex_code                 IN VARCHAR2,
   x_id_flex_structure_code       IN VARCHAR2,
   x_flex_validation_rule_name    IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_enabled_flag                 IN VARCHAR2,
   x_error_segment_column_name    IN VARCHAR2,
   x_start_date_active            IN DATE,
   x_end_date_active              IN DATE,
   x_error_message_text           IN VARCHAR2,
   x_description                  IN VARCHAR2)
  IS
     l_application_id    NUMBER;
     l_id_flex_num       NUMBER;
     l_rowid             VARCHAR2(64);
BEGIN
   SELECT application_id
     INTO l_application_id
     FROM fnd_application
     WHERE application_short_name = x_application_short_name;

   SELECT id_flex_num
     INTO l_id_flex_num
     FROM fnd_id_flex_structures
     WHERE application_id = l_application_id
     AND id_flex_code = x_id_flex_code
     AND id_flex_structure_code = x_id_flex_structure_code;

   BEGIN
      fnd_flex_vdation_rules_pkg.update_row
	(X_APPLICATION_ID               => l_application_id,
	 X_ID_FLEX_CODE                 => x_id_flex_code,
	 X_ID_FLEX_NUM                  => l_id_flex_num,
	 X_FLEX_VALIDATION_RULE_NAME    => x_flex_validation_rule_name,
	 X_DESCRIPTION                  => x_description,
	 X_ENABLED_FLAG                 => x_enabled_flag,
	 X_ERROR_SEGMENT_COLUMN_NAME    => x_error_segment_column_name,
	 X_START_DATE_ACTIVE            => x_start_date_active,
	 X_END_DATE_ACTIVE              => x_end_date_active,
	 X_ERROR_MESSAGE_TEXT           => x_error_message_text,
	 X_LAST_UPDATE_DATE             => x_who.last_update_date,
	 X_LAST_UPDATED_BY              => x_who.last_updated_by,
	 X_LAST_UPDATE_LOGIN            => x_who.last_update_login);
   EXCEPTION
      WHEN no_data_found THEN
	 fnd_flex_vdation_rules_pkg.insert_row
	   (X_ROWID                        => l_rowid,
	    X_APPLICATION_ID               => l_application_id,
	    X_ID_FLEX_CODE                 => x_id_flex_code,
	    X_ID_FLEX_NUM                  => l_id_flex_num,
	    X_FLEX_VALIDATION_RULE_NAME    => x_flex_validation_rule_name,
	    X_DESCRIPTION                  => x_description,
	    X_ENABLED_FLAG                 => x_enabled_flag,
	    X_ERROR_SEGMENT_COLUMN_NAME    => x_error_segment_column_name,
	    X_START_DATE_ACTIVE            => x_start_date_active,
	    X_END_DATE_ACTIVE              => x_end_date_active,
	    X_ERROR_MESSAGE_TEXT           => x_error_message_text,
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
   x_id_flex_structure_code       IN VARCHAR2,
   x_flex_validation_rule_name    IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_error_message_text           IN VARCHAR2,
   x_description                  IN VARCHAR2)
  IS
BEGIN
   UPDATE fnd_flex_vdation_rules_tl SET
     error_message_text = Nvl(x_error_message_text, error_message_text),
     description        = Nvl(x_description, description),
     last_update_date   = x_who.last_update_date,
     last_updated_by    = x_who.last_updated_by,
     last_update_login  = x_who.last_update_login,
     source_lang        = userenv('LANG')
     WHERE ((application_id, id_flex_code, id_flex_num) =
	    (SELECT application_id, id_flex_code, id_flex_num
	     FROM fnd_id_flex_structures
	     WHERE (application_id =
		    (SELECT application_id
		     FROM fnd_application
                     WHERE application_short_name = x_application_short_name))
	     AND id_flex_code = x_id_flex_code
             AND id_flex_structure_code = x_id_flex_structure_code))
     AND flex_validation_rule_name = x_flex_validation_rule_name
     AND userenv('LANG') in (language, source_lang);
END translate_row;

end FND_FLEX_VDATION_RULES_PKG;

/
