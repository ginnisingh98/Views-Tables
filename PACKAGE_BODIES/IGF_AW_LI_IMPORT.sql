--------------------------------------------------------
--  DDL for Package Body IGF_AW_LI_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_LI_IMPORT" AS
/* $Header: IGFAW15B.pls 120.14 2006/09/08 13:55:06 akomurav ship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: IGF_AW_LI_IMPORT                        |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 |The Legacy - Award and Disbursement Data Import Process imports data   |
 |from the Legacy Award Data Interface Table, Legacy Disbursement Data   |
 |Interface Table, and Legacy Disbursement Activity Data Interface Table |
 |into appropriate OSS Financial Aid tables.                             |
 |This concurrent process performs specified business rules and          |
 |validations before data can be imported into the OSS Financial Aid     |
 |tables.  Users will be notified  via the concurrent request's log file |
 |if the process has encountered errors.                                 |
 |                                                                       |
 | HISTORY                                                               |
 | Who       When         What                                           |
 |                                                                       |
 | azmohamm  03-AUG-2006  FA 163, Added GPLUSFL fund code                |
 |
 | ridas     29-Jul-2005  Bug #3536039.                                  |
 |                        Exception igf_se_gen_001.IGFSEGEN001 added in  |
 |                        procedure CREATE_AWARD_RECORD                  |
 |                                                                       |
 | ridas     22-Jul-2005  Bug #4093072. If FEDERAL_FUND_CODE equal to    |
 |                        'ALT'/'FLS'/'FLP'/'FLU', then call the function|
 |                        igf_sl_award.get_cl_hold_rel_ind() which will  |
 |                        return the hold_release_indicator value.       |
 |                        If not assign FALSE as default value           |
 |                                                                       |
 | ridas     10-Jan-2005  Bug #3701698 if the Award Status='CANCELLED',  |
 |                        Accected amount should be zero.                |
 |                                                                       |
 | brajendr  04-Jan-2004  Bug 3701698 Loading Legacy awds with CANCEL st |
 |                        Added the validations for validating the       |
 |                        -- Total offered/accepted amounts in disb      |
 |                        -- added check for disb_accepted_amt in dacts  |
 |                                                                       |
 | cdcruz    02-Dec-2004  Bug 3701698 Customer requirement was to be able|
 |                        to upload Cancelled Awards via Legacy Import   |
 |                                                                       |
 | ridas     08-Nov-2004  Bug 3021287 If the profile_value = 'AWARDED'   |
 |                        then updating COA at the student level         |
 |                                                                       |
 | brajendr  12-Oct-2004  Bug 3732665 ISIR Enhacements                   |
 |                        modified the payment isir reference            |
 |                                                                       |
 | veramach  July 2004    FA 151 HR Integration (bug# 3709292)           |
 |                        Moved validations at the disbursement level    |
 |                        for FWS awards to award level.                 |
 |                        also,creation of authorization is made at the  |
 |                        award level rather than at each disbursement   |
 |                        level                                          |
 | veramach  26-Feb-2004  bug 3466726 - Changed cursor c_get_att_type to |
 |                        use lookup_code rather than description for    |
 |                        validating base_attendance_type_code           |
 |                        If this validation fails, message              |
 |                        IGF_AP_INV_FLD_VAL is displayed rather than    |
 |                        IGF_AW_LI_INVALID_ATT_TYPE                     |
 | veramach  08-Dec-2003  FA 131 Build - made li_awd_rec parameter of    |
 |                        validate_awdyear_int_rec to IN OUT NOCOPY      |
 | sjadhav   4-Dec-2003   Limit logic for term comparision to Sponsor    |
 |                        Funds                                          |
 | veramach  04-Dec-2003  FA 131 COD Updates                             |
 |                        Changed column names in legacy award/          |
 |                        disbursement table to be in sync with the  CS  |
 | nsidana   11/27/2003  FA131 COD updated for 2004-2005 build.          |
 |                       New cols added to legacy award and legacy award |
 |                       disbursements table. Impact done here.          |
 | sjadhav   19-Nov-2003  Bug 3160568 FA 125 Build. Added run  routine   |
 |                        Added validations for EXT Award Import         |
 |                        Added validations for attendance_type_code     |
 | veramach  1-NOV-2003   FA 125 Multiple Distr Methods                  |
 |                        Changed calll to igf_aw_awd_disb_pkg.update_row|
 |                        to reflect the addition of attendance_type_code|
 | brajendr  08-Oct-2003  Bug # 3116511 - Update the Auth Date           |
 |                                                                       |
 | sjalasut  June 16,2003 Created as Part of Fa118.2 Legacy Import Build |
 | sjalasut  August 4, 2003 Import Sponsorships and Federal Work Study   |
 |                          funds for FACR117, part of sep 03 patch      |
 | sjalasut  Aug 12, 2003  Bug 3093913. Changed the message for validatio|
 |                         n on transaction type.                        |
 *=======================================================================*/

/***************************************************************
   Created By   : nsidana
   Date Created By  : 11/28/2003
   Purpose    :  Legacy Awards Import package body.
   Known Limitations,Enhancements or Remarks
   Change History :
   Who      When          What
   nsidana 11/28/2003  FA131 COD updates build. Added validations on two new feilds
                                      added to the legacy awards table and 1 feild in the legacy award
                                      disbursements table.
 ***************************************************************/


  -- cursor to fetch records from the award legacy interface tables

  CURSOR cur_legacy_award_int(p_alternate_code igs_ca_inst.alternate_code%TYPE,
                              p_batch_num igf_aw_li_awd_ints.batch_num%TYPE) IS
  SELECT
    awdint.batch_num,
    trim(awdint.ci_alternate_code) ci_alternate_code,
    trim(awdint.fund_code) fund_code,
    trim(awdint.person_number) person_number,
    trim(awdint.award_number_txt) award_number_txt,
    awdint.import_status_type,
    awdint.offered_amt,
    awdint.accepted_amt,
    trim(awdint.award_status_code) award_status_code,
    awdint.award_date,
    awdint.alt_pell_schedule_type,
    awdint.import_record_type,
    awdint.created_by,
    awdint.creation_date,
    awdint.last_updated_by,
    awdint.last_update_date,
    awdint.last_update_login,
    awdint.request_id,
    awdint.program_application_id,
    awdint.program_id,
    awdint.program_update_date,
    awdint.lock_award_flag,                     --new col for FA131 COD updates build
    awdint.app_trans_num_txt,                   --new col for FA131 COD updates build
    awdint.authorization_date,
    awdint.publish_in_ss_flag
  FROM igf_aw_li_awd_ints awdint
  WHERE awdint.batch_num = p_batch_num
    AND awdint.ci_alternate_code = p_alternate_code
    AND awdint.import_status_type IN ('U','R')
  ORDER BY awdint.person_number, awdint.fund_code, awdint.award_number_txt;
  l_out_person_id hz_parties.party_id%TYPE;
  l_out_base_id igf_ap_fa_base_rec_all.base_id%TYPE;

  g_ci_cal_type igf_ap_batch_aw_map.ci_cal_type%TYPE;
  g_ci_sequence_number igf_ap_batch_aw_map_all.ci_sequence_number%TYPE;

  g_award_year_status_code igf_ap_batch_aw_map_all.award_year_status_code%TYPE;
  g_sys_award_year igf_ap_batch_aw_map_all.sys_award_year%TYPE;
  g_fund_code igf_aw_fund_mast_all.fund_code%TYPE;
  g_fed_fund_code igf_aw_fund_cat_all.fed_fund_code%TYPE;
  g_fund_id igf_aw_fund_mast_all.fund_id%TYPE;
  g_base_id igf_ap_fa_base_rec_all.base_id%TYPE;
  g_award_id igf_aw_award_all.award_id%TYPE;
  g_disb_net_amount igf_aw_li_dact_ints.disb_net_amt%TYPE;
  g_person_id hz_parties.party_id%TYPE;
  g_processing_string VARCHAR2(1000);
  g_debug_string fnd_log_messages.message_text%TYPE;
  g_debug_runtime_level NUMBER;
  g_entry_point     VARCHAR2(30);

  g_print_msg       VARCHAR2(200);
  -- bvisvana - Bug # 4635941 - Global variables
  CURSOR c_get_awd_details(cp_award_id igf_aw_award_all.award_id%TYPE) IS
    SELECT * FROM igf_aw_award_all
      WHERE award_id = cp_award_id;

  g_old_award_rec   c_get_awd_details%ROWTYPE; -- Collects information of the old award (that is getting deleted)
  g_new_award_rec   c_get_awd_details%ROWTYPE; -- Collects information of the new award (that is getting created)
  g_hist_cnt        NUMBER;
  g_update_mode     BOOLEAN   := FALSE;         -- To Track whether running in update mode or not
  TYPE g_old_award_hist_tab_type IS TABLE OF igf_aw_award_level_hist%ROWTYPE INDEX BY BINARY_INTEGER;
  g_old_award_hist_col g_old_award_hist_tab_type; -- Holds the history of the award that is getting deleted when running in update_mode


PROCEDURE lock_std_coa (p_base_id         igf_ap_fa_base_rec_all.base_id%TYPE
                       )
IS
-----------------------------------------------------------------------------
--  Created By : ridas
--  Created On : 05-Nov-2004
--  Purpose : to lock COA at the student level
--  Known limitations, enhancements or remarks :
--  Change History :
--  Who             When            What
--
-----------------------------------------------------------------------------

    --Cursor to fetch person details
    CURSOR c_get_fab (p_base_id         igf_ap_fa_base_rec_all.base_id%TYPE
                       )
          IS
      SELECT fab.rowid row_id,
             fab.*
        FROM igf_ap_fa_base_rec_all   fab
       WHERE fab.base_id  = p_base_id
         AND NVL(fab.lock_coa_flag,'N') <> 'Y';

    l_get_fab    c_get_fab%ROWTYPE;


    --Cursor to fetch item details
    CURSOR c_items(
                   cp_base_id   igf_ap_fa_base_rec_all.base_id%TYPE
                  ) IS
      SELECT items.rowid  row_id,
             items.*
        FROM igf_aw_coa_items items
       WHERE base_id = cp_base_id
         AND NVL(lock_flag,'N') <> 'Y';


    --Cursor to fetch term details
    CURSOR c_terms(
                   cp_base_id   igf_ap_fa_base_rec_all.base_id%TYPE,
                   cp_item_code igf_aw_item.item_code%TYPE
                  ) IS
      SELECT terms.rowid  row_id,
             terms.*
        FROM igf_aw_coa_itm_terms terms
       WHERE base_id   = cp_base_id
         AND item_code = cp_item_code
         AND NVL(lock_flag,'N') <> 'Y';


BEGIN

    OPEN  c_get_fab(p_base_id);
    FETCH c_get_fab INTO l_get_fab;
    CLOSE c_get_fab;

    IF l_get_fab.base_id IS NOT NULL THEN

        FOR l_items IN c_items(l_get_fab.base_id)
        LOOP
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_li_import.lock_std_coa.debug','locking at the item level');
            END IF;

            igf_aw_coa_items_pkg.update_row(
                                            x_rowid              => l_items.row_id,
                                            x_base_id            => l_items.base_id,
                                            x_item_code          => l_items.item_code,
                                            x_amount             => l_items.amount,
                                            x_pell_coa_amount    => l_items.pell_coa_amount,
                                            x_alt_pell_amount    => l_items.alt_pell_amount,
                                            x_fixed_cost         => l_items.fixed_cost,
                                            x_legacy_record_flag => l_items.legacy_record_flag,
                                            x_mode               => 'R',
                                            x_lock_flag          => 'Y'
                                           );


            FOR l_terms IN c_terms(l_get_fab.base_id,l_items.item_code)
            LOOP
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_li_import.lock_std_coa.debug','locking at the term level');
                END IF;

                igf_aw_coa_itm_terms_pkg.update_row(
                                                    x_rowid              => l_terms.row_id,
                                                    x_base_id            => l_terms.base_id,
                                                    x_item_code          => l_terms.item_code,
                                                    x_amount             => l_terms.amount,
                                                    x_ld_cal_type        => l_terms.ld_cal_type,
                                                    x_ld_sequence_number => l_terms.ld_sequence_number,
                                                    x_mode               => 'R',
                                                    x_lock_flag          => 'Y'
                                                   );

            END LOOP;
        END LOOP;


        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_li_import.lock_std_coa.debug','l_get_fab.base_id IS NOT NULL');
        END IF;

        igf_ap_fa_base_rec_pkg.update_row
                                        (x_Mode                              => 'R',
                                         x_rowid                             => l_get_fab.row_id,
                                         x_base_id                           => l_get_fab.base_id,
                                         x_ci_cal_type                       => l_get_fab.ci_cal_type,
                                         x_person_id                         => l_get_fab.person_id,
                                         x_ci_sequence_number                => l_get_fab.ci_sequence_number,
                                         x_org_id                            => l_get_fab.org_id,
                                         x_coa_pending                       => l_get_fab.coa_pending,
                                         x_verification_process_run          => l_get_fab.verification_process_run,
                                         x_inst_verif_status_date            => l_get_fab.inst_verif_status_date,
                                         x_manual_verif_flag                 => l_get_fab.manual_verif_flag,
                                         x_fed_verif_status                  => l_get_fab.fed_verif_status,
                                         x_fed_verif_status_date             => l_get_fab.fed_verif_status_date,
                                         x_inst_verif_status                 => l_get_fab.inst_verif_status,
                                         x_nslds_eligible                    => l_get_fab.nslds_eligible,
                                         x_ede_correction_batch_id           => l_get_fab.ede_correction_batch_id,
                                         x_fa_process_status_date            => l_get_fab.fa_process_status_date,
                                         x_ISIR_corr_status                  => l_get_fab.ISIR_corr_status,
                                         x_ISIR_corr_status_date             => l_get_fab.ISIR_corr_status_date,
                                         x_ISIR_status                       => l_get_fab.ISIR_status,
                                         x_ISIR_status_date                  => l_get_fab.ISIR_status_date,
                                         x_coa_code_f                        => l_get_fab.coa_code_f,
                                         x_coa_code_i                        => l_get_fab.coa_code_i,
                                         x_coa_f                             => l_get_fab.coa_f,
                                         x_coa_i                             => l_get_fab.coa_i,
                                         x_disbursement_hold                 => l_get_fab.disbursement_hold,
                                         x_fa_process_status                 => l_get_fab.fa_process_status,
                                         x_notification_status               => l_get_fab.notification_status,
                                         x_notification_status_date          => l_get_fab.notification_status_date,
                                         x_packaging_status                  => l_get_fab.packaging_status,
                                         x_packaging_status_date             => l_get_fab.packaging_status_date,
                                         x_total_package_accepted            => l_get_fab.total_package_accepted,
                                         x_total_package_offered             => l_get_fab.total_package_offered,
                                         x_admstruct_id                      => l_get_fab.admstruct_id,
                                         x_admsegment_1                      => l_get_fab.admsegment_1,
                                         x_admsegment_2                      => l_get_fab.admsegment_2,
                                         x_admsegment_3                      => l_get_fab.admsegment_3,
                                         x_admsegment_4                      => l_get_fab.admsegment_4,
                                         x_admsegment_5                      => l_get_fab.admsegment_5,
                                         x_admsegment_6                      => l_get_fab.admsegment_6,
                                         x_admsegment_7                      => l_get_fab.admsegment_7,
                                         x_admsegment_8                      => l_get_fab.admsegment_8,
                                         x_admsegment_9                      => l_get_fab.admsegment_9,
                                         x_admsegment_10                     => l_get_fab.admsegment_10,
                                         x_admsegment_11                     => l_get_fab.admsegment_11,
                                         x_admsegment_12                     => l_get_fab.admsegment_12,
                                         x_admsegment_13                     => l_get_fab.admsegment_13,
                                         x_admsegment_14                     => l_get_fab.admsegment_14,
                                         x_admsegment_15                     => l_get_fab.admsegment_15,
                                         x_admsegment_16                     => l_get_fab.admsegment_16,
                                         x_admsegment_17                     => l_get_fab.admsegment_17,
                                         x_admsegment_18                     => l_get_fab.admsegment_18,
                                         x_admsegment_19                     => l_get_fab.admsegment_19,
                                         x_admsegment_20                     => l_get_fab.admsegment_20,
                                         x_packstruct_id                     => l_get_fab.packstruct_id,
                                         x_packsegment_1                     => l_get_fab.packsegment_1,
                                         x_packsegment_2                     => l_get_fab.packsegment_2,
                                         x_packsegment_3                     => l_get_fab.packsegment_3,
                                         x_packsegment_4                     => l_get_fab.packsegment_4,
                                         x_packsegment_5                     => l_get_fab.packsegment_5,
                                         x_packsegment_6                     => l_get_fab.packsegment_6,
                                         x_packsegment_7                     => l_get_fab.packsegment_7,
                                         x_packsegment_8                     => l_get_fab.packsegment_8,
                                         x_packsegment_9                     => l_get_fab.packsegment_9,
                                         x_packsegment_10                    => l_get_fab.packsegment_10,
                                         x_packsegment_11                    => l_get_fab.packsegment_11,
                                         x_packsegment_12                    => l_get_fab.packsegment_12,
                                         x_packsegment_13                    => l_get_fab.packsegment_13,
                                         x_packsegment_14                    => l_get_fab.packsegment_14,
                                         x_packsegment_15                    => l_get_fab.packsegment_15,
                                         x_packsegment_16                    => l_get_fab.packsegment_16,
                                         x_packsegment_17                    => l_get_fab.packsegment_17,
                                         x_packsegment_18                    => l_get_fab.packsegment_18,
                                         x_packsegment_19                    => l_get_fab.packsegment_19,
                                         x_packsegment_20                    => l_get_fab.packsegment_20,
                                         x_miscstruct_id                     => l_get_fab.miscstruct_id,
                                         x_miscsegment_1                     => l_get_fab.miscsegment_1,
                                         x_miscsegment_2                     => l_get_fab.miscsegment_2,
                                         x_miscsegment_3                     => l_get_fab.miscsegment_3,
                                         x_miscsegment_4                     => l_get_fab.miscsegment_4,
                                         x_miscsegment_5                     => l_get_fab.miscsegment_5,
                                         x_miscsegment_6                     => l_get_fab.miscsegment_6,
                                         x_miscsegment_7                     => l_get_fab.miscsegment_7,
                                         x_miscsegment_8                     => l_get_fab.miscsegment_8,
                                         x_miscsegment_9                     => l_get_fab.miscsegment_9,
                                         x_miscsegment_10                    => l_get_fab.miscsegment_10,
                                         x_miscsegment_11                    => l_get_fab.miscsegment_11,
                                         x_miscsegment_12                    => l_get_fab.miscsegment_12,
                                         x_miscsegment_13                    => l_get_fab.miscsegment_13,
                                         x_miscsegment_14                    => l_get_fab.miscsegment_14,
                                         x_miscsegment_15                    => l_get_fab.miscsegment_15,
                                         x_miscsegment_16                    => l_get_fab.miscsegment_16,
                                         x_miscsegment_17                    => l_get_fab.miscsegment_17,
                                         x_miscsegment_18                    => l_get_fab.miscsegment_18,
                                         x_miscsegment_19                    => l_get_fab.miscsegment_19,
                                         x_miscsegment_20                    => l_get_fab.miscsegment_20,
                                         x_prof_judgement_flg                => l_get_fab.prof_judgement_flg,
                                         x_nslds_data_override_flg           => l_get_fab.nslds_data_override_flg,
                                         x_target_group                      => l_get_fab.target_group,
                                         x_coa_fixed                         => l_get_fab.coa_fixed,
                                         x_profile_status                    => l_get_fab.profile_status,
                                         x_profile_status_date               => l_get_fab.profile_status_date,
                                         x_profile_fc                        => l_get_fab.profile_fc,
                                         x_coa_pell                          => l_get_fab.coa_pell,
                                         x_manual_disb_hold                  => l_get_fab.manual_disb_hold,
                                         x_pell_alt_expense                  => l_get_fab.pell_alt_expense,
                                         x_assoc_org_num                     => l_get_fab.assoc_org_num,
                                         x_award_fmly_contribution_type      => l_get_fab.award_fmly_contribution_type,
                                         x_packaging_hold                    => l_get_fab.packaging_hold,
                                         x_isir_locked_by                    => l_get_fab.isir_locked_by ,
                                         x_adnl_unsub_loan_elig_flag         => l_get_fab.adnl_unsub_loan_elig_flag,
                                         x_lock_awd_flag                     => l_get_fab.lock_awd_flag,
                                         x_lock_coa_flag                     => 'Y'
                                         );
        fnd_message.set_name('IGF','IGF_AW_STUD_COA_LOCK');
        fnd_message.set_token('PERSON_NUM',igf_gr_gen.get_per_num (p_base_id));
        g_print_msg := fnd_message.get;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_aw_li_import.lock_std_coa :' || SQLERRM);
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_li_import.lock_std_coa.exception','sql error:'||SQLERRM);
      END IF;
      igs_ge_msg_stack.conc_exception_hndl;
      app_exception.raise_exception;


END lock_std_coa;



  PROCEDURE validate_awdyear_int_rec(li_awd_rec IN OUT NOCOPY igf_aw_li_awd_ints%ROWTYPE, l_return_value OUT NOCOPY VARCHAR2) IS

  /***************************************************************
   Created By   : nsidana
   Date Created By  : 11/28/2003
   Purpose    :  Validates the interface record.
   Known Limitations,Enhancements or Remarks
   Change History :
   Who      When          What
   veramach  08-Dec-2003  FA 131 Build - made li_awd_rec parameter of
                          validate_awdyear_int_rec to IN OUT NOCOPY
   nsidana 11/28/2003  FA131 COD updates build. Added validations on two new feilds
                                      added to the legacy awards table.
 ***************************************************************/

    -- validates the award year interface record
    CURSOR cur_check_sys_awd (p_base_id igf_ap_fa_base_rec_all.base_id%TYPE) IS
    SELECT award_id, legacy_record_flag
    FROM igf_aw_award_all
    WHERE base_id = p_base_id
      AND award_number_txt = li_awd_rec.award_number_txt;
    l_award_id igf_aw_award_all.award_id%TYPE;
    l_legacy_record_flag igf_aw_award_all.legacy_record_flag%TYPE;

    CURSOR cur_get_fund_code(p_fund_code igf_aw_li_awd_ints.fund_code%TYPE) IS
    SELECT fmast.fund_code, fcat.fed_fund_code, fmast.fund_id
    FROM igf_aw_fund_mast_all fmast,
         igf_aw_fund_cat fcat
    WHERE fmast.fund_code = fcat.fund_code
      AND fmast.fund_code = p_fund_code
      AND fmast.ci_cal_type = g_ci_cal_type
      AND fmast.ci_sequence_number = g_ci_sequence_number
      AND discontinue_fund = 'N';

    CURSOR c_1_more_pell_fws IS
    SELECT 'X' present_in_award
    FROM igf_aw_award_all
    WHERE base_id = g_base_id
    AND fund_id = g_fund_id;
    c_1_more_pell_fws_rec c_1_more_pell_fws%ROWTYPE;

    CURSOR c_get_fa_hold_spnsr IS
    SELECT 'X' exist_hold
    FROM igf_aw_li_hold_ints
    WHERE person_number = li_awd_rec.person_number
      AND award_number_txt = li_awd_rec.award_number_txt
      AND ci_alternate_code = li_awd_rec.ci_alternate_code;
    c_get_fa_hold_spnsr_rec c_get_fa_hold_spnsr%ROWTYPE;

    CURSOR c_get_spnsr_amt IS
    SELECT fmast.max_yearly_amt
      FROM igf_aw_fund_mast_all fmast, igf_aw_fund_cat_all fcat
     WHERE fmast.fund_id = g_fund_id
       AND fcat.fed_fund_code = g_fed_fund_code
       AND fmast.ci_cal_type = g_ci_cal_type
       AND fmast.ci_sequence_number = g_ci_sequence_number
       AND fmast.fund_code = fcat.fund_code
       AND fmast.discontinue_fund = 'N';
    c_get_spnsr_amt_rec c_get_spnsr_amt%ROWTYPE;

    l_return_status_awd VARCHAR2(1);
    l_status_open_awd_yr VARCHAR2(1);
    l_return_status_db VARCHAR2(1);

   CURSOR c_get_person_ssn IS
   SELECT api.api_person_id, api.person_id_type, api.start_dt, api.end_dt
     FROM igs_pe_alt_pers_id api,
          igf_ap_fa_base_rec_all fabase,
          igs_pe_person_id_typ pid
    WHERE fabase.person_id = api.pe_person_id
      AND fabase.base_id = g_base_id
      AND api.person_id_Type = pid.person_id_type
      AND pid.s_person_id_type = 'SSN'
      AND SYSDATE BETWEEN api.start_Dt AND NVL(api.end_dt,SYSDATE);
    c_get_person_ssn_rec c_get_person_ssn%ROWTYPE;

    PROCEDURE validate_open_award_year (li_awd_rec IN igf_aw_li_awd_ints%ROWTYPE,
                                        l_status_open_awd_yr OUT NOCOPY VARCHAR2) IS
  /***************************************************************
   Created By   : nsidana
   Date Created By  : 11/28/2003
   Purpose    :  Validates the open award year.
   Known Limitations,Enhancements or Remarks
   Change History :
   Who      When          What
   nsidana 11/28/2003  FA131 COD updates build. Added validations on two new feilds
                                      added to the legacy awards table.
 ***************************************************************/
      CURSOR c_get_pay_isir IS
      SELECT isir_id payment_isir_id
        FROM igf_ap_isir_matched_all
       WHERE base_id = g_base_id
         AND system_record_type = 'ORIGINAL'
         AND payment_isir = 'Y';

      l_payment_isir_id igf_ap_isir_matched_all.isir_id%TYPE;

      CURSOR c_get_fund_source IS
      SELECT fund_source FROM igf_aw_fund_cat_all WHERE fund_code = li_awd_rec.fund_code;
      l_fund_source igf_aw_fund_cat_all.fund_source%TYPE;

      CURSOR c_get_fund_amt IS
      SELECT NVL(remaining_amt,0) remaining_amt, NVL(max_award_amt,0) max_award_amt,
             max_yearly_amt, max_life_amt
      FROM igf_aw_fund_mast_all
      WHERE fund_id = g_fund_id;
      c_get_fund_amt_rec c_get_fund_amt%ROWTYPE;

      CURSOR c_std_max_yr_amt IS
      SELECT NVL(SUM(NVL(awd.accepted_amt,awd.offered_amt)), 0) yr_total
      FROM igf_aw_award_all awd
      WHERE awd.fund_id = g_fund_id
       AND awd.base_id = g_base_id;
      c_std_max_yr_amt_rec c_std_max_yr_amt%ROWTYPE;

      CURSOR c_std_max_lf_count IS
      SELECT NVL(SUM( NVL(awd.accepted_amt,awd.offered_amt)), 0) lf_total
      FROM igf_aw_award_all awd, igf_aw_fund_mast_all fund, igf_ap_fa_base_rec_all fabase
      WHERE fund.fund_code  = g_fund_code
       AND fabase.person_id  = g_person_id
       AND awd.base_id = fabase.base_id
       AND awd.fund_id = fund.fund_id;
      c_std_max_lf_count_rec c_std_max_lf_count%ROWTYPE;

      CURSOR c_get_todo_items IS
      SELECT MST.item_code, mst.todo_number
      FROM igf_ap_td_item_mst mst, igf_aw_fund_td_map fund
      WHERE fund.fund_id = g_fund_id
        AND mst.todo_number = fund.item_sequence_number
        AND fund.item_sequence_number NOT IN (SELECT item_sequence_number
                                              FROM IGF_AP_TD_ITEM_INST
                                              WHERE base_id = g_base_id);

    -- nsidana 11/27/2003 FA131 COD updates build.
    -- Get the details of transaction number for the base ID and the APP_TRANS_ID present in the interface table.
    CURSOR   c_get_trans_num(cp_base_id   igf_ap_fa_base_rec_all.base_id%TYPE,cp_app_trans_num_txt VARCHAR2) IS
      SELECT   transaction_num
        FROM
                        igf_ap_isir_matched
       WHERE
                        BASE_ID=cp_base_id AND
                        transaction_num=cp_app_trans_num_txt;
    l_trans_num NUMBER;

    BEGIN -- begin of validate_open_award_year

      l_status_open_awd_yr :='S';
      l_payment_isir_id := NULL; l_fund_source := NULL; c_get_fund_amt_rec := NULL;

      OPEN c_get_pay_isir; FETCH c_get_pay_isir INTO l_payment_isir_id; CLOSE c_get_pay_isir;
      OPEN c_get_fund_source; FETCH c_get_fund_source INTO l_fund_source; CLOSE c_get_fund_source;
      OPEN c_get_fund_amt; FETCH c_get_fund_amt INTO c_get_fund_amt_rec; CLOSE c_get_fund_amt;

      IF(FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level)THEN
         g_debug_string := 'Fund ID'||g_fund_id||', Payment Isir'||l_payment_isir_id||',Fund Source'||l_fund_source||
                        ',Remaining Amt'||c_get_fund_amt_rec.remaining_amt||',Max Award Amount'||
       c_get_fund_amt_rec.max_Award_amt||',Max Yearly Amt'||c_get_fund_amt_rec.max_yearly_amt||
       ',Max Life Amount'||c_get_fund_amt_rec.max_life_amt;
      END IF;

      -- check if the student is having a valid isir when the context fund is FEDERAL fund. student should have
      -- valid active isir and payment isir
      IF(l_payment_isir_id IS NULL AND l_fund_source IS NOT NULL AND l_fund_source = 'FEDERAL') THEN
        l_status_open_awd_yr :='E';
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_ISIR_NOT_PRESENT');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      END IF;

      --<nsidana 11/27/2003 FA131 COD updates>
            IF ((l_fund_source = 'FEDERAL') and (upper(li_awd_rec.fund_code)='PELL') AND (li_awd_rec.app_trans_num_txt IS NOT NULL))
            THEN
                      OPEN c_get_trans_num(g_base_id,li_awd_rec.app_trans_num_txt);
                      FETCH c_get_trans_num INTO l_trans_num;
                      CLOSE c_get_trans_num;
                      IF (l_trans_num IS NULL)
                      THEN
                               l_return_value :='E';
                               FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_NO_ISIR_TRANS');  -- New message to be entered.
                               FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
                      END IF;
            END IF;
       --</nsidana 11/27/2003 FA131 COD>

      -- if the award amount > fund remaining amount
      IF(li_awd_rec.offered_amt > c_get_fund_amt_rec.remaining_amt)THEN
        l_status_open_awd_yr :='E';
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_AMT_GT_REM_AMT');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      END IF;

      -- award amount greater than the fund max amount
      --akomurav 5478287
      --if the max_award_amt is null do not do this validation

      IF(c_get_fund_amt_rec.max_award_amt <> 0 AND li_awd_rec.offered_amt > c_get_fund_amt_rec.max_award_amt) THEN
        l_status_open_awd_yr :='E';
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_AMT_GT_MAX_AMT');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      END IF;

      -- sum of total year award amount and legacy award amount greater than the maximum year amount
      -- defined at the fund
      c_std_max_yr_amt_rec := NULL;
      OPEN c_std_max_yr_amt; FETCH c_std_max_yr_amt INTO c_std_max_yr_amt_rec; CLOSE c_std_max_yr_amt;
      IF(FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level)THEN
        g_debug_string := g_debug_string ||'Year Total'||c_std_max_yr_amt_rec.yr_total;
      END IF;
      IF((c_get_fund_amt_rec.max_yearly_amt IS NOT NULL) AND
         ((c_std_max_yr_amt_rec.yr_total + li_awd_rec.offered_amt) > c_get_fund_amt_rec.max_yearly_amt))THEN
        l_status_open_awd_yr :='E';
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_AMT_GT_YR_AMT');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      END IF;

      -- sum of total life award amount and legacy award amount greater than the maximum life amount defined
      -- at the fund
      c_std_max_lf_count_rec := NULL;
      OPEN c_std_max_lf_count; FETCH c_std_max_lf_count INTO c_std_max_lf_count_rec; CLOSE c_std_max_lf_count;
      IF(FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level)THEN
        g_debug_string := g_debug_string ||'Life Total'||c_std_max_lf_count_rec.lf_total;
      END IF;
      IF((c_get_fund_amt_rec.max_life_amt IS NOT NULL) AND
         ((c_std_max_lf_count_rec.lf_total + li_awd_rec.offered_amt) > c_get_fund_amt_rec.max_life_amt))THEN
        l_status_open_awd_yr :='E';
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_AMT_GT_LIFE_AMT');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      END IF;
      -- disbursement validation is present at the disbursement level. 'coz the disb intf record is not
      -- yet processed

      -- Check To Do's are present at the Fund level and the same To Do's are not assigned to FA Base
      FOR c_get_todo_items_rec IN c_get_todo_items LOOP
        IF(l_status_open_awd_yr <> 'E')THEN
          l_status_open_awd_yr := 'W';
        END IF;
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_TODO_NT_FND');
        FND_MESSAGE.SET_TOKEN('TODO',c_get_todo_items_rec.item_code);
        FND_MESSAGE.SET_TOKEN('FUND',g_fund_code);
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      END LOOP;

      IF(FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level)THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_aw_li_import.validate_open_award_year.debug',g_debug_string);
         g_debug_string := NULL;
      END IF;
    EXCEPTION WHEN OTHERS THEN
      l_status_open_awd_yr :='E';
      IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                 'igf.plsql.igf_aw_li_import.validate_open_award_year.exception',
           SQLERRM );
      END IF;
      FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','VALIDATE_OPEN_AWARD_YEAR : '||SQLERRM);
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    END validate_open_award_year;

  /*
  Created By : bvisvana
  Created On : 24-May-2005
  Purpose : Identifies whether the award attribute is changed or not.
  Known limitations, enhancements or remarks :
  Change History :
  Who             When            What
  -------------------------------------
   -------------------------------------
  (reverse chronological order - newest change first)
  */

   FUNCTION isChangeIn_AwardAttribute(p_award_atrr_code IN igf_aw_award_level_hist.award_attrib_code%TYPE)
   RETURN BOOLEAN
   AS
   l_changed BOOLEAN := FALSE;
   BEGIN
      -- For offered amount change
      IF (p_award_atrr_code = 'IGF_AW_AMOUNT_OFFERED') THEN
        IF(NVL(g_old_award_rec.OFFERED_AMT,0) <> NVL(g_new_award_rec.OFFERED_AMT,0)) THEN
          l_changed := TRUE;
        END IF;
      END IF;
      -- For Accepted amount change
      IF (p_award_atrr_code = 'IGF_AW_AMOUNT_ACCEPTED') THEN
        IF (NVL(g_old_award_rec.ACCEPTED_AMT,0) <> NVL(g_new_award_rec.ACCEPTED_AMT,0)) THEN
          l_changed := TRUE;
        END IF;
      END IF;
      -- For Paid amount change
      IF (p_award_atrr_code = 'IGF_AW_AMOUNT_PAID') THEN
        IF (NVL(g_old_award_rec.PAID_AMT ,0) <> NVL(g_new_award_rec.PAID_AMT ,0)) THEN
          l_changed := TRUE;
        END IF;
      END IF;
      -- For Award Status change
      IF (p_award_atrr_code = 'IGF_AW_AWARD_STATUS') THEN
        IF (NVL(g_old_award_rec.AWARD_STATUS ,'*') <> NVL(g_new_award_rec.AWARD_STATUS,'*')) THEN
          l_changed := TRUE;
        END IF;
      END IF;
      -- For Award Distribution plan change
      IF (p_award_atrr_code = 'IGF_AW_DIST_PLAN') THEN
        IF (NVL(g_old_award_rec.ADPLANS_ID ,-1) <> NVL(g_new_award_rec.ADPLANS_ID,-1)) THEN
          l_changed := TRUE;
        END IF;
      END IF;
      -- For lock award change
      IF (p_award_atrr_code = 'IGF_AW_LOCK_STATUS') THEN
        IF (NVL(g_old_award_rec.LOCK_AWARD_FLAG ,'*') <> NVL(g_new_award_rec.LOCK_AWARD_FLAG,'*')) THEN
          l_changed := TRUE;
        END IF;
      END IF;

      RETURN l_changed;
    END isChangeIn_AwardAttribute;

     PROCEDURE create_new_award_hist_rec IS
    /***************************************************************
      Created By   : bvisvana
      Date Created By  : 17-Oct-2005
      Purpose      : Bug # 4635941 - Since new award is created when runnig in update mode, there wud be some difference in
                     award attributes.This function will identify the differences in the old award (deleted) and new award (created).
                     For the difference in award attributes, it inserts a history record
      Known Limitations,Enhancements or Remarks
      Change History :
      Who      When          What
     ***************************************************************/
     CURSOR c_lookup_attribute IS
      SELECT lookup_code FROM igf_lookups_view
      WHERE lookup_type = 'IGF_AW_AWARD_ATTRIBUTES';

     l_award_hist_tran_id igf_aw_award_level_hist.award_hist_tran_id%TYPE;

     l_award_atrr_code igf_aw_award_level_hist.award_attrib_code%TYPE;
     l_awd_attr_changed	BOOLEAN := FALSE;
     l_row_id VARCHAR2(30) ;

     BEGIN
      -- Get the details of the newly created award
      OPEN  c_get_awd_details(cp_award_id => g_award_id);
      FETCH c_get_awd_details INTO g_new_award_rec;
      CLOSE c_get_awd_details;

      IF g_old_award_rec.award_id IS NOT NULL AND g_new_award_rec.award_id IS NOT NULL THEN
        -- Get the new transaction Id
        SELECT igf_aw_award_level_hist_s.NEXTVAL INTO l_award_hist_tran_id from dual;
        -- insert history record for the 6 attributes IF any change
        l_row_id := null;
        OPEN c_lookup_attribute;
        LOOP
            l_awd_attr_changed := FALSE;
            FETCH c_lookup_attribute INTO l_award_atrr_code;
            EXIT WHEN c_lookup_attribute%NOTFOUND;
            l_awd_attr_changed := isChangeIn_AwardAttribute(l_award_atrr_code);
            l_row_id := null;
            /* If award attributes Change, then insert */
            IF (l_awd_attr_changed) THEN
              igf_aw_award_level_hist_pkg.insert_row
              (
                  x_rowid                     => l_row_id,
                  x_award_id                  => g_new_award_rec.award_id,
                  x_award_hist_tran_id        => l_award_hist_tran_id,
                  x_award_attrib_code         => l_award_atrr_code,
                  x_award_change_source_code  => 'CONCURRENT_PROCESS',
                  x_old_offered_amt           => g_old_award_rec.offered_amt,
                  x_new_offered_amt           => g_new_award_rec.offered_amt,
                  x_old_accepted_amt          => g_old_award_rec.accepted_amt,
                  x_new_accepted_amt          => g_new_award_rec.accepted_amt,
                  x_old_paid_amt              => g_old_award_rec.paid_amt,
                  x_new_paid_amt              => g_new_award_rec.paid_amt,
                  x_old_lock_award_flag       => g_old_award_rec.lock_award_flag,
                  x_new_lock_award_flag       => g_new_award_rec.lock_award_flag,
                  x_old_award_status_code     => g_old_award_rec.award_status,
                  x_new_award_status_code     => g_new_award_rec.award_status,
                  x_old_adplans_id            => g_old_award_rec.adplans_id,
                  x_new_adplans_id            => g_new_award_rec.adplans_id,
                  x_mode                      => 'R'
              );
            END IF;
        END LOOP; -- End of Loop - 6 attribute comparison ends
        CLOSE c_lookup_attribute;
      END IF; -- End of records NOT NULL check

      EXCEPTION
        WHEN OTHERS THEN
          fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
          fnd_message.set_token('NAME','igf_aw_li_import.create_new_award_hist_rec' || SQLERRM);
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
     END create_new_award_hist_rec;

    PROCEDURE maintain_old_award_hist_rec IS
    /***************************************************************
      Created By   : bvisvana
      Date Created By  : 17-Oct-2005
      Purpose    : Bug # 4635941 - Maintains the Award History details of the deleted award and assigns
                  those to the newly created award (g_award_id)
      Known Limitations,Enhancements or Remarks
      Change History :
      Who      When          What
     ***************************************************************/
    BEGIN
      FOR i IN g_old_award_hist_col.FIRST..g_old_award_hist_col.LAST LOOP
          INSERT INTO igf_aw_award_level_hist (
            award_id,
            award_hist_tran_id,
            award_attrib_code,
            award_change_source_code,
            old_offered_amt,
            new_offered_amt,
            old_accepted_amt,
            new_accepted_amt,
            old_paid_amt,
            new_paid_amt,
            old_lock_award_flag,
            new_lock_award_flag,
            old_award_status_code,
            new_award_status_code,
            old_adplans_id,
            new_adplans_id,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login,
            request_id,
            program_id,
            program_application_id,
            program_update_date
          ) VALUES (
            g_award_id,
            g_old_award_hist_col(i).award_hist_tran_id,
            g_old_award_hist_col(i).award_attrib_code,
            g_old_award_hist_col(i).award_change_source_code,
            g_old_award_hist_col(i).old_offered_amt,
            g_old_award_hist_col(i).new_offered_amt,
            g_old_award_hist_col(i).old_accepted_amt,
            g_old_award_hist_col(i).new_accepted_amt,
            g_old_award_hist_col(i).old_paid_amt,
            g_old_award_hist_col(i).new_paid_amt,
            g_old_award_hist_col(i).old_lock_award_flag,
            g_old_award_hist_col(i).new_lock_award_flag,
            g_old_award_hist_col(i).old_award_status_code,
            g_old_award_hist_col(i).new_award_status_code,
            g_old_award_hist_col(i).old_adplans_id,
            g_old_award_hist_col(i).new_adplans_id,
            g_old_award_hist_col(i).created_by,
            g_old_award_hist_col(i).creation_date,
            g_old_award_hist_col(i).last_updated_by,
            g_old_award_hist_col(i).last_update_date,
            g_old_award_hist_col(i).last_update_login,
            g_old_award_hist_col(i).request_id,
            g_old_award_hist_col(i).program_id,
            g_old_award_hist_col(i).program_application_id,
            g_old_award_hist_col(i).program_update_date
            );
        END LOOP;
    END maintain_old_award_hist_rec;

    PROCEDURE create_award_record(li_awd_rec IN igf_aw_li_awd_ints%ROWTYPE, l_awd_ins_status OUT NOCOPY VARCHAR2) IS
    /***************************************************************
   Created By   : nsidana
   Date Created By  : 11/28/2003
   Purpose    : Created awards in the system.
   Known Limitations,Enhancements or Remarks
   Change History :
   Who      When          What
 ***************************************************************/
      l_awd_rowid VARCHAR2(25);
      l_alt_pell_schedule igf_aw_award_all.alt_pell_schedule%TYPE;

     CURSOR c_visa (cv_person_id      hz_parties.party_id%TYPE ) IS
      SELECT a.visa_type,
             a.visa_category,
             a.visa_number,
             a.visa_expiry_date,
             b.visit_start_date entry_date
        FROM igs_pe_visa a,
             igs_pe_visit_histry b
       WHERE a.person_id = cv_person_id
         AND NVL(a.visa_expiry_date,SYSDATE) >= SYSDATE
         AND a.visa_id = b.visa_id
       ORDER BY a.visa_expiry_date DESC;

    visa_rec            c_visa%ROWTYPE;

    CURSOR c_hzp (cv_person_id     hz_parties.party_id%TYPE ) IS
      SELECT person_first_name,
             person_last_name,
             address1,
             address2,
             address3,
             address4,
             city,
             state,
             province,
             county,
             country
        FROM hz_parties
       WHERE party_id = cv_person_id;

     hzp_rec          c_hzp%ROWTYPE;
     l_warning        VARCHAR2(200);

    BEGIN --begin of create_award_record

      l_awd_rowid := NULL; g_award_id:= NULL;
      IF(li_awd_rec.alt_pell_schedule_type = 'Y')THEN
        l_alt_pell_schedule := 'A';
      ELSIF(li_awd_rec.alt_pell_schedule_type IS NULL)THEN
        l_alt_pell_schedule := 'R';
      END IF;
      igf_aw_award_pkg.insert_row(
                                  x_rowid              => l_awd_rowid,
                                  x_award_id           => g_award_id,
                                  x_fund_id            => g_fund_id,
                                  x_base_id            => g_base_id,
                                  x_offered_amt        => li_awd_rec.offered_amt,
                                  x_accepted_amt       => li_awd_rec.accepted_amt,
                                  x_paid_amt           => NULL,
                                  x_packaging_type     => NULL,
                                  x_batch_id           => NULL,
                                  x_manual_update      => NULL,
                                  x_rules_override     => NULL,
                                  x_award_date         => li_awd_rec.award_date,
                                  x_award_status       => li_awd_rec.award_status_code,
                                  x_attribute_category => NULL,
                                  x_attribute1         => NULL,
                                  x_attribute2         => NULL,
                                  x_attribute3         => NULL,
                                  x_attribute4         => NULL,
                                  x_attribute5         => NULL,
                                  x_attribute6         => NULL,
                                  x_attribute7         => NULL,
                                  x_attribute8         => NULL,
                                  x_attribute9         => NULL,
                                  x_attribute10        => NULL,
                                  x_attribute11        => NULL,
                                  x_attribute12        => NULL,
                                  x_attribute13        => NULL,
                                  x_attribute14        => NULL,
                                  x_attribute15        => NULL,
                                  x_attribute16        => NULL,
                                  x_attribute17        => NULL,
                                  x_attribute18        => NULL,
                                  x_attribute19        => NULL,
                                  x_attribute20        => NULL,
                                  x_rvsn_id            => NULL,
                                  x_alt_pell_schedule  => l_alt_pell_schedule,
                                  x_award_number_txt   => li_awd_rec.award_number_txt,
                                  x_legacy_record_flag => 'Y',
                                  x_adplans_id         => NULL,
                                  x_lock_award_flag    => li_awd_rec.lock_award_flag,
                                  x_app_trans_num_txt  => li_awd_rec.app_trans_num_txt,
                                  x_awd_proc_status_code => NULL,
                                  x_notification_status_code => 'R',
                                  x_notification_status_date => TRUNC(SYSDATE),
                                  x_publish_in_ss_flag => li_awd_rec.publish_in_ss_flag
                                 );
      IF(l_awd_rowid IS NULL AND g_award_id IS NULL) THEN
        l_awd_ins_status := 'E';
      ELSE
        l_awd_ins_status := 'S';
        -- bvisvana - Bug # 4635941 - START
        IF g_update_mode AND g_old_award_hist_col.COUNT > 0 THEN
          -- Maintain / preserve the old award history if running in UPDATE MODE and if some history exists
          maintain_old_award_hist_rec;
        END IF;
        -- While running in update mode, there wud be some changes and hence new award history should be inserted
        IF g_update_mode THEN
            create_new_award_hist_rec;
            -- Clear the mode and history collection
            g_update_mode := FALSE;
            g_old_award_hist_col.DELETE;
        END IF;
        -- bvisvana - Bug # 4635941 - END
      END IF;

     IF(g_fed_fund_code = 'FWS' AND li_awd_rec.authorization_date IS NOT NULL
        AND TRUNC(li_awd_rec.authorization_date) <= TRUNC(SYSDATE) AND l_awd_ins_status <> 'E')THEN
       BEGIN
         OPEN  c_hzp (g_person_id);
         FETCH c_hzp INTO hzp_rec;
         CLOSE c_hzp;
         OPEN  c_visa (g_person_id);
         FETCH c_visa INTO visa_rec;

         IF c_visa%NOTFOUND AND (hzp_rec.country IS NOT NULL AND hzp_rec.country <> 'US') THEN
            fnd_message.set_name('FND','FND_MBOX_WARN_CONSTANT');
            l_warning := fnd_message.get;
            fnd_message.set_name('IGF','IGF_SE_INVALID_SETUP');
            fnd_message.set_token('PLACE','VISA');
            fnd_file.put_line( fnd_file.log,'   -- '||l_warning ||' : '|| fnd_message.get);
            CLOSE c_visa;
            IF(l_awd_ins_status <> 'E')THEN
               l_awd_ins_status := 'W';
            END IF;

         ELSE
            CLOSE c_visa;
         END IF;

         igf_se_gen_001.send_work_auth(
                                       g_base_id,
                                       g_person_id,
                                       g_fund_id,
                                       g_award_id,
                                       NULL,
                                       NULL,
                                       'LEGACY',
                                       li_awd_rec.authorization_date
                                      );

       EXCEPTION
        WHEN igf_se_gen_001.IGFSEGEN001 THEN
         IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
           FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_aw_li_import.create_work_authorization.exception',SQLERRM);
         END IF;
         l_awd_ins_status := 'E';
         RETURN;

        WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
         FND_MESSAGE.SET_TOKEN('NAME','CREATING WORK AUTHORIZATION : '||SQLERRM);
         FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(' ',3,' ')||'-- '||FND_MESSAGE.GET);
         IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
           FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_aw_li_import.create_work_authorization.exception',SQLERRM);
         END IF;
         l_awd_ins_status := 'E';
         RETURN;
       END;
     END IF;

    EXCEPTION WHEN OTHERS THEN
      l_awd_ins_status := 'E';
      IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                 'igf.plsql.igf_aw_li_import.create_award_record.exception',
           SQLERRM );
      END IF;
      FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','CREATE_AWARD_RECORD : '||SQLERRM);
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    END create_award_record;

    PROCEDURE delete_award_and_child_records(p_award_id IN igf_aw_award_all.award_id%TYPE) IS
    /***************************************************************
   Created By   : nsidana
   Date Created By  : 11/28/2003
   Purpose    :  deletes awards and child records.
   Known Limitations,Enhancements or Remarks
   Change History :
   Who        When          What
   bvisvana   17-Oct-2005   Bug # 4635941 - Capturing the award history before deleting the award
                            Capturing the award details before deleting the award
 ***************************************************************/
      CURSOR c_get_awd_row IS
      SELECT ROWID row_id
      FROM igf_aw_award_all
      WHERE award_id = p_award_id;

      -- bvisvana - Bug # 4635941 - Added new cursors
      CURSOR c_get_awd_hist IS
      SELECT ROWID row_id
      FROM igf_aw_award_level_hist
      WHERE award_id = p_award_id;

      CURSOR c_get_awd_hist_details IS
      SELECT * FROM igf_aw_award_level_hist
      WHERE award_id = p_award_id;
      c_award_hist_rec c_get_awd_hist_details%ROWTYPE;

      CURSOR c_get_disb_row IS
      SELECT ROWID row_id, auth_id
      FROM igf_aw_awd_disb_all
      WHERE award_id = p_award_id;

      CURSOR c_get_disb_dtl_row IS
      SELECT ROWID row_id
      FROM igf_db_awd_disb_dtl_all
      WHERE award_id = p_award_id;

      CURSOR c_get_disb_holds_row IS
      SELECT ROWID row_id
      FROM igf_db_disb_holds_all
      WHERE award_id = p_award_id;

      CURSOR c_get_auth_row (cp_auth_id igf_se_auth.auth_id%TYPE) IS
      SELECT ROWID row_id
      FROM igf_se_auth
      WHERE auth_id = cp_auth_id;

      CURSOR c_get_disb_chg_dtls_row (p_award_id igf_aw_award_all.award_id%TYPE) IS
      SELECT ROWID row_id
      FROM igf_aw_db_chg_dtls
      WHERE award_id = p_award_id;

      CURSOR c_get_cod_dtl_row (p_award_id igf_aw_award_all.award_id%TYPE) IS
      SELECT ROWID row_id
      FROM igf_aw_db_cod_dtls
      WHERE award_id = p_award_id;


    BEGIN --begin of delete_award_and_child_records

      -- bvisvana - Bug # 4635941 - START
      -- While deleting the award, collect details of the award and also its history.
      g_hist_cnt  := 0;
      OPEN  c_get_awd_details(cp_award_id => p_award_id);
      FETCH c_get_awd_details INTO g_old_award_rec;
      CLOSE c_get_awd_details;

      OPEN c_get_awd_hist_details;
      LOOP
        FETCH c_get_awd_hist_details INTO c_award_hist_rec;
        EXIT WHEN c_get_awd_hist_details%NOTFOUND;
        g_hist_cnt := g_hist_cnt + 1;
        g_old_award_hist_col(g_hist_cnt).award_id                 := c_award_hist_rec.award_id;
        g_old_award_hist_col(g_hist_cnt).award_hist_tran_id       := c_award_hist_rec.award_hist_tran_id;
        g_old_award_hist_col(g_hist_cnt).award_attrib_code        := c_award_hist_rec.award_attrib_code;
        g_old_award_hist_col(g_hist_cnt).award_change_source_code := c_award_hist_rec.award_change_source_code;
        g_old_award_hist_col(g_hist_cnt).old_offered_amt          := c_award_hist_rec.old_offered_amt;
        g_old_award_hist_col(g_hist_cnt).new_offered_amt          := c_award_hist_rec.new_offered_amt;
        g_old_award_hist_col(g_hist_cnt).old_accepted_amt         := c_award_hist_rec.old_accepted_amt;
        g_old_award_hist_col(g_hist_cnt).new_accepted_amt         := c_award_hist_rec.new_accepted_amt;
        g_old_award_hist_col(g_hist_cnt).old_paid_amt             := c_award_hist_rec.old_paid_amt;
        g_old_award_hist_col(g_hist_cnt).new_paid_amt             := c_award_hist_rec.new_paid_amt;
        g_old_award_hist_col(g_hist_cnt).old_lock_award_flag      := c_award_hist_rec.old_lock_award_flag;
        g_old_award_hist_col(g_hist_cnt).new_lock_award_flag      := c_award_hist_rec.new_lock_award_flag;
        g_old_award_hist_col(g_hist_cnt).old_award_status_code    := c_award_hist_rec.old_award_status_code;
        g_old_award_hist_col(g_hist_cnt).new_award_status_code    := c_award_hist_rec.new_award_status_code;
        g_old_award_hist_col(g_hist_cnt).old_adplans_id           := c_award_hist_rec.old_adplans_id;
        g_old_award_hist_col(g_hist_cnt).new_adplans_id           := c_award_hist_rec.new_adplans_id;
        g_old_award_hist_col(g_hist_cnt).created_by               := c_award_hist_rec.created_by;
        g_old_award_hist_col(g_hist_cnt).creation_date            := c_award_hist_rec.creation_date;
        g_old_award_hist_col(g_hist_cnt).last_updated_by          := c_award_hist_rec.last_updated_by;
        g_old_award_hist_col(g_hist_cnt).last_update_date         := c_award_hist_rec.last_update_date;
        g_old_award_hist_col(g_hist_cnt).last_update_login        := c_award_hist_rec.last_update_login;
        g_old_award_hist_col(g_hist_cnt).request_id               := c_award_hist_rec.request_id;
        g_old_award_hist_col(g_hist_cnt).program_application_id   := c_award_hist_rec.program_application_id;
        g_old_award_hist_col(g_hist_cnt).program_id               := c_award_hist_rec.program_id;
        g_old_award_hist_col(g_hist_cnt).program_update_date      := c_award_hist_rec.program_update_date;
      END LOOP;
      CLOSE c_get_awd_hist_details;
      -- bvisvana - Bug # 4635941 - END

    -- while deleting the record in IGF_AW_AWD_DISB_ALL delete also from IGF_AW_DB_CHG_DTLS

      FOR c_get_disb_dtl_row_rec IN c_get_disb_dtl_row LOOP
        igf_db_awd_disb_dtl_pkg.delete_row(c_get_disb_dtl_row_rec.row_id);
      END LOOP;

      FOR c_get_cod_dtl_row_rec IN c_get_cod_dtl_row (p_award_id) LOOP
        igf_aw_db_cod_dtls_pkg.delete_row(c_get_cod_dtl_row_rec.row_id);
      END LOOP;

      FOR c_get_disb_chg_dtls_row_rec IN c_get_disb_chg_dtls_row(p_award_id) LOOP
          igf_aw_db_chg_dtls_pkg.delete_row(c_get_disb_chg_dtls_row_rec.row_id);
      END LOOP;

      FOR c_get_disb_holds_row_rec IN c_get_disb_holds_row LOOP
        igf_db_disb_holds_pkg.delete_row(c_get_disb_holds_row_rec.row_id);
      END LOOP;

      FOR c_get_disb_row_rec IN c_get_disb_row LOOP
        -- Delete the authorization record for the corresponsing Disb
        IF c_get_disb_row_rec.auth_id IS NOT NULL THEN
          FOR c_get_auth_row_rec IN c_get_auth_row(c_get_disb_row_rec.auth_id) LOOP
            igf_se_auth_pkg.delete_row(c_get_auth_row_rec.row_id);
          END LOOP;
        END IF;
        igf_aw_awd_disb_pkg.delete_row(c_get_disb_row_rec.row_id);
      END LOOP;

      -- bvisvana - Bug # 4635941 - Delete the Award History
      FOR award_hist_rec IN c_get_awd_hist LOOP
         igf_aw_award_level_hist_pkg.delete_row(award_hist_rec.row_id);
      END LOOP;

      FOR c_get_awd_row_rec IN c_get_awd_row LOOP
        igf_aw_award_pkg.delete_row(c_get_awd_row_rec.row_id);
      END LOOP;

    END delete_award_and_child_records;

    PROCEDURE upd_aw_rec_with_legacy_status(p_award_id IN igf_aw_award_all.award_id%TYPE) IS
    /***************************************************************
   Created By   : nsidana
   Date Created By  : 11/28/2003
   Purpose    :  updates awards records with legacy status.
   Known Limitations,Enhancements or Remarks
   Change History :
   Who      When          What
 ***************************************************************/
      CURSOR c_get_award IS
      SELECT ROWID row_id,awd.*
      FROM igf_aw_award_all awd
      WHERE award_id = p_award_id;
      c_get_award_rec c_get_award%ROWTYPE;
    BEGIN --begin of upd_aw_rec_with_legacy_status

      OPEN c_get_award; FETCH c_get_award INTO c_get_award_rec; CLOSE c_get_award;
        igf_aw_award_pkg.update_row (
          x_rowid             => c_get_award_rec.row_id,
          x_award_id          => c_get_award_rec.award_id,
          x_fund_id           => c_get_award_rec.fund_id,
          x_base_id           => c_get_award_rec.base_id,
          x_offered_amt       => c_get_award_rec.offered_amt,
          x_accepted_amt      => c_get_award_rec.accepted_amt,
          x_paid_amt          => c_get_award_rec.paid_amt,
          x_packaging_type    => c_get_award_rec.packaging_type,
          x_batch_id          => c_get_award_rec.batch_id,
          x_manual_update     => c_get_award_rec.manual_update,
          x_rules_override    => c_get_award_rec.rules_override,
          x_award_date        => c_get_award_rec.award_date,
          x_award_status      => c_get_award_rec.award_status,
          x_attribute_category => c_get_award_rec.attribute_category,
          x_attribute1        => c_get_award_rec.attribute1,
          x_attribute2        => c_get_award_rec.attribute2,
          x_attribute3        => c_get_award_rec.attribute3,
          x_attribute4        => c_get_award_rec.attribute4,
          x_attribute5        => c_get_award_rec.attribute5,
          x_attribute6        => c_get_award_rec.attribute6,
          x_attribute7        => c_get_award_rec.attribute7,
          x_attribute8        => c_get_award_rec.attribute8,
          x_attribute9        => c_get_award_rec.attribute9,
          x_attribute10       => c_get_award_rec.attribute10,
          x_attribute11       => c_get_award_rec.attribute11,
          x_attribute12       => c_get_award_rec.attribute12,
          x_attribute13       => c_get_award_rec.attribute13,
          x_attribute14       => c_get_award_rec.attribute14,
          x_attribute15       => c_get_award_rec.attribute15,
          x_attribute16       => c_get_award_rec.attribute16,
          x_attribute17       => c_get_award_rec.attribute17,
          x_attribute18       => c_get_award_rec.attribute18,
          x_attribute19       => c_get_award_rec.attribute19,
          x_attribute20       => c_get_award_rec.attribute20,
          x_rvsn_id           => c_get_award_rec.rvsn_id,
          x_alt_pell_schedule => c_get_award_rec.alt_pell_schedule,
          x_award_number_txt  => c_get_award_rec.award_number_txt,
          x_legacy_record_flag => 'Y', -- this is required as the award record is modified to have legacy as N by other processes
          x_adplans_id         => c_get_award_rec.adplans_id,
          x_app_trans_num_txt  => c_get_award_rec.app_trans_num_txt,
          x_lock_award_flag    => c_get_award_rec.lock_award_flag,
          x_awd_proc_status_code => c_get_award_rec.awd_proc_status_code,
          x_notification_status_code => c_get_award_rec.notification_status_code,
          x_notification_status_date => c_get_award_rec.notification_status_date,
          x_publish_in_ss_flag       => c_get_award_rec.publish_in_ss_flag
        );

    END upd_aw_rec_with_legacy_status;

  BEGIN -- begin of validate_awdyear_int_rec

    IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
      FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_aw_li_import.validate_awdyear_int_rec.debug','start' );
    END IF;

    -- initialize the return statuses, assuming all the validations are successful.
    l_return_value :='S'; l_status_open_awd_yr :='S'; l_return_status_db := 'S';
    -- initialize applicable global variables here.
    g_base_id := NULL; g_fund_code := NULL; g_fed_fund_code := NULL; g_fund_id := NULL;
    g_processing_string := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PROCESSING') || ' '||
                           igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','AWARD_NUMBER')|| ' : '
                           || li_awd_rec.award_number_txt ||'  '||
                           igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','FUND_CODE')
                           || ' : '|| li_awd_rec.fund_code;
    FND_FILE.PUT_LINE(FND_FILE.LOG,g_processing_string);

    IF(li_awd_rec.import_record_type = 'U' OR li_awd_rec.import_record_type IS NULL) THEN
      g_base_id := get_base_id_from_per_num(li_awd_rec.person_number, g_ci_cal_type, g_ci_sequence_number);

      IF(g_base_id IS NOT NULL AND g_base_id <> -1) THEN
        l_award_id := NULL; l_legacy_record_flag := NULL;
        OPEN cur_check_sys_awd(g_base_id); FETCH cur_check_sys_awd INTO l_award_id, l_legacy_record_flag;
        IF(li_awd_rec.import_record_type = 'U' AND cur_check_sys_awd%NOTFOUND) THEN
          CLOSE cur_check_sys_awd;
          l_return_value :='E';
          FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_UPD_FAIL_LINOT_FND');
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          RETURN;
        ELSIF(li_awd_rec.import_record_type IS NULL AND cur_check_sys_awd%FOUND) THEN
          CLOSE cur_check_sys_awd;
          l_return_value :='E';
          FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_AWD_ALREADY_PRSNT');
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          RETURN;
        ELSIF((li_awd_rec.import_record_type = 'U' AND cur_check_sys_awd%FOUND) OR
              (li_awd_rec.import_record_type IS NULL AND cur_check_sys_awd%NOTFOUND)
              ) THEN
          CLOSE cur_check_sys_awd;

          -- validate all the fields in the interface table. do not return unless all the fields are validated


          -- first validate if the award year status code is valid
          IF(li_awd_rec.award_status_code IN ('E_ACCEPTED','E_OFFERED','REVISED','SIMULATED','STOPPED')
             OR igf_ap_gen.get_aw_lookup_meaning('IGF_AWARD_STATUS',li_awd_rec.award_status_code, g_sys_award_year) IS NULL)THEN
            l_return_value :='E';
            FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_INVALID_AWD_STATUS');
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          END IF;

          -- second, validate if the fund code in the interface table matches with that of the fund master

          g_fund_code := NULL; g_fed_fund_code := NULL; g_fund_id := NULL;
          OPEN cur_get_fund_code(li_awd_rec.fund_code); FETCH cur_get_fund_code INTO g_fund_code, g_fed_fund_code, g_fund_id; CLOSE cur_get_fund_code;
          IF(FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level)THEN
            g_debug_string := g_debug_string || 'Fund Code'||g_fund_code||'Fed Fund Code'||g_fed_fund_code||'Fund Id'||g_fund_id;
          END IF;
          IF(g_fund_code IS NULL OR g_fund_id IS NULL)THEN

            l_return_value :='E';
            FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_FUND_CODE_NOT_FND');
            FND_MESSAGE.SET_TOKEN('FUND_CODE',li_awd_rec.fund_code);
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
          ELSE

            SAVEPOINT st_def_del_award_records;
            -- delete production records only if legacy record is present in the system with legacy_record_flag = Y
            IF(l_award_id IS NOT NULL)THEN
              IF(NVL(l_legacy_record_flag,'N') = 'Y')THEN

                IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_aw_li_import.validate_awdyear_int_rec.debug','calling DELETE with award id' || l_award_id );
                END IF;
                g_update_mode := TRUE; -- bvisvana - Bug # 4635941 - To track the update mode
                delete_award_and_child_records(l_award_id);

                 IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_aw_li_import.validate_awdyear_int_rec.debug','deleted records with award id' || l_award_id );
                END IF;
              ELSE
                l_return_value :='E';
                FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_UPD_FAILED_NOT_LI'); --sjalasut, should this message b changed ?
                FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
                RETURN;
              END IF;
            END IF;

            -- second, variant one. introduced in FACR117. Sponsorships cannot be imported for open award year.
            -- no further validations are required on this award if its a sponsorship and the award year is open
            IF(g_fed_fund_code = 'SPNSR' AND g_award_year_status_code = 'O')THEN
              l_return_value :='E';
              FND_MESSAGE.SET_NAME('IGF','IGF_SP_LI_NOT_IMP_4OPEN_AWDYR');
              FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
              RETURN;
            END IF;

            --
            -- External Awards Import can only import EXT funds
            --
            IF g_entry_point = 'EXTERNAL' AND g_fed_fund_code <> 'EXT' THEN
                l_return_value :='E';
                FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_FUND_CODE_FAIL');
                FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
                RETURN;
            END IF;

            -- variant two. If the sponsorship has financial aid hold information, error out and do not proceed further with
            -- this award.
            IF(g_fed_fund_code = 'SPNSR')THEN
              c_get_fa_hold_spnsr_rec := NULL;
              OPEN c_get_fa_hold_spnsr;FETCH c_get_fa_hold_spnsr INTO c_get_fa_hold_spnsr_rec; CLOSE c_get_fa_hold_spnsr;
              IF(c_get_fa_hold_spnsr_rec.exist_hold IS NOT NULL)THEN
                l_return_value :='E';
                FND_MESSAGE.SET_NAME('IGF','IGF_SP_LI_HOLD_PRSNT');
                FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
                RETURN;
              END IF;
              -- for sponsorship awards, award status should always be accepted.
              IF(li_awd_rec.award_status_code <> 'ACCEPTED')THEN
                l_return_value :='E';
                FND_MESSAGE.SET_NAME('IGF','IGF_SP_LI_AWD_ACPT');
                FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
              END IF;
            END IF;

            -- variant three. a student can have only one FWS award in an award year. this check should be done here to
            -- save further porcessing time.
            IF g_fed_fund_code = 'FWS' THEN
              -- Authorization Date should be NULL if the context award status is Offered.
              IF(li_awd_rec.award_status_code = 'OFFERED' AND li_awd_rec.authorization_date IS NOT NULL)THEN
                l_return_value := 'E';
                FND_MESSAGE.SET_NAME('IGF','IGF_SE_LI_AUTH_DT_BLNK_OFFRD');
                FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
              END IF;

              -- Authorization Date should not be greater than sysdate
              IF(li_awd_rec.authorization_date IS NOT NULL AND TRUNC(li_awd_rec.authorization_date) > TRUNC(SYSDATE))THEN
                l_return_value := 'E';
                FND_MESSAGE.SET_NAME('IGF','IGF_SE_LI_DATE_GT_SYSDATE');
                FND_MESSAGE.SET_TOKEN('DATE','AUTHORIZATION_DATE');
                FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
              END IF;

              -- SSN is mandatory for Federal Work Study Funds
              c_get_person_ssn_rec := NULL;
              OPEN c_get_person_ssn; FETCH c_get_person_ssn INTO c_get_person_ssn_rec; CLOSE c_get_person_ssn;
              IF(c_get_person_ssn_rec.api_person_id IS NULL)THEN
                l_return_value := 'E';
                FND_MESSAGE.SET_NAME('IGF', 'IGF_SE_LI_SSN_NOT_PRSNT');
                FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
              END IF;
            ELSE

              -- authorization date should be blank for all the funds except Federal Work Study
              IF(li_awd_rec.authorization_date IS NOT NULL)THEN
                l_return_value := 'E';
                FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_AWD_COL_BLNK');
                FND_MESSAGE.SET_TOKEN('COLUMN_NAME','AUTHORIZATION_DATE');
                FND_MESSAGE.SET_TOKEN('FUND_CODE',li_awd_rec.fund_code);
                FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
              END IF;
            END IF;

            -- third, check if the offered amount > 0
            IF(li_awd_rec.offered_amt <= 0)THEN
              l_return_value :='E';
              FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_AWD_OFRD_AMT_GT_0');
              FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            ELSE -- interface offered amount should not match with the total sponsor amt for sponsorships.
                 -- validation introduced in FACR117

              IF(g_fed_fund_code = 'SPNSR')THEN
                c_get_spnsr_amt_rec := NULL;
                OPEN c_get_spnsr_amt; FETCH c_get_spnsr_amt INTO c_get_spnsr_amt_rec; CLOSE c_get_spnsr_amt;
                IF(c_get_spnsr_amt_rec.max_yearly_amt IS NOT NULL AND li_awd_rec.offered_amt <> c_get_spnsr_amt_rec.max_yearly_amt) THEN
                  IF(l_return_value <> 'E')THEN
                     l_return_value := 'W';
                  END IF;
                  FND_MESSAGE.SET_NAME('IGF','IGF_SP_LI_TOTAL_AMT_MISMTCH');
                  FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
                END IF;
              END IF;
            END IF;

            -- fourth, if the award status is accepted then
            IF(li_awd_rec.award_status_code = 'ACCEPTED')THEN
              IF(li_awd_rec.accepted_amt IS NULL OR li_awd_rec.accepted_amt <= 0)THEN
                l_return_value :='E';
                FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_ACPT_AMT_GT_0_ACPT');
                FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
              END IF;
              IF(li_awd_rec.accepted_amt IS NOT NULL AND li_awd_rec.accepted_amt > li_awd_rec.offered_amt)THEN
                l_return_value :='E';
                FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_ACPT_AMT_GT_OFRD_AMT');
                FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
              END IF;
              -- for sponsorships, the accepted amount and the offered amount should be equal.
              IF(li_awd_rec.accepted_amt IS NOT NULL AND g_fed_fund_code = 'SPNSR' AND li_awd_rec.accepted_amt <> li_awd_rec.offered_amt)THEN
                l_return_value :='E';
                FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_EQ_ACPT_OFRD_AMT');
                FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
              END IF;
            ELSIF(li_awd_rec.award_status_code IN ('OFFERED','CANCELLED','DECLINED'))THEN
              --bug #3701698
              IF (li_awd_rec.award_status_code = 'CANCELLED' AND
                  ( li_awd_rec.accepted_amt IS NULL OR li_awd_rec.accepted_amt <> 0 )
                 ) THEN
                l_return_value :='E';
                FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_ACPT_AMT_AWD_CNCL');
                FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

              ELSIF(li_awd_rec.accepted_amt < 0)THEN
                l_return_value :='E';
                FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_ACPT_AMT_NEG');
                FND_MESSAGE.SET_TOKEN('AWD_STATUS', li_awd_rec.award_status_code);
                FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
              END IF;
            END IF;

            -- fifth, validate Pell Alternate Schedule indicator. for this we have to validate if the fund code is
            -- mapped to PELL fed fund code
            IF(g_fed_fund_code = 'PELL')THEN
              IF(li_awd_rec.alt_pell_schedule_type IS NOT NULL AND li_awd_rec.alt_pell_schedule_type <> 'Y') THEN
                l_return_value :='E';
                FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_INVLD_PELL_ALT_CD');
                FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
              END IF;
              IF(li_awd_rec.import_record_type IS NULL)THEN
                -- student can have only one PELL fund code in the given award year. check if this guy has a PELL already
                -- since the interface record is marked for insert. the same curosor is used for FWS also, hence the name.
                c_1_more_pell_fws_rec := NULL;
                OPEN c_1_more_pell_fws; FETCH c_1_more_pell_fws INTO c_1_more_pell_fws_rec; CLOSE c_1_more_pell_fws;
                IF(c_1_more_pell_fws_rec.present_in_award IS NOT NULL)THEN
                  l_return_value :='E';
                  FND_MESSAGE.SET_NAME('IGF','IGF_AW_MORE_PELL_AWD');
                  FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
                END IF;
              END IF;
            ELSE -- for all awards other than Pell, the pell alternate schedule type should be null
              IF(li_awd_rec.alt_pell_schedule_type IS NOT NULL) THEN
                l_return_value :='E';
                FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_PELL_ALT_IND_BLNK');
                FND_MESSAGE.SET_TOKEN('FUND_CODE',li_awd_rec.fund_code);
                FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
              END IF;
            END IF;
            IF(FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level)THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'igf.plsql.igf_aw_li_import.validate_awdyear_int_rec.debug', g_debug_string);
              g_debug_string := NULL;
            END IF;

            -- <nsidana 11/27/2003   FA131 COD updates build>
            -- Adding a check to see that the new col lock_award has only valid values i.e 'Y' or null.
            IF (li_awd_rec.lock_award_flag IS NOT NULL) THEN
              IF li_awd_rec.lock_award_flag NOT IN ('Y','N') THEN
                l_return_value :='E';
                fnd_message.set_name('IGF','IGF_AW_LI_INVD_LOCK_AWD_VAL');
                fnd_file.put_line(fnd_file.log,fnd_message.get);
              END IF;
            ELSE
              li_awd_rec.lock_award_flag := 'N';
            END IF;

            -- </nsidana 11/27/2003 FA131 COD updates.>

            IF li_awd_rec.publish_in_ss_flag IS NULL OR li_awd_rec.publish_in_ss_flag NOT IN ('Y','N') THEN
              l_return_value := 'E';
              fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
              fnd_message.set_token('FIELD','PUBLISH_IN_SS_FLAG');
              fnd_file.put_line(fnd_file.log,fnd_message.get);
            END IF;
            -- sixth, if the context award year is open and the return status is not E then perform open year validations
            IF(l_return_value IN ('S','W') AND g_award_year_status_code = 'O')THEN

             IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
                fnd_log.string(fnd_log.level_exception, 'igf.plsql.igf_aw_li_import.validate_awdyear_int_rec.debug','calling validate open awd' );
             END IF;

             validate_open_award_year(li_awd_rec, l_status_open_awd_yr);

            END IF;
            IF(l_return_value IN ('S','W') AND l_status_open_awd_yr IN ('S','W')) THEN
              BEGIN

              -- insert into awards table
                IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
                  fnd_log.string(fnd_log.level_exception, 'igf.plsql.igf_aw_li_import.validate_awdyear_int_rec.debug','calling create awd rec' );
                END IF;

                create_award_record(li_awd_rec, l_return_status_awd);

                IF(l_return_status_awd = 'E')THEN
                  l_return_value := 'E';
                  ROLLBACK TO st_def_del_award_records;
                  RETURN;
                END IF;

                IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
                  fnd_log.string(fnd_log.level_exception, 'igf.plsql.igf_aw_li_import.validate_awdyear_int_rec.debug','calling validate_disb_int_rec' );
                END IF;

                validate_disburs_int_rec(li_awd_rec, l_return_status_db);

                IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
                  fnd_log.string(fnd_log.level_exception, 'igf.plsql.igf_aw_li_import.validate_awdyear_int_rec.debug','status returned = ' || l_return_status_db );
                END IF;

                IF(l_return_status_db = 'E') THEN
                  l_return_value := 'E';
                  ROLLBACK TO st_def_del_award_records;
                  RETURN;
                ELSE

                 IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
                  fnd_log.string(fnd_log.level_exception, 'igf.plsql.igf_aw_li_import.validate_awdyear_int_rec.debug','upd_awd_with_leg_stat' );
                 END IF;

                  upd_aw_rec_with_legacy_status(g_award_id);

                END IF;
                -- OR condition because the open award valiations are in the disbursement validation proc also
                IF(l_status_open_awd_yr = 'W' OR l_return_status_db = 'W')THEN
                  l_return_value := 'W';
                ELSE
                  l_return_value := 'S';
                END IF;
              EXCEPTION WHEN OTHERS THEN

                IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
                  FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                  'igf.plsql.igf_aw_li_import.create_award_validate_disb_section.exception',
                  SQLERRM);
                END IF;
                ROLLBACK TO st_def_del_award_records;
                l_return_value := 'E';
                RETURN;
              END;
            ELSE
              ROLLBACK TO st_def_del_award_records;
              l_return_value:='E';
              RETURN;
            END IF; -- return status of l_return_value and l_status_open_awd_yr
          END IF; -- for fund_code is null or fund_id is null
        END IF; --end if of check import record type and sys award year found
      END IF; -- end if of base_id <> -1
    ELSE
      l_return_value :='E';
      FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_INVLD_IMP_REC_TY');
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      RETURN;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK TO st_def_del_award_records;
    l_return_value :='E';
    IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
      FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                     'igf.plsql.igf_aw_li_import.validate_awdyear_int_rec.exception',
         SQLERRM);
    END IF;
    FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','VALIDATE_AWDYEAR_INT_REC : '||SQLERRM);
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
  END validate_awdyear_int_rec;


  PROCEDURE validate_disburs_int_rec(li_awd_rec IN igf_aw_li_awd_ints%ROWTYPE,
             p_return_status OUT NOCOPY VARCHAR2
            ) IS

  /***************************************************************
   Created By   : nsidana
   Date Created By  : 11/28/2003
   Purpose    :  Validates legacy award disbursements interface record.
   Known Limitations,Enhancements or Remarks
   Change History :
   Who      When          What
   nsidana 11/28/2003  FA131 COD updates build. Added validations on 1 feild in the
                                      legacy award disbursements table.
 ***************************************************************/
   CURSOR cur_legacy_disb_int IS
   SELECT
     trim(disbint.ci_alternate_code) ci_alternate_code,
     trim(disbint.person_number) person_number,
     trim(disbint.award_number_txt) award_number_txt,
     disbint.disbursement_num,
     trim(disbint.ld_alternate_code) ld_alternate_code,
     trim(disbint.tp_alternate_code) tp_alternate_code,
     disbint.offered_amt,
     disbint.accepted_amt,
     disbint.fee_1_amt,
     disbint.fee_2_amt,
     disbint.disb_date,
     trim(disbint.trans_type_code) trans_type_code,
     disbint.elig_status_date,
     disbint.affirm_flag,
     disbint.int_rebate_amt,
     disbint.force_disb_flag,
     disbint.min_credit_pts_num,
     disbint.disb_exp_date,
     disbint.verf_enfr_date,
     disbint.planned_credit_flag,
     disbint.fee_paid_1_amt,
     disbint.fee_paid_2_amt,
     disbint.created_by,
     disbint.creation_date,
     disbint.last_updated_by,
     disbint.last_update_date,
     disbint.last_update_login,
     trim(fee_class_code) fee_class_code,
     authorization_date,
     TRIM(attendance_type_code) attendance_type_code,
     disbint.base_attendance_type_code                                                     -- new col added as part of FA131 COD updates build.
   FROM igf_aw_li_disb_ints disbint
   WHERE ci_alternate_code = li_awd_rec.ci_alternate_code
     AND person_number = li_awd_rec.person_number
     AND award_number_txt = li_awd_rec.award_number_txt
   ORDER BY disbursement_num;

   CURSOR c_uniq_fee_class IS
   SELECT fee_class_code
     FROM igf_aw_li_disb_ints
     WHERE person_number = li_awd_rec.person_number
       AND award_number_txt = li_awd_rec.award_number_txt
     GROUP BY fee_class_code
     HAVING COUNT(fee_class_code) > 1;
   c_uniq_fee_class_rec c_uniq_fee_class%ROWTYPE;

   CURSOR cur_legacy_disb_total IS
   SELECT SUM(offered_amt) total_offered_amt,
          SUM(accepted_amt) total_accepted_amt,
    COUNT(disbursement_num) number_of_disb,
    NVL(MAX(disbursement_num),0) max_disb_number,
    NVL(MIN(disbursement_num),0) min_disb_number
   FROM igf_aw_li_disb_ints
   WHERE ci_alternate_code = li_awd_rec.ci_alternate_code
     AND person_number = li_awd_rec.person_number
     AND award_number_txt = li_awd_rec.award_number_txt;

   cur_legacy_disb_total_rec cur_legacy_disb_total%ROWTYPE;

   CURSOR c_match_disb_term (p_cal_type igf_aw_fund_tp_all.tp_cal_type%TYPE,
                             p_sequence_number igf_aw_fund_tp_all.tp_sequence_number%TYPE) IS
   SELECT fund_id, tp_cal_type, tp_sequence_number
   FROM igf_aw_fund_tp_all
   WHERE fund_id = g_fund_id
     AND tp_cal_type = p_cal_type
     AND tp_sequence_number = p_sequence_number;
   c_match_disb_term_rec c_match_disb_term%ROWTYPE;

   CURSOR c_max_year_spnsr IS
   SELECT fmast.max_yearly_amt
     FROM igf_aw_fund_mast_all fmast,
          igf_aw_fund_cat_all fcat
     WHERE fcat.fund_code = fmast.fund_code
       AND fcat.fed_fund_code = g_fed_fund_code
       AND fmast.fund_id = g_fund_id
       AND fmast.discontinue_fund = 'N';
   c_max_year_spnsr_rec c_max_year_spnsr%ROWTYPE;

   CURSOR c_get_sp_fee_class(p_fee_class_code igf_aw_li_disb_ints.fee_class_code%TYPE) IS
   SELECT fee_cls_id
     FROM igf_sp_fc_all
    WHERE fund_id = g_fund_id
      AND fee_class = p_fee_class_code;
   c_get_sp_fee_class_rec c_get_sp_fee_class%ROWTYPE;

   CURSOR c_get_dact_fws(p_disbursement_num igf_aw_li_disb_ints.disbursement_num%TYPE) IS
   SELECT disb_activity_num
     FROM igf_aw_li_dact_ints
    WHERE ci_alternate_code = li_awd_rec.ci_alternate_code
      AND person_number = li_awd_rec.person_number
      AND award_number_txt = li_awd_rec.award_number_txt
      AND disbursement_num = p_disbursement_num;
   c_get_dact_fws_rec c_get_dact_fws%ROWTYPE;

   CURSOR c_val_lookup_code(p_lookup_type igs_lookups_view.lookup_type%TYPE,
                            p_lookup_code igs_lookups_view.lookup_code%TYPE) IS
   SELECT meaning FROM igs_lookups_view WHERE lookup_type = p_lookup_type AND
     lookup_code = p_lookup_code and enabled_flag = 'Y';
    c_val_lookup_code_rec c_val_lookup_code%ROWTYPE;

   CURSOR c_get_disb_count IS
   SELECT count(*)
   FROM igf_aw_li_disb_ints disbint
   WHERE disbint.ci_alternate_code = li_awd_rec.ci_alternate_code
     AND disbint.person_number = li_awd_rec.person_number
     AND disbint.award_number_txt = li_awd_rec.award_number_txt
   ORDER BY disbursement_num;
   l_disb_rec_count PLS_INTEGER;

   CURSOR c_get_uniq_ld_code IS
   SELECT count(distinct(ld_alternate_code))
     FROM igf_aw_li_disb_ints disbint
   WHERE ci_alternate_code = li_awd_rec.ci_alternate_code
     AND person_number = li_awd_rec.person_number
     AND award_number_txt = li_awd_rec.award_number_txt;
   l_uniq_ld_code PLS_INTEGER;

   CURSOR cur_check_atd( cp_atd_code VARCHAR2) IS
   SELECT attendance_type
     FROM igs_en_atd_type
    WHERE attendance_type = cp_atd_code;

   check_atd_rec    cur_check_atd%ROWTYPE;

   CURSOR cur_legacy_disb_fws_total IS
     SELECT COUNT (DISTINCT ld_alternate_code) terms,
            COUNT (tp_alternate_code) tp
       FROM igf_aw_li_disb_ints
      WHERE ci_alternate_code = li_awd_rec.ci_alternate_code
        AND person_number = li_awd_rec.person_number
        AND award_number_txt = li_awd_rec.award_number_txt;

   cur_legacy_disb_total_fws_rec cur_legacy_disb_fws_total%ROWTYPE;

   l_ctr PLS_INTEGER;
   l_ret_val BOOLEAN;
   l_var_cal_type igs_ca_inst.cal_type%TYPE;
   l_var_seq_number igs_ca_inst.sequence_number%TYPE;
   l_return_status_dh VARCHAR2(1);
   l_return_status_da VARCHAR2(1);
   l_disb_rec_ins_status VARCHAR2(1);
   l_net_amount igf_aw_awd_disb_all.disb_net_amt%TYPE;

   l_padding_string VARCHAR2(100);

   PROCEDURE create_disbursment_record(li_awd_rec IN igf_aw_li_awd_ints%ROWTYPE,
                                       cur_legacy_disb_int_rec IN igf_aw_li_disb_ints%ROWTYPE,
               l_disb_rec_ins_status OUT NOCOPY VARCHAR2
              ) IS
/***************************************************************
   Created By   : nsidana
   Date Created By  : 11/28/2003
   Purpose    : Creates disbursements records in the system.
   Known Limitations,Enhancements or Remarks
   Change History :
   Who      When          What
   nsidana 11/28/2003  FA131 COD updates build. Added validations on two new feilds
                                      added to the legacy awards table and 1 feild in the legacy award
                                      disbursements table.
    --veramach     1-NOV-2003      FA 125 Multiple Distr Methods
    --                             Changed calll to igf_aw_awd_disb_pkg.update_row to reflect the addition of attendance_type_code
    --rasahoo      25/Aug/2003     #3101894  Called procedure send_work_auth with parameter 'LEGACY'
 ***************************************************************/
     l_rowid VARCHAR2(25);

     CURSOR c_get_cal_typ_seq_num(p_alternate_code igs_ca_inst.alternate_code%TYPE) IS
     SELECT cal_type, sequence_number
       FROM igs_ca_inst
      WHERE alternate_code = p_alternate_code;

     CURSOR cur_awd_disb( cp_row_id ROWID) IS
     SELECT rowid row_id, disb.*
       FROM igf_aw_awd_disb_all disb
      WHERE rowid = cp_row_id;

     CURSOR c_get_fed_fund (cp_fund_code  igf_aw_fund_cat_all.fund_code%TYPE) IS
     SELECT fed_fund_code
       FROM igf_aw_fund_cat_all
      WHERE fund_code = cp_fund_code;

     l_fed_fund_code      igf_aw_fund_cat_all.fed_fund_code%TYPE;
     lc_awd_disb          cur_awd_disb%ROWTYPE;
     c_tp_calseq_rec      c_get_cal_typ_seq_num%ROWTYPE;
     c_ld_calseq_rec      c_get_cal_typ_seq_num%ROWTYPE;
     l_warning            VARCHAR2(200);
     l_trans_type         VARCHAR2(1);
     l_cal_type           igs_ca_inst_all.cal_type%TYPE;
     ln_sequence_number   igs_ca_inst_all.sequence_number%TYPE;
     ln_base_id           igf_ap_fa_base_rec_all.base_id%TYPE := NULL;
     l_hol_rel_ind        VARCHAR2(30)  :=  NULL;


   BEGIN
     l_rowid := NULL;

     -- obtain the cal type sequence number for teaching period
     c_tp_calseq_rec := NULL;
     OPEN c_get_cal_typ_seq_num(cur_legacy_disb_int_rec.tp_alternate_code);
     FETCH c_get_cal_typ_seq_num INTO c_tp_calseq_rec;
     CLOSE c_get_cal_typ_seq_num;

     -- obtain the cal type, sequence number for load calendar
     OPEN c_get_cal_typ_seq_num(cur_legacy_disb_int_rec.ld_alternate_code);
     FETCH c_get_cal_typ_seq_num INTO c_ld_calseq_rec;
     CLOSE c_get_cal_typ_seq_num;

     IF li_awd_rec.award_status_code = 'CANCELLED' THEN

      l_net_amount := 0 ;
      l_trans_type := 'C' ;
     ELSE

      l_trans_type := cur_legacy_disb_int_rec.trans_type_code ;
     END IF;

     -- get the hold_rel_ind flag if fed_fund_code in ('ALT', 'FLS', 'FLP', 'FLU')
     l_fed_fund_code := NULL;

     -- cursor to fetch the federal fund code
     OPEN c_get_fed_fund(li_awd_rec.fund_code);
     FETCH c_get_fed_fund INTO l_fed_fund_code;
     CLOSE c_get_fed_fund;

     IF l_fed_fund_code IN ('ALT', 'FLS', 'FLP', 'FLU') THEN
        -- get the cal type, sequence number for the award year
        OPEN c_get_cal_typ_seq_num(li_awd_rec.ci_alternate_code);
        FETCH c_get_cal_typ_seq_num INTO l_cal_type,ln_sequence_number;
        CLOSE c_get_cal_typ_seq_num;

        ln_base_id := get_base_id_from_per_num(li_awd_rec.person_number, l_cal_type, ln_sequence_number);

        l_hol_rel_ind := igf_sl_award.get_cl_hold_rel_ind(
                                                           p_fed_fund_code  =>  l_fed_fund_code,
                                                           p_ci_cal_type    =>  l_cal_type,
                                                           p_ci_seq_num     =>  ln_sequence_number,
                                                           p_base_id        =>  ln_base_id,
                                                           p_alt_rel_code   =>  igf_sl_award.get_alt_rel_code(li_awd_rec.fund_code)
                                                           );

     ELSE
        l_hol_rel_ind := 'FALSE';
     END IF;


     igf_aw_awd_disb_pkg.insert_row(
       x_rowid             => l_rowid,
       x_award_id          => g_award_id,
       x_disb_num          => cur_legacy_disb_int_rec.disbursement_num,
       x_tp_cal_type       => c_tp_calseq_rec.cal_type,
       x_tp_sequence_number=> c_tp_calseq_rec.sequence_number,
       x_disb_gross_amt    => cur_legacy_disb_int_rec.offered_amt,
       x_fee_1             => cur_legacy_disb_int_rec.fee_1_amt,
       x_fee_2             => cur_legacy_disb_int_rec.fee_2_amt,
       x_disb_net_amt      => l_net_amount,
       x_disb_date         => cur_legacy_disb_int_rec.disb_date,
       x_trans_type        => l_trans_type,
       x_elig_status       => NULL,
       x_elig_status_date  => cur_legacy_disb_int_rec.elig_status_date,
       x_affirm_flag       => cur_legacy_disb_int_rec.affirm_flag,
       x_hold_rel_ind      => l_hol_rel_ind,
       x_manual_hold_ind   => NULL,
       x_disb_status       => NULL,
       x_disb_status_date  => NULL,
       x_late_disb_ind     => NULL,
       x_fund_dist_mthd    => NULL,
       x_prev_reported_ind => NULL,
       x_fund_release_date => NULL,
       x_fund_status       => NULL,
       x_fund_status_date  => NULL,
       x_fee_paid_1        => cur_legacy_disb_int_rec.fee_paid_1_amt,
       x_fee_paid_2        => cur_legacy_disb_int_rec.fee_paid_2_amt,
       x_cheque_number     => NULL,
       x_ld_cal_type       => c_ld_calseq_rec.cal_type,
       x_ld_sequence_number=> c_ld_calseq_rec.sequence_number,
       x_disb_accepted_amt => cur_legacy_disb_int_rec.accepted_amt,
       x_disb_paid_amt     => NULL,
       x_rvsn_id           => NULL,
       x_int_rebate_amt    => cur_legacy_disb_int_rec.int_rebate_amt,
       x_force_disb        => cur_legacy_disb_int_rec.force_disb_flag,
       x_min_credit_pts    => cur_legacy_disb_int_rec.min_credit_pts_num,
       x_disb_exp_dt       => cur_legacy_disb_int_rec.disb_exp_date,
       x_verf_enfr_dt      => cur_legacy_disb_int_rec.verf_enfr_date,
       x_fee_class         => cur_legacy_disb_int_rec.fee_class_code,
       x_show_on_bill      => cur_legacy_disb_int_rec.planned_credit_flag,
       x_attendance_type_code => cur_legacy_disb_int_rec.attendance_type_code,
       x_base_attendance_type_code => cur_legacy_disb_int_rec.base_attendance_type_code,
       x_payment_prd_st_date     => NULL,
       x_change_type_code        => NULL,
       x_fund_return_mthd_code   => NULL,
       x_direct_to_borr_flag     => 'N'
     );

     IF(l_rowid IS NOT NULL)THEN
       l_disb_rec_ins_status := 'S';
     ELSE
       l_disb_rec_ins_status := 'E';
       RETURN;
     END IF;

  EXCEPTION WHEN OTHERS THEN
     IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_aw_li_import.create_disbursment_record.exception',SQLERRM);
     END IF;
    FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
    l_disb_rec_ins_status := 'E';
  END create_disbursment_record;

  BEGIN -- validate_disburs_int_rec

     p_return_status := 'S';
     l_padding_string := RPAD(' ',3,' ')||'-- ';
     -- open the cusrsor cur_legacy_disb_total and obtain the total values
     cur_legacy_disb_total_rec := NULL;
     OPEN cur_legacy_disb_total; FETCH cur_legacy_disb_total INTO cur_legacy_disb_total_rec; CLOSE cur_legacy_disb_total;
     g_processing_string := l_padding_string || igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PROCESSING') || ' '||
                           igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','DISBURSMNT');
     FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
     FND_FILE.PUT_LINE(FND_FILE.LOG,g_processing_string);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_li_import.validate_disburs_int_rec.debug','no of disb'|| cur_legacy_disb_total_rec.number_of_disb || 'max no = ' ||cur_legacy_disb_total_rec.max_disb_number);
      END IF;
     -- if total number of disbursement = 0 then error
     IF(cur_legacy_disb_total_rec.number_of_disb = 0)THEN
       p_return_status := 'E';
       FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DISB_NOT_PRSNT');
       FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
       RETURN;
     ELSIF(cur_legacy_disb_total_rec.max_disb_number > 99)THEN
       p_return_status := 'E';
       FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DISB_NUM_INVALID');
       FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
       RETURN;
     END IF;

     -- validate disbursement numbers for the award. the numbers must be sequential starting from 1
      l_ctr:=1;
      FOR cur_legacy_disb_int_rec IN cur_legacy_disb_int LOOP
         IF(l_ctr <> cur_legacy_disb_int_rec.disbursement_num) THEN
           p_return_status := 'E';
           FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DISB_NUM_ST_1_INR_1');
           FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
           RETURN;
         END IF;
         l_ctr:=l_ctr+1;
      END LOOP;

     -- sum of all offered amounts for all disb at the context awd = total offered amt.
     IF( (li_awd_rec.offered_amt IS NOT NULL AND cur_legacy_disb_total_rec.total_offered_amt IS NULL) OR
         (li_awd_rec.offered_amt IS NOT NULL AND li_awd_rec.offered_amt <> cur_legacy_disb_total_rec.total_offered_amt )
       ) THEN
       p_return_status := 'E';
       FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_SUM_OFRD_AMT_NOT_EQL');
       FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
       RETURN;
     END IF;


     -- If accepted amt is present at award and not present at disb then error
     -- sum of all accepted amounts for all dis at the context awd = total accepted amt
     IF( ( li_awd_rec.accepted_amt IS NOT NULL AND cur_legacy_disb_total_rec.total_accepted_amt IS NULL ) OR
         ( li_awd_rec.accepted_amt IS NOT NULL AND li_awd_rec.accepted_amt <> cur_legacy_disb_total_rec.total_accepted_amt)
       ) THEN
       p_return_status := 'E';
       FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_SUM_ACPT_AMT_NOT_EQL');
       FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
       RETURN;
     END IF;

     IF(g_fed_fund_code = 'SPNSR')THEN
       -- unique fee class validation for sponsorship awards
       c_uniq_fee_class_rec := NULL;
       OPEN c_uniq_fee_class; FETCH c_uniq_fee_class INTO c_uniq_fee_class_rec; CLOSE c_uniq_fee_class;
       IF(c_uniq_fee_class_rec.fee_class_code IS NOT NULL)THEN
         p_return_status := 'E';
         FND_MESSAGE.SET_NAME('IGF','IGF_SP_LI_DUP_FC_FND');
         FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
       END IF;
       -- Sponsorship Awards should be awarded under one Load Calendar for the given Award. Check if the Student has any
       -- sponsorhsips not in the same load calendar for a sponsorship Award in the disbursement interface.
       -- table. If the Student does have more than one LD then error out
       OPEN c_get_uniq_ld_code; FETCH c_get_uniq_ld_code INTO l_uniq_ld_code; CLOSE c_get_uniq_ld_code;
       IF(l_uniq_ld_code > 1)THEN
         p_return_status := 'E';
         FND_MESSAGE.SET_NAME('IGF','IGF_SP_LI_LD_CAL_NOT_SAME');
         FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
       END IF;
     END IF;

     IF g_fed_fund_code = 'FWS' THEN
       --check if the award has more than 1 disbursement per term
       --if yes, error OUT
       OPEN cur_legacy_disb_fws_total;
       FETCH cur_legacy_disb_fws_total INTO cur_legacy_disb_total_fws_rec;
       CLOSE cur_legacy_disb_fws_total;
       IF cur_legacy_disb_total_fws_rec.terms <> cur_legacy_disb_total_fws_rec.tp THEN
         p_return_status := 'E';
         FND_MESSAGE.SET_NAME('IGF','IGF_SE_MAX_TP_SETUP');
         FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
         RETURN;
       END IF;
     END IF;

     l_ctr := 0; -- this initialization is necessary for checking only one disb record for sponsorships
     FOR cur_legacy_disb_int_rec IN cur_legacy_disb_int LOOP
       l_ctr := l_ctr + 1;
       -- validate the term calendar
          g_processing_string := RPAD(' ',3,' ')||'-- '|| igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PROCESSING') || ' '||
                           igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','DISBURSEMENT_NUMBER');
       FND_FILE.PUT_LINE(FND_FILE.LOG,g_processing_string||': '||cur_legacy_disb_int_rec.disbursement_num);
       l_ret_val := igf_ap_gen.validate_cal_inst('LOAD',li_awd_rec.ci_alternate_code,
                                                 cur_legacy_disb_int_rec.ld_alternate_code,
                                                 l_var_cal_type,
                                                 l_var_seq_number);

       IF(FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level)THEN
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_aw_li_import.validate_disburs_int_rec.debug',
          'LOAD validation ci_alternate_code'||li_awd_rec.ci_alternate_code||'ld_alternate_code:'||
          cur_legacy_disb_int_rec.ld_alternate_code||'l_var_cal_type'||l_var_cal_type||'l_var_seq_number'||l_var_seq_number
          );
       END IF;

       IF(l_ret_val = FALSE AND l_var_cal_type IS NULL)THEN
         p_return_status := 'E';
         FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_TERM_NOT_FND');
         FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
       END IF;

       IF(l_ret_val = FALSE AND l_var_cal_type IS NOT NULL)THEN
         p_return_status := 'E';
         FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_TERM_NOT_CHLD_AWD_YR');
         FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
       END IF;

       -- error out if the award status is not accepted and accepted amount exists at the disbursement level
       IF ( li_awd_rec.award_status_code IN ('OFFERED','CANCELLED','DECLINED') AND
            cur_legacy_disb_int_rec.accepted_amt < 0
          )THEN
         p_return_status := 'E';
         FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_ACPT_AMT_NEG');
         FND_MESSAGE.SET_TOKEN('AWD_STATUS', li_awd_rec.award_status_code);
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
       END IF;

       -- for cancelled awards acpt amt should be zero or null
       IF ( li_awd_rec.award_status_code ='CANCELLED' AND
            ( cur_legacy_disb_int_rec.accepted_amt IS NULL OR cur_legacy_disb_int_rec.accepted_amt <> 0 )
          ) THEN
         p_return_status := 'E';
         FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DB_ACPT_AMT_AWD_CNCL');
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
       END IF;

       -- federal work study validations introduced in FACR117.
       IF(g_fed_fund_code = 'FWS')THEN
         -- Work Study Funds should not have Legacy Disbursement Activity Records
         c_get_dact_fws_rec := NULL;
         OPEN c_get_dact_fws(cur_legacy_disb_int_rec.disbursement_num); FETCH c_get_dact_fws INTO c_get_dact_fws_rec;
         CLOSE c_get_dact_fws;
         IF(c_get_dact_fws_rec.disb_activity_num IS NOT NULL)THEN
           p_return_status := 'E';
           FND_MESSAGE.SET_NAME('IGF','IGF_SE_LI_DISB_ADJ_PRSNT');
           FND_MESSAGE.SET_TOKEN('FUND',li_awd_rec.fund_code);
           FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
         END IF;
       END IF;

       -- sponsorship validations, introduced in FACR117 for sep 2003 release
       IF(g_fed_fund_code <> 'SPNSR')THEN
         -- fee class code should be null for non sponsorship awards. introduced in FACR117
         IF(cur_legacy_disb_int_rec.fee_class_code IS NOT NULL)THEN
           p_return_status := 'E';
           FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DISB_COL_BLNK');
           FND_MESSAGE.SET_TOKEN('COLUMN_NAME','FEE_CLASS_CODE');
           FND_MESSAGE.SET_TOKEN('FUND_CODE',li_awd_rec.fund_code);
           FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
         END IF;
       ELSIF(g_fed_fund_code = 'SPNSR')THEN
         -- When the sponsorship amount is present, only one disbursement record exist without any fee class code
         -- also for second disbursement onwards, fee class codes should be present.
         -- Secondly, when the spoosorship amount is not present, error if fee class code is blank.
         c_max_year_spnsr_rec := NULL; l_disb_rec_count := NULL;
         OPEN c_max_year_spnsr; FETCH c_max_year_spnsr INTO c_max_year_spnsr_rec; CLOSE c_max_year_spnsr;
         OPEN c_get_disb_count; FETCH c_get_disb_count INTO l_disb_rec_count; CLOSE c_get_disb_count;
         IF(c_max_year_spnsr_rec.max_yearly_amt IS NOT NULL AND cur_legacy_disb_int_rec.fee_class_code IS NULL AND l_disb_rec_count > 1)THEN
           p_return_status := 'E';
           FND_MESSAGE.SET_NAME('IGF','IGF_SP_LI_FC_NOT_PRSNT');
           FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
         ELSIF(c_max_year_spnsr_rec.max_yearly_amt IS NULL AND cur_legacy_disb_int_rec.fee_class_code IS NULL AND l_disb_rec_count >= 1)THEN
           p_return_status := 'E';
           FND_MESSAGE.SET_NAME('IGF','IGF_SP_LI_GT1_DB_FC_NULL');
           FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
         END IF;
         -- check if the fee class code is valid value for configured lookup. Test this only if the value is present in the
         -- fee class code. validation introduced in FACR117
         IF(cur_legacy_disb_int_rec.fee_class_code IS NOT NULL)THEN
           c_val_lookup_code_rec := NULL;
           OPEN c_val_lookup_code('FEE_CLASS',cur_legacy_disb_int_rec.fee_class_code); FETCH c_val_lookup_code INTO c_val_lookup_code_rec;
           CLOSE c_val_lookup_code;
           IF(c_val_lookup_code_rec.meaning IS NULL)THEN
             p_return_status := 'E';
             FND_MESSAGE.SET_NAME('IGF','IGF_AP_INV_FLD_VAL');
             FND_MESSAGE.SET_TOKEN('FIELD','FEE_CLASS_CODE');
             FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
           END IF;
         END IF;

         -- validate if the fee class is present in the sponsor definition. if not present then raise a warning
         c_get_sp_fee_class_rec := NULL;
         IF(cur_legacy_disb_int_rec.fee_class_code IS NOT NULL)THEN
           OPEN c_get_sp_fee_class(cur_legacy_disb_int_rec.fee_class_code); FETCH c_get_sp_fee_class INTO c_get_sp_fee_class_rec;
           CLOSE c_get_sp_fee_class;
           IF(c_get_sp_fee_class_rec.fee_cls_id IS NULL)THEN
             IF(p_return_status <> 'E')THEN
               p_return_status := 'W';
             END IF;
             FND_MESSAGE.SET_NAME('IGF','IGF_SP_LI_FC_NOT_CHILD');
             FND_MESSAGE.SET_TOKEN('FEE_CLASS',cur_legacy_disb_int_rec.fee_class_code);
             FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
           END IF;
         END IF;
       END IF;

       -- disbursement term matching validations for open award year only
       -- Do this validation only for SPNSR
       IF(g_award_year_status_code = 'O')THEN
         IF g_fed_fund_code = 'SPNSR' THEN
           c_match_disb_term_rec := NULL;
           OPEN c_match_disb_term(l_var_cal_type, l_var_seq_number); FETCH c_match_disb_term INTO c_match_disb_term_rec;
           CLOSE c_match_disb_term;
           IF(c_match_disb_term_rec.fund_id IS NULL) THEN
             IF(p_return_status <> 'E')THEN
               p_return_status := 'W';
             END IF;
             FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_TERM_DISTRIBUTION');
             FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
           END IF;
         END IF;

         -- validations as per review comments doc # 17 in the s1 version of the TD
         IF(g_fed_fund_code in ('DLP','FLP','GPLUSFL') AND cur_legacy_disb_total_rec.max_disb_number >  4) THEN
           p_return_status := 'E';
           FND_MESSAGE.SET_NAME('IGF','IGF_AW_PLUS_DISB');
           FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
         ELSIF(g_fed_fund_code in ('DLS','FLS','DLU','FLU') AND cur_legacy_disb_total_rec.max_disb_number > 20) THEN
           p_return_status := 'E';
           FND_MESSAGE.SET_NAME('IGF','IGF_AW_SUNS_DISB');
           FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
         ELSIF(g_fed_fund_code in ('PELL') AND cur_legacy_disb_total_rec.max_disb_number > 90) THEN
           p_return_status := 'E';
           FND_MESSAGE.SET_NAME('IGF','IGF_AW_PELL_DISB');
           FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
         END IF;
       END IF;

       -- validate transacation type. valid values are ACTUAL(A), PLANNED(P), CANCELLED(C)
       IF(igf_ap_gen.get_aw_lookup_meaning('IGF_DB_TRANS_TYPE',cur_legacy_disb_int_rec.trans_type_code,g_sys_award_year)IS NULL)THEN
         p_return_status := 'E';
         FND_MESSAGE.SET_NAME('IGF','IGF_AP_INV_FLD_VAL');
         FND_MESSAGE.SET_TOKEN('FIELD','TRANS_TYPE_CODE');
         FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
       END IF;
       --
       -- External Awards Import can import only Planned Disbursements
       --
       IF g_entry_point = 'EXTERNAL' AND g_fed_fund_code = 'EXT' AND cur_legacy_disb_int_rec.trans_type_code <> 'P' THEN
           p_return_status :='E';
           FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_TRANS_TYPE_FAIL');
           FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
       END IF;

       --
       -- Check if the Attendance Type Code is setup in OSS or not
       --
       IF cur_legacy_disb_int_rec.attendance_type_code IS NOT NULL THEN
          OPEN  cur_check_atd(cur_legacy_disb_int_rec.attendance_type_code);
          FETCH cur_check_atd INTO check_atd_rec;
          IF cur_check_atd%NOTFOUND THEN
            p_return_status :='E';
            FND_MESSAGE.SET_NAME('IGF','IGF_AP_INV_FLD_VAL');
            FND_MESSAGE.SET_TOKEN('FIELD','ATTENDANCE_TYPE_CODE');
            FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
          END IF;
          CLOSE cur_check_atd;
       END IF;

       IF (
           g_fed_fund_code = 'PELL' AND
           igf_ap_gen.get_aw_lookup_meaning('IGF_GR_RFMS_ENROL_STAT',cur_legacy_disb_int_rec.base_attendance_type_code,g_sys_award_year) IS NULL)
           OR (
           g_fed_fund_code <> 'PELL' AND
           cur_legacy_disb_int_rec.base_attendance_type_code IS NOT NULL
           )
           THEN
         p_return_status :='E';
         FND_MESSAGE.SET_NAME('IGF','IGF_AP_INV_FLD_VAL');
         fnd_message.set_token('FIELD','BASE_ATTENDANCE_TYPE_CODE');
         FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
       END IF;

       --
       -- Either Attendance Type Code, or Credit Points can be
       -- entered, not both
       --
       IF cur_legacy_disb_int_rec.attendance_type_code IS NOT NULL AND
          cur_legacy_disb_int_rec.min_credit_pts_num  IS NOT NULL THEN
          p_return_status :='E';
          FND_MESSAGE.SET_NAME('IGF','IGF_AW_CRP_ATT_FAIL');
          FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
       END IF;

       -- validate teaching calendar
       l_ret_val := FALSE; l_var_cal_type:=NULL; l_var_seq_number:=NULL;
       l_ret_val := igf_ap_gen.validate_cal_inst('TEACHING',cur_legacy_disb_int_rec.ld_alternate_code,
                                                      cur_legacy_disb_int_rec.tp_alternate_code,
                  l_var_cal_type,
                  l_var_seq_number);
       IF(l_ret_val = FALSE AND l_var_cal_type IS NULL)THEN
         p_return_status := 'E';
         FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_TEACH_CAL_NOT_FND');
         FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
       END IF;
       IF(l_ret_val = FALSE AND l_var_cal_type IS NULL)THEN
         p_return_status := 'E';
         FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_TEACH_NOT_CHLD_LOAD');
         FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
       END IF;

       -- validate offered amount. offered amount > 0 always
       IF(cur_legacy_disb_int_rec.offered_amt <= 0)THEN
         p_return_status := 'E';
         FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_OFRD_AMT_GT_0');
         FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
       END IF;

       -- validate eligibility status date. ELIG_STATUS_DATE < sysdate always
       IF(trunc(cur_legacy_disb_int_rec.elig_status_date) > trunc(sysdate))THEN
         p_return_status := 'E';
         FND_MESSAGE.SET_NAME('IGS','IGS_AD_DATE_SYSDATE');
         FND_MESSAGE.SET_TOKEN('NAME','ELIG_STATUS_DATE');
         FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
       END IF;

       IF(li_awd_rec.award_status_code = 'ACCEPTED')THEN
         -- accepted amount should be present at disb level if present at award level. if null
         -- at disb level, log error message and continue with validations
         IF(li_awd_rec.accepted_amt IS NOT NULL) THEN
           IF(cur_legacy_disb_int_rec.accepted_amt IS NULL) THEN
             p_return_status := 'E';
             FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_ACPT_REQ_AWD_ACPT');
             FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
             -- accepted amount should be > 0.
           ELSIF(cur_legacy_disb_int_rec.accepted_amt <= 0) THEN
             p_return_status := 'E';
             FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_ACPT_AMT_GT_0');
             FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
           END IF;
           IF(cur_legacy_disb_int_rec.trans_type_code = 'C' AND cur_legacy_disb_int_rec.accepted_amt <> 0) THEN
             p_return_status := 'E';
             FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_ACPT_AMT_EQ_0_TT_C');
             FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
           END IF;
         END IF;
       END IF; -- end award status is ACCEPTED

       -- Interest Rebate Amount and Affirmation Flag should be NULL for non Direct Loans
       IF(g_fed_fund_code NOT IN ('DLP','DLS','DLU'))THEN
         IF(cur_legacy_disb_int_rec.int_rebate_amt IS NOT NULL)THEN
           p_return_status := 'E';
           FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DISB_COL_BLNK');
           FND_MESSAGE.SET_TOKEN('COLUMN_NAME','INT_REBATE_AMT');
           FND_MESSAGE.SET_TOKEN('FUND_CODE',li_awd_rec.fund_code);
           FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
         END IF;
         IF(cur_legacy_disb_int_rec.affirm_flag IS NOT NULL)THEN
           p_return_status := 'E';
           FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DISB_COL_BLNK');
           FND_MESSAGE.SET_TOKEN('COLUMN_NAME','AFFIRM_FLAG');
           FND_MESSAGE.SET_TOKEN('FUND_CODE',li_awd_rec.fund_code);
           FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
         END IF;
       END IF;

       -- Origination Fee should be null for all loans except for Direct, FFELP and Alternative
       IF(g_fed_fund_code NOT IN ('DLP','DLS','DLU','FLS','FLP','FLU','ALT','GPLUSFL') AND cur_legacy_disb_int_rec.fee_1_amt IS NOT NULL)THEN
         p_return_status := 'E';
         FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DISB_COL_BLNK');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','FEE_1_AMT');
         FND_MESSAGE.SET_TOKEN('FUND_CODE',li_awd_rec.fund_code);
         FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
       END IF;

      -- validate if the Origination Fee is correct for Direct, FFELP and Alternative Loan
      IF(g_fed_fund_code IN ('DLP','DLS','DLU','FLS','FLP','FLU','ALT','GPLUSFL'))THEN
        IF(cur_legacy_disb_int_rec.fee_1_amt IS NOT NULL AND cur_legacy_disb_int_rec.fee_1_amt < 0)THEN
          p_return_status := 'E';
          FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DISB_COL_REQ');
          FND_MESSAGE.SET_TOKEN('COLUMN_NAME','FEE_1_AMT');
          FND_MESSAGE.SET_TOKEN('FUND_CODE',li_awd_rec.fund_code);
          FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
        END IF;
      END IF;

       -- Guarantee Fee, Guarantee Fee Paid, Origination Fee Paid should be null for non FFELP and Alternative Loans
       IF(g_fed_fund_code NOT IN('FLS','FLP','FLU','ALT','GPLUSFL'))THEN
         IF(cur_legacy_disb_int_rec.fee_2_amt IS NOT NULL)THEN
           p_return_status := 'E';
           FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DISB_COL_BLNK');
           FND_MESSAGE.SET_TOKEN('COLUMN_NAME','FEE_2_AMT');
           FND_MESSAGE.SET_TOKEN('FUND_CODE',li_awd_rec.fund_code);
           FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
         END IF;
         IF(cur_legacy_disb_int_rec.fee_paid_1_amt IS NOT NULL)THEN
           p_return_status := 'E';
           FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DISB_COL_BLNK');
           FND_MESSAGE.SET_TOKEN('COLUMN_NAME','FEE_PAID_1_AMT');
           FND_MESSAGE.SET_TOKEN('FUND_CODE',li_awd_rec.fund_code);
           FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
         END IF;
         IF(cur_legacy_disb_int_rec.fee_paid_2_amt IS NOT NULL)THEN
           p_return_status := 'E';
           FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DISB_COL_BLNK');
           FND_MESSAGE.SET_TOKEN('COLUMN_NAME','FEE_PAID_2_AMT');
           FND_MESSAGE.SET_TOKEN('FUND_CODE',li_awd_rec.fund_code);
           FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
         END IF;
       END IF;

       IF(g_fed_fund_code NOT IN('DLP','DLS','DLU') AND cur_legacy_disb_int_rec.affirm_flag IS NOT NULL)THEN
         p_return_status := 'E';
         FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DISB_COL_BLNK');
         FND_MESSAGE.SET_TOKEN('COLUMN_NAME','AFFIRM_FLAG');
         FND_MESSAGE.SET_TOKEN('FUND_CODE',li_awd_rec.fund_code);
         FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
       END IF;

       -- net amount is always the accepted amount for all the awards except for Direct Loans and Common Line Loans
       l_net_amount := NVL(cur_legacy_disb_int_rec.accepted_amt,0);
       -- perform direct loan validations

       IF(g_fed_fund_code IS NOT NULL AND g_fed_fund_code IN ('DLP','DLS','DLU'))THEN
         -- interest rebate amount is optional for Direct Loans. Validate if it is < 0

         IF(cur_legacy_disb_int_rec.int_rebate_amt IS NOT NULL AND cur_legacy_disb_int_rec.int_rebate_amt < 0)THEN
           p_return_status := 'E';
           FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DISB_COL_REQ');
           FND_MESSAGE.SET_TOKEN('COLUMN_NAME','INT_REBATE_AMT');
           FND_MESSAGE.SET_TOKEN('FUND_CODE',li_awd_rec.fund_code);
           FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
         END IF;
         IF(cur_legacy_disb_int_rec.affirm_flag IS NOT NULL AND cur_legacy_disb_int_rec.affirm_flag NOT IN('Y','N'))THEN
           p_return_status := 'E';
           FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_AFRM_FG_INVALID');
           FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
         END IF;

         -- compute l_net_amount here
         l_net_amount := NVL(cur_legacy_disb_int_rec.accepted_amt,0) -
                         NVL(cur_legacy_disb_int_rec.fee_1_amt,0) +
                         NVL(cur_legacy_disb_int_rec.int_rebate_amt,0);

       -- perform common line loan validations
       ELSIF(g_fed_fund_code IS NOT NULL AND g_fed_fund_code IN ('FLP','FLS','FLU','ALT','GPLUSFL')) THEN

         IF(cur_legacy_disb_int_rec.fee_paid_1_amt IS NOT NULL AND cur_legacy_disb_int_rec.fee_paid_1_amt < 0)THEN
           p_return_status := 'E';
           FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DISB_COL_REQ');
           FND_MESSAGE.SET_TOKEN('COLUMN_NAME','FEE_PAID_1_AMT');
           FND_MESSAGE.SET_TOKEN('FUND_CODE',li_awd_rec.fund_code);
           FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
         END IF;
         IF(cur_legacy_disb_int_rec.fee_2_amt IS NOT NULL AND cur_legacy_disb_int_rec.fee_2_amt < 0)THEN
           p_return_status := 'E';
           FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DISB_COL_REQ');
           FND_MESSAGE.SET_TOKEN('COLUMN_NAME','FEE_2_AMT');
           FND_MESSAGE.SET_TOKEN('FUND_CODE',li_awd_rec.fund_code);
           FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
         END IF;
         IF(cur_legacy_disb_int_rec.fee_paid_2_amt IS NOT NULL AND cur_legacy_disb_int_rec.fee_paid_2_amt < 0)THEN
           p_return_status := 'E';
           FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DISB_COL_REQ');
           FND_MESSAGE.SET_TOKEN('COLUMN_NAME','FEE_PAID_2_AMT');
           FND_MESSAGE.SET_TOKEN('FUND_CODE',li_awd_rec.fund_code);
           FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
         END IF;

         -- compute net amount for common line loans
         l_net_amount := NVL(cur_legacy_disb_int_rec.accepted_amt,0) -
                         NVL(cur_legacy_disb_int_rec.fee_1_amt,0) -
                         NVL(cur_legacy_disb_int_rec.fee_2_amt,0) +
                         NVL(cur_legacy_disb_int_rec.fee_paid_1_amt,0) +
                         NVL(cur_legacy_disb_int_rec.fee_paid_2_amt,0);
       END IF; -- end common line validations
       -- call to insert row of disb production table package. with the calculations of Net Amount for
       -- direct loans and common line loans
       -- call to insert disb record and further validations only if the return status is S or W

       IF(p_return_status = 'S' OR p_return_status = 'W')THEN
         SAVEPOINT st_def_ins_disb_records;

         create_disbursment_record(li_awd_rec,cur_legacy_disb_int_rec,l_disb_rec_ins_status);

         IF(l_disb_rec_ins_status = 'S' OR l_disb_rec_ins_status = 'W')THEN

           -- process disb holds records for context disb
           validate_disb_hold_int_rec(li_awd_rec,cur_legacy_disb_int_rec,l_return_status_dh);
           IF(l_return_status_dh = 'E')THEN
             ROLLBACK TO st_def_ins_disb_records;
             p_return_status := 'E';
             RETURN;
           END IF;
         ELSE
           ROLLBACK TO st_def_ins_disb_records;
           p_return_status := 'E';
           RETURN;
         END IF;
         -- process disb activity for context disb. process disb activity only if transaction type is ACTUAL or CANCELLED
         -- disbursement activity records are not processed for FWS funds.

         IF(cur_legacy_disb_int_rec.trans_type_code IN ('A','C') AND p_return_status <> 'E' AND g_fed_fund_code <> 'FWS') THEN
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_li_import.validate_disburs_int_rec.debug','calling validate_disb_act_int_rec');
           END IF;

           validate_disb_act_int_rec(li_awd_rec,cur_legacy_disb_int_rec,l_return_status_da);

           IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_li_import.validate_disburs_int_rec.debug','done validate_disb_act_int_rec');
            END IF;
           IF(l_return_status_da = 'E')THEN
             ROLLBACK TO st_def_ins_disb_records;
             p_return_status := 'E';
             RETURN;
           END IF;
         END IF;
       END IF;
     END LOOP;
   EXCEPTION WHEN OTHERS THEN
     p_return_status := 'E';
     IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                     'igf.plsql.igf_aw_li_import.validate_disburs_int_rec.exception',
                     SQLERRM);
     END IF;
     FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
     FND_MESSAGE.SET_TOKEN('NAME','VALIDATE_DISBURS_INT_REC : '||SQLERRM);
     FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
   END validate_disburs_int_rec;

  PROCEDURE validate_disb_act_int_rec(li_awd_rec igf_aw_li_awd_ints%ROWTYPE,
                                      li_awd_disb_rec igf_aw_li_disb_ints%ROWTYPE,
                                      p_return_status OUT NOCOPY VARCHAR2
                                     ) IS
/***************************************************************
   Created By   : nsidana
   Date Created By  : 11/28/2003
   Purpose    : Validates disbursements activity interface record.
   Known Limitations,Enhancements or Remarks
   Change History :
   Who      When          What
   pssahni  10/20/2004    The newly added fields  in the table IGF_AW_LI_DACT_INTS and  table IGF_DB_AWD_DISB_DTL.
                          (ORIG_FEE_AMT, GUARNT_FEE_AMT, ORIG_FEE_PAID_AMT, GUARNT_FEE_PAID_AMT, INT_REBATE_AMT)
                          are taken into account and data is inseted into IGF_AW_DB_CHG_DTLS table also
                          Validation is done to check that the last activity always reflect the current disbursement information.

 ***************************************************************/
    CURSOR cur_li_disb_act_int IS
    SELECT
      trim(disbact.ci_alternate_code) ci_alternate_code,
      trim(disbact.person_number) person_number,
      trim(disbact.award_number_txt) award_number_txt,
      disbact.disbursement_num,
      disbact.disb_activity_num,
      trim(disbact.disb_activity_type) disb_activity_type,
      disbact.disb_net_amt,
      disbact.disb_date,
      trim(disbact.sf_status_code) sf_status_code,
      disbact.sf_status_date,
      trim(disbact.sf_invoice_num_txt) sf_invoice_num_txt,
      trim(disbact.sf_credit_num_txt) sf_credit_num_txt,
      trim(disbact.disb_status_code) disb_status_code,
      disbact.notification_date,
      disbact.created_by,
      disbact.creation_date,
      disbact.last_updated_by,
      disbact.last_update_date,
      disbact.last_update_login,
      trim(disbact.spnsr_credit_num_txt) spnsr_credit_num_txt,
      trim(disbact.spnsr_charge_num_txt)  spnsr_charge_num_txt,
      trim(disbact.origination_fee_amt  ) origination_fee_amt  ,
      trim(disbact.guarntee_fee_amt  ) guarntee_fee_amt  ,
      trim(disbact.origination_fee_paid_amt  ) origination_fee_paid_amt  ,
      trim(disbact.guarntee_fee_paid_amt  ) guarntee_fee_paid_amt  ,
      trim(disbact.interest_rebate_amt  ) interest_rebate_amt  ,
      trim(disbact.disbursement_accepted_amt  ) disbursement_accepted_amt
    FROM igf_aw_li_dact_ints disbact
    WHERE ci_alternate_code = li_awd_disb_rec.ci_alternate_code
      AND person_number = li_awd_disb_rec.person_number
      AND award_number_txt = li_awd_disb_rec.award_number_txt
      AND disbursement_num = li_awd_disb_rec.disbursement_num
    ORDER BY disb_activity_num;

    -- Get the last activity sequence number
    CURSOR cur_get_max_disb IS
      SELECT MAX(disb_activity_num) last_activity
        FROM igf_aw_li_dact_ints
       WHERE ci_alternate_code = li_awd_disb_rec.ci_alternate_code
         AND person_number = li_awd_disb_rec.person_number
         AND award_number_txt = li_awd_disb_rec.award_number_txt
         AND disbursement_num = li_awd_disb_rec.disbursement_num;

    max_disb_num cur_get_max_disb%ROWTYPE;

    CURSOR cur_sf_credit_num (p_credit_num igf_aw_li_dact_ints.sf_credit_num_txt%TYPE) IS
    SELECT credit_number, amount, credit_id
    FROM igs_fi_credits
    WHERE party_id = g_person_id
      AND credit_number = p_credit_num;
    cur_sf_credit_num_rec cur_sf_credit_num%ROWTYPE;
    l_trans_credit_id igs_fi_credits_all.credit_id%TYPE;
    l_trans_spnsr_credit_id igs_fi_credits_all.credit_id%TYPE;

    CURSOR c_get_cal_typ_seq_num(p_alternate_code igs_ca_inst.alternate_code%TYPE) IS
    SELECT cal_type, sequence_number
    FROM igs_ca_inst
    WHERE alternate_code = p_alternate_code;

    r_get_cal_typ_seq_num   c_get_cal_typ_seq_num%ROWTYPE;


    CURSOR cur_sf_invoice_num(p_invoice_num igf_aw_li_dact_ints.sf_invoice_num_txt%TYPE) IS
    SELECT invoice_number, invoice_amount, invoice_id
    FROM igs_fi_inv_int
    WHERE person_id = g_person_id
      AND invoice_number = p_invoice_num;
    cur_sf_invoice_num_rec cur_sf_invoice_num%ROWTYPE;
    l_trans_invoice_id igs_fi_inv_int_all.invoice_id%TYPE;
    l_trans_spnsr_charge_id igs_fi_inv_int_all.invoice_id%TYPE;

    --l_disbact_rec igf_aw_li_dact_ints%ROWTYPE;
    l_disbact_rec cur_li_disb_act_int%ROWTYPE;
    l_ctr PLS_INTEGER;
    l_adjust_amt igf_aw_li_dact_ints.disb_net_amt%TYPE;
    l_last_disb_net_amt igf_aw_li_dact_ints.disb_net_amt%TYPE;
    l_return_status_da VARCHAR2(1);

    TYPE disb_net_amt_tab IS TABLE OF igf_aw_li_dact_ints.disb_net_amt%TYPE;
    disb_net_amt_table disb_net_amt_tab;

    TYPE disb_date_tab IS TABLE OF igf_aw_li_dact_ints.disb_date%TYPE;
    disb_date_table disb_date_tab;

    CURSOR c_get_all_disb_amt IS
    SELECT disbact.disb_net_amt, disbact.disb_date
    FROM igf_aw_li_dact_ints disbact
    WHERE ci_alternate_code = li_awd_disb_rec.ci_alternate_code
      AND person_number = li_awd_disb_rec.person_number
      AND award_number_txt = li_awd_disb_rec.award_number_txt
      AND disbursement_num = li_awd_disb_rec.disbursement_num
    ORDER BY disb_activity_num;


    -- Get the last disbursment sequence number activity
    CURSOR c_get_last_activity (p_disb_seq_num NUMBER)
    IS
      SELECT *
        FROM igf_aw_li_dact_ints
       WHERE ci_alternate_code = li_awd_disb_rec.ci_alternate_code
         AND person_number = li_awd_disb_rec.person_number
         AND award_number_txt = li_awd_disb_rec.award_number_txt
         AND disbursement_num = li_awd_disb_rec.disbursement_num
         AND disb_activity_num = p_disb_seq_num;

    last_activity_rec     c_get_last_activity%ROWTYPE;


    CURSOR cur_rowid ( p_award_id NUMBER, p_disb_num NUMBER, p_disb_seq_num NUMBER)
    IS
      SELECT ROWID row_id
        FROM igf_aw_db_chg_dtls
       WHERE award_id = p_award_id
         AND disb_num = p_disb_num
         AND disb_seq_num = p_disb_seq_num;
    lv_rowid cur_rowid%ROWTYPE;

    l_rowid VARCHAR2(25);
    l_padding_string VARCHAR2(100);


  BEGIN -- begin of validate_disb_act_int_rec
    p_return_status := 'S';
    disb_net_amt_table := NULL; disb_date_table := NULL;
    l_padding_string := RPAD(' ',6,' ')||'-- ';
    l_disbact_rec := NULL;

    OPEN cur_li_disb_act_int; FETCH cur_li_disb_act_int INTO l_disbact_rec;
    g_processing_string := l_padding_string || igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PROCESSING') || ' '||
                             igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','DISBURSEMENT_ACTIVITY');
    FND_FILE.PUT_LINE(FND_FILE.LOG,g_processing_string);
    -- if transaction type is Actual and disb records are not found.

    IF(cur_li_disb_act_int%NOTFOUND AND li_awd_disb_rec.trans_type_code = 'A')THEN
      CLOSE cur_li_disb_act_int;
      p_return_status := 'E';
      FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DACT_NOT_FND');
      FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
      RETURN;
    -- if transaction type is cancelled and disb activity records are not found
    ELSIF(cur_li_disb_act_int%NOTFOUND AND li_awd_disb_rec.trans_type_code = 'C') THEN
      CLOSE cur_li_disb_act_int;
      RETURN;
    END IF;

    IF cur_li_disb_act_int%ISOPEN THEN
      CLOSE cur_li_disb_act_int;
    END IF;

    --
    l_ctr:=1;
    FOR cur_li_disb_act_int_rec IN cur_li_disb_act_int LOOP
      IF(l_ctr <> cur_li_disb_act_int_rec.disb_activity_num) THEN
        p_return_status := 'E';
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DB_SEQ_ST_1_INR_1');
        FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
        RETURN;
      END IF;
      l_ctr := l_ctr +1;
    END LOOP;


    IF(disb_net_amt_table IS NULL OR disb_date_table IS NULL)THEN -- this condition makes this if execute only once per call

      -- fetch all the disb_net_amt into a PL/SQL Table. This is used in calculating the adjustment amount
      OPEN c_get_all_disb_amt;
      FETCH c_get_all_disb_amt BULK COLLECT INTO disb_net_amt_table,
                                                 disb_date_table;
      CLOSE c_get_all_disb_amt;


      -- accepted amt in disb should be = to disb act last seq num disb_net_amt. step 15 in TD validation for disb acts

      -- Find the last activity details
      OPEN cur_get_max_disb; FETCH cur_get_max_disb INTO max_disb_num ; CLOSE cur_get_max_disb;
      OPEN  c_get_last_activity (max_disb_num.last_activity);
      FETCH c_get_last_activity INTO last_activity_rec;
      CLOSE c_get_last_activity;


       IF(( NVL(li_awd_disb_rec.accepted_amt,-1) <> NVL(disb_net_amt_table(disb_net_amt_table.COUNT),-1))
         OR  (NVL(li_awd_disb_rec.fee_1_amt,-1) <> NVL(last_activity_rec.origination_fee_amt,-1) )
         OR  (NVL(li_awd_disb_rec.fee_2_amt,-1) <> NVL(last_activity_rec.guarntee_fee_amt,-1) )
         OR  (NVL(li_awd_disb_rec.fee_paid_1_amt,-1) <> NVL(last_activity_rec.origination_fee_paid_amt,-1)  )
         OR  (NVL(li_awd_disb_rec.fee_paid_2_amt,-1) <> NVL(last_activity_rec.guarntee_fee_paid_amt,-1)  )
         OR  (NVL(li_awd_disb_rec.int_rebate_amt,-1) <> NVL(last_activity_rec.interest_rebate_amt,-1)  )
        )THEN


        p_return_status := 'E';
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_ACPT_AMT_EQ_DISB_NET');
        FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
      END IF;
    END IF;

    -- l_ctr has a different meaning here. used in calculating the disb_net_amt
    l_ctr := 0;
    FOR cur_li_disb_act_int_rec IN cur_li_disb_act_int LOOP
      l_ctr := l_ctr +1;
      g_processing_string := l_padding_string || igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PROCESSING') || ' '||
                             igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','DISBURSEMENT_ACTIVITY');
      FND_FILE.PUT_LINE(FND_FILE.LOG,g_processing_string||': '||cur_li_disb_act_int_rec.disb_activity_num);
      l_trans_invoice_id := NULL; l_trans_credit_id := NULL; l_trans_spnsr_credit_id := NULL; l_trans_spnsr_charge_id := NULL;

      -- Disb Activity Table should not be processed for Disb Transaction Type is PLANNED
      IF(li_awd_disb_rec.trans_type_code = 'P' AND cur_li_disb_act_int_rec.person_number IS NOT NULL)THEN
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_NO_PRC_ACTIVITY');
        FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
        RETURN;
      END IF;

      -- sponsorship charge number and sponsorship activity number should be blank for non sponsorship awards
      -- introduced in FACR117
      IF(g_fed_fund_code <> 'SPNSR')THEN
        IF(cur_li_disb_act_int_rec.spnsr_credit_num_txt IS NOT NULL)THEN
          p_return_status := 'E';
          FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DISB_COL_BLNK');
          FND_MESSAGE.SET_TOKEN('COLUMN_NAME','SPNSR_CREDIT_NUM_TXT');
          FND_MESSAGE.SET_TOKEN('FUND_CODE',li_awd_rec.fund_code);
          FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
        END IF;
        IF(cur_li_disb_act_int_rec.spnsr_charge_num_txt IS NOT NULL)THEN
          p_return_status := 'E';
          FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DISB_COL_BLNK');
          FND_MESSAGE.SET_TOKEN('COLUMN_NAME','SPNSR_CHARGE_NUM_TXT');
          FND_MESSAGE.SET_TOKEN('FUND_CODE',li_awd_rec.fund_code);
          FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
        END IF;
      ELSIF(g_fed_fund_code = 'SPNSR')THEN
        IF(cur_li_disb_act_int_rec.sf_status_code IS NOT NULL AND cur_li_disb_act_int_rec.sf_status_code = 'P')THEN
          -- for posted transactions either both invoice number and sponsor credit number should be not null or both should be null.
          -- in any other cases, log an error
          IF ((cur_li_disb_act_int_rec.sf_invoice_num_txt IS NULL AND cur_li_disb_act_int_rec.spnsr_credit_num_txt IS NOT NULL) OR
              (cur_li_disb_act_int_rec.sf_invoice_num_txt IS NOT NULL AND cur_li_disb_act_int_rec.spnsr_credit_num_txt IS NULL))THEN
            p_return_status := 'E';
            FND_MESSAGE.SET_NAME('IGF','IGF_SP_LI_INVN_SPCRN_REQ');
            FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
          END IF;
          IF ((cur_li_disb_act_int_rec.sf_credit_num_txt IS NULL AND cur_li_disb_act_int_rec.spnsr_charge_num_txt IS NOT NULL) OR
              (cur_li_disb_act_int_rec.sf_credit_num_txt IS NOT NULL AND cur_li_disb_act_int_rec.spnsr_charge_num_txt IS NULL)) THEN
            p_return_status := 'E';
            FND_MESSAGE.SET_NAME('IGF','IGF_SP_LI_CRN_SPINVN_REQ');
            FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
          END IF;
        END IF;
      END IF;

      -- These validations are necessary only from second Disb Act records
      IF(l_ctr > 1)THEN
        -- adjustment amount is calculated here.
        l_adjust_amt := disb_net_amt_table(l_ctr) - disb_net_amt_table(l_ctr-1);
        -- disb dates should be in ascending order
        IF(disb_date_table(l_ctr) < disb_date_table(l_ctr-1))THEN
          p_return_status := 'E';
          FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_ADJ_DB_DT_INVALID');
          FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
        END IF;
      ELSIF(l_ctr = 1)THEN
        l_adjust_amt := 0;
      END IF;

      -- disbursement date cannot be greater than sysdate
      IF(disb_date_table(l_ctr) > trunc(SYSDATE))THEN
        p_return_status := 'E';
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_ADJ_DB_DT_GT_SYSDATE');
        FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
      END IF;

      -- both sf_invoice_num_txt and sf_credit_num_txt should not be present at the disb activity level. error if such case
      IF(cur_li_disb_act_int_rec.sf_invoice_num_txt IS NOT NULL AND cur_li_disb_act_int_rec.sf_credit_num_txt IS NOT NULL)THEN
        p_return_status := 'E';
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_CRINV_BOTH_PRSNT');
        FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
      END IF;

      -- if either the invoice num txt or the credit_num_txt is present then sf_status_code is mandatory
      IF(cur_li_disb_act_int_rec.sf_invoice_num_txt IS NOT NULL OR cur_li_disb_act_int_rec.sf_credit_num_txt IS NOT NULL) THEN
        IF(cur_li_disb_act_int_rec.sf_status_code IS NULL)THEN
          p_return_status := 'E';
          FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_SF_STATUS_BLNK');
          FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
        END IF;
      END IF;

      -- Validate SF status code values
      IF(cur_li_disb_act_int_rec.sf_status_code IS NOT NULL AND cur_li_disb_act_int_rec.sf_status_code NOT IN ('P','R'))THEN
        p_return_status := 'E';
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_SF_STATUS_INVALID');
        FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
      END IF;

      -- first disb activity cannot have invoice number
      IF(cur_li_disb_act_int_rec.sf_invoice_num_txt IS NOT NULL AND l_ctr = 1)THEN
        p_return_status := 'E';
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_INV_NUM_FIRST_DBIB');
        FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
      END IF;

      -- credit number validation for posted transactions only. valid for open and legacy details award years
      IF(cur_li_disb_act_int_rec.sf_credit_num_txt IS NOT NULL AND cur_li_disb_act_int_rec.sf_status_code = 'P')THEN
        -- Fetch the credit number from the igs_fi_credits table
        cur_sf_credit_num_rec := NULL;
        OPEN cur_sf_credit_num(cur_li_disb_act_int_rec.sf_credit_num_txt); FETCH cur_sf_credit_num INTO cur_sf_credit_num_rec;
        CLOSE cur_sf_credit_num;
        l_trans_credit_id := cur_sf_credit_num_rec.credit_id;
        IF(FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level)THEN
          g_debug_string := 'SF Credit Num'||cur_sf_credit_num_rec.credit_number||'credit id'||l_trans_credit_id;
        END IF;
        IF(cur_sf_credit_num_rec.credit_number IS NULL)THEN
          p_return_status := 'E';
          FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_CR_NUM_NOT_FND');
          FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
        END IF;
        -- credit amount validations for open award year only. the credit amount should match with the adjusted amount
        IF(g_award_year_status_code = 'O' AND cur_sf_credit_num_rec.amount IS NOT NULL)THEN
          IF((cur_sf_credit_num_rec.amount <> ABS(l_adjust_amt) AND l_ctr <> 1) OR
            (l_ctr=1 AND cur_sf_credit_num_rec.amount <> cur_li_disb_act_int_rec.disb_net_amt))THEN
            p_return_status := 'E';
            FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_CR_AMT_NOT_MTCH');
            FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
          END IF;
        END IF;
      END IF;

      -- invoice number validation for posted transactions only. valid for open and legacy details award years
      IF(cur_li_disb_act_int_rec.sf_invoice_num_txt IS NOT NULL AND cur_li_disb_act_int_rec.sf_status_code = 'P')THEN
        cur_sf_invoice_num_rec := NULL;
        OPEN cur_sf_invoice_num(cur_li_disb_act_int_rec.sf_invoice_num_txt); FETCH cur_sf_invoice_num INTO cur_sf_invoice_num_rec;
        CLOSE cur_sf_invoice_num;
        l_trans_invoice_id := cur_sf_invoice_num_rec.invoice_id;
        IF(FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level)THEN
          g_debug_string := g_debug_string ||'SF Invoice Num'||cur_sf_invoice_num_rec.invoice_number||'invoice id'||l_trans_invoice_id;
        END IF;
        IF(cur_sf_invoice_num_rec.invoice_number IS NULL)THEN
          p_return_status := 'E';
          FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_INV_NUM_NOT_FND');
          FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
        END IF;
        -- invoice amount validations for open award year only. the invoice amount should match with the adjusted amount
        IF(g_award_year_status_code = 'O' AND cur_sf_invoice_num_rec.invoice_amount IS NOT NULL AND l_ctr <> 1)THEN
          IF(cur_sf_invoice_num_rec.invoice_amount <> ABS(l_adjust_amt))THEN
            p_return_status := 'E';
            FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_INV_AMT_NOT_MTCH');
            FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
          END IF;
        END IF;
      END IF;

      -- sponsor credit number validations for posted transactions only. applicable for open as well as legacy details award years
      IF(cur_li_disb_act_int_rec.spnsr_credit_num_txt IS NOT NULL AND cur_li_disb_act_int_rec.sf_status_code = 'P')THEN
        --Fetch the Sponsorship Credit number from the igs_fi_credits_table
        cur_sf_credit_num_rec := NULL;
        OPEN cur_sf_credit_num(cur_li_disb_act_int_rec.spnsr_credit_num_txt); FETCH cur_sf_credit_num INTO cur_sf_credit_num_rec;
        CLOSE cur_sf_credit_num;
        l_trans_spnsr_credit_id := cur_sf_credit_num_rec.credit_id;
        IF(FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level)THEN
          g_debug_string := 'SF sponsor credit num'||cur_sf_credit_num_rec.credit_number||'credit id is'||l_trans_spnsr_credit_id;
        END IF;
        IF(cur_sf_credit_num_rec.credit_number IS NULL)THEN
          p_return_status := 'E';
          FND_MESSAGE.SET_NAME('IGF','IGF_SP_LI_SPNSR_CRNUM_NOT_FND');
          FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
        END IF;
        -- credit amount validations for open award year only. the credit amount should match with the adjusted amount
        IF(g_award_year_status_code = 'O' AND cur_sf_credit_num_rec.amount IS NOT NULL)THEN
          IF((cur_sf_credit_num_rec.amount <> ABS(l_adjust_amt) AND l_ctr <> 1) OR
            (l_ctr=1 AND cur_sf_credit_num_rec.amount <> cur_li_disb_act_int_rec.disb_net_amt))THEN
            p_return_status := 'E';
            FND_MESSAGE.SET_NAME('IGF','IGF_SP_LI_CR_AMT_NOT_MTCH');
            FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
          END IF;
        END IF;
      END IF;

      -- sponsor charge number validation for posted transactions only. valid for open and legacy details award years
      IF(cur_li_disb_act_int_rec.spnsr_charge_num_txt IS NOT NULL AND cur_li_disb_act_int_rec.sf_status_code = 'P')THEN
        cur_sf_invoice_num_rec := NULL;
        OPEN cur_sf_invoice_num(cur_li_disb_act_int_rec.spnsr_charge_num_txt); FETCH cur_sf_invoice_num INTO cur_sf_invoice_num_rec;
        CLOSE cur_sf_invoice_num;
        l_trans_spnsr_charge_id := cur_sf_invoice_num_rec.invoice_id;
        IF(FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level)THEN
          g_debug_string := g_debug_string ||'SF sponsor charge Num'||cur_sf_invoice_num_rec.invoice_number||'charge id'||l_trans_spnsr_charge_id;
        END IF;
        IF(cur_sf_invoice_num_rec.invoice_number IS NULL)THEN
          p_return_status := 'E';
          FND_MESSAGE.SET_NAME('IGF','IGF_SP_LI_SPNSR_INNUM_NOT_FND');
          FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
        END IF;
        -- sponsor charge amount validations for open award year only. the invoice amount should match with the adjusted amount
        IF(g_award_year_status_code = 'O' AND cur_sf_invoice_num_rec.invoice_amount IS NOT NULL AND l_ctr <> 1)THEN
          IF(cur_sf_invoice_num_rec.invoice_amount <> ABS(l_adjust_amt))THEN
            p_return_status := 'E';
            FND_MESSAGE.SET_NAME('IGF','IGF_SP_LI_INV_AMT_NOT_MTCH');
            FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
          END IF;
        END IF;
      END IF;

      -- student finance status date
      IF(NVL(cur_li_disb_act_int_rec.sf_status_code,'X') = 'P' OR
         cur_li_disb_act_int_rec.sf_invoice_num_txt IS NOT NULL OR
         cur_li_disb_act_int_rec.sf_credit_num_txt IS NOT NULL)THEN
        IF(cur_li_disb_act_int_rec.sf_status_date IS NULL)THEN
          p_return_status := 'E';
          FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_SF_STATUS_DT_BLNK');
          FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
        END IF;
      END IF;

      IF(cur_li_disb_act_int_rec.sf_status_code IS NOT NULL AND cur_li_disb_act_int_rec.sf_status_code = 'R')THEN
        -- validation introduced in FACR117. when the sf_status is ready to send, the by products of the posting
        -- should be null. viz. the status date, invioce num, credit num, spnsr credit num, spnsr invoice num
        IF(cur_li_disb_act_int_rec.sf_status_date IS NOT NULL OR cur_li_disb_act_int_rec.sf_credit_num_txt IS NOT NULL OR
           cur_li_disb_act_int_rec.sf_invoice_num_txt IS NOT NULL OR cur_li_disb_act_int_rec.spnsr_credit_num_txt IS NOT NULL OR
           cur_li_disb_act_int_rec.spnsr_charge_num_txt IS NOT NULL)THEN
          p_return_status := 'E';
          FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_SF_STATUS_DT_NTREQ');
          FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
        END IF;
      END IF;

      IF((l_adjust_amt < 0 AND cur_li_disb_act_int_rec.sf_credit_num_txt IS NOT NULL) OR
         (l_adjust_amt >= 0 AND cur_li_disb_act_int_rec.sf_invoice_num_txt IS NOT NULL)
        ) THEN
        p_return_status := 'E';
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_INC_CR_INV_NUM');
        FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
      END IF;

      -- validate disbursement status and disbursement ctivity.
      IF(g_fed_fund_code IN ('DLP','DLS','DLU'))THEN

        IF(cur_li_disb_act_int_rec.disb_status_code IS NULL)THEN
          p_return_status := 'E';
          FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_INV_DISB_ACT');
          FND_MESSAGE.SET_TOKEN('FUND',li_awd_rec.fund_code);
          FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
        ELSIF(cur_li_disb_act_int_rec.disb_status_code NOT IN ('A','B','G','R'))THEN
          p_return_status := 'E';
          FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DISB_ACT_UPD');
          FND_MESSAGE.SET_TOKEN('COL_NAME', 'DISB_STATUS_CODE');
          FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
        END IF;

        IF cur_li_disb_act_int_rec.disb_activity_type IS NULL THEN
           p_return_status := 'E';
           FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_INVLD_ACTVTY_CD');
           FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
        ELSE
          IF(cur_li_disb_act_int_rec.disb_activity_type NOT IN ('D','A','Q'))THEN
            p_return_status := 'E';
            FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DISB_ACT_UPD');
            FND_MESSAGE.SET_TOKEN('COL_NAME','DISB_ACTIVITY_TYPE');
            FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
          END IF;
        -- the first disbact record should have the disbact type as D always
           IF(l_ctr = 1 AND cur_li_disb_act_int_rec.disb_activity_type <> 'D')THEN
            p_return_status := 'E';
            FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_DISB_FIRST_ACT');
            FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
           END IF;
        END IF;


      ELSE
        -- disbursement status and activity should be null for non Direct Loans
        IF(cur_li_disb_act_int_rec.disb_status_code IS NOT NULL)THEN
          p_return_status := 'E';
          FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_ACT_COL_BLNK');
          FND_MESSAGE.SET_TOKEN('COLUMN_NAME','DISB_STATUS_CODE');
          FND_MESSAGE.SET_TOKEN('FUND_CODE',li_awd_rec.fund_code);
          FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
        END IF;
        IF(cur_li_disb_act_int_rec.disb_activity_type IS NOT NULL)THEN
          p_return_status := 'E';
          FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_ACT_COL_BLNK');
          FND_MESSAGE.SET_TOKEN('COLUMN_NAME','DISB_ACTIVITY_TYPE');
          FND_MESSAGE.SET_TOKEN('FUND_CODE',li_awd_rec.fund_code);
          FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
        END IF;
      END IF;

      -- Disbusement Accepted amount is a mandatory amount
      IF cur_li_disb_act_int_rec.disbursement_accepted_amt IS NULL THEN
          p_return_status := 'E';
          FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_ACPT_AMT_BLNK');
          FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string || FND_MESSAGE.GET);
      END IF;


      -- insert row only if all the validations are successful
      -- check for cal of l_adjust_amt

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_li_import.validate_disb_act_int_rec.debug','inserting into igf_db_awd_disb_dtl table');
    END IF;

      IF p_return_status <> 'E' THEN
        l_rowid := NULL;

	OPEN c_get_cal_typ_seq_num(li_awd_disb_rec.ld_alternate_code);
	FETCH c_get_cal_typ_seq_num INTO r_get_cal_typ_seq_num;
	CLOSE c_get_cal_typ_seq_num;

        igf_db_awd_disb_dtl_pkg.insert_row (
           x_rowid             => l_rowid,
           x_award_id          => g_award_id,
           x_disb_num          => li_awd_disb_rec.disbursement_num,
           x_disb_seq_num      => cur_li_disb_act_int_rec.disb_activity_num,
           x_disb_gross_amt    => cur_li_disb_act_int_rec.disbursement_accepted_amt,
           x_fee_1             => cur_li_disb_act_int_rec.origination_fee_amt ,
           x_fee_2             => cur_li_disb_act_int_rec.guarntee_fee_amt ,
           x_disb_net_amt      => cur_li_disb_act_int_rec.disb_net_amt,
           x_disb_adj_amt      => l_adjust_amt  ,
           x_disb_date         => cur_li_disb_act_int_rec.disb_date,
           x_fee_paid_1        => cur_li_disb_act_int_rec.origination_fee_paid_amt,
           x_fee_paid_2        => cur_li_disb_act_int_rec.guarntee_fee_paid_amt ,
           x_disb_activity     => cur_li_disb_act_int_rec.disb_activity_type,
           x_disb_batch_id     => NULL,
           x_disb_ack_date     => NULL,
           x_booking_batch_id  => NULL,
           x_booked_date       => NULL,
           x_disb_status       => cur_li_disb_act_int_rec.disb_status_code,
           x_disb_status_date  => NULL,
           x_sf_status         => cur_li_disb_act_int_rec.sf_status_code,
           x_sf_status_date    => cur_li_disb_act_int_rec.sf_status_date,
           x_sf_invoice_num    => l_trans_invoice_id, -- dont get confused by the col name. this is invoice id only
           x_spnsr_credit_id  => l_trans_spnsr_credit_id,
           x_spnsr_charge_id  => l_trans_spnsr_charge_id,
           x_sf_credit_id     => l_trans_credit_id,
           x_error_desc        => NULL,
           x_mode              => 'R',
           x_notification_date => cur_li_disb_act_int_rec.notification_date,
           x_interest_rebate_amt => cur_li_disb_act_int_rec.interest_rebate_amt,
	   x_ld_cal_type        => r_get_cal_typ_seq_num.cal_type,
	   x_ld_sequence_number => r_get_cal_typ_seq_num.sequence_number
         );


        IF(l_rowid IS NULL)THEN
          p_return_status := 'E';
          RETURN;
        END IF;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_li_import.validate_disb_act_int_rec.debug','inserting into igf_aw_db_chg_dtls table');
        END IF;
        -- insert into IGF_AW_DB_CHG_DTLS table also

        -- First delete the record in the table if present
        OPEN cur_rowid (g_award_id, li_awd_disb_rec.disbursement_num, cur_li_disb_act_int_rec.disb_activity_num);
        FETCH cur_rowid INTO lv_rowid;

        IF cur_rowid%FOUND THEN
          CLOSE cur_rowid;
          igf_aw_db_chg_dtls_pkg.delete_row(lv_rowid.row_id);
        ELSE
          CLOSE cur_rowid;
        END IF;


        l_rowid := NULL;
        igf_aw_db_chg_dtls_pkg.insert_row (
            x_rowid             => l_rowid,
            x_award_id          => g_award_id,
            x_disb_num          => li_awd_disb_rec.disbursement_num,
            x_disb_seq_num      => cur_li_disb_act_int_rec.disb_activity_num,
            x_disb_accepted_amt => cur_li_disb_act_int_rec.disbursement_accepted_amt,
            x_orig_fee_amt      => cur_li_disb_act_int_rec.origination_fee_amt,
            x_disb_net_amt      => cur_li_disb_act_int_rec.disb_net_amt,
            x_disb_date         => cur_li_disb_act_int_rec.disb_date,
            x_disb_activity     => cur_li_disb_act_int_rec.disb_activity_type,
            x_disb_status       => cur_li_disb_act_int_rec.disb_status_code,
            x_disb_status_date  => NULL,
            x_disb_rel_flag     => NULL,
            x_first_disb_flag   => NULL,
            x_interest_rebate_amt       => cur_li_disb_act_int_rec.interest_rebate_amt ,
            x_disb_conf_flag    => NULL,
            x_pymnt_prd_start_date => NULL,
            x_note_message       => NULL,
            x_batch_id_txt       => NULL,
            x_ack_date           => NULL,
            x_booking_id_txt     => NULL,
            x_booking_date       => NULL,
            x_mode               => 'R'

         );

        IF(l_rowid IS NULL)THEN
          p_return_status := 'E';
          RETURN;
        END IF;


      END IF;  -- End if of p_return_status <> 'E'

      IF(FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level)THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_aw_li_import.validate_disb_act_int_rec.debug',g_debug_string);
        g_debug_string := NULL;
      END IF;
    END LOOP;

  EXCEPTION WHEN OTHERS THEN
    p_return_status := 'E';
    IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                     'igf.plsql.igf_aw_li_import.validate_disb_act_int_rec.exception',
                     SQLERRM);
    END IF;
    FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','VALIDATE_DISB_ACT_INT_REC : '||SQLERRM);
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
  END validate_disb_act_int_rec;

  PROCEDURE validate_disb_hold_int_rec(li_awd_rec igf_aw_li_awd_ints%ROWTYPE,
                                       li_awd_disb_rec igf_aw_li_disb_ints%ROWTYPE,
               p_return_status OUT NOCOPY VARCHAR2
                                      ) IS
/***************************************************************
   Created By   : nsidana
   Date Created By  : 11/28/2003
   Purpose    : Validates disbursements holds interface record.
   Known Limitations,Enhancements or Remarks
   Change History :
   Who      When          What
 ***************************************************************/
    CURSOR cur_li_disb_hold_int IS
    SELECT
      trim(disbhold.ci_alternate_code) ci_alternate_code,
      trim(disbhold.person_number) person_number,
      trim(disbhold.award_number_txt) award_number_txt,
      disbhold.disbursement_num,
      trim(disbhold.hold_code) hold_code,
      disbhold.hold_date,
      disbhold.release_date,
      trim(disbhold.release_reason_txt) release_reason_txt,
      disbhold.created_by,
      disbhold.creation_date,
      disbhold.last_updated_by,
      disbhold.last_update_date,
      disbhold.last_update_login
    FROM igf_aw_li_hold_ints disbhold
    WHERE ci_alternate_code = li_awd_disb_rec.ci_alternate_code
      AND person_number = li_awd_disb_rec.person_number
      AND award_number_txt = li_awd_disb_rec.award_number_txt
      AND disbursement_num = li_awd_disb_rec.disbursement_num;

    x_release_flag igf_db_disb_holds_all.release_flag%TYPE;
    l_rowid VARCHAR2(25);
    l_hold_id igf_db_disb_holds_All.hold_id%TYPE;
    l_release_flag igf_db_disb_holds_all.release_flag%TYPE;

    l_padding_string VARCHAR2(100);

  BEGIN
    p_return_status := 'S';
    l_padding_string := RPAD(' ',6,' ')||'-- ';
    g_processing_string := l_padding_string || igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PROCESSING') || ' '||
                           igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','DISBURSEMENT_HOLD');
    FOR cur_li_disb_hold_int_rec IN cur_li_disb_hold_int LOOP
      FND_FILE.PUT_LINE(FND_FILE.LOG,g_processing_string||': '||cur_li_disb_hold_int_rec.hold_code);
      -- validate hold code
      -- should be one of 'CL','DL','DL_PROM','ENROLMENT','MISC','OVERAWARD','PELL' unless some are removed for certain award years
      IF(igf_ap_gen.get_aw_lookup_meaning('IGF_DB_DISB_HOLDS',cur_li_disb_hold_int_rec.hold_code, g_sys_award_year)IS NULL)THEN
        p_return_status := 'E';
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_INVAL_HOLD_CODE');
        FND_MESSAGE.SET_TOKEN('HOCDE',cur_li_disb_hold_int_rec.hold_code);
        FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string ||FND_MESSAGE.GET);
        RETURN;
      END IF;
      IF(cur_li_disb_hold_int_rec.release_date IS NOT NULL AND cur_li_disb_hold_int_rec.hold_date IS NOT NULL)THEN
        IF(trunc(cur_li_disb_hold_int_rec.release_date) < trunc(cur_li_disb_hold_int_rec.hold_date))THEN
          FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_INVAL_REL_DATE');
          FND_FILE.PUT_LINE(FND_FILE.LOG,l_padding_string ||FND_MESSAGE.GET);
          RETURN;
        END IF;
      END IF;
      IF(cur_li_disb_hold_int_rec.release_date IS NULL)THEN
        x_release_flag := 'N';
      ELSE
        x_release_flag := 'Y';
      END IF;
      IF(cur_li_disb_hold_int_rec.release_date IS NULL)THEN
        l_release_flag := 'N';
      ELSE
        l_release_flag := 'Y';
      END IF;
      l_rowid := NULL;l_hold_id:=NULL;
      igf_db_disb_holds_pkg.insert_row(
        x_rowid         => l_rowid,
        x_hold_id       => l_hold_id,
        x_award_id      => g_award_id,
        x_disb_num      => li_awd_disb_rec.disbursement_num,
        x_hold          => cur_li_disb_hold_int_rec.hold_code,
        x_hold_date     => cur_li_disb_hold_int_rec.hold_date,
        x_hold_type     => 'SYSTEM',
        x_release_date  => cur_li_disb_hold_int_rec.release_date,
        x_release_flag  => l_release_flag,
        x_release_reason=> cur_li_disb_hold_int_rec.release_reason_txt
        );
      IF(l_hold_id IS NULL)THEN
        p_return_status := 'E';
        RETURN;
      END IF;
    END LOOP;
  EXCEPTION WHEN OTHERS THEN
    p_return_status := 'E';
    IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                     'igf.plsql.igf_aw_li_import.validate_disb_hold_int_rec.exception',
                     SQLERRM);
    END IF;
    FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','VALIDATE_DISB_HOLD_INT_REC : '||SQLERRM);
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
  END validate_disb_hold_int_rec;


  PROCEDURE main(errbuf            OUT NOCOPY  VARCHAR2,
                 retcode           OUT NOCOPY  NUMBER,
                 p_award_year      IN VARCHAR2,
                 p_batch_number    IN NUMBER,
                 p_delete_flag     IN VARCHAR2
          ) IS

/***************************************************************
   Created By   : nsidana
   Date Created By  : 11/28/2003
   Purpose    : Main procedure for the legacy awards and disbursements import process.
   Known Limitations,Enhancements or Remarks
   Change History :
	   Who      When          What
   ||  tsailaja		  13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
 ***************************************************************/
    l_cal_type igs_ca_inst.cal_type%TYPE;
    l_seq_number igs_ca_inst.sequence_number%TYPE;

    l_var_cal_type igs_ca_inst.cal_type%TYPE;
    l_var_seq_number igs_ca_inst.sequence_number%TYPE;
    l_ret_value               BOOLEAN;

    l_success_records         PLS_INTEGER;
    l_warning_records         PLS_INTEGER;
    l_rejected_records        PLS_INTEGER;
    l_total_records           PLS_INTEGER;
    lv_profile_value          VARCHAR2(30);
    lv_base_id                igf_ap_fa_base_rec_all.base_id%TYPE;


    -- cursor to get the calendar alternate code
    CURSOR cur_alt_code  ( x_ci_cal_type         igs_ca_inst.cal_type%TYPE,
                           x_ci_sequence_number  igs_ca_inst.sequence_number%TYPE) IS
    SELECT cal.alternate_code
    FROM igs_ca_inst cal
    WHERE cal.cal_type = x_ci_cal_type
      AND cal.sequence_number =  x_ci_sequence_number;
    l_alternate_code igs_ca_inst.alternate_code%TYPE;

    -- cursor to verify if the cal_type and seq_number are present in the system award year
    CURSOR cur_in_award_year_form(x_ci_cal_type         igs_ca_inst.cal_type%TYPE,
                                  x_ci_sequence_number  igs_ca_inst.sequence_number%TYPE) IS
    SELECT award_year_status_code, sys_award_year
    FROM igf_ap_batch_aw_map
    WHERE ci_cal_type = x_ci_cal_type
      AND ci_sequence_number = x_ci_sequence_number;
    l_award_year_status_code igf_ap_batch_aw_map_all.award_year_status_code%TYPE;
    l_sys_award_year igf_ap_batch_aw_map_all.sys_award_year%TYPE;
    l_return_status_awd VARCHAR2(1);

    PROCEDURE del_or_upd_int_records(p_operation IN VARCHAR2,
                                 ctx_li_awd_rec IN igf_aw_li_awd_ints%ROWTYPE,
         p_status IN VARCHAR2) IS
    BEGIN

      IF(p_operation = 'U')THEN
        UPDATE igf_aw_li_awd_ints
        SET import_status_type = p_status,
            last_updated_by        = fnd_global.user_id,
            last_update_date       = SYSDATE,
            last_update_login      = fnd_global.login_id,
            request_id             = fnd_global.conc_request_id,
            program_id             = fnd_global.conc_program_id,
            program_application_id = fnd_global.prog_appl_id,
            program_update_date    = SYSDATE
        WHERE ci_alternate_code = ctx_li_awd_rec.ci_alternate_code
        AND person_number = ctx_li_awd_rec.person_number
        AND award_number_txt = ctx_li_awd_rec.award_number_txt
        AND import_status_type = ctx_li_awd_rec.import_status_type;
      ELSIF(p_operation = 'D') THEN
        DELETE FROM igf_aw_li_dact_ints
        WHERE ci_alternate_code = ctx_li_awd_rec.ci_alternate_code
          AND person_number = ctx_li_awd_rec.person_number
          AND award_number_txt = ctx_li_awd_rec.award_number_txt;

        DELETE FROM igf_aw_li_hold_ints
        WHERE ci_alternate_code = ctx_li_awd_rec.ci_alternate_code
          AND person_number = ctx_li_awd_rec.person_number
          AND award_number_txt = ctx_li_awd_rec.award_number_txt;

        DELETE FROM igf_aw_li_disb_ints
        WHERE ci_alternate_code = ctx_li_awd_rec.ci_alternate_code
          AND person_number = ctx_li_awd_rec.person_number
          AND award_number_txt = ctx_li_awd_rec.award_number_txt;

        DELETE FROM igf_aw_li_awd_ints
        WHERE ci_alternate_code = ctx_li_awd_rec.ci_alternate_code
          AND person_number = ctx_li_awd_rec.person_number
          AND award_number_txt = ctx_li_awd_rec.award_number_txt
          AND import_status_type = ctx_li_awd_rec.import_status_type;
      END IF;
    EXCEPTION WHEN OTHERS THEN
      IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,
                 'igf.plsql.igf_aw_li_import.del_or_upd_int_records.exception',
                 'Unhandled Exception'||SQLERRM);
      END IF;
      FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','DEL_OR_UPD_INT_RECORDS : '||SQLERRM );
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    END del_or_upd_int_records;


  BEGIN
    igf_aw_gen.set_org_id(NULL);

    -- begin of procedure main
    -- Obtain cal_type and sequence number from the Parameter p_award_year
    g_debug_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_cal_type            := TRIM(SUBSTR(p_award_year,1,10));
    l_seq_number          := TO_NUMBER(SUBSTR(p_award_year,11));

    IF(FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level)THEN
      g_debug_string := 'REQUEST ID: '||fnd_global.conc_request_id;
    END IF;

    -- copy the values into global variables for further processing
    g_ci_cal_type := l_cal_type; g_ci_sequence_number := l_seq_number;

    -- <1> validate if the school is configured for us financial aid functionallity
    IF(igf_ap_gen.check_profile = 'N') THEN
      FND_MESSAGE.SET_NAME('IGF','IGF_AP_LGCY_PROC_NOT_RUN');
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      retcode := 2;
      RETURN;
    END IF;

    -- obtain the alternate code corresponding to the passed cal_type and seq_number
    OPEN cur_alt_code(l_cal_type,l_seq_number); FETCH cur_alt_code INTO l_alternate_code;CLOSE cur_alt_code;

    -- Record the parameters in the log
    FND_FILE.PUT_LINE(FND_FILE.LOG,igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PARAMETER_PASS'));
    FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','AWARD_YEAR'),25) || ' : '|| l_alternate_code);
    FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','BATCH_NUMBER'),25) || ' : '|| p_batch_number);
    FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','DELETE_FLAG'),25) || ' : '||
      igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_delete_flag));
    FND_FILE.PUT_LINE(fnd_file.log,RPAD('-',55,'-'));

    l_var_cal_type := l_cal_type;
    l_var_seq_number := l_seq_number;
    l_ret_value := igf_ap_gen.validate_cal_inst('AWARD',l_alternate_code,NULL,l_var_cal_type,l_var_seq_number);

    -- <2> validate the existence of award year in the calendar system
    -- sjalasut, is this validation required ?
    IF(l_ret_value = FALSE AND l_var_cal_type IS NULL AND l_var_seq_number IS NULL) THEN
      FND_MESSAGE.SET_NAME('IGF','IGF_AP_AWD_YR_NOT_FOUND');
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      retcode := 2;
      RETURN;
    END IF;

    --  <3> validate if the award year entered has been setup in the system award year form
    --  and the status if found is either open or legacy details
    OPEN cur_in_award_year_form(l_cal_type,l_seq_number); FETCH cur_in_award_year_form INTO l_award_year_status_code, l_sys_award_year;
    IF(cur_in_award_year_form%NOTFOUND)THEN
      CLOSE cur_in_award_year_form;
      FND_MESSAGE.SET_NAME('IGF','IGF_AP_AWD_YR_NOT_FOUND');
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      retcode := 2;
      RETURN;
    ELSE -- award year is present in the sys award year form. check for validity
      CLOSE cur_in_award_year_form;
      -- copy the award year status code and sys award year values into global variables.for further processing.
      g_award_year_status_code := l_award_year_status_code; g_sys_award_year := l_sys_award_year;
      IF(FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level)THEN
        g_debug_string := g_debug_string || 'Award year status code '||g_award_year_status_code||'Sys Award Year'||g_sys_award_year;
      END IF;
      IF(l_award_year_status_code NOT IN ('O','LD')) THEN
        FND_MESSAGE.SET_NAME('IGF','IGF_AP_LG_INVALID_STAT');
        FND_MESSAGE.SET_TOKEN('AWARD_STATUS',l_award_year_status_code);
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        retcode := 2;
        RETURN;
      END IF;
    END IF;

    -- award year status code that is printed before starting the transaction
    FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','AWARD_YR_STATUS'),25)|| ' : '||
      igf_ap_gen.get_lookup_meaning('IGF_AWARD_YEAR_STATUS',g_award_year_status_code));

    FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD('-',55,'-'));

    -- final minute validation on batch number. if the config changes and the interface tables are not updated then error
    IF(igf_ap_gen.check_batch(p_batch_number,'AWD') = 'N')THEN
      FND_MESSAGE.SET_NAME('IGF','IGF_GR_BATCH_DOES_NOT_EXIST');
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      RETURN;
    END IF;

    --To check whether the profile value is set to a value of 'When student is awarded' or not
    fnd_profile.get('IGF_AW_LOCK_COA',lv_profile_value);

    lv_base_id  :=  NULL;
    g_print_msg :=  NULL;

    -- <4> now that the initial setup validations are passed, process each record of the interface table.
    l_success_records :=0; l_warning_records :=0; l_rejected_records:=0;
    FOR cur_legacy_award_int_rec IN cur_legacy_award_int(l_alternate_code, trim(p_batch_number)) LOOP
      IF g_print_msg IS NOT NULL AND lv_base_id<>l_out_base_id THEN
        fnd_file.put_line(fnd_file.log,g_print_msg);
        g_print_msg := NULL;
      END IF;
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');

      l_out_person_id := NULL; l_out_base_id := NULL; g_award_id := NULL;
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
      FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD('-',40,'-'));
      FND_FILE.PUT_LINE(FND_FILE.LOG,igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PROCESSING')||' '||
                        igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','PERSON_NUMBER')||' '||cur_legacy_award_int_rec.person_number);
      FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD('-',40,'-'));
      igf_ap_gen.check_person(cur_legacy_award_int_rec.person_number,
                              l_cal_type,
                              l_seq_number,
                              l_out_person_id,
                              l_out_base_id
                             );

      -- person id is null. update the interface record with status E
      IF(l_out_person_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_PERSON_NOT_FND');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        l_rejected_records := l_rejected_records + 1;
        del_or_upd_int_records('U',cur_legacy_award_int_rec,'E');
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_SKIPPING_AWD');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      ELSE
        g_person_id := l_out_person_id;
      END IF;

      -- base id is null but the person id is not null. error out updating the interface record with status E
      IF(l_out_base_id IS NULL AND l_out_person_id IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('IGF','IGF_AP_FABASE_NOT_FOUND');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        l_rejected_records := l_rejected_records + 1;
        del_or_upd_int_records('U',cur_legacy_award_int_rec,'E');
        FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_SKIPPING_AWD');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      ELSIF(l_out_base_id IS NOT NULL AND l_out_person_id IS NOT NULL)THEN -- here both person id and base id are found
        -- write to the log and clear the string so that it can be used for other procedures being called.
        IF(FND_LOG.LEVEL_STATEMENT >= g_debug_runtime_level)THEN
          g_debug_string := g_debug_string || 'Base Id'||l_out_base_id||'Person Id'||l_out_person_id;
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_aw_li_import.main.debug',g_debug_string);
          g_debug_string := NULL;
        END IF;
        -- call to validate award year interface record. this is the main fork. control goes around the
        -- world before comming back here.

        validate_awdyear_int_rec(cur_legacy_award_int_rec, l_return_status_awd);

        -- do some action based on the l_return_status_awd here.
        IF(l_return_status_awd IN ('S','W'))THEN
          FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_IMP_SUCCESS');
          FND_MESSAGE.SET_TOKEN('AWARD_ID',g_award_id);
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        END IF;
        -- The Records did not error out so if delete flag is set, delete interface records
        IF(l_return_status_awd <> 'E' AND p_delete_flag ='Y')THEN
          del_or_upd_int_records('D',cur_legacy_award_int_rec,NULL); -- NULL here does not matter as the op is delete
        END IF;
        IF(l_return_status_awd = 'S') THEN
          l_success_records := l_success_records + 1;
          -- processing of award and its child records is successful. but the delete flag is not set
          IF(p_delete_flag = 'N')THEN
            del_or_upd_int_records('U',cur_legacy_award_int_rec,'I');
          END IF;
        ELSIF(l_return_status_awd = 'W')THEN
          l_warning_records := l_warning_records + 1;
          IF(p_delete_flag = 'N')THEN
            del_or_upd_int_records('U',cur_legacy_award_int_rec,'W');
          END IF;
        ELSIF(l_return_status_awd NOT IN ('S','W')) THEN
          l_rejected_records := l_rejected_records + 1;
          del_or_upd_int_records('U',cur_legacy_award_int_rec,'E');
          FND_MESSAGE.SET_NAME('IGF','IGF_AW_LI_SKIPPING_AWD');
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        END IF;

        -- IF lv_profile_value = 'AWARDED' lock COA at the student level
        IF lv_profile_value = 'AWARDED' THEN
            IF (l_return_status_awd = 'S') OR (l_return_status_awd = 'W') THEN
              lock_std_coa(l_out_base_id);
              lv_base_id := l_out_base_id;
            END IF;
        END IF;

      END IF; -- end if of if(l_out_base_id is null AND l_out_person_id IS NOT NULL)
      COMMIT;
    END LOOP;

    -- print message if it is locked at the student level
    IF g_print_msg IS NOT NULL THEN
      fnd_file.put_line(fnd_file.log,g_print_msg);
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    l_total_records := l_success_records + l_warning_records + l_rejected_records;
    -- if no records are available, then write no records to be processed in the log file and write the
    -- summary in the output file. else write the summary in both log and output files.
    IF(l_total_records = 0)THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_FI_NO_RECORD_AVAILABLE');
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      -- write the summary into the out files.
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-',55,'-'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_PROCESSED'),40)||' : '||l_total_records);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_SUCCESSFUL'),40)||' : '||l_success_records);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_WARN'),40)||' : '||l_warning_records);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_REJECTED'),40)||' : '||l_rejected_records);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-',55,'-'));
    ELSE
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
      FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_PROCESSED'),40)||' : '||l_total_records);
      FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_SUCCESSFUL'),40)||' : '||l_success_records);
      FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_WARN'),40)||' : '||l_warning_records);
      FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_REJECTED'),40)||' : '||l_rejected_records);
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');

      -- write the summary into the out files.
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-',55,'-'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_PROCESSED'),40)||' : '||l_total_records);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_SUCCESSFUL'),40)||' : '||l_success_records);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_WARN'),40)||' : '||l_warning_records);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','RECORDS_REJECTED'),40)||' : '||l_rejected_records);
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-',55,'-'));
    END IF;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
      FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_aw_li_import.main.exception',
           g_debug_string );
      FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_aw_li_import.main.exception',
           'Unhandled Exception '||SQLERRM );
    END IF;
    FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','MAIN : '||SQLERRM);
    IGS_GE_MSG_STACK.ADD;
    retcode := 2;
    errbuf:= FND_MESSAGE.GET;
    FND_FILE.PUT_LINE(fnd_file.log,errbuf);
    IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
  END main;

  -------------------------------------------------------------------------------------------------------
  -- Generic Functions
  -------------------------------------------------------------------------------------------------------
  FUNCTION get_base_id_from_per_num (p_person_number hz_parties.party_number%TYPE,
             p_cal_type igs_ca_inst.cal_type%TYPE,
             p_sequence_number igs_ca_inst.sequence_number%TYPE
            ) RETURN NUMBER IS
    CURSOR cur_base_id IS
    SELECT base.base_id
    FROM igf_ap_fa_base_rec_all base,
         hz_parties hp
    WHERE
          base.ci_sequence_number = p_sequence_number
      AND base.ci_cal_type = p_cal_type
      AND base.person_id = hp.party_id
      AND hp.party_number = p_person_number;

    l_base_id igf_ap_fa_base_rec_all.base_id%TYPE;

  BEGIN
    IF(p_person_number IS NOT NULL AND p_cal_type IS NOT NULL AND p_sequence_number IS NOT NULL)THEN
      OPEN cur_base_id; FETCH cur_base_id INTO l_base_id; CLOSE cur_base_id;
      IF l_base_id IS NOT NULL THEN
        RETURN l_base_id;
      ELSE
        RETURN -1;
      END IF;
    END IF;
  END get_base_id_from_per_num ;

  PROCEDURE run( errbuf            OUT NOCOPY  VARCHAR2,
                 retcode           OUT NOCOPY  NUMBER,
                 p_award_year      IN VARCHAR2,
                 p_batch_number    IN NUMBER,
                 p_delete_flag     IN VARCHAR2
            )
  IS
/***************************************************************
   Created By   : nsidana
   Date Created By  : 11/28/2003
   Purpose    :
   Known Limitations,Enhancements or Remarks
   Change History :
   Who				When          What

 ***************************************************************/

     lv_errbuf    VARCHAR2(4000);
     ln_retcode   NUMBER;
  BEGIN
    errbuf         := NULL;
    retcode        := 0;

    --
    -- Assign global variable
    --
    g_entry_point  := 'EXTERNAL';

    --
    --Invoke the main routine
    --
    main(lv_errbuf,
         ln_retcode,
         p_award_year,
         p_batch_number,
         p_delete_flag);

  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    IF(FND_LOG.LEVEL_EXCEPTION >= g_debug_runtime_level)THEN
      FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_aw_li_import.run.exception',
           g_debug_string );
      FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'igf.plsql.igf_aw_li_import.run.exception',
           'Unhandled Exception '||SQLERRM );
    END IF;
    FND_MESSAGE.SET_NAME('IGF','IGF_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','RUN : '||SQLERRM);
    IGS_GE_MSG_STACK.ADD;
    retcode := 2;
    errbuf:= FND_MESSAGE.GET;
    FND_FILE.PUT_LINE(fnd_file.log,errbuf);
    IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

  END run;

END igf_aw_li_import;

/
