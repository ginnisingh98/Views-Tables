--------------------------------------------------------
--  DDL for Package Body AMS_QUERY_ALIAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_QUERY_ALIAS_PKG" as
/* $Header: amstqalb.pls 120.0 2005/06/01 23:39:11 appldev noship $ */
procedure INSERT_ROW (
  X_QUERY_ALIAS_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_OBJECT_NAME in VARCHAR2,
  X_ALIAS_SEQ in NUMBER,
  X_PARENT_QUERY_ALIAS_ID in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into AMS_QUERY_ALIAS (
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    REQUEST_ID,
    OBJECT_NAME,
    ALIAS_SEQ,
    PARENT_QUERY_ALIAS_ID,
    QUERY_ALIAS_ID,
    TEMPLATE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY
  ) values(
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER,
    X_REQUEST_ID,
    X_OBJECT_NAME,
    X_ALIAS_SEQ,
    X_PARENT_QUERY_ALIAS_ID,
    X_QUERY_ALIAS_ID,
    X_TEMPLATE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY);

end INSERT_ROW;

procedure LOCK_ROW (
  X_QUERY_ALIAS_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_OBJECT_NAME in VARCHAR2,
  X_ALIAS_SEQ in NUMBER,
  X_PARENT_QUERY_ALIAS_ID in NUMBER,
  X_TEMPLATE_ID in NUMBER
) is
  cursor c1 is select
      QUERY_ALIAS_ID,
      OBJECT_VERSION_NUMBER,
      OBJECT_NAME,
      ALIAS_SEQ,
      PARENT_QUERY_ALIAS_ID,
      TEMPLATE_ID
    from AMS_QUERY_ALIAS
    where QUERY_ALIAS_ID = X_QUERY_ALIAS_ID
    for update of QUERY_ALIAS_ID nowait;
begin
  for Recinfo in c1 loop
      if (
               ((Recinfo.QUERY_ALIAS_ID = X_QUERY_ALIAS_ID)
             OR ((Recinfo.QUERY_ALIAS_ID is null) AND (X_QUERY_ALIAS_ID is null)))

          AND ((Recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
               OR ((Recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
          AND ((Recinfo.OBJECT_NAME = X_OBJECT_NAME)
               OR ((Recinfo.OBJECT_NAME is null) AND (X_OBJECT_NAME is null)))
          AND (Recinfo.ALIAS_SEQ = X_ALIAS_SEQ)
          AND ((Recinfo.PARENT_QUERY_ALIAS_ID = X_PARENT_QUERY_ALIAS_ID)
               OR ((Recinfo.PARENT_QUERY_ALIAS_ID is null) AND (X_PARENT_QUERY_ALIAS_ID is null)))
          AND (Recinfo.TEMPLATE_ID = X_TEMPLATE_ID)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_QUERY_ALIAS_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_OBJECT_NAME in VARCHAR2,
  X_ALIAS_SEQ in NUMBER,
  X_PARENT_QUERY_ALIAS_ID in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_QUERY_ALIAS set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    REQUEST_ID = X_REQUEST_ID,
    OBJECT_NAME = X_OBJECT_NAME,
    ALIAS_SEQ = X_ALIAS_SEQ,
    PARENT_QUERY_ALIAS_ID = X_PARENT_QUERY_ALIAS_ID,
    TEMPLATE_ID = X_TEMPLATE_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where QUERY_ALIAS_ID = X_QUERY_ALIAS_ID
  and object_version_number = x_object_version_number;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_QUERY_ALIAS_ID in NUMBER
) is
begin
  delete from AMS_QUERY_ALIAS
  where QUERY_ALIAS_ID = X_QUERY_ALIAS_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

PROCEDURE load_row (
  X_QUERY_ALIAS_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_OBJECT_NAME in VARCHAR2,
  X_ALIAS_SEQ in NUMBER,
  X_PARENT_QUERY_ALIAS_ID in NUMBER,
  X_TEMPLATE_ID in NUMBER,
  x_owner IN VARCHAR2,
  x_custom_mode IN VARCHAR2

) is
 l_user_id   number := 0;
   l_obj_verno  number;
   l_dummy_char  varchar2(1);
   l_row_id    varchar2(100);
   l_QUERY_ALIAS_ID   number;
   l_db_luby_id   number;

   CURSOR  c_obj_verno IS
     SELECT object_version_number, last_updated_by
     FROM   AMS_QUERY_ALIAS
     WHERE  QUERY_ALIAS_ID =  x_QUERY_ALIAS_ID;

   CURSOR c_chk_exists is
     SELECT 'x'
     FROM   AMS_QUERY_ALIAS
     WHERE  QUERY_ALIAS_ID = x_QUERY_ALIAS_ID;

   CURSOR c_get_id is
      SELECT AMS_QUERY_ALIAS_s.NEXTVAL
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

      IF x_QUERY_ALIAS_ID IS NULL THEN
         OPEN c_get_id;
         FETCH c_get_id INTO l_QUERY_ALIAS_ID;
         CLOSE c_get_id;
      ELSE
         l_QUERY_ALIAS_ID := x_QUERY_ALIAS_ID;
      END IF;
      l_obj_verno := 1;

      AMS_QUERY_ALIAS_PKG.insert_row (
         x_QUERY_ALIAS_ID         => l_QUERY_ALIAS_ID,
         X_OBJECT_NAME                   => X_OBJECT_NAME,
         x_last_update_date            => SYSDATE,
         x_last_updated_by             => l_user_id,
         x_creation_date               => SYSDATE,
         x_created_by                  => l_user_id,
         x_last_update_login           => 0,
         x_object_version_number       => l_obj_verno,
         X_ALIAS_SEQ                    => X_ALIAS_SEQ,
         X_PARENT_QUERY_ALIAS_ID        => X_PARENT_QUERY_ALIAS_ID,
         X_TEMPLATE_ID                  => X_TEMPLATE_ID,
         X_REQUEST_ID                  => 0
      );


   ELSE
      CLOSE c_chk_exists;
      OPEN c_obj_verno;
      FETCH c_obj_verno INTO l_obj_verno, l_db_luby_id;
      CLOSE c_obj_verno;


     if (l_db_luby_id IN (0, 1, 2) or NVL(x_custom_mode, 'PRESERVE')='FORCE')
         then

      AMS_QUERY_ALIAS_PKG.update_row (
         x_QUERY_ALIAS_ID         => x_QUERY_ALIAS_ID,
         X_OBJECT_NAME                   => X_OBJECT_NAME,
         x_last_update_date            => SYSDATE,
         x_last_updated_by             => l_user_id,
         x_last_update_login           => 0,
         x_object_version_number       => l_obj_verno,
         X_ALIAS_SEQ                    => X_ALIAS_SEQ,
         X_PARENT_QUERY_ALIAS_ID        => X_PARENT_QUERY_ALIAS_ID,
         X_TEMPLATE_ID                  => X_TEMPLATE_ID,
         X_REQUEST_ID                  => 0
      );

     end if;

   END IF;
END load_row;



end AMS_QUERY_ALIAS_PKG;

/
