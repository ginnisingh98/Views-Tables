--------------------------------------------------------
--  DDL for Package Body AMS_VENUE_RATES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_VENUE_RATES_B_PKG" as
/* $Header: amstvrtb.pls 115.5 2003/03/28 23:19:44 soagrawa ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_VENUE_RATES_B_PKG
-- Purpose
--
-- History
--   10-MAY-2002  GMADANA    Added Rate_code.
--   28-mar-2003  soagrawa   Added add_language. Bug# 2876033
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_VENUE_RATES_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstvrtb.pls';


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createInsertBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          px_rate_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_active_flag    VARCHAR2,
          p_venue_id    NUMBER,
          p_metric_id    NUMBER,
          p_transactional_value    NUMBER,
          p_transactional_currency_code    VARCHAR2,
          p_functional_value    NUMBER,
          p_functional_currency_code    VARCHAR2,
          p_uom_code    VARCHAR2,
          p_rate_code   VARCHAR2,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
	  p_description    VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);
   l_rowid VARCHAR2(20);

   cursor C is select ROWID from AMS_venue_rates_b
   where rate_ID = px_rate_id;


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_VENUE_RATES_B(
           rate_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           active_flag,
           venue_id,
           metric_id,
           transactional_value,
           transactional_currency_code,
           functional_value,
           functional_currency_code,
           uom_code,
           rate_code,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15
   ) VALUES (
           DECODE( px_rate_id, FND_API.g_miss_num, NULL, px_rate_id),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           'Y',
           DECODE( p_venue_id, FND_API.g_miss_num, NULL, p_venue_id),
           DECODE( p_metric_id, FND_API.g_miss_num, NULL, p_metric_id),
           DECODE( p_transactional_value, FND_API.g_miss_num, NULL, p_transactional_value),
           DECODE( p_transactional_currency_code, FND_API.g_miss_char, NULL, p_transactional_currency_code),
           DECODE( p_functional_value, FND_API.g_miss_num, NULL, p_functional_value),
           DECODE( p_functional_currency_code, FND_API.g_miss_char, NULL, p_functional_currency_code),
           DECODE( p_uom_code, FND_API.g_miss_char, NULL, p_uom_code),
           DECODE( p_rate_code, FND_API.g_miss_char, NULL, p_rate_code),
           DECODE( p_attribute_category, FND_API.g_miss_char, NULL, p_attribute_category),
           DECODE( p_attribute1, FND_API.g_miss_char, NULL, p_attribute1),
           DECODE( p_attribute2, FND_API.g_miss_char, NULL, p_attribute2),
           DECODE( p_attribute3, FND_API.g_miss_char, NULL, p_attribute3),
           DECODE( p_attribute4, FND_API.g_miss_char, NULL, p_attribute4),
           DECODE( p_attribute5, FND_API.g_miss_char, NULL, p_attribute5),
           DECODE( p_attribute6, FND_API.g_miss_char, NULL, p_attribute6),
           DECODE( p_attribute7, FND_API.g_miss_char, NULL, p_attribute7),
           DECODE( p_attribute8, FND_API.g_miss_char, NULL, p_attribute8),
           DECODE( p_attribute9, FND_API.g_miss_char, NULL, p_attribute9),
           DECODE( p_attribute10, FND_API.g_miss_char, NULL, p_attribute10),
           DECODE( p_attribute11, FND_API.g_miss_char, NULL, p_attribute11),
           DECODE( p_attribute12, FND_API.g_miss_char, NULL, p_attribute12),
           DECODE( p_attribute13, FND_API.g_miss_char, NULL, p_attribute13),
           DECODE( p_attribute14, FND_API.g_miss_char, NULL, p_attribute14),
           DECODE( p_attribute15, FND_API.g_miss_char, NULL, p_attribute15));


 INSERT INTO ams_venue_rates_tl(
           rate_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           language,
           source_lang,
           description
   )  select
    px_rate_id,
    p_last_update_date,
    p_last_updated_by,
    p_creation_date,
    p_created_by,
    p_last_update_login,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    p_description
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ams_venue_rates_tl T
    where T.rate_ID = px_rate_id
    and T.LANGUAGE = L.LANGUAGE_CODE);

 open c;
  fetch c into l_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

END Insert_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createUpdateBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_rate_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_active_flag    VARCHAR2,
          p_venue_id    NUMBER,
          p_metric_id    NUMBER,
          p_transactional_value    NUMBER,
          p_transactional_currency_code    VARCHAR2,
          p_functional_value    NUMBER,
          p_functional_currency_code    VARCHAR2,
          p_uom_code    VARCHAR2,
          p_rate_code   VARCHAR2,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2,
	  p_description    VARCHAR2)

 IS
 BEGIN

    Update AMS_VENUE_RATES_B
    SET
              rate_id = DECODE( p_rate_id, FND_API.g_miss_num, rate_id, p_rate_id),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              active_flag = DECODE( p_active_flag, FND_API.g_miss_char, active_flag, p_active_flag),
              venue_id = DECODE( p_venue_id, FND_API.g_miss_num, venue_id, p_venue_id),
              metric_id = DECODE( p_metric_id, FND_API.g_miss_num, metric_id, p_metric_id),
              transactional_value = DECODE( p_transactional_value, FND_API.g_miss_num, transactional_value, p_transactional_value),
              transactional_currency_code = DECODE( p_transactional_currency_code, FND_API.g_miss_char, transactional_currency_code, p_transactional_currency_code),
              functional_value = DECODE( p_functional_value, FND_API.g_miss_num, functional_value, p_functional_value),
              functional_currency_code = DECODE( p_functional_currency_code, FND_API.g_miss_char, functional_currency_code, p_functional_currency_code),
              uom_code = DECODE( p_uom_code, FND_API.g_miss_char, uom_code, p_uom_code),
              rate_code = DECODE( p_rate_code, FND_API.g_miss_char, rate_code, p_rate_code),
              attribute_category = DECODE( p_attribute_category, FND_API.g_miss_char, attribute_category, p_attribute_category),
              attribute1 = DECODE( p_attribute1, FND_API.g_miss_char, attribute1, p_attribute1),
              attribute2 = DECODE( p_attribute2, FND_API.g_miss_char, attribute2, p_attribute2),
              attribute3 = DECODE( p_attribute3, FND_API.g_miss_char, attribute3, p_attribute3),
              attribute4 = DECODE( p_attribute4, FND_API.g_miss_char, attribute4, p_attribute4),
              attribute5 = DECODE( p_attribute5, FND_API.g_miss_char, attribute5, p_attribute5),
              attribute6 = DECODE( p_attribute6, FND_API.g_miss_char, attribute6, p_attribute6),
              attribute7 = DECODE( p_attribute7, FND_API.g_miss_char, attribute7, p_attribute7),
              attribute8 = DECODE( p_attribute8, FND_API.g_miss_char, attribute8, p_attribute8),
              attribute9 = DECODE( p_attribute9, FND_API.g_miss_char, attribute9, p_attribute9),
              attribute10 = DECODE( p_attribute10, FND_API.g_miss_char, attribute10, p_attribute10),
              attribute11 = DECODE( p_attribute11, FND_API.g_miss_char, attribute11, p_attribute11),
              attribute12 = DECODE( p_attribute12, FND_API.g_miss_char, attribute12, p_attribute12),
              attribute13 = DECODE( p_attribute13, FND_API.g_miss_char, attribute13, p_attribute13),
              attribute14 = DECODE( p_attribute14, FND_API.g_miss_char, attribute14, p_attribute14),
              attribute15 = DECODE( p_attribute15, FND_API.g_miss_char, attribute15, p_attribute15)
   WHERE RATE_ID = p_RATE_ID
   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
	RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   update AMS_VENUE_RATES_TL
   set
           last_update_date=DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
           last_updated_by=DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
           creation_date=DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
           created_by=DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
           last_update_login=DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
           source_lang=userenv('LANG'),
           description=DECODE( p_description, FND_API.g_miss_char, description, p_description)
   where rate_ID = p_rate_ID
   and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

   IF (SQL%NOTFOUND) THEN
	RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
END Update_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createDeleteBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_RATE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_VENUE_RATES_B
    WHERE RATE_ID = p_RATE_ID;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;



----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createLockBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
          p_rate_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_active_flag    VARCHAR2,
          p_venue_id    NUMBER,
          p_metric_id    NUMBER,
          p_transactional_value    NUMBER,
          p_transactional_currency_code    VARCHAR2,
          p_functional_value    NUMBER,
          p_functional_currency_code    VARCHAR2,
          p_uom_code    VARCHAR2,
          p_rate_code   VARCHAR2,
          p_attribute_category    VARCHAR2,
          p_attribute1    VARCHAR2,
          p_attribute2    VARCHAR2,
          p_attribute3    VARCHAR2,
          p_attribute4    VARCHAR2,
          p_attribute5    VARCHAR2,
          p_attribute6    VARCHAR2,
          p_attribute7    VARCHAR2,
          p_attribute8    VARCHAR2,
          p_attribute9    VARCHAR2,
          p_attribute10    VARCHAR2,
          p_attribute11    VARCHAR2,
          p_attribute12    VARCHAR2,
          p_attribute13    VARCHAR2,
          p_attribute14    VARCHAR2,
          p_attribute15    VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_VENUE_RATES_B
        WHERE RATE_ID =  p_RATE_ID
        FOR UPDATE of RATE_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    If (c%NOTFOUND) then
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
    IF (
           (      Recinfo.rate_id = p_rate_id)
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.active_flag = p_active_flag)
            OR (    ( Recinfo.active_flag IS NULL )
                AND (  p_active_flag IS NULL )))
       AND (    ( Recinfo.venue_id = p_venue_id)
            OR (    ( Recinfo.venue_id IS NULL )
                AND (  p_venue_id IS NULL )))
       AND (    ( Recinfo.metric_id = p_metric_id)
            OR (    ( Recinfo.metric_id IS NULL )
                AND (  p_metric_id IS NULL )))
       AND (    ( Recinfo.transactional_value = p_transactional_value)
            OR (    ( Recinfo.transactional_value IS NULL )
                AND (  p_transactional_value IS NULL )))
       AND (    ( Recinfo.transactional_currency_code = p_transactional_currency_code)
            OR (    ( Recinfo.transactional_currency_code IS NULL )
                AND (  p_transactional_currency_code IS NULL )))
       AND (    ( Recinfo.functional_value = p_functional_value)
            OR (    ( Recinfo.functional_value IS NULL )
                AND (  p_functional_value IS NULL )))
       AND (    ( Recinfo.functional_currency_code = p_functional_currency_code)
            OR (    ( Recinfo.functional_currency_code IS NULL )
                AND (  p_functional_currency_code IS NULL )))
       AND (    ( Recinfo.uom_code = p_uom_code)
            OR (    ( Recinfo.uom_code IS NULL )
                AND (  p_uom_code IS NULL )))
      AND (    ( Recinfo.rate_code = p_rate_code)
            OR (    ( Recinfo.rate_code IS NULL )
                AND (  p_rate_code IS NULL )))
       AND (    ( Recinfo.attribute_category = p_attribute_category)
            OR (    ( Recinfo.attribute_category IS NULL )
                AND (  p_attribute_category IS NULL )))
       AND (    ( Recinfo.attribute1 = p_attribute1)
            OR (    ( Recinfo.attribute1 IS NULL )
                AND (  p_attribute1 IS NULL )))
       AND (    ( Recinfo.attribute2 = p_attribute2)
            OR (    ( Recinfo.attribute2 IS NULL )
                AND (  p_attribute2 IS NULL )))
       AND (    ( Recinfo.attribute3 = p_attribute3)
            OR (    ( Recinfo.attribute3 IS NULL )
                AND (  p_attribute3 IS NULL )))
       AND (    ( Recinfo.attribute4 = p_attribute4)
            OR (    ( Recinfo.attribute4 IS NULL )
                AND (  p_attribute4 IS NULL )))
       AND (    ( Recinfo.attribute5 = p_attribute5)
            OR (    ( Recinfo.attribute5 IS NULL )
                AND (  p_attribute5 IS NULL )))
       AND (    ( Recinfo.attribute6 = p_attribute6)
            OR (    ( Recinfo.attribute6 IS NULL )
                AND (  p_attribute6 IS NULL )))
       AND (    ( Recinfo.attribute7 = p_attribute7)
            OR (    ( Recinfo.attribute7 IS NULL )
                AND (  p_attribute7 IS NULL )))
       AND (    ( Recinfo.attribute8 = p_attribute8)
            OR (    ( Recinfo.attribute8 IS NULL )
                AND (  p_attribute8 IS NULL )))
       AND (    ( Recinfo.attribute9 = p_attribute9)
            OR (    ( Recinfo.attribute9 IS NULL )
                AND (  p_attribute9 IS NULL )))
       AND (    ( Recinfo.attribute10 = p_attribute10)
            OR (    ( Recinfo.attribute10 IS NULL )
                AND (  p_attribute10 IS NULL )))
       AND (    ( Recinfo.attribute11 = p_attribute11)
            OR (    ( Recinfo.attribute11 IS NULL )
                AND (  p_attribute11 IS NULL )))
       AND (    ( Recinfo.attribute12 = p_attribute12)
            OR (    ( Recinfo.attribute12 IS NULL )
                AND (  p_attribute12 IS NULL )))
       AND (    ( Recinfo.attribute13 = p_attribute13)
            OR (    ( Recinfo.attribute13 IS NULL )
                AND (  p_attribute13 IS NULL )))
       AND (    ( Recinfo.attribute14 = p_attribute14)
            OR (    ( Recinfo.attribute14 IS NULL )
                AND (  p_attribute14 IS NULL )))
       AND (    ( Recinfo.attribute15 = p_attribute15)
            OR (    ( Recinfo.attribute15 IS NULL )
                AND (  p_attribute15 IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_VENUE_RATES_TL T
  where not exists
    (select NULL
    from AMS_VENUE_RATES_B B
    where B.RATE_ID = T.RATE_ID
    );

  update AMS_VENUE_RATES_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from AMS_VENUE_RATES_TL B
    where B.RATE_ID = T.RATE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RATE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RATE_ID,
      SUBT.LANGUAGE
    from AMS_VENUE_RATES_TL SUBB, AMS_VENUE_RATES_TL SUBT
    where SUBB.RATE_ID = SUBT.RATE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
     or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
     or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_VENUE_RATES_TL (
     RATE_ID,
     LANGUAGE,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     SOURCE_LANG,
     DESCRIPTION,
     SECURITY_GROUP_ID
  ) select
     B.RATE_ID,
     L.LANGUAGE_CODE,
     B.CREATION_DATE,
     B.CREATED_BY,
     B.LAST_UPDATE_DATE,
     B.LAST_UPDATED_BY,
     B.LAST_UPDATE_LOGIN,
     B.SOURCE_LANG,
     B.DESCRIPTION,
     B.SECURITY_GROUP_ID
  from AMS_VENUE_RATES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_VENUE_RATES_TL T
    where T.RATE_ID = B.RATE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


END AMS_VENUE_RATES_B_PKG;

/
