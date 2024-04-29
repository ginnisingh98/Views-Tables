--------------------------------------------------------
--  DDL for Package Body POS_SUPPLIER_BO_DEP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SUPPLIER_BO_DEP_PKG" AS
  /* $Header: POSSPFINB.pls 120.0.12010000.2 2010/02/08 14:14:14 ntungare noship $ */
        /*
        * Use this routine to get financial report bo
        * @param p_init_msg_list The Initialization message list
        * @param p_organization_id The party_id same as organization id
        * @param p_action_type The action type
        * @param x_financial_report_objs  The hz_financial_bo_tbl
        * @param x_return_status The return status
        * @param x_msg_count The message count
        * @param x_msg_data The message data
        * @rep:scope public
        * @rep:lifecycle active
        * @rep:displayname Get Supplier Financial Report
        * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
        */

        PROCEDURE get_financial_report_bos(p_init_msg_list         IN VARCHAR2 := fnd_api.g_false,
                                           p_organization_id       IN NUMBER,
                                           p_action_type           IN VARCHAR2 := NULL,
                                           x_financial_report_objs OUT NOCOPY hz_financial_bo_tbl,
                                           x_return_status         OUT NOCOPY VARCHAR2,
                                           x_msg_count             OUT NOCOPY NUMBER,
                                           x_msg_data              OUT NOCOPY VARCHAR2) IS
            CURSOR c1 IS
                SELECT hz_financial_bo(p_action_type,
                                       NULL, -- COMMON_OBJ_ID
                                       financial_report_id,
                                       party_id,
                                       type_of_financial_report,
                                       document_reference,
                                       date_report_issued,
                                       issued_period,
                                       report_start_date,
                                       report_end_date,
                                       actual_content_source,
                                       requiring_authority,
                                       audit_ind,
                                       consolidated_ind,
                                       estimated_ind,
                                       fiscal_ind,
                                       final_ind,
                                       forecast_ind,
                                       opening_ind,
                                       proforma_ind,
                                       qualified_ind,
                                       restated_ind,
                                       signed_by_principals_ind,
                                       trial_balance_ind,
                                       unbalanced_ind,
                                       status,
                                       program_update_date,
                                       created_by_module,
                                       hz_extract_bo_util_pvt.get_user_name(created_by),
                                       creation_date,
                                       last_update_date,
                                       hz_extract_bo_util_pvt.get_user_name(last_updated_by),
                                       CAST(MULTISET
                                            (SELECT hz_financial_number_obj(p_action_type,
                                                                            NULL, -- COMMON_OBJ_ID
                                                                            financial_number_id,
                                                                            financial_report_id,
                                                                            financial_number,
                                                                            financial_number_name,
                                                                            financial_units_applied,
                                                                            financial_number_currency,
                                                                            projected_actual_flag,
                                                                            status,
                                                                            program_update_date,
                                                                            created_by_module,
                                                                            hz_extract_bo_util_pvt.get_user_name(created_by),
                                                                            creation_date,
                                                                            last_update_date,
                                                                            hz_extract_bo_util_pvt.get_user_name(last_updated_by),
                                                                            actual_content_source)
                                             FROM   hz_financial_numbers
                                             WHERE  financial_report_id =
                                                    fr.financial_report_id) AS
                                            hz_financial_number_obj_tbl))
                FROM   hz_financial_reports fr
                WHERE  party_id = p_organization_id;

            l_debug_prefix VARCHAR2(30) := '';

        BEGIN

            -- initialize API return status to success.
            x_return_status := fnd_api.g_ret_sts_success;

            -- Initialize message list if p_init_msg_list is set to TRUE
            IF fnd_api.to_boolean(p_init_msg_list) THEN
                fnd_msg_pub.initialize;
            END IF;

            -- Debug info.
            IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message   => 'get_financial_report_bos(+)',
                                       p_prefix    => l_debug_prefix,
                                       p_msg_level => fnd_log.level_procedure);
            END IF;

            x_financial_report_objs := hz_financial_bo_tbl();
            OPEN c1;
            FETCH c1 BULK COLLECT
                INTO x_financial_report_objs;
            CLOSE c1;

            -- Debug info.
            IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug_return_messages(p_msg_count => x_msg_count,
                                                       p_msg_data  => x_msg_data,
                                                       p_msg_type  => 'WARNING',
                                                       p_msg_level => fnd_log.level_exception);
            END IF;

            -- Debug info.
            IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
                hz_utility_v2pub.debug(p_message   => 'get_financial_report_bos (-)',
                                       p_prefix    => l_debug_prefix,
                                       p_msg_level => fnd_log.level_procedure);
            END IF;

        EXCEPTION
            WHEN fnd_api.g_exc_error THEN

                x_return_status := fnd_api.g_ret_sts_error;
                fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                          p_data  => x_msg_data);
            WHEN fnd_api.g_exc_unexpected_error THEN

                x_return_status := fnd_api.g_ret_sts_unexp_error;
                fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                          p_data  => x_msg_data);
            WHEN OTHERS THEN

                x_return_status := fnd_api.g_ret_sts_unexp_error;

                fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                          p_data  => x_msg_data);

        END get_financial_report_bos;
-----------------------------------------------------------------
    /*#
    * Use this routine to get organization_bo
    * @param p_init_msg_list The Initialization message list
    * @param p_organization_id The party_id same as organization id
    * @param p_action_type The action type
    * @param x_organization_obj  The hz_organization_bo
    * @param x_return_status The return status
    * @param x_msg_count The message count
    * @param x_msg_data The message data
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Get Organization BO
    * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
    */
    PROCEDURE get_organization_bo(p_init_msg_list    IN VARCHAR2 := fnd_api.g_false,
                                  p_organization_id  IN NUMBER,
                                  p_action_type      IN VARCHAR2 := NULL,
                                  x_organization_obj OUT NOCOPY hz_organization_bo,
                                  x_return_status    OUT NOCOPY VARCHAR2,
                                  x_msg_count        OUT NOCOPY NUMBER,
                                  x_msg_data         OUT NOCOPY VARCHAR2) IS

        CURSOR c1 IS
            SELECT hz_organization_bo(p_action_type,
                                      NULL, -- COMMON_OBJ_ID
                                      p.party_id,
                                      NULL, --ORIG_SYSTEM,
                                      NULL, --ORIG_SYSTEM_REFERENCE,
                                      p.party_number,
                                      p.validated_flag,
                                      p.status,
                                      p.category_code,
                                      p.salutation,
                                      p.attribute_category,
                                      p.attribute1,
                                      p.attribute2,
                                      p.attribute3,
                                      p.attribute4,
                                      p.attribute5,
                                      p.attribute6,
                                      p.attribute7,
                                      p.attribute8,
                                      p.attribute9,
                                      p.attribute10,
                                      p.attribute11,
                                      p.attribute12,
                                      p.attribute13,
                                      p.attribute14,
                                      p.attribute15,
                                      p.attribute16,
                                      p.attribute17,
                                      p.attribute18,
                                      p.attribute19,
                                      p.attribute20,
                                      p.attribute21,
                                      p.attribute22,
                                      p.attribute23,
                                      p.attribute24,
                                      pro.organization_name,
                                      pro.duns_number_c,
                                      pro.enquiry_duns,
                                      pro.ceo_name,
                                      pro.ceo_title,
                                      pro.principal_name,
                                      pro.principal_title,
                                      pro.legal_status,
                                      pro.control_yr,
                                      pro.employees_total,
                                      pro.hq_branch_ind,
                                      pro.branch_flag,
                                      pro.oob_ind,
                                      pro.line_of_business,
                                      pro.cong_dist_code,
                                      pro.sic_code,
                                      pro.import_ind,
                                      pro.export_ind,
                                      pro.labor_surplus_ind,
                                      pro.debarment_ind,
                                      pro.minority_owned_ind,
                                      pro.minority_owned_type,
                                      pro.woman_owned_ind,
                                      pro.disadv_8a_ind,
                                      pro.small_bus_ind,
                                      pro.rent_own_ind,
                                      pro.debarments_count,
                                      pro.debarments_date,
                                      pro.failure_score,
                                      pro.failure_score_natnl_percentile,
                                      pro.failure_score_override_code,
                                      pro.failure_score_commentary,
                                      pro.global_failure_score,
                                      pro.db_rating,
                                      pro.credit_score,
                                      pro.credit_score_commentary,
                                      pro.paydex_score,
                                      pro.paydex_three_months_ago,
                                      pro.paydex_norm,
                                      pro.best_time_contact_begin,
                                      pro.best_time_contact_end,
                                      pro.organization_name_phonetic,
                                      pro.tax_reference,
                                      pro.gsa_indicator_flag,
                                      pro.jgzz_fiscal_code,
                                      pro.analysis_fy,
                                      pro.fiscal_yearend_month,
                                      pro.curr_fy_potential_revenue,
                                      pro.next_fy_potential_revenue,
                                      pro.year_established,
                                      pro.mission_statement,
                                      pro.organization_type,
                                      pro.business_scope,
                                      pro.corporation_class,
                                      pro.known_as,
                                      pro.known_as2,
                                      pro.known_as3,
                                      pro.known_as4,
                                      pro.known_as5,
                                      pro.local_bus_iden_type,
                                      pro.local_bus_identifier,
                                      pro.pref_functional_currency,
                                      pro.registration_type,
                                      pro.total_employees_text,
                                      pro.total_employees_ind,
                                      pro.total_emp_est_ind,
                                      pro.total_emp_min_ind,
                                      pro.parent_sub_ind,
                                      pro.incorp_year,
                                      pro.sic_code_type,
                                      pro.public_private_ownership_flag,
                                      pro.internal_flag,
                                      pro.local_activity_code_type,
                                      pro.local_activity_code,
                                      pro.emp_at_primary_adr,
                                      pro.emp_at_primary_adr_text,
                                      pro.emp_at_primary_adr_est_ind,
                                      pro.emp_at_primary_adr_min_ind,
                                      pro.high_credit,
                                      pro.avg_high_credit,
                                      pro.total_payments,
                                      pro.credit_score_class,
                                      pro.credit_score_natl_percentile,
                                      pro.credit_score_incd_default,
                                      pro.credit_score_age,
                                      pro.credit_score_date,
                                      pro.credit_score_commentary2,
                                      pro.credit_score_commentary3,
                                      pro.credit_score_commentary4,
                                      pro.credit_score_commentary5,
                                      pro.credit_score_commentary6,
                                      pro.credit_score_commentary7,
                                      pro.credit_score_commentary8,
                                      pro.credit_score_commentary9,
                                      pro.credit_score_commentary10,
                                      pro.failure_score_class,
                                      pro.failure_score_incd_default,
                                      pro.failure_score_age,
                                      pro.failure_score_date,
                                      pro.failure_score_commentary2,
                                      pro.failure_score_commentary3,
                                      pro.failure_score_commentary4,
                                      pro.failure_score_commentary5,
                                      pro.failure_score_commentary6,
                                      pro.failure_score_commentary7,
                                      pro.failure_score_commentary8,
                                      pro.failure_score_commentary9,
                                      pro.failure_score_commentary10,
                                      pro.maximum_credit_recommendation,
                                      pro.maximum_credit_currency_code,
                                      pro.displayed_duns_party_id,
                                      pro.program_update_date,
                                      pro.created_by_module,
                                      hz_extract_bo_util_pvt.get_user_name(pro.created_by),
                                      pro.creation_date,
                                      pro.last_update_date,
                                      hz_extract_bo_util_pvt.get_user_name(pro.last_updated_by),
                                      pro.do_not_confuse_with,
                                      pro.actual_content_source,
                                      hz_orig_sys_ref_obj_tbl(),
                                      hz_ext_attribute_obj_tbl(),
                                      hz_org_contact_bo_tbl(),
                                      hz_party_site_bo_tbl(),
                                      CAST(MULTISET
                                           (SELECT hz_party_pref_obj(p_action_type,
                                                                     NULL, -- COMMON_OBJ_ID
                                                                     party_preference_id,
                                                                     hz_extract_bo_util_pvt.get_parent_object_type('HZ_PARTIES',
                                                                                                                   party_id),
                                                                     party_id,
                                                                     category,
                                                                     preference_code,
                                                                     value_varchar2,
                                                                     value_number,
                                                                     value_date,
                                                                     value_name,
                                                                     module,
                                                                     additional_value1,
                                                                     additional_value2,
                                                                     additional_value3,
                                                                     additional_value4,
                                                                     additional_value5,
                                                                     hz_extract_bo_util_pvt.get_user_name(created_by),
                                                                     creation_date,
                                                                     last_update_date,
                                                                     hz_extract_bo_util_pvt.get_user_name(last_updated_by))
                                            FROM   hz_party_preferences
                                            WHERE  party_id =
                                                   p_organization_id) AS
                                           hz_party_pref_obj_tbl),
                                      hz_phone_cp_bo_tbl(),
                                      hz_telex_cp_bo_tbl(),
                                      hz_email_cp_bo_tbl(),
                                      hz_web_cp_bo_tbl(),
                                      hz_edi_cp_bo_tbl(),
                                      hz_eft_cp_bo_tbl(),
                                      hz_relationship_obj_tbl(),
                                      CAST(MULTISET
                                           (SELECT hz_code_assignment_obj(p_action_type,
                                                                          NULL, -- COMMON_OBJ_ID
                                                                          code_assignment_id,
                                                                          hz_extract_bo_util_pvt.get_parent_object_type('HZ_PARTIES',
                                                                                                                        owner_table_id),
                                                                          owner_table_id,
                                                                          class_category,
                                                                          class_code,
                                                                          primary_flag,
                                                                          actual_content_source,
                                                                          start_date_active,
                                                                          end_date_active,
                                                                          status,
                                                                          program_update_date,
                                                                          created_by_module,
                                                                          hz_extract_bo_util_pvt.get_user_name(created_by),
                                                                          creation_date,
                                                                          last_update_date,
                                                                          hz_extract_bo_util_pvt.get_user_name(last_updated_by),
                                                                          rank)
                                            FROM   hz_code_assignments
                                            WHERE  owner_table_name =
                                                   'HZ_PARTIES'
                                            AND    owner_table_id =
                                                   p_organization_id) AS
                                           hz_code_assignment_obj_tbl),
                                      hz_financial_bo_tbl(),
                                      CAST(MULTISET
                                           (SELECT hz_credit_rating_obj(p_action_type,
                                                                        NULL, -- COMMON_OBJ_ID
                                                                        credit_rating_id,
                                                                        description,
                                                                        party_id,
                                                                        rating,
                                                                        rated_as_of_date,
                                                                        rating_organization,
                                                                        comments,
                                                                        det_history_ind,
                                                                        fincl_embt_ind,
                                                                        criminal_proceeding_ind,
                                                                        claims_ind,
                                                                        secured_flng_ind,
                                                                        fincl_lgl_event_ind,
                                                                        disaster_ind,
                                                                        oprg_spec_evnt_ind,
                                                                        other_spec_evnt_ind,
                                                                        status,
                                                                        avg_high_credit,
                                                                        credit_score,
                                                                        credit_score_age,
                                                                        credit_score_class,
                                                                        credit_score_commentary,
                                                                        credit_score_commentary2,
                                                                        credit_score_commentary3,
                                                                        credit_score_commentary4,
                                                                        credit_score_commentary5,
                                                                        credit_score_commentary6,
                                                                        credit_score_commentary7,
                                                                        credit_score_commentary8,
                                                                        credit_score_commentary9,
                                                                        credit_score_commentary10,
                                                                        credit_score_date,
                                                                        credit_score_incd_default,
                                                                        credit_score_natl_percentile,
                                                                        failure_score,
                                                                        failure_score_age,
                                                                        failure_score_class,
                                                                        failure_score_commentary,
                                                                        failure_score_commentary2,
                                                                        failure_score_commentary3,
                                                                        failure_score_commentary4,
                                                                        failure_score_commentary5,
                                                                        failure_score_commentary6,
                                                                        failure_score_commentary7,
                                                                        failure_score_commentary8,
                                                                        failure_score_commentary9,
                                                                        failure_score_commentary10,
                                                                        failure_score_date,
                                                                        failure_score_incd_default,
                                                                        failure_score_natnl_percentile,
                                                                        failure_score_override_code,
                                                                        global_failure_score,
                                                                        debarment_ind,
                                                                        debarments_count,
                                                                        debarments_date,
                                                                        high_credit,
                                                                        maximum_credit_currency_code,
                                                                        maximum_credit_recommendation,
                                                                        paydex_norm,
                                                                        paydex_score,
                                                                        paydex_three_months_ago,
                                                                        credit_score_override_code,
                                                                        cr_scr_clas_expl,
                                                                        low_rng_delq_scr,
                                                                        high_rng_delq_scr,
                                                                        delq_pmt_rng_prcnt,
                                                                        delq_pmt_pctg_for_all_firms,
                                                                        num_trade_experiences,
                                                                        paydex_firm_days,
                                                                        paydex_firm_comment,
                                                                        paydex_industry_days,
                                                                        paydex_industry_comment,
                                                                        paydex_comment,
                                                                        suit_ind,
                                                                        lien_ind,
                                                                        judgement_ind,
                                                                        bankruptcy_ind,
                                                                        no_trade_ind,
                                                                        prnt_hq_bkcy_ind,
                                                                        num_prnt_bkcy_filing,
                                                                        prnt_bkcy_filg_type,
                                                                        prnt_bkcy_filg_chapter,
                                                                        prnt_bkcy_filg_date,
                                                                        num_prnt_bkcy_convs,
                                                                        prnt_bkcy_conv_date,
                                                                        prnt_bkcy_chapter_conv,
                                                                        slow_trade_expl,
                                                                        negv_pmt_expl,
                                                                        pub_rec_expl,
                                                                        business_discontinued,
                                                                        spcl_event_comment,
                                                                        num_spcl_event,
                                                                        spcl_event_update_date,
                                                                        spcl_evnt_txt,
                                                                        actual_content_source,
                                                                        program_update_date,
                                                                        created_by_module,
                                                                        hz_extract_bo_util_pvt.get_user_name(created_by),
                                                                        creation_date,
                                                                        last_update_date,
                                                                        hz_extract_bo_util_pvt.get_user_name(last_updated_by))
                                            FROM   hz_credit_ratings
                                            WHERE  party_id =
                                                   p_organization_id) AS
                                           hz_credit_rating_obj_tbl),
                                      CAST(MULTISET
                                           (SELECT hz_certification_obj(p_action_type,
                                                                        NULL, -- COMMON_OBJ_ID
                                                                        certification_id,
                                                                        certification_name,
                                                                        hz_extract_bo_util_pvt.get_parent_object_type('HZ_PARTIES',
                                                                                                                      party_id),
                                                                        party_id,
                                                                        current_status,
                                                                        expires_on_date,
                                                                        grade,
                                                                        issued_by_authority,
                                                                        issued_on_date,
                                                                        --WH_UPDATE_DATE,
                                                                        status,
                                                                        program_update_date,
                                                                        hz_extract_bo_util_pvt.get_user_name(created_by),
                                                                        creation_date,
                                                                        last_update_date,
                                                                        hz_extract_bo_util_pvt.get_user_name(last_updated_by))
                                            FROM   hz_certifications
                                            WHERE  party_id =
                                                   p_organization_id) AS
                                           hz_certification_obj_tbl),
                                      CAST(MULTISET
                                           (SELECT hz_financial_prof_obj(p_action_type,
                                                                         NULL, -- COMMON_OBJ_ID
                                                                         financial_profile_id,
                                                                         access_authority_date,
                                                                         access_authority_granted,
                                                                         balance_amount,
                                                                         balance_verified_on_date,
                                                                         financial_account_number,
                                                                         financial_account_type,
                                                                         financial_org_type,
                                                                         financial_organization_name,
                                                                         hz_extract_bo_util_pvt.get_parent_object_type('HZ_PARTIES',
                                                                                                                       party_id),
                                                                         party_id,
                                                                         --WH_UPDATE_DATE,
                                                                         status,
                                                                         program_update_date,
                                                                         hz_extract_bo_util_pvt.get_user_name(created_by),
                                                                         creation_date,
                                                                         last_update_date,
                                                                         hz_extract_bo_util_pvt.get_user_name(last_updated_by))
                                            FROM   hz_financial_profile
                                            WHERE  party_id =
                                                   p_organization_id) AS
                                           hz_financial_prof_obj_tbl),
                                      hz_contact_pref_obj_tbl(),
                                      hz_party_usage_obj_tbl())
            FROM   hz_organization_profiles pro,
                   hz_parties               p
            WHERE  pro.party_id = p.party_id
            AND    pro.party_id = p_organization_id
            AND    SYSDATE BETWEEN effective_start_date AND
                   nvl(effective_end_date, SYSDATE);

        CURSOR get_profile_id_csr IS
            SELECT organization_profile_id
            FROM   hz_organization_profiles
            WHERE  party_id = p_organization_id
            AND    SYSDATE BETWEEN effective_start_date AND
                   nvl(effective_end_date, SYSDATE);

        l_debug_prefix VARCHAR2(30) := '';
        l_prof_id      NUMBER;
    BEGIN

        -- initialize API return status to success.
        x_return_status := fnd_api.g_ret_sts_success;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF fnd_api.to_boolean(p_init_msg_list) THEN
            fnd_msg_pub.initialize;
        END IF;

        -- Debug info.
        IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message   => 'get_organization_bo(+)',
                                   p_prefix    => l_debug_prefix,
                                   p_msg_level => fnd_log.level_procedure);
        END IF;

        OPEN c1;
        FETCH c1
            INTO x_organization_obj;
        CLOSE c1;

        hz_extract_orig_sys_ref_bo_pvt.get_orig_sys_ref_bos(p_init_msg_list     => fnd_api.g_false,
                                                            p_owner_table_id    => p_organization_id,
                                                            p_owner_table_name  => 'HZ_PARTIES',
                                                            p_action_type       => NULL, --p_action_type,
                                                            x_orig_sys_ref_objs => x_organization_obj.orig_sys_objs,
                                                            x_return_status     => x_return_status,
                                                            x_msg_count         => x_msg_count,
                                                            x_msg_data          => x_msg_data);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        OPEN get_profile_id_csr;
        FETCH get_profile_id_csr
            INTO l_prof_id;
        CLOSE get_profile_id_csr;

        hz_extract_ext_attri_bo_pvt.get_ext_attribute_bos(p_init_msg_list      => fnd_api.g_false,
                                                          p_ext_object_id      => l_prof_id,
                                                          p_ext_object_name    => 'HZ_ORGANIZATION_PROFILES',
                                                          p_action_type        => p_action_type,
                                                          x_ext_attribute_objs => x_organization_obj.ext_attributes_objs,
                                                          x_return_status      => x_return_status,
                                                          x_msg_count          => x_msg_count,
                                                          x_msg_data           => x_msg_data);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        hz_extract_party_site_bo_pvt.get_party_site_bos(p_init_msg_list   => fnd_api.g_false,
                                                        p_party_id        => p_organization_id,
                                                        p_party_site_id   => NULL,
                                                        p_action_type     => p_action_type,
                                                        x_party_site_objs => x_organization_obj.party_site_objs,
                                                        x_return_status   => x_return_status,
                                                        x_msg_count       => x_msg_count,
                                                        x_msg_data        => x_msg_data);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        hz_extract_party_usage_bo_pvt.get_party_usage_bos(p_init_msg_list    => fnd_api.g_false,
                                                          p_owner_table_id   => p_organization_id,
                                                          p_owner_table_name => 'HZ_PARTIES',
                                                          p_action_type      => p_action_type,
                                                          x_party_usage_objs => x_organization_obj.party_usage_objs,
                                                          x_return_status    => x_return_status,
                                                          x_msg_count        => x_msg_count,
                                                          x_msg_data         => x_msg_data);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        hz_extract_org_cont_bo_pvt.get_org_contact_bos(p_init_msg_list    => fnd_api.g_false,
                                                       p_organization_id  => p_organization_id,
                                                       p_action_type      => p_action_type,
                                                       x_org_contact_objs => x_organization_obj.contact_objs,
                                                       x_return_status    => x_return_status,
                                                       x_msg_count        => x_msg_count,
                                                       x_msg_data         => x_msg_data);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        get_financial_report_bos(p_init_msg_list         => fnd_api.g_false,
                                 p_organization_id       => p_organization_id,
                                 p_action_type           => p_action_type,
                                 x_financial_report_objs => x_organization_obj.financial_report_objs,
                                 x_return_status         => x_return_status,
                                 x_msg_count             => x_msg_count,
                                 x_msg_data              => x_msg_data);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        hz_extract_cont_point_bo_pvt.get_phone_bos(p_init_msg_list     => fnd_api.g_false,
                                                   p_phone_id          => NULL,
                                                   p_parent_id         => p_organization_id,
                                                   p_parent_table_name => 'HZ_PARTIES',
                                                   p_action_type       => p_action_type,
                                                   x_phone_objs        => x_organization_obj.phone_objs,
                                                   x_return_status     => x_return_status,
                                                   x_msg_count         => x_msg_count,
                                                   x_msg_data          => x_msg_data);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        hz_extract_cont_point_bo_pvt.get_telex_bos(p_init_msg_list     => fnd_api.g_false,
                                                   p_telex_id          => NULL,
                                                   p_parent_id         => p_organization_id,
                                                   p_parent_table_name => 'HZ_PARTIES',
                                                   p_action_type       => p_action_type,
                                                   x_telex_objs        => x_organization_obj.telex_objs,
                                                   x_return_status     => x_return_status,
                                                   x_msg_count         => x_msg_count,
                                                   x_msg_data          => x_msg_data);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        hz_extract_cont_point_bo_pvt.get_email_bos(p_init_msg_list     => fnd_api.g_false,
                                                   p_email_id          => NULL,
                                                   p_parent_id         => p_organization_id,
                                                   p_parent_table_name => 'HZ_PARTIES',
                                                   p_action_type       => p_action_type,
                                                   x_email_objs        => x_organization_obj.email_objs,
                                                   x_return_status     => x_return_status,
                                                   x_msg_count         => x_msg_count,
                                                   x_msg_data          => x_msg_data);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        hz_extract_cont_point_bo_pvt.get_web_bos(p_init_msg_list     => fnd_api.g_false,
                                                 p_web_id            => NULL,
                                                 p_parent_id         => p_organization_id,
                                                 p_parent_table_name => 'HZ_PARTIES',
                                                 p_action_type       => p_action_type,
                                                 x_web_objs          => x_organization_obj.web_objs,
                                                 x_return_status     => x_return_status,
                                                 x_msg_count         => x_msg_count,
                                                 x_msg_data          => x_msg_data);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        hz_extract_cont_point_bo_pvt.get_edi_bos(p_init_msg_list     => fnd_api.g_false,
                                                 p_edi_id            => NULL,
                                                 p_parent_id         => p_organization_id,
                                                 p_parent_table_name => 'HZ_PARTIES',
                                                 p_action_type       => p_action_type,
                                                 x_edi_objs          => x_organization_obj.edi_objs,
                                                 x_return_status     => x_return_status,
                                                 x_msg_count         => x_msg_count,
                                                 x_msg_data          => x_msg_data);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        hz_extract_cont_point_bo_pvt.get_eft_bos(p_init_msg_list     => fnd_api.g_false,
                                                 p_eft_id            => NULL,
                                                 p_parent_id         => p_organization_id,
                                                 p_parent_table_name => 'HZ_PARTIES',
                                                 p_action_type       => p_action_type,
                                                 x_eft_objs          => x_organization_obj.eft_objs,
                                                 x_return_status     => x_return_status,
                                                 x_msg_count         => x_msg_count,
                                                 x_msg_data          => x_msg_data);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        hz_extract_relationship_bo_pvt.get_relationship_bos(p_init_msg_list     => fnd_api.g_false,
                                                            p_subject_id        => p_organization_id,
                                                            p_action_type       => p_action_type,
                                                            x_relationship_objs => x_organization_obj.relationship_objs,
                                                            x_return_status     => x_return_status,
                                                            x_msg_count         => x_msg_count,
                                                            x_msg_data          => x_msg_data);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        hz_extract_cont_point_bo_pvt.get_cont_pref_objs(p_init_msg_list       => fnd_api.g_false,
                                                        p_cont_level_table_id => p_organization_id,
                                                        p_cont_level_table    => 'HZ_PARTIES',
                                                        p_contact_type        => NULL,
                                                        p_action_type         => p_action_type,
                                                        x_cont_pref_objs      => x_organization_obj.contact_pref_objs,
                                                        x_return_status       => x_return_status,
                                                        x_msg_count           => x_msg_count,
                                                        x_msg_data            => x_msg_data);

        IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
        END IF;

        -- Debug info.
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count => x_msg_count,
                                                   p_msg_data  => x_msg_data,
                                                   p_msg_type  => 'WARNING',
                                                   p_msg_level => fnd_log.level_exception);
        END IF;

        -- Debug info.
        IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message   => 'get_organization_bo (-)',
                                   p_prefix    => l_debug_prefix,
                                   p_msg_level => fnd_log.level_procedure);
        END IF;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN

            x_return_status := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN fnd_api.g_exc_unexpected_error THEN

            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN

            x_return_status := fnd_api.g_ret_sts_unexp_error;

            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END get_organization_bo;
----------------------------------------
   FUNCTION get_party_id(p_orig_system           IN VARCHAR2,
                          p_orig_system_reference IN VARCHAR2) RETURN NUMBER AS
        l_party_id NUMBER;
    BEGIN
        SELECT owner_table_id
        INTO   l_party_id
        FROM   hz_orig_sys_references hr
        WHERE  hr.owner_table_name = 'HZ_PARTIES'
        AND    hr.orig_system = p_orig_system
        AND    hr.orig_system_reference = p_orig_system_reference
        AND    nvl(hr.end_date_active, SYSDATE) >= SYSDATE;

        RETURN l_party_id;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END get_party_id;

END pos_supplier_bo_dep_pkg;

/
