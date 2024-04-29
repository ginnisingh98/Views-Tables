--------------------------------------------------------
--  DDL for Package Body AR_BPA_DATASRC_APPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BPA_DATASRC_APPS_PKG" as
/* $Header: ARBPDSAB.pls 120.3 2005/12/01 20:16:24 lishao noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_INTERFACE_CONTEXT in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_DATASRC_APP_NAME in VARCHAR2,
  X_DATASRC_APP_DESC in VARCHAR2,
  X_PRIMARY_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AR_BPA_DATASRC_APPS_B
    where APPLICATION_ID = X_APPLICATION_ID
    ;
begin
  insert into AR_BPA_DATASRC_APPS_B (
    APPLICATION_ID,
    INTERFACE_CONTEXT,
    ENABLED_FLAG,
    SEEDED_FLAG,
    PRIMARY_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_APPLICATION_ID,
    X_INTERFACE_CONTEXT,
    X_ENABLED_FLAG,
    X_SEEDED_FLAG,
    X_PRIMARY_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AR_BPA_DATASRC_APPS_TL (
    APPLICATION_ID,
    DATASRC_APP_NAME,
    DATASRC_APP_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_APPLICATION_ID,
    X_DATASRC_APP_NAME,
    X_DATASRC_APP_DESC,
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
    from AR_BPA_DATASRC_APPS_TL T
    where T.APPLICATION_ID = X_APPLICATION_ID
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
  X_INTERFACE_CONTEXT in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_DATASRC_APP_NAME in VARCHAR2,
  X_DATASRC_APP_DESC in VARCHAR2,
  X_PRIMARY_FLAG in VARCHAR2
) is
  cursor c is select
      INTERFACE_CONTEXT,
      ENABLED_FLAG,
      SEEDED_FLAG,
      PRIMARY_FLAG
    from AR_BPA_DATASRC_APPS_B
    where APPLICATION_ID = X_APPLICATION_ID
    for update of APPLICATION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DATASRC_APP_NAME,
      DATASRC_APP_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AR_BPA_DATASRC_APPS_TL
    where APPLICATION_ID = X_APPLICATION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of APPLICATION_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.INTERFACE_CONTEXT = X_INTERFACE_CONTEXT)
           OR ((recinfo.INTERFACE_CONTEXT is null) AND (X_INTERFACE_CONTEXT is null)))
      AND ((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
           OR ((recinfo.ENABLED_FLAG is null) AND (X_ENABLED_FLAG is null)))
      AND ((recinfo.SEEDED_FLAG = X_SEEDED_FLAG)
           OR ((recinfo.SEEDED_FLAG is null) AND (X_SEEDED_FLAG is null)))
      AND ((recinfo.PRIMARY_FLAG = X_PRIMARY_FLAG)
           OR ((recinfo.PRIMARY_FLAG is null) AND (X_PRIMARY_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DATASRC_APP_NAME = X_DATASRC_APP_NAME)
          AND ((tlinfo.DATASRC_APP_DESC = X_DATASRC_APP_DESC)
               OR ((tlinfo.DATASRC_APP_DESC is null) AND (X_DATASRC_APP_DESC is null)))
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
  X_APPLICATION_ID in NUMBER,
  X_INTERFACE_CONTEXT in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_DATASRC_APP_NAME in VARCHAR2,
  X_DATASRC_APP_DESC in VARCHAR2,
  X_PRIMARY_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AR_BPA_DATASRC_APPS_B set
    INTERFACE_CONTEXT = X_INTERFACE_CONTEXT,
    ENABLED_FLAG = X_ENABLED_FLAG,
    SEEDED_FLAG = X_SEEDED_FLAG,
    PRIMARY_FLAG = X_PRIMARY_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where APPLICATION_ID = X_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AR_BPA_DATASRC_APPS_TL set
    DATASRC_APP_NAME = X_DATASRC_APP_NAME,
    DATASRC_APP_DESC = X_DATASRC_APP_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where APPLICATION_ID = X_APPLICATION_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER
) is
begin
  /* First delete interface attribute from the Item table. */
  delete from AR_BPA_ITEMS_TL
  where item_id in (select item_id from ar_bpa_items_b
                               where SEEDED_APPLICATION_ID = X_APPLICATION_ID);

  delete from AR_BPA_ITEMS_B
  where SEEDED_APPLICATION_ID = X_APPLICATION_ID;

  delete from AR_BPA_DATASRC_APPS_TL
  where APPLICATION_ID = X_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AR_BPA_DATASRC_APPS_B
  where APPLICATION_ID = X_APPLICATION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AR_BPA_DATASRC_APPS_TL T
  where not exists
    (select NULL
    from AR_BPA_DATASRC_APPS_B B
    where B.APPLICATION_ID = T.APPLICATION_ID
    );

  update AR_BPA_DATASRC_APPS_TL T set (
      DATASRC_APP_NAME,
      DATASRC_APP_DESC
    ) = (select
      B.DATASRC_APP_NAME,
      B.DATASRC_APP_DESC
    from AR_BPA_DATASRC_APPS_TL B
    where B.APPLICATION_ID = T.APPLICATION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.APPLICATION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.APPLICATION_ID,
      SUBT.LANGUAGE
    from AR_BPA_DATASRC_APPS_TL SUBB, AR_BPA_DATASRC_APPS_TL SUBT
    where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DATASRC_APP_NAME <> SUBT.DATASRC_APP_NAME
      or SUBB.DATASRC_APP_DESC <> SUBT.DATASRC_APP_DESC
      or (SUBB.DATASRC_APP_DESC is null and SUBT.DATASRC_APP_DESC is not null)
      or (SUBB.DATASRC_APP_DESC is not null and SUBT.DATASRC_APP_DESC is null)
  ));

  insert into AR_BPA_DATASRC_APPS_TL (
    APPLICATION_ID,
    DATASRC_APP_NAME,
    DATASRC_APP_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.APPLICATION_ID,
    B.DATASRC_APP_NAME,
    B.DATASRC_APP_DESC,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AR_BPA_DATASRC_APPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AR_BPA_DATASRC_APPS_TL T
    where T.APPLICATION_ID = B.APPLICATION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_DATASRC_APP_NAME in VARCHAR2,
  X_DATASRC_APP_DESC in VARCHAR2,
  X_OWNER in VARCHAR2) IS
begin

    update AR_BPA_DATASRC_APPS_TL
      set DATASRC_APP_NAME = X_DATASRC_APP_NAME,
      	  DATASRC_APP_DESC = X_DATASRC_APP_DESC,
          source_lang = userenv('LANG'),
          last_update_date = sysdate,
          last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
          last_update_login = 0
    where APPLICATION_ID = X_APPLICATION_ID
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_APPLICATION_ID in NUMBER,
  X_INTERFACE_CONTEXT in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_DATASRC_APP_NAME in VARCHAR2,
  X_DATASRC_APP_DESC in VARCHAR2,
  X_PRIMARY_FLAG in VARCHAR2,
  X_OWNER IN VARCHAR2
) IS
  begin
   declare
     user_id            number := 0;
     row_id             varchar2(64);
   begin
     if (X_OWNER = 'SEED') then
        user_id := 1;
    end if;

    AR_BPA_DATASRC_APPS_PKG.UPDATE_ROW (
        X_APPLICATION_ID 		 => X_APPLICATION_ID,
        X_INTERFACE_CONTEXT	 	 => X_INTERFACE_CONTEXT,
        X_ENABLED_FLAG	     	 => X_ENABLED_FLAG,
        X_SEEDED_FLAG	 		 => X_SEEDED_FLAG,
        X_DATASRC_APP_NAME		 => X_DATASRC_APP_NAME,
        X_DATASRC_APP_DESC 		 => X_DATASRC_APP_DESC ,
        X_PRIMARY_FLAG 				 => X_PRIMARY_FLAG,
        X_LAST_UPDATE_DATE 		 => sysdate,
        X_LAST_UPDATED_BY 	 	 => user_id,
        X_LAST_UPDATE_LOGIN 	 => 0);
    exception
       when NO_DATA_FOUND then
           AR_BPA_DATASRC_APPS_PKG.INSERT_ROW (
                X_ROWID 				 => row_id,
		        X_APPLICATION_ID 		 => X_APPLICATION_ID,
		        X_INTERFACE_CONTEXT	 	 => X_INTERFACE_CONTEXT,
		        X_ENABLED_FLAG	     	 => X_ENABLED_FLAG,
		        X_SEEDED_FLAG	 		 => X_SEEDED_FLAG,
		        X_DATASRC_APP_NAME		 => X_DATASRC_APP_NAME,
		        X_DATASRC_APP_DESC 		 => X_DATASRC_APP_DESC ,
        		X_PRIMARY_FLAG 				 => X_PRIMARY_FLAG,
				X_CREATION_DATE 	     => sysdate,
                X_CREATED_BY 			 => user_id,
                X_LAST_UPDATE_DATE 		 => sysdate,
                X_LAST_UPDATED_BY 		 => user_id,
                X_LAST_UPDATE_LOGIN 	 => 0);
    end;
end LOAD_ROW;

end AR_BPA_DATASRC_APPS_PKG;

/