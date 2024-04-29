--------------------------------------------------------
--  DDL for Package Body JTF_AM_TERR_QUALIFIERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AM_TERR_QUALIFIERS_PKG" as
/* $Header: jtfamttb.pls 115.1 2003/04/23 23:08:28 sroychou noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TERR_QUALIFIER_ID in NUMBER,
  X_QUAL_USG_ID       in NUMBER,
  X_QUAL_ATTRIBUTE_NAME  in VARCHAR,
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
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER)
IS

cursor C is select ROWID from JTF_AM_TERR_QUALIFIERS
    where TERR_QUALIFIER_ID  = X_TERR_QUALIFIER_ID
    ;

begin
  insert into JTF_AM_TERR_QUALIFIERS (
  TERR_QUALIFIER_ID,
  QUAL_USG_ID      ,
  QUAL_ATTRIBUTE_NAME ,
  ATTRIBUTE1 ,
  ATTRIBUTE2 ,
  ATTRIBUTE3 ,
  ATTRIBUTE4 ,
  ATTRIBUTE5 ,
  ATTRIBUTE6 ,
  ATTRIBUTE7 ,
  ATTRIBUTE8 ,
  ATTRIBUTE9 ,
  ATTRIBUTE10,
  ATTRIBUTE11,
  ATTRIBUTE12,
  ATTRIBUTE13,
  ATTRIBUTE14,
  ATTRIBUTE15,
  ATTRIBUTE_CATEGORY ,
  CREATION_DATE ,
  CREATED_BY ,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY ,
  LAST_UPDATE_LOGIN,
  OBJECT_VERSION_NUMBER,
  SECURITY_GROUP_ID
  ) values (
  X_TERR_QUALIFIER_ID ,
  X_QUAL_USG_ID       ,
  X_QUAL_ATTRIBUTE_NAME,
  X_ATTRIBUTE1 ,
  X_ATTRIBUTE2 ,
  X_ATTRIBUTE3 ,
  X_ATTRIBUTE4 ,
  X_ATTRIBUTE5 ,
  X_ATTRIBUTE6 ,
  X_ATTRIBUTE7 ,
  X_ATTRIBUTE8 ,
  X_ATTRIBUTE9 ,
  X_ATTRIBUTE10,
  X_ATTRIBUTE11,
  X_ATTRIBUTE12,
  X_ATTRIBUTE13,
  X_ATTRIBUTE14,
  X_ATTRIBUTE15,
  X_ATTRIBUTE_CATEGORY ,
  X_CREATION_DATE ,
  X_CREATED_BY ,
  X_LAST_UPDATE_DATE ,
  X_LAST_UPDATED_BY ,
  X_LAST_UPDATE_LOGIN ,
  1,
  X_SECURITY_GROUP_ID
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;


procedure LOCK_ROW (
  X_TERR_QUALIFIER_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
  cursor c1 is select
      OBJECT_VERSION_NUMBER
    from JTF_AM_TERR_QUALIFIERS
    where TERR_QUALIFIER_ID = X_TERR_QUALIFIER_ID
    for update of TERR_QUALIFIER_ID nowait;
    tlinfo c1%rowtype ;
begin
        open c1;
        fetch c1 into tlinfo;
        if (c1%notfound) then
                close c1;
                fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
            app_exception.raise_exception;
         end if;
         close c1;

  if (tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
  then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

end LOCK_ROW;

procedure UPDATE_ROW (
  X_TERR_QUALIFIER_ID in NUMBER,
  X_QUAL_USG_ID       in NUMBER,
  X_QUAL_ATTRIBUTE_NAME  in VARCHAR,
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
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER
) is
begin
  update JTF_AM_TERR_QUALIFIERS set
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    TERR_QUALIFIER_ID = X_TERR_QUALIFIER_ID,
    QUAL_USG_ID = X_QUAL_USG_ID,
    QUAL_ATTRIBUTE_NAME = X_QUAL_ATTRIBUTE_NAME,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID
  where TERR_QUALIFIER_ID = X_TERR_QUALIFIER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure LOAD_ROW (
  X_TERR_QUALIFIER_ID in NUMBER,
  X_OWNER             in VARCHAR2,
  X_QUAL_USG_ID       in NUMBER,
  X_QUAL_ATTRIBUTE_NAME  in VARCHAR2,
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
  X_ATTRIBUTE_CATEGORY in VARCHAR2
)
IS

l_row_id rowid;
l_user_id number;
l_last_updated_by number := -1;
l_object_version_number number := 1;

CURSOR c_last_updated IS
  SELECT last_updated_by,
         object_version_number
    from JTF_AM_TERR_QUALIFIERS
   WHERE terr_qualifier_id = x_terr_qualifier_id;

begin
if (X_OWNER = 'SEED') then
        l_user_id := 1;
else
        l_user_id := 0;
end if;

OPEN c_last_updated;
FETCH c_last_updated into l_last_updated_by, l_object_version_number ;
      IF c_last_updated%NOTFOUND THEN
         l_object_version_number := 1;
           jtf_am_terr_qualifiers_pkg.insert_row(
                X_ROWID               => l_row_id ,
                X_TERR_QUALIFIER_ID       => X_TERR_QUALIFIER_ID,
                X_ATTRIBUTE1            => X_ATTRIBUTE1 ,
                X_ATTRIBUTE2            => X_ATTRIBUTE2 ,
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
                X_QUAL_USG_ID           => X_QUAL_USG_ID,
                X_QUAL_ATTRIBUTE_NAME   => X_QUAL_ATTRIBUTE_NAME,
                X_CREATION_DATE         => sysdate      ,
                X_CREATED_BY            => l_user_id ,
                X_LAST_UPDATE_DATE      => sysdate      ,
                X_LAST_UPDATED_BY       => l_user_id ,
                X_SECURITY_GROUP_ID     => null ,
                X_LAST_UPDATE_LOGIN     => 0 );



      ELSIF c_last_updated%FOUND THEN

         IF l_last_updated_by IN (1,0) THEN
            l_object_version_number :=   l_object_version_number + 1;

             jtf_am_terr_qualifiers_pkg.update_row(
                X_TERR_QUALIFIER_ID       => X_TERR_QUALIFIER_ID,
                X_ATTRIBUTE1            => X_ATTRIBUTE1 ,
                X_ATTRIBUTE2            => X_ATTRIBUTE2 ,
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
                X_QUAL_USG_ID           => X_QUAL_USG_ID,
                X_QUAL_ATTRIBUTE_NAME   => X_QUAL_ATTRIBUTE_NAME,
                X_OBJECT_VERSION_NUMBER => l_object_version_number,
                X_SECURITY_GROUP_ID     => null ,
                X_LAST_UPDATE_DATE      => sysdate      ,
                X_LAST_UPDATED_BY       => l_user_id ,
                X_LAST_UPDATE_LOGIN     => 0 );

       END IF;
      END IF;
CLOSE c_last_updated;


END;

procedure DELETE_ROW (
  X_TERR_QUALIFIER_ID in NUMBER
) is
begin
  delete from JTF_AM_TERR_QUALIFIERS
  where TERR_QUALIFIER_ID = X_TERR_QUALIFIER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;
end JTF_AM_TERR_QUALIFIERS_PKG;

/
