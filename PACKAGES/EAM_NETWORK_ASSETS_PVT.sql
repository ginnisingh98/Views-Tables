--------------------------------------------------------
--  DDL for Package EAM_NETWORK_ASSETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_NETWORK_ASSETS_PVT" AUTHID CURRENT_USER as
/* $Header: EAMVNWKS.pls 115.2 2002/11/22 22:55:40 aan noship $ */
 -- Start of comments
 -- API name    : EAM_NETWORK_ASSETS_PVT
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
 --          P_NETWORK_ASSOCIATION_ID     IN OUT NUMBER   REQUIRED
 --          P_ORGANIZATION_ID             IN  NUMBER      REQUIRED
 --          P_NETWORK_OBJECT_TYPE           IN  NUMBER      REQUIRED
 --          P_NETWORK_OBJECT_ID           IN  NUMBER      REQUIRED
 --          P_MAINTENANCE_OBJECT_TYPE           IN  NUMBER      REQUIRED
 --          P_MAINTENANCE_OBJECT_ID           IN  NUMBER      REQUIRED
 --          P_INVENTORY_ITEM_ID           IN  NUMBER      REQUIRED
 --          P_SERIAL_NUMBER               IN  VARCHAR2    REQUIRED
 --          P_START_DATE_ACTIVE           IN  DATE        OPTIONAL
 --          P_END_DATE_ACTIVE             IN  DATE        OPTIONAL
 --          P_LAST_UPDATE_DATE            IN  DATE        REQUIRED
 --          P_LAST_UPDATED_BY             IN  NUMBER      REQUIRED
 --          P_CREATION_DATE               IN  DATE        REQUIRED
 --          P_CREATED_BY                  IN  NUMBER      REQUIRED
 --          P_LAST_UPDATE_LOGIN           IN  NUMBER      REQUIRED
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
 --          P_REQUEST_ID                  IN  NUMBER DEFAULT NULL OPTIONAL
 --          P_PROGRAM_APPLICATION_ID      IN  NUMBER DEFAULT NULL OPTIONAL
 --          P_PROGRAM_ID                  IN  NUMBER DEFAULT NULL OPTIONAL
 --          P_PROGRAM_UPDATE_DATE         IN  DATE DEFAULT NULL
 -- OUT      X_RETURN_STATUS               OUT VARCHAR2(1)
 --          X_MSG_COUNT                   OUT NUMBER
 --          X_MSG_DATA                    OUT VARCHAR2(2000)
 --
 -- Version  Current version 115.0
 --
 -- Notes    : Note text
 --
 -- End of comments


PROCEDURE INSERT_ROW(
  P_API_VERSION IN NUMBER,
  P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID                         IN OUT NOCOPY VARCHAR2,
  P_NETWORK_ASSOCIATION_ID       IN OUT NOCOPY NUMBER,
  P_ORGANIZATION_ID               NUMBER,
  P_NETWORK_OBJECT_TYPE           NUMBER,
  P_NETWORK_OBJECT_ID             NUMBER,
  P_MAINTENANCE_OBJECT_TYPE       NUMBER,
  P_MAINTENANCE_OBJECT_ID	  NUMBER,
  P_NETWORK_ITEM_ID      	  NUMBER,
  P_NETWORK_SERIAL_NUMBER 	  VARCHAR2,
  P_INVENTORY_ITEM_ID    	  NUMBER,
  P_SERIAL_NUMBER 	     	  VARCHAR2,
  P_START_DATE_ACTIVE             DATE,
  P_END_DATE_ACTIVE               DATE,
  P_LAST_UPDATE_DATE              DATE,
  P_LAST_UPDATED_BY               NUMBER,
  P_CREATION_DATE                 DATE,
  P_CREATED_BY                    NUMBER,
  P_LAST_UPDATE_LOGIN             NUMBER,
  P_ATTRIBUTE_CATEGORY            VARCHAR2,
  P_ATTRIBUTE1                    VARCHAR2,
  P_ATTRIBUTE2                    VARCHAR2,
  P_ATTRIBUTE3                    VARCHAR2,
  P_ATTRIBUTE4                    VARCHAR2,
  P_ATTRIBUTE5                    VARCHAR2,
  P_ATTRIBUTE6                    VARCHAR2,
  P_ATTRIBUTE7                    VARCHAR2,
  P_ATTRIBUTE8                    VARCHAR2,
  P_ATTRIBUTE9                    VARCHAR2,
  P_ATTRIBUTE10                   VARCHAR2,
  P_ATTRIBUTE11                   VARCHAR2,
  P_ATTRIBUTE12                   VARCHAR2,
  P_ATTRIBUTE13                   VARCHAR2,
  P_ATTRIBUTE14                   VARCHAR2,
  P_ATTRIBUTE15                   VARCHAR2,
  P_REQUEST_ID                    NUMBER DEFAULT NULL,
  P_PROGRAM_APPLICATION_ID        NUMBER DEFAULT NULL,
  P_PROGRAM_ID                    NUMBER DEFAULT NULL,
  P_PROGRAM_UPDATE_DATE           DATE DEFAULT NULL,
  X_RETURN_STATUS OUT NOCOPY VARCHAR2,
  X_MSG_COUNT OUT NOCOPY NUMBER,
  X_MSG_DATA OUT NOCOPY VARCHAR2);



PROCEDURE LOCK_ROW(
  P_API_VERSION IN NUMBER,
  P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID                         VARCHAR2,
  P_NETWORK_ASSOCIATION_ID        NUMBER,
  P_ORGANIZATION_ID               NUMBER,
  P_NETWORK_OBJECT_TYPE           NUMBER,
  P_NETWORK_OBJECT_ID             NUMBER,
  P_MAINTENANCE_OBJECT_TYPE	  NUMBER,
  P_MAINTENANCE_OBJECT_ID	  NUMBER,
  P_NETWORK_ITEM_ID      	  NUMBER,
  P_NETWORK_SERIAL_NUMBER 	  VARCHAR2,
  P_INVENTORY_ITEM_ID    	  NUMBER,
  P_SERIAL_NUMBER 	     	  VARCHAR2,
  P_START_DATE_ACTIVE             DATE,
  P_END_DATE_ACTIVE               DATE,
  P_ATTRIBUTE_CATEGORY            VARCHAR2,
  P_ATTRIBUTE1                    VARCHAR2,
  P_ATTRIBUTE2                    VARCHAR2,
  P_ATTRIBUTE3                    VARCHAR2,
  P_ATTRIBUTE4                    VARCHAR2,
  P_ATTRIBUTE5                    VARCHAR2,
  P_ATTRIBUTE6                    VARCHAR2,
  P_ATTRIBUTE7                    VARCHAR2,
  P_ATTRIBUTE8                    VARCHAR2,
  P_ATTRIBUTE9                    VARCHAR2,
  P_ATTRIBUTE10                   VARCHAR2,
  P_ATTRIBUTE11                   VARCHAR2,
  P_ATTRIBUTE12                   VARCHAR2,
  P_ATTRIBUTE13                   VARCHAR2,
  P_ATTRIBUTE14                   VARCHAR2,
  P_ATTRIBUTE15                   VARCHAR2,
  P_REQUEST_ID                    NUMBER DEFAULT NULL,
  P_PROGRAM_APPLICATION_ID        NUMBER DEFAULT NULL,
  P_PROGRAM_ID                    NUMBER DEFAULT NULL,
  P_PROGRAM_UPDATE_DATE           DATE DEFAULT NULL,
  X_RETURN_STATUS OUT NOCOPY VARCHAR2,
  X_MSG_COUNT OUT NOCOPY NUMBER,
  X_MSG_DATA OUT NOCOPY VARCHAR2);


PROCEDURE UPDATE_ROW(
  P_API_VERSION IN NUMBER,
  P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  P_ROWID                         VARCHAR2,
  P_NETWORK_ASSOCIATION_ID        NUMBER,
  P_ORGANIZATION_ID               NUMBER,
  P_NETWORK_OBJECT_TYPE           NUMBER,
  P_NETWORK_OBJECT_ID             NUMBER,
  P_MAINTENANCE_OBJECT_TYPE	  NUMBER,
  P_MAINTENANCE_OBJECT_ID	  NUMBER,
  P_NETWORK_ITEM_ID      	  NUMBER,
  P_NETWORK_SERIAL_NUMBER 	  VARCHAR2,
  P_INVENTORY_ITEM_ID    	  NUMBER,
  P_SERIAL_NUMBER 	     	  VARCHAR2,
  P_START_DATE_ACTIVE             DATE,
  P_END_DATE_ACTIVE               DATE,
  P_LAST_UPDATE_DATE              DATE,
  P_LAST_UPDATED_BY               NUMBER,
  P_LAST_UPDATE_LOGIN             NUMBER,
  P_ATTRIBUTE_CATEGORY            VARCHAR2,
  P_ATTRIBUTE1                    VARCHAR2,
  P_ATTRIBUTE2                    VARCHAR2,
  P_ATTRIBUTE3                    VARCHAR2,
  P_ATTRIBUTE4                    VARCHAR2,
  P_ATTRIBUTE5                    VARCHAR2,
  P_ATTRIBUTE6                    VARCHAR2,
  P_ATTRIBUTE7                    VARCHAR2,
  P_ATTRIBUTE8                    VARCHAR2,
  P_ATTRIBUTE9                    VARCHAR2,
  P_ATTRIBUTE10                   VARCHAR2,
  P_ATTRIBUTE11                   VARCHAR2,
  P_ATTRIBUTE12                   VARCHAR2,
  P_ATTRIBUTE13                   VARCHAR2,
  P_ATTRIBUTE14                   VARCHAR2,
  P_ATTRIBUTE15                   VARCHAR2,
  P_REQUEST_ID                    NUMBER DEFAULT NULL,
  P_PROGRAM_APPLICATION_ID        NUMBER DEFAULT NULL,
  P_PROGRAM_ID                    NUMBER DEFAULT NULL,
  P_PROGRAM_UPDATE_DATE           DATE DEFAULT NULL,
  X_RETURN_STATUS OUT NOCOPY 	VARCHAR2,
  X_MSG_COUNT OUT NOCOPY 	NUMBER,
  X_MSG_DATA OUT NOCOPY 	VARCHAR2);


END EAM_NETWORK_ASSETS_PVT;

 

/