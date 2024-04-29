--------------------------------------------------------
--  DDL for Package Body IGS_UC_EXPORT_UCAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_EXPORT_UCAS_PKG" AS
/* $Header: IGSUC27B.pls 120.5 2006/02/08 19:53:02 anwest ship $ */
l_abbrev_use        VARCHAR2(1)  DEFAULT  NULL;
l_rowid             VARCHAR2(26) DEFAULT  NULL;



  PROCEDURE export_data(Errbuf                  OUT NOCOPY VARCHAR2,
                        Retcode                 OUT NOCOPY NUMBER,
                        p_contact               IN  VARCHAR2,
                        p_program_details       IN  VARCHAR2,
                        p_keywords              IN  VARCHAR2,
                        p_abbreviations         IN  VARCHAR2,
                	p_ucas_transactions 	IN  VARCHAR2,
                	p_gttr_transactions 	IN  VARCHAR2,
                	p_nmas_transactions 	IN  VARCHAR2) IS
  /********************************************************************************
   Created By      : vbandaru
   Date Created By : 23-JAN-2002
   Purpose :

   Know limitations, enhancements or remarks
   Change History
   Who      When            What
   anwest   18-JAN-2006  Bug# 4950285 R12 Disable OSS Mandate
   jbaber   16-Aug-05    Modified for UC307 - HERCULES Small Systems Support
   jbaber   12-Jul-05    Modified for UC315 - UCAS Support 2006
                         Replaced reference to igs_uc_cvcontrol_2003_v with igs_uc_ucas_control
                         Removed references to export_inst_conts, export_inst_cnt_grp, export_crse_dets,
                         export_crse_vac_ops, export_crse_keywrds and export_offer_abbrev as these are no
                         longer supported by UCAS as updateable views.
   pmarada  03-Jul-03    Modified as per the UCFD203 build. bug 2669208

   (reverse chronological order - newest change first)
   ********************************************************************************/
    CURSOR cur_cycle IS
    SELECT MAX(current_cycle) current_cycle , MAX(configured_cycle) configured_cycle
    FROM igs_uc_defaults ;

    cur_cycle_rec cur_cycle%ROWTYPE;

    CURSOR cur_control (cp_system_code  igs_uc_ucas_control.system_code%TYPE) IS
    SELECT TO_NUMBER(LPAD(entry_year,4,200))
    FROM igs_uc_ucas_control
    WHERE system_code = cp_system_code
    AND ucas_cycle = cur_cycle_rec.configured_cycle;


    l_entry_year igs_uc_defaults.configured_cycle%TYPE;

    CURSOR cur_interface(cp_system_code  igs_uc_ucas_control.system_code%TYPE) IS
    SELECT ucas_interface FROM  igs_uc_cyc_defaults
    WHERE ucas_cycle = cur_cycle_rec.configured_cycle
    AND system_code = cp_system_code;
    l_interface igs_uc_cyc_defaults.ucas_interface%TYPE;

    validate_cycle   BOOLEAN := TRUE;

   BEGIN

      --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
      IGS_GE_GEN_003.SET_ORG_ID;

      -- Get current and configured cycle
      OPEN cur_cycle;
      FETCH cur_cycle INTO cur_cycle_rec;
      CLOSE cur_cycle;

      IF cur_cycle_rec.configured_cycle IS NULL OR cur_cycle_rec.current_cycle IS NULL THEN
           fnd_message.set_name('IGS','IGS_UC_CYCLE_NOT_FOUND');
           errbuf  := fnd_message.get;
           fnd_file.put_line(fnd_file.log, errbuf);
           retcode := 2 ;
           RETURN ;
      END IF ;

      -- Validate FTUG current and configured cycle
      IF (p_ucas_transactions = 'Y') THEN
          OPEN cur_control('U');
          FETCH cur_control INTO l_entry_year;
          CLOSE cur_control;
          -- If current cycle and configured cycle are same then write the transaction else log the message
          IF NVL(l_entry_year,0) <> cur_cycle_rec.configured_cycle THEN
             fnd_message.set_name('IGS','IGS_UC_CYCLES_NOT_SYNC');
             fnd_message.set_token('UCAS_CYCLE',cur_cycle_rec.configured_cycle);
             fnd_message.set_token('HERC_CYCLE',l_entry_year);
             fnd_message.set_token('SYSTEM_CODE','UCAS');
             fnd_file.put_line(fnd_file.log, fnd_message.get);
             errbuf  := fnd_message.get ;
             validate_cycle := FALSE;
          END IF;
      END IF;

      -- Validate GTTR current and configured cycle
      IF (p_gttr_transactions = 'Y') THEN
          OPEN cur_control('G');
          FETCH cur_control INTO l_entry_year;
          CLOSE cur_control;
          -- If current cycle and configured cycle are same then write the transaction else log the message
          IF NVL(l_entry_year,0) <> cur_cycle_rec.configured_cycle THEN
             fnd_message.set_name('IGS','IGS_UC_CYCLES_NOT_SYNC');
             fnd_message.set_token('UCAS_CYCLE',cur_cycle_rec.configured_cycle);
             fnd_message.set_token('HERC_CYCLE',l_entry_year);
             fnd_message.set_token('SYSTEM_CODE','GTTR');
             fnd_file.put_line(fnd_file.log, fnd_message.get);
             errbuf  := fnd_message.get ;
             validate_cycle := FALSE;
          END IF;
      END IF;

      -- Validate NMAS current and configured cycle
      IF (p_nmas_transactions = 'Y') THEN
          OPEN cur_control('N');
          FETCH cur_control INTO l_entry_year;
          CLOSE cur_control;
          -- If current cycle and configured cycle are same then write the transaction else log the message
          IF NVL(l_entry_year,0) <> cur_cycle_rec.configured_cycle THEN
             fnd_message.set_name('IGS','IGS_UC_CYCLES_NOT_SYNC');
             fnd_message.set_token('UCAS_CYCLE',cur_cycle_rec.configured_cycle);
             fnd_message.set_token('HERC_CYCLE',l_entry_year);
             fnd_message.set_token('SYSTEM_CODE','NMAS');
             fnd_file.put_line(fnd_file.log, fnd_message.get);
             errbuf  := fnd_message.get ;
             validate_cycle := FALSE;
          END IF;
      END IF;

      -- If any of the validations failed then exit process
      IF NOT validate_cycle THEN
          retcode := 2;
          RETURN;
      END IF;

      -- Export FTUG transactions if required
      IF (p_ucas_transactions = 'Y') THEN
          -- Make sure interface is set to H
          OPEN cur_interface ('U');
          FETCH cur_interface INTO l_interface;
          CLOSE cur_interface;
          IF l_interface = 'H' THEN
              --Exporting Transactions
              fnd_file.put_line(fnd_file.LOG, ' ');
              fnd_message.set_name( 'IGS','IGS_UC_EXP_TRANSACTIONS');
              fnd_message.set_token('SYSTEM_CODE','UCAS');
              fnd_file.put_line (FND_FILE.LOG,fnd_message.get);
              igs_uc_tran_processor_pkg.trans_write('U',Errbuf,Retcode);
          ELSE
              -- FTUG interface is MARVIN so log warning.
	      fnd_message.set_name('IGS','IGS_UC_MARVIN_INTERFACE');
	      fnd_message.set_token('SYSTEM_CODE','UCAS');
	      fnd_message.set_token('PROCESS','export');
	      fnd_file.put_line(fnd_file.log,fnd_message.get );
              retcode := 1;
          END IF;
      END IF;

      -- Export GTTR transactions if required
      IF (p_gttr_transactions = 'Y') THEN
          -- Make sure interface is set to H
          OPEN cur_interface ('G');
          FETCH cur_interface INTO l_interface;
          CLOSE cur_interface;
          IF l_interface = 'H' THEN
              --Exporting Transactions
              fnd_file.put_line(fnd_file.LOG, ' ');
              fnd_message.set_name( 'IGS','IGS_UC_EXP_TRANSACTIONS');
              fnd_message.set_token('SYSTEM_CODE','GTTR');
              fnd_file.put_line (FND_FILE.LOG,fnd_message.get);
              igs_uc_tran_processor_pkg.trans_write('G',Errbuf,Retcode);
          ELSE
              -- GTTR interface is MARVIN so log warning.
	      fnd_message.set_name('IGS','IGS_UC_MARVIN_INTERFACE');
	      fnd_message.set_token('SYSTEM_CODE','GTTR');
	      fnd_message.set_token('PROCESS','export');
	      fnd_file.put_line(fnd_file.log,fnd_message.get);
              retcode := 1;
          END IF;
      END IF;

      -- Export NMAS transactions if required
      IF (p_nmas_transactions = 'Y') THEN
          -- Make sure interface is set to H
          OPEN cur_interface ('N');
          FETCH cur_interface INTO l_interface;
          CLOSE cur_interface;
          IF l_interface = 'H' THEN
              --Exporting Transactions
              fnd_file.put_line(fnd_file.LOG, ' ');
              fnd_message.set_name( 'IGS','IGS_UC_EXP_TRANSACTIONS');
              fnd_message.set_token('SYSTEM_CODE','NMAS');
              fnd_file.put_line (FND_FILE.LOG,fnd_message.get);
              igs_uc_tran_processor_pkg.trans_write('N',Errbuf,Retcode);
          ELSE
              -- NMAS interface is MARVIN so log warning.
	      fnd_message.set_name('IGS','IGS_UC_MARVIN_INTERFACE');
	      fnd_message.set_token('SYSTEM_CODE','NMAS');
	      fnd_message.set_token('PROCESS','export');
	      fnd_file.put_line(fnd_file.log,fnd_message.get );
              retcode := 1;
          END IF;
      END IF;

      COMMIT;

  EXCEPTION

    WHEN OTHERS THEN
      ROLLBACK;
      retcode := 2;
      fnd_message.set_name( 'IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_UC_EXPORT_UCAS_PKG.EXPORT_DATA'||' - '||SQLERRM);
      errbuf := fnd_message.get;
      igs_ge_msg_stack.conc_exception_hndl;

  END export_data;

END igs_uc_export_ucas_pkg;

/
