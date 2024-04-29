--------------------------------------------------------
--  DDL for Package Body PV_REFERRALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_REFERRALS_PKG" as
/* $Header: pvreferralb.pls 120.3 2006/04/18 15:39:39 saarumug ship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_REFERRAL_ID in NUMBER,
  X_ACTUAL_CURRENCY_CODE in VARCHAR2,
  X_BENEFIT_TYPE_CODE in VARCHAR2,
  X_CUSTOMER_CONTACT_PHONE_TYPE in VARCHAR2,
  X_CUSTOMER_CONTACT_EMAIL_ADDRE in VARCHAR2,
  X_CUSTOMER_CONTACT_PHONE_EXT in VARCHAR2,
  X_DECLINE_REASON_CODE in VARCHAR2,
  X_ENTITY_TYPE in VARCHAR2,
  X_ORDER_ID in NUMBER,
  X_CLAIM_ID in NUMBER,
  X_CLAIM_NUMBER in VARCHAR2,
  X_EST_COMPENSATION_AMT in NUMBER,
  X_CURRENCY_CODE in VARCHAR2,
  X_ACTUAL_COMPENSATION_AMT in NUMBER,
  X_STATUS_CHANGE_DATE in DATE,
  X_DUPLICATE_CUSTOMER_FLAG in VARCHAR2,
  X_PARTNER_CUST_ACCOUNT_ID in NUMBER,
  X_CUSTOMER_COUNTRY in VARCHAR2,
  X_CUSTOMER_CONTACT_TITLE in VARCHAR2,
  X_CUSTOMER_CONTACT_FIRST_NAME in VARCHAR2,
  X_CUSTOMER_CONTACT_LAST_NAME in VARCHAR2,
  X_CUSTOMER_CONTACT_CNTRY_CODE in VARCHAR2,
  X_CUSTOMER_CONTACT_AREA_CODE in VARCHAR2,
  X_CUSTOMER_CONTACT_PHONE_NO in VARCHAR2,
  X_CUSTOMER_PROVINCE in VARCHAR2,
  X_CUSTOMER_POSTAL_CODE in VARCHAR2,
  X_CUSTOMER_COUNTY in VARCHAR2,
  X_ENTITY_ID_LINKED_TO in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_BENEFIT_ID in NUMBER,
  X_REFERRAL_CODE in VARCHAR2,
  X_REFERRAL_STATUS in VARCHAR2,
  X_PARTNER_ID in NUMBER,
  X_PARTNER_CONTACT_RESOURCE_ID in NUMBER,
  X_CUSTOMER_PARTY_ID in NUMBER,
  X_CUSTOMER_ORG_CONTACT_ID in NUMBER,
  X_CUSTOMER_CONTACT_PARTY_ID in NUMBER,
  X_CUSTOMER_PARTY_SITE_ID in NUMBER,
  X_CUSTOMER_NAME in VARCHAR2,
  X_CUSTOMER_ADDRESS_TYPE in VARCHAR2,
  X_CUSTOMER_ADDRESS1 in VARCHAR2,
  X_CUSTOMER_ADDRESS2 in VARCHAR2,
  X_CUSTOMER_ADDRESS3 in VARCHAR2,
  X_CUSTOMER_ADDRESS4 in VARCHAR2,
  X_ADDRESS_LINES_PHONETIC in VARCHAR2,
  X_CUSTOMER_CITY in VARCHAR2,
  X_CUSTOMER_STATE in VARCHAR2,
  X_REFERRAL_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORG_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_CUSTOMER_NAME_PRONOUNCIATION in VARCHAR2,
  X_RETURN_REASON_CODE in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1  in VARCHAR2,
  X_ATTRIBUTE2  in VARCHAR2,
  X_ATTRIBUTE3  in VARCHAR2,
  X_ATTRIBUTE4  in VARCHAR2,
  X_ATTRIBUTE5   in VARCHAR2,
  X_ATTRIBUTE6   in VARCHAR2,
  X_ATTRIBUTE7   in VARCHAR2,
  X_ATTRIBUTE8   in VARCHAR2,
  X_ATTRIBUTE9   in VARCHAR2,
  X_ATTRIBUTE10  in VARCHAR2,
  X_ATTRIBUTE11  in VARCHAR2,
  X_ATTRIBUTE12  in VARCHAR2,
  X_ATTRIBUTE13  in VARCHAR2,
  X_ATTRIBUTE14  in VARCHAR2,
  X_ATTRIBUTE15  in VARCHAR2,
  X_ATTRIBUTE16  in VARCHAR2,
  X_ATTRIBUTE17  in VARCHAR2,
  X_ATTRIBUTE18  in VARCHAR2,
  X_ATTRIBUTE19  in VARCHAR2,
  X_ATTRIBUTE20  in VARCHAR2,
  X_ATTRIBUTE21  in VARCHAR2,
  X_ATTRIBUTE22  in VARCHAR2,
  X_ATTRIBUTE23  in VARCHAR2,
  X_ATTRIBUTE24  in VARCHAR2
) is
  cursor C is select ROWID from PV_REFERRALS_B
    where REFERRAL_ID = X_REFERRAL_ID
    ;
begin
  insert into PV_REFERRALS_B (
    ACTUAL_CURRENCY_CODE,
    BENEFIT_TYPE_CODE,
    REFERRAL_ID,
    CUSTOMER_CONTACT_PHONE_TYPE,
    CUSTOMER_CONTACT_EMAIL_ADDRESS,
    CUSTOMER_CONTACT_PHONE_EXT,
    DECLINE_REASON_CODE,
    ENTITY_TYPE,
    ORDER_ID,
    CLAIM_ID,
    CLAIM_NUMBER,
    EST_COMPENSATION_AMT,
    CURRENCY_CODE,
    ACTUAL_COMPENSATION_AMT,
    STATUS_CHANGE_DATE,
    DUPLICATE_CUSTOMER_FLAG,
    PARTNER_CUST_ACCOUNT_ID,
    CUSTOMER_COUNTRY,
    CUSTOMER_CONTACT_TITLE,
    CUSTOMER_CONTACT_FIRST_NAME,
    CUSTOMER_CONTACT_LAST_NAME,
    CUSTOMER_CONTACT_CNTRY_CODE,
    CUSTOMER_CONTACT_AREA_CODE,
    CUSTOMER_CONTACT_PHONE_NO,
    CUSTOMER_PROVINCE,
    CUSTOMER_POSTAL_CODE,
    CUSTOMER_COUNTY,
    ENTITY_ID_LINKED_TO,
    OBJECT_VERSION_NUMBER,
    BENEFIT_ID,
    REFERRAL_CODE,
    REFERRAL_STATUS,
    PARTNER_ID,
    PARTNER_CONTACT_RESOURCE_ID,
    CUSTOMER_PARTY_ID,
    CUSTOMER_ORG_CONTACT_ID,
    CUSTOMER_CONTACT_PARTY_ID,
    CUSTOMER_PARTY_SITE_ID,
    CUSTOMER_NAME,
    CUSTOMER_ADDRESS_TYPE,
    CUSTOMER_ADDRESS1,
    CUSTOMER_ADDRESS2,
    CUSTOMER_ADDRESS3,
    CUSTOMER_ADDRESS4,
    ADDRESS_LINES_PHONETIC,
    CUSTOMER_CITY,
    CUSTOMER_STATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID,
    SECURITY_GROUP_ID,
    CUSTOMER_NAME_PRONOUNCIATION,
    RETURN_REASON_CODE,
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
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE16,
    ATTRIBUTE17,
    ATTRIBUTE18,
    ATTRIBUTE19,
    ATTRIBUTE20,
    ATTRIBUTE21,
    ATTRIBUTE22,
    ATTRIBUTE23,
    ATTRIBUTE24
  ) values (
    X_ACTUAL_CURRENCY_CODE,
    X_BENEFIT_TYPE_CODE,
    X_REFERRAL_ID,
    X_CUSTOMER_CONTACT_PHONE_TYPE,
    X_CUSTOMER_CONTACT_EMAIL_ADDRE,
    X_CUSTOMER_CONTACT_PHONE_EXT,
    X_DECLINE_REASON_CODE,
    X_ENTITY_TYPE,
    X_ORDER_ID,
    X_CLAIM_ID,
    X_CLAIM_NUMBER,
    X_EST_COMPENSATION_AMT,
    X_CURRENCY_CODE,
    X_ACTUAL_COMPENSATION_AMT,
    X_STATUS_CHANGE_DATE,
    X_DUPLICATE_CUSTOMER_FLAG,
    X_PARTNER_CUST_ACCOUNT_ID,
    X_CUSTOMER_COUNTRY,
    X_CUSTOMER_CONTACT_TITLE,
    X_CUSTOMER_CONTACT_FIRST_NAME,
    X_CUSTOMER_CONTACT_LAST_NAME,
    X_CUSTOMER_CONTACT_CNTRY_CODE,
    X_CUSTOMER_CONTACT_AREA_CODE,
    X_CUSTOMER_CONTACT_PHONE_NO,
    X_CUSTOMER_PROVINCE,
    X_CUSTOMER_POSTAL_CODE,
    X_CUSTOMER_COUNTY,
    X_ENTITY_ID_LINKED_TO,
    X_OBJECT_VERSION_NUMBER,
    X_BENEFIT_ID,
    X_REFERRAL_CODE,
    X_REFERRAL_STATUS,
    X_PARTNER_ID,
    X_PARTNER_CONTACT_RESOURCE_ID,
    X_CUSTOMER_PARTY_ID,
    X_CUSTOMER_ORG_CONTACT_ID,
    X_CUSTOMER_CONTACT_PARTY_ID,
    X_CUSTOMER_PARTY_SITE_ID,
    X_CUSTOMER_NAME,
    X_CUSTOMER_ADDRESS_TYPE,
    X_CUSTOMER_ADDRESS1,
    X_CUSTOMER_ADDRESS2,
    X_CUSTOMER_ADDRESS3,
    X_CUSTOMER_ADDRESS4,
    X_ADDRESS_LINES_PHONETIC,
    X_CUSTOMER_CITY,
    X_CUSTOMER_STATE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ORG_ID,
    X_SECURITY_GROUP_ID,
    X_CUSTOMER_NAME_PRONOUNCIATION,
    X_RETURN_REASON_CODE,
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
    X_ATTRIBUTE16,
    X_ATTRIBUTE17,
    X_ATTRIBUTE18,
    X_ATTRIBUTE19,
    X_ATTRIBUTE20,
    X_ATTRIBUTE21,
    X_ATTRIBUTE22,
    X_ATTRIBUTE23,
    X_ATTRIBUTE24
  );

  insert into PV_REFERRALS_TL (
    CREATION_DATE,
    CREATED_BY,
    REFERRAL_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    REFERRAL_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CREATION_DATE,
    X_CREATED_BY,
    X_REFERRAL_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_OBJECT_VERSION_NUMBER,
    X_REFERRAL_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PV_REFERRALS_TL T
    where T.REFERRAL_ID = X_REFERRAL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_REFERRAL_ID in NUMBER,
  X_ACTUAL_CURRENCY_CODE in VARCHAR2,
  X_BENEFIT_TYPE_CODE in VARCHAR2,
  X_CUSTOMER_CONTACT_PHONE_TYPE in VARCHAR2,
  X_CUSTOMER_CONTACT_EMAIL_ADDRE in VARCHAR2,
  X_CUSTOMER_CONTACT_PHONE_EXT in VARCHAR2,
  X_DECLINE_REASON_CODE in VARCHAR2,
  X_ENTITY_TYPE in VARCHAR2,
  X_ORDER_ID in NUMBER,
  X_CLAIM_ID in NUMBER,
  X_CLAIM_NUMBER in VARCHAR2,
  X_EST_COMPENSATION_AMT in NUMBER,
  X_CURRENCY_CODE in VARCHAR2,
  X_ACTUAL_COMPENSATION_AMT in NUMBER,
  X_STATUS_CHANGE_DATE in DATE,
  X_DUPLICATE_CUSTOMER_FLAG in VARCHAR2,
  X_PARTNER_CUST_ACCOUNT_ID in NUMBER,
  X_CUSTOMER_COUNTRY in VARCHAR2,
  X_CUSTOMER_CONTACT_TITLE in VARCHAR2,
  X_CUSTOMER_CONTACT_FIRST_NAME in VARCHAR2,
  X_CUSTOMER_CONTACT_LAST_NAME in VARCHAR2,
  X_CUSTOMER_CONTACT_CNTRY_CODE in VARCHAR2,
  X_CUSTOMER_CONTACT_AREA_CODE in VARCHAR2,
  X_CUSTOMER_CONTACT_PHONE_NO in VARCHAR2,
  X_CUSTOMER_PROVINCE in VARCHAR2,
  X_CUSTOMER_POSTAL_CODE in VARCHAR2,
  X_CUSTOMER_COUNTY in VARCHAR2,
  X_ENTITY_ID_LINKED_TO in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_BENEFIT_ID in NUMBER,
  X_REFERRAL_CODE in VARCHAR2,
  X_REFERRAL_STATUS in VARCHAR2,
  X_PARTNER_ID in NUMBER,
  X_PARTNER_CONTACT_RESOURCE_ID in NUMBER,
  X_CUSTOMER_PARTY_ID in NUMBER,
  X_CUSTOMER_ORG_CONTACT_ID in NUMBER,
  X_CUSTOMER_CONTACT_PARTY_ID in NUMBER,
  X_CUSTOMER_PARTY_SITE_ID in NUMBER,
  X_CUSTOMER_NAME in VARCHAR2,
  X_CUSTOMER_ADDRESS_TYPE in VARCHAR2,
  X_CUSTOMER_ADDRESS1 in VARCHAR2,
  X_CUSTOMER_ADDRESS2 in VARCHAR2,
  X_CUSTOMER_ADDRESS3 in VARCHAR2,
  X_CUSTOMER_ADDRESS4 in VARCHAR2,
  X_ADDRESS_LINES_PHONETIC in VARCHAR2,
  X_CUSTOMER_CITY in VARCHAR2,
  X_CUSTOMER_STATE in VARCHAR2,
  X_REFERRAL_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_CUSTOMER_NAME_PRONOUNCIATION in VARCHAR2,
  X_RETURN_REASON_CODE in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1  in VARCHAR2,
  X_ATTRIBUTE2  in VARCHAR2,
  X_ATTRIBUTE3  in VARCHAR2,
  X_ATTRIBUTE4  in VARCHAR2,
  X_ATTRIBUTE5   in VARCHAR2,
  X_ATTRIBUTE6   in VARCHAR2,
  X_ATTRIBUTE7   in VARCHAR2,
  X_ATTRIBUTE8   in VARCHAR2,
  X_ATTRIBUTE9   in VARCHAR2,
  X_ATTRIBUTE10  in VARCHAR2,
  X_ATTRIBUTE11  in VARCHAR2,
  X_ATTRIBUTE12  in VARCHAR2,
  X_ATTRIBUTE13  in VARCHAR2,
  X_ATTRIBUTE14  in VARCHAR2,
  X_ATTRIBUTE15  in VARCHAR2,
  X_ATTRIBUTE16  in VARCHAR2,
  X_ATTRIBUTE17  in VARCHAR2,
  X_ATTRIBUTE18  in VARCHAR2,
  X_ATTRIBUTE19  in VARCHAR2,
  X_ATTRIBUTE20  in VARCHAR2,
  X_ATTRIBUTE21  in VARCHAR2,
  X_ATTRIBUTE22  in VARCHAR2,
  X_ATTRIBUTE23  in VARCHAR2,
  X_ATTRIBUTE24  in VARCHAR2
) is
  cursor c is select
      ACTUAL_CURRENCY_CODE,
      BENEFIT_TYPE_CODE,
      CUSTOMER_CONTACT_PHONE_TYPE,
      CUSTOMER_CONTACT_EMAIL_ADDRESS,
      CUSTOMER_CONTACT_PHONE_EXT,
      DECLINE_REASON_CODE,
      ENTITY_TYPE,
      ORDER_ID,
      CLAIM_ID,
      CLAIM_NUMBER,
      EST_COMPENSATION_AMT,
      CURRENCY_CODE,
      ACTUAL_COMPENSATION_AMT,
      STATUS_CHANGE_DATE,
      DUPLICATE_CUSTOMER_FLAG,
      PARTNER_CUST_ACCOUNT_ID,
      CUSTOMER_COUNTRY,
      CUSTOMER_CONTACT_TITLE,
      CUSTOMER_CONTACT_FIRST_NAME,
      CUSTOMER_CONTACT_LAST_NAME,
      CUSTOMER_CONTACT_CNTRY_CODE,
      CUSTOMER_CONTACT_AREA_CODE,
      CUSTOMER_CONTACT_PHONE_NO,
      CUSTOMER_PROVINCE,
      CUSTOMER_POSTAL_CODE,
      CUSTOMER_COUNTY,
      ENTITY_ID_LINKED_TO,
      OBJECT_VERSION_NUMBER,
      BENEFIT_ID,
      REFERRAL_CODE,
      REFERRAL_STATUS,
      PARTNER_ID,
      PARTNER_CONTACT_RESOURCE_ID,
      CUSTOMER_PARTY_ID,
      CUSTOMER_ORG_CONTACT_ID,
      CUSTOMER_CONTACT_PARTY_ID,
      CUSTOMER_PARTY_SITE_ID,
      CUSTOMER_NAME,
      CUSTOMER_ADDRESS_TYPE,
      CUSTOMER_ADDRESS1,
      CUSTOMER_ADDRESS2,
      CUSTOMER_ADDRESS3,
      CUSTOMER_ADDRESS4,
      ADDRESS_LINES_PHONETIC,
      CUSTOMER_CITY,
      CUSTOMER_STATE,
      ORG_ID,
      SECURITY_GROUP_ID,
      CUSTOMER_NAME_PRONOUNCIATION,
      RETURN_REASON_CODE,
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
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
      ATTRIBUTE21,
      ATTRIBUTE22,
      ATTRIBUTE23,
      ATTRIBUTE24
    from PV_REFERRALS_B
    where REFERRAL_ID = X_REFERRAL_ID
    for update of REFERRAL_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      REFERRAL_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PV_REFERRALS_TL
    where REFERRAL_ID = X_REFERRAL_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of REFERRAL_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ACTUAL_CURRENCY_CODE = X_ACTUAL_CURRENCY_CODE)
           OR ((recinfo.ACTUAL_CURRENCY_CODE is null) AND (X_ACTUAL_CURRENCY_CODE is null)))
      AND (recinfo.BENEFIT_TYPE_CODE = X_BENEFIT_TYPE_CODE)
      AND ((recinfo.CUSTOMER_CONTACT_PHONE_TYPE = X_CUSTOMER_CONTACT_PHONE_TYPE)
           OR ((recinfo.CUSTOMER_CONTACT_PHONE_TYPE is null) AND (X_CUSTOMER_CONTACT_PHONE_TYPE is null)))
      AND ((recinfo.CUSTOMER_CONTACT_EMAIL_ADDRESS = X_CUSTOMER_CONTACT_EMAIL_ADDRE)
           OR ((recinfo.CUSTOMER_CONTACT_EMAIL_ADDRESS is null) AND (X_CUSTOMER_CONTACT_EMAIL_ADDRE is null)))
      AND ((recinfo.CUSTOMER_CONTACT_PHONE_EXT = X_CUSTOMER_CONTACT_PHONE_EXT)
           OR ((recinfo.CUSTOMER_CONTACT_PHONE_EXT is null) AND (X_CUSTOMER_CONTACT_PHONE_EXT is null)))
      AND ((recinfo.DECLINE_REASON_CODE = X_DECLINE_REASON_CODE)
           OR ((recinfo.DECLINE_REASON_CODE is null) AND (X_DECLINE_REASON_CODE is null)))
      AND ((recinfo.ENTITY_TYPE = X_ENTITY_TYPE)
           OR ((recinfo.ENTITY_TYPE is null) AND (X_ENTITY_TYPE is null)))
      AND ((recinfo.ORDER_ID = X_ORDER_ID)
           OR ((recinfo.ORDER_ID is null) AND (X_ORDER_ID is null)))
      AND ((recinfo.CLAIM_ID = X_CLAIM_ID)
           OR ((recinfo.CLAIM_ID is null) AND (X_CLAIM_ID is null)))
      AND ((recinfo.CLAIM_NUMBER = X_CLAIM_NUMBER)
           OR ((recinfo.CLAIM_NUMBER is null) AND (X_CLAIM_NUMBER is null)))
      AND ((recinfo.EST_COMPENSATION_AMT = X_EST_COMPENSATION_AMT)
           OR ((recinfo.EST_COMPENSATION_AMT is null) AND (X_EST_COMPENSATION_AMT is null)))
      AND ((recinfo.CURRENCY_CODE = X_CURRENCY_CODE)
           OR ((recinfo.CURRENCY_CODE is null) AND (X_CURRENCY_CODE is null)))
      AND ((recinfo.ACTUAL_COMPENSATION_AMT = X_ACTUAL_COMPENSATION_AMT)
           OR ((recinfo.ACTUAL_COMPENSATION_AMT is null) AND (X_ACTUAL_COMPENSATION_AMT is null)))
      AND (recinfo.STATUS_CHANGE_DATE = X_STATUS_CHANGE_DATE)
      AND ((recinfo.DUPLICATE_CUSTOMER_FLAG = X_DUPLICATE_CUSTOMER_FLAG)
           OR ((recinfo.DUPLICATE_CUSTOMER_FLAG is null) AND (X_DUPLICATE_CUSTOMER_FLAG is null)))
      AND (recinfo.PARTNER_CUST_ACCOUNT_ID = X_PARTNER_CUST_ACCOUNT_ID)
      AND (recinfo.CUSTOMER_COUNTRY = X_CUSTOMER_COUNTRY)
      AND ((recinfo.CUSTOMER_CONTACT_TITLE = X_CUSTOMER_CONTACT_TITLE)
           OR ((recinfo.CUSTOMER_CONTACT_TITLE is null) AND (X_CUSTOMER_CONTACT_TITLE is null)))
      AND ((recinfo.CUSTOMER_CONTACT_FIRST_NAME = X_CUSTOMER_CONTACT_FIRST_NAME)
           OR ((recinfo.CUSTOMER_CONTACT_FIRST_NAME is null) AND (X_CUSTOMER_CONTACT_FIRST_NAME is null)))
      AND ((recinfo.CUSTOMER_CONTACT_LAST_NAME = X_CUSTOMER_CONTACT_LAST_NAME)
           OR ((recinfo.CUSTOMER_CONTACT_LAST_NAME is null) AND (X_CUSTOMER_CONTACT_LAST_NAME is null)))
      AND ((recinfo.CUSTOMER_CONTACT_CNTRY_CODE = X_CUSTOMER_CONTACT_CNTRY_CODE)
           OR ((recinfo.CUSTOMER_CONTACT_CNTRY_CODE is null) AND (X_CUSTOMER_CONTACT_CNTRY_CODE is null)))
      AND ((recinfo.CUSTOMER_CONTACT_AREA_CODE = X_CUSTOMER_CONTACT_AREA_CODE)
           OR ((recinfo.CUSTOMER_CONTACT_AREA_CODE is null) AND (X_CUSTOMER_CONTACT_AREA_CODE is null)))
      AND ((recinfo.CUSTOMER_CONTACT_PHONE_NO = X_CUSTOMER_CONTACT_PHONE_NO)
           OR ((recinfo.CUSTOMER_CONTACT_PHONE_NO is null) AND (X_CUSTOMER_CONTACT_PHONE_NO is null)))
      AND ((recinfo.CUSTOMER_PROVINCE = X_CUSTOMER_PROVINCE)
           OR ((recinfo.CUSTOMER_PROVINCE is null) AND (X_CUSTOMER_PROVINCE is null)))
      AND ((recinfo.CUSTOMER_POSTAL_CODE = X_CUSTOMER_POSTAL_CODE)
           OR ((recinfo.CUSTOMER_POSTAL_CODE is null) AND (X_CUSTOMER_POSTAL_CODE is null)))
      AND ((recinfo.CUSTOMER_COUNTY = X_CUSTOMER_COUNTY)
           OR ((recinfo.CUSTOMER_COUNTY is null) AND (X_CUSTOMER_COUNTY is null)))
      AND ((recinfo.ENTITY_ID_LINKED_TO = X_ENTITY_ID_LINKED_TO)
           OR ((recinfo.ENTITY_ID_LINKED_TO is null) AND (X_ENTITY_ID_LINKED_TO is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.BENEFIT_ID = X_BENEFIT_ID)
      AND (recinfo.REFERRAL_CODE = X_REFERRAL_CODE)
      AND (recinfo.REFERRAL_STATUS = X_REFERRAL_STATUS)
      AND (recinfo.PARTNER_ID = X_PARTNER_ID)
      AND (recinfo.PARTNER_CONTACT_RESOURCE_ID = X_PARTNER_CONTACT_RESOURCE_ID)
      AND ((recinfo.CUSTOMER_PARTY_ID = X_CUSTOMER_PARTY_ID)
           OR ((recinfo.CUSTOMER_PARTY_ID is null) AND (X_CUSTOMER_PARTY_ID is null)))
      AND ((recinfo.CUSTOMER_ORG_CONTACT_ID = X_CUSTOMER_ORG_CONTACT_ID)
           OR ((recinfo.CUSTOMER_ORG_CONTACT_ID is null) AND (X_CUSTOMER_ORG_CONTACT_ID is null)))
      AND ((recinfo.CUSTOMER_CONTACT_PARTY_ID = X_CUSTOMER_CONTACT_PARTY_ID)
           OR ((recinfo.CUSTOMER_CONTACT_PARTY_ID is null) AND (X_CUSTOMER_CONTACT_PARTY_ID is null)))
      AND ((recinfo.CUSTOMER_PARTY_SITE_ID = X_CUSTOMER_PARTY_SITE_ID)
           OR ((recinfo.CUSTOMER_PARTY_SITE_ID is null) AND (X_CUSTOMER_PARTY_SITE_ID is null)))
      AND (recinfo.CUSTOMER_NAME = X_CUSTOMER_NAME)
      AND ((recinfo.CUSTOMER_NAME_PRONOUNCIATION = X_CUSTOMER_NAME_PRONOUNCIATION)
           OR ((recinfo.CUSTOMER_NAME_PRONOUNCIATION is null) AND (X_CUSTOMER_NAME_PRONOUNCIATION is null)))
      AND ((recinfo.RETURN_REASON_CODE = X_RETURN_REASON_CODE)
           OR ((recinfo.RETURN_REASON_CODE is null) AND (X_RETURN_REASON_CODE is null)))
      AND ((recinfo.CUSTOMER_ADDRESS_TYPE = X_CUSTOMER_ADDRESS_TYPE)
           OR ((recinfo.CUSTOMER_ADDRESS_TYPE is null) AND (X_CUSTOMER_ADDRESS_TYPE is null)))
      AND ((recinfo.CUSTOMER_ADDRESS1 = X_CUSTOMER_ADDRESS1)
           OR ((recinfo.CUSTOMER_ADDRESS1 is null) AND (X_CUSTOMER_ADDRESS1 is null)))
      AND ((recinfo.CUSTOMER_ADDRESS2 = X_CUSTOMER_ADDRESS2)
           OR ((recinfo.CUSTOMER_ADDRESS2 is null) AND (X_CUSTOMER_ADDRESS2 is null)))
      AND ((recinfo.CUSTOMER_ADDRESS3 = X_CUSTOMER_ADDRESS3)
           OR ((recinfo.CUSTOMER_ADDRESS3 is null) AND (X_CUSTOMER_ADDRESS3 is null)))
      AND ((recinfo.CUSTOMER_ADDRESS4 = X_CUSTOMER_ADDRESS4)
           OR ((recinfo.CUSTOMER_ADDRESS4 is null) AND (X_CUSTOMER_ADDRESS4 is null)))
      AND ((recinfo.ADDRESS_LINES_PHONETIC = X_ADDRESS_LINES_PHONETIC)
           OR ((recinfo.ADDRESS_LINES_PHONETIC is null) AND (X_ADDRESS_LINES_PHONETIC is null)))
      AND ((recinfo.CUSTOMER_CITY = X_CUSTOMER_CITY)
           OR ((recinfo.CUSTOMER_CITY is null) AND (X_CUSTOMER_CITY is null)))
      AND ((recinfo.CUSTOMER_STATE = X_CUSTOMER_STATE)
           OR ((recinfo.CUSTOMER_STATE is null) AND (X_CUSTOMER_STATE is null)))
      AND ((recinfo.ORG_ID = X_ORG_ID)
           OR ((recinfo.ORG_ID is null) AND (X_ORG_ID is null)))
      AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.ATTRIBUTE16 = X_ATTRIBUTE16)
           OR ((recinfo.ATTRIBUTE16 is null) AND (X_ATTRIBUTE16 is null)))
      AND ((recinfo.ATTRIBUTE17 = X_ATTRIBUTE17)
           OR ((recinfo.ATTRIBUTE17 is null) AND (X_ATTRIBUTE17 is null)))
      AND ((recinfo.ATTRIBUTE18 = X_ATTRIBUTE18)
           OR ((recinfo.ATTRIBUTE18 is null) AND (X_ATTRIBUTE18 is null)))
      AND ((recinfo.ATTRIBUTE19 = X_ATTRIBUTE19)
           OR ((recinfo.ATTRIBUTE19 is null) AND (X_ATTRIBUTE19 is null)))
      AND ((recinfo.ATTRIBUTE20 = X_ATTRIBUTE20)
           OR ((recinfo.ATTRIBUTE20 is null) AND (X_ATTRIBUTE20 is null)))
      AND ((recinfo.ATTRIBUTE21 = X_ATTRIBUTE21)
           OR ((recinfo.ATTRIBUTE21 is null) AND (X_ATTRIBUTE21 is null)))
      AND ((recinfo.ATTRIBUTE22 = X_ATTRIBUTE22)
           OR ((recinfo.ATTRIBUTE22 is null) AND (X_ATTRIBUTE22 is null)))
      AND ((recinfo.ATTRIBUTE23 = X_ATTRIBUTE23)
           OR ((recinfo.ATTRIBUTE23 is null) AND (X_ATTRIBUTE23 is null)))
      AND ((recinfo.ATTRIBUTE24 = X_ATTRIBUTE24)
           OR ((recinfo.ATTRIBUTE24 is null) AND (X_ATTRIBUTE24 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.REFERRAL_NAME = X_REFERRAL_NAME)
          AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_REFERRAL_ID in NUMBER,
  X_ACTUAL_CURRENCY_CODE in VARCHAR2,
  X_BENEFIT_TYPE_CODE in VARCHAR2,
  X_CUSTOMER_CONTACT_PHONE_TYPE in VARCHAR2,
  X_CUSTOMER_CONTACT_EMAIL_ADDRE in VARCHAR2,
  X_CUSTOMER_CONTACT_PHONE_EXT in VARCHAR2,
  X_DECLINE_REASON_CODE in VARCHAR2,
  X_ENTITY_TYPE in VARCHAR2,
  X_ORDER_ID in NUMBER,
  X_CLAIM_ID in NUMBER,
  X_CLAIM_NUMBER in VARCHAR2,
  X_EST_COMPENSATION_AMT in NUMBER,
  X_CURRENCY_CODE in VARCHAR2,
  X_ACTUAL_COMPENSATION_AMT in NUMBER,
  X_STATUS_CHANGE_DATE in DATE,
  X_DUPLICATE_CUSTOMER_FLAG in VARCHAR2,
  X_PARTNER_CUST_ACCOUNT_ID in NUMBER,
  X_CUSTOMER_COUNTRY in VARCHAR2,
  X_CUSTOMER_CONTACT_TITLE in VARCHAR2,
  X_CUSTOMER_CONTACT_FIRST_NAME in VARCHAR2,
  X_CUSTOMER_CONTACT_LAST_NAME in VARCHAR2,
  X_CUSTOMER_CONTACT_CNTRY_CODE in VARCHAR2,
  X_CUSTOMER_CONTACT_AREA_CODE in VARCHAR2,
  X_CUSTOMER_CONTACT_PHONE_NO in VARCHAR2,
  X_CUSTOMER_PROVINCE in VARCHAR2,
  X_CUSTOMER_POSTAL_CODE in VARCHAR2,
  X_CUSTOMER_COUNTY in VARCHAR2,
  X_ENTITY_ID_LINKED_TO in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_BENEFIT_ID in NUMBER,
  X_REFERRAL_CODE in VARCHAR2,
  X_REFERRAL_STATUS in VARCHAR2,
  X_PARTNER_ID in NUMBER,
  X_PARTNER_CONTACT_RESOURCE_ID in NUMBER,
  X_CUSTOMER_PARTY_ID in NUMBER,
  X_CUSTOMER_ORG_CONTACT_ID in NUMBER,
  X_CUSTOMER_CONTACT_PARTY_ID in NUMBER,
  X_CUSTOMER_PARTY_SITE_ID in NUMBER,
  X_CUSTOMER_NAME in VARCHAR2,
  X_CUSTOMER_ADDRESS_TYPE in VARCHAR2,
  X_CUSTOMER_ADDRESS1 in VARCHAR2,
  X_CUSTOMER_ADDRESS2 in VARCHAR2,
  X_CUSTOMER_ADDRESS3 in VARCHAR2,
  X_CUSTOMER_ADDRESS4 in VARCHAR2,
  X_ADDRESS_LINES_PHONETIC in VARCHAR2,
  X_CUSTOMER_CITY in VARCHAR2,
  X_CUSTOMER_STATE in VARCHAR2,
  X_REFERRAL_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORG_ID in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_CUSTOMER_NAME_PRONOUNCIATION in VARCHAR2,
  X_RETURN_REASON_CODE in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1  in VARCHAR2,
  X_ATTRIBUTE2  in VARCHAR2,
  X_ATTRIBUTE3  in VARCHAR2,
  X_ATTRIBUTE4  in VARCHAR2,
  X_ATTRIBUTE5   in VARCHAR2,
  X_ATTRIBUTE6   in VARCHAR2,
  X_ATTRIBUTE7   in VARCHAR2,
  X_ATTRIBUTE8   in VARCHAR2,
  X_ATTRIBUTE9   in VARCHAR2,
  X_ATTRIBUTE10  in VARCHAR2,
  X_ATTRIBUTE11  in VARCHAR2,
  X_ATTRIBUTE12  in VARCHAR2,
  X_ATTRIBUTE13  in VARCHAR2,
  X_ATTRIBUTE14  in VARCHAR2,
  X_ATTRIBUTE15  in VARCHAR2,
  X_ATTRIBUTE16  in VARCHAR2,
  X_ATTRIBUTE17  in VARCHAR2,
  X_ATTRIBUTE18  in VARCHAR2,
  X_ATTRIBUTE19  in VARCHAR2,
  X_ATTRIBUTE20  in VARCHAR2,
  X_ATTRIBUTE21  in VARCHAR2,
  X_ATTRIBUTE22  in VARCHAR2,
  X_ATTRIBUTE23  in VARCHAR2,
  X_ATTRIBUTE24  in VARCHAR2
) is
begin
  update PV_REFERRALS_B set
    ACTUAL_CURRENCY_CODE = X_ACTUAL_CURRENCY_CODE,
    BENEFIT_TYPE_CODE = X_BENEFIT_TYPE_CODE,
    CUSTOMER_CONTACT_PHONE_TYPE = X_CUSTOMER_CONTACT_PHONE_TYPE,
    CUSTOMER_CONTACT_EMAIL_ADDRESS = X_CUSTOMER_CONTACT_EMAIL_ADDRE,
    CUSTOMER_CONTACT_PHONE_EXT = X_CUSTOMER_CONTACT_PHONE_EXT,
    DECLINE_REASON_CODE = X_DECLINE_REASON_CODE,
    ENTITY_TYPE = X_ENTITY_TYPE,
    ORDER_ID = X_ORDER_ID,
    CLAIM_ID = X_CLAIM_ID,
    CLAIM_NUMBER = X_CLAIM_NUMBER,
    EST_COMPENSATION_AMT = X_EST_COMPENSATION_AMT,
    CURRENCY_CODE = X_CURRENCY_CODE,
    ACTUAL_COMPENSATION_AMT = X_ACTUAL_COMPENSATION_AMT,
    STATUS_CHANGE_DATE = X_STATUS_CHANGE_DATE,
    DUPLICATE_CUSTOMER_FLAG = X_DUPLICATE_CUSTOMER_FLAG,
    PARTNER_CUST_ACCOUNT_ID = X_PARTNER_CUST_ACCOUNT_ID,
    CUSTOMER_COUNTRY = X_CUSTOMER_COUNTRY,
    CUSTOMER_CONTACT_TITLE = X_CUSTOMER_CONTACT_TITLE,
    CUSTOMER_CONTACT_FIRST_NAME = X_CUSTOMER_CONTACT_FIRST_NAME,
    CUSTOMER_CONTACT_LAST_NAME = X_CUSTOMER_CONTACT_LAST_NAME,
    CUSTOMER_CONTACT_CNTRY_CODE = X_CUSTOMER_CONTACT_CNTRY_CODE,
    CUSTOMER_CONTACT_AREA_CODE = X_CUSTOMER_CONTACT_AREA_CODE,
    CUSTOMER_CONTACT_PHONE_NO = X_CUSTOMER_CONTACT_PHONE_NO,
    CUSTOMER_PROVINCE = X_CUSTOMER_PROVINCE,
    CUSTOMER_POSTAL_CODE = X_CUSTOMER_POSTAL_CODE,
    CUSTOMER_COUNTY = X_CUSTOMER_COUNTY,
    ENTITY_ID_LINKED_TO = X_ENTITY_ID_LINKED_TO,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    BENEFIT_ID = X_BENEFIT_ID,
    REFERRAL_CODE = X_REFERRAL_CODE,
    REFERRAL_STATUS = X_REFERRAL_STATUS,
    PARTNER_ID = X_PARTNER_ID,
    PARTNER_CONTACT_RESOURCE_ID = X_PARTNER_CONTACT_RESOURCE_ID,
    CUSTOMER_PARTY_ID = X_CUSTOMER_PARTY_ID,
    CUSTOMER_ORG_CONTACT_ID = X_CUSTOMER_ORG_CONTACT_ID,
    CUSTOMER_CONTACT_PARTY_ID = X_CUSTOMER_CONTACT_PARTY_ID,
    CUSTOMER_PARTY_SITE_ID = X_CUSTOMER_PARTY_SITE_ID,
    CUSTOMER_NAME = X_CUSTOMER_NAME,
    CUSTOMER_NAME_PRONOUNCIATION = X_CUSTOMER_NAME_PRONOUNCIATION,
    RETURN_REASON_CODE = X_RETURN_REASON_CODE,
    CUSTOMER_ADDRESS_TYPE = X_CUSTOMER_ADDRESS_TYPE,
    CUSTOMER_ADDRESS1 = X_CUSTOMER_ADDRESS1,
    CUSTOMER_ADDRESS2 = X_CUSTOMER_ADDRESS2,
    CUSTOMER_ADDRESS3 = X_CUSTOMER_ADDRESS3,
    CUSTOMER_ADDRESS4 = X_CUSTOMER_ADDRESS4,
    ADDRESS_LINES_PHONETIC = X_ADDRESS_LINES_PHONETIC,
    CUSTOMER_CITY = X_CUSTOMER_CITY,
    CUSTOMER_STATE = X_CUSTOMER_STATE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    ORG_ID = X_ORG_ID ,
    SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    ATTRIBUTE_CATEGORY  = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1  = X_ATTRIBUTE1,
    ATTRIBUTE2  = X_ATTRIBUTE2,
    ATTRIBUTE3  = X_ATTRIBUTE3,
    ATTRIBUTE4  = X_ATTRIBUTE4,
    ATTRIBUTE5  = X_ATTRIBUTE5,
    ATTRIBUTE6  = X_ATTRIBUTE6,
    ATTRIBUTE7  = X_ATTRIBUTE7,
    ATTRIBUTE8  = X_ATTRIBUTE8,
    ATTRIBUTE9  = X_ATTRIBUTE9,
    ATTRIBUTE10  = X_ATTRIBUTE10,
    ATTRIBUTE11  = X_ATTRIBUTE11,
    ATTRIBUTE12  = X_ATTRIBUTE12,
    ATTRIBUTE13  = X_ATTRIBUTE13,
    ATTRIBUTE14  = X_ATTRIBUTE14,
    ATTRIBUTE15  = X_ATTRIBUTE15,
    ATTRIBUTE16  = X_ATTRIBUTE16,
    ATTRIBUTE17  = X_ATTRIBUTE17,
    ATTRIBUTE18  = X_ATTRIBUTE18,
    ATTRIBUTE19  = X_ATTRIBUTE19,
    ATTRIBUTE20  = X_ATTRIBUTE20,
    ATTRIBUTE21  = X_ATTRIBUTE21,
    ATTRIBUTE22  = X_ATTRIBUTE22,
    ATTRIBUTE23  = X_ATTRIBUTE23,
    ATTRIBUTE24  = X_ATTRIBUTE24
  where REFERRAL_ID = X_REFERRAL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update PV_REFERRALS_TL set
    REFERRAL_NAME = X_REFERRAL_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where REFERRAL_ID = X_REFERRAL_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_REFERRAL_ID in NUMBER
) is
begin
  delete from PV_REFERRALS_TL
  where REFERRAL_ID = X_REFERRAL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PV_REFERRALS_B
  where REFERRAL_ID = X_REFERRAL_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from PV_REFERRALS_TL T
  where not exists
    (select NULL
    from PV_REFERRALS_B B
    where B.REFERRAL_ID = T.REFERRAL_ID
    );

  update PV_REFERRALS_TL T set (
      REFERRAL_NAME,
      DESCRIPTION
    ) = (select
      B.REFERRAL_NAME,
      B.DESCRIPTION
    from PV_REFERRALS_TL B
    where B.REFERRAL_ID = T.REFERRAL_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.REFERRAL_ID,
      T.LANGUAGE
  ) in (select
      SUBT.REFERRAL_ID,
      SUBT.LANGUAGE
    from PV_REFERRALS_TL SUBB, PV_REFERRALS_TL SUBT
    where SUBB.REFERRAL_ID = SUBT.REFERRAL_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.REFERRAL_NAME <> SUBT.REFERRAL_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into PV_REFERRALS_TL (
    CREATION_DATE,
    CREATED_BY,
    REFERRAL_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    REFERRAL_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CREATION_DATE,
    B.CREATED_BY,
    B.REFERRAL_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.OBJECT_VERSION_NUMBER,
    B.REFERRAL_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PV_REFERRALS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PV_REFERRALS_TL T
    where T.REFERRAL_ID = B.REFERRAL_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end PV_REFERRALS_PKG;

/
