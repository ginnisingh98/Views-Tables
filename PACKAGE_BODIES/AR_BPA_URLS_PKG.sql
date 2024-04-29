--------------------------------------------------------
--  DDL for Package Body AR_BPA_URLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BPA_URLS_PKG" as
/* $Header: ARBPURLB.pls 120.2 2005/10/30 04:13:55 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_URL_ID in NUMBER,
  X_URL_ADDRESS in VARCHAR2,
  X_FULL_URL_ADDRESS in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_URL_NAME in VARCHAR2,
  X_URL_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DISPLAY_AREA in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DATA_SOURCE_ID in NUMBER
) is
  cursor C is select ROWID from AR_BPA_URLS_B
    where URL_ID = X_URL_ID
    ;
begin
  insert into AR_BPA_URLS_B (
    URL_ID,
    URL_ADDRESS,
    FULL_URL_ADDRESS,
    SEEDED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    DISPLAY_AREA,
    APPLICATION_ID,
    DATA_SOURCE_ID
  ) values (
    X_URL_ID,
    X_URL_ADDRESS,
    X_FULL_URL_ADDRESS,
    X_SEEDED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_DISPLAY_AREA,
    X_APPLICATION_ID,
  	X_DATA_SOURCE_ID
  );

  insert into AR_BPA_URLS_TL (
    URL_ID,
    URL_NAME,
    URL_DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_URL_ID,
    X_URL_NAME,
    X_URL_DESCRIPTION,
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
    from AR_BPA_URLS_TL T
    where T.URL_ID = X_URL_ID
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
  X_URL_ID in NUMBER,
  X_URL_ADDRESS in VARCHAR2,
  X_FULL_URL_ADDRESS in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_URL_NAME in VARCHAR2,
  X_URL_DESCRIPTION in VARCHAR2,
  X_DISPLAY_AREA in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DATA_SOURCE_ID in NUMBER
) is
  cursor c is select
      URL_ADDRESS,
	  FULL_URL_ADDRESS,
      SEEDED_FLAG,
      DISPLAY_AREA,
      APPLICATION_ID,
      DATA_SOURCE_ID
    from AR_BPA_URLS_B
    where URL_ID = X_URL_ID
    for update of URL_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      URL_NAME,
      URL_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AR_BPA_URLS_TL
    where URL_ID = X_URL_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of URL_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.URL_ADDRESS = X_URL_ADDRESS)
  	  AND (recinfo.FULL_URL_ADDRESS = X_FULL_URL_ADDRESS)
      AND ((recinfo.SEEDED_FLAG = X_SEEDED_FLAG)
           OR ((recinfo.SEEDED_FLAG is null) AND (X_SEEDED_FLAG is null)))
      AND ((recinfo.DISPLAY_AREA = X_DISPLAY_AREA)
           OR ((recinfo.DISPLAY_AREA is null) AND (X_DISPLAY_AREA is null)))
      AND ((recinfo.APPLICATION_ID = X_APPLICATION_ID)
           OR ((recinfo.APPLICATION_ID is null) AND (X_APPLICATION_ID is null)))
      AND ((recinfo.DATA_SOURCE_ID = X_DATA_SOURCE_ID)
           OR ((recinfo.DATA_SOURCE_ID is null) AND (X_DATA_SOURCE_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.URL_NAME = X_URL_NAME)
          AND ((tlinfo.URL_DESCRIPTION = X_URL_DESCRIPTION)
               OR ((tlinfo.URL_DESCRIPTION is null) AND (X_URL_DESCRIPTION is null)))
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
  X_URL_ID in NUMBER,
  X_URL_ADDRESS in VARCHAR2,
  X_FULL_URL_ADDRESS in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_URL_NAME in VARCHAR2,
  X_URL_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_DISPLAY_AREA in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DATA_SOURCE_ID in NUMBER
) is
begin
  update AR_BPA_URLS_B set
    URL_ADDRESS = X_URL_ADDRESS,
    FULL_URL_ADDRESS = X_FULL_URL_ADDRESS,
    SEEDED_FLAG = X_SEEDED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    DISPLAY_AREA = X_DISPLAY_AREA,
	APPLICATION_ID = X_APPLICATION_ID,
	DATA_SOURCE_ID = X_DATA_SOURCE_ID
  where URL_ID = X_URL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AR_BPA_URLS_TL set
    URL_NAME = X_URL_NAME,
    URL_DESCRIPTION = X_URL_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where URL_ID = X_URL_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_URL_ID in NUMBER
) is
begin
  delete from AR_BPA_URLS_TL
  where URL_ID = X_URL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AR_BPA_URLS_B
  where URL_ID = X_URL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AR_BPA_URLS_TL T
  where not exists
    (select NULL
    from AR_BPA_URLS_B B
    where B.URL_ID = T.URL_ID
    );

  update AR_BPA_URLS_TL T set (
      URL_NAME,
      URL_DESCRIPTION
    ) = (select
      B.URL_NAME,
      B.URL_DESCRIPTION
    from AR_BPA_URLS_TL B
    where B.URL_ID = T.URL_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.URL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.URL_ID,
      SUBT.LANGUAGE
    from AR_BPA_URLS_TL SUBB, AR_BPA_URLS_TL SUBT
    where SUBB.URL_ID = SUBT.URL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.URL_NAME <> SUBT.URL_NAME
      or SUBB.URL_DESCRIPTION <> SUBT.URL_DESCRIPTION
      or (SUBB.URL_DESCRIPTION is null and SUBT.URL_DESCRIPTION is not null)
      or (SUBB.URL_DESCRIPTION is not null and SUBT.URL_DESCRIPTION is null)
  ));

  insert into AR_BPA_URLS_TL (
    URL_ID,
    URL_NAME,
    URL_DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.URL_ID,
    B.URL_NAME,
    B.URL_DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AR_BPA_URLS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AR_BPA_URLS_TL T
    where T.URL_ID = B.URL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_URL_ID in NUMBER,
  X_URL_NAME in VARCHAR2,
  X_URL_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2) IS
begin

    update AR_BPA_URLS_TL
      set URL_NAME = X_URL_NAME,
      	  URL_DESCRIPTION = X_URL_DESCRIPTION,
          source_lang = userenv('LANG'),
          last_update_date = sysdate,
          last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
          last_update_login = 0
    where URL_ID = X_URL_ID
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_URL_ID in NUMBER,
  X_URL_ADDRESS in VARCHAR2,
  X_FULL_URL_ADDRESS in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_URL_NAME in VARCHAR2,
  X_URL_DESCRIPTION in VARCHAR2,
  X_OWNER IN VARCHAR2,
  X_DISPLAY_AREA in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DATA_SOURCE_ID in NUMBER
) IS
  begin
   declare
     user_id            number := 0;
     row_id             varchar2(64);
   begin
     if (X_OWNER = 'SEED') then
        user_id := 1;
    end if;

    AR_BPA_URLS_PKG.UPDATE_ROW (
        X_URL_ID 		 		 => X_URL_ID,
        X_URL_ADDRESS	 		 => X_URL_ADDRESS,
        X_FULL_URL_ADDRESS	     => X_FULL_URL_ADDRESS,
        X_SEEDED_FLAG	 		 => X_SEEDED_FLAG,
        X_URL_NAME		 		 => X_URL_NAME,
        X_URL_DESCRIPTION		 => X_URL_DESCRIPTION,
        X_LAST_UPDATE_DATE 		 => sysdate,
        X_LAST_UPDATED_BY 	 	 => user_id,
        X_LAST_UPDATE_LOGIN 	 => 0,
        X_DISPLAY_AREA			 => X_DISPLAY_AREA,
        X_APPLICATION_ID		 => X_APPLICATION_ID,
        X_DATA_SOURCE_ID		 => X_DATA_SOURCE_ID);
    exception
       when NO_DATA_FOUND then
           AR_BPA_URLS_PKG.INSERT_ROW (
                X_ROWID 				 => row_id,
		        X_URL_ID 		 		 => X_URL_ID,
		        X_URL_ADDRESS	 		 => X_URL_ADDRESS,
				X_FULL_URL_ADDRESS	     => X_FULL_URL_ADDRESS,
		        X_SEEDED_FLAG	 		 => X_SEEDED_FLAG,
		        X_URL_NAME		 		 => X_URL_NAME,
		        X_URL_DESCRIPTION		 => X_URL_DESCRIPTION,
				X_CREATION_DATE 	     => sysdate,
                X_CREATED_BY 			 => user_id,
                X_LAST_UPDATE_DATE 		 => sysdate,
                X_LAST_UPDATED_BY 		 => user_id,
                X_LAST_UPDATE_LOGIN 	 => 0,
        		X_DISPLAY_AREA			 => X_DISPLAY_AREA,
        		X_APPLICATION_ID		 => X_APPLICATION_ID,
        		X_DATA_SOURCE_ID		 => X_DATA_SOURCE_ID);
    end;
end LOAD_ROW;

end AR_BPA_URLS_PKG;

/
