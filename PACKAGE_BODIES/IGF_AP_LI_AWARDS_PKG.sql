--------------------------------------------------------
--  DDL for Package Body IGF_AP_LI_AWARDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_LI_AWARDS_PKG" AS
/* $Header: IGFAP37B.pls 120.4 2006/01/17 02:36:51 tsailaja ship $ */

g_log_tab_index   NUMBER := 0;

TYPE log_record IS RECORD
        ( person_number VARCHAR2(30),
          message_text VARCHAR2(500));

-- The PL/SQL table for storing the log messages
TYPE LogTab IS TABLE OF log_record
           index by binary_integer;

g_log_tab LogTab;


  PROCEDURE main_import_process ( errbuf          OUT NOCOPY VARCHAR2,
                                  retcode         OUT NOCOPY NUMBER,
                                  p_award_year    IN         VARCHAR2,
                                  p_batch_id      IN         NUMBER,
                                  p_del_ind       IN         VARCHAR2 )
    IS

    l_error_flag      BOOLEAN := FALSE;
    l_error           VARCHAR2(80);
    l_person_number   VARCHAR2(80);
    l_batch_id        VARCHAR2(80);
    lv_row_id         VARCHAR2(80) := NULL;
    lv_award_id       igf_aw_award.award_id%TYPE := NULL;
    lv_person_id      igs_pe_hz_parties.party_id%TYPE := NULL;
    lv_base_id        igf_aw_award.base_id%TYPE := NULL;
    l_del_message     VARCHAR2(200);
    l_batch_desc      VARCHAR2(80);
    l_yes_no          VARCHAR2(10);
    l_award_yr        VARCHAR2(80);
    l_success_record_cnt    NUMBER := 0;
    l_error_record_cnt      NUMBER := 0;
    l_message_str      VARCHAR2(50) := NULL;
    l_chk_profile     VARCHAR2(1) := 'N';
    l_chk_batch       VARCHAR2(1) := 'Y';
    l_debug_str       VARCHAR2(800) := NULL;
    l_total_record_cnt      NUMBER := 0;

    CURSOR c_get_batch_desc(cp_batch_num NUMBER) IS
    SELECT batch_desc
      FROM igf_ap_li_bat_ints
     WHERE batch_num = cp_batch_num;

    l_get_batch_desc c_get_batch_desc%ROWTYPE;

    CURSOR c_get_alternate_code(cp_cal_type VARCHAR2,
                                cp_seq_number NUMBER)
    IS
    SELECT alternate_code
    FROM   igs_ca_inst
    WHERE  cal_type = cp_cal_type
    AND    sequence_number = cp_seq_number;

    l_get_alternate_code  c_get_alternate_code%ROWTYPE;


    l_cal_type   igf_ap_fa_base_rec_all.ci_cal_type%TYPE ;
    l_seq_number igf_ap_fa_base_rec_all.ci_sequence_number%TYPE;

    -- Cursor for getting the context award year details
    CURSOR c_award_det(cp_cal_type VARCHAR2,
                       cp_seq_number NUMBER)
    IS
    SELECT batch_year,
           award_year_status_code,
           sys_award_year
    FROM   igf_ap_batch_aw_map
    WHERE  ci_cal_type = cp_cal_type
    AND    ci_sequence_number = cp_seq_number;

    l_award_det c_award_det%ROWTYPE;

    CURSOR c_interface(cp_batch_id NUMBER,
                       cp_alternate_code VARCHAR2)
    IS
    SELECT A.batch_num batch_id,
           A.agrint_id agrint_id,
           A.ci_alternate_code ci_alternate_code,
           A.person_number person_number,
           A.fund_code fund_code,
           A.offered_amt offrd_amt,
           A.accepted_amt accpt_amt,
           A.paid_amt paid_amt,
           A.import_status_type import_status,
           A.import_record_type import_record_type,
           A.ROWID ROW_ID
    FROM   igf_aw_li_agr_ints A
    WHERE  A.batch_num = cp_batch_id
    AND    A.ci_alternate_code = cp_alternate_code
    AND    A.import_status_type IN ('U','R')
    ORDER BY A.person_number;

    l_interface c_interface%ROWTYPE;

    CURSOR c_fund_exists(cp_cal_type VARCHAR2,
                         cp_seq_number NUMBER,
                         cp_fund_code VARCHAR2)
    IS
    SELECT fund_id
    FROM   igf_aw_fund_mast FM
    WHERE  FM.ci_cal_type = cp_cal_type
    AND    FM.ci_sequence_number = cp_seq_number
    AND    FM.fund_code = cp_fund_code ;

    l_fund_id c_fund_exists%ROWTYPE;

    CURSOR c_award_exists(cp_base_id NUMBER,
                          cp_fund_id NUMBER)
    IS
    SELECT award_id,
           AW.ROWID ROW_ID
    FROM   igf_aw_award AW
    WHERE  AW.base_id = cp_base_id
    AND    AW.fund_id = cp_fund_id;

    l_award_id c_award_exists%ROWTYPE;

    /*
    ||  Created By : bkkumar
    ||  Created On : 20-MAY-2003
    ||  Purpose : Main process which imports the legacy aggregate awards in the system. This process
    ||  validates the awards for the validity of the fund code and award amount. No disbursement level
    ||  data is captured.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
	||  tsailaja		  13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
    ||  bvisvana        11-Jul-2005     FA 157 and FA 140 - Added x_notification_status_code,x_notification_status_code,x_publish_in_ss_flag for TBH impact
    ||  veramach        1-NOV-2003      #3160568 Added adplans_id in the calls to igf_aw_award_pkg.insert_row and igf_aw_award_pkg.update_row
    ||  (reverse chronological order - newest change first)
    */

  BEGIN
    igf_aw_gen.set_org_id(NULL);
    errbuf             := NULL;
    retcode            := 0;
    l_cal_type         := LTRIM(RTRIM(SUBSTR(p_award_year,1,10)));
    l_seq_number       := TO_NUMBER(SUBSTR(p_award_year,11));

    l_error         := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','ERROR');

    l_chk_profile := igf_ap_gen.check_profile;
    IF l_chk_profile = 'N' THEN
      fnd_message.set_name('IGF','IGF_AP_LGCY_PROC_NOT_RUN');
      fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
      RETURN;
    END IF;

    l_person_number := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','PERSON_NUMBER');
    l_batch_id      := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','BATCH_ID');
    l_award_yr      := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','AWARD_YEAR');
    l_yes_no        := igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_del_ind);

    OPEN  c_get_batch_desc(p_batch_id);
    FETCH c_get_batch_desc INTO l_get_batch_desc;
    CLOSE c_get_batch_desc;
    l_batch_desc := l_get_batch_desc.batch_desc ;

    -- this is to get the alternate code
    l_get_alternate_code := NULL;
    OPEN  c_get_alternate_code(l_cal_type,l_seq_number);
    FETCH c_get_alternate_code INTO l_get_alternate_code;
    CLOSE c_get_alternate_code;

    -- HERE THE INPUT PARAMETERS ARE TO BE LOGGED TO THE LOG FILE
    fnd_message.set_name('IGS','IGS_DA_JOB');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    fnd_file.put_line(fnd_file.log,l_batch_id || ' : ' || p_batch_id || ' - ' || l_batch_desc);
    fnd_file.put_line(fnd_file.log,l_award_yr || ' : ' || l_get_alternate_code.alternate_code);
    fnd_message.set_name('IGS','IGS_GE_ASK_DEL_REC');
    fnd_file.put_line(fnd_file.log,fnd_message.get || ' : ' || l_yes_no);
    fnd_file.put_line(fnd_file.log,'------------------------------------------------------------------------------');

    l_chk_batch := igf_ap_gen.check_batch(p_batch_id,'AWG');
    IF l_chk_batch = 'N' THEN
      fnd_message.set_name('IGF','IGF_GR_BATCH_DOES_NOT_EXIST');
      fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
      RETURN;
    END IF;

    OPEN  c_award_det(l_cal_type,l_seq_number);
    FETCH c_award_det INTO l_award_det;
    CLOSE c_award_det;

    IF l_award_det.award_year_status_code NOT IN('LA','LE') THEN
      fnd_message.set_name('IGF','IGF_AP_LG_INVALID_STAT');
      fnd_message.set_token('AWARD_STATUS',l_award_det.award_year_status_code);
      fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
      RETURN;
    END IF;

    -- NOW ONLY PERSON LEVEL MESSGAES WILL BE LOGGED

    FOR l_interface IN c_interface(p_batch_id,l_get_alternate_code.alternate_code) LOOP
     BEGIN
      SAVEPOINT sp1;
      l_fund_id := NULL;
      OPEN c_fund_exists(l_cal_type,l_seq_number,l_interface.fund_code);
      FETCH c_fund_exists INTO l_fund_id;
      CLOSE c_fund_exists;
      IF l_fund_id.fund_id IS NULL THEN
        fnd_message.set_name('IGF','IGF_AW_PK_FUND_NOT_EXIST');
        fnd_message.set_token('FUND_ID',l_interface.fund_code);
        g_log_tab_index := g_log_tab_index + 1;
        g_log_tab(g_log_tab_index).person_number := l_interface.person_number;
        g_log_tab(g_log_tab_index).message_text := RPAD(l_error,12) || fnd_message.get;
        l_error_flag := TRUE;
      END IF;
      l_debug_str := 'Agrint_id is:' || l_interface.agrint_id || 'Fund exists passed';
      lv_base_id := NULL;
      lv_person_id := NULL;
      --HERE CALL TO THE GENERIC WRAPPER IS BEING MADE TO CHEHK THE VALIDITY OF THE PEROSN AND BASE ID
      igf_ap_gen.check_person(l_interface.person_number,l_cal_type,l_seq_number,lv_person_id,lv_base_id);
      IF lv_person_id IS NULL THEN
        fnd_message.set_name('IGF','IGF_AP_PE_NOT_EXIST');
        g_log_tab_index := g_log_tab_index + 1;
        g_log_tab(g_log_tab_index).person_number := l_interface.person_number;
        g_log_tab(g_log_tab_index).message_text := RPAD(l_error,12) || fnd_message.get;
        l_error_flag := TRUE;
      ELSE
        l_debug_str := l_debug_str || ' Pesron ID exists passed';
        IF lv_base_id IS NULL THEN
          fnd_message.set_name('IGF','IGF_AP_FABASE_NOT_FOUND');
          g_log_tab_index := g_log_tab_index + 1;
          g_log_tab(g_log_tab_index).person_number := l_interface.person_number;
          g_log_tab(g_log_tab_index).message_text := RPAD(l_error,12) || fnd_message.get;
          l_error_flag := TRUE;
        ELSE -- IF THE BASE ID IS NOT NULL
          l_debug_str := l_debug_str || ' Base ID exists passed';
          IF l_fund_id.fund_id IS NOT NULL THEN
            l_award_id := NULL;
            OPEN c_award_exists(lv_base_id,l_fund_id.fund_id);
            FETCH c_award_exists INTO l_award_id;
            CLOSE c_award_exists;
             -- here check whether any amount if exists is negative then just skip that record
            IF l_interface.offrd_amt < 0 OR (l_interface.accpt_amt IS NOT NULL AND l_interface.accpt_amt < 0) OR (l_interface.paid_amt IS NOT NULL AND l_interface.paid_amt < 0) THEN
              fnd_message.set_name('IGF','IGF_SE_FUND_CODE');
              fnd_message.set_token('TOKEN',l_interface.fund_code);
              l_message_str := RPAD(l_error,12) || fnd_message.get;
              fnd_message.set_name('IGS','IGS_AD_SS_NO_NEGATIVE');
              g_log_tab_index := g_log_tab_index + 1;
              g_log_tab(g_log_tab_index).person_number := l_interface.person_number;
              g_log_tab(g_log_tab_index).message_text := l_message_str || ' ' || fnd_message.get;
              l_message_str := NULL;
              l_error_flag := TRUE;
            END IF;
            IF l_interface.offrd_amt = 0 THEN
              fnd_message.set_name('IGF','IGF_SE_FUND_CODE');
              fnd_message.set_token('TOKEN',l_interface.fund_code);
              l_message_str := RPAD(l_error,12) || fnd_message.get;
              fnd_message.set_name('IGF','IGF_AW_OFF_AMT_NO_ZERO');
              g_log_tab_index := g_log_tab_index + 1;
              g_log_tab(g_log_tab_index).person_number := l_interface.person_number;
              g_log_tab(g_log_tab_index).message_text := l_message_str || ' ' || fnd_message.get;
              l_message_str := NULL;
              l_error_flag := TRUE;
            END IF;
            -- IF ACCEPTED IS GREATER THAN OFFERED THEN LOG A MESSAGE
            IF l_interface.accpt_amt IS NOT NULL AND l_interface.accpt_amt > l_interface.offrd_amt THEN
              fnd_message.set_name('IGF','IGF_SE_FUND_CODE');
              fnd_message.set_token('TOKEN',l_interface.fund_code);
              l_message_str := RPAD(l_error,12) || fnd_message.get;
              fnd_message.set_name('IGF','IGF_AW_CHECK_OFFR_ACCEP');
              g_log_tab_index := g_log_tab_index + 1;
              g_log_tab(g_log_tab_index).person_number := l_interface.person_number;
              g_log_tab(g_log_tab_index).message_text := l_message_str || ' ' || fnd_message.get;
              l_message_str := NULL;
              l_error_flag := TRUE;
            END IF;
            -- IF PAID AMT IS GREATER THAN ACCEPTED AMT THEN LOG A MESSAGE
            IF NVL(l_interface.paid_amt,0) > NVL(l_interface.accpt_amt,0) THEN
              fnd_message.set_name('IGF','IGF_SE_FUND_CODE');
              fnd_message.set_token('TOKEN',l_interface.fund_code);
              l_message_str := RPAD(l_error,12) || fnd_message.get;
              fnd_message.set_name('IGF','IGF_AW_CHECK_ACCEP_PAID');
              g_log_tab_index := g_log_tab_index + 1;
              g_log_tab(g_log_tab_index).person_number := l_interface.person_number;
              g_log_tab(g_log_tab_index).message_text := l_message_str || ' ' || fnd_message.get;
              l_message_str := NULL;
              l_error_flag := TRUE;
            END IF;
            IF l_award_id.award_id IS NULL  THEN
              IF NVL(l_interface.import_record_type,'X') = 'U' THEN  -- AS THE AWARD DOES NOT EXIST SO IT CAN NOT BE UPDATED
                fnd_message.set_name('IGF','IGF_SE_FUND_CODE');
                fnd_message.set_token('TOKEN',l_interface.fund_code);
                l_message_str := RPAD(l_error,12) || fnd_message.get;
                fnd_message.set_name('IGF','IGF_AP_ORIG_REC_NOT_FOUND');
                g_log_tab_index := g_log_tab_index + 1;
                g_log_tab(g_log_tab_index).person_number := l_interface.person_number;
                g_log_tab(g_log_tab_index).message_text := l_message_str || ' ' || fnd_message.get;
                l_error_flag := TRUE;
              ELSE
                -- THE RECORD HAS TO BE INSERTED IN THE AWARD TABLE AS THE AWARD DOES NOT EXIST
                IF l_error_flag = FALSE THEN
                  igf_aw_award_pkg.insert_row(
                         x_mode                     => 'R',
                         x_award_id                 => lv_award_id,
                         x_fund_id                  => l_fund_id.fund_id,
                         x_base_id                  => lv_base_id,
                         x_rowid                    => lv_row_id,
                         x_offered_amt              => l_interface.offrd_amt,
                         x_accepted_amt             => l_interface.accpt_amt,
                         x_paid_amt                 => l_interface.paid_amt,
                         x_batch_id                 => l_interface.batch_id,
                         x_packaging_type           => NULL,
                         x_manual_update            => NULL,
                         x_rules_override           => NULL,
                         x_award_date               => NULL,
                         x_award_status             => 'ACCEPTED',
                         x_rvsn_id                  => NULL,
                         x_alt_pell_schedule        => NULL,
                         x_attribute_category       => NULL,
                         x_attribute1               => NULL,
                         x_attribute2               => NULL,
                         x_attribute3               => NULL,
                         x_attribute4               => NULL,
                         x_attribute5               => NULL,
                         x_attribute6               => NULL,
                         x_attribute7               => NULL,
                         x_attribute8               => NULL,
                         x_attribute9               => NULL,
                         x_attribute10              => NULL,
                         x_attribute11              => NULL,
                         x_attribute12              => NULL,
                         x_attribute13              => NULL,
                         x_attribute14              => NULL,
                         x_attribute15              => NULL,
                         x_attribute16              => NULL,
                         x_attribute17              => NULL,
                         x_attribute18              => NULL,
                         x_attribute19              => NULL,
                         x_attribute20              => NULL,
                         x_award_number_txt         => NULL,
                         x_legacy_record_flag       => 'Y',
                         x_adplans_id               => NULL,
                         x_lock_award_flag          => 'N',
                         x_app_trans_num_txt        => NULL,
                         x_awd_proc_status_code     => NULL,
                         x_notification_status_code	=> NULL,
                         x_notification_status_date	=> NULL,
                         x_publish_in_ss_flag       => 'N'
                       );
                       l_debug_str := l_debug_str || ' Record Inserted';
                END IF;
              END IF;
            ELSE  -- This means that award id is not null
              IF NVL(l_interface.import_record_type,'X') = 'U' THEN
              --UPDATE THE AWARD RECORD AS THE RECORD ALREADY EXISTS AND THE UPDATE FLAG IS 'U'
                IF l_error_flag = FALSE THEN
                  igf_aw_award_pkg.update_row(
                       x_mode                     => 'R',
                       x_award_id                 => l_award_id.award_id,
                       x_fund_id                  => l_fund_id.fund_id,
                       x_base_id                  => lv_base_id,
                       x_rowid                    => l_award_id.ROW_ID,
                       x_offered_amt              => l_interface.offrd_amt,
                       x_accepted_amt             => l_interface.accpt_amt,
                       x_paid_amt                 => l_interface.paid_amt,
                       x_batch_id                 => l_interface.batch_id,
                       x_packaging_type           => NULL,
                       x_manual_update            => NULL,
                       x_rules_override           => NULL,
                       x_award_date               => NULL,
                       x_award_status             => 'ACCEPTED',
                       x_rvsn_id                  => NULL,
                       x_alt_pell_schedule        => NULL,
                       x_attribute_category       => NULL,
                       x_attribute1               => NULL,
                       x_attribute2               => NULL,
                       x_attribute3               => NULL,
                       x_attribute4               => NULL,
                       x_attribute5               => NULL,
                       x_attribute6               => NULL,
                       x_attribute7               => NULL,
                       x_attribute8               => NULL,
                       x_attribute9               => NULL,
                       x_attribute10              => NULL,
                       x_attribute11              => NULL,
                       x_attribute12              => NULL,
                       x_attribute13              => NULL,
                       x_attribute14              => NULL,
                       x_attribute15              => NULL,
                       x_attribute16              => NULL,
                       x_attribute17              => NULL,
                       x_attribute18              => NULL,
                       x_attribute19              => NULL,
                       x_attribute20              => NULL,
                       x_award_number_txt         => NULL,
                       x_legacy_record_flag       => 'Y',
                       x_adplans_id               => NULL,
                       x_lock_award_flag          => 'N',
                       x_app_trans_num_txt        => NULL,
                       x_awd_proc_status_code     => NULL,
                       x_notification_status_code	=> NULL,
                       x_notification_status_date	=> NULL,
                       x_publish_in_ss_flag       => 'N'
                      );
                      l_debug_str := l_debug_str || ' Record Updated';
                END IF;
              ELSE
                -- AS THE AWARD ALREADY EXISTS SO IT CAN NOT BE UPDATED
                fnd_message.set_name('IGF','IGF_SE_FUND_CODE');
                fnd_message.set_token('TOKEN',l_interface.fund_code);
                l_message_str := RPAD(l_error,12) || fnd_message.get;
                fnd_message.set_name('IGF','IGF_AW_AWARD_EXISTS');
                g_log_tab_index := g_log_tab_index + 1;
                g_log_tab(g_log_tab_index).person_number := l_interface.person_number;
                g_log_tab(g_log_tab_index).message_text := l_message_str || ' ' || fnd_message.get;
                l_error_flag := TRUE;
              END IF;
            END IF; -- for the award id check
          END IF; -- for the fund id check
        END IF; -- for the base id check
      END IF; -- for the person id check
    IF l_error_flag = TRUE THEN
      l_error_flag := FALSE;
      --update the legacy interface table column import_status to 'E'
      UPDATE igf_aw_li_agr_ints
      SET import_status_type = 'E'
      WHERE ROWID = l_interface.ROW_ID;
      -- HERE INCREMENT THE COUNTER FOR THE RECORDS THAT HAVE ERRORS....
      l_error_record_cnt := l_error_record_cnt + 1;
    ELSE
      IF p_del_ind = 'Y' THEN
         DELETE FROM igf_aw_li_agr_ints
         WHERE ROWID = l_interface.ROW_ID;
         l_debug_str := l_debug_str || ' Record Deleted from interface table';
       ELSE
         --update the legacy interface table column import_status to 'I'
         UPDATE igf_aw_li_agr_ints
         SET import_status_type = 'I'
         WHERE ROWID = l_interface.ROW_ID;
         l_debug_str := l_debug_str || ' Record import_status changed to I';
       END IF;
       l_success_record_cnt := l_success_record_cnt + 1;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_li_awards_pkg.main_import_process.debug',l_debug_str);
    END IF;
    l_message_str := NULL;
    l_debug_str := NULL;

    EXCEPTION
       WHEN others THEN
         l_message_str := NULL;
         l_debug_str := NULL;
         l_error_flag := FALSE;
         fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
         fnd_message.set_token('NAME','IGF_AP_MK_ISIR_ACT_PKG.LG_MAKE_ACTIVE_ISIR');
         g_log_tab_index := g_log_tab_index + 1;
         g_log_tab(g_log_tab_index).person_number := l_interface.person_number;
         g_log_tab(g_log_tab_index).message_text := RPAD(l_error,12) || fnd_message.get;

         ROLLBACK TO sp1;
      END;
      COMMIT;
    END LOOP;

    IF l_success_record_cnt = 0 AND l_error_record_cnt = 0 THEN
       fnd_message.set_name('IGS','IGS_FI_NO_RECORD_AVAILABLE');
       fnd_file.put_line(fnd_file.log,RPAD(l_error,12) || fnd_message.get);
       RETURN;
    END IF;

    -- CALL THE PRINT LOG PROCESS
    print_log_process(l_person_number,l_error);
    l_total_record_cnt := l_success_record_cnt + l_error_record_cnt;
    fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_PROCESSED');
    fnd_file.put_line(fnd_file.OUTPUT,fnd_message.get || ' ' || l_total_record_cnt);
    fnd_message.set_name('IGS','IGS_AD_SUCC_IMP_OFR_RESP_REC');
    fnd_file.put_line(fnd_file.OUTPUT,fnd_message.get || ' : ' || l_success_record_cnt);
    fnd_message.set_name('IGS','IGS_GE_TOTAL_REC_FAILED');
    fnd_file.put_line(fnd_file.OUTPUT,fnd_message.get || ' : ' || l_error_record_cnt);

    EXCEPTION
    WHEN others THEN
       --CALL TO THE COMMON LOGGING FRAMEWORK FOR DEBUG MESSAGES
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_li_awards_pkg.main_import_process.exception','Exception: '||SQLERRM);
      END IF;
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_LI_AWARDS_PKG.MAIN_IMPORT_PROCESS');
      errbuf  := fnd_message.get;
      igs_ge_msg_stack.conc_exception_hndl;

  END main_import_process;

  PROCEDURE print_log_process(
                              p_person_number IN  VARCHAR2,
                              p_error         IN  VARCHAR2
                             ) IS
    /*
    ||  Created By : bkkumar
    ||  Created On : 24-MAY-2003
    ||  Purpose : This process gets the records from the pl/sql table and print in the log file
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

  l_count NUMBER(5) := g_log_tab.COUNT;
  l_old_person  igf_aw_li_agr_ints.person_number%TYPE := '*******';

  BEGIN

    FOR i IN 1..l_count LOOP
      IF l_old_person <> g_log_tab(i).person_number THEN
        fnd_file.put_line(fnd_file.log,'-----------------------------------------------------------------------------');
        fnd_file.put_line(fnd_file.log,p_person_number || ' : ' || g_log_tab(i).person_number);
      END IF;
      IF  g_log_tab(i).message_text IS NOT NULL AND g_log_tab(i).message_text <> ' ' THEN
        fnd_file.put_line(fnd_file.log,g_log_tab(i).message_text);
      END IF;
      l_old_person := g_log_tab(i).person_number;
    END LOOP;

  END print_log_process;

END igf_ap_li_awards_pkg;

/
