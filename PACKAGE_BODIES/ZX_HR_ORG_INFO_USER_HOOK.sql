--------------------------------------------------------
--  DDL for Package Body ZX_HR_ORG_INFO_USER_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_HR_ORG_INFO_USER_HOOK" AS
/*  $Header: zxhrptpsyncb.pls 120.0 2005/09/02 01:23:58 ykonishi noship $*/
PROCEDURE create_party_tax_profile
(p_organization_id  IN NUMBER,
 p_org_classif_code IN VARCHAR2
) IS

l_return_status   VARCHAR2(1);

BEGIN
IF p_org_classif_code = 'OPERATING_UNIT' THEN
zx_party_tax_profile_pkg.insert_row
(
P_COLLECTING_AUTHORITY_FLAG    => NULL,
P_PROVIDER_TYPE_CODE           => NULL,
P_CREATE_AWT_DISTS_TYPE_CODE   => NULL,
P_CREATE_AWT_INVOICES_TYPE_COD => NULL,
P_TAX_CLASSIFICATION_CODE      => NULL,
P_SELF_ASSESS_FLAG             => NULL,
P_ALLOW_OFFSET_TAX_FLAG        => NULL,
P_REP_REGISTRATION_NUMBER      => NULL,
P_EFFECTIVE_FROM_USE_LE        => NULL,
P_RECORD_TYPE_CODE             => NULL,
P_REQUEST_ID                   => fnd_global.conc_request_id,
P_ATTRIBUTE1                   => NULL,
P_ATTRIBUTE2                   => NULL,
P_ATTRIBUTE3                   => NULL,
P_ATTRIBUTE4                   => NULL,
P_ATTRIBUTE5                   => NULL,
P_ATTRIBUTE6                   => NULL,
P_ATTRIBUTE7                   => NULL,
P_ATTRIBUTE8                   => NULL,
P_ATTRIBUTE9                   => NULL,
P_ATTRIBUTE10                  => NULL,
P_ATTRIBUTE11                  => NULL,
P_ATTRIBUTE12                  => NULL,
P_ATTRIBUTE13                  => NULL,
P_ATTRIBUTE14                  => NULL,
P_ATTRIBUTE15                  => NULL,
P_ATTRIBUTE_CATEGORY           => NULL,
P_PARTY_ID                     => p_organization_id,
P_PROGRAM_LOGIN_ID             => fnd_global.conc_login_id,
P_PARTY_TYPE_CODE              => 'OU',
P_SUPPLIER_FLAG                => 'N',
P_CUSTOMER_FLAG                => 'N',
P_SITE_FLAG                    => 'N',
P_PROCESS_FOR_APPLICABILITY_FL => 'N',
P_ROUNDING_LEVEL_CODE          => NULL,
P_ROUNDING_RULE_CODE           => NULL,
P_WITHHOLDING_START_DATE       => NULL,
P_INCLUSIVE_TAX_FLAG           => NULL,
P_ALLOW_AWT_FLAG               => 'N',
P_USE_LE_AS_SUBSCRIBER_FLAG    => 'N',
P_LEGAL_ESTABLISHMENT_FLAG     => NULL,
P_FIRST_PARTY_LE_FLAG          => NULL,
P_REPORTING_AUTHORITY_FLAG     => NULL,
X_RETURN_STATUS                => l_return_status
);
END IF;

END create_party_tax_profile;

END zx_hr_org_info_user_hook;

/
