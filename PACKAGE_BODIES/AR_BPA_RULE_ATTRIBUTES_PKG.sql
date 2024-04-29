--------------------------------------------------------
--  DDL for Package Body AR_BPA_RULE_ATTRIBUTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BPA_RULE_ATTRIBUTES_PKG" as
/* $Header: ARBPRATB.pls 120.2 2005/10/30 04:13:36 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_RULE_ATTRIBUTE_ID in NUMBER,
  X_RULE_ID in NUMBER,
  X_ITEM_ID in NUMBER,
  X_MATCH_CONDITION in VARCHAR2,
  X_ATTRIBUTE_VALUE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AR_BPA_RULE_ATTRIBUTES_B
    where RULE_ATTRIBUTE_ID = X_RULE_ATTRIBUTE_ID
    ;
begin
  insert into AR_BPA_RULE_ATTRIBUTES_B (
    RULE_ATTRIBUTE_ID,
    RULE_ID,
    ITEM_ID,
    MATCH_CONDITION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_RULE_ATTRIBUTE_ID,
    X_RULE_ID,
    X_ITEM_ID,
    X_MATCH_CONDITION,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AR_BPA_RULE_ATTRIBUTES_TL (
    RULE_ATTRIBUTE_ID,
    ATTRIBUTE_VALUE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_RULE_ATTRIBUTE_ID,
    X_ATTRIBUTE_VALUE,
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
    from AR_BPA_RULE_ATTRIBUTES_TL T
    where T.RULE_ATTRIBUTE_ID = X_RULE_ATTRIBUTE_ID
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
  X_RULE_ATTRIBUTE_ID in NUMBER,
  X_RULE_ID in NUMBER,
  X_ITEM_ID in NUMBER,
  X_MATCH_CONDITION in VARCHAR2,
  X_ATTRIBUTE_VALUE in VARCHAR2
) is
  cursor c is select
      RULE_ID,
      ITEM_ID,
      MATCH_CONDITION
    from AR_BPA_RULE_ATTRIBUTES_B
    where RULE_ATTRIBUTE_ID = X_RULE_ATTRIBUTE_ID
    for update of RULE_ATTRIBUTE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      ATTRIBUTE_VALUE,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AR_BPA_RULE_ATTRIBUTES_TL
    where RULE_ATTRIBUTE_ID = X_RULE_ATTRIBUTE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of RULE_ATTRIBUTE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.RULE_ID = X_RULE_ID)
      AND (recinfo.ITEM_ID = X_ITEM_ID)
      AND (recinfo.MATCH_CONDITION = X_MATCH_CONDITION)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.ATTRIBUTE_VALUE = X_ATTRIBUTE_VALUE)
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
  X_RULE_ATTRIBUTE_ID in NUMBER,
  X_RULE_ID in NUMBER,
  X_ITEM_ID in NUMBER,
  X_MATCH_CONDITION in VARCHAR2,
  X_ATTRIBUTE_VALUE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AR_BPA_RULE_ATTRIBUTES_B set
    RULE_ID = X_RULE_ID,
    ITEM_ID = X_ITEM_ID,
    MATCH_CONDITION = X_MATCH_CONDITION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where RULE_ATTRIBUTE_ID = X_RULE_ATTRIBUTE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AR_BPA_RULE_ATTRIBUTES_TL set
    ATTRIBUTE_VALUE = X_ATTRIBUTE_VALUE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where RULE_ATTRIBUTE_ID = X_RULE_ATTRIBUTE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RULE_ATTRIBUTE_ID in NUMBER
) is
begin
  delete from AR_BPA_RULE_ATTRIBUTES_TL
  where RULE_ATTRIBUTE_ID = X_RULE_ATTRIBUTE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AR_BPA_RULE_ATTRIBUTES_B
  where RULE_ATTRIBUTE_ID = X_RULE_ATTRIBUTE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AR_BPA_RULE_ATTRIBUTES_TL T
  where not exists
    (select NULL
    from AR_BPA_RULE_ATTRIBUTES_B B
    where B.RULE_ATTRIBUTE_ID = T.RULE_ATTRIBUTE_ID
    );

  update AR_BPA_RULE_ATTRIBUTES_TL T set (
      ATTRIBUTE_VALUE
    ) = (select
      B.ATTRIBUTE_VALUE
    from AR_BPA_RULE_ATTRIBUTES_TL B
    where B.RULE_ATTRIBUTE_ID = T.RULE_ATTRIBUTE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RULE_ATTRIBUTE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RULE_ATTRIBUTE_ID,
      SUBT.LANGUAGE
    from AR_BPA_RULE_ATTRIBUTES_TL SUBB, AR_BPA_RULE_ATTRIBUTES_TL SUBT
    where SUBB.RULE_ATTRIBUTE_ID = SUBT.RULE_ATTRIBUTE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ATTRIBUTE_VALUE <> SUBT.ATTRIBUTE_VALUE
  ));

  insert into AR_BPA_RULE_ATTRIBUTES_TL (
    RULE_ATTRIBUTE_ID,
    ATTRIBUTE_VALUE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.RULE_ATTRIBUTE_ID,
    B.ATTRIBUTE_VALUE,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AR_BPA_RULE_ATTRIBUTES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AR_BPA_RULE_ATTRIBUTES_TL T
    where T.RULE_ATTRIBUTE_ID = B.RULE_ATTRIBUTE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_RULE_ATTRIBUTE_ID in NUMBER,
  X_ATTRIBUTE_VALUE in VARCHAR2,
  X_OWNER in VARCHAR2) IS
begin

    update AR_BPA_RULE_ATTRIBUTES_TL
      set ATTRIBUTE_VALUE = X_ATTRIBUTE_VALUE,
          source_lang = userenv('LANG'),
          last_update_date = sysdate,
          last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
          last_update_login = 0
    where RULE_ATTRIBUTE_ID = X_RULE_ATTRIBUTE_ID
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_RULE_ATTRIBUTE_ID in NUMBER,
  X_RULE_ID in NUMBER,
  X_ITEM_ID in NUMBER,
  X_MATCH_CONDITION in VARCHAR2,
  X_ATTRIBUTE_VALUE in VARCHAR2,
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

    AR_BPA_RULE_ATTRIBUTES_PKG.UPDATE_ROW (
        X_RULE_ATTRIBUTE_ID 	 => X_RULE_ATTRIBUTE_ID,
        X_RULE_ID 		 		 => X_RULE_ID,
        X_ITEM_ID 		 		 => X_ITEM_ID,
        X_MATCH_CONDITION 		 => X_MATCH_CONDITION,
        X_ATTRIBUTE_VALUE 		 => X_ATTRIBUTE_VALUE,
        X_LAST_UPDATE_DATE 		 => sysdate,
        X_LAST_UPDATED_BY 	 	 => user_id,
        X_LAST_UPDATE_LOGIN 	 => 0);
    exception
       when NO_DATA_FOUND then
           AR_BPA_RULE_ATTRIBUTES_PKG.INSERT_ROW (
                 X_ROWID 				 => row_id,
		        X_RULE_ATTRIBUTE_ID 	 => X_RULE_ATTRIBUTE_ID,
		        X_RULE_ID 		 		 => X_RULE_ID,
		        X_ITEM_ID 		 		 => X_ITEM_ID,
		        X_MATCH_CONDITION 		 => X_MATCH_CONDITION,
		        X_ATTRIBUTE_VALUE 		 => X_ATTRIBUTE_VALUE,
				X_CREATION_DATE 	     => sysdate,
                X_CREATED_BY 			 => user_id,
                X_LAST_UPDATE_DATE 		 => sysdate,
                X_LAST_UPDATED_BY 		 => user_id,
                X_LAST_UPDATE_LOGIN 	 => 0);
    end;
end LOAD_ROW;

end AR_BPA_RULE_ATTRIBUTES_PKG;

/
