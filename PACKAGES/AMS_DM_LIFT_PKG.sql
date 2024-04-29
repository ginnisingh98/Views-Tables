--------------------------------------------------------
--  DDL for Package AMS_DM_LIFT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DM_LIFT_PKG" AUTHID CURRENT_USER AS
/* $Header: amstdlfs.pls 120.1 2005/06/15 23:57:58 appldev  $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DM_LIFT_PKG
-- Purpose
--
-- History
-- 07-Jan-2002 choang   Removed security group id
-- 16-Jan-2002 choang   Fixed syntax problems from security group id
--
-- NOTE
--
-- End of Comments
-- ===============================================================

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
   );

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
   );

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
   );
PROCEDURE Delete_Row(
    p_LIFT_ID  NUMBER);
END AMS_DM_LIFT_PKG;

 

/
