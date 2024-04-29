--------------------------------------------------------
--  DDL for Package Body JTF_STORE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_STORE_GRP" as
/* $Header: JTFGSTRB.pls 115.3 2000/11/14 13:04:28 pkm ship      $ */
procedure INSERT_ROW (
  X_ROWID 			in out 	VARCHAR2,
  X_STORE_ID 			in 	NUMBER,
  X_SECURITY_GROUP_ID 		in	NUMBER,
  X_OBJECT_VERSION_NUMBER 	in 	NUMBER,
  X_ATTRIBUTE_CATEGORY 		in 	VARCHAR2,
  X_ATTRIBUTE1 			in 	VARCHAR2,
  X_ATTRIBUTE2 			in 	VARCHAR2,
  X_ATTRIBUTE3 			in 	VARCHAR2,
  X_ATTRIBUTE4 			in 	VARCHAR2,
  X_ATTRIBUTE5 			in 	VARCHAR2,
  X_ATTRIBUTE6 			in 	VARCHAR2,
  X_ATTRIBUTE7 			in 	VARCHAR2,
  X_ATTRIBUTE8 			in 	VARCHAR2,
  X_ATTRIBUTE9 			in 	VARCHAR2,
  X_ATTRIBUTE10 		in 	VARCHAR2,
  X_ATTRIBUTE11 		in 	VARCHAR2,
  X_ATTRIBUTE12 		in 	VARCHAR2,
  X_ATTRIBUTE13 		in 	VARCHAR2,
  X_ATTRIBUTE14 		in 	VARCHAR2,
  X_ATTRIBUTE15 		in 	VARCHAR2,
  X_STORE_NAME 			in 	VARCHAR2,
  X_STORE_DESCRIPTION 		in 	VARCHAR2,
  X_CREATION_DATE 		in 	DATE,
  X_CREATED_BY 			in 	NUMBER,
  X_LAST_UPDATE_DATE 		in 	DATE,
  X_LAST_UPDATED_BY 		in 	NUMBER,
  X_LAST_UPDATE_LOGIN 		in 	NUMBER
) is
  cursor C is select ROWID from JTF_STORES_B
    where STORE_ID = X_STORE_ID
    ;
begin
  insert into JTF_STORES_B (
    SECURITY_GROUP_ID,
    STORE_ID,
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
    X_SECURITY_GROUP_ID,
    X_STORE_ID,
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

  insert into JTF_STORES_TL (
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    STORE_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    STORE_NAME,
    STORE_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_SECURITY_GROUP_ID,
    X_OBJECT_VERSION_NUMBER,
    X_STORE_ID,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_STORE_NAME,
    X_STORE_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_STORES_TL T
    where T.STORE_ID = X_STORE_ID
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
  X_STORE_ID 			in NUMBER,
  X_SECURITY_GROUP_ID 		in NUMBER,
  X_OBJECT_VERSION_NUMBER 	in NUMBER,
  X_ATTRIBUTE_CATEGORY 		in VARCHAR2,
  X_ATTRIBUTE1 			in VARCHAR2,
  X_ATTRIBUTE2 			in VARCHAR2,
  X_ATTRIBUTE3 			in VARCHAR2,
  X_ATTRIBUTE4 			in VARCHAR2,
  X_ATTRIBUTE5 			in VARCHAR2,
  X_ATTRIBUTE6 			in VARCHAR2,
  X_ATTRIBUTE7 			in VARCHAR2,
  X_ATTRIBUTE8 			in VARCHAR2,
  X_ATTRIBUTE9 			in VARCHAR2,
  X_ATTRIBUTE10 		in VARCHAR2,
  X_ATTRIBUTE11 		in VARCHAR2,
  X_ATTRIBUTE12 		in VARCHAR2,
  X_ATTRIBUTE13 		in VARCHAR2,
  X_ATTRIBUTE14 		in VARCHAR2,
  X_ATTRIBUTE15 		in VARCHAR2,
  X_STORE_NAME 			in VARCHAR2,
  X_STORE_DESCRIPTION 		in VARCHAR2
) is
  cursor c is select
      SECURITY_GROUP_ID,
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
    from JTF_STORES_B
    where STORE_ID = X_STORE_ID
    for update of STORE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      STORE_NAME,
      STORE_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from JTF_STORES_TL
    where STORE_ID = X_STORE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of STORE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
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
      if (    ((tlinfo.STORE_NAME = X_STORE_NAME)
               OR ((tlinfo.STORE_NAME is null) AND (X_STORE_NAME is null)))
          AND ((tlinfo.STORE_DESCRIPTION = X_STORE_DESCRIPTION)
               OR ((tlinfo.STORE_DESCRIPTION is null) AND (X_STORE_DESCRIPTION is null)))
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
  X_STORE_ID 			in NUMBER,
  X_SECURITY_GROUP_ID 		in NUMBER,
  X_OBJECT_VERSION_NUMBER 	in NUMBER,
  X_ATTRIBUTE_CATEGORY 		in VARCHAR2,
  X_ATTRIBUTE1 			in VARCHAR2,
  X_ATTRIBUTE2 			in VARCHAR2,
  X_ATTRIBUTE3 			in VARCHAR2,
  X_ATTRIBUTE4 			in VARCHAR2,
  X_ATTRIBUTE5 			in VARCHAR2,
  X_ATTRIBUTE6 			in VARCHAR2,
  X_ATTRIBUTE7 			in VARCHAR2,
  X_ATTRIBUTE8 			in VARCHAR2,
  X_ATTRIBUTE9 			in VARCHAR2,
  X_ATTRIBUTE10 		in VARCHAR2,
  X_ATTRIBUTE11 		in VARCHAR2,
  X_ATTRIBUTE12 		in VARCHAR2,
  X_ATTRIBUTE13 		in VARCHAR2,
  X_ATTRIBUTE14 		in VARCHAR2,
  X_ATTRIBUTE15 		in VARCHAR2,
  X_STORE_NAME 			in VARCHAR2,
  X_STORE_DESCRIPTION 		in VARCHAR2,
  X_LAST_UPDATE_DATE 		in DATE,
  X_LAST_UPDATED_BY 		in NUMBER,
  X_LAST_UPDATE_LOGIN 		in NUMBER
) is
begin
  update JTF_STORES_B set
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
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
  where STORE_ID = X_STORE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_STORES_TL set
    STORE_NAME = X_STORE_NAME,
    STORE_DESCRIPTION = X_STORE_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where STORE_ID = X_STORE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_STORE_ID in NUMBER
) is
begin
  delete from JTF_STORES_TL
  where STORE_ID = X_STORE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_STORES_B
  where STORE_ID = X_STORE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure TRANSLATE_ROW (
  X_STORE_ID            in      NUMBER,
  X_OWNER               in      VARCHAR2,
  X_STORE_NAME          in      VARCHAR2,
  X_STORE_DESCRIPTION   in      VARCHAR2 ) is

begin

update jtf_stores_tl
set language = USERENV('LANG'),
    source_lang = USERENV('LANG'),
    store_name = X_STORE_NAME,
    store_description = X_STORE_DESCRIPTION,
    last_updated_by = decode(X_OWNER,'SEED',1,0),
    last_update_date = sysdate,
    last_update_login=0
Where userenv('LANG') in (language,source_lang)
and store_id = X_STORE_ID;

end TRANSLATE_ROW;

procedure LOAD_ROW (
   X_STORE_ID               in      NUMBER,
   X_SECURITY_GROUP_ID	    in	    NUMBER,
   X_OWNER                  in      VARCHAR2,
   X_OBJECT_VERSION_NUMBER  in      VARCHAR2,
   X_ATTRIBUTE_CATEGORY     in      VARCHAR2,
   X_ATTRIBUTE1             in      VARCHAR2,
   X_ATTRIBUTE2             in      VARCHAR2,
   X_ATTRIBUTE3             in      VARCHAR2,
   X_ATTRIBUTE4             in      VARCHAR2,
   X_ATTRIBUTE5             in      VARCHAR2,
   X_ATTRIBUTE6             in      VARCHAR2,
   X_ATTRIBUTE7             in      VARCHAR2,
   X_ATTRIBUTE8             in      VARCHAR2,
   X_ATTRIBUTE9             in      VARCHAR2,
   X_ATTRIBUTE10            in      VARCHAR2,
   X_ATTRIBUTE11            in      VARCHAR2,
   X_ATTRIBUTE12            in      VARCHAR2,
   X_ATTRIBUTE13            in      VARCHAR2,
   X_ATTRIBUTE14            in      VARCHAR2,
   X_ATTRIBUTE15            in      VARCHAR2,
   X_STORE_NAME             in      VARCHAR2,
   X_STORE_DESCRIPTION      in      VARCHAR2) is

    Owner_id  NUMBER := 0;
    Row_id    VARCHAR2(64);
Begin

    If X_OWNER = 'SEED' Then
	Owner_id := 1;
    End If;

  UPDATE_ROW (
  X_STORE_ID   => X_STORE_ID,
  X_SECURITY_GROUP_ID   => X_SECURITY_GROUP_ID,
  X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
  X_ATTRIBUTE_CATEGORY    => X_ATTRIBUTE_CATEGORY,
  X_ATTRIBUTE1    => X_ATTRIBUTE1,
  X_ATTRIBUTE2    => X_ATTRIBUTE2,
  X_ATTRIBUTE3    => X_ATTRIBUTE3,
  X_ATTRIBUTE4    => X_ATTRIBUTE4,
  X_ATTRIBUTE5    => X_ATTRIBUTE5,
  X_ATTRIBUTE6    => X_ATTRIBUTE6,
  X_ATTRIBUTE7    => X_ATTRIBUTE7,
  X_ATTRIBUTE8    => X_ATTRIBUTE8,
  X_ATTRIBUTE9    => X_ATTRIBUTE9,
  X_ATTRIBUTE10   => X_ATTRIBUTE10,
  X_ATTRIBUTE11   => X_ATTRIBUTE11,
  X_ATTRIBUTE12   => X_ATTRIBUTE12,
  X_ATTRIBUTE13   => X_ATTRIBUTE13,
  X_ATTRIBUTE14   => X_ATTRIBUTE14,
  X_ATTRIBUTE15   => X_ATTRIBUTE15,
  X_STORE_NAME    => X_STORE_NAME,
  X_STORE_DESCRIPTION  => X_STORE_DESCRIPTION,
  X_LAST_UPDATE_DATE  => SYSDATE,
  X_LAST_UPDATED_BY   => owner_id,
  X_LAST_UPDATE_LOGIN => 0);

Exception
    When NO_DATA_FOUND Then

            INSERT_ROW (
		X_ROWID     => Row_id,
 		X_STORE_ID  => X_STORE_ID,
 		X_SECURITY_GROUP_ID   => X_SECURITY_GROUP_ID,
 		X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
 		X_ATTRIBUTE_CATEGORY    => X_ATTRIBUTE_CATEGORY,
 		X_ATTRIBUTE1    => X_ATTRIBUTE1,
 		X_ATTRIBUTE2    => X_ATTRIBUTE2,
 		X_ATTRIBUTE3    => X_ATTRIBUTE3,
 		X_ATTRIBUTE4    => X_ATTRIBUTE4,
 		X_ATTRIBUTE5    => X_ATTRIBUTE5,
 		X_ATTRIBUTE6    => X_ATTRIBUTE6,
 		X_ATTRIBUTE7    => X_ATTRIBUTE7,
 		X_ATTRIBUTE8    => X_ATTRIBUTE8,
 		X_ATTRIBUTE9    => X_ATTRIBUTE9,
 		X_ATTRIBUTE10   => X_ATTRIBUTE10,
 		X_ATTRIBUTE11   => X_ATTRIBUTE11,
 		X_ATTRIBUTE12   => X_ATTRIBUTE12,
 		X_ATTRIBUTE13   => X_ATTRIBUTE13,
 		X_ATTRIBUTE14   => X_ATTRIBUTE14,
 		X_ATTRIBUTE15   => X_ATTRIBUTE15,
 		X_STORE_NAME    => X_STORE_NAME,
 		X_STORE_DESCRIPTION  => X_STORE_DESCRIPTION,
		X_CREATION_DATE => SYSDATE,
		X_CREATED_BY => Owner_id,
		X_LAST_UPDATE_DATE  => SYSDATE,
		X_LAST_UPDATED_BY => Owner_id,
		X_LAST_UPDATE_LOGIN => 0 );

End LOAD_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_STORES_TL T
  where not exists
    (select NULL
    from JTF_STORES_B B
    where B.STORE_ID = T.STORE_ID
    );

  update JTF_STORES_TL T set (
      STORE_NAME,
      STORE_DESCRIPTION
    ) = (select
      B.STORE_NAME,
      B.STORE_DESCRIPTION
    from JTF_STORES_TL B
    where B.STORE_ID = T.STORE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STORE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.STORE_ID,
      SUBT.LANGUAGE
    from JTF_STORES_TL SUBB, JTF_STORES_TL SUBT
    where SUBB.STORE_ID = SUBT.STORE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.STORE_NAME <> SUBT.STORE_NAME
      or (SUBB.STORE_NAME is null and SUBT.STORE_NAME is not null)
      or (SUBB.STORE_NAME is not null and SUBT.STORE_NAME is null)
      or SUBB.STORE_DESCRIPTION <> SUBT.STORE_DESCRIPTION
      or (SUBB.STORE_DESCRIPTION is null and SUBT.STORE_DESCRIPTION is not null)
      or (SUBB.STORE_DESCRIPTION is not null and SUBT.STORE_DESCRIPTION is null)
  ));

  insert into JTF_STORES_TL (
    SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    STORE_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    STORE_NAME,
    STORE_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.SECURITY_GROUP_ID,
    B.OBJECT_VERSION_NUMBER,
    B.STORE_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.STORE_NAME,
    B.STORE_DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_STORES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_STORES_TL T
    where T.STORE_ID = B.STORE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end JTF_STORE_GRP;

/
