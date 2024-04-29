--------------------------------------------------------
--  DDL for Package Body MTL_CATEGORY_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_CATEGORY_SETS_PKG" as
/* $Header: INVICSHB.pls 120.4 2006/06/05 12:08:59 lparihar ship $ */

-- ----------------------------------------------------------------------
-- PROCEDURE:  Insert_Row
-- ----------------------------------------------------------------------

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CATEGORY_SET_ID in NUMBER,
  X_CATEGORY_SET_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_STRUCTURE_ID in NUMBER,
  X_VALIDATE_FLAG in VARCHAR2,
  X_MULT_ITEM_CAT_ASSIGN_FLAG IN VARCHAR2,
  X_CONTROL_LEVEL_UPDT_FLAG   IN VARCHAR2 DEFAULT NULL,
  X_MULT_ITEM_CAT_UPDT_FLAG   IN VARCHAR2 DEFAULT NULL,
  X_VALIDATE_FLAG_UPDT_FLAG   IN VARCHAR2 DEFAULT NULL,
  X_HIERARCHY_ENABLED         IN VARCHAR2 DEFAULT NULL,
  X_CONTROL_LEVEL in NUMBER,
  X_DEFAULT_CATEGORY_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
--  X_REQUEST_ID in NUMBER,
) is

  cursor C is
    select ROWID
    from  MTL_CATEGORY_SETS_B
    where  CATEGORY_SET_ID = X_CATEGORY_SET_ID ;

begin

  insert into MTL_CATEGORY_SETS_B (
    CATEGORY_SET_ID,
    STRUCTURE_ID,
    VALIDATE_FLAG,
    MULT_ITEM_CAT_ASSIGN_FLAG,
    CONTROL_LEVEL_UPDATEABLE_FLAG,
    MULT_ITEM_CAT_UPDATEABLE_FLAG,
    VALIDATE_FLAG_UPDATEABLE_FLAG,
    HIERARCHY_ENABLED,
    CONTROL_LEVEL,
    DEFAULT_CATEGORY_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
--    REQUEST_ID,
  ) values (
    X_CATEGORY_SET_ID,
    X_STRUCTURE_ID,
    X_VALIDATE_FLAG,
    X_MULT_ITEM_CAT_ASSIGN_FLAG,
    DECODE(UPPER(X_CONTROL_LEVEL_UPDT_FLAG),'N','N',NULL),
    DECODE(UPPER(X_MULT_ITEM_CAT_UPDT_FLAG),'N','N',NULL),
    DECODE(UPPER(X_VALIDATE_FLAG_UPDT_FLAG),'N','N',NULL),
    DECODE(UPPER(X_HIERARCHY_ENABLED),'N','N','Y','Y',NULL),
    X_CONTROL_LEVEL,
    X_DEFAULT_CATEGORY_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN
--    X_REQUEST_ID,
  );

  insert into MTL_CATEGORY_SETS_TL (
    CATEGORY_SET_ID,
    LANGUAGE,
    SOURCE_LANG,
    CATEGORY_SET_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN
  ) select
    X_CATEGORY_SET_ID,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    X_CATEGORY_SET_NAME,
    X_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN
  from  FND_LANGUAGES  L
  where  L.INSTALLED_FLAG in ('I', 'B')
    and  not exists
         ( select NULL
           from  MTL_CATEGORY_SETS_TL T
           where  T.CATEGORY_SET_ID = X_CATEGORY_SET_ID
             and  T.LANGUAGE = L.LANGUAGE_CODE );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

-- ----------------------------------------------------------------------
-- PROCEDURE:  Lock_Row
-- ----------------------------------------------------------------------

procedure LOCK_ROW (
  X_CATEGORY_SET_ID in NUMBER,
  X_CATEGORY_SET_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_STRUCTURE_ID in NUMBER,
  X_VALIDATE_FLAG in VARCHAR2,
  X_MULT_ITEM_CAT_ASSIGN_FLAG in VARCHAR2,
  X_CONTROL_LEVEL in NUMBER,
  X_DEFAULT_CATEGORY_ID in NUMBER
--  X_REQUEST_ID in NUMBER,
) is

  cursor c is
    select
      STRUCTURE_ID,
      VALIDATE_FLAG,
      MULT_ITEM_CAT_ASSIGN_FLAG,
      CONTROL_LEVEL,
      DEFAULT_CATEGORY_ID
--      REQUEST_ID,
    from  MTL_CATEGORY_SETS_B
    where  CATEGORY_SET_ID = X_CATEGORY_SET_ID
    for update of CATEGORY_SET_ID nowait ;

  recinfo c%rowtype;

  cursor c1 is
    select
      CATEGORY_SET_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from  MTL_CATEGORY_SETS_TL
    where  CATEGORY_SET_ID = X_CATEGORY_SET_ID
--    Commented out. All translation rows need to be locked.
--      and  userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CATEGORY_SET_ID nowait ;

begin

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if (    (recinfo.STRUCTURE_ID = X_STRUCTURE_ID)
      AND (recinfo.VALIDATE_FLAG = X_VALIDATE_FLAG)
      AND (recinfo.MULT_ITEM_CAT_ASSIGN_FLAG = X_MULT_ITEM_CAT_ASSIGN_FLAG)
      AND (recinfo.CONTROL_LEVEL = X_CONTROL_LEVEL)
      AND ((recinfo.DEFAULT_CATEGORY_ID = X_DEFAULT_CATEGORY_ID)
           OR ((recinfo.DEFAULT_CATEGORY_ID is null) AND (X_DEFAULT_CATEGORY_ID is null)))
--      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
--           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.CATEGORY_SET_NAME = X_CATEGORY_SET_NAME)
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

-- ----------------------------------------------------------------------
-- PROCEDURE:  Update_Row
-- ----------------------------------------------------------------------

procedure UPDATE_ROW (
  X_CATEGORY_SET_ID           IN NUMBER,
  X_CATEGORY_SET_NAME         IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
  X_DESCRIPTION               IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
  X_STRUCTURE_ID              IN NUMBER   DEFAULT FND_API.G_MISS_NUM,
  X_VALIDATE_FLAG             IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
  X_MULT_ITEM_CAT_ASSIGN_FLAG IN VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
  X_CONTROL_LEVEL_UPDT_FLAG   IN VARCHAR2 DEFAULT NULL,
  X_MULT_ITEM_CAT_UPDT_FLAG   IN VARCHAR2 DEFAULT NULL,
  X_VALIDATE_FLAG_UPDT_FLAG   IN VARCHAR2 DEFAULT NULL,
  X_HIERARCHY_ENABLED         IN VARCHAR2 DEFAULT NULL,
  X_CONTROL_LEVEL             IN NUMBER   DEFAULT FND_API.G_MISS_NUM,
  X_DEFAULT_CATEGORY_ID       IN NUMBER   DEFAULT FND_API.G_MISS_NUM,
  X_LAST_UPDATE_DATE          IN DATE,
  X_LAST_UPDATED_BY           IN NUMBER,
  X_LAST_UPDATE_LOGIN         IN NUMBER

) IS
  l_miss_char VARCHAR2(1) := FND_API.G_MISS_CHAR;
  l_miss_num  NUMBER      := FND_API.G_MISS_NUM;
BEGIN

  update MTL_CATEGORY_SETS_B set
    STRUCTURE_ID                  = DECODE(X_STRUCTURE_ID,l_miss_num,STRUCTURE_ID,X_STRUCTURE_ID),
    VALIDATE_FLAG                 = DECODE(X_VALIDATE_FLAG,l_miss_char,VALIDATE_FLAG,X_VALIDATE_FLAG),
    MULT_ITEM_CAT_ASSIGN_FLAG     = DECODE(X_MULT_ITEM_CAT_ASSIGN_FLAG,l_miss_char,MULT_ITEM_CAT_ASSIGN_FLAG,X_MULT_ITEM_CAT_ASSIGN_FLAG),
    CONTROL_LEVEL_UPDATEABLE_FLAG = DECODE(UPPER(X_CONTROL_LEVEL_UPDT_FLAG),'N','N',NULL),
    MULT_ITEM_CAT_UPDATEABLE_FLAG = DECODE(UPPER(X_MULT_ITEM_CAT_UPDT_FLAG),'N','N',NULL),
    VALIDATE_FLAG_UPDATEABLE_FLAG = DECODE(UPPER(X_VALIDATE_FLAG_UPDT_FLAG),'N','N',NULL),
    HIERARCHY_ENABLED             = DECODE(UPPER(X_HIERARCHY_ENABLED),'N','N','Y','Y',NULL),
    CONTROL_LEVEL                 = DECODE(X_CONTROL_LEVEL,l_miss_num,CONTROL_LEVEL,X_CONTROL_LEVEL),
    DEFAULT_CATEGORY_ID           = DECODE(X_DEFAULT_CATEGORY_ID,l_miss_num,DEFAULT_CATEGORY_ID,X_DEFAULT_CATEGORY_ID),
    LAST_UPDATE_DATE              = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY               = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN             = X_LAST_UPDATE_LOGIN
  where  CATEGORY_SET_ID = X_CATEGORY_SET_ID ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update MTL_CATEGORY_SETS_TL set
    SOURCE_LANG          = userenv('LANG'),
    CATEGORY_SET_NAME    = DECODE(X_CATEGORY_SET_NAME,l_miss_char,CATEGORY_SET_NAME,X_CATEGORY_SET_NAME),
    DESCRIPTION          = DECODE(X_DESCRIPTION,l_miss_char,DESCRIPTION,X_DESCRIPTION),
    LAST_UPDATE_DATE     = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY      = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN    = X_LAST_UPDATE_LOGIN
  where  CATEGORY_SET_ID = X_CATEGORY_SET_ID
  and  userenv('LANG') in (LANGUAGE, SOURCE_LANG) ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

-- ----------------------------------------------------------------------
-- Deletion of categories is not supported.
-- ----------------------------------------------------------------------

procedure DELETE_ROW (
  X_CATEGORY_SET_ID in NUMBER
) is
begin

  raise_application_error( -20000, 'MTL_CATEGORY_SETS_PKG: CANNOT_DELETE_RECORD' );

-- This code is for future use when decided to validate
-- and delete category sets.
/*
  delete from  MTL_CATEGORY_SETS_TL
  where  CATEGORY_SET_ID = X_CATEGORY_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from  MTL_CATEGORY_SETS_B
  where  CATEGORY_SET_ID = X_CATEGORY_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
*/

end DELETE_ROW;


-- ----------------------------------------------------------------------
-- PROCEDURE:  Add_Language
-- ----------------------------------------------------------------------

procedure ADD_LANGUAGE
is
begin

  delete from  MTL_CATEGORY_SETS_TL  T
  where  not exists
         ( select NULL
           from  MTL_CATEGORY_SETS_B B
           where  B.CATEGORY_SET_ID = T.CATEGORY_SET_ID
         );

  update MTL_CATEGORY_SETS_TL T set (
      CATEGORY_SET_NAME,
      DESCRIPTION
    ) = ( select
      B.CATEGORY_SET_NAME,
      B.DESCRIPTION
    from  MTL_CATEGORY_SETS_TL  B
    where  B.CATEGORY_SET_ID = T.CATEGORY_SET_ID
      and  B.LANGUAGE = T.SOURCE_LANG )
  where (
      T.CATEGORY_SET_ID,
      T.LANGUAGE
  ) in ( select
      SUBT.CATEGORY_SET_ID,
      SUBT.LANGUAGE
    from  MTL_CATEGORY_SETS_TL  SUBB,
          MTL_CATEGORY_SETS_TL  SUBT
    where  SUBB.CATEGORY_SET_ID = SUBT.CATEGORY_SET_ID
      and  SUBB.LANGUAGE = SUBT.SOURCE_LANG
      and  ( SUBB.CATEGORY_SET_NAME <> SUBT.CATEGORY_SET_NAME
           or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
           or (SUBB.DESCRIPTION is null     and SUBT.DESCRIPTION is not null )
           or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null ) )
    );

  insert into MTL_CATEGORY_SETS_TL (
    CATEGORY_SET_ID,
    CATEGORY_SET_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CATEGORY_SET_ID,
    B.CATEGORY_SET_NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from  MTL_CATEGORY_SETS_TL  B,
        FND_LANGUAGES         L
  where  L.INSTALLED_FLAG in ('I', 'B')
    and  B.LANGUAGE = userenv('LANG')
    and  not exists
         ( select NULL
           from  MTL_CATEGORY_SETS_TL  T
           where  T.CATEGORY_SET_ID = B.CATEGORY_SET_ID
             and  T.LANGUAGE = L.LANGUAGE_CODE );

end ADD_LANGUAGE;


-- ----------------------------------------------------------------------
-- PROCEDURE:  Translate_Row
--
-- PARAMETERS:
--  x_<developer key>
--  x_<translated columns>
--  x_owner             user owning the row (SEED or other)
--
-- COMMENT:
--  Called from the FNDLOAD config file in 'NLS' mode to upload
--  translations.
-- ----------------------------------------------------------------------

PROCEDURE Translate_Row
(
   x_category_set_id     IN  NUMBER
,  x_category_set_name   IN  VARCHAR2
,  x_description         IN  VARCHAR2
,  x_owner               IN  VARCHAR2
,  x_custom_mode         IN VARCHAR2
,  x_lud                 IN DATE DEFAULT SYSDATE
)
IS

  f_luby         NUMBER;  -- entity owner in file
  f_ludate       DATE;    -- entity update date in file
  db_luby        NUMBER;  -- entity owner in db
  db_ludate      DATE;    -- entity update date in db

BEGIN

  -- Translate owner to file_last_updated_by
  f_luby   := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(to_char(x_lud,'YYYY/MM/DD'), 'YYYY/MM/DD'), sysdate);

  --5103579: Added rownum clause in translate_row.
  SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE
  INTO   db_luby, db_ludate
  FROM   mtl_category_sets_tl
  WHERE  category_set_id = x_category_set_id
  AND    userenv('LANG') IN (language, source_lang)
  AND    ROWNUM = 1;

  IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                   db_ludate, x_custom_mode)) THEN

     UPDATE  mtl_category_sets_tl
     SET  category_set_name = NVL(x_category_set_name, category_set_name)
       ,  description       = NVL(x_description, description)
       ,  last_update_date  = db_ludate
       ,  last_updated_by   = db_luby
       ,  last_update_login = 0
       ,  source_lang       = userenv('LANG')
     WHERE  category_set_id = x_category_set_id
     AND  userenv('LANG') IN (language, source_lang);

  END IF;

END Translate_Row;


-- ----------------------------------------------------------------------
-- PROCEDURE:  Load_Row
--
-- PARAMETERS:
--  x_<developer key>
--  x_<table_data>
--  x_owner             user owning the row (SEED or other)
--
-- COMMENT:
--  Called from the FNDLOAD config file in 'MLS' mode to upload a
--  multi-lingual entity.
-- ----------------------------------------------------------------------

PROCEDURE Load_Row
(
   x_category_set_id      IN  NUMBER
,  x_category_set_name    IN  VARCHAR2
,  x_description          IN  VARCHAR2
,  X_STRUCTURE_ID         IN  NUMBER
,  X_VALIDATE_FLAG        IN  VARCHAR2
,  X_MULT_ITEM_CAT_ASSIGN_FLAG IN VARCHAR2
,  X_CONTROL_LEVEL_UPDT_FLAG   IN VARCHAR2
,  X_MULT_ITEM_CAT_UPDT_FLAG   IN VARCHAR2
,  X_VALIDATE_FLAG_UPDT_FLAG   IN VARCHAR2
,  X_HIERARCHY_ENABLED    IN  VARCHAR2
,  X_CONTROL_LEVEL        IN  NUMBER
,  X_DEFAULT_CATEGORY_ID  IN  NUMBER
,  x_owner                IN  VARCHAR2
,  x_custom_mode          IN  VARCHAR2
,  x_msg_name             OUT NOCOPY VARCHAR2
,  x_lud                  IN DATE DEFAULT SYSDATE
)
IS

  l_Rowid        VARCHAR2(30);
  l_Login        NUMBER  := 0;
  f_luby         NUMBER;  -- entity owner in file
  f_ludate       DATE;    -- entity update date in file
  db_luby        NUMBER;  -- entity owner in db
  db_ludate      DATE;    -- entity update date in db
  db_control_updt_flag  MTL_CATEGORY_SETS_B.CONTROL_LEVEL_UPDATEABLE_FLAG%TYPE;
  db_mult_item_cat_flag MTL_CATEGORY_SETS_B.MULT_ITEM_CAT_UPDATEABLE_FLAG%TYPE;
  db_validate_updteable_flag MTL_CATEGORY_SETS_B.VALIDATE_FLAG_UPDATEABLE_FLAG%TYPE;
  db_validate_flag           MTL_CATEGORY_SETS_B.VALIDATE_FLAG%TYPE;
  db_hierarchy_enabled       MTL_CATEGORY_SETS_B.HIERARCHY_ENABLED%TYPE;
  db_mult_item_Cat_assign_flag MTL_CATEGORY_SETS_B.MULT_ITEM_CAT_ASSIGN_FLAG%TYPE;
  db_control_level         MTL_CATEGORY_SETS_B.CONTROL_LEVEL%TYPE;
  l_mult_item_cat_assign   MTL_CATEGORY_SETS_B.MULT_ITEM_CAT_ASSIGN_FLAG%TYPE;
  l_validate_flag          MTL_CATEGORY_SETS_B.VALIDATE_FLAG%TYPE;
  l_control_level          MTL_CATEGORY_SETS_B.CONTROL_LEVEL%TYPE;
  l_control_flag_changed   BOOLEAN;
  l_mult_item_flag_changed BOOLEAN;
  l_validate_flag_changed  BOOLEAN;
  l_select                 VARCHAR2(10);

BEGIN

  -- Translate owner to file_last_updated_by
  f_luby   := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(to_char(x_lud,'YYYY/MM/DD'), 'YYYY/MM/DD'), sysdate);

  BEGIN

     SELECT LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            CONTROL_LEVEL_UPDATEABLE_FLAG,
            MULT_ITEM_CAT_UPDATEABLE_FLAG,
            VALIDATE_FLAG_UPDATEABLE_FLAG,
            VALIDATE_FLAG,
            HIERARCHY_ENABLED,
	    MULT_ITEM_CAT_ASSIGN_FLAG,
	    CONTROL_LEVEL
     INTO   db_luby,
            db_ludate,
            db_control_updt_flag,
            db_mult_item_cat_flag,
            db_validate_updteable_flag,
            db_validate_flag,
            db_hierarchy_enabled,
	    db_mult_item_Cat_assign_flag,
	    db_control_level
     FROM   MTL_CATEGORY_SETS_B
     WHERE  CATEGORY_SET_ID = x_category_set_id ;

     l_mult_item_flag_changed :=  false;
     l_control_flag_changed   :=  false;

     IF (db_control_updt_flag IS NULL   AND X_CONTROL_LEVEL_UPDT_FLAG = 'N')
        OR (db_control_updt_flag = 'N'  AND X_CONTROL_LEVEL_UPDT_FLAG IS NULL)
        OR (db_control_updt_flag <> 'N' AND X_CONTROL_LEVEL_UPDT_FLAG='N')
        OR (db_control_updt_flag =  'N' AND X_CONTROL_LEVEL_UPDT_FLAG <>'N')THEN
           l_control_flag_changed := true;
    END IF;


    IF (db_mult_item_cat_flag IS NULL    AND X_MULT_ITEM_CAT_UPDT_FLAG = 'N')
        OR (db_mult_item_cat_flag =  'N' AND X_MULT_ITEM_CAT_UPDT_FLAG IS NULL)
        OR (db_mult_item_cat_flag <> 'N' AND  X_MULT_ITEM_CAT_UPDT_FLAG ='N')
        OR (db_mult_item_cat_flag =  'N' AND  X_MULT_ITEM_CAT_UPDT_FLAG <>'N') THEN
           l_mult_item_flag_changed := true;
    END IF;

    IF (db_validate_updteable_flag IS NULL    AND X_VALIDATE_FLAG_UPDT_FLAG = 'N')
        OR (db_validate_updteable_flag =  'N' AND X_VALIDATE_FLAG_UPDT_FLAG IS NULL)
        OR (db_validate_updteable_flag <> 'N' AND  X_VALIDATE_FLAG_UPDT_FLAG ='N')
        OR (db_validate_updteable_flag =  'N' AND  X_VALIDATE_FLAG_UPDT_FLAG <>'N') THEN
           l_validate_flag_changed := true;
    END IF;
    IF (fnd_load_util.upload_test(f_luby,
                                  f_ludate,
                                  db_luby,
                                  db_ludate,
                                  x_custom_mode)) THEN
    --Bug:3835368
      IF (NVL(X_VALIDATE_FLAG,NVL(db_validate_flag,'N')) ='N'
            AND NVL(X_HIERARCHY_ENABLED,NVL(db_hierarchy_enabled,'N')) ='Y') THEN
        x_msg_name := 'INV_CHG_HIER_ENABLE_ERR';
        RETURN;
      ELSIF(NVL(X_HIERARCHY_ENABLED,'N') ='Y' AND NVL(db_hierarchy_enabled,'N')='N' ) THEN
         BEGIN
           SELECT NULL INTO l_select
             FROM MTL_DEFAULT_CATEGORY_SETS
            WHERE FUNCTIONAL_AREA_ID NOT IN (7,11)
              AND CATEGORY_SET_ID = x_category_set_id
              AND ROWNUM = 1;
           x_msg_name := 'INV_DEF_HIER_ENABLE_ERR';
           RETURN;
         EXCEPTION
           WHEN OTHERS THEN
             NULL;
         END;
      END IF;

        MTL_CATEGORY_SETS_Pkg.Update_Row
        (
         x_category_set_id      =>  x_category_set_id
      ,  x_category_set_name    =>  x_category_set_name
      ,  x_description          =>  x_description
      ,  X_STRUCTURE_ID         =>  X_STRUCTURE_ID
      ,  X_VALIDATE_FLAG        =>  X_VALIDATE_FLAG
      ,  X_MULT_ITEM_CAT_ASSIGN_FLAG => X_MULT_ITEM_CAT_ASSIGN_FLAG
      ,  X_CONTROL_LEVEL_UPDT_FLAG   => X_CONTROL_LEVEL_UPDT_FLAG
      ,  X_MULT_ITEM_CAT_UPDT_FLAG   => X_MULT_ITEM_CAT_UPDT_FLAG
      ,  X_VALIDATE_FLAG_UPDT_FLAG   => X_VALIDATE_FLAG_UPDT_FLAG
      ,  X_HIERARCHY_ENABLED    => X_HIERARCHY_ENABLED
      ,  X_CONTROL_LEVEL        =>  X_CONTROL_LEVEL
      ,  X_DEFAULT_CATEGORY_ID  =>  X_DEFAULT_CATEGORY_ID
      ,  X_LAST_UPDATE_DATE     =>  db_ludate
      ,  X_LAST_UPDATED_BY      =>  db_luby
      ,  X_LAST_UPDATE_LOGIN    =>  l_Login
         );
     ELSIF (l_control_flag_changed OR l_mult_item_flag_changed OR l_validate_flag_changed) THEN

       --Bug:3835368
       IF (NVL(X_VALIDATE_FLAG,NVL(db_validate_flag,'N')) ='N'
            AND NVL(X_HIERARCHY_ENABLED,NVL(db_hierarchy_enabled,'N')) ='Y') THEN
        x_msg_name := 'INV_CHG_HIER_ENABLE_ERR';
        RETURN;
       ELSIF(NVL(X_HIERARCHY_ENABLED,'N') ='Y' AND NVL(db_hierarchy_enabled,'N')='N' ) THEN
         BEGIN
           SELECT NULL INTO l_select
             FROM MTL_DEFAULT_CATEGORY_SETS
            WHERE FUNCTIONAL_AREA_ID NOT IN (7,11)
              AND CATEGORY_SET_ID = x_category_set_id
              AND ROWNUM = 1;
           x_msg_name := 'INV_DEF_HIER_ENABLE_ERR';
           RETURN;
         EXCEPTION
           WHEN OTHERS THEN
             NULL;
         END;
       END IF;
 --Bug:4225603 Assigning new values if corresponding values are true.
       IF l_mult_item_flag_changed THEN
         l_mult_item_cat_assign := X_MULT_ITEM_CAT_ASSIGN_FLAG;
       ELSE
         l_mult_item_cat_assign := db_mult_item_Cat_assign_flag;
       END IF;
       IF l_validate_flag_changed THEN
         l_validate_flag := X_VALIDATE_FLAG;
       ELSE
         l_validate_flag := db_validate_flag;
       END IF;
       IF l_control_flag_changed THEN
         l_control_level := X_CONTROL_LEVEL;
       ELSE
         l_control_level := db_control_level;
       END IF;
 --Bug:4225603 Ended

        MTL_CATEGORY_SETS_Pkg.Update_Row
        (
         x_category_set_id           => X_CATEGORY_SET_ID
      ,  X_CONTROL_LEVEL_UPDT_FLAG   => X_CONTROL_LEVEL_UPDT_FLAG
      ,  X_MULT_ITEM_CAT_UPDT_FLAG   => X_MULT_ITEM_CAT_UPDT_FLAG
      ,  X_VALIDATE_FLAG_UPDT_FLAG   => X_VALIDATE_FLAG_UPDT_FLAG
      ,  X_HIERARCHY_ENABLED         => X_HIERARCHY_ENABLED
      ,  X_VALIDATE_FLAG             => l_validate_flag
      ,  X_MULT_ITEM_CAT_ASSIGN_FLAG => l_mult_item_cat_assign
      ,  X_CONTROL_LEVEL             => l_control_level
      ,  X_LAST_UPDATE_DATE          => db_ludate
      ,  X_LAST_UPDATED_BY           => db_luby
      ,  X_LAST_UPDATE_LOGIN         => l_Login
         );
     END IF;

  EXCEPTION
     WHEN no_data_found  THEN
        MTL_CATEGORY_SETS_Pkg.Insert_Row
          (
             X_ROWID                =>  l_Rowid
          ,  x_category_set_id      =>  x_category_set_id
          ,  x_category_set_name    =>  x_category_set_name
          ,  x_description          =>  x_description
          ,  X_STRUCTURE_ID         =>  X_STRUCTURE_ID
          ,  X_VALIDATE_FLAG        =>  X_VALIDATE_FLAG
          ,  X_MULT_ITEM_CAT_ASSIGN_FLAG => X_MULT_ITEM_CAT_ASSIGN_FLAG
          ,  X_CONTROL_LEVEL_UPDT_FLAG   => X_CONTROL_LEVEL_UPDT_FLAG
          ,  X_MULT_ITEM_CAT_UPDT_FLAG   => X_MULT_ITEM_CAT_UPDT_FLAG
          ,  X_VALIDATE_FLAG_UPDT_FLAG   => X_VALIDATE_FLAG_UPDT_FLAG
          ,  X_HIERARCHY_ENABLED    => X_HIERARCHY_ENABLED
          ,  X_CONTROL_LEVEL        =>  X_CONTROL_LEVEL
          ,  X_DEFAULT_CATEGORY_ID  =>  X_DEFAULT_CATEGORY_ID
          ,  X_CREATION_DATE        =>  f_ludate
          ,  X_CREATED_BY           =>  f_luby
          ,  X_LAST_UPDATE_DATE     =>  f_ludate
          ,  X_LAST_UPDATED_BY      =>  f_luby
          ,  X_LAST_UPDATE_LOGIN    =>  l_Login
          );
  END;

END Load_Row;
-- ----------------------------------------------------------------------
-- PROCEDURE:  Load_Row
--
--
-- COMMENT:
--  Overloaded procedure
-- ----------------------------------------------------------------------
PROCEDURE Load_Row
(
   X_CATEGORY_SET_ID           IN  NUMBER
,  X_CATEGORY_SET_NAME         IN  VARCHAR2
,  X_DESCRIPTION               IN  VARCHAR2
,  X_STRUCTURE_CODE            IN  VARCHAR2
,  X_VALIDATE_FLAG             IN  VARCHAR2
,  X_MULT_ITEM_CAT_ASSIGN_FLAG IN  VARCHAR2
,  X_CONTROL_LEVEL             IN  NUMBER
,  X_DEFAULT_CATEGORY_CD       IN  VARCHAR2
,  X_OWNER                     IN  VARCHAR2
,  X_LAST_UPDATE_DATE          IN  VARCHAR2
,  X_CONTROL_LEVEL_UPDT_FLAG   IN  VARCHAR2
,  X_MULT_ITEM_CAT_UPDT_FLAG   IN  VARCHAR2
,  X_VALIDATE_FLAG_UPDT_FLAG   IN  VARCHAR2
,  X_HIERARCHY_ENABLED         IN  VARCHAR2
) IS

    l_structure_Id        NUMBER;
    l_msg_name            VARCHAR2(2000);
    l_Rowid               VARCHAR2(300);
    l_cat_set_id          NUMBER;
    l_default_category_id NUMBER;
    BEGIN

      SELECT category_set_id, structure_id
        INTO l_cat_set_id, l_structure_id
        FROM MTL_CATEGORY_SETS_VL
       WHERE CATEGORY_SET_NAME = X_CATEGORY_SET_NAME ;

      -- Get default category id from the category code
      BEGIN
       SELECT category_id INTO l_default_category_id
        FROM  mtl_categories_b_kfv
       WHERE  concatenated_segments = X_DEFAULT_CATEGORY_CD
        AND  structure_id = l_structure_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_default_category_id := null;
      END;

      -- select sysdate into l_date from dual;

      MTL_CATEGORY_SETS_PKG.Update_Row(
          X_CATEGORY_SET_ID           => l_cat_set_id,
          X_CATEGORY_SET_NAME         => X_CATEGORY_SET_NAME,
          X_DESCRIPTION               => X_DESCRIPTION,
          X_STRUCTURE_ID              => l_structure_id,
          X_VALIDATE_FLAG             => X_VALIDATE_FLAG,
          X_MULT_ITEM_CAT_ASSIGN_FLAG => X_MULT_ITEM_CAT_ASSIGN_FLAG,
          X_CONTROL_LEVEL_UPDT_FLAG   => X_CONTROL_LEVEL_UPDT_FLAG,
          X_MULT_ITEM_CAT_UPDT_FLAG   => X_MULT_ITEM_CAT_UPDT_FLAG,
          X_VALIDATE_FLAG_UPDT_FLAG   => X_VALIDATE_FLAG_UPDT_FLAG,
          X_HIERARCHY_ENABLED         => X_HIERARCHY_ENABLED,
          X_CONTROL_LEVEL             => X_CONTROL_LEVEL,
          X_DEFAULT_CATEGORY_ID       => l_default_category_id,
          X_LAST_UPDATE_DATE          => SYSDATE,
          X_LAST_UPDATED_BY           => fnd_load_util.owner_id(X_OWNER),
          X_LAST_UPDATE_LOGIN         => 0
       );


    EXCEPTION WHEN no_data_found THEN

       BEGIN
          -- If category set id is null, then create category set
          -- with the structure of the source category set.
          SELECT  id_flex_num
           INTO  l_Structure_Id
           FROM  fnd_id_flex_structures_vl
          WHERE  application_id = 401
            AND  id_flex_code = 'MCAT'
            AND  id_flex_structure_code = X_STRUCTURE_CODE;

         select  MTL_CATEGORY_SETS_S.nextval into l_cat_set_id from dual;

         -- Get default category id from the category code
         BEGIN
          SELECT category_id INTO l_default_category_id
           FROM  mtl_categories_b_kfv
          WHERE  concatenated_segments = X_DEFAULT_CATEGORY_CD
           AND  structure_id = l_structure_id;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_default_category_id := null;
         END;

         --Insert the new category set name, but category set id
         --is sequence generated
         MTL_CATEGORY_SETS_Pkg.Insert_Row
          (
             X_ROWID                =>  l_Rowid
          ,  x_category_set_id      =>  l_cat_set_id
          ,  x_category_set_name    =>  X_CATEGORY_SET_NAME
          ,  x_description          =>  X_DESCRIPTION
          ,  X_STRUCTURE_ID         =>  l_structure_Id
          ,  X_VALIDATE_FLAG        =>  X_VALIDATE_FLAG
          ,  X_MULT_ITEM_CAT_ASSIGN_FLAG => X_MULT_ITEM_CAT_ASSIGN_FLAG
          ,  X_CONTROL_LEVEL_UPDT_FLAG   => X_CONTROL_LEVEL_UPDT_FLAG
          ,  X_MULT_ITEM_CAT_UPDT_FLAG   => X_MULT_ITEM_CAT_UPDT_FLAG
          ,  X_VALIDATE_FLAG_UPDT_FLAG   => X_VALIDATE_FLAG_UPDT_FLAG
          ,  X_HIERARCHY_ENABLED         => X_HIERARCHY_ENABLED
          ,  X_CONTROL_LEVEL        =>  X_CONTROL_LEVEL
          ,  X_DEFAULT_CATEGORY_ID  =>  l_default_category_id
          ,  X_CREATION_DATE        =>  SYSDATE
          ,  X_CREATED_BY           =>  fnd_load_util.owner_id(X_OWNER)
          ,  X_LAST_UPDATE_DATE     =>  SYSDATE
          ,  X_LAST_UPDATED_BY      =>  fnd_load_util.owner_id(X_OWNER)
          ,  X_LAST_UPDATE_LOGIN    =>  0
          );
       end;
   end;

end MTL_CATEGORY_SETS_PKG;

/
