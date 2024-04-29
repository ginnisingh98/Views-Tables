--------------------------------------------------------
--  DDL for Package Body JTF_SEEDED_QUAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_SEEDED_QUAL_PKG" AS
/* $Header: jtfvsqlb.pls 120.2 2005/10/25 16:43:34 achanda ship $ */

-- eihsu    10/06/1999 adding procedures for MLS support
-- vnedunga 05/11/00   fixing the translate row as part of
--                     MLS verification
-- vnedunga 05/16/00   Fixing UPdate_Row/Delete row use JTF_SEEDED_QUAL_ALL_B
--                     instead of JTF_SEEDED_QUAL
-- jdochert 08/17/00   1331579 bug fix =>
--	                   Replaced: AND org_id = x_org_id
--                     With:     and NVL(ORG_ID, -99) = NVL(x_ORG_ID, -99)
--

PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_SEEDED_QUAL_ID                 IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_NAME                           IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM JTF_SEEDED_QUAL_ALL_B
            WHERE SEEDED_QUAL_ID = x_SEEDED_QUAL_ID and NVL(ORG_ID, -99) = NVL(x_ORG_ID, -99);
   CURSOR C2 IS SELECT JTF_SEEDED_QUAL_s.nextval FROM sys.dual;
BEGIN
   If (x_SEEDED_QUAL_ID IS NULL) then
       OPEN C2;
       FETCH C2 INTO x_SEEDED_QUAL_ID;
       CLOSE C2;
   End If;
   INSERT INTO JTF_SEEDED_QUAL_ALL_B(
           SEEDED_QUAL_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           NAME,
           DESCRIPTION,
           ORG_ID
          ) VALUES (
          x_SEEDED_QUAL_ID,
           decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_LAST_UPDATE_DATE),
           decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATED_BY),
           decode( x_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL),x_CREATION_DATE),
           decode( x_CREATED_BY, FND_API.G_MISS_NUM, NULL,x_CREATED_BY),
           decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,x_LAST_UPDATE_LOGIN),
           decode( x_NAME, FND_API.G_MISS_CHAR, NULL,x_NAME),
           decode( x_DESCRIPTION, FND_API.G_MISS_CHAR, NULL,x_DESCRIPTION),
           decode( x_ORG_ID, FND_API.G_MISS_NUM, NULL, x_ORG_ID) );

   insert into JTF_SEEDED_QUAL_ALL_TL (
           SEEDED_QUAL_ID,
           NAME,
           DESCRIPTION,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN,
           CREATION_DATE,
           CREATED_BY,
           LANGUAGE,
           SOURCE_LANG,
           ORG_ID
         ) select
           X_SEEDED_QUAL_ID,
           X_NAME,
           X_DESCRIPTION,
           X_LAST_UPDATE_DATE,
           X_LAST_UPDATED_BY,
           X_LAST_UPDATE_LOGIN,
           X_CREATION_DATE,
           X_CREATED_BY,
           L.LANGUAGE_CODE,
           userenv('LANG'),
           X_ORG_ID
         from FND_LANGUAGES L
         where L.INSTALLED_FLAG in ('I', 'B')
         and not exists
           (select NULL
              from JTF_SEEDED_QUAL_ALL_TL T
             where T.SEEDED_QUAL_ID = X_SEEDED_QUAL_ID and
                   T.LANGUAGE = L.language_code and
                   NVL(T.ORG_ID, -99) = NVL(X_ORG_ID, -99) /* 1331579 BUG FIX */ );

   OPEN C;
   FETCH C INTO x_Rowid;
   If (C%NOTFOUND) then
       CLOSE C;
       RAISE NO_DATA_FOUND;
   End If;
End Insert_Row;



PROCEDURE Delete_Row(                  x_SEEDED_QUAL_ID                 IN     NUMBER
 ) IS
 BEGIN
   DELETE from JTF_SEEDED_QUAL_ALL_TL
    where SEEDED_QUAL_ID = X_SEEDED_QUAL_ID;

   if (sql%notfound) then
      raise no_data_found;
   end if;

   DELETE FROM JTF_SEEDED_QUAL_ALL_B
    WHERE SEEDED_QUAL_ID = x_SEEDED_QUAL_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_SEEDED_QUAL_ID                 IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_NAME                           IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER
 ) IS
 BEGIN
    Update JTF_SEEDED_QUAL_ALL_B
    SET    SEEDED_QUAL_ID = decode( x_SEEDED_QUAL_ID, FND_API.G_MISS_NUM,SEEDED_QUAL_ID,x_SEEDED_QUAL_ID),
           LAST_UPDATE_DATE = decode( x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE,LAST_UPDATE_DATE,x_LAST_UPDATE_DATE),
           LAST_UPDATED_BY = decode( x_LAST_UPDATED_BY, FND_API.G_MISS_NUM,LAST_UPDATED_BY,x_LAST_UPDATED_BY),
           CREATION_DATE = decode( x_CREATION_DATE, FND_API.G_MISS_DATE,CREATION_DATE,x_CREATION_DATE),
           CREATED_BY = decode( x_CREATED_BY, FND_API.G_MISS_NUM,CREATED_BY,x_CREATED_BY),
           LAST_UPDATE_LOGIN = decode( x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM,LAST_UPDATE_LOGIN,x_LAST_UPDATE_LOGIN),
           NAME = decode( x_NAME, FND_API.G_MISS_CHAR,NAME,x_NAME),
           DESCRIPTION = decode( x_DESCRIPTION, FND_API.G_MISS_CHAR,DESCRIPTION,x_DESCRIPTION),
           ORG_ID = decode( x_ORG_ID, FND_API.G_MISS_NUM, ORG_ID, X_ORG_ID)
    where SEEDED_QUAL_ID = X_SEEDED_QUAL_ID and
          NVL(ORG_ID, -99) = NVL(X_ORG_ID, -99) /* 1331579 BUG FIX */ ;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

    update JTF_SEEDED_QUAL_ALL_TL set
           NAME = X_NAME,
           LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
           LAST_UPDATED_BY = X_LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
           SOURCE_LANG = userenv('LANG')
     where SEEDED_QUAL_ID = X_SEEDED_QUAL_ID
       and userenv('LANG') in (LANGUAGE, SOURCE_LANG) AND
           NVL(ORG_ID, -99) = NVL(X_ORG_ID, -99) /* 1331579 BUG FIX */ ;

  if (sql%notfound) then
    raise no_data_found;
  end if;

 END Update_Row;


PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_SEEDED_QUAL_ID                 IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_NAME                           IN     VARCHAR2,
                  x_DESCRIPTION                    IN     VARCHAR2,
                  x_ORG_ID                         IN     NUMBER
 ) IS
   CURSOR C IS
        SELECT *
          FROM JTF_SEEDED_QUAL
         WHERE rowid = x_Rowid
         FOR UPDATE of SEEDED_QUAL_ID NOWAIT;
   Recinfo C%ROWTYPE;

   CURSOR c1 is select
          NAME,
          decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
          from JTF_SEEDED_QUAL_ALL_TL
         where SEEDED_QUAL_ID = X_SEEDED_QUAL_ID
           and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
           for update of SEEDED_QUAL_ID nowait;
 BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    End If;
    CLOSE C;
    if (
           (    ( Recinfo.SEEDED_QUAL_ID = x_SEEDED_QUAL_ID)
            OR (    ( Recinfo.SEEDED_QUAL_ID is NULL )
                AND (  x_SEEDED_QUAL_ID is NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = x_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE is NULL )
                AND (  x_LAST_UPDATE_DATE is NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = x_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY is NULL )
                AND (  x_LAST_UPDATED_BY is NULL )))
       AND (    ( Recinfo.CREATION_DATE = x_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE is NULL )
                AND (  x_CREATION_DATE is NULL )))
       AND (    ( Recinfo.CREATED_BY = x_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY is NULL )
                AND (  x_CREATED_BY is NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = x_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN is NULL )
                AND (  x_LAST_UPDATE_LOGIN is NULL )))
       AND (    ( Recinfo.NAME = x_NAME)
            OR (    ( Recinfo.NAME is NULL )
                AND (  x_NAME is NULL )))
       AND (    ( Recinfo.DESCRIPTION = x_DESCRIPTION)
            OR (    ( Recinfo.DESCRIPTION is NULL )
                AND (  x_DESCRIPTION is NULL )))
       AND (    ( Recinfo.ORG_ID = x_ORG_ID)
            OR (    ( Recinfo.ORG_ID is NULL )
                AND (  x_ORG_ID is NULL )))
       ) then
       null;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;

   -- Lock the transalation Table
   for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.NAME = X_NAME)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;

END Lock_Row;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_SEEDED_QUAL_ALL_TL T
  where not exists
    (select NULL
    from JTF_SEEDED_QUAL_ALL_B B
    where B.SEEDED_QUAL_ID = T.SEEDED_QUAL_ID
    and   NVL(B.ORG_ID,-99) = NVL(T.ORG_ID,-99) /* 1331579 BUG FIX */
    );

  update JTF_SEEDED_QUAL_ALL_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from JTF_SEEDED_QUAL_ALL_TL B
    where B.SEEDED_QUAL_ID = T.SEEDED_QUAL_ID
    and B.LANGUAGE = T.SOURCE_LANG
    and NVL(B.ORG_ID, -99) = NVL(T.ORG_ID,-99))
  where (
      T.SEEDED_QUAL_ID,
      T.LANGUAGE
  ) in ( select
         SUBT.SEEDED_QUAL_ID,
         SUBT.LANGUAGE
         from JTF_SEEDED_QUAL_ALL_TL SUBB, JTF_SEEDED_QUAL_ALL_TL SUBT
         where SUBB.SEEDED_QUAL_ID = SUBT.SEEDED_QUAL_ID
         and SUBB.LANGUAGE = SUBT.SOURCE_LANG
         AND NVL(SUBB.ORG_ID, -99) = NVL(SUBT.ORG_ID, -99) /* 1331579 BUG FIX */
         and (SUBB.NAME <> SUBT.NAME)
       );

  insert into JTF_SEEDED_QUAL_ALL_TL (
    SEEDED_QUAL_ID,
    NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG,
    ORG_ID
  ) select
    B.SEEDED_QUAL_ID,
    B.NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.CREATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    B.ORG_ID
  from JTF_SEEDED_QUAL_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    ( select NULL
      from JTF_SEEDED_QUAL_ALL_TL T
      where T.SEEDED_QUAL_ID = B.SEEDED_QUAL_ID
      and T.LANGUAGE = L.LANGUAGE_CODE
      AND NVL(T.ORG_ID, -99) = NVL(B.ORG_ID, -99) /* 1331579 BUG FIX */
    );

end ADD_LANGUAGE;

-- --------------------------------------------------------------------
-- Procedure : LOAD_ROW
-- Description : Called by FNDLOAD to upload seed datas, this procedure
--    only handle seed datas.
-- --------------------------------------------------------------------
PROCEDURE LOAD_ROW
  ( x_SEEDED_QUAL_ID IN NUMBER,
    x_description IN VARCHAR2,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2) IS
       user_id NUMBER;

BEGIN
   -- Validate input data
   IF (x_SEEDED_QUAL_ID IS NULL) OR
      (x_name IS NULL) THEN
      GOTO end_load_row;
   END IF;

   IF (x_owner IS NOT NULL) AND (x_owner = 'ORACLE12.0.0') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;
   -- Load The record to _B table
   UPDATE  JTF_SEEDED_QUAL_ALL_B SET
     name = x_name,
     description = x_description,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0
     WHERE SEEDED_QUAL_ID = x_SEEDED_QUAL_ID;

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _B table
      INSERT INTO JTF_SEEDED_QUAL_ALL_B
	(SEEDED_QUAL_ID,
	 name,
	 description,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login
	 ) VALUES
	(x_SEEDED_QUAL_ID,
	 x_Name,
	 x_description,
	 sysdate,
	 user_id,
	 sysdate,
	 user_id,
	 0
	 );
   END IF;
   -- Load The record to _TL table
   UPDATE JTF_SEEDED_QUAL_ALL_TL SET
     name = x_name,
     description = x_description,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     source_lang = userenv('LANG')
     WHERE SEEDED_QUAL_ID = x_SEEDED_QUAL_ID
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _TL table
      INSERT INTO JTF_SEEDED_QUAL_ALL_TL
	(SEEDED_QUAL_ID,
	 name,
	 description,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 language,
	 source_lang)
	SELECT
	x_SEEDED_QUAL_ID,
	x_name,
	x_description,
	sysdate,
	user_id,
	sysdate,
	user_id,
	0,
	l.language_code,
	userenv('LANG')
	FROM fnd_languages l
	WHERE l.installed_flag IN ('I', 'B')
	AND NOT EXISTS
	( SELECT NULL
	  FROM JTF_SEEDED_QUAL_ALL_TL t
	  WHERE t.SEEDED_QUAL_ID = x_SEEDED_QUAL_ID
	  AND t.language = l.language_code
        );

   END IF;
   << end_load_row >>
     NULL;
END LOAD_ROW ;

-- --------------------------------------------------------------------
-- Procedure : TRANSLATE_ROW
-- Description : Called by FNDLOAD to translate seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------
PROCEDURE TRANSLATE_ROW
  ( x_SEEDED_QUAL_ID IN NUMBER,
    x_name IN VARCHAR2,
    x_Description IN VARCHAR2,
    x_owner IN VARCHAR2) IS
    user_id NUMBER;
BEGIN
    -- Validate input data
   IF (x_SEEDED_QUAL_ID IS NULL) OR (x_name IS NULL) THEN
      GOTO end_translate_row;
   END IF;

   IF (x_owner IS NOT NULL) AND (x_owner = 'SEED') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;
   -- Update the translation
   UPDATE JTF_SEEDED_QUAL_ALL_TL SET
     name = x_name,
     description = x_Description,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     source_lang = userenv('LANG')
     WHERE SEEDED_QUAL_ID = x_SEEDED_QUAL_ID
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   << end_translate_row >>
     NULL;
END TRANSLATE_ROW ;


END JTF_SEEDED_QUAL_PKG;


/
