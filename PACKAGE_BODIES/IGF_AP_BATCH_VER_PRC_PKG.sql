--------------------------------------------------------
--  DDL for Package Body IGF_AP_BATCH_VER_PRC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_BATCH_VER_PRC_PKG" AS
/* $Header: IGFAP08B.pls 120.3 2006/03/07 23:25:33 veramach ship $ */

 /*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: IGF_AP_BATCH_VER_PRC_PKG                |
 |                                                                       |
 | NOTES                                                                 |
 |       This process does the auto verification for student records     |
 | The Verification Request Process generates the request for documents  |
 | from the student. This process will take all the info submited by the |
 | student and see if the information present in ISIR matches with the   |
 | info presented by the student.                                        |
 |                                                                       |
 |                                                                       |
 | HISTORY                                                               |
 |                                                                       |
 | who        when         what
 | svuppala    14-OCt-04   Bug # 3416936 Modified TBH call to addeded field |
 |                         Eligible for Additional Unsubsidized Loans    |
 |                               |
 | veramach   28-Jan-2004  Bug # 3405556 Obsoleted ins_verification_number.Added dhs_verification_num_txt
 | bkkumar    15-Dec-2003  Bug# 3240804 Removed the code to update the   |
 |                         fed_verif_Status to CORRSENT                  |
 | bkkumar    10-Dec-2003  Bug# 3240804 Added update_fed_verif_status procedure
 |                                                                       |
 | brajendr   17-NOV-2003  FA 128 - ISIR update 2004-05                  |
 |                         Corrected the issue for creating correction ISIR
 |                                                                       |
 | rasahoo    17-NOV-2003  FA 128 - ISIR update 2004-05                  |
 |                         added parameter award_fmly_contribution_type  |
 |                         to TBH call igf_ap_fa_base_rec_pkg            |
 |                         Added TBH impact of igf_ap_isir_matched       |
 |                                                                       |
 | cdcruz     26-SEP-2003  FA 121 - Verification Worksheet.              |
 |                         Changes per the TD have been incoporated      |
 |                         EFC Computation is added while creating       |
 |                         correction records                            |
 | ugummall   26-SEP-2003  FA 126 - Multiple FA Offices.                 |
 |                         added new parameter assoc_org_num to TBH call |
 |                         igf_ap_fa_base_rec_pkg.update_row w.r.t. FA126|
 |                                                                       |
 | bkkumar    27-Aug-2003  Bug# 3071157 Added explicit date format mask  |
 |                         to the to_date() function.                    |
 | gmuralid   10-03-2003   BUG# 2829487 .In procedure update process     |
 |                         status, inactive flag check in cursor cur_todo|
 |                         was modified.                                 |
 |                                                                       |
 | brajendr   03-Mar-2003  Bug # 2822497                                 |
 |                         Added the validations for Current SSN when    |
 |                         Pell Origination is Alread Sent               |
 |                                                                       |
 | rasingh    4-Feb-2003   Build FACR105 EFC Enhancements.               |
 |                         Correction ISIR updated with the values of    |
 |                         correction items. If correction ISIR not      |
 |                         present, then it is created.                  |
 |                                                                       |
 | rasingh 25-Nov-02 Build:2613576 FACR107/FA113/FA103 Related Build.    |
 |                   All Verification Status Removed except: Accurate and|
 |                   Correction Sent                                     |
 |                                                                       |
 | Bug 2637505 - DEV LINE Fix of Bugs on MNT Line.                       |
 | Please look in the bug for details of the fix.                        |
 | update_fa_status - pv_verification_status passed to                   |
 | update of igf_ap_fa_base_rec.                                         |
 | l_chk_dup_corr - Another cursor added to check if any record is already
 | present with the new correction status evaluated.                     |
 | main: Logic to derive verification status modified.                   |
 | Bug 2606001,2613546                                                   |
 | sjadhav    Oct.28.2002                                                |
 | Added l_pell_mat to igf_gr_pell.pell_calc routine                     |
 | Added x_pell_alt_expense   in igf_ap_fa_base_rec_pkg                  |
 | Modified get_gr_ver_code to read mapping from igf_aw_int_ext_map table|
 |-----------------------------------------------------------------------|
 |   12-Jun-2002  Bug ID: 2402371/ 2403886.                              |
 |The initialization of cursor variable dbms_sql.open_cursor removed from|
 |declaration section and moved to main body as it was failing when more |
 |cursor was required to be open more than once.                         |
 |EXECUTE IMMEDIATE Directly used instead of DBMS_SQL                    |
 | Bug ID  : 1818617                                                     |
 | who                 when            what                              |
 |-----------------------------------------------------------------------
 | bkkumar             02-July-2003    Bug 3004841                       |
 |                                     Modified function l_chk_dup_corr  |
 | rasahoo             11-June-2003    bug# 2858504 added parameter      |
 | x_legacy_record_flag to insert row                                    |
 | cdcruz              03-mar-2003     Bug # 2824774. Active ISIR not getting set |
 | smvk                11-feb-2003     Bug # 2758812. Modified procedure |
 |                                     get_gr_ver_code.                  |
 | rasingh             27-Sept-2002    Build 2590748 To Do Enhancements  |
 | sjadhav             24-jul-2001     added parameter p_get_recent_info |
 | rasingh             9-May-2002      Verification Status 'CALCULATED' added.
 | Logic added to compare the aid based on Pell Matix.                       |
 | 15-May-01 Rakesh Bug ID: 1776927 and 1776735 :                        |
 | Changes: There was an error in the way in which the count was passes  |
 | thru the loop. This was fixed.                                        |
 | 15-May01 Rakesh  Bug ID: 1779453                                      |
 | Changes: Base_id and Award Year added to the input parameter list.    |
 | 03-July-01 kkillams  Bug ID: 17794114                                 |
 | Changes: Creation of correction records based on group tolerance      |
 | amount and updation of wavie flag                                     |
 |-----------------------------------------------------------------------|
 |-----------------------------------------------------------------------|
 | 24-Oct-2001 skoppula BugID :2061146
 | Process of creating correction records is changed.If a correction
 | exists is "NotReady" status for an ISIR against a SAR field then the
 | corrected value is updated.Else if records exist in other states a
 | correction record with "NotReady" status is created                    |
 |                                                                       |
 | gvarapra   14-sep-2004   FA138 - ISIR Enhancements                    |
 |                          Added arguments in call to                   |
 |                          IGF_AP_ISIR_MATCHED_PKG.                     |
 |                          Added arguments in call to                   |
 |                          IGF_AP_FA_BASE_RECORD_PKG.                     |
 *=======================================================================*/

l_new_corr_status    igf_ap_isir_corr.correction_status%TYPE;
ln_corr_count        NUMBER;
ln_no_corr_count     NUMBER;
ln_tot_no_corr_count NUMBER;
ln_tot_corr_count    NUMBER;
g_disb_hold          VARCHAR2(1);

  FUNCTION l_chk_dup_corr(
                          pn_isir_id NUMBER,
                          pn_sar_field_number NUMBER,
                          pn_corrected_value VARCHAR2,
                          pv_status OUT NOCOPY VARCHAR2
                         )
  RETURN BOOLEAN IS

    -- bkkumar  02-07-2003  Bug 3004841 Here the check incorporated is that if the corrected
    -- value is the same as already present in the record with status "batched" then do not create the
    -- record again in the "pending" status.

    CURSOR cur_dup_rec (pn_isir_id NUMBER, pn_sar_field_number NUMBER) IS
    SELECT NVL(correction_status,'NOTREADY') correction_status,
           corrected_value
      FROM igf_ap_isir_corr
     WHERE isir_id = pn_isir_id
       AND sar_field_number = pn_sar_field_number;

    l_cur_dup_rec  cur_dup_rec%ROWTYPE;

    CURSOR cur_find_corr (pn_isir_id NUMBER, pn_sar_field_number NUMBER, pv_status VARCHAR2) IS
    SELECT count(*)
      FROM igf_ap_isir_corr
     WHERE isir_id = pn_isir_id
       AND sar_field_number = pn_sar_field_number
       AND correction_status = pv_status;

    l_corr_status   igf_ap_isir_corr.correction_status%TYPE := NULL;
    l_insert        BOOLEAN := FALSE;
    l_exists_flag   BOOLEAN := FALSE; -- this flag is set if the corrected value is same as the already present value.
    l_count         NUMBER;

  BEGIN

    /*
    This function will check if there is already correction present which has not been batched. If yes then the correction
    record is updated instead  of creating a new correction record.
    Also, if the correction is present with status 'BATCHED', then new corrections are created with status 'PENDING'
    */
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.l_chk_dup_corr.debug','opening cursor with cur_dup_rec > pn_isir_id/pn_sar_field_number'||pn_isir_id ||'/'||pn_sar_field_number);
    END IF;

    OPEN cur_dup_rec (pn_isir_id ,pn_sar_field_number);
    LOOP

      FETCH  cur_dup_rec INTO l_cur_dup_rec;
      l_corr_status := l_cur_dup_rec.correction_status;

      IF cur_dup_rec%NOTFOUND THEN
        IF l_corr_status IS NULL THEN
          l_new_corr_status := 'READY' ;
          l_insert := TRUE;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.l_chk_dup_corr.debug','New Correction status is READY');
          END IF;
        END IF;
        EXIT;
      END IF;

      IF l_corr_status IN ( 'NOTREADY', 'READY','PENDING','HOLD') THEN
        l_insert := FALSE;
        l_new_corr_status  := l_corr_status;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.l_chk_dup_corr.debug','New Correction status is '||l_corr_status);
        END IF;

      ELSIF l_corr_status = 'BATCHED' THEN
        IF l_cur_dup_rec.corrected_value = pn_corrected_value THEN
          l_exists_flag := TRUE;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.l_chk_dup_corr.debug','value is the same as already present in the record with status batched');
          END IF;

        ELSE
          l_new_corr_status  := 'PENDING';
          l_insert:= TRUE;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.l_chk_dup_corr.debug','value is not same as already present in the record with status batched and now status changed to pending ');
          END IF;
        END IF;
      END IF;

    END LOOP;
    CLOSE cur_dup_rec;

    IF l_exists_flag THEN
      pv_status := '';
      RETURN FALSE;
    END IF;

    OPEN cur_find_corr ( pn_isir_id ,pn_sar_field_number, l_new_corr_status);
    FETCH cur_find_corr INTO l_count;

    IF NOT l_insert AND l_count = 1 THEN
      pv_status := 'UPDATE';
      RETURN TRUE;
    ELSIF l_insert AND l_count = 0 THEN
      pv_status := 'INSERT';
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
    CLOSE cur_find_corr;

  EXCEPTION
    WHEN OTHERS THEN
      CLOSE cur_dup_rec;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_BATCH_VER_PRC.L_CHK_DUP_CORR '||SQLERRM);
      igs_ge_msg_stack.add;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.l_chk_dup_corr.debug',SQLERRM);
      END IF;
      RETURN FALSE;
  END l_chk_dup_corr;


  PROCEDURE l_update_base_rec(
                              pn_base_id           igf_ap_fa_base_rec_all.base_id%TYPE,
                              pv_status            igf_ap_fa_base_rec_all.fed_verif_status%TYPE ,
                              pv_tol               NUMBER,
                              pv_fa_process_status igf_ap_fa_base_rec_all.fa_process_status%TYPE
                             ) IS

    CURSOR cur_fa_base (pn_base_id NUMBER) IS
    SELECT fbr.*
      FROM igf_ap_fa_base_rec fbr
     WHERE base_id = pn_base_id FOR UPDATE NOWAIT;

  BEGIN

      FOR cur_fbr_rec IN cur_fa_base (pn_base_id) LOOP

        -- Update necessary fields in FA_Base_Record table.
        igf_ap_fa_base_rec_pkg.update_row (
                                        x_Mode                              => 'R',
                                        x_rowid                             => cur_fbr_rec.row_id,
                                        x_base_id                           => cur_fbr_rec.base_id,
                                        x_ci_cal_type                       => cur_fbr_rec.ci_cal_type,
                                        x_person_id                         => cur_fbr_rec.person_id,
                                        x_ci_sequence_number                => cur_fbr_rec.ci_sequence_number,
                                        x_org_id                            => cur_fbr_rec.org_id,
                                        x_coa_pending                       => cur_fbr_rec.coa_pending,
                                        x_verification_process_run          => cur_fbr_rec.verification_process_run,
                                        x_inst_verif_status_date            => cur_fbr_rec.inst_verif_status_date,
                                        x_manual_verif_flag                 => cur_fbr_rec.manual_verif_flag,
                                        x_fed_verif_status                  => NVL(pv_status,cur_fbr_rec.fed_verif_status),
                                        x_fed_verif_status_date             => TRUNC(SYSDATE),
                                        x_inst_verif_status                 => cur_fbr_rec.inst_verif_status,
                                        x_nslds_eligible                    => cur_fbr_rec.nslds_eligible,
                                        x_ede_correction_batch_id           => cur_fbr_rec.ede_correction_batch_id,
                                        x_fa_process_status_date            => TRUNC(SYSDATE) ,
                                        x_isir_corr_status                  => cur_fbr_rec.isir_corr_status,
                                        x_isir_corr_status_date             => cur_fbr_rec.isir_corr_status_date,
                                        x_isir_status                       => cur_fbr_rec.isir_status,
                                        x_isir_status_date                  => cur_fbr_rec.isir_status_date,
                                        x_coa_code_f                        => cur_fbr_rec.coa_code_f,
                                        x_coa_code_i                        => cur_fbr_rec.coa_code_i,
                                        x_coa_f                             => cur_fbr_rec.coa_f,
                                        x_coa_i                             => cur_fbr_rec.coa_i,
                                        x_disbursement_hold                 => cur_fbr_rec.disbursement_hold,
                                        x_fa_process_status                 => NVL(pv_fa_process_status,cur_fbr_rec.fa_process_status),
                                        x_notification_status               => cur_fbr_rec.notification_status,
                                        x_notification_status_date          => cur_fbr_rec.notification_status_date,
                                        x_packaging_status                  => cur_fbr_rec.packaging_status,
                                        x_packaging_status_date             => cur_fbr_rec.packaging_status_date,
                                        x_total_package_accepted            => cur_fbr_rec.total_package_accepted,
                                        x_total_package_offered             => cur_fbr_rec.total_package_offered,
                                        x_admstruct_id                      => cur_fbr_rec.admstruct_id,
                                        x_admsegment_1                      => cur_fbr_rec.admsegment_1,
                                        x_admsegment_2                      => cur_fbr_rec.admsegment_2,
                                        x_admsegment_3                      => cur_fbr_rec.admsegment_3,
                                        x_admsegment_4                      => cur_fbr_rec.admsegment_4,
                                        x_admsegment_5                      => cur_fbr_rec.admsegment_5,
                                        x_admsegment_6                      => cur_fbr_rec.admsegment_6,
                                        x_admsegment_7                      => cur_fbr_rec.admsegment_7,
                                        x_admsegment_8                      => cur_fbr_rec.admsegment_8,
                                        x_admsegment_9                      => cur_fbr_rec.admsegment_9,
                                        x_admsegment_10                     => cur_fbr_rec.admsegment_10,
                                        x_admsegment_11                     => cur_fbr_rec.admsegment_11,
                                        x_admsegment_12                     => cur_fbr_rec.admsegment_12,
                                        x_admsegment_13                     => cur_fbr_rec.admsegment_13,
                                        x_admsegment_14                     => cur_fbr_rec.admsegment_14,
                                        x_admsegment_15                     => cur_fbr_rec.admsegment_15,
                                        x_admsegment_16                     => cur_fbr_rec.admsegment_16,
                                        x_admsegment_17                     => cur_fbr_rec.admsegment_17,
                                        x_admsegment_18                     => cur_fbr_rec.admsegment_18,
                                        x_admsegment_19                     => cur_fbr_rec.admsegment_19,
                                        x_admsegment_20                     => cur_fbr_rec.admsegment_20,
                                        x_packstruct_id                     => cur_fbr_rec.packstruct_id,
                                        x_packsegment_1                     => cur_fbr_rec.packsegment_1,
                                        x_packsegment_2                     => cur_fbr_rec.packsegment_2,
                                        x_packsegment_3                     => cur_fbr_rec.packsegment_3,
                                        x_packsegment_4                     => cur_fbr_rec.packsegment_4,
                                        x_packsegment_5                     => cur_fbr_rec.packsegment_5,
                                        x_packsegment_6                     => cur_fbr_rec.packsegment_6,
                                        x_packsegment_7                     => cur_fbr_rec.packsegment_7,
                                        x_packsegment_8                     => cur_fbr_rec.packsegment_8,
                                        x_packsegment_9                     => cur_fbr_rec.packsegment_9,
                                        x_packsegment_10                    => cur_fbr_rec.packsegment_10,
                                        x_packsegment_11                    => cur_fbr_rec.packsegment_11,
                                        x_packsegment_12                    => cur_fbr_rec.packsegment_12,
                                        x_packsegment_13                    => cur_fbr_rec.packsegment_13,
                                        x_packsegment_14                    => cur_fbr_rec.packsegment_14,
                                        x_packsegment_15                    => cur_fbr_rec.packsegment_15,
                                        x_packsegment_16                    => cur_fbr_rec.packsegment_16,
                                        x_packsegment_17                    => cur_fbr_rec.packsegment_17,
                                        x_packsegment_18                    => cur_fbr_rec.packsegment_18,
                                        x_packsegment_19                    => cur_fbr_rec.packsegment_19,
                                        x_packsegment_20                    => cur_fbr_rec.packsegment_20,
                                        x_miscstruct_id                     => cur_fbr_rec.miscstruct_id,
                                        x_miscsegment_1                     => cur_fbr_rec.miscsegment_1,
                                        x_miscsegment_2                     => cur_fbr_rec.miscsegment_2,
                                        x_miscsegment_3                     => cur_fbr_rec.miscsegment_3,
                                        x_miscsegment_4                     => cur_fbr_rec.miscsegment_4,
                                        x_miscsegment_5                     => cur_fbr_rec.miscsegment_5,
                                        x_miscsegment_6                     => cur_fbr_rec.miscsegment_6,
                                        x_miscsegment_7                     => cur_fbr_rec.miscsegment_7,
                                        x_miscsegment_8                     => cur_fbr_rec.miscsegment_8,
                                        x_miscsegment_9                     => cur_fbr_rec.miscsegment_9,
                                        x_miscsegment_10                    => cur_fbr_rec.miscsegment_10,
                                        x_miscsegment_11                    => cur_fbr_rec.miscsegment_11,
                                        x_miscsegment_12                    => cur_fbr_rec.miscsegment_12,
                                        x_miscsegment_13                    => cur_fbr_rec.miscsegment_13,
                                        x_miscsegment_14                    => cur_fbr_rec.miscsegment_14,
                                        x_miscsegment_15                    => cur_fbr_rec.miscsegment_15,
                                        x_miscsegment_16                    => cur_fbr_rec.miscsegment_16,
                                        x_miscsegment_17                    => cur_fbr_rec.miscsegment_17,
                                        x_miscsegment_18                    => cur_fbr_rec.miscsegment_18,
                                        x_miscsegment_19                    => cur_fbr_rec.miscsegment_19,
                                        x_miscsegment_20                    => cur_fbr_rec.miscsegment_20,
                                        x_prof_judgement_flg                => cur_fbr_rec.prof_judgement_flg,
                                        x_nslds_data_override_flg           => cur_fbr_rec.nslds_data_override_flg,
                                        x_target_group                      => cur_fbr_rec.target_group,
                                        x_coa_fixed                         => cur_fbr_rec.coa_fixed,
                                        x_tolerance_amount                  => NVL(pv_tol,cur_fbr_rec.tolerance_amount),
                                        x_profile_status                    => cur_fbr_rec.profile_status,
                                        x_profile_status_date               => cur_fbr_rec.profile_status_date,
                                        x_profile_fc                        => cur_fbr_rec.profile_fc,
                                        x_coa_pell                          => cur_fbr_rec.coa_pell,
                                        x_manual_disb_hold                  => g_disb_hold,
                                        x_pell_alt_expense                  => cur_fbr_rec.pell_alt_expense,
                                        x_assoc_org_num                     => cur_fbr_rec.assoc_org_num,
                                        x_award_fmly_contribution_type      => cur_fbr_rec.award_fmly_contribution_type,
                                        x_isir_locked_by                    => cur_fbr_rec.isir_locked_by,
                                        x_adnl_unsub_loan_elig_flag         => cur_fbr_rec.adnl_unsub_loan_elig_flag,
                                        x_lock_awd_flag                     => cur_fbr_rec.lock_awd_flag,
                                        x_lock_coa_flag                     => cur_fbr_rec.lock_coa_flag
                                );
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.l_update_base_rec.debug','igf_ap_fa_base_rec_pkg.update_row successfull');
        END IF;
      END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_BATCH_VER_PRC.L_UPDATE_BASE_REC '||SQLERRM);
      IGS_GE_MSG_STACK.ADD;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.l_update_base_rec.debug',SQLERRM);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END l_update_base_rec;


  PROCEDURE  check_data_type(p_colname VARCHAR2, p_datatype OUT NOCOPY VARCHAR2) IS
    /*
    ||  Created By : Rakesh
    ||  Created On : 22-Mar-2002
    ||  Purpose : For right padding the variables to make their length
    ||            fit to the field size in record.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    v_datatype       VARCHAR2(106);
    v_date_num_flg   VARCHAR2(1);

    CURSOR get_data_type ( cp_tablename  VARCHAR2 )IS
    SELECT data_type
      FROM user_tab_columns
     WHERE column_name=p_colname
       AND table_name = cp_tablename ;

    l_tablename  VARCHAR2(60) ;

  BEGIN

      l_tablename := 'IGF_AP_ISIR_MATCHED';
      OPEN  get_data_type ( l_tablename) ;
      FETCH get_data_type INTO v_datatype;
      CLOSE get_data_type;

      IF v_datatype = 'NUMBER' THEN
       p_datatype := 'N';
      ELSIF v_datatype = 'DATE' THEN
       p_datatype := 'D';
      ELSE
       p_datatype := 'C';
      END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_datatype := 'C';
  END check_data_type;

  PROCEDURE create_correction_isir(
                                   p_base_id   IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                                   pn_isir_id  OUT NOCOPY NUMBER
                                   ) IS
    /*
    ||  Created By : skoppula
    ||  Created On : 04-JUL-2001
    ||  Purpose : To create the Correction ISIR
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  masehgal        15-Feb-2002     # 2216956     FACR007
    ||                                  Added Verif_track_flag
    ||  (reverse chronological order - newest change first)
    */

    CURSOR cur_isir_original (cp_base_id NUMBER) IS
    SELECT im.*
      FROM igf_ap_isir_matched im
     WHERE im.payment_isir = 'Y'
       AND im.system_record_type = 'ORIGINAL'
       AND im.base_id = cp_base_id;

    lv_rowid        VARCHAR2(30);

  BEGIN

    -- INsert Record in IGF_AP_ISIR_Matched table
    FOR cur_ori_isir_rec IN cur_isir_original(p_base_id) LOOP

       igf_ap_isir_matched_pkg.insert_row(
                              x_Mode                              => 'R',
                              x_rowid                             => lv_rowid,
                              x_isir_id                           => pn_isir_id,
                              x_base_id                           => cur_ori_isir_rec.base_id,
                              x_batch_year                        => cur_ori_isir_rec.batch_year,
                              x_transaction_num                   => cur_ori_isir_rec.transaction_num,
                              x_current_ssn                       => cur_ori_isir_rec.current_ssn,
                              x_ssn_name_change                   => cur_ori_isir_rec.ssn_name_change,
                              x_original_ssn                      => cur_ori_isir_rec.original_ssn,
                              x_orig_name_id                      => cur_ori_isir_rec.orig_name_id,
                              x_last_name                         => cur_ori_isir_rec.last_name,
                              x_first_name                        => cur_ori_isir_rec.first_name,
                              x_middle_initial                    => cur_ori_isir_rec.middle_initial,
                              x_perm_mail_add                     => cur_ori_isir_rec.perm_mail_add,
                              x_perm_city                         => cur_ori_isir_rec.perm_city,
                              x_perm_state                        => cur_ori_isir_rec.perm_state,
                              x_perm_zip_code                     => cur_ori_isir_rec.perm_zip_code,
                              x_date_of_birth                     => cur_ori_isir_rec.date_of_birth,
                              x_phone_number                      => cur_ori_isir_rec.phone_number,
                              x_driver_license_number             => cur_ori_isir_rec.driver_license_number,
                              x_driver_license_state              => cur_ori_isir_rec.driver_license_state,
                              x_citizenship_status                => cur_ori_isir_rec.citizenship_status,
                              x_alien_reg_number                  => cur_ori_isir_rec.alien_reg_number,
                              x_s_marital_status                  => cur_ori_isir_rec.s_marital_status,
                              x_s_marital_status_date             => cur_ori_isir_rec.s_marital_status_date,
                              x_summ_enrl_status                  => cur_ori_isir_rec.summ_enrl_status,
                              x_fall_enrl_status                  => cur_ori_isir_rec.fall_enrl_status,
                              x_winter_enrl_status                => cur_ori_isir_rec.winter_enrl_status,
                              x_spring_enrl_status                => cur_ori_isir_rec.spring_enrl_status,
                              x_summ2_enrl_status                 => cur_ori_isir_rec.summ2_enrl_status,
                              x_fathers_highest_edu_level         => cur_ori_isir_rec.fathers_highest_edu_level,
                              x_mothers_highest_edu_level         => cur_ori_isir_rec.mothers_highest_edu_level,
                              x_s_state_legal_residence           => cur_ori_isir_rec.s_state_legal_residence,
                              x_legal_residence_before_date       => cur_ori_isir_rec.legal_residence_before_date,
                              x_s_legal_resd_date                 => cur_ori_isir_rec.s_legal_resd_date,
                              x_ss_r_u_male                       => cur_ori_isir_rec.ss_r_u_male,
                              x_selective_service_reg             => cur_ori_isir_rec.selective_service_reg,
                              x_degree_certification              => cur_ori_isir_rec.degree_certification,
                              x_grade_level_in_college            => cur_ori_isir_rec.grade_level_in_college,
                              x_high_school_diploma_ged           => cur_ori_isir_rec.high_school_diploma_ged,
                              x_first_bachelor_deg_by_date        => cur_ori_isir_rec.first_bachelor_deg_by_date,
                              x_interest_in_loan                  => cur_ori_isir_rec.interest_in_loan,
                              x_interest_in_stud_employment       => cur_ori_isir_rec.interest_in_stud_employment,
                              x_drug_offence_conviction           => cur_ori_isir_rec.drug_offence_conviction,
                              x_s_tax_return_status               => cur_ori_isir_rec.s_tax_return_status,
                              x_s_type_tax_return                 => cur_ori_isir_rec.s_type_tax_return,
                              x_s_elig_1040ez                     => cur_ori_isir_rec.s_elig_1040ez,
                              x_s_adjusted_gross_income           => cur_ori_isir_rec.s_adjusted_gross_income,
                              x_s_fed_taxes_paid                  => cur_ori_isir_rec.s_fed_taxes_paid,
                              x_s_exemptions                      => cur_ori_isir_rec.s_exemptions,
                              x_s_income_from_work                => cur_ori_isir_rec.s_income_from_work,
                              x_spouse_income_from_work           => cur_ori_isir_rec.spouse_income_from_work,
                              x_s_toa_amt_from_wsa                => cur_ori_isir_rec.s_toa_amt_from_wsa,
                              x_s_toa_amt_from_wsb                => cur_ori_isir_rec.s_toa_amt_from_wsb,
                              x_s_toa_amt_from_wsc                => cur_ori_isir_rec.s_toa_amt_from_wsc,
                              x_s_investment_networth             => cur_ori_isir_rec.s_investment_networth,
                              x_s_busi_farm_networth              => cur_ori_isir_rec.s_busi_farm_networth,
                              x_s_cash_savings                    => cur_ori_isir_rec.s_cash_savings,
                              x_va_months                         => cur_ori_isir_rec.va_months,
                              x_va_amount                         => cur_ori_isir_rec.va_amount,
                              x_stud_dob_before_date              => cur_ori_isir_rec.stud_dob_before_date,
                              x_deg_beyond_bachelor               => cur_ori_isir_rec.deg_beyond_bachelor,
                              x_s_married                         => cur_ori_isir_rec.s_married,
                              x_s_have_children                   => cur_ori_isir_rec.s_have_children,
                              x_legal_dependents                  => cur_ori_isir_rec.legal_dependents,
                              x_orphan_ward_of_court              => cur_ori_isir_rec.orphan_ward_of_court,
                              x_s_veteran                         => cur_ori_isir_rec.s_veteran,
                              x_p_marital_status                  => cur_ori_isir_rec.p_marital_status,
                              x_father_ssn                        => cur_ori_isir_rec.father_ssn,
                              x_f_last_name                       => cur_ori_isir_rec.f_last_name,
                              x_mother_ssn                        => cur_ori_isir_rec.mother_ssn,
                              x_m_last_name                       => cur_ori_isir_rec.m_last_name,
                              x_p_num_family_member               => cur_ori_isir_rec.p_num_family_member,
                              x_p_num_in_college                  => cur_ori_isir_rec.p_num_in_college,
                              x_p_state_legal_residence           => cur_ori_isir_rec.p_state_legal_residence,
                              x_p_state_legal_res_before_dt       => cur_ori_isir_rec.p_state_legal_res_before_dt,
                              x_p_legal_res_date                  => cur_ori_isir_rec.p_legal_res_date,
                              x_age_older_parent                  => cur_ori_isir_rec.age_older_parent,
                              x_p_tax_return_status               => cur_ori_isir_rec.p_tax_return_status,
                              x_p_type_tax_return                 => cur_ori_isir_rec.p_type_tax_return,
                              x_p_elig_1040aez                    => cur_ori_isir_rec.p_elig_1040aez,
                              x_p_adjusted_gross_income           => cur_ori_isir_rec.p_adjusted_gross_income,
                              x_p_taxes_paid                      => cur_ori_isir_rec.p_taxes_paid,
                              x_p_exemptions                      => cur_ori_isir_rec.p_exemptions,
                              x_f_income_work                     => cur_ori_isir_rec.f_income_work,
                              x_m_income_work                     => cur_ori_isir_rec.m_income_work,
                              x_p_income_wsa                      => cur_ori_isir_rec.p_income_wsa,
                              x_p_income_wsb                      => cur_ori_isir_rec.p_income_wsb,
                              x_p_income_wsc                      => cur_ori_isir_rec.p_income_wsc,
                              x_p_investment_networth             => cur_ori_isir_rec.p_investment_networth,
                              x_p_business_networth               => cur_ori_isir_rec.p_business_networth,
                              x_p_cash_saving                     => cur_ori_isir_rec.p_cash_saving,
                              x_s_num_family_members              => cur_ori_isir_rec.s_num_family_members,
                              x_s_num_in_college                  => cur_ori_isir_rec.s_num_in_college,
                              x_first_college                     => cur_ori_isir_rec.first_college,
                              x_first_house_plan                  => cur_ori_isir_rec.first_house_plan,
                              x_second_college                    => cur_ori_isir_rec.second_college,
                              x_second_house_plan                 => cur_ori_isir_rec.second_house_plan,
                              x_third_college                     => cur_ori_isir_rec.third_college,
                              x_third_house_plan                  => cur_ori_isir_rec.third_house_plan,
                              x_fourth_college                    => cur_ori_isir_rec.fourth_college,
                              x_fourth_house_plan                 => cur_ori_isir_rec.fourth_house_plan,
                              x_fifth_college                     => cur_ori_isir_rec.fifth_college,
                              x_fifth_house_plan                  => cur_ori_isir_rec.fifth_house_plan,
                              x_sixth_college                     => cur_ori_isir_rec.sixth_college,
                              x_sixth_house_plan                  => cur_ori_isir_rec.sixth_house_plan,
                              x_date_app_completed                => cur_ori_isir_rec.date_app_completed,
                              x_signed_by                         => cur_ori_isir_rec.signed_by,
                              x_preparer_ssn                      => cur_ori_isir_rec.preparer_ssn,
                              x_preparer_emp_id_number            => cur_ori_isir_rec.preparer_emp_id_number,
                              x_preparer_sign                     => cur_ori_isir_rec.preparer_sign,
                              x_transaction_receipt_date          => cur_ori_isir_rec.transaction_receipt_date,
                              x_dependency_override_ind           => cur_ori_isir_rec.dependency_override_ind,
                              x_faa_fedral_schl_code              => cur_ori_isir_rec.faa_fedral_schl_code,
                              x_faa_adjustment                    => cur_ori_isir_rec.faa_adjustment,
                              x_input_record_type                 => cur_ori_isir_rec.input_record_type,
                              x_serial_number                     => cur_ori_isir_rec.serial_number,
                              x_batch_number                      => cur_ori_isir_rec.batch_number,
                              x_early_analysis_flag               => cur_ori_isir_rec.early_analysis_flag,
                              x_app_entry_source_code             => cur_ori_isir_rec.app_entry_source_code,
                              x_eti_destination_code              => cur_ori_isir_rec.eti_destination_code,
                              x_reject_override_b                 => cur_ori_isir_rec.reject_override_b,
                              x_reject_override_n                 => cur_ori_isir_rec.reject_override_n,
                              x_reject_override_w                 => cur_ori_isir_rec.reject_override_w,
                              x_assum_override_1                  => cur_ori_isir_rec.assum_override_1,
                              x_assum_override_2                  => cur_ori_isir_rec.assum_override_2,
                              x_assum_override_3                  => cur_ori_isir_rec.assum_override_3,
                              x_assum_override_4                  => cur_ori_isir_rec.assum_override_4,
                              x_assum_override_5                  => cur_ori_isir_rec.assum_override_5,
                              x_assum_override_6                  => cur_ori_isir_rec.assum_override_6,
                              x_dependency_status                 => cur_ori_isir_rec.dependency_status,
                              x_s_email_address                   => cur_ori_isir_rec.s_email_address,
                              x_nslds_reason_code                 => cur_ori_isir_rec.nslds_reason_code,
                              x_app_receipt_date                  => cur_ori_isir_rec.app_receipt_date,
                              x_processed_rec_type                => cur_ori_isir_rec.processed_rec_type,
                              x_hist_correction_for_tran_id       => cur_ori_isir_rec.hist_correction_for_tran_id,
                              x_system_generated_indicator        => cur_ori_isir_rec.system_generated_indicator,
                              x_dup_request_indicator             => cur_ori_isir_rec.dup_request_indicator,
                              x_source_of_correction              => cur_ori_isir_rec.source_of_correction,
                              x_p_cal_tax_status                  => cur_ori_isir_rec.p_cal_tax_status,
                              x_s_cal_tax_status                  => cur_ori_isir_rec.s_cal_tax_status,
                              x_graduate_flag                     => cur_ori_isir_rec.graduate_flag,
                              x_auto_zero_efc                     => cur_ori_isir_rec.auto_zero_efc,
                              x_efc_change_flag                   => cur_ori_isir_rec.efc_change_flag,
                              x_sarc_flag                         => cur_ori_isir_rec.sarc_flag,
                              x_simplified_need_test              => cur_ori_isir_rec.simplified_need_test,
                              x_reject_reason_codes               => cur_ori_isir_rec.reject_reason_codes,
                              x_select_service_match_flag         => cur_ori_isir_rec.select_service_match_flag,
                              x_select_service_reg_flag           => cur_ori_isir_rec.select_service_reg_flag,
                              x_ins_match_flag                    => cur_ori_isir_rec.ins_match_flag,
                              x_ins_verification_number           => NULL,
                              x_sec_ins_match_flag                => cur_ori_isir_rec.sec_ins_match_flag,
                              x_sec_ins_ver_number                => cur_ori_isir_rec.sec_ins_ver_number,
                              x_ssn_match_flag                    => cur_ori_isir_rec.ssn_match_flag,
                              x_ssa_citizenship_flag              => cur_ori_isir_rec.ssa_citizenship_flag,
                              x_ssn_date_of_death                 => cur_ori_isir_rec.ssn_date_of_death,
                              x_nslds_match_flag                  => cur_ori_isir_rec.nslds_match_flag,
                              x_va_match_flag                     => cur_ori_isir_rec.va_match_flag,
                              x_prisoner_match                    => cur_ori_isir_rec.prisoner_match,
                              x_verification_flag                 => cur_ori_isir_rec.verification_flag,
                              x_subsequent_app_flag               => cur_ori_isir_rec.subsequent_app_flag,
                              x_app_source_site_code              => cur_ori_isir_rec.app_source_site_code,
                              x_tran_source_site_code             => cur_ori_isir_rec.tran_source_site_code,
                              x_drn                               => cur_ori_isir_rec.drn,
                              x_tran_process_date                 => cur_ori_isir_rec.tran_process_date,
                              x_computer_batch_number             => cur_ori_isir_rec.computer_batch_number,
                              x_correction_flags                  => cur_ori_isir_rec.correction_flags,
                              x_highlight_flags                   => cur_ori_isir_rec.highlight_flags,
                              x_paid_efc                          => cur_ori_isir_rec.paid_efc,
                              x_primary_efc                       => cur_ori_isir_rec.primary_efc,
                              x_secondary_efc                     => cur_ori_isir_rec.secondary_efc,
                              x_fed_pell_grant_efc_type           => cur_ori_isir_rec.fed_pell_grant_efc_type,
                              x_primary_efc_type                  => cur_ori_isir_rec.primary_efc_type,
                              x_sec_efc_type                      => cur_ori_isir_rec.sec_efc_type,
                              x_primary_alternate_month_1         => cur_ori_isir_rec.primary_alternate_month_1,
                              x_primary_alternate_month_2         => cur_ori_isir_rec.primary_alternate_month_2,
                              x_primary_alternate_month_3         => cur_ori_isir_rec.primary_alternate_month_3,
                              x_primary_alternate_month_4         => cur_ori_isir_rec.primary_alternate_month_4,
                              x_primary_alternate_month_5         => cur_ori_isir_rec.primary_alternate_month_5,
                              x_primary_alternate_month_6         => cur_ori_isir_rec.primary_alternate_month_6,
                              x_primary_alternate_month_7         => cur_ori_isir_rec.primary_alternate_month_7,
                              x_primary_alternate_month_8         => cur_ori_isir_rec.primary_alternate_month_8,
                              x_primary_alternate_month_10        => cur_ori_isir_rec.primary_alternate_month_10,
                              x_primary_alternate_month_11        => cur_ori_isir_rec.primary_alternate_month_11,
                              x_primary_alternate_month_12        => cur_ori_isir_rec.primary_alternate_month_12,
                              x_sec_alternate_month_1             => cur_ori_isir_rec.sec_alternate_month_1,
                              x_sec_alternate_month_2             => cur_ori_isir_rec.sec_alternate_month_2,
                              x_sec_alternate_month_3             => cur_ori_isir_rec.sec_alternate_month_3,
                              x_sec_alternate_month_4             => cur_ori_isir_rec.sec_alternate_month_4,
                              x_sec_alternate_month_5             => cur_ori_isir_rec.sec_alternate_month_5,
                              x_sec_alternate_month_6             => cur_ori_isir_rec.sec_alternate_month_6,
                              x_sec_alternate_month_7             => cur_ori_isir_rec.sec_alternate_month_7,
                              x_sec_alternate_month_8             => cur_ori_isir_rec.sec_alternate_month_8,
                              x_sec_alternate_month_10            => cur_ori_isir_rec.sec_alternate_month_10,
                              x_sec_alternate_month_11            => cur_ori_isir_rec.sec_alternate_month_11,
                              x_sec_alternate_month_12            => cur_ori_isir_rec.sec_alternate_month_12,
                              x_total_income                      => cur_ori_isir_rec.total_income,
                              x_allow_total_income                => cur_ori_isir_rec.allow_total_income,
                              x_state_tax_allow                   => cur_ori_isir_rec.state_tax_allow,
                              x_employment_allow                  => cur_ori_isir_rec.employment_allow,
                              x_income_protection_allow           => cur_ori_isir_rec.income_protection_allow,
                              x_available_income                  => cur_ori_isir_rec.available_income,
                              x_contribution_from_ai              => cur_ori_isir_rec.contribution_from_ai,
                              x_discretionary_networth            => cur_ori_isir_rec.discretionary_networth,
                              x_efc_networth                      => cur_ori_isir_rec.efc_networth,
                              x_asset_protect_allow               => cur_ori_isir_rec.asset_protect_allow,
                              x_parents_cont_from_assets          => cur_ori_isir_rec.parents_cont_from_assets,
                              x_adjusted_available_income         => cur_ori_isir_rec.adjusted_available_income,
                              x_total_student_contribution        => cur_ori_isir_rec.total_student_contribution,
                              x_total_parent_contribution         => cur_ori_isir_rec.total_parent_contribution,
                              x_parents_contribution              => cur_ori_isir_rec.parents_contribution,
                              x_student_total_income              => cur_ori_isir_rec.student_total_income,
                              x_sati                              => cur_ori_isir_rec.sati,
                              x_sic                               => cur_ori_isir_rec.sic,
                              x_sdnw                              => cur_ori_isir_rec.sdnw,
                              x_sca                               => cur_ori_isir_rec.sca,
                              x_fti                               => cur_ori_isir_rec.fti,
                              x_secti                             => cur_ori_isir_rec.secti,
                              x_secati                            => cur_ori_isir_rec.secati,
                              x_secstx                            => cur_ori_isir_rec.secstx,
                              x_secea                             => cur_ori_isir_rec.secea,
                              x_secipa                            => cur_ori_isir_rec.secipa,
                              x_secai                             => cur_ori_isir_rec.secai,
                              x_seccai                            => cur_ori_isir_rec.seccai,
                              x_secdnw                            => cur_ori_isir_rec.secdnw,
                              x_secnw                             => cur_ori_isir_rec.secnw,
                              x_secapa                            => cur_ori_isir_rec.secapa,
                              x_secpca                            => cur_ori_isir_rec.secpca,
                              x_secaai                            => cur_ori_isir_rec.secaai,
                              x_sectsc                            => cur_ori_isir_rec.sectsc,
                              x_sectpc                            => cur_ori_isir_rec.sectpc,
                              x_secpc                             => cur_ori_isir_rec.secpc,
                              x_secsti                            => cur_ori_isir_rec.secsti,
                              x_secsic                            => cur_ori_isir_rec.secsic,
                              x_secsati                           => cur_ori_isir_rec.secsati,
                              x_secsdnw                           => cur_ori_isir_rec.secsdnw,
                              x_secsca                            => cur_ori_isir_rec.secsca,
                              x_secfti                            => cur_ori_isir_rec.secfti,
                              x_a_citizenship                     => cur_ori_isir_rec.a_citizenship,
                              x_a_student_marital_status          => cur_ori_isir_rec.a_student_marital_status,
                              x_a_student_agi                     => cur_ori_isir_rec.a_student_agi,
                              x_a_s_us_tax_paid                   => cur_ori_isir_rec.a_s_us_tax_paid,
                              x_a_s_income_work                   => cur_ori_isir_rec.a_s_income_work,
                              x_a_spouse_income_work              => cur_ori_isir_rec.a_spouse_income_work,
                              x_a_s_total_wsc                     => cur_ori_isir_rec.a_s_total_wsc,
                              x_a_date_of_birth                   => cur_ori_isir_rec.a_date_of_birth,
                              x_a_student_married                 => cur_ori_isir_rec.a_student_married,
                              x_a_have_children                   => cur_ori_isir_rec.a_have_children,
                              x_a_s_have_dependents               => cur_ori_isir_rec.a_s_have_dependents,
                              x_a_va_status                       => cur_ori_isir_rec.a_va_status,
                              x_a_s_num_in_family                 => cur_ori_isir_rec.a_s_num_in_family,
                              x_a_s_num_in_college                => cur_ori_isir_rec.a_s_num_in_college,
                              x_a_p_marital_status                => cur_ori_isir_rec.a_p_marital_status,
                              x_a_father_ssn                      => cur_ori_isir_rec.a_father_ssn,
                              x_a_mother_ssn                      => cur_ori_isir_rec.a_mother_ssn,
                              x_a_parents_num_family              => cur_ori_isir_rec.a_parents_num_family,
                              x_a_parents_num_college             => cur_ori_isir_rec.a_parents_num_college,
                              x_a_parents_agi                     => cur_ori_isir_rec.a_parents_agi,
                              x_a_p_us_tax_paid                   => cur_ori_isir_rec.a_p_us_tax_paid,
                              x_a_f_work_income                   => cur_ori_isir_rec.a_f_work_income,
                              x_a_m_work_income                   => cur_ori_isir_rec.a_m_work_income,
                              x_a_p_total_wsc                     => cur_ori_isir_rec.a_p_total_wsc,
                              x_comment_codes                     => cur_ori_isir_rec.comment_codes,
                              x_sar_ack_comm_code                 => cur_ori_isir_rec.sar_ack_comm_code,
                              x_pell_grant_elig_flag              => cur_ori_isir_rec.pell_grant_elig_flag,
                              x_reprocess_reason_code             => cur_ori_isir_rec.reprocess_reason_code,
                              x_duplicate_date                    => cur_ori_isir_rec.duplicate_date,
                              x_isir_transaction_type             => 'C',
                              x_fedral_schl_code_indicator        => cur_ori_isir_rec.fedral_schl_code_indicator,
                              x_multi_school_code_flags           => cur_ori_isir_rec.multi_school_code_flags,
                              x_dup_ssn_indicator                 => cur_ori_isir_rec.dup_ssn_indicator,
                              x_system_record_type                => 'CORRECTION',
                              x_payment_isir                      => 'N',
                              x_active_isir                       => 'Y',
                              x_receipt_status                    => 'MATCHED',
                              x_isir_receipt_completed            => 'Y' ,
                              x_verif_track_flag                  => cur_ori_isir_rec.verif_track_flag,
                              x_legacy_record_flag                => NULL,
                              x_father_first_name_initial         => cur_ori_isir_rec.father_first_name_initial_txt,
                              x_father_step_father_birth_dt       => cur_ori_isir_rec.father_step_father_birth_date,
                              x_mother_first_name_initial         => cur_ori_isir_rec.mother_first_name_initial_txt,
                              x_mother_step_mother_birth_dt       => cur_ori_isir_rec.mother_step_mother_birth_date,
                              x_parents_email_address_txt         => cur_ori_isir_rec.parents_email_address_txt,
                              x_address_change_type               => cur_ori_isir_rec.address_change_type,
                              x_cps_pushed_isir_flag              => cur_ori_isir_rec.cps_pushed_isir_flag,
                              x_electronic_transaction_type       => cur_ori_isir_rec.electronic_transaction_type,
                              x_sar_c_change_type                 => cur_ori_isir_rec.sar_c_change_type,
                              x_father_ssn_match_type             => cur_ori_isir_rec.father_ssn_match_type,
                              x_mother_ssn_match_type             => cur_ori_isir_rec.mother_ssn_match_type,
                              x_reject_override_g_flag            => cur_ori_isir_rec.reject_override_g_flag,
                              x_dhs_verification_num_txt          => cur_ori_isir_rec.dhs_verification_num_txt,
                              x_data_file_name_txt                => cur_ori_isir_rec.data_file_name_txt ,
                              x_message_class_txt                 => NULL,
                              x_reject_override_3_flag            => cur_ori_isir_rec.reject_override_3_flag,
                              x_reject_override_12_flag           => cur_ori_isir_rec.reject_override_12_flag,
                              x_reject_override_j_flag            => cur_ori_isir_rec.reject_override_j_flag,
                              x_reject_override_k_flag            => cur_ori_isir_rec.reject_override_k_flag,
                              x_rejected_status_change_flag       => cur_ori_isir_rec.rejected_status_change_flag,
                              x_verification_selection_flag       => cur_ori_isir_rec.verification_selection_flag
                        );
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.l_update_base_rec.debug','igf_ap_isir_matched_pkg.insert_row successfull New ISIR ID: '||pn_isir_id);
        END IF;
    END LOOP;

  EXCEPTION
    WHEN others THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_BATCH_VER_PRC.CREATE_CORRECTION_ISIR '||SQLERRM);
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      IGS_GE_MSG_STACK.ADD;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.create_correction_isir.debug',SQLERRM);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END create_correction_isir;


  PROCEDURE update_correction_isir (
                                    pn_base_id igf_ap_fa_base_rec.base_id%TYPE ,
                                    p_isir_rec IGF_AP_ISIR_MATCHED%ROWTYPE ,
                                    p_update_ssn VARCHAR2
                                   ) IS
    /*
    ||  Created By : rasingh
    ||  Created On : 07-May-2002
    ||  Purpose :
    ||  The procedure will validate if the correctiosn will cause any chage in the EFC, If there is change then
    ||  This procedure creates correction record if that record is not presant. Else FA Process Status is Updated to
    ||  CALCULATED.
    ||  Change History :
    ||  Who        When         What
    ||  (reverse chronological order - newest change first)
    ||  brajendr   03-Mar-2003  Bug # 2822497
    ||                          Added the validations for Current SSN when
    ||                          Pell Origination is Alread Sent
    */


    l_message           VARCHAR2(100);
  BEGIN

    IF p_update_ssn = 'Y' THEN
      -- SSN for the student has changed so update the SSN
      l_message := NULL;

      igf_gr_gen.update_current_ssn(
                                    p_isir_rec.base_id,
                                    p_isir_rec.current_ssn,
                                    l_message
                                   );

      IF l_message = 'IGF_GR_UPDT_SSN_FAIL' THEN
        fnd_message.set_name('IGF','IGF_GR_UPDT_SSN_FAIL');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
      END IF;

    END IF;

    igf_ap_isir_matched_pkg.update_row(
              x_Mode                         => 'R',
              x_rowid                        => p_isir_rec.row_id,
              x_isir_id                      => p_isir_rec.isir_id,
              x_base_id                      => p_isir_rec.base_id,
              x_batch_year                   => p_isir_rec.batch_year,
              x_transaction_num              => p_isir_rec.transaction_num,
              x_current_ssn                  => p_isir_rec.current_ssn,
              x_ssn_name_change              => p_isir_rec.ssn_name_change,
              x_original_ssn                 => p_isir_rec.original_ssn,
              x_orig_name_id                 => p_isir_rec.orig_name_id,
              x_last_name                    => p_isir_rec.last_name,
              x_first_name                   => p_isir_rec.first_name,
              x_middle_initial               => p_isir_rec.middle_initial,
              x_perm_mail_add                => p_isir_rec.perm_mail_add,
              x_perm_city                    => p_isir_rec.perm_city,
              x_perm_state                   => p_isir_rec.perm_state,
              x_perm_zip_code                => p_isir_rec.perm_zip_code,
              x_date_of_birth                => p_isir_rec.date_of_birth,
              x_phone_number                 => p_isir_rec.phone_number,
              x_driver_license_number        => p_isir_rec.driver_license_number,
              x_driver_license_state         => p_isir_rec.driver_license_state,
              x_citizenship_status           => p_isir_rec.citizenship_status,
              x_alien_reg_number             => p_isir_rec.alien_reg_number,
              x_s_marital_status             => p_isir_rec.s_marital_status,
              x_s_marital_status_date        => p_isir_rec.s_marital_status_date,
              x_summ_enrl_status             => p_isir_rec.summ_enrl_status,
              x_fall_enrl_status             => p_isir_rec.fall_enrl_status,
              x_winter_enrl_status           => p_isir_rec.winter_enrl_status,
              x_spring_enrl_status           => p_isir_rec.spring_enrl_status,
              x_summ2_enrl_status            => p_isir_rec.summ2_enrl_status,
              x_fathers_highest_edu_level    => p_isir_rec.fathers_highest_edu_level,
              x_mothers_highest_edu_level    => p_isir_rec.mothers_highest_edu_level,
              x_s_state_legal_residence      => p_isir_rec.s_state_legal_residence,
              x_legal_residence_before_date  => p_isir_rec.legal_residence_before_date,
              x_s_legal_resd_date            => p_isir_rec.s_legal_resd_date,
              x_ss_r_u_male                  => p_isir_rec.ss_r_u_male,
              x_selective_service_reg        => p_isir_rec.selective_service_reg,
              x_degree_certification         => p_isir_rec.degree_certification,
              x_grade_level_in_college       => p_isir_rec.grade_level_in_college,
              x_high_school_diploma_ged      => p_isir_rec.high_school_diploma_ged,
              x_first_bachelor_deg_by_date   => p_isir_rec.first_bachelor_deg_by_date,
              x_interest_in_loan             => p_isir_rec.interest_in_loan,
              x_interest_in_stud_employment  => p_isir_rec.interest_in_stud_employment,
              x_drug_offence_conviction      => p_isir_rec.drug_offence_conviction,
              x_s_tax_return_status          => p_isir_rec.s_tax_return_status,
              x_s_type_tax_return            => p_isir_rec.s_type_tax_return,
              x_s_elig_1040ez                => p_isir_rec.s_elig_1040ez,
              x_s_adjusted_gross_income      => p_isir_rec.s_adjusted_gross_income,
              x_s_fed_taxes_paid             => p_isir_rec.s_fed_taxes_paid,
              x_s_exemptions                 => p_isir_rec.s_exemptions,
              x_s_income_from_work           => p_isir_rec.s_income_from_work,
              x_spouse_income_from_work      => p_isir_rec.spouse_income_from_work,
              x_s_toa_amt_from_wsa           => p_isir_rec.s_toa_amt_from_wsa,
              x_s_toa_amt_from_wsb           => p_isir_rec.s_toa_amt_from_wsb,
              x_s_toa_amt_from_wsc           => p_isir_rec.s_toa_amt_from_wsc,
              x_s_investment_networth        => p_isir_rec.s_investment_networth,
              x_s_busi_farm_networth         => p_isir_rec.s_busi_farm_networth,
              x_s_cash_savings               => p_isir_rec.s_cash_savings,
              x_va_months                    => p_isir_rec.va_months,
              x_va_amount                    => p_isir_rec.va_amount,
              x_stud_dob_before_date         => p_isir_rec.stud_dob_before_date,
              x_deg_beyond_bachelor          => p_isir_rec.deg_beyond_bachelor,
              x_s_married                    => p_isir_rec.s_married,
              x_s_have_children              => p_isir_rec.s_have_children,
              x_legal_dependents             => p_isir_rec.legal_dependents,
              x_orphan_ward_of_court         => p_isir_rec.orphan_ward_of_court,
              x_s_veteran                    => p_isir_rec.s_veteran,
              x_p_marital_status             => p_isir_rec.p_marital_status,
              x_father_ssn                   => p_isir_rec.father_ssn,
              x_f_last_name                  => p_isir_rec.f_last_name,
              x_mother_ssn                   => p_isir_rec.mother_ssn,
              x_m_last_name                  => p_isir_rec.m_last_name,
              x_p_num_family_member          => p_isir_rec.p_num_family_member,
              x_p_num_in_college             => p_isir_rec.p_num_in_college,
              x_p_state_legal_residence      => p_isir_rec.p_state_legal_residence,
              x_p_state_legal_res_before_dt  => p_isir_rec.p_state_legal_res_before_dt,
              x_p_legal_res_date             => p_isir_rec.p_legal_res_date,
              x_age_older_parent             => p_isir_rec.age_older_parent,
              x_p_tax_return_status          => p_isir_rec.p_tax_return_status,
              x_p_type_tax_return            => p_isir_rec.p_type_tax_return,
              x_p_elig_1040aez               => p_isir_rec.p_elig_1040aez,
              x_p_adjusted_gross_income      => p_isir_rec.p_adjusted_gross_income,
              x_p_taxes_paid                 => p_isir_rec.p_taxes_paid,
              x_p_exemptions                 => p_isir_rec.p_exemptions,
              x_f_income_work                => p_isir_rec.f_income_work,
              x_m_income_work                => p_isir_rec.m_income_work,
              x_p_income_wsa                 => p_isir_rec.p_income_wsa,
              x_p_income_wsb                 => p_isir_rec.p_income_wsb,
              x_p_income_wsc                 => p_isir_rec.p_income_wsc,
              x_p_investment_networth        => p_isir_rec.p_investment_networth,
              x_p_business_networth          => p_isir_rec.p_business_networth,
              x_p_cash_saving                => p_isir_rec.p_cash_saving,
              x_s_num_family_members         => p_isir_rec.s_num_family_members,
              x_s_num_in_college             => p_isir_rec.s_num_in_college,
              x_first_college                => p_isir_rec.first_college,
              x_first_house_plan             => p_isir_rec.first_house_plan,
              x_second_college               => p_isir_rec.second_college,
              x_second_house_plan            => p_isir_rec.second_house_plan,
              x_third_college                => p_isir_rec.third_college,
              x_third_house_plan             => p_isir_rec.third_house_plan,
              x_fourth_college               => p_isir_rec.fourth_college,
              x_fourth_house_plan            => p_isir_rec.fourth_house_plan,
              x_fifth_college                => p_isir_rec.fifth_college,
              x_fifth_house_plan             => p_isir_rec.fifth_house_plan,
              x_sixth_college                => p_isir_rec.sixth_college,
              x_sixth_house_plan             => p_isir_rec.sixth_house_plan,
              x_date_app_completed           => p_isir_rec.date_app_completed,
              x_signed_by                    => p_isir_rec.signed_by,
              x_preparer_ssn                 => p_isir_rec.preparer_ssn,
              x_preparer_emp_id_number       => p_isir_rec.preparer_emp_id_number,
              x_preparer_sign                => p_isir_rec.preparer_sign,
              x_transaction_receipt_date     => p_isir_rec.transaction_receipt_date,
              x_dependency_override_ind      => p_isir_rec.dependency_override_ind,
              x_faa_fedral_schl_code         => p_isir_rec.faa_fedral_schl_code,
              x_faa_adjustment               => p_isir_rec.faa_adjustment,
              x_input_record_type            => p_isir_rec.input_record_type,
              x_serial_number                => p_isir_rec.serial_number,
              x_batch_number                 => p_isir_rec.batch_number,
              x_early_analysis_flag          => p_isir_rec.early_analysis_flag,
              x_app_entry_source_code        => p_isir_rec.app_entry_source_code,
              x_eti_destination_code         => p_isir_rec.eti_destination_code,
              x_reject_override_b            => p_isir_rec.reject_override_b,
              x_reject_override_n            => p_isir_rec.reject_override_n,
              x_reject_override_w            => p_isir_rec.reject_override_w,
              x_assum_override_1             => p_isir_rec.assum_override_1,
              x_assum_override_2             => p_isir_rec.assum_override_2,
              x_assum_override_3             => p_isir_rec.assum_override_3,
              x_assum_override_4             => p_isir_rec.assum_override_4,
              x_assum_override_5             => p_isir_rec.assum_override_5,
              x_assum_override_6             => p_isir_rec.assum_override_6,
              x_dependency_status            => p_isir_rec.dependency_status,
              x_s_email_address              => p_isir_rec.s_email_address,
              x_nslds_reason_code            => p_isir_rec.nslds_reason_code,
              x_app_receipt_date             => p_isir_rec.app_receipt_date,
              x_processed_rec_type           => p_isir_rec.processed_rec_type,
              x_hist_correction_for_tran_id  => p_isir_rec.hist_correction_for_tran_id,
              x_system_generated_indicator   => p_isir_rec.system_generated_indicator,
              x_dup_request_indicator        => p_isir_rec.dup_request_indicator,
              x_source_of_correction         => p_isir_rec.source_of_correction,
              x_p_cal_tax_status             => p_isir_rec.p_cal_tax_status,
              x_s_cal_tax_status             => p_isir_rec.s_cal_tax_status,
              x_graduate_flag                => p_isir_rec.graduate_flag,
              x_auto_zero_efc                => p_isir_rec.auto_zero_efc,
              x_efc_change_flag              => p_isir_rec.efc_change_flag,
              x_sarc_flag                    => p_isir_rec.sarc_flag,
              x_simplified_need_test         => p_isir_rec.simplified_need_test,
              x_reject_reason_codes          => p_isir_rec.reject_reason_codes,
              x_select_service_match_flag    => p_isir_rec.select_service_match_flag,
              x_select_service_reg_flag      => p_isir_rec.select_service_reg_flag,
              x_ins_match_flag               => p_isir_rec.ins_match_flag,
              x_ins_verification_number      => NULL,
              x_sec_ins_match_flag           => p_isir_rec.sec_ins_match_flag,
              x_sec_ins_ver_number           => p_isir_rec.sec_ins_ver_number,
              x_ssn_match_flag               => p_isir_rec.ssn_match_flag,
              x_ssa_citizenship_flag         => p_isir_rec.ssa_citizenship_flag,
              x_ssn_date_of_death            => p_isir_rec.ssn_date_of_death,
              x_nslds_match_flag             => p_isir_rec.nslds_match_flag,
              x_va_match_flag                => p_isir_rec.va_match_flag,
              x_prisoner_match               => p_isir_rec.prisoner_match,
              x_verification_flag            => p_isir_rec.verification_flag,
              x_subsequent_app_flag          => p_isir_rec.subsequent_app_flag,
              x_app_source_site_code         => p_isir_rec.app_source_site_code,
              x_tran_source_site_code        => p_isir_rec.tran_source_site_code,
              x_drn                          => p_isir_rec.drn,
              x_tran_process_date            => p_isir_rec.tran_process_date,
              x_computer_batch_number        => p_isir_rec.computer_batch_number,
              x_correction_flags             => p_isir_rec.correction_flags,
              x_highlight_flags              => p_isir_rec.highlight_flags,
              x_paid_efc                     => p_isir_rec.paid_efc,
              x_primary_efc                  => p_isir_rec.primary_efc,
              x_secondary_efc                => p_isir_rec.secondary_efc,
              x_fed_pell_grant_efc_type      => p_isir_rec.fed_pell_grant_efc_type,
              x_primary_efc_type             => p_isir_rec.primary_efc_type,
              x_sec_efc_type                 => p_isir_rec.sec_efc_type,
              x_primary_alternate_month_1    => p_isir_rec.primary_alternate_month_1,
              x_primary_alternate_month_2    => p_isir_rec.primary_alternate_month_2,
              x_primary_alternate_month_3    => p_isir_rec.primary_alternate_month_3,
              x_primary_alternate_month_4    => p_isir_rec.primary_alternate_month_4,
              x_primary_alternate_month_5    => p_isir_rec.primary_alternate_month_5,
              x_primary_alternate_month_6    => p_isir_rec.primary_alternate_month_6,
              x_primary_alternate_month_7    => p_isir_rec.primary_alternate_month_7,
              x_primary_alternate_month_8    => p_isir_rec.primary_alternate_month_8,
              x_primary_alternate_month_10   => p_isir_rec.primary_alternate_month_10,
              x_primary_alternate_month_11   => p_isir_rec.primary_alternate_month_11,
              x_primary_alternate_month_12   => p_isir_rec.primary_alternate_month_12,
              x_sec_alternate_month_1        => p_isir_rec.sec_alternate_month_1,
              x_sec_alternate_month_2        => p_isir_rec.sec_alternate_month_2,
              x_sec_alternate_month_3        => p_isir_rec.sec_alternate_month_3,
              x_sec_alternate_month_4        => p_isir_rec.sec_alternate_month_4,
              x_sec_alternate_month_5        => p_isir_rec.sec_alternate_month_5,
              x_sec_alternate_month_6        => p_isir_rec.sec_alternate_month_6,
              x_sec_alternate_month_7        => p_isir_rec.sec_alternate_month_7,
              x_sec_alternate_month_8        => p_isir_rec.sec_alternate_month_8,
              x_sec_alternate_month_10       => p_isir_rec.sec_alternate_month_10,
              x_sec_alternate_month_11       => p_isir_rec.sec_alternate_month_11,
              x_sec_alternate_month_12       => p_isir_rec.sec_alternate_month_12,
              x_total_income                 => p_isir_rec.total_income,
              x_allow_total_income           => p_isir_rec.allow_total_income,
              x_state_tax_allow              => p_isir_rec.state_tax_allow,
              x_employment_allow             => p_isir_rec.employment_allow,
              x_income_protection_allow      => p_isir_rec.income_protection_allow,
              x_available_income             => p_isir_rec.available_income,
              x_contribution_from_ai         => p_isir_rec.contribution_from_ai,
              x_discretionary_networth       => p_isir_rec.discretionary_networth,
              x_efc_networth                 => p_isir_rec.efc_networth,
              x_asset_protect_allow          => p_isir_rec.asset_protect_allow,
              x_parents_cont_from_assets     => p_isir_rec.parents_cont_from_assets,
              x_adjusted_available_income    => p_isir_rec.adjusted_available_income,
              x_total_student_contribution   => p_isir_rec.total_student_contribution,
              x_total_parent_contribution    => p_isir_rec.total_parent_contribution,
              x_parents_contribution         => p_isir_rec.parents_contribution,
              x_student_total_income         => p_isir_rec.student_total_income,
              x_sati                         => p_isir_rec.sati,
              x_sic                          => p_isir_rec.sic,
              x_sdnw                         => p_isir_rec.sdnw,
              x_sca                          => p_isir_rec.sca,
              x_fti                          => p_isir_rec.fti,
              x_secti                        => p_isir_rec.secti,
              x_secati                       => p_isir_rec.secati,
              x_secstx                       => p_isir_rec.secstx,
              x_secea                        => p_isir_rec.secea,
              x_secipa                       => p_isir_rec.secipa,
              x_secai                        => p_isir_rec.secai,
              x_seccai                       => p_isir_rec.seccai,
              x_secdnw                       => p_isir_rec.secdnw,
              x_secnw                        => p_isir_rec.secnw,
              x_secapa                       => p_isir_rec.secapa,
              x_secpca                       => p_isir_rec.secpca,
              x_secaai                       => p_isir_rec.secaai,
              x_sectsc                       => p_isir_rec.sectsc,
              x_sectpc                       => p_isir_rec.sectpc,
              x_secpc                        => p_isir_rec.secpc,
              x_secsti                       => p_isir_rec.secsti,
              x_secsic                       => p_isir_rec.secsic,
              x_secsati                      => p_isir_rec.secsati,
              x_secsdnw                      => p_isir_rec.secsdnw,
              x_secsca                       => p_isir_rec.secsca,
              x_secfti                       => p_isir_rec.secfti,
              x_a_citizenship                => p_isir_rec.a_citizenship,
              x_a_student_marital_status     => p_isir_rec.a_student_marital_status,
              x_a_student_agi                => p_isir_rec.a_student_agi,
              x_a_s_us_tax_paid              => p_isir_rec.a_s_us_tax_paid,
              x_a_s_income_work              => p_isir_rec.a_s_income_work,
              x_a_spouse_income_work         => p_isir_rec.a_spouse_income_work,
              x_a_s_total_wsc                => p_isir_rec.a_s_total_wsc,
              x_a_date_of_birth              => p_isir_rec.a_date_of_birth,
              x_a_student_married            => p_isir_rec.a_student_married,
              x_a_have_children              => p_isir_rec.a_have_children,
              x_a_s_have_dependents          => p_isir_rec.a_s_have_dependents,
              x_a_va_status                  => p_isir_rec.a_va_status,
              x_a_s_num_in_family            => p_isir_rec.a_s_num_in_family,
              x_a_s_num_in_college           => p_isir_rec.a_s_num_in_college,
              x_a_p_marital_status           => p_isir_rec.a_p_marital_status,
              x_a_father_ssn                 => p_isir_rec.a_father_ssn,
              x_a_mother_ssn                 => p_isir_rec.a_mother_ssn,
              x_a_parents_num_family         => p_isir_rec.a_parents_num_family,
              x_a_parents_num_college        => p_isir_rec.a_parents_num_college,
              x_a_parents_agi                => p_isir_rec.a_parents_agi,
              x_a_p_us_tax_paid              => p_isir_rec.a_p_us_tax_paid,
              x_a_f_work_income              => p_isir_rec.a_f_work_income,
              x_a_m_work_income              => p_isir_rec.a_m_work_income,
              x_a_p_total_wsc                => p_isir_rec.a_p_total_wsc,
              x_comment_codes                => p_isir_rec.comment_codes,
              x_sar_ack_comm_code            => p_isir_rec.sar_ack_comm_code,
              x_pell_grant_elig_flag         => p_isir_rec.pell_grant_elig_flag,
              x_reprocess_reason_code        => p_isir_rec.reprocess_reason_code,
              x_duplicate_date               => p_isir_rec.duplicate_date,
              x_isir_transaction_type        => p_isir_rec.isir_transaction_type,
              x_fedral_schl_code_indicator   => p_isir_rec.fedral_schl_code_indicator,
              x_multi_school_code_flags      => p_isir_rec.multi_school_code_flags,
              x_dup_ssn_indicator            => p_isir_rec.dup_ssn_indicator,
              x_system_record_type           => p_isir_rec.system_record_type,
              x_payment_isir                 => p_isir_rec.payment_isir,
              x_receipt_status               => p_isir_rec.receipt_status,
              x_isir_receipt_completed       => p_isir_rec.isir_receipt_completed,
              x_active_isir                  => p_isir_rec.active_isir,
              x_fafsa_data_verify_flags      => p_isir_rec.fafsa_data_verify_flags,
              x_reject_override_a            => p_isir_rec.reject_override_a,
              x_reject_override_c            => p_isir_rec.reject_override_c,
              x_parent_marital_status_date   => p_isir_rec.parent_marital_status_date,
              x_legacy_record_flag           => p_isir_rec.legacy_record_flag,
              x_verif_track_flag             => p_isir_rec.verif_track_flag,
              x_father_first_name_initial    => p_isir_rec.father_first_name_initial_txt,
              x_father_step_father_birth_dt  => p_isir_rec.father_step_father_birth_date,
              x_mother_first_name_initial    => p_isir_rec.mother_first_name_initial_txt,
              x_mother_step_mother_birth_dt  => p_isir_rec.mother_step_mother_birth_date,
              x_parents_email_address_txt    => p_isir_rec.parents_email_address_txt,
              x_address_change_type          => p_isir_rec.address_change_type,
              x_cps_pushed_isir_flag         => p_isir_rec.cps_pushed_isir_flag,
              x_electronic_transaction_type  => p_isir_rec.electronic_transaction_type,
              x_sar_c_change_type            => p_isir_rec.sar_c_change_type,
              x_father_ssn_match_type        => p_isir_rec.father_ssn_match_type,
              x_mother_ssn_match_type        => p_isir_rec.mother_ssn_match_type,
              x_reject_override_g_flag       => p_isir_rec.reject_override_g_flag,
              x_dhs_verification_num_txt     => p_isir_rec.dhs_verification_num_txt,
              x_data_file_name_txt           => p_isir_rec.data_file_name_txt ,
              x_message_class_txt            => p_isir_rec.message_class_txt,
              x_reject_override_3_flag       => p_isir_rec.reject_override_3_flag,
              x_reject_override_12_flag      => p_isir_rec.reject_override_12_flag,
              x_reject_override_j_flag       => p_isir_rec.reject_override_j_flag,
              x_reject_override_k_flag       => p_isir_rec.reject_override_k_flag,
              x_rejected_status_change_flag  => p_isir_rec.rejected_status_change_flag,
              x_verification_selection_flag  => p_isir_rec.verification_selection_flag
              );
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.update_correction_isir.debug','igf_ap_isir_matched_pkg.update_row successfull');
        END IF;

  EXCEPTION
    WHEN OTHERS THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
       FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_BATCH_VER_PRC.UPDATE_CORRECTION_ISIR '||SQLERRM);
       IGS_GE_MSG_STACK.ADD;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.update_correction_isir.debug',SQLERRM);
        END IF;
       APP_EXCEPTION.RAISE_EXCEPTION;
  END update_correction_isir;


  FUNCTION l_incomplete(p_base_id igf_ap_fa_base_rec_all.base_id%TYPE ) RETURN BOOLEAN IS

    /*
    ||  Created By : rasingh
    ||  Created On : 06-July-2001
    ||  Purpose : This function checks the all verification item values, if any item having null values
    ||  than it sets the incomplete status and returns true or false.
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    CURSOR cur_get_ver_data (pn_base_id NUMBER) IS
    SELECT COUNT(ivi.isir_map_col)
      FROM igf_ap_inst_ver_item ivi
     WHERE ivi.base_id = pn_base_id
       AND ivi.waive_flag <> 'Y'
       AND ( ivi.item_value IS NULL AND NVL(USE_BLANK_FLAG,'N') <> 'Y' )
       AND rownum = 1;

    lv_flag          NUMBER := 0;
    lv_ver_status    igf_ap_fa_base_rec_all.fed_verif_status%TYPE;
    lb_return_status BOOLEAN;

  BEGIN

    OPEN cur_get_ver_data (p_base_id);
    FETCH cur_get_ver_data INTO lv_flag;
    CLOSE cur_get_ver_data;

    IF lv_flag >  0 THEN
      FND_MESSAGE.SET_NAME('IGF','IGF_AP_INCOMPLETE_DOC_VAL');
      FND_FILE.PUT_LINE(FND_FILE.LOG,fnd_message.get);
      lb_return_status := TRUE;
    ELSE
      lb_return_status := FALSE;
    END IF;

    RETURN lb_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      IF cur_get_ver_data%ISOPEN THEN
        CLOSE cur_get_ver_data;
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_BATCH_VER_PRC.l_incomplete '||SQLERRM);
      IGS_GE_MSG_STACK.ADD;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.l_incomplete.debug',SQLERRM);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END l_incomplete;


  PROCEDURE  l_create_corr_record(
                                  pn_base_id igf_ap_fa_base_rec.base_id%TYPE ,
                                  pn_isir_id igf_ap_isir_matched.isir_id%TYPE ,
                                  pv_isir_map_column igf_ap_inst_ver_item.isir_map_col%TYPE,
                                  pv_cal_type igs_ca_inst.cal_type%TYPE,
                                  pn_sequence_number igs_ca_inst.sequence_number%TYPE,
                                  pv_retval VARCHAR2,
                                  pv_item_value  igf_ap_inst_ver_item.item_value%TYPE,
                                  pv_mode VARCHAR2
                                 ) IS

    lv_rowid        VARCHAR2(30);
    ln_isirc_id     igf_ap_isir_corr.isirc_id%TYPE;

    CURSOR upd_corr_cur IS
    SELECT corr.*,corr.rowid
      FROM igf_ap_isir_corr corr
     WHERE isir_id = pn_isir_id
       AND sar_field_number = pv_isir_map_column;

  BEGIN

    IF pv_mode = 'INSERT' THEN

        igf_ap_isir_corr_pkg.insert_row
        (
         X_ROWID                => lv_rowid,
         X_ISIRC_ID             => ln_isirc_id,
         X_ISIR_ID              => pn_isir_id,
         X_CI_SEQUENCE_NUMBER   => pn_sequence_number,
         X_CI_CAL_TYPE          => pv_cal_type,
         X_SAR_FIELD_NUMBER     => pv_isir_map_column,
         X_ORIGINAL_VALUE       => pv_retval,
         X_BATCH_ID             => NULL,
         X_CORRECTED_VALUE      => pv_item_value,
         X_CORRECTION_STATUS    => NVL(l_new_corr_status,'READY'),
         X_MODE                 => 'R'
        );
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.l_create_corr_record.debug','igf_ap_isir_corr_pkg.insert_row successfull with values ');
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.l_create_corr_record.debug','Values : ln_isirc_id/pn_isir_id/pn_sequence_number : '||ln_isirc_id||' / '||pn_isir_id||' / '||pn_sequence_number);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.l_create_corr_record.debug','Values : pv_cal_type/pv_isir_map_column/pv_retval/pv_item_value'||pv_cal_type||'/'||pv_isir_map_column||'/'||pv_retval||'/'||pv_item_value);
        END IF;
    ELSIF pv_mode = 'UPDATE' THEN
      FOR corr_upd_rec IN upd_Corr_cur LOOP
        igf_ap_isir_corr_pkg.update_row
        (
         X_ROWID                => corr_upd_rec.rowid,
         X_ISIRC_ID             => corr_upd_rec.isirc_id,
         X_ISIR_ID              => corr_upd_rec.isir_id,
         X_CI_SEQUENCE_NUMBER   => corr_upd_rec.ci_sequence_number,
         X_CI_CAL_TYPE          => corr_upd_rec.ci_cal_type,
         X_SAR_FIELD_NUMBER     => corr_upd_rec.sar_field_number,
         X_ORIGINAL_VALUE       => pv_retval,
         X_BATCH_ID             => NULL,
         X_CORRECTED_VALUE      => pv_item_value,
         X_CORRECTION_STATUS    => l_new_corr_status,
         X_MODE                 => 'R'
        );
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.l_create_corr_record.debug','igf_ap_isir_corr_pkg.update_row successfull');
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.l_create_corr_record.debug','Values : corr_upd_rec.rowid / corr_upd_rec.isirc_id : '||corr_upd_rec.rowid||' / '||corr_upd_rec.isirc_id);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.l_create_corr_record.debug','Values : corr_upd_rec.isir_id / corr_upd_rec.ci_sequence_number : '||corr_upd_rec.isir_id||' / '||corr_upd_rec.ci_sequence_number);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.l_create_corr_record.debug','Values : corr_upd_rec.ci_cal_type / corr_upd_rec.sar_field_number : '||corr_upd_rec.ci_cal_type||' / '||corr_upd_rec.sar_field_number);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.l_create_corr_record.debug','Values : pv_retval / pv_item_value / l_new_corr_status : '||pv_retval / pv_item_value||' / '||l_new_corr_status);
        END IF;
     END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_BATCH_VER_PRC.L_CREATE_CORR_RECORD '||SQLERRM);
      IGS_GE_MSG_STACK.ADD;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.l_create_corr_record.debug',SQLERRM);
      END IF;
      RETURN;
  END l_create_corr_record;


  PROCEDURE l_validate_data ( pn_base_id                     IN igf_ap_fa_base_rec.base_id%TYPE,
                              pv_isir_id                     IN igf_ap_isir_matched.isir_id%TYPE,
                              pv_item_value                  IN igf_ap_inst_ver_item.item_value%TYPE,
                              pv_column_name                 IN igf_fc_sar_cd_mst.sar_field_name%TYPE, --gets the SAR Field name
                              pv_isir_map_column             IN igf_ap_inst_ver_item.isir_map_col%TYPE,
                              pv_ci_cal_type                 IN igf_ap_fa_base_rec.ci_cal_type%TYPE,
                              pv_ci_sequence_number          IN igf_ap_fa_base_rec.ci_sequence_number%TYPE ,
                              pv_update_ssn                  IN OUT NOCOPY VARCHAR2
                            ) IS
    /*
    ||  Created By : rasingh
    ||  Created On : 05-Dec-2000
    ||  Purpose : This procedure validates verification value to ISIR record value and
    ||  creates the correction record if those values are not same.
    ||  Change History :
    ||  Who             When            What
    ||  masehgal        14-May-2003     # 2885882 FACR113 SAR Updates
    ||                                  changed cursors
    ||  (reverse chronological order - newest change first)
    */

    lv_cur               PLS_INTEGER;
    lv_retval            igf_ap_isir_corr.original_value%TYPE;
    lv_stmt              VARCHAR2(2000);
    lv_rows              integer;
    ln_isir_id           igf_ap_isir_matched.isir_id%TYPE     := pv_isir_id;
    lv_cal_type          igs_ca_inst.cal_type%TYPE            := pv_ci_cal_type;
    ln_sequence_number   igs_ca_inst.sequence_number%TYPE     := pv_ci_sequence_number;
    lv_item_value        igf_ap_inst_ver_item.item_value%TYPE;
    l_mode               VARCHAR2(30);

    CURSOR cur_get_sar_field_desc (pv_column_name  igf_fc_sar_cd_mst.sar_field_name%TYPE,
                                   pv_lookup_type  VARCHAR2)  IS
       SELECT lkup.meaning
         FROM igf_lookups_view  lkup
        WHERE lkup.lookup_type   = pv_lookup_type
          AND lkup.lookup_code   = pv_column_name
          AND lkup.enabled_flag  = 'Y' ;

    l_column_name    igf_fc_sar_cd_mst.sar_field_name%TYPE ;
    l_lookup_type    VARCHAR2(60) ;
    l_sar_col_desc   igf_lookups_view.meaning%TYPE ;

  BEGIN

   IF pv_column_name <> 'S_EMAIL_ADDRESS' THEN

    lv_item_value := pv_item_value;

    -- Get the isir_id of the latest ISIR for the student
    IF pv_isir_id IS NULL THEN
      fnd_message.set_name('IGF','IGF_AP_NO_ISIR_RECS_EXIST');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.l_create_corr_record.debug','No ISIR record exists');
      END IF;
    ELSE

      IF pv_column_name IS NOT NULL THEN
        lv_cur  := DBMS_SQL.OPEN_CURSOR;
        lv_stmt := 'SELECT '||pv_column_name ||' FROM igf_ap_isir_matched where isir_id =  '||to_char(pv_isir_id);

        DBMS_SQL.PARSE(lv_cur,lv_stmt,2);
        DBMS_SQL.DEFINE_COLUMN(lv_cur,1,lv_retval,30);
        lv_rows := DBMS_SQL.EXECUTE_AND_FETCH(lv_cur);
        DBMS_SQL.COLUMN_VALUE(lv_cur,1,lv_retval);
        DBMS_SQL.CLOSE_CURSOR(lv_cur);
      END IF;

      -- Processing for String Values.
      IF UPPER(LTRIM(RTRIM(NVL(lv_retval,'#')))) <> UPPER(LTRIM(RTRIM(NVL(lv_item_value,'#')))) THEN
        ln_corr_count := ln_corr_count + 1;
        IF l_chk_dup_corr (ln_isir_id,TO_NUMBER(pv_isir_map_column),lv_item_value,l_mode) THEN
          l_lookup_type := 'IGF_AP_SAR_FIELD_MAP';
          OPEN  cur_get_sar_field_desc ( pv_column_name , l_lookup_type) ;
          FETCH cur_get_sar_field_desc  INTO  l_sar_col_desc ;
          CLOSE cur_get_sar_field_desc ;

          fnd_message.set_name('IGF','IGF_AP_CORR_REC_CREATED');
          fnd_message.set_token ('ITEM',l_sar_col_desc );
          fnd_file.put_line(fnd_file.log, '   ' || fnd_message.get);
          l_create_corr_record ( pn_base_id,ln_isir_id,pv_isir_map_column,lv_cal_type, ln_sequence_number, lv_retval,lv_item_value,l_mode);

          -- Update the Correction ISIR with the correction Value
          EXECUTE IMMEDIATE  'BEGIN igf_ap_batch_ver_prc_pkg.lp_isir_rec.'
                            || pv_column_name || ' := ' ||  '''' || lv_item_value || '''' || ' ; END;' ;

          -- Check if the SSN is getting updated
          IF pv_column_name = 'CURRENT_SSN' THEN
            pv_update_ssn := 'Y' ;
          END IF;
        END IF;
      END IF;

    END IF; -- End of ISIR IS NULL
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_BATCH_VER_PRC.L_VALIDATE_DATA '||SQLERRM);
      igs_ge_msg_stack.add;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.l_validate_data.debug',SQLERRM);
      END IF;
      RETURN;
  END l_validate_data;


  PROCEDURE main (
                  errbuf  OUT NOCOPY VARCHAR2,
                  retcode OUT NOCOPY NUMBER,
                  p_award_year VARCHAR2,
                  p_org_id IN NUMBER
                ) IS
    /**********************************************************
    Created By :
    Date Created By :
    Purpose :
    Know limitations, enhancements or remarks

    Change History
    Who           When            What
    bkkumar       05-Dec-2003     Bug# 3240804 Removed the base_id parameter.
                                  Enforced the validation of when student has
                                  any correction items = Batched (or Verification
                                  Process Status = Corrections Sent) then no
                                  correction items can be created
    masehgal      14-May-2003     # 2885882 FACR113 SAR Updates
                                  changed cursor cur_get_ver_data, call to validate_data
    smvk         04-Feb-2003      Removed the status 'INCOMPLETE' from the cursor cur_selected_rec.
                                  As per Enh Bug # 2758812.
    (reverse chronological order - newest change first)
    ***************************************************************/

    CURSOR cur_selected_rec (lv_ci_cal_type        VARCHAR2,
                             lv_ci_sequence_number NUMBER)  IS
    SELECT far.base_id,
           far.ci_cal_type,
           far.ci_sequence_number,
           far.person_id,
           pe.party_number person_number,
           pe.person_first_name given_names,
           pe.person_last_name surname,
           im.isir_id
      FROM igf_ap_fa_base_rec_all far,
           igf_ap_isir_matched_all im,
           hz_parties             pe
     WHERE far.person_id          = pe.party_id
       AND far.ci_cal_type        = NVL(lv_ci_cal_type,far.ci_cal_type)
       AND far.ci_sequence_number = NVL(lv_ci_sequence_number, far.ci_sequence_number)
       AND far.fed_verif_status IN ('SELECTED', 'NOTVERIFIED')
       AND far.base_id = im.base_id
       AND im.system_record_type = 'ORIGINAL'
       AND im.payment_isir = 'Y';


    CURSOR cur_chk_batched ( cp_base_id     igf_ap_isir_matched_all.base_id%TYPE,
                             cp_corr_status igf_ap_isir_corr_all.correction_status%TYPE
                           )
    IS
    SELECT isir.base_id
    FROM   igf_ap_isir_matched_all isir,
           igf_ap_isir_corr_all    corr
    WHERE  isir.base_id = cp_base_id
    AND    isir.isir_id = corr.isir_id
    AND    NVL(corr.correction_status,'X') = cp_corr_status;

    l_cur_chk_batched   cur_chk_batched%ROWTYPE;

    CURSOR cur_get_ver_data ( pn_base_id    NUMBER ) IS
    SELECT ivi.base_id, ivi.udf_vern_item_seq_num, ivi.item_value, ivi.isir_map_col,
           ivi.incl_in_tolerance, sar.sar_field_name  column_name
      FROM igf_ap_batch_aw_map    map,
           igf_ap_fa_base_rec_all fabase,
           igf_ap_inst_ver_item   ivi,
           Igf_fc_sar_cd_mst      sar
     WHERE fabase.base_id         = pn_base_id
       AND map.ci_cal_type        = fabase.ci_cal_type
       AND map.ci_sequence_number = fabase.ci_sequence_number
       AND ivi.base_id            = pn_base_id
       AND sar.sys_award_year     = map.sys_award_year
       AND sar.sar_field_number   = ivi.isir_map_col
       AND ivi.waive_flag         <> 'Y'
       AND ( (ivi.item_value IS NOT NULL) OR
             (ivi.item_value IS NULL AND NVL(USE_BLANK_FLAG,'N') = 'Y' )
           );

    CURSOR cur_get_ver_item_count(
                                  cp_base_id  igf_ap_fa_base_rec_all.base_id%TYPE
                                 ) IS
    SELECT ivi.base_id
      FROM igf_ap_inst_ver_item   ivi
     WHERE ivi.base_id            = cp_base_id
       AND ivi.waive_flag         <> 'Y'
       AND ( (ivi.item_value IS NOT NULL) OR
             (ivi.item_value IS NULL AND NVL(USE_BLANK_FLAG,'N') = 'Y' )
           )
       AND rownum = 1;

    lc_get_ver_item_count  cur_get_ver_item_count%ROWTYPE;

    CURSOR c_correction_isir ( cp_base_id igf_ap_fa_base_rec.base_id%TYPE) IS
    SELECT *
      FROM igf_ap_isir_matched
     WHERE BASE_ID = cp_base_id
       AND SYSTEM_RECORD_TYPE = 'CORRECTION';

    CURSOR c_get_sys_year(
                          cp_cal_type VARCHAR2,
                          cp_sequence_number NUMBER
                         ) IS
    SELECT sys_award_year
      FROM igf_ap_batch_aw_map
     WHERE ci_cal_type = cp_cal_type
       AND ci_sequence_number = cp_sequence_number ;

    lv_get_sys_year c_get_sys_year%ROWTYPE;

    rec_selected            cur_selected_rec%ROWTYPE ;
    rec_get_ver_data        cur_get_ver_data%ROWTYPE ;
    lv_ci_cal_type          IGS_CA_INST.CAL_TYPE%TYPE;
    lv_ci_sequence_number   IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
    lv_ver_status           VARCHAR2(30);
    ln_tot_count            NUMBER(15);
    lv_efc_isir_rec         igf_ap_isir_matched%ROWTYPE;
    p_efc_ret_status        VARCHAR2(30);
    p_msg_count             NUMBER;
    p_msg_text              VARCHAR2(2000);
    lv_update_ssn           VARCHAR2(1);
    SKIP_STUDENT            EXCEPTION;
    ln_corr_isir_id         igf_ap_isir_matched_all.isir_id%TYPE;


  BEGIN

    igf_aw_gen.set_org_id(p_org_id);
    lv_ci_cal_type := RTRIM(SUBSTR(p_award_year,1,10));
    lv_ci_sequence_number := TO_NUMBER(RTRIM(SUBSTR(p_award_year,11)));

    -- Retrieve the System Award Year
    OPEN c_get_sys_year(lv_ci_cal_type,lv_ci_sequence_number);
    FETCH c_get_sys_year INTO lv_get_sys_year;
    CLOSE c_get_sys_year ;

    -- Initialize Count variables:
    ln_tot_count          := 0;
    ln_tot_no_corr_count  := 0;
    ln_tot_corr_count     := 0;

    -- Start the process by getting all the students for which
    -- the verification process is initiated.
    FOR rec_selected IN cur_selected_rec(lv_ci_cal_type, lv_ci_sequence_number) LOOP

      fnd_message.set_name('IGF','IGF_AP_PROCESSING_STUDENT');
      fnd_message.set_token ('PERSON_NAME',rec_selected.given_names  ||' '||rec_selected.surname);
      fnd_message.set_token ('PERSON_NUMBER',rec_selected.person_number);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.main.debug','Procssing student '||rec_selected.given_names  ||' '||rec_selected.surname );
      END IF;
      ln_tot_count := ln_tot_count + 1;

      l_cur_chk_batched := NULL;
      OPEN  cur_chk_batched(rec_selected.base_id,'BATCHED');
      FETCH cur_chk_batched INTO l_cur_chk_batched;
      CLOSE cur_chk_batched;

      -- Run this process only for those records for which the item value is present. l_incomplete will return TRUE if all the verification items have some value.
      IF( l_cur_chk_batched.base_id IS NULL AND (NOT l_incomplete(rec_selected.base_id)) ) THEN

        ln_corr_count    := 0;
        ln_no_corr_count := 0;

        -- Load the current Active Correction ISIR for the Student
        -- Initialize the pkg rowtype to Null , Note this is used for dynamic update of correction ISIR.
        BEGIN

          SAVEPOINT IGFAP08B_SP;

          -- If Verifications Items are not present for the student, then log a message and skip the student.
          -- If Verification items are present then proceed further
          OPEN cur_get_ver_item_count(rec_selected.base_id);
          FETCH cur_get_ver_item_count INTO lc_get_ver_item_count;
          IF cur_get_ver_item_count%NOTFOUND THEN
            CLOSE cur_get_ver_item_count;
            fnd_message.set_name('IGF','IGF_AP_STDNT_SKIP_NO_VERIF');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            fnd_file.new_line(fnd_file.log,2);
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.main.debug','No verification items present , Therefore skipping the student');
            END IF;
            RAISE SKIP_STUDENT;
          ELSE
            CLOSE cur_get_ver_item_count;
          END IF;

          -- If Correction ISIR is already present, then update the Correction ISIR with the Verificaiton items
          -- else create the Correction ISIR and then update the Correction ISIR with the Verificaiton Items
          igf_ap_batch_ver_prc_pkg.lp_isir_rec :=  NULL;
          OPEN c_correction_isir(rec_selected.base_id);
          FETCH c_correction_isir INTO igf_ap_batch_ver_prc_pkg.lp_isir_rec;
          IF c_correction_isir%FOUND THEN
            CLOSE c_correction_isir ;

          ELSIF c_correction_isir%NOTFOUND THEN
            CLOSE c_correction_isir;

            -- Create the CORRECTION ISIR
            ln_corr_isir_id := NULL;
            create_correction_isir( rec_selected.base_id, ln_corr_isir_id );
            IF ln_corr_isir_id IS NULL THEN
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.main.debug','Could not create correction record, Therefore skipping the student');
              END IF;
              RAISE SKIP_STUDENT;
            END IF;

            -- Fetch the Correction ISIR and add the Verifiaction items
            igf_ap_batch_ver_prc_pkg.lp_isir_rec :=  NULL;
            OPEN c_correction_isir(rec_selected.base_id);
            FETCH c_correction_isir INTO igf_ap_batch_ver_prc_pkg.lp_isir_rec;
            CLOSE c_correction_isir ;

          END IF;

          --
          -- For the selected student, start processing the Verification Items.
          --
          lv_update_ssn := 'N' ;

          FOR rec_get_ver_data IN cur_get_ver_data (rec_selected.base_id) LOOP
             l_validate_data ( pn_base_id            => rec_get_ver_data.base_id,
                               pv_isir_id            => rec_selected.isir_id,
                               pv_item_value         => rec_get_ver_data.item_value,
                               pv_column_name        => rec_get_ver_data.column_name, -- we are now passing the SAR Field name as in the Seed Table
                               pv_isir_map_column    => rec_get_ver_data.isir_map_col,
                               pv_ci_cal_type        => rec_selected.ci_cal_type,
                               pv_ci_sequence_number => rec_selected.ci_sequence_number,
                               pv_update_ssn         => lv_update_ssn
                             );
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.main.debug','l_validate_data sucessfull');
              END IF;
          END LOOP;

          -- Compute EFC Against the updated correction ISIR
          lv_efc_isir_rec := igf_ap_batch_ver_prc_pkg.lp_isir_rec ;

          FND_MSG_PUB.Initialize ;

          -- Call EFC Calculation with Ignore Warnings set to 'N'
          igf_ap_efc_calc.calculate_efc(
                                    p_isir_rec         => lv_efc_isir_rec,
                                    p_ignore_warnings  => 'N',
                                    p_sys_batch_yr     => lv_get_sys_year.sys_award_year,
                                    p_return_status    => p_efc_ret_status
                                   );
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.main.debug','igf_ap_efc_calc.calculate_efc sucessfull');
          END IF;

          IF  p_efc_ret_status = 'W' THEN
            -- Computation stopped with Warnings.
            -- So re-submit with Ignore Warnings
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.main.debug','EFC Computation stopped with Warnings.So re-submit with Ignore Warnings');
            END IF;

            igf_ap_efc_calc.calculate_efc(
                                    p_isir_rec         => lv_efc_isir_rec,
                                    p_ignore_warnings  => 'Y',
                                    p_sys_batch_yr     => lv_get_sys_year.sys_award_year,
                                    p_return_status    => p_efc_ret_status
                                   );
             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.main.debug','igf_ap_efc_calc.calculate_efc sucessfull');
             END IF;
          END IF;

          -- Now check the final return value of p_efc_ret_status
          IF p_efc_ret_status = 'S' THEN

            IF ln_corr_count = 0 THEN

              lv_ver_status := 'ACCURATE';

              -- Update FA Process Status in FA Base Record.
              igf_ap_batch_ver_prc_pkg.update_process_status (rec_selected.base_id,lv_ver_status);
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.main.debug','Updated FA Process Status in FA Base Record');
              END IF;
              ln_tot_no_corr_count := ln_tot_no_corr_count+1;
              fnd_message.set_name ('IGF','IGF_AP_VER_STAT_ACCURATE');
              fnd_file.put_line(fnd_file.log,fnd_message.get);

            ELSIF ln_corr_count <> 0 THEN

               --  Update the Correction ISIR with Correction Items Values in Federal Verification Worksheet.
               --  Note since we have loaded all the corrections into lv_efc_isir_rec Just pass this rowtype variable
               --  For Update of Correction ISIR.
               update_correction_isir (pn_base_id   => rec_selected.base_id,
                                       p_isir_rec   => lv_efc_isir_rec,
                                       p_update_ssn => lv_update_ssn );
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.main.debug','Correction Records were created for the student and Verification Process Status set to Corrections Sent');
               END IF;
               ln_tot_corr_count := ln_tot_corr_count + 1;
             END IF;

          ELSE
            -- Efc failed due to errors.
            -- PRINT ALL ERRORS
            p_msg_count := FND_MSG_PUB.Count_Msg();

            IF NVL(p_msg_count,0) > 0 THEN
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.main.debug','EFC computation for the context student has failed.');
              END IF;
              FND_MESSAGE.SET_NAME('IGF','IGF_AP_EFC_FAIL');
              FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

              FOR i in 1..p_msg_count LOOP
                p_msg_text := fnd_msg_pub.get(i,'F');
                FND_FILE.PUT_LINE(FND_FILE.LOG, '   ' || TO_CHAR(i) || '.' || p_msg_text);
              END LOOP;
            END IF;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.main.debug','Since EFC could not be computed with given correction items, No correction item has been created for this Student.');
            END IF;
            FND_MESSAGE.SET_NAME('IGF','IGF_AP_CORR_SKIP');
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            ROLLBACK TO IGFAP08B_SP;

          END IF;

          fnd_file.put_line(fnd_file.log,RPAD('-',100,'-'));

        EXCEPTION
          WHEN SKIP_STUDENT THEN
            NULL;

          WHEN OTHERS THEN
            fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
            fnd_message.set_token('NAME','IGF_AP_BATCH_VER_PRC.MAIN-INNER '||SQLERRM);
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            FND_MESSAGE.SET_NAME('IGF','IGF_AP_CORR_SKIP');
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.main-inner.debug',SQLERRM);
            END IF;
            ROLLBACK TO IGFAP08B_SP;
        END;
      ELSE
         IF l_cur_chk_batched.base_id IS NOT NULL THEN
            fnd_message.set_name('IGF','IGF_AP_COR_BATCH_EXIST');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
         END IF;
        fnd_file.put_line(fnd_file.log,RPAD('-',100,'-'));

      END IF;

    END LOOP;

    IF ln_tot_count = 0 THEN
      fnd_message.set_name('IGF','IGF_AP_MATCHING_REC_NT_FND');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
    END IF;

    fnd_message.set_name('IGF','IGF_AP_TOTAL_RECS');
    fnd_message.set_token('COUNT',TO_CHAR(ln_tot_count));
    fnd_file.put_line(fnd_file.output,fnd_message.get);

    fnd_message.set_name('IGF','IGF_AP_COMPLETED_RECS');
    fnd_message.set_token('COUNT',TO_CHAR(ln_tot_count-ln_tot_corr_count));
    fnd_file.put_line(fnd_file.output,fnd_message.get);

    fnd_message.set_name('IGF','IGF_AP_CORR_RECS');
    fnd_message.set_token('COUNT',TO_CHAR(ln_tot_corr_count));
    fnd_file.put_line(fnd_file.output,fnd_message.get);

    retcode := 0;
  EXCEPTION
    WHEN others THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_BATCH_VER_PRC.main');
      igs_ge_msg_stack.add;
      igs_ge_msg_stack.conc_exception_hndl;
      fnd_file.put_line(fnd_file.log,'ERROR: '||SQLERRM);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.main.debug',SQLERRM);
      END IF;
      app_exception.raise_exception;
  END main;


  PROCEDURE update_process_status(
                                  p_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
                                  p_fed_verif_status igf_ap_fa_base_rec_all.fed_verif_status%TYPE
                                 ) IS

    CURSOR cur_todo(
                    p_base_id   igf_ap_fa_base_rec_all.base_id%TYPE,
                    p_person_id igf_ap_fa_base_rec_all.person_id%TYPE
                   ) IS
    SELECT 1
      FROM igf_ap_td_item_inst_all tdinst,
           igf_ap_td_item_mst_all tdmst
     WHERE tdinst.base_id = p_base_id
       AND tdinst.status IN ('INC','REQ','REC')
       AND tdinst.required_for_application = 'Y'
       AND NVL(tdinst.inactive_flag,'N') <> 'Y'
       AND tdinst.item_sequence_number = tdmst.todo_number
       AND tdmst.career_item = 'N'
       AND ROWNUM < 2
    UNION
    SELECT 1
      FROM igf_ap_td_item_inst_all tdinst,
           igf_ap_td_item_mst_all tdmst,
           igf_ap_fa_base_rec_all fa
     WHERE tdinst.base_id = fa.base_id
       AND tdinst.status IN ('INC','REQ','REC')
       AND tdinst.required_for_application = 'Y'
       AND NVL(tdinst.inactive_flag,'N') <> 'Y'
       AND tdinst.item_sequence_number = tdmst.todo_number
       AND tdmst.career_item = 'Y'
       AND fa.person_id = p_person_id
       AND ROWNUM < 2;

    CURSOR cur_ver_status ( p_base_id igf_ap_fa_base_rec_all.base_id%TYPE) IS
    SELECT fed_verif_status, NVL(fa_process_status,'RECEIVED') fa_process_status
      FROM igf_ap_fa_base_rec
     WHERE base_id = p_base_id;

    ln_count_open_items  NUMBER;
    l_person_id          hz_parties.party_id%TYPE;
    lv_fed_verif_status  igf_ap_fa_base_rec_all.fed_verif_status%TYPE;
    lv_fa_process_status igf_ap_fa_base_rec_all.fa_process_status%TYPE;
    ln_auto_na_complete  VARCHAR2(80);

    -- Get person_id
    CURSOR c_person_id(
                       cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                      ) IS
      SELECT person_id
        FROM igf_ap_fa_base_rec_all
       WHERE base_id = cp_base_id;

  BEGIN

    -- Initialise the global
    g_disb_hold := 'N';

    OPEN c_person_id(p_base_id);
    FETCH c_person_id INTO l_person_id;
    CLOSE c_person_id;

    fnd_profile.get('IGF_AP_MANUAL_REVIEW_APPL',ln_auto_na_complete);
    ln_auto_na_complete := NVL(ln_auto_na_complete,'N');

    OPEN cur_ver_status ( p_base_id);
    FETCH cur_ver_status INTO lv_fed_verif_status,lv_fa_process_status;
    IF cur_ver_status%NOTFOUND THEN
      CLOSE cur_ver_status;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','FA BASE DOES NOT EXIST');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE cur_ver_status;

    OPEN cur_todo ( p_base_id,l_person_id);
    FETCH cur_todo INTO ln_count_open_items;
    IF cur_todo%NOTFOUND THEN
      ln_count_open_items := 0;
    ELSE
      ln_count_open_items := 1;
    END IF;
    CLOSE cur_todo;

    IF lv_fa_process_status = 'RECEIVED' AND  ln_count_open_items = 0 THEN
      IF ln_auto_na_complete = 'Y' THEN
        lv_fa_process_status := 'MANUAL_REVIEW';
      ELSE
        lv_fa_process_status := 'COMPLETE';
      END IF;

    ELSIF ln_count_open_items > 0 THEN
      lv_fa_process_status := 'RECEIVED';

    END IF;

    IF p_fed_verif_status = 'REPROCESSED' AND  lv_fed_verif_status <>  'REPROCESSED' THEN
      g_disb_hold := 'Y';
    END IF;

    l_update_base_rec (p_base_id,p_fed_verif_status,NULL,lv_fa_process_status);

  EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,SQLERRM);
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_BATCH_VER_PRC.UPDATE_PROCESS_STATUS');
      IGS_GE_MSG_STACK.ADD;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.update_process_status.debug',SQLERRM);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END update_process_status;

  PROCEDURE update_fed_verif_status ( p_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
                                      p_fed_verif_status igf_ap_fa_base_rec_all.fed_verif_status%TYPE
                                    ) IS
    /**********************************************************
    Created By : bkkumar
    Date Created By : 10-Dec-2003

    Purpose : Bug# 3240804 Update the federal verification status
    if the verification status is in TERMINAL status.

    Know limitations, enhancements or remarks
    Change History
    Who           When            What
    (reverse chronological order - newest change first)
    ***************************************************************/
  CURSOR get_fed_verif_status (cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
  IS
  SELECT fed_verif_status
  FROM   igf_ap_fa_base_rec_all
  WHERE  base_id = cp_base_id;

  l_fed_verif_status igf_ap_fa_base_rec_all.fed_verif_status%TYPE;

  BEGIN
  l_fed_verif_status := NULL;

  OPEN  get_fed_verif_status(p_base_id);
  FETCH get_fed_verif_status INTO l_fed_verif_status;
  CLOSE get_fed_verif_status;

  -- If the fed_verif_Status is not in terminal status then only update the status
  IF NVL(l_fed_verif_status,'X') NOT IN ('CORRSENT','SELECTED','WITHOUTDOC') THEN
    update_process_status(p_base_id , p_fed_verif_status);
  ELSE
    update_process_status(p_base_id , NULL);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.log,SQLERRM);
    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_BATCH_VER_PRC.UPDATE_FED_VERIF_STATUS');
    IGS_GE_MSG_STACK.ADD;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.update_fed_verif_status.debug',SQLERRM);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

  END update_fed_verif_status;

  FUNCTION get_gr_ver_code(
                           pv_fed_verif_status  igf_lookups_view.lookup_code%TYPE,
                           p_cal_type           igf_ap_batch_aw_map_all.ci_cal_type%TYPE,
                           p_sequence_number    igf_ap_batch_aw_map_all.ci_sequence_number%TYPE
                          ) RETURN VARCHAR2 IS

    -- Read Sys Award Year
    CURSOR cur_get_sys_awd(
                           p_cal_type           igf_ap_batch_aw_map_all.ci_cal_type%TYPE,
                           p_sequence_number    igf_ap_batch_aw_map_all.ci_sequence_number%TYPE
                          ) IS
    SELECT sys_award_year
      FROM igf_ap_batch_aw_map
     WHERE ci_cal_type        = p_cal_type
       AND ci_sequence_number = p_sequence_number;

    lv_sys_award_year igf_aw_int_ext_map.sys_award_year%TYPE;

    -- Read mapping from igf_aw_int_ext_map table
    CURSOR cur_get_int_ext(
                           p_fed_verif_status  igf_lookups_view.lookup_code%TYPE,
                           p_sys_award_year    igf_aw_int_ext_map.sys_award_year%TYPE ,
                           cp_int_lkup_type    VARCHAR2 ,
                           cp_ext_lkup_type    VARCHAR2
                          ) IS
    SELECT ext_lookup_code
      FROM igf_aw_int_ext_map
     WHERE int_lookup_type = cp_int_lkup_type
       AND ext_lookup_type = cp_ext_lkup_type
       AND int_lookup_code = p_fed_verif_status
       AND SYS_AWARD_YEAR  = p_sys_award_year;

    lv_gr_verif_status  VARCHAR2(30);
    l_int_lkup_type     VARCHAR2(30);
    l_ext_lkup_type     VARCHAR2(30);

  BEGIN

    OPEN  cur_get_sys_awd(p_cal_type,p_sequence_number);
    FETCH cur_get_sys_awd INTO lv_sys_award_year;
    CLOSE cur_get_sys_awd;

    l_int_lkup_type := 'IGF_FED_VERIFY_STATUS';
    l_ext_lkup_type := 'IGF_GR_VER_STAT_CD' ;
    OPEN  cur_get_int_ext(pv_fed_verif_status,lv_sys_award_year, l_int_lkup_type, l_ext_lkup_type );
    FETCH cur_get_int_ext INTO lv_gr_verif_status;
    CLOSE cur_get_int_ext;

    RETURN lv_gr_verif_status;

  EXCEPTION
    WHEN OTHERS THEN

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_BATCH_VER_PRC.GET_GR_VER_CODE');
      igs_ge_msg_stack.add;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_batch_ver_prc_pkg.get_gr_ver_code.debug',SQLERRM);
      END IF;
      app_exception.raise_exception;

  END get_gr_ver_code;


END igf_ap_batch_ver_prc_pkg;

/
