--------------------------------------------------------
--  DDL for Package Body POS_SUPPLIER_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SUPPLIER_BO_PKG" AS
/* $Header: POSSPBOB.pls 120.0.12010000.7 2012/10/10 21:06:11 riren noship $ */
PROCEDURE assign_organization(p_hz_organization_bo  IN hz_organization_bo,
                              p_pos_organization_bo OUT NOCOPY pos_organization_bo) AS

    l_contact_objs      pos_org_contact_bo_tbl := pos_org_contact_bo_tbl();
    l_contact_objs_temp hz_org_contact_bo_tbl  := hz_org_contact_bo_tbl();
    l_party_site_temp   hz_party_site_bo_tbl   := hz_party_site_bo_tbl();
    l_party_site_objs_1 pos_party_site_bo_tbl  := pos_party_site_bo_tbl();
    l_party_site_objs_2 pos_party_site_bo_tbl  := pos_party_site_bo_tbl();
    l_organization      pos_organization_bo;

   BEGIN

     l_contact_objs_temp := p_hz_organization_bo.contact_objs;
     IF l_contact_objs_temp.count > 0 THEN        -- Bug 14162504: Check if the collection is empty.
        FOR i IN l_contact_objs_temp.first .. l_contact_objs_temp.last LOOP
            l_contact_objs.extend(1);
            l_party_site_temp :=l_contact_objs_temp(i).party_site_objs;

          IF l_party_site_temp.count >0 THEN
            FOR j IN l_party_site_temp.first..l_party_site_temp.last LOOP
                l_party_site_objs_1.extend(1);
                l_party_site_objs_1(j) := pos_party_site_bo(l_party_site_temp(j).action_type,
                                                            l_party_site_temp(j).common_obj_id,
                                                            l_party_site_temp(j).party_site_id,
                                                            l_party_site_temp(j).orig_system,
                                                            l_party_site_temp(j).orig_system_reference,
                                                            l_party_site_temp(j).parent_object_type,
                                                            l_party_site_temp(j).parent_object_id,
                                                            l_party_site_temp(j).party_site_number,
                                                            l_party_site_temp(j).mailstop,
                                                            l_party_site_temp(j).identifying_address_flag,
                                                            l_party_site_temp(j).status,
                                                            l_party_site_temp(j).party_site_name,
                                                            l_party_site_temp(j).attribute_category,
                                                            l_party_site_temp(j).attribute1,
                                                            l_party_site_temp(j).attribute2,
                                                            l_party_site_temp(j).attribute3,
                                                            l_party_site_temp(j).attribute4,
                                                            l_party_site_temp(j).attribute5,
                                                            l_party_site_temp(j).attribute6,
                                                            l_party_site_temp(j).attribute7,
                                                            l_party_site_temp(j).attribute8,
                                                            l_party_site_temp(j).attribute9,
                                                            l_party_site_temp(j).attribute10,
                                                            l_party_site_temp(j).attribute11,
                                                            l_party_site_temp(j).attribute12,
                                                            l_party_site_temp(j).attribute13,
                                                            l_party_site_temp(j).attribute14,
                                                            l_party_site_temp(j).attribute15,
                                                            l_party_site_temp(j).attribute16,
                                                            l_party_site_temp(j).attribute17,
                                                            l_party_site_temp(j).attribute18,
                                                            l_party_site_temp(j).attribute19,
                                                            l_party_site_temp(j).attribute20,
                                                            l_party_site_temp(j).language,
                                                            l_party_site_temp(j).addressee,
                                                            l_party_site_temp(j).program_update_date,
                                                            l_party_site_temp(j).created_by_module,
                                                            l_party_site_temp(j).created_by_name,
                                                            l_party_site_temp(j).creation_date,
                                                            l_party_site_temp(j).last_update_date,
                                                            l_party_site_temp(j).last_updated_by_name,
                                                            l_party_site_temp(j).actual_content_source,
                                                            l_party_site_temp(j).global_location_number,
                                                            l_party_site_temp(j).orig_sys_objs,
                                                            l_party_site_temp(j).ext_attributes_objs,
                                                            l_party_site_temp(j).location_obj,
                                                            l_party_site_temp(j).party_site_use_objs,
                                                            l_party_site_temp(j).phone_objs,
                                                            l_party_site_temp(j).telex_objs,
                                                            l_party_site_temp(j).email_objs,
                                                            l_party_site_temp(j).web_objs,
                                                            l_party_site_temp(j).contact_pref_objs);

            END LOOP;
        END IF;
            l_contact_objs(i) := pos_org_contact_bo(l_contact_objs_temp(i).action_type,
                                                   l_contact_objs_temp(i).common_obj_id,
                                                   l_contact_objs_temp(i).org_contact_id,
                                                   l_contact_objs_temp(i).organization_id,
                                                   l_contact_objs_temp(i).orig_system,
                                                   l_contact_objs_temp(i).orig_system_reference,
                                                   l_contact_objs_temp(i).comments,
                                                   l_contact_objs_temp(i).contact_number,
                                                   l_contact_objs_temp(i).department_code,
                                                   l_contact_objs_temp(i).department,
                                                   l_contact_objs_temp(i).title,
                                                   l_contact_objs_temp(i).job_title,
                                                   l_contact_objs_temp(i).decision_maker_flag,
                                                   l_contact_objs_temp(i).job_title_code,
                                                   l_contact_objs_temp(i).reference_use_flag,
                                                   l_contact_objs_temp(i).rank,
                                                   l_contact_objs_temp(i).party_site_id,
                                                   l_contact_objs_temp(i).attribute_category,
                                                   l_contact_objs_temp(i).attribute1,
                                                   l_contact_objs_temp(i).attribute2,
                                                   l_contact_objs_temp(i).attribute3,
                                                   l_contact_objs_temp(i).attribute4,
                                                   l_contact_objs_temp(i).attribute5,
                                                   l_contact_objs_temp(i).attribute6,
                                                   l_contact_objs_temp(i).attribute7,
                                                   l_contact_objs_temp(i).attribute8,
                                                   l_contact_objs_temp(i).attribute9,
                                                   l_contact_objs_temp(i).attribute10,
                                                   l_contact_objs_temp(i).attribute11,
                                                   l_contact_objs_temp(i).attribute12,
                                                   l_contact_objs_temp(i).attribute13,
                                                   l_contact_objs_temp(i).attribute14,
                                                   l_contact_objs_temp(i).attribute15,
                                                   l_contact_objs_temp(i).attribute16,
                                                   l_contact_objs_temp(i).attribute17,
                                                   l_contact_objs_temp(i).attribute18,
                                                   l_contact_objs_temp(i).attribute19,
                                                   l_contact_objs_temp(i).attribute20,
                                                   l_contact_objs_temp(i).attribute21,
                                                   l_contact_objs_temp(i).attribute22,
                                                   l_contact_objs_temp(i).attribute23,
                                                   l_contact_objs_temp(i).attribute24,
                                                   l_contact_objs_temp(i).program_update_date,
                                                   l_contact_objs_temp(i).created_by_module,
                                                   l_contact_objs_temp(i).created_by_name,
                                                   l_contact_objs_temp(i).creation_date,
                                                   l_contact_objs_temp(i).last_update_date,
                                                   l_contact_objs_temp(i).last_updated_by_name,
                                                   l_contact_objs_temp(i).relationship_code,
                                                   l_contact_objs_temp(i).relationship_type,
                                                   l_contact_objs_temp(i).relationship_comments,
                                                   l_contact_objs_temp(i).start_date,
                                                   l_contact_objs_temp(i).end_date,
                                                   l_contact_objs_temp(i).status,
                                                   l_contact_objs_temp(i).orig_sys_objs,
                                                   l_contact_objs_temp(i).person_profile_obj,
                                                   l_contact_objs_temp(i).org_contact_role_objs,
                                                   l_party_site_objs_1,
                                                   l_contact_objs_temp(i).phone_objs,
                                                   l_contact_objs_temp(i).telex_objs,
                                                   l_contact_objs_temp(i).email_objs,
                                                   l_contact_objs_temp(i).web_objs,
                                                   l_contact_objs_temp(i).sms_objs,
                                                   l_contact_objs_temp(i).contact_pref_objs);
         l_party_site_objs_1.delete;
        END LOOP;
     END IF;

     IF p_hz_organization_bo.party_site_objs.count > 0 THEN        -- Bug 14699689: Check if the collection is empty.
          FOR j IN p_hz_organization_bo.party_site_objs.first..p_hz_organization_bo.party_site_objs.last LOOP
            l_party_site_objs_2.extend(1);
            l_party_site_objs_2(j) := pos_party_site_bo(p_hz_organization_bo.party_site_objs(j).action_type,
                                                        p_hz_organization_bo.party_site_objs(j).common_obj_id,
                                                        p_hz_organization_bo.party_site_objs(j).party_site_id,
                                                        p_hz_organization_bo.party_site_objs(j).orig_system,
                                                        p_hz_organization_bo.party_site_objs(j).orig_system_reference,
                                                        p_hz_organization_bo.party_site_objs(j).parent_object_type,
                                                        p_hz_organization_bo.party_site_objs(j).parent_object_id,
                                                        p_hz_organization_bo.party_site_objs(j).party_site_number,
                                                        p_hz_organization_bo.party_site_objs(j).mailstop,
                                                        p_hz_organization_bo.party_site_objs(j).identifying_address_flag,
                                                        p_hz_organization_bo.party_site_objs(j).status,
                                                        p_hz_organization_bo.party_site_objs(j).party_site_name,
                                                        p_hz_organization_bo.party_site_objs(j).attribute_category,
                                                        p_hz_organization_bo.party_site_objs(j).attribute1,
                                                        p_hz_organization_bo.party_site_objs(j).attribute2,
                                                        p_hz_organization_bo.party_site_objs(j).attribute3,
                                                        p_hz_organization_bo.party_site_objs(j).attribute4,
                                                        p_hz_organization_bo.party_site_objs(j).attribute5,
                                                        p_hz_organization_bo.party_site_objs(j).attribute6,
                                                        p_hz_organization_bo.party_site_objs(j).attribute7,
                                                        p_hz_organization_bo.party_site_objs(j).attribute8,
                                                        p_hz_organization_bo.party_site_objs(j).attribute9,
                                                        p_hz_organization_bo.party_site_objs(j).attribute10,
                                                        p_hz_organization_bo.party_site_objs(j).attribute11,
                                                        p_hz_organization_bo.party_site_objs(j).attribute12,
                                                        p_hz_organization_bo.party_site_objs(j).attribute13,
                                                        p_hz_organization_bo.party_site_objs(j).attribute14,
                                                        p_hz_organization_bo.party_site_objs(j).attribute15,
                                                        p_hz_organization_bo.party_site_objs(j).attribute16,
                                                        p_hz_organization_bo.party_site_objs(j).attribute17,
                                                        p_hz_organization_bo.party_site_objs(j).attribute18,
                                                        p_hz_organization_bo.party_site_objs(j).attribute19,
                                                        p_hz_organization_bo.party_site_objs(j).attribute20,
                                                        p_hz_organization_bo.party_site_objs(j).language,
                                                        p_hz_organization_bo.party_site_objs(j).addressee,
                                                        p_hz_organization_bo.party_site_objs(j).program_update_date,
                                                        p_hz_organization_bo.party_site_objs(j).created_by_module,
                                                        p_hz_organization_bo.party_site_objs(j).created_by_name,
                                                        p_hz_organization_bo.party_site_objs(j).creation_date,
                                                        p_hz_organization_bo.party_site_objs(j).last_update_date,
                                                        p_hz_organization_bo.party_site_objs(j).last_updated_by_name,
                                                        p_hz_organization_bo.party_site_objs(j).actual_content_source,
                                                        p_hz_organization_bo.party_site_objs(j).global_location_number,
                                                        p_hz_organization_bo.party_site_objs(j).orig_sys_objs,
                                                        p_hz_organization_bo.party_site_objs(j).ext_attributes_objs,
                                                        p_hz_organization_bo.party_site_objs(j).location_obj,
                                                        p_hz_organization_bo.party_site_objs(j).party_site_use_objs,
                                                        p_hz_organization_bo.party_site_objs(j).phone_objs,
                                                        p_hz_organization_bo.party_site_objs(j).telex_objs,
                                                        p_hz_organization_bo.party_site_objs(j).email_objs,
                                                        p_hz_organization_bo.party_site_objs(j).web_objs,
                                                        p_hz_organization_bo.party_site_objs(j).contact_pref_objs);

        END LOOP;
    END IF;
        p_pos_organization_bo := pos_organization_bo(p_hz_organization_bo.action_type,
                                                 p_hz_organization_bo.common_obj_id,
                                                 p_hz_organization_bo.organization_id,
                                                 p_hz_organization_bo.orig_system,
                                                 p_hz_organization_bo.orig_system_reference,
                                                 p_hz_organization_bo.party_number,
                                                 p_hz_organization_bo.validated_flag,
                                                 p_hz_organization_bo.status,
                                                 p_hz_organization_bo.category_code,
                                                 p_hz_organization_bo.salutation,
                                                 p_hz_organization_bo.attribute_category,
                                                 p_hz_organization_bo.attribute1,
                                                 p_hz_organization_bo.attribute2,
                                                 p_hz_organization_bo.attribute3,
                                                 p_hz_organization_bo.attribute4,
                                                 p_hz_organization_bo.attribute5,
                                                 p_hz_organization_bo.attribute6,
                                                 p_hz_organization_bo.attribute7,
                                                 p_hz_organization_bo.attribute8,
                                                 p_hz_organization_bo.attribute9,
                                                 p_hz_organization_bo.attribute10,
                                                 p_hz_organization_bo.attribute11,
                                                 p_hz_organization_bo.attribute12,
                                                 p_hz_organization_bo.attribute13,
                                                 p_hz_organization_bo.attribute14,
                                                 p_hz_organization_bo.attribute15,
                                                 p_hz_organization_bo.attribute16,
                                                 p_hz_organization_bo.attribute17,
                                                 p_hz_organization_bo.attribute18,
                                                 p_hz_organization_bo.attribute19,
                                                 p_hz_organization_bo.attribute20,
                                                 p_hz_organization_bo.attribute21,
                                                 p_hz_organization_bo.attribute22,
                                                 p_hz_organization_bo.attribute23,
                                                 p_hz_organization_bo.attribute24,
                                                 p_hz_organization_bo.organization_name,
                                                 p_hz_organization_bo.duns_number_c,
                                                 p_hz_organization_bo.enquiry_duns,
                                                 p_hz_organization_bo.ceo_name,
                                                 p_hz_organization_bo.ceo_title,
                                                 p_hz_organization_bo.principal_name,
                                                 p_hz_organization_bo.principal_title,
                                                 p_hz_organization_bo.legal_status,
                                                 p_hz_organization_bo.control_yr,
                                                 p_hz_organization_bo.employees_total,
                                                 p_hz_organization_bo.hq_branch_ind,
                                                 p_hz_organization_bo.branch_flag,
                                                 p_hz_organization_bo.oob_ind,
                                                 p_hz_organization_bo.line_of_business,
                                                 p_hz_organization_bo.cong_dist_code,
                                                 p_hz_organization_bo.sic_code,
                                                 p_hz_organization_bo.import_ind,
                                                 p_hz_organization_bo.export_ind,
                                                 p_hz_organization_bo.labor_surplus_ind,
                                                 p_hz_organization_bo.debarment_ind,
                                                 p_hz_organization_bo.minority_owned_ind,
                                                 p_hz_organization_bo.minority_owned_type,
                                                 p_hz_organization_bo.woman_owned_ind,
                                                 p_hz_organization_bo.disadv_8a_ind,
                                                 p_hz_organization_bo.small_bus_ind,
                                                 p_hz_organization_bo.rent_own_ind,
                                                 p_hz_organization_bo.debarments_count,
                                                 p_hz_organization_bo.debarments_date,
                                                 p_hz_organization_bo.failure_score,
                                                 p_hz_organization_bo.failure_score_natnl_per,
                                                 p_hz_organization_bo.failure_score_override_code,
                                                 p_hz_organization_bo.failure_score_commentary,
                                                 p_hz_organization_bo.global_failure_score,
                                                 p_hz_organization_bo.db_rating,
                                                 p_hz_organization_bo.credit_score,
                                                 p_hz_organization_bo.credit_score_commentary,
                                                 p_hz_organization_bo.paydex_score,
                                                 p_hz_organization_bo.paydex_three_months_ago,
                                                 p_hz_organization_bo.paydex_norm,
                                                 p_hz_organization_bo.best_time_contact_begin,
                                                 p_hz_organization_bo.best_time_contact_end,
                                                 p_hz_organization_bo.organization_name_phonetic,
                                                 p_hz_organization_bo.tax_reference,
                                                 p_hz_organization_bo.gsa_indicator_flag,
                                                 p_hz_organization_bo.jgzz_fiscal_code,
                                                 p_hz_organization_bo.analysis_fy,
                                                 p_hz_organization_bo.fiscal_yearend_month,
                                                 p_hz_organization_bo.curr_fy_potential_revenue,
                                                 p_hz_organization_bo.next_fy_potential_revenue,
                                                 p_hz_organization_bo.year_established,
                                                 p_hz_organization_bo.mission_statement,
                                                 p_hz_organization_bo.organization_type,
                                                 p_hz_organization_bo.business_scope,
                                                 p_hz_organization_bo.corporation_class,
                                                 p_hz_organization_bo.known_as,
                                                 p_hz_organization_bo.known_as2,
                                                 p_hz_organization_bo.known_as3,
                                                 p_hz_organization_bo.known_as4,
                                                 p_hz_organization_bo.known_as5,
                                                 p_hz_organization_bo.local_bus_iden_type,
                                                 p_hz_organization_bo.local_bus_identifier,
                                                 p_hz_organization_bo.pref_functional_currency,
                                                 p_hz_organization_bo.registration_type,
                                                 p_hz_organization_bo.total_employees_text,
                                                 p_hz_organization_bo.total_employees_ind,
                                                 p_hz_organization_bo.total_emp_est_ind,
                                                 p_hz_organization_bo.total_emp_min_ind,
                                                 p_hz_organization_bo.parent_sub_ind,
                                                 p_hz_organization_bo.incorp_year,
                                                 p_hz_organization_bo.sic_code_type,
                                                 p_hz_organization_bo.public_private_owner_flag,
                                                 p_hz_organization_bo.internal_flag,
                                                 p_hz_organization_bo.local_activity_code_type,
                                                 p_hz_organization_bo.local_activity_code,
                                                 p_hz_organization_bo.emp_at_primary_adr,
                                                 p_hz_organization_bo.emp_at_primary_adr_text,
                                                 p_hz_organization_bo.emp_at_primary_adr_est_ind,
                                                 p_hz_organization_bo.emp_at_primary_adr_min_ind,
                                                 p_hz_organization_bo.high_credit,
                                                 p_hz_organization_bo.avg_high_credit,
                                                 p_hz_organization_bo.total_payments,
                                                 p_hz_organization_bo.credit_score_class,
                                                 p_hz_organization_bo.credit_score_natl_percentile,
                                                 p_hz_organization_bo.credit_score_incd_default,
                                                 p_hz_organization_bo.credit_score_age,
                                                 p_hz_organization_bo.credit_score_date,
                                                 p_hz_organization_bo.credit_score_commentary2,
                                                 p_hz_organization_bo.credit_score_commentary3,
                                                 p_hz_organization_bo.credit_score_commentary4,
                                                 p_hz_organization_bo.credit_score_commentary5,
                                                 p_hz_organization_bo.credit_score_commentary6,
                                                 p_hz_organization_bo.credit_score_commentary7,
                                                 p_hz_organization_bo.credit_score_commentary8,
                                                 p_hz_organization_bo.credit_score_commentary9,
                                                 p_hz_organization_bo.credit_score_commentary10,
                                                 p_hz_organization_bo.failure_score_class,
                                                 p_hz_organization_bo.failure_score_incd_default,
                                                 p_hz_organization_bo.failure_score_age,
                                                 p_hz_organization_bo.failure_score_date,
                                                 p_hz_organization_bo.failure_score_commentary2,
                                                 p_hz_organization_bo.failure_score_commentary3,
                                                 p_hz_organization_bo.failure_score_commentary4,
                                                 p_hz_organization_bo.failure_score_commentary5,
                                                 p_hz_organization_bo.failure_score_commentary6,
                                                 p_hz_organization_bo.failure_score_commentary7,
                                                 p_hz_organization_bo.failure_score_commentary8,
                                                 p_hz_organization_bo.failure_score_commentary9,
                                                 p_hz_organization_bo.failure_score_commentary10,
                                                 p_hz_organization_bo.maximum_credit_recommend,
                                                 p_hz_organization_bo.maximum_credit_currency_code,
                                                 p_hz_organization_bo.displayed_duns_party_id,
                                                 p_hz_organization_bo.program_update_date,
                                                 p_hz_organization_bo.created_by_module,
                                                 p_hz_organization_bo.created_by_name,
                                                 p_hz_organization_bo.creation_date,
                                                 p_hz_organization_bo.last_update_date,
                                                 p_hz_organization_bo.last_updated_by_name,
                                                 p_hz_organization_bo.do_not_confuse_with,
                                                 p_hz_organization_bo.actual_content_source,
                                                 p_hz_organization_bo.orig_sys_objs,
                                                 p_hz_organization_bo.ext_attributes_objs,
                                                 l_contact_objs,
                                                 l_party_site_objs_2,
                                                 p_hz_organization_bo.preference_objs,
                                                 p_hz_organization_bo.phone_objs,
                                                 p_hz_organization_bo.telex_objs,
                                                 p_hz_organization_bo.email_objs,
                                                 p_hz_organization_bo.web_objs,
                                                 p_hz_organization_bo.edi_objs,
                                                 p_hz_organization_bo.eft_objs,
                                                 p_hz_organization_bo.relationship_objs,
                                                 p_hz_organization_bo.class_objs,
                                                 p_hz_organization_bo.financial_report_objs,
                                                 p_hz_organization_bo.credit_rating_objs,
                                                 p_hz_organization_bo.certification_objs,
                                                 p_hz_organization_bo.financial_prof_objs,
                                                 p_hz_organization_bo.contact_pref_objs,
                                                 p_hz_organization_bo.party_usage_objs);

    EXCEPTION
        WHEN OTHERS THEN
        fnd_file.put_line(fnd_file.log,'exception detected in assign_organization.');
          RAISE;

    END assign_organization;

    /*#
    * Use this routine to get supplier BO
    * @param p_api_version The api version
    * @param p_init_msg_list The Initialization message list
    * @param p_party_id The party_id
    * @param p_orig_system The Orig System
    * @param p_orig_system_reference The Orig System Reference
    * @param x_pos_supplier_bo The supplier bo
    * @param x_return_status The return status
    * @param x_msg_count The message count
    * @param x_msg_data The message data
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Get Supplier All BO
    * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
    */
    PROCEDURE pos_get_supplier_bo(p_api_version           IN NUMBER DEFAULT NULL,
                                  p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
                                  p_party_id              IN NUMBER,
                                  p_orig_system           IN VARCHAR2,
                                  p_orig_system_reference IN VARCHAR2,
                                  x_pos_supplier_bo       OUT NOCOPY pos_supplier_bo,
                                  x_return_status         OUT NOCOPY VARCHAR2,
                                  x_msg_count             OUT NOCOPY NUMBER,
                                  x_msg_data              OUT NOCOPY VARCHAR2) IS

        l_api_version   NUMBER;
        l_init_msg_list VARCHAR2(1000);
        l_return_status VARCHAR2(20);
        l_msg_count     NUMBER;
        l_msg_data      VARCHAR2(1000);
        x_ap_supplier_bo             pos_ap_supplier_bo;
        x_pos_supplier_site_bo       pos_supplier_sites_all_bo_tbl;
        x_pos_supplier_contact_bo    pos_supplier_contact_bo_tbl;
        x_pos_business_class_bo_tbl  pos_business_class_bo_tbl;
        x_pos_tax_profile_bo_tbl     pos_tax_profile_bo_tbl;
        x_pos_product_service_bo_tbl pos_product_service_bo_tbl;
        x_pos_bank_payment_bo_tbl    pos_bank_payment_bo_tbl;
        x_pos_bank_account_bo_tbl    pos_bank_account_bo_tbl;
        x_pos_bank_payee_bo_tbl      pos_bank_payee_bo_tbl;
        x_pos_tax_report_bo_tbl      pos_tax_report_bo_tbl;
        x_hz_organization_bo         hz_organization_bo;
        x_pos_organization_bo        pos_organization_bo;
        x_hz_org_contact_bo_tbl      hz_org_contact_bo_tbl;
        x_hz_locations_bo_tbl        pos_hz_location_bo_tbl;
        x_hz_party_bo                pos_hz_party_bo;
        x_pos_supplier_uda           pos_supp_uda_obj_tbl;
        x_pos_hz_party_site_bo_tbl   pos_hz_party_site_bo_tbl;
        l_party_id                   NUMBER;
    BEGIN

        x_pos_supplier_bo := pos_supplier_bo(NULL,
                                             NULL,
                                             NULL,
                                             pos_supplier_sites_all_bo_tbl(),
                                             pos_hz_party_site_bo_tbl(),
                                             pos_supplier_contact_bo_tbl(),
                                             pos_business_class_bo_tbl(),
                                             pos_tax_profile_bo_tbl(),
                                             pos_product_service_bo_tbl(),
                                             pos_bank_account_bo_tbl(),
                                             pos_bank_payee_bo_tbl(),
                                             pos_tax_report_bo_tbl(),
                                             NULL,
                                             NULL);
        IF p_party_id IS NULL THEN
            l_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_orig_system,
                                                               p_orig_system_reference);
            IF l_party_id IS NULL OR l_party_id = 0 THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                x_msg_data      := 'Unable to retrieve Party ID';
                RETURN;
            END IF;

        ELSE

            l_party_id := p_party_id;
        END IF;

        --populating ap_supplier data;
       pos_ap_supplier_bo_pkg.get_ap_supplier_bo(p_api_version,
                                                  p_init_msg_list,
                                                  l_party_id,
                                                  p_orig_system,
                                                  p_orig_system_reference,
                                                  x_ap_supplier_bo,
                                                  x_return_status,
                                                  x_msg_count,
                                                  x_msg_data);
       IF x_msg_data IS NULL THEN
          fnd_file.put_line(fnd_file.log,'Extracted the Supplier Data');
       ELSE
          fnd_file.put_line(fnd_file.log,'Extracting the Supplier Data: Exception: '||x_msg_data);
       END IF;

        /*pos_supplier_uda_bo_pkg.get_uda_data(p_api_version      ,
        NULL    ,
         NULL,
         'SUPP_LEVEL',
         x_pos_supplier_uda ,
         x_return_status    ,
         x_msg_count        ,
         x_msg_data         );*/

	--populating ap_supplier_site data;
        pos_ap_supplier_site_bo_pkg.get_pos_supplier_sites_bo_tbl(p_api_version,
                                                                  p_init_msg_list,
                                                                  l_party_id,
                                                                  p_orig_system,
                                                                  p_orig_system_reference,
                                                                  x_pos_supplier_site_bo,
                                                                  x_return_status,
                                                                  x_msg_count,
                                                                  x_msg_data);
       IF x_msg_data IS NULL THEN
          fnd_file.put_line(fnd_file.log,'Extracted the Supplier Site Data');
       ELSE
          fnd_file.put_line(fnd_file.log,'Extracting the Supplier Site Data: Exception: '||x_msg_data);
       END IF;


        pos_hz_party_site_bo_tbl_pkg.get_party_site_bos(l_party_id,
                                                        x_pos_hz_party_site_bo_tbl,
                                                        x_return_status,
                                                        x_msg_count,
                                                        x_msg_data);

        IF x_msg_data IS NULL THEN
          fnd_file.put_line(fnd_file.log,'Extracted the Party Site Data');
        ELSE
          fnd_file.put_line(fnd_file.log,'Extracting the Party Site Data: Exception: '||x_msg_data);
        END IF;

        -- Bug 12795884: Populating bank account data

        pos_bank_account_bo_pkg.get_pos_bank_account_bo_tbl(p_api_version,
        p_init_msg_list,
        p_party_id,
        p_orig_system,
        p_orig_system_reference,
        x_pos_bank_account_bo_tbl,
        x_return_status,
        x_msg_count,
        x_msg_data);

        IF x_msg_data IS NULL THEN
          fnd_file.put_line(fnd_file.log,'Extracted the Bank Account Data');
        ELSE
          fnd_file.put_line(fnd_file.log,'Extracting the Bank Account Data: Exception: '||x_msg_data);
        END IF;

        -- End Bug 12795884

        --organization
        hz_organization_bo_pub.get_organization_bo(p_init_msg_list,
                                                   l_party_id,
                                                   p_orig_system,
                                                   p_orig_system_reference,
                                                   x_hz_organization_bo,
                                                   x_return_status,
                                                   x_msg_count,
                                                   x_msg_data);

        IF x_msg_data IS NULL THEN
          fnd_file.put_line(fnd_file.log,'Extracted the Supplier Organization Data');
        ELSE
          fnd_file.put_line(fnd_file.log,'Extracting the Supplier Organization Data: Exception: '||x_msg_data);
        END IF;

        --populating business class  data;
        pos_business_class_bo_pkg.get_pos_business_class_bo_tbl(p_api_version,
                                                                p_init_msg_list,
                                                                p_party_id,
                                                                p_orig_system,
                                                                p_orig_system_reference,
                                                                x_pos_business_class_bo_tbl,
                                                                x_return_status,
                                                                x_msg_count,
                                                                x_msg_data);
        IF x_msg_data IS NULL THEN
          fnd_file.put_line(fnd_file.log,'Extracted the Supplier Business Class Data');
        ELSE
          fnd_file.put_line(fnd_file.log,'Extracting the Supplier Business Class Data: Exception: '||x_msg_data);
        END IF;

        --populating bank payee  data;
        pos_bank_payee_bo_pkg.get_pos_bank_payee_bo_tbl(p_api_version,
                                                        p_init_msg_list,
                                                        p_party_id,
                                                        p_orig_system,
                                                        p_orig_system_reference,
                                                        x_pos_bank_payee_bo_tbl,
                                                        x_return_status,
                                                        x_msg_count,
                                                        x_msg_data);
        IF x_msg_data IS NULL THEN
          fnd_file.put_line(fnd_file.log,'Extracted the Bank Payee Data');
        ELSE
          fnd_file.put_line(fnd_file.log,'Extracting the Bank Payee Data: Exception: '||x_msg_data);
        END IF;


        --Populating Party Data
        pos_hz_party_bo_pkg.get_hz_party_bo(p_api_version,
                                            p_init_msg_list,
                                            p_party_id,

                                            x_hz_party_bo,
                                            x_return_status,
                                            x_msg_count,
                                            x_msg_data);
        IF x_msg_data IS NULL THEN
          fnd_file.put_line(fnd_file.log,'Extracted the Party Data');
        ELSE
          fnd_file.put_line(fnd_file.log,'Extracting the Party Data: Exception: '||x_msg_data);
        END IF;

        --populating product services data
        pos_product_service_bo_pkg.get_pos_product_service_bo_tbl(p_api_version,
                                                                  p_init_msg_list,
                                                                  p_party_id,
                                                                  p_orig_system,
                                                                  p_orig_system_reference,
                                                                  x_pos_product_service_bo_tbl,
                                                                  x_return_status,
                                                                  x_msg_count,
                                                                  x_msg_data);
        IF (x_msg_data IS NULL or x_msg_data='SUCCESS' )THEN
          fnd_file.put_line(fnd_file.log,'Extracted the Supplier Product Services Data');
        ELSE
          fnd_file.put_line(fnd_file.log,'Extracting the Supplier Product Services Data: Exception: '||x_msg_data);
        END IF;

        --Populating supplier contacts data
        pos_supplier_contact_bo_pkg.get_pos_supp_contact_bo_tbl(p_api_version,
                                                                p_init_msg_list,
                                                                p_party_id,
                                                                p_orig_system,
                                                                p_orig_system_reference,
                                                                x_pos_supplier_contact_bo,
                                                                x_return_status,
                                                                x_msg_count,
                                                                x_msg_data);
        IF x_msg_data IS NULL THEN
          fnd_file.put_line(fnd_file.log,'Extracted the Supplier Contact Data');
        ELSE
          fnd_file.put_line(fnd_file.log,'Extracting the Supplier Contact Data: Exception: '||x_msg_data);
        END IF;

        --populating tax profile data
        pos_supplier_tax_prof_bo_pkg.get_pos_sup_tax_prof_bo_tbl(p_api_version,
                                                                 p_init_msg_list,
                                                                 p_party_id,
                                                                 p_orig_system,
                                                                 p_orig_system_reference,
                                                                 x_pos_tax_profile_bo_tbl,
                                                                 x_return_status,
                                                                 x_msg_count,
                                                                 x_msg_data);
        IF x_msg_data IS NULL THEN
          fnd_file.put_line(fnd_file.log,'Extracted the Supplier Tax Profile Data');
        ELSE
          fnd_file.put_line(fnd_file.log,'Extracting the Supplier Tax Profile Data: Exception: '||x_msg_data);
        END IF;

        --Populating tax reporting data
        pos_tax_report_bo_pkg.get_pos_tax_report_bo_tbl(p_api_version,
                                                        p_init_msg_list,
                                                        p_party_id,
                                                        p_orig_system,
                                                        p_orig_system_reference,
                                                        x_pos_tax_report_bo_tbl,
                                                        x_return_status,
                                                        x_msg_count,
                                                        x_msg_data);
        IF x_msg_data IS NULL THEN
          fnd_file.put_line(fnd_file.log,'Extracted the Supplier Tax Report Data');
        ELSE
          fnd_file.put_line(fnd_file.log,'Extracting the Supplier Tax Report Data: Exception: '||x_msg_data);
        END IF;

       --Populating Location data
        pos_hz_location_bo_pkg.get_hz_location_bo(p_api_version,
                                                  p_init_msg_list,
                                                  p_party_id,
                                                  p_orig_system,
                                                  p_orig_system_reference,
                                                  x_hz_locations_bo_tbl,
                                                  x_return_status,
                                                  x_msg_count,
                                                  x_msg_data);

        IF x_msg_data IS NULL THEN
          fnd_file.put_line(fnd_file.log,'Extracted the Supplier Location Data');
        ELSE
          fnd_file.put_line(fnd_file.log,'Extracting the Supplier Location Data: Exception: '||x_msg_data);
        END IF;

        x_pos_supplier_bo.p_pos_ap_supplier_bo := x_ap_supplier_bo;
        x_pos_supplier_bo.p_pos_supplier_sites_all_tbl  := x_pos_supplier_site_bo;
        x_pos_supplier_bo.p_pos_supplier_contact_bo_tbl := x_pos_supplier_contact_bo;
        x_pos_supplier_bo.p_pos_business_class_bo_tbl   := x_pos_business_class_bo_tbl;
        x_pos_supplier_bo.p_pos_tax_profile_bo_tbl      := x_pos_tax_profile_bo_tbl;
        x_pos_supplier_bo.p_pos_product_service_bo_tbl  := x_pos_product_service_bo_tbl;

        x_pos_supplier_bo.p_pos_bank_account_bo_tbl    := x_pos_bank_account_bo_tbl;
        x_pos_supplier_bo.p_pos_bank_payee_bo_tbl    := x_pos_bank_payee_bo_tbl;
        x_pos_supplier_bo.p_pos_tax_report_bo_tbl    := x_pos_tax_report_bo_tbl;
        x_pos_supplier_bo.p_pos_hz_party_bo          := x_hz_party_bo;
        x_pos_supplier_bo.p_pos_hz_party_site_bo_tbl := x_pos_hz_party_site_bo_tbl;

        assign_organization(x_hz_organization_bo,x_pos_supplier_bo.p_hz_organization_bo);

        x_pos_supplier_bo.p_hz_locations_bo    := x_hz_locations_bo_tbl;
        x_pos_supplier_bo.party_id             := l_party_id;

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
    END pos_get_supplier_bo;

    PROCEDURE pos_create_update_supplier_bo(p_api_version           IN NUMBER DEFAULT NULL,
                                            p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
                                            p_party_id              IN NUMBER,
                                            p_orig_system           IN VARCHAR2,
                                            p_orig_system_reference IN VARCHAR2,
                                            p_create_update_flag    IN VARCHAR2,
                                            p_pos_supplier_bo       IN pos_supplier_bo,
                                            x_return_status         OUT NOCOPY VARCHAR2,
                                            x_msg_count             OUT NOCOPY NUMBER,
                                            x_msg_data              OUT NOCOPY VARCHAR2) IS
        l_party_id          NUMBER;
        p_request_status    VARCHAR2(20);
        x_vendor_contact_id NUMBER;
        x_per_party_id      NUMBER;
        x_rel_party_id      NUMBER;
        x_rel_id            NUMBER;
        x_org_contact_id    NUMBER;
        x_party_site_id     NUMBER;
        x_tax_profile_id    NUMBER;
        x_vendor_id         NUMBER;
        x_party_id          NUMBER;
        x_vendor_site_id    NUMBER;
        x_location_id       NUMBER;
    BEGIN

        IF p_party_id IS NULL THEN
            l_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_orig_system,
                                                               p_orig_system_reference);
        ELSE
            l_party_id := p_party_id;
        END IF;

        pos_ap_supplier_bo_pkg.create_pos_ap_supplier(p_api_version,
                                                      p_init_msg_list,
                                                      p_pos_supplier_bo.p_pos_ap_supplier_bo,
                                                      l_party_id,
                                                      p_orig_system,
                                                      p_orig_system_reference,
                                                      p_create_update_flag,
                                                      x_vendor_id,
                                                      x_party_id,
                                                      x_return_status,
                                                      x_msg_count,
                                                      x_msg_data);

        pos_ap_supplier_site_bo_pkg.create_pos_supplier_site_bo(p_api_version,
                                                                p_init_msg_list,
                                                                p_pos_supplier_bo.p_pos_supplier_sites_all_tbl,
                                                                p_party_id,
                                                                p_orig_system,
                                                                p_orig_system_reference,
                                                                p_create_update_flag,
                                                                x_vendor_site_id,
                                                                x_party_site_id,
                                                                x_location_id,
                                                                x_return_status,
                                                                x_msg_count,
                                                                x_msg_data);

        pos_business_class_bo_pkg.create_bus_class_attr(p_api_version,
                                                        p_init_msg_list,
                                                        p_pos_supplier_bo.p_pos_business_class_bo_tbl,
                                                        p_party_id,
                                                        p_orig_system,
                                                        p_orig_system_reference,
                                                        p_create_update_flag,
                                                        x_return_status,
                                                        x_msg_count,
                                                        x_msg_data);

        pos_bank_payee_bo_pkg.create_pos_bank_payee_bo_tbl(p_api_version,
                                                           p_init_msg_list,
                                                           p_pos_supplier_bo.p_pos_bank_payee_bo_tbl,
                                                           p_party_id,
                                                           p_orig_system,
                                                           p_orig_system_reference,
                                                           p_create_update_flag,
                                                           x_return_status,
                                                           x_msg_count,
                                                           x_msg_data);

        --populating product services data
        pos_product_service_bo_pkg.create_pos_product_service(p_api_version,
                                                              p_init_msg_list,
                                                              p_pos_supplier_bo.p_pos_product_service_bo_tbl,
                                                              p_request_status,
                                                              p_party_id,
                                                              p_orig_system,
                                                              p_orig_system_reference,
                                                              x_return_status,
                                                              x_msg_count,
                                                              x_msg_data);

        --Populating supplier contacts data
        pos_supplier_contact_bo_pkg.create_pos_supp_contact_bo(p_api_version,
                                                               p_init_msg_list,
                                                               p_pos_supplier_bo.p_pos_supplier_contact_bo_tbl,
                                                               p_party_id,
                                                               p_orig_system,
                                                               p_orig_system_reference,
                                                               p_create_update_flag,
                                                               x_vendor_contact_id,
                                                               x_per_party_id,
                                                               x_rel_party_id,
                                                               x_rel_id,
                                                               x_org_contact_id,
                                                               x_party_site_id,
                                                               x_return_status,
                                                               x_msg_count,
                                                               x_msg_data);
        --populating tax profile data

        pos_supplier_tax_prof_bo_pkg.create_supp_tax_profile(p_api_version,
                                                             p_init_msg_list,
                                                             p_pos_supplier_bo.p_pos_tax_profile_bo_tbl,
                                                             p_party_id,
                                                             p_orig_system,
                                                             p_orig_system_reference,
                                                             p_create_update_flag,
                                                             x_return_status,
                                                             x_msg_count,
                                                             x_msg_data,
                                                             x_tax_profile_id);

        --Populating tax reporting data
        pos_tax_report_bo_pkg.create_pos_tax_report_bo_row(p_api_version,
                                                           p_init_msg_list,
                                                           p_party_id,
                                                           p_orig_system,
                                                           p_orig_system_reference,
                                                           p_create_update_flag,
                                                           p_pos_supplier_bo.p_pos_tax_report_bo_tbl,
                                                           x_return_status,
                                                           x_msg_count,
                                                           x_msg_data);

        /*--Populating relationship data
        pos_supplier_bo_dep_pkg.get_relationship_bos(p_init_msg_list,

                                                     p_party_id,
                                                     NULL,
                                                     x_hz_relationship_obj_tbl,
                                                     x_return_status,
                                                     x_msg_count,
                                                     x_msg_data);*/

        --Populate organization data
        /* pos_supplier_bo_dep_pkg.get_organization_bo(p_init_msg_list,
        p_party_id,
        NULL,
        x_hz_organization_bo,
        x_return_status,
        x_msg_count,
        x_msg_data);*/

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
    END pos_create_update_supplier_bo;

END pos_supplier_bo_pkg;

/
