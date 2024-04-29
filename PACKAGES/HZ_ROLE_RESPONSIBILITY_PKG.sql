--------------------------------------------------------
--  DDL for Package HZ_ROLE_RESPONSIBILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ROLE_RESPONSIBILITY_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHCRRTS.pls 115.3 2002/11/21 19:48:38 sponnamb ship $ */

PROCEDURE Insert_Row (
    X_RESPONSIBILITY_ID                     IN OUT NOCOPY NUMBER,
    X_CUST_ACCOUNT_ROLE_ID                  IN     NUMBER,
    X_RESPONSIBILITY_TYPE                   IN     VARCHAR2,
    X_PRIMARY_FLAG                          IN     VARCHAR2,
    X_ATTRIBUTE_CATEGORY                    IN     VARCHAR2,
    X_ATTRIBUTE1                            IN     VARCHAR2,
    X_ATTRIBUTE2                            IN     VARCHAR2,
    X_ATTRIBUTE3                            IN     VARCHAR2,
    X_ATTRIBUTE4                            IN     VARCHAR2,
    X_ATTRIBUTE5                            IN     VARCHAR2,
    X_ATTRIBUTE6                            IN     VARCHAR2,
    X_ATTRIBUTE7                            IN     VARCHAR2,
    X_ATTRIBUTE8                            IN     VARCHAR2,
    X_ATTRIBUTE9                            IN     VARCHAR2,
    X_ATTRIBUTE10                           IN     VARCHAR2,
    X_ATTRIBUTE11                           IN     VARCHAR2,
    X_ATTRIBUTE12                           IN     VARCHAR2,
    X_ATTRIBUTE13                           IN     VARCHAR2,
    X_ATTRIBUTE14                           IN     VARCHAR2,
    X_ATTRIBUTE15                           IN     VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Update_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_RESPONSIBILITY_ID                     IN     NUMBER,
    X_CUST_ACCOUNT_ROLE_ID                  IN     NUMBER,
    X_RESPONSIBILITY_TYPE                   IN     VARCHAR2,
    X_PRIMARY_FLAG                          IN     VARCHAR2,
    X_ATTRIBUTE_CATEGORY                    IN     VARCHAR2,
    X_ATTRIBUTE1                            IN     VARCHAR2,
    X_ATTRIBUTE2                            IN     VARCHAR2,
    X_ATTRIBUTE3                            IN     VARCHAR2,
    X_ATTRIBUTE4                            IN     VARCHAR2,
    X_ATTRIBUTE5                            IN     VARCHAR2,
    X_ATTRIBUTE6                            IN     VARCHAR2,
    X_ATTRIBUTE7                            IN     VARCHAR2,
    X_ATTRIBUTE8                            IN     VARCHAR2,
    X_ATTRIBUTE9                            IN     VARCHAR2,
    X_ATTRIBUTE10                           IN     VARCHAR2,
    X_ATTRIBUTE11                           IN     VARCHAR2,
    X_ATTRIBUTE12                           IN     VARCHAR2,
    X_ATTRIBUTE13                           IN     VARCHAR2,
    X_ATTRIBUTE14                           IN     VARCHAR2,
    X_ATTRIBUTE15                           IN     VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Lock_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_RESPONSIBILITY_ID                     IN     NUMBER,
    X_CUST_ACCOUNT_ROLE_ID                  IN     NUMBER,
    X_RESPONSIBILITY_TYPE                   IN     VARCHAR2,
    X_PRIMARY_FLAG                          IN     VARCHAR2,
    X_CREATED_BY                            IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_REQUEST_ID                            IN     NUMBER,
    X_PROGRAM_APPLICATION_ID                IN     NUMBER,
    X_PROGRAM_ID                            IN     NUMBER,
    X_PROGRAM_UPDATE_DATE                   IN     DATE,
    X_ATTRIBUTE_CATEGORY                    IN     VARCHAR2,
    X_ATTRIBUTE1                            IN     VARCHAR2,
    X_ATTRIBUTE2                            IN     VARCHAR2,
    X_ATTRIBUTE3                            IN     VARCHAR2,
    X_ATTRIBUTE4                            IN     VARCHAR2,
    X_ATTRIBUTE5                            IN     VARCHAR2,
    X_ATTRIBUTE6                            IN     VARCHAR2,
    X_ATTRIBUTE7                            IN     VARCHAR2,
    X_ATTRIBUTE8                            IN     VARCHAR2,
    X_ATTRIBUTE9                            IN     VARCHAR2,
    X_ATTRIBUTE10                           IN     VARCHAR2,
    X_ATTRIBUTE11                           IN     VARCHAR2,
    X_ATTRIBUTE12                           IN     VARCHAR2,
    X_ATTRIBUTE13                           IN     VARCHAR2,
    X_ATTRIBUTE14                           IN     VARCHAR2,
    X_ATTRIBUTE15                           IN     VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Select_Row (
    X_RESPONSIBILITY_ID                     IN OUT NOCOPY NUMBER,
    X_CUST_ACCOUNT_ROLE_ID                  OUT NOCOPY    NUMBER,
    X_RESPONSIBILITY_TYPE                   OUT NOCOPY    VARCHAR2,
    X_PRIMARY_FLAG                          OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE_CATEGORY                    OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE1                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE2                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE3                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE4                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE5                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE6                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE7                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE8                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE9                            OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE10                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE11                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE12                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE13                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE14                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE15                           OUT NOCOPY    VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 OUT NOCOPY    VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER
);

PROCEDURE Delete_Row (
    X_RESPONSIBILITY_ID                     IN     NUMBER
);

END HZ_ROLE_RESPONSIBILITY_PKG;

 

/
