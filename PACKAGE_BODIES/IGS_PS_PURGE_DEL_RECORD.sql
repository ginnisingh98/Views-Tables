--------------------------------------------------------
--  DDL for Package Body IGS_PS_PURGE_DEL_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_PURGE_DEL_RECORD" AS
/* $Header: IGSPS88B.pls 120.1 2005/06/29 05:12:28 appldev ship $ */


PROCEDURE purge_igs_ps_ofr_opt_all AS
/***********************************************************************************************

  Created By     :  Shtatiko
  Date Created By:  19-FEB-2003
  Purpose        :  To purge logically deleted records from the table IGS_PS_OFR_OPT_ALL.
                    If any child record exists for a logically deleted record then that
                    record will be updated such that it becomes active else it will be deleted.

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What
********************************************************************************************** */
CURSOR c_del_recs IS
SELECT rowid, a.*
FROM igs_ps_ofr_opt_all a
WHERE delete_flag = 'Y';

rec_del_recs c_del_recs%ROWTYPE;

l_b_purged  BOOLEAN ;
l_c_message VARCHAR2 (4000);
l_n_rec_count NUMBER(10);

BEGIN
  -- Create a Savepoint for Rollback
  SAVEPOINT igs_ps_ofr_opt_all ;

  fnd_file.put_line ( fnd_file.LOG, ' ' );
  fnd_message.set_name ( 'IGS', 'IGS_PS_OFR_OPT_PURGE' );
  fnd_file.put_line ( fnd_file.LOG, fnd_message.get );

  l_n_rec_count := 0;
  FOR rec_del_recs IN c_del_recs LOOP
    l_b_purged := TRUE;
    l_n_rec_count := l_n_rec_count + 1;
    BEGIN
      -- Call before_dml of the TBH to know whether the record can physically be deleted or not.
      igs_ps_ofr_opt_pkg.before_dml (
        p_action                => 'VALIDATE_DELETE' ,
        x_rowid                 => rec_del_recs.rowid ,
        x_course_cd             => rec_del_recs.course_cd ,
        x_version_number        => rec_del_recs.version_number ,
        x_cal_type              => rec_del_recs.cal_type ,
        x_location_cd           => rec_del_recs.location_cd ,
        x_attendance_mode       => rec_del_recs.attendance_mode ,
        x_attendance_type       => rec_del_recs.attendance_type ,
        x_coo_id                => rec_del_recs.coo_id ,
        x_forced_location_ind   => rec_del_recs.forced_location_ind ,
        x_forced_att_mode_ind   => rec_del_recs.forced_att_mode_ind ,
        x_forced_att_type_ind   => rec_del_recs.forced_att_type_ind ,
        x_time_limitation       => rec_del_recs.time_limitation ,
        x_enr_officer_person_id => rec_del_recs.enr_officer_person_id ,
        x_attribute_category    => rec_del_recs.attribute_category ,
        x_attribute1            => rec_del_recs.attribute1 ,
        x_attribute2            => rec_del_recs.attribute2 ,
        x_attribute3            => rec_del_recs.attribute3 ,
        x_attribute4            => rec_del_recs.attribute4 ,
        x_attribute5            => rec_del_recs.attribute5 ,
        x_attribute6            => rec_del_recs.attribute6 ,
        x_attribute7            => rec_del_recs.attribute7 ,
        x_attribute8            => rec_del_recs.attribute8 ,
        x_attribute9            => rec_del_recs.attribute9 ,
        x_attribute10           => rec_del_recs.attribute10 ,
        x_attribute11           => rec_del_recs.attribute11 ,
        x_attribute12           => rec_del_recs.attribute12 ,
        x_attribute13           => rec_del_recs.attribute13 ,
        x_attribute14           => rec_del_recs.attribute14 ,
        x_attribute15           => rec_del_recs.attribute15 ,
        x_attribute16           => rec_del_recs.attribute16 ,
        x_attribute17           => rec_del_recs.attribute17 ,
        x_attribute18           => rec_del_recs.attribute18 ,
        x_attribute19           => rec_del_recs.attribute19 ,
        x_attribute20           => rec_del_recs.attribute20 ,
        x_creation_date         => rec_del_recs.creation_date ,
        x_created_by            => rec_del_recs.created_by ,
        x_last_update_date      => rec_del_recs.last_update_date ,
        x_last_updated_by       => rec_del_recs.last_updated_by ,
        x_last_update_login     => rec_del_recs.last_update_login ,
        x_org_id                => rec_del_recs.org_id ,
        x_program_length        => rec_del_recs.program_length ,
        x_program_length_measurement => rec_del_recs.program_length_measurement
      );

    EXCEPTION
      WHEN OTHERS THEN
        -- Exception means that there are childs for the record in question.
        -- So deletion cannot be done and moreover, delete_flag is to be made 'N'
        -- to make it active record.
        l_b_purged := FALSE;

        -- Ignore the message stacked by TBH so delete the message from the stack.
        IGS_GE_MSG_STACK.DELETE_MSG ;

        -- Update the delete_flag to 'N'
        igs_ps_ofr_opt_pkg.update_row (
          x_rowid                 => rec_del_recs.rowid ,
          x_course_cd             => rec_del_recs.course_cd ,
          x_version_number        => rec_del_recs.version_number ,
          x_cal_type              => rec_del_recs.cal_type ,
          x_location_cd           => rec_del_recs.location_cd ,
          x_attendance_mode       => rec_del_recs.attendance_mode ,
          x_attendance_type       => rec_del_recs.attendance_type ,
          x_coo_id                => rec_del_recs.coo_id ,
          x_forced_location_ind   => rec_del_recs.forced_location_ind ,
          x_forced_att_mode_ind   => rec_del_recs.forced_att_mode_ind ,
          x_forced_att_type_ind   => rec_del_recs.forced_att_type_ind ,
          x_time_limitation       => rec_del_recs.time_limitation ,
          x_enr_officer_person_id => rec_del_recs.enr_officer_person_id ,
          x_attribute_category    => rec_del_recs.attribute_category ,
          x_attribute1            => rec_del_recs.attribute1 ,
          x_attribute2            => rec_del_recs.attribute2 ,
          x_attribute3            => rec_del_recs.attribute3 ,
          x_attribute4            => rec_del_recs.attribute4 ,
          x_attribute5            => rec_del_recs.attribute5 ,
          x_attribute6            => rec_del_recs.attribute6 ,
          x_attribute7            => rec_del_recs.attribute7 ,
          x_attribute8            => rec_del_recs.attribute8 ,
          x_attribute9            => rec_del_recs.attribute9 ,
          x_attribute10           => rec_del_recs.attribute10 ,
          x_attribute11           => rec_del_recs.attribute11 ,
          x_attribute12           => rec_del_recs.attribute12 ,
          x_attribute13           => rec_del_recs.attribute13 ,
          x_attribute14           => rec_del_recs.attribute14 ,
          x_attribute15           => rec_del_recs.attribute15 ,
          x_attribute16           => rec_del_recs.attribute16 ,
          x_attribute17           => rec_del_recs.attribute17 ,
          x_attribute18           => rec_del_recs.attribute18 ,
          x_attribute19           => rec_del_recs.attribute19 ,
          x_attribute20           => rec_del_recs.attribute20 ,
          x_program_length        => rec_del_recs.program_length ,
          x_program_length_measurement => rec_del_recs.program_length_measurement,
          x_delete_flag           => 'N'
        );
    END;

    IF l_b_purged THEN
      igs_ps_ofr_opt_pkg.delete_row ( x_rowid => rec_del_recs.rowid );
    END IF;

    -- Log the details of record and status of purging.
    fnd_file.put_line ( fnd_file.LOG, ' ');
    fnd_file.put_line ( fnd_file.LOG, ' ');
    fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'PROGRAM_CD' )
                                                  || '         : ' || rec_del_recs.course_cd );
    fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'VERSION_NUMBER' )
                                                  || '  : ' || rec_del_recs.version_number );
    fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'CAL_TYPE' )
                                                  || '   : ' || rec_del_recs.cal_type );
    fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'LOCATION_CD' )
                                                  || '   : ' || rec_del_recs.location_cd );
    fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'ATTENDANCE_MODE' )
                                                  || ' : ' || rec_del_recs.attendance_mode );
    fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'ATTENDANCE_TYPE' )
                                                  || ' : ' || rec_del_recs.attendance_type );
    IF l_b_purged THEN
      fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'DELETE_FLAG' )
                                                  || '     : ' || igs_ge_gen_004.genp_get_lookup ( 'TIMESLOT_ALPHABET', 'Y' ) );
      fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'STATUS' )
                                                  || '          : ' || igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'PURGED' ) );
    ELSE
      fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'DELETE_FLAG' )
                                                  || '     : ' || igs_ge_gen_004.genp_get_lookup ( 'TIMESLOT_ALPHABET', 'N' ) );
      fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'STATUS' )
                                                  || '          : ' || igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'UPDATED' ) );
    END IF;

  END LOOP;

  -- Log the number of records processed.
  fnd_message.set_name ( 'IGS', 'IGS_AD_TOT_REC_PRC' );
  fnd_message.set_token ( 'RCOUNT', l_n_rec_count );
  fnd_file.put_line ( fnd_file.LOG, ' ' );
  fnd_file.put_line ( fnd_file.LOG, fnd_message.get );

EXCEPTION  /* This exception handling is at table level */
  WHEN OTHERS THEN
    -- If any exception occurs, whole transaction should be rolled off.
    ROLLBACK TO igs_ps_ofr_opt_all;

    -- We have to log message stacked by TBH, if any. Otherwise, we will log the generic unhandled exception.
    l_c_message := fnd_message.get ;
    IF ( l_c_message IS NOT NULL ) THEN
      fnd_file.put_line ( fnd_file.LOG, l_c_message );
    ELSE
      fnd_message.set_name ( 'IGS', 'IGS_GE_UNHANDLED_EXP' );
      fnd_message.set_token ( 'NAME', 'purge_igs_ps_ofr_opt_all' );
      fnd_file.put_line ( fnd_file.LOG,  fnd_message.get || ' : ' || SQLERRM );
    END IF;

END purge_igs_ps_ofr_opt_all; /* End Of Processing IGS_PS_OFR_OPT_ALL records */



PROCEDURE purge_igs_ps_unit_ofr_pat_all AS
/***********************************************************************************************

  Created By     :  sarakshi
  Date Created By:  13-Jul-2004
  Purpose        :  To purge logically deleted records from the table IGS_PS_UNIT_OFR_PAT_ALL.
                    If any child record exists for a logically deleted record then that
                    record will be updated such that it becomes active else it will be deleted.

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What

********************************************************************************************** */
CURSOR c_del_recs IS
SELECT a.rowid, a.*
FROM igs_ps_unit_ofr_pat_all a
WHERE a.delete_flag = 'Y';
rec_del_recs c_del_recs%ROWTYPE;

CURSOR c_alt_code (cp_cal_type         igs_ca_inst_all.cal_type%TYPE,
                   cp_sequence_number  igs_ca_inst_all.sequence_number%TYPE) IS
SELECT alternate_code
FROM   igs_ca_inst_all
WHERE  cal_type        = cp_cal_type
AND    sequence_number = cp_sequence_number;

l_c_alt_code igs_ca_inst_all.alternate_code%TYPE;
l_b_purged  BOOLEAN ;
l_c_message VARCHAR2 (4000);
l_n_rec_count NUMBER(10);

BEGIN
  -- Create a Savepoint for Rollback
  SAVEPOINT igs_ps_unit_ofr_pat_all ;

  fnd_file.put_line ( fnd_file.LOG, ' ' );
  fnd_message.set_name ( 'IGS', 'IGS_PS_UOP_PURGE' );
  fnd_file.put_line ( fnd_file.LOG, fnd_message.get );

  l_n_rec_count := 0;
  FOR rec_del_recs IN c_del_recs LOOP
    l_b_purged := TRUE;
    l_n_rec_count := l_n_rec_count + 1;
    BEGIN
      -- Call before_dml of the TBH to know whether the record can physically be deleted or not.
      igs_ps_unit_ofr_pat_pkg.before_dml(
        p_action                        => 'VALIDATE_DELETE' ,
        x_rowid                         => rec_del_recs.rowid,
        x_unit_cd                       => rec_del_recs.unit_cd,
        x_version_number                => rec_del_recs.version_number,
        x_cal_type                      => rec_del_recs.cal_type,
        x_ci_sequence_number            => rec_del_recs.ci_sequence_number,
        x_ci_start_dt                   => rec_del_recs.ci_start_dt,
        x_ci_end_dt                     => rec_del_recs.ci_end_dt,
        x_waitlist_allowed              => rec_del_recs.waitlist_allowed,
        x_max_students_per_waitlist     => rec_del_recs.max_students_per_waitlist,
        x_creation_date                 => rec_del_recs.creation_date,
        x_created_by                    => rec_del_recs.created_by,
        x_last_update_date              => rec_del_recs.last_update_date,
        x_last_updated_by               => rec_del_recs.last_updated_by,
        x_last_update_login             => rec_del_recs.last_update_login,
        x_org_id                        => rec_del_recs.org_id,
        x_delete_flag                   => rec_del_recs.delete_flag ,
        x_abort_flag                    => rec_del_recs.abort_flag
      );

    EXCEPTION
      WHEN OTHERS THEN
        -- Exception means that there are childs for the record in question.
        -- So deletion cannot be done and moreover, delete_flag is to be made 'N'
        -- to make it active record.
        l_b_purged := FALSE;

        -- Ignore the message stacked by TBH so delete the message from the stack.
        IGS_GE_MSG_STACK.DELETE_MSG ;

        -- Update the delete_flag to 'N'
        igs_ps_unit_ofr_pat_pkg.update_row (
          x_rowid                     => rec_del_recs.rowid ,
          x_unit_cd                   => rec_del_recs.unit_cd,
          x_version_number            => rec_del_recs.version_number,
          x_ci_sequence_number        => rec_del_recs.ci_sequence_number,
          x_cal_type                  => rec_del_recs.cal_type,
          x_ci_start_dt               => rec_del_recs.ci_start_dt,
          x_ci_end_dt                 => rec_del_recs.ci_end_dt,
          x_waitlist_allowed          => rec_del_recs.waitlist_allowed,
          x_max_students_per_waitlist => rec_del_recs.max_students_per_waitlist,
          x_delete_flag               => 'N',
          x_abort_flag                => rec_del_recs.abort_flag
        );
    END;

    IF l_b_purged THEN
      igs_ps_unit_ofr_pat_pkg.delete_row ( x_rowid => rec_del_recs.rowid );
    END IF;

    -- Log the details of record and status of purging.
    fnd_file.put_line ( fnd_file.LOG, ' ');
    fnd_file.put_line ( fnd_file.LOG, ' ');
    fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'UNIT_CD' )
                                                  || '       : ' || rec_del_recs.unit_cd );
    fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'VERSION_NUMBER' )
                                                  || '  : ' || rec_del_recs.version_number );
    fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'CAL_TYPE' )
                                                  || '   : ' || rec_del_recs.cal_type );
    OPEN c_alt_code(rec_del_recs.cal_type,rec_del_recs.ci_sequence_number);
    FETCH c_alt_code INTO l_c_alt_code;
    CLOSE c_alt_code;
    fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'LEGACY_TOKENS', 'ALT_CODE' )
                                                  || '  : ' || l_c_alt_code );
    IF l_b_purged THEN
      fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'DELETE_FLAG' )
                                                  || '     : ' || igs_ge_gen_004.genp_get_lookup ( 'TIMESLOT_ALPHABET', 'Y' ) );
      fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'STATUS' )
                                                  || '          : ' || igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'PURGED' ) );
    ELSE
      fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'DELETE_FLAG' )
                                                  || '     : ' || igs_ge_gen_004.genp_get_lookup ( 'TIMESLOT_ALPHABET', 'N' ) );
      fnd_file.put_line ( fnd_file.LOG, igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'STATUS' )
                                                  || '          : ' || igs_ge_gen_004.genp_get_lookup ( 'IGS_PS_LOG_PARAMETERS', 'UPDATED' ) );
    END IF;

  END LOOP;

  -- Log the number of records processed.
  fnd_message.set_name ( 'IGS', 'IGS_AD_TOT_REC_PRC' );
  fnd_message.set_token ( 'RCOUNT', l_n_rec_count );
  fnd_file.put_line ( fnd_file.LOG, ' ' );
  fnd_file.put_line ( fnd_file.LOG, fnd_message.get );

EXCEPTION  /* This exception handling is at table level */
  WHEN OTHERS THEN
    -- If any exception occurs, whole transaction should be rolled off.
    ROLLBACK TO igs_ps_unit_ofr_pat_all;

    -- We have to log message stacked by TBH, if any. Otherwise, we will log the generic unhandled exception.
    l_c_message := fnd_message.get ;
    IF ( l_c_message IS NOT NULL ) THEN
      fnd_file.put_line ( fnd_file.LOG, l_c_message );
    ELSE
      fnd_message.set_name ( 'IGS', 'IGS_GE_UNHANDLED_EXP' );
      fnd_message.set_token ( 'NAME', 'purge_igs_ps_unit_ofr_pat_all' );
      fnd_file.put_line ( fnd_file.LOG,  fnd_message.get || ' : ' || SQLERRM );
    END IF;

END purge_igs_ps_unit_ofr_pat_all; /* End Of Processing IGS_PS_UNIT_OFR_PAT_ALL records */

PROCEDURE purge_ps_records AS
/***********************************************************************************************

  Created By     :  Shtatiko
  Date Created By:  19-FEB-2003
  Purpose        :  To purge logically deleted records from the tables, where logical delete
                    functionality is being used. If any child record exists for a logically deleted
                    record then that record will be updated such that it becomes active.
                    This package is specific for Program Structure and Planning module only i.e.,
                    this will process only tables of PSP module. The process will currently be
                    purging/activating logically deleted records for IGS_PS_OFR_OPT_ALL table.

  Known limitations,enhancements,remarks:
  Change History
  Who        When             What

********************************************************************************************** */


BEGIN

  -- This sub-process should take care of all the PS tables which have delete_flag.
  -- Processing of each table is independent in the sense that processing of each table
  -- should be treated as one transaction. So exceptions raised in processing of one table
  -- should not affect the processing of another table. So COMMIT, and ROLLBACK are at table level
  -- instead of at the module level.

  -- Begin Processing Records of IGS_PS_OFR_OPT_ALL table.
  purge_igs_ps_ofr_opt_all;


  -- Begin Processing Records of IGS_PS_UNIT_OFR_PAT_ALL table.
  purge_igs_ps_unit_ofr_pat_all;


EXCEPTION /* This exception handling is at Module Level */
  WHEN OTHERS THEN
    fnd_message.set_name ( 'IGS', 'IGS_GE_UNHANDLED_EXP' );
    fnd_message.set_token ( 'NAME', 'purge_ps_records' );
    fnd_file.put_line ( fnd_file.LOG,  fnd_message.get || ' : ' || SQLERRM );

END purge_ps_records;

END igs_ps_purge_del_record;

/
