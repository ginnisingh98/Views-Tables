--------------------------------------------------------
--  DDL for Package Body IGF_AP_LG_VER_IMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_LG_VER_IMP" AS
/* $Header: IGFAP38B.pls 120.2 2006/01/17 02:37:07 tsailaja noship $ */


g_log_tab_index   NUMBER := 0;

TYPE log_record IS RECORD ( person_number VARCHAR2(30),
                            message_text VARCHAR2(500));

-- The PL/SQL table for storing the log messages
TYPE LogTab IS TABLE OF log_record index by binary_integer;

g_log_tab LogTab;


  -- global cursor for fa base rec
  CURSOR c_fabase ( p_person_number   hz_parties.party_number%TYPE ) IS
     SELECT fabase.*
       FROM igf_ap_fa_base_rec  fabase,
            hz_parties          hz
      WHERE hz.party_id               = fabase.person_id
        AND hz.party_number           = p_person_number
        AND fabase.ci_cal_type        = g_ci_cal_type
        AND fabase.ci_sequence_number = g_ci_sequence_number ;
  g_fabase    c_fabase%ROWTYPE ;


PROCEDURE log_input_params( p_batch_num         IN  igf_aw_li_coa_ints.batch_num%TYPE ,
                            p_alternate_code    IN  igs_ca_inst.alternate_code%TYPE   ,
                            p_delete_flag       IN  VARCHAR2 )  IS
/*
||  Created By : masehgal
||  Created On : 28-May-2003
||  Purpose    : Logs all the Input Parameters
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
*/

  -- cursor to get batch desc for the batch id from igf_ap_li_bat_ints
  CURSOR c_batch_desc(cp_batch_num     igf_aw_li_coa_ints.batch_num%TYPE ) IS
     SELECT batch_desc, batch_type
       FROM igf_ap_li_bat_ints
      WHERE batch_num = cp_batch_num ;

  l_lkup_type            VARCHAR2(60) ;
  l_lkup_code            VARCHAR2(60) ;
  l_batch_desc           igf_ap_li_bat_ints.batch_desc%TYPE ;
  l_batch_type           igf_ap_li_bat_ints.batch_type%TYPE ;
  l_batch_id             igf_ap_li_bat_ints.batch_type%TYPE ;
  l_yes_no               igf_lookups_view.meaning%TYPE ;
  l_award_year_pmpt      igf_lookups_view.meaning%TYPE ;
  l_params_pass_prmpt    igf_lookups_view.meaning%TYPE ;
  l_person_number_prmpt  igf_lookups_view.meaning%TYPE ;
  l_batch_num_prmpt      igf_lookups_view.meaning%TYPE ;
  l_error                igf_lookups_view.meaning%TYPE ;

  BEGIN -- begin log parameters

     -- get the batch description
     OPEN  c_batch_desc( p_batch_num) ;
     FETCH c_batch_desc INTO l_batch_desc, l_batch_type ;
     CLOSE c_batch_desc ;

    l_error               := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','ERROR');
    l_person_number_prmpt := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','PERSON_NUMBER');
    l_batch_num_prmpt     := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','BATCH_ID');
    l_award_year_pmpt     := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','AWARD_YEAR');
    l_yes_no              := igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_delete_flag);
    l_params_pass_prmpt   := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PARAMETER_PASS');

    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE( FND_FILE.LOG, '-------------------------------------------------------------');
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');

    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ') ;
    FND_FILE.PUT_LINE( FND_FILE.LOG, l_params_pass_prmpt) ; --Parameters Passed
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ') ;

    FND_FILE.PUT_LINE( FND_FILE.LOG, RPAD( l_award_year_pmpt, 40)    || ' : '|| p_alternate_code ) ;

    FND_FILE.PUT_LINE( FND_FILE.LOG, RPAD( l_batch_num_prmpt, 40)     || ' : '|| TO_CHAR(p_batch_num) || '-' || l_batch_desc ) ;

    FND_FILE.PUT_LINE( FND_FILE.LOG, RPAD( FND_MESSAGE.GET_STRING('IGS','IGS_GE_ASK_DEL_REC'), 40)   || ' : '|| l_yes_no ) ;
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE( FND_FILE.LOG, '-------------------------------------------------------------');
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');

  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_lg_ver_imp.log_input_params.exception','Unhandled Exception :'||SQLERRM);
      END IF;
  END log_input_params ;


  PROCEDURE print_log_process( p_person_number IN  VARCHAR2,
                               p_error         IN  VARCHAR2 ) IS
    /*
    ||  Created By : masehgal
    ||  Created On : 01-Jun-2003
    ||  Purpose : This process gets the records from the pl/sql table and print in the log file
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

  l_count NUMBER(5) := g_log_tab.COUNT;
  l_old_person VARCHAR2(30) := '*******';

  BEGIN

    FOR i IN 1..l_count LOOP
      IF l_old_person <> g_log_tab(i).person_number THEN
        fnd_file.put_line(fnd_file.log,'-----------------------------------------------------------------------------');
        fnd_file.put_line(fnd_file.log,p_person_number || ' : ' || g_log_tab(i).person_number);
      END IF;
      fnd_file.put_line(fnd_file.log,g_log_tab(i).message_text);
      l_old_person := g_log_tab(i).person_number;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_lg_ver_imp.print_log_process.exception','Unhandled Exception :'||SQLERRM);
      END IF;

  END print_log_process;


  PROCEDURE check_dup_ver ( p_sar_num    IN           igf_ap_inst_ver_item_all.isir_map_col%TYPE,
                            p_base_id    IN           igf_ap_fa_base_rec_all.base_id%TYPE,
                            p_dup_ver    OUT  NOCOPY  BOOLEAN )  IS
  /*
  ||  Created By : masehgal
  ||  Created On : 28-May-2003
  ||  Purpose    : check duplication of Ver Item
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

   CURSOR chk_dup ( cp_base_id     igf_ap_isir_matched.base_id%TYPE,
                    cp_sar_num     igf_ap_inst_ver_item_all.isir_map_col%TYPE ) IS
      SELECT 1
        FROM igf_ap_inst_ver_item_all
       WHERE base_id      = cp_base_id
         AND isir_map_col = cp_sar_num ;
   l_count    NUMBER ;

  BEGIN
     OPEN  chk_dup ( p_base_id, p_sar_num) ;
     FETCH chk_dup INTO l_count ;
     IF chk_dup%NOTFOUND THEN
        p_dup_ver := FALSE ;
     ELSE
        p_dup_ver := TRUE ;
     END IF ;
     CLOSE chk_dup ;

  EXCEPTION
     WHEN OTHERS THEN
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_lg_ver_imp.check_dup_ver.exception','Unhandled Exception :'||SQLERRM);
        END IF;
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AP_LG_VER_IMP.CHECK_DUP_VER');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END check_dup_ver ;


  PROCEDURE chk_corr_items (p_sar_num      IN           igf_ap_inst_ver_item_all.isir_map_col%TYPE,
                            p_pay_isir_id  IN           igf_ap_fa_base_rec_all.base_id%TYPE,
                            p_corr_exist   OUT  NOCOPY  BOOLEAN )  IS
  /*
  ||  Created By : masehgal
  ||  Created On : 28-May-2003
  ||  Purpose    : check correction items presence
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  CURSOR cur_corr_items ( cp_pay_isir_id   igf_ap_isir_corr.isir_id%TYPE,
                          cp_sar_num       igf_ap_isir_corr.sar_field_number%TYPE ) IS
     SELECT 1
       FROM igf_ap_isir_corr
      WHERE isir_id          = cp_pay_isir_id
        AND sar_field_number = cp_sar_num ;
  l_count    NUMBER ;

  BEGIN
     OPEN  cur_corr_items ( p_pay_isir_id, p_sar_num) ;
     FETCH cur_corr_items INTO l_count ;
     IF cur_corr_items%NOTFOUND THEN
        p_corr_exist := FALSE ;
     ELSE
        p_corr_exist := TRUE ;
     END IF ;
     CLOSE cur_corr_items ;
  EXCEPTION
     WHEN OTHERS THEN
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_lg_ver_imp.chk_corr_items.exception','Unhandled Exception :'||SQLERRM);
        END IF;
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AP_LG_VER_IMP.CHK_CORR_ITEMS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END chk_corr_items ;


  PROCEDURE delete_ver_items ( p_base_id    IN   igf_ap_fa_base_rec_all.base_id%TYPE,
                               p_sar_num    IN   igf_ap_inst_ver_item_all.isir_map_col%TYPE )  IS
  /*
  ||  Created By : masehgal
  ||  Created On : 28-May-2003
  ||  Purpose    : deletion of Ver Items
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  CURSOR del_ver_items( cp_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                        cp_sar_num    igf_ap_inst_ver_item_all.isir_map_col%TYPE ) IS
     SELECT rowid
       FROM igf_ap_inst_ver_item_all
      WHERE base_id      = cp_base_id
        AND isir_map_col = cp_sar_num ;
  lv_rowid  del_ver_items%ROWTYPE;

  BEGIN
     FOR lv_rowid IN del_ver_items ( p_base_id, p_sar_num )
     LOOP
        igf_ap_inst_ver_item_pkg.delete_row( x_rowid => lv_rowid.rowid);
     END LOOP;

  EXCEPTION
     WHEN OTHERS THEN
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_lg_ver_imp.delete_ver_items.exception','Unhandled Exception :'||SQLERRM);
        END IF;
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AP_LG_VER_IMP.DELETE_VER_TERMS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END delete_ver_items ;



  PROCEDURE upd_fed_verif_status ( p_fed_verif_status igf_ap_fa_base_rec_all.fed_verif_status%TYPE ) IS
  /*
  ||  Created By : masehgal
  ||  Created On : 28-May-2003
  ||  Purpose    : updation of verification status
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||   rasahoo        17-NOV-2003     FA 128 - ISIR update 2004-05
  ||                                  added new parameter award_fmly_contribution_type to
  ||                                  igf_ap_fa_base_rec_pkg.update_row
  ||  ugummall        26-SEP-2003     FA 126 - Multiple FA Offices.
  ||                                  added new parameter assoc_org_num to TBH call of
  ||                                  igf_ap_fa_base_rec_pkg   w.r.t. FA 126
  ||
  ||  (reverse chronological order - newest change first)
  */

  BEGIN
     -- get base rec values

     -- update fa base rec with new verif status ...
         igf_ap_fa_base_rec_pkg.update_row(
                                      x_rowid                      =>  g_fabase.row_id,
                                      x_base_id                    =>  g_fabase.base_id,
                                      x_ci_cal_type                =>  g_fabase.ci_cal_type,
                                      x_person_id                  =>  g_fabase.person_id,
                                      x_ci_sequence_number         =>  g_fabase.ci_sequence_number,
                                      x_org_id                     =>  g_fabase.org_id,
                                      x_coa_pending                =>  g_fabase.coa_pending,
                                      x_verification_process_run   =>  g_fabase.verification_process_run,
                                      x_inst_verif_status_date     =>  g_fabase.inst_verif_status_date,
                                      x_manual_verif_flag          =>  g_fabase.manual_verif_flag,
                                      x_fed_verif_status           =>  p_fed_verif_status,
                                      x_fed_verif_status_date      =>  TRUNC(SYSDATE),
                                      x_inst_verif_status          =>  g_fabase.inst_verif_status,
                                      x_nslds_eligible             =>  g_fabase.nslds_eligible,
                                      x_ede_correction_batch_id    =>  g_fabase.ede_correction_batch_id,
                                      x_fa_process_status_date     =>  g_fabase.fa_process_status_date,
                                      x_isir_corr_status           =>  g_fabase.isir_corr_status,
                                      x_isir_corr_status_date      =>  g_fabase.isir_corr_status_date,
                                      x_isir_status                =>  g_fabase.isir_status,
                                      x_isir_status_date           =>  g_fabase.isir_status_date,
                                      x_coa_code_f                 =>  g_fabase.coa_code_f,
                                      x_coa_code_i                 =>  g_fabase.coa_code_i,
                                      x_coa_f                      =>  g_fabase.coa_f,
                                      x_coa_i                      =>  g_fabase.coa_i,
                                      x_disbursement_hold          =>  g_fabase.disbursement_hold,
                                      x_fa_process_status          =>  g_fabase.fa_process_status,
                                      x_notification_status        =>  g_fabase.notification_status,
                                      x_notification_status_date   =>  g_fabase.notification_status_date,
                                      x_packaging_status           =>  g_fabase.packaging_status,
                                      x_packaging_status_date      =>  g_fabase.packaging_status_date,
                                      x_total_package_accepted     =>  g_fabase.total_package_accepted,
                                      x_total_package_offered      =>  g_fabase.total_package_offered,
                                      x_admstruct_id               =>  g_fabase.admstruct_id,
                                      x_admsegment_1               =>  g_fabase.admsegment_1,
                                      x_admsegment_2               =>  g_fabase.admsegment_2,
                                      x_admsegment_3               =>  g_fabase.admsegment_3,
                                      x_admsegment_4               =>  g_fabase.admsegment_4,
                                      x_admsegment_5               =>  g_fabase.admsegment_5,
                                      x_admsegment_6               =>  g_fabase.admsegment_6,
                                      x_admsegment_7               =>  g_fabase.admsegment_7,
                                      x_admsegment_8               =>  g_fabase.admsegment_8,
                                      x_admsegment_9               =>  g_fabase.admsegment_9,
                                      x_admsegment_10              =>  g_fabase.admsegment_10,
                                      x_admsegment_11              =>  g_fabase.admsegment_11,
                                      x_admsegment_12              =>  g_fabase.admsegment_12,
                                      x_admsegment_13              =>  g_fabase.admsegment_13,
                                      x_admsegment_14              =>  g_fabase.admsegment_14,
                                      x_admsegment_15              =>  g_fabase.admsegment_15,
                                      x_admsegment_16              =>  g_fabase.admsegment_16,
                                      x_admsegment_17              =>  g_fabase.admsegment_17,
                                      x_admsegment_18              =>  g_fabase.admsegment_18,
                                      x_admsegment_19              =>  g_fabase.admsegment_19,
                                      x_admsegment_20              =>  g_fabase.admsegment_20,
                                      x_packstruct_id              =>  g_fabase.packstruct_id,
                                      x_packsegment_1              =>  g_fabase.packsegment_1,
                                      x_packsegment_2              =>  g_fabase.packsegment_2,
                                      x_packsegment_3              =>  g_fabase.packsegment_3,
                                      x_packsegment_4              =>  g_fabase.packsegment_4,
                                      x_packsegment_5              =>  g_fabase.packsegment_5,
                                      x_packsegment_6              =>  g_fabase.packsegment_6,
                                      x_packsegment_7              =>  g_fabase.packsegment_7,
                                      x_packsegment_8              =>  g_fabase.packsegment_8,
                                      x_packsegment_9              =>  g_fabase.packsegment_9,
                                      x_packsegment_10             =>  g_fabase.packsegment_10,
                                      x_packsegment_11             =>  g_fabase.packsegment_11,
                                      x_packsegment_12             =>  g_fabase.packsegment_12,
                                      x_packsegment_13             =>  g_fabase.packsegment_13,
                                      x_packsegment_14             =>  g_fabase.packsegment_14,
                                      x_packsegment_15             =>  g_fabase.packsegment_15,
                                      x_packsegment_16             =>  g_fabase.packsegment_16,
                                      x_packsegment_17             =>  g_fabase.packsegment_17,
                                      x_packsegment_18             =>  g_fabase.packsegment_18,
                                      x_packsegment_19             =>  g_fabase.packsegment_19,
                                      x_packsegment_20             =>  g_fabase.packsegment_20,
                                      x_miscstruct_id              =>  g_fabase.miscstruct_id,
                                      x_miscsegment_1              =>  g_fabase.miscsegment_1,
                                      x_miscsegment_2              =>  g_fabase.miscsegment_2,
                                      x_miscsegment_3              =>  g_fabase.miscsegment_3,
                                      x_miscsegment_4              =>  g_fabase.miscsegment_4,
                                      x_miscsegment_5              =>  g_fabase.miscsegment_5,
                                      x_miscsegment_6              =>  g_fabase.miscsegment_6,
                                      x_miscsegment_7              =>  g_fabase.miscsegment_7,
                                      x_miscsegment_8              =>  g_fabase.miscsegment_8,
                                      x_miscsegment_9              =>  g_fabase.miscsegment_9,
                                      x_miscsegment_10             =>  g_fabase.miscsegment_10,
                                      x_miscsegment_11             =>  g_fabase.miscsegment_11,
                                      x_miscsegment_12             =>  g_fabase.miscsegment_12,
                                      x_miscsegment_13             =>  g_fabase.miscsegment_13,
                                      x_miscsegment_14             =>  g_fabase.miscsegment_14,
                                      x_miscsegment_15             =>  g_fabase.miscsegment_15,
                                      x_miscsegment_16             =>  g_fabase.miscsegment_16,
                                      x_miscsegment_17             =>  g_fabase.miscsegment_17,
                                      x_miscsegment_18             =>  g_fabase.miscsegment_18,
                                      x_miscsegment_19             =>  g_fabase.miscsegment_19,
                                      x_miscsegment_20             =>  g_fabase.miscsegment_20,
                                      x_prof_judgement_flg         =>  g_fabase.prof_judgement_flg,
                                      x_nslds_data_override_flg    =>  g_fabase.nslds_data_override_flg ,
                                      x_target_group               =>  g_fabase.target_group,
                                      x_coa_fixed                  =>  g_fabase.coa_fixed,
                                      x_coa_pell                   =>  g_fabase.coa_pell,
                                      x_profile_status             =>  g_fabase.profile_status,
                                      x_profile_status_date        =>  g_fabase.profile_status_date,
                                      x_profile_fc                 =>  g_fabase.profile_fc,
                                      x_tolerance_amount           =>  g_fabase.tolerance_amount,
                                      x_manual_disb_hold           =>  g_fabase.manual_disb_hold,
                                      x_mode                       =>   'R',
                                      x_pell_alt_expense           =>   g_fabase.pell_alt_expense,
                                      x_assoc_org_num              =>   g_fabase.assoc_org_num,
                                      x_award_fmly_contribution_type => g_fabase.award_fmly_contribution_type,
                                      x_isir_locked_by             =>  g_fabase.isir_locked_by,
				      x_adnl_unsub_loan_elig_flag  =>  g_fabase.adnl_unsub_loan_elig_flag,
                                      x_lock_awd_flag              => g_fabase.lock_awd_flag,
                                      x_lock_coa_flag              => g_fabase.lock_coa_flag

                                     );


  EXCEPTION
     WHEN OTHERS THEN
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_lg_ver_imp.upd_fed_verif_status.exception','Unhandled Exception :'||SQLERRM);
        END IF;
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AP_LG_VER_IMP.UPD_FED_VERIF_STATUS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END upd_fed_verif_status ;


  PROCEDURE main ( errbuf            OUT NOCOPY VARCHAR2,
                   retcode           OUT NOCOPY NUMBER,
                   p_award_year      IN         VARCHAR2,
                   p_batch_num       IN         VARCHAR2,
                   p_delete_flag     IN         VARCHAR2 ) IS
  /*
  ||  Created By : masehgal
  ||  Created On : 28-May-2003
  ||  Purpose    : Main - called from submitted request
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  tsailaja		  13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
  ||  rasahoo         17-Oct-2003     #3085558  FA121 Added parameter use_blank_flag in
  ||                                  igf_ap_inst_ver_item_pkg.insert_row
  */

    l_prof_set             VARCHAR2(1) ;
    g_terminate_process    BOOLEAN  := FALSE ;
    g_skip_person          BOOLEAN  := FALSE ;
    g_skip_record          BOOLEAN  := FALSE ;
    g_award_year_status    igf_ap_batch_aw_map.award_year_status_code%TYPE ;
    g_sys_award_year       igf_ap_batch_aw_map.sys_award_year%TYPE ;
    l_alternate_code       igs_ca_inst.alternate_code%TYPE ;
    l_rec_processed        NUMBER;
    l_rec_imported         NUMBER;
    l_last_person_number   igf_ap_li_vern_ints.person_number%TYPE ;
    l_fa_base_id           igf_ap_fa_base_rec.base_id%TYPE;
    l_person_id            igf_ap_fa_base_rec.person_id%TYPE;
    l_dup_item_found       BOOLEAN;
    l_pay_isir_id          igf_ap_isir_matched.isir_id%TYPE ;
    l_act_isir_id          igf_ap_isir_matched.isir_id%TYPE ;
    l_error                igf_lookups_view.meaning%TYPE ;
    l_person_number        igf_lookups_view.meaning%TYPE ;
    l_token                VARCHAR2(60) ;
    l_corr_exist           BOOLEAN ;
    l_fed_verif_status     igf_ap_fa_base_rec_all.fed_verif_status%TYPE ;
    l_new_fed_verif_status igf_ap_fa_base_rec_all.fed_verif_status%TYPE ;
    l_orig_value           VARCHAR2(1000);
    l_doc_value            VARCHAR2(1000);
    lv_rowid               ROWID ;
    lv_stmt                VARCHAR2(2000);
    l_diff_flag            BOOLEAN ;
    l_doc_null_flag        BOOLEAN ;
    lv_cur                 PLS_INTEGER;
    lv_rows                INTEGER;
    l_per_item_count       NUMBER ;
    l_batch_valid          VARCHAR2(1) ;


    -- cursor to get sys award year and award year status
    CURSOR c_get_stat IS
       SELECT award_year_status_code, sys_award_year
         FROM igf_ap_batch_aw_map   map
        WHERE map.ci_cal_type         = g_ci_cal_type
          AND map.ci_sequence_number  = g_ci_sequence_number ;

    -- cursor to get persons for import
    CURSOR  c_get_persons ( cp_alternate_code  igf_ap_li_vern_ints.ci_alternate_code%TYPE,
                            cp_batch_num       igf_ap_li_vern_ints.batch_num%TYPE ) IS
       SELECT *
         FROM igf_ap_li_vern_ints
        WHERE ci_alternate_code  = cp_alternate_code
          AND batch_num          = cp_batch_num
          AND import_status_type IN ('R','U')
     ORDER BY person_number ;

    person_rec    c_get_persons%ROWTYPE ;

    -- cursor to get alternate code for award year
    CURSOR c_alternate_code( cp_ci_cal_type         igs_ca_inst.cal_type%TYPE ,
                             cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE ) IS
       SELECT alternate_code
         FROM igs_ca_inst
        WHERE cal_type        = cp_ci_cal_type
          AND sequence_number = cp_ci_sequence_number ;

    -- check SAR Field Number done
    CURSOR c_get_sar_num ( cp_sys_award_year   igf_fc_sar_cd_mst.sys_award_year%TYPE,
                           cp_sar_name         igf_fc_sar_cd_mst.sar_field_name%TYPE) IS
       SELECT sar_field_number
         FROM igf_fc_sar_cd_mst
        WHERE sys_award_year = cp_sys_award_year
          AND sar_field_name = cp_sar_name ;
    l_sar_num     igf_fc_sar_cd_mst.sar_field_number%TYPE;


    -- get active and payment ISIR
    CURSOR c_act_pay_isir ( cp_base_id     igf_ap_isir_matched.base_id%TYPE ) IS
       SELECT isir_id, active_isir, payment_isir
         FROM igf_ap_isir_matched
        WHERE base_id      = cp_base_id
          AND (active_isir = 'Y'  OR  payment_isir = 'Y' ) ;
    act_pay_isir_rec   c_act_pay_isir%ROWTYPE ;


   BEGIN  -- of MAIN
	  igf_aw_gen.set_org_id(NULL);
      retcode := 0;
      l_prof_set := 'N' ;
      /****************************************
      -- Check if the following profiles are set
      *****************************************/
      l_prof_set :=  igf_ap_gen.check_profile ;

      IF l_prof_set = 'Y' THEN
         l_error         := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','ERROR');
         l_person_number := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','PERSON_NUMBER');

         -- profiles properly set  ....... proceed
         -- Get the Award Year Calender Type and the Sequence Number
         g_ci_cal_type        := RTRIM(SUBSTR(p_award_year,1,10));
         g_ci_sequence_number := TO_NUMBER(RTRIM(SUBSTR(p_award_year,11)));

         -- Get the Award Year Alternate Code
         OPEN  c_alternate_code( g_ci_cal_type, g_ci_sequence_number ) ;
         FETCH c_alternate_code INTO l_alternate_code ;
         CLOSE c_alternate_code ;

         -- Log input params
         log_input_params( p_batch_num, l_alternate_code , p_delete_flag);
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_lg_ver_imp.main.debug','Completed input parameters logging in Procedure main');
         END IF;

         -- Get Award Year Status
         OPEN  c_get_stat ;
         FETCH c_get_stat INTO g_award_year_status, g_sys_award_year ;
         -- check validity of award year
         IF c_get_stat%NOTFOUND THEN
            -- Award Year setup tampered .... Log a message
            FND_MESSAGE.SET_NAME('IGF','IGF_AP_AWD_YR_NOT_FOUND');
            FND_MESSAGE.SET_TOKEN('P_AWARD_YEAR', l_alternate_code);
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            g_terminate_process := TRUE ;
         ELSE
            -- Award year exists but is it Open/Legacy Details .... check
            IF g_award_year_status NOT IN ('O','LD') THEN
               FND_MESSAGE.SET_NAME('IGF','IGF_AP_LG_INVALID_STAT');
               FND_MESSAGE.SET_TOKEN('AWARD_STATUS', g_award_year_status);
               FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
               g_terminate_process := TRUE ;
            END IF ;  -- awd ye open or legacy detail chk
         END IF ; -- award year invalid check
         CLOSE c_get_stat ;

         -- check validity of batch
         l_batch_valid := igf_ap_gen.check_batch ( p_batch_num, 'VERIF') ;
         IF NVL(l_batch_valid,'N') <> 'Y' THEN
            FND_MESSAGE.SET_NAME('IGF','IGF_GR_BATCH_DOES_NOT_EXIST');
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            g_terminate_process := TRUE ;
         END IF;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_lg_ver_imp.main.debug','Completed batch validations in Procedure main');
         END IF;


         /***********************************************************************
         Person Level checks
         l_rec_processed  flag to monitor the number of records in the batch
         submitted for processing
         l_last_person_number Holds the last processed Person Number
         ***********************************************************************/

         -- check for terminate flag
         IF NOT g_terminate_process THEN
            l_last_person_number  := NULL ;
            l_rec_processed       := 0 ;
            l_per_item_count      := 0 ;
            l_rec_imported        := 0 ;

            -- Select persons from interface table
            FOR person_rec IN c_get_persons (l_alternate_code, p_batch_num)
            LOOP
               -- validate each person
               l_rec_processed := l_rec_processed + 1 ;
               g_skip_record   := FALSE ;

               -- check if this person has been processed before ....
               -- if yes, then skip the person related validations re-check
               IF person_rec.person_number <> NVL(l_last_person_number,'*') THEN
                  -- have to update the fa base rec for the previous person ....
                  IF l_last_person_number IS NOT NULL THEN
                     -- only for legacy details
                     IF g_award_year_status = 'LD' THEN
                        OPEN  c_fabase(l_last_person_number) ;
                        FETCH c_fabase INTO g_fabase ;
                        CLOSE c_fabase ;

                        l_fed_verif_status := g_fabase.fed_verif_status ;

                        IF l_per_item_count > 0 THEN
                           IF l_fed_verif_status IN ('SELECTED','NOTSELECTED') THEN
                              IF l_doc_null_flag THEN
                                 l_new_fed_verif_status := 'WITHOUTDOC' ;
                                 FND_MESSAGE.SET_NAME('IGF','IGF_AP_VER_STAT_WITHOUT_DOC');
                                 g_log_tab_index := g_log_tab_index + 1;
                                 g_log_tab(g_log_tab_index).person_number := l_last_person_number ;
                                 g_log_tab(g_log_tab_index).message_text := RPAD(null,12) || fnd_message.get;
                              END IF ;
                              IF NOT l_doc_null_flag AND NOT l_diff_flag THEN
                                 l_new_fed_verif_status := 'ACCURATE' ;
                                 FND_MESSAGE.SET_NAME('IGF','IGF_AP_VER_STAT_ACCURATE');
                                 g_log_tab_index := g_log_tab_index + 1;
                                 g_log_tab(g_log_tab_index).person_number := l_last_person_number;
                                 g_log_tab(g_log_tab_index).message_text := RPAD(null,12) || fnd_message.get;
                              END IF ;
                              IF NOT l_doc_null_flag AND l_diff_flag THEN
                                 l_new_fed_verif_status := 'SELECTED' ;
                                 FND_MESSAGE.SET_NAME('IGF','IGF_AP_VER_STAT_SELECTED');
                                 g_log_tab_index := g_log_tab_index + 1;
                                 g_log_tab(g_log_tab_index).person_number := l_last_person_number;
                                 g_log_tab(g_log_tab_index).message_text := RPAD(null,12) || fnd_message.get;
                              END IF ;

                              upd_fed_verif_status ( l_new_fed_verif_status) ;
                              -- commit after updating the fa base rec
                              COMMIT ;
                              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_lg_ver_imp.main.debug','Federal Verification Status updated in Procedure main');
                              END IF;

                           END IF ;
                        END IF ;
                     END IF ;
                  END IF ;

                  -- new person ..
                  -- set skip flag for the new person to FALSE
                  g_skip_person := FALSE ;
                  l_diff_flag   := FALSE ;
                  l_doc_null_flag := FALSE ;
                  l_per_item_count := 0 ;

                  -- call procedure to check person existence and fa base rec existence
                  igf_ap_gen.check_person ( person_rec.person_number, g_ci_cal_type, g_ci_sequence_number,
                                            l_person_id, l_fa_base_id) ;

                  IF l_person_id IS NULL THEN
                     FND_MESSAGE.SET_NAME('IGF','IGF_AP_PE_NOT_EXIST');
                     g_log_tab_index := g_log_tab_index + 1;
                     g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                     g_log_tab(g_log_tab_index).message_text := RPAD(l_error,12) || fnd_message.get;
                     g_skip_person := TRUE ;
                  ELSIF l_fa_base_id IS NULL THEN
                     FND_MESSAGE.SET_NAME('IGF','IGF_AP_FABASE_NOT_FOUND');
                     g_log_tab_index := g_log_tab_index + 1;
                     g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                     g_log_tab(g_log_tab_index).message_text := RPAD(l_error,12) || fnd_message.get;
                     g_skip_person := TRUE ;
                  ELSE
                     g_skip_person := FALSE ;
                  END IF ; -- person existence check

                  IF l_person_id IS NOT NULL THEN
                     -- check for Active and Payment ISIR for the person ...
                     l_act_isir_id := NULL ;
                     l_pay_isir_id := NULL ;
                     FOR act_pay_isir_rec IN c_act_pay_isir ( l_fa_base_id )
                     LOOP
                        EXIT WHEN c_act_pay_isir%NOTFOUND ;
                        IF act_pay_isir_rec.active_isir = 'Y' THEN
                           l_act_isir_id := act_pay_isir_rec.isir_id ;
                        END IF ;
                        IF act_pay_isir_rec.payment_isir = 'Y' THEN
                           l_pay_isir_id := act_pay_isir_rec.isir_id ;
                        END IF ;
                     END LOOP ;
                     IF l_act_isir_id IS NULL THEN
                        FND_MESSAGE.SET_NAME('IGF','IGF_AP_ACT_ISIR_NOT_FOUND');
                        g_log_tab_index := g_log_tab_index + 1;
                        g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                        g_log_tab(g_log_tab_index).message_text  := RPAD(l_error,12) || fnd_message.get;
                        g_skip_person := TRUE ;
                     END IF ;
                     IF l_pay_isir_id IS NULL THEN
                        FND_MESSAGE.SET_NAME('IGF','IGF_AP_NO_PAY_ISIR');
                        g_log_tab_index := g_log_tab_index + 1;
                        g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                        g_log_tab(g_log_tab_index).message_text  := RPAD(l_error,12) || fnd_message.get;
                        g_skip_person := TRUE ;
                     END IF ;
                  END IF ;
               END IF ;  -- person already processed check

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                 fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_lg_ver_imp.main.debug','Completed person validations in Procedure main');
               END IF;


               /* End Of Person level Check */
               /**************************************************
               Ver Item Level checks
               ***************************************************/

               -- Check for person skip flag
               IF g_skip_person THEN
                  -- person skip flag set....
                  -- if flag set then the person related records aer to be marked as error records and skipped
                  -- update all person records to error status
                  UPDATE igf_ap_li_vern_ints
                     SET import_status_type = 'E'
                   WHERE batch_num = p_batch_num
                     AND person_number = person_rec.person_number ;
                  --COMMIT ;
               ELSE  -- person not to b skipped
                  -- Item level validations ...
                  l_token := person_rec.sar_field_label_code || ' VERINT_ID - ' || TO_CHAR(person_rec.verint_id) ;
                  FND_MESSAGE.SET_NAME('IGF','IGF_AP_PROC_ITM');
                  FND_MESSAGE.SET_TOKEN('ITEM', l_token );
                  g_log_tab_index := g_log_tab_index + 1;
                  g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                  g_log_tab(g_log_tab_index).message_text  := RPAD(null,12) || fnd_message.get;

                  -- ver item valid
                  OPEN  c_get_sar_num ( g_sys_award_year, person_rec.sar_field_label_code);
                  FETCH c_get_sar_num INTO l_sar_num ;
                  -- if no Ver Item found
                  IF c_get_sar_num%NOTFOUND THEN
                     l_sar_num := NULL ;
                     FND_MESSAGE.SET_NAME('IGF','IGF_AP_INVALID_VERN_ITM');
                     FND_MESSAGE.SET_TOKEN('ITEM', person_rec.sar_field_label_code);
                     g_log_tab_index := g_log_tab_index + 1;
                     g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                     g_log_tab(g_log_tab_index).message_text  := RPAD(l_error,12) || fnd_message.get;
                     g_skip_record := TRUE ;
                  END IF ;
                  CLOSE c_get_sar_num;

                  -- ver item duplicate
                  IF l_sar_num is NOT NULL THEN
                     check_dup_ver ( l_sar_num, l_fa_base_id, l_dup_item_found) ;
                     IF l_dup_item_found AND NVL(person_rec.import_record_type,'A') <> 'U'  THEN
                        -- log a message for duplicate
                        FND_MESSAGE.SET_NAME('IGF','IGF_AP_VER_ITM_EXIST');
                        FND_MESSAGE.SET_TOKEN('ITEM', person_rec.sar_field_label_code);
                        g_log_tab_index := g_log_tab_index + 1;
                        g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                        g_log_tab(g_log_tab_index).message_text  := RPAD(l_error,12) || fnd_message.get;
                        g_skip_record := TRUE ;
                     END IF ;
                     IF (NOT l_dup_item_found) AND NVL(person_rec.import_record_type,'A') = 'U'  THEN
                        -- log a message for duplicate
                        FND_MESSAGE.SET_NAME('IGF','IGF_AP_ORIG_REC_NOT_FOUND');
                        g_log_tab_index := g_log_tab_index + 1;
                        g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                        g_log_tab(g_log_tab_index).message_text  := RPAD(l_error,12) ||fnd_message.get;
                        g_skip_record := TRUE ;
                     END IF ;

                     IF l_dup_item_found THEN
                        -- check if corrections have been created for the ver item
                        l_corr_exist := FALSE ;
                        chk_corr_items ( l_pay_isir_id , l_sar_num , l_corr_exist) ;
                        IF l_corr_exist THEN
                           FND_MESSAGE.SET_NAME('IGF','IGF_AP_VER_CORR_GEN');
                           g_log_tab_index := g_log_tab_index + 1;
                           g_log_tab(g_log_tab_index).person_number := person_rec.person_number;
                           g_log_tab(g_log_tab_index).message_text  := RPAD(l_error,12) ||fnd_message.get;
                           g_skip_record := TRUE ;
                        END IF ;
                     END IF ;  -- end of dup found ...
                  END IF ; -- end of sar null chk
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_lg_ver_imp.main.debug','Completed record validations in Procedure main');
                  END IF;



                  -- all record validations done ...
                  -- now check for skip record flag
                  IF g_skip_record THEN
                      UPDATE igf_ap_li_vern_ints
                         SET import_status_type = 'E'
                       WHERE verint_id = person_rec.verint_id ;
                      COMMIT ;
                  ELSE
                     -- add records
                     IF NVL(person_rec.import_record_type,'A') = 'U' THEN
                        -- record exists
                        -- has to be deleted
                        delete_ver_items ( l_fa_base_id, l_sar_num );
                     END IF; --
                     -- Now add records
                     l_per_item_count := l_per_item_count + 1 ;
                     l_rec_imported   := l_rec_imported + 1 ;
                     igf_ap_inst_ver_item_pkg.insert_row (
                      x_rowid                       => lv_rowid ,
                      x_base_id                     => l_fa_base_id ,
                      x_udf_vern_item_seq_num       => NULL ,
                      x_item_value                  => TRIM(person_rec.sar_field_value_txt) ,
                      x_waive_flag                  => NULL ,
                      x_incl_in_tolerance           => NULL ,
                      x_isir_map_col                => l_sar_num ,
                      x_legacy_record_flag          => 'Y' ,
                      x_use_blank_flag              => NULL,
                      x_mode                        => 'R'
                    );
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_lg_ver_imp.main.debug','Inserted Verification record in Procedure main');
                    END IF;

                    -- now update the record status
                    IF p_delete_flag = 'Y' THEN
                       DELETE FROM igf_ap_li_vern_ints
                       WHERE verint_id = person_rec.verint_id ;
                       COMMIT ;
                    ELSE
                      UPDATE igf_ap_li_vern_ints
                         SET import_status_type = 'I'
                       WHERE verint_id = person_rec.verint_id ;
                      COMMIT ;
                    END IF ;

                   IF g_award_year_status = 'LD' THEN
                      -- get the existing value for the item ....
                      IF person_rec.sar_field_label_code IS NOT NULL THEN
                         lv_cur  := DBMS_SQL.OPEN_CURSOR;
                         lv_stmt := 'SELECT ' || person_rec.sar_field_label_code || ' FROM igf_ap_isir_matched WHERE isir_id = :l_isir_id' ;

                         DBMS_SQL.PARSE(lv_cur,lv_stmt,2);
                         DBMS_SQL.BIND_VARIABLE(lv_cur, 'l_isir_id', TO_CHAR(l_pay_isir_id));

                         DBMS_SQL.DEFINE_COLUMN(lv_cur,1,l_orig_value,30);
                         lv_rows := DBMS_SQL.EXECUTE_AND_FETCH(lv_cur);
                         DBMS_SQL.COLUMN_VALUE(lv_cur,1,l_orig_value);
                         DBMS_SQL.CLOSE_CURSOR(lv_cur);
                      END IF;
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_lg_ver_imp.main.debug','Obtained isir column value in Procedure main');
                      END IF;


                      -- check the original value with the new doc value
                      IF (l_orig_value = person_rec.sar_field_value_txt) OR
                         (l_orig_value is NULL and person_rec.sar_field_value_txt is NULL) THEN
                           NULL;
                      ELSE
                           l_diff_flag := TRUE ;
                      END IF ;

                      IF person_rec.sar_field_value_txt IS NULL THEN
                         l_doc_null_flag := TRUE ;
                      END IF ;
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_lg_ver_imp.main.debug','Set difference and null value flags in Procedure main');
                      END IF;


                   END IF ; -- award year check ...
                  END IF ; -- skip record check

               END IF ; -- person skip flag check

               -- Reset the Last Person Processed
               l_last_person_number := person_rec.person_number;
            END LOOP ; -- person selection loop

            -- now update fa base record for the last person processed ...
            IF g_award_year_status = 'LD' THEN
               IF l_per_item_count > 0 THEN
                  OPEN  c_fabase(l_last_person_number) ;
                  FETCH c_fabase INTO g_fabase ;
                  CLOSE c_fabase ;

                  l_fed_verif_status := g_fabase.fed_verif_status ;

                  IF l_fed_verif_status IN ('SELECTED','NOTSELECTED') THEN
                     IF l_doc_null_flag THEN
                        l_new_fed_verif_status := 'WITHOUTDOC' ;
                        FND_MESSAGE.SET_NAME('IGF','IGF_AP_VER_STAT_WITHOUT_DOC');
                        g_log_tab_index := g_log_tab_index + 1;
                        g_log_tab(g_log_tab_index).person_number := l_last_person_number ;
                        g_log_tab(g_log_tab_index).message_text := RPAD(null,12) || fnd_message.get;
                     END IF ;
                     IF NOT l_doc_null_flag AND NOT l_diff_flag THEN
                        l_new_fed_verif_status := 'ACCURATE' ;
                        FND_MESSAGE.SET_NAME('IGF','IGF_AP_VER_STAT_ACCURATE');
                        g_log_tab_index := g_log_tab_index + 1;
                        g_log_tab(g_log_tab_index).person_number := l_last_person_number;
                        g_log_tab(g_log_tab_index).message_text := RPAD(null,12) || fnd_message.get;
                     END IF ;
                     IF NOT l_doc_null_flag AND l_diff_flag THEN
                        l_new_fed_verif_status := 'SELECTED' ;
                        FND_MESSAGE.SET_NAME('IGF','IGF_AP_VER_STAT_SELECTED');
                        g_log_tab_index := g_log_tab_index + 1;
                        g_log_tab(g_log_tab_index).person_number := l_last_person_number;
                        g_log_tab(g_log_tab_index).message_text := RPAD(null,12) || fnd_message.get;
                     END IF ;

                     upd_fed_verif_status ( l_new_fed_verif_status) ;
                     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_lg_ver_imp.main.debug','Federal Verification Status updated for last person in Procedure main');
                     END IF;

                  END IF ; -- verification status check ...
               END IF ; -- counter check ....
            END IF ; -- award year check ...

            IF l_rec_processed = 0 THEN
               FND_MESSAGE.SET_NAME('IGF','IGF_AP_AWDYR_STAT_NOT_EXISTS');
               FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
            ELSE
               -- CALL THE PRINT LOG PROCESS
               print_log_process(l_person_number,l_error);
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING('IGS','IGS_GE_TOTAL_REC_PROCESSED'),50)|| TO_CHAR(l_rec_processed) );
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING('IGS','IGS_GE_TOTAL_REC_FAILED'),50)|| TO_CHAR(l_rec_processed - l_rec_imported));
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(FND_MESSAGE.GET_STRING('IGS','IGS_AD_SUCC_IMP_OFR_RESP_REC'),50)|| TO_CHAR(l_rec_imported));

               IF l_rec_imported = 0 THEN
                  FND_FILE.PUT_LINE( FND_FILE.OUTPUT, ' ');
                  FND_FILE.PUT_LINE( FND_FILE.OUTPUT, '-------------------------------------------------------------');
                  FND_FILE.PUT_LINE( FND_FILE.OUTPUT, ' ');
                  FND_MESSAGE.SET_NAME('IGS','IGS_EN_NO_DATA_IMP' );
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET);
               END IF ;
            END IF ;

         END IF ; -- terminate flag check

      ELSE -- profile check
         -- error message
         -- terminate the process .. no further processing
         FND_MESSAGE.SET_NAME('IGF','IGF_AP_LGCY_PROC_NOT_RUN');
         FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      END IF ; -- profile check ends

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RETCODE := 2 ;
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_lg_ver_imp.main.exception','Unhandled Exception :'||SQLERRM);
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP') ;
      FND_MESSAGE.SET_TOKEN('NAME','IGF_AP_LG_VER_IMP.MAIN') ;
      errbuf := FND_MESSAGE.GET ;
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL ;
   END main ;

   END  igf_ap_lg_ver_imp ;

/
