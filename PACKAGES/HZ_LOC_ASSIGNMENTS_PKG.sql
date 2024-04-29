--------------------------------------------------------
--  DDL for Package HZ_LOC_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_LOC_ASSIGNMENTS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHTLATS.pls 115.2 2002/11/21 19:44:17 sponnamb ship $ */

PROCEDURE Insert_Row (
    X_LOCATION_ID                           IN     NUMBER,
    X_LOC_ID                                IN     NUMBER,
    X_ORG_ID                                IN     NUMBER,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Update_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_LOCATION_ID                           IN     NUMBER,
    X_LOC_ID                                IN     NUMBER,
    X_ORG_ID                                IN     NUMBER,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Lock_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_LOCATION_ID                           IN     NUMBER,
    X_LOC_ID                                IN     NUMBER,
    X_ORG_ID                                IN     NUMBER,
    X_CREATED_BY                            IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_REQUEST_ID                            IN     NUMBER,
    X_PROGRAM_APPLICATION_ID                IN     NUMBER,
    X_PROGRAM_ID                            IN     NUMBER,
    X_PROGRAM_UPDATE_DATE                   IN     DATE,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Select_Row (
    X_LOCATION_ID                           IN OUT NOCOPY NUMBER,
    X_ORG_ID                                IN OUT NOCOPY NUMBER,
    X_LOC_ID                                OUT NOCOPY    NUMBER,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER
);

PROCEDURE Delete_Row (
    X_LOCATION_ID                           IN     NUMBER
);

END HZ_LOC_ASSIGNMENTS_PKG;

 

/
