--------------------------------------------------------
--  DDL for Package Body HZ_DSS_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DSS_GROUPS_PKG" AS
/* $Header: ARHPDSGB.pls 120.2 2005/06/16 21:13:28 jhuang noship $ */

PROCEDURE Insert_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_dss_group_code                        IN     VARCHAR2,
    x_rank                                  IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_dss_group_name                        IN     VARCHAR2,
    x_description                           IN     VARCHAR2,
    x_bes_enable_flag                       IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER
) IS

    l_success                               VARCHAR2(1) := 'N';

BEGIN

    WHILE l_success = 'N' LOOP
    BEGIN
      INSERT INTO HZ_DSS_GROUPS_B (
        dss_group_code,
        rank,
        status,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        bes_enable_flag,
        object_version_number
      )
      VALUES (
        DECODE(x_dss_group_code,
               FND_API.G_MISS_CHAR, NULL, x_dss_group_code),
        DECODE(x_rank,
               FND_API.G_MISS_NUM, NULL,
               x_rank),
        DECODE(x_status,
               FND_API.G_MISS_CHAR, 'A',
               NULL, 'A',
               x_status),
        hz_utility_v2pub.last_update_date,
        hz_utility_v2pub.last_updated_by,
        hz_utility_v2pub.creation_date,
        hz_utility_v2pub.created_by,
        hz_utility_v2pub.last_update_login,
        DECODE(x_bes_enable_flag,
               FND_API.G_MISS_CHAR, NULL,
               x_bes_enable_flag),
        DECODE(x_object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number)
      ) RETURNING
        rowid
      INTO
        x_rowid;

      INSERT INTO HZ_DSS_GROUPS_TL (
        dss_group_code,
        language,
        source_lang,
        dss_group_name,
        description,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login
      )
        SELECT
        x_dss_group_code,
        L.LANGUAGE_CODE,
        B.LANGUAGE_CODE,
        x_dss_group_name,
        x_description,
        hz_utility_v2pub.last_update_date,
        hz_utility_v2pub.last_updated_by,
        hz_utility_v2pub.creation_date,
        hz_utility_v2pub.created_by,
        hz_utility_v2pub.last_update_login
        FROM
         FND_LANGUAGES L, FND_LANGUAGES B
        WHERE L.INSTALLED_FLAG in ('I', 'B')
         and B.INSTALLED_FLAG = 'B'
         and not exists
         (SELECT NULL
             FROM HZ_DSS_GROUPS_TL T
             WHERE T.dss_group_code = x_dss_group_code AND
             T.LANGUAGE = L.LANGUAGE_CODE);
      l_success := 'Y';

    END;

    END LOOP;



END Insert_Row;

PROCEDURE Update_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
 -- x_dss_group_code                        IN     VARCHAR2,
    x_rank                                  IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_dss_group_name                        IN     VARCHAR2,
    x_description                           IN     VARCHAR2,
    x_bes_enable_flag                       IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER
) IS
l_dss_group_code varchar2(30);
BEGIN

    UPDATE HZ_DSS_GROUPS_B
    SET
      rank =
        DECODE(x_rank,
               NULL, rank,
               FND_API.G_MISS_NUM, NULL,
               x_rank),
      status =
        DECODE(x_status,
               NULL, status,
               FND_API.G_MISS_CHAR, NULL,
               x_status),
      last_update_date = hz_utility_v2pub.last_update_date,
      last_updated_by = hz_utility_v2pub.last_updated_by,
      creation_date = creation_date,
      created_by = created_by,
      last_update_login = hz_utility_v2pub.last_update_login,
      bes_enable_flag =
        DECODE(x_bes_enable_flag,
               NULL, bes_enable_flag,
               FND_API.G_MISS_CHAR, NULL,
               x_bes_enable_flag),
      object_version_number=
        DECODE(x_object_version_number,
               NULL, object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number)
    WHERE rowid = x_rowid
    returning dss_group_code into l_dss_group_code  ;
    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    UPDATE HZ_DSS_GROUPS_TL
    SET
      source_lang =
        DECODE(USERENV('LANG'),
               NULL, source_lang,
               FND_API.G_MISS_CHAR, NULL,
               USERENV('LANG') ),
      dss_group_name =
        DECODE(x_dss_group_name,
               NULL, dss_group_name,
               FND_API.G_MISS_CHAR, NULL,
               x_dss_group_name),
      description =
        DECODE(x_description,
               NULL, description,
               FND_API.G_MISS_CHAR, NULL,
               x_description),
      last_update_date = hz_utility_v2pub.last_update_date,
      last_updated_by = hz_utility_v2pub.last_updated_by,
      last_update_login = hz_utility_v2pub.last_update_login

    WHERE dss_group_code = l_dss_group_code AND
    USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Update_Row;

PROCEDURE Lock_Row (
    x_rowid                                 IN OUT NOCOPY VARCHAR2,
    x_dss_group_code                        IN     VARCHAR2,
    x_rank                                  IN     NUMBER,
    x_status                                IN     VARCHAR2,
    x_last_update_date                      IN     DATE,
    x_last_updated_by                       IN     NUMBER,
    x_creation_date                         IN     DATE,
    x_created_by                            IN     NUMBER,
    x_last_update_login                     IN     NUMBER,
    x_bes_enable_flag                       IN     VARCHAR2,
    x_object_version_number                 IN     NUMBER
) IS

    CURSOR c IS
      SELECT * FROM hz_dss_groups_b
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;
    Recinfo c%ROWTYPE;

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
        ( ( Recinfo.dss_group_code = x_dss_group_code )
        OR ( ( Recinfo.dss_group_code IS NULL )
          AND (  x_dss_group_code IS NULL ) ) )
    AND ( ( Recinfo.rank = x_rank )
        OR ( ( Recinfo.rank IS NULL )
          AND (  x_rank IS NULL ) ) )
    AND ( ( Recinfo.status = x_status )
        OR ( ( Recinfo.status IS NULL )
          AND (  x_status IS NULL ) ) )
    AND ( ( Recinfo.last_update_date = x_last_update_date )
        OR ( ( Recinfo.last_update_date IS NULL )
          AND (  x_last_update_date IS NULL ) ) )
    AND ( ( Recinfo.last_updated_by = x_last_updated_by )
        OR ( ( Recinfo.last_updated_by IS NULL )
          AND (  x_last_updated_by IS NULL ) ) )
    AND ( ( Recinfo.creation_date = x_creation_date )
        OR ( ( Recinfo.creation_date IS NULL )
          AND (  x_creation_date IS NULL ) ) )
    AND ( ( Recinfo.created_by = x_created_by )
        OR ( ( Recinfo.created_by IS NULL )
          AND (  x_created_by IS NULL ) ) )
    AND ( ( Recinfo.last_update_login = x_last_update_login )
        OR ( ( Recinfo.last_update_login IS NULL )
          AND (  x_last_update_login IS NULL ) ) )
    AND ( ( Recinfo.bes_enable_flag = x_bes_enable_flag )
        OR ( ( Recinfo.bes_enable_flag IS NULL )
          AND (  x_bes_enable_flag IS NULL ) ) )
    AND ( ( Recinfo.object_version_number = x_object_version_number)
        OR ( ( Recinfo.object_version_number IS NULL )
          AND (  x_object_version_number IS NULL ) ) )
    ) THEN
      RETURN;
    ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

END Lock_Row;

PROCEDURE Select_Row (
    x_dss_group_code                        IN OUT NOCOPY VARCHAR2,
    x_rank                                  OUT    NOCOPY NUMBER,
    x_status                                OUT    NOCOPY VARCHAR2,
    x_dss_group_name                        OUT     NOCOPY VARCHAR2,
    x_description                           OUT    NOCOPY VARCHAR2,
    x_bes_enable_flag                       OUT    NOCOPY VARCHAR2,
    x_object_version_number                 OUT    NOCOPY NUMBER

) IS
x_dummy1 VARCHAR2(2000); x_dummy2 varchar2(2000);
BEGIN

    SELECT
      NVL(dss_group_code, FND_API.G_MISS_CHAR),
      NVL(rank, FND_API.G_MISS_NUM),
      NVL(status, FND_API.G_MISS_CHAR),
      NVL(bes_enable_flag, FND_API.G_MISS_CHAR),
      NVL(object_version_number, FND_API.G_MISS_NUM)
    INTO
      x_dss_group_code,
      x_rank,
      x_status,
      x_bes_enable_flag,
      x_object_version_number
    FROM HZ_DSS_GROUPS_B
    WHERE dss_group_code = x_dss_group_code;


    SELECT
      NVL(dss_group_code, FND_API.G_MISS_CHAR),
      NVL(dss_group_name, FND_API.G_MISS_CHAR),
      NVL(description, FND_API.G_MISS_CHAR)
    INTO
      x_dss_group_code, x_dummy1, x_dummy2
    FROM HZ_DSS_GROUPS_TL
    WHERE dss_group_code = x_dss_group_code AND
    USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
      FND_MESSAGE.SET_TOKEN('RECORD', 'dss_group_rec');
      FND_MESSAGE.SET_TOKEN('VALUE', x_dss_group_code);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    x_dss_group_code                        IN     VARCHAR2
) IS
BEGIN

    DELETE FROM HZ_DSS_GROUPS_B
    WHERE dss_group_code = x_dss_group_code;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    DELETE FROM HZ_DSS_GROUPS_TL
    WHERE dss_group_code = x_dss_group_code;

    IF ( SQL%NOTFOUND ) THEN
      RAISE NO_DATA_FOUND;
    END IF;

END Delete_Row;



procedure ADD_LANGUAGE
is
begin
  delete from HZ_DSS_GROUPS_TL T
  where not exists
    (select NULL
    from HZ_DSS_GROUPS_B B
    where B.DSS_GROUP_CODE = T.DSS_GROUP_CODE
    );

  update HZ_DSS_GROUPS_TL T set (
      DSS_GROUP_CODE,
      DESCRIPTION
    ) = (select
      B.DSS_GROUP_NAME,
      B.DESCRIPTION
    from HZ_DSS_GROUPS_TL B
    where B.DSS_GROUP_CODE = T.DSS_GROUP_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DSS_GROUP_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.DSS_GROUP_CODE,
      SUBT.LANGUAGE
    from HZ_DSS_GROUPS_TL SUBB, HZ_DSS_GROUPS_TL SUBT
    where SUBB.DSS_GROUP_CODE = SUBT.DSS_GROUP_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DSS_GROUP_NAME <> SUBT.DSS_GROUP_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into HZ_DSS_GROUPS_TL (
   DSS_GROUP_CODE,
   DSS_GROUP_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.DSS_GROUP_CODE,
    B.DSS_GROUP_NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from HZ_DSS_GROUPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from HZ_DSS_GROUPS_TL T
    where T.DSS_GROUP_CODE = B.DSS_GROUP_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


procedure LOAD_ROW (
  X_DSS_GROUP_CODE in VARCHAR2,
  X_DATABASE_OBJECT_NAME in VARCHAR2,
  X_DSS_GROUP_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,  -- "SEED" or "CUSTOM"
  X_LAST_UPDATE_DATE in DATE,
  X_CUSTOM_MODE in VARCHAR2,
  X_RANK in NUMBER,
  X_STATUS in VARCHAR2,
  X_BES_ENABLE_FLAG  IN     VARCHAR2,
  X_OBJECT_VERSION_NUMBER IN     NUMBER
) is
  l_f_luby    number;  -- entity owner in file
  l_f_ludate  date;    -- entity update date in file
  l_db_luby   number;  -- entity owner in db
  l_db_ludate date;    -- entity update date in db
  l_rowid     varchar2(64);

begin

  -- Translate owner to file_last_updated_by
  if (x_owner = 'SEED') then
    l_f_luby := 1;
  else
    l_f_luby := 0;
  end if;

  -- Get last update date of ldt entity
  l_f_ludate := nvl(x_last_update_date, sysdate);

  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
         into l_db_luby, l_db_ludate
         from HZ_DSS_GROUPS_B
         where DSS_GROUP_CODE = x_dss_group_code;

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date

    if ((x_custom_mode = 'FORCE') or
       ((l_f_luby = 0) and (l_db_luby = 1)) or
       ((l_f_luby = l_db_luby) and (l_f_ludate > l_db_ludate)))
    then
      hz_dss_groups_pkg.update_row (
        X_ROWID                    => L_ROWID,
      --X_DSS_GROUP_CODE           => X_DSS_GROUP_CODE,
        X_RANK                     => X_RANK,
        X_STATUS                   => X_STATUS,
        X_DSS_GROUP_NAME           => X_DSS_GROUP_NAME,
        X_DESCRIPTION          => X_DESCRIPTION,
        X_BES_ENABLE_FLAG      => X_BES_ENABLE_FLAG,
        X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER
      );
    end if;

  exception
    when no_data_found then
      -- record not found, insert in all cases
      hz_dss_groups_pkg.insert_row(
          x_rowid                => l_rowid,
          x_dss_group_code       => X_DSS_GROUP_CODE,
          x_rank                 =>  x_rank,
          x_status               =>  x_status,
          x_dss_group_name       => X_DSS_GROUP_NAME,
          x_description          => X_DESCRIPTION,
          x_bes_enable_flag      => x_bes_enable_flag,
          x_object_version_number => x_object_version_number
      );
  end;

end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_DSS_GROUP_CODE in VARCHAR2,
  X_DSS_GROUP_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,  -- "SEED" or "CUSTOM"
  X_LAST_UPDATE_DATE in DATE,
  X_CUSTOM_MODE in VARCHAR2
) is
  l_f_luby    number;  -- entity owner in file
  l_f_ludate  date;    -- entity update date in file
  l_db_luby   number;  -- entity owner in db
  l_db_ludate date;    -- entity update date in db
begin
  -- Translate owner to file_last_updated_by
  if (x_owner = 'SEED') then
    l_f_luby := 1;
  else
    l_f_luby := 0;
  end if;

  -- Get last update date of ldt entity
  l_f_ludate := nvl(x_last_update_date, sysdate);

  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
         into l_db_luby, l_db_ludate
         from HZ_DSS_GROUPS_TL
         where DSS_GROUP_CODE = x_dss_group_code
           and LANGUAGE = userenv('LANG');

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date

    if ((x_custom_mode = 'FORCE') or
       ((l_f_luby = 0) and (l_db_luby = 1)) or
       ((l_f_luby = l_db_luby) and (l_f_ludate > l_db_ludate)))
    then
      update HZ_DSS_GROUPS_TL
         set DSS_GROUP_NAME        = nvl(X_DSS_GROUP_NAME,DSS_GROUP_NAME),
             DESCRIPTION       = nvl(X_DESCRIPTION,DESCRIPTION),
             LAST_UPDATE_DATE  = l_f_ludate,
             LAST_UPDATED_BY   = l_f_luby,
             LAST_UPDATE_LOGIN = 0,
             SOURCE_LANG       = userenv('LANG')
       where DSS_GROUP_CODE = X_DSS_GROUP_CODE
         and userenv('LANG') in (LANGUAGE, SOURCE_LANG);
    end if;
  exception
    when no_data_found then
      null;  -- no translation found.  standards say do nothing.
  end;

end TRANSLATE_ROW;


END HZ_DSS_GROUPS_PKG;

/
