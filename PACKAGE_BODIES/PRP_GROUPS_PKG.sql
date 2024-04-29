--------------------------------------------------------
--  DDL for Package Body PRP_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PRP_GROUPS_PKG" as
/* $Header: PRPTGRPB.pls 120.1 2005/10/21 17:38:59 hekkiral noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_GROUP_NAME in VARCHAR2,
  X_GROUP_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PRP_GROUPS_B
    where GROUP_ID = X_GROUP_ID
    ;
begin
  insert into PRP_GROUPS_B (
    GROUP_ID,
    OBJECT_VERSION_NUMBER,
    ATTRIBUTE_CATEGORY,
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
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_GROUP_ID,
    X_OBJECT_VERSION_NUMBER,
    X_ATTRIBUTE_CATEGORY,
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
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into PRP_GROUPS_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    GROUP_ID,
    GROUP_NAME,
    GROUP_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_GROUP_ID,
    X_GROUP_NAME,
    X_GROUP_DESC,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PRP_GROUPS_TL T
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
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_GROUP_NAME in VARCHAR2,
  X_GROUP_DESC in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      ATTRIBUTE_CATEGORY,
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
      ATTRIBUTE15
    from PRP_GROUPS_B
    where GROUP_ID = X_GROUP_ID
    for update of GROUP_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      GROUP_NAME,
      GROUP_DESC,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PRP_GROUPS_TL
    where GROUP_ID = X_GROUP_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of GROUP_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.GROUP_NAME = X_GROUP_NAME)
          AND ((tlinfo.GROUP_DESC = X_GROUP_DESC)
               OR ((tlinfo.GROUP_DESC is null) AND (X_GROUP_DESC is null)))
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
  X_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
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
  X_GROUP_NAME in VARCHAR2,
  X_GROUP_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update PRP_GROUPS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
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
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where GROUP_ID = X_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PRP_GROUPS_TL set
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
  delete from PRP_GROUPS_TL
  where GROUP_ID = X_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PRP_GROUPS_B
  where GROUP_ID = X_GROUP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from PRP_GROUPS_TL T
  where not exists
    (select NULL
    from PRP_GROUPS_B B
    where B.GROUP_ID = T.GROUP_ID
    );

  update PRP_GROUPS_TL T set (
      GROUP_NAME,
      GROUP_DESC
    ) = (select
      B.GROUP_NAME,
      B.GROUP_DESC
    from PRP_GROUPS_TL B
    where B.GROUP_ID = T.GROUP_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.GROUP_ID,
      T.LANGUAGE
  ) in (select
      SUBT.GROUP_ID,
      SUBT.LANGUAGE
    from PRP_GROUPS_TL SUBB, PRP_GROUPS_TL SUBT
    where SUBB.GROUP_ID = SUBT.GROUP_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.GROUP_NAME <> SUBT.GROUP_NAME
      or SUBB.GROUP_DESC <> SUBT.GROUP_DESC
      or (SUBB.GROUP_DESC is null and SUBT.GROUP_DESC is not null)
      or (SUBB.GROUP_DESC is not null and SUBT.GROUP_DESC is null)
  ));

  insert into PRP_GROUPS_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    GROUP_ID,
    GROUP_NAME,
    GROUP_DESC,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.GROUP_ID,
    B.GROUP_NAME,
    B.GROUP_DESC,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PRP_GROUPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PRP_GROUPS_TL T
    where T.GROUP_ID = B.GROUP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

--
-- Should be called only from lct file
--+
procedure LOAD_ROW
  (
  p_owner                 IN VARCHAR2,
  p_group_id              IN NUMBER,
  p_object_version_number IN NUMBER,
  p_attribute_category    IN VARCHAR2,
  p_attribute1            IN VARCHAR2,
  p_attribute2            IN VARCHAR2,
  p_attribute3            IN VARCHAR2,
  p_attribute4            IN VARCHAR2,
  p_attribute5            IN VARCHAR2,
  p_attribute6            IN VARCHAR2,
  p_attribute7            IN VARCHAR2,
  p_attribute8            IN VARCHAR2,
  p_attribute9            IN VARCHAR2,
  p_attribute10           IN VARCHAR2,
  p_attribute11           IN VARCHAR2,
  p_attribute12           IN VARCHAR2,
  p_attribute13           IN VARCHAR2,
  p_attribute14           IN VARCHAR2,
  p_attribute15           IN VARCHAR2,
  p_group_name            IN VARCHAR2,
  p_group_desc            IN VARCHAR2
  )
is
  l_user_id                        NUMBER := 0;
  l_login_id                       NUMBER := 0;
  l_rowid                          VARCHAR2(256);
begin

    l_user_id := fnd_load_util.owner_id(p_owner);

  BEGIN

    update_row
      (
      X_GROUP_ID               => p_group_id,
      X_OBJECT_VERSION_NUMBER  => p_object_version_number,
      X_ATTRIBUTE_CATEGORY     => p_attribute_category,
      X_ATTRIBUTE1             => p_attribute1,
      X_ATTRIBUTE2             => p_attribute2,
      X_ATTRIBUTE3             => p_attribute3,
      X_ATTRIBUTE4             => p_attribute4,
      X_ATTRIBUTE5             => p_attribute5,
      X_ATTRIBUTE6             => p_attribute6,
      X_ATTRIBUTE7             => p_attribute7,
      X_ATTRIBUTE8             => p_attribute8,
      X_ATTRIBUTE9             => p_attribute9,
      X_ATTRIBUTE10            => p_attribute10,
      X_ATTRIBUTE11            => p_attribute11,
      X_ATTRIBUTE12            => p_attribute12,
      X_ATTRIBUTE13            => p_attribute13,
      X_ATTRIBUTE14            => p_attribute14,
      X_ATTRIBUTE15            => p_attribute15,
      X_GROUP_NAME             => p_group_name,
      X_GROUP_DESC             => p_group_desc,
      X_LAST_UPDATE_DATE       => sysdate,
      X_LAST_UPDATED_BY        => l_user_id,
      X_LAST_UPDATE_LOGIN      => l_login_id
      );

  EXCEPTION

     WHEN NO_DATA_FOUND THEN

       insert_row
       (
       X_ROWID                 => l_rowid,
       X_GROUP_ID              => p_group_id,
       X_OBJECT_VERSION_NUMBER => p_object_version_number,
       X_ATTRIBUTE_CATEGORY    => p_attribute_category,
       X_ATTRIBUTE1            => p_attribute1,
       X_ATTRIBUTE2            => p_attribute2,
       X_ATTRIBUTE3            => p_attribute3,
       X_ATTRIBUTE4            => p_attribute4,
       X_ATTRIBUTE5            => p_attribute5,
       X_ATTRIBUTE6            => p_attribute6,
       X_ATTRIBUTE7            => p_attribute7,
       X_ATTRIBUTE8            => p_attribute8,
       X_ATTRIBUTE9            => p_attribute9,
       X_ATTRIBUTE10           => p_attribute10,
       X_ATTRIBUTE11           => p_attribute11,
       X_ATTRIBUTE12           => p_attribute12,
       X_ATTRIBUTE13           => p_attribute13,
       X_ATTRIBUTE14           => p_attribute14,
       X_ATTRIBUTE15           => p_attribute15,
       X_GROUP_NAME            => p_group_name,
       X_GROUP_DESC            => p_group_desc,
       X_CREATION_DATE         => sysdate,
       X_CREATED_BY            => l_user_id,
       X_LAST_UPDATE_DATE      => sysdate,
       X_LAST_UPDATED_BY       => l_user_id,
       X_LAST_UPDATE_LOGIN     => l_login_id
       );

  END;

end LOAD_ROW;

procedure TRANSLATE_ROW
  (
   p_owner                              IN VARCHAR2,
   p_group_id                           IN NUMBER,
   p_group_name                         IN VARCHAR2,
   p_group_desc                         IN VARCHAR2
  )
IS
  l_login_id                       NUMBER := 0;
BEGIN

  UPDATE prp_groups_tl
    SET group_name = p_group_name,
    group_desc = p_group_desc,
    last_update_date = sysdate,
    last_updated_by = decode(p_owner, 'SEED', 1, 0),
    last_update_login = l_login_id,
    source_lang = userenv('LANG')
    WHERE userenv('LANG') in (LANGUAGE, SOURCE_LANG) AND
    group_id = p_group_id;

end TRANSLATE_ROW;

end PRP_GROUPS_PKG;

/
