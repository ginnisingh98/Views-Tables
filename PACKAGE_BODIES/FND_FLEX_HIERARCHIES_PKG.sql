--------------------------------------------------------
--  DDL for Package Body FND_FLEX_HIERARCHIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_HIERARCHIES_PKG" as
/* $Header: AFFFHIRB.pls 120.2.12010000.1 2008/07/25 14:14:01 appldev ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_HIERARCHY_ID in NUMBER,
  X_HIERARCHY_CODE in VARCHAR2,
  X_HIERARCHY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_FLEX_HIERARCHIES
    where FLEX_VALUE_SET_ID = X_FLEX_VALUE_SET_ID
    and HIERARCHY_ID = X_HIERARCHY_ID
    ;
begin
  insert into FND_FLEX_HIERARCHIES (
    FLEX_VALUE_SET_ID,
    HIERARCHY_ID,
    HIERARCHY_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_FLEX_VALUE_SET_ID,
    X_HIERARCHY_ID,
    X_HIERARCHY_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_FLEX_HIERARCHIES_TL (
    FLEX_VALUE_SET_ID,
    HIERARCHY_ID,
    HIERARCHY_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_FLEX_VALUE_SET_ID,
    X_HIERARCHY_ID,
    X_HIERARCHY_NAME,
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
    from FND_FLEX_HIERARCHIES_TL T
    where T.FLEX_VALUE_SET_ID = X_FLEX_VALUE_SET_ID
    and T.HIERARCHY_ID = X_HIERARCHY_ID
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
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_HIERARCHY_ID in NUMBER,
  X_HIERARCHY_CODE in VARCHAR2,
  X_HIERARCHY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      HIERARCHY_CODE
    from FND_FLEX_HIERARCHIES
    where FLEX_VALUE_SET_ID = X_FLEX_VALUE_SET_ID
    and HIERARCHY_ID = X_HIERARCHY_ID
    for update of FLEX_VALUE_SET_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      HIERARCHY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from FND_FLEX_HIERARCHIES_TL
    where FLEX_VALUE_SET_ID = X_FLEX_VALUE_SET_ID
    and HIERARCHY_ID = X_HIERARCHY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of FLEX_VALUE_SET_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.HIERARCHY_CODE = X_HIERARCHY_CODE)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.HIERARCHY_NAME = X_HIERARCHY_NAME)
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
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_HIERARCHY_ID in NUMBER,
  X_HIERARCHY_CODE in VARCHAR2,
  X_HIERARCHY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_FLEX_HIERARCHIES set
    HIERARCHY_CODE = X_HIERARCHY_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where FLEX_VALUE_SET_ID = X_FLEX_VALUE_SET_ID
  and HIERARCHY_ID = X_HIERARCHY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_FLEX_HIERARCHIES_TL set
    HIERARCHY_NAME = X_HIERARCHY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where FLEX_VALUE_SET_ID = X_FLEX_VALUE_SET_ID
  and HIERARCHY_ID = X_HIERARCHY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_FLEX_VALUE_SET_ID in NUMBER,
  X_HIERARCHY_ID in NUMBER
) is
begin
  delete from FND_FLEX_HIERARCHIES_TL
  where FLEX_VALUE_SET_ID = X_FLEX_VALUE_SET_ID
  and HIERARCHY_ID = X_HIERARCHY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_FLEX_HIERARCHIES
  where FLEX_VALUE_SET_ID = X_FLEX_VALUE_SET_ID
  and HIERARCHY_ID = X_HIERARCHY_ID;

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

   delete from FND_FLEX_HIERARCHIES_TL T
   where not exists
     (select NULL
     from FND_FLEX_HIERARCHIES B
     where B.FLEX_VALUE_SET_ID = T.FLEX_VALUE_SET_ID
     and B.HIERARCHY_ID = T.HIERARCHY_ID
     );

   update FND_FLEX_HIERARCHIES_TL T set (
       HIERARCHY_NAME,
       DESCRIPTION
     ) = (select
       B.HIERARCHY_NAME,
       B.DESCRIPTION
     from FND_FLEX_HIERARCHIES_TL B
     where B.FLEX_VALUE_SET_ID = T.FLEX_VALUE_SET_ID
     and B.HIERARCHY_ID = T.HIERARCHY_ID
     and B.LANGUAGE = T.SOURCE_LANG)
   where (
       T.FLEX_VALUE_SET_ID,
       T.HIERARCHY_ID,
       T.LANGUAGE
   ) in (select
       SUBT.FLEX_VALUE_SET_ID,
       SUBT.HIERARCHY_ID,
       SUBT.LANGUAGE
     from FND_FLEX_HIERARCHIES_TL SUBB, FND_FLEX_HIERARCHIES_TL SUBT
     where SUBB.FLEX_VALUE_SET_ID = SUBT.FLEX_VALUE_SET_ID
     and SUBB.HIERARCHY_ID = SUBT.HIERARCHY_ID
     and SUBB.LANGUAGE = SUBT.SOURCE_LANG
     and (SUBB.HIERARCHY_NAME <> SUBT.HIERARCHY_NAME
       or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
       or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
       or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
   ));
*/

   insert into FND_FLEX_HIERARCHIES_TL (
     FLEX_VALUE_SET_ID,
     HIERARCHY_ID,
     HIERARCHY_NAME,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_LOGIN,
     DESCRIPTION,
     LANGUAGE,
     SOURCE_LANG
   ) select
     B.FLEX_VALUE_SET_ID,
     B.HIERARCHY_ID,
     B.HIERARCHY_NAME,
     B.LAST_UPDATE_DATE,
     B.LAST_UPDATED_BY,
     B.CREATION_DATE,
     B.CREATED_BY,
     B.LAST_UPDATE_LOGIN,
     B.DESCRIPTION,
     L.LANGUAGE_CODE,
     B.SOURCE_LANG
   from FND_FLEX_HIERARCHIES_TL B, FND_LANGUAGES L
   where L.INSTALLED_FLAG in ('I', 'B')
   and B.LANGUAGE = userenv('LANG')
   and not exists
     (select NULL
     from FND_FLEX_HIERARCHIES_TL T
     where T.FLEX_VALUE_SET_ID = B.FLEX_VALUE_SET_ID
     and T.HIERARCHY_ID = B.HIERARCHY_ID
     and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE load_row
  (x_flex_value_set_name          IN VARCHAR2,
   x_hierarchy_code               IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_hierarchy_name               IN VARCHAR2,
   x_description                  IN VARCHAR2)
  IS
     l_flex_value_set_id  NUMBER;
     l_hierarchy_id       NUMBER;
     l_rowid              VARCHAR2(64);
BEGIN
   SELECT flex_value_set_id
     INTO l_flex_value_set_id
     FROM fnd_flex_value_sets
     WHERE flex_value_set_name = x_flex_value_set_name;

   BEGIN
      SELECT hierarchy_id
        INTO l_hierarchy_id
        FROM fnd_flex_hierarchies
        WHERE flex_value_set_id = l_flex_value_set_id
        AND hierarchy_code = x_hierarchy_code;

      fnd_flex_hierarchies_pkg.update_row
        (X_FLEX_VALUE_SET_ID            => l_flex_value_set_id,
         X_HIERARCHY_ID                 => l_hierarchy_id,
         X_HIERARCHY_CODE               => x_hierarchy_code,
         X_HIERARCHY_NAME               => x_hierarchy_name,
         X_DESCRIPTION                  => x_description,
         X_LAST_UPDATE_DATE             => x_who.last_update_date,
         X_LAST_UPDATED_BY              => x_who.last_updated_by,
         X_LAST_UPDATE_LOGIN            => x_who.last_update_login);
   EXCEPTION
      WHEN no_data_found THEN
         SELECT fnd_flex_hierarchies_s.NEXTVAL
           INTO l_hierarchy_id
           FROM dual;

         fnd_flex_hierarchies_pkg.insert_row
           (X_ROWID                        => l_rowid,
            X_FLEX_VALUE_SET_ID            => l_flex_value_set_id,
            X_HIERARCHY_ID                 => l_hierarchy_id,
            X_HIERARCHY_CODE               => x_hierarchy_code,
            X_HIERARCHY_NAME               => x_hierarchy_name,
            X_DESCRIPTION                  => x_description,
            X_CREATION_DATE                => x_who.creation_date,
            X_CREATED_BY                   => x_who.created_by,
            X_LAST_UPDATE_DATE             => x_who.last_update_date,
            X_LAST_UPDATED_BY              => x_who.last_updated_by,
            X_LAST_UPDATE_LOGIN            => x_who.last_update_login);
   END;
END load_row;

PROCEDURE translate_row
  (x_flex_value_set_name          IN VARCHAR2,
   x_hierarchy_code               IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_hierarchy_name               IN VARCHAR2,
   x_description                  IN VARCHAR2)
  IS
BEGIN
   UPDATE fnd_flex_hierarchies_tl SET
     hierarchy_name    = Nvl(x_hierarchy_name, hierarchy_name),
     description       = Nvl(x_description, description),
     last_update_date  = x_who.last_update_date,
     last_updated_by   = x_who.last_updated_by,
     last_update_login = x_who.last_update_login,
     source_lang       = userenv('LANG')
     WHERE ((flex_value_set_id, hierarchy_id) =
            (SELECT flex_value_set_id, hierarchy_id
             FROM fnd_flex_hierarchies
             WHERE (flex_value_set_id =
                    (SELECT flex_value_set_id
                     FROM fnd_flex_value_sets
                     WHERE flex_value_set_name = x_flex_value_set_name))
             AND hierarchy_code = x_hierarchy_code))
     AND userenv('LANG') in (language, source_lang);
END translate_row;

end FND_FLEX_HIERARCHIES_PKG;

/
