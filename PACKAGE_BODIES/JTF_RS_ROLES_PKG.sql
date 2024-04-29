--------------------------------------------------------
--  DDL for Package Body JTF_RS_ROLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_ROLES_PKG" as
/* $Header: jtfrstrb.pls 120.0 2005/05/11 08:22:32 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ROLE_ID in NUMBER,
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
  X_ROLE_CODE in VARCHAR2,
  X_ROLE_TYPE_CODE in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_MEMBER_FLAG in VARCHAR2,
  X_ADMIN_FLAG in VARCHAR2,
  X_LEAD_FLAG in VARCHAR2,
  X_MANAGER_FLAG in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ROLE_NAME in VARCHAR2,
  X_ROLE_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_RS_ROLES_B
    where ROLE_ID = X_ROLE_ID
    ;
begin
  insert into JTF_RS_ROLES_B (
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
    ROLE_ID,
    ROLE_CODE,
    ROLE_TYPE_CODE,
    SEEDED_FLAG,
    MEMBER_FLAG,
    ADMIN_FLAG,
    LEAD_FLAG,
    MANAGER_FLAG,
    ACTIVE_FLAG,
    OBJECT_VERSION_NUMBER,
    ATTRIBUTE1,
    ATTRIBUTE2,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
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
    X_ROLE_ID,
    X_ROLE_CODE,
    X_ROLE_TYPE_CODE,
    X_SEEDED_FLAG,
    X_MEMBER_FLAG,
    X_ADMIN_FLAG,
    X_LEAD_FLAG,
    X_MANAGER_FLAG,
    X_ACTIVE_FLAG,
    1,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_RS_ROLES_TL (
    ROLE_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    ROLE_NAME,
    ROLE_DESC,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_ROLE_ID,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_ROLE_NAME,
    X_ROLE_DESC,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_RS_ROLES_TL T
    where T.ROLE_ID = X_ROLE_ID
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
  X_ROLE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c is select
      OBJECT_VERSION_NUMBER
    from JTF_RS_ROLES_B
    where ROLE_ID = X_ROLE_ID
    and OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER
    for update of ROLE_ID nowait;
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
  X_ROLE_ID in NUMBER,
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
  X_ROLE_CODE in VARCHAR2,
  X_ROLE_TYPE_CODE in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_MEMBER_FLAG in VARCHAR2,
  X_ADMIN_FLAG in VARCHAR2,
  X_LEAD_FLAG in VARCHAR2,
  X_MANAGER_FLAG in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ROLE_NAME in VARCHAR2,
  X_ROLE_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_RS_ROLES_B set
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
    ROLE_CODE = X_ROLE_CODE,
    ROLE_TYPE_CODE = X_ROLE_TYPE_CODE,
    SEEDED_FLAG = X_SEEDED_FLAG,
    MEMBER_FLAG = X_MEMBER_FLAG,
    ADMIN_FLAG = X_ADMIN_FLAG,
    LEAD_FLAG = X_LEAD_FLAG,
    MANAGER_FLAG = X_MANAGER_FLAG,
    ACTIVE_FLAG = X_ACTIVE_FLAG,
    OBJECT_VERSION_NUMBER = nvl(OBJECT_VERSION_NUMBER,1) + 1,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROLE_ID = X_ROLE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_RS_ROLES_TL set
    ROLE_NAME = X_ROLE_NAME,
    ROLE_DESC = X_ROLE_DESC,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ROLE_ID = X_ROLE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

Procedure TRANSLATE_ROW
(X_role_id  in number,
 X_role_name in varchar2,
 x_role_desc in varchar2,
 x_Last_update_date in date,
 x_last_updated_by in number,
 x_last_update_login in number)
is
begin

Update jtf_rs_roles_tl set
role_name		= nvl(x_role_name,role_name),
role_desc		= nvl(x_role_desc,role_desc),
last_update_date	= nvl(x_last_update_date,sysdate),
last_updated_by		= x_last_updated_by,
last_update_login	= 0,
source_lang		= userenv('LANG')
where role_id		= x_role_id
and userenv('LANG') in (LANGUAGE,SOURCE_LANG);

end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_ROLE_ID in NUMBER,
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
  X_ROLE_CODE in VARCHAR2,
  X_ROLE_TYPE_CODE in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_MEMBER_FLAG in VARCHAR2,
  X_ADMIN_FLAG in VARCHAR2,
  X_LEAD_FLAG in VARCHAR2,
  X_MANAGER_FLAG in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ROLE_NAME in VARCHAR2,
  X_ROLE_DESC in VARCHAR2,
  X_OWNER in VARCHAR2
) is
l_row_id rowid;
l_user_id number;
l_last_updated_by number := -1;

CURSOR c_last_updated IS
  SELECT last_updated_by from JTF_RS_ROLES_VL
  WHERE role_id = X_ROLE_ID;

begin
if (X_OWNER = 'SEED') then
	l_user_id := 1;
else
	l_user_id := 0;
end if;

OPEN c_last_updated;
FETCH c_last_updated into l_last_updated_by;
      IF c_last_updated%NOTFOUND THEN
	 jtf_rs_roles_pkg.insert_row(
                X_ROWID               => l_row_id ,
                X_ROLE_ID               => x_role_id ,
                X_ATTRIBUTE3            => X_ATTRIBUTE3 ,
                X_ATTRIBUTE4            => X_ATTRIBUTE4 ,
                X_ATTRIBUTE5            => X_ATTRIBUTE5 ,
                X_ATTRIBUTE6            => X_ATTRIBUTE6 ,
                X_ATTRIBUTE7            => X_ATTRIBUTE7 ,
                X_ATTRIBUTE8            => X_ATTRIBUTE8 ,
                X_ATTRIBUTE9            => X_ATTRIBUTE9 ,
                X_ATTRIBUTE10           => X_ATTRIBUTE10 ,
                X_ATTRIBUTE11           => X_ATTRIBUTE11 ,
                X_ATTRIBUTE12           => X_ATTRIBUTE12 ,
                X_ATTRIBUTE13           => X_ATTRIBUTE13 ,
                X_ATTRIBUTE14           => X_ATTRIBUTE14 ,
                X_ATTRIBUTE15           => X_ATTRIBUTE15 ,
                X_ATTRIBUTE_CATEGORY    => X_ATTRIBUTE_CATEGORY ,
                X_ROLE_CODE             => x_role_code ,
                X_ROLE_TYPE_CODE        => x_role_type_code ,
                X_SEEDED_FLAG           => x_seeded_flag ,
                X_MEMBER_FLAG           => x_member_flag ,
                X_ADMIN_FLAG            => x_admin_flag ,
                X_LEAD_FLAG             => x_lead_flag ,
                X_MANAGER_FLAG          => x_manager_flag ,
                X_ACTIVE_FLAG           => x_active_flag ,
                X_ATTRIBUTE1            => X_ATTRIBUTE1 ,
                X_ATTRIBUTE2            => X_ATTRIBUTE2 ,
                X_ROLE_NAME             => x_role_name ,
                X_ROLE_DESC             => x_role_desc ,
                X_CREATION_DATE		=> sysdate      ,
                X_CREATED_BY	        => l_user_id ,
                X_LAST_UPDATE_DATE      => sysdate      ,
                X_LAST_UPDATED_BY       => l_user_id ,
                X_LAST_UPDATE_LOGIN     => 0     );
      ELSIF c_last_updated%FOUND THEN
         IF l_last_updated_by = 1 THEN
            jtf_rs_roles_pkg.update_row(
                X_ROLE_ID               => x_role_id ,
                X_ATTRIBUTE3            => X_ATTRIBUTE3 ,
                X_ATTRIBUTE4            => X_ATTRIBUTE4 ,
                X_ATTRIBUTE5            => X_ATTRIBUTE5 ,
                X_ATTRIBUTE6            => X_ATTRIBUTE6 ,
                X_ATTRIBUTE7            => X_ATTRIBUTE7 ,
                X_ATTRIBUTE8            => X_ATTRIBUTE8 ,
                X_ATTRIBUTE9            => X_ATTRIBUTE9 ,
                X_ATTRIBUTE10           => X_ATTRIBUTE10 ,
                X_ATTRIBUTE11           => X_ATTRIBUTE11 ,
                X_ATTRIBUTE12           => X_ATTRIBUTE12 ,
                X_ATTRIBUTE13           => X_ATTRIBUTE13 ,
                X_ATTRIBUTE14           => X_ATTRIBUTE14 ,
                X_ATTRIBUTE15           => X_ATTRIBUTE15 ,
                X_ATTRIBUTE_CATEGORY    => X_ATTRIBUTE_CATEGORY ,
                X_ROLE_CODE             => x_role_code ,
                X_ROLE_TYPE_CODE        => x_role_type_code ,
                X_SEEDED_FLAG           => x_seeded_flag ,
                X_MEMBER_FLAG           => x_member_flag ,
                X_ADMIN_FLAG            => x_admin_flag ,
                X_LEAD_FLAG             => x_lead_flag ,
                X_MANAGER_FLAG          => x_manager_flag ,
                X_ACTIVE_FLAG           => x_active_flag ,
                X_OBJECT_VERSION_NUMBER => x_object_version_number ,
                X_ATTRIBUTE1            => X_ATTRIBUTE1 ,
                X_ATTRIBUTE2            => X_ATTRIBUTE2 ,
                X_ROLE_NAME             => x_role_name ,
                X_ROLE_DESC             => x_role_desc ,
                X_LAST_UPDATE_DATE      => sysdate      ,
                X_LAST_UPDATED_BY       => l_user_id ,
                X_LAST_UPDATE_LOGIN     => 0     );
           END IF;
      END IF;
CLOSE c_last_updated;
End LOAD_ROW;


procedure DELETE_ROW (
  X_ROLE_ID in NUMBER
) is
begin
  delete from JTF_RS_ROLES_TL
  where ROLE_ID = X_ROLE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_RS_ROLES_B
  where ROLE_ID = X_ROLE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_RS_ROLES_TL T
  where not exists
    (select NULL
    from JTF_RS_ROLES_B B
    where B.ROLE_ID = T.ROLE_ID
    );

  update JTF_RS_ROLES_TL T set (
      ROLE_NAME,
      ROLE_DESC
    ) = (select
      B.ROLE_NAME,
      B.ROLE_DESC
    from JTF_RS_ROLES_TL B
    where B.ROLE_ID = T.ROLE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ROLE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ROLE_ID,
      SUBT.LANGUAGE
    from JTF_RS_ROLES_TL SUBB, JTF_RS_ROLES_TL SUBT
    where SUBB.ROLE_ID = SUBT.ROLE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ROLE_NAME <> SUBT.ROLE_NAME
      or SUBB.ROLE_DESC <> SUBT.ROLE_DESC
      or (SUBB.ROLE_DESC is null and SUBT.ROLE_DESC is not null)
      or (SUBB.ROLE_DESC is not null and SUBT.ROLE_DESC is null)
  ));

  insert into JTF_RS_ROLES_TL (
    ROLE_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    ROLE_NAME,
    ROLE_DESC,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ROLE_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.ROLE_NAME,
    B.ROLE_DESC,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_RS_ROLES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_RS_ROLES_TL T
    where T.ROLE_ID = B.ROLE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end JTF_RS_ROLES_PKG;

/
