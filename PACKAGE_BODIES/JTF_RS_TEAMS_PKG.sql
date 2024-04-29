--------------------------------------------------------
--  DDL for Package Body JTF_RS_TEAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_TEAMS_PKG" as
/* $Header: jtfrsttb.pls 120.0 2005/05/11 08:22:36 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TEAM_ID in NUMBER,
  X_TEAM_NUMBER in VARCHAR2,
  X_EMAIL_ADDRESS in VARCHAR2,
  X_EXCLUSIVE_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_TEAM_NAME in VARCHAR2,
  X_TEAM_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_RS_TEAMS_B
    where TEAM_ID = X_TEAM_ID
    ;
begin
  insert into JTF_RS_TEAMS_B (
    TEAM_ID,
    TEAM_NUMBER,
    EMAIL_ADDRESS,
    EXCLUSIVE_FLAG,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    OBJECT_VERSION_NUMBER,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE_CATEGORY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_TEAM_ID,
    X_TEAM_NUMBER,
    X_EMAIL_ADDRESS,
    X_EXCLUSIVE_FLAG,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    1,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_ATTRIBUTE_CATEGORY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_RS_TEAMS_TL (
    TEAM_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    TEAM_NAME,
    TEAM_DESC,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_TEAM_ID,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_TEAM_NAME,
    X_TEAM_DESC,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_RS_TEAMS_TL T
    where T.TEAM_ID = X_TEAM_ID
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
  X_TEAM_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      OBJECT_VERSION_NUMBER
    from JTF_RS_TEAMS_VL
    where TEAM_ID = X_TEAM_ID
    and OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
    for update of TEAM_ID nowait;
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

end LOCK_ROW;

procedure UPDATE_ROW (
  X_TEAM_ID in NUMBER,
  X_TEAM_NUMBER in VARCHAR2,
  X_EMAIL_ADDRESS in VARCHAR2,
  X_EXCLUSIVE_FLAG in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_TEAM_NAME in VARCHAR2,
  X_TEAM_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_RS_TEAMS_B set
    TEAM_NUMBER = X_TEAM_NUMBER,
    EMAIL_ADDRESS = X_EMAIL_ADDRESS,
    EXCLUSIVE_FLAG = X_EXCLUSIVE_FLAG,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where TEAM_ID = X_TEAM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_RS_TEAMS_TL set
    TEAM_NAME = X_TEAM_NAME,
    TEAM_DESC = X_TEAM_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where TEAM_ID = X_TEAM_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_TEAM_ID in NUMBER
) is
begin
  delete from JTF_RS_TEAMS_TL
  where TEAM_ID = X_TEAM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_RS_TEAMS_B
  where TEAM_ID = X_TEAM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_RS_TEAMS_TL T
  where not exists
    (select NULL
    from JTF_RS_TEAMS_B B
    where B.TEAM_ID = T.TEAM_ID
    );

  update JTF_RS_TEAMS_TL T set (
      TEAM_NAME,
      TEAM_DESC
    ) = (select
      B.TEAM_NAME,
      B.TEAM_DESC
    from JTF_RS_TEAMS_TL B
    where B.TEAM_ID = T.TEAM_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TEAM_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TEAM_ID,
      SUBT.LANGUAGE
    from JTF_RS_TEAMS_TL SUBB, JTF_RS_TEAMS_TL SUBT
    where SUBB.TEAM_ID = SUBT.TEAM_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TEAM_NAME <> SUBT.TEAM_NAME
      or SUBB.TEAM_DESC <> SUBT.TEAM_DESC
      or (SUBB.TEAM_DESC is null and SUBT.TEAM_DESC is not null)
      or (SUBB.TEAM_DESC is not null and SUBT.TEAM_DESC is null)
  ));

  insert into JTF_RS_TEAMS_TL (
    TEAM_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    TEAM_NAME,
    TEAM_DESC,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TEAM_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.TEAM_NAME,
    B.TEAM_DESC,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_RS_TEAMS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_RS_TEAMS_TL T
    where T.TEAM_ID = B.TEAM_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


Procedure TRANSLATE_ROW
(x_team_id  in number,
 x_team_name in varchar2,
 x_team_desc in varchar2,
 x_Last_update_date in date,
 x_last_updated_by in number,
 x_last_update_login in number)
is
begin

Update jtf_rs_teams_tl set
team_name		= nvl(x_team_name,team_name),
team_desc		= nvl(x_team_desc,team_desc),
last_update_date	= nvl(x_last_update_date,sysdate),
last_updated_by		= x_last_updated_by,
last_update_login	= 0,
source_lang		= userenv('LANG')
where team_id		= x_team_id
and userenv('LANG') in (LANGUAGE,SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end TRANSLATE_ROW;

end JTF_RS_TEAMS_PKG;

/
