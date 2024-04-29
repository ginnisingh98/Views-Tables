--------------------------------------------------------
--  DDL for Package HZ_CODE_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CODE_ASSIGNMENTS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHCASTS.pls 120.4 2005/10/30 04:17:34 appldev ship $ */

PROCEDURE Insert_Row (
    X_CODE_ASSIGNMENT_ID                    IN OUT NOCOPY NUMBER,
    X_OWNER_TABLE_NAME                      IN     VARCHAR2,
    X_OWNER_TABLE_ID                        IN     NUMBER,
    X_OWNER_TABLE_KEY_1                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_2                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_3                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_4                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_5                     IN     VARCHAR2,
    X_CLASS_CATEGORY                        IN     VARCHAR2,
    X_CLASS_CODE                            IN     VARCHAR2,
    X_PRIMARY_FLAG                          IN     VARCHAR2,
    X_CONTENT_SOURCE_TYPE                   IN     VARCHAR2,
    X_START_DATE_ACTIVE                     IN     DATE,
    X_END_DATE_ACTIVE                       IN     DATE,
    X_STATUS                                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_RANK                                  IN     NUMBER,
    X_APPLICATION_ID                        IN     NUMBER,
    X_ACTUAL_CONTENT_SOURCE                 IN     VARCHAR2
);

PROCEDURE Update_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_CODE_ASSIGNMENT_ID                    IN     NUMBER,
    X_OWNER_TABLE_NAME                      IN     VARCHAR2,
    X_OWNER_TABLE_ID                        IN     NUMBER,
    X_OWNER_TABLE_KEY_1                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_2                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_3                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_4                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_5                     IN     VARCHAR2,
    X_CLASS_CATEGORY                        IN     VARCHAR2,
    X_CLASS_CODE                            IN     VARCHAR2,
    X_PRIMARY_FLAG                          IN     VARCHAR2,
    X_CONTENT_SOURCE_TYPE                   IN     VARCHAR2,
    X_START_DATE_ACTIVE                     IN     DATE,
    X_END_DATE_ACTIVE                       IN     DATE,
    X_STATUS                                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_RANK                                  IN     NUMBER,
    X_APPLICATION_ID                        IN     NUMBER,
    X_ACTUAL_CONTENT_SOURCE                 IN     VARCHAR2
);

PROCEDURE Lock_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_CODE_ASSIGNMENT_ID                    IN     NUMBER,
    X_OWNER_TABLE_NAME                      IN     VARCHAR2,
    X_OWNER_TABLE_ID                        IN     NUMBER,
    X_OWNER_TABLE_KEY_1                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_2                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_3                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_4                     IN     VARCHAR2,
    X_OWNER_TABLE_KEY_5                     IN     VARCHAR2,
    X_CLASS_CATEGORY                        IN     VARCHAR2,
    X_CLASS_CODE                            IN     VARCHAR2,
    X_PRIMARY_FLAG                          IN     VARCHAR2,
    X_CONTENT_SOURCE_TYPE                   IN     VARCHAR2,
    X_START_DATE_ACTIVE                     IN     DATE,
    X_END_DATE_ACTIVE                       IN     DATE,
    X_CREATED_BY                            IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_STATUS                                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_RANK                                  IN     NUMBER,
    X_APPLICATION_ID                        IN     NUMBER,
    X_ACTUAL_CONTENT_SOURCE                 IN     VARCHAR2
);

PROCEDURE Select_Row (
    X_CODE_ASSIGNMENT_ID                    IN OUT NOCOPY NUMBER,
    X_OWNER_TABLE_NAME                      OUT NOCOPY    VARCHAR2,
    X_OWNER_TABLE_ID                        OUT NOCOPY    NUMBER,
    X_OWNER_TABLE_KEY_1                     OUT NOCOPY    VARCHAR2,
    X_OWNER_TABLE_KEY_2                     OUT NOCOPY    VARCHAR2,
    X_OWNER_TABLE_KEY_3                     OUT NOCOPY    VARCHAR2,
    X_OWNER_TABLE_KEY_4                     OUT NOCOPY    VARCHAR2,
    X_OWNER_TABLE_KEY_5                     OUT NOCOPY    VARCHAR2,
    X_CLASS_CATEGORY                        OUT NOCOPY    VARCHAR2,
    X_CLASS_CODE                            OUT NOCOPY    VARCHAR2,
    X_PRIMARY_FLAG                          OUT NOCOPY    VARCHAR2,
    X_CONTENT_SOURCE_TYPE                   OUT NOCOPY    VARCHAR2,
    X_START_DATE_ACTIVE                     OUT NOCOPY    DATE,
    X_END_DATE_ACTIVE                       OUT NOCOPY    DATE,
    X_STATUS                                OUT NOCOPY    VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_RANK                                  OUT NOCOPY    NUMBER,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER,
    X_ACTUAL_CONTENT_SOURCE                 OUT NOCOPY     VARCHAR2
);

PROCEDURE Delete_Row (
    X_CODE_ASSIGNMENT_ID                    IN     NUMBER
);

END HZ_CODE_ASSIGNMENTS_PKG;

 

/
