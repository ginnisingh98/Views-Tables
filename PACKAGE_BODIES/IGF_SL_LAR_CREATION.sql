--------------------------------------------------------
--  DDL for Package Body IGF_SL_LAR_CREATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_LAR_CREATION" AS
/* $Header: IGFSL01B.pls 120.14 2006/08/07 13:10:15 azmohamm ship $ */

/*
--
------------------------------------------------------------------------
--   Created By       :    mesriniv
--   Date Created By  :    2000/11/13
--   Purpose          :    To Insert Loan Records into IGF_SL_LOANS
------------------------------------------------------------------------
-- Who          When           What
------------------------------------------------------------------------------------------------------------
   azmohamm     03-AUG-2006    FA163
                               TBH Impact changes done in create_loan_records() and update_loan_rec()
------------------------------------------------------------------------------------------------------------
   bvisvana     10-Apr-2006    Build FA161. Bug 5006583
                               TBH Impact change done in insert_lor_dl_records().
--------------------------------------------------------------------------------------------------------------
   museshad     20-Feb-2005   Bug 5031795 - SQL Repository issue.
                              In create_loan_records(), modified cursor cur_count_fed_code
                              for better performance.
---------------------------------------------------------------------------------------------------------------
   bvisvana     20-Sep-2005   Bug # 4127532 - For ALT Loan, if borrower and Student are equal then
                              p_default_status is set to s_default_status during the loan creation
---------------------------------------------------------------------------------------------------------------
   bvisvana     12-Sep-2005   SBCC Bug # 4575843
                              Before creating loan record, check whether the award accepted amount is in whole numbers.
--------------------------------------------------------------------------------------------
   bvisvana    25-Aug-2005    Bug # 4568942. Grade Level not matching with enrollment data.
                              (Wrong argument type) g_fund_id is replaced with (correct argument type)
                              g_adplans_id while calling the Class standing wrapper igf_aw_packng_subfns.get_class_stnd
--------------------------------------------------------------------------------------------
   bvisvana     18-Aug-2005    Bug # 4464629 - Removed the global variable gv_dl_version.
                               This is not used anywhere and this is causing unexpected behaviour.
---------------------------------------------------------------------------------------------------------------
   mnade        6/3/2005       FA 157 - Auto Borrower population for PLUS loans, Cosigner Data for ALT Loans.
                               Student default borrower for ALT Loans.
   pssahni     30-Dec-2004    Bug 4087865 Application form code must be populated
--------------------------------------------------------------------------
   mnade        29-Dec-2004    Bug 4085937
                               Call get entity ids Only for Full Participant
   sjadhav      25-Oct-2004    Bug 3416863 FA 149 Build Changes
------------------------------------------------------------------------
   brajendr   12-Oct-2004      Bug 3732665 ISIR Enhacements
                               Modified the Payment ISIR reference

   ugummall   23-OCT-2003      Bug 3102439. FA 126 - Multiple FA Offices.
                               In constructing loan_number for Direct Loan, School ID is derived from the
                               student's associated Org. For this purpose, base_id(as extra parameter) is
                               passed to this function.
                               Similarly, OPE ID and School Non Ed Brc ID are also derived for Common Line Loan.
--veramach     16-OCT-2003     FA124 Build remove ISIR requirement for awarding(bug # 3108506)
--                             Added code for checking loan limits in insert_loan_records
-- bkkumar     06-oct-2003     Bug 3104228 Impact of adding the relationship_cd
                               in igf_sl_lor_all table and obsoleting
                               BORW_LENDER_ID,
                               DUNS_BORW_LENDER_ID,
                               GUARANTOR_ID,
                               DUNS_GUARNT_ID,
                               LENDER_ID, DUNS_LENDER_ID
                               LEND_NON_ED_BRC_ID, RECIPIENT_ID
                               RECIPIENT_TYPE,DUNS_RECIP_ID
                               RECIP_NON_ED_BRC_ID columns
                               Also the relationship code is now picked up from the
                               pick_Setup routine.
-- bkkumar     29-sep-2003     Bug 3104228 . FA 122 Loans Enhancements
                               In "insert_lor_cl_records" procedure
                               Derivation of the fields
                               REQ_SERIAL_LOAN_CODE,
                               PNOTE_DELIVERY_CODE,
                               BORW_INTEREST_IND,
                               BORW_LENDER_ID,
                               DUNS_BORW_LENDER_ID,  -- FIELD OBSOLETED
                               GUARANTOR_ID,
                               DUNS_GUARNT_ID,  --  FIELD OBSOLETED
                               PRC_TYPE_CODE,
                               LENDER_ID,
                               DUNS_LENDER_ID,  -- FIELD OBSOLETED
                               LEND_NON_ED_BRC_ID,
                               RECIPIENT_ID,
                               RECIPIENT_TYPE,
                               DUNS_RECIP_ID,   --  FIELD  OBSOLETED
                               RECIP_NON_ED_BRC_ID,
                               is now done from the FFELP loan Setup.
                               Added the common framework logging messages.

-- rasahoo     02-Sep-2003     Replaced igf_ap_fa_base_h.class_standing%TYPE with
--                             igs_pr_css_class_std_v.class_standing%TYPE and
--                             igf_ap_fa_base_h.enrl_program_type%TYPE with igs_ps_ver_all.course_type%TYPE.
-- gmuralid     3-Juyl-2003    Bug 2995944 - Legacy Part 3 - FFELP Import
--                             Added legacy record flag as parameter to
--                             igf_sl_loans_pkg
------------------------------------------------------------------------
-- sjadhav      28-Mar-2003    Bug 2863960
--                             Corrected message token for
--                             IGF_AP_NO_GRADE_LEVEL to PERSON_NUMBER
------------------------------------------------------------------------
-- masehgal     10-Oct-2002    # 2591960    Integration Enhancements
--                             Validation on a FRESHMAN ( never attended
--                             college or did )
--                             Sepearated dl/cl code derivation from
--                             return entities
--                             Created separate procedure to obtain
--                             those
------------------------------------------------------------------------
-- sjadhav      Bug 2415013    Default Enrollment Code to Full Time
------------------------------------------------------------------------
-- sjadhav      26-Feb-2002    Bug 2240762
--                             Removed references to cur_tp_dates
--                             Added two functions to get Loan Start Date
--                             and Loan End Date
--                             Added a check to see if the SSN is already
--                             used in creation of Loan Number
------------------------------------------------------------------------
-- sjadhav      24-jul-2001    Bug ID  : 1818617
--                             added parameter p_get_recent_info
------------------------------------------------------------------------
-- adhawan      15-feb-2002    Bug Id : 2216956 added columns
--                             elec_mpn_ind,
--                             borr_sign_in
--                             stud_sign_ind
--                             borr_credit_auth_code
----------------------------------------------------------------------- */
--

-- FA 134

-- FA 134

award_rec               igf_aw_award_v%ROWTYPE;
dl_setup_rec            igf_sl_dl_setup_all%ROWTYPE;
cl_setup_rec            igf_sl_cl_setup_all%ROWTYPE;
p_incr_date_code        VARCHAR2(100);

g_s_default_status      igf_sl_lor_all.s_default_status%TYPE;
g_p_default_status      igf_sl_lor_all.p_default_status%TYPE;
g_grade_level_dl        igf_sl_lor_all.grade_level_code%TYPE;
g_grade_level_cl        igf_sl_lor_all.grade_level_code%TYPE;
g_anticip_compl_date    igf_sl_lor_all.anticip_compl_date%TYPE;
g_enrollment_code       igf_sl_lor_all.enrollment_code%TYPE;
gv_return_status        VARCHAR2(30);
gv_message              fnd_new_messages.message_text%TYPE;
SKIP_THIS_RECORD        EXCEPTION;

g_log_title             VARCHAR2(1000);
g_log_start_flag        BOOLEAN;

-- Parameters below is declared to hold the fund id in the
-- award rec loop. (Bug 2385334)
g_adplans_id            igf_aw_awd_dist_plans.adplans_id%TYPE; -- Bug 4568942
g_award_id              igf_aw_award_all.award_id%TYPE;
g_person_id             igf_ap_fa_base_rec_all.person_id%TYPE;
gn_transaction_num      igf_ap_isir_matched_all.transaction_num%TYPE;
gv_atd_entity_id_txt    VARCHAR2(30);
gv_rep_entity_id_txt    VARCHAR2(30);

gv_unsub_elig_for_depnt  igf_sl_lor.unsub_elig_for_depnt%TYPE;
gn_award_id              igf_aw_awd_disb_all.award_id%TYPE;

g_accepted_amt          award_rec.accepted_amt%TYPE;

g_process_log            igf_lookups_view.meaning%TYPE;
g_award_log              igf_lookups_view.meaning%TYPE;
g_person_log             igf_lookups_view.meaning%TYPE;
g_year                   VARCHAR2(80);
g_start_date             DATE;
g_end_date               DATE;
g_alternate_code         igs_ca_inst_all.alternate_code%TYPE;
g_student_person_id      NUMBER; -- Bug # 4636920 - bvisvana


  PROCEDURE get_borrower_parent_id (
            p_loan_id                  IN       igf_sl_loans.loan_id%TYPE,
            p_parent_person_id         IN       OUT NOCOPY  NUMBER,
            p_student_person_id        IN       OUT NOCOPY  NUMBER
            ) IS
  -- takes loan_id, return parentid and parent_details for single associated parent for the student
  /***************************************************************
   Change History   :
   Who          When                What
   bvisvana     25-Aug-2005         Bug 4127532 - Placed p_student_person_id assignment after the IF condition
                                    since we need the student id for ALT loans (student = borrower) irrespective of single parent or not
                                    For FLP and DLP only parent is needed and hence if only one parent, that parent_id is returned, else NULL
   ***************************************************************/
    CURSOR parent_id_cur (cp_loan_id    igf_sl_loans_all.loan_id%TYPE) IS
    SELECT
      COUNT(v.row_id) parent_count,
      MIN(v.object_ID) student_id,
      MIN(v.SUBJECT_ID) parent_id
    FROM
        igs_pe_relationships_v v,
        igf_aw_award_all awd,
        igf_sl_loans_all loans,
        igf_ap_fa_base_rec base
    WHERE
    base.person_id = v.object_id
    AND base.base_id = awd.base_id
    AND awd.award_id = loans.award_id
    AND loans.loan_id = cp_loan_id
    AND
    RELATIONSHIP_CODE = 'PARENT_OF'
    AND TRUNC(SYSDATE) BETWEEN v.start_date and NVL(v.end_date, SYSDATE);

    l_parent_id_rec         parent_id_cur%ROWTYPE;

  BEGIN
    OPEN parent_id_cur (cp_loan_id => p_loan_id);
    FETCH parent_id_cur INTO l_parent_id_rec;
    CLOSE parent_id_cur;
    IF l_parent_id_rec.parent_count = 1 THEN
      -- Get Parent Details as required for
      p_parent_person_id  := l_parent_id_rec.parent_id;
    END IF;
    -- bvisvana - Bug 4127532 - Placed the assignment statement for p_student_person_id
    -- after the IF condition since we need the student id for ALT loans (student = borrower) irrespective of parent count
    -- For FLP and DLP only parent is needed and hence it only one parent, that is returned else NULL
    p_student_person_id := l_parent_id_rec.student_id;
    g_student_person_id := l_parent_id_rec.student_id; -- Bug # 4636920 - bvisvana
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.get_borrower_parent_id.debug',
                                                 'p_loan_id            - ' || p_loan_id ||
                                                 '|student_id          - ' || l_parent_id_rec.student_id ||
                                                 '|p_parent_person_id  - ' || p_parent_person_id ||
                                                 '|Parent .parent_count - ' ||l_parent_id_rec.parent_count);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_SL_LAR_CREATION.GET_BORROWER_PARENT_ID');
      fnd_file.put_line(fnd_file.log,fnd_message.get || '-' || SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
  END get_borrower_parent_id;


  PROCEDURE populate_cosigner_data (p_loan_id         igf_sl_loans_all.loan_id%TYPE,
                                    p_person_id       NUMBER) IS
    /*
    Change History
      Who            When            What
      bvisvana       07-Oct-2005     Bug # 4636920 - Cosigner details not fetched properly.
                                     CS1 Student Relationship and CS1 US Citizenship status are populated correctly.
    */

    CURSOR alt_borw_cur (cp_loan_id   igf_sl_alt_borw_all.loan_id%TYPE) IS
    SELECT
      alt.rowid row_id,
      alt.*
    FROM
      igf_sl_alt_borw_all alt
    WHERE
      alt.loan_id = cp_loan_id;

--Bug# 5006583  - bvisvana
-- get cal type and sequence number

    CURSOR cal_type_cur (cp_loan_id igf_sl_alt_borw_all.loan_id%TYPE) IS
    SELECT
           slor.ci_cal_type, slor.ci_sequence_number
    FROM   igf_sl_lor_v  slor
    WHERE slor.loan_id = cp_loan_id;

    cal_type_rec  cal_type_cur%ROWTYPE;

--Bug# 5006583  - bvisvana
    CURSOR citizenship_dtl_cur (cp_person_id igf_sl_cl_pref_lenders.person_id%TYPE) IS
    SELECT
           pct.restatus_code
    FROM   igs_pe_eit_restatus_v  pct
    WHERE  pct.person_id    = cp_person_id
    AND  SYSDATE BETWEEN start_date AND NVL(end_date,SYSDATE);

    citizenship_dtl_rec citizenship_dtl_cur%ROWTYPE;

    --Bug# 5006583
    CURSOR cur_fa_mapping ( p_citizenship_status igf_sl_pe_citi_map.pe_citi_stat_code%TYPE,
                            p_cal_type igf_sl_pe_citi_map.ci_cal_type%TYPE,
                             p_sequence_number igf_sl_pe_citi_map.ci_sequence_number%TYPE ) IS
    SELECT fa_citi_stat_code FROM igf_sl_pe_citi_map
    WHERE pe_citi_stat_code = p_citizenship_status
    AND ci_sequence_number =p_sequence_number
    AND ci_cal_type = p_cal_type;

        l_cur_fa_rec                  cur_fa_mapping%ROWTYPE;
    -- Bug # 4636920 - bvisvana
    CURSOR cur_stud_rel (cp_parent_id  NUMBER , cp_student_id NUMBER) IS
    SELECT relationship_code FROM
      igs_pe_relationships_v v
    WHERE v.object_id  = cp_student_id AND -- child
          v.subject_id = cp_parent_id  AND  -- parent
          TRUNC(SYSDATE) BETWEEN v.start_date and NVL(v.end_date, SYSDATE);
    rel_code    VARCHAR2(30);

    l_alt_borw_rec      alt_borw_cur%ROWTYPE;
    lv_rowid            ROWID;
    l_albw_id           igf_sl_alt_borw.albw_id%TYPE;
    cosigner_dtl_cur    igf_sl_gen.person_dtl_cur;
    cosigner_dtl_rec    igf_sl_gen.person_dtl_rec;
    l_person_phone      VARCHAR2(30);

  BEGIN

    igf_sl_gen.get_person_details(p_person_id, cosigner_dtl_cur);
    FETCH cosigner_dtl_cur INTO cosigner_dtl_rec;
    CLOSE cosigner_dtl_cur;
    l_person_phone   := igf_sl_gen.get_person_phone(p_person_id);

    OPEN alt_borw_cur (cp_loan_id => p_loan_id);
    FETCH alt_borw_cur INTO l_alt_borw_rec;
    CLOSE alt_borw_cur;

    -- FA 161 CL4 #5006583
    OPEN citizenship_dtl_cur (p_person_id);                   --get citizenship status
    FETCH citizenship_dtl_cur INTO citizenship_dtl_rec;

    OPEN cal_type_cur (p_loan_id);
    FETCH cal_type_cur INTO cal_type_rec;

    IF citizenship_dtl_cur%FOUND THEN
     OPEN cur_fa_mapping (citizenship_dtl_rec.restatus_code,         --get FA Citizenship Status Code
                             cal_type_rec.ci_cal_type,
                             cal_type_rec.ci_sequence_number);
     FETCH cur_fa_mapping INTO l_cur_fa_rec;
     CLOSE cur_fa_mapping;

     IF NVL(l_cur_fa_rec.fa_citi_stat_code,'*') = '1' THEN
      citizenship_dtl_rec.restatus_code := '1';
     ELSE
      citizenship_dtl_rec.restatus_code := NULL;
     END IF;
    END IF;
    CLOSE cal_type_cur;
    CLOSE citizenship_dtl_cur;

    -- Bug # 4636920 - bvisvana
    IF p_person_id IS NOT NULL THEN
       OPEN cur_stud_rel(cp_parent_id => p_person_id, cp_student_id => g_student_person_id);
       FETCH cur_stud_rel INTO rel_code;
       CLOSE cur_stud_rel;
       IF rel_code = 'PARENT_OF' THEN
          rel_code := 'P';
       ELSIF rel_code = 'CHILD_OF' THEN
          rel_code := 'C';
       END IF;
    END IF;

    cosigner_dtl_rec.p_permt_zip := TRANSLATE (UPPER(LTRIM(RTRIM(cosigner_dtl_rec.p_permt_zip))),'1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ`~!@#$%^&*_+=-,./?><():; ','1234567890');

    igf_sl_alt_borw_pkg.add_row (
        x_rowid                             => l_alt_borw_rec.row_id                      ,
        x_albw_id                           => l_alt_borw_rec.albw_id                     ,
        x_loan_id                           => p_loan_id                                  ,
        x_fed_stafford_loan_debt            => l_alt_borw_rec.fed_stafford_loan_debt      ,
        x_fed_sls_debt                      => l_alt_borw_rec.fed_sls_debt                ,
        x_heal_debt                         => l_alt_borw_rec.heal_debt                   ,
        x_perkins_debt                      => l_alt_borw_rec.perkins_debt                ,
        x_other_debt                        => l_alt_borw_rec.other_debt                  ,
        x_crdt_undr_difft_name              => l_alt_borw_rec.crdt_undr_difft_name        ,
        x_borw_gross_annual_sal             => l_alt_borw_rec.borw_gross_annual_sal       ,
        x_borw_other_income                 => l_alt_borw_rec.borw_other_income           ,
        x_student_major                     => l_alt_borw_rec.student_major               ,
        x_int_rate_opt                      => l_alt_borw_rec.int_rate_opt                ,
        x_repayment_opt_code                => l_alt_borw_rec.repayment_opt_code          ,
        x_stud_mth_housing_pymt             => l_alt_borw_rec.stud_mth_housing_pymt       ,
        x_stud_mth_crdtcard_pymt            => l_alt_borw_rec.stud_mth_crdtcard_pymt      ,
        x_stud_mth_auto_pymt                => l_alt_borw_rec.stud_mth_auto_pymt          ,
        x_stud_mth_ed_loan_pymt             => l_alt_borw_rec.stud_mth_ed_loan_pymt       ,
        x_stud_mth_other_pymt               => l_alt_borw_rec.stud_mth_other_pymt         ,
        x_mode                              => 'R'                                        ,
        x_other_loan_amt                    => l_alt_borw_rec.other_loan_amt              ,
        x_cs1_lname                         => NVL(l_alt_borw_rec.cs1_lname, SUBSTR(cosigner_dtl_rec.p_last_name, 1, 35)),
        x_cs1_fname                         => NVL(l_alt_borw_rec.cs1_fname, SUBSTR(cosigner_dtl_rec.p_first_name, 1, 12)),
        x_cs1_mi_txt                        => NVL(l_alt_borw_rec.cs1_mi_txt, SUBSTR(cosigner_dtl_rec.p_middle_name, 1, 1)),
        x_cs1_ssn_txt                       => NVL(l_alt_borw_rec.cs1_ssn_txt, SUBSTR(cosigner_dtl_rec.p_ssn, 1, 9)),
        x_cs1_citizenship_status            => NVL(l_alt_borw_rec.cs1_citizenship_status, SUBSTR(citizenship_dtl_rec.restatus_code, 1, 1)),  -- rajagupt bug#5006587, instead of driving from person detail , now deriving from new mapping form
        x_cs1_address_line_1_txt            => NVL(l_alt_borw_rec.cs1_address_line_1_txt, SUBSTR(cosigner_dtl_rec.p_permt_addr1, 1, 30)),
        x_cs1_address_line_2_txt            => NVL(l_alt_borw_rec.cs1_address_line_2_txt, SUBSTR(cosigner_dtl_rec.p_permt_addr2, 1, 30)),
        x_cs1_city_txt                      => NVL(l_alt_borw_rec.cs1_city_txt, SUBSTR(cosigner_dtl_rec.p_permt_city, 1, 24)),
        x_cs1_state_txt                     => NVL(l_alt_borw_rec.cs1_state_txt, SUBSTR(cosigner_dtl_rec.p_permt_state, 1, 2)),
        x_cs1_zip_txt                       => NVL(l_alt_borw_rec.cs1_zip_txt, SUBSTR(cosigner_dtl_rec.p_permt_zip, 1, 5)),
        x_cs1_zip_suffix_txt                => NVL(l_alt_borw_rec.cs1_zip_suffix_txt, SUBSTR(cosigner_dtl_rec.p_permt_zip, 6, 4)),
        x_cs1_telephone_number_txt          => NVL(l_alt_borw_rec.cs1_telephone_number_txt, SUBSTR(l_person_phone, 1, 10)),
        x_cs1_signature_code_txt            => l_alt_borw_rec.cs1_signature_code_txt      ,
        x_cs2_lname                         => l_alt_borw_rec.cs2_lname                   ,
        x_cs2_fname                         => l_alt_borw_rec.cs2_fname                   ,
        x_cs2_mi_txt                        => l_alt_borw_rec.cs2_mi_txt                  ,
        x_cs2_ssn_txt                       => l_alt_borw_rec.cs2_ssn_txt                 ,
        x_cs2_citizenship_status            => l_alt_borw_rec.cs2_citizenship_status      ,
        x_cs2_address_line_1_txt            => l_alt_borw_rec.cs2_address_line_1_txt      ,
        x_cs2_address_line_2_txt            => l_alt_borw_rec.cs2_address_line_2_txt      ,
        x_cs2_city_txt                      => l_alt_borw_rec.cs2_city_txt                ,
        x_cs2_state_txt                     => l_alt_borw_rec.cs2_state_txt               ,
        x_cs2_zip_txt                       => l_alt_borw_rec.cs2_zip_txt                 ,
        x_cs2_zip_suffix_txt                => l_alt_borw_rec.cs2_zip_suffix_txt          ,
        x_cs2_telephone_number_txt          => l_alt_borw_rec.cs2_telephone_number_txt    ,
        x_cs2_signature_code_txt            => l_alt_borw_rec.cs2_signature_code_txt      ,
        x_cs1_credit_auth_code_txt          => l_alt_borw_rec.cs1_credit_auth_code_txt    ,
        x_cs1_birth_date                    => NVL(l_alt_borw_rec.cs1_birth_date, cosigner_dtl_rec.p_date_of_birth),
        x_cs1_drv_license_num_txt           => NVL(l_alt_borw_rec.cs1_drv_license_num_txt, SUBSTR(cosigner_dtl_rec.p_license_num, 1, 20)),
        x_cs1_drv_license_state_txt         => NVL(l_alt_borw_rec.cs1_drv_license_state_txt, SUBSTR(cosigner_dtl_rec.p_license_state, 1, 2)),
        x_cs1_elect_sig_ind_code_txt        => l_alt_borw_rec.cs1_elect_sig_ind_code_txt  ,
        x_cs1_frgn_postal_code_txt          => l_alt_borw_rec.cs1_frgn_postal_code_txt    ,
        x_cs1_frgn_tel_num_prefix_txt       => l_alt_borw_rec.cs1_frgn_tel_num_prefix_txt ,
        x_cs1_gross_annual_sal_num          => l_alt_borw_rec.cs1_gross_annual_sal_num    ,
        x_cs1_mthl_auto_pay_txt             => l_alt_borw_rec.cs1_mthl_auto_pay_txt       ,
        x_cs1_mthl_cc_pay_txt               => l_alt_borw_rec.cs1_mthl_cc_pay_txt         ,
        x_cs1_mthl_edu_loan_pay_txt         => l_alt_borw_rec.cs1_mthl_edu_loan_pay_txt   ,
        x_cs1_mthl_housing_pay_txt          => l_alt_borw_rec.cs1_mthl_housing_pay_txt    ,
        x_cs1_mthl_other_pay_txt            => l_alt_borw_rec.cs1_mthl_other_pay_txt      ,
        x_cs1_other_income_amt              => l_alt_borw_rec.cs1_other_income_amt        ,
        x_cs1_rel_to_student_flag           => NVL(l_alt_borw_rec.cs1_rel_to_student_flag,rel_code) , -- bvisvana - Bug # 4636920
        x_cs1_suffix_txt                    => l_alt_borw_rec.cs1_suffix_txt              ,
        x_cs1_years_at_address_txt          => l_alt_borw_rec.cs1_years_at_address_txt    ,
        x_cs2_credit_auth_code_txt          => l_alt_borw_rec.cs2_credit_auth_code_txt    ,
        x_cs2_birth_date                    => l_alt_borw_rec.cs2_birth_date              ,
        x_cs2_drv_license_num_txt           => l_alt_borw_rec.cs2_drv_license_num_txt     ,
        x_cs2_drv_license_state_txt         => l_alt_borw_rec.cs2_drv_license_state_txt   ,
        x_cs2_elect_sig_ind_code_txt        => l_alt_borw_rec.cs2_elect_sig_ind_code_txt  ,
        x_cs2_frgn_postal_code_txt          => l_alt_borw_rec.cs2_frgn_postal_code_txt    ,
        x_cs2_frgn_tel_num_prefix_txt       => l_alt_borw_rec.cs2_frgn_tel_num_prefix_txt ,
        x_cs2_gross_annual_sal_num          => l_alt_borw_rec.cs2_gross_annual_sal_num    ,
        x_cs2_mthl_auto_pay_txt             => l_alt_borw_rec.cs2_mthl_auto_pay_txt       ,
        x_cs2_mthl_cc_pay_txt               => l_alt_borw_rec.cs2_mthl_cc_pay_txt         ,
        x_cs2_mthl_edu_loan_pay_txt         => l_alt_borw_rec.cs2_mthl_edu_loan_pay_txt   ,
        x_cs2_mthl_housing_pay_txt          => l_alt_borw_rec.cs2_mthl_housing_pay_txt    ,
        x_cs2_mthl_other_pay_txt            => l_alt_borw_rec.cs2_mthl_other_pay_txt      ,
        x_cs2_other_income_amt              => l_alt_borw_rec.cs2_other_income_amt        ,
        x_cs2_rel_to_student_flag           => l_alt_borw_rec.cs2_rel_to_student_flag     ,
        x_cs2_suffix_txt                    => l_alt_borw_rec.cs2_suffix_txt              ,
        x_cs2_years_at_address_txt          => l_alt_borw_rec.cs2_years_at_address_txt
      );

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_SL_LAR_CREATION.POPULATE_COSIGNER_DATA');
      fnd_file.put_line(fnd_file.log,fnd_message.get || '-' || SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
  END populate_cosigner_data;



  FUNCTION get_fund_desc(p_fund_id IN NUMBER)
  RETURN VARCHAR2 IS
  CURSOR cur_get_fund_desc (p_fund_id NUMBER)
  IS
  SELECT fcat.fund_code||'-'||fmast.description description
  FROM   igf_aw_fund_mast_all fmast,
         igf_aw_fund_cat_all fcat
  WHERE  fmast.fund_id = p_fund_id
    AND  fcat.fund_code = fmast.fund_code;

  get_fund_desc_rec cur_get_fund_desc%ROWTYPE;

  BEGIN

    OPEN  cur_get_fund_desc (p_fund_id);
    FETCH cur_get_fund_desc INTO get_fund_desc_rec;
    CLOSE cur_get_fund_desc;

    RETURN get_fund_desc_rec.description;

  END get_fund_desc;

 FUNCTION check_fa_rec(p_base_id    NUMBER,
                        p_cal_type   VARCHAR2,
                        p_seq_number NUMBER)
  RETURN BOOLEAN
  IS
    CURSOR cur_chk_fa (p_base_id    NUMBER,
                       p_cal_type   VARCHAR2,
                       p_seq_number NUMBER)
    IS
    SELECT base_id
    FROM   igf_ap_fa_base_rec_all
    WHERE  base_id = p_base_id AND
    ci_cal_type = p_cal_type   AND
    ci_sequence_number = p_seq_number;

    chk_fa_rec cur_chk_fa%ROWTYPE;

  BEGIN

    OPEN cur_chk_fa (p_base_id,p_cal_type,p_seq_number);
    FETCH cur_chk_fa INTO chk_fa_rec;
    CLOSE cur_chk_fa;
    IF chk_fa_rec.base_id IS NULL THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;

  END check_fa_rec;
--End of declarations for bug 2385334
-- Function to get the Loan Start Date
--

  FUNCTION get_grp_name(p_per_grp_id IN NUMBER)
  RETURN VARCHAR2 IS

  CURSOR cur_get_grp_name (p_per_grp_id NUMBER)
  IS
  SELECT group_cd
  FROM   igs_pe_persid_group_all
  WHERE  group_id = p_per_grp_id;


  get_grp_name_rec cur_get_grp_name%ROWTYPE;

  BEGIN

    OPEN  cur_get_grp_name (p_per_grp_id);
    FETCH cur_get_grp_name INTO get_grp_name_rec;
    CLOSE cur_get_grp_name;

    RETURN get_grp_name_rec.group_cd;

  END get_grp_name;

PROCEDURE get_dl_entity_id(p_base_id           IN NUMBER,
                           p_cal_type          IN igs_ca_inst_all.cal_type%TYPE,
                           p_seq_num           IN igs_ca_inst_all.sequence_number%TYPE,
                           p_atd_entity_id_txt OUT NOCOPY VARCHAR2,
                           p_rep_entity_id_txt OUT NOCOPY VARCHAR2,
                           p_message           OUT NOCOPY VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2)
IS
   CURSOR c_get_rep_entity_id_txt(
      p_cal_type                          igs_ca_inst.cal_type%TYPE,
      p_seq_num                           igs_ca_inst.sequence_number%TYPE,
      p_atd_entity_id                     igf_gr_attend_pell.atd_entity_id_txt%TYPE
   )
   IS
      SELECT rep.rep_entity_id_txt
        FROM igf_gr_attend_pell gap, igf_gr_report_pell rep
       WHERE gap.ci_cal_type = p_cal_type
         AND gap.ci_sequence_number = p_seq_num
         AND gap.atd_entity_id_txt = p_atd_entity_id
         AND gap.rcampus_id = rep.rcampus_id;

   l_ret_status                  VARCHAR2(30);
   l_msg_data                    VARCHAR2(30);

BEGIN

      p_atd_entity_id_txt := NULL;
      p_rep_entity_id_txt := NULL;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.get_dl_entity_id.debug','Entry p_base_id, p_cal_type, p_seq_num ' || p_base_id || ' : ' ||  p_cal_type || ' : ' || p_seq_num);
      END IF;

-- Get attending Pell Id from Org Setup.
      igf_sl_gen.get_stu_fao_code(
         p_base_id                     => p_base_id,
         p_office_type                 => 'ENTITY_ID',
         x_office_cd                   => p_atd_entity_id_txt,
         x_return_status               => l_ret_status,
         x_msg_data                    => l_msg_data
      );

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.get_dl_entity_id.debug','after get fao code');
      END IF;

      IF (l_ret_status = 'E')
      THEN
         p_return_status := l_ret_status;
         fnd_message.set_name('IGF', 'IGF_GR_NO_ATTEND_ENTITY_ID');
         p_message := fnd_message.get;
         RETURN;
      END IF;

      IF ((l_ret_status = 'S') AND (p_atd_entity_id_txt IS NOT NULL))
      THEN

-- Derive the report pell ID.
         OPEN c_get_rep_entity_id_txt(
            p_cal_type,
            p_seq_num,
            p_atd_entity_id_txt
         );
         FETCH c_get_rep_entity_id_txt INTO p_rep_entity_id_txt;
         CLOSE c_get_rep_entity_id_txt;
      END IF;

      IF (p_rep_entity_id_txt IS NULL)
      THEN
         fnd_message.set_name('IGF', 'IGF_GR_NOREP_ENTITY');
         fnd_message.set_token('STU_NUMBER', igf_gr_gen.get_per_num(p_base_id));
         p_message := fnd_message.get;
         p_return_status := 'E';
         RETURN;
      END IF;

EXCEPTION

  WHEN OTHERS THEN
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_LAR_CREATION.GET_DL_ENTITY_ID');
    fnd_file.put_line(fnd_file.log,SQLERRM);
    igs_ge_msg_stack.add;
    app_exception.raise_exception;

END get_dl_entity_id;

FUNCTION get_loan_start_dt ( p_award_id  igf_aw_award_all.award_id%TYPE)
RETURN DATE
IS
--
-- Cursor to retrieve Loan Start Date
--
    CURSOR cur_loan_start_dt ( p_award_id  igf_aw_award_all.award_id%TYPE) IS
       SELECT ld_cal_type,ld_sequence_number
       FROM   igf_aw_awd_disb  awd
       WHERE  awd.award_id           = p_award_id
       AND    awd.trans_type         <> 'C'
       GROUP BY awd.ld_cal_type,awd.ld_sequence_number;

  CURSOR c_base_id(cp_award_id igf_aw_award_all.award_id%TYPE) IS
    SELECT base_id
      FROM igf_aw_award_all
     WHERE award_id = cp_award_id;
  l_base_id igf_ap_fa_base_rec_all.base_id%TYPE;

  p_start_dt DATE;
  l_start_dt DATE;
  l_end_dt   DATE;
  l_first_cycle VARCHAR2(1);

BEGIN
  p_start_dt := NULL;
  l_base_id  := NULL;
  l_start_dt := NULL;
  l_end_dt   := NULL;

  OPEN c_base_id(p_award_id);
  FETCH c_base_id INTO l_base_id;
  CLOSE c_base_id;

  l_first_cycle := 'Y';

    FOR loan_start_dt_rec IN cur_loan_start_dt(p_award_id) LOOP
      igf_ap_gen_001.get_term_dates(
                                    p_base_id            => l_base_id,
                                    p_ld_cal_type        => loan_start_dt_rec.ld_cal_type,
                                    p_ld_sequence_number => loan_start_dt_rec.ld_sequence_number,
                                    p_ld_start_date      => l_start_dt,
                                    p_ld_end_date        => l_end_dt
                                   );
      IF l_first_cycle = 'Y' THEN
        p_start_dt := l_start_dt;
        l_first_cycle := 'N';
      ELSE
        p_start_dt := LEAST(p_start_dt,l_start_dt);
      END IF;
    END LOOP;
    RETURN p_start_dt;
END get_loan_start_dt;

--
-- Function to get the Loan End Date
--

FUNCTION get_loan_end_dt ( p_award_id  igf_aw_award_all.award_id%TYPE)
RETURN DATE
IS


--
-- Cursor to Retrieve Loan End Date
--
    CURSOR cur_loan_end_dt ( p_award_id  igf_aw_award_all.award_id%TYPE) IS
       SELECT ld_cal_type,ld_sequence_number
       FROM   igf_aw_awd_disb  awd
       WHERE  awd.award_id           = p_award_id
       AND    awd.trans_type         <> 'C'
       GROUP BY awd.ld_cal_type,awd.ld_sequence_number;

  CURSOR c_base_id(cp_award_id igf_aw_award_all.award_id%TYPE) IS
    SELECT base_id
      FROM igf_aw_award_all
     WHERE award_id = cp_award_id;
  l_base_id igf_ap_fa_base_rec_all.base_id%TYPE;

  p_end_dt   DATE;
  l_start_dt DATE;
  l_end_dt   DATE;
  l_first_cycle VARCHAR2(1);

BEGIN

  p_end_dt   := NULL;
  l_base_id  := NULL;
  l_start_dt := NULL;
  l_end_dt   := NULL;

  OPEN c_base_id(p_award_id);
  FETCH c_base_id INTO l_base_id;
  CLOSE c_base_id;

  l_first_cycle := 'Y';

    FOR loan_end_dt_rec IN cur_loan_end_dt(p_award_id) LOOP
      igf_ap_gen_001.get_term_dates(
                                    p_base_id            => l_base_id,
                                    p_ld_cal_type        => loan_end_dt_rec.ld_cal_type,
                                    p_ld_sequence_number => loan_end_dt_rec.ld_sequence_number,
                                    p_ld_start_date      => l_start_dt,
                                    p_ld_end_date        => l_end_dt
                                   );
      IF l_first_cycle = 'Y' THEN
        p_end_dt      := l_end_dt;
        l_first_cycle := 'N';
      ELSE
        p_end_dt := GREATEST(p_end_dt,l_end_dt);
      END IF;
    END LOOP;
    RETURN p_end_dt;
END get_loan_end_dt;

PROCEDURE log_message(p_award_id    igf_aw_award.award_id%TYPE) IS
BEGIN

  IF g_log_start_flag = FALSE THEN
    fnd_file.new_line(fnd_file.log,1);

    IF g_log_title IS NULL THEN
       g_log_title := igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','AWARD_ID')||'   : ';
    END IF;

    fnd_file.put_line(fnd_file.log, g_log_title||TO_CHAR(p_award_id));
    g_log_start_flag := TRUE;
  END IF;

END log_message;


FUNCTION  ret_loan_number(p_loan_seq_number   IN   igf_sl_loans.seq_num%TYPE,
                          p_base_id       IN    igf_aw_award_v.base_id%TYPE)
RETURN VARCHAR2
IS
/***************************************************************
   Created By       :    mesriniv
   Date Created By  :    2000/11/13
   Purpose          :    To arrive at the Loan Number
   Known Limitations,Enhancements or Remarks


--
--
   Change History   :
   --Bug 2470130 Desc : DL Formatting Errors.
   Who        When             What
   ugummall   23-OCT-2003      Bug 3102439. FA 126 - Multiple FA Offices.
                               In constructing loan_number for Direct Loan, School ID is derived from the
                               student's associated Org. For this purpose base_id(as extra parameter) is
                               passed to this function.
                               Similarly, OPE ID and School Non Ed Brc ID are also derived for Common Line Loan.
   mesriniv   26-jul-2002      Used DL Version to get the program year instead of calendar end date.

   Bug Id           : 1720677
   Desc       : Mapping of school id in the CommonLine Setup
                             to ope_id of  Financial Aid Office Setup.
   Who                When             What
   mesriniv         05-APR-2001    Changed the occurrences of field fao_id
                                        to ope_id
 ***************************************************************/

    lv_loan_type          VARCHAR2(100);
    lv_loan_yr            VARCHAR2(2);
    lv_loan_number        igf_sl_loans_all.loan_number%TYPE;
    lv_incr_seq           NUMBER;
    lv_incr_seq_char      VARCHAR2(100);
    l_ssn                 igf_ap_isir_matched_all.current_ssn%TYPE;

    x_return_status       VARCHAR2(1);
    x_msg_data            VARCHAR2(30);
    x_dlsch_cd            igs_or_org_alt_ids.org_alternate_id%TYPE;
    x_ope_cd              igs_or_org_alt_ids.org_alternate_id%TYPE;
    x_sch_non_ed_brc_cd   igs_or_org_alt_ids.org_alternate_id%TYPE;

    CURSOR cur_loan_num (p_loan_number igf_sl_loans_all.loan_number%TYPE) IS
       SELECT   rowid
       FROM     igf_sl_loans_all
       WHERE    loan_number = p_loan_number;

    loan_num_rec  cur_loan_num%ROWTYPE;

BEGIN

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.ret_loan_number.debug','Entry ret_loan_number');
   END IF;

  IF igf_sl_gen.chk_dl_fed_fund_code(award_rec.fed_fund_code) = 'TRUE' THEN

        -- Direct Loan's Loan Number
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.ret_loan_number.debug','DL Loan Number Step 1');
        END IF;

        -- Loan TYPE is S from DLS,P from DLP and U from DLU
        lv_loan_type := SUBSTR(TRIM(award_rec.fed_fund_code),3,1);

        --Bug 2470130 ,To get the Program Year
        lv_loan_yr := SUBSTR(dl_setup_rec.dl_version,8,2);

        l_ssn:=NULL;
        l_ssn := igf_gr_gen.get_ssn_digits(award_rec.ssn);

        -- Bug 3102439. To get School ID for Direct Loan.
        igf_sl_gen.get_stu_fao_code(p_base_id, 'DL_SCH_CD', x_dlsch_cd, x_return_status, x_msg_data);
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.ret_loan_number.debug','after get DL SCHOOL CODE');
        END IF;
        IF (x_return_status = 'E') THEN
          log_message(award_rec.award_id);
          fnd_message.set_name('IGF', x_msg_data);
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          RAISE SKIP_THIS_RECORD;
        END IF;
        lv_loan_number :=  LPAD(l_ssn,9,'0')
                        || lv_loan_type
                        || lv_loan_yr
                        || x_dlsch_cd
                        || LPAD(TO_CHAR(p_loan_seq_number),3,'0');

        OPEN cur_loan_num (lv_loan_number);
        FETCH cur_loan_num INTO loan_num_rec;
        IF (cur_loan_num%FOUND) THEN
                CLOSE cur_loan_num;

                log_message(award_rec.award_id);
                fnd_message.set_name('IGF','IGF_SL_SSN_IN_USE');
                fnd_message.set_token('VALUE',award_rec.ssn);
                fnd_message.set_token('PER_NUM',award_rec.person_number);
                fnd_file.put_line(fnd_file.log,fnd_message.get);
                RAISE SKIP_THIS_RECORD;
        ELSE
                CLOSE cur_loan_num;
        END IF;


  ELSIF igf_sl_gen.chk_cl_fed_fund_code(award_rec.fed_fund_code) = 'TRUE' THEN

         -- CommonLine Loan's Loan Number
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.ret_loan_number.debug','FFEL Loan Number Step 1');
        END IF;

         -- Range is 1 to 46655. So, RECYCLE option should be provided.
         SELECT igf_sl_cl_loan_seq_s.NEXTVAL into lv_incr_seq FROM DUAL;

         lv_incr_seq_char := igf_sl_gen.base10_to_base36(lv_incr_seq);

         -- Bug 3102439. To get OPE ID.
         igf_sl_gen.get_stu_fao_code(p_base_id, 'OPE_ID_NUM', x_ope_cd, x_return_status, x_msg_data);
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.ret_loan_number.debug','FFEL Loan Number Step 2 x_ope_cd ' || x_ope_cd);
         END IF;
         IF (x_return_status = 'E') THEN
           log_message(award_rec.award_id);
           fnd_message.set_name('IGF', x_msg_data);
           fnd_file.put_line(fnd_file.log, fnd_message.get);
           RAISE SKIP_THIS_RECORD;
         END IF;

         -- Bug 3102439. To get SCH_NON_ED_BRC_ID.
         igf_sl_gen.get_stu_fao_code(p_base_id, 'SCH_NON_ED_BRC_ID', x_sch_non_ed_brc_cd, x_return_status, x_msg_data);
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.ret_loan_number.debug','FFEL Loan Number Step 3 x_sch_non_ed_brc_cd ' || x_sch_non_ed_brc_cd ||' : x_msg_data ' || x_msg_data);
         END IF;
         IF (x_return_status = 'E') THEN
           IF (x_msg_data = 'IGF_AP_SCH_NONED_NOTFND') THEN
             -- construct source non ed branch id from the last two digits of the school id
             -- school id assigned by the ED will always be of 8 characters in length
             x_sch_non_ed_brc_cd := substr(x_ope_cd,7,2);
           ELSE
             log_message(award_rec.award_id);
             fnd_message.set_name('IGF', x_msg_data);
             fnd_file.put_line(fnd_file.log, fnd_message.get);
             RAISE SKIP_THIS_RECORD;
           END IF;
         END IF;
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.ret_loan_number.debug','Construct Loan Number ');
         END IF;

         lv_loan_number :=  LPAD(x_ope_cd, 6,'0')
                         || LPAD(NVL(x_sch_non_ed_brc_cd,'0'),4,'0')
                         || '1'           -- Hardcoded the Computer Number.
                         || LPAD(p_incr_date_code,3,'0')
                         || LPAD(lv_incr_seq_char,3,'0');
  END IF;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.ret_loan_number.debug',' Loan Number = lv_loan_number ' || lv_loan_number);
  END IF;

  RETURN lv_loan_number;

EXCEPTION

  WHEN SKIP_THIS_RECORD THEN
        RAISE;

  WHEN NO_DATA_FOUND THEN
    fnd_message.set_name('IGF','IGF_GE_NO_DATA_FOUND');
    fnd_message.set_token('NAME','IGF_SL_LAR_CREATION.RET_LOAN_NUMBER');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;

  WHEN OTHERS THEN
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_LAR_CREATION.RET_LOAN_NUMBER');
    fnd_file.put_line(fnd_file.log,SQLERRM);
    igs_ge_msg_stack.add;
    app_exception.raise_exception;

END ret_loan_number;

PROCEDURE  get_dl_cl_std_code ( p_base_id         IN   igf_ap_fa_base_rec_all.base_id%TYPE,
                                p_class_standing  IN   igs_pr_css_class_std_v.class_standing%TYPE ,
                                p_program_type    IN   igs_ps_ver_all.course_type%TYPE ,
                                p_dl_std_code     OUT NOCOPY  igf_ap_class_std_map.dl_std_code%TYPE ,
                                p_cl_std_code     OUT NOCOPY  igf_ap_class_std_map.cl_std_code%TYPE )
                   AS
/***************************************************************
   Created By       :       masehgal
   Date Created By  :    10-Oct-2002
   Purpose          :     # 2591960    Integration Enhancements
                   To obtain the dl/cl std codes
                   Validation for FRESHMAN
   Known Limitations,Enhancements or Remarks
   Change History   :
   Who        When             What
 ***************************************************************/

   -- Cursor to get person_id, ci_cal_type and ci_sequence_number
   CURSOR c_person_info ( cp_base_id   igf_ap_fa_base_rec.base_id%TYPE ) IS
      SELECT person_id, ci_cal_type, ci_sequence_number
      FROM   igf_ap_fa_base_rec
      WHERE  base_id = cp_base_id ;
   lv_person_info_rec   c_person_info%ROWTYPE ;

   -- Cursor to get cs_schdl_id, class_std_id, css_class_std_id
   CURSOR c_class_std ( cp_class_standing    igs_pr_css_class_std_v.class_standing%TYPE ,
                        cp_program_type      igs_ps_ver_all.course_type%TYPE ) IS
      SELECT CSSV.igs_pr_cs_schdl_id ,
             CSSV.igs_pr_class_std_id ,
             CSSV.igs_pr_css_class_std_id
      FROM   igs_pr_css_class_std_v CSSV
      WHERE  CSSV.igs_pr_cs_schdl_id = (SELECT igs_pr_cs_schdl_id
                                        FROM   igs_pr_cs_schdl CS
                                        WHERE  CS.course_type =  cp_program_type )
      AND    CSSV.class_standing = cp_class_standing ;
   lv_class_std_rec    c_class_std%ROWTYPE ;

   -- Cursor to get dl_std_code
   CURSOR  c_dl_cl_std_code ( cp_ci_cal_type         igf_ap_fa_base_rec.ci_cal_type%TYPE ,
                              cp_ci_sequence_number  igf_ap_fa_base_rec.ci_sequence_number%TYPE ,
                              cp_cs_schdl_id         igf_ap_pr_prg_type.igs_pr_cs_schdl_id%TYPE ,
                              cp_css_class_std_id    igf_ap_class_std_map.igs_pr_css_class_std_id%TYPE ) IS
      SELECT  CSM.dl_std_code,
              CSM.cl_std_code
      FROM    igf_ap_class_std_map CSM ,
              igf_ap_pr_prg_type   PPT
      WHERE   PPT.ppt_id                  = CSM.ppt_id
      AND     PPT.igs_pr_cs_schdl_id      = cp_cs_schdl_id
      AND     PPT.cal_type                = cp_ci_cal_type
      AND     PPT.sequence_number         = cp_ci_sequence_number
      AND     CSM.igs_pr_css_class_std_id = cp_css_class_std_id ;
   lv_dl_cl_std_code_rec     c_dl_cl_std_code%ROWTYPE ;

   -- Cursor to get acad history ( institutions attended by the student )
   CURSOR  c_get_acad_hist ( cp_person_id  igf_ap_fa_base_rec.person_id%TYPE ) IS
      SELECT COUNT(institution_code)
      FROM   igs_ad_acad_history_v acad, igs_or_org_inst_type org
      WHERE  acad.institution_type = org.institution_type
      AND    person_id = cp_person_id
      AND    org.system_inst_type = 'POST-SECONDARY' ;

   lv_acad_hist_rec    c_get_acad_hist%ROWTYPE;
   l_count NUMBER(5);

  BEGIN
     l_count :=0;
     -- GET person_id, ci_cal_type , ci_sequence_number using base_id
     OPEN  c_person_info ( p_base_id ) ;
     FETCH c_person_info INTO lv_person_info_rec ;
     CLOSE c_person_info ;

     -- GET cs_schdl_id, class_std_id, css_class_std_id
     OPEN  c_class_std ( p_class_standing, p_program_type ) ;
     FETCH c_class_std INTO lv_class_std_rec ;
     CLOSE c_class_std ;

     -- GET direct loan std code using ci_cal_type, ci_sequence_number, schdl_id and class_standing_id
     OPEN  c_dl_cl_std_code ( lv_person_info_rec.ci_cal_type,
                              lv_person_info_rec.ci_sequence_number,
                              lv_class_std_rec.igs_pr_cs_schdl_id,
                              lv_class_std_rec.igs_pr_css_class_std_id ) ;
     FETCH c_dl_cl_std_code INTO lv_dl_cl_std_code_rec ;
     IF c_dl_cl_std_code%NOTFOUND THEN
        CLOSE c_dl_cl_std_code ;

        RETURN ;
        -- Here we are returning NULL for dl_std_code, cl_std_code
        -- In the calling procedure we will check if it is NULL . If so,
        -- Log a message that no set up has ben done for this particular class standing
        -- i.e. No DL/CL Grade has been attached to this particular class standing in this particular award year
     ELSE
        CLOSE c_dl_cl_std_code ;
     END IF ;

     p_dl_std_code := lv_dl_cl_std_code_rec.dl_std_code ;
     p_cl_std_code := lv_dl_cl_std_code_rec.cl_std_code ;

     -- CHECK for DL_STD_CODE ( '0/1' )
     IF p_dl_std_code = '0/1' THEN
       -- Check for previous institutions attended by the student
                OPEN c_get_acad_hist(lv_person_info_rec.person_id) ;
                FETCH c_get_acad_hist INTO l_count;
                CLOSE c_get_acad_hist;

                IF l_count =0 THEN
                   p_dl_std_code := '0' ;
                ELSE
                   p_dl_std_code := '1';
                END IF;
     END IF ;

  EXCEPTION
     WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_SL_LAR_CREATION.GET_DL_CL_STD_CODE');
        fnd_file.put_line(fnd_file.log,SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
  END get_dl_cl_std_code ;


PROCEDURE return_entities ( P_base_id           IN    igf_ap_fa_base_rec.base_id%TYPE,
                            p_grd_dl            OUT NOCOPY   igf_sl_lor.grade_level_code%TYPE,
                            p_enrl_stat         OUT NOCOPY   igf_sl_lor.enrollment_code%TYPE,
                            p_grd_cl            OUT NOCOPY   igf_sl_lor.grade_level_code%TYPE,
                            p_anticip_comp_date OUT NOCOPY   igf_sl_lor.anticip_compl_date%TYPE) IS
/***************************************************************
   Created By           :       kpadiyar
   Date Created By      :       2001/04/26
   Purpose              :
   Known Limitations,Enhancements or Remarks

   Change History       :
   Who                  When            What
   rasahoo              03-Sep-2003     Removed cursor c_fabaseh and its references
                                        as part of  FA-114(Obsoletion of FA base record History)
   masehgal             18-Dec-2002     # 2477912   Corrected variables to collect dl/cl std codes
   masehgal             10-Oct-2002     # 2591960   Integration Enhancements
                                        Seperated logic to get dl/cl std code to a new procedure
   pmarada              23-Aug-2001     Get Enrollmen, Grade-level dtls
                                        from FA-Base-Hist table
                                        Enh Bug 1818617
   skoppula             29-May-2002     The class standing shall be picked
                                        up from igf_aw_packng_subfns.get_class_stnd
                         instead from igf_ap_fa_base_h. This is
                         done to determine which class standing
                         to be used - Actual or Predictive
                         Bug:2385334
 ***************************************************************/

     CURSOR c_cal_seq (cp_baseid NUMBER) IS
        SELECT ci_cal_type, ci_sequence_number
        FROM   igf_ap_fa_base_rec
        WHERE  base_id = cp_baseid;

     CURSOR c_awd_yr (cp_cal_type         igs_ca_inst.cal_type%TYPE ,
                      cp_sequence_number  igs_ca_inst.sequence_number%TYPE) IS
        SELECT alternate_code
        FROM   igs_ca_inst
        WHERE  cal_type = cp_cal_type
        AND    sequence_number = cp_sequence_number ;

      l_person_number      igf_ap_fa_con_v.person_number%TYPE;
      l_alternate_code     igs_ca_inst_all.alternate_code%TYPE;
      l_cal_seq_rec        c_cal_seq%ROWTYPE;
      l_ci_cal_type        igf_ap_fa_base_rec_all.ci_cal_type%TYPE;
      l_ci_sequence_number igf_ap_fa_base_rec_all.ci_sequence_number%TYPE;


       -- Declarations as part of bug 2385334
       lv_class_standing        igs_pr_css_class_std_v.class_standing%TYPE;
       lv_program_type          igs_ps_ver_all.course_type%TYPE;
       -- defined for Integration Enhancements build
       lv_dl_std_code           igf_ap_class_std_map.dl_std_code%TYPE;
       lv_cl_std_code           igf_ap_class_std_map.dl_std_code%TYPE;

BEGIN

        lv_dl_std_code := NULL;
        lv_cl_std_code := NULL;
        p_anticip_comp_date := igf_ap_gen_001.get_anticip_compl_date(P_base_id);

        OPEN  c_cal_seq (p_base_id);
        FETCH c_cal_seq INTO l_cal_seq_rec;
        CLOSE c_cal_seq;
        l_ci_cal_type        := l_cal_seq_rec.ci_cal_type;
        l_ci_sequence_number := l_cal_seq_rec.ci_sequence_number;

        OPEN  c_awd_yr (l_ci_cal_type, l_ci_sequence_number);
        FETCH c_awd_yr INTO l_alternate_code;
        CLOSE c_awd_yr;

        l_person_number := igf_gr_gen.get_per_num ( p_base_id);
        -- Call to get the class standing and program_type
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.return_entities.debug','The values passed to igf_aw_packng_subfns.get_class_stnd base id :' || p_base_id);
         END IF;

         lv_class_standing := igf_aw_packng_subfns.get_class_stnd( p_base_id,
                                                                   g_person_id,
                                                                   g_adplans_id,
                                                                   g_award_id,
                                                                   lv_program_type ) ;
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.return_entities.debug','The class standing from igf_aw_packng_subfns.get_class_stnd :' || lv_class_standing);
         END IF;

        IF lv_class_standing IS NULL OR lv_program_type IS  NULL THEN
          -- Bug # 5078693 - bvisvana - Message out that Class standing has to be defined.
          fnd_message.set_name('IGF','IGF_SL_NO_CLSTND');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          RAISE SKIP_THIS_RECORD;
        END IF;
        -- Call to get the dl_std_code
        get_dl_cl_std_code ( p_base_id,
                             lv_class_standing,
                             lv_program_type ,
                             lv_dl_std_code ,
                             lv_cl_std_code );

        IF lv_dl_std_code IS NULL THEN
          -- Bug 5078693 - bvisvana
          fnd_message.set_name('IGF','IGF_SL_NO_CLSTND_GRDLVL');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
        ELSE
             p_grd_dl := lv_dl_std_code ;
        END IF ;

        IF lv_cl_std_code IS NULL THEN
          -- Bug 5078693 - bvisvana
          fnd_message.set_name('IGF','IGF_SL_NO_CLSTND_GRDLVL');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
        ELSE
             p_grd_cl := lv_cl_std_code ;
        END IF ;

EXCEPTION
   WHEN SKIP_THIS_RECORD THEN
      RAISE SKIP_THIS_RECORD;
   WHEN NO_DATA_FOUND THEN
     NULL;
END return_entities;

PROCEDURE get_fa_base_details(p_base_id           IN   igf_ap_fa_base_rec.base_id%TYPE,
                              p_s_default_status  OUT NOCOPY  igf_sl_lor.s_default_status%TYPE,
                              p_grade_dl          OUT NOCOPY  igf_sl_lor.grade_level_code%TYPE,
                              p_grade_cl          OUT NOCOPY  igf_sl_lor.grade_level_code%TYPE,
                              p_enroll_code       OUT NOCOPY  igf_sl_lor.enrollment_code%TYPE,
                              p_isir_present      OUT NOCOPY  BOOLEAN,
                              p_anticip_comp_date OUT NOCOPY  igf_sl_lor.anticip_compl_date%TYPE,
                              p_transaction_num   OUT NOCOPY  igf_ap_isir_matched_all.transaction_num%TYPE,
                              p_unsub_elig_for_depnt OUT NOCOPY igf_sl_lor.unsub_elig_for_depnt%TYPE
                              )
IS
  /***************************************************************
   Created By       :    mesriniv
   Date Created By  :    2000/11/15
   Purpose          :    Return the nslds flag match status,
                                Grade Level, Enrollment Code
                         for the Current Base Id
   Known Limitations,Enhancements or Remarks
   Change History   :
   Who              When      What
 ***************************************************************/

  lv_s_default_status          igf_sl_lor_all.s_default_status%TYPE;
  lv_match_flag                igf_ap_isir_matched_all.nslds_match_flag%TYPE;
  lv_nslds_data_override_flg   igf_ap_fa_base_rec_all.nslds_data_override_flg%TYPE;
  lv_adnl_unsub_loan_elig_flag igf_ap_fa_base_rec_all.adnl_unsub_loan_elig_flag%TYPE;

CURSOR cur_nslds_data IS
  SELECT isirm.nslds_match_flag,  NVL(fabase.nslds_data_override_flg,'N'),isirm.transaction_num,
         NVL(fabase.adnl_unsub_loan_elig_flag,'N')  adnl_unsub_loan_elig_flag -- FA134
    FROM igf_ap_isir_matched_all isirm,
         igf_ap_fa_base_rec_all  fabase
   WHERE fabase.base_id = p_base_id
     AND fabase.base_id = isirm.base_id
     AND isirm.payment_isir = 'Y'
     AND isirm.system_record_type = 'ORIGINAL';

BEGIN
  p_isir_present := FALSE;

  OPEN cur_nslds_data;
  FETCH cur_nslds_data INTO lv_match_flag,
                            lv_nslds_data_override_flg, p_transaction_num, lv_adnl_unsub_loan_elig_flag;--fa134
  IF  cur_nslds_data%NOTFOUND  THEN
      p_isir_present := FALSE;
  ELSE
    IF lv_nslds_data_override_flg='Y' THEN
       lv_s_default_status:='Z';
    ELSE
      IF lv_match_flag='1' THEN
         lv_s_default_status:='N';
      ELSIF lv_match_flag IN ('2','3','4','7','8') THEN
         lv_s_default_status:='Y';
      END IF;
    END IF;
    p_isir_present := TRUE;
  END IF;

  CLOSE cur_nslds_data;

  p_s_default_status := lv_s_default_status;
  return_entities(p_base_id, p_grade_dl, p_enroll_code, p_grade_cl,p_anticip_comp_date);

EXCEPTION
  WHEN SKIP_THIS_RECORD THEN
    RAISE SKIP_THIS_RECORD;
  WHEN OTHERS THEN
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_LAR_CREATION.GET_FA_BASE_DETAILS');
    fnd_file.put_line(fnd_file.log,SQLERRM);
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END get_fa_base_details;



/* Procedure to insert Direct Loan Originations into IGF_SL_LOR */

PROCEDURE insert_lor_dl_records(
  p_cal_type                  IN    igs_ca_inst.cal_type%TYPE,
  p_sequence_number           IN    igs_ca_inst.sequence_number%TYPE,
  p_loan_id                   IN    igf_sl_loans.loan_id%TYPE
)AS
/***************************************************************
   Created By       :    mesriniv
   Date Created By  :    2000/11/13
   Purpose          :    To Insert Records into IGF_SL_LOR for DL Loans
   Known Limitations,Enhancements or Remarks

   Change History   :
   Who              When      What
   bvisvana         10-Apr-2006   Build FA161.
                                  TBH impact change in igf_sl_lor_pkg.insert_row().
   pkpatel             12-05-2001     Given default value for the parameter
                           pnote_status
 ***************************************************************/
CURSOR getloannumber (cp_loan_id NUMBER) is
      SELECT LOAN_NUMBER
	FROM IGF_SL_LOANS_ALL lar
	WHERE lar.LOAN_ID = cp_loan_id;

  lv_row_id            ROWID;
  ln_origination_id    igf_sl_lor_all.origination_id%TYPE;
  ld_sch_cert_date     DATE;
  lv_orig_fee_perct    igf_sl_dl_setup_all.orig_fee_perct_stafford%TYPE;
  lv_match_flag        igf_ap_isir_matched_all.nslds_match_flag%TYPE;
  lv_acad_cal_type        igs_ca_inst_all.cal_type%TYPE ;
  lv_acad_seq_num         igs_ca_inst_all.sequence_number%TYPE;
  lv_acad_begin_date      igs_ca_inst_all.start_dt%TYPE;
  lv_acad_end_date        igs_ca_inst_all.end_dt%TYPE;
  lv_message              VARCHAR2(100);
  c_loan_number             getloannumber%ROWTYPE;
  l_parent_person_id          NUMBER;
  l_student_person_id         NUMBER;

BEGIN

  -- Origination_Id will be populated from Sequence.
  -- Loan_Id is got from the Current value of sequence returned.
  -- Sch_cert_date is the Award Creation Date
OPEN getloannumber(p_loan_id);
  FETCH getloannumber INTO c_loan_number;
  CLOSE getloannumber;

  igf_sl_dl_record.get_acad_cal_dtls (c_loan_number.LOAN_NUMBER,
                       lv_acad_cal_type,
                       lv_acad_seq_num,
                       lv_acad_begin_date,
                       lv_acad_end_date,
                       lv_message );

  -- bvisvana - Bug 5078761
  IF lv_message IS NOT NULL THEN
      fnd_message.set_name(substr(lv_message,1,3),lv_message);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
  END IF;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_lor_dl_records.debug',' Acad Begin Date :' || lv_acad_begin_date);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_lor_dl_records.debug',' Acad End Date :' || lv_acad_end_date);
  END IF;

  IF igf_sl_gen.chk_dl_stafford(award_rec.fed_fund_code) = 'TRUE' THEN
     lv_orig_fee_perct := dl_setup_rec.orig_fee_perct_stafford;
  ELSIF igf_sl_gen.chk_dl_plus(award_rec.fed_fund_code) = 'TRUE' THEN
     lv_orig_fee_perct := dl_setup_rec.orig_fee_perct_plus;
  END IF;


    IF igf_sl_gen.chk_dl_plus(award_rec.fed_fund_code) = 'TRUE' THEN                   -- Check if that is plus/alt loans and get parent id for the same.
        get_borrower_parent_id (
                  p_loan_id                   =>  p_loan_id,
                  p_parent_person_id          =>  l_parent_person_id,
                  p_student_person_id         =>  l_student_person_id
                  );
    END IF;                                                                   -- END Check if that is plus/alt loans and get parent id for the same.



  -- With these Default values need to insert data into igf_sl_lor table
  lv_row_id := NULL;
  ln_origination_id := NULL;

  igf_sl_lor_pkg.insert_row (
      x_mode                              => 'R',
      x_rowid                             => lv_row_id,
      x_origination_id                    => ln_origination_id,
      x_loan_id                           => p_loan_id,
      x_sch_cert_date                     => TRUNC(award_rec.creation_date),
      x_orig_status_flag                  => NULL,
      x_orig_batch_id                     => NULL,
      x_orig_batch_date                   => NULL,
      x_chg_batch_id                      => NULL,
      x_orig_ack_date                     => NULL,
      x_credit_override                   => NULL,
      x_credit_decision_date              => NULL,
      x_req_serial_loan_code              => NULL,
      x_act_serial_loan_code              => NULL,
      x_pnote_delivery_code               => NULL,
      x_pnote_status                      => 'N',
      x_pnote_status_date                 => NULL,
      x_pnote_id                          => NULL,
      x_pnote_print_ind                   => dl_setup_rec.pnote_print_ind,
      x_pnote_accept_amt                  => NULL,
      x_pnote_accept_date                 => NULL,
      x_unsub_elig_for_heal               => 'N',
      x_disclosure_print_ind              => dl_setup_rec.disclosure_print_ind,
      x_orig_fee_perct                    => lv_orig_fee_perct,
      x_borw_confirm_ind                  => NULL,
      x_borw_interest_ind                 => NULL,
      x_borw_outstd_loan_code             => NULL,
      x_unsub_elig_for_depnt              => gv_unsub_elig_for_depnt,
      x_guarantee_amt                     => NULL,
      x_guarantee_date                    => NULL,
      x_guarnt_amt_redn_code              => NULL,
      x_guarnt_status_code                => NULL,
      x_guarnt_status_date                => NULL,
      x_lend_apprv_denied_code            => NULL,
      x_lend_apprv_denied_date            => NULL,
      x_lend_status_code                  => NULL,
      x_lend_status_date                  => NULL,
      x_guarnt_adj_ind                    => NULL,
      x_grade_level_code                  => g_grade_level_dl,
      x_enrollment_code                   => NULL,
      x_anticip_compl_date                => NULL,
      x_borw_lender_id                    => NULL,
      x_duns_borw_lender_id               => NULL,
      x_guarantor_id                      => NULL,
      x_duns_guarnt_id                    => NULL,
      x_prc_type_code                     => NULL,
      x_cl_seq_number                     => NULL,
      x_last_resort_lender                => NULL,
      x_lender_id                         => NULL,
      x_duns_lender_id                    => NULL,
      x_lend_non_ed_brc_id                => NULL,
      x_recipient_id                      => NULL,
      x_recipient_type                    => NULL,
      x_duns_recip_id                     => NULL,
      x_recip_non_ed_brc_id               => NULL,
      x_rec_type_ind                      => NULL,
      x_cl_loan_type                      => NULL,
      x_cl_rec_status                     => NULL,
      x_cl_rec_status_last_update         => NULL,
      x_alt_prog_type_code                => NULL,
      x_alt_appl_ver_code                 => NULL,
      x_mpn_confirm_code                  => NULL,
      x_resp_to_orig_code                 => NULL,
      x_appl_loan_phase_code              => NULL,
      x_appl_loan_phase_code_chg          => NULL,
      x_appl_send_error_codes             => NULL,
      x_tot_outstd_stafford               => NULL,
      x_tot_outstd_plus                   => NULL,
      x_alt_borw_tot_debt                 => NULL,
      x_act_interest_rate                 => NULL,
      x_service_type_code                 => NULL,
      x_rev_notice_of_guarnt              => NULL,
      x_sch_refund_amt                    => NULL,
      x_sch_refund_date                   => NULL,
      x_uniq_layout_vend_code             => NULL,
      x_uniq_layout_ident_code            => NULL,
      x_p_person_id                       => l_parent_person_id,        -- FA 157 -- derived single parent ID.
      x_p_ssn_chg_date                    => NULL,
      x_p_dob_chg_date                    => NULL,
      x_p_permt_addr_chg_date             => NULL,
      x_p_default_status                  => 'N',
      x_p_signature_code                  => NULL,
      x_p_signature_date                  => NULL,
      x_s_ssn_chg_date                    => NULL,
      x_s_dob_chg_date                    => NULL,
      x_s_permt_addr_chg_date             => NULL,
      x_s_local_addr_chg_date             => NULL,
      x_s_default_status                  => g_s_default_status,
      x_s_signature_code                  => NULL,
      x_pnote_batch_id                    => NULL,
      x_pnote_ack_date                    => NULL,
      x_pnote_mpn_ind                     => NULL,
      x_elec_mpn_ind                      => NULL,
      x_borr_sign_ind                     => NULL,
      x_stud_sign_ind                     => NULL,
      x_borr_credit_auth_code             => NULL,
      x_relationship_cd                   => NULL,   -- FA 122 Added this column
      x_interest_rebate_percent_num       => NVL(dl_setup_rec.int_rebate,0),
      x_cps_trans_num                     => gn_transaction_num,
      x_atd_entity_id_txt                 => gv_atd_entity_id_txt,
      x_rep_entity_id_txt                 => gv_rep_entity_id_txt,
      x_crdt_decision_status              => NULL,
      x_note_message                      => NULL,
      x_book_loan_amt                     => NULL,
      x_book_loan_amt_date                => NULL,
      x_pymt_servicer_amt                 => NULL,
      x_pymt_servicer_date                => NULL,
      x_requested_loan_amt                => g_accepted_amt,
      x_eft_authorization_code            => NULL,
      x_external_loan_id_txt              => NULL,
      x_deferment_request_code            => NULL,
      x_actual_record_type_code           => NULL,
      x_reinstatement_amt                 => NULL,
      x_school_use_txt                    => NULL,
      x_lender_use_txt                    => NULL,
      x_guarantor_use_txt                 => NULL,
      x_fls_approved_amt                  => NULL,
      x_flu_approved_amt                  => NULL,
      x_flp_approved_amt                  => NULL,
      x_alt_approved_amt                  => NULL,
      x_loan_app_form_code                => NULL,
      x_override_grade_level_code         => NULL,
      x_b_alien_reg_num_txt               => NULL,
      x_esign_src_typ_cd                  => NULL,
      x_acad_begin_date                   => lv_acad_begin_date,
      x_acad_end_date                     => lv_acad_end_date);

EXCEPTION
WHEN OTHERS THEN
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_LAR_CREATION.INSERT_LOR_DL_RECORDS');
    fnd_file.put_line(fnd_file.log,SQLERRM);
    igs_ge_msg_stack.add;
    app_exception.raise_exception;

END insert_lor_dl_records;


/* Procedure to insert into IGF_SL_LOR  for CL Loans*/

PROCEDURE insert_lor_cl_records(
  p_cal_type                  IN    igs_ca_inst.cal_type%TYPE,
  p_sequence_number           IN    igs_ca_inst.sequence_number%TYPE,
  p_loan_id                   IN    igf_sl_loans.loan_id%TYPE,
  p_comp_date                 IN    igf_sl_lor.anticip_compl_date%TYPE,
  p_grd_cl                    IN    igf_sl_lor.grade_level_code%TYPE
)AS

/***************************************************************
   Created By       :    mesriniv
   Date Created By  :    2000/11/13
   Purpose          :    To Insert Records into IGF_SL_LOR for CL Loans
   Known Limitations,Enhancements or Remarks

   Change History   :
   Who              When            What
   azmohamm         03-AUG-2006     For GPLUSFL, the new loan type would be 'GB'
                                    and the Federal application form Code would be 'G'.
                                    The borrower id is same as the student id.
                                    So while inserting into igf_sl_lor_all table person_id has to be the student's party id.
   rajagupt         10-Apr-2006     Bug# 5006583, FA161 CL4.
                                    cps_trans_num is inserted. deferment_request_code
                                    borw_interest_ind, borw_outstd_loan_code, p_default_status, s_default_status, stud_sign_ind
                                    are inserted with null and loan_app_form_code = 'Q' for FLP loans
   bvisvana         06-Jul-2005     Bug # 4473160. LOAN_NUMBER token set in the message
   pssahni          30-Dec-2004     Application form code must be populated
   bkkumar          02-04-04        FACR116 - Added the parameter to the pick_setup routine to check
                                    in teh case of 'ALT' Loans. Added validation to check if the alt_rel_code
                                    IS null or not.
   venagara         18-May-2001     Bug# 1769051
                                    For FLS,FLU, default cl_loan_type.
   bkkumar          29-sep-2003     FA 122 Loans Enhancements
                                    Derivation of the fields REQ_SERIAL_LOAN_CODE
                                    PNOTE_DELIVERY_CODE
                                    BORW_INTEREST_IND
                                    BORW_LENDER_ID
                                    DUNS_BORW_LENDER_ID  -- OBSOLETED THIS FIELD
                                    GUARANTOR_ID
                                    DUNS_GUARNT_ID  -- OBSOLETED THIS FIELD
                                    PRC_TYPE_CODE
                                    LENDER_ID
                                    DUNS_LENDER_ID  -- OBSOLETED THIS FIELD
                                    LEND_NON_ED_BRC_ID
                                    RECIPIENT_ID
                                    RECIPIENT_TYPE
                                    DUNS_RECIP_ID   -- OBSOLETED THIS FIELD
                                    RECIP_NON_ED_BRC_ID is now done from
                                    the FFELP loan Setup.
   bkkumar         06-oct-2003     Bug 3104228 Impact of adding the relationship_cd
                                   in igf_sl_lor_all table and obsoleting
                                   BORW_LENDER_ID,
                                   DUNS_BORW_LENDER_ID,
                                   GUARANTOR_ID,
                                   DUNS_GUARNT_ID,
                                   LENDER_ID, DUNS_LENDER_ID
                                   LEND_NON_ED_BRC_ID, RECIPIENT_ID
                                   RECIPIENT_TYPE,DUNS_RECIP_ID
                                   RECIP_NON_ED_BRC_ID columns
                                   Also the relationship code is now picked up from the
                                   pick_Setup routine.
 ***************************************************************/


ln_origination_id             igf_sl_lor.origination_id%TYPE;
lv_cl_loan_type               igf_sl_lor.cl_loan_type%TYPE;
ld_sch_cert_date              igf_sl_lor.sch_cert_date%TYPE;
lv_s_default_status           igf_sl_lor.s_default_status%TYPE;
lv_grade_level_code           igf_sl_lor.grade_level_code%TYPE;
lv_enrollment_code            igf_sl_lor.enrollment_code%TYPE;
lv_anticipated_compl_date     DATE;
lv_row_id                     ROWID;

ln_cur_loan_id                igf_sl_loans.loan_id%TYPE;
l_rel_code                    igf_sl_cl_setup.relationship_cd%TYPE;
l_party_id                    igf_sl_cl_setup.party_id%TYPE;
l_person_id                   igf_sl_cl_pref_lenders.person_id%TYPE;
l_loan_status  VARCHAR2(30);


-- cursor to get the base id from the loan id
CURSOR c_get_base_id (
                   cp_loan_id  igf_sl_loans.loan_id%TYPE
                   ) IS
SELECT awd.base_id, awd.award_id
FROM  igf_sl_loans_all loans,
      igf_aw_award_all awd
WHERE loans.loan_id = cp_loan_id
AND   loans.award_id = awd.award_id;

l_get_base_id  c_get_base_id%ROWTYPE;

-- cursor to get the loan details from the current FFELP set up used by the student
CURSOR c_clsetup (
                           cp_cal_type  igf_sl_cl_setup_v.ci_cal_type%TYPE,
                           cp_seq_number igf_sl_cl_setup_v.ci_sequence_number%TYPE,
                           cp_rel_code  igf_sl_cl_setup_v.relationship_cd%TYPE,
                           cp_party_id  igf_sl_cl_setup.party_id%TYPE
                          ) IS
SELECT *
FROM  igf_sl_cl_setup_all
WHERE ci_cal_type = cp_cal_type
AND   ci_sequence_number = cp_seq_number
AND   relationship_cd = cp_rel_code
AND   NVL(party_id,-1000) = NVL(cp_party_id,-1000);

c_clsetup_rec  c_clsetup%ROWTYPE;

 CURSOR c_disb_count (cp_award_id igf_aw_awd_disb_all.award_id%TYPE) IS
 SELECT COUNT(*)
 FROM  igf_aw_awd_disb_all
 WHERE award_id = cp_award_id;

 l_disb_count NUMBER;

 CURSOR c_tbh_loans_cur (cp_loanid NUMBER)  IS
 SELECT * FROM igf_sl_loans
 WHERE loan_id = cp_loanid;

  l_tbh_loans_rec    c_tbh_loans_cur%ROWTYPE;

  l_appl_form_code   igf_sl_lor_all.loan_app_form_code%TYPE;
  l_borw_interest_ind           igf_sl_lor.borw_interest_ind%TYPE;
  l_borw_outstd_loan_code       igf_sl_lor.borw_outstd_loan_code%TYPE;
  l_parent_person_id          NUMBER;
  l_student_person_id         NUMBER;
  l_cosigner_person_id        NUMBER;

  --Bug# 5006583
CURSOR cur_fa_mapping ( p_citizenship_status igf_sl_pe_citi_map.pe_citi_stat_code%TYPE,
                        p_cal_type igf_sl_pe_citi_map.ci_cal_type%TYPE,
                        p_sequence_number igf_sl_pe_citi_map.ci_sequence_number%TYPE ) IS
SELECT fa_citi_stat_code FROM igf_sl_pe_citi_map
WHERE pe_citi_stat_code = p_citizenship_status
AND ci_sequence_number =p_sequence_number
AND ci_cal_type = p_cal_type;

--Bug# 5006583
CURSOR cur_borrower_id (cp_loanid NUMBER) IS
SELECT p_person_id FROM igf_sl_lor_all
WHERE loan_id = cp_loanid;

--Bug# 5006583
CURSOR citizenship_dtl_cur (cp_person_id igf_sl_cl_pref_lenders.person_id%TYPE) IS
 SELECT
           pct.restatus_code
    FROM   igs_pe_eit_restatus_v  pct
    WHERE  pct.person_id    = cp_person_id
    AND  SYSDATE BETWEEN start_date AND NVL(end_date,SYSDATE);

l_cur_borrower_rec             cur_borrower_id%ROWTYPE;
l_cur_fa_rec                  cur_fa_mapping%ROWTYPE;
citizenship_dtl_rec           citizenship_dtl_cur%ROWTYPE;
alien_dtl_cur                 igf_sl_gen.person_dtl_cur;
alien_dtl_rec                 igf_sl_gen.person_dtl_rec;
l_b_alien_reg_num_txt         igf_sl_lor_all.b_alien_reg_num_txt%TYPE;
BEGIN

  -- Origination_Id will be populated from Sequence.
  -- Loan_Id is got from the Current value of sequence returned.
  -- Rec_type_ind value is A
  -- Defaulting loan status

  IF award_rec.fed_fund_code = 'FLU' THEN
       lv_cl_loan_type := 'SU';
  ELSIF award_rec.fed_fund_code = 'FLS' THEN
       lv_cl_loan_type := 'SF';
  ELSIF award_rec.fed_fund_code = 'FLP' THEN
     lv_cl_loan_type := 'PL';
  ELSIF award_rec.fed_fund_code = 'ALT' THEN
       lv_cl_loan_type := 'AL';
  ELSIF award_rec.fed_fund_code = 'GPLUSFL' THEN
       lv_cl_loan_type := 'GB';
  END IF;
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_lor_cl_records.debug','The fed_fund_code being used is :' || award_rec.fed_fund_code );
  END IF;

--  l_get_base_id := NULL;
  OPEN  c_get_base_id(p_loan_id);
  FETCH c_get_base_id INTO l_get_base_id;
  CLOSE c_get_base_id;
  -- FACR116 Grant Loan Changes
  IF lv_cl_loan_type = 'AL' THEN
    IF award_rec.alt_loan_code IS NULL THEN
      fnd_message.set_name('IGF','IGF_AW_NO_ALT_LOAN_CODE');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE SKIP_THIS_RECORD;
    END IF;
  END IF;

  l_rel_code := NULL;
  l_party_id := NULL;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_lor_cl_records.debug','The values passed to  pick_setup base_id :' || l_get_base_id.base_id );
   END IF;
   -- this will return the current active FFELP setup for this person
  igf_sl_award.pick_setup(l_get_base_id.base_id,p_cal_type,p_sequence_number,l_rel_code,l_person_id,l_party_id,award_rec.alt_rel_code);

  -- log the messages in the logging framework
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_lor_cl_records.debug','The values returned from pick setup RelCode :' || l_rel_code || ' The Party ID :' || l_party_id);
    END IF;

  -- if both the rel_code and party_id is null then raise the exception SKIP_THIS_RECORD
  IF l_rel_code IS NULL AND l_party_id IS NULL THEN
    fnd_message.set_name('IGF','IGF_SL_NO_CL_SETUP');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    RAISE SKIP_THIS_RECORD;
  END IF;

  -- get the deatils from the igf_sl_cl_setup table  for this relationship code and party id
--  c_clsetup_rec := NULL;
  OPEN  c_clsetup(p_cal_type,p_sequence_number,l_rel_code,l_party_id);
  FETCH c_clsetup INTO c_clsetup_rec;
  CLOSE c_clsetup;


  -- Get the Anticipated Completion Date of the Student.
  lv_anticipated_compl_date := p_comp_date;


     l_loan_status := 'G';
     gn_award_id := award_rec.award_id;
     OPEN c_disb_count(gn_award_id);
     FETCH c_disb_count INTO l_disb_count;
     CLOSE c_disb_count;

    OPEN c_tbh_loans_cur(p_loan_id);
    FETCH c_tbh_loans_cur INTO l_tbh_loans_rec;
    IF c_tbh_loans_cur%NOTFOUND THEN
      CLOSE c_tbh_loans_cur;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_tbh_loans_cur;

    IF (l_disb_count > 4 ) and (c_clsetup_rec.cl_version = 'RELEASE-4') THEN
      fnd_message.set_name('IGF','IGF_SL_CL4_NUM_OF_DISB_LOAN');
      fnd_message.set_token('LOAN_NUMBER',l_tbh_loans_rec.loan_number); -- bvisvana Bug # 4473160
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      l_loan_status := 'N';
    END IF;

    IF award_rec.fed_fund_code IN ('FLP', 'ALT') THEN                         -- Check if that is plus/alt loans and get parent id for the same.
        get_borrower_parent_id (
                  p_loan_id                  =>   p_loan_id,
                  p_parent_person_id         =>   l_parent_person_id,
                  p_student_person_id         =>  l_student_person_id
                  );
    END IF;                                                                   -- END Check if that is plus/alt loans and get parent id for the same.

    igf_sl_loans_pkg.update_row (
        x_mode                              => 'R',
        x_rowid                             => l_tbh_loans_rec.row_id,
        x_loan_id                           => l_tbh_loans_rec.loan_id,
        x_award_id                          => l_tbh_loans_rec.award_id,
        x_seq_num                           => l_tbh_loans_rec.seq_num,
        x_loan_number                       => l_tbh_loans_rec.loan_number,
        x_loan_per_begin_date               => l_tbh_loans_rec.loan_per_begin_date,
        x_loan_per_end_date                 => l_tbh_loans_rec.loan_per_end_date,
        x_loan_status                       => l_loan_status,
        x_loan_status_date                  => l_tbh_loans_rec.loan_status_date,
        x_loan_chg_status                   => l_tbh_loans_rec.loan_chg_status,
        x_loan_chg_status_date              => l_tbh_loans_rec.loan_chg_status_date,
        x_active                            => l_tbh_loans_rec.active,
        x_active_date                       => l_tbh_loans_rec.active_date ,
        x_borw_detrm_code                   => l_tbh_loans_rec.borw_detrm_code,
        x_legacy_record_flag                => l_tbh_loans_rec.legacy_record_flag,
        x_external_loan_id_txt              => l_tbh_loans_rec.external_loan_id_txt
      );

   -- With these values get loan details insert data into igf_sl_lor table
   lv_row_id         := NULL;
   ln_origination_id := NULL;

   -- Bug 4087865 Populate loan application form code
   l_appl_form_code := NULL;
   g_p_default_status := 'N';
    l_borw_interest_ind :=   c_clsetup_rec.borw_interest_ind;
    l_borw_outstd_loan_code  := 'N';

    IF award_rec.fed_fund_code = 'FLU' THEN
      l_appl_form_code := 'M';
    ELSIF award_rec.fed_fund_code = 'FLS' THEN
      l_appl_form_code := 'M';
    ELSIF award_rec.fed_fund_code = 'FLP' THEN
      l_appl_form_code := 'Q';
       l_borw_interest_ind := NULL;
       l_borw_outstd_loan_code := NULL;
       g_p_default_status := NULL;
       g_s_default_status := NULL;
    ELSIF award_rec.fed_fund_code = 'ALT' THEN
      l_appl_form_code := NULL;
      l_cosigner_person_id := l_parent_person_id;
      l_parent_person_id := award_rec.person_id;          -- FA 157 - For ALT loans, student is default borrower.
      g_p_default_status := g_s_default_status;           -- bvisvana 4127532 - p_default_stauts = s_default_status
    ELSIF award_rec.fed_fund_code = 'GPLUSFL' THEN
       l_appl_form_code := 'G';
       l_parent_person_id := award_rec.person_id;
       l_borw_interest_ind := NULL;
       l_borw_outstd_loan_code := NULL;
       g_p_default_status := NULL;
       g_s_default_status := NULL;
    END IF;

    -- l_parent_person_id holds the Borrower..(for ALT l_parent_person_id = student_id itself.)

    --Bug# 5006583,  FA161 CL4 -- Borrower Alien Regestration Number for FLP/ALT loans
    l_b_alien_reg_num_txt := NULL;
    IF l_parent_person_id IS NOT NULL THEN
      OPEN citizenship_dtl_cur (l_parent_person_id);                   --get borrower citizenship status
      FETCH citizenship_dtl_cur INTO citizenship_dtl_rec;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_lor_cl_records.debug','Borrower citizenship status is ' || citizenship_dtl_rec.restatus_code );
      END IF;
      IF citizenship_dtl_cur%FOUND THEN
        --get FA Citizenship Status Code
        OPEN cur_fa_mapping (p_citizenship_status => citizenship_dtl_rec.restatus_code,
                             p_cal_type           => p_cal_type,
                             p_sequence_number    => p_sequence_number);
        FETCH cur_fa_mapping INTO l_cur_fa_rec;
        CLOSE cur_fa_mapping;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_lor_cl_records.debug','Borrower Alein reg number is ' || l_cur_fa_rec.fa_citi_stat_code);
        END IF;

        IF NVL(l_cur_fa_rec.fa_citi_stat_code,'*') = '2' THEN
          igf_sl_gen.get_person_details(l_parent_person_id, alien_dtl_cur);         --get Alein reg number
          FETCH alien_dtl_cur INTO alien_dtl_rec;
          IF alien_dtl_cur%FOUND THEN
            l_b_alien_reg_num_txt := alien_dtl_rec.p_alien_reg_num;
          END IF;
          CLOSE alien_dtl_cur;
        END IF;
      END IF; -- End of "IF citizenship_dtl_cur%FOUND THEN"
      CLOSE citizenship_dtl_cur;
   END IF; --End of "IF l_parent_person_id IS NOT NULL THEN"


   igf_sl_lor_pkg.insert_row (
      x_mode                              => 'R',
      x_rowid                             => lv_row_id,
      x_origination_id                    => ln_origination_id,
      x_loan_id                           => p_loan_id,
      x_sch_cert_date                     => TRUNC(award_rec.creation_date),
      x_orig_status_flag                  => NULL,
      x_orig_batch_id                     => NULL,
      x_orig_batch_date                   => NULL,
      x_chg_batch_id                      => NULL,
      x_orig_ack_date                     => NULL,
      x_credit_override                   => NULL,
      x_credit_decision_date              => NULL,
      x_req_serial_loan_code              => c_clsetup_rec.req_serial_loan_code,
      x_act_serial_loan_code              => NULL,
      x_pnote_delivery_code               => c_clsetup_rec.pnote_delivery_code,
      x_pnote_status                      => NULL,
      x_pnote_status_date                 => NULL,
      x_pnote_id                          => NULL,
      x_pnote_print_ind                   => NULL,
      x_pnote_accept_amt                  => NULL,
      x_pnote_accept_date                 => NULL,
      x_unsub_elig_for_heal               => NULL,
      x_disclosure_print_ind              => NULL,
      x_orig_fee_perct                    => NULL,
      x_borw_confirm_ind                  => NULL,
      x_borw_interest_ind                 => l_borw_interest_ind,
      x_borw_outstd_loan_code             => l_borw_outstd_loan_code,
      x_unsub_elig_for_depnt              => gv_unsub_elig_for_depnt,
      x_guarantee_amt                     => NULL,
      x_guarantee_date                    => NULL,
      x_guarnt_amt_redn_code              => NULL,
      x_guarnt_status_code                => NULL,
      x_guarnt_status_date                => NULL,
      x_lend_apprv_denied_code            => NULL,
      x_lend_apprv_denied_date            => NULL,
      x_lend_status_code                  => NULL,
      x_lend_status_date                  => NULL,
      x_guarnt_adj_ind                    => NULL,
      x_grade_level_code                  => p_grd_cl,
      x_enrollment_code                   => g_enrollment_code,
      x_anticip_compl_date                => lv_anticipated_compl_date,
      x_borw_lender_id                    => NULL,
      x_duns_borw_lender_id               => NULL,
      x_guarantor_id                      => NULL,
      x_duns_guarnt_id                    => NULL,
      x_prc_type_code                     => c_clsetup_rec.prc_type_code,
      x_cl_seq_number                     => NULL,
      x_last_resort_lender                => NULL,
      x_lender_id                         => NULL,
      x_duns_lender_id                    => NULL,
      x_lend_non_ed_brc_id                => NULL,
      x_recipient_id                      => NULL,
      x_recipient_type                    => NULL,
      x_duns_recip_id                     => NULL,
      x_recip_non_ed_brc_id               => NULL,
      x_rec_type_ind                      => 'A',
      x_cl_loan_type                      => lv_cl_loan_type,
      x_cl_rec_status                     => NULL,
      x_cl_rec_status_last_update         => NULL,
      x_alt_prog_type_code                => award_rec.alt_loan_code, -- FACR116
      x_alt_appl_ver_code                 => NULL,
      x_mpn_confirm_code                  => NULL,
      x_resp_to_orig_code                 => NULL,
      x_appl_loan_phase_code              => NULL,
      x_appl_loan_phase_code_chg          => NULL,
      x_appl_send_error_codes             => NULL,
      x_tot_outstd_stafford               => NULL,
      x_tot_outstd_plus                   => NULL,
      x_alt_borw_tot_debt                 => NULL,
      x_act_interest_rate                 => NULL,
      x_service_type_code                 => NULL,
      x_rev_notice_of_guarnt              => NULL,
      x_sch_refund_amt                    => NULL,
      x_sch_refund_date                   => NULL,
      x_uniq_layout_vend_code             => NULL,
      x_uniq_layout_ident_code            => NULL,
      x_p_person_id                       => l_parent_person_id,        -- FA 157 -- derived single parent ID.
      x_p_ssn_chg_date                    => NULL,
      x_p_dob_chg_date                    => NULL,
      x_p_permt_addr_chg_date             => NULL,
      x_p_default_status                  => g_p_default_status, -- Bug 4127532 -derived borr default status from student default status
      x_p_signature_code                  => NULL,
      x_p_signature_date                  => NULL,
      x_s_ssn_chg_date                    => NULL,
      x_s_dob_chg_date                    => NULL,
      x_s_permt_addr_chg_date             => NULL,
      x_s_local_addr_chg_date             => NULL,
      x_s_default_status                  => g_s_default_status,
      x_s_signature_code                  => NULL,
      x_pnote_batch_id                    => NULL,
      x_pnote_ack_date                    => NULL,
      x_pnote_mpn_ind                     => NULL,
      x_elec_mpn_ind                      => NULL,
      x_borr_sign_ind                     => NULL,
      x_stud_sign_ind                     => NULL,
      x_borr_credit_auth_code             => NULL,
      x_relationship_cd                   => l_rel_code,    -- FA 122 Added this column,
      x_interest_rebate_percent_num       => NULL,
      x_cps_trans_num                     => gn_transaction_num,   -- FA161
      x_atd_entity_id_txt                 => NULL,
      x_rep_entity_id_txt                 => NULL,
      x_crdt_decision_status              => NULL,
      x_note_message                      => NULL,
      x_book_loan_amt                     => NULL,
      x_book_loan_amt_date                => NULL,
      x_pymt_servicer_amt                 => NULL,
      x_pymt_servicer_date                => NULL,
      x_requested_loan_amt                => g_accepted_amt,
      x_eft_authorization_code            => c_clsetup_rec.eft_authorization,
      x_external_loan_id_txt              => NULL,
      x_deferment_request_code            => NULL,
      x_actual_record_type_code           => NULL,
      x_reinstatement_amt                 => NULL,
      x_school_use_txt                    => NULL,
      x_lender_use_txt                    => NULL,
      x_guarantor_use_txt                 => NULL,
      x_fls_approved_amt                  => NULL,
      x_flu_approved_amt                  => NULL,
      x_flp_approved_amt                  => NULL,
      x_alt_approved_amt                  => NULL,
      x_loan_app_form_code                => l_appl_form_code,
      x_override_grade_level_code         => NULL,
      x_b_alien_reg_num_txt               => l_b_alien_reg_num_txt,
      x_esign_src_typ_cd                  => NULL,
      x_acad_begin_date                   => NULL,
      x_acad_end_date                     => NULL
      );

    IF award_rec.fed_fund_code = 'ALT' THEN
      populate_cosigner_data(p_loan_id, l_cosigner_person_id);
    END IF;

  --
  -- update award if fees information has changed
  --
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_lor_cl_records.debug','before racalc fees');
   END IF;

     igf_sl_award.recalc_fees(
                             p_award_id        => l_get_base_id.award_id,
                             p_base_id         => l_get_base_id.base_id,
                             p_rel_code        => l_rel_code,
                             p_sequence_number => p_sequence_number,
                             p_cal_type        => p_cal_type);

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_lor_cl_records.debug','after racalc fees');
   END IF;


EXCEPTION
WHEN SKIP_THIS_RECORD THEN
    RAISE SKIP_THIS_RECORD;
WHEN NO_DATA_FOUND THEN
    fnd_message.set_name('IGF','IGF_GE_NO_DATA_FOUND');
    fnd_message.set_token('NAME','IGF_SL_LAR_CREATION.INSERT_LOR_CL_RECORDS');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_lar_creation.insert_lor_cl_records.exception',SQLERRM);
    END IF;
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_LAR_CREATION.INSERT_LOR_CL_RECORDS');
    fnd_file.put_line(fnd_file.log,SQLERRM);
    igs_ge_msg_stack.add;
    app_exception.raise_exception;

END insert_lor_cl_records;


PROCEDURE update_loan_rec(p_award_id number,
                          p_fund_id number,
                          p_base_id number,
                          p_ci_cal_type igs_ca_inst_all.cal_type%TYPE,
                          p_ci_sequence_number igs_ca_inst_all.sequence_number%TYPE)
IS

  CURSOR cur_loan IS
SELECT loan.*,
       awd.adplans_id,
       fa.person_id,
       fcat.fed_fund_code,
       awd.base_id,
       awd.award_status,
       awd.accepted_amt,
       fmast.ci_cal_type,
       fmast.ci_sequence_number
  FROM igf_sl_loans_all loan,
       igf_aw_award_all awd,
       igf_aw_fund_mast_all fmast,
       igf_aw_fund_cat_all fcat,
       igf_ap_fa_base_rec_all fa
 WHERE loan.award_id = awd.award_id
   AND awd.fund_id = fmast.fund_id
   AND fmast.fund_code = fcat.fund_code
   AND fmast.ci_cal_type = p_ci_cal_type
   AND fmast.ci_sequence_number = p_ci_sequence_number
   AND awd.base_id = NVL (p_base_id, awd.base_id)
   AND awd.fund_id = NVL (p_fund_id, awd.fund_id)
   AND awd.award_id = NVL (p_award_id, awd.award_id)
   AND fa.base_id = NVL (p_base_id, awd.base_id)
   AND fa.ci_cal_type = fmast.ci_cal_type
   AND fa.ci_sequence_number = fmast.ci_sequence_number;

  lv_isir_present BOOLEAN ;
loan_title  VARCHAR2(1000);

  CURSOR c_tbh_cur (cp_loanid NUMBER)  IS
  SELECT * FROM igf_sl_lor
  WHERE loan_id = cp_loanid;

  l_tbh_rec    igf_sl_lor%ROWTYPE;

  CURSOR c_tbh_loans_cur (cp_loanid NUMBER)  IS
  SELECT * FROM igf_sl_loans
  WHERE loan_id = cp_loanid;

  l_tbh_loans_rec    c_tbh_loans_cur%ROWTYPE;

  lb_update                   Boolean;
  l_parent_person_id          NUMBER;
  l_student_person_id         NUMBER;
--Bug# 5006583
CURSOR cur_fa_mapping ( p_citizenship_status igf_sl_pe_citi_map.pe_citi_stat_code%TYPE,
                        p_cal_type igf_sl_pe_citi_map.ci_cal_type%TYPE,
                         p_sequence_number igf_sl_pe_citi_map.ci_sequence_number%TYPE ) IS
SELECT fa_citi_stat_code FROM igf_sl_pe_citi_map
WHERE pe_citi_stat_code = p_citizenship_status
AND ci_sequence_number =p_sequence_number
AND ci_cal_type = p_cal_type;

--Bug# 5006583
CURSOR cur_borrower_id (cp_loanid NUMBER) IS
SELECT p_person_id FROM igf_sl_lor_all
WHERE loan_id = cp_loanid;

--Bug# 5006583
CURSOR citizenship_dtl_cur (cp_person_id igf_sl_cl_pref_lenders.person_id%TYPE) IS
 SELECT
           pct.restatus_code
    FROM   igs_pe_eit_restatus_v  pct
    WHERE  pct.person_id    = cp_person_id
    AND  SYSDATE BETWEEN start_date AND NVL(end_date,SYSDATE);

l_cur_borrower_rec             cur_borrower_id%ROWTYPE;
l_cur_fa_rec                  cur_fa_mapping%ROWTYPE;
citizenship_dtl_rec           citizenship_dtl_cur%ROWTYPE;
l_rel_code                    igf_sl_cl_setup.relationship_cd%TYPE;
l_party_id                    igf_sl_cl_setup.party_id%TYPE;
l_person_id                   igf_sl_cl_pref_lenders.person_id%TYPE;
alien_dtl_cur                 igf_sl_gen.person_dtl_cur;
alien_dtl_rec                 igf_sl_gen.person_dtl_rec;

lv_acad_cal_type        igs_ca_inst_all.cal_type%TYPE ;
lv_acad_seq_num         igs_ca_inst_all.sequence_number%TYPE;
lv_message              VARCHAR2(100);

--Bug# 5006583
CURSOR get_parent_id_cur (cp_loan_id igf_sl_lor.loan_id%TYPE
                          ) IS
  SELECT
        'X'
    FROM
        igs_pe_relationships_v v,
        igf_aw_award_all awd,
        igf_sl_loans_all loans,
        igf_ap_fa_base_rec base
    WHERE
    base.person_id = v.object_ID
    AND base.base_id = awd.base_id
    AND awd.award_id = loans.award_id
    AND loans.loan_id = cp_loan_id
    AND
    RELATIONSHIP_CODE = 'PARENT_OF'
    AND trunc(SYSDATE) BETWEEN v.start_date and NVL(v.end_date, SYSDATE);


get_parent_id_rec    get_parent_id_cur%ROWTYPE;

BEGIN

FOR cur_loan_rec IN cur_loan LOOP

  BEGIN

    SAVEPOINT IGFSL01B_SP2;

    loan_title  := igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PROCESSING') || ' ' || igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS', 'LOAN_NUMBER') || ' :' || cur_loan_rec.loan_number;

    fnd_file.put_line(fnd_file.log, loan_title);

    g_adplans_id                := cur_loan_rec.adplans_id;
    g_person_id                 := cur_loan_rec.person_id;
    g_award_id                  := cur_loan_rec.award_id;
    g_s_default_status          :=  NULL;
    g_grade_level_dl            :=  NULL;
    g_enrollment_code           :=  NULL;
    g_anticip_compl_date        :=  NULL;
    g_grade_level_cl            :=  NULL;
    lv_isir_present             :=  TRUE;
    g_log_start_flag            :=  FALSE;
    gn_transaction_num          :=  NULL;
    gv_atd_entity_id_txt        :=  NULL;
    gv_rep_entity_id_txt        :=  NULL;
    gv_message                  :=  NULL;
    gv_return_status            :=  NULL;

  --derive depe status, entity id, for cur_loan_rec.base_id

    get_fa_base_details(cur_loan_rec.base_id, g_s_default_status, g_grade_level_dl,g_grade_level_cl,
                         g_enrollment_code,  lv_isir_present, g_anticip_compl_date,gn_transaction_num,gv_unsub_elig_for_depnt);

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug', 'after call to get_fa_base_details');
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug', 'g_s_default_status= ' || g_s_default_status);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug', 'g_grade_level_dl= ' || g_grade_level_dl);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug', 'g_grade_level_cl= ' || g_grade_level_cl);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug', 'g_enrollment_code= ' || g_enrollment_code);
      --fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug', 'lv_isir_present= ' || lv_isir_present);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug', 'g_anticip_compl_date= ' || g_anticip_compl_date);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug', 'gn_transaction_num= ' || gn_transaction_num);
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug', 'gv_unsub_elig_for_depnt= ' || gv_unsub_elig_for_depnt);
    END IF;

    OPEN c_tbh_cur(cur_loan_rec.loan_id);
    FETCH c_tbh_cur INTO l_tbh_rec;
    IF c_tbh_cur%NOTFOUND THEN
      CLOSE c_tbh_cur;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_tbh_cur;

    OPEN c_tbh_loans_cur(cur_loan_rec.loan_id);
    FETCH c_tbh_loans_cur INTO l_tbh_loans_rec;
    IF c_tbh_loans_cur%NOTFOUND THEN
      CLOSE c_tbh_loans_cur;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_tbh_loans_cur;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug', 'fed fund code is ' ||cur_loan_rec.fed_fund_code);
    END IF;

   IF cur_loan_rec.fed_fund_code in ('FLP','FLS','FLU','ALT','GPLUSFL') THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug', 'inside FFELP');
      END IF;

--Bug# 5006583
      IF cur_loan_rec.loan_status = 'S' OR (cur_loan_rec.loan_chg_status = 'S') THEN
         lb_update := FALSE;
        fnd_message.set_name('IGF','IGF_SL_LOAN_UPD_FAIL_SENT');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        RAISE SKIP_THIS_RECORD;

        ELSIF (cur_loan_rec.loan_status IN ('C','T')) OR (cur_loan_rec.loan_chg_status IN ('C','T')) THEN
        lb_update := FALSE;
        -- print updation failed mesg
         fnd_message.set_name('IGF','IGF_SL_LOAN_UPD_FAIL_CANCEL');
         fnd_file.put_line(fnd_file.log,fnd_message.get);

        RAISE SKIP_THIS_RECORD;
        ELSIF (cur_loan_rec.award_status IN ('CANCELLED')) THEN
        lb_update := FALSE;
        fnd_message.set_name('IGF','IGF_SL_CL_AW_CANC_SKIP_UPD'); -- print updation failed mesg Since Award is cancelled.
        fnd_file.put_line(fnd_file.log, fnd_message.get);

        RAISE SKIP_THIS_RECORD;
      ELSE
        lb_update := TRUE;

        -- Following FFELP fields need to be updated in LOR table down the line
        -- Dependency Status - Update
        -- Grade Level - Update.
        -- Enrollment Status - Update

        l_rel_code   := NULL;
        l_party_id   := NULL;
        l_person_id  := NULL;
        IF cur_loan_rec.fed_fund_code = 'FLP' THEN
        l_tbh_rec.loan_app_form_code           :='Q';
        l_tbh_rec.deferment_request_code       :=NULL;
        l_tbh_rec.borw_interest_ind            :=NULL;
        l_tbh_rec.borw_outstd_loan_code        :=NULL;
        l_tbh_rec.s_default_status             :=NULL;
        l_tbh_rec.p_default_status             :=NULL;
        l_tbh_rec.stud_sign_ind                :=NULL;
        l_tbh_rec.s_signature_code             :=NULL;
        ELSIF cur_loan_rec.fed_fund_code = 'GPLUSFL' THEN
          l_tbh_rec.loan_app_form_code  := 'G';
          l_tbh_rec.deferment_request_code       :=NULL;
          l_tbh_rec.borw_interest_ind            :=NULL;
          l_tbh_rec.borw_outstd_loan_code        :=NULL;
          l_tbh_rec.s_default_status             :=NULL;
          l_tbh_rec.p_default_status             :=NULL;
          l_tbh_rec.stud_sign_ind                :=NULL;
          l_tbh_rec.s_signature_code             :=NULL;
        ELSE
        l_tbh_rec.s_default_status  := g_s_default_status;
        END IF;
        igf_sl_award.pick_setup(cur_loan_rec.base_id,p_ci_cal_type,p_ci_sequence_number,l_rel_code,l_person_id,l_party_id,award_rec.alt_rel_code);


        IF l_tbh_rec.override_grade_level_code IS NULL THEN
        l_tbh_rec.grade_level_code := g_grade_level_cl;
        ELSE
         fnd_message.set_name('IGF','IGF_SL_CL_GRD_LEVEL_INVALID');
         fnd_file.put_line(fnd_file.log, fnd_message.get);
         END IF;
    --    l_tbh_rec.enrollment_code := g_enrollment_code;      -- updating enrollment_code with 'F'
        l_tbh_rec.cps_trans_num   :=  gn_transaction_num;
        l_tbh_rec.relationship_cd  :=   l_rel_code;
        l_tbh_rec.anticip_compl_date  := g_anticip_compl_date;
        l_tbh_rec.sch_cert_date        := TRUNC(sysdate);

        IF NVL(l_tbh_rec.requested_loan_amt,2) < NVL(cur_loan_rec.accepted_amt,1) THEN
        l_tbh_rec.requested_loan_amt := cur_loan_rec.accepted_amt;
        END IF;

        l_tbh_loans_rec.loan_per_begin_date := get_loan_start_dt(cur_loan_rec.award_id);
        l_tbh_loans_rec.loan_per_end_date := get_loan_end_dt(cur_loan_rec.award_id);



--Bug# 5006587,  FA161 CL4 -- Borrower Alien Regestration Number for FLP/ALT loans
IF cur_loan_rec.fed_fund_code IN ('FLP', 'ALT', 'GPLUSFL') THEN                         -- Check if that is plus/alt loans and get borrower id for the same if available.
    OPEN cur_borrower_id(cur_loan_rec.loan_id);                               --get borrower id
    FETCH cur_borrower_id INTO l_cur_borrower_rec;
    CLOSE cur_borrower_id;
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug','Borrower Id for the fed_fund_code is ' || l_cur_borrower_rec.p_person_id );
  END IF;
    l_tbh_rec.b_alien_reg_num_txt := NULL;
   IF l_cur_borrower_rec.p_person_id IS NOT NULL THEN
   OPEN citizenship_dtl_cur (l_cur_borrower_rec.p_person_id);                   --get borrower citizenship status
    FETCH citizenship_dtl_cur INTO citizenship_dtl_rec;
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug','Borrower citizenship status is ' || citizenship_dtl_rec.restatus_code );
  END IF;
      IF citizenship_dtl_cur%FOUND THEN

        OPEN cur_fa_mapping (citizenship_dtl_rec.restatus_code,         --get FA Citizenship Status Code
                                        p_ci_cal_type,
                                        p_ci_sequence_number);
        FETCH cur_fa_mapping INTO l_cur_fa_rec;
        CLOSE cur_fa_mapping;
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug','Borrower Alein reg number is ' || l_cur_fa_rec.fa_citi_stat_code);
  END IF;
         IF NVL(l_cur_fa_rec.fa_citi_stat_code,'*') = '2' THEN
          igf_sl_gen.get_person_details(l_cur_borrower_rec.p_person_id, alien_dtl_cur);         --get Alein reg number
          FETCH alien_dtl_cur INTO alien_dtl_rec;
           IF alien_dtl_cur%FOUND THEN
            l_tbh_rec.b_alien_reg_num_txt := alien_dtl_rec.p_alien_reg_num;
           END IF;
          CLOSE alien_dtl_cur;
         END IF;

      END IF;
      CLOSE citizenship_dtl_cur;
   END IF;
END IF;
        IF cur_loan_rec.loan_status = 'A' then
          l_tbh_loans_rec.loan_chg_status := 'G';

        ELSE
          l_tbh_loans_rec.loan_status := 'G';
        END IF;


    igf_sl_loans_pkg.update_row (
        x_mode                              => 'R',
        x_rowid                             => l_tbh_loans_rec.row_id,
        x_loan_id                           => l_tbh_loans_rec.loan_id,
        x_award_id                          => l_tbh_loans_rec.award_id,
        x_seq_num                           => l_tbh_loans_rec.seq_num,
        x_loan_number                       => l_tbh_loans_rec.loan_number,
        x_loan_per_begin_date               => l_tbh_loans_rec.loan_per_begin_date,
        x_loan_per_end_date                 => l_tbh_loans_rec.loan_per_end_date,
        x_loan_status                       => l_tbh_loans_rec.loan_status,
        x_loan_status_date                  => l_tbh_loans_rec.loan_status_date,
        x_loan_chg_status                   => l_tbh_loans_rec.loan_chg_status,
        x_loan_chg_status_date              => l_tbh_loans_rec.loan_chg_status_date,
        x_active                            => l_tbh_loans_rec.active,
        x_active_date                       => l_tbh_loans_rec.active_date ,
        x_borw_detrm_code                   => l_tbh_loans_rec.borw_detrm_code,
        x_legacy_record_flag                => l_tbh_loans_rec.legacy_record_flag,
        x_external_loan_id_txt              => l_tbh_loans_rec.external_loan_id_txt,
        x_called_from                       => 'UPDATE_MODE'                 --Bug# 5006587
      );
      END IF;
   END IF;

   IF cur_loan_rec.fed_fund_code in ('DLP','DLS','DLU') THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement, 'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug', 'inside FFELP');
      END IF;

      IF (cur_loan_rec.loan_status IN ('S','C','T')) OR (cur_loan_rec.loan_chg_status IN ('S','C','T')) THEN
         lb_update := FALSE;

        -- print updation failed mesg
         fnd_message.set_name('IGF','IGF_SL_LOAN_UPD_FAIL');
         fnd_file.put_line(fnd_file.log,fnd_message.get);

        RAISE SKIP_THIS_RECORD;
      ELSE
          lb_update                     := TRUE;

        -- update loans table
        l_tbh_loans_rec.loan_per_begin_date := get_loan_start_dt(cur_loan_rec.award_id);
        l_tbh_loans_rec.loan_per_end_date := get_loan_end_dt(cur_loan_rec.award_id);

        IF (l_tbh_loans_rec.loan_per_begin_date IS NULL OR l_tbh_loans_rec.loan_per_end_date IS NULL) THEN
          fnd_message.set_name('IGF','IGF_SL_ALL_CANCEL_DISB');
          fnd_message.set_token('VALUE',cur_loan_rec.award_id);
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          RAISE SKIP_THIS_RECORD;
        END IF;

          IF cur_loan_rec.loan_status = 'A' then
            -- Update Loan Change Status to "Ready to Send" and loan period
            l_tbh_loans_rec.loan_chg_status := 'G';
          END IF;

             igf_sl_loans_pkg.update_row (
              x_mode                              => 'R',
              x_rowid                             => l_tbh_loans_rec.row_id,
              x_loan_id                           => l_tbh_loans_rec.loan_id,
              x_award_id                          => l_tbh_loans_rec.award_id,
              x_seq_num                           => l_tbh_loans_rec.seq_num,
              x_loan_number                       => l_tbh_loans_rec.loan_number,
              x_loan_per_begin_date               => l_tbh_loans_rec.loan_per_begin_date, -- this is getting updated
              x_loan_per_end_date                 => l_tbh_loans_rec.loan_per_end_date, -- this is getting updated
              x_loan_status                       => l_tbh_loans_rec.loan_status,
              x_loan_status_date                  => l_tbh_loans_rec.loan_status_date,
              x_loan_chg_status                   => l_tbh_loans_rec.loan_chg_status, -- this is getting updated
              x_loan_chg_status_date              => l_tbh_loans_rec.loan_chg_status_date,
              x_active                            => l_tbh_loans_rec.active,
              x_active_date                       => l_tbh_loans_rec.active_date ,
              x_borw_detrm_code                   => l_tbh_loans_rec.borw_detrm_code,
              x_legacy_record_flag                => l_tbh_loans_rec.legacy_record_flag,
              x_external_loan_id_txt              => l_tbh_loans_rec.external_loan_id_txt
             );

        -- Following DL fields need to be updated in LOR table down the line
        -- Dependency Status - Update
        -- Grade Level - No Update, override is present.
        -- Entity ID - Update
        -- ISIR Transaction Number - Update

        l_tbh_rec.s_default_status := g_s_default_status;
        l_tbh_rec.grade_level_code := g_grade_level_dl;
        l_tbh_rec.cps_trans_num := gn_transaction_num;

        -- Get Entity IDs
        get_dl_entity_id(cur_loan_rec.base_id, cur_loan_rec.ci_cal_type, cur_loan_rec.ci_sequence_number,
                              gv_atd_entity_id_txt,gv_rep_entity_id_txt,gv_message,gv_return_status);
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug','The values returned from get_dl_entity_id gv_return_status :' || gv_return_status);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug','The values returned from get_dl_entity_id gv_message :' || gv_message);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug','The values returned from get_dl_entity_id gv_atd_entity_id_txt :' || gv_atd_entity_id_txt);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug','The values returned from get_dl_entity_id gv_rep_entity_id_txt :' || gv_rep_entity_id_txt);
        END IF;
        IF gv_return_status = 'E' THEN
          log_message(cur_loan_rec.award_id);
          fnd_file.put_line(fnd_file.log, gv_message);
          RAISE SKIP_THIS_RECORD;
        END IF;
        l_tbh_rec.atd_entity_id_txt := gv_atd_entity_id_txt;
        l_tbh_rec.rep_entity_id_txt := gv_rep_entity_id_txt;

      END IF; -- to update or not
      -- FA 163 : If acad begin date and end date are null, then re populate
      IF l_tbh_rec.acad_begin_date IS NULL
         OR l_tbh_rec.acad_end_date IS NULL THEN
           igf_sl_dl_record.get_acad_cal_dtls (l_tbh_loans_rec.loan_number,
                     lv_acad_cal_type,
                     lv_acad_seq_num,
                     l_tbh_rec.acad_begin_date,
                     l_tbh_rec.acad_end_date,
                     lv_message );
      END IF;
    END IF; -- fund is DL or not

     --FA 161 CL4 build, Populate borrower information based on the borrower specified in existing LOR
      IF cur_loan_rec.fed_fund_code IN ('FLP', 'DLP', 'ALT') THEN
        get_borrower_parent_id (
                    p_loan_id                  => l_tbh_rec.loan_id,
                    p_parent_person_id         => l_parent_person_id,
                    p_student_person_id        => l_student_person_id);
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug','The values returned from get_borrower_parent_id l_parent_person_id :' || l_parent_person_id);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug','The values returned from get_borrower_parent_id l_student_person_id :' || l_student_person_id);
        END IF;
         -- FA 161 CL4 Build , If person has more than one parent then check whether the person id present has 'Parent of' relationship
          IF l_parent_person_id IS NULL AND l_tbh_rec.p_person_id IS NOT NULL THEN
            OPEN get_parent_id_cur (l_tbh_rec.loan_id );
            FETCH get_parent_id_cur INTO get_parent_id_rec;
            IF get_parent_id_cur%FOUND THEN
             l_parent_person_id := l_tbh_rec.p_person_id;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.update_loan_rec.debug','Parent id :' || l_parent_person_id);
        END IF;
            END IF;
            CLOSE get_parent_id_cur;
          END IF;
        IF cur_loan_rec.fed_fund_code <> 'ALT' THEN
          l_tbh_rec.p_person_id := l_parent_person_id;
        ELSE
          l_tbh_rec.p_person_id := l_student_person_id;
          -- bvisvana Bug # 4127532
          l_tbh_rec.p_default_status  := l_tbh_rec.s_default_status;
        END IF ;
     END IF;
                                                                        -- END Populate borrower information based on the borrower specified in existing LOR

   IF lb_update THEN
   igf_sl_lor_pkg.update_row(
          x_mode                              => 'R',
          x_rowid                             => l_tbh_rec.row_id,
          x_origination_id                    => l_tbh_rec.origination_id,
          x_loan_id                           => l_tbh_rec.loan_id,
          x_sch_cert_date                     => l_tbh_rec.sch_cert_date,
          x_orig_status_flag                  => l_tbh_rec.orig_status_flag,
          x_orig_batch_id                     => l_tbh_rec.orig_batch_id,
          x_orig_batch_date                   => l_tbh_rec.orig_batch_date,
          x_chg_batch_id                      => l_tbh_rec.chg_batch_id,
          x_orig_ack_date                     => l_tbh_rec.orig_ack_date,
          x_credit_override                   => l_tbh_rec.credit_override,
          x_credit_decision_date              => l_tbh_rec.credit_decision_date,
          x_req_serial_loan_code              => l_tbh_rec.req_serial_loan_code,
          x_act_serial_loan_code              => l_tbh_rec.act_serial_loan_code,
          x_pnote_delivery_code               => l_tbh_rec.pnote_delivery_code,
          x_pnote_status                      => l_tbh_rec.pnote_status,
          x_pnote_status_date                 => l_tbh_rec.pnote_status_date,
          x_pnote_id                          => l_tbh_rec.pnote_id,
          x_pnote_print_ind                   => l_tbh_rec.pnote_print_ind,
          x_pnote_accept_amt                  => l_tbh_rec.pnote_accept_amt,
          x_pnote_accept_date                 => l_tbh_rec.pnote_accept_date,
          x_pnote_batch_id                    => l_tbh_rec.pnote_batch_id,
          x_pnote_ack_date                    => l_tbh_rec.pnote_ack_date,
          x_pnote_mpn_ind                     => l_tbh_rec.pnote_mpn_ind,
          x_unsub_elig_for_heal               => l_tbh_rec.unsub_elig_for_heal,
          x_disclosure_print_ind              => l_tbh_rec.disclosure_print_ind,
          x_orig_fee_perct                    => l_tbh_rec.orig_fee_perct,
          x_borw_confirm_ind                  => l_tbh_rec.borw_confirm_ind,
          x_borw_interest_ind                 => l_tbh_rec.borw_interest_ind,
          x_borw_outstd_loan_code             => l_tbh_rec.borw_outstd_loan_code,
          x_unsub_elig_for_depnt              => l_tbh_rec.unsub_elig_for_depnt,
          x_guarantee_amt                     => l_tbh_rec.guarantee_amt,
          x_guarantee_date                    => l_tbh_rec.guarantee_date,
          x_guarnt_amt_redn_code              => l_tbh_rec.guarnt_amt_redn_code,
          x_guarnt_status_code                => l_tbh_rec.guarnt_status_code,
          x_guarnt_status_date                => l_tbh_rec.guarnt_status_date,
          x_lend_apprv_denied_code            => l_tbh_rec.lend_apprv_denied_code,
          x_lend_apprv_denied_date            => l_tbh_rec.lend_apprv_denied_date,
          x_lend_status_code                  => l_tbh_rec.lend_status_code,
          x_lend_status_date                  => l_tbh_rec.lend_status_date,
          x_guarnt_adj_ind                    => l_tbh_rec.guarnt_adj_ind,
          x_grade_level_code                  => l_tbh_rec.grade_level_code,
          x_enrollment_code                   => l_tbh_rec.enrollment_code,
          x_anticip_compl_date                => l_tbh_rec.anticip_compl_date,
          x_borw_lender_id                    => l_tbh_rec.borw_lender_id,
          x_duns_borw_lender_id               => l_tbh_rec.duns_borw_lender_id,
          x_guarantor_id                      => l_tbh_rec.guarantor_id,
          x_duns_guarnt_id                    => l_tbh_rec.duns_guarnt_id,
          x_prc_type_code                     => l_tbh_rec.prc_type_code,
          x_cl_seq_number                     => l_tbh_rec.cl_seq_number,
          x_last_resort_lender                => l_tbh_rec.last_resort_lender,
          x_lender_id                         => l_tbh_rec.lender_id,
          x_duns_lender_id                    => l_tbh_rec.duns_lender_id,
          x_lend_non_ed_brc_id                => l_tbh_rec.lend_non_ed_brc_id,
          x_recipient_id                      => l_tbh_rec.recipient_id,
          x_recipient_type                    => l_tbh_rec.recipient_type,
          x_duns_recip_id                     => l_tbh_rec.duns_recip_id,
          x_recip_non_ed_brc_id               => l_tbh_rec.recip_non_ed_brc_id,
          x_rec_type_ind                      => l_tbh_rec.rec_type_ind,
          x_cl_loan_type                      => l_tbh_rec.cl_loan_type,
          x_cl_rec_status                     => l_tbh_rec.cl_rec_status,
          x_cl_rec_status_last_update         => l_tbh_rec.cl_rec_status_last_update,
          x_alt_prog_type_code                => l_tbh_rec.alt_prog_type_code,
          x_alt_appl_ver_code                 => l_tbh_rec.alt_appl_ver_code,
          x_mpn_confirm_code                  => l_tbh_rec.mpn_confirm_code,
          x_resp_to_orig_code                 => l_tbh_rec.resp_to_orig_code,
          x_appl_loan_phase_code              => l_tbh_rec.appl_loan_phase_code,
          x_appl_loan_phase_code_chg          => l_tbh_rec.appl_loan_phase_code_chg,
          x_appl_send_error_codes             => l_tbh_rec.appl_send_error_codes,
          x_tot_outstd_stafford               => l_tbh_rec.tot_outstd_stafford,
          x_tot_outstd_plus                   => l_tbh_rec.tot_outstd_plus,
          x_alt_borw_tot_debt                 => l_tbh_rec.alt_borw_tot_debt,
          x_act_interest_rate                 => l_tbh_rec.act_interest_rate,
          x_service_type_code                 => l_tbh_rec.service_type_code,
          x_rev_notice_of_guarnt              => l_tbh_rec.rev_notice_of_guarnt,
          x_sch_refund_amt                    => l_tbh_rec.sch_refund_amt,
          x_sch_refund_date                   => l_tbh_rec.sch_refund_date,
          x_uniq_layout_vend_code             => l_tbh_rec.uniq_layout_vend_code,
          x_uniq_layout_ident_code            => l_tbh_rec.uniq_layout_ident_code,
          x_p_person_id                       => l_tbh_rec.p_person_id,
          x_p_ssn_chg_date                    => l_tbh_rec.p_ssn_chg_date,
          x_p_dob_chg_date                    => l_tbh_rec.p_dob_chg_date,
          x_p_permt_addr_chg_date             => l_tbh_rec.p_permt_addr_chg_date,
          x_p_default_status                  => l_tbh_rec.p_default_status,
          x_p_signature_code                  => l_tbh_rec.p_signature_code,
          x_p_signature_date                  => l_tbh_rec.p_signature_date,
          x_s_ssn_chg_date                    => l_tbh_rec.s_ssn_chg_date,
          x_s_dob_chg_date                    => l_tbh_rec.s_dob_chg_date ,
          x_s_permt_addr_chg_date             => l_tbh_rec.s_permt_addr_chg_date,
          x_s_local_addr_chg_date             => l_tbh_rec.s_local_addr_chg_date,
          x_s_default_status                  => l_tbh_rec.s_default_status,
          x_s_signature_code                  => l_tbh_rec.s_signature_code,
          x_elec_mpn_ind                      => l_tbh_rec.elec_mpn_ind,
          x_borr_sign_ind                     => l_tbh_rec.borr_sign_ind,
          x_stud_sign_ind                     => l_tbh_rec.stud_sign_ind,
          x_borr_credit_auth_code             => l_tbh_rec.borr_credit_auth_code,
          x_relationship_cd                   => l_tbh_rec.relationship_cd,
          x_interest_rebate_percent_num       => l_tbh_rec.interest_rebate_percent_num,
          x_cps_trans_num                     => l_tbh_rec.cps_trans_num,
          x_atd_entity_id_txt                 => l_tbh_rec.atd_entity_id_txt ,
          x_rep_entity_id_txt                 => l_tbh_rec.rep_entity_id_txt,
          x_crdt_decision_status              => l_tbh_rec.crdt_decision_status,
          x_note_message                      => l_tbh_rec.note_message,
          x_book_loan_amt                     => l_tbh_rec.book_loan_amt ,
          x_book_loan_amt_date                => l_tbh_rec.book_loan_amt_date,
          x_pymt_servicer_amt                 => l_tbh_rec.pymt_servicer_amt,
          x_pymt_servicer_date                => l_tbh_rec.pymt_servicer_date,
          x_requested_loan_amt                => l_tbh_rec.requested_loan_amt,
          x_eft_authorization_code            => l_tbh_rec.eft_authorization_code,
          x_external_loan_id_txt              => l_tbh_rec.external_loan_id_txt,
          x_deferment_request_code            => l_tbh_rec.deferment_request_code ,
          x_actual_record_type_code           => l_tbh_rec.actual_record_type_code,
          x_reinstatement_amt                 => l_tbh_rec.reinstatement_amt,
          x_school_use_txt                    => l_tbh_rec.school_use_txt,
          x_lender_use_txt                    => l_tbh_rec.lender_use_txt,
          x_guarantor_use_txt                 => l_tbh_rec.guarantor_use_txt,
          x_fls_approved_amt                  => l_tbh_rec.fls_approved_amt,
          x_flu_approved_amt                  => l_tbh_rec.flu_approved_amt,
          x_flp_approved_amt                  => l_tbh_rec.flp_approved_amt,
          x_alt_approved_amt                  => l_tbh_rec.alt_approved_amt,
          x_loan_app_form_code                => l_tbh_rec.loan_app_form_code,
          x_override_grade_level_code         => l_tbh_rec.override_grade_level_code,
          x_called_from                       => 'UPDATE_MODE',                 --Bug# 5006587
          x_b_alien_reg_num_txt               => l_tbh_rec.b_alien_reg_num_txt,
          x_esign_src_typ_cd                  => l_tbh_rec.esign_src_typ_cd,
          x_acad_begin_date                   => l_tbh_rec.acad_begin_date,
	  x_acad_end_date                     => l_tbh_rec.acad_end_date);

          IF cur_loan_rec.fed_fund_code = 'ALT' THEN
            populate_cosigner_data (p_loan_id       => l_tbh_rec.loan_id,
                                    p_person_id     => l_parent_person_id);
          END IF;
        END IF;

   EXCEPTION
   WHEN SKIP_THIS_RECORD THEN
        fnd_message.set_name('IGF','IGF_SL_SKIPPING');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        fnd_file.new_line(fnd_file.log,2);
        ROLLBACK TO IGFSL01B_SP2;
 WHEN OTHERS THEN
        -- Bug # 5079098  - This is to handle any exception thrown from other wrappers / proc / func / calls.
        -- Instead of throwing exception it needs to handled, skipped and continue with further loan records
        igs_ge_msg_stack.conc_exception_hndl;
        fnd_message.set_name('IGF','IGF_SL_SKIPPING');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        fnd_file.new_line(fnd_file.log,1);
        ROLLBACK TO IGFSL01B_SP2;
   END;

 END LOOP;

 EXCEPTION
        WHEN OTHERS THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_SL_LAR_CREATION.UPDATE_LOAN_REC');
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_lar_creation.update_loan_rec.exception','Exception:'||SQLERRM);
        END IF;
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

END  update_loan_rec;
-- FA 134

PROCEDURE create_loan_records(p_award_id number,
                          p_fund_id number,
                          p_base_id number,
                          p_ci_cal_type igs_ca_inst_all.cal_type%TYPE,
                          p_ci_sequence_number igs_ca_inst_all.sequence_number%TYPE,
                          p_dl_setup BOOLEAN,
                          p_cl_setup BOOLEAN)  IS
/*******************************************************************************
    Change History   :
    Who         When            What
    museshad    20-Feb-2006     Bug 5031795 - SQL Repository issue.
                                Modified cursor cur_count_fed_code for better
                                performance.
*******************************************************************************/
   CURSOR cur_awards_recs (p_award_id number, p_fund_id number, p_base_id number) IS
     SELECT  awdv.*
     FROM    igf_aw_award_v awdv
     WHERE   awdv.sys_fund_type ='LOAN'
     AND     awdv.ci_cal_type        = p_ci_cal_type
     AND     awdv.ci_sequence_number = p_ci_sequence_number
     AND     awdv.award_id           = NVL(p_award_id, awdv.award_id)
     AND     awdv.fund_id            = NVL(p_fund_id,  awdv.fund_id)
     AND     awdv.base_id            = NVL(p_base_id,  awdv.base_id) -- fa134
     AND     awdv.award_status       = 'ACCEPTED'
     AND     awdv.fed_fund_code IN ('DLP','DLS','DLU','FLP','FLS','FLU','ALT','GPLUSFL')
     AND     awdv.award_id NOT IN  ( SELECT loans.award_id
                                     FROM   igf_sl_loans_all loans )
     ORDER BY awdv.award_id;

   lv_isir_present BOOLEAN ;

   lb_print_dl BOOLEAN;
   lb_print_cl BOOLEAN;

   ln_seq_number             igf_sl_loans_all.seq_num%TYPE;
   l_msg_name     fnd_new_messages.message_name%TYPE;
   l_aid          NUMBER;
   l_loan_tab     igf_aw_packng_subfns.std_loan_tab;

   ld_loan_prd_start_dt      DATE;
   ld_loan_prd_end_dt        DATE;
   l_mapping                 VARCHAR2(1);

   CURSOR cur_count_fed_code IS
    SELECT COUNT(*) + 1
    FROM
          igf_sl_loans_all loan,
          igf_aw_award_all awd,
          igf_aw_fund_mast_all fmast,
          igf_aw_fund_cat_all fcat,
          igf_ap_fa_base_rec_all fabase
    WHERE
          loan.award_id = awd.award_id AND
          awd.fund_id = fmast.fund_id AND
          awd.base_id = fabase.base_id AND
          fcat.fund_code = fmast.fund_code AND
          fabase.ci_cal_type = award_rec.ci_cal_type AND
          fabase.ci_sequence_number = award_rec.ci_sequence_number AND
          fabase.person_id = award_rec.student_id AND
          fcat.fed_fund_code = award_rec.fed_fund_code;

   lv_loan_number            igf_sl_loans_all.loan_number%TYPE;

   lv_row_id                 ROWID;
   ln_loan_id                igf_sl_loans_all.loan_id%TYPE;
   l_head                    VARCHAR2(1);
   l_found_loans             VARCHAR2(1);
   l_fund_type               VARCHAR2(10);

BEGIN

   lb_print_dl   := TRUE;
   lb_print_cl   := TRUE;
   l_found_loans := 'N';
   l_head        := 'N';

   FOR award_rec_temp IN cur_awards_recs(p_award_id, p_fund_id, p_base_id) LOOP

   BEGIN

      SAVEPOINT IGFSL01B_SP1;

      fnd_file.put_line(fnd_file.log,g_process_log || ' ' || g_person_log ||' : ' || award_rec_temp.person_number);
      fnd_file.put_line(fnd_file.log,g_process_log || ' ' || g_award_log || ' : ' || award_rec_temp.award_id);


     IF award_rec_temp.fed_fund_code IN ('DLP','DLS','DLU') THEN
      IF NOT p_dl_setup THEN
        IF lb_print_dl THEN
         fnd_message.set_name('IGF','IGF_SL_NO_DL_SETUP');
         fnd_file.put_line(fnd_file.log,fnd_message.get);
         lb_print_dl := FALSE;
        END IF;
         RAISE SKIP_THIS_RECORD;
      END IF;
     END IF;

    IF award_rec_temp.fed_fund_code IN ('FLS','FLU','FLP','ALT','GPLUSFL') THEN
      IF NOT p_cl_setup THEN
        IF lb_print_cl THEN
         fnd_message.set_name('IGF','IGF_SL_NO_CL_SETUP');
         fnd_file.put_line(fnd_file.log,fnd_message.get);
         lb_print_cl := FALSE;
        END IF;
         RAISE SKIP_THIS_RECORD;
      END IF;
    END IF;

      -- Check the Loan Limts amounts for Loans other than DLP/FLP/ALT
      IF award_rec_temp.fed_fund_code NOT IN ('PRK','DLP','FLP','ALT','GPLUSFL') THEN
        l_aid := 0;
        l_msg_name := NULL;
      -- since the fund amount is already awarded to the student then l_aid is passed as 0.
        igf_aw_packng_subfns.check_loan_limits (
                                                l_base_id      => award_rec_temp.base_id,
                                                fund_type      => award_rec_temp.fed_fund_code,
                                                l_award_id     => award_rec_temp.award_id,
                                                l_adplans_id   => award_rec_temp.adplans_id,
                                                l_aid          => l_aid,
                                                l_std_loan_tab => l_loan_tab,
                                                p_msg_name     => l_msg_name
                                               );
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_loan_records.debug','The values returned from check_loan_limits l_aid :' || l_aid);
        END IF;
         -- If the returned l_aid is 0 with no message returned or l_aid is greater than 0 then
         -- the set up is fine otherwise show the corresponding error message in the log.
        IF l_msg_name IS NOT NULL THEN
          --Error has occured
          IF l_aid = 0 THEN
            -- Bug 5091652 - Treating no loan limit setup for class standings combinations as error
            fnd_message.set_name('IGF',l_msg_name);
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            RAISE SKIP_THIS_RECORD;
          ELSIF l_aid < 0 THEN
            -- Get the warning messages for the corresponding error messages. Bug 5064622
            -- These messages are to be treated as warnings only.
            IF l_msg_name = 'IGF_AW_AGGR_LMT_ERR' THEN
              l_msg_name := 'IGF_AW_AGGR_LMT_WARN';
            ELSIF l_msg_name = 'IGF_AW_ANNUAL_LMT_ERR' THEN
              l_msg_name := 'IGF_AW_ANNUAL_LMT_WARN';
            ELSIF l_msg_name = 'IGF_AW_SUB_AGGR_LMT_ERR' THEN
              l_msg_name := 'IGF_AW_SUB_AGGR_LMT_WARN';
            ELSIF l_msg_name = 'IGF_AW_SUB_LMT_ERR' THEN
              l_msg_name := 'IGF_AW_SUB_LMT_WARN';
            ELSIF l_msg_name = 'IGF_AW_UNSUB_AGGR_LMT_ERR' THEN
              l_msg_name := 'IGF_AW_UNSUB_AGGR_LMT_WRN';
            ELSIF l_msg_name = 'IGF_AW_UNSUB_LMT_ERR' THEN
              l_msg_name := 'IGF_AW_UNSUB_LMT_WARN';
            END IF;
            fnd_message.set_name('IGF',l_msg_name);
            fnd_message.set_token('FUND_CODE',award_rec_temp.fed_fund_code);
            fnd_file.put_line(fnd_file.log,fnd_message.get);
          END IF ;
         -- RAISE SKIP_THIS_RECORD;
        END IF;

      END IF; -- End Check the Loan Limts amounts for Loans other than DLP/FLP/ALT

      award_rec                   := award_rec_temp;
      g_adplans_id                := award_rec.adplans_id; -- Bug 4568942
      g_person_id                 := award_rec.person_id;
      g_award_id                  := award_rec.award_id;
      g_s_default_status          :=  NULL;
      g_grade_level_dl            :=  NULL;
      g_enrollment_code           :=  NULL;
      g_anticip_compl_date        :=  NULL;
      g_grade_level_cl            :=  NULL;
      lv_isir_present             :=  TRUE;
      g_log_start_flag            :=  FALSE;
      gn_transaction_num          :=  NULL;
      gv_atd_entity_id_txt        :=  NULL;
      gv_rep_entity_id_txt        :=  NULL;
      gv_message                  :=  NULL;
      gv_return_status            :=  NULL;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_loan_records.debug','The values passed to get_fabase_details Base_id :' || award_rec.base_id);
      END IF;
      -- Get the S_Default_status from NSLDS Matched Table, and
      -- also the Student Grade Level code and Enrollment Code

      get_fa_base_details(award_rec.base_id, g_s_default_status, g_grade_level_dl,g_grade_level_cl,
                                             g_enrollment_code,  lv_isir_present, g_anticip_compl_date,gn_transaction_num,gv_unsub_elig_for_depnt);


      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_loan_records.debug','The values returned from get_fabase_details Default Status :' || g_s_default_status);
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_loan_records.debug','The values returned from get_fabase_details Grade_level_cl :' || g_grade_level_cl);
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_loan_records.debug','The values returned from get_fabase_details Grade_level_dl :' || g_grade_level_dl);
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_loan_records.debug','The values returned from get_fabase_details Enrollment Code :' || g_enrollment_code);
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_loan_records.debug','The values returned from get_fabase_details anticip_compl_date :' || g_anticip_compl_date);
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_loan_records.debug','The values returned from get_fabase_details gn_transaction_num :' || gn_transaction_num);
      END IF;

      -- If the Award is a Loan and has a Fund-Source of FEDERAL, then
      -- Payment ISIR record should be present in the system for the Student.
      -- Else, the Loan Application record should not be created.

      IF igf_sl_gen.chk_dl_fed_fund_code(award_rec.fed_fund_code) = 'TRUE' THEN
         log_message(award_rec.award_id);
         IF gn_transaction_num IS NULL THEN
            fnd_message.set_name('IGF','IGF_AP_NOPAYMENT_ISIR');
            fnd_file.put_line(fnd_file.log, fnd_message.get);
            RAISE SKIP_THIS_RECORD;
         END IF;

-- MN 29-Dec-2004 Call get entity ids Only for Full Participant
         IF award_rec_temp.fed_fund_code in ('DLU', 'DLS', 'DLP') THEN
            l_fund_type := 'DL';
         ELSIF award_rec_temp.fed_fund_code = 'PELL' THEN
            l_fund_type := 'PELL';
         END IF;
         IF igf_sl_dl_validation.check_full_participant  (award_rec.ci_cal_type,
                                                          award_rec.ci_sequence_number,
                                                          l_fund_type) THEN
             get_dl_entity_id(award_rec.base_id,award_rec.ci_cal_type,award_rec.ci_sequence_number,
                              gv_atd_entity_id_txt,gv_rep_entity_id_txt,gv_message,gv_return_status);
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_loan_records.debug','The values returned from get_dl_entity_id gv_return_status :' || gv_return_status);
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_loan_records.debug','The values returned from get_dl_entity_id gv_message :' || gv_message);
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_loan_records.debug','The values returned from get_dl_entity_id gv_atd_entity_id_txt :' || gv_atd_entity_id_txt);
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_loan_records.debug','The values returned from get_dl_entity_id gv_rep_entity_id_txt :' || gv_rep_entity_id_txt);
             END IF;
         END IF;

         IF gv_return_status = 'E' THEN
           log_message(award_rec.award_id);
           fnd_file.put_line(fnd_file.log, gv_message);
           RAISE SKIP_THIS_RECORD;
         END IF;
      END IF;
      IF award_rec.fund_source = 'FEDERAL' AND lv_isir_present = FALSE THEN
          log_message(award_rec.award_id);
          -- Loan application record is not created as there is no Payment ISIR record for this federal loan
          fnd_message.set_name('IGF','IGF_SL_FEDLOAN_NO_FABASE');
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          RAISE SKIP_THIS_RECORD;

      END IF;

      IF award_rec.SSN IS NULL THEN

               log_message(award_rec.award_id);
               fnd_message.set_name('IGF','IGF_SL_NO_SSN_PRESENT');
               fnd_message.set_token('VALUE',award_rec.person_number);
               fnd_file.put_line(fnd_file.log, fnd_message.get);

               RAISE SKIP_THIS_RECORD;
      END IF;


      ld_loan_prd_start_dt  :=  get_loan_start_dt(award_rec.award_id);
      ld_loan_prd_end_dt    :=  get_loan_end_dt(award_rec.award_id);

      IF (ld_loan_prd_start_dt  IS NULL OR ld_loan_prd_end_dt IS NULL) THEN

               log_message(award_rec.award_id);
               fnd_message.set_name('IGF','IGF_SL_ALL_CANCEL_DISB');
               fnd_message.set_token('VALUE',award_rec.award_id);
               fnd_file.put_line(fnd_file.log, fnd_message.get);

               RAISE SKIP_THIS_RECORD;
      END IF;

      --Grade Level Code should be NOT NULL for both Direct Loan and CommonLine/ALT Loans
      --Enrollment Code should be NOT NULL for FFELP
      l_mapping:='Y';

  --
  -- sjadhav
  -- Bug 2415013
  -- Default Enrollment Code to Full Time
  --
      g_enrollment_code := 'F';
      -- Bug # 5078693 - bvisvana - If Grade level code is not determined it cud be due to missing grade level and class stnd mapping.
      -- Since same message applies , merging for all loan types
      IF  g_grade_level_dl IS NULL OR g_grade_level_cl IS NULL THEN
          IF award_rec.fed_fund_code IN ('DLP','DLS','DLU','FLP','FLS','FLU','ALT','GPLUSFL') THEN
             l_mapping:='N';
             fnd_message.set_name('IGF','IGF_SL_NO_CLSTND');
         END IF;
      END IF;

      IF l_mapping ='N'  THEN
          log_message(award_rec.award_id);
          fnd_message.set_token('PERSON_NUMBER',award_rec.person_number);
          fnd_message.set_token('AWARD_YEAR',award_rec.ci_alternate_code);
          fnd_file.put_line(fnd_file.log, fnd_message.get);

          RAISE SKIP_THIS_RECORD;

      END IF;

      -- To get the Seq No.value based on records available in IGF_SL_LOR
      ln_seq_number := 0;
      OPEN cur_count_fed_code;
      FETCH cur_count_fed_code INTO ln_seq_number;
      CLOSE cur_count_fed_code;

       -- To assign value of Loan Number using function
      lv_loan_number := NULL;
      lv_loan_number := ret_loan_number(ln_seq_number, award_rec.base_id);
      -- Insert these values into the IGF_SL_LOANS Table

     g_accepted_amt := award_rec.accepted_amt;
     gn_award_id    := award_rec.award_id;
     -- bvisvana - Bug # 4575843 - Before creating the loan record check whether the award accepted amount is in whole numbers
     IF ((g_accepted_amt - TRUNC(g_accepted_amt)) <> 0) THEN
       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_loan_records.debug',' g_accepted_amt is not a whole number');
       END IF;
      fnd_message.set_name('IGF','IGF_AW_ACCEPT_AMT_WHOLE_NUM');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      RAISE SKIP_THIS_RECORD;
     END IF;

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_loan_records.debug',' gn_award_id ' || gn_award_id);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_loan_records.debug',' g_accepted_amt : ' || g_accepted_amt);
     END IF;

  -- Modified the call of the IGF_SL_LOANS_PKG.INSERT_ROW to include the
  -- borrower determination code as part of Refunds DLD 2144600

      lv_row_id  := NULL;
      ln_loan_id := NULL;

      igf_sl_loans_pkg.insert_row (
        x_mode                              => 'R',
        x_rowid                             => lv_row_id,
        x_loan_id                           => ln_loan_id,
        x_award_id                          => award_rec.award_id,
        x_seq_num                           => ln_seq_number,
        x_loan_number                       => lv_loan_number,
        x_loan_per_begin_date               => ld_loan_prd_start_dt,
        x_loan_per_end_date                 => ld_loan_prd_end_dt,
        x_loan_status                       => 'G',
        x_loan_status_date                  => TRUNC(SYSDATE),
        x_loan_chg_status                   => NULL,
        x_loan_chg_status_date              => NULL,
        x_active                            => 'Y',
        x_active_date                       => TRUNC(SYSDATE),
        x_borw_detrm_code                   => NULL,
        x_legacy_record_flag                => NULL,
        x_external_loan_id_txt              => NULL
      );

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_loan_records.debug',' after insert of loan record ');
     END IF;

      -- Procedure call for Inserting Origination Records into IGF_SL_LOR

      IF igf_sl_gen.chk_dl_fed_fund_code(award_rec.fed_fund_code) = 'TRUE' THEN
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_loan_records.debug',' calling  insert_lor_dl_records');
         END IF;
         insert_lor_dl_records(p_ci_cal_type, p_ci_sequence_number, ln_loan_id);

      ELSIF igf_sl_gen.chk_cl_fed_fund_code(award_rec.fed_fund_code) = 'TRUE' THEN
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_loan_records.debug',' calling insert_lor_cl_records ');
            END IF;
            insert_lor_cl_records(p_ci_cal_type, p_ci_sequence_number, ln_loan_id, g_anticip_compl_date, g_grade_level_cl);
      END IF;

      --Display Heading in OutputFile
       IF l_head <> 'Y' THEN
          fnd_file.put_line(fnd_file.output,RPAD(g_year,40,' ')||': '||award_rec.ci_alternate_code);
          fnd_message.set_name('IGF','IGF_SL_EFF_DATES');
          fnd_message.set_token('EFF_DATES',RPAD(award_rec.ci_start_dt,15,' ')||'-'||LPAD(award_rec.ci_end_dt,15,' '));
          fnd_file.put_line(fnd_file.output,fnd_message.get);
          fnd_file.new_line(fnd_file.output,1);
          l_head := 'Y';
        END IF;

       fnd_file.new_line(fnd_file.output,1);
       fnd_file.put_line(fnd_file.output,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','FUND_CODE'),40,' ')||': '||award_rec.fund_code||'-'||award_rec.description);
       fnd_file.put_line(fnd_file.output,RPAD(g_person_log,40,' ')||': '||award_rec.person_number);
       fnd_file.put_line(fnd_file.output,RPAD(g_award_log,40,' ')||': '||award_rec.award_id);
       fnd_file.put_line(fnd_file.output,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','LOAN_NUMBER'),40,' ')||': '||lv_loan_number);
       fnd_file.put_line(fnd_file.output,RPAD(igf_aw_gen.lookup_desc('IGF_SL_LOAN_FIELDS','LOAN_AMT_OFFERED'),40,' ')||': '||award_rec.accepted_amt);

       -- Reassign Y that loan records are found
       IF l_found_loans <> 'Y' THEN
          l_found_loans := 'Y';
       END IF;

     EXCEPTION

     WHEN SKIP_THIS_RECORD THEN
          fnd_message.set_name('IGF','IGF_SL_SKIPPING');
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          fnd_file.new_line(fnd_file.log,2);
          ROLLBACK TO IGFSL01B_SP1;
     END;

    END LOOP;

    -- Bug 2324159 LAR Process to display LOG File Info
    -- Display appropriate message if Loans records are created

    IF l_found_loans ='Y' THEN
     --Loan Application Records created
     fnd_message.set_name('IGF','IGF_SL_LOANS_CREATED');
     fnd_file.put_line(fnd_file.log,fnd_message.get);
     fnd_file.new_line(fnd_file.log,2);
    ELSIF l_found_loans ='N' THEN
     --Loan Application not created
     fnd_message.set_name('IGF','IGF_SL_NO_LOANS');
     fnd_file.put_line(fnd_file.log,fnd_message.get);
     fnd_file.new_line(fnd_file.log,2);
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.insert_loan_records.debug',' End of create_loan_records ');
    END IF;

EXCEPTION

  WHEN OTHERS THEN
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_LAR_CREATION.create_loan_records');
    fnd_file.put_line(fnd_file.log,SQLERRM);
    igs_ge_msg_stack.add;
    app_exception.raise_exception;

END create_loan_records;


FUNCTION per_in_fa ( p_person_id            igf_ap_fa_base_rec_all.person_id%TYPE,
                     p_ci_cal_type          VARCHAR2,
                     p_ci_sequence_number   NUMBER,
                     p_base_id     OUT NOCOPY NUMBER
                    )
RETURN VARCHAR2
IS
        CURSOR cur_get_pers_num ( p_person_id  igf_ap_fa_base_rec_all.person_id%TYPE)
        IS
        SELECT person_number
        FROM   igs_pe_person_base_v
        WHERE
        person_id  = p_person_id;

        get_pers_num_rec   cur_get_pers_num%ROWTYPE;

        CURSOR cur_get_base (p_cal_type        igs_ca_inst_all.cal_type%TYPE,
                             p_sequence_number igs_ca_inst_all.sequence_number%TYPE,
                             p_person_id       igf_ap_fa_base_rec_all.person_id%TYPE)
        IS
        SELECT
        base_id
        FROM
        igf_ap_fa_base_rec_all
        WHERE
        person_id          = p_person_id AND
        ci_cal_type        = p_cal_type  AND
        ci_sequence_number = p_sequence_number;

BEGIN

        OPEN  cur_get_pers_num(p_person_id);
        FETCH cur_get_pers_num  INTO get_pers_num_rec;

        IF    cur_get_pers_num%NOTFOUND THEN
              CLOSE cur_get_pers_num;
              RETURN NULL;
        ELSE
              CLOSE cur_get_pers_num;
              OPEN  cur_get_base(p_ci_cal_type,p_ci_sequence_number,p_person_id);
              FETCH cur_get_base INTO p_base_id;
              CLOSE cur_get_base;

              RETURN get_pers_num_rec.person_number;

        END IF;

        EXCEPTION
        WHEN OTHERS THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_SL_DL_GEN_XML.PER_IN_FA');
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_dl_gen_xml.per_in_fa.exception','Exception:'||SQLERRM);
        END IF;
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END per_in_fa;

-- FA 134

/* MAIN PROCEDURE */

 PROCEDURE insert_loan_records(
  errbuf                           OUT NOCOPY  VARCHAR2,
  retcode                          OUT NOCOPY  NUMBER,
  p_award_year                     IN          VARCHAR2,
  p_run_mode                       IN          VARCHAR2,
  p_fund_id                        IN          NUMBER,
  p_dummy_1                        IN          NUMBER,
  p_base_id                        IN          NUMBER,
  p_dummy_2                        IN          NUMBER,
  p_award_id                       IN          NUMBER,
  p_dummy_3                        IN          NUMBER,
  p_dyn_pid_grp                    IN          NUMBER
  )
  AS

  /***************************************************************
   Created By       :    mesriniv
   Date Created By  :    2000/11/13
   Purpose          :    To  arrive at the default values for the various columns in
                         IGF_SL_LOANS
   Known Limitations,Enhancements or Remarks
   Change History   :
   Bug 2367953  Modify Parameters in Loans Process
   Who                 When             What
   ridas              08-Feb-2006     Bug #5021084. Added new parameter 'lv_group_type' in call to igf_ap_ss_pkg.get_pid
   tsailaja		        15/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
   bkkumar            04-04-04        FACR116 - Added a savepoint so that if the insert_lor procedures raises an
                                      exception then we have to rollback and display the appropriate message
   bkkumar           14-Jan-04        Bug# 3360702
                                      Passed the l_aid paramter as 0 to the check_loan_limits and also displayed the
                                      error message correctly.
                                      appropriate message.
   veramach            16-OCT-2003     Bug # 3108506 Added code to check loan limits before inserting loan records
   rasahoo             27-Aug-2003     Removed the call IGF_AP_OSS_PROCESS.GET_OSS_DETAILS,
                                       Changed the signature of procedure INSERT_LOAN_RECORDS,
                                       Removed the parameter P_GET_RECENT_INFO,
                                       as part of obsoletion of FA base record history
   mesriniv            20-may-2002     1.Added check for Grade Level Code in case of Direct Loans
                                       2.Added NVL for sch non ed brc id when arriving at loan number for CL Loans.
                                       3.Added call to remove any special characters from SSN while concatenating SSN
                                         in Loan Number
                                       4.Added new message for Grade Level Check for DL
   Bug 23241893 LAR Process  does not populate loan amount correctly
   Who                 When             What
   mesriniv           19-apr-2002       Added OFFERED Status in NOT IN condition of cursor cur_awards_rec.
   Bug No:  2324159
   Desc  :  LOAN APPLICATION PROCESS - LOG FILE DOES NOT DISPLAY ANY INFO
   Who                 When             What
   mesriniv            18-apr-2002      1.Added cursor cur_check_fund_award
                                        2.Initialized a variable l_found_loans to check and dsiplay
                                          info on loan records created or not.
                                        3.Added code to print list of person numbers having got the loan and details
                                        in Output File
   Bug No : 1978873
   Who                  When            What
   agairola             15-Mar-2002     Modified the call for the IGF_SL_LOANS_PKG.Insert_Row
                                        for Borrower Determination Code as part of Refunds DLD
                                        Enhancement No: 2144600
   ENH Bug No           :       1806850  Bug Desc:  Awards Build for Nov 2001 Rel
   Who               When                 What
   mesriniv             6-Jul-2001      W.r.to Awards Build Filtered
                                        Awards with award status
                                        as Declined,Cancelled or Simulated
                                        from creating Loans

 ***************************************************************/

  p_ci_cal_type             igs_ca_inst_all.cal_type%TYPE;
  p_ci_sequence_number      igs_ca_inst_all.sequence_number%TYPE;

  lv_loan_number            igf_sl_loans_all.loan_number%TYPE;

  lv_loan_status            igf_sl_loans_all.loan_status%TYPE;

  lv_row_id                 ROWID;
  lv_incr_date              NUMBER;
  l_found_loans             VARCHAR2(1);
  l_awd                     igf_aw_award_all.award_id%TYPE;
  l_fund                    igf_aw_fund_mast_all.fund_code%TYPE;
  l_head                    VARCHAR2(1);
  ln_rec_count              INTEGER;

  --For display of heading and parameters passed
  TYPE l_parameters IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
  l_para_rec l_parameters;

  -- for Fetching school Code for the Award Year
  CURSOR cur_dl_setup IS
     SELECT *
     FROM   igf_sl_dl_setup_all
     WHERE  ci_cal_type        = p_ci_cal_type
     AND    ci_sequence_number = p_ci_sequence_number;

  CURSOR cur_cl_setup IS
     SELECT *
     FROM   igf_sl_cl_setup_all
     WHERE  ci_cal_type        = p_ci_cal_type
     AND    ci_sequence_number = p_ci_sequence_number;

  --Cursor to get the alternate code for the calendar instance
  CURSOR cur_alternate_code IS
     SELECT ca.alternate_code,start_dt,end_dt
     FROM   igs_ca_inst ca
     WHERE  ca.cal_type =p_ci_cal_type
     AND    ca.sequence_number = p_ci_sequence_number;

  --Bug 23241893 LAR Process  does not populate loan amount correctly
  --Added OFFERED Status in NOT IN condition.


--Check if award exists
  CURSOR cur_check_fund_award (p_base_id NUMBER, p_award_id NUMBER, p_fund_id NUMBER, p_cal_type VARCHAR2, p_seq_number NUMBER)
  IS
     SELECT awd.award_id,fmast.fund_code
     FROM   igf_aw_award_all     awd,
            igf_aw_fund_mast_all fmast,
            igf_ap_fa_base_rec_all base,
            igf_aw_fund_cat_all   fcat
     WHERE  awd.fund_id  = fmast.fund_id
     AND    awd.base_id  = base.base_id
     AND    awd.award_status = 'ACCEPTED'
     AND    fmast.fund_code = fcat.fund_code
     AND    fcat.fed_fund_code IN ('DLP','DLS','DLU','FLP','FLS','FLU','ALT','GPLUSFL')
     AND    awd.award_id = NVL(p_award_id,awd.award_id)
     AND    awd.base_id  = NVL(p_base_id,awd.base_id)
     AND    awd.fund_id  = NVL(p_fund_id,awd.fund_id)
     AND    fmast.ci_cal_type = p_cal_type
     AND    fmast.ci_sequence_number = p_seq_number;

  check_fund_award_rec   cur_check_fund_award%ROWTYPE;
  --Get the Descriptions for the Parameters Passed:
  -- Get the details of
  CURSOR cur_get_parameters IS
     SELECT meaning
     FROM   igf_lookups_view
     WHERE  lookup_type = 'IGF_GE_PARAMETERS'
     AND    lookup_code IN ('AWARD_ID',
                            'AWARD_YEAR',
                            'FUND_CODE',
                            'GET_LATEST_OSS',
                            'PARAMETER_PASS',
                            'PERSON_ID_GROUP',
                            'PERSON_NUMBER',
                            'PROCESSING',
                            'RUN_MODE')
     ORDER  BY lookup_code;

    CURSOR cur_chk_pidgroup ( p_dyn_pid_grp NUMBER)
    IS
    SELECT group_id
    FROM   igs_pe_persid_group_all
    WHERE
    group_id   =  p_dyn_pid_grp AND
    closed_ind = 'N';

    chk_pidgroup_rec  cur_chk_pidgroup%ROWTYPE;

  l_msg_name     fnd_new_messages.message_name%TYPE;
  l_aid          NUMBER;
  l_loan_tab     igf_aw_packng_subfns.std_loan_tab;

  lb_dl_setup BOOLEAN;
  lb_cl_setup BOOLEAN;
  l_list      VARCHAR2(32767);

  TYPE cur_person_id_type IS REF CURSOR;
  cur_per_grp cur_person_id_type;

  lv_status VARCHAR2(1);
  l_person_id hz_parties.party_id%TYPE;
  lb_record_exist BOOLEAN;

  ln_base_id        NUMBER;
  lv_person_number  hz_parties.party_number%TYPE;
  lv_group_type     igs_pe_persid_group_v.group_type%TYPE;

BEGIN

  igf_aw_gen.set_org_id(NULL);
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.main.debug','Start of main');
  END IF;

  retcode        := 0;
  l_msg_name     := NULL;
  l_aid          := 0;
  l_loan_tab     := igf_aw_packng_subfns.std_loan_tab();
  l_found_loans  := 'N';
  l_head         := 'N';


  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.main.debug','Main inti');
  END IF;

  --Splitting the Award Year Value to ci_cal_type and ci_sequence_number
  p_ci_cal_type        := LTRIM(RTRIM(SUBSTR(p_award_year,1,10)));
  p_ci_sequence_number := TO_NUMBER(LTRIM(RTRIM(SUBSTR(p_award_year,11))));

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.main.debug','get award year cal type ' || p_ci_cal_type ||' seq num ' || p_ci_sequence_number);
  END IF;

  --Get the alternate code
  OPEN cur_alternate_code;
  FETCH cur_alternate_code INTO g_alternate_code,g_start_date,g_end_date;
  IF cur_alternate_code%NOTFOUND THEN
     CLOSE cur_alternate_code;
     fnd_message.set_name('IGF','IGF_SL_NO_CALENDAR');
     igs_ge_msg_stack.add;
     fnd_file.put_line(fnd_file.log,fnd_message.get);

     RAISE NO_DATA_FOUND;
   END IF;
   CLOSE cur_alternate_code;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.main.debug','get award year alt code ' || g_alternate_code ||' awd start date ' || g_start_date || ' awd end date '|| g_end_date);
  END IF;

     --List of all Parameters:
    ln_rec_count   := 0;
    OPEN cur_get_parameters;
    LOOP
      ln_rec_count := ln_rec_count + 1;
     FETCH cur_get_parameters INTO l_para_rec(ln_rec_count);
     EXIT WHEN cur_get_parameters%NOTFOUND;
    END LOOP;
    CLOSE cur_get_parameters;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.main.debug','after getting parameter lkp desc');
   END IF;

     --Show the parameters passed -- print all parameters passed
        g_process_log  := l_para_rec(8);
        g_award_log    := l_para_rec(1);
        g_person_log   := l_para_rec(7);
        g_year         := l_para_rec(2);
        fnd_file.new_line(fnd_file.log,2);
        fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(5),50,' '));
        fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(2),30,' ')||':'||RPAD(' ',4,' ')||g_alternate_code);
        fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(9),30,' ')||':'||RPAD(' ',4,' ')||igf_aw_gen.lookup_desc('IGF_SL_CL_SLJ01_RUN_MODE',p_run_mode));
        fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(3),30,' ')||':'||RPAD(' ',4,' ')||get_fund_desc(p_fund_id));
        fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(7),30,' ')||':'||RPAD(' ',4,' ')||igf_gr_gen.get_per_num(p_base_id)); -- person nunmber
        fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(1),30,' ')||':'||RPAD(' ',4,' ')||p_award_id);
        fnd_file.put_line(fnd_file.log,RPAD(l_para_rec(6),30,' ')||':'||RPAD(' ',4,' ')||get_grp_name(p_dyn_pid_grp));
        fnd_file.put_line(fnd_file.log,RPAD('-',50,'-'));
        fnd_file.new_line(fnd_file.log,2);


-- check if parameters passed are valid ot not
OPEN  cur_check_fund_award(p_base_id, p_award_id, p_fund_id,p_ci_cal_type,p_ci_sequence_number);
FETCH cur_check_fund_award INTO check_fund_award_rec;
IF cur_check_fund_award%NOTFOUND THEN
  CLOSE cur_check_fund_award;
  fnd_message.set_name ('IGF','IGF_SL_NO_LOAN_AWARDS');
  fnd_file.put_line(fnd_file.log, fnd_message.get);
  fnd_file.new_line(fnd_file.log, 1);
  RETURN;
ELSE
 CLOSE cur_check_fund_award;
END IF;



-- Fetching Setup details for Direct Loans
  OPEN cur_dl_setup;
  FETCH cur_dl_setup INTO dl_setup_rec;
  IF cur_dl_setup%NOTFOUND THEN
     lb_dl_setup := FALSE;
     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.main.debug','direct loan setup not found');
     END IF;
  END IF;
  CLOSE cur_dl_setup;

  -- Fetching Setup details for CommonLine Loans
  OPEN cur_cl_setup;
  FETCH cur_cl_setup INTO cl_setup_rec;
  IF cur_cl_setup%NOTFOUND THEN
      lb_cl_setup := FALSE;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.main.debug','FFELP loan setup not found');
      END IF;
  END IF;
  CLOSE cur_cl_setup;

  -- Base 36 Date Code for CommonLine Loan Number
  SELECT TO_CHAR(SYSDATE,'DDDYY') INTO lv_incr_date FROM DUAL;
  p_incr_date_code := igf_sl_gen.base10_to_base36(lv_incr_date);

 -- fa134
  IF p_base_id IS NOT NULL AND
       ( igf_gr_gen.get_per_num(p_base_id) IS NULL OR
         NOT check_fa_rec(p_base_id, p_ci_cal_type, p_ci_sequence_number))
      THEN
       fnd_message.set_name('IGF','IGF_SP_NO_FA_BASE_REC');
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       fnd_file.new_line(fnd_file.log, 1);
       RETURN;
  END IF;
  -- FA134
  IF  p_dyn_pid_grp IS NOT NULL THEN
       OPEN  cur_chk_pidgroup ( p_dyn_pid_grp);
       FETCH cur_chk_pidgroup INTO chk_pidgroup_rec;
       CLOSE cur_chk_pidgroup;
       IF chk_pidgroup_rec.group_id IS NULL THEN
         fnd_message.set_name('IGF','IGF_SL_COD_PERSID_GRP_INV');
         fnd_file.put_line(fnd_file.log, fnd_message.get);
         fnd_file.new_line(fnd_file.log, 1);
         RETURN;
       END IF;
    END IF;
  -- FA134

    IF  p_dyn_pid_grp IS NOT NULL AND p_base_id IS NOT NULL THEN
       fnd_message.set_name('IGF','IGF_SL_COD_INV_PARAM');
       fnd_message.set_token('PARAM1',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_ID_GROUP'));
       fnd_message.set_token('PARAM2',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_NUMBER'));
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       fnd_file.new_line(fnd_file.log, 1);
       RETURN;
    END IF;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.main.debug','base id and pgroup id check');
   END IF;

   IF p_dyn_pid_grp IS NOT NULL AND p_award_id IS NOT NULL THEN
       fnd_message.set_name('IGF','IGF_SL_COD_INV_PARAM');
       fnd_message.set_token('PARAM1',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_ID_GROUP'));
       fnd_message.set_token('PARAM2',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','LOAN_NUMBER'));
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       fnd_file.new_line(fnd_file.log, 1);
       RETURN;
   END IF;
  -- FA134

  IF p_run_mode = 'I' THEN   -- FA134

    IF p_base_id IS NULL AND p_dyn_pid_grp IS NULL THEN
      create_loan_records(p_award_id, p_fund_id, p_base_id,p_ci_cal_type, p_ci_sequence_number, lb_dl_setup, lb_cl_setup);
      RETURN;
    END IF;

    IF p_base_id IS NOT NULL THEN
       create_loan_records(p_award_id, p_fund_id, p_base_id,p_ci_cal_type, p_ci_sequence_number, lb_dl_setup, lb_cl_setup);
       RETURN;
    END IF;

    IF  p_dyn_pid_grp IS NOT NULL THEN

     fnd_message.set_name('IGF','IGF_AW_PERSON_ID_GROUP');
     fnd_message.set_token('P_PER_GRP',get_grp_name(p_dyn_pid_grp));
     fnd_file.new_line(fnd_file.log, 1);
     fnd_file.put_line(fnd_file.log, fnd_message.get);

     --Bug #5021084
     l_list := igf_ap_ss_pkg.get_pid( p_dyn_pid_grp,lv_status,lv_group_type);

     --Bug #5021084. Passing Group ID if the group type is STATIC.
     IF lv_group_type = 'STATIC' THEN
        OPEN cur_per_grp FOR ' SELECT PARTY_ID FROM HZ_PARTIES WHERE PARTY_ID IN (' || l_list  || ') ' USING p_dyn_pid_grp;
     ELSIF lv_group_type = 'DYNAMIC' THEN
        OPEN cur_per_grp FOR ' SELECT PARTY_ID FROM HZ_PARTIES WHERE PARTY_ID IN (' || l_list  || ') ';
     END IF;

     FETCH cur_per_grp INTO l_person_id;

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.main.debug','Starting to process person group '|| p_dyn_pid_grp);
     END IF;

     IF cur_per_grp%NOTFOUND THEN
       CLOSE cur_per_grp;
       fnd_message.set_name('IGF','IGF_DB_NO_PER_GRP');
       fnd_file.put_line(fnd_file.log,fnd_message.get);
       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.main.debug','No persons in group '|| p_dyn_pid_grp);
       END IF;
     ELSE
       IF cur_per_grp%FOUND THEN -- Check if the person exists in FA.
        lb_record_exist := FALSE;
        LOOP
          ln_base_id := 0;
          lv_person_number  := NULL;
          lv_person_number  := per_in_fa (l_person_id,p_ci_cal_type,p_ci_sequence_number,ln_base_id);
          IF lv_person_number IS NOT NULL THEN
            IF ln_base_id IS NOT NULL THEN
               fnd_message.set_name('IGF','IGF_AW_PROC_STUD');
               fnd_message.set_token('STDNT',lv_person_number);
               fnd_file.put_line(fnd_file.log, fnd_message.get);
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.main.debug','PIDG base id ' || ln_base_id);
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.main.debug','PIDG lv_person_number ' || lv_person_number);
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.main.debug','PIDG l_person_id ' || l_person_id);
               END IF;
               create_loan_records(p_award_id, p_fund_id, ln_base_id,p_ci_cal_type, p_ci_sequence_number, lb_dl_setup, lb_cl_setup );
               IF NOT lb_record_exist THEN
                  lb_record_exist := TRUE;
               END IF;
            ELSE -- log a message and skip this person, base id not found
               fnd_message.set_name('IGF','IGF_GR_LI_PER_INVALID');
               fnd_message.set_token('PERSON_NUMBER',lv_person_number);
               fnd_message.set_token('AWD_YR',igf_gr_gen.get_alt_code(p_ci_cal_type,p_ci_sequence_number));
               fnd_file.put_line(fnd_file.log,fnd_message.get);
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.main.debug',igf_gr_gen.get_per_num_oss(l_person_id) || ' not in FA');
               END IF;
            END IF; -- base id not found
          ELSE
            fnd_message.set_name('IGF','IGF_AP_PE_NOT_EXIST');
            fnd_file.put_line(fnd_file.log,RPAD(' ',5) ||fnd_message.get);
          END IF; -- person number not null

        FETCH   cur_per_grp INTO l_person_id;
        EXIT WHEN cur_per_grp%NOTFOUND;
        END LOOP;
        IF NOT lb_record_exist THEN
          fnd_file.new_line(fnd_file.log, 1);
          fnd_message.set_name('IGF','IGF_SL_NO_LOAN_AWARDS');--
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          fnd_file.new_line(fnd_file.log, 1);
          RETURN;
        END IF;
        CLOSE cur_per_grp;
       END IF; -- group found
     END IF; -- group not found
  END IF; -- pid group is not null

 END IF ; -- RUN MODE = INSERT

IF p_run_mode = 'U' THEN

 -- fa134, if update mode then call update_loan(pass all parameters inlciding lb_dl_s, lb_cl_s);

  IF p_base_id IS NULL AND  p_dyn_pid_grp IS NULL THEN
      update_loan_rec(p_award_id, p_fund_id, p_base_id,p_ci_cal_type,p_ci_sequence_number);
      RETURN;
    END IF;

    IF p_base_id IS NOT NULL THEN
      update_loan_rec(p_award_id, p_fund_id, p_base_id,p_ci_cal_type,p_ci_sequence_number);
      RETURN;
    END IF;

    IF  p_dyn_pid_grp IS NOT NULL THEN

     fnd_message.set_name('IGF','IGF_AW_PERSON_ID_GROUP');
     fnd_message.set_token('P_PER_GRP',get_grp_name( p_dyn_pid_grp));
     fnd_file.new_line(fnd_file.log, 1);
     fnd_file.put_line(fnd_file.log, fnd_message.get);

     --Bug #5021084
     l_list := NULL;
     lv_group_type := NULL;
     l_list := igf_ap_ss_pkg.get_pid( p_dyn_pid_grp,lv_status,lv_group_type);

     --Bug #5021084. Passing Group ID if the group type is STATIC.
     IF lv_group_type = 'STATIC' THEN
        OPEN cur_per_grp FOR ' SELECT PARTY_ID FROM HZ_PARTIES WHERE PARTY_ID IN (' || l_list  || ') ' USING p_dyn_pid_grp;
     ELSIF lv_group_type = 'DYNAMIC' THEN
        OPEN cur_per_grp FOR ' SELECT PARTY_ID FROM HZ_PARTIES WHERE PARTY_ID IN (' || l_list  || ') ';
     END IF;

     FETCH cur_per_grp INTO l_person_id;

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.main.debug','Starting to process person group '|| p_dyn_pid_grp);
     END IF;

     IF cur_per_grp%NOTFOUND THEN
       CLOSE cur_per_grp;
       fnd_message.set_name('IGF','IGF_DB_NO_PER_GRP');
       fnd_file.put_line(fnd_file.log,fnd_message.get);
       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.main.debug','No persons in group '|| p_dyn_pid_grp);
       END IF;
     ELSE
       IF cur_per_grp%FOUND THEN -- Check if the person exists in FA.
        lb_record_exist := FALSE;
        LOOP
          ln_base_id := 0;
          lv_person_number  := NULL;
          lv_person_number  := per_in_fa (l_person_id,p_ci_cal_type,p_ci_sequence_number,ln_base_id);
          IF lv_person_number IS NOT NULL THEN
            IF ln_base_id IS NOT NULL THEN
               fnd_message.set_name('IGF','IGF_AW_PROC_STUD');
               fnd_message.set_token('STDNT',lv_person_number);
               fnd_file.put_line(fnd_file.log, fnd_message.get);
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.main.debug','PIDG base id ' || ln_base_id);
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.main.debug','PIDG lv_person_number ' || lv_person_number);
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.main.debug','PIDG l_person_id ' || l_person_id);
               END IF;
                 update_loan_rec(p_award_id, p_fund_id, ln_base_id,p_ci_cal_type, p_ci_sequence_number);
                 IF NOT lb_record_exist THEN
                    lb_record_exist := TRUE;
                 END IF;
            ELSE -- log a message and skip this person, base id not found
               fnd_message.set_name('IGF','IGF_GR_LI_PER_INVALID');
               fnd_message.set_token('PERSON_NUMBER',lv_person_number);
               fnd_message.set_token('AWD_YR',igf_gr_gen.get_alt_code(p_ci_cal_type,p_ci_sequence_number));
               fnd_file.put_line(fnd_file.log,fnd_message.get);
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_lar_creation.main.debug',igf_gr_gen.get_per_num_oss(l_person_id) || ' not in FA');
               END IF;
            END IF; -- base id not found
          ELSE
            fnd_message.set_name('IGF','IGF_AP_PE_NOT_EXIST');
            fnd_file.put_line(fnd_file.log,RPAD(' ',5) ||fnd_message.get);
          END IF; -- person number not null

        FETCH   cur_per_grp INTO l_person_id;
        EXIT WHEN cur_per_grp%NOTFOUND;
        END LOOP;
        IF NOT lb_record_exist THEN
          fnd_file.new_line(fnd_file.log, 1);
          fnd_message.set_name('IGF','IGF_SL_NO_LOAN_AWARDS');--
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          fnd_file.new_line(fnd_file.log, 1);
          RETURN;
        END IF;
        CLOSE cur_per_grp;
       END IF; -- group found
     END IF; -- group not found
  END IF; -- pid group is not null

 END IF ; -- RUN MODE = UPDATE

--  COMMIT;

EXCEPTION
WHEN NO_DATA_FOUND THEN
     NULL;

WHEN OTHERS THEN
     ROLLBACK;
     retcode :=2;
     errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
     fnd_file.put_line(fnd_file.log,SQLERRM);
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_lar_creation.main.debug','SLQERRM ' || SQLERRM);
     END IF;
     igs_ge_msg_stack.conc_exception_hndl;

END insert_loan_records;

END igf_sl_lar_creation;

/
