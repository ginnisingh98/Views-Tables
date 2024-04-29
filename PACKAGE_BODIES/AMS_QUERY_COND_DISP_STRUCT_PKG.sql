--------------------------------------------------------
--  DDL for Package Body AMS_QUERY_COND_DISP_STRUCT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_QUERY_COND_DISP_STRUCT_PKG" as
/* $Header: amstcdsb.pls 120.1 2005/06/27 05:39:52 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_QUERY_COND_DISP_STRUCT_ID in NUMBER,
  X_QUERY_TEMPLATE_ID in NUMBER,
  X_QUERY_CONDITION_ID in NUMBER,
  X_TOKEN_TYPE in VARCHAR2,
  X_TOKEN_SEQUENCE in NUMBER,
  X_AVAILABLE_LOV_ID in NUMBER,
  X_VALUE_TYPE in VARCHAR2,
  X_NON_VARIANT_VALUE in VARCHAR2,
  X_QUERY_ALIAS_ID in NUMBER,
  X_DATA_TYPE in VARCHAR2,
  X_EXP_LOGIC_SEQ in NUMBER,
  X_EXP_DISPLAY_SEQ in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_DISPLAY_TEXT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE
) is
  cursor C is select ROWID from AMS_QUERY_COND_DISP_STRUCT_ALL
    where QUERY_COND_DISP_STRUCT_ID = X_QUERY_COND_DISP_STRUCT_ID
    ;
begin
  insert into AMS_QUERY_COND_DISP_STRUCT_ALL (
    QUERY_COND_DISP_STRUCT_ID,
    QUERY_TEMPLATE_ID,
    QUERY_CONDITION_ID,
    TOKEN_TYPE,
    TOKEN_SEQUENCE,
    AVAILABLE_LOV_ID,
    VALUE_TYPE,
    NON_VARIANT_VALUE,
    QUERY_ALIAS_ID,
    DATA_TYPE,
    EXP_LOGIC_SEQ,
    EXP_DISPLAY_SEQ,
    OBJECT_VERSION_NUMBER,
    REQUEST_ID,
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
    X_QUERY_COND_DISP_STRUCT_ID,
    X_QUERY_TEMPLATE_ID,
    X_QUERY_CONDITION_ID,
    X_TOKEN_TYPE,
    X_TOKEN_SEQUENCE,
    X_AVAILABLE_LOV_ID,
    X_VALUE_TYPE,
    X_NON_VARIANT_VALUE,
    X_QUERY_ALIAS_ID,
    X_DATA_TYPE,
    X_EXP_LOGIC_SEQ,
    X_EXP_DISPLAY_SEQ,
    X_OBJECT_VERSION_NUMBER,
    X_REQUEST_ID,
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

  insert into AMS_QUERY_COND_DISP_STRUCT_TL (
    QUERY_COND_DISP_STRUCT_ID,
    DISPLAY_TEXT,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_QUERY_COND_DISP_STRUCT_ID,
    X_DISPLAY_TEXT,
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
    from AMS_QUERY_COND_DISP_STRUCT_TL T
    where T.QUERY_COND_DISP_STRUCT_ID = X_QUERY_COND_DISP_STRUCT_ID
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
  X_QUERY_COND_DISP_STRUCT_ID in NUMBER,
  X_QUERY_TEMPLATE_ID in NUMBER,
  X_QUERY_CONDITION_ID in NUMBER,
  X_TOKEN_TYPE in VARCHAR2,
  X_TOKEN_SEQUENCE in NUMBER,
  X_AVAILABLE_LOV_ID in NUMBER,
  X_VALUE_TYPE in VARCHAR2,
  X_NON_VARIANT_VALUE in VARCHAR2,
  X_QUERY_ALIAS_ID in NUMBER,
  X_DATA_TYPE in VARCHAR2,
  X_EXP_LOGIC_SEQ in NUMBER,
  X_EXP_DISPLAY_SEQ in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_DISPLAY_TEXT in VARCHAR2,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE
) is
  cursor c is select
      QUERY_TEMPLATE_ID,
      QUERY_CONDITION_ID,
      TOKEN_TYPE,
      TOKEN_SEQUENCE,
      AVAILABLE_LOV_ID,
      VALUE_TYPE,
      NON_VARIANT_VALUE,
      QUERY_ALIAS_ID,
      DATA_TYPE,
      EXP_LOGIC_SEQ,
      EXP_DISPLAY_SEQ,
      OBJECT_VERSION_NUMBER,
      REQUEST_ID,
      SECURITY_GROUP_ID
    from AMS_QUERY_COND_DISP_STRUCT_ALL
    where QUERY_COND_DISP_STRUCT_ID = X_QUERY_COND_DISP_STRUCT_ID
    for update of QUERY_COND_DISP_STRUCT_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_TEXT,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMS_QUERY_COND_DISP_STRUCT_TL
    where QUERY_COND_DISP_STRUCT_ID = X_QUERY_COND_DISP_STRUCT_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of QUERY_COND_DISP_STRUCT_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.QUERY_TEMPLATE_ID = X_QUERY_TEMPLATE_ID)
           OR ((recinfo.QUERY_TEMPLATE_ID is null) AND (X_QUERY_TEMPLATE_ID is null)))
      AND ((recinfo.QUERY_CONDITION_ID = X_QUERY_CONDITION_ID)
           OR ((recinfo.QUERY_CONDITION_ID is null) AND (X_QUERY_CONDITION_ID is null)))
      AND ((recinfo.TOKEN_TYPE = X_TOKEN_TYPE)
           OR ((recinfo.TOKEN_TYPE is null) AND (X_TOKEN_TYPE is null)))
      AND ((recinfo.TOKEN_SEQUENCE = X_TOKEN_SEQUENCE)
           OR ((recinfo.TOKEN_SEQUENCE is null) AND (X_TOKEN_SEQUENCE is null)))
      AND ((recinfo.AVAILABLE_LOV_ID = X_AVAILABLE_LOV_ID)
           OR ((recinfo.AVAILABLE_LOV_ID is null) AND (X_AVAILABLE_LOV_ID is null)))
      AND ((recinfo.VALUE_TYPE = X_VALUE_TYPE)
           OR ((recinfo.VALUE_TYPE is null) AND (X_VALUE_TYPE is null)))
      AND ((recinfo.NON_VARIANT_VALUE = X_NON_VARIANT_VALUE)
           OR ((recinfo.NON_VARIANT_VALUE is null) AND (X_NON_VARIANT_VALUE is null)))
      AND ((recinfo.QUERY_ALIAS_ID = X_QUERY_ALIAS_ID)
           OR ((recinfo.QUERY_ALIAS_ID is null) AND (X_QUERY_ALIAS_ID is null)))
      AND ((recinfo.DATA_TYPE = X_DATA_TYPE)
           OR ((recinfo.DATA_TYPE is null) AND (X_DATA_TYPE is null)))
      AND ((recinfo.EXP_LOGIC_SEQ = X_EXP_LOGIC_SEQ)
           OR ((recinfo.EXP_LOGIC_SEQ is null) AND (X_EXP_LOGIC_SEQ is null)))
      AND ((recinfo.EXP_DISPLAY_SEQ = X_EXP_DISPLAY_SEQ)
           OR ((recinfo.EXP_DISPLAY_SEQ is null) AND (X_EXP_DISPLAY_SEQ is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
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
      if (    ((tlinfo.DISPLAY_TEXT = X_DISPLAY_TEXT)
               OR ((tlinfo.DISPLAY_TEXT is null) AND (X_DISPLAY_TEXT is null)))
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
  X_QUERY_COND_DISP_STRUCT_ID in NUMBER,
  X_QUERY_TEMPLATE_ID in NUMBER,
  X_QUERY_CONDITION_ID in NUMBER,
  X_TOKEN_TYPE in VARCHAR2,
  X_TOKEN_SEQUENCE in NUMBER,
  X_AVAILABLE_LOV_ID in NUMBER,
  X_VALUE_TYPE in VARCHAR2,
  X_NON_VARIANT_VALUE in VARCHAR2,
  X_QUERY_ALIAS_ID in NUMBER,
  X_DATA_TYPE in VARCHAR2,
  X_EXP_LOGIC_SEQ in NUMBER,
  X_EXP_DISPLAY_SEQ in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_DISPLAY_TEXT in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE
) is
begin
  update AMS_QUERY_COND_DISP_STRUCT_ALL set
    QUERY_TEMPLATE_ID = X_QUERY_TEMPLATE_ID,
    QUERY_CONDITION_ID = X_QUERY_CONDITION_ID,
    TOKEN_TYPE = X_TOKEN_TYPE,
    TOKEN_SEQUENCE = X_TOKEN_SEQUENCE,
    AVAILABLE_LOV_ID = X_AVAILABLE_LOV_ID,
    VALUE_TYPE = X_VALUE_TYPE,
    NON_VARIANT_VALUE = X_NON_VARIANT_VALUE,
    QUERY_ALIAS_ID = X_QUERY_ALIAS_ID,
    DATA_TYPE = X_DATA_TYPE,
    EXP_LOGIC_SEQ = X_EXP_LOGIC_SEQ,
    EXP_DISPLAY_SEQ = X_EXP_DISPLAY_SEQ,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    REQUEST_ID = X_REQUEST_ID,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
  where QUERY_COND_DISP_STRUCT_ID = X_QUERY_COND_DISP_STRUCT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_QUERY_COND_DISP_STRUCT_TL set
    DISPLAY_TEXT = X_DISPLAY_TEXT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where QUERY_COND_DISP_STRUCT_ID = X_QUERY_COND_DISP_STRUCT_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


PROCEDURE LOAD_ROW (
  X_QUERY_COND_DISP_STRUCT_ID IN NUMBER,
  X_QUERY_TEMPLATE_ID in NUMBER,
  X_QUERY_CONDITION_ID in NUMBER,
  X_TOKEN_TYPE in VARCHAR2,
  X_TOKEN_SEQUENCE in NUMBER,
  X_AVAILABLE_LOV_ID in NUMBER,
  X_VALUE_TYPE in VARCHAR2,
  X_NON_VARIANT_VALUE in VARCHAR2,
  X_QUERY_ALIAS_ID in NUMBER,
  X_DATA_TYPE in VARCHAR2,
  X_EXP_LOGIC_SEQ in NUMBER,
  X_EXP_DISPLAY_SEQ in NUMBER,
  X_DISPLAY_TEXT in VARCHAR2,
  x_owner IN VARCHAR2,
  x_custom_mode IN VARCHAR2
)
IS
   l_user_id   number := 0;
   l_obj_verno  number;
   l_dummy_char  varchar2(1);
   l_row_id    varchar2(100);
   l_disp_struct_id   number;
   l_db_luby_id   number;

   CURSOR  c_obj_verno IS
     SELECT object_version_number, last_updated_by
     FROM   AMS_QUERY_COND_DISP_STRUCT_ALL
     WHERE  QUERY_COND_DISP_STRUCT_ID =  X_QUERY_COND_DISP_STRUCT_ID;

   CURSOR c_chk_exists is
     SELECT 'x'
     FROM   AMS_QUERY_COND_DISP_STRUCT_ALL
     WHERE  QUERY_COND_DISP_STRUCT_ID = X_QUERY_COND_DISP_STRUCT_ID;

   CURSOR c_get_id is
      SELECT AMS_QUERY_COND_DISP_STRUCT_S.NEXTVAL
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

      IF X_QUERY_COND_DISP_STRUCT_ID IS NULL THEN
         OPEN c_get_id;
         FETCH c_get_id INTO l_disp_struct_id;
         CLOSE c_get_id;
      ELSE
         l_disp_struct_id := X_QUERY_COND_DISP_STRUCT_ID;
      END IF;

      l_obj_verno := 1;

      AMS_QUERY_COND_DISP_STRUCT_PKG.Insert_Row (
         X_ROWID                    => l_row_id,
         X_QUERY_COND_DISP_STRUCT_ID => l_disp_struct_id,
         X_QUERY_TEMPLATE_ID         => X_QUERY_TEMPLATE_ID,
         X_QUERY_CONDITION_ID        => X_QUERY_CONDITION_ID,
         X_TOKEN_TYPE                => X_TOKEN_TYPE,
         X_TOKEN_SEQUENCE            => X_TOKEN_SEQUENCE,
         X_AVAILABLE_LOV_ID          => X_AVAILABLE_LOV_ID,
         X_VALUE_TYPE                => X_VALUE_TYPE,
	 X_NON_VARIANT_VALUE         => X_NON_VARIANT_VALUE,
         X_QUERY_ALIAS_ID            => X_QUERY_ALIAS_ID,
         X_DATA_TYPE                 => X_DATA_TYPE,
	 X_EXP_LOGIC_SEQ             => X_EXP_LOGIC_SEQ,
         X_EXP_DISPLAY_SEQ           => X_EXP_DISPLAY_SEQ,
         X_OBJECT_VERSION_NUMBER    => l_obj_verno,
         X_REQUEST_ID               => 0,
	 X_SECURITY_GROUP_ID        => 0,
         X_DISPLAY_TEXT             => X_DISPLAY_TEXT,
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

      AMS_QUERY_COND_DISP_STRUCT_PKG.Update_Row (
         X_QUERY_COND_DISP_STRUCT_ID => X_QUERY_COND_DISP_STRUCT_ID ,
         X_QUERY_TEMPLATE_ID         => X_QUERY_TEMPLATE_ID,
         X_QUERY_CONDITION_ID        => X_QUERY_CONDITION_ID,
         X_TOKEN_TYPE                => X_TOKEN_TYPE,
         X_TOKEN_SEQUENCE            => X_TOKEN_SEQUENCE,
         X_AVAILABLE_LOV_ID          => X_AVAILABLE_LOV_ID,
         X_VALUE_TYPE                => X_VALUE_TYPE,
	 X_NON_VARIANT_VALUE         => X_NON_VARIANT_VALUE,
         X_QUERY_ALIAS_ID            => X_QUERY_ALIAS_ID,
         X_DATA_TYPE                 => X_DATA_TYPE,
	 X_EXP_LOGIC_SEQ             => X_EXP_LOGIC_SEQ,
         X_EXP_DISPLAY_SEQ           => X_EXP_DISPLAY_SEQ,
         X_OBJECT_VERSION_NUMBER    => l_obj_verno,
         X_REQUEST_ID               => 0,
	 X_SECURITY_GROUP_ID        => 0,
         X_DISPLAY_TEXT             => X_DISPLAY_TEXT,
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

procedure DELETE_ROW (
  X_QUERY_COND_DISP_STRUCT_ID in NUMBER
) is
begin
  delete from AMS_QUERY_COND_DISP_STRUCT_TL
  where QUERY_COND_DISP_STRUCT_ID = X_QUERY_COND_DISP_STRUCT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_QUERY_COND_DISP_STRUCT_ALL
  where QUERY_COND_DISP_STRUCT_ID = X_QUERY_COND_DISP_STRUCT_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_QUERY_COND_DISP_STRUCT_TL T
  where not exists
    (select NULL
    from AMS_QUERY_COND_DISP_STRUCT_ALL B
    where B.QUERY_COND_DISP_STRUCT_ID = T.QUERY_COND_DISP_STRUCT_ID
    );

  update AMS_QUERY_COND_DISP_STRUCT_TL T set (
      DISPLAY_TEXT
    ) = (select
      B.DISPLAY_TEXT
    from AMS_QUERY_COND_DISP_STRUCT_TL B
    where B.QUERY_COND_DISP_STRUCT_ID = T.QUERY_COND_DISP_STRUCT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.QUERY_COND_DISP_STRUCT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.QUERY_COND_DISP_STRUCT_ID,
      SUBT.LANGUAGE
    from AMS_QUERY_COND_DISP_STRUCT_TL SUBB, AMS_QUERY_COND_DISP_STRUCT_TL SUBT
    where SUBB.QUERY_COND_DISP_STRUCT_ID = SUBT.QUERY_COND_DISP_STRUCT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_TEXT <> SUBT.DISPLAY_TEXT
      or (SUBB.DISPLAY_TEXT is null and SUBT.DISPLAY_TEXT is not null)
      or (SUBB.DISPLAY_TEXT is not null and SUBT.DISPLAY_TEXT is null)
  ));

  insert into AMS_QUERY_COND_DISP_STRUCT_TL (
    QUERY_COND_DISP_STRUCT_ID,
    DISPLAY_TEXT,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.QUERY_COND_DISP_STRUCT_ID,
    B.DISPLAY_TEXT,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_QUERY_COND_DISP_STRUCT_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_QUERY_COND_DISP_STRUCT_TL T
    where T.QUERY_COND_DISP_STRUCT_ID = B.QUERY_COND_DISP_STRUCT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure TRANSLATE_ROW(
  X_QUERY_COND_DISP_STRUCT_ID in NUMBER,
  X_DISPLAY_TEXT in VARCHAR2,
  x_owner   in VARCHAR2,
  x_custom_mode in VARCHAR2
 )  is

  cursor c_last_updated_by is
        select last_updated_by
        from AMS_QUERY_COND_DISP_STRUCT_TL
        where QUERY_COND_DISP_STRUCT_ID = x_QUERY_COND_DISP_STRUCT_ID
        and  USERENV('LANG') = LANGUAGE;

        l_luby number; --last updated by

begin

open c_last_updated_by;
fetch c_last_updated_by into l_luby;
close c_last_updated_by;

 if (l_luby IN (0, 1, 2) or NVL(x_custom_mode, 'PRESERVE')='FORCE')
       then
    update AMS_QUERY_COND_DISP_STRUCT_TL set
       DISPLAY_TEXT = nvl(x_DISPLAY_TEXT, DISPLAY_TEXT),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1,  'ORACLE', 2, 'SYSADMIN', 0, -1),
       last_update_login = 0
    where  QUERY_COND_DISP_STRUCT_ID = x_QUERY_COND_DISP_STRUCT_ID
    and      userenv('LANG') in (language, source_lang);
 end if;
end TRANSLATE_ROW;


end AMS_QUERY_COND_DISP_STRUCT_PKG;

/
