--------------------------------------------------------
--  DDL for Package Body AMS_COMPETITOR_PRODUCTS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_COMPETITOR_PRODUCTS_B_PKG" as
/* $Header: amstcprb.pls 120.3 2005/11/14 02:07:27 inanaiah ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_COMPETITOR_PRODUCTS_B_PKG
-- Purpose
--
-- History
--
--   01-Oct-2001   musman   created
--   05-Nov-2001   musman    Commented out the reference to security_group_id
--   10-Sep-2003   Musman     Added Changes reqd for interest type to category
--   04-Aug-2005   inanaiah  R12 change - added a DFF
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_COMPETITOR_PRODUCTS_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstcprb.pls';


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
          px_competitor_product_id   IN OUT NOCOPY NUMBER,
          px_object_version_number  IN OUT NOCOPY  NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_competitor_party_id    NUMBER,
          p_competitor_product_code    VARCHAR2,
          p_interest_type_id    NUMBER,
          p_inventory_item_id    NUMBER,
          p_organization_id    NUMBER,
          p_comp_product_url    VARCHAR2,
          p_original_system_ref    VARCHAR2,
          --p_security_group_id    NUMBER,
          p_competitor_product_name  VARCHAR2,
          p_description         VARCHAR2,
          p_start_date          DATE,
          p_end_date            DATE,
          p_category_id         NUMBER,
          p_category_set_id     NUMBER,
       p_context                         VARCHAR2,
       p_attribute1                      VARCHAR2,
       p_attribute2                      VARCHAR2,
       p_attribute3                      VARCHAR2,
       p_attribute4                      VARCHAR2,
       p_attribute5                      VARCHAR2,
       p_attribute6                      VARCHAR2,
       p_attribute7                      VARCHAR2,
       p_attribute8                      VARCHAR2,
       p_attribute9                      VARCHAR2,
       p_attribute10                      VARCHAR2,
       p_attribute11                      VARCHAR2,
       p_attribute12                      VARCHAR2,
       p_attribute13                      VARCHAR2,
       p_attribute14                      VARCHAR2,
       p_attribute15                      VARCHAR2
        )
 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_COMPETITOR_PRODUCTS_B(
           competitor_product_id,
           object_version_number,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           competitor_party_id,
           competitor_product_code,
           interest_type_id,
           inventory_item_id,
           organization_id,
           comp_product_url,
           original_system_ref
           --,security_group_id
           ,start_date
           ,end_date
           ,category_id
           ,category_set_id
           , context
           , attribute1
           , attribute2
           , attribute3
           , attribute4
           , attribute5
           , attribute6
           , attribute7
           , attribute8
           , attribute9
           , attribute10
           , attribute11
           , attribute12
           , attribute13
           , attribute14
           , attribute15


   ) VALUES (
           DECODE( px_competitor_product_id, FND_API.g_miss_num, NULL, px_competitor_product_id),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( p_competitor_party_id, FND_API.g_miss_num, NULL, p_competitor_party_id),
           DECODE( p_competitor_product_code, FND_API.g_miss_char, NULL, p_competitor_product_code),
           DECODE( p_interest_type_id, FND_API.g_miss_num, NULL, p_interest_type_id),
           DECODE( p_inventory_item_id, FND_API.g_miss_num, NULL, p_inventory_item_id),
           DECODE( p_organization_id, FND_API.g_miss_num, NULL, p_organization_id),
           DECODE( p_comp_product_url, FND_API.g_miss_char, NULL, p_comp_product_url),
           DECODE( p_original_system_ref, FND_API.g_miss_char, NULL, p_original_system_ref)
           --,DECODE( p_security_group_id, FND_API.g_miss_num, NULL, p_security_group_id)
          ,DECODE( p_start_date, FND_API.g_miss_date, NULL, p_start_date)
          ,DECODE( p_end_date, FND_API.g_miss_date, NULL, p_end_date)
          ,DECODE( p_category_id, FND_API.g_miss_num, NULL, p_category_id)
          ,DECODE( p_category_set_id, FND_API.g_miss_num, NULL, p_category_set_id)
          , DECODE(p_context , FND_API.G_MISS_CHAR , NULL , p_context)
          , DECODE(p_attribute1 , FND_API.G_MISS_CHAR, NULL , p_attribute1)
          , DECODE(p_attribute2 , FND_API.G_MISS_CHAR, NULL , p_attribute2)
          , DECODE(p_attribute3 , FND_API.G_MISS_CHAR, NULL , p_attribute3)
          , DECODE(p_attribute4 , FND_API.G_MISS_CHAR, NULL , p_attribute4)
          , DECODE(p_attribute5 , FND_API.G_MISS_CHAR, NULL , p_attribute5)
          , DECODE(p_attribute6 , FND_API.G_MISS_CHAR, NULL , p_attribute6)
          , DECODE(p_attribute7 , FND_API.G_MISS_CHAR, NULL , p_attribute7)
          , DECODE(p_attribute8 , FND_API.G_MISS_CHAR, NULL , p_attribute8)
          , DECODE(p_attribute9 , FND_API.G_MISS_CHAR, NULL , p_attribute9)
          , DECODE(p_attribute10 , FND_API.G_MISS_CHAR, NULL , p_attribute10)
          , DECODE(p_attribute11 , FND_API.G_MISS_CHAR, NULL , p_attribute11)
          , DECODE(p_attribute12 , FND_API.G_MISS_CHAR, NULL , p_attribute12)
          , DECODE(p_attribute13 , FND_API.G_MISS_CHAR, NULL , p_attribute13)
          , DECODE(p_attribute14 , FND_API.G_MISS_CHAR, NULL , p_attribute14)
          , DECODE(p_attribute15 , FND_API.G_MISS_CHAR, NULL , p_attribute15)
           );

   INSERT INTO AMS_COMPETITOR_PRODUCTS_TL(
           competitor_product_id,
           language,
           source_lang,
           last_update_date,
           last_updated_by,
           last_update_login,
           creation_date,
           created_by,
           competitor_product_name,
           description
           --,security_group_id
           )
   SELECT
           DECODE( px_competitor_product_id, FND_API.g_miss_num, NULL, px_competitor_product_id),
           l.language_code,
           USERENV('LANG'),
           sysdate,
           FND_GLOBAL.user_id,
           FND_GLOBAL.conc_login_id,
           sysdate,
           FND_GLOBAL.user_id,
           DECODE( p_competitor_product_name, FND_API.g_miss_char, NULL, p_competitor_product_name),
           DECODE( p_description, FND_API.g_miss_char, NULL, p_description)
           --,DECODE( p_security_group_id, FND_API.g_miss_num, NULL, p_security_group_id)
   FROM    fnd_languages l
   WHERE   l.installed_flag IN ('I','B')
   AND     NOT EXISTS(
                      SELECT NULL
                      FROM   ams_competitor_products_tl t
                      WHERE  t.competitor_product_id = DECODE( px_competitor_product_id, FND_API.g_miss_num, NULL, px_competitor_product_id)
                      AND    t.language = l.language_code ) ;


END Insert_Row;


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
          p_competitor_product_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_competitor_party_id    NUMBER,
          p_competitor_product_code    VARCHAR2,
          p_interest_type_id    NUMBER,
          p_inventory_item_id    NUMBER,
          p_organization_id    NUMBER,
          p_comp_product_url    VARCHAR2,
          p_original_system_ref    VARCHAR2,
          --p_security_group_id    NUMBER,
          p_competitor_product_name  VARCHAR2,
          p_description         VARCHAR2,
          p_start_date          DATE,
          p_end_date            DATE,
          p_category_id         NUMBER,
          p_category_set_id     NUMBER,
       p_context                         VARCHAR2,
       p_attribute1                      VARCHAR2,
       p_attribute2                      VARCHAR2,
       p_attribute3                      VARCHAR2,
       p_attribute4                      VARCHAR2,
       p_attribute5                      VARCHAR2,
       p_attribute6                      VARCHAR2,
       p_attribute7                      VARCHAR2,
       p_attribute8                      VARCHAR2,
       p_attribute9                      VARCHAR2,
       p_attribute10                      VARCHAR2,
       p_attribute11                      VARCHAR2,
       p_attribute12                      VARCHAR2,
       p_attribute13                      VARCHAR2,
       p_attribute14                      VARCHAR2,
       p_attribute15                      VARCHAR2
        )
        IS
 BEGIN

    AMS_UTILITY_PVT.debug_message('Pub update: start');

    Update AMS_COMPETITOR_PRODUCTS_B
    SET
              competitor_product_id = DECODE( p_competitor_product_id, FND_API.g_miss_num, null, null, competitor_product_id, p_competitor_product_id),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, null, null, object_version_number, p_object_version_number),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, to_date(null), to_date(null), last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, null, null, last_updated_by, p_last_updated_by),
              creation_date = DECODE( p_creation_date, FND_API.g_miss_date, to_date(null) , to_date(null), creation_date, p_creation_date),
              created_by = DECODE( p_created_by, FND_API.g_miss_num, null, null, created_by, p_created_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num,null, null, last_update_login, p_last_update_login),
              competitor_party_id = DECODE( p_competitor_party_id, FND_API.g_miss_num, null, null, competitor_party_id, p_competitor_party_id),
              competitor_product_code = DECODE( p_competitor_product_code, FND_API.g_miss_char, null, null, competitor_product_code, p_competitor_product_code),
              interest_type_id = DECODE( p_interest_type_id, FND_API.g_miss_num, null, null, interest_type_id, p_interest_type_id),
              inventory_item_id = DECODE( p_inventory_item_id, FND_API.g_miss_num, null, p_inventory_item_id),
              organization_id = DECODE( p_organization_id, FND_API.g_miss_num, null, p_organization_id),
              comp_product_url = DECODE( p_comp_product_url, FND_API.g_miss_char, null , null, comp_product_url, p_comp_product_url),
              original_system_ref = DECODE( p_original_system_ref, FND_API.g_miss_char, null , null , original_system_ref, p_original_system_ref)
              --,security_group_id = DECODE( p_security_group_id, FND_API.g_miss_num, null , null , security_group_id, p_security_group_id)
             ,start_date = DECODE( p_start_date, FND_API.g_miss_date, to_date(null), to_date(null), start_date, p_start_date)
             ,end_date = DECODE( p_end_date, FND_API.g_miss_date, to_date(null), to_date(null), end_date, p_end_date)
             ,category_id = DECODE( p_category_id, FND_API.g_miss_num, null, p_category_id)
             ,category_set_id = DECODE( p_category_set_id, FND_API.g_miss_num, null, p_category_Set_id)
             , context        = DECODE(p_context, FND_API.G_MISS_CHAR, null, null , context, p_context )
             , attribute1      = DECODE(p_attribute1, FND_API.G_MISS_CHAR, null, null , attribute1 , p_attribute1)
             , attribute2      = DECODE(p_attribute2, FND_API.G_MISS_CHAR, null, null , attribute2 , p_attribute2)
             , attribute3      = DECODE(p_attribute3, FND_API.G_MISS_CHAR, null, null , attribute3 , p_attribute3)
             , attribute4      = DECODE(p_attribute4, FND_API.G_MISS_CHAR, null, null , attribute4 , p_attribute4)
             , attribute5      = DECODE(p_attribute5, FND_API.G_MISS_CHAR, null, null , attribute5 , p_attribute5)
             , attribute6      = DECODE(p_attribute6, FND_API.G_MISS_CHAR, null, null , attribute6 , p_attribute6)
             , attribute7      = DECODE(p_attribute7, FND_API.G_MISS_CHAR, null, null , attribute7 , p_attribute7)
             , attribute8      = DECODE(p_attribute8, FND_API.G_MISS_CHAR, null, null , attribute8 , p_attribute8)
             , attribute9      = DECODE(p_attribute9, FND_API.G_MISS_CHAR, null, null , attribute9 , p_attribute9)
             , attribute10      = DECODE(p_attribute10, FND_API.G_MISS_CHAR, null, null , attribute10 , p_attribute10)
             , attribute11      = DECODE(p_attribute11, FND_API.G_MISS_CHAR, null, null , attribute12 , p_attribute11)
             , attribute12      = DECODE(p_attribute12, FND_API.G_MISS_CHAR, null, null , attribute12 , p_attribute12)
             , attribute13      = DECODE(p_attribute13, FND_API.G_MISS_CHAR, null, null , attribute13 , p_attribute13)
             , attribute14      = DECODE(p_attribute14, FND_API.G_MISS_CHAR, null, null , attribute14 , p_attribute14)
             , attribute15      = DECODE(p_attribute15, FND_API.G_MISS_CHAR, null, null , attribute15 , p_attribute15)
   WHERE COMPETITOR_PRODUCT_ID = p_COMPETITOR_PRODUCT_ID
   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   UPDATE  AMS_COMPETITOR_PRODUCTS_TL
   SET
        competitor_product_name = DECODE( p_competitor_product_name, FND_API.g_miss_char, competitor_product_name, p_competitor_product_name),
        description   = DECODE(p_description,FND_API.g_miss_char,description,p_description),
        last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
        last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
        last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
        source_lang = USERENV('LANG')
   WHERE competitor_product_id = p_competitor_product_id
   AND    USERENV('LANG') IN (language, source_lang);

   IF (SQL%NOTFOUND) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;



END Update_Row;


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
    p_COMPETITOR_PRODUCT_ID  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_COMPETITOR_PRODUCTS_B
   WHERE COMPETITOR_PRODUCT_ID = p_COMPETITOR_PRODUCT_ID
   AND object_version_number = p_object_version_number;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

   DELETE FROM AMS_COMPETITOR_PRODUCTS_TL
   WHERE COMPETITOR_PRODUCT_ID = p_COMPETITOR_PRODUCT_ID;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;


 END Delete_Row ;


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
          p_competitor_product_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_competitor_party_id    NUMBER,
          p_competitor_product_code    VARCHAR2,
          p_interest_type_id    NUMBER,
          p_inventory_item_id    NUMBER,
          p_organization_id    NUMBER,
          p_comp_product_url    VARCHAR2,
          p_original_system_ref    VARCHAR2,
          --p_security_group_id    NUMBER ,
          p_competitor_product_name  VARCHAR2,
          p_description         VARCHAR2,
          p_start_date          DATE,
          p_end_date            DATE,
          p_category_id         NUMBER,
          p_category_set_id     NUMBER
)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_COMPETITOR_PRODUCTS_VL
        WHERE COMPETITOR_PRODUCT_ID =  p_COMPETITOR_PRODUCT_ID
          and object_version_number = p_object_version_number
        FOR UPDATE of COMPETITOR_PRODUCT_ID NOWAIT;
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
           (      Recinfo.competitor_product_id = p_competitor_product_id)
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
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
       AND (    ( Recinfo.competitor_party_id = p_competitor_party_id)
            OR (    ( Recinfo.competitor_party_id IS NULL )
                AND (  p_competitor_party_id IS NULL )))
       AND (    ( Recinfo.competitor_product_code = p_competitor_product_code)
            OR (    ( Recinfo.competitor_product_code IS NULL )
                AND (  p_competitor_product_code IS NULL )))
       AND (    ( Recinfo.interest_type_id = p_interest_type_id)
            OR (    ( Recinfo.interest_type_id IS NULL )
                AND (  p_interest_type_id IS NULL )))
       AND (    ( Recinfo.inventory_item_id = p_inventory_item_id)
            OR (    ( Recinfo.inventory_item_id IS NULL )
                AND (  p_inventory_item_id IS NULL )))
       AND (    ( Recinfo.organization_id = p_organization_id)
            OR (    ( Recinfo.organization_id IS NULL )
                AND (  p_organization_id IS NULL )))
       AND (    ( Recinfo.comp_product_url = p_comp_product_url)
            OR (    ( Recinfo.comp_product_url IS NULL )
                AND (  p_comp_product_url IS NULL )))
       AND (    ( Recinfo.original_system_ref = p_original_system_ref)
            OR (    ( Recinfo.original_system_ref IS NULL )
                AND (  p_original_system_ref IS NULL )))
       AND (    ( Recinfo.competitor_product_name = p_competitor_product_name)
            OR (    ( Recinfo.competitor_product_name IS NULL )
                AND (  p_competitor_product_name IS NULL )))
       AND (    ( Recinfo.description = p_description)
            OR (    ( Recinfo.description IS NULL )
                AND (  p_description IS NULL )))
       AND (    ( Recinfo.start_date = p_start_date)
            OR (    ( Recinfo.start_date IS NULL )
                AND (  p_start_date IS NULL )))
       AND (    ( Recinfo.end_date = p_end_date)
            OR (    ( Recinfo.end_date IS NULL )
                AND (  p_end_date IS NULL )))
       AND (    ( Recinfo.category_id = p_category_id)
            OR (    ( Recinfo.category_id IS NULL )
                AND (  p_category_id IS NULL )))
       AND (    ( Recinfo.category_set_id = p_category_set_id)
            OR (    ( Recinfo.category_set_id IS NULL )
                AND (  p_category_set_id IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;
-- ===========================================
-- ADD_LANGUAGE
--=============================================
procedure ADD_LANGUAGE
is
begin
  delete from AMS_COMPETITOR_PRODUCTS_TL T
  where not exists
    (select NULL
    from AMS_COMPETITOR_PRODUCTS_B B
    where B.competitor_product_id = T.competitor_product_id
    );

  update AMS_COMPETITOR_PRODUCTS_TL T set (
      competitor_product_id
    ) = (select
      B.competitor_product_id
    from AMS_COMPETITOR_PRODUCTS_TL B
    where B.competitor_product_id = T.competitor_product_id
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.competitor_product_id,
      T.LANGUAGE
  ) in (select
      SUBT.competitor_product_id,
      SUBT.LANGUAGE
    from AMS_COMPETITOR_PRODUCTS_TL SUBB, AMS_COMPETITOR_PRODUCTS_TL SUBT
    where SUBB.competitor_product_id = SUBT.competitor_product_id
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.competitor_product_id <> SUBT.competitor_product_id
  ));

   INSERT INTO AMS_COMPETITOR_PRODUCTS_TL(
           competitor_product_id,
           language,
           source_lang,
           last_update_date,
           last_updated_by,
           last_update_login,
           creation_date,
           created_by,
           competitor_product_name,
           description
           --,security_group_id
           )
   SELECT
            B.competitor_product_id,
           l.language_code,
           B.SOURCE_LANG,
            B.LAST_UPDATE_DATE,
           B.LAST_UPDATED_BY,
           B.LAST_UPDATE_LOGIN,
           B.CREATION_DATE,
           B.CREATED_BY,
           B.competitor_product_name,
           B.DESCRIPTION
  from AMS_COMPETITOR_PRODUCTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_COMPETITOR_PRODUCTS_TL T
    where T.competitor_product_id = B.competitor_product_id
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;


END AMS_COMPETITOR_PRODUCTS_B_PKG;

/
