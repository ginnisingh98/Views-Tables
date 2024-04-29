--------------------------------------------------------
--  DDL for Package Body IEU_UWQM_PRIORITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQM_PRIORITIES_PKG" as
/* $Header: IEUUWQPB.pls 120.1 2005/06/15 23:09:58 appldev  $ */
procedure INSERT_ROW (
  P_PRIORITY_ID in NUMBER,
  P_PRIORITY_CODE in VARCHAR2,
  P_PRIORITY_LEVEL in NUMBER,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2,
  X_ROWID in out nocopy VARCHAR2
) is
  cursor C is select ROWID from IEU_UWQM_PRIORITIES_B
    where PRIORITY_ID = P_PRIORITY_ID
    ;
begin
  insert into IEU_UWQM_PRIORITIES_B (
    PRIORITY_CODE,
    PRIORITY_ID,
    OBJECT_VERSION_NUMBER,
    PRIORITY_LEVEL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    P_PRIORITY_CODE,
    P_PRIORITY_ID,
    1,
    P_PRIORITY_LEVEL,
    SYSDATE,
    FND_GLOBAL.USER_ID,
    SYSDATE,
    FND_GLOBAL.USER_ID,
    FND_GLOBAL.LOGIN_ID
  );

  insert into IEU_UWQM_PRIORITIES_TL (
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    LAST_UPDATED_BY,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    PRIORITY_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    FND_GLOBAL.LOGIN_ID,
    P_NAME,
    P_DESCRIPTION,
    SYSDATE,
    SYSDATE,
    FND_GLOBAL.USER_ID,
    1,
    FND_GLOBAL.USER_ID,
    P_PRIORITY_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IEU_UWQM_PRIORITIES_TL T
    where T.PRIORITY_ID = P_PRIORITY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into x_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  P_PRIORITY_ID in NUMBER,
  P_PRIORITY_CODE in VARCHAR2,
  P_OBJECT_VERSION_NUMBER in NUMBER,
  P_PRIORITY_LEVEL in NUMBER,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      PRIORITY_CODE,
      OBJECT_VERSION_NUMBER,
      PRIORITY_LEVEL
    from IEU_UWQM_PRIORITIES_B
    where PRIORITY_ID = P_PRIORITY_ID
    for update of PRIORITY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IEU_UWQM_PRIORITIES_TL
    where PRIORITY_ID = P_PRIORITY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PRIORITY_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.PRIORITY_CODE = P_PRIORITY_CODE)
      AND (recinfo.OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER)
      AND (recinfo.PRIORITY_LEVEL = P_PRIORITY_LEVEL)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = P_NAME)
          AND (tlinfo.DESCRIPTION = P_DESCRIPTION)
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
  P_PRIORITY_ID in NUMBER,
  P_PRIORITY_CODE in VARCHAR2,
  P_PRIORITY_LEVEL in NUMBER,
  P_NAME in VARCHAR2,
  P_DESCRIPTION in VARCHAR2
) is
begin
  update IEU_UWQM_PRIORITIES_B set
    PRIORITY_CODE = P_PRIORITY_CODE,
    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
    PRIORITY_LEVEL = P_PRIORITY_LEVEL,
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
    LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
  where PRIORITY_ID = P_PRIORITY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IEU_UWQM_PRIORITIES_TL set
    NAME = P_NAME,
    DESCRIPTION = P_DESCRIPTION,
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
    LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
    SOURCE_LANG = userenv('LANG')
  where PRIORITY_ID = P_PRIORITY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  P_PRIORITY_ID in NUMBER
) is
begin
  delete from IEU_UWQM_PRIORITIES_TL
  where PRIORITY_ID = P_PRIORITY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEU_UWQM_PRIORITIES_B
  where PRIORITY_ID = P_PRIORITY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IEU_UWQM_PRIORITIES_TL T
  where not exists
    (select NULL
    from IEU_UWQM_PRIORITIES_B B
    where B.PRIORITY_ID = T.PRIORITY_ID
    );

  update IEU_UWQM_PRIORITIES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from IEU_UWQM_PRIORITIES_TL B
    where B.PRIORITY_ID = T.PRIORITY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PRIORITY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PRIORITY_ID,
      SUBT.LANGUAGE
    from IEU_UWQM_PRIORITIES_TL SUBB, IEU_UWQM_PRIORITIES_TL SUBT
    where SUBB.PRIORITY_ID = SUBT.PRIORITY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into IEU_UWQM_PRIORITIES_TL (
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    LAST_UPDATED_BY,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    PRIORITY_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_LOGIN,
    B.NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.OBJECT_VERSION_NUMBER,
    B.CREATED_BY,
    B.PRIORITY_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEU_UWQM_PRIORITIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEU_UWQM_PRIORITIES_TL T
    where T.PRIORITY_ID = B.PRIORITY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE translate_row (
    p_priority_id IN NUMBER,
    p_name IN VARCHAR2,
    p_description IN VARCHAR2,
    p_owner IN VARCHAR2) IS

BEGIN

      -- only UPDATE rows that have not been altered by user

      UPDATE ieu_uwqm_priorities_tl
      SET
        name = p_name,
        source_lang = userenv('LANG'),
        description = p_description,
        last_update_date = sysdate,
        --last_updated_by = decode(p_owner, 'SEED', 1, 0),
        last_updated_by = fnd_load_util.owner_id(p_owner),
        last_update_login = 0
      WHERE priority_id = p_priority_id
      AND   userenv('LANG') IN (language, source_lang);

END translate_row;

PROCEDURE Load_Row (
                p_priority_id IN NUMBER,
                p_priority_level IN NUMBER,
                p_priority_code IN VARCHAR2,
                p_name IN VARCHAR2,
                p_description IN VARCHAR2,
                p_owner IN VARCHAR2) IS
BEGIN

    DECLARE
       user_id           number := 0;
       X_ROWID          VARCHAR2(50);
    BEGIN

       IF (p_owner = 'SEED') then
          user_id := 1;
       END IF;

      UPDATE_ROW (
       P_PRIORITY_ID,
       P_PRIORITY_CODE,
       P_PRIORITY_LEVEL,
       P_NAME,
       P_DESCRIPTION
      );

     EXCEPTION
        when no_data_found then

      INSERT_ROW (
        P_PRIORITY_ID,
        P_PRIORITY_CODE,
        P_PRIORITY_LEVEL,
        P_NAME,
        P_DESCRIPTION,
        X_ROWID
      );
    END;

END load_row;

PROCEDURE Load_Seed_Row (
                p_upload_mode in VARCHAR2,
                p_priority_id IN NUMBER,
                p_priority_level IN NUMBER,
                p_priority_code IN VARCHAR2,
                p_name IN VARCHAR2,
                p_description IN VARCHAR2,
                p_owner IN VARCHAR2) IS
BEGIN

if (p_upload_mode = 'NLS') then
       TRANSLATE_ROW (
             p_priority_id ,
             p_name ,
             p_description ,
             p_owner );
else
        LOAD_ROW (
             p_priority_id,
             p_priority_level,
             p_priority_code,
             p_name,
             p_description,
             p_owner);
end if;

END Load_Seed_Row;

end IEU_UWQM_PRIORITIES_PKG;

/
