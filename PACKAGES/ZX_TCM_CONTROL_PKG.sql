--------------------------------------------------------
--  DDL for Package ZX_TCM_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TCM_CONTROL_PKG" AUTHID CURRENT_USER AS
/* $Header: zxccontrols.pls 120.30 2006/08/11 17:37:05 nipatel ship $ */

TYPE zx_fiscal_class_info_rec IS RECORD(
	classification_category        zx_fc_types_b.Classification_Type_Categ_Code%type,
	classification_type            zx_fc_types_b.classification_type_code%type,
        condition_value                zx_conditions.alphanumeric_value%type,
        event_class_code               zx_lines_det_factors.trx_business_category%TYPE, -- event_class_code here used as trx_business_category, hence hold the same type
        tax_determine_date             date,
	tax_regime_code                zx_regimes_b.tax_regime_code%TYPE,
	classified_entity_id           number,
        application_id                 number,
	item_org_id                    number,
        effective_from                 date,
	effective_to                   date,
	fsc_code                       zx_conditions.alphanumeric_value%type);

TYPE zx_fsc_class_info_cache IS TABLE OF zx_fiscal_class_info_rec
   INDEX BY BINARY_INTEGER;

TYPE zx_category_code_info_rec IS RECORD(
	classification_category        zx_fc_types_b.Classification_Type_Categ_Code%type,
	classification_type            zx_fc_types_b.classification_type_code%type,
        parameter_value                zx_conditions.alphanumeric_value%type,
        condition_subclass             fnd_lookups.lookup_code%type,
        condition_value                zx_conditions.alphanumeric_value%type,
        tax_determine_date             date,
        effective_from                 date,
	effective_to                   date);

TYPE zx_registration_info_rec IS RECORD(
 -- The dummy flag has been added to avoid hitting the database again for the same combination
 -- of PARTY_TAX_PROFILE_ID, TAX_REGIME_CODE, TAX, JURISDICTION_CODE if a value is not found in the
 -- cache. This is important because we always try to search for true registrations first,
 -- but during migration,we do not have information to create true registrations. Hence during
 -- calculationwe do not find any registration record in the database and cache and we keep on
 -- searching the databse for a registration record for every tax line only to find that a
 -- record does not exist in the database.
        dummy_flag                  VARCHAR2(1),
        registration_id                zx_registrations.registration_id%type,
        registration_type_code         zx_registrations.registration_type_code%type,
        registration_number            zx_registrations.registration_number%type,
        validation_rule                zx_registrations.validation_rule%type,
        tax_authority_id               zx_registrations.tax_authority_id%type,
        rep_tax_authority_id           zx_registrations.rep_tax_authority_id%type,
        coll_Tax_authority_id          zx_registrations.coll_tax_authority_id%type,
        rounding_rule_code             zx_registrations.rounding_rule_code%type,
        tax_jurisdiction_code          zx_registrations.tax_jurisdiction_code%type,
        self_assess_flag               zx_registrations.self_assess_flag%type,
        registration_status_code       zx_registrations.registration_status_code%type,
        registration_source_code       zx_registrations.registration_source_code%type,
        registration_reason_code       zx_registrations.registration_reason_code%type,
        party_tax_profile_id           zx_registrations.party_tax_profile_id%type,
        tax                            zx_registrations.tax%type,
        tax_regime_code                zx_registrations.tax_regime_code%type,
        inclusive_tax_flag             zx_registrations.inclusive_tax_flag%type,
--        has_tax_exemptions_flag        zx_registrations.has_tax_exemptions_flag%type,
        effective_from                 date,
        effective_to                   date,
        rep_party_tax_name             zx_registrations.rep_party_tax_name%type,
        legal_registration_id          zx_registrations.legal_registration_id%type,
        default_registration_flag      zx_registrations.default_registration_flag%type,
        bank_id                        zx_registrations.bank_id%type,
        bank_branch_id                 zx_registrations.bank_branch_id%type,
        bank_account_num               zx_registrations.bank_account_num%type,
        legal_location_id              zx_registrations.legal_location_id%type,
        record_type_code               zx_registrations.record_type_code%type,
        request_id                     zx_registrations.request_id%type,
        program_application_id         zx_registrations.program_application_id%type,
        program_id                     zx_registrations.program_id%type,
        program_login_id               zx_registrations.program_login_id%type,
        account_id                     zx_registrations.account_id%type,
        ACCOUNT_SITE_ID                zx_registrations.ACCOUNT_SITE_ID%type,
--        site_use_id                    HZ_CUST_SITE_USES_ALL.site_use_id%type,
        geo_type_classification_code   HZ_CUST_SITE_USES_ALL.tax_classification%TYPE,
        tax_classification_code        zx_registrations.tax_classification_code%type,
        attribute1                     zx_registrations.attribute1%type,
        attribute2                     zx_registrations.attribute2%type,
        attribute3                     zx_registrations.attribute3%type,
        attribute4                     zx_registrations.attribute4%type,
        attribute5                     zx_registrations.attribute5%type,
        attribute6                     zx_registrations.attribute6%type,
        attribute7                     zx_registrations.attribute7%type,
        attribute8                     zx_registrations.attribute8%type,
        attribute9                     zx_registrations.attribute9%type,
        attribute10                    zx_registrations.attribute10%type,
        attribute11                    zx_registrations.attribute11%type,
        attribute12                    zx_registrations.attribute12%type,
        attribute13                    zx_registrations.attribute13%type,
        attribute14                    zx_registrations.attribute14%type,
        attribute15                    zx_registrations.attribute15%type,
        attribute_category             zx_registrations.attribute_category%type,
        party_type_code                zx_party_tax_profile.party_type_code%type,
        supplier_flag                  zx_party_tax_profile.supplier_flag%type,
        customer_flag                  zx_party_tax_profile.customer_flag%type,
        site_flag                      zx_party_tax_profile.site_flag%type,
        process_for_applicability_flag zx_party_tax_profile.process_for_applicability_flag%type,
        rounding_level_code            zx_party_tax_profile.rounding_level_code%type,
        withholding_start_date         zx_party_tax_profile.withholding_start_date%type,
        allow_awt_flag                 zx_party_tax_profile.allow_awt_flag%type,
        use_le_as_subscriber_flag      zx_party_tax_profile.use_le_as_subscriber_flag%type,
        legal_establishment_flag       zx_party_tax_profile.legal_establishment_flag%type,
        first_party_le_flag            zx_party_tax_profile.first_party_le_flag%type,
        reporting_authority_flag       zx_party_tax_profile.reporting_authority_flag%type,
        collecting_authority_flag      zx_party_tax_profile.collecting_authority_flag%type,
        provider_type_code             zx_party_tax_profile.provider_type_code%type,
        create_awt_dists_type_code     zx_party_tax_profile.create_awt_dists_type_code%type,
        create_awt_invoices_type_code  zx_party_tax_profile.create_awt_invoices_type_code%type,
        allow_offset_tax_flag          zx_party_tax_profile.allow_offset_tax_flag%type,
        effective_from_use_le          zx_party_tax_profile.effective_from_use_le%type,
        party_id                       zx_party_tax_profile.party_id%type,
        rep_registration_number        zx_party_tax_profile.rep_registration_number%type);

PROCEDURE GET_FISCAL_CLASSIFICATION(
            p_fsc_rec           IN OUT NOCOPY ZX_TCM_CONTROL_PKG.ZX_FISCAL_CLASS_INFO_REC,
            p_return_status     OUT NOCOPY VARCHAR2);

PROCEDURE GET_PROD_TRX_CATE_VALUE (
             p_fsc_cat_rec      IN  OUT NOCOPY ZX_TCM_CONTROL_PKG.ZX_CATEGORY_CODE_INFO_REC,
             p_return_status    OUT NOCOPY VARCHAR2);

PROCEDURE GET_TAX_REGISTRATION(
            p_parent_ptp_id          IN  zx_party_tax_profile.party_tax_profile_id%TYPE,
            p_site_ptp_id            IN  zx_party_tax_profile.party_tax_profile_id%TYPE,
            p_account_type_code      IN  zx_registrations.account_type_code%TYPE,
            p_tax_determine_date     IN  ZX_LINES.TAX_DETERMINE_DATE%TYPE,
            p_tax                    IN  ZX_TAXES_B.TAX%TYPE,
            p_tax_regime_code        IN  ZX_REGIMES_B.TAX_REGIME_CODE%TYPE,
            p_jurisdiction_code      IN  ZX_JURISDICTIONS_B.TAX_JURISDICTION_CODE%TYPE,
            p_account_id             IN  ZX_REGISTRATIONS.ACCOUNT_ID%TYPE,
            p_account_site_id        IN  ZX_REGISTRATIONS.ACCOUNT_SITE_ID%TYPE,
            p_site_use_id            IN  HZ_CUST_SITE_USES_ALL.SITE_USE_ID%TYPE,
            p_zx_registration_rec    OUT NOCOPY ZX_TCM_CONTROL_PKG.ZX_REGISTRATION_INFO_REC,
            p_ret_record_level       OUT NOCOPY VARCHAR2,
            p_return_status          OUT NOCOPY VARCHAR2);

PROCEDURE INITIALIZE_LTE (p_return_status    OUT NOCOPY VARCHAR2);

END ZX_TCM_CONTROL_PKG;

 

/
