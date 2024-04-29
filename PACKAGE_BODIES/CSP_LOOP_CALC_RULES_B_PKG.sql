--------------------------------------------------------
--  DDL for Package Body CSP_LOOP_CALC_RULES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_LOOP_CALC_RULES_B_PKG" as
/* $Header: csptpcrb.pls 115.9 2002/11/26 07:13:40 hhaugeru ship $ */
-- Start of Comments
-- Package name     : CSP_LOOP_CALC_RULES_B_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_LOOP_CALC_RULES_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csptpcrb.pls';

PROCEDURE Insert_Row(
          px_CALCULATION_RULE_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_CALCULATION_RULE_NAME    VARCHAR2,
          p_INCLUDE_SALES_ORDERS    VARCHAR2,
          p_INCLUDE_MOVE_ORDERS    VARCHAR2,
          p_INCLUDE_REPAIR_ORDERS    VARCHAR2,
          p_INCLUDE_WORK_ORDERS    VARCHAR2,
          p_INCLUDE_PURCHASE_ORDERS    VARCHAR2,
          p_INCLUDE_REQUISITIONS    VARCHAR2,
          p_INCLUDE_INTERORG_TRANSFERS    VARCHAR2,
          p_INCLUDE_ONHAND_GOOD    VARCHAR2,
          p_INCLUDE_ONHAND_BAD    VARCHAR2,
          p_INCLUDE_INTRANSIT_MOVE_ORD    VARCHAR2,
          p_TOLERANCE_PERCENT    NUMBER,
          p_TIME_FENCE    NUMBER,
		p_INCLUDE_DOA	VARCHAR2,
		p_ROLLUP_SUPERCESSION VARCHAR2,
		p_FORECAST_LOWER_SUPERCESSION VARCHAR2,
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
          p_DESCRIPTION    VARCHAR2 )

 IS
   CURSOR C2 IS SELECT CSP_LOOP_CALC_RULES_B_S1.nextval FROM sys.dual;

   CURSOR C3 is select ROWID from CSP_LOOP_CALC_RULES_B
   where CALCULATION_RULE_ID = px_CALCULATION_RULE_ID;

   p_ROWID  VARCHAR2(30);

BEGIN
   If (px_CALCULATION_RULE_ID IS NULL) OR (px_CALCULATION_RULE_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_CALCULATION_RULE_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSP_LOOP_CALC_RULES_B(
           CALCULATION_RULE_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           CALCULATION_RULE_NAME,
           INCLUDE_SALES_ORDERS,
           INCLUDE_MOVE_ORDERS,
           INCLUDE_REPAIR_ORDERS,
           INCLUDE_WORK_ORDERS,
           INCLUDE_PURCHASE_ORDERS,
           INCLUDE_REQUISITIONS,
           INCLUDE_INTERORG_TRANSFERS,
           INCLUDE_ONHAND_GOOD,
           INCLUDE_ONHAND_BAD,
           INCLUDE_INTRANSIT_MOVE_ORDERS,
           TOLERANCE_PERCENT,
           TIME_FENCE,
		 INCLUDE_DOA,
		 ROLLUP_SUPERCESSION,
		 FORECAST_LOWER_SUPERCESSION,
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
           px_CALCULATION_RULE_ID,
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode( p_CREATION_DATE, FND_API.G_MISS_DATE, to_date(null), p_CREATION_DATE),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, to_date(null), p_LAST_UPDATE_DATE),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_CALCULATION_RULE_NAME, FND_API.G_MISS_CHAR, NULL, p_CALCULATION_RULE_NAME),
           decode( p_INCLUDE_SALES_ORDERS, FND_API.G_MISS_CHAR, NULL, p_INCLUDE_SALES_ORDERS),
           decode( p_INCLUDE_MOVE_ORDERS, FND_API.G_MISS_CHAR, NULL, p_INCLUDE_MOVE_ORDERS),
           decode( p_INCLUDE_REPAIR_ORDERS, FND_API.G_MISS_CHAR, NULL, p_INCLUDE_REPAIR_ORDERS),
           decode( p_INCLUDE_WORK_ORDERS, FND_API.G_MISS_CHAR, NULL, p_INCLUDE_WORK_ORDERS),
           decode( p_INCLUDE_PURCHASE_ORDERS, FND_API.G_MISS_CHAR, NULL, p_INCLUDE_PURCHASE_ORDERS),
           decode( p_INCLUDE_REQUISITIONS, FND_API.G_MISS_CHAR, NULL, p_INCLUDE_REQUISITIONS),
           decode( p_INCLUDE_INTERORG_TRANSFERS, FND_API.G_MISS_CHAR, NULL, p_INCLUDE_INTERORG_TRANSFERS),
           decode( p_INCLUDE_ONHAND_GOOD, FND_API.G_MISS_CHAR, NULL, p_INCLUDE_ONHAND_GOOD),
           decode( p_INCLUDE_ONHAND_BAD, FND_API.G_MISS_CHAR, NULL, p_INCLUDE_ONHAND_BAD),
           decode( p_INCLUDE_INTRANSIT_MOVE_ORD, FND_API.G_MISS_CHAR, NULL, p_INCLUDE_INTRANSIT_MOVE_ORD),
           decode( p_TOLERANCE_PERCENT, FND_API.G_MISS_NUM, NULL, p_TOLERANCE_PERCENT),
           decode( p_TIME_FENCE, FND_API.G_MISS_NUM, NULL, p_TIME_FENCE),
           decode( p_INCLUDE_DOA, FND_API.G_MISS_CHAR, NULL, p_INCLUDE_DOA),
           decode( p_ROLLUP_SUPERCESSION, FND_API.G_MISS_CHAR, NULL, p_ROLLUP_SUPERCESSION),
           decode( p_FORECAST_LOWER_SUPERCESSION, FND_API.G_MISS_CHAR, NULL, p_FORECAST_LOWER_SUPERCESSION),
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

  insert into CSP_LOOP_CALC_RULES_TL (
    CALCULATION_RULE_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    px_CALCULATION_RULE_ID,
    p_CREATED_BY,
    p_CREATION_DATE,
    p_LAST_UPDATED_BY,
    p_LAST_UPDATE_DATE,
    p_LAST_UPDATE_LOGIN,
    p_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CSP_LOOP_CALC_RULES_TL T
    where T.CALCULATION_RULE_ID = px_CALCULATION_RULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c3;
  fetch c3 into P_ROWID;
  if (c3%notfound) then
    close c3;
    raise no_data_found;
  end if;
  close c3;

End Insert_Row;


PROCEDURE Update_Row(
          p_CALCULATION_RULE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_CALCULATION_RULE_NAME    VARCHAR2,
          p_INCLUDE_SALES_ORDERS    VARCHAR2,
          p_INCLUDE_MOVE_ORDERS    VARCHAR2,
          p_INCLUDE_REPAIR_ORDERS    VARCHAR2,
          p_INCLUDE_WORK_ORDERS    VARCHAR2,
          p_INCLUDE_PURCHASE_ORDERS    VARCHAR2,
          p_INCLUDE_REQUISITIONS    VARCHAR2,
          p_INCLUDE_INTERORG_TRANSFERS    VARCHAR2,
          p_INCLUDE_ONHAND_GOOD    VARCHAR2,
          p_INCLUDE_ONHAND_BAD    VARCHAR2,
          p_INCLUDE_INTRANSIT_MOVE_ORD    VARCHAR2,
          p_TOLERANCE_PERCENT    NUMBER,
          p_TIME_FENCE    NUMBER,
		p_INCLUDE_DOA	VARCHAR2,
		p_ROLLUP_SUPERCESSION VARCHAR2,
		p_FORECAST_LOWER_SUPERCESSION VARCHAR2,
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
          p_DESCRIPTION    VARCHAR2 )

 IS
 BEGIN
    Update CSP_LOOP_CALC_RULES_B
    SET
              CALCULATION_RULE_ID = decode( p_CALCULATION_RULE_ID, FND_API.G_MISS_NUM, CALCULATION_RULE_ID, p_CALCULATION_RULE_ID),
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode( p_CREATION_DATE, FND_API.G_MISS_DATE, CREATION_DATE, p_CREATION_DATE),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode( p_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              CALCULATION_RULE_NAME = decode( p_CALCULATION_RULE_NAME, FND_API.G_MISS_CHAR, CALCULATION_RULE_NAME, p_CALCULATION_RULE_NAME),
              INCLUDE_SALES_ORDERS = decode( p_INCLUDE_SALES_ORDERS, FND_API.G_MISS_CHAR, INCLUDE_SALES_ORDERS, p_INCLUDE_SALES_ORDERS),
              INCLUDE_MOVE_ORDERS = decode( p_INCLUDE_MOVE_ORDERS, FND_API.G_MISS_CHAR, INCLUDE_MOVE_ORDERS, p_INCLUDE_MOVE_ORDERS),
              INCLUDE_REPAIR_ORDERS = decode( p_INCLUDE_REPAIR_ORDERS, FND_API.G_MISS_CHAR, INCLUDE_REPAIR_ORDERS, p_INCLUDE_REPAIR_ORDERS),
              INCLUDE_WORK_ORDERS = decode( p_INCLUDE_WORK_ORDERS, FND_API.G_MISS_CHAR, INCLUDE_WORK_ORDERS, p_INCLUDE_WORK_ORDERS),
              INCLUDE_PURCHASE_ORDERS = decode( p_INCLUDE_PURCHASE_ORDERS, FND_API.G_MISS_CHAR, INCLUDE_PURCHASE_ORDERS, p_INCLUDE_PURCHASE_ORDERS),
              INCLUDE_REQUISITIONS = decode( p_INCLUDE_REQUISITIONS, FND_API.G_MISS_CHAR, INCLUDE_REQUISITIONS, p_INCLUDE_REQUISITIONS),
              INCLUDE_INTERORG_TRANSFERS = decode( p_INCLUDE_INTERORG_TRANSFERS, FND_API.G_MISS_CHAR, INCLUDE_INTERORG_TRANSFERS, p_INCLUDE_INTERORG_TRANSFERS),
              INCLUDE_ONHAND_GOOD = decode( p_INCLUDE_ONHAND_GOOD, FND_API.G_MISS_CHAR, INCLUDE_ONHAND_GOOD, p_INCLUDE_ONHAND_GOOD),
              INCLUDE_ONHAND_BAD = decode( p_INCLUDE_ONHAND_BAD, FND_API.G_MISS_CHAR, INCLUDE_ONHAND_BAD, p_INCLUDE_ONHAND_BAD),
              INCLUDE_INTRANSIT_MOVE_ORDERS = decode( p_INCLUDE_INTRANSIT_MOVE_ORD, FND_API.G_MISS_CHAR, INCLUDE_INTRANSIT_MOVE_ORDERS, p_INCLUDE_INTRANSIT_MOVE_ORD),
              TOLERANCE_PERCENT = decode( p_TOLERANCE_PERCENT, FND_API.G_MISS_NUM, TOLERANCE_PERCENT, p_TOLERANCE_PERCENT),
              TIME_FENCE = decode( p_TIME_FENCE, FND_API.G_MISS_NUM, TIME_FENCE, p_TIME_FENCE),
              INCLUDE_DOA = decode( p_INCLUDE_DOA, FND_API.G_MISS_CHAR, INCLUDE_DOA, p_INCLUDE_DOA),
              ROLLUP_SUPERCESSION = decode( p_ROLLUP_SUPERCESSION, FND_API.G_MISS_CHAR, ROLLUP_SUPERCESSION, p_ROLLUP_SUPERCESSION),
              FORECAST_LOWER_SUPERCESSION = decode( p_FORECAST_LOWER_SUPERCESSION, FND_API.G_MISS_CHAR, FORECAST_LOWER_SUPERCESSION, p_FORECAST_LOWER_SUPERCESSION),
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
    where CALCULATION_RULE_ID = p_CALCULATION_RULE_ID;

  If (SQL%NOTFOUND) then
     RAISE NO_DATA_FOUND;
  End If;

  update CSP_LOOP_CALC_RULES_TL set
    DESCRIPTION = p_DESCRIPTION,
    LAST_UPDATE_DATE = p_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = p_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CALCULATION_RULE_ID = p_CALCULATION_RULE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

END Update_Row;

PROCEDURE Delete_Row(
    p_CALCULATION_RULE_ID  NUMBER)
 IS
 BEGIN

  delete from CSP_LOOP_CALC_RULES_TL
  where CALCULATION_RULE_ID = p_CALCULATION_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

   DELETE FROM CSP_LOOP_CALC_RULES_B
    WHERE CALCULATION_RULE_ID = p_CALCULATION_RULE_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_CALCULATION_RULE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_CALCULATION_RULE_NAME    VARCHAR2,
          p_INCLUDE_SALES_ORDERS    VARCHAR2,
          p_INCLUDE_MOVE_ORDERS    VARCHAR2,
          p_INCLUDE_REPAIR_ORDERS    VARCHAR2,
          p_INCLUDE_WORK_ORDERS    VARCHAR2,
          p_INCLUDE_PURCHASE_ORDERS    VARCHAR2,
          p_INCLUDE_REQUISITIONS    VARCHAR2,
          p_INCLUDE_INTERORG_TRANSFERS    VARCHAR2,
          p_INCLUDE_ONHAND_GOOD    VARCHAR2,
          p_INCLUDE_ONHAND_BAD    VARCHAR2,
          p_INCLUDE_INTRANSIT_MOVE_ORD    VARCHAR2,
          p_TOLERANCE_PERCENT    NUMBER,
          p_TIME_FENCE    NUMBER,
		p_INCLUDE_DOA	VARCHAR2,
		p_ROLLUP_SUPERCESSION VARCHAR2,
		p_FORECAST_LOWER_SUPERCESSION VARCHAR2,
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
          p_DESCRIPTION    VARCHAR2 )

 IS
   CURSOR C IS
        SELECT *
         FROM CSP_LOOP_CALC_RULES_B
        WHERE CALCULATION_RULE_ID =  p_CALCULATION_RULE_ID
        FOR UPDATE of CALCULATION_RULE_ID NOWAIT;
   Recinfo C%ROWTYPE;

  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CSP_LOOP_CALC_RULES_TL
    where CALCULATION_RULE_ID = p_CALCULATION_RULE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CALCULATION_RULE_ID nowait;

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
         ( ( Recinfo.CALCULATION_RULE_ID = p_CALCULATION_RULE_ID)
            OR (    ( Recinfo.CALCULATION_RULE_ID IS NULL )
                AND (  p_CALCULATION_RULE_ID IS NULL )))
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
       AND (    ( Recinfo.CALCULATION_RULE_NAME = p_CALCULATION_RULE_NAME)
            OR (    ( Recinfo.CALCULATION_RULE_NAME IS NULL )
                AND (  p_CALCULATION_RULE_NAME IS NULL )))
       AND (    ( Recinfo.INCLUDE_SALES_ORDERS = p_INCLUDE_SALES_ORDERS)
            OR (    ( Recinfo.INCLUDE_SALES_ORDERS IS NULL )
                AND (  p_INCLUDE_SALES_ORDERS IS NULL )))
       AND (    ( Recinfo.INCLUDE_MOVE_ORDERS = p_INCLUDE_MOVE_ORDERS)
            OR (    ( Recinfo.INCLUDE_MOVE_ORDERS IS NULL )
                AND (  p_INCLUDE_MOVE_ORDERS IS NULL )))
       AND (    ( Recinfo.INCLUDE_REPAIR_ORDERS = p_INCLUDE_REPAIR_ORDERS)
            OR (    ( Recinfo.INCLUDE_REPAIR_ORDERS IS NULL )
                AND (  p_INCLUDE_REPAIR_ORDERS IS NULL )))
       AND (    ( Recinfo.INCLUDE_WORK_ORDERS = p_INCLUDE_WORK_ORDERS)
            OR (    ( Recinfo.INCLUDE_WORK_ORDERS IS NULL )
                AND (  p_INCLUDE_WORK_ORDERS IS NULL )))
       AND (    ( Recinfo.INCLUDE_PURCHASE_ORDERS = p_INCLUDE_PURCHASE_ORDERS)
            OR (    ( Recinfo.INCLUDE_PURCHASE_ORDERS IS NULL )
                AND (  p_INCLUDE_PURCHASE_ORDERS IS NULL )))
       AND (    ( Recinfo.INCLUDE_REQUISITIONS = p_INCLUDE_REQUISITIONS)
            OR (    ( Recinfo.INCLUDE_REQUISITIONS IS NULL )
                AND (  p_INCLUDE_REQUISITIONS IS NULL )))
       AND (    ( Recinfo.INCLUDE_INTERORG_TRANSFERS = p_INCLUDE_INTERORG_TRANSFERS)
            OR (    ( Recinfo.INCLUDE_INTERORG_TRANSFERS IS NULL )
                AND (  p_INCLUDE_INTERORG_TRANSFERS IS NULL )))
       AND (    ( Recinfo.INCLUDE_ONHAND_GOOD = p_INCLUDE_ONHAND_GOOD)
            OR (    ( Recinfo.INCLUDE_ONHAND_GOOD IS NULL )
                AND (  p_INCLUDE_ONHAND_GOOD IS NULL )))
       AND (    ( Recinfo.INCLUDE_ONHAND_BAD = p_INCLUDE_ONHAND_BAD)
            OR (    ( Recinfo.INCLUDE_ONHAND_BAD IS NULL )
                AND (  p_INCLUDE_ONHAND_BAD IS NULL )))
       AND (    ( Recinfo.INCLUDE_INTRANSIT_MOVE_ORDERS = p_INCLUDE_INTRANSIT_MOVE_ORD)
            OR (    ( Recinfo.INCLUDE_INTRANSIT_MOVE_ORDERS IS NULL )
                AND (  p_INCLUDE_INTRANSIT_MOVE_ORD IS NULL )))
       AND (    ( Recinfo.TOLERANCE_PERCENT = p_TOLERANCE_PERCENT)
            OR (    ( Recinfo.TOLERANCE_PERCENT IS NULL )
                AND (  p_TOLERANCE_PERCENT IS NULL )))
       AND (    ( Recinfo.TIME_FENCE = p_TIME_FENCE)
            OR (    ( Recinfo.TIME_FENCE IS NULL )
                AND (  p_TIME_FENCE IS NULL )))
       AND (    ( Recinfo.INCLUDE_DOA = p_INCLUDE_DOA)
            OR (    ( Recinfo.INCLUDE_DOA IS NULL )
                AND (  p_INCLUDE_DOA IS NULL )))
       AND (    ( Recinfo.ROLLUP_SUPERCESSION = p_ROLLUP_SUPERCESSION)
            OR (    ( Recinfo.ROLLUP_SUPERCESSION IS NULL )
                AND (  p_ROLLUP_SUPERCESSION IS NULL )))
       AND (    ( Recinfo.FORECAST_LOWER_SUPERCESSION = p_FORECAST_LOWER_SUPERCESSION)
            OR (    ( Recinfo.FORECAST_LOWER_SUPERCESSION IS NULL )
                AND (  p_FORECAST_LOWER_SUPERCESSION IS NULL )))
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
      if (    ((tlinfo.DESCRIPTION = P_DESCRIPTION)
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
  delete from CSP_LOOP_CALC_RULES_TL T
  where not exists
    (select NULL
    from CSP_LOOP_CALC_RULES_B B
    where B.CALCULATION_RULE_ID = T.CALCULATION_RULE_ID
    );

  update CSP_LOOP_CALC_RULES_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from CSP_LOOP_CALC_RULES_TL B
    where B.calculation_rule_id = T.calculation_rule_id
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.calculation_rule_id,
      T.LANGUAGE
  ) in (select
      SUBT.calculation_rule_id,
      SUBT.LANGUAGE
    from CSP_LOOP_CALC_RULES_TL SUBB, CSP_LOOP_CALC_RULES_TL SUBT
    where SUBB.calculation_rule_id = SUBT.calculation_rule_id
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CSP_LOOP_CALC_RULES_TL (
    calculation_rule_id,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.calculation_rule_id,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CSP_LOOP_CALC_RULES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CSP_LOOP_CALC_RULES_TL T
    where T.calculation_rule_id = B.calculation_rule_id
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE Translate_Row
( p_calculation_rule_id  IN  NUMBER
, p_description          IN  VARCHAR2
, p_owner				IN VARCHAR2
)
IS
l_user_id NUMBER := 0;
BEGIN

  if p_owner = 'SEED' then
    l_user_id := 1;
  end if;

  UPDATE csp_loop_calc_rules_tl
    SET description = p_description
      , last_update_date  = SYSDATE
      , last_updated_by   = l_user_id
      , last_update_login = 0
      , source_lang       = userenv('LANG')
    WHERE calculation_rule_id = p_calculation_rule_id
      AND userenv('LANG') in (LANGUAGE, SOURCE_LANG);

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Translate_Row');
    END IF;
    RAISE;

END Translate_Row;

PROCEDURE Load_Row
( p_calculation_rule_id IN  NUMBER
, p_description  	IN  VARCHAR2
, p_owner           IN VARCHAR2
)
IS

l_calculation_rule_id  	VARCHAR2(20);
l_user_id 		NUMBER := 0;

BEGIN

  -- assign user ID
  if p_owner = 'SEED' then
    l_user_id := 1; --SEED
  end if;

  BEGIN
    -- update row if present
    Update_Row(
          p_CALCULATION_RULE_ID		=>	p_calculation_rule_id,
          p_CREATED_BY    		=>	FND_API.G_MISS_NUM,
          p_CREATION_DATE    		=>	FND_API.G_MISS_DATE,
          p_LAST_UPDATED_BY    		=>	l_user_id,
          p_LAST_UPDATE_DATE    	=>	SYSDATE,
          p_LAST_UPDATE_LOGIN    	=>	0,
          p_CALCULATION_RULE_NAME    	=>	FND_API.G_MISS_CHAR,
          p_INCLUDE_SALES_ORDERS    	=>	FND_API.G_MISS_CHAR,
          p_INCLUDE_MOVE_ORDERS    	=>	FND_API.G_MISS_CHAR,
          p_INCLUDE_REPAIR_ORDERS    	=>	FND_API.G_MISS_CHAR,
          p_INCLUDE_WORK_ORDERS    	=>	FND_API.G_MISS_CHAR,
          p_INCLUDE_PURCHASE_ORDERS    	=>	FND_API.G_MISS_CHAR,
          p_INCLUDE_REQUISITIONS    	=>	FND_API.G_MISS_CHAR,
          p_INCLUDE_INTERORG_TRANSFERS  =>	FND_API.G_MISS_CHAR,
          p_INCLUDE_ONHAND_GOOD    	=>	FND_API.G_MISS_CHAR,
          p_INCLUDE_ONHAND_BAD    	=>	FND_API.G_MISS_CHAR,
          p_INCLUDE_INTRANSIT_MOVE_ORD  =>	FND_API.G_MISS_CHAR,
          p_TOLERANCE_PERCENT    	=>	FND_API.G_MISS_NUM,
          p_TIME_FENCE    		=>	FND_API.G_MISS_NUM,
		p_INCLUDE_DOA		     =>   FND_API.G_MISS_CHAR,
		p_ROLLUP_SUPERCESSION    =>   FND_API.G_MISS_CHAR,
		p_FORECAST_LOWER_SUPERCESSION	 =>   FND_API.G_MISS_CHAR,
          p_ATTRIBUTE_CATEGORY    	=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE1    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE2    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE3    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE4    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE5    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE6    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE7    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE8    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE9    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE10   	 	=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE11  	  	=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE12  	  	=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE13  	  	=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE14  	  	=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE15  	  	=>	FND_API.G_MISS_CHAR,
          p_DESCRIPTION  	  	=>	p_description);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- insert row
      Insert_Row(
          px_CALCULATION_RULE_ID	=>	l_calculation_rule_id,
          p_CREATED_BY    		=>	FND_API.G_MISS_NUM,
          p_CREATION_DATE    		=>	FND_API.G_MISS_DATE,
          p_LAST_UPDATED_BY    		=>	l_user_id,
          p_LAST_UPDATE_DATE    	=>	SYSDATE,
          p_LAST_UPDATE_LOGIN    	=>	0,
          p_CALCULATION_RULE_NAME    	=>	FND_API.G_MISS_CHAR,
          p_INCLUDE_SALES_ORDERS    	=>	FND_API.G_MISS_CHAR,
          p_INCLUDE_MOVE_ORDERS    	=>	FND_API.G_MISS_CHAR,
          p_INCLUDE_REPAIR_ORDERS    	=>	FND_API.G_MISS_CHAR,
          p_INCLUDE_WORK_ORDERS    	=>	FND_API.G_MISS_CHAR,
          p_INCLUDE_PURCHASE_ORDERS    	=>	FND_API.G_MISS_CHAR,
          p_INCLUDE_REQUISITIONS    	=>	FND_API.G_MISS_CHAR,
          p_INCLUDE_INTERORG_TRANSFERS  =>	FND_API.G_MISS_CHAR,
          p_INCLUDE_ONHAND_GOOD    	=>	FND_API.G_MISS_CHAR,
          p_INCLUDE_ONHAND_BAD    	=>	FND_API.G_MISS_CHAR,
          p_INCLUDE_INTRANSIT_MOVE_ORD  =>	FND_API.G_MISS_CHAR,
          p_TOLERANCE_PERCENT  	  	=>	FND_API.G_MISS_NUM,
          p_TIME_FENCE    		=>	FND_API.G_MISS_NUM,
		p_INCLUDE_DOA		     =>   FND_API.G_MISS_CHAR,
		p_ROLLUP_SUPERCESSION    =>   FND_API.G_MISS_CHAR,
		p_FORECAST_LOWER_SUPERCESSION	 =>   FND_API.G_MISS_CHAR,
          p_ATTRIBUTE_CATEGORY    	=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE1    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE2    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE3    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE4    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE5    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE6    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE7    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE8    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE9    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE10    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE11    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE12    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE13    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE14    		=>	FND_API.G_MISS_CHAR,
          p_ATTRIBUTE15    		=>	FND_API.G_MISS_CHAR,
          p_DESCRIPTION    		=>	p_description);
  END;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Load_Row');
    END IF;
    RAISE;

END Load_Row;

End CSP_LOOP_CALC_RULES_B_PKG;

/
