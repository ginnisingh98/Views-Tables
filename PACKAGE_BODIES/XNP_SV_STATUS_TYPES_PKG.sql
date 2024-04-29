--------------------------------------------------------
--  DDL for Package Body XNP_SV_STATUS_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_SV_STATUS_TYPES_PKG" as
/* $Header: XNPSTTPB.pls 120.2 2005/07/19 04:03:30 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_STATUS_TYPE_CODE in VARCHAR2,
  X_PHASE_INDICATOR in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_INITIAL_FLAG in VARCHAR2,
  X_INITIAL_FLAG_ENFORCE_SEQ in NUMBER,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from XNP_SV_STATUS_TYPES_B
    where STATUS_TYPE_CODE = X_STATUS_TYPE_CODE
    ;
begin
  insert into XNP_SV_STATUS_TYPES_B (
    STATUS_TYPE_CODE,
    PHASE_INDICATOR,
    ACTIVE_FLAG,
    INITIAL_FLAG,
    INITIAL_FLAG_ENFORCE_SEQ,
    DISPLAY_SEQUENCE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_STATUS_TYPE_CODE,
    X_PHASE_INDICATOR,
    X_ACTIVE_FLAG,
    X_INITIAL_FLAG,
    X_INITIAL_FLAG_ENFORCE_SEQ,
    X_DISPLAY_SEQUENCE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into XNP_SV_STATUS_TYPES_TL (
    STATUS_TYPE_CODE,
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
    X_STATUS_TYPE_CODE,
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
    from XNP_SV_STATUS_TYPES_TL T
    where T.STATUS_TYPE_CODE = X_STATUS_TYPE_CODE
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
  X_STATUS_TYPE_CODE in VARCHAR2,
  X_PHASE_INDICATOR in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_INITIAL_FLAG in VARCHAR2,
  X_INITIAL_FLAG_ENFORCE_SEQ in NUMBER,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      PHASE_INDICATOR,
      ACTIVE_FLAG,
      INITIAL_FLAG,
      INITIAL_FLAG_ENFORCE_SEQ,
      DISPLAY_SEQUENCE
    from XNP_SV_STATUS_TYPES_B
    where STATUS_TYPE_CODE = X_STATUS_TYPE_CODE
    for update of STATUS_TYPE_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from XNP_SV_STATUS_TYPES_TL
    where STATUS_TYPE_CODE = X_STATUS_TYPE_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of STATUS_TYPE_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.PHASE_INDICATOR = X_PHASE_INDICATOR)
      AND (recinfo.ACTIVE_FLAG = X_ACTIVE_FLAG)
      AND (recinfo.INITIAL_FLAG = X_INITIAL_FLAG)
      AND (recinfo.INITIAL_FLAG_ENFORCE_SEQ = X_INITIAL_FLAG_ENFORCE_SEQ)
      AND (recinfo.DISPLAY_SEQUENCE = X_DISPLAY_SEQUENCE)
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
  X_STATUS_TYPE_CODE in VARCHAR2,
  X_PHASE_INDICATOR in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_INITIAL_FLAG in VARCHAR2,
  X_INITIAL_FLAG_ENFORCE_SEQ in NUMBER,
  X_DISPLAY_SEQUENCE in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update XNP_SV_STATUS_TYPES_B set
    PHASE_INDICATOR = X_PHASE_INDICATOR,
    ACTIVE_FLAG = X_ACTIVE_FLAG,
    INITIAL_FLAG = X_INITIAL_FLAG,
    INITIAL_FLAG_ENFORCE_SEQ = X_INITIAL_FLAG_ENFORCE_SEQ,
    DISPLAY_SEQUENCE = X_DISPLAY_SEQUENCE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where STATUS_TYPE_CODE = X_STATUS_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update XNP_SV_STATUS_TYPES_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where STATUS_TYPE_CODE = X_STATUS_TYPE_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_STATUS_TYPE_CODE in VARCHAR2
) is
begin
  delete from XNP_SV_STATUS_TYPES_TL
  where STATUS_TYPE_CODE = X_STATUS_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from XNP_SV_STATUS_TYPES_B
  where STATUS_TYPE_CODE = X_STATUS_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from XNP_SV_STATUS_TYPES_TL T
  where not exists
    (select NULL
    from XNP_SV_STATUS_TYPES_B B
    where B.STATUS_TYPE_CODE = T.STATUS_TYPE_CODE
    );

  update XNP_SV_STATUS_TYPES_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from XNP_SV_STATUS_TYPES_TL B
    where B.STATUS_TYPE_CODE = T.STATUS_TYPE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STATUS_TYPE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.STATUS_TYPE_CODE,
      SUBT.LANGUAGE
    from XNP_SV_STATUS_TYPES_TL SUBB, XNP_SV_STATUS_TYPES_TL SUBT
    where SUBB.STATUS_TYPE_CODE = SUBT.STATUS_TYPE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into XNP_SV_STATUS_TYPES_TL (
    STATUS_TYPE_CODE,
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
    B.STATUS_TYPE_CODE,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from XNP_SV_STATUS_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from XNP_SV_STATUS_TYPES_TL T
    where T.STATUS_TYPE_CODE = B.STATUS_TYPE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
procedure LOAD_ROW (
  X_STATUS_TYPE_CODE in VARCHAR2,
  X_PHASE_INDICATOR in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_INITIAL_FLAG in VARCHAR2,
  X_INITIAL_FLAG_ENFORCE_SEQ in NUMBER,
  X_DISPLAY_SEQUENCE in NUMBER,
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

    XNP_SV_STATUS_TYPES_PKG.UPDATE_ROW (
      X_STATUS_TYPE_CODE => X_STATUS_TYPE_CODE,
      X_PHASE_INDICATOR => X_PHASE_INDICATOR,
      X_ACTIVE_FLAG => X_ACTIVE_FLAG,
      X_INITIAL_FLAG => X_INITIAL_FLAG,
      X_INITIAL_FLAG_ENFORCE_SEQ => X_INITIAL_FLAG_ENFORCE_SEQ,
      X_DISPLAY_SEQUENCE => X_DISPLAY_SEQUENCE,
      X_DISPLAY_NAME => X_DISPLAY_NAME,
      X_DESCRIPTION => X_DESCRIPTION,
      X_LAST_UPDATE_DATE => sysdate,
      X_LAST_UPDATED_BY => l_user_id,
      X_LAST_UPDATE_LOGIN => 0);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       XNP_SV_STATUS_TYPES_PKG.INSERT_ROW (
         X_ROWID => l_row_id,
         X_STATUS_TYPE_CODE => X_STATUS_TYPE_CODE,
         X_PHASE_INDICATOR => X_PHASE_INDICATOR,
         X_ACTIVE_FLAG => X_ACTIVE_FLAG,
         X_INITIAL_FLAG => X_INITIAL_FLAG,
         X_INITIAL_FLAG_ENFORCE_SEQ => X_INITIAL_FLAG_ENFORCE_SEQ,
         X_DISPLAY_SEQUENCE => X_DISPLAY_SEQUENCE,
         X_DISPLAY_NAME => X_DISPLAY_NAME,
         X_DESCRIPTION => X_DESCRIPTION,
         X_CREATION_DATE => sysdate,
         X_CREATED_BY => l_user_id,
         X_LAST_UPDATE_DATE => sysdate,
         X_LAST_UPDATED_BY => l_user_id,
         X_LAST_UPDATE_LOGIN => 0);
  END LOAD_ROW;
END LOAD_ROW;
procedure TRANSLATE_ROW (
  X_STATUS_TYPE_CODE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2) IS
BEGIN
  -- Only update rows which have not been altered by user
  UPDATE XNP_SV_STATUS_TYPES_TL
  SET description = X_DESCRIPTION,
      display_name = X_DISPLAY_NAME,
      source_lang = userenv('LANG'),
      last_update_date = sysdate,
      --last_updated_by = decode(X_OWNER, 'SEED', 1, 0),		/*dputhiye 19-JUL-2005. DECODE replaced with FND API.*/
      last_updated_by = fnd_load_util.owner_id(X_OWNER),
      last_update_login = 0
  WHERE status_type_code = X_STATUS_TYPE_CODE
    AND userenv('LANG') IN (language, source_lang);
END TRANSLATE_ROW;
end XNP_SV_STATUS_TYPES_PKG;

/
