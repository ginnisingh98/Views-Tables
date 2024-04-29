--------------------------------------------------------
--  DDL for Package Body JTF_RS_GROUPS_AUD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_GROUPS_AUD_PKG" as
/* $Header: jtfrstkb.pls 120.0.12010000.2 2009/05/11 07:38:07 rgokavar ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GROUP_AUDIT_ID in NUMBER,
  X_GROUP_ID in NUMBER,
  X_NEW_GROUP_NUMBER in VARCHAR2,
  X_OLD_GROUP_NUMBER in VARCHAR2,
  X_NEW_EMAIL_ADDRESS in VARCHAR2,
  X_OLD_EMAIL_ADDRESS in VARCHAR2,
  X_NEW_EXCLUSIVE_FLAG in VARCHAR2,
  X_OLD_EXCLUSIVE_FLAG in VARCHAR2,
  X_NEW_START_DATE_ACTIVE in DATE,
  X_OLD_START_DATE_ACTIVE in DATE,
  X_NEW_END_DATE_ACTIVE in DATE,
  X_OLD_END_DATE_ACTIVE in DATE,
  X_NEW_ACCOUNTING_CODE in VARCHAR2,
  X_OLD_ACCOUNTING_CODE in VARCHAR2,
  X_NEW_OBJECT_VERSION_NUMBER in NUMBER,
  X_OLD_OBJECT_VERSION_NUMBER in NUMBER,
  X_NEW_GROUP_NAME in VARCHAR2,
  X_OLD_GROUP_NAME in VARCHAR2,
  X_NEW_GROUP_DESC in VARCHAR2,
  X_OLD_GROUP_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_NEW_TIME_ZONE in NUMBER,
  X_OLD_TIME_ZONE in NUMBER
) is
  cursor C is select ROWID from JTF_RS_GROUPS_AUD_B
    where GROUP_AUDIT_ID = X_GROUP_AUDIT_ID
    ;
begin
  insert into JTF_RS_GROUPS_AUD_B (
    GROUP_AUDIT_ID,
    GROUP_ID,
    NEW_GROUP_NUMBER,
    OLD_GROUP_NUMBER,
    NEW_EMAIL_ADDRESS,
    OLD_EMAIL_ADDRESS,
    NEW_EXCLUSIVE_FLAG,
    OLD_EXCLUSIVE_FLAG,
    NEW_START_DATE_ACTIVE,
    OLD_START_DATE_ACTIVE,
    NEW_END_DATE_ACTIVE,
    OLD_END_DATE_ACTIVE,
    NEW_ACCOUNTING_CODE,
    OLD_ACCOUNTING_CODE,
    NEW_OBJECT_VERSION_NUMBER,
    OLD_OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    NEW_TIME_ZONE,
    OLD_TIME_ZONE
  ) values (
    X_GROUP_AUDIT_ID,
    X_GROUP_ID,
    X_NEW_GROUP_NUMBER,
    X_OLD_GROUP_NUMBER,
    X_NEW_EMAIL_ADDRESS,
    X_OLD_EMAIL_ADDRESS,
    X_NEW_EXCLUSIVE_FLAG,
    X_OLD_EXCLUSIVE_FLAG,
    X_NEW_START_DATE_ACTIVE,
    X_OLD_START_DATE_ACTIVE,
    X_NEW_END_DATE_ACTIVE,
    X_OLD_END_DATE_ACTIVE,
    X_NEW_ACCOUNTING_CODE,
    X_OLD_ACCOUNTING_CODE,
    X_NEW_OBJECT_VERSION_NUMBER,
    X_OLD_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_NEW_TIME_ZONE,
    X_OLD_TIME_ZONE
  );

  insert into JTF_RS_GROUPS_AUD_TL (
    GROUP_AUDIT_ID,
    NEW_GROUP_NAME,
    OLD_GROUP_NAME,
    NEW_GROUP_DESC,
    OLD_GROUP_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_GROUP_AUDIT_ID,
    X_NEW_GROUP_NAME,
    X_OLD_GROUP_NAME,
    X_NEW_GROUP_DESC,
    X_OLD_GROUP_DESC,
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
    from JTF_RS_GROUPS_AUD_TL T
    where T.GROUP_AUDIT_ID = X_GROUP_AUDIT_ID
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
  X_GROUP_AUDIT_ID in NUMBER,
  X_GROUP_ID in NUMBER,
  X_NEW_GROUP_NUMBER in VARCHAR2,
  X_OLD_GROUP_NUMBER in VARCHAR2,
  X_NEW_EMAIL_ADDRESS in VARCHAR2,
  X_OLD_EMAIL_ADDRESS in VARCHAR2,
  X_NEW_EXCLUSIVE_FLAG in VARCHAR2,
  X_OLD_EXCLUSIVE_FLAG in VARCHAR2,
  X_NEW_START_DATE_ACTIVE in DATE,
  X_OLD_START_DATE_ACTIVE in DATE,
  X_NEW_END_DATE_ACTIVE in DATE,
  X_OLD_END_DATE_ACTIVE in DATE,
  X_NEW_ACCOUNTING_CODE in VARCHAR2,
  X_OLD_ACCOUNTING_CODE in VARCHAR2,
  X_NEW_OBJECT_VERSION_NUMBER in NUMBER,
  X_OLD_OBJECT_VERSION_NUMBER in NUMBER,
  X_NEW_GROUP_NAME in VARCHAR2,
  X_OLD_GROUP_NAME in VARCHAR2,
  X_NEW_GROUP_DESC in VARCHAR2,
  X_OLD_GROUP_DESC in VARCHAR2,
  X_NEW_TIME_ZONE in NUMBER,
  X_OLD_TIME_ZONE in NUMBER
) is
  cursor c is select
      GROUP_ID,
      NEW_GROUP_NUMBER,
      OLD_GROUP_NUMBER,
      NEW_EMAIL_ADDRESS,
      OLD_EMAIL_ADDRESS,
      NEW_EXCLUSIVE_FLAG,
      OLD_EXCLUSIVE_FLAG,
      NEW_START_DATE_ACTIVE,
      OLD_START_DATE_ACTIVE,
      NEW_END_DATE_ACTIVE,
      OLD_END_DATE_ACTIVE,
      NEW_ACCOUNTING_CODE,
      OLD_ACCOUNTING_CODE,
      NEW_OBJECT_VERSION_NUMBER,
      OLD_OBJECT_VERSION_NUMBER,
      NEW_TIME_ZONE,
      OLD_TIME_ZONE
    from JTF_RS_GROUPS_AUD_B
    where GROUP_AUDIT_ID = X_GROUP_AUDIT_ID
    for update of GROUP_AUDIT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NEW_GROUP_NAME,
      OLD_GROUP_NAME,
      NEW_GROUP_DESC,
      OLD_GROUP_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_RS_GROUPS_AUD_TL
    where GROUP_AUDIT_ID = X_GROUP_AUDIT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of GROUP_AUDIT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.GROUP_ID = X_GROUP_ID)
      AND ((recinfo.NEW_GROUP_NUMBER = X_NEW_GROUP_NUMBER)
           OR ((recinfo.NEW_GROUP_NUMBER is null) AND (X_NEW_GROUP_NUMBER is null)))
      AND ((recinfo.OLD_GROUP_NUMBER = X_OLD_GROUP_NUMBER)
           OR ((recinfo.OLD_GROUP_NUMBER is null) AND (X_OLD_GROUP_NUMBER is null)))
      AND ((recinfo.NEW_EMAIL_ADDRESS = X_NEW_EMAIL_ADDRESS)
           OR ((recinfo.NEW_EMAIL_ADDRESS is null) AND (X_NEW_EMAIL_ADDRESS is null)))
      AND ((recinfo.OLD_EMAIL_ADDRESS = X_OLD_EMAIL_ADDRESS)
           OR ((recinfo.OLD_EMAIL_ADDRESS is null) AND (X_OLD_EMAIL_ADDRESS is null)))
      AND ((recinfo.NEW_EXCLUSIVE_FLAG = X_NEW_EXCLUSIVE_FLAG)
           OR ((recinfo.NEW_EXCLUSIVE_FLAG is null) AND (X_NEW_EXCLUSIVE_FLAG is null)))
      AND ((recinfo.OLD_EXCLUSIVE_FLAG = X_OLD_EXCLUSIVE_FLAG)
           OR ((recinfo.OLD_EXCLUSIVE_FLAG is null) AND (X_OLD_EXCLUSIVE_FLAG is null)))
      AND ((recinfo.NEW_START_DATE_ACTIVE = X_NEW_START_DATE_ACTIVE)
           OR ((recinfo.NEW_START_DATE_ACTIVE is null) AND (X_NEW_START_DATE_ACTIVE is null)))
      AND ((recinfo.OLD_START_DATE_ACTIVE = X_OLD_START_DATE_ACTIVE)
           OR ((recinfo.OLD_START_DATE_ACTIVE is null) AND (X_OLD_START_DATE_ACTIVE is null)))
      AND ((recinfo.NEW_END_DATE_ACTIVE = X_NEW_END_DATE_ACTIVE)
           OR ((recinfo.NEW_END_DATE_ACTIVE is null) AND (X_NEW_END_DATE_ACTIVE is null)))
      AND ((recinfo.OLD_END_DATE_ACTIVE = X_OLD_END_DATE_ACTIVE)
           OR ((recinfo.OLD_END_DATE_ACTIVE is null) AND (X_OLD_END_DATE_ACTIVE is null)))
      AND ((recinfo.NEW_ACCOUNTING_CODE = X_NEW_ACCOUNTING_CODE)
           OR ((recinfo.NEW_ACCOUNTING_CODE is null) AND (X_NEW_ACCOUNTING_CODE is null)))
      AND ((recinfo.OLD_ACCOUNTING_CODE = X_OLD_ACCOUNTING_CODE)
           OR ((recinfo.OLD_ACCOUNTING_CODE is null) AND (X_OLD_ACCOUNTING_CODE is null)))
      AND ((recinfo.NEW_OBJECT_VERSION_NUMBER = X_NEW_OBJECT_VERSION_NUMBER)
           OR ((recinfo.NEW_OBJECT_VERSION_NUMBER is null) AND (X_NEW_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.OLD_OBJECT_VERSION_NUMBER = X_OLD_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OLD_OBJECT_VERSION_NUMBER is null) AND (X_OLD_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.NEW_TIME_ZONE = X_NEW_TIME_ZONE)
           OR ((recinfo.NEW_TIME_ZONE is null) AND (X_NEW_TIME_ZONE is null)))
      AND ((recinfo.OLD_TIME_ZONE = X_OLD_TIME_ZONE)
           OR ((recinfo.OLD_TIME_ZONE is null) AND (X_OLD_TIME_ZONE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.NEW_GROUP_NAME = X_NEW_GROUP_NAME)
               OR ((tlinfo.NEW_GROUP_NAME is null) AND (X_NEW_GROUP_NAME is null)))
          AND ((tlinfo.OLD_GROUP_NAME = X_OLD_GROUP_NAME)
               OR ((tlinfo.OLD_GROUP_NAME is null) AND (X_OLD_GROUP_NAME is null)))
          AND ((tlinfo.NEW_GROUP_DESC = X_NEW_GROUP_DESC)
               OR ((tlinfo.NEW_GROUP_DESC is null) AND (X_NEW_GROUP_DESC is null)))
          AND ((tlinfo.OLD_GROUP_DESC = X_OLD_GROUP_DESC)
               OR ((tlinfo.OLD_GROUP_DESC is null) AND (X_OLD_GROUP_DESC is null)))
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
  X_GROUP_AUDIT_ID in NUMBER,
  X_GROUP_ID in NUMBER,
  X_NEW_GROUP_NUMBER in VARCHAR2,
  X_OLD_GROUP_NUMBER in VARCHAR2,
  X_NEW_EMAIL_ADDRESS in VARCHAR2,
  X_OLD_EMAIL_ADDRESS in VARCHAR2,
  X_NEW_EXCLUSIVE_FLAG in VARCHAR2,
  X_OLD_EXCLUSIVE_FLAG in VARCHAR2,
  X_NEW_START_DATE_ACTIVE in DATE,
  X_OLD_START_DATE_ACTIVE in DATE,
  X_NEW_END_DATE_ACTIVE in DATE,
  X_OLD_END_DATE_ACTIVE in DATE,
  X_NEW_ACCOUNTING_CODE in VARCHAR2,
  X_OLD_ACCOUNTING_CODE in VARCHAR2,
  X_NEW_OBJECT_VERSION_NUMBER in NUMBER,
  X_OLD_OBJECT_VERSION_NUMBER in NUMBER,
  X_NEW_GROUP_NAME in VARCHAR2,
  X_OLD_GROUP_NAME in VARCHAR2,
  X_NEW_GROUP_DESC in VARCHAR2,
  X_OLD_GROUP_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_NEW_TIME_ZONE in NUMBER,
  X_OLD_TIME_ZONE in NUMBER
) is
begin
  update JTF_RS_GROUPS_AUD_B set
    GROUP_ID = X_GROUP_ID,
    NEW_GROUP_NUMBER = X_NEW_GROUP_NUMBER,
    OLD_GROUP_NUMBER = X_OLD_GROUP_NUMBER,
    NEW_EMAIL_ADDRESS = X_NEW_EMAIL_ADDRESS,
    OLD_EMAIL_ADDRESS = X_OLD_EMAIL_ADDRESS,
    NEW_EXCLUSIVE_FLAG = X_NEW_EXCLUSIVE_FLAG,
    OLD_EXCLUSIVE_FLAG = X_OLD_EXCLUSIVE_FLAG,
    NEW_START_DATE_ACTIVE = X_NEW_START_DATE_ACTIVE,
    OLD_START_DATE_ACTIVE = X_OLD_START_DATE_ACTIVE,
    NEW_END_DATE_ACTIVE = X_NEW_END_DATE_ACTIVE,
    OLD_END_DATE_ACTIVE = X_OLD_END_DATE_ACTIVE,
    NEW_ACCOUNTING_CODE = X_NEW_ACCOUNTING_CODE,
    OLD_ACCOUNTING_CODE = X_OLD_ACCOUNTING_CODE,
    NEW_OBJECT_VERSION_NUMBER = X_NEW_OBJECT_VERSION_NUMBER,
    OLD_OBJECT_VERSION_NUMBER = X_OLD_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    NEW_TIME_ZONE = X_NEW_TIME_ZONE,
    OLD_TIME_ZONE = X_OLD_TIME_ZONE
  where GROUP_AUDIT_ID = X_GROUP_AUDIT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_RS_GROUPS_AUD_TL set
    NEW_GROUP_NAME = X_NEW_GROUP_NAME,
    OLD_GROUP_NAME = X_OLD_GROUP_NAME,
    NEW_GROUP_DESC = X_NEW_GROUP_DESC,
    OLD_GROUP_DESC = X_OLD_GROUP_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where GROUP_AUDIT_ID = X_GROUP_AUDIT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_GROUP_AUDIT_ID in NUMBER
) is
begin
  delete from JTF_RS_GROUPS_AUD_TL
  where GROUP_AUDIT_ID = X_GROUP_AUDIT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_RS_GROUPS_AUD_B
  where GROUP_AUDIT_ID = X_GROUP_AUDIT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_RS_GROUPS_AUD_TL T
  where not exists
    (select NULL
    from JTF_RS_GROUPS_AUD_B B
    where B.GROUP_AUDIT_ID = T.GROUP_AUDIT_ID
    );

  update JTF_RS_GROUPS_AUD_TL T set (
      NEW_GROUP_NAME,
      OLD_GROUP_NAME,
      NEW_GROUP_DESC,
      OLD_GROUP_DESC
    ) = (select
      B.NEW_GROUP_NAME,
      B.OLD_GROUP_NAME,
      B.NEW_GROUP_DESC,
      B.OLD_GROUP_DESC
    from JTF_RS_GROUPS_AUD_TL B
    where B.GROUP_AUDIT_ID = T.GROUP_AUDIT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.GROUP_AUDIT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.GROUP_AUDIT_ID,
      SUBT.LANGUAGE
    from JTF_RS_GROUPS_AUD_TL SUBB, JTF_RS_GROUPS_AUD_TL SUBT
    where SUBB.GROUP_AUDIT_ID = SUBT.GROUP_AUDIT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NEW_GROUP_NAME <> SUBT.NEW_GROUP_NAME
      or (SUBB.NEW_GROUP_NAME is null and SUBT.NEW_GROUP_NAME is not null)
      or (SUBB.NEW_GROUP_NAME is not null and SUBT.NEW_GROUP_NAME is null)
      or SUBB.OLD_GROUP_NAME <> SUBT.OLD_GROUP_NAME
      or (SUBB.OLD_GROUP_NAME is null and SUBT.OLD_GROUP_NAME is not null)
      or (SUBB.OLD_GROUP_NAME is not null and SUBT.OLD_GROUP_NAME is null)
      or SUBB.NEW_GROUP_DESC <> SUBT.NEW_GROUP_DESC
      or (SUBB.NEW_GROUP_DESC is null and SUBT.NEW_GROUP_DESC is not null)
      or (SUBB.NEW_GROUP_DESC is not null and SUBT.NEW_GROUP_DESC is null)
      or SUBB.OLD_GROUP_DESC <> SUBT.OLD_GROUP_DESC
      or (SUBB.OLD_GROUP_DESC is null and SUBT.OLD_GROUP_DESC is not null)
      or (SUBB.OLD_GROUP_DESC is not null and SUBT.OLD_GROUP_DESC is null)
  ));

  insert into JTF_RS_GROUPS_AUD_TL (
    GROUP_AUDIT_ID,
    NEW_GROUP_NAME,
    OLD_GROUP_NAME,
    NEW_GROUP_DESC,
    OLD_GROUP_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.GROUP_AUDIT_ID,
    B.NEW_GROUP_NAME,
    B.OLD_GROUP_NAME,
    B.NEW_GROUP_DESC,
    B.OLD_GROUP_DESC,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_RS_GROUPS_AUD_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_RS_GROUPS_AUD_TL T
    where T.GROUP_AUDIT_ID = B.GROUP_AUDIT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


Procedure TRANSLATE_ROW
(x_group_audit_id  in number,
 x_new_group_name in varchar2,
 x_new_group_desc in varchar2,
 x_old_group_name in varchar2,
 x_old_group_desc in varchar2,
 x_Last_update_date in date,
 x_last_updated_by in number,
 x_last_update_login in number)
is
begin

Update jtf_rs_groups_aud_tl set
new_group_name		= nvl(x_new_group_name,new_group_name),
new_group_desc		= nvl(x_new_group_desc,new_group_desc),
old_group_name		= nvl(x_old_group_name,old_group_name),
old_group_desc		= nvl(x_old_group_desc,old_group_desc),
last_update_date	= nvl(x_last_update_date,sysdate),
last_updated_by		= x_last_updated_by,
last_update_login	= 0,
source_lang		= userenv('LANG')
where group_audit_id		= x_group_audit_id
and userenv('LANG') in (LANGUAGE,SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end TRANSLATE_ROW;

end JTF_RS_GROUPS_AUD_PKG;

/
