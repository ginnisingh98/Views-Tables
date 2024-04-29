--------------------------------------------------------
--  DDL for Package Body AMS_LIST_SRC_TYPES_NEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_SRC_TYPES_NEW_PKG" as
/* $Header: amstlstb.pls 120.3 2005/09/12 05:40:21 rmbhanda noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_LIST_SOURCE_TYPE_ID in NUMBER,
  X_REMOTE_FLAG in VARCHAR2,
  X_DATABASE_LINK in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_JAVA_CLASS_NAME in VARCHAR2,
  X_ARC_ACT_SRC_USED_BY in VARCHAR2,
  X_SOURCE_CATEGORY in VARCHAR2,
  X_IMPORT_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LIST_SOURCE_TYPE in VARCHAR2,
  X_SOURCE_TYPE_CODE in VARCHAR2,
  X_SOURCE_OBJECT_NAME in VARCHAR2,
  X_MASTER_SOURCE_TYPE_FLAG in VARCHAR2,
  X_SOURCE_OBJECT_PK_FIELD in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_LIST_SOURCE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_BASED_ON_TCA_FLAG in VARCHAR2
) is
  cursor C is select ROWID from AMS_LIST_SRC_TYPES
    where LIST_SOURCE_TYPE_ID = X_LIST_SOURCE_TYPE_ID
    ;
begin
  insert into AMS_LIST_SRC_TYPES (
    REMOTE_FLAG,
    DATABASE_LINK,
    SEEDED_FLAG,
    VIEW_APPLICATION_ID,
    JAVA_CLASS_NAME,
    ARC_ACT_SRC_USED_BY,
    SOURCE_CATEGORY,
    IMPORT_TYPE,
    LIST_SOURCE_TYPE_ID,
    OBJECT_VERSION_NUMBER,
    LIST_SOURCE_TYPE,
    SOURCE_TYPE_CODE,
    SOURCE_OBJECT_NAME,
    MASTER_SOURCE_TYPE_FLAG,
    SOURCE_OBJECT_PK_FIELD,
    ENABLED_FLAG,
    SECURITY_GROUP_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    BASED_ON_TCA_FLAG
  ) values (
    X_REMOTE_FLAG,
    X_DATABASE_LINK,
    X_SEEDED_FLAG,
    X_VIEW_APPLICATION_ID,
    X_JAVA_CLASS_NAME,
    X_ARC_ACT_SRC_USED_BY,
    X_SOURCE_CATEGORY,
    X_IMPORT_TYPE,
    X_LIST_SOURCE_TYPE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_LIST_SOURCE_TYPE,
    X_SOURCE_TYPE_CODE,
    X_SOURCE_OBJECT_NAME,
    X_MASTER_SOURCE_TYPE_FLAG,
    X_SOURCE_OBJECT_PK_FIELD,
    X_ENABLED_FLAG,
    X_SECURITY_GROUP_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_BASED_ON_TCA_FLAG
  );

  insert into AMS_LIST_SRC_TYPES_TL (
    LIST_SOURCE_TYPE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATE_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LIST_SOURCE_NAME,
    DESCRIPTION,
    SECURITY_GROUP_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LIST_SOURCE_TYPE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LIST_SOURCE_NAME,
    X_DESCRIPTION,
    X_SECURITY_GROUP_ID,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_LIST_SRC_TYPES_TL T
    where T.LIST_SOURCE_TYPE_ID = X_LIST_SOURCE_TYPE_ID
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
  X_LIST_SOURCE_TYPE_ID in NUMBER,
  X_REMOTE_FLAG in VARCHAR2,
  X_DATABASE_LINK in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_JAVA_CLASS_NAME in VARCHAR2,
  X_ARC_ACT_SRC_USED_BY in VARCHAR2,
  X_SOURCE_CATEGORY in VARCHAR2,
  X_IMPORT_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LIST_SOURCE_TYPE in VARCHAR2,
  X_SOURCE_TYPE_CODE in VARCHAR2,
  X_SOURCE_OBJECT_NAME in VARCHAR2,
  X_MASTER_SOURCE_TYPE_FLAG in VARCHAR2,
  X_SOURCE_OBJECT_PK_FIELD in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_LIST_SOURCE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_BASED_ON_TCA_FLAG in VARCHAR2  --rmbhanda bug#4604219
) is
  cursor c is select
      REMOTE_FLAG,
      DATABASE_LINK,
      SEEDED_FLAG,
      VIEW_APPLICATION_ID,
      JAVA_CLASS_NAME,
      ARC_ACT_SRC_USED_BY,
      SOURCE_CATEGORY,
      IMPORT_TYPE,
      OBJECT_VERSION_NUMBER,
      LIST_SOURCE_TYPE,
      SOURCE_TYPE_CODE,
      SOURCE_OBJECT_NAME,
      MASTER_SOURCE_TYPE_FLAG,
      SOURCE_OBJECT_PK_FIELD,
      ENABLED_FLAG,
      SECURITY_GROUP_ID,
      BASED_ON_TCA_FLAG  --rmbhanda bug#4604219
    from AMS_LIST_SRC_TYPES
    where LIST_SOURCE_TYPE_ID = X_LIST_SOURCE_TYPE_ID
    for update of LIST_SOURCE_TYPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      LIST_SOURCE_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMS_LIST_SRC_TYPES_TL
    where LIST_SOURCE_TYPE_ID = X_LIST_SOURCE_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of LIST_SOURCE_TYPE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.REMOTE_FLAG = X_REMOTE_FLAG)
           OR ((recinfo.REMOTE_FLAG is null) AND (X_REMOTE_FLAG is null)))
      AND ((recinfo.DATABASE_LINK = X_DATABASE_LINK)
           OR ((recinfo.DATABASE_LINK is null) AND (X_DATABASE_LINK is null)))
      AND ((recinfo.SEEDED_FLAG = X_SEEDED_FLAG)
           OR ((recinfo.SEEDED_FLAG is null) AND (X_SEEDED_FLAG is null)))
      AND ((recinfo.VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID)
           OR ((recinfo.VIEW_APPLICATION_ID is null) AND (X_VIEW_APPLICATION_ID is null)))
      AND ((recinfo.JAVA_CLASS_NAME = X_JAVA_CLASS_NAME)
           OR ((recinfo.JAVA_CLASS_NAME is null) AND (X_JAVA_CLASS_NAME is null)))
      AND ((recinfo.ARC_ACT_SRC_USED_BY = X_ARC_ACT_SRC_USED_BY)
           OR ((recinfo.ARC_ACT_SRC_USED_BY is null) AND (X_ARC_ACT_SRC_USED_BY is null)))
      AND ((recinfo.SOURCE_CATEGORY = X_SOURCE_CATEGORY)
           OR ((recinfo.SOURCE_CATEGORY is null) AND (X_SOURCE_CATEGORY is null)))
      AND ((recinfo.IMPORT_TYPE = X_IMPORT_TYPE)
           OR ((recinfo.IMPORT_TYPE is null) AND (X_IMPORT_TYPE is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND (recinfo.LIST_SOURCE_TYPE = X_LIST_SOURCE_TYPE)
      AND (recinfo.SOURCE_TYPE_CODE = X_SOURCE_TYPE_CODE)
      AND (recinfo.SOURCE_OBJECT_NAME = X_SOURCE_OBJECT_NAME)
      AND (recinfo.MASTER_SOURCE_TYPE_FLAG = X_MASTER_SOURCE_TYPE_FLAG)
      AND ((recinfo.SOURCE_OBJECT_PK_FIELD = X_SOURCE_OBJECT_PK_FIELD)
           OR ((recinfo.SOURCE_OBJECT_PK_FIELD is null) AND (X_SOURCE_OBJECT_PK_FIELD is null)))
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
     --rmbhanda bug#4604219 start
      AND ((recinfo.BASED_ON_TCA_FLAG = X_BASED_ON_TCA_FLAG)
           OR ((recinfo.BASED_ON_TCA_FLAG is null) AND (X_BASED_ON_TCA_FLAG is null)))
     --rmbhanda bug#4604219 end
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.LIST_SOURCE_NAME = X_LIST_SOURCE_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
  X_LIST_SOURCE_TYPE_ID in NUMBER,
  X_REMOTE_FLAG in VARCHAR2,
  X_DATABASE_LINK in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_VIEW_APPLICATION_ID in NUMBER,
  X_JAVA_CLASS_NAME in VARCHAR2,
  X_ARC_ACT_SRC_USED_BY in VARCHAR2,
  X_SOURCE_CATEGORY in VARCHAR2,
  X_IMPORT_TYPE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LIST_SOURCE_TYPE in VARCHAR2,
  X_SOURCE_TYPE_CODE in VARCHAR2,
  X_SOURCE_OBJECT_NAME in VARCHAR2,
  X_MASTER_SOURCE_TYPE_FLAG in VARCHAR2,
  X_SOURCE_OBJECT_PK_FIELD in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_LIST_SOURCE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_BASED_ON_TCA_FLAG in VARCHAR2
) is
begin
  update AMS_LIST_SRC_TYPES set
    REMOTE_FLAG = X_REMOTE_FLAG,
    DATABASE_LINK = X_DATABASE_LINK,
    SEEDED_FLAG = X_SEEDED_FLAG,
    VIEW_APPLICATION_ID = X_VIEW_APPLICATION_ID,
    JAVA_CLASS_NAME = X_JAVA_CLASS_NAME,
    ARC_ACT_SRC_USED_BY = X_ARC_ACT_SRC_USED_BY,
    SOURCE_CATEGORY = X_SOURCE_CATEGORY,
    IMPORT_TYPE = X_IMPORT_TYPE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LIST_SOURCE_TYPE = X_LIST_SOURCE_TYPE,
    SOURCE_TYPE_CODE = X_SOURCE_TYPE_CODE,
    SOURCE_OBJECT_NAME = X_SOURCE_OBJECT_NAME,
    MASTER_SOURCE_TYPE_FLAG = X_MASTER_SOURCE_TYPE_FLAG,
    SOURCE_OBJECT_PK_FIELD = X_SOURCE_OBJECT_PK_FIELD,
    ENABLED_FLAG = X_ENABLED_FLAG,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    BASED_ON_TCA_FLAG = X_BASED_ON_TCA_FLAG
  where LIST_SOURCE_TYPE_ID = X_LIST_SOURCE_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_LIST_SRC_TYPES_TL set
    LIST_SOURCE_NAME = X_LIST_SOURCE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATE_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where LIST_SOURCE_TYPE_ID = X_LIST_SOURCE_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LIST_SOURCE_TYPE_ID in NUMBER
) is
begin
  delete from AMS_LIST_SRC_TYPES_TL
  where LIST_SOURCE_TYPE_ID = X_LIST_SOURCE_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_LIST_SRC_TYPES
  where LIST_SOURCE_TYPE_ID = X_LIST_SOURCE_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

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
    SECURITY_GROUP_ID,
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
    B.SECURITY_GROUP_ID,
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

/* added by arunatar on 2nd April 2004, to find out whether the data source has some associations or not */
FUNCTION get_ams_ds_disable_delete(p_list_source_type_id in VARCHAR2)
   RETURN VARCHAR2
IS
   l_disable_delete VARCHAR2(1):='N';

  -- CURSOR SEEDED_CUR(c_list_source_type_id IN NUMBER) IS
  --          SELECT 'Y' FROM AMS_LIST_SRC_TYPES_VL
  --           WHERE p_list_source_type_id < 10000;

   CURSOR LIST_CUR(c_list_source_type_id IN NUMBER) IS
            SELECT 'Y' FROM AMS_LIST_HEADERS_ALL
             WHERE LIST_SOURCE_TYPE = (SELECT SOURCE_TYPE_CODE
              FROM AMS_LIST_SRC_TYPES
             WHERE LIST_SOURCE_TYPE_ID = c_list_source_type_id);

   CURSOR TARGET_CUR(c_list_source_type_id IN NUMBER) IS
            SELECT 'Y' FROM DUAL
             WHERE EXISTS (
               SELECT 1 FROM AMS_DM_TARGETS_VL
                WHERE DATA_SOURCE_ID = c_list_source_type_id
               UNION
               SELECT 1 FROM AMS_DM_TARGET_SOURCES
                WHERE DATA_SOURCE_ID = c_list_source_type_id );

   CURSOR QRY_TEMPL_CUR(c_list_source_type_id IN NUMBER) IS
            SELECT 'Y' FROM AMS_QUERY_TEMPLATE_ALL
             WHERE LIST_SRC_TYPE = ( SELECT SOURCE_TYPE_CODE
                                       FROM AMS_LIST_SRC_TYPES
                                      WHERE LIST_SOURCE_TYPE_ID = c_list_source_type_id);

   CURSOR DEDUP_CUR(c_list_source_type_id IN NUMBER) IS
            SELECT 'Y' FROM AMS_LIST_RULES_ALL
             WHERE LIST_SOURCE_TYPE = (SELECT SOURCE_TYPE_CODE
                                         FROM AMS_LIST_SRC_TYPES
                                        WHERE LIST_SOURCE_TYPE_ID = c_list_source_type_id);

   CURSOR ASSOCS_CUR(c_list_source_type_id IN NUMBER) IS
            SELECT DISTINCT 'Y' FROM AMS_LIST_SRC_TYPE_ASSOCS
             WHERE MASTER_SOURCE_TYPE_ID = c_list_source_type_id;

BEGIN


   IF p_list_source_type_id < 10000 then
   	l_disable_delete := 'Y';
   else
   	l_disable_delete := 'N';
   end if;

   --OPEN SEEDED_CUR(p_list_source_type_id);
   --FETCH SEEDED_CUR INTO l_disable_delete;

   --IF SEEDED_CUR%NOTFOUND THEN

   IF (l_disable_delete = 'N') THEN
      OPEN LIST_CUR(p_list_source_type_id);
      FETCH LIST_CUR INTO l_disable_delete;

      IF LIST_CUR%NOTFOUND THEN
         OPEN TARGET_CUR(p_list_source_type_id);
         FETCH TARGET_CUR INTO l_disable_delete;

         IF TARGET_CUR%NOTFOUND THEN
            OPEN QRY_TEMPL_CUR(p_list_source_type_id);
            FETCH QRY_TEMPL_CUR INTO l_disable_delete;

            IF QRY_TEMPL_CUR%NOTFOUND THEN
               OPEN DEDUP_CUR(p_list_source_type_id);
               FETCH DEDUP_CUR INTO l_disable_delete;

               IF DEDUP_CUR%NOTFOUND THEN
                  OPEN ASSOCS_CUR(p_list_source_type_id);
                  FETCH ASSOCS_CUR INTO l_disable_delete;

                  IF ASSOCS_CUR%NOTFOUND THEN
                     l_disable_delete := 'N';
                  END IF;
                  CLOSE ASSOCS_CUR;

               END IF;
               CLOSE DEDUP_CUR;

            END IF;
            CLOSE QRY_TEMPL_CUR;

         END IF;
         CLOSE TARGET_CUR;

      END IF;
      CLOSE LIST_CUR;
   END IF;
   --CLOSE SEEDED_CUR;

   RETURN l_disable_delete;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 'N';
   WHEN TOO_MANY_ROWS THEN
      RETURN 'Y';
   WHEN OTHERS THEN
      RETURN 'N';
END get_ams_ds_disable_delete;

end AMS_LIST_SRC_TYPES_NEW_PKG;

/
