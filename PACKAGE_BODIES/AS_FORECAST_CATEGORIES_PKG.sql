--------------------------------------------------------
--  DDL for Package Body AS_FORECAST_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_FORECAST_CATEGORIES_PKG" as
/* $Header: asxtfcab.pls 115.12 2004/03/16 05:01:58 sumahali ship $ */
-- Start of Comments
-- Package name     : AS_FORECAST_CATEGORIES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AS_FORECAST_CATEGORIES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxtfcab.pls';

PROCEDURE Insert_Row(
          px_FORECAST_CATEGORY_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_FORECAST_CATEGORY_NAME    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE)

 IS
   CURSOR C2 IS SELECT AS_FORECAST_CATEGORIES_S.nextval FROM sys.dual;
BEGIN
   If (px_FORECAST_CATEGORY_ID IS NULL) OR (px_FORECAST_CATEGORY_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_FORECAST_CATEGORY_ID;
       CLOSE C2;
   End If;

   INSERT INTO AS_FORECAST_CATEGORIES_B(
           FORECAST_CATEGORY_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           START_DATE_ACTIVE,
           END_DATE_ACTIVE
          ) VALUES (
           px_FORECAST_CATEGORY_ID,
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_START_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_START_DATE_ACTIVE),
           decode( p_END_DATE_ACTIVE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_END_DATE_ACTIVE));

    INSERT INTO AS_FORECAST_CATEGORIES_TL(
           FORECAST_CATEGORY_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           FORECAST_CATEGORY_NAME,
     		LANGUAGE,
    		SOURCE_LANG
  	  ) select
           px_FORECAST_CATEGORY_ID,
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_FORECAST_CATEGORY_NAME, FND_API.G_MISS_CHAR, NULL, p_FORECAST_CATEGORY_NAME),
    		L.LANGUAGE_CODE,
    		userenv('LANG')
  	from FND_LANGUAGES L
  	where L.INSTALLED_FLAG in ('I', 'B')
  	and not exists
    	(select NULL
    		from AS_FORECAST_CATEGORIES_TL T
    		where T.FORECAST_CATEGORY_ID = px_FORECAST_CATEGORY_ID
    		and T.LANGUAGE = L.LANGUAGE_CODE);


End Insert_Row;

PROCEDURE Update_Row(
          p_FORECAST_CATEGORY_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_FORECAST_CATEGORY_NAME    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE)

 IS
 BEGIN
    Update AS_FORECAST_CATEGORIES_B
    SET
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              START_DATE_ACTIVE = decode( p_START_DATE_ACTIVE, FND_API.G_MISS_DATE, START_DATE_ACTIVE, p_START_DATE_ACTIVE),
              END_DATE_ACTIVE = decode( p_END_DATE_ACTIVE, FND_API.G_MISS_DATE, END_DATE_ACTIVE, p_END_DATE_ACTIVE)
    where FORECAST_CATEGORY_ID = p_FORECAST_CATEGORY_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

    Update AS_FORECAST_CATEGORIES_TL
    SET
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              FORECAST_CATEGORY_NAME = decode( p_FORECAST_CATEGORY_NAME, FND_API.G_MISS_CHAR, FORECAST_CATEGORY_NAME, p_FORECAST_CATEGORY_NAME),
              SOURCE_LANG = userenv('LANG')
    where FORECAST_CATEGORY_ID = p_FORECAST_CATEGORY_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

END Update_Row;

PROCEDURE Delete_Row(
    p_FORECAST_CATEGORY_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AS_FORECAST_CATEGORIES_B
    WHERE FORECAST_CATEGORY_ID = p_FORECAST_CATEGORY_ID;

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;

   DELETE FROM AS_FORECAST_CATEGORIES_TL
    WHERE FORECAST_CATEGORY_ID = p_FORECAST_CATEGORY_ID;

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;

 END Delete_Row;

PROCEDURE Lock_Row(
          p_FORECAST_CATEGORY_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_FORECAST_CATEGORY_NAME    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE)

 IS
   CURSOR C IS
        SELECT *
         FROM AS_FORECAST_CATEGORIES_B
        WHERE FORECAST_CATEGORY_ID =  p_FORECAST_CATEGORY_ID
        FOR UPDATE of FORECAST_CATEGORY_ID NOWAIT;

   Recinfo C%ROWTYPE;

   CURSOR C1 IS
        SELECT   FORECAST_CATEGORY_NAME,
          decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG

         FROM AS_FORECAST_CATEGORIES_TL
        WHERE FORECAST_CATEGORY_ID =  p_FORECAST_CATEGORY_ID
       and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
       FOR UPDATE of FORECAST_CATEGORY_ID NOWAIT;

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
           (      Recinfo.FORECAST_CATEGORY_ID = p_FORECAST_CATEGORY_ID)
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.START_DATE_ACTIVE = p_START_DATE_ACTIVE)
            OR (    ( Recinfo.START_DATE_ACTIVE IS NULL )
                AND (  p_START_DATE_ACTIVE IS NULL )))
       AND (    ( Recinfo.END_DATE_ACTIVE = p_END_DATE_ACTIVE)
            OR (    ( Recinfo.END_DATE_ACTIVE IS NULL )
                AND (  p_END_DATE_ACTIVE IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
  /*
   for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if ( ((tlinfo.FORECAST_CATEGORY_NAME = p_FORECAST_CATEGORY_NAME)
               OR ((tlinfo.FORECAST_CATEGORY_NAME is null) AND (p_FORECAST_CATEGORY_NAME is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  --return;
 */

END Lock_Row;

procedure ADD_LANGUAGE
is
begin
  delete from AS_FORECAST_CATEGORIES_TL T
  where not exists
    (select NULL
    from AS_FORECAST_CATEGORIES_B B
    where B.FORECAST_CATEGORY_ID = T.FORECAST_CATEGORY_ID
    );

  update AS_FORECAST_CATEGORIES_TL T set (
      FORECAST_CATEGORY_NAME
    ) = (select
      FORECAST_CATEGORY_NAME
    from AS_FORECAST_CATEGORIES_TL B
    where B.FORECAST_CATEGORY_ID = T.FORECAST_CATEGORY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FORECAST_CATEGORY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.FORECAST_CATEGORY_ID,
      SUBT.LANGUAGE
    from AS_FORECAST_CATEGORIES_TL SUBB, AS_FORECAST_CATEGORIES_TL SUBT
    where SUBB.FORECAST_CATEGORY_ID = SUBT.FORECAST_CATEGORY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and ( SUBB.FORECAST_CATEGORY_NAME <> SUBT.FORECAST_CATEGORY_NAME
      or (SUBB.FORECAST_CATEGORY_NAME is null and SUBT.FORECAST_CATEGORY_NAME is not null)
      or (SUBB.FORECAST_CATEGORY_NAME is not null and SUBT.FORECAST_CATEGORY_NAME is null)
  ));

  insert into AS_FORECAST_CATEGORIES_TL (
    FORECAST_CATEGORY_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    FORECAST_CATEGORY_NAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.FORECAST_CATEGORY_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.FORECAST_CATEGORY_NAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AS_FORECAST_CATEGORIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AS_FORECAST_CATEGORIES_TL T
    where T.FORECAST_CATEGORY_ID = B.FORECAST_CATEGORY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


PROCEDURE Load_Row(
          X_FORECAST_CATEGORY_ID    in NUMBER,
          X_FORECAST_CATEGORY_NAME  in VARCHAR2,
	  X_OWNER                   in VARCHAR2,
          x_START_DATE_ACTIVE    in DATE,
          x_END_DATE_ACTIVE    in DATE)
IS
l_forecast_category_id as_forecast_categories_b.forecast_category_id%Type;
li_forecast_category_id NUMBER := 0;

BEGIN
  declare

	user_id number := 0;

	cursor custom_exist(p_forecast_category_id NUMBER) is
	 select 'Y'
	 from AS_FORECAST_CATEGORIES_B
	 where last_updated_by <> 1
	 and FORECAST_CATEGORY_ID = p_forecast_category_id;

	 l_custom_exist  varchar2(1) := 'N';

  begin
    OPEN custom_exist(X_FORECAST_CATEGORY_ID);
    FETCH custom_exist into l_custom_exist;
    CLOSE custom_exist;

    IF nvl(l_custom_exist,'N') = 'N' THEN

    if (X_OWNER = 'SEED') then
	 user_id := 1;
    end if;

    begin

      l_forecast_category_id := X_FORECAST_CATEGORY_ID;

      AS_FORECAST_CATEGORIES_PKG.UPDATE_ROW(
          p_FORECAST_CATEGORY_ID     => X_FORECAST_CATEGORY_ID,
          p_CREATED_BY               => 0,
          p_CREATION_DATE            => sysdate,
          p_LAST_UPDATED_BY          => user_id,
          p_LAST_UPDATE_DATE         => sysdate,
          p_LAST_UPDATE_LOGIN        =>  0,
          p_FORECAST_CATEGORY_NAME   => X_FORECAST_CATEGORY_NAME,--FND_API.G_MISS_CHAR,
          p_START_DATE_ACTIVE        => x_start_date_active,
          p_END_DATE_ACTIVE          => x_end_date_active
      );

    exception
    when NO_DATA_FOUND then

	 AS_FORECAST_CATEGORIES_PKG.INSERT_ROW(
          px_FORECAST_CATEGORY_ID    => l_FORECAST_CATEGORY_ID,
          p_CREATED_BY               => 0,
          p_CREATION_DATE            => sysdate,
          p_LAST_UPDATED_BY          => user_id,
          p_LAST_UPDATE_DATE         => sysdate,
          p_LAST_UPDATE_LOGIN        => 0 ,
          p_FORECAST_CATEGORY_NAME   => X_FORECAST_CATEGORY_NAME,
          p_START_DATE_ACTIVE        => x_start_date_active,
          p_END_DATE_ACTIVE          => x_end_date_active
 	  );


   end;

   END IF; --customer not exist
 end;
END Load_Row;

procedure TRANSLATE_ROW (
  p_FORECAST_CATEGORY_ID in NUMBER,
  p_FORECAST_CATEGORY_NAME in VARCHAR2,
  p_OWNER in VARCHAR2)IS

begin
  -- only update rows that have not been altered by user
   update AS_FORECAST_CATEGORIES_TL
     set FORECAST_CATEGORY_NAME  = p_FORECAST_CATEGORY_NAME,
         source_lang = userenv('LANG'),
	    last_update_date = sysdate,
	    last_updated_by = decode(p_OWNER, 'SEED', 1, 0),
	    last_update_login = 0
      where  FORECAST_CATEGORY_ID = p_FORECAST_CATEGORY_ID
	 and userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;

End AS_FORECAST_CATEGORIES_PKG;

/
