--------------------------------------------------------
--  DDL for Package Body IEC_O_ALG_ACTION_DEFS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_O_ALG_ACTION_DEFS_PKG" as
/* $Header: IECHACDB.pls 120.2 2005/07/21 10:35:00 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ACTION_CODE in VARCHAR2,
  X_ACTION_TYPE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_SUBST_TEXT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from IEC_O_ALG_ACTION_DEFS_B
    where ACTION_CODE = X_ACTION_CODE
    ;
begin
  insert into IEC_O_ALG_ACTION_DEFS_B (
    ACTION_CODE,
    ACTION_TYPE_CODE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ACTION_CODE,
    X_ACTION_TYPE_CODE,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into IEC_O_ALG_ACTION_DEFS_TL (
    ACTION_CODE,
    DESCRIPTION,
    SUBST_TEXT,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_ACTION_CODE,
    X_DESCRIPTION,
    X_SUBST_TEXT,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IEC_O_ALG_ACTION_DEFS_TL T
    where T.ACTION_CODE = X_ACTION_CODE
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
  X_ACTION_CODE in VARCHAR2,
  X_ACTION_TYPE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_SUBST_TEXT in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER
    from IEC_O_ALG_ACTION_DEFS_B
    where ACTION_CODE = X_ACTION_CODE
    for update of ACTION_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      SUBST_TEXT,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IEC_O_ALG_ACTION_DEFS_TL
    where ACTION_CODE = X_ACTION_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ACTION_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DESCRIPTION = X_DESCRIPTION)
          AND (tlinfo.SUBST_TEXT = X_SUBST_TEXT)
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
  X_ACTION_CODE in VARCHAR2,
  X_ACTION_TYPE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_SUBST_TEXT in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IEC_O_ALG_ACTION_DEFS_B set
    ACTION_TYPE_CODE = X_ACTION_TYPE_CODE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ACTION_CODE = X_ACTION_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IEC_O_ALG_ACTION_DEFS_TL set
    DESCRIPTION = X_DESCRIPTION,
    SUBST_TEXT = X_SUBST_TEXT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ACTION_CODE = X_ACTION_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure LOAD_ROW (
  X_ACTION_CODE in VARCHAR2,
  X_ACTION_TYPE_CODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SUBST_TEXT in VARCHAR2,
  P_OWNER IN VARCHAR2) is
  user_id		     number := 0;
  x_rowid		     VARCHAR2(500) := null;
begin
  USER_ID := fnd_load_util.owner_id(P_OWNER);

  UPDATE_ROW (X_ACTION_CODE,X_ACTION_TYPE_CODE,0,X_DESCRIPTION,X_SUBST_TEXT,sysdate,user_id,0);
  EXCEPTION
    when no_data_found then
	INSERT_ROW (X_ROWID,X_ACTION_CODE,X_ACTION_TYPE_CODE,0,X_DESCRIPTION,X_SUBST_TEXT, sysdate,user_id,sysdate,user_id,0);
end LOAD_ROW;

procedure LOAD_SEED_ROW (
  X_upload_mode	in VARCHAR2,
  X_ACTION_CODE in VARCHAR2,
  X_ACTION_TYPE_CODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SUBST_TEXT in VARCHAR2,
  P_OWNER IN VARCHAR2) is
begin
         if(X_upload_mode='NLS') then
           IEC_O_ALG_ACTION_DEFS_PKG.TRANSLATE_ROW (
					 	X_ACTION_CODE,
						X_DESCRIPTION,
						X_SUBST_TEXT,
						P_OWNER);
         else
           IEC_O_ALG_ACTION_DEFS_PKG.LOAD_ROW (
					 	X_ACTION_CODE,
						X_ACTION_TYPE_CODE,
						X_DESCRIPTION,
						X_SUBST_TEXT,
						P_OWNER);
         end if;

end LOAD_SEED_ROW;

procedure TRANSLATE_ROW (
  X_ACTION_CODE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SUBST_TEXT in VARCHAR2,
  P_OWNER IN VARCHAR2)is
BEGIN
      UPDATE iec_o_alg_action_defs_tl SET
        source_lang = userenv('LANG'),
	DESCRIPTION = X_DESCRIPTION,
	SUBST_TEXT = X_SUBST_TEXT ,
      last_update_date = sysdate,
      last_updated_by = fnd_load_util.owner_id(P_OWNER),
      last_update_login = 0
      WHERE ACTION_CODE = X_ACTION_CODE
      AND   userenv('LANG') IN (language, source_lang);

END TRANSLATE_ROW;

procedure DELETE_ROW (
  X_ACTION_CODE in VARCHAR2
) is
begin
  delete from IEC_O_ALG_ACTION_DEFS_TL
  where ACTION_CODE = X_ACTION_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEC_O_ALG_ACTION_DEFS_B
  where ACTION_CODE = X_ACTION_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IEC_O_ALG_ACTION_DEFS_TL T
  where not exists
    (select NULL
    from IEC_O_ALG_ACTION_DEFS_B B
    where B.ACTION_CODE = T.ACTION_CODE
    );

  update IEC_O_ALG_ACTION_DEFS_TL T set (
      DESCRIPTION,
      SUBST_TEXT
    ) = (select
      B.DESCRIPTION,
      B.SUBST_TEXT
    from IEC_O_ALG_ACTION_DEFS_TL B
    where B.ACTION_CODE = T.ACTION_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ACTION_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.ACTION_CODE,
      SUBT.LANGUAGE
    from IEC_O_ALG_ACTION_DEFS_TL SUBB, IEC_O_ALG_ACTION_DEFS_TL SUBT
    where SUBB.ACTION_CODE = SUBT.ACTION_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or SUBB.SUBST_TEXT <> SUBT.SUBST_TEXT
  ));

  insert into IEC_O_ALG_ACTION_DEFS_TL (
    ACTION_CODE,
    DESCRIPTION,
    SUBST_TEXT,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.ACTION_CODE,
    B.DESCRIPTION,
    B.SUBST_TEXT,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEC_O_ALG_ACTION_DEFS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEC_O_ALG_ACTION_DEFS_TL T
    where T.ACTION_CODE = B.ACTION_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end IEC_O_ALG_ACTION_DEFS_PKG;

/
