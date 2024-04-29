--------------------------------------------------------
--  DDL for Package HZ_CONTACT_PREFERENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CONTACT_PREFERENCES_PKG" AUTHID CURRENT_USER AS
/*$Header: ARH2CTTS.pls 115.1 2002/11/21 05:19:54 sponnamb noship $ */

PROCEDURE Insert_Row (
    X_Rowid                             IN OUT NOCOPY VARCHAR2,
    X_CONTACT_PREFERENCE_ID             IN OUT NOCOPY NUMBER,
    X_CONTACT_LEVEL_TABLE               IN     VARCHAR2,
    X_CONTACT_LEVEL_TABLE_ID            IN     NUMBER,
    X_CONTACT_TYPE          	        IN     VARCHAR2,
    X_PREFERENCE_CODE                   IN     VARCHAR2,
    X_PREFERENCE_TOPIC_TYPE             IN     VARCHAR2,
    X_PREFERENCE_TOPIC_TYPE_ID          IN     NUMBER,
    X_PREFERENCE_TOPIC_TYPE_CODE        IN     VARCHAR2,
    X_PREFERENCE_START_DATE             IN     DATE,
    X_PREFERENCE_END_DATE               IN     DATE,
    X_PREFERENCE_START_TIME_HR          IN     NUMBER,
    X_PREFERENCE_END_TIME_HR            IN     NUMBER,
    X_PREFERENCE_START_TIME_MI          IN     NUMBER,
    X_PREFERENCE_END_TIME_MI            IN     NUMBER,
    X_MAX_NO_OF_INTERACTIONS            IN     NUMBER,
    X_MAX_NO_OF_INTERACT_UOM_CODE       IN     VARCHAR2,
    X_REQUESTED_BY                      IN     VARCHAR2,
    X_REASON_CODE                       IN     VARCHAR2,
    X_STATUS                            IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER             IN     NUMBER,
    X_CREATED_BY_MODULE                 IN     VARCHAR2,
    X_APPLICATION_ID                    IN     NUMBER
);

PROCEDURE Update_Row (
    X_Rowid                             IN OUT NOCOPY VARCHAR2,
    X_CONTACT_PREFERENCE_ID             IN     NUMBER,
    X_CONTACT_LEVEL_TABLE               IN     VARCHAR2,
    X_CONTACT_LEVEL_TABLE_ID            IN     NUMBER,
    X_CONTACT_TYPE                      IN     VARCHAR2,
    X_PREFERENCE_CODE                   IN     VARCHAR2,
    X_PREFERENCE_TOPIC_TYPE             IN     VARCHAR2,
    X_PREFERENCE_TOPIC_TYPE_ID          IN     NUMBER,
    X_PREFERENCE_TOPIC_TYPE_CODE        IN     VARCHAR2,
    X_PREFERENCE_START_DATE             IN     DATE,
    X_PREFERENCE_END_DATE               IN     DATE,
    X_PREFERENCE_START_TIME_HR          IN     NUMBER,
    X_PREFERENCE_END_TIME_HR            IN     NUMBER,
    X_PREFERENCE_START_TIME_MI          IN     NUMBER,
    X_PREFERENCE_END_TIME_MI            IN     NUMBER,
    X_MAX_NO_OF_INTERACTIONS            IN     NUMBER,
    X_MAX_NO_OF_INTERACT_UOM_CODE       IN     VARCHAR2,
    X_REQUESTED_BY                      IN     VARCHAR2,
    X_REASON_CODE                       IN     VARCHAR2,
    X_STATUS                            IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER             IN     NUMBER,
    X_CREATED_BY_MODULE                 IN     VARCHAR2,
    X_APPLICATION_ID                    IN     NUMBER
);

PROCEDURE Lock_Row (
    X_Rowid                             IN OUT NOCOPY VARCHAR2,
    X_CONTACT_PREFERENCE_ID             IN     NUMBER,
    X_CONTACT_LEVEL_TABLE               IN     VARCHAR2,
    X_CONTACT_LEVEL_TABLE_ID            IN     NUMBER,
    X_CONTACT_TYPE                      IN     VARCHAR2,
    X_PREFERENCE_CODE                   IN     VARCHAR2,
    X_PREFERENCE_TOPIC_TYPE             IN     VARCHAR2,
    X_PREFERENCE_TOPIC_TYPE_ID          IN     NUMBER,
    X_PREFERENCE_TOPIC_TYPE_CODE        IN     VARCHAR2,
    X_PREFERENCE_START_DATE             IN     DATE,
    X_PREFERENCE_END_DATE               IN     DATE,
    X_PREFERENCE_START_TIME_HR          IN     NUMBER,
    X_PREFERENCE_END_TIME_HR            IN     NUMBER,
    X_PREFERENCE_START_TIME_MI          IN     NUMBER,
    X_PREFERENCE_END_TIME_MI            IN     NUMBER,
    X_MAX_NO_OF_INTERACTIONS            IN     NUMBER,
    X_MAX_NO_OF_INTERACT_UOM_CODE       IN     VARCHAR2,
    X_REQUESTED_BY                      IN     VARCHAR2,
    X_REASON_CODE                       IN     VARCHAR2,
    X_CREATED_BY                        IN     NUMBER,
    X_CREATION_DATE                     IN     DATE,
    X_LAST_UPDATE_LOGIN                 IN     NUMBER,
    X_LAST_UPDATE_DATE                  IN     DATE,
    X_LAST_UPDATED_BY                   IN     NUMBER,
    X_REQUEST_ID                        IN     NUMBER,
    X_PROGRAM_APPLICATION_ID            IN     NUMBER,
    X_PROGRAM_ID                        IN     NUMBER,
    X_PROGRAM_UPDATE_DATE               IN     DATE,
    X_STATUS                            IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER             IN     NUMBER,
    X_CREATED_BY_MODULE                 IN     VARCHAR2,
    X_APPLICATION_ID                    IN     NUMBER
);

PROCEDURE Select_Row (
    X_CONTACT_PREFERENCE_ID             IN OUT NOCOPY NUMBER,
    X_CONTACT_LEVEL_TABLE               OUT NOCOPY    VARCHAR2,
    X_CONTACT_LEVEL_TABLE_ID            OUT NOCOPY    NUMBER,
    X_CONTACT_TYPE                      OUT NOCOPY    VARCHAR2,
    X_PREFERENCE_CODE                   OUT NOCOPY    VARCHAR2,
    X_PREFERENCE_TOPIC_TYPE             OUT NOCOPY    VARCHAR2,
    X_PREFERENCE_TOPIC_TYPE_ID          OUT NOCOPY    NUMBER,
    X_PREFERENCE_TOPIC_TYPE_CODE        OUT NOCOPY    VARCHAR2,
    X_PREFERENCE_START_DATE             OUT NOCOPY    DATE,
    X_PREFERENCE_END_DATE               OUT NOCOPY    DATE,
    X_PREFERENCE_START_TIME_HR          OUT NOCOPY    NUMBER,
    X_PREFERENCE_END_TIME_HR            OUT NOCOPY    NUMBER,
    X_PREFERENCE_START_TIME_MI          OUT NOCOPY    NUMBER,
    X_PREFERENCE_END_TIME_MI            OUT NOCOPY    NUMBER,
    X_MAX_NO_OF_INTERACTIONS            OUT NOCOPY    NUMBER,
    X_MAX_NO_OF_INTERACT_UOM_CODE       OUT NOCOPY    VARCHAR2,
    X_REQUESTED_BY                      OUT NOCOPY    VARCHAR2,
    X_REASON_CODE                       OUT NOCOPY    VARCHAR2,
    X_STATUS                            OUT NOCOPY    VARCHAR2,
    X_CREATED_BY_MODULE                 OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                    OUT NOCOPY    NUMBER
);

PROCEDURE Delete_Row (
    X_CONTACT_PREFERENCE_ID             IN     NUMBER
);

END HZ_CONTACT_PREFERENCES_PKG;

 

/
