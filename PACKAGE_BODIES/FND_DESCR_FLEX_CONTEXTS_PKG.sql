--------------------------------------------------------
--  DDL for Package Body FND_DESCR_FLEX_CONTEXTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DESCR_FLEX_CONTEXTS_PKG" as
/* $Header: AFFFDFCB.pls 120.2.12010000.1 2008/07/25 14:13:45 appldev ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_GLOBAL_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_NAM in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from FND_DESCR_FLEX_CONTEXTS
    where APPLICATION_ID = X_APPLICATION_ID
    and DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME
    and DESCRIPTIVE_FLEX_CONTEXT_CODE = X_DESCRIPTIVE_FLEX_CONTEXT_COD
    ;
begin
  insert into FND_DESCR_FLEX_CONTEXTS (
    APPLICATION_ID,
    DESCRIPTIVE_FLEXFIELD_NAME,
    DESCRIPTIVE_FLEX_CONTEXT_CODE,
    ENABLED_FLAG,
    GLOBAL_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_DESCRIPTIVE_FLEXFIELD_NAME,
    X_DESCRIPTIVE_FLEX_CONTEXT_COD,
    X_ENABLED_FLAG,
    X_GLOBAL_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into FND_DESCR_FLEX_CONTEXTS_TL (
    APPLICATION_ID,
    DESCRIPTIVE_FLEXFIELD_NAME,
    DESCRIPTIVE_FLEX_CONTEXT_CODE,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTIVE_FLEX_CONTEXT_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_DESCRIPTIVE_FLEXFIELD_NAME,
    X_DESCRIPTIVE_FLEX_CONTEXT_COD,
    X_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_DESCRIPTIVE_FLEX_CONTEXT_NAM,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from FND_DESCR_FLEX_CONTEXTS_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
    and T.DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME
    and T.DESCRIPTIVE_FLEX_CONTEXT_CODE = X_DESCRIPTIVE_FLEX_CONTEXT_COD
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
  X_DESCRIPTIVE_FLEX_CONTEXT_COD in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_GLOBAL_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_NAM in VARCHAR2
) is
  cursor c is select
      ENABLED_FLAG,
      GLOBAL_FLAG
    from FND_DESCR_FLEX_CONTEXTS
    where APPLICATION_ID = X_APPLICATION_ID
    and DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME
    and DESCRIPTIVE_FLEX_CONTEXT_CODE = X_DESCRIPTIVE_FLEX_CONTEXT_COD
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      DESCRIPTIVE_FLEX_CONTEXT_NAME
    from FND_DESCR_FLEX_CONTEXTS_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME
    and DESCRIPTIVE_FLEX_CONTEXT_CODE = X_DESCRIPTIVE_FLEX_CONTEXT_COD
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
  if (    (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND (recinfo.GLOBAL_FLAG = X_GLOBAL_FLAG)
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

  if (    ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      AND (tlinfo.DESCRIPTIVE_FLEX_CONTEXT_NAME = X_DESCRIPTIVE_FLEX_CONTEXT_NAM)
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
  X_DESCRIPTIVE_FLEXFIELD_NAME in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_GLOBAL_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_NAM in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update FND_DESCR_FLEX_CONTEXTS set
    ENABLED_FLAG = X_ENABLED_FLAG,
    GLOBAL_FLAG = X_GLOBAL_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID
  and DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME
  and DESCRIPTIVE_FLEX_CONTEXT_CODE = X_DESCRIPTIVE_FLEX_CONTEXT_COD;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update FND_DESCR_FLEX_CONTEXTS_TL set
    DESCRIPTION = X_DESCRIPTION,
    DESCRIPTIVE_FLEX_CONTEXT_NAME = X_DESCRIPTIVE_FLEX_CONTEXT_NAM,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME
  and DESCRIPTIVE_FLEX_CONTEXT_CODE = X_DESCRIPTIVE_FLEX_CONTEXT_COD
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_DESCRIPTIVE_FLEXFIELD_NAME in VARCHAR2,
  X_DESCRIPTIVE_FLEX_CONTEXT_COD in VARCHAR2
) is
begin
  delete from FND_DESCR_FLEX_CONTEXTS
  where APPLICATION_ID = X_APPLICATION_ID
  and DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME
  and DESCRIPTIVE_FLEX_CONTEXT_CODE = X_DESCRIPTIVE_FLEX_CONTEXT_COD;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from FND_DESCR_FLEX_CONTEXTS_TL
  where APPLICATION_ID = X_APPLICATION_ID
  and DESCRIPTIVE_FLEXFIELD_NAME = X_DESCRIPTIVE_FLEXFIELD_NAME
  and DESCRIPTIVE_FLEX_CONTEXT_CODE = X_DESCRIPTIVE_FLEX_CONTEXT_COD;

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
   delete from FND_DESCR_FLEX_CONTEXTS_TL T
   where not exists
     (select NULL
     from FND_DESCR_FLEX_CONTEXTS B
     where B.APPLICATION_ID = T.APPLICATION_ID
     and B.DESCRIPTIVE_FLEXFIELD_NAME = T.DESCRIPTIVE_FLEXFIELD_NAME
     and B.DESCRIPTIVE_FLEX_CONTEXT_CODE = T.DESCRIPTIVE_FLEX_CONTEXT_CODE
     );

   update FND_DESCR_FLEX_CONTEXTS_TL T set (
       DESCRIPTION,
       DESCRIPTIVE_FLEX_CONTEXT_NAME
     ) = (select
       B.DESCRIPTION,
       B.DESCRIPTIVE_FLEX_CONTEXT_NAME
     from FND_DESCR_FLEX_CONTEXTS_TL B
     where B.APPLICATION_ID = T.APPLICATION_ID
     and B.DESCRIPTIVE_FLEXFIELD_NAME = T.DESCRIPTIVE_FLEXFIELD_NAME
     and B.DESCRIPTIVE_FLEX_CONTEXT_CODE = T.DESCRIPTIVE_FLEX_CONTEXT_CODE
     and B.LANGUAGE = T.SOURCE_LANG)
   where (
       T.APPLICATION_ID,
       T.DESCRIPTIVE_FLEXFIELD_NAME,
       T.DESCRIPTIVE_FLEX_CONTEXT_CODE,
       T.LANGUAGE
   ) in (select
       SUBT.APPLICATION_ID,
       SUBT.DESCRIPTIVE_FLEXFIELD_NAME,
       SUBT.DESCRIPTIVE_FLEX_CONTEXT_CODE,
       SUBT.LANGUAGE
     from FND_DESCR_FLEX_CONTEXTS_TL SUBB, FND_DESCR_FLEX_CONTEXTS_TL SUBT
     where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
     and SUBB.DESCRIPTIVE_FLEXFIELD_NAME = SUBT.DESCRIPTIVE_FLEXFIELD_NAME
     and SUBB.DESCRIPTIVE_FLEX_CONTEXT_CODE = SUBT.DESCRIPTIVE_FLEX_CONTEXT_CODE
     and SUBB.LANGUAGE = SUBT.SOURCE_LANG
     and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
       or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
       or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
       or SUBB.DESCRIPTIVE_FLEX_CONTEXT_NAME <> SUBT.DESCRIPTIVE_FLEX_CONTEXT_NAME
   ));
*/

   insert into FND_DESCR_FLEX_CONTEXTS_TL (
     APPLICATION_ID,
     DESCRIPTIVE_FLEXFIELD_NAME,
     DESCRIPTIVE_FLEX_CONTEXT_CODE,
     DESCRIPTION,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_LOGIN,
     DESCRIPTIVE_FLEX_CONTEXT_NAME,
     LANGUAGE,
     SOURCE_LANG
   ) select
     B.APPLICATION_ID,
     B.DESCRIPTIVE_FLEXFIELD_NAME,
     B.DESCRIPTIVE_FLEX_CONTEXT_CODE,
     B.DESCRIPTION,
     B.LAST_UPDATE_DATE,
     B.LAST_UPDATED_BY,
     B.CREATION_DATE,
     B.CREATED_BY,
     B.LAST_UPDATE_LOGIN,
     B.DESCRIPTIVE_FLEX_CONTEXT_NAME,
     L.LANGUAGE_CODE,
     B.SOURCE_LANG
   from FND_DESCR_FLEX_CONTEXTS_TL B, FND_LANGUAGES L
   where L.INSTALLED_FLAG in ('I', 'B')
   and B.LANGUAGE = userenv('LANG')
   and not exists
     (select NULL
     from FND_DESCR_FLEX_CONTEXTS_TL T
     where T.APPLICATION_ID = B.APPLICATION_ID
     and T.DESCRIPTIVE_FLEXFIELD_NAME = B.DESCRIPTIVE_FLEXFIELD_NAME
     and T.DESCRIPTIVE_FLEX_CONTEXT_CODE = B.DESCRIPTIVE_FLEX_CONTEXT_CODE
     and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE load_row
  (x_application_short_name       IN VARCHAR2,
   x_descriptive_flexfield_name   IN VARCHAR2,
   x_descriptive_flex_context_cod IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_enabled_flag                 IN VARCHAR2,
   x_global_flag                  IN VARCHAR2,
   x_description                  IN VARCHAR2,
   x_descriptive_flex_context_nam IN VARCHAR2)
  IS
     l_application_id  NUMBER;
     l_rowid           VARCHAR2(64);
BEGIN
   SELECT application_id
     INTO l_application_id
     FROM fnd_application
     WHERE application_short_name = x_application_short_name;

   BEGIN
      fnd_descr_flex_contexts_pkg.update_row
        (X_APPLICATION_ID               => l_application_id,
         X_DESCRIPTIVE_FLEXFIELD_NAME   => x_descriptive_flexfield_name,
         X_DESCRIPTIVE_FLEX_CONTEXT_COD => x_descriptive_flex_context_cod,
         X_ENABLED_FLAG                 => x_enabled_flag,
         X_GLOBAL_FLAG                  => x_global_flag,
         X_DESCRIPTION                  => x_description,
         X_DESCRIPTIVE_FLEX_CONTEXT_NAM => x_descriptive_flex_context_nam,
         X_LAST_UPDATE_DATE             => x_who.last_update_date,
         X_LAST_UPDATED_BY              => x_who.last_updated_by,
         X_LAST_UPDATE_LOGIN            => x_who.last_update_login);
   EXCEPTION
      WHEN no_data_found THEN
         fnd_descr_flex_contexts_pkg.insert_row
           (X_ROWID                        => l_rowid,
            X_APPLICATION_ID               => l_application_id,
            X_DESCRIPTIVE_FLEXFIELD_NAME   => x_descriptive_flexfield_name,
            X_DESCRIPTIVE_FLEX_CONTEXT_COD => x_descriptive_flex_context_cod,
            X_ENABLED_FLAG                 => x_enabled_flag,
            X_GLOBAL_FLAG                  => x_global_flag,
            X_DESCRIPTION                  => x_description,
            X_DESCRIPTIVE_FLEX_CONTEXT_NAM => x_descriptive_flex_context_nam,
            X_CREATION_DATE                => x_who.creation_date,
            X_CREATED_BY                   => x_who.created_by,
            X_LAST_UPDATE_DATE             => x_who.last_update_date,
            X_LAST_UPDATED_BY              => x_who.last_updated_by,
            X_LAST_UPDATE_LOGIN            => x_who.last_update_login);
   END;
END load_row;

PROCEDURE translate_row
  (x_application_short_name       IN VARCHAR2,
   x_descriptive_flexfield_name   IN VARCHAR2,
   x_descriptive_flex_context_cod IN VARCHAR2,
   x_who                          IN fnd_flex_loader_apis.who_type,
   x_description                  IN VARCHAR2,
   x_descriptive_flex_context_nam IN VARCHAR2)
  IS
BEGIN
   UPDATE fnd_descr_flex_contexts_tl SET
     description                   = Nvl(x_description, description),
     descriptive_flex_context_name = Nvl(x_descriptive_flex_context_nam,
                                         descriptive_flex_context_name),
     last_update_date    = x_who.last_update_date,
     last_updated_by     = x_who.last_updated_by,
     last_update_login   = x_who.last_update_login,
     source_lang         = userenv('LANG')
     WHERE application_id = (SELECT application_id
                             FROM fnd_application
                             WHERE application_short_name = x_application_short_name)
     AND descriptive_flexfield_name = x_descriptive_flexfield_name
     AND descriptive_flex_context_code = x_descriptive_flex_context_cod
     AND userenv('LANG') in (language, source_lang);
END translate_row;

end FND_DESCR_FLEX_CONTEXTS_PKG;

/
