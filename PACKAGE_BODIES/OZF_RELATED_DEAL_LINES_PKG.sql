--------------------------------------------------------
--  DDL for Package Body OZF_RELATED_DEAL_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_RELATED_DEAL_LINES_PKG" as
/* $Header: ozftordb.pls 120.0 2005/06/01 02:58:49 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_RELATED_DEAL_LINES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_RELATED_DEAL_LINES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftordb.pls';


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
          px_related_deal_lines_id   IN OUT NOCOPY NUMBER,
          p_modifier_id    NUMBER,
          p_related_modifier_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          --p_security_group_id    NUMBER,
          p_estimated_qty_is_max    VARCHAR2,
          p_estimated_amount_is_max    VARCHAR2,
          p_estimated_qty    NUMBER,
          p_estimated_amount    NUMBER,
          p_qp_list_header_id    NUMBER,
          p_estimate_qty_uom  VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO OZF_RELATED_DEAL_LINES(
           related_deal_lines_id,
           modifier_id,
           related_modifier_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           --security_group_id,
           estimated_qty_is_max,
           estimated_amount_is_max,
           estimated_qty,
           estimated_amount,
           qp_list_header_id,
           estimate_qty_uom
   ) VALUES (
           DECODE( px_related_deal_lines_id, FND_API.g_miss_num, NULL, px_related_deal_lines_id),
           DECODE( p_modifier_id, FND_API.g_miss_num, NULL, p_modifier_id),
           DECODE( p_related_modifier_id, FND_API.g_miss_num, NULL, p_related_modifier_id),
           DECODE( p_last_update_date, FND_API.g_miss_date, to_date(NULL), p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, to_date(NULL), p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           --DECODE( p_security_group_id, FND_API.g_miss_num, NULL, p_security_group_id),
           DECODE( p_estimated_qty_is_max, FND_API.g_miss_char, NULL, p_estimated_qty_is_max),
           DECODE( p_estimated_amount_is_max, FND_API.g_miss_char, NULL, p_estimated_amount_is_max),
           DECODE( p_estimated_qty, FND_API.g_miss_num, NULL, p_estimated_qty),
           DECODE( p_estimated_amount, FND_API.g_miss_num, NULL, p_estimated_amount),
           DECODE( p_qp_list_header_id, FND_API.g_miss_num, NULL, p_qp_list_header_id),
           DECODE( p_estimate_qty_uom, FND_API.g_miss_char, NULL, p_estimate_qty_uom));
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
          p_related_deal_lines_id    NUMBER,
          p_modifier_id    NUMBER,
          p_related_modifier_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          --p_security_group_id    NUMBER,
          p_estimated_qty_is_max    VARCHAR2,
          p_estimated_amount_is_max    VARCHAR2,
          p_estimated_qty    NUMBER,
          p_estimated_amount    NUMBER,
          p_qp_list_header_id    NUMBER,
          p_estimate_qty_uom  VARCHAR2)

 IS
 BEGIN
    Update OZF_RELATED_DEAL_LINES
    SET
              related_deal_lines_id = DECODE( p_related_deal_lines_id, FND_API.g_miss_num, related_deal_lines_id, p_related_deal_lines_id),
              modifier_id = DECODE( p_modifier_id, FND_API.g_miss_num, modifier_id, p_modifier_id),
              related_modifier_id = DECODE( p_related_modifier_id, FND_API.g_miss_num, related_modifier_id, p_related_modifier_id),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              --security_group_id = DECODE( p_security_group_id, FND_API.g_miss_num, security_group_id, p_security_group_id),
              estimated_qty_is_max = DECODE( p_estimated_qty_is_max, FND_API.g_miss_char, estimated_qty_is_max, p_estimated_qty_is_max),
              estimated_amount_is_max = DECODE( p_estimated_amount_is_max, FND_API.g_miss_char, estimated_amount_is_max, p_estimated_amount_is_max),
              estimated_qty = DECODE( p_estimated_qty, FND_API.g_miss_num, estimated_qty, p_estimated_qty),
              estimated_amount = DECODE( p_estimated_amount, FND_API.g_miss_num, estimated_amount, p_estimated_amount),
              qp_list_header_id = DECODE( p_qp_list_header_id, FND_API.g_miss_num, qp_list_header_id, p_qp_list_header_id),
              estimate_qty_uom = DECODE( p_estimate_qty_uom, FND_API.g_miss_char, estimate_qty_uom, p_estimate_qty_uom)
   WHERE RELATED_DEAL_LINES_ID = p_RELATED_DEAL_LINES_ID
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
    p_RELATED_DEAL_LINES_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM OZF_RELATED_DEAL_LINES
    WHERE RELATED_DEAL_LINES_ID = p_RELATED_DEAL_LINES_ID;
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
          p_related_deal_lines_id    NUMBER,
          p_modifier_id    NUMBER,
          p_related_modifier_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          --p_security_group_id    NUMBER,
          p_estimated_qty_is_max    VARCHAR2,
          p_estimated_amount_is_max    VARCHAR2,
          p_estimated_qty    NUMBER,
          p_estimated_amount    NUMBER,
          p_qp_list_header_id    NUMBER,
          p_estimate_qty_uom  VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM OZF_RELATED_DEAL_LINES
        WHERE RELATED_DEAL_LINES_ID =  p_RELATED_DEAL_LINES_ID
        FOR UPDATE of RELATED_DEAL_LINES_ID NOWAIT;
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
           (      Recinfo.related_deal_lines_id = p_related_deal_lines_id)
       AND (    ( Recinfo.modifier_id = p_modifier_id)
            OR (    ( Recinfo.modifier_id IS NULL )
                AND (  p_modifier_id IS NULL )))
       AND (    ( Recinfo.related_modifier_id = p_related_modifier_id)
            OR (    ( Recinfo.related_modifier_id IS NULL )
                AND (  p_related_modifier_id IS NULL )))
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
       /*AND (
                ( Recinfo.security_group_id = p_security_group_id
                )
            OR (
                        ( Recinfo.security_group_id IS NULL
                        )
                AND     (  p_security_group_id IS NULL
                        )
                )
             )
*/
       AND (    ( Recinfo.estimated_qty_is_max = p_estimated_qty_is_max)
            OR (    ( Recinfo.estimated_qty_is_max IS NULL )
                AND (  p_estimated_qty_is_max IS NULL )))
       AND (    ( Recinfo.estimated_amount_is_max = p_estimated_amount_is_max)
            OR (    ( Recinfo.estimated_amount_is_max IS NULL )
                AND (  p_estimated_amount_is_max IS NULL )))
       AND (    ( Recinfo.estimated_qty = p_estimated_qty)
            OR (    ( Recinfo.estimated_qty IS NULL )
                AND (  p_estimated_qty IS NULL )))
       AND (    ( Recinfo.estimated_amount = p_estimated_amount)
            OR (    ( Recinfo.estimated_amount IS NULL )
                AND (  p_estimated_amount IS NULL )))
       AND (    ( Recinfo.qp_list_header_id = p_qp_list_header_id)
            OR (    ( Recinfo.qp_list_header_id IS NULL )
                AND (  p_qp_list_header_id IS NULL )))
       AND (    ( Recinfo.estimate_qty_uom = p_estimate_qty_uom)
            OR (    ( Recinfo.estimate_qty_uom IS NULL )
                AND (  p_estimate_qty_uom IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END OZF_RELATED_DEAL_LINES_PKG;

/
