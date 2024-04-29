--------------------------------------------------------
--  DDL for Package Body IGF_AP_MATCHING_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_MATCHING_PROCESS_PKG" AS
/* $Header: IGFAP04B.pls 120.23 2006/06/30 07:54:19 rajagupt ship $ */

    INVALID_PROFILE_ERROR     EXCEPTION;
    total_rvw                 NUMBER(8);
    g_force_add               VARCHAR2(1);
    g_create_inquiry          VARCHAR2(1);
    g_adm_source_type         VARCHAR2(30);
    g_matched_rec             NUMBER  :=        0;
    g_unmatched_rec           NUMBER  :=        0;
    g_unmatched_added         NUMBER  :=        0;
    g_bad_rec                 NUMBER  :=        0;
    g_dup_rec                 NUMBER  :=        0;
    g_review_count            NUMBER  :=        0;
    g_rec_not_ins             BOOLEAN :=        TRUE;
    gv_format                 igs_pe_person_id_typ.format_mask%TYPE := NULL;
    g_setup_score             igf_ap_record_match%ROWTYPE;
    g_isir_intrface_rec       igf_ap_isir_ints%ROWTYPE;
    g_ci_cal_type             igf_ap_batch_aw_map.ci_cal_type%TYPE;
    g_ci_sequence_number      igf_ap_batch_aw_map.ci_sequence_number%TYPE;
    g_pell_match_type         VARCHAR2(1) ; -- Stores the Type of Pell match done Duplicate/New rec
    g_base_id                 NUMBER;
    g_called_from_process     BOOLEAN := FALSE;
    g_fa_base_rec             igf_ap_fa_base_rec%ROWTYPE; -- Will be populated once and used in all places
    g_max_tran_num            VARCHAR2(2); -- Stores the max transaction number
    g_person_id               NUMBER;
    g_count_corr              NUMBER ;

    g_batch_year              igf_ap_batch_aw_map.batch_year%TYPE;
    g_match_code              igf_ap_record_match_all.match_code%TYPE;
    g_separator_line          VARCHAR2(100);
    g_total_recs_processed    NUMBER := 0;
    g_rec_processed_status    igf_ap_isir_ints_all.record_status%TYPE;
    g_del_success_int_rec     VARCHAR2(1); -- Global var for holding p_del_int parameter value
    g_isir_is_valid           BOOLEAN;
    g_sub_req_num             NUMBER;
    g_gen_party_profile_val   VARCHAR2(1);
    g_enable_debug_logging    VARCHAR2(1);
    g_upd_ant_val             VARCHAR2(1);

    g_debug_seq               NUMBER:=0;  --- #R1 Remove after debugging
    g_old_active_isir_id      igf_ap_isir_matched_all.isir_id%TYPE;  -- bbb

   -- pl/sql table def for deleting from match details using BULK operation.
   TYPE match_details_amd_id IS TABLE OF igf_ap_match_details.amd_id%TYPE;
   g_amd_id_tab   match_details_amd_id;

   CURSOR cur_setup_score (cp_match_code igf_ap_record_match_all.match_code%TYPE) IS
   SELECT *
   FROM   igf_ap_record_match
   WHERE  match_code = cp_match_code
     AND  enabled_flag = 'Y';


      --==== FOR TESTING...
      RAM_U_R       NUMBER := 0;

      RAM_I_M       NUMBER := 0;
      RAM_U_M       NUMBER := 0;

      RAM_I_N       NUMBER := 0;

      RAM_I_PM      NUMBER := 0;
      RAM_U_PM      NUMBER := 0;

      RAM_I_MD      NUMBER := 0;
      RAM_U_MD      NUMBER := 0;

      RAM_I_F       NUMBER := 0;
      RAM_U_F       NUMBER := 0;

      RAM_I_CORR    NUMBER := 0;
      RAM_U_CORR    NUMBER := 0;

      RAM_I_PRSN    NUMBER := 0;
      RAM_I_HZ      NUMBER := 0;

      RAM_U_TODO    NUMBER := 0;
      RAM_I_TODO    NUMBER := 0;

      RAM_U_O       NUMBER := 0;

      RAM_D_MD      NUMBER := 0;
      RAM_D_PM      NUMBER := 0;

      RAM_MQ         NUMBER := 0;


PROCEDURE log_debug_message(m VARCHAR2)
IS
-- for debugging/testing

BEGIN
   IF g_enable_debug_logging = 'Y' THEN
      g_debug_seq := g_debug_seq + 1;
  --    fnd_file.put_line(fnd_file.log, m);
  -- INSERT INTO RAN_DEBUG values (g_debug_seq,m);

   END IF;
END log_debug_message;


PROCEDURE RAM_log_dml_count IS

BEGIN

log_debug_message('RAM_U_R     ' || RAM_U_R);

log_debug_message('RAM_I_M     ' || RAM_I_M);
log_debug_message('RAM_U_M     ' || RAM_U_M);

log_debug_message('RAM_I_N     ' || RAM_I_N);

log_debug_message('RAM_I_PM    ' || RAM_I_PM);
log_debug_message('RAM_U_PM    ' || RAM_U_PM);
log_debug_message('RAM_D_PM    ' || RAM_D_PM);

log_debug_message('RAM_I_MD    ' || RAM_I_MD);
log_debug_message('RAM_U_MD    ' || RAM_U_MD);
log_debug_message('RAM_D_MD    ' || RAM_D_MD);

log_debug_message('RAM_I_F     ' || RAM_I_F);
log_debug_message('RAM_U_F     ' || RAM_U_F);

log_debug_message('RAM_I_CORR  ' || RAM_I_CORR);
log_debug_message('RAM_U_CORR  ' || RAM_U_CORR);

log_debug_message('RAM_U_TODO  ' || RAM_U_TODO);
log_debug_message('RAM_I_TODO  ' || RAM_I_TODO);
log_debug_message('RAM_I_HZ    ' || RAM_I_HZ);
log_debug_message('RAM_U_O     ' || RAM_U_O);


log_debug_message('RAM_MQ      ' || RAM_MQ);

END RAM_log_dml_count;


PROCEDURE reset_global_variables
IS
  /*
  ||  Created By : rgangara
  ||  Created On : 30-AUG-2004
  ||  Purpose :    Resets global variables.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||
  ||  (reverse chronological order - newest change first)
  */

BEGIN
   total_rvw                 := 0;
   g_matched_rec             := 0;
   g_unmatched_rec           := 0;
   g_unmatched_added         := 0;
   g_bad_rec                 := 0;
   g_dup_rec                 := 0;
   g_review_count            := 0;
   g_count_corr              := 0;
   g_total_recs_processed    := 0;
   g_pell_match_type         := NULL;
   g_base_id                 := NULL;
   g_max_tran_num            := NULL;
   g_person_id               := NULL;
   g_batch_year              := NULL;
   g_match_code              := NULL;
   g_sub_req_num             := 0;
END;


FUNCTION get_msg_class_from_filename(p_filename VARCHAR2)
RETURN VARCHAR2 IS

  /*
  ||  Created By : rgangara
  ||  Created On : 03-AUG-2004
  ||  Purpose :        Extracts and returns message class name from a given data file name.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||
  ||  (reverse chronological order - newest change first)
  */

   l_mesg_class       igf_ap_isir_matched_all.message_class_txt%TYPE;
   l_dot_in_file_name NUMBER :=0;

BEGIN
   -- Check if data file has a file extn
   l_dot_in_file_name := INSTR(p_filename, '.');

   IF l_dot_in_file_name = 0 THEN
      -- no dot in filename hence entire string is msg class
      l_mesg_class := p_filename;
   ELSE
      -- extract msg class by removing file extn from the file name.
      l_mesg_class := SUBSTR(p_filename, 1, (l_dot_in_file_name - 1));
   END IF;

   RETURN(l_mesg_class);

EXCEPTION
   WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.get_msg_class_from_filename.exception','The exception is : ' || SQLERRM );
      END IF;

     RETURN NULL;
     fnd_message.set_name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
     igs_ge_msg_stack.add;
     fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
     igs_ge_msg_stack.add;
     app_exception.raise_exception;

END get_msg_class_from_filename;



FUNCTION is_payment_isir(p_primary_efc_amt NUMBER)
RETURN VARCHAR2 IS

  /*
  ||  Created By : rgangara
  ||  Created On : 03-AUG-2004
  ||  Purpose :        For Inserting record into ISIR matched table based on ISIR int record.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||
  ||  (reverse chronological order - newest change first)
  */

   lv_payment_isir VARCHAR2(1);

BEGIN
   IF p_primary_efc_amt IS NOT NULL THEN
      lv_payment_isir := 'Y' ;
   ELSE
      lv_payment_isir := 'N' ;
   END IF;

   RETURN (lv_payment_isir);

EXCEPTION
   WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.is_payment_isir.exception','The exception is : ' || SQLERRM );
      END IF;

     fnd_message.set_name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
     igs_ge_msg_stack.add;
     fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
END is_payment_isir;



PROCEDURE process_todo_items(p_base_id      NUMBER,
                             p_payment_isir VARCHAR2)
IS
  /*
  ||  Created By : rgangara
  ||  Created On : 11-AUG-2004
  ||  Purpose :    For updating TODO items for system todo type of ISIR. Added as part of FA 138 enh (3416895)
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||
  ||  (reverse chronological order - newest change first)
  */

   CURSOR todo_items_for_isir_cur IS
   SELECT im.*
   FROM   igf_ap_td_item_mst im
   WHERE  im.system_todo_type_code = 'ISIR' -- for ISIR type only
     AND im.ci_cal_type = g_ci_cal_type
     AND im.ci_sequence_number = g_ci_sequence_number;

   CURSOR check_todo_exists_inst_cur(lp_base_id NUMBER, p_item_seq_num NUMBER) IS
     SELECT ii.rowid, ii.*
       FROM igf_ap_td_item_inst ii, igf_ap_td_item_mst im
      WHERE ii.item_sequence_number = im.todo_number
        AND im.system_todo_type_code = 'ISIR'
        AND im.ci_cal_type = g_ci_cal_type
        AND im.ci_sequence_number = g_ci_sequence_number
        AND ii.item_sequence_number = p_item_seq_num
        AND ii.base_id = lp_base_id;

   l_todo_status igf_ap_td_item_inst_all.status%TYPE;

    check_todo_exists_inst_rec check_todo_exists_inst_cur%ROWTYPE;

    lv_rowid ROWID;

BEGIN

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_todo_items.debug','Beginning processing of TODO Items for BASE ID: ' || p_base_id || ', Payment ISIR Flag: ' || p_payment_isir );
   END IF;

log_debug_message(' Processing TODO items.... ');
   -- populate the variable with the status to be updated for the records
   IF p_payment_isir = 'Y' THEN
      -- need to set the todo status for the records to COMPLETE
      l_todo_status := 'COM';

   ELSE
      -- need to set the todo status for the records to INCOMPLETE
      l_todo_status := 'REC';
   END IF;


   -- loop thru the records and update the status
   FOR todo_items_for_isir_rec IN todo_items_for_isir_cur
   LOOP
      check_todo_exists_inst_rec := NULL;
      OPEN check_todo_exists_inst_cur(p_base_id, todo_items_for_isir_rec.todo_number);
      FETCH check_todo_exists_inst_cur INTO check_todo_exists_inst_rec;

      IF check_todo_exists_inst_cur%NOTFOUND THEN

      log_debug_message(' Attaching new ISIR with item_sequence_number : ' || todo_items_for_isir_rec.todo_number || ' and TODO status : ' || l_todo_status || '  for Base ID: ' || p_base_id);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_todo_items.debug','Attaching new ISIR with item_sequence_number : ' || todo_items_for_isir_rec.todo_number || '  for Base ID: ' || p_base_id);
      END IF;

      -- insert new row
      lv_rowid := NULL;
      igf_ap_td_item_inst_pkg.insert_row (
             x_rowid                        => lv_rowid                                    ,
             x_base_id                      => p_base_id                                   ,
             x_item_sequence_number         => todo_items_for_isir_rec.todo_number         ,
             x_status                       => l_todo_status                               ,
             x_status_date                  => TRUNC(SYSDATE)                              ,
             x_add_date                     => TRUNC(SYSDATE)                              ,
             x_corsp_date                   => NULL                                        ,
             x_corsp_count                  => NULL                                        ,
             x_inactive_flag                => 'N'                                         ,
             x_freq_attempt                 => todo_items_for_isir_rec.freq_attempt        ,
             x_max_attempt                  => todo_items_for_isir_rec.max_attempt         ,
             x_required_for_application     => todo_items_for_isir_rec.required_for_application,
             x_mode                         => 'R'                                        ,
             x_legacy_record_flag           => NULL,
             x_clprl_id                     => NULL
          );
      ELSE

      log_debug_message(' Update TODO Items to Status : ' || l_todo_status);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_todo_items.debug','Processing TODO status to  : ' || l_todo_status || '  for Base ID: ' || p_base_id);
      END IF;

      -- update the status to complete
      igf_ap_td_item_inst_pkg.update_row (
             x_rowid                        => check_todo_exists_inst_rec.rowid               ,
             x_base_id                      => p_base_id                                      ,
             x_item_sequence_number         => check_todo_exists_inst_rec.item_sequence_number,
             x_status                       => l_todo_status                                  ,
             x_status_date                  => check_todo_exists_inst_rec.status_date         ,
             x_add_date                     => check_todo_exists_inst_rec.add_date            ,
             x_corsp_date                   => check_todo_exists_inst_rec.corsp_date          ,
             x_corsp_count                  => check_todo_exists_inst_rec.corsp_count         ,
             x_inactive_flag                => check_todo_exists_inst_rec.inactive_flag       ,
             x_freq_attempt                 => check_todo_exists_inst_rec.freq_attempt        ,
             x_max_attempt                  => check_todo_exists_inst_rec.max_attempt         ,
             x_required_for_application     => check_todo_exists_inst_rec.required_for_application,
             x_mode                         => 'R'                                            ,
             x_legacy_record_flag           => check_todo_exists_inst_rec.legacy_record_flag,
             x_clprl_id                     => check_todo_exists_inst_rec.clprl_id
          );
      END IF;


      CLOSE check_todo_exists_inst_cur;

      log_debug_message('Successfully processed TODO processing.');
      RAM_U_TODO := RAM_U_TODO + 1;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_todo_items.debug','Item No.: ' || todo_items_for_isir_rec.todo_number);
      END IF;
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.process_todo_items.exception','The exception is : ' || SQLERRM );
      END IF;

     fnd_message.set_name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
     igs_ge_msg_stack.add;
     fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
END process_todo_items;


PROCEDURE update_isir_int_record (p_si_id             igf_ap_isir_ints.si_id%TYPE,
                                  p_isir_rec_status   igf_ap_isir_ints_all.record_status%TYPE,
                                  p_match_code        igf_ap_isir_ints.match_code%TYPE)
IS
  /*
  ||  Created By : rgangara
  ||  Created On : 03-AUG-2004
  ||  Purpose :    For Updating ISIR Interface record status.
  ||               However, records which are to be updated to 'MATCHED' status could be deleted if
  ||               the p_del_int_rec User parameter value is 'Y'. Hence this procedure is modified
  ||               to delete the ISIR from Int table if the rec status is MATCHED and the paremeter is 'Y'.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||
  ||  (reverse chronological order - newest change first)
  */


BEGIN

   IF g_del_success_int_rec = 'Y' AND p_isir_rec_status = 'MATCHED' THEN

      DELETE FROM igf_ap_isir_ints_all
      WHERE  si_id = p_si_id;

      log_debug_message('Deleted ISIR Interface record. SI ID : ' || p_si_id);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.update_isir_int_record.statement','Deleted ISIR Interface record for SI_ID: ' || p_si_id);
      END IF;

   ELSE -- if parameter is No or status is not 'MATCHED'
      UPDATE igf_ap_isir_ints_all
      SET    record_status    = p_isir_rec_status,
             match_code       = p_match_code,
             last_update_date = SYSDATE
      WHERE  si_id            = p_si_id;

      log_debug_message('Updated ISIR Interface record. SI ID : ' || p_si_id);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.update_isir_int_record.statement','Updated ISIR Interface Record Status to ' || p_isir_rec_status || ' for SI_ID: ' || p_si_id);
      END IF;

      RAM_U_R := RAM_U_R + 1;
     fnd_message.set_name('IGF','IGF_AP_ISIR_REC_STATUS');
     fnd_message.set_token('STATUS',p_isir_rec_status);
     fnd_file.put_line(fnd_file.log, fnd_message.get);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.update_isir_int_record.exception','The exception is : ' || SQLERRM );
      END IF;

     fnd_message.set_name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
     igs_ge_msg_stack.add;
     fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
END update_isir_int_record;


PROCEDURE update_fa_base_rec(p_fabase_rec             igf_ap_fa_base_rec%ROWTYPE,
                             p_isir_verification_flag VARCHAR2)
IS
  /*
  ||  Created By : rgangara
  ||  Created On : 05-AUG-2004
  ||  Purpose :    For Updating FA BASE record as per the passed in record.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||
  ||  (reverse chronological order - newest change first)
  */

   l_fed_verif_status igf_ap_fa_base_rec.fed_verif_status%TYPE;

BEGIN

   l_fed_verif_status := p_fabase_rec.fed_verif_status;

   log_debug_message(' Beginning Update of FA Base record. BASE ID : ' || p_fabase_rec.base_id);
   IF (p_fabase_rec.fed_verif_status IS NULL OR
       p_fabase_rec.fed_verif_status IN ('CORRSENT','NOTVERIFIED', 'NOTSELECTED')) THEN

      IF p_isir_verification_flag = 'Y' THEN
         l_fed_verif_status := 'SELECTED';
      ELSE
         l_fed_verif_status := 'NOTSELECTED';
      END IF;
   END IF;

   -- call the TBH to update the record
   igf_ap_fa_base_rec_pkg.update_row(
              x_Mode                                   => 'R' ,
              x_rowid                                  => p_fabase_rec.row_id ,
              x_base_id                                => p_fabase_rec.base_id ,
              x_ci_cal_type                            => p_fabase_rec.ci_cal_type ,
              x_person_id                              => p_fabase_rec.person_id ,
              x_ci_sequence_number                     => p_fabase_rec.ci_sequence_number ,
              x_org_id                                 => p_fabase_rec.org_id ,
              x_coa_pending                            => p_fabase_rec.coa_pending ,
              x_verification_process_run               => p_fabase_rec.verification_process_run ,
              x_inst_verif_status_date                 => p_fabase_rec.inst_verif_status_date ,
              x_manual_verif_flag                      => p_fabase_rec.manual_verif_flag ,
              x_fed_verif_status                       => l_fed_verif_status ,
              x_fed_verif_status_date                  => TRUNC(SYSDATE),
              x_inst_verif_status                      => p_fabase_rec.inst_verif_status ,
              x_nslds_eligible                         => NVL(p_fabase_rec.nslds_eligible, g_isir_intrface_rec.nslds_match_type) ,
              x_ede_correction_batch_id                => p_fabase_rec.ede_correction_batch_id ,
              x_fa_process_status_date                 => p_fabase_rec.fa_process_status_date ,
              x_isir_corr_status                       => p_fabase_rec.isir_corr_status ,
              x_isir_corr_status_date                  => p_fabase_rec.isir_corr_status_date ,
              x_isir_status                            => 'Received-Valid',
              x_isir_status_date                       => TRUNC(SYSDATE) ,
              x_coa_code_f                             => p_fabase_rec.coa_code_f ,
              x_coa_code_i                             => p_fabase_rec.coa_code_i ,
              x_coa_f                                  => p_fabase_rec.coa_f ,
              x_coa_i                                  => p_fabase_rec.coa_i ,
              x_disbursement_hold                      => p_fabase_rec.disbursement_hold ,
              x_fa_process_status                      => p_fabase_rec.fa_process_status ,
              x_notification_status                    => p_fabase_rec.notification_status ,
              x_notification_status_date               => p_fabase_rec.notification_status_date ,
              x_packaging_status                       => p_fabase_rec.packaging_status ,
              x_packaging_status_date                  => p_fabase_rec.packaging_status_date ,
              x_total_package_accepted                 => p_fabase_rec.total_package_accepted ,
              x_total_package_offered                  => p_fabase_rec.total_package_offered ,
              x_admstruct_id                           => p_fabase_rec.admstruct_id ,
              x_admsegment_1                           => p_fabase_rec.admsegment_1 ,
              x_admsegment_2                           => p_fabase_rec.admsegment_2 ,
              x_admsegment_3                           => p_fabase_rec.admsegment_3 ,
              x_admsegment_4                           => p_fabase_rec.admsegment_4 ,
              x_admsegment_5                           => p_fabase_rec.admsegment_5 ,
              x_admsegment_6                           => p_fabase_rec.admsegment_6 ,
              x_admsegment_7                           => p_fabase_rec.admsegment_7 ,
              x_admsegment_8                           => p_fabase_rec.admsegment_8 ,
              x_admsegment_9                           => p_fabase_rec.admsegment_9 ,
              x_admsegment_10                          => p_fabase_rec.admsegment_10 ,
              x_admsegment_11                          => p_fabase_rec.admsegment_11 ,
              x_admsegment_12                          => p_fabase_rec.admsegment_12 ,
              x_admsegment_13                          => p_fabase_rec.admsegment_13 ,
              x_admsegment_14                          => p_fabase_rec.admsegment_14 ,
              x_admsegment_15                          => p_fabase_rec.admsegment_15 ,
              x_admsegment_16                          => p_fabase_rec.admsegment_16 ,
              x_admsegment_17                          => p_fabase_rec.admsegment_17 ,
              x_admsegment_18                          => p_fabase_rec.admsegment_18 ,
              x_admsegment_19                          => p_fabase_rec.admsegment_19 ,
              x_admsegment_20                          => p_fabase_rec.admsegment_20 ,
              x_packstruct_id                          => p_fabase_rec.packstruct_id ,
              x_packsegment_1                          => p_fabase_rec.packsegment_1 ,
              x_packsegment_2                          => p_fabase_rec.packsegment_2 ,
              x_packsegment_3                          => p_fabase_rec.packsegment_3 ,
              x_packsegment_4                          => p_fabase_rec.packsegment_4 ,
              x_packsegment_5                          => p_fabase_rec.packsegment_5 ,
              x_packsegment_6                          => p_fabase_rec.packsegment_6 ,
              x_packsegment_7                          => p_fabase_rec.packsegment_7 ,
              x_packsegment_8                          => p_fabase_rec.packsegment_8 ,
              x_packsegment_9                          => p_fabase_rec.packsegment_9 ,
              x_packsegment_10                         => p_fabase_rec.packsegment_10 ,
              x_packsegment_11                         => p_fabase_rec.packsegment_11 ,
              x_packsegment_12                         => p_fabase_rec.packsegment_12 ,
              x_packsegment_13                         => p_fabase_rec.packsegment_13 ,
              x_packsegment_14                         => p_fabase_rec.packsegment_14 ,
              x_packsegment_15                         => p_fabase_rec.packsegment_15 ,
              x_packsegment_16                         => p_fabase_rec.packsegment_16 ,
              x_packsegment_17                         => p_fabase_rec.packsegment_17 ,
              x_packsegment_18                         => p_fabase_rec.packsegment_18 ,
              x_packsegment_19                         => p_fabase_rec.packsegment_19 ,
              x_packsegment_20                         => p_fabase_rec.packsegment_20 ,
              x_miscstruct_id                          => p_fabase_rec.miscstruct_id ,
              x_miscsegment_1                          => p_fabase_rec.miscsegment_1 ,
              x_miscsegment_2                          => p_fabase_rec.miscsegment_2 ,
              x_miscsegment_3                          => p_fabase_rec.miscsegment_3 ,
              x_miscsegment_4                          => p_fabase_rec.miscsegment_4 ,
              x_miscsegment_5                          => p_fabase_rec.miscsegment_5 ,
              x_miscsegment_6                          => p_fabase_rec.miscsegment_6 ,
              x_miscsegment_7                          => p_fabase_rec.miscsegment_7 ,
              x_miscsegment_8                          => p_fabase_rec.miscsegment_8 ,
              x_miscsegment_9                          => p_fabase_rec.miscsegment_9 ,
              x_miscsegment_10                         => p_fabase_rec.miscsegment_10 ,
              x_miscsegment_11                         => p_fabase_rec.miscsegment_11 ,
              x_miscsegment_12                         => p_fabase_rec.miscsegment_12 ,
              x_miscsegment_13                         => p_fabase_rec.miscsegment_13 ,
              x_miscsegment_14                         => p_fabase_rec.miscsegment_14 ,
              x_miscsegment_15                         => p_fabase_rec.miscsegment_15 ,
              x_miscsegment_16                         => p_fabase_rec.miscsegment_16 ,
              x_miscsegment_17                         => p_fabase_rec.miscsegment_17 ,
              x_miscsegment_18                         => p_fabase_rec.miscsegment_18 ,
              x_miscsegment_19                         => p_fabase_rec.miscsegment_19 ,
              x_miscsegment_20                         => p_fabase_rec.miscsegment_20 ,
              x_prof_judgement_flg                     => p_fabase_rec.prof_judgement_flg ,
              x_nslds_data_override_flg                => p_fabase_rec.nslds_data_override_flg ,
              x_target_group                           => p_fabase_rec.target_group ,
              x_coa_fixed                              => p_fabase_rec.coa_fixed ,
              x_coa_pell                               => p_fabase_rec.coa_pell ,
              x_profile_status                         => p_fabase_rec.profile_status ,
              x_profile_status_date                    => p_fabase_rec.profile_status_date ,
              x_profile_fc                             => p_fabase_rec.profile_fc ,
              x_manual_disb_hold                       => p_fabase_rec.manual_disb_hold ,
              x_pell_alt_expense                       => p_fabase_rec.pell_alt_expense,
              x_assoc_org_num                          => p_fabase_rec.assoc_org_num,
              x_award_fmly_contribution_type           => p_fabase_rec.award_fmly_contribution_type,
              x_packaging_hold                         => p_fabase_rec.packaging_hold,
              x_isir_locked_by                         => p_fabase_rec.isir_locked_by,
              x_adnl_unsub_loan_elig_flag              => p_fabase_rec.adnl_unsub_loan_elig_flag,
              x_lock_awd_flag                          => p_fabase_rec.lock_awd_flag,
              x_lock_coa_flag                          => p_fabase_rec.lock_coa_flag

              );

      log_debug_message(' Successfully Updated FA Base record. BASE ID : ' || p_fabase_rec.base_id || '. Person ID" ' || p_fabase_rec.person_id);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.update_fa_base_rec.debug','Updated FA Base Record for BASE ID: ' || p_fabase_rec.base_id || ', Person ID" ' || p_fabase_rec.person_id);
      END IF;
      RAM_U_F := RAM_U_F + 1;

EXCEPTION
   WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.update_fa_base_rec.exception','The exception is : ' || SQLERRM );
      END IF;

     fnd_message.set_name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
     igs_ge_msg_stack.add;
     fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
END update_fa_base_rec;

PROCEDURE update_isir_matched_rec(p_isir_matched_record igf_ap_isir_matched%ROWTYPE,
                                  p_payment_isir        igf_ap_isir_matched_all.payment_isir%TYPE,
                                  p_active_isir         igf_ap_isir_matched_all.active_isir%TYPE )
IS
  /*
  ||  Created By : rgangara
  ||  Created On : 05-AUG-2004
  ||  Purpose :    For Updating record in ISIR Matched table and updating based on payment and active isir types.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||
  ||  (reverse chronological order - newest change first)
  */


BEGIN

   log_debug_message(' Beginning Update of ISIR Matched record. ISIR ID : ' || p_isir_matched_record.isir_id);
   -- call the TBH to update the isir matched record

   igf_ap_isir_matched_pkg.update_row(
           x_Mode                         => 'R',
           x_rowid                        => p_isir_matched_record.row_id,
           x_isir_id                      => p_isir_matched_record.isir_id,
           x_base_id                      => p_isir_matched_record.base_id,
           x_batch_year                   => p_isir_matched_record.batch_year,
           x_transaction_num              => p_isir_matched_record.transaction_num,
           x_current_ssn                  => p_isir_matched_record.current_ssn,
           x_ssn_name_change              => p_isir_matched_record.ssn_name_change,
           x_original_ssn                 => p_isir_matched_record.original_ssn,
           x_orig_name_id                 => p_isir_matched_record.orig_name_id,
           x_last_name                    => p_isir_matched_record.last_name,
           x_first_name                   => p_isir_matched_record.first_name,
           x_middle_initial               => p_isir_matched_record.middle_initial,
           x_perm_mail_add                => p_isir_matched_record.perm_mail_add,
           x_perm_city                    => p_isir_matched_record.perm_city,
           x_perm_state                   => p_isir_matched_record.perm_state,
           x_perm_zip_code                => p_isir_matched_record.perm_zip_code,
           x_date_of_birth                => p_isir_matched_record.date_of_birth,
           x_phone_number                 => p_isir_matched_record.phone_number,
           x_driver_license_number        => p_isir_matched_record.driver_license_number,
           x_driver_license_state         => p_isir_matched_record.driver_license_state,
           x_citizenship_status           => p_isir_matched_record.citizenship_status,
           x_alien_reg_number             => p_isir_matched_record.alien_reg_number,
           x_s_marital_status             => p_isir_matched_record.s_marital_status,
           x_s_marital_status_date        => p_isir_matched_record.s_marital_status_date,
           x_summ_enrl_status             => p_isir_matched_record.summ_enrl_status,
           x_fall_enrl_status             => p_isir_matched_record.fall_enrl_status,
           x_winter_enrl_status           => p_isir_matched_record.winter_enrl_status,
           x_spring_enrl_status           => p_isir_matched_record.spring_enrl_status,
           x_summ2_enrl_status            => p_isir_matched_record.summ2_enrl_status,
           x_fathers_highest_edu_level    => p_isir_matched_record.fathers_highest_edu_level,
           x_mothers_highest_edu_level    => p_isir_matched_record.mothers_highest_edu_level,
           x_s_state_legal_residence      => p_isir_matched_record.s_state_legal_residence,
           x_legal_residence_before_date  => p_isir_matched_record.legal_residence_before_date,
           x_s_legal_resd_date            => p_isir_matched_record.s_legal_resd_date,
           x_ss_r_u_male                  => p_isir_matched_record.ss_r_u_male,
           x_selective_service_reg        => p_isir_matched_record.selective_service_reg,
           x_degree_certification         => p_isir_matched_record.degree_certification,
           x_grade_level_in_college       => p_isir_matched_record.grade_level_in_college,
           x_high_school_diploma_ged      => p_isir_matched_record.high_school_diploma_ged,
           x_first_bachelor_deg_by_date   => p_isir_matched_record.first_bachelor_deg_by_date,
           x_interest_in_loan             => p_isir_matched_record.interest_in_loan,
           x_interest_in_stud_employment  => p_isir_matched_record.interest_in_stud_employment,
           x_drug_offence_conviction      => p_isir_matched_record.drug_offence_conviction,
           x_s_tax_return_status          => p_isir_matched_record.s_tax_return_status,
           x_s_type_tax_return            => p_isir_matched_record.s_type_tax_return,
           x_s_elig_1040ez                => p_isir_matched_record.s_elig_1040ez,
           x_s_adjusted_gross_income      => p_isir_matched_record.s_adjusted_gross_income,
           x_s_fed_taxes_paid             => p_isir_matched_record.s_fed_taxes_paid,
           x_s_exemptions                 => p_isir_matched_record.s_exemptions,
           x_s_income_from_work           => p_isir_matched_record.s_income_from_work,
           x_spouse_income_from_work      => p_isir_matched_record.spouse_income_from_work,
           x_s_toa_amt_from_wsa           => p_isir_matched_record.s_toa_amt_from_wsa,
           x_s_toa_amt_from_wsb           => p_isir_matched_record.s_toa_amt_from_wsb,
           x_s_toa_amt_from_wsc           => p_isir_matched_record.s_toa_amt_from_wsc,
           x_s_investment_networth        => p_isir_matched_record.s_investment_networth,
           x_s_busi_farm_networth         => p_isir_matched_record.s_busi_farm_networth,
           x_s_cash_savings               => p_isir_matched_record.s_cash_savings,
           x_va_months                    => p_isir_matched_record.va_months,
           x_va_amount                    => p_isir_matched_record.va_amount,
           x_stud_dob_before_date         => p_isir_matched_record.stud_dob_before_date,
           x_deg_beyond_bachelor          => p_isir_matched_record.deg_beyond_bachelor,
           x_s_married                    => p_isir_matched_record.s_married,
           x_s_have_children              => p_isir_matched_record.s_have_children,
           x_legal_dependents             => p_isir_matched_record.legal_dependents,
           x_orphan_ward_of_court         => p_isir_matched_record.orphan_ward_of_court,
           x_s_veteran                    => p_isir_matched_record.s_veteran,
           x_p_marital_status             => p_isir_matched_record.p_marital_status,
           x_father_ssn                   => p_isir_matched_record.father_ssn,
           x_f_last_name                  => p_isir_matched_record.f_last_name,
           x_mother_ssn                   => p_isir_matched_record.mother_ssn,
           x_m_last_name                  => p_isir_matched_record.m_last_name,
           x_p_num_family_member          => p_isir_matched_record.p_num_family_member,
           x_p_num_in_college             => p_isir_matched_record.p_num_in_college,
           x_p_state_legal_residence      => p_isir_matched_record.p_state_legal_residence,
           x_p_state_legal_res_before_dt  => p_isir_matched_record.p_state_legal_res_before_dt,
           x_p_legal_res_date             => p_isir_matched_record.p_legal_res_date,
           x_age_older_parent             => p_isir_matched_record.age_older_parent,
           x_p_tax_return_status          => p_isir_matched_record.p_tax_return_status,
           x_p_type_tax_return            => p_isir_matched_record.p_type_tax_return,
           x_p_elig_1040aez               => p_isir_matched_record.p_elig_1040aez,
           x_p_adjusted_gross_income      => p_isir_matched_record.p_adjusted_gross_income,
           x_p_taxes_paid                 => p_isir_matched_record.p_taxes_paid,
           x_p_exemptions                 => p_isir_matched_record.p_exemptions,
           x_f_income_work                => p_isir_matched_record.f_income_work,
           x_m_income_work                => p_isir_matched_record.m_income_work,
           x_p_income_wsa                 => p_isir_matched_record.p_income_wsa,
           x_p_income_wsb                 => p_isir_matched_record.p_income_wsb,
           x_p_income_wsc                 => p_isir_matched_record.p_income_wsc,
           x_p_investment_networth        => p_isir_matched_record.p_investment_networth,
           x_p_business_networth          => p_isir_matched_record.p_business_networth,
           x_p_cash_saving                => p_isir_matched_record.p_cash_saving,
           x_s_num_family_members         => p_isir_matched_record.s_num_family_members,
           x_s_num_in_college             => p_isir_matched_record.s_num_in_college,
           x_first_college                => p_isir_matched_record.first_college,
           x_first_house_plan             => p_isir_matched_record.first_house_plan,
           x_second_college               => p_isir_matched_record.second_college,
           x_second_house_plan            => p_isir_matched_record.second_house_plan,
           x_third_college                => p_isir_matched_record.third_college,
           x_third_house_plan             => p_isir_matched_record.third_house_plan,
           x_fourth_college               => p_isir_matched_record.fourth_college,
           x_fourth_house_plan            => p_isir_matched_record.fourth_house_plan,
           x_fifth_college                => p_isir_matched_record.fifth_college,
           x_fifth_house_plan             => p_isir_matched_record.fifth_house_plan,
           x_sixth_college                => p_isir_matched_record.sixth_college,
           x_sixth_house_plan             => p_isir_matched_record.sixth_house_plan,
           x_date_app_completed           => p_isir_matched_record.date_app_completed,
           x_signed_by                    => p_isir_matched_record.signed_by,
           x_preparer_ssn                 => p_isir_matched_record.preparer_ssn,
           x_preparer_emp_id_number       => p_isir_matched_record.preparer_emp_id_number,
           x_preparer_sign                => p_isir_matched_record.preparer_sign,
           x_transaction_receipt_date     => p_isir_matched_record.transaction_receipt_date,
           x_dependency_override_ind      => p_isir_matched_record.dependency_override_ind,
           x_faa_fedral_schl_code         => p_isir_matched_record.faa_fedral_schl_code,
           x_faa_adjustment               => p_isir_matched_record.faa_adjustment,
           x_input_record_type            => p_isir_matched_record.input_record_type,
           x_serial_number                => p_isir_matched_record.serial_number,
           x_batch_number                 => p_isir_matched_record.batch_number,
           x_early_analysis_flag          => p_isir_matched_record.early_analysis_flag,
           x_app_entry_source_code        => p_isir_matched_record.app_entry_source_code,
           x_eti_destination_code         => p_isir_matched_record.eti_destination_code,
           x_reject_override_b            => p_isir_matched_record.reject_override_b,
           x_reject_override_n            => p_isir_matched_record.reject_override_n,
           x_reject_override_w            => p_isir_matched_record.reject_override_w,
           x_assum_override_1             => p_isir_matched_record.assum_override_1,
           x_assum_override_2             => p_isir_matched_record.assum_override_2,
           x_assum_override_3             => p_isir_matched_record.assum_override_3,
           x_assum_override_4             => p_isir_matched_record.assum_override_4,
           x_assum_override_5             => p_isir_matched_record.assum_override_5,
           x_assum_override_6             => p_isir_matched_record.assum_override_6,
           x_dependency_status            => p_isir_matched_record.dependency_status,
           x_s_email_address              => p_isir_matched_record.s_email_address,
           x_nslds_reason_code            => p_isir_matched_record.nslds_reason_code,
           x_app_receipt_date             => p_isir_matched_record.app_receipt_date,
           x_processed_rec_type           => p_isir_matched_record.processed_rec_type,
           x_hist_correction_for_tran_id  => p_isir_matched_record.hist_correction_for_tran_id,
           x_system_generated_indicator   => p_isir_matched_record.system_generated_indicator,
           x_dup_request_indicator        => p_isir_matched_record.dup_request_indicator,
           x_source_of_correction         => p_isir_matched_record.source_of_correction,
           x_p_cal_tax_status             => p_isir_matched_record.p_cal_tax_status,
           x_s_cal_tax_status             => p_isir_matched_record.s_cal_tax_status,
           x_graduate_flag                => p_isir_matched_record.graduate_flag,
           x_auto_zero_efc                => p_isir_matched_record.auto_zero_efc,
           x_efc_change_flag              => p_isir_matched_record.efc_change_flag,
           x_sarc_flag                    => p_isir_matched_record.sarc_flag,
           x_simplified_need_test         => p_isir_matched_record.simplified_need_test,
           x_reject_reason_codes          => p_isir_matched_record.reject_reason_codes,
           x_select_service_match_flag    => p_isir_matched_record.select_service_match_flag,
           x_select_service_reg_flag      => p_isir_matched_record.select_service_reg_flag,
           x_ins_match_flag               => p_isir_matched_record.ins_match_flag,
           x_ins_verification_number      => NULL,
           x_sec_ins_match_flag           => p_isir_matched_record.sec_ins_match_flag,
           x_sec_ins_ver_number           => p_isir_matched_record.sec_ins_ver_number,
           x_ssn_match_flag               => p_isir_matched_record.ssn_match_flag,
           x_ssa_citizenship_flag         => p_isir_matched_record.ssa_citizenship_flag,
           x_ssn_date_of_death            => p_isir_matched_record.ssn_date_of_death,
           x_nslds_match_flag             => p_isir_matched_record.nslds_match_flag,
           x_va_match_flag                => p_isir_matched_record.va_match_flag,
           x_prisoner_match               => p_isir_matched_record.prisoner_match,
           x_verification_flag            => p_isir_matched_record.verification_flag,
           x_subsequent_app_flag          => p_isir_matched_record.subsequent_app_flag,
           x_app_source_site_code         => p_isir_matched_record.app_source_site_code,
           x_tran_source_site_code        => p_isir_matched_record.tran_source_site_code,
           x_drn                          => p_isir_matched_record.drn,
           x_tran_process_date            => p_isir_matched_record.tran_process_date,
           x_computer_batch_number        => p_isir_matched_record.computer_batch_number,
           x_correction_flags             => p_isir_matched_record.correction_flags,
           x_highlight_flags              => p_isir_matched_record.highlight_flags,
           x_paid_efc                     => NULL,
           x_primary_efc                  => p_isir_matched_record.primary_efc,
           x_secondary_efc                => p_isir_matched_record.secondary_efc,
           x_fed_pell_grant_efc_type      => NULL,
           x_primary_efc_type             => p_isir_matched_record.primary_efc_type,
           x_sec_efc_type                 => p_isir_matched_record.sec_efc_type,
           x_primary_alternate_month_1    => p_isir_matched_record.primary_alternate_month_1,
           x_primary_alternate_month_2    => p_isir_matched_record.primary_alternate_month_2,
           x_primary_alternate_month_3    => p_isir_matched_record.primary_alternate_month_3,
           x_primary_alternate_month_4    => p_isir_matched_record.primary_alternate_month_4,
           x_primary_alternate_month_5    => p_isir_matched_record.primary_alternate_month_5,
           x_primary_alternate_month_6    => p_isir_matched_record.primary_alternate_month_6,
           x_primary_alternate_month_7    => p_isir_matched_record.primary_alternate_month_7,
           x_primary_alternate_month_8    => p_isir_matched_record.primary_alternate_month_8,
           x_primary_alternate_month_10   => p_isir_matched_record.primary_alternate_month_10,
           x_primary_alternate_month_11   => p_isir_matched_record.primary_alternate_month_11,
           x_primary_alternate_month_12   => p_isir_matched_record.primary_alternate_month_12,
           x_sec_alternate_month_1        => p_isir_matched_record.sec_alternate_month_1,
           x_sec_alternate_month_2        => p_isir_matched_record.sec_alternate_month_2,
           x_sec_alternate_month_3        => p_isir_matched_record.sec_alternate_month_3,
           x_sec_alternate_month_4        => p_isir_matched_record.sec_alternate_month_4,
           x_sec_alternate_month_5        => p_isir_matched_record.sec_alternate_month_5,
           x_sec_alternate_month_6        => p_isir_matched_record.sec_alternate_month_6,
           x_sec_alternate_month_7        => p_isir_matched_record.sec_alternate_month_7,
           x_sec_alternate_month_8        => p_isir_matched_record.sec_alternate_month_8,
           x_sec_alternate_month_10       => p_isir_matched_record.sec_alternate_month_10,
           x_sec_alternate_month_11       => p_isir_matched_record.sec_alternate_month_11,
           x_sec_alternate_month_12       => p_isir_matched_record.sec_alternate_month_12,
           x_total_income                 => p_isir_matched_record.total_income,
           x_allow_total_income           => p_isir_matched_record.allow_total_income,
           x_state_tax_allow              => p_isir_matched_record.state_tax_allow,
           x_employment_allow             => p_isir_matched_record.employment_allow,
           x_income_protection_allow      => p_isir_matched_record.income_protection_allow,
           x_available_income             => p_isir_matched_record.available_income,
           x_contribution_from_ai         => p_isir_matched_record.contribution_from_ai,
           x_discretionary_networth       => p_isir_matched_record.discretionary_networth,
           x_efc_networth                 => p_isir_matched_record.efc_networth,
           x_asset_protect_allow          => p_isir_matched_record.asset_protect_allow,
           x_parents_cont_from_assets     => p_isir_matched_record.parents_cont_from_assets,
           x_adjusted_available_income    => p_isir_matched_record.adjusted_available_income,
           x_total_student_contribution   => p_isir_matched_record.total_student_contribution,
           x_total_parent_contribution    => p_isir_matched_record.total_parent_contribution,
           x_parents_contribution         => p_isir_matched_record.parents_contribution,
           x_student_total_income         => p_isir_matched_record.student_total_income,
           x_sati                         => p_isir_matched_record.sati,
           x_sic                          => p_isir_matched_record.sic,
           x_sdnw                         => p_isir_matched_record.sdnw,
           x_sca                          => p_isir_matched_record.sca,
           x_fti                          => p_isir_matched_record.fti,
           x_secti                        => p_isir_matched_record.secti,
           x_secati                       => p_isir_matched_record.secati,
           x_secstx                       => p_isir_matched_record.secstx,
           x_secea                        => p_isir_matched_record.secea,
           x_secipa                       => p_isir_matched_record.secipa,
           x_secai                        => p_isir_matched_record.secai,
           x_seccai                       => p_isir_matched_record.seccai,
           x_secdnw                       => p_isir_matched_record.secdnw,
           x_secnw                        => p_isir_matched_record.secnw,
           x_secapa                       => p_isir_matched_record.secapa,
           x_secpca                       => p_isir_matched_record.secpca,
           x_secaai                       => p_isir_matched_record.secaai,
           x_sectsc                       => p_isir_matched_record.sectsc,
           x_sectpc                       => p_isir_matched_record.sectpc,
           x_secpc                        => p_isir_matched_record.secpc,
           x_secsti                       => p_isir_matched_record.secsti,
           x_secsic                       => p_isir_matched_record.secsic,
           x_secsati                      => p_isir_matched_record.secsati,
           x_secsdnw                      => p_isir_matched_record.secsdnw,
           x_secsca                       => p_isir_matched_record.secsca,
           x_secfti                       => p_isir_matched_record.secfti,
           x_a_citizenship                => p_isir_matched_record.a_citizenship,
           x_a_student_marital_status     => p_isir_matched_record.a_student_marital_status,
           x_a_student_agi                => p_isir_matched_record.a_student_agi,
           x_a_s_us_tax_paid              => p_isir_matched_record.a_s_us_tax_paid,
           x_a_s_income_work              => p_isir_matched_record.a_s_income_work,
           x_a_spouse_income_work         => p_isir_matched_record.a_spouse_income_work,
           x_a_s_total_wsc                => p_isir_matched_record.a_s_total_wsc,
           x_a_date_of_birth              => p_isir_matched_record.a_date_of_birth,
           x_a_student_married            => p_isir_matched_record.a_student_married,
           x_a_have_children              => p_isir_matched_record.a_have_children,
           x_a_s_have_dependents          => p_isir_matched_record.a_s_have_dependents,
           x_a_va_status                  => p_isir_matched_record.a_va_status,
           x_a_s_num_in_family            => p_isir_matched_record.a_s_num_in_family,
           x_a_s_num_in_college           => p_isir_matched_record.a_s_num_in_college,
           x_a_p_marital_status           => p_isir_matched_record.a_p_marital_status,
           x_a_father_ssn                 => p_isir_matched_record.a_father_ssn,
           x_a_mother_ssn                 => p_isir_matched_record.a_mother_ssn,
           x_a_parents_num_family         => p_isir_matched_record.a_parents_num_family,
           x_a_parents_num_college        => p_isir_matched_record.a_parents_num_college,
           x_a_parents_agi                => p_isir_matched_record.a_parents_agi,
           x_a_p_us_tax_paid              => p_isir_matched_record.a_p_us_tax_paid,
           x_a_f_work_income              => p_isir_matched_record.a_f_work_income,
           x_a_m_work_income              => p_isir_matched_record.a_m_work_income,
           x_a_p_total_wsc                => p_isir_matched_record.a_p_total_wsc,
           x_comment_codes                => p_isir_matched_record.comment_codes,
           x_sar_ack_comm_code            => p_isir_matched_record.sar_ack_comm_code,
           x_pell_grant_elig_flag         => p_isir_matched_record.pell_grant_elig_flag,
           x_reprocess_reason_code        => p_isir_matched_record.reprocess_reason_code,
           x_duplicate_date               => p_isir_matched_record.duplicate_date,
           x_isir_transaction_type        => p_isir_matched_record.isir_transaction_type,
           x_fedral_schl_code_indicator   => p_isir_matched_record.fedral_schl_code_indicator,
           x_multi_school_code_flags      => p_isir_matched_record.multi_school_code_flags,
           x_dup_ssn_indicator            => p_isir_matched_record.dup_ssn_indicator,
           x_system_record_type           => p_isir_matched_record.system_record_type,
           x_verif_track_flag             => p_isir_matched_record.verif_track_flag,
           x_payment_isir                 => p_payment_isir,
           x_receipt_status               => p_isir_matched_record.receipt_status,
           x_isir_receipt_completed       => p_isir_matched_record.isir_receipt_completed,
           x_active_isir                  => p_active_isir ,
           x_fafsa_data_verify_flags      => p_isir_matched_record.fafsa_data_verify_flags,
           x_reject_override_a            => p_isir_matched_record.reject_override_a,
           x_reject_override_c            => p_isir_matched_record.reject_override_c,
           x_parent_marital_status_date   => p_isir_matched_record.parent_marital_status_date,
           x_legacy_record_flag           => NULL,
           x_father_first_name_initial    => p_isir_matched_record.father_first_name_initial_txt,
           x_father_step_father_birth_dt  => p_isir_matched_record.father_step_father_birth_date,
           x_mother_first_name_initial    => p_isir_matched_record.mother_first_name_initial_txt,
           x_mother_step_mother_birth_dt  => p_isir_matched_record.mother_step_mother_birth_date,
           x_parents_email_address_txt    => p_isir_matched_record.parents_email_address_txt,
           x_address_change_type          => p_isir_matched_record.address_change_type,
           x_cps_pushed_isir_flag         => p_isir_matched_record.cps_pushed_isir_flag,
           x_electronic_transaction_type  => p_isir_matched_record.electronic_transaction_type,
           x_sar_c_change_type            => p_isir_matched_record.sar_c_change_type,
           x_father_ssn_match_type        => p_isir_matched_record.father_ssn_match_type,
           x_mother_ssn_match_type        => p_isir_matched_record.mother_ssn_match_type,
           x_reject_override_g_flag       => p_isir_matched_record.reject_override_g_flag,
           x_dhs_verification_num_txt     => p_isir_matched_record.dhs_verification_num_txt,
           x_data_file_name_txt           => p_isir_matched_record.data_file_name_txt,
           x_message_class_txt            => p_isir_matched_record.message_class_txt,
           x_reject_override_3_flag       => p_isir_matched_record.reject_override_3_flag,
           x_reject_override_12_flag      => p_isir_matched_record.reject_override_12_flag,
           x_reject_override_j_flag       => p_isir_matched_record.reject_override_j_flag,
           x_reject_override_k_flag       => p_isir_matched_record.reject_override_k_flag,
           x_rejected_status_change_flag  => p_isir_matched_record.rejected_status_change_flag,
           x_verification_selection_flag  => p_isir_matched_record.verification_selection_flag
          );

   log_debug_message(' Successfully updated Isir Matched record. ' || p_isir_matched_record.isir_id || '. Payment ISIR Flag: ' || p_payment_isir || '. Active ISIR Flag: ' || p_active_isir);
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.update_isir_matched_rec.statement','Successfully updated ISIR record for ISIR ID : ' || p_isir_matched_record.isir_id);
   END IF;
   RAM_U_M := RAM_U_M + 1;

EXCEPTION
   WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.update_isir_matched_rec(.exception','The exception is : ' || SQLERRM );
      END IF;

     fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
     igs_ge_msg_stack.add;
     fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
END  update_isir_matched_rec;

PROCEDURE make_old_isir_non_awarding(p_base_id NUMBER) AS

    CURSOR cur_old_awd_isir(pn_base_id NUMBER) IS
    SELECT im.*
      FROM igf_ap_isir_matched im
     WHERE im.base_id = pn_base_id
       AND im.active_isir = 'Y';

      old_awd_isir_rec cur_old_awd_isir%ROWTYPE;


BEGIN

      FOR old_awd_isir_rec IN cur_old_awd_isir(p_base_id)
      LOOP
         update_isir_matched_rec(p_isir_matched_record => old_awd_isir_rec,
                                 p_payment_isir        => old_awd_isir_rec.payment_isir, -- retain existing value
                                 p_active_isir         => 'N'); -- retain existing value
      END LOOP;
END;

PROCEDURE make_old_isir_non_payment(p_base_id NUMBER) AS

    CURSOR cur_old_pymt_isir(pn_base_id NUMBER) IS
    SELECT im.*
      FROM igf_ap_isir_matched im
     WHERE im.base_id = pn_base_id
       AND im.payment_isir = 'Y';

      old_pymt_isir_rec cur_old_pymt_isir%ROWTYPE;


BEGIN

      FOR old_pymt_isir_rec IN cur_old_pymt_isir(p_base_id)
      LOOP
         update_isir_matched_rec(p_isir_matched_record => old_pymt_isir_rec,
                                 p_payment_isir        => 'N',                          -- make it Non payment isir
                                 p_active_isir         => old_pymt_isir_rec.active_isir); -- retain existing value
      END LOOP;
END;


PROCEDURE insert_isir_matched_rec(cp_isir_int_rec igf_ap_isir_ints%ROWTYPE,
                                  p_payment_isir  igf_ap_isir_matched_all.payment_isir%TYPE,
                                  p_active_isir   igf_ap_isir_matched_all.active_isir%TYPE,
                                  p_base_id       NUMBER,
                                  p_out_isir_id   OUT NOCOPY NUMBER
                                  ) IS


  /*
  ||  Created By : rgangara
  ||  Created On : 03-AUG-2004
  ||  Purpose :        For Inserting record into ISIR matched table based on ISIR int record.
  ||  Known limitations, enhancements or remarks :
  ||        PARAMETERS : p_payment_isir indicates that the New isir matched rec is also a  Payment isir
  ||                     p_active_isir  indicates that the New isir matched rec is also an Active isir
  ||                     p_out_isir_id  OUT parameter returns the ISIR ID of the new rec inserted.
  ||  Change History :
  ||  Who              When              What
  ||
  ||  (reverse chronological order - newest change first)
  */

   l_mesg_class       igf_ap_isir_matched_all.message_class_txt%TYPE;
   lv_rowid           VARCHAR2(30);

BEGIN
   lv_rowid   := NULL;

   log_debug_message(' Beginning Insert of ISIR Matched record. Base ID: ' || p_base_id || ', Payment ISIR Flag: ' || p_payment_isir);
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.insert_isir_matched_rec.debug','Inserting ISIR Matched record: Base ID: ' || p_Base_id || ', Payment: ' || p_payment_isir);
   END IF;


   -- Call function which extracts and returns message class from a given data file name.
   l_mesg_class := get_msg_class_from_filename(cp_isir_int_rec.data_file_name_txt);
   log_debug_message(' Message Class : ' || l_mesg_class);

 -- If the current ISIR is a payment ISIR, make the old ISIR as non payment.
 IF p_payment_isir = 'Y' THEN
     make_old_isir_non_payment(p_base_id);
 END IF;

  -- If the current ISIR is a awarding ISIR, make the old ISIR as non awarding.
 IF p_active_isir = 'Y' THEN
     make_old_isir_non_awarding(p_base_id);
 END IF;

  -- Insert old record into ISIR Matched Table
  igf_ap_isir_matched_pkg.insert_row(
        x_Mode                         => 'R',
        x_rowid                        => lv_rowid,
        x_isir_id                      => p_out_isir_id, -- value copied to OUT parameter
        x_base_id                      => p_base_id,
        x_batch_year                   => cp_isir_int_rec.batch_year_num,
        x_transaction_num              => cp_isir_int_rec.transaction_num_txt,
        x_current_ssn                  => cp_isir_int_rec.current_ssn_txt,
        x_ssn_name_change              => cp_isir_int_rec.ssn_name_change_type,
        x_original_ssn                 => cp_isir_int_rec.original_ssn_txt,
        x_orig_name_id                 => cp_isir_int_rec.orig_name_id_txt,
        x_last_name                    => cp_isir_int_rec.last_name,
        x_first_name                   => cp_isir_int_rec.first_name,
        x_middle_initial               => cp_isir_int_rec.middle_initial_txt,
        x_perm_mail_add                => cp_isir_int_rec.perm_mail_address_txt,
        x_perm_city                    => cp_isir_int_rec.perm_city_txt,
        x_perm_state                   => cp_isir_int_rec.perm_state_txt,
        x_perm_zip_code                => cp_isir_int_rec.perm_zip_cd,
        x_date_of_birth                => cp_isir_int_rec.birth_date,
        x_phone_number                 => cp_isir_int_rec.phone_number_txt,
        x_driver_license_number        => cp_isir_int_rec.driver_license_number_txt,
        x_driver_license_state         => cp_isir_int_rec.driver_license_state_txt,
        x_citizenship_status           => cp_isir_int_rec.citizenship_status_type,
        x_alien_reg_number             => cp_isir_int_rec.alien_reg_number_txt,
        x_s_marital_status             => cp_isir_int_rec.s_marital_status_type,
        x_s_marital_status_date        => cp_isir_int_rec.s_marital_status_date,
        x_summ_enrl_status             => cp_isir_int_rec.summ_enrl_status_type,
        x_fall_enrl_status             => cp_isir_int_rec.fall_enrl_status_type,
        x_winter_enrl_status           => cp_isir_int_rec.winter_enrl_status_type,
        x_spring_enrl_status           => cp_isir_int_rec.spring_enrl_status_type,
        x_summ2_enrl_status            => cp_isir_int_rec.summ2_enrl_status_type,
        x_fathers_highest_edu_level    => cp_isir_int_rec.fathers_highst_edu_lvl_type,
        x_mothers_highest_edu_level    => cp_isir_int_rec.mothers_highst_edu_lvl_type,
        x_s_state_legal_residence      => cp_isir_int_rec.s_state_legal_residence,
        x_legal_residence_before_date  => cp_isir_int_rec.legal_res_before_year_flag,
        x_s_legal_resd_date            => cp_isir_int_rec.s_legal_resd_date,
        x_ss_r_u_male                  => cp_isir_int_rec.ss_r_u_male_flag,
        x_selective_service_reg        => cp_isir_int_rec.selective_service_reg_flag,
        x_degree_certification         => cp_isir_int_rec.degree_certification_type,
        x_grade_level_in_college       => cp_isir_int_rec.grade_level_in_college_type,
        x_high_school_diploma_ged      => cp_isir_int_rec.high_schl_diploma_ged_flag,
        x_first_bachelor_deg_by_date   => cp_isir_int_rec.first_bachlr_deg_year_flag,
        x_interest_in_loan             => cp_isir_int_rec.interest_in_loan_flag,
        x_interest_in_stud_employment  => cp_isir_int_rec.interest_in_stu_employ_flag,
        x_drug_offence_conviction      => cp_isir_int_rec.drug_offence_convict_type,
        x_s_tax_return_status          => cp_isir_int_rec.s_tax_return_status_type,
        x_s_type_tax_return            => cp_isir_int_rec.s_type_tax_return_type,
        x_s_elig_1040ez                => cp_isir_int_rec.s_elig_1040ez_type,
        x_s_adjusted_gross_income      => cp_isir_int_rec.s_adjusted_gross_income_amt,
        x_s_fed_taxes_paid             => cp_isir_int_rec.s_fed_taxes_paid_amt,
        x_s_exemptions                 => cp_isir_int_rec.s_exemptions_amt,
        x_s_income_from_work           => cp_isir_int_rec.s_income_from_work_amt,
        x_spouse_income_from_work      => cp_isir_int_rec.spouse_income_from_work_amt,
        x_s_toa_amt_from_wsa           => cp_isir_int_rec.s_total_from_wsa_amt,
        x_s_toa_amt_from_wsb           => cp_isir_int_rec.s_total_from_wsb_amt,
        x_s_toa_amt_from_wsc           => cp_isir_int_rec.s_total_from_wsc_amt,
        x_s_investment_networth        => cp_isir_int_rec.s_investment_networth_amt,
        x_s_busi_farm_networth         => cp_isir_int_rec.s_busi_farm_networth_amt,
        x_s_cash_savings               => cp_isir_int_rec.s_cash_savings_amt,
        x_va_months                    => cp_isir_int_rec.va_months_num,
        x_va_amount                    => cp_isir_int_rec.va_amt,
        x_stud_dob_before_date         => cp_isir_int_rec.stud_dob_before_year_flag,
        x_deg_beyond_bachelor          => cp_isir_int_rec.deg_beyond_bachelor_flag,
        x_s_married                    => cp_isir_int_rec.s_married_flag,
        x_s_have_children              => cp_isir_int_rec.s_have_children_flag,
        x_legal_dependents             => cp_isir_int_rec.legal_dependents_flag,
        x_orphan_ward_of_court         => cp_isir_int_rec.orphan_ward_of_court_flag,
        x_s_veteran                    => cp_isir_int_rec.s_veteran_flag,
        x_p_marital_status             => cp_isir_int_rec.p_marital_status_type,
        x_father_ssn                   => cp_isir_int_rec.father_ssn_txt,
        x_f_last_name                  => cp_isir_int_rec.f_last_name,
        x_mother_ssn                   => cp_isir_int_rec.mother_ssn_txt,
        x_m_last_name                  => cp_isir_int_rec.m_last_name,
        x_p_num_family_member          => cp_isir_int_rec.p_family_members_num,
        x_p_num_in_college             => cp_isir_int_rec.p_in_college_num,
        x_p_state_legal_residence      => cp_isir_int_rec.p_state_legal_residence_txt,
        x_p_state_legal_res_before_dt  => cp_isir_int_rec.p_legal_res_before_dt_flag,
        x_p_legal_res_date             => cp_isir_int_rec.p_legal_res_date,
        x_age_older_parent             => cp_isir_int_rec.age_older_parent_num,
        x_p_tax_return_status          => cp_isir_int_rec.p_tax_return_status_type,
        x_p_type_tax_return            => cp_isir_int_rec.p_type_tax_return_type,
        x_p_elig_1040aez               => cp_isir_int_rec.p_elig_1040aez_type,
        x_p_adjusted_gross_income      => cp_isir_int_rec.p_adjusted_gross_income_amt,
        x_p_taxes_paid                 => cp_isir_int_rec.p_taxes_paid_amt,
        x_p_exemptions                 => cp_isir_int_rec.p_exemptions_amt,
        x_f_income_work                => cp_isir_int_rec.f_income_work_amt,
        x_m_income_work                => cp_isir_int_rec.m_income_work_amt,
        x_p_income_wsa                 => cp_isir_int_rec.p_income_wsa_amt,
        x_p_income_wsb                 => cp_isir_int_rec.p_income_wsb_amt,
        x_p_income_wsc                 => cp_isir_int_rec.p_income_wsc_amt,
        x_p_investment_networth        => cp_isir_int_rec.p_investment_networth_amt,
        x_p_business_networth          => cp_isir_int_rec.p_business_networth_amt,
        x_p_cash_saving                => cp_isir_int_rec.p_cash_saving_amt,
        x_s_num_family_members         => cp_isir_int_rec.s_family_members_num,
        x_s_num_in_college             => cp_isir_int_rec.s_in_college_num,
        x_first_college                => cp_isir_int_rec.first_college_cd,
        x_first_house_plan             => cp_isir_int_rec.first_house_plan_type,
        x_second_college               => cp_isir_int_rec.second_college_cd,
        x_second_house_plan            => cp_isir_int_rec.second_house_plan_type,
        x_third_college                => cp_isir_int_rec.third_college_cd,
        x_third_house_plan             => cp_isir_int_rec.third_house_plan_type,
        x_fourth_college               => cp_isir_int_rec.fourth_college_cd,
        x_fourth_house_plan            => cp_isir_int_rec.fourth_house_plan_type,
        x_fifth_college                => cp_isir_int_rec.fifth_college_cd,
        x_fifth_house_plan             => cp_isir_int_rec.fifth_house_plan_type,
        x_sixth_college                => cp_isir_int_rec.sixth_college_cd,
        x_sixth_house_plan             => cp_isir_int_rec.sixth_house_plan_type,
        x_date_app_completed           => cp_isir_int_rec.app_completed_date,
        x_signed_by                    => cp_isir_int_rec.signed_by_type,
        x_preparer_ssn                 => cp_isir_int_rec.preparer_ssn_txt,
        x_preparer_emp_id_number       => cp_isir_int_rec.preparer_emp_id_number_txt,
        x_preparer_sign                => cp_isir_int_rec.preparer_sign_flag,
        x_transaction_receipt_date     => cp_isir_int_rec.transaction_receipt_date,
        x_dependency_override_ind      => cp_isir_int_rec.dependency_override_type,
        x_faa_fedral_schl_code         => cp_isir_int_rec.faa_fedral_schl_cd,
        x_faa_adjustment               => cp_isir_int_rec.faa_adjustment_type,
        x_input_record_type            => cp_isir_int_rec.input_record_type,
        x_serial_number                => cp_isir_int_rec.serial_num,
        x_batch_number                 => cp_isir_int_rec.batch_number_txt,
        x_early_analysis_flag          => cp_isir_int_rec.early_analysis_flag,
        x_app_entry_source_code        => cp_isir_int_rec.app_entry_source_type,
        x_eti_destination_code         => cp_isir_int_rec.eti_destination_cd,
        x_reject_override_b            => cp_isir_int_rec.reject_override_b_flag,
        x_reject_override_n            => cp_isir_int_rec.reject_override_n_flag,
        x_reject_override_w            => cp_isir_int_rec.reject_override_w_flag,
        x_assum_override_1             => cp_isir_int_rec.assum_override_1_flag,
        x_assum_override_2             => cp_isir_int_rec.assum_override_2_flag,
        x_assum_override_3             => cp_isir_int_rec.assum_override_3_flag,
        x_assum_override_4             => cp_isir_int_rec.assum_override_4_flag,
        x_assum_override_5             => cp_isir_int_rec.assum_override_5_flag,
        x_assum_override_6             => cp_isir_int_rec.assum_override_6_flag,
        x_dependency_status            => cp_isir_int_rec.dependency_status_type,
        x_s_email_address              => cp_isir_int_rec.s_email_address_txt,
        x_nslds_reason_code            => cp_isir_int_rec.nslds_reason_cd,
        x_app_receipt_date             => cp_isir_int_rec.app_receipt_date,
        x_processed_rec_type           => cp_isir_int_rec.processed_rec_type,
        x_hist_correction_for_tran_id  => cp_isir_int_rec.hist_corr_for_tran_num,
        x_system_generated_indicator   => cp_isir_int_rec.sys_generated_indicator_type,
        x_dup_request_indicator        => cp_isir_int_rec.dup_request_indicator_type,
        x_source_of_correction         => cp_isir_int_rec.source_of_correction_type,
        x_p_cal_tax_status             => cp_isir_int_rec.p_cal_tax_status_type,
        x_s_cal_tax_status             => cp_isir_int_rec.s_cal_tax_status_type,
        x_graduate_flag                => cp_isir_int_rec.graduate_flag,
        x_auto_zero_efc                => cp_isir_int_rec.auto_zero_efc_flag,
        x_efc_change_flag              => cp_isir_int_rec.efc_change_flag,
        x_sarc_flag                    => cp_isir_int_rec.sarc_flag,
        x_simplified_need_test         => cp_isir_int_rec.simplified_need_test_flag,
        x_reject_reason_codes          => cp_isir_int_rec.reject_reason_codes_txt,
        x_select_service_match_flag    => cp_isir_int_rec.select_service_match_type,
        x_select_service_reg_flag      => cp_isir_int_rec.select_service_reg_type,
        x_ins_match_flag               => cp_isir_int_rec.ins_match_flag,
        x_ins_verification_number      => NULL,
        x_sec_ins_match_flag           => cp_isir_int_rec.sec_ins_match_type,
        x_sec_ins_ver_number           => cp_isir_int_rec.sec_ins_ver_num,
        x_ssn_match_flag               => cp_isir_int_rec.ssn_match_type,
        x_ssa_citizenship_flag         => cp_isir_int_rec.ssa_citizenship_type,
        x_ssn_date_of_death            => cp_isir_int_rec.ssn_death_date,
        x_nslds_match_flag             => cp_isir_int_rec.nslds_match_type,
        x_va_match_flag                => cp_isir_int_rec.va_match_type,
        x_prisoner_match               => cp_isir_int_rec.prisoner_match_flag,
        x_verification_flag            => cp_isir_int_rec.verification_flag,
        x_subsequent_app_flag          => cp_isir_int_rec.subsequent_app_flag,
        x_app_source_site_code         => cp_isir_int_rec.app_source_site_cd,
        x_tran_source_site_code        => cp_isir_int_rec.tran_source_site_cd,
        x_drn                          => cp_isir_int_rec.drn_num,
        x_tran_process_date            => cp_isir_int_rec.tran_process_date,
        x_computer_batch_number        => cp_isir_int_rec.computer_batch_num,
        x_correction_flags             => cp_isir_int_rec.correction_flags_txt,
        x_highlight_flags              => cp_isir_int_rec.highlight_flags_txt,
        x_paid_efc                     => NULL,
        x_primary_efc                  => cp_isir_int_rec.primary_efc_amt,
        x_secondary_efc                => cp_isir_int_rec.secondary_efc_amt,
        x_fed_pell_grant_efc_type      => NULL,
        x_primary_efc_type             => cp_isir_int_rec.primary_efc_type,
        x_sec_efc_type                 => cp_isir_int_rec.sec_efc_type,
        x_primary_alternate_month_1    => cp_isir_int_rec.primary_alt_month_1_amt,
        x_primary_alternate_month_2    => cp_isir_int_rec.primary_alt_month_2_amt,
        x_primary_alternate_month_3    => cp_isir_int_rec.primary_alt_month_3_amt,
        x_primary_alternate_month_4    => cp_isir_int_rec.primary_alt_month_4_amt,
        x_primary_alternate_month_5    => cp_isir_int_rec.primary_alt_month_5_amt,
        x_primary_alternate_month_6    => cp_isir_int_rec.primary_alt_month_6_amt,
        x_primary_alternate_month_7    => cp_isir_int_rec.primary_alt_month_7_amt,
        x_primary_alternate_month_8    => cp_isir_int_rec.primary_alt_month_8_amt,
        x_primary_alternate_month_10   => cp_isir_int_rec.primary_alt_month_10_amt,
        x_primary_alternate_month_11   => cp_isir_int_rec.primary_alt_month_11_amt,
        x_primary_alternate_month_12   => cp_isir_int_rec.primary_alt_month_12_amt,
        x_sec_alternate_month_1        => cp_isir_int_rec.sec_alternate_month_1_amt,
        x_sec_alternate_month_2        => cp_isir_int_rec.sec_alternate_month_2_amt,
        x_sec_alternate_month_3        => cp_isir_int_rec.sec_alternate_month_3_amt,
        x_sec_alternate_month_4        => cp_isir_int_rec.sec_alternate_month_4_amt,
        x_sec_alternate_month_5        => cp_isir_int_rec.sec_alternate_month_5_amt,
        x_sec_alternate_month_6        => cp_isir_int_rec.sec_alternate_month_6_amt,
        x_sec_alternate_month_7        => cp_isir_int_rec.sec_alternate_month_7_amt,
        x_sec_alternate_month_8        => cp_isir_int_rec.sec_alternate_month_8_amt,
        x_sec_alternate_month_10       => cp_isir_int_rec.sec_alternate_month_10_amt,
        x_sec_alternate_month_11       => cp_isir_int_rec.sec_alternate_month_11_amt,
        x_sec_alternate_month_12       => cp_isir_int_rec.sec_alternate_month_12_amt,
        x_total_income                 => cp_isir_int_rec.total_income_amt,
        x_allow_total_income           => cp_isir_int_rec.allow_total_income_amt,
        x_state_tax_allow              => cp_isir_int_rec.state_tax_allow_amt,
        x_employment_allow             => cp_isir_int_rec.employment_allow_amt,
        x_income_protection_allow      => cp_isir_int_rec.income_protection_allow_amt,
        x_available_income             => cp_isir_int_rec.available_income_amt,
        x_contribution_from_ai         => cp_isir_int_rec.contribution_from_ai_amt,
        x_discretionary_networth       => cp_isir_int_rec.discretionary_networth_amt,
        x_efc_networth                 => cp_isir_int_rec.efc_networth_amt,
        x_asset_protect_allow          => cp_isir_int_rec.asset_protect_allow_amt,
        x_parents_cont_from_assets     => cp_isir_int_rec.parents_cont_from_assets_amt,
        x_adjusted_available_income    => cp_isir_int_rec.adjusted_avail_income_amt,
        x_total_student_contribution   => cp_isir_int_rec.total_student_contrib_amt,
        x_total_parent_contribution    => cp_isir_int_rec.total_parent_contrib_amt,
        x_parents_contribution         => cp_isir_int_rec.parents_contribution_amt,
        x_student_total_income         => cp_isir_int_rec.student_total_income_amt,
        x_sati                         => cp_isir_int_rec.sati_amt,
        x_sic                          => cp_isir_int_rec.sic_amt,
        x_sdnw                         => cp_isir_int_rec.sdnw_amt,
        x_sca                          => cp_isir_int_rec.sca_amt,
        x_fti                          => cp_isir_int_rec.fti_amt,
        x_secti                        => cp_isir_int_rec.secti_amt,
        x_secati                       => cp_isir_int_rec.secati_amt,
        x_secstx                       => cp_isir_int_rec.secstx_amt,
        x_secea                        => cp_isir_int_rec.secea_amt,
        x_secipa                       => cp_isir_int_rec.secipa_amt,
        x_secai                        => cp_isir_int_rec.secai_amt,
        x_seccai                       => cp_isir_int_rec.seccai_amt,
        x_secdnw                       => cp_isir_int_rec.secdnw_amt,
        x_secnw                        => cp_isir_int_rec.secnw_amt,
        x_secapa                       => cp_isir_int_rec.secapa_amt,
        x_secpca                       => cp_isir_int_rec.SECPCA_AMT,
        x_secaai                       => cp_isir_int_rec.secaai_amt,
        x_sectsc                       => cp_isir_int_rec.sectsc_amt,
        x_sectpc                       => cp_isir_int_rec.sectpc_amt,
        x_secpc                        => cp_isir_int_rec.secpc_amt,
        x_secsti                       => cp_isir_int_rec.secsti_amt,
        x_secsic                       => cp_isir_int_rec.secsic_amt,
        x_secsati                      => cp_isir_int_rec.secsati_amt,
        x_secsdnw                      => cp_isir_int_rec.secsdnw_amt,
        x_secsca                       => cp_isir_int_rec.secsca_amt,
        x_secfti                       => cp_isir_int_rec.secfti_amt,
        x_a_citizenship                => cp_isir_int_rec.a_citizenship_flag,
        x_a_student_marital_status     => cp_isir_int_rec.a_studnt_marital_status_flag,
        x_a_student_agi                => cp_isir_int_rec.a_student_agi_amt,
        x_a_s_us_tax_paid              => cp_isir_int_rec.a_s_us_tax_paid_amt,
        x_a_s_income_work              => cp_isir_int_rec.a_s_income_work_amt,
        x_a_spouse_income_work         => cp_isir_int_rec.a_spouse_income_work_amt,
        x_a_s_total_wsc                => cp_isir_int_rec.a_s_total_wsc_amt,
        x_a_date_of_birth              => cp_isir_int_rec.a_date_of_birth_flag,
        x_a_student_married            => cp_isir_int_rec.a_student_married_flag,
        x_a_have_children              => cp_isir_int_rec.a_have_children_flag,
        x_a_s_have_dependents          => cp_isir_int_rec.a_s_have_dependents_flag,
        x_a_va_status                  => cp_isir_int_rec.a_va_status_flag,
        x_a_s_num_in_family            => cp_isir_int_rec.a_s_in_family_num,
        x_a_s_num_in_college           => cp_isir_int_rec.a_s_in_college_num,
        x_a_p_marital_status           => cp_isir_int_rec.a_p_marital_status_flag,
        x_a_father_ssn                 => cp_isir_int_rec.a_father_ssn_txt,
        x_a_mother_ssn                 => cp_isir_int_rec.a_mother_ssn_txt,
        x_a_parents_num_family         => cp_isir_int_rec.a_parents_family_num,
        x_a_parents_num_college        => cp_isir_int_rec.a_parents_college_num,
        x_a_parents_agi                => cp_isir_int_rec.a_parents_agi_amt,
        x_a_p_us_tax_paid              => cp_isir_int_rec.a_p_us_tax_paid_amt,
        x_a_f_work_income              => cp_isir_int_rec.a_f_work_income_amt,
        x_a_m_work_income              => cp_isir_int_rec.a_m_work_income_amt,
        x_a_p_total_wsc                => cp_isir_int_rec.a_p_total_wsc_amt,
        x_comment_codes                => cp_isir_int_rec.comment_codes_txt,
        x_sar_ack_comm_code            => cp_isir_int_rec.sar_ack_comm_codes_txt,
        x_pell_grant_elig_flag         => cp_isir_int_rec.pell_grant_elig_flag,
        x_reprocess_reason_code        => cp_isir_int_rec.reprocess_reason_cd,
        x_duplicate_date               => cp_isir_int_rec.duplicate_date,
        x_isir_transaction_type        => cp_isir_int_rec.isir_transaction_type,
        x_fedral_schl_code_indicator   => cp_isir_int_rec.fedral_schl_type,
        x_multi_school_code_flags      => cp_isir_int_rec.multi_school_cd_flags_txt,
        x_dup_ssn_indicator            => cp_isir_int_rec.dup_ssn_indicator_flag,
        x_system_record_type           => 'ORIGINAL',
        x_verif_track_flag             => cp_isir_int_rec.verif_track_type,
        x_payment_isir                 => p_payment_isir,
        x_receipt_status               => 'MATCHED',
        x_isir_receipt_completed       => 'N',
        x_active_isir                  => p_active_isir,
        x_fafsa_data_verify_flags      => cp_isir_int_rec.fafsa_data_verification_txt,
        x_reject_override_a            => cp_isir_int_rec.reject_override_a_flag,
        x_reject_override_c            => cp_isir_int_rec.reject_override_c_flag,
        x_parent_marital_status_date   => cp_isir_int_rec.parent_marital_status_date,
        x_legacy_record_flag           => NULL,
        x_father_first_name_initial    => cp_isir_int_rec.fathr_first_name_initial_txt,
        x_father_step_father_birth_dt  => cp_isir_int_rec.fathr_step_father_birth_date,
        x_mother_first_name_initial    => cp_isir_int_rec.mothr_first_name_initial_txt,
        x_mother_step_mother_birth_dt  => cp_isir_int_rec.mothr_step_mother_birth_date,
        x_parents_email_address_txt    => cp_isir_int_rec.parents_email_address_txt,
        x_address_change_type          => cp_isir_int_rec.address_change_type,
        x_cps_pushed_isir_flag         => cp_isir_int_rec.cps_pushed_isir_flag,
        x_electronic_transaction_type  => cp_isir_int_rec.electronic_transaction_type,
        x_sar_c_change_type            => cp_isir_int_rec.sar_c_change_type,
        x_father_ssn_match_type        => cp_isir_int_rec.father_ssn_match_type,
        x_mother_ssn_match_type        => cp_isir_int_rec.mother_ssn_match_type,
        x_reject_override_g_flag       => cp_isir_int_rec.reject_override_g_flag,
        x_dhs_verification_num_txt     => cp_isir_int_rec.dhs_verification_num_txt,
        x_data_file_name_txt           => cp_isir_int_rec.data_file_name_txt,
        x_message_class_txt            => l_mesg_class,
        x_reject_override_3_flag       => cp_isir_int_rec.reject_override_3_flag,
        x_reject_override_12_flag      => cp_isir_int_rec.reject_override_12_flag,
        x_reject_override_j_flag       => cp_isir_int_rec.reject_override_j_flag,
        x_reject_override_k_flag       => cp_isir_int_rec.reject_override_k_flag,
        x_rejected_status_change_flag  => cp_isir_int_rec.rejected_status_change_flag,
        x_verification_selection_flag  => cp_isir_int_rec.verification_selection_flag
       );

   log_debug_message(' SUccessfully Inserted ISIR Matched record. ISIR ID : ' || p_out_isir_id);
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.insert_isir_matched_rec.statement','Successfully inserted new ISIR record into ISIR Matched table. ISIR ID : ' || p_out_isir_id );
   END IF;
   RAM_I_M := RAM_I_M + 1;

EXCEPTION
   WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.insert_isir_matched_rec.exception','The exception is : ' || SQLERRM );
      END IF;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.insert_isir_matched_rec');
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
END insert_isir_matched_rec;



PROCEDURE insert_nslds_data_rec(cp_isir_intrface_rec  igf_ap_isir_ints%ROWTYPE,
                                p_isir_id             igf_ap_isir_matched_all.isir_id%TYPE,
                                p_base_id             NUMBER,
                                p_out_nslds_id        OUT NOCOPY NUMBER
                               )
IS
  /*
  ||  Created By : rgangara
  ||  Created On : 03-AUG-2004
  ||  Purpose :        For Inserting record into NSLDS data table based on ISIR int record.
  ||  Parameters :
  ||               1. p_out_nslds_id is OUT parameter returning the NSLDS id of the inserted record
  ||               2. p_isir_id is the isir_id of the corresponding record in isir matched table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||
  ||  (reverse chronological order - newest change first)
  */

  lv_rowid       VARCHAR2(30);

BEGIN

  log_debug_message(' Beginning Insert of NSLDS record for ISIR ID : ' || p_isir_id || '. Base ID : ' || p_base_id);

  lv_rowid   := NULL;
  -- Insert old record into ISIR Matched Table
  igf_ap_nslds_data_pkg.insert_row(
             x_Mode                                => 'R',
             x_rowid                               => lv_rowid,
             x_nslds_id                            => p_out_nslds_id,
             x_isir_id                             => p_isir_id,
             x_base_id                             => p_base_id,
             x_transaction_num_txt                 => cp_isir_intrface_rec.transaction_num_txt,
             x_nslds_transaction_num               => cp_isir_intrface_rec.nslds_transaction_num,
             x_nslds_database_results_f            => cp_isir_intrface_rec.nslds_database_results_type,
             x_nslds_f                             => cp_isir_intrface_rec.nslds_flag,
             x_nslds_pell_overpay_f                => cp_isir_intrface_rec.nslds_pell_overpay_type,
             x_nslds_pell_overpay_contact          => cp_isir_intrface_rec.nslds_pell_overpay_cont_txt,
             x_nslds_seog_overpay_f                => cp_isir_intrface_rec.nslds_seog_overpay_type,
             x_nslds_seog_overpay_contact          => cp_isir_intrface_rec.nslds_seog_overpay_cont_txt,
             x_nslds_perkins_overpay_f             => cp_isir_intrface_rec.nslds_perkins_overpay_type,
             x_nslds_perkins_overpay_cntct         => cp_isir_intrface_rec.nslds_perk_ovrpay_cntct_txt,
             x_nslds_defaulted_loan_f              => cp_isir_intrface_rec.nslds_defaulted_loan_flag,
             x_nslds_dischged_loan_chng_f          => cp_isir_intrface_rec.nslds_dischgd_loan_chng_flag,
             x_nslds_satis_repay_f                 => cp_isir_intrface_rec.nslds_satis_repay_flag,
             x_nslds_act_bankruptcy_f              => cp_isir_intrface_rec.nslds_act_bankruptcy_flag,
             x_nslds_agg_subsz_out_prin_bal        => cp_isir_intrface_rec.nslds_agg_subsz_out_pbal_amt,
             x_nslds_agg_unsbz_out_prin_bal        => cp_isir_intrface_rec.nslds_agg_unsbz_out_pbal_amt,
             x_nslds_agg_comb_out_prin_bal         => cp_isir_intrface_rec.nslds_agg_comb_out_pbal_amt,
             x_nslds_agg_cons_out_prin_bal         => cp_isir_intrface_rec.nslds_agg_cons_out_pbal_amt,
             x_nslds_agg_subsz_pend_dismt          => cp_isir_intrface_rec.nslds_agg_subsz_pnd_disb_amt,
             x_nslds_agg_unsbz_pend_dismt          => cp_isir_intrface_rec.nslds_agg_unsbz_pnd_disb_amt,
             x_nslds_agg_comb_pend_dismt           => cp_isir_intrface_rec.nslds_agg_comb_pend_disb_amt,
             x_nslds_agg_subsz_total               => cp_isir_intrface_rec.nslds_agg_subsz_total_amt,
             x_nslds_agg_unsbz_total               => cp_isir_intrface_rec.nslds_agg_unsbz_total_amt,
             x_nslds_agg_comb_total                => cp_isir_intrface_rec.nslds_agg_comb_total_amt,
             x_nslds_agg_consd_total               => cp_isir_intrface_rec.nslds_agg_consd_total_amt,
             x_nslds_perkins_out_bal               => cp_isir_intrface_rec.nslds_perkins_out_bal_amt,
             x_nslds_perkins_cur_yr_dismnt         => cp_isir_intrface_rec.nslds_perkin_cur_yr_disb_amt,
             x_nslds_default_loan_chng_f           => cp_isir_intrface_rec.nslds_default_loan_chng_flag,
             x_nslds_discharged_loan_f             => cp_isir_intrface_rec.nslds_discharged_loan_type,
             x_nslds_satis_repay_chng_f            => cp_isir_intrface_rec.nslds_satis_repay_chng_flag,
             x_nslds_act_bnkrupt_chng_f            => cp_isir_intrface_rec.nslds_act_bnkrupt_chng_flag,
             x_nslds_overpay_chng_f                => cp_isir_intrface_rec.nslds_overpay_chng_flag,
             x_nslds_agg_loan_chng_f               => cp_isir_intrface_rec.nslds_agg_loan_chng_flag,
             x_nslds_perkins_loan_chng_f           => cp_isir_intrface_rec.nslds_perkins_loan_chng_flag,
             x_nslds_pell_paymnt_chng_f            => cp_isir_intrface_rec.nslds_pell_paymnt_chng_flag,
             x_nslds_addtnl_pell_f                 => cp_isir_intrface_rec.nslds_addtnl_pell_flag,
             x_nslds_addtnl_loan_f                 => cp_isir_intrface_rec.nslds_addtnl_loan_flag,
             x_direct_loan_mas_prom_nt_f           => cp_isir_intrface_rec.direct_loan_mas_prom_nt_type,
             x_nslds_pell_seq_num_1                => cp_isir_intrface_rec.nslds_pell_1_seq_num,
             x_nslds_pell_verify_f_1               => cp_isir_intrface_rec.nslds_pell_1_verify_f_txt,
             x_nslds_pell_efc_1                    => cp_isir_intrface_rec.nslds_pell_1_efc_amt,
             x_nslds_pell_school_code_1            => cp_isir_intrface_rec.nslds_pell_1_school_num,
             x_nslds_pell_transcn_num_1            => cp_isir_intrface_rec.nslds_pell_1_transcn_num,
             x_nslds_pell_last_updt_dt_1           => cp_isir_intrface_rec.nslds_pell_1_last_updt_date,
             x_nslds_pell_scheduled_amt_1          => cp_isir_intrface_rec.nslds_pell_1_scheduled_amt,
             x_nslds_pell_amt_paid_todt_1          => cp_isir_intrface_rec.nslds_pell_1_paid_todt_amt,
             x_nslds_pell_remng_amt_1              => cp_isir_intrface_rec.nslds_pell_1_remng_amt,
             x_nslds_pell_pc_schd_awd_us_1         => cp_isir_intrface_rec.nslds_pell_1_pc_scwd_use_amt,
             x_nslds_pell_award_amt_1              => cp_isir_intrface_rec.nslds_pell_1_award_amt,
             x_nslds_pell_seq_num_2                => cp_isir_intrface_rec.nslds_pell_2_seq_num,
             x_nslds_pell_verify_f_2               => cp_isir_intrface_rec.nslds_pell_2_verify_f_txt,
             x_nslds_pell_efc_2                    => cp_isir_intrface_rec.nslds_pell_2_efc_amt,
             x_nslds_pell_school_code_2            => cp_isir_intrface_rec.nslds_pell_2_school_num,
             x_nslds_pell_transcn_num_2            => cp_isir_intrface_rec.nslds_pell_2_transcn_num,
             x_nslds_pell_last_updt_dt_2           => cp_isir_intrface_rec.nslds_pell_2_last_updt_date,
             x_nslds_pell_scheduled_amt_2          => cp_isir_intrface_rec.nslds_pell_2_scheduled_amt,
             x_nslds_pell_amt_paid_todt_2          => cp_isir_intrface_rec.nslds_pell_2_paid_todt_amt,
             x_nslds_pell_remng_amt_2              => cp_isir_intrface_rec.nslds_pell_2_remng_amt,
             x_nslds_pell_pc_schd_awd_us_2         => cp_isir_intrface_rec.nslds_pell_2_pc_scwd_use_amt,
             x_nslds_pell_award_amt_2              => cp_isir_intrface_rec.nslds_pell_2_award_amt,
             x_nslds_pell_seq_num_3                => cp_isir_intrface_rec.nslds_pell_3_seq_num,
             x_nslds_pell_verify_f_3               => cp_isir_intrface_rec.nslds_pell_3_verify_f_txt,
             x_nslds_pell_efc_3                    => cp_isir_intrface_rec.nslds_pell_3_efc_amt,
             x_nslds_pell_school_code_3            => cp_isir_intrface_rec.nslds_pell_3_school_num,
             x_nslds_pell_transcn_num_3            => cp_isir_intrface_rec.nslds_pell_3_transcn_num,
             x_nslds_pell_last_updt_dt_3           => cp_isir_intrface_rec.nslds_pell_3_last_updt_date,
             x_nslds_pell_scheduled_amt_3          => cp_isir_intrface_rec.nslds_pell_3_scheduled_amt,
             x_nslds_pell_amt_paid_todt_3          => cp_isir_intrface_rec.nslds_pell_3_paid_todt_amt,
             x_nslds_pell_remng_amt_3              => cp_isir_intrface_rec.nslds_pell_3_remng_amt,
             x_nslds_pell_pc_schd_awd_us_3         => cp_isir_intrface_rec.nslds_pell_3_pc_scwd_use_amt,
             x_nslds_pell_award_amt_3              => cp_isir_intrface_rec.nslds_pell_3_award_amt,
             x_nslds_loan_seq_num_1                => cp_isir_intrface_rec.nslds_loan_1_seq_num,
             x_nslds_loan_type_code_1              => cp_isir_intrface_rec.nslds_loan_1_type,
             x_nslds_loan_chng_f_1                 => cp_isir_intrface_rec.nslds_loan_1_chng_flag,
             x_nslds_loan_prog_code_1              => cp_isir_intrface_rec.nslds_loan_1_prog_cd,
             x_nslds_loan_net_amnt_1               => cp_isir_intrface_rec.nslds_loan_1_net_amt,
             x_nslds_loan_cur_st_code_1            => cp_isir_intrface_rec.nslds_loan_1_cur_st_cd,
             x_nslds_loan_cur_st_date_1            => cp_isir_intrface_rec.nslds_loan_1_cur_st_date,
             x_nslds_loan_agg_pr_bal_1             => cp_isir_intrface_rec.nslds_loan_1_agg_pr_bal_amt,
             x_nslds_loan_out_pr_bal_dt_1          => cp_isir_intrface_rec.nslds_loan_1_out_pr_bal_date,
             x_nslds_loan_begin_dt_1               => cp_isir_intrface_rec.nslds_loan_1_begin_date,
             x_nslds_loan_end_dt_1                 => cp_isir_intrface_rec.nslds_loan_1_end_date,
             x_nslds_loan_ga_code_1                => cp_isir_intrface_rec.nslds_loan_1_ga_cd,
             x_nslds_loan_cont_type_1              => cp_isir_intrface_rec.nslds_loan_1_cont_type,
             x_nslds_loan_schol_code_1             => cp_isir_intrface_rec.nslds_loan_1_schol_cd,
             x_nslds_loan_cont_code_1              => cp_isir_intrface_rec.nslds_loan_1_cont_cd,
             x_nslds_loan_grade_lvl_1              => cp_isir_intrface_rec.nslds_loan_1_grade_lvl_txt,
             x_nslds_loan_xtr_unsbz_ln_f_1         => cp_isir_intrface_rec.nslds_loan_1_x_unsbz_ln_type,
             x_nslds_loan_capital_int_f_1          => cp_isir_intrface_rec.nslds_loan_1_captal_int_flag,
             x_nslds_loan_seq_num_2                => cp_isir_intrface_rec.nslds_loan_2_seq_num,
             x_nslds_loan_type_code_2              => cp_isir_intrface_rec.nslds_loan_2_type,
             x_nslds_loan_chng_f_2                 => cp_isir_intrface_rec.nslds_loan_2_chng_flag,
             x_nslds_loan_prog_code_2              => cp_isir_intrface_rec.nslds_loan_2_prog_cd,
             x_nslds_loan_net_amnt_2               => cp_isir_intrface_rec.nslds_loan_2_net_amt,
             x_nslds_loan_cur_st_code_2            => cp_isir_intrface_rec.nslds_loan_2_cur_st_cd,
             x_nslds_loan_cur_st_date_2            => cp_isir_intrface_rec.nslds_loan_2_cur_st_date,
             x_nslds_loan_agg_pr_bal_2             => cp_isir_intrface_rec.nslds_loan_2_agg_pr_bal_amt,
             x_nslds_loan_out_pr_bal_dt_2          => cp_isir_intrface_rec.nslds_loan_2_out_pr_bal_date,
             x_nslds_loan_begin_dt_2               => cp_isir_intrface_rec.nslds_loan_2_begin_date,
             x_nslds_loan_end_dt_2                 => cp_isir_intrface_rec.nslds_loan_2_end_date,
             x_nslds_loan_ga_code_2                => cp_isir_intrface_rec.nslds_loan_2_ga_cd,
             x_nslds_loan_cont_type_2              => cp_isir_intrface_rec.nslds_loan_2_cont_type,
             x_nslds_loan_schol_code_2             => cp_isir_intrface_rec.nslds_loan_2_schol_cd,
             x_nslds_loan_cont_code_2              => cp_isir_intrface_rec.nslds_loan_2_cont_cd,
             x_nslds_loan_grade_lvl_2              => cp_isir_intrface_rec.nslds_loan_2_grade_lvl_txt,
             x_nslds_loan_xtr_unsbz_ln_f_2         => cp_isir_intrface_rec.nslds_loan_2_x_unsbz_ln_type,
             x_nslds_loan_capital_int_f_2          => cp_isir_intrface_rec.nslds_loan_2_captal_int_flag,
             x_nslds_loan_seq_num_3                => cp_isir_intrface_rec.nslds_loan_3_seq_num,
             x_nslds_loan_type_code_3              => cp_isir_intrface_rec.nslds_loan_3_type,
             x_nslds_loan_chng_f_3                 => cp_isir_intrface_rec.nslds_loan_3_chng_flag,
             x_nslds_loan_prog_code_3              => cp_isir_intrface_rec.nslds_loan_3_prog_cd,
             x_nslds_loan_net_amnt_3               => cp_isir_intrface_rec.nslds_loan_3_net_amt,
             x_nslds_loan_cur_st_code_3            => cp_isir_intrface_rec.nslds_loan_3_cur_st_cd,
             x_nslds_loan_cur_st_date_3            => cp_isir_intrface_rec.nslds_loan_3_cur_st_date,
             x_nslds_loan_agg_pr_bal_3             => cp_isir_intrface_rec.nslds_loan_3_agg_pr_bal_amt,
             x_nslds_loan_out_pr_bal_dt_3          => cp_isir_intrface_rec.nslds_loan_3_out_pr_bal_date,
             x_nslds_loan_begin_dt_3               => cp_isir_intrface_rec.nslds_loan_3_begin_date,
             x_nslds_loan_end_dt_3                 => cp_isir_intrface_rec.nslds_loan_3_end_date,
             x_nslds_loan_ga_code_3                => cp_isir_intrface_rec.nslds_loan_3_ga_cd,
             x_nslds_loan_cont_type_3              => cp_isir_intrface_rec.nslds_loan_3_cont_type,
             x_nslds_loan_schol_code_3             => cp_isir_intrface_rec.nslds_loan_3_schol_cd,
             x_nslds_loan_cont_code_3              => cp_isir_intrface_rec.nslds_loan_3_cont_cd,
             x_nslds_loan_grade_lvl_3              => cp_isir_intrface_rec.nslds_loan_3_grade_lvl_txt,
             x_nslds_loan_xtr_unsbz_ln_f_3         => cp_isir_intrface_rec.nslds_loan_3_x_unsbz_ln_type,
             x_nslds_loan_capital_int_f_3          => cp_isir_intrface_rec.nslds_loan_3_captal_int_flag,
             x_nslds_loan_seq_num_4                => cp_isir_intrface_rec.nslds_loan_4_seq_num,
             x_nslds_loan_type_code_4              => cp_isir_intrface_rec.nslds_loan_4_type,
             x_nslds_loan_chng_f_4                 => cp_isir_intrface_rec.nslds_loan_4_chng_flag,
             x_nslds_loan_prog_code_4              => cp_isir_intrface_rec.nslds_loan_4_prog_cd,
             x_nslds_loan_net_amnt_4               => cp_isir_intrface_rec.nslds_loan_4_net_amt,
             x_nslds_loan_cur_st_code_4            => cp_isir_intrface_rec.nslds_loan_4_cur_st_cd,
             x_nslds_loan_cur_st_date_4            => cp_isir_intrface_rec.nslds_loan_4_cur_st_date,
             x_nslds_loan_agg_pr_bal_4             => cp_isir_intrface_rec.nslds_loan_4_agg_pr_bal_amt,
             x_nslds_loan_out_pr_bal_dt_4          => cp_isir_intrface_rec.nslds_loan_4_out_pr_bal_date,
             x_nslds_loan_begin_dt_4               => cp_isir_intrface_rec.nslds_loan_4_begin_date,
             x_nslds_loan_end_dt_4                 => cp_isir_intrface_rec.nslds_loan_4_end_date,
             x_nslds_loan_ga_code_4                => cp_isir_intrface_rec.nslds_loan_4_ga_cd,
             x_nslds_loan_cont_type_4              => cp_isir_intrface_rec.nslds_loan_4_cont_type,
             x_nslds_loan_schol_code_4             => cp_isir_intrface_rec.nslds_loan_4_schol_cd,
             x_nslds_loan_cont_code_4              => cp_isir_intrface_rec.nslds_loan_4_cont_cd,
             x_nslds_loan_grade_lvl_4              => cp_isir_intrface_rec.nslds_loan_4_grade_lvl_txt,
             x_nslds_loan_xtr_unsbz_ln_f_4         => cp_isir_intrface_rec.nslds_loan_4_x_unsbz_ln_type,
             x_nslds_loan_capital_int_f_4          => cp_isir_intrface_rec.nslds_loan_4_captal_int_flag,
             x_nslds_loan_seq_num_5                => cp_isir_intrface_rec.nslds_loan_5_seq_num,
             x_nslds_loan_type_code_5              => cp_isir_intrface_rec.nslds_loan_5_type,
             x_nslds_loan_chng_f_5                 => cp_isir_intrface_rec.nslds_loan_5_chng_flag,
             x_nslds_loan_prog_code_5              => cp_isir_intrface_rec.nslds_loan_5_prog_cd,
             x_nslds_loan_net_amnt_5               => cp_isir_intrface_rec.nslds_loan_5_net_amt,
             x_nslds_loan_cur_st_code_5            => cp_isir_intrface_rec.nslds_loan_5_cur_st_cd,
             x_nslds_loan_cur_st_date_5            => cp_isir_intrface_rec.nslds_loan_5_cur_st_date,
             x_nslds_loan_agg_pr_bal_5             => cp_isir_intrface_rec.nslds_loan_5_agg_pr_bal_amt,
             x_nslds_loan_out_pr_bal_dt_5          => cp_isir_intrface_rec.nslds_loan_5_out_pr_bal_date,
             x_nslds_loan_begin_dt_5               => cp_isir_intrface_rec.nslds_loan_5_begin_date,
             x_nslds_loan_end_dt_5                 => cp_isir_intrface_rec.nslds_loan_5_end_date,
             x_nslds_loan_ga_code_5                => cp_isir_intrface_rec.nslds_loan_5_ga_cd,
             x_nslds_loan_cont_type_5              => cp_isir_intrface_rec.nslds_loan_5_cont_type,
             x_nslds_loan_schol_code_5             => cp_isir_intrface_rec.nslds_loan_5_schol_cd,
             x_nslds_loan_cont_code_5              => cp_isir_intrface_rec.nslds_loan_5_cont_cd,
             x_nslds_loan_grade_lvl_5              => cp_isir_intrface_rec.nslds_loan_5_grade_lvl_txt,
             x_nslds_loan_xtr_unsbz_ln_f_5         => cp_isir_intrface_rec.nslds_loan_5_x_unsbz_ln_type,
             x_nslds_loan_capital_int_f_5          => cp_isir_intrface_rec.nslds_loan_5_captal_int_flag,
             x_nslds_loan_seq_num_6                => cp_isir_intrface_rec.nslds_loan_6_seq_num,
             x_nslds_loan_type_code_6              => cp_isir_intrface_rec.nslds_loan_6_type,
             x_nslds_loan_chng_f_6                 => cp_isir_intrface_rec.nslds_loan_6_chng_flag,
             x_nslds_loan_prog_code_6              => cp_isir_intrface_rec.nslds_loan_6_prog_cd,
             x_nslds_loan_net_amnt_6               => cp_isir_intrface_rec.nslds_loan_6_net_amt,
             x_nslds_loan_cur_st_code_6            => cp_isir_intrface_rec.nslds_loan_6_cur_st_cd,
             x_nslds_loan_cur_st_date_6            => cp_isir_intrface_rec.nslds_loan_6_cur_st_date,
             x_nslds_loan_agg_pr_bal_6             => cp_isir_intrface_rec.nslds_loan_6_agg_pr_bal_amt,
             x_nslds_loan_out_pr_bal_dt_6          => cp_isir_intrface_rec.nslds_loan_6_out_pr_bal_date,
             x_nslds_loan_begin_dt_6               => cp_isir_intrface_rec.nslds_loan_6_begin_date,
             x_nslds_loan_end_dt_6                 => cp_isir_intrface_rec.nslds_loan_6_end_date,
             x_nslds_loan_ga_code_6                => cp_isir_intrface_rec.nslds_loan_6_ga_cd,
             x_nslds_loan_cont_type_6              => cp_isir_intrface_rec.nslds_loan_6_cont_type,
             x_nslds_loan_schol_code_6             => cp_isir_intrface_rec.nslds_loan_6_schol_cd,
             x_nslds_loan_cont_code_6              => cp_isir_intrface_rec.nslds_loan_6_cont_cd,
             x_nslds_loan_grade_lvl_6              => cp_isir_intrface_rec.nslds_loan_6_grade_lvl_txt,
             x_nslds_loan_xtr_unsbz_ln_f_6         => cp_isir_intrface_rec.nslds_loan_6_x_unsbz_ln_type,
             x_nslds_loan_capital_int_f_6          => cp_isir_intrface_rec.nslds_loan_6_captal_int_flag,
             x_nslds_loan_last_d_amt_1             => cp_isir_intrface_rec.nslds_loan_1_last_disb_amt,
             x_nslds_loan_last_d_date_1            => cp_isir_intrface_rec.nslds_loan_1_last_disb_date,
             x_nslds_loan_last_d_amt_2             => cp_isir_intrface_rec.nslds_loan_2_last_disb_amt,
             x_nslds_loan_last_d_date_2            => cp_isir_intrface_rec.nslds_loan_2_last_disb_date,
             x_nslds_loan_last_d_amt_3             => cp_isir_intrface_rec.nslds_loan_3_last_disb_amt,
             x_nslds_loan_last_d_date_3            => cp_isir_intrface_rec.nslds_loan_3_last_disb_date,
             x_nslds_loan_last_d_amt_4             => cp_isir_intrface_rec.nslds_loan_4_last_disb_amt,
             x_nslds_loan_last_d_date_4            => cp_isir_intrface_rec.nslds_loan_4_last_disb_date,
             x_nslds_loan_last_d_amt_5             => cp_isir_intrface_rec.nslds_loan_5_last_disb_amt,
             x_nslds_loan_last_d_date_5            => cp_isir_intrface_rec.nslds_loan_5_last_disb_date,
             x_nslds_loan_last_d_amt_6             => cp_isir_intrface_rec.nslds_loan_6_last_disb_amt,
             x_nslds_loan_last_d_date_6            => cp_isir_intrface_rec.nslds_loan_6_last_disb_date,
             x_dlp_master_prom_note_flag           => cp_isir_intrface_rec.dlp_master_prom_note_type,
             x_subsidized_loan_limit_type          => cp_isir_intrface_rec.subsidized_loan_limit_type,
             x_combined_loan_limit_type            => cp_isir_intrface_rec.combined_loan_limit_type
            );

   log_debug_message(' Successfully Inserted NSLDS record. NSLDS ID : ' || p_out_nslds_id);

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.insert_nslds_data_rec.statement','Inserted data into NSLDS data table. NSLDS ID : ' || p_out_nslds_id);
   END IF;
   RAM_I_N := RAM_I_N + 1;

EXCEPTION
   WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.insert_nslds_data_rec.exception','The exception is : ' || SQLERRM );
      END IF;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.insert_nslds_data_rec');
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
END insert_nslds_data_rec;

PROCEDURE create_ssn(cp_person_id igs_pe_alt_pers_id.pe_person_id%TYPE,
                       cp_original_ssn_txt VARCHAR2
                      )
   IS

     /*
    ||  Created By : rajagupt
    ||  Created On : 06-Oct-2005
    ||  Purpose : create SSN record
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    */

   lv_rowid ROWID;
  BEGIN

     IGS_PE_ALT_PERS_ID_PKG.INSERT_ROW (
        X_ROWID => lv_rowid,
        X_PE_PERSON_ID  => cp_person_id,
        X_API_PERSON_ID => cp_original_ssn_txt,
        X_PERSON_ID_TYPE  => 'SSN',
        X_START_DT   => SYSDATE,
        X_END_DT => NULL,
                    X_ATTRIBUTE_CATEGORY => NULL,
                    X_ATTRIBUTE1         => NULL,
                    X_ATTRIBUTE2         => NULL,
                    X_ATTRIBUTE3         => NULL,
                    X_ATTRIBUTE4         => NULL,
                    X_ATTRIBUTE5         => NULL,
                    X_ATTRIBUTE6         => NULL,
                    X_ATTRIBUTE7         => NULL,
                    X_ATTRIBUTE8         => NULL,
                    X_ATTRIBUTE9         => NULL,
                    X_ATTRIBUTE10        => NULL,
                    X_ATTRIBUTE11        => NULL,
                    X_ATTRIBUTE12        => NULL,
                    X_ATTRIBUTE13        => NULL,
                    X_ATTRIBUTE14        => NULL,
                    X_ATTRIBUTE15        => NULL,
                    X_ATTRIBUTE16        => NULL,
                    X_ATTRIBUTE17        => NULL,
                    X_ATTRIBUTE18        => NULL,
                    X_ATTRIBUTE19        => NULL,
                    X_ATTRIBUTE20        => NULL,
        X_REGION_CD          => NULL,
        X_MODE =>  'R'
        );
  END create_ssn;


PROCEDURE insert_fa_base_record( pn_person_id            NUMBER,
                                 pn_base_id   OUT NOCOPY NUMBER)
IS
  /*
  ||  Created By : rgangara
  ||  Created On : 17-AUG-2004
  ||  Purpose :        Inserts a new FA base record for the person.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  ridas         14-Feb-2006        Bug #5021084. Removed trunc function from cursor SSN_CUR
  ||  rajagupt      6-Oct-2005         Bug#4068548 - added a new cursor ssn_cur
  ||  (reverse chronological order - newest change first)
  */

   -- cursor to get the ssn no of a person
    CURSOR ssn_cur(cp_person_id number) IS
    SELECT api_person_id,api_person_id_uf, end_dt
     FROM   igs_pe_alt_pers_id
     WHERE  pe_person_id=cp_person_id
     AND    person_id_type like 'SSN'
     AND    SYSDATE < = NVL(end_dt,SYSDATE);

    rec_ssn_cur   ssn_cur%ROWTYPE;

    lv_profile_value VARCHAR2(20);
    l_award_fmly_contr_type VARCHAR2(1);
    lv_rowid                VARCHAR2(30);
    l_fed_verif_status      igf_ap_fa_base_rec_all.fed_verif_status%TYPE;

BEGIN

   log_debug_message(' Beginning Insert of FA Base Record. Person ID ' || pn_person_id);

   l_fed_verif_status := NULL; -- initialize to NULL

   IF NVL(g_isir_intrface_rec.verification_flag,'X') = 'Y' THEN
      l_fed_verif_status := 'SELECTED';
   ELSE
      l_fed_verif_status := 'NOTSELECTED';
   END IF;


   IF (g_isir_intrface_rec.secondary_efc_amt IS NOT NULL) AND
      (g_isir_intrface_rec.secondary_efc_amt < NVL(g_isir_intrface_rec.primary_efc_amt,0)) THEN

      l_award_fmly_contr_type := '2';
   ELSE
     l_award_fmly_contr_type := '1';
   END IF;


   lv_rowid := NULL;

   -- call TBH to insert a new rec
   --check if the ssn no is available or not

    fnd_profile.get('IGF_AP_SSN_REQ_FOR_BASE_REC',lv_profile_value);

    IF(lv_profile_value = 'Y')  THEN
      OPEN ssn_cur(pn_person_id) ;
      FETCH ssn_cur INTO rec_ssn_cur;
       IF ssn_cur%NOTFOUND THEN
         CLOSE ssn_cur;
         create_ssn(pn_person_id, g_isir_intrface_rec.original_ssn_txt );
       ELSE
         CLOSE ssn_cur;
       END IF;
     END IF;

         igf_ap_fa_base_rec_pkg.insert_row(
         x_Mode                                  => 'R',
         x_rowid                                 => lv_rowid,
         x_base_id                               => pn_base_id,
         x_ci_cal_type                           => g_ci_cal_type,
         x_person_id                             => pn_person_id,
         x_ci_sequence_number                    => g_ci_sequence_number,
         x_org_id                                => NULL,
         x_coa_pending                           => NULL,
         x_verification_process_run              => 'N',
         x_inst_verif_status_date                => NULL,
         x_manual_verif_flag                     => NULL,
         x_fed_verif_status                      => l_fed_verif_status,
         x_fed_verif_status_date                 => TRUNC(SYSDATE),
         x_inst_verif_status                     => NULL,
         x_nslds_eligible                        => g_isir_intrface_rec.nslds_match_type,
         x_ede_correction_batch_id               => NULL,
         x_fa_process_status_date                => TRUNC(SYSDATE),
         x_isir_corr_status                      => NULL,
         x_isir_corr_status_date                 => NULL,
         x_isir_status                           => 'Received-Valid', -- Bug 3169500
         x_isir_status_date                      => TRUNC(SYSDATE),
         x_coa_code_f                            => NULL,
         x_coa_code_i                            => NULL,
         x_coa_f                                 => NULL,
         x_coa_i                                 => NULL,
         x_disbursement_hold                     => NULL,
         x_fa_process_status                     => 'RECEIVED',
         x_notification_status                   => NULL,
         x_notification_status_date              => NULL,
         x_packaging_status                      => NULL,
         x_packaging_status_date                 => NULL,
         x_total_package_accepted                => NULL,
         x_total_package_offered                 => NULL,
         x_admstruct_id                          => NULL,
         x_admsegment_1                          => NULL,
         x_admsegment_2                          => NULL,
         x_admsegment_3                          => NULL,
         x_admsegment_4                          => NULL,
         x_admsegment_5                          => NULL,
         x_admsegment_6                          => NULL,
         x_admsegment_7                          => NULL,
         x_admsegment_8                          => NULL,
         x_admsegment_9                          => NULL,
         x_admsegment_10                         => NULL,
         x_admsegment_11                         => NULL,
         x_admsegment_12                         => NULL,
         x_admsegment_13                         => NULL,
         x_admsegment_14                         => NULL,
         x_admsegment_15                         => NULL,
         x_admsegment_16                         => NULL,
         x_admsegment_17                         => NULL,
         x_admsegment_18                         => NULL,
         x_admsegment_19                         => NULL,
         x_admsegment_20                         => NULL,
         x_packstruct_id                         => NULL,
         x_packsegment_1                         => NULL,
         x_packsegment_2                         => NULL,
         x_packsegment_3                         => NULL,
         x_packsegment_4                         => NULL,
         x_packsegment_5                         => NULL,
         x_packsegment_6                         => NULL,
         x_packsegment_7                         => NULL,
         x_packsegment_8                         => NULL,
         x_packsegment_9                         => NULL,
         x_packsegment_10                        => NULL,
         x_packsegment_11                        => NULL,
         x_packsegment_12                        => NULL,
         x_packsegment_13                        => NULL,
         x_packsegment_14                        => NULL,
         x_packsegment_15                        => NULL,
         x_packsegment_16                        => NULL,
         x_packsegment_17                        => NULL,
         x_packsegment_18                        => NULL,
         x_packsegment_19                        => NULL,
         x_packsegment_20                        => NULL,
         x_miscstruct_id                         => NULL,
         x_miscsegment_1                         => NULL,
         x_miscsegment_2                         => NULL,
         x_miscsegment_3                         => NULL,
         x_miscsegment_4                         => NULL,
         x_miscsegment_5                         => NULL,
         x_miscsegment_6                         => NULL,
         x_miscsegment_7                         => NULL,
         x_miscsegment_8                         => NULL,
         x_miscsegment_9                         => NULL,
         x_miscsegment_10                        => NULL,
         x_miscsegment_11                        => NULL,
         x_miscsegment_12                        => NULL,
         x_miscsegment_13                        => NULL,
         x_miscsegment_14                        => NULL,
         x_miscsegment_15                        => NULL,
         x_miscsegment_16                        => NULL,
         x_miscsegment_17                        => NULL,
         x_miscsegment_18                        => NULL,
         x_miscsegment_19                        => NULL,
         x_miscsegment_20                        => NULL,
         x_prof_judgement_flg                    => NULL,
         x_nslds_data_override_flg               => NULL,
         x_target_group                          => NULL,
         x_coa_fixed                             => NULL,
         x_coa_pell                              => NULL,
         x_profile_status                        => NULL,
         x_profile_status_date                   => NULL,
         x_profile_fc                            => NULL,
         x_manual_disb_hold                      => NULL,
         x_pell_alt_expense                      => NULL,
         x_assoc_org_num                         => NULL,
         x_award_fmly_contribution_type          => l_award_fmly_contr_type,
         x_packaging_hold                        => NULL,
         x_isir_locked_by                        => NULL,
         x_adnl_unsub_loan_elig_flag             => 'N',
         x_lock_awd_flag                         => 'N',
         x_lock_coa_flag                         => 'N'

   );


   IF pn_base_id IS NULL THEN
      fnd_message.set_name ('IGF', 'IGF_AP_ERR_FA_REC');
      fnd_file.put_line(fnd_file.log,fnd_message.get );
      app_exception.raise_exception;
   END IF;

   log_debug_message(' Successfully inserted FA Base Record. Base ID: ' || pn_base_id);
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.insert_fa_base_record.statement','Inserted FA Base Record. BASE ID : ' || pn_base_id || ', Person ID:' || pn_person_id);
   END IF;

   g_base_id := pn_base_id; -- populate global variable

   fnd_message.set_name('IGF','IGF_AP_ISIR_FA_BASE_CREATED');
   fnd_file.put_line(fnd_file.log, fnd_message.get);
   RAM_I_F := RAM_I_F + 1;

EXCEPTION
    WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.insert_fa_base_record.exception','The exception is : ' || SQLERRM );
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.insert_fa_base_record');
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
END insert_fa_base_record;



PROCEDURE update_prsn_match_rec_status(p_apm_id      NUMBER,
                                       p_rec_status  VARCHAR2)
IS
  /*
  ||  Created By : rgangara
  ||  Created On : 17-AUG-2004
  ||  Purpose :    Generic procedure for Updating records in Person Match and Match Details table.
  ||               Generally record status is updated.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||
  ||  (reverse chronological order - newest change first)
  */

   -- Person match
   CURSOR cur_person_match (cp_apm_id NUMBER) IS
   SELECT apm.rowid row_id,
          apm.*
     FROM igf_ap_person_match_all apm
    WHERE apm.apm_id = cp_apm_id
    FOR UPDATE NOWAIT;

   -- match details
   CURSOR match_details_cur (cp_apm_id NUMBER) IS
   SELECT amd.rowid row_id,
          amd.*
   FROM   igf_ap_match_details amd
   WHERE  amd.apm_id = cp_apm_id
   FOR UPDATE NOWAIT;

BEGIN

   log_debug_message(' Beginning update_prsn_match_rec_status proc');

   FOR person_match_rec IN cur_person_match(p_apm_id) LOOP

      -- call the TBH to update the isir matched record
      igf_ap_person_match_pkg.update_row(
                   x_rowid                =>        person_match_rec.row_id ,
                   x_apm_id               =>        person_match_rec.apm_id ,
                   x_css_id               =>        person_match_rec.css_id ,
                   x_si_id                =>        person_match_rec.si_id ,
                   x_record_type          =>        person_match_rec.record_type,
                   x_date_run             =>        person_match_rec.date_run ,
                   x_ci_sequence_number   =>        person_match_rec.ci_sequence_number,
                   x_ci_cal_type          =>        person_match_rec.ci_cal_type       ,
                   x_record_status        =>        p_rec_status,
                   x_mode                 =>        'R'
                   );

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.update_prsn_match_rec_status.statement',' Updated Record Status for APM ID : ' || person_match_rec.apm_id);
      END IF;
      RAM_U_PM := RAM_U_PM + 1;

      -- update record status for corresponding match detail records
      FOR match_details_rec IN match_details_cur(person_match_rec.apm_id) LOOP

         -- call TBH for updating corresp recs.
         igf_ap_match_details_pkg.update_row(
                      x_mode              => 'R',
                      x_rowid             => match_details_rec.row_id,
                      x_amd_id            => match_details_rec.amd_id,
                      x_apm_id            => match_details_rec.apm_id,
                      x_person_id         => match_details_rec.person_id ,
                      x_ssn_match         => match_details_rec.ssn_match ,
                      x_given_name_match  => match_details_rec.given_name_match,
                      x_surname_match     => match_details_rec.surname_match   ,
                      x_dob_match         => match_details_rec.dob_match       ,
                      x_address_match     => match_details_rec.address_match   ,
                      x_city_match        => match_details_rec.city_match      ,
                      x_zip_match         => match_details_rec.zip_match       ,
                      x_match_score       => match_details_rec.match_score     ,
                      x_record_status     => p_rec_status                      ,
                       x_ssn_txt           => match_details_rec.ssn_txt          , -- update
                       x_given_name_txt   => match_details_rec.given_name_txt  ,
                       x_sur_name_txt     => match_details_rec.sur_name_txt    ,
                       x_birth_date       => match_details_rec.birth_date      ,
                       x_address_txt      => match_details_rec.address_txt     ,
                       x_city_txt         => match_details_rec.city_txt        ,
                       x_zip_txt          => match_details_rec.zip_txt         ,
                       x_gender_txt       => match_details_rec.gender_txt      ,
                       x_email_id_txt     => match_details_rec.email_id_txt    ,
                       x_gender_match     => match_details_rec.gender_match    ,
                       x_email_id_match   => match_details_rec.email_id_match
                   );


         RAM_U_MD := RAM_U_MD + 1;
         log_debug_message(' Updated Match Details record status to : ' || p_rec_status);
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.update_prsn_match_rec_status.statement',' Updated Record Status for Person ID : ' || match_details_rec.person_id || '  AMD ID: ' || match_details_rec.amd_id);
         END IF;
      END LOOP; -- match_details_rec
   END LOOP; -- person_match_rec

EXCEPTION
   WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.update_prsn_match_rec_status.exception','The exception is : ' || SQLERRM );
      END IF;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.update_prsn_match_rec_status');
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
END update_prsn_match_rec_status;


PROCEDURE raise_cps_pushed_isir_event
IS
  /*
  ||  Created By : rgangara
  ||  Created On : 26-AUG-2004
  ||  Purpose :    Called when a CPS Pushed ISIR is processed. Raises a business event notification
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||
  ||  (reverse chronological order - newest change first)
  */


   l_message_class      VARCHAR2(30);
   l_event_t            wf_event_t;
   l_raise_event        VARCHAR2(50);
   l_seq_val            VARCHAR2(100);
   l_parameter_list_t   wf_parameter_list_t;

   CURSOR person_dtls_cur(cp_person_id NUMBER) IS
   SELECT party_number
   FROM   hz_parties
   WHERE  party_id = cp_person_id;

   l_person_num  hz_parties.party_number%TYPE;

   CURSOR get_fa_rec_verif_stat (pn_base_id NUMBER) IS
   SELECT fed_verif_status
     FROM igf_ap_fa_base_rec_all
    WHERE base_id = pn_base_id;

    l_verification_status igf_ap_fa_base_rec_all.fed_verif_status%TYPE;
BEGIN

   l_seq_val := 'IGFAPW06'|| TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'); -- for unique identification

   log_debug_message(' Beginning  raise_cps_pushed_isir_event Proc for raising Notification');
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.processed_cps_pushed_isir.statement','Raising Business event Notification for a CPS Pushed ISIR. Message Class:' || l_message_class);
   END IF;


   OPEN get_fa_rec_verif_stat(g_base_id);
   FETCH get_fa_rec_verif_stat INTO l_verification_status;
   CLOSE get_fa_rec_verif_stat ;

   IF l_verification_status NOT IN ('ACCURATE','REPROCESSED','WITHOUTDOC') THEN
      log_debug_message('No need to raise notification as the Verification Status is NOT complete.');
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.processed_cps_pushed_isir.statement','No need to raise notification as the Verification Status is NOT complete');
      END IF;

      RETURN;
   END IF;

   log_debug_message('Raising Business event Notification');
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.processed_cps_pushed_isir.statement','Raising Business event Notification');
   END IF;

   IF g_person_id IS NOT NULL THEN
      OPEN person_dtls_cur(g_person_id);
      FETCH person_dtls_cur INTO l_person_num;
      CLOSE person_dtls_cur ;
   END IF;


   -- Raise Business Event Notification
   l_raise_event := 'oracle.apps.igf.ap.PushedIsir';

   -- initialize the wf_event_t object
   wf_event_t.initialize(l_event_t);

   -- Adding the parameters to the parameter list
   wf_event.addparametertolist( p_name          => 'M_SI_ID',
                                p_value         => g_isir_intrface_rec.si_id  ,
                                p_parameterlist => l_parameter_list_t);


   wf_event.addparametertolist( p_name          => 'M_ORIG_SSN',
                                p_value         => g_isir_intrface_rec.original_ssn_txt,
                                p_parameterlist => l_parameter_list_t);


   wf_event.addparametertolist( p_name          => 'M_TRANSACTION_NUM',
                                p_value         => g_isir_intrface_rec.transaction_num_txt,
                                p_parameterlist => l_parameter_list_t);


   wf_event.addparametertolist( p_name          => 'M_FIRST_NAME',
                                p_value         => g_isir_intrface_rec.first_name,
                                p_parameterlist => l_parameter_list_t);

   wf_event.addparametertolist( p_name          => 'M_PERSON_NUM',
                                p_value         => l_person_num,
                                p_parameterlist => l_parameter_list_t);


   -- Set this role to the workflow
   wf_event.addparametertolist( p_name          => 'M_EMAIL_USER_NAME',
                                p_value         => fnd_global.user_name,
                                p_parameterlist => l_parameter_list_t);

   --Raise the event...
   wf_event.raise (p_event_name => l_raise_event,
                   p_event_key  => l_seq_val,
                   p_parameters => l_parameter_list_t);

   -- Deleting the Parameter list after the event is raised
   l_parameter_list_t.delete;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.processed_cps_pushed_isir.statement','Raised Business event Notification for a CPS Pushed ISIR. Message Class:' || l_message_class);
   END IF;
   log_debug_message(' Raised CPS PUSHED ISIR Business Event successfully.')  ;

EXCEPTION
  WHEN OTHERS THEN
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.raise_cps_pushed_isir_event.exception','The exception is : ' || SQLERRM );
     END IF;

     wf_core.context('IGF_AP_PushedIsir_WF', 'PUSHEDISIR', l_seq_val, l_raise_event);

     fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','igf_ap_matching_process_pkg.raise_cps_pushed_isir_event');
     igs_ge_msg_stack.add;
     fnd_file.put_line(fnd_file.log, ' - '|| SQLERRM);
     RAISE;
END raise_cps_pushed_isir_event;


PROCEDURE raise_demographic_chng_event
IS
  /*
  ||  Created By : rgangara
  ||  Created On : 26-AUG-2004
  ||  Purpose :    Called when there is changes to Person demographic data. Raises a business event notification
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||
  ||  (reverse chronological order - newest change first)
  */


   l_message_class      VARCHAR2(30);
   l_event_t            wf_event_t;
   l_raise_event        VARCHAR2(50);
   l_seq_val            VARCHAR2(100);
   l_parameter_list_t   wf_parameter_list_t;

   CURSOR person_dtls_cur(cp_person_id NUMBER) IS
   SELECT party_number
   FROM   hz_parties
   WHERE  party_id = cp_person_id;

   l_person_num  hz_parties.party_number%TYPE;

BEGIN

   l_seq_val := 'DATACHNG'|| TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'); -- for unique identification

   log_debug_message(' Beginning demographic data changed event. Person ID: ' || g_person_id);

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.raise_demographic_chng_event.statement','Raising demographic data changes Business event Notification. Person ID : ' || g_person_id);
   END IF;

   IF g_person_id IS NOT NULL THEN
      OPEN person_dtls_cur(g_person_id);
      FETCH person_dtls_cur INTO l_person_num;
      CLOSE person_dtls_cur ;
   END IF;


   -- Raise Business Event Notification
   l_raise_event := 'oracle.apps.igf.ap.DemographicChange';

   -- initialize the wf_event_t object
   wf_event_t.initialize(l_event_t);

   -- Adding the parameters to the parameter list
   wf_event.addparametertolist( p_name          => 'M_SI_ID',
                                p_value         => g_isir_intrface_rec.si_id  ,
                                p_parameterlist => l_parameter_list_t);

   wf_event.addparametertolist( p_name          => 'M_PERSON_NUM',
                                p_value         => l_person_num,
                                p_parameterlist => l_parameter_list_t);


   wf_event.addparametertolist( p_name          => 'M_ORIG_SSN',
                                p_value         => g_isir_intrface_rec.original_ssn_txt,
                                p_parameterlist => l_parameter_list_t);


   wf_event.addparametertolist( p_name          => 'M_TRANSACTION_NUM',
                                p_value         => g_isir_intrface_rec.transaction_num_txt,
                                p_parameterlist => l_parameter_list_t);

   wf_event.addparametertolist( p_name          => 'M_SSN',
                                p_value         => g_isir_intrface_rec.current_ssn_txt,
                                p_parameterlist => l_parameter_list_t);


   wf_event.addparametertolist( p_name          => 'M_FIRST_NAME',
                                p_value         => INITCAP(g_isir_intrface_rec.first_name),
                                p_parameterlist => l_parameter_list_t);


   wf_event.addparametertolist( p_name          => 'M_LAST_NAME',
                                p_value         => INITCAP(g_isir_intrface_rec.last_name),
                                p_parameterlist => l_parameter_list_t);


   wf_event.addparametertolist( p_name          => 'M_GENDER',
                                p_value         => g_isir_intrface_rec.ss_r_u_male_flag,
                                p_parameterlist => l_parameter_list_t);

   wf_event.addparametertolist( p_name          => 'M_BIRTH_DT',
                                p_value         => g_isir_intrface_rec.birth_date,
                                p_parameterlist => l_parameter_list_t);


   wf_event.addparametertolist( p_name          => 'M_ADDRESS',
                                p_value         => INITCAP(g_isir_intrface_rec.perm_mail_address_txt),
                                p_parameterlist => l_parameter_list_t);

   wf_event.addparametertolist( p_name          => 'M_CITY',
                                p_value         => INITCAP(g_isir_intrface_rec.perm_city_txt),
                                p_parameterlist => l_parameter_list_t);


   wf_event.addparametertolist( p_name          => 'M_ZIP_CODE',
                                p_value         => g_isir_intrface_rec.perm_zip_cd,
                                p_parameterlist => l_parameter_list_t);

   wf_event.addparametertolist( p_name          => 'M_EMAIL',
                                p_value         => g_isir_intrface_rec.s_email_address_txt,
                                p_parameterlist => l_parameter_list_t);

   -- Set this role to the workflow
   wf_event.addparametertolist( p_name          => 'M_RECIPIENT',
                                p_value         => fnd_global.user_name,
                                p_parameterlist => l_parameter_list_t);

   --Raise the event...
   wf_event.raise (p_event_name => l_raise_event,
                   p_event_key  => l_seq_val,
                   p_parameters => l_parameter_list_t);

   -- Deleting the Parameter list after the event is raised
   l_parameter_list_t.delete;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.raise_demographic_chng_event.statement','Raised Demographic data changes Business event Notification. Message Class:' ||l_message_class);
   END IF;

   log_debug_message('Completed demographic data changed event. Raised Notification');

EXCEPTION
  WHEN OTHERS THEN
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.raise_demographic_chng_event.exception','The exception is : ' || SQLERRM );
     END IF;

     wf_core.context('IGF_AP_DemographicChange_WF', 'DEMOGRAPHICCHANGE', l_seq_val, l_raise_event); -- RAMMOHAN check name

     fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','igf_ap_matching_process_pkg.raise_demographic_chng_event');
     igs_ge_msg_stack.add;
     fnd_file.put_line(fnd_file.log, ' - '|| SQLERRM);
     RAISE;
END raise_demographic_chng_event;

PROCEDURE create_updt_email_address(p_person_id    NUMBER)
IS
  /*
  ||  Created By : rgangara
  ||  Created On : 19-AUG-2004
  ||  Purpose :    For Inserting new Primary Email Address if none exists Else Insert a new Email Address as Non Primary
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  museshad         29-Sep-2005       Bug 4291874.
  ||                                     If the Person record has an email id and if the ISIR
  ||                                     being imported has a different email id, do not add
  ||                                     the new email address to the person record and log a
  ||                                     message. If the email id in the ISIR matches with that
  ||                                     in the Person record, then don't log any message.
  ||                                     Implemented this. Note, this is applicable only for
  ||                                     the first ISIR getting imported. If an ISIR is already
  ||                                     imported and a new ISIR comes in with the above
  ||                                     scenario then a Notification event is raised.
  ||  (reverse chronological order - newest change first)
  */


    CURSOR cur_chk_email_addr (cp_person_id   hz_parties.party_id%TYPE)
    IS
    SELECT 'Y' is_email_exists, email_address
    FROM  hz_parties
    WHERE party_id = cp_person_id
    AND   email_address IS NOT NULL;

    l_chk_email     cur_chk_email_addr%ROWTYPE;


    CURSOR  c_get_obj_version(cp_person_id           hz_contact_points.owner_table_id%TYPE,
                              cp_primary_flag        hz_contact_points.primary_flag%TYPE,
                              cp_contact_point_type  hz_contact_points.contact_point_type%TYPE)
    IS
    SELECT object_version_number,
           contact_point_id
    FROM   hz_contact_points
    WHERE  owner_table_id        = cp_person_id
    AND    contact_point_type    = cp_contact_point_type
    AND    NVL(primary_flag,'X') = cp_primary_flag;


    p_contact_points_rec    hz_contact_point_v2pub.contact_point_rec_type;
    p_email_rec             hz_contact_point_v2pub.email_rec_type := NULL;
    p_phone_rec             hz_contact_point_v2pub.phone_rec_type;
    l_obj_ver               hz_contact_points.object_version_number%TYPE;
    l_contact_point_id      hz_contact_points.contact_point_id%TYPE := NULL;
    l_obj_version           hz_contact_points.object_version_number%TYPE;
    l_return_status         VARCHAR2(25);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(4000);


BEGIN
   SAVEPOINT email_SP1;

   log_debug_message(' Beginning create/update email address. Person ID : ' || p_person_id);
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.create_updt_email_address.debug','Beginning create_updt_email_address for person_id : ' || p_person_id);
   END IF;

   -- check whether email already exists for the person
   OPEN cur_chk_email_addr(p_person_id);
   FETCH cur_chk_email_addr INTO l_chk_email;
   CLOSE cur_chk_email_addr;

   -- initialize rec variables
   p_contact_points_rec.contact_point_type :=  'EMAIL';
   p_contact_points_rec.owner_table_name := 'HZ_PARTIES';
   p_contact_points_rec.owner_table_id := p_person_id;
   p_contact_points_rec.content_source_type := 'USER_ENTERED';
   p_contact_points_rec.created_by_module := 'IGF';
   p_email_rec.email_format := 'MAILHTML';
   p_email_rec.email_address := g_isir_intrface_rec.s_email_address_txt;

   IF l_chk_email.is_email_exists = 'Y' THEN
      -- Email already exists, so don't insert email again.

      IF UPPER(l_chk_email.email_address) <> UPPER(g_isir_intrface_rec.s_email_address_txt) THEN
        -- Email in ISIR is different from that in the Person record. Log the email id
        fnd_message.set_name('IGF','IGF_AP_ISIR_EMAIL_NTFND');
        fnd_message.set_token('EMAIL_ID', g_isir_intrface_rec.s_email_address_txt);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,
                       'igf.plsql.igf_ap_matching_process_pkg.create_updt_email_address.debug',
                       'Person id ' ||p_person_id|| ' already has email. Not considering email address in ISIR');
      END IF;
   ELSE
      -- Email does not exist. Hence insert a new e-mail address as Primary
      p_contact_points_rec.primary_flag := 'Y';

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,
                       'igf.plsql.igf_ap_matching_process_pkg.create_updt_email_address.debug',
                       'Person id ' ||p_person_id|| ' does not have email. Inserting email address into Person record from ISIR');
      END IF;

     -- call the API to insert Email Address
     HZ_CONTACT_POINT_V2PUB.create_contact_point(
                                  p_init_msg_list         => FND_API.G_FALSE,
                                  p_contact_point_rec     => p_contact_points_rec,
                                  p_email_rec             => p_email_rec,
                                  p_phone_rec             => p_phone_rec,
                                  x_return_status         => l_return_status,
                                  x_msg_count             => l_msg_count,
                                  x_msg_data              => l_msg_data,
                                  x_contact_point_id      => l_contact_point_id
                              );
   END IF;

   RAM_I_HZ := RAM_I_HZ + 1;
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.create_updt_email_address.debug','Email Creation resulted in Status : ' || l_return_status || ', Person ID: ' || p_person_id);
   END IF;

   IF l_return_status IN ('E','U') THEN
      ROLLBACK TO email_SP1;
      RETURN;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.create_updt_email_address.exception','The exception is : ' || SQLERRM );
      END IF;
      ROLLBACK TO email_SP1;

      fnd_file.put_line(FND_FILE.LOG ,l_msg_data||fnd_global.newline ||'STATUS:'||l_return_status);
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.create_updt_email_address');
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      igs_ge_msg_stack.add;
END create_updt_email_address;

PROCEDURE update_person_info (pn_isir_id  igf_ap_isir_matched.isir_id%TYPE)
IS
  /*
  ||  Created By : rgangara
  ||  Created On : 17-AUG-2004
  ||  Purpose :    To identify changes to Person Demographic data by comparing OSS Person data with incoming ISIR data.
  ||               This would only be invoked when the Incoming ISIR Transaction No. is > Existing Max transaction No.
  ||               NOTE: This procedure does not change any existing demographic data but only sends a WF Notification.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  ridas            14-Feb-2006       Bug #5021084. Added SYSDATE condition in cursor ALT_PERSON_ID_CUR.
  ||  museshad         07-Oct-2005       Bug 4291874.
  ||                                     If the Person does not have email in hzparties
  ||                                     and if the ISIR has an email, then update the
  ||                                     Person record with the email. Note, a change
  ||                                     notification event is NOT raised for this.
  ||  (reverse chronological order - newest change first)
  */

   CURSOR isir_cur (cp_isir_id igf_ap_isir_matched.isir_id%TYPE)  IS
   SELECT ssn_name_change_type,
         first_name,
         last_name,
         current_ssn_txt,
         s_email_address_txt,
         perm_mail_address_txt,
         perm_city_txt,
         perm_state_txt,
         perm_zip_cd,
         birth_date,
         ss_r_u_male_flag
   FROM  igf_ap_isir_ints
   WHERE si_id = cp_isir_id;

   isir_rec   isir_cur%ROWTYPE;


   CURSOR person_cur  (ln_person_id  igf_ap_fa_base_rec.person_id%TYPE)  IS
   SELECT person_number,
          api_person_id,
          birth_dt,
          sex
     FROM igs_pe_person
    WHERE person_id = ln_person_id;

   person_rec  person_cur%ROWTYPE;

   CURSOR hzparties_cur (ln_person_id  igf_ap_fa_base_rec.person_id%TYPE)  IS
   SELECT person_first_name,
          person_last_name,
          address1,
          city,
          postal_code,
          state,
          email_address
     FROM hz_parties
    WHERE party_id = ln_person_id;

   hzparties_rec  hzparties_cur%ROWTYPE;



   CURSOR alt_person_id_cur (ln_api_person_id igs_pe_alt_pers_id.api_person_id%TYPE,
                             ln_person_id igf_ap_fa_base_rec.person_id%TYPE) IS
   SELECT rowid  row_id,
          altp.*
     FROM igs_pe_alt_pers_id  altp
    WHERE altp.pe_person_id = ln_person_id
      AND altp.api_person_id = ln_api_person_id
      AND SYSDATE BETWEEN altp.start_dt and NVL(altp.end_dt, SYSDATE);

   CURSOR person_id_type_cur ( cp_pers_id_type  VARCHAR2 ) IS
   SELECT person_id_type
     FROM igs_pe_person_id_typ
    WHERE s_person_id_type = cp_pers_id_type ;

   l_pers_id_type   igs_pe_person_id_typ.person_id_type%TYPE;


   CURSOR cur_lkups(cp_lkup_type VARCHAR2, cp_lkup_cd VARCHAR2) IS
   SELECT tag
   FROM   igf_lookups_view
   WHERE  lookup_type = cp_lkup_type
     AND  lookup_code = cp_lkup_cd
     AND  enabled_flag = 'Y';


   ln_person_number           hz_parties.party_number%TYPE;
   ln_person_id               igf_ap_fa_base_rec.person_id%TYPE;
   lv_person_id_type          igs_pe_person_id_typ.person_id_type%TYPE;
   alt_person_id_rec          alt_person_id_cur%ROWTYPE;
   ln_msg_count               NUMBER;
   lv_msg_data                VARCHAR2(2000);
   lv_return_status           VARCHAR2(1);
   lv_row_id                  VARCHAR2(30);
   ld_end_date                DATE;
   lv_sex                     igf_lookups_view.lookup_code%TYPE;
   lv_oss_sex_val             VARCHAR2(30);
   l_demo_data_changed        VARCHAR2(1);
BEGIN

   log_debug_message(' Beginning Person Update info Proc. Person ID : ' || g_person_id);

   IF g_called_from_process THEN

      -- Internal flag set to prevent requerying the ISIR interface record
      isir_rec := NULL;
      isir_rec.ssn_name_change_type := g_isir_intrface_rec.ssn_name_change_type ;
      isir_rec.first_name           := g_isir_intrface_rec.first_name ;
      isir_rec.last_name            := g_isir_intrface_rec.last_name ;
      isir_rec.current_ssn_txt      := g_isir_intrface_rec.current_ssn_txt ;
      isir_rec.s_email_address_txt  := g_isir_intrface_rec.s_email_address_txt;
      isir_rec.ss_r_u_male_flag     := g_isir_intrface_rec.ss_r_u_male_flag;
      isir_rec.perm_mail_address_txt:= g_isir_intrface_rec.perm_mail_address_txt;
      isir_rec.perm_city_txt        := g_isir_intrface_rec.perm_city_txt;
      isir_rec.perm_state_txt       := g_isir_intrface_rec.perm_state_txt;
      isir_rec.perm_zip_cd          := g_isir_intrface_rec.perm_zip_cd;
      isir_rec.birth_date           := g_isir_intrface_rec.birth_date;

   ELSE
      isir_rec := NULL;
      OPEN  isir_cur ( pn_isir_id);
      FETCH isir_cur INTO isir_rec;
      CLOSE isir_cur;
   END IF;

   ln_person_id := g_person_id ;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.person_update_info.debug','Checking for any person data changes for person : ' || ln_person_id);
   END IF;


   -- get person details from OSS
   OPEN   hzparties_cur(ln_person_id);
   FETCH  hzparties_cur INTO hzparties_rec;
   CLOSE  hzparties_cur;

   -- get remaining person details from OSS
   OPEN person_cur(ln_person_id);
   FETCH  person_cur INTO person_rec;
   CLOSE  person_cur;

   -- get the eqvivalent OSS SEX value from Lookups
   OPEN cur_lkups('IGF_AP_ISIR_GENDER', isir_rec.ss_r_u_male_flag);
   FETCH cur_lkups INTO lv_oss_sex_val;

   IF cur_lkups%NOTFOUND THEN
      lv_oss_sex_val := 'UNSPECIFIED' ;
   END IF;
   CLOSE cur_lkups;
   log_debug_message(' Gender Value ' || lv_oss_sex_val);

   -- get SSN DETAILS
   l_pers_id_type := 'SSN' ;
   -- validate SSN alt person id type
   OPEN person_id_type_cur (l_pers_id_type) ;
   FETCH person_id_type_cur INTO lv_person_id_type;

   IF person_id_type_cur%NOTFOUND THEN
      fnd_message.set_name ('IGF','IGF_AP_PER_ID_NOT_SET');
      fnd_file.put_line ( FND_FILE.LOG, fnd_message.get);
   END IF;
   CLOSE person_id_type_cur;


   FOR alt_person_id_rec IN alt_person_id_cur (person_rec.api_person_id, ln_person_id)
   LOOP

      log_debug_message(' End Date for Alternate Person ID fetched by alt_person_id_cur : ' || TO_CHAR(alt_person_id_rec.end_dt));
      -- check whether the alt pers id is active
      IF SYSDATE > alt_person_id_rec.end_dt THEN
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.person_update_info.debug','SSN Type Alternate Person ID record for the person is already End Dated. SSN No.: ' || person_rec.api_person_id);
         END IF;

         EXIT; --
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.person_update_info.debug','Active Alternate Person ID record found for the person. SSN No.:' || person_rec.api_person_id);
      END IF;
   END LOOP;

   -- museshad (Bug 4291874)
   IF hzparties_rec.email_address IS NULL THEN
      create_updt_email_address(p_person_id => ln_person_id);
      hzparties_rec.email_address := isir_rec.s_email_address_txt;
   END IF;
   -- museshad (Bug 4291874)

   -- NOW compare OSS values with the new ISIR values and determine whether any data has changed.
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.person_update_info.debug','Comparing OSS data with ISIR data to identify changes to demographic data');
   END IF;

   l_demo_data_changed := 'N'; -- initialize

   IF NVL(isir_rec.current_ssn_txt, '*')  <> NVL(person_rec.api_person_id, '~') THEN
      l_demo_data_changed := 'Y';
   END IF;

   IF UPPER(lv_oss_sex_val) <> NVL(UPPER(person_rec.sex), '*') THEN
      -- sex value derived using lookups.
      l_demo_data_changed := 'Y';
   END IF;

   IF NVL(isir_rec.birth_date, SYSDATE) <> NVL(person_rec.birth_dt, SYSDATE-1) THEN
      l_demo_data_changed := 'Y';
   END IF;


   IF NVL(isir_rec.first_name, '*') <> NVL(hzparties_rec.person_first_name, '~') THEN
      l_demo_data_changed := 'Y';
   END IF;


   IF NVL(isir_rec.last_name, '*')  <> NVL(hzparties_rec.person_last_name, '~') THEN
      l_demo_data_changed := 'Y';
   END IF;


   IF NVL(isir_rec.perm_mail_address_txt, '*') <> NVL(hzparties_rec.address1, '~') THEN
      l_demo_data_changed := 'Y';
   END IF;


   IF NVL(isir_rec.perm_city_txt, '*') <> NVL(hzparties_rec.city, '~') THEN
      l_demo_data_changed := 'Y';
   END IF;


   IF NVL(isir_rec.perm_zip_cd, '*') <> NVL(hzparties_rec.postal_code, '~') THEN
      l_demo_data_changed := 'Y';
   END IF;


   IF NVL(isir_rec.perm_state_txt, '*') <> NVL(hzparties_rec.state, '~') THEN
      l_demo_data_changed := 'Y';
   END IF;

   IF NVL(isir_rec.s_email_address_txt, '*') <> NVL(hzparties_rec.email_address, '~') THEN
      l_demo_data_changed := 'Y';
   END IF;


   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.person_update_info.debug','Person Demographic data changed: ' || l_demo_data_changed);
   END IF;
   log_debug_message('Person Demographic data changed flag :  ' || l_demo_data_changed);


   IF l_demo_data_changed = 'Y' THEN

      -- raise notification
      raise_demographic_chng_event; -- call the procedure to raise the event

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.person_update_info.debug','Person Demographic data changed and hence send notification: ');
      END IF;
   END IF;
   log_debug_message('Completed  update_person_info Proc. Person data changed ? : ' || l_demo_data_changed);

EXCEPTION
    WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.update_person_info.exception','The exception is : ' || SQLERRM );
      END IF;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.update_person_info');
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
END update_person_info;


PROCEDURE validate_correction_school(p_payment_isir      OUT NOCOPY VARCHAR2)
IS
  /*
  ||  Created By : rgangara
  ||  Created On : 24-AUG-2004
  ||  Purpose :    Called when Pell Match Type is 'N' and is a CORRECTION isir i.e. processed rec type is H
  ||               This procedure validates School code or raises a WORKFLOW notification if not valid.
  ||               Flags the OUT parameters based on the outcome of the validation.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||
  ||  (reverse chronological order - newest change first)
  */


  -- cursor to check whether the school code is valid or not
   CURSOR c_valid_fed_school(cp_fed_school igf_sl_school_codes_v.alternate_identifier%TYPE,
                             cp_system_id_type igf_sl_school_codes_v.system_id_type%TYPE)
   IS
   SELECT  'X'
     FROM  igf_sl_school_codes_v
    WHERE  system_id_type= cp_system_id_type
      AND  alternate_identifier = cp_fed_school;


   CURSOR cur_per_det (p_party_id    NUMBER, p_party_type  VARCHAR2) IS
   SELECT p.party_number person_number,
          p.person_first_name given_names
     FROM hz_parties   p
    WHERE p.party_id   = p_party_id
      AND p.party_type = p_party_type;


   l_cur_per_rec       cur_per_det%ROWTYPE;

   CURSOR get_payment_isir (ln_base_id NUMBER) IS
   SELECT isir_id
     FROM igf_ap_ISIR_matched isir
    WHERE base_id = ln_base_id
      AND payment_isir = 'Y' ;

   lv_chk_py_isir_rec get_payment_isir%ROWTYPE;

   CURSOR check_correction_items (ln_base_id NUMBER) IS
   SELECT 'x'
     FROM igf_ap_ISIR_matched isir, igf_ap_isir_corr_all corr
    WHERE isir.isir_id = corr.isir_id
      AND isir.base_id = ln_base_id;

   lv_chk_corrections check_correction_items%ROWTYPE;

   lv_rowid            VARCHAR2(30);
   l_transaction_num   CHAR(13);
   l_ow_id             NUMBER;
   l_message           VARCHAR2(100);
   l_send_workflow     BOOLEAN;
   l_college_code      igf_sl_school_codes_v.alternate_identifier%TYPE;
   l_chk_valid         VARCHAR2(1);

BEGIN

   log_debug_message('Beginning validate_correction_school proc');
   -- initialize OUT parameters
   l_send_workflow := FALSE;
   l_college_code  := NULL;
   p_payment_isir  := 'N';

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.validate_correction_school.debug','This ISIR is a Correction ISIR. Performing School validation' );
   END IF;

   IF NVL(g_isir_intrface_rec.fedral_schl_type,'X') NOT IN ('1','2','3','4','5','6') THEN
      -- invalid.. Lot a message and send WF notification
      l_send_workflow := TRUE;
      l_message := 'IGF_AP_INVALID_ELEC_FED_SCH';
   ELSE

      -- ckeck if the FEDRAL_SCHL_CODE_INDICATOR is null or not in 1 to 6 and flag accordingly.
      IF g_isir_intrface_rec.fedral_schl_type = '1' THEN
         IF g_isir_intrface_rec.first_college_cd IS NOT NULL THEN
            l_college_code := g_isir_intrface_rec.first_college_cd;
         ELSE
            l_send_workflow := TRUE;
         END IF;

      ELSIF g_isir_intrface_rec.fedral_schl_type = '2' THEN
         IF g_isir_intrface_rec.second_college_cd IS NOT NULL THEN
            l_college_code := g_isir_intrface_rec.second_college_cd;
         ELSE
            l_send_workflow := TRUE;
         END IF;

      ELSIF g_isir_intrface_rec.fedral_schl_type = '3' THEN
         IF g_isir_intrface_rec.third_college_cd IS NOT NULL THEN
            l_college_code := g_isir_intrface_rec.third_college_cd;
         ELSE
            l_send_workflow := TRUE;
         END IF;

      ELSIF g_isir_intrface_rec.fedral_schl_type = '4' THEN
         IF g_isir_intrface_rec.fourth_college_cd IS NOT NULL THEN
            l_college_code := g_isir_intrface_rec.fourth_college_cd;
         ELSE
            l_send_workflow := TRUE;
         END IF;

      ELSIF g_isir_intrface_rec.fedral_schl_type = '5' THEN
         IF g_isir_intrface_rec.fifth_college_cd IS NOT NULL THEN
            l_college_code := g_isir_intrface_rec.fifth_college_cd;
         ELSE
            l_send_workflow := TRUE;
         END IF;

      ELSIF g_isir_intrface_rec.fedral_schl_type = '6' THEN
         IF g_isir_intrface_rec.sixth_college_cd IS NOT NULL THEN
            l_college_code := g_isir_intrface_rec.sixth_college_cd;
         ELSE
            l_send_workflow := TRUE;
         END IF;
      END IF;
      log_debug_message('Correction School code is ' || l_college_code);

      IF l_college_code IS NOT NULL THEN

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.validate_correction_school.debug','Correction School code is : ' || l_college_code);
         END IF;

         -- open the cursor to see if the l_school_code obtained is valid or not
         l_chk_valid := NULL;
         OPEN  c_valid_fed_school(l_college_code,'FED_SCH_CD');
         FETCH c_valid_fed_school INTO l_chk_valid;
         CLOSE c_valid_fed_school;

         IF l_chk_valid IS NULL THEN
            -- Check if the student has at least 1 Payment ISIR
            -- If he does not then the School Code validation does not matter.
            lv_chk_py_isir_rec := NULL;

            OPEN  get_payment_isir(g_base_id);
            FETCH get_payment_isir INTO lv_chk_py_isir_rec ;
            CLOSE get_payment_isir;

            IF lv_chk_py_isir_rec.isir_id IS NOT NULL THEN
               l_send_workflow := TRUE;
               l_message := 'IGF_AP_FED_NOT_IN_SYSTEM';
            ELSE
               -- no valid isir present, so check for correction items
               -- if there are no correction items, mark the current isir as payment isir, else raise wf event.
               -- refer to bug 4532047
              OPEN  check_correction_items(g_base_id);
              FETCH check_correction_items INTO lv_chk_corrections ;
              IF check_correction_items%FOUND THEN
                l_send_workflow := TRUE;
                l_message := 'IGF_AP_FED_NOT_IN_SYSTEM';
              END IF;
              CLOSE check_correction_items;

            END IF;
         END IF; --l_chk_valid


         -- WF is raised only when validation fails. Hence if it is FALSE then the current isir can be a payment ISIR.
         IF l_send_workflow = FALSE THEN
                 p_payment_isir      := 'Y' ;  -- set the OUT parameter to Y
         END IF;

      END IF; -- l_college_code
   END IF; -- g_isir_intrface_rec.fedral_schl_type


   -- Send Workflow as Correction Record not originated from the context school
   IF l_send_workflow THEN
      l_message := NVL(l_message, 'IGF_AP_FEDSCH_NOT_CONTEXT');
      log_debug_message(' School Validation Worflow required');

      -- log message in log file
      IF l_message = 'IGF_AP_FEDSCH_NOT_CONTEXT' THEN
         -- get person number
         OPEN  cur_per_det(g_person_id, 'PERSON') ;
         FETCH cur_per_det into l_cur_per_rec;
         CLOSE cur_per_det;

         fnd_message.set_name('IGF','IGF_AP_FEDSCH_NOT_SAME');
         fnd_message.set_token('PERSON_NUM', l_cur_per_rec.person_number);

      ELSIF l_message = 'IGF_AP_INVALID_ELEC_FED_SCH' THEN
         fnd_message.set_name('IGF','IGF_AP_INVALID_ELEC_FED_SCH');

      ELSE
         fnd_message.set_name('IGF','IGF_AP_FED_NOT_IN_SYSTEM');
         fnd_message.set_token('FEDCODE',l_college_code);
      END IF;

      fnd_file.put_line(fnd_file.log, fnd_message.get);

      l_transaction_num  :=  g_isir_intrface_rec.original_ssn_txt||g_isir_intrface_rec.orig_name_id_txt||g_isir_intrface_rec.transaction_num_txt;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.validate_correction_school.debug','Sending School Code validation workflow notification');
      END IF;

      lv_rowid := NULL;
      igf_ap_outcorr_wf_pkg.insert_row (
                      x_rowid               => lv_rowid,
                      x_person_number       => l_cur_per_rec.person_number,
                      x_given_names         => l_cur_per_rec.given_names,
                      x_transaction_number  => l_transaction_num,
                      x_item_key            => 'NEW',
                      x_ow_id               => l_ow_id,
                      x_mode                => 'R');

      RAM_U_O := RAM_U_O + 1;
      log_debug_message(' Worflow Raised from validate_correction_school proc ');
   END IF;
   log_debug_message('Successfully  completed validate_correction_school proc');

EXCEPTION
   WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.validate_correction_school.exception','The exception is : ' || SQLERRM );
      END IF;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.validate_correction_school');
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
END validate_correction_school;


PROCEDURE delete_person_match_rec(p_si_id  igf_ap_person_match_all.si_id%TYPE,
                                  p_apm_id igf_ap_person_match_all.apm_id%TYPE)
IS
 /*
  ||  Created By : rgangara
  ||  Created On : 06-AUG-2004
  ||  Purpose :    Deletes records from Match details and then from Person match tables.
  ||               This proc can be called by passing either SI_ID or APM_ID. If apm_id is NULL then process on SI_ID.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */

   -- to get the apm ID based on si_id
   CURSOR cur_prsn_match_siid(cp_si_id NUMBER) IS
   SELECT pm.apm_id
     FROM igf_ap_person_match pm
    WHERE pm.si_id = cp_si_id;

   -- to get the row_id based on apm_id
   CURSOR cur_prsn_match_apm(cp_apm_id NUMBER) IS
   SELECT pm.row_id, pm.apm_id
     FROM igf_ap_person_match pm
    WHERE pm.apm_id = cp_apm_id ;


   CURSOR cur_match_dtls(cp_apm_id  igf_ap_person_match_all.apm_id%TYPE) IS
   SELECT amd.amd_id
     FROM igf_ap_match_details amd
    WHERE amd.apm_id = cp_apm_id;

   l_apm_id  igf_ap_person_match_all.apm_id%TYPE;
   l_cnt_match_dtls NUMBER;

BEGIN

   log_debug_message(' Beginning delete_person_match_rec Proc for SI_ID: ' || p_si_id || '. APM_ID : ' || p_apm_id);

   -- Get the apm_id based on SI_ID if parameter p_apm_id is NULL.
   IF p_apm_id IS NULL THEN
      -- get the apm_id based on si_id.
      OPEN cur_prsn_match_siid(p_si_id);
      FETCH cur_prsn_match_siid INTO l_apm_id;
      CLOSE cur_prsn_match_siid;
   ELSE
      l_apm_id := p_apm_id;
   END IF;

   -- There can only be one record with a given si_id but FOR LOOP is used for code clarity
   -- if person match rec exists. delete it after deleting corresp match details recs.
   FOR prsn_match_rec IN cur_prsn_match_apm(l_apm_id)
   LOOP

      -- fetch records from match details table for the apm id into temp table.
      OPEN cur_match_dtls(l_apm_id);
      FETCH cur_match_dtls BULK COLLECT INTO g_amd_id_tab;
      CLOSE cur_match_dtls ;

      l_cnt_match_dtls := g_amd_id_tab.COUNT;

      IF l_cnt_match_dtls > 0 THEN
         -- i.e. corresp apm id recs exist in match details.
         -- delete them using using bulk delete option
         FORALL k IN 1..l_cnt_match_dtls
            DELETE FROM igf_ap_match_details
            WHERE  amd_id = g_amd_id_tab(k);

         log_debug_message(' Deleted Match Details records for APM ID : ' || l_apm_id);
         RAM_D_MD := RAM_D_MD + 1;
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.delete_person_match_rec.debug','Deleted Match Details records for APM ID: ' || l_apm_id);
         END IF;
      END IF; -- l_cnt_match_dtls


      -- now call tbh of person match table to delete the record
      igf_ap_person_match_pkg.delete_row(prsn_match_rec.row_id);
      RAM_D_PM := RAM_D_PM + 1;

      log_debug_message(' Deleted Person Match record for APM ID : ' || l_apm_id);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.delete_person_match_rec.debug','Deleted Person Match record. APM ID: ' || prsn_match_rec.apm_id);
      END IF;

   END LOOP;

   log_debug_message(' Successfully deleted Person match and Match details data for APM ID:  ' || l_apm_id);

EXCEPTION
   WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.delete_person_match_rec.exception','The exception is : ' || SQLERRM );
      END IF;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.delete_person_match_rec' );
      igs_ge_msg_stack.add;
      fnd_file.put_line(fnd_file.log, ' - '|| SQLERRM);
      app_exception.raise_exception;
END delete_person_match_rec;


PROCEDURE create_admission_rec(
                               p_person_id   igf_ap_fa_base_rec_all.person_id%TYPE,
                               p_batch_year  igf_ap_batch_aw_map_all.batch_year%TYPE
                              )
IS
    /*
    ||        Created        By : rasingh
    ||        Created        On : 14-JUN-2001
    ||        Purpose        : Creates a enquiry record and instance        record,
    ||                  applicant and        student        else create its        inquiry        record and instance record.
    ||        Known limitations, enhancements        or remarks :
    ||        Change History :
    ||        Who                When                What
    ||        (reverse chronological order - newest change first)
    */

   CURSOR cur_adm_cal_conf IS
   SELECT inq_cal_type
     FROM igs_ad_cal_conf;

   CURSOR cur_person_type ( cp_sys_type   VARCHAR2) IS
   SELECT person_type_code
     FROM igs_pe_person_types
    WHERE system_type = cp_sys_type
      AND closed_ind =  'N' ;

   l_sys_type              VARCHAR2(30) ;
   l_person_type           igs_pe_person_types.person_type_code%TYPE;
   l_inq_cal_type          igs_ad_cal_conf.inq_cal_type%TYPE;
   l_rowid                 ROWID;
   l_adm_seq               igs_ca_inst.sequence_number%TYPE;
   l_acad_cal_type         igs_ca_type.cal_type%TYPE;
   l_acad_seq              igs_ca_inst.sequence_number%TYPE;
   ln_typ_id               igs_pe_typ_instances_all.type_instance_id%TYPE;
   l_adm_alternate_code    igs_ca_inst.alternate_code%TYPE;
   l_message               VARCHAR2(255);
   lv_return_status        VARCHAR2(255);
   lv_msg_data             VARCHAR2(2000);
   lv_msg_count            NUMBER;
   l_igr_sql_stmt          VARCHAR2(5000);

BEGIN

   log_debug_message(' Beginning Create Admission rec proc');
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.create_admission_rec.debug','Beginning of Create Admission Record. Person ID: ' || p_person_id || ',Batch Year:' || p_batch_year);
   END IF;

   -- Check if        the parameter to create        inquiry        record is set to Y.
   IF (g_create_inquiry = 'Y')        THEN
      OPEN cur_adm_cal_conf;
      FETCH cur_adm_cal_conf INTO l_inq_cal_type;

      IF cur_adm_cal_conf%NOTFOUND  THEN
        CLOSE cur_adm_cal_conf;

        fnd_message.set_name('IGF','IGF_AP_NO_DEF_ADM_CAL');
        fnd_file.put_line(fnd_file.log,fnd_message.get );
        app_exception.raise_exception;
      END IF;
      CLOSE cur_adm_cal_conf;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.create_admission_rec.debug','Before Calling igs_ad_gen_008.get_acad_cal');
      END IF;

      igs_ad_gen_008.get_acad_cal(
                                  p_adm_cal_type       => l_inq_cal_type,
                                  p_adm_seq            => l_adm_seq,
                                  p_acad_cal_type      => l_acad_cal_type,
                                  p_acad_seq           => l_acad_seq,
                                  p_adm_alternate_code => l_adm_alternate_code,
                                  p_message            => l_message
                                 );

      IF l_message IS NOT NULL THEN
         fnd_message.set_name('IGS', 'IGS_AD_INQ_ADMCAL_SEQ_NOTDFN');
         fnd_message.set_token('CAL_TYPE', l_inq_cal_type);
         fnd_file.put_line(fnd_file.log,fnd_message.get);
         RETURN;
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.create_admission_rec.debug','Before Inserting into igr_inquiry');
      END IF;

      IF fnd_profile.value('IGS_RECRUITING_ENABLED') = 'Y' THEN

         l_igr_sql_stmt := '
            DECLARE
               l_enquiry_status        VARCHAR2(30)        := ''OSS_REGISTERED'';
               x_rowid                 VARCHAR2(50);
               l_enquiry_appl_number   igr_i_appl_all.enquiry_appl_number%TYPE;
               l_sales_lead_id         igr_i_appl_all.sales_lead_id%TYPE;
            BEGIN
               x_rowid := NULL;
               igr_inquiry_pkg.insert_row(
                              X_MODE                         => ''R'',
                              X_ROWID                        => x_rowid,
                              X_PERSON_ID                    => :1,
                              X_ENQUIRY_APPL_NUMBER          => l_enquiry_appl_number,
                              X_SALES_LEAD_ID                => l_sales_lead_id,
                              X_ACAD_CAL_TYPE                => :2,
                              X_ACAD_CI_SEQUENCE_NUMBER      => :3,
                              X_ADM_CAL_TYPE                 => :4,
                              X_ADM_CI_SEQUENCE_NUMBER       => :5,
                              X_s_ENQUIRY_STATUS             => l_enquiry_status,
                              X_ENQUIRY_DT                   => TRUNC(SYSDATE),
                              X_INQUIRY_METHOD_CODE          => :6,
                              X_REGISTERING_PERSON_ID        => NULL,
                              X_OVERRIDE_PROCESS_IND         => ''N'',
                              X_INDICATED_MAILING_DT         => NULL,
                              X_LAST_PROCESS_DT              => NULL,
                              X_COMMENTS                     => NULL,
                              X_ORG_ID                       => igs_ge_gen_003.get_org_id,
                              X_INQ_ENTRY_LEVEL_ID           => NULL,
                              X_EDU_GOAL_ID                  => NULL,
                              X_PARTY_ID                     => NULL,
                              X_HOW_KNOWUS_ID                => NULL,
                              X_WHO_INFLUENCED_ID            => NULL,
                              X_SOURCE_PROMOTION_ID          => NULL,
                              X_PERSON_TYPE_CODE             => NULL,
                              X_FUNNEL_STATUS                => NULL,
                              X_ATTRIBUTE_CATEGORY           => NULL,
                              X_ATTRIBUTE1                   => NULL,
                              X_ATTRIBUTE2                   => NULL,
                              X_ATTRIBUTE3                   => NULL,
                              X_ATTRIBUTE4                   => NULL,
                              X_ATTRIBUTE5                   => NULL,
                              X_ATTRIBUTE6                   => NULL,
                              X_ATTRIBUTE7                   => NULL,
                              X_ATTRIBUTE8                   => NULL,
                              X_ATTRIBUTE9                   => NULL,
                              X_ATTRIBUTE10                  => NULL,
                              X_ATTRIBUTE11                  => NULL,
                              X_ATTRIBUTE12                  => NULL,
                              X_ATTRIBUTE13                  => NULL,
                              X_ATTRIBUTE14                  => NULL,
                              X_ATTRIBUTE15                  => NULL,
                              X_ATTRIBUTE16                  => NULL,
                              X_ATTRIBUTE17                  => NULL,
                              X_ATTRIBUTE18                  => NULL,
                              X_ATTRIBUTE19                  => NULL,
                              X_ATTRIBUTE20                  => NULL,
                              x_ret_status                   => :7,
                              x_msg_data                     => :8,
                              x_msg_count                    => :9,
                              x_action                       => ''Import'',
            x_enabled_flag                 => ''Y'',
            x_pkg_reduct_ind               => ''Y''
                           );
            END;';

         EXECUTE IMMEDIATE l_igr_sql_stmt
             USING p_person_id, l_acad_cal_type, l_acad_seq, l_inq_cal_type, l_adm_seq,
             g_adm_source_type, OUT lv_return_status, OUT lv_msg_data, OUT lv_msg_count;
      ELSE
        FND_MESSAGE.Set_Name('IGS', 'IGS_AD_INQ_NOT_CRT');
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      END IF; -- IGS Recruiting User

      log_debug_message('Created Admission Inquiry record. Status : ' || lv_return_status);
      RAM_I_HZ := RAM_I_HZ + 1;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.create_admission_rec.debug','Inquiry creation returned status: ' || lv_return_status);
      END IF;

      IF lv_return_status IN ('E','U') THEN

         FOR i IN 1..lv_msg_count LOOP
             fnd_file.put_line(fnd_file.log,fnd_msg_pub.get(p_encoded => fnd_api.g_false));
         END LOOP;

      ELSE
         fnd_message.set_name('IGF','IGF_AP_ISIR_ADM_REC');
         fnd_file.put_line(fnd_file.log,fnd_message.get);
      END IF;

   END IF; -- g_create_inquiry

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.create_admission_rec.debug','After Create Inquiry. Before inserting into igs_pe_typ_instances_pkg');
   END IF;


   l_sys_type := 'PROSPECT' ;
   OPEN cur_person_type ( l_sys_type ) ;
   FETCH cur_person_type INTO l_person_type;

   IF cur_person_type%FOUND  THEN
      CLOSE cur_person_type;
      l_rowid := NULL;
      igs_pe_typ_instances_pkg.insert_row(
                                       X_ROWID                   => l_rowid,
                                       x_PERSON_ID               => p_person_id,
                                       x_COURSE_CD               => NULL,
                                       x_TYPE_INSTANCE_ID        => ln_typ_id,
                                       x_PERSON_TYPE_CODE        => l_person_type,
                                       x_CC_VERSION_NUMBER       => NULL,
                                       x_FUNNEL_STATUS           => NULL,
                                       x_ADMISSION_APPL_NUMBER   => NULL,
                                       x_NOMINATED_COURSE_CD     => NULL,
                                       x_NCC_VERSION_NUMBER      => NULL,
                                       x_SEQUENCE_NUMBER         => NULL,
                                       x_START_DATE              => TRUNC(SYSDATE),
                                       x_END_DATE                => NULL,
                                       x_CREATE_METHOD           => 'CREATE_ENQ_APPL_INSTANCE',
                                       x_ENDED_BY                => NULL,
                                       x_END_METHOD              => NULL,
                                       X_MODE                    => 'R',
                                       X_ORG_ID                  => igs_ge_gen_003.get_org_id
                                      );

      RAM_I_HZ := RAM_I_HZ + 1;
      log_debug_message('Inserted record into igs_pe_typ_instances. ID : ' || ln_typ_id);

   ELSE
      CLOSE cur_person_type;
      fnd_message.set_name('IGF','IGF_AP_NO_PERSON_TYPE');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
   END IF;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.create_admission_rec.debug','Completed create_admission_rec procedure successfully');
   END IF;

EXCEPTION
    WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.create_admission_rec.exception','The exception is : ' || SQLERRM );
      END IF;

      IF cur_adm_cal_conf%ISOPEN THEN
        CLOSE cur_adm_cal_conf;
      END IF;

      IF cur_person_type%ISOPEN        THEN
        CLOSE cur_person_type;
      END IF;

      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_MATCHING_PROCESS_PKG.create_admission_rec');
      fnd_file.put_line(fnd_file.log,fnd_message.get );
      igs_ge_msg_stack.add;
END create_admission_rec;


PROCEDURE create_person_record(
                               p_called_from      VARCHAR2,
                               pn_person_id  OUT  NOCOPY NUMBER,
                               pv_mesg_data  OUT  NOCOPY VARCHAR2
                              )
IS

  /*
  ||  Created By : rgangara
  ||  Created On : 24-AUG-2004
  ||  Purpose :    Creates person record and returns Person ID as out parameter.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  skpandey         21-SEP-2005       Bug: 3663505
  ||                                     Description: Added ATTRIBUTES 21 TO 24 TO STORE ADDITIONAL INFORMATION
  ||  (reverse chronological order - newest change first)
  */

   CURSOR person_id_type_cur ( cp_pers_id_type   VARCHAR2 ) IS
   SELECT person_id_type
     FROM igs_pe_person_id_typ
    WHERE s_person_id_type = cp_pers_id_type ;

   CURSOR cur_lookups (p_lkup_type igf_lookups_view.Lookup_type%TYPE,
                       p_lkup_code igf_lookups_view.Lookup_code%TYPE) IS
   SELECT tag
   FROM   igf_lookups_view
   WHERE  lookup_type = p_lkup_type
     AND  lookup_code = p_lkup_code
     AND  enabled_flag = 'Y';


    l_pers_id_typ           VARCHAR2(30) ;
    ln_person_number        hz_parties.party_number%TYPE;
    lv_person_id_type       igs_pe_person_id_typ.person_id_type%TYPE;
    ln_msg_count            NUMBER;
    lv_msg_data             VARCHAR2(2000);
    lv_return_status        VARCHAR2(1);
    lv_row_id               VARCHAR2(30);
    retcode                 NUMBER;
    errbuf                  VARCHAR2(300);
    lv_sex                  igf_lookups_view.lookup_code%TYPE;
    l_object_version_number NUMBER;

    l_return_status VARCHAR2(25);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(4000);

BEGIN

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.create_person_record.debug','Beginning Person Creation.');
   END IF;
   log_debug_message(' Beginning Person Creation procedure');

   l_pers_id_typ  := 'SSN' ;
   OPEN  person_id_type_cur ( l_pers_id_typ) ;
   FETCH person_id_type_cur INTO lv_person_id_type;

   IF person_id_type_cur%NOTFOUND THEN
      fnd_message.set_name('IGF','IGF_AP_PER_ID_NOT_SET');
      pv_mesg_data := fnd_message.get;

      IF p_called_from = 'PLSQL' THEN
         fnd_file.put_line(fnd_file.log, pv_mesg_data); -- log the msg in log file.
      END IF;
      CLOSE person_id_type_cur;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.create_person_record.debug',pv_mesg_data);
      END IF;

      RETURN;
   END IF;
   CLOSE person_id_type_cur;


   -- Create a new person by getting the details from isir_intrface table.
   OPEN cur_lookups('IGF_AP_ISIR_GENDER', g_isir_intrface_rec.ss_r_u_male_flag);
   FETCH cur_lookups INTO lv_sex;

   IF cur_lookups%NOTFOUND THEN
      lv_sex := 'UNSPECIFIED' ;
   END IF;
   CLOSE cur_lookups;


   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.create_person_record.debug','Inserting Into Person table.');
   END IF;

   SAVEPOINT person_SP1;
   lv_row_id := NULL;
   l_object_version_number := NULL;

   igs_pe_person_pkg.insert_row(
             x_MSG_COUNT                => ln_msg_count,
             x_MSG_DATA                 => lv_msg_data,
             x_RETURN_STATUS            => lv_return_status,
             x_ROWID                    => lv_row_id,
             x_PERSON_ID                => pn_person_id,
             x_PERSON_NUMBER            => ln_person_number,
             x_SURNAME                  => INITCAP(g_isir_intrface_rec.last_name),
             x_MIDDLE_NAME              => g_isir_intrface_rec.middle_initial_txt,
             x_GIVEN_NAMES              => INITCAP(g_isir_intrface_rec.first_name),
             x_SEX                      => UPPER(lv_sex),
             x_TITLE                    => NULL,
             x_STAFF_MEMBER_IND         => NULL,
             x_DECEASED_IND             => NULL,
             x_SUFFIX                   => NULL,
             x_PRE_NAME_ADJUNCT         => NULL,
             x_ARCHIVE_EXCLUSION_IND    => NULL,
             x_ARCHIVE_DT               => NULL,
             x_PURGE_EXCLUSION_IND      => NULL,
             x_PURGE_DT                 => NULL,
             x_DECEASED_DATE            => NULL,
             x_PROOF_OF_INS             => NULL,
             x_PROOF_OF_IMMU            => NULL,
             x_BIRTH_DT                 => TRUNC(g_isir_intrface_rec.birth_date),
             x_SALUTATION               => NULL,
             x_ORACLE_USERNAME          => NULL,
             x_PREFERRED_GIVEN_NAME     => NULL,  -- modified to NULL for Reg Updates 0607 (bug 5086053)
             x_EMAIL_ADDR               => g_isir_intrface_rec.s_email_address_txt,
             x_LEVEL_OF_QUAL_ID         => NULL,
             x_MILITARY_SERVICE_REG     => NULL,
             x_VETERAN                  => NULL,
             x_hz_parties_ovn           => l_object_version_number,
             x_ATTRIBUTE_CATEGORY       => NULL,
             x_ATTRIBUTE1               => NULL,
             x_ATTRIBUTE2               => NULL,
             x_ATTRIBUTE3               => NULL,
             x_ATTRIBUTE4               => NULL,
             x_ATTRIBUTE5               => NULL,
             x_ATTRIBUTE6               => NULL,
             x_ATTRIBUTE7               => NULL,
             x_ATTRIBUTE8               => NULL,
             x_ATTRIBUTE9               => NULL,
             x_ATTRIBUTE10              => NULL,
             x_ATTRIBUTE11              => NULL,
             x_ATTRIBUTE12              => NULL,
             x_ATTRIBUTE13              => NULL,
             x_ATTRIBUTE14              => NULL,
             x_ATTRIBUTE15              => NULL,
             x_ATTRIBUTE16              => NULL,
             x_ATTRIBUTE17              => NULL,
             x_ATTRIBUTE18              => NULL,
             x_ATTRIBUTE19              => NULL,
             x_ATTRIBUTE20              => NULL,
             x_ATTRIBUTE21              => NULL,
             x_ATTRIBUTE22              => NULL,
             x_ATTRIBUTE23              => NULL,
             x_ATTRIBUTE24              => NULL,
             x_PERSON_ID_TYPE           => lv_person_id_type,
             x_API_PERSON_ID            => format_SSN(g_isir_intrface_rec.current_ssn_txt)
           );

   RAM_I_HZ := RAM_I_HZ + 1;
   IF lv_return_status = 'S'        THEN
     fnd_message.set_name('IGF','IGF_AP_ISIR_CREATE_PERSON');
     g_person_id := pn_person_id; -- populate into global variable.
     fnd_file.put_line(fnd_file.log, fnd_message.get || ' ' || igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','PERSON_NUMBER') || ':' || ln_person_number);

   ELSE -- error creating person

      log_debug_message(' Error Creating Person. Status ' || lv_return_status || ' Msg:' || lv_msg_data);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.create_person_record.debug','Error creating person. Return Status : ' || lv_return_status || '  ' || 'Message: ' || lv_msg_data);
      END IF;

      ROLLBACK TO person_SP1;
      pn_person_id := NULL;
      RETURN;
   END IF;

   g_person_id := pn_person_id; -- assign to global variable.

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.create_person_record.debug','Person Created Successfully... ' || g_person_id);
   END IF;

EXCEPTION
    WHEN OTHERS THEN
    log_debug_message(' EXCEPTON in create_person_record proc : ' || SQLERRM);
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.create_person_record.exception','The exception is : ' || SQLERRM );
    END IF;

    IF fnd_msg_pub.count_msg = 1 THEN
       pv_mesg_data := fnd_message.get;

    ELSIF fnd_msg_pub.count_msg > 1 THEN
       pv_mesg_data := SQLERRM;
    END IF ;

    ROLLBACK TO person_SP1;
    pn_person_id := NULL;
    RETURN;
END create_person_record;



PROCEDURE create_person_addr_record(pn_person_id  NUMBER)
IS
  /*
  ||  Created By : brajendr
  ||  Created On : 24-NOV-2000
  ||  Purpose :        Create person address record after creating the        person record for those        who satisfies the matching process.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  rajagupt       29-Jun-06           bug #5348743, Added check to handle lv_return_status of warning type
  || bkkumar         15-oct-2003         Bug 2906227
  ||                                     1) Added the code to default the Address usage to the value that is present in the
  ||                                        IGF_AP_DEF_ADDR_USAGE profile else default it to "HOME".
  ||  (reverse chronological order - newest change first)
  */
    lv_row_id              VARCHAR2(30);
    lv_msg_data            VARCHAR2(2000);
    lv_return_status       VARCHAR2(1);
    lv_location_id         hz_locations.location_id%TYPE;
    pd_last_update_date    DATE;
    ln_party_site_id       hz_party_sites.party_site_id%TYPE;

    l_rowid                VARCHAR2(200) := NULL;
    l_party_site_use_id    NUMBER := NULL;
    l_return_status        VARCHAR2(200);
    l_msg_data             VARCHAR2(200);
    l_last_update_date     DATE;
    l_site_use_last_update_date    DATE;
    l_profile_last_update_date     DATE;
    lv_object_version_number       NUMBER := NULL;
    l_party_site_use       hz_party_site_uses.site_use_type%TYPE;
    l_party_site_ovn       hz_party_sites.object_version_number%TYPE;
    l_location_ovn         hz_locations.object_version_number%TYPE;

BEGIN

   log_debug_message('Beginning creation of Person Address. Person ID : ' || pn_person_id);
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.create_person_addr_record.debug','Beginning Address creation for Person ID: ' || pn_person_id);
   END IF;


   lv_row_id := NULL;
   ln_party_site_id := NULL;

   igs_pe_person_addr_pkg.insert_row(
           P_ACTION                     => 'R',
           P_ROWID                      => lv_row_id,
           P_LOCATION_ID                => lv_location_id,
           P_START_DT                   => NULL,
           P_END_DT                     => NULL,
           P_COUNTRY                    => 'US',
           P_ADDRESS_STYLE              => NULL,
           P_ADDR_LINE_1                => INITCAP( g_isir_intrface_rec.perm_mail_address_txt),
           P_ADDR_LINE_2                => NULL,
           P_ADDR_LINE_3                => NULL,
           P_ADDR_LINE_4                => NULL,
           P_DATE_LAST_VERIFIED         => NULL,
           P_CORRESPONDENCE             => NULL,
           P_CITY                       => INITCAP(g_isir_intrface_rec.perm_city_txt),
           P_STATE                      => g_isir_intrface_rec.perm_state_txt,
           P_PROVINCE                   => NULL,
           P_COUNTY                     => NULL,
           P_POSTAL_CODE                => g_isir_intrface_rec.perm_zip_cd,
           P_ADDRESS_LINES_PHONETIC     => NULL,
           P_DELIVERY_POINT_CODE        => NULL,
           P_OTHER_DETAILS_1            => NULL,
           P_OTHER_DETAILS_2            => NULL,
           P_OTHER_DETAILS_3            => NULL,
           L_RETURN_STATUS              => lv_return_status,
           L_MSG_DATA                   => lv_msg_data,
           P_PARTY_ID                   => pn_person_id,
           P_PARTY_SITE_ID              => ln_party_site_id,
           P_PARTY_TYPE                 => NULL,
           P_LAST_UPDATE_DATE           => pd_last_update_date,
           P_PARTY_SITE_OVN             => l_party_site_ovn,
           P_LOCATION_OVN               => l_location_ovn,
           P_STATUS                     => 'A'
         );

RAM_I_HZ := RAM_I_HZ + 1;
   -- Bug 2906227 Here we need to default the address usage to 'HOME' and since this is the first time the person is
   -- getting created the address will be automatically defaulted to 'PRIMARY'
   -- CHECK THE PROFILE OPTION TO GET THE VALUE OF RESIDES AT COLUMN

   IF FND_PROFILE.VALUE('IGF_AP_DEF_ADDR_USAGE') IS NULL THEN
      l_party_site_use := 'HOME';
   ELSE
      l_party_site_use := FND_PROFILE.VALUE('IGF_AP_DEF_ADDR_USAGE');
   END IF;

   igs_pe_party_site_use_pkg.hz_party_site_uses_ak (
                             p_action                      => 'INSERT',
                             p_rowid                       => l_rowid,
                             p_party_site_use_id           => l_party_site_use_id,
                             p_party_site_id               => ln_party_site_id,
                             p_site_use_type               => l_party_site_use,
                             p_status                      => 'A',
                             p_return_status               => l_return_status  ,
                             p_msg_data                    => l_msg_data,
                             p_last_update_date            => l_last_update_date,
                             p_site_use_last_update_date   => l_site_use_last_update_date,
                             p_profile_last_update_date    => l_profile_last_update_date,
                             p_hz_party_site_use_ovn       => lv_object_version_number
                     );

RAM_I_HZ := RAM_I_HZ + 1;
   IF lv_return_status        = 'S' THEN
      fnd_message.set_name('IGF','IGF_AP_ISIR_PER_ADD');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
    ELSIF lv_return_status = 'W' THEN
    -- bug 5348743
      fnd_file.put_line(fnd_file.log, lv_msg_data);
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.create_person_addr_record.debug','Completed Address creation returned status warning : ' || lv_return_status);
   END IF;
   ELSE
      fnd_message.set_name('IGS','IGS_AD_CRT_ADDR_FAILED');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
   END IF;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.create_person_addr_record.debug','Completed Address creation returned status : ' || lv_return_status);
   END IF;

EXCEPTION
   WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.create_person_addr_record.exception','The exception is : ' || SQLERRM );
      END IF;

      fnd_file.put_line(FND_FILE.LOG ,lv_msg_data||fnd_global.newline ||'STATUS:'||lv_return_status);
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.create_person_addr_record');
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      igs_ge_msg_stack.add;
END create_person_addr_record;






PROCEDURE auto_fa_rec(p_person_id        igf_ap_match_details.person_id%TYPE,
                      p_apm_id           igf_ap_person_match_all.apm_id%TYPE,
                      p_cal_type         igf_ap_person_match_all.ci_cal_type%TYPE,
                      p_seq_num          igf_ap_person_match_all.ci_sequence_number%TYPE)
IS
        /*
  ||  Created By : rgangara
  ||  Created On : 16-AUG-2004
  ||  Purpose    : Is called only after record matching is performed and the total match score > auto fa rec
  ||               Since the record is matched, update the status to MATCHED and create records in other tables.
  ||               NOTE: This procedure gets executed only when the Pell match type is 'U'
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  ||  museshad         12-Apr-2006       Bug 5096864. Added code to update the FA Base record details
  ||                                     with the newly created ISIR info.
  */
    CURSOR chk_isir_exist (cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
    IS
        SELECT 'x'
        FROM igf_ap_isir_matched_all
        WHERE base_id = cp_base_id AND
              ROWNUM = 1;

    l_chk_isir_exist chk_isir_exist%ROWTYPE;

    CURSOR cur_fabase (cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE) IS
    SELECT fa.*
      FROM igf_ap_fa_base_rec fa
     WHERE fa.base_id = cp_base_id;

    lv_cur_fabase_rec cur_fabase%ROWTYPE;

    lv_base_id        igf_ap_fa_base_rec.base_id%TYPE;
    lv_isir_id        igf_ap_isir_matched_all.isir_id%TYPE;
    lv_nslds_id       igf_ap_nslds_data_all.nslds_id%TYPE;
    l_pymt_isir_flag  igf_ap_isir_matched_all.payment_isir%TYPE;
    l_chk_fo_ant_data BOOLEAN;
    l_anticip_status  VARCHAR2(30);
    l_awd_prc_status  VARCHAR2(30);

BEGIN

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.auto_fa_rec.debug','Auto FA Rec processing for APM ID: ' || p_apm_id || ' Person ID: ' || p_person_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.auto_fa_rec.debug','Interface Record Email Address : ' || g_isir_intrface_rec.s_email_address_txt );
   END IF;

   g_person_id := p_person_id; -- since matched, populate value into global

   IF g_create_inquiry = 'Y' THEN -- input parameter
      IF NOT check_ptyp_code(p_person_id) THEN
         -- No record found for prospect/applicant/student So create an Admission inquiry record
         create_admission_rec(p_person_id, g_isir_intrface_rec.batch_year_num);
      END IF;
   END IF;


   -- create/update email address
   IF g_isir_intrface_rec.s_email_address_txt IS NOT NULL THEN
      create_updt_email_address(p_person_id);
   END IF;


   -- Check whether the matched student has the detailed of current award year in the fa_base table
   IF NOT is_fa_base_record_present(p_person_id, g_isir_intrface_rec.batch_year_num, lv_base_id)  THEN
      -- create a base record for that award year.
      insert_fa_base_record( pn_person_id    => p_person_id, pn_base_id      => lv_base_id); -- OUT parameter
      l_chk_fo_ant_data := FALSE; -- bcoz, freshly created student will not have any anticipated data and existing awards
   ELSE
      -- FA Base record exists
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.auto_fa_rec.debug','FA Base Record found, base_id= ' ||lv_base_id);
      END IF;

      OPEN chk_isir_exist(cp_base_id => lv_base_id);
      FETCH chk_isir_exist INTO l_chk_isir_exist;

      IF (chk_isir_exist%NOTFOUND) THEN
        -- ISIR does not exist for the base_id. Create ISIR match record (gets created down the line) and
        -- update the FA Base record with the ISIR details.
        OPEN cur_fabase(cp_base_id => lv_base_id);
        FETCH cur_fabase INTO lv_cur_fabase_rec;
        CLOSE cur_fabase;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.auto_fa_rec.debug','ISIR does not exist for base_id= ' ||lv_base_id|| '. ISIR matched record will be inserted.');
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.auto_fa_rec.debug','Calling update_fa_base_rec() to update FA Base record with the ISIR details.');
        END IF;

        update_fa_base_rec( p_fabase_rec => lv_cur_fabase_rec,
                            p_isir_verification_flag => g_isir_intrface_rec.verification_flag);
      END IF;

      CLOSE chk_isir_exist;
      l_chk_fo_ant_data := TRUE; -- existing student might have anticipated data and awards
   END IF;

   g_base_id := lv_base_id; -- populate base_id into Global variable.

   -- get the payment ISIR flag value
   l_pymt_isir_flag := is_payment_isir(p_primary_efc_amt => g_isir_intrface_rec.primary_efc_amt);

   -- create ISIR Matched record
   insert_isir_matched_rec(cp_isir_int_rec  => g_isir_intrface_rec,
                           p_payment_isir   => l_pymt_isir_flag,
                           p_active_isir    => l_pymt_isir_flag, -- In this case, Active Flag same as Payment Flag
                           p_base_id        => lv_base_id,
                           p_out_isir_id    => lv_isir_id
                        );

   -- create NSLDS data record
   insert_nslds_data_rec(cp_isir_intrface_rec  => g_isir_intrface_rec,
                         p_isir_id             => lv_isir_id,
                         p_base_id             => lv_base_id,
                         p_out_nslds_id        => lv_nslds_id
                        );

   -- Process TODO items, if any
   process_todo_items(p_base_id       => lv_base_id,
                      p_payment_isir  => l_pymt_isir_flag);


   -- #4871790
   IGF_AP_BATCH_VER_PRC_PKG.update_process_status(
                         p_base_id          => lv_base_id,
                         p_fed_verif_status => NULL);


   -- call procedure to Delete the MATCHING records from MATCH tables as they no longer will be used.
   delete_person_match_rec(p_si_id  => NULL, p_apm_id  => p_apm_id);


   -- update ISIR int rec status
   update_isir_int_record(g_isir_intrface_rec.si_id, 'MATCHED', g_match_code); -- update ISIR int rec status

   g_matched_rec :=  g_matched_rec +  1; -- update count

    IF l_chk_fo_ant_data THEN
      -- bbb case 1
      -- check for ant data
      -- also check for award, no prev ISIR, so what will be the status of AWard prcoess status
      l_anticip_status  := NULL;
      l_awd_prc_status  := NULL;
      igf_ap_isir_gen_pkg.upd_ant_data_awd_prc_status( p_old_active_isir_id => NULL, -- Bcoz, this is the first ISIR the student is receiving
                                                       p_new_active_isir_id => lv_isir_id,
                                                       p_upd_ant_val        => g_upd_ant_val,
                                                       p_anticip_status     => l_anticip_status,
                                                       p_awd_prc_status     => l_awd_prc_status
                                                     );
    END IF;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.auto_fa_rec.debug','Successfully Completed processing Auto Fa Record procedure');
   END IF;

EXCEPTION
    WHEN others THEN
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.auto_fa_rec.exception','The exception is : ' || SQLERRM );
        END IF;

        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','igf_ap_matching_process_pkg.auto_fa_rec');
        fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
END auto_fa_rec;


PROCEDURE rvw_fa_rec(p_apm_id          igf_ap_person_match_all.apm_id%TYPE )        IS
  /*
  ||  Created By : rgangara
  ||  Created On : 16-AUG-2004
  ||  Purpose    : Is called only after record matching is performed and the total match score >= auto fa review rec
  ||               This procedure only updates record status to REVIEW and does not create any records in any other table.
  ||               NOTE: This procedure gets executed only when the Pell match type is 'U'
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */

BEGIN

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.rvw_fa_rec.debug','Review FA Rec processing for APM ID: ' || p_apm_id);
   END IF;

   -- call procedure to update the record_status of igf_ap_person_match and match details table
   update_prsn_match_rec_status(p_apm_id      => p_apm_id,
                                p_rec_status  => 'REVIEW');

   --  call procedure to update the record_status of igf_ap_isir_ints to 'REVIEW'
   update_isir_int_record (p_si_id           => g_isir_intrface_rec.si_id,
                           p_isir_rec_status => 'REVIEW',
                           p_match_code      => g_match_code);

   --Incrementing the count of review records
   g_review_count :=        g_review_count + 1 ; -- update count

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.rvw_fa_rec.debug','Successfully Completed processing Review FA Record procedure');
   END IF;

EXCEPTION
    WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.rvw_fa_rec.exception','The exception is : ' || SQLERRM );
       END IF;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.rvw_fa_rec');
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
END rvw_fa_rec ;


PROCEDURE unmatched_rec(p_apm_id      igf_ap_person_match_all.apm_id%TYPE,
                        p_called_from VARCHAR2,
                        p_msg_out     OUT NOCOPY VARCHAR2)
IS
  /*
  ||  Created By : rgangara
  ||  Created On : 16-AUG-2004
  ||  Purpose    : Is called only after record matching is performed and the total match score < auto fa review rec
  ||               This procedure only updates record status to UNMATCHED and hence does not create any records in any other table.
  ||               NOTE: This procedure gets executed only when the Pell match type is 'U'
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */

   lv_person_id         igf_ap_person_v.person_id%TYPE ;
   lv_base_id           igf_ap_fa_base_rec.base_id%TYPE;
   lv_isir_id           igf_ap_css_profile.cssp_id%TYPE;
   lv_nslds_id          igf_ap_nslds_data_all.nslds_id%TYPE;
   l_pymt_isir_flag     igf_ap_isir_matched_all.payment_isir%TYPE;

BEGIN


   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.unmatched_rec.debug','Unmatched rec processing for APM ID: ' || p_apm_id);
   END IF;
   log_debug_message('Before Create Person');

   -- Creation of Person record for the unmatched record
   create_person_record(p_called_from  => p_called_from,
                        pn_person_id   => lv_person_id, -- OUT parameter
                        pv_mesg_data   => p_msg_out     -- OUT parameter
                        );   -- igs_pe_person_pkg.insert_row();


   log_debug_message('Person Created.... ID= ' || lv_person_id);
   fnd_message.set_name('IGF','IGF_AP_SUCCESS_CREATE_PERSON');
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.unmatched_rec.debug','Person Created. Person ID :' || lv_person_id || ', p_msg_out :' || p_msg_out );
   END IF;


   IF lv_person_id IS NOT NULL THEN

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.unmatched_rec.debug','Creating Address');
      END IF;

      -- create person address
      create_person_addr_record(lv_person_id);     -- igs_pe_addr_pkg.insert_row();

      -- Admission inquiry record
      IF g_create_inquiry = 'Y' THEN
         IF NOT check_ptyp_code(lv_person_id) THEN

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.unmatched_rec.debug','Before calling Create Admission Record');
            END IF;

            create_admission_rec(lv_person_id,g_isir_intrface_rec.batch_year_num);
         END IF;
      END IF;

      -- create/update email address
      IF g_isir_intrface_rec.s_email_address_txt IS NOT NULL THEN
         create_updt_email_address(lv_person_id);
      END IF;

      -- Check whether FA Base record exists for the current Award year for the matched student
      IF NOT is_fa_base_record_present( lv_person_id, g_isir_intrface_rec.batch_year_num, lv_base_id)  THEN
         -- create a base record for that award year.
         insert_fa_base_record( pn_person_id    => lv_person_id, pn_base_id      => lv_base_id); -- OUT parameter
      END IF;
      g_base_id := lv_base_id; -- populate into global variable.

      -- get the payment ISIR flag value
      l_pymt_isir_flag := is_payment_isir(p_primary_efc_amt => g_isir_intrface_rec.primary_efc_amt);


      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.unmatched_rec.debug','Before Inserting ISIR Matched record ');
      END IF;

      -- create ISIR Matched record
      insert_isir_matched_rec(cp_isir_int_rec  => g_isir_intrface_rec,
                               p_payment_isir  => l_pymt_isir_flag,
                               p_active_isir   => l_pymt_isir_flag, -- In this case, Active Flag same as Payment Flag
                               p_base_id       => lv_base_id,
                               p_out_isir_id   => lv_isir_id -- OUT parameter
                              );

      -- create NSLDS data record
      insert_nslds_data_rec(cp_isir_intrface_rec  => g_isir_intrface_rec,
                             p_isir_id            => lv_isir_id,
                             p_base_id            => lv_base_id,
                             p_out_nslds_id       => lv_nslds_id -- OUT parameter
                            ) ;

      -- Process TODO items, if any
      process_todo_items(p_base_id       => lv_base_id,
                         p_payment_isir  => l_pymt_isir_flag);

      -- #4871790
      IGF_AP_BATCH_VER_PRC_PKG.update_process_status(
                         p_base_id          => lv_base_id,
                         p_fed_verif_status => NULL);

      -- call procedure to Delete the MATCHING records from MATCH tables as they no longer will be used.
      delete_person_match_rec(p_si_id  => NULL, p_apm_id  => p_apm_id);

      --  call procedure to update the ISIR Int record_status to 'UNMATCHED'
      update_isir_int_record (p_si_id           => g_isir_intrface_rec.si_id,
                              p_isir_rec_status => 'MATCHED',
                              p_match_code      => g_match_code);


      --Incrementing the   unmatched added        records        count
      g_unmatched_added := g_unmatched_added + 1;

   ELSE -- lv_person_id

      g_person_id := NULL;
      log_debug_message(' Error Creating Person ');
      -- call procedure to update the record_status of igf_ap_person_match and match details table
      update_prsn_match_rec_status(p_apm_id      => p_apm_id,
                                   p_rec_status  => 'UNMATCHED');

      --  call procedure to update the ISIR Int record_status to 'UNMATCHED'
      update_isir_int_record (p_si_id           => g_isir_intrface_rec.si_id,
                              p_isir_rec_status => 'UNMATCHED',
                              p_match_code      => g_match_code);

      --Incrementing the   unmatched added        records        count
      g_unmatched_rec   := g_unmatched_rec + 1 ;

   END IF; -- lv_person_id


   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.unmatched_rec.debug','Successfully Completed processing Unmatched record procedure. Person ID ' || lv_person_id);
   END IF;
   log_debug_message('Compeleted Unmatched rec processing with Force add');

EXCEPTION
   WHEN others THEN
       IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.unmatched_rec.exception','The exception is : ' || SQLERRM );
       END IF;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.unmatched_rec');
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
END   unmatched_rec ;



PROCEDURE calculate_match_score(p_isir_rec       igf_ap_isir_ints%ROWTYPE,
                                p_match_setup    igf_ap_record_match%ROWTYPE,
                                p_match_dtls_rec igf_ap_match_details%ROWTYPE,
                                p_apm_id         NUMBER,
                                p_person_id      NUMBER)
IS
 /*
  ||  Created By : rgangara
  ||  Created On : 09-Aug-2004
  ||  Purpose :        Matches attributes as per record match setup and inserts a record in match details table
                       after deriving the total score.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */


   CURSOR cur_lookups(cp_lkup_type VARCHAR2, cp_lkup_cd VARCHAR2) IS
   SELECT tag
   FROM   igf_lookups_view
   WHERE  lookup_type = cp_lkup_type
     AND  lookup_code = cp_lkup_cd
     AND  enabled_flag = 'Y';

   l_oss_gender hz_person_profiles.gender%TYPE;


   CURSOR chk_match_dtls_exists_cur(cp_apm_id NUMBER, cp_person_id NUMBER) IS
   SELECT ad.rowid row_id, ad.*
     FROM igf_ap_match_details ad
    WHERE apm_id = cp_apm_id
      AND person_id = cp_person_id;

   chk_match_dtls_exists_rec chk_match_dtls_exists_cur%ROWTYPE;

   l_ssn_match         igf_ap_match_details.ssn_match%TYPE;
   l_given_name_match  igf_ap_match_details.given_name_match%TYPE;
   l_surname_match     igf_ap_match_details.surname_match%TYPE;
   l_address_match     igf_ap_match_details.address_match%TYPE;
   l_city_match        igf_ap_match_details.city_match%TYPE;
   l_zip_match         igf_ap_match_details.zip_match%TYPE;
   l_email_id_match    igf_ap_match_details.email_id_match%TYPE;
   l_dob_match         igf_ap_match_details.dob_match%TYPE;
   l_gender_match      igf_ap_match_details.gender_match%TYPE;
   l_match_score       igf_ap_match_details.match_score%TYPE;

   l_primary_match_score NUMBER;

BEGIN

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.calculate_match_score.debug','Deriving Matching score values. APM_ID: ' || p_apm_id || ', Person_ID: ' || p_person_id);
   END IF;

   l_ssn_match := 0;
   l_given_name_match := 0;
   l_surname_match := 0;
   l_address_match := 0;
   l_city_match := 0;
   l_zip_match := 0;
   l_email_id_match := 0;
   l_dob_match := 0;
   l_gender_match := 0;
   l_match_score := 0;
-- ===============  FIRST MATCH ATTRIBUTES ===============

   -- SSN MATCH
   IF p_isir_rec.current_ssn_txt =  p_match_dtls_rec.ssn_txt THEN
      l_ssn_match := p_match_setup.ssn;
   END IF;

   -- FIRST NAME
   IF p_match_setup.given_name_mt_txt = 'EXACT' THEN
      -- First Name setup for exact match
      IF UPPER(p_isir_rec.first_name) =  UPPER(p_match_dtls_rec.given_name_txt) THEN
         l_given_name_match := p_match_setup.given_name;
      END IF;

   ELSE
      -- First Name setup for Partial match
     IF UPPER(p_match_dtls_rec.given_name_txt) LIKE '%'|| UPPER(p_isir_rec.first_name) || '%' THEN
         l_given_name_match := p_match_setup.given_name;
      END IF;
   END IF;


   -- LAST NAME

  log_debug_message('p_match_setup.surname_mt_txt'||p_match_setup.surname_mt_txt);
   IF p_match_setup.surname_mt_txt = 'EXACT' THEN
      -- Last Name setup for exact match
      IF UPPER(p_isir_rec.last_name) =  UPPER(p_match_dtls_rec.sur_name_txt) THEN
         l_surname_match := p_match_setup.surname;
      END IF;

   ELSE -- last name setup for Partial match

     IF UPPER(p_match_dtls_rec.sur_name_txt) LIKE UPPER('%' || p_isir_rec.last_name || '%') THEN
         l_surname_match := p_match_setup.surname;
      END IF;
   END IF;

   l_primary_match_score := NVL(l_ssn_match,0) + NVL(l_given_name_match,0) + NVL(l_surname_match,0);
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.calculate_match_score.debug','Total Primary Matching Attributes score : ' || l_primary_match_score);
   END IF;

   -- ===============  SECOND MATCH ATTRIBUTES ===============

   -- ADDRESS
   IF ((p_match_dtls_rec.address_txt IS NOT NULL) AND (p_isir_rec.perm_mail_address_txt IS NOT NULL)) THEN
      IF p_match_setup.address_mt_txt = 'EXACT' THEN
         -- Address setup for exact match
         IF UPPER(p_isir_rec.perm_mail_address_txt) =  UPPER(p_match_dtls_rec.address_txt) THEN
            l_address_match := p_match_setup.address;
         END IF;

      ELSIF p_match_setup.address_mt_txt = 'PARTIAL' THEN  -- Address setup for Partial match

           IF  UPPER(p_match_dtls_rec.address_txt) LIKE UPPER('%' || p_isir_rec.perm_mail_address_txt || '%') THEN
               l_address_match := p_match_setup.address;
           END IF;
      END IF;
  END IF;



   -- CITY
  IF ((p_match_dtls_rec.city_txt IS NOT NULL) AND (p_isir_rec.perm_city_txt IS NOT NULL)) THEN
   IF p_match_setup.city_mt_txt = 'EXACT' THEN
      -- City setup for exact match
      IF UPPER(p_isir_rec.perm_city_txt) =  UPPER(p_match_dtls_rec.city_txt) THEN
         l_city_match := p_match_setup.city;
      END IF;

   ELSIF p_match_setup.city_mt_txt = 'PARTIAL' THEN  -- Address setup for Partial match

      IF UPPER(p_match_dtls_rec.city_txt) LIKE '%' || UPPER(p_isir_rec.perm_city_txt) || '%' THEN
         l_city_match := p_match_setup.city;
      END IF;
   END IF;
 END IF;

   -- POSTAL CODE
 IF ((p_match_dtls_rec.zip_txt IS NOT NULL) AND (p_isir_rec.perm_zip_cd IS NOT NULL)) THEN
   IF p_match_setup.zip_mt_txt = 'EXACT' THEN
      -- Zip Code setup for exact match
      IF p_isir_rec.perm_zip_cd =  p_match_dtls_rec.zip_txt THEN
         l_zip_match := p_match_setup.zip;
      END IF;

   ELSIF p_match_setup.zip_mt_txt = 'PARTIAL' THEN  -- Address setup for Partial match

         IF p_match_dtls_rec.city_txt LIKE '%' || p_isir_rec.perm_zip_cd || '%' THEN
            l_zip_match := p_match_setup.zip;
         END IF;
   END IF;
 END IF;

   -- EMAIL ADDRESS
 IF ((p_match_dtls_rec.email_id_txt IS NOT NULL) AND (p_isir_rec.s_email_address_txt IS NOT NULL)) THEN
   IF p_match_setup.email_mt_txt = 'EXACT' THEN
      -- Email setup for exact match
      IF p_isir_rec.s_email_address_txt =  p_match_dtls_rec.email_id_txt THEN
         l_email_id_match := p_match_setup.email_num;
      END IF;

   ELSIF p_match_setup.email_mt_txt = 'PARTIAL' THEN  -- Address setup for Partial match

         IF p_match_dtls_rec.city_txt LIKE '%' || p_isir_rec.s_email_address_txt || '%' THEN
            l_email_id_match := p_match_setup.email_num;
         END IF;
   END IF;
 END IF;

   -- BIRTH DATE
   -- can only be setup for Exact or exclude
 IF ((p_match_dtls_rec.birth_date IS NOT NULL) AND (p_isir_rec.birth_date IS NOT NULL)) THEN
   IF p_match_setup.birth_dt_mt_txt = 'EXACT' THEN
      -- Birth date setup for exact match
      IF p_isir_rec.birth_date =  p_match_dtls_rec.birth_date THEN
         l_dob_match := p_match_setup.birth_dt;
      END IF;
   END IF;
 END IF;

   -- GENDER
   -- can only be setup for Exact or exclude
 IF ((p_match_dtls_rec.gender_txt IS NOT NULL) AND (p_isir_rec.ss_r_u_male_flag IS NOT NULL)) THEN
   IF p_match_setup.gender_mt_txt = 'EXACT' THEN
      -- Gender setup for exact match

      -- get the corresponding OSS value
      OPEN cur_lookups('IGF_AP_ISIR_GENDER', p_isir_rec.ss_r_u_male_flag);
      FETCH cur_lookups INTO l_oss_gender;
      CLOSE cur_lookups ;

      IF l_oss_gender IS NULL THEN
         l_oss_gender := 'UNSPECIFIED';
      END IF;

      IF UPPER(l_oss_gender) =  UPPER(p_match_dtls_rec.gender_txt) THEN
         l_gender_match := p_match_setup.gender_num;
      END IF;
   END IF;
 END IF;

   -- ===============  COMPUTE TOTAL SCORE  ===============

   l_match_score:=
         NVL(l_ssn_match,0)         +
         NVL(l_given_name_match,0)  +
         NVL(l_surname_match,0)     +
         NVL(l_address_match,0)     +
         NVL(l_city_match,0)        +
         NVL(l_zip_match ,0)        +
         NVL(l_email_id_match,0)    +
         NVL(l_dob_match,0)         +
         NVL(l_gender_match,0)   ;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.calculate_match_score.debug','Total Match Score calculated is ' || p_match_dtls_rec.match_score);
   END IF;
   log_debug_message(' SSN MATCH SCORE : ' || l_ssn_match);
   log_debug_message(' FNAME MATCH SCORE : ' || l_given_name_match);
   log_debug_message(' LNAME MATCH SCORE : ' || l_surname_match);
   log_debug_message(' ADDR  MATCH SCORE : ' || l_address_match);
   log_debug_message(' CITY  MATCH SCORE : ' || l_city_match);
   log_debug_message(' ZIP   MATCH SCORE : ' || l_zip_match);
   log_debug_message(' EMIAL MATCH SCORE : ' || l_email_id_match);
   log_debug_message(' DOB   MATCH SCORE : ' || l_dob_match);
   log_debug_message(' GENDR MATCH SCORE : ' || l_gender_match);
   log_debug_message(' TOTAL MATCH SCORE : ' || l_match_score);

   log_debug_message(' p_match_dtls_rec.ssn_txt ' || p_match_dtls_rec.ssn_txt);
   log_debug_message(' p_match_dtls_rec.given_name_txt ' || p_match_dtls_rec.given_name_txt);
   log_debug_message(' p_match_dtls_rec.sur_name_txt ' || p_match_dtls_rec.sur_name_txt);
   log_debug_message(' p_match_dtls_rec.birth_date ' || p_match_dtls_rec.birth_date);
   log_debug_message(' p_match_dtls_rec.address_txt ' || p_match_dtls_rec.address_txt);
   log_debug_message(' p_match_dtls_rec.city_txt ' || p_match_dtls_rec.city_txt);
   log_debug_message(' p_match_dtls_rec.zip_txt ' || p_match_dtls_rec.zip_txt);
   log_debug_message(' p_match_dtls_rec.gender_txt ' || p_match_dtls_rec.gender_txt);
   log_debug_message(' p_match_dtls_rec.email_id_txt ' || p_match_dtls_rec.email_id_txt);


   -- check whether a match details rec already exists for this person and isir rec.
   OPEN chk_match_dtls_exists_cur(p_apm_id, p_person_id);
   FETCH chk_match_dtls_exists_cur INTO chk_match_dtls_exists_rec;
   CLOSE chk_match_dtls_exists_cur;

   IF chk_match_dtls_exists_rec.row_id IS NULL THEN

      log_debug_message(' INSERTING Match Details record .... : ');
      -- insert a new match details rec
      igf_ap_match_details_pkg.insert_row(
              x_mode                => 'R',
              x_rowid               => chk_match_dtls_exists_rec.row_id,
              x_amd_id              => chk_match_dtls_exists_rec.amd_id,
              x_apm_id              => p_apm_id,
              x_person_id           => p_person_id ,
              x_ssn_match           => l_ssn_match ,
              x_given_name_match    => l_given_name_match,
              x_surname_match       => l_surname_match   ,
              x_dob_match           => l_dob_match       ,
              x_address_match       => l_address_match   ,
              x_city_match          => l_city_match      ,
              x_zip_match           => l_zip_match       ,
              x_match_score         => l_match_score     ,
              x_record_status       => g_isir_intrface_rec.record_status,
              x_ssn_txt             => p_match_dtls_rec.ssn_txt         ,
              x_given_name_txt      => p_match_dtls_rec.given_name_txt  ,
              x_sur_name_txt        => p_match_dtls_rec.sur_name_txt    ,
              x_birth_date          => p_match_dtls_rec.birth_date      ,
              x_address_txt         => p_match_dtls_rec.address_txt     ,
              x_city_txt            => p_match_dtls_rec.city_txt        ,
              x_zip_txt             => p_match_dtls_rec.zip_txt         ,
              x_gender_txt          => p_match_dtls_rec.gender_txt      ,
              x_email_id_txt        => p_match_dtls_rec.email_id_txt    ,
              x_gender_match        => l_gender_match                   ,
              x_email_id_match      => l_email_id_match
              );

RAM_I_MD := RAM_I_MD + 1;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.calculate_match_score.debug','Inserted match details record. AMD_ID: ' || chk_match_dtls_exists_rec.amd_id);
      END IF;
      log_debug_message(' Inserted Match Details record. AMD ID: ' || chk_match_dtls_exists_rec.amd_id || ' Person ID: ' || p_person_id);


   ELSE

      log_debug_message(' Match Details rec UPDATING ?????????.... : ' || p_person_id);
      -- Update can happen only for SSN since the first part of the main matching query returns distinct person id
      -- for SSN, first name and last name from OSS.
      -- 2nd part of the query returns matches based on SSN from HRMS (This is the only possibility of being in update mode)

      -- update existing rec
      igf_ap_match_details_pkg.update_row(
              x_mode                => 'R',
              x_rowid               => chk_match_dtls_exists_rec.row_id          ,
              x_amd_id              => chk_match_dtls_exists_rec.amd_id          ,
              x_apm_id              => chk_match_dtls_exists_rec.apm_id          ,
              x_person_id           => chk_match_dtls_exists_rec.person_id       ,
              x_ssn_match           => l_ssn_match                               , -- update
              x_given_name_match    => chk_match_dtls_exists_rec.given_name_match,
              x_surname_match       => chk_match_dtls_exists_rec.surname_match   ,
              x_dob_match           => chk_match_dtls_exists_rec.dob_match       ,
              x_address_match       => chk_match_dtls_exists_rec.address_match   ,
              x_city_match          => chk_match_dtls_exists_rec.city_match      ,
              x_zip_match           => chk_match_dtls_exists_rec.zip_match       ,
              x_match_score         => (chk_match_dtls_exists_rec.match_score - chk_match_dtls_exists_rec.ssn_match + l_ssn_match),
              x_record_status       => chk_match_dtls_exists_rec.record_status   ,
              x_ssn_txt             => p_match_dtls_rec.ssn_txt                  , -- update
              x_given_name_txt      => chk_match_dtls_exists_rec.given_name_txt  ,
              x_sur_name_txt        => chk_match_dtls_exists_rec.sur_name_txt    ,
              x_birth_date          => chk_match_dtls_exists_rec.birth_date      ,
              x_address_txt         => chk_match_dtls_exists_rec.address_txt     ,
              x_city_txt            => chk_match_dtls_exists_rec.city_txt        ,
              x_zip_txt             => chk_match_dtls_exists_rec.zip_txt         ,
              x_gender_txt          => chk_match_dtls_exists_rec.gender_txt      ,
              x_email_id_txt        => chk_match_dtls_exists_rec.email_id_txt    ,
              x_gender_match        => chk_match_dtls_exists_rec.gender_match    ,
              x_email_id_match      => chk_match_dtls_exists_rec.email_id_match
            );

RAM_U_MD := RAM_U_MD + 1;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.calculate_match_score.debug','Updated match details record. APM ID: ' || p_apm_id || ' AMD ID: ' || chk_match_dtls_exists_rec.amd_id);
      END IF;

   END IF;

EXCEPTION
   WHEN others THEN
       IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.calculate_match_score.exception','The exception is : ' || SQLERRM );
       END IF;

       fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
       fnd_message.set_token('NAME','igf_ap_matching_process_pkg.calculate_match_score' );
       igs_ge_msg_stack.add;
       fnd_file.put_line(fnd_file.log, ' - '|| SQLERRM);
       app_exception.raise_exception;
END calculate_match_score;



PROCEDURE perform_record_matching (p_apm_id igf_ap_person_match_all.apm_id%TYPE)
IS
  /*
  ||  Created By : rgangara
  ||  Created On : 09-Aug-2004
  ||  Purpose :    Performs person matching for the new ISIR record based on the matching Attributes
  ||               and inserts the matched person records and attribute values into match details table.
  ||               This procedure gets executed only when the pell match type is 'U' (unidentified isir)
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */

   -- table definition
   TYPE RecTab             IS TABLE OF    VARCHAR2(30);
   TYPE PersonIdTab        IS TABLE OF    hz_parties.party_id%TYPE;
   TYPE ssntab             IS TABLE OF    igs_pe_alt_pers_id.api_person_id_uf%TYPE;
   TYPE firstnametab       IS TABLE OF    hz_parties.person_first_name%TYPE;
   TYPE lastnametab        IS TABLE OF    hz_parties.person_last_name%TYPE;
   TYPE addresstab         IS TABLE OF    hz_parties.address1%TYPE;
   TYPE citytab            IS TABLE OF    hz_parties.city%TYPE;
   TYPE postalcodetab      IS TABLE OF    hz_parties.postal_code%TYPE;
   TYPE emailaddresstab    IS TABLE OF    hz_parties.email_address%TYPE;
   TYPE dobtab             IS TABLE OF    hz_person_profiles.date_of_birth%TYPE;
   TYPE gendertab          IS TABLE OF    hz_person_profiles.gender%TYPE;
   TYPE totmatchscoretab   IS TABLE OF    NUMBER;

   t_rec_tab            RecTab;
   t_pid_tab            PersonIdTab;
   t_prsn_SSN           ssntab;
   t_first_name         firstnametab;
   t_last_name          lastnametab;
   t_address            addresstab;
   t_city               citytab;
   t_postal_code        postalcodetab;
   t_email_address      emailaddresstab;
   t_dob_tab            dobtab;
   t_gender             gendertab;
   t_tot_match_score    totmatchscoretab;

   match_details_rec    igf_ap_match_details%ROWTYPE;

   CURSOR check_oss_person_match(p_apm_id NUMBER, p_person_id NUMBER) IS
   SELECT ssn_txt
     FROM igf_ap_match_details ad
    WHERE apm_id = p_apm_id
      AND person_id = p_person_id;

   oss_person_match_rec check_oss_person_match%ROWTYPE;

   lv_ssn      igf_ap_match_details.ssn_txt%TYPE;
   lv_fname    igf_ap_match_details.given_name_txt%TYPE;
   lv_lname    igf_ap_match_details.sur_name_txt%TYPE;
   l_fname_exact_match VARCHAR2(1);
   l_lname_exact_match VARCHAR2(1);
   l_process_rec       VARCHAR2(1);
   lv_tot              NUMBER;

BEGIN

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.perform_record_matching.debug','Beginning Person Matching ');
   END IF;

   -- get SSN by removing any special characters
   lv_ssn   :=  remove_spl_chr(g_isir_intrface_rec.current_ssn_txt) ;

   -- FNAME / GIVENNAME
   IF g_setup_score.given_name_mt_txt = 'EXACT' THEN
      l_fname_exact_match := 'Y';
      lv_fname := UPPER(TRIM(g_isir_intrface_rec.first_name));

   ELSE
      l_fname_exact_match := 'N';
      lv_fname := '%' || UPPER(TRIM(g_isir_intrface_rec.first_name)) || '%' ;
   END IF;

   -- LAST NAME / SURNAME
   IF g_setup_score.surname_mt_txt = 'EXACT' THEN
      l_lname_exact_match := 'Y';
      lv_lname := UPPER(TRIM(g_isir_intrface_rec.last_name));

   ELSE
      l_lname_exact_match := 'N';
      lv_lname := '%' || UPPER(TRIM(g_isir_intrface_rec.last_name)) || '%' ;
   END IF;

   log_debug_message(' About to execute the main matching query. '  || TO_CHAR(SYSDATE, 'HH24:MI:SS'));

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.perform_record_matching.debug','Matching Attribute Values: ');
   END IF;

   -- main query to fetch all the records from OSS which match
   SELECT rec_type,
          person_id,
          prsn_ssn,
          firstname,
          lastname,
          address,
          city,
          postal_code,
          email_address,
          date_of_birth,
          gender
   BULK COLLECT INTO
          t_rec_tab,
          t_pid_tab,
          t_prsn_ssn,
          t_first_name,
          t_last_name,
          t_address,
          t_city,
          t_postal_code,
          t_email_address,
          t_dob_tab,
          t_gender
   FROM
   (
          -- SSN matching records
          SELECT 'OSS' rec_type,
                hz.party_id person_id,
                api.api_person_id_uf prsn_ssn,  --Unformatted SSN value
                hz.person_first_name firstname,
                hz.person_last_name lastname,
                hz.address1 address,
                hz.city  city,
                hz.postal_code postal_code,
                hz.email_address email_address,
                hp.date_of_birth date_of_birth,
                hp.gender gender
           FROM ( SELECT apii.pe_person_id, apii.api_person_id_uf
                    FROM igs_pe_alt_pers_id apii, igs_pe_person_id_typ pit
                   WHERE apii.person_id_type = pit.person_id_type
                     AND pit.s_person_id_type = 'SSN'
                     AND SYSDATE BETWEEN apii.start_dt AND NVL (apii.end_dt, SYSDATE)) api,
                hz_parties hz,
                hz_person_profiles hp
          WHERE hz.party_id  = api.pe_person_id(+)
            AND hz.party_id  = hp.party_id
            AND hp.effective_end_date IS NULL
            AND (api.api_person_id_uf     = lv_ssn
                 -- First Name
                 OR (UPPER(hz.person_first_name)  =    UPPER(lv_fname) AND l_fname_exact_match = 'Y')
                 OR (UPPER(hz.person_first_name)  LIKE UPPER(lv_fname) AND l_fname_exact_match = 'N')
                 -- Last Name
                 OR (UPPER(hz.person_last_name)   =    UPPER(lv_lname) AND l_lname_exact_match = 'Y')
                 OR (UPPER(hz.person_last_name)   LIKE UPPER(lv_lname) AND l_lname_exact_match = 'N')
                )

   UNION
          --Source of SSN from HRMS
          SELECT 'HRM' rec_type,
                ppf.party_id person_id,  -- party id maps to HZ_parties.party_id
                remove_spl_chr(ppf.national_identifier) prsn_ssn,
                hz.person_first_name firstname,
                hz.person_last_name lastname,
                hz.address1 address,
                hz.city  city,
                hz.postal_code postal_code,
                hz.email_address email_address,
                hp.date_of_birth date_of_birth,
                hp.gender gender
           FROM per_all_people_f ppf,
                per_business_groups_perf pbg,
                per_person_types         ppt,
                hz_parties               hz,
                hz_person_profiles       hp
          WHERE IGS_EN_GEN_001.Check_HRMS_Installed = 'Y'
            AND pbg.legislation_code   = 'US'
            AND ppt.system_person_type = 'EMP'
            AND ppt.person_type_id     = ppf.person_type_id
            AND pbg.business_group_id  = ppf.business_group_id
            AND TRUNC(SYSDATE) BETWEEN ppf.effective_start_date AND ppf.effective_end_date
            AND ppf.party_id           = hz.party_id
            AND hz.party_id            = hp.party_id
            AND hp.effective_end_date IS NULL
            AND remove_spl_chr(ppf.national_identifier) = lv_ssn
   ) v_dataset ORDER BY 2        ;

RAM_MQ := RAM_MQ +1;
   lv_tot := t_rec_tab.COUNT;


   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.perform_record_matching.debug','Total No. of matched records found : ' || lv_tot);
   END IF;
   log_debug_message(' Matching query execution completed. Fetched recs ' || lv_tot || ' .Time : ' || TO_CHAR(SYSDATE, 'HH24:MI:SS'));

   -- Loop thru and process a person at a time
   FOR l_row IN        1..lv_tot
   LOOP

      l_process_rec := 'N'; -- initialize flag variable

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.perform_record_matching.debug','Processing for Person_id: ' || t_pid_tab(l_row) || ', Match in: ' || t_rec_tab(l_row));
      END IF;

      log_debug_message(' Processing match rec for Person ID: ' || t_pid_tab(l_row) || '. Rec No. ' || l_row);
      IF t_rec_tab(l_row) = 'OSS' THEN
         l_process_rec := 'Y'; -- process OSS matching records as usual.

      ELSE -- i.e. hrms match record for ssn
         -- this matching record is from HRMS. hence process only when SSN does not exist in OSS.
         oss_person_match_rec := NULL;
         OPEN check_oss_person_match(p_apm_id, t_pid_tab(l_row));
         FETCH check_oss_person_match INTO oss_person_match_rec;

         -- This is HRMS matching rec i.e. on SSN attribute.
         -- Hence process this record only if the SSN is not found in OSS.
         IF check_oss_person_match%NOTFOUND THEN
            l_process_rec := 'Y';
         ELSE
            -- OSS match exists but ssn_txt is null i.e. not ssn match. could be first name or last name matched rec
            IF oss_person_match_rec.ssn_txt IS NULL THEN
               l_process_rec := 'Y';
            END IF;
         END IF;
         CLOSE check_oss_person_match;

         log_debug_message(' HRMS MATCH REC ?????. SSN : ' || oss_person_match_rec.ssn_txt  || '. Process Record : ' || l_process_rec);
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.perform_record_matching.debug','HRMS Matching Record. SSN: ' || t_prsn_ssn(l_row) || '. Process flag : ' || l_process_rec);
         END IF;
      END IF; -- t_rec_tab


      IF l_process_rec = 'Y' THEN   -- process the record
         -- populate values into rec variable call for passing to process_match_person_rec proc
         match_details_rec.ssn_txt           := t_prsn_ssn(l_row);
         match_details_rec.given_name_txt    := t_first_name(l_row);
         match_details_rec.sur_name_txt      := t_last_name(l_row);
         match_details_rec.address_txt       := t_address(l_row);
         match_details_rec.city_txt          := t_city(l_row);
         match_details_rec.zip_txt           := t_postal_code(l_row);
         match_details_rec.email_id_txt      := t_email_address(l_row);
         match_details_rec.birth_date        := t_dob_tab(l_row);
         match_details_rec.gender_txt        := t_gender(l_row);

         log_debug_message(' calling calculate match score proc.... ');
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.perform_record_matching.debug','Before calling calculate_match_score procedure... ');
         END IF;

         -- call the procedure to match the attributes, compute score and insert rec into match details table
         calculate_match_score(p_isir_rec       =>  g_isir_intrface_rec,
                               p_match_setup    =>  g_setup_score,
                               p_match_dtls_rec =>  match_details_rec,
                               p_apm_id         =>  p_apm_id,
                               p_person_id      =>  t_pid_tab(l_row)
                             );
         log_debug_message(' Returned from calculate match score Proc. ');

      END IF;
   END LOOP;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.perform_record_matching.debug','Successfully Completed processing perform_record_matching');
   END IF;
   log_debug_message(' END of Perform record matching....... ');

EXCEPTION
   WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.perform_record_matching.exception','The exception is : ' || SQLERRM );
      END IF;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.perform_record_matching' );
      igs_ge_msg_stack.add;
      fnd_file.put_line(fnd_file.log, ' - '|| SQLERRM);
      app_exception.raise_exception;
END perform_record_matching ;


PROCEDURE process_unidentified_isir_rec IS
  /*
  ||  Created By : rgangara
  ||  Created On : 06-AUG-2004
  ||  Purpose :        For processing ISIR recs with pell match type as 'U' i.e.
  ||                   first isir for the student. Separate procedure is created for this
  ||                   for clarity as it has quite a lot of steps
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  ||  museshad         11-Apr-2006       Bug 5096864. Issue in updating the record_status of ISIRs that have either -
  ||                                     no ISIR record for the matched Student or the ISIR record exists for the matched
  ||                                     Student but its transaction number does not match with the transaction number of
  ||                                     the new ISIR in the interface table. Fixed this issue.
  ||
  */

   -- check for person match rec before inserting
   CURSOR cur_prsn_match (cp_si_id NUMBER) IS
   SELECT *
     FROM igf_ap_person_match
    WHERE si_id = cp_si_id;

   person_match_rec cur_prsn_match%ROWTYPE;

   -- Cursor to get the person_id with highest match_score for a particulare apm_id
   CURSOR cur_get_max_data(cp_apm_id  igf_ap_person_match.apm_id%TYPE) IS
   SELECT person_id,
          match_score
     FROM igf_ap_match_details
    WHERE apm_id = cp_apm_id
    ORDER BY match_score DESC;

   CURSOR c_base_id(p_person_id NUMBER,
                   p_cal_type VARCHAR2,
                   p_seq_num VARCHAR2) IS
   SELECT base_id
    FROM igf_ap_fa_con_v
   WHERE person_id = p_person_id
     AND ci_cal_type = p_cal_type
     AND ci_sequence_number = p_seq_num ;

   l_base_id        NUMBER;

    CURSOR chk_isir_exist (cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
    IS
        SELECT 'x'
        FROM igf_ap_isir_matched_all
        WHERE base_id = cp_base_id AND
              ROWNUM = 1;

    l_chk_isir_exist chk_isir_exist%ROWTYPE;

   lv_rowid          VARCHAR2(30);
   lv_person_id      igf_ap_match_details.person_id%TYPE;
   ln_match_score    igf_ap_match_details.match_score%TYPE;
   ln_apm_id         igf_ap_match_details.apm_id%TYPE;
   lv_msg_out        VARCHAR2(2000);

BEGIN

   log_debug_message(' Beginning Process Unidentified rec proc ');
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_unidentified_isir_rec.debug','Beginning processing Unidentified record.');
   END IF;

   -- Unidentified ISIR. Hence first insert a record in person match table.
   -- first check whether a record already exists for this Int rec si_id
   OPEN  cur_prsn_match (g_isir_intrface_rec.si_id);
   FETCH cur_prsn_match INTO person_match_rec;

   IF cur_prsn_match%NOTFOUND THEN
      CLOSE cur_prsn_match ;
      -- Inserting new student record into igf_ap_person_match table.
      lv_rowid := NULL;
      igf_ap_person_match_pkg.insert_row(
                       x_rowid                 => lv_rowid ,
                       x_apm_id                => ln_apm_id,
                       x_css_id                => NULL,
                       x_si_id                 => g_isir_intrface_rec.si_id ,
                       x_record_type           => 'ISIR' ,
                       x_date_run              => TRUNC(SYSDATE),
                       x_ci_sequence_number    => g_ci_sequence_number ,
                       x_ci_cal_type           => g_ci_cal_type ,
                       x_record_status         => 'NEW' ,
                       x_mode                  => 'R');

      log_debug_message(' Inserted New Person Match record. APM ID: ' || ln_apm_id);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.perform_record_matching.debug','Inserted record into Person Match table with APM_ID: ' || ln_apm_id);
      END IF;

   ELSE
      CLOSE cur_prsn_match;
      -- record already exists??. Update the record.
      igf_ap_person_match_pkg.update_row(
                       x_rowid                 => person_match_rec.row_id ,
                       x_apm_id                => person_match_rec.apm_id,
                       x_css_id                => person_match_rec.css_id,
                       x_si_id                 => person_match_rec.si_id ,
                       x_record_type           => person_match_rec.record_type,
                       x_date_run              => TRUNC(SYSDATE),
                       x_ci_sequence_number    => person_match_rec.ci_sequence_number,
                       x_ci_cal_type           => person_match_rec.ci_cal_type ,
                       x_record_status         => 'NEW' ,
                       x_mode                  => 'R');

      ln_apm_id := person_match_rec.apm_id; -- assign it to local variable which can be used for passing to person match proc

      log_debug_message(' Updated Person Match record. APM ID: ' || ln_apm_id);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.perform_record_matching.debug','Updated record in Person Match table with APM_ID: ' || ln_apm_id);
      END IF;
   END IF; -- cur_prsn_match%NOTFOUND


   -- Call procedure to perform person matching based on match set attributes.
   -- This procedure would match attributes and populates matching records into match details table.
   perform_record_matching(p_apm_id  => ln_apm_id);

   log_debug_message(' Returned from perform record matching proc ');

   ln_match_score := 0;
   -- get the person record with the highest match_score from among the matched records for this apm_id
   OPEN  cur_get_max_data(ln_apm_id);
   FETCH cur_get_max_data INTO lv_person_id, ln_match_score;
   CLOSE cur_get_max_data;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_unidentified_isir_rec.debug','Matching record with Max Total Score. APM ID: ' || ln_apm_id || ' Person ID: ' || lv_person_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_unidentified_isir_rec.debug','Matching record with Max Total Score. Total Score: ' || ln_match_score);
   END IF;
   log_debug_message(' Max score matched record found. Person ID: ' || lv_person_id || ' Score: ' || ln_match_score);

   -- compare total score against the setup scores
   IF ln_match_score >= g_setup_score.min_score_auto_fa  THEN
      -- check if base_id already exists for this person
      OPEN c_base_id (p_person_id  =>        lv_person_id ,
                     p_cal_type   =>        g_ci_cal_type,
                     p_seq_num    =>        g_ci_sequence_number
                    );
      FETCH c_base_id INTO l_base_id;
      IF c_base_id%FOUND THEN
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_unidentified_isir_rec.debug','Base_id ' ||l_base_id|| ' found for mached person_id ' ||lv_person_id);
        END IF;

        -- Chk if ISIR record exists for this matched person
        OPEN chk_isir_exist(cp_base_id => l_base_id);
        FETCH chk_isir_exist INTO l_chk_isir_exist;

        IF (chk_isir_exist%NOTFOUND) THEN
          -- ISIR does not exist for this matched person. So create new ISIR and move it to MATCHED.

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_unidentified_isir_rec.debug','ISIR does NOT exist for base_id ' ||l_base_id|| '. Calling auto_fa_rec() to create new ISIR and mark it as MATCHED.');
          END IF;

          auto_fa_rec(
                        p_person_id  =>        lv_person_id ,
                        p_apm_id     =>        ln_apm_id ,
                        p_cal_type   =>        g_ci_cal_type,
                        p_seq_num    =>        g_ci_sequence_number
                     );
        ELSE
          -- ISIR exists for this matched person. The transaction number of the matched person's ISIR  could be same or different
          -- from the new ISIR in the interface table. In both cases, we move the ISIR for manual review.

          rvw_fa_rec(p_apm_id => ln_apm_id);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,
                          'igf.plsql.igf_ap_matching_process_pkg.process_unidentified_isir_rec.debug',
                          'ISIR exists for base_id ' ||l_base_id|| '. But the tran_num does NOT match with interface table. Marked ISIR for REVIEW');
          END IF;
        END IF;
        CLOSE chk_isir_exist;
     ELSE
       -- person is deemed as matched.
       auto_fa_rec(p_person_id  =>        lv_person_id ,
                   p_apm_id     =>        ln_apm_id ,
                   p_cal_type   =>        g_ci_cal_type,
                   p_seq_num    =>        g_ci_sequence_number
                  );

       fnd_message.set_name('IGF','IGF_AP_ISIR_AUTO_FA');
       fnd_file.put_line(fnd_file.log, fnd_message.get);
     END IF;

     CLOSE c_base_id;
   ELSIF ln_match_score >= g_setup_score.min_score_rvw_fa THEN

      -- record status to be updated to review
      rvw_fa_rec(p_apm_id     =>   ln_apm_id);
   ELSE
      -- match_score is less than the min_score_rvw_fa and hence to be marked as UNMATCHED.
      IF (g_force_add = 'Y')  THEN

         -- call procedure to process unmatched rec
         unmatched_rec(p_apm_id      => ln_apm_id,
                       p_called_from => 'PLSQL',
                       p_msg_out     => lv_msg_out); -- OUT parameter

      ELSE -- i.e. g_force_add = 'N'

         log_debug_message(' Force ADD = N.  Hence updating the status to Unmatched');
         -- call procedure to update the record_status of igf_ap_person_match and match details table
         update_prsn_match_rec_status(p_apm_id      => ln_apm_id,
                                      p_rec_status  => 'UNMATCHED');

         --  call procedure to update the ISIR Int record_status to 'UNMATCHED'
         update_isir_int_record (p_si_id           => g_isir_intrface_rec.si_id,
                                 p_isir_rec_status => 'UNMATCHED',
                                 p_match_code      => g_match_code);


         -- Incrementing the umamatched recs ,these record_status is going to be 'UNMATCHED'
         g_unmatched_rec   := g_unmatched_rec + 1 ;

      END IF;
   END IF ; -- ln_match_score

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_unidentified_isir_rec.debug','Completed process_unidentified_isir_rec successfully..');
   END IF;
   log_debug_message(' Completed process_unidentified_isir_rec Proc');

EXCEPTION
   WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.process_unidentified_isir_rec.exception','The exception is : ' || SQLERRM );
      END IF;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.process_unidentified_isir_rec');
      igs_ge_msg_stack.add;
      fnd_file.put_line(fnd_file.log, ' - '|| SQLERRM);
      app_exception.raise_exception;
END process_unidentified_isir_rec;

/* Added as a part of Bug 4403807
This procedure returns the payment isir id if it exists,
otherwise it returns the isir id of the isir on which the correction has been created.
*/
PROCEDURE get_corrected_isir(p_base_id IN NUMBER, p_isir_id OUT NOCOPY NUMBER)
IS

  CURSOR c_get_payment_isir(cp_base_id NUMBER) IS
  SELECT isir_id
  FROM igf_ap_isir_matched_all
  WHERE base_id = cp_base_id
  AND payment_isir = 'Y';

  CURSOR c_get_trans_num(cp_base_id NUMBER) IS
  SELECT transaction_num
  FROM igf_ap_isir_matched_all
  WHERE base_id = cp_base_id
  AND system_record_type = 'CORRECTION';

  CURSOR c_get_isir_id(cp_trans_num igf_ap_isir_matched_all.transaction_num%TYPE,
                       cp_base_id   igf_ap_isir_matched_all.base_id%TYPE) IS
  SELECT isir_id
  FROM igf_ap_isir_matched_all
  WHERE base_id = cp_base_id
  AND transaction_num = cp_trans_num
  AND system_record_type <> 'CORRECTION';

  l_get_trans_num igf_ap_isir_matched_all.transaction_num%TYPE;

BEGIN

    OPEN c_get_payment_isir(p_base_id);
    FETCH c_get_payment_isir INTO p_isir_id;
    IF c_get_payment_isir%NOTFOUND THEN
      p_isir_id := null;
      OPEN c_get_trans_num(p_base_id);
      FETCH c_get_trans_num INTO l_get_trans_num;
      IF c_get_trans_num%FOUND THEN
        OPEN c_get_isir_id(l_get_trans_num, p_base_id);
        FETCH c_get_isir_id INTO p_isir_id;
        CLOSE c_get_isir_id;
      END IF;
      CLOSE c_get_trans_num;
    END IF;
    CLOSE c_get_payment_isir;

END get_corrected_isir;



PROCEDURE process_corrections(p_old_payment_isir       IN NUMBER,
                              p_new_payment_isir       IN NUMBER,
                              p_new_isir_is_pymnt_isir IN VARCHAR2)
IS
/*
||  Created By : rgangara
||  Created On : 19-AUG-2004
||  Purpose : This Procedure processes corrections and gets called only when for a New Payment isir.
||            This procedure gets executed only when the Pell Match Type is 'N'.
||            Parameter p_new_isir_is_pymnt_isir is not actually required but has been retained for any future requirement.
||            This process Scan all Correction records and match them.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
*/

   CURSOR get_ISIR (ln_isir_id NUMBER) IS
   SELECT isir.*
   FROM   igf_ap_isir_matched isir
   WHERE  isir_id = ln_isir_id ;

   lv_payment_isir_rec get_isir%ROWTYPE;


   CURSOR get_corr_isir (cp_base_id igf_ap_isir_matched_all.base_id%TYPE) IS
   SELECT row_id, isir_id
   FROM   igf_ap_isir_matched
   WHERE  base_id = cp_base_id
     AND  NVL(system_record_type,'*') = 'CORRECTION';

   l_cor_isir get_corr_isir%ROWTYPE;


   CURSOR cur_isir_corr (cp_base_id     igf_ap_isir_matched.base_id%TYPE,
                         cp_corr_stat  VARCHAR2 ) IS
   SELECT corr.*,
          sar.sar_field_name column_name
   FROM   igf_ap_batch_aw_map  map,
          igf_ap_ISIR_corr     corr,
          igf_fc_sar_cd_mst    sar,
          igf_ap_isir_matched  isir
   WHERE  map.ci_cal_type        = g_ci_cal_type
     AND  map.ci_sequence_number = g_ci_sequence_number
     AND  corr.isir_id           = isir.isir_id
     AND  isir.base_id           = cp_base_id
     AND  corr.ci_cal_type       = map.ci_cal_type
     AND  corr.ci_sequence_number= map.ci_sequence_number
     AND  corr.correction_status <> cp_corr_stat
     AND  sar.sys_award_year     = map.sys_award_year
     AND  sar.sar_field_number   = corr.sar_field_number ;

   l_corr_stat   VARCHAR2(30) ;


    CURSOR cur_isir_corr_pymt (cp_isir_id igf_ap_isir_matched.isir_id%TYPE)  IS
    SELECT corr.*
    FROM   igf_ap_ISIR_corr corr
    WHERE  corr.isir_id = cp_isir_id  ;


   lv_Param_Values     VARCHAR2(200);
   lv_all_corr_rcvd    VARCHAR2(1);
   lv_tot              NUMBER;
   n                   NUMBER;
   p_new_isir_id       NUMBER;

  TYPE corr_rec IS RECORD(
                          column_name  VARCHAR2(200),
                          column_value VARCHAR2(200) );

  TYPE corr_tab IS TABLE OF corr_rec;
  lv_corr_tab corr_tab := corr_tab() ;

    l_anticip_status  VARCHAR2(30);
    l_awd_prc_status  VARCHAR2(30);

  l_corrected_value   igf_ap_isir_corr_all.corrected_value%TYPE;
  l_column_value      igf_ap_isir_corr_all.corrected_value%TYPE;

BEGIN

   log_debug_message(' Beginning Processing Corrections for payment isir ' || p_new_payment_isir);


   IF p_new_isir_is_pymnt_isir = 'Y' THEN
      -- Payment ISIR is getting changed
      p_new_isir_id := p_new_payment_isir ;
   ELSE
      -- Set a New Payment ISIR ID to Null
      p_new_isir_id := NULL;
   END IF;


   -- Process Corrections
   -- Load the pl/sql Table
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.validate_correction_school.debug','Before processing the correction items');
   END IF;

   n := 1 ;
   lv_corr_tab.extend;
   lv_corr_tab(n).column_name  := 'CURRENT_SSN';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.current_ssn_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SSN_NAME_CHANGE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.ssn_name_change_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'ORIGINAL_SSN';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.original_ssn_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'ORIG_NAME_ID';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.orig_name_id_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'LAST_NAME';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.last_name ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'FIRST_NAME';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.first_name ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'MIDDLE_INITIAL';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.middle_initial_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PERM_MAIL_ADD';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.perm_mail_address_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PERM_CITY';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.perm_city_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PERM_STATE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.perm_state_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PERM_ZIP_CODE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.perm_zip_cd ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'DATE_OF_BIRTH';
   lv_corr_tab(n).column_value := fnd_date.date_to_chardate(g_isir_intrface_rec.birth_date) ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PHONE_NUMBER';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.phone_number_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'DRIVER_LICENSE_NUMBER';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.driver_license_number_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'DRIVER_LICENSE_STATE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.driver_license_state_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'CITIZENSHIP_STATUS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.citizenship_status_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'ALIEN_REG_NUMBER';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.alien_reg_number_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_MARITAL_STATUS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_marital_status_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_MARITAL_STATUS_DATE';
   lv_corr_tab(n).column_value := to_char(g_isir_intrface_rec.s_marital_status_date, 'YYYYMM') ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SUMM_ENRL_STATUS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.summ_enrl_status_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'FALL_ENRL_STATUS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.fall_enrl_status_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'WINTER_ENRL_STATUS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.winter_enrl_status_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SPRING_ENRL_STATUS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.spring_enrl_status_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SUMM2_ENRL_STATUS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.summ2_enrl_status_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'FATHERS_HIGHEST_EDU_LEVEL';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.fathers_highst_edu_lvl_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.validate_correction_school.debug','Processing correction items1');
   END IF;

   lv_corr_tab(n).column_name  := 'MOTHERS_HIGHEST_EDU_LEVEL';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.mothers_highst_edu_lvl_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_STATE_LEGAL_RESIDENCE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_state_legal_residence ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'LEGAL_RESIDENCE_BEFORE_DATE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.legal_res_before_year_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_LEGAL_RESD_DATE';
   lv_corr_tab(n).column_value := to_char(g_isir_intrface_rec.s_legal_resd_date, 'YYYYMM') ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SS_R_U_MALE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.ss_r_u_male_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SELECTIVE_SERVICE_REG';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.selective_service_reg_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'DEGREE_CERTIFICATION';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.degree_certification_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'GRADE_LEVEL_IN_COLLEGE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.grade_level_in_college_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'HIGH_SCHOOL_DIPLOMA_GED';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.high_schl_diploma_ged_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'FIRST_BACHELOR_DEG_BY_DATE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.first_bachlr_deg_year_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'INTEREST_IN_LOAN';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.interest_in_loan_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'INTEREST_IN_STUD_EMPLOYMENT';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.interest_in_stu_employ_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'DRUG_OFFENCE_CONVICTION';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.drug_offence_convict_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_TAX_RETURN_STATUS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_tax_return_status_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_TYPE_TAX_RETURN';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_type_tax_return_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_ELIG_1040EZ';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_elig_1040ez_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_ADJUSTED_GROSS_INCOME';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_adjusted_gross_income_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_FED_TAXES_PAID';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_fed_taxes_paid_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_EXEMPTIONS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_exemptions_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_INCOME_FROM_WORK';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_income_from_work_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SPOUSE_INCOME_FROM_WORK';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.spouse_income_from_work_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_TOA_AMT_FROM_WSA';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_total_from_wsa_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_TOA_AMT_FROM_WSB';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_total_from_wsb_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_TOA_AMT_FROM_WSC';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_total_from_wsc_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.validate_correction_school.debug','processing correction items2');
   END IF;

   lv_corr_tab(n).column_name  := 'S_INVESTMENT_NETWORTH';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_investment_networth_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_BUSI_FARM_NETWORTH';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_busi_farm_networth_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_CASH_SAVINGS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_cash_savings_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'VA_MONTHS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.va_months_num ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'VA_AMOUNT';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.va_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'STUD_DOB_BEFORE_DATE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.stud_dob_before_year_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'DEG_BEYOND_BACHELOR';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.deg_beyond_bachelor_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_MARRIED';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_married_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_HAVE_CHILDREN';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_have_children_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'LEGAL_DEPENDENTS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.legal_dependents_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'ORPHAN_WARD_OF_COURT';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.orphan_ward_of_court_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_VETERAN';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_veteran_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'P_MARITAL_STATUS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.p_marital_status_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'FATHER_SSN';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.father_ssn_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'F_LAST_NAME';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.f_last_name ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'MOTHER_SSN';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.mother_ssn_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'M_LAST_NAME';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.m_last_name ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'P_NUM_FAMILY_MEMBER';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.p_family_members_num ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'P_NUM_IN_COLLEGE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.p_in_college_num ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'P_STATE_LEGAL_RESIDENCE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.p_state_legal_residence_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'P_STATE_LEGAL_RES_BEFORE_DT';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.p_legal_res_before_dt_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'P_LEGAL_RES_DATE';
   lv_corr_tab(n).column_value := to_char(g_isir_intrface_rec.p_legal_res_date, 'YYYYMM') ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'AGE_OLDER_PARENT';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.age_older_parent_num ;
   n := n + 1 ;
   lv_corr_tab.extend;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.validate_correction_school.debug','Processing correction items3');
   END IF;

   lv_corr_tab(n).column_name  := 'P_TAX_RETURN_STATUS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.p_tax_return_status_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'P_TYPE_TAX_RETURN';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.p_type_tax_return_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'P_ELIG_1040AEZ';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.p_elig_1040aez_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'P_ADJUSTED_GROSS_INCOME';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.p_adjusted_gross_income_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'P_TAXES_PAID';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.p_taxes_paid_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'P_EXEMPTIONS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.p_exemptions_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'F_INCOME_WORK';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.f_income_work_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'M_INCOME_WORK';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.m_income_work_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'P_INCOME_WSA';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.p_income_wsa_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'P_INCOME_WSB';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.p_income_wsb_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'P_INCOME_WSC';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.p_income_wsc_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'P_INVESTMENT_NETWORTH';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.p_investment_networth_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'P_BUSINESS_NETWORTH';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.p_business_networth_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'P_CASH_SAVING';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.p_cash_saving_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_NUM_FAMILY_MEMBERS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_family_members_num ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_NUM_IN_COLLEGE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_in_college_num ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'FIRST_COLLEGE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.first_college_cd ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'FIRST_HOUSE_PLAN';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.first_house_plan_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECOND_COLLEGE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.second_college_cd ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECOND_HOUSE_PLAN';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.second_house_plan_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'THIRD_COLLEGE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.third_college_cd ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'THIRD_HOUSE_PLAN';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.third_house_plan_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'FOURTH_COLLEGE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.fourth_college_cd ;
   n := n + 1 ;
   lv_corr_tab.extend;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.validate_correction_school.debug','Processing correction items4');
   END IF;

   lv_corr_tab(n).column_name  := 'FOURTH_HOUSE_PLAN';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.fourth_house_plan_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'FIFTH_COLLEGE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.fifth_college_cd ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'FIFTH_HOUSE_PLAN';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.fifth_house_plan_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SIXTH_COLLEGE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sixth_college_cd ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SIXTH_HOUSE_PLAN';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sixth_house_plan_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'DATE_APP_COMPLETED';
   lv_corr_tab(n).column_value := fnd_date.date_to_chardate(g_isir_intrface_rec.app_completed_date) ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SIGNED_BY';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.signed_by_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PREPARER_SSN';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.preparer_ssn_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PREPARER_EMP_ID_NUMBER';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.preparer_emp_id_number_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PREPARER_SIGN';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.preparer_sign_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'TRANSACTION_RECEIPT_DATE';
   lv_corr_tab(n).column_value := fnd_date.date_to_chardate(g_isir_intrface_rec.transaction_receipt_date) ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'DEPENDENCY_OVERRIDE_IND';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.dependency_override_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'FAA_FEDRAL_SCHL_CODE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.faa_fedral_schl_cd ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'FAA_ADJUSTMENT';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.faa_adjustment_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'INPUT_RECORD_TYPE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.input_record_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SERIAL_NUMBER';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.serial_num ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'BATCH_NUMBER';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.batch_number_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'EARLY_ANALYSIS_FLAG';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.early_analysis_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'APP_ENTRY_SOURCE_CODE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.app_entry_source_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'ETI_DESTINATION_CODE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.eti_destination_cd ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'REJECT_OVERRIDE_B';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.reject_override_b_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'REJECT_OVERRIDE_N';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.reject_override_n_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'REJECT_OVERRIDE_W';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.reject_override_w_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'ASSUM_OVERRIDE_1';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.assum_override_1_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.validate_correction_school.debug','Processing correction items5');
   END IF;

   lv_corr_tab(n).column_name  := 'ASSUM_OVERRIDE_2';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.assum_override_2_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'ASSUM_OVERRIDE_3';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.assum_override_3_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'ASSUM_OVERRIDE_4';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.assum_override_4_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'ASSUM_OVERRIDE_5';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.assum_override_5_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'ASSUM_OVERRIDE_6';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.assum_override_6_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'DEPENDENCY_STATUS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.dependency_status_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_EMAIL_ADDRESS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_email_address_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'NSLDS_REASON_CODE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.nslds_reason_cd ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'APP_RECEIPT_DATE';
   lv_corr_tab(n).column_value := fnd_date.date_to_chardate(g_isir_intrface_rec.app_receipt_date) ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PROCESSED_REC_TYPE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.processed_rec_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'HIST_CORRECTION_FOR_TRAN_ID';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.hist_corr_for_tran_num ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SYSTEM_GENERATED_INDICATOR';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sys_generated_indicator_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'DUP_REQUEST_INDICATOR';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.dup_request_indicator_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SOURCE_OF_CORRECTION';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.source_of_correction_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'P_CAL_TAX_STATUS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.p_cal_tax_status_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'S_CAL_TAX_STATUS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.s_cal_tax_status_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'GRADUATE_FLAG';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.graduate_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'AUTO_ZERO_EFC';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.auto_zero_efc_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'EFC_CHANGE_FLAG';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.efc_change_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SARC_FLAG';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sarc_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SIMPLIFIED_NEED_TEST';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.simplified_need_test_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'REJECT_REASON_CODES';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.reject_reason_codes_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SELECT_SERVICE_MATCH_FLAG';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.select_service_match_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SELECT_SERVICE_REG_FLAG';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.select_service_reg_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'INS_MATCH_FLAG';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.ins_match_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SEC_INS_MATCH_FLAG';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sec_ins_match_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SEC_INS_VER_NUMBER';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sec_ins_ver_num ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SSN_MATCH_FLAG';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.ssn_match_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SSA_CITIZENSHIP_FLAG';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.ssa_citizenship_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SSN_DATE_OF_DEATH';
   lv_corr_tab(n).column_value := fnd_date.date_to_chardate(g_isir_intrface_rec.ssn_death_date) ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'NSLDS_MATCH_FLAG';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.nslds_match_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'VA_MATCH_FLAG';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.va_match_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PRISONER_MATCH';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.prisoner_match_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'VERIFICATION_FLAG';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.verification_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SUBSEQUENT_APP_FLAG';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.subsequent_app_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'APP_SOURCE_SITE_CODE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.app_source_site_cd ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'TRAN_SOURCE_SITE_CODE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.tran_source_site_cd ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'DRN';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.drn_num ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'TRAN_PROCESS_DATE';
   lv_corr_tab(n).column_value := fnd_date.date_to_chardate(g_isir_intrface_rec.tran_process_date) ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'COMPUTER_BATCH_NUMBER';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.computer_batch_num ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'CORRECTION_FLAGS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.correction_flags_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'HIGHLIGHT_FLAGS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.highlight_flags_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PAID_EFC';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.paid_efc_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PRIMARY_EFC';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.primary_efc_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECONDARY_EFC';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.secondary_efc_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'FED_PELL_GRANT_EFC_TYPE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.fed_pell_grant_efc_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PRIMARY_EFC_TYPE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.primary_efc_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SEC_EFC_TYPE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sec_efc_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.validate_correction_school.debug','Processing correction items6');
   END IF;

   lv_corr_tab(n).column_name  := 'PRIMARY_ALTERNATE_MONTH_1';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.primary_alt_month_1_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PRIMARY_ALTERNATE_MONTH_2';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.primary_alt_month_2_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PRIMARY_ALTERNATE_MONTH_3';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.primary_alt_month_3_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PRIMARY_ALTERNATE_MONTH_4';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.primary_alt_month_4_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PRIMARY_ALTERNATE_MONTH_5';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.primary_alt_month_5_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PRIMARY_ALTERNATE_MONTH_6';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.primary_alt_month_6_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PRIMARY_ALTERNATE_MONTH_7';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.primary_alt_month_7_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PRIMARY_ALTERNATE_MONTH_8';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.primary_alt_month_8_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PRIMARY_ALTERNATE_MONTH_10';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.primary_alt_month_10_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PRIMARY_ALTERNATE_MONTH_11';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.primary_alt_month_11_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PRIMARY_ALTERNATE_MONTH_12';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.primary_alt_month_12_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SEC_ALTERNATE_MONTH_1';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sec_alternate_month_1_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SEC_ALTERNATE_MONTH_2';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sec_alternate_month_2_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SEC_ALTERNATE_MONTH_3';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sec_alternate_month_3_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SEC_ALTERNATE_MONTH_4';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sec_alternate_month_4_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SEC_ALTERNATE_MONTH_5';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sec_alternate_month_5_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SEC_ALTERNATE_MONTH_6';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sec_alternate_month_6_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SEC_ALTERNATE_MONTH_7';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sec_alternate_month_7_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SEC_ALTERNATE_MONTH_8';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sec_alternate_month_8_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SEC_ALTERNATE_MONTH_10';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sec_alternate_month_10_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SEC_ALTERNATE_MONTH_11';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sec_alternate_month_11_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SEC_ALTERNATE_MONTH_12';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sec_alternate_month_12_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'TOTAL_INCOME';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.total_income_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'ALLOW_TOTAL_INCOME';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.allow_total_income_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'STATE_TAX_ALLOW';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.state_tax_allow_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'EMPLOYMENT_ALLOW';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.employment_allow_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'INCOME_PROTECTION_ALLOW';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.income_protection_allow_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'AVAILABLE_INCOME';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.available_income_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'CONTRIBUTION_FROM_AI';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.contribution_from_ai_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'DISCRETIONARY_NETWORTH';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.discretionary_networth_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'EFC_NETWORTH';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.efc_networth_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'ASSET_PROTECT_ALLOW';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.asset_protect_allow_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PARENTS_CONT_FROM_ASSETS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.parents_cont_from_assets_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'ADJUSTED_AVAILABLE_INCOME';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.adjusted_avail_income_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'TOTAL_STUDENT_CONTRIBUTION';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.total_student_contrib_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'TOTAL_PARENT_CONTRIBUTION';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.total_parent_contrib_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PARENTS_CONTRIBUTION';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.parents_contribution_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'STUDENT_TOTAL_INCOME';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.student_total_income_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SATI';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sati_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SIC';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sic_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SDNW';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sdnw_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SCA';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sca_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'FTI';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.fti_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECTI';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.secti_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECATI';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.secati_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECSTX';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.secstx_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECEA';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.secea_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECIPA';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.secipa_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECAI';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.secai_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECCAI';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.seccai_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECDNW';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.secdnw_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECNW';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.secnw_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECAPA';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.secapa_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECPCA';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.SECPCA_AMT ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECAAI';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.secaai_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECTSC';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sectsc_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECTPC';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sectpc_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECPC';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.secpc_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECSTI';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.secsti_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECSIC';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.secsic_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECSATI';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.secsati_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECSDNW';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.secsdnw_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SECSCA';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.secsca_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.validate_correction_school.debug','Processing correction items7');
   END IF;

   lv_corr_tab(n).column_name  := 'SECFTI';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.secfti_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_CITIZENSHIP';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_citizenship_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_STUDENT_MARITAL_STATUS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_studnt_marital_status_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_STUDENT_AGI';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_student_agi_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_S_US_TAX_PAID';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_s_us_tax_paid_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_S_INCOME_WORK';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_s_income_work_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_SPOUSE_INCOME_WORK';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_spouse_income_work_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_S_TOTAL_WSC';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_s_total_wsc_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_DATE_OF_BIRTH';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_date_of_birth_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_STUDENT_MARRIED';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_student_married_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_HAVE_CHILDREN';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_have_children_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_S_HAVE_DEPENDENTS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_s_have_dependents_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_VA_STATUS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_va_status_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_S_NUM_IN_FAMILY';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_s_in_family_num ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_S_NUM_IN_COLLEGE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_s_in_college_num ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_P_MARITAL_STATUS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_p_marital_status_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_FATHER_SSN';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_father_ssn_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_MOTHER_SSN';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_mother_ssn_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_PARENTS_NUM_FAMILY';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_parents_family_num ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_PARENTS_NUM_COLLEGE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_parents_college_num ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_PARENTS_AGI';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_parents_agi_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_P_US_TAX_PAID';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_p_us_tax_paid_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_F_WORK_INCOME';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_f_work_income_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_M_WORK_INCOME';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_m_work_income_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'A_P_TOTAL_WSC';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.a_p_total_wsc_amt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'COMMENT_CODES';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.comment_codes_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'SAR_ACK_COMM_CODE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.sar_ack_comm_codes_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PELL_GRANT_ELIG_FLAG';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.pell_grant_elig_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'REPROCESS_REASON_CODE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.reprocess_reason_cd ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'DUPLICATE_DATE';
   lv_corr_tab(n).column_value := fnd_date.date_to_chardate(g_isir_intrface_rec.duplicate_date) ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'ISIR_TRANSACTION_TYPE';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.isir_transaction_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'FEDRAL_SCHL_CODE_INDICATOR';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.fedral_schl_type ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'MULTI_SCHOOL_CODE_FLAGS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.multi_school_cd_flags_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'DUP_SSN_INDICATOR';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.dup_ssn_indicator_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'FAFSA_DATA_VERIFY_FLAGS';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.fafsa_data_verification_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'REJECT_OVERRIDE_A';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.reject_override_a_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'REJECT_OVERRIDE_C';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.reject_override_c_flag ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PARENT_MARITAL_STATUS_DATE';
   lv_corr_tab(n).column_value := to_char(g_isir_intrface_rec.parent_marital_status_date, 'YYYYMM') ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'FATHER_FIRST_NAME_INITIAL_TXT';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.fathr_first_name_initial_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'FATHER_STEP_FATHER_BIRTH_DATE';
   lv_corr_tab(n).column_value := fnd_date.date_to_chardate(g_isir_intrface_rec.fathr_step_father_birth_date) ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'MOTHER_FIRST_NAME_INITIAL_TXT';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.mothr_first_name_initial_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'MOTHER_STEP_MOTHER_BIRTH_DATE';
   lv_corr_tab(n).column_value := fnd_date.date_to_chardate(g_isir_intrface_rec.mothr_step_mother_birth_date) ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'DHS_VERIFICATION_NUM_TXT';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.dhs_verification_num_txt ;
   n := n + 1 ;
   lv_corr_tab.extend;

   lv_corr_tab(n).column_name  := 'PARENTS_EMAIL_ADDRESS_TXT';
   lv_corr_tab(n).column_value := g_isir_intrface_rec.parents_email_address_txt ;

   lv_tot := lv_corr_tab.COUNT;


   -- Initialised to assume that the user has no New corrections
   lv_all_corr_rcvd  := 'Y' ;
   l_corr_stat := 'ACKNOWLEDGED' ;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.validate_correction_school.debug','Correction poulation completed.');
   END IF;

   FOR isir_corr_rec IN cur_ISIR_corr(g_base_id, l_corr_stat )
   LOOP
     -- loop thru the Pl/SQL table and match columns
     FOR n in 1..lv_tot
     LOOP

       IF isir_corr_rec.column_name = lv_corr_tab(n).column_name THEN

        IF isir_corr_rec.column_name IN ('S_LEGAL_RESD_DATE', 'PARENT_MARITAL_STATUS_DATE', 'S_MARITAL_STATUS_DATE', 'P_LEGAL_RES_DATE') THEN

          l_corrected_value := to_char(fnd_date.chardate_to_date(isir_corr_rec.corrected_value), 'YYYYMM');
          l_column_value    := lv_corr_tab(n).column_value ;

        ELSE
          l_corrected_value := NVL(isir_corr_rec.corrected_value,'##');
          l_column_value    := NVL(lv_corr_tab(n).column_value,'##');
        END IF;

         -- Current col in pl/sql table reached
         IF l_corrected_value = l_column_value THEN
             -- update only if it is not already acknowledged
             IF NOT igf_ap_isir_corr_pkg.get_uk_for_validation(  NVL(p_new_isir_id,isir_corr_rec.isir_id),
                                             isir_corr_rec.sar_field_number,
                                             'ACKNOWLEDGED') THEN
                igf_ap_ISIR_corr_pkg.update_row (
                    x_rowid                                 =>        isir_corr_rec.row_id,
                    x_ISIRc_id                              =>        isir_corr_rec.ISIRc_id,
                    x_ISIR_id                               =>        NVL(p_new_isir_id,isir_corr_rec.isir_id),
                    x_ci_sequence_number                    =>        isir_corr_rec.ci_sequence_number,
                    x_ci_cal_type                           =>        isir_corr_rec.ci_cal_type,
                    x_sar_field_number                      =>        isir_corr_rec.sar_field_number,
                    x_original_value                        =>        isir_corr_rec.original_value,
                    x_batch_id                              =>        isir_corr_rec.batch_id,
                    x_corrected_value                       =>        isir_corr_rec.corrected_value,
                    x_correction_status                     =>        'ACKNOWLEDGED',
                    x_mode                                  =>        'R');
RAM_I_CORR  := RAM_I_CORR +1;
             END IF;

             fnd_message.set_name('IGF','IGF_AP_ISIR_CORR_ACK');
             fnd_message.set_token('FIELD', isir_corr_rec.column_name);
             fnd_file.put_line(fnd_file.log,fnd_message.get);

         ELSE
             -- Set the flag that there are still corrections.
             lv_all_corr_rcvd  := 'N' ;

             -- update only if the matching record is not already in ready status
             IF NOT igf_ap_isir_corr_pkg.get_uk_for_validation(  NVL(p_new_isir_id,isir_corr_rec.isir_id),
                                             isir_corr_rec.sar_field_number,
                                             'READY') THEN
                  igf_ap_ISIR_corr_pkg.update_row (
                    x_rowid                                 =>        isir_corr_rec.row_id,
                    x_ISIRc_id                              =>        isir_corr_rec.ISIRc_id,
                    x_ISIR_id                               =>        NVL(p_new_isir_id,isir_corr_rec.isir_id),
                    x_ci_sequence_number                    =>        isir_corr_rec.ci_sequence_number,
                    x_ci_cal_type                           =>        isir_corr_rec.ci_cal_type,
                    x_sar_field_number                      =>        isir_corr_rec.sar_field_number,
                    x_original_value                        =>        isir_corr_rec.original_value,
                    x_batch_id                              =>        isir_corr_rec.batch_id,
                    x_corrected_value                       =>        isir_corr_rec.corrected_value,
                    x_correction_status                     =>        'READY',
                    x_mode                                  =>        'R');
RAM_U_CORR  := RAM_U_CORR +1;
             END IF;

             g_count_corr := g_count_corr + 1;
             fnd_message.set_name('IGF','IGF_AP_ISIR_CORR_READY');
             fnd_message.set_token('FIELD', isir_corr_rec.column_name);
             fnd_file.put_line(fnd_file.log,fnd_message.get);
         END IF;

         -- Column found and updated hence exit and move to next correction
         EXIT;

       END IF;

     END LOOP; -- n in 1..lv_tot

     -- Get the next correction.
   END LOOP; -- isir_corr_rec

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.validate_correction_school.debug','Corrections updated...');
   END IF;


   IF p_new_isir_is_pymnt_isir = 'Y' THEN
      -- Payment ISIR is got changed
      -- So update the Payment ISIR ID for all existing correction records that Have not been udated
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_corrections.debug','Before updating the paymnet ISIR');
      END IF;

      FOR l_cur_isir_corr_pymnt IN cur_isir_corr_pymt(p_old_payment_isir)
      LOOP

         -- update only if not already in the said status
         IF NOT igf_ap_isir_corr_pkg.get_uk_for_validation( p_new_isir_id,
                                             l_cur_isir_corr_pymnt.sar_field_number,
                                             l_cur_isir_corr_pymnt.correction_status) THEN

             igf_ap_ISIR_corr_pkg.update_row (
                    x_rowid                                 =>        l_cur_isir_corr_pymnt.row_id,
                    x_ISIRc_id                              =>        l_cur_isir_corr_pymnt.ISIRc_id,
                    x_ISIR_id                               =>        p_new_isir_id,
                    x_ci_sequence_number                    =>        l_cur_isir_corr_pymnt.ci_sequence_number,
                    x_ci_cal_type                           =>        l_cur_isir_corr_pymnt.ci_cal_type,
                    x_sar_field_number                      =>        l_cur_isir_corr_pymnt.sar_field_number,
                    x_original_value                        =>        l_cur_isir_corr_pymnt.original_value,
                    x_batch_id                              =>        l_cur_isir_corr_pymnt.batch_id,
                    x_corrected_value                       =>        l_cur_isir_corr_pymnt.corrected_value,
                    x_correction_status                     =>        l_cur_isir_corr_pymnt.correction_status,
                    x_mode                                  =>        'R');
RAM_U_CORR  := RAM_U_CORR +1;
         END IF;

      END LOOP;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_corrections.debug','Updated ISIR Information for Correction Items to New Payment ISIR');
      END IF;
   END IF; -- payment isir check


   IF lv_all_corr_rcvd  = 'Y' THEN

      -- Since all corrections are recieved, delete existing CORRECTION ISIR record in the ISIR matched table
      --  (so that the save as correction record functionality is enabled in the ISIR review SS Page)
      -- Return Y to OUT parameter so that the newly created ISIR, can now be made as the Active ISIR

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_corrections.debug','All Corrections received..');
      END IF;

      -- Bug 4403807 - changed the argument to get_isir from p_new_isir_id to NVL(p_new_isir_id,p_new_payment_isir)
      FOR cur_new_isir_rec IN get_ISIR(NVL(p_new_isir_id,p_new_payment_isir)) LOOP
         l_cor_isir := NULL;

         -- get Correction type ISIR.
         OPEN get_corr_isir(cur_new_isir_rec.base_id);
         FETCH get_corr_isir INTO l_cor_isir;
         CLOSE get_corr_isir;

         -- now delete the correction isir
         IF l_cor_isir.row_id IS NOT NULL THEN
            igf_ap_isir_matched_pkg.delete_row(l_cor_isir.row_id); -- delete the correction type isir.

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_corrections.debug','Deleted existing Correction ISIR ID: ' || l_cor_isir.isir_id);
            END IF;
         END IF;

         -- update the new ISIR record to make it an ACTIVE ISIR as all corrections have been received.
         update_isir_matched_rec(p_isir_matched_record => cur_new_isir_rec,
                                 p_payment_isir        => cur_new_isir_rec.payment_isir,
                                 p_active_isir         => 'Y');

        -- bbb case 3
        -- get first the EFC data for Corr ISIR before deleting and do cmp
        -- also chk for ant data
        l_anticip_status  := NULL;
        l_awd_prc_status  := NULL;
        igf_ap_isir_gen_pkg.upd_ant_data_awd_prc_status( p_old_active_isir_id => g_old_active_isir_id,
                                                         p_new_active_isir_id => p_new_payment_isir,
                                                         p_upd_ant_val        => g_upd_ant_val,
                                                         p_anticip_status     => l_anticip_status,
                                                         p_awd_prc_status     => l_awd_prc_status
                                                       );

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_corrections.debug','Made the new ISIR as Active ISIR for ISIR ID: ' || cur_new_isir_rec.isir_id);
         END IF;
      END LOOP;
   END IF; -- lv_all_corr_rcvd  = 'Y'

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_corrections.debug','Successfully processed corrections.');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.process_corrections.exception','The exception is : ' || SQLERRM );
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','PROCESS_ISIR_RECEIPT.PROCESS_CORRECTIONS');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      igs_ge_msg_stack.add;

      lv_param_values := TO_CHAR(g_Base_Id)||','|| TO_CHAR(p_new_isir_id);

      fnd_message.set_name('IGS','IGS_GE_PARAMETERS');
      fnd_message.set_token('VALUE',lv_param_values);
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
END process_corrections;

PROCEDURE process_non_payment_isir
IS
/*
||  Created By : rgangara
||  Created On : 19-AUG-2004
||  Purpose : This Procedure processes the incoming ISIR as a Non Payment ISIR.
||            This procedure gets executed only when the Pell Match Type is 'O'.
||            This process Inserts a Non Payment ISIR, NSLDS data, TODO Processing.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
*/

lv_isir_id  NUMBER;
l_nslds_id  NUMBER;
lv_corrected_isir NUMBER;
BEGIN

   log_debug_message(' Beginning process_non_payment_isir Proc');
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_non_payment_isir.debug','Beginning processing the ISIR as a NON Payment ISIR.');
   END IF;

   -- call procedure to insert a row into isir matched table.
   insert_isir_matched_rec(cp_isir_int_rec         => g_isir_intrface_rec,
                           p_payment_isir          => 'N',
                           p_active_isir           => 'N',
                           p_base_id               => g_base_id,
                           p_out_isir_id           => lv_isir_id -- OUT parameter returns value of isir id.
                         );

   -- insert record into NSLDS data table for the new transaction num
   insert_nslds_data_rec(cp_isir_intrface_rec   => g_isir_intrface_rec,
                          p_isir_id             => lv_isir_id,
                          p_base_id             => g_base_id,
                          p_out_nslds_id        => l_nslds_id
                         );

   -- call procedure to update TODO items
   process_todo_items(p_base_id      => g_base_id,
                      p_payment_isir => 'N');


     -- #4871790
   IGF_AP_BATCH_VER_PRC_PKG.update_process_status(
                          p_base_id          => g_base_id,
                          p_fed_verif_status => NULL);

   -- Bug 4403807 - adding the process_corrections procedure
    IF g_isir_intrface_rec.processed_rec_type = 'H' THEN
        get_corrected_isir(p_base_id      => g_base_id, p_isir_id => lv_corrected_isir);
        IF lv_corrected_isir IS NOT NULL THEN
          process_corrections( p_old_payment_isir => lv_corrected_isir,
                               p_new_payment_isir => lv_isir_id,
                               p_new_isir_is_pymnt_isir => 'N');
        END IF;
    END IF;

   -- update ISIR int record status
   update_isir_int_record (p_si_id           => g_isir_intrface_rec.si_id,
                           p_isir_rec_status => 'MATCHED',
                           p_match_code      => NULL);

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_non_payment_isir.debug','Completed processing the ISIR as a NON Payment ISIR.');
   END IF;
   log_debug_message(' Completed process_non_payment_isir Proc');

EXCEPTION
   WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.process_non_payment_isir.exception','The exception is : ' || SQLERRM );
      END IF;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.process_non_payment_isir');
      igs_ge_msg_stack.add;
      fnd_file.put_line(fnd_file.log, ' - '|| SQLERRM);
      app_exception.raise_exception;
END process_non_payment_isir;

PROCEDURE process_new_isir_rec IS
  /*
  ||  Created By : rgangara
  ||  Created On : 03-AUG-2004
  ||  Purpose :    For processing ISIR recs with pell match type as 'N'.
  ||               This also indicates that the isir is a valid isir and would become a payment isir.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  museshad         23-MAY-2005       Replaced the incorrect message name
  ||                                     'IGF_LAON_NEW_PYMNT_ISIR' with
  ||                                     'IGF_AP_LN_NEW_PYMNT_ISIR'
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_fabase (pn_base_id NUMBER) IS
    SELECT fa.*
      FROM igf_ap_fa_base_rec fa
     WHERE fa.base_id = pn_base_id FOR UPDATE NOWAIT ;

    lv_cur_fabase_rec cur_fabase%ROWTYPE;


    CURSOR cur_old_pymt_isir(pn_base_id NUMBER) IS
    SELECT im.*
      FROM igf_ap_isir_matched im
     WHERE im.base_id = pn_base_id
       AND im.payment_isir = 'Y';

    old_pymt_isir_rec cur_old_pymt_isir%ROWTYPE;


    CURSOR person_cur  (ln_person_id  igf_ap_fa_base_rec.person_id%TYPE)  IS
    SELECT party_number person_number
      FROM hz_parties
     WHERE party_id = ln_person_id;

    -- Get the privious Active ISIR id for the base id.
    CURSOR cur_old_active_isir(cp_base_id  igf_ap_fa_base_rec_all.base_id%TYPE) IS
    SELECT isir_id
      FROM igf_ap_isir_matched_all
     WHERE base_id = cp_base_id
       AND active_isir = 'Y';

  CURSOR cur_loan_orig_chk(cp_base_id           igf_ap_fa_base_rec_all.base_id%TYPE) IS
  SELECT
  'X'
  FROM
  IGF_SL_LOR_ALL LOR, IGF_SL_LOANS_ALL LOAN,
  IGF_AW_AWARD_ALL AWD, igf_ap_isir_matched_all m
  WHERE
  m.base_id = awd.base_id and
  awd.award_id = loan.award_id and
  loan.loan_id = lor.loan_id and
  m.base_id   = cp_base_id;


    lv_dummy VARCHAR2(1);

    person_rec  person_cur%ROWTYPE;

    lv_payment_isir      VARCHAR2(1);
    lv_rowid             VARCHAR2(30);
    lv_status            VARCHAR2(30);
    is_orig_isir_exists  BOOLEAN;
    lv_isir_id           igf_ap_isir_matched.isir_id%TYPE;
    lv_nslds_id          NUMBER;
    lv_all_corr_rcvd     VARCHAR2(1);

BEGIN

   -- initialize variables
   lv_payment_isir   := 'Y';
   lv_all_corr_rcvd  := 'Y';

   -- Load the Base Record Details as it mandatorily exists for a NEW pell type matched person
   OPEN cur_fabase(g_base_id);
   FETCH cur_fabase INTO lv_cur_fabase_rec;
   CLOSE cur_fabase;

    -- bbb
    -- Get the Old Active ISIR ID for updating the Anticipated data and Award Prcoess status
    g_old_active_isir_id := NULL;
    OPEN cur_old_active_isir(g_base_id);
    FETCH cur_old_active_isir INTO g_old_active_isir_id;
    CLOSE cur_old_active_isir;

   g_person_id := lv_cur_fabase_rec.person_id;

   -- Check if the New ISIR is an Original ISIR or a Correction ISIR.
   IF g_isir_intrface_rec.processed_rec_type = 'H' THEN  -- This is an CORRECTION ISIR
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_new_isir_rec.debug','This ISIR is a Correction ISIR');
      END IF;

      -- since correction ISIR. Perform school validation and determine flags for further processing
      validate_correction_school(p_payment_isir  => lv_payment_isir);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_new_isir_rec.debug','validate_correction_school returns Payment ISIR Flag as ' || lv_payment_isir);
      END IF;
   END IF;


   -- perform further processing  based on the payment isir flag

   IF lv_payment_isir = 'Y' THEN -- i.e. the new isir being processed need to be created as a payment isir.

      -- check if any payment isir already exists for this base id. If exists, it has to be updated to be a Non payment isir.
      OPEN  cur_old_pymt_isir(g_base_id);
      FETCH cur_old_pymt_isir INTO old_pymt_isir_rec;
      CLOSE cur_old_pymt_isir;

      IF old_pymt_isir_rec.isir_id IS NOT NULL THEN --          -- i.e. there already exists a payment isir.

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_new_isir_rec.debug','Old Payment ISIR Rec exists. Old Payment ISIR No: ' || old_pymt_isir_rec.isir_id);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_new_isir_rec.debug','Old Payment Transaction No.: ' || old_pymt_isir_rec.Transaction_num);
         END IF;
         log_debug_message('Old Payment ISIR Exists. Making it a Non Payment isir ' || old_pymt_isir_rec.isir_id || ' Trans: ' || old_pymt_isir_rec.Transaction_Num || ' Active: ' || old_pymt_isir_rec.Active_isir);

         -- check if PELL is already granted for the old payment isir. If so, log a warning message before updating.
         is_orig_isir_exists := igf_gr_gen.chk_orig_isir_exists(g_base_id, old_pymt_isir_rec.transaction_num);

         IF is_orig_isir_exists THEN
            OPEN person_cur(g_person_id);
            FETCH person_cur INTO person_rec;
            CLOSE person_cur;

            fnd_message.set_name('IGF','IGF_GR_NEW_PYMNT_ISIR');
            fnd_message.set_token('PERSON_NUMBER',person_rec.person_number);
            fnd_file.put_line(fnd_file.log, fnd_message.get);
         END IF;

         -- Check if Loan is originated for the student
         lv_dummy := null;
         OPEN cur_loan_orig_chk(g_base_id);
         FETCH cur_loan_orig_chk INTO lv_dummy;
         IF cur_loan_orig_chk%FOUND THEN
            CLOSE cur_loan_orig_chk;
            OPEN person_cur(g_person_id);
            FETCH person_cur INTO person_rec;
            CLOSE person_cur;

             -- museshad (Bug# 4091601): Modified the incorrect message name
            fnd_message.set_name('IGF','IGF_AP_LN_NEW_PYMNT_ISIR');
            fnd_message.set_token('PERSON_NUMBER',person_rec.person_number);
            fnd_file.put_line(fnd_file.log, fnd_message.get);
         ELSE
          CLOSE cur_loan_orig_chk;
         END IF;
         -- Making old ISIR non payment
          make_old_isir_non_payment(g_base_id);

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_new_isir_rec.debug','Made the exisiting payment ISIR as Non Payment ISIR');
         END IF;
      END IF; --old_pymt_isir_rec
   END IF; -- lv_payment_isir

   -- insert the NEW isir as a Payment isir.
   insert_isir_matched_rec(cp_isir_int_rec         => g_isir_intrface_rec,
                           p_payment_isir          => lv_payment_isir,
                           p_active_isir           => 'N',       -- Non active isir. May get updated based on correction processing
                           p_base_id               => g_base_id,
                           p_out_isir_id           => lv_isir_id -- OUT parameter returns value of isir id.
                          );

   -- call procedure to insert a new NSLDS data record (since inserting into isir matched table, insert into nslds data table.
   insert_nslds_data_rec(cp_isir_intrface_rec   => g_isir_intrface_rec,
                          p_isir_id             => lv_isir_id,
                          p_base_id             => g_base_id,
                          p_out_nslds_id        => lv_nslds_id); -- OUT parameter returning ID.

   -- call procedure to update fa base record when its a payment isir
   update_fa_base_rec(p_fabase_rec             => lv_cur_fabase_rec,
                      p_isir_verification_flag => g_isir_intrface_rec.verification_flag);


   -- call procedure to update TODO items
   process_todo_items(p_base_id      => g_base_id,
                      p_payment_isir => lv_payment_isir);


    -- #4871790
   IGF_AP_BATCH_VER_PRC_PKG.update_process_status(
                            p_base_id          => g_base_id,
                            p_fed_verif_status => NULL);


   IF lv_payment_isir = 'Y' THEN
      -- process corrections
      process_corrections(p_old_payment_isir       => old_pymt_isir_rec.isir_id,
                          p_new_payment_isir       => lv_isir_id,
                          p_new_isir_is_pymnt_isir => lv_payment_isir);
   END IF; -- lv_payment_isir;

   IF g_isir_intrface_rec.transaction_num_txt > g_max_tran_num THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_new_isir_rec.debug','Incoming Transaction No. > Existing Max Trans and hence Invoking Update Person Info Procedure');
      END IF;

      -- This procedure should be called only when the incoming trans num > existing max trans num
      g_called_from_process := TRUE;
      update_person_info(g_isir_intrface_rec.si_id);
   END IF;

   -- update ISIR int record status
   update_isir_int_record (p_si_id            => g_isir_intrface_rec.si_id,
                           p_isir_rec_status  => 'MATCHED',
                           p_match_code      => NULL);

   g_matched_rec := g_matched_rec + 1; -- update matched rec count
   log_debug_message('Completed processing New Interface record.');

EXCEPTION
   WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.process_new_isir_rec.exception','The exception is : ' || SQLERRM );
      END IF;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.process_new_isir_rec');
      igs_ge_msg_stack.add;
      fnd_file.put_line(fnd_file.log, ' - '|| SQLERRM);
      app_exception.raise_exception;
END process_new_isir_rec;



PROCEDURE pell_match_type_rec_processing IS

  /*
  ||  Created By : rgangara
  ||  Created On : 03-AUG-2004
  ||  Purpose :        For processing the ISIR Interface record based on its Pell Match Type.
  ||                   For pell match type of 'D' and 'O', very few processing steps reqd hence
  ||                   no separate procedures created. For 'N' and 'U' separate procedures exist.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||
  ||  (reverse chronological order - newest change first)
  */

   lv_isir_id          NUMBER;
   l_nslds_id          NUMBER;

   CURSOR get_person_cur(pn_base_id NUMBER) IS
   SELECT person_id
     FROM igf_ap_fa_base_rec
    WHERE base_id = pn_base_id;

BEGIN

   log_debug_message(' Beginning Pell Match Type rec processing... ' || g_pell_match_type);

   IF g_base_id IS NOT NULL THEN
      -- get the Person ID. This would be available for pell match type is D, O, N. For U it would be NULL.
      OPEN  get_person_cur(g_base_id);
      FETCH get_person_cur INTO g_person_id;
      CLOSE get_person_cur ;
   END IF;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.pell_match_type_rec_processing.debug','p_si_id : ' || g_isir_intrface_rec.si_id || ' , Pell Match Type : ' || g_pell_match_type );
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.pell_match_type_rec_processing.debug','The g_base_id : ' || g_base_id || ', Person ID: ' || g_person_id);
   END IF;

   -- First delete existing match records, if any, from match tables for this si_id.
   delete_person_match_rec(p_si_id   => g_isir_intrface_rec.si_id,
                           p_apm_id  => NULL);


   IF g_pell_match_type = 'D' THEN -- ISIR record is Duplicate

      fnd_message.set_name('IGF','IGF_AP_ISIR_DUPLICATE');
      fnd_file.put_line(fnd_file.log, fnd_message.get);

      g_dup_rec := NVL(g_dup_rec ,0)+ 1; -- update Duplicate rec count

      -- update ISIR int record status
      update_isir_int_record (p_si_id           => g_isir_intrface_rec.si_id,
                              p_isir_rec_status => 'MATCHED',
                              p_match_code      => NULL);

   ELSIF g_pell_match_type = 'O' THEN   -- OLD ISIR rec processing
      -- process rec as non payment isir.
      process_non_payment_isir;

   ELSIF g_pell_match_type = 'N' THEN
      -- process the isir rec as a payment isir
      process_new_isir_rec;

   ELSIF g_pell_match_type = 'U' THEN
      IF g_gen_party_profile_val = 'N' THEN -- value derived only once at the beginning of the main process
         RAISE INVALID_PROFILE_ERROR;
      END IF;

      process_unidentified_isir_rec; -- separate procedure for clarity as it has lot of processing steps.
   END IF;

EXCEPTION
   WHEN INVALID_PROFILE_ERROR THEN
      -- print the log message
      fnd_message.set_name('IGF','IGF_AP_HZ_GEN_PARTY_NUMBER');
      fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
      app_exception.raise_exception;

   WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.pell_match_type_rec_processing.exception','The exception is : ' || SQLERRM);
      END IF;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.pell_match_type_rec_processing');
      igs_ge_msg_stack.add;
      fnd_file.put_line(fnd_file.log, ' - '|| SQLERRM);
      app_exception.raise_exception;
END pell_match_type_rec_processing;


PROCEDURE process_correction_isir
IS
  /*
  ||  Created By : rgangara
  ||  Created On : 27-AUG-2004
  ||  Purpose :    Processes Correction Type of ISIR Interface record i.e. processed_rec_type = 'C'
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||
  ||  (reverse chronological order - newest change first)
  */

BEGIN

   log_debug_message(' Processing Correction ISIR.');

   update_isir_int_record (p_si_id           => g_isir_intrface_rec.si_id,
                           p_isir_rec_status => 'REVIEW',
                           p_match_code      => NULL);

   -- update review records count
   g_review_count := g_review_count + 1;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_correction_isir.statement','Updated ISIR Interface record status to REVIEW');
   END IF;

EXCEPTION
    WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.process_correction_isir.exception','The exception is : ' || SQLERRM );
      END IF;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_MATCHING_PROCESS_PKG.process_correction_isir');
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
END process_correction_isir;


PROCEDURE process_int_record
IS
  /*
  ||  Created By : rgangara
  ||  Created On : 03-AUG-2004
  ||  Purpose :        Determine the Pell Match Type and accordingly call appropriate procedures for processing the Interface record.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||
  ||  (reverse chronological order - newest change first)
  */

   CURSOR cur_max_isir ( cp_original_ssn  VARCHAR2,
                         cp_orig_name_id  VARCHAR2,
                         cp_batch_year    NUMBER,
                         cp_sys_rec_type  VARCHAR2)
   IS
   SELECT MAX(iim.transaction_num) max_id,
          iim.base_id
   FROM   igf_ap_isir_matched iim
   WHERE  iim.original_ssn       = cp_original_ssn
      AND iim.orig_name_id       = cp_orig_name_id
      AND iim.system_record_type = cp_sys_rec_type
      AND iim.batch_year         = cp_batch_year
   GROUP BY iim.base_id ;

   l_max_isir_rec cur_max_isir%ROWTYPE;


   CURSOR chk_transaction_num( cp_original_ssn     VARCHAR2,
                               cp_orig_name_id     VARCHAR2,
                               cp_batch_year       NUMBER,
                               cp_sys_rec_type     VARCHAR2,
                               cp_transaction_num  VARCHAR2)
   IS
   SELECT 1
   FROM   igf_ap_isir_matched iim
   WHERE  iim.original_ssn       = cp_original_ssn
     AND  iim.orig_name_id       = cp_orig_name_id
     AND  iim.system_record_type = cp_sys_rec_type
     AND  iim.batch_year         = cp_batch_year
     AND  iim.transaction_num    = cp_transaction_num
     AND  rownum = 1;

  CURSOR check_pymt_isir_locked_cur(pn_base_id NUMBER) IS
  SELECT isir_locked_by
    FROM igf_ap_fa_base_rec
   WHERE base_id = pn_base_id;

  CURSOR get_pymnt_isir_tran_cur(pn_base_id  NUMBER) IS
  SELECT transaction_num
    FROM igf_ap_isir_matched
   WHERE base_id = pn_base_id
     AND payment_isir = 'Y';

  l_chk_transaction_num chk_transaction_num%ROWTYPE;
  l_sys_rec_type        VARCHAR2(30) ;
  lv_valid_isir_flag    VARCHAR2(1);
  ln_isir_locked_by     NUMBER;
  ln_pay_isir_id        NUMBER;
  l_message_class       VARCHAR2(30);

BEGIN

/* ============================================================================================
  NOTE: Pell Match Code Determining logic. (U, N, O, D)

  1. IF No record found in ISIR Matched table for Original SSN, Original Name ID and Batch Year
     then the Pell Match Type is 'U' i.e. unidentified

  2. IF Match found (step 1 above), then IF a record with same transaction already exists
     then Pell Match type is 'D' i.e. Duplicate

  3. If Match Found and No record with the same transaction Number exists then it can be N or O.
     IF the incoming Int rec has
         A) A valid Primary EFC
         B) Higher transaction Num than the existing Payment ISIR
         C) Existing Payment ISIR is Not Locked
     then its pell match type is 'N' i.e. New

  4. If step 3 fails, then pell match type is 'O'. i.e. Old.
   ===========================================================================================*/

   SAVEPOINT SP1;

   -- Log ISIR Student details
   fnd_file.put_line(fnd_file.log,g_separator_line);
   fnd_file.put_line(fnd_file.log,'');
   fnd_message.set_name ('IGF','IGF_AP_STUD_SSN_DTL');
   fnd_message.set_token('NAME',g_isir_intrface_rec.first_name||' '||g_isir_intrface_rec.last_name );
   fnd_message.set_token('SSN',g_isir_intrface_rec.current_ssn_txt);
   fnd_file.put_line(fnd_file.log,fnd_message.get);

   fnd_message.set_name ('IGF','IGF_AP_STUD_TRAN_DTL');
   fnd_message.set_token('TRAN', g_isir_intrface_rec.transaction_num_txt);
   fnd_message.set_token('NCODE',g_isir_intrface_rec.orig_name_id_txt);

   fnd_file.put_line(fnd_file.log,fnd_message.get);

   --count for total number of records.
   g_total_recs_processed := g_total_recs_processed +1;

   -- initialize variables
   l_sys_rec_type    := 'ORIGINAL' ;
   l_max_isir_rec    := NULL;
   g_base_id         := NULL;
   g_max_tran_num    := NULL;
   g_person_id       := NULL;

   IF g_isir_intrface_rec.processed_rec_type = 'C' THEN
      log_debug_message('This is a Correction ISIR');
      -- put such records to REVIEW status.
      process_correction_isir;

   ELSE
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_int_record.debug','Checking for Max Transaction Number');
      END IF;

      --Check if ISIR record exists. If it does, get the max Transaction Number.
      OPEN cur_max_isir ( g_isir_intrface_rec.original_ssn_txt ,
                          g_isir_intrface_rec.orig_name_id_txt ,
                          g_isir_intrface_rec.batch_year_num,
                          l_sys_rec_type) ;

      FETCH cur_max_isir INTO l_max_isir_rec;
      IF cur_max_isir%NOTFOUND THEN
         -- Unidentified ISIR record.
         CLOSE cur_max_isir;

         g_base_id         :=  NULL;
         g_max_tran_num    :=  0;
         g_pell_match_type := 'U' ; -- Unidientified CPS record
         log_debug_message('Pell Match type is U');

      ELSE -- record exists for this person
         CLOSE cur_max_isir;
         log_debug_message('Pell Match is not U');
         -- populate base id and max transaction num to global variables.
         g_base_id      :=  l_max_isir_rec.base_id;
         g_max_tran_num :=  l_max_isir_rec.max_id;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_int_record.debug','Checking for Duplicate');
         END IF;

         -- check whether it is a duplicate isir.
         -- check whether ISIR rec with same transaction Num already exists.
         OPEN chk_transaction_num ( g_isir_intrface_rec.original_ssn_txt ,
                                    g_isir_intrface_rec.orig_name_id_txt ,
                                    g_isir_intrface_rec.batch_year_num,
                                    l_sys_rec_type,
                                    g_isir_intrface_rec.transaction_num_txt);

         FETCH chk_transaction_num INTO l_chk_transaction_num;
         IF  Chk_transaction_num%FOUND THEN
             g_pell_match_type := 'D' ; -- Duplicate ISIR record for Exisitng Student
             CLOSE Chk_transaction_num;
         ELSE
            CLOSE Chk_transaction_num;

            log_debug_message('Pell Matche type is NOT D');
            -- check whether the incoming isir is a valid isir.
            lv_valid_isir_flag := is_payment_isir(g_isir_intrface_rec.primary_efc_amt);

            IF lv_valid_isir_flag = 'N' THEN
               g_pell_match_type := 'O' ; -- Process the ISIR as a non payment isir
            ELSE

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_int_record.debug','Checking for ISIR Locking');
               END IF;

               log_debug_message('Checking for Payment ISIR being locked');
               -- check if the payment isir is locked. If so the locked isir should remain as payment isir.
               -- Any other incoming ISIR should be processed as Non payment isir even if they are valid
               -- and have a higher transaction number.
               OPEN  check_pymt_isir_locked_cur(g_base_id);
               FETCH check_pymt_isir_locked_cur INTO ln_isir_locked_by;
               CLOSE check_pymt_isir_locked_cur;

               IF ln_isir_locked_by IS NOT NULL THEN
                  -- Existing Payment ISIR is locked and hence should be retained as payment isir.
                  -- Hence Process this incoming isir as a Non payment isir.
                  g_pell_match_type := 'O' ;
               ELSE
                  log_debug_message('Checking for Payment ISIR For this person with higher Transaction Number');
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_int_record.debug','Payment ISIR Transaction No. checking');
                  END IF;

                  -- Check whether there already exists a payment isir with transaction number > incoming isir.
                  -- IF so, the incoming isir should be processed as Non payment isir Else as Payment ISIR.
                  OPEN  get_pymnt_isir_tran_cur(g_base_id);
                  FETCH get_pymnt_isir_tran_cur INTO ln_pay_isir_id;
                  CLOSE get_pymnt_isir_tran_cur;

                  IF TO_NUMBER(g_isir_intrface_rec.transaction_num_txt) < NVL(TO_NUMBER(ln_pay_isir_id),0) THEN
                     -- i.e. incoming trans num < existing payment isir flagged trans num
                     -- hence process the incoming isir rec as a Non payment isir rec.
                     g_pell_match_type := 'O' ;
                  ELSE
                     g_pell_match_type := 'N' ;
                  END IF;

               END IF; -- check_pymt_isir_locked_cur
            END IF; -- lv_valid_isir_flag

         END IF; --Chk_transaction_num%FOUND

      END IF; -- cur_max_isir%NOTFOUND

      log_debug_message(' PELL MATCH TYPE for this Interface record : ' || g_pell_match_type);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.main.debug','PELL_MATCH_TYPE for this ISIR record : ' || g_pell_match_type );
      END IF;


      -- call procedure which would process ISIR rec based on the pell match type.
      pell_match_type_rec_processing; -- call procedure which would process ISIR rec based on the pell match type.


      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.main.debug','Processed Interface record successfully. Commiting Changes');
      END IF;

   END IF; -- g_isir_intrface_rec.processed_record_type

   COMMIT;  --commit after processing the student record (i.e. commit after each isir record is processed)


   -- IF CPS Pushed ISIR processed then raise business event notification.
   l_message_class := get_msg_class_from_filename(p_filename => g_isir_intrface_rec.data_file_name_txt);

   IF l_message_class IN ('IGCO05OP','IGSA05OP') THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.process_int_record.statement','CPS Pushed ISIR processed. Message Class:' || l_message_class);
      END IF;

      -- Raise a Business Event Notification if the processed record is a CPS Pushed ISIR.
      raise_cps_pushed_isir_event;
   END IF;

EXCEPTION
   WHEN INVALID_PROFILE_ERROR THEN
     -- print the log message
     fnd_message.set_name('IGF','IGF_AP_HZ_GEN_PARTY_NUMBER');
     fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
     ROLLBACK TO SP1;
     RETURN;

   WHEN OTHERS THEN
     ROLLBACK TO SP1;
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.process_int_record.exception','The exception is : ' || SQLERRM );
     END IF;

     g_bad_rec := g_bad_rec + 1; -- update bad rec count

     fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
     fnd_message.set_token('NAME','igf_ap_matching_process_pkg.process_int_record');
     igs_ge_msg_stack.add;
     fnd_file.put_line(fnd_file.log, ' - '|| SQLERRM);
     log_debug_message('EXCEPTION : ' || SQLERRM);
     RETURN;
END process_int_record;


PROCEDURE log_statistics IS

  /*
  ||  Created By : rgangara
  ||  Created On : 03-AUG-2004
  ||  Purpose :        For Logging ISIR Import process processing statistics.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||
  ||  (reverse chronological order - newest change first)
  */

BEGIN

   fnd_file.put_line(fnd_file.log, g_separator_line);
   fnd_file.put_line(fnd_file.log, g_separator_line);
   fnd_message.set_name('IGF','IGF_AP_TOTAL_RECS');
   fnd_message.set_token('COUNT','');
   fnd_file.put_line(fnd_file.output,RPAD(fnd_message.get,50,'.')||TO_CHAR(g_total_recs_processed) );
   log_debug_message('TOTAL RECS : ' || TO_CHAR(g_total_recs_processed));

   fnd_message.set_name('IGF','IGF_AP_MATCHED_RECS');
   fnd_message.set_token('COUNT','');
   fnd_file.put_line(fnd_file.output,RPAD(fnd_message.get,50,'.') || TO_CHAR(g_matched_rec));
   log_debug_message('MATCHED RECS : ' || TO_CHAR(g_matched_rec));

   fnd_message.set_name('IGF','IGF_AP_UNMATCHED_RECS');
   fnd_message.set_token('COUNT','');
   fnd_file.put_line(fnd_file.output,RPAD(fnd_message.get,50,'.') || TO_CHAR(g_unmatched_rec));
   log_debug_message('UNMATCHED RECS : ' || TO_CHAR(g_unmatched_rec));


   fnd_message.set_name('IGF','IGF_AP_ISIR_REV');
   fnd_file.put_line(fnd_file.output,RPAD(fnd_message.get,47,' ')||'   ' || TO_CHAR(TO_NUMBER(g_review_count)));
   fnd_file.put_line(fnd_file.log, g_separator_line);
   fnd_file.put_line(fnd_file.log, g_separator_line);
   log_debug_message('REVIEW RECS : ' || TO_CHAR(g_review_count));

   fnd_message.set_name('IGF','IGF_AP_DUP_RECS');
   fnd_message.set_token('COUNT','');
   fnd_file.put_line(fnd_file.output,RPAD(fnd_message.get,50,'.') || TO_CHAR(g_dup_rec));
   log_debug_message('DUPLICATE RECS : ' || TO_CHAR(g_dup_rec));


   fnd_message.set_name('IGF','IGF_AP_BAD_RECS');
   fnd_message.set_token('COUNT','');
   fnd_file.put_line(fnd_file.output,RPAD(fnd_message.get,50,'.') || TO_CHAR(g_bad_rec));
   log_debug_message('BAD RECS : ' || TO_CHAR(g_bad_rec));

   fnd_message.set_name('IGF','IGF_AP_NEW_PER_RECS');
   fnd_message.set_token('COUNT','');
   fnd_file.put_line(fnd_file.output,RPAD(fnd_message.get,50,'.') || TO_CHAR(g_unmatched_added));
   log_debug_message('NEW PERSON RECS i.e. => unmatched and added : ' || TO_CHAR(g_unmatched_added));

END log_statistics;




PROCEDURE main ( errbuf            OUT NOCOPY VARCHAR2,
                 retcode           OUT NOCOPY NUMBER,
                 p_force_add       IN VARCHAR2,
                 p_create_inquiry  IN VARCHAR2,
                 p_adm_source_type IN VARCHAR2,
                 p_batch_year      IN VARCHAR2,
                 p_match_code      IN VARCHAR2,
                 p_del_int         IN VARCHAR2,
                 p_parent_req_id   IN VARCHAR2,             -- when called as sub request
                 p_sub_req_num     IN VARCHAR2,             -- when called as sub request
                 p_si_id           IN VARCHAR2,             -- when called for single si id
                 p_upd_ant_val     IN VARCHAR2              -- Newly added in FA152
               )
IS
  /*
  ||  Created By : rgangara
  ||  Created On : 03-AUG-2004
  ||  Purpose :        Does the matching process and updates isir interface, isir matched table, base record table etc.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||
  ||  tsailaja      13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
  ||  (reverse chronological order - newest change first)
  */

   lv_apm_id      igf_ap_person_match.apm_id%TYPE := NULL;

   CURSOR cur_batch_aw_map(cp_batch_yr NUMBER)  IS
   SELECT ci_cal_type,ci_sequence_number
     FROM igf_ap_batch_aw_map
    WHERE batch_year = cp_batch_yr;

   CURSOR cur_isir_intrface(cp_si_id NUMBER)  IS
   SELECT iia.*
     FROM igf_ap_isir_ints iia
    WHERE si_id = cp_si_id;

   -- cursor to get records to process current request (as sub request)
   CURSOR cur_sub_req_int(cp_parent_req_id NUMBER, cp_sub_req_num NUMBER)  IS
   SELECT iia.*
     FROM igf_ap_isir_ints iia
    WHERE parent_req_id = cp_parent_req_id
      AND sub_req_num   = cp_sub_req_num
    ORDER BY si_id;



BEGIN
   igf_aw_gen.set_org_id(NULL);
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.main.debug','Beginning Processing');
   END IF;

   g_gen_party_profile_val  := FND_PROFILE.VALUE('HZ_GENERATE_PARTY_NUMBER'); -- get the profile value and store in global variable

   -- print input parameters
   fnd_file.put_line(fnd_file.log, '-----------------------------------------------------------------------------------------');
   fnd_message.set_name('IGF', 'IGF_AP_CREATE_PRSN_NO_MATCH');
   fnd_message.set_token('CREATE_PRSN', p_force_add);
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   fnd_message.set_name('IGF', 'IGF_AP_CREATE_ADM_INQ');
   fnd_message.set_token('CREATE_INQ', p_create_inquiry);
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   fnd_message.set_name('IGF', 'IGF_AP_ADM_INQ_MTHD');
   fnd_message.set_token('INQ_METHOD', p_adm_source_type);
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   fnd_message.set_name('IGF', 'IGF_AP_BATCH_YEAR');
   fnd_message.set_token('BATCH_YR', p_batch_year);
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   fnd_message.set_name('IGF', 'IGF_AP_MATCH_CODE');
   fnd_message.set_token('MATCH_CODE', p_match_code);
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   fnd_message.set_name('IGF', 'IGF_AP_DEL_INT_RECORD');
   fnd_message.set_token('DEL_FLAG', p_del_int);
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   fnd_message.set_name('IGF', 'IGF_AP_PRNT_REQ_ID');
   fnd_message.set_token('PARENT_REQ_NO', p_parent_req_id);
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   fnd_message.set_name('IGF', 'IGF_AP_SUB_REQ_ID');
   fnd_message.set_token('SUB_REQ_NO', p_sub_req_num);
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   fnd_message.set_name('IGF', 'IGF_AP_UPD_ANT_DATA');
   fnd_message.set_token('UPD_ANT', p_upd_ant_val);
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   fnd_file.put_line(fnd_file.log, '-----------------------------------------------------------------------------------------');


   -- initialize/reset global variables.
   reset_global_variables;

   log_debug_message(' Starting main procedure... ' || TO_CHAR(SYSDATE, 'HH24:MI:SS'));

   -- Copying the parameter values to the gobal variable.
   g_force_add             := p_force_add;
   g_create_inquiry        := NVL(p_create_inquiry,'N');
   g_adm_source_type       := p_adm_source_type;
   g_count_corr            := 0;
   g_batch_year            := p_batch_year;
   g_match_code            := p_match_code;
   g_separator_line        := RPAD('*',50,'*');
   g_del_success_int_rec   := NVL(p_del_int, 'N');
   g_sub_req_num           := p_sub_req_num;
   g_enable_debug_logging  := 'N' ; -- 'N' by default disables logging debug messages.
   g_upd_ant_val           := p_upd_ant_val;

   -- Validate Match code parameter
   IF g_match_code IS NOT NULL THEN  -- validate only if it is not null
      OPEN cur_setup_score (g_match_code) ;
      FETCH cur_setup_score INTO g_setup_score;

      IF cur_setup_score%NOTFOUND THEN
           CLOSE cur_setup_score ;
           fnd_message.set_name('IGF','IGF_AP_SETUP_SCORE_NOT_FOUND');
           errbuf := fnd_message.get;
           fnd_file.put_line(fnd_file.log, errbuf);
           retcode := 1;
           RETURN;
      END IF;
      CLOSE cur_setup_score ;
   END IF;


   -- Batch Year validation
   OPEN  cur_batch_aw_map(p_batch_year) ;
   FETCH cur_batch_aw_map INTO g_ci_cal_type,g_ci_sequence_number ;

   IF cur_batch_aw_map%NOTFOUND        THEN
      CLOSE cur_batch_aw_map ;
      fnd_message.set_name('IGF','IGF_AP_BATCH_YEAR_NOT_FOUND');
      errbuf := fnd_message.get;
      fnd_file.put_line(fnd_file.log, errbuf);
      retcode := 1;
      RETURN;
   END IF ;
   CLOSE cur_batch_aw_map ;


   IF p_si_id IS NOT NULL THEN
      -- process for only one record with SI ID = p_si_id
      OPEN cur_isir_intrface (p_si_id);
      FETCH cur_isir_intrface INTO g_isir_intrface_rec;
      CLOSE cur_isir_intrface ;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.main.debug','Procedure invoked by passing SI ID ' || p_si_id);
      END IF;

      IF g_isir_intrface_rec.si_id IS NULL THEN
         fnd_message.set_name('IGF','IGF_AP_NO_INT_REC_FOUND');
         fnd_file.put_line(fnd_file.log, fnd_message.get);
         RETURN;
      END IF;

      log_debug_message(' SI_ID Passed...  ' || p_si_id);


      process_int_record; -- call the process for processing the Interface record.


   ELSE
      -- Loop and process for each record
      OPEN  cur_sub_req_int(p_parent_req_id, p_sub_req_num);
      FETCH cur_sub_req_int INTO g_isir_intrface_rec;

      WHILE cur_sub_req_int%FOUND LOOP
         log_debug_message('Processing Interface record. SI_ID = ' || g_isir_intrface_rec.si_id || '   at : ' || TO_CHAR(SYSDATE, 'HH24:MI:SS'));
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.main.debug','Processing Interface record. SI ID : ' || g_isir_intrface_rec.si_id);
         END IF;

         process_int_record; -- call the process for processing the Interface record.

         FETCH cur_sub_req_int INTO g_isir_intrface_rec;
      END LOOP;
   END IF;

   log_debug_message(' Completed processing....  SUCCESSFULLY ');

   -- call procedure for logging processed statistics.
   log_statistics;

   ram_log_dml_count;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.main.debug','Completed Main Processing at : ' || TO_CHAR(SYSDATE, 'HH24:MI:SS'));
   END IF;

   log_debug_message(' Ended main procedure... ' || TO_CHAR(SYSDATE, 'HH24:MI:SS'));
   RETURN;

EXCEPTION
   WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.main.exception','The exception is : ' || SQLERRM );
      END IF;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.main');
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      igs_ge_msg_stack.add;
      igs_ge_msg_stack.conc_exception_hndl;
END main;


FUNCTION format_SSN ( l_ssn VARCHAR2 )
RETURN VARCHAR2
IS
  /*
  ||  Created By : masehgal
  ||  Created On : 12-Jun-2002
  ||  Purpose :        Converts SSN into required format
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */


   CURSOR cur_format IS
   SELECT NVL(format_mask,'999999999')
     FROM igs_pe_person_id_typ
    WHERE s_person_id_type = 'SSN';

   l_formated_ssn  VARCHAR2(30);
   cur             NUMBER(15);

BEGIN

   IF gv_format        IS NULL        THEN

        OPEN  cur_format;
        FETCH cur_format INTO gv_format;
        IF cur_format%NOTFOUND THEN
           gv_format :=  '999999999';
        END IF;
        CLOSE cur_format;

   END IF;

   cur := 1;

   FOR i in 1 .. (LENGTH(gv_format))
   LOOP
       IF SUBSTR(gv_format,i,1)        = '9' THEN
         IF LENGTH(l_ssn) >= cur THEN
            l_formated_ssn := l_formated_ssn ||SUBSTR(l_ssn,cur,1);
            cur:=cur +1;
         END IF;

       ELSE
         l_formated_ssn:=l_formated_ssn||SUBSTR(gv_format,i,1);
       END IF;
   END LOOP ;
   RETURN l_formated_ssn;

EXCEPTION
  WHEN OTHERS THEN
   IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.format_SSN.exception','The exception is : ' || SQLERRM );
   END IF;

  fnd_message.set_name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
  igs_ge_msg_stack.add;
  fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
  RETURN NULL;

END format_SSN ;


FUNCTION convert_to_date( pv_org_date VARCHAR2)
RETURN DATE
IS
  /*
  ||  Created By : brajendr
  ||  Created On : 24-NOV-2000
  ||  Purpose :        Converts the valid dates to into the DATE format else return NULL.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */
    ld_date   DATE;
BEGIN

    ld_date := FND_DATE.CHARDATE_TO_DATE( pv_org_date);
    RETURN ld_date;

EXCEPTION
    WHEN others THEN
      RETURN NULL;

END convert_to_date;


FUNCTION remove_spl_chr(pv_ssn        igf_ap_isir_ints_all.current_ssn_txt%TYPE)
RETURN VARCHAR2
IS
  /*
  ||  Created By : rasingh
  ||  Created On : 19-Apr-2002
  ||  Purpose :        Strips the special charactes from SSN and returns just the number
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */

   ln_ssn VARCHAR2(20);

BEGIN
   ln_ssn := TRANSLATE (pv_ssn,'1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ`~!@#$%^&*_+=-,./?><():; ','1234567890');
   RETURN ln_ssn;
EXCEPTION
   WHEN        others THEN
   RETURN '-1';

END remove_spl_chr;



FUNCTION convert_to_number( pv_org_number VARCHAR2 )
RETURN NUMBER
IS
  /*
  ||  Created By : brajendr
  ||  Created On : 24-NOV-2000
  ||  Purpose :        Converts the valid number to into the NUMBER format else RETURN NULL.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */
    ld_number NUMBER;
BEGIN

    ld_number := TO_NUMBER( pv_org_number);
    RETURN ld_number;

EXCEPTION
    WHEN others THEN
         RETURN NULL;
END convert_to_number;


FUNCTION is_fa_base_record_present(pn_person_id             NUMBER,
                                   pn_batch_year            NUMBER,
                                   pn_base_id    OUT NOCOPY NUMBER)
RETURN BOOLEAN
IS
  /*
  ||  Created By : brajendr
  ||  Created On : 24-NOV-2000
  ||  Purpose :        To check whether the newly imported student has        any matched record present in the FA_BASE_REC table in th egiven award year.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||   rasahoo         19-09-2003      If FA Base record not found then
  ||                                   the procedure will return false.
  ||  (reverse chronological order - newest change first)
  */

    -- Get all the records from        base table which are having same person        id and the given batch year
    CURSOR cur_fa_base_record (pn_person_id NUMBER, ln_batch_year NUMBER) IS
    SELECT ifb.*
      FROM igf_ap_fa_base_rec        ifb,
           igf_ap_batch_aw_map ibm
     WHERE ifb.person_id = pn_person_id
       AND ibm.ci_sequence_number = ifb.ci_sequence_number
       AND ibm.ci_cal_type = ifb.ci_cal_type
       AND ibm.batch_year = ln_batch_year;

BEGIN

    -- If  a base record is found for the given student
    -- then return 'TRUE' else        return 'FALSE'

    OPEN cur_fa_base_record( pn_person_id,pn_batch_year);
    FETCH cur_fa_base_record INTO g_fa_base_rec ;

    IF cur_fa_base_record%FOUND THEN
       pn_base_id := g_fa_base_rec.base_id;
       CLOSE cur_fa_base_record;
       RETURN TRUE;

    ELSE
       pn_base_id := NULL;
       CLOSE cur_fa_base_record;
       RETURN FALSE;
    END IF;

EXCEPTION
    WHEN others THEN
       IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.is_fa_base_record_present.exception','The exception is : ' || SQLERRM );
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.is_fa_base_record_present');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      igs_ge_msg_stack.add;
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      RETURN FALSE;
END is_fa_base_record_present;


FUNCTION convert_negative_char(pv_charnum VARCHAR2)
RETURN NUMBER
IS
  /*
  ||  Created By : brajendr
  ||  Created On : 24-NOV-2000
  ||  Purpose :        Process        which converts the Alphaneumeric signed        number to equavalent numeric signed number.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */
    ln_Amount         NUMBER;
    lv_Signed_Char    VARCHAR2(1);
    lv_Number         VARCHAR2(10);
    lv_Signed_Value   VARCHAR2(1);

BEGIN

    -- Select the last character which is used to denote a signed number
    IF pv_charnum IS NULL THEN
         RETURN NULL;
    END IF;

    lv_signed_char := SUBSTR( pv_charnum, LENGTH( pv_charnum), 1);

    IF lv_signed_char NOT IN ( '{','}','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R')        THEN
         RETURN NULL ;
    END IF;

    -- Select the number part from the amount field
    lv_number := SUBSTR( pv_charnum, 1,LENGTH( pv_charnum)-1);

    -- Get the value of        the signed character
    -- The mapping is '{' => +0,  'A' =>+1 to 'I' => +9        and '}'        => -0 ,        'J'=> -1 so on to 'R' => -9
    IF lv_signed_char IN ('{','}') THEN
       lv_signed_value := '0';

    ELSIF  lv_signed_char IN ('A','J') THEN
       lv_signed_value := '1';

    ELSIF lv_signed_char IN ('B','K') THEN
       lv_signed_value := '2';

    ELSIF lv_signed_char IN ('C','L') THEN
       lv_signed_value := '3';

    ELSIF lv_signed_char IN ('D','M') THEN
       lv_signed_value := '4';

    ELSIF  lv_signed_char IN ('E','N') THEN
       lv_signed_value := '5';

    ELSIF lv_signed_char IN ('F','O') THEN
       lv_signed_value := '6';

    ELSIF lv_signed_char IN ('G','P') THEN
       lv_signed_value := '7';

    ELSIF lv_signed_char IN ('H','Q') THEN
       lv_signed_value := '8';

    ELSIF lv_signed_char IN ('I','R') THEN
       lv_signed_value := '9';

    END IF;

    -- Get the amount by concatanating number and signed value
    ln_Amount := TO_NUMBER( lv_number||lv_signed_value);

    -- add the signed value
    IF lv_signed_char IN ( '}','J','K','L','M','N','O','P','Q','R') THEN
          ln_Amount := ln_Amount*(-1);
    END IF;

    RETURN ln_Amount;

EXCEPTION

    WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.convert_negative_char.exception','The exception is : ' || SQLERRM );
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.convert_negative_char');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      igs_ge_msg_stack.add;
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      app_exception.raise_exception;

END convert_negative_char;



PROCEDURE load_matched_isir(pv_ssn                  VARCHAR2,
                            pv_last_name            VARCHAR2,
                            pd_date_of_birth        DATE,
                            pn_ci_sequence_number   NUMBER,
                            pv_ci_cal_type          VARCHAR2,
                            pn_base_id              igf_ap_isir_matched.base_id%TYPE)
IS
  /*
  ||  Created By : brajendr
  ||  Created On : 24-NOV-2000
  ||  Purpose :        Process        creates        isir_matched records for all the unmatched records and having the valid        data.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR   cur_isir_intrface( pn_ssn NUMBER, pv_last_name VARCHAR2, pd_date_of_birth DATE, pn_ci_sequence_number NUMBER, pv_ci_cal_type        VARCHAR2) IS
    SELECT   iii.si_id,
             iii.last_name,
             iii.birth_date,
             iii.batch_year_num,
             iii.record_status
      FROM   igf_ap_isir_ints iii,
             igf_ap_batch_aw_map ibm
     WHERE   original_ssn_txt       = pn_ssn
       AND   iii.last_name          = pv_last_name
       AND   iii.birth_date         = pd_date_of_birth
       AND   ibm.ci_sequence_number = pn_ci_sequence_number
       AND   ibm.ci_cal_type        = pv_ci_cal_type
       AND   iii.batch_year_num     = ibm.batch_year
       AND   (iii.record_status     = 'UNMATCHED' OR iii.record_status = 'NEW');

    ln_isir_id        igf_ap_isir_matched.isir_id%TYPE;

BEGIN

    --Get all the unmatched records which are valid for        this batch year        and creates a new matched record for it.
    FOR cur_isir_intrface_rec IN cur_isir_intrface( pv_ssn, pv_last_name, pd_date_of_birth, pn_ci_sequence_number, pv_ci_cal_type)
    LOOP

      create_isir_matched( cur_isir_intrface_rec.si_id, ln_isir_id, pn_base_id);

      create_nslds_data( cur_isir_intrface_rec.si_id, ln_isir_id, pn_base_id);

      update_isir_intrface( cur_isir_intrface_rec.si_id, 'MATCHED');

      fnd_message.set_name('IGF','IGF_AP_ISIR_REC_STATUS');
      fnd_message.set_token('STATUS','MATCHED');
      fnd_file.put_line(fnd_file.log, fnd_message.get);
    END LOOP;

EXCEPTION
    WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.load_matched_isir.exception','The exception is : ' || SQLERRM );
      END IF;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.load_isir_matched');
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
END load_matched_isir;



PROCEDURE create_isir_matched(pn_si_id    IN          NUMBER,
                              pn_isir_id  OUT  NOCOPY NUMBER,
                              pn_base_id  IN          NUMBER)
IS
  /*
  ||  Created By : brajendr
  ||  Created On : 24-NOV-2000
  ||  Purpose :        To create the isir matched record once the person satisfies the        matching process.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  masehgal              15-feb-2002     #        2216956           FACR007
  ||                                      Addded Verif_track_flag
  ||  (reverse chronological order - newest change first)
  */
      CURSOR cur_isir_intrface ( pn_si_id NUMBER)
      IS
      SELECT iii.*
        FROM igf_ap_isir_ints iii
       WHERE iii.si_id = pn_si_id;

    lv_rowid  VARCHAR2(30);

BEGIN

   -- INsert Record in        IGF_AP_ISIR_Matched table
   FOR cur_isir_intrface_rec IN cur_isir_intrface ( pn_si_id)
   LOOP

      lv_rowid := NULL;
      -- call procedure to insert isir matched record.
      insert_isir_matched_rec(cp_isir_int_rec     => cur_isir_intrface_rec,
                                  p_payment_isir  => 'N',
                                  p_active_isir   => 'N',
                                  p_base_id       => pn_base_id,
                                  p_out_isir_id   => pn_isir_id -- OUT parameter returns isir id
                                  ) ;

   END LOOP;

EXCEPTION

   WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.create_isir_matched.exception','The exception is : ' || SQLERRM );
      END IF;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.create_isir_matched');
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

END create_isir_matched;



PROCEDURE update_isir_intrface(pn_si_id         NUMBER,
                               pv_record_status VARCHAR2)
IS
  /*
  ||  Created By : brajendr
  ||  Created On : 24-NOV-2000
  ||  Purpose :        Update the record status to 'Matched / Unmatched' for all the successful/ non successfull persons.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  masehgal              15-feb-2002     #        2216956           FACR007
  ||                                      Addded Verif_track_flag
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_isir_intrface ( pn_si_id        NUMBER)        IS
      SELECT rowid row_id, iii.si_id
      FROM   igf_ap_isir_ints_all iii
      WHERE  si_id = pn_si_id FOR UPDATE NOWAIT ;

    lv_rowid  VARCHAR2(30);
    retcode   NUMBER;
    errbuf    VARCHAR2(300);

BEGIN

    -- Update record _status
    FOR cur_isir_intrface_rec IN cur_isir_intrface ( pn_si_id)
    LOOP

      UPDATE igf_ap_isir_ints_all
      SET    record_status    =  pv_record_status
      WHERE  si_id            =  cur_isir_intrface_rec.si_id;

    END LOOP;

    fnd_message.set_name('IGF','IGF_AP_ISIR_REC_STATUS');
    fnd_message.set_token('STATUS', pv_record_status);
    fnd_file.put_line(fnd_file.log, fnd_message.get);

EXCEPTION
    WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.update_isir_intrface.exception','The exception is : ' || SQLERRM );
      END IF;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_MATCHING_PROCESS_PKG.UPDATE_ISIR_INTRFACE');
      fnd_file.put_line(fnd_file.log,fnd_message.get || ' - '|| SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
END update_isir_intrface;



PROCEDURE create_nslds_data( pn_si_id    NUMBER,
                             pn_isir_id  NUMBER,
                             pn_base_id  NUMBER )
IS
  /*
  ||  Created By : brajendr
  ||  Created On : 24-NOV-2000
  ||  Purpose :        To create the NSLDS matched record for all the matched records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  rgangara        06-AUG-04   modified to user transaction No. field for querying the
                                  NSLDS data table since as per FA 138 ISIR enh, 3416895,
                                  there would as many nslds data recs as the no. of transactions for an isir.
  ||  (reverse chronological order - newest change first)
  */
    -- Get all the NSLDS data for the matched isir record.
   CURSOR cur_isir_intrface (cp_si_id  NUMBER) IS
   SELECT iii.*
     FROM igf_ap_isir_ints iii
    WHERE si_id = pn_si_id;

   CURSOR cur_nslds_data (cp_base_id NUMBER ,
                          cp_trans_num igf_ap_nslds_data_all.transaction_num_txt%TYPE) IS
   SELECT nslds.rowid row_id,
          nslds.nslds_id
     FROM igf_ap_nslds_data nslds
    WHERE base_id             = cp_base_id
      AND transaction_num_txt = cp_trans_num
    FOR UPDATE NOWAIT ;

   lv_rowid  VARCHAR2(30);
   ln_nslds_id        igf_ap_nslds_data.nslds_id%TYPE;

BEGIN

   -- Update NSLDS data for the given student
   FOR cur_isir_intrface_rec IN cur_isir_intrface ( pn_si_id)
   LOOP

      lv_rowid := NULL;
      ln_nslds_id := NULL;

      -- check whether NSLDS data rec already exists for this base id and transaction num
      OPEN cur_nslds_data (pn_base_id, cur_isir_intrface_rec.transaction_num_txt);
      FETCH cur_nslds_data INTO lv_rowid, ln_nslds_id;
      CLOSE cur_nslds_data ;

      IF lv_rowid IS NULL THEN
         -- call proc to insert a new NSLDS data rec
         insert_nslds_data_rec(cp_isir_intrface_rec  => cur_isir_intrface_rec,
                                p_isir_id             => pn_isir_id,
                                p_base_id             => pn_base_id,
                                p_out_nslds_id        => ln_nslds_id);

      END IF;
   END LOOP;

EXCEPTION
   WHEN others THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.create_nslds_data.exception','The exception is : ' || SQLERRM );
      END IF;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_ap_matching_process_pkg.create_nslds_data');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      igs_ge_msg_stack.add;
END create_nslds_data;



FUNCTION  check_ptyp_code(p_person_id  igf_ap_person_v.person_id%TYPE)
RETURN BOOLEAN IS
       /*
  ||  Created By : prchandr
  ||  Created On : 16-JAN-2001
  ||  Purpose :        Does the checking whether the person type code is with prospect,
        ||              applicant        and student else create        its inquiry record and instance        record.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */

   CURSOR cur_ptyp_code IS
    SELECT COUNT(*)
      FROM igs_pe_typ_instances_all pti,
           igs_pe_person_types pt
     WHERE pti.person_id        = p_person_id
       AND pti.person_type_code = pt.person_type_code
       AND SYSDATE BETWEEN pti.start_date and NVL(pti.end_date,SYSDATE)
       AND pt.system_type IN ('PROSPECT','APPLICANT','STUDENT')
       AND NVL(pt.closed_ind,'N') = 'N' ;

   l_count        NUMBER DEFAULT 0;

BEGIN
   OPEN cur_ptyp_code;
   FETCH cur_ptyp_code INTO l_count;
   CLOSE cur_ptyp_code;

   IF l_count=0 THEN
         RETURN FALSE;
   ELSE
         RETURN TRUE;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.check_ptyp_code.exception','The exception is : ' || SQLERRM );
     END IF;

    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igf_ap_matching_process.check_ptyp_code');
    igs_ge_msg_stack.add;

END check_ptyp_code;

PROCEDURE wrpr_refresh_matches(p_si_id          IN igf_ap_isir_ints_all.si_id%TYPE,
                               p_match_code     IN igf_ap_record_match_all.match_code%TYPE,
                               p_return_status OUT NOCOPY VARCHAR2,
                               p_message_out   OUT NOCOPY VARCHAR2)
IS
       /*
  ||  Created By : rgangara
  ||  Created On : 06-SEP-2004
  ||  Purpose :    Provides Outside Interface (Wrapper procedure) for invoking the Perform_record_matching procedure
  ||               which performs person match and populates data into match details table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */

   CURSOR cur_isir_intrface(cp_si_id NUMBER)  IS
   SELECT iia.*
     FROM igf_ap_isir_ints iia
    WHERE si_id = cp_si_id;

  CURSOR cur_award_year_dtl(cp_batch_year igf_ap_isir_ints.batch_year_num%TYPE) IS
  SELECT ci_sequence_number,ci_cal_type
  FROM   igf_ap_batch_aw_map
  WHERE  batch_year = cp_batch_year;

  award_year_dtl_rec cur_award_year_dtl%ROWTYPE;

   CURSOR get_prsn_match_cur (cp_si_id IN NUMBER) IS
   SELECT *
     FROM igf_ap_person_match
    WHERE si_id = cp_si_id;

   person_match_rec get_prsn_match_cur%ROWTYPE;

   -- for deleting recs
   CURSOR get_match_details_cur (cp_apm_id IN NUMBER) IS
   SELECT md.rowid row_id
     FROM igf_ap_match_details md
    WHERE apm_id = cp_apm_id;
   lv_rowid          VARCHAR2(30);
   ln_apm_id         igf_ap_match_details.apm_id%TYPE;
BEGIN
  g_enable_debug_logging := 'N';
   -- get Int rec details
   OPEN cur_isir_intrface (p_si_id);
   FETCH cur_isir_intrface INTO g_isir_intrface_rec;
   CLOSE cur_isir_intrface ;

   IF g_isir_intrface_rec.si_id IS NULL THEN
      fnd_message.set_name('IGF','IGF_AP_NO_INT_REC_FOUND');
      p_message_out := fnd_message.get;
      p_return_status := 'E'; -- indicate Failure
      RETURN;
   END IF;


   -- Validate Match code parameter
   OPEN cur_setup_score (p_match_code) ;
   FETCH cur_setup_score INTO g_setup_score;

   IF cur_setup_score%NOTFOUND THEN
        CLOSE cur_setup_score ;
        fnd_message.set_name('IGF','IGF_AP_SETUP_SCORE_NOT_FOUND');
        p_return_status := 'E';
        p_message_out   := fnd_message.get;
        RETURN;
   END IF;
   CLOSE cur_setup_score ;

   OPEN  get_prsn_match_cur (p_si_id);
   FETCH get_prsn_match_cur INTO person_match_rec;

   IF get_prsn_match_cur%NOTFOUND THEN
           CLOSE get_prsn_match_cur ;

     OPEN cur_award_year_dtl(g_isir_intrface_rec.batch_year_num);
     FETCH cur_award_year_dtl INTO award_year_dtl_rec;
     CLOSE cur_award_year_dtl;

     g_batch_year         := g_isir_intrface_rec.batch_year_num;
     g_match_code         := p_match_code;
     g_ci_cal_type        := award_year_dtl_rec.ci_cal_type;
     g_ci_sequence_number := award_year_dtl_rec.ci_sequence_number;
     g_del_success_int_rec:= 'N';

           ln_apm_id := NULL;
     lv_rowid  := NULL;
     log_debug_message('Inserting a record intp person match table');
           igf_ap_person_match_pkg.insert_row(
                       x_rowid                 => lv_rowid ,
                       x_apm_id                => ln_apm_id,
                       x_css_id                => NULL,
                       x_si_id                 => g_isir_intrface_rec.si_id ,
                       x_record_type           => 'ISIR' ,
                       x_date_run              => TRUNC(SYSDATE),
                       x_ci_sequence_number    => g_ci_sequence_number ,
                       x_ci_cal_type           => g_ci_cal_type ,
                       x_record_status         => g_isir_intrface_rec.record_status ,
                       x_mode                  => 'R');

   ELSE

     CLOSE get_prsn_match_cur ;
     -- populate global variables.
     g_batch_year         := g_isir_intrface_rec.batch_year_num;
     g_match_code         := p_match_code;
     g_ci_cal_type        := person_match_rec.ci_cal_type;
     g_ci_sequence_number := person_match_rec.ci_sequence_number;
     g_del_success_int_rec:= 'N';

     -- delete existing match details record for the apm_id
     FOR match_details_rec IN get_match_details_cur (person_match_rec.apm_id)
     LOOP
        igf_ap_match_details_pkg.delete_row(match_details_rec.row_id);
     END LOOP;

     ln_apm_id := person_match_rec.apm_id;

   END IF;
   -- call proc to match records and populate match details table.
   -- This proc would match records based on attributes and populates the matching recs into match details table.
   log_debug_message('performing record match');
   perform_record_matching(p_apm_id  => ln_apm_id);
   log_debug_message('Record match Performed');

   -- update the match code in INT table to the new one as
   log_debug_message(' Updating interface record status:'|| g_match_code);
   update_isir_int_record (p_si_id             => p_si_id,
                           p_isir_rec_status   => g_isir_intrface_rec.record_status, -- retain existing status
                           p_match_code        => g_match_code -- new match code to be updated
                          );
    log_debug_message(' Interface record status Updated');
   p_return_status := 'S'; -- indicate success
EXCEPTION
   WHEN OTHERS THEN
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.wrpr_refresh_matches.exception','The exception is : ' || SQLERRM );
     END IF;

    p_return_status := 'E'; -- indicate error
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igf_ap_matching_process.wrpr_refresh_matches');
    p_message_out := fnd_message.get || '. Exception is : ' || SQLERRM;
END wrpr_refresh_matches;

-- Added p_award_yr as a part of Bug Fix 4241350
PROCEDURE wrpr_auto_fa_rec(p_si_id          IN igf_ap_isir_ints_all.si_id%TYPE,
                           p_person_id      IN igf_ap_match_details.person_id%TYPE,
         p_batch_year       IN igf_ap_isir_matched.batch_year%TYPE,
                           p_return_status OUT NOCOPY VARCHAR2,
                           p_message_out   OUT NOCOPY VARCHAR2)
IS
       /*
  ||  Created By : rgangara
  ||  Created On : 06-SEP-2004
  ||  Purpose :    Provides Outside Interface (Wrapper procedure) for invoking the Perform_record_matching procedure
  ||               which performs person match and populates data into match details table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  ridas            14-Feb-2006       Bug #5021084. Removed trunc function from cursor C_SSN.
  ||  (reverse chronological order - newest change first)
  */

   CURSOR cur_isir_intrface(cp_si_id NUMBER)  IS
   SELECT iia.*
     FROM igf_ap_isir_ints iia
    WHERE si_id = cp_si_id;

   CURSOR get_person_match_cur (cp_si_id IN NUMBER) IS
   SELECT apm_id,
          ci_cal_type,
          ci_sequence_number
     FROM igf_ap_person_match
    WHERE si_id = cp_si_id;

-- Added cp_batch_year as a part of Bug Fix 4241350
   CURSOR cur_base_id_rec(cp_person_id NUMBER, cp_batch_year NUMBER)  IS
   SELECT base_id
     FROM igf_ap_fa_base_rec br, igf_ap_batch_aw_map am
    WHERE person_id = cp_person_id
      AND br.ci_cal_type = am.ci_cal_type
      AND br.ci_sequence_number = am.ci_sequence_number
      AND am.batch_year = cp_batch_year;

   CURSOR cur_isir_matched(cp_base_id NUMBER, cp_transaction_num VARCHAR2) IS
   SELECT 'Y'
     FROM igf_ap_isir_matched
    WHERE base_id = cp_base_id
      AND transaction_num = cp_transaction_num;

    lv_profile_value   VARCHAR2(10);
    CURSOR c_ssn(
                 cp_person_id NUMBER
                ) IS
      SELECT api_person_id,
             api_person_id_uf,
             end_dt
        FROM igs_pe_alt_pers_id
       WHERE pe_person_id = cp_person_id
         AND person_id_type LIKE 'SSN'
         AND SYSDATE BETWEEN start_dt AND NVL(end_dt,SYSDATE);
    l_ssn c_ssn%ROWTYPE;

   person_match_rec  get_person_match_cur%ROWTYPE;
   ln_apm_id         NUMBER;
   l_trans_exists    VARCHAR2(1);
   l_base_id         igf_ap_fa_base_rec_all.base_id%TYPE;

BEGIN
   -- Get the Interface record details
   OPEN  cur_isir_intrface (p_si_id);
   FETCH cur_isir_intrface INTO g_isir_intrface_rec;
   CLOSE cur_isir_intrface ;

   IF g_isir_intrface_rec.si_id IS NULL THEN
      fnd_message.set_name('IGF','IGF_AP_NO_INT_REC_FOUND');
      p_message_out := fnd_message.get;
      p_return_status := 'E'; -- indicate Failure
      RETURN;
   END IF;


   fnd_profile.get('IGF_AP_SSN_REQ_FOR_BASE_REC',lv_profile_value);
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.wrpr_auto_fa_rec.debug','lv_profile_value:'||NVL(lv_profile_value,'N'));
   END IF;
   IF NVL(lv_profile_value,'N') = 'Y' THEN
     OPEN c_ssn(p_person_id);
     FETCH c_ssn INTO l_ssn;
     IF c_ssn%NOTFOUND THEN
       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.wrpr_auto_fa_rec.debug','c_ssn%NOTFOUND. raising error');
       END IF;
       CLOSE c_ssn;
       p_return_status := 'E';
       fnd_message.set_name('IGF','IGF_AP_SSN_FOR_BASEREC');
       p_message_out := fnd_message.get;
       RETURN;
     ELSE
       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.wrpr_auto_fa_rec.debug','c_ssn%FOUND.');
       END IF;
       CLOSE c_ssn;
     END IF;
   END IF;

   -- get person match rec details for the person
   OPEN  get_person_match_cur(p_si_id);
   FETCH get_person_match_cur INTO person_match_rec;
   CLOSE get_person_match_cur ;

   -- check whether a FA Base Rec already exists for the person Id
   -- Added p_batch_yr as a part of Bug Fix 4241350
   OPEN  cur_base_id_rec(p_person_id, p_batch_year);
   FETCH cur_base_id_rec INTO l_base_id;
   CLOSE cur_base_id_rec;

   IF l_base_id IS NOT NULL THEN
      -- i.e. person already has a base rec
      -- Check whether an ISIR matched rec already exists for this person with the current transaction num
      -- IF yes, then report error else proceed to create a record.

      OPEN  cur_isir_matched(l_base_id, g_isir_intrface_rec.transaction_num_txt);
      FETCH cur_isir_matched INTO l_trans_exists;
      CLOSE cur_isir_matched ;

      IF l_trans_exists = 'Y' THEN
         --i.e. The Person Base ID and the current trans rec already exists. Hence report error and return
         fnd_message.set_name('IGF','IGF_AP_TRAN_NUM_EXISTS');
         fnd_message.set_token('TRAN_NUM',g_isir_intrface_rec.transaction_num_txt);
         p_message_out := fnd_message.get;
         p_return_status := 'E'; -- indicate Failure
         RETURN;
      END IF; -- l_trans_exists

   END IF; -- l_base_id

   -- populate global variables.
   g_person_id           := p_person_id;
   g_batch_year          := g_isir_intrface_rec.batch_year_num;
   g_match_code          := g_isir_intrface_rec.match_code;
   g_ci_cal_type         := person_match_rec.ci_cal_type;
   g_ci_sequence_number  := person_match_rec.ci_sequence_number;
   g_del_success_int_rec := 'N';


   -- person is deemed as matched.
   auto_fa_rec(p_person_id  =>  p_person_id,
               p_apm_id     =>  ln_apm_id ,
               p_cal_type   =>  g_ci_cal_type,
               p_seq_num    =>  g_ci_sequence_number
              );

      fnd_message.set_name('IGF','IGF_AP_SUCCESS_FA_BASE');
      p_message_out := fnd_message.get;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_matching_process_pkg.wrpr_auto_fa_rec.statement','ISIR Imported successfully for the specified person');
      END IF;

      p_return_status := 'S'; -- return success
EXCEPTION
   WHEN OTHERS THEN
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.wrpr_auto_fa_rec.exception','Exception encountered and hence process could not complete successfully');
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.wrpr_auto_fa_rec.exception','The exception is : ' || SQLERRM );
     END IF;

    p_return_status := 'E'; -- return error
    fnd_message.set_name('IGF','IGF_AP_FAIL_FA_BASE');
    p_message_out := fnd_message.get;

    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igf_ap_matching_process.wrpr_refresh_matches');
    p_message_out := p_message_out || '.  ' || fnd_message.get || ' Exception is : ' || SQLERRM;
END wrpr_auto_fa_rec;


PROCEDURE wrpr_unmatched_rec(p_si_id          IN igf_ap_isir_ints_all.si_id%TYPE,
                             p_return_status OUT NOCOPY VARCHAR2,
                             p_message_out   OUT NOCOPY VARCHAR2)
IS
  /*
  ||  Created By : rgangara
  ||  Created On : 06-SEP-2004
  ||  Purpose :    Provides Outside Interface (Wrapper procedure) for invoking the unmatched_rec procedure.
  ||               Creates person record and other data and imports the ISIR record.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who              When              What
  ||  (reverse chronological order - newest change first)
  */

   CURSOR cur_isir_intrface(cp_si_id NUMBER)  IS
   SELECT iia.*
     FROM igf_ap_isir_ints iia
    WHERE si_id = cp_si_id;


   CURSOR get_person_match_cur (cp_si_id IN NUMBER) IS
   SELECT *
     FROM igf_ap_person_match
    WHERE si_id = cp_si_id;

   person_match_rec get_person_match_cur%ROWTYPE;

BEGIN
   -- Get the Interface record details
   OPEN  cur_isir_intrface (p_si_id);
   FETCH cur_isir_intrface INTO g_isir_intrface_rec;
   CLOSE cur_isir_intrface ;

   IF g_isir_intrface_rec.si_id IS NULL THEN
      fnd_message.set_name('IGF','IGF_AP_NO_INT_REC_FOUND');
      p_message_out := fnd_message.get;
      p_return_status := 'E'; -- indicate Failure
      RETURN;
   END IF;

   -- validate person id
   OPEN  get_person_match_cur(p_si_id);
   FETCH get_person_match_cur INTO person_match_rec;
   CLOSE get_person_match_cur ;

   -- populate global variables.
   g_person_id           := NULL;
   g_batch_year          := g_isir_intrface_rec.batch_year_num;
   g_match_code          := g_isir_intrface_rec.match_code;
   g_ci_cal_type         := person_match_rec.ci_cal_type;
   g_ci_sequence_number  := person_match_rec.ci_sequence_number;
   g_del_success_int_rec := 'N';

   -- Check if HZ gen party profile is set to YES as a new person is to be created. If set to No. return with error message
   IF FND_PROFILE.VALUE('HZ_GENERATE_PARTY_NUMBER') = 'N' THEN
      p_return_status := 'E'; -- indicate error

      fnd_message.set_name('IGF','IGF_AP_HZ_GEN_PARTY_NUMBER');
      p_message_out := fnd_message.get;
      RETURN;
   END IF;

   -- call procedure to create person and import ISIR.
   unmatched_rec(p_apm_id       => person_match_rec.apm_id,
                 p_called_from  => 'FORM',
                 p_msg_out      => p_message_out);


   fnd_message.set_name('IGF','IGF_AP_SUCCESS_CREATE_PERSON');
   p_message_out := fnd_message.get;

   p_return_status := 'S'; -- indicate success

EXCEPTION
   WHEN OTHERS THEN
     IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_matching_process_pkg.wrpr_unmatched_rec.exception','The exception is : ' || SQLERRM );
     END IF;

    p_return_status := 'E'; -- indicate error
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igf_ap_matching_process.wrpr_unmatched_rec');
    p_message_out := fnd_message.get || '. Exception is : ' || SQLERRM;
END wrpr_unmatched_rec;

END igf_ap_matching_process_pkg;

/
