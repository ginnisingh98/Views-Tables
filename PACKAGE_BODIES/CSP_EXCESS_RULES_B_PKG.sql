--------------------------------------------------------
--  DDL for Package Body CSP_EXCESS_RULES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_EXCESS_RULES_B_PKG" as
/* $Header: csptexrb.pls 115.5 2002/11/26 07:26:56 hhaugeru noship $ */
-- Start of Comments
-- Package name     : CSP_EXCESS_RULES_B_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments



G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_EXCESS_RULES_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csptexrb.pls';

PROCEDURE Insert_Row(
          px_EXCESS_RULE_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_EXCESS_RULE_NAME    VARCHAR2,
          p_TOTAL_MAX_EXCESS    NUMBER,
          p_LINE_MAX_EXCESS    NUMBER,
          p_DAYS_SINCE_RECEIPT    NUMBER,
          p_TOTAL_EXCESS_VALUE    NUMBER,
          p_TOP_EXCESS_LINES    NUMBER,
          p_CATEGORY_SET_ID    NUMBER,
          p_CATEGORY_ID    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_DESCRIPTION       VARCHAR2)
 IS
   CURSOR C2 IS SELECT CSP_EXCESS_RULES_B_S1.nextval FROM sys.dual;
BEGIN
   If (px_EXCESS_RULE_ID IS NULL) OR (px_EXCESS_RULE_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_EXCESS_RULE_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSP_EXCESS_RULES_B(
           EXCESS_RULE_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           EXCESS_RULE_NAME,
           TOTAL_MAX_EXCESS,
           LINE_MAX_EXCESS,
           DAYS_SINCE_RECEIPT,
           TOTAL_EXCESS_VALUE,
           TOP_EXCESS_LINES,
           CATEGORY_SET_ID,
           CATEGORY_ID,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15
          ) VALUES (
           px_EXCESS_RULE_ID,
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_EXCESS_RULE_NAME, FND_API.G_MISS_CHAR, NULL, p_EXCESS_RULE_NAME),
           decode( p_TOTAL_MAX_EXCESS, FND_API.G_MISS_NUM, NULL, p_TOTAL_MAX_EXCESS),
           decode( p_LINE_MAX_EXCESS, FND_API.G_MISS_NUM, NULL, p_LINE_MAX_EXCESS),
           decode( p_DAYS_SINCE_RECEIPT, FND_API.G_MISS_NUM, NULL, p_DAYS_SINCE_RECEIPT),
           decode( p_TOTAL_EXCESS_VALUE, FND_API.G_MISS_NUM, NULL, p_TOTAL_EXCESS_VALUE),
           decode( p_TOP_EXCESS_LINES, FND_API.G_MISS_NUM, NULL, p_TOP_EXCESS_LINES),
           decode( p_CATEGORY_SET_ID, FND_API.G_MISS_NUM, NULL, p_CATEGORY_SET_ID),
           decode( p_CATEGORY_ID, FND_API.G_MISS_NUM, NULL, p_CATEGORY_ID),
           decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE_CATEGORY),
           decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE1),
           decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE2),
           decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE3),
           decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE4),
           decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE5),
           decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE6),
           decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE7),
           decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE8),
           decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE9),
           decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE10),
           decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE11),
           decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE12),
           decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE13),
           decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE14),
           decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, p_ATTRIBUTE15));
           insert into CSP_EXCESS_RULES_TL (
                                              EXCESS_RULE_ID,
                                              CREATED_BY,
                                              CREATION_DATE,
                                              LAST_UPDATED_BY,
                                              LAST_UPDATE_DATE,
                                              LAST_UPDATE_LOGIN,
                                              DESCRIPTION,
                                              LANGUAGE,
                                              SOURCE_LANG
                                              ) select
                                                    pX_EXCESS_RULE_ID,
                                                    p_CREATED_BY,
                                                    p_CREATION_DATE,
                                                    p_LAST_UPDATED_BY,
                                                    p_last_update_DATE,
                                                    p_LAST_UPDATE_LOGIN,
                                                     p_DESCRIPTION,
                                                    L.LANGUAGE_CODE,
                                                    userenv('LANG')
                                              from FND_LANGUAGES L
                                              where L.INSTALLED_FLAG in ('I', 'B')
                                              and not exists
                                                (select NULL
                                                 from CSP_EXCESS_RULES_TL T
                                                 where T.EXCESS_RULE_ID = pX_EXCESS_RULE_ID
                                                and T.LANGUAGE = L.LANGUAGE_CODE);

End Insert_Row;

PROCEDURE Update_Row(
          p_EXCESS_RULE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_EXCESS_RULE_NAME    VARCHAR2,
          p_TOTAL_MAX_EXCESS    NUMBER,
          p_LINE_MAX_EXCESS    NUMBER,
          p_DAYS_SINCE_RECEIPT    NUMBER,
          p_TOTAL_EXCESS_VALUE    NUMBER,
          p_TOP_EXCESS_LINES    NUMBER,
          p_CATEGORY_SET_ID    NUMBER,
          p_CATEGORY_ID    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_DESCRIPTION       VARCHAR2)
 IS
 BEGIN
    Update CSP_EXCESS_RULES_B
    SET
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              EXCESS_RULE_NAME = decode( p_EXCESS_RULE_NAME, FND_API.G_MISS_CHAR, EXCESS_RULE_NAME, p_EXCESS_RULE_NAME),
              TOTAL_MAX_EXCESS = decode( p_TOTAL_MAX_EXCESS, FND_API.G_MISS_NUM, TOTAL_MAX_EXCESS, p_TOTAL_MAX_EXCESS),
              LINE_MAX_EXCESS = decode( p_LINE_MAX_EXCESS, FND_API.G_MISS_NUM, LINE_MAX_EXCESS, p_LINE_MAX_EXCESS),
              DAYS_SINCE_RECEIPT = decode( p_DAYS_SINCE_RECEIPT, FND_API.G_MISS_NUM, DAYS_SINCE_RECEIPT, p_DAYS_SINCE_RECEIPT),
              TOTAL_EXCESS_VALUE = decode( p_TOTAL_EXCESS_VALUE, FND_API.G_MISS_NUM, TOTAL_EXCESS_VALUE, p_TOTAL_EXCESS_VALUE),
              TOP_EXCESS_LINES = decode( p_TOP_EXCESS_LINES, FND_API.G_MISS_NUM, TOP_EXCESS_LINES, p_TOP_EXCESS_LINES),
              CATEGORY_SET_ID = decode( p_CATEGORY_SET_ID, FND_API.G_MISS_NUM, CATEGORY_SET_ID, p_CATEGORY_SET_ID),
              CATEGORY_ID = decode( p_CATEGORY_ID, FND_API.G_MISS_NUM, CATEGORY_ID, p_CATEGORY_ID),
              ATTRIBUTE_CATEGORY = decode( p_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, ATTRIBUTE_CATEGORY, p_ATTRIBUTE_CATEGORY),
              ATTRIBUTE1 = decode( p_ATTRIBUTE1, FND_API.G_MISS_CHAR, ATTRIBUTE1, p_ATTRIBUTE1),
              ATTRIBUTE2 = decode( p_ATTRIBUTE2, FND_API.G_MISS_CHAR, ATTRIBUTE2, p_ATTRIBUTE2),
              ATTRIBUTE3 = decode( p_ATTRIBUTE3, FND_API.G_MISS_CHAR, ATTRIBUTE3, p_ATTRIBUTE3),
              ATTRIBUTE4 = decode( p_ATTRIBUTE4, FND_API.G_MISS_CHAR, ATTRIBUTE4, p_ATTRIBUTE4),
              ATTRIBUTE5 = decode( p_ATTRIBUTE5, FND_API.G_MISS_CHAR, ATTRIBUTE5, p_ATTRIBUTE5),
              ATTRIBUTE6 = decode( p_ATTRIBUTE6, FND_API.G_MISS_CHAR, ATTRIBUTE6, p_ATTRIBUTE6),
              ATTRIBUTE7 = decode( p_ATTRIBUTE7, FND_API.G_MISS_CHAR, ATTRIBUTE7, p_ATTRIBUTE7),
              ATTRIBUTE8 = decode( p_ATTRIBUTE8, FND_API.G_MISS_CHAR, ATTRIBUTE8, p_ATTRIBUTE8),
              ATTRIBUTE9 = decode( p_ATTRIBUTE9, FND_API.G_MISS_CHAR, ATTRIBUTE9, p_ATTRIBUTE9),
              ATTRIBUTE10 = decode( p_ATTRIBUTE10, FND_API.G_MISS_CHAR, ATTRIBUTE10, p_ATTRIBUTE10),
              ATTRIBUTE11 = decode( p_ATTRIBUTE11, FND_API.G_MISS_CHAR, ATTRIBUTE11, p_ATTRIBUTE11),
              ATTRIBUTE12 = decode( p_ATTRIBUTE12, FND_API.G_MISS_CHAR, ATTRIBUTE12, p_ATTRIBUTE12),
              ATTRIBUTE13 = decode( p_ATTRIBUTE13, FND_API.G_MISS_CHAR, ATTRIBUTE13, p_ATTRIBUTE13),
              ATTRIBUTE14 = decode( p_ATTRIBUTE14, FND_API.G_MISS_CHAR, ATTRIBUTE14, p_ATTRIBUTE14),
              ATTRIBUTE15 = decode( p_ATTRIBUTE15, FND_API.G_MISS_CHAR, ATTRIBUTE15, p_ATTRIBUTE15)
    where EXCESS_RULE_ID = p_EXCESS_RULE_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

    update CSP_EXCESS_RULES_TL set
        DESCRIPTION = p_DESCRIPTION,
        LAST_UPDATE_DATE = p_last_update_DATE,
        LAST_UPDATED_BY = p_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN,
        SOURCE_LANG = userenv('LANG')
   where EXCESS_RULE_ID = p_EXCESS_RULE_ID
   and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

   if (sql%notfound) then
     raise no_data_found;
   end if;
END Update_Row;

PROCEDURE Delete_Row(
    p_EXCESS_RULE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSP_EXCESS_RULES_B
    WHERE EXCESS_RULE_ID = p_EXCESS_RULE_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
   DELETE FROM CSP_EXCESS_RULES_TL
    WHERE EXCESS_RULE_ID = p_EXCESS_RULE_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_EXCESS_RULE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_EXCESS_RULE_NAME    VARCHAR2,
          p_TOTAL_MAX_EXCESS    NUMBER,
          p_LINE_MAX_EXCESS    NUMBER,
          p_DAYS_SINCE_RECEIPT    NUMBER,
          p_TOTAL_EXCESS_VALUE    NUMBER,
          p_TOP_EXCESS_LINES    NUMBER,
          p_CATEGORY_SET_ID    NUMBER,
          p_CATEGORY_ID    NUMBER,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_DESCRIPTION       VARCHAR2)
 IS
   CURSOR C IS
        SELECT *
         FROM CSP_EXCESS_RULES_B
        WHERE EXCESS_RULE_ID =  p_EXCESS_RULE_ID
        FOR UPDATE of EXCESS_RULE_ID NOWAIT;
   CURSOR c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CSP_EXCESS_RULES_TL
    where EXCESS_RULE_ID = p_EXCESS_RULE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of EXCESS_RULE_ID nowait;

   Recinfo C%ROWTYPE;
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
           (      Recinfo.EXCESS_RULE_ID = p_EXCESS_RULE_ID)
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
       AND (    ( Recinfo.EXCESS_RULE_NAME = p_EXCESS_RULE_NAME)
            OR (    ( Recinfo.EXCESS_RULE_NAME IS NULL )
                AND (  p_EXCESS_RULE_NAME IS NULL )))
       AND (    ( Recinfo.TOTAL_MAX_EXCESS = p_TOTAL_MAX_EXCESS)
            OR (    ( Recinfo.TOTAL_MAX_EXCESS IS NULL )
                AND (  p_TOTAL_MAX_EXCESS IS NULL )))
       AND (    ( Recinfo.LINE_MAX_EXCESS = p_LINE_MAX_EXCESS)
            OR (    ( Recinfo.LINE_MAX_EXCESS IS NULL )
                AND (  p_LINE_MAX_EXCESS IS NULL )))
       AND (    ( Recinfo.DAYS_SINCE_RECEIPT = p_DAYS_SINCE_RECEIPT)
            OR (    ( Recinfo.DAYS_SINCE_RECEIPT IS NULL )
                AND (  p_DAYS_SINCE_RECEIPT IS NULL )))
       AND (    ( Recinfo.TOTAL_EXCESS_VALUE = p_TOTAL_EXCESS_VALUE)
            OR (    ( Recinfo.TOTAL_EXCESS_VALUE IS NULL )
                AND (  p_TOTAL_EXCESS_VALUE IS NULL )))
       AND (    ( Recinfo.TOP_EXCESS_LINES = p_TOP_EXCESS_LINES)
            OR (    ( Recinfo.TOP_EXCESS_LINES IS NULL )
                AND (  p_TOP_EXCESS_LINES IS NULL )))
       AND (    ( Recinfo.CATEGORY_SET_ID = p_CATEGORY_SET_ID)
            OR (    ( Recinfo.CATEGORY_SET_ID IS NULL )
                AND (  p_CATEGORY_SET_ID IS NULL )))
       AND (    ( Recinfo.CATEGORY_ID = p_CATEGORY_ID)
            OR (    ( Recinfo.CATEGORY_ID IS NULL )
                AND (  p_CATEGORY_ID IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE_CATEGORY = p_ATTRIBUTE_CATEGORY)
            OR (    ( Recinfo.ATTRIBUTE_CATEGORY IS NULL )
                AND (  p_ATTRIBUTE_CATEGORY IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE1 = p_ATTRIBUTE1)
            OR (    ( Recinfo.ATTRIBUTE1 IS NULL )
                AND (  p_ATTRIBUTE1 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE2 = p_ATTRIBUTE2)
            OR (    ( Recinfo.ATTRIBUTE2 IS NULL )
                AND (  p_ATTRIBUTE2 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE3 = p_ATTRIBUTE3)
            OR (    ( Recinfo.ATTRIBUTE3 IS NULL )
                AND (  p_ATTRIBUTE3 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE4 = p_ATTRIBUTE4)
            OR (    ( Recinfo.ATTRIBUTE4 IS NULL )
                AND (  p_ATTRIBUTE4 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE5 = p_ATTRIBUTE5)
            OR (    ( Recinfo.ATTRIBUTE5 IS NULL )
                AND (  p_ATTRIBUTE5 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE6 = p_ATTRIBUTE6)
            OR (    ( Recinfo.ATTRIBUTE6 IS NULL )
                AND (  p_ATTRIBUTE6 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE7 = p_ATTRIBUTE7)
            OR (    ( Recinfo.ATTRIBUTE7 IS NULL )
                AND (  p_ATTRIBUTE7 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE8 = p_ATTRIBUTE8)
            OR (    ( Recinfo.ATTRIBUTE8 IS NULL )
                AND (  p_ATTRIBUTE8 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE9 = p_ATTRIBUTE9)
            OR (    ( Recinfo.ATTRIBUTE9 IS NULL )
                AND (  p_ATTRIBUTE9 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE10 = p_ATTRIBUTE10)
            OR (    ( Recinfo.ATTRIBUTE10 IS NULL )
                AND (  p_ATTRIBUTE10 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE11 = p_ATTRIBUTE11)
            OR (    ( Recinfo.ATTRIBUTE11 IS NULL )
                AND (  p_ATTRIBUTE11 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE12 = p_ATTRIBUTE12)
            OR (    ( Recinfo.ATTRIBUTE12 IS NULL )
                AND (  p_ATTRIBUTE12 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE13 = p_ATTRIBUTE13)
            OR (    ( Recinfo.ATTRIBUTE13 IS NULL )
                AND (  p_ATTRIBUTE13 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE14 = p_ATTRIBUTE14)
            OR (    ( Recinfo.ATTRIBUTE14 IS NULL )
                AND (  p_ATTRIBUTE14 IS NULL )))
       AND (    ( Recinfo.ATTRIBUTE15 = p_ATTRIBUTE15)
            OR (    ( Recinfo.ATTRIBUTE15 IS NULL )
                AND (  p_ATTRIBUTE15 IS NULL )))
       ) then
       return;
   else
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   End If;
   for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DESCRIPTION = p_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (p_DESCRIPTION is null)))
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
procedure ADD_LANGUAGE
is
begin
  delete from CSP_EXCESS_RULES_TL T
  where not exists
    (select NULL
    from CSP_EXCESS_RULES_B B
    where B.EXCESS_RULE_ID = T.EXCESS_RULE_ID
    );

  update CSP_EXCESS_RULES_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from CSP_EXCESS_RULES_TL B
    where B.EXCESS_RULE_ID = T.EXCESS_RULE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.EXCESS_RULE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.EXCESS_RULE_ID,
      SUBT.LANGUAGE
    from CSP_EXCESS_RULES_TL SUBB, CSP_EXCESS_RULES_TL SUBT
    where SUBB.EXCESS_RULE_ID = SUBT.EXCESS_RULE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CSP_EXCESS_RULES_TL (
    EXCESS_RULE_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.EXCESS_RULE_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CSP_EXCESS_RULES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CSP_EXCESS_RULES_TL T
    where T.EXCESS_RULE_ID = B.EXCESS_RULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE Translate_Row
( p_excess_rule_id     IN  NUMBER
, p_description          IN  VARCHAR2
, p_owner                IN  VARCHAR2
)
IS
l_user_id    NUMBER := 0;
BEGIN

  if p_owner = 'SEED' then
    l_user_id := 1;
  end if;

  UPDATE csp_excess_rules_tl
    SET description = p_description
      , last_update_date  = SYSDATE
      , last_updated_by   = l_user_id
      , last_update_login = 0
      , source_lang       = userenv('LANG')
    WHERE excess_rule_id = p_excess_rule_id
      AND userenv('LANG') IN (language, source_lang);

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Translate_Row');
    END IF;
    RAISE;

END Translate_Row;

PROCEDURE Load_Row
( p_excess_rule_id    IN  NUMBER
, p_description         IN  VARCHAR2
, p_owner               IN VARCHAR2
)
IS

l_excess_rule_id      NUMBER;
l_user_id               NUMBER := 0;

BEGIN

  -- assign user ID
  if p_owner = 'SEED' then
    l_user_id := 1; --SEED
  end if;

  BEGIN
    -- update row if present
    Update_Row(
          p_EXCESS_RULE_ID => p_excess_rule_id,
          p_CREATED_BY     => l_user_id,
          p_CREATION_DATE  => sysdate ,
          p_LAST_UPDATED_BY => l_user_id,
          p_LAST_UPDATE_DATE => sysdate,
          p_LAST_UPDATE_LOGIN => 0,
          p_EXCESS_RULE_NAME => FND_API.G_MISS_CHAR,
          p_TOTAL_MAX_EXCESS => FND_API.G_MISS_NUM,
          p_LINE_MAX_EXCESS => FND_API.G_MISS_NUM,
          p_DAYS_SINCE_RECEIPT => FND_API.G_MISS_NUM,
          p_TOTAL_EXCESS_VALUE => FND_API.G_MISS_NUM,
          p_TOP_EXCESS_LINES => FND_API.G_MISS_NUM,
          p_CATEGORY_SET_ID => FND_API.G_MISS_NUM,
          p_CATEGORY_ID => FND_API.G_MISS_NUM,
          p_ATTRIBUTE_CATEGORY =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE1 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE2 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE3 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE4 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE5 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE6 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE7 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE8 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE9 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE10 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE11 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE12 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE13 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE14 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE15 =>      FND_API.G_MISS_CHAR,
          p_DESCRIPTION => p_description);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- insert row
      Insert_Row(
          px_EXCESS_RULE_ID => l_excess_rule_id,
          p_CREATED_BY     => l_user_id,
          p_CREATION_DATE  => sysdate ,
          p_LAST_UPDATED_BY => l_user_id,
          p_LAST_UPDATE_DATE => sysdate,
          p_LAST_UPDATE_LOGIN => 0,
          p_EXCESS_RULE_NAME => FND_API.G_MISS_CHAR,
          p_TOTAL_MAX_EXCESS => FND_API.G_MISS_NUM,
          p_LINE_MAX_EXCESS => FND_API.G_MISS_NUM,
          p_DAYS_SINCE_RECEIPT => FND_API.G_MISS_NUM,
          p_TOTAL_EXCESS_VALUE => FND_API.G_MISS_NUM,
          p_TOP_EXCESS_LINES => FND_API.G_MISS_NUM,
          p_CATEGORY_SET_ID => FND_API.G_MISS_NUM,
          p_CATEGORY_ID => FND_API.G_MISS_NUM,
          p_ATTRIBUTE_CATEGORY =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE1 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE2 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE3 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE4 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE5 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE6 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE7 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE8 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE9 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE10 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE11 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE12 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE13 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE14 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE15 =>      FND_API.G_MISS_CHAR,
          p_DESCRIPTION => p_description);
  END;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Load_Row');
    END IF;
    RAISE;

END Load_Row;
End CSP_EXCESS_RULES_B_PKG;

/
