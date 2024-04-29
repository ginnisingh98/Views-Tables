--------------------------------------------------------
--  DDL for Package HZ_PARTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTIES_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHPTYTS.pls 115.12 2002/11/21 21:09:17 sponnamb ship $ */

PROCEDURE Insert_Row (
    X_PARTY_ID                              IN OUT NOCOPY NUMBER,
    X_PARTY_NUMBER                          IN OUT NOCOPY VARCHAR2,
    X_PARTY_NAME                            IN     VARCHAR2,
    X_PARTY_TYPE                            IN     VARCHAR2,
    X_VALIDATED_FLAG                        IN     VARCHAR2,
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
    X_ATTRIBUTE21                           IN     VARCHAR2,
    X_ATTRIBUTE22                           IN     VARCHAR2,
    X_ATTRIBUTE23                           IN     VARCHAR2,
    X_ATTRIBUTE24                           IN     VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 IN     VARCHAR2,
    X_SIC_CODE                              IN     VARCHAR2,
    X_HQ_BRANCH_IND                         IN     VARCHAR2,
    X_CUSTOMER_KEY                          IN     VARCHAR2,
    X_TAX_REFERENCE                         IN     VARCHAR2,
    X_JGZZ_FISCAL_CODE                      IN     VARCHAR2,
    X_PERSON_PRE_NAME_ADJUNCT               IN     VARCHAR2,
    X_PERSON_FIRST_NAME                     IN     VARCHAR2,
    X_PERSON_MIDDLE_NAME                    IN     VARCHAR2,
    X_PERSON_LAST_NAME                      IN     VARCHAR2,
    X_PERSON_NAME_SUFFIX                    IN     VARCHAR2,
    X_PERSON_TITLE                          IN     VARCHAR2,
    X_PERSON_ACADEMIC_TITLE                 IN     VARCHAR2,
    X_PERSON_PREVIOUS_LAST_NAME             IN     VARCHAR2,
    X_KNOWN_AS                              IN     VARCHAR2,
    X_PERSON_IDEN_TYPE                      IN     VARCHAR2,
    X_PERSON_IDENTIFIER                     IN     VARCHAR2,
    X_GROUP_TYPE                            IN     VARCHAR2,
    X_COUNTRY                               IN     VARCHAR2,
    X_ADDRESS1                              IN     VARCHAR2,
    X_ADDRESS2                              IN     VARCHAR2,
    X_ADDRESS3                              IN     VARCHAR2,
    X_ADDRESS4                              IN     VARCHAR2,
    X_CITY                                  IN     VARCHAR2,
    X_POSTAL_CODE                           IN     VARCHAR2,
    X_STATE                                 IN     VARCHAR2,
    X_PROVINCE                              IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_COUNTY                                IN     VARCHAR2,
    X_SIC_CODE_TYPE                         IN     VARCHAR2,
    X_URL                                   IN     VARCHAR2,
    X_EMAIL_ADDRESS                         IN     VARCHAR2,
    X_ANALYSIS_FY                           IN     VARCHAR2,
    X_FISCAL_YEAREND_MONTH                  IN     VARCHAR2,
    X_EMPLOYEES_TOTAL                       IN     NUMBER,
    X_CURR_FY_POTENTIAL_REVENUE             IN     NUMBER,
    X_NEXT_FY_POTENTIAL_REVENUE             IN     NUMBER,
    X_YEAR_ESTABLISHED                      IN     NUMBER,
    X_GSA_INDICATOR_FLAG                    IN     VARCHAR2,
    X_MISSION_STATEMENT                     IN     VARCHAR2,
    X_ORGANIZATION_NAME_PHONETIC            IN     VARCHAR2,
    X_PERSON_FIRST_NAME_PHONETIC            IN     VARCHAR2,
    X_PERSON_LAST_NAME_PHONETIC             IN     VARCHAR2,
    X_LANGUAGE_NAME                         IN     VARCHAR2,
    X_CATEGORY_CODE                         IN     VARCHAR2,
    X_SALUTATION                            IN     VARCHAR2,
    X_KNOWN_AS2                             IN     VARCHAR2,
    X_KNOWN_AS3                             IN     VARCHAR2,
    X_KNOWN_AS4                             IN     VARCHAR2,
    X_KNOWN_AS5                             IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_DUNS_NUMBER_C                         IN     VARCHAR2,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Update_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_PARTY_ID                              IN     NUMBER,
    X_PARTY_NUMBER                          IN     VARCHAR2,
    X_PARTY_NAME                            IN     VARCHAR2,
    X_PARTY_TYPE                            IN     VARCHAR2,
    X_VALIDATED_FLAG                        IN     VARCHAR2,
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
    X_ATTRIBUTE21                           IN     VARCHAR2,
    X_ATTRIBUTE22                           IN     VARCHAR2,
    X_ATTRIBUTE23                           IN     VARCHAR2,
    X_ATTRIBUTE24                           IN     VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 IN     VARCHAR2,
    X_SIC_CODE                              IN     VARCHAR2,
    X_HQ_BRANCH_IND                         IN     VARCHAR2,
    X_CUSTOMER_KEY                          IN     VARCHAR2,
    X_TAX_REFERENCE                         IN     VARCHAR2,
    X_JGZZ_FISCAL_CODE                      IN     VARCHAR2,
    X_PERSON_PRE_NAME_ADJUNCT               IN     VARCHAR2,
    X_PERSON_FIRST_NAME                     IN     VARCHAR2,
    X_PERSON_MIDDLE_NAME                    IN     VARCHAR2,
    X_PERSON_LAST_NAME                      IN     VARCHAR2,
    X_PERSON_NAME_SUFFIX                    IN     VARCHAR2,
    X_PERSON_TITLE                          IN     VARCHAR2,
    X_PERSON_ACADEMIC_TITLE                 IN     VARCHAR2,
    X_PERSON_PREVIOUS_LAST_NAME             IN     VARCHAR2,
    X_KNOWN_AS                              IN     VARCHAR2,
    X_PERSON_IDEN_TYPE                      IN     VARCHAR2,
    X_PERSON_IDENTIFIER                     IN     VARCHAR2,
    X_GROUP_TYPE                            IN     VARCHAR2,
    X_COUNTRY                               IN     VARCHAR2,
    X_ADDRESS1                              IN     VARCHAR2,
    X_ADDRESS2                              IN     VARCHAR2,
    X_ADDRESS3                              IN     VARCHAR2,
    X_ADDRESS4                              IN     VARCHAR2,
    X_CITY                                  IN     VARCHAR2,
    X_POSTAL_CODE                           IN     VARCHAR2,
    X_STATE                                 IN     VARCHAR2,
    X_PROVINCE                              IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_COUNTY                                IN     VARCHAR2,
    X_SIC_CODE_TYPE                         IN     VARCHAR2,
    X_URL                                   IN     VARCHAR2,
    X_EMAIL_ADDRESS                         IN     VARCHAR2,
    X_ANALYSIS_FY                           IN     VARCHAR2,
    X_FISCAL_YEAREND_MONTH                  IN     VARCHAR2,
    X_EMPLOYEES_TOTAL                       IN     NUMBER,
    X_CURR_FY_POTENTIAL_REVENUE             IN     NUMBER,
    X_NEXT_FY_POTENTIAL_REVENUE             IN     NUMBER,
    X_YEAR_ESTABLISHED                      IN     NUMBER,
    X_GSA_INDICATOR_FLAG                    IN     VARCHAR2,
    X_MISSION_STATEMENT                     IN     VARCHAR2,
    X_ORGANIZATION_NAME_PHONETIC            IN     VARCHAR2,
    X_PERSON_FIRST_NAME_PHONETIC            IN     VARCHAR2,
    X_PERSON_LAST_NAME_PHONETIC             IN     VARCHAR2,
    X_LANGUAGE_NAME                         IN     VARCHAR2,
    X_CATEGORY_CODE                         IN     VARCHAR2,
    X_SALUTATION                            IN     VARCHAR2,
    X_KNOWN_AS2                             IN     VARCHAR2,
    X_KNOWN_AS3                             IN     VARCHAR2,
    X_KNOWN_AS4                             IN     VARCHAR2,
    X_KNOWN_AS5                             IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_DUNS_NUMBER_C                         IN     VARCHAR2,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Lock_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_PARTY_ID                              IN     NUMBER,
    X_PARTY_NUMBER                          IN     VARCHAR2,
    X_PARTY_NAME                            IN     VARCHAR2,
    X_PARTY_TYPE                            IN     VARCHAR2,
    X_VALIDATED_FLAG                        IN     VARCHAR2,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_REQUEST_ID                            IN     NUMBER,
    X_PROGRAM_APPLICATION_ID                IN     NUMBER,
    X_CREATED_BY                            IN     NUMBER,
    X_LAST_UPDATE_DATE                      IN     DATE,
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
    X_ATTRIBUTE21                           IN     VARCHAR2,
    X_ATTRIBUTE22                           IN     VARCHAR2,
    X_ATTRIBUTE23                           IN     VARCHAR2,
    X_ATTRIBUTE24                           IN     VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 IN     VARCHAR2,
    X_SIC_CODE                              IN     VARCHAR2,
    X_HQ_BRANCH_IND                         IN     VARCHAR2,
    X_CUSTOMER_KEY                          IN     VARCHAR2,
    X_TAX_REFERENCE                         IN     VARCHAR2,
    X_JGZZ_FISCAL_CODE                      IN     VARCHAR2,
    X_PERSON_PRE_NAME_ADJUNCT               IN     VARCHAR2,
    X_PERSON_FIRST_NAME                     IN     VARCHAR2,
    X_PERSON_MIDDLE_NAME                    IN     VARCHAR2,
    X_PERSON_LAST_NAME                      IN     VARCHAR2,
    X_PERSON_NAME_SUFFIX                    IN     VARCHAR2,
    X_PERSON_TITLE                          IN     VARCHAR2,
    X_PERSON_ACADEMIC_TITLE                 IN     VARCHAR2,
    X_PERSON_PREVIOUS_LAST_NAME             IN     VARCHAR2,
    X_KNOWN_AS                              IN     VARCHAR2,
    X_PERSON_IDEN_TYPE                      IN     VARCHAR2,
    X_PERSON_IDENTIFIER                     IN     VARCHAR2,
    X_GROUP_TYPE                            IN     VARCHAR2,
    X_COUNTRY                               IN     VARCHAR2,
    X_ADDRESS1                              IN     VARCHAR2,
    X_ADDRESS2                              IN     VARCHAR2,
    X_ADDRESS3                              IN     VARCHAR2,
    X_ADDRESS4                              IN     VARCHAR2,
    X_CITY                                  IN     VARCHAR2,
    X_POSTAL_CODE                           IN     VARCHAR2,
    X_STATE                                 IN     VARCHAR2,
    X_PROVINCE                              IN     VARCHAR2,
    X_STATUS                                IN     VARCHAR2,
    X_COUNTY                                IN     VARCHAR2,
    X_SIC_CODE_TYPE                         IN     VARCHAR2,
    X_URL                                   IN     VARCHAR2,
    X_EMAIL_ADDRESS                         IN     VARCHAR2,
    X_ANALYSIS_FY                           IN     VARCHAR2,
    X_FISCAL_YEAREND_MONTH                  IN     VARCHAR2,
    X_EMPLOYEES_TOTAL                       IN     NUMBER,
    X_CURR_FY_POTENTIAL_REVENUE             IN     NUMBER,
    X_NEXT_FY_POTENTIAL_REVENUE             IN     NUMBER,
    X_YEAR_ESTABLISHED                      IN     NUMBER,
    X_GSA_INDICATOR_FLAG                    IN     VARCHAR2,
    X_MISSION_STATEMENT                     IN     VARCHAR2,
    X_ORGANIZATION_NAME_PHONETIC            IN     VARCHAR2,
    X_PERSON_FIRST_NAME_PHONETIC            IN     VARCHAR2,
    X_PERSON_LAST_NAME_PHONETIC             IN     VARCHAR2,
    X_LANGUAGE_NAME                         IN     VARCHAR2,
    X_CATEGORY_CODE                         IN     VARCHAR2,
    X_SALUTATION                            IN     VARCHAR2,
    X_KNOWN_AS2                             IN     VARCHAR2,
    X_KNOWN_AS3                             IN     VARCHAR2,
    X_KNOWN_AS4                             IN     VARCHAR2,
    X_KNOWN_AS5                             IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_DUNS_NUMBER_C                         IN     VARCHAR2,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER
);

PROCEDURE Select_Row (
    X_PARTY_ID                              IN OUT NOCOPY NUMBER,
    X_PARTY_NUMBER                          OUT NOCOPY    VARCHAR2,
    X_PARTY_NAME                            OUT NOCOPY    VARCHAR2,
    X_PARTY_TYPE                            OUT NOCOPY    VARCHAR2,
    X_VALIDATED_FLAG                        OUT NOCOPY    VARCHAR2,
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
    X_ATTRIBUTE21                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE22                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE23                           OUT NOCOPY    VARCHAR2,
    X_ATTRIBUTE24                           OUT NOCOPY    VARCHAR2,
    X_ORIG_SYSTEM_REFERENCE                 OUT NOCOPY    VARCHAR2,
    X_SIC_CODE                              OUT NOCOPY    VARCHAR2,
    X_HQ_BRANCH_IND                         OUT NOCOPY    VARCHAR2,
    X_CUSTOMER_KEY                          OUT NOCOPY    VARCHAR2,
    X_TAX_REFERENCE                         OUT NOCOPY    VARCHAR2,
    X_JGZZ_FISCAL_CODE                      OUT NOCOPY    VARCHAR2,
    X_PERSON_PRE_NAME_ADJUNCT               OUT NOCOPY    VARCHAR2,
    X_PERSON_FIRST_NAME                     OUT NOCOPY    VARCHAR2,
    X_PERSON_MIDDLE_NAME                    OUT NOCOPY    VARCHAR2,
    X_PERSON_LAST_NAME                      OUT NOCOPY    VARCHAR2,
    X_PERSON_NAME_SUFFIX                    OUT NOCOPY    VARCHAR2,
    X_PERSON_TITLE                          OUT NOCOPY    VARCHAR2,
    X_PERSON_ACADEMIC_TITLE                 OUT NOCOPY    VARCHAR2,
    X_PERSON_PREVIOUS_LAST_NAME             OUT NOCOPY    VARCHAR2,
    X_KNOWN_AS                              OUT NOCOPY    VARCHAR2,
    X_PERSON_IDEN_TYPE                      OUT NOCOPY    VARCHAR2,
    X_PERSON_IDENTIFIER                     OUT NOCOPY    VARCHAR2,
    X_GROUP_TYPE                            OUT NOCOPY    VARCHAR2,
    X_COUNTRY                               OUT NOCOPY    VARCHAR2,
    X_ADDRESS1                              OUT NOCOPY    VARCHAR2,
    X_ADDRESS2                              OUT NOCOPY    VARCHAR2,
    X_ADDRESS3                              OUT NOCOPY    VARCHAR2,
    X_ADDRESS4                              OUT NOCOPY    VARCHAR2,
    X_CITY                                  OUT NOCOPY    VARCHAR2,
    X_POSTAL_CODE                           OUT NOCOPY    VARCHAR2,
    X_STATE                                 OUT NOCOPY    VARCHAR2,
    X_PROVINCE                              OUT NOCOPY    VARCHAR2,
    X_STATUS                                OUT NOCOPY    VARCHAR2,
    X_COUNTY                                OUT NOCOPY    VARCHAR2,
    X_SIC_CODE_TYPE                         OUT NOCOPY    VARCHAR2,
    X_URL                                   OUT NOCOPY    VARCHAR2,
    X_EMAIL_ADDRESS                         OUT NOCOPY    VARCHAR2,
    X_ANALYSIS_FY                           OUT NOCOPY    VARCHAR2,
    X_FISCAL_YEAREND_MONTH                  OUT NOCOPY    VARCHAR2,
    X_EMPLOYEES_TOTAL                       OUT NOCOPY    NUMBER,
    X_CURR_FY_POTENTIAL_REVENUE             OUT NOCOPY    NUMBER,
    X_NEXT_FY_POTENTIAL_REVENUE             OUT NOCOPY    NUMBER,
    X_YEAR_ESTABLISHED                      OUT NOCOPY    NUMBER,
    X_GSA_INDICATOR_FLAG                    OUT NOCOPY    VARCHAR2,
    X_MISSION_STATEMENT                     OUT NOCOPY    VARCHAR2,
    X_ORGANIZATION_NAME_PHONETIC            OUT NOCOPY    VARCHAR2,
    X_PERSON_FIRST_NAME_PHONETIC            OUT NOCOPY    VARCHAR2,
    X_PERSON_LAST_NAME_PHONETIC             OUT NOCOPY    VARCHAR2,
    X_LANGUAGE_NAME                         OUT NOCOPY    VARCHAR2,
    X_CATEGORY_CODE                         OUT NOCOPY    VARCHAR2,
    X_SALUTATION                            OUT NOCOPY    VARCHAR2,
    X_KNOWN_AS2                             OUT NOCOPY    VARCHAR2,
    X_KNOWN_AS3                             OUT NOCOPY    VARCHAR2,
    X_KNOWN_AS4                             OUT NOCOPY    VARCHAR2,
    X_KNOWN_AS5                             OUT NOCOPY    VARCHAR2,
    X_DUNS_NUMBER_C                         OUT NOCOPY    VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER
);

PROCEDURE Delete_Row (
    X_PARTY_ID                              IN     NUMBER
);

END HZ_PARTIES_PKG;

 

/