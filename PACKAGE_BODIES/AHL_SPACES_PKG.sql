--------------------------------------------------------
--  DDL for Package Body AHL_SPACES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_SPACES_PKG" as
/* $Header: AHLLSPCB.pls 115.4 2003/04/04 12:07:52 adharia noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SPACE_ID in NUMBER,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_BOM_DEPARTMENT_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_INACTIVE_FLAG in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_SPACE_CATEGORY in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SPACE_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AHL_SPACES_B
    where SPACE_ID = X_SPACE_ID
    ;
begin
  insert into AHL_SPACES_B (
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE3,
    BOM_DEPARTMENT_ID,
    ORGANIZATION_ID,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    INACTIVE_FLAG,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    SPACE_CATEGORY,
    OBJECT_VERSION_NUMBER,
    SPACE_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_ATTRIBUTE3,
    X_BOM_DEPARTMENT_ID,
    X_ORGANIZATION_ID,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_INACTIVE_FLAG,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_SPACE_CATEGORY,
    X_OBJECT_VERSION_NUMBER,
    X_SPACE_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AHL_SPACES_TL (
    SPACE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    SPACE_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_SPACE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_SPACE_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AHL_SPACES_TL T
    where T.SPACE_ID = X_SPACE_ID
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
  X_SPACE_ID in NUMBER,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_BOM_DEPARTMENT_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_INACTIVE_FLAG in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_SPACE_CATEGORY in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SPACE_NAME in VARCHAR2
) is
  cursor c is select
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE3,
      BOM_DEPARTMENT_ID,
      ORGANIZATION_ID,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      INACTIVE_FLAG,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      SPACE_CATEGORY,
      OBJECT_VERSION_NUMBER
    from AHL_SPACES_B
    where SPACE_ID = X_SPACE_ID
    for update of SPACE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      SPACE_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AHL_SPACES_TL
    where SPACE_ID = X_SPACE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of SPACE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND (recinfo.BOM_DEPARTMENT_ID = X_BOM_DEPARTMENT_ID)
      AND (recinfo.ORGANIZATION_ID = X_ORGANIZATION_ID)
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND (recinfo.INACTIVE_FLAG = X_INACTIVE_FLAG)
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
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
      AND (recinfo.SPACE_CATEGORY = X_SPACE_CATEGORY)
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.SPACE_NAME = X_SPACE_NAME)
               OR ((tlinfo.SPACE_NAME is null) AND (X_SPACE_NAME is null)))
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
  X_SPACE_ID in NUMBER,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_BOM_DEPARTMENT_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_INACTIVE_FLAG in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_SPACE_CATEGORY in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SPACE_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AHL_SPACES_B set
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    BOM_DEPARTMENT_ID = X_BOM_DEPARTMENT_ID,
    ORGANIZATION_ID = X_ORGANIZATION_ID,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    INACTIVE_FLAG = X_INACTIVE_FLAG,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    SPACE_CATEGORY = X_SPACE_CATEGORY,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where SPACE_ID = X_SPACE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AHL_SPACES_TL set
    SPACE_NAME = X_SPACE_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where SPACE_ID = X_SPACE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_SPACE_ID in NUMBER
) is
begin
  delete from AHL_SPACES_TL
  where SPACE_ID = X_SPACE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AHL_SPACES_B
  where SPACE_ID = X_SPACE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AHL_SPACES_TL T
  where not exists
    (select NULL
    from AHL_SPACES_B B
    where B.SPACE_ID = T.SPACE_ID
    );

  update AHL_SPACES_TL T set (
      SPACE_NAME
    ) = (select
      B.SPACE_NAME
    from AHL_SPACES_TL B
    where B.SPACE_ID = T.SPACE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SPACE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SPACE_ID,
      SUBT.LANGUAGE
    from AHL_SPACES_TL SUBB, AHL_SPACES_TL SUBT
    where SUBB.SPACE_ID = SUBT.SPACE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SPACE_NAME <> SUBT.SPACE_NAME
      or (SUBB.SPACE_NAME is null and SUBT.SPACE_NAME is not null)
      or (SUBB.SPACE_NAME is not null and SUBT.SPACE_NAME is null)
  ));

  insert into AHL_SPACES_TL (
    SPACE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    SPACE_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.SPACE_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.SPACE_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AHL_SPACES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AHL_SPACES_TL T
    where T.SPACE_ID = B.SPACE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure  LOAD_ROW(
  X_SPACE_ID in NUMBER,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_BOM_DEPARTMENT_ID in NUMBER,
  X_ORGANIZATION_ID in NUMBER,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_INACTIVE_FLAG in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_SPACE_CATEGORY in VARCHAR2,
  X_SPACE_NAME in VARCHAR2,

  X_OWNER in VARCHAR2
  )
  IS
  l_user_id     number := 0;
  l_obj_verno   number;
  l_dummy_char  varchar2(1);
  l_row_id      varchar2(100);
  l_obj_id      number;


cursor  c_obj_verno is
  select  object_version_number
  from    AHL_SPACES_B
  where   SPACE_ID =  X_SPACE_ID;

cursor c_chk_rec_exists is
  select 'x'
  from   AHL_SPACES_B
  where  SPACE_ID = X_SPACE_ID;

cursor c_get_rec_id is
   select AHL_SPACES_B_S.NEXTVAL
   from DUAL;

BEGIN

  if X_OWNER = 'SEED' then
     l_user_id := 1;
 end if;

 open c_chk_rec_exists;
 fetch c_chk_rec_exists into l_dummy_char;
 if c_chk_rec_exists%notfound
 then
    close c_chk_rec_exists;

    if X_SPACE_ID is null then
        open c_get_rec_id;
        fetch c_get_rec_id into l_obj_id;
        close c_get_rec_id;
    else
       l_obj_id := X_SPACE_ID;
    end if ;

    l_obj_verno := 1;

AHL_SPACES_PKG.INSERT_ROW (
X_ROWID			=>	l_row_id	,
X_SPACE_ID		=>	l_obj_id	,
X_OBJECT_VERSION_NUMBER	=>	l_obj_verno	,

X_ATTRIBUTE13		=>	X_ATTRIBUTE13	,
X_ATTRIBUTE14		=>	X_ATTRIBUTE14	,
X_ATTRIBUTE15		=>	X_ATTRIBUTE15	,
X_ATTRIBUTE3		=>	X_ATTRIBUTE3	,
X_BOM_DEPARTMENT_ID	=>	X_BOM_DEPARTMENT_ID	,
X_ORGANIZATION_ID	=>	X_ORGANIZATION_ID	,
X_ATTRIBUTE4		=>	X_ATTRIBUTE4	,
X_ATTRIBUTE5		=>	X_ATTRIBUTE5	,
X_ATTRIBUTE6		=>	X_ATTRIBUTE6	,
X_ATTRIBUTE7		=>	X_ATTRIBUTE7	,
X_INACTIVE_FLAG		=>	'Y'		,
X_ATTRIBUTE_CATEGORY	=>	X_ATTRIBUTE_CATEGORY	,
X_ATTRIBUTE1		=>	X_ATTRIBUTE1	,
X_ATTRIBUTE2		=>	X_ATTRIBUTE2	,
X_ATTRIBUTE8		=>	X_ATTRIBUTE8	,
X_ATTRIBUTE9		=>	X_ATTRIBUTE9	,
X_ATTRIBUTE10		=>	X_ATTRIBUTE10	,
X_ATTRIBUTE11		=>	X_ATTRIBUTE11	,
X_ATTRIBUTE12		=>	X_ATTRIBUTE12	,
X_SPACE_CATEGORY	=>	X_SPACE_CATEGORY	,
X_SPACE_NAME		=>	X_SPACE_NAME	,

X_CREATION_DATE 	=>      SYSDATE         ,
X_CREATED_BY            =>      l_user_id       ,
X_LAST_UPDATE_DATE      =>      SYSDATE         ,
X_LAST_UPDATED_BY       =>      l_user_id       ,
X_LAST_UPDATE_LOGIN     =>      0
);

else
   close c_chk_rec_exists;
   open c_obj_verno;
   fetch c_obj_verno into l_obj_verno;
   close c_obj_verno;

   l_obj_verno := l_obj_verno + 1;

AHL_SPACES_PKG.UPDATE_ROW (
X_SPACE_ID		=>	X_SPACE_ID	,
X_OBJECT_VERSION_NUMBER	=>	l_obj_verno	,

X_ATTRIBUTE13		=>	X_ATTRIBUTE13	,
X_ATTRIBUTE14		=>	X_ATTRIBUTE14	,
X_ATTRIBUTE15		=>	X_ATTRIBUTE15	,
X_ATTRIBUTE3		=>	X_ATTRIBUTE3	,
X_BOM_DEPARTMENT_ID	=>	X_BOM_DEPARTMENT_ID	,
X_ORGANIZATION_ID	=>	X_ORGANIZATION_ID	,
X_ATTRIBUTE4		=>	X_ATTRIBUTE4	,
X_ATTRIBUTE5		=>	X_ATTRIBUTE5	,
X_ATTRIBUTE6		=>	X_ATTRIBUTE6	,
X_ATTRIBUTE7		=>	X_ATTRIBUTE7	,
X_INACTIVE_FLAG		=>	X_INACTIVE_FLAG	,
X_ATTRIBUTE_CATEGORY	=>	X_ATTRIBUTE_CATEGORY	,
X_ATTRIBUTE1		=>	X_ATTRIBUTE1	,
X_ATTRIBUTE2		=>	X_ATTRIBUTE2	,
X_ATTRIBUTE8		=>	X_ATTRIBUTE8	,
X_ATTRIBUTE9		=>	X_ATTRIBUTE9	,
X_ATTRIBUTE10		=>	X_ATTRIBUTE10	,
X_ATTRIBUTE11		=>	X_ATTRIBUTE11	,
X_ATTRIBUTE12		=>	X_ATTRIBUTE12	,
X_SPACE_CATEGORY	=>	X_SPACE_CATEGORY	,
X_SPACE_NAME		=>	X_SPACE_NAME	,

X_LAST_UPDATE_DATE      =>      SYSDATE         ,
X_LAST_UPDATED_BY       =>      l_user_id       ,
X_LAST_UPDATE_LOGIN     =>      0
	);
end if;
END LOAD_ROW ;

procedure TRANSLATE_ROW(
          X_SPACE_ID     in NUMBER,
	  X_SPACE_NAME in VARCHAR2,
          X_OWNER               in VARCHAR2
 ) IS

 begin
  update AHL_SPACES_TL set
    SPACE_NAME = nvl(X_SPACE_NAME,space_name),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1, 0),
       last_update_login = 0
  where SPACE_ID = X_SPACE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
end TRANSLATE_ROW;

end AHL_SPACES_PKG;

/
