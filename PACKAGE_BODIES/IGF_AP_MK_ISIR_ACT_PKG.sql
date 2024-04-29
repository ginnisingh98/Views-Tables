--------------------------------------------------------
--  DDL for Package Body IGF_AP_MK_ISIR_ACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_MK_ISIR_ACT_PKG" AS
/* $Header: IGFAP41B.pls 120.2 2006/01/17 02:38:02 tsailaja noship $ */

g_log_tab_index   NUMBER := 0;

TYPE log_record IS RECORD
        ( person_number VARCHAR2(30),
          message_text VARCHAR2(500));

-- The PL/SQL table for storing the log messages
TYPE LogTab IS TABLE OF log_record
           index by binary_integer;

g_log_tab LogTab;

 -- The PL/SQL table for storing the duplicate person number
TYPE PerTab IS TABLE OF igf_ap_li_isir_act_ints.person_number%TYPE
           index by binary_integer;

g_per_tab PerTab;

-- THIS IS THE GLOBAL CURSOR THAT IS USED TO UPDATE THE  FA BASE RECORD IF THE TODO ITEMS ARE SUCCESSFULLY IMPORTED

CURSOR c_baseid_exists(cp_base_id NUMBER)
    IS
    SELECT  ROWID  row_id,
            base_id,
            ci_cal_type,
            person_id,
            ci_sequence_number,
            org_id ,
            bbay  ,
            current_enrolled_hrs ,
            special_handling,
            coa_pending,
            sap_evaluation_date,
            sap_selected_flag,
            state_sap_status,
            verification_process_run,
            inst_verif_status_date,
            manual_verif_flag,
            fed_verif_status,
            fed_verif_status_date,
            inst_verif_status,
            nslds_eligible,
            ede_correction_batch_id,
            fa_process_status_date,
            isir_corr_status,
            isir_corr_status_date,
            isir_status,
            isir_status_date,
            profile_status,
            profile_status_date,
            profile_fc,
            pell_eligible,
            award_adjusted,
            change_pending,
            coa_code_f,
            coa_fixed,
            coa_code_i,
            coa_f,
            coa_i                   ,
            coa_pell                ,
            disbursement_hold       ,
            enrolment_status        ,
            enrolment_status_date   ,
            fa_process_status       ,
            federal_sap_status      ,
            grade_level             ,
            grade_level_date        ,
            grade_level_type        ,
            inst_sap_status         ,
            last_packaged           ,
            notification_status     ,
            notification_status_date ,
            packaging_hold          ,
            nslds_data_override_flg ,
            packaging_status        ,
            prof_judgement_flg      ,
            packaging_status_date   ,
            qa_sampling             ,
            target_group            ,
            todo_code               ,
            total_package_accepted  ,
            total_package_offered   ,
            transcript_available    ,
            tolerance_amount ,
            transfered ,
            total_aid ,
            admstruct_id,
            admsegment_1 ,
            admsegment_2 ,
            admsegment_3 ,
            admsegment_4 ,
            admsegment_5 ,
            admsegment_6,
            admsegment_7,
            admsegment_8,
            admsegment_9,
            admsegment_10,
            admsegment_11,
            admsegment_12,
            admsegment_13,
            admsegment_14,
            admsegment_15,
            admsegment_16,
            admsegment_17,
            admsegment_18,
            admsegment_19,
            admsegment_20,
            packstruct_id,
            packsegment_1,
            packsegment_2,
            packsegment_3,
            packsegment_4,
            packsegment_5,
            packsegment_6,
            packsegment_7,
            packsegment_8,
            packsegment_9,
            packsegment_10,
            packsegment_11,
            packsegment_12,
            packsegment_13,
            packsegment_14,
            packsegment_15,
            packsegment_16,
            packsegment_17,
            packsegment_18,
            packsegment_19,
            packsegment_20,
            miscstruct_id ,
            miscsegment_1,
            miscsegment_2 ,
            miscsegment_3 ,
            miscsegment_4,
            miscsegment_5,
            miscsegment_6,
            miscsegment_7,
            miscsegment_8,
            miscsegment_9,
            miscsegment_10,
            miscsegment_11,
            miscsegment_12,
            miscsegment_13,
            miscsegment_14,
            miscsegment_15,
            miscsegment_16,
            miscsegment_17,
            miscsegment_18,
            miscsegment_19,
            miscsegment_20,
            request_id,
            program_application_id,
            program_id            ,
            program_update_date,
            manual_disb_hold,
            pell_alt_expense,
            assoc_org_num ,      --Modified(added this attribute) by ugummall on 25-SEP-2003 w.r.t FA 126 - Multiple FA Offices
            award_fmly_contribution_type,
            isir_locked_by,
	    adnl_unsub_loan_elig_flag,
            lock_awd_flag,
            lock_coa_flag
    FROM   igf_ap_fa_base_rec_all FA
    WHERE  FA.base_id = cp_base_id;

    g_baseid_exists c_baseid_exists%ROWTYPE;


  PROCEDURE lg_make_active_isir ( errbuf          OUT NOCOPY VARCHAR2,
                                  retcode         OUT NOCOPY NUMBER,
                                  p_award_year    IN         VARCHAR2,
                                  p_batch_id      IN         NUMBER,
                                  p_del_ind       IN         VARCHAR2,
                                  p_upd_ind       IN         VARCHAR2)
    IS
    /*
    ||  Created By : bkkumar
    ||  Created On : 26-MAY-2003
    ||  Purpose : Main process makes the ISIR records active based on the data in the
    ||            Legacy Make Active ISIR Interface Table .
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
	||  tsailaja		  13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
    ||  (reverse chronological order - newest change first)
    */
    l_proc_item_str            VARCHAR2(50) := NULL;
    l_message_str              VARCHAR2(800) := NULL;
    l_terminate_flag           BOOLEAN := FALSE;
    l_error_flag               BOOLEAN := FALSE;
    l_error                    VARCHAR2(80);
    lv_row_id                  VARCHAR2(80) := NULL;
    lv_person_id               igs_pe_hz_parties.party_id%TYPE := NULL;
    lv_base_id                 igf_ap_fa_base_rec_all.base_id%TYPE := NULL;
    l_person_skip_flag         BOOLEAN  := FALSE;
    l_success_record_cnt       NUMBER := 0;
    l_error_record_cnt         NUMBER := 0;
    l_todo_flag                BOOLEAN := FALSE;
    l_chk_profile              VARCHAR2(1) := 'N';
    l_chk_batch                VARCHAR2(1) := 'N';
    l_index                    NUMBER := 1;
    l_total_record_cnt         NUMBER := 0;
    l_process_flag             BOOLEAN := FALSE;
    l_debug_str                VARCHAR2(800) := NULL;

    l_cal_type   igf_ap_fa_base_rec_all.ci_cal_type%TYPE ;
    l_seq_number igf_ap_fa_base_rec_all.ci_sequence_number%TYPE;



    -- Cursor for getting the context award year details
    CURSOR c_get_status(cp_cal_type VARCHAR2,
                        cp_seq_number NUMBER)
    IS
    SELECT sys_award_year,
           batch_year,
           award_year_status_code
    FROM   igf_ap_batch_aw_map
    WHERE  ci_cal_type = cp_cal_type
    AND    ci_sequence_number = cp_seq_number;

    l_get_status c_get_status%ROWTYPE;

    CURSOR c_get_alternate_code(cp_cal_type VARCHAR2,
                                cp_seq_number NUMBER)
    IS
    SELECT alternate_code
    FROM   igs_ca_inst
    WHERE  cal_type = cp_cal_type
    AND    sequence_number = cp_seq_number;

    l_get_alternate_code  c_get_alternate_code%ROWTYPE;

    CURSOR c_get_records(cp_alternate_code VARCHAR2,
                         cp_batch_id NUMBER)
    IS
    SELECT  A.batch_num batch_num,
            A.actint_id actint_id,
            A.ci_alternate_code ci_alternate_code,
            A.person_number person_number,
            A.transaction_num_txt transaction_num_txt,
            A.batch_year_num batch_year_num,
            A.import_status_type import_status_type,
            A.ROWID ROW_ID
    FROM    igf_ap_li_isir_act_ints A
    WHERE   A.ci_alternate_code = cp_alternate_code
    AND     A.batch_num = cp_batch_id
    AND     A.import_status_type IN ('U','R')
    ORDER BY A.person_number;


    l_get_records c_get_records%ROWTYPE;

    -- check whether that isir record came through legacy
    CURSOR c_chk_isir_rec_legacy(cp_base_id NUMBER,
                                 cp_batch_year NUMBER )
    IS
    SELECT ISIR.isir_id isir_id
    FROM   igf_ap_isir_matched ISIR
    WHERE  ISIR.base_id = cp_base_id
    AND    ISIR.batch_year = cp_batch_year
    AND    NVL(ISIR.legacy_record_flag,'X') <> 'Y'
    AND    rownum = 1;

    l_chk_isir_rec_legacy  c_chk_isir_rec_legacy%ROWTYPE;

    CURSOR c_get_dup_person(cp_alternate_code VARCHAR2,
                            cp_batch_id       NUMBER)
    IS
    SELECT person_number
    FROM   igf_ap_li_isir_act_ints
    WHERE  ci_alternate_code = cp_alternate_code
    AND    batch_num = cp_batch_id
    AND    import_status_type IN ('U','R')
    GROUP BY person_number
    HAVING COUNT(person_number) > 1;

    l_get_dup_person  c_get_dup_person%ROWTYPE;
    CURSOR c_get_isir_rec(cp_base_id       NUMBER,
                          cp_batch_year      NUMBER,
                          cp_transaction_num VARCHAR2,
                          cp_rec_type  VARCHAR2)
    IS
    SELECT  ISIR.row_id row_id,
            ISIR.isir_id isir_id,
            ISIR.base_id base_id,
            ISIR.batch_year batch_year,
            ISIR.transaction_num transaction_num,
            ISIR.current_ssn current_ssn,
            ISIR.ssn_name_change ssn_name_change,
            ISIR.original_ssn original_ssn,
            ISIR.orig_name_id orig_name_id,
            ISIR.last_name last_name,
            ISIR.first_name first_name,
            ISIR.middle_initial middle_initial,
            ISIR.perm_mail_add perm_mail_add,
            ISIR.perm_city perm_city,
            ISIR.perm_state perm_state,
            ISIR.perm_zip_code perm_zip_code,
            ISIR.date_of_birth date_of_birth,
            ISIR.phone_number phone_number,
            ISIR.driver_license_number driver_license_number,
            ISIR.driver_license_state driver_license_state,
            ISIR.citizenship_status citizenship_status,
            ISIR.alien_reg_number alien_reg_number,
            ISIR.s_marital_status s_marital_status,
            ISIR.s_marital_status_date s_marital_status_date,
            ISIR.summ_enrl_status summ_enrl_status,
            ISIR.fall_enrl_status fall_enrl_status,
            ISIR.winter_enrl_status winter_enrl_status,
            ISIR.spring_enrl_status spring_enrl_status,
            ISIR.summ2_enrl_status summ2_enrl_status,
            ISIR.fathers_highest_edu_level fathers_highest_edu_level,
            ISIR.mothers_highest_edu_level mothers_highest_edu_level,
            ISIR.s_state_legal_residence s_state_legal_residence,
            ISIR.legal_residence_before_date legal_residence_before_date,
            ISIR.s_legal_resd_date s_legal_resd_date,
            ISIR.ss_r_u_male ss_r_u_male,
            ISIR.selective_service_reg selective_service_reg,
            ISIR.degree_certification degree_certification,
            ISIR.grade_level_in_college grade_level_in_college,
            ISIR.high_school_diploma_ged high_school_diploma_ged,
            ISIR.first_bachelor_deg_by_date first_bachelor_deg_by_date,
            ISIR.interest_in_loan interest_in_loan,
            ISIR.interest_in_stud_employment interest_in_stud_employment,
            ISIR.drug_offence_conviction drug_offence_conviction,
            ISIR.s_tax_return_status s_tax_return_status,
            ISIR.s_type_tax_return s_type_tax_return,
            ISIR.s_elig_1040ez s_elig_1040ez,
            ISIR.s_adjusted_gross_income s_adjusted_gross_income,
            ISIR.s_fed_taxes_paid s_fed_taxes_paid,
            ISIR.s_exemptions s_exemptions,
            ISIR.s_income_from_work s_income_from_work,
            ISIR.spouse_income_from_work spouse_income_from_work,
            ISIR.s_toa_amt_from_wsa s_toa_amt_from_wsa,
            ISIR.s_toa_amt_from_wsb s_toa_amt_from_wsb,
            ISIR.s_toa_amt_from_wsc s_toa_amt_from_wsc,
            ISIR.s_investment_networth s_investment_networth,
            ISIR.s_busi_farm_networth s_busi_farm_networth,
            ISIR.s_cash_savings s_cash_savings,
            ISIR.va_months va_months,
            ISIR.va_amount va_amount,
            ISIR.stud_dob_before_date stud_dob_before_date,
            ISIR.deg_beyond_bachelor deg_beyond_bachelor,
            ISIR.s_married s_married,
            ISIR.s_have_children s_have_children,
            ISIR.legal_dependents legal_dependents,
            ISIR.orphan_ward_of_court orphan_ward_of_court,
            ISIR.s_veteran s_veteran,
            ISIR.p_marital_status p_marital_status,
            ISIR.father_ssn father_ssn,
            ISIR.f_last_name f_last_name,
            ISIR.mother_ssn mother_ssn,
            ISIR.m_last_name m_last_name,
            ISIR.p_num_family_member p_num_family_member,
            ISIR.p_num_in_college p_num_in_college,
            ISIR.p_state_legal_residence p_state_legal_residence,
            ISIR.p_state_legal_res_before_dt p_state_legal_res_before_dt,
            ISIR.p_legal_res_date p_legal_res_date,
            ISIR.age_older_parent age_older_parent,
            ISIR.p_tax_return_status p_tax_return_status,
            ISIR.p_type_tax_return p_type_tax_return,
            ISIR.p_elig_1040aez p_elig_1040aez,
            ISIR.p_adjusted_gross_income p_adjusted_gross_income,
            ISIR.p_taxes_paid p_taxes_paid,
            ISIR.p_exemptions p_exemptions,
            ISIR.f_income_work f_income_work,
            ISIR.m_income_work m_income_work,
            ISIR.p_income_wsa p_income_wsa,
            ISIR.p_income_wsb p_income_wsb,
            ISIR.p_income_wsc p_income_wsc,
            ISIR.p_investment_networth p_investment_networth,
            ISIR.p_business_networth p_business_networth,
            ISIR.p_cash_saving p_cash_saving,
            ISIR.s_num_family_members s_num_family_members,
            ISIR.s_num_in_college s_num_in_college,
            ISIR.first_college first_college,
            ISIR.first_house_plan first_house_plan,
            ISIR.second_college second_college,
            ISIR.second_house_plan second_house_plan,
            ISIR.third_college third_college,
            ISIR.third_house_plan third_house_plan,
            ISIR.fourth_college fourth_college,
            ISIR.fourth_house_plan fourth_house_plan,
            ISIR.fifth_college fifth_college,
            ISIR.fifth_house_plan fifth_house_plan,
            ISIR.sixth_college sixth_college,
            ISIR.sixth_house_plan sixth_house_plan,
            ISIR.date_app_completed date_app_completed,
            ISIR.signed_by signed_by,
            ISIR.preparer_ssn preparer_ssn,
            ISIR.preparer_emp_id_number preparer_emp_id_number,
            ISIR.preparer_sign preparer_sign,
            ISIR.transaction_receipt_date transaction_receipt_date,
            ISIR.dependency_override_ind dependency_override_ind,
            ISIR.faa_fedral_schl_code faa_fedral_schl_code,
            ISIR.faa_adjustment faa_adjustment,
            ISIR.input_record_type input_record_type,
            ISIR.serial_number serial_number,
            ISIR.batch_number batch_number,
            ISIR.early_analysis_flag early_analysis_flag,
            ISIR.app_entry_source_code app_entry_source_code,
            ISIR.eti_destination_code eti_destination_code,
            ISIR.reject_override_b reject_override_b,
            ISIR.reject_override_n reject_override_n,
            ISIR.reject_override_w reject_override_w,
            ISIR.assum_override_1 assum_override_1,
            ISIR.assum_override_2 assum_override_2,
            ISIR.assum_override_3 assum_override_3,
            ISIR.assum_override_4 assum_override_4,
            ISIR.assum_override_5 assum_override_5,
            ISIR.assum_override_6 assum_override_6,
            ISIR.dependency_status dependency_status,
            ISIR.s_email_address s_email_address,
            ISIR.nslds_reason_code nslds_reason_code,
            ISIR.app_receipt_date app_receipt_date,
            ISIR.processed_rec_type processed_rec_type,
            ISIR.hist_correction_for_tran_id hist_correction_for_tran_id,
            ISIR.system_generated_indicator system_generated_indicator,
            ISIR.dup_request_indicator dup_request_indicator,
            ISIR.source_of_correction source_of_correction,
            ISIR.p_cal_tax_status p_cal_tax_status,
            ISIR.s_cal_tax_status s_cal_tax_status,
            ISIR.graduate_flag graduate_flag,
            ISIR.auto_zero_efc auto_zero_efc,
            ISIR.efc_change_flag efc_change_flag,
            ISIR.sarc_flag sarc_flag,
            ISIR.simplified_need_test simplified_need_test,
            ISIR.reject_reason_codes reject_reason_codes,
            ISIR.select_service_match_flag select_service_match_flag,
            ISIR.select_service_reg_flag select_service_reg_flag,
            ISIR.ins_match_flag ins_match_flag,
            ISIR.ins_verification_number ins_verification_number,
            ISIR.sec_ins_match_flag sec_ins_match_flag,
            ISIR.sec_ins_ver_number sec_ins_ver_number,
            ISIR.ssn_match_flag ssn_match_flag,
            ISIR.ssa_citizenship_flag ssa_citizenship_flag,
            ISIR.ssn_date_of_death ssn_date_of_death,
            ISIR.nslds_match_flag nslds_match_flag,
            ISIR.va_match_flag va_match_flag,
            ISIR.prisoner_match prisoner_match,
            ISIR.verification_flag verification_flag,
            ISIR.subsequent_app_flag subsequent_app_flag,
            ISIR.app_source_site_code app_source_site_code,
            ISIR.tran_source_site_code tran_source_site_code,
            ISIR.drn drn,
            ISIR.tran_process_date tran_process_date,
            ISIR.correction_flags correction_flags,
            ISIR.computer_batch_number computer_batch_number,
            ISIR.highlight_flags highlight_flags,
            ISIR.paid_efc paid_efc,
            ISIR.primary_efc primary_efc,
            ISIR.secondary_efc secondary_efc,
            ISIR.fed_pell_grant_efc_type fed_pell_grant_efc_type,
            ISIR.primary_efc_type primary_efc_type,
            ISIR.sec_efc_type sec_efc_type,
            ISIR.primary_alternate_month_1 primary_alternate_month_1,
            ISIR.primary_alternate_month_2 primary_alternate_month_2,
            ISIR.primary_alternate_month_3 primary_alternate_month_3,
            ISIR.primary_alternate_month_4 primary_alternate_month_4,
            ISIR.primary_alternate_month_5 primary_alternate_month_5,
            ISIR.primary_alternate_month_6 primary_alternate_month_6,
            ISIR.primary_alternate_month_7 primary_alternate_month_7,
            ISIR.primary_alternate_month_8 primary_alternate_month_8,
            ISIR.primary_alternate_month_10 primary_alternate_month_10,
            ISIR.primary_alternate_month_11 primary_alternate_month_11,
            ISIR.primary_alternate_month_12 primary_alternate_month_12,
            ISIR.sec_alternate_month_1 sec_alternate_month_1,
            ISIR.sec_alternate_month_2 sec_alternate_month_2,
            ISIR.sec_alternate_month_3 sec_alternate_month_3,
            ISIR.sec_alternate_month_4 sec_alternate_month_4,
            ISIR.sec_alternate_month_5 sec_alternate_month_5,
            ISIR.sec_alternate_month_6 sec_alternate_month_6,
            ISIR.sec_alternate_month_7 sec_alternate_month_7,
            ISIR.sec_alternate_month_8 sec_alternate_month_8,
            ISIR.sec_alternate_month_10 sec_alternate_month_10,
            ISIR.sec_alternate_month_11 sec_alternate_month_11,
            ISIR.sec_alternate_month_12 sec_alternate_month_12,
            ISIR.total_income total_income,
            ISIR.allow_total_income allow_total_income,
            ISIR.state_tax_allow state_tax_allow,
            ISIR.employment_allow employment_allow,
            ISIR.income_protection_allow income_protection_allow,
            ISIR.available_income available_income,
            ISIR.contribution_from_ai contribution_from_ai,
            ISIR.discretionary_networth discretionary_networth,
            ISIR.efc_networth efc_networth,
            ISIR.asset_protect_allow asset_protect_allow,
            ISIR.parents_cont_from_assets parents_cont_from_assets,
            ISIR.adjusted_available_income adjusted_available_income,
            ISIR.total_student_contribution total_student_contribution,
            ISIR.total_parent_contribution total_parent_contribution,
            ISIR.parents_contribution parents_contribution,
            ISIR.student_total_income student_total_income,
            ISIR.sati sati,
            ISIR.sic sic,
            ISIR.sdnw sdnw,
            ISIR.sca sca,
            ISIR.fti fti,
            ISIR.secti secti,
            ISIR.secati secati,
            ISIR.secstx secstx,
            ISIR.secea secea,
            ISIR.secipa secipa,
            ISIR.secai secai,
            ISIR.seccai seccai,
            ISIR.secdnw secdnw,
            ISIR.secnw secnw,
            ISIR.secapa secapa,
            ISIR.secpca secpca,
            ISIR.secaai secaai,
            ISIR.sectsc sectsc,
            ISIR.sectpc sectpc,
            ISIR.secpc secpc,
            ISIR.secsti secsti,
            ISIR.secsati secsati,
            ISIR.secsic secsic,
            ISIR.secsdnw secsdnw,
            ISIR.secsca secsca,
            ISIR.secfti secfti,
            ISIR.a_citizenship a_citizenship,
            ISIR.a_student_marital_status a_student_marital_status,
            ISIR.a_student_agi a_student_agi,
            ISIR.a_s_us_tax_paid a_s_us_tax_paid,
            ISIR.a_s_income_work a_s_income_work,
            ISIR.a_spouse_income_work a_spouse_income_work,
            ISIR.a_s_total_wsc a_s_total_wsc,
            ISIR.a_date_of_birth a_date_of_birth,
            ISIR.a_student_married a_student_married,
            ISIR.a_have_children a_have_children,
            ISIR.a_s_have_dependents a_s_have_dependents,
            ISIR.a_va_status a_va_status,
            ISIR.a_s_num_in_family a_s_num_in_family,
            ISIR.a_s_num_in_college a_s_num_in_college,
            ISIR.a_p_marital_status a_p_marital_status,
            ISIR.a_father_ssn a_father_ssn,
            ISIR.a_mother_ssn a_mother_ssn,
            ISIR.a_parents_num_family a_parents_num_family,
            ISIR.a_parents_num_college a_parents_num_college,
            ISIR.a_parents_agi a_parents_agi,
            ISIR.a_p_us_tax_paid a_p_us_tax_paid,
            ISIR.a_f_work_income a_f_work_income,
            ISIR.a_m_work_income a_m_work_income,
            ISIR.a_p_total_wsc a_p_total_wsc,
            ISIR.comment_codes comment_codes,
            ISIR.sar_ack_comm_code sar_ack_comm_code,
            ISIR.pell_grant_elig_flag pell_grant_elig_flag,
            ISIR.reprocess_reason_code reprocess_reason_code,
            ISIR.duplicate_date duplicate_date,
            ISIR.isir_transaction_type isir_transaction_type,
            ISIR.fedral_schl_code_indicator fedral_schl_code_indicator,
            ISIR.multi_school_code_flags multi_school_code_flags,
            ISIR.dup_ssn_indicator dup_ssn_indicator,
            ISIR.payment_isir payment_isir,
            ISIR.receipt_status receipt_status,
            ISIR.isir_receipt_completed isir_receipt_completed,
            ISIR.system_record_type system_record_type,
            ISIR.created_by created_by,
            ISIR.creation_date creation_date,
            ISIR.last_updated_by last_updated_by,
            ISIR.last_update_date last_update_date,
            ISIR.last_update_login last_update_login,
            ISIR.request_id request_id,
            ISIR.program_application_id program_application_id,
            ISIR.program_id program_id,
            ISIR.program_update_date program_update_date,
            ISIR.org_id org_id,
            ISIR.verif_track_flag verif_track_flag,
            ISIR.active_isir active_isir,
            ISIR.fafsa_data_verify_flags fafsa_data_verify_flags,
            ISIR.reject_override_a reject_override_a,
            ISIR.reject_override_c reject_override_c,
            ISIR.parent_marital_status_date parent_marital_status_date,
            ISIR.legacy_record_flag legacy_record_flag,
            ISIR.father_first_name_initial_txt,
            ISIR.father_step_father_birth_date,
            ISIR.mother_first_name_initial_txt,
            ISIR.mother_step_mother_birth_date,
            ISIR.parents_email_address_txt,
            ISIR.address_change_type,
            ISIR.cps_pushed_isir_flag,
            ISIR.electronic_transaction_type,
            ISIR.sar_c_change_type,
            ISIR.father_ssn_match_type,
            ISIR.mother_ssn_match_type,
            ISIR.reject_override_g_flag,
            ISIR.dhs_verification_num_txt,
            ISIR.data_file_name_txt,
            ISIR.message_class_txt,
            reject_override_3_flag,
            ISIR.reject_override_12_flag,
            ISIR.reject_override_j_flag,
            ISIR.reject_override_k_flag,
            ISIR.rejected_status_change_flag,
            ISIR.verification_selection_flag
    FROM   igf_ap_isir_matched ISIR

    WHERE  ISIR.base_id = cp_base_id
    AND    ISIR.batch_year = cp_batch_year
    AND    ISIR.transaction_num = cp_transaction_num
    AND    ISIR.system_record_type = cp_rec_type;


    l_get_isir_rec  c_get_isir_rec%ROWTYPE;

    CURSOR c_old_act_isir(cp_base_id NUMBER,
                          cp_rec_type VARCHAR2)
    IS
    SELECT  ISIR.row_id row_id,
            ISIR.isir_id isir_id,
            ISIR.base_id base_id,
            ISIR.batch_year batch_year,
            ISIR.transaction_num transaction_num,
            ISIR.current_ssn current_ssn,
            ISIR.ssn_name_change ssn_name_change,
            ISIR.original_ssn original_ssn,
            ISIR.orig_name_id orig_name_id,
            ISIR.last_name last_name,
            ISIR.first_name first_name,
            ISIR.middle_initial middle_initial,
            ISIR.perm_mail_add perm_mail_add,
            ISIR.perm_city perm_city,
            ISIR.perm_state perm_state,
            ISIR.perm_zip_code perm_zip_code,
            ISIR.date_of_birth date_of_birth,
            ISIR.phone_number phone_number,
            ISIR.driver_license_number driver_license_number,
            ISIR.driver_license_state driver_license_state,
            ISIR.citizenship_status citizenship_status,
            ISIR.alien_reg_number alien_reg_number,
            ISIR.s_marital_status s_marital_status,
            ISIR.s_marital_status_date s_marital_status_date,
            ISIR.summ_enrl_status summ_enrl_status,
            ISIR.fall_enrl_status fall_enrl_status,
            ISIR.winter_enrl_status winter_enrl_status,
            ISIR.spring_enrl_status spring_enrl_status,
            ISIR.summ2_enrl_status summ2_enrl_status,
            ISIR.fathers_highest_edu_level fathers_highest_edu_level,
            ISIR.mothers_highest_edu_level mothers_highest_edu_level,
            ISIR.s_state_legal_residence s_state_legal_residence,
            ISIR.legal_residence_before_date legal_residence_before_date,
            ISIR.s_legal_resd_date s_legal_resd_date,
            ISIR.ss_r_u_male ss_r_u_male,
            ISIR.selective_service_reg selective_service_reg,
            ISIR.degree_certification degree_certification,
            ISIR.grade_level_in_college grade_level_in_college,
            ISIR.high_school_diploma_ged high_school_diploma_ged,
            ISIR.first_bachelor_deg_by_date first_bachelor_deg_by_date,
            ISIR.interest_in_loan interest_in_loan,
            ISIR.interest_in_stud_employment interest_in_stud_employment,
            ISIR.drug_offence_conviction drug_offence_conviction,
            ISIR.s_tax_return_status s_tax_return_status,
            ISIR.s_type_tax_return s_type_tax_return,
            ISIR.s_elig_1040ez s_elig_1040ez,
            ISIR.s_adjusted_gross_income s_adjusted_gross_income,
            ISIR.s_fed_taxes_paid s_fed_taxes_paid,
            ISIR.s_exemptions s_exemptions,
            ISIR.s_income_from_work s_income_from_work,
            ISIR.spouse_income_from_work spouse_income_from_work,
            ISIR.s_toa_amt_from_wsa s_toa_amt_from_wsa,
            ISIR.s_toa_amt_from_wsb s_toa_amt_from_wsb,
            ISIR.s_toa_amt_from_wsc s_toa_amt_from_wsc,
            ISIR.s_investment_networth s_investment_networth,
            ISIR.s_busi_farm_networth s_busi_farm_networth,
            ISIR.s_cash_savings s_cash_savings,
            ISIR.va_months va_months,
            ISIR.va_amount va_amount,
            ISIR.stud_dob_before_date stud_dob_before_date,
            ISIR.deg_beyond_bachelor deg_beyond_bachelor,
            ISIR.s_married s_married,
            ISIR.s_have_children s_have_children,
            ISIR.legal_dependents legal_dependents,
            ISIR.orphan_ward_of_court orphan_ward_of_court,
            ISIR.s_veteran s_veteran,
            ISIR.p_marital_status p_marital_status,
            ISIR.father_ssn father_ssn,
            ISIR.f_last_name f_last_name,
            ISIR.mother_ssn mother_ssn,
            ISIR.m_last_name m_last_name,
            ISIR.p_num_family_member p_num_family_member,
            ISIR.p_num_in_college p_num_in_college,
            ISIR.p_state_legal_residence p_state_legal_residence,
            ISIR.p_state_legal_res_before_dt p_state_legal_res_before_dt,
            ISIR.p_legal_res_date p_legal_res_date,
            ISIR.age_older_parent age_older_parent,
            ISIR.p_tax_return_status p_tax_return_status,
            ISIR.p_type_tax_return p_type_tax_return,
            ISIR.p_elig_1040aez p_elig_1040aez,
            ISIR.p_adjusted_gross_income p_adjusted_gross_income,
            ISIR.p_taxes_paid p_taxes_paid,
            ISIR.p_exemptions p_exemptions,
            ISIR.f_income_work f_income_work,
            ISIR.m_income_work m_income_work,
            ISIR.p_income_wsa p_income_wsa,
            ISIR.p_income_wsb p_income_wsb,
            ISIR.p_income_wsc p_income_wsc,
            ISIR.p_investment_networth p_investment_networth,
            ISIR.p_business_networth p_business_networth,
            ISIR.p_cash_saving p_cash_saving,
            ISIR.s_num_family_members s_num_family_members,
            ISIR.s_num_in_college s_num_in_college,
            ISIR.first_college first_college,
            ISIR.first_house_plan first_house_plan,
            ISIR.second_college second_college,
            ISIR.second_house_plan second_house_plan,
            ISIR.third_college third_college,
            ISIR.third_house_plan third_house_plan,
            ISIR.fourth_college fourth_college,
            ISIR.fourth_house_plan fourth_house_plan,
            ISIR.fifth_college fifth_college,
            ISIR.fifth_house_plan fifth_house_plan,
            ISIR.sixth_college sixth_college,
            ISIR.sixth_house_plan sixth_house_plan,
            ISIR.date_app_completed date_app_completed,
            ISIR.signed_by signed_by,
            ISIR.preparer_ssn preparer_ssn,
            ISIR.preparer_emp_id_number preparer_emp_id_number,
            ISIR.preparer_sign preparer_sign,
            ISIR.transaction_receipt_date transaction_receipt_date,
            ISIR.dependency_override_ind dependency_override_ind,
            ISIR.faa_fedral_schl_code faa_fedral_schl_code,
            ISIR.faa_adjustment faa_adjustment,
            ISIR.input_record_type input_record_type,
            ISIR.serial_number serial_number,
            ISIR.batch_number batch_number,
            ISIR.early_analysis_flag early_analysis_flag,
            ISIR.app_entry_source_code app_entry_source_code,
            ISIR.eti_destination_code eti_destination_code,
            ISIR.reject_override_b reject_override_b,
            ISIR.reject_override_n reject_override_n,
            ISIR.reject_override_w reject_override_w,
            ISIR.assum_override_1 assum_override_1,
            ISIR.assum_override_2 assum_override_2,
            ISIR.assum_override_3 assum_override_3,
            ISIR.assum_override_4 assum_override_4,
            ISIR.assum_override_5 assum_override_5,
            ISIR.assum_override_6 assum_override_6,
            ISIR.dependency_status dependency_status,
            ISIR.s_email_address s_email_address,
            ISIR.nslds_reason_code nslds_reason_code,
            ISIR.app_receipt_date app_receipt_date,
            ISIR.processed_rec_type processed_rec_type,
            ISIR.hist_correction_for_tran_id hist_correction_for_tran_id,
            ISIR.system_generated_indicator system_generated_indicator,
            ISIR.dup_request_indicator dup_request_indicator,
            ISIR.source_of_correction source_of_correction,
            ISIR.p_cal_tax_status p_cal_tax_status,
            ISIR.s_cal_tax_status s_cal_tax_status,
            ISIR.graduate_flag graduate_flag,
            ISIR.auto_zero_efc auto_zero_efc,
            ISIR.efc_change_flag efc_change_flag,
            ISIR.sarc_flag sarc_flag,
            ISIR.simplified_need_test simplified_need_test,
            ISIR.reject_reason_codes reject_reason_codes,
            ISIR.select_service_match_flag select_service_match_flag,
            ISIR.select_service_reg_flag select_service_reg_flag,
            ISIR.ins_match_flag ins_match_flag,
            ISIR.ins_verification_number ins_verification_number,
            ISIR.sec_ins_match_flag sec_ins_match_flag,
            ISIR.sec_ins_ver_number sec_ins_ver_number,
            ISIR.ssn_match_flag ssn_match_flag,
            ISIR.ssa_citizenship_flag ssa_citizenship_flag,
            ISIR.ssn_date_of_death ssn_date_of_death,
            ISIR.nslds_match_flag nslds_match_flag,
            ISIR.va_match_flag va_match_flag,
            ISIR.prisoner_match prisoner_match,
            ISIR.verification_flag verification_flag,
            ISIR.subsequent_app_flag subsequent_app_flag,
            ISIR.app_source_site_code app_source_site_code,
            ISIR.tran_source_site_code tran_source_site_code,
            ISIR.drn drn,
            ISIR.tran_process_date tran_process_date,
            ISIR.correction_flags correction_flags,
            ISIR.computer_batch_number computer_batch_number,
            ISIR.highlight_flags highlight_flags,
            ISIR.paid_efc paid_efc,
            ISIR.primary_efc primary_efc,
            ISIR.secondary_efc secondary_efc,
            ISIR.fed_pell_grant_efc_type fed_pell_grant_efc_type,
            ISIR.primary_efc_type primary_efc_type,
            ISIR.sec_efc_type sec_efc_type,
            ISIR.primary_alternate_month_1 primary_alternate_month_1,
            ISIR.primary_alternate_month_2 primary_alternate_month_2,
            ISIR.primary_alternate_month_3 primary_alternate_month_3,
            ISIR.primary_alternate_month_4 primary_alternate_month_4,
            ISIR.primary_alternate_month_5 primary_alternate_month_5,
            ISIR.primary_alternate_month_6 primary_alternate_month_6,
            ISIR.primary_alternate_month_7 primary_alternate_month_7,
            ISIR.primary_alternate_month_8 primary_alternate_month_8,
            ISIR.primary_alternate_month_10 primary_alternate_month_10,
            ISIR.primary_alternate_month_11 primary_alternate_month_11,
            ISIR.primary_alternate_month_12 primary_alternate_month_12,
            ISIR.sec_alternate_month_1 sec_alternate_month_1,
            ISIR.sec_alternate_month_2 sec_alternate_month_2,
            ISIR.sec_alternate_month_3 sec_alternate_month_3,
            ISIR.sec_alternate_month_4 sec_alternate_month_4,
            ISIR.sec_alternate_month_5 sec_alternate_month_5,
            ISIR.sec_alternate_month_6 sec_alternate_month_6,
            ISIR.sec_alternate_month_7 sec_alternate_month_7,
            ISIR.sec_alternate_month_8 sec_alternate_month_8,
            ISIR.sec_alternate_month_10 sec_alternate_month_10,
            ISIR.sec_alternate_month_11 sec_alternate_month_11,
            ISIR.sec_alternate_month_12 sec_alternate_month_12,
            ISIR.total_income total_income,
            ISIR.allow_total_income allow_total_income,
            ISIR.state_tax_allow state_tax_allow,
            ISIR.employment_allow employment_allow,
            ISIR.income_protection_allow income_protection_allow,
            ISIR.available_income available_income,
            ISIR.contribution_from_ai contribution_from_ai,
            ISIR.discretionary_networth discretionary_networth,
            ISIR.efc_networth efc_networth,
            ISIR.asset_protect_allow asset_protect_allow,
            ISIR.parents_cont_from_assets parents_cont_from_assets,
            ISIR.adjusted_available_income adjusted_available_income,
            ISIR.total_student_contribution total_student_contribution,
            ISIR.total_parent_contribution total_parent_contribution,
            ISIR.parents_contribution parents_contribution,
            ISIR.student_total_income student_total_income,
            ISIR.sati sati,
            ISIR.sic sic,
            ISIR.sdnw sdnw,
            ISIR.sca sca,
            ISIR.fti fti,
            ISIR.secti secti,
            ISIR.secati secati,
            ISIR.secstx secstx,
            ISIR.secea secea,
            ISIR.secipa secipa,
            ISIR.secai secai,
            ISIR.seccai seccai,
            ISIR.secdnw secdnw,
            ISIR.secnw secnw,
            ISIR.secapa secapa,
            ISIR.secpca secpca,
            ISIR.secaai secaai,
            ISIR.sectsc sectsc,
            ISIR.sectpc sectpc,
            ISIR.secpc secpc,
            ISIR.secsti secsti,
            ISIR.secsati secsati,
            ISIR.secsic secsic,
            ISIR.secsdnw secsdnw,
            ISIR.secsca secsca,
            ISIR.secfti secfti,
            ISIR.a_citizenship a_citizenship,
            ISIR.a_student_marital_status a_student_marital_status,
            ISIR.a_student_agi a_student_agi,
            ISIR.a_s_us_tax_paid a_s_us_tax_paid,
            ISIR.a_s_income_work a_s_income_work,
            ISIR.a_spouse_income_work a_spouse_income_work,
            ISIR.a_s_total_wsc a_s_total_wsc,
            ISIR.a_date_of_birth a_date_of_birth,
            ISIR.a_student_married a_student_married,
            ISIR.a_have_children a_have_children,
            ISIR.a_s_have_dependents a_s_have_dependents,
            ISIR.a_va_status a_va_status,
            ISIR.a_s_num_in_family a_s_num_in_family,
            ISIR.a_s_num_in_college a_s_num_in_college,
            ISIR.a_p_marital_status a_p_marital_status,
            ISIR.a_father_ssn a_father_ssn,
            ISIR.a_mother_ssn a_mother_ssn,
            ISIR.a_parents_num_family a_parents_num_family,
            ISIR.a_parents_num_college a_parents_num_college,
            ISIR.a_parents_agi a_parents_agi,
            ISIR.a_p_us_tax_paid a_p_us_tax_paid,
            ISIR.a_f_work_income a_f_work_income,
            ISIR.a_m_work_income a_m_work_income,
            ISIR.a_p_total_wsc a_p_total_wsc,
            ISIR.comment_codes comment_codes,
            ISIR.sar_ack_comm_code sar_ack_comm_code,
            ISIR.pell_grant_elig_flag pell_grant_elig_flag,
            ISIR.reprocess_reason_code reprocess_reason_code,
            ISIR.duplicate_date duplicate_date,
            ISIR.isir_transaction_type isir_transaction_type,
            ISIR.fedral_schl_code_indicator fedral_schl_code_indicator,
            ISIR.multi_school_code_flags multi_school_code_flags,
            ISIR.dup_ssn_indicator dup_ssn_indicator,
            ISIR.payment_isir payment_isir,
            ISIR.receipt_status receipt_status,
            ISIR.isir_receipt_completed isir_receipt_completed,
            ISIR.system_record_type system_record_type,
            ISIR.created_by created_by,
            ISIR.creation_date creation_date,
            ISIR.last_updated_by last_updated_by,
            ISIR.last_update_date last_update_date,
            ISIR.last_update_login last_update_login,
            ISIR.request_id request_id,
            ISIR.program_application_id program_application_id,
            ISIR.program_id program_id,
            ISIR.program_update_date program_update_date,
            ISIR.org_id org_id,
            ISIR.verif_track_flag verif_track_flag,
            ISIR.active_isir active_isir,
            ISIR.fafsa_data_verify_flags fafsa_data_verify_flags,
            ISIR.reject_override_a reject_override_a,
            ISIR.reject_override_c reject_override_c,
            ISIR.parent_marital_status_date parent_marital_status_date,
            ISIR.legacy_record_flag legacy_record_flag,
            ISIR.father_first_name_initial_txt,
            ISIR.father_step_father_birth_date,
            ISIR.mother_first_name_initial_txt,
            ISIR.mother_step_mother_birth_date,
            ISIR.parents_email_address_txt,
            ISIR.address_change_type,
            ISIR.cps_pushed_isir_flag,
            ISIR.electronic_transaction_type,
            ISIR.sar_c_change_type,
            ISIR.father_ssn_match_type,
            ISIR.mother_ssn_match_type,
            ISIR.reject_override_g_flag,
            ISIR.dhs_verification_num_txt,
            ISIR.data_file_name_txt,
            ISIR.message_class_txt,
            reject_override_3_flag,
            ISIR.reject_override_12_flag,
            ISIR.reject_override_j_flag,
            ISIR.reject_override_k_flag,
            ISIR.rejected_status_change_flag,
            ISIR.verification_selection_flag
    FROM   igf_ap_isir_matched ISIR
    WHERE  ISIR.base_id = cp_base_id
    AND    ISIR.active_isir = 'Y'
    AND    ISIR.system_record_type = cp_rec_type;

    l_old_act_isir  c_old_act_isir%ROWTYPE;

  BEGIN
	igf_aw_gen.set_org_id(NULL);
    errbuf             := NULL;
    retcode            := 0;
    l_cal_type         := LTRIM(RTRIM(SUBSTR(p_award_year,1,10)));
    l_seq_number       := TO_NUMBER(SUBSTR(p_award_year,11));

    l_error := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','ERROR');
    l_chk_profile := igf_ap_gen.check_profile;
    IF l_chk_profile = 'N' THEN
      fnd_message.set_name('IGF','IGF_AP_LGCY_PROC_NOT_RUN');
      fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
      RETURN;
    END IF;

    l_chk_batch := igf_ap_gen.check_batch(p_batch_id,'ISIR');
    IF l_chk_batch = 'N' THEN
      fnd_message.set_name('IGF','IGF_GR_BATCH_DOES_NOT_EXIST');
       add_log_table_process(NULL,l_error,fnd_message.get);
      l_terminate_flag := TRUE;
    END IF;
    -- this is to get the alternate code
    l_get_alternate_code := NULL;
    OPEN  c_get_alternate_code(l_cal_type,l_seq_number);
    FETCH c_get_alternate_code INTO l_get_alternate_code;
    CLOSE c_get_alternate_code;

    -- this is to check that the award year is valid or not
    l_get_status := NULL;
    OPEN  c_get_status(l_cal_type,l_seq_number);
    FETCH c_get_status INTO l_get_status;
    CLOSE c_get_status;

    IF l_get_status.award_year_status_code NOT IN ('O','LD') THEN
      fnd_message.set_name('IGF','IGF_AP_LG_INVALID_STAT');
      fnd_message.set_token('AWARD_STATUS',l_get_status.award_year_status_code);
      add_log_table_process(NULL,l_error,fnd_message.get);
      l_terminate_flag := TRUE;
    END IF;
    IF l_terminate_flag = TRUE THEN
      print_log_process(l_get_alternate_code.alternate_code,p_batch_id,p_del_ind);
      RETURN;
    END IF;

    OPEN c_get_dup_person(l_get_alternate_code.alternate_code,p_batch_id);
    LOOP
      FETCH c_get_dup_person INTO l_get_dup_person;
      EXIT WHEN c_get_dup_person%NOTFOUND;
      g_per_tab(l_index) := l_get_dup_person.person_number;
      l_index := l_index + 1;
    END LOOP;
    CLOSE c_get_dup_person;

    -- THE MAIN LOOP STARTS HERE FOR FETCHING THE RECORD FROM THE INTERFACE TABLE
    -- IF MORE THAN ISIR RECORD PER STUDENT IS ENTERED THEN THE PERSON IS TO BE SKIPPED ENTIRELY
    OPEN c_get_records(l_get_alternate_code.alternate_code,p_batch_id);
    LOOP
      BEGIN
      SAVEPOINT sp1;
      FETCH c_get_records INTO l_get_records;
      EXIT WHEN c_get_records%NOTFOUND OR c_get_records%NOTFOUND IS NULL;
       l_debug_str := 'Actint_id is:' || l_get_records.actint_id;
     -- here the check is there to see if the person number is repetitive so skip the person
      IF NOT check_dup_person(l_get_records.person_number) THEN
        lv_base_id := NULL;
        lv_person_id := NULL;
        igf_ap_gen.check_person(l_get_records.person_number,l_cal_type,l_seq_number,lv_person_id,lv_base_id);
        IF lv_person_id IS NULL THEN
           fnd_message.set_name('IGF','IGF_AP_PE_NOT_EXIST');
           add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
           l_error_flag := TRUE;
        ELSE
          IF lv_base_id IS NULL THEN
            fnd_message.set_name('IGF','IGF_AP_FABASE_NOT_FOUND');
            add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
            l_error_flag := TRUE;
          ELSE
             l_debug_str := l_debug_str || ' Person and Base ID check passed';
          -- HERE THE CHK FOR THE BATCH YEAR WILL BE THERE
           IF l_get_records.batch_year_num <> NVL(l_get_status.batch_year,-1) THEN
               fnd_message.set_name('IGF','IGF_AP_AW_BATCH_NOT_EXISTS');
               add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
               l_error_flag := TRUE;
           ELSE
             g_baseid_exists := NULL;
             OPEN  c_baseid_exists(lv_base_id);
             FETCH c_baseid_exists INTO g_baseid_exists;
             CLOSE c_baseid_exists;
             l_chk_isir_rec_legacy := NULL;
             OPEN  c_chk_isir_rec_legacy(lv_base_id,l_get_records.batch_year_num);
             FETCH c_chk_isir_rec_legacy INTO l_chk_isir_rec_legacy;
             CLOSE c_chk_isir_rec_legacy;
             IF l_chk_isir_rec_legacy.isir_id IS NOT NULL THEN
               fnd_message.set_name('IGF','IGF_AP_NON_LI_ISIR_EXISTS');
               add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
               l_error_flag := TRUE;
             ELSE -- THIS MEANS THE THERE IS ISIR IS IMPORTED BY LEGACY ONLY
                 l_debug_str := l_debug_str || ' Legacy ISIR check passed';
                 l_get_isir_rec := NULL;
                 OPEN  c_get_isir_rec(lv_base_id,l_get_records.batch_year_num,l_get_records.transaction_num_txt,'ORIGINAL');
                 FETCH c_get_isir_rec INTO l_get_isir_rec;
                 CLOSE c_get_isir_rec;
                 IF l_get_isir_rec.isir_id IS NULL THEN
                   fnd_message.set_name('IGF','IGF_AP_NO_ISIR_RECS_EXIST');
                   add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
                   l_error_flag := TRUE;
                 ELSE
                   l_debug_str := l_debug_str || ' ISIR record exists check passed';
                   IF l_get_isir_rec.primary_efc IS NULL THEN
                     fnd_message.set_name('IGF','IGF_AP_ISIR_INVALID_EFC');
                     add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
                     l_error_flag := TRUE;
                   ELSE
                      l_debug_str := l_debug_str || ' EFC check passed';
                     l_old_act_isir := NULL;
                     OPEN  c_old_act_isir(lv_base_id,'ORIGINAL');
                     FETCH c_old_act_isir INTO l_old_act_isir;
                     CLOSE c_old_act_isir;
                     IF l_old_act_isir.isir_id IS NOT NULL THEN
                       IF l_old_act_isir.isir_id <> l_get_isir_rec.isir_id THEN -- means that the current active ISIR is different from the new ISIR to be imported
                         IF p_upd_ind = 'Y' THEN
                            -- make the old as inactive and the current as the active ISIR
                            update_isir_rec(l_old_act_isir,'N');
                            l_process_flag := TRUE;
                         ELSE
                            fnd_message.set_name('IGF','IGF_AP_UPD_IND_NOT_SET');
                            add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
                            l_error_flag := TRUE;
                         END IF; -- update flag is not set
                       ELSE
                       fnd_message.set_name('IGF','IGF_AP_REC_ALREADY_ACT');
                       add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
                       l_error_flag := TRUE;
                       END IF;   --
                     ELSE  -- MEANS THE CURRENT ACTIVE ISIR DOES NOT EXISTS
                       l_process_flag := TRUE;
                     END IF;
                     l_debug_str := l_debug_str || ' Old ISIR check passed';
                     IF l_process_flag = TRUE THEN
                       update_isir_rec(l_get_isir_rec,'Y');
                       IF NVL(l_get_isir_rec.verification_flag,'X') = 'Y' THEN
                         update_fabase_rec_process('SELECTED');
                       ELSE
                         update_fabase_rec_process('NOTSELECTED');
                       END IF;
                       l_success_record_cnt := l_success_record_cnt + 1;
                     END IF; -- FOR THE PROCESS FLAG CHECK

                   END IF; -- for the primary_efc null check
                 END IF; -- FOR CHECKING THE CONTEXT  ISIR
               END IF; -- ISIR IMPORTED BY LEGACY OR NOT
             END IF;  -- for the batch year check
            END IF; -- BASE ID EXISTS OR NOT
        END IF; -- PERSON EXISTS OR NOT

    ELSE
      fnd_message.set_name('IGF','IGF_AP_MK_ACT_SKIP');
      add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
      l_error_flag := TRUE;
    END IF; -- if the person is not duplicate
      IF l_error_flag = TRUE THEN
        l_error_flag := FALSE;
        l_error_record_cnt := l_error_record_cnt + 1;
        --update the legacy interface table column import_status to 'E'
        UPDATE igf_ap_li_isir_act_ints
        SET import_status_type = 'E'
        WHERE ROWID = l_get_records.ROW_ID;
      ELSE
        IF p_del_ind = 'Y' THEN
           DELETE FROM igf_ap_li_isir_act_ints
           WHERE ROWID = l_get_records.ROW_ID;
        ELSE
           --update the legacy interface table column import_status to 'I'
           UPDATE igf_ap_li_isir_act_ints
           SET import_status_type = 'I'
           WHERE ROWID = l_get_records.ROW_ID;
        END IF;
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_mk_isir_act_pkg.lg_make_active_isir.debug',l_debug_str);
      END IF;
      l_process_flag := FALSE;
      l_debug_str := NULL;
      EXCEPTION
       WHEN others THEN
         l_process_flag := FALSE;
         l_debug_str := NULL;
         l_error_flag := FALSE;
         fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
         fnd_message.set_token('NAME','IGF_AP_MK_ISIR_ACT_PKG.LG_MAKE_ACTIVE_ISIR');
         add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
         ROLLBACK TO sp1;
      END;
      COMMIT;
    END LOOP;
    CLOSE c_get_records;

    IF l_success_record_cnt = 0 AND l_error_record_cnt = 0 THEN
       fnd_message.set_name('IGS','IGS_FI_NO_RECORD_AVAILABLE');
       add_log_table_process(NULL,l_error,fnd_message.get);
    END IF;

    -- CALL THE PRINT LOG PROCESS
    print_log_process(l_get_alternate_code.alternate_code,p_batch_id,p_del_ind);

    l_total_record_cnt := l_success_record_cnt + l_error_record_cnt;
    fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_PROCESSED');
    fnd_file.put_line(fnd_file.OUTPUT,fnd_message.get || ' ' || l_total_record_cnt);
    fnd_message.set_name('IGS','IGS_AD_SUCC_IMP_OFR_RESP_REC');
    fnd_file.put_line(fnd_file.OUTPUT,fnd_message.get || ' : ' || l_success_record_cnt);
    fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_FAILED');
    fnd_file.put_line(fnd_file.OUTPUT,fnd_message.get || ' : ' || l_error_record_cnt);
  EXCEPTION
        WHEN others THEN
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_mk_isir_act_pkg.lg_make_active_isir.exception','Unhandled Exception: '||SQLERRM);
        END IF;
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AP_MK_ISIR_ACT_PKG.LG_MAKE_ACTIVE_ISIR');
        errbuf  := fnd_message.get;
        igs_ge_msg_stack.conc_exception_hndl;

  END lg_make_active_isir;

  FUNCTION check_dup_person(p_person_number  IN VARCHAR2)
  RETURN BOOLEAN
  IS
    /*
    ||  Created By : bkkumar
    ||  Created On :
    ||  Purpose : Routine will verify whether the person number is duplicate
    ||            in the interface table.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
    l_count NUMBER(5) := g_per_tab.COUNT;
  BEGIN
    FOR i IN 1..l_count LOOP
      IF g_per_tab(i) = p_person_number THEN
        RETURN TRUE;
      END IF;
    END LOOP;
    RETURN FALSE;
  END;

  PROCEDURE update_isir_rec( p_isir_rec             IN igf_ap_isir_matched%ROWTYPE,
                             p_make_isir            IN VARCHAR2
                           ) IS
    /*
    ||  Created By : bkkumar
    ||  Created On : 26-MAY-2003
    ||  Purpose : This process updates the ISIR record active_isir
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

  BEGIN

     igf_ap_isir_matched_pkg.update_row(
                  x_Mode                              => 'R',
                  x_rowid                             => p_isir_rec.row_id,
                  x_isir_id                           => p_isir_rec.isir_id,
                  x_base_id                           => p_isir_rec.base_id,
                  x_batch_year                        => p_isir_rec.batch_year                       ,
                  x_transaction_num                   => p_isir_rec.transaction_num                  ,
                  x_current_ssn                       => p_isir_rec.current_ssn                      ,
                  x_ssn_name_change                   => p_isir_rec.ssn_name_change                  ,
                  x_original_ssn                      => p_isir_rec.original_ssn                     ,
                  x_orig_name_id                      => p_isir_rec.orig_name_id                     ,
                  x_last_name                         => p_isir_rec.last_name                        ,
                  x_first_name                        => p_isir_rec.first_name                       ,
                  x_middle_initial                    => p_isir_rec.middle_initial                   ,
                  x_perm_mail_add                     => p_isir_rec.perm_mail_add                    ,
                  x_perm_city                         => p_isir_rec.perm_city                        ,
                  x_perm_state                        => p_isir_rec.perm_state                       ,
                  x_perm_zip_code                     => p_isir_rec.perm_zip_code                    ,
                  x_date_of_birth                     => p_isir_rec.date_of_birth                    ,
                  x_phone_number                      => p_isir_rec.phone_number                     ,
                  x_driver_license_number             => p_isir_rec.driver_license_number            ,
                  x_driver_license_state              => p_isir_rec.driver_license_state             ,
                  x_citizenship_status                => p_isir_rec.citizenship_status               ,
                  x_alien_reg_number                  => p_isir_rec.alien_reg_number                 ,
                  x_s_marital_status                  => p_isir_rec.s_marital_status                 ,
                  x_s_marital_status_date             => p_isir_rec.s_marital_status_date            ,
                  x_summ_enrl_status                  => p_isir_rec.summ_enrl_status                 ,
                  x_fall_enrl_status                  => p_isir_rec.fall_enrl_status                 ,
                  x_winter_enrl_status                => p_isir_rec.winter_enrl_status               ,
                  x_spring_enrl_status                => p_isir_rec.spring_enrl_status               ,
                  x_summ2_enrl_status                 => p_isir_rec.summ2_enrl_status                ,
                  x_fathers_highest_edu_level         => p_isir_rec.fathers_highest_edu_level        ,
                  x_mothers_highest_edu_level         => p_isir_rec.mothers_highest_edu_level        ,
                  x_s_state_legal_residence           => p_isir_rec.s_state_legal_residence          ,
                  x_legal_residence_before_date       => p_isir_rec.legal_residence_before_date      ,
                  x_s_legal_resd_date                 => p_isir_rec.s_legal_resd_date                ,
                  x_ss_r_u_male                       => p_isir_rec.ss_r_u_male                      ,
                  x_selective_service_reg             => p_isir_rec.selective_service_reg            ,
                  x_degree_certification              => p_isir_rec.degree_certification             ,
                  x_grade_level_in_college            => p_isir_rec.grade_level_in_college           ,
                  x_high_school_diploma_ged           => p_isir_rec.high_school_diploma_ged          ,
                  x_first_bachelor_deg_by_date        => p_isir_rec.first_bachelor_deg_by_date       ,
                  x_interest_in_loan                  => p_isir_rec.interest_in_loan                 ,
                  x_interest_in_stud_employment       => p_isir_rec.interest_in_stud_employment      ,
                  x_drug_offence_conviction           => p_isir_rec.drug_offence_conviction          ,
                  x_s_tax_return_status               => p_isir_rec.s_tax_return_status              ,
                  x_s_type_tax_return                 => p_isir_rec.s_type_tax_return                ,
                  x_s_elig_1040ez                     => p_isir_rec.s_elig_1040ez                    ,
                  x_s_adjusted_gross_income           => p_isir_rec.s_adjusted_gross_income          ,
                  x_s_fed_taxes_paid                  => p_isir_rec.s_fed_taxes_paid                 ,
                  x_s_exemptions                      => p_isir_rec.s_exemptions                     ,
                  x_s_income_from_work                => p_isir_rec.s_income_from_work               ,
                  x_spouse_income_from_work           => p_isir_rec.spouse_income_from_work          ,
                  x_s_toa_amt_from_wsa                => p_isir_rec.s_toa_amt_from_wsa               ,
                  x_s_toa_amt_from_wsb                => p_isir_rec.s_toa_amt_from_wsb               ,
                  x_s_toa_amt_from_wsc                => p_isir_rec.s_toa_amt_from_wsc               ,
                  x_s_investment_networth             => p_isir_rec.s_investment_networth            ,
                  x_s_busi_farm_networth              => p_isir_rec.s_busi_farm_networth             ,
                  x_s_cash_savings                    => p_isir_rec.s_cash_savings                   ,
                  x_va_months                         => p_isir_rec.va_months                        ,
                  x_va_amount                         => p_isir_rec.va_amount                        ,
                  x_stud_dob_before_date              => p_isir_rec.stud_dob_before_date             ,
                  x_deg_beyond_bachelor               => p_isir_rec.deg_beyond_bachelor              ,
                  x_s_married                         => p_isir_rec.s_married                        ,
                  x_s_have_children                   => p_isir_rec.s_have_children                  ,
                  x_legal_dependents                  => p_isir_rec.legal_dependents                 ,
                  x_orphan_ward_of_court              => p_isir_rec.orphan_ward_of_court             ,
                  x_s_veteran                         => p_isir_rec.s_veteran                        ,
                  x_p_marital_status                  => p_isir_rec.p_marital_status                 ,
                  x_father_ssn                        => p_isir_rec.father_ssn                       ,
                  x_f_last_name                       => p_isir_rec.f_last_name                      ,
                  x_mother_ssn                        => p_isir_rec.mother_ssn                       ,
                  x_m_last_name                       => p_isir_rec.m_last_name                      ,
                  x_p_num_family_member               => p_isir_rec.p_num_family_member              ,
                  x_p_num_in_college                  => p_isir_rec.p_num_in_college                 ,
                  x_p_state_legal_residence           => p_isir_rec.p_state_legal_residence          ,
                  x_p_state_legal_res_before_dt       => p_isir_rec.p_state_legal_res_before_dt      ,
                  x_p_legal_res_date                  => p_isir_rec.p_legal_res_date                 ,
                  x_age_older_parent                  => p_isir_rec.age_older_parent                 ,
                  x_p_tax_return_status               => p_isir_rec.p_tax_return_status              ,
                  x_p_type_tax_return                 => p_isir_rec.p_type_tax_return                ,
                  x_p_elig_1040aez                    => p_isir_rec.p_elig_1040aez                   ,
                  x_p_adjusted_gross_income           => p_isir_rec.p_adjusted_gross_income          ,
                  x_p_taxes_paid                      => p_isir_rec.p_taxes_paid                     ,
                  x_p_exemptions                      => p_isir_rec.p_exemptions                     ,
                  x_f_income_work                     => p_isir_rec.f_income_work                    ,
                  x_m_income_work                     => p_isir_rec.m_income_work                    ,
                  x_p_income_wsa                      => p_isir_rec.p_income_wsa                     ,
                  x_p_income_wsb                      => p_isir_rec.p_income_wsb                     ,
                  x_p_income_wsc                      => p_isir_rec.p_income_wsc                     ,
                  x_p_investment_networth             => p_isir_rec.p_investment_networth            ,
                  x_p_business_networth               => p_isir_rec.p_business_networth              ,
                  x_p_cash_saving                     => p_isir_rec.p_cash_saving                    ,
                  x_s_num_family_members              => p_isir_rec.s_num_family_members             ,
                  x_s_num_in_college                  => p_isir_rec.s_num_in_college                 ,
                  x_first_college                     => p_isir_rec.first_college                    ,
                  x_first_house_plan                  => p_isir_rec.first_house_plan                 ,
                  x_second_college                    => p_isir_rec.second_college                   ,
                  x_second_house_plan                 => p_isir_rec.second_house_plan                ,
                  x_third_college                     => p_isir_rec.third_college                    ,
                  x_third_house_plan                  => p_isir_rec.third_house_plan                 ,
                  x_fourth_college                    => p_isir_rec.fourth_college                   ,
                  x_fourth_house_plan                 => p_isir_rec.fourth_house_plan                ,
                  x_fifth_college                     => p_isir_rec.fifth_college                    ,
                  x_fifth_house_plan                  => p_isir_rec.fifth_house_plan                 ,
                  x_sixth_college                     => p_isir_rec.sixth_college                    ,
                  x_sixth_house_plan                  => p_isir_rec.sixth_house_plan                 ,
                  x_date_app_completed                => p_isir_rec.date_app_completed               ,
                  x_signed_by                         => p_isir_rec.signed_by                        ,
                  x_preparer_ssn                      => p_isir_rec.preparer_ssn                     ,
                  x_preparer_emp_id_number            => p_isir_rec.preparer_emp_id_number           ,
                  x_preparer_sign                     => p_isir_rec.preparer_sign                    ,
                  x_transaction_receipt_date          => p_isir_rec.transaction_receipt_date         ,
                  x_dependency_override_ind           => p_isir_rec.dependency_override_ind          ,
                  x_faa_fedral_schl_code              => p_isir_rec.faa_fedral_schl_code             ,
                  x_faa_adjustment                    => p_isir_rec.faa_adjustment                   ,
                  x_input_record_type                 => p_isir_rec.input_record_type                ,
                  x_serial_number                     => p_isir_rec.serial_number                    ,
                  x_batch_number                      => p_isir_rec.batch_number                     ,
                  x_early_analysis_flag               => p_isir_rec.early_analysis_flag              ,
                  x_app_entry_source_code             => p_isir_rec.app_entry_source_code            ,
                  x_eti_destination_code              => p_isir_rec.eti_destination_code             ,
                  x_reject_override_b                 => p_isir_rec.reject_override_b                ,
                  x_reject_override_n                 => p_isir_rec.reject_override_n                ,
                  x_reject_override_w                 => p_isir_rec.reject_override_w                ,
                  x_assum_override_1                  => p_isir_rec.assum_override_1                 ,
                  x_assum_override_2                  => p_isir_rec.assum_override_2                 ,
                  x_assum_override_3                  => p_isir_rec.assum_override_3                 ,
                  x_assum_override_4                  => p_isir_rec.assum_override_4                 ,
                  x_assum_override_5                  => p_isir_rec.assum_override_5                 ,
                  x_assum_override_6                  => p_isir_rec.assum_override_6                 ,
                  x_dependency_status                 => p_isir_rec.dependency_status                ,
                  x_s_email_address                   => p_isir_rec.s_email_address                  ,
                  x_nslds_reason_code                 => p_isir_rec.nslds_reason_code                ,
                  x_app_receipt_date                  => p_isir_rec.app_receipt_date                 ,
                  x_processed_rec_type                => p_isir_rec.processed_rec_type               ,
                  x_hist_correction_for_tran_id       => p_isir_rec.hist_correction_for_tran_id      ,
                  x_system_generated_indicator        => p_isir_rec.system_generated_indicator       ,
                  x_dup_request_indicator             => p_isir_rec.dup_request_indicator            ,
                  x_source_of_correction              => p_isir_rec.source_of_correction             ,
                  x_p_cal_tax_status                  => p_isir_rec.p_cal_tax_status                 ,
                  x_s_cal_tax_status                  => p_isir_rec.s_cal_tax_status                 ,
                  x_graduate_flag                     => p_isir_rec.graduate_flag                    ,
                  x_auto_zero_efc                     => p_isir_rec.auto_zero_efc                    ,
                  x_efc_change_flag                   => p_isir_rec.efc_change_flag                  ,
                  x_sarc_flag                         => p_isir_rec.sarc_flag                        ,
                  x_simplified_need_test              => p_isir_rec.simplified_need_test             ,
                  x_reject_reason_codes               => p_isir_rec.reject_reason_codes              ,
                  x_select_service_match_flag         => p_isir_rec.select_service_match_flag        ,
                  x_select_service_reg_flag           => p_isir_rec.select_service_reg_flag          ,
                  x_ins_match_flag                    => p_isir_rec.ins_match_flag                   ,
                  x_ins_verification_number           => NULL                                        ,
                  x_sec_ins_match_flag                => p_isir_rec.sec_ins_match_flag               ,
                  x_sec_ins_ver_number                => p_isir_rec.sec_ins_ver_number               ,
                  x_ssn_match_flag                    => p_isir_rec.ssn_match_flag                   ,
                  x_ssa_citizenship_flag              => p_isir_rec.ssa_citizenship_flag             ,
                  x_ssn_date_of_death                 => p_isir_rec.ssn_date_of_death                ,
                  x_nslds_match_flag                  => p_isir_rec.nslds_match_flag                 ,
                  x_va_match_flag                     => p_isir_rec.va_match_flag                    ,
                  x_prisoner_match                    => p_isir_rec.prisoner_match                   ,
                  x_verification_flag                 => p_isir_rec.verification_flag                ,
                  x_subsequent_app_flag               => p_isir_rec.subsequent_app_flag              ,
                  x_app_source_site_code              => p_isir_rec.app_source_site_code             ,
                  x_tran_source_site_code             => p_isir_rec.tran_source_site_code            ,
                  x_drn                               => p_isir_rec.drn                              ,
                  x_tran_process_date                 => p_isir_rec.tran_process_date                ,
                  x_computer_batch_number             => p_isir_rec.computer_batch_number            ,
                  x_correction_flags                  => p_isir_rec.correction_flags                 ,
                  x_highlight_flags                   => p_isir_rec.highlight_flags                  ,
                  x_paid_efc                          => NULL                                        ,
                  x_primary_efc                       => p_isir_rec.primary_efc                      ,
                  x_secondary_efc                     => p_isir_rec.secondary_efc                    ,
                  x_fed_pell_grant_efc_type           => NULL                                        ,
                  x_primary_efc_type                  => p_isir_rec.primary_efc_type                 ,
                  x_sec_efc_type                      => p_isir_rec.sec_efc_type                     ,
                  x_primary_alternate_month_1         => p_isir_rec.primary_alternate_month_1        ,
                  x_primary_alternate_month_2         => p_isir_rec.primary_alternate_month_2        ,
                  x_primary_alternate_month_3         => p_isir_rec.primary_alternate_month_3        ,
                  x_primary_alternate_month_4         => p_isir_rec.primary_alternate_month_4        ,
                  x_primary_alternate_month_5         => p_isir_rec.primary_alternate_month_5        ,
                  x_primary_alternate_month_6         => p_isir_rec.primary_alternate_month_6        ,
                  x_primary_alternate_month_7         => p_isir_rec.primary_alternate_month_7        ,
                  x_primary_alternate_month_8         => p_isir_rec.primary_alternate_month_8        ,
                  x_primary_alternate_month_10        => p_isir_rec.primary_alternate_month_10       ,
                  x_primary_alternate_month_11        => p_isir_rec.primary_alternate_month_11       ,
                  x_primary_alternate_month_12        => p_isir_rec.primary_alternate_month_12       ,
                  x_sec_alternate_month_1             => p_isir_rec.sec_alternate_month_1            ,
                  x_sec_alternate_month_2             => p_isir_rec.sec_alternate_month_2            ,
                  x_sec_alternate_month_3             => p_isir_rec.sec_alternate_month_3            ,
                  x_sec_alternate_month_4             => p_isir_rec.sec_alternate_month_4            ,
                  x_sec_alternate_month_5             => p_isir_rec.sec_alternate_month_5            ,
                  x_sec_alternate_month_6             => p_isir_rec.sec_alternate_month_6            ,
                  x_sec_alternate_month_7             => p_isir_rec.sec_alternate_month_7            ,
                  x_sec_alternate_month_8             => p_isir_rec.sec_alternate_month_8            ,
                  x_sec_alternate_month_10            => p_isir_rec.sec_alternate_month_10           ,
                  x_sec_alternate_month_11            => p_isir_rec.sec_alternate_month_11           ,
                  x_sec_alternate_month_12            => p_isir_rec.sec_alternate_month_12           ,
                  x_total_income                      => p_isir_rec.total_income                     ,
                  x_allow_total_income                => p_isir_rec.allow_total_income               ,
                  x_state_tax_allow                   => p_isir_rec.state_tax_allow                  ,
                  x_employment_allow                  => p_isir_rec.employment_allow                 ,
                  x_income_protection_allow           => p_isir_rec.income_protection_allow          ,
                  x_available_income                  => p_isir_rec.available_income                 ,
                  x_contribution_from_ai              => p_isir_rec.contribution_from_ai             ,
                  x_discretionary_networth            => p_isir_rec.discretionary_networth           ,
                  x_efc_networth                      => p_isir_rec.efc_networth                     ,
                  x_asset_protect_allow               => p_isir_rec.asset_protect_allow              ,
                  x_parents_cont_from_assets          => p_isir_rec.parents_cont_from_assets         ,
                  x_adjusted_available_income         => p_isir_rec.adjusted_available_income        ,
                  x_total_student_contribution        => p_isir_rec.total_student_contribution       ,
                  x_total_parent_contribution         => p_isir_rec.total_parent_contribution        ,
                  x_parents_contribution              => p_isir_rec.parents_contribution             ,
                  x_student_total_income              => p_isir_rec.student_total_income             ,
                  x_sati                              => p_isir_rec.sati                             ,
                  x_sic                               => p_isir_rec.sic                              ,
                  x_sdnw                              => p_isir_rec.sdnw                             ,
                  x_sca                               => p_isir_rec.sca                              ,
                  x_fti                               => p_isir_rec.fti                              ,
                  x_secti                             => p_isir_rec.secti                            ,
                  x_secati                            => p_isir_rec.secati                           ,
                  x_secstx                            => p_isir_rec.secstx                           ,
                  x_secea                             => p_isir_rec.secea                            ,
                  x_secipa                            => p_isir_rec.secipa                           ,
                  x_secai                             => p_isir_rec.secai                            ,
                  x_seccai                            => p_isir_rec.seccai                           ,
                  x_secdnw                            => p_isir_rec.secdnw                           ,
                  x_secnw                             => p_isir_rec.secnw                            ,
                  x_secapa                            => p_isir_rec.secapa                           ,
                  x_secpca                            => p_isir_rec.secpca                           ,
                  x_secaai                            => p_isir_rec.secaai                           ,
                  x_sectsc                            => p_isir_rec.sectsc                           ,
                  x_sectpc                            => p_isir_rec.sectpc                           ,
                  x_secpc                             => p_isir_rec.secpc                            ,
                  x_secsti                            => p_isir_rec.secsti                           ,
                  x_secsic                            => p_isir_rec.secsic                           ,
                  x_secsati                           => p_isir_rec.secsati                          ,
                  x_secsdnw                           => p_isir_rec.secsdnw                          ,
                  x_secsca                            => p_isir_rec.secsca                           ,
                  x_secfti                            => p_isir_rec.secfti                           ,
                  x_a_citizenship                     => p_isir_rec.a_citizenship                    ,
                  x_a_student_marital_status          => p_isir_rec.a_student_marital_status         ,
                  x_a_student_agi                     => p_isir_rec.a_student_agi                    ,
                  x_a_s_us_tax_paid                   => p_isir_rec.a_s_us_tax_paid                  ,
                  x_a_s_income_work                   => p_isir_rec.a_s_income_work                  ,
                  x_a_spouse_income_work              => p_isir_rec.a_spouse_income_work             ,
                  x_a_s_total_wsc                     => p_isir_rec.a_s_total_wsc                    ,
                  x_a_date_of_birth                   => p_isir_rec.a_date_of_birth                  ,
                  x_a_student_married                 => p_isir_rec.a_student_married                ,
                  x_a_have_children                   => p_isir_rec.a_have_children                  ,
                  x_a_s_have_dependents               => p_isir_rec.a_s_have_dependents              ,
                  x_a_va_status                       => p_isir_rec.a_va_status                      ,
                  x_a_s_num_in_family                 => p_isir_rec.a_s_num_in_family                ,
                  x_a_s_num_in_college                => p_isir_rec.a_s_num_in_college               ,
                  x_a_p_marital_status                => p_isir_rec.a_p_marital_status               ,
                  x_a_father_ssn                      => p_isir_rec.a_father_ssn                     ,
                  x_a_mother_ssn                      => p_isir_rec.a_mother_ssn                     ,
                  x_a_parents_num_family              => p_isir_rec.a_parents_num_family             ,
                  x_a_parents_num_college             => p_isir_rec.a_parents_num_college            ,
                  x_a_parents_agi                     => p_isir_rec.a_parents_agi                    ,
                  x_a_p_us_tax_paid                   => p_isir_rec.a_p_us_tax_paid                  ,
                  x_a_f_work_income                   => p_isir_rec.a_f_work_income                  ,
                  x_a_m_work_income                   => p_isir_rec.a_m_work_income                  ,
                  x_a_p_total_wsc                     => p_isir_rec.a_p_total_wsc                    ,
                  x_comment_codes                     => p_isir_rec.comment_codes                    ,
                  x_sar_ack_comm_code                 => p_isir_rec.sar_ack_comm_code                ,
                  x_pell_grant_elig_flag              => p_isir_rec.pell_grant_elig_flag             ,
                  x_reprocess_reason_code             => p_isir_rec.reprocess_reason_code            ,
                  x_duplicate_date                    => p_isir_rec.duplicate_date                   ,
                  x_isir_transaction_type             => p_isir_rec.isir_transaction_type            ,
                  x_fedral_schl_code_indicator        => p_isir_rec.fedral_schl_code_indicator       ,
                  x_multi_school_code_flags           => p_isir_rec.multi_school_code_flags          ,
                  x_dup_ssn_indicator                 => p_isir_rec.dup_ssn_indicator                ,
                  x_system_record_type                => p_isir_rec.system_record_type               ,
						---- Changed the value from p_isir_rec.payment_isir to p_make_isir (same value to be assigned to payment_isir and active_isir
                  x_payment_isir                      => p_make_isir                                 ,
                  x_receipt_status                    => p_isir_rec.receipt_status                   ,
                  x_isir_receipt_completed            => p_isir_rec.isir_receipt_completed           ,
                  x_active_isir                       => p_make_isir                                 ,
                  x_fafsa_data_verify_flags           => p_isir_rec.fafsa_data_verify_flags          ,
                  x_reject_override_a                 => p_isir_rec.reject_override_a                ,
                  x_reject_override_c                 => p_isir_rec.reject_override_c                ,
                  x_parent_marital_status_date        => p_isir_rec.parent_marital_status_date       ,
                  x_legacy_record_flag                => p_isir_rec.legacy_record_flag               ,
                  x_father_first_name_initial         => p_isir_rec.father_first_name_initial_txt    ,
                  x_father_step_father_birth_dt       => p_isir_rec.father_step_father_birth_date    ,
                  x_mother_first_name_initial         => p_isir_rec.mother_first_name_initial_txt    ,
                  x_mother_step_mother_birth_dt       => p_isir_rec.mother_step_mother_birth_date    ,
                  x_parents_email_address_txt         => p_isir_rec.parents_email_address_txt        ,
                  x_address_change_type               => p_isir_rec.address_change_type              ,
                  x_cps_pushed_isir_flag              => p_isir_rec.cps_pushed_isir_flag             ,
                  x_electronic_transaction_type       => p_isir_rec.electronic_transaction_type      ,
                  x_sar_c_change_type                 => p_isir_rec.sar_c_change_type                ,
                  x_father_ssn_match_type             => p_isir_rec.father_ssn_match_type            ,
                  x_mother_ssn_match_type             => p_isir_rec.mother_ssn_match_type            ,
                  x_reject_override_g_flag            => p_isir_rec.reject_override_g_flag           ,
                  x_dhs_verification_num_txt          => p_isir_rec.dhs_verification_num_txt         ,
                  x_data_file_name_txt                => p_isir_rec.data_file_name_txt               ,
                  x_message_class_txt                 => p_isir_rec.message_class_txt                ,
                  x_reject_override_3_flag            => p_isir_rec.reject_override_3_flag           ,
                  x_reject_override_12_flag           => p_isir_rec.reject_override_12_flag          ,
                  x_reject_override_j_flag            => p_isir_rec.reject_override_j_flag           ,
                  x_reject_override_k_flag            => p_isir_rec.reject_override_k_flag           ,
                  x_rejected_status_change_flag       => p_isir_rec.rejected_status_change_flag      ,
                  x_verification_selection_flag       => p_isir_rec.verification_selection_flag
                 );


  END update_isir_rec;


  PROCEDURE update_fabase_rec_process(
                                       p_fed_verif_status     IN VARCHAR2
                                     ) IS
    /*
    ||  Created By : bkkumar
    ||  Created On : 26-MAY-2003
    ||  Purpose : This process updates the FA Base federal verification status
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    || rasahoo        17-NOV-2003      FA 128 - ISIR update 2004-05
    ||                                 added new parameter award_fmly_contribution_type to
    ||                                 igf_ap_fa_base_rec_pkg.update_row
    ||  ugummall        25-SEP-2003     FA 126 - Multiple FA Offices
    ||                                  added new parameter assoc_org_num to
    ||                                  igf_ap_fa_base_rec_pkg.update_row call
    */

  BEGIN

      igf_ap_fa_base_rec_pkg.update_row(
                                  x_Mode                                   => 'R' ,
                                  x_rowid                                  => g_baseid_exists.row_id ,
                                  x_base_id                                => g_baseid_exists.base_id ,
                                  x_ci_cal_type                            => g_baseid_exists.ci_cal_type ,
                                  x_person_id                              => g_baseid_exists.person_id ,
                                  x_ci_sequence_number                     => g_baseid_exists.ci_sequence_number ,
                                  x_org_id                                 => g_baseid_exists.org_id ,
                                  x_coa_pending                            => g_baseid_exists.coa_pending ,
                                  x_verification_process_run               => g_baseid_exists.verification_process_run ,
                                  x_inst_verif_status_date                 => g_baseid_exists.inst_verif_status_date ,
                                  x_manual_verif_flag                      => g_baseid_exists.manual_verif_flag ,
                                  x_fed_verif_status                       => p_fed_verif_status,
                                  x_fed_verif_status_date                  => SYSDATE,
                                  x_inst_verif_status                      => g_baseid_exists.inst_verif_status ,
                                  x_nslds_eligible                         => g_baseid_exists.nslds_eligible ,
                                  x_ede_correction_batch_id                => g_baseid_exists.ede_correction_batch_id ,
                                  x_fa_process_status_date                 => g_baseid_exists.fa_process_status_date ,
                                  x_isir_corr_status                       => g_baseid_exists.isir_corr_status ,
                                  x_isir_corr_status_date                  => g_baseid_exists.isir_corr_status_date ,
                                  x_isir_status                            => g_baseid_exists.isir_status ,
                                  x_isir_status_date                       => g_baseid_exists.isir_status_date ,
                                  x_coa_code_f                             => g_baseid_exists.coa_code_f ,
                                  x_coa_code_i                             => g_baseid_exists.coa_code_i ,
                                  x_coa_f                                  => g_baseid_exists.coa_f ,
                                  x_coa_i                                  => g_baseid_exists.coa_i ,
                                  x_disbursement_hold                      => g_baseid_exists.disbursement_hold ,
                                  x_fa_process_status                      => g_baseid_exists.fa_process_status ,
                                  x_notification_status                    => g_baseid_exists.notification_status ,
                                  x_notification_status_date               => g_baseid_exists.notification_status_date ,
                                  x_packaging_status                       => g_baseid_exists.packaging_status ,
                                  x_packaging_status_date                  => g_baseid_exists.packaging_status_date ,
                                  x_total_package_accepted                 => g_baseid_exists.total_package_accepted ,
                                  x_total_package_offered                  => g_baseid_exists.total_package_offered ,
                                  x_admstruct_id                           => g_baseid_exists.admstruct_id ,
                                  x_admsegment_1                           => g_baseid_exists.admsegment_1 ,
                                  x_admsegment_2                           => g_baseid_exists.admsegment_2 ,
                                  x_admsegment_3                           => g_baseid_exists.admsegment_3 ,
                                  x_admsegment_4                           => g_baseid_exists.admsegment_4 ,
                                  x_admsegment_5                           => g_baseid_exists.admsegment_5 ,
                                  x_admsegment_6                           => g_baseid_exists.admsegment_6 ,
                                  x_admsegment_7                           => g_baseid_exists.admsegment_7 ,
                                  x_admsegment_8                           => g_baseid_exists.admsegment_8 ,
                                  x_admsegment_9                           => g_baseid_exists.admsegment_9 ,
                                  x_admsegment_10                          => g_baseid_exists.admsegment_10 ,
                                  x_admsegment_11                          => g_baseid_exists.admsegment_11 ,
                                  x_admsegment_12                          => g_baseid_exists.admsegment_12 ,
                                  x_admsegment_13                          => g_baseid_exists.admsegment_13 ,
                                  x_admsegment_14                          => g_baseid_exists.admsegment_14 ,
                                  x_admsegment_15                          => g_baseid_exists.admsegment_15 ,
                                  x_admsegment_16                          => g_baseid_exists.admsegment_16 ,
                                  x_admsegment_17                          => g_baseid_exists.admsegment_17 ,
                                  x_admsegment_18                          => g_baseid_exists.admsegment_18 ,
                                  x_admsegment_19                          => g_baseid_exists.admsegment_19 ,
                                  x_admsegment_20                          => g_baseid_exists.admsegment_20 ,
                                  x_packstruct_id                          => g_baseid_exists.packstruct_id ,
                                  x_packsegment_1                          => g_baseid_exists.packsegment_1 ,
                                  x_packsegment_2                          => g_baseid_exists.packsegment_2 ,
                                  x_packsegment_3                          => g_baseid_exists.packsegment_3 ,
                                  x_packsegment_4                          => g_baseid_exists.packsegment_4 ,
                                  x_packsegment_5                          => g_baseid_exists.packsegment_5 ,
                                  x_packsegment_6                          => g_baseid_exists.packsegment_6 ,
                                  x_packsegment_7                          => g_baseid_exists.packsegment_7 ,
                                  x_packsegment_8                          => g_baseid_exists.packsegment_8 ,
                                  x_packsegment_9                          => g_baseid_exists.packsegment_9 ,
                                  x_packsegment_10                         => g_baseid_exists.packsegment_10 ,
                                  x_packsegment_11                         => g_baseid_exists.packsegment_11 ,
                                  x_packsegment_12                         => g_baseid_exists.packsegment_12 ,
                                  x_packsegment_13                         => g_baseid_exists.packsegment_13 ,
                                  x_packsegment_14                         => g_baseid_exists.packsegment_14 ,
                                  x_packsegment_15                         => g_baseid_exists.packsegment_15 ,
                                  x_packsegment_16                         => g_baseid_exists.packsegment_16 ,
                                  x_packsegment_17                         => g_baseid_exists.packsegment_17 ,
                                  x_packsegment_18                         => g_baseid_exists.packsegment_18 ,
                                  x_packsegment_19                         => g_baseid_exists.packsegment_19 ,
                                  x_packsegment_20                         => g_baseid_exists.packsegment_20 ,
                                  x_miscstruct_id                          => g_baseid_exists.miscstruct_id ,
                                  x_miscsegment_1                          => g_baseid_exists.miscsegment_1 ,
                                  x_miscsegment_2                          => g_baseid_exists.miscsegment_2 ,
                                  x_miscsegment_3                          => g_baseid_exists.miscsegment_3 ,
                                  x_miscsegment_4                          => g_baseid_exists.miscsegment_4 ,
                                  x_miscsegment_5                          => g_baseid_exists.miscsegment_5 ,
                                  x_miscsegment_6                          => g_baseid_exists.miscsegment_6 ,
                                  x_miscsegment_7                          => g_baseid_exists.miscsegment_7 ,
                                  x_miscsegment_8                          => g_baseid_exists.miscsegment_8 ,
                                  x_miscsegment_9                          => g_baseid_exists.miscsegment_9 ,
                                  x_miscsegment_10                         => g_baseid_exists.miscsegment_10 ,
                                  x_miscsegment_11                         => g_baseid_exists.miscsegment_11 ,
                                  x_miscsegment_12                         => g_baseid_exists.miscsegment_12 ,
                                  x_miscsegment_13                         => g_baseid_exists.miscsegment_13 ,
                                  x_miscsegment_14                         => g_baseid_exists.miscsegment_14 ,
                                  x_miscsegment_15                         => g_baseid_exists.miscsegment_15 ,
                                  x_miscsegment_16                         => g_baseid_exists.miscsegment_16 ,
                                  x_miscsegment_17                         => g_baseid_exists.miscsegment_17 ,
                                  x_miscsegment_18                         => g_baseid_exists.miscsegment_18 ,
                                  x_miscsegment_19                         => g_baseid_exists.miscsegment_19 ,
                                  x_miscsegment_20                         => g_baseid_exists.miscsegment_20 ,
                                  x_prof_judgement_flg                     => g_baseid_exists.prof_judgement_flg ,
                                  x_nslds_data_override_flg                => g_baseid_exists.nslds_data_override_flg ,
                                  x_target_group                           => g_baseid_exists.target_group ,
                                  x_coa_fixed                              => g_baseid_exists.coa_fixed ,
                                  x_coa_pell                               => g_baseid_exists.coa_pell ,
                                  x_profile_status                         => g_baseid_exists.profile_status ,
                                  x_profile_status_date                    => g_baseid_exists.profile_status_date ,
                                  x_profile_fc                             => g_baseid_exists.profile_fc ,
                                  x_manual_disb_hold                       => g_baseid_exists.manual_disb_hold ,
                                  x_pell_alt_expense                       => g_baseid_exists.pell_alt_expense,
                                  x_assoc_org_num                          => g_baseid_exists.assoc_org_num,
                                  x_award_fmly_contribution_type           => g_baseid_exists.award_fmly_contribution_type,
                                  x_isir_locked_by                         => g_baseid_exists.isir_locked_by,
                                  x_adnl_unsub_loan_elig_flag              => g_baseid_exists.adnl_unsub_loan_elig_flag,
                                  x_lock_awd_flag                          => g_baseid_exists.lock_awd_flag,
                                  x_lock_coa_flag                          => g_baseid_exists.lock_coa_flag
                                  );


  END update_fabase_rec_process;

  PROCEDURE add_log_table_process(
                                  p_person_number     IN VARCHAR2,
                                  p_error             IN VARCHAR2,
                                  p_message_str       IN VARCHAR2
                                 ) IS
    /*
    ||  Created By : bkkumar
    ||  Created On : 26-MAY-2003
    ||  Purpose : This process adds a record to the global pl/sql table containing log messages
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

  BEGIN

      g_log_tab_index := g_log_tab_index + 1;
      g_log_tab(g_log_tab_index).person_number := p_person_number;
      g_log_tab(g_log_tab_index).message_text := RPAD(p_error,12) || p_message_str;

  END add_log_table_process;

  PROCEDURE print_log_process(
                              p_alternate_code     IN VARCHAR2,
                              p_batch_id           IN  NUMBER,
                              p_del_ind            IN VARCHAR2
                             ) IS
    /*
    ||  Created By : bkkumar
    ||  Created On : 26-MAY-2003
    ||  Purpose : This process gets the records from the pl/sql table and print in the log file
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    l_count NUMBER(5) := g_log_tab.COUNT;
    l_old_person igf_ap_li_isir_act_ints.person_number%TYPE := '*******';

    l_person_number   VARCHAR2(80);
    l_batch_id        VARCHAR2(80);
    l_award_yr        VARCHAR2(80);
    l_batch_desc      VARCHAR2(80);
    l_yes_no          VARCHAR2(10);

    CURSOR c_get_batch_desc(cp_batch_num NUMBER) IS
    SELECT batch_desc
      FROM igf_ap_li_bat_ints
     WHERE batch_num = cp_batch_num;

    l_get_batch_desc c_get_batch_desc%ROWTYPE;

  BEGIN

    l_person_number := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','PERSON_NUMBER');
    l_batch_id      := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','BATCH_ID');
    l_award_yr      := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','AWARD_YEAR');
    l_yes_no        := igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_del_ind);

    OPEN  c_get_batch_desc(p_batch_id);
    FETCH c_get_batch_desc INTO l_get_batch_desc;
    CLOSE c_get_batch_desc;
    l_batch_desc := l_get_batch_desc.batch_desc ;

    -- HERE THE INPUT PARAMETERS ARE TO BE LOGGED TO THE LOG FILE
    fnd_message.set_name('IGS','IGS_DA_JOB');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    fnd_file.put_line(fnd_file.log,l_batch_id || ' : ' || p_batch_id || ' - ' || l_batch_desc);
    fnd_file.put_line(fnd_file.log,l_award_yr || ' : ' || p_alternate_code);
    fnd_message.set_name('IGS','IGS_GE_ASK_DEL_REC');
    fnd_file.put_line(fnd_file.log,fnd_message.get || ' : ' || l_yes_no);
    fnd_file.put_line(fnd_file.log,'------------------------------------------------------------------------------');

    FOR i IN 1..l_count LOOP
      IF g_log_tab(i).person_number IS NOT NULL THEN
        IF l_old_person <> g_log_tab(i).person_number THEN
          fnd_file.put_line(fnd_file.log,'---------------------------------------------------------------------------------');
          fnd_file.put_line(fnd_file.log,l_person_number || ' : ' || g_log_tab(i).person_number);
        END IF;
        l_old_person := g_log_tab(i).person_number;
      END IF;
      fnd_file.put_line(fnd_file.log,g_log_tab(i).message_text);
    END LOOP;

  END print_log_process;

END igf_ap_mk_isir_act_pkg;

/
