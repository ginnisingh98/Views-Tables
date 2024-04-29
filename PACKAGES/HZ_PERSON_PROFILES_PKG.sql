--------------------------------------------------------
--  DDL for Package HZ_PERSON_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PERSON_PROFILES_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHPERTS.pls 115.17 2003/09/03 20:55:12 kttang ship $ */

PROCEDURE Insert_Row (
    X_ROWID                                 OUT NOCOPY    ROWID,
    X_PERSON_PROFILE_ID                     IN OUT NOCOPY NUMBER,
    X_PARTY_ID                              IN     NUMBER,
    X_PERSON_NAME                           IN     VARCHAR2,
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
    X_ATTRIBUTE16                           IN     VARCHAR2,
    X_ATTRIBUTE17                           IN     VARCHAR2,
    X_ATTRIBUTE18                           IN     VARCHAR2,
    X_ATTRIBUTE19                           IN     VARCHAR2,
    X_ATTRIBUTE20                           IN     VARCHAR2,
    X_INTERNAL_FLAG                         IN     VARCHAR2,
    X_PERSON_PRE_NAME_ADJUNCT               IN     VARCHAR2,
    X_PERSON_FIRST_NAME                     IN     VARCHAR2,
    X_PERSON_MIDDLE_NAME                    IN     VARCHAR2,
    X_PERSON_LAST_NAME                      IN     VARCHAR2,
    X_PERSON_NAME_SUFFIX                    IN     VARCHAR2,
    X_PERSON_TITLE                          IN     VARCHAR2,
    X_PERSON_ACADEMIC_TITLE                 IN     VARCHAR2,
    X_PERSON_PREVIOUS_LAST_NAME             IN     VARCHAR2,
    X_PERSON_INITIALS                       IN     VARCHAR2,
    X_KNOWN_AS                              IN     VARCHAR2,
    X_PERSON_NAME_PHONETIC                  IN     VARCHAR2,
    X_PERSON_FIRST_NAME_PHONETIC            IN     VARCHAR2,
    X_PERSON_LAST_NAME_PHONETIC             IN     VARCHAR2,
    X_TAX_REFERENCE                         IN     VARCHAR2,
    X_JGZZ_FISCAL_CODE                      IN     VARCHAR2,
    X_PERSON_IDEN_TYPE                      IN     VARCHAR2,
    X_PERSON_IDENTIFIER                     IN     VARCHAR2,
    X_DATE_OF_BIRTH                         IN     DATE,
    X_PLACE_OF_BIRTH                        IN     VARCHAR2,
    X_DATE_OF_DEATH                         IN     DATE,
    X_DECEASED_FLAG                         IN     VARCHAR2,
    X_GENDER                                IN     VARCHAR2,
    X_DECLARED_ETHNICITY                    IN     VARCHAR2,
    X_MARITAL_STATUS                        IN     VARCHAR2,
    X_MARITAL_STATUS_EFF_DATE               IN     DATE,
    X_PERSONAL_INCOME                       IN     NUMBER,
    X_HEAD_OF_HOUSEHOLD_FLAG                IN     VARCHAR2,
    X_HOUSEHOLD_INCOME                      IN     NUMBER,
    X_HOUSEHOLD_SIZE                        IN     NUMBER,
    X_RENT_OWN_IND                          IN     VARCHAR2,
    X_LAST_KNOWN_GPS                        IN     VARCHAR2,
    X_EFFECTIVE_START_DATE                  IN     DATE,
    X_EFFECTIVE_END_DATE                    IN     DATE,
    X_CONTENT_SOURCE_TYPE                   IN     VARCHAR2,
    X_KNOWN_AS2                             IN     VARCHAR2,
    X_KNOWN_AS3                             IN     VARCHAR2,
    X_KNOWN_AS4                             IN     VARCHAR2,
    X_KNOWN_AS5                             IN     VARCHAR2,
    X_MIDDLE_NAME_PHONETIC                  IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER,
    X_ACTUAL_CONTENT_SOURCE                 IN     VARCHAR2,
    X_VERSION_NUMBER			    IN     NUMBER DEFAULT 1
);

PROCEDURE Update_Row (
    X_ROWID                                 IN OUT NOCOPY VARCHAR2,
    X_PERSON_PROFILE_ID                     IN     NUMBER,
    X_PARTY_ID                              IN     NUMBER,
    X_PERSON_NAME                           IN     VARCHAR2,
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
    X_ATTRIBUTE16                           IN     VARCHAR2,
    X_ATTRIBUTE17                           IN     VARCHAR2,
    X_ATTRIBUTE18                           IN     VARCHAR2,
    X_ATTRIBUTE19                           IN     VARCHAR2,
    X_ATTRIBUTE20                           IN     VARCHAR2,
    X_INTERNAL_FLAG                         IN     VARCHAR2,
    X_PERSON_PRE_NAME_ADJUNCT               IN     VARCHAR2,
    X_PERSON_FIRST_NAME                     IN     VARCHAR2,
    X_PERSON_MIDDLE_NAME                    IN     VARCHAR2,
    X_PERSON_LAST_NAME                      IN     VARCHAR2,
    X_PERSON_NAME_SUFFIX                    IN     VARCHAR2,
    X_PERSON_TITLE                          IN     VARCHAR2,
    X_PERSON_ACADEMIC_TITLE                 IN     VARCHAR2,
    X_PERSON_PREVIOUS_LAST_NAME             IN     VARCHAR2,
    X_PERSON_INITIALS                       IN     VARCHAR2,
    X_KNOWN_AS                              IN     VARCHAR2,
    X_PERSON_NAME_PHONETIC                  IN     VARCHAR2,
    X_PERSON_FIRST_NAME_PHONETIC            IN     VARCHAR2,
    X_PERSON_LAST_NAME_PHONETIC             IN     VARCHAR2,
    X_TAX_REFERENCE                         IN     VARCHAR2,
    X_JGZZ_FISCAL_CODE                      IN     VARCHAR2,
    X_PERSON_IDEN_TYPE                      IN     VARCHAR2,
    X_PERSON_IDENTIFIER                     IN     VARCHAR2,
    X_DATE_OF_BIRTH                         IN     DATE,
    X_PLACE_OF_BIRTH                        IN     VARCHAR2,
    X_DATE_OF_DEATH                         IN     DATE,
    X_DECEASED_FLAG                         IN     VARCHAR2 DEFAULT NULL,
    X_GENDER                                IN     VARCHAR2,
    X_DECLARED_ETHNICITY                    IN     VARCHAR2,
    X_MARITAL_STATUS                        IN     VARCHAR2,
    X_MARITAL_STATUS_EFF_DATE               IN     DATE,
    X_PERSONAL_INCOME                       IN     NUMBER,
    X_HEAD_OF_HOUSEHOLD_FLAG                IN     VARCHAR2,
    X_HOUSEHOLD_INCOME                      IN     NUMBER,
    X_HOUSEHOLD_SIZE                        IN     NUMBER,
    X_RENT_OWN_IND                          IN     VARCHAR2,
    X_LAST_KNOWN_GPS                        IN     VARCHAR2,
    X_EFFECTIVE_START_DATE                  IN     DATE,
    X_EFFECTIVE_END_DATE                    IN     DATE,
    X_CONTENT_SOURCE_TYPE                   IN     VARCHAR2,
    X_KNOWN_AS2                             IN     VARCHAR2,
    X_KNOWN_AS3                             IN     VARCHAR2,
    X_KNOWN_AS4                             IN     VARCHAR2,
    X_KNOWN_AS5                             IN     VARCHAR2,
    X_MIDDLE_NAME_PHONETIC                  IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER,
    X_ACTUAL_CONTENT_SOURCE                 IN     VARCHAR2 DEFAULT NULL,
    X_VERSION_NUMBER			    IN     NUMBER DEFAULT NULL
);

PROCEDURE Lock_Row (
    X_ROWID                                 IN OUT NOCOPY VARCHAR2,
    X_PERSON_PROFILE_ID                     IN     NUMBER,
    X_PARTY_ID                              IN     NUMBER,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_CREATED_BY                            IN     NUMBER,
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
    X_ATTRIBUTE16                           IN     VARCHAR2,
    X_ATTRIBUTE17                           IN     VARCHAR2,
    X_ATTRIBUTE18                           IN     VARCHAR2,
    X_ATTRIBUTE19                           IN     VARCHAR2,
    X_ATTRIBUTE20                           IN     VARCHAR2,
    X_INTERNAL_FLAG                         IN     VARCHAR2,
    X_PERSON_PRE_NAME_ADJUNCT               IN     VARCHAR2,
    X_PERSON_FIRST_NAME                     IN     VARCHAR2,
    X_PERSON_MIDDLE_NAME                    IN     VARCHAR2,
    X_PERSON_LAST_NAME                      IN     VARCHAR2,
    X_PERSON_NAME_SUFFIX                    IN     VARCHAR2,
    X_PERSON_TITLE                          IN     VARCHAR2,
    X_PERSON_ACADEMIC_TITLE                 IN     VARCHAR2,
    X_PERSON_PREVIOUS_LAST_NAME             IN     VARCHAR2,
    X_PERSON_INITIALS                       IN     VARCHAR2,
    X_KNOWN_AS                              IN     VARCHAR2,
    X_PERSON_NAME_PHONETIC                  IN     VARCHAR2,
    X_PERSON_FIRST_NAME_PHONETIC            IN     VARCHAR2,
    X_PERSON_LAST_NAME_PHONETIC             IN     VARCHAR2,
    X_TAX_REFERENCE                         IN     VARCHAR2,
    X_JGZZ_FISCAL_CODE                      IN     VARCHAR2,
    X_PERSON_IDEN_TYPE                      IN     VARCHAR2,
    X_PERSON_IDENTIFIER                     IN     VARCHAR2,
    X_DATE_OF_BIRTH                         IN     DATE,
    X_PLACE_OF_BIRTH                        IN     VARCHAR2,
    X_DATE_OF_DEATH                         IN     DATE,
    X_DECEASED_FLAG                         IN     VARCHAR2,
    X_GENDER                                IN     VARCHAR2,
    X_DECLARED_ETHNICITY                    IN     VARCHAR2,
    X_MARITAL_STATUS                        IN     VARCHAR2,
    X_MARITAL_STATUS_EFF_DATE               IN     DATE,
    X_PERSONAL_INCOME                       IN     NUMBER,
    X_HEAD_OF_HOUSEHOLD_FLAG                IN     VARCHAR2,
    X_HOUSEHOLD_INCOME                      IN     NUMBER,
    X_HOUSEHOLD_SIZE                        IN     NUMBER,
    X_RENT_OWN_IND                          IN     VARCHAR2,
    X_LAST_KNOWN_GPS                        IN     VARCHAR2,
    X_EFFECTIVE_START_DATE                  IN     DATE,
    X_EFFECTIVE_END_DATE                    IN     DATE,
    X_CONTENT_SOURCE_TYPE                   IN     VARCHAR2,
    X_KNOWN_AS2                             IN     VARCHAR2,
    X_KNOWN_AS3                             IN     VARCHAR2,
    X_KNOWN_AS4                             IN     VARCHAR2,
    X_KNOWN_AS5                             IN     VARCHAR2,
    X_MIDDLE_NAME_PHONETIC                  IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER,
    X_ACTUAL_CONTENT_SOURCE                 IN     VARCHAR2 DEFAULT NULL
);

PROCEDURE Select_Row (
    X_PERSON_PROFILE_ID                     IN OUT NOCOPY NUMBER,
    X_PARTY_ID                              OUT NOCOPY    NUMBER,
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
    X_ATTRIBUTE16                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE17                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE18                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE19                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE20                           OUT NOCOPY    VARCHAR2,
    X_INTERNAL_FLAG                         OUT NOCOPY    VARCHAR2,
    X_PERSON_PRE_NAME_ADJUNCT               OUT NOCOPY    VARCHAR2,
    X_PERSON_FIRST_NAME                     OUT NOCOPY    VARCHAR2,
    X_PERSON_MIDDLE_NAME                    OUT NOCOPY    VARCHAR2,
    X_PERSON_LAST_NAME                      OUT NOCOPY    VARCHAR2,
    X_PERSON_NAME_SUFFIX                    OUT NOCOPY    VARCHAR2,
    X_PERSON_TITLE                          OUT NOCOPY    VARCHAR2,
    X_PERSON_ACADEMIC_TITLE                 OUT NOCOPY    VARCHAR2,
    X_PERSON_PREVIOUS_LAST_NAME             OUT NOCOPY    VARCHAR2,
    X_PERSON_INITIALS                       OUT NOCOPY    VARCHAR2,
    X_KNOWN_AS                              OUT NOCOPY    VARCHAR2,
    X_PERSON_NAME_PHONETIC                  OUT NOCOPY    VARCHAR2,
    X_PERSON_FIRST_NAME_PHONETIC            OUT NOCOPY    VARCHAR2,
    X_PERSON_LAST_NAME_PHONETIC             OUT NOCOPY    VARCHAR2,
    X_TAX_REFERENCE                         OUT NOCOPY    VARCHAR2,
    X_JGZZ_FISCAL_CODE                      OUT NOCOPY    VARCHAR2,
    X_PERSON_IDEN_TYPE                      OUT NOCOPY    VARCHAR2,
    X_PERSON_IDENTIFIER                     OUT NOCOPY    VARCHAR2,
    X_DATE_OF_BIRTH                         OUT NOCOPY    DATE,
    X_PLACE_OF_BIRTH                        OUT NOCOPY    VARCHAR2,
    X_DATE_OF_DEATH                         OUT NOCOPY    DATE,
    X_DECEASED_FLAG                         OUT NOCOPY    VARCHAR2,
    X_GENDER                                OUT NOCOPY    VARCHAR2,
    X_DECLARED_ETHNICITY                    OUT NOCOPY    VARCHAR2,
    X_MARITAL_STATUS                        OUT NOCOPY    VARCHAR2,
    X_MARITAL_STATUS_EFF_DATE               OUT NOCOPY    DATE,
    X_PERSONAL_INCOME                       OUT NOCOPY    NUMBER,
    X_HEAD_OF_HOUSEHOLD_FLAG                OUT NOCOPY    VARCHAR2,
    X_HOUSEHOLD_INCOME                      OUT NOCOPY    NUMBER,
    X_HOUSEHOLD_SIZE                        OUT NOCOPY    NUMBER,
    X_RENT_OWN_IND                          OUT NOCOPY    VARCHAR2,
    X_LAST_KNOWN_GPS                        OUT NOCOPY    VARCHAR2,
    X_EFFECTIVE_START_DATE                  OUT NOCOPY    DATE,
    X_EFFECTIVE_END_DATE                    OUT NOCOPY    DATE,
    X_CONTENT_SOURCE_TYPE                   OUT NOCOPY    VARCHAR2,
    X_KNOWN_AS2                             OUT NOCOPY    VARCHAR2,
    X_KNOWN_AS3                             OUT NOCOPY    VARCHAR2,
    X_KNOWN_AS4                             OUT NOCOPY    VARCHAR2,
    X_KNOWN_AS5                             OUT NOCOPY    VARCHAR2,
    X_MIDDLE_NAME_PHONETIC                  OUT NOCOPY    VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER,
    X_ACTUAL_CONTENT_SOURCE                 OUT NOCOPY    VARCHAR2
);

PROCEDURE Delete_Row (
    X_PERSON_PROFILE_ID                     IN     NUMBER
);

END HZ_PERSON_PROFILES_PKG;

 

/