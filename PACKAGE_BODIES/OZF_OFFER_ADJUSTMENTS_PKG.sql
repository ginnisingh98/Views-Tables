--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_ADJUSTMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_ADJUSTMENTS_PKG" as
/* $Header: ozftobdb.pls 120.0 2005/06/01 01:50:27 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_OFFER_ADJUSTMENTS_PKG
-- Purpose
--
-- History
--   11-DEC-2002 julou change ams_offer_adjustments to ozf_offer_adjustments_b
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_OFFER_ADJUSTMENTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftobdb.pls';


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
          px_offer_adjustment_id   IN OUT NOCOPY NUMBER,
          p_effective_date    DATE,
          p_approved_date    DATE,
          p_settlement_code    VARCHAR2,
          p_status_code    VARCHAR2,
          p_list_header_id    NUMBER,
          p_version    NUMBER,
          p_budget_adjusted_flag    VARCHAR2,
          p_comments    VARCHAR2,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_security_group_id    NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO ozf_OFFER_ADJUSTMENTS_B(
           offer_adjustment_id,
           effective_date,
           approved_date,
           settlement_code,
           status_code,
           list_header_id,
           version,
           budget_adjusted_flag,
           comments,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           security_group_id
   ) VALUES (
           DECODE( px_offer_adjustment_id, FND_API.g_miss_num, NULL, px_offer_adjustment_id),
           DECODE( p_effective_date, FND_API.g_miss_date, to_date(NULL), p_effective_date),
           DECODE( p_approved_date, FND_API.g_miss_date, to_date(NULL), p_approved_date),
           DECODE( p_settlement_code, FND_API.g_miss_char, NULL, p_settlement_code),
           DECODE( p_status_code, FND_API.g_miss_char, NULL, p_status_code),
           DECODE( p_list_header_id, FND_API.g_miss_num, NULL, p_list_header_id),
           DECODE( p_version, FND_API.g_miss_num, NULL, p_version),
           DECODE( p_budget_adjusted_flag, FND_API.g_miss_char, NULL, p_budget_adjusted_flag),
           DECODE( p_comments, FND_API.g_miss_char, NULL, p_comments),
           DECODE( p_last_update_date, FND_API.g_miss_date, to_date(NULL), p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, to_date(NULL), p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_security_group_id, FND_API.g_miss_num, NULL, p_security_group_id));
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
          p_offer_adjustment_id    NUMBER,
          p_effective_date    DATE,
          p_approved_date    DATE,
          p_settlement_code    VARCHAR2,
          p_status_code    VARCHAR2,
          p_list_header_id    NUMBER,
          p_version    NUMBER,
          p_budget_adjusted_flag    VARCHAR2,
          p_comments    VARCHAR2,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_security_group_id    NUMBER)

 IS
 BEGIN
    Update ozf_OFFER_ADJUSTMENTS_B
    SET
              offer_adjustment_id = DECODE( p_offer_adjustment_id, FND_API.g_miss_num, offer_adjustment_id, p_offer_adjustment_id),
              effective_date = DECODE( p_effective_date, FND_API.g_miss_date, effective_date, p_effective_date),
              approved_date = DECODE( p_approved_date, FND_API.g_miss_date, approved_date, p_approved_date),
              settlement_code = DECODE( p_settlement_code, FND_API.g_miss_char, settlement_code, p_settlement_code),
              status_code = DECODE( p_status_code, FND_API.g_miss_char, status_code, p_status_code),
              list_header_id = DECODE( p_list_header_id, FND_API.g_miss_num, list_header_id, p_list_header_id),
              version = DECODE( p_version, FND_API.g_miss_num, version, p_version),
              budget_adjusted_flag = DECODE( p_budget_adjusted_flag, FND_API.g_miss_char, budget_adjusted_flag, p_budget_adjusted_flag),
              comments = DECODE( p_comments, FND_API.g_miss_char, comments, p_comments),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              security_group_id = DECODE( p_security_group_id, FND_API.g_miss_num, security_group_id, p_security_group_id)
   WHERE OFFER_ADJUSTMENT_ID = p_OFFER_ADJUSTMENT_ID
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
    p_OFFER_ADJUSTMENT_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM ozf_OFFER_ADJUSTMENTS_B
    WHERE OFFER_ADJUSTMENT_ID = p_OFFER_ADJUSTMENT_ID;
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
          p_offer_adjustment_id    NUMBER,
          p_effective_date    DATE,
          p_approved_date    DATE,
          p_settlement_code    VARCHAR2,
          p_status_code    VARCHAR2,
          p_list_header_id    NUMBER,
          p_version    NUMBER,
          p_budget_adjusted_flag    VARCHAR2,
          p_comments    VARCHAR2,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_security_group_id    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM ozf_OFFER_ADJUSTMENTS_B
        WHERE OFFER_ADJUSTMENT_ID =  p_OFFER_ADJUSTMENT_ID
        FOR UPDATE of OFFER_ADJUSTMENT_ID NOWAIT;
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
           (      Recinfo.offer_adjustment_id = p_offer_adjustment_id)
       AND (    ( Recinfo.effective_date = p_effective_date)
            OR (    ( Recinfo.effective_date IS NULL )
                AND (  p_effective_date IS NULL )))
       AND (    ( Recinfo.approved_date = p_approved_date)
            OR (    ( Recinfo.approved_date IS NULL )
                AND (  p_approved_date IS NULL )))
       AND (    ( Recinfo.settlement_code = p_settlement_code)
            OR (    ( Recinfo.settlement_code IS NULL )
                AND (  p_settlement_code IS NULL )))
       AND (    ( Recinfo.status_code = p_status_code)
            OR (    ( Recinfo.status_code IS NULL )
                AND (  p_status_code IS NULL )))
       AND (    ( Recinfo.list_header_id = p_list_header_id)
            OR (    ( Recinfo.list_header_id IS NULL )
                AND (  p_list_header_id IS NULL )))
       AND (    ( Recinfo.version = p_version)
            OR (    ( Recinfo.version IS NULL )
                AND (  p_version IS NULL )))
       AND (    ( Recinfo.budget_adjusted_flag = p_budget_adjusted_flag)
            OR (    ( Recinfo.budget_adjusted_flag IS NULL )
                AND (  p_budget_adjusted_flag IS NULL )))
       AND (    ( Recinfo.comments = p_comments)
            OR (    ( Recinfo.comments IS NULL )
                AND (  p_comments IS NULL )))
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
       AND (    ( Recinfo.security_group_id = p_security_group_id)
            OR (    ( Recinfo.security_group_id IS NULL )
                AND (  p_security_group_id IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END ozf_OFFER_ADJUSTMENTS_PKG;

/
