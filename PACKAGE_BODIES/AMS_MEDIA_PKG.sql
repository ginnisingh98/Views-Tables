--------------------------------------------------------
--  DDL for Package Body AMS_MEDIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_MEDIA_PKG" as
/* $Header: amslmdab.pls 115.8 2004/01/30 01:38:34 asaha ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_MEDIA_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_MEDIA_TYPE_CODE in VARCHAR2,
  X_INBOUND_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
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
  X_DEDUPE_RULE_ID in VARCHAR2,
  X_MEDIA_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AMS_MEDIA_B
    where MEDIA_ID = X_MEDIA_ID
    ;
begin
  insert into AMS_MEDIA_B (
    MEDIA_ID,
    OBJECT_VERSION_NUMBER,
    MEDIA_TYPE_CODE,
    INBOUND_FLAG,
    ENABLED_FLAG,
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
    LAST_UPDATE_LOGIN,
    DEDUPE_RULE_ID
  ) values (
    X_MEDIA_ID,
    X_OBJECT_VERSION_NUMBER,
    X_MEDIA_TYPE_CODE,
    X_INBOUND_FLAG,
    X_ENABLED_FLAG,
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
    X_LAST_UPDATE_LOGIN,
    X_DEDUPE_RULE_ID
  );

  insert into AMS_MEDIA_TL (
    MEDIA_NAME,
    DESCRIPTION,
    MEDIA_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_MEDIA_NAME,
    X_DESCRIPTION,
    X_MEDIA_ID,
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
    from AMS_MEDIA_TL T
    where T.MEDIA_ID = X_MEDIA_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure UPDATE_ROW (
  X_MEDIA_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_MEDIA_TYPE_CODE in VARCHAR2,
  X_INBOUND_FLAG in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
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
  X_DEDUPE_RULE_ID in VARCHAR2,
  X_MEDIA_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_MEDIA_B set
    -- OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER ,
    MEDIA_TYPE_CODE = X_MEDIA_TYPE_CODE,
    INBOUND_FLAG = X_INBOUND_FLAG
    -- removed by soagrawa for bug# 2740393 on 08-jan-2003
    -- should not update the active flag
    -- ENABLED_FLAG = X_ENABLED_FLAG,
    -- ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    -- ATTRIBUTE1 = X_ATTRIBUTE1,
    -- ATTRIBUTE2 = X_ATTRIBUTE2,
    -- ATTRIBUTE3 = X_ATTRIBUTE3,
    -- ATTRIBUTE4 = X_ATTRIBUTE4,
    -- ATTRIBUTE5 = X_ATTRIBUTE5,
    -- ATTRIBUTE6 = X_ATTRIBUTE6,
    -- ATTRIBUTE7 = X_ATTRIBUTE7,
    -- ATTRIBUTE8 = X_ATTRIBUTE8,
    -- ATTRIBUTE9 = X_ATTRIBUTE9,
    -- ATTRIBUTE10 = X_ATTRIBUTE10,
    -- ATTRIBUTE11 = X_ATTRIBUTE11,
    -- ATTRIBUTE12 = X_ATTRIBUTE12,
    -- ATTRIBUTE13 = X_ATTRIBUTE13,
    -- ATTRIBUTE14 = X_ATTRIBUTE14,
    -- ATTRIBUTE15 = X_ATTRIBUTE15,
    -- LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    -- LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    -- LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    -- DEDUPE_RULE_ID = X_DEDUPE_RULE_ID
  where MEDIA_ID = X_MEDIA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  /* Following code is uncommented by asaha on 28-Jan-2004 to
     allow Customization to be overridden form _TL table at least
     in case last owner was seed data itself. The following comments
     are super-seeded.

     following code is modified by soagrawa on 13-Jan-2003
     The seeded activities can be updated for name and description
  */
  update AMS_MEDIA_TL set
    MEDIA_NAME = X_MEDIA_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where MEDIA_ID = X_MEDIA_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_MEDIA_ID in NUMBER
) is
begin
  delete from AMS_MEDIA_TL
  where MEDIA_ID = X_MEDIA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_MEDIA_B
  where MEDIA_ID = X_MEDIA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_MEDIA_TL T
  where not exists
    (select NULL
    from AMS_MEDIA_B B
    where B.MEDIA_ID = T.MEDIA_ID
    );

  update AMS_MEDIA_TL T set (
      MEDIA_NAME,
      DESCRIPTION
    ) = (select
      B.MEDIA_NAME,
      B.DESCRIPTION
    from AMS_MEDIA_TL B
    where B.MEDIA_ID = T.MEDIA_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.MEDIA_ID,
      T.LANGUAGE
  ) in (select
      SUBT.MEDIA_ID,
      SUBT.LANGUAGE
    from AMS_MEDIA_TL SUBB, AMS_MEDIA_TL SUBT
    where SUBB.MEDIA_ID = SUBT.MEDIA_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MEDIA_NAME <> SUBT.MEDIA_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_MEDIA_TL (
    MEDIA_NAME,
    DESCRIPTION,
    MEDIA_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.MEDIA_NAME,
    B.DESCRIPTION,
    B.MEDIA_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_MEDIA_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_MEDIA_TL T
    where T.MEDIA_ID = B.MEDIA_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure TRANSLATE_ROW(
       x_media_id    in NUMBER
     , x_media_name  in VARCHAR2
     , x_description    in VARCHAR2
     , x_owner   in VARCHAR2
 ) is
 begin
    update AMS_MEDIA_TL set
       media_name = nvl(x_media_name, media_name),
       description = nvl(x_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1, 0),
       last_update_login = 0
    where  media_id = x_media_id
    and      userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;

procedure  LOAD_ROW(
  X_MEDIA_ID   IN NUMBER,
  X_MEDIA_TYPE_CODE in VARCHAR2 DEFAULT NULL,
  X_INBOUND_FLAG in VARCHAR2 DEFAULT 'N',
  X_ENABLED_FLAG in VARCHAR2  DEFAULT 'Y',
  X_ATTRIBUTE_CATEGORY in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE1 in VARCHAR2  DEFAULT NULL ,
  X_ATTRIBUTE2 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE3 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE4 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE5 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE6 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE7 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE8 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE9 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE10 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE11 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE12 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE13 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE14 in VARCHAR2  DEFAULT NULL,
  X_ATTRIBUTE15 in VARCHAR2  DEFAULT NULL,
  X_DEDUPE_RULE_ID in VARCHAR2 DEFAULT NULL,
  X_MEDIA_NAME in VARCHAR2  DEFAULT NULL,
  X_DESCRIPTION in VARCHAR2  DEFAULT NULL ,
  X_Owner              VARCHAR2
) is

l_user_id   number := 0;
l_obj_verno  number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);
l_media_id   number;
l_db_luby_id NUMBER;

cursor  c_db_data_details is
  select last_updated_by, nvl(object_version_number,1)
  from    AMS_MEDIA_B
  where  media_id =  X_MEDIA_ID;

cursor c_chk_mda_exists is
  select 'x'
  from   AMS_MEDIA_B
  where  media_id = X_MEDIA_ID;

cursor c_get_mdaid is
   select AMS_MEDIA_B_S.nextval
   from dual;

BEGIN

  if X_OWNER = 'SEED' then
     l_user_id := 1;
 end if;

 open c_chk_mda_exists;
 fetch c_chk_mda_exists into l_dummy_char;
 if c_chk_mda_exists%notfound
 then
    close c_chk_mda_exists;
    if X_MEDIA_ID is null
    then
      open c_get_mdaid;
      fetch c_get_mdaid into l_media_id;
      close c_get_mdaid;
    else
       l_media_id := X_MEDIA_ID;
    end if;
    l_obj_verno := 1;
    AMS_MEDIA_PKG.INSERT_ROW(
    X_ROWID				=>   l_row_id,
    X_MEDIA_ID				 =>  l_media_id,
    X_OBJECT_VERSION_NUMBER  => l_obj_verno,
    X_MEDIA_TYPE_CODE		=>  X_MEDIA_TYPE_CODE,
    X_INBOUND_FLAG			 => X_INBOUND_FLAG,
    X_ENABLED_FLAG			=>  X_ENABLED_FLAG,
    X_ATTRIBUTE_CATEGORY	=>  X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1			=>  X_ATTRIBUTE1,
    X_ATTRIBUTE2			=>  X_ATTRIBUTE2,
    X_ATTRIBUTE3			=>  X_ATTRIBUTE3,
    X_ATTRIBUTE4			=>  X_ATTRIBUTE4,
    X_ATTRIBUTE5			=>  X_ATTRIBUTE5,
    X_ATTRIBUTE6			=>  X_ATTRIBUTE6,
    X_ATTRIBUTE7			=>  X_ATTRIBUTE7,
    X_ATTRIBUTE8			=>  X_ATTRIBUTE8,
    X_ATTRIBUTE9			=>  X_ATTRIBUTE9,
    X_ATTRIBUTE10			=>  X_ATTRIBUTE10,
    X_ATTRIBUTE11			=>  X_ATTRIBUTE11,
    X_ATTRIBUTE12			=>  X_ATTRIBUTE12,
    X_ATTRIBUTE13			=>  X_ATTRIBUTE13,
    X_ATTRIBUTE14			=>  X_ATTRIBUTE14,
    X_ATTRIBUTE15			=>  X_ATTRIBUTE15,
    X_DEDUPE_RULE_ID    =>  X_DEDUPE_RULE_ID,
    X_MEDIA_NAME			=>  X_MEDIA_NAME,
    X_DESCRIPTION			=>  X_DESCRIPTION,
    X_CREATION_DATE		=>  SYSDATE,
    X_CREATED_BY			=>  l_user_id,
    X_LAST_UPDATE_DATE	=>  SYSDATE,
    X_LAST_UPDATED_BY		=>  l_user_id,
    X_LAST_UPDATE_LOGIN	=>  0
  );
else
   close c_chk_mda_exists;
   open c_db_data_details;
   fetch c_db_data_details into l_db_luby_id,l_obj_verno;
   close c_db_data_details;

   if ( l_db_luby_id IN (1, 2, 0)) then
     AMS_MEDIA_PKG.UPDATE_ROW(
     X_MEDIA_ID				 =>  X_MEDIA_ID,
     X_OBJECT_VERSION_NUMBER  => l_obj_verno + 1,
     X_MEDIA_TYPE_CODE		=>  X_MEDIA_TYPE_CODE,
     X_INBOUND_FLAG			 => X_INBOUND_FLAG,
     X_ENABLED_FLAG			=>  X_ENABLED_FLAG,
     X_ATTRIBUTE_CATEGORY	=>  X_ATTRIBUTE_CATEGORY,
     X_ATTRIBUTE1			=>  X_ATTRIBUTE1,
     X_ATTRIBUTE2			=>  X_ATTRIBUTE2,
     X_ATTRIBUTE3			=>  X_ATTRIBUTE3,
     X_ATTRIBUTE4			=>  X_ATTRIBUTE4,
     X_ATTRIBUTE5			=>  X_ATTRIBUTE5,
     X_ATTRIBUTE6			=>  X_ATTRIBUTE6,
     X_ATTRIBUTE7			=>  X_ATTRIBUTE7,
     X_ATTRIBUTE8			=>  X_ATTRIBUTE8,
     X_ATTRIBUTE9			=>  X_ATTRIBUTE9,
     X_ATTRIBUTE10			=>  X_ATTRIBUTE10,
     X_ATTRIBUTE11			=>  X_ATTRIBUTE11,
     X_ATTRIBUTE12			=>  X_ATTRIBUTE12,
     X_ATTRIBUTE13			=>  X_ATTRIBUTE13,
     X_ATTRIBUTE14			=>  X_ATTRIBUTE14,
     X_ATTRIBUTE15			=>  X_ATTRIBUTE15,
     X_DEDUPE_RULE_ID    =>  X_DEDUPE_RULE_ID,
     X_MEDIA_NAME			=>  X_MEDIA_NAME,
     X_DESCRIPTION			=>  X_DESCRIPTION,
     X_LAST_UPDATE_DATE	=>  SYSDATE,
     X_LAST_UPDATED_BY		=>  l_user_id,
     X_LAST_UPDATE_LOGIN	=>  0
   );
  end if;
end if;
END LOAD_ROW;

end AMS_MEDIA_PKG;

/
