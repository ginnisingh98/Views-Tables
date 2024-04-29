--------------------------------------------------------
--  DDL for Package HZ_CLASS_CATEGORY_USES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CLASS_CATEGORY_USES_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHCAUTS.pls 115.4 2002/11/21 21:07:33 sponnamb ship $ */

PROCEDURE Insert_Row (
    X_CLASS_CATEGORY                        IN     VARCHAR2,
    X_OWNER_TABLE                           IN     VARCHAR2,
    X_COLUMN_NAME                           IN     VARCHAR2,
    X_ADDITIONAL_WHERE_CLAUSE               IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Update_Row (
    X_CLASS_CATEGORY                        IN     VARCHAR2,
    X_OWNER_TABLE                           IN     VARCHAR2,
    X_COLUMN_NAME                           IN     VARCHAR2,
    X_ADDITIONAL_WHERE_CLAUSE               IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Lock_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_CLASS_CATEGORY                        IN     VARCHAR2,
    X_OWNER_TABLE                           IN     VARCHAR2,
    X_COLUMN_NAME                           IN     VARCHAR2,
    X_ADDITIONAL_WHERE_CLAUSE               IN     VARCHAR2,
    X_CREATED_BY                            IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Select_Row (
    X_CLASS_CATEGORY                        IN OUT NOCOPY VARCHAR2,
    X_OWNER_TABLE                           IN OUT NOCOPY VARCHAR2,
    X_COLUMN_NAME                           OUT NOCOPY    VARCHAR2,
    X_ADDITIONAL_WHERE_CLAUSE               OUT NOCOPY    VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER
);

PROCEDURE Delete_Row (
    X_CLASS_CATEGORY                        IN     VARCHAR2,
    X_OWNER_TABLE                           IN     VARCHAR2
);

END HZ_CLASS_CATEGORY_USES_PKG;

 

/
