--------------------------------------------------------
--  DDL for Package Body IEC_G_CPN_PERSONALIZE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_G_CPN_PERSONALIZE_PKG" as
/* $Header: IECCPB.pls 120.3 2005/07/13 13:11:08 appldev noship $ */


procedure INSERT_ROW (
  X_ROWID out nocopy VARCHAR2,
  X_CPN_PERSONALIZE_ID in NUMBER,
  X_SEARCH_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
  ) is
  cursor C is select ROWID from IEC_G_CPN_PERSONALIZE_B
    where CPN_PERSONALIZE_ID = X_CPN_PERSONALIZE_ID
    ;
begin
  x_rowid := NULL;

  insert into IEC_G_CPN_PERSONALIZE_B (
    CPN_PERSONALIZE_ID,
    OBJECT_VERSION_NUMBER,
    OWNER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_CPN_PERSONALIZE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_OWNER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into IEC_G_CPN_PERSONALIZE_TL (
    CPN_PERSONALIZE_ID,
    SEARCH_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CPN_PERSONALIZE_ID,
    X_SEARCH_NAME,
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
    from IEC_G_CPN_PERSONALIZE_TL T
    where T.CPN_PERSONALIZE_ID = X_CPN_PERSONALIZE_ID
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
  X_CPN_PERSONALIZE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER
    from IEC_G_CPN_PERSONALIZE_B
    where CPN_PERSONALIZE_ID = X_CPN_PERSONALIZE_ID
    for update of CPN_PERSONALIZE_ID nowait;
  recinfo c%rowtype;

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

  return;
end LOCK_ROW;


procedure UPDATE_ROW (
  X_CPN_PERSONALIZE_ID in NUMBER,
  X_SEARCH_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IEC_G_CPN_PERSONALIZE_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where CPN_PERSONALIZE_ID  = X_CPN_PERSONALIZE_ID ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;


procedure DELETE_ROW (
  X_CPN_PERSONALIZE_ID in NUMBER
) is
begin
  delete from IEC_G_CPN_PERSONALIZE_B
  where CPN_PERSONALIZE_ID  = X_CPN_PERSONALIZE_ID;

  delete from IEC_G_CPN_PERSONALIZE_TL
  where CPN_PERSONALIZE_ID  = X_CPN_PERSONALIZE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure TRANSLATE_ROW (
  X_CPN_PERSONALIZE_ID in NUMBER,
  X_SEARCH_NAME in VARCHAR2,
  P_OWNER IN VARCHAR2
) is
BEGIN
      UPDATE IEC_G_CPN_PERSONALIZE_TL SET
        source_lang = userenv('LANG'),
	SEARCH_NAME = X_SEARCH_NAME,
      last_update_date = sysdate,
      last_updated_by = fnd_load_util.owner_id(P_OWNER),
      last_update_login = 0
      WHERE CPN_PERSONALIZE_ID = X_CPN_PERSONALIZE_ID
      AND   userenv('LANG') IN (language, source_lang);

END TRANSLATE_ROW;


procedure LOAD_ROW (
  X_CPN_PERSONALIZE_ID NUMBER,
  X_SEARCH_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_OWNER_REF in VARCHAR2
) is


  USER_ID NUMBER;
  ROW_ID  VARCHAR2(500);

begin

  USER_ID := fnd_load_util.owner_id(X_OWNER_REF);


  UPDATE_ROW ( X_CPN_PERSONALIZE_ID
             , X_SEARCH_NAME
             , 0
             , X_OWNER
             , SYSDATE
             , USER_ID
             , 0);

exception
  when no_data_found then
    INSERT_ROW ( ROW_ID
               , X_CPN_PERSONALIZE_ID
               , X_SEARCH_NAME
               , 0
               , X_OWNER
               , SYSDATE
               , USER_ID
               , SYSDATE
               , USER_ID
               , 0);

end LOAD_ROW;

procedure LOAD_SEED_ROW (
  X_UPLOAD_MODE in VARCHAR2,
  X_CPN_PERSONALIZE_ID in NUMBER,
  X_SEARCH_NAME in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_OWNER_REF in VARCHAR2
) is
begin
	 if(X_UPLOAD_MODE = 'NLS') then
 	         IEC_G_CPN_PERSONALIZE_PKG.TRANSLATE_ROW (
			      		X_CPN_PERSONALIZE_ID,
					X_SEARCH_NAME,
 					X_OWNER_REF);
         else
	         IEC_G_CPN_PERSONALIZE_PKG.LOAD_ROW (
      						X_CPN_PERSONALIZE_ID,
  						X_SEARCH_NAME,
  						X_OWNER,
  						X_OWNER_REF);
         end if;
end LOAD_SEED_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IEC_G_CPN_PERSONALIZE_TL T
  where not exists
    (select NULL
    from IEC_G_CPN_PERSONALIZE_B B
    where B.CPN_PERSONALIZE_ID = T.CPN_PERSONALIZE_ID
    );

  update IEC_G_CPN_PERSONALIZE_TL T set (
      SEARCH_NAME
    ) = (select
      B.SEARCH_NAME
    from IEC_G_CPN_PERSONALIZE_TL B
    where B.CPN_PERSONALIZE_ID = T.CPN_PERSONALIZE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CPN_PERSONALIZE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CPN_PERSONALIZE_ID,
      SUBT.LANGUAGE
    from IEC_G_CPN_PERSONALIZE_TL SUBB, IEC_G_CPN_PERSONALIZE_TL SUBT
    where SUBB.CPN_PERSONALIZE_ID = SUBT.CPN_PERSONALIZE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SEARCH_NAME <> SUBT.SEARCH_NAME
      or (SUBB.SEARCH_NAME is null and SUBT.SEARCH_NAME is not null)
      or (SUBB.SEARCH_NAME is not null and SUBT.SEARCH_NAME is null)
  ));

  insert into IEC_G_CPN_PERSONALIZE_TL (
    CPN_PERSONALIZE_ID,
    SEARCH_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CPN_PERSONALIZE_ID,
    B.SEARCH_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEC_G_CPN_PERSONALIZE_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEC_G_CPN_PERSONALIZE_TL T
    where T.CPN_PERSONALIZE_ID = B.CPN_PERSONALIZE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end IEC_G_CPN_PERSONALIZE_PKG;

/
