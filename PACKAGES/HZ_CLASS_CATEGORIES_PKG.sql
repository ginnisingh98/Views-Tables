--------------------------------------------------------
--  DDL for Package HZ_CLASS_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CLASS_CATEGORIES_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHCSCTS.pls 115.5 2002/11/21 20:33:28 sponnamb ship $ */

PROCEDURE Insert_Row (
    X_CLASS_CATEGORY                        IN     VARCHAR2,
    X_ALLOW_MULTI_PARENT_FLAG               IN     VARCHAR2,
    X_ALLOW_MULTI_ASSIGN_FLAG               IN     VARCHAR2,
    X_ALLOW_LEAF_NODE_ONLY_FLAG             IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER,
    X_DELIMITER				    IN     VARCHAR2
);

PROCEDURE Update_Row (
    X_CLASS_CATEGORY                        IN     VARCHAR2,
    X_ALLOW_MULTI_PARENT_FLAG               IN     VARCHAR2,
    X_ALLOW_MULTI_ASSIGN_FLAG               IN     VARCHAR2,
    X_ALLOW_LEAF_NODE_ONLY_FLAG             IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER,
    X_DELIMITER				    IN     VARCHAR2
);

PROCEDURE Lock_Row (
    X_CLASS_CATEGORY                        IN     VARCHAR2,
    X_ALLOW_MULTI_PARENT_FLAG               IN     VARCHAR2,
    X_ALLOW_MULTI_ASSIGN_FLAG               IN     VARCHAR2,
    X_CREATED_BY                            IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_ALLOW_LEAF_NODE_ONLY_FLAG             IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER,
    X_DELIMITER				    IN     VARCHAR2
);

PROCEDURE Select_Row (
    X_CLASS_CATEGORY                        IN OUT NOCOPY VARCHAR2,
    X_ALLOW_MULTI_PARENT_FLAG               OUT NOCOPY    VARCHAR2,
    X_ALLOW_MULTI_ASSIGN_FLAG               OUT NOCOPY    VARCHAR2,
    X_ALLOW_LEAF_NODE_ONLY_FLAG             OUT NOCOPY    VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER,
    X_DELIMITER				    OUT NOCOPY    VARCHAR2
);

PROCEDURE Delete_Row (
    X_CLASS_CATEGORY                        IN     VARCHAR2
);

END HZ_CLASS_CATEGORIES_PKG;

 

/
