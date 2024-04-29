--------------------------------------------------------
--  DDL for Package Body IGF_GR_LI_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_LI_IMPORT" AS
/* $Header: IGFGR10B.pls 120.3 2006/01/17 02:45:55 tsailaja ship $ */
/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL spec for package: IGF_GR_LI_IMPORT                        |
 |                                                                       |
 | NOTES                                                                 |
 |   Legacy Pell Origiantion and Disbursement Import Process. Imports the|
 |   Pell Originaton records and its disbursement records from the legacy|
 |   systems to IGS. Validates all the lookup values, checks for foreign |
 |   key refferencing to the awards table, also populates the Pell Batch |
 |   table.                                                              |
 |                                                                       |
 |   Supports import of Pell Origination and Disbursments records in     |
 |   update mode provided key information is not changed.                |
 |                                                                       |
 | HISTORY                                                               |
 | psssahni     29-Oct-2004  Bug 3416863                                 |
 |                           Added validation to run the process for     |
 |                           awards having Ready to Send status only in  |
 |                           case of COD-XML processing.                 |
 |                           Added validation to check the combination of|
 |                           attending and reporting pell id             |
 | svuppala     14-Oct-2004  Bug # 3416936				 |
 |                           Modified TBH call to addeded field          |
 |                           Eligible for Additional Unsubsidized Loans  |
 |									 |
 | ugummall       20-Apr-2004   Bug 3558751. Added lookup enabled_flag   |
 |                              check for all the cursors using lookups. |
 | veramach       10-Dec-2003  Removed cursor c_pell_setup and related   |
 |                             code                                      |
 | rasahoo        17-NOV-2003 FA 128 - ISIR update 2004-05               |
 |                           added new parameter                         |
 |                           award_fmly_contribution_type to             |
 |                           igf_ap_fa_base_rec_pkg.update_row           |
 |                           Changed the cursor c_isir_details           |
 | brajendr      04-Jul-2002  Bug # 2991359 Creation of file             |
 | bkkumar       13-Aug-2003  Bug# 3089841  Added one transaction_num    |
 |                            validation  and changed the c_isir_details |
 |                            cursor.                                    |
 | nsidana       10/31/2003   Multiple FA offices build : Added new fn   |
 |                            to derive the REP PELL ID.                 |
 | gvarapra   14-sep-2004         FA138 - ISIR Enhancements              |
 |                                Changed arguments in call to           |
 |                                IGF_AP_FA_BASE_RECORD_PKG.             |
 *=======================================================================*/

  -- Get the details of Pell Origination Interface records
  CURSOR c_pell_orig_int(
                         cp_batch_num          igf_aw_li_pell_ints.batch_num%TYPE,
                         cp_ci_alternate_code  igf_aw_li_pell_ints.ci_alternate_code%TYPE,
                         cp_orig_status_code   igf_aw_li_pell_ints.orig_status_code%TYPE
                        ) IS
  SELECT ROWID row_id,
         batch_num                         batch_num,
         TRIM(ci_alternate_code)           ci_alternate_code,
         TRIM(person_number)               person_number,
         TRIM(award_number_txt)            award_number_txt,
         TRIM(origination_id_txt)          origination_id_txt,
         TRIM(import_status_type)          import_status_type,
         TRIM(orig_send_batch_id_txt)      orig_send_batch_id_txt,
         TRIM(transaction_num_txt)         transaction_num_txt,
         efc_amt                           efc_amt,
         TRIM(verification_status_code)    verification_status_code,
         secondary_efc_amt                 secondary_efc_amt,
         TRIM(secondary_efc_code)          secondary_efc_code,
         pell_award_amt                    pell_award_amt,
         TRIM(enrollment_status_flag)      enrollment_status_flag,
         enrollment_date                   enrollment_date,
         pell_coa_amt                      pell_coa_amt,
         TRIM(academic_calendar_cd)        academic_calendar_cd,
         TRIM(payment_method_code)         payment_method_code,
         TRIM(incrcd_fed_pell_rcp_code)    incrcd_fed_pell_rcp_code,
         TRIM(attending_campus_cd )        attending_campus_cd,
         TRIM(orig_status_code)            orig_status_code,
         orig_status_date                  orig_status_date,
         TRIM(orig_ed_use_flags_txt)       orig_ed_use_flags_txt,
         ft_sch_pell_amt                   ft_sch_pell_amt,
         prev_accpt_efc_amt                prev_accpt_efc_amt,
         TRIM(prev_accpt_tran_num_txt)     prev_accpt_tran_num_txt,
         TRIM(prev_accpt_sec_efc_cd)       prev_accpt_sec_efc_cd,
         prev_accpt_coa_amt                prev_accpt_coa_amt,
         TRIM(orig_reject_codes_txt)       orig_reject_codes_txt,
         wk_inst_time_calc_pymt_num        wk_inst_time_calc_pymt_num,
         wk_int_time_prg_def_yr_num        wk_int_time_prg_def_yr_num,
         cr_clk_hrs_prds_sch_yr_num        cr_clk_hrs_prds_sch_yr_num,
         cr_clk_hrs_acad_yr_num            cr_clk_hrs_acad_yr_num,
         TRIM(inst_cross_ref_cd)           inst_cross_ref_cd,
         TRIM(low_tution_fee_cd)           low_tution_fee_cd,
         pending_amt                       pending_amt,
         rfms_process_date                 rfms_process_date,
         rfms_ack_date                     rfms_ack_date,
         TRIM(import_record_type)          import_record_type,
         TRIM(ope_cd)                      ope_cd,
         pell_alt_exp_amt                  pell_alt_exp_amt,
         atd_entity_id_txt                 atd_entity_id_txt,
         rep_entity_id_txt                 rep_entity_id_txt
    FROM igf_aw_li_pell_ints pell
   WHERE batch_num = cp_batch_num
     AND TRIM(ci_alternate_code) = cp_ci_alternate_code
     AND TRIM(import_status_type) IN ('U','R')
     AND NVL (TRIM (orig_status_code), 'x') = NVL (cp_orig_status_code, NVL (TRIM
             (orig_status_code), 'x'))
   ORDER BY ci_alternate_code, person_number, award_number_txt;

  -- Get the details of Pell Origination Interface records
  CURSOR c_pell_disb_int(
                         cp_ci_alternate_code  igf_aw_li_pdb_ints.ci_alternate_code%TYPE,
                         cp_person_number      igf_aw_li_pdb_ints.person_number%TYPE,
                         cp_award_number_txt   igf_aw_li_pdb_ints.award_number_txt%TYPE,
                         cp_origination_id_txt igf_aw_li_pdb_ints.origination_id_txt%TYPE
                        ) IS
  SELECT ROWID row_id,
         TRIM(ci_alternate_code)       ci_alternate_code,
         TRIM(person_number)           person_number,
         TRIM(award_number_txt)        award_number_txt,
         TRIM(origination_id_txt)      origination_id_txt,
         disbursement_num              disbursement_num,
         TRIM(disb_ack_act_flag)       disb_ack_act_flag,
         disb_status_date              disb_status_date,
         accpt_disb_date               accpt_disb_date,
         disb_accpt_amt                disb_accpt_amt,
         TRIM(disbursement_sign_flag)  disbursement_sign_flag,
         disb_ytd_amt                  disb_ytd_amt,
         pymt_prd_start_date           pymt_prd_start_date,
         accpt_pymt_prd_start_date     accpt_pymt_prd_start_date,
         TRIM(edit_codes_txt)          edit_codes_txt,
         TRIM(disburse_batch_id_txt)   disburse_batch_id_txt,
         disburse_batch_process_date   disburse_batch_process_date,
         disburse_batch_ack_date       disburse_batch_ack_date,
         TRIM(ed_use_flags)            ed_use_flags
    FROM igf_aw_li_pdb_ints
   WHERE TRIM(ci_alternate_code)  = cp_ci_alternate_code
     AND TRIM(person_number)      = cp_person_number
     AND TRIM(award_number_txt)   = cp_award_number_txt
     AND TRIM(origination_id_txt) = cp_origination_id_txt
   ORDER BY ci_alternate_code, person_number, award_number_txt, origination_id_txt, disbursement_num;

  -- Get the ISIR details for the context Person(base_id)
  --  Bug# 3089841 Removed the payment ISIR check
  CURSOR c_isir_details(
                        cp_base_id          igf_ap_fa_base_rec_all.base_id%TYPE,
                        cp_transaction_num  igf_ap_isir_matched_all.transaction_num%TYPE
                       ) IS
    SELECT i.original_ssn,
           RPAD(i.orig_name_id,2,' ') orig_name_id,
           i.date_of_birth,
           i.last_name,
           i.first_name,
           i.middle_initial,
           i.current_ssn,
           DECODE(f.award_fmly_contribution_type,
                  '2',i.secondary_efc,
                      i.primary_efc) paid_efc
      FROM igf_ap_isir_matched_all i,
           igf_ap_fa_base_rec_all f
     WHERE i.base_id = cp_base_id
       AND f.base_id = i.base_id
       AND i.system_record_type = 'ORIGINAL'
       AND TO_NUMBER(i.transaction_num) = TO_NUMBER(cp_transaction_num);

  -- Declaration of global paramters
  g_award_id                igf_aw_award_all.award_id%TYPE;
  g_person_id               igf_ap_fa_base_rec_all.person_id%TYPE;
  g_base_id                 igf_ap_fa_base_rec_all.base_id%TYPE;
  g_cal_type                igf_ap_fa_base_rec_all.ci_cal_type%TYPE;
  g_seq_number              igf_ap_fa_base_rec_all.ci_sequence_number%TYPE;
  g_sys_award_year          igf_ap_batch_aw_map_all.sys_award_year%TYPE;
  g_awd_yr_status_cd        igf_ap_batch_aw_map_all.award_year_status_code%TYPE;
  g_debug_runtime_level     NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_disb_pad_str            VARCHAR2(10) := '    ';
  g_tot_rec_processed       NUMBER :=0 ;
  g_tot_rec_imp_warning     NUMBER :=0 ;
  g_tot_rec_imp_error       NUMBER :=0 ;
  g_tot_rec_imp_successful  NUMBER :=0 ;
  g_delete_flag             VARCHAR2(1);
  g_reporting_pell_id       VARCHAR2(30):=NULL; -- Multiple FA offices. Global variable to hold the derived Rep Pell ID.
  g_attending_pell_cd       VARCHAR2(30):=NULL; -- Multiple FA offices. Global variable to hold the derived Rep Pell ID.
  g_atd_entity_id_txt       VARCHAR2(30):=NULL;

  PROCEDURE log_parameters(
                           p_alternate_code  VARCHAR2,
                           p_batch_number    NUMBER,
                           p_del_ind         VARCHAR2
                          ) IS
    /*
    ||  Created By : brajendr
    ||  Created On : 10-Jul-2003
    ||  Purpose : This process log the parameters in the log file
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    -- Get the values from the lookups
    CURSOR c_get_parameters IS
    SELECT lkups.meaning, lkups.lookup_code
      FROM igf_lookups_view lkups
     WHERE lkups.lookup_type = 'IGF_GE_PARAMETERS'
       AND lkups.lookup_code IN ('AWARD_YEAR','BATCH_NUMBER','DELETE_FLAG','PARAMETER_PASS')
       AND lkups.enabled_flag = 'Y' ;

    parameter_rec           c_get_parameters%ROWTYPE;

    l_award_year_pmpt      igf_lookups_view.meaning%TYPE;
    l_batch_number_pmpt    igf_lookups_view.meaning%TYPE;
    l_delete_flag_pmpt     igf_lookups_view.meaning%TYPE;
    l_para_pass            igf_lookups_view.meaning%TYPE;

  BEGIN

    -- Set all the Prompts for the Input Parameters
    OPEN c_get_parameters;
    LOOP
     FETCH c_get_parameters INTO  parameter_rec;
     EXIT WHEN c_get_parameters%NOTFOUND;

     IF (parameter_rec.lookup_code ='AWARD_YEAR') THEN
       l_award_year_pmpt := TRIM(parameter_rec.meaning);

     ELSIF (parameter_rec.lookup_code ='BATCH_NUMBER') THEN
       l_batch_number_pmpt := TRIM(parameter_rec.meaning);

     ELSIF (parameter_rec.lookup_code ='DELETE_FLAG') THEN
       l_delete_flag_pmpt := TRIM(parameter_rec.meaning);

     ELSIF (parameter_rec.lookup_code ='PARAMETER_PASS') THEN
       l_para_pass := TRIM(parameter_rec.meaning);

     END IF;

    END LOOP;
    CLOSE c_get_parameters;


    fnd_file.put_line(fnd_file.log, ' ');
    fnd_file.put_line(fnd_file.log, l_para_pass); --------------Parameters Passed--------------
    fnd_file.put_line(fnd_file.log, ' ');

    fnd_file.put_line(fnd_file.log, RPAD(l_award_year_pmpt,40)   || ' : '|| p_alternate_code);
    fnd_file.put_line(fnd_file.log, RPAD(l_batch_number_pmpt,40) || ' : '|| p_batch_number);
    fnd_file.put_line(fnd_file.log, RPAD(l_delete_flag_pmpt,40)  || ' : '|| igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO', p_del_ind));

    fnd_file.put_line(fnd_file.log, ' ');
    fnd_file.put_line(fnd_file.log,RPAD('-',55,'-'));

  EXCEPTION
    WHEN OTHERS THEN
      IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_gr_li_import.log_parameters.exception', SQLERRM );
      END IF;
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_GR_LI_IMPORT.LOG_PARAMETERS');
      igs_ge_msg_stack.add;

  END log_parameters;


FUNCTION derive_rep_pell_id(p_pell_orig_int  c_pell_orig_int%ROWTYPE) RETURN VARCHAR2
    /*
    ||  Created By : nsidana
    ||  Created On : 11/4/2003
    ||  Purpose : This fn derives the reporting pell ID for an Pell interface record based on OPE CD / Attend campus ID / Base ID.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
AS
l_rep_pell VARCHAR2(30);
l_debug_str           fnd_log_messages.message_text%TYPE := 'IGFGR10B.pls Function derive_rep_pell_id() :: ';


BEGIN
    IF (p_pell_orig_int.ope_cd IS NOT NULL)
    THEN
         l_rep_pell := igf_gr_gen.get_rep_pell_from_ope(g_cal_type,g_seq_number,p_pell_orig_int.ope_cd);
         IF (l_rep_pell IS NULL)
         THEN
             IF (p_pell_orig_int.attending_campus_cd IS NOT NULL)
             THEN
                l_rep_pell := igf_gr_gen.get_rep_pell_from_att(g_cal_type,g_seq_number,p_pell_orig_int.attending_campus_cd);
                IF (l_rep_pell IS NULL)
                THEN
                    l_rep_pell := igf_gr_gen.get_rep_pell_from_base(g_cal_type,g_seq_number,g_base_id);
                    IF (l_rep_pell IS NOT NULL)
                    THEN
                        IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
                          l_debug_str := l_debug_str || ' Derived reporting pell Id from Base ID '|| l_rep_pell;
                        END IF;
                        RETURN l_rep_pell;
                    ELSE
                        IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
                          l_debug_str := l_debug_str || ' Unable to derive the rep_pell ID from ope_cd, attending campus ID and base ID.';
                        END IF;
                        RETURN null;
                    END IF;
                ELSE
                    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
                       l_debug_str := l_debug_str || ' Derived reporting pell Id from Attending campus ID '||l_rep_pell;
                    END IF;
                    RETURN l_rep_pell;
                END IF;
             ELSE
                l_rep_pell := igf_gr_gen.get_rep_pell_from_base(g_cal_type,g_seq_number,g_base_id);
                IF (l_rep_pell IS NOT NULL)
                THEN
                    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
                        l_debug_str := l_debug_str || ' Derived Reporting Pell Id from the base ID '||l_rep_pell;
                    END IF;
                    RETURN l_rep_pell;
                ELSE
                    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
                      l_debug_str := l_debug_str || ' Unable to derive the rep_pell ID from ope_cd, attending campus ID and base ID.';
                    END IF;
                    RETURN null;
                END IF;
             END IF;
         ELSE
            IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
              l_debug_str := l_debug_str || 'Derived reporting pell Id from the OPE CD '||l_rep_pell;
            END IF;
            RETURN l_rep_pell;
         END IF;
    ELSE
        -- ope_cd is null...
             IF (p_pell_orig_int.attending_campus_cd IS NOT NULL)
             THEN
                l_rep_pell := igf_gr_gen.get_rep_pell_from_att(g_cal_type,g_seq_number,p_pell_orig_int.attending_campus_cd);
                IF (l_rep_pell IS NULL)
                THEN
                    l_rep_pell := igf_gr_gen.get_rep_pell_from_base(g_cal_type,g_seq_number,g_base_id);
                        IF (l_rep_pell IS NOT NULL)
                        THEN
                            IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
                                l_debug_str := l_debug_str || 'Derived repoting pell ID from Base ID' || l_rep_pell;
                            END IF;
                            RETURN l_rep_pell;
                        ELSE
                            IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
                              l_debug_str := l_debug_str || ' Unable to derive the rep_pell ID from ope_cd, attending campus ID and base ID.';
                            END IF;
                            RETURN null;
                        END IF;
                ELSE
                    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
                        l_debug_str := l_debug_str || 'Derived reporting pell ID from the Attend campus ID '||l_rep_pell;
                    END IF;
                    RETURN l_rep_pell;
                END IF;
             ELSE
                l_rep_pell := igf_gr_gen.get_rep_pell_from_base(g_cal_type,g_seq_number,g_base_id);
                IF (l_rep_pell IS NOT NULL)
                THEN
                    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
                       l_debug_str := l_debug_str || 'Derived repoting pell ID from Base Id '||l_rep_pell;
                    END IF;
                    RETURN l_rep_pell;
                ELSE
                    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
                      l_debug_str := l_debug_str || ' Unable to derive the rep_pell ID from ope_cd, attending campus ID and base ID.';
                    END IF;
                    RETURN null;
                END IF;
             END IF;
    END IF;
END derive_rep_pell_id;


  FUNCTION update_fa_base_data(
                               p_base_id          igf_ap_fa_base_rec_all.base_id%TYPE,
                               p_coa_pell         igf_ap_fa_base_rec_all.coa_pell%TYPE,
                               p_pell_alt_expense igf_ap_fa_base_rec_all.pell_alt_expense%TYPE
                              ) RETURN VARCHAR2 AS

    /*
    ||  Created By : brajendr
    ||  Created On : 10-Jul-2003
    ||  Purpose : Updates the FA Base record with the Pel COA and Pell Alternate expenses
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||
    ||   rasahoo        17-NOV-2003      FA 128 - ISIR update 2004-05
    ||                                   added new parameter award_fmly_contribution_type to
    ||                                   igf_ap_fa_base_rec_pkg.update_row
    ||  ugummall        25-SEP-2003     FA 126 - Multiple FA Offices
    ||                                  added new parameter assoc_org_num to
    ||                                  igf_ap_fa_base_rec_pkg.update_row call
    */

    -- Get base record deails
    CURSOR c_get_base_rec_dtls(
                               cp_base_id  igf_ap_fa_base_rec_all.base_id%TYPE
                              ) IS
      SELECT ROWID row_id, base.*
        FROM igf_ap_fa_base_rec_all base
       WHERE base.base_id = cp_base_id;

    lc_get_base_rec_dtls   c_get_base_rec_dtls%ROWTYPE;

    l_debug_str     fnd_log_messages.message_text%TYPE := 'IGFGR10B.pls Procedure update_fa_base_data :: ';

  BEGIN

    -- Get the details of the Base record to update the PELL COA and PELL ALT Expenses
    lc_get_base_rec_dtls := NULL;
    OPEN c_get_base_rec_dtls(p_base_id);
    FETCH c_get_base_rec_dtls INTO lc_get_base_rec_dtls;
    CLOSE c_get_base_rec_dtls;

    IF (lc_get_base_rec_dtls.base_id IS NULL) THEN
      RETURN 'E';
    END IF;


    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ' Before updating FA Base : Pell COA ' || p_coa_pell || ' Pell Alt Exp : '|| p_pell_alt_expense;
    END IF;

    -- update the fa base record
    igf_ap_fa_base_rec_pkg.update_row(
                                      x_Mode                         => 'R' ,
                                      x_rowid                        => lc_get_base_rec_dtls.row_id ,
                                      x_base_id                      => lc_get_base_rec_dtls.base_id ,
                                      x_ci_cal_type                  => lc_get_base_rec_dtls.ci_cal_type ,
                                      x_person_id                    => lc_get_base_rec_dtls.person_id ,
                                      x_ci_sequence_number           => lc_get_base_rec_dtls.ci_sequence_number ,
                                      x_org_id                       => lc_get_base_rec_dtls.org_id ,
                                      x_coa_pending                  => lc_get_base_rec_dtls.coa_pending ,
                                      x_verification_process_run     => lc_get_base_rec_dtls.verification_process_run ,
                                      x_inst_verif_status_date       => lc_get_base_rec_dtls.inst_verif_status_date ,
                                      x_manual_verif_flag            => lc_get_base_rec_dtls.manual_verif_flag ,
                                      x_fed_verif_status             => lc_get_base_rec_dtls.fed_verif_status ,
                                      x_fed_verif_status_date        => lc_get_base_rec_dtls.fed_verif_status_date ,
                                      x_inst_verif_status            => lc_get_base_rec_dtls.inst_verif_status ,
                                      x_nslds_eligible               => lc_get_base_rec_dtls.nslds_eligible ,
                                      x_ede_correction_batch_id      => lc_get_base_rec_dtls.ede_correction_batch_id ,
                                      x_fa_process_status_date       => lc_get_base_rec_dtls.fa_process_status_date  ,
                                      x_isir_corr_status             => lc_get_base_rec_dtls.isir_corr_status ,
                                      x_isir_corr_status_date        => lc_get_base_rec_dtls.isir_corr_status_date ,
                                      x_isir_status                  => lc_get_base_rec_dtls.isir_status ,
                                      x_isir_status_date             => lc_get_base_rec_dtls.isir_status_date ,
                                      x_coa_code_f                   => lc_get_base_rec_dtls.coa_code_f ,
                                      x_coa_code_i                   => lc_get_base_rec_dtls.coa_code_i ,
                                      x_coa_f                        => lc_get_base_rec_dtls.coa_f ,
                                      x_coa_i                        => lc_get_base_rec_dtls.coa_i ,
                                      x_disbursement_hold            => lc_get_base_rec_dtls.disbursement_hold ,
                                      x_fa_process_status            => lc_get_base_rec_dtls.fa_process_status  ,
                                      x_notification_status          => lc_get_base_rec_dtls.notification_status ,
                                      x_notification_status_date     => lc_get_base_rec_dtls.notification_status_date ,
                                      x_packaging_status             => lc_get_base_rec_dtls.packaging_status,
                                      x_packaging_status_date        => lc_get_base_rec_dtls.packaging_status_date,
                                      x_total_package_accepted       => lc_get_base_rec_dtls.total_package_accepted ,
                                      x_total_package_offered        => lc_get_base_rec_dtls.total_package_offered ,
                                      x_admstruct_id                 => lc_get_base_rec_dtls.admstruct_id ,
                                      x_admsegment_1                 => lc_get_base_rec_dtls.admsegment_1 ,
                                      x_admsegment_2                 => lc_get_base_rec_dtls.admsegment_2 ,
                                      x_admsegment_3                 => lc_get_base_rec_dtls.admsegment_3 ,
                                      x_admsegment_4                 => lc_get_base_rec_dtls.admsegment_4 ,
                                      x_admsegment_5                 => lc_get_base_rec_dtls.admsegment_5 ,
                                      x_admsegment_6                 => lc_get_base_rec_dtls.admsegment_6 ,
                                      x_admsegment_7                 => lc_get_base_rec_dtls.admsegment_7 ,
                                      x_admsegment_8                 => lc_get_base_rec_dtls.admsegment_8 ,
                                      x_admsegment_9                 => lc_get_base_rec_dtls.admsegment_9 ,
                                      x_admsegment_10                => lc_get_base_rec_dtls.admsegment_10 ,
                                      x_admsegment_11                => lc_get_base_rec_dtls.admsegment_11 ,
                                      x_admsegment_12                => lc_get_base_rec_dtls.admsegment_12 ,
                                      x_admsegment_13                => lc_get_base_rec_dtls.admsegment_13 ,
                                      x_admsegment_14                => lc_get_base_rec_dtls.admsegment_14 ,
                                      x_admsegment_15                => lc_get_base_rec_dtls.admsegment_15 ,
                                      x_admsegment_16                => lc_get_base_rec_dtls.admsegment_16 ,
                                      x_admsegment_17                => lc_get_base_rec_dtls.admsegment_17 ,
                                      x_admsegment_18                => lc_get_base_rec_dtls.admsegment_18 ,
                                      x_admsegment_19                => lc_get_base_rec_dtls.admsegment_19 ,
                                      x_admsegment_20                => lc_get_base_rec_dtls.admsegment_20 ,
                                      x_packstruct_id                => lc_get_base_rec_dtls.packstruct_id ,
                                      x_packsegment_1                => lc_get_base_rec_dtls.packsegment_1 ,
                                      x_packsegment_2                => lc_get_base_rec_dtls.packsegment_2 ,
                                      x_packsegment_3                => lc_get_base_rec_dtls.packsegment_3 ,
                                      x_packsegment_4                => lc_get_base_rec_dtls.packsegment_4 ,
                                      x_packsegment_5                => lc_get_base_rec_dtls.packsegment_5 ,
                                      x_packsegment_6                => lc_get_base_rec_dtls.packsegment_6 ,
                                      x_packsegment_7                => lc_get_base_rec_dtls.packsegment_7 ,
                                      x_packsegment_8                => lc_get_base_rec_dtls.packsegment_8 ,
                                      x_packsegment_9                => lc_get_base_rec_dtls.packsegment_9 ,
                                      x_packsegment_10               => lc_get_base_rec_dtls.packsegment_10 ,
                                      x_packsegment_11               => lc_get_base_rec_dtls.packsegment_11 ,
                                      x_packsegment_12               => lc_get_base_rec_dtls.packsegment_12 ,
                                      x_packsegment_13               => lc_get_base_rec_dtls.packsegment_13 ,
                                      x_packsegment_14               => lc_get_base_rec_dtls.packsegment_14 ,
                                      x_packsegment_15               => lc_get_base_rec_dtls.packsegment_15 ,
                                      x_packsegment_16               => lc_get_base_rec_dtls.packsegment_16 ,
                                      x_packsegment_17               => lc_get_base_rec_dtls.packsegment_17 ,
                                      x_packsegment_18               => lc_get_base_rec_dtls.packsegment_18 ,
                                      x_packsegment_19               => lc_get_base_rec_dtls.packsegment_19 ,
                                      x_packsegment_20               => lc_get_base_rec_dtls.packsegment_20 ,
                                      x_miscstruct_id                => lc_get_base_rec_dtls.miscstruct_id ,
                                      x_miscsegment_1                => lc_get_base_rec_dtls.miscsegment_1 ,
                                      x_miscsegment_2                => lc_get_base_rec_dtls.miscsegment_2 ,
                                      x_miscsegment_3                => lc_get_base_rec_dtls.miscsegment_3 ,
                                      x_miscsegment_4                => lc_get_base_rec_dtls.miscsegment_4 ,
                                      x_miscsegment_5                => lc_get_base_rec_dtls.miscsegment_5 ,
                                      x_miscsegment_6                => lc_get_base_rec_dtls.miscsegment_6 ,
                                      x_miscsegment_7                => lc_get_base_rec_dtls.miscsegment_7 ,
                                      x_miscsegment_8                => lc_get_base_rec_dtls.miscsegment_8 ,
                                      x_miscsegment_9                => lc_get_base_rec_dtls.miscsegment_9 ,
                                      x_miscsegment_10               => lc_get_base_rec_dtls.miscsegment_10 ,
                                      x_miscsegment_11               => lc_get_base_rec_dtls.miscsegment_11 ,
                                      x_miscsegment_12               => lc_get_base_rec_dtls.miscsegment_12 ,
                                      x_miscsegment_13               => lc_get_base_rec_dtls.miscsegment_13 ,
                                      x_miscsegment_14               => lc_get_base_rec_dtls.miscsegment_14 ,
                                      x_miscsegment_15               => lc_get_base_rec_dtls.miscsegment_15 ,
                                      x_miscsegment_16               => lc_get_base_rec_dtls.miscsegment_16 ,
                                      x_miscsegment_17               => lc_get_base_rec_dtls.miscsegment_17 ,
                                      x_miscsegment_18               => lc_get_base_rec_dtls.miscsegment_18 ,
                                      x_miscsegment_19               => lc_get_base_rec_dtls.miscsegment_19 ,
                                      x_miscsegment_20               => lc_get_base_rec_dtls.miscsegment_20 ,
                                      x_prof_judgement_flg           => lc_get_base_rec_dtls.prof_judgement_flg ,
                                      x_nslds_data_override_flg      => lc_get_base_rec_dtls.nslds_data_override_flg ,
                                      x_target_group                 => lc_get_base_rec_dtls.target_group ,
                                      x_coa_fixed                    => lc_get_base_rec_dtls.coa_fixed ,
                                      x_coa_pell                     => p_coa_pell ,
                                      x_profile_status               => lc_get_base_rec_dtls.profile_status ,
                                      x_profile_status_date          => lc_get_base_rec_dtls.profile_status_date ,
                                      x_profile_fc                   => lc_get_base_rec_dtls.profile_fc ,
                                      x_manual_disb_hold             => lc_get_base_rec_dtls.manual_disb_hold,
                                      x_pell_alt_expense             => p_pell_alt_expense,
                                      x_assoc_org_num                => lc_get_base_rec_dtls.assoc_org_num,
                                      x_award_fmly_contribution_type => lc_get_base_rec_dtls.award_fmly_contribution_type,
                                      x_isir_locked_by               => lc_get_base_rec_dtls.isir_locked_by,
				                              x_adnl_unsub_loan_elig_flag    => lc_get_base_rec_dtls.adnl_unsub_loan_elig_flag,
                                      x_lock_awd_flag                => lc_get_base_rec_dtls.lock_awd_flag,
                                      x_lock_coa_flag                => lc_get_base_rec_dtls.lock_coa_flag

                                     );

    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_gr_li_import.update_fa_base_data.debug', l_debug_str || ' Sucssfully updated ');
      l_debug_str := NULL;
    END IF;

    RETURN 'S';

  EXCEPTION
    WHEN OTHERS THEN

      IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_gr_li_import.update_fa_base_data.exception', l_debug_str || SQLERRM );
      END IF;
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_GR_LI_IMPORT.UPDATE_FA_BASE_DATA');
      igs_ge_msg_stack.add;
      RETURN 'E';

  END update_fa_base_data;


  FUNCTION delete_existing_pell_rec(
                                    p_origination_id  igf_gr_rfms_all.origination_id%TYPE,
                                    p_cal_type        igf_gr_rfms_all.ci_cal_type%TYPE,
                                    p_seq_number      igf_gr_rfms_all.ci_sequence_number%TYPE
                                   ) RETURN VARCHAR2 AS

    /*
    ||  Created By : brajendr
    ||  Created On : 10-Jul-2003
    ||  Purpose : Deletes the exitsing pell legacy records from the production tables
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    -- Check whether is there any pell origination record present for the context information
    CURSOR c_chk_pell_orig(
                           cp_origination_id  igf_gr_rfms_all.origination_id%TYPE,
                           cp_cal_type        igf_gr_rfms_all.ci_cal_type%TYPE,
                           cp_seq_number      igf_gr_rfms_all.ci_sequence_number%TYPE
                          ) IS
      SELECT ROWID row_id, rfms.rfmb_id
        FROM igf_gr_rfms_all rfms
       WHERE rfms.origination_id = cp_origination_id
         AND rfms.ci_cal_type = cp_cal_type
         AND rfms.ci_sequence_number = cp_seq_number
         AND NVL(rfms.legacy_record_flag,'N') = 'Y';

    lc_chk_pell_orig   c_chk_pell_orig%ROWTYPE;

    -- Get the details of
    CURSOR c_get_pell_disb(
                           cp_origination_id  igf_gr_rfms_all.origination_id%TYPE
                          ) IS
      SELECT ROWID row_id, pdb.rfmd_id, pdb.rfmb_id
        FROM igf_gr_rfms_disb_all pdb
       WHERE pdb.origination_id = cp_origination_id;

    l_return_val    VARCHAR2(1) := 'E';
    l_debug_str     fnd_log_messages.message_text%TYPE := 'IGFGR10B.pls Procedure delete_existing_pell_rec :: ';

  BEGIN

    -- check whether Pell Origination record is present in the system with the legacy flag is set to 'Y'
    lc_chk_pell_orig := NULL;
    OPEN c_chk_pell_orig( p_origination_id, p_cal_type, p_seq_number);
    FETCH c_chk_pell_orig INTO lc_chk_pell_orig;
    CLOSE c_chk_pell_orig;

    IF (lc_chk_pell_orig.row_id IS NOT NULL) THEN

      IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
        l_debug_str := l_debug_str || ' Pell Orig : ' || p_origination_id || ', Looping Pell disb ';
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_gr_li_import.delete_existing_pell_rec.debug', l_debug_str);
        l_debug_str := NULL;
      END IF;

      BEGIN

        -- Loop for all Pell Disbursement records for the given Pell record
        FOR lc_get_pell_disb IN c_get_pell_disb(p_origination_id) LOOP

          IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_gr_li_import.delete_existing_pell_rec.debug', ' Deleting Pell Disb : ' || lc_get_pell_disb.rfmd_id);
          END IF;

          igf_gr_rfms_disb_pkg.delete_row(lc_get_pell_disb.row_id);
        END LOOP;

        -- Delete Pell Origination Record
        igf_gr_rfms_pkg.delete_row(lc_chk_pell_orig.row_id);

        -- After complete deletion set return status as successful
        l_return_val := 'S';

      EXCEPTION
        WHEN OTHERS THEN
          l_return_val := 'E';
      END;

    END IF;

    RETURN l_return_val;

  EXCEPTION
    WHEN OTHERS THEN

      IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_gr_li_import.delete_existing_pell_rec.exception', l_debug_str || SQLERRM );
      END IF;
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_GR_LI_IMPORT.DELETE_EXISTING_PELL_REC');
      igs_ge_msg_stack.add;
      RETURN 'E';

  END delete_existing_pell_rec;


  FUNCTION create_pell_disb_batch(
                                  p_pell_disb_int  c_pell_disb_int%ROWTYPE,
                                  p_ope_cd         igf_aw_li_pell_ints.ope_cd%TYPE
                                 ) RETURN NUMBER AS
    /*
    ||  Created By : brajendr
    ||  Created On : 19-Jun-2003
    ||  Purpose : Creates the Pell Disbursement Batch record in the batch table
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    -- Get the details of duplicate batch id
    CURSOR c_chk_dup_batch_dtls(
                                cp_batch_id  igf_gr_rfms_batch_all.batch_id%TYPE
                               ) IS
      SELECT pb.rfmb_id
        FROM igf_gr_rfms_batch_all pb
       WHERE pb.batch_id = cp_batch_id;

    lc_chk_dup_batch_dtls  c_chk_dup_batch_dtls%ROWTYPE;

    l_row_id             ROWID;
    l_rfmb_id            igf_gr_rfms_batch_all.rfmb_id%TYPE;
    l_batch_id           igf_gr_rfms_batch_all.batch_id%TYPE;
    l_rfms_ack_batch_id  igf_gr_rfms_batch_all.rfms_ack_batch_id%TYPE;
    l_data_rec_length    igf_gr_rfms_batch_all.data_rec_length%TYPE;

  BEGIN

    -- Check if duplicate batch records exists in the system, if present then return the existing batch id
    OPEN c_chk_dup_batch_dtls(p_pell_disb_int.disburse_batch_id_txt);
    FETCH c_chk_dup_batch_dtls INTO lc_chk_dup_batch_dtls;
    CLOSE c_chk_dup_batch_dtls;

    IF (lc_chk_dup_batch_dtls.rfmb_id IS NOT NULL) THEN
      RETURN lc_chk_dup_batch_dtls.rfmb_id;
    END IF;


    -- Ack Batch id is needed only if ack data is not null.
    IF (p_pell_disb_int.disburse_batch_ack_date IS NOT NULL) THEN
      l_rfms_ack_batch_id := p_pell_disb_int.disburse_batch_id_txt;
    ELSE
      l_rfms_ack_batch_id := NULL;
    END IF;


    -- Create Pell Batch Record
    l_row_id := NULL;
    l_rfmb_id := -1;
    igf_gr_rfms_batch_pkg.insert_row(
                                     x_rowid                => l_row_id,
                                     x_rfmb_id              => l_rfmb_id,
                                     x_batch_id             => p_pell_disb_int.disburse_batch_id_txt,
                                     x_data_rec_length      => 100,
                                     x_ope_id               => p_ope_cd,
                                     x_software_providor    => NULL,
                                     x_rfms_process_dt      => p_pell_disb_int.disburse_batch_process_date,
                                     x_rfms_ack_dt          => p_pell_disb_int.disburse_batch_ack_date,
                                     x_rfms_ack_batch_id    => l_rfms_ack_batch_id,
                                     x_reject_reason        => NULL,
                                     x_mode                 => 'R'
                                    );

    RETURN l_rfmb_id;

  EXCEPTION
    WHEN OTHERS THEN
      IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_gr_li_import.create_pell_disb_batch.exception', SQLERRM );
      END IF;
      fnd_message.set_name('IGF','IGF_GR_LI_BDINSRT_FAIL');
      fnd_message.set_token('BATCH_NUM',p_pell_disb_int.disburse_batch_id_txt);
      fnd_message.set_token('ORIG_ID',p_pell_disb_int.origination_id_txt);
      fnd_message.set_token('DISB_NUM',p_pell_disb_int.disbursement_num);
      igs_ge_msg_stack.add;
      RETURN -1;

  END create_pell_disb_batch;


  FUNCTION create_pell_disb(
                            p_pell_disb_int  c_pell_disb_int%ROWTYPE,
                            p_rfmb_id        igf_gr_rfms_batch_all.rfmb_id%TYPE,
                            p_disb_date      igf_aw_awd_disb_all.disb_date%TYPE,
                            p_disb_amt       igf_aw_awd_disb_all.disb_net_amt%TYPE
                           ) RETURN BOOLEAN AS
    /*
    ||  Created By : brajendr
    ||  Created On : 19-Jun-2003
    ||  Purpose : Creats the Pell Disbursement records for context Pell Origination record
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    l_row_id      ROWID;
    l_rfmd_id     igf_gr_rfms_disb.rfmd_id%TYPE;
    l_db_cr_flag  igf_gr_rfms_disb.db_cr_flag%TYPE;

  BEGIN

    -- Set the dibursement Sign Flag based on the Disb Accepted amount
    IF (p_pell_disb_int.disb_accpt_amt >= 0) THEN
      l_db_cr_flag := 'P';
    ELSE
      l_db_cr_flag := 'N';
    END IF;


    -- Create Pell Origination Record in the production table
    l_row_id  := NULL;
    l_rfmd_id := NULL;
    igf_gr_rfms_disb_pkg.insert_row(
                                    x_mode                       => 'R',
                                    x_rowid                      => l_row_id,
                                    x_rfmd_id                    => l_rfmd_id,
                                    x_origination_id             => p_pell_disb_int.origination_id_txt,
                                    x_disb_ref_num               => p_pell_disb_int.disbursement_num,
                                    x_disb_dt                    => p_disb_date,
                                    x_disb_amt                   => NVL(p_pell_disb_int.disb_accpt_amt,p_disb_amt), -- If the disb ack status is R or N then, get the amt from awd disb
                                    x_db_cr_flag                 => l_db_cr_flag,
                                    x_disb_ack_act_status        => p_pell_disb_int.disb_ack_act_flag,
                                    x_disb_status_dt             => p_pell_disb_int.disb_status_date,
                                    x_accpt_disb_dt              => p_pell_disb_int.accpt_disb_date,
                                    x_disb_accpt_amt             => p_pell_disb_int.disb_accpt_amt,
                                    x_accpt_db_cr_flag           => p_pell_disb_int.disbursement_sign_flag,
                                    x_disb_ytd_amt               => p_pell_disb_int.disb_ytd_amt,
                                    x_pymt_prd_start_dt          => p_pell_disb_int.pymt_prd_start_date,
                                    x_accpt_pymt_prd_start_dt    => p_pell_disb_int.accpt_pymt_prd_start_date,
                                    x_edit_code                  => p_pell_disb_int.edit_codes_txt,
                                    x_rfmb_id                    => p_rfmb_id,
                                    x_ed_use_flags               => p_pell_disb_int.ed_use_flags
                                   );

    UPDATE igf_aw_li_pdb_ints
       SET last_updated_by   = fnd_global.user_id,
           last_update_date  = SYSDATE,
           last_update_login = fnd_global.login_id
     WHERE ci_alternate_code  = p_pell_disb_int.ci_alternate_code
       AND person_number      = p_pell_disb_int.person_number
       AND award_number_txt   = p_pell_disb_int.award_number_txt
       AND origination_id_txt = p_pell_disb_int.origination_id_txt
       AND disbursement_num   = p_pell_disb_int.disbursement_num;

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_gr_li_import.create_pell_disb.exception', SQLERRM );
      END IF;
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_GR_LI_IMPORT.CREATE_PELL_DISB');
      igs_ge_msg_stack.add;
      RETURN FALSE;

  END create_pell_disb;


  FUNCTION import_pell_disb(
                            p_pell_disb_int  c_pell_disb_int%ROWTYPE,
                            p_ope_cd         igf_aw_li_pell_ints.ope_cd%TYPE
                           ) RETURN VARCHAR2 AS
    /*
    ||  Created By : brajendr
    ||  Created On : 19-Jun-2003
    ||  Purpose : Import Pell Disbursement records from the legacy interface table to the production tables
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    -- Get the Award details for the Context pell
    CURSOR c_awd_disb(
                      cp_award_id  igf_aw_award_all.award_id%TYPE,
                      cp_disb_num  igf_aw_awd_disb_all.disb_num%TYPE
                     ) IS
      SELECT disb.disb_date, disb.disb_gross_amt, disb.disb_net_amt
        FROM igf_aw_awd_disb_all disb
       WHERE disb.award_id = cp_award_id
         AND disb.disb_num = cp_disb_num
         AND disb.trans_type = 'A';

    lc_awd_disb  c_awd_disb%ROWTYPE;

    l_rfmb_id             igf_gr_rfms_batch_all.rfmb_id%TYPE;
    l_debug_str           fnd_log_messages.message_text%TYPE := 'IGFGR10B.pls Function import_pell_disb :: ';
    l_disb_import_status  VARCHAR2(1) := 'I';
    l_disb_batch_id       VARCHAR2(30);

  BEGIN

    -- Check whether the disbursement record is present in the Award disbursement table.
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Checking Awd disb with Disb Num : ' || p_pell_disb_int.disbursement_num;
    END IF;

    OPEN c_awd_disb(g_award_id, p_pell_disb_int.disbursement_num);
    FETCH c_awd_disb INTO lc_awd_disb;
    IF (c_awd_disb%NOTFOUND) THEN
      fnd_message.set_name('IGF','IGF_GR_LI_DNUM_INVALID');
      fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
      CLOSE c_awd_disb;
      IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_gr_li_import.import_pell_disb.debug', l_debug_str);
        l_debug_str := NULL;
      END IF;
      l_disb_import_status := 'E';
      RETURN l_disb_import_status;
    END IF;
    CLOSE c_awd_disb;


    -- Validate Acknowledgement Status
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Acknowledgement Status : ' || p_pell_disb_int.disb_ack_act_flag;
    END IF;

    IF (p_pell_disb_int.disb_ack_act_flag IS NOT NULL) AND
       ( (igf_ap_gen.get_aw_lookup_meaning('IGF_GR_ORIG_STATUS', p_pell_disb_int.disb_ack_act_flag, g_sys_award_year) IS NULL) OR
         (p_pell_disb_int.disb_ack_act_flag IN ('S','D')) )
    THEN

      fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
      fnd_message.set_token('FIELD', 'DISB_ACK_ACT_FLAG');
      fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
      l_disb_import_status := 'E';
    END IF;


    -- Validate Disbursement Batch ID
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Disbursement Batch ID : ' || p_pell_disb_int.disburse_batch_id_txt;
    END IF;

    l_disb_batch_id := '#D' ||                                                  -- Batch Code
                       igf_gr_gen.get_cycle_year(g_cal_type, g_seq_number) ||   -- Cycle year
                       g_reporting_pell_id;  --pell_setup.rep_pell_id;                               -- Reporting PELL ID

    IF ( SUBSTR(p_pell_disb_int.disburse_batch_id_txt, 0, 12) <> l_disb_batch_id ) OR
       ( (p_pell_disb_int.disb_ack_act_flag IN ('R','N')) AND
         (p_pell_disb_int.disburse_batch_id_txt IS NOT NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_DBTH_INVALID');
      fnd_message.set_token('DISB_BATCH_ID',p_pell_disb_int.disburse_batch_id_txt);
      fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
      l_disb_import_status := 'E';
    END IF;


    -- Validate Action Code status date
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Action Code status date : ' || p_pell_disb_int.disb_status_date;
    END IF;

    IF ( (p_pell_disb_int.disb_ack_act_flag IN ('N','R')) AND
         (p_pell_disb_int.disb_status_date IS NOT NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_DBSD_INVALID_1');
      fnd_message.set_token('DISB_STAT_DT',p_pell_disb_int.disb_status_date);
      fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
      l_disb_import_status := 'E';
    ELSIF ( (p_pell_disb_int.disb_ack_act_flag IN ('A','C','E')) AND
            (p_pell_disb_int.disb_status_date IS NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_DBSD_INVALID_2');
      fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
      l_disb_import_status := 'E';
    END IF;


    -- Validate Process Date
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Process Date : ' || p_pell_disb_int.disburse_batch_process_date;
    END IF;

    IF ( (p_pell_disb_int.disb_ack_act_flag IN ('N','R')) AND
         (p_pell_disb_int.disburse_batch_process_date IS NOT NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_PRDT_INVALID_1');
      fnd_message.set_token('PROC_DATE',p_pell_disb_int.disburse_batch_process_date);
      fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
      l_disb_import_status := 'E';
    ELSIF ( (p_pell_disb_int.disb_ack_act_flag IN ('A','C','E')) AND
            (p_pell_disb_int.disburse_batch_process_date IS NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_PRDT_INVALID_2');
      fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
      l_disb_import_status := 'E';
    END IF;


    -- Validate Payment Period start date
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Payment Period Start Date : ' || p_pell_disb_int.pymt_prd_start_date;
    END IF;
    IF ( (p_pell_disb_int.disb_ack_act_flag IN ('N','R')) AND
         (p_pell_disb_int.pymt_prd_start_date IS NOT NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_PMST_INVALID');
      fnd_message.set_token('PM_STDT',p_pell_disb_int.pymt_prd_start_date);
      fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
      l_disb_import_status := 'E';
    END IF;


    -- Validate Accepted Disbursement Date
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Accepted Disbursement Date : ' || p_pell_disb_int.accpt_disb_date;
    END IF;
    IF ( (p_pell_disb_int.disb_ack_act_flag IN ('N','R')) AND
         (p_pell_disb_int.accpt_disb_date IS NOT NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_ADBDT_INVALID_1');
      fnd_message.set_token('ACC_DISB_DT',p_pell_disb_int.accpt_disb_date);
      fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
      l_disb_import_status := 'E';
    ELSIF ( (p_pell_disb_int.disb_ack_act_flag IN ('A','C','E')) AND
            (p_pell_disb_int.accpt_disb_date IS NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_ADBDT_INVALID_2');
      fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
      l_disb_import_status := 'E';
    END IF;


    -- Validate Accepted Disbursement Amount
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Accepted Disbursement Amount : ' || p_pell_disb_int.disb_accpt_amt;
    END IF;
    IF ( (p_pell_disb_int.disb_ack_act_flag IN ('N','R')) AND
         (p_pell_disb_int.disb_accpt_amt IS NOT NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_DBAC_AMT_INVALID_1');
      fnd_message.set_token('DISB_AC_AMT',p_pell_disb_int.disb_accpt_amt);
      fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
      l_disb_import_status := 'E';
    ELSIF (p_pell_disb_int.disb_ack_act_flag IN ('A','C','E')) THEN

      -- Disb Acpt Amt is mandatory if ack status is Accepted, Corrected or Rejected
      IF p_pell_disb_int.disb_accpt_amt IS NULL THEN
        fnd_message.set_name('IGF','IGF_GR_LI_DBAC_AMT_INVALID_2');
        fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
        l_disb_import_status := 'E';
      -- Validate Disbursement Amount against the Disb table
      ELSIF p_pell_disb_int.disb_accpt_amt <> lc_awd_disb.disb_net_amt THEN
        fnd_message.set_name('IGF','IGF_GR_LI_DAMT_INVALID');
        fnd_message.set_token('INT_AMT',p_pell_disb_int.disb_accpt_amt);
        fnd_message.set_token('SYS_AMT',lc_awd_disb.disb_net_amt);
        fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);

      END IF;

    END IF;


    -- Validate Accepted Disbursement Amount Sign Indicator
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Accepted Disbursement Amount Sign Indicator : ' || p_pell_disb_int.disbursement_sign_flag;
      l_debug_str := l_debug_str || ', Accepted Disbursment Amount : ' || p_pell_disb_int.disb_accpt_amt;
    END IF;
    IF ( (p_pell_disb_int.disb_ack_act_flag IN ('N','R')) AND
         (p_pell_disb_int.disbursement_sign_flag IS NOT NULL) )

    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_ADBCR_INVALID_1');
      fnd_message.set_token('ACC_DBCR_FLAG',p_pell_disb_int.disbursement_sign_flag);
      fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
      l_disb_import_status := 'E';

    ELSIF ( (p_pell_disb_int.disb_ack_act_flag IN ('A','C','E')) AND
            (p_pell_disb_int.disbursement_sign_flag IS NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_ADBCR_INVALID_2');
      fnd_message.set_token('ACC_DBCR_FLAG',p_pell_disb_int.disbursement_sign_flag);
      fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
      l_disb_import_status := 'E';

    END IF;

    -- Validate Accepted Disbursment Amount
    -- Flag should be 'P' if the disb accepted amount is positive else 'N'
    IF ( (p_pell_disb_int.disbursement_sign_flag IS NOT NULL) AND
         (p_pell_disb_int.disb_ack_act_flag IN ('A','C','E')) )
    THEN

      IF (p_pell_disb_int.disbursement_sign_flag = 'P' AND NVL(p_pell_disb_int.disb_accpt_amt,1) <= 0 ) OR
         (p_pell_disb_int.disbursement_sign_flag = 'N' AND NVL(p_pell_disb_int.disb_accpt_amt,-1) > 0 ) OR
         (p_pell_disb_int.disbursement_sign_flag NOT IN ('P','N'))
      THEN
        fnd_message.set_name('IGF','IGF_GR_LI_ADBCR_INVALID_3');
        fnd_message.set_token('ACC_DBCR_FLAG',p_pell_disb_int.disbursement_sign_flag);
        fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
        l_disb_import_status := 'E';
      END IF;
    END IF;

    -- Validate Accepted Payment Period start date
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Accepted Payment Period start date : ' || p_pell_disb_int.accpt_pymt_prd_start_date;
    END IF;
    IF ( (p_pell_disb_int.disb_ack_act_flag IN ('N','R')) AND
         (p_pell_disb_int.accpt_pymt_prd_start_date IS NOT NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_APMST_INVALID');
      fnd_message.set_token('ACC_PM_STDT',p_pell_disb_int.accpt_pymt_prd_start_date);
      fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
      l_disb_import_status := 'E';
    END IF;


    -- Validate Disbursement Year to Date Amount
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Disbursement Year to Date Amount : ' || p_pell_disb_int.disb_ytd_amt;
    END IF;
    IF ( (p_pell_disb_int.disb_ack_act_flag IN ('N','R')) AND
         (p_pell_disb_int.disb_ytd_amt IS NOT NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_DYTD_INVALID_1');
      fnd_message.set_token('YTD_AMT',p_pell_disb_int.disb_ytd_amt);
      fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
      l_disb_import_status := 'E';

    ELSIF ( (p_pell_disb_int.disb_ack_act_flag IN ('A','C','E')) AND
            (p_pell_disb_int.disb_ytd_amt IS NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_DYTD_INVALID_2');
      fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
      l_disb_import_status := 'E';

    END IF;


    -- Validate Edit Code
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Edit Code : ' || p_pell_disb_int.edit_codes_txt;
    END IF;
    IF ( (p_pell_disb_int.disb_ack_act_flag IN ('N','R')) AND
         (p_pell_disb_int.edit_codes_txt IS NOT NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_REJCD_INVALID');
      fnd_message.set_token('REJ_CODES',p_pell_disb_int.edit_codes_txt);
      fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
      l_disb_import_status := 'E';
    END IF;


    -- Validate ED Use Flags
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', ED Use Flags : ' || p_pell_disb_int.ed_use_flags;
    END IF;
    IF ( (p_pell_disb_int.disb_ack_act_flag IN ('N','R')) AND
         (p_pell_disb_int.ed_use_flags IS NOT NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_DEDF_INVALID');
      fnd_message.set_token('DISB_ED_FLAGS',p_pell_disb_int.ed_use_flags);
      fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
      l_disb_import_status := 'E';
    END IF;

    -- Completed all validations for Pell Disbursements
    IF l_disb_import_status <> 'E' THEN

      -- Create the Disbursement batch record if Pell Disb in Ack status
      l_rfmb_id := NULL;
      IF ( (p_pell_disb_int.disb_ack_act_flag IS NOT NULL) AND p_pell_disb_int.disb_ack_act_flag NOT IN ('R','N')) THEN

        IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
          l_debug_str := l_debug_str || ' :: Creating Pell Batch';
        END IF;
        l_rfmb_id := create_pell_disb_batch(p_pell_disb_int, p_ope_cd);

        -- Create Pell Disbursement only if the Pell Batch is created
        IF l_rfmb_id = -1  THEN

          l_disb_import_status := 'E';
          IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_aw_li_import.import_pell_disb.debug', l_debug_str || ' : Pell Disb Batch not created' || ' Ret status : '|| l_disb_import_status);
            l_debug_str := NULL;
          END IF;

          RETURN l_disb_import_status;
        END IF;
      END IF;

    ELSE
      IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_aw_li_import.import_pell_disb.debug', l_debug_str || ' : Pell Disb Batch not created' || ' Ret status : '|| l_disb_import_status);
        l_debug_str := NULL;
      END IF;
      RETURN l_disb_import_status;
    END IF;

    -- Create Pell Disbursement
    IF l_disb_import_status <> 'E' AND (NOT (igf_sl_dl_validation.check_full_participant (g_cal_type, g_seq_number,'PELL'))) THEN
      IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
        l_debug_str := l_debug_str || ' :: Creating Pell Disbursement';
      END IF;
      IF NOT create_pell_disb(p_pell_disb_int, l_rfmb_id, lc_awd_disb.disb_date, lc_awd_disb.disb_net_amt) THEN

        l_disb_import_status := 'E';
        IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
          l_debug_str := l_debug_str || ' :: Pell Disbursement not created Ret status : '|| l_disb_import_status;
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_gr_li_import.import_pell_disb.debug', l_debug_str );
          l_debug_str := NULL;
        END IF;
        RETURN l_disb_import_status;
      END IF;
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ' :: IMPORT_PELL_DISB Successful :: Ret status : '|| l_disb_import_status;
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_gr_li_import.import_pell_disb.debug', l_debug_str );
      l_debug_str := NULL;
    END IF;
    RETURN l_disb_import_status;

  EXCEPTION
    WHEN OTHERS THEN
      IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_gr_li_import.import_pell_disb.exception', l_debug_str || SQLERRM );
      END IF;
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_GR_LI_IMPORT.IMPORT_PELL_DISB');
      igs_ge_msg_stack.add;
      RETURN 'E';

  END import_pell_disb;


  FUNCTION create_pell_orig_batch(
                                  p_pell_orig_int  c_pell_orig_int%ROWTYPE
                                 ) RETURN NUMBER AS
    /*
    ||  Created By : brajendr
    ||  Created On : 19-Jun-2003
    ||  Purpose : Creates the Pell origination batch records for the legacy pell record
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    -- Get the details of duplicate batch id
    CURSOR c_chk_dup_batch_dtls(
                                cp_batch_id  igf_gr_rfms_batch_all.batch_id%TYPE
                               ) IS
      SELECT pb.rfmb_id
        FROM igf_gr_rfms_batch_all pb
       WHERE pb.batch_id = cp_batch_id;

    lc_chk_dup_batch_dtls  c_chk_dup_batch_dtls%ROWTYPE;

    l_row_id             ROWID;
    l_rfmb_id            igf_gr_rfms_batch_all.rfmb_id%TYPE;
    l_batch_id           igf_gr_rfms_batch_all.batch_id%TYPE;
    l_rfms_ack_batch_id  igf_gr_rfms_batch_all.rfms_ack_batch_id%TYPE;
    l_data_rec_length    igf_gr_rfms_batch_all.data_rec_length%TYPE;

  BEGIN

    -- Check if duplicate batch records exists in the system, if present then return the existing batch id
    OPEN c_chk_dup_batch_dtls(p_pell_orig_int.orig_send_batch_id_txt);
    FETCH c_chk_dup_batch_dtls INTO lc_chk_dup_batch_dtls;
    CLOSE c_chk_dup_batch_dtls;

    IF lc_chk_dup_batch_dtls.rfmb_id IS NOT NULL THEN
      RETURN lc_chk_dup_batch_dtls.rfmb_id;
    END IF;


    -- Ack Batch id is needed only if ack data is not null.
    IF p_pell_orig_int.rfms_ack_date IS NOT NULL THEN
      l_rfms_ack_batch_id := p_pell_orig_int.orig_send_batch_id_txt;
    ELSE
      l_rfms_ack_batch_id := NULL;
    END IF;


    -- Create Pell Batch Record
    l_row_id  := NULL;
    l_rfmb_id := -1;
    igf_gr_rfms_batch_pkg.insert_row(
                                     x_rowid                => l_row_id,
                                     x_rfmb_id              => l_rfmb_id,
                                     x_batch_id             => p_pell_orig_int.orig_send_batch_id_txt,
                                     x_data_rec_length      => 300,
                                     x_ope_id               => p_pell_orig_int.ope_cd,
                                     x_software_providor    => NULL,
                                     x_rfms_process_dt      => p_pell_orig_int.rfms_process_date,
                                     x_rfms_ack_dt          => p_pell_orig_int.rfms_ack_date,
                                     x_rfms_ack_batch_id    => l_rfms_ack_batch_id,
                                     x_reject_reason        => NULL,
                                     x_mode                 => 'R'
                                    );

    RETURN l_rfmb_id;

  EXCEPTION
    WHEN OTHERS THEN
      IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_gr_li_import.create_pell_orig_batch.exception', SQLERRM );
      END IF;
      fnd_message.set_name('IGF','IGF_GR_LI_BINSERT_FAIL');
      fnd_message.set_token('BATCH_NUM',p_pell_orig_int.orig_send_batch_id_txt);
      igs_ge_msg_stack.add;
      RETURN -1;

  END create_pell_orig_batch;


  FUNCTION create_pell_orig(
                            p_pell_orig_int  c_pell_orig_int%ROWTYPE,
                            p_isir_details   c_isir_details%ROWTYPE,
                            p_rfmb_id        igf_gr_rfms_batch_all.rfmb_id%TYPE
                           ) RETURN BOOLEAN AS
    /*
    ||  Created By : brajendr
    ||  Created On : 19-Jun-2003
    ||  Purpose : Creates Pell Origination record for the legacy interface record
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    CURSOR c_pymt_prds_n_date(
                              cp_award_id igf_aw_award_all.award_id%TYPE
                             ) IS
    SELECT adisb1.disb_num, adisb2.disb_date
      FROM igf_aw_awd_disb adisb1, igf_aw_awd_disb adisb2
     WHERE adisb1.award_id = cp_award_id
       AND adisb1.disb_num IN ( SELECT MAX(adisb11.disb_num)
                                  FROM igf_aw_awd_disb adisb11
                                 WHERE adisb11.award_id = adisb1.award_id
                              )
       AND adisb1.award_id  = adisb2.award_id
       AND adisb2.disb_num IN ( SELECT MIN(adisb11.disb_num)
                                  FROM igf_aw_awd_disb adisb11
                                 WHERE adisb11.award_id = adisb2.award_id
                              );

    lc_pymt_prds_n_date   c_pymt_prds_n_date%ROWTYPE;

    l_row_id       ROWID;
    l_debug_str    fnd_log_messages.message_text%TYPE := 'IGFGR10B.pls Procedure create_pell_orig :: ';

  BEGIN

    -- Get the Total Payment periods and First disbursement date
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Fetching Disb dates for Award ID : ' || g_award_id;
    END IF;
    OPEN  c_pymt_prds_n_date(g_award_id);
    FETCH c_pymt_prds_n_date INTO lc_pymt_prds_n_date;
    CLOSE c_pymt_prds_n_date;

    -- Create Pell Origination Record in the production table
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Creating RFMS record :: Total Disb Num : ' || lc_pymt_prds_n_date.disb_num;
      l_debug_str := l_debug_str || ', Disb Date : ' || lc_pymt_prds_n_date.disb_date;
    END IF;

    l_row_id := NULL;

    igf_gr_rfms_pkg.insert_row(
                               x_rowid                     => l_row_id,
                               x_origination_id            => p_pell_orig_int.origination_id_txt,
                               x_ci_cal_type               => g_cal_type,
                               x_ci_sequence_number        => g_seq_number,
                               x_base_id                   => g_base_id,
                               x_award_id                  => g_award_id,
                               x_rfmb_id                   => p_rfmb_id,
                               x_sys_orig_ssn              => p_isir_details.original_ssn,
                               x_sys_orig_name_cd          => p_isir_details.orig_name_id,
                               x_transaction_num           => p_pell_orig_int.transaction_num_txt,
                               x_efc                       => p_pell_orig_int.efc_amt,
                               x_ver_status_code           => p_pell_orig_int.verification_status_code,
                               x_secondary_efc             => p_pell_orig_int.secondary_efc_amt,
                               x_secondary_efc_cd          => p_pell_orig_int.secondary_efc_code,
                               x_pell_amount               => p_pell_orig_int.pell_award_amt,
                               x_pell_profile              => NULL,
                               x_enrollment_status         => p_pell_orig_int.enrollment_status_flag,
                               x_enrollment_dt             => p_pell_orig_int.enrollment_date,
                               x_coa_amount                => p_pell_orig_int.pell_coa_amt,
                               x_academic_calendar         => p_pell_orig_int.academic_calendar_cd,
                               x_payment_method            => p_pell_orig_int.payment_method_code,
                               x_total_pymt_prds           => lc_pymt_prds_n_date.disb_num,
                               x_incrcd_fed_pell_rcp_cd    => p_pell_orig_int.incrcd_fed_pell_rcp_code,
                               x_attending_campus_id       => g_attending_pell_cd,
                               x_est_disb_dt1              => lc_pymt_prds_n_date.disb_date,
                               x_orig_action_code          => p_pell_orig_int.orig_status_code,
                               x_orig_status_dt            => p_pell_orig_int.orig_status_date,
                               x_orig_ed_use_flags         => p_pell_orig_int.orig_ed_use_flags_txt,
                               x_ft_pell_amount            => p_pell_orig_int.ft_sch_pell_amt,
                               x_prev_accpt_efc            => p_pell_orig_int.prev_accpt_efc_amt,
                               x_prev_accpt_tran_no        => p_pell_orig_int.prev_accpt_tran_num_txt,
                               x_prev_accpt_sec_efc_cd     => p_pell_orig_int.prev_accpt_sec_efc_cd,
                               x_prev_accpt_coa            => p_pell_orig_int.prev_accpt_coa_amt,
                               x_orig_reject_code          => p_pell_orig_int.orig_reject_codes_txt,
                               x_wk_inst_time_calc_pymt    => p_pell_orig_int.wk_inst_time_calc_pymt_num,
                               x_wk_int_time_prg_def_yr    => p_pell_orig_int.wk_int_time_prg_def_yr_num,
                               x_cr_clk_hrs_prds_sch_yr    => p_pell_orig_int.cr_clk_hrs_prds_sch_yr_num,
                               x_cr_clk_hrs_acad_yr        => p_pell_orig_int.cr_clk_hrs_acad_yr_num,
                               x_inst_cross_ref_cd         => p_pell_orig_int.inst_cross_ref_cd,
                               x_low_tution_fee            => p_pell_orig_int.low_tution_fee_cd,
                               x_rec_source                => 'B',
                               x_pending_amount            => p_pell_orig_int.pending_amt,
                               x_birth_dt                  => p_isir_details.date_of_birth,
                               x_last_name                 => p_isir_details.last_name,
                               x_first_name                => p_isir_details.first_name,
                               x_middle_name               => p_isir_details.middle_initial,
                               x_current_ssn               => p_isir_details.current_ssn,
                               x_legacy_record_flag        => 'Y',
                               x_mode                      => 'R',
                               x_reporting_pell_cd         => g_reporting_pell_id,
                               x_rep_entity_id_txt         => p_pell_orig_int.rep_entity_id_txt,
                               x_atd_entity_id_txt         => p_pell_orig_int.atd_entity_id_txt,
                               x_note_message              => NULL,
                               x_full_resp_code            => NULL,
                               x_document_id_txt           => NULL
                              );

    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_gr_li_import.create_pell_orig.debug', l_debug_str || ', Created Pell Origination record Orig ID :' || p_pell_orig_int.origination_id_txt);
      l_debug_str := NULL;
    END IF;

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_gr_li_import.create_pell_orig.exception', SQLERRM );
      END IF;
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_GR_LI_IMPORT.CREATE_PELL_ORIG');
      igs_ge_msg_stack.add;
      RETURN FALSE;

  END create_pell_orig;


  FUNCTION import_pell_orig(
                            p_pell_orig_int  c_pell_orig_int%ROWTYPE
                           ) RETURN VARCHAR2 AS
    /*
    ||  Created By : brajendr
    ||  Created On : 19-Jun-2003
    ||  Purpose : Import pell origination records from the legacy interface table to the production tables
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||  rasahoo         16-Feb-2004     Bug #  3441605 Changed the cursor "cur_get_attendance_type_code"
    ||                                  Now it will select "Base_attendance_type_code" instead of "attendance_type_code"
    ||                                  Removed cursor "c_get_enrl_status" as it is no longer used.
    ||  ugummall        05-DEC-2003     Bug 3252832. FA 131 - COD Updates
    ||                                  Changed the logic for validating the enrollment status w.r.t. FA 131.
    ||                                  Added the cursor cur_get_attendance_type_code for above validation.
    ||                                  Removed the validation for Scheduled Pell Award.
    ||  rasahoo         02-Sep-2003     changed the cursor C_GET_ENRL_STATUS.
    ||                                  Removed the join with IGF_AP_FA_BASE_H
    ||                                  and got the DERIVED_ATTEND_TYPE from IGF_AP_GEN_001
    ||                                  and changed the data type of l_enrl_status from igf_ap_fa_base_h.derived_attend_type%TYPE
    ||                                  as part of  FA-114(Obsoletion of FA base record History)
    ||
    */

    -- Get the Award details for the refference award number if present
    CURSOR c_awd_details(
                         cp_base_id       igf_ap_fa_base_rec_all.base_id%TYPE,
                         cp_award_number  igf_aw_award_all.award_number_txt%TYPE
                         ) IS
      SELECT awd.award_id, awd.offered_amt, awd.accepted_amt, awd.fund_id
        FROM igf_aw_award_all awd
       WHERE awd.base_id = cp_base_id
         AND awd.award_number_txt IS NOT NULL
         AND awd.award_number_txt = cp_award_number
         AND awd.award_status <> 'SIMULATED';

    lc_awd_details        c_awd_details%ROWTYPE;


    -- Get the details of RFMS for the context award id
    CURSOR c_chk_rfms_awd(
                          cp_award_id   igf_aw_award_all.award_id%TYPE
                         ) IS
      SELECT rfms.origination_id
        FROM igf_gr_rfms_all rfms
       WHERE rfms.award_id = cp_award_id;

    lc_chk_rfms_awd   c_chk_rfms_awd%ROWTYPE;

    CURSOR c_get_remain_disb(
                             cp_award_id   igf_aw_award_all.award_id%TYPE
                            ) IS
    SELECT ad.disb_num, ad.disb_date, ad.disb_accepted_amt
      FROM igf_aw_awd_disb_all ad
     WHERE ad.award_id = cp_award_id
       AND NOT EXISTS ( SELECT pdisb.disb_ref_num
                          FROM igf_gr_rfms_all porig, igf_gr_rfms_disb_all pdisb
                         WHERE porig.origination_id = pdisb.origination_id
                           AND ad.award_id = porig.award_id
                           AND ad.disb_num = pdisb.disb_ref_num);

    lc_isir_details          c_isir_details%ROWTYPE;
    l_pell_import_status     igf_aw_li_pell_ints.import_status_type%TYPE := 'I';
    l_enrl_status            igs_en_stdnt_ps_att_all.derived_att_type%TYPE;
    l_origination_id         igf_aw_li_pell_ints.origination_id_txt%TYPE;
    l_rfmb_id                igf_gr_rfms_batch_all.rfmb_id%TYPE;
    l_db_cr_flag             igf_gr_rfms_disb.db_cr_flag%TYPE;
    l_rfmd_id                igf_gr_rfms_disb.rfmd_id%TYPE;
    l_disb_num_prmpt         igf_lookups_view.meaning%TYPE;
    l_processing             igf_lookups_view.meaning%TYPE;
    l_debug_str              fnd_log_messages.message_text%TYPE := 'IGFGR10B.pls Procedure import_pell_orig (1) :: ';
    l_error                  VARCHAR2(30);
    l_orig_batch_id          VARCHAR2(30);
    l_pell_mat               VARCHAR2(10);
    l_pell_disb_full_status  VARCHAR2(1);
    l_pell_disb_indv_status  VARCHAR2(1);
    l_derived_attend_type    VARCHAR2(30);
    l_office_cd              VARCHAR2(30);
    l_ret_status             VARCHAR2(1);
    l_msg_data               VARCHAR2(30);
    ln_rem_disb_cnt          NUMBER := 0;
    l_temp_aid               NUMBER;
    l_row_id                 ROWID;

   --  Get the Base attendance type code for context Award Id
    CURSOR cur_get_attendance_type_code(cp_award_id igf_aw_award_all.award_id%TYPE) IS
      SELECT    base_attendance_type_code
        FROM    igf_aw_awd_disb_all
       WHERE    award_id = cp_award_id
       GROUP BY base_attendance_type_code;

    rec_get_attendance_type_code  cur_get_attendance_type_code%ROWTYPE;

  BEGIN

    -- Start validation of Pell record.
    SAVEPOINT SP_PELL;

    -- Validate the Award Number in the production table
    g_award_id := NULL;
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Fetching production table award details with Awd Number : '|| p_pell_orig_int.award_number_txt;
    END IF;

    OPEN c_awd_details(g_base_id, p_pell_orig_int.award_number_txt);
    FETCH c_awd_details INTO lc_awd_details;
    IF c_awd_details%NOTFOUND THEN
      fnd_message.set_name('IGF','IGF_GR_LI_AWD_INVALID');
      fnd_file.put_line(fnd_file.log, fnd_message.get);

      CLOSE c_awd_details;
      ROLLBACK TO SP_PELL;
      l_pell_import_status := 'E';
      IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_gr_li_import.import_pell_orig.debug',
           l_debug_str || 'Award ref not present in production table :'|| l_pell_import_status);
      END IF;
      RETURN l_pell_import_status;

    END IF;
    CLOSE c_awd_details;

    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ' Award ID : ' || lc_awd_details.award_id;
    END IF;

    g_award_id := lc_awd_details.award_id;


    -- Validate if award id is already present in the GR RFMS table
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Dup Award ID chk : ';
    END IF;
    OPEN c_chk_rfms_awd(g_award_id);
    FETCH c_chk_rfms_awd INTO lc_chk_rfms_awd;
    CLOSE c_chk_rfms_awd;

    IF lc_chk_rfms_awd.origination_id IS NOT NULL THEN
      ROLLBACK TO SP_PELL;
      fnd_message.set_name('IGF','IGF_GR_LI_OINSERT_DUP_AWID');
      fnd_message.set_token('SYS_ORIG_ID',lc_chk_rfms_awd.origination_id);
      fnd_message.set_token('AWARD_ID',g_award_id);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';
      RETURN l_pell_import_status;
    END IF;


    -- Validate Transaction Number
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Transaction Number : ' || p_pell_orig_int.transaction_num_txt;
    END IF;
    --  Bug# 3089841 Added the check for the transaction_num to be NULL
    IF p_pell_orig_int.transaction_num_txt IS NULL OR TO_NUMBER(p_pell_orig_int.transaction_num_txt) < 1 OR  TO_NUMBER(p_pell_orig_int.transaction_num_txt) > 99 THEN
      fnd_message.set_name('IGF','IGF_GR_LI_TRNM_INVALID');
      fnd_message.set_token('TRNM',p_pell_orig_int.transaction_num_txt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';
    END IF;


    -- Fetch the ISIR Details of the new person,
    -- IF ISIR details are not present then log an error message proceed with new person
    OPEN c_isir_details(g_base_id, p_pell_orig_int.transaction_num_txt);
    FETCH c_isir_details INTO lc_isir_details;
    IF c_isir_details%NOTFOUND THEN

      IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
        l_debug_str := l_debug_str || ', ISIR Details not found : ';
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_gr_li_import.import_pell_orig.debug', l_debug_str);
        l_debug_str := NULL;
      END IF;
      --  Bug# 3089841 Changed the message
      fnd_message.set_name('IGF','IGF_GR_ISIR_NOT_FOUND');
      fnd_message.set_token('STUD',NULL);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      CLOSE c_isir_details;
      RETURN 'E';
    END IF;
    CLOSE c_isir_details;


    -- Validate Origination Status
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Origination Status : ' || p_pell_orig_int.orig_status_code;
    END IF;
    IF (p_pell_orig_int.orig_status_code IS NOT NULL) AND
       (igf_ap_gen.get_aw_lookup_meaning('IGF_GR_ORIG_STATUS', p_pell_orig_int.orig_status_code, g_sys_award_year) IS NULL OR
        p_pell_orig_int.orig_status_code IN ('S','D') )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_OSTS_INVALID');
      fnd_message.set_token('ORIG_STATUS',p_pell_orig_int.orig_status_code);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';
    END IF;

    -- nsidana 11/4/2003 FA126 Multiple FA offices.
    -- Validation for the attend_campus_id in the pell interface table.
    -- This validation needs to be done only in case of phase-in participant

    IF (NOT (igf_sl_dl_validation.check_full_participant (g_cal_type, g_seq_number,'PELL'))) THEN

        g_attending_pell_cd := NULL;

        IF(p_pell_orig_int.attending_campus_cd IS NOT NULL)
        THEN
            -- Derive the attending campus ID for the student and validate it against the values in the interface table. They shud match, else error.
            igf_sl_gen.get_stu_fao_code(g_base_id,'PELL_ID',l_office_cd,l_ret_status,l_msg_data);
            IF(l_ret_status = 'E')THEN
              -- return status is error then l_msg_data would have message name. Put it on the Stack and raise error.
              fnd_message.set_name('IGF',l_msg_data);
              fnd_file.put_line(fnd_file.log,fnd_message.get);
              l_pell_import_status := 'E';
            ELSE -- return status indicating success here
              IF((l_office_cd IS NOT NULL) AND (l_office_cd <> p_pell_orig_int.attending_campus_cd))
              THEN
               -- Raise error.
               fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
               fnd_message.set_token('FIELD','ATTENDING_CAMPUS_CD');
               fnd_file.put_line(fnd_file.log, fnd_message.get);
               l_pell_import_status := 'E';
              ELSE
                g_attending_pell_cd := TRIM(p_pell_orig_int.attending_campus_cd);
              END IF;
            END IF;
        ELSE -- Attend campus ID is null.

            igf_sl_gen.get_stu_fao_code(g_base_id,'PELL_ID',l_office_cd, l_ret_status,l_msg_data);
            IF(l_ret_status = 'E')
            THEN
               fnd_message.set_name('IGF',l_msg_data);
               fnd_file.put_line(fnd_file.log,fnd_message.get);
               l_pell_import_status := 'E';
            ELSIF(l_ret_status = 'S')
            THEN
              g_attending_pell_cd := l_office_cd;
            END IF;
        END IF;

        -- Derive the reporting Pell ID by making a call to the local fn.

        g_reporting_pell_id:=null;
        g_reporting_pell_id:=derive_rep_pell_id(p_pell_orig_int);
        IF (g_reporting_pell_id IS NULL) THEN
          fnd_message.set_name( 'IGF', 'IGF_GR_NOREP_PELL');
          fnd_message.set_token('STU_NUMBER',p_pell_orig_int.person_number);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          l_pell_import_status := 'E';
        END IF;

    END IF;



    -- Validate Origination ID
    -- Passing Attending Pell value to generate_orgination_id function instead of reporting pell id
    -- Use attending entity id if the award year is COD-XML processing
    l_origination_id := NULL;
    l_error          := NULL;

    IF igf_sl_dl_validation.check_full_participant (g_cal_type, g_seq_number,'PELL') THEN
        igf_gr_pell.generate_origination_id(
                                        g_base_id,
                                        g_atd_entity_id_txt,
                                        l_origination_id,
                                        l_error
                                       );
    ELSE
        igf_gr_pell.generate_origination_id(
                                        g_base_id,
                                        g_attending_pell_cd,
                                        l_origination_id,
                                        l_error
                                       );

    END IF;



    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Origination ID : ' || p_pell_orig_int.origination_id_txt;
      l_debug_str := l_debug_str || ', l_origination_id : ' || l_origination_id;
    END IF;

    IF l_origination_id IS NULL OR
       p_pell_orig_int.origination_id_txt <> l_origination_id OR
       l_error IS NOT NULL
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_ORIG_INVALID');
      fnd_message.set_token('ORIG_ID',p_pell_orig_int.origination_id_txt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';
    END IF;


    -- Validate Pell Origianation Batch ID
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Origianation Batch ID : ' || p_pell_orig_int.orig_send_batch_id_txt;
    END IF;

    l_orig_batch_id := '#O' ||                                                  -- Batch Code
                       igf_gr_gen.get_cycle_year(g_cal_type, g_seq_number) ||   -- Cycle year
                       g_reporting_pell_id;  --pell_setup.rep_pell_id;                               -- Reporting PELL ID

    IF ( SUBSTR(p_pell_orig_int.orig_send_batch_id_txt, 0, 12) <> l_orig_batch_id ) OR
       ( (p_pell_orig_int.orig_status_code IN ('R','N')) AND
         (p_pell_orig_int.orig_send_batch_id_txt IS NOT NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_OBID_INVALID');
      fnd_message.set_token('BATCH_ID',p_pell_orig_int.orig_send_batch_id_txt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';
    END IF;


    -- Validate Pell Cost of Attendance
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Pell COA : ' || p_pell_orig_int.pell_coa_amt;
    END IF;

    IF (p_pell_orig_int.pell_coa_amt < 0) OR
       (p_pell_orig_int.pell_coa_amt > 9999999)
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_COA_INVALID');
      fnd_message.set_token('PELL_COA',p_pell_orig_int.pell_coa_amt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';
    END IF;


    -- Validate Pell Alternate Expenses
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Pell Alternate Expenses : ' || p_pell_orig_int.pell_alt_exp_amt;
    END IF;

    IF (p_pell_orig_int.pell_alt_exp_amt < 0) OR
       (p_pell_orig_int.pell_alt_exp_amt > 9999999)
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_ALTEXP_INVALID');
      fnd_message.set_token('PELL_ALTEXP',p_pell_orig_int.pell_alt_exp_amt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';
    END IF;


    -- Validate Enrollment Status
    -- p_pell_orig_int.enrollment_status_flag NOT IN ('1','2','3','4','5') AND
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Enrollment Status : ' || p_pell_orig_int.enrollment_status_flag;
    END IF;

    IF (p_pell_orig_int.enrollment_status_flag IS NOT NULL) AND
       (igf_ap_gen.get_aw_lookup_meaning('IGF_AP_ENRL_STAT',p_pell_orig_int.enrollment_status_flag, g_sys_award_year) IS NULL )
    THEN
      fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
      fnd_message.set_token('FIELD', 'ENROLLMENT_STATUS_FLAG');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';
    END IF;

    -- Validate Enrollment status with the system enrollment status
    -- FA 131. Prepare l_enrl_status variable to validate with orig record's value.
    OPEN cur_get_attendance_type_code(g_award_id);
    FETCH cur_get_attendance_type_code INTO rec_get_attendance_type_code;

    IF (cur_get_attendance_type_code%NOTFOUND) THEN
      l_enrl_status := NULL;
    ELSE
      IF (cur_get_attendance_type_code%ROWCOUNT > 1) THEN
        l_enrl_status := '5';    -- 5 for Pell Attendance "Others"
      ELSIF (rec_get_attendance_type_code.base_attendance_type_code IS NULL) THEN
        -- cursor returned 1 row. And attendance_type_code is null
        l_enrl_status := '5';    -- 5 for Pell Attendance "Others"
      ELSE
        -- cursor returned 1 row. And attendance_type_code is not null
        l_enrl_status := rec_get_attendance_type_code.base_attendance_type_code;
      END IF;
    END IF;
    CLOSE cur_get_attendance_type_code;
    -- End FA 131

    IF l_enrl_status IS NULL OR
       p_pell_orig_int.enrollment_status_flag <> l_enrl_status
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_ENRL_MISMTCH');
      fnd_message.set_token('SYS_ENRL_CODE', l_enrl_status );
      fnd_message.set_token('ENRL_CODE',p_pell_orig_int.enrollment_status_flag);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      IF l_pell_import_status <> 'E' THEN
        l_pell_import_status := 'W';
      END IF;
    END IF;
    -- End of Validate Enrollment Status


    -- Validate Pell EFC Amount for valid values
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', EFC Amount : ' || p_pell_orig_int.efc_amt;
    END IF;

    IF (p_pell_orig_int.efc_amt < 0) OR
       (p_pell_orig_int.efc_amt > 9999999)
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_EFC_INVALID');
      fnd_message.set_token('EFC',p_pell_orig_int.efc_amt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';
    END IF;


    -- Check Pell Amount with the ISIR Pell Amount
    IF (g_awd_yr_status_cd = 'O') AND
       (lc_isir_details.paid_efc <> p_pell_orig_int.efc_amt)
    THEN

      fnd_message.set_name('IGF','IGF_GR_LI_EFC_MISMTCH');
      fnd_message.set_token('ISIR_EFC',lc_isir_details.paid_efc);
      fnd_message.set_token('EFC',p_pell_orig_int.efc_amt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      IF l_pell_import_status <> 'E' THEN
        l_pell_import_status := 'W';
      END IF;

    END IF;


    -- Validate Low Tution Fee Code
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Low Tution Fee Code : ' || p_pell_orig_int.low_tution_fee_cd;
    END IF;

    IF (p_pell_orig_int.low_tution_fee_cd IS NOT NULL) AND
       (p_pell_orig_int.low_tution_fee_cd NOT IN ('1','2','3','4'))
    THEN
      fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
      fnd_message.set_token('FIELD', 'LOW_TUTION_FEE_CD');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';
    END IF;


    -- Removed the following validation. FA 131.
    -- Validate Scheduled Pell Award for OPEN Award Year and Origination status should be 'Ready' or 'Not Ready'

    -- Validate Pell Award
    IF p_pell_orig_int.pell_award_amt <> lc_awd_details.accepted_amt THEN
      fnd_message.set_name('IGF','IGF_GR_LI_PELL_AWD_INVALID');
      fnd_message.set_token('PELL_LMT', p_pell_orig_int.pell_award_amt);
      fnd_message.set_token('AWD_AMT', lc_awd_details.accepted_amt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';

    END IF;


    -- Validate Payment Method
    --  p_pell_orig_int.payment_method_code NOT IN ('1','2','3','4','5')
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Payment Method : ' || p_pell_orig_int.payment_method_code;
    END IF;

    IF igf_ap_gen.get_aw_lookup_meaning('IGF_GR_PAYMENT_METHOD', p_pell_orig_int.payment_method_code, g_sys_award_year) IS NULL THEN
      fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
      fnd_message.set_token('FIELD', 'PAYMENT_METHOD_CODE');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';
    END IF;


    -- Validate Payment Weeks
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Payment Weeks : ' || p_pell_orig_int.wk_inst_time_calc_pymt_num;
    END IF;

    IF p_pell_orig_int.payment_method_code = '1' AND
       p_pell_orig_int.wk_inst_time_calc_pymt_num IS NOT NULL
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_PMWK_INVALID');
      fnd_message.set_token('PYMT_WKS', p_pell_orig_int.wk_inst_time_calc_pymt_num);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';

    ELSIF p_pell_orig_int.payment_method_code IN ('2','3','4','5') AND
       p_pell_orig_int.wk_inst_time_calc_pymt_num IS NULL
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_PMWK_INVALID_1');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';

    END IF;


    -- Validate Academic Weeks
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Academic Weeks : ' || p_pell_orig_int.wk_int_time_prg_def_yr_num;
    END IF;

    IF ( p_pell_orig_int.payment_method_code = '1' AND
         p_pell_orig_int.wk_int_time_prg_def_yr_num IS NOT NULL
       )
       OR
       (
         p_pell_orig_int.payment_method_code IN ('2','3','4','5') AND
         p_pell_orig_int.wk_int_time_prg_def_yr_num IS NULL
       )
    THEN
      fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
      fnd_message.set_token('FIELD', 'WK_INT_TIME_PRG_DEF_YR_NUM');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';
    END IF;


    -- Validate Academic Calendar
    -- p_pell_orig_int.academic_calendar_cd NOT IN ('1','2','3','4','5','6')
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Academic Calendar : ' || p_pell_orig_int.academic_calendar_cd;
    END IF;

    IF igf_ap_gen.get_aw_lookup_meaning('IGF_GR_ACAD_CAL', p_pell_orig_int.academic_calendar_cd, g_sys_award_year) IS NULL THEN
      fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
      fnd_message.set_token('FIELD', 'ACADEMIC_CALENDAR_CD');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';
    END IF;


    -- Validate Expected Hours
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Expected Hours : ' || p_pell_orig_int.cr_clk_hrs_prds_sch_yr_num;
    END IF;

    IF ( p_pell_orig_int.academic_calendar_cd IN ('1','2','3','4') AND p_pell_orig_int.cr_clk_hrs_prds_sch_yr_num IS NOT NULL ) OR
       ( p_pell_orig_int.academic_calendar_cd IN ('5','6') AND p_pell_orig_int.cr_clk_hrs_prds_sch_yr_num IS NULL )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_EXHR_INVALID');
      fnd_message.set_token('EXP_HRS',p_pell_orig_int.cr_clk_hrs_prds_sch_yr_num);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';
    END IF;


    -- Validate Academic hours
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Academic Hours : ' || p_pell_orig_int.cr_clk_hrs_acad_yr_num;
    END IF;

    IF ( p_pell_orig_int.academic_calendar_cd IN ('1','2','3','4') AND p_pell_orig_int.cr_clk_hrs_acad_yr_num IS NOT NULL )OR
       ( p_pell_orig_int.academic_calendar_cd IN ('5','6') AND p_pell_orig_int.cr_clk_hrs_acad_yr_num IS NULL )
    THEN
      fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
      fnd_message.set_token('FIELD', 'CR_CLK_HRS_ACAD_YR_NUM');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';
    END IF;


    -- Validate Verification Status
    -- ( g_sys_award_year = '0203' AND p_pell_orig_int.verification_status_code NOT IN ('W','V') ) OR
    -- ( g_sys_award_year = '0304' AND p_pell_orig_int.verification_status_code NOT IN ('W','V','S') )
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Verification Status : ' || p_pell_orig_int.verification_status_code;
    END IF;

    IF (p_pell_orig_int.verification_status_code IS NOT NULL) AND
       (igf_ap_gen.get_aw_lookup_meaning('IGF_GR_VER_STAT_CD', p_pell_orig_int.verification_status_code, g_sys_award_year) IS NULL )
    THEN
      fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
      fnd_message.set_token('FIELD', 'VERIFICATION_STATUS_CODE');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';
    END IF;


    -- Validate Incarcerated Code
    -- IF p_pell_orig_int.incrcd_fed_pell_rcp_code NOT IN ('Y','N') THEN
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Incarcerated Code : ' || p_pell_orig_int.incrcd_fed_pell_rcp_code;
    END IF;

    IF (p_pell_orig_int.incrcd_fed_pell_rcp_code IS NOT NULL) AND
       (igf_ap_gen.get_aw_lookup_meaning('IGF_GR_STU_INCARCE_STATUS', p_pell_orig_int.incrcd_fed_pell_rcp_code, g_sys_award_year) IS NULL )
    THEN
      fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
      fnd_message.set_token('FIELD', 'INCRCD_FED_PELL_RCP_CODE');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';
    END IF;


    -- Validate Secondary EFC Code
    -- IF p_pell_orig_int.secondary_efc_code NOT IN ('O','S') THEN
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Secondary EFC Code : ' || p_pell_orig_int.secondary_efc_code;
    END IF;

    IF (p_pell_orig_int.secondary_efc_code IS NOT NULL) AND
       (igf_ap_gen.get_aw_lookup_meaning('IGF_GR_SEC_EFC_CD', p_pell_orig_int.secondary_efc_code, g_sys_award_year) IS NULL )
    THEN
      fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
      fnd_message.set_token('FIELD', 'SECONDARY_EFC_CODE');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_gr_li_import.import_pell_orig.debug', l_debug_str);
      l_debug_str := 'IGFGR10B.pls Procedure import_pell_orig (2) :: ';
    END IF;


    -- Validate Previous Transaction Number
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Previous Transaction Number : ' || p_pell_orig_int.prev_accpt_tran_num_txt;
    END IF;

    IF (p_pell_orig_int.prev_accpt_tran_num_txt IS NOT NULL) AND
       (TO_NUMBER(p_pell_orig_int.prev_accpt_tran_num_txt) < 1 OR  TO_NUMBER(p_pell_orig_int.prev_accpt_tran_num_txt) > 99 )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_PRNT_INVALID_1');
      fnd_message.set_token('PR_TNUM',p_pell_orig_int.prev_accpt_tran_num_txt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';

    ELSIF ( (p_pell_orig_int.orig_status_code IN ('N','R','A','C')) AND
            (p_pell_orig_int.prev_accpt_tran_num_txt IS NOT NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_PRNT_INVALID_2');
      fnd_message.set_token('PR_TNUM',p_pell_orig_int.prev_accpt_tran_num_txt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';

    END IF;


    -- Validate Previous EFC
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Previous EFC : ' || p_pell_orig_int.prev_accpt_efc_amt;
    END IF;

    IF (p_pell_orig_int.prev_accpt_efc_amt < 0) OR
       (p_pell_orig_int.prev_accpt_efc_amt > 9999999)
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_PSEF_INVALID_1');
      fnd_message.set_token('PR_SEC_EFC',p_pell_orig_int.prev_accpt_efc_amt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';

    ELSIF ( (p_pell_orig_int.orig_status_code IN ('N','R','A','C')) AND
            (p_pell_orig_int.prev_accpt_efc_amt IS NOT NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_PSEF_INVALID_2');
      fnd_message.set_token('PR_SEC_EFC',p_pell_orig_int.prev_accpt_efc_amt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';

    END IF;


    -- Validate Previous Secondary EFC
    -- IF p_pell_orig_int.prev_accpt_sec_efc_cd NOT IN ('O','S') THEN
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Previous Secondary EFC : ' || p_pell_orig_int.prev_accpt_sec_efc_cd;
    END IF;

    IF (p_pell_orig_int.prev_accpt_sec_efc_cd IS NOT NULL) AND
       (igf_ap_gen.get_aw_lookup_meaning('IGF_GR_SEC_EFC_CD', p_pell_orig_int.prev_accpt_sec_efc_cd, g_sys_award_year) IS NULL )
    THEN
      fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
      fnd_message.set_token('FIELD', 'PREV_ACCPT_SEC_EFC_CD');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';

    ELSIF ( (p_pell_orig_int.orig_status_code IN ('N','R','A','C')) AND
            (p_pell_orig_int.prev_accpt_sec_efc_cd IS NOT NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_PSEFCD_INVALID_2');
      fnd_message.set_token('PR_SEC_EFC',p_pell_orig_int.prev_accpt_sec_efc_cd);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';

    END IF;


    -- Validate Previous COA
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Previous COA : ' || p_pell_orig_int.prev_accpt_coa_amt;
    END IF;

    IF p_pell_orig_int.prev_accpt_coa_amt < 0 OR p_pell_orig_int.prev_accpt_coa_amt < 9999999 THEN
      fnd_message.set_name('IGF','IGF_GR_LI_PCOA_INVALID_1');
      fnd_message.set_token('PR_COA',p_pell_orig_int.prev_accpt_coa_amt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';

    ELSIF ( (p_pell_orig_int.orig_status_code IN ('N','R','A','C')) AND
            (p_pell_orig_int.prev_accpt_coa_amt IS NOT NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_PCOA_INVALID_2');
      fnd_message.set_token('PR_COA',p_pell_orig_int.prev_accpt_coa_amt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';

    END IF;


    -- Validate Process Date
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Previous Date : ' || p_pell_orig_int.rfms_process_date;
    END IF;

    IF ( (p_pell_orig_int.orig_status_code IN ('A','C','E')) AND
         (p_pell_orig_int.rfms_process_date IS NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_OPRDT_INVALID_1');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';

    ELSIF ( (p_pell_orig_int.orig_status_code IN ('A','C','E')) AND
            (TRUNC(p_pell_orig_int.rfms_process_date) > TRUNC(sysdate)) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_OPRDT_INVALID_2');
      fnd_message.set_token('PROC_DATE',p_pell_orig_int.rfms_process_date);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';

    ELSIF ( (p_pell_orig_int.orig_status_code IN ('N','R')) AND
            (p_pell_orig_int.rfms_process_date IS NOT NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_OPRDT_INVALID_3');
      fnd_message.set_token('PROC_DATE',p_pell_orig_int.rfms_process_date);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';

    END IF;


    -- Validate ED Use Flags
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', ED Use Flags : ' || p_pell_orig_int.orig_ed_use_flags_txt;
    END IF;

    IF ( (p_pell_orig_int.orig_status_code IN ('R','N')) AND
         (p_pell_orig_int.orig_ed_use_flags_txt IS NOT NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_OEDFL_INVALID_2');
      fnd_message.set_token('ED_FLAG',p_pell_orig_int.orig_ed_use_flags_txt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';
    END IF;


    -- Validate Warning Codes
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Warning Codes : ' || p_pell_orig_int.orig_reject_codes_txt;
    END IF;

    IF ( (p_pell_orig_int.orig_status_code IN ('R','N')) AND
         (p_pell_orig_int.orig_reject_codes_txt IS NOT NULL) )
    THEN
      fnd_message.set_name('IGF','IGF_GR_LI_OEDCD_INVALID_2');
      fnd_message.set_token('EDIT_CODE',p_pell_orig_int.orig_reject_codes_txt);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      l_pell_import_status := 'E';
    END IF;


    -- If the validations are passed thru, then created the PELL Batch record and Pell Origination (If error should not import records)
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ' :: After all Validations : Import status :  ' || l_pell_import_status;
    END IF;

    IF l_pell_import_status <> 'E' THEN

      -- Create Pell Batch record (Do not create batch records for ready status and not ready statuses)
      l_rfmb_id := NULL;
      IF ( (p_pell_orig_int.orig_status_code IS NOT NULL) AND
           (p_pell_orig_int.orig_status_code NOT IN ('R','N')) )
      THEN

        IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
          l_debug_str := l_debug_str || ' :: Creating Pell Orig Batch :  ';
        END IF;
        l_rfmb_id := create_pell_orig_batch(p_pell_orig_int);

        IF l_rfmb_id = -1 THEN
          IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
            l_debug_str := l_debug_str || ' : Pell Orig Batch not created';
          END IF;
          l_pell_import_status := 'E';
          ROLLBACK TO SP_PELL;
          RETURN l_pell_import_status;
        END IF;

      END IF;

      IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
        l_debug_str := l_debug_str || ' Pell Orig Batch ID :  '|| l_rfmb_id || ' :: Creating Pell Orig rec :  ';
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_gr_li_import.import_pell_orig.debug', l_debug_str);
        l_debug_str := NULL;
      END IF;

      -- Create Pell Record
      IF NOT create_pell_orig(p_pell_orig_int, lc_isir_details, l_rfmb_id) THEN
        fnd_message.set_name('IGF','IGF_GR_LI_OINSERT_FAIL');
        fnd_message.set_token('ORIG_ID',p_pell_orig_int.origination_id_txt);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_gr_li_import.import_pell_orig.debug', ' : Pell Orig rec not created');
        END IF;
        l_pell_import_status := 'E';
        ROLLBACK TO SP_PELL;
        RETURN l_pell_import_status;
      END IF;

      IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
        l_debug_str := ' :: Creating Pell Disbursements : ';
      END IF;

      l_disb_num_prmpt := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','DISBURSEMENT_NUMBER');
      l_processing     := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PROCESSING');
      l_pell_disb_full_status  := 'I';
      l_pell_disb_indv_status  := 'I';

      -- Validate and Import Pell Disbursement
      FOR lc_pell_disb_int IN c_pell_disb_int(p_pell_orig_int.ci_alternate_code, p_pell_orig_int.person_number, p_pell_orig_int.award_number_txt, p_pell_orig_int.origination_id_txt ) LOOP

        -- Log context information of the Pell Disbursment
        fnd_file.put_line(fnd_file.log, ' ');
        fnd_file.put_line(fnd_file.log, g_disb_pad_str || l_processing ||' '|| l_disb_num_prmpt  ||' : '|| lc_pell_disb_int.disbursement_num);


        -- Import Pell Disbursement
        IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
          l_debug_str := ' Disb num : ' || lc_pell_disb_int.disbursement_num;
        END IF;

        l_pell_disb_indv_status := 'E';
        l_pell_disb_indv_status := import_pell_disb(lc_pell_disb_int, p_pell_orig_int.ope_cd);

        -- Update the full disbursement status
        IF(l_pell_disb_indv_status = 'I' AND (l_pell_disb_full_status NOT IN ('W','E')))THEN
          l_pell_disb_full_status := l_pell_disb_indv_status;

        ELSIF(l_pell_disb_indv_status = 'W' AND l_pell_disb_full_status <> 'E')THEN
          l_pell_disb_full_status := l_pell_disb_indv_status;

        ELSIF(l_pell_disb_indv_status = 'E')THEN
          l_pell_disb_full_status := l_pell_disb_indv_status;

          -- Log an error message that Pell Import is unsuccessful
          fnd_message.set_name('IGF','IGF_GR_LI_DINSERT_FAIL');
          fnd_message.set_token('ORIG_ID',lc_pell_disb_int.origination_id_txt);
          fnd_message.set_token('DISB_NUM',lc_pell_disb_int.disbursement_num);
          fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
        END IF;

        IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
          l_debug_str := l_debug_str || ', Disb Status : ' || l_pell_disb_indv_status;
          l_debug_str := l_debug_str || ', l_pell_disb_full_status : '|| l_pell_disb_full_status ||', l_pell_disb_indv_status : '|| l_pell_disb_indv_status;
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_gr_li_import.import_pell_orig.debug', l_debug_str);
          l_debug_str := NULL;
        END IF;

      END LOOP; -- End of creation of Disbursments


      -- Update the Pell status based on the disb full status
      IF(l_pell_disb_full_status = 'I' AND (l_pell_import_status NOT IN ('W','E')))THEN
        l_pell_import_status := l_pell_disb_full_status;
      ELSIF(l_pell_disb_full_status = 'W' AND l_pell_import_status <> 'E')THEN
        l_pell_import_status := l_pell_disb_full_status;
      ELSIF(l_pell_disb_full_status = 'E')THEN
        l_pell_import_status := l_pell_disb_full_status;
      END IF;


      -- If imported with errors then rollback to the Pell and return with the status 'E'
      IF l_pell_import_status = 'E' THEN

        ROLLBACK TO SP_PELL;
        IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_gr_li_import.import_pell_orig.debug', l_debug_str || ' End of Pell Orig Import, return status : '|| l_pell_import_status);
          l_debug_str := NULL;
        END IF;

        RETURN l_pell_import_status;

      END IF;


      --  Import the remaining disbursements only if Pell Disb imported successfully from Int table
      IF l_pell_import_status <> 'E' THEN

        -- Create the remaining disbursements which are present in the Awd Disb table and not present in the Pell Disb table
        IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_gr_li_import.import_pell_orig.debug','Processing Remaining disb present in the Production Awd Disb : ');
        END IF;

        ln_rem_disb_cnt := 0;
        FOR lc_get_remain_disb IN c_get_remain_disb(g_award_id) LOOP

          BEGIN

            IF ln_rem_disb_cnt = 0 THEN
              -- Log a message for processing remaining disbursements.
              fnd_message.set_name('IGF','IGF_GR_LI_REMG_DISB');
              fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
            END IF;
            ln_rem_disb_cnt := ln_rem_disb_cnt + 1;


            -- Print the log information
            fnd_file.put_line(fnd_file.log, ' ');
            fnd_file.put_line(fnd_file.log, g_disb_pad_str || l_processing ||' '|| l_disb_num_prmpt  ||' : '|| lc_get_remain_disb.disb_num);

            IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN

              l_debug_str := l_debug_str || ' Remaining Disb Num : '|| lc_get_remain_disb.disb_num;
            END IF;

            -- Set the dibursement Sign Flag based on the Disb Accepted amount
            IF lc_get_remain_disb.disb_accepted_amt >= 0 THEN
              l_db_cr_flag := 'P';
            ELSE
              l_db_cr_flag := 'N';
            END IF;


            -- Create Pell Origination Record in the production table
            l_row_id := NULL;
            l_rfmd_id := NULL;
            igf_gr_rfms_disb_pkg.insert_row(
                                            x_mode                       => 'R',
                                            x_rowid                      => l_row_id,
                                            x_rfmd_id                    => l_rfmd_id,
                                            x_origination_id             => p_pell_orig_int.origination_id_txt,
                                            x_disb_ref_num               => lc_get_remain_disb.disb_num,
                                            x_disb_dt                    => lc_get_remain_disb.disb_date,
                                            x_disb_amt                   => lc_get_remain_disb.disb_accepted_amt,
                                            x_db_cr_flag                 => l_db_cr_flag,
                                            x_disb_ack_act_status        => 'R',
                                            x_disb_status_dt             => TRUNC(SYSDATE),
                                            x_accpt_disb_dt              => NULL,
                                            x_disb_accpt_amt             => NULL,
                                            x_accpt_db_cr_flag           => NULL,
                                            x_disb_ytd_amt               => NULL,
                                            x_pymt_prd_start_dt          => NULL,
                                            x_accpt_pymt_prd_start_dt    => NULL,
                                            x_edit_code                  => NULL,
                                            x_rfmb_id                    => NULL,
                                            x_ed_use_flags               => NULL
                                           );
          IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
            l_debug_str := l_debug_str || ', Created Disb successful rfmd_id: '|| l_rfmd_id;
          END IF;

          EXCEPTION
            WHEN OTHERS THEN
              fnd_message.set_name('IGF','IGF_GR_LI_REM_DINS_FAIL');
              fnd_message.set_token('ORIG_ID',p_pell_orig_int.origination_id_txt);
              fnd_message.set_token('DISB_NUM',lc_get_remain_disb.disb_num);
              fnd_file.put_line(fnd_file.log, g_disb_pad_str || fnd_message.get);
          END;

        IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_gr_li_import.import_pell_orig.debug', l_debug_str);
          l_debug_str := NULL;
        END IF;

        END LOOP;  -- End of remaining disbs

      END IF; -- End of remaining disb

    END IF; -- End of Error status <> 'E' to Import Pell Disb

    -- Return to the main routine
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_gr_li_import.import_pell_orig.debug', l_debug_str || ' End of Pell Orig Import, return status : '|| l_pell_import_status);
      l_debug_str := NULL;
    END IF;

    RETURN l_pell_import_status;

  EXCEPTION

    WHEN OTHERS THEN
      IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_gr_li_import.import_pell_orig.exception', l_debug_str || SQLERRM );
      END IF;
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_GR_LI_IMPORT.IMPORT_PELL_ORIG');
      igs_ge_msg_stack.add;

  END import_pell_orig;

  FUNCTION chk_atd_rep( p_atd_entity_id_txt VARCHAR2, p_rep_entity_id_txt VARCHAR2)
  RETURN BOOLEAN
  IS
      /*
      ||  Created By : pssahni
      ||  Created On : 29-Oct-2004
      ||  Purpose : To validate the combination of attending and reporting pell ids
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
      */

    CURSOR c_chk_atd_rep_comb (p_atd_entity_id_txt VARCHAR2, p_rep_entity_id_txt VARCHAR2)
    IS
      SELECT atd.atd_entity_id_txt, rep.rep_entity_id_txt
        FROM igf_gr_report_pell rep, igf_gr_attend_pell atd
       WHERE rep.rcampus_id = atd.rcampus_id
         AND atd.atd_entity_id_txt = p_atd_entity_id_txt
         AND rep.rep_entity_id_txt = p_rep_entity_id_txt;

    chk_atd_rep_comb_rec   c_chk_atd_rep_comb%ROWTYPE;


    l_office_cd       igs_or_org_alt_ids.org_alternate_id_type%TYPE;
    l_ret_status      VARCHAR2(1);
    l_msg_data        VARCHAR2(30);
    BEGIN
        IF (p_atd_entity_id_txt IS NULL)OR (p_rep_entity_id_txt IS NULL) THEN
            -- If anyone is null then raise error
            fnd_message.set_name('IGF','IGF_SL_ATD_REP_PELL_NOT_CORR');
            fnd_file.put_line(fnd_file.log, fnd_message.get);
            RETURN FALSE;
        ELSE
          -- Check if their combination is valid

            OPEN c_chk_atd_rep_comb (p_atd_entity_id_txt, p_rep_entity_id_txt );
            FETCH c_chk_atd_rep_comb INTO chk_atd_rep_comb_rec;

            IF c_chk_atd_rep_comb%NOTFOUND THEN
                fnd_message.set_name('IGF','IGF_SL_ATD_REP_PELL_NOT_CORR');
                fnd_file.put_line(fnd_file.log, fnd_message.get);
                RETURN FALSE;
            END IF;

            CLOSE c_chk_atd_rep_comb;

        END IF;
    g_atd_entity_id_txt := p_atd_entity_id_txt;
    RETURN TRUE;

    END chk_atd_rep;


  PROCEDURE main(
                 errbuf          OUT NOCOPY VARCHAR2,
                 retcode         OUT NOCOPY NUMBER,
                 p_award_year    IN         VARCHAR2,
                 p_batch_num     IN         NUMBER,
                 p_delete_flag   IN         VARCHAR2
            ) AS
    /*
    ||  Created By : brajendr
    ||  Created On : 18-Jun-2003
    ||  Purpose : Main process imports the Pell data from the Legacy Pell interface table
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
	|| tsailaja	  13/Jan/2006       Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
    || bvisvana   07-July-2005      Bug # 4008991 - IGF_GR_BATCH_DOES_NOT_EXIST replaced by IGF_SL_GR_BATCH_DOES_NO_EXIST
    ||  (reverse chronological order - newest change first)
    */

    -- Cursor to fetch alternate code for the given Cal Type and Sequence Number
    CURSOR c_get_alternate_code(
                                cp_cal_type   igs_ca_inst_all.cal_type%TYPE,
                                cp_seq_number igs_ca_inst_all.sequence_number%TYPE
                               ) IS
    SELECT ca.alternate_code
      FROM igs_ca_inst_all ca
     WHERE ca.cal_type = cp_cal_type
       AND ca.sequence_number = cp_seq_number;

    lc_get_alternate_code  c_get_alternate_code%ROWTYPE;

    -- cursor to verify if the cal_type and seq_number are present in the system award year
    CURSOR c_sys_awd_yr_dtls(
                             cp_ci_cal_type         igs_ca_inst.cal_type%TYPE,
                             cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE
                            ) IS
    SELECT bam.alternate_code, bam.award_year_status_code, bam.sys_award_year
      FROM igf_ap_batch_aw_map_v bam
     WHERE bam.ci_cal_type = cp_ci_cal_type
       AND bam.ci_sequence_number = cp_ci_sequence_number;

    lc_sys_awd_yr_dtls    c_sys_awd_yr_dtls%ROWTYPE;

    -- Get the details of
    CURSOR c_check_setups(
                          cp_ci_cal_type         igs_ca_inst.cal_type%TYPE,
                          cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE
                         ) IS
      SELECT 'x'
        FROM DUAL
       WHERE EXISTS(
                SELECT 'x'
                  FROM igf_gr_reg_amts reg, igf_ap_batch_aw_map_all batch
                 WHERE batch.ci_cal_type = cp_ci_cal_type
                   AND batch.ci_sequence_number = cp_ci_sequence_number
                   AND batch.sys_award_year = reg.sys_awd_yr
                   )
         AND EXISTS(
                SELECT 'X'
                  FROM igf_gr_alt_amts alt, igf_ap_batch_aw_map_all batch
                 WHERE batch.ci_cal_type = cp_ci_cal_type
                   AND batch.ci_sequence_number = cp_ci_sequence_number
                   AND alt.sys_awd_yr = batch.sys_award_year
                   )
         AND EXISTS(
                SELECT 'X'
                  FROM igf_gr_tuition_fee_codes tfee, igf_ap_batch_aw_map_all batch
                 WHERE batch.ci_cal_type = cp_ci_cal_type
                   AND batch.ci_sequence_number = cp_ci_sequence_number
                   AND batch.sys_award_year = tfee.sys_awd_yr
                   )
         AND EXISTS(
                SELECT 'X'
                  FROM igf_ap_attend_map_all atm
                 WHERE atm.cal_type IS NOT NULL
                   AND atm.sequence_number IS NOT NULL
                   AND atm.cal_type = cp_ci_cal_type
                   AND atm.sequence_number = cp_ci_sequence_number);

    lc_pell_orig_int      c_pell_orig_int%ROWTYPE;
    lc_pell_disb_int      c_pell_disb_int%ROWTYPE;
    l_prev_person_number  hz_parties.party_number%TYPE;
    l_processing          igf_lookups_view.meaning%TYPE;
    l_person_number       igf_lookups_view.meaning%TYPE;
    l_award_number        igf_lookups_view.meaning%TYPE;
    l_debug_str           fnd_log_messages.message_text%TYPE := 'IGFGR10B.pls Procedure main :: ';
    l_pell_import_status  VARCHAR2(1);
    l_chk_batch           VARCHAR2(1);
    l_chk_setups          VARCHAR2(1);
    l_chk_profile         VARCHAR2(1);
    l_delete_status       VARCHAR2(1);
    l_fabase_ret_status   VARCHAR2(1);
    SKIP_RECORD           EXCEPTION;




BEGIN
	igf_aw_gen.set_org_id(NULL);
    -- Initialize the global variables
    g_cal_type    := TRIM(SUBSTR(p_award_year,1,10));
    g_seq_number  := TO_NUMBER(SUBSTR(p_award_year,11));
    g_delete_flag := p_delete_flag;
    errbuf        := NULL;
    retcode       := 0;

    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Cal Type : ' || g_cal_type;
      l_debug_str := l_debug_str || ', Sequence Num : ' || g_seq_number;

      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_gr_li_import.main.debug', ' ---- Request ID : '||fnd_global.conc_request_id
                     ||' Conc Prgm Id : '||fnd_global.conc_program_id
                     ||' Pgm appl Id : '||fnd_global.prog_appl_id
                     ||' ----');
    END IF;

    OPEN c_get_alternate_code(g_cal_type,g_seq_number);
    FETCH c_get_alternate_code INTO lc_get_alternate_code;
    CLOSE c_get_alternate_code;

    -- Log the input paramters.
    log_parameters( lc_get_alternate_code.alternate_code, p_batch_num, p_delete_flag );


    -- Verify whether the school is configured for US School and uses Financial Aid.
    -- If not participating then log an error message
    l_chk_profile := igf_ap_gen.check_profile();
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Checking Profile value : ' || l_chk_profile;
    END IF;

    IF NVL(l_chk_profile, 'N') <> 'Y' THEN
      fnd_message.set_name('IGF','IGF_AP_LGCY_PROC_NOT_RUN');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      RETURN;
    END IF;

    -- Validate the Batch Details
    l_chk_batch := 'Y';
    l_chk_batch := igf_ap_gen.check_batch(p_batch_num, 'GRANTS');
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Checking Batch : ' || l_chk_batch;
    END IF;

    IF l_chk_batch = 'N' THEN
      fnd_message.set_name('IGF','IGF_SL_GR_BATCH_DOES_NO_EXIST');
      fnd_message.set_token('BATCH_ID',p_batch_num);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      RETURN;
    END IF;

    -- Get the alternate code for the calendar details
    OPEN  c_sys_awd_yr_dtls(g_cal_type, g_seq_number);
    FETCH c_sys_awd_yr_dtls INTO lc_sys_awd_yr_dtls;
    IF c_sys_awd_yr_dtls%NOTFOUND THEN
      CLOSE c_sys_awd_yr_dtls;
      FND_MESSAGE.SET_NAME('IGF','IGF_AP_AWD_YR_NOT_FOUND');
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      retcode := 2;
      RETURN;
    END IF;
    CLOSE c_sys_awd_yr_dtls;

    -- Validate Alternate code
    -- Check whether the import is for OPEN or Legacy Details award year or not.
    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Validating Alternate Code Awd Yr Cd : ' || lc_sys_awd_yr_dtls.award_year_status_code;
      l_debug_str := l_debug_str || ', Sys Awd Yr : ' || lc_sys_awd_yr_dtls.sys_award_year;
    END IF;

    IF lc_sys_awd_yr_dtls.award_year_status_code IS NULL OR lc_sys_awd_yr_dtls.award_year_status_code NOT IN ('O','LD') THEN
      fnd_message.set_name('IGF','IGF_AP_LG_INVALID_STAT');
      fnd_message.set_token('AWARD_STATUS',igf_ap_gen.get_aw_lookup_meaning('IGF_AWARD_YEAR_STATUS', lc_sys_awd_yr_dtls.award_year_status_code, lc_sys_awd_yr_dtls.sys_award_year));
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      RETURN;
    END IF;

    -- Set the System Award Year and Award Year status code
    g_sys_award_year   := lc_sys_awd_yr_dtls.sys_award_year;
    g_awd_yr_status_cd := lc_sys_awd_yr_dtls.award_year_status_code;

    fnd_file.put_line(fnd_file.log,RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','AWARD_YR_STATUS'),40)|| ' : '|| igf_ap_gen.get_aw_lookup_meaning('IGF_AWARD_YEAR_STATUS',g_awd_yr_status_cd, g_sys_award_year));
    fnd_file.put_line(fnd_file.log,RPAD('-',55,'-'));


    -- Check whether all the setups are valid for the context award year in the system.
    OPEN c_check_setups(g_cal_type, g_seq_number);
    FETCH c_check_setups INTO l_chk_setups;
    CLOSE c_check_setups;

    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Validating Other Pell Setups : ' || l_chk_setups;
    END IF;

    IF NVL(l_chk_setups, 'N') <> 'x' THEN
      fnd_message.set_name('IGF','IGF_GR_LI_AWD_YR_INVALID_4');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
      l_debug_str := l_debug_str || ', Starting Pell Origination import : ';
    END IF;


    -- If it is COD-XML award year then take awards with status Ready to Send only
    IF igf_sl_dl_validation.check_full_participant (g_cal_type, g_seq_number,'PELL') THEN
      -- open the cursor with origination status code as "R" meaning "Ready to Send".
      OPEN c_pell_orig_int(p_batch_num, lc_sys_awd_yr_dtls.alternate_code,'R');
    ELSE
      -- open the cursor with origination status code as NULL so that it picks all records.
      OPEN c_pell_orig_int(p_batch_num, lc_sys_awd_yr_dtls.alternate_code,NULL);
    END IF;

     -- Loop each record in the Pell Interface table
    FETCH c_pell_orig_int INTO lc_pell_orig_int;

    -- If Pell records are not present in the interface table for the given batch number and award year
    -- log an error message and exit process
    IF c_pell_orig_int%NOTFOUND THEN
      CLOSE c_pell_orig_int;

      IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
        l_debug_str := l_debug_str || ', Pell int records not found :: ';
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_gr_li_import.main.debug', l_debug_str);
        l_debug_str := NULL;
      END IF;
      fnd_message.set_name('IGF','IGF_GR_LI_NO_RECORDS');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      RETURN;

    ELSE

      -- Cache the temporary variables
      IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
        l_debug_str := l_debug_str || ', Pell int records are present :: ';
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_gr_li_import.main.debug', l_debug_str);
        l_debug_str := NULL;
      END IF;

      l_processing     := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PROCESSING');
      l_person_number  := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PERSON_NUMBER');
      l_award_number   := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','AWARD_NUMBER');
      l_prev_person_number := NULL;

      -- Process all Interface Pell Origination records.
      LOOP

        -- Loop is necessary to transfer the control from middle of the loop to next record
        BEGIN

          SAVEPOINT SP_MAIN_PELL;

          fnd_file.put_line(fnd_file.log, ' ');
          fnd_file.put_line(fnd_file.log, ' ');
          g_tot_rec_processed := g_tot_rec_processed + 1;
          IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
            l_debug_str := ' Processing Record : ' || g_tot_rec_processed ||', Person Number : ' || lc_pell_orig_int.person_number;
          END IF;

          -- Check attending and reporting entity IDs in case of COD-XML processing
          -- Attending campus code should be NULL
          IF igf_sl_dl_validation.check_full_participant (g_cal_type, g_seq_number,'PELL') THEN

             IF (NOT chk_atd_rep(lc_pell_orig_int.atd_entity_id_txt, lc_pell_orig_int.rep_entity_id_txt)) THEN
                -- Skip Record
               fnd_message.set_name('IGF','IGF_AW_LI_SKIPPING_AWD');
               fnd_file.put_line(fnd_file.log, fnd_message.get);
               g_tot_rec_imp_error := g_tot_rec_imp_error + 1;
               RAISE SKIP_RECORD;
             END IF;
             IF lc_pell_orig_int.attending_campus_cd IS NOT NULL THEN
               fnd_message.set_name('IGF','IGF_GR_FULL_NO_ATD_PELL_ID');
               fnd_message.set_name('IGF','IGF_AW_LI_SKIPPING_AWD');
               fnd_file.put_line(fnd_file.log, fnd_message.get);
               fnd_file.put_line(fnd_file.log, fnd_message.get);
               g_tot_rec_imp_error := g_tot_rec_imp_error + 1;
               RAISE SKIP_RECORD;
             END IF;

          END IF;

          -- Perform Person existance and Base Record existance in the system
          -- Do not perform the checks for the same person once again
          IF lc_pell_orig_int.person_number <> l_prev_person_number OR l_prev_person_number IS NULL THEN

            l_prev_person_number := lc_pell_orig_int.person_number;

            -- Log context Information in the log file
            fnd_file.put_line(fnd_file.log,RPAD('-',50,'-'));
            fnd_file.put_line(fnd_file.log, RPAD(l_processing ||' '|| l_person_number, 30) ||' : '|| lc_pell_orig_int.person_number);
            fnd_file.put_line(fnd_file.log,RPAD('-',50,'-'));
            fnd_file.put_line(fnd_file.log, RPAD(l_processing ||' '|| l_award_number, 30)  ||' : '|| lc_pell_orig_int.award_number_txt);

            -- Validate Person Number
            g_person_id := NULL;
            g_base_id   := NULL;
            IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
              l_debug_str := l_debug_str || ', Checking Person Existance ';
            END IF;

            igf_ap_gen.check_person(
                                    lc_pell_orig_int.person_number,
                                    g_cal_type,
                                    g_seq_number,
                                    g_person_id,
                                    g_base_id
                                   );
            IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
              l_debug_str := l_debug_str || ', Person ID : ' || g_person_id;
              l_debug_str := l_debug_str || ', Base ID : ' || g_base_id;
            END IF;

            -- If person does not exits, log a message and exit the loop
            IF g_person_id IS NULL AND g_base_id IS NULL THEN
              fnd_message.set_name('IGF','IGF_AW_LI_PERSON_NOT_FND');
              fnd_file.put_line(fnd_file.log,fnd_message.get);
              l_prev_person_number := NULL;

              fnd_message.set_name('IGF','IGF_AW_LI_SKIPPING_AWD');
              fnd_file.put_line(fnd_file.log, fnd_message.get);
              g_tot_rec_imp_error := g_tot_rec_imp_error + 1;

              UPDATE igf_aw_li_pell_ints
                 SET import_status_type     = 'E',
                     last_updated_by        = fnd_global.user_id,
                     last_update_date       = SYSDATE,
                     last_update_login      = fnd_global.login_id,
                     request_id             = fnd_global.conc_request_id,
                     program_id             = fnd_global.conc_program_id,
                     program_application_id = fnd_global.prog_appl_id,
                     program_update_date    = SYSDATE
               WHERE batch_num = lc_pell_orig_int.batch_num
                 AND ci_alternate_code = lc_pell_orig_int.ci_alternate_code
                 AND person_number = lc_pell_orig_int.person_number
                 AND award_number_txt = lc_pell_orig_int.award_number_txt
                 AND origination_id_txt = lc_pell_orig_int.origination_id_txt;

              RAISE SKIP_RECORD;


            -- If FA Base record does not exits then log a message and exit the loop
            ELSIF g_base_id IS NULL THEN

              fnd_message.set_name('IGF','IGF_AP_FABASE_NOT_FOUND');
              fnd_file.put_line(fnd_file.log,fnd_message.get);
              l_prev_person_number := NULL;

              fnd_message.set_name('IGF','IGF_AW_LI_SKIPPING_AWD');
              fnd_file.put_line(fnd_file.log, fnd_message.get);
              g_tot_rec_imp_error := g_tot_rec_imp_error + 1;

              UPDATE igf_aw_li_pell_ints
                 SET import_status_type     = 'E',
                     last_updated_by        = fnd_global.user_id,
                     last_update_date       = SYSDATE,
                     last_update_login      = fnd_global.login_id,
                     request_id             = fnd_global.conc_request_id,
                     program_id             = fnd_global.conc_program_id,
                     program_application_id = fnd_global.prog_appl_id,
                     program_update_date    = SYSDATE
               WHERE batch_num = lc_pell_orig_int.batch_num
                 AND ci_alternate_code = lc_pell_orig_int.ci_alternate_code
                 AND person_number = lc_pell_orig_int.person_number
                 AND award_number_txt = lc_pell_orig_int.award_number_txt
                 AND origination_id_txt = lc_pell_orig_int.origination_id_txt;

              RAISE SKIP_RECORD;
            END IF;

          ELSE
            fnd_file.put_line(fnd_file.log, RPAD(l_processing ||' '|| l_award_number, 30)  ||' : '|| lc_pell_orig_int.award_number_txt);

          END IF;


          -- If the Pell record is being imported in Update mode, then delete the existing PELL record then import interface record
          IF lc_pell_orig_int.import_record_type = 'U' THEN
            l_delete_status := 'E';
            l_delete_status := delete_existing_pell_rec(
                                                        lc_pell_orig_int.origination_id_txt,
                                                        g_cal_type,
                                                        g_seq_number
                                                       );

            -- IF legacy Pell records are not found OR Errors in Pell records deletion, log an error message and rollback to prev. save point
            IF l_delete_status = 'E' THEN
              ROLLBACK TO SP_MAIN_PELL;
              fnd_message.set_name('IGF','IGF_GR_LI_UPDATE_FAIL');
              fnd_file.put_line(fnd_file.log, fnd_message.get);

              UPDATE igf_aw_li_pell_ints
                 SET import_status_type     = 'E',
                     last_updated_by        = fnd_global.user_id,
                     last_update_date       = SYSDATE,
                     last_update_login      = fnd_global.login_id,
                     request_id             = fnd_global.conc_request_id,
                     program_id             = fnd_global.conc_program_id,
                     program_application_id = fnd_global.prog_appl_id,
                     program_update_date    = SYSDATE
               WHERE batch_num = lc_pell_orig_int.batch_num
                 AND ci_alternate_code = lc_pell_orig_int.ci_alternate_code
                 AND person_number = lc_pell_orig_int.person_number
                 AND award_number_txt = lc_pell_orig_int.award_number_txt
                 AND origination_id_txt = lc_pell_orig_int.origination_id_txt;

              COMMIT;

              fnd_message.set_name('IGF','IGF_AW_LI_SKIPPING_AWD');
              fnd_file.put_line(fnd_file.log, fnd_message.get);
              g_tot_rec_imp_error := g_tot_rec_imp_error + 1;
              RAISE SKIP_RECORD;
            END IF;

          -- If NULL or in Insert mode, do the import
          ELSIF NVL(lc_pell_orig_int.import_record_type,'I') = 'I' THEN
            NULL;
          -- for all other values error out
          ELSE

            ROLLBACK TO SP_MAIN_PELL;
            fnd_message.set_name('IGF','IGF_AW_LI_INVLD_IMP_REC_TY');
            fnd_file.put_line(fnd_file.log, fnd_message.get);

            fnd_message.set_name('IGF','IGF_AW_LI_SKIPPING_AWD');
            fnd_file.put_line(fnd_file.log, fnd_message.get);
            g_tot_rec_imp_error := g_tot_rec_imp_error + 1;

            UPDATE igf_aw_li_pell_ints
               SET import_status_type     = 'E',
                   last_updated_by        = fnd_global.user_id,
                   last_update_date       = SYSDATE,
                   last_update_login      = fnd_global.login_id,
                   request_id             = fnd_global.conc_request_id,
                   program_id             = fnd_global.conc_program_id,
                   program_application_id = fnd_global.prog_appl_id,
                   program_update_date    = SYSDATE
             WHERE batch_num = lc_pell_orig_int.batch_num
               AND ci_alternate_code = lc_pell_orig_int.ci_alternate_code
               AND person_number = lc_pell_orig_int.person_number
               AND award_number_txt = lc_pell_orig_int.award_number_txt
               AND origination_id_txt = lc_pell_orig_int.origination_id_txt;

            RAISE SKIP_RECORD;
          END IF;


          -- Update Pell amounts at the FA Base rec level
          IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
            l_debug_str := l_debug_str || ' :: Updating FA Base Record ';
          END IF;

          l_fabase_ret_status := NULL;
          l_fabase_ret_status := update_fa_base_data( g_base_id, lc_pell_orig_int.pell_coa_amt, lc_pell_orig_int.pell_alt_exp_amt);
          IF l_fabase_ret_status = 'E' THEN
            fnd_message.set_name('IGF','IGF_GR_LI_FAIL_UPD_COA');
            fnd_message.set_token('PELL_COA',lc_pell_orig_int.pell_coa_amt);
            fnd_message.set_token('PELL_ALT_EXP',lc_pell_orig_int.pell_alt_exp_amt);
            fnd_file.put_line(fnd_file.log, fnd_message.get);

            IF l_pell_import_status <> 'E' THEN
              l_pell_import_status := 'W';
            END IF;
          END IF;

          -- Import Pell Origination Record
          IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
            l_debug_str := l_debug_str || ' : Import Pell Origination : ';
          END IF;

          l_pell_import_status := NULL;
          l_pell_import_status := import_pell_orig(lc_pell_orig_int);

          -- Update the records imported count
          IF l_pell_import_status = 'I' THEN
            fnd_message.set_name('IGF','IGF_GR_LI_IMP_SUCCES');
            fnd_message.set_token('ORIG_ID',lc_pell_orig_int.origination_id_txt);
            fnd_file.put_line(fnd_file.log, fnd_message.get);
            g_tot_rec_imp_successful := g_tot_rec_imp_successful + 1;

            -- Commit the transaction after successful import of Pell record.
            COMMIT;

          ELSIF l_pell_import_status = 'E' THEN
            fnd_message.set_name('IGF','IGF_AW_LI_SKIPPING_AWD');
            fnd_file.put_line(fnd_file.log, fnd_message.get);
            g_tot_rec_imp_error := g_tot_rec_imp_error + 1;

            -- Rollback the intermediate transactions
            ROLLBACK TO SP_MAIN_PELL;

          ELSE
            g_tot_rec_imp_warning := g_tot_rec_imp_warning + 1;

          END IF;

          -- Update the return status of the record.
          -- Delete the interface recrodss if the falg is set. (Do not delete int records if imported with warnings)
          IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
            l_debug_str := l_debug_str || ' : Import status : ' || l_pell_import_status;
          END IF;

          IF l_pell_import_status = 'I' AND g_delete_flag = 'Y' THEN

            IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
              l_debug_str := l_debug_str || ' : Deleting Pell Int rec : ';
            END IF;

            DELETE igf_aw_li_pell_ints
             WHERE batch_num = lc_pell_orig_int.batch_num
               AND ci_alternate_code  = lc_pell_orig_int.ci_alternate_code
               AND person_number      = lc_pell_orig_int.person_number
               AND award_number_txt   = lc_pell_orig_int.award_number_txt
               AND origination_id_txt = lc_pell_orig_int.origination_id_txt;

            IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
              l_debug_str := l_debug_str || ', Deleting Interface Pell Disb recs';
            END IF;

            DELETE igf_aw_li_pdb_ints
             WHERE ci_alternate_code  = lc_pell_orig_int.ci_alternate_code
               AND person_number      = lc_pell_orig_int.person_number
               AND award_number_txt   = lc_pell_orig_int.award_number_txt
               AND origination_id_txt = lc_pell_orig_int.origination_id_txt;

          ELSE
            -- Update the interface table as 'I' if imported successfully
            -- Update the interface table as 'W' if imported with warnings
            -- Update the interface table as 'E' if not imported and errors are present
            IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
              l_debug_str := l_debug_str || ' : Updating Pell Int rec : ';
            END IF;

            UPDATE igf_aw_li_pell_ints
               SET import_status_type     = l_pell_import_status,
                   last_updated_by        = fnd_global.user_id,
                   last_update_date       = SYSDATE,
                   last_update_login      = fnd_global.login_id,
                   request_id             = fnd_global.conc_request_id,
                   program_id             = fnd_global.conc_program_id,
                   program_application_id = fnd_global.prog_appl_id,
                   program_update_date    = SYSDATE
             WHERE batch_num = lc_pell_orig_int.batch_num
               AND ci_alternate_code = lc_pell_orig_int.ci_alternate_code
               AND person_number = lc_pell_orig_int.person_number
               AND award_number_txt = lc_pell_orig_int.award_number_txt
               AND origination_id_txt = lc_pell_orig_int.origination_id_txt;

          END IF;

          -- This comment is necessary to commit the import_status_type of the corresponding record
          COMMIT;

        EXCEPTION
          WHEN SKIP_RECORD THEN
            NULL;

          WHEN OTHERS THEN
            IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_gr_li_import.main.internal Begin', l_debug_str || SQLERRM );
            END IF;
            fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
            fnd_message.set_token('NAME','IGF_GR_LI_IMPORT.MAIN_SUB_BEGIN');
            igs_ge_msg_stack.add;
            app_exception.raise_exception;
        END; -- End of local begin


        -- Fetch the next record, if no more records then exit the code
        IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
          l_debug_str := l_debug_str || ' : Fetch next record : ';
          l_debug_str := l_debug_str || ' : Fetch next record : ';
        END IF;

        lc_pell_orig_int := NULL;
        FETCH c_pell_orig_int INTO lc_pell_orig_int;
        EXIT WHEN c_pell_orig_int%NOTFOUND;

        IF (FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_gr_li_import.main.debug', l_debug_str);
          l_debug_str := NULL;
        END IF;
        l_debug_str := NULL;

      END LOOP; -- End of all Pell Interface records

    END IF; -- End of Pell Cursor

    -- If cursor is still open then close it
    IF c_pell_orig_int%ISOPEN THEN
      CLOSE c_pell_orig_int;
    END IF;

    fnd_file.put_line(fnd_file.log, ' ');

    -- Print the statistics in the OUT file
    fnd_file.put_line(fnd_file.output,' ' );
    fnd_file.put_line(fnd_file.output, RPAD('-',50,'-'));
    fnd_file.put_line(fnd_file.output,' ' );
    fnd_file.put_line(fnd_file.output, RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_PROCESSED'), 40)  || ' : ' || g_tot_rec_processed);
    fnd_file.put_line(fnd_file.output, RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_SUCCESSFUL'), 40) || ' : ' || g_tot_rec_imp_successful);
    fnd_file.put_line(fnd_file.output, RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_WARN'), 40)       || ' : ' || g_tot_rec_imp_warning);
    fnd_file.put_line(fnd_file.output, RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_REJECTED'), 40)   || ' : ' || g_tot_rec_imp_error);
    fnd_file.put_line(fnd_file.output,' ' );
    fnd_file.put_line(fnd_file.output, RPAD('-',50,'-'));
    fnd_file.put_line(fnd_file.output,' ' );

    fnd_file.put_line(fnd_file.log,' ' );
    fnd_file.put_line(fnd_file.log, RPAD('-',50,'-'));
    fnd_file.put_line(fnd_file.log,' ' );
    fnd_file.put_line(fnd_file.log, RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_PROCESSED'), 40)  || ' : ' || g_tot_rec_processed);
    fnd_file.put_line(fnd_file.log, RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_SUCCESSFUL'), 40) || ' : ' || g_tot_rec_imp_successful);
    fnd_file.put_line(fnd_file.log, RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_WARN'), 40)       || ' : ' || g_tot_rec_imp_warning);
    fnd_file.put_line(fnd_file.log, RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_REJECTED'), 40)   || ' : ' || g_tot_rec_imp_error);
    fnd_file.put_line(fnd_file.log,' ' );
    fnd_file.put_line(fnd_file.log, RPAD('-',50,'-'));
    fnd_file.put_line(fnd_file.log,' ' );


  EXCEPTION
    WHEN others THEN
      IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_gr_li_import.main.exception', l_debug_str || SQLERRM );
      END IF;
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_GR_LI_IMPORT.MAIN');
      errbuf  := fnd_message.get;
      igs_ge_msg_stack.conc_exception_hndl;

  END main;



END igf_gr_li_import;

/
