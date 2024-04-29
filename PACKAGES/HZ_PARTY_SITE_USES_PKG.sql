--------------------------------------------------------
--  DDL for Package HZ_PARTY_SITE_USES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_SITE_USES_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHPSUTS.pls 115.6 2002/11/21 19:42:04 sponnamb ship $ */

PROCEDURE Insert_Row (
    X_PARTY_SITE_USE_ID                     IN OUT NOCOPY NUMBER,
    X_COMMENTS                              IN     VARCHAR2,
    X_PARTY_SITE_ID                         IN     NUMBER,
    X_SITE_USE_TYPE                         IN     VARCHAR2,
    X_PRIMARY_PER_TYPE                      IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Update_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_PARTY_SITE_USE_ID                     IN     NUMBER,
    X_COMMENTS                              IN     VARCHAR2,
    X_PARTY_SITE_ID                         IN     NUMBER,
    X_SITE_USE_TYPE                         IN     VARCHAR2,
    X_PRIMARY_PER_TYPE                      IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Lock_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_PARTY_SITE_USE_ID                     IN     NUMBER,
    X_COMMENTS                              IN     VARCHAR2,
    X_PARTY_SITE_ID                         IN     NUMBER,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_REQUEST_ID                            IN     NUMBER,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_PROGRAM_APPLICATION_ID                IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_PROGRAM_ID                            IN     NUMBER,
    X_CREATED_BY                            IN     NUMBER,
    X_PROGRAM_UPDATE_DATE                   IN     DATE,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_SITE_USE_TYPE                         IN     VARCHAR2,
    X_PRIMARY_PER_TYPE                      IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Select_Row (
    X_PARTY_SITE_USE_ID                     IN OUT NOCOPY NUMBER,
    X_COMMENTS                              OUT NOCOPY    VARCHAR2,
    X_PARTY_SITE_ID                         OUT NOCOPY    NUMBER,
    X_SITE_USE_TYPE                         OUT NOCOPY    VARCHAR2,
    X_PRIMARY_PER_TYPE                      OUT NOCOPY    VARCHAR2,
    X_STATUS                                OUT NOCOPY    VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER
);

PROCEDURE Delete_Row (
    X_PARTY_SITE_USE_ID                     IN     NUMBER
);

END HZ_PARTY_SITE_USES_PKG;

 

/
