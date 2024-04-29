--------------------------------------------------------
--  DDL for Package Body AMS_DM_SCORE_RESULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DM_SCORE_RESULTS_PKG" as
/* $Header: amstdrsb.pls 120.1 2005/06/15 23:58:16 appldev  $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DM_SCORE_RESULTS_PKG
-- Purpose
--
-- History
-- 24-Jan-2001 choang   Created.
-- 24-Jan-2001 choang   Removed object version number from update
--                      criteria.
-- 26-Jan-2001 choang   1) Changed response to score and model_score_id
--                      to score_id.
-- 10-Jul-2001 choang   Replaced tree_node with decile.
-- 07-Jan-2002 choang   Removed security group id
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_DM_SCORE_RESULTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstdrsb.pls';


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
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
          px_score_result_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_score_id    NUMBER,
          p_decile    VARCHAR2,
          p_num_records    NUMBER,
          p_score    VARCHAR2,
          p_confidence    NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_DM_SCORE_RESULTS(
           score_result_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           score_id,
           decile,
           num_records,
           score,
           confidence
   ) VALUES (
           DECODE( px_score_result_id, FND_API.g_miss_num, NULL, px_score_result_id),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_score_id, FND_API.g_miss_num, NULL, p_score_id),
           DECODE( p_decile, FND_API.g_miss_char, NULL, p_decile),
           DECODE( p_num_records, FND_API.g_miss_num, NULL, p_num_records),
           DECODE( p_score, FND_API.g_miss_char, NULL, p_score),
           DECODE( p_confidence, FND_API.g_miss_num, NULL, p_confidence));
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
          p_score_result_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_score_id    NUMBER,
          p_decile    VARCHAR2,
          p_num_records    NUMBER,
          p_score    VARCHAR2,
          p_confidence    NUMBER)

 IS
 BEGIN
    Update AMS_DM_SCORE_RESULTS
    SET
              score_result_id = DECODE( p_score_result_id, FND_API.g_miss_num, score_result_id, p_score_result_id),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              score_id = DECODE( p_score_id, FND_API.g_miss_num, score_id, p_score_id),
              decile = DECODE( p_decile, FND_API.g_miss_char, decile, p_decile),
              num_records = DECODE( p_num_records, FND_API.g_miss_num, num_records, p_num_records),
              score = DECODE( p_score, FND_API.g_miss_char, score, p_score),
              confidence = DECODE( p_confidence, FND_API.g_miss_num, confidence, p_confidence)
   WHERE SCORE_RESULT_ID = p_SCORE_RESULT_ID;

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
    p_SCORE_RESULT_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_DM_SCORE_RESULTS
    WHERE SCORE_RESULT_ID = p_SCORE_RESULT_ID;
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
          p_score_result_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_score_id    NUMBER,
          p_decile    VARCHAR2,
          p_num_records    NUMBER,
          p_score    VARCHAR2,
          p_confidence    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_DM_SCORE_RESULTS
        WHERE SCORE_RESULT_ID =  p_SCORE_RESULT_ID
        FOR UPDATE of SCORE_RESULT_ID NOWAIT;
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
           (      Recinfo.score_result_id = p_score_result_id)
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
       AND (    ( Recinfo.score_id = p_score_id)
            OR (    ( Recinfo.score_id IS NULL )
                AND (  p_score_id IS NULL )))
       AND (    ( Recinfo.decile = p_decile)
            OR (    ( Recinfo.decile IS NULL )
                AND (  p_decile IS NULL )))
       AND (    ( Recinfo.num_records = p_num_records)
            OR (    ( Recinfo.num_records IS NULL )
                AND (  p_num_records IS NULL )))
       AND (    ( Recinfo.score = p_score)
            OR (    ( Recinfo.score IS NULL )
                AND (  p_score IS NULL )))
       AND (    ( Recinfo.confidence = p_confidence)
            OR (    ( Recinfo.confidence IS NULL )
                AND (  p_confidence IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END AMS_DM_SCORE_RESULTS_PKG;

/
