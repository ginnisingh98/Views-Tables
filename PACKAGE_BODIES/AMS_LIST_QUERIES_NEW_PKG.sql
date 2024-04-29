--------------------------------------------------------
--  DDL for Package Body AMS_LIST_QUERIES_NEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_QUERIES_NEW_PKG" as
/* $Header: amstlqrb.pls 120.2.12000000.2 2007/07/02 05:05:43 rsatyava ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_LIST_QUERY_ID in NUMBER,
  X_QUERY_TEMPLATE_ID in NUMBER,
  X_OWNER_USER_ID in NUMBER,
  X_QUERY_TYPE in VARCHAR2,
  X_ACT_LIST_QUERY_USED_BY_ID in NUMBER,
  X_ARC_ACT_LIST_QUERY_USED_BY in VARCHAR2,
  X_SEED_FLAG in VARCHAR2,
  X_SQL_STRING in VARCHAR2,
  X_SOURCE_OBJECT_NAME in VARCHAR2,
  X_PARENT_LIST_QUERY_ID in NUMBER,
  X_SEQUENCE_ORDER in NUMBER,
  X_PARAMETERIZED_FLAG in VARCHAR2,
  X_ADMIN_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TYPE in VARCHAR2,
  X_QUERY in LONG,
  X_ENABLED_FLAG in VARCHAR2,
  X_PRIMARY_KEY in VARCHAR2,
  X_PUBLIC_FLAG in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AMS_LIST_QUERIES_ALL
    where LIST_QUERY_ID = X_LIST_QUERY_ID
    ;
begin
  insert into AMS_LIST_QUERIES_ALL (
    QUERY_TEMPLATE_ID,
    OWNER_USER_ID,
    QUERY_TYPE,
    ACT_LIST_QUERY_USED_BY_ID,
    ARC_ACT_LIST_QUERY_USED_BY,
    SEED_FLAG,
    SQL_STRING,
    SOURCE_OBJECT_NAME,
    PARENT_LIST_QUERY_ID,
    SEQUENCE_ORDER,
    PARAMETERIZED_FLAG,
    ADMIN_FLAG,
    LIST_QUERY_ID,
    OBJECT_VERSION_NUMBER,
    TYPE,
    QUERY,
    ENABLED_FLAG,
    PRIMARY_KEY,
    PUBLIC_FLAG,
    COMMENTS,
    SECURITY_GROUP_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_QUERY_TEMPLATE_ID,
    X_OWNER_USER_ID,
    X_QUERY_TYPE,
    X_ACT_LIST_QUERY_USED_BY_ID,
    X_ARC_ACT_LIST_QUERY_USED_BY,
    X_SEED_FLAG,
    X_SQL_STRING,
    X_SOURCE_OBJECT_NAME,
    X_PARENT_LIST_QUERY_ID,
    X_SEQUENCE_ORDER,
    X_PARAMETERIZED_FLAG,
    X_ADMIN_FLAG,
    X_LIST_QUERY_ID,
    X_OBJECT_VERSION_NUMBER,
    X_TYPE,
--    X_QUERY,
 --bmuthukr. Bug 5334951
--   NVL(X_QUERY,X_SQL_STRING),
--  rsatyava.Bug 5647356
     X_QUERY,
    X_ENABLED_FLAG,
    X_PRIMARY_KEY,
    X_PUBLIC_FLAG,
    X_COMMENTS,
    X_SECURITY_GROUP_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AMS_LIST_QUERIES_TL (
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    LIST_QUERY_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_NAME,
    X_DESCRIPTION,
    X_LIST_QUERY_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_LIST_QUERIES_TL T
    where T.LIST_QUERY_ID = X_LIST_QUERY_ID
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
  X_LIST_QUERY_ID in NUMBER,
  X_QUERY_TEMPLATE_ID in NUMBER,
  X_OWNER_USER_ID in NUMBER,
  X_QUERY_TYPE in VARCHAR2,
  X_ACT_LIST_QUERY_USED_BY_ID in NUMBER,
  X_ARC_ACT_LIST_QUERY_USED_BY in VARCHAR2,
  X_SEED_FLAG in VARCHAR2,
  X_SQL_STRING in VARCHAR2,
  X_SOURCE_OBJECT_NAME in VARCHAR2,
  X_PARENT_LIST_QUERY_ID in NUMBER,
  X_SEQUENCE_ORDER in NUMBER,
  X_PARAMETERIZED_FLAG in VARCHAR2,
  X_ADMIN_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TYPE in VARCHAR2,
  X_QUERY in LONG,
  X_ENABLED_FLAG in VARCHAR2,
  X_PRIMARY_KEY in VARCHAR2,
  X_PUBLIC_FLAG in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      QUERY_TEMPLATE_ID,
      OWNER_USER_ID,
      QUERY_TYPE,
      ACT_LIST_QUERY_USED_BY_ID,
      ARC_ACT_LIST_QUERY_USED_BY,
      SEED_FLAG,
      SQL_STRING,
      SOURCE_OBJECT_NAME,
      PARENT_LIST_QUERY_ID,
      SEQUENCE_ORDER,
      PARAMETERIZED_FLAG,
      ADMIN_FLAG,
      OBJECT_VERSION_NUMBER,
      TYPE,
      QUERY,
      ENABLED_FLAG,
      PRIMARY_KEY,
      PUBLIC_FLAG,
      COMMENTS,
      SECURITY_GROUP_ID
    from AMS_LIST_QUERIES_ALL
    where LIST_QUERY_ID = X_LIST_QUERY_ID
    for update of LIST_QUERY_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMS_LIST_QUERIES_TL
    where LIST_QUERY_ID = X_LIST_QUERY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of LIST_QUERY_ID nowait;
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
      AND ((recinfo.OWNER_USER_ID = X_OWNER_USER_ID)
           OR ((recinfo.OWNER_USER_ID is null) AND (X_OWNER_USER_ID is null)))
      AND ((recinfo.QUERY_TYPE = X_QUERY_TYPE)
           OR ((recinfo.QUERY_TYPE is null) AND (X_QUERY_TYPE is null)))
      AND ((recinfo.ACT_LIST_QUERY_USED_BY_ID = X_ACT_LIST_QUERY_USED_BY_ID)
           OR ((recinfo.ACT_LIST_QUERY_USED_BY_ID is null) AND (X_ACT_LIST_QUERY_USED_BY_ID is null)))
      AND ((recinfo.ARC_ACT_LIST_QUERY_USED_BY = X_ARC_ACT_LIST_QUERY_USED_BY)
           OR ((recinfo.ARC_ACT_LIST_QUERY_USED_BY is null) AND (X_ARC_ACT_LIST_QUERY_USED_BY is null)))
      AND ((recinfo.SEED_FLAG = X_SEED_FLAG)
           OR ((recinfo.SEED_FLAG is null) AND (X_SEED_FLAG is null)))
      AND ((recinfo.SQL_STRING = X_SQL_STRING)
           OR ((recinfo.SQL_STRING is null) AND (X_SQL_STRING is null)))
      AND ((recinfo.SOURCE_OBJECT_NAME = X_SOURCE_OBJECT_NAME)
           OR ((recinfo.SOURCE_OBJECT_NAME is null) AND (X_SOURCE_OBJECT_NAME is null)))
      AND ((recinfo.PARENT_LIST_QUERY_ID = X_PARENT_LIST_QUERY_ID)
           OR ((recinfo.PARENT_LIST_QUERY_ID is null) AND (X_PARENT_LIST_QUERY_ID is null)))
      AND ((recinfo.SEQUENCE_ORDER = X_SEQUENCE_ORDER)
           OR ((recinfo.SEQUENCE_ORDER is null) AND (X_SEQUENCE_ORDER is null)))
      AND ((recinfo.PARAMETERIZED_FLAG = X_PARAMETERIZED_FLAG)
           OR ((recinfo.PARAMETERIZED_FLAG is null) AND (X_PARAMETERIZED_FLAG is null)))
      AND ((recinfo.ADMIN_FLAG = X_ADMIN_FLAG)
           OR ((recinfo.ADMIN_FLAG is null) AND (X_ADMIN_FLAG is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.TYPE = X_TYPE)
           OR ((recinfo.TYPE is null) AND (X_TYPE is null)))
      AND ((recinfo.QUERY = X_QUERY)
           OR ((recinfo.QUERY is null) AND (X_QUERY is null)))
      AND ((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
           OR ((recinfo.ENABLED_FLAG is null) AND (X_ENABLED_FLAG is null)))
      AND ((recinfo.PRIMARY_KEY = X_PRIMARY_KEY)
           OR ((recinfo.PRIMARY_KEY is null) AND (X_PRIMARY_KEY is null)))
      AND ((recinfo.PUBLIC_FLAG = X_PUBLIC_FLAG)
           OR ((recinfo.PUBLIC_FLAG is null) AND (X_PUBLIC_FLAG is null)))
      AND ((recinfo.COMMENTS = X_COMMENTS)
           OR ((recinfo.COMMENTS is null) AND (X_COMMENTS is null)))
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
      if (    (tlinfo.NAME = X_NAME)
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
  X_LIST_QUERY_ID in NUMBER,
  X_QUERY_TEMPLATE_ID in NUMBER,
  X_OWNER_USER_ID in NUMBER,
  X_QUERY_TYPE in VARCHAR2,
  X_ACT_LIST_QUERY_USED_BY_ID in NUMBER,
  X_ARC_ACT_LIST_QUERY_USED_BY in VARCHAR2,
  X_SEED_FLAG in VARCHAR2,
  X_SQL_STRING in VARCHAR2,
  X_SOURCE_OBJECT_NAME in VARCHAR2,
  X_PARENT_LIST_QUERY_ID in NUMBER,
  X_SEQUENCE_ORDER in NUMBER,
  X_PARAMETERIZED_FLAG in VARCHAR2,
  X_ADMIN_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_TYPE in VARCHAR2,
  X_QUERY in LONG,
  X_ENABLED_FLAG in VARCHAR2,
  X_PRIMARY_KEY in VARCHAR2,
  X_PUBLIC_FLAG in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_LIST_QUERIES_ALL set
    QUERY_TEMPLATE_ID = X_QUERY_TEMPLATE_ID,
    OWNER_USER_ID = X_OWNER_USER_ID,
    QUERY_TYPE = X_QUERY_TYPE,
    ACT_LIST_QUERY_USED_BY_ID = X_ACT_LIST_QUERY_USED_BY_ID,
    ARC_ACT_LIST_QUERY_USED_BY = X_ARC_ACT_LIST_QUERY_USED_BY,
    SEED_FLAG = X_SEED_FLAG,
    SQL_STRING = X_SQL_STRING,
    SOURCE_OBJECT_NAME = X_SOURCE_OBJECT_NAME,
    PARENT_LIST_QUERY_ID = X_PARENT_LIST_QUERY_ID,
    SEQUENCE_ORDER = X_SEQUENCE_ORDER,
    PARAMETERIZED_FLAG = X_PARAMETERIZED_FLAG,
    ADMIN_FLAG = X_ADMIN_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    TYPE = X_TYPE,
    --QUERY = X_QUERY,
 --bmuthukr. Bug 5334951
    QUERY = NVL(X_QUERY,X_SQL_STRING),
    ENABLED_FLAG = X_ENABLED_FLAG,
    PRIMARY_KEY = X_PRIMARY_KEY,
    PUBLIC_FLAG = X_PUBLIC_FLAG,
    COMMENTS = X_COMMENTS,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where LIST_QUERY_ID = X_LIST_QUERY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_LIST_QUERIES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where LIST_QUERY_ID = X_LIST_QUERY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


procedure DELETE_ROW (
  X_LIST_QUERY_ID in NUMBER
) is
begin
  delete from AMS_LIST_QUERIES_TL
  where LIST_QUERY_ID = X_LIST_QUERY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_LIST_QUERIES_ALL
  where LIST_QUERY_ID = X_LIST_QUERY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


PROCEDURE LOAD_ROW (
  X_LIST_QUERY_ID in NUMBER,
  X_QUERY_TEMPLATE_ID in NUMBER,
  X_OWNER_USER_ID in NUMBER,
  X_QUERY_TYPE in VARCHAR2,
  X_ACT_LIST_QUERY_USED_BY_ID in NUMBER,
  X_ARC_ACT_LIST_QUERY_USED_BY in VARCHAR2,
  X_SEED_FLAG in VARCHAR2,
  X_SQL_STRING in VARCHAR2,
  X_SOURCE_OBJECT_NAME in VARCHAR2,
  X_PARENT_LIST_QUERY_ID in NUMBER,
  X_SEQUENCE_ORDER in NUMBER,
  X_PARAMETERIZED_FLAG in VARCHAR2,
  X_ADMIN_FLAG in VARCHAR2,
  X_TYPE in VARCHAR2,
  X_QUERY in LONG,
  X_ENABLED_FLAG in VARCHAR2,
  X_PRIMARY_KEY in VARCHAR2,
  X_PUBLIC_FLAG in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  x_owner IN VARCHAR2,
  x_custom_mode IN VARCHAR2
)
IS
   l_user_id   number := 0;
   l_obj_verno  number;
   l_dummy_char  varchar2(1);
   l_row_id    varchar2(100);
   l_LIST_QUERY_ID   number;
   l_last_updated_by number;

   CURSOR  c_obj_verno IS
     SELECT object_version_number, last_updated_by
     FROM   AMS_LIST_QUERIES_ALL
     WHERE  LIST_QUERY_ID =  X_LIST_QUERY_ID;

   CURSOR c_chk_exists is
     SELECT 'x'
     FROM   AMS_LIST_QUERIES_ALL
     WHERE  LIST_QUERY_ID = X_LIST_QUERY_ID;

   CURSOR c_get_id is
      SELECT AMS_LIST_QUERIES_ALL_S.NEXTVAL
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

      IF X_LIST_QUERY_ID IS NULL THEN
         OPEN c_get_id;
         FETCH c_get_id INTO l_LIST_QUERY_ID;
         CLOSE c_get_id;
      ELSE
         l_LIST_QUERY_ID := X_LIST_QUERY_ID;
      END IF;

      l_obj_verno := 1;

      AMS_LIST_QUERIES_NEW_PKG.Insert_Row (
         X_ROWID                      => l_row_id,
         X_LIST_QUERY_ID             => l_LIST_QUERY_ID,
         X_QUERY_TEMPLATE_ID         => X_QUERY_TEMPLATE_ID,
         X_OWNER_USER_ID             => X_OWNER_USER_ID,
         X_QUERY_TYPE                => X_QUERY_TYPE,
         X_ACT_LIST_QUERY_USED_BY_ID  => X_ACT_LIST_QUERY_USED_BY_ID,
         X_ARC_ACT_LIST_QUERY_USED_BY => X_ARC_ACT_LIST_QUERY_USED_BY,
         X_SEED_FLAG                  => X_SEED_FLAG,
	 X_SQL_STRING                 =>  X_SQL_STRING,
         X_SOURCE_OBJECT_NAME          => X_SOURCE_OBJECT_NAME,
         X_PARENT_LIST_QUERY_ID        => X_PARENT_LIST_QUERY_ID,
	 X_SEQUENCE_ORDER              => X_SEQUENCE_ORDER,
         X_PARAMETERIZED_FLAG          => X_PARAMETERIZED_FLAG,
	 X_ADMIN_FLAG                  => X_ADMIN_FLAG,
         X_OBJECT_VERSION_NUMBER       => l_obj_verno,
	 X_TYPE                        =>X_TYPE,
	 X_QUERY                       =>X_QUERY,
	 X_ENABLED_FLAG                =>X_ENABLED_FLAG,
	 X_PRIMARY_KEY                 =>X_PRIMARY_KEY,
	 X_PUBLIC_FLAG                 =>null,
	 X_COMMENTS                    =>null,
 	 X_SECURITY_GROUP_ID        => 0,
	 X_NAME                        =>X_NAME,
	 X_DESCRIPTION                 =>X_DESCRIPTION,
         X_creation_date            => SYSDATE,
         X_created_by               => l_user_id,
         X_last_update_date         => SYSDATE,
         X_last_updated_by          => l_user_id,
         X_last_update_login        => 0
      );
   ELSE
      CLOSE c_chk_exists;
      OPEN c_obj_verno;
      FETCH c_obj_verno INTO l_obj_verno, l_last_updated_by;
      CLOSE c_obj_verno;


   if (l_last_updated_by in (1,2,0) OR
          NVL(x_custom_mode,'PRESERVE')='FORCE') THEN

      AMS_LIST_QUERIES_NEW_PKG.Update_Row (
         X_LIST_QUERY_ID             => x_LIST_QUERY_ID,
         X_QUERY_TEMPLATE_ID         => X_QUERY_TEMPLATE_ID,
         X_OWNER_USER_ID             => X_OWNER_USER_ID,
         X_QUERY_TYPE                => X_QUERY_TYPE,
         X_ACT_LIST_QUERY_USED_BY_ID  => X_ACT_LIST_QUERY_USED_BY_ID,
         X_ARC_ACT_LIST_QUERY_USED_BY => X_ARC_ACT_LIST_QUERY_USED_BY,
         X_SEED_FLAG                  => X_SEED_FLAG,
	 X_SQL_STRING                 => X_SQL_STRING,
         X_SOURCE_OBJECT_NAME          => X_SOURCE_OBJECT_NAME,
         X_PARENT_LIST_QUERY_ID        => X_PARENT_LIST_QUERY_ID,
	 X_SEQUENCE_ORDER              => X_SEQUENCE_ORDER,
         X_PARAMETERIZED_FLAG          => X_PARAMETERIZED_FLAG,
	 X_ADMIN_FLAG                  => X_ADMIN_FLAG,
         X_OBJECT_VERSION_NUMBER       => l_obj_verno,
	 X_TYPE                        =>X_TYPE,
	 X_QUERY                       =>X_QUERY,
	 X_ENABLED_FLAG                =>X_ENABLED_FLAG,
	 X_PRIMARY_KEY                 =>X_PRIMARY_KEY,
	 X_PUBLIC_FLAG                 =>null,
	 X_COMMENTS                    =>null,
 	 X_SECURITY_GROUP_ID        => 0,
	 X_NAME                        =>X_NAME,
	 X_DESCRIPTION                 =>X_DESCRIPTION,
         X_last_update_date         => SYSDATE,
         X_last_updated_by          => l_user_id,
         X_last_update_login        => 0
      );

    end if;
   END IF;
END LOAD_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_LIST_QUERIES_TL T
  where not exists
    (select NULL
    from AMS_LIST_QUERIES_ALL B
    where B.LIST_QUERY_ID = T.LIST_QUERY_ID
    );

  update AMS_LIST_QUERIES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from AMS_LIST_QUERIES_TL B
    where B.LIST_QUERY_ID = T.LIST_QUERY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LIST_QUERY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.LIST_QUERY_ID,
      SUBT.LANGUAGE
    from AMS_LIST_QUERIES_TL SUBB, AMS_LIST_QUERIES_TL SUBT
    where SUBB.LIST_QUERY_ID = SUBT.LIST_QUERY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_LIST_QUERIES_TL (
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    NAME,
    DESCRIPTION,
    LIST_QUERY_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.NAME,
    B.DESCRIPTION,
    B.LIST_QUERY_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_LIST_QUERIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_LIST_QUERIES_TL T
    where T.LIST_QUERY_ID = B.LIST_QUERY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  X_LIST_QUERY_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  x_owner   in VARCHAR2,
  x_custom_mode in VARCHAR2
 )  is

  cursor c_last_updated_by is
	  select last_updated_by
	  FROM AMS_LIST_QUERIES_TL
	  where  LIST_QUERY_ID =  x_LIST_QUERY_ID
	  and  USERENV('LANG') = LANGUAGE;

l_last_updated_by number;

begin


     open c_last_updated_by;
     fetch c_last_updated_by into l_last_updated_by;
     close c_last_updated_by;

     if (l_last_updated_by in (1,2,0) OR
            NVL(x_custom_mode,'PRESERVE')='FORCE') THEN

	    update AMS_LIST_QUERIES_TL set
	       NAME= nvl(X_NAME, NAME),
	       DESCRIPTION= nvl(X_DESCRIPTION, DESCRIPTION),
	       source_lang = userenv('LANG'),
	       last_update_date = sysdate,
	       last_updated_by = decode(x_owner, 'SEED', 1, 'ORACLE',2, 'SYSADMIN',0, -1),
	       last_update_login = 0
	    where  LIST_QUERY_ID = X_LIST_QUERY_ID
	    and      userenv('LANG') in (language, source_lang);
     end if;

end TRANSLATE_ROW;



end AMS_LIST_QUERIES_NEW_PKG;

/
