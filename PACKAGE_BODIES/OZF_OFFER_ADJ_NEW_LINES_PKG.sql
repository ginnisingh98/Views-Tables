--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_ADJ_NEW_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_ADJ_NEW_LINES_PKG" as
/* $Header: ozftanlb.pls 120.0 2006/03/30 13:49:34 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_OFFER_ADJ_NEW_LINES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_OFFER_ADJ_NEW_LINES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftoanb.pls';
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
          px_offer_adj_new_line_id   IN OUT NOCOPY  NUMBER,
          p_offer_adjustment_id    NUMBER,
          p_volume_from    NUMBER,
          p_volume_to    NUMBER,
          p_volume_type    VARCHAR2,
          p_discount    NUMBER,
          p_discount_type    VARCHAR2,
          p_tier_type    VARCHAR2,
          p_td_discount NUMBER,
          p_td_discount_type VARCHAR2,
          p_quantity NUMBER,
          p_benefit_price_list_line_id NUMBER,
          p_parent_adj_line_id NUMBER,
          p_start_date_active DATE,
          p_end_date_active DATE,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY  NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO OZF_OFFER_ADJ_NEW_LINES(
           offer_adj_new_line_id,
           offer_adjustment_id,
           volume_from,
           volume_to,
           volume_type,
           discount,
           discount_type,
           tier_type,
           td_discount,
           td_discount_type,
           quantity ,
           benefit_price_list_line_id,
           parent_adj_line_id,
           start_date_active,
           end_date_active,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login,
           object_version_number
   ) VALUES (
           DECODE( px_offer_adj_new_line_id, FND_API.g_miss_num, NULL, px_offer_adj_new_line_id)
           , DECODE( p_offer_adjustment_id, FND_API.g_miss_num, NULL, p_offer_adjustment_id)
           , DECODE( p_volume_from, FND_API.g_miss_num, NULL, p_volume_from)
           , DECODE( p_volume_to, FND_API.g_miss_num, NULL, p_volume_to)
           , DECODE( p_volume_type, FND_API.g_miss_char, NULL, p_volume_type)
           , DECODE( p_discount, FND_API.g_miss_num, NULL, p_discount)
           , DECODE( p_discount_type, FND_API.g_miss_char, NULL, p_discount_type)
           , DECODE( p_tier_type, FND_API.g_miss_char, NULL, p_tier_type)
           , DECODE( p_td_discount, FND_API.g_miss_num, NULL, p_td_discount)
           , DECODE( p_td_discount_type, FND_API.g_miss_char, NULL, p_td_discount_type)
           , DECODE( p_quantity, FND_API.G_MISS_NUM, null,p_quantity)
           , DECODE( P_benefit_price_list_line_id, FND_API.G_MISS_NUM, null, p_benefit_price_list_line_id)
           , DECODE( p_parent_adj_line_id , FND_API.G_MISS_NUM, null, p_parent_adj_line_id)
           , DECODE( p_start_date_active, FND_API.G_MISS_DATE , null, p_start_date_active)
           , DECODE( p_end_date_active, FND_API.G_MISS_DATE , null, p_end_date_active)
           , DECODE( p_creation_date, FND_API.g_miss_date, SYSDATE, p_creation_date)
           , DECODE( p_created_by, FND_API.g_miss_num, FND_GLOBAL.USER_ID, p_created_by)
           , DECODE( p_last_update_date, FND_API.g_miss_date, SYSDATE, p_last_update_date)
           , DECODE( p_last_updated_by, FND_API.g_miss_num, FND_GLOBAL.USER_ID, p_last_updated_by)
           , DECODE( p_last_update_login, FND_API.g_miss_num, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login)
           , DECODE( px_object_version_number, FND_API.g_miss_num, 1, px_object_version_number)
           );

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
          p_offer_adj_new_line_id    NUMBER,
          p_offer_adjustment_id    NUMBER,
          p_volume_from    NUMBER,
          p_volume_to    NUMBER,
          p_volume_type    VARCHAR2,
          p_discount    NUMBER,
          p_discount_type    VARCHAR2,
          p_tier_type    VARCHAR2,
          p_td_discount NUMBER,
          p_td_discount_type VARCHAR2,
          p_quantity NUMBER,
          p_benefit_price_list_line_id NUMBER,
          p_parent_adj_line_id NUMBER,
          p_start_date_active DATE,
          p_end_date_active DATE,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER)

 IS
 BEGIN
    Update OZF_OFFER_ADJ_NEW_LINES
    SET
              offer_adj_new_line_id = DECODE( p_offer_adj_new_line_id, FND_API.g_miss_num, NULL, NULL, offer_adj_new_line_id, p_offer_adj_new_line_id),
              offer_adjustment_id = DECODE( p_offer_adjustment_id, FND_API.g_miss_num, NULL, NULL, offer_adjustment_id, p_offer_adjustment_id),
              volume_from = DECODE( p_volume_from, FND_API.g_miss_num, NULL, NULL,volume_from, p_volume_from),
              volume_to = DECODE( p_volume_to, FND_API.g_miss_num, NULL, NULL, volume_to, p_volume_to),
              volume_type = DECODE( p_volume_type, FND_API.g_miss_char, NULL, NULL, volume_type, p_volume_type),
              discount = DECODE( p_discount, FND_API.g_miss_num, NULL, NULL, discount, p_discount),
              discount_type = DECODE( p_discount_type, FND_API.g_miss_char, NULL, NULL, discount_type, p_discount_type),
              tier_type = DECODE( p_tier_type, FND_API.g_miss_char, NULL, NULL, tier_type, p_tier_type),
              td_discount = DECODE(p_td_discount , FND_API.g_miss_num, NULL, NULL, td_discount, p_td_discount),
              td_discount_type = DECODE(p_td_discount_type, FND_API.g_miss_char, NULL, NULL,td_discount_type, p_td_discount_type),
              quantity         = DECODE(p_quantity , FND_API.G_MISS_NUM, NULL,null, quantity, p_quantity),
              benefit_price_list_line_id = DECODE(p_benefit_price_list_line_id, FND_API.G_MISS_NUM , NULL, null, benefit_price_list_line_id, p_benefit_price_list_line_id),
              parent_adj_line_id        = DECODE(p_parent_adj_line_id , fnd_api.g_miss_num, NULL, NULL, parent_adj_line_id , p_parent_adj_line_id),
              start_date_active =  DECODE( p_start_date_active, FND_API.G_MISS_DATE , null, null, start_date_active, p_start_date_active),
              end_date_active   =  DECODE( p_end_date_active, FND_API.G_MISS_DATE , null, null , end_date_active, p_end_date_active),
              last_update_date = DECODE( p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(null), p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
              object_version_number = nvl(p_object_version_number,0) + 1
   WHERE OFFER_ADJ_NEW_LINE_ID = p_OFFER_ADJ_NEW_LINE_ID
   AND   object_version_number = p_object_version_number;

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
    p_OFFER_ADJ_NEW_LINE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM OZF_OFFER_ADJ_NEW_LINES
    WHERE OFFER_ADJ_NEW_LINE_ID = p_OFFER_ADJ_NEW_LINE_ID;
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
          p_offer_adj_new_line_id    NUMBER,
          p_offer_adjustment_id    NUMBER,
          p_volume_from    NUMBER,
          p_volume_to    NUMBER,
          p_volume_type    VARCHAR2,
          p_discount    NUMBER,
          p_discount_type    VARCHAR2,
          p_tier_type    VARCHAR2,
          p_td_discount NUMBER,
          p_td_discount_type VARCHAR2,
          p_quantity NUMBER,
          p_benefit_price_list_line_id NUMBER,
          p_parent_adj_line_id NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM OZF_OFFER_ADJ_NEW_LINES
        WHERE OFFER_ADJ_NEW_LINE_ID =  p_OFFER_ADJ_NEW_LINE_ID
        FOR UPDATE of OFFER_ADJ_NEW_LINE_ID NOWAIT;
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
           (      Recinfo.offer_adj_new_line_id = p_offer_adj_new_line_id)
       AND (    ( Recinfo.offer_adjustment_id = p_offer_adjustment_id)
            OR (    ( Recinfo.offer_adjustment_id IS NULL )
                AND (  p_offer_adjustment_id IS NULL )))
       AND (    ( Recinfo.volume_from = p_volume_from)
            OR (    ( Recinfo.volume_from IS NULL )
                AND (  p_volume_from IS NULL )))
       AND (    ( Recinfo.volume_to = p_volume_to)
            OR (    ( Recinfo.volume_to IS NULL )
                AND (  p_volume_to IS NULL )))
       AND (    ( Recinfo.volume_type = p_volume_type)
            OR (    ( Recinfo.volume_type IS NULL )
                AND (  p_volume_type IS NULL )))
       AND (    ( Recinfo.discount = p_discount)
            OR (    ( Recinfo.discount IS NULL )
                AND (  p_discount IS NULL )))
       AND (    ( Recinfo.discount_type = p_discount_type)
            OR (    ( Recinfo.discount_type IS NULL )
                AND (  p_discount_type IS NULL )))
       AND (    ( Recinfo.tier_type = p_tier_type)
            OR (    ( Recinfo.tier_type IS NULL )
                AND (  p_tier_type IS NULL )))
       AND (    ( Recinfo.td_discount = p_td_discount)
            OR (    ( Recinfo.td_discount IS NULL )
                AND (  p_td_discount IS NULL )))
       AND (    ( Recinfo.td_discount_type = p_td_discount_type)
            OR (    ( Recinfo.td_discount_type IS NULL )
                AND (  p_td_discount_type IS NULL )))
       AND (    ( Recinfo.quantity = p_quantity)
            OR (    ( Recinfo.quantity IS NULL )
                AND (  p_quantity IS NULL )))
       AND (    ( Recinfo.benefit_price_list_line_id = p_benefit_price_list_line_id)
            OR (    ( Recinfo.benefit_price_list_line_id IS NULL )
                AND (  p_benefit_price_list_line_id IS NULL )))
       AND (    ( Recinfo.parent_adj_line_id = p_parent_adj_line_id)
            OR (    ( Recinfo.parent_adj_line_id IS NULL )
                AND (  p_parent_adj_line_id IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END OZF_OFFER_ADJ_NEW_LINES_PKG;

/
