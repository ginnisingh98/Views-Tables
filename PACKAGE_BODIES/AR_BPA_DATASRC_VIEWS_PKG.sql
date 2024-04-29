--------------------------------------------------------
--  DDL for Package Body AR_BPA_DATASRC_VIEWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BPA_DATASRC_VIEWS_PKG" as
/* $Header: ARBPDSVB.pls 120.2 2005/10/30 04:13:28 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DATA_SOURCE_ID in NUMBER,
  X_OBJECT_TYPE in VARCHAR2,
  X_OBJECT_NAME in VARCHAR2,
  X_VO_USAGE_NAME in VARCHAR2,
  X_VO_USAGE_FULL_NAME in VARCHAR2,
  X_VO_INIT_SEQUENCE in NUMBER,
  X_DISPLAY_LEVEL in VARCHAR2,
  X_LINK_TO_DATA_SOURCE_ID in NUMBER,
  X_INVOICED_LINE_ACCTG_LEVEL in VARCHAR2,
  X_TAX_SOURCE_FLAG in VARCHAR2,
  X_SOURCE_LINE_TYPE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DATASRC_VIEW_NAME in VARCHAR2,
  X_DATASRC_VIEW_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AR_BPA_DATA_SOURCES_B
    where DATA_SOURCE_ID = X_DATA_SOURCE_ID
    ;
begin
  insert into AR_BPA_DATA_SOURCES_B (
    OBJECT_TYPE,
    OBJECT_NAME,
    VO_USAGE_NAME,
    VO_USAGE_FULL_NAME,
    VO_INIT_SEQUENCE,
    DISPLAY_LEVEL,
    LINK_TO_DATA_SOURCE_ID,
    INVOICED_LINE_ACCTG_LEVEL,
    TAX_SOURCE_FLAG,
    SOURCE_LINE_TYPE,
    ENABLED_FLAG,
    SEEDED_FLAG,
    DATA_SOURCE_ID,
    APPLICATION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_OBJECT_TYPE,
    X_OBJECT_NAME,
    X_VO_USAGE_NAME,
    X_VO_USAGE_FULL_NAME,
    X_VO_INIT_SEQUENCE,
    X_DISPLAY_LEVEL,
    X_LINK_TO_DATA_SOURCE_ID,
    X_INVOICED_LINE_ACCTG_LEVEL,
    X_TAX_SOURCE_FLAG,
    X_SOURCE_LINE_TYPE,
    X_ENABLED_FLAG,
    X_SEEDED_FLAG,
    X_DATA_SOURCE_ID,
    X_APPLICATION_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AR_BPA_DATA_SOURCES_TL (
    DATA_SOURCE_ID,
    DATASRC_VIEW_NAME,
    DATASRC_VIEW_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_DATA_SOURCE_ID,
    X_DATASRC_VIEW_NAME,
    X_DATASRC_VIEW_DESC,
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
    from AR_BPA_DATA_SOURCES_TL T
    where T.DATA_SOURCE_ID = X_DATA_SOURCE_ID
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
  X_DATA_SOURCE_ID in NUMBER,
  X_OBJECT_TYPE in VARCHAR2,
  X_OBJECT_NAME in VARCHAR2,
  X_VO_USAGE_NAME in VARCHAR2,
  X_VO_USAGE_FULL_NAME in VARCHAR2,
  X_VO_INIT_SEQUENCE in NUMBER,
  X_DISPLAY_LEVEL in VARCHAR2,
  X_LINK_TO_DATA_SOURCE_ID in NUMBER,
  X_INVOICED_LINE_ACCTG_LEVEL in VARCHAR2,
  X_TAX_SOURCE_FLAG in VARCHAR2,
  X_SOURCE_LINE_TYPE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DATASRC_VIEW_NAME in VARCHAR2,
  X_DATASRC_VIEW_DESC in VARCHAR2
) is
  cursor c is select
      OBJECT_TYPE,
      OBJECT_NAME,
      VO_USAGE_NAME,
      VO_USAGE_FULL_NAME,
      VO_INIT_SEQUENCE,
      DISPLAY_LEVEL,
      LINK_TO_DATA_SOURCE_ID,
      INVOICED_LINE_ACCTG_LEVEL,
      TAX_SOURCE_FLAG,
      SOURCE_LINE_TYPE,
      ENABLED_FLAG,
      SEEDED_FLAG,
      APPLICATION_ID
    from AR_BPA_DATA_SOURCES_B
    where DATA_SOURCE_ID = X_DATA_SOURCE_ID
    for update of DATA_SOURCE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DATASRC_VIEW_NAME,
      DATASRC_VIEW_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AR_BPA_DATA_SOURCES_TL
    where DATA_SOURCE_ID = X_DATA_SOURCE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of DATA_SOURCE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.OBJECT_TYPE = X_OBJECT_TYPE)
           OR ((recinfo.OBJECT_TYPE is null) AND (X_OBJECT_TYPE is null)))
      AND ((recinfo.OBJECT_NAME = X_OBJECT_NAME)
           OR ((recinfo.OBJECT_NAME is null) AND (X_OBJECT_NAME is null)))
      AND ((recinfo.VO_USAGE_NAME = X_VO_USAGE_NAME)
           OR ((recinfo.VO_USAGE_NAME is null) AND (X_VO_USAGE_NAME is null)))
      AND ((recinfo.VO_USAGE_FULL_NAME = X_VO_USAGE_FULL_NAME)
           OR ((recinfo.VO_USAGE_FULL_NAME is null) AND (X_VO_USAGE_FULL_NAME is null)))
      AND (recinfo.VO_INIT_SEQUENCE = X_VO_INIT_SEQUENCE)
      AND (recinfo.DISPLAY_LEVEL = X_DISPLAY_LEVEL)
      AND ((recinfo.LINK_TO_DATA_SOURCE_ID = X_LINK_TO_DATA_SOURCE_ID)
           OR ((recinfo.LINK_TO_DATA_SOURCE_ID is null) AND (X_LINK_TO_DATA_SOURCE_ID is null)))
      AND ((recinfo.INVOICED_LINE_ACCTG_LEVEL = X_INVOICED_LINE_ACCTG_LEVEL)
           OR ((recinfo.INVOICED_LINE_ACCTG_LEVEL is null) AND (X_INVOICED_LINE_ACCTG_LEVEL is null)))
      AND ((recinfo.TAX_SOURCE_FLAG = X_TAX_SOURCE_FLAG)
           OR ((recinfo.TAX_SOURCE_FLAG is null) AND (X_TAX_SOURCE_FLAG is null)))
      AND ((recinfo.SOURCE_LINE_TYPE = X_SOURCE_LINE_TYPE)
           OR ((recinfo.SOURCE_LINE_TYPE is null) AND (X_SOURCE_LINE_TYPE is null)))
      AND ((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
           OR ((recinfo.ENABLED_FLAG is null) AND (X_ENABLED_FLAG is null)))
      AND ((recinfo.SEEDED_FLAG = X_SEEDED_FLAG)
           OR ((recinfo.SEEDED_FLAG is null) AND (X_SEEDED_FLAG is null)))
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DATASRC_VIEW_NAME = X_DATASRC_VIEW_NAME)
          AND ((tlinfo.DATASRC_VIEW_DESC = X_DATASRC_VIEW_DESC)
               OR ((tlinfo.DATASRC_VIEW_DESC is null) AND (X_DATASRC_VIEW_DESC is null)))
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
  X_DATA_SOURCE_ID in NUMBER,
  X_OBJECT_TYPE in VARCHAR2,
  X_OBJECT_NAME in VARCHAR2,
  X_VO_USAGE_NAME in VARCHAR2,
  X_VO_USAGE_FULL_NAME in VARCHAR2,
  X_VO_INIT_SEQUENCE in NUMBER,
  X_DISPLAY_LEVEL in VARCHAR2,
  X_LINK_TO_DATA_SOURCE_ID in NUMBER,
  X_INVOICED_LINE_ACCTG_LEVEL in VARCHAR2,
  X_TAX_SOURCE_FLAG in VARCHAR2,
  X_SOURCE_LINE_TYPE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DATASRC_VIEW_NAME in VARCHAR2,
  X_DATASRC_VIEW_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AR_BPA_DATA_SOURCES_B set
    OBJECT_TYPE = X_OBJECT_TYPE,
    OBJECT_NAME = X_OBJECT_NAME,
    VO_USAGE_NAME = X_VO_USAGE_NAME,
    VO_USAGE_FULL_NAME = X_VO_USAGE_FULL_NAME,
    VO_INIT_SEQUENCE = X_VO_INIT_SEQUENCE,
    DISPLAY_LEVEL = X_DISPLAY_LEVEL,
    LINK_TO_DATA_SOURCE_ID = X_LINK_TO_DATA_SOURCE_ID,
    INVOICED_LINE_ACCTG_LEVEL = X_INVOICED_LINE_ACCTG_LEVEL,
    TAX_SOURCE_FLAG = X_TAX_SOURCE_FLAG,
    SOURCE_LINE_TYPE = X_SOURCE_LINE_TYPE,
    ENABLED_FLAG = X_ENABLED_FLAG,
    SEEDED_FLAG = X_SEEDED_FLAG,
    APPLICATION_ID = X_APPLICATION_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where DATA_SOURCE_ID = X_DATA_SOURCE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AR_BPA_DATA_SOURCES_TL set
    DATASRC_VIEW_NAME = X_DATASRC_VIEW_NAME,
    DATASRC_VIEW_DESC = X_DATASRC_VIEW_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where DATA_SOURCE_ID = X_DATA_SOURCE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_DATA_SOURCE_ID in NUMBER
) is
begin
  /* First delete from Item table. then delete from the view item GT table  */
  delete from AR_BPA_ITEMS_TL
  where item_id in (select item_id from ar_bpa_items_b
                               where data_source_id = X_DATA_SOURCE_ID);

  delete from AR_BPA_ITEMS_B
  where DATA_SOURCE_ID = X_DATA_SOURCE_ID;

  delete from AR_BPA_DATA_SOURCES_TL
  where DATA_SOURCE_ID = X_DATA_SOURCE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AR_BPA_DATA_SOURCES_B
  where DATA_SOURCE_ID = X_DATA_SOURCE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AR_BPA_DATA_SOURCES_TL T
  where not exists
    (select NULL
    from AR_BPA_DATA_SOURCES_B B
    where B.DATA_SOURCE_ID = T.DATA_SOURCE_ID
    );

  update AR_BPA_DATA_SOURCES_TL T set (
      DATASRC_VIEW_NAME,
      DATASRC_VIEW_DESC
    ) = (select
      B.DATASRC_VIEW_NAME,
      B.DATASRC_VIEW_DESC
    from AR_BPA_DATA_SOURCES_TL B
    where B.DATA_SOURCE_ID = T.DATA_SOURCE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DATA_SOURCE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.DATA_SOURCE_ID,
      SUBT.LANGUAGE
    from AR_BPA_DATA_SOURCES_TL SUBB, AR_BPA_DATA_SOURCES_TL SUBT
    where SUBB.DATA_SOURCE_ID = SUBT.DATA_SOURCE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DATASRC_VIEW_NAME <> SUBT.DATASRC_VIEW_NAME
      or SUBB.DATASRC_VIEW_DESC <> SUBT.DATASRC_VIEW_DESC
      or (SUBB.DATASRC_VIEW_DESC is null and SUBT.DATASRC_VIEW_DESC is not null)
      or (SUBB.DATASRC_VIEW_DESC is not null and SUBT.DATASRC_VIEW_DESC is null)
  ));

  insert into AR_BPA_DATA_SOURCES_TL (
    DATA_SOURCE_ID,
    DATASRC_VIEW_NAME,
    DATASRC_VIEW_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.DATA_SOURCE_ID,
    B.DATASRC_VIEW_NAME,
    B.DATASRC_VIEW_DESC,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AR_BPA_DATA_SOURCES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AR_BPA_DATA_SOURCES_TL T
    where T.DATA_SOURCE_ID = B.DATA_SOURCE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_DATA_SOURCE_ID in NUMBER,
  X_DATASRC_VIEW_NAME in VARCHAR2,
  X_DATASRC_VIEW_DESC in VARCHAR2,
  X_OWNER in VARCHAR2) IS
begin

    update AR_BPA_DATA_SOURCES_TL
      set DATASRC_VIEW_NAME = X_DATASRC_VIEW_NAME,
      	  DATASRC_VIEW_DESC = X_DATASRC_VIEW_DESC,
          source_lang = userenv('LANG'),
          last_update_date = sysdate,
          last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
          last_update_login = 0
    where DATA_SOURCE_ID = X_DATA_SOURCE_ID
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_DATA_SOURCE_ID in NUMBER,
  X_OBJECT_TYPE in VARCHAR2,
  X_OBJECT_NAME in VARCHAR2,
  X_VO_USAGE_NAME in VARCHAR2,
  X_VO_USAGE_FULL_NAME in VARCHAR2,
  X_VO_INIT_SEQUENCE in NUMBER,
  X_DISPLAY_LEVEL in VARCHAR2,
  X_LINK_TO_DATA_SOURCE_ID in NUMBER,
  X_INVOICED_LINE_ACCTG_LEVEL in VARCHAR2,
  X_TAX_SOURCE_FLAG in VARCHAR2,
  X_SOURCE_LINE_TYPE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_DATASRC_VIEW_NAME in VARCHAR2,
  X_DATASRC_VIEW_DESC in VARCHAR2,
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

    AR_BPA_DATASRC_VIEWS_PKG.UPDATE_ROW (
        X_DATA_SOURCE_ID 		 	=> X_DATA_SOURCE_ID,
        X_OBJECT_TYPE	 	 		=> X_OBJECT_TYPE,
        X_OBJECT_NAME	     	 	=> X_OBJECT_NAME,
        X_VO_USAGE_NAME	 		 	=> X_VO_USAGE_NAME,
        X_VO_USAGE_FULL_NAME		=> X_VO_USAGE_FULL_NAME,
        X_VO_INIT_SEQUENCE 		 	=> X_VO_INIT_SEQUENCE ,
        X_DISPLAY_LEVEL 		 	=> X_DISPLAY_LEVEL,
        X_LINK_TO_DATA_SOURCE_ID	=> X_LINK_TO_DATA_SOURCE_ID,
        X_INVOICED_LINE_ACCTG_LEVEL	=> X_INVOICED_LINE_ACCTG_LEVEL,
        X_TAX_SOURCE_FLAG	 		=> X_TAX_SOURCE_FLAG,
        X_SOURCE_LINE_TYPE		 	=> X_SOURCE_LINE_TYPE,
        X_ENABLED_FLAG 		 		=> X_ENABLED_FLAG ,
        X_SEEDED_FLAG		 		=> X_SEEDED_FLAG,
        X_APPLICATION_ID 		 	=> X_APPLICATION_ID ,
        X_DATASRC_VIEW_NAME		 	=> X_DATASRC_VIEW_NAME,
        X_DATASRC_VIEW_DESC 		=> X_DATASRC_VIEW_DESC ,
        X_LAST_UPDATE_DATE 		 	=> sysdate,
        X_LAST_UPDATED_BY 	 	 	=> user_id,
        X_LAST_UPDATE_LOGIN 	 	=> 0);
    exception
       when NO_DATA_FOUND then
           AR_BPA_DATASRC_VIEWS_PKG.INSERT_ROW (
                X_ROWID 				 => row_id,
		        X_DATA_SOURCE_ID 		 	=> X_DATA_SOURCE_ID,
		        X_OBJECT_TYPE	 	 		=> X_OBJECT_TYPE,
		        X_OBJECT_NAME	     	 	=> X_OBJECT_NAME,
		        X_VO_USAGE_NAME	 		 	=> X_VO_USAGE_NAME,
		        X_VO_USAGE_FULL_NAME		=> X_VO_USAGE_FULL_NAME,
		        X_VO_INIT_SEQUENCE 		 	=> X_VO_INIT_SEQUENCE ,
		        X_DISPLAY_LEVEL 		 	=> X_DISPLAY_LEVEL,
		        X_LINK_TO_DATA_SOURCE_ID	=> X_LINK_TO_DATA_SOURCE_ID,
		        X_INVOICED_LINE_ACCTG_LEVEL	=> X_INVOICED_LINE_ACCTG_LEVEL,
		        X_TAX_SOURCE_FLAG	 		=> X_TAX_SOURCE_FLAG,
		        X_SOURCE_LINE_TYPE		 	=> X_SOURCE_LINE_TYPE,
		        X_ENABLED_FLAG 		 		=> X_ENABLED_FLAG ,
		        X_SEEDED_FLAG		 		=> X_SEEDED_FLAG,
		        X_APPLICATION_ID 		 	=> X_APPLICATION_ID ,
		        X_DATASRC_VIEW_NAME		 	=> X_DATASRC_VIEW_NAME,
		        X_DATASRC_VIEW_DESC 		=> X_DATASRC_VIEW_DESC ,
				X_CREATION_DATE 	     => sysdate,
                X_CREATED_BY 			 => user_id,
                X_LAST_UPDATE_DATE 		 => sysdate,
                X_LAST_UPDATED_BY 		 => user_id,
                X_LAST_UPDATE_LOGIN 	 => 0);
    end;
end LOAD_ROW;

end AR_BPA_DATASRC_VIEWS_PKG;

/
