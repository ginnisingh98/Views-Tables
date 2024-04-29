--------------------------------------------------------
--  DDL for Package Body HZ_TRANS_FUNCTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_TRANS_FUNCTIONS_PKG" AS
/*$Header: ARHDQTFB.pls 120.11 2006/03/18 12:41:14 rarajend noship $ */

function get_valid_tx_column(X_STAGED_ATTRIBUTE_TABLE VARCHAR2,
                             X_STAGED_ATTRIBUTE_COLUMN VARCHAR2) return varchar2;
procedure INSERT_ROW (
  X_FUNCTION_ID IN OUT NOCOPY NUMBER,
  X_STAGED_ATTRIBUTE_TABLE in VARCHAR2,
  X_STAGED_ATTRIBUTE_COLUMN in VARCHAR2,
  X_STAGED_FLAG in VARCHAR2,
  X_ATTRIBUTE_ID in NUMBER,
  X_PROCEDURE_NAME in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_PRIMARY_FLAG in VARCHAR2,
  X_INDEX_REQUIRED_FLAG in VARCHAR2,
  X_TRANSFORMATION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER
) is
 CURSOR C2 IS SELECT  HZ_TRANS_FUNCTIONS_s.nextval FROM sys.dual;
 l_success VARCHAR2(1) := 'N';
 l_staged_attribute_column varchar2(255);
begin
 l_staged_attribute_column := get_valid_tx_column(X_STAGED_ATTRIBUTE_TABLE,X_STAGED_ATTRIBUTE_COLUMN);
 WHILE l_success = 'N' LOOP
   BEGIN
     IF ( X_FUNCTION_ID IS NULL) OR (X_FUNCTION_ID = FND_API.G_MISS_NUM) THEN
        OPEN C2;
        FETCH C2 INTO X_FUNCTION_ID;
        CLOSE C2;
     END IF;

     insert into HZ_TRANS_FUNCTIONS_B (
        STAGED_ATTRIBUTE_TABLE,
        STAGED_ATTRIBUTE_COLUMN,
        STAGED_FLAG,
        FUNCTION_ID,
        ATTRIBUTE_ID,
        PROCEDURE_NAME,
        ACTIVE_FLAG,
        PRIMARY_FLAG,
        INDEX_REQUIRED_FLAG,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER
          ) values (
        X_STAGED_ATTRIBUTE_TABLE,
        l_staged_attribute_column, --Bug No:4260144
        nvl(X_STAGED_FLAG,'N'),
        X_FUNCTION_ID,
        X_ATTRIBUTE_ID,
        X_PROCEDURE_NAME,
        X_ACTIVE_FLAG,
        X_PRIMARY_FLAG,
        X_INDEX_REQUIRED_FLAG,
        X_CREATION_DATE,
        X_CREATED_BY,
        X_LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN,
        1
      );

      l_success := 'Y';
      EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
         IF INSTRB( SQLERRM, 'HZ_TRANS_FUNCTIONS_B_U1' ) <> 0 THEN
            DECLARE
              l_count             NUMBER;
              l_dummy             VARCHAR2(1);
            BEGIN
              l_count := 1;
              WHILE l_count > 0 LOOP
                 SELECT   HZ_TRANS_FUNCTIONS_s.nextval
		  into   X_FUNCTION_ID FROM sys.dual;
                 BEGIN
                  SELECT 'Y' INTO l_dummy
                  FROM HZ_TRANS_FUNCTIONS_B
                  WHERE  FUNCTION_ID =   X_FUNCTION_ID;
                  l_count := 1;
                 EXCEPTION WHEN NO_DATA_FOUND THEN
                  l_count := 0;
                 END;
             END LOOP;
          END;
        END IF;
     END;
  END LOOP;

   insert into HZ_TRANS_FUNCTIONS_TL (
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    FUNCTION_ID,
    TRANSFORMATION_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG,
    OBJECT_VERSION_NUMBER
  ) select
    X_LAST_UPDATE_DATE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_FUNCTION_ID,
    X_TRANSFORMATION_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    1
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from HZ_TRANS_FUNCTIONS_TL T
    where T.FUNCTION_ID = X_FUNCTION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end INSERT_ROW;


procedure LOCK_ROW (
  X_FUNCTION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER IN NUMBER
) is
  cursor c is select
    OBJECT_VERSION_NUMBER
    from HZ_TRANS_FUNCTIONS_B
    where FUNCTION_ID = X_FUNCTION_ID
    for update of FUNCTION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      OBJECT_VERSION_NUMBER,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from HZ_TRANS_FUNCTIONS_TL
    where FUNCTION_ID = X_FUNCTION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of FUNCTION_ID nowait;
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
  X_FUNCTION_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER IN NUMBER,
  X_TRANSFORMATION_NAME IN VARCHAR2,
  X_DESCRIPTION IN VARCHAR2

) is
  cursor c is select
    OBJECT_VERSION_NUMBER
    from HZ_TRANS_FUNCTIONS_B
    where FUNCTION_ID = X_FUNCTION_ID
    for update of FUNCTION_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TRANSFORMATION_NAME,DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from HZ_TRANS_FUNCTIONS_TL
    where FUNCTION_ID = X_FUNCTION_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of FUNCTION_ID nowait;
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
       if (    ((tlinfo.TRANSFORMATION_NAME = X_TRANSFORMATION_NAME)
               OR ((tlinfo.TRANSFORMATION_NAME  is null) AND ( X_TRANSFORMATION_NAME is null)))
      ) then
       if (    ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION  is null) AND ( X_DESCRIPTION is null)))
      ) then
      null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
       end if;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;


procedure UPDATE_ROW (
  X_FUNCTION_ID in NUMBER,
  X_STAGED_ATTRIBUTE_TABLE in VARCHAR2,
  X_STAGED_ATTRIBUTE_COLUMN in VARCHAR2,
  X_STAGED_FLAG in VARCHAR2,
  X_ATTRIBUTE_ID in NUMBER,
  X_PROCEDURE_NAME in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_PRIMARY_FLAG in VARCHAR2,
  X_INDEX_REQUIRED_FLAG in VARCHAR2,
  X_TRANSFORMATION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER IN out NOCOPY NUMBER
) is

  l_object_version_number NUMBER;
  l_db_act_flag VARCHAR2(1);
  l_db_proc_name VARCHAR2(256);
  l_db_primary_flag VARCHAR2(1);
  l_db_upd_by NUMBER;
  l_db_trans_name VARCHAR2(100);
  l_db_desc VARCHAR2(1000);
  l_db_stg_atr_col VARCHAR2(30);
  l_db_stg_flag VARCHAR2(1);
  l_db_index_req_flag VARCHAR2(1);
  L_STAGED_FLAG VARCHAR2(1);
  L_STAGED_ATTRIBUTE_COLUMN VARCHAR2(255);
  TMP NUMBER;

begin

  SELECT 1 INTO TMP FROM HZ_TRANS_FUNCTIONS_VL
  WHERE function_id = X_FUNCTION_ID;

  SELECT  nvl(ACTIVE_FLAG,'Y'), PROCEDURE_NAME,
          nvl(PRIMARY_FLAG,'N'), last_updated_by, staged_flag,
          transformation_name, description,
          nvl(INDEX_REQUIRED_FLAG, 'N'), STAGED_ATTRIBUTE_COLUMN
  into l_db_act_flag, l_db_proc_name, l_db_primary_flag, l_db_upd_by, l_db_stg_flag,
       l_db_trans_name, l_db_desc, l_db_index_req_flag, l_db_stg_atr_col
  from HZ_TRANS_FUNCTIONS_VL
  where function_id =X_FUNCTION_ID;
  l_object_version_number := NVL(X_object_version_number, 1) + 1;

  IF (X_LAST_UPDATED_BY = 1 AND l_db_upd_by <> 1) THEN
     -- coming from seed and data modified by user
     IF (X_PROCEDURE_NAME <>l_db_proc_name) THEN
       update HZ_TRANS_FUNCTIONS_B set
         PROCEDURE_NAME = X_PROCEDURE_NAME,
         STAGED_FLAG = 'N',
         OBJECT_VERSION_NUMBER = l_object_version_number
       where FUNCTION_ID = X_FUNCTION_ID;
       update HZ_TRANS_FUNCTIONS_TL set
         TRANSFORMATION_NAME = X_TRANSFORMATION_NAME,
         DESCRIPTION = X_DESCRIPTION,
         OBJECT_VERSION_NUMBER = l_object_version_number
       where FUNCTION_ID = X_FUNCTION_ID
       and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
     END IF;
  ELSE
     IF ((l_db_act_flag<>nvl(X_ACTIVE_FLAG,'Y'))
         OR ((l_db_primary_flag='N') AND (nvl(X_PRIMARY_FLAG,'N')='Y'))
         OR (X_PROCEDURE_NAME<>l_db_proc_name)) THEN
       L_STAGED_FLAG:='N';
     ELSE
       L_STAGED_FLAG:=l_db_stg_flag;
     END IF;
     IF ((l_db_act_flag = 'N') AND (X_ACTIVE_FLAG = 'Y')) THEN
       l_staged_attribute_column := get_valid_tx_column(X_STAGED_ATTRIBUTE_TABLE,X_STAGED_ATTRIBUTE_COLUMN);  --Bug No:4260144
       --L_STAGED_ATTRIBUTE_COLUMN := X_STAGED_ATTRIBUTE_COLUMN;
     ELSE
       L_STAGED_ATTRIBUTE_COLUMN := l_db_stg_atr_col;
     END IF;
     update HZ_TRANS_FUNCTIONS_B set
        STAGED_ATTRIBUTE_TABLE = X_STAGED_ATTRIBUTE_TABLE,
        STAGED_ATTRIBUTE_COLUMN = L_STAGED_ATTRIBUTE_COLUMN,
        ATTRIBUTE_ID = X_ATTRIBUTE_ID,
        PROCEDURE_NAME = X_PROCEDURE_NAME,
        ACTIVE_FLAG = X_ACTIVE_FLAG,
        PRIMARY_FLAG = X_PRIMARY_FLAG,
        INDEX_REQUIRED_FLAG = X_INDEX_REQUIRED_FLAG,
        STAGED_FLAG = L_STAGED_FLAG,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY = X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER = l_object_version_number
       where FUNCTION_ID = X_FUNCTION_ID;
       update HZ_TRANS_FUNCTIONS_TL set
        TRANSFORMATION_NAME = X_TRANSFORMATION_NAME,
        DESCRIPTION = X_DESCRIPTION,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY = X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
        SOURCE_LANG = userenv('LANG')
--        OBJECT_VERSION_NUMBER = l_object_version_number
       where FUNCTION_ID = X_FUNCTION_ID
       and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    END IF;
    X_object_version_number := l_object_version_number;
end UPDATE_ROW;


procedure DELETE_ROW (
  X_FUNCTION_ID in NUMBER
) is
begin
  delete from HZ_TRANS_FUNCTIONS_TL
  where FUNCTION_ID = X_FUNCTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from HZ_TRANS_FUNCTIONS_B
  where FUNCTION_ID = X_FUNCTION_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from HZ_TRANS_FUNCTIONS_TL T
  where not exists
    (select NULL
    from HZ_TRANS_FUNCTIONS_B B
    where B.FUNCTION_ID = T.FUNCTION_ID
    );

  update HZ_TRANS_FUNCTIONS_TL T set (
      TRANSFORMATION_NAME,
      DESCRIPTION
    ) = (select
      B.TRANSFORMATION_NAME,
      B.DESCRIPTION
    from HZ_TRANS_FUNCTIONS_TL B
    where B.FUNCTION_ID = T.FUNCTION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FUNCTION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.FUNCTION_ID,
      SUBT.LANGUAGE
    from HZ_TRANS_FUNCTIONS_TL SUBB, HZ_TRANS_FUNCTIONS_TL SUBT
    where SUBB.FUNCTION_ID = SUBT.FUNCTION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TRANSFORMATION_NAME <> SUBT.TRANSFORMATION_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

   insert into HZ_TRANS_FUNCTIONS_TL (
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    FUNCTION_ID,
    TRANSFORMATION_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.FUNCTION_ID,
    B.TRANSFORMATION_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from HZ_TRANS_FUNCTIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and L.LANGUAGE_CODE <> B.LANGUAGE
  and not exists
    (select NULL
    from HZ_TRANS_FUNCTIONS_TL T
    where T.FUNCTION_ID = B.FUNCTION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_ROW (
  X_FUNCTION_ID in NUMBER,
  X_STAGED_ATTRIBUTE_TABLE in VARCHAR2,
  X_STAGED_ATTRIBUTE_COLUMN in VARCHAR2,
  X_STAGED_FLAG in VARCHAR2,
  X_ATTRIBUTE_ID in NUMBER,
  X_PROCEDURE_NAME in VARCHAR2,
  X_ACTIVE_FLAG in VARCHAR2,
  X_PRIMARY_FLAG in VARCHAR2,
  X_INDEX_REQUIRED_FLAG in VARCHAR2,
  X_TRANSFORMATION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2) IS

  begin

  declare
     user_id		number := 0;
     row_id     	varchar2(64);
     L_FUNCTION_ID  NUMBER := X_FUNCTION_ID;
     L_OBJECT_VERSION_NUMBER number;

  begin

     if (X_OWNER = 'SEED') then
        user_id := 1;
     end if;

     L_OBJECT_VERSION_NUMBER := NVL(X_OBJECT_VERSION_NUMBER, 1) + 1;

     HZ_TRANS_FUNCTIONS_PKG.UPDATE_ROW(
     X_FUNCTION_ID =>X_FUNCTION_ID,
     X_STAGED_ATTRIBUTE_TABLE =>X_STAGED_ATTRIBUTE_TABLE,
     X_STAGED_ATTRIBUTE_COLUMN =>X_STAGED_ATTRIBUTE_COLUMN,
     X_STAGED_FLAG =>X_STAGED_FLAG,
     X_ATTRIBUTE_ID =>X_ATTRIBUTE_ID,
     X_PROCEDURE_NAME =>X_PROCEDURE_NAME,
     X_ACTIVE_FLAG =>X_ACTIVE_FLAG,
     X_PRIMARY_FLAG =>X_PRIMARY_FLAG,
     X_INDEX_REQUIRED_FLAG =>X_INDEX_REQUIRED_FLAG,
     X_TRANSFORMATION_NAME =>X_TRANSFORMATION_NAME,
     X_DESCRIPTION =>X_DESCRIPTION,
     X_LAST_UPDATE_DATE => sysdate,
     X_LAST_UPDATED_BY => user_id,
     X_LAST_UPDATE_LOGIN => 0,
     X_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER);

     exception
       when NO_DATA_FOUND then

     HZ_TRANS_FUNCTIONS_PKG.INSERT_ROW(
     X_FUNCTION_ID =>L_FUNCTION_ID,
     X_STAGED_ATTRIBUTE_TABLE =>X_STAGED_ATTRIBUTE_TABLE,
     X_STAGED_ATTRIBUTE_COLUMN =>X_STAGED_ATTRIBUTE_COLUMN,
     X_STAGED_FLAG =>X_STAGED_FLAG,
     X_ATTRIBUTE_ID =>X_ATTRIBUTE_ID,
     X_PROCEDURE_NAME =>X_PROCEDURE_NAME,
     X_ACTIVE_FLAG =>X_ACTIVE_FLAG,
     X_PRIMARY_FLAG =>X_PRIMARY_FLAG,
     X_INDEX_REQUIRED_FLAG =>X_INDEX_REQUIRED_FLAG,
     X_TRANSFORMATION_NAME =>X_TRANSFORMATION_NAME,
     X_DESCRIPTION =>X_DESCRIPTION,
     X_CREATION_DATE=>SYSDATE  ,
     X_CREATED_BY =>USER_ID,
     X_LAST_UPDATE_DATE => sysdate,
     X_LAST_UPDATED_BY => user_id,
     X_LAST_UPDATE_LOGIN => 0,
     X_OBJECT_VERSION_NUMBER => 1);

     end;
end LOAD_ROW;

procedure TRANSLATE_ROW (
   X_FUNCTION_ID in NUMBER,
   X_TRANSFORMATION_NAME in varchar2,
   X_DESCRIPTION in varchar2,
   X_OWNER in VARCHAR2) IS

 begin
    -- only update rows that have not been altered by user
    update HZ_TRANS_FUNCTIONS_TL set
    TRANSFORMATION_NAME = X_TRANSFORMATION_NAME,
    DESCRIPTION = X_DESCRIPTION,
    source_lang = userenv('LANG'),
    last_update_date = sysdate,
    last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
    last_update_login = 0
    where FUNCTION_ID = X_FUNCTION_ID
    and   userenv('LANG') in (language, source_lang);

end TRANSLATE_ROW;

FUNCTION get_valid_tx_column(x_staged_attribute_table  VARCHAR2,
                             x_staged_attribute_column VARCHAR2)
return varchar2
IS
CURSOR c_stg_attr_col IS  select substr(staged_attribute_column,3)-1 from hz_trans_functions_vl vl1
                          where staged_attribute_table = x_staged_attribute_table
			  and substr(staged_attribute_column,3) > 2
			  and NOT EXISTS(
			    select 'Y'from hz_trans_functions_vl vl2
			    where vl2.staged_attribute_table=vl1.staged_attribute_table
			    and   substr(vl2.staged_attribute_column,3) = substr(vl1.staged_attribute_column,3)-1
			    )
			  and rownum=1 ;
CURSOR c_max_stg_col IS select max(to_number(substr(staged_attribute_column,3)))+1 from hz_trans_functions_vl
                        where staged_attribute_table = X_STAGED_ATTRIBUTE_TABLE;
l_staged_attribute_column VARCHAR2(255);
l_prefix    VARCHAR2(2);
BEGIN
 l_prefix := 'TX';
 IF( (x_staged_attribute_column IS NULL) OR (substr(x_staged_attribute_column,3) > 255)) THEN
  IF(x_staged_attribute_column IS NOT NULL) THEN
   OPEN  c_stg_attr_col;
   FETCH c_stg_attr_col INTO l_staged_attribute_column;
   CLOSE c_stg_attr_col;
  END IF;
  IF l_staged_attribute_column is null then
    open  c_max_stg_col;
    fetch c_max_stg_col INTO l_staged_attribute_column;
    close c_max_stg_col;
  END IF;
  IF( nvl(l_staged_attribute_column,256) > 255)THEN
   FND_MESSAGE.SET_NAME('AR', 'HZ_DQM_TRANSFORMATION_LIMIT');
   FND_MSG_PUB.ADD;
   RAISE FND_API.G_EXC_ERROR;
  ELSE
   l_staged_attribute_column := l_prefix || l_staged_attribute_column;
  END IF;
 ELSE
  l_staged_attribute_column := X_STAGED_ATTRIBUTE_COLUMN;
 END IF;
 RETURN l_staged_attribute_column;
END;
end HZ_TRANS_FUNCTIONS_PKG;

/
