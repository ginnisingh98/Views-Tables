--------------------------------------------------------
--  DDL for Package Body HZ_CUSTOMER_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CUSTOMER_PROFILES_PKG" AS
/*$Header: ARHCPFTB.pls 120.13.12010000.8 2009/12/11 11:00:55 rgokavar ship $ */

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
    X_REVIEW_CYCLE                          IN     VARCHAR2 ,
    X_LAST_CREDIT_REVIEW_DATE               IN     DATE     ,
    X_PARTY_ID                              IN     NUMBER   ,
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
) IS

    l_success                               VARCHAR2(1) := 'N';

    l_profile_class_rec                     HZ_CUST_PROFILE_CLASSES%ROWTYPE;

BEGIN

    -- x_profile_class_id is defaulted to default profile class id
    -- before calling table handler.

    SELECT * INTO l_profile_class_rec
    FROM HZ_CUST_PROFILE_CLASSES
    WHERE PROFILE_CLASS_ID = X_PROFILE_CLASS_ID;

    WHILE l_success = 'N' LOOP
    BEGIN

        INSERT INTO HZ_CUSTOMER_PROFILES (
            CUST_ACCOUNT_PROFILE_ID,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            CREATED_BY,
            CREATION_DATE,
            CUST_ACCOUNT_ID,
            STATUS,
            COLLECTOR_ID,
            CREDIT_ANALYST_ID,
            CREDIT_CHECKING,
            NEXT_CREDIT_REVIEW_DATE,
            TOLERANCE,
            DISCOUNT_TERMS,
            DUNNING_LETTERS,
            INTEREST_CHARGES,
            SEND_STATEMENTS,
            CREDIT_BALANCE_STATEMENTS,
            CREDIT_HOLD,
            PROFILE_CLASS_ID,
            SITE_USE_ID,
            CREDIT_RATING,
            RISK_CODE,
            STANDARD_TERMS,
            OVERRIDE_TERMS,
            DUNNING_LETTER_SET_ID,
            INTEREST_PERIOD_DAYS,
            PAYMENT_GRACE_DAYS,
            DISCOUNT_GRACE_DAYS,
            STATEMENT_CYCLE_ID,
            ACCOUNT_STATUS,
            PERCENT_COLLECTABLE,
            AUTOCASH_HIERARCHY_ID,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            AUTO_REC_INCL_DISPUTED_FLAG,
            TAX_PRINTING_OPTION,
            CHARGE_ON_FINANCE_CHARGE_FLAG,
            GROUPING_RULE_ID,
            CLEARING_DAYS,
            JGZZ_ATTRIBUTE_CATEGORY,
            JGZZ_ATTRIBUTE1,
            JGZZ_ATTRIBUTE2,
            JGZZ_ATTRIBUTE3,
            JGZZ_ATTRIBUTE4,
            JGZZ_ATTRIBUTE5,
            JGZZ_ATTRIBUTE6,
            JGZZ_ATTRIBUTE7,
            JGZZ_ATTRIBUTE8,
            JGZZ_ATTRIBUTE9,
            JGZZ_ATTRIBUTE10,
            JGZZ_ATTRIBUTE11,
            JGZZ_ATTRIBUTE12,
            JGZZ_ATTRIBUTE13,
            JGZZ_ATTRIBUTE14,
            JGZZ_ATTRIBUTE15,
            GLOBAL_ATTRIBUTE1,
            GLOBAL_ATTRIBUTE2,
            GLOBAL_ATTRIBUTE3,
            GLOBAL_ATTRIBUTE4,
            GLOBAL_ATTRIBUTE5,
            GLOBAL_ATTRIBUTE6,
            GLOBAL_ATTRIBUTE7,
            GLOBAL_ATTRIBUTE8,
            GLOBAL_ATTRIBUTE9,
            GLOBAL_ATTRIBUTE10,
            GLOBAL_ATTRIBUTE11,
            GLOBAL_ATTRIBUTE12,
            GLOBAL_ATTRIBUTE13,
            GLOBAL_ATTRIBUTE14,
            GLOBAL_ATTRIBUTE15,
            GLOBAL_ATTRIBUTE16,
            GLOBAL_ATTRIBUTE17,
            GLOBAL_ATTRIBUTE18,
            GLOBAL_ATTRIBUTE19,
            GLOBAL_ATTRIBUTE20,
            GLOBAL_ATTRIBUTE_CATEGORY,
            CONS_INV_FLAG,
            CONS_INV_TYPE,
            AUTOCASH_HIERARCHY_ID_FOR_ADR,
            LOCKBOX_MATCHING_OPTION,
            OBJECT_VERSION_NUMBER,
            CREATED_BY_MODULE,
            APPLICATION_ID,
            REVIEW_CYCLE    ,
            LAST_CREDIT_REVIEW_DATE,
            PARTY_ID,
            CREDIT_CLASSIFICATION,
            CONS_BILL_LEVEL,
            LATE_CHARGE_CALCULATION_TRX,
            CREDIT_ITEMS_FLAG,
            DISPUTED_TRANSACTIONS_FLAG,
            LATE_CHARGE_TYPE,
            LATE_CHARGE_TERM_ID,
            INTEREST_CALCULATION_PERIOD,
            HOLD_CHARGED_INVOICES_FLAG,
            MESSAGE_TEXT_ID,
            MULTIPLE_INTEREST_RATES_FLAG,
            CHARGE_BEGIN_DATE,
            AUTOMATCH_SET_ID
        )
        VALUES (
            DECODE( X_CUST_ACCOUNT_PROFILE_ID, FND_API.G_MISS_NUM, HZ_CUSTOMER_PROFILES_S.NEXTVAL, NULL, HZ_CUSTOMER_PROFILES_S.NEXTVAL, X_CUST_ACCOUNT_PROFILE_ID ),
            HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
            HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
            HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
            HZ_UTILITY_V2PUB.CREATED_BY,
            HZ_UTILITY_V2PUB.CREATION_DATE,
            DECODE( X_CUST_ACCOUNT_ID, FND_API.G_MISS_NUM, NULL, X_CUST_ACCOUNT_ID ),
            DECODE( X_STATUS, FND_API.G_MISS_CHAR, 'A', NULL, 'A', X_STATUS ),
            DECODE( X_COLLECTOR_ID, FND_API.G_MISS_NUM, NULL, NULL, l_profile_class_rec.collector_id, X_COLLECTOR_ID ),
            DECODE( X_CREDIT_ANALYST_ID, FND_API.G_MISS_NUM, NULL, NULL, l_profile_class_rec.credit_analyst_id, X_CREDIT_ANALYST_ID ),
            DECODE( X_CREDIT_CHECKING, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.credit_checking, X_CREDIT_CHECKING ),
            DECODE( X_NEXT_CREDIT_REVIEW_DATE, FND_API.G_MISS_DATE, TO_DATE( NULL ), X_NEXT_CREDIT_REVIEW_DATE ),
            DECODE( X_TOLERANCE, FND_API.G_MISS_NUM, NULL, NULL, l_profile_class_rec.tolerance, X_TOLERANCE ),
            DECODE( X_DISCOUNT_TERMS, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.discount_terms, X_DISCOUNT_TERMS ),
            DECODE( X_DUNNING_LETTERS, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.dunning_letters, X_DUNNING_LETTERS ),
            DECODE( X_INTEREST_CHARGES, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.interest_charges, X_INTEREST_CHARGES ),
	    DECODE( X_SEND_STATEMENTS, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.statements, X_SEND_STATEMENTS ),
            DECODE( X_CREDIT_BALANCE_STATEMENTS, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.credit_balance_statements, X_CREDIT_BALANCE_STATEMENTS ),
            DECODE( X_CREDIT_HOLD, FND_API.G_MISS_CHAR, 'N', NULL, 'N', X_CREDIT_HOLD ),
            DECODE( X_PROFILE_CLASS_ID, FND_API.G_MISS_NUM, NULL, X_PROFILE_CLASS_ID ),
            DECODE( X_SITE_USE_ID, FND_API.G_MISS_NUM, NULL, X_SITE_USE_ID ),
            DECODE( X_CREDIT_RATING, FND_API.G_MISS_CHAR, NULL, X_CREDIT_RATING ),
            DECODE( X_RISK_CODE, FND_API.G_MISS_CHAR, NULL, X_RISK_CODE ),
            DECODE( X_STANDARD_TERMS, FND_API.G_MISS_NUM, NULL, NULL, l_profile_class_rec.standard_terms, X_STANDARD_TERMS ),
            DECODE( X_OVERRIDE_TERMS, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.override_terms, X_OVERRIDE_TERMS ),
            --DECODE( X_DUNNING_LETTER_SET_ID, FND_API.G_MISS_NUM, NULL, NULL, l_profile_class_rec.dunning_letter_set_id, X_DUNNING_LETTER_SET_ID ),
	    DECODE( X_DUNNING_LETTER_SET_ID,FND_API.G_MISS_NUM, NULL, NULL,decode(nvl(X_DUNNING_LETTERS,l_profile_class_rec.dunning_letters),'Y',l_profile_class_rec.dunning_letter_set_id,X_DUNNING_LETTER_SET_ID),X_DUNNING_LETTER_SET_ID ),
            DECODE( X_INTEREST_PERIOD_DAYS, FND_API.G_MISS_NUM, NULL,NULL,decode(nvl(X_INTEREST_CHARGES,l_profile_class_rec.interest_charges),'Y',l_profile_class_rec.interest_period_days,X_INTEREST_PERIOD_DAYS),X_INTEREST_PERIOD_DAYS ),
            DECODE( X_PAYMENT_GRACE_DAYS, FND_API.G_MISS_NUM, NULL, NULL, l_profile_class_rec.payment_grace_days, X_PAYMENT_GRACE_DAYS ),
            DECODE( X_DISCOUNT_GRACE_DAYS, FND_API.G_MISS_NUM, NULL, NULL,decode(nvl(x_discount_terms,l_profile_class_rec.discount_terms),'Y',l_profile_class_rec.discount_grace_days,NULL), X_DISCOUNT_GRACE_DAYS ),
            --DECODE( X_STATEMENT_CYCLE_ID, FND_API.G_MISS_NUM, NULL, NULL, l_profile_class_rec.statement_cycle_id, X_STATEMENT_CYCLE_ID ),
	    DECODE( X_STATEMENT_CYCLE_ID, FND_API.G_MISS_NUM, NULL, NULL,decode(nvl(X_SEND_STATEMENTS,l_profile_class_rec.statements),'Y',l_profile_class_rec.statement_cycle_id, X_STATEMENT_CYCLE_ID), X_STATEMENT_CYCLE_ID),
            DECODE( X_ACCOUNT_STATUS, FND_API.G_MISS_CHAR, NULL, X_ACCOUNT_STATUS ),
            DECODE( X_PERCENT_COLLECTABLE, FND_API.G_MISS_NUM, NULL, X_PERCENT_COLLECTABLE ),
	    DECODE( X_AUTOCASH_HIERARCHY_ID,FND_API.G_MISS_NUM, NULL, NULL, nvl(l_profile_class_rec.autocash_hierarchy_id,HZ_MO_GLOBAL_CACHE.get_autocash_hierarchy_id), X_AUTOCASH_HIERARCHY_ID ),
	    DECODE( X_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.attribute_category, X_ATTRIBUTE_CATEGORY ),
            DECODE( X_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.attribute1, X_ATTRIBUTE1 ),
            DECODE( X_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.attribute2, X_ATTRIBUTE2 ),
            DECODE( X_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.attribute3, X_ATTRIBUTE3 ),
            DECODE( X_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.attribute4, X_ATTRIBUTE4 ),
            DECODE( X_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.attribute5, X_ATTRIBUTE5 ),
            DECODE( X_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.attribute6, X_ATTRIBUTE6 ),
            DECODE( X_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.attribute7, X_ATTRIBUTE7 ),
            DECODE( X_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.attribute8, X_ATTRIBUTE8 ),
            DECODE( X_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.attribute9, X_ATTRIBUTE9 ),
            DECODE( X_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.attribute10, X_ATTRIBUTE10 ),
            HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
            HZ_UTILITY_V2PUB.PROGRAM_ID,
            HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
            HZ_UTILITY_V2PUB.REQUEST_ID,
            DECODE( X_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.attribute11, X_ATTRIBUTE11 ),
            DECODE( X_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.attribute12, X_ATTRIBUTE12 ),
            DECODE( X_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.attribute13, X_ATTRIBUTE13 ),
            DECODE( X_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.attribute14, X_ATTRIBUTE14 ),
            DECODE( X_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.attribute15, X_ATTRIBUTE15 ),
            DECODE( X_AUTO_REC_INCL_DISPUTED_FLAG, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.auto_rec_incl_disputed_flag, X_AUTO_REC_INCL_DISPUTED_FLAG ),
            DECODE( X_TAX_PRINTING_OPTION, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.tax_printing_option, X_TAX_PRINTING_OPTION ),
            DECODE( X_CHARGE_ON_FINANCE_CHARGE_FG, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.charge_on_finance_charge_flag, X_CHARGE_ON_FINANCE_CHARGE_FG ),
	    DECODE( X_GROUPING_RULE_ID,FND_API.G_MISS_NUM, NULL, NULL, nvl(l_profile_class_rec.grouping_rule_id,HZ_MO_GLOBAL_CACHE.get_default_grouping_rule_id), X_GROUPING_RULE_ID ),
	    DECODE( X_CLEARING_DAYS, FND_API.G_MISS_NUM, NULL, X_CLEARING_DAYS ),
            DECODE( X_JGZZ_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.jgzz_attribute_category, X_JGZZ_ATTRIBUTE_CATEGORY ),
            DECODE( X_JGZZ_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.jgzz_attribute1, X_JGZZ_ATTRIBUTE1 ),
            DECODE( X_JGZZ_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.jgzz_attribute2, X_JGZZ_ATTRIBUTE2 ),
            DECODE( X_JGZZ_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.jgzz_attribute3, X_JGZZ_ATTRIBUTE3 ),
            DECODE( X_JGZZ_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.jgzz_attribute4, X_JGZZ_ATTRIBUTE4 ),
            DECODE( X_JGZZ_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.jgzz_attribute5, X_JGZZ_ATTRIBUTE5 ),
            DECODE( X_JGZZ_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.jgzz_attribute6, X_JGZZ_ATTRIBUTE6 ),
            DECODE( X_JGZZ_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.jgzz_attribute7, X_JGZZ_ATTRIBUTE7 ),
            DECODE( X_JGZZ_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.jgzz_attribute8, X_JGZZ_ATTRIBUTE8 ),
            DECODE( X_JGZZ_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.jgzz_attribute9, X_JGZZ_ATTRIBUTE9 ),
            DECODE( X_JGZZ_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.jgzz_attribute10, X_JGZZ_ATTRIBUTE10 ),
            DECODE( X_JGZZ_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.jgzz_attribute11, X_JGZZ_ATTRIBUTE11 ),
            DECODE( X_JGZZ_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.jgzz_attribute12, X_JGZZ_ATTRIBUTE12 ),
            DECODE( X_JGZZ_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.jgzz_attribute13, X_JGZZ_ATTRIBUTE13 ),
            DECODE( X_JGZZ_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.jgzz_attribute14, X_JGZZ_ATTRIBUTE14 ),
            DECODE( X_JGZZ_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.jgzz_attribute15, X_JGZZ_ATTRIBUTE15 ),
            DECODE( X_GLOBAL_ATTRIBUTE1, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.global_attribute1, X_GLOBAL_ATTRIBUTE1 ),
            DECODE( X_GLOBAL_ATTRIBUTE2, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.global_attribute2, X_GLOBAL_ATTRIBUTE2 ),
            DECODE( X_GLOBAL_ATTRIBUTE3, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.global_attribute3, X_GLOBAL_ATTRIBUTE3 ),
            DECODE( X_GLOBAL_ATTRIBUTE4, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.global_attribute4, X_GLOBAL_ATTRIBUTE4 ),
            DECODE( X_GLOBAL_ATTRIBUTE5, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.global_attribute5, X_GLOBAL_ATTRIBUTE5 ),
            DECODE( X_GLOBAL_ATTRIBUTE6, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.global_attribute6, X_GLOBAL_ATTRIBUTE6 ),
            DECODE( X_GLOBAL_ATTRIBUTE7, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.global_attribute7, X_GLOBAL_ATTRIBUTE7 ),
            DECODE( X_GLOBAL_ATTRIBUTE8, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.global_attribute8, X_GLOBAL_ATTRIBUTE8 ),
            DECODE( X_GLOBAL_ATTRIBUTE9, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.global_attribute9, X_GLOBAL_ATTRIBUTE9 ),
            DECODE( X_GLOBAL_ATTRIBUTE10, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.global_attribute10, X_GLOBAL_ATTRIBUTE10 ),
            DECODE( X_GLOBAL_ATTRIBUTE11, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.global_attribute11, X_GLOBAL_ATTRIBUTE11 ),
            DECODE( X_GLOBAL_ATTRIBUTE12, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.global_attribute12, X_GLOBAL_ATTRIBUTE12 ),
            DECODE( X_GLOBAL_ATTRIBUTE13, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.global_attribute13, X_GLOBAL_ATTRIBUTE13 ),
            DECODE( X_GLOBAL_ATTRIBUTE14, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.global_attribute14, X_GLOBAL_ATTRIBUTE14 ),
            DECODE( X_GLOBAL_ATTRIBUTE15, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.global_attribute15, X_GLOBAL_ATTRIBUTE15 ),
            DECODE( X_GLOBAL_ATTRIBUTE16, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.global_attribute16, X_GLOBAL_ATTRIBUTE16 ),
            DECODE( X_GLOBAL_ATTRIBUTE17, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.global_attribute17, X_GLOBAL_ATTRIBUTE17 ),
            DECODE( X_GLOBAL_ATTRIBUTE18, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.global_attribute18, X_GLOBAL_ATTRIBUTE18 ),
            DECODE( X_GLOBAL_ATTRIBUTE19, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.global_attribute19, X_GLOBAL_ATTRIBUTE19 ),
            DECODE( X_GLOBAL_ATTRIBUTE20, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.global_attribute20, X_GLOBAL_ATTRIBUTE20 ),
            DECODE( X_GLOBAL_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.global_attribute_category, X_GLOBAL_ATTRIBUTE_CATEGORY ),
            DECODE( X_CONS_INV_FLAG, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.cons_inv_flag, X_CONS_INV_FLAG ),
--			Bug 8396946
--            DECODE( X_CONS_INV_TYPE, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.cons_inv_type, X_CONS_INV_TYPE ),
             X_CONS_INV_TYPE,
            DECODE( X_AUTOCASH_HIERARCHY_ID_ADR, FND_API.G_MISS_NUM, NULL, NULL, l_profile_class_rec.autocash_hierarchy_id_for_adr, X_AUTOCASH_HIERARCHY_ID_ADR ),
            DECODE( X_LOCKBOX_MATCHING_OPTION, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.lockbox_matching_option, X_LOCKBOX_MATCHING_OPTION ),
            DECODE( X_OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
            DECODE( X_CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
            DECODE( X_APPLICATION_ID, FND_API.G_MISS_NUM, NULL, X_APPLICATION_ID ),
            DECODE( X_REVIEW_CYCLE, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.review_cycle, X_REVIEW_CYCLE),
            DECODE( X_LAST_CREDIT_REVIEW_DATE, FND_API.G_MISS_DATE, TO_DATE(NULL), X_LAST_CREDIT_REVIEW_DATE ),
            DECODE( X_PARTY_ID     , FND_API.G_MISS_NUM, NULL,   X_PARTY_ID ),
            DECODE( X_CREDIT_CLASSIFICATION ,FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.credit_classification, X_CREDIT_CLASSIFICATION ),
            DECODE( X_CONS_BILL_LEVEL, FND_API.G_MISS_CHAR, NULL, X_CONS_BILL_LEVEL),
            DECODE( X_LATE_CHARGE_CALCULATION_TRX, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.late_charge_calculation_trx, X_LATE_CHARGE_CALCULATION_TRX),
          --DECODE( X_CREDIT_ITEMS_FLAG, FND_API.G_MISS_CHAR, NULL, X_CREDIT_ITEMS_FLAG),
            DECODE( X_CREDIT_ITEMS_FLAG, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.CREDIT_ITEMS_FLAG, X_CREDIT_ITEMS_FLAG),
          --DECODE( X_DISPUTED_TRANSACTIONS_FLAG, FND_API.G_MISS_CHAR, NULL, X_DISPUTED_TRANSACTIONS_FLAG),
            DECODE( X_DISPUTED_TRANSACTIONS_FLAG, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.DISPUTED_TRANSACTIONS_FLAG, X_DISPUTED_TRANSACTIONS_FLAG),
            DECODE( X_LATE_CHARGE_TYPE, FND_API.G_MISS_CHAR, NULL, X_LATE_CHARGE_TYPE),
            DECODE( X_LATE_CHARGE_TERM_ID, FND_API.G_MISS_NUM, NULL, X_LATE_CHARGE_TERM_ID),
            DECODE( X_INTEREST_CALCULATION_PERIOD, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.INTEREST_CALCULATION_PERIOD, X_INTEREST_CALCULATION_PERIOD),
            DECODE( X_HOLD_CHARGED_INVOICES_FLAG, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.HOLD_CHARGED_INVOICES_FLAG, X_HOLD_CHARGED_INVOICES_FLAG),
            DECODE( X_MESSAGE_TEXT_ID, FND_API.G_MISS_NUM, NULL, X_MESSAGE_TEXT_ID),
          --DECODE( X_MULTIPLE_INTEREST_RATES_FLAG, FND_API.G_MISS_CHAR, NULL, X_MULTIPLE_INTEREST_RATES_FLAG),
            DECODE( X_MULTIPLE_INTEREST_RATES_FLAG, FND_API.G_MISS_CHAR, NULL, NULL, l_profile_class_rec.MULTIPLE_INTEREST_RATES_FLAG, X_MULTIPLE_INTEREST_RATES_FLAG),
          --DECODE( X_CHARGE_BEGIN_DATE, FND_API.G_MISS_DATE, NULL, X_CHARGE_BEGIN_DATE)
            DECODE( X_CHARGE_BEGIN_DATE, FND_API.G_MISS_DATE, NULL, NULL, l_profile_class_rec.CHARGE_BEGIN_DATE, X_CHARGE_BEGIN_DATE),
            DECODE( X_AUTOMATCH_SET_ID,FND_API.G_MISS_NUM, NULL,NULL,l_profile_class_rec.AUTOMATCH_SET_ID,X_AUTOMATCH_SET_ID)
        ) RETURNING
            CUST_ACCOUNT_PROFILE_ID
        INTO
            X_CUST_ACCOUNT_PROFILE_ID;

        l_success := 'Y';

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            IF INSTRB( SQLERRM, 'HZ_CUSTOMER_PROFILES_U1' ) <> 0 OR
               INSTRB( SQLERRM, 'HZ_CUSTOMER_PROFILES_PK' ) <> 0
            THEN
            DECLARE
                l_count             NUMBER;
                l_dummy             VARCHAR2(1);
            BEGIN
                l_count := 1;
                WHILE l_count > 0 LOOP
                    SELECT HZ_CUSTOMER_PROFILES_S.NEXTVAL
                    INTO X_CUST_ACCOUNT_PROFILE_ID FROM dual;
                    BEGIN
                        SELECT 'Y' INTO l_dummy
                        FROM HZ_CUSTOMER_PROFILES
                        WHERE CUST_ACCOUNT_PROFILE_ID = X_CUST_ACCOUNT_PROFILE_ID;
                        l_count := 1;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            l_count := 0;
                    END;
                END LOOP;
            END;
            ELSE
                RAISE;
            END IF;

    END;
    END LOOP;

END Insert_Row;

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
    X_REVIEW_CYCLE                          IN     VARCHAR2 ,
    X_LAST_CREDIT_REVIEW_DATE               IN     DATE     ,
    X_PARTY_ID                              IN     NUMBER   ,
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
) IS

    l_profile_class_updated                 VARCHAR2(1) := 'N';

    l_profile_class_rec                     HZ_CUST_PROFILE_CLASSES%ROWTYPE;

BEGIN

    -- profile_class_id cannot be updated to null.
    IF X_PROFILE_CLASS_ID IS NOT NULL THEN
        l_profile_class_updated := 'Y';

        SELECT * INTO l_profile_class_rec
        FROM HZ_CUST_PROFILE_CLASSES
        WHERE PROFILE_CLASS_ID = X_PROFILE_CLASS_ID;
    END IF;

    UPDATE HZ_CUSTOMER_PROFILES SET
        CUST_ACCOUNT_PROFILE_ID = DECODE( X_CUST_ACCOUNT_PROFILE_ID, NULL, CUST_ACCOUNT_PROFILE_ID, FND_API.G_MISS_NUM, NULL, X_CUST_ACCOUNT_PROFILE_ID ),
        LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
        LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
        CREATED_BY = CREATED_BY,
        CREATION_DATE = CREATION_DATE,
        CUST_ACCOUNT_ID = DECODE( X_CUST_ACCOUNT_ID, NULL, CUST_ACCOUNT_ID, FND_API.G_MISS_NUM, NULL, X_CUST_ACCOUNT_ID ),
        STATUS = DECODE( X_STATUS, NULL, STATUS, FND_API.G_MISS_CHAR, 'A', X_STATUS ),
        COLLECTOR_ID = DECODE( X_COLLECTOR_ID, NULL, DECODE( l_profile_class_updated, 'N', COLLECTOR_ID, l_profile_class_rec.collector_id ), FND_API.G_MISS_NUM, NULL, X_COLLECTOR_ID ),
        CREDIT_ANALYST_ID = DECODE( X_CREDIT_ANALYST_ID, NULL, DECODE( l_profile_class_updated, 'N', CREDIT_ANALYST_ID, l_profile_class_rec.credit_analyst_id ), FND_API.G_MISS_NUM, NULL, X_CREDIT_ANALYST_ID ),
        CREDIT_CHECKING = DECODE( X_CREDIT_CHECKING, NULL, DECODE( l_profile_class_updated, 'N', CREDIT_CHECKING, l_profile_class_rec.credit_checking ), FND_API.G_MISS_CHAR, NULL, X_CREDIT_CHECKING ),
        NEXT_CREDIT_REVIEW_DATE = DECODE( X_NEXT_CREDIT_REVIEW_DATE, NULL, NEXT_CREDIT_REVIEW_DATE, FND_API.G_MISS_DATE, NULL, X_NEXT_CREDIT_REVIEW_DATE ),
        TOLERANCE = DECODE( X_TOLERANCE, NULL, DECODE( l_profile_class_updated, 'N', TOLERANCE, l_profile_class_rec.tolerance), FND_API.G_MISS_NUM, NULL, X_TOLERANCE ),
        DISCOUNT_TERMS = DECODE( X_DISCOUNT_TERMS, NULL, DECODE( l_profile_class_updated, 'N', DISCOUNT_TERMS, l_profile_class_rec.discount_terms ), FND_API.G_MISS_CHAR, NULL, X_DISCOUNT_TERMS ),
        DUNNING_LETTERS = DECODE( X_DUNNING_LETTERS, NULL, DECODE( l_profile_class_updated, 'N', DUNNING_LETTERS, l_profile_class_rec.dunning_letters ), FND_API.G_MISS_CHAR, NULL, X_DUNNING_LETTERS ),
        INTEREST_CHARGES = DECODE( X_INTEREST_CHARGES, NULL, DECODE( l_profile_class_updated, 'N', INTEREST_CHARGES, l_profile_class_rec.interest_charges ), FND_API.G_MISS_CHAR, NULL, X_INTEREST_CHARGES ),
        SEND_STATEMENTS = DECODE( X_SEND_STATEMENTS, NULL, DECODE( l_profile_class_updated, 'N', SEND_STATEMENTS, l_profile_class_rec.statements ), FND_API.G_MISS_CHAR, NULL, X_SEND_STATEMENTS ),
        CREDIT_BALANCE_STATEMENTS = DECODE( X_CREDIT_BALANCE_STATEMENTS, NULL, DECODE( l_profile_class_updated, 'N', CREDIT_BALANCE_STATEMENTS, l_profile_class_rec.credit_balance_statements ), FND_API.G_MISS_CHAR, NULL, X_CREDIT_BALANCE_STATEMENTS ),
        CREDIT_HOLD = DECODE( X_CREDIT_HOLD, NULL, CREDIT_HOLD, FND_API.G_MISS_CHAR, 'N', X_CREDIT_HOLD ),
        PROFILE_CLASS_ID = DECODE( X_PROFILE_CLASS_ID, NULL, PROFILE_CLASS_ID, FND_API.G_MISS_NUM, NULL, X_PROFILE_CLASS_ID ),
        SITE_USE_ID = DECODE( X_SITE_USE_ID, NULL, SITE_USE_ID, FND_API.G_MISS_NUM, NULL, X_SITE_USE_ID ),
        CREDIT_RATING = DECODE( X_CREDIT_RATING, NULL, CREDIT_RATING, FND_API.G_MISS_CHAR, NULL, X_CREDIT_RATING ),
        RISK_CODE = DECODE( X_RISK_CODE, NULL, RISK_CODE, FND_API.G_MISS_CHAR, NULL, X_RISK_CODE ),
        STANDARD_TERMS = DECODE( X_STANDARD_TERMS, NULL, DECODE( l_profile_class_updated, 'N', STANDARD_TERMS, l_profile_class_rec.standard_terms ), FND_API.G_MISS_NUM, NULL, X_STANDARD_TERMS ),
        OVERRIDE_TERMS = DECODE( X_OVERRIDE_TERMS, NULL, DECODE( l_profile_class_updated, 'N', OVERRIDE_TERMS, l_profile_class_rec.override_terms ), FND_API.G_MISS_CHAR, NULL, X_OVERRIDE_TERMS ),
        --DUNNING_LETTER_SET_ID = DECODE( X_DUNNING_LETTER_SET_ID, NULL, DECODE( l_profile_class_updated, 'N', DUNNING_LETTER_SET_ID, l_profile_class_rec.dunning_letter_set_id ), FND_API.G_MISS_NUM, NULL, X_DUNNING_LETTER_SET_ID ),
	DUNNING_LETTER_SET_ID = DECODE( X_DUNNING_LETTER_SET_ID, NULL, DECODE( l_profile_class_updated, 'N', DUNNING_LETTER_SET_ID,
	decode(nvl(X_DUNNING_LETTERS,l_profile_class_rec.dunning_letters),'Y',l_profile_class_rec.dunning_letter_set_id,X_DUNNING_LETTER_SET_ID)), FND_API.G_MISS_NUM, NULL, X_DUNNING_LETTER_SET_ID ),
        INTEREST_PERIOD_DAYS = DECODE( X_INTEREST_PERIOD_DAYS,NULL,DECODE( l_profile_class_updated, 'N', INTEREST_PERIOD_DAYS,
	decode(nvl(X_INTEREST_CHARGES,l_profile_class_rec.interest_charges),'Y',l_profile_class_rec.interest_period_days,X_INTEREST_PERIOD_DAYS)),FND_API.G_MISS_NUM, NULL, X_INTEREST_PERIOD_DAYS ),
        PAYMENT_GRACE_DAYS = DECODE( X_PAYMENT_GRACE_DAYS, NULL, DECODE( l_profile_class_updated, 'N', PAYMENT_GRACE_DAYS, l_profile_class_rec.payment_grace_days ), FND_API.G_MISS_NUM, NULL, X_PAYMENT_GRACE_DAYS ),
        DISCOUNT_GRACE_DAYS = DECODE( X_DISCOUNT_GRACE_DAYS, NULL, DECODE( l_profile_class_updated, 'N', DISCOUNT_GRACE_DAYS,
        decode(nvl(x_discount_terms,l_profile_class_rec.discount_terms),'Y',l_profile_class_rec.discount_grace_days,NULL) ), FND_API.G_MISS_NUM, NULL, X_DISCOUNT_GRACE_DAYS ),
        --STATEMENT_CYCLE_ID = DECODE( X_STATEMENT_CYCLE_ID, NULL, DECODE( l_profile_class_updated, 'N', STATEMENT_CYCLE_ID, l_profile_class_rec.statement_cycle_id ), FND_API.G_MISS_NUM, NULL, X_STATEMENT_CYCLE_ID ),
        STATEMENT_CYCLE_ID = DECODE( X_STATEMENT_CYCLE_ID, NULL, DECODE( l_profile_class_updated, 'N', STATEMENT_CYCLE_ID,
	decode(nvl(X_SEND_STATEMENTS,l_profile_class_rec.statements),'Y',l_profile_class_rec.statement_cycle_id, X_STATEMENT_CYCLE_ID)), FND_API.G_MISS_NUM, NULL, X_STATEMENT_CYCLE_ID ),
	ACCOUNT_STATUS = DECODE( X_ACCOUNT_STATUS, NULL, ACCOUNT_STATUS, FND_API.G_MISS_CHAR, NULL, X_ACCOUNT_STATUS ),
        PERCENT_COLLECTABLE = DECODE( X_PERCENT_COLLECTABLE, NULL, PERCENT_COLLECTABLE, FND_API.G_MISS_NUM, NULL, X_PERCENT_COLLECTABLE ),
        AUTOCASH_HIERARCHY_ID = DECODE( X_AUTOCASH_HIERARCHY_ID, NULL, DECODE( l_profile_class_updated, 'N', AUTOCASH_HIERARCHY_ID, l_profile_class_rec.autocash_hierarchy_id ), FND_API.G_MISS_NUM, NULL, X_AUTOCASH_HIERARCHY_ID ),
        ATTRIBUTE_CATEGORY = DECODE( X_ATTRIBUTE_CATEGORY, NULL, DECODE( l_profile_class_updated, 'N', ATTRIBUTE_CATEGORY, l_profile_class_rec.attribute_category ), FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE_CATEGORY ),
        ATTRIBUTE1 = DECODE( X_ATTRIBUTE1, NULL, DECODE( l_profile_class_updated, 'N', ATTRIBUTE1, l_profile_class_rec.attribute1 ), FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE1 ),
        ATTRIBUTE2 = DECODE( X_ATTRIBUTE2, NULL, DECODE( l_profile_class_updated, 'N', ATTRIBUTE2, l_profile_class_rec.attribute2 ), FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE2 ),
        ATTRIBUTE3 = DECODE( X_ATTRIBUTE3, NULL, DECODE( l_profile_class_updated, 'N', ATTRIBUTE3, l_profile_class_rec.attribute3 ), FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE3 ),
        ATTRIBUTE4 = DECODE( X_ATTRIBUTE4, NULL, DECODE( l_profile_class_updated, 'N', ATTRIBUTE4, l_profile_class_rec.attribute4 ), FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE4 ),
        ATTRIBUTE5 = DECODE( X_ATTRIBUTE5, NULL, DECODE( l_profile_class_updated, 'N', ATTRIBUTE5, l_profile_class_rec.attribute5 ), FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE5 ),
        ATTRIBUTE6 = DECODE( X_ATTRIBUTE6, NULL, DECODE( l_profile_class_updated, 'N', ATTRIBUTE6, l_profile_class_rec.attribute6 ), FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE6 ),
        ATTRIBUTE7 = DECODE( X_ATTRIBUTE7, NULL, DECODE( l_profile_class_updated, 'N', ATTRIBUTE7, l_profile_class_rec.attribute7 ), FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE7 ),
        ATTRIBUTE8 = DECODE( X_ATTRIBUTE8, NULL, DECODE( l_profile_class_updated, 'N', ATTRIBUTE8, l_profile_class_rec.attribute8 ), FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE8 ),
        ATTRIBUTE9 = DECODE( X_ATTRIBUTE9, NULL, DECODE( l_profile_class_updated, 'N', ATTRIBUTE9, l_profile_class_rec.attribute9 ), FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE9 ),
        ATTRIBUTE10 = DECODE( X_ATTRIBUTE10, NULL, DECODE( l_profile_class_updated, 'N', ATTRIBUTE10, l_profile_class_rec.attribute10 ), FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE10 ),
        PROGRAM_APPLICATION_ID = HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
        PROGRAM_ID = HZ_UTILITY_V2PUB.PROGRAM_ID,
        PROGRAM_UPDATE_DATE = HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
        REQUEST_ID = HZ_UTILITY_V2PUB.REQUEST_ID,
        ATTRIBUTE11 = DECODE( X_ATTRIBUTE11, NULL, DECODE( l_profile_class_updated, 'N', ATTRIBUTE11, l_profile_class_rec.attribute11 ), FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE11 ),
        ATTRIBUTE12 = DECODE( X_ATTRIBUTE12, NULL, DECODE( l_profile_class_updated, 'N', ATTRIBUTE12, l_profile_class_rec.attribute12 ), FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE12 ),
        ATTRIBUTE13 = DECODE( X_ATTRIBUTE13, NULL, DECODE( l_profile_class_updated, 'N', ATTRIBUTE13, l_profile_class_rec.attribute13 ), FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE13 ),
        ATTRIBUTE14 = DECODE( X_ATTRIBUTE14, NULL, DECODE( l_profile_class_updated, 'N', ATTRIBUTE14, l_profile_class_rec.attribute14 ), FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE14 ),
        ATTRIBUTE15 = DECODE( X_ATTRIBUTE15, NULL, DECODE( l_profile_class_updated, 'N', ATTRIBUTE15, l_profile_class_rec.attribute15 ), FND_API.G_MISS_CHAR, NULL, X_ATTRIBUTE15 ),
        AUTO_REC_INCL_DISPUTED_FLAG = DECODE( X_AUTO_REC_INCL_DISPUTED_FLAG, NULL,
            DECODE( l_profile_class_updated, 'N', AUTO_REC_INCL_DISPUTED_FLAG, l_profile_class_rec.auto_rec_incl_disputed_flag ),
            FND_API.G_MISS_CHAR, NULL, X_AUTO_REC_INCL_DISPUTED_FLAG ),
        TAX_PRINTING_OPTION = DECODE( X_TAX_PRINTING_OPTION, NULL, DECODE( l_profile_class_updated, 'N', TAX_PRINTING_OPTION, l_profile_class_rec.tax_printing_option ), FND_API.G_MISS_CHAR, NULL, X_TAX_PRINTING_OPTION ),
        CHARGE_ON_FINANCE_CHARGE_FLAG = DECODE( X_CHARGE_ON_FINANCE_CHARGE_FG, NULL,
            DECODE( l_profile_class_updated, 'N', CHARGE_ON_FINANCE_CHARGE_FLAG, l_profile_class_rec.charge_on_finance_charge_flag ),
            FND_API.G_MISS_CHAR, NULL, X_CHARGE_ON_FINANCE_CHARGE_FG ),
        GROUPING_RULE_ID = DECODE( X_GROUPING_RULE_ID, NULL, DECODE( l_profile_class_updated, 'N', GROUPING_RULE_ID, l_profile_class_rec.grouping_rule_id ), FND_API.G_MISS_NUM, NULL, X_GROUPING_RULE_ID ),
        CLEARING_DAYS = DECODE( X_CLEARING_DAYS, NULL, CLEARING_DAYS, FND_API.G_MISS_NUM, NULL, X_CLEARING_DAYS ),
        JGZZ_ATTRIBUTE_CATEGORY = DECODE( X_JGZZ_ATTRIBUTE_CATEGORY, NULL, DECODE( l_profile_class_updated, 'N', JGZZ_ATTRIBUTE_CATEGORY, l_profile_class_rec.jgzz_attribute_category ), FND_API.G_MISS_CHAR, NULL, X_JGZZ_ATTRIBUTE_CATEGORY ),
        JGZZ_ATTRIBUTE1 = DECODE( X_JGZZ_ATTRIBUTE1, NULL, DECODE( l_profile_class_updated, 'N', JGZZ_ATTRIBUTE1, l_profile_class_rec.jgzz_attribute1 ), FND_API.G_MISS_CHAR, NULL, X_JGZZ_ATTRIBUTE1 ),
        JGZZ_ATTRIBUTE2 = DECODE( X_JGZZ_ATTRIBUTE2, NULL, DECODE( l_profile_class_updated, 'N', JGZZ_ATTRIBUTE2, l_profile_class_rec.jgzz_attribute2 ), FND_API.G_MISS_CHAR, NULL, X_JGZZ_ATTRIBUTE2 ),
        JGZZ_ATTRIBUTE3 = DECODE( X_JGZZ_ATTRIBUTE3, NULL, DECODE( l_profile_class_updated, 'N', JGZZ_ATTRIBUTE3, l_profile_class_rec.jgzz_attribute3 ), FND_API.G_MISS_CHAR, NULL, X_JGZZ_ATTRIBUTE3 ),
        JGZZ_ATTRIBUTE4 = DECODE( X_JGZZ_ATTRIBUTE4, NULL, DECODE( l_profile_class_updated, 'N', JGZZ_ATTRIBUTE4, l_profile_class_rec.jgzz_attribute4 ), FND_API.G_MISS_CHAR, NULL, X_JGZZ_ATTRIBUTE4 ),
        JGZZ_ATTRIBUTE5 = DECODE( X_JGZZ_ATTRIBUTE5, NULL, DECODE( l_profile_class_updated, 'N', JGZZ_ATTRIBUTE5, l_profile_class_rec.jgzz_attribute5 ), FND_API.G_MISS_CHAR, NULL, X_JGZZ_ATTRIBUTE5 ),
        JGZZ_ATTRIBUTE6 = DECODE( X_JGZZ_ATTRIBUTE6, NULL, DECODE( l_profile_class_updated, 'N', JGZZ_ATTRIBUTE6, l_profile_class_rec.jgzz_attribute6 ), FND_API.G_MISS_CHAR, NULL, X_JGZZ_ATTRIBUTE6 ),
        JGZZ_ATTRIBUTE7 = DECODE( X_JGZZ_ATTRIBUTE7, NULL, DECODE( l_profile_class_updated, 'N', JGZZ_ATTRIBUTE7, l_profile_class_rec.jgzz_attribute7 ), FND_API.G_MISS_CHAR, NULL, X_JGZZ_ATTRIBUTE7 ),
        JGZZ_ATTRIBUTE8 = DECODE( X_JGZZ_ATTRIBUTE8, NULL, DECODE( l_profile_class_updated, 'N', JGZZ_ATTRIBUTE8, l_profile_class_rec.jgzz_attribute8 ), FND_API.G_MISS_CHAR, NULL, X_JGZZ_ATTRIBUTE8 ),
        JGZZ_ATTRIBUTE9 = DECODE( X_JGZZ_ATTRIBUTE9, NULL, DECODE( l_profile_class_updated, 'N', JGZZ_ATTRIBUTE9, l_profile_class_rec.jgzz_attribute9 ), FND_API.G_MISS_CHAR, NULL, X_JGZZ_ATTRIBUTE9 ),
        JGZZ_ATTRIBUTE10 = DECODE( X_JGZZ_ATTRIBUTE10, NULL, DECODE( l_profile_class_updated, 'N', JGZZ_ATTRIBUTE10, l_profile_class_rec.jgzz_attribute10 ), FND_API.G_MISS_CHAR, NULL, X_JGZZ_ATTRIBUTE10 ),
        JGZZ_ATTRIBUTE11 = DECODE( X_JGZZ_ATTRIBUTE11, NULL, DECODE( l_profile_class_updated, 'N', JGZZ_ATTRIBUTE11, l_profile_class_rec.jgzz_attribute11 ), FND_API.G_MISS_CHAR, NULL, X_JGZZ_ATTRIBUTE11 ),
        JGZZ_ATTRIBUTE12 = DECODE( X_JGZZ_ATTRIBUTE12, NULL, DECODE( l_profile_class_updated, 'N', JGZZ_ATTRIBUTE12, l_profile_class_rec.jgzz_attribute12 ), FND_API.G_MISS_CHAR, NULL, X_JGZZ_ATTRIBUTE12 ),
        JGZZ_ATTRIBUTE13 = DECODE( X_JGZZ_ATTRIBUTE13, NULL, DECODE( l_profile_class_updated, 'N', JGZZ_ATTRIBUTE13, l_profile_class_rec.jgzz_attribute13 ), FND_API.G_MISS_CHAR, NULL, X_JGZZ_ATTRIBUTE13 ),
        JGZZ_ATTRIBUTE14 = DECODE( X_JGZZ_ATTRIBUTE14, NULL, DECODE( l_profile_class_updated, 'N', JGZZ_ATTRIBUTE14, l_profile_class_rec.jgzz_attribute14 ), FND_API.G_MISS_CHAR, NULL, X_JGZZ_ATTRIBUTE14 ),
        JGZZ_ATTRIBUTE15 = DECODE( X_JGZZ_ATTRIBUTE15, NULL, DECODE( l_profile_class_updated, 'N', JGZZ_ATTRIBUTE15, l_profile_class_rec.jgzz_attribute15 ), FND_API.G_MISS_CHAR, NULL, X_JGZZ_ATTRIBUTE15 ),
        GLOBAL_ATTRIBUTE1 = DECODE( X_GLOBAL_ATTRIBUTE1, NULL, DECODE( l_profile_class_updated, 'N', GLOBAL_ATTRIBUTE1, l_profile_class_rec.global_attribute1 ), FND_API.G_MISS_CHAR, NULL, X_GLOBAL_ATTRIBUTE1 ),
        GLOBAL_ATTRIBUTE2 = DECODE( X_GLOBAL_ATTRIBUTE2, NULL, DECODE( l_profile_class_updated, 'N', GLOBAL_ATTRIBUTE2, l_profile_class_rec.global_attribute2 ), FND_API.G_MISS_CHAR, NULL, X_GLOBAL_ATTRIBUTE2 ),
        GLOBAL_ATTRIBUTE3 = DECODE( X_GLOBAL_ATTRIBUTE3, NULL, DECODE( l_profile_class_updated, 'N', GLOBAL_ATTRIBUTE3, l_profile_class_rec.global_attribute3 ), FND_API.G_MISS_CHAR, NULL, X_GLOBAL_ATTRIBUTE3 ),
        GLOBAL_ATTRIBUTE4 = DECODE( X_GLOBAL_ATTRIBUTE4, NULL, DECODE( l_profile_class_updated, 'N', GLOBAL_ATTRIBUTE4, l_profile_class_rec.global_attribute4 ), FND_API.G_MISS_CHAR, NULL, X_GLOBAL_ATTRIBUTE4 ),
        GLOBAL_ATTRIBUTE5 = DECODE( X_GLOBAL_ATTRIBUTE5, NULL, DECODE( l_profile_class_updated, 'N', GLOBAL_ATTRIBUTE5, l_profile_class_rec.global_attribute5 ), FND_API.G_MISS_CHAR, NULL, X_GLOBAL_ATTRIBUTE5 ),
        GLOBAL_ATTRIBUTE6 = DECODE( X_GLOBAL_ATTRIBUTE6, NULL, DECODE( l_profile_class_updated, 'N', GLOBAL_ATTRIBUTE6, l_profile_class_rec.global_attribute6 ), FND_API.G_MISS_CHAR, NULL, X_GLOBAL_ATTRIBUTE6 ),
        GLOBAL_ATTRIBUTE7 = DECODE( X_GLOBAL_ATTRIBUTE7, NULL, DECODE( l_profile_class_updated, 'N', GLOBAL_ATTRIBUTE7, l_profile_class_rec.global_attribute7 ), FND_API.G_MISS_CHAR, NULL, X_GLOBAL_ATTRIBUTE7 ),
        GLOBAL_ATTRIBUTE8 = DECODE( X_GLOBAL_ATTRIBUTE8, NULL, DECODE( l_profile_class_updated, 'N', GLOBAL_ATTRIBUTE8, l_profile_class_rec.global_attribute8 ), FND_API.G_MISS_CHAR, NULL, X_GLOBAL_ATTRIBUTE8 ),
        GLOBAL_ATTRIBUTE9 = DECODE( X_GLOBAL_ATTRIBUTE9, NULL, DECODE( l_profile_class_updated, 'N', GLOBAL_ATTRIBUTE9, l_profile_class_rec.global_attribute9 ), FND_API.G_MISS_CHAR, NULL, X_GLOBAL_ATTRIBUTE9 ),
        GLOBAL_ATTRIBUTE10 = DECODE( X_GLOBAL_ATTRIBUTE10, NULL, DECODE( l_profile_class_updated, 'N', GLOBAL_ATTRIBUTE10, l_profile_class_rec.global_attribute10 ), FND_API.G_MISS_CHAR, NULL, X_GLOBAL_ATTRIBUTE10 ),
        GLOBAL_ATTRIBUTE11 = DECODE( X_GLOBAL_ATTRIBUTE11, NULL, DECODE( l_profile_class_updated, 'N', GLOBAL_ATTRIBUTE11, l_profile_class_rec.global_attribute11 ), FND_API.G_MISS_CHAR, NULL, X_GLOBAL_ATTRIBUTE11 ),
        GLOBAL_ATTRIBUTE12 = DECODE( X_GLOBAL_ATTRIBUTE12, NULL, DECODE( l_profile_class_updated, 'N', GLOBAL_ATTRIBUTE12, l_profile_class_rec.global_attribute12 ), FND_API.G_MISS_CHAR, NULL, X_GLOBAL_ATTRIBUTE12 ),
        GLOBAL_ATTRIBUTE13 = DECODE( X_GLOBAL_ATTRIBUTE13, NULL, DECODE( l_profile_class_updated, 'N', GLOBAL_ATTRIBUTE13, l_profile_class_rec.global_attribute13 ), FND_API.G_MISS_CHAR, NULL, X_GLOBAL_ATTRIBUTE13 ),
        GLOBAL_ATTRIBUTE14 = DECODE( X_GLOBAL_ATTRIBUTE14, NULL, DECODE( l_profile_class_updated, 'N', GLOBAL_ATTRIBUTE14, l_profile_class_rec.global_attribute14 ), FND_API.G_MISS_CHAR, NULL, X_GLOBAL_ATTRIBUTE14 ),
        GLOBAL_ATTRIBUTE15 = DECODE( X_GLOBAL_ATTRIBUTE15, NULL, DECODE( l_profile_class_updated, 'N', GLOBAL_ATTRIBUTE15, l_profile_class_rec.global_attribute15 ), FND_API.G_MISS_CHAR, NULL, X_GLOBAL_ATTRIBUTE15 ),
        GLOBAL_ATTRIBUTE16 = DECODE( X_GLOBAL_ATTRIBUTE16, NULL, DECODE( l_profile_class_updated, 'N', GLOBAL_ATTRIBUTE16, l_profile_class_rec.global_attribute16 ), FND_API.G_MISS_CHAR, NULL, X_GLOBAL_ATTRIBUTE16 ),
        GLOBAL_ATTRIBUTE17 = DECODE( X_GLOBAL_ATTRIBUTE17, NULL, DECODE( l_profile_class_updated, 'N', GLOBAL_ATTRIBUTE17, l_profile_class_rec.global_attribute17 ), FND_API.G_MISS_CHAR, NULL, X_GLOBAL_ATTRIBUTE17 ),
        GLOBAL_ATTRIBUTE18 = DECODE( X_GLOBAL_ATTRIBUTE18, NULL, DECODE( l_profile_class_updated, 'N', GLOBAL_ATTRIBUTE18, l_profile_class_rec.global_attribute18 ), FND_API.G_MISS_CHAR, NULL, X_GLOBAL_ATTRIBUTE18 ),
        GLOBAL_ATTRIBUTE19 = DECODE( X_GLOBAL_ATTRIBUTE19, NULL, DECODE( l_profile_class_updated, 'N', GLOBAL_ATTRIBUTE19, l_profile_class_rec.global_attribute19 ), FND_API.G_MISS_CHAR, NULL, X_GLOBAL_ATTRIBUTE19 ),
        GLOBAL_ATTRIBUTE20 = DECODE( X_GLOBAL_ATTRIBUTE20, NULL, DECODE( l_profile_class_updated, 'N', GLOBAL_ATTRIBUTE20, l_profile_class_rec.global_attribute20 ), FND_API.G_MISS_CHAR, NULL, X_GLOBAL_ATTRIBUTE20 ),
        GLOBAL_ATTRIBUTE_CATEGORY = DECODE( X_GLOBAL_ATTRIBUTE_CATEGORY, NULL, DECODE( l_profile_class_updated, 'N', GLOBAL_ATTRIBUTE_CATEGORY, l_profile_class_rec.global_attribute_category ), FND_API.G_MISS_CHAR, NULL, X_GLOBAL_ATTRIBUTE_CATEGORY ),
        CONS_INV_FLAG = DECODE( X_CONS_INV_FLAG, NULL, DECODE( l_profile_class_updated, 'N', CONS_INV_FLAG, l_profile_class_rec.cons_inv_flag ), FND_API.G_MISS_CHAR, NULL, X_CONS_INV_FLAG ),
        CONS_INV_TYPE = DECODE( X_CONS_INV_TYPE, NULL, DECODE( l_profile_class_updated, 'N', CONS_INV_TYPE, l_profile_class_rec.cons_inv_type ), FND_API.G_MISS_CHAR,NULL, X_CONS_INV_TYPE ),
        AUTOCASH_HIERARCHY_ID_FOR_ADR = DECODE( X_AUTOCASH_HIERARCHY_ID_ADR, NULL,
            DECODE( l_profile_class_updated, 'N', AUTOCASH_HIERARCHY_ID_FOR_ADR, l_profile_class_rec.autocash_hierarchy_id_for_adr ),
            FND_API.G_MISS_NUM, NULL, X_AUTOCASH_HIERARCHY_ID_ADR ),
        LOCKBOX_MATCHING_OPTION = DECODE( X_LOCKBOX_MATCHING_OPTION, NULL, DECODE( l_profile_class_updated, 'N', LOCKBOX_MATCHING_OPTION, l_profile_class_rec.lockbox_matching_option ), FND_API.G_MISS_CHAR, NULL, X_LOCKBOX_MATCHING_OPTION ),
        OBJECT_VERSION_NUMBER = DECODE( X_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER ),
        CREATED_BY_MODULE = DECODE( X_CREATED_BY_MODULE, NULL, CREATED_BY_MODULE, FND_API.G_MISS_CHAR, NULL, X_CREATED_BY_MODULE ),
        APPLICATION_ID = DECODE( X_APPLICATION_ID, NULL, APPLICATION_ID, FND_API.G_MISS_NUM, NULL, X_APPLICATION_ID ),
--  REVIEW_CYCLE = DECODE( X_REVIEW_CYCLE  , NULL, REVIEW_CYCLE  , FND_API.G_MISS_CHAR,NULL, X_REVIEW_CYCLE ),
    REVIEW_CYCLE = DECODE( X_REVIEW_CYCLE, NULL, DECODE(l_profile_class_updated, 'N', REVIEW_CYCLE, l_profile_class_rec.REVIEW_CYCLE ), FND_API.G_MISS_CHAR, NULL, X_REVIEW_CYCLE),
    LAST_CREDIT_REVIEW_DATE= DECODE( X_LAST_CREDIT_REVIEW_DATE, NULL, LAST_CREDIT_REVIEW_DATE , FND_API.G_MISS_DATE ,NULL, X_LAST_CREDIT_REVIEW_DATE ),
    PARTY_ID        = DECODE( X_PARTY_ID, NULL, PARTY_ID , FND_API.G_MISS_NUM ,NULL, X_PARTY_ID ),
    CREDIT_CLASSIFICATION = DECODE(X_CREDIT_CLASSIFICATION, NULL, DECODE(l_profile_class_updated, 'N', CREDIT_CLASSIFICATION, l_profile_class_rec.credit_classification ), FND_API.G_MISS_CHAR ,NULL, X_CREDIT_CLASSIFICATION),
    CONS_BILL_LEVEL = DECODE( X_CONS_BILL_LEVEL, NULL, DECODE(l_profile_class_updated, 'N', CONS_BILL_LEVEL, l_profile_class_rec.CONS_BILL_LEVEL ), FND_API.G_MISS_CHAR, NULL, X_CONS_BILL_LEVEL ),
    LATE_CHARGE_CALCULATION_TRX = DECODE( X_LATE_CHARGE_CALCULATION_TRX, NULL, DECODE(l_profile_class_updated, 'N', LATE_CHARGE_CALCULATION_TRX, l_profile_class_rec.LATE_CHARGE_CALCULATION_TRX ), FND_API.G_MISS_CHAR, NULL, X_LATE_CHARGE_CALCULATION_TRX),
    CREDIT_ITEMS_FLAG = DECODE( X_CREDIT_ITEMS_FLAG, NULL, DECODE(l_profile_class_updated, 'N', CREDIT_ITEMS_FLAG, l_profile_class_rec.CREDIT_ITEMS_FLAG ), FND_API.G_MISS_CHAR, NULL, X_CREDIT_ITEMS_FLAG),
    DISPUTED_TRANSACTIONS_FLAG = DECODE( X_DISPUTED_TRANSACTIONS_FLAG, NULL, DECODE(l_profile_class_updated, 'N', DISPUTED_TRANSACTIONS_FLAG, l_profile_class_rec.DISPUTED_TRANSACTIONS_FLAG ), FND_API.G_MISS_CHAR, NULL, X_DISPUTED_TRANSACTIONS_FLAG),
    LATE_CHARGE_TYPE = DECODE( X_LATE_CHARGE_TYPE, NULL, DECODE(l_profile_class_updated, 'N', LATE_CHARGE_TYPE, l_profile_class_rec.LATE_CHARGE_TYPE ), FND_API.G_MISS_CHAR, NULL, X_LATE_CHARGE_TYPE),
    LATE_CHARGE_TERM_ID = DECODE( X_LATE_CHARGE_TERM_ID, NULL, DECODE(l_profile_class_updated, 'N', LATE_CHARGE_TERM_ID, l_profile_class_rec.LATE_CHARGE_TERM_ID ), FND_API.G_MISS_NUM, NULL, X_LATE_CHARGE_TERM_ID),
    INTEREST_CALCULATION_PERIOD = DECODE( X_INTEREST_CALCULATION_PERIOD, NULL, DECODE(l_profile_class_updated, 'N', INTEREST_CALCULATION_PERIOD, l_profile_class_rec.INTEREST_CALCULATION_PERIOD ), FND_API.G_MISS_CHAR, NULL, X_INTEREST_CALCULATION_PERIOD),
    HOLD_CHARGED_INVOICES_FLAG = DECODE( X_HOLD_CHARGED_INVOICES_FLAG, NULL, DECODE(l_profile_class_updated, 'N', HOLD_CHARGED_INVOICES_FLAG, l_profile_class_rec.HOLD_CHARGED_INVOICES_FLAG ), FND_API.G_MISS_CHAR, NULL, X_HOLD_CHARGED_INVOICES_FLAG),
    MESSAGE_TEXT_ID = DECODE( X_MESSAGE_TEXT_ID, NULL, DECODE(l_profile_class_updated, 'N', MESSAGE_TEXT_ID, l_profile_class_rec.MESSAGE_TEXT_ID ), FND_API.G_MISS_NUM, NULL, X_MESSAGE_TEXT_ID),
    MULTIPLE_INTEREST_RATES_FLAG =
    DECODE( X_MULTIPLE_INTEREST_RATES_FLAG, NULL, DECODE(l_profile_class_updated, 'N', MULTIPLE_INTEREST_RATES_FLAG, l_profile_class_rec.MULTIPLE_INTEREST_RATES_FLAG ), FND_API.G_MISS_CHAR, NULL, X_MULTIPLE_INTEREST_RATES_FLAG),
    CHARGE_BEGIN_DATE = DECODE( X_CHARGE_BEGIN_DATE, NULL, DECODE(l_profile_class_updated, 'N', CHARGE_BEGIN_DATE, l_profile_class_rec.CHARGE_BEGIN_DATE ), FND_API.G_MISS_DATE, NULL, X_CHARGE_BEGIN_DATE),
    AUTOMATCH_SET_ID  = DECODE( X_AUTOMATCH_SET_ID,  NULL, DECODE(l_profile_class_updated, 'N', AUTOMATCH_SET_ID,  l_profile_class_rec.AUTOMATCH_SET_ID  ), FND_API.G_MISS_NUM, NULL, X_AUTOMATCH_SET_ID)
    WHERE ROWID = X_RowId ;


    IF ( SQL%NOTFOUND ) THEN
        RAISE NO_DATA_FOUND;
    END IF;

END Update_Row;

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
) IS

    CURSOR C IS
        SELECT * FROM HZ_CUSTOMER_PROFILES
        WHERE  ROWID = x_Rowid
        FOR UPDATE NOWAIT;
    Recinfo C%ROWTYPE;

BEGIN

    OPEN C;
    FETCH C INTO Recinfo;
    IF ( C%NOTFOUND ) THEN
        CLOSE C;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;

    IF (
        ( ( Recinfo.CUST_ACCOUNT_PROFILE_ID = X_CUST_ACCOUNT_PROFILE_ID )
        OR ( ( Recinfo.CUST_ACCOUNT_PROFILE_ID IS NULL )
            AND (  X_CUST_ACCOUNT_PROFILE_ID IS NULL ) ) )
    AND ( ( Recinfo.LAST_UPDATED_BY = X_LAST_UPDATED_BY )
        OR ( ( Recinfo.LAST_UPDATED_BY IS NULL )
            AND (  X_LAST_UPDATED_BY IS NULL ) ) )
    AND ( ( Recinfo.LAST_UPDATE_DATE = X_LAST_UPDATE_DATE )
        OR ( ( Recinfo.LAST_UPDATE_DATE IS NULL )
            AND (  X_LAST_UPDATE_DATE IS NULL ) ) )
    AND ( ( Recinfo.LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN )
        OR ( ( Recinfo.LAST_UPDATE_LOGIN IS NULL )
            AND (  X_LAST_UPDATE_LOGIN IS NULL ) ) )
    AND ( ( Recinfo.CREATED_BY = X_CREATED_BY )
        OR ( ( Recinfo.CREATED_BY IS NULL )
            AND (  X_CREATED_BY IS NULL ) ) )
    AND ( ( Recinfo.CREATION_DATE = X_CREATION_DATE )
        OR ( ( Recinfo.CREATION_DATE IS NULL )
            AND (  X_CREATION_DATE IS NULL ) ) )
    AND ( ( Recinfo.CUST_ACCOUNT_ID = X_CUST_ACCOUNT_ID )
        OR ( ( Recinfo.CUST_ACCOUNT_ID IS NULL )
            AND (  X_CUST_ACCOUNT_ID IS NULL ) ) )
    AND ( ( Recinfo.STATUS = X_STATUS )
        OR ( ( Recinfo.STATUS IS NULL )
            AND (  X_STATUS IS NULL ) ) )
    AND ( ( Recinfo.COLLECTOR_ID = X_COLLECTOR_ID )
        OR ( ( Recinfo.COLLECTOR_ID IS NULL )
            AND (  X_COLLECTOR_ID IS NULL ) ) )
    AND ( ( Recinfo.CREDIT_ANALYST_ID = X_CREDIT_ANALYST_ID )
        OR ( ( Recinfo.CREDIT_ANALYST_ID IS NULL )
            AND (  X_CREDIT_ANALYST_ID IS NULL ) ) )
    AND ( ( Recinfo.CREDIT_CHECKING = X_CREDIT_CHECKING )
        OR ( ( Recinfo.CREDIT_CHECKING IS NULL )
            AND (  X_CREDIT_CHECKING IS NULL ) ) )
    AND ( ( Recinfo.NEXT_CREDIT_REVIEW_DATE = X_NEXT_CREDIT_REVIEW_DATE )
        OR ( ( Recinfo.NEXT_CREDIT_REVIEW_DATE IS NULL )
            AND (  X_NEXT_CREDIT_REVIEW_DATE IS NULL ) ) )
    AND ( ( Recinfo.TOLERANCE = X_TOLERANCE )
        OR ( ( Recinfo.TOLERANCE IS NULL )
            AND (  X_TOLERANCE IS NULL ) ) )
    AND ( ( Recinfo.DISCOUNT_TERMS = X_DISCOUNT_TERMS )
        OR ( ( Recinfo.DISCOUNT_TERMS IS NULL )
            AND (  X_DISCOUNT_TERMS IS NULL ) ) )
    AND ( ( Recinfo.DUNNING_LETTERS = X_DUNNING_LETTERS )
        OR ( ( Recinfo.DUNNING_LETTERS IS NULL )
            AND (  X_DUNNING_LETTERS IS NULL ) ) )
    AND ( ( Recinfo.INTEREST_CHARGES = X_INTEREST_CHARGES )
        OR ( ( Recinfo.INTEREST_CHARGES IS NULL )
            AND (  X_INTEREST_CHARGES IS NULL ) ) )
    AND ( ( Recinfo.SEND_STATEMENTS = X_SEND_STATEMENTS )
        OR ( ( Recinfo.SEND_STATEMENTS IS NULL )
            AND (  X_SEND_STATEMENTS IS NULL ) ) )
    AND ( ( Recinfo.CREDIT_BALANCE_STATEMENTS = X_CREDIT_BALANCE_STATEMENTS )
        OR ( ( Recinfo.CREDIT_BALANCE_STATEMENTS IS NULL )
            AND (  X_CREDIT_BALANCE_STATEMENTS IS NULL ) ) )
    AND ( ( Recinfo.CREDIT_HOLD = X_CREDIT_HOLD )
        OR ( ( Recinfo.CREDIT_HOLD IS NULL )
            AND (  X_CREDIT_HOLD IS NULL ) ) )
    AND ( ( Recinfo.PROFILE_CLASS_ID = X_PROFILE_CLASS_ID )
        OR ( ( Recinfo.PROFILE_CLASS_ID IS NULL )
            AND (  X_PROFILE_CLASS_ID IS NULL ) ) )
    AND ( ( Recinfo.SITE_USE_ID = X_SITE_USE_ID )
        OR ( ( Recinfo.SITE_USE_ID IS NULL )
            AND (  X_SITE_USE_ID IS NULL ) ) )
    AND ( ( Recinfo.CREDIT_RATING = X_CREDIT_RATING )
        OR ( ( Recinfo.CREDIT_RATING IS NULL )
            AND (  X_CREDIT_RATING IS NULL ) ) )
    AND ( ( Recinfo.RISK_CODE = X_RISK_CODE )
        OR ( ( Recinfo.RISK_CODE IS NULL )
            AND (  X_RISK_CODE IS NULL ) ) )
    AND ( ( Recinfo.STANDARD_TERMS = X_STANDARD_TERMS )
        OR ( ( Recinfo.STANDARD_TERMS IS NULL )
            AND (  X_STANDARD_TERMS IS NULL ) ) )
    AND ( ( Recinfo.OVERRIDE_TERMS = X_OVERRIDE_TERMS )
        OR ( ( Recinfo.OVERRIDE_TERMS IS NULL )
            AND (  X_OVERRIDE_TERMS IS NULL ) ) )
    AND ( ( Recinfo.DUNNING_LETTER_SET_ID = X_DUNNING_LETTER_SET_ID )
        OR ( ( Recinfo.DUNNING_LETTER_SET_ID IS NULL )
            AND (  X_DUNNING_LETTER_SET_ID IS NULL ) ) )
    AND ( ( Recinfo.INTEREST_PERIOD_DAYS = X_INTEREST_PERIOD_DAYS )
        OR ( ( Recinfo.INTEREST_PERIOD_DAYS IS NULL )
            AND (  X_INTEREST_PERIOD_DAYS IS NULL ) ) )
    AND ( ( Recinfo.PAYMENT_GRACE_DAYS = X_PAYMENT_GRACE_DAYS )
        OR ( ( Recinfo.PAYMENT_GRACE_DAYS IS NULL )
            AND (  X_PAYMENT_GRACE_DAYS IS NULL ) ) )
    AND ( ( Recinfo.DISCOUNT_GRACE_DAYS = X_DISCOUNT_GRACE_DAYS )
        OR ( ( Recinfo.DISCOUNT_GRACE_DAYS IS NULL )
            AND (  X_DISCOUNT_GRACE_DAYS IS NULL ) ) )
    AND ( ( Recinfo.STATEMENT_CYCLE_ID = X_STATEMENT_CYCLE_ID )
        OR ( ( Recinfo.STATEMENT_CYCLE_ID IS NULL )
            AND (  X_STATEMENT_CYCLE_ID IS NULL ) ) )
    AND ( ( Recinfo.ACCOUNT_STATUS = X_ACCOUNT_STATUS )
        OR ( ( Recinfo.ACCOUNT_STATUS IS NULL )
            AND (  X_ACCOUNT_STATUS IS NULL ) ) )
    AND ( ( Recinfo.PERCENT_COLLECTABLE = X_PERCENT_COLLECTABLE )
        OR ( ( Recinfo.PERCENT_COLLECTABLE IS NULL )
            AND (  X_PERCENT_COLLECTABLE IS NULL ) ) )
    AND ( ( Recinfo.AUTOCASH_HIERARCHY_ID = X_AUTOCASH_HIERARCHY_ID )
        OR ( ( Recinfo.AUTOCASH_HIERARCHY_ID IS NULL )
            AND (  X_AUTOCASH_HIERARCHY_ID IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY )
        OR ( ( Recinfo.ATTRIBUTE_CATEGORY IS NULL )
            AND (  X_ATTRIBUTE_CATEGORY IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE1 = X_ATTRIBUTE1 )
        OR ( ( Recinfo.ATTRIBUTE1 IS NULL )
            AND (  X_ATTRIBUTE1 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE2 = X_ATTRIBUTE2 )
        OR ( ( Recinfo.ATTRIBUTE2 IS NULL )
            AND (  X_ATTRIBUTE2 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE3 = X_ATTRIBUTE3 )
        OR ( ( Recinfo.ATTRIBUTE3 IS NULL )
            AND (  X_ATTRIBUTE3 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE4 = X_ATTRIBUTE4 )
        OR ( ( Recinfo.ATTRIBUTE4 IS NULL )
            AND (  X_ATTRIBUTE4 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE5 = X_ATTRIBUTE5 )
        OR ( ( Recinfo.ATTRIBUTE5 IS NULL )
            AND (  X_ATTRIBUTE5 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE6 = X_ATTRIBUTE6 )
        OR ( ( Recinfo.ATTRIBUTE6 IS NULL )
            AND (  X_ATTRIBUTE6 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE7 = X_ATTRIBUTE7 )
        OR ( ( Recinfo.ATTRIBUTE7 IS NULL )
            AND (  X_ATTRIBUTE7 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE8 = X_ATTRIBUTE8 )
        OR ( ( Recinfo.ATTRIBUTE8 IS NULL )
            AND (  X_ATTRIBUTE8 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE9 = X_ATTRIBUTE9 )
        OR ( ( Recinfo.ATTRIBUTE9 IS NULL )
            AND (  X_ATTRIBUTE9 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE10 = X_ATTRIBUTE10 )
        OR ( ( Recinfo.ATTRIBUTE10 IS NULL )
            AND (  X_ATTRIBUTE10 IS NULL ) ) )
    AND ( ( Recinfo.PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID )
        OR ( ( Recinfo.PROGRAM_APPLICATION_ID IS NULL )
            AND (  X_PROGRAM_APPLICATION_ID IS NULL ) ) )
    AND ( ( Recinfo.PROGRAM_ID = X_PROGRAM_ID )
        OR ( ( Recinfo.PROGRAM_ID IS NULL )
            AND (  X_PROGRAM_ID IS NULL ) ) )
    AND ( ( Recinfo.PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE )
        OR ( ( Recinfo.PROGRAM_UPDATE_DATE IS NULL )
            AND (  X_PROGRAM_UPDATE_DATE IS NULL ) ) )
    AND ( ( Recinfo.REQUEST_ID = X_REQUEST_ID )
        OR ( ( Recinfo.REQUEST_ID IS NULL )
            AND (  X_REQUEST_ID IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE11 = X_ATTRIBUTE11 )
        OR ( ( Recinfo.ATTRIBUTE11 IS NULL )
            AND (  X_ATTRIBUTE11 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE12 = X_ATTRIBUTE12 )
        OR ( ( Recinfo.ATTRIBUTE12 IS NULL )
            AND (  X_ATTRIBUTE12 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE13 = X_ATTRIBUTE13 )
        OR ( ( Recinfo.ATTRIBUTE13 IS NULL )
            AND (  X_ATTRIBUTE13 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE14 = X_ATTRIBUTE14 )
        OR ( ( Recinfo.ATTRIBUTE14 IS NULL )
            AND (  X_ATTRIBUTE14 IS NULL ) ) )
    AND ( ( Recinfo.ATTRIBUTE15 = X_ATTRIBUTE15 )
        OR ( ( Recinfo.ATTRIBUTE15 IS NULL )
            AND (  X_ATTRIBUTE15 IS NULL ) ) )
    AND ( ( Recinfo.AUTO_REC_INCL_DISPUTED_FLAG = X_AUTO_REC_INCL_DISPUTED_FLAG )
        OR ( ( Recinfo.AUTO_REC_INCL_DISPUTED_FLAG IS NULL )
            AND (  X_AUTO_REC_INCL_DISPUTED_FLAG IS NULL ) ) )
    AND ( ( Recinfo.TAX_PRINTING_OPTION = X_TAX_PRINTING_OPTION )
        OR ( ( Recinfo.TAX_PRINTING_OPTION IS NULL )
            AND (  X_TAX_PRINTING_OPTION IS NULL ) ) )
    AND ( ( Recinfo.CHARGE_ON_FINANCE_CHARGE_FLAG = X_CHARGE_ON_FINANCE_CHARGE_FG )
        OR ( ( Recinfo.CHARGE_ON_FINANCE_CHARGE_FLAG IS NULL )
            AND (  X_CHARGE_ON_FINANCE_CHARGE_FG IS NULL ) ) )
    AND ( ( Recinfo.GROUPING_RULE_ID = X_GROUPING_RULE_ID )
        OR ( ( Recinfo.GROUPING_RULE_ID IS NULL )
            AND (  X_GROUPING_RULE_ID IS NULL ) ) )
    AND ( ( Recinfo.CLEARING_DAYS = X_CLEARING_DAYS )
        OR ( ( Recinfo.CLEARING_DAYS IS NULL )
            AND (  X_CLEARING_DAYS IS NULL ) ) )
    AND ( ( Recinfo.JGZZ_ATTRIBUTE_CATEGORY = X_JGZZ_ATTRIBUTE_CATEGORY )
        OR ( ( Recinfo.JGZZ_ATTRIBUTE_CATEGORY IS NULL )
            AND (  X_JGZZ_ATTRIBUTE_CATEGORY IS NULL ) ) )
    AND ( ( Recinfo.JGZZ_ATTRIBUTE1 = X_JGZZ_ATTRIBUTE1 )
        OR ( ( Recinfo.JGZZ_ATTRIBUTE1 IS NULL )
            AND (  X_JGZZ_ATTRIBUTE1 IS NULL ) ) )
    AND ( ( Recinfo.JGZZ_ATTRIBUTE2 = X_JGZZ_ATTRIBUTE2 )
        OR ( ( Recinfo.JGZZ_ATTRIBUTE2 IS NULL )
            AND (  X_JGZZ_ATTRIBUTE2 IS NULL ) ) )
    AND ( ( Recinfo.JGZZ_ATTRIBUTE3 = X_JGZZ_ATTRIBUTE3 )
        OR ( ( Recinfo.JGZZ_ATTRIBUTE3 IS NULL )
            AND (  X_JGZZ_ATTRIBUTE3 IS NULL ) ) )
    AND ( ( Recinfo.JGZZ_ATTRIBUTE4 = X_JGZZ_ATTRIBUTE4 )
        OR ( ( Recinfo.JGZZ_ATTRIBUTE4 IS NULL )
            AND (  X_JGZZ_ATTRIBUTE4 IS NULL ) ) )
    AND ( ( Recinfo.JGZZ_ATTRIBUTE5 = X_JGZZ_ATTRIBUTE5 )
        OR ( ( Recinfo.JGZZ_ATTRIBUTE5 IS NULL )
            AND (  X_JGZZ_ATTRIBUTE5 IS NULL ) ) )
    AND ( ( Recinfo.JGZZ_ATTRIBUTE6 = X_JGZZ_ATTRIBUTE6 )
        OR ( ( Recinfo.JGZZ_ATTRIBUTE6 IS NULL )
            AND (  X_JGZZ_ATTRIBUTE6 IS NULL ) ) )
    AND ( ( Recinfo.JGZZ_ATTRIBUTE7 = X_JGZZ_ATTRIBUTE7 )
        OR ( ( Recinfo.JGZZ_ATTRIBUTE7 IS NULL )
            AND (  X_JGZZ_ATTRIBUTE7 IS NULL ) ) )
    AND ( ( Recinfo.JGZZ_ATTRIBUTE8 = X_JGZZ_ATTRIBUTE8 )
        OR ( ( Recinfo.JGZZ_ATTRIBUTE8 IS NULL )
            AND (  X_JGZZ_ATTRIBUTE8 IS NULL ) ) )
    AND ( ( Recinfo.JGZZ_ATTRIBUTE9 = X_JGZZ_ATTRIBUTE9 )
        OR ( ( Recinfo.JGZZ_ATTRIBUTE9 IS NULL )
            AND (  X_JGZZ_ATTRIBUTE9 IS NULL ) ) )
    AND ( ( Recinfo.JGZZ_ATTRIBUTE10 = X_JGZZ_ATTRIBUTE10 )
        OR ( ( Recinfo.JGZZ_ATTRIBUTE10 IS NULL )
            AND (  X_JGZZ_ATTRIBUTE10 IS NULL ) ) )
    AND ( ( Recinfo.JGZZ_ATTRIBUTE11 = X_JGZZ_ATTRIBUTE11 )
        OR ( ( Recinfo.JGZZ_ATTRIBUTE11 IS NULL )
            AND (  X_JGZZ_ATTRIBUTE11 IS NULL ) ) )
    AND ( ( Recinfo.JGZZ_ATTRIBUTE12 = X_JGZZ_ATTRIBUTE12 )
        OR ( ( Recinfo.JGZZ_ATTRIBUTE12 IS NULL )
            AND (  X_JGZZ_ATTRIBUTE12 IS NULL ) ) )
    AND ( ( Recinfo.JGZZ_ATTRIBUTE13 = X_JGZZ_ATTRIBUTE13 )
        OR ( ( Recinfo.JGZZ_ATTRIBUTE13 IS NULL )
            AND (  X_JGZZ_ATTRIBUTE13 IS NULL ) ) )
    AND ( ( Recinfo.JGZZ_ATTRIBUTE14 = X_JGZZ_ATTRIBUTE14 )
        OR ( ( Recinfo.JGZZ_ATTRIBUTE14 IS NULL )
            AND (  X_JGZZ_ATTRIBUTE14 IS NULL ) ) )
    AND ( ( Recinfo.JGZZ_ATTRIBUTE15 = X_JGZZ_ATTRIBUTE15 )
        OR ( ( Recinfo.JGZZ_ATTRIBUTE15 IS NULL )
            AND (  X_JGZZ_ATTRIBUTE15 IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_ATTRIBUTE1 = X_GLOBAL_ATTRIBUTE1 )
        OR ( ( Recinfo.GLOBAL_ATTRIBUTE1 IS NULL )
            AND (  X_GLOBAL_ATTRIBUTE1 IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_ATTRIBUTE2 = X_GLOBAL_ATTRIBUTE2 )
        OR ( ( Recinfo.GLOBAL_ATTRIBUTE2 IS NULL )
            AND (  X_GLOBAL_ATTRIBUTE2 IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_ATTRIBUTE3 = X_GLOBAL_ATTRIBUTE3 )
        OR ( ( Recinfo.GLOBAL_ATTRIBUTE3 IS NULL )
            AND (  X_GLOBAL_ATTRIBUTE3 IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_ATTRIBUTE4 = X_GLOBAL_ATTRIBUTE4 )
        OR ( ( Recinfo.GLOBAL_ATTRIBUTE4 IS NULL )
            AND (  X_GLOBAL_ATTRIBUTE4 IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_ATTRIBUTE5 = X_GLOBAL_ATTRIBUTE5 )
        OR ( ( Recinfo.GLOBAL_ATTRIBUTE5 IS NULL )
            AND (  X_GLOBAL_ATTRIBUTE5 IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_ATTRIBUTE6 = X_GLOBAL_ATTRIBUTE6 )
        OR ( ( Recinfo.GLOBAL_ATTRIBUTE6 IS NULL )
            AND (  X_GLOBAL_ATTRIBUTE6 IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_ATTRIBUTE7 = X_GLOBAL_ATTRIBUTE7 )
        OR ( ( Recinfo.GLOBAL_ATTRIBUTE7 IS NULL )
            AND (  X_GLOBAL_ATTRIBUTE7 IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_ATTRIBUTE8 = X_GLOBAL_ATTRIBUTE8 )
        OR ( ( Recinfo.GLOBAL_ATTRIBUTE8 IS NULL )
            AND (  X_GLOBAL_ATTRIBUTE8 IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_ATTRIBUTE9 = X_GLOBAL_ATTRIBUTE9 )
        OR ( ( Recinfo.GLOBAL_ATTRIBUTE9 IS NULL )
            AND (  X_GLOBAL_ATTRIBUTE9 IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_ATTRIBUTE10 = X_GLOBAL_ATTRIBUTE10 )
        OR ( ( Recinfo.GLOBAL_ATTRIBUTE10 IS NULL )
            AND (  X_GLOBAL_ATTRIBUTE10 IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_ATTRIBUTE11 = X_GLOBAL_ATTRIBUTE11 )
        OR ( ( Recinfo.GLOBAL_ATTRIBUTE11 IS NULL )
            AND (  X_GLOBAL_ATTRIBUTE11 IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_ATTRIBUTE12 = X_GLOBAL_ATTRIBUTE12 )
        OR ( ( Recinfo.GLOBAL_ATTRIBUTE12 IS NULL )
            AND (  X_GLOBAL_ATTRIBUTE12 IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_ATTRIBUTE13 = X_GLOBAL_ATTRIBUTE13 )
        OR ( ( Recinfo.GLOBAL_ATTRIBUTE13 IS NULL )
            AND (  X_GLOBAL_ATTRIBUTE13 IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_ATTRIBUTE14 = X_GLOBAL_ATTRIBUTE14 )
        OR ( ( Recinfo.GLOBAL_ATTRIBUTE14 IS NULL )
            AND (  X_GLOBAL_ATTRIBUTE14 IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_ATTRIBUTE15 = X_GLOBAL_ATTRIBUTE15 )
        OR ( ( Recinfo.GLOBAL_ATTRIBUTE15 IS NULL )
            AND (  X_GLOBAL_ATTRIBUTE15 IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_ATTRIBUTE16 = X_GLOBAL_ATTRIBUTE16 )
        OR ( ( Recinfo.GLOBAL_ATTRIBUTE16 IS NULL )
            AND (  X_GLOBAL_ATTRIBUTE16 IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_ATTRIBUTE17 = X_GLOBAL_ATTRIBUTE17 )
        OR ( ( Recinfo.GLOBAL_ATTRIBUTE17 IS NULL )
            AND (  X_GLOBAL_ATTRIBUTE17 IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_ATTRIBUTE18 = X_GLOBAL_ATTRIBUTE18 )
        OR ( ( Recinfo.GLOBAL_ATTRIBUTE18 IS NULL )
            AND (  X_GLOBAL_ATTRIBUTE18 IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_ATTRIBUTE19 = X_GLOBAL_ATTRIBUTE19 )
        OR ( ( Recinfo.GLOBAL_ATTRIBUTE19 IS NULL )
            AND (  X_GLOBAL_ATTRIBUTE19 IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_ATTRIBUTE20 = X_GLOBAL_ATTRIBUTE20 )
        OR ( ( Recinfo.GLOBAL_ATTRIBUTE20 IS NULL )
            AND (  X_GLOBAL_ATTRIBUTE20 IS NULL ) ) )
    AND ( ( Recinfo.GLOBAL_ATTRIBUTE_CATEGORY = X_GLOBAL_ATTRIBUTE_CATEGORY )
        OR ( ( Recinfo.GLOBAL_ATTRIBUTE_CATEGORY IS NULL )
            AND (  X_GLOBAL_ATTRIBUTE_CATEGORY IS NULL ) ) )
    AND ( ( Recinfo.CONS_INV_FLAG = X_CONS_INV_FLAG )
        OR ( ( Recinfo.CONS_INV_FLAG IS NULL )
            AND (  X_CONS_INV_FLAG IS NULL ) ) )
    AND ( ( Recinfo.CONS_INV_TYPE = X_CONS_INV_TYPE )
        OR ( ( Recinfo.CONS_INV_TYPE IS NULL )
            AND (  X_CONS_INV_TYPE IS NULL ) ) )
    AND ( ( Recinfo.AUTOCASH_HIERARCHY_ID_FOR_ADR = X_AUTOCASH_HIERARCHY_ID_ADR )
        OR ( ( Recinfo.AUTOCASH_HIERARCHY_ID_FOR_ADR IS NULL )
            AND (  X_AUTOCASH_HIERARCHY_ID_ADR IS NULL ) ) )
    AND ( ( Recinfo.LOCKBOX_MATCHING_OPTION = X_LOCKBOX_MATCHING_OPTION )
        OR ( ( Recinfo.LOCKBOX_MATCHING_OPTION IS NULL )
            AND (  X_LOCKBOX_MATCHING_OPTION IS NULL ) ) )
    AND ( ( Recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER )
        OR ( ( Recinfo.OBJECT_VERSION_NUMBER IS NULL )
            AND (  X_OBJECT_VERSION_NUMBER IS NULL ) ) )
    AND ( ( Recinfo.CREATED_BY_MODULE = X_CREATED_BY_MODULE )
        OR ( ( Recinfo.CREATED_BY_MODULE IS NULL )
            AND (  X_CREATED_BY_MODULE IS NULL ) ) )
    AND ( ( Recinfo.APPLICATION_ID = X_APPLICATION_ID )
        OR ( ( Recinfo.APPLICATION_ID IS NULL )
            AND (  X_APPLICATION_ID IS NULL ) ) )
    AND ( ( Recinfo.REVIEW_CYCLE   = X_REVIEW_CYCLE )
        OR ( ( Recinfo.REVIEW_CYCLE IS NULL )
            AND ( X_REVIEW_CYCLE IS NULL ) ) )
    AND ( ( Recinfo.LAST_CREDIT_REVIEW_DATE   = X_LAST_CREDIT_REVIEW_DATE )
        OR ( ( Recinfo.LAST_CREDIT_REVIEW_DATE IS NULL )
            AND ( X_LAST_CREDIT_REVIEW_DATE IS NULL ) ) )
    AND ( ( Recinfo.PARTY_ID   = X_PARTY_ID )
        OR ( ( Recinfo.PARTY_ID IS NULL )
            AND ( X_PARTY_ID IS NULL ) ) )
    AND ( ( Recinfo.CREDIT_CLASSIFICATION = X_CREDIT_CLASSIFICATION)
        OR (( Recinfo.CREDIT_CLASSIFICATION IS NULL )
            AND ( X_CREDIT_CLASSIFICATION IS NULL ) ) )
    AND ( ( Recinfo.CONS_BILL_LEVEL = X_CONS_BILL_LEVEL )
        OR ( ( Recinfo.CONS_BILL_LEVEL IS NULL )
            AND (  X_CONS_BILL_LEVEL IS NULL ) ) )
    AND ( ( Recinfo.LATE_CHARGE_CALCULATION_TRX = X_LATE_CHARGE_CALCULATION_TRX )
        OR ( ( Recinfo.LATE_CHARGE_CALCULATION_TRX IS NULL )
            AND (  X_LATE_CHARGE_CALCULATION_TRX IS NULL ) ) )
    AND ( ( Recinfo.CREDIT_ITEMS_FLAG = X_CREDIT_ITEMS_FLAG )
        OR ( ( Recinfo.CREDIT_ITEMS_FLAG IS NULL )
            AND (  X_CREDIT_ITEMS_FLAG IS NULL ) ) )
    AND ( ( Recinfo.DISPUTED_TRANSACTIONS_FLAG = X_DISPUTED_TRANSACTIONS_FLAG )
        OR ( ( Recinfo.DISPUTED_TRANSACTIONS_FLAG IS NULL )
            AND (  X_DISPUTED_TRANSACTIONS_FLAG IS NULL ) ) )
    AND ( ( Recinfo.LATE_CHARGE_TYPE = X_LATE_CHARGE_TYPE )
        OR ( ( Recinfo.LATE_CHARGE_TYPE IS NULL )
            AND (  X_LATE_CHARGE_TYPE IS NULL ) ) )
    AND ( ( Recinfo.LATE_CHARGE_TERM_ID = X_LATE_CHARGE_TERM_ID )
        OR ( ( Recinfo.LATE_CHARGE_TERM_ID IS NULL )
            AND (  X_LATE_CHARGE_TERM_ID IS NULL ) ) )
    AND ( ( Recinfo.INTEREST_CALCULATION_PERIOD = X_INTEREST_CALCULATION_PERIOD )
        OR ( ( Recinfo.INTEREST_CALCULATION_PERIOD IS NULL )
            AND (  X_INTEREST_CALCULATION_PERIOD IS NULL ) ) )
    AND ( ( Recinfo.HOLD_CHARGED_INVOICES_FLAG = X_HOLD_CHARGED_INVOICES_FLAG )
        OR ( ( Recinfo.HOLD_CHARGED_INVOICES_FLAG IS NULL )
            AND (  X_HOLD_CHARGED_INVOICES_FLAG IS NULL ) ) )
    AND ( ( Recinfo.MESSAGE_TEXT_ID = X_MESSAGE_TEXT_ID )
        OR ( ( Recinfo.MESSAGE_TEXT_ID IS NULL )
            AND (  X_MESSAGE_TEXT_ID IS NULL ) ) )
    AND ( ( Recinfo.MULTIPLE_INTEREST_RATES_FLAG = X_MULTIPLE_INTEREST_RATES_FLAG )
        OR ( ( Recinfo.MULTIPLE_INTEREST_RATES_FLAG IS NULL )
            AND (  X_MULTIPLE_INTEREST_RATES_FLAG IS NULL ) ) )
    AND ( ( Recinfo.CHARGE_BEGIN_DATE = X_CHARGE_BEGIN_DATE )
        OR ( ( Recinfo.CHARGE_BEGIN_DATE IS NULL )
            AND (  X_CHARGE_BEGIN_DATE IS NULL ) ) )
    AND ( ( Recinfo.AUTOMATCH_SET_ID = X_AUTOMATCH_SET_ID )
        OR ( ( Recinfo.AUTOMATCH_SET_ID IS NULL )
            AND (  X_AUTOMATCH_SET_ID IS NULL ) ) )
    ) THEN
        RETURN;
    ELSE
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

END Lock_Row;

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
    X_PARTY_ID                             OUT NOCOPY     NUMBER  ,
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
) IS

BEGIN

    SELECT
        NVL( CUST_ACCOUNT_PROFILE_ID, FND_API.G_MISS_NUM ),
        NVL( CUST_ACCOUNT_ID, FND_API.G_MISS_NUM ),
        NVL( STATUS, FND_API.G_MISS_CHAR ),
        NVL( COLLECTOR_ID, FND_API.G_MISS_NUM ),
        NVL( CREDIT_ANALYST_ID, FND_API.G_MISS_NUM ),
        NVL( CREDIT_CHECKING, FND_API.G_MISS_CHAR ),
        NVL( NEXT_CREDIT_REVIEW_DATE, FND_API.G_MISS_DATE ),
        NVL( TOLERANCE, FND_API.G_MISS_NUM ),
        NVL( DISCOUNT_TERMS, FND_API.G_MISS_CHAR ),
        NVL( DUNNING_LETTERS, FND_API.G_MISS_CHAR ),
        NVL( INTEREST_CHARGES, FND_API.G_MISS_CHAR ),
        NVL( SEND_STATEMENTS, FND_API.G_MISS_CHAR ),
        NVL( CREDIT_BALANCE_STATEMENTS, FND_API.G_MISS_CHAR ),
        NVL( CREDIT_HOLD, FND_API.G_MISS_CHAR ),
        NVL( PROFILE_CLASS_ID, FND_API.G_MISS_NUM ),
        NVL( SITE_USE_ID, FND_API.G_MISS_NUM ),
        NVL( CREDIT_RATING, FND_API.G_MISS_CHAR ),
        NVL( RISK_CODE, FND_API.G_MISS_CHAR ),
        NVL( STANDARD_TERMS, FND_API.G_MISS_NUM ),
        NVL( OVERRIDE_TERMS, FND_API.G_MISS_CHAR ),
        NVL( DUNNING_LETTER_SET_ID, FND_API.G_MISS_NUM ),
        NVL( INTEREST_PERIOD_DAYS, FND_API.G_MISS_NUM ),
        NVL( PAYMENT_GRACE_DAYS, FND_API.G_MISS_NUM ),
        NVL( DISCOUNT_GRACE_DAYS, FND_API.G_MISS_NUM ),
        NVL( STATEMENT_CYCLE_ID, FND_API.G_MISS_NUM ),
        NVL( ACCOUNT_STATUS, FND_API.G_MISS_CHAR ),
        NVL( PERCENT_COLLECTABLE, FND_API.G_MISS_NUM ),
        NVL( AUTOCASH_HIERARCHY_ID, FND_API.G_MISS_NUM ),
        NVL( ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE1, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE2, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE3, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE4, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE5, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE6, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE7, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE8, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE9, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE10, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE11, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE12, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE13, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE14, FND_API.G_MISS_CHAR ),
        NVL( ATTRIBUTE15, FND_API.G_MISS_CHAR ),
        NVL( AUTO_REC_INCL_DISPUTED_FLAG, FND_API.G_MISS_CHAR ),
        NVL( TAX_PRINTING_OPTION, FND_API.G_MISS_CHAR ),
        NVL( CHARGE_ON_FINANCE_CHARGE_FLAG, FND_API.G_MISS_CHAR ),
        NVL( GROUPING_RULE_ID, FND_API.G_MISS_NUM ),
        NVL( CLEARING_DAYS, FND_API.G_MISS_NUM ),
        NVL( JGZZ_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR ),
        NVL( JGZZ_ATTRIBUTE1, FND_API.G_MISS_CHAR ),
        NVL( JGZZ_ATTRIBUTE2, FND_API.G_MISS_CHAR ),
        NVL( JGZZ_ATTRIBUTE3, FND_API.G_MISS_CHAR ),
        NVL( JGZZ_ATTRIBUTE4, FND_API.G_MISS_CHAR ),
        NVL( JGZZ_ATTRIBUTE5, FND_API.G_MISS_CHAR ),
        NVL( JGZZ_ATTRIBUTE6, FND_API.G_MISS_CHAR ),
        NVL( JGZZ_ATTRIBUTE7, FND_API.G_MISS_CHAR ),
        NVL( JGZZ_ATTRIBUTE8, FND_API.G_MISS_CHAR ),
        NVL( JGZZ_ATTRIBUTE9, FND_API.G_MISS_CHAR ),
        NVL( JGZZ_ATTRIBUTE10, FND_API.G_MISS_CHAR ),
        NVL( JGZZ_ATTRIBUTE11, FND_API.G_MISS_CHAR ),
        NVL( JGZZ_ATTRIBUTE12, FND_API.G_MISS_CHAR ),
        NVL( JGZZ_ATTRIBUTE13, FND_API.G_MISS_CHAR ),
        NVL( JGZZ_ATTRIBUTE14, FND_API.G_MISS_CHAR ),
        NVL( JGZZ_ATTRIBUTE15, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_ATTRIBUTE1, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_ATTRIBUTE2, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_ATTRIBUTE3, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_ATTRIBUTE4, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_ATTRIBUTE5, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_ATTRIBUTE6, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_ATTRIBUTE7, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_ATTRIBUTE8, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_ATTRIBUTE9, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_ATTRIBUTE10, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_ATTRIBUTE11, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_ATTRIBUTE12, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_ATTRIBUTE13, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_ATTRIBUTE14, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_ATTRIBUTE15, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_ATTRIBUTE16, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_ATTRIBUTE17, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_ATTRIBUTE18, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_ATTRIBUTE19, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_ATTRIBUTE20, FND_API.G_MISS_CHAR ),
        NVL( GLOBAL_ATTRIBUTE_CATEGORY, FND_API.G_MISS_CHAR ),
        NVL( CONS_INV_FLAG, FND_API.G_MISS_CHAR ),
        NVL( CONS_INV_TYPE, FND_API.G_MISS_CHAR ),
        NVL( AUTOCASH_HIERARCHY_ID_FOR_ADR, FND_API.G_MISS_NUM ),
        NVL( LOCKBOX_MATCHING_OPTION, FND_API.G_MISS_CHAR ),
        NVL( CREATED_BY_MODULE, FND_API.G_MISS_CHAR ),
        NVL( APPLICATION_ID, FND_API.G_MISS_NUM ),
        NVL(REVIEW_CYCLE     , FND_API.G_MISS_CHAR),
        NVL(LAST_CREDIT_REVIEW_DATE , FND_API.G_MISS_DATE),
        NVL(PARTY_ID         , FND_API.G_MISS_NUM),
        NVL(CREDIT_CLASSIFICATION , FND_API.G_MISS_CHAR),
        NVL(CONS_BILL_LEVEL, FND_API.G_MISS_CHAR),
        NVL(LATE_CHARGE_CALCULATION_TRX, FND_API.G_MISS_CHAR),
        NVL(CREDIT_ITEMS_FLAG, FND_API.G_MISS_CHAR),
        NVL(DISPUTED_TRANSACTIONS_FLAG, FND_API.G_MISS_CHAR),
        NVL(LATE_CHARGE_TYPE, FND_API.G_MISS_CHAR),
        NVL(LATE_CHARGE_TERM_ID, FND_API.G_MISS_NUM),
        NVL(INTEREST_CALCULATION_PERIOD, FND_API.G_MISS_CHAR),
        NVL(HOLD_CHARGED_INVOICES_FLAG, FND_API.G_MISS_CHAR),
        NVL(MESSAGE_TEXT_ID, FND_API.G_MISS_NUM),
        NVL(MULTIPLE_INTEREST_RATES_FLAG, FND_API.G_MISS_CHAR),
        NVL(CHARGE_BEGIN_DATE, FND_API.G_MISS_DATE),
        NVL(AUTOMATCH_SET_ID, FND_API.G_MISS_NUM)
    INTO
        X_CUST_ACCOUNT_PROFILE_ID,
        X_CUST_ACCOUNT_ID,
        X_STATUS,
        X_COLLECTOR_ID,
        X_CREDIT_ANALYST_ID,
        X_CREDIT_CHECKING,
        X_NEXT_CREDIT_REVIEW_DATE,
        X_TOLERANCE,
        X_DISCOUNT_TERMS,
        X_DUNNING_LETTERS,
        X_INTEREST_CHARGES,
        X_SEND_STATEMENTS,
        X_CREDIT_BALANCE_STATEMENTS,
        X_CREDIT_HOLD,
        X_PROFILE_CLASS_ID,
        X_SITE_USE_ID,
        X_CREDIT_RATING,
        X_RISK_CODE,
        X_STANDARD_TERMS,
        X_OVERRIDE_TERMS,
        X_DUNNING_LETTER_SET_ID,
        X_INTEREST_PERIOD_DAYS,
        X_PAYMENT_GRACE_DAYS,
        X_DISCOUNT_GRACE_DAYS,
        X_STATEMENT_CYCLE_ID,
        X_ACCOUNT_STATUS,
        X_PERCENT_COLLECTABLE,
        X_AUTOCASH_HIERARCHY_ID,
        X_ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1,
        X_ATTRIBUTE2,
        X_ATTRIBUTE3,
        X_ATTRIBUTE4,
        X_ATTRIBUTE5,
        X_ATTRIBUTE6,
        X_ATTRIBUTE7,
        X_ATTRIBUTE8,
        X_ATTRIBUTE9,
        X_ATTRIBUTE10,
        X_ATTRIBUTE11,
        X_ATTRIBUTE12,
        X_ATTRIBUTE13,
        X_ATTRIBUTE14,
        X_ATTRIBUTE15,
        X_AUTO_REC_INCL_DISPUTED_FLAG,
        X_TAX_PRINTING_OPTION,
        X_CHARGE_ON_FINANCE_CHARGE_FG,
        X_GROUPING_RULE_ID,
        X_CLEARING_DAYS,
        X_JGZZ_ATTRIBUTE_CATEGORY,
        X_JGZZ_ATTRIBUTE1,
        X_JGZZ_ATTRIBUTE2,
        X_JGZZ_ATTRIBUTE3,
        X_JGZZ_ATTRIBUTE4,
        X_JGZZ_ATTRIBUTE5,
        X_JGZZ_ATTRIBUTE6,
        X_JGZZ_ATTRIBUTE7,
        X_JGZZ_ATTRIBUTE8,
        X_JGZZ_ATTRIBUTE9,
        X_JGZZ_ATTRIBUTE10,
        X_JGZZ_ATTRIBUTE11,
        X_JGZZ_ATTRIBUTE12,
        X_JGZZ_ATTRIBUTE13,
        X_JGZZ_ATTRIBUTE14,
        X_JGZZ_ATTRIBUTE15,
        X_GLOBAL_ATTRIBUTE1,
        X_GLOBAL_ATTRIBUTE2,
        X_GLOBAL_ATTRIBUTE3,
        X_GLOBAL_ATTRIBUTE4,
        X_GLOBAL_ATTRIBUTE5,
        X_GLOBAL_ATTRIBUTE6,
        X_GLOBAL_ATTRIBUTE7,
        X_GLOBAL_ATTRIBUTE8,
        X_GLOBAL_ATTRIBUTE9,
        X_GLOBAL_ATTRIBUTE10,
        X_GLOBAL_ATTRIBUTE11,
        X_GLOBAL_ATTRIBUTE12,
        X_GLOBAL_ATTRIBUTE13,
        X_GLOBAL_ATTRIBUTE14,
        X_GLOBAL_ATTRIBUTE15,
        X_GLOBAL_ATTRIBUTE16,
        X_GLOBAL_ATTRIBUTE17,
        X_GLOBAL_ATTRIBUTE18,
        X_GLOBAL_ATTRIBUTE19,
        X_GLOBAL_ATTRIBUTE20,
        X_GLOBAL_ATTRIBUTE_CATEGORY,
        X_CONS_INV_FLAG,
        X_CONS_INV_TYPE,
        X_AUTOCASH_HIERARCHY_ID_ADR,
        X_LOCKBOX_MATCHING_OPTION,
        X_CREATED_BY_MODULE,
        X_APPLICATION_ID,
        X_REVIEW_CYCLE    ,
        X_LAST_CREDIT_REVIEW_DATE,
        X_PARTY_ID    ,
        X_CREDIT_CLASSIFICATION,
        X_CONS_BILL_LEVEL,
        X_LATE_CHARGE_CALCULATION_TRX,
        X_CREDIT_ITEMS_FLAG,
        X_DISPUTED_TRANSACTIONS_FLAG,
        X_LATE_CHARGE_TYPE,
        X_LATE_CHARGE_TERM_ID,
        X_INTEREST_CALCULATION_PERIOD,
        X_HOLD_CHARGED_INVOICES_FLAG,
        X_MESSAGE_TEXT_ID,
        X_MULTIPLE_INTEREST_RATES_FLAG,
        X_CHARGE_BEGIN_DATE,
        X_AUTOMATCH_SET_ID
    FROM HZ_CUSTOMER_PROFILES
    WHERE CUST_ACCOUNT_PROFILE_ID = X_CUST_ACCOUNT_PROFILE_ID;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
        FND_MESSAGE.SET_TOKEN( 'RECORD', 'customer_profile_rec');
        FND_MESSAGE.SET_TOKEN( 'VALUE', TO_CHAR( X_CUST_ACCOUNT_PROFILE_ID ) );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

END Select_Row;

PROCEDURE Delete_Row (
    X_CUST_ACCOUNT_PROFILE_ID               IN     NUMBER
) IS

BEGIN

    DELETE FROM HZ_CUSTOMER_PROFILES
    WHERE CUST_ACCOUNT_PROFILE_ID = X_CUST_ACCOUNT_PROFILE_ID;

    IF ( SQL%NOTFOUND ) THEN
        RAISE NO_DATA_FOUND;
    END IF;

END Delete_Row;

END HZ_CUSTOMER_PROFILES_PKG;

/
