--------------------------------------------------------
--  DDL for Package Body IGS_UC_START_NEW_CYCLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_START_NEW_CYCLE" AS
/* $Header: IGSUC40B.pls 120.3 2006/02/08 19:57:22 anwest noship $ */

 PROCEDURE start_new_cycle( errbuf    OUT NOCOPY    VARCHAR2,
                            retcode   OUT NOCOPY    NUMBER
                           ) IS
   /*************************************************************
   Created By      : dsridhar
   Date Created On : 19-JUN-2003
   Purpose         : This procedure will configure the UCAS System to a new
                    Admission Cycle.

   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   (reverse chronological order - newest change first)
   dsridhar        19-JUN-2003     Create Version as part of UC203FD
                                   Bug# 2669208
   dsridhar        16-JUL-2003     Changed cursor cur_uc_defaults, added new cursor, added code to run the process
                                   when maximum current cycle and maximum configured cycle are NULL
   dsridhar        17-JUL-2003     Added code to display message after updating igs_uc_defaults
   dsridhar        24-JUL-2003     Bug No: 3022067, part of change request for UCAS Application Calendar Mapping.
                                   Removed calendar fields from the IGS_UC_CYC_DEFAULTS_PKG procedure calls.
   jchakrab        20-Sep-2005     Modified for 4616246 - If a record with null current/conf cycle is found in
                                   IGS_UC_DEFAULTS and no record exists for the current cycle in IGS_UC_TRANSACTIONS
                                   a empty record is inserted into IGS_UC_UCAS_CONTROL to be updated later by user
   anwest          18-JAN-2006     Bug# 4950285 R12 Disable OSS Mandate
   ***************************************************************/

     -- Cursor to check if any records exist in IGS_UC_DEFAULTS
     CURSOR cur_uc_defaults IS
            SELECT 'X'
            FROM   igs_uc_defaults;

     -- Cursor to get the maximum current cycle and maximum configured cycle
     CURSOR cur_max_cycles IS
            SELECT MAX(current_cycle) current_cycle, MAX(configured_cycle) configured_cycle
            FROM   igs_uc_defaults;

     -- Cursor to get the any cycles is null
     -- Modified for 4589994 to exclude SWAS
     CURSOR cur_null_cycles IS
     SELECT 'X' FROM igs_uc_defaults
     WHERE (current_cycle IS NULL OR configured_cycle IS NULL)
     AND   system_code <> 'S';

     -- Cursor to obtain the Supported Cycle - 1
     CURSOR cur_sup_cycle IS
            SELECT MAX(TO_NUMBER(lookup_code)) - 1
            FROM   igs_lookup_values
            WHERE  lookup_type = 'IGS_UC_SUP_CYCLE'
            AND    enabled_flag = 'Y'
            AND    NVL(closed_Ind, 'N') = 'N';

     -- Cursor to obtain the Next Cycle i.e. Supported Cycle + 1
     CURSOR cur_next_cycle (p_current_cycle igs_uc_defaults.current_cycle%TYPE) IS
            SELECT TO_NUMBER(lookup_code)
            FROM   igs_lookup_values
            WHERE  lookup_type = 'IGS_UC_SUP_CYCLE'
            AND    TO_NUMBER(lookup_code) = p_current_cycle + 1
            AND    enabled_flag = 'Y'
            AND    NVL(closed_Ind, 'N') = 'N';

     -- Cursor to select the Current Cycle details from IGS_UC_CYC_DEFAULTS
     -- Modified for UC315 - UCAS 2006 Support to exclude SWAS
     CURSOR cur_uc_cyc_defaults (p_current_cycle igs_uc_defaults.current_cycle%TYPE) IS
            SELECT  ucd.*
            FROM   igs_uc_cyc_defaults ucd
            WHERE  ucas_cycle = p_current_cycle
            AND    ucd.system_code <> 'S';

     -- Cursor to check if the record exists in IGS_UC_CYC_DEFAULTS
     CURSOR cur_check_uc_cyc_defaults (p_system_code igs_uc_cyc_defaults.system_code%TYPE,
                                       p_ucas_cycle igs_uc_cyc_defaults.ucas_cycle%TYPE) IS
            SELECT  'X'
            FROM   igs_uc_cyc_defaults ucd
            WHERE  system_code = p_system_code
            AND    ucas_cycle = p_ucas_cycle;

     -- Cursor to select current cycle details from IGS_UC_UCAS_CONTROL
     -- Modified for UC315 - UCAS 2006 Support to include FTUG and exclude SWAS
     CURSOR cur_uc_ucas_control (p_current_cycle igs_uc_defaults.current_cycle%TYPE) IS
            SELECT uco.rowid, uco.*
            FROM   igs_uc_ucas_control uco
            WHERE  uco.system_code <> 'S'
            AND    ucas_cycle = p_current_cycle;

     -- Cursor to check if the record exists in IGS_UC_UCAS_CONTROL
     CURSOR cur_check_ucas_control (p_system_code igs_uc_ucas_control.system_code%TYPE,
                                       p_ucas_cycle igs_uc_ucas_control.ucas_cycle%TYPE) IS
            SELECT  'X'
            FROM   igs_uc_ucas_control ucd
            WHERE  system_code = p_system_code
            AND    ucas_cycle = p_ucas_cycle;

     -- Cursor to select records from IGS_UC_DEFAULTS
     -- Modified for UC315 - UCAS 2006 Support to exclude SWAS
     CURSOR cur_defaults IS
            SELECT ucd.rowid, ucd.*
            FROM   igs_uc_defaults ucd
            WHERE  ucd.system_code <> 'S';

    l_max_cycles cur_max_cycles%ROWTYPE;
    l_current_cycle igs_uc_defaults.current_cycle%TYPE;
    l_sup_cycle igs_uc_defaults.current_cycle%TYPE;
    l_next_cycle igs_uc_defaults.current_cycle%TYPE;
    l_rowid VARCHAR2(26);
    l_exists VARCHAR2(1);
    l_curr_control_exists  VARCHAR2(1);
    l_null_cycles VARCHAR2(1);
    l_curr_cycle igs_uc_defaults.current_cycle%TYPE;
    l_conf_cycle igs_uc_defaults.configured_cycle%TYPE;
    l_appno_first igs_uc_ucas_control.appno_first%TYPE;
    l_appno_maximum  igs_uc_ucas_control.appno_maximum%TYPE;

BEGIN

    --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
    IGS_GE_GEN_003.SET_ORG_ID;

    -- Check if records exist in IGS_UC_DEFAULTS
    l_exists := NULL;
    retcode := 0;
    OPEN cur_uc_defaults;
    FETCH cur_uc_defaults INTO l_exists;
    IF cur_uc_defaults%NOTFOUND THEN
       CLOSE cur_uc_defaults;
       fnd_message.set_name('IGS', 'IGS_UC_NO_SYSTEM_CONFIG');
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       retcode := 2;
       RETURN;
    END IF;
    CLOSE cur_uc_defaults;

     -- Get maximum current cycle or maximum configured cycle and check if they are NULL
     OPEN cur_max_cycles;
     FETCH cur_max_cycles INTO l_max_cycles;
     CLOSE cur_max_cycles;

     -- Get maximum of supported cycle - 1 and update current cycle and configured cycle with it
     OPEN cur_sup_cycle;
     FETCH cur_sup_cycle INTO l_sup_cycle;
     CLOSE cur_sup_cycle;

     -- Check whether any cycle is null then populate correct cycle value,bug 3420747
     OPEN cur_null_cycles;
     FETCH cur_null_cycles INTO l_null_cycles;

   IF cur_null_cycles%FOUND THEN
       CLOSE cur_null_cycles;
        -- take the max of the cycle value or look up value
       l_curr_cycle := NVL(l_max_cycles.current_cycle,l_sup_cycle);
       l_conf_cycle := NVL(l_max_cycles.configured_cycle,l_sup_cycle);

       FOR rec_cur_defaults IN cur_defaults LOOP
         IF rec_cur_defaults.current_cycle IS NULL OR rec_cur_defaults.configured_cycle IS NULL THEN
              igs_uc_defaults_pkg.update_row ( x_rowid                        => rec_cur_defaults.rowid,
                                               x_current_inst_code            => rec_cur_defaults.current_inst_code,
                                               x_ucas_id_format               => rec_cur_defaults.ucas_id_format,
                                               x_test_app_no                  => rec_cur_defaults.test_app_no,
                                               x_test_choice_no               => rec_cur_defaults.test_choice_no,
                                               x_test_transaction_type        => rec_cur_defaults.test_transaction_type,
                                               x_copy_ucas_id                 => rec_cur_defaults.copy_ucas_id,
                                               x_mode                         => 'R',
                                               x_decision_make_id             => rec_cur_defaults.decision_make_id,
                                               x_decision_reason_id           => rec_cur_defaults.decision_reason_id,
                                               x_obsolete_outcome_status      => rec_cur_defaults.obsolete_outcome_status,
                                               x_pending_outcome_status       => rec_cur_defaults.pending_outcome_status,
                                               x_rejected_outcome_status      => rec_cur_defaults.rejected_outcome_status,
                                               x_system_code                  => rec_cur_defaults.system_code,
                                               x_ni_number_alt_pers_type      => rec_cur_defaults.ni_number_alt_pers_type,
                                               x_application_type             => rec_cur_defaults.application_type,
                                               x_name                         => rec_cur_defaults.name,
                                               x_description                  => rec_cur_defaults.description,
                                               x_ucas_security_key            => rec_cur_defaults.ucas_security_key,
                                               x_current_cycle                => l_curr_cycle,
                                               x_configured_cycle             => l_conf_cycle,
                                               x_prev_inst_left_date          => rec_cur_defaults.prev_inst_left_date
		     	                    );

              fnd_message.set_name('IGS', 'IGS_UC_CRNT_CYCLE_UPDTD');
              fnd_message.set_token('SYSTEM_CODE', rec_cur_defaults.system_code);
              fnd_message.set_token('CRNT_CYCLE', l_curr_cycle);
              fnd_file.put_line(fnd_file.log, fnd_message.get);

              --jchakrab - Modified for 4616246
              --Create a record in the IGS_UC_UCAS_CONTROL table if no record exists for l_curr_cycle
              l_curr_control_exists := NULL;
              OPEN cur_check_ucas_control(rec_cur_defaults.system_code, l_curr_cycle);
              FETCH cur_check_ucas_control into l_curr_control_exists;
              CLOSE cur_check_ucas_control;

              IF l_curr_control_exists IS NULL THEN
                  --this is a scenario where the customer is trying to setup UCAS in a fresh-install env
                  --we need to create a empty record in IGS_UC_UCAS_CONTROL which should be updated later by user

                  --derive app-no ranges based on system code and current cycle
                  --FTUG = Y000001 to Y689999, GTTR = Y700001 to Y799999, NMAS = Y800001 to Y899999, Y = entry_year
                  IF rec_cur_defaults.system_code = 'U' THEN
                      l_appno_first := Ltrim(Substr(l_curr_cycle,3,2)) || '000001';
                      l_appno_maximum := Ltrim(Substr(l_curr_cycle,3,2)) || '689999';
                  ELSIF  rec_cur_defaults.system_code = 'G' THEN
                      l_appno_first := Ltrim(Substr(l_curr_cycle,3,2)) || '700001';
                      l_appno_maximum := Ltrim(Substr(l_curr_cycle,3,2)) || '799999';
                  ELSIF  rec_cur_defaults.system_code = 'N' THEN
                      l_appno_first := Ltrim(Substr(l_curr_cycle,3,2)) || '800001';
                      l_appno_maximum := Ltrim(Substr(l_curr_cycle,3,2)) || '899999';
                  ELSE
                      l_appno_first := 0;
                      l_appno_maximum := 0;
                  END IF;
                  l_rowid := NULL;
                  igs_uc_ucas_control_pkg.insert_row( x_rowid              => l_rowid,
                                               x_entry_year                => Ltrim(Substr(l_curr_cycle,3,2)),
                                               x_time_of_year              => NULL,
                                               x_time_of_day               => NULL,
                                               x_routeb_time_of_year       => NULL,
                                               x_appno_first               => l_appno_first, -- put value to expected appno ranges as value cannot be derived at this stage
                                               x_appno_maximum             => l_appno_maximum, -- put value to expected appno ranges as value cannot be derived at this stage
                                               x_appno_last_used           => NULL,
                                               x_last_daily_run_no         => NULL,
                                               x_last_daily_run_date       => NULL,
                                               x_appno_15dec               => NULL,
                                               x_run_date_15dec            => NULL,
                                               x_appno_24mar               => NULL,
                                               x_run_date_24mar            => NULL,
                                               x_appno_16may               => NULL,
                                               x_run_date_16may            => NULL,
                                               x_appno_decision_proc       => NULL,
                                               x_run_date_decision_proc    => NULL,
                                               x_appno_first_pre_num       => NULL,
                                               x_news                      => NULL,
                                               x_no_more_la_tran           => NULL,
                                               x_star_x_avail              => NULL,
                                               x_mode                      => 'R',
                                               x_appno_first_opf           => 0,
                                               x_appno_first_rpa_noneu     => 0,
                                               x_appno_first_rpa_eu        => 0,
                                               x_extra_start_date          => NULL,
                                               x_last_passport_date        => NULL,
                                               x_last_le_date              => NULL,
                                               x_system_code               => rec_cur_defaults.system_code,
                                               x_ucas_cycle                => l_curr_cycle,
                                               x_gttr_clear_toy_code       => NULL,
                                               x_transaction_toy_code      => 'S'
                                             );

                  fnd_message.set_name('IGS', 'IGS_UC_REC_INSRT');
                  fnd_message.set_token('SYSTEM_CODE', rec_cur_defaults.system_code);
                  fnd_message.set_token('TNAME', 'IGS_UC_UCAS_CONTROL');
                  fnd_file.put_line(fnd_file.log, fnd_message.get);
              END IF;

         END IF;
       END LOOP;
       RETURN;
    END IF;

      IF cur_null_cycles%ISOPEN THEN
        CLOSE cur_null_cycles;
      END IF;
    -- Get the next higher cycle i.e. Supported Cycle + 1
    l_next_cycle  := NULL ;
    IF l_max_cycles.current_cycle IS NOT NULL THEN
       l_current_cycle := l_max_cycles.current_cycle;
    ELSE
       l_current_cycle := l_sup_cycle;
    END IF;

    OPEN cur_next_cycle (l_current_cycle);
    FETCH cur_next_cycle INTO l_next_cycle;
    -- If Current Cycle = Maximum of Supported Cycle
    IF cur_next_cycle%NOTFOUND THEN
       CLOSE cur_next_cycle;
       fnd_message.set_name('IGS', 'IGS_UC_ALRDY_MAX_CYCLE');
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       retcode := 2 ;
       RETURN;
    END IF;
    CLOSE cur_next_cycle;

    -- If next cycle is not null i.e. Current Cycle + 1 is supported
    IF l_next_cycle IS NOT NULL THEN

       -- Populate records for new cycle in IGS_UC_CYC_DEFAULTS from previous cycle.
       FOR rec_uc_cyc_defaults IN cur_uc_cyc_defaults (l_current_cycle)
       LOOP
           l_exists := NULL;
           OPEN cur_check_uc_cyc_defaults(rec_uc_cyc_defaults.system_code, l_next_cycle);
           FETCH cur_check_uc_cyc_defaults INTO l_exists;
           CLOSE cur_check_uc_cyc_defaults;
           IF l_exists IS NULL THEN
              l_rowid := NULL;
              igs_uc_cyc_defaults_pkg.insert_row( x_rowid                  => l_rowid,
                                                  x_SYSTEM_CODE            => rec_uc_cyc_defaults.system_code,
                                                  x_UCAS_CYCLE             => l_next_cycle,
                                                  x_UCAS_INTERFACE         => rec_uc_cyc_defaults.ucas_interface,
                                                  x_MARVIN_SEQ             => 0,
                                                  x_CLEARING_FLAG          => rec_uc_cyc_defaults.clearing_flag,
                                                  x_EXTRA_FLAG             => rec_uc_cyc_defaults.extra_flag,
                                                  x_CVNAME_FLAG            => rec_uc_cyc_defaults.cvname_flag,
					          x_MODE                   => 'R'
                                             );

             fnd_message.set_name('IGS', 'IGS_UC_REC_INSRT');
             fnd_message.set_token('TNAME', 'IGS_UC_CYC_DEFAULTS');
             fnd_message.set_token('SYSTEM_CODE', rec_uc_cyc_defaults.system_code);
             fnd_file.put_line(fnd_file.log, fnd_message.get);
           END IF;

       END LOOP;

       -- Populate records for new cycle in IGS_UC_UCAS_CONTROL from previous cycle.
       FOR rec_cur_uc_ucas_control IN  cur_uc_ucas_control(l_current_cycle)
       LOOP
           l_exists := NULL;
           OPEN cur_check_ucas_control(rec_cur_uc_ucas_control.system_code, l_next_cycle);
           FETCH cur_check_ucas_control INTO l_exists;
           CLOSE cur_check_ucas_control;
           IF l_exists IS NULL THEN
              l_rowid := NULL;
              igs_uc_ucas_control_pkg.insert_row( x_rowid                  => l_rowid,
                                               x_entry_year                => rec_cur_uc_ucas_control.entry_year + 1,
                                               x_time_of_year              => NULL,
                                               x_time_of_day               => NULL,
                                               x_routeb_time_of_year       => NULL,
                                               x_appno_first               => rec_cur_uc_ucas_control.appno_first + 1000000,
                                               x_appno_maximum             => rec_cur_uc_ucas_control.appno_maximum + 1000000,
                                               x_appno_last_used           => NULL,
                                               x_last_daily_run_no         => NULL,
                                               x_last_daily_run_date       => NULL,
                                               x_appno_15dec               => NULL,
                                               x_run_date_15dec            => NULL,
                                               x_appno_24mar               => NULL,
                                               x_run_date_24mar            => NULL,
                                               x_appno_16may               => NULL,
                                               x_run_date_16may            => NULL,
                                               x_appno_decision_proc       => NULL,
                                               x_run_date_decision_proc    => NULL,
                                               x_appno_first_pre_num       => NULL,
                                               x_news                      => NULL,
                                               x_no_more_la_tran           => NULL,
                                               x_star_x_avail              => NULL,
                                               x_mode                      => 'R',
                                               x_appno_first_opf           => 0,
                                               x_appno_first_rpa_noneu     => 0,
                                               x_appno_first_rpa_eu        => 0,
                                               x_extra_start_date          => NULL,
                                               x_last_passport_date        => NULL,
                                               x_last_le_date              => NULL,
                                               x_system_code               => rec_cur_uc_ucas_control.system_code,
					       x_ucas_cycle                => l_next_cycle,
                                               x_gttr_clear_toy_code       => NULL,
                                               x_transaction_toy_code      => 'S'
                                             );

              fnd_message.set_name('IGS', 'IGS_UC_REC_INSRT');
              fnd_message.set_token('SYSTEM_CODE', rec_cur_uc_ucas_control.system_code);
              fnd_message.set_token('TNAME', 'IGS_UC_UCAS_CONTROL');
              fnd_file.put_line(fnd_file.log, fnd_message.get);
           END IF;
       END LOOP;

       -- Update the current_cycle to  maximum supported cycle in IGS_UC_DEFAULTS
       FOR rec_cur_defaults IN cur_defaults
       LOOP
           igs_uc_defaults_pkg.update_row ( x_rowid                        => rec_cur_defaults.rowid,
                                            x_current_inst_code            => rec_cur_defaults.current_inst_code,
                                            x_ucas_id_format               => rec_cur_defaults.ucas_id_format,
                                            x_test_app_no                  => rec_cur_defaults.test_app_no,
                                            x_test_choice_no               => rec_cur_defaults.test_choice_no,
                                            x_test_transaction_type        => rec_cur_defaults.test_transaction_type,
                                            x_copy_ucas_id                 => rec_cur_defaults.copy_ucas_id,
                                            x_mode                         => 'R',
                                            x_decision_make_id             => rec_cur_defaults.decision_make_id,
                                            x_decision_reason_id           => rec_cur_defaults.decision_reason_id,
                                            x_obsolete_outcome_status      => rec_cur_defaults.obsolete_outcome_status,
                                            x_pending_outcome_status       => rec_cur_defaults.pending_outcome_status,
                                            x_rejected_outcome_status      => rec_cur_defaults.rejected_outcome_status,
                                            x_system_code                  => rec_cur_defaults.system_code,
                                            x_ni_number_alt_pers_type      => rec_cur_defaults.ni_number_alt_pers_type,
                                            x_application_type             => rec_cur_defaults.application_type,
                                            x_name                         => rec_cur_defaults.name,
                                            x_description                  => rec_cur_defaults.description,
                                            x_ucas_security_key            => rec_cur_defaults.ucas_security_key,
                                            x_current_cycle                => l_next_cycle,
                                            x_configured_cycle             => rec_cur_defaults.configured_cycle,
                                            x_prev_inst_left_date          => rec_cur_defaults.prev_inst_left_date
			                 );

           fnd_message.set_name('IGS', 'IGS_UC_CRNT_CYCLE_UPDTD');
           fnd_message.set_token('SYSTEM_CODE', rec_cur_defaults.system_code);
           fnd_message.set_token('CRNT_CYCLE', l_next_cycle);
           fnd_file.put_line(fnd_file.log, fnd_message.get);
       END LOOP;

   END IF;

  EXCEPTION
       WHEN OTHERS THEN
           ROLLBACK;

           fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
           fnd_message.set_token('NAME','IGS_UC_START_NEW_CYCLE.START_NEW_CYCLE');
           fnd_file.put_line(fnd_file.log, fnd_message.get);
	   fnd_file.put_line(fnd_file.log, sqlerrm);
           errbuf  := fnd_message.get ;
           retcode := 2;
           igs_ge_msg_stack.conc_exception_hndl;

END start_new_cycle;

END igs_uc_start_new_cycle;

/
