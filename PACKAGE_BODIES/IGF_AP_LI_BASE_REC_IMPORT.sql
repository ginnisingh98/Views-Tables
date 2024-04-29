--------------------------------------------------------
--  DDL for Package Body IGF_AP_LI_BASE_REC_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_LI_BASE_REC_IMPORT" AS
/* $Header: IGFAP43B.pls 120.6 2006/02/14 23:04:28 ridas ship $ */

g_log_tab_index   NUMBER := 0;

TYPE log_record IS RECORD
        ( person_number VARCHAR2(30),
          message_text VARCHAR2(500));

-- The PL/SQL table for storing the log messages
TYPE LogTab IS TABLE OF log_record
           index by binary_integer;

g_log_tab LogTab;

 -- The PL/SQL table for storing the duplicate person number
TYPE PerTab IS TABLE OF igf_ap_li_css_act_ints.person_number%TYPE
           index by binary_integer;

g_per_tab PerTab;

  PROCEDURE main (
                  errbuf          OUT NOCOPY VARCHAR2,
                  retcode         OUT NOCOPY NUMBER,
                  p_award_year    IN         VARCHAR2,
                  p_batch_id      IN         NUMBER,
                  p_del_ind       IN         VARCHAR2
                 )
    IS
    /*
    ||  Created By : bkkumar
    ||  Created On : 13-JUN-2003
    ||  Purpose : Main process imports the data from the interface table
    ||
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  ridas           14-Feb-2006     Bug #5021084. Removed trunc function from
    ||                                  cursor SSN_CUR.
	  ||  tsailaja		    13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
    ||  rajagupt        06-Oct-2005     Bug#4068548 - added a new cursor ssn_cur
    ||  asbala          19-nov-2003     3026594: FA128 - ISIR Federal Updates 04- 05,
    ||                                  modified signature of igf_ap_isir_matched_pkg
    ||  ugummall        25-SEP-2003     FA 126 Multiple FA Offices
    ||                                  added new parameter assoc_org_num to
    ||                                  igf_ap_fa_base_rec_pkg.update_row call
    ||                                  and added the same to cursor c_baseid_exists
    ||  (reverse chronological order - newest change first)
    */
    l_proc_item_str        VARCHAR2(50) := NULL;
    l_message_str          VARCHAR2(800) := NULL;
    l_terminate_flag       BOOLEAN := FALSE;
    l_error_flag           BOOLEAN := FALSE;
    l_error                VARCHAR2(80);
    lv_row_id              VARCHAR2(80) := NULL;
    lv_person_id           igs_pe_hz_parties.party_id%TYPE := NULL;
    lv_base_id             igf_ap_fa_base_rec_all.base_id%TYPE := NULL;
    l_process_status       igf_ap_fa_base_rec_all.fa_process_status%TYPE := NULL;
    l_process_date         igf_ap_fa_base_rec_all.packaging_status_date%TYPE := NULL;
    l_success_record_cnt   NUMBER := 0;
    l_error_record_cnt     NUMBER := 0;
    l_todo_flag            BOOLEAN := FALSE;
    l_chk_profile          VARCHAR2(1) := 'N';
    l_chk_batch            VARCHAR2(1) := 'N';
    l_index                NUMBER := 1;
    l_total_record_cnt     NUMBER := 0;
    l_debug_str            VARCHAR2(800) := NULL;

    l_cal_type   igf_ap_fa_base_rec_all.ci_cal_type%TYPE ;
    l_seq_number igf_ap_fa_base_rec_all.ci_sequence_number%TYPE;
    l_base_id    igf_ap_fa_base_rec_all.base_id%TYPE;
    l_row_id     ROWID;
    l_create_flag BOOLEAN;
    l_create_base_rec BOOLEAN;


    -- Cursor for getting the context award year details
    CURSOR c_get_status(cp_cal_type igf_ap_batch_aw_map.ci_cal_type%TYPE,
                        cp_seq_number igf_ap_batch_aw_map.ci_sequence_number%TYPE)
    IS
    SELECT sys_award_year,
           batch_year,
           award_year_status_code,
           css_academic_year
    FROM   igf_ap_batch_aw_map
    WHERE  ci_cal_type = cp_cal_type
    AND    ci_sequence_number = cp_seq_number;

    l_get_status c_get_status%ROWTYPE;

    CURSOR c_get_alternate_code(cp_cal_type igs_ca_inst.cal_type%TYPE,
                                cp_seq_number igs_ca_inst.sequence_number%TYPE)
    IS
    SELECT alternate_code
    FROM   igs_ca_inst
    WHERE  cal_type = cp_cal_type
    AND    sequence_number = cp_seq_number;

    l_get_alternate_code  c_get_alternate_code%ROWTYPE;

    CURSOR  c_get_records(cp_alternate_code igf_ap_li_fab_ints.ci_alternate_code%TYPE,
                         cp_batch_id       igf_ap_li_fab_ints.batch_num%TYPE)
    IS
    SELECT  batch_num,
            award_process_status_code,
            ci_alternate_code,
            person_number,
            award_process_status_date,
            award_notify_status,
            award_notify_status_date,
            override_nslds_flag,
            professional_judgment_flag,
            disburse_verification_hold,
            import_status_type,
            ROWID ROW_ID
    FROM    igf_ap_li_fab_ints
    WHERE   ci_alternate_code = cp_alternate_code
    AND     batch_num = cp_batch_id
    AND     import_status_type IN ('U','R')
    ORDER BY person_number;


    l_get_records c_get_records%ROWTYPE;


    CURSOR c_baseid_exists(cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
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
            assoc_org_num,
            award_fmly_contribution_type,
            isir_locked_by,
	    adnl_unsub_loan_elig_flag,
            lock_awd_flag,
            lock_coa_flag
    FROM   igf_ap_fa_base_rec_all
    WHERE  base_id = cp_base_id;

    l_baseid_exists c_baseid_exists%ROWTYPE;


    CURSOR c_chk_legacy_awd(
                            cp_base_id  igf_aw_award_all.base_id%TYPE
                           )
    IS
    SELECT  base_id
    FROM   igf_aw_award_all
    WHERE  base_id = cp_base_id
    AND    rownum = 1;

    l_chk_legacy_awd  c_chk_legacy_awd%ROWTYPE;

    -- cursor to get the ssn no of a person
    CURSOR ssn_cur(cp_person_id number) IS
    SELECT api_person_id,api_person_id_uf, end_dt
    FROM   igs_pe_alt_pers_id
    WHERE  pe_person_id=cp_person_id
    AND    person_id_type like 'SSN'
    AND    SYSDATE < = NVL(end_dt,SYSDATE);

    rec_ssn_cur ssn_cur%ROWTYPE;
    lv_profile_value VARCHAR2(20);

  BEGIN
	igf_aw_gen.set_org_id(NULL);
    errbuf             := NULL;
    retcode            := 0;
    l_cal_type         := LTRIM(RTRIM(SUBSTR(p_award_year,1,10)));
    l_seq_number       := TO_NUMBER(SUBSTR(p_award_year,11));

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','l_cal_type:'||l_cal_type);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','l_seq_number:'||l_seq_number);
    END IF;

    l_error := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','ERROR');
    l_chk_profile := igf_ap_gen.check_profile;
    IF l_chk_profile = 'N' THEN
      fnd_message.set_name('IGF','IGF_AP_LGCY_PROC_NOT_RUN');
      fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
      RETURN;
    END IF;

    l_chk_batch := igf_ap_gen.check_batch(p_batch_id,'BASE');
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

    IF l_get_status.award_year_status_code IS NULL OR l_get_status.award_year_status_code IN ('C') THEN
      fnd_message.set_name('IGF','IGF_AP_LG_INVALID_STAT');
      fnd_message.set_token('AWARD_STATUS',l_get_status.award_year_status_code);
      add_log_table_process(NULL,l_error,fnd_message.get);
      l_terminate_flag := TRUE;
    END IF;

    IF l_terminate_flag = TRUE THEN
      print_log_process(l_get_alternate_code.alternate_code,p_batch_id,p_del_ind,l_get_status.award_year_status_code);
      RETURN;
    END IF;

    -- THE MAIN LOOP STARTS HERE FOR FETCHING THE RECORD FROM THE INTERFACE TABLE
    OPEN c_get_records(l_get_alternate_code.alternate_code,p_batch_id);
    LOOP
      BEGIN
      SAVEPOINT sp1;
      FETCH c_get_records INTO l_get_records;
      EXIT WHEN c_get_records%NOTFOUND;
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        l_debug_str := 'Person Number is:' || l_get_records.person_number;
      END IF;

      lv_base_id    := NULL;
      lv_person_id  := NULL;
      l_create_flag := FALSE;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','Calling igf_ap_gen.check_person');
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','l_get_records.person_number:'||l_get_records.person_number);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','l_cal_type:'||l_cal_type);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','l_seq_number:'||l_seq_number);
      END IF;
      igf_ap_gen.check_person(l_get_records.person_number,l_cal_type,l_seq_number,lv_person_id,lv_base_id);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','lv_person_id:'||lv_person_id);
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','lv_base_id:'||lv_base_id);
      END IF;

      IF lv_person_id IS NULL THEN
        fnd_message.set_name('IGF','IGF_AP_PE_NOT_EXIST');
        add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
        l_error_flag := TRUE;
      ELSE
        IF lv_base_id IS NULL THEN
          l_create_flag := TRUE;
        END IF;
      END IF;

      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       l_debug_str := l_debug_str || ' Person and Base ID check passed';
      END IF;

      l_baseid_exists := NULL;
      IF NOT l_create_flag THEN
        OPEN  c_baseid_exists(lv_base_id);
        FETCH c_baseid_exists INTO l_baseid_exists;
        CLOSE c_baseid_exists;
      END IF;

      -- HERE ALL THE VALIDATIONS TO BE DONE AT ONE GO
      -- VALIDATION FOR THE AWARD PROCESS STATUS DATE
      IF l_get_records.award_process_status_date IS NOT NULL AND l_get_records.award_process_status_date > TRUNC(SYSDATE) THEN
        fnd_message.set_name('IGF','IGF_AP_LI_APS_DT_INVALID');
        fnd_message.set_token('APS_DT',l_get_records.award_process_status_date);
        add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
        l_error_flag := TRUE;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','Award process status date is invalid');
        END IF;
      END IF;

      -- VALIDATION FOR THE AWARD NOTIFICATION STATUS NULL IS ALSO VALID
      IF NVL(l_get_records.award_notify_status,'S') NOT IN ('S','R','D') THEN
        fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
        fnd_message.set_token('FIELD','AWARD_NOTIFY_STATUS');
        add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
        l_error_flag := TRUE;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','Award notification status is invalid');
        END IF;
      END IF;

      -- VALIDATION FOR AWARD NOTIFICATION STATUS DATE
      IF l_get_records.award_notify_status_date IS NOT NULL AND l_get_records.award_notify_status_date > TRUNC(SYSDATE) THEN
        fnd_message.set_name('IGF','IGF_AP_LI_ANS_DT_INVALID');
        fnd_message.set_token('AWD_NOT_STAT_DT',l_get_records.award_notify_status_date);
        add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
        l_error_flag := TRUE;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','Award notification status date in invalid');
        END IF;
      END IF;

      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        l_debug_str := l_debug_str || ' AWARD PROCESS AND NOTIFICATION STATUS DATE passed';
      END IF;

      -- VALIDATION FOR OVERRIDE NSLDS DEFAULT
      IF NVL(l_get_records.override_nslds_flag,'X') NOT IN ('Y','N') THEN
        fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
        fnd_message.set_token('FIELD','OVERRIDE_NSLDS_FLAG');
        add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
        l_error_flag := TRUE;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','Override NSLDS flag value is invalid');
        END IF;
      END IF;

      -- VALIDATION FOR PROFESSIONAL JUDGEMENT
      IF NVL(l_get_records.professional_judgment_flag,'X') NOT IN ('Y','N') THEN
         fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
        fnd_message.set_token('FIELD','PROFESSIONAL_JUDGMENT_FLAG');
        add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
        l_error_flag := TRUE;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','Professional Judgement flag value is invalid');
        END IF;
      END IF;

      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        l_debug_str := l_debug_str || ' PROFESSIONAL JUDGEMENT passed';
      END IF;

      -- VALIDATION FOR VERIFICATION HOLD ON DISBURSEMENT
      IF NVL(l_get_records.disburse_verification_hold,'X') NOT IN ('Y','N') THEN
         fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
        fnd_message.set_token('FIELD','DISBURSE_VERIFICATION_HOLD');
        add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
        l_error_flag := TRUE;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','Disburse verification flag value is invalid');
        END IF;
      END IF;

      -- VALIDATION FOR AWARD PROCESS STATUS NULL IS ALSO VALID
      IF NVL(l_get_records.award_process_status_code,'REVISED') NOT IN ('REVISED','AUTO_PACKAGED') THEN
         fnd_message.set_name('IGF','IGF_AP_INV_FLD_VAL');
        fnd_message.set_token('FIELD','AWARD_PROCESS_STATUS_CODE');
        add_log_table_process(l_get_records.person_number,l_error,fnd_message.get);
        l_error_flag := TRUE;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','award process status is invalid');
        END IF;
      END IF;

      l_process_status := NULL;
      l_process_date   := NULL;
      IF NOT l_create_flag THEN
        l_process_status := l_baseid_exists.packaging_status;
        l_process_date   := l_baseid_exists.packaging_status_date;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','l_process_status:'||l_process_status);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','l_process_date:'||l_process_date);
        END IF;
      ELSE
        l_process_status := l_get_records.award_process_status_code;
        l_process_date   := l_get_records.award_process_status_date;
      END IF;

      IF l_process_status IS NULL THEN
        -- if the student in context has legacy awards then update the process status
        IF NOT l_create_flag THEN
          l_chk_legacy_awd := NULL;
          OPEN  c_chk_legacy_awd(lv_base_id);
          FETCH c_chk_legacy_awd INTO l_chk_legacy_awd;
          CLOSE c_chk_legacy_awd;
          IF l_chk_legacy_awd.base_id IS NOT NULL THEN
            l_process_status := l_get_records.award_process_status_code;
            l_process_date   := l_get_records.award_process_status_date;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','l_chk_legacy_awd.base_id:'||l_chk_legacy_awd.base_id);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','l_process_status:'||l_process_status);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','l_process_date:'||l_process_date);
            END IF;
          END IF;
        END IF;
      END IF;

      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        l_debug_str := l_debug_str || ' AWARD PROCESS STATUS passed';
      END IF;

      IF NOT l_error_flag THEN
        IF NOT l_create_flag THEN
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','l_create_flag:FALSE');
          END IF;
          -- update the fa base record
          igf_ap_fa_base_rec_pkg.update_row(
                             x_Mode                                   => 'R' ,
                             x_rowid                                  => l_baseid_exists.row_id ,
                             x_base_id                                => l_baseid_exists.base_id ,
                             x_ci_cal_type                            => l_baseid_exists.ci_cal_type ,
                             x_person_id                              => l_baseid_exists.person_id ,
                             x_ci_sequence_number                     => l_baseid_exists.ci_sequence_number ,
                             x_org_id                                 => l_baseid_exists.org_id ,
                             x_coa_pending                            => l_baseid_exists.coa_pending ,
                             x_verification_process_run               => l_baseid_exists.verification_process_run ,
                             x_inst_verif_status_date                 => l_baseid_exists.inst_verif_status_date ,
                             x_manual_verif_flag                      => l_baseid_exists.manual_verif_flag ,
                             x_fed_verif_status                       => l_baseid_exists.fed_verif_status ,
                             x_fed_verif_status_date                  => l_baseid_exists.fed_verif_status_date ,
                             x_inst_verif_status                      => l_baseid_exists.inst_verif_status ,
                             x_nslds_eligible                         => l_baseid_exists.nslds_eligible ,
                             x_ede_correction_batch_id                => l_baseid_exists.ede_correction_batch_id ,
                             x_fa_process_status_date                 => l_baseid_exists.fa_process_status_date  ,
                             x_isir_corr_status                       => l_baseid_exists.isir_corr_status ,
                             x_isir_corr_status_date                  => l_baseid_exists.isir_corr_status_date ,
                             x_isir_status                            => l_baseid_exists.isir_status ,
                             x_isir_status_date                       => l_baseid_exists.isir_status_date ,
                             x_coa_code_f                             => l_baseid_exists.coa_code_f ,
                             x_coa_code_i                             => l_baseid_exists.coa_code_i ,
                             x_coa_f                                  => l_baseid_exists.coa_f ,
                             x_coa_i                                  => l_baseid_exists.coa_i ,
                             x_disbursement_hold                      => l_baseid_exists.disbursement_hold ,
                             x_fa_process_status                      => l_baseid_exists.fa_process_status  ,
                             x_notification_status                    => NULL, --l_get_records.award_notify_status ,
                             x_notification_status_date               => NULL, --l_get_records.award_notify_status_date ,
                             x_packaging_status                       => l_process_status ,
                             x_packaging_status_date                  => l_process_date ,
                             x_total_package_accepted                 => l_baseid_exists.total_package_accepted ,
                             x_total_package_offered                  => l_baseid_exists.total_package_offered ,
                             x_admstruct_id                           => l_baseid_exists.admstruct_id ,
                             x_admsegment_1                           => l_baseid_exists.admsegment_1 ,
                             x_admsegment_2                           => l_baseid_exists.admsegment_2 ,
                             x_admsegment_3                           => l_baseid_exists.admsegment_3 ,
                             x_admsegment_4                           => l_baseid_exists.admsegment_4 ,
                             x_admsegment_5                           => l_baseid_exists.admsegment_5 ,
                             x_admsegment_6                           => l_baseid_exists.admsegment_6 ,
                             x_admsegment_7                           => l_baseid_exists.admsegment_7 ,
                             x_admsegment_8                           => l_baseid_exists.admsegment_8 ,
                             x_admsegment_9                           => l_baseid_exists.admsegment_9 ,
                             x_admsegment_10                          => l_baseid_exists.admsegment_10 ,
                             x_admsegment_11                          => l_baseid_exists.admsegment_11 ,
                             x_admsegment_12                          => l_baseid_exists.admsegment_12 ,
                             x_admsegment_13                          => l_baseid_exists.admsegment_13 ,
                             x_admsegment_14                          => l_baseid_exists.admsegment_14 ,
                             x_admsegment_15                          => l_baseid_exists.admsegment_15 ,
                             x_admsegment_16                          => l_baseid_exists.admsegment_16 ,
                             x_admsegment_17                          => l_baseid_exists.admsegment_17 ,
                             x_admsegment_18                          => l_baseid_exists.admsegment_18 ,
                             x_admsegment_19                          => l_baseid_exists.admsegment_19 ,
                             x_admsegment_20                          => l_baseid_exists.admsegment_20 ,
                             x_packstruct_id                          => l_baseid_exists.packstruct_id ,
                             x_packsegment_1                          => l_baseid_exists.packsegment_1 ,
                             x_packsegment_2                          => l_baseid_exists.packsegment_2 ,
                             x_packsegment_3                          => l_baseid_exists.packsegment_3 ,
                             x_packsegment_4                          => l_baseid_exists.packsegment_4 ,
                             x_packsegment_5                          => l_baseid_exists.packsegment_5 ,
                             x_packsegment_6                          => l_baseid_exists.packsegment_6 ,
                             x_packsegment_7                          => l_baseid_exists.packsegment_7 ,
                             x_packsegment_8                          => l_baseid_exists.packsegment_8 ,
                             x_packsegment_9                          => l_baseid_exists.packsegment_9 ,
                             x_packsegment_10                         => l_baseid_exists.packsegment_10 ,
                             x_packsegment_11                         => l_baseid_exists.packsegment_11 ,
                             x_packsegment_12                         => l_baseid_exists.packsegment_12 ,
                             x_packsegment_13                         => l_baseid_exists.packsegment_13 ,
                             x_packsegment_14                         => l_baseid_exists.packsegment_14 ,
                             x_packsegment_15                         => l_baseid_exists.packsegment_15 ,
                             x_packsegment_16                         => l_baseid_exists.packsegment_16 ,
                             x_packsegment_17                         => l_baseid_exists.packsegment_17 ,
                             x_packsegment_18                         => l_baseid_exists.packsegment_18 ,
                             x_packsegment_19                         => l_baseid_exists.packsegment_19 ,
                             x_packsegment_20                         => l_baseid_exists.packsegment_20 ,
                             x_miscstruct_id                          => l_baseid_exists.miscstruct_id ,
                             x_miscsegment_1                          => l_baseid_exists.miscsegment_1 ,
                             x_miscsegment_2                          => l_baseid_exists.miscsegment_2 ,
                             x_miscsegment_3                          => l_baseid_exists.miscsegment_3 ,
                             x_miscsegment_4                          => l_baseid_exists.miscsegment_4 ,
                             x_miscsegment_5                          => l_baseid_exists.miscsegment_5 ,
                             x_miscsegment_6                          => l_baseid_exists.miscsegment_6 ,
                             x_miscsegment_7                          => l_baseid_exists.miscsegment_7 ,
                             x_miscsegment_8                          => l_baseid_exists.miscsegment_8 ,
                             x_miscsegment_9                          => l_baseid_exists.miscsegment_9 ,
                             x_miscsegment_10                         => l_baseid_exists.miscsegment_10 ,
                             x_miscsegment_11                         => l_baseid_exists.miscsegment_11 ,
                             x_miscsegment_12                         => l_baseid_exists.miscsegment_12 ,
                             x_miscsegment_13                         => l_baseid_exists.miscsegment_13 ,
                             x_miscsegment_14                         => l_baseid_exists.miscsegment_14 ,
                             x_miscsegment_15                         => l_baseid_exists.miscsegment_15 ,
                             x_miscsegment_16                         => l_baseid_exists.miscsegment_16 ,
                             x_miscsegment_17                         => l_baseid_exists.miscsegment_17 ,
                             x_miscsegment_18                         => l_baseid_exists.miscsegment_18 ,
                             x_miscsegment_19                         => l_baseid_exists.miscsegment_19 ,
                             x_miscsegment_20                         => l_baseid_exists.miscsegment_20 ,
                             x_prof_judgement_flg                     => l_get_records.professional_judgment_flag ,
                             x_nslds_data_override_flg                => l_get_records.override_nslds_flag ,
                             x_target_group                           => l_baseid_exists.target_group ,
                             x_coa_fixed                              => l_baseid_exists.coa_fixed ,
                             x_coa_pell                               => l_baseid_exists.coa_pell ,
                             x_profile_status                         => l_baseid_exists.profile_status ,
                             x_profile_status_date                    => l_baseid_exists.profile_status_date ,
                             x_profile_fc                             => l_baseid_exists.profile_fc ,
                             x_manual_disb_hold                       => l_get_records.disburse_verification_hold,
                             x_pell_alt_expense                       => l_baseid_exists.pell_alt_expense,
                             x_assoc_org_num                          => l_baseid_exists.assoc_org_num,
                             x_award_fmly_contribution_type           => l_baseid_exists.award_fmly_contribution_type,
                             x_isir_locked_by                         => l_baseid_exists.isir_locked_by,
			                       x_adnl_unsub_loan_elig_flag              => l_baseid_exists.adnl_unsub_loan_elig_flag,
                             x_lock_awd_flag                          => l_baseid_exists.lock_awd_flag,
                             x_lock_coa_flag                          => l_baseid_exists.lock_coa_flag
                             );
        ELSE
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','l_create_flag:TRUE');
          END IF;
          --insert new base record
          l_base_id  := NULL;
          l_row_id   := NULL;

     --check if the ssn no is available or not

      fnd_profile.get('IGF_AP_SSN_REQ_FOR_BASE_REC',lv_profile_value);

      l_create_base_rec := TRUE;
      IF(lv_profile_value = 'Y') THEN
      OPEN ssn_cur(lv_person_id) ;
      FETCH ssn_cur INTO rec_ssn_cur;
       IF ssn_cur%NOTFOUND THEN
       CLOSE ssn_cur;
       fnd_message.set_name('IGF','IGF_AP_SSN_REQD');
       FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
       l_create_base_rec := FALSE;
       l_error_flag := FALSE;
       ELSE
        CLOSE ssn_cur;
       l_create_base_rec := TRUE;
       END IF;
       END IF;

     IF l_create_base_rec THEN
         igf_ap_fa_base_rec_pkg.insert_row(
                             x_Mode                                   => 'R' ,
                             x_rowid                                  => l_row_id ,
                             x_base_id                                => l_base_id ,
                             x_ci_cal_type                            => l_cal_type ,
                             x_person_id                              => lv_person_id ,
                             x_ci_sequence_number                     => l_seq_number ,
                             x_org_id                                 => NULL,
                             x_coa_pending                            => NULL,
                             x_verification_process_run               => NULL,
                             x_inst_verif_status_date                 => NULL,
                             x_manual_verif_flag                      => NULL,
                             x_fed_verif_status                       => NULL,
                             x_fed_verif_status_date                  => NULL,
                             x_inst_verif_status                      => NULL,
                             x_nslds_eligible                         => NULL,
                             x_ede_correction_batch_id                => NULL,
                             x_fa_process_status_date                 => NULL,
                             x_isir_corr_status                       => NULL,
                             x_isir_corr_status_date                  => NULL,
                             x_isir_status                            => NULL,
                             x_isir_status_date                       => NULL,
                             x_coa_code_f                             => NULL,
                             x_coa_code_i                             => NULL,
                             x_coa_f                                  => NULL,
                             x_coa_i                                  => NULL,
                             x_disbursement_hold                      => NULL,
                             x_fa_process_status                      => NULL,
                             x_notification_status                    => NULL, --l_get_records.award_notify_status ,
                             x_notification_status_date               => NULL, --l_get_records.award_notify_status_date ,
                             x_packaging_status                       => l_process_status ,
                             x_packaging_status_date                  => l_process_date ,
                             x_total_package_accepted                 => NULL,
                             x_total_package_offered                  => NULL,
                             x_admstruct_id                           => NULL,
                             x_admsegment_1                           => NULL,
                             x_admsegment_2                           => NULL,
                             x_admsegment_3                           => NULL,
                             x_admsegment_4                           => NULL,
                             x_admsegment_5                           => NULL,
                             x_admsegment_6                           => NULL,
                             x_admsegment_7                           => NULL,
                             x_admsegment_8                           => NULL,
                             x_admsegment_9                           => NULL,
                             x_admsegment_10                          => NULL,
                             x_admsegment_11                          => NULL,
                             x_admsegment_12                          => NULL,
                             x_admsegment_13                          => NULL,
                             x_admsegment_14                          => NULL,
                             x_admsegment_15                          => NULL,
                             x_admsegment_16                          => NULL,
                             x_admsegment_17                          => NULL,
                             x_admsegment_18                          => NULL,
                             x_admsegment_19                          => NULL,
                             x_admsegment_20                          => NULL,
                             x_packstruct_id                          => NULL,
                             x_packsegment_1                          => NULL,
                             x_packsegment_2                          => NULL,
                             x_packsegment_3                          => NULL,
                             x_packsegment_4                          => NULL,
                             x_packsegment_5                          => NULL,
                             x_packsegment_6                          => NULL,
                             x_packsegment_7                          => NULL,
                             x_packsegment_8                          => NULL,
                             x_packsegment_9                          => NULL,
                             x_packsegment_10                         => NULL,
                             x_packsegment_11                         => NULL,
                             x_packsegment_12                         => NULL,
                             x_packsegment_13                         => NULL,
                             x_packsegment_14                         => NULL,
                             x_packsegment_15                         => NULL,
                             x_packsegment_16                         => NULL,
                             x_packsegment_17                         => NULL,
                             x_packsegment_18                         => NULL,
                             x_packsegment_19                         => NULL,
                             x_packsegment_20                         => NULL,
                             x_miscstruct_id                          => NULL,
                             x_miscsegment_1                          => NULL,
                             x_miscsegment_2                          => NULL,
                             x_miscsegment_3                          => NULL,
                             x_miscsegment_4                          => NULL,
                             x_miscsegment_5                          => NULL,
                             x_miscsegment_6                          => NULL,
                             x_miscsegment_7                          => NULL,
                             x_miscsegment_8                          => NULL,
                             x_miscsegment_9                          => NULL,
                             x_miscsegment_10                         => NULL,
                             x_miscsegment_11                         => NULL,
                             x_miscsegment_12                         => NULL,
                             x_miscsegment_13                         => NULL,
                             x_miscsegment_14                         => NULL,
                             x_miscsegment_15                         => NULL,
                             x_miscsegment_16                         => NULL,
                             x_miscsegment_17                         => NULL,
                             x_miscsegment_18                         => NULL,
                             x_miscsegment_19                         => NULL,
                             x_miscsegment_20                         => NULL,
                             x_prof_judgement_flg                     => l_get_records.professional_judgment_flag ,
                             x_nslds_data_override_flg                => l_get_records.override_nslds_flag ,
                             x_target_group                           => NULL,
                             x_coa_fixed                              => NULL,
                             x_coa_pell                               => NULL,
                             x_profile_status                         => NULL,
                             x_profile_status_date                    => NULL,
                             x_profile_fc                             => NULL,
                             x_manual_disb_hold                       => l_get_records.disburse_verification_hold,
                             x_pell_alt_expense                       => NULL,
                             x_assoc_org_num                          => NULL,
                             x_award_fmly_contribution_type           => '1',
                             x_isir_locked_by                         => NULL,
			                       x_adnl_unsub_loan_elig_flag              => 'N',
                             x_lock_awd_flag                          => 'N',
                             x_lock_coa_flag                          => 'N'

                             );

         END IF;

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','l_base_id:'||l_base_id);
          END IF;
        END IF;
        fnd_message.set_name('IGS','IGS_EN_LGCY_SUCCESS');
        add_log_table_process(l_get_records.person_number,' ',fnd_message.get);
        l_success_record_cnt := l_success_record_cnt + 1;
      END IF; -- ERROR FLAG CHECK


      IF l_error_flag = TRUE THEN
        l_error_flag := FALSE;
        l_error_record_cnt := l_error_record_cnt + 1;
        --update the legacy interface table column import_status to 'E'
        UPDATE igf_ap_li_fab_ints
        SET import_status_type = 'E',
            last_updated_by        = fnd_global.user_id,
            last_update_date       = SYSDATE,
            last_update_login      = fnd_global.login_id,
            request_id             = fnd_global.conc_request_id,
            program_id             = fnd_global.conc_program_id,
            program_application_id = fnd_global.prog_appl_id,
            program_update_date    = SYSDATE
        WHERE ROWID = l_get_records.ROW_ID;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','updating igf_ap_li_fa_ints(E) with rowid:'||l_get_records.ROW_ID);
        END IF;
      ELSE
        IF p_del_ind = 'Y' THEN
           DELETE FROM igf_ap_li_fab_ints
           WHERE ROWID = l_get_records.ROW_ID;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','deleting igf_ap_li_fa_ints with rowid:'||l_get_records.ROW_ID);
          END IF;
        ELSE
           --update the legacy interface table column import_status to 'I'
           UPDATE igf_ap_li_fab_ints
           SET import_status_type = 'I',
               last_updated_by        = fnd_global.user_id,
               last_update_date       = SYSDATE,
               last_update_login      = fnd_global.login_id,
               request_id             = fnd_global.conc_request_id,
               program_id             = fnd_global.conc_program_id,
               program_application_id = fnd_global.prog_appl_id,
               program_update_date    = SYSDATE
           WHERE ROWID = l_get_records.ROW_ID;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_base_rec_import.main.debug','updating igf_ap_li_fa_ints(I) with rowid:'||l_get_records.ROW_ID);
          END IF;
        END IF;
      END IF;
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_li_base_rec_import.main.debug',l_debug_str);
      END IF;

      l_debug_str := NULL;
      EXCEPTION
       WHEN others THEN
         l_debug_str := NULL;
         l_error_flag := FALSE;
         fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
         fnd_message.set_token('NAME','IGF_AP_LI_BASE_REC_IMPORT.MAIN');
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
    print_log_process(l_get_alternate_code.alternate_code,p_batch_id,p_del_ind,l_get_status.award_year_status_code);

    l_total_record_cnt := l_success_record_cnt + l_error_record_cnt;
    fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_PROCESSED');
    fnd_file.put_line(fnd_file.OUTPUT,fnd_message.get || ' ' || l_total_record_cnt);
    fnd_message.set_name('IGS','IGS_AD_SUCC_IMP_OFR_RESP_REC');
    fnd_file.put_line(fnd_file.OUTPUT,fnd_message.get || ' : ' || l_success_record_cnt);
    fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_FAILED');
    fnd_file.put_line(fnd_file.OUTPUT,fnd_message.get || ' : ' || l_error_record_cnt);
  EXCEPTION
        WHEN others THEN
        IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'igf.plsql.igf_ap_li_base_rec_import.main.exception',SQLERRM);
        END IF;
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AP_LI_BASE_REC_IMPORT.MAIN');
        errbuf  := fnd_message.get;
        igs_ge_msg_stack.conc_exception_hndl;

  END main;


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
    g_log_tab(g_log_tab_index).message_text := RPAD('',12) || p_message_str;

  END add_log_table_process;

  PROCEDURE print_log_process(
                              p_alternate_code     IN VARCHAR2,
                              p_batch_id           IN  NUMBER,
                              p_del_ind            IN VARCHAR2,
                              p_awd_yr_status      IN VARCHAR2
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
    l_print_message_flag BOOLEAN := TRUE;
    l_old_person igf_ap_li_css_act_ints.person_number%TYPE := '*******';

    l_person_number   VARCHAR2(80);
    l_batch_id        VARCHAR2(80);
    l_award_yr        VARCHAR2(80);
    l_batch_desc      VARCHAR2(80);
    l_yes_no          VARCHAR2(10);
    l_param_passed    VARCHAR2(80);
    l_award_yr_status VARCHAR2(80);

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
    l_param_passed  := igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','PARAMETER_PASS');
    l_award_yr_status  := igf_ap_gen.get_lookup_meaning('IGF_AWARD_YEAR_STATUS',p_awd_yr_status);

    OPEN  c_get_batch_desc(p_batch_id);
    FETCH c_get_batch_desc INTO l_get_batch_desc;
    CLOSE c_get_batch_desc;
    l_batch_desc := l_get_batch_desc.batch_desc ;

     -- HERE THE INPUT PARAMETERS ARE TO BE LOGGED TO THE LOG FILE
    fnd_file.put_line(fnd_file.log,l_param_passed);
    fnd_file.put_line(fnd_file.log,RPAD(l_award_yr,50) || ' : ' || p_alternate_code);
    fnd_file.put_line(fnd_file.log,RPAD(l_batch_id,50) || ' : ' || p_batch_id || ' - ' || l_batch_desc);
    fnd_file.put_line(fnd_file.log,RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','DELETE_FLAG'),50) || ' : ' || l_yes_no);
    fnd_file.put_line(fnd_file.log,'------------------------------------------------------------------------------');
    fnd_file.put_line(fnd_file.log,RPAD(igf_ap_gen.get_lookup_meaning('IGF_GE_PARAMETERS','AWARD_YR_STATUS'),50) || ' : ' || l_award_yr_status);

    FOR i IN 1..l_count LOOP
      IF g_log_tab(i).person_number IS NOT NULL THEN
        IF l_old_person <> g_log_tab(i).person_number THEN
          IF i <> 1 AND l_print_message_flag THEN
            fnd_message.set_name('IGF','IGF_AW_LI_SKIPPING_AWD');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
          END IF;
          fnd_file.put_line(fnd_file.log,'---------------------------------------------------------------------------------');
          fnd_file.put_line(fnd_file.log,l_person_number || ' : ' || g_log_tab(i).person_number);

        END IF;
        l_old_person := g_log_tab(i).person_number;
      END IF;
      l_print_message_flag := TRUE;
      fnd_file.put_line(fnd_file.log,g_log_tab(i).message_text);
      IF g_log_tab(i).message_text = 'Record Successfully imported' THEN
        l_print_message_flag := FALSE;
      END IF;
    END LOOP;
    IF l_print_message_flag THEN
      fnd_message.set_name('IGF','IGF_AW_LI_SKIPPING_AWD');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
    END IF;

  END print_log_process;

END igf_ap_li_base_rec_import;

/
