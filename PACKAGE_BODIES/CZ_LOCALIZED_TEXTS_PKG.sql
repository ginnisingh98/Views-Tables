--------------------------------------------------------
--  DDL for Package Body CZ_LOCALIZED_TEXTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_LOCALIZED_TEXTS_PKG" as
/* $Header: cziloctb.pls 120.4 2006/09/26 20:08:47 asiaston ship $ */

NO_MODEL_ID   NUMBER := -1;

procedure INSERT_ROW
(X_ROWID             in OUT NOCOPY VARCHAR2,
 X_INTL_TEXT_ID      in NUMBER,
 X_LOCALIZED_STR     in VARCHAR2,
 X_ORIG_SYS_REF      in VARCHAR2,
 X_CREATION_DATE     in DATE,
 X_LAST_UPDATE_DATE  in DATE,
 X_DELETED_FLAG      in VARCHAR2,
 X_CREATED_BY        in NUMBER,
 X_LAST_UPDATED_BY   in NUMBER,
 X_LAST_UPDATE_LOGIN in NUMBER,
 X_LOCALE_ID         in NUMBER,
 p_model_id          IN NUMBER,
 p_ui_def_id         IN NUMBER,
 X_SEEDED_FLAG       IN VARCHAR2,
 X_PERSISTENT_INTL_TEXT_ID IN NUMBER,
 X_UI_PAGE_ID         IN NUMBER,
 X_UI_PAGE_ELEMENT_ID IN VARCHAR2) is

  cursor C is
    select ROWID
    from  CZ_LOCALIZED_TEXTS
    where  INTL_TEXT_ID = X_INTL_TEXT_ID
    and language = userenv('LANG');

begin

  insert into CZ_LOCALIZED_TEXTS
           (INTL_TEXT_ID
            ,LOCALIZED_STR
            ,ORIG_SYS_REF
            ,CREATION_DATE
            ,LAST_UPDATE_DATE
            ,DELETED_FLAG
            ,CREATED_BY
            ,LAST_UPDATED_BY
            ,LAST_UPDATE_LOGIN
            ,LOCALE_ID
            ,model_id
            ,ui_def_id
            ,seeded_flag
            ,source_lang
            ,language
            ,PERSISTENT_INTL_TEXT_ID
            ,UI_PAGE_ID
            ,UI_PAGE_ELEMENT_ID)
  select
             X_INTL_TEXT_ID
            ,X_LOCALIZED_STR
            ,X_ORIG_SYS_REF
            ,X_CREATION_DATE
            ,X_LAST_UPDATE_DATE
            ,X_DELETED_FLAG
            ,X_CREATED_BY
            ,X_LAST_UPDATED_BY
            ,X_LAST_UPDATE_LOGIN
            ,X_LOCALE_ID
            ,p_model_id
            ,p_ui_def_id
            ,X_SEEDED_FLAG, userenv('LANG'), L.LANGUAGE_CODE, X_PERSISTENT_INTL_TEXT_ID
            ,X_UI_PAGE_ID, X_UI_PAGE_ELEMENT_ID
  from  FND_LANGUAGES  L
  where  L.INSTALLED_FLAG in ('I', 'B')
    and  not exists
         ( select NULL
           from   CZ_LOCALIZED_TEXTS  T
           where  T.INTL_TEXT_ID = X_INTL_TEXT_ID
             and  T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure UPDATE_ROW
(X_INTL_TEXT_ID      in NUMBER,
 X_LOCALIZED_STR     in VARCHAR2,
 X_ORIG_SYS_REF      in VARCHAR2,
 X_CREATION_DATE     in DATE,
 X_LAST_UPDATE_DATE  in DATE,
 X_DELETED_FLAG      in VARCHAR2,
 X_CREATED_BY        in NUMBER,
 X_LAST_UPDATED_BY   in NUMBER,
 X_LAST_UPDATE_LOGIN in NUMBER,
 X_LOCALE_ID         in NUMBER,
 p_model_id          IN NUMBER,
 p_ui_def_id         IN NUMBER,
 X_PERSISTENT_INTL_TEXT_ID in NUMBER,
 X_SEEDED_FLAG       IN VARCHAR2,
 X_UI_PAGE_ID        IN NUMBER,
 X_UI_PAGE_ELEMENT_ID IN VARCHAR2) is

begin

 update  CZ_LOCALIZED_TEXTS set
         INTL_TEXT_ID     =X_INTL_TEXT_ID
         ,LOCALIZED_STR    = DECODE(userenv('LANG'), language, X_LOCALIZED_STR, source_lang, X_LOCALIZED_STR, localized_str)
         ,ORIG_SYS_REF     =X_ORIG_SYS_REF
         ,DELETED_FLAG     =X_DELETED_FLAG
         ,LAST_UPDATE_LOGIN=X_LAST_UPDATE_LOGIN
         ,LOCALE_ID        =X_LOCALE_ID
         ,model_id         =p_model_id
         ,ui_def_id        =p_ui_def_id
         ,persistent_intl_text_id = X_PERSISTENT_INTL_TEXT_ID
         ,seeded_flag = x_seeded_flag
         ,UI_PAGE_ID = X_UI_PAGE_ID
         ,UI_PAGE_ELEMENT_ID = X_UI_PAGE_ELEMENT_ID
  where  INTL_TEXT_ID = X_INTL_TEXT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;


-- ----------------------------------------------------------------------
-- Deletion of categories is not supported.
-- ----------------------------------------------------------------------

procedure DELETE_ROW (
  X_INTL_TEXT_ID in NUMBER
) is
begin

  delete from CZ_LOCALIZED_TEXTS
  where  INTL_TEXT_ID = X_INTL_TEXT_ID ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


-- ----------------------------------------------------------------------
-- PROCEDURE:  ADD_LANGUAGE       PUBLIC
-- ----------------------------------------------------------------------
procedure ADD_LANGUAGE is

begin

/* Mar/19/03 requested by Ric Ginsberg */
/* The following delete and update statements are commented out */
/* as a quick workaround to fix the time-consuming table handler issue */
/* Eventually we'll need to turn them into a separate fix_language procedure */
/* Added by Pat Passerini July 17, 2003. */
/*
  delete from CZ_LOCALIZED_TEXTS where DELETED_FLAG='1';
  commit;

  update CZ_LOCALIZED_TEXTS T set (
      LOCALIZED_STR
    ) = ( select B.LOCALIZED_STR
          from CZ_LOCALIZED_TEXTS  B
          where  B.INTL_TEXT_ID = T.INTL_TEXT_ID
          and B.LANGUAGE = T.SOURCE_LANG and B.DELETED_FLAG='0')
  where (
      T.INTL_TEXT_ID,
      T.LANGUAGE
  ) in ( select
      SUBT.INTL_TEXT_ID,
      SUBT.LANGUAGE
    from  CZ_LOCALIZED_TEXTS  SUBB,
          CZ_LOCALIZED_TEXTS  SUBT
    where  SUBB.INTL_TEXT_ID = SUBT.INTL_TEXT_ID
      and  SUBB.LANGUAGE = SUBT.SOURCE_LANG and SUBT.DELETED_FLAG='0' and SUBB.DELETED_FLAG='0'
      and  ( SUBB.LOCALIZED_STR <> SUBT.LOCALIZED_STR
           or ( SUBB.LOCALIZED_STR is null     and SUBT.LOCALIZED_STR is not null )
           or ( SUBB.LOCALIZED_STR is not null and SUBT.LOCALIZED_STR is null ) )
    );
  commit;
*/

  insert into CZ_LOCALIZED_TEXTS (
    LAST_UPDATE_LOGIN,
    INTL_TEXT_ID,
    LOCALIZED_STR,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG,
    model_id,
    ui_def_id,
    seeded_flag,
    UI_PAGE_ID,UI_PAGE_ELEMENT_ID,
    persistent_intl_text_id,
    DELETED_FLAG,
    ORIG_SYS_REF)
 select
    B.LAST_UPDATE_LOGIN,
    B.INTL_TEXT_ID,
    B.LOCALIZED_STR,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    nvl(B.model_id, NO_MODEL_ID),
    B.ui_def_id,
    B.seeded_flag,
    B.UI_PAGE_ID, B.UI_PAGE_ELEMENT_ID,
    B.persistent_intl_text_id,
    B.DELETED_FLAG,
    B.ORIG_SYS_REF
  from  CZ_LOCALIZED_TEXTS  B,
        FND_LANGUAGES      L
  where  L.INSTALLED_FLAG in ('I', 'B')
    and  B.LANGUAGE = userenv('LANG')
    and  not exists
         ( select NULL
           from  CZ_LOCALIZED_TEXTS  T
           where  T.INTL_TEXT_ID = B.INTL_TEXT_ID
             and  T.LANGUAGE = L.LANGUAGE_CODE);
  commit;

end ADD_LANGUAGE;


-- ----------------------------------------------------------------------
-- PROCEDURE:  Translate_Row        PUBLIC
--
-- PARAMETERS:
--  x_<developer key>
--  x_<translated columns>
--  x_owner             user owning the row (SEED or other)
--
-- COMMENT:
--  Called from the FNDLOAD config file in 'NLS' mode to upload
--  translations.
-- ----------------------------------------------------------------------

PROCEDURE Translate_Row
(X_INTL_TEXT_ID    IN  NUMBER,
 X_LOCALIZED_STR   IN  VARCHAR2,
 X_OWNER           IN  VARCHAR2) IS

f_luby    number;  -- entity owner in file

BEGIN

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(X_OWNER);

  UPDATE CZ_LOCALIZED_TEXTS
  SET LOCALIZED_STR     = NVL(X_LOCALIZED_STR, LOCALIZED_STR)
     ,LAST_UPDATE_DATE  = SYSDATE
     ,LAST_UPDATED_BY   = f_luby
     ,last_update_login = 0
     ,source_lang       = userenv('LANG')
  WHERE INTL_TEXT_ID = X_INTL_TEXT_ID
  AND userenv('LANG') IN (language, source_lang);

  IF ( SQL%NOTFOUND ) THEN
    RAISE no_data_found;
  END IF;

END Translate_Row;

procedure LOAD_ROW
(X_INTL_TEXT_ID      in NUMBER,
 X_LOCALIZED_STR     in VARCHAR2,
 X_ORIG_SYS_REF      in VARCHAR2,
 X_CREATION_DATE     in DATE,
 X_LAST_UPDATE_DATE  in DATE,
 X_DELETED_FLAG      in VARCHAR2,
 X_LOCALE_ID         in NUMBER,
 p_model_id          IN NUMBER,
 p_ui_def_id         IN NUMBER,
 X_OWNER             IN VARCHAR2,
 X_PERSISTENT_INTL_TEXT_ID IN NUMBER,
 X_SEEDED_FLAG       IN VARCHAR2,
 X_UI_PAGE_ID        IN NUMBER,
 X_UI_PAGE_ELEMENT_ID IN VARCHAR2) IS

  s_intlid  cz_localized_texts.intl_text_id%type; -- entity intl_text_id
  f_luby    number;   -- entity owner in file
  f_ludate  date;     -- entity update date in file
  row_id varchar2(64);


cursor c_lktx is
  select intl_text_id
  from cz_localized_texts
  where intl_text_id = x_intl_text_id
  and language = userenv('LANG');

begin

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'RRRR-MM-DD'), sysdate);

  open c_lktx;
  fetch c_lktx into s_intlid;

  if (c_lktx%notfound) then
    -- No matching rows
    CZ_LOCALIZED_TEXTS_PKG.INSERT_ROW(
      X_ROWID        => row_id,
      X_INTL_TEXT_ID       => X_INTL_TEXT_ID,
      X_LOCALIZED_STR      => X_LOCALIZED_STR,
      X_ORIG_SYS_REF       => X_ORIG_SYS_REF,
      X_CREATION_DATE      => nvl(to_date(X_CREATION_DATE, 'RRRR-MM-DD'), sysdate),
      X_LAST_UPDATE_DATE   => nvl(to_date(X_LAST_UPDATE_DATE, 'RRRR-MM-DD'), sysdate),
      X_DELETED_FLAG       => X_DELETED_FLAG,
      X_CREATED_BY         => UID,
      X_LAST_UPDATED_BY    => f_luby,
      X_LAST_UPDATE_LOGIN  => UID,
      X_LOCALE_ID          => X_LOCALE_ID,
      p_model_id           => p_model_id,
      p_ui_def_id          => p_ui_def_id,
      X_SEEDED_FLAG        => X_SEEDED_FLAG,
      X_PERSISTENT_INTL_TEXT_ID => X_PERSISTENT_INTL_TEXT_ID,
      X_UI_PAGE_ID => X_UI_PAGE_ID,
      X_UI_PAGE_ELEMENT_ID => X_UI_PAGE_ELEMENT_ID
      );
  else
    loop
          -- Update row in all matching locales
      CZ_LOCALIZED_TEXTS_PKG.UPDATE_ROW (
        X_INTL_TEXT_ID => X_INTL_TEXT_ID,
        X_LOCALIZED_STR => X_LOCALIZED_STR,
        X_ORIG_SYS_REF => X_ORIG_SYS_REF,
        X_CREATION_DATE => SYSDATE,
        X_LAST_UPDATE_DATE => f_ludate,
        X_DELETED_FLAG => X_DELETED_FLAG,
        X_CREATED_BY => UID,
        X_LAST_UPDATED_BY => f_luby,
        X_LAST_UPDATE_LOGIN => 0,
        X_LOCALE_ID => X_LOCALE_ID,
        p_model_id => p_model_id,
        p_ui_def_id => p_ui_def_id,
        X_PERSISTENT_INTL_TEXT_ID => X_PERSISTENT_INTL_TEXT_ID,
        X_SEEDED_FLAG => X_SEEDED_FLAG,
        X_UI_PAGE_ID => X_UI_PAGE_ID,
        X_UI_PAGE_ELEMENT_ID => X_UI_PAGE_ELEMENT_ID);

      fetch c_lktx into s_intlid;
      exit when c_lktx%notfound;
    end loop;
  end if;
  close c_lktx;

end LOAD_ROW;

procedure UPDATE_ROW
(X_INTL_TEXT_ID      in NUMBER,
 X_LOCALIZED_STR     in VARCHAR2,
 X_ORIG_SYS_REF      in VARCHAR2,
 X_DELETED_FLAG      in VARCHAR2) is

begin

 update  CZ_LOCALIZED_TEXTS set
         INTL_TEXT_ID     =X_INTL_TEXT_ID
         ,LOCALIZED_STR    = DECODE(userenv('LANG'), language, X_LOCALIZED_STR, source_lang, X_LOCALIZED_STR, localized_str)
         ,ORIG_SYS_REF     =X_ORIG_SYS_REF
         ,DELETED_FLAG     =X_DELETED_FLAG
  where  INTL_TEXT_ID = X_INTL_TEXT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;


procedure LOAD_ROW
(X_INTL_TEXT_ID      in NUMBER,
 X_LOCALIZED_STR     in VARCHAR2,
 X_ORIG_SYS_REF      in VARCHAR2,
 X_DELETED_FLAG      in VARCHAR2) IS

  s_intlid  cz_localized_texts.intl_text_id%type; -- entity intl_text_id
  row_id varchar2(64);


cursor c_lktx is
  select intl_text_id
  from cz_localized_texts
  where intl_text_id = x_intl_text_id
  and language = userenv('LANG');

begin

  open c_lktx;
  fetch c_lktx into s_intlid;

  if (c_lktx%notfound) then
    -- No matching rows
    CZ_LOCALIZED_TEXTS_PKG.INSERT_ROW(
      X_ROWID        => row_id,
      X_INTL_TEXT_ID       => X_INTL_TEXT_ID,
      X_LOCALIZED_STR      => X_LOCALIZED_STR,
      X_ORIG_SYS_REF       => X_ORIG_SYS_REF,
      X_CREATION_DATE      =>  sysdate,
      X_LAST_UPDATE_DATE   =>  sysdate,
      X_DELETED_FLAG       => X_DELETED_FLAG,
      X_CREATED_BY         => null,
      X_LAST_UPDATED_BY    => null,
      X_LAST_UPDATE_LOGIN  => null,
      X_LOCALE_ID          => null,
      p_model_id           => null,
      p_ui_def_id          => null,
      X_SEEDED_FLAG        => null,
      X_PERSISTENT_INTL_TEXT_ID => null,
      X_UI_PAGE_ID => null,
      X_UI_PAGE_ELEMENT_ID => null
      );
  else
    loop
          -- Update row in all matching locales
      CZ_LOCALIZED_TEXTS_PKG.UPDATE_ROW (
        X_INTL_TEXT_ID => X_INTL_TEXT_ID,
        X_LOCALIZED_STR => X_LOCALIZED_STR,
        X_ORIG_SYS_REF => X_ORIG_SYS_REF,
        X_DELETED_FLAG => X_DELETED_FLAG);

      fetch c_lktx into s_intlid;
      exit when c_lktx%notfound;
    end loop;
  end if;
  close c_lktx;

end LOAD_ROW;


end CZ_LOCALIZED_TEXTS_PKG;

/
