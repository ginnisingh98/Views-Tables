--------------------------------------------------------
--  DDL for Package EAM_ASSET_ATTR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ASSET_ATTR_PVT" AUTHID CURRENT_USER as
/* $Header: EAMVAATS.pls 115.6 2004/02/18 13:56:14 ashetye ship $ */
 -- Start of comments
 -- API name    : EAM_ASSET_ATTR_PVT
 -- Type     : Private
 -- Function :
 -- Pre-reqs : None.
 -- Parameters  :
 -- IN       P_API_VERSION                 IN NUMBER       REQUIRED
 --          P_INIT_MSG_LIST               IN VARCHAR2     OPTIONAL
 --             DEFAULT = FND_API.G_FALSE
 --          P_COMMIT                      IN VARCHAR2     OPTIONAL
 --             DEFAULT = FND_API.G_FALSE
 --          P_VALIDATION_LEVEL            IN NUMBER       OPTIONAL
 --             DEFAULT = FND_API.G_VALID_LEVEL_FULL
 --          P_ROWID                       IN OUT VARCHAR2 REQUIRED
 --          P_INVENTORY_ITEM_ID           IN  NUMBER
 --          P_SERIAL_NUMBER               IN  VARCHAR2
 --          P_START_DATE_ACTIVE           IN  DATE
 --          P_DESCRIPTIVE_TEXT            IN  VARCHAR2
 --          P_ORGANIZATION_ID             IN  NUMBER
 --          P_CATEGORY_ID                 IN  NUMBER
 --          P_PN_LOCATION_ID              IN  NUMBER
 --          P_EAM_LOCATION_ID             IN  NUMBER
 --          P_FA_ASSET_ID                 IN  NUMBER
 --          P_ASSET_STATUS_CODE           IN  VARCHAR2
 --          P_ASSET_CRITICALITY_CODE      IN  VARCHAR2
 --          P_WIP_ACCOUNTING_CLASS_CODE   IN  VARCHAR2
 --          P_MAINTAINABLE_FLAG           IN  VARCHAR2
 --          P_NETWORK_ASSET_FLAG          IN  VARCHAR2
 --          P_OWNING_DEPARTMENT_ID        IN  NUMBER
 --          P_DEPENDENT_ASSET_FLAG        IN  VARCHAR2
 --          P_ATTRIBUTE_CATEGORY          IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE1                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE2                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE3                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE4                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE5                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE6                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE7                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE8                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE9                  IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE10                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE11                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE12                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE13                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE14                 IN  VARCHAR2    OPTIONAL
 --          P_ATTRIBUTE15                 IN  VARCHAR2    OPTIONAL
 --          P_LAST_UPDATE_DATE            IN  DATE        REQUIRED
 --          P_LAST_UPDATED_BY             IN  NUMBER      REQUIRED
 --          P_CREATION_DATE               IN  DATE        REQUIRED
 --          P_CREATED_BY                  IN  NUMBER      REQUIRED
 --          P_LAST_UPDATE_LOGIN           IN  NUMBER      REQUIRED
 --          P_REQUEST_ID                  IN  NUMBER DEFAULT NULL OPTIONAL
 --          P_PROGRAM_APPLICATION_ID      IN  NUMBER DEFAULT NULL OPTIONAL
 --          P_PROGRAM_ID                  IN  NUMBER DEFAULT NULL OPTIONAL
 --          P_PROGRAM_UPDATE_DATE         IN  DATE DEFAULT NULL
 -- OUT      X_OBJECT_ID                   OUT NUMBER
 --          X_RETURN_STATUS               OUT VARCHAR2(1)
 --          X_MSG_COUNT                   OUT NUMBER
 --          X_MSG_DATA                    OUT VARCHAR2(2000)
 --
 -- Version  Current version 115.0
 --
 -- Notes    : Note text
 --
 -- End of comments


PROCEDURE INSERT_ROW(
  P_API_VERSION                  IN NUMBER,
  P_INIT_MSG_LIST                IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT                       IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL             IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID                    IN OUT NOCOPY VARCHAR2,
  P_ASSOCIATION_ID                  NUMBER,
  P_APPLICATION_ID                  NUMBER,
  P_DESCRIPTIVE_FLEXFIELD_NAME      VARCHAR2,
  P_INVENTORY_ITEM_ID               NUMBER,
  P_SERIAL_NUMBER                   VARCHAR2,
  P_ORGANIZATION_ID                 NUMBER,
  P_ATTRIBUTE_CATEGORY              VARCHAR2,
  P_C_ATTRIBUTE1                    VARCHAR2,
  P_C_ATTRIBUTE2                    VARCHAR2,
  P_C_ATTRIBUTE3                    VARCHAR2,
  P_C_ATTRIBUTE4                    VARCHAR2,
  P_C_ATTRIBUTE5                    VARCHAR2,
  P_C_ATTRIBUTE6                    VARCHAR2,
  P_C_ATTRIBUTE7                    VARCHAR2,
  P_C_ATTRIBUTE8                    VARCHAR2,
  P_C_ATTRIBUTE9                    VARCHAR2,
  P_C_ATTRIBUTE10                   VARCHAR2,
  P_C_ATTRIBUTE11                   VARCHAR2,
  P_C_ATTRIBUTE12                   VARCHAR2,
  P_C_ATTRIBUTE13                   VARCHAR2,
  P_C_ATTRIBUTE14                   VARCHAR2,
  P_C_ATTRIBUTE15                   VARCHAR2,
  P_C_ATTRIBUTE16                   VARCHAR2,
  P_C_ATTRIBUTE17                   VARCHAR2,
  P_C_ATTRIBUTE18                   VARCHAR2,
  P_C_ATTRIBUTE19                   VARCHAR2,
  P_C_ATTRIBUTE20                   VARCHAR2,
  P_D_ATTRIBUTE1                    DATE,
  P_D_ATTRIBUTE2                    DATE,
  P_D_ATTRIBUTE3                    DATE,
  P_D_ATTRIBUTE4                    DATE,
  P_D_ATTRIBUTE5                    DATE,
  P_D_ATTRIBUTE6                    DATE,
  P_D_ATTRIBUTE7                    DATE,
  P_D_ATTRIBUTE8                    DATE,
  P_D_ATTRIBUTE9                    DATE,
  P_D_ATTRIBUTE10                   DATE,
  P_N_ATTRIBUTE1                    NUMBER,
  P_N_ATTRIBUTE2                    NUMBER,
  P_N_ATTRIBUTE3                    NUMBER,
  P_N_ATTRIBUTE4                    NUMBER,
  P_N_ATTRIBUTE5                    NUMBER,
  P_N_ATTRIBUTE6                    NUMBER,
  P_N_ATTRIBUTE7                    NUMBER,
  P_N_ATTRIBUTE8                    NUMBER,
  P_N_ATTRIBUTE9                    NUMBER,
  P_N_ATTRIBUTE10                   NUMBER,
  P_REQUEST_ID                      NUMBER DEFAULT NULL,
  P_PROGRAM_APPLICATION_ID          NUMBER DEFAULT NULL,
  P_PROGRAM_ID                      NUMBER DEFAULT NULL,
  P_PROGRAM_UPDATE_DATE             DATE DEFAULT NULL,
  P_MAINTENANCE_OBJECT_TYPE         NUMBER,
  P_MAINTENANCE_OBJECT_ID           NUMBER,
  P_CREATION_ORGANIZATION_ID          NUMBER,
  P_LAST_UPDATE_DATE                DATE,
  P_LAST_UPDATED_BY                 NUMBER,
  P_CREATION_DATE                   DATE,
  P_CREATED_BY                      NUMBER,
  P_LAST_UPDATE_LOGIN               NUMBER,
  X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT NOCOPY NUMBER,
  X_MSG_DATA                    OUT NOCOPY VARCHAR2);



PROCEDURE LOCK_ROW(
  P_API_VERSION                  IN NUMBER,
  P_INIT_MSG_LIST                IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT                       IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL             IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID                    IN OUT NOCOPY VARCHAR2,
  P_ASSOCIATION_ID                  NUMBER,
  P_APPLICATION_ID                  NUMBER,
  P_DESCRIPTIVE_FLEXFIELD_NAME      VARCHAR2,
  P_INVENTORY_ITEM_ID               NUMBER,
  P_SERIAL_NUMBER                   VARCHAR2,
  P_ORGANIZATION_ID                 NUMBER,
  P_ATTRIBUTE_CATEGORY              VARCHAR2,
  P_C_ATTRIBUTE1                    VARCHAR2,
  P_C_ATTRIBUTE2                    VARCHAR2,
  P_C_ATTRIBUTE3                    VARCHAR2,
  P_C_ATTRIBUTE4                    VARCHAR2,
  P_C_ATTRIBUTE5                    VARCHAR2,
  P_C_ATTRIBUTE6                    VARCHAR2,
  P_C_ATTRIBUTE7                    VARCHAR2,
  P_C_ATTRIBUTE8                    VARCHAR2,
  P_C_ATTRIBUTE9                    VARCHAR2,
  P_C_ATTRIBUTE10                   VARCHAR2,
  P_C_ATTRIBUTE11                   VARCHAR2,
  P_C_ATTRIBUTE12                   VARCHAR2,
  P_C_ATTRIBUTE13                   VARCHAR2,
  P_C_ATTRIBUTE14                   VARCHAR2,
  P_C_ATTRIBUTE15                   VARCHAR2,
  P_C_ATTRIBUTE16                   VARCHAR2,
  P_C_ATTRIBUTE17                   VARCHAR2,
  P_C_ATTRIBUTE18                   VARCHAR2,
  P_C_ATTRIBUTE19                   VARCHAR2,
  P_C_ATTRIBUTE20                   VARCHAR2,
  P_D_ATTRIBUTE1                    DATE,
  P_D_ATTRIBUTE2                    DATE,
  P_D_ATTRIBUTE3                    DATE,
  P_D_ATTRIBUTE4                    DATE,
  P_D_ATTRIBUTE5                    DATE,
  P_D_ATTRIBUTE6                    DATE,
  P_D_ATTRIBUTE7                    DATE,
  P_D_ATTRIBUTE8                    DATE,
  P_D_ATTRIBUTE9                    DATE,
  P_D_ATTRIBUTE10                   DATE,
  P_N_ATTRIBUTE1                    NUMBER,
  P_N_ATTRIBUTE2                    NUMBER,
  P_N_ATTRIBUTE3                    NUMBER,
  P_N_ATTRIBUTE4                    NUMBER,
  P_N_ATTRIBUTE5                    NUMBER,
  P_N_ATTRIBUTE6                    NUMBER,
  P_N_ATTRIBUTE7                    NUMBER,
  P_N_ATTRIBUTE8                    NUMBER,
  P_N_ATTRIBUTE9                    NUMBER,
  P_N_ATTRIBUTE10                   NUMBER,
  P_REQUEST_ID                      NUMBER DEFAULT NULL,
  P_PROGRAM_APPLICATION_ID          NUMBER DEFAULT NULL,
  P_PROGRAM_ID                      NUMBER DEFAULT NULL,
  P_PROGRAM_UPDATE_DATE             DATE DEFAULT NULL,
  P_MAINTENANCE_OBJECT_TYPE         NUMBER,
  P_MAINTENANCE_OBJECT_ID           NUMBER,
  X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT NOCOPY NUMBER,
  X_MSG_DATA                    OUT NOCOPY VARCHAR2);



PROCEDURE UPDATE_ROW(
  P_API_VERSION                  IN NUMBER,
  P_INIT_MSG_LIST                IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT                       IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL             IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID                    IN OUT NOCOPY VARCHAR2,
  P_C_ATTRIBUTE1                    VARCHAR2,
  P_C_ATTRIBUTE2                    VARCHAR2,
  P_C_ATTRIBUTE3                    VARCHAR2,
  P_C_ATTRIBUTE4                    VARCHAR2,
  P_C_ATTRIBUTE5                    VARCHAR2,
  P_C_ATTRIBUTE6                    VARCHAR2,
  P_C_ATTRIBUTE7                    VARCHAR2,
  P_C_ATTRIBUTE8                    VARCHAR2,
  P_C_ATTRIBUTE9                    VARCHAR2,
  P_C_ATTRIBUTE10                   VARCHAR2,
  P_C_ATTRIBUTE11                   VARCHAR2,
  P_C_ATTRIBUTE12                   VARCHAR2,
  P_C_ATTRIBUTE13                   VARCHAR2,
  P_C_ATTRIBUTE14                   VARCHAR2,
  P_C_ATTRIBUTE15                   VARCHAR2,
  P_C_ATTRIBUTE16                   VARCHAR2,
  P_C_ATTRIBUTE17                   VARCHAR2,
  P_C_ATTRIBUTE18                   VARCHAR2,
  P_C_ATTRIBUTE19                   VARCHAR2,
  P_C_ATTRIBUTE20                   VARCHAR2,
  P_D_ATTRIBUTE1                    DATE,
  P_D_ATTRIBUTE2                    DATE,
  P_D_ATTRIBUTE3                    DATE,
  P_D_ATTRIBUTE4                    DATE,
  P_D_ATTRIBUTE5                    DATE,
  P_D_ATTRIBUTE6                    DATE,
  P_D_ATTRIBUTE7                    DATE,
  P_D_ATTRIBUTE8                    DATE,
  P_D_ATTRIBUTE9                    DATE,
  P_D_ATTRIBUTE10                   DATE,
  P_N_ATTRIBUTE1                    NUMBER,
  P_N_ATTRIBUTE2                    NUMBER,
  P_N_ATTRIBUTE3                    NUMBER,
  P_N_ATTRIBUTE4                    NUMBER,
  P_N_ATTRIBUTE5                    NUMBER,
  P_N_ATTRIBUTE6                    NUMBER,
  P_N_ATTRIBUTE7                    NUMBER,
  P_N_ATTRIBUTE8                    NUMBER,
  P_N_ATTRIBUTE9                    NUMBER,
  P_N_ATTRIBUTE10                   NUMBER,
  P_REQUEST_ID                      NUMBER DEFAULT NULL,
  P_PROGRAM_APPLICATION_ID          NUMBER DEFAULT NULL,
  P_PROGRAM_ID                      NUMBER DEFAULT NULL,
  P_PROGRAM_UPDATE_DATE             DATE DEFAULT NULL,
  P_MAINTENANCE_OBJECT_TYPE         NUMBER,
  P_MAINTENANCE_OBJECT_ID           NUMBER,
  P_LAST_UPDATE_DATE                DATE,
  P_LAST_UPDATED_BY                 NUMBER,
  P_LAST_UPDATE_LOGIN               NUMBER,
  /* Bug 3371507 */
  P_FROM_PUBLIC_API               VARCHAR2 DEFAULT 'Y',
  X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT NOCOPY NUMBER,
  X_MSG_DATA                    OUT NOCOPY VARCHAR2);



PROCEDURE DELETE_ROW(
  P_API_VERSION                  IN NUMBER,
  P_INIT_MSG_LIST                IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT                       IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL             IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID                    IN OUT NOCOPY VARCHAR2,
  X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT NOCOPY NUMBER,
  X_MSG_DATA                    OUT NOCOPY VARCHAR2);



PROCEDURE COPY_ATTRIBUTE(
  P_API_VERSION                  IN NUMBER,
  P_INIT_MSG_LIST                IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT                       IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL             IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  P_INVENTORY_ITEM_ID            IN NUMBER,
  P_ORGANIZATION_ID              IN NUMBER,
  P_SERIAL_NUMBER_FROM           IN VARCHAR2,
  P_SERIAL_NUMBER_TO             IN VARCHAR2,
  X_OBJECT_ID                   OUT NOCOPY NUMBER,
  X_RETURN_STATUS               OUT NOCOPY VARCHAR2,
  X_MSG_COUNT                   OUT NOCOPY NUMBER,
  X_MSG_DATA                    OUT NOCOPY VARCHAR2);


END EAM_ASSET_ATTR_PVT;

 

/
