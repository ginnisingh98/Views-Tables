--------------------------------------------------------
--  DDL for Package HZ_PERSON_LANGUAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PERSON_LANGUAGE_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHPLATS.pls 115.5 2003/02/10 09:49:04 ssmohan ship $ */

PROCEDURE Insert_Row (
    X_LANGUAGE_USE_REFERENCE_ID             IN OUT NOCOPY NUMBER,
    X_LANGUAGE_NAME                         IN     VARCHAR2,
    X_PARTY_ID                              IN     NUMBER,
    X_NATIVE_LANGUAGE                       IN     VARCHAR2,
    X_PRIMARY_LANGUAGE_INDICATOR            IN     VARCHAR2,
    X_READS_LEVEL                           IN     VARCHAR2,
    X_SPEAKS_LEVEL                          IN     VARCHAR2,
    X_WRITES_LEVEL                          IN     VARCHAR2,
    X_SPOKEN_COMPREHENSION_LEVEL            IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);


PROCEDURE Update_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_LANGUAGE_USE_REFERENCE_ID             IN     NUMBER,
    X_LANGUAGE_NAME                         IN     VARCHAR2,
    X_PARTY_ID                              IN     NUMBER,
    X_NATIVE_LANGUAGE                       IN     VARCHAR2,
    X_PRIMARY_LANGUAGE_INDICATOR            IN     VARCHAR2,
    X_READS_LEVEL                           IN     VARCHAR2,
    X_SPEAKS_LEVEL                          IN     VARCHAR2,
    X_WRITES_LEVEL                          IN     VARCHAR2,
    X_SPOKEN_COMPREHENSION_LEVEL            IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);


PROCEDURE Lock_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_LANGUAGE_USE_REFERENCE_ID             IN     NUMBER,
    X_LANGUAGE_NAME                         IN     VARCHAR2,
    X_PARTY_ID                              IN     NUMBER,
    X_NATIVE_LANGUAGE                       IN     VARCHAR2,
    X_PRIMARY_LANGUAGE_INDICATOR            IN     VARCHAR2,
    X_READS_LEVEL                           IN     VARCHAR2,
    X_SPEAKS_LEVEL                          IN     VARCHAR2,
    X_WRITES_LEVEL                          IN     VARCHAR2,
    X_SPOKEN_COMPREHENSION_LEVEL            IN     VARCHAR2,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_CREATED_BY                            IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_REQUEST_ID                            IN     NUMBER,
    X_PROGRAM_APPLICATION_ID                IN     NUMBER,
    X_PROGRAM_ID                            IN     NUMBER,
    X_PROGRAM_UPDATE_DATE                   IN     DATE,
    X_STATUS                                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);


PROCEDURE Select_Row (
    X_LANGUAGE_USE_REFERENCE_ID             IN OUT NOCOPY NUMBER,
    X_LANGUAGE_NAME                         OUT NOCOPY    VARCHAR2,
    X_PARTY_ID                              OUT NOCOPY    NUMBER,
    X_NATIVE_LANGUAGE                       OUT NOCOPY    VARCHAR2,
    X_PRIMARY_LANGUAGE_INDICATOR            OUT NOCOPY    VARCHAR2,
    X_READS_LEVEL                           OUT NOCOPY    VARCHAR2,
    X_SPEAKS_LEVEL                          OUT NOCOPY    VARCHAR2,
    X_WRITES_LEVEL                          OUT NOCOPY    VARCHAR2,
    X_SPOKEN_COMPREHENSION_LEVEL            OUT NOCOPY    VARCHAR2,
    X_STATUS                                OUT NOCOPY    VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER
);


PROCEDURE Delete_Row (
    X_LANGUAGE_USE_REFERENCE_ID             IN     NUMBER
);


END HZ_PERSON_LANGUAGE_PKG;

 

/
