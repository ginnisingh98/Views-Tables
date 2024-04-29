--------------------------------------------------------
--  DDL for Package Body POS_SUPPLIER_TAX_PROF_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SUPPLIER_TAX_PROF_BO_PKG" AS
    /* $Header: POSSPTXPB.pls 120.0.12010000.1 2010/02/02 07:02:57 ntungare noship $ */
    /*#
    * Use this routine to get tax profile BO
    * @param p_api_version The api version
    * @param p_init_msg_list The Initialization message list
    * @param p_party_id The party_id
    * @param p_orig_system The Orig System
    * @param p_orig_system_reference The Orig System Reference
    * @param x_zx_party_tax_profile_bo_tbl The tax profile bo
    * @param x_return_status The return status
    * @param x_msg_count The message count
    * @param x_msg_data The message data
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Get Supplier Tax Profile
    * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
    */
    PROCEDURE get_pos_sup_tax_prof_bo_tbl(p_api_version                 IN NUMBER DEFAULT NULL,
                                          p_init_msg_list               IN VARCHAR2 DEFAULT NULL,
                                          p_party_id                    IN NUMBER,
                                          p_orig_system                 IN VARCHAR2,
                                          p_orig_system_reference       IN VARCHAR2,
                                          x_zx_party_tax_profile_bo_tbl OUT NOCOPY pos_tax_profile_bo_tbl,
                                          x_return_status               OUT NOCOPY VARCHAR2,
                                          x_msg_count                   OUT NOCOPY NUMBER,
                                          x_msg_data                    OUT NOCOPY VARCHAR2) IS

        l_ap_supplier_tax_prof_bo_tbl pos_tax_profile_bo_tbl := pos_tax_profile_bo_tbl();
        l_party_id                    NUMBER;

    BEGIN

        IF p_party_id IS NULL OR p_party_id = 0 THEN
            l_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_orig_system,
                                                           p_orig_system_reference);
        ELSE
            l_party_id := p_party_id;
        END IF;

        SELECT pos_tax_profile_bo(party_type_code,
                                  supplier_flag,
                                  customer_flag,
                                  site_flag,
                                  process_for_applicability_flag,
                                  rounding_level_code,
                                  rounding_rule_code,
                                  withholding_start_date,
                                  inclusive_tax_flag,
                                  allow_awt_flag,
                                  use_le_as_subscriber_flag,
                                  legal_establishment_flag,
                                  first_party_le_flag,
                                  reporting_authority_flag,
                                  collecting_authority_flag,
                                  provider_type_code,
                                  create_awt_dists_type_code,
                                  create_awt_invoices_type_code,
                                  tax_classification_code,
                                  self_assess_flag,
                                  allow_offset_tax_flag,
                                  effective_from_use_le,
                                  record_type_code,
                                  created_by,
                                  creation_date,
                                  last_updated_by,
                                  last_update_date,
                                  last_update_login,
                                  request_id,
                                  program_application_id,
                                  program_id,
                                  attribute1,
                                  attribute2,
                                  attribute3,
                                  attribute4,
                                  attribute5,
                                  attribute6,
                                  attribute7,
                                  attribute8,
                                  attribute9,
                                  attribute10,
                                  attribute11,
                                  attribute12,
                                  attribute13,
                                  attribute14,
                                  attribute15,
                                  attribute_category,
                                  program_login_id,
                                  party_tax_profile_id,
                                  party_id,
                                  rep_registration_number,
                                  object_version_number,
                                  registration_type_code,
                                  country_code,
                                  merged_to_ptp_id,
                                  merged_status_code) BULK COLLECT
        INTO   l_ap_supplier_tax_prof_bo_tbl
        FROM   zx_party_tax_profile
        WHERE  party_id = l_party_id;

        x_zx_party_tax_profile_bo_tbl := l_ap_supplier_tax_prof_bo_tbl;
    EXCEPTION
        WHEN fnd_api.g_exc_error THEN

            x_return_status := fnd_api.g_ret_sts_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
        WHEN fnd_api.g_exc_unexpected_error THEN

            x_return_status := fnd_api.g_ret_sts_unexp_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
        WHEN OTHERS THEN

            x_return_status := fnd_api.g_ret_sts_unexp_error;

            x_msg_count := 1;
            x_msg_data  := SQLCODE || SQLERRM;
    END get_pos_sup_tax_prof_bo_tbl;
-----------------------------------------------------
    PROCEDURE validate_tax_profile(p_party_id               IN NUMBER,
                                   p_rounding_level_code    IN VARCHAR2,
                                   p_rounding_rule_code     IN VARCHAR2,
                                   p_registration_type_code IN VARCHAR2,
                                   p_country_code           IN VARCHAR2,
                                   x_return_status          OUT NOCOPY VARCHAR2,
                                   x_msg_count              OUT NOCOPY NUMBER,
                                   x_msg_data               OUT NOCOPY VARCHAR2,
                                   x_tax_prof_valid         OUT NOCOPY VARCHAR2,
                                   x_party_tax_profile_id   OUT NOCOPY NUMBER,
                                   x_country_code           OUT NOCOPY VARCHAR2) IS
        l_dummy_lookup VARCHAR2(30);
        l_request_id   NUMBER := fnd_global.conc_request_id;

        l_msg_count NUMBER;
        l_msg_data  VARCHAR2(2000);
        l_api_name CONSTANT VARCHAR2(50) := 'VALIDATE_VENDOR_PRODS_SERVICES';
    BEGIN
        --  Initialize API return status to success
        x_return_status := fnd_api.g_ret_sts_success;
        x_tax_prof_valid := 'Y';

        -- Check if the Tax Profile Id exists
        BEGIN
            SELECT party_tax_profile_id
            INTO   x_party_tax_profile_id
            FROM   zx_party_tax_profile
            WHERE  party_id = p_party_id
            AND    party_type_code = 'THIRD_PARTY';

            RETURN;

        EXCEPTION
            WHEN no_data_found THEN
                NULL;
        END;

        -- Validate the rounding Level using the following query
        IF (p_rounding_level_code IS NOT NULL) THEN
            BEGIN
                SELECT fndlookup.lookup_code
                INTO   l_dummy_lookup
                FROM   fnd_lookups fndlookup
                WHERE  fndlookup.lookup_type LIKE 'ZX_ROUNDING_LEVEL'
                AND    nvl(fndlookup.start_date_active, SYSDATE) <= SYSDATE
                AND    nvl(fndlookup.end_date_active, SYSDATE) >= SYSDATE
                AND    nvl(fndlookup.enabled_flag, 'N') = 'Y'
                AND    lookup_code = p_rounding_level_code
                ORDER  BY fndlookup.lookup_code;

            EXCEPTION
                WHEN OTHERS THEN
                    x_tax_prof_valid := 'N';
                    x_return_status  := fnd_api.g_ret_sts_error;
                    x_msg_data       := 'AP_INVALID_ROUNDING_LEVEL';

            END;
        END IF;

        IF (p_rounding_rule_code IS NOT NULL) THEN
            -- Validate the rounding Rule using the following query
            BEGIN
                SELECT fndlookup.lookup_code
                INTO   l_dummy_lookup
                FROM   fnd_lookups fndlookup
                WHERE  fndlookup.lookup_type LIKE 'ZX_ROUNDING_RULE'
                AND    nvl(fndlookup.start_date_active, SYSDATE) <= SYSDATE
                AND    nvl(fndlookup.end_date_active, SYSDATE) >= SYSDATE
                AND    nvl(fndlookup.enabled_flag, 'N') = 'Y'
                AND    lookup_code = p_rounding_rule_code
                ORDER  BY fndlookup.lookup_code;

            EXCEPTION
                WHEN OTHERS THEN
                    x_tax_prof_valid := 'N';
                    x_return_status  := fnd_api.g_ret_sts_error;
                    x_msg_data       := 'AP_INVALID_ROUNDING_RULE';

            END;
        END IF;

        IF (p_country_code IS NOT NULL) THEN
            -- Validate the Country Name using the following query
            BEGIN
                SELECT territory_short_name
                INTO   x_country_code
                FROM   fnd_territories_vl
                WHERE  territory_code = p_country_code;

                -- Update the Interface table with the country code obtained in the prev SQL since the country code would be saved.
            EXCEPTION
                WHEN OTHERS THEN
                    x_tax_prof_valid := 'N';
                    x_return_status  := fnd_api.g_ret_sts_error;
                    x_msg_data       := 'AP_INVALID_COUNTRY_NAME';

            END;
        END IF;

        IF (p_registration_type_code IS NOT NULL) THEN
            -- Validate the Registration Type Code using the following query
            BEGIN
                SELECT fndlookup.lookup_code
                INTO   l_dummy_lookup
                FROM   fnd_lookups fndlookup
                WHERE  fndlookup.lookup_type LIKE 'ZX_REGISTRATIONS_TYPE'
                AND    nvl(fndlookup.start_date_active, SYSDATE) <= SYSDATE
                AND    nvl(fndlookup.end_date_active, SYSDATE) >= SYSDATE
                AND    nvl(fndlookup.enabled_flag, 'N') = 'Y'
                AND    lookup_code = p_registration_type_code
                ORDER  BY fndlookup.lookup_code;

            EXCEPTION
                WHEN OTHERS THEN
                    x_tax_prof_valid := 'N';
                    x_return_status  := fnd_api.g_ret_sts_error;
                    x_msg_data       := 'AP_INVALID_REGISTRATION_TYPE_CODE';

            END;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_tax_prof_valid := 'N';
            x_return_status  := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END validate_tax_profile;

    /*#
    * Use this routine to create tax profile BO
    * @param p_api_version The api version
    * @param p_init_msg_list The Initialization message list
    * @param x_zx_party_tax_profile_bo_tbl The tax profile bo
    * @param p_party_id The party_id
    * @param p_orig_system The Orig System
    * @param p_orig_system_reference The Orig System Reference
    * @param x_return_status The return status
    * @param x_msg_count The message count
    * @param x_msg_data The message data
    * @param x_tax_profile_id The newly created tax profile id
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Create Supplier Tax Profile
    * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
    */
    PROCEDURE create_supp_tax_profile(p_api_version             IN NUMBER DEFAULT NULL,
                                      p_init_msg_list           IN VARCHAR2 DEFAULT NULL,
                                      x_zx_party_tax_profile_bo_tbl IN pos_tax_profile_bo_tbl,
                                      p_party_id                IN NUMBER,
                                      p_orig_system             IN VARCHAR2,
                                      p_orig_system_reference   IN VARCHAR2,
                                      p_create_update_flag      IN VARCHAR2,
                                      x_return_status           OUT NOCOPY VARCHAR2,
                                      x_msg_count               OUT NOCOPY NUMBER,
                                      x_msg_data                OUT NOCOPY VARCHAR2,
                                      x_tax_profile_id          OUT NOCOPY NUMBER) IS
        l_tax_prof_valid       VARCHAR2(10);
        l_party_tax_profile_id NUMBER;
        l_country_code         VARCHAR2(40);
        l_return_status        VARCHAR2(100);
        l_msg_count            NUMBER;
        l_msg_data             VARCHAR2(4000);
        l_party_id             NUMBER;
    BEGIN
        x_return_status := fnd_api.g_ret_sts_success;

        IF p_party_id IS NULL OR p_party_id = 0 THEN
            l_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_orig_system,
                                                           p_orig_system_reference);
        ELSE
            l_party_id := p_party_id;
        END IF;
FOR i IN x_zx_party_tax_profile_bo_tbl.first .. x_zx_party_tax_profile_bo_tbl.last LOOP
        -- Call Validate_Tax_profile to validate the Tax Profiledata
        validate_tax_profile(p_party_id               => l_party_id,
                             p_rounding_level_code    => x_zx_party_tax_profile_bo_tbl(i).rounding_level_code,
                             p_rounding_rule_code     => x_zx_party_tax_profile_bo_tbl(i).rounding_rule_code,
                             p_registration_type_code => x_zx_party_tax_profile_bo_tbl(i).registration_type_code,
                             p_country_code           => x_zx_party_tax_profile_bo_tbl(i).country_code,
                             x_return_status          => l_return_status,
                             x_msg_count              => l_msg_count,
                             x_msg_data               => l_msg_data,
                             x_tax_prof_valid         => l_tax_prof_valid,
                             x_party_tax_profile_id   => l_party_tax_profile_id,
                             x_country_code           => l_country_code);

        IF p_create_update_flag = 'C' THEN
            IF (l_tax_prof_valid = 'Y') THEN

                -- Insert
                zx_party_tax_profile_pkg.insert_row(p_allow_awt_flag               => x_zx_party_tax_profile_bo_tbl(i).allow_awt_flag,
                                                    p_allow_offset_tax_flag        => x_zx_party_tax_profile_bo_tbl(i).allow_offset_tax_flag,
                                                    p_attribute_category           => x_zx_party_tax_profile_bo_tbl(i).attribute_category,
                                                    p_attribute1                   => x_zx_party_tax_profile_bo_tbl(i).attribute1,
                                                    p_attribute10                  => x_zx_party_tax_profile_bo_tbl(i).attribute10,
                                                    p_attribute11                  => x_zx_party_tax_profile_bo_tbl(i).attribute11,
                                                    p_attribute12                  => x_zx_party_tax_profile_bo_tbl(i).attribute12,
                                                    p_attribute13                  => x_zx_party_tax_profile_bo_tbl(i).attribute13,
                                                    p_attribute14                  => x_zx_party_tax_profile_bo_tbl(i).attribute14,
                                                    p_attribute15                  => x_zx_party_tax_profile_bo_tbl(i).attribute15,
                                                    p_attribute2                   => x_zx_party_tax_profile_bo_tbl(i).attribute2,
                                                    p_attribute3                   => x_zx_party_tax_profile_bo_tbl(i).attribute3,
                                                    p_attribute4                   => x_zx_party_tax_profile_bo_tbl(i).attribute4,
                                                    p_attribute5                   => x_zx_party_tax_profile_bo_tbl(i).attribute5,
                                                    p_attribute6                   => x_zx_party_tax_profile_bo_tbl(i).attribute6,
                                                    p_attribute7                   => x_zx_party_tax_profile_bo_tbl(i).attribute7,
                                                    p_attribute8                   => x_zx_party_tax_profile_bo_tbl(i).attribute8,
                                                    p_attribute9                   => x_zx_party_tax_profile_bo_tbl(i).attribute9,
                                                    p_collecting_authority_flag    => x_zx_party_tax_profile_bo_tbl(i).collecting_authority_flag,
                                                    p_country_code                 => x_zx_party_tax_profile_bo_tbl(i).country_code,
                                                    p_create_awt_dists_type_code   => x_zx_party_tax_profile_bo_tbl(i).create_awt_dists_type_code,
                                                    p_create_awt_invoices_type_cod => x_zx_party_tax_profile_bo_tbl(i).create_awt_invoices_type_code,
                                                    p_customer_flag                => x_zx_party_tax_profile_bo_tbl(i).customer_flag,
                                                    p_effective_from_use_le        => x_zx_party_tax_profile_bo_tbl(i).effective_from_use_le,
                                                    p_first_party_le_flag          => x_zx_party_tax_profile_bo_tbl(i).first_party_le_flag,
                                                    p_inclusive_tax_flag           => x_zx_party_tax_profile_bo_tbl(i).inclusive_tax_flag,
                                                    p_legal_establishment_flag     => x_zx_party_tax_profile_bo_tbl(i).legal_establishment_flag,
                                                    p_party_id                     => x_zx_party_tax_profile_bo_tbl(i).party_id,
                                                    p_party_type_code              => x_zx_party_tax_profile_bo_tbl(i).party_type_code,
                                                    p_process_for_applicability_fl => x_zx_party_tax_profile_bo_tbl(i).process_for_applicability_flag,
                                                    p_program_login_id             => x_zx_party_tax_profile_bo_tbl(i).program_application_id,
                                                    p_provider_type_code           => x_zx_party_tax_profile_bo_tbl(i).provider_type_code,
                                                    p_record_type_code             => x_zx_party_tax_profile_bo_tbl(i).record_type_code,
                                                    p_registration_type_code       => x_zx_party_tax_profile_bo_tbl(i).registration_type_code,
                                                    p_rep_registration_number      => x_zx_party_tax_profile_bo_tbl(i).rep_registration_number,
                                                    p_reporting_authority_flag     => x_zx_party_tax_profile_bo_tbl(i).reporting_authority_flag,
                                                    p_request_id                   => x_zx_party_tax_profile_bo_tbl(i).request_id,
                                                    p_rounding_level_code          => x_zx_party_tax_profile_bo_tbl(i).rounding_level_code,
                                                    p_rounding_rule_code           => x_zx_party_tax_profile_bo_tbl(i).rounding_rule_code,
                                                    p_self_assess_flag             => x_zx_party_tax_profile_bo_tbl(i).self_assess_flag,
                                                    p_site_flag                    => x_zx_party_tax_profile_bo_tbl(i).site_flag,
                                                    p_supplier_flag                => x_zx_party_tax_profile_bo_tbl(i).supplier_flag,
                                                    p_tax_classification_code      => x_zx_party_tax_profile_bo_tbl(i).tax_classification_code,
                                                    p_use_le_as_subscriber_flag    => x_zx_party_tax_profile_bo_tbl(i).use_le_as_subscriber_flag,
                                                    p_withholding_start_date       => x_zx_party_tax_profile_bo_tbl(i).withholding_start_date,
                                                    x_return_status                => l_return_status);

                -- The ZX API doesn't return the Tax Profile Id that has been created
                -- So re-querying the Tax profile Id using the party Id and the party Type
                --
                IF (l_return_status = 'S') THEN
                    SELECT party_tax_profile_id
                    INTO   l_party_tax_profile_id
                    FROM   zx_party_tax_profile
                    WHERE  party_id = l_party_id
                    AND    party_type_code = 'THIRD_PARTY';

                    x_tax_profile_id := l_party_tax_profile_id;
                 else
                    x_return_status := l_return_status;
                x_msg_data      := l_msg_data;
                x_msg_count     := l_msg_count;
                END IF;

            ELSE
                x_return_status := l_return_status;
                x_msg_data      := l_msg_data;
                x_msg_count     := l_msg_count;
            END IF;

        ELSIF p_create_update_flag = 'U' THEN
            IF (l_tax_prof_valid = 'Y') THEN

                zx_party_tax_profile_pkg.update_row(p_allow_awt_flag               => x_zx_party_tax_profile_bo_tbl(i).allow_awt_flag,
                                                    p_allow_offset_tax_flag        => x_zx_party_tax_profile_bo_tbl(i).allow_offset_tax_flag,
                                                    p_attribute_category           => x_zx_party_tax_profile_bo_tbl(i).attribute_category,
                                                    p_attribute1                   => x_zx_party_tax_profile_bo_tbl(i).attribute1,
                                                    p_attribute10                  => x_zx_party_tax_profile_bo_tbl(i).attribute10,
                                                    p_attribute11                  => x_zx_party_tax_profile_bo_tbl(i).attribute11,
                                                    p_attribute12                  => x_zx_party_tax_profile_bo_tbl(i).attribute12,
                                                    p_attribute13                  => x_zx_party_tax_profile_bo_tbl(i).attribute13,
                                                    p_attribute14                  => x_zx_party_tax_profile_bo_tbl(i).attribute14,
                                                    p_attribute15                  => x_zx_party_tax_profile_bo_tbl(i).attribute15,
                                                    p_attribute2                   => x_zx_party_tax_profile_bo_tbl(i).attribute2,
                                                    p_attribute3                   => x_zx_party_tax_profile_bo_tbl(i).attribute3,
                                                    p_attribute4                   => x_zx_party_tax_profile_bo_tbl(i).attribute4,
                                                    p_attribute5                   => x_zx_party_tax_profile_bo_tbl(i).attribute5,
                                                    p_attribute6                   => x_zx_party_tax_profile_bo_tbl(i).attribute6,
                                                    p_attribute7                   => x_zx_party_tax_profile_bo_tbl(i).attribute7,
                                                    p_attribute8                   => x_zx_party_tax_profile_bo_tbl(i).attribute8,
                                                    p_attribute9                   => x_zx_party_tax_profile_bo_tbl(i).attribute9,
                                                    p_collecting_authority_flag    => x_zx_party_tax_profile_bo_tbl(i).collecting_authority_flag,
                                                    p_country_code                 => x_zx_party_tax_profile_bo_tbl(i).country_code,
                                                    p_create_awt_dists_type_code   => x_zx_party_tax_profile_bo_tbl(i).create_awt_dists_type_code,
                                                    p_create_awt_invoices_type_cod => x_zx_party_tax_profile_bo_tbl(i).create_awt_invoices_type_code,
                                                    p_customer_flag                => x_zx_party_tax_profile_bo_tbl(i).customer_flag,
                                                    p_effective_from_use_le        => x_zx_party_tax_profile_bo_tbl(i).effective_from_use_le,
                                                    p_first_party_le_flag          => x_zx_party_tax_profile_bo_tbl(i).first_party_le_flag,
                                                    p_inclusive_tax_flag           => x_zx_party_tax_profile_bo_tbl(i).inclusive_tax_flag,
                                                    p_legal_establishment_flag     => x_zx_party_tax_profile_bo_tbl(i).legal_establishment_flag,
                                                    p_party_id                     => x_zx_party_tax_profile_bo_tbl(i).party_id,
                                                    p_party_type_code              => x_zx_party_tax_profile_bo_tbl(i).party_type_code,
                                                    p_process_for_applicability_fl => x_zx_party_tax_profile_bo_tbl(i).process_for_applicability_flag,
                                                    p_program_login_id             => x_zx_party_tax_profile_bo_tbl(i).program_application_id,
                                                    p_provider_type_code           => x_zx_party_tax_profile_bo_tbl(i).provider_type_code,
                                                    p_record_type_code             => x_zx_party_tax_profile_bo_tbl(i).record_type_code,
                                                    p_registration_type_code       => x_zx_party_tax_profile_bo_tbl(i).registration_type_code,
                                                    p_rep_registration_number      => x_zx_party_tax_profile_bo_tbl(i).rep_registration_number,
                                                    p_reporting_authority_flag     => x_zx_party_tax_profile_bo_tbl(i).reporting_authority_flag,
                                                    p_request_id                   => x_zx_party_tax_profile_bo_tbl(i).request_id,
                                                    p_rounding_level_code          => x_zx_party_tax_profile_bo_tbl(i).rounding_level_code,
                                                    p_rounding_rule_code           => x_zx_party_tax_profile_bo_tbl(i).rounding_rule_code,
                                                    p_self_assess_flag             => x_zx_party_tax_profile_bo_tbl(i).self_assess_flag,
                                                    p_site_flag                    => x_zx_party_tax_profile_bo_tbl(i).site_flag,
                                                    p_supplier_flag                => x_zx_party_tax_profile_bo_tbl(i).supplier_flag,
                                                    p_tax_classification_code      => x_zx_party_tax_profile_bo_tbl(i).tax_classification_code,
                                                    p_use_le_as_subscriber_flag    => x_zx_party_tax_profile_bo_tbl(i).use_le_as_subscriber_flag,
                                                    p_withholding_start_date       => x_zx_party_tax_profile_bo_tbl(i).withholding_start_date,
                                                    p_party_tax_profile_id         => x_zx_party_tax_profile_bo_tbl(i).party_tax_profile_id,
                                                    x_return_status                => l_return_status);

               IF (l_return_status <> 'S') THEN
                 x_return_status := l_return_status;
                 x_msg_data      := l_msg_data;
                 x_msg_count     := l_msg_count;
               END IF;

            ELSE
                x_return_status := l_return_status;
                x_msg_data      := l_msg_data;
                x_msg_count     := l_msg_count;
            END IF;

        END IF;


        END LOOP;


    EXCEPTION
        WHEN fnd_api.g_exc_error THEN

            x_return_status := fnd_api.g_ret_sts_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
        WHEN fnd_api.g_exc_unexpected_error THEN

            x_return_status := fnd_api.g_ret_sts_unexp_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
        WHEN OTHERS THEN

            x_return_status := fnd_api.g_ret_sts_unexp_error;

            x_msg_count := 1;
            x_msg_data  := SQLCODE || SQLERRM;
    END create_supp_tax_profile;
/*    /*#
    * Use this routine to update tax profile BO
    * @param p_api_version The api version
    * @param p_init_msg_list The Initialization message list
    * @param p_tax_profile_rec The tax profile bo
    * @param x_return_status The return status
    * @param x_msg_count The message count
    * @param x_msg_data The message data
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Create Supplier Contact
    * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
    */
/*  PROCEDURE update_supp_tax_profile(p_api_version     IN NUMBER DEFAULT NULL,
                                      p_init_msg_list   IN VARCHAR2 DEFAULT NULL,
                                      p_tax_profile_rec IN pos_party_tax_profile_int%ROWTYPE,
                                      x_return_status   OUT NOCOPY VARCHAR2,
                                      x_msg_count       OUT NOCOPY NUMBER,
                                      x_msg_data        OUT NOCOPY VARCHAR2) IS
        l_tax_prof_valid       VARCHAR2(10);
        l_party_tax_profile_id NUMBER;
        l_country_code         VARCHAR2(40);
        l_return_status        VARCHAR2(100);
        l_msg_count            NUMBER;
        l_msg_data             VARCHAR2(4000);

    BEGIN
        x_return_status := fnd_api.g_ret_sts_success;

        -- Call Validate_Tax_profile to validate the Tax Profiledata
        validate_tax_profile(p_tax_profile_rec      => p_tax_profile_rec,
                             x_return_status        => l_return_status,
                             x_msg_count            => l_msg_count,
                             x_msg_data             => l_msg_data,
                             x_tax_prof_valid       => l_tax_prof_valid,
                             x_party_tax_profile_id => l_party_tax_profile_id,
                             x_country_code         => l_country_code);

        IF (l_tax_prof_valid = 'Y') THEN

            zx_party_tax_profile_pkg.update_row(p_party_tax_profile_id         => l_party_tax_profile_id,
                                                p_collecting_authority_flag    => NULL,
                                                p_provider_type_code           => NULL,
                                                p_create_awt_dists_type_code   => NULL,
                                                p_create_awt_invoices_type_cod => NULL,
                                                p_tax_classification_code      => NULL,
                                                p_self_assess_flag             => NULL,
                                                p_allow_offset_tax_flag        => NULL,
                                                p_rep_registration_number      => p_tax_profile_rec.rep_registration_number,
                                                p_effective_from_use_le        => NULL,
                                                p_record_type_code             => NULL,
                                                p_request_id                   => NULL,
                                                p_attribute1                   => NULL,
                                                p_attribute2                   => NULL,
                                                p_attribute3                   => NULL,
                                                p_attribute4                   => NULL,
                                                p_attribute5                   => NULL,
                                                p_attribute6                   => NULL,
                                                p_attribute7                   => NULL,
                                                p_attribute8                   => NULL,
                                                p_attribute9                   => NULL,
                                                p_attribute10                  => NULL,
                                                p_attribute11                  => NULL,
                                                p_attribute12                  => NULL,
                                                p_attribute13                  => NULL,
                                                p_attribute14                  => NULL,
                                                p_attribute15                  => NULL,
                                                p_attribute_category           => NULL,
                                                p_party_id                     => p_tax_profile_rec.party_id,
                                                p_program_login_id             => NULL,
                                                p_party_type_code              => 'THIRD_PARTY',
                                                p_supplier_flag                => NULL,
                                                p_customer_flag                => NULL,
                                                p_site_flag                    => NULL,
                                                p_process_for_applicability_fl => NULL,
                                                p_rounding_level_code          => p_tax_profile_rec.rounding_level_code,
                                                p_rounding_rule_code           => p_tax_profile_rec.rounding_rule_code,
                                                p_withholding_start_date       => NULL,
                                                p_inclusive_tax_flag           => p_tax_profile_rec.inclusive_tax_flag,
                                                p_allow_awt_flag               => NULL,
                                                p_use_le_as_subscriber_flag    => NULL,
                                                p_legal_establishment_flag     => NULL,
                                                p_first_party_le_flag          => NULL,
                                                p_reporting_authority_flag     => NULL,
                                                x_return_status                => x_return_status,
                                                p_registration_type_code       => p_tax_profile_rec.registration_type_code,
                                                p_country_code                 => l_country_code);

            -- The ZX API doesn't return the Tax Profile Id that has been created
            -- So re-querying the Tax profile Id using the party Id and the party Type
            --

        ELSE
            x_return_status := l_return_status;
            x_msg_data      := l_msg_data;
            x_msg_count     := l_msg_count;
        END IF;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN

            x_return_status := fnd_api.g_ret_sts_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
        WHEN fnd_api.g_exc_unexpected_error THEN

            x_return_status := fnd_api.g_ret_sts_unexp_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
        WHEN OTHERS THEN

            x_return_status := fnd_api.g_ret_sts_unexp_error;

            x_msg_count := 1;
            x_msg_data  := SQLCODE || SQLERRM;
    END update_supp_tax_profile;
*/
END pos_supplier_tax_prof_bo_pkg;

/
