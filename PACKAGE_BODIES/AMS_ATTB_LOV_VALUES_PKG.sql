--------------------------------------------------------
--  DDL for Package Body AMS_ATTB_LOV_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ATTB_LOV_VALUES_PKG" as
/* $Header: amstatvb.pls 120.1 2005/06/27 05:39:35 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_ATTB_LOV_VALUE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_ATTB_LOV_ID in NUMBER,
  X_VALUE_CODE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_VALUE_MEANING in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE
) is
  cursor C is select ROWID from AMS_ATTB_LOV_VALUES_B
    where ATTB_LOV_VALUE_ID = X_ATTB_LOV_VALUE_ID
    ;
begin
  insert into AMS_ATTB_LOV_VALUES_B (
    ATTB_LOV_VALUE_ID,
    OBJECT_VERSION_NUMBER,
    REQUEST_ID,
    VIEW_APPLICATION_ID,
    ATTB_LOV_ID,
    VALUE_CODE,
    SECURITY_GROUP_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE
  ) values (
    X_ATTB_LOV_VALUE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_REQUEST_ID,
    X_VIEW_APPLICATION_ID,
    X_ATTB_LOV_ID,
    X_VALUE_CODE,
    X_SECURITY_GROUP_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE
  );

  insert into AMS_ATTB_LOV_VALUES_TL (
    ATTB_LOV_VALUE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    -- SOURCE_LANG,
    VALUE_MEANING,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_ATTB_LOV_VALUE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    -- X_SOURCE_LANG,
    X_VALUE_MEANING,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_ATTB_LOV_VALUES_TL T
    where T.ATTB_LOV_VALUE_ID = X_ATTB_LOV_VALUE_ID
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
  X_ATTB_LOV_VALUE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_ATTB_LOV_ID in NUMBER,
  X_VALUE_CODE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_VALUE_MEANING in VARCHAR2,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      REQUEST_ID,
      VIEW_APPLICATION_ID,
      ATTB_LOV_ID,
      VALUE_CODE,
      SECURITY_GROUP_ID
    from AMS_ATTB_LOV_VALUES_B
    where ATTB_LOV_VALUE_ID = X_ATTB_LOV_VALUE_ID
    for update of ATTB_LOV_VALUE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      VALUE_MEANING,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMS_ATTB_LOV_VALUES_TL
    where ATTB_LOV_VALUE_ID = X_ATTB_LOV_VALUE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ATTB_LOV_VALUE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
      AND ((recinfo.VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID)
           OR ((recinfo.VIEW_APPLICATION_ID is null) AND (X_VIEW_APPLICATION_ID is null)))
      AND (recinfo.ATTB_LOV_ID = X_ATTB_LOV_ID)
      AND (recinfo.VALUE_CODE = X_VALUE_CODE)
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.VALUE_MEANING = X_VALUE_MEANING)
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
  X_ATTB_LOV_VALUE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_ATTB_LOV_ID in NUMBER,
  X_VALUE_CODE in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_VALUE_MEANING in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE
) is
begin
  update AMS_ATTB_LOV_VALUES_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    REQUEST_ID = X_REQUEST_ID,
    VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID,
    ATTB_LOV_ID = X_ATTB_LOV_ID,
    VALUE_CODE = X_VALUE_CODE,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ATTB_LOV_VALUE_ID = X_ATTB_LOV_VALUE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_ATTB_LOV_VALUES_TL set
    VALUE_MEANING = X_VALUE_MEANING,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ATTB_LOV_VALUE_ID = X_ATTB_LOV_VALUE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ATTB_LOV_VALUE_ID in NUMBER
) is
begin
  delete from AMS_ATTB_LOV_VALUES_TL
  where ATTB_LOV_VALUE_ID = X_ATTB_LOV_VALUE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_ATTB_LOV_VALUES_B
  where ATTB_LOV_VALUE_ID = X_ATTB_LOV_VALUE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_ATTB_LOV_VALUES_TL T
  where not exists
    (select NULL
    from AMS_ATTB_LOV_VALUES_B B
    where B.ATTB_LOV_VALUE_ID = T.ATTB_LOV_VALUE_ID
    );

  update AMS_ATTB_LOV_VALUES_TL T set (
      VALUE_MEANING
    ) = (select
      B.VALUE_MEANING
    from AMS_ATTB_LOV_VALUES_TL B
    where B.ATTB_LOV_VALUE_ID = T.ATTB_LOV_VALUE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ATTB_LOV_VALUE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ATTB_LOV_VALUE_ID,
      SUBT.LANGUAGE
    from AMS_ATTB_LOV_VALUES_TL SUBB, AMS_ATTB_LOV_VALUES_TL SUBT
    where SUBB.ATTB_LOV_VALUE_ID = SUBT.ATTB_LOV_VALUE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.VALUE_MEANING <> SUBT.VALUE_MEANING
  ));

  insert into AMS_ATTB_LOV_VALUES_TL (
    ATTB_LOV_VALUE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    -- SOURCE_LANG,
    VALUE_MEANING,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.ATTB_LOV_VALUE_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    -- B.SOURCE_LANG,
    B.VALUE_MEANING,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_ATTB_LOV_VALUES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_ATTB_LOV_VALUES_TL T
    where T.ATTB_LOV_VALUE_ID = B.ATTB_LOV_VALUE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
procedure TRANSLATE_ROW(
  X_ATTB_LOV_VALUE_ID in NUMBER,
  X_VALUE_MEANING in VARCHAR2,
  x_owner   in VARCHAR2,
  x_custom_mode in VARCHAR2

 )  is

 cursor c_last_updated_by is
        select last_updated_by
        from AMS_ATTB_LOV_VALUES_TL
        where ATTB_LOV_VALUE_ID = X_ATTB_LOV_VALUE_ID
        and  USERENV('LANG') = LANGUAGE;

        l_luby number; --last updated by

begin

 open c_last_updated_by;
       fetch c_last_updated_by into l_luby;
       close c_last_updated_by;

if (l_luby IN (0, 1, 2) or NVL(x_custom_mode, 'PRESERVE')='FORCE')
then

    update AMS_ATTB_LOV_VALUES_TL set
       VALUE_MEANING= nvl(X_VALUE_MEANING, VALUE_MEANING),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1,  'ORACLE', 2, 'SYSADMIN', 0, -1),
       last_update_login = 0
    where  ATTB_LOV_VALUE_ID = X_ATTB_LOV_VALUE_ID
    and      userenv('LANG') in (language, source_lang);
end if;
end TRANSLATE_ROW;

PROCEDURE LOAD_ROW (
  X_ATTB_LOV_VALUE_ID in NUMBER,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_ATTB_LOV_ID in NUMBER,
  X_VALUE_CODE in VARCHAR2,
  X_VALUE_MEANING in VARCHAR2,
  X_OWNER in VARCHAR2,
  x_custom_mode in VARCHAR2

)
IS
   l_user_id   number := 0;
   l_obj_verno  number;
   l_dummy_char  varchar2(1);
   l_row_id    varchar2(100);
   l_ATTB_LOV_VALUE_ID   number;
   l_db_luby_id   number;

   CURSOR  c_obj_verno IS
     SELECT object_version_number, last_updated_by
     FROM   AMS_ATTB_LOV_VALUES_B
     WHERE  ATTB_LOV_VALUE_ID =  X_ATTB_LOV_VALUE_ID;

   CURSOR c_chk_exists is
     SELECT 'x'
     FROM   AMS_ATTB_LOV_VALUES_B
     WHERE  ATTB_LOV_VALUE_ID = X_ATTB_LOV_VALUE_ID;

   CURSOR c_get_id is
      SELECT AMS_ATTB_LOV_VALUES_B_S.NEXTVAL
      FROM DUAL;
BEGIN
   if X_OWNER = 'SEED' then
      l_user_id := 1;
   elsif X_OWNER = 'ORACLE' then
      l_user_id := 2;
   elsif X_OWNER = 'SYSADMIN' then
      l_user_id := 0;

   end if;

   OPEN c_chk_exists;
   FETCH c_chk_exists INTO l_dummy_char;
   IF c_chk_exists%notfound THEN
      CLOSE c_chk_exists;

      IF X_ATTB_LOV_VALUE_ID IS NULL THEN
         OPEN c_get_id;
         FETCH c_get_id INTO l_ATTB_LOV_VALUE_ID;
         CLOSE c_get_id;
      ELSE
         l_ATTB_LOV_VALUE_ID := X_ATTB_LOV_VALUE_ID;
      END IF;

      l_obj_verno := 1;

      AMS_ATTB_LOV_VALUES_PKG.Insert_Row (
         X_ROWID                    => l_row_id,
         X_ATTB_LOV_VALUE_ID        => l_ATTB_LOV_VALUE_ID,
         X_OBJECT_VERSION_NUMBER    => l_obj_verno,
	 X_REQUEST_ID               => 0,
         X_VIEW_APPLICATION_ID      => X_VIEW_APPLICATION_ID,
	 X_ATTB_LOV_ID              => X_ATTB_LOV_ID,
         X_VALUE_CODE               => X_VALUE_CODE,
  	 X_SECURITY_GROUP_ID        => 0,
         X_VALUE_MEANING            => X_VALUE_MEANING,
         X_creation_date            => SYSDATE,
         X_created_by               => l_user_id,
         X_last_update_date         => SYSDATE,
         X_last_updated_by          => l_user_id,
         X_last_update_login        => 0,
	 X_PROGRAM_ID               => 0,
         X_PROGRAM_APPLICATION_ID   => 0,
         X_PROGRAM_UPDATE_DATE      => SYSDATE
      );
   ELSE
      CLOSE c_chk_exists;
      OPEN c_obj_verno;
      FETCH c_obj_verno INTO l_obj_verno, l_db_luby_id;
      CLOSE c_obj_verno;


   if (l_db_luby_id IN (0, 1, 2) or NVL(x_custom_mode, 'PRESERVE')='FORCE')
         then

      AMS_ATTB_LOV_VALUES_PKG.Update_Row (
         X_ATTB_LOV_VALUE_ID        => x_ATTB_LOV_VALUE_ID,
         X_OBJECT_VERSION_NUMBER    => l_obj_verno,
         X_REQUEST_ID               => 0,
         X_VIEW_APPLICATION_ID      => X_VIEW_APPLICATION_ID,
         X_ATTB_LOV_ID              => X_ATTB_LOV_ID,
         X_VALUE_CODE               => X_VALUE_CODE,
         X_VALUE_MEANING              => X_VALUE_MEANING,
 	 X_SECURITY_GROUP_ID        => 0,
         X_last_update_date         => SYSDATE,
         X_last_updated_by          => l_user_id,
         X_last_update_login        => 0,
	 X_PROGRAM_ID               => 0,
         X_PROGRAM_APPLICATION_ID   => 0,
         X_PROGRAM_UPDATE_DATE      => SYSDATE
      );

    end if;
   END IF;
END LOAD_ROW;



end AMS_ATTB_LOV_VALUES_PKG;

/
