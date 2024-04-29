--------------------------------------------------------
--  DDL for Package Body CSP_PARTS_LOOPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_PARTS_LOOPS_PKG" as
/* $Header: csptplpb.pls 115.9 2002/11/26 07:15:34 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_PARTS_LOOPS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_PARTS_LOOPS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csptplpb.pls';

PROCEDURE Insert_Row(
          px_PARTS_LOOP_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PLANNER_CODE    VARCHAR2,
          p_CALCULATION_RULE_ID    NUMBER,
          p_FORECAST_RULE_ID    NUMBER,
          p_PARTS_LOOP_NAME    VARCHAR2,
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
          p_DESCRIPTION    VARCHAR2)

 IS

   CURSOR C2 IS SELECT CSP_PARTS_LOOPS_B_S1.nextval FROM sys.dual;
BEGIN
   If (px_PARTS_LOOP_ID IS NULL) OR (px_PARTS_LOOP_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_PARTS_LOOP_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSP_PARTS_LOOPS_B(
           PARTS_LOOP_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           ORGANIZATION_ID,
           PLANNER_CODE,
           CALCULATION_RULE_ID,
           FORECAST_RULE_ID,
           PARTS_LOOP_NAME,
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
           px_PARTS_LOOP_ID,
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode(p_CREATION_DATE, fnd_api.g_miss_date,to_date(null),p_creation_date),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode(p_LAST_UPDATE_DATE,fnd_api.g_miss_date,to_date(null),p_last_update_date),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, NULL, p_ORGANIZATION_ID),
           decode( p_PLANNER_CODE, FND_API.G_MISS_CHAR, NULL, p_PLANNER_CODE),
           decode( p_CALCULATION_RULE_ID, FND_API.G_MISS_NUM, NULL, p_CALCULATION_RULE_ID),
           decode( p_FORECAST_RULE_ID, FND_API.G_MISS_NUM, NULL, p_FORECAST_RULE_ID),
           decode( p_PARTS_LOOP_NAME, FND_API.G_MISS_CHAR, NULL, p_PARTS_LOOP_NAME),
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

  insert into CSP_PARTS_LOOPS_TL (
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    PARTS_LOOP_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LANGUAGE,
    SOURCE_LANG)
  select
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATE_LOGIN,
    P_DESCRIPTION,
    px_PARTS_LOOP_ID,
    P_CREATED_BY,
    P_CREATION_DATE,
    P_LAST_UPDATED_BY,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CSP_PARTS_LOOPS_TL T
    where T.PARTS_LOOP_ID = px_PARTS_LOOP_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

End Insert_Row;

PROCEDURE Update_Row(
          p_PARTS_LOOP_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PLANNER_CODE    VARCHAR2,
          p_CALCULATION_RULE_ID    NUMBER,
          p_FORECAST_RULE_ID    NUMBER,
          p_PARTS_LOOP_NAME    VARCHAR2,
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
          p_DESCRIPTION    VARCHAR2)

 IS
 BEGIN
    Update CSP_PARTS_LOOPS_B
    SET
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode(p_CREATION_DATE, fnd_api.g_miss_date,creation_date,p_creation_date),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode(p_LAST_UPDATE_DATE,fnd_api.g_miss_date,last_update_date,p_last_update_date),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              ORGANIZATION_ID = decode( p_ORGANIZATION_ID, FND_API.G_MISS_NUM, ORGANIZATION_ID, p_ORGANIZATION_ID),
              PLANNER_CODE = decode( p_PLANNER_CODE, FND_API.G_MISS_CHAR, PLANNER_CODE, p_PLANNER_CODE),
              CALCULATION_RULE_ID = decode( p_CALCULATION_RULE_ID, FND_API.G_MISS_NUM, CALCULATION_RULE_ID, p_CALCULATION_RULE_ID),
              FORECAST_RULE_ID = decode( p_FORECAST_RULE_ID, FND_API.G_MISS_NUM, FORECAST_RULE_ID, p_FORECAST_RULE_ID),
              PARTS_LOOP_NAME = decode( p_PARTS_LOOP_NAME, FND_API.G_MISS_CHAR, PARTS_LOOP_NAME, p_PARTS_LOOP_NAME),
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
    where PARTS_LOOP_ID = p_PARTS_LOOP_ID;

    If (SQL%NOTFOUND) then
        RAISE NO_DATA_FOUND;
    End If;

  update CSP_PARTS_LOOPS_TL set
    DESCRIPTION = P_DESCRIPTION,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PARTS_LOOP_ID = P_PARTS_LOOP_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

END Update_Row;

PROCEDURE Delete_Row(
    p_PARTS_LOOP_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM CSP_PARTS_LOOPS_B
    WHERE PARTS_LOOP_ID = p_PARTS_LOOP_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;

  delete from CSP_PARTS_LOOPS_TL
  where PARTS_LOOP_ID = p_PARTS_LOOP_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  --- Remove Master Stocklist
  delete from csp_mstrstck_lists_itms
  where  parts_loops_id = p_PARTS_LOOP_ID;

  -- Update Subinventory
  Update csp_sec_inventories
  Set   Parts_loop_id = NULL
  Where Parts_loop_id = p_PARTS_LOOP_ID;

 END Delete_Row;

PROCEDURE Lock_Row(
          p_PARTS_LOOP_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ORGANIZATION_ID    NUMBER,
          p_PLANNER_CODE    VARCHAR2,
          p_CALCULATION_RULE_ID    NUMBER,
          p_FORECAST_RULE_ID    NUMBER,
          p_PARTS_LOOP_NAME    VARCHAR2,
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
          p_DESCRIPTION    VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM CSP_PARTS_LOOPS_B
        WHERE PARTS_LOOP_ID =  p_PARTS_LOOP_ID
        FOR UPDATE of PARTS_LOOP_ID NOWAIT;

  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CSP_PARTS_LOOPS_TL
    where PARTS_LOOP_ID = p_PARTS_LOOP_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PARTS_LOOP_ID nowait;

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
           (      Recinfo.PARTS_LOOP_ID = p_PARTS_LOOP_ID)
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
       AND (    ( Recinfo.ORGANIZATION_ID = p_ORGANIZATION_ID)
            OR (    ( Recinfo.ORGANIZATION_ID IS NULL )
                AND (  p_ORGANIZATION_ID IS NULL )))
       AND (    ( Recinfo.PLANNER_CODE = p_PLANNER_CODE)
            OR (    ( Recinfo.PLANNER_CODE IS NULL )
                AND (  p_PLANNER_CODE IS NULL )))
       AND (    ( Recinfo.CALCULATION_RULE_ID = p_CALCULATION_RULE_ID)
            OR (    ( Recinfo.CALCULATION_RULE_ID IS NULL )
                AND (  p_CALCULATION_RULE_ID IS NULL )))
       AND (    ( Recinfo.FORECAST_RULE_ID = p_FORECAST_RULE_ID)
            OR (    ( Recinfo.FORECAST_RULE_ID IS NULL )
                AND (  p_FORECAST_RULE_ID IS NULL )))
       AND (    ( Recinfo.PARTS_LOOP_NAME = p_PARTS_LOOP_NAME)
            OR (    ( Recinfo.PARTS_LOOP_NAME IS NULL )
                AND (  p_PARTS_LOOP_NAME IS NULL )))
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
       null;
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
  delete from csp_parts_loops_tl T
  where not exists
    (select NULL
    from csp_parts_loops_b B
    where B.parts_loop_id = T.parts_loop_id
    );

  update csp_parts_loops_tl T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from csp_parts_loops_tl B
    where B.parts_loop_id = T.parts_loop_id
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.parts_loop_id,
      T.LANGUAGE
  ) in (select
      SUBT.parts_loop_id,
      SUBT.LANGUAGE
    from csp_parts_loops_tl SUBB, csp_parts_loops_tl SUBT
    where SUBB.parts_loop_id = SUBT.parts_loop_id
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into csp_parts_loops_tl (
    parts_loop_id,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.parts_loop_id,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from csp_parts_loops_tl B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from csp_parts_loops_tl T
    where T.parts_loop_id = B.parts_loop_id
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE Translate_Row
( p_parts_loop_id     IN  NUMBER
, p_description          IN  VARCHAR2
, p_owner				IN VARCHAR2
)
IS
l_user_id	NUMBER := 0;
BEGIN

  if p_owner = 'SEED' then
    l_user_id := 1;
  end if;

  UPDATE csp_parts_loops_tl
    SET description = p_description
      , last_update_date  = SYSDATE
      , last_updated_by   = l_user_id
      , last_update_login = 0
      , source_lang       = userenv('LANG')
    WHERE parts_loop_id = p_parts_loop_id
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
( p_parts_loop_id    IN  NUMBER
, p_description         IN  VARCHAR2
, p_owner               IN  VARCHAR2
)
IS

l_parts_loop_id      NUMBER;
l_user_id               NUMBER := 0;

BEGIN

  -- assign user ID
  if p_owner = 'SEED' then
    l_user_id := 1; --SEED
  end if;

  BEGIN
    -- update row if present
    Update_Row(
          p_parts_loop_id            	=>      p_parts_loop_id,
          p_CREATED_BY                  =>      FND_API.G_MISS_NUM,
          p_CREATION_DATE               =>      FND_API.G_MISS_DATE,
          p_LAST_UPDATED_BY             =>      l_user_id,
          p_LAST_UPDATE_DATE            =>      SYSDATE,
          p_LAST_UPDATE_LOGIN           =>      0,
          p_organization_id		     =>      FND_API.G_MISS_NUM,
          p_planner_code		          =>      FND_API.G_MISS_CHAR,
          p_calculation_rule_id	     =>      FND_API.G_MISS_NUM,
          p_forecast_rule_id		     =>      FND_API.G_MISS_NUM,
          p_parts_loop_name	          =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE_CATEGORY          =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE1                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE2                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE3                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE4                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE5                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE6                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE7                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE8                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE9                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE10                 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE11                 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE12                 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE13                 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE14                 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE15                 =>      FND_API.G_MISS_CHAR,
          p_DESCRIPTION                 =>      p_description);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- insert row
      Insert_Row(
          px_parts_loop_id           	=>      l_parts_loop_id,
          p_CREATED_BY                  =>      FND_API.G_MISS_NUM,
          p_CREATION_DATE               =>      FND_API.G_MISS_DATE,
          p_LAST_UPDATED_BY             =>      l_user_id,
          p_LAST_UPDATE_DATE            =>      SYSDATE,
          p_LAST_UPDATE_LOGIN           =>      0,
          p_organization_id             =>      FND_API.G_MISS_NUM,
          p_planner_code		          =>      FND_API.G_MISS_CHAR,
          p_calculation_rule_id         =>      FND_API.G_MISS_NUM,
          p_forecast_rule_id	          =>      FND_API.G_MISS_NUM,
          p_parts_loop_name	          =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE_CATEGORY          =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE1                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE2                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE3                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE4                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE5                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE6                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE7                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE8                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE9                  =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE10                 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE11                 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE12                 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE13                 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE14                 =>      FND_API.G_MISS_CHAR,
          p_ATTRIBUTE15                 =>      FND_API.G_MISS_CHAR,
          p_DESCRIPTION                 =>      p_description);
  END;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Load_Row');
    END IF;
    RAISE;

END Load_Row;

End CSP_PARTS_LOOPS_PKG;

/
