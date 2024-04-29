--------------------------------------------------------
--  DDL for Package Body HZ_TRANSFORMATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_TRANSFORMATIONS_PKG" as
/*$Header: ARHDTFTB.pls 120.3 2006/02/10 01:18:25 schitrap noship $ */

PROCEDURE Insert_Row (
    x_transformation_id                          IN  OUT NOCOPY NUMBER,
    x_transformation_name                        IN VARCHAR2,
    x_description                                IN VARCHAR2,
    x_procedure_name				 IN VARCHAR2,
    x_object_version_number			 IN  NUMBER
) IS


   CURSOR C2 IS SELECT   HZ_TRANSFORMATIONS_S.nextval FROM sys.dual ;
   l_success  VARCHAR2(1) := 'N';
   l_object_version_number NUMBER;
   l_proc_valid  VARCHAR2(10);
BEGIN

  l_proc_valid:= HZ_DQM_SEARCH_UTIL.validate_trans_proc(x_procedure_name);
  if(nvl(l_proc_valid,'INVALID') = 'INVALID') then
    fnd_message.set_name('AR', 'HZ_DQM_INVALID_TRANS_PROC');
    fnd_message.set_token('PROC',x_procedure_name);
    app_exception.raise_exception;
  end if;
  l_object_version_number := x_object_version_number;
  IF ( x_transformation_id IS NULL) OR (x_transformation_id = FND_API.G_MISS_NUM) THEN
     OPEN C2;
     FETCH C2 INTO x_transformation_id;
     CLOSE C2;
  END IF;
  IF ( l_object_version_number IS NULL) OR (l_object_version_number = FND_API.G_MISS_NUM) THEN
       l_object_version_number :=1;
  END IF;

  WHILE l_success = 'N' LOOP
    BEGIN
        INSERT INTO HZ_TRANSFORMATIONS_B(
         transformation_id,
         procedure_name,
         object_version_number,
         created_by,
	 creation_date,
         last_updated_by,
	 last_update_login,
	 last_update_date
        )
        VALUES (
         x_transformation_id,
         DECODE(x_procedure_name,FND_API.G_MISS_CHAR, NULL,x_procedure_name),
	 l_object_version_number,
         hz_utility_v2pub.created_by,
         hz_utility_v2pub.creation_date,
         hz_utility_v2pub.last_updated_by,
         hz_utility_v2pub.last_update_login,
	 hz_utility_v2pub.last_update_date
        );
	l_success := 'Y';
    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
     IF INSTRB( SQLERRM, 'HZ_TRANSFORMATIONS_B_U1' ) <> 0 THEN
        DECLARE
	 l_count             NUMBER;
	 l_dummy             VARCHAR2(1);
	BEGIN
	  l_count := 1;
	  WHILE l_count > 0 LOOP
	    SELECT  HZ_TRANSFORMATIONS_S.nextval
	    into  x_transformation_id FROM sys.dual;
	    BEGIN
	      SELECT 'Y' INTO l_dummy
	      FROM HZ_TRANSFORMATIONS_B
	      WHERE TRANSFORMATION_ID =  X_TRANSFORMATION_ID;
	      l_count := 1;
	    EXCEPTION WHEN NO_DATA_FOUND THEN
	      l_count := 0;
	    END;
	  END LOOP;
	END;
     END IF;
    END;
  END LOOP;

  INSERT INTO HZ_TRANSFORMATIONS_TL (
        transformation_id,
        transformation_name,
        description,
        language,
        source_lang,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_login,
	last_update_date
      )
       SELECT
        x_transformation_id,
        x_transformation_name,
        x_description,
        l.language_code,
        userenv('LANG'),
        l_object_version_number,
	hz_utility_v2pub.created_by,
	hz_utility_v2pub.creation_date,
        hz_utility_v2pub.last_updated_by,
        hz_utility_v2pub.last_update_login,
        hz_utility_v2pub.last_update_date
       FROM FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG in ('I', 'B')
       AND NOT EXISTS (select NULL from HZ_TRANSFORMATIONS_TL T
                       where T.TRANSFORMATION_ID = X_TRANSFORMATION_ID
                       and   T.LANGUAGE = L.LANGUAGE_CODE
	               );

END Insert_Row;


procedure Update_Row (
    x_transformation_id                          IN NUMBER,
    x_transformation_name                        IN VARCHAR2,
    x_description                                IN VARCHAR2,
    x_procedure_name				 IN VARCHAR2,
    x_object_version_number			 IN OUT NOCOPY NUMBER
)
IS
   p_object_version_number NUMBER ;
   l_proc_valid  VARCHAR2(10);
BEGIN
   p_object_version_number := nvl(x_object_version_number, 1) + 1;
   l_proc_valid:= HZ_DQM_SEARCH_UTIL.validate_trans_proc(x_procedure_name);
   if(nvl(l_proc_valid,'INVALID') = 'INVALID') then
    fnd_message.set_name('AR', 'HZ_DQM_INVALID_TRANS_PROC');
    fnd_message.set_token('PROC',x_procedure_name);
    app_exception.raise_exception;
   end if;
   UPDATE HZ_TRANSFORMATIONS_B set
        procedure_name = decode(x_procedure_name,null,procedure_name,fnd_api.g_miss_char,NULL,x_procedure_name),
        object_version_number = p_object_version_number,
        last_updated_by       = hz_utility_v2pub.last_updated_by,
        last_update_login     = hz_utility_v2pub.last_update_login,
        last_update_date      = hz_utility_v2pub.last_update_date
   where transformation_id = x_transformation_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update HZ_TRANSFORMATIONS_TL set
        transformation_name = decode(x_transformation_name,null,transformation_name,fnd_api.g_miss_char,NULL,x_transformation_name),
        description = decode(x_description,null,description,fnd_api.g_miss_char,NULL,x_description),
        object_version_number = p_object_version_number,
        last_updated_by = hz_utility_v2pub.last_updated_by,
        last_update_login = hz_utility_v2pub.last_update_login,
        last_update_date = hz_utility_v2pub.last_update_date,
        source_lang = userenv('LANG')
  where transformation_id = x_transformation_id
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
  x_object_version_number := p_object_version_number ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

END ;


procedure Delete_Row (
  x_transformation_id in NUMBER
)
IS
BEGIN
  delete from HZ_TRANSFORMATIONS_B
  where transformation_id = x_transformation_id ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from HZ_TRANSFORMATIONS_TL
  where transformation_id = x_transformation_id ;

  if (sql%notfound) then
    raise no_data_found;
  end if;
END ;

procedure Lock_Row (
  x_transformation_id in NUMBER,
  x_object_version_number in  NUMBER
)
IS
 cursor c is select object_version_number
             from HZ_TRANSFORMATIONS_TL
             where transformation_id = x_transformation_id
	     and   language = userenv('lang');
 cursor c1 is select object_version_number
             from HZ_TRANSFORMATIONS_B
             where transformation_id = x_transformation_id
 for update of transformation_id nowait;

 cursor c2 is select object_version_number
             from HZ_TRANSFORMATIONS_TL
             where transformation_id = x_transformation_id
 for update of transformation_id nowait;

recinfo c%rowtype;

BEGIN
  -- Lock the records
   open  c1;
   close c1;
   open  c2;
   close c2;

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if(
       ( recinfo.object_version_number IS NULL AND x_object_version_number IS NULL )
       OR ( recinfo.object_version_number IS NOT NULL AND
          x_object_version_number IS NOT NULL AND
          recinfo.object_version_number = x_object_version_number )
     ) then
       null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;

END Lock_Row ;


procedure Add_Language
IS
BEGIN
  delete from HZ_TRANSFORMATIONS_TL T
  where not exists
    (select NULL
    from HZ_TRANSFORMATIONS_B B
    where B.transformation_id = T.transformation_id
    );

  update HZ_TRANSFORMATIONS_TL T set (
      transformation_name,
      description,
      object_version_number
    ) = (select B.transformation_name,B.description,
            NVL(T.object_version_number, 1) + 1
         from HZ_TRANSFORMATIONS_TL B
         where B.transformation_id = T.transformation_id
         and B.language = T.source_lang
	 )
  where (T.transformation_id,T.language) in (select SUBT.transformation_id,SUBT.language
					     from HZ_TRANSFORMATIONS_TL SUBB, HZ_TRANSFORMATIONS_TL SUBT
					     where SUBB.transformation_id = SUBT.transformation_id
					     and SUBB.language = SUBT.source_lang
					     and (SUBB.transformation_name <> SUBT.transformation_name
					           or SUBB.description <> SUBT.description
					           or (SUBB.description is null and SUBT.description is not null)
					           or (SUBB.description is not null and SUBT.description is null)
                                                  )
				            );

  insert into HZ_TRANSFORMATIONS_TL (
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    DESCRIPTION,
    TRANSFORMATION_NAME,
    TRANSFORMATION_ID,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
    OBJECT_VERSION_NUMBER
  ) select
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.DESCRIPTION,
    B.TRANSFORMATION_NAME,
    B.TRANSFORMATION_ID,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    1
  from HZ_TRANSFORMATIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and L.LANGUAGE_CODE <> B.LANGUAGE
  and not exists
    (select NULL
    from HZ_TRANSFORMATIONS_TL T
    where T.TRANSFORMATION_ID = B.TRANSFORMATION_ID
    and T.language = L.language_code );
END ;


procedure Load_Row (
    x_transformation_id                          IN OUT NOCOPY NUMBER,
    x_transformation_name                        IN VARCHAR2,
    x_description                                IN VARCHAR2,
    x_procedure_name				 IN VARCHAR2,
    x_object_version_number			 IN NUMBER,
    x_last_updated_by				 IN number,
    x_last_update_login				 IN number,
    x_last_update_date				 IN date,
    x_owner                                      IN VARCHAR2,
    x_custom_mode                                IN VARCHAR2
    )
IS
  l_f_luby    number;  -- entity owner in file
  l_f_ludate  date;    -- entity update date in file
  l_db_luby   number;  -- entity owner in db
  l_db_ludate date;    -- entity update date in db
  l_object_version_number number ;

begin

  -- Translate owner to file_last_updated_by
  IF (x_owner = 'SEED')
  THEN
    l_f_luby := 1;
  ELSE
    l_f_luby := 0;
  END IF ;

  -- Get last update date of ldt entity
  l_f_ludate := nvl(x_last_update_date, sysdate);

  l_object_version_number := x_object_version_number ;

  BEGIN
         select LAST_UPDATED_BY, LAST_UPDATE_DATE
         into l_db_luby, l_db_ludate
         from HZ_TRANSFORMATIONS_B
         where transformation_id = x_transformation_id ;

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date

   IF ((x_custom_mode = 'FORCE') or
       ((l_f_luby = 0) and (l_db_luby = 1)) or
       ((l_f_luby = l_db_luby) and (l_f_ludate > l_db_ludate)))
   THEN

    HZ_TRANSFORMATIONS_PKG.UPDATE_ROW(
       x_transformation_id => x_transformation_id,
       x_transformation_name => x_transformation_name,
       x_description => x_description,
       x_procedure_name => x_procedure_name,
       x_object_version_number => l_object_version_number
    );
   END IF ;

   EXCEPTION
       WHEN NO_DATA_FOUND
       THEN
          HZ_TRANSFORMATIONS_PKG.INSERT_ROW(
            x_transformation_id => x_transformation_id,
            x_transformation_name => x_transformation_name,
            x_description => x_description,
            x_procedure_name => x_procedure_name,
            x_object_version_number => x_object_version_number
          );

   END ;

END ;

-- update rows that have not been altered by user
procedure Translate_Row (
  x_transformation_id in NUMBER,
  x_transformation_name in VARCHAR2,
  x_description in VARCHAR2,
  x_owner in VARCHAR2)
IS
BEGIN

 UPDATE HZ_TRANSFORMATIONS_TL set
 transformation_name = x_transformation_name,
 description = x_description,
 source_lang = userenv('LANG'),
 last_update_date = sysdate,
 last_updated_by = decode(x_owner, 'SEED', 1, 0),
 last_update_login = 0
 where transformation_id = x_transformation_id
 and   userenv('LANG') in (language, source_lang);

END ;


END HZ_TRANSFORMATIONS_PKG  ;


/
