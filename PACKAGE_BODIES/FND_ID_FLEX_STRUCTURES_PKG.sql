--------------------------------------------------------
--  DDL for Package Body FND_ID_FLEX_STRUCTURES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_ID_FLEX_STRUCTURES_PKG" as
/* $Header: AFFFSTRB.pls 120.4.12010000.1 2008/07/25 14:14:21 appldev ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_ID_FLEX_NUM in NUMBER,
  X_ID_FLEX_STRUCTURE_CODE in VARCHAR2,
  X_CONCATENATED_SEGMENT_DELIMIT in VARCHAR2,
  X_CROSS_SEGMENT_VALIDATION_FLA in VARCHAR2,
  X_DYNAMIC_INSERTS_ALLOWED_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_FREEZE_FLEX_DEFINITION_FLAG in VARCHAR2,
  X_FREEZE_STRUCTURED_HIER_FLAG in VARCHAR2,
  X_SHORTHAND_ENABLED_FLAG in VARCHAR2,
  X_SHORTHAND_LENGTH in NUMBER,
  X_STRUCTURE_VIEW_NAME in VARCHAR2,
  X_ID_FLEX_STRUCTURE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SHORTHAND_PROMPT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_ID_FLEX_STRUCTURES
    where APPLICATION_ID = X_APPLICATION_ID
    and ID_FLEX_CODE = X_ID_FLEX_CODE
    and ID_FLEX_NUM = X_ID_FLEX_NUM
    ;
begin
  insert into FND_ID_FLEX_STRUCTURES (
    APPLICATION_ID,
    ID_FLEX_CODE,
    ID_FLEX_NUM,
    ID_FLEX_STRUCTURE_CODE,
    CONCATENATED_SEGMENT_DELIMITER,
    CROSS_SEGMENT_VALIDATION_FLAG,
    DYNAMIC_INSERTS_ALLOWED_FLAG,
    ENABLED_FLAG,
    FREEZE_FLEX_DEFINITION_FLAG,
    FREEZE_STRUCTURED_HIER_FLAG,
    SHORTHAND_ENABLED_FLAG,
    SHORTHAND_LENGTH,
    STRUCTURE_VIEW_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_ID_FLEX_CODE,
    X_ID_FLEX_NUM,
    X_ID_FLEX_STRUCTURE_CODE,
    X_CONCATENATED_SEGMENT_DELIMIT,
    X_CROSS_SEGMENT_VALIDATION_FLA,
    X_DYNAMIC_INSERTS_ALLOWED_FLAG,
    X_ENABLED_FLAG,
    X_FREEZE_FLEX_DEFINITION_FLAG,
    X_FREEZE_STRUCTURED_HIER_FLAG,
    X_SHORTHAND_ENABLED_FLAG,
    X_SHORTHAND_LENGTH,
    X_STRUCTURE_VIEW_NAME,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_ID_FLEX_STRUCTURES_TL (
    APPLICATION_ID,
    ID_FLEX_CODE,
    ID_FLEX_NUM,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    ID_FLEX_STRUCTURE_NAME,
    DESCRIPTION,
    SHORTHAND_PROMPT,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_ID_FLEX_CODE,
    X_ID_FLEX_NUM,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ID_FLEX_STRUCTURE_NAME,
    X_DESCRIPTION,
    X_SHORTHAND_PROMPT,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_ID_FLEX_STRUCTURES_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.ID_FLEX_CODE = X_ID_FLEX_CODE
    and T.ID_FLEX_NUM = X_ID_FLEX_NUM
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
  X_ID_FLEX_STRUCTURE_CODE in VARCHAR2,
  X_CONCATENATED_SEGMENT_DELIMIT in VARCHAR2,
  X_CROSS_SEGMENT_VALIDATION_FLA in VARCHAR2,
  X_DYNAMIC_INSERTS_ALLOWED_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_FREEZE_FLEX_DEFINITION_FLAG in VARCHAR2,
  X_FREEZE_STRUCTURED_HIER_FLAG in VARCHAR2,
  X_SHORTHAND_ENABLED_FLAG in VARCHAR2,
  X_SHORTHAND_LENGTH in NUMBER,
  X_STRUCTURE_VIEW_NAME in VARCHAR2,
  X_ID_FLEX_STRUCTURE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SHORTHAND_PROMPT in VARCHAR2
) is
  cursor c is select
      ID_FLEX_STRUCTURE_CODE,
      CONCATENATED_SEGMENT_DELIMITER,
      CROSS_SEGMENT_VALIDATION_FLAG,
      DYNAMIC_INSERTS_ALLOWED_FLAG,
      ENABLED_FLAG,
      FREEZE_FLEX_DEFINITION_FLAG,
      FREEZE_STRUCTURED_HIER_FLAG,
      SHORTHAND_ENABLED_FLAG,
      SHORTHAND_LENGTH,
      STRUCTURE_VIEW_NAME
    from FND_ID_FLEX_STRUCTURES
    where APPLICATION_ID = X_APPLICATION_ID
    and ID_FLEX_CODE = X_ID_FLEX_CODE
    and ID_FLEX_NUM = X_ID_FLEX_NUM
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      ID_FLEX_STRUCTURE_NAME,
      DESCRIPTION,
      SHORTHAND_PROMPT,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_ID_FLEX_STRUCTURES_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and ID_FLEX_CODE = X_ID_FLEX_CODE
    and ID_FLEX_NUM = X_ID_FLEX_NUM
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
  if (    (recinfo.ID_FLEX_STRUCTURE_CODE = X_ID_FLEX_STRUCTURE_CODE)
      AND (recinfo.CONCATENATED_SEGMENT_DELIMITER = X_CONCATENATED_SEGMENT_DELIMIT)
      AND (recinfo.CROSS_SEGMENT_VALIDATION_FLAG = X_CROSS_SEGMENT_VALIDATION_FLA)
      AND (recinfo.DYNAMIC_INSERTS_ALLOWED_FLAG = X_DYNAMIC_INSERTS_ALLOWED_FLAG)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.FREEZE_FLEX_DEFINITION_FLAG = X_FREEZE_FLEX_DEFINITION_FLAG)
      AND (recinfo.FREEZE_STRUCTURED_HIER_FLAG = X_FREEZE_STRUCTURED_HIER_FLAG)
      AND (recinfo.SHORTHAND_ENABLED_FLAG = X_SHORTHAND_ENABLED_FLAG)
      AND ((recinfo.SHORTHAND_LENGTH = X_SHORTHAND_LENGTH)
           OR ((recinfo.SHORTHAND_LENGTH is null) AND (X_SHORTHAND_LENGTH is null)))
      AND ((recinfo.STRUCTURE_VIEW_NAME = X_STRUCTURE_VIEW_NAME)
           OR ((recinfo.STRUCTURE_VIEW_NAME is null) AND (X_STRUCTURE_VIEW_NAME is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.ID_FLEX_STRUCTURE_NAME = X_ID_FLEX_STRUCTURE_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND ((tlinfo.SHORTHAND_PROMPT = X_SHORTHAND_PROMPT)
               OR ((tlinfo.SHORTHAND_PROMPT is null) AND (X_SHORTHAND_PROMPT is null)))
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
  X_ID_FLEX_STRUCTURE_CODE in VARCHAR2,
  X_CONCATENATED_SEGMENT_DELIMIT in VARCHAR2,
  X_CROSS_SEGMENT_VALIDATION_FLA in VARCHAR2,
  X_DYNAMIC_INSERTS_ALLOWED_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_FREEZE_FLEX_DEFINITION_FLAG in VARCHAR2,
  X_FREEZE_STRUCTURED_HIER_FLAG in VARCHAR2,
  X_SHORTHAND_ENABLED_FLAG in VARCHAR2,
  X_SHORTHAND_LENGTH in NUMBER,
  X_STRUCTURE_VIEW_NAME in VARCHAR2,
  X_ID_FLEX_STRUCTURE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SHORTHAND_PROMPT in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_ID_FLEX_STRUCTURES set
    ID_FLEX_STRUCTURE_CODE = X_ID_FLEX_STRUCTURE_CODE,
    CONCATENATED_SEGMENT_DELIMITER = X_CONCATENATED_SEGMENT_DELIMIT,
    CROSS_SEGMENT_VALIDATION_FLAG = X_CROSS_SEGMENT_VALIDATION_FLA,
    DYNAMIC_INSERTS_ALLOWED_FLAG = X_DYNAMIC_INSERTS_ALLOWED_FLAG,
    ENABLED_FLAG = X_ENABLED_FLAG,
    FREEZE_FLEX_DEFINITION_FLAG = X_FREEZE_FLEX_DEFINITION_FLAG,
    FREEZE_STRUCTURED_HIER_FLAG = X_FREEZE_STRUCTURED_HIER_FLAG,
    SHORTHAND_ENABLED_FLAG = X_SHORTHAND_ENABLED_FLAG,
    SHORTHAND_LENGTH = X_SHORTHAND_LENGTH,
    STRUCTURE_VIEW_NAME = X_STRUCTURE_VIEW_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and ID_FLEX_CODE = X_ID_FLEX_CODE
  and ID_FLEX_NUM = X_ID_FLEX_NUM;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_ID_FLEX_STRUCTURES_TL set
    ID_FLEX_STRUCTURE_NAME = X_ID_FLEX_STRUCTURE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    SHORTHAND_PROMPT = X_SHORTHAND_PROMPT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and ID_FLEX_CODE = X_ID_FLEX_CODE
  and ID_FLEX_NUM = X_ID_FLEX_NUM
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_ID_FLEX_CODE in VARCHAR2,
  X_ID_FLEX_NUM in NUMBER
) is
begin
  delete from FND_ID_FLEX_STRUCTURES_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and ID_FLEX_CODE = X_ID_FLEX_CODE
  and ID_FLEX_NUM = X_ID_FLEX_NUM;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_ID_FLEX_STRUCTURES
  where APPLICATION_ID = X_APPLICATION_ID
  and ID_FLEX_CODE = X_ID_FLEX_CODE
  and ID_FLEX_NUM = X_ID_FLEX_NUM;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
 is
 begin
/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out  */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/*

   delete from FND_ID_FLEX_STRUCTURES_TL T
   where not exists
     (select NULL
     from FND_ID_FLEX_STRUCTURES B
     where B.APPLICATION_ID = T.APPLICATION_ID
     and B.ID_FLEX_CODE = T.ID_FLEX_CODE
     and B.ID_FLEX_NUM = T.ID_FLEX_NUM
     );

   update FND_ID_FLEX_STRUCTURES_TL T set (
       ID_FLEX_STRUCTURE_NAME,
       DESCRIPTION,
       SHORTHAND_PROMPT
     ) = (select
       B.ID_FLEX_STRUCTURE_NAME,
       B.DESCRIPTION,
       B.SHORTHAND_PROMPT
     from FND_ID_FLEX_STRUCTURES_TL B
     where B.APPLICATION_ID = T.APPLICATION_ID
     and B.ID_FLEX_CODE = T.ID_FLEX_CODE
     and B.ID_FLEX_NUM = T.ID_FLEX_NUM
     and B.LANGUAGE = T.SOURCE_LANG)
   where (
       T.APPLICATION_ID,
       T.ID_FLEX_CODE,
       T.ID_FLEX_NUM,
       T.LANGUAGE
   ) in (select
       SUBT.APPLICATION_ID,
       SUBT.ID_FLEX_CODE,
       SUBT.ID_FLEX_NUM,
       SUBT.LANGUAGE
     from FND_ID_FLEX_STRUCTURES_TL SUBB, FND_ID_FLEX_STRUCTURES_TL SUBT
     where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
     and SUBB.ID_FLEX_CODE = SUBT.ID_FLEX_CODE
     and SUBB.ID_FLEX_NUM = SUBT.ID_FLEX_NUM
     and SUBB.LANGUAGE = SUBT.SOURCE_LANG
     and (SUBB.ID_FLEX_STRUCTURE_NAME <> SUBT.ID_FLEX_STRUCTURE_NAME
       or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
       or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
       or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
       or SUBB.SHORTHAND_PROMPT <> SUBT.SHORTHAND_PROMPT
       or (SUBB.SHORTHAND_PROMPT is null and SUBT.SHORTHAND_PROMPT is not null)
       or (SUBB.SHORTHAND_PROMPT is not null and SUBT.SHORTHAND_PROMPT is null)
   ));
*/

   insert into FND_ID_FLEX_STRUCTURES_TL (
     APPLICATION_ID,
     ID_FLEX_CODE,
     ID_FLEX_NUM,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_LOGIN,
     ID_FLEX_STRUCTURE_NAME,
     DESCRIPTION,
     SHORTHAND_PROMPT,
     LANGUAGE,
     SOURCE_LANG
   ) select
     B.APPLICATION_ID,
     B.ID_FLEX_CODE,
     B.ID_FLEX_NUM,
     B.LAST_UPDATE_DATE,
     B.LAST_UPDATED_BY,
     B.CREATION_DATE,
     B.CREATED_BY,
     B.LAST_UPDATE_LOGIN,
     B.ID_FLEX_STRUCTURE_NAME,
     B.DESCRIPTION,
     B.SHORTHAND_PROMPT,
     L.LANGUAGE_CODE,
     B.SOURCE_LANG
   from FND_ID_FLEX_STRUCTURES_TL B, FND_LANGUAGES L
   where L.INSTALLED_FLAG in ('I', 'B')
   and B.LANGUAGE = userenv('LANG')
   and not exists
     (select NULL
     from FND_ID_FLEX_STRUCTURES_TL T
     where T.APPLICATION_ID = B.APPLICATION_ID
     and T.ID_FLEX_CODE = B.ID_FLEX_CODE
     and T.ID_FLEX_NUM = B.ID_FLEX_NUM
     and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE load_row
  (x_application_short_name       IN VARCHAR2,
   x_id_flex_code                 IN VARCHAR2,
   x_id_flex_structure_code       IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_concatenated_segment_delimit IN VARCHAR2,
   x_cross_segment_validation_fla IN VARCHAR2,
   x_dynamic_inserts_allowed_flag IN VARCHAR2,
   x_enabled_flag                 IN VARCHAR2,
   x_freeze_flex_definition_flag  IN VARCHAR2,
   x_freeze_structured_hier_flag  IN VARCHAR2,
   x_shorthand_enabled_flag       IN VARCHAR2,
   x_shorthand_length             IN NUMBER,
   x_structure_view_name          IN VARCHAR2,
   x_id_flex_structure_name       IN VARCHAR2,
   x_description                  IN VARCHAR2,
   x_shorthand_prompt             IN VARCHAR2)
  IS
     l_application_id   NUMBER;
     l_id_flex_code     fnd_id_flexs.id_flex_code%TYPE;
     l_id_flex_num      NUMBER;
     l_rowid            VARCHAR2(64);
BEGIN
   SELECT application_id
     INTO l_application_id
     FROM fnd_application
     WHERE application_short_name = x_application_short_name;

   SELECT id_flex_code
     INTO l_id_flex_code
     FROM fnd_id_flexs
     WHERE application_id = l_application_id
     AND id_flex_code = x_id_flex_code;

   BEGIN
      SELECT id_flex_num
	INTO l_id_flex_num
	FROM fnd_id_flex_structures
	WHERE application_id = l_application_id
	AND id_flex_code = l_id_flex_code
	AND id_flex_structure_code = x_id_flex_structure_code;

      fnd_id_flex_structures_pkg.update_row
	(X_APPLICATION_ID               => l_application_id,
	 X_ID_FLEX_CODE                 => l_id_flex_code,
	 X_ID_FLEX_NUM                  => l_id_flex_num,
	 X_ID_FLEX_STRUCTURE_CODE       => x_id_flex_structure_code,
	 X_CONCATENATED_SEGMENT_DELIMIT => x_concatenated_segment_delimit,
	 X_CROSS_SEGMENT_VALIDATION_FLA => x_cross_segment_validation_fla,
	 X_DYNAMIC_INSERTS_ALLOWED_FLAG => x_dynamic_inserts_allowed_flag,
	 X_ENABLED_FLAG                 => x_enabled_flag,
	 X_FREEZE_FLEX_DEFINITION_FLAG  => x_freeze_flex_definition_flag,
	 X_FREEZE_STRUCTURED_HIER_FLAG  => x_freeze_structured_hier_flag,
	 X_SHORTHAND_ENABLED_FLAG       => x_shorthand_enabled_flag,
	 X_SHORTHAND_LENGTH             => x_shorthand_length,
	 X_STRUCTURE_VIEW_NAME          => x_structure_view_name,
	 X_ID_FLEX_STRUCTURE_NAME       => x_id_flex_structure_name,
	 X_DESCRIPTION                  => x_description,
	 X_SHORTHAND_PROMPT             => x_shorthand_prompt,
	 X_LAST_UPDATE_DATE             => x_who.last_update_date,
	 X_LAST_UPDATED_BY              => x_who.last_updated_by,
	 X_LAST_UPDATE_LOGIN            => x_who.last_update_login);
   EXCEPTION
      WHEN no_data_found THEN
	 SELECT fnd_id_flex_structures_s.NEXTVAL
	   INTO l_id_flex_num
	   FROM dual;

	 fnd_id_flex_structures_pkg.insert_row
	   (X_ROWID                        => l_rowid,
	    X_APPLICATION_ID               => l_application_id,
	    X_ID_FLEX_CODE                 => l_id_flex_code,
	    X_ID_FLEX_NUM                  => l_id_flex_num,
	    X_ID_FLEX_STRUCTURE_CODE       => x_id_flex_structure_code,
	    X_CONCATENATED_SEGMENT_DELIMIT => x_concatenated_segment_delimit,
	    X_CROSS_SEGMENT_VALIDATION_FLA => x_cross_segment_validation_fla,
	    X_DYNAMIC_INSERTS_ALLOWED_FLAG => x_dynamic_inserts_allowed_flag,
	    X_ENABLED_FLAG                 => x_enabled_flag,
	    X_FREEZE_FLEX_DEFINITION_FLAG  => x_freeze_flex_definition_flag,
	    X_FREEZE_STRUCTURED_HIER_FLAG  => x_freeze_structured_hier_flag,
	    X_SHORTHAND_ENABLED_FLAG       => x_shorthand_enabled_flag,
	    X_SHORTHAND_LENGTH             => x_shorthand_length,
	    X_STRUCTURE_VIEW_NAME          => x_structure_view_name,
	    X_ID_FLEX_STRUCTURE_NAME       => x_id_flex_structure_name,
	    X_DESCRIPTION                  => x_description,
	    X_SHORTHAND_PROMPT             => x_shorthand_prompt,
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
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_id_flex_structure_name       IN VARCHAR2,
   x_description                  IN VARCHAR2,
   x_shorthand_prompt             IN VARCHAR2)
  IS
BEGIN
   UPDATE fnd_id_flex_structures_tl SET
     id_flex_structure_name = Nvl(x_id_flex_structure_name,
				  id_flex_structure_name),
     description            = Nvl(x_description, description),
     shorthand_prompt       = Nvl(x_shorthand_prompt, shorthand_prompt),
     last_update_date       = x_who.last_update_date,
     last_updated_by        = x_who.last_updated_by,
     last_update_login      = x_who.last_update_login,
     source_lang            = userenv('LANG')
     WHERE ((application_id, id_flex_code, id_flex_num) =
	    (SELECT application_id, id_flex_code, id_flex_num
	     FROM fnd_id_flex_structures
	     WHERE (application_id =
		    (SELECT application_id
		     FROM fnd_application
		     WHERE application_short_name = x_application_short_name))
	     AND id_flex_code = x_id_flex_code
	     AND id_flex_structure_code = x_id_flex_structure_code))
     AND userenv('LANG') in (language, source_lang);
END translate_row;

end FND_ID_FLEX_STRUCTURES_PKG;

/
