--------------------------------------------------------
--  DDL for Package Body JTF_RS_SKILL_LEVELS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_SKILL_LEVELS_PKG" as
/* $Header: jtfrshsb.pls 120.0 2005/05/11 08:20:10 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SKILL_LEVEL_ID in NUMBER,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_SKILL_LEVEL in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_LEVEL_NAME in VARCHAR2,
  X_LEVEL_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_RS_SKILL_LEVELS_B
    where SKILL_LEVEL_ID = X_SKILL_LEVEL_ID
    ;
begin
  insert into JTF_RS_SKILL_LEVELS_B (
    ATTRIBUTE15,
    ATTRIBUTE_CATEGORY,
    OBJECT_VERSION_NUMBER,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    SKILL_LEVEL_ID,
    SKILL_LEVEL,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ATTRIBUTE15,
    X_ATTRIBUTE_CATEGORY,
    X_OBJECT_VERSION_NUMBER,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_SKILL_LEVEL_ID,
    X_SKILL_LEVEL,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_RS_SKILL_LEVELS_TL (
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LEVEL_NAME,
    LEVEL_DESC,
    CREATED_BY,
    SKILL_LEVEL_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_LEVEL_NAME,
    X_LEVEL_DESC,
    X_CREATED_BY,
    X_SKILL_LEVEL_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_RS_SKILL_LEVELS_TL T
    where T.SKILL_LEVEL_ID = X_SKILL_LEVEL_ID
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
  X_SKILL_LEVEL_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER)
is
  cursor c is select
      OBJECT_VERSION_NUMBER
    from JTF_RS_SKILL_LEVELS_B
    where SKILL_LEVEL_ID = X_SKILL_LEVEL_ID
    for update of SKILL_LEVEL_ID nowait;
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
  if (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_SKILL_LEVEL_ID in NUMBER,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_SKILL_LEVEL in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_LEVEL_NAME in VARCHAR2,
  X_LEVEL_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_RS_SKILL_LEVELS_B set
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    SKILL_LEVEL = X_SKILL_LEVEL,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SKILL_LEVEL_ID = X_SKILL_LEVEL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_RS_SKILL_LEVELS_TL set
    LEVEL_NAME = X_LEVEL_NAME,
    LEVEL_DESC = X_LEVEL_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where SKILL_LEVEL_ID = X_SKILL_LEVEL_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SKILL_LEVEL_ID in NUMBER
) is
begin
  delete from JTF_RS_SKILL_LEVELS_TL
  where SKILL_LEVEL_ID = X_SKILL_LEVEL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_RS_SKILL_LEVELS_B
  where SKILL_LEVEL_ID = X_SKILL_LEVEL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_RS_SKILL_LEVELS_TL T
  where not exists
    (select NULL
    from JTF_RS_SKILL_LEVELS_B B
    where B.SKILL_LEVEL_ID = T.SKILL_LEVEL_ID
    );

  update JTF_RS_SKILL_LEVELS_TL T set (
      LEVEL_NAME,
      LEVEL_DESC
    ) = (select
      B.LEVEL_NAME,
      B.LEVEL_DESC
    from JTF_RS_SKILL_LEVELS_TL B
    where B.SKILL_LEVEL_ID = T.SKILL_LEVEL_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SKILL_LEVEL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SKILL_LEVEL_ID,
      SUBT.LANGUAGE
    from JTF_RS_SKILL_LEVELS_TL SUBB, JTF_RS_SKILL_LEVELS_TL SUBT
    where SUBB.SKILL_LEVEL_ID = SUBT.SKILL_LEVEL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.LEVEL_NAME <> SUBT.LEVEL_NAME
      or SUBB.LEVEL_DESC <> SUBT.LEVEL_DESC
      or (SUBB.LEVEL_DESC is null and SUBT.LEVEL_DESC is not null)
      or (SUBB.LEVEL_DESC is not null and SUBT.LEVEL_DESC is null)
  ));

  insert into JTF_RS_SKILL_LEVELS_TL (
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LEVEL_NAME,
    LEVEL_DESC,
    CREATED_BY,
    SKILL_LEVEL_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.LEVEL_NAME,
    B.LEVEL_DESC,
    B.CREATED_BY,
    B.SKILL_LEVEL_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_RS_SKILL_LEVELS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_RS_SKILL_LEVELS_TL T
    where T.SKILL_LEVEL_ID = B.SKILL_LEVEL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

Procedure TRANSLATE_ROW
(x_skill_level_id in number,
 x_level_name in varchar2,
 x_level_desc in varchar2,
 x_last_update_date in date,
 x_last_updated_by in number,
 x_last_update_login in number)
is
begin

update jtf_rs_skill_levels_tl set
level_name     = nvl(x_level_name,level_name),
level_desc     = nvl(x_level_desc,level_desc),
last_update_date        = nvl(x_last_update_date,sysdate),
last_updated_by         = x_last_updated_by,
last_update_login       = 0,
source_lang             = userenv('LANG')
where skill_level_id      = x_skill_level_id
and userenv('LANG') in (LANGUAGE,SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SKILL_LEVEL_ID in NUMBER,
  X_SKILL_LEVEL in NUMBER,
  X_LEVEL_NAME in VARCHAR2,
  X_LEVEL_DESC in VARCHAR2,
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
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OWNER in VARCHAR2
) is
l_row_id rowid;
l_user_id number;
l_last_updated_by number := -1;

CURSOR c_last_updated IS
  SELECT last_updated_by from JTF_RS_SKILL_LEVELS_VL
  WHERE skill_level_id = X_SKILL_LEVEL_ID;

begin
if (X_OWNER = 'SEED') then
   l_user_id := 1;
else
   l_user_id := 0;
end if;

OPEN c_last_updated;
FETCH c_last_updated into l_last_updated_by;
      IF c_last_updated%NOTFOUND THEN
            JTF_RS_SKILL_LEVELS_PKG.INSERT_ROW(
                   X_ROWID                  => X_ROWID,
                   X_SKILL_LEVEL_ID       => x_skill_level_id,
                   X_LEVEL_NAME           => X_LEVEL_NAME,
                   X_LEVEL_DESC         => X_LEVEL_DESC,
                   X_SKILL_LEVEL => X_SKILL_LEVEL,
                   X_ATTRIBUTE1             => X_ATTRIBUTE1,
                   X_ATTRIBUTE2             => X_ATTRIBUTE2,
                   X_ATTRIBUTE3             => X_ATTRIBUTE3,
                   X_ATTRIBUTE4             => X_ATTRIBUTE4,
                   X_ATTRIBUTE5             => X_ATTRIBUTE5,
                   X_ATTRIBUTE6             => X_ATTRIBUTE6,
                   X_ATTRIBUTE7             => X_ATTRIBUTE7,
                   X_ATTRIBUTE8             => X_ATTRIBUTE8,
                   X_ATTRIBUTE9             => X_ATTRIBUTE9,
                   X_ATTRIBUTE10            => X_ATTRIBUTE10,
                   X_ATTRIBUTE11            => X_ATTRIBUTE11,
                   X_ATTRIBUTE12            => X_ATTRIBUTE12,
                   X_ATTRIBUTE13            => X_ATTRIBUTE13,
                   X_ATTRIBUTE14            => X_ATTRIBUTE14,
                   X_ATTRIBUTE15            => X_ATTRIBUTE15,
                   X_ATTRIBUTE_CATEGORY     => X_ATTRIBUTE_CATEGORY,
                   X_OBJECT_VERSION_NUMBER  => X_OBJECT_VERSION_NUMBER,
                   X_CREATION_DATE          => sysdate,
                   X_CREATED_BY             => l_user_id,
                   X_LAST_UPDATE_DATE       => sysdate,
                   X_LAST_UPDATED_BY        => l_user_id,
                   X_LAST_UPDATE_LOGIN      => 0);
         ELSIF c_last_updated%FOUND THEN
	    IF l_last_updated_by = 1 THEN
                  JTF_RS_SKILL_LEVELS_PKG.UPDATE_ROW(
                         X_SKILL_LEVEL_ID           => X_SKILL_LEVEL_ID,
                         X_SKILL_LEVEL         => X_SKILL_LEVEL,
                         X_LEVEL_NAME          => X_LEVEL_NAME,
                         X_LEVEL_DESC          => X_LEVEL_DESC,
                         X_ATTRIBUTE1             => X_ATTRIBUTE1,
                         X_ATTRIBUTE2             => X_ATTRIBUTE2,
                         X_ATTRIBUTE3             => X_ATTRIBUTE3,
                         X_ATTRIBUTE4             => X_ATTRIBUTE4,
                         X_ATTRIBUTE5             => X_ATTRIBUTE5,
                         X_ATTRIBUTE6             => X_ATTRIBUTE6,
                         X_ATTRIBUTE7             => X_ATTRIBUTE7,
                         X_ATTRIBUTE8             => X_ATTRIBUTE8,
                         X_ATTRIBUTE9             => X_ATTRIBUTE9,
                         X_ATTRIBUTE10            => X_ATTRIBUTE10,
                         X_ATTRIBUTE11            => X_ATTRIBUTE11,
                         X_ATTRIBUTE12            => X_ATTRIBUTE12,
                         X_ATTRIBUTE13            => X_ATTRIBUTE13,
                         X_ATTRIBUTE14            => X_ATTRIBUTE14,
                         X_ATTRIBUTE15            => X_ATTRIBUTE15,
                         X_ATTRIBUTE_CATEGORY     => X_ATTRIBUTE_CATEGORY,
                         X_OBJECT_VERSION_NUMBER  => X_OBJECT_VERSION_NUMBER,
                         X_LAST_UPDATE_DATE       => sysdate,
                         X_LAST_UPDATED_BY        => l_user_id,
                         X_LAST_UPDATE_LOGIN      => 0);
             END IF;
       END IF;
   CLOSE c_last_updated;
End LOAD_ROW;

end JTF_RS_SKILL_LEVELS_PKG;

/
