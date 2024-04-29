--------------------------------------------------------
--  DDL for Package Body AMS_LIST_QUERIES_PARAM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_QUERIES_PARAM_PKG" as
/* $Header: amstlqpb.pls 120.1 2005/06/27 05:40:16 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_LIST_QUERY_PARAM_ID in NUMBER,
  X_ATTB_LOV_ID in NUMBER,
  X_PARAM_VALUE_2 in VARCHAR2,
  X_CONDITION_VALUE in VARCHAR2,
  X_PARAMETER_NAME in VARCHAR2,
  X_LIST_QUERY_ID in NUMBER,
  X_PARAMETER_ORDER in NUMBER,
  X_PARAMETER_VALUE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AMS_LIST_QUERIES_PARAM
    where LIST_QUERY_PARAM_ID = X_LIST_QUERY_PARAM_ID
    ;
begin
  insert into AMS_LIST_QUERIES_PARAM (
    ATTB_LOV_ID,
    PARAM_VALUE_2,
    CONDITION_VALUE,
    PARAMETER_NAME,
    LIST_QUERY_PARAM_ID,
    LIST_QUERY_ID,
    PARAMETER_ORDER,
    PARAMETER_VALUE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ATTB_LOV_ID,
    X_PARAM_VALUE_2,
    X_CONDITION_VALUE,
    X_PARAMETER_NAME,
    X_LIST_QUERY_PARAM_ID,
    X_LIST_QUERY_ID,
    X_PARAMETER_ORDER,
    X_PARAMETER_VALUE,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AMS_LIST_QUERIES_PARAM_TL (
    LIST_QUERY_PARAM_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DISPLAY_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LIST_QUERY_PARAM_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_DISPLAY_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_LIST_QUERIES_PARAM_TL T
    where T.LIST_QUERY_PARAM_ID = X_LIST_QUERY_PARAM_ID
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
  X_LIST_QUERY_PARAM_ID in NUMBER,
  X_ATTB_LOV_ID in NUMBER,
  X_PARAM_VALUE_2 in VARCHAR2,
  X_CONDITION_VALUE in VARCHAR2,
  X_PARAMETER_NAME in VARCHAR2,
  X_LIST_QUERY_ID in NUMBER,
  X_PARAMETER_ORDER in NUMBER,
  X_PARAMETER_VALUE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2
) is
  cursor c is select
      ATTB_LOV_ID,
      PARAM_VALUE_2,
      CONDITION_VALUE,
      PARAMETER_NAME,
      LIST_QUERY_ID,
      PARAMETER_ORDER,
      PARAMETER_VALUE,
      OBJECT_VERSION_NUMBER
    from AMS_LIST_QUERIES_PARAM
    where LIST_QUERY_PARAM_ID = X_LIST_QUERY_PARAM_ID
    for update of LIST_QUERY_PARAM_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMS_LIST_QUERIES_PARAM_TL
    where LIST_QUERY_PARAM_ID = X_LIST_QUERY_PARAM_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of LIST_QUERY_PARAM_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTB_LOV_ID = X_ATTB_LOV_ID)
           OR ((recinfo.ATTB_LOV_ID is null) AND (X_ATTB_LOV_ID is null)))
      AND ((recinfo.PARAM_VALUE_2 = X_PARAM_VALUE_2)
           OR ((recinfo.PARAM_VALUE_2 is null) AND (X_PARAM_VALUE_2 is null)))
      AND ((recinfo.CONDITION_VALUE = X_CONDITION_VALUE)
           OR ((recinfo.CONDITION_VALUE is null) AND (X_CONDITION_VALUE is null)))
      AND ((recinfo.PARAMETER_NAME = X_PARAMETER_NAME)
           OR ((recinfo.PARAMETER_NAME is null) AND (X_PARAMETER_NAME is null)))
      AND (recinfo.LIST_QUERY_ID = X_LIST_QUERY_ID)
      AND (recinfo.PARAMETER_ORDER = X_PARAMETER_ORDER)
      AND ((recinfo.PARAMETER_VALUE = X_PARAMETER_VALUE)
           OR ((recinfo.PARAMETER_VALUE is null) AND (X_PARAMETER_VALUE is null)))
      --AND (recinfo.PARAMETER_VALUE = X_PARAMETER_VALUE)
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_NAME = X_DISPLAY_NAME)
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
  X_LIST_QUERY_PARAM_ID in NUMBER,
  X_ATTB_LOV_ID in NUMBER,
  X_PARAM_VALUE_2 in VARCHAR2,
  X_CONDITION_VALUE in VARCHAR2,
  X_PARAMETER_NAME in VARCHAR2,
  X_LIST_QUERY_ID in NUMBER,
  X_PARAMETER_ORDER in NUMBER,
  X_PARAMETER_VALUE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_LIST_QUERIES_PARAM set
    ATTB_LOV_ID = X_ATTB_LOV_ID,
    PARAM_VALUE_2 = X_PARAM_VALUE_2,
    CONDITION_VALUE = X_CONDITION_VALUE,
    PARAMETER_NAME = X_PARAMETER_NAME,
    LIST_QUERY_ID = X_LIST_QUERY_ID,
    PARAMETER_ORDER = X_PARAMETER_ORDER,
    PARAMETER_VALUE = X_PARAMETER_VALUE,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where LIST_QUERY_PARAM_ID = X_LIST_QUERY_PARAM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_LIST_QUERIES_PARAM_TL set
    DISPLAY_NAME = X_DISPLAY_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where LIST_QUERY_PARAM_ID = X_LIST_QUERY_PARAM_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LIST_QUERY_PARAM_ID in NUMBER
) is
begin
  delete from AMS_LIST_QUERIES_PARAM_TL
  where LIST_QUERY_PARAM_ID = X_LIST_QUERY_PARAM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_LIST_QUERIES_PARAM
  where LIST_QUERY_PARAM_ID = X_LIST_QUERY_PARAM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_LIST_QUERIES_PARAM_TL T
  where not exists
    (select NULL
    from AMS_LIST_QUERIES_PARAM B
    where B.LIST_QUERY_PARAM_ID = T.LIST_QUERY_PARAM_ID
    );

  update AMS_LIST_QUERIES_PARAM_TL T set (
      DISPLAY_NAME
    ) = (select
      B.DISPLAY_NAME
    from AMS_LIST_QUERIES_PARAM_TL B
    where B.LIST_QUERY_PARAM_ID = T.LIST_QUERY_PARAM_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LIST_QUERY_PARAM_ID,
      T.LANGUAGE
  ) in (select
      SUBT.LIST_QUERY_PARAM_ID,
      SUBT.LANGUAGE
    from AMS_LIST_QUERIES_PARAM_TL SUBB, AMS_LIST_QUERIES_PARAM_TL SUBT
    where SUBB.LIST_QUERY_PARAM_ID = SUBT.LIST_QUERY_PARAM_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
  ));

  insert into AMS_LIST_QUERIES_PARAM_TL (
    LIST_QUERY_PARAM_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DISPLAY_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.LIST_QUERY_PARAM_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.DISPLAY_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_LIST_QUERIES_PARAM_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_LIST_QUERIES_PARAM_TL T
    where T.LIST_QUERY_PARAM_ID = B.LIST_QUERY_PARAM_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure INSERT_ROW (
  X_LIST_QUERY_PARAM_ID in NUMBER,
  X_ATTB_LOV_ID in NUMBER,
  X_PARAM_VALUE_2 in VARCHAR2,
  X_CONDITION_VALUE in VARCHAR2,
  X_PARAMETER_NAME in VARCHAR2,
  X_LIST_QUERY_ID in NUMBER,
  X_PARAMETER_ORDER in NUMBER,
  X_PARAMETER_VALUE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_DISPLAY_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER

) is
begin
  insert into AMS_LIST_QUERIES_PARAM (
    ATTB_LOV_ID,
    PARAM_VALUE_2,
    CONDITION_VALUE,
    PARAMETER_NAME,
    LIST_QUERY_PARAM_ID,
    LIST_QUERY_ID,
    PARAMETER_ORDER,
    PARAMETER_VALUE,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_ATTB_LOV_ID,
    X_PARAM_VALUE_2,
    X_CONDITION_VALUE,
    X_PARAMETER_NAME,
    X_LIST_QUERY_PARAM_ID,
    X_LIST_QUERY_ID,
    X_PARAMETER_ORDER,
    X_PARAMETER_VALUE,
    X_OBJECT_VERSION_NUMBER,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AMS_LIST_QUERIES_PARAM_TL (
    LIST_QUERY_PARAM_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DISPLAY_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LIST_QUERY_PARAM_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_DISPLAY_NAME,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_LIST_QUERIES_PARAM_TL T
    where T.LIST_QUERY_PARAM_ID = X_LIST_QUERY_PARAM_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end INSERT_ROW;


PROCEDURE LOAD_ROW (
  X_LIST_QUERY_PARAM_ID in NUMBER,
  X_ATTB_LOV_ID in NUMBER,
  X_PARAM_VALUE_2 in VARCHAR2,
  X_CONDITION_VALUE in VARCHAR2,
  X_PARAMETER_NAME in VARCHAR2,
  X_LIST_QUERY_ID in NUMBER,
  X_PARAMETER_ORDER in NUMBER,
  X_PARAMETER_VALUE in VARCHAR2,
  X_DISPLAY_NAME in VARCHAR2,
  x_owner IN VARCHAR2,
  x_custom_mode IN VARCHAR2
)
IS
   l_user_id   number := 0;
   l_obj_verno  number;
   l_dummy_char  varchar2(1);
   l_row_id    varchar2(100);
   l_LIST_QUERY_PARAM_ID   number;
   l_last_updated_by number;

   CURSOR  c_obj_verno IS
     SELECT object_version_number, last_updated_by
     FROM   AMS_LIST_QUERIES_PARAM
     WHERE  LIST_QUERY_PARAM_ID =  X_LIST_QUERY_PARAM_ID;

   CURSOR c_chk_exists is
     SELECT 'x'
     FROM   AMS_LIST_QUERIES_PARAM
     WHERE  LIST_QUERY_PARAM_ID = X_LIST_QUERY_PARAM_ID;

   CURSOR c_get_id is
      SELECT AMS_LIST_QUERIES_PARAM_S.NEXTVAL
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

      IF X_LIST_QUERY_PARAM_ID IS NULL THEN
         OPEN c_get_id;
         FETCH c_get_id INTO l_LIST_QUERY_PARAM_ID;
         CLOSE c_get_id;
      ELSE
         l_LIST_QUERY_PARAM_ID := X_LIST_QUERY_PARAM_ID;
      END IF;

      l_obj_verno := 1;

      AMS_LIST_QUERIES_PARAM_PKG.INSERT_ROW (
          X_LIST_QUERY_PARAM_ID => x_list_query_param_id,
          X_ATTB_LOV_ID => x_attb_lov_id,
          X_PARAM_VALUE_2 => X_PARAM_VALUE_2 ,
          X_CONDITION_VALUE => X_CONDITION_VALUE ,
          X_PARAMETER_NAME => X_PARAMETER_NAME  ,
          X_LIST_QUERY_ID => X_LIST_QUERY_ID ,
          X_PARAMETER_ORDER => X_PARAMETER_ORDER  ,
          X_PARAMETER_VALUE => X_PARAMETER_VALUE   ,
          X_OBJECT_VERSION_NUMBER => l_obj_verno  ,
          X_DISPLAY_NAME => X_DISPLAY_NAME  ,
          X_creation_date            => SYSDATE,
          X_created_by               => l_user_id,
          X_last_update_date         => SYSDATE,
          X_last_updated_by          => l_user_id,
          X_last_update_login        => 0
        ) ;
   ELSE
      CLOSE c_chk_exists;
      OPEN c_obj_verno;
      FETCH c_obj_verno INTO l_obj_verno, l_last_updated_by;
      CLOSE c_obj_verno;

  if (l_last_updated_by in (1,2,0) OR
          NVL(x_custom_mode,'PRESERVE')='FORCE') THEN

      AMS_LIST_QUERIES_PARAM_PKG.UPDATE_ROW (
          X_LIST_QUERY_PARAM_ID => x_list_query_param_id,
          X_ATTB_LOV_ID => x_attb_lov_id,
          X_PARAM_VALUE_2 => X_PARAM_VALUE_2 ,
          X_CONDITION_VALUE => X_CONDITION_VALUE ,
          X_PARAMETER_NAME => X_PARAMETER_NAME  ,
          X_LIST_QUERY_ID => X_LIST_QUERY_ID ,
          X_PARAMETER_ORDER => X_PARAMETER_ORDER  ,
          X_PARAMETER_VALUE => X_PARAMETER_VALUE   ,
          X_OBJECT_VERSION_NUMBER => l_obj_verno  ,
          X_DISPLAY_NAME => X_DISPLAY_NAME  ,
          X_last_update_date         => SYSDATE,
          X_last_updated_by          => l_user_id,
          X_last_update_login        => 0
        ) ;

    end if;

   END IF;
END LOAD_ROW;

PROCEDURE TRANSLATE_ROW (
  X_LIST_QUERY_PARAM_ID     IN NUMBER,
  X_DISPLAY_NAME            IN VARCHAR2,
  X_OWNER                   IN VARCHAR2,
  x_custom_mode		    IN VARCHAR2
) IS

   cursor c_last_updated_by is
                 select last_updated_by
                 FROM AMS_LIST_QUERIES_PARAM_TL
                 where  LIST_QUERY_PARAM_ID =  x_LIST_QUERY_PARAM_ID
                 and  USERENV('LANG') = LANGUAGE;

       l_last_updated_by number;

BEGIN
    -- only UPDATE rows that have not been altered by user

open c_last_updated_by;
 fetch c_last_updated_by into l_last_updated_by;
 close c_last_updated_by;

 if (l_last_updated_by in (1,2,0) OR
	NVL(x_custom_mode,'PRESERVE')='FORCE') THEN


    UPDATE AMS_LIST_QUERIES_PARAM_TL
    SET
        DISPLAY_NAME = NVL(X_DISPLAY_NAME, DISPLAY_NAME),
        SOURCE_LANG = userenv('LANG'),
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = decode(x_owner, 'SEED', 1, 'ORACLE',2, 'SYSADMIN',0, -1),
        LAST_UPDATE_LOGIN = 0
    WHERE LIST_QUERY_PARAM_ID = X_LIST_QUERY_PARAM_ID
    AND   userenv('LANG') IN (language, source_lang);


 end if;
END TRANSLATE_ROW;

end AMS_LIST_QUERIES_PARAM_PKG;

/
