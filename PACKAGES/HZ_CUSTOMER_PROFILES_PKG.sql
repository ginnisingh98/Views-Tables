--------------------------------------------------------
--  DDL for Package HZ_CUSTOMER_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CUSTOMER_PROFILES_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHCPFTS.pls 120.5.12010000.2 2009/02/27 12:47:08 rgokavar ship $ */

PROCEDURE Insert_Row (
    X_CUST_ACCOUNT_PROFILE_ID               IN OUT NOCOPY NUMBER,
    X_CUST_ACCOUNT_ID                       IN     NUMBER,
    X_STATUS                                IN     VARCHAR2,
    X_COLLECTOR_ID                          IN     NUMBER,
    X_CREDIT_ANALYST_ID                     IN     NUMBER,
    X_CREDIT_CHECKING                       IN     VARCHAR2,
    X_NEXT_CREDIT_REVIEW_DATE               IN     DATE,
    X_TOLERANCE                             IN     NUMBER,
    X_DISCOUNT_TERMS                        IN     VARCHAR2,
    X_DUNNING_LETTERS                       IN     VARCHAR2,
    X_INTEREST_CHARGES                      IN     VARCHAR2,
    X_SEND_STATEMENTS                       IN     VARCHAR2,
    X_CREDIT_BALANCE_STATEMENTS             IN     VARCHAR2,
    X_CREDIT_HOLD                           IN     VARCHAR2,
    X_PROFILE_CLASS_ID                      IN     NUMBER,
    X_SITE_USE_ID                           IN     NUMBER,
    X_CREDIT_RATING                         IN     VARCHAR2,
    X_RISK_CODE                             IN     VARCHAR2,
    X_STANDARD_TERMS                        IN     NUMBER,
    X_OVERRIDE_TERMS                        IN     VARCHAR2,
    X_DUNNING_LETTER_SET_ID                 IN     NUMBER,
    X_INTEREST_PERIOD_DAYS                  IN     NUMBER,
    X_PAYMENT_GRACE_DAYS                    IN     NUMBER,
    X_DISCOUNT_GRACE_DAYS                   IN     NUMBER,
    X_STATEMENT_CYCLE_ID                    IN     NUMBER,
    X_ACCOUNT_STATUS                        IN     VARCHAR2,
    X_PERCENT_COLLECTABLE                   IN     NUMBER,
    X_AUTOCASH_HIERARCHY_ID                 IN     NUMBER,
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
    X_AUTO_REC_INCL_DISPUTED_FLAG           IN     VARCHAR2,
    X_TAX_PRINTING_OPTION                   IN     VARCHAR2,
    X_CHARGE_ON_FINANCE_CHARGE_FG           IN     VARCHAR2,
    X_GROUPING_RULE_ID                      IN     NUMBER,
    X_CLEARING_DAYS                         IN     NUMBER,
    X_JGZZ_ATTRIBUTE_CATEGORY               IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE1                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE2                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE3                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE4                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE5                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE6                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE7                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE8                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE9                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE10                      IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE11                      IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE12                      IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE13                      IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE14                      IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE15                      IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE1                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE2                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE3                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE4                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE5                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE6                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE7                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE8                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE9                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE10                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE11                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE12                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE13                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE14                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE15                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE16                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE17                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE18                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE19                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE20                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE_CATEGORY             IN     VARCHAR2,
    X_CONS_INV_FLAG                         IN     VARCHAR2,
    X_CONS_INV_TYPE                         IN     VARCHAR2,
    X_AUTOCASH_HIERARCHY_ID_ADR             IN     NUMBER,
    X_LOCKBOX_MATCHING_OPTION               IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER,
    X_REVIEW_CYCLE                          IN     VARCHAR2 DEFAULT NULL,
    X_LAST_CREDIT_REVIEW_DATE               IN     DATE     DEFAULT NULL,
    X_PARTY_ID                              IN     NUMBER   DEFAULT NULL,
    X_CREDIT_CLASSIFICATION                 IN     VARCHAR2 DEFAULT NULL,
    X_CONS_BILL_LEVEL                       IN     VARCHAR2 DEFAULT NULL,
    X_LATE_CHARGE_CALCULATION_TRX           IN     VARCHAR2 DEFAULT NULL,
    X_CREDIT_ITEMS_FLAG                     IN     VARCHAR2 DEFAULT NULL,
    X_DISPUTED_TRANSACTIONS_FLAG            IN     VARCHAR2 DEFAULT NULL,
    X_LATE_CHARGE_TYPE                      IN     VARCHAR2 DEFAULT NULL,
    X_LATE_CHARGE_TERM_ID                   IN     NUMBER   DEFAULT NULL,
    X_INTEREST_CALCULATION_PERIOD           IN     VARCHAR2 DEFAULT NULL,
    X_HOLD_CHARGED_INVOICES_FLAG            IN     VARCHAR2 DEFAULT NULL,
    X_MESSAGE_TEXT_ID                       IN     NUMBER   DEFAULT NULL,
    X_MULTIPLE_INTEREST_RATES_FLAG          IN     VARCHAR2 DEFAULT NULL,
    X_CHARGE_BEGIN_DATE                     IN     DATE     DEFAULT NULL,
    X_AUTOMATCH_SET_ID                      IN     NUMBER   DEFAULT NULL
);

PROCEDURE Update_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_CUST_ACCOUNT_PROFILE_ID               IN     NUMBER,
    X_CUST_ACCOUNT_ID                       IN     NUMBER,
    X_STATUS                                IN     VARCHAR2,
    X_COLLECTOR_ID                          IN     NUMBER,
    X_CREDIT_ANALYST_ID                     IN     NUMBER,
    X_CREDIT_CHECKING                       IN     VARCHAR2,
    X_NEXT_CREDIT_REVIEW_DATE               IN     DATE,
    X_TOLERANCE                             IN     NUMBER,
    X_DISCOUNT_TERMS                        IN     VARCHAR2,
    X_DUNNING_LETTERS                       IN     VARCHAR2,
    X_INTEREST_CHARGES                      IN     VARCHAR2,
    X_SEND_STATEMENTS                       IN     VARCHAR2,
    X_CREDIT_BALANCE_STATEMENTS             IN     VARCHAR2,
    X_CREDIT_HOLD                           IN     VARCHAR2,
    X_PROFILE_CLASS_ID                      IN     NUMBER,
    X_SITE_USE_ID                           IN     NUMBER,
    X_CREDIT_RATING                         IN     VARCHAR2,
    X_RISK_CODE                             IN     VARCHAR2,
    X_STANDARD_TERMS                        IN     NUMBER,
    X_OVERRIDE_TERMS                        IN     VARCHAR2,
    X_DUNNING_LETTER_SET_ID                 IN     NUMBER,
    X_INTEREST_PERIOD_DAYS                  IN     NUMBER,
    X_PAYMENT_GRACE_DAYS                    IN     NUMBER,
    X_DISCOUNT_GRACE_DAYS                   IN     NUMBER,
    X_STATEMENT_CYCLE_ID                    IN     NUMBER,
    X_ACCOUNT_STATUS                        IN     VARCHAR2,
    X_PERCENT_COLLECTABLE                   IN     NUMBER,
    X_AUTOCASH_HIERARCHY_ID                 IN     NUMBER,
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
    X_AUTO_REC_INCL_DISPUTED_FLAG           IN     VARCHAR2,
    X_TAX_PRINTING_OPTION                   IN     VARCHAR2,
    X_CHARGE_ON_FINANCE_CHARGE_FG           IN     VARCHAR2,
    X_GROUPING_RULE_ID                      IN     NUMBER,
    X_CLEARING_DAYS                         IN     NUMBER,
    X_JGZZ_ATTRIBUTE_CATEGORY               IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE1                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE2                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE3                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE4                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE5                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE6                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE7                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE8                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE9                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE10                      IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE11                      IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE12                      IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE13                      IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE14                      IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE15                      IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE1                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE2                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE3                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE4                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE5                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE6                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE7                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE8                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE9                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE10                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE11                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE12                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE13                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE14                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE15                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE16                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE17                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE18                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE19                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE20                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE_CATEGORY             IN     VARCHAR2,
    X_CONS_INV_FLAG                         IN     VARCHAR2,
    X_CONS_INV_TYPE                         IN     VARCHAR2,
    X_AUTOCASH_HIERARCHY_ID_ADR             IN     NUMBER,
    X_LOCKBOX_MATCHING_OPTION               IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER,
    X_REVIEW_CYCLE                          IN     VARCHAR2 DEFAULT NULL,
    X_LAST_CREDIT_REVIEW_DATE               IN     DATE     DEFAULT NULL,
    X_PARTY_ID                              IN     NUMBER   DEFAULT NULL,
    X_CREDIT_CLASSIFICATION                 IN     VARCHAR2 DEFAULT NULL,
    X_CONS_BILL_LEVEL                       IN     VARCHAR2 DEFAULT NULL,
    X_LATE_CHARGE_CALCULATION_TRX           IN     VARCHAR2 DEFAULT NULL,
    X_CREDIT_ITEMS_FLAG                     IN     VARCHAR2 DEFAULT NULL,
    X_DISPUTED_TRANSACTIONS_FLAG            IN     VARCHAR2 DEFAULT NULL,
    X_LATE_CHARGE_TYPE                      IN     VARCHAR2 DEFAULT NULL,
    X_LATE_CHARGE_TERM_ID                   IN     NUMBER   DEFAULT NULL,
    X_INTEREST_CALCULATION_PERIOD           IN     VARCHAR2 DEFAULT NULL,
    X_HOLD_CHARGED_INVOICES_FLAG            IN     VARCHAR2 DEFAULT NULL,
    X_MESSAGE_TEXT_ID                       IN     NUMBER   DEFAULT NULL,
    X_MULTIPLE_INTEREST_RATES_FLAG          IN     VARCHAR2 DEFAULT NULL,
    X_CHARGE_BEGIN_DATE                     IN     DATE     DEFAULT NULL,
    X_AUTOMATCH_SET_ID                      IN     NUMBER   DEFAULT NULL
);

PROCEDURE Lock_Row (
    X_Rowid                                 IN OUT NOCOPY VARCHAR2,
    X_CUST_ACCOUNT_PROFILE_ID               IN     NUMBER,
    X_LAST_UPDATED_BY                       IN     NUMBER,
    X_LAST_UPDATE_DATE                      IN     DATE,
    X_LAST_UPDATE_LOGIN                     IN     NUMBER,
    X_CREATED_BY                            IN     NUMBER,
    X_CREATION_DATE                         IN     DATE,
    X_CUST_ACCOUNT_ID                       IN     NUMBER,
    X_STATUS                                IN     VARCHAR2,
    X_COLLECTOR_ID                          IN     NUMBER,
    X_CREDIT_ANALYST_ID                     IN     NUMBER,
    X_CREDIT_CHECKING                       IN     VARCHAR2,
    X_NEXT_CREDIT_REVIEW_DATE               IN     DATE,
    X_TOLERANCE                             IN     NUMBER,
    X_DISCOUNT_TERMS                        IN     VARCHAR2,
    X_DUNNING_LETTERS                       IN     VARCHAR2,
    X_INTEREST_CHARGES                      IN     VARCHAR2,
    X_SEND_STATEMENTS                       IN     VARCHAR2,
    X_CREDIT_BALANCE_STATEMENTS             IN     VARCHAR2,
    X_CREDIT_HOLD                           IN     VARCHAR2,
    X_PROFILE_CLASS_ID                      IN     NUMBER,
    X_SITE_USE_ID                           IN     NUMBER,
    X_CREDIT_RATING                         IN     VARCHAR2,
    X_RISK_CODE                             IN     VARCHAR2,
    X_STANDARD_TERMS                        IN     NUMBER,
    X_OVERRIDE_TERMS                        IN     VARCHAR2,
    X_DUNNING_LETTER_SET_ID                 IN     NUMBER,
    X_INTEREST_PERIOD_DAYS                  IN     NUMBER,
    X_PAYMENT_GRACE_DAYS                    IN     NUMBER,
    X_DISCOUNT_GRACE_DAYS                   IN     NUMBER,
    X_STATEMENT_CYCLE_ID                    IN     NUMBER,
    X_ACCOUNT_STATUS                        IN     VARCHAR2,
    X_PERCENT_COLLECTABLE                   IN     NUMBER,
    X_AUTOCASH_HIERARCHY_ID                 IN     NUMBER,
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
    X_PROGRAM_APPLICATION_ID                IN     NUMBER,
    X_PROGRAM_ID                            IN     NUMBER,
    X_PROGRAM_UPDATE_DATE                   IN     DATE,
    X_REQUEST_ID                            IN     NUMBER,
    X_ATTRIBUTE11                           IN     VARCHAR2,
    X_ATTRIBUTE12                           IN     VARCHAR2,
    X_ATTRIBUTE13                           IN     VARCHAR2,
    X_ATTRIBUTE14                           IN     VARCHAR2,
    X_ATTRIBUTE15                           IN     VARCHAR2,
    X_AUTO_REC_INCL_DISPUTED_FLAG           IN     VARCHAR2,
    X_TAX_PRINTING_OPTION                   IN     VARCHAR2,
    X_CHARGE_ON_FINANCE_CHARGE_FG           IN     VARCHAR2,
    X_GROUPING_RULE_ID                      IN     NUMBER,
    X_CLEARING_DAYS                         IN     NUMBER,
    X_JGZZ_ATTRIBUTE_CATEGORY               IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE1                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE2                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE3                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE4                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE5                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE6                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE7                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE8                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE9                       IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE10                      IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE11                      IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE12                      IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE13                      IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE14                      IN     VARCHAR2,
    X_JGZZ_ATTRIBUTE15                      IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE1                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE2                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE3                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE4                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE5                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE6                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE7                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE8                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE9                     IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE10                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE11                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE12                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE13                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE14                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE15                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE16                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE17                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE18                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE19                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE20                    IN     VARCHAR2,
    X_GLOBAL_ATTRIBUTE_CATEGORY             IN     VARCHAR2,
    X_CONS_INV_FLAG                         IN     VARCHAR2,
    X_CONS_INV_TYPE                         IN     VARCHAR2,
    X_AUTOCASH_HIERARCHY_ID_ADR             IN     NUMBER,
    X_LOCKBOX_MATCHING_OPTION               IN     VARCHAR2,
    X_OBJECT_VERSION_NUMBER                 IN     NUMBER,
    X_CREATED_BY_MODULE                     IN     VARCHAR2,
    X_APPLICATION_ID                        IN     NUMBER,
    X_REVIEW_CYCLE                          IN     VARCHAR2,
    X_LAST_CREDIT_REVIEW_DATE               IN     DATE,
    X_PARTY_ID                              IN     NUMBER,
    X_CREDIT_CLASSIFICATION                 IN     VARCHAR2,
    X_CONS_BILL_LEVEL                       IN     VARCHAR2,
    X_LATE_CHARGE_CALCULATION_TRX           IN     VARCHAR2,
    X_CREDIT_ITEMS_FLAG                     IN     VARCHAR2,
    X_DISPUTED_TRANSACTIONS_FLAG            IN     VARCHAR2,
    X_LATE_CHARGE_TYPE                      IN     VARCHAR2,
    X_LATE_CHARGE_TERM_ID                   IN     NUMBER,
    X_INTEREST_CALCULATION_PERIOD           IN     VARCHAR2,
    X_HOLD_CHARGED_INVOICES_FLAG            IN     VARCHAR2,
    X_MESSAGE_TEXT_ID                       IN     NUMBER,
    X_MULTIPLE_INTEREST_RATES_FLAG          IN     VARCHAR2,
    X_CHARGE_BEGIN_DATE                     IN     DATE,
    X_AUTOMATCH_SET_ID                      IN     NUMBER
);

PROCEDURE Select_Row (
    X_CUST_ACCOUNT_PROFILE_ID               IN OUT NOCOPY NUMBER,
    X_CUST_ACCOUNT_ID                       OUT NOCOPY    NUMBER,
    X_STATUS                                OUT NOCOPY    VARCHAR2,
    X_COLLECTOR_ID                          OUT NOCOPY    NUMBER,
    X_CREDIT_ANALYST_ID                     OUT NOCOPY    NUMBER,
    X_CREDIT_CHECKING                       OUT NOCOPY    VARCHAR2,
    X_NEXT_CREDIT_REVIEW_DATE               OUT NOCOPY    DATE,
    X_TOLERANCE                             OUT NOCOPY    NUMBER,
    X_DISCOUNT_TERMS                        OUT NOCOPY    VARCHAR2,
    X_DUNNING_LETTERS                       OUT NOCOPY    VARCHAR2,
    X_INTEREST_CHARGES                      OUT NOCOPY    VARCHAR2,
    X_SEND_STATEMENTS                       OUT NOCOPY    VARCHAR2,
    X_CREDIT_BALANCE_STATEMENTS             OUT NOCOPY    VARCHAR2,
    X_CREDIT_HOLD                           OUT NOCOPY    VARCHAR2,
    X_PROFILE_CLASS_ID                      OUT NOCOPY    NUMBER,
    X_SITE_USE_ID                           OUT NOCOPY    NUMBER,
    X_CREDIT_RATING                         OUT NOCOPY    VARCHAR2,
    X_RISK_CODE                             OUT NOCOPY    VARCHAR2,
    X_STANDARD_TERMS                        OUT NOCOPY    NUMBER,
    X_OVERRIDE_TERMS                        OUT NOCOPY    VARCHAR2,
    X_DUNNING_LETTER_SET_ID                 OUT NOCOPY    NUMBER,
    X_INTEREST_PERIOD_DAYS                  OUT NOCOPY    NUMBER,
    X_PAYMENT_GRACE_DAYS                    OUT NOCOPY    NUMBER,
    X_DISCOUNT_GRACE_DAYS                   OUT NOCOPY    NUMBER,
    X_STATEMENT_CYCLE_ID                    OUT NOCOPY    NUMBER,
    X_ACCOUNT_STATUS                        OUT NOCOPY    VARCHAR2,
    X_PERCENT_COLLECTABLE                   OUT NOCOPY    NUMBER,
    X_AUTOCASH_HIERARCHY_ID                 OUT NOCOPY    NUMBER,
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
    X_AUTO_REC_INCL_DISPUTED_FLAG           OUT NOCOPY    VARCHAR2,
    X_TAX_PRINTING_OPTION                   OUT NOCOPY    VARCHAR2,
    X_CHARGE_ON_FINANCE_CHARGE_FG           OUT NOCOPY    VARCHAR2,
    X_GROUPING_RULE_ID                      OUT NOCOPY    NUMBER,
    X_CLEARING_DAYS                         OUT NOCOPY    NUMBER,
    X_JGZZ_ATTRIBUTE_CATEGORY               OUT NOCOPY    VARCHAR2,
    X_JGZZ_ATTRIBUTE1                       OUT NOCOPY    VARCHAR2,
    X_JGZZ_ATTRIBUTE2                       OUT NOCOPY    VARCHAR2,
    X_JGZZ_ATTRIBUTE3                       OUT NOCOPY    VARCHAR2,
    X_JGZZ_ATTRIBUTE4                       OUT NOCOPY    VARCHAR2,
    X_JGZZ_ATTRIBUTE5                       OUT NOCOPY    VARCHAR2,
    X_JGZZ_ATTRIBUTE6                       OUT NOCOPY    VARCHAR2,
    X_JGZZ_ATTRIBUTE7                       OUT NOCOPY    VARCHAR2,
    X_JGZZ_ATTRIBUTE8                       OUT NOCOPY    VARCHAR2,
    X_JGZZ_ATTRIBUTE9                       OUT NOCOPY    VARCHAR2,
    X_JGZZ_ATTRIBUTE10                      OUT NOCOPY    VARCHAR2,
    X_JGZZ_ATTRIBUTE11                      OUT NOCOPY    VARCHAR2,
    X_JGZZ_ATTRIBUTE12                      OUT NOCOPY    VARCHAR2,
    X_JGZZ_ATTRIBUTE13                      OUT NOCOPY    VARCHAR2,
    X_JGZZ_ATTRIBUTE14                      OUT NOCOPY    VARCHAR2,
    X_JGZZ_ATTRIBUTE15                      OUT NOCOPY    VARCHAR2,
    X_GLOBAL_ATTRIBUTE1                     OUT NOCOPY    VARCHAR2,
    X_GLOBAL_ATTRIBUTE2                     OUT NOCOPY    VARCHAR2,
    X_GLOBAL_ATTRIBUTE3                     OUT NOCOPY    VARCHAR2,
    X_GLOBAL_ATTRIBUTE4                     OUT NOCOPY    VARCHAR2,
    X_GLOBAL_ATTRIBUTE5                     OUT NOCOPY    VARCHAR2,
    X_GLOBAL_ATTRIBUTE6                     OUT NOCOPY    VARCHAR2,
    X_GLOBAL_ATTRIBUTE7                     OUT NOCOPY    VARCHAR2,
    X_GLOBAL_ATTRIBUTE8                     OUT NOCOPY    VARCHAR2,
    X_GLOBAL_ATTRIBUTE9                     OUT NOCOPY    VARCHAR2,
    X_GLOBAL_ATTRIBUTE10                    OUT NOCOPY    VARCHAR2,
    X_GLOBAL_ATTRIBUTE11                    OUT NOCOPY    VARCHAR2,
    X_GLOBAL_ATTRIBUTE12                    OUT NOCOPY    VARCHAR2,
    X_GLOBAL_ATTRIBUTE13                    OUT NOCOPY    VARCHAR2,
    X_GLOBAL_ATTRIBUTE14                    OUT NOCOPY    VARCHAR2,
    X_GLOBAL_ATTRIBUTE15                    OUT NOCOPY    VARCHAR2,
    X_GLOBAL_ATTRIBUTE16                    OUT NOCOPY    VARCHAR2,
    X_GLOBAL_ATTRIBUTE17                    OUT NOCOPY    VARCHAR2,
    X_GLOBAL_ATTRIBUTE18                    OUT NOCOPY    VARCHAR2,
    X_GLOBAL_ATTRIBUTE19                    OUT NOCOPY    VARCHAR2,
    X_GLOBAL_ATTRIBUTE20                    OUT NOCOPY    VARCHAR2,
    X_GLOBAL_ATTRIBUTE_CATEGORY             OUT NOCOPY    VARCHAR2,
    X_CONS_INV_FLAG                         OUT NOCOPY    VARCHAR2,
    X_CONS_INV_TYPE                         OUT NOCOPY    VARCHAR2,
    X_AUTOCASH_HIERARCHY_ID_ADR             OUT NOCOPY    NUMBER,
    X_LOCKBOX_MATCHING_OPTION               OUT NOCOPY    VARCHAR2,
    X_CREATED_BY_MODULE                     OUT NOCOPY    VARCHAR2,
    X_APPLICATION_ID                        OUT NOCOPY    NUMBER,
    X_REVIEW_CYCLE                         OUT NOCOPY     VARCHAR2 ,
    X_LAST_CREDIT_REVIEW_DATE              OUT NOCOPY     DATE     ,
    X_PARTY_ID                             OUT NOCOPY     NUMBER,
    X_CREDIT_CLASSIFICATION                OUT NOCOPY     VARCHAR2,
    X_CONS_BILL_LEVEL                       OUT NOCOPY     VARCHAR2,
    X_LATE_CHARGE_CALCULATION_TRX           OUT NOCOPY     VARCHAR2,
    X_CREDIT_ITEMS_FLAG                     OUT NOCOPY     VARCHAR2,
    X_DISPUTED_TRANSACTIONS_FLAG            OUT NOCOPY     VARCHAR2,
    X_LATE_CHARGE_TYPE                      OUT NOCOPY     VARCHAR2,
    X_LATE_CHARGE_TERM_ID                   OUT NOCOPY     NUMBER,
    X_INTEREST_CALCULATION_PERIOD           OUT NOCOPY     VARCHAR2,
    X_HOLD_CHARGED_INVOICES_FLAG            OUT NOCOPY     VARCHAR2,
    X_MESSAGE_TEXT_ID                       OUT NOCOPY     NUMBER,
    X_MULTIPLE_INTEREST_RATES_FLAG          OUT NOCOPY     VARCHAR2,
    X_CHARGE_BEGIN_DATE                     OUT NOCOPY     DATE,
    X_AUTOMATCH_SET_ID                      OUT NOCOPY     NUMBER
);

PROCEDURE Delete_Row (
    X_CUST_ACCOUNT_PROFILE_ID               IN     NUMBER
);

END HZ_CUSTOMER_PROFILES_PKG;

/