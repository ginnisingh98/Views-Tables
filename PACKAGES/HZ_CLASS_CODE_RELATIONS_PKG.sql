--------------------------------------------------------
--  DDL for Package HZ_CLASS_CODE_RELATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CLASS_CODE_RELATIONS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHCCRTS.pls 115.2 2002/11/21 19:37:50 sponnamb ship $ */

PROCEDURE Insert_Row (
    X_CLASS_CATEGORY                        IN     VARCHAR2,
    X_CLASS_CODE                            IN     VARCHAR2,
    X_SUB_CLASS_CODE                        IN     VARCHAR2,
    X_START_DATE_ACTIVE                     IN     DATE,
    X_END_DATE_ACTIVE                       IN     DATE,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Update_Row (
    X_CLASS_CATEGORY                        IN     VARCHAR2,
    X_CLASS_CODE                            IN     VARCHAR2,
    X_SUB_CLASS_CODE                        IN     VARCHAR2,
    X_START_DATE_ACTIVE                     IN     DATE,
    X_END_DATE_ACTIVE                       IN     DATE,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Lock_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_CLASS_CATEGORY                        IN     VARCHAR2,
    X_CLASS_CODE                            IN     VARCHAR2,
    X_SUB_CLASS_CODE                        IN     VARCHAR2,
    X_START_DATE_ACTIVE                     IN     DATE,
    X_END_DATE_ACTIVE                       IN     DATE,
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
    X_CLASS_CODE                            IN OUT NOCOPY VARCHAR2,
    X_SUB_CLASS_CODE                        IN OUT NOCOPY VARCHAR2,
    X_START_DATE_ACTIVE                     IN OUT NOCOPY DATE,
    X_END_DATE_ACTIVE                       OUT NOCOPY    DATE,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER
);

PROCEDURE Delete_Row (
    X_CLASS_CATEGORY                        IN     VARCHAR2,
    X_CLASS_CODE                            IN     VARCHAR2,
    X_SUB_CLASS_CODE                        IN     VARCHAR2,
    X_START_DATE_ACTIVE                     IN     DATE
);

END HZ_CLASS_CODE_RELATIONS_PKG;

 

/
