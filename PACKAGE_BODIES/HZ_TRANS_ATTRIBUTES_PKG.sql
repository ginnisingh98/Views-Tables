--------------------------------------------------------
--  DDL for Package Body HZ_TRANS_ATTRIBUTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_TRANS_ATTRIBUTES_PKG" AS
/*$Header: ARHDQTAB.pls 120.6 2005/10/30 04:19:24 appldev noship $ */

procedure INSERT_ROW (
  X_ATTRIBUTE_ID in OUT NOCOPY NUMBER,
  X_ENTITY_NAME in VARCHAR2,
  X_CUSTOM_ATTRIBUTE_PROCEDURE in VARCHAR2,
  X_SOURCE_TABLE in VARCHAR2,
  X_ATTRIBUTE_NAME in VARCHAR2,
  X_USER_DEFINED_ATTRIBUTE_NAME in VARCHAR2,
  x_DENORM_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
   CURSOR C2 IS SELECT  HZ_TRANS_ATTRIBUTES_s.nextval FROM sys.dual;
  l_success VARCHAR2(1) := 'N';
begin
 WHILE l_success = 'N' LOOP
   BEGIN
      IF ( X_ATTRIBUTE_ID IS NULL) OR (X_ATTRIBUTE_ID = FND_API.G_MISS_NUM) THEN
         OPEN C2;
         FETCH C2 INTO X_ATTRIBUTE_ID;
         CLOSE C2;
      END IF;

      insert into HZ_TRANS_ATTRIBUTES_B (
       ATTRIBUTE_ID,
       ATTRIBUTE_NAME,
       ENTITY_NAME,
       CUSTOM_ATTRIBUTE_PROCEDURE,
       SOURCE_TABLE,
       DENORM_FLAG,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       OBJECT_VERSION_NUMBER
        ) values (
       X_ATTRIBUTE_ID,
       X_ATTRIBUTE_NAME,
       X_ENTITY_NAME,
       X_CUSTOM_ATTRIBUTE_PROCEDURE,
       X_SOURCE_TABLE,
       X_DENORM_FLAG,
       X_CREATION_DATE,
       X_CREATED_BY,
       X_LAST_UPDATE_DATE,
       X_LAST_UPDATED_BY,
       X_LAST_UPDATE_LOGIN,
       1
     );

      l_success := 'Y';
      EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
         IF INSTRB( SQLERRM, 'HZ_TRANS_ATTRIBUTES_B_U1' ) <> 0 THEN
            DECLARE
              l_count             NUMBER;
              l_dummy             VARCHAR2(1);
            BEGIN
              l_count := 1;
              WHILE l_count > 0 LOOP
                 SELECT  HZ_TRANS_ATTRIBUTES_s.nextval
		  into  X_ATTRIBUTE_ID FROM sys.dual;
                 BEGIN
                  SELECT 'Y' INTO l_dummy
                  FROM HZ_TRANS_ATTRIBUTES_B
                  WHERE ATTRIBUTE_ID =  X_ATTRIBUTE_ID;
                  l_count := 1;
                 EXCEPTION WHEN NO_DATA_FOUND THEN
                  l_count := 0;
                 END;
             END LOOP;
          END;
        END IF;
     END;
  END LOOP;

   insert into HZ_TRANS_ATTRIBUTES_TL (
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    USER_DEFINED_ATTRIBUTE_NAME,
    ATTRIBUTE_ID,
    LANGUAGE,
    SOURCE_LANG,
    OBJECT_VERSION_NUMBER
  ) select
    X_LAST_UPDATE_DATE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_USER_DEFINED_ATTRIBUTE_NAME,
    X_ATTRIBUTE_ID,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    1
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from HZ_TRANS_ATTRIBUTES_TL T
    where T.ATTRIBUTE_ID = X_ATTRIBUTE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end INSERT_ROW;

procedure LOCK_ROW (
  X_ATTRIBUTE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER IN number
) is
  cursor c is select
      OBJECT_VERSION_NUMBER
    from HZ_TRANS_ATTRIBUTES_B
    where ATTRIBUTE_ID = X_ATTRIBUTE_ID
    for update of ATTRIBUTE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      OBJECT_VERSION_NUMBER,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from HZ_TRANS_ATTRIBUTES_TL
    where ATTRIBUTE_ID = X_ATTRIBUTE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ATTRIBUTE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if ( ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
               OR ((tlinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
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


procedure LOCK_ROW (
  X_ATTRIBUTE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER IN number,
  X_USER_DEFINED_ATTRIBUTE_NAME IN varchar2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER
    from HZ_TRANS_ATTRIBUTES_B
    where ATTRIBUTE_ID = X_ATTRIBUTE_ID
    for update of ATTRIBUTE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      USER_DEFINED_ATTRIBUTE_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from HZ_TRANS_ATTRIBUTES_TL
    where ATTRIBUTE_ID = X_ATTRIBUTE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ATTRIBUTE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if ( ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.USER_DEFINED_ATTRIBUTE_NAME = X_USER_DEFINED_ATTRIBUTE_NAME)
               OR ((tlinfo.USER_DEFINED_ATTRIBUTE_NAME is null) AND (X_USER_DEFINED_ATTRIBUTE_NAME is null)))
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
  X_ATTRIBUTE_ID in NUMBER,
  X_ENTITY_NAME in VARCHAR2,
  X_CUSTOM_ATTRIBUTE_PROCEDURE in VARCHAR2,
  X_SOURCE_TABLE in VARCHAR2,
  X_ATTRIBUTE_NAME in VARCHAR2,
  X_USER_DEFINED_ATTRIBUTE_NAME in VARCHAR2,
  X_DENORM_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER IN out nocopy NUMBER
) is

  l_object_version_number number;
  l_db_atr_name VARCHAR2(255);
  l_db_user_def_atr VARCHAR2(255);
  l_db_cus_atr_proc VARCHAR2(600);
  l_db_upd_by NUMBER;
  l_db_denorm_flag VARCHAR2(1);
  TMP NUMBER;
begin

  SELECT 1 INTO TMP FROM HZ_TRANS_ATTRIBUTES_VL
  where attribute_id=X_ATTRIBUTE_ID;

  l_object_version_number := NVL(X_object_version_number, 1) + 1;

  select ATTRIBUTE_NAME, USER_DEFINED_ATTRIBUTE_NAME,
         CUSTOM_ATTRIBUTE_PROCEDURE, LAST_UPDATED_BY, nvl(DENORM_FLAG,'N')
  into l_db_atr_name, l_db_user_def_atr, l_db_cus_atr_proc, l_db_upd_by, l_db_denorm_flag
  from HZ_TRANS_ATTRIBUTES_VL
  where attribute_id=X_ATTRIBUTE_ID;

  IF (X_LAST_UPDATED_BY = 1 AND l_db_upd_by <> 1) THEN
     -- coming from seed and data modified by user
     IF (l_db_cus_atr_proc <> X_CUSTOM_ATTRIBUTE_PROCEDURE) THEN
       update HZ_TRANS_ATTRIBUTES_B set
         CUSTOM_ATTRIBUTE_PROCEDURE = X_CUSTOM_ATTRIBUTE_PROCEDURE,
         OBJECT_VERSION_NUMBER = l_object_version_number
       where ATTRIBUTE_ID = X_ATTRIBUTE_ID;

       update hz_trans_functions_b
       set staged_flag = 'N'
       where attribute_id = X_ATTRIBUTE_ID;
    END IF;
  ELSE
    update HZ_TRANS_ATTRIBUTES_B set
      ENTITY_NAME = X_ENTITY_NAME,
      CUSTOM_ATTRIBUTE_PROCEDURE = X_CUSTOM_ATTRIBUTE_PROCEDURE,
      SOURCE_TABLE = X_SOURCE_TABLE,
      DENORM_FLAG = X_DENORM_FLAG,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY, -- L_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
      OBJECT_VERSION_NUMBER = l_object_version_number
    where ATTRIBUTE_ID = X_ATTRIBUTE_ID;

    update HZ_TRANS_ATTRIBUTES_TL set
      USER_DEFINED_ATTRIBUTE_NAME = X_USER_DEFINED_ATTRIBUTE_NAME,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
--    OBJECT_VERSION_NUMBER =l_object_version_number,
      SOURCE_LANG = userenv('LANG')
    where ATTRIBUTE_ID = X_ATTRIBUTE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    IF (l_db_cus_atr_proc <> X_CUSTOM_ATTRIBUTE_PROCEDURE) THEN
       update hz_trans_functions_b
       set staged_flag = 'N'
       where attribute_id = X_ATTRIBUTE_ID;
    END IF;
  END IF;
  X_object_version_number := l_object_version_number;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ATTRIBUTE_ID in NUMBER
) is
begin
  delete from HZ_TRANS_ATTRIBUTES_TL
  where ATTRIBUTE_ID = X_ATTRIBUTE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from HZ_TRANS_ATTRIBUTES_B
  where ATTRIBUTE_ID = X_ATTRIBUTE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from HZ_TRANS_ATTRIBUTES_TL T
  where not exists
    (select NULL
    from HZ_TRANS_ATTRIBUTES_B B
    where B.ATTRIBUTE_ID = T.ATTRIBUTE_ID
    );

     update HZ_TRANS_ATTRIBUTES_TL T set (
     USER_DEFINED_ATTRIBUTE_NAME
    ) = (select
    B.USER_DEFINED_ATTRIBUTE_NAME
    from HZ_TRANS_ATTRIBUTES_TL B
    where B.ATTRIBUTE_ID = T.ATTRIBUTE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ATTRIBUTE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ATTRIBUTE_ID,
      SUBT.LANGUAGE
    from HZ_TRANS_ATTRIBUTES_TL SUBB, HZ_TRANS_ATTRIBUTES_TL SUBT
    where SUBB.ATTRIBUTE_ID = SUBT.ATTRIBUTE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and  SUBB.USER_DEFINED_ATTRIBUTE_NAME <> SUBT.USER_DEFINED_ATTRIBUTE_NAME
  );

  insert into HZ_TRANS_ATTRIBUTES_TL (
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    USER_DEFINED_ATTRIBUTE_NAME,
    ATTRIBUTE_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.USER_DEFINED_ATTRIBUTE_NAME,
    B.ATTRIBUTE_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from HZ_TRANS_ATTRIBUTES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from HZ_TRANS_ATTRIBUTES_TL T
    where T.ATTRIBUTE_ID = B.ATTRIBUTE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_ATTRIBUTE_ID in NUMBER,
  X_ENTITY_NAME in VARCHAR2,
  X_CUSTOM_ATTRIBUTE_PROCEDURE in VARCHAR2,
  X_SOURCE_TABLE in VARCHAR2,
  X_ATTRIBUTE_NAME in VARCHAR2,
  X_USER_DEFINED_ATTRIBUTE_NAME in VARCHAR2,
  X_DENORM_FLAG in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2) IS
begin

  declare
     user_id		number := 0;
     row_id     	varchar2(64);
     L_ATTRIBUTE_ID  NUMBER := X_ATTRIBUTE_ID;
     L_OBJECT_VERSION_NUMBER number;

  begin

     if (X_OWNER = 'SEED') then
        user_id := 1;
     end if;

     L_OBJECT_VERSION_NUMBER := NVL(X_OBJECT_VERSION_NUMBER, 1) + 1;

     HZ_TRANS_ATTRIBUTES_PKG.UPDATE_ROW(
     X_ATTRIBUTE_ID => X_ATTRIBUTE_ID ,
     X_ENTITY_NAME =>  X_ENTITY_NAME,
     X_CUSTOM_ATTRIBUTE_PROCEDURE =>X_CUSTOM_ATTRIBUTE_PROCEDURE ,
     X_SOURCE_TABLE => X_SOURCE_TABLE ,
     X_DENORM_FLAG => X_DENORM_FLAG ,
     X_ATTRIBUTE_NAME => X_ATTRIBUTE_NAME ,
     X_USER_DEFINED_ATTRIBUTE_NAME =>X_USER_DEFINED_ATTRIBUTE_NAME ,
     X_LAST_UPDATE_DATE => sysdate,
     X_LAST_UPDATED_BY => user_id,
     X_LAST_UPDATE_LOGIN => 0,
     X_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER);

     exception
       when NO_DATA_FOUND then

     HZ_TRANS_ATTRIBUTES_PKG.INSERT_ROW(
     X_ATTRIBUTE_ID => L_ATTRIBUTE_ID ,
     X_ENTITY_NAME =>  X_ENTITY_NAME,
     X_CUSTOM_ATTRIBUTE_PROCEDURE =>X_CUSTOM_ATTRIBUTE_PROCEDURE ,
     X_SOURCE_TABLE => X_SOURCE_TABLE ,
     X_ATTRIBUTE_NAME => X_ATTRIBUTE_NAME ,
     X_USER_DEFINED_ATTRIBUTE_NAME =>X_USER_DEFINED_ATTRIBUTE_NAME ,
     X_DENORM_FLAG => X_DENORM_FLAG ,
     X_CREATION_DATE=>SYSDATE  ,
     X_CREATED_BY =>USER_ID,
     X_LAST_UPDATE_DATE => sysdate,
     X_LAST_UPDATED_BY => user_id,
     X_LAST_UPDATE_LOGIN => 0,
     X_OBJECT_VERSION_NUMBER => 1);

     end;
end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_ATTRIBUTE_ID in NUMBER,
  X_USER_DEFINED_ATTRIBUTE_NAME in VARCHAR2,
  X_OWNER in VARCHAR2) IS

 begin
    -- only update rows that have not been altered by user
    update HZ_TRANS_ATTRIBUTES_TL set
    USER_DEFINED_ATTRIBUTE_NAME= X_USER_DEFINED_ATTRIBUTE_NAME,
    source_lang = userenv('LANG'),
    last_update_date = sysdate,
    last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
    last_update_login = 0
    where ATTRIBUTE_ID= X_ATTRIBUTE_ID
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;
end HZ_TRANS_ATTRIBUTES_PKG;

/
