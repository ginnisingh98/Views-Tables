--------------------------------------------------------
--  DDL for Package Body AMS_QUERY_COND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_QUERY_COND_PKG" as
/* $Header: amstqcob.pls 120.0 2005/05/31 20:24:24 appldev noship $ */
procedure INSERT_ROW (
  X_QUERY_CONDITION_ID in NUMBER,
  X_PARAMETER_KEY in VARCHAR2,
  X_TEMPLATE_ID in NUMBER,
  X_JOIN_CONDITION in VARCHAR2,
  X_OPERAND_DATA_TYPE in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_CONDITION_IN_USE_FLAG in VARCHAR2,
  X_LEFT_OPERAND_TYPE in VARCHAR2,
  X_VALUE1_TYPE in VARCHAR2,
  X_VALUE2_TYPE in VARCHAR2,
  X_DISPLAY_COL_NUMBER in NUMBER,
  X_MAX_TOKEN_COUNT in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_COND_KEYWORD in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  insert into AMS_QUERY_CONDITION (
    PARAMETER_KEY,
    QUERY_CONDITION_ID,
    TEMPLATE_ID,
    JOIN_CONDITION,
    OPERAND_DATA_TYPE,
    MANDATORY_FLAG,
    DEFAULT_FLAG,
    CONDITION_IN_USE_FLAG,
    LEFT_OPERAND_TYPE,
    VALUE1_TYPE,
    VALUE2_TYPE,
    DISPLAY_COL_NUMBER,
    MAX_TOKEN_COUNT,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    REQUEST_ID
  ) values(
    X_PARAMETER_KEY,
    X_QUERY_CONDITION_ID,
    X_TEMPLATE_ID,
    X_JOIN_CONDITION,
    X_OPERAND_DATA_TYPE,
    X_MANDATORY_FLAG,
    X_DEFAULT_FLAG,
    X_CONDITION_IN_USE_FLAG,
    X_LEFT_OPERAND_TYPE,
    X_VALUE1_TYPE,
    X_VALUE2_TYPE,
    X_DISPLAY_COL_NUMBER,
    X_MAX_TOKEN_COUNT,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER,
    X_REQUEST_ID);

end INSERT_ROW;

procedure LOCK_ROW (
  X_QUERY_CONDITION_ID in NUMBER,
  X_PARAMETER_KEY in VARCHAR2,
  X_TEMPLATE_ID in NUMBER,
  X_JOIN_CONDITION in VARCHAR2,
  X_OPERAND_DATA_TYPE in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_CONDITION_IN_USE_FLAG in VARCHAR2,
  X_LEFT_OPERAND_TYPE in VARCHAR2,
  X_VALUE1_TYPE in VARCHAR2,
  X_VALUE2_TYPE in VARCHAR2,
  X_DISPLAY_COL_NUMBER in NUMBER,
  X_MAX_TOKEN_COUNT in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_COND_KEYWORD in VARCHAR2
) is
  cursor c1 is select
      PARAMETER_KEY,
      TEMPLATE_ID,
      JOIN_CONDITION,
      OPERAND_DATA_TYPE,
      MANDATORY_FLAG,
      DEFAULT_FLAG,
      CONDITION_IN_USE_FLAG,
      LEFT_OPERAND_TYPE,
      VALUE1_TYPE,
      VALUE2_TYPE,
      DISPLAY_COL_NUMBER,
      MAX_TOKEN_COUNT,
      OBJECT_VERSION_NUMBER,
      COND_KEYWORD,
      QUERY_CONDITION_ID
    from AMS_QUERY_CONDITION
    where QUERY_CONDITION_ID = X_QUERY_CONDITION_ID
    for update of QUERY_CONDITION_ID nowait;
begin
  for Recinfo in c1 loop
      if (    (Recinfo.QUERY_CONDITION_ID = X_QUERY_CONDITION_ID)
          AND ((Recinfo.PARAMETER_KEY = X_PARAMETER_KEY)
               OR ((Recinfo.PARAMETER_KEY is null) AND (X_PARAMETER_KEY is null)))
          AND ((Recinfo.TEMPLATE_ID = X_TEMPLATE_ID)
               OR ((Recinfo.TEMPLATE_ID is null) AND (X_TEMPLATE_ID is null)))
          AND ((Recinfo.JOIN_CONDITION = X_JOIN_CONDITION)
               OR ((Recinfo.JOIN_CONDITION is null) AND (X_JOIN_CONDITION is null)))
          AND ((Recinfo.OPERAND_DATA_TYPE = X_OPERAND_DATA_TYPE)
               OR ((Recinfo.OPERAND_DATA_TYPE is null) AND (X_OPERAND_DATA_TYPE is null)))
          AND ((Recinfo.MANDATORY_FLAG = X_MANDATORY_FLAG)
               OR ((Recinfo.MANDATORY_FLAG is null) AND (X_MANDATORY_FLAG is null)))
          AND ((Recinfo.DEFAULT_FLAG = X_DEFAULT_FLAG)
               OR ((Recinfo.DEFAULT_FLAG is null) AND (X_DEFAULT_FLAG is null)))
          AND ((Recinfo.CONDITION_IN_USE_FLAG = X_CONDITION_IN_USE_FLAG)
               OR ((Recinfo.CONDITION_IN_USE_FLAG is null) AND (X_CONDITION_IN_USE_FLAG is null)))
          AND ((Recinfo.LEFT_OPERAND_TYPE = X_LEFT_OPERAND_TYPE)
               OR ((Recinfo.LEFT_OPERAND_TYPE is null) AND (X_LEFT_OPERAND_TYPE is null)))
          AND ((Recinfo.VALUE1_TYPE = X_VALUE1_TYPE)
               OR ((Recinfo.VALUE1_TYPE is null) AND (X_VALUE1_TYPE is null)))
          AND ((Recinfo.VALUE2_TYPE = X_VALUE2_TYPE)
               OR ((Recinfo.VALUE2_TYPE is null) AND (X_VALUE2_TYPE is null)))
          AND ((Recinfo.DISPLAY_COL_NUMBER = X_DISPLAY_COL_NUMBER)
               OR ((Recinfo.DISPLAY_COL_NUMBER is null) AND (X_DISPLAY_COL_NUMBER is null)))
          AND ((Recinfo.MAX_TOKEN_COUNT = X_MAX_TOKEN_COUNT)
               OR ((Recinfo.MAX_TOKEN_COUNT is null) AND (X_MAX_TOKEN_COUNT is null)))
          AND ((Recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
               OR ((Recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
          AND ((Recinfo.COND_KEYWORD = X_COND_KEYWORD)
               OR ((Recinfo.COND_KEYWORD is null) AND (X_COND_KEYWORD is null)))
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
  X_QUERY_CONDITION_ID in NUMBER,
  X_PARAMETER_KEY in VARCHAR2,
  X_TEMPLATE_ID in NUMBER,
  X_JOIN_CONDITION in VARCHAR2,
  X_OPERAND_DATA_TYPE in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_CONDITION_IN_USE_FLAG in VARCHAR2,
  X_LEFT_OPERAND_TYPE in VARCHAR2,
  X_VALUE1_TYPE in VARCHAR2,
  X_VALUE2_TYPE in VARCHAR2,
  X_DISPLAY_COL_NUMBER in NUMBER,
  X_MAX_TOKEN_COUNT in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_COND_KEYWORD in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_QUERY_CONDITION set
    PARAMETER_KEY = X_PARAMETER_KEY,
    TEMPLATE_ID = X_TEMPLATE_ID,
    JOIN_CONDITION = X_JOIN_CONDITION,
    OPERAND_DATA_TYPE = X_OPERAND_DATA_TYPE,
    MANDATORY_FLAG = X_MANDATORY_FLAG,
    DEFAULT_FLAG = X_DEFAULT_FLAG,
    CONDITION_IN_USE_FLAG = X_CONDITION_IN_USE_FLAG,
    LEFT_OPERAND_TYPE = X_LEFT_OPERAND_TYPE,
    VALUE1_TYPE = X_VALUE1_TYPE,
    VALUE2_TYPE = X_VALUE2_TYPE,
    DISPLAY_COL_NUMBER = X_DISPLAY_COL_NUMBER,
    MAX_TOKEN_COUNT = X_MAX_TOKEN_COUNT,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    REQUEST_ID = X_REQUEST_ID,
    COND_KEYWORD = X_COND_KEYWORD,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where QUERY_CONDITION_ID = X_QUERY_CONDITION_ID
  and object_version_number = X_OBJECT_VERSION_NUMBER;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_QUERY_CONDITION_ID in NUMBER
) is
begin
  delete from AMS_QUERY_CONDITION
  where QUERY_CONDITION_ID = X_QUERY_CONDITION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;


PROCEDURE load_row (
  X_QUERY_CONDITION_ID in NUMBER,
  X_PARAMETER_KEY in VARCHAR2,
  X_TEMPLATE_ID in NUMBER,
  X_JOIN_CONDITION in VARCHAR2,
  X_OPERAND_DATA_TYPE in VARCHAR2,
  X_MANDATORY_FLAG in VARCHAR2,
  X_DEFAULT_FLAG in VARCHAR2,
  X_CONDITION_IN_USE_FLAG in VARCHAR2,
  X_LEFT_OPERAND_TYPE in VARCHAR2,
  X_VALUE1_TYPE in VARCHAR2,
  X_VALUE2_TYPE in VARCHAR2,
  X_DISPLAY_COL_NUMBER in NUMBER,
  X_MAX_TOKEN_COUNT in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_COND_KEYWORD in VARCHAR2,
  x_owner IN VARCHAR2,
  x_custom_mode IN VARCHAR2
) is
 l_user_id   number := 0;
   l_obj_verno  number;
   l_dummy_char  varchar2(1);
   l_row_id    varchar2(100);
   l_QUERY_CONDITION_ID   number;
    l_db_luby_id   number;

   CURSOR  c_obj_verno IS
     SELECT object_version_number, last_updated_by
     FROM   AMS_QUERY_CONDITION
     WHERE  QUERY_CONDITION_ID =  x_QUERY_CONDITION_ID;

   CURSOR c_chk_exists is
     SELECT 'x'
     FROM   AMS_QUERY_CONDITION
     WHERE  QUERY_CONDITION_ID = x_QUERY_CONDITION_ID;

   CURSOR c_get_id is
      SELECT AMS_QUERY_CONDITION_s.NEXTVAL
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

      IF x_QUERY_CONDITION_ID IS NULL THEN
         OPEN c_get_id;
         FETCH c_get_id INTO l_QUERY_CONDITION_ID;
         CLOSE c_get_id;
      ELSE
         l_QUERY_CONDITION_ID := x_QUERY_CONDITION_ID;
      END IF;
      l_obj_verno := 1;

      AMS_QUERY_COND_PKG.insert_row (
         x_QUERY_CONDITION_ID   => l_QUERY_CONDITION_ID,
         x_last_update_date            => SYSDATE,
         x_last_updated_by             => l_user_id,
         x_creation_date               => SYSDATE,
         x_created_by                  => l_user_id,
         x_last_update_login           => 0,
         x_object_version_number       => l_obj_verno,
         X_TEMPLATE_ID                 => X_TEMPLATE_ID,
         X_PARAMETER_KEY               => X_PARAMETER_KEY,
         X_JOIN_CONDITION               => X_JOIN_CONDITION,
         X_OPERAND_DATA_TYPE            => X_OPERAND_DATA_TYPE,
	 X_MANDATORY_FLAG               => X_MANDATORY_FLAG,
	 X_DEFAULT_FLAG                 => X_DEFAULT_FLAG,
         X_CONDITION_IN_USE_FLAG        => X_CONDITION_IN_USE_FLAG,
         X_LEFT_OPERAND_TYPE            => X_LEFT_OPERAND_TYPE,
         X_VALUE1_TYPE                  => X_VALUE1_TYPE,
	 X_VALUE2_TYPE                   => X_VALUE2_TYPE,
	 X_DISPLAY_COL_NUMBER            => X_DISPLAY_COL_NUMBER,
         X_MAX_TOKEN_COUNT              => X_MAX_TOKEN_COUNT,
         X_COND_KEYWORD            => X_COND_KEYWORD,
         X_REQUEST_ID                 => 0
      );


   ELSE
      CLOSE c_chk_exists;
      OPEN c_obj_verno;
      FETCH c_obj_verno INTO l_obj_verno, l_db_luby_id;
      CLOSE c_obj_verno;


     if (l_db_luby_id IN (0, 1, 2) or NVL(x_custom_mode, 'PRESERVE')='FORCE')
         then

      AMS_QUERY_COND_PKG.update_row (
         x_QUERY_CONDITION_ID   => x_QUERY_CONDITION_ID,
         x_last_update_date            => SYSDATE,
         x_last_updated_by             => l_user_id,
         x_last_update_login           => 0,
         x_object_version_number       => l_obj_verno,
         X_TEMPLATE_ID                 => X_TEMPLATE_ID,
         X_PARAMETER_KEY               => X_PARAMETER_KEY,
         X_JOIN_CONDITION               => X_JOIN_CONDITION,
         X_OPERAND_DATA_TYPE            => X_OPERAND_DATA_TYPE,
	 X_MANDATORY_FLAG               => X_MANDATORY_FLAG,
	 X_DEFAULT_FLAG                 => X_DEFAULT_FLAG,
         X_CONDITION_IN_USE_FLAG        => X_CONDITION_IN_USE_FLAG,
         X_LEFT_OPERAND_TYPE            => X_LEFT_OPERAND_TYPE,
         X_VALUE1_TYPE                  => X_VALUE1_TYPE,
	 X_VALUE2_TYPE                   => X_VALUE2_TYPE,
	 X_DISPLAY_COL_NUMBER            => X_DISPLAY_COL_NUMBER,
         X_MAX_TOKEN_COUNT              => X_MAX_TOKEN_COUNT,
         X_COND_KEYWORD                 => X_COND_KEYWORD,
         X_REQUEST_ID                 => 0
      );

      end if;

   END IF;
END load_row;


end AMS_QUERY_COND_PKG;

/
