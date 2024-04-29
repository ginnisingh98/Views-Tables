--------------------------------------------------------
--  DDL for Package Body EGO_RULE_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_RULE_SETS_PKG" as
/* $Header: EGOVRSTB.pls 120.1 2007/07/31 10:53:38 rgadiyar noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_RULESET_ID in NUMBER,
  X_ATTR_GROUP_TYPE in VARCHAR2,
  X_RULESET_NAME in VARCHAR2,
  X_RULESET_TYPE in VARCHAR2,
  X_COMPOSITE in VARCHAR2,
  X_ITEM_CATALOG_CATEGORY in NUMBER,
  X_ATTR_GROUP_NAME in VARCHAR2,
  X_RULESET_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from EGO_RULE_SETS_B
    where RULESET_ID = X_RULESET_ID
    ;
begin
  insert into EGO_RULE_SETS_B (
    ATTR_GROUP_TYPE,
    RULESET_ID,
    RULESET_NAME,
    RULESET_TYPE,
    COMPOSITE,
    ITEM_CATALOG_CATEGORY,
    ATTR_GROUP_NAME,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ATTR_GROUP_TYPE,
    X_RULESET_ID,
    X_RULESET_NAME,
    X_RULESET_TYPE,
    X_COMPOSITE,
    X_ITEM_CATALOG_CATEGORY,
    X_ATTR_GROUP_NAME,
    Nvl(X_CREATION_DATE,SYSDATE),
    X_CREATED_BY,
    Nvl(X_LAST_UPDATE_DATE, SYSDATE),
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into EGO_RULE_SETS_TL (
    RULESET_ID,
    RULESET_DISPLAY_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_RULESET_ID,
    X_RULESET_DISPLAY_NAME,
    X_DESCRIPTION,
    Nvl(X_LAST_UPDATE_DATE,SYSDATE),
    X_LAST_UPDATED_BY,
    Nvl(X_CREATION_DATE,SYSDATE),
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from EGO_RULE_SETS_TL T
    where T.RULESET_ID = X_RULESET_ID
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
  X_RULESET_ID in NUMBER,
  X_ATTR_GROUP_TYPE in VARCHAR2,
  X_RULESET_NAME in VARCHAR2,
  X_RULESET_TYPE in VARCHAR2,
  X_COMPOSITE in VARCHAR2,
  X_ITEM_CATALOG_CATEGORY in NUMBER,
  X_ATTR_GROUP_NAME in VARCHAR2,
  X_RULESET_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ATTR_GROUP_TYPE,
      RULESET_NAME,
      RULESET_TYPE,
      COMPOSITE,
      ITEM_CATALOG_CATEGORY,
      ATTR_GROUP_NAME
    from EGO_RULE_SETS_B
    where RULESET_ID = X_RULESET_ID
    for update of RULESET_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      RULESET_DISPLAY_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from EGO_RULE_SETS_TL
    where RULESET_ID = X_RULESET_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of RULESET_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTR_GROUP_TYPE = X_ATTR_GROUP_TYPE)
           OR ((recinfo.ATTR_GROUP_TYPE is null) AND (X_ATTR_GROUP_TYPE is null)))
      AND (recinfo.RULESET_NAME = X_RULESET_NAME)
      AND (recinfo.RULESET_TYPE = X_RULESET_TYPE)
      AND (recinfo.COMPOSITE = X_COMPOSITE)
      AND ((recinfo.ITEM_CATALOG_CATEGORY = X_ITEM_CATALOG_CATEGORY)
           OR ((recinfo.ITEM_CATALOG_CATEGORY is null) AND (X_ITEM_CATALOG_CATEGORY is null)))
      AND ((recinfo.ATTR_GROUP_NAME = X_ATTR_GROUP_NAME)
           OR ((recinfo.ATTR_GROUP_NAME is null) AND (X_ATTR_GROUP_NAME is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.RULESET_DISPLAY_NAME = X_RULESET_DISPLAY_NAME)
               OR ((tlinfo.RULESET_DISPLAY_NAME is null) AND (X_RULESET_DISPLAY_NAME is null)))
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
  X_RULESET_ID in NUMBER,
  X_ATTR_GROUP_TYPE in VARCHAR2,
  X_RULESET_NAME in VARCHAR2,
  X_RULESET_TYPE in VARCHAR2,
  X_COMPOSITE in VARCHAR2,
  X_ITEM_CATALOG_CATEGORY in NUMBER,
  X_ATTR_GROUP_NAME in VARCHAR2,
  X_RULESET_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update EGO_RULE_SETS_B set
    ATTR_GROUP_TYPE = X_ATTR_GROUP_TYPE,
    RULESET_NAME = X_RULESET_NAME,
    RULESET_TYPE = X_RULESET_TYPE,
    COMPOSITE = X_COMPOSITE,
    ITEM_CATALOG_CATEGORY = X_ITEM_CATALOG_CATEGORY,
    ATTR_GROUP_NAME = X_ATTR_GROUP_NAME,
    LAST_UPDATE_DATE = Nvl(X_LAST_UPDATE_DATE,SYSDATE),
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where RULESET_ID = X_RULESET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update EGO_RULE_SETS_TL set
    RULESET_DISPLAY_NAME = X_RULESET_DISPLAY_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = Nvl(X_LAST_UPDATE_DATE,SYSDATE),
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where RULESET_ID = X_RULESET_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RULESET_ID in NUMBER
) is
begin
  delete from EGO_RULE_SETS_TL
  where RULESET_ID = X_RULESET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from EGO_RULE_SETS_B
  where RULESET_ID = X_RULESET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from EGO_RULE_SETS_TL T
  where not exists
    (select NULL
    from EGO_RULE_SETS_B B
    where B.RULESET_ID = T.RULESET_ID
    );

  update EGO_RULE_SETS_TL T set (
      RULESET_DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.RULESET_DISPLAY_NAME,
      B.DESCRIPTION
    from EGO_RULE_SETS_TL B
    where B.RULESET_ID = T.RULESET_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RULESET_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RULESET_ID,
      SUBT.LANGUAGE
    from EGO_RULE_SETS_TL SUBB, EGO_RULE_SETS_TL SUBT
    where SUBB.RULESET_ID = SUBT.RULESET_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.RULESET_DISPLAY_NAME <> SUBT.RULESET_DISPLAY_NAME
      or (SUBB.RULESET_DISPLAY_NAME is null and SUBT.RULESET_DISPLAY_NAME is not null)
      or (SUBB.RULESET_DISPLAY_NAME is not null and SUBT.RULESET_DISPLAY_NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into EGO_RULE_SETS_TL (
    RULESET_ID,
    RULESET_DISPLAY_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.RULESET_ID,
    B.RULESET_DISPLAY_NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from EGO_RULE_SETS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from EGO_RULE_SETS_TL T
    where T.RULESET_ID = B.RULESET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_RULESET_ID in NUMBER,
  X_RULESET_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
 ) is
begin
 update EGO_RULE_SETS_TL set
   RULESET_DISPLAY_NAME = X_RULESET_DISPLAY_NAME,
   DESCRIPTION = X_DESCRIPTION,
   LAST_UPDATE_DATE = sysdate,
   LAST_UPDATED_BY = decode(x_owner, 'ORACLE', 1, 0),
   LAST_UPDATE_LOGIN = 0,
   SOURCE_LANG = userenv('LANG')
 where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
 and RULESET_ID = X_RULESET_ID;
end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_RULESET_ID in NUMBER,
  X_RULESET_NAME in VARCHAR2,
  X_ATTR_GROUP_TYPE in VARCHAR2,
  X_RULESET_TYPE in VARCHAR2,
  X_COMPOSITE in VARCHAR2,
  X_ITEM_CATALOG_CATEGORY in NUMBER,
  X_ATTR_GROUP_NAME in VARCHAR2,
  X_RULESET_DISPLAY_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
 ) is
 begin
   declare
     l_ruleset_id number := 0;

   begin
     select RULESET_ID into l_ruleset_id
     from EGO_RULE_SETS_B
     where  RULESET_NAME = X_RULESET_NAME;

     EGO_RULE_SETS_PKG.UPDATE_ROW(
       X_RULESET_ID		=>	l_ruleset_id,
       X_RULESET_NAME		=>	X_RULESET_NAME,
       X_ATTR_GROUP_TYPE	=>	X_ATTR_GROUP_TYPE,
       X_RULESET_TYPE		=>	X_RULESET_TYPE,
       X_COMPOSITE		=>	X_COMPOSITE,
       X_ITEM_CATALOG_CATEGORY	=>	X_ITEM_CATALOG_CATEGORY,
       X_ATTR_GROUP_NAME	=>	X_ATTR_GROUP_NAME,
       X_RULESET_DISPLAY_NAME	=>	X_RULESET_DISPLAY_NAME,
       X_DESCRIPTION		=>	X_DESCRIPTION,
       X_LAST_UPDATE_DATE	=>	SYSDATE,
       X_LAST_UPDATED_BY	=>	X_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN	=>	X_LAST_UPDATE_LOGIN
     );

   exception
     when NO_DATA_FOUND then
       select EGO_RULE_SETS_S.nextval into l_ruleset_id from dual;

       EGO_RULE_SETS_PKG.INSERT_ROW(
         X_ROWID		=>	X_ROWID,
	 X_RULESET_ID		=>	l_ruleset_id,
	 X_ATTR_GROUP_TYPE	=>	X_ATTR_GROUP_TYPE,
	 X_RULESET_NAME		=>	X_RULESET_NAME,
	 X_RULESET_TYPE		=>	X_RULESET_TYPE,
	 X_COMPOSITE		=>	X_COMPOSITE,
	 X_ITEM_CATALOG_CATEGORY	=>	X_ITEM_CATALOG_CATEGORY,
	 X_ATTR_GROUP_NAME	=>	X_ATTR_GROUP_NAME,
	 X_RULESET_DISPLAY_NAME	=>	X_RULESET_DISPLAY_NAME,
	 X_DESCRIPTION		=>	X_DESCRIPTION,
	 X_CREATION_DATE	=>	sysdate,
	 X_CREATED_BY		=>	X_CREATED_BY,
	 X_LAST_UPDATE_DATE	=>	sysdate,
	 X_LAST_UPDATED_BY	=>	X_LAST_UPDATED_BY,
	 X_LAST_UPDATE_LOGIN	=>	X_LAST_UPDATE_LOGIN
       );
   end;
 end LOAD_ROW;

end EGO_RULE_SETS_PKG;

/
