--------------------------------------------------------
--  DDL for Package Body AMS_QUERY_TMP_ASSOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_QUERY_TMP_ASSOC_PKG" as
/* $Header: amstqcab.pls 120.0 2005/05/31 14:49:29 appldev noship $ */
procedure INSERT_ROW (
  X_ASSOC_ID in NUMBER,
  X_TEMPLATE_INSTANCE_ID in NUMBER,
  X_QUERY_CONDITION_ID in NUMBER,
  X_CONDITION_SEQUENCE in NUMBER,
  X_RUNNING_TOTAL in NUMBER,
  X_DELTA in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into AMS_QUERY_TEMP_INST_COND_ASSOC (
    ASSOC_ID,
    TEMPLATE_INSTANCE_ID,
    QUERY_CONDITION_ID,
    CONDITION_SEQUENCE,
    RUNNING_TOTAL,
    DELTA,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    REQUEST_ID
  ) values
  (
    X_ASSOC_ID,
    X_TEMPLATE_INSTANCE_ID,
    X_QUERY_CONDITION_ID,
    X_CONDITION_SEQUENCE,
    X_RUNNING_TOTAL,
    X_DELTA,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER,
    X_REQUEST_ID);

end INSERT_ROW;

procedure LOCK_ROW (
  X_ASSOC_ID in NUMBER,
  X_TEMPLATE_INSTANCE_ID in NUMBER,
  X_QUERY_CONDITION_ID in NUMBER,
  X_CONDITION_SEQUENCE in NUMBER,
  X_RUNNING_TOTAL in NUMBER,
  X_DELTA in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER
) is
  cursor c1 is select
      TEMPLATE_INSTANCE_ID,
      QUERY_CONDITION_ID,
      CONDITION_SEQUENCE,
      RUNNING_TOTAL,
      DELTA,
      OBJECT_VERSION_NUMBER,
      ASSOC_ID
    from AMS_QUERY_TEMP_INST_COND_ASSOC
    where ASSOC_ID = X_ASSOC_ID
    for update of ASSOC_ID nowait;
begin
  for Recinfo in c1 loop
      if (    ((Recinfo.ASSOC_ID = X_ASSOC_ID)
               OR ((Recinfo.ASSOC_ID is null) AND (X_ASSOC_ID is null)))
          AND ((Recinfo.TEMPLATE_INSTANCE_ID = X_TEMPLATE_INSTANCE_ID)
               OR ((Recinfo.TEMPLATE_INSTANCE_ID is null) AND (X_TEMPLATE_INSTANCE_ID is null)))
          AND ((Recinfo.QUERY_CONDITION_ID = X_QUERY_CONDITION_ID)
               OR ((Recinfo.QUERY_CONDITION_ID is null) AND (X_QUERY_CONDITION_ID is null)))
          AND ((Recinfo.CONDITION_SEQUENCE = X_CONDITION_SEQUENCE)
               OR ((Recinfo.CONDITION_SEQUENCE is null) AND (X_CONDITION_SEQUENCE is null)))
          AND ((Recinfo.RUNNING_TOTAL = X_RUNNING_TOTAL)
               OR ((Recinfo.RUNNING_TOTAL is null) AND (X_RUNNING_TOTAL is null)))
          AND ((Recinfo.DELTA = X_DELTA)
               OR ((Recinfo.DELTA is null) AND (X_DELTA is null)))
          AND ((Recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
               OR ((Recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
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
  X_ASSOC_ID in NUMBER,
  X_TEMPLATE_INSTANCE_ID in NUMBER,
  X_QUERY_CONDITION_ID in NUMBER,
  X_CONDITION_SEQUENCE in NUMBER,
  X_RUNNING_TOTAL in NUMBER,
  X_DELTA in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_QUERY_TEMP_INST_COND_ASSOC set
    TEMPLATE_INSTANCE_ID = X_TEMPLATE_INSTANCE_ID,
    QUERY_CONDITION_ID = X_QUERY_CONDITION_ID,
    CONDITION_SEQUENCE = X_CONDITION_SEQUENCE,
    RUNNING_TOTAL = X_RUNNING_TOTAL,
    DELTA = X_DELTA,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    REQUEST_ID = X_REQUEST_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ASSOC_ID = X_ASSOC_ID
  and OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER;


  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ASSOC_ID in NUMBER
) is
begin
  delete from AMS_QUERY_TEMP_INST_COND_ASSOC
  where ASSOC_ID = X_ASSOC_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


PROCEDURE load_row (
  X_ASSOC_ID in NUMBER,
  X_TEMPLATE_INSTANCE_ID in NUMBER,
  X_QUERY_CONDITION_ID in NUMBER,
  X_CONDITION_SEQUENCE in NUMBER,
  X_RUNNING_TOTAL in NUMBER,
  X_DELTA in NUMBER,
  X_REQUEST_ID in NUMBER,
  x_owner IN VARCHAR2,
  x_custom_mode IN VARCHAR2

) is
 l_user_id   number := 0;
   l_obj_verno  number;
   l_dummy_char  varchar2(1);
   l_row_id    varchar2(100);
   l_ASSOC_ID   number;
  l_db_luby_id   number;

   CURSOR  c_obj_verno IS
     SELECT object_version_number, last_updated_by
     FROM   AMS_QUERY_TEMP_INST_COND_ASSOC
     WHERE  ASSOC_ID =  x_ASSOC_ID;

   CURSOR c_chk_exists is
     SELECT 'x'
     FROM   AMS_QUERY_TEMP_INST_COND_ASSOC
     WHERE  ASSOC_ID = x_ASSOC_ID;

   CURSOR c_get_id is
      SELECT AMS_QUERY_TEMP_INST_COND_ASC_S.NEXTVAL
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

      IF x_ASSOC_ID IS NULL THEN
         OPEN c_get_id;
         FETCH c_get_id INTO l_ASSOC_ID;
         CLOSE c_get_id;
      ELSE
         l_ASSOC_ID := x_ASSOC_ID;
      END IF;
      l_obj_verno := 1;

      AMS_QUERY_TMP_ASSOC_PKG.insert_row (
         x_ASSOC_ID   => l_ASSOC_ID,
         x_last_update_date            => SYSDATE,
         x_last_updated_by             => l_user_id,
         x_creation_date               => SYSDATE,
         x_created_by                  => l_user_id,
         x_last_update_login           => 0,
         x_object_version_number       => l_obj_verno,
         X_TEMPLATE_INSTANCE_ID        => X_TEMPLATE_INSTANCE_ID,
         X_QUERY_CONDITION_ID          => X_QUERY_CONDITION_ID,
	 X_CONDITION_SEQUENCE          => X_CONDITION_SEQUENCE,
         X_RUNNING_TOTAL               => X_RUNNING_TOTAL,
	 X_DELTA                       => X_DELTA,
         X_REQUEST_ID                 => 0
      );


   ELSE
      CLOSE c_chk_exists;
      OPEN c_obj_verno;
      FETCH c_obj_verno INTO l_obj_verno,  l_db_luby_id;
      CLOSE c_obj_verno;

   if (l_db_luby_id IN (0, 1, 2) or NVL(x_custom_mode, 'PRESERVE')='FORCE')
         then

      AMS_QUERY_TMP_ASSOC_PKG.update_row (
         x_ASSOC_ID   => x_ASSOC_ID,
         x_last_update_date            => SYSDATE,
         x_last_updated_by             => l_user_id,
         x_last_update_login           => 0,
         x_object_version_number       => l_obj_verno,
         X_TEMPLATE_INSTANCE_ID        => X_TEMPLATE_INSTANCE_ID,
         X_QUERY_CONDITION_ID          => X_QUERY_CONDITION_ID,
	 X_CONDITION_SEQUENCE          => X_CONDITION_SEQUENCE,
         X_RUNNING_TOTAL               => X_RUNNING_TOTAL,
	 X_DELTA                       => X_DELTA,
         X_REQUEST_ID                 => 0
      );

    end if;

   END IF;
END load_row;


end AMS_QUERY_TMP_ASSOC_PKG;

/
