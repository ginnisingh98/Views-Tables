--------------------------------------------------------
--  DDL for Package Body XNP_MSG_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_MSG_TYPES_PKG" as
/* $Header: XNPMSGTB.pls 120.2 2005/07/19 05:27:14 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_MSG_CODE in VARCHAR2,
  X_MSG_TYPE in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_QUEUE_NAME in VARCHAR2,
  X_PROTECTED_FLAG in VARCHAR2,
  X_ROLE_NAME in VARCHAR2,
  X_LAST_COMPILED_DATE in DATE,
  X_VALIDATE_LOGIC in VARCHAR2,
  X_IN_PROCESS_LOGIC in VARCHAR2,
  X_OUT_PROCESS_LOGIC in VARCHAR2,
  X_DEFAULT_PROCESS_LOGIC in VARCHAR2,
  X_DTD_URL in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from XNP_MSG_TYPES_B
    where MSG_CODE = X_MSG_CODE
    ;
begin
  insert into XNP_MSG_TYPES_B (
    MSG_CODE,
    MSG_TYPE,
    STATUS,
    PRIORITY,
    QUEUE_NAME,
    PROTECTED_FLAG,
    ROLE_NAME,
    LAST_COMPILED_DATE,
    VALIDATE_LOGIC,
    IN_PROCESS_LOGIC,
    OUT_PROCESS_LOGIC,
    DEFAULT_PROCESS_LOGIC,
    DTD_URL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_MSG_CODE,
    X_MSG_TYPE,
    X_STATUS,
    X_PRIORITY,
    X_QUEUE_NAME,
    X_PROTECTED_FLAG,
    X_ROLE_NAME,
    X_LAST_COMPILED_DATE,
    X_VALIDATE_LOGIC,
    X_IN_PROCESS_LOGIC,
    X_OUT_PROCESS_LOGIC,
    X_DEFAULT_PROCESS_LOGIC,
    X_DTD_URL,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into XNP_MSG_TYPES_TL (
    MSG_CODE,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_MSG_CODE,
    X_DISPLAY_NAME,
    X_DESCRIPTION,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from XNP_MSG_TYPES_TL T
    where T.MSG_CODE = X_MSG_CODE
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
  X_MSG_CODE in VARCHAR2,
  X_MSG_TYPE in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_QUEUE_NAME in VARCHAR2,
  X_PROTECTED_FLAG in VARCHAR2,
  X_ROLE_NAME in VARCHAR2,
  X_LAST_COMPILED_DATE in DATE,
  X_VALIDATE_LOGIC in VARCHAR2,
  X_IN_PROCESS_LOGIC in VARCHAR2,
  X_OUT_PROCESS_LOGIC in VARCHAR2,
  X_DEFAULT_PROCESS_LOGIC in VARCHAR2,
  X_DTD_URL in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      MSG_TYPE,
      STATUS,
      PRIORITY,
      QUEUE_NAME,
      PROTECTED_FLAG,
      ROLE_NAME,
      LAST_COMPILED_DATE,
      VALIDATE_LOGIC,
      IN_PROCESS_LOGIC,
      OUT_PROCESS_LOGIC,
      DEFAULT_PROCESS_LOGIC,
      DTD_URL
    from XNP_MSG_TYPES_B
    where MSG_CODE = X_MSG_CODE
    for update of MSG_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from XNP_MSG_TYPES_TL
    where MSG_CODE = X_MSG_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of MSG_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.MSG_TYPE = X_MSG_TYPE)
      AND (recinfo.STATUS = X_STATUS)
      AND (recinfo.PRIORITY = X_PRIORITY)
      AND (recinfo.QUEUE_NAME = X_QUEUE_NAME)
      AND (recinfo.PROTECTED_FLAG = X_PROTECTED_FLAG)
      AND ((recinfo.ROLE_NAME = X_ROLE_NAME)
           OR ((recinfo.ROLE_NAME is null) AND (X_ROLE_NAME is null)))
      AND ((recinfo.LAST_COMPILED_DATE = X_LAST_COMPILED_DATE)
           OR ((recinfo.LAST_COMPILED_DATE is null) AND (X_LAST_COMPILED_DATE is null)))
      AND ((recinfo.VALIDATE_LOGIC = X_VALIDATE_LOGIC)
           OR ((recinfo.VALIDATE_LOGIC is null) AND (X_VALIDATE_LOGIC is null)))
      AND ((recinfo.IN_PROCESS_LOGIC = X_IN_PROCESS_LOGIC)
           OR ((recinfo.IN_PROCESS_LOGIC is null) AND (X_IN_PROCESS_LOGIC is null)))
      AND ((recinfo.OUT_PROCESS_LOGIC = X_OUT_PROCESS_LOGIC)
           OR ((recinfo.OUT_PROCESS_LOGIC is null) AND (X_OUT_PROCESS_LOGIC is null)))
      AND ((recinfo.DEFAULT_PROCESS_LOGIC = X_DEFAULT_PROCESS_LOGIC)
           OR ((recinfo.DEFAULT_PROCESS_LOGIC is null) AND (X_DEFAULT_PROCESS_LOGIC is null)))
      AND ((recinfo.DTD_URL = X_DTD_URL)
           OR ((recinfo.DTD_URL is null) AND (X_DTD_URL is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
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
  X_MSG_CODE in VARCHAR2,
  X_MSG_TYPE in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_QUEUE_NAME in VARCHAR2,
  X_PROTECTED_FLAG in VARCHAR2,
  X_ROLE_NAME in VARCHAR2,
  X_LAST_COMPILED_DATE in DATE,
  X_VALIDATE_LOGIC in VARCHAR2,
  X_IN_PROCESS_LOGIC in VARCHAR2,
  X_OUT_PROCESS_LOGIC in VARCHAR2,
  X_DEFAULT_PROCESS_LOGIC in VARCHAR2,
  X_DTD_URL in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update XNP_MSG_TYPES_B set
    MSG_TYPE = X_MSG_TYPE,
    STATUS = X_STATUS,
    PRIORITY = X_PRIORITY,
    QUEUE_NAME = X_QUEUE_NAME,
    PROTECTED_FLAG = X_PROTECTED_FLAG,
    ROLE_NAME = X_ROLE_NAME,
    LAST_COMPILED_DATE = X_LAST_COMPILED_DATE,
    VALIDATE_LOGIC = X_VALIDATE_LOGIC,
    IN_PROCESS_LOGIC = X_IN_PROCESS_LOGIC,
    OUT_PROCESS_LOGIC = X_OUT_PROCESS_LOGIC,
    DEFAULT_PROCESS_LOGIC = X_DEFAULT_PROCESS_LOGIC,
    DTD_URL = X_DTD_URL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where MSG_CODE = X_MSG_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update XNP_MSG_TYPES_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where MSG_CODE = X_MSG_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_MSG_CODE in VARCHAR2
) is
begin
  delete from XNP_MSG_TYPES_TL
  where MSG_CODE = X_MSG_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from XNP_MSG_TYPES_B
  where MSG_CODE = X_MSG_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from XNP_MSG_TYPES_TL T
  where not exists
    (select NULL
    from XNP_MSG_TYPES_B B
    where B.MSG_CODE = T.MSG_CODE
    );

  update XNP_MSG_TYPES_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from XNP_MSG_TYPES_TL B
    where B.MSG_CODE = T.MSG_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.MSG_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.MSG_CODE,
      SUBT.LANGUAGE
    from XNP_MSG_TYPES_TL SUBB, XNP_MSG_TYPES_TL SUBT
    where SUBB.MSG_CODE = SUBT.MSG_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into XNP_MSG_TYPES_TL (
    MSG_CODE,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.MSG_CODE,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from XNP_MSG_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from XNP_MSG_TYPES_TL T
    where T.MSG_CODE = B.MSG_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_MSG_CODE in VARCHAR2,
  X_MSG_TYPE in VARCHAR2,
  X_STATUS in VARCHAR2,
  X_PRIORITY in NUMBER,
  X_QUEUE_NAME in VARCHAR2,
  X_PROTECTED_FLAG in VARCHAR2,
  X_ROLE_NAME in VARCHAR2,
  X_LAST_COMPILED_DATE in DATE,
  X_VALIDATE_LOGIC in VARCHAR2,
  X_IN_PROCESS_LOGIC in VARCHAR2,
  X_OUT_PROCESS_LOGIC in VARCHAR2,
  X_DEFAULT_PROCESS_LOGIC in VARCHAR2,
  X_DTD_URL in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2) IS
BEGIN
  DECLARE
    l_user_id    NUMBER := 0;
    l_row_id     varchar2(64);
  BEGIN

    /*The following derivation has been replaced with the FND API. */
    /*dputhiye 19-JUL-2005. R12 ATG Seed Version by Date Uptake    */
    --IF (X_OWNER = 'SEED') THEN
    --  l_user_id := 1;
    --END IF;
    l_user_id  := fnd_load_util.owner_id(X_OWNER);

    XNP_MSG_TYPES_PKG.UPDATE_ROW (
      X_MSG_CODE => X_MSG_CODE,
      X_MSG_TYPE => X_MSG_TYPE,
      X_STATUS => X_STATUS,
      X_PRIORITY => X_PRIORITY,
      X_QUEUE_NAME => X_QUEUE_NAME,
      X_PROTECTED_FLAG => X_PROTECTED_FLAG,
      X_ROLE_NAME => X_ROLE_NAME,
      X_LAST_COMPILED_DATE => X_LAST_COMPILED_DATE,
      X_VALIDATE_LOGIC => X_VALIDATE_LOGIC,
      X_IN_PROCESS_LOGIC => X_IN_PROCESS_LOGIC,
      X_OUT_PROCESS_LOGIC => X_OUT_PROCESS_LOGIC,
      X_DEFAULT_PROCESS_LOGIC => X_DEFAULT_PROCESS_LOGIC,
      X_DTD_URL => X_DTD_URL,
      X_DISPLAY_NAME => X_DISPLAY_NAME,
      X_DESCRIPTION => X_DESCRIPTION,
      X_LAST_UPDATE_DATE => sysdate,
      X_LAST_UPDATED_BY => l_user_id,
      X_LAST_UPDATE_LOGIN => 0);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       XNP_MSG_TYPES_PKG.INSERT_ROW (
          X_ROWID => l_row_id,
          X_MSG_CODE => X_MSG_CODE,
          X_MSG_TYPE => X_MSG_TYPE,
          X_STATUS => X_STATUS,
          X_PRIORITY => X_PRIORITY,
          X_QUEUE_NAME => X_QUEUE_NAME,
          X_PROTECTED_FLAG => X_PROTECTED_FLAG,
          X_ROLE_NAME => X_ROLE_NAME,
          X_LAST_COMPILED_DATE => X_LAST_COMPILED_DATE,
          X_VALIDATE_LOGIC => X_VALIDATE_LOGIC,
          X_IN_PROCESS_LOGIC => X_IN_PROCESS_LOGIC,
          X_OUT_PROCESS_LOGIC => X_OUT_PROCESS_LOGIC,
          X_DEFAULT_PROCESS_LOGIC => X_DEFAULT_PROCESS_LOGIC,
          X_DTD_URL => X_DTD_URL,
          X_DISPLAY_NAME => X_DISPLAY_NAME,
          X_DESCRIPTION => X_DESCRIPTION,
          X_CREATION_DATE => sysdate,
          X_CREATED_BY => l_user_id,
          X_LAST_UPDATE_DATE => sysdate,
          X_LAST_UPDATED_BY => l_user_id,
          X_LAST_UPDATE_LOGIN => 0);
   END;
END LOAD_ROW;
procedure TRANSLATE_ROW (
  X_MSG_CODE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2) IS
BEGIN
  -- Only update rows which have not been altered by user
  UPDATE XNP_MSG_TYPES_TL
  SET description = X_DESCRIPTION,
      display_name = X_DISPLAY_NAME,
      source_lang = userenv('LANG'),
      last_update_date = sysdate,
      --last_updated_by = decode(X_OWNER, 'SEED', 1, 0),		/*dputhiye 19-JUL-2005. DECODE replaced with FND API.*/
      last_updated_by = fnd_load_util.owner_id(X_OWNER),
      last_update_login = 0
  WHERE msg_code = X_MSG_CODE
    AND userenv('LANG') IN (language, source_lang);
END TRANSLATE_ROW;
end XNP_MSG_TYPES_PKG;

/
