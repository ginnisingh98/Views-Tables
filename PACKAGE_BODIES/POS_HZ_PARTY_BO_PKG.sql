--------------------------------------------------------
--  DDL for Package Body POS_HZ_PARTY_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_HZ_PARTY_BO_PKG" AS
 /* $Header: POSSPPAB.pls 120.0.12010000.1 2010/02/02 06:34:06 ntungare noship $ */
    PROCEDURE get_hz_party_bo(p_api_version   IN NUMBER DEFAULT NULL,
                              p_init_msg_list IN VARCHAR2 DEFAULT NULL,
                              p_party_id      IN NUMBER,
                              x_hz_party_bo   OUT NOCOPY pos_hz_party_bo,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count     OUT NOCOPY NUMBER,
                              x_msg_data      OUT NOCOPY VARCHAR2) IS

        l_pos_hz_party_bo pos_hz_party_bo;

    BEGIN
        SELECT pos_hz_party_bo(party_id,
                               party_number,
                               party_name,
                               party_type,
                               validated_flag,
                               last_updated_by,
                               creation_date,
                               last_update_login,
                               request_id,
                               program_application_id,
                               created_by,
                               last_update_date,
                               program_id,
                               program_update_date,
                               wh_update_date,
                               attribute_category,
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
                               attribute16,
                               attribute17,
                               attribute18,
                               attribute19,
                               attribute20,
                               attribute21,
                               attribute22,
                               attribute23,
                               attribute24,
                               global_attribute_category,
                               global_attribute1,
                               global_attribute2,
                               global_attribute4,
                               global_attribute3,
                               global_attribute5,
                               global_attribute6,
                               global_attribute7,
                               global_attribute8,
                               global_attribute9,
                               global_attribute10,
                               global_attribute11,
                               global_attribute12,
                               global_attribute13,
                               global_attribute14,
                               global_attribute15,
                               global_attribute16,
                               global_attribute17,
                               global_attribute18,
                               global_attribute19,
                               global_attribute20,
                               orig_system_reference,
                               sic_code,
                               hq_branch_ind,
                               customer_key,
                               tax_reference,
                               jgzz_fiscal_code,
                               duns_number,
                               tax_name,
                               person_pre_name_adjunct,
                               person_first_name,
                               person_middle_name,
                               person_last_name,
                               person_name_suffix,
                               person_title,
                               person_academic_title,
                               person_previous_last_name,
                               known_as,
                               person_iden_type,
                               person_identifier,
                               group_type,
                               country,
                               address1,
                               address2,
                               address3,
                               address4,
                               city,
                               postal_code,
                               state,
                               province,
                               status,
                               county,
                               sic_code_type,
                               total_num_of_orders,
                               total_ordered_amount,
                               last_ordered_date,
                               url,
                               email_address,
                               do_not_mail_flag,
                               analysis_fy,
                               fiscal_yearend_month,
                               employees_total,
                               curr_fy_potential_revenue,
                               next_fy_potential_revenue,
                               year_established,
                               gsa_indicator_flag,
                               mission_statement,
                               organization_name_phonetic,
                               person_first_name_phonetic,
                               person_last_name_phonetic,
                               language_name,
                               category_code,
                               reference_use_flag,
                               third_party_flag,
                               competitor_flag,
                               salutation,
                               known_as2,
                               known_as3,
                               known_as4,
                               known_as5,
                               duns_number_c,
                               object_version_number,
                               created_by_module,
                               application_id,
                               primary_phone_contact_pt_id,
                               primary_phone_purpose,
                               primary_phone_line_type,
                               primary_phone_country_code,
                               primary_phone_area_code,
                               primary_phone_number,
                               primary_phone_extension,
                               certification_level,
                               cert_reason_code,
                               preferred_contact_method,
                               home_country,
                               person_bo_version,
                               org_bo_version,
                               person_cust_bo_version,
                               org_cust_bo_version)
        INTO   l_pos_hz_party_bo
        FROM   hz_parties
        WHERE  party_id = p_party_id;

        x_hz_party_bo := l_pos_hz_party_bo;

    EXCEPTION
        WHEN no_data_found THEN
            x_return_status := fnd_api.g_ret_sts_error;
            x_msg_data      := SQLCODE || SQLERRM;
            x_msg_count     := 1;
        WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            x_msg_data      := SQLCODE || SQLERRM;
            x_msg_count     := 1;

    END get_hz_party_bo;

END pos_hz_party_bo_pkg;

/
