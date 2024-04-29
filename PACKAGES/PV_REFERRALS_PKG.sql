--------------------------------------------------------
--  DDL for Package PV_REFERRALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_REFERRALS_PKG" AUTHID CURRENT_USER as
/* $Header: pvreferrals.pls 120.3 2006/04/18 15:39:27 saarumug ship $ */
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
  );
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
);
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
);
procedure DELETE_ROW (
  X_REFERRAL_ID in NUMBER
);
procedure ADD_LANGUAGE;
end PV_REFERRALS_PKG;

 

/