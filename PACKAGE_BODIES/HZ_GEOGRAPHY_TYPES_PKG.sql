--------------------------------------------------------
--  DDL for Package Body HZ_GEOGRAPHY_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEOGRAPHY_TYPES_PKG" AS
/*$Header: ARHGTPTB.pls 120.6.12000000.2 2007/05/07 20:45:47 nsinghai ship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_geography_type                        IN  VARCHAR2,
    x_geography_type_name                   IN  VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_geography_use                         IN     VARCHAR2,
    x_postal_code_range_flag                IN     VARCHAR2,
    x_limited_by_geography_id               IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_program_login_id                      IN     NUMBER
) IS


BEGIN

      INSERT INTO HZ_GEOGRAPHY_TYPES_B (
        geography_type,
        object_version_number,
        geography_use,
        postal_code_range_flag,
        limited_by_geography_id,
        created_by_module,
        last_updated_by,
        creation_date,
        created_by,
        last_update_date,
        last_update_login,
        application_id,
        program_id,
        program_login_id,
        program_application_id,
        request_id
      )
      VALUES (
        DECODE(x_geography_type,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_type),
        DECODE(x_object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number),
        DECODE(x_geography_use,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_use),
        DECODE(x_postal_code_range_flag,
               FND_API.G_MISS_CHAR, NULL,
               x_postal_code_range_flag),
        DECODE(x_limited_by_geography_id,
               FND_API.G_MISS_NUM, NULL,
               x_limited_by_geography_id),
        DECODE(x_created_by_module,
               FND_API.G_MISS_CHAR, NULL,
               x_created_by_module),
        hz_utility_v2pub.last_updated_by,
        hz_utility_v2pub.creation_date,
        hz_utility_v2pub.created_by,
        hz_utility_v2pub.last_update_date,
        hz_utility_v2pub.last_update_login,
        DECODE(x_application_id,
               FND_API.G_MISS_NUM, NULL,
               x_application_id),
        hz_utility_v2pub.program_id,
        DECODE(x_program_login_id,
               FND_API.G_MISS_NUM, NULL,
               x_program_login_id),
        hz_utility_v2pub.program_application_id,
        hz_utility_v2pub.request_id
      ) RETURNING
        rowid
      INTO
        x_rowid;

  insert into HZ_GEOGRAPHY_TYPES_TL (
    GEOGRAPHY_TYPE,
    GEOGRAPHY_TYPE_NAME,
    CREATED_BY_MODULE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_LOGIN_ID,
    PROGRAM_APPLICATION_ID,
    REQUEST_ID,
    LANGUAGE,
    SOURCE_LANG
  ) select
    DECODE(x_geography_type,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_type),
    DECODE(x_geography_type_name,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_type_name),
    DECODE(x_created_by_module,
               FND_API.G_MISS_CHAR, NULL,
               x_created_by_module),
        hz_utility_v2pub.last_updated_by,
        hz_utility_v2pub.creation_date,
        hz_utility_v2pub.created_by,
        hz_utility_v2pub.last_update_date,
        hz_utility_v2pub.last_update_login,
        DECODE(x_application_id,
               FND_API.G_MISS_NUM, NULL,
               x_application_id),
        hz_utility_v2pub.program_id,
        DECODE(x_program_login_id,
               FND_API.G_MISS_NUM, NULL,
               x_program_login_id),
        hz_utility_v2pub.program_application_id,
        hz_utility_v2pub.request_id,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from HZ_GEOGRAPHY_TYPES_TL T
    where T.GEOGRAPHY_TYPE = X_GEOGRAPHY_TYPE
    and T.LANGUAGE = L.LANGUAGE_CODE);

END Insert_Row;

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_geography_type                        IN     VARCHAR2,
    x_geography_type_name                   IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_geography_use                         IN     VARCHAR2,
    x_postal_code_range_flag                IN     VARCHAR2,
    x_limited_by_geography_id               IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_application_id                        IN     NUMBER,
    x_program_login_id                      IN     NUMBER
) IS
BEGIN

  --dbms_output.put_line.PUT_LINE('in tblhandler geography_type_name is '||x_geography_type_name);

    UPDATE HZ_GEOGRAPHY_TYPES_B
    SET
      geography_type =
        DECODE(x_geography_type,
               NULL, geography_type,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_type),
      object_version_number =
        DECODE(x_object_version_number,
               NULL, object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number),
      geography_use =
        DECODE(x_geography_use,
               NULL, geography_use,
               FND_API.G_MISS_CHAR, NULL,
               x_geography_use),
      postal_code_range_flag =
        DECODE(x_postal_code_range_flag,
               NULL, postal_code_range_flag,
               FND_API.G_MISS_CHAR, NULL,
               x_postal_code_range_flag),
      limited_by_geography_id =
        DECODE(x_limited_by_geography_id,
               NULL, limited_by_geography_id,
               FND_API.G_MISS_NUM, NULL,
               x_limited_by_geography_id),
      created_by_module =
        DECODE(x_created_by_module,
               NULL, created_by_module,
               FND_API.G_MISS_CHAR, NULL,
               x_created_by_module),
      last_updated_by = hz_utility_v2pub.last_updated_by,
      creation_date = creation_date,
      created_by = created_by,
      last_update_date = hz_utility_v2pub.last_update_date,
      last_update_login = hz_utility_v2pub.last_update_login,
      application_id =
        DECODE(x_application_id,
               NULL, application_id,
               FND_API.G_MISS_NUM, NULL,
               x_application_id),
      program_id = hz_utility_v2pub.program_id,
      program_login_id =
        DECODE(x_program_login_id,
               NULL, program_login_id,
               FND_API.G_MISS_NUM, NULL,
               x_program_login_id),
      program_application_id = hz_utility_v2pub.program_application_id,
      request_id = hz_utility_v2pub.request_id
    WHERE rowid = x_rowid;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  update HZ_GEOGRAPHY_TYPES_TL set
    GEOGRAPHY_TYPE_NAME = decode(X_GEOGRAPHY_TYPE_NAME,
                                 NULL, GEOGRAPHY_TYPE_NAME,
                                 FND_API.G_MISS_NUM, NULL,
                                 X_GEOGRAPHY_TYPE_NAME),
    LAST_UPDATE_DATE = decode(X_GEOGRAPHY_TYPE_NAME, NULL, LAST_UPDATE_DATE,
                              FND_API.G_MISS_NUM, NULL,
                              hz_utility_v2pub.last_update_date),
    LAST_UPDATED_BY = decode(X_GEOGRAPHY_TYPE_NAME, NULL, LAST_UPDATED_BY,
                             FND_API.G_MISS_NUM, NULL,
                             hz_utility_v2pub.LAST_UPDATED_BY),
    LAST_UPDATE_LOGIN = decode(X_GEOGRAPHY_TYPE_NAME, NULL, LAST_UPDATE_LOGIN,
                             FND_API.G_MISS_NUM, NULL,
                             hz_utility_v2pub.LAST_UPDATE_LOGIN),
    SOURCE_LANG = userenv('LANG')
  where GEOGRAPHY_TYPE = X_GEOGRAPHY_TYPE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

END Update_Row;

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_geography_type                        IN     VARCHAR2,
    x_geography_type_name                   IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER,
    x_geography_use                         IN     VARCHAR2,
    x_postal_code_range_flag                IN     VARCHAR2,
    x_limited_by_geography_id               IN     NUMBER,
    x_created_by_module                     IN     VARCHAR2,
    x_last_updated_by                       IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_created_by                            IN     NUMBER,
    x_last_update_date                      IN     DATE,
    x_last_update_login                     IN     NUMBER,
    x_application_id                        IN     NUMBER,
    x_program_id                            IN     NUMBER,
    x_program_login_id                      IN     NUMBER,
    x_program_application_id                IN     NUMBER,
    x_request_id                            IN     NUMBER
) IS

    CURSOR c IS
      SELECT * FROM hz_geography_types_b
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;
    Recinfo c%ROWTYPE;

  cursor c1 is select
      GEOGRAPHY_TYPE_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from HZ_GEOGRAPHY_TYPES_TL
    where GEOGRAPHY_TYPE = X_GEOGRAPHY_TYPE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of GEOGRAPHY_TYPE nowait;
BEGIN

    OPEN c;
    FETCH c INTO Recinfo;
    IF ( c%NOTFOUND ) THEN
      CLOSE c;
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;

    IF (
        ( ( Recinfo.geography_type = x_geography_type )
        OR ( ( Recinfo.geography_type IS NULL )
          AND (  x_geography_type IS NULL ) ) )
    AND ( ( Recinfo.object_version_number = x_object_version_number )
        OR ( ( Recinfo.object_version_number IS NULL )
          AND (  x_object_version_number IS NULL ) ) )
    AND ( ( Recinfo.geography_use = x_geography_use )
        OR ( ( Recinfo.geography_use IS NULL )
          AND (  x_geography_use IS NULL ) ) )
    AND ( ( Recinfo.postal_code_range_flag = x_postal_code_range_flag )
        OR ( ( Recinfo.postal_code_range_flag IS NULL )
          AND (  x_postal_code_range_flag IS NULL ) ) )
    AND ( ( Recinfo.limited_by_geography_id = x_limited_by_geography_id )
        OR ( ( Recinfo.limited_by_geography_id IS NULL )
          AND (  x_limited_by_geography_id IS NULL ) ) )
    AND ( ( Recinfo.created_by_module = x_created_by_module )
        OR ( ( Recinfo.created_by_module IS NULL )
          AND (  x_created_by_module IS NULL ) ) )
    AND ( ( Recinfo.last_updated_by = x_last_updated_by )
        OR ( ( Recinfo.last_updated_by IS NULL )
          AND (  x_last_updated_by IS NULL ) ) )
    AND ( ( Recinfo.creation_date = x_creation_date )
        OR ( ( Recinfo.creation_date IS NULL )
          AND (  x_creation_date IS NULL ) ) )
    AND ( ( Recinfo.created_by = x_created_by )
        OR ( ( Recinfo.created_by IS NULL )
          AND (  x_created_by IS NULL ) ) )
    AND ( ( Recinfo.last_update_date = x_last_update_date )
        OR ( ( Recinfo.last_update_date IS NULL )
          AND (  x_last_update_date IS NULL ) ) )
    AND ( ( Recinfo.last_update_login = x_last_update_login )
        OR ( ( Recinfo.last_update_login IS NULL )
          AND (  x_last_update_login IS NULL ) ) )
    AND ( ( Recinfo.application_id = x_application_id )
        OR ( ( Recinfo.application_id IS NULL )
          AND (  x_application_id IS NULL ) ) )
    AND ( ( Recinfo.program_id = x_program_id )
        OR ( ( Recinfo.program_id IS NULL )
          AND (  x_program_id IS NULL ) ) )
    AND ( ( Recinfo.program_login_id = x_program_login_id )
        OR ( ( Recinfo.program_login_id IS NULL )
          AND (  x_program_login_id IS NULL ) ) )
    AND ( ( Recinfo.program_application_id = x_program_application_id )
        OR ( ( Recinfo.program_application_id IS NULL )
          AND (  x_program_application_id IS NULL ) ) )
    AND ( ( Recinfo.request_id = x_request_id )
        OR ( ( Recinfo.request_id IS NULL )
          AND (  x_request_id IS NULL ) ) )
    ) THEN
      RETURN;
    ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.GEOGRAPHY_TYPE_NAME = X_GEOGRAPHY_TYPE_NAME)
               OR ((tlinfo.GEOGRAPHY_TYPE_NAME is null) AND (X_GEOGRAPHY_TYPE_NAME is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
END Lock_Row;

PROCEDURE Select_Row (
    x_geography_type                        IN OUT NOCOPY VARCHAR2,
    x_object_version_number                 OUT    NOCOPY NUMBER,
    x_geography_use                         OUT    NOCOPY VARCHAR2,
    x_postal_code_range_flag                OUT    NOCOPY VARCHAR2,
    x_limited_by_geography_id               OUT    NOCOPY NUMBER,
    x_created_by_module                     OUT    NOCOPY VARCHAR2,
    x_application_id                        OUT    NOCOPY NUMBER,
    x_program_login_id                      OUT    NOCOPY NUMBER
) IS
BEGIN

    SELECT
      NVL(geography_type, FND_API.G_MISS_CHAR),
      NVL(geography_use, FND_API.G_MISS_CHAR),
      NVL(postal_code_range_flag, FND_API.G_MISS_CHAR),
      NVL(limited_by_geography_id, FND_API.G_MISS_NUM),
      NVL(created_by_module, FND_API.G_MISS_CHAR),
      NVL(application_id, FND_API.G_MISS_NUM),
      NVL(program_login_id, FND_API.G_MISS_NUM)
    INTO
      x_geography_type,
      x_geography_use,
      x_postal_code_range_flag,
      x_limited_by_geography_id,
      x_created_by_module,
      x_application_id,
      x_program_login_id
    FROM HZ_GEOGRAPHY_TYPES_B
    WHERE geography_type = x_geography_type;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'geography');
      FND_MESSAGE.SET_TOKEN('VALUE', x_geography_type);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    x_geography_type                        IN     VARCHAR2
) IS
BEGIN

  delete from HZ_GEOGRAPHY_TYPES_TL
  where GEOGRAPHY_TYPE = X_GEOGRAPHY_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from HZ_GEOGRAPHY_TYPES_B
  where GEOGRAPHY_TYPE = X_GEOGRAPHY_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
END Delete_Row;

procedure ADD_LANGUAGE
is
begin
  delete from HZ_GEOGRAPHY_TYPES_TL T
  where not exists
    (select NULL
    from HZ_GEOGRAPHY_TYPES_B B
    where B.GEOGRAPHY_TYPE = T.GEOGRAPHY_TYPE
    );

  update HZ_GEOGRAPHY_TYPES_TL T set (
      GEOGRAPHY_TYPE_NAME
    ) = (select
      B.GEOGRAPHY_TYPE_NAME
    from HZ_GEOGRAPHY_TYPES_TL B
    where B.GEOGRAPHY_TYPE = T.GEOGRAPHY_TYPE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.GEOGRAPHY_TYPE,
      T.LANGUAGE
  ) in (select
      SUBT.GEOGRAPHY_TYPE,
      SUBT.LANGUAGE
    from HZ_GEOGRAPHY_TYPES_TL SUBB, HZ_GEOGRAPHY_TYPES_TL SUBT
    where SUBB.GEOGRAPHY_TYPE = SUBT.GEOGRAPHY_TYPE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.GEOGRAPHY_TYPE_NAME <> SUBT.GEOGRAPHY_TYPE_NAME
      or (SUBB.GEOGRAPHY_TYPE_NAME is null and SUBT.GEOGRAPHY_TYPE_NAME is not null)
      or (SUBB.GEOGRAPHY_TYPE_NAME is not null and SUBT.GEOGRAPHY_TYPE_NAME is null)
  ));

  insert into HZ_GEOGRAPHY_TYPES_TL (
    GEOGRAPHY_TYPE,
    GEOGRAPHY_TYPE_NAME,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
    CREATED_BY_MODULE
  ) select
    B.GEOGRAPHY_TYPE,
    B.GEOGRAPHY_TYPE_NAME,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    B.CREATED_BY_MODULE
  from HZ_GEOGRAPHY_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from HZ_GEOGRAPHY_TYPES_TL T
    where T.GEOGRAPHY_TYPE = B.GEOGRAPHY_TYPE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE translate_row (
  x_geography_type      IN VARCHAR2,
  x_geography_type_name IN VARCHAR2,
  x_owner               IN VARCHAR2) IS

BEGIN
    UPDATE HZ_GEOGRAPHY_TYPES_TL
      SET geography_type_name = x_geography_type_name,
          source_lang = userenv('LANG'),
          last_update_date = sysdate,
          last_updated_by = DECODE(x_owner, 'SEED', 1, 0),
          last_update_login = 0
    WHERE geography_type = x_geography_type
    AND   userenv('LANG') IN (language, source_lang);

END translate_row;

PROCEDURE LOAD_ROW (
   x_geography_type                        IN  VARCHAR2,
   x_geography_type_name                   IN  VARCHAR2,
   x_object_version_number                 IN     NUMBER,
   x_geography_use                         IN     VARCHAR2,
   x_postal_code_range_flag                IN     VARCHAR2,
   x_limited_by_geography_id               IN     NUMBER,
   x_created_by_module                     IN     VARCHAR2,
   x_application_id                        IN     NUMBER,
   x_program_login_id                      IN     NUMBER,
   X_OWNER in VARCHAR2
      ) IS

   l_user_id            NUMBER;
   l_row_id             ROWID; --varchar2(64);

  BEGIN

    l_user_id := NVL(fnd_load_util.owner_id(X_OWNER),FND_GLOBAL.USER_ID);

    BEGIN

     -- check for existance of data
     SELECT rowid
     INTO   l_row_id
     FROM   hz_geography_types_b
     WHERE  geography_type = x_geography_type;

     -- data exists in hz_geography_types_b table. Now Update it.
     -- cannot use update_row package directly because it has last_updated_by as
     -- hz_utility_v2pub.last_updated_by which cannot be used for seed data loading
     UPDATE HZ_GEOGRAPHY_TYPES_B
     SET
      object_version_number =
	    DECODE(x_object_version_number,
               NULL, object_version_number,
               x_object_version_number),
      geography_use =
        DECODE(x_geography_use,
               NULL, geography_use,
               x_geography_use),
      postal_code_range_flag =
        DECODE(x_postal_code_range_flag,
               NULL, postal_code_range_flag,
               x_postal_code_range_flag),
      limited_by_geography_id =
        DECODE(x_limited_by_geography_id,
               NULL, limited_by_geography_id,
               FND_API.G_MISS_NUM, NULL,
               x_limited_by_geography_id),
      last_updated_by = l_user_id,
      last_update_date = hz_utility_v2pub.last_update_date,
      last_update_login = hz_utility_v2pub.last_update_login,
      application_id =
        DECODE(x_application_id,
               NULL, application_id,
               FND_API.G_MISS_NUM, NULL,
               x_application_id),
      program_login_id =
        DECODE(x_program_login_id,
               NULL, program_login_id,
               FND_API.G_MISS_NUM, NULL,
               x_program_login_id)
    WHERE rowid = l_row_id;

    -- so far hz_geography_types_b table has data. Now update tl table

    UPDATE HZ_GEOGRAPHY_TYPES_TL SET
	    GEOGRAPHY_TYPE_NAME = decode(X_GEOGRAPHY_TYPE_NAME,
	                                 NULL, GEOGRAPHY_TYPE_NAME,
	                                 FND_API.G_MISS_NUM, NULL,
	                                 X_GEOGRAPHY_TYPE_NAME),
	    LAST_UPDATE_DATE =    decode(X_GEOGRAPHY_TYPE_NAME, NULL, LAST_UPDATE_DATE,
	                                 hz_utility_v2pub.last_update_date),
	    LAST_UPDATED_BY =     decode(X_GEOGRAPHY_TYPE_NAME, NULL, LAST_UPDATED_BY,
		                             l_user_id),
	    LAST_UPDATE_LOGIN =   decode(X_GEOGRAPHY_TYPE_NAME, NULL, LAST_UPDATE_LOGIN,
		                             FND_API.G_MISS_NUM, NULL,
		                             l_user_id),
	    SOURCE_LANG = USERENV('LANG')
	WHERE GEOGRAPHY_TYPE = X_GEOGRAPHY_TYPE
	AND   USERENV('LANG') in (LANGUAGE, SOURCE_LANG);

    IF (SQL%NOTFOUND) THEN
      -- data exist in hz_geography_types_b table but not in hz_geography_types_tl
	  RAISE no_data_found;
	END IF;

    EXCEPTION WHEN NO_DATA_FOUND THEN -- insert data
     BEGIN
      -- check if we need to insert data in hz_geography_types_b
      -- if l_row_id is NULL and no_data_found is raised, it means we have
      -- to insert in hz_geography_types_b table.
      IF (l_row_id IS NULL) THEN
          -- We cannot use insert_row procedure because it puts user_ids of logged in user
	      INSERT INTO HZ_GEOGRAPHY_TYPES_B (
	        geography_type,
	        object_version_number,
	        geography_use,
	        postal_code_range_flag,
	        limited_by_geography_id,
	        created_by_module,
	        last_updated_by,
	        creation_date,
	        created_by,
	        last_update_date,
	        last_update_login,
	        application_id,
	        program_id,
	        program_login_id,
	        program_application_id,
	        request_id
	      )
	      VALUES (x_geography_type,
                 1,
	             x_geography_use,
	             x_postal_code_range_flag,
	             DECODE(x_limited_by_geography_id,
	                   FND_API.G_MISS_NUM, NULL,
	                   x_limited_by_geography_id),
                 x_created_by_module,
	             l_user_id,
	             hz_utility_v2pub.creation_date,
	             l_user_id,
	             hz_utility_v2pub.last_update_date,
	             hz_utility_v2pub.last_update_login,
  	             DECODE(x_application_id,
	                    FND_API.G_MISS_NUM, NULL,
	                    x_application_id),
	             hz_utility_v2pub.program_id,
	             DECODE(x_program_login_id,
	                    FND_API.G_MISS_NUM, NULL,
	                    x_program_login_id),
	             hz_utility_v2pub.program_application_id,
	             hz_utility_v2pub.request_id
	       ) ;
       END IF;

       INSERT INTO HZ_GEOGRAPHY_TYPES_TL (
		    GEOGRAPHY_TYPE,
		    GEOGRAPHY_TYPE_NAME,
		    CREATED_BY_MODULE,
		    LAST_UPDATED_BY,
		    CREATION_DATE,
		    CREATED_BY,
		    LAST_UPDATE_DATE,
		    LAST_UPDATE_LOGIN,
		    APPLICATION_ID,
		    PROGRAM_ID,
		    PROGRAM_LOGIN_ID,
		    PROGRAM_APPLICATION_ID,
		    REQUEST_ID,
		    LANGUAGE,
		    SOURCE_LANG
		  ) SELECT
		    x_geography_type,
		    DECODE(x_geography_type_name,
		           FND_API.G_MISS_CHAR, NULL,
		           x_geography_type_name),
		    x_created_by_module,
		    l_user_id,
		    hz_utility_v2pub.creation_date,
		    l_user_id,
		    hz_utility_v2pub.last_update_date,
		    hz_utility_v2pub.last_update_login,
		    DECODE(x_application_id,
		           FND_API.G_MISS_NUM, NULL,
		           x_application_id),
		    hz_utility_v2pub.program_id,
		    DECODE(x_program_login_id,
		           FND_API.G_MISS_NUM, NULL,
		           x_program_login_id),
		    hz_utility_v2pub.program_application_id,
		    hz_utility_v2pub.request_id,
		    L.LANGUAGE_CODE,
		    USERENV('LANG')
	   FROM FND_LANGUAGES L
	   WHERE L.INSTALLED_FLAG in ('I', 'B')
	   AND NOT EXISTS (SELECT NULL
		               FROM HZ_GEOGRAPHY_TYPES_TL T
		               WHERE T.GEOGRAPHY_TYPE = X_GEOGRAPHY_TYPE
		               AND T.LANGUAGE = L.LANGUAGE_CODE);

    EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
       NULL;
    END;

  END; -- for main table

END LOAD_ROW;

END HZ_GEOGRAPHY_TYPES_PKG;

/
