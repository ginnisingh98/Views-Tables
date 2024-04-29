--------------------------------------------------------
--  DDL for Package Body OZF_SD_REQUEST_HEADERS_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_SD_REQUEST_HEADERS_ALL_PKG" as
/* $Header: ozftsdrb.pls 120.0 2008/02/28 01:24:30 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_REQUEST_HEADER_ID in NUMBER,
  X_USER_STATUS_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_CREATED_FROM in VARCHAR2,
  X_REQUEST_NUMBER in VARCHAR2,
  X_REQUEST_CLASS in VARCHAR2,
  X_OFFER_TYPE in VARCHAR2,
  X_OFFER_ID in NUMBER,
  X_ROOT_REQUEST_HEADER_ID in NUMBER,
  X_LINKED_REQUEST_HEADER_ID in NUMBER,
  X_REQUEST_START_DATE in DATE,
  X_REQUEST_END_DATE in DATE,
  X_REQUEST_OUTCOME in VARCHAR2,
  X_DECLINE_REASON_CODE in VARCHAR2,
  X_RETURN_REASON_CODE in VARCHAR2,
  X_REQUEST_CURRENCY_CODE in VARCHAR2,
  X_AUTHORIZATION_NUMBER in VARCHAR2,
  X_REQUESTED_BUDGET_AMOUNT in NUMBER,
  X_APPROVED_BUDGET_AMOUNT in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_SUPPLIER_ID in NUMBER,
  X_SUPPLIER_SITE_ID in NUMBER,
  X_SUPPLIER_CONTACT_ID in NUMBER,
  X_REQUEST_BASIS in VARCHAR2,
  X_SUPPLIER_RESPONSE_DATE in DATE,
  X_SUPPLIER_SUBMISSION_DATE in DATE,
  X_REQUESTOR_ID in NUMBER,
  X_SUPPLIER_QUOTE_NUMBER in VARCHAR2,
  X_INTERNAL_ORDER_NUMBER in NUMBER,
  X_SALES_ORDER_CURRENCY in VARCHAR2,
  X_REQUEST_SOURCE in VARCHAR2,
  X_ASIGNEE_RESOURCE_ID in NUMBER,
  X_ACCRUAL_TYPE in VARCHAR2,
  X_CUST_ACCOUNT_ID in NUMBER,
  X_SUPPLIER_CONTACT_EMAIL_ADDRE in VARCHAR2,
  X_SUPPLIER_CONTACT_PHONE_NUMBE in VARCHAR2,
  X_REQUEST_TYPE_SETUP_ID in NUMBER,
  X_SUPPLIER_RESPONSE_BY_DATE in DATE,
  X_INTERNAL_SUBMISSION_DATE in DATE,
  X_ASIGNEE_RESPONSE_BY_DATE in DATE,
  X_ASIGNEE_RESPONSE_DATE in DATE,
  X_SUBMTD_BY_FOR_SUPP_APPROVAL in NUMBER,
  X_REQUEST_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from OZF_SD_REQUEST_HEADERS_ALL_B
    where REQUEST_HEADER_ID = X_REQUEST_HEADER_ID
    ;
begin
  insert into OZF_SD_REQUEST_HEADERS_ALL_B (
    USER_STATUS_ID,
    REQUEST_HEADER_ID,
    OBJECT_VERSION_NUMBER,
    REQUEST_ID,
    CREATED_FROM,
    REQUEST_NUMBER,
    REQUEST_CLASS,
    OFFER_TYPE,
    OFFER_ID,
    ROOT_REQUEST_HEADER_ID,
    LINKED_REQUEST_HEADER_ID,
    REQUEST_START_DATE,
    REQUEST_END_DATE,
    REQUEST_OUTCOME,
    DECLINE_REASON_CODE,
    RETURN_REASON_CODE,
    REQUEST_CURRENCY_CODE,
    AUTHORIZATION_NUMBER,
    REQUESTED_BUDGET_AMOUNT,
    APPROVED_BUDGET_AMOUNT,
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
    SUPPLIER_ID,
    SUPPLIER_SITE_ID,
    SUPPLIER_CONTACT_ID,
    REQUEST_BASIS,
    SUPPLIER_RESPONSE_DATE,
    SUPPLIER_SUBMISSION_DATE,
    REQUESTOR_ID,
    SUPPLIER_QUOTE_NUMBER,
    INTERNAL_ORDER_NUMBER,
    SALES_ORDER_CURRENCY,
    REQUEST_SOURCE,
    ASIGNEE_RESOURCE_ID,
    ACCRUAL_TYPE,
    CUST_ACCOUNT_ID,
    SUPPLIER_CONTACT_EMAIL_ADDRESS,
    SUPPLIER_CONTACT_PHONE_NUMBER,
    REQUEST_TYPE_SETUP_ID,
    SUPPLIER_RESPONSE_BY_DATE,
    INTERNAL_SUBMISSION_DATE,
    ASIGNEE_RESPONSE_BY_DATE,
    ASIGNEE_RESPONSE_DATE,
    SUBMTD_BY_FOR_SUPP_APPROVAL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_USER_STATUS_ID,
    X_REQUEST_HEADER_ID,
    X_OBJECT_VERSION_NUMBER,
    X_REQUEST_ID,
    X_CREATED_FROM,
    X_REQUEST_NUMBER,
    X_REQUEST_CLASS,
    X_OFFER_TYPE,
    X_OFFER_ID,
    X_ROOT_REQUEST_HEADER_ID,
    X_LINKED_REQUEST_HEADER_ID,
    X_REQUEST_START_DATE,
    X_REQUEST_END_DATE,
    X_REQUEST_OUTCOME,
    X_DECLINE_REASON_CODE,
    X_RETURN_REASON_CODE,
    X_REQUEST_CURRENCY_CODE,
    X_AUTHORIZATION_NUMBER,
    X_REQUESTED_BUDGET_AMOUNT,
    X_APPROVED_BUDGET_AMOUNT,
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
    X_SUPPLIER_ID,
    X_SUPPLIER_SITE_ID,
    X_SUPPLIER_CONTACT_ID,
    X_REQUEST_BASIS,
    X_SUPPLIER_RESPONSE_DATE,
    X_SUPPLIER_SUBMISSION_DATE,
    X_REQUESTOR_ID,
    X_SUPPLIER_QUOTE_NUMBER,
    X_INTERNAL_ORDER_NUMBER,
    X_SALES_ORDER_CURRENCY,
    X_REQUEST_SOURCE,
    X_ASIGNEE_RESOURCE_ID,
    X_ACCRUAL_TYPE,
    X_CUST_ACCOUNT_ID,
    X_SUPPLIER_CONTACT_EMAIL_ADDRE,
    X_SUPPLIER_CONTACT_PHONE_NUMBE,
    X_REQUEST_TYPE_SETUP_ID,
    X_SUPPLIER_RESPONSE_BY_DATE,
    X_INTERNAL_SUBMISSION_DATE,
    X_ASIGNEE_RESPONSE_BY_DATE,
    X_ASIGNEE_RESPONSE_DATE,
    X_SUBMTD_BY_FOR_SUPP_APPROVAL,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into OZF_SD_REQUEST_HEADERS_ALL_TL (
    REQUEST_HEADER_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_DESCRIPTION,
    REQUEST_ID,
    CREATED_FROM,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_REQUEST_HEADER_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_DESCRIPTION,
    X_REQUEST_ID,
    X_CREATED_FROM,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from OZF_SD_REQUEST_HEADERS_ALL_TL T
    where T.REQUEST_HEADER_ID = X_REQUEST_HEADER_ID
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
  X_REQUEST_HEADER_ID in NUMBER,
  X_USER_STATUS_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_CREATED_FROM in VARCHAR2,
  X_REQUEST_NUMBER in VARCHAR2,
  X_REQUEST_CLASS in VARCHAR2,
  X_OFFER_TYPE in VARCHAR2,
  X_OFFER_ID in NUMBER,
  X_ROOT_REQUEST_HEADER_ID in NUMBER,
  X_LINKED_REQUEST_HEADER_ID in NUMBER,
  X_REQUEST_START_DATE in DATE,
  X_REQUEST_END_DATE in DATE,
  X_REQUEST_OUTCOME in VARCHAR2,
  X_DECLINE_REASON_CODE in VARCHAR2,
  X_RETURN_REASON_CODE in VARCHAR2,
  X_REQUEST_CURRENCY_CODE in VARCHAR2,
  X_AUTHORIZATION_NUMBER in VARCHAR2,
  X_REQUESTED_BUDGET_AMOUNT in NUMBER,
  X_APPROVED_BUDGET_AMOUNT in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_SUPPLIER_ID in NUMBER,
  X_SUPPLIER_SITE_ID in NUMBER,
  X_SUPPLIER_CONTACT_ID in NUMBER,
  X_REQUEST_BASIS in VARCHAR2,
  X_SUPPLIER_RESPONSE_DATE in DATE,
  X_SUPPLIER_SUBMISSION_DATE in DATE,
  X_REQUESTOR_ID in NUMBER,
  X_SUPPLIER_QUOTE_NUMBER in VARCHAR2,
  X_INTERNAL_ORDER_NUMBER in NUMBER,
  X_SALES_ORDER_CURRENCY in VARCHAR2,
  X_REQUEST_SOURCE in VARCHAR2,
  X_ASIGNEE_RESOURCE_ID in NUMBER,
  X_ACCRUAL_TYPE in VARCHAR2,
  X_CUST_ACCOUNT_ID in NUMBER,
  X_SUPPLIER_CONTACT_EMAIL_ADDRE in VARCHAR2,
  X_SUPPLIER_CONTACT_PHONE_NUMBE in VARCHAR2,
  X_REQUEST_TYPE_SETUP_ID in NUMBER,
  X_SUPPLIER_RESPONSE_BY_DATE in DATE,
  X_INTERNAL_SUBMISSION_DATE in DATE,
  X_ASIGNEE_RESPONSE_BY_DATE in DATE,
  X_ASIGNEE_RESPONSE_DATE in DATE,
  X_SUBMTD_BY_FOR_SUPP_APPROVAL in NUMBER,
  X_REQUEST_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      USER_STATUS_ID,
      OBJECT_VERSION_NUMBER,
      REQUEST_ID,
      CREATED_FROM,
      REQUEST_NUMBER,
      REQUEST_CLASS,
      OFFER_TYPE,
      OFFER_ID,
      ROOT_REQUEST_HEADER_ID,
      LINKED_REQUEST_HEADER_ID,
      REQUEST_START_DATE,
      REQUEST_END_DATE,
      REQUEST_OUTCOME,
      DECLINE_REASON_CODE,
      RETURN_REASON_CODE,
      REQUEST_CURRENCY_CODE,
      AUTHORIZATION_NUMBER,
      REQUESTED_BUDGET_AMOUNT,
      APPROVED_BUDGET_AMOUNT,
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
      SUPPLIER_ID,
      SUPPLIER_SITE_ID,
      SUPPLIER_CONTACT_ID,
      REQUEST_BASIS,
      SUPPLIER_RESPONSE_DATE,
      SUPPLIER_SUBMISSION_DATE,
      REQUESTOR_ID,
      SUPPLIER_QUOTE_NUMBER,
      INTERNAL_ORDER_NUMBER,
      SALES_ORDER_CURRENCY,
      REQUEST_SOURCE,
      ASIGNEE_RESOURCE_ID,
      ACCRUAL_TYPE,
      CUST_ACCOUNT_ID,
      SUPPLIER_CONTACT_EMAIL_ADDRESS,
      SUPPLIER_CONTACT_PHONE_NUMBER,
      REQUEST_TYPE_SETUP_ID,
      SUPPLIER_RESPONSE_BY_DATE,
      INTERNAL_SUBMISSION_DATE,
      ASIGNEE_RESPONSE_BY_DATE,
      ASIGNEE_RESPONSE_DATE,
      SUBMTD_BY_FOR_SUPP_APPROVAL
    from OZF_SD_REQUEST_HEADERS_ALL_B
    where REQUEST_HEADER_ID = X_REQUEST_HEADER_ID
    for update of REQUEST_HEADER_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      REQUEST_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from OZF_SD_REQUEST_HEADERS_ALL_TL
    where REQUEST_HEADER_ID = X_REQUEST_HEADER_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of REQUEST_HEADER_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.USER_STATUS_ID = X_USER_STATUS_ID)
           OR ((recinfo.USER_STATUS_ID is null) AND (X_USER_STATUS_ID is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
      AND ((recinfo.CREATED_FROM = X_CREATED_FROM)
           OR ((recinfo.CREATED_FROM is null) AND (X_CREATED_FROM is null)))
      AND (recinfo.REQUEST_NUMBER = X_REQUEST_NUMBER)
      AND ((recinfo.REQUEST_CLASS = X_REQUEST_CLASS)
           OR ((recinfo.REQUEST_CLASS is null) AND (X_REQUEST_CLASS is null)))
      AND ((recinfo.OFFER_TYPE = X_OFFER_TYPE)
           OR ((recinfo.OFFER_TYPE is null) AND (X_OFFER_TYPE is null)))
      AND ((recinfo.OFFER_ID = X_OFFER_ID)
           OR ((recinfo.OFFER_ID is null) AND (X_OFFER_ID is null)))
      AND ((recinfo.ROOT_REQUEST_HEADER_ID = X_ROOT_REQUEST_HEADER_ID)
           OR ((recinfo.ROOT_REQUEST_HEADER_ID is null) AND (X_ROOT_REQUEST_HEADER_ID is null)))
      AND ((recinfo.LINKED_REQUEST_HEADER_ID = X_LINKED_REQUEST_HEADER_ID)
           OR ((recinfo.LINKED_REQUEST_HEADER_ID is null) AND (X_LINKED_REQUEST_HEADER_ID is null)))
      AND ((recinfo.REQUEST_START_DATE = X_REQUEST_START_DATE)
           OR ((recinfo.REQUEST_START_DATE is null) AND (X_REQUEST_START_DATE is null)))
      AND ((recinfo.REQUEST_END_DATE = X_REQUEST_END_DATE)
           OR ((recinfo.REQUEST_END_DATE is null) AND (X_REQUEST_END_DATE is null)))
      AND ((recinfo.REQUEST_OUTCOME = X_REQUEST_OUTCOME)
           OR ((recinfo.REQUEST_OUTCOME is null) AND (X_REQUEST_OUTCOME is null)))
      AND ((recinfo.DECLINE_REASON_CODE = X_DECLINE_REASON_CODE)
           OR ((recinfo.DECLINE_REASON_CODE is null) AND (X_DECLINE_REASON_CODE is null)))
      AND ((recinfo.RETURN_REASON_CODE = X_RETURN_REASON_CODE)
           OR ((recinfo.RETURN_REASON_CODE is null) AND (X_RETURN_REASON_CODE is null)))
      AND ((recinfo.REQUEST_CURRENCY_CODE = X_REQUEST_CURRENCY_CODE)
           OR ((recinfo.REQUEST_CURRENCY_CODE is null) AND (X_REQUEST_CURRENCY_CODE is null)))
      AND ((recinfo.AUTHORIZATION_NUMBER = X_AUTHORIZATION_NUMBER)
           OR ((recinfo.AUTHORIZATION_NUMBER is null) AND (X_AUTHORIZATION_NUMBER is null)))
      AND ((recinfo.REQUESTED_BUDGET_AMOUNT = X_REQUESTED_BUDGET_AMOUNT)
           OR ((recinfo.REQUESTED_BUDGET_AMOUNT is null) AND (X_REQUESTED_BUDGET_AMOUNT is null)))
      AND ((recinfo.APPROVED_BUDGET_AMOUNT = X_APPROVED_BUDGET_AMOUNT)
           OR ((recinfo.APPROVED_BUDGET_AMOUNT is null) AND (X_APPROVED_BUDGET_AMOUNT is null)))
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
      AND ((recinfo.SUPPLIER_ID = X_SUPPLIER_ID)
           OR ((recinfo.SUPPLIER_ID is null) AND (X_SUPPLIER_ID is null)))
      AND ((recinfo.SUPPLIER_SITE_ID = X_SUPPLIER_SITE_ID)
           OR ((recinfo.SUPPLIER_SITE_ID is null) AND (X_SUPPLIER_SITE_ID is null)))
      AND ((recinfo.SUPPLIER_CONTACT_ID = X_SUPPLIER_CONTACT_ID)
           OR ((recinfo.SUPPLIER_CONTACT_ID is null) AND (X_SUPPLIER_CONTACT_ID is null)))
      AND ((recinfo.REQUEST_BASIS = X_REQUEST_BASIS)
           OR ((recinfo.REQUEST_BASIS is null) AND (X_REQUEST_BASIS is null)))
      AND ((recinfo.SUPPLIER_RESPONSE_DATE = X_SUPPLIER_RESPONSE_DATE)
           OR ((recinfo.SUPPLIER_RESPONSE_DATE is null) AND (X_SUPPLIER_RESPONSE_DATE is null)))
      AND ((recinfo.SUPPLIER_SUBMISSION_DATE = X_SUPPLIER_SUBMISSION_DATE)
           OR ((recinfo.SUPPLIER_SUBMISSION_DATE is null) AND (X_SUPPLIER_SUBMISSION_DATE is null)))
      AND (recinfo.REQUESTOR_ID = X_REQUESTOR_ID)
      AND ((recinfo.SUPPLIER_QUOTE_NUMBER = X_SUPPLIER_QUOTE_NUMBER)
           OR ((recinfo.SUPPLIER_QUOTE_NUMBER is null) AND (X_SUPPLIER_QUOTE_NUMBER is null)))
      AND ((recinfo.INTERNAL_ORDER_NUMBER = X_INTERNAL_ORDER_NUMBER)
           OR ((recinfo.INTERNAL_ORDER_NUMBER is null) AND (X_INTERNAL_ORDER_NUMBER is null)))
      AND ((recinfo.SALES_ORDER_CURRENCY = X_SALES_ORDER_CURRENCY)
           OR ((recinfo.SALES_ORDER_CURRENCY is null) AND (X_SALES_ORDER_CURRENCY is null)))
      AND ((recinfo.REQUEST_SOURCE = X_REQUEST_SOURCE)
           OR ((recinfo.REQUEST_SOURCE is null) AND (X_REQUEST_SOURCE is null)))
      AND ((recinfo.ASIGNEE_RESOURCE_ID = X_ASIGNEE_RESOURCE_ID)
           OR ((recinfo.ASIGNEE_RESOURCE_ID is null) AND (X_ASIGNEE_RESOURCE_ID is null)))
      AND (recinfo.ACCRUAL_TYPE = X_ACCRUAL_TYPE)
      AND ((recinfo.CUST_ACCOUNT_ID = X_CUST_ACCOUNT_ID)
           OR ((recinfo.CUST_ACCOUNT_ID is null) AND (X_CUST_ACCOUNT_ID is null)))
      AND ((recinfo.SUPPLIER_CONTACT_EMAIL_ADDRESS = X_SUPPLIER_CONTACT_EMAIL_ADDRE)
           OR ((recinfo.SUPPLIER_CONTACT_EMAIL_ADDRESS is null) AND (X_SUPPLIER_CONTACT_EMAIL_ADDRE is null)))
      AND ((recinfo.SUPPLIER_CONTACT_PHONE_NUMBER = X_SUPPLIER_CONTACT_PHONE_NUMBE)
           OR ((recinfo.SUPPLIER_CONTACT_PHONE_NUMBER is null) AND (X_SUPPLIER_CONTACT_PHONE_NUMBE is null)))
      AND ((recinfo.REQUEST_TYPE_SETUP_ID = X_REQUEST_TYPE_SETUP_ID)
           OR ((recinfo.REQUEST_TYPE_SETUP_ID is null) AND (X_REQUEST_TYPE_SETUP_ID is null)))
      AND ((recinfo.SUPPLIER_RESPONSE_BY_DATE = X_SUPPLIER_RESPONSE_BY_DATE)
           OR ((recinfo.SUPPLIER_RESPONSE_BY_DATE is null) AND (X_SUPPLIER_RESPONSE_BY_DATE is null)))
      AND ((recinfo.INTERNAL_SUBMISSION_DATE = X_INTERNAL_SUBMISSION_DATE)
           OR ((recinfo.INTERNAL_SUBMISSION_DATE is null) AND (X_INTERNAL_SUBMISSION_DATE is null)))
      AND ((recinfo.ASIGNEE_RESPONSE_BY_DATE = X_ASIGNEE_RESPONSE_BY_DATE)
           OR ((recinfo.ASIGNEE_RESPONSE_BY_DATE is null) AND (X_ASIGNEE_RESPONSE_BY_DATE is null)))
      AND ((recinfo.ASIGNEE_RESPONSE_DATE = X_ASIGNEE_RESPONSE_DATE)
           OR ((recinfo.ASIGNEE_RESPONSE_DATE is null) AND (X_ASIGNEE_RESPONSE_DATE is null)))
      AND ((recinfo.SUBMTD_BY_FOR_SUPP_APPROVAL = X_SUBMTD_BY_FOR_SUPP_APPROVAL)
           OR ((recinfo.SUBMTD_BY_FOR_SUPP_APPROVAL is null) AND (X_SUBMTD_BY_FOR_SUPP_APPROVAL is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.REQUEST_DESCRIPTION = X_REQUEST_DESCRIPTION)
               OR ((tlinfo.REQUEST_DESCRIPTION is null) AND (X_REQUEST_DESCRIPTION is null)))
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
  X_REQUEST_HEADER_ID in NUMBER,
  X_USER_STATUS_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_CREATED_FROM in VARCHAR2,
  X_REQUEST_NUMBER in VARCHAR2,
  X_REQUEST_CLASS in VARCHAR2,
  X_OFFER_TYPE in VARCHAR2,
  X_OFFER_ID in NUMBER,
  X_ROOT_REQUEST_HEADER_ID in NUMBER,
  X_LINKED_REQUEST_HEADER_ID in NUMBER,
  X_REQUEST_START_DATE in DATE,
  X_REQUEST_END_DATE in DATE,
  X_REQUEST_OUTCOME in VARCHAR2,
  X_DECLINE_REASON_CODE in VARCHAR2,
  X_RETURN_REASON_CODE in VARCHAR2,
  X_REQUEST_CURRENCY_CODE in VARCHAR2,
  X_AUTHORIZATION_NUMBER in VARCHAR2,
  X_REQUESTED_BUDGET_AMOUNT in NUMBER,
  X_APPROVED_BUDGET_AMOUNT in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_SUPPLIER_ID in NUMBER,
  X_SUPPLIER_SITE_ID in NUMBER,
  X_SUPPLIER_CONTACT_ID in NUMBER,
  X_REQUEST_BASIS in VARCHAR2,
  X_SUPPLIER_RESPONSE_DATE in DATE,
  X_SUPPLIER_SUBMISSION_DATE in DATE,
  X_REQUESTOR_ID in NUMBER,
  X_SUPPLIER_QUOTE_NUMBER in VARCHAR2,
  X_INTERNAL_ORDER_NUMBER in NUMBER,
  X_SALES_ORDER_CURRENCY in VARCHAR2,
  X_REQUEST_SOURCE in VARCHAR2,
  X_ASIGNEE_RESOURCE_ID in NUMBER,
  X_ACCRUAL_TYPE in VARCHAR2,
  X_CUST_ACCOUNT_ID in NUMBER,
  X_SUPPLIER_CONTACT_EMAIL_ADDRE in VARCHAR2,
  X_SUPPLIER_CONTACT_PHONE_NUMBE in VARCHAR2,
  X_REQUEST_TYPE_SETUP_ID in NUMBER,
  X_SUPPLIER_RESPONSE_BY_DATE in DATE,
  X_INTERNAL_SUBMISSION_DATE in DATE,
  X_ASIGNEE_RESPONSE_BY_DATE in DATE,
  X_ASIGNEE_RESPONSE_DATE in DATE,
  X_SUBMTD_BY_FOR_SUPP_APPROVAL in NUMBER,
  X_REQUEST_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update OZF_SD_REQUEST_HEADERS_ALL_B set
    USER_STATUS_ID = X_USER_STATUS_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    REQUEST_ID = X_REQUEST_ID,
    CREATED_FROM = X_CREATED_FROM,
    REQUEST_NUMBER = X_REQUEST_NUMBER,
    REQUEST_CLASS = X_REQUEST_CLASS,
    OFFER_TYPE = X_OFFER_TYPE,
    OFFER_ID = X_OFFER_ID,
    ROOT_REQUEST_HEADER_ID = X_ROOT_REQUEST_HEADER_ID,
    LINKED_REQUEST_HEADER_ID = X_LINKED_REQUEST_HEADER_ID,
    REQUEST_START_DATE = X_REQUEST_START_DATE,
    REQUEST_END_DATE = X_REQUEST_END_DATE,
    REQUEST_OUTCOME = X_REQUEST_OUTCOME,
    DECLINE_REASON_CODE = X_DECLINE_REASON_CODE,
    RETURN_REASON_CODE = X_RETURN_REASON_CODE,
    REQUEST_CURRENCY_CODE = X_REQUEST_CURRENCY_CODE,
    AUTHORIZATION_NUMBER = X_AUTHORIZATION_NUMBER,
    REQUESTED_BUDGET_AMOUNT = X_REQUESTED_BUDGET_AMOUNT,
    APPROVED_BUDGET_AMOUNT = X_APPROVED_BUDGET_AMOUNT,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    SUPPLIER_ID = X_SUPPLIER_ID,
    SUPPLIER_SITE_ID = X_SUPPLIER_SITE_ID,
    SUPPLIER_CONTACT_ID = X_SUPPLIER_CONTACT_ID,
    REQUEST_BASIS = X_REQUEST_BASIS,
    SUPPLIER_RESPONSE_DATE = X_SUPPLIER_RESPONSE_DATE,
    SUPPLIER_SUBMISSION_DATE = X_SUPPLIER_SUBMISSION_DATE,
    REQUESTOR_ID = X_REQUESTOR_ID,
    SUPPLIER_QUOTE_NUMBER = X_SUPPLIER_QUOTE_NUMBER,
    INTERNAL_ORDER_NUMBER = X_INTERNAL_ORDER_NUMBER,
    SALES_ORDER_CURRENCY = X_SALES_ORDER_CURRENCY,
    REQUEST_SOURCE = X_REQUEST_SOURCE,
    ASIGNEE_RESOURCE_ID = X_ASIGNEE_RESOURCE_ID,
    ACCRUAL_TYPE = X_ACCRUAL_TYPE,
    CUST_ACCOUNT_ID = X_CUST_ACCOUNT_ID,
    SUPPLIER_CONTACT_EMAIL_ADDRESS = X_SUPPLIER_CONTACT_EMAIL_ADDRE,
    SUPPLIER_CONTACT_PHONE_NUMBER = X_SUPPLIER_CONTACT_PHONE_NUMBE,
    REQUEST_TYPE_SETUP_ID = X_REQUEST_TYPE_SETUP_ID,
    SUPPLIER_RESPONSE_BY_DATE = X_SUPPLIER_RESPONSE_BY_DATE,
    INTERNAL_SUBMISSION_DATE = X_INTERNAL_SUBMISSION_DATE,
    ASIGNEE_RESPONSE_BY_DATE = X_ASIGNEE_RESPONSE_BY_DATE,
    ASIGNEE_RESPONSE_DATE = X_ASIGNEE_RESPONSE_DATE,
    SUBMTD_BY_FOR_SUPP_APPROVAL = X_SUBMTD_BY_FOR_SUPP_APPROVAL,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where REQUEST_HEADER_ID = X_REQUEST_HEADER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update OZF_SD_REQUEST_HEADERS_ALL_TL set
    REQUEST_DESCRIPTION = X_REQUEST_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where REQUEST_HEADER_ID = X_REQUEST_HEADER_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_REQUEST_HEADER_ID in NUMBER
) is
begin
  delete from OZF_SD_REQUEST_HEADERS_ALL_TL
  where REQUEST_HEADER_ID = X_REQUEST_HEADER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from OZF_SD_REQUEST_HEADERS_ALL_B
  where REQUEST_HEADER_ID = X_REQUEST_HEADER_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from OZF_SD_REQUEST_HEADERS_ALL_TL T
  where not exists
    (select NULL
    from OZF_SD_REQUEST_HEADERS_ALL_B B
    where B.REQUEST_HEADER_ID = T.REQUEST_HEADER_ID
    );

  update OZF_SD_REQUEST_HEADERS_ALL_TL T set (
      REQUEST_DESCRIPTION
    ) = (select
      B.REQUEST_DESCRIPTION
    from OZF_SD_REQUEST_HEADERS_ALL_TL B
    where B.REQUEST_HEADER_ID = T.REQUEST_HEADER_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.REQUEST_HEADER_ID,
      T.LANGUAGE
  ) in (select
      SUBT.REQUEST_HEADER_ID,
      SUBT.LANGUAGE
    from OZF_SD_REQUEST_HEADERS_ALL_TL SUBB, OZF_SD_REQUEST_HEADERS_ALL_TL SUBT
    where SUBB.REQUEST_HEADER_ID = SUBT.REQUEST_HEADER_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.REQUEST_DESCRIPTION <> SUBT.REQUEST_DESCRIPTION
      or (SUBB.REQUEST_DESCRIPTION is null and SUBT.REQUEST_DESCRIPTION is not null)
      or (SUBB.REQUEST_DESCRIPTION is not null and SUBT.REQUEST_DESCRIPTION is null)
  ));

  insert into OZF_SD_REQUEST_HEADERS_ALL_TL (
    REQUEST_HEADER_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_DESCRIPTION,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE,
    PROGRAM_ID,
    CREATED_FROM,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.REQUEST_HEADER_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.REQUEST_DESCRIPTION,
    B.REQUEST_ID,
    B.PROGRAM_APPLICATION_ID,
    B.PROGRAM_UPDATE_DATE,
    B.PROGRAM_ID,
    B.CREATED_FROM,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from OZF_SD_REQUEST_HEADERS_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from OZF_SD_REQUEST_HEADERS_ALL_TL T
    where T.REQUEST_HEADER_ID = B.REQUEST_HEADER_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end OZF_SD_REQUEST_HEADERS_ALL_PKG;

/