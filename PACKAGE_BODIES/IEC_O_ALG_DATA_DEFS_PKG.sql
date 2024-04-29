--------------------------------------------------------
--  DDL for Package Body IEC_O_ALG_DATA_DEFS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_O_ALG_DATA_DEFS_PKG" as
/* $Header: IECHDADB.pls 120.2 2005/07/21 10:35:06 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DATA_CODE in VARCHAR2,
  X_OWNER_CODE in VARCHAR2,
  X_OWNER_TYPE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REF_NAME in VARCHAR2,
  X_REF_VALUE in VARCHAR2,
  X_REF_TABLE in VARCHAR2,
  X_REF_WHERE in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_IS_REF_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from IEC_O_ALG_DATA_DEFS_B
    where DATA_CODE = X_DATA_CODE
    and OWNER_CODE = X_OWNER_CODE
    and OWNER_TYPE_CODE = X_OWNER_TYPE_CODE
    ;
begin
  insert into IEC_O_ALG_DATA_DEFS_B (
    OBJECT_VERSION_NUMBER,
    REF_NAME,
    REF_VALUE,
    REF_TABLE,
    REF_WHERE,
    DATA_TYPE,
    IS_REF_FLAG,
    DATA_CODE,
    OWNER_CODE,
    OWNER_TYPE_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_OBJECT_VERSION_NUMBER,
    X_REF_NAME,
    X_REF_VALUE,
    X_REF_TABLE,
    X_REF_WHERE,
    X_DATA_TYPE,
    X_IS_REF_FLAG,
    X_DATA_CODE,
    X_OWNER_CODE,
    X_OWNER_TYPE_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into IEC_O_ALG_DATA_DEFS_TL (
    DATA_CODE,
    OWNER_CODE,
    OWNER_TYPE_CODE,
    NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DATA_CODE,
    X_OWNER_CODE,
    X_OWNER_TYPE_CODE,
    X_NAME,
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
    from IEC_O_ALG_DATA_DEFS_TL T
    where T.DATA_CODE = X_DATA_CODE
    and T.OWNER_CODE = X_OWNER_CODE
    and T.OWNER_TYPE_CODE = X_OWNER_TYPE_CODE
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
  X_DATA_CODE in VARCHAR2,
  X_OWNER_CODE in VARCHAR2,
  X_OWNER_TYPE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REF_NAME in VARCHAR2,
  X_REF_VALUE in VARCHAR2,
  X_REF_TABLE in VARCHAR2,
  X_REF_WHERE in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_IS_REF_FLAG in VARCHAR2,
  X_NAME in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      REF_NAME,
      REF_VALUE,
      REF_TABLE,
      REF_WHERE,
      DATA_TYPE,
      IS_REF_FLAG
    from IEC_O_ALG_DATA_DEFS_B
    where DATA_CODE = X_DATA_CODE
    and OWNER_CODE = X_OWNER_CODE
    and OWNER_TYPE_CODE = X_OWNER_TYPE_CODE
    for update of DATA_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IEC_O_ALG_DATA_DEFS_TL
    where DATA_CODE = X_DATA_CODE
    and OWNER_CODE = X_OWNER_CODE
    and OWNER_TYPE_CODE = X_OWNER_TYPE_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DATA_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND ((recinfo.REF_NAME = X_REF_NAME)
           OR ((recinfo.REF_NAME is null) AND (X_REF_NAME is null)))
      AND ((recinfo.REF_VALUE = X_REF_VALUE)
           OR ((recinfo.REF_VALUE is null) AND (X_REF_VALUE is null)))
      AND ((recinfo.REF_TABLE = X_REF_TABLE)
           OR ((recinfo.REF_TABLE is null) AND (X_REF_TABLE is null)))
      AND ((recinfo.REF_WHERE = X_REF_WHERE)
           OR ((recinfo.REF_WHERE is null) AND (X_REF_WHERE is null)))
      AND ((recinfo.DATA_TYPE = X_DATA_TYPE)
           OR ((recinfo.DATA_TYPE is null) AND (X_DATA_TYPE is null)))
      AND (recinfo.IS_REF_FLAG = X_IS_REF_FLAG)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
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
  X_DATA_CODE in VARCHAR2,
  X_OWNER_CODE in VARCHAR2,
  X_OWNER_TYPE_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REF_NAME in VARCHAR2,
  X_REF_VALUE in VARCHAR2,
  X_REF_TABLE in VARCHAR2,
  X_REF_WHERE in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_IS_REF_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IEC_O_ALG_DATA_DEFS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    REF_NAME = X_REF_NAME,
    REF_VALUE = X_REF_VALUE,
    REF_TABLE = X_REF_TABLE,
    REF_WHERE = X_REF_WHERE,
    DATA_TYPE = X_DATA_TYPE,
    IS_REF_FLAG = X_IS_REF_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DATA_CODE = X_DATA_CODE
  and OWNER_CODE = X_OWNER_CODE
  and OWNER_TYPE_CODE = X_OWNER_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IEC_O_ALG_DATA_DEFS_TL set
    NAME = X_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DATA_CODE = X_DATA_CODE
  and OWNER_CODE = X_OWNER_CODE
  and OWNER_TYPE_CODE = X_OWNER_TYPE_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure LOAD_ROW (
  X_DATA_CODE in VARCHAR2,
  X_OWNER_CODE in VARCHAR2,
  X_OWNER_TYPE_CODE in VARCHAR2,
  X_REF_NAME in VARCHAR2,
  X_REF_VALUE in VARCHAR2,
  X_REF_TABLE in VARCHAR2,
  X_REF_WHERE in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_IS_REF_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  P_OWNER IN VARCHAR2) is
  user_id		     number := 0;
  x_rowid		     VARCHAR2(500) := null;
begin

  USER_ID := fnd_load_util.owner_id(P_OWNER);

  UPDATE_ROW (X_DATA_CODE,X_OWNER_CODE,X_OWNER_TYPE_CODE,0,X_REF_NAME,X_REF_VALUE, X_REF_TABLE,X_REF_WHERE,X_DATA_TYPE,X_IS_REF_FLAG,X_NAME,sysdate,user_id,0);
  EXCEPTION
    when no_data_found then
	INSERT_ROW (X_ROWID,X_DATA_CODE,X_OWNER_CODE,X_OWNER_TYPE_CODE,0,X_REF_NAME,X_REF_VALUE, X_REF_TABLE,X_REF_WHERE,X_DATA_TYPE,X_IS_REF_FLAG,X_NAME,sysdate,user_id,sysdate,user_id,0);
end LOAD_ROW;

procedure LOAD_SEED_ROW (
  X_upload_mode	in VARCHAR2,
  X_DATA_CODE in VARCHAR2,
  X_OWNER_CODE in VARCHAR2,
  X_OWNER_TYPE_CODE in VARCHAR2,
  X_REF_NAME in VARCHAR2,
  X_REF_VALUE in VARCHAR2,
  X_REF_TABLE in VARCHAR2,
  X_REF_WHERE in VARCHAR2,
  X_DATA_TYPE in VARCHAR2,
  X_IS_REF_FLAG in VARCHAR2,
  X_NAME in VARCHAR2,
  P_OWNER IN VARCHAR2) is
begin
         if(X_upload_mode='NLS') then
           IEC_O_ALG_DATA_DEFS_PKG.TRANSLATE_ROW (
					 	X_DATA_CODE,
						X_OWNER_CODE,
						X_OWNER_TYPE_CODE,
						X_NAME,
						P_OWNER);
         else
           IEC_O_ALG_DATA_DEFS_PKG.LOAD_ROW (
            				X_DATA_CODE,
            				X_OWNER_CODE,
            				X_OWNER_TYPE_CODE,
            				X_REF_NAME,
            				X_REF_VALUE,
            				X_REF_TABLE,
            				X_REF_WHERE,
            				X_DATA_TYPE,
            				X_IS_REF_FLAG,
            				X_NAME,
					P_OWNER);
         end if;

end LOAD_SEED_ROW;

procedure TRANSLATE_ROW (
  X_DATA_CODE in VARCHAR2,
  X_OWNER_CODE in VARCHAR2,
  X_OWNER_TYPE_CODE in VARCHAR2,
  X_NAME in VARCHAR2,
  P_OWNER IN VARCHAR2)is
BEGIN
      UPDATE iec_o_alg_data_defs_tl SET
      source_lang = userenv('LANG'),
      NAME = X_NAME,
      last_update_date = sysdate,
      last_updated_by = fnd_load_util.owner_id(P_OWNER),
      last_update_login = 0
      WHERE DATA_CODE = X_DATA_CODE
      AND OWNER_CODE = X_OWNER_CODE
      AND OWNER_TYPE_CODE = X_OWNER_TYPE_CODE
      AND   userenv('LANG') IN (language, source_lang);

END TRANSLATE_ROW;

procedure DELETE_ROW (
  X_DATA_CODE in VARCHAR2,
  X_OWNER_CODE in VARCHAR2,
  X_OWNER_TYPE_CODE in VARCHAR2
) is
begin
  delete from IEC_O_ALG_DATA_DEFS_TL
  where DATA_CODE = X_DATA_CODE
  and OWNER_CODE = X_OWNER_CODE
  and OWNER_TYPE_CODE = X_OWNER_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEC_O_ALG_DATA_DEFS_B
  where DATA_CODE = X_DATA_CODE
  and OWNER_CODE = X_OWNER_CODE
  and OWNER_TYPE_CODE = X_OWNER_TYPE_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IEC_O_ALG_DATA_DEFS_TL T
  where not exists
    (select NULL
    from IEC_O_ALG_DATA_DEFS_B B
    where B.DATA_CODE = T.DATA_CODE
    and B.OWNER_CODE = T.OWNER_CODE
    and B.OWNER_TYPE_CODE = T.OWNER_TYPE_CODE
    );

  update IEC_O_ALG_DATA_DEFS_TL T set (
      NAME
    ) = (select
      B.NAME
    from IEC_O_ALG_DATA_DEFS_TL B
    where B.DATA_CODE = T.DATA_CODE
    and B.OWNER_CODE = T.OWNER_CODE
    and B.OWNER_TYPE_CODE = T.OWNER_TYPE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DATA_CODE,
      T.OWNER_CODE,
      T.OWNER_TYPE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.DATA_CODE,
      SUBT.OWNER_CODE,
      SUBT.OWNER_TYPE_CODE,
      SUBT.LANGUAGE
    from IEC_O_ALG_DATA_DEFS_TL SUBB, IEC_O_ALG_DATA_DEFS_TL SUBT
    where SUBB.DATA_CODE = SUBT.DATA_CODE
    and SUBB.OWNER_CODE = SUBT.OWNER_CODE
    and SUBB.OWNER_TYPE_CODE = SUBT.OWNER_TYPE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
  ));

  insert into IEC_O_ALG_DATA_DEFS_TL (
    DATA_CODE,
    OWNER_CODE,
    OWNER_TYPE_CODE,
    NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.DATA_CODE,
    B.OWNER_CODE,
    B.OWNER_TYPE_CODE,
    B.NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEC_O_ALG_DATA_DEFS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEC_O_ALG_DATA_DEFS_TL T
    where T.DATA_CODE = B.DATA_CODE
    and T.OWNER_CODE = B.OWNER_CODE
    and T.OWNER_TYPE_CODE = B.OWNER_TYPE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end IEC_O_ALG_DATA_DEFS_PKG;

/
