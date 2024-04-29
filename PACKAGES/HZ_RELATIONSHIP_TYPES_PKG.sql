--------------------------------------------------------
--  DDL for Package HZ_RELATIONSHIP_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_RELATIONSHIP_TYPES_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHRLTTS.pls 115.5 2002/11/21 20:38:04 sponnamb noship $ */

PROCEDURE Insert_Row (
    X_RELATIONSHIP_TYPE_ID                  IN OUT NOCOPY NUMBER,
    X_RELATIONSHIP_TYPE                     IN     VARCHAR2,
    X_FORWARD_REL_CODE                      IN     VARCHAR2,
    X_BACKWARD_REL_CODE                     IN     VARCHAR2,
    X_DIRECTION_CODE                        IN     VARCHAR2,
    X_HIERARCHICAL_FLAG                     IN     VARCHAR2,
    X_CREATE_PARTY_FLAG                     IN     VARCHAR2,
    X_ALLOW_RELATE_TO_SELF_FLAG             IN     VARCHAR2,
    X_SUBJECT_TYPE                          IN     VARCHAR2,
    X_OBJECT_TYPE                           IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_ALLOW_CIRCULAR_RELATIONSHIPS          IN     VARCHAR2,
    X_MULTIPLE_PARENT_ALLOWED               IN     VARCHAR2,
    X_INCL_UNRELATED_ENTITIES               IN     VARCHAR2,
    X_ROLE                		    IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Update_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_RELATIONSHIP_TYPE_ID                  IN     NUMBER,
    X_RELATIONSHIP_TYPE                     IN     VARCHAR2,
    X_FORWARD_REL_CODE                      IN     VARCHAR2,
    X_BACKWARD_REL_CODE                     IN     VARCHAR2,
    X_DIRECTION_CODE                        IN     VARCHAR2,
    X_HIERARCHICAL_FLAG                     IN     VARCHAR2,
    X_CREATE_PARTY_FLAG                     IN     VARCHAR2,
    X_ALLOW_RELATE_TO_SELF_FLAG             IN     VARCHAR2,
    X_SUBJECT_TYPE                          IN     VARCHAR2,
    X_OBJECT_TYPE                           IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_ALLOW_CIRCULAR_RELATIONSHIPS          IN     VARCHAR2,
    X_MULTIPLE_PARENT_ALLOWED               IN     VARCHAR2,
    X_INCL_UNRELATED_ENTITIES               IN     VARCHAR2,
    X_ROLE                                  IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Lock_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_RELATIONSHIP_TYPE_ID                  IN     NUMBER,
    X_RELATIONSHIP_TYPE                     IN     VARCHAR2,
    X_FORWARD_REL_CODE                      IN     VARCHAR2,
    X_BACKWARD_REL_CODE                     IN     VARCHAR2,
    X_DIRECTION_CODE                        IN     VARCHAR2,
    X_HIERARCHICAL_FLAG                     IN     VARCHAR2,
    X_CREATE_PARTY_FLAG                     IN     VARCHAR2,
    X_ALLOW_RELATE_TO_SELF_FLAG             IN     VARCHAR2,
    X_SUBJECT_TYPE                          IN     VARCHAR2,
    X_OBJECT_TYPE                           IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_CREATED_BY                            IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_ALLOW_CIRCULAR_RELATIONSHIPS          IN     VARCHAR2,
    X_MULTIPLE_PARENT_ALLOWED               IN     VARCHAR2,
    X_INCL_UNRELATED_ENTITIES               IN     VARCHAR2,
    X_ROLE                IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Select_Row (
    X_RELATIONSHIP_TYPE_ID                  IN OUT NOCOPY NUMBER,
    X_RELATIONSHIP_TYPE                     OUT NOCOPY    VARCHAR2,
    X_FORWARD_REL_CODE                      OUT NOCOPY    VARCHAR2,
    X_BACKWARD_REL_CODE                     OUT NOCOPY    VARCHAR2,
    X_DIRECTION_CODE                        OUT NOCOPY    VARCHAR2,
    X_HIERARCHICAL_FLAG                     OUT NOCOPY    VARCHAR2,
    X_CREATE_PARTY_FLAG                     OUT NOCOPY    VARCHAR2,
    X_ALLOW_RELATE_TO_SELF_FLAG             OUT NOCOPY    VARCHAR2,
    X_SUBJECT_TYPE                          OUT NOCOPY    VARCHAR2,
    X_OBJECT_TYPE                           OUT NOCOPY    VARCHAR2,
    X_STATUS                                OUT NOCOPY    VARCHAR2,
    X_ALLOW_CIRCULAR_RELATIONSHIPS          OUT NOCOPY    VARCHAR2,
    X_MULTIPLE_PARENT_ALLOWED               OUT NOCOPY    VARCHAR2,
    X_INCL_UNRELATED_ENTITIES               OUT NOCOPY    VARCHAR2,
    X_ROLE                OUT NOCOPY    VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER
);

PROCEDURE Delete_Row (
    X_RELATIONSHIP_TYPE_ID                  IN     NUMBER
);

END HZ_RELATIONSHIP_TYPES_PKG;

 

/
