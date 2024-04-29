--------------------------------------------------------
--  DDL for Package Body AMS_DM_LIFT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DM_LIFT_PKG" as
/* $Header: amstdlfb.pls 120.1 2005/06/15 23:57:13 appldev  $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DM_LIFT_PKG
-- Purpose
--
-- History
-- 26-jan-2001 choang   Removed object ver num from where in update
-- 07-Jan-2002 choang   removed security group id
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_DM_LIFT_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstdlfb.pls';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Insert_Row(
          px_LIFT_ID   IN OUT NOCOPY NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          px_OBJECT_VERSION_NUMBER   IN OUT NOCOPY NUMBER,
          p_MODEL_ID    NUMBER,
          p_QUANTILE    NUMBER,
          p_LIFT    NUMBER,
          p_TARGETS    NUMBER,
          p_NON_TARGETS    NUMBER,
          p_TARGETS_CUMM    NUMBER,
          p_TARGET_DENSITY_CUMM    NUMBER,
          p_TARGET_DENSITY    NUMBER,
          p_MARGIN    NUMBER,
          p_ROI    NUMBER,
          p_TARGET_CONFIDENCE    NUMBER,
          p_NON_TARGET_CONFIDENCE    NUMBER
      )
IS
BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_DM_LIFT(
           lift_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           model_id,
           quantile,
           lift,
           targets,
           non_targets,
           targets_cumm,
           target_density_cumm,
           target_density,
           margin,
           roi,
           target_confidence,
           non_target_confidence
   ) VALUES (
           DECODE( px_LIFT_ID, FND_API.g_miss_num, NULL, px_LIFT_ID),
           DECODE( p_LAST_UPDATE_DATE, FND_API.g_miss_date, NULL, p_LAST_UPDATE_DATE),
           DECODE( p_LAST_UPDATED_BY, FND_API.g_miss_num, NULL, p_LAST_UPDATED_BY),
           DECODE( p_CREATION_DATE, FND_API.g_miss_date, NULL, p_CREATION_DATE),
           DECODE( p_CREATED_BY, FND_API.g_miss_num, NULL, p_CREATED_BY),
           DECODE( p_LAST_UPDATE_LOGIN, FND_API.g_miss_num, NULL, p_LAST_UPDATE_LOGIN),
           DECODE( px_OBJECT_VERSION_NUMBER, FND_API.g_miss_num, NULL, px_OBJECT_VERSION_NUMBER),
           DECODE( p_MODEL_ID, FND_API.g_miss_num, NULL, p_MODEL_ID),
           DECODE( p_QUANTILE, FND_API.g_miss_num, NULL, p_QUANTILE),
           DECODE( p_LIFT, FND_API.g_miss_num, NULL, p_LIFT),
           DECODE( p_TARGETS, FND_API.g_miss_num, NULL, p_TARGETS),
           DECODE( p_NON_TARGETS, FND_API.g_miss_num, NULL, p_NON_TARGETS),
           DECODE( p_TARGETS_CUMM, FND_API.g_miss_num, NULL, p_TARGETS_CUMM),
           DECODE( p_TARGET_DENSITY_CUMM, FND_API.g_miss_num, NULL, p_TARGET_DENSITY_CUMM),
           DECODE( p_TARGET_DENSITY, FND_API.g_miss_num, NULL, p_TARGET_DENSITY),
           DECODE( p_MARGIN, FND_API.g_miss_num, NULL, p_MARGIN),
           DECODE( p_ROI, FND_API.g_miss_num, NULL, p_ROI),
           DECODE( p_TARGET_CONFIDENCE, FND_API.g_miss_num, NULL, p_TARGET_CONFIDENCE),
           DECODE( p_NON_TARGET_CONFIDENCE, FND_API.g_miss_num, NULL, p_NON_TARGET_CONFIDENCE)
   );
END Insert_Row;

PROCEDURE Update_Row(
          p_LIFT_ID    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_MODEL_ID    NUMBER,
          p_QUANTILE    NUMBER,
          p_LIFT    NUMBER,
          p_TARGETS    NUMBER,
          p_NON_TARGETS    NUMBER,
          p_TARGETS_CUMM    NUMBER,
          p_TARGET_DENSITY_CUMM    NUMBER,
          p_TARGET_DENSITY    NUMBER,
          p_MARGIN    NUMBER,
          p_ROI    NUMBER,
          p_TARGET_CONFIDENCE    NUMBER,
          p_NON_TARGET_CONFIDENCE    NUMBER
   )
 IS
 BEGIN
    Update AMS_DM_LIFT
    SET
              lift_id = DECODE( p_LIFT_ID, FND_API.g_miss_num, LIFT_ID, p_LIFT_ID),
              last_update_date = DECODE( p_LAST_UPDATE_DATE, FND_API.g_miss_date, LAST_UPDATE_DATE, p_LAST_UPDATE_DATE),
              last_updated_by = DECODE( p_LAST_UPDATED_BY, FND_API.g_miss_num, LAST_UPDATED_BY, p_LAST_UPDATED_BY),
              last_update_login = DECODE( p_LAST_UPDATE_LOGIN, FND_API.g_miss_num, LAST_UPDATE_LOGIN, p_LAST_UPDATE_LOGIN),
              object_version_number = DECODE( p_OBJECT_VERSION_NUMBER, FND_API.g_miss_num, OBJECT_VERSION_NUMBER, p_OBJECT_VERSION_NUMBER),
              model_id = DECODE( p_MODEL_ID, FND_API.g_miss_num, MODEL_ID, p_MODEL_ID),
              quantile = DECODE( p_QUANTILE, FND_API.g_miss_num, QUANTILE, p_QUANTILE),
              lift = DECODE( p_LIFT, FND_API.g_miss_num, LIFT, p_LIFT),
              targets = DECODE( p_TARGETS, FND_API.g_miss_num, TARGETS, p_TARGETS),
              non_targets = DECODE( p_NON_TARGETS, FND_API.g_miss_num, NON_TARGETS, p_NON_TARGETS),
              targets_cumm = DECODE( p_TARGETS_CUMM, FND_API.g_miss_num, TARGETS_CUMM, p_TARGETS_CUMM),
              target_density_cumm = DECODE( p_TARGET_DENSITY_CUMM, FND_API.g_miss_num, TARGET_DENSITY_CUMM, p_TARGET_DENSITY_CUMM),
              target_density = DECODE( p_TARGET_DENSITY, FND_API.g_miss_num, TARGET_DENSITY, p_TARGET_DENSITY),
              margin = DECODE( p_MARGIN, FND_API.g_miss_num, MARGIN, p_MARGIN),
              roi = DECODE( p_ROI, FND_API.g_miss_num, ROI, p_ROI),
              target_confidence = DECODE( p_TARGET_CONFIDENCE, FND_API.g_miss_num, TARGET_CONFIDENCE, p_TARGET_CONFIDENCE),
              non_target_confidence = DECODE( p_NON_TARGET_CONFIDENCE, FND_API.g_miss_num, NON_TARGET_CONFIDENCE, p_NON_TARGET_CONFIDENCE)
   WHERE LIFT_ID = p_LIFT_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;
END Update_Row;

PROCEDURE Delete_Row(
    p_LIFT_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_DM_LIFT
    WHERE LIFT_ID = p_LIFT_ID;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 END Delete_Row;

PROCEDURE Lock_Row(
          p_LIFT_ID    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER    NUMBER,
          p_MODEL_ID    NUMBER,
          p_QUANTILE    NUMBER,
          p_LIFT    NUMBER,
          p_TARGETS    NUMBER,
          p_NON_TARGETS    NUMBER,
          p_TARGETS_CUMM    NUMBER,
          p_TARGET_DENSITY_CUMM    NUMBER,
          p_TARGET_DENSITY    NUMBER,
          p_MARGIN    NUMBER,
          p_ROI    NUMBER,
          p_TARGET_CONFIDENCE    NUMBER,
          p_NON_TARGET_CONFIDENCE    NUMBER
   )
 IS
   CURSOR C IS
        SELECT *
         FROM AMS_DM_LIFT
        WHERE LIFT_ID =  p_LIFT_ID
        FOR UPDATE of LIFT_ID NOWAIT;
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
           (      Recinfo.LIFT_ID = p_LIFT_ID)
       AND (    ( Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE)
            OR (    ( Recinfo.LAST_UPDATE_DATE IS NULL )
                AND (  p_LAST_UPDATE_DATE IS NULL )))
       AND (    ( Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY)
            OR (    ( Recinfo.LAST_UPDATED_BY IS NULL )
                AND (  p_LAST_UPDATED_BY IS NULL )))
       AND (    ( Recinfo.CREATION_DATE = p_CREATION_DATE)
            OR (    ( Recinfo.CREATION_DATE IS NULL )
                AND (  p_CREATION_DATE IS NULL )))
       AND (    ( Recinfo.CREATED_BY = p_CREATED_BY)
            OR (    ( Recinfo.CREATED_BY IS NULL )
                AND (  p_CREATED_BY IS NULL )))
       AND (    ( Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)
            OR (    ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
                AND (  p_LAST_UPDATE_LOGIN IS NULL )))
       AND (    ( Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
            OR (    ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
                AND (  p_OBJECT_VERSION_NUMBER IS NULL )))
       AND (    ( Recinfo.MODEL_ID = p_MODEL_ID)
            OR (    ( Recinfo.MODEL_ID IS NULL )
                AND (  p_MODEL_ID IS NULL )))
       AND (    ( Recinfo.QUANTILE = p_QUANTILE)
            OR (    ( Recinfo.QUANTILE IS NULL )
                AND (  p_QUANTILE IS NULL )))
       AND (    ( Recinfo.LIFT = p_LIFT)
            OR (    ( Recinfo.LIFT IS NULL )
                AND (  p_LIFT IS NULL )))
       AND (    ( Recinfo.TARGETS = p_TARGETS)
            OR (    ( Recinfo.TARGETS IS NULL )
                AND (  p_TARGETS IS NULL )))
       AND (    ( Recinfo.NON_TARGETS = p_NON_TARGETS)
            OR (    ( Recinfo.NON_TARGETS IS NULL )
                AND (  p_NON_TARGETS IS NULL )))
       AND (    ( Recinfo.TARGETS_CUMM = p_TARGETS_CUMM)
            OR (    ( Recinfo.TARGETS_CUMM IS NULL )
                AND (  p_TARGETS_CUMM IS NULL )))
       AND (    ( Recinfo.TARGET_DENSITY_CUMM = p_TARGET_DENSITY_CUMM)
            OR (    ( Recinfo.TARGET_DENSITY_CUMM IS NULL )
                AND (  p_TARGET_DENSITY_CUMM IS NULL )))
       AND (    ( Recinfo.TARGET_DENSITY = p_TARGET_DENSITY)
            OR (    ( Recinfo.TARGET_DENSITY IS NULL )
                AND (  p_TARGET_DENSITY IS NULL )))
       AND (    ( Recinfo.MARGIN = p_MARGIN)
            OR (    ( Recinfo.MARGIN IS NULL )
                AND (  p_MARGIN IS NULL )))
       AND (    ( Recinfo.ROI = p_ROI)
            OR (    ( Recinfo.ROI IS NULL )
                AND (  p_ROI IS NULL )))
       AND (    ( Recinfo.TARGET_CONFIDENCE = p_TARGET_CONFIDENCE)
            OR (    ( Recinfo.TARGET_CONFIDENCE IS NULL )
                AND (  p_TARGET_CONFIDENCE IS NULL )))
       AND (    ( Recinfo.NON_TARGET_CONFIDENCE = p_NON_TARGET_CONFIDENCE)
            OR (    ( Recinfo.NON_TARGET_CONFIDENCE IS NULL )
                AND (  p_NON_TARGET_CONFIDENCE IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END AMS_DM_LIFT_PKG;

/
