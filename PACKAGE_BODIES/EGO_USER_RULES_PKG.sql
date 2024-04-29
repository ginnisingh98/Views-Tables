--------------------------------------------------------
--  DDL for Package Body EGO_USER_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_USER_RULES_PKG" as
/* $Header: EGOVUSRB.pls 120.1 2007/07/31 10:55:23 rgadiyar noship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_RULE_ID in NUMBER,
  X_RULESET_ID in NUMBER,
  X_SEQUENCE in NUMBER,
  X_RULE_NAME in VARCHAR2,
  X_ATTR_GROUP_TYPE in VARCHAR2,
  X_ATTR_GROUP_NAME in VARCHAR2,
  X_ATTR_NAME in VARCHAR2,
  X_SEVERITY in VARCHAR2,
  X_RULE_XML in CLOB,
  X_DESCRIPTION in VARCHAR2,
  X_USER_EXPLANATION_MESSAGE in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from EGO_USER_RULES_B
    where RULE_ID = X_RULE_ID
    ;
begin
  insert into EGO_USER_RULES_B (
    RULE_ID,
    RULESET_ID,
    SEQUENCE,
    RULE_NAME,
    ATTR_GROUP_TYPE,
    ATTR_GROUP_NAME,
    ATTR_NAME,
    SEVERITY,
    RULE_XML,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_RULE_ID,
    X_RULESET_ID,
    X_SEQUENCE,
    X_RULE_NAME,
    X_ATTR_GROUP_TYPE,
    X_ATTR_GROUP_NAME,
    X_ATTR_NAME,
    X_SEVERITY,
    X_RULE_XML,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into EGO_USER_RULES_TL (
    RULE_ID,
    DESCRIPTION,
    USER_EXPLANATION_MESSAGE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_RULE_ID,
    X_DESCRIPTION,
    X_USER_EXPLANATION_MESSAGE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from EGO_USER_RULES_TL T
    where T.RULE_ID = X_RULE_ID
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
  X_RULE_ID in NUMBER,
  X_RULESET_ID in NUMBER,
  X_SEQUENCE in NUMBER,
  X_RULE_NAME in VARCHAR2,
  X_ATTR_GROUP_TYPE in VARCHAR2,
  X_ATTR_GROUP_NAME in VARCHAR2,
  X_ATTR_NAME in VARCHAR2,
  X_SEVERITY in VARCHAR2,
  X_RULE_XML in CLOB,
  X_DESCRIPTION in VARCHAR2,
  X_USER_EXPLANATION_MESSAGE in VARCHAR2
) is
  cursor c is select
      RULESET_ID,
      SEQUENCE,
      RULE_NAME,
      ATTR_GROUP_TYPE,
      ATTR_GROUP_NAME,
      ATTR_NAME,
      SEVERITY,
      RULE_XML
    from EGO_USER_RULES_B
    where RULE_ID = X_RULE_ID
    for update of RULE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      USER_EXPLANATION_MESSAGE,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from EGO_USER_RULES_TL
    where RULE_ID = X_RULE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of RULE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.RULESET_ID = X_RULESET_ID)
      AND (recinfo.SEQUENCE = X_SEQUENCE)
      AND (recinfo.RULE_NAME = X_RULE_NAME)
      AND ((recinfo.ATTR_GROUP_TYPE = X_ATTR_GROUP_TYPE)
           OR ((recinfo.ATTR_GROUP_TYPE is null) AND (X_ATTR_GROUP_TYPE is null)))
      AND ((recinfo.ATTR_GROUP_NAME = X_ATTR_GROUP_NAME)
           OR ((recinfo.ATTR_GROUP_NAME is null) AND (X_ATTR_GROUP_NAME is null)))
      AND ((recinfo.ATTR_NAME = X_ATTR_NAME)
           OR ((recinfo.ATTR_NAME is null) AND (X_ATTR_NAME is null)))
      AND ((recinfo.SEVERITY = X_SEVERITY)
           OR ((recinfo.SEVERITY is null) AND (X_SEVERITY is null)))
      AND (recinfo.RULE_XML = X_RULE_XML)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND ((tlinfo.USER_EXPLANATION_MESSAGE = X_USER_EXPLANATION_MESSAGE)
               OR ((tlinfo.USER_EXPLANATION_MESSAGE is null) AND (X_USER_EXPLANATION_MESSAGE is null)))
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
  X_RULE_ID in NUMBER,
  X_RULESET_ID in NUMBER,
  X_SEQUENCE in NUMBER,
  X_RULE_NAME in VARCHAR2,
  X_ATTR_GROUP_TYPE in VARCHAR2,
  X_ATTR_GROUP_NAME in VARCHAR2,
  X_ATTR_NAME in VARCHAR2,
  X_SEVERITY in VARCHAR2,
  X_RULE_XML in CLOB,
  X_DESCRIPTION in VARCHAR2,
  X_USER_EXPLANATION_MESSAGE in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update EGO_USER_RULES_B set
    RULESET_ID = X_RULESET_ID,
    SEQUENCE = X_SEQUENCE,
    RULE_NAME = X_RULE_NAME,
    ATTR_GROUP_TYPE = X_ATTR_GROUP_TYPE,
    ATTR_GROUP_NAME = X_ATTR_GROUP_NAME,
    ATTR_NAME = X_ATTR_NAME,
    SEVERITY = X_SEVERITY,
    RULE_XML = X_RULE_XML,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where RULE_ID = X_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update EGO_USER_RULES_TL set
    DESCRIPTION = X_DESCRIPTION,
    USER_EXPLANATION_MESSAGE = X_USER_EXPLANATION_MESSAGE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where RULE_ID = X_RULE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_RULE_ID in NUMBER
) is
begin
  delete from EGO_USER_RULES_TL
  where RULE_ID = X_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from EGO_USER_RULES_B
  where RULE_ID = X_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from EGO_USER_RULES_TL T
  where not exists
    (select NULL
    from EGO_USER_RULES_B B
    where B.RULE_ID = T.RULE_ID
    );

  update EGO_USER_RULES_TL T set (
      DESCRIPTION,
      USER_EXPLANATION_MESSAGE
    ) = (select
      B.DESCRIPTION,
      B.USER_EXPLANATION_MESSAGE
    from EGO_USER_RULES_TL B
    where B.RULE_ID = T.RULE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RULE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RULE_ID,
      SUBT.LANGUAGE
    from EGO_USER_RULES_TL SUBB, EGO_USER_RULES_TL SUBT
    where SUBB.RULE_ID = SUBT.RULE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      or SUBB.USER_EXPLANATION_MESSAGE <> SUBT.USER_EXPLANATION_MESSAGE
      or (SUBB.USER_EXPLANATION_MESSAGE is null and SUBT.USER_EXPLANATION_MESSAGE is not null)
      or (SUBB.USER_EXPLANATION_MESSAGE is not null and SUBT.USER_EXPLANATION_MESSAGE is null)
  ));

  insert into EGO_USER_RULES_TL (
    RULE_ID,
    DESCRIPTION,
    USER_EXPLANATION_MESSAGE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.RULE_ID,
    B.DESCRIPTION,
    B.USER_EXPLANATION_MESSAGE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from EGO_USER_RULES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from EGO_USER_RULES_TL T
    where T.RULE_ID = B.RULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  X_RULE_ID in NUMBER,
  X_USER_EXPLANATION_MESSAGE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
 ) is
begin
 update EGO_USER_RULES_TL set
   USER_EXPLANATION_MESSAGE = X_USER_EXPLANATION_MESSAGE,
   DESCRIPTION = X_DESCRIPTION,
   LAST_UPDATE_DATE = sysdate,
   LAST_UPDATED_BY = decode(x_owner, 'ORACLE', 1, 0),
   LAST_UPDATE_LOGIN = 0,
   SOURCE_LANG = userenv('LANG')
 where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
 and RULE_ID = X_RULE_ID;
end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_RULE_ID in NUMBER,
  X_RULESET_ID in NUMBER,
  X_SEQUENCE in NUMBER,
  X_RULE_NAME in VARCHAR2,
  X_ATTR_GROUP_TYPE in VARCHAR2,
  X_ATTR_GROUP_NAME in VARCHAR2,
  X_ATTR_NAME in VARCHAR2,
  X_SEVERITY in VARCHAR2,
  X_RULE_XML in CLOB,
  X_DESCRIPTION in VARCHAR2,
  X_USER_EXPLANATION_MESSAGE in VARCHAR2,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
   declare
     l_rule_id number := 0;
   begin

     EGO_USER_RULES_PKG.UPDATE_ROW(
       X_RULE_ID		=>	X_RULE_ID,
       X_RULESET_ID		=>	X_RULESET_ID,
       X_SEQUENCE		=>	X_SEQUENCE,
       X_RULE_NAME		=>	X_RULE_NAME,
       X_ATTR_GROUP_TYPE	=>	X_ATTR_GROUP_TYPE,
       X_ATTR_GROUP_NAME	=>	X_ATTR_GROUP_NAME,
       X_ATTR_NAME		=>	X_ATTR_NAME,
       X_SEVERITY		=>	X_SEVERITY,
       X_RULE_XML		=>	X_RULE_XML,
       X_DESCRIPTION		=>	X_DESCRIPTION,
       X_USER_EXPLANATION_MESSAGE	=>	X_USER_EXPLANATION_MESSAGE,
       X_LAST_UPDATE_DATE	=>	SYSDATE,
       X_LAST_UPDATED_BY	=>	X_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN	=>	X_LAST_UPDATE_LOGIN
     );

   exception
     when NO_DATA_FOUND then
       select EGO_USER_RULES_S.nextval into l_rule_id from dual;

       EGO_USER_RULES_PKG.INSERT_ROW(
         X_ROWID		=>	X_ROWID,
	 X_RULE_ID		=>	l_rule_id,
	 X_RULESET_ID		=>	X_RULESET_ID,
	 X_SEQUENCE		=>	X_SEQUENCE,
	 X_RULE_NAME		=>	X_RULE_NAME,
	 X_ATTR_GROUP_TYPE	=>	X_ATTR_GROUP_TYPE,
	 X_ATTR_GROUP_NAME	=>	X_ATTR_GROUP_NAME,
	 X_ATTR_NAME		=>	X_ATTR_NAME,
	 X_SEVERITY		=>	X_SEVERITY,
	 X_RULE_XML		=>	X_RULE_XML,
	 X_DESCRIPTION		=>	X_DESCRIPTION,
	 X_USER_EXPLANATION_MESSAGE	=>	X_USER_EXPLANATION_MESSAGE,
	 X_CREATION_DATE	=>	sysdate,
	 X_CREATED_BY		=>	X_CREATED_BY,
	 X_LAST_UPDATE_DATE	=>	sysdate,
	 X_LAST_UPDATED_BY	=>	X_LAST_UPDATED_BY,
	 X_LAST_UPDATE_LOGIN	=>	X_LAST_UPDATE_LOGIN
       );
   end;

end LOAD_ROW;

end EGO_USER_RULES_PKG;

/
