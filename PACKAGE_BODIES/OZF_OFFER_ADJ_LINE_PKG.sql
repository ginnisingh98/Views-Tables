--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_ADJ_LINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_ADJ_LINE_PKG" as
/* $Header: ozftoalb.pls 120.1 2005/09/26 17:59:42 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Offer_Adj_Line_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Offer_Adj_Line_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftoalb.pls';




--  ========================================================
--
--  NAME
--  Insert_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          px_offer_adjustment_line_id   IN OUT NOCOPY NUMBER,
          p_offer_adjustment_id    NUMBER,
          p_list_line_id    NUMBER,
          p_arithmetic_operator    VARCHAR2,
          p_original_discount    NUMBER,
          p_modified_discount    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_list_header_id    NUMBER,
          p_accrual_flag    VARCHAR2,
          p_list_line_id_td    NUMBER,
          p_original_discount_td    NUMBER,
          p_modified_discount_td    NUMBER,
      p_quantity    NUMBER ,
      p_created_from_adjustments VARCHAR2,
      p_discount_end_date DATE)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO ozf_offer_adjustment_lines(
           offer_adjustment_line_id,
           offer_adjustment_id,
           list_line_id,
           arithmetic_operator,
           original_discount,
           modified_discount,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           list_header_id,
           accrual_flag,
           list_line_id_td,
           original_discount_td,
           modified_discount_td,
       quantity,
       created_from_adjustments,
       discount_end_date
   ) VALUES (
           DECODE( px_offer_adjustment_line_id, FND_API.G_MISS_NUM, NULL, px_offer_adjustment_line_id),
           DECODE( p_offer_adjustment_id, FND_API.G_MISS_NUM, NULL, p_offer_adjustment_id),
           DECODE( p_list_line_id, FND_API.G_MISS_NUM, NULL, p_list_line_id),
           DECODE( p_arithmetic_operator, FND_API.g_miss_char, NULL, p_arithmetic_operator),
           DECODE( p_original_discount, FND_API.G_MISS_NUM, NULL, p_original_discount),
           DECODE( p_modified_discount, FND_API.G_MISS_NUM, NULL, p_modified_discount),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           DECODE( p_list_header_id, FND_API.G_MISS_NUM, NULL, p_list_header_id),
           DECODE( p_accrual_flag, FND_API.g_miss_char, NULL, p_accrual_flag),
           DECODE( p_list_line_id_td, FND_API.G_MISS_NUM, NULL, p_list_line_id_td),
           DECODE( p_original_discount_td, FND_API.G_MISS_NUM, NULL, p_original_discount_td),
           DECODE( p_modified_discount_td, FND_API.G_MISS_NUM, NULL, p_modified_discount_td),
           DECODE( p_quantity, FND_API.G_MISS_NUM, NULL, p_quantity),
           DECODE( p_created_from_adjustments, FND_API.g_miss_char, NULL, p_created_from_adjustments),
           DECODE( p_discount_end_date, FND_API.g_miss_date, NULL, p_discount_end_date)
       );

END Insert_Row;




--  ========================================================
--
--  NAME
--  Update_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_offer_adjustment_line_id    NUMBER,
          p_offer_adjustment_id    NUMBER,
          p_list_line_id    NUMBER,
          p_arithmetic_operator    VARCHAR2,
          p_original_discount    NUMBER,
          p_modified_discount    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_list_header_id    NUMBER,
          p_accrual_flag    VARCHAR2,
          p_list_line_id_td    NUMBER,
          p_original_discount_td    NUMBER,
          p_modified_discount_td    NUMBER,
          p_quantity    NUMBER,
          p_created_from_adjustments VARCHAR2,
          p_discount_end_date DATE
      )

 IS
 BEGIN
    Update ozf_offer_adjustment_lines
    SET
              offer_adjustment_line_id = DECODE( p_offer_adjustment_line_id, null, offer_adjustment_line_id, FND_API.G_MISS_NUM, null, p_offer_adjustment_line_id),
              offer_adjustment_id = DECODE( p_offer_adjustment_id, null, offer_adjustment_id, FND_API.G_MISS_NUM, null, p_offer_adjustment_id),
              list_line_id = DECODE( p_list_line_id, null, list_line_id, FND_API.G_MISS_NUM, null, p_list_line_id),
              arithmetic_operator = DECODE( p_arithmetic_operator, null, arithmetic_operator, FND_API.g_miss_char, null, p_arithmetic_operator),
              original_discount = DECODE( p_original_discount, null, original_discount, FND_API.G_MISS_NUM, null, p_original_discount),
          --    modified_discount = DECODE( p_modified_discount, null, modified_discount, FND_API.G_MISS_NUM, null, p_modified_discount),
           modified_discount = p_modified_discount,
              last_update_date = DECODE( p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(null), p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
            object_version_number = object_version_number + 1 ,
              list_header_id = DECODE( p_list_header_id, null, list_header_id, FND_API.G_MISS_NUM, null, p_list_header_id),
              accrual_flag = DECODE( p_accrual_flag, null, accrual_flag, FND_API.g_miss_char, null, p_accrual_flag),
              list_line_id_td = DECODE( p_list_line_id_td, null, list_line_id_td, FND_API.G_MISS_NUM, null, p_list_line_id_td),
              original_discount_td = DECODE( p_original_discount_td, null, original_discount_td, FND_API.G_MISS_NUM, null, p_original_discount_td),
           --   modified_discount_td = DECODE( p_modified_discount_td, null, modified_discount_td, FND_API.G_MISS_NUM, null, p_modified_discount_td),
            modified_discount_td = p_modified_discount_td,
          quantity = DECODE( p_quantity, null, quantity, FND_API.G_MISS_NUM, null, p_quantity),
            discount_end_date = DECODE(p_discount_end_date, null, discount_end_date, FND_API.G_MISS_DATE, null, p_discount_end_date)
--          created_from_adjustments = DECODE( p_created_from_adjustments, null, created_from_adjustments, FND_API.g_miss_char, null, p_created_from_adjustments)
   WHERE offer_adjustment_line_id = p_offer_adjustment_line_id
   AND   object_version_number = px_object_version_number;


   IF (SQL%NOTFOUND) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   px_object_version_number := nvl(px_object_version_number,0) + 1;

END Update_Row;




--  ========================================================
--
--  NAME
--  Delete_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_offer_adjustment_line_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM ozf_offer_adjustment_lines
    WHERE offer_adjustment_line_id = p_offer_adjustment_line_id
    AND object_version_number = p_object_version_number;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;





--  ========================================================
--
--  NAME
--  Lock_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
    p_offer_adjustment_line_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM ozf_offer_adjustment_lines
        WHERE offer_adjustment_line_id =  p_offer_adjustment_line_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF offer_adjustment_line_id NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN

   OPEN c;
   FETCH c INTO Recinfo;
   IF (c%NOTFOUND) THEN
      CLOSE c;
      OZF_Utility_PVT.error_message ('OZF_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c;
END Lock_Row;



END OZF_Offer_Adj_Line_PKG;

/
