--------------------------------------------------------
--  DDL for Package Body IGS_UC_UPD_PENDING_TRANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_UPD_PENDING_TRANS_PKG" AS
/* $Header: IGSUC70B.pls 120.2 2006/08/21 03:53:06 jbaber noship $*/

  l_debug_level NUMBER:= fnd_log.g_current_runtime_level;

  PROCEDURE upd_pending_transactions (
     errbuf                        OUT NOCOPY VARCHAR2,
     retcode                       OUT NOCOPY NUMBER
    ) IS

  /*------------------------------------------------------------------
  --Created by  : jchakrab, Oracle Corporation
  --Date created: 31-Oct-2005
  --
  --Purpose     : Retrieve transaction details from the UCAS TRANIN view (over the
  --              database link) for transactions currently marked as pending in
  --              IGS_UC_TRANSACTIONS table and update their details, if processed
  --              by the UCAS transaction processing system(Topaz).
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  WHO       WHEN          WHAT
  anwest    18-JAN-2006   Bug# 4950285 R12 Disable OSS Mandate
  jbaber   11-Jul-06    Added modular and part_time fields for UC325 - UCAS 2007 Support
  -----------------------------------------------------------------------*/
  CURSOR c_cycle IS
      SELECT max(current_cycle) current_cycle, max(configured_cycle) configured_cycle
      FROM igs_uc_defaults ;

  c_cycle_rec c_cycle%ROWTYPE;

  CURSOR c_control IS
      SELECT TO_NUMBER(LPAD(entry_year,4,200))
      FROM igs_uc_ucas_control
      WHERE system_code = 'U'
      AND ucas_cycle = c_cycle_rec.configured_cycle;

  CURSOR c_pending_trans(cp_conf_cycle igs_uc_defaults.configured_cycle%TYPE) IS
      SELECT TRANS.ROWID,
             TRANS.UC_TRAN_ID,
             TRANS.TRANSACTION_ID,
             TRANS.DATETIMESTAMP,
             TRANS.UPDATER,
             TRANS.ERROR_CODE,
             TRANS.TRANSACTION_TYPE,
             TRANS.APP_NO,
             TRANS.CHOICE_NO,
             TRANS.DECISION,
             TRANS.PROGRAM_CODE,
             TRANS.CAMPUS,
             TRANS.ENTRY_MONTH,
             TRANS.ENTRY_YEAR,
             TRANS.ENTRY_POINT,
             TRANS.SOC,
             TRANS.COMMENTS_IN_OFFER,
             TRANS.RETURN1,
             TRANS.RETURN2,
             TRANS.HOLD_FLAG,
             TRANS.SENT_TO_UCAS,
             TRANS.TEST_COND_CAT,
             TRANS.TEST_COND_NAME,
             TRANS.INST_REFERENCE ,
             TRANS.AUTO_GENERATED_FLAG,
             TRANS.SYSTEM_CODE,
             TRANS.UCAS_CYCLE,
             TRANS.MODULAR,
             TRANS.PART_TIME
         FROM
             IGS_UC_TRANSACTIONS TRANS,
             IGS_UC_CYC_DEFAULTS DFLTS
         WHERE
             TRANS.ERROR_CODE = -1
             AND TRANS.SENT_TO_UCAS = 'Y'
             AND TRANS.UCAS_CYCLE = cp_conf_cycle
             AND TRANS.SYSTEM_CODE = DFLTS.SYSTEM_CODE
             AND TRANS.UCAS_CYCLE  = DFLTS.UCAS_CYCLE
             AND DFLTS.UCAS_INTERFACE = 'H'
         ORDER BY TRANS.CREATION_DATE;

 CURSOR c_pending_trans_count(cp_conf_cycle igs_uc_defaults.configured_cycle%TYPE) IS
     SELECT COUNT(*)
     FROM
         IGS_UC_TRANSACTIONS TRANS,
         IGS_UC_CYC_DEFAULTS DFLTS
     WHERE
         TRANS.ERROR_CODE = -1
         AND TRANS.SENT_TO_UCAS = 'Y'
         AND TRANS.UCAS_CYCLE = cp_conf_cycle
         AND TRANS.SYSTEM_CODE = DFLTS.SYSTEM_CODE
         AND TRANS.UCAS_CYCLE  = DFLTS.UCAS_CYCLE
         AND DFLTS.UCAS_INTERFACE = 'H';

 CURSOR c_tranin_info(cp_trans_id igs_uc_transactions.transaction_id%TYPE,
                      cp_app_no   igs_uc_u_tranin_2004.appno%TYPE) IS
     SELECT APPNO,
            CHOICENO,
            TRANSACTIONID,
            ERRORCODE,
            TIMESTAMP,
            UPDATER,
            RETURN1,
            RETURN2,
            SOC
     FROM
            IGS_UC_U_TRANIN_2004
     WHERE
            TRANSACTIONID = cp_trans_id
            AND APPNO = cp_app_no;

  c_tranin_info_rec  c_tranin_info%ROWTYPE;

  -- Cursor to convert 8-digit appno to 9 digit NUMBER with check digit for UCAS 2006 Cycle Support
  CURSOR c_appno(cp_appno igs_uc_applicants.app_no%TYPE) IS
      SELECT TO_NUMBER(APP_NO || CHECK_DIGIT)
      FROM IGS_UC_APPLICANTS
      WHERE APP_NO = CP_APPNO;

  l_soc                       igs_uc_transactions.SOC%TYPE;
  l_entry_year                igs_uc_defaults.configured_cycle%TYPE;
  l_pending_cnt               NUMBER;
  l_valid_cnt                 NUMBER;
  l_invalid_cnt               NUMBER;
  l_appno                     igs_uc_u_tranin_2004.appno%TYPE;

  BEGIN

      --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
      IGS_GE_GEN_003.SET_ORG_ID;

      /* Checking whether the UK profile is enabled */
      IF NOT (igs_uc_utils.is_ucas_hesa_enabled) THEN

          fnd_message.set_name('IGS','IGS_UC_HE_NOT_ENABLED');
          fnd_file.put_line(fnd_file.log, fnd_message.get());  -- display to user also
          -- also log using the fnd logging framework
          IF (fnd_log.level_statement >= l_debug_level ) THEN
              fnd_log.string( fnd_log.level_statement, 'igs.plsql.ucas.upd_pending_transactions.validation', fnd_message.get());
          END IF;
          errbuf  := fnd_message.get_string ('IGS', 'IGS_UC_HE_NOT_ENABLED');
          retcode := 3 ;
          RETURN ;

      END IF;


      -- get the ucas configured cycle
      OPEN c_cycle;
      FETCH c_cycle INTO c_cycle_rec;
      CLOSE c_cycle;

      -- Get the hercules entry year
      OPEN c_control;
      FETCH c_control INTO l_entry_year;
      CLOSE c_control;

      -- Check whether configured cycle is same as entry year
      IF l_entry_year <> c_cycle_rec.configured_cycle THEN
          fnd_message.set_name('IGS','IGS_UC_CYCLES_NOT_SYNC');
          fnd_message.set_token('UCAS_CYCLE',c_cycle_rec.configured_cycle);
          fnd_message.set_token('HERC_CYCLE',l_entry_year);
          fnd_file.put_line(fnd_file.log, fnd_message.get());
          errbuf  := fnd_message.get;
          retcode := 2;
          RETURN;
      END IF;

      l_pending_cnt := 0;
      l_valid_cnt := 0;
      l_invalid_cnt := 0;

      -- get the initial count of pending transactions
      OPEN c_pending_trans_count(c_cycle_rec.configured_cycle);
      FETCH c_pending_trans_count INTO l_pending_cnt;
      CLOSE c_pending_trans_count;

      fnd_message.set_name('IGS','IGS_UC_INIT_TRAN_PENDING_CNT');
      fnd_message.set_token('REC_CNT',l_pending_cnt);
      fnd_file.put_line(fnd_file.log, fnd_message.get());

      --When the Interface is Hercules then get the Transaction records from IGS_UC_TRANSACTIONS table and insert into Hercules igs_uc_u_tranin_2004 .
      FOR c_pending_trans_rec IN c_pending_trans(c_cycle_rec.configured_cycle)
      LOOP

          -- Determine appno based on configured year.
          IF c_cycle_rec.configured_cycle < 2006 THEN
              l_appno := c_pending_trans_rec.app_no;
          ELSE
              -- Convert 8-digit appno to 9 digit NUMBER with check digit for UC315 - UCAS 2006 Support
              OPEN c_appno(c_pending_trans_rec.app_no);
              FETCH c_appno INTO l_appno;
              CLOSE c_appno;
          END IF;

          OPEN c_tranin_info(c_pending_trans_rec.transaction_id, l_appno);
          FETCH c_tranin_info INTO c_tranin_info_rec;
          CLOSE c_tranin_info;

          --check if the transaction has been processed
          IF c_tranin_info_rec.errorcode <> -1 THEN

              --perform updates in IGS_UC_TRANSACTIONS based on error code

              --to update the SOC based on the errorcode value
              IF c_tranin_info_rec.errorcode = 0 THEN
                  l_soc := c_tranin_info_rec.soc;
                  --update the count of valid transactions processed by UCAS
                  l_valid_cnt := l_valid_cnt + 1;
              ELSE
                  --use old SOC value
                  l_soc := c_pending_trans_rec.SOC;
                  --update the count of invalid transactions processed by UCAS
                  l_invalid_cnt := l_invalid_cnt + 1;
              END IF;

              igs_uc_transactions_pkg.update_row (
                    x_mode                              => 'R',
                    x_rowid                             => c_pending_trans_rec.ROWID,
                    x_uc_tran_id                        => c_pending_trans_rec.uc_tran_id,
                    x_transaction_id                    => c_pending_trans_rec.transaction_id,
                    x_datetimestamp                     => c_tranin_info_rec.timestamp,
                    x_updater                           => c_tranin_info_rec.updater,
                    x_error_code                        => c_tranin_info_rec.errorcode,
                    x_transaction_type                  => c_pending_trans_rec.transaction_type,
                    x_app_no                            => c_pending_trans_rec.app_no,
                    x_choice_no                         => c_pending_trans_rec.choice_no,
                    x_decision                          => c_pending_trans_rec.decision,
                    x_program_code                      => c_pending_trans_rec.program_code,
                    x_campus                            => c_pending_trans_rec.campus,
                    x_entry_month                       => c_pending_trans_rec.entry_month,
                    x_entry_year                        => c_pending_trans_rec.entry_year,
                    x_entry_point                       => c_pending_trans_rec.entry_point,
                    x_soc                               => l_soc,
                    x_comments_in_offer                 => c_pending_trans_rec.comments_in_offer,
                    x_return1                           => c_tranin_info_rec.return1,
                    x_return2                           => c_tranin_info_rec.return2,
                    x_hold_flag                         => c_pending_trans_rec.hold_flag,
                    x_sent_to_ucas                      => c_pending_trans_rec.sent_to_ucas,
                    x_test_cond_cat                     => c_pending_trans_rec.test_cond_cat,
                    x_test_cond_name                    => c_pending_trans_rec.test_cond_name,
                    x_inst_reference                    => c_pending_trans_rec.inst_reference ,
                    x_auto_generated_flag               => c_pending_trans_rec.auto_generated_flag,
                    x_system_code                       => c_pending_trans_rec.system_code,
                    x_ucas_cycle                        => c_pending_trans_rec.ucas_cycle,
                    x_modular                           => c_pending_trans_rec.modular,
                    x_part_time                         => c_pending_trans_rec.part_time);

          END IF;

      END LOOP;

      COMMIT;

      --print statistics
      fnd_message.set_name('IGS','IGS_UC_TRAN_VALID_CNT');
      fnd_message.set_token('REC_CNT',l_valid_cnt);
      fnd_file.put_line(fnd_file.log, fnd_message.get());

      fnd_message.set_name('IGS','IGS_UC_TRAN_INVALID_CNT');
      fnd_message.set_token('REC_CNT',l_invalid_cnt);
      fnd_file.put_line(fnd_file.log, fnd_message.get());

      -- get the final count of pending transactions
      OPEN c_pending_trans_count(c_cycle_rec.configured_cycle);
      FETCH c_pending_trans_count INTO l_pending_cnt;
      CLOSE c_pending_trans_count;

      fnd_message.set_name('IGS','IGS_UC_TRAN_PENDING_CNT');
      fnd_message.set_token('REC_CNT',l_pending_cnt);
      fnd_file.put_line(fnd_file.log, fnd_message.get());


  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igs_uc_upd_pending_trans_pkg.upd_pending_transactions - '||SQLERRM);
      fnd_file.put_line(fnd_file.log,fnd_message.get);

      IF ( fnd_log.level_unexpected >= l_debug_level ) THEN
          fnd_log.message(fnd_log.level_unexpected, 'igs.plsql.ucas.upd_pending_transactions.exception', FALSE);
      END IF;

      fnd_message.retrieve (errbuf);
      retcode := 2 ;
      igs_ge_msg_stack.conc_exception_hndl;

  END upd_pending_transactions;

END igs_uc_upd_pending_trans_pkg;

/
