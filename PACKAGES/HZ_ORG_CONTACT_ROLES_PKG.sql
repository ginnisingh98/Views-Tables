--------------------------------------------------------
--  DDL for Package HZ_ORG_CONTACT_ROLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_ORG_CONTACT_ROLES_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHOCRTS.pls 115.6 2002/11/21 19:39:25 sponnamb ship $ */

PROCEDURE Insert_Row (
    X_ORG_CONTACT_ROLE_ID                   IN OUT NOCOPY NUMBER,
    X_ORG_CONTACT_ID                        IN     NUMBER,
    X_ROLE_TYPE                             IN     VARCHAR2,
    X_ROLE_LEVEL                            IN     VARCHAR2,
    X_PRIMARY_FLAG                          IN     VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 IN     VARCHAR2,
    X_PRIMARY_CON_PER_ROLE_TYPE             IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Update_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_ORG_CONTACT_ROLE_ID                   IN     NUMBER,
    X_ORG_CONTACT_ID                        IN     NUMBER,
    X_ROLE_TYPE                             IN     VARCHAR2,
    X_ROLE_LEVEL                            IN     VARCHAR2,
    X_PRIMARY_FLAG                          IN     VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 IN     VARCHAR2,
    X_PRIMARY_CON_PER_ROLE_TYPE             IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Lock_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_ORG_CONTACT_ROLE_ID                   IN     NUMBER,
    X_ORG_CONTACT_ID                        IN     NUMBER,
    X_ROLE_TYPE                             IN     VARCHAR2,
    X_CREATED_BY                            IN     NUMBER,
    X_ROLE_LEVEL                            IN     VARCHAR2,
    X_PRIMARY_FLAG                          IN     VARCHAR2,
    X_CREATION_DATE                         IN     DATE,
    X_ORIG_SYSTEM_REFERENCE                 IN     VARCHAR2,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_REQUEST_ID                            IN     NUMBER,
    X_PROGRAM_APPLICATION_ID                IN     NUMBER,
    X_PROGRAM_ID                            IN     NUMBER,
    X_PROGRAM_UPDATE_DATE                   IN     DATE,
    X_PRIMARY_CON_PER_ROLE_TYPE             IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Select_Row (
    X_ORG_CONTACT_ROLE_ID                   IN OUT NOCOPY NUMBER,
    X_ORG_CONTACT_ID                        OUT NOCOPY    NUMBER,
    X_ROLE_TYPE                             OUT NOCOPY    VARCHAR2,
    X_ROLE_LEVEL                            OUT NOCOPY    VARCHAR2,
    X_PRIMARY_FLAG                          OUT NOCOPY    VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 OUT NOCOPY    VARCHAR2,
    X_PRIMARY_CON_PER_ROLE_TYPE             OUT NOCOPY    VARCHAR2,
    X_STATUS                                OUT NOCOPY    VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER
);

PROCEDURE Delete_Row (
    X_ORG_CONTACT_ROLE_ID                   IN     NUMBER
);

END HZ_ORG_CONTACT_ROLES_PKG;

 

/
