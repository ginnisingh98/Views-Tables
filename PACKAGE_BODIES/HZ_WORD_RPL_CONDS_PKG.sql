--------------------------------------------------------
--  DDL for Package Body HZ_WORD_RPL_CONDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_WORD_RPL_CONDS_PKG" as
/*$Header: ARHWRCDB.pls 120.4 2005/06/02 22:51:23 cvijayan noship $ */

PROCEDURE Insert_Row (
    x_condition_id                          IN  OUT NOCOPY NUMBER,
    x_entity                                IN VARCHAR2,
    x_condition_function                    IN VARCHAR2,
    x_condition_val_fmt_flag                IN VARCHAR2,
    x_condition_name                        IN VARCHAR2,
    x_condition_description                 IN VARCHAR2,
    x_object_version_number                 IN  NUMBER
) IS


   CURSOR C2 IS SELECT   HZ_WORD_RPL_CONDS_S.nextval FROM sys.dual ;
   l_success  VARCHAR2(1) := 'N';

BEGIN

    WHILE l_success = 'N' LOOP
    BEGIN
        IF ( X_CONDITION_ID IS NULL) OR (X_CONDITION_ID = FND_API.G_MISS_NUM) THEN
        OPEN C2;
        FETCH C2 INTO X_CONDITION_ID;
        CLOSE C2;
        END IF;

        INSERT INTO HZ_WORD_RPL_CONDS_B(
        condition_id,
        entity,
        condition_function,
        condition_val_fmt_flag,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        object_version_number
      )
      VALUES (
        x_condition_id,
        DECODE(x_entity,
               FND_API.G_MISS_CHAR, NULL,
               x_entity),
        DECODE(x_condition_function,
               FND_API.G_MISS_CHAR, NULL,
               x_condition_function),
        DECODE(x_condition_val_fmt_flag,
               FND_API.G_MISS_CHAR, NULL,
               x_condition_val_fmt_flag),
        hz_utility_v2pub.last_update_date,
        hz_utility_v2pub.last_updated_by,
        hz_utility_v2pub.creation_date,
        hz_utility_v2pub.created_by,
        hz_utility_v2pub.last_update_login,
        DECODE(x_object_version_number,
               FND_API.G_MISS_NUM, NULL,
               x_object_version_number)
      ) ;

      INSERT INTO HZ_WORD_RPL_CONDS_TL (
        condition_id,
        condition_name,
        condition_description,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        language,
        source_lang,
        object_version_number
        )
        SELECT
        x_condition_id,
        x_condition_name,
        x_condition_description,
        hz_utility_v2pub.last_update_date,
        hz_utility_v2pub.last_updated_by,
        hz_utility_v2pub.creation_date,
        hz_utility_v2pub.created_by,
        hz_utility_v2pub.last_update_login,
        L.LANGUAGE_CODE,
        userenv('LANG'),
        x_object_version_number
        FROM FND_LANGUAGES L
        where L.INSTALLED_FLAG in ('I', 'B')
        and not exists
            (select NULL
             from HZ_WORD_RPL_CONDS_TL T
             where T.CONDITION_ID = X_CONDITION_ID
             and T.LANGUAGE = L.LANGUAGE_CODE);
       l_success := 'Y';
    END;

    END LOOP;

END Insert_Row;


procedure Update_Row (
    x_condition_id                          IN  NUMBER,
    x_entity                                IN VARCHAR2,
    x_condition_function                    IN VARCHAR2,
    x_condition_val_fmt_flag                IN VARCHAR2,
    x_condition_name                        IN VARCHAR2,
    x_condition_description                 IN VARCHAR2,
    x_object_version_number                 IN  OUT NOCOPY NUMBER
)
IS
   p_object_version_number NUMBER ;
BEGIN
   p_object_version_number := NVL(x_object_version_number, 1) + 1;

 UPDATE HZ_WORD_RPL_CONDS_B set
        entity = x_entity,
        condition_function = x_condition_function,
        condition_val_fmt_flag = x_condition_val_fmt_flag,
        object_version_number = p_object_version_number,
        last_update_date = hz_utility_v2pub.last_update_date,
        last_updated_by = hz_utility_v2pub.last_updated_by,
        last_update_login = hz_utility_v2pub.last_update_login
  where condition_id = x_condition_id ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update HZ_WORD_RPL_CONDS_TL set
        condition_name = x_condition_name,
        condition_description = x_condition_description,
        object_version_number = p_object_version_number,
        last_update_date = hz_utility_v2pub.last_update_date,
        last_updated_by = hz_utility_v2pub.last_updated_by,
        last_update_login = hz_utility_v2pub.last_update_login,
        source_lang = userenv('LANG')
  where condition_id = x_condition_id
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  x_object_version_number := p_object_version_number ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

END ;


procedure Delete_Row (
  x_condition_id in NUMBER
)
IS
BEGIN
  delete from HZ_WORD_RPL_CONDS_B
  where condition_id = x_condition_id ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from HZ_WORD_RPL_CONDS_TL
  where condition_id = x_condition_id ;

  if (sql%notfound) then
    raise no_data_found;
  end if;
END ;

procedure Lock_Row (
  x_condition_id in NUMBER,
  x_object_version_number in  NUMBER
)
IS
 cursor c is select
    object_version_number
    from HZ_WORD_RPL_CONDS_B
    where condition_id = x_condition_id
    for update of condition_id nowait;

recinfo c%rowtype;

BEGIN

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
  delete from HZ_WORD_RPL_CONDS_TL T
  where not exists
    (select NULL
    from HZ_WORD_RPL_CONDS_B B
    where B.condition_id = T.condition_id
    );

  update HZ_WORD_RPL_CONDS_TL T set (
      condition_name,
      condition_description,
      object_version_number                         ------> VJN Introduced for Bug 4397811
    ) = (select
      B.condition_name,
      B.condition_description,
      NVL(T.object_version_number, 1) + 1           ------> VJN Introduced for Bug 4397811
    from HZ_WORD_RPL_CONDS_TL B
    where B.condition_id = T.condition_id
    and B.language = T.source_lang)
  where (
         T.condition_id,
         T.language
  ) in (select
      SUBT.condition_id,
      SUBT.language
    from HZ_WORD_RPL_CONDS_TL SUBB, HZ_WORD_RPL_CONDS_TL SUBT
    where SUBB.condition_id = SUBT.condition_id
    and SUBB.language = SUBT.source_lang
    and (SUBB.condition_name <> SUBT.condition_name
      or SUBB.condition_description <> SUBT.condition_description
      or (SUBB.condition_description is null and SUBT.condition_description is not null)
      or (SUBB.condition_description is not null and SUBT.condition_description is null)
  ));

  insert into HZ_WORD_RPL_CONDS_TL (
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    CONDITION_DESCRIPTION,
    CONDITION_NAME,
    CONDITION_ID,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG,
    OBJECT_VERSION_NUMBER                             ------> VJN Introduced for Bug 4397811
  ) select
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.CONDITION_DESCRIPTION,
    B.CONDITION_NAME,
    B.CONDITION_ID,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    1                                                ------> VJN Introduced for Bug 4397811
  from HZ_WORD_RPL_CONDS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from HZ_WORD_RPL_CONDS_TL T
    where T.condition_id = B.condition_id
    and T.language = L.language_code );
END ;


procedure Load_Row (
    x_condition_id                          IN  OUT NOCOPY NUMBER,
    x_entity                                IN VARCHAR2,
    x_condition_function                    IN VARCHAR2,
    x_condition_val_fmt_flag                IN VARCHAR2,
    x_condition_name                        IN VARCHAR2,
    x_condition_description                 IN VARCHAR2,
    x_object_version_number                 IN  NUMBER,
    x_last_update_date                      IN DATE,
    x_last_updated_by                       IN NUMBER,
    x_last_update_login                     IN NUMBER,
    x_owner                                 IN VARCHAR2,
    x_custom_mode                           IN VARCHAR2
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
         from HZ_WORD_RPL_CONDS_B
         where condition_id = x_condition_id ;

    -- Update record, honoring customization mode.
    -- Record should be updated only if:
    -- a. CUSTOM_MODE = FORCE, or
    -- b. file owner is CUSTOM, db owner is SEED
    -- c. owners are the same, and file_date > db_date

   IF ((x_custom_mode = 'FORCE') or
       ((l_f_luby = 0) and (l_db_luby = 1)) or
       ((l_f_luby = l_db_luby) and (l_f_ludate > l_db_ludate)))
   THEN

    HZ_WORD_RPL_CONDS_PKG.UPDATE_ROW(
    x_condition_id => x_condition_id,
    x_entity => x_entity,
    x_condition_function => x_condition_function,
    x_condition_val_fmt_flag => x_condition_val_fmt_flag,
    x_condition_name => x_condition_name,
    x_condition_description => x_condition_description,
    x_object_version_number  => l_object_version_number
    );
   END IF ;

   EXCEPTION
       WHEN NO_DATA_FOUND
       THEN

          HZ_WORD_RPL_CONDS_PKG.INSERT_ROW(
          x_condition_id => x_condition_id,
          x_entity => x_entity,
          x_condition_function => x_condition_function,
          x_condition_val_fmt_flag => x_condition_val_fmt_flag,
          x_condition_name => x_condition_name,
          x_condition_description => x_condition_description,
          x_object_version_number  => x_object_version_number
          );

   END ;

END ;

-- update rows that have not been altered by user
procedure Translate_Row (
  x_condition_id in NUMBER,
  x_condition_name in VARCHAR2,
  x_condition_description in VARCHAR2,
  x_owner in VARCHAR2)
IS
BEGIN

 UPDATE HZ_WORD_RPL_CONDS_TL set
 condition_name = x_condition_name,
 condition_description = x_condition_description,
 source_lang = userenv('LANG'),
 last_update_date = sysdate,
 last_updated_by = decode(x_owner, 'SEED', 1, 0),
 last_update_login = 0
 where condition_id = x_condition_id
 and   userenv('LANG') in (language, source_lang);

END ;


END HZ_WORD_RPL_CONDS_PKG  ;


/
