--------------------------------------------------------
--  DDL for Package Body CSP_FORECAST_RULES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_FORECAST_RULES_B_PKG" as
/* $Header: csptpfrb.pls 115.8 2003/05/29 20:31:19 sunarasi ship $ */
-- Start of Comments
-- Package name     : CSP_FORECAST_RULES_B_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_FORECAST_RULES_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csptpfrb.pls';

PROCEDURE Insert_Row(
          px_FORECAST_RULE_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_FORECAST_RULE_NAME    VARCHAR2,
          p_PERIOD_TYPE    VARCHAR2,
		p_PERIOD_SIZE 	  NUMBER,
          p_FORECAST_PERIODS    NUMBER,
          p_FORECAST_METHOD    VARCHAR2,
          p_HISTORY_PERIODS    NUMBER,
          p_ALPHA    NUMBER,
          p_BETA    NUMBER,
	  p_TRACKING_SIGNAL_CYCLE   NUMBER,
          p_WEIGHTED_AVG_PERIOD1    NUMBER,
          p_WEIGHTED_AVG_PERIOD2    NUMBER,
          p_WEIGHTED_AVG_PERIOD3    NUMBER,
          p_WEIGHTED_AVG_PERIOD4    NUMBER,
          p_WEIGHTED_AVG_PERIOD5    NUMBER,
          p_WEIGHTED_AVG_PERIOD6    NUMBER,
          p_WEIGHTED_AVG_PERIOD7    NUMBER,
          p_WEIGHTED_AVG_PERIOD8    NUMBER,
          p_WEIGHTED_AVG_PERIOD9    NUMBER,
          p_WEIGHTED_AVG_PERIOD10    NUMBER,
          p_WEIGHTED_AVG_PERIOD11    NUMBER,
          p_WEIGHTED_AVG_PERIOD12    NUMBER,
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
   CURSOR C2 IS SELECT CSP_FORECAST_RULES_B_S1.nextval FROM sys.dual;
BEGIN
   If (px_FORECAST_RULE_ID IS NULL) OR (px_FORECAST_RULE_ID = FND_API.G_MISS_NUM) then
       OPEN C2;
       FETCH C2 INTO px_FORECAST_RULE_ID;
       CLOSE C2;
   End If;
   INSERT INTO CSP_FORECAST_RULES_B(
           FORECAST_RULE_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           FORECAST_RULE_NAME,
           PERIOD_TYPE,
		 PERIOD_SIZE,
           FORECAST_PERIODS,
           FORECAST_METHOD,
           HISTORY_PERIODS,
           ALPHA,
           BETA,
	   TRACKING_SIGNAL_CYCLE,
           WEIGHTED_AVG_PERIOD1,
           WEIGHTED_AVG_PERIOD2,
           WEIGHTED_AVG_PERIOD3,
           WEIGHTED_AVG_PERIOD4,
           WEIGHTED_AVG_PERIOD5,
           WEIGHTED_AVG_PERIOD6,
           WEIGHTED_AVG_PERIOD7,
           WEIGHTED_AVG_PERIOD8,
           WEIGHTED_AVG_PERIOD9,
           WEIGHTED_AVG_PERIOD10,
           WEIGHTED_AVG_PERIOD11,
           WEIGHTED_AVG_PERIOD12,
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
           px_FORECAST_RULE_ID,
           decode( p_CREATED_BY, FND_API.G_MISS_NUM, NULL, p_CREATED_BY),
           decode(p_CREATION_DATE,fnd_api.g_miss_date,to_date(null),p_creation_date),
           decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATED_BY),
           decode(p_last_update_date,fnd_api.g_miss_date,to_date(null),p_last_update_date),
           decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL, p_LAST_UPDATE_LOGIN),
           decode( p_FORECAST_RULE_NAME, FND_API.G_MISS_CHAR, NULL, p_FORECAST_RULE_NAME),
           decode( p_PERIOD_TYPE, FND_API.G_MISS_CHAR, NULL, p_PERIOD_TYPE),
           decode( p_PERIOD_SIZE, FND_API.G_MISS_NUM, NULL, p_PERIOD_SIZE),
           decode( p_FORECAST_PERIODS, FND_API.G_MISS_NUM, NULL, p_FORECAST_PERIODS),
           decode( p_FORECAST_METHOD, FND_API.G_MISS_CHAR, NULL, p_FORECAST_METHOD),
           decode( p_HISTORY_PERIODS, FND_API.G_MISS_NUM, NULL, p_HISTORY_PERIODS),
           decode( p_ALPHA, FND_API.G_MISS_NUM, NULL, p_ALPHA),
           decode( p_BETA, FND_API.G_MISS_NUM, NULL, p_BETA),
           decode( p_TRACKING_SIGNAL_CYCLE, FND_API.G_MISS_NUM, NULL, p_TRACKING_SIGNAL_CYCLE),
           decode( p_WEIGHTED_AVG_PERIOD1, FND_API.G_MISS_NUM, NULL, p_WEIGHTED_AVG_PERIOD1),
           decode( p_WEIGHTED_AVG_PERIOD2, FND_API.G_MISS_NUM, NULL, p_WEIGHTED_AVG_PERIOD2),
           decode( p_WEIGHTED_AVG_PERIOD3, FND_API.G_MISS_NUM, NULL, p_WEIGHTED_AVG_PERIOD3),
           decode( p_WEIGHTED_AVG_PERIOD4, FND_API.G_MISS_NUM, NULL, p_WEIGHTED_AVG_PERIOD4),
           decode( p_WEIGHTED_AVG_PERIOD5, FND_API.G_MISS_NUM, NULL, p_WEIGHTED_AVG_PERIOD5),
           decode( p_WEIGHTED_AVG_PERIOD6, FND_API.G_MISS_NUM, NULL, p_WEIGHTED_AVG_PERIOD6),
           decode( p_WEIGHTED_AVG_PERIOD7, FND_API.G_MISS_NUM, NULL, p_WEIGHTED_AVG_PERIOD7),
           decode( p_WEIGHTED_AVG_PERIOD8, FND_API.G_MISS_NUM, NULL, p_WEIGHTED_AVG_PERIOD8),
           decode( p_WEIGHTED_AVG_PERIOD9, FND_API.G_MISS_NUM, NULL, p_WEIGHTED_AVG_PERIOD9),
           decode( p_WEIGHTED_AVG_PERIOD10, FND_API.G_MISS_NUM, NULL, p_WEIGHTED_AVG_PERIOD10),
           decode( p_WEIGHTED_AVG_PERIOD11, FND_API.G_MISS_NUM, NULL, p_WEIGHTED_AVG_PERIOD11),
           decode( p_WEIGHTED_AVG_PERIOD12, FND_API.G_MISS_NUM, NULL, p_WEIGHTED_AVG_PERIOD12),
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

  insert into CSP_FORECAST_RULES_TL (
    FORECAST_RULE_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    pX_FORECAST_RULE_ID,
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
    from CSP_FORECAST_RULES_TL T
    where T.FORECAST_RULE_ID = pX_FORECAST_RULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

End Insert_Row;

PROCEDURE Update_Row(
          p_FORECAST_RULE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_FORECAST_RULE_NAME    VARCHAR2,
          p_PERIOD_TYPE    VARCHAR2,
		p_PERIOD_SIZE    NUMBER,
          p_FORECAST_PERIODS    NUMBER,
          p_FORECAST_METHOD    VARCHAR2,
          p_HISTORY_PERIODS    NUMBER,
          p_ALPHA    NUMBER,
          p_BETA    NUMBER,
	  p_TRACKING_SIGNAL_CYCLE   NUMBER,
          p_WEIGHTED_AVG_PERIOD1    NUMBER,
          p_WEIGHTED_AVG_PERIOD2    NUMBER,
          p_WEIGHTED_AVG_PERIOD3    NUMBER,
          p_WEIGHTED_AVG_PERIOD4    NUMBER,
          p_WEIGHTED_AVG_PERIOD5    NUMBER,
          p_WEIGHTED_AVG_PERIOD6    NUMBER,
          p_WEIGHTED_AVG_PERIOD7    NUMBER,
          p_WEIGHTED_AVG_PERIOD8    NUMBER,
          p_WEIGHTED_AVG_PERIOD9    NUMBER,
          p_WEIGHTED_AVG_PERIOD10    NUMBER,
          p_WEIGHTED_AVG_PERIOD11    NUMBER,
          p_WEIGHTED_AVG_PERIOD12    NUMBER,
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
    Update CSP_FORECAST_RULES_B
    SET
              CREATED_BY = decode( p_CREATED_BY, FND_API.G_MISS_NUM, CREATED_BY, p_CREATED_BY),
              CREATION_DATE = decode(p_CREATION_DATE,fnd_api.g_miss_date,creation_date,p_creation_date),
              LAST_UPDATED_BY = decode( p_LAST_UPDATED_BY, FND_API.G_MISS_NUM, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              LAST_UPDATE_DATE = decode(p_last_update_DATE,fnd_api.g_miss_date,last_update_date,p_last_update_date),
              LAST_UPDATE_LOGIN = decode( p_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              FORECAST_RULE_NAME = decode( p_FORECAST_RULE_NAME, FND_API.G_MISS_CHAR, FORECAST_RULE_NAME, p_FORECAST_RULE_NAME),
              PERIOD_TYPE = decode( p_PERIOD_TYPE, FND_API.G_MISS_CHAR, PERIOD_TYPE, p_PERIOD_TYPE),
              PERIOD_SIZE = decode( p_PERIOD_SIZE, FND_API.G_MISS_NUM, PERIOD_SIZE, p_PERIOD_SIZE),
              FORECAST_PERIODS = decode( p_FORECAST_PERIODS, FND_API.G_MISS_NUM, FORECAST_PERIODS, p_FORECAST_PERIODS),
              FORECAST_METHOD = decode( p_FORECAST_METHOD, FND_API.G_MISS_CHAR, FORECAST_METHOD, p_FORECAST_METHOD),
              HISTORY_PERIODS = decode( p_HISTORY_PERIODS, FND_API.G_MISS_NUM, HISTORY_PERIODS, p_HISTORY_PERIODS),
              ALPHA = decode( p_ALPHA, FND_API.G_MISS_NUM, ALPHA, p_ALPHA),
              BETA = decode( p_BETA, FND_API.G_MISS_NUM, BETA, p_BETA),
              TRACKING_SIGNAL_CYCLE = decode( p_TRACKING_SIGNAL_CYCLE, FND_API.G_MISS_NUM, TRACKING_SIGNAL_CYCLE, p_TRACKING_SIGNAL_CYCLE),
              WEIGHTED_AVG_PERIOD1 = decode( p_WEIGHTED_AVG_PERIOD1, FND_API.G_MISS_NUM, WEIGHTED_AVG_PERIOD1, p_WEIGHTED_AVG_PERIOD1),
              WEIGHTED_AVG_PERIOD2 = decode( p_WEIGHTED_AVG_PERIOD2, FND_API.G_MISS_NUM, WEIGHTED_AVG_PERIOD2, p_WEIGHTED_AVG_PERIOD2),
              WEIGHTED_AVG_PERIOD3 = decode( p_WEIGHTED_AVG_PERIOD3, FND_API.G_MISS_NUM, WEIGHTED_AVG_PERIOD3, p_WEIGHTED_AVG_PERIOD3),
              WEIGHTED_AVG_PERIOD4 = decode( p_WEIGHTED_AVG_PERIOD4, FND_API.G_MISS_NUM, WEIGHTED_AVG_PERIOD4, p_WEIGHTED_AVG_PERIOD4),
              WEIGHTED_AVG_PERIOD5 = decode( p_WEIGHTED_AVG_PERIOD5, FND_API.G_MISS_NUM, WEIGHTED_AVG_PERIOD5, p_WEIGHTED_AVG_PERIOD5),
              WEIGHTED_AVG_PERIOD6 = decode( p_WEIGHTED_AVG_PERIOD6, FND_API.G_MISS_NUM, WEIGHTED_AVG_PERIOD6, p_WEIGHTED_AVG_PERIOD6),
              WEIGHTED_AVG_PERIOD7 = decode( p_WEIGHTED_AVG_PERIOD7, FND_API.G_MISS_NUM, WEIGHTED_AVG_PERIOD7, p_WEIGHTED_AVG_PERIOD7),
              WEIGHTED_AVG_PERIOD8 = decode( p_WEIGHTED_AVG_PERIOD8, FND_API.G_MISS_NUM, WEIGHTED_AVG_PERIOD8, p_WEIGHTED_AVG_PERIOD8),
              WEIGHTED_AVG_PERIOD9 = decode( p_WEIGHTED_AVG_PERIOD9, FND_API.G_MISS_NUM, WEIGHTED_AVG_PERIOD9, p_WEIGHTED_AVG_PERIOD9),
              WEIGHTED_AVG_PERIOD10 = decode( p_WEIGHTED_AVG_PERIOD10, FND_API.G_MISS_NUM, WEIGHTED_AVG_PERIOD10, p_WEIGHTED_AVG_PERIOD10),
              WEIGHTED_AVG_PERIOD11 = decode( p_WEIGHTED_AVG_PERIOD11, FND_API.G_MISS_NUM, WEIGHTED_AVG_PERIOD11, p_WEIGHTED_AVG_PERIOD11),
              WEIGHTED_AVG_PERIOD12 = decode( p_WEIGHTED_AVG_PERIOD12, FND_API.G_MISS_NUM, WEIGHTED_AVG_PERIOD12, p_WEIGHTED_AVG_PERIOD12),
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
    where FORECAST_RULE_ID = p_FORECAST_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CSP_FORECAST_RULES_TL set
    DESCRIPTION = p_DESCRIPTION,
    LAST_UPDATE_DATE = p_last_update_DATE,
    LAST_UPDATED_BY = p_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where FORECAST_RULE_ID = p_FORECAST_RULE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;


END Update_Row;

PROCEDURE Delete_Row(
    p_FORECAST_RULE_ID  NUMBER)
 IS
 BEGIN
  delete from CSP_FORECAST_RULES_TL
  where FORECAST_RULE_ID = p_FORECAST_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

   DELETE FROM CSP_FORECAST_RULES_B
    WHERE FORECAST_RULE_ID = p_FORECAST_RULE_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_FORECAST_RULE_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_FORECAST_RULE_NAME    VARCHAR2,
          p_PERIOD_TYPE    VARCHAR2,
		p_PERIOD_SIZE    NUMBER,
          p_FORECAST_PERIODS    NUMBER,
          p_FORECAST_METHOD    VARCHAR2,
          p_HISTORY_PERIODS    NUMBER,
          p_ALPHA    NUMBER,
          p_BETA    NUMBER,
          p_TRACKING_SIGNAL_CYCLE   NUMBER,
          p_WEIGHTED_AVG_PERIOD1    NUMBER,
          p_WEIGHTED_AVG_PERIOD2    NUMBER,
          p_WEIGHTED_AVG_PERIOD3    NUMBER,
          p_WEIGHTED_AVG_PERIOD4    NUMBER,
          p_WEIGHTED_AVG_PERIOD5    NUMBER,
          p_WEIGHTED_AVG_PERIOD6    NUMBER,
          p_WEIGHTED_AVG_PERIOD7    NUMBER,
          p_WEIGHTED_AVG_PERIOD8    NUMBER,
          p_WEIGHTED_AVG_PERIOD9    NUMBER,
          p_WEIGHTED_AVG_PERIOD10    NUMBER,
          p_WEIGHTED_AVG_PERIOD11    NUMBER,
          p_WEIGHTED_AVG_PERIOD12    NUMBER,
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
         FROM CSP_FORECAST_RULES_B
        WHERE FORECAST_RULE_ID =  p_FORECAST_RULE_ID
        FOR UPDATE of FORECAST_RULE_ID NOWAIT;

 cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from CSP_FORECAST_RULES_TL
    where FORECAST_RULE_ID = p_FORECAST_RULE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of FORECAST_RULE_ID nowait;

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
           (      Recinfo.FORECAST_RULE_ID = p_FORECAST_RULE_ID)
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
       AND (    ( Recinfo.FORECAST_RULE_NAME = p_FORECAST_RULE_NAME)
            OR (    ( Recinfo.FORECAST_RULE_NAME IS NULL )
                AND (  p_FORECAST_RULE_NAME IS NULL )))
       AND (    ( Recinfo.PERIOD_TYPE = p_PERIOD_TYPE)
            OR (    ( Recinfo.PERIOD_TYPE IS NULL )
                AND (  p_PERIOD_TYPE IS NULL )))
       AND (    ( Recinfo.PERIOD_SIZE = p_PERIOD_SIZE)
            OR (    ( Recinfo.PERIOD_SIZE IS NULL )
                AND (  p_PERIOD_SIZE IS NULL )))
       AND (    ( Recinfo.FORECAST_PERIODS = p_FORECAST_PERIODS)
            OR (    ( Recinfo.FORECAST_PERIODS IS NULL )
                AND (  p_FORECAST_PERIODS IS NULL )))
       AND (    ( Recinfo.FORECAST_METHOD = p_FORECAST_METHOD)
            OR (    ( Recinfo.FORECAST_METHOD IS NULL )
                AND (  p_FORECAST_METHOD IS NULL )))
       AND (    ( Recinfo.HISTORY_PERIODS = p_HISTORY_PERIODS)
            OR (    ( Recinfo.HISTORY_PERIODS IS NULL )
                AND (  p_HISTORY_PERIODS IS NULL )))
       AND (    ( Recinfo.ALPHA = p_ALPHA)
            OR (    ( Recinfo.ALPHA IS NULL )
                AND (  p_ALPHA IS NULL )))
       AND (    ( Recinfo.BETA = p_BETA)
            OR (    ( Recinfo.BETA IS NULL )
                AND (  p_BETA IS NULL )))
       AND (    ( Recinfo.TRACKING_SIGNAL_CYCLE = p_TRACKING_SIGNAL_CYCLE)
            OR (    ( Recinfo.TRACKING_SIGNAL_CYCLE IS NULL )
                AND (  p_TRACKING_SIGNAL_CYCLE IS NULL )))
       AND (    ( Recinfo.WEIGHTED_AVG_PERIOD1 = p_WEIGHTED_AVG_PERIOD1)
            OR (    ( Recinfo.WEIGHTED_AVG_PERIOD1 IS NULL )
                AND (  p_WEIGHTED_AVG_PERIOD1 IS NULL )))
       AND (    ( Recinfo.WEIGHTED_AVG_PERIOD2 = p_WEIGHTED_AVG_PERIOD2)
            OR (    ( Recinfo.WEIGHTED_AVG_PERIOD2 IS NULL )
                AND (  p_WEIGHTED_AVG_PERIOD2 IS NULL )))
       AND (    ( Recinfo.WEIGHTED_AVG_PERIOD3 = p_WEIGHTED_AVG_PERIOD3)
            OR (    ( Recinfo.WEIGHTED_AVG_PERIOD3 IS NULL )
                AND (  p_WEIGHTED_AVG_PERIOD3 IS NULL )))
       AND (    ( Recinfo.WEIGHTED_AVG_PERIOD4 = p_WEIGHTED_AVG_PERIOD4)
            OR (    ( Recinfo.WEIGHTED_AVG_PERIOD4 IS NULL )
                AND (  p_WEIGHTED_AVG_PERIOD4 IS NULL )))
       AND (    ( Recinfo.WEIGHTED_AVG_PERIOD5 = p_WEIGHTED_AVG_PERIOD5)
            OR (    ( Recinfo.WEIGHTED_AVG_PERIOD5 IS NULL )
                AND (  p_WEIGHTED_AVG_PERIOD5 IS NULL )))
       AND (    ( Recinfo.WEIGHTED_AVG_PERIOD6 = p_WEIGHTED_AVG_PERIOD6)
            OR (    ( Recinfo.WEIGHTED_AVG_PERIOD6 IS NULL )
                AND (  p_WEIGHTED_AVG_PERIOD6 IS NULL )))
       AND (    ( Recinfo.WEIGHTED_AVG_PERIOD7 = p_WEIGHTED_AVG_PERIOD7)
            OR (    ( Recinfo.WEIGHTED_AVG_PERIOD7 IS NULL )
                AND (  p_WEIGHTED_AVG_PERIOD7 IS NULL )))
       AND (    ( Recinfo.WEIGHTED_AVG_PERIOD8 = p_WEIGHTED_AVG_PERIOD8)
            OR (    ( Recinfo.WEIGHTED_AVG_PERIOD8 IS NULL )
                AND (  p_WEIGHTED_AVG_PERIOD8 IS NULL )))
       AND (    ( Recinfo.WEIGHTED_AVG_PERIOD9 = p_WEIGHTED_AVG_PERIOD9)
            OR (    ( Recinfo.WEIGHTED_AVG_PERIOD9 IS NULL )
                AND (  p_WEIGHTED_AVG_PERIOD9 IS NULL )))
       AND (    ( Recinfo.WEIGHTED_AVG_PERIOD10 = p_WEIGHTED_AVG_PERIOD10)
            OR (    ( Recinfo.WEIGHTED_AVG_PERIOD10 IS NULL )
                AND (  p_WEIGHTED_AVG_PERIOD10 IS NULL )))
       AND (    ( Recinfo.WEIGHTED_AVG_PERIOD11 = p_WEIGHTED_AVG_PERIOD11)
            OR (    ( Recinfo.WEIGHTED_AVG_PERIOD11 IS NULL )
                AND (  p_WEIGHTED_AVG_PERIOD11 IS NULL )))
       AND (    ( Recinfo.WEIGHTED_AVG_PERIOD12 = p_WEIGHTED_AVG_PERIOD12)
            OR (    ( Recinfo.WEIGHTED_AVG_PERIOD12 IS NULL )
                AND (  p_WEIGHTED_AVG_PERIOD12 IS NULL )))
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
  delete from CSP_FORECAST_RULES_TL T
  where not exists
    (select NULL
    from CSP_FORECAST_RULES_B B
    where B.FORECAST_RULE_ID = T.FORECAST_RULE_ID
    );

  update CSP_FORECAST_RULES_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from CSP_FORECAST_RULES_TL B
    where B.FORECAST_RULE_ID = T.FORECAST_RULE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FORECAST_RULE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.FORECAST_RULE_ID,
      SUBT.LANGUAGE
    from CSP_FORECAST_RULES_TL SUBB, CSP_FORECAST_RULES_TL SUBT
    where SUBB.FORECAST_RULE_ID = SUBT.FORECAST_RULE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into CSP_FORECAST_RULES_TL (
    FORECAST_RULE_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.FORECAST_RULE_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from CSP_FORECAST_RULES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CSP_FORECAST_RULES_TL T
    where T.FORECAST_RULE_ID = B.FORECAST_RULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE Translate_Row
( p_forecast_rule_id     IN  NUMBER
, p_description          IN  VARCHAR2
, p_owner                IN  VARCHAR2
)
IS
l_user_id    NUMBER := 0;
BEGIN

  if p_owner = 'SEED' then
    l_user_id := 1;
  end if;

  UPDATE csp_forecast_rules_tl
    SET description = p_description
      , last_update_date  = SYSDATE
      , last_updated_by   = l_user_id
      , last_update_login = 0
      , source_lang       = userenv('LANG')
    WHERE forecast_rule_id = p_forecast_rule_id
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
( p_forecast_rule_id    IN  NUMBER
, p_description         IN  VARCHAR2
, p_owner               IN VARCHAR2
)
IS

l_forecast_rule_id      NUMBER;
l_user_id               NUMBER := 0;

BEGIN

  -- assign user ID
  if p_owner = 'SEED' then
    l_user_id := 1; --SEED
  end if;

  BEGIN
    -- update row if present
    Update_Row(
          p_forecast_rule_id         	=>      p_forecast_rule_id,
          p_CREATED_BY                  =>      FND_API.G_MISS_NUM,
          p_CREATION_DATE               =>      FND_API.G_MISS_DATE,
          p_LAST_UPDATED_BY             =>      l_user_id,
          p_LAST_UPDATE_DATE            =>      SYSDATE,
          p_LAST_UPDATE_LOGIN           =>      0,
          p_forecast_rule_name       	=>      FND_API.G_MISS_CHAR,
          p_period_type        		=>      FND_API.G_MISS_CHAR,
          p_period_size        		=>      FND_API.G_MISS_NUM,
          p_forecast_periods      	   	=>      FND_API.G_MISS_NUM,
          p_forecast_method       		=>      FND_API.G_MISS_CHAR,
          p_history_periods         		=>      FND_API.G_MISS_NUM,
          p_alpha     				=>      FND_API.G_MISS_NUM,
          p_beta        			=>      FND_API.G_MISS_NUM,
          p_tracking_signal_cycle  		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period1  		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period2  		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period3  		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period4  		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period5  		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period6  		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period7  		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period8  		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period9  		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period10 		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period11 		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period12 		=>      FND_API.G_MISS_NUM,
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
          px_forecast_rule_id        	=>      l_forecast_rule_id,
          p_CREATED_BY                  =>      FND_API.G_MISS_NUM,
          p_CREATION_DATE               =>      FND_API.G_MISS_DATE,
          p_LAST_UPDATED_BY             =>      l_user_id,
          p_LAST_UPDATE_DATE            =>      SYSDATE,
          p_LAST_UPDATE_LOGIN           =>      0,
          p_forecast_rule_name       	=>      FND_API.G_MISS_CHAR,
          p_period_type        		=>      FND_API.G_MISS_CHAR,
          p_period_size        		=>      FND_API.G_MISS_NUM,
          p_forecast_periods      	   	=>      FND_API.G_MISS_NUM,
          p_forecast_method       		=>      FND_API.G_MISS_CHAR,
          p_history_periods         		=>      FND_API.G_MISS_NUM,
          p_alpha     				=>      FND_API.G_MISS_NUM,
          p_beta        			=>      FND_API.G_MISS_NUM,
          p_tracking_signal_cycle        	=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period1  		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period2  		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period3  		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period4  		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period5  		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period6  		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period7  		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period8  		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period9  		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period10 		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period11 		=>      FND_API.G_MISS_NUM,
          p_weighted_avg_period12 		=>      FND_API.G_MISS_NUM,
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

End CSP_FORECAST_RULES_B_PKG;

/
