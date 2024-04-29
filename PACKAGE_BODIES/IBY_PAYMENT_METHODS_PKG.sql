--------------------------------------------------------
--  DDL for Package Body IBY_PAYMENT_METHODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_PAYMENT_METHODS_PKG" as
/* $Header: ibypmtdb.pls 120.5 2006/06/26 21:29:09 syidner noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PAYMENT_METHOD_CODE in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_REMITTANCE_MESSAGE1_APL_FLAG in VARCHAR2,
  X_REMITTANCE_MESSAGE2_APL_FLAG in VARCHAR2,
  X_REMITTANCE_MESSAGE3_APL_FLAG in VARCHAR2,
  X_UNIQUE_REMIT_ID_APL_FLAG in VARCHAR2,
  X_URI_CHECK_DIGIT_APL_FLAG in VARCHAR2,
  X_DELIVERY_CHANNEL_APL_FLAG in VARCHAR2,
  X_PAYMENT_FORMAT_APL_FLAG in VARCHAR2,
  X_SETTLEMENT_PRIORITY_APL_FLAG in VARCHAR2,
  X_EXCLUSIVE_PMT_APL_FLAG in VARCHAR2,
  X_REASON_APL_FLAG in VARCHAR2,
  X_REASON_COMNT_APL_FLAG in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_BANK_CHARGE_BEARER_APL_FLAG in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_EXTERNAL_BANK_ACCT_APL_FLAG in VARCHAR2,
  X_SUPPORT_BILLS_PAYABLE_FLAG in VARCHAR2,
  X_DOCUMENT_CATEGORY_CODE in VARCHAR2,
  X_MATURITY_DATE_OFFSET_DAYS in NUMBER,
  X_INACTIVE_DATE in DATE,
  X_ANTICIPATED_FLOAT in NUMBER,
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
  X_ATTRIBUTE11 in VARCHAR2,
  X_PAYMENT_METHOD_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_SEEDED_FLAG in VARCHAR2
) is
  cursor C is select ROWID from IBY_PAYMENT_METHODS_B
    where PAYMENT_METHOD_CODE = X_PAYMENT_METHOD_CODE
    ;
begin
  insert into IBY_PAYMENT_METHODS_B (
    ATTRIBUTE14,
    ATTRIBUTE15,
    REMITTANCE_MESSAGE1_APL_FLAG,
    REMITTANCE_MESSAGE2_APL_FLAG,
    REMITTANCE_MESSAGE3_APL_FLAG,
    UNIQUE_REMITTANCE_ID_APL_FLAG,
    URI_CHECK_DIGIT_APL_FLAG,
    DELIVERY_CHANNEL_APL_FLAG,
    PAYMENT_FORMAT_APL_FLAG,
    SETTLEMENT_PRIORITY_APL_FLAG,
    EXCLUSIVE_PMT_APL_FLAG,
    PAYMENT_REASON_APL_FLAG,
    PAYMENT_REASON_COMNT_APL_FLAG,
    ATTRIBUTE10,
    OBJECT_VERSION_NUMBER,
    BANK_CHARGE_BEARER_APL_FLAG,
    ATTRIBUTE12,
    ATTRIBUTE13,
    PAYMENT_METHOD_CODE,
    EXTERNAL_BANK_ACCT_APL_FLAG,
    SUPPORT_BILLS_PAYABLE_FLAG,
    DOCUMENT_CATEGORY_CODE,
    MATURITY_DATE_OFFSET_DAYS,
    INACTIVE_DATE,
    ANTICIPATED_FLOAT,
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
    ATTRIBUTE11,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    SEEDED_FLAG
  ) values (
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_REMITTANCE_MESSAGE1_APL_FLAG,
    X_REMITTANCE_MESSAGE2_APL_FLAG,
    X_REMITTANCE_MESSAGE3_APL_FLAG,
    X_UNIQUE_REMIT_ID_APL_FLAG,
    X_URI_CHECK_DIGIT_APL_FLAG,
    X_DELIVERY_CHANNEL_APL_FLAG,
    X_PAYMENT_FORMAT_APL_FLAG,
    X_SETTLEMENT_PRIORITY_APL_FLAG,
    X_EXCLUSIVE_PMT_APL_FLAG,
    X_REASON_APL_FLAG,
    X_REASON_COMNT_APL_FLAG,
    X_ATTRIBUTE10,
    X_OBJECT_VERSION_NUMBER,
    X_BANK_CHARGE_BEARER_APL_FLAG,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_PAYMENT_METHOD_CODE,
    X_EXTERNAL_BANK_ACCT_APL_FLAG,
    X_SUPPORT_BILLS_PAYABLE_FLAG,
    X_DOCUMENT_CATEGORY_CODE,
    X_MATURITY_DATE_OFFSET_DAYS,
    X_INACTIVE_DATE,
    X_ANTICIPATED_FLOAT,
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
    X_ATTRIBUTE11,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_SEEDED_FLAG
  );

  insert into IBY_PAYMENT_METHODS_TL (
    PAYMENT_METHOD_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    PAYMENT_METHOD_CODE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PAYMENT_METHOD_NAME,
    X_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_PAYMENT_METHOD_CODE,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from IBY_PAYMENT_METHODS_TL T
    where T.PAYMENT_METHOD_CODE = X_PAYMENT_METHOD_CODE
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
  X_PAYMENT_METHOD_CODE in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_REMITTANCE_MESSAGE1_APL_FLAG in VARCHAR2,
  X_REMITTANCE_MESSAGE2_APL_FLAG in VARCHAR2,
  X_REMITTANCE_MESSAGE3_APL_FLAG in VARCHAR2,
  X_UNIQUE_REMIT_ID_APL_FLAG in VARCHAR2,
  X_URI_CHECK_DIGIT_APL_FLAG in VARCHAR2,
  X_DELIVERY_CHANNEL_APL_FLAG in VARCHAR2,
  X_PAYMENT_FORMAT_APL_FLAG in VARCHAR2,
  X_SETTLEMENT_PRIORITY_APL_FLAG in VARCHAR2,
  X_EXCLUSIVE_PMT_APL_FLAG in VARCHAR2,
  X_REASON_APL_FLAG in VARCHAR2,
  X_REASON_COMNT_APL_FLAG in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_BANK_CHARGE_BEARER_APL_FLAG in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_EXTERNAL_BANK_ACCT_APL_FLAG in VARCHAR2,
  X_SUPPORT_BILLS_PAYABLE_FLAG in VARCHAR2,
  X_DOCUMENT_CATEGORY_CODE in VARCHAR2,
  X_MATURITY_DATE_OFFSET_DAYS in NUMBER,
  X_INACTIVE_DATE in DATE,
  X_ANTICIPATED_FLOAT in NUMBER,
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
  X_ATTRIBUTE11 in VARCHAR2,
  X_PAYMENT_METHOD_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ATTRIBUTE14,
      ATTRIBUTE15,
      REMITTANCE_MESSAGE1_APL_FLAG,
      REMITTANCE_MESSAGE2_APL_FLAG,
      REMITTANCE_MESSAGE3_APL_FLAG,
      UNIQUE_REMITTANCE_ID_APL_FLAG,
      URI_CHECK_DIGIT_APL_FLAG,
      DELIVERY_CHANNEL_APL_FLAG,
      PAYMENT_FORMAT_APL_FLAG,
      SETTLEMENT_PRIORITY_APL_FLAG,
      EXCLUSIVE_PMT_APL_FLAG,
      PAYMENT_REASON_APL_FLAG,
      PAYMENT_REASON_COMNT_APL_FLAG,
      ATTRIBUTE10,
      OBJECT_VERSION_NUMBER,
      BANK_CHARGE_BEARER_APL_FLAG,
      ATTRIBUTE12,
      ATTRIBUTE13,
      EXTERNAL_BANK_ACCT_APL_FLAG,
      SUPPORT_BILLS_PAYABLE_FLAG,
      DOCUMENT_CATEGORY_CODE,
      MATURITY_DATE_OFFSET_DAYS,
      INACTIVE_DATE,
      ANTICIPATED_FLOAT,
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
      ATTRIBUTE11
    from IBY_PAYMENT_METHODS_B
    where PAYMENT_METHOD_CODE = X_PAYMENT_METHOD_CODE
    for update of PAYMENT_METHOD_CODE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      PAYMENT_METHOD_NAME,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IBY_PAYMENT_METHODS_TL
    where PAYMENT_METHOD_CODE = X_PAYMENT_METHOD_CODE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PAYMENT_METHOD_CODE nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND (recinfo.REMITTANCE_MESSAGE1_APL_FLAG = X_REMITTANCE_MESSAGE1_APL_FLAG)
      AND (recinfo.REMITTANCE_MESSAGE2_APL_FLAG = X_REMITTANCE_MESSAGE2_APL_FLAG)
      AND (recinfo.REMITTANCE_MESSAGE3_APL_FLAG = X_REMITTANCE_MESSAGE3_APL_FLAG)
      AND (recinfo.UNIQUE_REMITTANCE_ID_APL_FLAG = X_UNIQUE_REMIT_ID_APL_FLAG)
      AND (recinfo.URI_CHECK_DIGIT_APL_FLAG = X_URI_CHECK_DIGIT_APL_FLAG)
      AND (recinfo.DELIVERY_CHANNEL_APL_FLAG = X_DELIVERY_CHANNEL_APL_FLAG)
      AND (recinfo.PAYMENT_FORMAT_APL_FLAG = X_PAYMENT_FORMAT_APL_FLAG)
      AND (recinfo.SETTLEMENT_PRIORITY_APL_FLAG = X_SETTLEMENT_PRIORITY_APL_FLAG)
      AND (recinfo.EXCLUSIVE_PMT_APL_FLAG = X_EXCLUSIVE_PMT_APL_FLAG)
      AND (recinfo.PAYMENT_REASON_APL_FLAG = X_REASON_APL_FLAG)
      AND (recinfo.PAYMENT_REASON_COMNT_APL_FLAG = X_REASON_COMNT_APL_FLAG)
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND (recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
      AND (recinfo.BANK_CHARGE_BEARER_APL_FLAG = X_BANK_CHARGE_BEARER_APL_FLAG)
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND (recinfo.EXTERNAL_BANK_ACCT_APL_FLAG = X_EXTERNAL_BANK_ACCT_APL_FLAG)
      AND (recinfo.SUPPORT_BILLS_PAYABLE_FLAG = X_SUPPORT_BILLS_PAYABLE_FLAG)
      AND ((recinfo.DOCUMENT_CATEGORY_CODE = X_DOCUMENT_CATEGORY_CODE)
           OR ((recinfo.DOCUMENT_CATEGORY_CODE is null) AND (X_DOCUMENT_CATEGORY_CODE is null)))
      AND ((recinfo.MATURITY_DATE_OFFSET_DAYS = X_MATURITY_DATE_OFFSET_DAYS)
           OR ((recinfo.MATURITY_DATE_OFFSET_DAYS is null) AND (X_MATURITY_DATE_OFFSET_DAYS is null)))
      AND ((recinfo.INACTIVE_DATE = X_INACTIVE_DATE)
           OR ((recinfo.INACTIVE_DATE is null) AND (X_INACTIVE_DATE is null)))
      AND ((recinfo.ANTICIPATED_FLOAT = X_ANTICIPATED_FLOAT)
           OR ((recinfo.ANTICIPATED_FLOAT is null) AND (X_ANTICIPATED_FLOAT is null)))
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
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.PAYMENT_METHOD_NAME = X_PAYMENT_METHOD_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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
  X_PAYMENT_METHOD_CODE in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_REMITTANCE_MESSAGE1_APL_FLAG in VARCHAR2,
  X_REMITTANCE_MESSAGE2_APL_FLAG in VARCHAR2,
  X_REMITTANCE_MESSAGE3_APL_FLAG in VARCHAR2,
  X_UNIQUE_REMIT_ID_APL_FLAG in VARCHAR2,
  X_URI_CHECK_DIGIT_APL_FLAG in VARCHAR2,
  X_DELIVERY_CHANNEL_APL_FLAG in VARCHAR2,
  X_PAYMENT_FORMAT_APL_FLAG in VARCHAR2,
  X_SETTLEMENT_PRIORITY_APL_FLAG in VARCHAR2,
  X_EXCLUSIVE_PMT_APL_FLAG in VARCHAR2,
  X_REASON_APL_FLAG in VARCHAR2,
  X_REASON_COMNT_APL_FLAG in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_BANK_CHARGE_BEARER_APL_FLAG in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_EXTERNAL_BANK_ACCT_APL_FLAG in VARCHAR2,
  X_SUPPORT_BILLS_PAYABLE_FLAG in VARCHAR2,
  X_DOCUMENT_CATEGORY_CODE in VARCHAR2,
  X_MATURITY_DATE_OFFSET_DAYS in NUMBER,
  X_INACTIVE_DATE in DATE,
  X_ANTICIPATED_FLOAT in NUMBER,
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
  X_ATTRIBUTE11 in VARCHAR2,
  X_PAYMENT_METHOD_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update IBY_PAYMENT_METHODS_B set
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    REMITTANCE_MESSAGE1_APL_FLAG = X_REMITTANCE_MESSAGE1_APL_FLAG,
    REMITTANCE_MESSAGE2_APL_FLAG = X_REMITTANCE_MESSAGE2_APL_FLAG,
    REMITTANCE_MESSAGE3_APL_FLAG = X_REMITTANCE_MESSAGE3_APL_FLAG,
    UNIQUE_REMITTANCE_ID_APL_FLAG = X_UNIQUE_REMIT_ID_APL_FLAG,
    URI_CHECK_DIGIT_APL_FLAG = X_URI_CHECK_DIGIT_APL_FLAG,
    DELIVERY_CHANNEL_APL_FLAG = X_DELIVERY_CHANNEL_APL_FLAG,
    PAYMENT_FORMAT_APL_FLAG = X_PAYMENT_FORMAT_APL_FLAG,
    SETTLEMENT_PRIORITY_APL_FLAG = X_SETTLEMENT_PRIORITY_APL_FLAG,
    EXCLUSIVE_PMT_APL_FLAG = X_EXCLUSIVE_PMT_APL_FLAG,
    PAYMENT_REASON_APL_FLAG = X_REASON_APL_FLAG,
    PAYMENT_REASON_COMNT_APL_FLAG = X_REASON_COMNT_APL_FLAG,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    BANK_CHARGE_BEARER_APL_FLAG = X_BANK_CHARGE_BEARER_APL_FLAG,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    EXTERNAL_BANK_ACCT_APL_FLAG = X_EXTERNAL_BANK_ACCT_APL_FLAG,
    SUPPORT_BILLS_PAYABLE_FLAG = X_SUPPORT_BILLS_PAYABLE_FLAG,
    DOCUMENT_CATEGORY_CODE = X_DOCUMENT_CATEGORY_CODE,
    MATURITY_DATE_OFFSET_DAYS = X_MATURITY_DATE_OFFSET_DAYS,
    INACTIVE_DATE = X_INACTIVE_DATE,
    ANTICIPATED_FLOAT = X_ANTICIPATED_FLOAT,
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
    ATTRIBUTE11 = X_ATTRIBUTE11,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PAYMENT_METHOD_CODE = X_PAYMENT_METHOD_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IBY_PAYMENT_METHODS_TL set
    PAYMENT_METHOD_NAME = X_PAYMENT_METHOD_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PAYMENT_METHOD_CODE = X_PAYMENT_METHOD_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_PAYMENT_METHOD_CODE in VARCHAR2
) is
begin
  delete from IBY_PAYMENT_METHODS_TL
  where PAYMENT_METHOD_CODE = X_PAYMENT_METHOD_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IBY_PAYMENT_METHODS_B
  where PAYMENT_METHOD_CODE = X_PAYMENT_METHOD_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from IBY_PAYMENT_METHODS_TL T
  where not exists
    (select NULL
    from IBY_PAYMENT_METHODS_B B
    where B.PAYMENT_METHOD_CODE = T.PAYMENT_METHOD_CODE
    );

  update IBY_PAYMENT_METHODS_TL T set (
      PAYMENT_METHOD_NAME,
      DESCRIPTION
    ) = (select
      B.PAYMENT_METHOD_NAME,
      B.DESCRIPTION
    from IBY_PAYMENT_METHODS_TL B
    where B.PAYMENT_METHOD_CODE = T.PAYMENT_METHOD_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PAYMENT_METHOD_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.PAYMENT_METHOD_CODE,
      SUBT.LANGUAGE
    from IBY_PAYMENT_METHODS_TL SUBB, IBY_PAYMENT_METHODS_TL SUBT
    where SUBB.PAYMENT_METHOD_CODE = SUBT.PAYMENT_METHOD_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PAYMENT_METHOD_NAME <> SUBT.PAYMENT_METHOD_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into IBY_PAYMENT_METHODS_TL (
    PAYMENT_METHOD_NAME,
    DESCRIPTION,
      LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    PAYMENT_METHOD_CODE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.PAYMENT_METHOD_NAME,
    B.DESCRIPTION,
      B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.PAYMENT_METHOD_CODE,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.OBJECT_VERSION_NUMBER,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IBY_PAYMENT_METHODS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IBY_PAYMENT_METHODS_TL T
    where T.PAYMENT_METHOD_CODE = B.PAYMENT_METHOD_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure LOAD_SEED_ROW (
  X_PAYMENT_METHOD_CODE in VARCHAR2,
  X_REMITTANCE_MESSAGE1_APL_FLAG in VARCHAR2,
  X_REMITTANCE_MESSAGE2_APL_FLAG in VARCHAR2,
  X_REMITTANCE_MESSAGE3_APL_FLAG in VARCHAR2,
  X_UNIQUE_REMIT_ID_APL_FLAG in VARCHAR2,
  X_URI_CHECK_DIGIT_APL_FLAG in VARCHAR2,
  X_DELIVERY_CHANNEL_APL_FLAG in VARCHAR2,
  X_PAYMENT_FORMAT_APL_FLAG in VARCHAR2,
  X_SETTLEMENT_PRIORITY_APL_FLAG in VARCHAR2,
  X_EXCLUSIVE_PMT_APL_FLAG in VARCHAR2,
  X_REASON_APL_FLAG in VARCHAR2,
  X_REASON_COMNT_APL_FLAG in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_BANK_CHARGE_BEARER_APL_FLAG in VARCHAR2,
  X_EXTERNAL_BANK_ACCT_APL_FLAG in VARCHAR2,
  X_SUPPORT_BILLS_PAYABLE_FLAG in VARCHAR2,
  X_INACTIVE_DATE in DATE,
  X_ANTICIPATED_FLOAT in NUMBER,
  X_PAYMENT_METHOD_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
)  is
   row_id VARCHAR2(200);
begin

  update IBY_PAYMENT_METHODS_B set
    REMITTANCE_MESSAGE1_APL_FLAG = X_REMITTANCE_MESSAGE1_APL_FLAG,
    REMITTANCE_MESSAGE2_APL_FLAG = X_REMITTANCE_MESSAGE2_APL_FLAG,
    REMITTANCE_MESSAGE3_APL_FLAG = X_REMITTANCE_MESSAGE3_APL_FLAG,
    UNIQUE_REMITTANCE_ID_APL_FLAG = X_UNIQUE_REMIT_ID_APL_FLAG,
    URI_CHECK_DIGIT_APL_FLAG = X_URI_CHECK_DIGIT_APL_FLAG,
    DELIVERY_CHANNEL_APL_FLAG = X_DELIVERY_CHANNEL_APL_FLAG,
    PAYMENT_FORMAT_APL_FLAG = X_PAYMENT_FORMAT_APL_FLAG,
    SETTLEMENT_PRIORITY_APL_FLAG = X_SETTLEMENT_PRIORITY_APL_FLAG,
    EXCLUSIVE_PMT_APL_FLAG = X_EXCLUSIVE_PMT_APL_FLAG,
    PAYMENT_REASON_APL_FLAG = X_REASON_APL_FLAG,
    PAYMENT_REASON_COMNT_APL_FLAG = X_REASON_COMNT_APL_FLAG,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    BANK_CHARGE_BEARER_APL_FLAG = X_BANK_CHARGE_BEARER_APL_FLAG,
    EXTERNAL_BANK_ACCT_APL_FLAG = X_EXTERNAL_BANK_ACCT_APL_FLAG,
    SUPPORT_BILLS_PAYABLE_FLAG = X_SUPPORT_BILLS_PAYABLE_FLAG,
    INACTIVE_DATE = X_INACTIVE_DATE,
    ANTICIPATED_FLOAT = X_ANTICIPATED_FLOAT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PAYMENT_METHOD_CODE = X_PAYMENT_METHOD_CODE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update IBY_PAYMENT_METHODS_TL set
    PAYMENT_METHOD_NAME = X_PAYMENT_METHOD_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PAYMENT_METHOD_CODE = X_PAYMENT_METHOD_CODE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;

 exception
    when no_data_found then
      INSERT_ROW (
  row_id,
  X_PAYMENT_METHOD_CODE,
  null,
  null,
  X_REMITTANCE_MESSAGE1_APL_FLAG,
  X_REMITTANCE_MESSAGE2_APL_FLAG,
  X_REMITTANCE_MESSAGE3_APL_FLAG,
  X_UNIQUE_REMIT_ID_APL_FLAG,
  X_URI_CHECK_DIGIT_APL_FLAG,
  X_DELIVERY_CHANNEL_APL_FLAG,
  X_PAYMENT_FORMAT_APL_FLAG,
  X_SETTLEMENT_PRIORITY_APL_FLAG,
  X_EXCLUSIVE_PMT_APL_FLAG,
  X_REASON_APL_FLAG,
  X_REASON_COMNT_APL_FLAG,
 null,
  X_OBJECT_VERSION_NUMBER,
  X_BANK_CHARGE_BEARER_APL_FLAG,
 null,
null,
  X_EXTERNAL_BANK_ACCT_APL_FLAG,
  X_SUPPORT_BILLS_PAYABLE_FLAG,
 null,
 null,
  X_INACTIVE_DATE,
  X_ANTICIPATED_FLOAT,
  null,
  null,
  null,
  null,
 null,
  null,
  null,
  null,
  null,
  null,
  null,
  X_PAYMENT_METHOD_NAME,
  X_DESCRIPTION,
  X_CREATION_DATE,
  X_CREATED_BY,
  X_LAST_UPDATE_DATE,
  X_LAST_UPDATED_BY,
  X_LAST_UPDATE_LOGIN,
  X_SEEDED_FLAG);

end LOAD_SEED_ROW;

procedure TRANSLATE_ROW (
  X_PAYMENT_METHOD_CODE in VARCHAR2,
  X_PAYMENT_METHOD_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2)
is
begin
  update iby_payment_methods_tl set
    PAYMENT_METHOD_NAME = X_PAYMENT_METHOD_NAME,
    DESCRIPTION = X_DESCRIPTION,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LAST_UPDATED_BY = fnd_load_util.owner_id(X_OWNER),
    LAST_UPDATE_DATE = trunc(sysdate),
    LAST_UPDATE_LOGIN = fnd_load_util.owner_id(X_OWNER),
    SOURCE_LANG = userenv('LANG')
  where userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    and PAYMENT_METHOD_CODE = X_PAYMENT_METHOD_CODE;
end;

procedure LOAD_SEED_APL_ROW (
  X_PAYMENT_METHOD_CODE in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PAYMENT_FLOW in VARCHAR2,
  X_APPLICABLE_TYPE_CODE in VARCHAR2,
  X_APPLICABLE_VALUE_FROM in VARCHAR2,
  X_APPLICABLE_VALUE_TO in VARCHAR2,
  X_APPLICATION_ID in  NUMBER,
  X_INACTIVE_DATE in DATE,
  X_EXCLUDE_FROM_APPLIC_FLAG VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
l_result number;

begin

select 1
into l_result
from
IBY_APPLICABLE_PMT_MTHDS
where application_id=X_APPLICATION_ID
and   payment_flow=x_payment_flow
and   applicable_type_code=x_applicable_type_code
and   payment_method_code=x_payment_method_code
and  rownum=1;

exception
    when no_data_found then
        insert into IBY_APPLICABLE_PMT_MTHDS
  ( APPLICABLE_PMT_MTHD_ID,
    PAYMENT_METHOD_CODE,
    PAYMENT_FLOW,
    APPLICABLE_TYPE_CODE,
    APPLICABLE_VALUE_FROM,
    APPLICABLE_VALUE_TO,
    APPLICATION_ID,
    INACTIVE_DATE,
    EXCLUDE_FROM_APPLIC_FLAG,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    OBJECT_VERSION_NUMBER)
    VALUES
     ( iby_applicable_pmt_mthds_s.nextval,
    X_PAYMENT_METHOD_CODE,
    X_PAYMENT_FLOW,
    X_APPLICABLE_TYPE_CODE,
    X_APPLICABLE_VALUE_FROM,
    X_APPLICABLE_VALUE_TO,
    X_APPLICATION_ID,
    X_INACTIVE_DATE,
    X_EXCLUDE_FROM_APPLIC_FLAG,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    X_LAST_UPDATED_BY,
    X_OBJECT_VERSION_NUMBER);

end LOAD_SEED_APL_ROW;

end IBY_PAYMENT_METHODS_PKG;

/