--------------------------------------------------------
--  DDL for Package Body JTF_RS_DYNAMIC_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_DYNAMIC_GROUPS_PKG" as
/* $Header: jtfrstdb.pls 120.0 2005/05/11 08:22:08 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GROUP_ID in NUMBER,
  X_GROUP_NUMBER in VARCHAR2,
  X_USAGE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_SQL_TEXT in VARCHAR2,
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
  X_GROUP_NAME in VARCHAR2,
  X_GROUP_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_RS_DYNAMIC_GROUPS_B
    where GROUP_ID = X_GROUP_ID
    ;
begin
  insert into JTF_RS_DYNAMIC_GROUPS_B (
    GROUP_ID,
    GROUP_NUMBER,
    USAGE,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    SQL_TEXT,
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
    X_GROUP_ID,
    X_GROUP_NUMBER,
    X_USAGE,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_SQL_TEXT,
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

  insert into JTF_RS_DYNAMIC_GROUPS_TL (
    GROUP_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    GROUP_NAME,
    GROUP_DESC,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_GROUP_ID,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_GROUP_NAME,
    X_GROUP_DESC,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_RS_DYNAMIC_GROUPS_TL T
    where T.GROUP_ID = X_GROUP_ID
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
  X_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      OBJECT_VERSION_NUMBER
    from JTF_RS_DYNAMIC_GROUPS_B
    where GROUP_ID = X_GROUP_ID
    and OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
    for update of GROUP_ID nowait;
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
  X_GROUP_ID in NUMBER,
  X_GROUP_NUMBER in VARCHAR2,
  X_USAGE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_SQL_TEXT in VARCHAR2,
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
  X_GROUP_NAME in VARCHAR2,
  X_GROUP_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_RS_DYNAMIC_GROUPS_B set
    GROUP_NUMBER = X_GROUP_NUMBER,
    USAGE = X_USAGE,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    SQL_TEXT = X_SQL_TEXT,
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
  where GROUP_ID = X_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_RS_DYNAMIC_GROUPS_TL set
    GROUP_NAME = X_GROUP_NAME,
    GROUP_DESC = X_GROUP_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where GROUP_ID = X_GROUP_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_GROUP_ID in NUMBER
) is
begin
  delete from JTF_RS_DYNAMIC_GROUPS_TL
  where GROUP_ID = X_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_RS_DYNAMIC_GROUPS_B
  where GROUP_ID = X_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_RS_DYNAMIC_GROUPS_TL T
  where not exists
    (select NULL
    from JTF_RS_DYNAMIC_GROUPS_B B
    where B.GROUP_ID = T.GROUP_ID
    );

  update JTF_RS_DYNAMIC_GROUPS_TL T set (
      GROUP_NAME,
      GROUP_DESC
    ) = (select
      B.GROUP_NAME,
      B.GROUP_DESC
    from JTF_RS_DYNAMIC_GROUPS_TL B
    where B.GROUP_ID = T.GROUP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.GROUP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.GROUP_ID,
      SUBT.LANGUAGE
    from JTF_RS_DYNAMIC_GROUPS_TL SUBB, JTF_RS_DYNAMIC_GROUPS_TL SUBT
    where SUBB.GROUP_ID = SUBT.GROUP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.GROUP_NAME <> SUBT.GROUP_NAME
      or SUBB.GROUP_DESC <> SUBT.GROUP_DESC
      or (SUBB.GROUP_DESC is null and SUBT.GROUP_DESC is not null)
      or (SUBB.GROUP_DESC is not null and SUBT.GROUP_DESC is null)
  ));

  insert into JTF_RS_DYNAMIC_GROUPS_TL (
    GROUP_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    GROUP_NAME,
    GROUP_DESC,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.GROUP_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.GROUP_NAME,
    B.GROUP_DESC,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_RS_DYNAMIC_GROUPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_RS_DYNAMIC_GROUPS_TL T
    where T.GROUP_ID = B.GROUP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


Procedure TRANSLATE_ROW
(x_group_id  in number,
 x_group_name in varchar2,
 x_group_desc in varchar2,
 x_Last_update_date in date,
 x_last_updated_by in number,
 x_last_update_login in number)
is
begin

Update jtf_rs_dynamic_groups_tl set
group_name		= nvl(x_group_name,group_name),
group_desc		= nvl(x_group_desc,group_desc),
last_update_date	= nvl(x_last_update_date,sysdate),
last_updated_by		= x_last_updated_by,
last_update_login	= 0,
source_lang		= userenv('LANG')
where group_id		= x_group_id
and userenv('LANG') in (LANGUAGE,SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end TRANSLATE_ROW;

end JTF_RS_DYNAMIC_GROUPS_PKG;

/
