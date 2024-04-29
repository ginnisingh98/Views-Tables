--------------------------------------------------------
--  DDL for Package AHL_UNIT_THRESHOLDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UNIT_THRESHOLDS_PKG" AUTHID CURRENT_USER AS
/* $Header: AHLLUMTS.pls 115.5 2003/07/25 21:27:51 sikumar noship $ */
-- ARCS header version

PROCEDURE insert_row (
  P_X_UNIT_THRESHOLD_ID        IN OUT NOCOPY NUMBER,
  P_UNIT_DEFERRAL_ID           IN     NUMBER,
  P_COUNTER_ID                 IN     NUMBER,
  P_COUNTER_VALUE              IN     NUMBER,
  P_CTR_VALUE_TYPE_CODE        IN     VARCHAR2,
  P_ATTRIBUTE_CATEGORY         IN     VARCHAR2,
  P_ATTRIBUTE1                 IN     VARCHAR2,
  P_ATTRIBUTE2                 IN     VARCHAR2,
  P_ATTRIBUTE3                 IN     VARCHAR2,
  P_ATTRIBUTE4                 IN     VARCHAR2,
  P_ATTRIBUTE5                 IN     VARCHAR2,
  P_ATTRIBUTE6                 IN     VARCHAR2,
  P_ATTRIBUTE7                 IN     VARCHAR2,
  P_ATTRIBUTE8                 IN     VARCHAR2,
  P_ATTRIBUTE9                 IN     VARCHAR2,
  P_ATTRIBUTE10                IN     VARCHAR2,
  P_ATTRIBUTE11                IN     VARCHAR2,
  P_ATTRIBUTE12                IN     VARCHAR2,
  P_ATTRIBUTE13                IN     VARCHAR2,
  P_ATTRIBUTE14                IN     VARCHAR2,
  P_ATTRIBUTE15                IN     VARCHAR2,
  P_OBJECT_VERSION_NUMBER      IN     NUMBER,
  P_LAST_UPDATE_DATE           IN     DATE,
  P_LAST_UPDATED_BY            IN     NUMBER,
  P_CREATION_DATE              IN     DATE,
  P_CREATED_BY                 IN     NUMBER,
  P_LAST_UPDATE_LOGIN          IN     NUMBER
);

PROCEDURE update_row (
  P_UNIT_THRESHOLD_ID          IN     NUMBER,
  P_UNIT_DEFERRAL_ID           IN     NUMBER,
  P_COUNTER_ID                 IN     NUMBER,
  P_COUNTER_VALUE              IN     NUMBER,
  P_CTR_VALUE_TYPE_CODE        IN     VARCHAR2,
  P_ATTRIBUTE_CATEGORY         IN     VARCHAR2,
  P_ATTRIBUTE1                 IN     VARCHAR2,
  P_ATTRIBUTE2                 IN     VARCHAR2,
  P_ATTRIBUTE3                 IN     VARCHAR2,
  P_ATTRIBUTE4                 IN     VARCHAR2,
  P_ATTRIBUTE5                 IN     VARCHAR2,
  P_ATTRIBUTE6                 IN     VARCHAR2,
  P_ATTRIBUTE7                 IN     VARCHAR2,
  P_ATTRIBUTE8                 IN     VARCHAR2,
  P_ATTRIBUTE9                 IN     VARCHAR2,
  P_ATTRIBUTE10                IN     VARCHAR2,
  P_ATTRIBUTE11                IN     VARCHAR2,
  P_ATTRIBUTE12                IN     VARCHAR2,
  P_ATTRIBUTE13                IN     VARCHAR2,
  P_ATTRIBUTE14                IN     VARCHAR2,
  P_ATTRIBUTE15                IN     VARCHAR2,
  P_OBJECT_VERSION_NUMBER      IN     NUMBER,
  P_LAST_UPDATE_DATE           IN     DATE,
  P_LAST_UPDATED_BY            IN     NUMBER,
  P_LAST_UPDATE_LOGIN          IN     NUMBER
);

procedure delete_row (
  P_UNIT_THRESHOLD_ID          IN     NUMBER
);

END AHL_UNIT_THRESHOLDS_PKG;

 

/
