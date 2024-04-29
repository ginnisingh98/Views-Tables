--------------------------------------------------------
--  DDL for Package AHL_UNIT_ACCOMPLISH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UNIT_ACCOMPLISH_PKG" AUTHID CURRENT_USER AS
/* $Header: AHLLUMAS.pls 115.4 2002/12/04 23:14:18 sracha noship $ */
-- ARCS header version

PROCEDURE insert_row (
  P_X_UNIT_ACCOMPLISHMNT_ID    IN OUT NOCOPY NUMBER,
  P_UNIT_EFFECTIVITY_ID        IN     NUMBER,
  P_COUNTER_ID                 IN     NUMBER,
  P_COUNTER_VALUE              IN     NUMBER,
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
  P_UNIT_ACCOMPLISHMNT_ID      IN     NUMBER,
  P_UNIT_EFFECTIVITY_ID        IN     NUMBER,
  P_COUNTER_ID                 IN     NUMBER,
  P_COUNTER_VALUE              IN     NUMBER,
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
  P_UNIT_ACCOMPLISHMNT_ID      IN     NUMBER
);


END AHL_UNIT_ACCOMPLISH_PKG;

 

/
