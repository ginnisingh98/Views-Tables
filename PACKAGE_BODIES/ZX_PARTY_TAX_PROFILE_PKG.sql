--------------------------------------------------------
--  DDL for Package Body ZX_PARTY_TAX_PROFILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_PARTY_TAX_PROFILE_PKG" as
/* $Header: zxcptytaxprfileb.pls 120.9.12010000.4 2010/03/02 17:02:30 srajapar ship $ */


procedure INSERT_ROW (
  p_collecting_authority_flag    IN VARCHAR2,
  p_provider_type_code           IN VARCHAR2,
  p_create_awt_dists_type_code   IN VARCHAR2,
  p_create_awt_invoices_type_cod IN VARCHAR2,
  p_tax_classification_code      IN VARCHAR2,
  p_self_assess_flag             IN VARCHAR2,
  p_allow_offset_tax_flag        IN VARCHAR2,
  p_rep_registration_number      IN VARCHAR2,
  p_effective_from_use_le        IN DATE,
  p_record_type_code             IN VARCHAR2,
  p_request_id                   IN NUMBER,
  p_attribute1                   IN VARCHAR2,
  p_attribute2                   IN VARCHAR2,
  p_attribute3                   IN VARCHAR2,
  p_attribute4                   IN VARCHAR2,
  p_attribute5                   IN VARCHAR2,
  p_attribute6                   IN VARCHAR2,
  p_attribute7                   IN VARCHAR2,
  p_attribute8                   IN VARCHAR2,
  p_attribute9                   IN VARCHAR2,
  p_attribute10                  IN VARCHAR2,
  p_attribute11                  IN VARCHAR2,
  p_attribute12                  IN VARCHAR2,
  p_attribute13                  IN VARCHAR2,
  p_attribute14                  IN VARCHAR2,
  p_attribute15                  IN VARCHAR2,
  p_attribute_category           IN VARCHAR2,
  p_party_id                     IN NUMBER,
  p_program_login_id             IN NUMBER,
  p_party_type_code              IN VARCHAR2,
  p_supplier_flag                IN VARCHAR2,
  p_customer_flag                IN VARCHAR2,
  p_site_flag                    IN VARCHAR2,
  p_process_for_applicability_fl IN VARCHAR2,
  p_rounding_level_code          IN VARCHAR2,
  p_rounding_rule_code           IN VARCHAR2,
  p_withholding_start_date       IN DATE,
  p_inclusive_tax_flag           IN VARCHAR2,
  p_allow_awt_flag               IN VARCHAR2,
  p_use_le_as_subscriber_flag    IN VARCHAR2,
  p_legal_establishment_flag     IN VARCHAR2,
  p_first_party_le_flag          IN VARCHAR2,
  p_reporting_authority_flag     IN VARCHAR2,
  x_return_status               OUT NOCOPY VARCHAR2
) is
  L_PARTY_TAX_PROFILE_ID   ZX_PARTY_TAX_PROFILE.PARTY_TAX_PROFILE_ID%TYPE;
  L_EFFECTIVE_FROM_USE_LE  ZX_PARTY_TAX_PROFILE.EFFECTIVE_FROM_USE_LE%TYPE  := P_EFFECTIVE_FROM_USE_LE;
  L_CREATED_BY_MODULE      HZ_PARTIES.CREATED_BY_MODULE%TYPE;

  CURSOR ptp_cur IS
  SELECT PARTY_TAX_PROFILE_ID
  FROM ZX_PARTY_TAX_PROFILE
  WHERE PARTY_TAX_PROFILE_ID = L_PARTY_TAX_PROFILE_ID;
begin
  --Initialise x_return_status variable
  X_RETURN_STATUS :=  FND_API.G_RET_STS_SUCCESS;
  select ZX_PARTY_TAX_PROFILE_S.nextval into L_PARTY_TAX_PROFILE_ID from dual;
  --Perform validations before inserting data
  --AllowOffsetTax and SetforSelfAssessment flag would be mutually exclusive
  BEGIN
  -- Check created module name
  select nvl(substr(created_by_module,1,3),'ZX') created_by_module
    into L_CREATED_BY_MODULE
    from hz_parties where party_id = P_PARTY_ID;
  IF L_CREATED_BY_MODULE = 'XLE' THEN
     return;
  END IF;
  EXCEPTION
      WHEN OTHERS THEN NULL;
  END;
  IF P_SELF_ASSESS_FLAG = 'Y' AND P_ALLOW_OFFSET_TAX_FLAG = 'Y' THEN
    X_RETURN_STATUS :=  FND_API.G_RET_STS_ERROR;
    arp_util_tax.debug('Error: "Offset Tax and Set for Self Assessment can not both be "Y" at the same time." for Party Id: ' || P_PARTY_ID || ' and Party Type: ' ||P_PARTY_TYPE_CODE);
  END IF;
  --when UseLeAsSubscriberFlag is set to 'Y', then setEffectiveFromUseLe as System date
  IF P_USE_LE_AS_SUBSCRIBER_FLAG = 'Y' THEN
    L_EFFECTIVE_FROM_USE_LE := SYSDATE;
  END IF;
  --Insert only when there is no error
  IF X_RETURN_STATUS =  FND_API.G_RET_STS_SUCCESS THEN
    insert into ZX_PARTY_TAX_PROFILE (
    COLLECTING_AUTHORITY_FLAG,
    PROVIDER_TYPE_CODE,
    CREATE_AWT_DISTS_TYPE_CODE,
    CREATE_AWT_INVOICES_TYPE_CODE,
    TAX_CLASSIFICATION_CODE,
    SELF_ASSESS_FLAG,
    ALLOW_OFFSET_TAX_FLAG,
    REP_REGISTRATION_NUMBER,
    EFFECTIVE_FROM_USE_LE,
    RECORD_TYPE_CODE,
    REQUEST_ID,
    PARTY_TAX_PROFILE_ID,
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
    ATTRIBUTE_CATEGORY,
    PARTY_ID,
    PROGRAM_LOGIN_ID,
    PARTY_TYPE_CODE,
    SUPPLIER_FLAG,
    CUSTOMER_FLAG,
    SITE_FLAG,
    PROCESS_FOR_APPLICABILITY_FLAG,
    ROUNDING_LEVEL_CODE,
    ROUNDING_RULE_CODE,
    WITHHOLDING_START_DATE,
    INCLUSIVE_TAX_FLAG,
    ALLOW_AWT_FLAG,
    USE_LE_AS_SUBSCRIBER_FLAG,
    LEGAL_ESTABLISHMENT_FLAG,
    FIRST_PARTY_LE_FLAG,
    REPORTING_AUTHORITY_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER
  ) values (
    P_COLLECTING_AUTHORITY_FLAG,
    P_PROVIDER_TYPE_CODE,
    P_CREATE_AWT_DISTS_TYPE_CODE,
    P_CREATE_AWT_INVOICES_TYPE_COD,
    P_TAX_CLASSIFICATION_CODE,
    P_SELF_ASSESS_FLAG,
    P_ALLOW_OFFSET_TAX_FLAG,
    DECODE(P_REP_REGISTRATION_NUMBER, fnd_api.g_miss_char,
           NULL, P_REP_REGISTRATION_NUMBER),
    L_EFFECTIVE_FROM_USE_LE,
    P_RECORD_TYPE_CODE,
    P_REQUEST_ID,
    L_PARTY_TAX_PROFILE_ID,
    P_ATTRIBUTE1,
    P_ATTRIBUTE2,
    P_ATTRIBUTE3,
    P_ATTRIBUTE4,
    P_ATTRIBUTE5,
    P_ATTRIBUTE6,
    P_ATTRIBUTE7,
    P_ATTRIBUTE8,
    P_ATTRIBUTE9,
    P_ATTRIBUTE10,
    P_ATTRIBUTE11,
    P_ATTRIBUTE12,
    P_ATTRIBUTE13,
    P_ATTRIBUTE14,
    P_ATTRIBUTE15,
    P_ATTRIBUTE_CATEGORY,
    P_PARTY_ID,
    P_PROGRAM_LOGIN_ID,
    P_PARTY_TYPE_CODE,
    P_SUPPLIER_FLAG,
    P_CUSTOMER_FLAG,
    P_SITE_FLAG,
    P_PROCESS_FOR_APPLICABILITY_FL,
    P_ROUNDING_LEVEL_CODE,
    P_ROUNDING_RULE_CODE,
    P_WITHHOLDING_START_DATE,
    P_INCLUSIVE_TAX_FLAG,
    P_ALLOW_AWT_FLAG,
    P_USE_LE_AS_SUBSCRIBER_FLAG,
    P_LEGAL_ESTABLISHMENT_FLAG,
    P_FIRST_PARTY_LE_FLAG,
    P_REPORTING_AUTHORITY_FLAG,
    sysdate,
    FND_GLOBAL.User_ID,
    sysdate,
    FND_GLOBAL.User_ID,
    FND_GLOBAL.Login_ID,
    1
    );
    OPEN ptp_cur;
    FETCH ptp_cur INTO L_PARTY_TAX_PROFILE_ID;
    IF (ptp_cur%notfound) then
          --Set x_return_status param
          X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
    arp_util_tax.debug('Error: "The Ptp row has not been inserted for Party Id: ' || P_PARTY_ID || ' and Party Type: ' ||P_PARTY_TYPE_CODE || '."');
    END IF;
    CLOSE ptp_cur;
  END IF;
  EXCEPTION
    --Index violation check
    WHEN DUP_VAL_ON_INDEX THEN
      --Set x_return_status param
      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
      arp_util_tax.debug('Error: "The Ptp row already exists for Party Id: ' || P_PARTY_ID || ' and Party Type: ' ||P_PARTY_TYPE_CODE || '."');
end INSERT_ROW;


procedure INSERT_ROW (
  p_collecting_authority_flag    IN VARCHAR2,
  p_provider_type_code           IN VARCHAR2,
  p_create_awt_dists_type_code   IN VARCHAR2,
  p_create_awt_invoices_type_cod IN VARCHAR2,
  p_tax_classification_code      IN VARCHAR2,
  p_self_assess_flag             IN VARCHAR2,
  p_allow_offset_tax_flag        IN VARCHAR2,
  p_rep_registration_number      IN VARCHAR2,
  p_effective_from_use_le        IN DATE,
  p_record_type_code             IN VARCHAR2,
  p_request_id                   IN NUMBER,
  p_attribute1                   IN VARCHAR2,
  p_attribute2                   IN VARCHAR2,
  p_attribute3                   IN VARCHAR2,
  p_attribute4                   IN VARCHAR2,
  p_attribute5                   IN VARCHAR2,
  p_attribute6                   IN VARCHAR2,
  p_attribute7                   IN VARCHAR2,
  p_attribute8                   IN VARCHAR2,
  p_attribute9                   IN VARCHAR2,
  p_attribute10                  IN VARCHAR2,
  p_attribute11                  IN VARCHAR2,
  p_attribute12                  IN VARCHAR2,
  p_attribute13                  IN VARCHAR2,
  p_attribute14                  IN VARCHAR2,
  p_attribute15                  IN VARCHAR2,
  p_attribute_category           IN VARCHAR2,
  p_party_id                     IN NUMBER,
  p_program_login_id             IN NUMBER,
  p_party_type_code              IN VARCHAR2,
  p_supplier_flag                IN VARCHAR2,
  p_customer_flag                IN VARCHAR2,
  p_site_flag                    IN VARCHAR2,
  p_process_for_applicability_fl IN VARCHAR2,
  p_rounding_level_code          IN VARCHAR2,
  p_rounding_rule_code           IN VARCHAR2,
  p_withholding_start_date       IN DATE,
  p_inclusive_tax_flag           IN VARCHAR2,
  p_allow_awt_flag               IN VARCHAR2,
  p_use_le_as_subscriber_flag    IN VARCHAR2,
  p_legal_establishment_flag     IN VARCHAR2,
  p_first_party_le_flag          IN VARCHAR2,
  p_reporting_authority_flag     IN VARCHAR2,
  x_return_status               OUT NOCOPY VARCHAR2,
  p_registration_type_code       IN VARCHAR2,
  p_country_code                 IN VARCHAR2
) is
  L_PARTY_TAX_PROFILE_ID   ZX_PARTY_TAX_PROFILE.PARTY_TAX_PROFILE_ID%TYPE;
  L_EFFECTIVE_FROM_USE_LE  ZX_PARTY_TAX_PROFILE.EFFECTIVE_FROM_USE_LE%TYPE  := P_EFFECTIVE_FROM_USE_LE;
  L_CREATED_BY_MODULE      HZ_PARTIES.CREATED_BY_MODULE%TYPE;

  CURSOR ptp_cur IS
  SELECT PARTY_TAX_PROFILE_ID
  FROM ZX_PARTY_TAX_PROFILE
  WHERE PARTY_TAX_PROFILE_ID = L_PARTY_TAX_PROFILE_ID;

begin
  --Initialise x_return_status variable
  X_RETURN_STATUS :=  FND_API.G_RET_STS_SUCCESS;
  select ZX_PARTY_TAX_PROFILE_S.nextval into L_PARTY_TAX_PROFILE_ID from dual;

  BEGIN
    -- Check created module name
    select nvl(substr(created_by_module,1,3),'ZX') created_by_module
    into L_CREATED_BY_MODULE
    from hz_parties where party_id = P_PARTY_ID;

    IF L_CREATED_BY_MODULE = 'XLE' THEN
      return;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  --Perform validations before inserting data
  --AllowOffsetTax and SetforSelfAssessment flag would be mutually exclusive
  IF P_SELF_ASSESS_FLAG = 'Y' AND P_ALLOW_OFFSET_TAX_FLAG = 'Y' THEN
    X_RETURN_STATUS :=  FND_API.G_RET_STS_ERROR;
    arp_util_tax.debug('Error: "Offset Tax and Set for Self Assessment can not both be "Y" at the same time." for Party Id: ' || P_PARTY_ID || ' and Party Type: ' ||P_PARTY_TYPE_CODE);
  END IF;
  --when UseLeAsSubscriberFlag is set to 'Y', then setEffectiveFromUseLe as System date
  IF P_USE_LE_AS_SUBSCRIBER_FLAG = 'Y' THEN
    L_EFFECTIVE_FROM_USE_LE := SYSDATE;
  END IF;
  --Insert only when there is no error
  IF X_RETURN_STATUS =  FND_API.G_RET_STS_SUCCESS THEN
    insert into ZX_PARTY_TAX_PROFILE (
    COLLECTING_AUTHORITY_FLAG,
    PROVIDER_TYPE_CODE,
    CREATE_AWT_DISTS_TYPE_CODE,
    CREATE_AWT_INVOICES_TYPE_CODE,
    TAX_CLASSIFICATION_CODE,
    SELF_ASSESS_FLAG,
    ALLOW_OFFSET_TAX_FLAG,
    REP_REGISTRATION_NUMBER,
    EFFECTIVE_FROM_USE_LE,
    RECORD_TYPE_CODE,
    REQUEST_ID,
    PARTY_TAX_PROFILE_ID,
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
    ATTRIBUTE_CATEGORY,
    PARTY_ID,
    PROGRAM_LOGIN_ID,
    PARTY_TYPE_CODE,
    SUPPLIER_FLAG,
    CUSTOMER_FLAG,
    SITE_FLAG,
    PROCESS_FOR_APPLICABILITY_FLAG,
    ROUNDING_LEVEL_CODE,
    ROUNDING_RULE_CODE,
    WITHHOLDING_START_DATE,
    INCLUSIVE_TAX_FLAG,
    ALLOW_AWT_FLAG,
    USE_LE_AS_SUBSCRIBER_FLAG,
    LEGAL_ESTABLISHMENT_FLAG,
    FIRST_PARTY_LE_FLAG,
    REPORTING_AUTHORITY_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    REGISTRATION_TYPE_CODE,
    COUNTRY_CODE
  ) values (
    P_COLLECTING_AUTHORITY_FLAG,
    P_PROVIDER_TYPE_CODE,
    P_CREATE_AWT_DISTS_TYPE_CODE,
    P_CREATE_AWT_INVOICES_TYPE_COD,
    P_TAX_CLASSIFICATION_CODE,
    P_SELF_ASSESS_FLAG,
    P_ALLOW_OFFSET_TAX_FLAG,
    DECODE(P_REP_REGISTRATION_NUMBER, fnd_api.g_miss_char,
           NULL, P_REP_REGISTRATION_NUMBER),
    L_EFFECTIVE_FROM_USE_LE,
    P_RECORD_TYPE_CODE,
    P_REQUEST_ID,
    L_PARTY_TAX_PROFILE_ID,
    P_ATTRIBUTE1,
    P_ATTRIBUTE2,
    P_ATTRIBUTE3,
    P_ATTRIBUTE4,
    P_ATTRIBUTE5,
    P_ATTRIBUTE6,
    P_ATTRIBUTE7,
    P_ATTRIBUTE8,
    P_ATTRIBUTE9,
    P_ATTRIBUTE10,
    P_ATTRIBUTE11,
    P_ATTRIBUTE12,
    P_ATTRIBUTE13,
    P_ATTRIBUTE14,
    P_ATTRIBUTE15,
    P_ATTRIBUTE_CATEGORY,
    P_PARTY_ID,
    P_PROGRAM_LOGIN_ID,
    P_PARTY_TYPE_CODE,
    P_SUPPLIER_FLAG,
    P_CUSTOMER_FLAG,
    P_SITE_FLAG,
    P_PROCESS_FOR_APPLICABILITY_FL,
    P_ROUNDING_LEVEL_CODE,
    P_ROUNDING_RULE_CODE,
    P_WITHHOLDING_START_DATE,
    P_INCLUSIVE_TAX_FLAG,
    P_ALLOW_AWT_FLAG,
    P_USE_LE_AS_SUBSCRIBER_FLAG,
    P_LEGAL_ESTABLISHMENT_FLAG,
    P_FIRST_PARTY_LE_FLAG,
    P_REPORTING_AUTHORITY_FLAG,
    sysdate,
    FND_GLOBAL.User_ID,
    sysdate,
    FND_GLOBAL.User_ID,
    FND_GLOBAL.Login_ID,
    1,
    P_REGISTRATION_TYPE_CODE,
    P_COUNTRY_CODE
    );
    OPEN ptp_cur;
    FETCH ptp_cur INTO L_PARTY_TAX_PROFILE_ID;
    IF (ptp_cur%notfound) then
          --Set x_return_status param
          X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
    arp_util_tax.debug('Error: "The Ptp row has not been inserted for Party Id: ' || P_PARTY_ID || ' and Party Type: ' ||P_PARTY_TYPE_CODE || '."');
    END IF;
    CLOSE ptp_cur;
  END IF;
  EXCEPTION
    --Index violation check
    WHEN DUP_VAL_ON_INDEX THEN
      --Set x_return_status param
      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
      arp_util_tax.debug('Error: "The Ptp row already exists for Party Id: ' || P_PARTY_ID || ' and Party Type: ' ||P_PARTY_TYPE_CODE || '."');
end INSERT_ROW;


procedure UPDATE_ROW (
  p_party_tax_profile_id         IN NUMBER,
  p_collecting_authority_flag    IN VARCHAR2,
  p_provider_type_code           IN VARCHAR2,
  p_create_awt_dists_type_code   IN VARCHAR2,
  p_create_awt_invoices_type_cod IN VARCHAR2,
  p_tax_classification_code      IN VARCHAR2,
  p_self_assess_flag             IN VARCHAR2,
  p_allow_offset_tax_flag        IN VARCHAR2,
  p_rep_registration_number      IN VARCHAR2,
  p_effective_from_use_le        IN DATE,
  p_record_type_code             IN VARCHAR2,
  p_request_id                   IN NUMBER,
  p_attribute1                   IN VARCHAR2,
  p_attribute2                   IN VARCHAR2,
  p_attribute3                   IN VARCHAR2,
  p_attribute4                   IN VARCHAR2,
  p_attribute5                   IN VARCHAR2,
  p_attribute6                   IN VARCHAR2,
  p_attribute7                   IN VARCHAR2,
  p_attribute8                   IN VARCHAR2,
  p_attribute9                   IN VARCHAR2,
  p_attribute10                  IN VARCHAR2,
  p_attribute11                  IN VARCHAR2,
  p_attribute12                  IN VARCHAR2,
  p_attribute13                  IN VARCHAR2,
  p_attribute14                  IN VARCHAR2,
  p_attribute15                  IN VARCHAR2,
  p_attribute_category           IN VARCHAR2,
  p_party_id                     IN NUMBER,
  p_program_login_id             IN NUMBER,
  p_party_type_code              IN VARCHAR2,
  p_supplier_flag                IN VARCHAR2,
  p_customer_flag                IN VARCHAR2,
  p_site_flag                    IN VARCHAR2,
  p_process_for_applicability_fl IN VARCHAR2,
  p_rounding_level_code          IN VARCHAR2,
  p_rounding_rule_code           IN VARCHAR2,
  p_withholding_start_date       IN DATE,
  p_inclusive_tax_flag           IN VARCHAR2,
  p_allow_awt_flag               IN VARCHAR2,
  p_use_le_as_subscriber_flag    IN VARCHAR2,
  p_legal_establishment_flag     IN VARCHAR2,
  p_first_party_le_flag          IN VARCHAR2,
  p_reporting_authority_flag     IN VARCHAR2,
  x_return_status               OUT NOCOPY VARCHAR2
) is
  L_EFFECTIVE_FROM_USE_LE  ZX_PARTY_TAX_PROFILE.EFFECTIVE_FROM_USE_LE%TYPE  := P_EFFECTIVE_FROM_USE_LE;
begin
  --Initialise x_return_status variable
  X_RETURN_STATUS :=  FND_API.G_RET_STS_SUCCESS;
  --Perform validations before inserting data
  --AllowOffsetTax and SetforSelfAssessment flag would be mutually exclusive
  IF P_SELF_ASSESS_FLAG = 'Y' AND P_ALLOW_OFFSET_TAX_FLAG = 'Y' THEN
    X_RETURN_STATUS :=  FND_API.G_RET_STS_ERROR;
    arp_util_tax.debug('Error: "Offset Tax and Set for Self Assessment can not both be "Y" at the same time." for Party Id: ' || P_PARTY_ID || ' and Party Type: ' ||P_PARTY_TYPE_CODE);
  END IF;
  --when UseLeAsSubscriberFlag is set to 'Y', then setEffectiveFromUseLe as System date
  IF P_USE_LE_AS_SUBSCRIBER_FLAG = 'Y' THEN
    L_EFFECTIVE_FROM_USE_LE := SYSDATE;
  ELSE
    L_EFFECTIVE_FROM_USE_LE := NULL;
  END IF;
  --Update only when there is no error
  IF X_RETURN_STATUS =  FND_API.G_RET_STS_SUCCESS THEN
    update ZX_PARTY_TAX_PROFILE set
    COLLECTING_AUTHORITY_FLAG = DECODE( P_COLLECTING_AUTHORITY_FLAG, NULL, COLLECTING_AUTHORITY_FLAG, P_COLLECTING_AUTHORITY_FLAG ),
    PROVIDER_TYPE_CODE = DECODE( P_PROVIDER_TYPE_CODE, NULL, PROVIDER_TYPE_CODE, P_PROVIDER_TYPE_CODE ),
    CREATE_AWT_DISTS_TYPE_CODE = DECODE( P_CREATE_AWT_DISTS_TYPE_CODE, NULL, CREATE_AWT_DISTS_TYPE_CODE, P_CREATE_AWT_DISTS_TYPE_CODE ),
    CREATE_AWT_INVOICES_TYPE_CODE = DECODE( P_CREATE_AWT_INVOICES_TYPE_COD, NULL, CREATE_AWT_INVOICES_TYPE_CODE, P_CREATE_AWT_INVOICES_TYPE_COD ),
    TAX_CLASSIFICATION_CODE = DECODE( P_TAX_CLASSIFICATION_CODE, NULL, TAX_CLASSIFICATION_CODE, P_TAX_CLASSIFICATION_CODE ),
    SELF_ASSESS_FLAG = DECODE( P_SELF_ASSESS_FLAG, NULL, SELF_ASSESS_FLAG, P_SELF_ASSESS_FLAG ),
    ALLOW_OFFSET_TAX_FLAG = DECODE( P_ALLOW_OFFSET_TAX_FLAG, NULL, ALLOW_OFFSET_TAX_FLAG, P_ALLOW_OFFSET_TAX_FLAG ),
    REP_REGISTRATION_NUMBER = DECODE( P_REP_REGISTRATION_NUMBER, NULL, REP_REGISTRATION_NUMBER,fnd_api.g_miss_char, NULL, P_REP_REGISTRATION_NUMBER ),
    EFFECTIVE_FROM_USE_LE = DECODE( L_EFFECTIVE_FROM_USE_LE, NULL, EFFECTIVE_FROM_USE_LE, L_EFFECTIVE_FROM_USE_LE ),
    RECORD_TYPE_CODE = DECODE( P_RECORD_TYPE_CODE, NULL, RECORD_TYPE_CODE, P_RECORD_TYPE_CODE ),
    REQUEST_ID = DECODE( P_REQUEST_ID, NULL, REQUEST_ID, P_REQUEST_ID ),
    ATTRIBUTE1 = DECODE( P_ATTRIBUTE1, NULL, ATTRIBUTE1, P_ATTRIBUTE1 ),
    ATTRIBUTE2 = DECODE( P_ATTRIBUTE2, NULL, ATTRIBUTE2, P_ATTRIBUTE2 ),
    ATTRIBUTE3 = DECODE( P_ATTRIBUTE3, NULL, ATTRIBUTE3, P_ATTRIBUTE3 ),
    ATTRIBUTE4 = DECODE( P_ATTRIBUTE4, NULL, ATTRIBUTE4, P_ATTRIBUTE4 ),
    ATTRIBUTE5 = DECODE( P_ATTRIBUTE5, NULL, ATTRIBUTE5, P_ATTRIBUTE5 ),
    ATTRIBUTE6 = DECODE( P_ATTRIBUTE6, NULL, ATTRIBUTE6, P_ATTRIBUTE6 ),
    ATTRIBUTE7 = DECODE( P_ATTRIBUTE7, NULL, ATTRIBUTE7, P_ATTRIBUTE7 ),
    ATTRIBUTE8 = DECODE( P_ATTRIBUTE8, NULL, ATTRIBUTE8, P_ATTRIBUTE8 ),
    ATTRIBUTE9 = DECODE( P_ATTRIBUTE9, NULL, ATTRIBUTE9, P_ATTRIBUTE9 ),
    ATTRIBUTE10 = DECODE( P_ATTRIBUTE10, NULL, ATTRIBUTE10, P_ATTRIBUTE10 ),
    ATTRIBUTE11 = DECODE( P_ATTRIBUTE11, NULL, ATTRIBUTE11, P_ATTRIBUTE11 ),
    ATTRIBUTE12 = DECODE( P_ATTRIBUTE12, NULL, ATTRIBUTE12, P_ATTRIBUTE12 ),
    ATTRIBUTE13 = DECODE( P_ATTRIBUTE13, NULL, ATTRIBUTE13, P_ATTRIBUTE13 ),
    ATTRIBUTE14 = DECODE( P_ATTRIBUTE14, NULL, ATTRIBUTE14, P_ATTRIBUTE14 ),
    ATTRIBUTE15 = DECODE( P_ATTRIBUTE15, NULL, ATTRIBUTE15, P_ATTRIBUTE15 ),
    ATTRIBUTE_CATEGORY = DECODE( P_ATTRIBUTE_CATEGORY, NULL, ATTRIBUTE_CATEGORY, P_ATTRIBUTE_CATEGORY ),
    PARTY_ID = DECODE( P_PARTY_ID, NULL, PARTY_ID, P_PARTY_ID ),
    PROGRAM_LOGIN_ID = DECODE( P_PROGRAM_LOGIN_ID, NULL, PROGRAM_LOGIN_ID, P_PROGRAM_LOGIN_ID ),
    PARTY_TYPE_CODE = DECODE( P_PARTY_TYPE_CODE, NULL, PARTY_TYPE_CODE, P_PARTY_TYPE_CODE),
    SUPPLIER_FLAG = DECODE( P_SUPPLIER_FLAG, NULL, SUPPLIER_FLAG, P_SUPPLIER_FLAG ),
    CUSTOMER_FLAG = DECODE( P_CUSTOMER_FLAG, NULL, CUSTOMER_FLAG, P_CUSTOMER_FLAG ),
    SITE_FLAG = DECODE( P_SITE_FLAG, NULL, SITE_FLAG, P_SITE_FLAG ),
    PROCESS_FOR_APPLICABILITY_FLAG = DECODE( P_PROCESS_FOR_APPLICABILITY_FL, NULL, PROCESS_FOR_APPLICABILITY_FLAG, P_PROCESS_FOR_APPLICABILITY_FL ),
    ROUNDING_LEVEL_CODE = DECODE( P_ROUNDING_LEVEL_CODE, NULL, ROUNDING_LEVEL_CODE, P_ROUNDING_LEVEL_CODE ),
    ROUNDING_RULE_CODE = DECODE( P_ROUNDING_RULE_CODE, NULL, ROUNDING_RULE_CODE, P_ROUNDING_RULE_CODE ),
    WITHHOLDING_START_DATE = DECODE( P_WITHHOLDING_START_DATE, NULL, WITHHOLDING_START_DATE, P_WITHHOLDING_START_DATE ),
    INCLUSIVE_TAX_FLAG = DECODE( P_INCLUSIVE_TAX_FLAG, NULL, INCLUSIVE_TAX_FLAG, P_INCLUSIVE_TAX_FLAG ),
    ALLOW_AWT_FLAG = DECODE( P_ALLOW_AWT_FLAG, NULL, ALLOW_AWT_FLAG, P_ALLOW_AWT_FLAG ),
    USE_LE_AS_SUBSCRIBER_FLAG = DECODE( P_USE_LE_AS_SUBSCRIBER_FLAG, NULL, USE_LE_AS_SUBSCRIBER_FLAG, P_USE_LE_AS_SUBSCRIBER_FLAG ),
    LEGAL_ESTABLISHMENT_FLAG = DECODE( P_LEGAL_ESTABLISHMENT_FLAG, NULL, LEGAL_ESTABLISHMENT_FLAG, P_LEGAL_ESTABLISHMENT_FLAG ),
    FIRST_PARTY_LE_FLAG = DECODE( P_FIRST_PARTY_LE_FLAG, NULL, FIRST_PARTY_LE_FLAG, P_FIRST_PARTY_LE_FLAG ),
    REPORTING_AUTHORITY_FLAG = DECODE( P_REPORTING_AUTHORITY_FLAG, NULL, REPORTING_AUTHORITY_FLAG, P_REPORTING_AUTHORITY_FLAG ),
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = FND_GLOBAL.User_ID,
    LAST_UPDATE_LOGIN = FND_GLOBAL.Login_ID,
    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
    where PARTY_TAX_PROFILE_ID = P_PARTY_TAX_PROFILE_ID;
    if (sql%notfound) then
      --Set x_return_status param
      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
      arp_util_tax.debug('Error: "The Ptp row has not been updated for Party Id: ' || P_PARTY_ID || ' and Party Type: ' ||P_PARTY_TYPE_CODE || '."');
    end if;--end sql%notfound
  end if;--end X_RETURN_STATUS
end UPDATE_ROW;

procedure UPDATE_ROW (
  p_party_tax_profile_id         IN NUMBER,
  p_collecting_authority_flag    IN VARCHAR2,
  p_provider_type_code           IN VARCHAR2,
  p_create_awt_dists_type_code   IN VARCHAR2,
  p_create_awt_invoices_type_cod IN VARCHAR2,
  p_tax_classification_code      IN VARCHAR2,
  p_self_assess_flag             IN VARCHAR2,
  p_allow_offset_tax_flag        IN VARCHAR2,
  p_rep_registration_number      IN VARCHAR2,
  p_effective_from_use_le        IN DATE,
  p_record_type_code             IN VARCHAR2,
  p_request_id                   IN NUMBER,
  p_attribute1                   IN VARCHAR2,
  p_attribute2                   IN VARCHAR2,
  p_attribute3                   IN VARCHAR2,
  p_attribute4                   IN VARCHAR2,
  p_attribute5                   IN VARCHAR2,
  p_attribute6                   IN VARCHAR2,
  p_attribute7                   IN VARCHAR2,
  p_attribute8                   IN VARCHAR2,
  p_attribute9                   IN VARCHAR2,
  p_attribute10                  IN VARCHAR2,
  p_attribute11                  IN VARCHAR2,
  p_attribute12                  IN VARCHAR2,
  p_attribute13                  IN VARCHAR2,
  p_attribute14                  IN VARCHAR2,
  p_attribute15                  IN VARCHAR2,
  p_attribute_category           IN VARCHAR2,
  p_party_id                     IN NUMBER,
  p_program_login_id             IN NUMBER,
  p_party_type_code              IN VARCHAR2,
  p_supplier_flag                IN VARCHAR2,
  p_customer_flag                IN VARCHAR2,
  p_site_flag                    IN VARCHAR2,
  p_process_for_applicability_fl IN VARCHAR2,
  p_rounding_level_code          IN VARCHAR2,
  p_rounding_rule_code           IN VARCHAR2,
  p_withholding_start_date       IN DATE,
  p_inclusive_tax_flag           IN VARCHAR2,
  p_allow_awt_flag               IN VARCHAR2,
  p_use_le_as_subscriber_flag    IN VARCHAR2,
  p_legal_establishment_flag     IN VARCHAR2,
  p_first_party_le_flag          IN VARCHAR2,
  p_reporting_authority_flag     IN VARCHAR2,
  x_return_status               OUT NOCOPY VARCHAR2,
  p_registration_type_code       IN VARCHAR2,
  p_country_code                 IN VARCHAR2
) is
  L_EFFECTIVE_FROM_USE_LE  ZX_PARTY_TAX_PROFILE.EFFECTIVE_FROM_USE_LE%TYPE  := P_EFFECTIVE_FROM_USE_LE;
begin
  --Initialise x_return_status variable
  X_RETURN_STATUS :=  FND_API.G_RET_STS_SUCCESS;
  --Perform validations before inserting data
  --AllowOffsetTax and SetforSelfAssessment flag would be mutually exclusive
  IF P_SELF_ASSESS_FLAG = 'Y' AND P_ALLOW_OFFSET_TAX_FLAG = 'Y' THEN
    X_RETURN_STATUS :=  FND_API.G_RET_STS_ERROR;
    arp_util_tax.debug('Error: "Offset Tax and Set for Self Assessment can not both be "Y" at the same time." for Party Id: ' || P_PARTY_ID || ' and Party Type: ' ||P_PARTY_TYPE_CODE);
  END IF;
  --when UseLeAsSubscriberFlag is set to 'Y', then setEffectiveFromUseLe as System date
  IF P_USE_LE_AS_SUBSCRIBER_FLAG = 'Y' THEN
    L_EFFECTIVE_FROM_USE_LE := SYSDATE;
  ELSE
    L_EFFECTIVE_FROM_USE_LE := NULL;
  END IF;
  --Update only when there is no error
  IF X_RETURN_STATUS =  FND_API.G_RET_STS_SUCCESS THEN
    update ZX_PARTY_TAX_PROFILE set
    COLLECTING_AUTHORITY_FLAG = DECODE( P_COLLECTING_AUTHORITY_FLAG, NULL, COLLECTING_AUTHORITY_FLAG, P_COLLECTING_AUTHORITY_FLAG ),
    PROVIDER_TYPE_CODE = DECODE( P_PROVIDER_TYPE_CODE, NULL, PROVIDER_TYPE_CODE, P_PROVIDER_TYPE_CODE ),
    CREATE_AWT_DISTS_TYPE_CODE = DECODE( P_CREATE_AWT_DISTS_TYPE_CODE, NULL, CREATE_AWT_DISTS_TYPE_CODE, P_CREATE_AWT_DISTS_TYPE_CODE ),
    CREATE_AWT_INVOICES_TYPE_CODE = DECODE( P_CREATE_AWT_INVOICES_TYPE_COD, NULL, CREATE_AWT_INVOICES_TYPE_CODE, P_CREATE_AWT_INVOICES_TYPE_COD ),
    TAX_CLASSIFICATION_CODE = DECODE( P_TAX_CLASSIFICATION_CODE, NULL, TAX_CLASSIFICATION_CODE, P_TAX_CLASSIFICATION_CODE ),
    SELF_ASSESS_FLAG = DECODE( P_SELF_ASSESS_FLAG, NULL, SELF_ASSESS_FLAG, P_SELF_ASSESS_FLAG ),
    ALLOW_OFFSET_TAX_FLAG = DECODE( P_ALLOW_OFFSET_TAX_FLAG, NULL, ALLOW_OFFSET_TAX_FLAG, P_ALLOW_OFFSET_TAX_FLAG ),
    REP_REGISTRATION_NUMBER = DECODE( P_REP_REGISTRATION_NUMBER, NULL, REP_REGISTRATION_NUMBER,fnd_api.g_miss_char, NULL, P_REP_REGISTRATION_NUMBER ),
    EFFECTIVE_FROM_USE_LE = DECODE( L_EFFECTIVE_FROM_USE_LE, NULL, EFFECTIVE_FROM_USE_LE, L_EFFECTIVE_FROM_USE_LE ),
    RECORD_TYPE_CODE = DECODE( P_RECORD_TYPE_CODE, NULL, RECORD_TYPE_CODE, P_RECORD_TYPE_CODE ),
    REQUEST_ID = DECODE( P_REQUEST_ID, NULL, REQUEST_ID, P_REQUEST_ID ),
    ATTRIBUTE1 = DECODE( P_ATTRIBUTE1, NULL, ATTRIBUTE1, P_ATTRIBUTE1 ),
    ATTRIBUTE2 = DECODE( P_ATTRIBUTE2, NULL, ATTRIBUTE2, P_ATTRIBUTE2 ),
    ATTRIBUTE3 = DECODE( P_ATTRIBUTE3, NULL, ATTRIBUTE3, P_ATTRIBUTE3 ),
    ATTRIBUTE4 = DECODE( P_ATTRIBUTE4, NULL, ATTRIBUTE4, P_ATTRIBUTE4 ),
    ATTRIBUTE5 = DECODE( P_ATTRIBUTE5, NULL, ATTRIBUTE5, P_ATTRIBUTE5 ),
    ATTRIBUTE6 = DECODE( P_ATTRIBUTE6, NULL, ATTRIBUTE6, P_ATTRIBUTE6 ),
    ATTRIBUTE7 = DECODE( P_ATTRIBUTE7, NULL, ATTRIBUTE7, P_ATTRIBUTE7 ),
    ATTRIBUTE8 = DECODE( P_ATTRIBUTE8, NULL, ATTRIBUTE8, P_ATTRIBUTE8 ),
    ATTRIBUTE9 = DECODE( P_ATTRIBUTE9, NULL, ATTRIBUTE9, P_ATTRIBUTE9 ),
    ATTRIBUTE10 = DECODE( P_ATTRIBUTE10, NULL, ATTRIBUTE10, P_ATTRIBUTE10 ),
    ATTRIBUTE11 = DECODE( P_ATTRIBUTE11, NULL, ATTRIBUTE11, P_ATTRIBUTE11 ),
    ATTRIBUTE12 = DECODE( P_ATTRIBUTE12, NULL, ATTRIBUTE12, P_ATTRIBUTE12 ),
    ATTRIBUTE13 = DECODE( P_ATTRIBUTE13, NULL, ATTRIBUTE13, P_ATTRIBUTE13 ),
    ATTRIBUTE14 = DECODE( P_ATTRIBUTE14, NULL, ATTRIBUTE14, P_ATTRIBUTE14 ),
    ATTRIBUTE15 = DECODE( P_ATTRIBUTE15, NULL, ATTRIBUTE15, P_ATTRIBUTE15 ),
    ATTRIBUTE_CATEGORY = DECODE( P_ATTRIBUTE_CATEGORY, NULL, ATTRIBUTE_CATEGORY, P_ATTRIBUTE_CATEGORY ),
    PARTY_ID = DECODE( P_PARTY_ID, NULL, PARTY_ID, P_PARTY_ID ),
    PROGRAM_LOGIN_ID = DECODE( P_PROGRAM_LOGIN_ID, NULL, PROGRAM_LOGIN_ID, P_PROGRAM_LOGIN_ID ),
    PARTY_TYPE_CODE = DECODE( P_PARTY_TYPE_CODE, NULL, PARTY_TYPE_CODE, P_PARTY_TYPE_CODE),
    SUPPLIER_FLAG = DECODE( P_SUPPLIER_FLAG, NULL, SUPPLIER_FLAG, P_SUPPLIER_FLAG ),
    CUSTOMER_FLAG = DECODE( P_CUSTOMER_FLAG, NULL, CUSTOMER_FLAG, P_CUSTOMER_FLAG ),
    SITE_FLAG = DECODE( P_SITE_FLAG, NULL, SITE_FLAG, P_SITE_FLAG ),
    PROCESS_FOR_APPLICABILITY_FLAG = DECODE( P_PROCESS_FOR_APPLICABILITY_FL, NULL, PROCESS_FOR_APPLICABILITY_FLAG, P_PROCESS_FOR_APPLICABILITY_FL ),
    ROUNDING_LEVEL_CODE = DECODE( P_ROUNDING_LEVEL_CODE, NULL, ROUNDING_LEVEL_CODE, P_ROUNDING_LEVEL_CODE ),
    ROUNDING_RULE_CODE = DECODE( P_ROUNDING_RULE_CODE, NULL, ROUNDING_RULE_CODE, P_ROUNDING_RULE_CODE ),
    WITHHOLDING_START_DATE = DECODE( P_WITHHOLDING_START_DATE, NULL, WITHHOLDING_START_DATE, P_WITHHOLDING_START_DATE ),
    INCLUSIVE_TAX_FLAG = DECODE( P_INCLUSIVE_TAX_FLAG, NULL, INCLUSIVE_TAX_FLAG, P_INCLUSIVE_TAX_FLAG ),
    ALLOW_AWT_FLAG = DECODE( P_ALLOW_AWT_FLAG, NULL, ALLOW_AWT_FLAG, P_ALLOW_AWT_FLAG ),
    USE_LE_AS_SUBSCRIBER_FLAG = DECODE( P_USE_LE_AS_SUBSCRIBER_FLAG, NULL, USE_LE_AS_SUBSCRIBER_FLAG, P_USE_LE_AS_SUBSCRIBER_FLAG ),
    LEGAL_ESTABLISHMENT_FLAG = DECODE( P_LEGAL_ESTABLISHMENT_FLAG, NULL, LEGAL_ESTABLISHMENT_FLAG, P_LEGAL_ESTABLISHMENT_FLAG ),
    FIRST_PARTY_LE_FLAG = DECODE( P_FIRST_PARTY_LE_FLAG, NULL, FIRST_PARTY_LE_FLAG, P_FIRST_PARTY_LE_FLAG ),
    REPORTING_AUTHORITY_FLAG = DECODE( P_REPORTING_AUTHORITY_FLAG, NULL, REPORTING_AUTHORITY_FLAG, P_REPORTING_AUTHORITY_FLAG ),
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATED_BY = FND_GLOBAL.User_ID,
    LAST_UPDATE_LOGIN = FND_GLOBAL.Login_ID,
    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
    REGISTRATION_TYPE_CODE = DECODE (P_REGISTRATION_TYPE_CODE,NULL, REGISTRATION_TYPE_CODE, P_REGISTRATION_TYPE_CODE),
    COUNTRY_CODE = DECODE (P_COUNTRY_CODE,NULL, COUNTRY_CODE, P_COUNTRY_CODE)
    where PARTY_TAX_PROFILE_ID = P_PARTY_TAX_PROFILE_ID;
    if (sql%notfound) then
      --Set x_return_status param
      X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
      arp_util_tax.debug('Error: "The Ptp row has not been updated for Party Id: ' || P_PARTY_ID || ' and Party Type: ' ||P_PARTY_TYPE_CODE || '."');
    end if;--end sql%notfound
  end if;--end X_RETURN_STATUS
end UPDATE_ROW;

procedure DELETE_ROW (
  p_party_tax_profile_id  IN NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2
) is
begin
  --Initialise x_return_status variable
  X_RETURN_STATUS :=  FND_API.G_RET_STS_SUCCESS;
  --Delete the row
  delete from ZX_PARTY_TAX_PROFILE
  where PARTY_TAX_PROFILE_ID = P_PARTY_TAX_PROFILE_ID;

  if (sql%notfound) then
    --Set x_return_status param
    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
    raise no_data_found;
  end if;
end DELETE_ROW;

PROCEDURE sync_tax_reg_num (
   p_party_id        IN NUMBER
  ,p_tax_reg_num     IN VARCHAR2
  ,x_return_status  OUT NOCOPY VARCHAR2
  ,x_msg_count      OUT NOCOPY NUMBER
  ,x_msg_data       OUT NOCOPY VARCHAR2
  ) IS

  l_organization_rec  HZ_PARTY_V2PUB.organization_rec_type;
  l_party_ovn         NUMBER(15)   := NULL;
  l_dummy_number      NUMBER(15)   := NULL;
  l_dummy_char        HZ_PARTIES.party_type%TYPE;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := NULL;

  IF p_party_id IS NULL THEN
    RETURN;
  ELSE
    BEGIN

      SELECT party_type
      INTO l_dummy_char
      FROM hz_parties
      WHERE party_id = p_party_id;

      IF l_dummy_char <> 'ORGANIZATION' THEN
        -- no action reqd for suppliers
        RETURN;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN;
    END;
  END IF;

  hz_party_v2pub.get_organization_rec
    (p_init_msg_list => FND_API.G_TRUE
    ,p_party_id      => p_party_id
    ,x_organization_rec => l_organization_rec
    ,x_return_status    => x_return_status
    ,x_msg_count        => x_msg_count
    ,x_msg_data         => x_msg_data
    );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RETURN;
  END IF;

  IF NVL(l_organization_rec.tax_reference,FND_API.G_MISS_CHAR) <>
     NVL(p_tax_reg_num,FND_API.G_MISS_CHAR) THEN
    l_organization_rec.tax_reference := NVL(p_tax_reg_num,FND_API.G_MISS_CHAR);

    SELECT object_version_number
    INTO l_party_ovn
    FROM hz_parties
    WHERE party_id = p_party_id;

    hz_party_v2pub.update_organization
      (p_init_msg_list    => FND_API.G_TRUE
      ,p_organization_rec => l_organization_rec
      ,p_party_object_version_number => l_party_ovn
      ,x_profile_id       => l_dummy_number
      ,x_return_status    => x_return_status
      ,x_msg_count        => x_msg_count
      ,x_msg_data         => x_msg_data
      );
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := 1;
      x_msg_data := SQLERRM;

END sync_tax_reg_num;

END ZX_PARTY_TAX_PROFILE_PKG;

/
