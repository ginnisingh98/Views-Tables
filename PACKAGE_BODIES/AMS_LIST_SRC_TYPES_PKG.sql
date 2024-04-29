--------------------------------------------------------
--  DDL for Package Body AMS_LIST_SRC_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_SRC_TYPES_PKG" AS
/* $Header: amsllstb.pls 120.2 2006/06/07 08:41:17 bmuthukr noship $ */

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE insert_row (
  x_rowid IN OUT NOCOPY VARCHAR2,
  x_list_source_type_id IN NUMBER,
  x_object_version_number IN NUMBER,
  x_list_source_name IN VARCHAR2,
  x_list_source_type IN VARCHAR2,
  x_source_type_code IN VARCHAR2,
  x_source_object_name IN VARCHAR2,
  x_master_source_type_flag IN VARCHAR2,
  x_source_object_pk_field IN VARCHAR2,
  x_enabled_flag IN VARCHAR2,
  x_description IN VARCHAR2,
  X_JAVA_CLASS_NAME IN VARCHAR2,
  x_view_application_id          in number,
  x_ARC_ACT_SRC_USED_BY          in varchar2,
  x_SOURCE_CATEGORY              in varchar2,
  x_import_type                  in varchar2,
  x_creation_date IN DATE,
  x_created_by IN NUMBER,
  x_last_update_date IN DATE,
  x_last_updated_by IN NUMBER,
  x_last_update_login IN NUMBER,
  x_BASED_ON_TCA_FLAG             IN varchar2
) IS
  l_import_type VARCHAR2(30);
  CURSOR c IS SELECT rowid FROM ams_list_src_types
    WHERE list_source_type_id = x_list_source_type_id;

  CURSOR c_import_type(code IN VARCHAR2) IS SELECT lookup_code FROM ams_lookups
    WHERE lookup_type = 'AMS_IMPORT_TYPE' and enabled_flag='Y'
    AND lookup_code = code;
BEGIN
  if x_import_type is not null or
     x_import_type <> FND_API.G_MISS_CHAR then
     OPEN c_import_type(x_import_type);
     FETCH c_import_type into l_import_type;
     IF (c_import_type%NOTFOUND) THEN
        CLOSE c_import_type;
        FND_MESSAGE.SET_NAME('AMS', 'AMS_INVALID_IMPORT_TYPE');
        APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;
     CLOSE c_import_type;
  end if;

  INSERT INTO ams_list_src_types (
    list_source_type_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    object_version_number,
    list_source_name,
    list_source_type,
    source_type_code,
    source_object_name,
    master_source_type_flag,
    source_object_pk_field,
    enabled_flag,
    description,
    java_class_name,
    view_application_id         ,
    ARC_ACT_SRC_USED_BY         ,
    SOURCE_CATEGORY             ,
    IMPORT_TYPE,
    BASED_ON_TCA_FLAG
  )
  values (
    x_list_source_type_id,
    x_last_update_date,
    x_last_updated_by,
    x_creation_date,
    x_created_by,
    x_last_update_login,
    x_object_version_number,
    x_list_source_name,
    x_list_source_type,
    x_source_type_code,
    x_source_object_name,
    x_master_source_type_flag,
    x_source_object_pk_field,
    x_enabled_flag,
    x_description,
    x_java_class_name,
    x_view_application_id          ,
    x_ARC_ACT_SRC_USED_BY          ,
    x_SOURCE_CATEGORY              ,
    x_IMPORT_TYPE,
    x_BASED_ON_TCA_FLAG
  );
  insert into AMS_LIST_SRC_TYPES_TL (
    LANGUAGE,
    SOURCE_LANG,
    LIST_SOURCE_NAME,
    DESCRIPTION,
    LIST_SOURCE_TYPE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATE_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    l.language_code,
    userenv('LANG'),
    x_list_source_name,
    x_description,
    x_list_source_type_id,
--Modified for bug 5237401. bmuthukr
/*
    sysdate,
    FND_GLOBAL.user_id,
    sysdate,
    FND_GLOBAL.user_id,
*/
    x_last_update_date,
    x_last_updated_by,
    x_creation_date,
    x_created_by,
--
    FND_GLOBAL.conc_login_id
    from FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and not exists
    (select NULL
    from AMS_LIST_SRC_TYPES_TL T
    where T.LIST_SOURCE_TYPE_ID = x_list_source_type_id
    and T.LANGUAGE = L.LANGUAGE_CODE);


  OPEN C;
  FETCH C INTO x_rowid;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;

END insert_row;

PROCEDURE lock_row (
  x_list_source_type_id IN NUMBER,
  x_object_version_number IN NUMBER,
  x_list_source_name IN VARCHAR2,
  x_list_source_type IN VARCHAR2,
  x_source_type_code IN VARCHAR2,
  x_source_object_name IN VARCHAR2,
  x_master_source_type_flag IN VARCHAR2,
  x_source_object_pk_field IN VARCHAR2,
  x_enabled_flag IN VARCHAR2,
  x_description IN VARCHAR2,
  X_JAVA_CLASS_NAME IN VARCHAR2,
  x_view_application_id          in number,
  x_ARC_ACT_SRC_USED_BY          in varchar2,
  x_SOURCE_CATEGORY             in varchar2,
  x_import_type                 in varchar2,
  x_BASED_ON_TCA_FLAG             IN varchar2
) IS
  CURSOR C1 IS SELECT
      object_version_number,
      list_source_name,
      list_source_type,
      source_type_code,
      source_object_name,
      master_source_type_flag,
      source_object_pk_field,
      enabled_flag,
      description,
      java_class_name,
      view_application_id          ,
      ARC_ACT_SRC_USED_BY          ,
      SOURCE_CATEGORY              ,
      IMPORT_TYPE,
      BASED_ON_TCA_FLAG
    FROM ams_list_src_types
    WHERE list_source_type_id = x_list_source_type_id
    FOR UPDATE OF list_source_type_id NOWAIT;
BEGIN
  FOR TLINFO IN C1 LOOP
      IF (    ((TLINFO.description = x_description)
               or ((TLINFO.description IS NULL) and (x_description IS NULL)))
          and ((TLINFO.object_version_number = x_object_version_number)
               or ((TLINFO.object_version_number IS NULL) and (x_object_version_number IS NULL)))
          and (TLINFO.list_source_name = x_list_source_name)
          and (TLINFO.list_source_type = x_list_source_type)
          and (TLINFO.source_type_code = x_source_type_code)
          and (TLINFO.source_object_name = x_source_object_name)
          and (TLINFO.master_source_type_flag = x_master_source_type_flag)
          and ((TLINFO.source_object_pk_field = x_source_object_pk_field)
               or ((TLINFO.source_object_pk_field IS NULL) and (x_source_object_pk_field IS NULL)))
          and (TLINFO.enabled_flag = x_enabled_flag)
	  and (TLINFO.BASED_ON_TCA_FLAG = X_BASED_ON_TCA_FLAG)
      ) THEN
        NULL;
      ELSE
        FND_MESSAGE.SET_NAME('fnd', 'form_record_changed');
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
  END LOOP;
  RETURN;
END lock_row;

PROCEDURE update_row (
  x_list_source_type_id IN NUMBER,
  x_object_version_number IN NUMBER,
  x_list_source_name IN VARCHAR2,
  x_list_source_type IN VARCHAR2,
  x_source_type_code IN VARCHAR2,
  x_source_object_name IN VARCHAR2,
  x_master_source_type_flag IN VARCHAR2,
  x_source_object_pk_field IN VARCHAR2,
  x_enabled_flag IN VARCHAR2,
  x_description IN VARCHAR2,
  X_JAVA_CLASS_NAME IN VARCHAR2,
  x_view_application_id          in number,
  x_ARC_ACT_SRC_USED_BY          in varchar2,
  x_SOURCE_CATEGORY              in varchar2,
  x_IMPORT_TYPE                  in varchar2,
  x_last_update_date IN DATE,
  x_last_updated_by IN NUMBER,
  x_last_update_login IN NUMBER,
  x_BASED_ON_TCA_FLAG             IN varchar2
) IS
  l_import_type VARCHAR2(30);
  CURSOR c_import_type(code IN VARCHAR2) IS SELECT lookup_code FROM ams_lookups
    WHERE lookup_type = 'AMS_IMPORT_TYPE' and enabled_flag='Y'
    AND lookup_code = code;
BEGIN
  if x_import_type is not null or
     x_import_type <> FND_API.G_MISS_CHAR then
     OPEN c_import_type(x_import_type);
     FETCH c_import_type into l_import_type;
     IF (c_import_type%NOTFOUND) THEN
        CLOSE c_import_type;
        FND_MESSAGE.SET_NAME('AMS', 'AMS_INVALID_IMPORT_TYPE');
        APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;
     CLOSE c_import_type;
  end if;

  UPDATE ams_list_src_types SET
    object_version_number = x_object_version_number,
    list_source_name = x_list_source_name,
    list_source_type = x_list_source_type,
    source_type_code = x_source_type_code,
    source_object_name = x_source_object_name,
    master_source_type_flag = x_master_source_type_flag,
    source_object_pk_field = x_source_object_pk_field,
    enabled_flag = x_enabled_flag,
    description = x_description,
    JAVA_CLASS_NAME = x_java_class_name,
    view_application_id          = x_VIEW_APPLICATION_ID,
    ARC_ACT_SRC_USED_BY          = x_ARC_ACT_SRC_USED_BY,
    SOURCE_CATEGORY              = x_SOURCE_CATEGORY,
    IMPORT_TYPE                  = x_IMPORT_TYPE,
    last_update_date = x_last_update_date,
    last_updated_by = x_last_updated_by,
    last_update_login = x_last_update_login,
    BASED_ON_TCA_FLAG = X_BASED_ON_TCA_FLAG
  WHERE list_source_type_id = x_list_source_type_id;

  update AMS_LIST_SRC_TYPES_TL set
    LIST_SOURCE_NAME = x_list_source_name,
    DESCRIPTION = x_description,
    LAST_UPDATE_DATE = sysdate,
    --for bug 5237401
    -- LAST_UPDATE_BY = FND_GLOBAL.user_id,
    last_update_by = x_last_updated_by,
    LAST_UPDATE_LOGIN = FND_GLOBAL.conc_login_id,
    SOURCE_LANG = userenv('LANG')
  WHERE list_source_type_id = x_list_source_type_id
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END update_row;

PROCEDURE delete_row (
  x_list_source_type_id IN NUMBER
) IS
BEGIN
  DELETE FROM ams_list_src_types
  WHERE list_source_type_id = x_list_source_type_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END delete_row;

PROCEDURE load_row (
  X_LIST_SOURCE_TYPE_ID in NUMBER,
  X_LIST_SOURCE_NAME in VARCHAR2,
  X_LIST_SOURCE_TYPE in VARCHAR2,
  X_SOURCE_TYPE_CODE in VARCHAR2,
  X_SOURCE_OBJECT_NAME in VARCHAR2,
  X_MASTER_SOURCE_TYPE_FLAG in VARCHAR2,
  X_SOURCE_OBJECT_PK_FIELD in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_JAVA_CLASS_NAME IN VARCHAR2,
  x_view_application_id          in number,
  x_ARC_ACT_SRC_USED_BY          in varchar2,
  x_SOURCE_CATEGORY              in varchar2,
  x_import_type                  in varchar2,
  x_owner IN VARCHAR2,
  x_custom_mode IN VARCHAR2,
  x_BASED_ON_TCA_FLAG             IN varchar2
)
IS
   l_user_id   number := 0;
   l_obj_verno  number;
   l_dummy_char  varchar2(1);
   l_row_id    varchar2(100);
   l_list_source_type_id   number;
   l_last_updated_by number;

   CURSOR  c_obj_verno IS
     SELECT object_version_number,  last_updated_by
     FROM   ams_list_src_types
     WHERE  list_source_type_id =  x_list_source_type_id;

   CURSOR c_chk_exists is
     SELECT 'x'
     FROM   ams_list_src_types
     WHERE  list_source_type_id = x_list_source_type_id;

   CURSOR c_get_id is
      SELECT ams_list_src_types_s.NEXTVAL
      FROM DUAL;
BEGIN
   if X_OWNER = 'SEED' then
      l_user_id := 1;
   elsif X_OWNER = 'ORACLE' then
      l_user_id := 2;
   elsif X_OWNER = 'SYSADMIN' THEN
      l_user_id := 0;
   end if;

   OPEN c_chk_exists;
   FETCH c_chk_exists INTO l_dummy_char;
   IF c_chk_exists%notfound THEN
      CLOSE c_chk_exists;

      IF x_list_source_type_id IS NULL THEN
         OPEN c_get_id;
         FETCH c_get_id INTO l_list_source_type_id;
         CLOSE c_get_id;
      ELSE
         l_list_source_type_id := x_list_source_type_id;
      END IF;
      l_obj_verno := 1;

      ams_list_src_types_pkg.Insert_Row (
         X_ROWID                    => l_row_id,
         X_LIST_SOURCE_TYPE_ID      => l_list_source_type_id,
         X_OBJECT_VERSION_NUMBER    => l_obj_verno,
         X_LIST_SOURCE_NAME         => x_list_source_name,
         X_LIST_SOURCE_TYPE         => x_list_source_type,
         X_SOURCE_TYPE_CODE         => x_source_type_code,
         X_SOURCE_OBJECT_NAME       => x_source_object_name,
         X_MASTER_SOURCE_TYPE_FLAG  => x_master_source_type_flag,
         X_SOURCE_OBJECT_PK_FIELD   => x_source_object_pk_field,
         X_ENABLED_FLAG             => x_enabled_flag,
         X_DESCRIPTION              => x_description,
         X_JAVA_CLASS_NAME          => x_java_class_name,
         x_view_application_id      => x_VIEW_APPLICATION_ID,
         x_ARC_ACT_SRC_USED_BY      => x_ARC_ACT_SRC_USED_BY,
         x_SOURCE_CATEGORY          => x_SOURCE_CATEGORY,
	 x_IMPORT_TYPE              => x_IMPORT_TYPE,
          X_CREATION_DATE           => SYSDATE,
         X_CREATED_BY               => l_user_id,
         X_LAST_UPDATE_DATE         => SYSDATE,
         X_LAST_UPDATED_BY          => l_user_id,
         X_LAST_UPDATE_LOGIN        => 0,
	 x_BASED_ON_TCA_FLAG        => x_BASED_ON_TCA_FLAG
      );
   ELSE
      CLOSE c_chk_exists;
      OPEN c_obj_verno;
      FETCH c_obj_verno INTO l_obj_verno,l_last_updated_by;
      CLOSE c_obj_verno;


    if (l_last_updated_by in (1,2,0) OR
          NVL(x_custom_mode,'PRESERVE')='FORCE') THEN

      ams_list_src_types_pkg.Update_Row (
         X_LIST_SOURCE_TYPE_ID      => x_list_source_type_id,
         X_OBJECT_VERSION_NUMBER    => l_obj_verno,
         X_LIST_SOURCE_NAME         => x_list_source_name,
         X_LIST_SOURCE_TYPE         => x_list_source_type,
         X_SOURCE_TYPE_CODE         => x_source_type_code,
         X_SOURCE_OBJECT_NAME       => x_source_object_name,
         X_MASTER_SOURCE_TYPE_FLAG  => x_master_source_type_flag,
         X_SOURCE_OBJECT_PK_FIELD   => x_source_object_pk_field,
         X_ENABLED_FLAG             => x_enabled_flag,
         X_DESCRIPTION              => x_description,
         X_JAVA_CLASS_NAME          =>X_JAVA_CLASS_NAME,
         x_view_application_id      =>x_VIEW_APPLICATION_ID,
         x_ARC_ACT_SRC_USED_BY      =>x_ARC_ACT_SRC_USED_BY,
         x_SOURCE_CATEGORY          =>x_SOURCE_CATEGORY,
 	 x_IMPORT_TYPE              => x_IMPORT_TYPE,
         X_LAST_UPDATE_DATE         => SYSDATE,
         X_LAST_UPDATED_BY          => l_user_id,
         X_LAST_UPDATE_LOGIN        => 0,
	 x_BASED_ON_TCA_FLAG        => x_BASED_ON_TCA_FLAG
      );
     end if;

   END IF;
END load_row;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_LIST_SRC_TYPES_TL T
  where not exists
    (select NULL
    from AMS_LIST_SRC_TYPES B
    where B.LIST_SOURCE_TYPE_ID = T.LIST_SOURCE_TYPE_ID
    );

  update AMS_LIST_SRC_TYPES_TL T set (
      LIST_SOURCE_NAME,
      DESCRIPTION
    ) = (select
      B.LIST_SOURCE_NAME,
      B.DESCRIPTION
    from AMS_LIST_SRC_TYPES_TL B
    where B.LIST_SOURCE_TYPE_ID = T.LIST_SOURCE_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LIST_SOURCE_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.LIST_SOURCE_TYPE_ID,
      SUBT.LANGUAGE
    from AMS_LIST_SRC_TYPES_TL SUBB, AMS_LIST_SRC_TYPES_TL SUBT
    where SUBB.LIST_SOURCE_TYPE_ID = SUBT.LIST_SOURCE_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.LIST_SOURCE_NAME <> SUBT.LIST_SOURCE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_LIST_SRC_TYPES_TL (
    LIST_SOURCE_TYPE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATE_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LIST_SOURCE_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.LIST_SOURCE_TYPE_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LIST_SOURCE_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_LIST_SRC_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_LIST_SRC_TYPES_TL T
    where T.LIST_SOURCE_TYPE_ID = B.LIST_SOURCE_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
procedure TRANSLATE_ROW(
  X_LIST_SOURCE_TYPE_ID in NUMBER,
  X_LIST_SOURCE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  x_owner   in VARCHAR2,
  x_custom_mode in VARCHAR2
 )  is

 cursor c_last_updated_by is
  select last_update_by
  FROM ams_list_src_types_tl
  where  list_source_type_id =  x_list_source_type_id
  and  USERENV('LANG') = LANGUAGE;

 l_last_updated_by number;


begin


    open c_last_updated_by;
     fetch c_last_updated_by into l_last_updated_by;
     close c_last_updated_by;

    if (l_last_updated_by in (1,2,0) OR
            NVL(x_custom_mode,'PRESERVE')='FORCE') THEN

    update AMS_LIST_SRC_TYPES_TL set
       list_source_name = nvl(x_list_source_name, list_source_name),
       description = nvl(x_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_update_by = decode(x_owner, 'SEED', 1, 'ORACLE', 2, 'SYSADMIN', 0, -1),
       last_update_login = 0
    where  list_source_type_id = x_list_source_type_id
    and      userenv('LANG') in (language, source_lang);

    end if;
end TRANSLATE_ROW;

END ams_list_src_types_pkg;

/
