--------------------------------------------------------
--  DDL for Package Body IGF_SL_CL_LI_IMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_CL_LI_IMP_PKG" AS
/* $Header: IGFSL19B.pls 120.11 2006/08/07 13:22:03 azmohamm ship $ */

/*
--=========================================================================
--   Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA
--                               All rights reserved.
-- ========================================================================
--
--  DESCRIPTION
--         PL/SQL Body for package: IGF_SL_CL_LI_IMP_PKG
--
--  NOTES
--
--  This package is used to import the legacy FFELP Loan and Disbursement
--  data in the system.
--
----------------------------------------------------------------------------------
-- CHANGE HISTORY
----------------------------------------------------------------------------------
-- who        when              what
-- azmohamm  03-AUG-2006       FA 163 Enhancements
--                             Introduced GPLUSFL
-- mnade      6/6/2005         FA 157 - 4382371 - Changes to import cs1/2 related columns from interface table.
-- pssahni   3-Nov-2004        FA134 Enhancements
--                             Added function validate release

-- svuppala    14-Oct-04       Bug # 3416936
                               Added other loan amount
  brajendr    12-Oct-2004     FA138 ISIR Enhacements
                              Modified the reference of payment_isir_id
*/
----------------------------------------------------------------------------------
--  veramach    July 2004       FA 151 HR Integration (bug#3709292)
--                              Impacts of obsoleting columns from igf_aw_awd_disb_all
---------------------------------------------------------------------------------
-- veramach     04-May-2004     bug 3603289
--                              Modified cursor cur_student_licence to select
--                              dependency_status from ISIR. other details are
--                              derived from igf_sl_gen.get_person_details.
-----------------------------------------------------------------------------------
-- sjadhav    18-Feb-2004       Bug 3451140
--                              Check for Non ED Branch ID setup only iff it is not
--                              '0000'
----------------------------------------------------------------------------------
-- veramach   11-Dec-2003       Bug # 3184891 Removed calls to igf_ap_gen.write_log
--                              and added common logging
----------------------------------------------------------------------------------
-- bkkumar    04-DEC-2003       Bug 3252382  FA 131 . TBH impact for the igf_aw_awd_disb_all
--                              Added two columns ATTENDANCE_TYPE_CODE,BASE_ATTENDANCE_TYPE_CODE
----------------------------------------------------------------------------------
-- ugummall   04-NOV-2003       Bug 3102439. FA 126 - Multiple FA Offices.
--                              Renamed cursor c_ope_id to c_source_or_branch_id with one extra
--                              parameter cp_source_type.
-- ugummall   21-OCT-2003       Bug 3102439. FA 126 - Multiple FA Offices.
--                              Removed the cursor c_branch_id in is_valid function.
--                              Modified the cursor c_ope_id in is_valid function.
--                              Added validation on sch_non_ed_brc_id_txt column.
-- bkkumar    16-oct-03         Bug 3104228 FA 122 Build Passed the correct token to
--                              "award_year" to the fnd_message.
----------------------------------------------------------------------------------
-- sjadhav    8-Oct-2003        Bug 3104228 FA 122 Build
--                              use recipient info from igf_sl_lor_v to
--                              insert into igf_sl_Lor_loc table
---------------------------------------------------------------------------------
-- bkkumar    06-oct-2003       Bug 3104228 FA 122 Loans Enhancements
--                              a) Impact of obsoleting GUARANTOR_ID_TXT,
--                              LENDER_ID_TXT,LEND_NON_ED_BRC_ID_TXT,RECIPIENT_ID_TXT,
--                              RECIPIENT_TYPE,RECIPIENT_NON_ED_BRC_ID_TXT from the
--                              interface table and also adding a new column relationship_cd
--                              b) Impact of adding the relationship_cd
--                              in igf_sl_lor_all table and obsoleting
--                              BORW_LENDER_ID, DUNS_BORW_LENDER_ID,
--                              GUARANTOR_ID, DUNS_GUARNT_ID,
--                              LENDER_ID, DUNS_LENDER_ID
--                              LEND_NON_ED_BRC_ID, RECIPIENT_ID
--                              RECIPIENT_TYPE,DUNS_RECIP_ID
--                              RECIP_NON_ED_BRC_ID columns.
--                              c) The DUNS_BORW_LENDER_ID
--                              DUNS_GUARNT_ID
--                              DUNS_LENDER_ID
--                              DUNS_RECIP_ID columns are osboleted from the
--                              igf_sl_lor_loc_all table.
---------------------------------------------------------------------------------
-- veramach   23-SEP-2003       Bug 3104228:
--                              Obsoleted lend_apprv_denied_code,lend_apprv_denied_date
--                              ,cl_rec_status_last_update,cl_rec_status,mpn_confirm_code
--                              ,appl_loan_phase_code_chg,appl_loan_phase_code,
--                              p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
--                              chg_batch_id,appl_send_error_codes from igf_sl_lor
--                              Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
--                              cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
--                              p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
--                              chg_batch_id from igf_sl_lor_loc
---------------------------------------------------------------------------------
-- veramach   16-SEP-2003       FA 122 Build Loan Enhancements
--                              1.Changed insert_records procedure's c_loan_dtls cursor
--                              not to select borrower information
--                              2.Changed validations of prc_type_code,disbursement_hld_release_flag,
--                              record_type
----------------------------------------------------------------------------------

     IMPORT_ERROR EXCEPTION;

     g_tab_index              NUMBER :=0;
     g_p_person_id            NUMBER;
     g_igf_sl_msg_table       igf_sl_msg_table;

     g_error VARCHAR2(11);

     g_award_year             VARCHAR2(80);
     g_award_year_status_desc VARCHAR2(80);
     g_del_flag               VARCHAR2(80);
     g_person_number          VARCHAR2(80);
     g_batch_num              VARCHAR2(80);
     g_loan_record            VARCHAR2(80);
     g_loan_disb              VARCHAR2(80);
     g_processing             VARCHAR2(80);
     g_para_pass              VARCHAR2(80);
     g_sys_award_year         VARCHAR2(80);
     g_rel_version            VARCHAR2(30);

     CURSOR c_interface (cp_batch_id              NUMBER,
                         cp_alternate_code        VARCHAR2,
       p_import_status_type_1   igf_sl_li_orig_ints.import_status_type%TYPE,
       p_import_status_type_2   igf_sl_li_orig_ints.import_status_type%TYPE
      )
     IS
     SELECT
     ROWID,
     TRUNC(clint.loan_per_begin_date)                  loan_per_begin_date,
     TRUNC(clint.loan_per_end_date)                    loan_per_end_date,
     TRUNC(clint.loan_status_date)                     loan_status_date,
     TRUNC(clint.active_date)                          active_date,
     TRUNC(clint.anticip_compl_date)                   anticip_compl_date,
     TRUNC(clint.b_permt_addr_chg_date)                b_permt_addr_chg_date,
     TRUNC(clint.b_signature_date)                     b_signature_date,
     TRUNC(clint.credit_status_date)                   credit_status_date,
     TRUNC(clint.guarantee_date)                       guarantee_date,
     TRUNC(clint.guarnt_status_date)                   guarnt_status_date,
     TRUNC(clint.lend_status_date)                     lend_status_date,
     TRUNC(clint.lend_blkt_guarnt_appr_date)           lend_blkt_guarnt_appr_date,
     TRUNC(clint.orig_ack_date)                        orig_ack_date,
     TRUNC(clint.orig_batch_date)                      orig_batch_date,
     TRUNC(clint.pnote_status_date)                    pnote_status_date,
     TRUNC(clint.sch_cert_date)                        sch_cert_date,
     TRUNC(clint.sch_refund_date)                      sch_refund_date,
     TRUNC(clint.file_creation_date)                   file_creation_date,
     TRUNC(clint.file_trans_date)                      file_trans_date,
     clint.batch_num,
     clint.loan_seq_num,
     clint.act_interest_rate_num,
     clint.alt_appl_ver_code_num,
     clint.alt_borw_tot_stu_loan_debt_amt,
     clint.borw_gross_annual_sal_amt,
     clint.borw_other_income_amt,
     clint.cl_seq_num,
     clint.coa_amt,
     clint.efc_amt,
     clint.est_fa_amt,
     clint.fed_sls_debt_amt,
     clint.fed_stafford_loan_debt_amt,
     clint.flp_approved_amt,
     clint.flp_cert_amt,
     clint.fls_approved_amt,
     clint.fls_cert_amt,
     clint.flu_approved_amt,
     clint.flu_cert_amt,
     clint.guarantee_amt,
     clint.heal_debt_amt,
     clint.other_debt_amt,
     clint.perkins_debt_amt,
     clint.req_loan_amt,
     clint.sch_refund_amt,
     clint.stud_mth_auto_pymt_amt,
     clint.stud_mth_crdtcard_pymt_amt,
     clint.stud_mth_ed_loan_pymt_amt,
     clint.stud_mth_housing_pymt_amt,
     clint.stud_mth_other_pymt_amt,
     clint.tot_outstd_plus_amt,
     clint.tot_outstd_stafford_amt,
     clint.alt_cert_amt,
     clint.alt_approved_amt,
     clint.reinst_avail_amt,
     TRIM(clint.ci_alternate_code)                                   ci_alternate_code,
     TRIM(clint.person_number)                                       person_number,
     TRIM(clint.award_number_txt)                                    award_number_txt,
     TRIM(clint.loan_number_txt)                                     loan_number_txt,
     TRIM(clint.import_status_type)                                  import_status_type,
     TRIM(clint.loan_status_code)                                    loan_status_code,
     TRIM(clint.active_flag)                                         active_flag,
     TRIM(clint.act_serial_loan_code)                                act_serial_loan_code,
     TRIM(clint.alt_prog_type_cd)                                    alt_prog_type_cd,
     TRIM(clint.borr_person_number)                                  borr_person_number,
     TRIM(clint.b_default_status_flag)                               b_default_status_flag,
     TRIM(clint.b_foreign_postal_cd)                                 b_foreign_postal_cd,
     TRIM(clint.b_stu_indicator_flag)                                b_stu_indicator_flag,
     TRIM(clint.b_reference_flag)                                    b_reference_flag,
     TRIM(clint.b_signature_flag)                                    b_signature_flag,
     TRIM(clint.borr_credit_auth_flag)                               borr_credit_auth_flag,
     TRIM(clint.borr_sign_flag)                                      borr_sign_flag,
     TRIM(clint.borw_confirm_flag)                                   borw_confirm_flag,
     TRIM(clint.borw_interest_flag)                                  borw_interest_flag,
     TRIM(clint.borw_outstd_loan_flag)                               borw_outstd_loan_flag,
     TRIM(clint.crdt_undr_difft_name_flag)                           crdt_undr_difft_name_flag,
     TRIM(clint.credit_status_code)                                  credit_status_code,
     TRIM(clint.eft_auth_flag)                                       eft_auth_flag,
     TRIM(clint.enrollment_code)                                     enrollment_code,
     TRIM(clint.err_mesg_1_cd)                                       err_mesg_1_cd,
     TRIM(clint.err_mesg_2_cd)                                       err_mesg_2_cd,
     TRIM(clint.err_mesg_3_cd)                                       err_mesg_3_cd,
     TRIM(clint.err_mesg_4_cd)                                       err_mesg_4_cd,
     TRIM(clint.err_mesg_5_cd)                                       err_mesg_5_cd,
     TRIM(clint.fed_appl_form_type)                                  fed_appl_form_type,
     TRIM(clint.grade_level_code)                                    grade_level_code,
     TRIM(clint.guarnt_adj_flag)                                     guarnt_adj_flag,
     TRIM(clint.guarnt_amt_redn_code)                                guarnt_amt_redn_code,
     TRIM(clint.guarnt_status_code)                                  guarnt_status_code,
     TRIM(clint.int_rate_opt_code)                                   int_rate_opt_code,
     TRIM(clint.last_resort_lender_flag)                             last_resort_lender_flag,
     TRIM(clint.lend_status_code)                                    lend_status_code,
     TRIM(clint.lend_blkt_guarnt_flag)                               lend_blkt_guarnt_flag,
     TRIM(clint.orig_ack_batch_id_txt)                               orig_ack_batch_id_txt,
     TRIM(clint.orig_send_batch_id_txt)                              orig_send_batch_id_txt,
     TRIM(clint.pnote_delivery_code)                                 pnote_delivery_code,
     TRIM(clint.pnote_status_code)                                   pnote_status_code,
     TRIM(clint.prc_type_code)                                       prc_type_code,
     TRIM(clint.record_code)                                         record_code,
     TRIM(clint.repayment_opt_code)                                  repayment_opt_code,
     TRIM(clint.req_serial_loan_code)                                req_serial_loan_code,
     TRIM(clint.resp_to_orig_flag)                                   resp_to_orig_flag,
     TRIM(clint.rev_notice_of_guarnt_code)                           rev_notice_of_guarnt_code,
     TRIM(clint.s_default_status_flag)                               s_default_status_flag,
     TRIM(clint.s_signature_flag)                                    s_signature_flag,
     TRIM(clint.sch_non_ed_brc_id_txt)                               sch_non_ed_brc_id_txt,
     TRIM(clint.service_type_code)                                   service_type_code,
     TRIM(clint.stud_sign_flag)                                      stud_sign_flag,
     TRIM(clint.student_major_txt)                                   student_major_txt,
     TRIM(clint.uniq_layout_ident_code)                              uniq_layout_ident_code,
     TRIM(clint.uniq_layout_vend_code)                               uniq_layout_vend_code,
     TRIM(clint.orig_batch_id_txt)                                   orig_batch_id_txt,
     TRIM(clint.defer_req_flag)                                      defer_req_flag,
     TRIM(clint.b_license_state_code)                                b_license_state_code,
     TRIM(clint.b_license_number_txt)                                b_license_number_txt,
     TRIM(clint.send_resp_code)                                      send_resp_code,
     TRIM(clint.source_id_txt)                                       source_id_txt,
     TRIM(clint.source_non_ed_brc_id_txt)                            source_non_ed_brc_id_txt,
     TRIM(clint.import_record_type)                                  import_record_type,
     TRIM(clint.relationship_cd)                                     relationship_cd,  -- FA 122 Loans Enhancements,
     TRIM(clint.actual_record_type_code)                             actual_record_type_code,
     TRIM(clint.lend_apprv_denied_code)                              lend_apprv_denied_code,
     TRIM(clint.lend_apprv_denied_date)                              lend_apprv_denied_date,
     TRIM(clint.cl_rec_status)                                       cl_rec_status,
     TRIM(clint.appl_loan_phase_code)                                appl_loan_phase_code,
     TRIM(clint.mpn_confirm_code)                                    mpn_confirm_code,
     TRIM(clint.appl_loan_phase_code_chg)                            appl_loan_phase_code_chg,
     TRIM(clint.external_loan_id_txt)                                external_loan_id_txt,
     TRUNC(clint.other_loan_amt)                                     other_loan_amt,
     TRIM(clint.guarantor_use_txt)                                   guarantor_use_txt,
     TRIM(clint.lender_use_txt)                                      lender_use_txt,
     TRIM(clint.school_use_txt)                                      school_use_txt,
     TRIM(cl_rec_status_last_update)                                 cl_rec_status_last_update,
     TRIM(clint.cs1_lname)                                           cs1_lname,
     TRIM(clint.cs1_fname)                                           cs1_fname,
     TRIM(clint.cs1_mi_txt)                                          cs1_mi_txt,
     TRIM(clint.cs1_ssn_txt)                                         cs1_ssn_txt,
     TRIM(clint.cs1_citizenship_status)                              cs1_citizenship_status,
     TRIM(clint.cs1_address_line_1_txt)                              cs1_address_line_1_txt,
     TRIM(clint.cs1_address_line_2_txt)                              cs1_address_line_2_txt,
     TRIM(clint.cs1_city_txt)                                        cs1_city_txt,
     TRIM(clint.cs1_state_txt)                                       cs1_state_txt,
     TRIM(clint.cs1_zip_txt)                                         cs1_zip_txt,
     TRIM(clint.cs1_zip_suffix_txt)                                  cs1_zip_suffix_txt,
     TRIM(clint.cs1_telephone_number_txt)                            cs1_telephone_number_txt,
     TRIM(clint.cs1_signature_code_txt)                              cs1_signature_code_txt,
     TRIM(clint.cs2_lname)                                           cs2_lname,
     TRIM(clint.cs2_fname)                                           cs2_fname,
     TRIM(clint.cs2_mi_txt)                                          cs2_mi_txt,
     TRIM(clint.cs2_ssn_txt)                                         cs2_ssn_txt,
     TRIM(clint.cs2_citizenship_status)                              cs2_citizenship_status,
     TRIM(clint.cs2_address_line_1_txt)                              cs2_address_line_1_txt,
     TRIM(clint.cs2_address_line_2_txt)                              cs2_address_line_2_txt,
     TRIM(clint.cs2_city_txt)                                        cs2_city_txt,
     TRIM(clint.cs2_state_txt)                                       cs2_state_txt,
     TRIM(clint.cs2_zip_txt)                                         cs2_zip_txt,
     TRIM(clint.cs2_zip_suffix_txt)                                  cs2_zip_suffix_txt,
     TRIM(clint.cs2_telephone_number_txt)                            cs2_telephone_number_txt,
     TRIM(clint.cs2_signature_code_txt)                              cs2_signature_code_txt,
     TRIM(clint.cs1_credit_auth_code_txt)                            cs1_credit_auth_code_txt,
     TRUNC(clint.cs1_birth_date)                                     cs1_birth_date,
     TRIM(clint.cs1_drv_license_num_txt)                             cs1_drv_license_num_txt,
     TRIM(clint.cs1_drv_license_state_txt)                           cs1_drv_license_state_txt,
     SUBSTR(clint.cs1_elect_sig_ind_code_txt, 1, 1)                  cs1_elect_sig_ind_code_txt,        -- Since the elect sig can come in as " " for N, treating it the same way
     TRIM(clint.cs1_frgn_postal_code_txt)                            cs1_frgn_postal_code_txt,
     TRIM(clint.cs1_frgn_tel_num_prefix_txt)                         cs1_frgn_tel_num_prefix_txt,
     TRUNC(clint.cs1_gross_annual_sal_num)                           cs1_gross_annual_sal_num,
     TRIM(clint.cs1_mthl_auto_pay_txt)                               cs1_mthl_auto_pay_txt,
     TRIM(clint.cs1_mthl_cc_pay_txt)                                 cs1_mthl_cc_pay_txt,
     TRIM(clint.cs1_mthl_edu_loan_pay_txt)                           cs1_mthl_edu_loan_pay_txt,
     TRIM(clint.cs1_mthl_housing_pay_txt)                            cs1_mthl_housing_pay_txt,
     TRIM(clint.cs1_mthl_other_pay_txt)                              cs1_mthl_other_pay_txt,
     TRUNC(clint.cs1_other_income_amt)                               cs1_other_income_amt,
     TRIM(clint.cs1_rel_to_student_flag)                             cs1_rel_to_student_flag,
     TRIM(clint.cs1_suffix_txt)                                      cs1_suffix_txt,
     TRUNC(clint.cs1_years_at_address_txt)                           cs1_years_at_address_txt,
     TRIM(clint.cs2_credit_auth_code_txt)                            cs2_credit_auth_code_txt,
     TRUNC(clint.cs2_birth_date)                                     cs2_birth_date,
     TRIM(clint.cs2_drv_license_num_txt)                             cs2_drv_license_num_txt,
     TRIM(clint.cs2_drv_license_state_txt)                           cs2_drv_license_state_txt,
     SUBSTR(clint.cs2_elect_sig_ind_code_txt, 1, 1)                  cs2_elect_sig_ind_code_txt,        -- Since the elect sig can come in as " " for N, treating it the same way
     TRIM(clint.cs2_frgn_postal_code_txt)                            cs2_frgn_postal_code_txt,
     TRIM(clint.cs2_frgn_tel_num_prefix_txt)                         cs2_frgn_tel_num_prefix_txt,
     TRUNC(clint.cs2_gross_annual_sal_num)                           cs2_gross_annual_sal_num,
     TRIM(clint.cs2_mthl_auto_pay_txt)                               cs2_mthl_auto_pay_txt,
     TRIM(clint.cs2_mthl_cc_pay_txt)                                 cs2_mthl_cc_pay_txt,
     TRIM(clint.cs2_mthl_edu_loan_pay_txt)                           cs2_mthl_edu_loan_pay_txt,
     TRIM(clint.cs2_mthl_housing_pay_txt)                            cs2_mthl_housing_pay_txt,
     TRIM(clint.cs2_mthl_other_pay_txt)                              cs2_mthl_other_pay_txt,
     TRUNC(clint.cs2_other_income_amt)                               cs2_other_income_amt,
     TRIM(clint.cs2_rel_to_student_flag)                             cs2_rel_to_student_flag,
     TRIM(clint.cs2_suffix_txt)                                      cs2_suffix_txt,
     TRUNC(clint.cs2_years_at_address_txt)                           cs2_years_at_address_txt,
     TRIM(clint.esign_src_typ_cd) esign_src_typ_cd -- FA 161 - CL 4
     FROM
     igf_sl_li_orig_ints clint
     WHERE
     clint.batch_num          = cp_batch_id       AND
     clint.ci_alternate_code  = cp_alternate_code AND
     (clint.import_status_type = p_import_status_type_1 OR clint.import_status_type = p_import_status_type_2)
     ORDER BY clint.person_number;

     CURSOR c_disb_interface(cp_alternate_code   VARCHAR2,
                             cp_person_number    VARCHAR2,
                             cp_award_number_txt VARCHAR2,
                             cp_loan_number      VARCHAR2)
     IS
     SELECT
     TRUNC(dlint.disbursement_date)                disbursement_date,
     TRUNC(dlint.fund_release_date)                fund_release_date,
     TRUNC(dlint.guarantee_date)                   guarantee_date,
     TRUNC(dlint.pnote_status_date)                pnote_status_date,
     TRUNC(dlint.disbursement_status_date)         disbursement_status_date,
     TRUNC(dlint.fund_status_date)                 fund_status_date,
     TRUNC(dlint.file_creation_date)               file_creation_date,
     TRUNC(dlint.file_trans_date)                  file_trans_date,
     dlint.disbursement_num,
     dlint.sch_disbursement_num,
     dlint.guarantee_amt,
     dlint.gross_disbursement_amt,
     dlint.origination_fee_amt,
     dlint.guarantee_fee_amt,
     dlint.guarantee_fees_paid_amt,
     dlint.net_cancel_amt,
     dlint.origination_fees_paid_amt,
     dlint.netted_cancel_amt,
     dlint.outstd_cancel_amt,
     TRIM(dlint.ci_alternate_code)               ci_alternate_code,
     TRIM(dlint.person_number)                   person_number,
     TRIM(dlint.award_number_txt)                award_number_txt,
     TRIM(dlint.loan_number_txt)                 loan_number_txt,
     TRIM(dlint.record_type)                     record_type,
     TRIM(dlint.school_use_txt)                  school_use_txt,
     TRIM(dlint.lender_use_txt)                  lender_use_txt,
     TRIM(dlint.guarantor_use_txt)               guarantor_use_txt,
     TRIM(dlint.fund_dist_mthd_type)             fund_dist_mthd_type,
     TRIM(dlint.check_number_txt)                check_number_txt,
     TRIM(dlint.late_disbursement_flag)          late_disbursement_flag,
     TRIM(dlint.prev_reported_flag)              prev_reported_flag,
     TRIM(dlint.err_mesg_1_cd)                   err_mesg_1_cd,
     TRIM(dlint.err_mesg_2_cd)                   err_mesg_2_cd,
     TRIM(dlint.err_mesg_3_cd)                   err_mesg_3_cd,
     TRIM(dlint.err_mesg_4_cd)                   err_mesg_4_cd,
     TRIM(dlint.err_mesg_5_cd)                   err_mesg_5_cd,
     TRIM(dlint.disbursement_hld_release_flag)   disbursement_hld_release_flag,
     TRIM(dlint.pnote_code)                      pnote_code,
     TRIM(dlint.disbursement_status_code)        disbursement_status_code,
     TRIM(dlint.fund_status_code)                fund_status_code,
     TRIM(dlint.lender_name)                     lender_name,
     TRIM(dlint.roster_batch_id_txt)             roster_batch_id,
     TRIM(dlint.recipient_id_txt)                recipient_id_txt,
     TRIM(dlint.recipient_non_ed_brc_id_txt)     recipient_non_ed_brc_id_txt,
     TRIM(dlint.source_id_txt)                   source_id_txt,
     TRIM(dlint.source_non_ed_brc_id_txt)        source_non_ed_brc_id_txt,
     TRIM(dlint.send_resp_code)                  send_resp_code,
     TRIM(dlint.direct_to_borr_flag)             direct_to_borr_flag
     FROM
     igf_sl_li_org_disb_ints dlint
     WHERE
     dlint.ci_alternate_code     = cp_alternate_code    AND
     dlint.person_number         = cp_person_number     AND
     dlint.award_number_txt      = cp_award_number_txt  AND
     dlint.loan_number_txt       = cp_loan_number;

     CURSOR c_get_award (cp_base_id       NUMBER,
                         cp_award_number  VARCHAR2)
     IS
     SELECT    awd.award_id,
               awd.offered_amt,
               awd.accepted_amt,
               fcat.fed_fund_code,
               fcat.fund_code
     FROM      igf_aw_award_all     awd,
               igf_aw_fund_mast_all fmast,
               igf_aw_fund_cat_all  fcat
     WHERE     awd.base_id           = cp_base_id      AND
               awd.award_number_txt  = cp_award_number AND
               awd.fund_id           = fmast.fund_id   AND
               fmast.fund_code       = fcat.fund_code;

     l_get_award c_get_award%ROWTYPE;


PROCEDURE log_parameters(p_alternate_code  VARCHAR2,
                         p_batch_number    VARCHAR2,
                         p_del_ind         VARCHAR2)
IS
--
--  Created By : brajendr
--  Created On : 10-Jul-2003
--  Purpose : This process log the parameters in the log file
--  Known limitations, enhancements or remarks :
--  Change History :
--  Who             When            What
--  (reverse chronological order - newest change first)
--

-- Get the values from the lookups

    CURSOR c_get_parameters
    IS
    SELECT meaning, lookup_code
      FROM igf_lookups_view
     WHERE lookup_type = 'IGF_GE_PARAMETERS'
       AND lookup_code IN ('AWARD_YEAR',
                           'BATCH_NUMBER',
                           'DELETE_FLAG',
                           'PARAMETER_PASS',
                           'PROCESSING',
                           'LOAN_DISB',
                           'LOAN_RECORD',
                           'AWARD_YR_STATUS',
                           'PERSON_NUMBER');

    parameter_rec           c_get_parameters%ROWTYPE;


BEGIN

     OPEN c_get_parameters;
     LOOP
          FETCH c_get_parameters INTO  parameter_rec;
          EXIT WHEN c_get_parameters%NOTFOUND;

          IF parameter_rec.lookup_code ='AWARD_YEAR' THEN
            g_award_year    := TRIM(parameter_rec.meaning);

          ELSIF parameter_rec.lookup_code ='BATCH_NUMBER' THEN
            g_batch_num     := TRIM(parameter_rec.meaning);

          ELSIF parameter_rec.lookup_code ='DELETE_FLAG' THEN
            g_del_flag      := TRIM(parameter_rec.meaning);

          ELSIF parameter_rec.lookup_code ='PARAMETER_PASS' THEN
            g_para_pass     := TRIM(parameter_rec.meaning);

          ELSIF parameter_rec.lookup_code ='PROCESSING' THEN
            g_processing    := TRIM(parameter_rec.meaning);

          ELSIF parameter_rec.lookup_code ='LOAN_RECORD' THEN
            g_loan_record   := TRIM(parameter_rec.meaning);

          ELSIF parameter_rec.lookup_code ='LOAN_DISB' THEN
            g_loan_disb     := TRIM(parameter_rec.meaning);

          ELSIF parameter_rec.lookup_code ='PERSON_NUMBER' THEN
            g_person_number := TRIM(parameter_rec.meaning);

          ELSIF parameter_rec.lookup_code ='AWARD_YR_STATUS' THEN
            g_award_year_status_desc := TRIM(parameter_rec.meaning);
          END IF;

     END LOOP;
     CLOSE c_get_parameters;

     fnd_file.new_line(fnd_file.log,1);
     fnd_file.put_line(fnd_file.log, g_para_pass); --------------Parameters Passed--------------
     fnd_file.new_line(fnd_file.log,1);

     fnd_file.put_line(fnd_file.log, RPAD(g_award_year,40) || ' : '|| p_alternate_code);
     fnd_file.put_line(fnd_file.log, RPAD(g_batch_num,40)  || ' : '|| p_batch_number);
     fnd_file.put_line(fnd_file.log, RPAD(g_del_flag,40)   || ' : '|| p_del_ind);

     fnd_file.new_line(fnd_file.log,1);
     fnd_file.put_line(fnd_file.log, '--------------------------------------------------------');
     fnd_file.new_line(fnd_file.log,1);


  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_li_imp_pkg.log_parameters.exception','LOG_PARAMETERS :: ' || SQLERRM);
      END IF;
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_SL_CL_LI_IMP_PKG.LOG_PARAMETERS');
      igs_ge_msg_stack.add;

END log_parameters;


FUNCTION is_valid(p_loan_number IN VARCHAR2,
                  p_cal_type    IN VARCHAR2,
                  p_seq_number  IN VARCHAR2)

RETURN BOOLEAN
AS
--
--   Created By : gmuralid
--   Created On : 24-JUN-2003
--   Purpose : The function is used to validate loan number
--   Known limitations, enhancements or remarks :
--   Change History :
--   Who              When            What
--   ugummall         04-NOV-2003     Bug 3102439. FA 126 - Multiple FA Offices.
--                                    Renamed cursor c_ope_id to c_source_or_branch_id with one extra
--                                    parameter cp_source_type.
--   ugummall         21-OCT-2003     Bug 3102439. FA 126 - Multiple FA Offices.
--                                    Removed the cursor c_branch_id and its reference.
--                                    Modified the cursor c_ope_id so that cp_ope_id is
--                                    configured as an active OPEID in the system under any Org Unit.
--   (reverse chronological order - newest change first)
--

     CURSOR c_source_or_branch_id(cp_source_or_branch_id VARCHAR2, cp_source_type VARCHAR2)
     IS
      SELECT 1
        FROM hz_parties hz,
             igs_or_org_alt_ids oli,
             igs_or_org_alt_idtyp olt
       WHERE oli.org_structure_id = hz.party_number
         AND oli.org_alternate_id_type = olt.org_alternate_id_type
         AND SYSDATE BETWEEN oli.start_date AND NVL(oli.end_date, SYSDATE)
         AND hz.status = 'A'
         AND oli.org_alternate_id = cp_source_or_branch_id
         AND system_id_type = cp_source_type;


     l_source_or_branch_id   c_source_or_branch_id%ROWTYPE;

     l_part_1 VARCHAR2(8);
     l_part_2 VARCHAR2(4);
     l_part_3 VARCHAR2(3);

     l_part3_1 VARCHAR2(1);
     l_part3_2 VARCHAR2(1);
     l_part3_3 VARCHAR2(1);
     l_part_4  VARCHAR2(3);

     l_part4_1 VARCHAR2(1);
     l_part4_2 VARCHAR2(1);
     l_part4_3 VARCHAR2(1);

BEGIN

       l_part_1 := SUBSTR(p_loan_number,1,8);

       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_li_imp_pkg.is_valid.debug','IS_VALID: l_part_1 ' || l_part_1);
       END IF;

       OPEN c_source_or_branch_id(l_part_1, 'OPE_ID_NUM');
       FETCH c_source_or_branch_id INTO l_source_or_branch_id;
       IF (c_source_or_branch_id%NOTFOUND) THEN
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_li_imp_pkg.is_valid.debug','IS_VALID: l_part_1 not valid for school id' || l_part_1);
         END IF;
         CLOSE c_source_or_branch_id;
         RETURN FALSE;
       ELSE
         CLOSE c_source_or_branch_id;
       END IF;

       l_part_2 := SUBSTR(p_loan_number,7,4);

       IF l_part_2 <> '0000' THEN
         OPEN c_source_or_branch_id(l_part_2, 'SCH_NON_ED_BRC_ID');
         FETCH c_source_or_branch_id INTO l_source_or_branch_id;
         IF (c_source_or_branch_id%NOTFOUND) THEN
           IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_li_imp_pkg.is_valid.debug','IS_VALID: l_part_2 not valid for school non ed branch id' || l_part_2);
           END IF;
           CLOSE c_source_or_branch_id;
           RETURN FALSE;
         ELSE
           CLOSE c_source_or_branch_id;
         END IF;
       END IF;

       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_li_imp_pkg.is_valid.debug','IS_VALID: l_part_2 ' || l_part_2);
       END IF;

       l_part_3  :=  SUBSTR(p_loan_number,12,3);
       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_li_imp_pkg.is_valid.debug','IS_VALID: l_part_3 ' || l_part_3);
       END IF;
       l_part3_1 := SUBSTR(l_part_3,1,1);
       l_part3_2 := SUBSTR(l_part_3,2,1);
       l_part3_3 := SUBSTR(l_part_3,3,1);

       IF l_part3_1 NOT IN ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S') THEN
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_li_imp_pkg.is_valid.debug','IS_VALID: l_part3_1 ' || l_part3_1);
          END IF;
          RETURN FALSE;
       ELSIF (l_part3_1 = 'S') THEN
                IF l_part3_2 NOT IN ('0','1','2','3','4','5','6','7','8','9','A','B') THEN
                       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_li_imp_pkg.is_valid.debug','is_valid: l_part3_2 ' || l_part3_2);
                       END IF;
                       RETURN FALSE;
                END IF;
       ELSIF (l_part3_1 <> 'S') THEN
                IF l_part3_2 NOT IN  ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J',
                                'K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z') THEN
                       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_im_pkg.is_valid.debug','IS_VALID: l_part3_2 - II ' || l_part3_2);
                       END IF;
                       RETURN FALSE;
                END IF;
       ELSIF (l_part3_1 = 'S') AND (l_part3_2 = 'B') THEN
                IF l_part3_3 NOT IN ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F') THEN
                       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.is_valid.debug','IS_VALID: l_part3_3 ' || l_part3_3);
                       END IF;
                       RETURN FALSE;
                END IF;
       ELSIF (l_part3_1 <> 'S') OR (l_part3_2 <> 'B') THEN
                IF  l_part3_3 NOT IN  ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J',
                                'K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z') THEN
                       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.is_valid.debug','IS_VALID: l_part3_3 - II ' || l_part3_3);
                       END IF;
                       RETURN FALSE;
                END IF;
       END IF;

       l_part_4 := SUBSTR(p_loan_number,15,3);

       IF l_part_4 = '000' THEN
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.is_valid.debug','IS_VALID: l_part_4 ' || l_part_4);
          END IF;
          RETURN FALSE;
       ELSE
          l_part4_1 := SUBSTR(l_part_4,1,1);
          l_part4_2 := SUBSTR(l_part_4,2,1);
          l_part4_3 := SUBSTR(l_part_4,3,1);

          IF l_part4_1 NOT IN ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J',
                            'K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z') THEN

             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.is_valid.debug','IS_VALID: l_part4_1 ' || l_part4_1);
             END IF;
             RETURN FALSE;

           ELSIF l_part4_2 NOT IN ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J',
                                'K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z') THEN
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.is_valid.debug','IS_VALID: l_part4_2 ' || l_part4_2);
             END IF;
             RETURN FALSE;

           ELSIF l_part4_3 NOT IN ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J',
                                'K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z') THEN
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.is_valid.debug','IS_VALID: l_part4_3 ' || l_part4_3);
             END IF;
             RETURN FALSE;

           END IF;
        END IF;

       RETURN TRUE;

END is_valid;

FUNCTION validate_release( l_interface    IN   c_interface%ROWTYPE,
                           p_cal_type     IN   VARCHAR2,
                           p_seq_number   IN   NUMBER,
                           p_fed_fund_cd  IN   VARCHAR2)
RETURN BOOLEAN AS
  /*
  ||  Created By : pssahni
  ||  Created On : 3-Nov-2004
  ||  Purpose : FA134 Enhancements
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || bvisvana         14-Nov-2005     Bug # 4732538 - Validation of Fed appl form code based on release and fund type
  ||  (reverse chronological order - newest change first)
  */


-- Get the release version
CURSOR c_get_rel_ver(p_rel_code igf_sl_cl_setup_all.relationship_cd%TYPE, p_cal_type VARCHAR2 , p_seq_num NUMBER)
IS
  SELECT cl_version
    FROM igf_sl_cl_setup_all
   WHERE ci_cal_type = p_cal_type
     AND ci_sequence_number = p_seq_num
     AND relationship_cd= p_rel_code;

 get_rel_ver_rec    c_get_rel_ver%ROWTYPE;

  CURSOR c_num_disb         (cp_alternate_code   VARCHAR2,
                             cp_person_number    VARCHAR2,
                             cp_award_number_txt VARCHAR2,
                             cp_loan_number      VARCHAR2)
     IS
     SELECT
      count(*)
     FROM
     igf_sl_li_org_disb_ints
     WHERE
     ci_alternate_code     = cp_alternate_code    AND
     person_number         = cp_person_number     AND
     award_number_txt      = cp_award_number_txt  AND
     loan_number_txt       = cp_loan_number;

l_num_disb             NUMBER;

check_passed BOOLEAN       := TRUE;

BEGIN


-- Check the release version
    OPEN c_get_rel_ver(l_interface.relationship_cd, p_cal_type, p_seq_number);
    FETCH c_get_rel_ver INTO get_rel_ver_rec;
    CLOSE c_get_rel_ver;

    g_rel_version              := get_rel_ver_rec.cl_version;

    IF get_rel_ver_rec.cl_version NOT IN ('RELEASE-4', 'RELEASE-5') THEN
        fnd_message.set_name('IGF','IGF_SL_CL_VERSION_NTFND');
        g_tab_index := g_tab_index + 1;
        g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
        check_passed := FALSE;

    ELSIF get_rel_ver_rec.cl_version='RELEASE-4' THEN

        -- Release 4 cannot have more than 4 disbursments

        OPEN c_num_disb(l_interface.ci_alternate_code,l_interface.person_number,l_interface.award_number_txt,l_interface.loan_number_txt);
        FETCH c_num_disb INTO l_num_disb;
        IF l_num_disb > 4 THEN
            fnd_message.set_name('IGF','IGF_SL_CL4_DISB_EXCEED');
            g_tab_index := g_tab_index + 1;
            g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
            check_passed := FALSE;
        END IF;
        CLOSE c_num_disb;

        -- Check for Actual Record Type
          IF l_interface.actual_record_type_code NOT IN ('M' , 'N' , 'C', 'T' ) OR l_interface.actual_record_type_code IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','ACTUAL_RECORD_TYPE_CODE');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              check_passed := FALSE;
          END IF;

        -- Checking for a valid combination of Processing type, send record code and Response record code

        IF l_interface.record_code = 'A' THEN
           IF (l_interface.prc_type_code  IN ('GO' , 'GP' ) ) AND (l_interface.actual_record_type_code  IN ('M')) THEN
              NULL;
           ELSE
              fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_RT_RC');
              g_tab_index := g_tab_index + 1;
              g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
               check_passed := FALSE;
          END IF;

        ELSIF l_interface.record_code = 'C' THEN
          IF (l_interface.prc_type_code IN ('GO' , 'GP' ) ) AND (l_interface.actual_record_type_code IN ('M')) THEN
              NULL;
           ELSE
              fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_RT_RC');
              g_tab_index := g_tab_index + 1;
              g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
               check_passed := FALSE;
          END IF;

        ELSIF l_interface.record_code = 'R' THEN
          IF (l_interface.prc_type_code  IN ( 'GP' ) ) AND (l_interface.actual_record_type_code  IN ('N')) THEN
              NULL;
           ELSE
              fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_RT_RC');
              g_tab_index := g_tab_index + 1;
              g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
               check_passed := FALSE;
          END IF;

        ELSIF l_interface.record_code = 'T' THEN
          IF (l_interface.prc_type_code  IN ( 'GO','GP' ) ) AND ( l_interface.actual_record_type_code  IN ('T')) THEN
              NULL;
           ELSE
              fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_RT_RC');
              g_tab_index := g_tab_index + 1;
              g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
               check_passed := FALSE;
          END IF;

        END IF;

        --Record status and Actual record type cannot be populated simultaneously

        IF (l_interface.cl_rec_status IS NOT NULL ) AND (l_interface.actual_record_type_code IS NOT NULL ) THEN
              fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_RT_RC');
              g_tab_index := g_tab_index + 1;
              g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
              check_passed := FALSE;
        END IF;

        -- If lender approved denied date and code needs to be specified together

        IF      (l_interface.lend_apprv_denied_code IS NULL) AND (l_interface.lend_apprv_denied_date IS NOT NULL)
             OR (l_interface.lend_apprv_denied_code IS NOT NULL) AND (l_interface.lend_apprv_denied_date IS NULL)
             THEN
              fnd_message.set_name('IGF','IGF_SL_CL_INVLD_LADCD');
              g_tab_index := g_tab_index + 1;
              g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
              check_passed := FALSE;
        END IF;

        -- If lender approved denied code is D then record status must also be D

        IF l_interface.lend_apprv_denied_code='D' AND l_interface.cl_rec_status <> 'D' THEN
             fnd_message.set_name('IGF','IGF_SL_INVLD_LADC_RS');
             g_tab_index := g_tab_index + 1;
             g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
             check_passed := FALSE;
        END IF;

        -- Validate application form code
        -- Bug # 4732538
        IF l_interface.fed_appl_form_type IS NOT NULL THEN
          IF ((p_fed_fund_cd IN ('FLS','FLU') AND l_interface.fed_appl_form_type NOT IN ('B','M','P'))  OR
              (p_fed_fund_cd IN ('FLP') AND l_interface.fed_appl_form_type NOT IN ('Q','B','M','P'))OR
              (p_fed_fund_cd IN ('GPLUSFL') AND l_interface.fed_appl_form_type NOT IN ('G')))
              THEN
             g_tab_index := g_tab_index + 1;
             fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
             fnd_message.set_token('FIELD','FED_APPL_FORM_TYPE');
             g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
             check_passed := FALSE;
          END IF;
       END IF;


        -- Check if any of the release 5 fields are populated then raise an error

        IF l_interface.borr_sign_flag IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','BORR_SIGN_FLAG');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.borr_credit_auth_flag  IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','BORR_CREDIT_AUTH_FLAG');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.Sch_non_ed_brc_id_txt  IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','SCH_NON_ED_BRC_ID_TXT');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.stud_sign_flag   IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','STUD_SIGN_FLAG');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.guarnt_status_code   IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','GUARNT_STATUS_CODE');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.lend_status_code    IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','LEND_STATUS_CODE');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.pnote_status_code    IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','PNOTE_STATUS_CODE');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.Credit_status_code    IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','CREDIT_STATUS_CODE');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.guarnt_status_date     IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','GUARNT_STATUS_DATE');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.lend_status_date     IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','LEND_STATUS_DATE');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.pnote_status_date    IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','PNOTE_STATUS_DATE');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.credit_status_date     IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','CREDIT_STATUS_DATE');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.act_serial_loan_code     IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','ACT_SERIAL_LOAN_CODE');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.stud_mth_housing_pymt_amt      IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','STUD_MTH_HOUSING_PYMT_AMT');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.stud_mth_crdtcard_pymt_amt IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','STUD_MTH_CRDTCARD_PYMT_AMT');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.stud_mth_auto_pymt_amt IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','STUD_MTH_AUTO_PYMT_AMT');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.stud_mth_ed_loan_pymt_amt  IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','STUD_MTH_ED_LOAN_PYMT_AMT');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.stud_mth_other_pymt_amt  IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','STUD_MTH_OTHER_PYMT_AMT');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;


    ELSIF get_rel_ver_rec.cl_version='RELEASE-5' THEN

        -- Release 5 cannot have more than 20 disbursments

        OPEN c_num_disb(l_interface.ci_alternate_code,l_interface.person_number,l_interface.award_number_txt,l_interface.loan_number_txt);
        FETCH c_num_disb INTO l_num_disb;
        IF l_num_disb > 20 THEN
            fnd_message.set_name('IGF','IGF_SL_CL4_DISB_EXCEED');
            g_tab_index := g_tab_index + 1;
            g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
            check_passed := FALSE;
        END IF;
        CLOSE c_num_disb;
           -- Check for Actual Record Type
          IF l_interface.actual_record_type_code NOT IN ('M' , 'N' , 'C', 'T', 'S' ) OR l_interface.actual_record_type_code IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','ACTUAL_RECORD_TYPE_CODE');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              check_passed := FALSE;
          END IF;

      -- Checking for a valid combination of Processing type, send record code and Response record code

        IF l_interface.record_code = 'A' THEN
           IF (l_interface.prc_type_code IN ('GO' , 'GP' ) )AND(l_interface.actual_record_type_code  IN ('S','M')) THEN
              NULL;
           ELSE
              fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_RT_RC');
              g_tab_index := g_tab_index + 1;
              g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
              check_passed := FALSE;
           END IF;

        ELSIF l_interface.record_code = 'C' THEN
          IF (l_interface.prc_type_code  IN ('GO' , 'GP' )) AND (l_interface.actual_record_type_code IN ('S','M'))THEN
              NULL;
           ELSE
              fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_RT_RC');
              g_tab_index := g_tab_index + 1;
              g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
              check_passed := FALSE;
          END IF;

        ELSIF l_interface.record_code = 'R' THEN
          IF (l_interface.prc_type_code IN ( 'GP' ) ) AND (l_interface.actual_record_type_code  IN ('N')) THEN
              NULL;
           ELSE
              fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_RT_RC');
              g_tab_index := g_tab_index + 1;
              g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
              check_passed := FALSE;
          END IF;

        ELSIF l_interface.record_code = 'T' THEN
          IF (l_interface.prc_type_code IN ( 'GO','GP' ) )AND (l_interface.actual_record_type_code  IN ('S','T')) THEN
              NULL;
           ELSE
              fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_RT_RC');
              g_tab_index := g_tab_index + 1;
              g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
              check_passed := FALSE;
          END IF;

        END IF;



      -- Validate application form code
              -- Bug # 4732538
        IF l_interface.fed_appl_form_type IS NOT NULL THEN
          IF ((p_fed_fund_cd IN ('FLS','FLU') AND l_interface.fed_appl_form_type  IN ('M','P')) OR
              (p_fed_fund_cd IN ('FLP') AND l_interface.fed_appl_form_type  IN ('Q','M','P')) OR
              (p_fed_fund_cd IN ('GPLUSFL') AND l_interface.fed_appl_form_type  IN ('G'))) THEN
             NULL;
          ELSE
             g_tab_index := g_tab_index + 1;
             fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
             fnd_message.set_token('FIELD','FED_APPL_FORM_TYPE');
             g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
             check_passed := FALSE;
          END IF;
        END IF;

      -- Check if any of the release 4 fields are populated then raise an error

        IF l_interface.cl_rec_status  IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','CL_REC_STATUS');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.lend_apprv_denied_code  IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','LEND_APPRV_DENIED_CODE');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.lend_apprv_denied_date  IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','LEND_APPRV_DENIED_DATE');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.appl_loan_phase_code  IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','APPL_LOAN_PHASE_CODE');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.mpn_confirm_code  IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','MPN_CONFIRM_CODE');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.appl_loan_phase_code_chg  IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','APPL_LOAN_PHASE_CODE_CHG');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;


        IF l_interface.lend_apprv_denied_code  IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','LEND_APPRV_DENIED_CODE');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;

        IF l_interface.lend_apprv_denied_date  IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','LEND_APPRV_DENIED_DATE');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;


    END IF;  -- ver not in rel-4 or rel-5

    -- External loan number required if record tpye is C
    IF l_interface.record_code = 'C' THEN
        IF l_interface.external_loan_id_txt IS NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_SL_CL_SCR_XLID_NTFND');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;
    ELSE
        IF l_interface.external_loan_id_txt IS NOT NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_SL_CL_SCR_XLID_FND');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           check_passed := FALSE;
        END IF;
    END IF;


RETURN check_passed;

EXCEPTION
  WHEN others THEN
   IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_imp_pkg.validate_release.exception','Exception ' || SQLERRM);
   END IF;
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_SL_CL_LI_IMP_PKG.VALIDATE_RELEASE');

   RAISE IMPORT_ERROR;
END;


PROCEDURE validate_loan_orig_int( p_interface     IN  c_interface%ROWTYPE,
                                  p_award_id      IN  NUMBER,
                                  p_status        OUT NOCOPY BOOLEAN,
                                  p_cal_type      IN  VARCHAR2,
                                  p_seq_number    IN  NUMBER,
                                  p_open_flag     IN  BOOLEAN,
                                  p_fed_fund_cd   IN  VARCHAR2
                                  )
AS
--
--    Created By : gmuralid
--    Created On : 24-JUN-2003
--    Purpose : This procedure is used to validate the loan origination interface record
--    Known limitations, enhancements or remarks :
--    Change History :
--    Who             When            What
--    pssahni        3-Nov-2004       validation for prc_type_cpde changed to have valid values GP and GO
--                                    also added validation for combination of process type and record code
--    bkkumar         10-apr-04       FACR116 - Added validation for the alt_prog_typ_code
--                                    and corrected the validations for the 'ALT' Loan
--    ugummall        21-OCT-2003     Bug 3102439. FA 126 - Multiple FA Offices.
--                                    Added the validation for sch_non_ed_brc_id_txt is a valid Non Ed Brc Id
--                                    that is setup as alternate identifier in the System.
--    bkkumar         07-oct-2003     Bug 3104228 . Added the validation for the relationship code.
--                                    present in the interface table.
--    (reverse chronological order - newest change first)
--    veramach       16-SEP-2003      Validation for prc_type_code changed to look into 'GP' only

     l_valid         BOOLEAN;

     l_amt           NUMBER;
     lv_person_id    NUMBER;
     lv_base_id      NUMBER;

     l_result        VARCHAR2(1);

     CURSOR c_lender_id(cp_lender_id VARCHAR2)
     IS
     SELECT
     1
     FROM
     igf_sl_lender
     WHERE
     lender_id = cp_lender_id;

     l_lender_id   c_lender_id%ROWTYPE;

     CURSOR c_guarantor_id(cp_guarnt_id VARCHAR2)
     IS
     SELECT
     1
     FROM
     igf_sl_guarantor
     WHERE
     guarantor_id = cp_guarnt_id;

     l_guarantor_id  c_guarantor_id%ROWTYPE;

--5026901, SQL Repository
     CURSOR c_relationship (cp_person_number   VARCHAR2,
                            cp_b_person_number VARCHAR2
                            )
     IS
     SELECT 'X'
     FROM hz_relationships pr,
          igs_pe_hz_parties pe,
          hz_parties br,
          hz_parties st
     WHERE
          br.party_number = cp_b_person_number
     AND  st.party_number = cp_person_number
     AND  pr.subject_id = st.party_id
     AND  pr.object_id =  br.party_id
     AND  st.party_id = pe.party_id;


     l_relationship c_relationship%ROWTYPE;

     CURSOR  cur_chk_grd (p_cal_type    VARCHAR2,
                          p_seq_number  NUMBER,
                          p_grd_lvl     VARCHAR2)
     IS
     SELECT '1'
     FROM
     igf_ap_class_std_map
     WHERE
     cl_std_code = p_grd_lvl AND
     ppt_id IN
          (
               SELECT ppt_id
               FROM   igf_ap_pr_prg_type
               WHERE  sequence_number = p_seq_number AND
                      cal_type        = p_cal_type
          );

     lv_grd VARCHAR2(1);

     CURSOR  cur_chk_enrl (p_cal_type    VARCHAR2,
                           p_seq_number   NUMBER,
                           p_enrl_code    VARCHAR2)
     IS
     SELECT '1'
     FROM
     igf_ap_attend_map_v
     WHERE
     cl_att_code     = p_enrl_code  AND
     sequence_number = p_seq_number AND
     cal_type        = p_cal_type;

     lv_enrl VARCHAR2(1);

 -- FA 122 Loan Enhancements
     CURSOR  cur_chk_rel_code (p_cal_type    VARCHAR2,
                               p_seq_number   NUMBER,
                               p_rel_code    VARCHAR2)
     IS
     SELECT relationship_cd
     FROM
     igf_sl_cl_setup
     WHERE
     ci_cal_type        = p_cal_type  AND
     ci_sequence_number = p_seq_number AND
     NVL(relationship_cd,'*')    = p_rel_code;

     l_chk_rel_code    cur_chk_rel_code%ROWTYPE;

    CURSOR c_get_alternate_code(cp_cal_type VARCHAR2,
                                 cp_seq_number NUMBER)
     IS
     SELECT alternate_code
     FROM   igs_ca_inst
     WHERE  cal_type = cp_cal_type
     AND    sequence_number = cp_seq_number;

     l_get_alternate_code  c_get_alternate_code%ROWTYPE;

  -- Cursor to validate School Non Educational Branch Id.
     CURSOR c_source_or_branch_id(cp_sch_non_ed_brc_id VARCHAR2, cp_source_type VARCHAR2)
     IS
      SELECT 1
        FROM hz_parties hz,
             igs_or_org_alt_ids oli,
             igs_or_org_alt_idtyp olt
       WHERE oli.org_structure_id = hz.party_number
         AND oli.org_alternate_id_type = olt.org_alternate_id_type
         AND SYSDATE BETWEEN oli.start_date AND NVL(oli.end_date, SYSDATE)
         AND hz.status = 'A'
         AND oli.org_alternate_id = cp_sch_non_ed_brc_id
         AND system_id_type = cp_source_type;

     l_source_or_branch_id   c_source_or_branch_id%ROWTYPE;

   -- FACR116
     CURSOR c_get_fund_code ( cp_alt_loan_code igf_aw_fund_cat_all.alt_loan_code%TYPE,
                              cp_alt_rel_code  igf_aw_fund_cat_all.alt_rel_code%TYPE,
                              cp_fund_code     igf_aw_fund_cat_all.fund_code%TYPE
                             )

     IS
     SELECT fund_code
     FROM   igf_aw_fund_cat_all
     WHERE  NVL(alt_loan_code,'*') = cp_alt_loan_code
     AND    NVL(alt_rel_code,'*') = cp_alt_rel_code
     AND    fund_code = cp_fund_code;

     l_get_fund_code  c_get_fund_code%ROWTYPE;
      PROCEDURE set_message_and_flag(       p_message_name       VARCHAR,
                                            p_val                VARCHAR,
                                            p_cosigner_number    NUMBER) AS
      BEGIN
          fnd_message.set_name('IGF',     p_message_name);
          fnd_message.set_token('VAL',    p_val);
          fnd_message.set_token('CS_NO',  p_cosigner_number);
          g_tab_index := g_tab_index + 1;
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
          p_status := FALSE;
      END set_message_and_flag;


      PROCEDURE validate_alt_loan_cosigner (p_cosigner_number             NUMBER,
                                            p_ssn_txt                       igf_sl_li_orig_ints.cs1_ssn_txt%TYPE,
                                            p_citizenship_status            igf_sl_li_orig_ints.cs1_citizenship_status%TYPE,
                                            p_state_txt                     igf_sl_li_orig_ints.cs1_state_txt%TYPE,
                                            p_drv_license_state_txt         igf_sl_li_orig_ints.cs1_drv_license_state_txt%TYPE,
                                            p_signature_code_txt            igf_sl_li_orig_ints.cs1_signature_code_txt%TYPE,
                                            p_credit_auth_code_txt          igf_sl_li_orig_ints.cs1_credit_auth_code_txt%TYPE,
                                            p_elect_sig_ind_code_txt        igf_sl_li_orig_ints.cs1_elect_sig_ind_code_txt%TYPE,
                                            p_rel_to_student_flag           igf_sl_li_orig_ints.cs1_rel_to_student_flag%TYPE
                                          ) AS
      --
      --
      --  This procedure is used to validate the cosigner data
      --  which is expected to be validated only for
      --  ALT loans.
      --  FA 157 - Bug# - 4382371
      --
      --  mnade         6/15/2005         Creation of the procedure.
      --
      --
      CURSOR c_citizenship_codes (cp_lookup_code      VARCHAR2) IS
        SELECT lookup_code
        FROM igf_aw_lookups_view
        WHERE
          lookup_type             = 'IGF_SL_ALT_CS_US_CT_ST_CODE'
          AND cal_type            = p_cal_type
          AND sequence_number     = p_seq_number
          AND enabled_flag        = 'Y'
          AND lookup_code         = cp_lookup_code;

      CURSOR c_state_codes (cp_lookup_code      VARCHAR2) IS
        SELECT lookup_code
        FROM igf_aw_lookups_view
        WHERE
          lookup_type             = 'IGF_AP_STATE_CODES'
          AND cal_type            = p_cal_type
          AND sequence_number     = p_seq_number
          AND enabled_flag        = 'Y'
          AND lookup_code         NOT IN ('BL', 'CN', 'MX', 'OT')
          AND lookup_code         = cp_lookup_code;

      CURSOR c_yes_no_codes (cp_lookup_code      VARCHAR2) IS                   -- Used for Signature/Credit Aut/Elect Sig validations.
        SELECT lookup_code
        FROM igf_aw_lookups_view
        WHERE
          lookup_type             = 'YES_NO'
          AND cal_type            = p_cal_type
          AND sequence_number     = p_seq_number
          AND enabled_flag        = 'Y'
          AND lookup_code         = cp_lookup_code;

      CURSOR c_relationship_codes (cp_lookup_code      VARCHAR2) IS
        SELECT lookup_code
        FROM igf_aw_lookups_view
        WHERE
          lookup_type             = 'IGF_SL_ALT_CS_STUDENT_RELATION'
          AND cal_type            = p_cal_type
          AND sequence_number     = p_seq_number
          AND enabled_flag        = 'Y'
          AND lookup_code         = cp_lookup_code;

      l_lookup_code               igf_aw_lookups_view.lookup_code%TYPE;

      BEGIN
        IF  SUBSTR(p_ssn_txt,1,1)  = '8' OR                                                   -- SSN Validations - CL Spec - 8/9/000 at start not permitted.
            SUBSTR(p_ssn_txt,1,1)    = '9' OR
            SUBSTR(p_ssn_txt,1,3)    = '000' OR
            LENGTH(NVL(p_ssn_txt, '123456789')) <> 9 THEN
            set_message_and_flag('IGF_SL_CL_ALT_CS_INV_SSN', p_ssn_txt, p_cosigner_number);
        END IF;                                                                               -- END SSN Validations - CL Spec - 8/9/000 at start not permitted.

        -- Citizenship Validations
        OPEN c_citizenship_codes (p_citizenship_status);
        FETCH c_citizenship_codes INTO l_lookup_code;
        IF c_citizenship_codes%NOTFOUND AND p_citizenship_status IS NOT NULL THEN
          set_message_and_flag('IGF_SL_CL_ALT_CS_INV_CT_STATUS', p_citizenship_status, p_cosigner_number);
        END IF;
        CLOSE c_citizenship_codes;

        -- State Validations
        OPEN c_state_codes (p_state_txt);
        FETCH c_state_codes INTO l_lookup_code;
        IF c_state_codes%NOTFOUND AND p_state_txt IS NOT NULL THEN
          set_message_and_flag('IGF_SL_CL_ALT_CS_INV_STATE', p_state_txt, p_cosigner_number);
        ELSE
          IF l_lookup_code = 'FC' THEN
            fnd_message.set_name('IGF',     'IGF_SL_CL_ALT_CS_STATE_COUNTRY');
            g_tab_index := g_tab_index + 1;
            g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
          END IF;
        END IF;
        CLOSE c_state_codes;

        -- Drivers State Validations
        OPEN c_state_codes (p_drv_license_state_txt);
        FETCH c_state_codes INTO l_lookup_code;
        IF c_state_codes%NOTFOUND AND p_drv_license_state_txt IS NOT NULL THEN
          set_message_and_flag('IGF_SL_CL_ALT_CS_INV_LIC_STATE', p_drv_license_state_txt, p_cosigner_number);
        END IF;
        CLOSE c_state_codes;

        -- Signature Code Validations
        OPEN c_yes_no_codes (p_signature_code_txt);
        FETCH c_yes_no_codes INTO l_lookup_code;
        IF c_yes_no_codes%NOTFOUND AND p_signature_code_txt IS NOT NULL THEN
          set_message_and_flag('IGF_SL_CL_ALT_CS_INV_SIG_CODE', p_signature_code_txt, p_cosigner_number);
        END IF;
        CLOSE c_yes_no_codes;

        -- Relationship Validations
        OPEN c_relationship_codes (p_rel_to_student_flag);
        FETCH c_relationship_codes INTO l_lookup_code;
        IF c_relationship_codes%NOTFOUND AND p_rel_to_student_flag IS NOT NULL THEN
          set_message_and_flag('IGF_SL_CL_ALT_CS_INV_REL_CODE', p_rel_to_student_flag, p_cosigner_number);
        END IF;
        CLOSE c_relationship_codes;

        IF g_rel_version = 'RELEASE-5' THEN             -- CL5 ALT loans specific validations

          -- Credit Autcode Validations
          OPEN c_yes_no_codes (p_credit_auth_code_txt);
          FETCH c_yes_no_codes INTO l_lookup_code;
          IF c_yes_no_codes%NOTFOUND AND p_credit_auth_code_txt IS NOT NULL THEN
            set_message_and_flag('IGF_SL_CL_ALT_CS_INV_CRD_AUTH', p_credit_auth_code_txt, p_cosigner_number);
          END IF;
          CLOSE c_yes_no_codes;

          -- Elect Sig Code Validations
          OPEN c_yes_no_codes (p_elect_sig_ind_code_txt);
          FETCH c_yes_no_codes INTO l_lookup_code;
          IF c_yes_no_codes%NOTFOUND AND p_elect_sig_ind_code_txt IS NOT NULL THEN
            set_message_and_flag('IGF_SL_CL_ALT_CS_INV_ELECT_SIG', p_elect_sig_ind_code_txt, p_cosigner_number);
          END IF;
          CLOSE c_yes_no_codes;

        END IF;                                         -- END CL5 ALT loans specific validations

      END validate_alt_loan_cosigner;

BEGIN

     g_tab_index := 0;
     l_valid     := is_valid(p_interface.loan_number_txt,p_cal_type,p_seq_number);

     IF NOT l_valid THEN

          fnd_message.set_name('IGF','IGF_SL_CL_INV_LOAN_NUM');
          g_tab_index := g_tab_index + 1;
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
          p_status := FALSE;

     END IF;

     l_get_alternate_code := NULL;
     OPEN c_get_alternate_code(p_cal_type,p_seq_number);
     FETCH c_get_alternate_code INTO l_get_alternate_code;
     CLOSE c_get_alternate_code;

     -- FA 122 Loans Enhancements Check for the relationship code
     IF p_interface.relationship_cd IS NULL THEN
       fnd_message.set_name('IGF','IGF_SL_CL_RELATION_CD_FAIL');
       fnd_message.set_token('REL_CODE','NULL');
       fnd_message.set_token('AWD_YR',l_get_alternate_code.alternate_code);
       g_tab_index := g_tab_index + 1;
       g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
       p_status := FALSE;
     ELSE
       l_chk_rel_code := NULL;
       OPEN  cur_chk_rel_code(p_cal_type,p_seq_number,p_interface.relationship_cd);
       FETCH cur_chk_rel_code INTO l_chk_rel_code;
       CLOSE cur_chk_rel_code;
       IF l_chk_rel_code.relationship_cd IS NULL THEN
        fnd_message.set_name('IGF','IGF_SL_CL_RELATION_CD_FAIL');
        fnd_message.set_token('REL_CODE',p_interface.relationship_cd);
        fnd_message.set_token('AWD_YR',l_get_alternate_code.alternate_code);
        g_tab_index := g_tab_index + 1;
        g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
        p_status := FALSE;
       END IF;
     END IF;
     l_get_fund_code := NULL;
     -- FACR116 Grant Loan Changes
     -- 1. Check if the alt_prg_type_cd is not null for 'ALT' loan
     -- 2. If the alt_prg_type_cd and the relationship_cd are assosiated in the fund code setup
     IF p_fed_fund_cd = 'ALT' THEN
        IF p_interface.alt_prog_type_cd IS NULL THEN
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','ALT_PROG_TYPE_CD');
           g_tab_index := g_tab_index + 1;
           g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
           p_status := FALSE;
        END IF;
        OPEN c_get_fund_code(p_interface.alt_prog_type_cd,p_interface.relationship_cd,l_get_award.fund_code);
        FETCH c_get_fund_code INTO l_get_fund_code;
        CLOSE c_get_fund_code;
        IF l_get_fund_code.fund_code IS NULL THEN
           fnd_message.set_name('IGF','IGF_SL_ALT_INV_SETUP');
           fnd_message.set_token('FUND_CODE',l_get_award.fund_code);
           fnd_message.set_token('ALT_LOAN_CODE',p_interface.alt_prog_type_cd);
           fnd_message.set_token('REL_CODE',p_interface.relationship_cd);
           g_tab_index := g_tab_index + 1;
           g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
           p_status := FALSE;
        END IF;
     ELSIF p_interface.alt_prog_type_cd IS NOT NULL THEN -- If fund_code <> 'ALT' then alt_prog_type_cd shd be NULL
        fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
        fnd_message.set_token('FIELD','ALT_PROG_TYPE_CD');
        g_tab_index := g_tab_index + 1;
        g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
        p_status := FALSE;
     END IF;

      -- Validate release information : FA 134
      -- bvisvana - Bug # 4732538 - Validation of Fed appl form code based on Release type and fed fund code
      -- Added p_fed_fund_cd as a new parameter to the function
      p_status  :=  validate_release (p_interface,p_cal_type,p_seq_number,p_fed_fund_cd);  -- set error if the function returns false

-- credit decision can be 	01   Unknown
--                        	05   Not applicable
--                        	10   Awaiting Credit
--                        	15   Credit check performed
--                        	20   Credit denied
--                        	25   Credit on appeal
--                        	30   Appeal denied
--                        	35   Credit approved

-- FA134 : guarnt_status_code, lend_status_code, pnote_status_code are Release -5 field only
     IF g_rel_version = 'RELEASE-5' THEN
       IF ( p_open_flag = TRUE ) THEN
            IF (p_interface.loan_status_code = 'A') AND
                 (( p_interface.prc_type_code <> 'GP') OR (p_interface.guarnt_status_code <> '40')
                 OR (p_interface.lend_status_code <> '45') OR (p_interface.pnote_status_code <> '60')
                 OR (p_interface.credit_status_code NOT IN ('01','05','10','15','20','25','30','35') ) )
                 THEN

                 fnd_message.set_name('IGF','IGF_SL_CL_LOAN_STATUS_ERR');
                 fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
                 p_status := FALSE;

            END IF;
       END IF;
     END IF;

     IF ( p_fed_fund_cd NOT IN('ALT','FLP','GPLUSFL') ) AND (p_interface.borr_person_number IS NOT NULL)
     THEN

          fnd_message.set_name('IGF','IGF_SL_CL_BORW_NOT_REQD');
          fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
          p_status := FALSE;

     END IF;

     IF (p_fed_fund_cd IN ('ALT','FLP','GPLUSFL')) AND (p_interface.borr_person_number IS NULL )
     THEN

          fnd_message.set_name('IGF','IGF_SL_CL_BOR_NUM_REQD');
          fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
          p_status := FALSE;

     END IF;

     IF p_fed_fund_cd <> 'ALT' AND p_interface.b_stu_indicator_flag IS NOT NULL THEN
          fnd_message.set_name('IGF','IGF_SL_CL_INV_BOR_STU_IND');
          g_tab_index := g_tab_index + 1;
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
          p_status := FALSE;

     ELSIF p_fed_fund_cd = 'ALT' AND p_interface.loan_status_code = 'A' AND p_interface.b_stu_indicator_flag IS NULL THEN
          fnd_message.set_name('IGF','IGF_SL_CL_INV_BOR_STU_IND');
          g_tab_index := g_tab_index + 1;
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
          p_status := FALSE;
     END IF;

     IF p_fed_fund_cd = 'ALT' AND p_interface.b_stu_indicator_flag IS NOT NULL THEN
       IF  igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_interface.b_stu_indicator_flag) IS NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','B_STU_INDICATOR_FLAG');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           p_status := FALSE;
        END IF;
     END IF;

     IF p_fed_fund_cd IN ('ALT')
        AND p_interface.borr_person_number IS NOT NULL
        AND NVL(p_interface.b_stu_indicator_flag,'X') = 'Y'
        AND p_interface.borr_person_number <> p_interface.person_number
     THEN

          fnd_message.set_name('IGF','IGF_SL_CL_S_BOR_NOT_SAME');
          fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
          p_status := FALSE;

     END IF;

     --FA 163 : For Federal Graduate plus loans, borrower and student should be same
     IF p_fed_fund_cd IN ('GPLUSFL') THEN
        IF p_interface.borr_person_number <> p_interface.person_number THEN
             fnd_message.set_name('IGF','IGF_SL_CL_STU_BOR_DIFFER');
             fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
             p_status := FALSE;
        ELSE
             igf_ap_gen.check_person(p_interface.borr_person_number,NULL,NULL,lv_person_id,lv_base_id);
             IF lv_person_id IS NULL THEN
                  fnd_message.set_name('IGF','IGF_SL_LI_INVALID_BORR');
                  fnd_message.set_token('PERS_NUM', p_interface.borr_person_number);
                  fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
                  p_status := FALSE;
             ELSE
                  g_p_person_id := lv_person_id;
             END IF;
        END IF;
     END IF;


     IF p_fed_fund_cd IN ('ALT','FLP')
        AND p_interface.borr_person_number IS NOT NULL
        AND NVL(p_interface.b_stu_indicator_flag,'X') <> 'Y'
     THEN

          igf_ap_gen.check_person(p_interface.borr_person_number,NULL,NULL,lv_person_id,lv_base_id);

          IF lv_person_id IS NULL THEN
                fnd_message.set_name('IGF','IGF_SL_LI_INVALID_BORR');
                fnd_message.set_token('PERS_NUM', p_interface.borr_person_number);
                fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
                p_status := FALSE;
          ELSE

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.validate_loan_orig_int.debug','Borr Person ID ' || lv_person_id);
                END IF;
                g_p_person_id := lv_person_id;

                OPEN c_relationship(p_interface.person_number,p_interface.borr_person_number);
                FETCH c_relationship INTO l_relationship;
                IF (c_relationship%NOTFOUND) THEN
                     CLOSE c_relationship;
                     fnd_message.set_name('IGF','IGF_SL_CL_INV_BOR_REL');
                     fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
                     p_status := FALSE;
                ELSE
                     CLOSE c_relationship;
                END IF;
          END IF;
     END IF;

     IF p_interface.loan_seq_num IS NOT NULL THEN
        IF (p_interface.loan_seq_num <= 0) OR (p_interface.loan_seq_num > 99) THEN
           fnd_message.set_name('IGF','IGF_SL_CL_INV_LOAN_SEQ_NUM');
           g_tab_index := g_tab_index + 1;
           g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
           p_status := FALSE;
        END IF;
     END IF;

     IF (p_interface.loan_per_end_date < p_interface.loan_per_begin_date) THEN
           fnd_message.set_name('IGF','IGF_SL_CL_LOAN_INV_END_DT');
           g_tab_index := g_tab_index + 1;
           g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
           p_status := FALSE;
     END IF;

     IF (p_interface.loan_status_code IN ('B','C','R','S','T'))
           OR (igf_ap_gen.get_aw_lookup_meaning('IGF_SL_LOAN_STATUS',p_interface.loan_status_code,g_sys_award_year)) IS NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','LOAN_STATUS_CODE');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           p_status := FALSE;
     END IF;

     IF  igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_interface.active_flag) IS NULL THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','ACTIVE_FLAG');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           p_status := FALSE;
     END IF;

     IF p_interface.defer_req_flag IS NOT NULL THEN
          IF  igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_interface.defer_req_flag) IS NULL THEN
                g_tab_index := g_tab_index + 1;
                fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
                fnd_message.set_token('FIELD','DEFER_REQ_FLAG');
                g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
                p_status := FALSE;
          END IF;

     END IF;

     IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_REC_TYPE_IND',p_interface.record_code,g_sys_award_year) IS NULL THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','RECORD_CODE');
          g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;


     IF (p_interface.loan_status_code = 'A') AND (p_interface.req_loan_amt IS NULL) THEN
           fnd_message.set_name('IGF','IGF_SL_CL_REQ_LOAN_AMT_REQD');
            g_tab_index := g_tab_index + 1;
            g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
            p_status := FALSE;
     ELSIF (p_interface.req_loan_amt IS NOT NULL) THEN

         l_amt := l_get_award.accepted_amt;

         IF (l_amt IS NULL) OR (l_amt <> p_interface.req_loan_amt) THEN
             fnd_message.set_name('IGF','IGF_SL_CL_INV_REQ_LOAN_AMT');
             g_tab_index := g_tab_index + 1;
             g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
             p_status := FALSE;
         END IF;
     END IF;

     IF (p_interface.borw_interest_flag IS NOT NULL) THEN
          IF (igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_interface.borw_interest_flag) IS NULL) THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','BORW_INTEREST_FLAG');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
           END IF;
      END IF;

     IF p_interface.b_signature_flag IS NOT NULL THEN
         IF igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_interface.b_signature_flag) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','B_SIGNATURE_FLAG');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
          END IF;
     END IF;

     IF (p_fed_fund_cd NOT IN ('FLP','ALT','GPLUSFL')) AND ((p_interface.b_default_status_flag IS NOT NULL)) THEN
          fnd_message.set_name('IGF','IGF_SL_CL_INV_DEF_RETURN_CD');
          g_tab_index := g_tab_index + 1;
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
          p_status := FALSE;

     ELSIF (p_fed_fund_cd IN ('FLP','ALT','GPLUSFL')) AND (p_interface.b_default_status_flag IS NOT NULL) THEN
          IF igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_interface.b_default_status_flag) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','B_DEFAULT_STATUS_FLAG');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
          END IF;
     END IF;

     IF (p_fed_fund_cd NOT IN ('FLP','ALT','GPLUSFL')) AND ((p_interface.borw_outstd_loan_flag IS NOT NULL)) THEN
          fnd_message.set_name('IGF','IGF_SL_CL_BORW_OUTSTD_LOAN_CD');
          g_tab_index := g_tab_index + 1;
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
          p_status := FALSE;

     ELSIF (p_fed_fund_cd IN ('FLP','ALT','GPLUSFL')) AND (p_interface.borw_outstd_loan_flag IS NOT NULL) THEN
          IF igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_interface.borw_outstd_loan_flag) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','BORW_OUTSTD_LOAN_FLAG');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
          END IF;
     END IF;

     IF (p_fed_fund_cd NOT IN ('FLP','ALT','GPLUSFL')) AND ((p_interface.s_default_status_flag IS NOT NULL)) THEN
           fnd_message.set_name('IGF','IGF_SL_CL_STUD_DEF_REFND_CD');
           g_tab_index := g_tab_index + 1;
           g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
           p_status := FALSE;

     ELSIF (p_fed_fund_cd IN ('FLP','ALT','GPLUSFL')) AND (p_interface.s_default_status_flag IS NOT NULL) THEN
           IF igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_interface.s_default_status_flag) IS NULL THEN
                g_tab_index := g_tab_index + 1;
                fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
                fnd_message.set_token('FIELD','S_DEFAULT_STATUS_FLAG');
                g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
                p_status := FALSE;
           END IF;
     END IF;

     IF (p_fed_fund_cd NOT IN ('FLP','ALT','GPLUSFL')) AND ((p_interface.s_signature_flag IS NOT NULL)) THEN
          fnd_message.set_name('IGF','IGF_SL_CL_INV_STU_SIGNATURE');
          g_tab_index := g_tab_index + 1;
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
          p_status := FALSE;

     ELSIF (p_fed_fund_cd IN ('FLP','ALT','GPLUSFL')) AND (p_interface.s_signature_flag IS NOT NULL) THEN
          IF igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_interface.s_signature_flag) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','S_SIGNATURE_FLAG');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
          END IF;
     END IF;

     IF p_interface.grade_level_code IS NULL THEN
          fnd_message.set_name('IGF','IGF_SL_CL_GRADE_LVL_REQD');
          g_tab_index := g_tab_index + 1;
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
          p_status := FALSE;
     ELSIF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_CL_GRADE_LEVEL',p_interface.grade_level_code,g_sys_award_year) IS NULL THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','GRADE_LEVEL_CODE');
          g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;

     ELSE
          OPEN  cur_chk_grd (p_cal_type,
                             p_seq_number,
                             p_interface.grade_level_code);
          FETCH cur_chk_grd INTO lv_grd;
          CLOSE cur_chk_grd;
          IF NVL(lv_grd,'*') <> '1' THEN
               g_tab_index := g_tab_index + 1;
               fnd_message.set_name('IGF','IGF_SL_INV_GRD_VAL');
               fnd_message.set_token('GRD_LVL',p_interface.grade_level_code);
               g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
               p_status := FALSE;
          END IF;
     END IF;

     IF p_interface.borr_sign_flag IS NOT NULL THEN
         IF igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_interface.borr_sign_flag) IS NULL THEN
               g_tab_index := g_tab_index + 1;
               fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
               fnd_message.set_token('FIELD','BORR_SIGN_FLAG');
               g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
               p_status := FALSE;
          END IF;
     END IF;

     IF p_interface.eft_auth_flag IS NOT NULL THEN
         IF igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_interface.eft_auth_flag) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','EFT_AUTH_FLAG');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
          END IF;
     END IF;

     IF (p_interface.loan_status_code = 'A') AND (p_interface.anticip_compl_date IS NULL) THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_SL_INV_ANT_COM');
          g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF (p_interface.loan_status_code = 'A') AND (p_interface.enrollment_code IS NULL) THEN
          fnd_message.set_name('IGF','IGF_SL_CL_ENRL_CD_REQD');
          g_tab_index := g_tab_index + 1;
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
          p_status := FALSE;

     ELSIF p_interface.enrollment_code IS NOT NULL THEN

          IF   igf_ap_gen.get_aw_lookup_meaning('IGF_SL_CL_ENROL_STATUS',p_interface.enrollment_code,g_sys_award_year) IS NULL THEN
               g_tab_index := g_tab_index + 1;
               fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
               fnd_message.set_token('FIELD','ENROLLMENT_CODE');
               g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
               p_status := FALSE;
          ELSE
          --
          -- Check if enrollment code mapping is done
          --
              OPEN   cur_chk_enrl(p_cal_type,p_seq_number,p_interface.enrollment_code);
              FETCH  cur_chk_enrl INTO lv_enrl;
              CLOSE  cur_chk_enrl;

              IF NVL(lv_enrl,'*') <> '1' THEN
                 g_tab_index := g_tab_index + 1;
                 fnd_message.set_name('IGF','IGF_SL_INV_ENRL_CODE');
                 fnd_message.set_token('ENRL_CODE',p_interface.enrollment_code);
                 g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
                 p_status := FALSE;
              END IF;
          END IF;

     END IF;

     IF (p_fed_fund_cd NOT IN ('ALT')) AND (p_interface.alt_appl_ver_code_num IS NOT NULL) THEN
          fnd_message.set_name('IGF','IGF_SL_CL_INV_ALT_APPL_VER_CD');
          g_tab_index := g_tab_index + 1;
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
          p_status := FALSE;
     END IF;

     IF p_interface.req_serial_loan_code IS NOT NULL THEN
        IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_SERIAL_LOAN_CODE',p_interface.req_serial_loan_code,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','REQ_SERIAL_LOAN_CODE');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
        END IF;
     END IF;

     IF p_interface.borr_credit_auth_flag IS NOT NULL THEN
        IF igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_interface.borr_credit_auth_flag) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','BORR_CREDIT_AUTH_FLAG');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
        END IF;
     END IF;

    -- FA 134 : STUD_SIGN_FLAG  is a Release -5 field only
     IF g_rel_version = 'RELEASE-5' THEN
       IF (p_fed_fund_cd NOT IN ('FLP','ALT','GPLUSFL')) AND ((p_interface.stud_sign_flag IS NOT NULL)) THEN
            fnd_message.set_name('IGF','IGF_SL_INV_STUD_SIGN_CODE');
            g_tab_index := g_tab_index + 1;
            g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
            p_status := FALSE;

       ELSIF (p_fed_fund_cd IN ('FLP','ALT','GPLUSFL')) AND (p_interface.stud_sign_flag IS NOT NULL) THEN
            IF igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_interface.stud_sign_flag) IS NULL THEN
                g_tab_index := g_tab_index + 1;
                fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
                fnd_message.set_token('FIELD','STUD_SIGN_FLAG');
                g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
                p_status := FALSE;
            END IF;
       END IF;
     END IF;

     IF p_interface.prc_type_code IS NULL THEN
          fnd_message.set_name('IGF','IGF_SL_CL_PRC_TYP_CD_REQD');
          g_tab_index := g_tab_index + 1;
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
          p_status := FALSE;

     ELSIF  p_interface.prc_type_code NOT IN ('GP', 'GO') THEN
        IF  igf_ap_gen.get_aw_lookup_meaning('IGF_SL_PRC_TYPE_CODE',p_interface.prc_type_code,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','PRC_TYPE_CODE');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
        END IF;
     END IF;

    -- Check for the combination of processing type and record code

    IF (p_interface.prc_type_code ='GO' AND p_interface.record_code IN ('A', 'C', 'T' ))
        OR (p_interface.prc_type_code ='GP' AND p_interface.record_code IN ('A', 'C', 'T','R' ))

      THEN
        -- Valid Combination
        NULL;
    ELSE
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_SL_CL_INV_COMB_PT_RC');
          g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
    END IF;



     IF p_interface.service_type_code IS NOT NULL THEN
        IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_CL_SERV_CD',p_interface.service_type_code,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','SERVICE_TYPE_CODE');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
        END IF;
     END IF;

     IF p_interface.rev_notice_of_guarnt_code IS NOT NULL THEN
        IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_CL_REV_GUARNT_CD',p_interface.rev_notice_of_guarnt_code,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','REV_NOTICE_OF_GUARNT_CODE');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
        END IF;
     END IF;

     IF p_interface.pnote_delivery_code IS NOT NULL THEN
        IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_PNOTE_DELIVERY',p_interface.pnote_delivery_code,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','PNOTE_DELIVERY_CODE');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
        END IF;
     END IF;

     IF (p_interface.loan_status_code = 'N' OR p_interface.loan_status_code = 'G') AND (p_interface.guarnt_adj_flag IS NOT NULL) THEN
          fnd_message.set_name('IGF','IGF_SL_CL_INV_GUARNT_ADJ_FLG');
          g_tab_index := g_tab_index + 1;
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
          p_status := FALSE;
     ELSIF p_interface.guarnt_adj_flag IS NOT NULL THEN
         IF igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_interface.guarnt_adj_flag) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','GUARNT_ADJ_FLAG');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)  || fnd_message.get;
              p_status := FALSE;
         END IF;
     END IF;

     IF (p_interface.loan_status_code = 'N' OR p_interface.loan_status_code = 'G') AND (p_interface.guarantee_date IS NOT NULL) THEN
         fnd_message.set_name('IGF','IGF_SL_CL_INV_GUARNT_DATE');
         g_tab_index := g_tab_index + 1;
         g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
         p_status := FALSE;
     ELSIF (p_interface.loan_status_code = 'A') AND (p_interface.guarantee_date IS NULL) THEN
         fnd_message.set_name('IGF','IGF_SL_CL_INV_GUARNT_DATE');
         g_tab_index := g_tab_index + 1;
         g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
         p_status := FALSE;
     END IF;

     IF (p_interface.loan_status_code = 'N' OR p_interface.loan_status_code = 'G') AND (p_interface.guarantee_amt IS NOT NULL) THEN
         fnd_message.set_name('IGF','IGF_SL_CL_INV_GUARNT_AMT');
         g_tab_index := g_tab_index + 1;
         g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
         p_status := FALSE;
     ELSIF (p_interface.loan_status_code = 'A') AND (p_interface.guarantee_amt IS NULL) THEN
         fnd_message.set_name('IGF','IGF_SL_CL_INV_GUARNT_AMT');
         g_tab_index := g_tab_index + 1;
         g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
         p_status := FALSE;
     END IF;

     IF p_interface.borw_confirm_flag IS NOT NULL THEN
        IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_BORW_CONFIRM',p_interface.borw_confirm_flag,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','BORW_CONFIRM_FLAG');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
        END IF;
     END IF;

     IF p_interface.last_resort_lender_flag IS NOT NULL THEN
        IF igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_interface.last_resort_lender_flag) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','LAST_RESORT_LENDER_FLAG');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
        END IF;
     END IF;

     IF p_interface.resp_to_orig_flag IS NOT NULL THEN
        IF igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_interface.resp_to_orig_flag) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','RESP_TO_ORIG_FLAG');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
        END IF;
     END IF;

     IF (p_interface.loan_status_code = 'N' OR p_interface.loan_status_code = 'G') AND (p_interface.guarnt_amt_redn_code IS NOT NULL) THEN
         fnd_message.set_name('IGF','IGF_SL_CL_INV_G_AMT_REDN_CD');
         g_tab_index := g_tab_index + 1;
         g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
         p_status := FALSE;
     ELSIF p_interface.guarnt_amt_redn_code IS NOT NULL THEN
        IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_GUARNT_AMT_RED_CODE',p_interface.guarnt_amt_redn_code,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','GUARNT_AMT_REDN_CODE');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
        END IF;
     END IF;

    -- FA 134 : GUARNT_STATUS_CODE is a Release -5 field only
     IF g_rel_version = 'RELEASE-5' THEN
       IF (p_interface.loan_status_code = 'N' OR p_interface.loan_status_code = 'G') AND (p_interface.guarnt_status_code IS NOT NULL) THEN
           fnd_message.set_name('IGF','IGF_SL_CL_INV_G_STATUS_CODE');
           g_tab_index := g_tab_index + 1;
           g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
           p_status := FALSE;
       ELSIF (p_interface.loan_status_code = 'A') AND (p_interface.guarnt_status_code IS NULL) THEN
           fnd_message.set_name('IGF','IGF_SL_CL_INV_G_STATUS_CODE');
           g_tab_index := g_tab_index + 1;
           g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
           p_status := FALSE;
       ELSIF p_interface.guarnt_status_code IS NOT NULL THEN
         IF  igf_ap_gen.get_aw_lookup_meaning('IGF_SL_GUARNT_STATUS',p_interface.guarnt_status_code,g_sys_award_year) IS NULL THEN
                g_tab_index := g_tab_index + 1;
                fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
                fnd_message.set_token('FIELD','GUARNT_STATUS_CODE');
                g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
                p_status := FALSE;
          END IF;
       END IF;
     END IF;

     -- FA 134: is a Release -5 field only
     IF g_rel_version = 'RELEASE-5' THEN
       IF (p_interface.loan_status_code = 'N' OR p_interface.loan_status_code = 'G') AND
          (p_interface.guarnt_status_date IS NOT NULL) THEN

           fnd_message.set_name('IGF','IGF_SL_CL_INV_G_STATUS_DATE');
           g_tab_index := g_tab_index + 1;
           g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
           p_status := FALSE;

       ELSIF (p_interface.loan_status_code = 'A') AND (p_interface.guarnt_status_date IS NULL) THEN

           fnd_message.set_name('IGF','IGF_SL_CL_INV_G_STATUS_DATE');
           g_tab_index := g_tab_index + 1;
           g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
           p_status := FALSE;

       END IF;
     END IF;

     -- FA 134: lend_status_code is a Release -5 field only
     IF g_rel_version = 'RELEASE-5' THEN
       IF (p_interface.loan_status_code = 'N' OR p_interface.loan_status_code = 'G') AND (p_interface.lend_status_code IS NOT NULL) THEN
           fnd_message.set_name('IGF','IGF_SL_CL_INV_L_STATUS_CODE');
           g_tab_index := g_tab_index + 1;
           g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
           p_status := FALSE;
       ELSIF (p_interface.loan_status_code = 'A') AND (p_interface.lend_status_code IS NULL) THEN
           fnd_message.set_name('IGF','IGF_SL_CL_INV_L_STATUS_CODE');
           g_tab_index := g_tab_index + 1;
           g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
           p_status := FALSE;
       ELSIF p_interface.lend_status_code IS NOT NULL THEN
          IF  igf_ap_gen.get_aw_lookup_meaning('IGF_SL_LEND_STATUS',p_interface.lend_status_code,g_sys_award_year) IS NULL THEN
                g_tab_index := g_tab_index + 1;
                fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
                fnd_message.set_token('FIELD','LEND_STATUS_CODE');
                g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
                p_status := FALSE;
           END IF;
       END IF;
     END IF;

     -- FA 134:lend_status_date is a Release -5 field only
     IF g_rel_version = 'RELEASE-5' THEN
       IF (p_interface.loan_status_code = 'N' OR p_interface.loan_status_code = 'G') AND
          (p_interface.lend_status_date  IS NOT NULL) THEN

           fnd_message.set_name('IGF','IGF_SL_CL_INV_L_STATUS_DATE');
           g_tab_index := g_tab_index + 1;
           g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
           p_status := FALSE;

       ELSIF (p_interface.loan_status_code = 'A') AND (p_interface.lend_status_date IS NULL) THEN

           fnd_message.set_name('IGF','IGF_SL_CL_INV_L_STATUS_DATE');
           g_tab_index := g_tab_index + 1;
           g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
           p_status := FALSE;

       END IF;
     END IF;

     -- FA 134: PNOTE_STATUS is a Release -5 field only
     IF g_rel_version = 'RELEASE-5' THEN
       IF (p_interface.loan_status_code = 'N' OR p_interface.loan_status_code = 'G') AND (p_interface.pnote_status_code IS NOT NULL) THEN
           fnd_message.set_name('IGF','IGF_SL_CL_INV_PNOTE_STATUS');
           g_tab_index := g_tab_index + 1;
           g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
           p_status := FALSE;
       ELSIF (p_interface.loan_status_code = 'A') AND (p_interface.pnote_status_code IS NULL) THEN
           fnd_message.set_name('IGF','IGF_SL_CL_INV_PNOTE_STATUS');
           g_tab_index := g_tab_index + 1;
           g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
           p_status := FALSE;
       ELSIF p_interface.pnote_status_code IS NOT NULL THEN
         IF p_interface.pnote_status_code IN ('A','C','F','G','I','M','N','P','Q','R','S','X')
          OR (igf_ap_gen.get_aw_lookup_meaning('IGF_SL_PNOTE_STATUS',p_interface.pnote_status_code,g_sys_award_year) IS NULL) THEN

                g_tab_index := g_tab_index + 1;
                fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
                fnd_message.set_token('FIELD','PNOTE_STATUS_CODE');
                g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
                p_status := FALSE;
          END IF;
       END IF;
     END IF;

     -- FA 134: is a Release -5 field only
     IF g_rel_version = 'RELEASE-5' THEN
       IF (p_interface.loan_status_code = 'N' OR p_interface.loan_status_code = 'G') AND
          (p_interface.pnote_status_date IS NOT NULL) THEN

           fnd_message.set_name('IGF','IGF_SL_CL_INV_P_STATUS_DATE');
           g_tab_index := g_tab_index + 1;
           g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
           p_status := FALSE;

       ELSIF (p_interface.loan_status_code = 'A') AND (p_interface.pnote_status_date IS NULL) THEN

           fnd_message.set_name('IGF','IGF_SL_CL_INV_P_STATUS_DATE');
           g_tab_index := g_tab_index + 1;
           g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
           p_status := FALSE;

       END IF;
     END IF;

     -- FA 134: credit_status_code is a Release -5 field only
     IF g_rel_version = 'RELEASE-5' THEN
       IF (p_interface.loan_status_code = 'N' OR p_interface.loan_status_code = 'G') AND
          (p_interface.credit_status_code IS NOT NULL) THEN
           fnd_message.set_name('IGF','IGF_SL_CL_INV_C_STATUS_CODE');
           g_tab_index := g_tab_index + 1;
           g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
           p_status := FALSE;

       ELSIF (p_interface.loan_status_code = 'A') AND (p_interface.credit_status_code IS NULL) THEN
           fnd_message.set_name('IGF','IGF_SL_CL_INV_C_STATUS_CODE');
           g_tab_index := g_tab_index + 1;
           g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
           p_status := FALSE;

       ELSIF p_interface.credit_status_code IS NOT NULL THEN
         IF p_interface.credit_status_code IN ('C','D','E','N')
          OR (igf_ap_gen.get_aw_lookup_meaning('IGF_SL_CREDIT_OVERRIDE',p_interface.credit_status_code,g_sys_award_year) IS NULL) THEN
                g_tab_index := g_tab_index + 1;
                fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
                fnd_message.set_token('FIELD','CREDIT_STATUS_CODE');
                g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
                p_status := FALSE;
          END IF;
       END IF;
     END IF;

     -- FA 134: credit_status_date is a Release -5 field only
     IF g_rel_version = 'RELEASE-5' THEN
       IF (p_interface.loan_status_code = 'N' OR p_interface.loan_status_code = 'G') AND
          (p_interface.credit_status_date IS NOT NULL) THEN

           fnd_message.set_name('IGF','IGF_SL_CL_INV_C_STATUS_DATE');
           g_tab_index := g_tab_index + 1;
           g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
           p_status := FALSE;

       ELSIF (p_interface.loan_status_code = 'A') AND (p_interface.credit_status_date IS NULL) THEN

           fnd_message.set_name('IGF','IGF_SL_CL_INV_C_STATUS_DATE');
           g_tab_index := g_tab_index + 1;
           g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
           p_status := FALSE;

       END IF;
     END IF;

     IF p_fed_fund_cd = 'ALT' AND p_interface.crdt_undr_difft_name_flag IS NOT NULL THEN
        IF igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_interface.crdt_undr_difft_name_flag) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','CRDT_UNDR_DIFFT_NAME_FLAG');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
        END IF;
     ELSIF p_fed_fund_cd <> 'ALT' AND p_interface.crdt_undr_difft_name_flag IS NOT NULL THEN
        fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
        fnd_message.set_token('FIELD','CRDT_UNDR_DIFFT_NAME_FLAG');
        g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
        p_status := FALSE;
     END IF;

     -- FA 134:ACT_SERIAL_LOAN_CODE is a Release -5 field only
     IF g_rel_version = 'RELEASE-5' THEN
       IF p_interface.act_serial_loan_code IS NOT NULL THEN
         IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_SERIAL_LOAN_CODE',p_interface.act_serial_loan_code,g_sys_award_year) IS NULL THEN
                g_tab_index := g_tab_index + 1;
                fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
                fnd_message.set_token('FIELD','ACT_SERIAL_LOAN_CODE');
                g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
                p_status := FALSE;
         END IF;
       END IF;
     END IF;

     IF p_interface.int_rate_opt_code IS NOT NULL THEN
         IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_ALT_INT_RATE_OPTION',p_interface.int_rate_opt_code,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','INT_RATE_OPT_CODE');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
         END IF;
     END IF;

     IF p_interface.repayment_opt_code IS NOT NULL THEN
         IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_ALT_REPAY_OPTION',p_interface.repayment_opt_code,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','REPAYMENT_OPT_CODE');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
         END IF;
     END IF;

     IF  (p_fed_fund_cd = 'ALT' AND NVL(p_interface.alt_borw_tot_stu_loan_debt_amt,0) < 0 )  OR (
            p_fed_fund_cd <> 'ALT' AND p_interface.alt_borw_tot_stu_loan_debt_amt IS NOT NULL )   THEN
           g_tab_index := g_tab_index + 1;
           fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
           fnd_message.set_token('FIELD','ALT_BORW_TOT_STU_LOAN_DEBT_AMT');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           p_status := FALSE;
     END IF;

     IF NVL(p_interface.reinst_avail_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','REINST_AVAIL_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF (p_fed_fund_cd = 'ALT' AND NVL(p_interface.borw_gross_annual_sal_amt,0) < 0) OR (
            p_fed_fund_cd <> 'ALT' AND  p_interface.borw_gross_annual_sal_amt IS NOT NULL ) THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','BORW_GROSS_ANNUAL_SAL_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF (p_fed_fund_cd = 'ALT' AND NVL(p_interface.borw_other_income_amt,0) < 0 ) OR (
           p_fed_fund_cd <> 'ALT' AND  p_interface.borw_other_income_amt IS NOT NULL ) THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','BORW_OTHER_INCOME_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF NVL(p_interface.coa_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','COA_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF NVL(p_interface.efc_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','EFC_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF NVL(p_interface.est_fa_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','EST_FA_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF NVL(p_interface.alt_approved_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','ALT_APPROVED_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF p_fed_fund_cd <> 'ALT' AND p_interface.alt_approved_amt IS NOT NULL THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_SL_INV_ALT_APP_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF p_fed_fund_cd = 'ALT' AND p_interface.alt_approved_amt IS NULL THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_SL_INV_ALT_APP_AMT_1');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF NVL(p_interface.flp_approved_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','FLP_APPROVED_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF p_fed_fund_cd NOT IN ('FLP','GPLUSFL') AND p_interface.flp_approved_amt IS NOT NULL THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_SL_INV_FLP_APP_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF p_fed_fund_cd IN ('FLP','GPLUSFL') AND p_interface.flp_approved_amt IS NULL THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_SL_INV_FLP_APP_AMT_1');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF NVL(p_interface.fls_approved_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','FLS_APPROVED_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF p_fed_fund_cd <> 'FLS' AND p_interface.fls_approved_amt IS NOT NULL THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_SL_INV_FLS_APP_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF p_fed_fund_cd = 'FLS' AND p_interface.fls_approved_amt IS NULL THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_SL_INV_FLS_APP_AMT_1');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF NVL(p_interface.flu_approved_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','FLU_APPROVED_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF p_fed_fund_cd <> 'FLU' AND p_interface.flu_approved_amt IS NOT NULL THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_SL_INV_FLU_APP_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF p_fed_fund_cd = 'FLU' AND p_interface.flu_approved_amt IS NULL THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_SL_INV_FLU_APP_AMT_1');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF NVL(p_interface.alt_cert_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','ALT_CERT_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF p_fed_fund_cd <> 'ALT' AND p_interface.alt_cert_amt IS NOT NULL THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_SL_INV_ALT_CRT_AMT_1');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF p_fed_fund_cd = 'ALT' AND p_interface.loan_status_code = 'A' AND p_interface.alt_cert_amt IS NULL THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_SL_INV_ALT_CRT_AMT_2');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF NVL(p_interface.flp_cert_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','FLP_CERT_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF p_fed_fund_cd NOT IN ('FLP','GPLUSFL') AND p_interface.flp_cert_amt IS NOT NULL THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_SL_INV_FLP_CRT_AMT_1');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF p_fed_fund_cd IN ('FLP','GPLUSFL') AND p_interface.loan_status_code = 'A' AND p_interface.flp_cert_amt IS NULL THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_SL_INV_FLP_CRT_AMT_2');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF NVL(p_interface.fls_cert_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','FLS_CERT_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF p_fed_fund_cd <> 'FLS' AND p_interface.fls_cert_amt IS NOT NULL THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_SL_INV_FLS_CRT_AMT_1');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF p_fed_fund_cd = 'FLS' AND p_interface.loan_status_code = 'A' AND p_interface.fls_cert_amt IS NULL THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_SL_INV_FLS_CRT_AMT_2');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF NVL(p_interface.flu_cert_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','FLU_CERT_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF p_fed_fund_cd <> 'FLU' AND p_interface.flu_cert_amt IS NOT NULL THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_SL_INV_FLU_CRT_AMT_1');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF p_fed_fund_cd = 'FLU' AND p_interface.loan_status_code = 'A' AND p_interface.flu_cert_amt IS NULL THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_SL_INV_FLU_CRT_AMT_2');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF NVL(p_interface.guarantee_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','GUARANTEE_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF NVL(p_interface.req_loan_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','REQ_LOAN_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF NVL(p_interface.sch_refund_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','SCH_REFUND_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF NVL(p_interface.tot_outstd_plus_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','TOT_OUTSTD_PLUS_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF NVL(p_interface.tot_outstd_stafford_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','TOT_OUTSTD_STAFFORD_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     -- ALT

     IF (p_fed_fund_cd = 'ALT' AND NVL(p_interface.fed_sls_debt_amt,0) < 0) OR (
           p_fed_fund_cd <> 'ALT' AND p_interface.fed_sls_debt_amt IS NOT NULL ) THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','FED_SLS_DEBT_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF NVL(p_interface.fed_stafford_loan_debt_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','FED_STAFFORD_LOAN_DEBT_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF (p_fed_fund_cd = 'ALT' AND NVL(p_interface.heal_debt_amt,0) < 0 ) OR (
           p_fed_fund_cd <> 'ALT' AND p_interface.heal_debt_amt IS NOT NULL ) THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','HEAL_DEBT_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF (p_fed_fund_cd = 'ALT' AND NVL(p_interface.other_debt_amt,0) < 0  ) OR (
            p_fed_fund_cd <> 'ALT' AND p_interface.other_debt_amt IS NOT NULL ) THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','OTHER_DEBT_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF (p_fed_fund_cd = 'ALT' AND NVL(p_interface.perkins_debt_amt,0) < 0 ) OR (
           p_fed_fund_cd <> 'ALT' AND p_interface.perkins_debt_amt IS NOT NULL) THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','PERKINS_DEBT_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF (p_fed_fund_cd = 'ALT' AND NVL(p_interface.stud_mth_auto_pymt_amt,0) < 0 ) OR (
           p_fed_fund_cd <> 'ALT' AND p_interface.stud_mth_auto_pymt_amt IS NOT NULL ) THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','STUD_MTH_AUTO_PYMT_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     -- FA 134: STUD_MTH_CRDTCARD_PYMT_AMT,STUD_MTH_ED_LOAN_PYMT_AMT,STUD_MTH_HOUSING_PYMT_AMT,STUD_MTH_OTHER_PYMT_AMT is a Release -5 field only
     IF g_rel_version = 'RELEASE-5' THEN
       IF NVL(p_interface.stud_mth_crdtcard_pymt_amt,0) < 0 THEN
            g_tab_index := g_tab_index + 1;
            fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
            fnd_message.set_token('FIELD','STUD_MTH_CRDTCARD_PYMT_AMT');
            g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
            p_status := FALSE;
       END IF;

       IF NVL(p_interface.stud_mth_ed_loan_pymt_amt,0) < 0 THEN
            g_tab_index := g_tab_index + 1;
            fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
            fnd_message.set_token('FIELD','STUD_MTH_ED_LOAN_PYMT_AMT');
            g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
            p_status := FALSE;
       END IF;

       IF NVL(p_interface.stud_mth_housing_pymt_amt,0) < 0 THEN
            g_tab_index := g_tab_index + 1;
            fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
            fnd_message.set_token('FIELD','STUD_MTH_HOUSING_PYMT_AMT');
            g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
            p_status := FALSE;
       END IF;

       IF NVL(p_interface.stud_mth_other_pymt_amt,0) < 0 THEN
            g_tab_index := g_tab_index + 1;
            fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
            fnd_message.set_token('FIELD','STUD_MTH_OTHER_PYMT_AMT');
            g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
            p_status := FALSE;
       END IF;
     END IF;

     IF p_interface.err_mesg_1_cd IS NOT NULL THEN
         IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_CL_ERROR',p_interface.err_mesg_1_cd,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','ERR_MESG_1_CD');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
         END IF;
     END IF;

     IF p_interface.err_mesg_2_cd IS NOT NULL THEN
         IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_CL_ERROR',p_interface.err_mesg_2_cd,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','ERR_MESG_2_CD');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
         END IF;
     END IF;

     IF p_interface.err_mesg_3_cd IS NOT NULL THEN
         IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_CL_ERROR',p_interface.err_mesg_3_cd,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','ERR_MESG_3_CD');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
         END IF;
     END IF;

     IF p_interface.err_mesg_4_cd IS NOT NULL THEN
         IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_CL_ERROR',p_interface.err_mesg_4_cd,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','ERR_MESG_4_CD');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
         END IF;
     END IF;

     IF p_interface.err_mesg_5_cd IS NOT NULL THEN
         IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_CL_ERROR',p_interface.err_mesg_5_cd,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','ERR_MESG_5_CD');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
         END IF;
     END IF;

     IF p_interface.fed_appl_form_type IS NOT NULL THEN
          IF p_fed_fund_cd = 'ALT' THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_SL_INV_FED_FORM_1');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
          END IF;
     END IF;

     IF p_interface.fed_appl_form_type IS NULL THEN
          IF p_interface.loan_status_code NOT IN ('G','N') AND p_fed_fund_cd <> 'ALT' THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_SL_INV_FED_FORM_2');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
          END IF;
     END IF;

     IF p_interface.lend_blkt_guarnt_flag IS NOT NULL AND p_interface.lend_blkt_guarnt_flag <> 'Y' THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','LEND_BLKT_GUARNT_FLAG');
          g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
          p_status := FALSE;
     END IF;

     IF p_interface.b_reference_flag IS NOT NULL THEN
        IF igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_interface.b_reference_flag ) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','B_REFERENCE_FLAG');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_status := FALSE;
        END IF;
     END IF;

     -- Validate if the source_id_txt is part of the loan number and also present in the
     -- system as OPE_ID_NUM value.
     IF(p_interface.source_id_txt IS NOT NULL)THEN
       -- the source id txt should match with the substrign of the loan number txt
       IF(p_interface.source_id_txt <> substr(p_interface.loan_number_txt,1,8))THEN
         g_tab_index := g_tab_index + 1;
         FND_MESSAGE.SET_NAME('IGF', 'IGF_SL_LNUM_SCHBCH_NMTCH');
         FND_MESSAGE.SET_TOKEN('LNUM', p_interface.loan_number_txt);
         FND_MESSAGE.SET_TOKEN('FIELD','SOURCE_ID_TXT');
         g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
         p_status := FALSE;
       END IF;
       OPEN c_source_or_branch_id(p_interface.source_id_txt, 'OPE_ID_NUM');
       FETCH c_source_or_branch_id INTO l_source_or_branch_id;
       IF (c_source_or_branch_id%NOTFOUND) THEN
         CLOSE c_source_or_branch_id;
         g_tab_index := g_tab_index + 1;
         FND_MESSAGE.SET_NAME('IGF', 'IGF_AP_INV_FLD_VAL');
         FND_MESSAGE.SET_TOKEN('FIELD', 'SOURCE_ID_TXT');
         g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
         p_status := FALSE;
       ELSE
         CLOSE c_source_or_branch_id;
       END IF;
     END IF;

     -- Validate if the school_non_ed_brc_id_txt is a valid Source Non Ed Brc Id that is setup
     -- as alternate_identifier in the system. Bug 3102439.
     -- FA134 SCH_NON_ED_BRC_ID_TXT is a realease 5 field only
     IF g_rel_version = 'RELEASE-5' THEN
       IF(p_interface.sch_non_ed_brc_id_txt IS NOT NULL)THEN
         -- the school non ed branch id should be the same as the substr of loan number txt
         IF(p_interface.sch_non_ed_brc_id_txt <> substr(p_interface.loan_number_txt,7,4))THEN
           g_tab_index := g_tab_index + 1;
           FND_MESSAGE.SET_NAME('IGF', 'IGF_SL_LNUM_SCHBCH_NMTCH');
           FND_MESSAGE.SET_TOKEN('LNUM', p_interface.loan_number_txt);
           FND_MESSAGE.SET_TOKEN('FIELD','SCH_NON_ED_BRC_ID_TXT');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           p_status := FALSE;
         END IF;
         OPEN c_source_or_branch_id(p_interface.sch_non_ed_brc_id_txt, 'SCH_NON_ED_BRC_ID');
         FETCH c_source_or_branch_id INTO l_source_or_branch_id;
         IF (c_source_or_branch_id%NOTFOUND) THEN
           CLOSE c_source_or_branch_id;
           g_tab_index := g_tab_index + 1;
           FND_MESSAGE.SET_NAME('IGF', 'IGF_AP_INV_FLD_VAL');
           FND_MESSAGE.SET_TOKEN('FIELD', 'SCH_NON_ED_BRC_ID_TXT');
           g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
           p_status := FALSE;
         ELSE
           CLOSE c_source_or_branch_id;
         END IF;
       END IF;
     END IF;

      IF p_fed_fund_cd = 'ALT' THEN                                     -- FA 157 - Cosigner Data validations for ALT loans
        validate_alt_loan_cosigner (1,
                                    p_interface.cs1_ssn_txt                 ,
                                    p_interface.cs1_citizenship_status      ,
                                    p_interface.cs1_state_txt               ,
                                    p_interface.cs1_drv_license_state_txt   ,
                                    p_interface.cs1_signature_code_txt      ,
                                    p_interface.cs1_credit_auth_code_txt    ,
                                    p_interface.cs1_elect_sig_ind_code_txt  ,
                                    p_interface.cs1_rel_to_student_flag);
        validate_alt_loan_cosigner (2,
                                    p_interface.cs2_ssn_txt                 ,
                                    p_interface.cs2_citizenship_status      ,
                                    p_interface.cs2_state_txt               ,
                                    p_interface.cs2_drv_license_state_txt   ,
                                    p_interface.cs2_signature_code_txt      ,
                                    p_interface.cs2_credit_auth_code_txt    ,
                                    p_interface.cs2_elect_sig_ind_code_txt  ,
                                    p_interface.cs2_rel_to_student_flag);
      END IF;                                                           -- END FA 157 - Cosigner Data validations for ALT loans


     IF NVL(p_status,TRUE) <> FALSE THEN
       p_status := TRUE;
     END IF;

EXCEPTION
WHEN OTHERS THEN

   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_SL_CL_LI_IMP_PKG.VALIDATE_LOAN_ORIG_INT');
   fnd_file.put_line(fnd_file.log,fnd_message.get);

   IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_imp_pkg.validate_loan_orig_int.exception','VALIDATE_LOAN_ORIG_INT ' || SQLERRM);
   END IF;

   RAISE IMPORT_ERROR;


END validate_loan_orig_int;

PROCEDURE validate_loan_disb( p_disb_interface    IN c_disb_interface%ROWTYPE,
                              p_award_id          IN NUMBER,
                              p_d_status          OUT NOCOPY BOOLEAN)
AS
--
--      Created By : gmuralid
--      Created On : 24-JUN-2003
--      Purpose : This procedure is used to validate the loan origination disbursement interface record
--      Known limitations, enhancements or remarks :
--      Change History :
--      Who             When            What
--      (reverse chronological order - newest change first)
--      veramach       16-SEP-2003      1.Validation for disbursement_hld_release_flag changed to look into 'F','N'
--                                      2. Validation for record type changed to look  into IGF_SL_CL_REC_TYPE_CD

CURSOR c_gross_amt(cp_award_id NUMBER,
                   cp_disb_num NUMBER)
IS
SELECT disb_accepted_amt disb_gross_amt
FROM   igf_aw_awd_disb_all
WHERE  award_id = cp_award_id
AND    disb_num = cp_disb_num;

l_gross_amt           c_gross_amt%ROWTYPE;
lv_disb_net_amt       NUMBER;

l_result VARCHAR2(1);

BEGIN

     g_tab_index := 0;

     IF p_disb_interface.record_type IS NULL THEN
             fnd_message.set_name('IGF','IGF_SL_DISB_REC_TYP_REQD');
             fnd_message.set_token('DISB_NUM',p_disb_interface.disbursement_num);
             g_tab_index := g_tab_index + 1;
             g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
             p_d_status := FALSE;
     ELSE
        IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_CL_REC_TYPE_CD',p_disb_interface.record_type,g_sys_award_year) IS NULL THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','RECORD_TYPE');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_d_status := FALSE;
        END IF;

     END IF;

     IF (p_disb_interface.disbursement_num < 0) OR (p_disb_interface.disbursement_num > 99) THEN
             fnd_message.set_name('IGF','IGF_SL_CL_INV_DISB_NUM');
             fnd_message.set_token('DISB_NUM',p_disb_interface.disbursement_num);
             g_tab_index := g_tab_index + 1;
             g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
             p_d_status := FALSE;
     END IF;

     IF p_disb_interface.gross_disbursement_amt IS NOT NULL THEN
       OPEN c_gross_amt(p_award_id,p_disb_interface.disbursement_num);
       FETCH c_gross_amt INTO l_gross_amt;
       CLOSE c_gross_amt;

       IF (l_gross_amt.disb_gross_amt IS NULL) OR (l_gross_amt.disb_gross_amt <> p_disb_interface.gross_disbursement_amt) THEN
             fnd_message.set_name('IGF','IGF_SL_CL_INV_DISB_AMT');
             g_tab_index := g_tab_index + 1;
             g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
             p_d_status := FALSE;
        END IF;
     END IF;

     IF p_disb_interface.origination_fee_amt  IS NOT NULL THEN
       IF (p_disb_interface.origination_fee_amt < 0) THEN
             fnd_message.set_name('IGF','IGF_SL_CL_INV_ORG_FEE_AMT');
             g_tab_index := g_tab_index + 1;
             g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
             p_d_status := FALSE;
       END IF;
     END IF;

     IF p_disb_interface.guarantee_fee_amt  IS NOT NULL THEN
       IF (p_disb_interface.guarantee_fee_amt < 0) THEN
             fnd_message.set_name('IGF','IGF_SL_CL_INV_GUA_FEE_AMT');
             g_tab_index := g_tab_index + 1;
             g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
             p_d_status := FALSE;
       END IF;
     END IF;

     IF NVL(p_disb_interface.outstd_cancel_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','OUTSTD_CANCEL_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_d_status := FALSE;
     END IF;

     IF NVL(p_disb_interface.netted_cancel_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','NETTED_CANCEL_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_d_status := FALSE;
     END IF;

     IF NVL(p_disb_interface.net_cancel_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','NET_CANCEL_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_d_status := FALSE;
     END IF;

    -- FA 134 Enhancements : guarantee_fees_paid_amt is release 5 field only
    -- FA 163 guarantee_fees_paid_amt is valid for realease 4 also
     IF g_rel_version IN ('RELEASE-5','RELEASE-4') AND NVL(p_disb_interface.guarantee_fees_paid_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','GUARANTEE_FEES_PAID_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_d_status := FALSE;
     END IF;

     IF NVL(p_disb_interface.guarantee_amt,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','GUARANTEE_AMT');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_d_status := FALSE;
     END IF;

     IF NVL(p_disb_interface.sch_disbursement_num,0) < 0 THEN
          g_tab_index := g_tab_index + 1;
          fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
          fnd_message.set_token('FIELD','SCH_DISBURSEMENT_NUM');
          g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11)|| fnd_message.get;
          p_d_status := FALSE;
     END IF;

     -- FA 163 : direct_to_borr_flag should be either Y or N
     IF p_disb_interface.direct_to_borr_flag IS NOT NULL THEN
         IF igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_disb_interface.direct_to_borr_flag) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','DIRECT_TO_BORR_FLAG');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_d_status := FALSE;
         END IF;
      END IF;

--
-- Check the net amount, should not be negative
--

      lv_disb_net_amt :=  NVL(p_disb_interface.gross_disbursement_amt,0) - NVL(p_disb_interface.guarantee_fee_amt,0) - NVL(p_disb_interface.origination_fee_amt,0)
                        + NVL(p_disb_interface.guarantee_fees_paid_amt,0) + NVL(p_disb_interface.origination_fees_paid_amt,0);

      IF lv_disb_net_amt < 0 THEN
              fnd_message.set_name('IGF','IGF_DB_INVALID_NET_AMT');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_d_status := FALSE;
      END IF;

      IF p_disb_interface.fund_dist_mthd_type IS NOT NULL THEN
        IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_CL_DB_FUND_DISB_METH',p_disb_interface.fund_dist_mthd_type,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','FUND_DIST_MTHD_TYPE');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_d_status := FALSE;
        END IF;
      END IF;

      IF p_disb_interface.late_disbursement_flag IS NOT NULL THEN
         IF igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_disb_interface.late_disbursement_flag) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','LATE_DISBURSEMENT_FLAG');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_d_status := FALSE;
         END IF;
      END IF;

      IF p_disb_interface.prev_reported_flag IS NOT NULL THEN
         IF igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_disb_interface.prev_reported_flag) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','PREV_REPORTED_FLAG');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_d_status := FALSE;
         END IF;
      END IF;

      IF p_disb_interface.disbursement_hld_release_flag IS NOT NULL THEN
         IF p_disb_interface.disbursement_hld_release_flag IN ('H','R') OR
                  (igf_ap_gen.get_aw_lookup_meaning('IGF_SL_CL_DB_HOLD_REL_IND',p_disb_interface.disbursement_hld_release_flag,g_sys_award_year)) IS NULL
         THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','DISBURSEMENT_HLD_RELEASE_FLAG');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_d_status := FALSE;
         END IF;
      END IF;

      IF p_disb_interface.pnote_code IS NULL THEN
             fnd_message.set_name('IGF','IGF_SL_CL_PNOTE_STAT_REQD');
             g_tab_index := g_tab_index + 1;
             g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
             p_d_status := FALSE;

      ELSIF p_disb_interface.pnote_code IN ('A','C','F','G','I','M','N','P','Q','R','S','X')
             OR (igf_ap_gen.get_aw_lookup_meaning('IGF_SL_PNOTE_STATUS',p_disb_interface.pnote_code,g_sys_award_year) IS NULL)
             THEN

             g_tab_index := g_tab_index + 1;
             fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
             fnd_message.set_token('FIELD','PNOTE_CODE');
             g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
             p_d_status := FALSE;

      END IF;

      -- FA 134: is a Release -5 field only
      IF g_rel_version = 'RELEASE-5' THEN
        IF p_disb_interface.pnote_status_date IS NULL THEN
               fnd_message.set_name('IGF','IGF_SL_CL_P_STAT_DT_REQD');
               g_tab_index := g_tab_index + 1;
               g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
               p_d_status := FALSE;
        END IF;
      END IF;

      IF p_disb_interface.origination_fees_paid_amt IS NOT NULL THEN
         IF (p_disb_interface.origination_fees_paid_amt < 0) THEN
              fnd_message.set_name('IGF','IGF_SL_CL_INV_ORG_FEE_AMT');
              g_tab_index := g_tab_index + 1;
              g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
              p_d_status := FALSE;
         END IF;
      END IF;


      IF p_disb_interface.disbursement_status_code IS NOT NULL THEN
         IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_CL_DISB_STATUS',p_disb_interface.disbursement_status_code,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','DISBURSEMENT_STATUS_CODE');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_d_status := FALSE;
         END IF;
      END IF;

      IF p_disb_interface.fund_status_code IS NOT NULL THEN
         IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_CL_DB_FUND_STATUS',p_disb_interface.fund_status_code,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_SL_CL_INV_FND_STATUS');
              g_igf_sl_msg_table(g_tab_index).msg_text := RPAD(g_error,11) || fnd_message.get;
              p_d_status := FALSE;
         END IF;
      END IF;

     IF p_disb_interface.err_mesg_1_cd IS NOT NULL THEN
         IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_CL_ERROR',p_disb_interface.err_mesg_1_cd,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','ERR_MESG_1_CD');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_d_status := FALSE;
         END IF;
     END IF;

     IF p_disb_interface.err_mesg_2_cd IS NOT NULL THEN
         IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_CL_ERROR',p_disb_interface.err_mesg_2_cd,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','ERR_MESG_2_CD');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_d_status := FALSE;
         END IF;
     END IF;

     IF p_disb_interface.err_mesg_3_cd IS NOT NULL THEN
         IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_CL_ERROR',p_disb_interface.err_mesg_3_cd,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','ERR_MESG_3_CD');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_d_status := FALSE;
         END IF;
     END IF;

     IF p_disb_interface.err_mesg_4_cd IS NOT NULL THEN
         IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_CL_ERROR',p_disb_interface.err_mesg_4_cd,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','ERR_MESG_4_CD');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_d_status := FALSE;
         END IF;
     END IF;

     IF p_disb_interface.err_mesg_5_cd IS NOT NULL THEN
         IF igf_ap_gen.get_aw_lookup_meaning('IGF_SL_CL_ERROR',p_disb_interface.err_mesg_5_cd,g_sys_award_year) IS NULL THEN
              g_tab_index := g_tab_index + 1;
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','ERR_MESG_5_CD');
              g_igf_sl_msg_table(g_tab_index).msg_text :=  RPAD(g_error,11)|| fnd_message.get;
              p_d_status := FALSE;
         END IF;
     END IF;


     IF NVL(p_d_status,TRUE) <> FALSE THEN
        p_d_status := TRUE;
     END IF;

EXCEPTION
     WHEN OTHERS THEN

        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_SL_CL_LI_IMP_PKG.VALIDATE_LOAN_DISB');
        fnd_file.put_line(fnd_file.log,fnd_message.get);

        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_imp_pkg.validate_loan_disb.exception','Unhandled exception : '||SQLERRM);
        END IF;
        RAISE IMPORT_ERROR;

END validate_loan_disb;

PROCEDURE write_logfile(p_log IN VARCHAR2)
AS
--
--    Created By : gmuralid
--    Created On : 24-JUN-2003
--    Purpose : This procedure is used to write the messages into log file
--    Known limitations, enhancements or remarks :
--    Change History :
--    Who             When            What
--    (reverse chronological order - newest change first)
--

indx NUMBER;

BEGIN

     IF g_igf_sl_msg_table.COUNT <> 0 THEN
        FOR indx IN g_igf_sl_msg_table.FIRST..g_igf_sl_msg_table.LAST
        LOOP
               IF p_log = 'D' THEN
                    fnd_file.put_line(fnd_file.log,LPAD(' ',11) || g_igf_sl_msg_table(indx).msg_text);
               ELSE
                    fnd_file.put_line(fnd_file.log,g_igf_sl_msg_table(indx).msg_text);
               END IF;
        END LOOP;
     END IF;

     g_igf_sl_msg_table.DELETE;

EXCEPTION
WHEN OTHERS THEN

   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_SL_CL_LI_IMP_PKG.WRITE_LOGFILE');
   fnd_file.put_line(fnd_file.log,fnd_message.get);

   IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_imp_pkg.write_logfile.exception','unhandled exception : '||SQLERRM);
   END IF;
   RAISE IMPORT_ERROR;

END write_logfile;


PROCEDURE delete_records ( p_rowid       ROWID,
                           p_loan_id     NUMBER,
                           p_loan_number VARCHAR2)
IS


     l_award_id               igf_aw_award_all.award_id%TYPE;

     l_lor_orig_id            NUMBER;
     l_resp_r1_clrp1_id       NUMBER;

     l_lor_rowid              ROWID;
     l_loc_rowid              ROWID;
     l_alt_rowid              ROWID;
     l_disb_rowid             ROWID;
     l_resp_r1_rowid          ROWID;
     l_resp_r4_rowid          ROWID;
     l_resp_r8_rowid          ROWID;
     l_disb_resp_rowid        ROWID;

     CURSOR c_lor(cp_loan_id NUMBER)
     IS
     SELECT
     rowid,
     origination_id
     FROM   igf_sl_lor_all
     WHERE  loan_id = cp_loan_id;

     l_lor c_lor%ROWTYPE;

     CURSOR c_lor_loc(cp_orig_id NUMBER)
     IS
     SELECT rowid
     FROM   igf_sl_lor_loc_all
     WHERE  origination_id = cp_orig_id;

     l_lor_loc c_lor_loc%ROWTYPE;

     CURSOR c_alt_borw(cp_loan_id NUMBER)
     IS
     SELECT rowid
     FROM   igf_sl_alt_borw_all
     WHERE  loan_id = cp_loan_id;

     l_alt_borw c_alt_borw%ROWTYPE;

     CURSOR c_disb_loc(cp_award_id NUMBER)
     IS
     SELECT rowid
     FROM   igf_sl_awd_disb_loc_all
     WHERE  award_id = cp_award_id;

     l_disb_loc c_disb_loc%ROWTYPE;

     CURSOR c_resp_r1(cp_loan_number VARCHAR2)
     IS
     SELECT rowid,clrp1_id
     FROM   igf_sl_cl_resp_r1_all
     WHERE  loan_number = cp_loan_number;

     l_resp_r1 c_resp_r1%ROWTYPE;

     CURSOR c_resp_r4(cp_rp1_id  NUMBER)
     IS
     SELECT rowid
     FROM   igf_sl_cl_resp_r4_all
     WHERE  clrp1_id = cp_rp1_id;

     l_resp_r4 c_resp_r4%ROWTYPE;

     CURSOR c_resp_r8(cp_rp1_id  NUMBER)
     IS
     SELECT rowid
     FROM   igf_sl_cl_resp_r8_all
     WHERE  clrp1_id = cp_rp1_id;

     l_resp_r8  c_resp_r8%ROWTYPE;

     CURSOR c_disb_resp(cp_loan_number VARCHAR2)
     IS
     SELECT rowid
     FROM   igf_db_cl_disb_resp_all
     WHERE  loan_number = cp_loan_number;

     l_disb_resp c_disb_resp%ROWTYPE;


     CURSOR c_pnote_hist(cp_loan_id NUMBER)
     IS
     SELECT
     rowid
     FROM  igf_sl_pnote_stat_h
     WHERE loan_id = cp_loan_id;

     l_pnote_hist  c_pnote_hist%ROWTYPE;


BEGIN

     OPEN c_lor(p_loan_id);
     FETCH c_lor INTO l_lor;
     IF (c_lor%FOUND) THEN
        CLOSE c_lor;
        l_lor_rowid   := l_lor.rowid;
        l_lor_orig_id := l_lor.origination_id;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.delete_record.debug','DELETE_RECORDS: Before c_pnote_hist OPEN');
        END IF;

        FOR l_pnote_hist IN c_pnote_hist(p_loan_id)
        LOOP
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.delete_records.debug','DELETE_RECORDS: c_pnote_hist ROWID ' || l_pnote_hist.rowid);
            END IF;
            igf_sl_pnote_stat_h_pkg.delete_row(l_pnote_hist.rowid);
        END LOOP;

        OPEN c_lor_loc(l_lor_orig_id);
        FETCH c_lor_loc INTO l_lor_loc;
        IF (c_lor_loc%FOUND) THEN
             CLOSE c_lor_loc;
             l_loc_rowid := l_lor_loc.rowid;
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.delete_record.debug','l_lor_rowid.rowid:'||l_lor_rowid);
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.delete_record.debug','l_loc_rowid.rowid:'||l_loc_rowid);
             END IF;
             igf_sl_lor_loc_pkg.delete_row(l_loc_rowid);
             igf_sl_lor_pkg.delete_row(l_lor_rowid);
        ELSE
             CLOSE c_lor_loc;
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.delete_record.debug','l_lor_rowid.rowid:'||l_lor_rowid);
             END IF;
             igf_sl_lor_pkg.delete_row(l_lor_rowid);
        END IF;
     ELSE
        CLOSE c_lor;
        l_lor_rowid   := NULL;
        l_lor_orig_id := NULL;
     END IF;

     OPEN c_alt_borw(p_loan_id);
     FETCH c_alt_borw INTO l_alt_borw;
     IF (c_alt_borw%FOUND) THEN
        CLOSE c_alt_borw;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_li_imp_pkg.delete_records.debug','l_alt_borw ROWID '|| l_alt_borw.rowid);
        END IF;
        igf_sl_alt_borw_pkg.delete_row(x_ROWID => l_alt_borw.rowid);
     ELSE
        CLOSE c_alt_borw;
     END IF;

     FOR l_disb_loc IN c_disb_loc(l_award_id) LOOP
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_li_imp_pkg.delete_records.debug','l_disb_loc ROWID ' || l_disb_loc.rowid);
        END IF;
         igf_sl_awd_disb_loc_pkg.delete_row(x_ROWID  => l_disb_loc.rowid);
     END LOOP;

     IF (p_loan_number IS NOT NULL) THEN
       OPEN c_resp_r1(p_loan_number);
       FETCH c_resp_r1 INTO l_resp_r1;
       IF (c_resp_r1%FOUND) THEN
          CLOSE c_resp_r1;
          l_resp_r1_rowid     := l_resp_r1.rowid;
          l_resp_r1_clrp1_id  := l_resp_r1.clrp1_id;

          OPEN c_resp_r4(l_resp_r1_clrp1_id);
          FETCH c_resp_r4 INTO l_resp_r4;
          IF (c_resp_r4%FOUND) THEN
             CLOSE c_resp_r4;
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.delete_record.debug','l_resp_r4 ROWID ' || l_resp_r4.rowid);
             END IF;
             igf_sl_cl_resp_r4_pkg.delete_row(l_resp_r4.rowid);
          ELSE
             CLOSE c_resp_r4;
          END IF;

          FOR l_resp_r8 IN c_resp_r8(l_resp_r1_clrp1_id) LOOP
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.delete_record.debug','l_resp_r8 ROWID ' || l_resp_r8.rowid);
             END IF;
             igf_sl_cl_resp_r8_pkg.delete_row(x_ROWID => l_resp_r8.rowid);
          END LOOP;
           IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.delete_record.debug','l_resp_r1 ROWID ' || l_resp_r1.rowid);
           END IF;
           igf_sl_cl_resp_r1_pkg.delete_row(x_ROWID => l_resp_r1_rowid);

       ELSE
           CLOSE c_resp_r1;
       END IF;

       FOR l_disb_resp IN c_disb_resp(p_loan_number) LOOP
           IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.delete_record.debug','l_disb_resp ROWID ' || l_disb_resp.rowid);
           END IF;
           igf_db_cl_disb_resp_pkg.delete_row(x_ROWID => l_disb_resp.rowid);
       END LOOP;

     END IF;

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.delete_record.debug','igf_sl_loans ROWID ' || p_rowid);
     END IF;
     igf_sl_loans_pkg.delete_row(p_rowid);

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.delete_record.debug','Deletion Complete');
     END IF;


EXCEPTION
WHEN OTHERS THEN

   IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_imp_pkg.delete_records.exception','Exception ' || SQLERRM);
   END IF;
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_SL_CL_LI_IMP_PKG.DELETE_RECORDS');

   RAISE IMPORT_ERROR;


END delete_records;

PROCEDURE insert_records(p_interface              IN c_interface%ROWTYPE,
                         p_award_id               IN NUMBER,
                         p_fed_fund               IN VARCHAR2,
                         p_student_person_id      IN NUMBER)
AS
--
--    Created By : gmuralid
--    Created On : 24-JUN-2003
--    Purpose : This procedure is used to perform the dml operation on every table
--    Known limitations, enhancements or remarks :
--    Change History :
--    Who             When            What
--    (reverse chronological order - newest change first)
--    bkkumar     07-oct-2003    Bug 3104228  FA 122 Loans Enhancements
--                               a) Impact of obsoleting GUARANTOR_ID_TXT,
--                               LENDER_ID_TXT,LEND_NON_ED_BRC_ID_TXT,RECIPIENT_ID_TXT,
--                               RECIPIENT_TYPE,RECIPIENT_NON_ED_BRC_ID_TXT from the
--                               interface table and also adding a new column relationship_cd
--                               b) Impact of adding the relationship_cd
--                               in igf_sl_lor_all table and obsoleting
--                               BORW_LENDER_ID, DUNS_BORW_LENDER_ID,
--                               GUARANTOR_ID, DUNS_GUARNT_ID,
--                               LENDER_ID, DUNS_LENDER_ID
--                               LEND_NON_ED_BRC_ID, RECIPIENT_ID
--                               RECIPIENT_TYPE,DUNS_RECIP_ID
--                               RECIP_NON_ED_BRC_ID columns.
--                               c) The DUNS_BORW_LENDER_ID
--                               DUNS_GUARNT_ID
--                               DUNS_LENDER_ID
--                               DUNS_RECIP_ID columns are osboleted from the
--                               igf_sl_lor_loc_all table.
--    veramach   23-SEP-2003     Bug 3104228:
--                                        1. Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
--                                        cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
--                                        p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
--                                        chg_batch_id,appl_send_error_codes from igf_sl_lor
--                                        2. Obsoleted lend_apprv_denied_code,lend_apprv_denied_date,cl_rec_status_last_update,
--                                        cl_rec_status,mpn_confirm_code,appl_loan_phase_code_chg,appl_loan_phase_code,
--                                        p_ssn_chg_date,p_dob_chg_date,s_ssn_chg_date,s_dob_chg_date,s_local_addr_chg_date,
--                                        chg_batch_id from igf_sl_lor_loc
--    veramach        16-SEP-2003    FA 122 loan enhancements
--                                   Changed c_loan_dtls cursor.it does not select borrower information.igf_sl_gen.get_person_details is used for this


     ln_rowid                 ROWID;
     lor_rowid                ROWID;
     loc_rowid                ROWID;
     alt_rowid                ROWID;


     l_b_permt_zip            NUMBER(30);
     l_b_permt_zip_suffix     NUMBER(30);

     l_b_dob                  DATE;
     l_b_legal_res_date       DATE;
     l_b_signature_date       DATE;

     l_p_default_status       VARCHAR2(30);
     l_b_first_name           VARCHAR2(150);
     l_b_last_name            VARCHAR2(150);
     l_b_middle_name          VARCHAR2(150);
     l_b_ssn                  VARCHAR2(9);
     l_b_permt_addr1          VARCHAR2(240);
     l_b_permt_addr2          VARCHAR2(240);
     l_b_permt_city           VARCHAR2(60);
     l_b_permt_state          VARCHAR2(60);
     l_b_permt_phone          VARCHAR2(60);
     l_b_signature_code       VARCHAR2(30);
     l_b_citizenship_status   VARCHAR2(30);
     l_b_state_of_legal_res   VARCHAR2(30);
     l_b_default_status       VARCHAR2(30);
     l_b_license_state        VARCHAR2(30);
     l_b_license_number       VARCHAR2(30);

     ln_loan_id         igf_sl_loans.loan_id%TYPE;
     ln_albw_id         igf_sl_alt_borw_all.albw_id%TYPE;
     ln_origination_id  igf_sl_lor_all.origination_id%TYPE;

     -- FA 122 Loans Enhancements
     CURSOR c_get_base_id ( cp_award_id  igf_aw_award.award_id%TYPE)
     IS
     SELECT base_id,
            ci_cal_type,
            ci_sequence_number
     FROM   igf_aw_award_v
     WHERE  award_id = cp_award_id;

     l_get_base_id  c_get_base_id%ROWTYPE;
 -- cursor to get the est_orig_fee_perct for the given set up  FA 122 Loans Enhancemtns
    CURSOR c_setup (
                      cp_cal_type          igs_ca_inst_all.cal_type%TYPE,
                      cp_sequence_number   igs_ca_inst_all.sequence_number%TYPE,
                      cp_rel_code          igf_sl_cl_setup.relationship_cd%TYPE

                   )
    IS
    SELECT est_orig_fee_perct
    FROM   igf_sl_cl_setup
    WHERE  ci_cal_type = cp_cal_type
    AND    ci_sequence_number = cp_sequence_number
    AND    cp_rel_code = NVL(relationship_cd,'*');

    l_setup c_setup%ROWTYPE;

     CURSOR c_loan_dtls(p_loan_id          NUMBER,
                        cp_origination_id   NUMBER) IS
     SELECT loans.row_id,
            loans.loan_id,
            lor.s_default_status,
            lor.p_default_status,
            lor.p_person_id,
            lor.recipient_id,
            lor.lender_id,
            lor.guarantor_id,
            lor.lend_non_ed_brc_id,
            lor.recip_non_ed_brc_id,
            lor.recipient_type,
            fabase.person_id student_id
     FROM   igf_sl_loans       loans,
            igf_sl_lor_v       lor,
            igf_aw_award       awd,
            igf_ap_fa_base_rec fabase
     WHERE  fabase.base_id     = awd.base_id
     AND    loans.award_id     = awd.award_id
     AND    loans.loan_id      = lor.loan_id
     AND    loans.loan_id      = p_loan_id;


     loan_rec   c_loan_dtls%ROWTYPE;

     student_dtl_rec igf_sl_gen.person_dtl_rec;
     student_dtl_cur igf_sl_gen.person_dtl_cur;

     parent_dtl_rec igf_sl_gen.person_dtl_rec;
     parent_dtl_cur igf_sl_gen.person_dtl_cur;

     CURSOR cur_isir_depend_status (cp_person_id NUMBER)
     IS
     SELECT isir.dependency_status
       FROM igf_ap_fa_base_rec fabase,
            igf_ap_isir_matched isir
      WHERE isir.payment_isir = 'Y'
        AND isir.system_record_type = 'ORIGINAL'
        AND isir.base_id     =   fabase.base_id
        AND fabase.person_id =   cp_person_id;

     l_student_license   cur_isir_depend_status%ROWTYPE;

     CURSOR c_disb_det (cp_disb_num NUMBER)
     IS
     SELECT
     ROWID,
     adisb.*
     FROM
     igf_aw_awd_disb_all adisb
     WHERE
     adisb.award_id   =  p_award_id AND
     adisb.disb_num   =  cp_disb_num;

     l_disb_det c_disb_det%ROWTYPE;

     CURSOR chk_batch_id(cp_orig_ack_batch_id_txt VARCHAR2)
     IS
     SELECT cbth_id
     FROM   igf_sl_cl_batch_all
     WHERE  batch_id = cp_orig_ack_batch_id_txt;

     l_batch_id chk_batch_id%ROWTYPE;

     lv_cl_loan_type              VARCHAR2(2);
     lv_s_citizenship_status      VARCHAR2(30);


     lv_p_permt_phone             igf_sl_lor_loc_all.s_permt_phone%TYPE;
     lv_p_citizenship_status      igf_ap_isir_matched_all.citizenship_status%TYPE;
     lv_p_foreign_postal_code     igf_sl_lor_loc_all.s_foreign_postal_code%TYPE;
     lv_s_permt_phone             igf_sl_lor_loc_all.s_permt_phone%TYPE;
     lv_s_license_number          igf_ap_isir_matched.driver_license_number%TYPE;
     lv_s_license_state           igf_ap_isir_matched.driver_license_state%TYPE;
     lv_alien_reg_num             igf_ap_isir_matched.alien_reg_number%TYPE;
     lv_dependency_status         igf_ap_isir_matched.dependency_status%TYPE;
     lv_s_legal_res_date          igf_ap_isir_matched.s_legal_resd_date%TYPE;
     lv_s_legal_res_state         igf_ap_isir_matched.s_state_legal_residence%TYPE;
     ln_cbth_id                   igf_sl_cl_batch_all.cbth_id%TYPE;
     l_clrp1_id                   igf_sl_cl_resp_r1_all.clrp1_id%TYPE;

     l_disb_interface             c_disb_interface%ROWTYPE;


     awdloc_rowid                 ROWID;
     clb_rowid                    ROWID;
     l_rl_row_id                  ROWID;
     l_r4_row_id                  ROWID;
     l_r8_row_id                  ROWID;
     l_rost_rowid                 ROWID;

     i                            NUMBER;
     l_cdbr_id                    NUMBER;
     lv_disb_net_amt              NUMBER;

BEGIN

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_record.debug','Before insert into loans IGF_SL_LOANS_ALL');
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg..debug','Values :' ||
                                                   ' Award ID '                      ||
                                                   p_award_id                        ||
                                                   ' Loan Seq Number '               ||
                                                   p_interface.loan_seq_num          ||
                                                   ' Loan Number '                   ||
                                                   p_interface.loan_number_txt);
     END IF;

    -- FA 122 Loans Enhancements
     OPEN c_get_base_id(p_award_id);
     FETCH c_get_base_id INTO l_get_base_id;
     CLOSE c_get_base_id;

     OPEN  c_setup(l_get_base_id.ci_cal_type,l_get_base_id.ci_sequence_number,p_interface.relationship_cd);
     FETCH c_setup INTO l_setup;
     CLOSE c_setup;

     ln_loan_id := NULL;
     ln_rowid   := NULL;

     igf_sl_loans_pkg.insert_row (
           x_mode                 => 'R',
           x_rowid                => ln_rowid,
           x_loan_id              => ln_loan_id,
           x_award_id             => p_award_id,
           x_seq_num              => p_interface.loan_seq_num,
           x_loan_number          => p_interface.loan_number_txt,
           x_loan_per_begin_date  => p_interface.loan_per_begin_date,
           x_loan_per_end_date    => p_interface.loan_per_end_date,
           x_loan_status          => p_interface.loan_status_code,
           x_loan_status_date     => p_interface.loan_status_date,
           x_loan_chg_status      => NULL,
           x_loan_chg_status_date => NULL,
           x_active               => p_interface.active_flag,
           x_active_date          => p_interface.active_date,
           x_borw_detrm_code      => NULL,
           x_legacy_record_flag   => 'Y',
           x_external_loan_id_txt => p_interface.external_loan_id_txt

         );

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','After Insert into IGF_SL_LOANS LOAN_ID ' || ln_loan_id);
     END IF;


     IF p_fed_fund = 'FLU' THEN
            lv_cl_loan_type := 'SU';
     ELSIF p_fed_fund = 'FLS' THEN
            lv_cl_loan_type := 'SF';
     ELSIF p_fed_fund = 'FLP' THEN
          lv_cl_loan_type := 'PL';
     ELSIF p_fed_fund = 'ALT' THEN
            lv_cl_loan_type := 'AL';
     ELSIF p_fed_fund = 'GPLUSFL' THEN
            lv_cl_loan_type := 'GB';
     END IF;

     IF (NVL(p_interface.b_stu_indicator_flag,'X') = 'Y') AND (p_fed_fund = 'ALT') THEN
        l_p_default_status := p_interface.s_default_status_flag;
        g_p_person_id      := p_student_person_id;
     ELSE
        l_p_default_status := p_interface.b_default_status_flag;
     END IF;

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','Before insert into IGF_SL_LOR');
     END IF;

     lor_rowid         := NULL;
     ln_origination_id := NULL;

     igf_sl_lor_pkg.insert_row (
                x_mode                              => 'R',
                x_rowid                             => lor_rowid,
                x_origination_id                    => ln_origination_id,
                x_loan_id                           => ln_loan_id,
                x_sch_cert_date                     => p_interface.sch_cert_date,
                x_orig_status_flag                  => NULL,--This is applicable for Direct Loans
                x_orig_batch_id                     => p_interface.orig_batch_id_txt,
                x_orig_batch_date                   => p_interface.orig_batch_date,
                x_chg_batch_id                      => NULL,--This is applicable for Direct Loans
                x_orig_ack_date                     => p_interface.orig_ack_date,
                x_credit_override                   => NULL,    -- FA 149 Credit status override changed to crdt_decision_status
                x_credit_decision_date              => p_interface.credit_status_date,
                x_req_serial_loan_code              => p_interface.req_serial_loan_code,
                x_act_serial_loan_code              => p_interface.act_serial_loan_code,
                x_pnote_delivery_code               => p_interface.pnote_delivery_code,
                x_pnote_status                      => p_interface.pnote_status_code,
                x_pnote_status_date                 => p_interface.pnote_status_date,
                x_pnote_id                          => NULL,--This is applicable for Direct Loans
                x_pnote_print_ind                   => NULL,--This is applicable for Direct Loans
                x_pnote_accept_amt                  => NULL,--This is applicable for Direct Loans
                x_pnote_accept_date                 => NULL,--This is applicable for Direct Loans
                x_unsub_elig_for_heal               => NULL,--This is applicable for Direct Loans
                x_disclosure_print_ind              => NULL,--This is applicable for Direct Loans
                x_orig_fee_perct                    => l_setup.est_orig_fee_perct,
                x_borw_confirm_ind                  => p_interface.borw_confirm_flag,
                x_borw_interest_ind                 => p_interface.borw_interest_flag,
                x_borw_outstd_loan_code             => p_interface.borw_outstd_loan_flag,
                x_unsub_elig_for_depnt              => NULL,--This is applicable for Direct Loans
                x_guarantee_amt                     => p_interface.guarantee_amt,
                x_guarantee_date                    => p_interface.guarantee_date,
                x_guarnt_amt_redn_code              => p_interface.guarnt_amt_redn_code,
                x_guarnt_status_code                => p_interface.guarnt_status_code,
                x_guarnt_status_date                => p_interface.guarnt_status_date,
                x_lend_apprv_denied_code            => p_interface.lend_apprv_denied_code,
                x_lend_apprv_denied_date            => p_interface.lend_apprv_denied_date,
                x_lend_status_code                  => p_interface.lend_status_code,
                x_lend_status_date                  => p_interface.lend_status_date,
                x_guarnt_adj_ind                    => p_interface.guarnt_adj_flag,
                x_grade_level_code                  => p_interface.grade_level_code,
                x_enrollment_code                   => p_interface.enrollment_code,
                x_anticip_compl_date                => p_interface.anticip_compl_date,
                x_borw_lender_id                    => NULL,
                x_duns_borw_lender_id               => NULL,
                x_guarantor_id                      => NULL,
                x_duns_guarnt_id                    => NULL,
                x_prc_type_code                     => p_interface.prc_type_code,
                x_cl_seq_number                     => p_interface.cl_seq_num,
                x_last_resort_lender                => p_interface.last_resort_lender_flag,
                x_lender_id                         => NULL,
                x_duns_lender_id                    => NULL,
                x_lend_non_ed_brc_id                => NULL,
                x_recipient_id                      => NULL,
                x_recipient_type                    => NULL,
                x_duns_recip_id                     => NULL,
                x_recip_non_ed_brc_id               => NULL,
                x_rec_type_ind                      => p_interface.record_code,
                x_cl_loan_type                      => lv_cl_loan_type,
                x_cl_rec_status                     => p_interface.cl_rec_status,
                x_cl_rec_status_last_update         => p_interface.cl_rec_status_last_update,
                x_alt_prog_type_code                => p_interface.alt_prog_type_cd,
                x_alt_appl_ver_code                 => p_interface.alt_appl_ver_code_num,
                x_mpn_confirm_code                  => p_interface.mpn_confirm_code,-- May be Obsolete field
                x_resp_to_orig_code                 => p_interface.resp_to_orig_flag,
                x_appl_loan_phase_code              => p_interface.appl_loan_phase_code,
                x_appl_loan_phase_code_chg          => p_interface.appl_loan_phase_code_chg,
                x_appl_send_error_codes             => NULL,-- May be Obsolete field
                x_tot_outstd_stafford               => p_interface.tot_outstd_stafford_amt,
                x_tot_outstd_plus                   => p_interface.tot_outstd_plus_amt,
                x_alt_borw_tot_debt                 => p_interface.alt_borw_tot_stu_loan_debt_amt,
                x_act_interest_rate                 => p_interface.act_interest_rate_num,
                x_service_type_code                 => p_interface.service_type_code,
                x_rev_notice_of_guarnt              => p_interface.rev_notice_of_guarnt_code,
                x_sch_refund_amt                    => p_interface.sch_refund_amt,
                x_sch_refund_date                   => p_interface.sch_refund_date,
                x_uniq_layout_vend_code             => p_interface.uniq_layout_vend_code,
                x_uniq_layout_ident_code            => p_interface.uniq_layout_ident_code,
                x_p_person_id                       => g_p_person_id,
                x_p_ssn_chg_date                    => NULL,--Change Field for Direct Loan
                x_p_dob_chg_date                    => NULL,--Change Field for Direct Loan
                x_p_permt_addr_chg_date             => NULL,--Change Field for Direct Loan
                x_p_default_status                  => l_p_default_status,
                x_p_signature_code                  => p_interface.b_signature_flag,
                x_p_signature_date                  => p_interface.b_signature_date,
                x_s_ssn_chg_date                    => NULL,--Change Field for Direct Loan
                x_s_dob_chg_date                    => NULL,--Change Field for Direct Loan
                x_s_permt_addr_chg_date             => NULL,--Change Field for Direct Loan
                x_s_local_addr_chg_date             => NULL,--Change Field for Direct Loan
                x_s_default_status                  => p_interface.s_default_status_flag,
                x_s_signature_code                  => p_interface.s_signature_flag,
                x_pnote_batch_id                    => NULL,--This is applicable for Direct Loans
                x_pnote_ack_date                    => NULL,--This is applicable for Direct Loans
                x_pnote_mpn_ind                     => NULL,--This is applicable for Direct Loans
                x_elec_mpn_ind                      => NULL,--This is applicable for Direct Loans
                x_borr_sign_ind                     => p_interface.borr_sign_flag ,
                x_stud_sign_ind                     => p_interface.stud_sign_flag,
                x_borr_credit_auth_code             => p_interface.borr_credit_auth_flag,
                x_relationship_cd                   => p_interface.relationship_cd,
                x_interest_rebate_percent_num       => NULL,
                x_cps_trans_num                     => NULL,
                x_atd_entity_id_txt                 => NULL,
                x_rep_entity_id_txt                 => NULL,
                x_crdt_decision_status              => p_interface.credit_status_code,
                x_note_message                      => NULL,
                x_book_loan_amt                     => NULL,
                x_book_loan_amt_date                => NULL,
                x_pymt_servicer_amt                 => NULL,
                x_pymt_servicer_date                => NULL,
                x_external_loan_id_txt              => p_interface.external_loan_id_txt,
                x_alt_approved_amt                  => p_interface.alt_approved_amt,
                x_flp_approved_amt                  => p_interface.flp_approved_amt,
                x_fls_approved_amt                  => p_interface.fls_approved_amt,
                x_flu_approved_amt                  => p_interface.flu_approved_amt,
                x_guarantor_use_txt                 => p_interface.guarantor_use_txt,
                x_lender_use_txt                    => p_interface.lender_use_txt,
                x_loan_app_form_code                => p_interface.fed_appl_form_type,
                x_reinstatement_amt                 => p_interface.reinst_avail_amt,
                x_requested_loan_amt                => p_interface.req_loan_amt,
                x_school_use_txt                    => p_interface.school_use_txt,
                x_deferment_request_code            => p_interface.defer_req_flag,
                x_eft_authorization_code            => p_interface.eft_auth_flag,
                x_actual_record_type_code           => p_interface.actual_record_type_code,
                x_override_grade_level_code         => NULL,
		x_acad_begin_date                   => NULL,
            	x_acad_end_date                     => NULL,
                x_b_alien_reg_num_txt               => NULL,
                x_esign_src_typ_cd                  => p_interface.esign_src_typ_cd
                );
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','After insert into IGF_SL_LOR ln_origination_id ' || ln_origination_id);
     END IF;

     IF p_fed_fund = 'ALT' THEN

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','Before insert into IGF_SL_ALT_BORW_ALL');
          END IF;

          ln_albw_id := NULL;
          alt_rowid  := NULL;

          igf_sl_alt_borw_pkg.insert_row (
                    x_mode                              => 'R',
                    x_rowid                             => alt_rowid,
                    x_stud_mth_auto_pymt                => p_interface.stud_mth_auto_pymt_amt,
                    x_stud_mth_ed_loan_pymt             => p_interface.stud_mth_ed_loan_pymt_amt ,
                    x_stud_mth_other_pymt               => p_interface.stud_mth_other_pymt_amt ,
                    x_stud_mth_crdtcard_pymt            => p_interface.stud_mth_crdtcard_pymt_amt   ,
                    x_repayment_opt_code                => p_interface.repayment_opt_code,
                    x_stud_mth_housing_pymt             => p_interface.stud_mth_housing_pymt_amt ,
                    x_albw_id                           => ln_albw_id,
                    x_loan_id                           => ln_loan_id,
                    x_fed_stafford_loan_debt            => p_interface.fed_stafford_loan_debt_amt ,
                    x_fed_sls_debt                      => p_interface.fed_sls_debt_amt,
                    x_heal_debt                         => p_interface.heal_debt_amt,
                    x_perkins_debt                      => p_interface.perkins_debt_amt,
                    x_other_debt                        => p_interface.other_debt_amt,
                    x_crdt_undr_difft_name              => p_interface.crdt_undr_difft_name_flag,
                    x_borw_gross_annual_sal             => p_interface.borw_gross_annual_sal_amt,
                    x_borw_other_income                 => p_interface.borw_other_income_amt,
                    x_student_major                     => p_interface.student_major_txt,
                    x_int_rate_opt                      => p_interface.int_rate_opt_code,
                    x_other_loan_amt                    => p_interface.other_loan_amt,
                    x_cs1_lname                         => p_interface.cs1_lname,
                    x_cs1_fname                         => p_interface.cs1_fname,
                    x_cs1_mi_txt                        => p_interface.cs1_mi_txt,
                    x_cs1_ssn_txt                       => p_interface.cs1_ssn_txt,
                    x_cs1_citizenship_status            => p_interface.cs1_citizenship_status,
                    x_cs1_address_line_1_txt            => p_interface.cs1_address_line_1_txt,
                    x_cs1_address_line_2_txt            => p_interface.cs1_address_line_2_txt,
                    x_cs1_city_txt                      => p_interface.cs1_city_txt,
                    x_cs1_state_txt                     => p_interface.cs1_state_txt,
                    x_cs1_zip_txt                       => p_interface.cs1_zip_txt,
                    x_cs1_zip_suffix_txt                => p_interface.cs1_zip_suffix_txt,
                    x_cs1_telephone_number_txt          => p_interface.cs1_telephone_number_txt,
                    x_cs1_signature_code_txt            => p_interface.cs1_signature_code_txt,
                    x_cs2_lname                         => p_interface.cs2_lname,
                    x_cs2_fname                         => p_interface.cs2_fname,
                    x_cs2_mi_txt                        => p_interface.cs2_mi_txt,
                    x_cs2_ssn_txt                       => p_interface.cs2_ssn_txt,
                    x_cs2_citizenship_status            => p_interface.cs2_citizenship_status,
                    x_cs2_address_line_1_txt            => p_interface.cs2_address_line_1_txt,
                    x_cs2_address_line_2_txt            => p_interface.cs2_address_line_2_txt,
                    x_cs2_city_txt                      => p_interface.cs2_city_txt,
                    x_cs2_state_txt                     => p_interface.cs2_state_txt,
                    x_cs2_zip_txt                       => p_interface.cs2_zip_txt,
                    x_cs2_zip_suffix_txt                => p_interface.cs2_zip_suffix_txt,
                    x_cs2_telephone_number_txt          => p_interface.cs2_telephone_number_txt,
                    x_cs2_signature_code_txt            => p_interface.cs2_signature_code_txt,
                    x_cs1_credit_auth_code_txt          => p_interface.cs1_credit_auth_code_txt,
                    x_cs1_birth_date                    => p_interface.cs1_birth_date,
                    x_cs1_drv_license_num_txt           => p_interface.cs1_drv_license_num_txt,
                    x_cs1_drv_license_state_txt         => p_interface.cs1_drv_license_state_txt,
                    x_cs1_elect_sig_ind_code_txt        => p_interface.cs1_elect_sig_ind_code_txt,
                    x_cs1_frgn_postal_code_txt          => p_interface.cs1_frgn_postal_code_txt,
                    x_cs1_frgn_tel_num_prefix_txt       => p_interface.cs1_frgn_tel_num_prefix_txt,
                    x_cs1_gross_annual_sal_num          => p_interface.cs1_gross_annual_sal_num,
                    x_cs1_mthl_auto_pay_txt             => p_interface.cs1_mthl_auto_pay_txt,
                    x_cs1_mthl_cc_pay_txt               => p_interface.cs1_mthl_cc_pay_txt,
                    x_cs1_mthl_edu_loan_pay_txt         => p_interface.cs1_mthl_edu_loan_pay_txt,
                    x_cs1_mthl_housing_pay_txt          => p_interface.cs1_mthl_housing_pay_txt,
                    x_cs1_mthl_other_pay_txt            => p_interface.cs1_mthl_other_pay_txt,
                    x_cs1_other_income_amt              => p_interface.cs1_other_income_amt,
                    x_cs1_rel_to_student_flag           => p_interface.cs1_rel_to_student_flag,
                    x_cs1_suffix_txt                    => p_interface.cs1_suffix_txt,
                    x_cs1_years_at_address_txt          => p_interface.cs1_years_at_address_txt,
                    x_cs2_credit_auth_code_txt          => p_interface.cs2_credit_auth_code_txt,
                    x_cs2_birth_date                    => p_interface.cs2_birth_date,
                    x_cs2_drv_license_num_txt           => p_interface.cs2_drv_license_num_txt,
                    x_cs2_drv_license_state_txt         => p_interface.cs2_drv_license_state_txt,
                    x_cs2_elect_sig_ind_code_txt        => p_interface.cs2_elect_sig_ind_code_txt,
                    x_cs2_frgn_postal_code_txt          => p_interface.cs2_frgn_postal_code_txt,
                    x_cs2_frgn_tel_num_prefix_txt       => p_interface.cs2_frgn_tel_num_prefix_txt,
                    x_cs2_gross_annual_sal_num          => p_interface.cs2_gross_annual_sal_num,
                    x_cs2_mthl_auto_pay_txt             => p_interface.cs2_mthl_auto_pay_txt,
                    x_cs2_mthl_cc_pay_txt               => p_interface.cs2_mthl_cc_pay_txt,
                    x_cs2_mthl_edu_loan_pay_txt         => p_interface.cs2_mthl_edu_loan_pay_txt,
                    x_cs2_mthl_housing_pay_txt          => p_interface.cs2_mthl_housing_pay_txt,
                    x_cs2_mthl_other_pay_txt            => p_interface.cs2_mthl_other_pay_txt,
                    x_cs2_other_income_amt              => p_interface.cs2_other_income_amt,
                    x_cs2_rel_to_student_flag           => p_interface.cs2_rel_to_student_flag,
                    x_cs2_suffix_txt                    => p_interface.cs2_suffix_txt,
                    x_cs2_years_at_address_txt          => p_interface.cs2_years_at_address_txt
                    );

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','After insert into IGF_SL_ALT_BORW_ALL albw_id ' || ln_albw_id);
          END IF;

     END IF;

     OPEN  c_loan_dtls(ln_loan_id,ln_origination_id);
     FETCH c_loan_dtls INTO loan_rec;

     igf_sl_gen.get_person_details(loan_rec.student_id,student_dtl_cur);
     FETCH student_dtl_cur INTO student_dtl_rec;
     igf_sl_gen.get_person_details(loan_rec.p_person_id,parent_dtl_cur);
     FETCH parent_dtl_cur INTO parent_dtl_rec;


     CLOSE c_loan_dtls;
     CLOSE student_dtl_cur;
     CLOSE parent_dtl_cur;

     OPEN  cur_isir_depend_status(loan_rec.student_id);
     FETCH cur_isir_depend_status INTO  lv_dependency_status;
     CLOSE cur_isir_depend_status;

     lv_s_permt_phone  := igf_sl_gen.get_person_phone(loan_rec.student_id);
     lv_p_permt_phone  := igf_sl_gen.get_person_phone(loan_rec.p_person_id);

     --Code added for bug 3603289 start
     lv_s_license_number     := student_dtl_rec.p_license_num;
     lv_s_license_state      := student_dtl_rec.p_license_state;
     lv_s_citizenship_status := student_dtl_rec.p_citizenship_status;
     lv_alien_reg_num        := student_dtl_rec.p_alien_reg_num;
     lv_s_legal_res_date     := student_dtl_rec.p_legal_res_date;
     lv_s_legal_res_state    := student_dtl_rec.p_state_of_legal_res;
     --Code added for bug 3603289 end

     IF p_fed_fund = 'ALT' AND NVL(p_interface.b_stu_indicator_flag,'X') = 'Y' THEN

        parent_dtl_rec.p_citizenship_status := lv_s_citizenship_status;
        parent_dtl_rec.p_state_of_legal_res := lv_s_legal_res_state;
        parent_dtl_rec.p_legal_res_date     := lv_s_legal_res_date;
        loan_rec.p_default_status           := loan_rec.s_default_status;
        parent_dtl_rec.p_license_num        := lv_s_license_number;
        parent_dtl_rec.p_license_state      := lv_s_license_state;
        lv_p_permt_phone                    := lv_s_permt_phone;

     END IF;


     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_record.debug','Before insert into IGF_SL_LOR_LOC_ALL');
     END IF;

     loc_rowid := NULL;

     igf_sl_lor_loc_pkg.insert_row (
                    x_rowid                      => loc_rowid,
                    x_loan_id                    => ln_loan_id,
                    x_origination_id             => ln_origination_id,
                    x_loan_number                => p_interface.loan_number_txt,
                    x_loan_type                  => p_fed_fund,
                    x_loan_amt_offered           => l_get_award.offered_amt,
                    x_loan_amt_accepted          => l_get_award.accepted_amt,
                    x_loan_per_begin_date        => p_interface.loan_per_begin_date,
                    x_loan_per_end_date          => p_interface.loan_per_end_date,
                    x_acad_yr_begin_date         => NULL,--This is applicable for Direct Loans
                    x_acad_yr_end_date           => NULL,--This is applicable for Direct Loans
                    x_loan_status                => p_interface.loan_status_code,
                    x_loan_status_date           => p_interface.loan_status_date,
                    x_loan_chg_status            => NULL,--This is applicable for Direct Loans
                    x_loan_chg_status_date       => NULL,--This is applicable for Direct Loans
                    x_req_serial_loan_code       => p_interface.req_serial_loan_code,
                    x_act_serial_loan_code       => p_interface.act_serial_loan_code,
                    x_active                     => p_interface.active_flag,
                    x_active_date                => p_interface.active_date,
                    x_sch_cert_date              => p_interface.sch_cert_date,
                    x_orig_status_flag           => NULL,--This is applicable for Direct Loans
                    x_orig_batch_id              => p_interface.orig_batch_id_txt,
                    x_orig_batch_date            => p_interface.orig_batch_date,
                    x_chg_batch_id               => NULL,--This is applicable for Direct Loans
                    x_orig_ack_date              => p_interface.orig_ack_date,
                    x_credit_override            => NULL,
                    x_credit_decision_date       => p_interface.credit_status_date,
                    x_pnote_delivery_code        => p_interface.pnote_delivery_code,
                    x_pnote_status               => p_interface.pnote_status_code,
                    x_pnote_status_date          => p_interface.pnote_status_date,
                    x_pnote_id                   => NULL,--This is applicable for Direct Loans
                    x_pnote_print_ind            => NULL,--This is applicable for Direct Loans
                    x_pnote_accept_amt           => NULL,--This is applicable for Direct Loans
                    x_pnote_accept_date          => NULL,--This is applicable for Direct Loans
                    x_p_signature_code           => p_interface.b_signature_flag,
                    x_p_signature_date           => p_interface.b_signature_date,
                    x_s_signature_code           => p_interface.s_signature_flag,
                    x_unsub_elig_for_heal        => NULL,--This is applicable for Direct Loans
                    x_disclosure_print_ind       => NULL,--This is applicable for Direct Loans
                    x_orig_fee_perct             => l_setup.est_orig_fee_perct,
                    x_borw_confirm_ind           => p_interface.borw_confirm_flag,
                    x_borw_interest_ind          => p_interface.borw_interest_flag ,
                    x_unsub_elig_for_depnt       => NULL,--This is applicable for Direct Loans
                    x_guarantee_amt              => p_interface.guarantee_amt,
                    x_guarantee_date             => p_interface.guarantee_date,
                    x_guarnt_adj_ind             => p_interface.guarnt_adj_flag,
                    x_guarnt_amt_redn_code       => p_interface.guarnt_amt_redn_code,
                    x_guarnt_status_code         => p_interface.guarnt_status_code,
                    x_guarnt_status_date         => p_interface.guarnt_status_date,
                    x_lend_apprv_denied_code     => p_interface.lend_apprv_denied_code,
                    x_lend_apprv_denied_date     => p_interface.lend_apprv_denied_date,
                    x_lend_status_code           => p_interface.lend_status_code,
                    x_lend_status_date           => p_interface.lend_status_date,
                    x_grade_level_code           => p_interface.grade_level_code,
                    x_enrollment_code            => p_interface.enrollment_code,
                    x_anticip_compl_date         => p_interface.anticip_compl_date,
                    x_borw_lender_id             => loan_rec.lender_id,
                    x_duns_borw_lender_id        => NULL,
                    x_guarantor_id               => loan_rec.guarantor_id,
                    x_duns_guarnt_id             => NULL,
                    x_prc_type_code              => p_interface.prc_type_code,
                    x_rec_type_ind               => p_interface.record_code,
                    x_cl_loan_type               => lv_cl_loan_type,
                    x_cl_seq_number              => p_interface.cl_seq_num,
                    x_last_resort_lender         => p_interface.last_resort_lender_flag,
                    x_lender_id                  => loan_rec.lender_id,
                    x_duns_lender_id             => NULL,
                    x_lend_non_ed_brc_id         => loan_rec.lend_non_ed_brc_id,
                    x_recipient_id               => loan_rec.recipient_id,
                    x_recipient_type             => loan_rec.recipient_type,
                    x_duns_recip_id              => NULL,
                    x_recip_non_ed_brc_id        => loan_rec.recip_non_ed_brc_id,
                    x_cl_rec_status              => p_interface.cl_rec_status,
                    x_cl_rec_status_last_update  => p_interface.cl_rec_status_last_update,
                    x_alt_prog_type_code         => p_interface.alt_prog_type_cd,
                    x_alt_appl_ver_code          => p_interface.alt_appl_ver_code_num,
                    x_borw_outstd_loan_code      => p_interface.borw_outstd_loan_flag,
                    x_mpn_confirm_code           => p_interface.mpn_confirm_code,
                    x_resp_to_orig_code          => p_interface.resp_to_orig_flag,
                    x_appl_loan_phase_code       => p_interface.appl_loan_phase_code,
                    x_appl_loan_phase_code_chg   => p_interface.appl_loan_phase_code_chg,
                    x_tot_outstd_stafford        => p_interface.tot_outstd_stafford_amt,
                    x_tot_outstd_plus            => p_interface.tot_outstd_plus_amt,
                    x_alt_borw_tot_debt          => p_interface.alt_borw_tot_stu_loan_debt_amt,
                    x_act_interest_rate          => p_interface.act_interest_rate_num,
                    x_service_type_code          => p_interface.service_type_code,
                    x_rev_notice_of_guarnt       => p_interface.rev_notice_of_guarnt_code,
                    x_sch_refund_amt             => p_interface.sch_refund_amt,
                    x_sch_refund_date            => p_interface.sch_refund_date,
                    x_uniq_layout_vend_code      => p_interface.uniq_layout_vend_code,
                    x_uniq_layout_ident_code     => p_interface.uniq_layout_ident_code,
                    x_p_person_id                => loan_rec.p_person_id,
                    x_p_ssn                      => SUBSTR(parent_dtl_rec.p_ssn,1,9),
                    x_p_ssn_chg_date             => NULL,-- Change field
                    x_p_last_name                => parent_dtl_rec.p_last_name,
                    x_p_first_name               => parent_dtl_rec.p_first_name,
                    x_p_middle_name              => parent_dtl_rec.p_middle_name,
                    x_p_permt_addr1              => parent_dtl_rec.p_permt_addr1,
                    x_p_permt_addr2              => parent_dtl_rec.p_permt_addr2,
                    x_p_permt_city               => parent_dtl_rec.p_permt_city,
                    x_p_permt_state              => parent_dtl_rec.p_permt_state,
                    x_p_permt_zip                => parent_dtl_rec.p_permt_zip,
                    x_p_permt_addr_chg_date      => NULL,-- Change field
                    x_p_permt_phone              => lv_p_permt_phone,
                    x_p_email_addr               => parent_dtl_rec.p_email_addr,
                    x_p_date_of_birth            => parent_dtl_rec.p_date_of_birth,
                    x_p_dob_chg_date             => NULL,-- Change field
                    x_p_license_num              => parent_dtl_rec.p_license_num,
                    x_p_license_state            => parent_dtl_rec.p_license_state,
                    x_p_citizenship_status       => parent_dtl_rec.p_citizenship_status,
                    x_p_alien_reg_num            => parent_dtl_rec.p_alien_reg_num,
                    x_p_default_status           => loan_rec.p_default_status,
                    x_p_foreign_postal_code      => p_interface.b_foreign_postal_cd,
                    x_p_state_of_legal_res       => parent_dtl_rec.p_state_of_legal_res,
                    x_p_legal_res_date           => parent_dtl_rec.p_legal_res_date,
                    x_s_ssn                      => SUBSTR(student_dtl_rec.p_ssn,1,9),
                    x_s_ssn_chg_date             => NULL,-- Change field
                    x_s_last_name                => student_dtl_rec.p_last_name,
                    x_s_first_name               => student_dtl_rec.p_first_name,
                    x_s_middle_name              => student_dtl_rec.p_middle_name,
                    x_s_permt_addr1              => student_dtl_rec.p_permt_addr1,
                    x_s_permt_addr2              => student_dtl_rec.p_permt_addr2,
                    x_s_permt_city               => student_dtl_rec.p_permt_city,
                    x_s_permt_state              => student_dtl_rec.p_permt_state,
                    x_s_permt_zip                => student_dtl_rec.p_permt_zip,
                    x_s_permt_addr_chg_date      => NULL,-- Change field
                    x_s_permt_phone              => lv_s_permt_phone,
                    x_s_local_addr1              => student_dtl_rec.p_local_addr1,
                    x_s_local_addr2              => student_dtl_rec.p_local_addr2,
                    x_s_local_city               => student_dtl_rec.p_local_city,
                    x_s_local_state              => student_dtl_rec.p_local_state,
                    x_s_local_zip                => student_dtl_rec.p_local_zip,
                    x_s_local_addr_chg_date      => NULL,-- Change field
                    x_s_email_addr               => student_dtl_rec.p_email_addr,
                    x_s_date_of_birth            => student_dtl_rec.p_date_of_birth,
                    x_s_dob_chg_date             => NULL,-- Change field
                    x_s_license_num              => lv_s_license_number,
                    x_s_license_state            => lv_s_license_state,
                    x_s_depncy_status            => lv_dependency_status,
                    x_s_default_status           => p_interface.s_default_status_flag,
                    x_s_citizenship_status       => lv_s_citizenship_status,
                    x_s_alien_reg_num            => lv_alien_reg_num,
                    x_s_foreign_postal_code      => p_interface.b_foreign_postal_cd,
                    x_mode                       => 'R',
                    x_pnote_batch_id             => NULL,
                    x_pnote_ack_date             => NULL,
                    x_pnote_mpn_ind              => NULL,
                    x_award_id                   => p_award_id,
                    x_base_id                    => l_get_base_id.base_id,
                    x_document_id_txt            => NULL,
                    x_loan_key_num               => NULL,
                    x_interest_rebate_percent_num=> NULL,
                    x_fin_award_year             => NULL,
                    x_cps_trans_num              => NULL,
                    x_atd_entity_id_txt          => NULL,
                    x_rep_entity_id_txt          => NULL,
                    x_source_entity_id_txt       => NULL,
                    x_pymt_servicer_amt          => NULL,
                    x_pymt_servicer_date         => NULL,
                    x_book_loan_amt              => NULL,
                    x_book_loan_amt_date         => NULL,
                    x_s_chg_birth_date           => NULL,
                    x_s_chg_ssn                  => NULL,
                    x_s_chg_last_name            => NULL,
                    x_b_chg_birth_date           => NULL,
                    x_b_chg_ssn                  => NULL,
                    x_b_chg_last_name            => NULL,
                    x_note_message               => NULL,
                    x_full_resp_code             => NULL,
                    x_s_permt_county             => NULL,
                    x_b_permt_county             => NULL,
                    x_s_permt_country            => NULL,
                    x_b_permt_country            => NULL,
                    x_crdt_decision_status       => p_interface.credit_status_code,
                    x_actual_record_type_code    => p_interface.actual_record_type_code,
                    x_alt_approved_amt           => p_interface.alt_approved_amt,
                    x_alt_borrower_ind_flag      => p_interface.b_stu_indicator_flag,
                    x_borower_credit_authoriz_flag => p_interface.borr_credit_auth_flag,
                    x_borower_electronic_sign_flag => p_interface.borr_sign_flag,
                    x_cost_of_attendance_amt       => p_interface.coa_amt,
                    x_deferment_request_code       => p_interface.defer_req_flag,
                    x_eft_authorization_code       => p_interface.eft_auth_flag,
                    x_established_fin_aid_amount   => p_interface.est_fa_amt,
                    x_expect_family_contribute_amt => p_interface.efc_amt,
                    x_external_loan_id_txt         => p_interface.external_loan_id_txt,
                    x_flp_approved_amt             => p_interface.flp_approved_amt,
                    x_fls_approved_amt             => p_interface.fls_approved_amt,
                    x_flu_approved_amt             => p_interface.flu_approved_amt,
                    x_guarantor_use_txt            => p_interface.guarantor_use_txt,
                    x_lender_use_txt               => p_interface.lender_use_txt,
                    x_loan_app_form_code           => p_interface.fed_appl_form_type,
                    x_mpn_type_flag                => NULL,
                    x_reinstatement_amt            => p_interface.reinst_avail_amt,
                    x_requested_loan_amt           => p_interface.req_loan_amt,
                    x_school_id_txt                => SUBSTR(p_interface.loan_number_txt,1,8),
                    x_school_use_txt               => p_interface.school_use_txt,
                    x_student_electronic_sign_flag => p_interface.stud_sign_flag,
                    x_esign_src_typ_cd             => p_interface.esign_src_typ_cd
                    );

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_record.debug','After insert into IGF_SL_LOR_LOC_ALL');
     END IF;

     IF ( p_fed_fund in ('ALT','FLP','GPLUSFL') ) AND  (NVL(p_interface.b_stu_indicator_flag,'X') <> 'Y') THEN
          l_b_last_name           :=    parent_dtl_rec.p_last_name;
          l_b_first_name          :=    parent_dtl_rec.p_first_name;
          l_b_middle_name         :=    parent_dtl_rec.p_middle_name;
          l_b_ssn                 :=    SUBSTR(parent_dtl_rec.p_ssn,1,9);
          l_b_permt_addr1         :=    parent_dtl_rec.p_permt_addr1;
          l_b_permt_addr2         :=    parent_dtl_rec.p_permt_addr2;
          l_b_permt_city          :=    parent_dtl_rec.p_permt_city;
          l_b_permt_state         :=    parent_dtl_rec.p_permt_state;
          l_b_permt_zip           :=    parent_dtl_rec.p_permt_zip;
          l_b_permt_zip_suffix    :=    NULL;
          l_b_permt_phone         :=    lv_p_permt_phone;
          l_b_signature_code      :=    p_interface.b_signature_flag;
          l_b_signature_date      :=    p_interface.b_signature_date;
          l_b_citizenship_status  :=    parent_dtl_rec.p_citizenship_status;
          l_b_state_of_legal_res  :=    parent_dtl_rec.p_state_of_legal_res;
          l_b_legal_res_date      :=    parent_dtl_rec.p_legal_res_date;
          l_b_default_status      :=    p_interface.b_default_status_flag ;
          l_b_license_state       :=    p_interface.b_license_state_code;
          l_b_license_number      :=    p_interface.b_license_number_txt;
          l_b_dob                 :=    parent_dtl_rec.p_date_of_birth;
     ELSE
          l_b_last_name           :=    student_dtl_rec.p_last_name;
          l_b_first_name          :=    student_dtl_rec.p_first_name;
          l_b_middle_name         :=    student_dtl_rec.p_middle_name;
          l_b_ssn                 :=    SUBSTR(student_dtl_rec.p_ssn,1,9);
          l_b_permt_addr1         :=    student_dtl_rec.p_permt_addr1;
          l_b_permt_addr2         :=    student_dtl_rec.p_permt_addr2;
          l_b_permt_city          :=    student_dtl_rec.p_permt_city;
          l_b_permt_state         :=    student_dtl_rec.p_permt_state;
          l_b_permt_zip           :=    student_dtl_rec.p_permt_zip;
          l_b_permt_zip_suffix    :=    NULL;
          l_b_permt_phone         :=    lv_s_permt_phone;
          l_b_signature_code      :=    p_interface.s_signature_flag;
          l_b_signature_date      :=    p_interface.b_signature_date;
          l_b_citizenship_status  :=    lv_s_citizenship_status;
          l_b_state_of_legal_res  :=    lv_s_legal_res_state;
          l_b_legal_res_date      :=    lv_s_legal_res_date;
          l_b_default_status      :=    p_interface.s_default_status_flag;
          l_b_license_state       :=    lv_s_license_state;
          l_b_license_number      :=    lv_s_license_number;
          l_b_dob                 :=    student_dtl_rec.p_date_of_birth;
     END IF;

     IF NVL(p_interface.send_resp_code,'X') = 'S'  THEN
        ln_cbth_id := NULL;

        OPEN  chk_batch_id(p_interface.orig_send_batch_id_txt);
        FETCH chk_batch_id INTO l_batch_id;

        IF (chk_batch_id%NOTFOUND) THEN
          CLOSE  chk_batch_id;
          clb_rowid  := NULL;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','Before insert into IGF_SL_CL_BATCH_ALL - I');
          END IF;

          igf_sl_cl_batch_pkg.insert_row (
                   x_rowid                     =>  clb_rowid,
                   x_cbth_id                   =>  ln_cbth_id,
                   x_batch_id                  =>  p_interface.orig_send_batch_id_txt,
                   x_file_creation_date        =>  p_interface.file_creation_date,
                   x_file_trans_date           =>  p_interface.file_trans_date ,
                   x_file_ident_code           =>  'A005P',
                   x_recipient_id              =>  NULL,
                   x_recip_non_ed_brc_id       =>  NULL,
                   x_source_id                 =>  p_interface.source_id_txt,
                   x_source_non_ed_brc_id      =>  p_interface.source_non_ed_brc_id_txt,
                   x_send_resp                 =>  p_interface.send_resp_code,
                   x_mode                      =>  'R',
                   x_record_count_num          =>  NULL,
                   x_total_net_disb_amt        =>  NULL,
                   x_total_net_eft_amt         =>  NULL,
                   x_total_net_non_eft_amt     =>  NULL,
                   x_total_reissue_amt         =>  NULL,
                   x_total_cancel_amt          =>  NULL,
                   x_total_deficit_amt         =>  NULL,
                   x_total_net_cancel_amt      =>  NULL,
                   x_total_net_out_cancel_amt  =>  NULL);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','After insert into IGF_SL_CL_BATCH_ALL - I ln_cbth_id ' || ln_cbth_id);
          END IF;
        ELSE
           CLOSE  chk_batch_id;
        END IF;

     END IF;

     IF NVL(p_interface.send_resp_code,'X') = 'R'     AND
        p_interface.loan_status_code NOT IN ('G','N')

     THEN

        ln_cbth_id := NULL;

        OPEN chk_batch_id(p_interface.orig_ack_batch_id_txt);
        FETCH chk_batch_id INTO l_batch_id;

        IF (chk_batch_id%NOTFOUND) THEN
          CLOSE  chk_batch_id;
          clb_rowid  := NULL;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_record.debug','Before insert into IGF_SL_CL_BATCH_ALL');
          END IF;

          igf_sl_cl_batch_pkg.insert_row (
                   x_rowid                     =>  clb_rowid,
                   x_cbth_id                   =>  ln_cbth_id,
                   x_batch_id                  =>  p_interface.orig_ack_batch_id_txt ,
                   x_file_creation_date        =>  p_interface.file_creation_date,
                   x_file_trans_date           =>  p_interface.file_trans_date ,
                   x_file_ident_code           =>  'R005P',
                   x_recipient_id              =>  NULL,
                   x_recip_non_ed_brc_id       =>  NULL,
                   x_source_id                 =>  p_interface.source_id_txt,
                   x_source_non_ed_brc_id      =>  p_interface.source_non_ed_brc_id_txt,
                   x_send_resp                 =>  p_interface.send_resp_code,
                   x_mode                      =>  'R',
                   x_record_count_num          =>  NULL,
                   x_total_net_disb_amt        =>  NULL,
                   x_total_net_eft_amt         =>  NULL,
                   x_total_net_non_eft_amt     =>  NULL,
                   x_total_reissue_amt         =>  NULL,
                   x_total_cancel_amt          =>  NULL,
                   x_total_deficit_amt         =>  NULL,
                   x_total_net_cancel_amt      =>  NULL,
                   x_total_net_out_cancel_amt  =>  NULL);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','Before insert into IGF_SL_CL_BATCH_ALL ln_cbth_id ' || ln_cbth_id);
          END IF;
        ELSE
           CLOSE  chk_batch_id;
        END IF;

      -- POPULATE R1 AND R4
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','Before insert into IGF_SL_CL_RESP_R1');
        END IF;

        l_rl_row_id := NULL;

        IF ln_cbth_id IS NULL THEN
            ln_cbth_id := l_batch_id.cbth_id;
        END IF;

        l_clrp1_id := NULL;

        igf_sl_cl_resp_r1_pkg.insert_row (
                              x_mode                       =>  'R',
                              x_rowid                      =>  l_rl_row_id,
                              x_clrp1_id                   =>  l_clrp1_id, -- generated by sequence and value returned
                              x_cbth_id                    =>  ln_cbth_id,
                              x_rec_code                   =>  '@1',
                              x_rec_type_ind               =>  p_interface.record_code,
                              x_b_last_name                =>  l_b_last_name,
                              x_b_first_name               =>  l_b_first_name,
                              x_b_middle_name              =>  l_b_middle_name,
                              x_b_ssn                      =>  TO_NUMBER(l_b_ssn),
                              x_b_permt_addr1              =>  l_b_permt_addr1,
                              x_b_permt_addr2              =>  l_b_permt_addr2,
                              x_b_permt_city               =>  l_b_permt_city,
                              x_b_permt_state              =>  l_b_permt_state,
                              x_b_permt_zip                =>  l_b_permt_zip,
                              x_b_permt_zip_suffix         =>  l_b_permt_zip_suffix,
                              x_b_permt_phone              =>  l_b_permt_phone,
                              x_b_date_of_birth            =>  l_b_dob,
                              x_cl_loan_type               =>  lv_cl_loan_type,
                              x_req_loan_amt               =>  p_interface.req_loan_amt,
                              x_defer_req_code             =>  p_interface.defer_req_flag,
                              x_borw_interest_ind          =>  p_interface.borw_interest_flag,
                              x_eft_auth_code              =>  p_interface.eft_auth_flag,
                              x_b_signature_code           =>  l_b_signature_code,
                              x_b_signature_date           =>  l_b_signature_date,
                              x_loan_number                =>  p_interface.loan_number_txt,
                              x_cl_seq_number              =>  p_interface.cl_seq_num,
                              x_borr_credit_auth_code      =>  p_interface.borr_credit_auth_flag,
                              x_b_citizenship_status       =>  l_b_citizenship_status,
                              x_b_state_of_legal_res       =>  l_b_state_of_legal_res,
                              x_b_legal_res_date           =>  l_b_legal_res_date,
                              x_b_default_status           =>  l_b_default_status,
                              x_b_outstd_loan_code         =>  p_interface.borw_outstd_loan_flag,
                              x_b_indicator_code           =>  p_interface.b_stu_indicator_flag,
                              x_s_last_name                =>  student_dtl_rec.p_last_name,
                              x_s_first_name               =>  student_dtl_rec.p_first_name,
                              x_s_middle_name              =>  student_dtl_rec.p_middle_name,
                              x_s_ssn                      =>  TO_NUMBER(SUBSTR(student_dtl_rec.p_ssn,1,9)),
                              x_s_date_of_birth            =>  student_dtl_rec.p_date_of_birth,
                              x_s_citizenship_status       =>  lv_s_citizenship_status,
                              x_s_default_code             =>  p_interface.s_default_status_flag,
                              x_s_signature_code           =>  p_interface.s_signature_flag,
                              x_school_id                  =>  SUBSTR(p_interface.loan_number_txt,1,8),
                              x_loan_per_begin_date        =>  p_interface.loan_per_begin_date,
                              x_loan_per_end_date          =>  p_interface.loan_per_end_date,
                              x_grade_level_code           =>  p_interface.grade_level_code,
                              x_borr_sign_ind              =>  p_interface.borr_sign_flag,
                              x_enrollment_code            =>  p_interface.enrollment_code,
                              x_anticip_compl_date         =>  p_interface.anticip_compl_date,
                              x_coa_amt                    =>  p_interface.coa_amt,
                              x_efc_amt                    =>  p_interface.efc_amt,
                              x_est_fa_amt                 =>  p_interface.est_fa_amt,
                              x_fls_cert_amt               =>  p_interface.fls_cert_amt,
                              x_flu_cert_amt               =>  p_interface.flu_cert_amt,
                              x_flp_cert_amt               =>  p_interface.flp_cert_amt,
                              x_sch_cert_date              =>  p_interface.sch_cert_date,
                              x_alt_cert_amt               =>  p_interface.alt_cert_amt,
                              x_alt_appl_ver_code          =>  p_interface.alt_appl_ver_code_num,
                              x_duns_school_id             =>  NULL,
                              x_lender_id                  =>  NULL,
                              x_fls_approved_amt           =>  p_interface.fls_approved_amt,
                              x_flu_approved_amt           =>  p_interface.flu_approved_amt,
                              x_flp_approved_amt           =>  p_interface.flp_approved_amt,
                              x_alt_approved_amt           =>  p_interface.alt_approved_amt,
                              x_duns_lender_id             =>  NULL,
                              x_guarantor_id               =>  NULL,
                              x_fed_appl_form_code         =>  p_interface.fed_appl_form_type,
                              x_duns_guarnt_id             =>  NULL,
                              x_lend_blkt_guarnt_ind       =>  p_interface.lend_blkt_guarnt_flag,
                              x_lend_blkt_guarnt_appr_date =>  p_interface.lend_blkt_guarnt_appr_date,
                              x_guarnt_adj_ind             =>  p_interface.guarnt_adj_flag,
                              x_guarantee_date             =>  p_interface.guarantee_date,
                              x_guarantee_amt              =>  p_interface.guarantee_amt,
                              x_req_serial_loan_code       =>  p_interface.req_serial_loan_code,
                              x_borw_confirm_ind           =>  p_interface.borw_confirm_flag,
                              x_b_license_state            =>  l_b_license_state,
                              x_b_license_number           =>  l_b_license_number,
                              x_b_ref_code                 =>  p_interface.b_reference_flag,
                              x_pnote_delivery_code        =>  p_interface.pnote_delivery_code,
                              x_b_foreign_postal_code      =>  p_interface.b_foreign_postal_cd,
                              x_stud_sign_ind              =>  p_interface.stud_sign_flag,
                              x_lend_non_ed_brc_id         =>  NULL,
                              x_last_resort_lender         =>  p_interface.last_resort_lender_flag,
                              x_resp_to_orig_code          =>  p_interface.resp_to_orig_flag,
                              x_err_mesg_1                 =>  p_interface.err_mesg_1_cd,
                              x_err_mesg_2                 =>  p_interface.err_mesg_2_cd,
                              x_err_mesg_3                 =>  p_interface.err_mesg_3_cd,
                              x_err_mesg_4                 =>  p_interface.err_mesg_4_cd,
                              x_err_mesg_5                 =>  p_interface.err_mesg_5_cd,
                              x_guarnt_amt_redn_code       =>  p_interface.guarnt_amt_redn_code,
                              x_tot_outstd_stafford        =>  p_interface.tot_outstd_stafford_amt,
                              x_tot_outstd_plus            =>  p_interface.tot_outstd_plus_amt,
                              x_b_permt_addr_chg_date      =>  p_interface.b_permt_addr_chg_date,
                              x_alt_prog_type_code         =>  p_interface.alt_prog_type_cd,
                              x_alt_borw_tot_debt          =>  p_interface.alt_borw_tot_stu_loan_debt_amt,
                              x_act_interest_rate          =>  p_interface.act_interest_rate_num,
                              x_prc_type_code              =>  p_interface.prc_type_code,
                              x_service_type_code          =>  p_interface.service_type_code,
                              x_rev_notice_of_guarnt       =>  p_interface.rev_notice_of_guarnt_code,
                              x_sch_refund_amt             =>  p_interface.sch_refund_amt,
                              x_sch_refund_date            =>  p_interface.sch_refund_date,
                              x_guarnt_status_code         =>  p_interface.guarnt_status_code,
                              x_lender_status_code         =>  p_interface.lend_status_code,
                              x_pnote_status_code          =>  p_interface.pnote_status_code,
                              x_credit_status_code         =>  p_interface.credit_status_code,
                              x_guarnt_status_date         =>  p_interface.guarnt_status_date,
                              x_lender_status_date         =>  p_interface.lend_status_date,
                              x_pnote_status_date          =>  p_interface.pnote_status_date,
                              x_credit_status_date         =>  p_interface.credit_status_date,
                              x_act_serial_loan_code       =>  p_interface.act_serial_loan_code,
                              x_amt_avail_for_reinst       =>  p_interface.reinst_avail_amt,
                              x_sch_non_ed_brc_id          =>  p_interface.source_non_ed_brc_id_txt,
                              x_uniq_layout_vend_code      =>  p_interface.uniq_layout_vend_code,
                              x_uniq_layout_ident_code     =>  p_interface.uniq_layout_ident_code,
                              x_resp_record_status         =>  'Y',
                              x_appl_loan_phase_code       => p_interface.appl_loan_phase_code,
                              x_appl_loan_phase_code_chg   => p_interface.appl_loan_phase_code_chg,
                              x_cl_rec_status              => p_interface.cl_rec_status,
                              x_cl_rec_status_last_update  => p_interface.cl_rec_status_last_update,
                              x_cl_version_code            => g_rel_version,
                              x_guarantor_use_txt          => p_interface.guarantor_use_txt,
                              x_lend_apprv_denied_code     => p_interface.lend_apprv_denied_code,
                              x_lend_apprv_denied_date     => p_interface.lend_apprv_denied_date,
                              x_lender_use_txt             => p_interface.lender_use_txt,
                              x_mpn_confirm_ind            => p_interface.mpn_confirm_code,
                              x_school_use_txt             => p_interface.school_use_txt,
                              x_b_alien_reg_num_txt        => NULL,
                              x_esign_src_typ_cd           => p_interface.esign_src_typ_cd
                              );

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','After insert into IGF_SL_CL_RESP_R1 l_clrp1_id ' || l_clrp1_id);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','Before insert into IGF_SL_CL_RESP_R4');
          END IF;

          l_r4_row_id := NULL;

          igf_sl_cl_resp_r4_pkg.insert_row (
                     x_mode                              => 'R',
                     x_rowid                             =>  l_r4_row_id,
                     x_clrp1_id                          =>  l_clrp1_id,
                     x_loan_number                       =>  p_interface.loan_number_txt,
                     x_fed_stafford_loan_debt            =>  p_interface.fed_stafford_loan_debt_amt,
                     x_fed_sls_debt                      =>  p_interface.fed_sls_debt_amt ,
                     x_heal_debt                         =>  p_interface.heal_debt_amt ,
                     x_perkins_debt                      =>  p_interface.perkins_debt_amt ,
                     x_other_debt                        =>  p_interface.other_debt_amt ,
                     x_crdt_undr_difft_name              =>  p_interface.crdt_undr_difft_name_flag,
                     x_borw_gross_annual_sal             =>  p_interface.borw_gross_annual_sal_amt,
                     x_borw_other_income                 =>  p_interface.borw_other_income_amt ,
                     x_student_major                     =>  p_interface.student_major_txt ,
                     x_int_rate_opt                      =>  p_interface.int_rate_opt_code,
                     x_repayment_opt_code                =>  p_interface.repayment_opt_code,
                     x_stud_mth_housing_pymt             =>  p_interface.stud_mth_housing_pymt_amt ,
                     x_stud_mth_crdtcard_pymt            =>  p_interface.stud_mth_crdtcard_pymt_amt ,
                     x_stud_mth_auto_pymt                =>  p_interface.stud_mth_auto_pymt_amt ,
                     x_stud_mth_ed_loan_pymt             =>  p_interface.stud_mth_ed_loan_pymt_amt ,
                     x_stud_mth_other_pymt               =>  p_interface.stud_mth_other_pymt_amt ,
                     x_cosnr_1_last_name                 =>  NULL,
                     x_cosnr_1_first_name                =>  NULL,
                     x_cosnr_1_middle_name               =>  NULL,
                     x_cosnr_1_ssn                       =>  NULL,
                     x_cosnr_1_citizenship               =>  NULL,
                     x_cosnr_1_addr_line1                =>  NULL,
                     x_cosnr_1_addr_line2                =>  NULL,
                     x_cosnr_1_city                      =>  NULL,
                     x_cosnr_1_state                     =>  NULL,
                     x_cosnr_1_zip                       =>  NULL,
                     x_cosnr_1_zip_suffix                =>  NULL,
                     x_cosnr_1_phone                     =>  NULL,
                     x_cosnr_1_sig_code                  =>  NULL,
                     x_cosnr_1_gross_anl_sal             =>  NULL,
                     x_cosnr_1_other_income              =>  NULL,
                     x_cosnr_1_forn_postal_code          =>  NULL,
                     x_cosnr_1_forn_phone_prefix         =>  NULL,
                     x_cosnr_1_dob                       =>  NULL,
                     x_cosnr_1_license_state             =>  NULL,
                     x_cosnr_1_license_num               =>  NULL,
                     x_cosnr_1_relationship_to           =>  NULL,
                     x_cosnr_1_years_at_addr             =>  NULL,
                     x_cosnr_1_mth_housing_pymt          =>  NULL,
                     x_cosnr_1_mth_crdtcard_pymt         =>  NULL,
                     x_cosnr_1_mth_auto_pymt             =>  NULL,
                     x_cosnr_1_mth_ed_loan_pymt          =>  NULL,
                     x_cosnr_1_mth_other_pymt            =>  NULL,
                     x_cosnr_1_crdt_auth_code            =>  NULL,
                     x_cosnr_2_last_name                 =>  NULL,
                     x_cosnr_2_first_name                =>  NULL,
                     x_cosnr_2_middle_name               =>  NULL,
                     x_cosnr_2_ssn                       =>  NULL,
                     x_cosnr_2_citizenship               =>  NULL,
                     x_cosnr_2_addr_line1                =>  NULL,
                     x_cosnr_2_addr_line2                =>  NULL,
                     x_cosnr_2_city                      =>  NULL,
                     x_cosnr_2_state                     =>  NULL,
                     x_cosnr_2_zip                       =>  NULL,
                     x_cosnr_2_zip_suffix                =>  NULL,
                     x_cosnr_2_phone                     =>  NULL,
                     x_cosnr_2_sig_code                  =>  NULL,
                     x_cosnr_2_gross_anl_sal             =>  NULL,
                     x_cosnr_2_other_income              =>  NULL,
                     x_cosnr_2_forn_postal_code          =>  NULL,
                     x_cosnr_2_forn_phone_prefix         =>  NULL,
                     x_cosnr_2_dob                       =>  NULL,
                     x_cosnr_2_license_state             =>  NULL,
                     x_cosnr_2_license_num               =>  NULL,
                     x_cosnr_2_relationship_to           =>  NULL,
                     x_cosnr_2_years_at_addr             =>  NULL,
                     x_cosnr_2_mth_housing_pymt          =>  NULL,
                     x_cosnr_2_mth_crdtcard_pymt         =>  NULL,
                     x_cosnr_2_mth_auto_pymt             =>  NULL,
                     x_cosnr_2_mth_ed_loan_pymt          =>  NULL,
                     x_cosnr_2_mth_other_pymt            =>  NULL,
                     x_cosnr_2_crdt_auth_code            =>  NULL,
                     x_other_loan_amt                    =>  p_interface.other_loan_amt,
                     x_alt_layout_owner_code_txt         =>  NULL,
                     x_alt_layout_identi_code_txt        =>  NULL,
                     x_student_school_phone_txt          =>  NULL,
                     x_first_csgnr_elec_sign_flag        =>  NULL,
                     x_second_csgnr_elec_sign_flag       =>  NULL
                    );

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','Before insert into IGF_SL_CL_RESP_R4 l_clrp1_id ' || l_clrp1_id);
          END IF;
          -- THEN R8 BASED ON RECORD RETRIEVED THRU R1
          i := 0;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','Before insert into IGF_SL_CL_RESP_R8');
          END IF;

          FOR l_disb_interface IN c_disb_interface( p_interface.ci_alternate_code,
                                                    p_interface.person_number,
                                                    p_interface.award_number_txt,
                                                    p_interface.loan_number_txt
                                                  ) LOOP
              i := i+1;

              lv_disb_net_amt := NVL(l_disb_interface.gross_disbursement_amt,0) - NVL(l_disb_interface.guarantee_fee_amt,0) - NVL(l_disb_interface.origination_fee_amt,0)
                     + NVL(l_disb_interface.guarantee_fees_paid_amt,0) + NVL(l_disb_interface.origination_fees_paid_amt,0);

              OPEN  c_disb_det(l_disb_interface.disbursement_num);
              FETCH c_disb_det INTO l_disb_det;
              CLOSE c_disb_det;

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','Before Update IGF_AW_AWD_DISB');
              END IF;

              igf_aw_awd_disb_pkg.update_row (
                               x_mode                              => 'R',
                               x_rowid                             => l_disb_det.rowid,
                               x_award_id                          => l_disb_det.award_id,
                               x_disb_num                          => l_disb_det.disb_num,
                               x_tp_cal_type                       => l_disb_det.tp_cal_type,
                               x_tp_sequence_number                => l_disb_det.tp_sequence_number   ,
                               x_disb_gross_amt                    => l_disb_det.disb_gross_amt,
                               x_fee_1                             => l_disb_interface.origination_fee_amt,
                               x_fee_2                             => l_disb_interface.guarantee_fee_amt,
                               x_disb_net_amt                      => lv_disb_net_amt,
                               x_disb_date                         => l_disb_det.disb_date,
                               x_trans_type                        => l_disb_det.trans_type,
                               x_elig_status                       => l_disb_det.elig_status,
                               x_elig_status_date                  => l_disb_det.elig_status_date,
                               x_affirm_flag                       => l_disb_det.affirm_flag,
                               x_hold_rel_ind                      => l_disb_interface.disbursement_hld_release_flag,
                               x_manual_hold_ind                   => l_disb_det.manual_hold_ind,
                               x_disb_status                       => l_disb_interface.disbursement_status_code,
                               x_disb_status_date                  => l_disb_interface.disbursement_status_date,
                               x_late_disb_ind                     => l_disb_interface.late_disbursement_flag,
                               x_fund_dist_mthd                    => l_disb_interface.fund_dist_mthd_type,
                               x_prev_reported_ind                 => l_disb_interface.prev_reported_flag,
                               x_fund_release_date                 => l_disb_interface.fund_release_date,
                               x_fund_status                       => l_disb_interface.fund_status_code,
                               x_fund_status_date                  => l_disb_interface.fund_status_date,
                               x_fee_paid_1                        => l_disb_interface.origination_fees_paid_amt,
                               x_fee_paid_2                        => l_disb_interface.guarantee_fees_paid_amt,
                               x_cheque_number                     => l_disb_interface.check_number_txt,
                               x_ld_cal_type                       => l_disb_det.ld_cal_type,
                               x_ld_sequence_number                => l_disb_det.ld_sequence_number,
                               x_disb_accepted_amt                 => l_disb_det.disb_accepted_amt,
                               x_disb_paid_amt                     => l_disb_det.disb_paid_amt,
                               x_rvsn_id                           => l_disb_det.rvsn_id,
                               x_int_rebate_amt                    => l_disb_det.int_rebate_amt,
                               x_force_disb                        => l_disb_det.force_disb,
                               x_min_credit_pts                    => l_disb_det.min_credit_pts,
                               x_disb_exp_dt                       => l_disb_det.disb_exp_dt,
                               x_verf_enfr_dt                      => l_disb_det.verf_enfr_dt,
                               x_fee_class                         => l_disb_det.fee_class,
                               x_show_on_bill                      => l_disb_det.show_on_bill,
                               x_attendance_type_code              => l_disb_det.attendance_type_code,
                               x_base_attendance_type_code         => l_disb_det.base_attendance_type_code,
                               x_change_type_code                  => l_disb_det.change_type_code,
                               x_fund_return_mthd_code             => l_disb_det.fund_return_mthd_code,
                               x_payment_prd_st_date               => l_disb_det.payment_prd_st_date,
                               x_direct_to_borr_flag               => l_disb_interface.direct_to_borr_flag
                               );

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','Before insert into IGF_SL_CL_RESP_R8 - LOOP');
              END IF;

              igf_sl_cl_resp_r8_pkg.insert_row (
                        x_mode                   => 'R',
                        x_rowid                  => l_r8_row_id,
                        x_clrp1_id               => l_clrp1_id,
                        x_clrp8_id               => i,
                        x_disb_date              => l_disb_interface.disbursement_date,
                        x_disb_gross_amt         => l_disb_interface.gross_disbursement_amt,
                        x_orig_fee               => l_disb_interface.origination_fee_amt,
                        x_guarantee_fee          => l_disb_interface.guarantee_fee_amt,
                        x_net_disb_amt           => lv_disb_net_amt,
                        x_disb_hold_rel_ind      => l_disb_interface.disbursement_hld_release_flag,
                        x_disb_status            => l_disb_interface.disbursement_status_code,
                        x_guarnt_fee_paid        => l_disb_interface.guarantee_fees_paid_amt,
                        x_orig_fee_paid          => l_disb_interface.origination_fees_paid_amt,
                        x_resp_record_status     => 'Y',
                        x_layout_owner_code_txt   => NULL,
                        x_layout_version_code_txt => NULL,
                        x_record_code_txt         => NULL,
                        x_direct_to_borr_flag     => l_disb_interface.direct_to_borr_flag);

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','Before insert into IGF_SL_CL_RESP_R8 - LOOP l_clrp1_id ' || l_clrp1_id || ' i ' || i);
              END IF;
              clb_rowid  := NULL;
              ln_cbth_id := NULL;

              IF NVL(l_disb_interface.send_resp_code,'X') = 'D' THEN

                    OPEN  chk_batch_id(l_disb_interface.roster_batch_id);
                    FETCH chk_batch_id INTO l_batch_id;

                    IF (chk_batch_id%NOTFOUND) THEN
                         CLOSE chk_batch_id;

                         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','Before insert into IGF_SL_CL_BATCH');
                         END IF;

                         ln_cbth_id := NULL;
                         clb_rowid  := NULL;

                         igf_sl_cl_batch_pkg.insert_row (
                                  x_rowid                     =>  clb_rowid,
                                  x_cbth_id                   =>  ln_cbth_id,
                                  x_batch_id                  =>  l_disb_interface.roster_batch_id,
                                  x_file_creation_date        =>  l_disb_interface.file_creation_date,
                                  x_file_trans_date           =>  l_disb_interface.file_trans_date ,
                                  x_file_ident_code           =>  'E005P',
                                  x_recipient_id              =>  l_disb_interface.recipient_id_txt,
                                  x_recip_non_ed_brc_id       =>  l_disb_interface.recipient_non_ed_brc_id_txt,
                                  x_source_id                 =>  l_disb_interface.source_id_txt,
                                  x_source_non_ed_brc_id      =>  l_disb_interface.source_non_ed_brc_id_txt,
                                  x_send_resp                 =>  l_disb_interface.send_resp_code,
                                  x_mode                      =>  'R',
                                  x_record_count_num          =>  NULL,
                                  x_total_net_disb_amt        =>  NULL,
                                  x_total_net_eft_amt         =>  NULL,
                                  x_total_net_non_eft_amt     =>  NULL,
                                  x_total_reissue_amt         =>  NULL,
                                  x_total_cancel_amt          =>  NULL,
                                  x_total_deficit_amt         =>  NULL,
                                  x_total_net_cancel_amt      =>  NULL,
                                  x_total_net_out_cancel_amt  =>  NULL);
                    ELSE
                        CLOSE chk_batch_id;
                    END IF;

                    IF ln_cbth_id IS NULL THEN
                          ln_cbth_id := l_batch_id.cbth_id;
                    END IF;

                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','After insert into IGF_SL_CL_BATCH ln_cbth_id  ' || ln_cbth_id);
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','Before insert into IGF_DB_CL_DISB_RESP');
                    END IF;

                    l_rost_rowid := NULL;
                    l_cdbr_id    := NULL;

                    igf_db_cl_disb_resp_pkg.insert_row (
                                   x_mode                 => 'R',
                                   x_rowid                => l_rost_rowid,
                                   x_cdbr_id              => l_cdbr_id,
                                   x_cbth_id              => ln_cbth_id,
                                   x_record_type          => l_disb_interface.record_type,
                                   x_loan_number          => l_disb_interface.loan_number_txt,
                                   x_cl_seq_number        => p_interface.cl_seq_num,
                                   x_b_last_name          => l_b_last_name,
                                   x_b_first_name         => l_b_first_name,
                                   x_b_middle_name        => l_b_middle_name,
                                   x_b_ssn                => l_b_ssn,
                                   x_b_addr_line_1        => l_b_permt_addr1,
                                   x_b_addr_line_2        => l_b_permt_addr2,
                                   x_b_city               => l_b_permt_city,
                                   x_b_state              => l_b_permt_state,
                                   x_b_zip                => l_b_permt_zip,
                                   x_b_zip_suffix         => NULL,
                                   x_b_addr_chg_date      => NULL,
                                   x_eft_auth_code        => p_interface.eft_auth_flag,
                                   x_s_last_name          => student_dtl_rec.p_last_name,
                                   x_s_first_name         => student_dtl_rec.p_first_name,
                                   x_s_middle_initial     => student_dtl_rec.p_middle_name,
                                   x_s_ssn                => SUBSTR(student_dtl_rec.p_ssn,1,9),
                                   x_school_id            => SUBSTR(p_interface.loan_number_txt,1,8),
                                   x_school_use           => l_disb_interface.school_use_txt,
                                   x_loan_per_start_date  => p_interface.loan_per_begin_date ,
                                   x_loan_per_end_date    => p_interface.loan_per_end_date ,
                                   x_cl_loan_type         => lv_cl_loan_type,
                                   x_alt_prog_type_code   => p_interface.alt_prog_type_cd ,
                                   x_lender_id            => NULL,
                                   x_lend_non_ed_brc_id   => NULL,
                                   x_lender_use           => l_disb_interface.lender_use_txt,
                                   x_borw_confirm_ind     => p_interface.borw_confirm_flag,
                                   x_tot_sched_disb       => l_disb_interface.sch_disbursement_num,
                                   x_fund_release_date    => l_disb_interface.fund_release_date,
                                   x_disb_num             => l_disb_interface.disbursement_num,
                                   x_guarantor_id         => NULL,
                                   x_guarantor_use        => l_disb_interface.guarantor_use_txt,
                                   x_guarantee_date       => l_disb_interface.guarantee_date,
                                   x_guarantee_amt        => l_disb_interface.guarantee_amt,
                                   x_gross_disb_amt       => l_disb_interface.gross_disbursement_amt,
                                   x_fee_1                => l_disb_interface.origination_fee_amt,
                                   x_fee_2                => l_disb_interface.guarantee_fee_amt,
                                   x_net_disb_amt         => lv_disb_net_amt,
                                   x_fund_dist_mthd       => l_disb_interface.fund_dist_mthd_type,
                                   x_check_number         => l_disb_interface.check_number_txt,
                                   x_late_disb_ind        => l_disb_interface.late_disbursement_flag,
                                   x_prev_reported_ind    => l_disb_interface.prev_reported_flag,
                                   x_err_code1            => l_disb_interface.err_mesg_1_cd,
                                   x_err_code2            => l_disb_interface.err_mesg_2_cd,
                                   x_err_code3            => l_disb_interface.err_mesg_3_cd,
                                   x_err_code4            => l_disb_interface.err_mesg_4_cd,
                                   x_err_code5            => l_disb_interface.err_mesg_5_cd,
                                   x_fee_paid_2           => l_disb_interface.guarantee_fees_paid_amt,
                                   x_lender_name          => l_disb_interface.lender_name,
                                   x_net_cancel_amt       => l_disb_interface.net_cancel_amt,
                                   x_duns_lender_id       => NULL,
                                   x_duns_guarnt_id       => NULL,
                                   x_hold_rel_ind         => l_disb_interface.disbursement_hld_release_flag,
                                   x_pnote_code           => SUBSTR(l_disb_interface.pnote_code,1,2),
                                   x_pnote_status_date    => l_disb_interface.pnote_status_date ,
                                   x_fee_paid_1           => l_disb_interface.origination_fees_paid_amt,
                                   x_netted_cancel_amt    => l_disb_interface.netted_cancel_amt,
                                   x_outstd_cancel_amt    => l_disb_interface.outstd_cancel_amt,
                                   x_sch_non_ed_brc_id    => p_interface.source_non_ed_brc_id_txt,
                                   x_status               => 'Y',
                                   x_esign_src_typ_cd     => NULL,
                                   x_direct_to_borr_flag   => l_disb_interface.direct_to_borr_flag);
              END IF;
          END LOOP;
     ELSE
          --
          -- Update Disbursement Related Information
          --
          FOR l_disb_interface IN c_disb_interface( p_interface.ci_alternate_code,
                                                    p_interface.person_number,
                                                    p_interface.award_number_txt,
                                                    p_interface.loan_number_txt
                                                  ) LOOP
              i := i+1;

              lv_disb_net_amt := NVL(l_disb_interface.gross_disbursement_amt,0) - NVL(l_disb_interface.guarantee_fee_amt,0) - NVL(l_disb_interface.origination_fee_amt,0)
                     + NVL(l_disb_interface.guarantee_fees_paid_amt,0) + NVL(l_disb_interface.origination_fees_paid_amt,0);

              OPEN  c_disb_det(l_disb_interface.disbursement_num);
              FETCH c_disb_det INTO l_disb_det;
              CLOSE c_disb_det;

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','Before Update IGF_AW_AWD_DISB');
              END IF;

              igf_aw_awd_disb_pkg.update_row (
                               x_mode                              => 'R',
                               x_rowid                             => l_disb_det.rowid,
                               x_award_id                          => l_disb_det.award_id,
                               x_disb_num                          => l_disb_det.disb_num,
                               x_tp_cal_type                       => l_disb_det.tp_cal_type,
                               x_tp_sequence_number                => l_disb_det.tp_sequence_number   ,
                               x_disb_gross_amt                    => l_disb_det.disb_gross_amt,
                               x_fee_1                             => l_disb_interface.origination_fee_amt,
                               x_fee_2                             => l_disb_interface.guarantee_fee_amt,
                               x_disb_net_amt                      => lv_disb_net_amt,
                               x_disb_date                         => l_disb_det.disb_date,
                               x_trans_type                        => l_disb_det.trans_type,
                               x_elig_status                       => l_disb_det.elig_status,
                               x_elig_status_date                  => l_disb_det.elig_status_date,
                               x_affirm_flag                       => l_disb_det.affirm_flag,
                               x_hold_rel_ind                      => l_disb_interface.disbursement_hld_release_flag,
                               x_manual_hold_ind                   => l_disb_det.manual_hold_ind,
                               x_disb_status                       => l_disb_interface.disbursement_status_code,
                               x_disb_status_date                  => l_disb_interface.disbursement_status_date,
                               x_late_disb_ind                     => l_disb_interface.late_disbursement_flag,
                               x_fund_dist_mthd                    => l_disb_interface.fund_dist_mthd_type,
                               x_prev_reported_ind                 => l_disb_interface.prev_reported_flag,
                               x_fund_release_date                 => l_disb_interface.fund_release_date,
                               x_fund_status                       => l_disb_interface.fund_status_code,
                               x_fund_status_date                  => l_disb_interface.fund_status_date,
                               x_fee_paid_1                        => l_disb_interface.origination_fees_paid_amt,
                               x_fee_paid_2                        => l_disb_interface.guarantee_fees_paid_amt,
                               x_cheque_number                     => l_disb_interface.check_number_txt,
                               x_ld_cal_type                       => l_disb_det.ld_cal_type,
                               x_ld_sequence_number                => l_disb_det.ld_sequence_number,
                               x_disb_accepted_amt                 => l_disb_det.disb_accepted_amt,
                               x_disb_paid_amt                     => l_disb_det.disb_paid_amt,
                               x_rvsn_id                           => l_disb_det.rvsn_id,
                               x_int_rebate_amt                    => l_disb_det.int_rebate_amt,
                               x_force_disb                        => l_disb_det.force_disb,
                               x_min_credit_pts                    => l_disb_det.min_credit_pts,
                               x_disb_exp_dt                       => l_disb_det.disb_exp_dt,
                               x_verf_enfr_dt                      => l_disb_det.verf_enfr_dt,
                               x_fee_class                         => l_disb_det.fee_class,
                               x_show_on_bill                      => l_disb_det.show_on_bill,
                               x_attendance_type_code              => l_disb_det.attendance_type_code,
                               x_base_attendance_type_code         => l_disb_det.base_attendance_type_code,
                               x_change_type_code                  => l_disb_det.change_type_code,
                               x_fund_return_mthd_code             => l_disb_det.fund_return_mthd_code,
                               x_payment_prd_st_date               => l_disb_det.payment_prd_st_date,
                               x_direct_to_borr_flag               => l_disb_interface.direct_to_borr_flag
                               );

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','After insert into IGF_SL_CL_RESP_R8 - LOOP');
              END IF;
          END LOOP;
     END IF;

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','Before insert into IGF_SL_AWD_DISB_LOC');
     END IF;

     DECLARE

        lv_row_id  VARCHAR2(25);

        CURSOR c_loc_cur IS
           SELECT *
           FROM   igf_sl_awd_disb_loc
           WHERE  award_id = p_award_id;

        CURSOR c_awd_cur IS
           SELECT *
           FROM   igf_aw_awd_disb
           WHERE  award_id = p_award_id;

     BEGIN

        FOR tbh_rec IN c_loc_cur LOOP
            igf_sl_awd_disb_loc_pkg.delete_row (tbh_rec.row_id);
        END LOOP;

        FOR tbh_rec IN c_awd_cur LOOP

          lv_row_id  := NULL;

          igf_sl_awd_disb_loc_pkg.insert_row (
            x_mode                              => 'R',
            x_rowid                             => lv_row_id,
            x_award_id                          => tbh_rec.award_id,
            x_disb_num                          => tbh_rec.disb_num,
            x_disb_gross_amt                    => tbh_rec.disb_accepted_amt,
            x_fee_1                             => tbh_rec.fee_1,
            x_fee_2                             => tbh_rec.fee_2,
            x_disb_net_amt                      => tbh_rec.disb_net_amt,
            x_disb_date                         => tbh_rec.disb_date,
            x_hold_rel_ind                      => tbh_rec.hold_rel_ind,
            x_fee_paid_1                        => tbh_rec.fee_paid_1,
            x_fee_paid_2                        => tbh_rec.fee_paid_2);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug',' After insert into IGF_SL_AWD_DISB_LOC');
          END IF;

        END LOOP;

     END;

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.debug','DML Complete');
     END IF;

EXCEPTION
WHEN OTHERS THEN

   IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_imp_pkg.insert_records.exception','Exception ' || SQLERRM);
   END IF;
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','IGF_SL_CL_LI_IMP_PKG.INSERT_RECORDS');

   RAISE IMPORT_ERROR;

END insert_records;



PROCEDURE run (  errbuf         IN OUT NOCOPY VARCHAR2,
                 retcode        IN OUT NOCOPY NUMBER,
                 p_awd_yr       IN VARCHAR2,
                 p_batch_id     IN NUMBER,
                 p_delete_flag  IN VARCHAR2
               )
IS
--
--    Created By : gmuralid
--    Created On : 24-JUN-2003
--    Purpose : This procedure is the main procedure invoked via concurrent program to import legacy data.
--    Known limitations, enhancements or remarks :
--    Change History :
--    Who             When            What
--    tsailaja		  15/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
--    bvisvana   07-July-2005   Bug # 4008991 - IGF_GR_BATCH_DOES_NOT_EXIST replaced by IGF_SL_GR_BATCH_DOES_NO_EXIST
--    (reverse chronological order - newest change first
--


     p_d_status               BOOLEAN;
     p_l_status               BOOLEAN;
     p_status                 BOOLEAN;
     lb_isir_flag             BOOLEAN := TRUE;
     g_error_flag             BOOLEAN := FALSE;
     lb_open_flag             BOOLEAN := FALSE;

     l_total_record_cnt       NUMBER;
     lb_base_id               NUMBER;
     g_error_record_cnt       NUMBER  := 0;
     l_success_record_cnt     NUMBER  := 0;

     result1                  VARCHAR2(1);
     result2                  VARCHAR2(1);
     l_award_year_status      VARCHAR2(80);
     l_batch_desc             VARCHAR2(80);
     l_chk_profile            VARCHAR2(1);
     l_chk_batch              VARCHAR2(1);

     l_cal_type               igf_ap_fa_base_rec_all.ci_cal_type%TYPE;
     l_seq_number             igf_ap_fa_base_rec_all.ci_sequence_number%TYPE;
     l_award_id               igf_aw_award_all.award_id%TYPE;
     l_fed_fund_cd            igf_aw_fund_cat.fed_fund_code%TYPE;
     lv_person_id             igs_pe_hz_parties.party_id%TYPE;
     lv_base_id               igf_ap_fa_base_rec_all.base_id%TYPE;

     l_interface              c_interface%ROWTYPE;
     l_disb_interface         c_disb_interface%ROWTYPE;

     CURSOR c_get_batch_desc(cp_batch_num NUMBER)
     IS
     SELECT batch_desc
     FROM   igf_ap_li_bat_ints
     WHERE  batch_num = cp_batch_num;

     l_get_batch_desc c_get_batch_desc%ROWTYPE;

     CURSOR c_get_alternate_code(cp_cal_type VARCHAR2,
                                 cp_seq_number NUMBER)
     IS
     SELECT alternate_code
     FROM   igs_ca_inst
     WHERE  cal_type = cp_cal_type
     AND    sequence_number = cp_seq_number;

     l_get_alternate_code  c_get_alternate_code%ROWTYPE;


     CURSOR c_award_det(cp_cal_type VARCHAR2,
                        cp_seq_number NUMBER)
     IS
     SELECT batch_year,
            award_year_status_code,
            sys_award_year
     FROM   igf_ap_batch_aw_map_v
     WHERE  ci_cal_type        = cp_cal_type
     AND    ci_sequence_number = cp_seq_number;

     l_award_det c_award_det%ROWTYPE;


     CURSOR c_act_isir(cp_base_id NUMBER)
     IS
     SELECT    1
     FROM      igf_ap_isir_matched   isir
     WHERE     isir.base_id          = cp_base_id
     AND       isir.active_isir      = 'Y';

     l_act_isir c_act_isir%ROWTYPE;


     CURSOR c_chk_loan_exist (cp_award_id NUMBER)
     IS
     SELECT
     rowid row_id,
     loan_id,
     award_id,
     loan_number,
     legacy_record_flag
     FROM
     igf_sl_loans_all
     WHERE
     award_id = cp_award_id;

     l_chk_loan_exist c_chk_loan_exist%ROWTYPE;

     CURSOR c_chk_loan_number (cp_loan_number VARCHAR2)
     IS
     SELECT
     rowid row_id,
     loan_id,
     award_id,
     loan_number,
     legacy_record_flag
     FROM
     igf_sl_loans_all
     WHERE
     loan_number = cp_loan_number;

     l_chk_loan_number c_chk_loan_number%ROWTYPE;

     CURSOR c_disb_det(cp_award_id NUMBER,
                       cp_disb_num NUMBER)
     IS
     SELECT 1
     FROM   igf_aw_awd_disb_all adisb
     WHERE  adisb.award_id   =  cp_award_id
     AND    adisb.disb_num   =  cp_disb_num;

     l_disb_det c_disb_det%ROWTYPE;

BEGIN
	 igf_aw_gen.set_org_id(NULL);
     errbuf             :=  NULL;
     retcode            :=  0;
     g_error            := '           ';
     l_chk_profile      := 'N';
     l_chk_batch        := 'Y';
     l_cal_type         :=  LTRIM(RTRIM(SUBSTR(p_awd_yr,1,10)));
     l_seq_number       :=  TO_NUMBER(SUBSTR(p_awd_yr,11));

     --
     -- Get batch description and display it
     --
     OPEN  c_get_batch_desc(p_batch_id);
     FETCH c_get_batch_desc INTO l_get_batch_desc;
     CLOSE c_get_batch_desc;

     l_batch_desc := p_batch_id ||' - ' || l_get_batch_desc.batch_desc ;
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','l_batch_desc ' || l_batch_desc);
     END IF;

     l_get_alternate_code := NULL;

     OPEN  c_get_alternate_code(l_cal_type,l_seq_number);
     FETCH c_get_alternate_code INTO l_get_alternate_code;
     CLOSE c_get_alternate_code;

     log_parameters( l_get_alternate_code.alternate_code,p_batch_id,igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_delete_flag));

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','l_cal_type:'||l_cal_type ||' l_seq_number:'||l_seq_number);
     END IF;

     l_chk_profile      :=  igf_ap_gen.check_profile;

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','l_chk_profile ' || l_chk_profile);
     END IF;


     IF l_chk_profile = 'N' THEN
          fnd_message.set_name('IGF','IGF_AP_LGCY_PROC_NOT_RUN');
          fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
          RETURN;
     END IF;

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','l_get_alternate_code.alternate_code ' || l_get_alternate_code.alternate_code);
     END IF;

     IF (l_get_alternate_code.alternate_code IS NULL) THEN
        fnd_message.set_name('IGF','IGF_SL_NO_CALENDAR');
        fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
        RETURN;
     END IF;

     l_chk_batch := igf_ap_gen.check_batch(p_batch_id,'LOANS');
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','l_chk_batch ' || l_chk_batch);
     END IF;

     IF l_chk_batch = 'N' THEN
           -- Bug # 4008991
           fnd_message.set_name('IGF','IGF_SL_GR_BATCH_DOES_NO_EXIST');
           fnd_message.set_token('BATCH_ID',p_batch_id);
           fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
           RETURN;
     END IF;


     OPEN  c_award_det(l_cal_type,l_seq_number);
     FETCH c_award_det INTO l_award_det;
     IF c_award_det%NOTFOUND THEN
           fnd_message.set_name('IGF','IGF_AP_AWD_YR_NOT_FOUND');
           fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
           fnd_file.new_line(fnd_file.log,1);
           CLOSE c_award_det;
           RETURN;
     ELSE
       CLOSE c_award_det;
     END IF;

     l_award_year_status := l_award_det.award_year_status_code;
     g_sys_award_year    := l_award_det.sys_award_year;

     fnd_file.put_line(fnd_file.log,RPAD(g_award_year_status_desc,40)|| ' : '
                                                                || igf_aw_gen.lookup_desc('IGF_AWARD_YEAR_STATUS',l_award_year_status));
     fnd_file.new_line(fnd_file.log,1);
     fnd_file.put_line(fnd_file.log, '--------------------------------------------------------');

     IF l_award_det.award_year_status_code NOT IN ('LD','O') THEN
          fnd_message.set_name('IGF','IGF_AP_LG_INVALID_STAT');
          fnd_message.set_token('AWARD_STATUS',igf_aw_gen.lookup_desc('IGF_AWARD_YEAR_STATUS',l_award_year_status));
          fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
          fnd_file.new_line(fnd_file.log,1);
          RETURN;
     END IF;

     IF (l_award_year_status = 'O') THEN
         lb_open_flag := TRUE;
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','lb_open_flag : TRUE');
         END IF;
     ELSE
         lb_open_flag := FALSE;
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','lb_open_flag : FALSE');
         END IF;
     END IF;

     FOR l_interface IN c_interface(p_batch_id,l_get_alternate_code.alternate_code,'U','R') LOOP

          BEGIN

              SAVEPOINT sp1;

              fnd_file.new_line(fnd_file.log,1);
              fnd_file.put_line(fnd_file.log,g_processing    ||
                                             ' '             ||
                                             g_person_number ||
                                             ' '             ||
                                             l_interface.person_number);
              --
              -- Check if person exists in OSS
              --
              igf_ap_gen.check_person(l_interface.person_number,l_cal_type,l_seq_number,lv_person_id,lv_base_id);

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','lv_person_id ' || lv_person_id||' lv_base_id ' || lv_base_id);
              END IF;

              IF lv_person_id IS NULL THEN
                  fnd_message.set_name('IGF','IGF_SL_LI_PERSON_NOT_FND');
                  fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
                  fnd_file.new_line(fnd_file.log,1);
                  g_error_flag := TRUE;
              ELSE
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','Pesron Number check passed');
                  END IF;
                  --
                  -- Check if base record present
                  --
                  IF lv_base_id IS NULL THEN
                      fnd_message.set_name('IGF','IGF_AP_FABASE_NOT_FOUND');
                      fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
                      fnd_file.new_line(fnd_file.log,1);
                      g_error_flag := TRUE;

                  ELSE
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','Base record check passed');
                      END IF;
                      --
                      -- Check if corresponding award is present in the awards table
                      --
                      fnd_file.put_line(fnd_file.log, g_processing ||
                                                      ' '          ||
                                                      g_loan_record||
                                                      ' '          ||
                                                      l_interface.loan_number_txt);

                      OPEN c_get_award(lv_base_id,l_interface.award_number_txt);
                      FETCH c_get_award INTO l_get_award;
                      IF (c_get_award%NOTFOUND) THEN
                          CLOSE c_get_award;
                          fnd_message.set_name('IGF','IGF_SL_CL_LI_NO_AW_REF');
                          fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
                          g_error_flag := TRUE;
                      ELSE
                          CLOSE c_get_award;

                          l_award_id  := l_get_award.award_id;

                          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','Award ID ' || l_award_id);
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','Award Reference check passed');
                          END IF;

                          lb_isir_flag := TRUE;

                          IF ( lb_open_flag = TRUE ) THEN
                              --
                              -- Check for active isir only if open award year
                              --
                               OPEN  c_act_isir(lv_base_id);
                               FETCH c_act_isir INTO l_act_isir;

                               IF (c_act_isir%NOTFOUND) THEN
                                  CLOSE c_act_isir;
                                  fnd_message.set_name('IGF','IGF_AP_NO_ACTIVE_ISIR');
                                  fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
                                  lb_isir_flag := FALSE;
                                  g_error_flag := TRUE;
                               ELSE
                                  CLOSE c_act_isir;
                                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','Active ISIR for Open Award Year check passed');
                                  END IF;
                               END IF; -- c_act_isir IF
                          END IF; -- lb_open_flag IF

                          IF (lb_isir_flag = TRUE) THEN

                                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','Loan status and active isir check passed');
                                 END IF;
                                 --
                                 -- Check for the fed fund code and based on this check the person borrower relationship
                                 --
                                 l_fed_fund_cd := l_get_award.fed_fund_code;
                                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','Fed Fund Code ' || l_fed_fund_cd);
                                 END IF;

                                 IF (l_fed_fund_cd IS NULL) OR (l_fed_fund_cd NOT IN ('FLP','FLS','FLU','ALT','GPLUSFL'))
                                 THEN
                                      fnd_message.set_name('IGF','IGF_SL_CL_INV_FED_FND_CD');
                                      fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
                                      g_error_flag    := TRUE;
                                 ELSE
                                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','Person Borrower relationship check passed');
                                      END IF;


                                      validate_loan_orig_int(l_interface,
                                                             l_award_id,
                                                             p_status,
                                                             l_cal_type,
                                                             l_seq_number,
                                                             lb_open_flag,
                                                             l_fed_fund_cd);

                                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','After calling validate_loan_orig_int');
                                      END IF;
                                 END IF; -- Fund Code IF


                                 IF p_status = FALSE OR g_error_flag THEN
                                         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','Validation of interface record failed');
                                         END IF;
                                         g_error_flag := TRUE;
                                         write_logfile('O');
                                 ELSE
                                        OPEN  c_disb_interface(l_interface.ci_alternate_code,l_interface.person_number,l_interface.award_number_txt,l_interface.loan_number_txt);
                                        FETCH c_disb_interface INTO l_disb_interface;

                                        IF (c_disb_interface%NOTFOUND) THEN
                                            CLOSE c_disb_interface;
                                            p_d_status   := FALSE;
                                            g_error_flag := TRUE;
                                            fnd_message.set_name('IGF','IGF_SL_CL_NO_DIS_REC');
                                            fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
                                        ELSE
                                            CLOSE c_disb_interface;
                                            l_disb_interface := NULL;
                                            p_d_status := TRUE;
                                            p_l_status := TRUE;

                                            FOR l_disb_interface IN
                                                  c_disb_interface(l_interface.ci_alternate_code,
                                                                   l_interface.person_number,
                                                                   l_interface.award_number_txt,
                                                                   l_interface.loan_number_txt)
                                            LOOP

                                                  fnd_file.put_line(fnd_file.log,LPAD(' ',11)
                                                  ||g_processing
                                                  ||' '
                                                  ||g_loan_disb
                                                  ||' '
                                                  ||l_disb_interface.disbursement_num);

                                                  OPEN c_disb_det(l_award_id,l_disb_interface.disbursement_num);
                                                  FETCH c_disb_det INTO l_disb_det;

                                                  IF (c_disb_det%NOTFOUND) THEN
                                                       CLOSE c_disb_det;
                                                       g_error_flag := TRUE;
                                                       fnd_message.set_name('IGF','IGF_SL_CL_DISB_REC_NO_EXIST');
                                                       fnd_message.set_token('DISB_NUM',l_disb_interface.disbursement_num);
                                                       fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
                                                       p_d_status := FALSE;
                                                  ELSE
                                                       CLOSE c_disb_det;
                                                       --
                                                       -- Validate disb
                                                       --
                                                       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                                                         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','Before calling validate_loan_disb');
                                                       END IF;
                                                       validate_loan_disb( l_disb_interface,l_award_id,p_d_status);
                                                       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                                                         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','After calling validate_loan_disb');
                                                       END IF;

                                                  END IF;

                                                  IF p_d_status  = FALSE THEN
                                                     p_l_status   := FALSE;
                                                     g_error_flag := TRUE;
                                                     write_logfile('D');
                                                  END IF;

                                            END LOOP;

                                            IF p_l_status = FALSE THEN
                                                    p_d_status := FALSE;
                                            END IF;

                                            IF p_d_status = FALSE THEN
                                                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                                                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','Validation of Disbursement interface record failed');
                                                    END IF;
                                                    g_error_flag := TRUE;
                                            ELSIF p_d_status = TRUE AND p_status = TRUE THEN

                                                    OPEN c_chk_loan_exist(l_award_id);
                                                    FETCH c_chk_loan_exist INTO l_chk_loan_exist;
                                                    --
                                                    -- If interface record does not exist log message
                                                    --
                                                    IF  (c_chk_loan_exist%NOTFOUND) THEN

                                                       CLOSE c_chk_loan_exist;

                                                       IF (NVL(l_interface.import_record_type,'X') = 'U' ) THEN
                                                            fnd_message.set_name('IGF','IGF_AP_ORIG_REC_NOT_FOUND');
                                                            fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
                                                            g_error_flag := TRUE;
                                                       END IF;

                                                    ELSIF (c_chk_loan_exist%FOUND) THEN

                                                       CLOSE c_chk_loan_exist;

                                                       IF (NVL(l_interface.import_record_type,'X') <> 'U' ) THEN
                                                                fnd_message.set_name('IGF','IGF_SL_CL_RECORD_EXIST');
                                                                fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
                                                                g_error_flag := TRUE;
                                                       END IF;

                                                       IF (NVL(l_chk_loan_exist.legacy_record_flag,'N') = 'N') THEN
                                                            fnd_message.set_name('IGF','IGF_SL_CL_UPD_OPEN');
                                                            fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
                                                            g_error_flag := TRUE;
                                                       END IF;

                                                       IF (NVL(l_interface.import_record_type,'X') = 'U' ) THEN
                                                           IF l_chk_loan_exist.loan_number <> l_interface.loan_number_txt THEN
                                                                   fnd_message.set_name('IGF','IGF_SL_LI_LOAN_NUM_MISMTCH');
                                                                   fnd_message.set_token('SYS_LOAN_NUM',l_chk_loan_exist.loan_number);
                                                                   fnd_message.set_token('INT_LOAN_NUM',l_interface.loan_number_txt);
                                                                   fnd_message.set_token('AWARD_ID',l_award_id);
                                                                   fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
                                                                   g_error_flag := TRUE;
                                                           END IF;
                                                       END IF;

                                                    END IF;

                                                    OPEN  c_chk_loan_number(l_interface.loan_number_txt);
                                                    FETCH c_chk_loan_number INTO l_chk_loan_number;
                                                    CLOSE c_chk_loan_number;

                                                    IF NVL(l_chk_loan_number.award_id,l_award_id) <> l_award_id THEN
                                                          fnd_message.set_name('IGF','IGF_SL_DUP_LOAN');
                                                          fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
                                                          g_error_flag := TRUE;
                                                    END IF;

                                                    IF NOT g_error_flag AND l_chk_loan_exist.loan_id IS NOT NULL THEN
                                                      delete_records(l_chk_loan_exist.row_id,
                                                                     l_chk_loan_exist.loan_id,
                                                                     l_chk_loan_exist.loan_number);
                                                    END IF;

                                                    IF NOT g_error_flag THEN
                                                         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                                                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','Record to be updated deleted successfully');
                                                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','l_award_id    ' || l_award_id);
                                                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','l_fed_fund_cd ' || l_fed_fund_cd);
                                                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','lv_person_id  ' || lv_person_id);
                                                         END IF;


                                                         insert_records(l_interface,
                                                                        l_award_id,
                                                                        l_fed_fund_cd,
                                                                        lv_person_id);
                                                    END IF;
                                            END IF; -- PD STATUS IF
                                        END IF; -- DISBURSEMENT RECORDS FOUND IF
                                 END IF; -- P STATUS FLAG IF
                          END IF; -- ISIR PASS IF
                      END IF; -- AWARD REF IF
                  END IF; -- BASE ID IF
              END IF; -- PERSON ID IF

          EXCEPTION

          WHEN IMPORT_ERROR THEN
               g_error_flag  := TRUE;
               fnd_message.set_name('IGF','IGF_SL_CL_LI_UPD_FLD');
               fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
               fnd_file.new_line(fnd_file.log,1);
               ROLLBACK TO sp1;

          WHEN OTHERS THEN
               RAISE;
          END;

          BEGIN  -- Block for updating Interface Record

               IF    g_error_flag = TRUE  OR
                     p_status     = FALSE OR
                     p_d_status   = FALSE

                     THEN
                     g_error_flag := FALSE;
                     --
                     -- update the legacy interface table column import_status to 'E'
                     --
                     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','Before update of interface table : status E');
                     END IF;
                     UPDATE
                     igf_sl_li_orig_ints
                     SET
                     import_status_type     = 'E',
                     last_update_date       = SYSDATE,
                     last_update_login      = fnd_global.login_id,
                     request_id             = fnd_global.conc_request_id,
                     program_id             = fnd_global.conc_program_id,
                     program_application_id = fnd_global.prog_appl_id,
                     program_update_date    = SYSDATE
                     WHERE
                     ROWID = l_interface.ROWID;

                     g_error_record_cnt := g_error_record_cnt + 1;
                     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','After update of interface table : status E');
                     END IF;
                     fnd_file.new_line(fnd_file.log,1);
                     fnd_message.set_name('IGF','IGF_SL_LI_SKIPPING_AWD');
                     fnd_file.put_line(fnd_file.log,fnd_message.get);
                     fnd_file.new_line(fnd_file.log,1);
               ELSE

                    IF p_delete_flag = 'Y' THEN

                         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','Before deleting disb interface table record');
                         END IF;

                         DELETE
                         FROM
                         igf_sl_li_org_disb_ints
                         WHERE
                         ci_alternate_code = l_interface.ci_alternate_code AND
                         person_number     = l_interface.person_number     AND
                         award_number_txt  = l_interface.award_number_txt;

                         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','Before deleting orig interface table record');
                         END IF;

                         DELETE
                         FROM
                         igf_sl_li_orig_ints
                         WHERE
                         ROWID = l_interface.ROWID;

                         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','After deleting orig interface table record');
                         END IF;

                    ELSE
                         --
                         -- update the legacy interface table column import_status to 'I'
                         --

                         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','Before update of interface table : status I');
                         END IF;

                         UPDATE
                         igf_sl_li_orig_ints
                         SET
                         import_status_type     = 'I',
                         last_update_date       = SYSDATE,
                         last_update_login      = fnd_global.login_id,
                         request_id             = fnd_global.conc_request_id,
                         program_id             = fnd_global.conc_program_id,
                         program_application_id = fnd_global.prog_appl_id,
                         program_update_date    = SYSDATE
                         WHERE
                         ROWID = l_interface.ROWID;

                         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','After update of interface table : status I');
                         END IF;

                    END IF;

                    l_success_record_cnt := l_success_record_cnt + 1;
                    fnd_message.set_name('IGF','IGF_SL_LI_IMP_SUCCES');
                    fnd_file.put_line(fnd_file.log, fnd_message.get);
                    fnd_file.new_line(fnd_file.log,1);

               END IF;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_cl_imp_pkg.run.debug','Before COMMIT');
               END IF;

               COMMIT;
               fnd_file.new_line(fnd_file.log,1);
          END;


     END LOOP;

     IF l_success_record_cnt = 0 AND g_error_record_cnt = 0 THEN
       fnd_message.set_name('IGF','IGF_SL_CL_LI_NO_RECORDS');
       fnd_message.set_token('AID_YR', l_get_alternate_code.alternate_code);
       fnd_message.set_token('BATCH_ID',p_batch_id);
       fnd_file.put_line(fnd_file.log,RPAD(g_error,11) || fnd_message.get);
       RETURN;
     END IF;

     l_total_record_cnt := l_success_record_cnt + g_error_record_cnt;
     fnd_file.put_line(fnd_file.output,' ' );
     fnd_file.put_line(fnd_file.output, RPAD('-',50,'-'));
     fnd_file.put_line(fnd_file.output,' ' );
     fnd_file.put_line(fnd_file.output, RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_PROCESSED'), 40)  || ' : ' || l_total_record_cnt);
     fnd_file.put_line(fnd_file.output, RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_SUCCESSFUL'), 40) || ' : ' || l_success_record_cnt);
     fnd_file.put_line(fnd_file.output, RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_REJECTED'), 40)   || ' : ' || g_error_record_cnt);
     fnd_file.put_line(fnd_file.output,' ' );
     fnd_file.put_line(fnd_file.output, RPAD('-',50,'-'));
     fnd_file.put_line(fnd_file.output,' ' );


EXCEPTION

     WHEN others THEN
     ROLLBACK;

     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_cl_imp_pkg.run.exception','Exception'|| SQLERRM);
     END IF;
     fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','IGF_SL_CL_LI_IMP_PKG.RUN');
     fnd_file.put_line(fnd_file.log,fnd_message.get);
     retcode := 2;
     errbuf  := fnd_message.get;
     igs_ge_msg_stack.conc_exception_hndl;
 END run;

END IGF_SL_CL_LI_IMP_PKG;

/
