--------------------------------------------------------
--  DDL for Package Body IGS_UC_LOAD_HERCULES_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_LOAD_HERCULES_DATA" AS
/* $Header: IGSUC42B.pls 120.10 2006/08/21 06:18:28 jbaber ship $  */


  -- global cursors and variables
     -- Get the cycle information from defaults
     CURSOR c_cyc_info IS
     SELECT MAX(current_cycle) current_cycle , MAX(configured_cycle) configured_cycle
     FROM   igs_uc_defaults ;
     g_cyc_info_rec         c_cyc_info%ROWTYPE ;

     CURSOR c_ucas_cycle (cp_system_code igs_uc_ucas_control.system_code%TYPE) IS
     SELECT entry_year
     FROM igs_uc_ucas_control
     WHERE system_code = cp_system_code
     AND ucas_cycle = g_cyc_info_rec.configured_cycle;
     c_ucas_cycle_rec  c_ucas_cycle%ROWTYPE ;

     -- Cursor to get the UCAS_INTERFACE
     CURSOR c_ucas_interface (cp_system_code igs_uc_cyc_defaults.system_code%TYPE) IS
     SELECT ucas_interface
     FROM IGS_UC_CYC_DEFAULTS
     WHERE system_code = cp_system_code
     AND ucas_cycle = g_cyc_info_rec.configured_cycle;
     c_ucas_interface_rec    igs_uc_cyc_defaults.ucas_interface%TYPE;

     -- get the timestamp value of the hercules views from cvrefammendment
     -- modified by jbaber
     --    added country and nationality so that 2003 version looks like 2007 version
     --    this allows us to base the global variable on 2007 version of refamendments
     CURSOR c_refamend_timestamp IS
     SELECT aprdate, disdate, errordate, ethnicdate, examdate, feedate,
            keyworddate, oeqdate, offerabbrevdate, offersubjdate, poccdate,
            rescatdate, awardbodydate, statusdate, ucasgroupdate, estabgroup,
            schooltype, tariffdate, jointadmissions,
            sysdate AS COUNTRY, sysdate AS NATIONALITY
     FROM igs_uc_u_cvrefamendments_2003 a;

     CURSOR c_refamend_timestamp_2007 IS
     SELECT aprdate, disdate, errordate, ethnicdate, examdate, feedate,
            keyworddate, oeqdate, offerabbrevdate, offersubjdate, poccdate,
            rescatdate, awardbodydate, statusdate, ucasgroupdate, estabgroup,
            schooltype, tariffdate, jointadmissions, country, nationality
     FROM igs_uc_u_cvrefamendments_2007 ;
     g_refamend_timestamp   c_refamend_timestamp_2007%ROWTYPE ;

     -- Added GTTR timestamp value of the hercules views from cvgrefamendments
     -- for bug 4638126
     CURSOR c_grefamend_timestamp IS
     SELECT *
     FROM igs_uc_g_cvgrefamendments_2006;
     g_grefamend_timestamp   c_grefamend_timestamp%ROWTYPE ;

     -- variable declarations
     g_sync_reqd            BOOLEAN;


   PROCEDURE write_to_log(p_message    IN VARCHAR2)
   IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   writes the passed message into the log file
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */
   BEGIN

      Fnd_File.Put_Line(Fnd_File.Log, p_message);

   END write_to_log;


  PROCEDURE herc_timestamp_exists ( p_view IN igs_uc_hrc_timstmps.view_name%TYPE ,
                                    p_herc_timestamp OUT NOCOPY igs_uc_hrc_timstmps.timestamp%TYPE )  IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   checks if the timestamp record for the passed view exists or not
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

    -- Get the timestamp value for the passed view for the passed ucas cycle
    CURSOR c_timestamp IS
    SELECT hrc.timestamp
    FROM igs_uc_hrc_timstmps hrc
    WHERE view_name = p_view
     AND  ucas_cycle = g_cyc_info_rec.configured_cycle ;
    c_timestamp_rec c_timestamp%ROWTYPE ;

    l_rowid VARCHAR2(50) ;

  BEGIN

      -- if timestamp record exists for this view then return true else return false
      c_timestamp_rec := NULL ;
      OPEN c_timestamp ;
      FETCH c_timestamp INTO c_timestamp_rec ;
      IF c_timestamp%NOTFOUND THEN
          p_herc_timestamp := NULL ;
      ELSE
           p_herc_timestamp := c_timestamp_rec.timestamp ;
      END IF ;
      CLOSE c_timestamp ;
      RETURN  ;


  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.HERC_TIMESTAMP_EXISTS');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END herc_timestamp_exists;


  PROCEDURE ins_upd_timestamp( p_view IN igs_uc_hrc_timstmps.view_name%TYPE ,
                               p_new_max_timestamp IN igs_uc_hrc_timstmps.timestamp%TYPE )
  IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   inserts/updates hercules timestamp record for passed view
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

    l_rowid VARCHAR2(50) ;

  BEGIN

      -- Initializations
      l_rowid := NULL ;

      -- if timestamp record is not found for this view in passed cycle then insert new record with the passed timestamp
      -- else update its timestamp value with the passed timestamp
          igs_uc_hrc_timstmps_pkg.add_row(
                      x_rowid           => l_rowid,
                      x_view_name       => p_view ,
                      x_ucas_cycle      => g_cyc_info_rec.configured_cycle ,
                      x_timestamp       => p_new_max_timestamp,
                      x_mode            => 'R' );

          RETURN  ;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.INS_UPD_TIMESTAMP');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END ins_upd_timestamp;


  PROCEDURE log_start ( p_view_name VARCHAR2)
  IS
   /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   logs messages of start of loading views
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */
  BEGIN
       -- log message that this view is being loaded
       fnd_message.set_name('IGS','IGS_UC_VW_PROCESSING' );
       fnd_message.set_token('VIEW_NAME', p_view_name ||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
       fnd_file.put_line(fnd_file.Log, fnd_message.get);

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOG_START');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END log_start;

  PROCEDURE log_complete (  p_view_name VARCHAR2 ,
                p_count NUMBER )
  IS
   /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   logs messages of completion of loading views
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */
  BEGIN
       -- log message that this view has been succesfully loaded
       fnd_message.set_name('IGS','IGS_UC_VW_SYNC_COMPLETE' );
       fnd_message.set_token('VIEW_NAME', p_view_name );
       fnd_file.put_line(fnd_file.Log, fnd_message.get ) ;

       -- log message that p_count number of records have been processed
       fnd_message.set_name('IGS','IGS_UC_REC_CNT_PROC' );
       fnd_message.set_token('REC_CNT', p_count );
       fnd_file.put_line(fnd_file.Log, fnd_message.get ) ;


  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOG_COMPLETE');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END log_complete;


  PROCEDURE log_already_insync(  p_view_name VARCHAR2)
  IS
   /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   logs messages of completion of loading views
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */
  BEGIN
       -- log message that this view has been succesfully loaded
       fnd_message.set_name('IGS','IGS_UC_VW_ALREADY_IN_SYNC' );
       fnd_message.set_token('VIEW_NAME', p_view_name );
       fnd_file.put_line(fnd_file.Log, fnd_message.get) ;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOG_ALREADY_INSYNC');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END log_already_insync;


  PROCEDURE get_appno (p_appno_in       IN  VARCHAR2,
                       p_checkdigit_in  IN  VARCHAR2,
                       p_appno_out      OUT NOCOPY NUMBER,
                       p_checkdigit_out OUT NOCOPY NUMBER ) IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :  12-Jul-05
     Purpose         :  return appno and checkdigit according to configured year
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

  BEGIN


      -- Check configure year
      IF g_cyc_info_rec.configured_cycle < 2006 THEN
          -- If 2003-2005 appno_out = appno_in
          p_appno_out := p_appno_in;
          p_checkdigit_out := p_checkdigit_in;
      ELSE
          -- If 2006(+) must extract appno and check_digit
          p_appno_out := TO_NUMBER(SUBSTR(LPAD(p_appno_in,9,0),1,8));
          p_checkdigit_out := TO_NUMBER(SUBSTR(LPAD(p_appno_in,9,0),9,1));

      END IF;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.GET_APPNO');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;

  END get_appno;


  FUNCTION is_valid(  p_value      VARCHAR2,
                      p_viewname   VARCHAR2,
                      p_fieldname  VARCHAR2,
                      p_datatype   VARCHAR2
                     ) RETURN BOOLEAN AS

    /*
    ||  Created By : jbaber
    ||  Created On :
    ||  Purpose    : function which return TRUE if the passed value
    ||               can be convertable into NUMBER else return FALSE and logs error.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
    return_value        BOOLEAN         := FALSE;
    ln_number           NUMBER;

  BEGIN

    -- Check whether the passed value can be convertable to number of not.
    -- If the value can not be convertable to number catch the exception and return FALSE.
    BEGIN
      ln_number := TO_NUMBER(p_value);
      return_value := TRUE;

    EXCEPTION
      WHEN VALUE_ERROR THEN
        -- log message that this line has not been loaded
    fnd_message.set_name('IGS','IGS_UC_VAR_VALIDATE' );
    fnd_message.set_token('VIEW_NAME', p_viewname);
    fnd_message.set_token('FIELD_NAME', p_fieldname );
    fnd_message.set_token('FIELD_VALUE', p_value );
    fnd_message.set_token('DATA_TYPE',p_datatype);
        fnd_file.put_line(fnd_file.Log, fnd_message.get ) ;

        return_value := FALSE;
    END;

    RETURN return_value;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_UC_LOAD_HERCULES_DATA.IS_VALID - '||SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

  END is_valid;


  PROCEDURE load_cvcourse_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view CVCOURSE into the interface table
                         igs_uc_ccrse_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     jbaber    15-Sep-05    Replace campus value with '*' if NULL for bug 4589994
     jbaber    11-Jul-06    Added system_code field to igs_uc_ccrse_ints
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvcourse( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT DECODE(RTRIM(inst),NULL, RPAD('*',LENGTH(inst),'*'), RTRIM(inst)) inst
          ,DECODE(RTRIM(course),NULL, RPAD('*',LENGTH(course),'*'), RTRIM(course)) course
          ,NVL(DECODE(RTRIM(campus),NULL, RPAD('*',LENGTH(campus),'*'), RTRIM(campus)),'*') campus
          ,timestamp
          ,RTRIM(faculty) faculty
          ,RTRIM(shortname) shortname
          ,RTRIM(longname) longname
          ,RTRIM(validcurrent) validcurrent
          ,RTRIM(validdefer) validdefer
          ,RTRIM(jointadmission) jointadmission
          ,RTRIM(openextra) openextra
      FROM igs_uc_u_cvcourse_2003
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_u_cvcourse_2003 ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_u_cvcourse_2003.timestamp%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVCOURSE ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVCOURSE', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_cvcourse_rec IN c_cvcourse(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- Obsolete matching records in interface table with status N
              UPDATE igs_uc_ccrse_ints SET record_status = 'O'
              WHERE record_status = 'N' AND course = c_cvcourse_rec.course
              AND campus = c_cvcourse_rec.campus AND inst = c_cvcourse_rec.inst ;

              -- copy hercules record into interface table with record status N
              INSERT INTO igs_uc_ccrse_ints (    inst,
                                                 course,
                                                 campus,
                                                 faculty,
                                                 shortname,
                                                 longname,
                                                 validcurrent,
                                                 validdefer,
                                                 jointadmission,
                                                 openextra,
                                                 system_code,
                                                 record_status,
                                                 error_code  )
                                     VALUES (    c_cvcourse_rec.inst,
                                                 c_cvcourse_rec.course,
                                                 c_cvcourse_rec.campus,
                                                 c_cvcourse_rec.faculty,
                                                 c_cvcourse_rec.shortname,
                                                 c_cvcourse_rec.longname,
                                                 c_cvcourse_rec.validcurrent,
                                                 c_cvcourse_rec.validdefer,
                                                 c_cvcourse_rec.jointadmission,
                                                 c_cvcourse_rec.openextra,
                                                 'U',
                                                 'N',
                                                 NULL) ;
              -- increment count of records
              l_count := l_count + 1;

       END LOOP ;

       IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVCOURSE',l_new_max_timestamp) ;

               -- log message that this view has been loaded
               log_complete('CVCOURSE', l_count) ;
       ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVCOURSE') ;
       END IF ;
       COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVCOURSE_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_cvcourse_2003  ;


  PROCEDURE load_cvgcourse_2007 IS
    /******************************************************************
     Created By      :   jbaber
     Date Created By :   11-Jun-06
     Purpose         :   loads each record in the hercules view CVGCOURSE into the interface table
                         igs_uc_ccrse_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvgcourse( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT DECODE(RTRIM(inst),NULL, RPAD('*',LENGTH(inst),'*'), RTRIM(inst)) inst
          ,DECODE(RTRIM(course),NULL, RPAD('*',LENGTH(course),'*'), RTRIM(course)) course
          ,NVL(DECODE(RTRIM(campus),NULL, RPAD('*',LENGTH(campus),'*'), RTRIM(campus)),'*') campus
          ,timestamp
          ,RTRIM(SUBSTR(longname,1,20)) shortname
          ,RTRIM(longname) longname
      FROM igs_uc_g_cvgcourse_2007
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_g_cvgcourse_2007 ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_g_cvgcourse_2007.timestamp%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVGCOURSE ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVGCOURSE', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_cvgcourse_rec IN c_cvgcourse(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- Obsolete matching records in interface table with status N
              UPDATE igs_uc_ccrse_ints SET record_status = 'O'
              WHERE record_status = 'N' AND course = c_cvgcourse_rec.course
              AND campus = c_cvgcourse_rec.campus AND inst = c_cvgcourse_rec.inst ;

              -- copy hercules record into interface table with record status N
              INSERT INTO igs_uc_ccrse_ints (    inst,
                                                 course,
                                                 campus,
                                                 shortname,
                                                 longname,
                                                 system_code,
                                                 record_status,
                                                 error_code  )
                                     VALUES (    c_cvgcourse_rec.inst,
                                                 c_cvgcourse_rec.course,
                                                 c_cvgcourse_rec.campus,
                                                 c_cvgcourse_rec.shortname,
                                                 c_cvgcourse_rec.longname,
                                                 'G',
                                                 'N',
                                                 NULL) ;
              -- increment count of records
              l_count := l_count + 1;

       END LOOP ;

       IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVGCOURSE',l_new_max_timestamp) ;

               -- log message that this view has been loaded
               log_complete('CVGCOURSE', l_count) ;
       ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVGCOURSE') ;
       END IF ;
       COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVGCOURSE_2007');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_cvgcourse_2007  ;


  PROCEDURE load_cvncourse_2007 IS
    /******************************************************************
     Created By      :   jbaber
     Date Created By :   11-Jun-06
     Purpose         :   loads each record in the hercules view CVNCOURSE into the interface table
                         igs_uc_ccrse_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvncourse( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT DECODE(RTRIM(inst),NULL, RPAD('*',LENGTH(inst),'*'), RTRIM(inst)) inst
          ,DECODE(RTRIM(course),NULL, RPAD('*',LENGTH(course),'*'), RTRIM(course)) course
          ,NVL(DECODE(RTRIM(campus),NULL, RPAD('*',LENGTH(campus),'*'), RTRIM(campus)),'*') campus
          ,timestamp
          ,RTRIM(shortname) shortname
          ,RTRIM(longname) longname
      FROM igs_uc_n_cvncourse_2007
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_n_cvncourse_2007 ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_n_cvncourse_2007.timestamp%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVNCOURSE ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVNCOURSE', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_cvncourse_rec IN c_cvncourse(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- Obsolete matching records in interface table with status N
              UPDATE igs_uc_ccrse_ints SET record_status = 'O'
              WHERE record_status = 'N' AND course = c_cvncourse_rec.course
              AND campus = c_cvncourse_rec.campus AND inst = c_cvncourse_rec.inst ;

              -- copy hercules record into interface table with record status N
              INSERT INTO igs_uc_ccrse_ints (    inst,
                                                 course,
                                                 campus,
                                                 shortname,
                                                 longname,
                                                 system_code,
                                                 record_status,
                                                 error_code  )
                                     VALUES (    c_cvncourse_rec.inst,
                                                 c_cvncourse_rec.course,
                                                 c_cvncourse_rec.campus,
                                                 c_cvncourse_rec.shortname,
                                                 c_cvncourse_rec.longname,
                                                 'N',
                                                 'N',
                                                 NULL) ;
              -- increment count of records
              l_count := l_count + 1;

       END LOOP ;

       IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVNCOURSE',l_new_max_timestamp) ;

               -- log message that this view has been loaded
               log_complete('CVNCOURSE', l_count) ;
       ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVNCOURSE') ;
       END IF ;
       COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVNCOURSE_2007');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_cvncourse_2007  ;


  PROCEDURE load_cveblsubject_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view CVEBLSUBJECT into the interface table
                         igs_uc_ceblsbj_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     jbaber    15-Sep-05    Replace sitting and awardingbody values with '*' if NULL
                            for bug 4589994
     jchakrab  24-Mar-06    Removed ROWID from columns selected in c_cvebl - 5114377
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvebl( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT
           subjectid
          ,timestamp
          ,year
          ,NVL(DECODE(RTRIM(sitting),NULL, RPAD('*',LENGTH(sitting),'*'), RTRIM(sitting)),'*') sitting
          ,NVL(DECODE(RTRIM(awardingbody),NULL, RPAD('*',LENGTH(awardingbody),'*'), RTRIM(awardingbody)),'*') awardingbody
          ,RTRIM(externalref) externalref
          ,DECODE(RTRIM(examlevel),NULL, RPAD('*',LENGTH(examlevel),'*'), RTRIM(examlevel)) examlevel
          ,RTRIM(title) title
          ,RTRIM(subjcode) subjcode
      FROM igs_uc_u_cveblsubject_2003
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_u_cveblsubject_2003 ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_u_cveblsubject_2003.timestamp%TYPE ;
      l_count NUMBER ;


  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVEBLSUBJECT ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVEBLSUBJECT',p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_cvebl_rec IN c_cvebl(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- Obsolete matching records in interface table with status N
              UPDATE igs_uc_ceblsbj_ints SET record_status = 'O'
              WHERE  record_status = 'N' AND subjectid = c_cvebl_rec.subjectid  ;

              -- copy hercules record into interface table with record status N
              INSERT INTO igs_uc_ceblsbj_ints ( subjectid,
                                                year,
                                                sitting,
                                                awardingbody,
                                                externalref,
                                                examlevel,
                                                title,
                                                subjcode,
                                                record_status,
                                                error_code  )
                                     VALUES (    c_cvebl_rec.subjectid,
                                                 c_cvebl_rec.year,
                                                 c_cvebl_rec.sitting,
                                                 c_cvebl_rec.awardingbody,
                                                 c_cvebl_rec.externalref,
                                                 c_cvebl_rec.examlevel,
                                                 c_cvebl_rec.title,
                                                 c_cvebl_rec.subjcode,
                                                 'N',
                                                 NULL) ;
          -- increment count of records
          l_count := l_count + 1;

       END LOOP ;

       IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVEBLSUBJECT',l_new_max_timestamp) ;
               -- log message that this view has been loaded
                log_complete('CVEBLSUBJECT', l_count) ;
       ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVEBLSUBJECT') ;
       END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVEBLSUBJECT_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_cveblsubject_2003  ;


  PROCEDURE load_cvinstitution_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :    loads each record in the hercules view CVINSTITUTION into the interface table
                         igs_uc_ceblsbj_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     jchin     7-Mar-05     Modified for bug #4103556/4124010 Defaulted SWAS column to 'N'
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvinst( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT DECODE(RTRIM(inst),NULL, RPAD('*',LENGTH(inst),'*'), RTRIM(inst)) inst
          ,timestamp
          ,RTRIM(instcode) instcode
          ,RTRIM(instname) instname
          ,RTRIM(ucas) ucas
          ,RTRIM(gttr) gttr
          ,'N' swas
          ,RTRIM(nmas) nmas
      FROM igs_uc_u_cvinstitution_2003
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_u_cvinstitution_2003 ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_u_cvinstitution_2003.timestamp%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
        log_start('CVINSTITUTION ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVINSTITUTION', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_cvinst_rec IN c_cvinst(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- Obsolete matching records in interface table with status N
              UPDATE igs_uc_cinst_ints SET record_status = 'O'
              WHERE record_status = 'N' AND inst = c_cvinst_rec.inst  ;

              -- copy hercules record into interface table with record status N
              INSERT INTO igs_uc_cinst_ints (   inst,
                                                instcode,
                                                instname,
                                                ucas,
                                                gttr,
                                                swas,
                                                nmas,
                                                record_status,
                                                error_code  )
                                     VALUES (    c_cvinst_rec.inst,
                                                 c_cvinst_rec.instcode,
                                                 c_cvinst_rec.instname,
                                                 c_cvinst_rec.ucas,
                                                 c_cvinst_rec.gttr,
                                                 c_cvinst_rec.swas,
                                                 c_cvinst_rec.nmas,
                                                 'N',
                                                 NULL) ;
        -- increment count of records
        l_count := l_count + 1;

       END LOOP ;

       IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVINSTITUTION', l_new_max_timestamp) ;

              -- log message that this view has been loaded
              log_complete('CVINSTITUTION', l_count) ;
       ELSE
               -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVINSTITUTION') ;
       END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVINSTITUTION_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_cvinstitution_2003  ;


  PROCEDURE load_cvjointadmissions_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view CVJOINTADMISSIONS into the interface table
                         igs_uc_cjntadm_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     jbaber    15-Sep-05    Replace parentinst1 value with '*' if NULL for bug 4589994
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvjntadm IS
      SELECT DECODE(RTRIM(childinst),NULL, RPAD('*',LENGTH(childinst),'*'), RTRIM(childinst)) childinst
          ,NVL(DECODE(RTRIM(parentinst1),NULL, RPAD('*',LENGTH(parentinst1),'*'), RTRIM(parentinst1)),'*') parentinst1
          ,RTRIM(parentinst2) parentinst2
          ,RTRIM(parentinst3) parentinst3
          ,RTRIM(parentinst4) parentinst4
          ,RTRIM(parentinst5) parentinst5
      FROM igs_uc_u_cvjntadmissions_2003 ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_u_cvrefamendments_2003.jointadmissions%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVJOINTADMISSIONS ON ') ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_refamend_timestamp.jointadmissions ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVJOINTADMISSIONS', p_old_timestamp) ;


      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

              -- Obsolete all records in interface table with status N
              UPDATE igs_uc_cjntadm_ints SET record_status = 'O' WHERE record_status = 'N' ;

               -- create interface records for each record in the hercules view
               FOR c_cvjntadm_rec IN c_cvjntadm LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      -- copy hercules record into interface table with record status N
                      INSERT INTO igs_uc_cjntadm_ints ( childinst,
                                                        parentinst1,
                                                        parentinst2,
                                                        parentinst3,
                                                        parentinst4,
                                                        parentinst5,
                                                        record_status,
                                                        error_code )
                                             VALUES (    c_cvjntadm_rec.childinst,
                                                         c_cvjntadm_rec.parentinst1,
                                                         c_cvjntadm_rec.parentinst2,
                                                         c_cvjntadm_rec.parentinst3,
                                                         c_cvjntadm_rec.parentinst4,
                                                         c_cvjntadm_rec.parentinst5,
                                                         'N',
                                                         NULL) ;
            -- increment count of records
            l_count := l_count + 1;

               END LOOP ;
      END IF ;

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVJOINTADMISSIONS', l_new_max_timestamp) ;

              -- log message that this view has been loaded
              log_complete('CVJOINTADMISSIONS', l_count) ;
      ELSE
              -- log message that this view is already in sync and need not be loaded
              log_already_insync('CVJOINTADMISSIONS') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVJOINTADMISSIONS_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_cvjointadmissions_2003  ;


  PROCEDURE load_cvrefapr_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view CVREFAPR into the interface table
                         igs_uc_crapr_ints  with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvapr IS
      SELECT dom
           ,RTRIM(domtext) domtext
           ,RTRIM(leaflag) leaflag
      FROM igs_uc_u_cvrefapr_2003  ;


      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_u_cvrefamendments_2003.aprdate%TYPE ;
      l_count NUMBER ;


  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVREFAPR ON ') ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_refamend_timestamp.aprdate ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVREFAPR', p_old_timestamp) ;

      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

               -- Obsolete all records in interface table with status N
               UPDATE igs_uc_crapr_ints SET record_status = 'O' WHERE record_status = 'N' ;

               -- create interface records for each record in the hercules view
               FOR c_cvapr_rec IN c_cvapr LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      --Validate varchar to number conversion
                      IF  is_valid(c_cvapr_rec.dom,'CVREFAPR','DOM','NUMBER') THEN

                          -- copy hercules record into interface table with record status N
                          INSERT INTO igs_uc_crapr_ints (   dom,
                                                            domtext,
                                                            leaflag,
                                                            record_status,
                                                            error_code )
                                                 VALUES (    c_cvapr_rec.dom,
                                                             c_cvapr_rec.domtext,
                                                             c_cvapr_rec.leaflag,
                                                             'N',
                                                             NULL) ;
                          -- increment count of records
                          l_count := l_count + 1;

                      END IF;

               END LOOP ;
      END IF ;  -- old and new timetamps differ

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVREFAPR',l_new_max_timestamp) ;

              -- log message that this view has been loaded
              log_complete('CVREFAPR', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFAPR') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFAPR_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_cvrefapr_2003  ;


  PROCEDURE load_cvrefawardbody_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view CVREFAWARDBODY into the interface table
                         igs_uc_crawdbd_ints   with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvawb IS
      SELECT year
           ,DECODE(RTRIM(sitting),NULL, RPAD('*',LENGTH(sitting),'*'), RTRIM(sitting)) sitting
           ,DECODE(RTRIM(awardingbody),NULL, RPAD('*',LENGTH(awardingbody),'*'), RTRIM(awardingbody)) awardingbody
           ,RTRIM(bodyname) bodyname
           ,RTRIM(bodyabbrev) bodyabbrev
      FROM igs_uc_u_cvrefawardbody_2003   ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_u_cvrefamendments_2003.awardbodydate%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVREFAWARDBODY ON ' ) ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_refamend_timestamp.awardbodydate ;


      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVREFAWARDBODY', p_old_timestamp) ;
      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

               -- Obsolete all records in interface table with status N
               UPDATE igs_uc_crawdbd_ints SET record_status = 'O' WHERE record_status = 'N' ;

               -- create interface records for each record in the hercules view
               FOR c_cvawb_rec IN c_cvawb LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      -- copy hercules record into interface table with record status N
                      INSERT INTO igs_uc_crawdbd_ints (  year,
                                                         sitting,
                                                         awardingbody,
                                                         bodyname,
                                                         bodyabbrev,
                                                         record_status,
                                                         error_code)
                                             VALUES (    c_cvawb_rec.year,
                                                         c_cvawb_rec.sitting,
                                                         c_cvawb_rec.awardingbody,
                                                         c_cvawb_rec.bodyname,
                                                         c_cvawb_rec.bodyabbrev,
                                                         'N',
                                                         NULL) ;
            -- increment count of records
            l_count := l_count + 1;

               END LOOP ;
      END IF ;  -- old and new timetamps differ

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVREFAWARDBODY', l_new_max_timestamp) ;

                -- log message that this view has been loaded
                log_complete('CVREFAWARDBODY', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFAWARDBODY') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFAWARDBODY_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_cvrefawardbody_2003   ;

  PROCEDURE load_cvrefdis_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :    loads each record in the hercules view cvrefdis into the interface table
                         igs_uc_crfcode_ints with record status N and code_type = DC
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvdis IS
      SELECT dis
           ,RTRIM(distext) distext
      FROM igs_uc_u_cvrefdis_2003    ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_u_cvrefamendments_2003.disdate%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
        log_start('CVREFDIS ON ') ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_refamend_timestamp.disdate ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVREFDIS',p_old_timestamp) ;
      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

               -- Obsolete all records in interface table with status N
               UPDATE igs_uc_crfcode_ints  SET record_status = 'O' WHERE record_status = 'N' AND code_type= 'DC' ;

               -- create interface records for each record in the hercules view
               FOR c_cvdis_rec IN c_cvdis LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      -- copy hercules record into interface table with record status N
                      INSERT INTO igs_uc_crfcode_ints (  code_type,
                                                         code,
                                                         code_text,
                                                         record_status,
                                                         error_code )
                                             VALUES (    'DC',
                                                         c_cvdis_rec.dis,
                                                         c_cvdis_rec.distext,
                                                         'N',
                                                         NULL) ;
            -- increment count of records
            l_count := l_count + 1;

               END LOOP ;
      END IF ;  -- old and new timetamps differ

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVREFDIS', l_new_max_timestamp) ;

                 -- log message that this view has been loaded
                 log_complete('CVREFDIS', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFDIS') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFDIS_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END    load_cvrefdis_2003 ;

  PROCEDURE load_cvreferror_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :    loads each record in the hercules view cvreferror into the interface table
                         igs_uc_crfcode_ints with record status N and code_type = EC
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cverr IS
      SELECT errorcode
           ,RTRIM(errordescription) errordescription
      FROM igs_uc_u_cvreferror_2003     ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_u_cvrefamendments_2003.errordate%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVREFERROR ON ' ) ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_refamend_timestamp.errordate ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVREFERROR',p_old_timestamp) ;
      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

               -- Obsolete all records in interface table with status N
               UPDATE igs_uc_crfcode_ints  SET record_status = 'O' WHERE record_status = 'N' AND code_type= 'EC' ;

               -- create interface records for each record in the hercules view
               FOR c_cverr_rec IN c_cverr LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      -- copy hercules record into interface table with record status N
                      INSERT INTO igs_uc_crfcode_ints (  code_type,
                                                         code,
                                                         code_text,
                                                         record_status,
                                                         error_code )
                                             VALUES (    'EC',
                                                         c_cverr_rec.errorcode,
                                                         c_cverr_rec.errordescription,
                                                         'N',
                                                         NULL) ;
            -- increment count of records
            l_count := l_count + 1;

               END LOOP ;
      END IF ;  -- old and new timetamps differ

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVREFERROR',l_new_max_timestamp) ;

                 -- log message that this view has been loaded
                log_complete('CVREFERROR', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFERROR') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFERROR_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_cvreferror_2003   ;


  PROCEDURE load_cvrefestgroup_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :    loads each record in the hercules view cvrefestgroup into the interface table
                         igs_uc_crfcode_ints with record status N and code_type = EG
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvest IS
      SELECT DECODE(RTRIM(estabgrp),NULL, RPAD('*',LENGTH(estabgrp),'*'), RTRIM(estabgrp)) estabgrp
           ,RTRIM(estabtext) estabtext
      FROM igs_uc_u_cvrefestgroup_2003      ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_u_cvrefamendments_2003.estabgroup%TYPE ;
      l_count NUMBER ;


  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVREFESTGROUP ON ') ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_refamend_timestamp.estabgroup ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVREFESTGROUP', p_old_timestamp) ;
      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

               -- Obsolete all records in interface table with status N
               UPDATE igs_uc_crfcode_ints  SET record_status = 'O' WHERE record_status = 'N' AND code_type= 'EG' ;

               -- create interface records for each record in the hercules view
               FOR c_cvest_rec IN c_cvest LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      -- copy hercules record into interface table with record status N
                      INSERT INTO igs_uc_crfcode_ints (  code_type,
                                                         code,
                                                         code_text,
                                                         record_status,
                                                         error_code )
                                             VALUES (    'EG',
                                                         c_cvest_rec.estabgrp,
                                                         c_cvest_rec.estabtext,
                                                         'N',
                                                         NULL) ;
            -- increment count of records
            l_count := l_count + 1;

               END LOOP ;
      END IF ;  -- old and new timetamps differ

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVREFESTGROUP', l_new_max_timestamp) ;

                -- log message that this view has been loaded
                log_complete('CVREFESTGROUP', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFESTGROUP') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFESTGROUP_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_cvrefestgroup_2003  ;


  PROCEDURE load_cvrefethnic_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view cvrefethnic into the interface table
                         igs_uc_crfcode_ints with record status N and code_type = ET
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cveth IS
      SELECT ethnic
           ,RTRIM(ethnictext) ethnictext
      FROM igs_uc_u_cvrefethnic_2003       ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_u_cvrefamendments_2003.ethnicdate%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVREFETHNIC ON ') ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_refamend_timestamp.ethnicdate ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVREFETHNIC', p_old_timestamp) ;
      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

               -- Obsolete all records in interface table with status N
               UPDATE igs_uc_crfcode_ints  SET record_status = 'O' WHERE record_status = 'N' AND code_type= 'ET' ;

               -- create interface records for each record in the hercules view
               FOR c_cveth_rec IN c_cveth LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      -- copy hercules record into interface table with record status N
                      INSERT INTO igs_uc_crfcode_ints (  code_type,
                                                         code,
                                                         code_text,
                                                         record_status,
                                                         error_code )
                                             VALUES (    'ET',
                                                         c_cveth_rec.ethnic,
                                                         c_cveth_rec.ethnictext,
                                                         'N',
                                                         NULL) ;
            -- increment count of records
            l_count := l_count + 1;

               END LOOP ;
      END IF ;  -- old and new timetamps differ

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVREFETHNIC', l_new_max_timestamp) ;

                 -- log message that this view has been loaded
                  log_complete('CVREFETHNIC', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFETHNIC') ;
       END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFETHNIC_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_cvrefethnic_2003  ;

  PROCEDURE load_cvrefexam_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view cvrefexam into the interface table
                         igs_uc_crfcode_ints with record status N and code_type = EL
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvexam IS
      SELECT DECODE(RTRIM(examlevel),NULL, RPAD('*',LENGTH(examlevel),'*'), RTRIM(examlevel)) examlevel
           ,RTRIM(examtext) examtext
      FROM igs_uc_u_cvrefexam_2003  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_u_cvrefamendments_2003.examdate%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
        log_start('CVREFEXAM ON ' ) ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_refamend_timestamp.examdate ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVREFEXAM', p_old_timestamp) ;
      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

               -- Obsolete all records in interface table with status N
               UPDATE igs_uc_crfcode_ints  SET record_status = 'O' WHERE record_status = 'N' AND code_type= 'EL' ;

               -- create interface records for each record in the hercules view
               FOR c_cvexam_rec IN c_cvexam LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      -- copy hercules record into interface table with record status N
                      INSERT INTO igs_uc_crfcode_ints (  code_type,
                                                         code,
                                                         code_text,
                                                         record_status,
                                                         error_code )
                                             VALUES (    'EL',
                                                         c_cvexam_rec.examlevel,
                                                         c_cvexam_rec.examtext,
                                                         'N',
                                                         NULL) ;
            -- increment count of records
            l_count := l_count + 1;

               END LOOP ;
      END IF ;  -- old and new timetamps differ

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVREFEXAM',  l_new_max_timestamp) ;

            -- log message that this view has been loaded
            log_complete('CVREFEXAM', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFEXAM') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFEXAM_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_cvrefexam_2003  ;

  PROCEDURE load_cvreffee_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view cvreffee into the interface table
                         igs_uc_crfcode_ints with record status N and code_type = FC
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvfee IS
      SELECT feepayer
           ,RTRIM(feetext) feetext
      FROM igs_uc_u_cvreffee_2003 ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_u_cvrefamendments_2003.feedate%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVREFFEE ON ') ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_refamend_timestamp.feedate ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVREFFEE', p_old_timestamp) ;
      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

               -- Obsolete all records in interface table with status N
               UPDATE igs_uc_crfcode_ints  SET record_status = 'O' WHERE record_status = 'N' AND code_type= 'FC' ;

               -- create interface records for each record in the hercules view
               FOR c_cvfee_rec IN c_cvfee LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      -- copy hercules record into interface table with record status N
                      INSERT INTO igs_uc_crfcode_ints (  code_type,
                                                         code,
                                                         code_text,
                                                         record_status,
                                                         error_code )
                                             VALUES (    'FC',
                                                         c_cvfee_rec.feepayer,
                                                         c_cvfee_rec.feetext,
                                                         'N',
                                                         NULL) ;
            -- increment count of records
            l_count := l_count + 1;

               END LOOP ;
      END IF ;  -- old and new timetamps differ

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVREFFEE', l_new_max_timestamp) ;

                -- log message that this view has been loaded
                log_complete('CVREFFEE', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
                log_already_insync('CVREFFEE') ;
       END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFFEE_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_cvreffee_2003  ;

  PROCEDURE load_cvrefkeyword_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view cvrefkeyword into the interface table
                         igs_uc_crkywd_ints  with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvkyw IS
      SELECT DECODE(RTRIM(keyword),NULL, RPAD('*',LENGTH(keyword),'*'), RTRIM(keyword)) keyword
      FROM igs_uc_u_cvrefkeyword_2003 ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_u_cvrefamendments_2003.keyworddate%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVREFKEYWORD ON ') ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_refamend_timestamp.keyworddate ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVREFKEYWORD', p_old_timestamp) ;
      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

               -- Obsolete all records in interface table with status N
               UPDATE igs_uc_crkywd_ints   SET record_status = 'O' WHERE record_status = 'N' ;

               -- create interface records for each record in the hercules view
               FOR c_cvkyw_rec IN c_cvkyw LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      -- copy hercules record into interface table with record status N
                      INSERT INTO igs_uc_crkywd_ints (   keyword,
                                                         record_status,
                                                         error_code )
                                             VALUES (    c_cvkyw_rec.keyword,
                                                         'N',
                                                         NULL) ;
            -- increment count of records
            l_count := l_count + 1;

               END LOOP ;
      END IF ;  -- old and new timestamps differ

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVREFKEYWORD',l_new_max_timestamp) ;

                  -- log message that this view has been loaded
                 log_complete('CVREFKEYWORD', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFKEYWORD') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFKEYWORD_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_cvrefkeyword_2003  ;

  PROCEDURE load_cvrefoeq_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view cvrefoeq into the interface table
                          igs_uc_crfcode_ints with record status N and code_type = OC
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvoeq IS
      SELECT DECODE(RTRIM(oeq),NULL, RPAD('*',LENGTH(oeq),'*'), RTRIM(oeq)) oeq
           ,RTRIM(oeqtext) oeqtext
      FROM igs_uc_u_cvrefoeq_2003  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_u_cvrefamendments_2003.oeqdate%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
      log_start('CVREFOEQ ON ') ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_refamend_timestamp.oeqdate ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVREFOEQ', p_old_timestamp) ;
      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

               -- Obsolete all records in interface table with status N
               UPDATE igs_uc_crfcode_ints  SET record_status = 'O' WHERE record_status = 'N' AND code_type= 'OC' ;

               -- create interface records for each record in the hercules view
               FOR c_cvoeq_rec IN c_cvoeq LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      -- copy hercules record into interface table with record status N
                      INSERT INTO igs_uc_crfcode_ints (  code_type,
                                                         code,
                                                         code_text,
                                                         record_status,
                                                         error_code )
                                             VALUES (    'OC',
                                                         c_cvoeq_rec.oeq,
                                                         c_cvoeq_rec.oeqtext,
                                                         'N',
                                                         NULL) ;
            -- increment count of records
            l_count := l_count + 1;

               END LOOP ;
      END IF ;  -- old and new timetamps differ

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVREFOEQ',  l_new_max_timestamp) ;

           -- log message that this view has been loaded
              log_complete('CVREFOEQ', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFOEQ') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFOEQ_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_cvrefoeq_2003  ;

  PROCEDURE load_cvrefofferabbrev_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view cvrefofferabbrev into the interface table
                         igs_uc_croffab_ints  with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvoffabr IS
      SELECT DECODE(RTRIM(abbrevcode),NULL, RPAD('*',LENGTH(abbrevcode),'*'), RTRIM(abbrevcode)) abbrevcode
        ,RTRIM(abbrevtext) abbrevtext
        ,DECODE(RTRIM(letterformat),NULL, RPAD('*',LENGTH(letterformat),'*'), RTRIM(letterformat)) letterformat
        ,RTRIM(summarychar) summarychar
        ,RTRIM(uncond) uncond
        ,RTRIM(withdrawal) withdrawal
        ,RTRIM(release) release
        ,RTRIM(tariff) tariff
      FROM igs_uc_u_cvrefofferabbrev_2003  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_u_cvrefamendments_2003.offerabbrevdate%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVREFOFFERABBREV ON ') ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_refamend_timestamp.offerabbrevdate ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVREFOFFERABBREV', p_old_timestamp) ;
      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

               -- Obsolete all records in interface table with status N
               UPDATE igs_uc_croffab_ints   SET record_status = 'O' WHERE record_status = 'N' ;

               -- create interface records for each record in the hercules view
               FOR c_cvoffabr_rec IN c_cvoffabr LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      -- copy hercules record into interface table with record status N
                      INSERT INTO igs_uc_croffab_ints ( abbrevcode,
                                                        abbrevtext,
                                                        letterformat,
                                                        summarychar,
                                                        uncond,
                                                        withdrawal,
                                                        release,
                                                        tariff,
                                                        record_status,
                                                        error_code )
                                             VALUES (   c_cvoffabr_rec.abbrevcode,
                                                        c_cvoffabr_rec.abbrevtext,
                                                        c_cvoffabr_rec.letterformat,
                                                        c_cvoffabr_rec.summarychar,
                                                        c_cvoffabr_rec.uncond,
                                                        c_cvoffabr_rec.withdrawal,
                                                        c_cvoffabr_rec.release,
                                                        c_cvoffabr_rec.tariff,
                                                        'N',
                                                        NULL) ;
            -- increment count of records
            l_count := l_count + 1;

               END LOOP ;
      END IF ;  -- old and new timestamps differ

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVREFOFFERABBREV',l_new_max_timestamp) ;

              -- log message that this view has been loaded
              log_complete('CVREFOFFERABBREV', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFOFFERABBREV') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFOFFERABBREV_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_cvrefofferabbrev_2003   ;


  PROCEDURE load_cvrefoffersubj_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view cvrefoffersubj into the interface table
                          igs_uc_crfcode_ints with record status N and code_type = SB
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvoffsbj IS
      SELECT DECODE(RTRIM(subjcode),NULL, RPAD('*',LENGTH(subjcode),'*'), RTRIM(subjcode)) subjcode
           ,RTRIM(subjtext) subjtext
      FROM igs_uc_u_cvrefoffersubj_2003   ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_u_cvrefamendments_2003.offersubjdate%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVREFOFFERSUBJ ON ') ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_refamend_timestamp.offersubjdate ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVREFOFFERSUBJ', p_old_timestamp) ;
      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

               -- Obsolete all records in interface table with status N
               UPDATE igs_uc_crfcode_ints  SET record_status = 'O' WHERE record_status = 'N' AND code_type= 'SB' ;

               -- create interface records for each record in the hercules view
               FOR c_cvoffsbj_rec IN c_cvoffsbj LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      -- copy hercules record into interface table with record status N
                      INSERT INTO igs_uc_crfcode_ints (  code_type,
                                                         code,
                                                         code_text,
                                                         record_status,
                                                         error_code )
                                             VALUES (    'SB',
                                                         c_cvoffsbj_rec.subjcode,
                                                         c_cvoffsbj_rec.subjtext,
                                                         'N',
                                                         NULL) ;
            -- increment count of records
            l_count := l_count + 1;

               END LOOP ;
      END IF ;  -- old and new timetamps differ

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVREFOFFERSUBJ',  l_new_max_timestamp) ;

                -- log message that this view has been loaded
                log_complete('CVREFOFFERSUBJ', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFOFFERSUBJ') ;
      END IF;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFOFFERSUBJ_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_cvrefoffersubj_2003  ;

  PROCEDURE load_cvrefpocc_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view cvrefpocc into the interface table
                          igs_uc_crefpoc_ints  with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvpocc IS
      SELECT pocc
          ,socialclass
          ,RTRIM(occupationtext) occupationtext
          ,RTRIM(alternativetext) alternativetext
          ,alternateclass1
          ,alternateclass2
          ,socioeconomic
      FROM igs_uc_u_cvrefpocc_2003 ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_u_cvrefamendments_2003.poccdate%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVREFPOCC ON ') ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_refamend_timestamp.poccdate ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVREFPOCC', p_old_timestamp) ;
      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

               -- Obsolete all records in interface table with status N
               UPDATE igs_uc_crefpoc_ints   SET record_status = 'O' WHERE record_status = 'N' ;

               -- create interface records for each record in the hercules view
               FOR c_cvpocc_rec IN c_cvpocc LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      --Validate varchar to number conversion
                      IF  is_valid(c_cvpocc_rec.pocc ,'CVREFPOCC','POCC','NUMBER') AND
                          is_valid(c_cvpocc_rec.socialclass ,'CVREFPOCC','SocialClass','NUMBER') AND
                          is_valid(c_cvpocc_rec.alternateclass1,'CVREFPOCC','AlternateClass1','NUMBER') AND
                          is_valid(c_cvpocc_rec.alternateclass2,'CVREFPOCC','AlternateClass2','NUMBER') AND
                          is_valid(c_cvpocc_rec.socioeconomic,'CVREFPOCC','SocioEconomic','NUMBER') THEN

                          -- copy hercules record into interface table with record status N
                          INSERT INTO igs_uc_crefpoc_ints  ( pocc,
                                                             socialclass,
                                                             occupationtext,
                                                             alternativetext,
                                                             alternateclass1,
                                                             alternateclass2,
                                                             socioeconomic,
                                                             record_status,
                                                             error_code )
                                                 VALUES (   c_cvpocc_rec.pocc,
                                                            c_cvpocc_rec.socialclass,
                                                            c_cvpocc_rec.occupationtext,
                                                            c_cvpocc_rec.alternativetext,
                                                            c_cvpocc_rec.alternateclass1,
                                                            c_cvpocc_rec.alternateclass2,
                                                            c_cvpocc_rec.socioeconomic,
                                                            'N',
                                                            NULL) ;
                          -- increment count of records
                          l_count := l_count + 1;

                      END IF;

               END LOOP ;
      END IF ;  -- old and new timestamps differ

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVREFPOCC',  l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('CVREFPOCC', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFPOCC') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFPOCC_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_cvrefpocc_2003   ;

  PROCEDURE load_cvrefrescat_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :    loads each record in the hercules view cvrefrescat into the interface table
                           igs_uc_crfcode_ints with record status N and code_type = RC
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvrescat IS
      SELECT DECODE(RTRIM(rescat),NULL, RPAD('*',LENGTH(rescat),'*'), RTRIM(rescat)) rescat
           ,RTRIM(rescattext) rescattext
      FROM igs_uc_u_cvrefrescat_2003  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_u_cvrefamendments_2003.rescatdate%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVREFRESCAT ON ') ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_refamend_timestamp.rescatdate ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVREFRESCAT', p_old_timestamp) ;
      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

               -- Obsolete all records in interface table with status N
               UPDATE igs_uc_crfcode_ints  SET record_status = 'O' WHERE record_status = 'N' AND code_type= 'RC' ;

               -- create interface records for each record in the hercules view
               FOR c_cvrescat_rec IN c_cvrescat LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      -- copy hercules record into interface table with record status N
                      INSERT INTO igs_uc_crfcode_ints (  code_type,
                                                         code,
                                                         code_text,
                                                         record_status,
                                                         error_code )
                                             VALUES (    'RC',
                                                         c_cvrescat_rec.rescat,
                                                         c_cvrescat_rec.rescattext,
                                                         'N',
                                                         NULL) ;
            -- increment count of records
            l_count := l_count + 1;

               END LOOP ;
      END IF ;  -- old and new timetamps differ

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVREFRESCAT',l_new_max_timestamp) ;

               -- log message that this view has been loaded
                log_complete('CVREFRESCAT', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFRESCAT') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFRESCAT_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END    load_cvrefrescat_2003 ;

  PROCEDURE load_cvrefschooltype_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view cvrefschooltype into the interface table
                           igs_uc_crfcode_ints with record status N and code_type = ST
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvschtyp IS
      SELECT DECODE(RTRIM(schooltype),NULL, RPAD('*',LENGTH(schooltype),'*'), RTRIM(schooltype)) schooltype
           ,RTRIM(schooltext) schooltext
      FROM igs_uc_u_cvrefschooltype_2003   ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_u_cvrefamendments_2003.schooltype%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVREFSCHOOLTYPE ON ') ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_refamend_timestamp.schooltype ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVREFSCHOOLTYPE',p_old_timestamp) ;
      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

               -- Obsolete all records in interface table with status N
               UPDATE igs_uc_crfcode_ints  SET record_status = 'O' WHERE record_status = 'N' AND code_type= 'ST' ;

               -- create interface records for each record in the hercules view
               FOR c_cvschtyp_rec IN c_cvschtyp LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      -- copy hercules record into interface table with record status N
                      INSERT INTO igs_uc_crfcode_ints (  code_type,
                                                         code,
                                                         code_text,
                                                         record_status,
                                                         error_code )
                                             VALUES (    'ST',
                                                         c_cvschtyp_rec.schooltype,
                                                         c_cvschtyp_rec.schooltext,
                                                         'N',
                                                         NULL) ;
            -- increment count of records
            l_count := l_count + 1;

               END LOOP ;
      END IF ;  -- old and new timetamps differ

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVREFSCHOOLTYPE',l_new_max_timestamp) ;

             -- log message that this view has been loaded
               log_complete('CVREFSCHOOLTYPE', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFSCHOOLTYPE') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFSCHOOLTYPE_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END    load_cvrefschooltype_2003 ;

  PROCEDURE load_cvrefstatus_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view cvrefstatus into the interface table
                           igs_uc_crfcode_ints with record status N and code_type = SC
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvstatus IS
      SELECT status
           ,RTRIM(statustext) statustext
      FROM igs_uc_u_cvrefstatus_2003    ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_u_cvrefamendments_2003.statusdate%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVREFSTATUS ON ' ) ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_refamend_timestamp.statusdate ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVREFSTATUS', p_old_timestamp) ;
      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

               -- Obsolete all records in interface table with status N
               UPDATE igs_uc_crfcode_ints  SET record_status = 'O' WHERE record_status = 'N' AND code_type= 'SC' ;

               -- create interface records for each record in the hercules view
               FOR c_cvstatus_rec IN c_cvstatus LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      -- copy hercules record into interface table with record status N
                      INSERT INTO igs_uc_crfcode_ints (  code_type,
                                                         code,
                                                         code_text,
                                                         record_status,
                                                         error_code )
                                             VALUES (    'SC',
                                                         c_cvstatus_rec.status,
                                                         c_cvstatus_rec.statustext,
                                                         'N',
                                                         NULL) ;
            -- increment count of records
            l_count := l_count + 1;

               END LOOP ;
      END IF ;  -- old and new timetamps differ

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVREFSTATUS', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('CVREFSTATUS', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFSTATUS') ;
      END IF;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFSTATUS_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END    load_cvrefstatus_2003 ;

  PROCEDURE load_cvreftariff_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :  loads each record in the hercules view cvreftariff into the interface table
                          igs_uc_ctariff_ints  with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvtariff IS
      SELECT DECODE(RTRIM(examlevel),NULL, RPAD('*',LENGTH(examlevel),'*'), RTRIM(examlevel)) examlevel
          ,DECODE(RTRIM(examgrade),NULL, RPAD('*',LENGTH(examgrade),'*'), RTRIM(examgrade)) examgrade
          ,DECODE(RTRIM(tariffscore),NULL, RPAD('*',LENGTH(tariffscore),'*'), RTRIM(tariffscore)) tariffscore
      FROM igs_uc_u_cvreftariff_2003  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_u_cvrefamendments_2003.tariffdate%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVREFTARIFF ON ') ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_refamend_timestamp.tariffdate ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVREFTARIFF', p_old_timestamp) ;
      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

               -- Obsolete all records in interface table with status N
               UPDATE igs_uc_ctariff_ints   SET record_status = 'O' WHERE record_status = 'N' ;

               -- create interface records for each record in the hercules view
               FOR c_cvtariff_rec IN c_cvtariff LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      -- copy hercules record into interface table with record status N
                      INSERT INTO igs_uc_ctariff_ints  ( examlevel,
                                                         examgrade,
                                                         tariffscore,
                                                         record_status,
                                                         error_code )
                                             VALUES (   c_cvtariff_rec.examlevel,
                                                        c_cvtariff_rec.examgrade,
                                                        c_cvtariff_rec.tariffscore,
                                                        'N',
                                                        NULL) ;
            -- increment count of records
            l_count := l_count + 1;

               END LOOP ;
      END IF ;  -- old and new timestamps differ

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVREFTARIFF',  l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('CVREFTARIFF', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFTARIFF') ;
       END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFTARIFF_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_cvreftariff_2003  ;

  PROCEDURE load_cvrefucasgroup_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view cvrefucasgroup into the interface table
                           igs_uc_crfcode_ints with record status N and code_type = GN
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvugroup IS
      SELECT groupno
           ,RTRIM(groupname) groupname
      FROM igs_uc_u_cvrefucasgroup_2003   ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_u_cvrefamendments_2003.ucasgroupdate%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVREFUCASGROUP ON ') ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_refamend_timestamp.ucasgroupdate ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVREFUCASGROUP', p_old_timestamp) ;
      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

               -- Obsolete all records in interface table with status N
               UPDATE igs_uc_crfcode_ints  SET record_status = 'O' WHERE record_status = 'N' AND code_type= 'GN' ;

               -- create interface records for each record in the hercules view
               FOR c_cvugroup_rec IN c_cvugroup LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      -- copy hercules record into interface table with record status N
                      INSERT INTO igs_uc_crfcode_ints (  code_type,
                                                         code,
                                                         code_text,
                                                         record_status,
                                                         error_code )
                                             VALUES (    'GN',
                                                         c_cvugroup_rec.groupno,
                                                         c_cvugroup_rec.groupname,
                                                         'N',
                                                         NULL) ;
            -- increment count of records
            l_count := l_count + 1;

               END LOOP ;
      END IF ;  -- old and new timetamps differ

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVREFUCASGROUP', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('CVREFUCASGROUP', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFUCASGROUP') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFUCASGROUP_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_cvrefucasgroup_2003  ;

  PROCEDURE load_cvschool_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view cvschool into the interface table
                           igs_uc_cvsch_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     jbaber    15-Sep-05    Replace estabgrp value with '*' if NULL for bug 4589994
     jbaber    11-Jul-06    Truncate NCN to 5 chars for UCAS 2007 Support
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvschool( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT school
          ,DECODE(RTRIM(sitecode),NULL, RPAD('*',LENGTH(sitecode),'*'), RTRIM(sitecode)) sitecode
          ,timestamp
          ,RTRIM(schoolname) schoolname
          ,namechangedate
          ,RTRIM(formername) formername
          ,RTRIM(SUBSTR(ncn,1,5)) ncn
          ,RTRIM(edexcelncn) edexcelncn
          ,RTRIM(dfeecode) dfeecode
          ,country
          ,RTRIM(lea) lea
          ,RTRIM(ucasstatus) ucasstatus
          ,NVL(DECODE(RTRIM(estabgrp),NULL, RPAD('*',LENGTH(estabgrp),'*'), RTRIM(estabgrp)),'*') estabgrp
          ,RTRIM(schooltype) schooltype
          ,statsdate
          ,noroll
          ,no5th
          ,no6th
          ,nohe
          ,RTRIM(address1) address1
          ,RTRIM(address2) address2
          ,RTRIM(address3) address3
          ,RTRIM(address4) address4
          ,RTRIM(postcode) postcode
          ,mailsort
          ,RTRIM(townkey) townkey
          ,RTRIM(countykey) countykey
          ,RTRIM(countrycode) countrycode
      FROM igs_uc_u_cvschool_2003
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_u_cvschool_2003  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_u_cvschool_2003.timestamp%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVSCHOOL ON ' ) ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVSCHOOL', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_cvschool_rec IN c_cvschool(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              --Validate varchar to number conversion
              IF  is_valid(c_cvschool_rec.school,'CVSCHOOL','School','NUMBER') AND
                  is_valid(c_cvschool_rec.country,'CVSCHOOL','Country','NUMBER') THEN

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_cvsch_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND school = c_cvschool_rec.school ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_cvsch_ints (   school,
                                                    sitecode,
                                                    schoolname,
                                                    namechangedate,
                                                    formername,
                                                    ncn,
                                                    edexcelncn,
                                                    dfeecode,
                                                    country,
                                                    lea,
                                                    ucasstatus,
                                                    estabgrp,
                                                    schooltype,
                                                    statsdate,
                                                    noroll,
                                                    no5th,
                                                    no6th,
                                                    nohe,
                                                    address1,
                                                    address2,
                                                    address3,
                                                    address4,
                                                    postcode,
                                                    mailsort,
                                                    townkey,
                                                    countykey,
                                                    countrycode,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   c_cvschool_rec.school,
                                                    NVL(c_cvschool_rec.sitecode,'A'),
                                                    c_cvschool_rec.schoolname,
                                                    c_cvschool_rec.namechangedate,
                                                    c_cvschool_rec.formername,
                                                    c_cvschool_rec.ncn,
                                                    c_cvschool_rec.edexcelncn,
                                                    c_cvschool_rec.dfeecode,
                                                    c_cvschool_rec.country,
                                                    c_cvschool_rec.lea,
                                                    c_cvschool_rec.ucasstatus,
                                                    c_cvschool_rec.estabgrp,
                                                    c_cvschool_rec.schooltype,
                                                    c_cvschool_rec.statsdate,
                                                    c_cvschool_rec.noroll,
                                                    c_cvschool_rec.no5th,
                                                    c_cvschool_rec.no6th,
                                                    c_cvschool_rec.nohe,
                                                    c_cvschool_rec.address1,
                                                    c_cvschool_rec.address2,
                                                    c_cvschool_rec.address3,
                                                    c_cvschool_rec.address4,
                                                    c_cvschool_rec.postcode,
                                                    c_cvschool_rec.mailsort,
                                                    c_cvschool_rec.townkey,
                                                    c_cvschool_rec.countykey,
                                                    c_cvschool_rec.countrycode,
                                                     'N',
                                                     NULL) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVSCHOOL',   l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('CVSCHOOL', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVSCHOOL') ;
       END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVSCHOOL_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_cvschool_2003   ;


  PROCEDURE load_cvschoolcontact_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view cvschoolcontact into the interface table
                           igs_uc_cschcnt_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvschcnt( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT school
          ,DECODE(RTRIM(sitecode),NULL, RPAD('*',LENGTH(sitecode),'*'), RTRIM(sitecode)) sitecode
          ,contactcode
          ,timestamp
          ,RTRIM(contactpost) contactpost
          ,RTRIM(contactname) contactname
          ,RTRIM(telephone) telephone
          ,RTRIM(fax) fax
          ,RTRIM(email) email
          ,RTRIM(principal) principal
          ,RTRIM(lists) lists
          ,RTRIM(orders) orders
          ,RTRIM(forms) forms
          ,RTRIM(referee) referee
          ,RTRIM(careers) careers
          ,RTRIM(eascontact) eascontact
      FROM igs_uc_u_cvschoolcontact_2003
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_u_cvschoolcontact_2003  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_u_cvschoolcontact_2003.timestamp%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
        log_start('CVSCHOOLCONTACT ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVSCHOOLCONTACT', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_cvschcnt_rec IN c_cvschcnt(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              --Validate varchar to number conversion
              IF  is_valid(c_cvschcnt_rec.school,'CVSCHOOLCONTACT','School','NUMBER') AND
                  is_valid(c_cvschcnt_rec.contactcode,'CVSCHOOLCONTACT','ContactCode','NUMBER') THEN

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_cschcnt_ints SET record_status = 'O'
                  WHERE  record_status = 'N' AND school = c_cvschcnt_rec.school
                  AND sitecode = NVL(c_cvschcnt_rec.sitecode,'A') AND contactcode = c_cvschcnt_rec.contactcode  ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_cschcnt_ints ( school,
                                                    sitecode,
                                                    contactcode,
                                                    contactpost,
                                                    contactname,
                                                    telephone,
                                                    fax,
                                                    email,
                                                    principal,
                                                    lists,
                                                    orders,
                                                    forms,
                                                    referee,
                                                    careers,
                                                    eascontact,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   c_cvschcnt_rec.school,
                                                    NVL(c_cvschcnt_rec.sitecode,'A'),
                                                    c_cvschcnt_rec.contactcode,
                                                    c_cvschcnt_rec.contactpost,
                                                    c_cvschcnt_rec.contactname,
                                                    c_cvschcnt_rec.telephone,
                                                    c_cvschcnt_rec.fax,
                                                    c_cvschcnt_rec.email,
                                                    c_cvschcnt_rec.principal,
                                                    c_cvschcnt_rec.lists,
                                                    c_cvschcnt_rec.orders,
                                                    c_cvschcnt_rec.forms,
                                                    c_cvschcnt_rec.referee,
                                                    c_cvschcnt_rec.careers,
                                                    c_cvschcnt_rec.eascontact,
                                                     'N',
                                                     NULL) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVSCHOOLCONTACT', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('CVSCHOOLCONTACT', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVSCHOOLCONTACT') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVSCHOOLCONTACT_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_cvschoolcontact_2003   ;


  PROCEDURE load_uvcontact_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :    loads each record in the hercules view uvcontact into the interface table
                           igs_uc_ucntact_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_uvcnt( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT DECODE(RTRIM(contactcode),NULL, RPAD('*',LENGTH(contactcode),'*'), RTRIM(contactcode)) contactcode
          ,timestamp
          ,RTRIM(updater) updater
          ,DECODE(RTRIM(name),NULL, RPAD('*',LENGTH(name),'*'), RTRIM(name)) name
          ,DECODE(RTRIM(post),NULL, RPAD('*',LENGTH(post),'*'), RTRIM(post)) post
          ,DECODE(RTRIM(address1),NULL, RPAD('*',LENGTH(address1),'*'), RTRIM(address1)) address1
          ,RTRIM(address2) address2
          ,RTRIM(address3) address3
          ,RTRIM(address4) address4
          ,RTRIM(telephone) telephone
          ,RTRIM(email) email
          ,RTRIM(fax) fax
      FROM igs_uc_u_uvcontact_2003
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_u_uvcontact_2003  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_u_uvcontact_2003.timestamp%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
        log_start('UVCONTACT ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('UVCONTACT', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_uvcnt_rec IN c_uvcnt(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- Obsolete matching records in interface table with status N
              UPDATE igs_uc_ucntact_ints SET record_status = 'O'
              WHERE record_status = 'N' AND contactcode = c_uvcnt_rec.contactcode  ;

              -- copy hercules record into interface table with record status N
              INSERT INTO igs_uc_ucntact_ints (  contactcode,
                                                 updater,
                                                 name,
                                                 post,
                                                 address1,
                                                 address2,
                                                 address3,
                                                 address4,
                                                 telephone,
                                                 email,
                                                 fax,
                                                record_status,
                                                error_code
                                                 )
                                     VALUES (   c_uvcnt_rec.contactcode,
                                                c_uvcnt_rec.updater,
                                                c_uvcnt_rec.name,
                                                c_uvcnt_rec.post,
                                                c_uvcnt_rec.address1,
                                                c_uvcnt_rec.address2,
                                                c_uvcnt_rec.address3,
                                                c_uvcnt_rec.address4,
                                                c_uvcnt_rec.telephone,
                                                c_uvcnt_rec.email,
                                                c_uvcnt_rec.fax,
                                                 'N',
                                                 NULL) ;
        -- increment count of records
        l_count := l_count + 1;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('UVCONTACT', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('UVCONTACT', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('UVCONTACT') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_UVCONTACT_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_uvcontact_2003   ;


  PROCEDURE load_uvcontgrp_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :    loads each record in the hercules view uvcontgrp into the interface table
                           igs_uc_ucntgrp_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_uvcntgr( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT DECODE(RTRIM(contactcode),NULL, RPAD('*',LENGTH(contactcode),'*'), RTRIM(contactcode)) contactcode
          ,ucasgroup
          ,RTRIM(updater) updater
          ,timestamp
      FROM igs_uc_u_uvcontgrp_2003
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_u_uvcontgrp_2003  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_u_uvcontgrp_2003.timestamp%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('UVCONTGRP ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('UVCONTGRP', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_uvcntgr_rec IN c_uvcntgr(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- Obsolete matching records in interface table with status N
              UPDATE igs_uc_ucntgrp_ints SET record_status = 'O'
              WHERE record_status = 'N' AND contactcode = c_uvcntgr_rec.contactcode
              AND ucasgroup =  c_uvcntgr_rec.ucasgroup ;

              -- copy hercules record into interface table with record status N
              INSERT INTO igs_uc_ucntgrp_ints (  contactcode,
                                                 ucasgroup,
                                                 updater,
                                                 record_status,
                                                 error_code
                                                 )
                                     VALUES (   c_uvcntgr_rec.contactcode,
                                                c_uvcntgr_rec.ucasgroup,
                                                c_uvcntgr_rec.updater,
                                                 'N',
                                                 NULL) ;
        -- increment count of records
        l_count := l_count + 1;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('UVCONTGRP', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('UVCONTGRP', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('UVCONTGRP') ;
       END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_UVCONTGRP_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_uvcontgrp_2003   ;


  PROCEDURE load_uvcourse_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view uvcourse into the interface table
                           igs_uc_ucrse_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     jbaber    15-Sep-05    Replace campus value with '*' if NULL for bug 4589994
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_uvcrse( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT DECODE(RTRIM(course),NULL, RPAD('*',LENGTH(course),'*'), RTRIM(course)) course
          ,NVL(DECODE(RTRIM(campus),NULL, RPAD('*',LENGTH(campus),'*'), RTRIM(campus)),'*') campus
          ,timestamp
          ,DECODE(RTRIM(updater),NULL, RPAD('*',LENGTH(updater),'*'), RTRIM(updater)) updater
          ,RTRIM(faculty) faculty
          ,RTRIM(shorttitle) shorttitle
          ,RTRIM(longtitle) longtitle
          ,RTRIM(validcurr) validcurr
          ,RTRIM(validdefer) validdefer
          ,term1start
          ,term1end
          ,term2start
          ,term2end
          ,term3start
          ,term3end
          ,term4start
          ,term4end
          ,RTRIM(jointadmission) jointadmission
          ,RTRIM(openextra) openextra
      FROM igs_uc_u_uvcourse_2003
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_u_uvcourse_2003  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_u_uvcourse_2003.timestamp%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('UVCOURSE ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('UVCOURSE', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_uvcrse_rec IN c_uvcrse(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- Obsolete matching records in interface table with status N
              UPDATE igs_uc_ucrse_ints SET record_status = 'O'
              WHERE record_status = 'N' AND course = c_uvcrse_rec.course
              AND campus =  c_uvcrse_rec.campus ;

              -- copy hercules record into interface table with record status N
              INSERT INTO igs_uc_ucrse_ints (   course,
                                                campus,
                                                updater,
                                                faculty,
                                                shorttitle,
                                                longtitle,
                                                validcurr,
                                                validdefer,
                                                term1start,
                                                term1end,
                                                term2start,
                                                term2end,
                                                term3start,
                                                term3end,
                                                term4start,
                                                term4end,
                                                jointadmission,
                                                openextra,
                                                record_status,
                                                error_code
                                                 )
                                     VALUES (   c_uvcrse_rec.course,
                                                c_uvcrse_rec.campus,
                                                c_uvcrse_rec.updater,
                                                c_uvcrse_rec.faculty,
                                                c_uvcrse_rec.shorttitle,
                                                c_uvcrse_rec.longtitle,
                                                c_uvcrse_rec.validcurr,
                                                c_uvcrse_rec.validdefer,
                                                c_uvcrse_rec.term1start,
                                                c_uvcrse_rec.term1end,
                                                c_uvcrse_rec.term2start,
                                                c_uvcrse_rec.term2end,
                                                c_uvcrse_rec.term3start,
                                                c_uvcrse_rec.term3end,
                                                c_uvcrse_rec.term4start,
                                                c_uvcrse_rec.term4end,
                                                c_uvcrse_rec.jointadmission,
                                                c_uvcrse_rec.openextra,
                                                 'N',
                                                 NULL) ;
        -- increment count of records
        l_count := l_count + 1;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('UVCOURSE', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('UVCOURSE', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('UVCOURSE') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_UVCOURSE_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_uvcourse_2003  ;

  PROCEDURE load_uvcoursekeyword_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view uvcoursekeyword into the interface table
                           igs_uc_ucrskwd_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     rgangara  20-Apr-04    Bug 3496874. Modified UVKeyword processing to process Keyword records as a Set.
                            Existing records if any for the course,campus and optioncode would be obsoleted
                            before importing keyword records.
     jbaber    15-Sep-05    Load NULL for keyno for bug 4589994
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_uvcrsekyw( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT DECODE(RTRIM(course),NULL, RPAD('*',LENGTH(course),'*'), RTRIM(course)) course
          ,DECODE(RTRIM(campus),NULL, RPAD('*',LENGTH(campus),'*'), RTRIM(campus)) campus
          ,DECODE(RTRIM(optioncode),NULL, RPAD('*',LENGTH(optioncode),'*'), RTRIM(optioncode)) optioncode
          ,NULL keyno
          ,DECODE(RTRIM(keyword),NULL, RPAD('*',LENGTH(keyword),'*'), RTRIM(keyword)) keyword
          ,timestamp
          ,DECODE(RTRIM(updater),NULL, RPAD('*',LENGTH(updater),'*'), RTRIM(updater)) updater
          ,RTRIM(active) active
      FROM igs_uc_u_uvcoursekeyword_2003
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_u_uvcoursekeyword_2003  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_u_uvcoursekeyword_2003.timestamp%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('UVCOURSEKEYWORD ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('UVCOURSEKEYWORD', p_old_timestamp) ;


      -- Obsoleting all the keyword records in INT table for all the DISTINCT combination of course,
      -- campus and optioncode having a higher timestamp. This is to ensure that all the Keyword records
      -- are processed as a set. If a combination record is imported, all the existing records in the INTS
      -- table are to be obsoleted and the new Set is to be imported. This is as part of Bug# 3496874.
      -- This approach of Update is adopted from performance reasons otherwise it would have needed another
      -- loop and an update which would be exectued as many times as that of the Distinct Course combination.
      UPDATE igs_uc_ucrskwd_ints
         SET record_status = 'O'
      WHERE  record_status = 'N'
      AND    (course, campus, optioncode) IN (
                    SELECT DISTINCT DECODE(RTRIM(course),NULL, RPAD('*',LENGTH(course),'*'), RTRIM(course)) course,
                           DECODE(RTRIM(campus),NULL, RPAD('*',LENGTH(campus),'*'), RTRIM(campus)) campus,
                           DECODE(RTRIM(optioncode),NULL, RPAD('*',LENGTH(optioncode),'*'), RTRIM(optioncode)) optioncode
                    FROM   igs_uc_u_uvcoursekeyword_2003
                    WHERE  (timestamp > p_old_timestamp OR p_old_timestamp IS NULL));

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_uvcrsekyw_rec IN c_uvcrsekyw(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- copy hercules record into interface table with record status N
              INSERT INTO igs_uc_ucrskwd_ints ( course,
                                                campus,
                                                optioncode,
                                                keyno,
                                                keyword,
                                                updater,
                                                active,
                                                record_status,
                                                error_code
                                                 )
                                     VALUES (   c_uvcrsekyw_rec.course,
                                                c_uvcrsekyw_rec.campus,
                                                c_uvcrsekyw_rec.optioncode,
                                                c_uvcrsekyw_rec.keyno,
                                                c_uvcrsekyw_rec.keyword,
                                                c_uvcrsekyw_rec.updater,
                                                c_uvcrsekyw_rec.active,
                                                 'N',
                                                 NULL) ;
        -- increment count of records
        l_count := l_count + 1;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('UVCOURSEKEYWORD', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('UVCOURSEKEYWORD', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('UVCOURSEKEYWORD') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_UVCOURSEKEYWORD_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_uvcoursekeyword_2003   ;


  PROCEDURE load_uvcoursevacancies_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :     loads each record in the hercules view uvcoursevacancies into the interface table
                           igs_uc_ucrsvac_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_uvcrsevac( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT DECODE(RTRIM(course),NULL, RPAD('*',LENGTH(course),'*'), RTRIM(course)) course
          ,DECODE(RTRIM(campus),NULL, RPAD('*',LENGTH(campus),'*'), RTRIM(campus)) campus
          ,timestamp
          ,DECODE(RTRIM(updater),NULL, RPAD('*',LENGTH(updater),'*'), RTRIM(updater)) updater
          ,RTRIM(clupdated) clupdated
          ,cldate
          ,RTRIM(vacstatus) vacstatus
          ,RTRIM(novac) novac
          ,score
          ,RTRIM(rbfull) rbfull
          ,RTRIM(scotvac) scotvac
      FROM igs_uc_u_uvcoursevacs_2003
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_u_uvcoursevacs_2003  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp IGS_UC_U_UVCOURSEVACS_2003.timestamp%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start( 'UVCOURSEVACANCIES ON ' ) ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('UVCOURSEVACANCIES', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_uvcrsevac_rec IN c_uvcrsevac(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- Obsolete matching records in interface table with status N
              UPDATE igs_uc_ucrsvac_ints SET record_status = 'O'
              WHERE record_status = 'N' AND course = c_uvcrsevac_rec.course
              AND campus = c_uvcrsevac_rec.campus  ;

              -- copy hercules record into interface table with record status N
              INSERT INTO igs_uc_ucrsvac_ints ( course,
                                                campus,
                                                updater,
                                                clupdated,
                                                cldate,
                                                vacstatus,
                                                novac,
                                                score,
                                                rbfull,
                                                scotvac,
                                                record_status,
                                                error_code
                                                 )
                                     VALUES (   c_uvcrsevac_rec.course,
                                                c_uvcrsevac_rec.campus,
                                                c_uvcrsevac_rec.updater,
                                                c_uvcrsevac_rec.clupdated,
                                                c_uvcrsevac_rec.cldate,
                                                c_uvcrsevac_rec.vacstatus,
                                                c_uvcrsevac_rec.novac,
                                                c_uvcrsevac_rec.score,
                                                c_uvcrsevac_rec.rbfull,
                                                c_uvcrsevac_rec.scotvac,
                                                 'N',
                                                 NULL) ;
        -- increment count of records
        l_count := l_count + 1;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('UVCOURSEVACANCIES',l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete( 'UVCOURSEVACANCIES', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('UVCOURSEVACANCIES') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_UVCOURSEVACANCIES_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_uvcoursevacancies_2003  ;

  PROCEDURE load_uvcoursevacoptions_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :    loads each record in the hercules view uvcoursevacoptions into the interface table
                           igs_uc_ucrsvop_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_uvcrsevacop( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  DECODE(RTRIM(course),NULL, RPAD('*',LENGTH(course),'*'), RTRIM(course)) course
          ,DECODE(RTRIM(campus),NULL, RPAD('*',LENGTH(campus),'*'), RTRIM(campus)) campus
          ,DECODE(RTRIM(optioncode),NULL, RPAD('*',LENGTH(optioncode),'*'), RTRIM(optioncode)) optioncode
          ,timestamp
          ,DECODE(RTRIM(updater),NULL, RPAD('*',LENGTH(updater),'*'), RTRIM(updater)) updater
          ,RTRIM(clupdated) clupdated
          ,cldate
          ,RTRIM(vacstatus) vacstatus
      FROM igs_uc_u_uvcoursevacops_2003
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_u_uvcoursevacops_2003  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp IGS_UC_U_UVCOURSEVACOPS_2003.timestamp%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('UVCOURSEVACOPTIONS ON ' ) ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('UVCOURSEVACOPTIONS', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_uvcrsevacop_rec IN c_uvcrsevacop(p_old_timestamp) LOOP

              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- Obsolete matching records in interface table with status N
              UPDATE igs_uc_ucrsvop_ints SET record_status = 'O'
              WHERE record_status = 'N' AND course = c_uvcrsevacop_rec.course
              AND campus = c_uvcrsevacop_rec.campus AND optioncode = c_uvcrsevacop_rec.optioncode ;

              -- copy hercules record into interface table with record status N
              INSERT INTO igs_uc_ucrsvop_ints (  course,
                                                 campus,
                                                 optioncode,
                                                 updater,
                                                 clupdated,
                                                 cldate,
                                                 vacstatus,
                                                 record_status,
                                                 error_code
                                                 )
                                     VALUES (    c_uvcrsevacop_rec.course,
                                                 c_uvcrsevacop_rec.campus,
                                                 c_uvcrsevacop_rec.optioncode,
                                                 c_uvcrsevacop_rec.updater,
                                                 c_uvcrsevacop_rec.clupdated,
                                                 c_uvcrsevacop_rec.cldate,
                                                 c_uvcrsevacop_rec.vacstatus,
                                                 'N',
                                                 NULL) ;
        -- increment count of records
        l_count := l_count + 1;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('UVCOURSEVACOPTIONS', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('UVCOURSEVACOPTIONS', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('UVCOURSEVACOPTIONS') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_UVCOURSEVACOPTIONS_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_uvcoursevacoptions_2003  ;

  PROCEDURE load_uvinstitution_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view uvinstitution into the interface table
                           igs_uc_uinst_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_uinst ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  timestamp
         ,DECODE(RTRIM(updater),NULL, RPAD('*',LENGTH(updater),'*'), RTRIM(updater)) updater
         ,DECODE(RTRIM(insttype),NULL, RPAD('*',LENGTH(insttype),'*'), RTRIM(insttype)) insttype
         ,RTRIM(instshortname) instshortname
         ,RTRIM(instname) instname
         ,RTRIM(instfullname) instfullname
         ,RTRIM(switchboardtelno) switchboardtelno
         ,RTRIM(decisioncards) decisioncards
         ,RTRIM(recordcards) recordcards
         ,RTRIM(labels) labels
         ,RTRIM(weeklymovlistseq) weeklymovlistseq
         ,RTRIM(weeklymovpaging) weeklymovpaging
         ,RTRIM(formseq) formseq
         ,RTRIM(eblrequired) eblrequired
         ,RTRIM(eblmedia1or2) eblmedia1or2
         ,RTRIM(eblmedia3) eblmedia3
         ,RTRIM(ebl1or2merged) ebl1or2merged
         ,RTRIM(ebl1or2boardgroup) ebl1or2boardgroup
         ,RTRIM(ebl3boardgroup) ebl3boardgroup
         ,RTRIM(eblncapp) eblncapp
         ,RTRIM(eblmajorkey1) eblmajorkey1
         ,RTRIM(eblmajorkey2) eblmajorkey2
         ,RTRIM(eblmajorkey3) eblmajorkey3
         ,RTRIM(eblminorkey1) eblminorkey1
         ,RTRIM(eblminorkey2) eblminorkey2
         ,RTRIM(eblminorkey3) eblminorkey3
         ,RTRIM(eblfinalkey) eblfinalkey
         ,RTRIM(odl1) odl1
         ,RTRIM(odl1a) odl1a
         ,RTRIM(odl2) odl2
         ,RTRIM(odl3) odl3
         ,RTRIM(odlsummer) odlsummer
         ,RTRIM(odlrouteb) odlrouteb
         ,RTRIM(monthlyseq) monthlyseq
         ,RTRIM(monthlypaper) monthlypaper
         ,RTRIM(monthlypage) monthlypage
         ,RTRIM(monthlytype) monthlytype
         ,RTRIM(junelistseq) junelistseq
         ,RTRIM(junelabels) junelabels
         ,RTRIM(junenumlabels) junenumlabels
         ,RTRIM(courseanalysis) courseanalysis
         ,RTRIM(campusused) campusused
         ,RTRIM(d3docsrequired) d3docsrequired
         ,RTRIM(clearingacceptcopyform) clearingacceptcopyform
         ,RTRIM(onlinemessage) onlinemessage
         ,RTRIM(ethniclistseq) ethniclistseq
      FROM igs_uc_u_uvinstitution_2003
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_u_uvinstitution_2003  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_u_uvinstitution_2003.timestamp%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('UVINSTITUTION ON ' ) ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('UVINSTITUTION', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_uinst_rec IN c_uinst(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- Obsolete all records in interface table with status N
              UPDATE igs_uc_uinst_ints SET record_status = 'O' WHERE record_status = 'N' ;

              -- copy hercules record into interface table with record status N
              INSERT INTO igs_uc_uinst_ints (   updater,
                                                insttype,
                                                instshortname,
                                                instname,
                                                instfullname,
                                                switchboardtelno,
                                                decisioncards,
                                                recordcards,
                                                labels,
                                                weeklymovlistseq,
                                                weeklymovpaging,
                                                formseq,
                                                eblrequired,
                                                eblmedia1or2,
                                                eblmedia3,
                                                ebl1or2merged,
                                                ebl1or2boardgroup,
                                                ebl3boardgroup,
                                                eblncapp,
                                                eblmajorkey1,
                                                eblmajorkey2,
                                                eblmajorkey3,
                                                eblminorkey1,
                                                eblminorkey2,
                                                eblminorkey3,
                                                eblfinalkey,
                                                odl1,
                                                odl1a,
                                                odl2,
                                                odl3,
                                                odlsummer,
                                                odlrouteb,
                                                monthlyseq,
                                                monthlypaper,
                                                monthlypage,
                                                monthlytype,
                                                junelistseq,
                                                junelabels,
                                                junenumlabels,
                                                courseanalysis,
                                                campusused,
                                                d3docsrequired,
                                                clearingacceptcopyform,
                                                onlinemessage,
                                                ethniclistseq,
                                                starx,
                                                record_status,
                                                error_code
                                                 )
                                     VALUES (   c_uinst_rec.updater,
                                                c_uinst_rec.insttype,
                                                c_uinst_rec.instshortname,
                                                c_uinst_rec.instname,
                                                c_uinst_rec.instfullname,
                                                c_uinst_rec.switchboardtelno,
                                                c_uinst_rec.decisioncards,
                                                c_uinst_rec.recordcards,
                                                c_uinst_rec.labels,
                                                c_uinst_rec.weeklymovlistseq,
                                                c_uinst_rec.weeklymovpaging,
                                                c_uinst_rec.formseq,
                                                c_uinst_rec.eblrequired,
                                                c_uinst_rec.eblmedia1or2,
                                                c_uinst_rec.eblmedia3,
                                                c_uinst_rec.ebl1or2merged,
                                                c_uinst_rec.ebl1or2boardgroup,
                                                c_uinst_rec.ebl3boardgroup,
                                                c_uinst_rec.eblncapp,
                                                c_uinst_rec.eblmajorkey1,
                                                c_uinst_rec.eblmajorkey2,
                                                c_uinst_rec.eblmajorkey3,
                                                c_uinst_rec.eblminorkey1,
                                                c_uinst_rec.eblminorkey2,
                                                c_uinst_rec.eblminorkey3,
                                                c_uinst_rec.eblfinalkey,
                                                c_uinst_rec.odl1,
                                                c_uinst_rec.odl1a,
                                                c_uinst_rec.odl2,
                                                c_uinst_rec.odl3,
                                                c_uinst_rec.odlsummer,
                                                c_uinst_rec.odlrouteb,
                                                c_uinst_rec.monthlyseq,
                                                c_uinst_rec.monthlypaper,
                                                c_uinst_rec.monthlypage,
                                                c_uinst_rec.monthlytype,
                                                c_uinst_rec.junelistseq,
                                                c_uinst_rec.junelabels,
                                                c_uinst_rec.junenumlabels,
                                                c_uinst_rec.courseanalysis,
                                                c_uinst_rec.campusused,
                                                c_uinst_rec.d3docsrequired,
                                                c_uinst_rec.clearingacceptcopyform,
                                                c_uinst_rec.onlinemessage,
                                                c_uinst_rec.ethniclistseq,
                                                'N',
                                                 'N',
                                                 NULL) ;
        -- increment count of records
        l_count := l_count + 1;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('UVINSTITUTION', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('UVINSTITUTION', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('UVINSTITUTION') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_UVINSTITUTION_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_uvinstitution_2003  ;

  PROCEDURE load_uvofferabbrev_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view uvofferabbrev into the interface table
                           igs_uc_uofabrv_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_uvoffabrv( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  abbrevid
        ,timestamp
        ,RTRIM(updater) updater
        ,RTRIM(abbrevtext) abbrevtext
        ,DECODE(RTRIM(letterformat),NULL, RPAD('*',LENGTH(letterformat),'*'), RTRIM(letterformat)) letterformat
        ,RTRIM(summarychar) summarychar
        ,abbrevuse
      FROM igs_uc_u_uvofferabbrev_2003
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_u_uvofferabbrev_2003  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_u_uvofferabbrev_2003.timestamp%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('UVOFFERABBREV ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('UVOFFERABBREV', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_uvoffabrv_rec IN c_uvoffabrv(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              --Validate varchar to number conversion
              IF  is_valid(c_uvoffabrv_rec.abbrevid,'UVOFFERABBREV','ABBREVID','NUMBER') THEN

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_uofabrv_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  abbrevid = c_uvoffabrv_rec.abbrevid ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_uofabrv_ints ( abbrevid,
                                                    updater,
                                                    abbrevtext,
                                                    letterformat,
                                                    summarychar,
                                                    abbrevuse,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   c_uvoffabrv_rec.abbrevid,
                                                    c_uvoffabrv_rec.updater,
                                                    c_uvoffabrv_rec.abbrevtext,
                                                    c_uvoffabrv_rec.letterformat,
                                                    c_uvoffabrv_rec.summarychar,
                                                    c_uvoffabrv_rec.abbrevuse,
                                                    'N',
                                                    NULL) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('UVOFFERABBREV',  l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('UVOFFERABBREV', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('UVOFFERABBREV') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_UVOFFERABBREV_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_uvofferabbrev_2003   ;


  PROCEDURE load_cvrefpre2000pocc_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view cvrefpre2000pocc into the interface table
                           igs_uc_crprepo_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvprepocc IS
      SELECT  pocc
          ,socialclass
          ,RTRIM(occupationtext) occupationtext
          ,RTRIM(alternativetext) alternativetext
          ,alternateclass1
          ,alternateclass2
      FROM igs_uc_u_cvrefpre2000pocc_2003     ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
        log_start('CVREFPRE2000POCC ON ' ) ;

      -- Obsolete records in interface table with status N
      UPDATE igs_uc_crprepo_ints SET record_status = 'O' WHERE record_status = 'N' ;

       -- create interface records for each record in the hercules view
       FOR c_cvprepocc_rec IN c_cvprepocc LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- copy hercules record into interface table with record status N
              INSERT INTO igs_uc_crprepo_ints(  pocc,
                                                socialclass,
                                                occupationtext,
                                                alternativetext,
                                                alternateclass1,
                                                alternateclass2,
                                                record_status,
                                                error_code
                                                 )
                                     VALUES (   c_cvprepocc_rec.pocc,
                                                c_cvprepocc_rec.socialclass,
                                                c_cvprepocc_rec.occupationtext,
                                                c_cvprepocc_rec.alternativetext,
                                                c_cvprepocc_rec.alternateclass1,
                                                c_cvprepocc_rec.alternateclass2,
                                                 'N',
                                                 NULL) ;
        -- increment count of records
        l_count := l_count + 1;

       END LOOP ;

      IF g_sync_reqd THEN
              -- log message that this view has been loaded
               log_complete('CVREFPRE2000POCC', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFPRE2000POCC') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFPRE2000POCC_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END    load_cvrefpre2000pocc_2003 ;

  PROCEDURE load_cvrefsocialclass_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :  loads each record in the hercules view cvrefsocialclass into the interface table
                           igs_uc_crfcode_ints with record status N and code_type = PC
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvsocclas IS
      SELECT  socialclass
           ,RTRIM(socialclasstext) socialclasstext
      FROM igs_uc_u_cvrefsocialclass_2003      ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVREFSOCIALCLASS ON ') ;

     -- Obsolete records in interface table with status N
      UPDATE igs_uc_crfcode_ints SET record_status = 'O' WHERE record_status = 'N' AND code_type = 'PC';

       -- create interface records for each record in the hercules view
       FOR c_cvsocclas_rec IN c_cvsocclas LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- copy hercules record into interface table with record status N
              INSERT INTO igs_uc_crfcode_ints(   code_type,
                                                 code,
                                                 code_text,
                                                 record_status,
                                                 error_code
                                                 )
                                     VALUES (    'PC',
                                                 c_cvsocclas_rec.socialclass,
                                                 c_cvsocclas_rec.socialclasstext,
                                                 'N',
                                                 NULL) ;
        -- increment count of records
        l_count := l_count + 1;

       END LOOP ;

      IF g_sync_reqd THEN
              -- log message that this view has been loaded
               log_complete('CVREFSOCIALCLASS', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFSOCIALCLASS') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFSOCIALCLASS_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_cvrefsocialclass_2003  ;

  PROCEDURE load_cvrefsocioeconomic_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :    loads each record in the hercules view cvrefsocioeconomic into the interface table
                           igs_uc_crfcode_ints with record status N and code_type = PE
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvsocioecon IS
      SELECT  socioecon
           ,RTRIM(socioecontext) socioecontext
      FROM igs_uc_u_cvrefsocioecon_2003  ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVREFSOCIOECONOMIC ON ') ;

     -- Obsolete records in interface table with status N
      UPDATE igs_uc_crfcode_ints SET record_status = 'O' WHERE record_status = 'N' AND code_type = 'PE';

       -- create interface records for each record in the hercules view
       FOR c_cvsocioecon_rec IN c_cvsocioecon LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- copy hercules record into interface table with record status N
              INSERT INTO igs_uc_crfcode_ints(   code_type,
                                                 code,
                                                 code_text,
                                                 record_status,
                                                 error_code
                                                 )
                                     VALUES (    'PE',
                                                 c_cvsocioecon_rec.socioecon,
                                                 c_cvsocioecon_rec.socioecontext,
                                                 'N',
                                                 NULL) ;
        -- increment count of records
        l_count := l_count + 1;

       END LOOP ;

      IF g_sync_reqd THEN
               -- log message that this view has been loaded
               log_complete('CVREFSOCIOECONOMIC', l_count) ;
      ELSE
               -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFSOCIOECONOMIC') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFSOCIOECONOMIC_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_cvrefsocioeconomic_2003  ;

  PROCEDURE load_cvrefsubj_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :     loads each record in the hercules view cvrefsubj into the interface table
                           igs_uc_crsubj_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     jbaber    15-Sep-05    Replace subjtext value with '*' if NULL for bug 4589994
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvsubj IS
      SELECT  DECODE(RTRIM(subjcode),NULL, RPAD('*',LENGTH(subjcode),'*'), RTRIM(subjcode)) subjcode
                 ,NVL(DECODE(RTRIM(subjtext),NULL, RPAD('*',LENGTH(subjtext),'*'), RTRIM(subjtext)),'*') subjtext
                 ,RTRIM(subjabbrev) subjabbrev
                 ,RTRIM(ebl_subj) ebl_subj
      FROM igs_uc_u_cvrefsubj_2003 ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start( 'CVREFSUBJ ON ') ;

     -- Obsolete records in interface table with status N
      UPDATE igs_uc_crsubj_ints SET record_status = 'O' WHERE record_status = 'N' ;

       -- create interface records for each record in the hercules view
       FOR c_cvsubj_rec IN c_cvsubj LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- copy hercules record into interface table with record status N
              INSERT INTO igs_uc_crsubj_ints(   subjcode,
                                                subjtext,
                                                subjabbrev,
                                                ebl_subj,
                                                record_status,
                                                error_code
                                                 )
                                     VALUES (   c_cvsubj_rec.subjcode,
                                                c_cvsubj_rec.subjtext,
                                                c_cvsubj_rec.subjabbrev,
                                                c_cvsubj_rec.ebl_subj,
                                                 'N',
                                                 NULL) ;
        -- increment count of records
        l_count := l_count + 1;

       END LOOP ;

       IF g_sync_reqd THEN
              -- log message that this view has been loaded
               log_complete( 'CVREFSUBJ', l_count) ;
       ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFSUBJ') ;
       END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFSUBJ_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_cvrefsubj_2003  ;


  PROCEDURE load_cvrefcountry_2007 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :   11-Jul-06
     Purpose         :   loads each record in the hercules view cvrefcountry into the interface table
                         igs_uc_country_ints  with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvrefcountry IS
      SELECT DECODE(RTRIM(countrycode),NULL, RPAD('*',LENGTH(countrycode),'*'), RTRIM(countrycode)) countrycode
          ,RTRIM(description) description
          ,RTRIM(type) type
      FROM igs_uc_u_cvrefcountry_2007 ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_u_cvrefamendments_2007.country%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('CVREFCOUNTRY ON ') ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_refamend_timestamp.country ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVREFCOUNTRY', p_old_timestamp) ;
      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

               -- Obsolete all records in interface table with status N
               UPDATE igs_uc_country_ints   SET record_status = 'O' WHERE record_status = 'N' ;

               -- create interface records for each record in the hercules view
               FOR c_cvrefcountry_rec IN c_cvrefcountry LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      -- copy hercules record into interface table with record status N
                      INSERT INTO igs_uc_country_ints (  countrycode,
                                                         description,
                                                         type,
                                                         record_status,
                                                         error_code )
                                             VALUES (    c_cvrefcountry_rec.countrycode,
                                                         c_cvrefcountry_rec.description,
                                                         c_cvrefcountry_rec.type,
                                                         'N',
                                                         NULL) ;
            -- increment count of records
            l_count := l_count + 1;

               END LOOP ;
      END IF ;  -- old and new timestamps differ

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVREFCOUNTRY',l_new_max_timestamp) ;

                  -- log message that this view has been loaded
                 log_complete('CVREFCOUNTRY', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFCOUNTRY') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFCOUNTRY_2007');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_cvrefcountry_2007  ;


  PROCEDURE load_cvrefnationality_2007 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :   11-Jul-06
     Purpose         :   loads each record in the hercules view cvrefnationality into the interface table
                         igs_uc_crfcode_ints with record status N and code_type = NC
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvrefnationality IS
      SELECT DECODE(RTRIM(nationality),NULL, RPAD('*',LENGTH(nationality),'*'), RTRIM(nationality)) nationality
           ,RTRIM(description) description
      FROM igs_uc_u_cvrefnationality_2007  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_u_cvrefamendments_2007.nationality%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
      log_start('CVREFNATIONALITY ON ' ) ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_refamend_timestamp.nationality ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVREFNATIONALITY', p_old_timestamp) ;
      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

               -- Obsolete all records in interface table with status N
               UPDATE igs_uc_crfcode_ints  SET record_status = 'O' WHERE record_status = 'N' AND code_type= 'NC' ;

               -- create interface records for each record in the hercules view
               FOR c_cvrefnationality_rec IN c_cvrefnationality LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      -- copy hercules record into interface table with record status N
                      INSERT INTO igs_uc_crfcode_ints (  code_type,
                                                         code,
                                                         code_text,
                                                         record_status,
                                                         error_code )
                                             VALUES (    'NC',
                                                         c_cvrefnationality_rec.nationality,
                                                         c_cvrefnationality_rec.description,
                                                         'N',
                                                         NULL) ;
            -- increment count of records
            l_count := l_count + 1;

               END LOOP ;
      END IF ;  -- old and new timetamps differ

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVREFNATIONALITY',  l_new_max_timestamp) ;

            -- log message that this view has been loaded
            log_complete('CVREFNATIONALITY', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVREFNATIONALITY') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVREFNATIONALITY_2007');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_cvrefnationality_2007  ;


  PROCEDURE load_cvgrefdegreesubj_2006  IS
    /******************************************************************
     Created By      :   jbaber
     Date Created By :   02-Oct-05
     Purpose         :   loads each record in the hercules view cvgrefdegreesubject into the interface table
                         igs_uc_crfcode_ints with record status N and code_type = DS
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_cvgrefdegsubj IS
      SELECT degreesubject
            ,RTRIM(description) description
      FROM igs_uc_g_cvgrefdegreesubj_2006;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ;
      l_new_max_timestamp igs_uc_g_cvgrefamendments_2006.degreesubject%TYPE ;
      l_count NUMBER ;

  BEGIN
      -- set syncronization required to false
      g_sync_reqd := FALSE;
      l_count := 0 ;

      -- log message that this view is being loaded
      log_start('CVGREFDEGREESUBJECT ON ') ;

      -- get the max timestamp of this hercules view
      l_new_max_timestamp := g_grefamend_timestamp.degreesubject ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('CVGREFDEGREESUBJECT',p_old_timestamp) ;

      -- if there is a difference in the timestamps then load all records from hercules view
      IF ( l_new_max_timestamp > p_old_timestamp OR p_old_timestamp IS NULL  ) THEN

               -- Obsolete all records in interface table with status N
               UPDATE igs_uc_crfcode_ints  SET record_status = 'O' WHERE record_status = 'N' AND code_type= 'DS' ;

               -- create interface records for each record in the hercules view
               FOR c_cvgrefdegsubj_rec IN c_cvgrefdegsubj LOOP
                      -- set x_sync_read to true if the loop is entered even once
                      g_sync_reqd := TRUE;

                      -- copy hercules record into interface table with record status N
                      INSERT INTO igs_uc_crfcode_ints (  code_type,
                                                         code,
                                                         code_text,
                                                         record_status,
                                                         error_code )
                                               VALUES (  'DS',
                                                         c_cvgrefdegsubj_rec.degreesubject,
                                                         c_cvgrefdegsubj_rec.description,
                                                         'N',
                                                         NULL );
                      -- increment count of records
                      l_count := l_count + 1;

               END LOOP ;

      END IF ;  -- old and new timetamps differ

      IF g_sync_reqd THEN
               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('CVGREFDEGREESUBJECT', l_new_max_timestamp) ;

               -- log message that this view has been loaded
               log_complete('CVGREFDEGREESUBJECT', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('CVGREFDEGREESUBJECT') ;
      END IF ;

      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_CVGREFDEGREESUBJ_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END    load_cvgrefdegreesubj_2006 ;


  PROCEDURE load_ivoffer_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view ivoffer into the interface table
                           igs_uc_ioffer_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivoffer( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
           ,choiceno
           ,timestamp
           ,DECODE(RTRIM(offercourse),NULL, RPAD('*',LENGTH(offercourse),'*'), RTRIM(offercourse)) offercourse
           ,DECODE(RTRIM(offercampus),NULL, RPAD('*',LENGTH(offercampus),'*'), RTRIM(offercampus)) offercampus
           ,offercourselength
           ,RTRIM(offerentrymonth) offerentrymonth
           ,RTRIM(offerentryyear) offerentryyear
           ,RTRIM(offerentrypoint) offerentrypoint
           ,RTRIM(offertext) offertext
      FROM igs_uc_ivoffer_2003_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivoffer_2003_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivoffer_2003_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_ioffer_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVOFFER ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVOFFER', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivoffer_rec IN c_ivoffer(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivoffer_rec.appno,'IVOFFER','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivoffer_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_ioffer_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = l_appno
                  AND choiceno = c_ivoffer_rec.choiceno ;


                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_ioffer_ints (  appno,
                                                    choiceno,
                                                    offercourse,
                                                    offercampus,
                                                    offercourselength,
                                                    offerentrymonth,
                                                    offerentryyear,
                                                    offerentrypoint,
                                                    offertext,
                                                    record_status,
                                                    error_code,
                                                    ucas_cycle
                                                     )
                                         VALUES (   l_appno,
                                                    c_ivoffer_rec.choiceno,
                                                    c_ivoffer_rec.offercourse,
                                                    c_ivoffer_rec.offercampus,
                                                    c_ivoffer_rec.offercourselength,
                                                    c_ivoffer_rec.offerentrymonth,
                                                    c_ivoffer_rec.offerentryyear,
                                                    c_ivoffer_rec.offerentrypoint,
                                                    c_ivoffer_rec.offertext,
                                                     'N',
                                                     NULL,
                                                    g_cyc_info_rec.configured_cycle ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVOFFER',   l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVOFFER', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVOFFER') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVOFFER_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_ivoffer_2003   ;


  PROCEDURE load_ivgoffer_2006 IS
    /******************************************************************
     Created By      :   jtmathew
     Date Created By :   08-Jul-05
     Purpose         :   loads each record in the odbc-link view ivgoffer into the interface table
                         igs_uc_ioffer_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from odbc-link view whose timestamp is > passed timestamp
      -- or get all the records in odbc-link view if the timestamp passed is null
      CURSOR c_ivgoffer( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
           ,roundno
           ,timestamp
           ,RTRIM(offertext) offertext
      FROM igs_uc_ivgoffer_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the odbc-link view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivgoffer_2006_v  ;

      -- Variables
      p_old_timestamp     igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivgoffer_2006_v.timestamp%TYPE ;
      l_appno             igs_uc_ioffer_ints.appno%TYPE;
      l_checkdigit        NUMBER;
      l_count             NUMBER ;


  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVGOFFER ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVGOFFER', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivgoffer_rec IN c_ivgoffer(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivgoffer_rec.appno,'IVGOFFER','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivgoffer_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_ioffer_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = c_ivgoffer_rec.appno
                  AND choiceno = c_ivgoffer_rec.roundno ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_ioffer_ints (  appno,
                                                    choiceno,
                                                    offertext,
                                                    record_status,
                                                    error_code,
                                                    ucas_cycle
                                                     )
                                         VALUES (   l_appno,
                                                    c_ivgoffer_rec.roundno,
                                                    c_ivgoffer_rec.offertext,
                                                    'N',
                                                    NULL,
                                                    g_cyc_info_rec.configured_cycle ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVGOFFER',   l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVGOFFER', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVGOFFER') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVGOFFER_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_ivgoffer_2006   ;


  PROCEDURE load_ivnoffer_2006 IS
    /******************************************************************
     Created By      :   jtmathew
     Date Created By :   08-Jul-05
     Purpose         :   loads each record in the odbc-link view ivnoffer into the interface table
                         igs_uc_ioffer_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from odbc-link view whose timestamp is > passed timestamp
      -- or get all the records in odbc-link view if the timestamp passed is null
      CURSOR c_ivnoffer( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
           ,choiceno
           ,timestamp
           ,RTRIM(offertext) offertext
      FROM igs_uc_ivnoffer_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the odbc-link view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivnoffer_2006_v  ;

      -- Variables
      p_old_timestamp     igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivnoffer_2006_v.timestamp%TYPE ;
      l_appno             igs_uc_ioffer_ints.appno%TYPE;
      l_checkdigit        NUMBER;
      l_count             NUMBER ;


  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVNOFFER ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVNOFFER', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivnoffer_rec IN c_ivnoffer(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivnoffer_rec.appno,'IVNOFFER','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivnoffer_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_ioffer_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = c_ivnoffer_rec.appno
                  AND choiceno = c_ivnoffer_rec.choiceno ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_ioffer_ints (  appno,
                                                    choiceno,
                                                    offertext,
                                                    record_status,
                                                    error_code,
                                                    ucas_cycle
                                                     )
                                         VALUES (   l_appno,
                                                    c_ivnoffer_rec.choiceno,
                                                    c_ivnoffer_rec.offertext,
                                                    'N',
                                                    NULL,
                                                    g_cyc_info_rec.configured_cycle ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVNOFFER',   l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVNOFFER', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVNOFFER') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVNOFFER_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_ivnoffer_2006   ;


  PROCEDURE load_ivqualification_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :    loads each record in the hercules view ivqualification into the interface table
                           igs_uc_iqual_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivqual ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
            ,timestamp
            ,RTRIM(matchprevious) matchprevious
            ,matchpreviousdate
            ,RTRIM(matchwinter) matchwinter
            ,RTRIM(matchsummer) matchsummer
            ,gnvqdate    -- not used in hercules
            ,ibdate
            ,ilcdate
            ,aicedate
            ,gcesqadate
      FROM igs_uc_ivqualification_2003_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivqualification_2003_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivqualification_2003_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_iqual_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVQUALIFICATION ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVQUALIFICATION', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivqual_rec IN c_ivqual(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivqual_rec.appno,'IVQUALIFICATION','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivqual_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_iqual_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = l_appno;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_iqual_ints (   appno,
                                                    matchprevious,
                                                    matchpreviousdate,
                                                    matchwinter,
                                                    matchsummer,
                                                    gnvqdate,
                                                    ibdate,
                                                    ilcdate,
                                                    aicedate,
                                                    gcesqadate,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   l_appno,
                                                    c_ivqual_rec.matchprevious,
                                                    c_ivqual_rec.matchpreviousdate,
                                                    c_ivqual_rec.matchwinter,
                                                    c_ivqual_rec.matchsummer,
                                                    c_ivqual_rec.gnvqdate,
                                                    c_ivqual_rec.ibdate,
                                                    c_ivqual_rec.ilcdate,
                                                    c_ivqual_rec.aicedate,
                                                    c_ivqual_rec.gcesqadate,
                                                     'N',
                                                     NULL ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

       IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVQUALIFICATION', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVQUALIFICATION', l_count) ;
       ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVQUALIFICATION') ;
       END IF;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVQUALIFICATION_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivqualification_2003  ;


  PROCEDURE load_ivstara_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view ivstara into the interface table
                           igs_uc_istara_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivstara ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
      ,timestamp
      ,addressarea
      ,DECODE(RTRIM(address1),NULL, RPAD('*',LENGTH(address1),'*'), RTRIM(address1)) address1
      ,RTRIM(address2) address2
      ,RTRIM(address3) address3
      ,RTRIM(address4) address4
      ,RTRIM(postcode) postcode
      ,mailsort
      ,RTRIM(telephone) telephone
      ,NULL fax   -- not used in hercules
      ,RTRIM(email) email
      ,DECODE(RTRIM(homeaddress1),NULL, RPAD('*',LENGTH(homeaddress1),'*'), RTRIM(homeaddress1)) homeaddress1
      ,RTRIM(homeaddress2) homeaddress2
      ,RTRIM(homeaddress3) homeaddress3
      ,RTRIM(homeaddress4) homeaddress4
      ,RTRIM(homepostcode) homepostcode
      ,RTRIM(homephone) homephone
      ,NULL homefax    -- not used in hercules
      ,NULL homeemail  -- not used in hercules
      FROM  igs_uc_ivstara_2003_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivstara_2003_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivstara_2003_v.timestamp%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
      log_start( 'IVSTARA ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVSTARA', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivstara_rec IN c_ivstara(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- Obsolete matching records in interface table with status N
              UPDATE igs_uc_istara_ints SET record_status = 'O'
              WHERE record_status = 'N' AND  appno = c_ivstara_rec.appno;

              -- copy hercules record into interface table with record status N
              INSERT INTO igs_uc_istara_ints (  appno,
                                                addressarea,
                                                address1,
                                                address2,
                                                address3,
                                                address4,
                                                postcode,
                                                mailsort,
                                                telephone,
                                                fax,
                                                email,
                                                homeaddress1,
                                                homeaddress2,
                                                homeaddress3,
                                                homeaddress4,
                                                homepostcode,
                                                homephone,
                                                homefax,
                                                homeemail,
                                                record_status,
                                                error_code
                                                 )
                                     VALUES (   c_ivstara_rec.appno,
                                                c_ivstara_rec.addressarea,
                                                c_ivstara_rec.address1,
                                                c_ivstara_rec.address2,
                                                c_ivstara_rec.address3,
                                                c_ivstara_rec.address4,
                                                c_ivstara_rec.postcode,
                                                c_ivstara_rec.mailsort,
                                                c_ivstara_rec.telephone,
                                                c_ivstara_rec.fax,
                                                c_ivstara_rec.email,
                                                c_ivstara_rec.homeaddress1,
                                                c_ivstara_rec.homeaddress2,
                                                c_ivstara_rec.homeaddress3,
                                                c_ivstara_rec.homeaddress4,
                                                c_ivstara_rec.homepostcode,
                                                c_ivstara_rec.homephone,
                                                c_ivstara_rec.homefax,
                                                c_ivstara_rec.homeemail,
                                                 'N',
                                                 NULL ) ;
        -- increment count of records
        l_count := l_count + 1;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVSTARA', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete( 'IVSTARA', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVSTARA') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVSTARA_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivstara_2003  ;


  PROCEDURE load_ivstara_2006 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view ivstara into the interface table
                         igs_uc_istara_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivstara ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
      ,timestamp
      ,addressarea
      ,DECODE(RTRIM(address1),NULL, RPAD('*',LENGTH(address1),'*'), RTRIM(address1)) address1
      ,RTRIM(address2) address2
      ,RTRIM(address3) address3
      ,RTRIM(address4) address4
      ,RTRIM(postcode) postcode
      ,mailsort
      ,RTRIM(telephone) telephone
      ,RTRIM(email) email
      ,DECODE(RTRIM(homeaddress1),NULL, RPAD('*',LENGTH(homeaddress1),'*'), RTRIM(homeaddress1)) homeaddress1
      ,RTRIM(homeaddress2) homeaddress2
      ,RTRIM(homeaddress3) homeaddress3
      ,RTRIM(homeaddress4) homeaddress4
      ,RTRIM(homepostcode) homepostcode
      FROM  igs_uc_ivstara_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivstara_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivstara_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istara_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
      log_start( 'IVSTARA ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVSTARA', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivstara_rec IN c_ivstara(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivstara_rec.appno,'IVSTARA','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivstara_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istara_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = l_appno;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istara_ints (  appno,
                                                    addressarea,
                                                    address1,
                                                    address2,
                                                    address3,
                                                    address4,
                                                    postcode,
                                                    mailsort,
                                                    telephone,
                                                    email,
                                                    homeaddress1,
                                                    homeaddress2,
                                                    homeaddress3,
                                                    homeaddress4,
                                                    homepostcode,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   l_appno,
                                                    c_ivstara_rec.addressarea,
                                                    c_ivstara_rec.address1,
                                                    c_ivstara_rec.address2,
                                                    c_ivstara_rec.address3,
                                                    c_ivstara_rec.address4,
                                                    c_ivstara_rec.postcode,
                                                    c_ivstara_rec.mailsort,
                                                    c_ivstara_rec.telephone,
                                                    c_ivstara_rec.email,
                                                    c_ivstara_rec.homeaddress1,
                                                    c_ivstara_rec.homeaddress2,
                                                    c_ivstara_rec.homeaddress3,
                                                    c_ivstara_rec.homeaddress4,
                                                    c_ivstara_rec.homepostcode,
                                                     'N',
                                                     NULL ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVSTARA', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete( 'IVSTARA', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVSTARA') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVSTARA_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivstara_2006  ;

  PROCEDURE load_ivstara_2007 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :   11-Jul-06
     Purpose         :   loads each record in the hercules view ivstara into the interface table
                         igs_uc_istara_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivstara ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
      ,timestamp
      ,addressarea
      ,DECODE(RTRIM(address1),NULL, RPAD('*',LENGTH(address1),'*'), RTRIM(address1)) address1
      ,RTRIM(address2) address2
      ,RTRIM(address3) address3
      ,RTRIM(address4) address4
      ,RTRIM(postcode) postcode
      ,mailsort
      ,RTRIM(telephone) telephone
      ,RTRIM(email) email
      ,DECODE(RTRIM(homeaddress1),NULL, RPAD('*',LENGTH(homeaddress1),'*'), RTRIM(homeaddress1)) homeaddress1
      ,RTRIM(homeaddress2) homeaddress2
      ,RTRIM(homeaddress3) homeaddress3
      ,RTRIM(homeaddress4) homeaddress4
      ,RTRIM(homepostcode) homepostcode
      ,RTRIM(mobile) mobile
      ,RTRIM(countrycode) countrycode
      ,RTRIM(homecountrycode) homecountrycode
      FROM  igs_uc_ivstara_2007_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivstara_2007_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivstara_2007_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istara_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
      log_start( 'IVSTARA ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVSTARA', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivstara_rec IN c_ivstara(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivstara_rec.appno,'IVSTARA','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivstara_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istara_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = l_appno;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istara_ints (  appno,
                                                    addressarea,
                                                    address1,
                                                    address2,
                                                    address3,
                                                    address4,
                                                    postcode,
                                                    mailsort,
                                                    telephone,
                                                    email,
                                                    homeaddress1,
                                                    homeaddress2,
                                                    homeaddress3,
                                                    homeaddress4,
                                                    homepostcode,
                                                    mobile,
                                                    countrycode,
                                                    homecountrycode,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   l_appno,
                                                    c_ivstara_rec.addressarea,
                                                    c_ivstara_rec.address1,
                                                    c_ivstara_rec.address2,
                                                    c_ivstara_rec.address3,
                                                    c_ivstara_rec.address4,
                                                    c_ivstara_rec.postcode,
                                                    c_ivstara_rec.mailsort,
                                                    c_ivstara_rec.telephone,
                                                    c_ivstara_rec.email,
                                                    c_ivstara_rec.homeaddress1,
                                                    c_ivstara_rec.homeaddress2,
                                                    c_ivstara_rec.homeaddress3,
                                                    c_ivstara_rec.homeaddress4,
                                                    c_ivstara_rec.homepostcode,
                                                    c_ivstara_rec.mobile,
                                                    c_ivstara_rec.countrycode,
                                                    c_ivstara_rec.homecountrycode,
                                                     'N',
                                                     NULL ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVSTARA', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete( 'IVSTARA', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVSTARA') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVSTARA_2007');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivstara_2007  ;


  PROCEDURE load_ivgstara_2006 IS
    /******************************************************************
     Created By      :   jbaber
     Date Created By :   12-Aug-03
     Purpose         :   loads each record in the hercules view ivgstara into the interface table
                         igs_uc_istara_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from odbc-link view whose timestamp is > passed timestamp
      -- or get all the records in odbc-link view if the timestamp passed is null
      CURSOR c_ivgstara ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
      ,timestamp
      ,RTRIM(addressarea) addressarea
      ,DECODE(RTRIM(address1),NULL, RPAD('*',LENGTH(address1),'*'), RTRIM(address1)) address1
      ,RTRIM(address2) address2
      ,RTRIM(address3) address3
      ,RTRIM(address4) address4
      ,RTRIM(postcode) postcode
      ,mailsort
      ,RTRIM(telephone) telephone
      ,RTRIM(email) email
      ,RTRIM(homepostcode) homepostcode
      FROM  igs_uc_ivgstara_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivgstara_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivgstara_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istara_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
      log_start( 'IVGSTARA ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVGSTARA', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivgstara_rec IN c_ivgstara(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivgstara_rec.appno,'IVGSTARA','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivgstara_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istara_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = l_appno;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istara_ints (  appno,
                                                    addressarea,
                                                    address1,
                                                    address2,
                                                    address3,
                                                    address4,
                                                    postcode,
                                                    mailsort,
                                                    telephone,
                                                    email,
                                                    homepostcode,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   l_appno,
                                                    c_ivgstara_rec.addressarea,
                                                    c_ivgstara_rec.address1,
                                                    c_ivgstara_rec.address2,
                                                    c_ivgstara_rec.address3,
                                                    c_ivgstara_rec.address4,
                                                    c_ivgstara_rec.postcode,
                                                    c_ivgstara_rec.mailsort,
                                                    c_ivgstara_rec.telephone,
                                                    c_ivgstara_rec.email,
                                                    c_ivgstara_rec.homepostcode,
                                                     'N',
                                                     NULL ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVGSTARA', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete( 'IVGSTARA', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVGSTARA') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVGSTARA_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivgstara_2006  ;


  PROCEDURE load_ivgstara_2007 IS
    /******************************************************************
     Created By      :   jbaber
     Date Created By :   11-Jul-06
     Purpose         :   loads each record in the hercules view ivgstara into the interface table
                         igs_uc_istara_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivgstara ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
      ,timestamp
      ,addressarea
      ,DECODE(RTRIM(address1),NULL, RPAD('*',LENGTH(address1),'*'), RTRIM(address1)) address1
      ,RTRIM(address2) address2
      ,RTRIM(address3) address3
      ,RTRIM(address4) address4
      ,RTRIM(postcode) postcode
      ,mailsort
      ,RTRIM(telephone) telephone
      ,RTRIM(email) email
      ,DECODE(RTRIM(home_address1),NULL, RPAD('*',LENGTH(home_address1),'*'), RTRIM(home_address1)) homeaddress1
      ,RTRIM(home_address2) homeaddress2
      ,RTRIM(home_address3) homeaddress3
      ,RTRIM(home_address4) homeaddress4
      ,RTRIM(homepostcode) homepostcode
      ,RTRIM(mobile) mobile
      ,RTRIM(countrycode) countrycode
      ,RTRIM(homecountrycode) homecountrycode
      FROM  igs_uc_ivgstara_2007_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivgstara_2007_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivgstara_2007_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istara_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
      log_start( 'IVGSTARA ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVGSTARA', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivgstara_rec IN c_ivgstara(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivgstara_rec.appno,'IVGSTARA','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivgstara_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istara_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = l_appno;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istara_ints (  appno,
                                                    addressarea,
                                                    address1,
                                                    address2,
                                                    address3,
                                                    address4,
                                                    postcode,
                                                    mailsort,
                                                    telephone,
                                                    email,
                                                    homeaddress1,
                                                    homeaddress2,
                                                    homeaddress3,
                                                    homeaddress4,
                                                    homepostcode,
                                                    mobile,
                                                    countrycode,
                                                    homecountrycode,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   l_appno,
                                                    c_ivgstara_rec.addressarea,
                                                    c_ivgstara_rec.address1,
                                                    c_ivgstara_rec.address2,
                                                    c_ivgstara_rec.address3,
                                                    c_ivgstara_rec.address4,
                                                    c_ivgstara_rec.postcode,
                                                    c_ivgstara_rec.mailsort,
                                                    c_ivgstara_rec.telephone,
                                                    c_ivgstara_rec.email,
                                                    c_ivgstara_rec.homeaddress1,
                                                    c_ivgstara_rec.homeaddress2,
                                                    c_ivgstara_rec.homeaddress3,
                                                    c_ivgstara_rec.homeaddress4,
                                                    c_ivgstara_rec.homepostcode,
                                                    c_ivgstara_rec.mobile,
                                                    c_ivgstara_rec.countrycode,
                                                    c_ivgstara_rec.homecountrycode,
                                                     'N',
                                                     NULL ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVGSTARA', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete( 'IVGSTARA', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVGSTARA') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVGSTARA_2007');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivgstara_2007  ;


  PROCEDURE load_ivnstara_2006 IS
    /******************************************************************
     Created By      :   jbaber
     Date Created By :   12-Aug-03
     Purpose         :   loads each record in the hercules view ivnstara into the interface table
                         igs_uc_istara_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from odbc-link view whose timestamp is > passed timestamp
      -- or get all the records in odbc-link view if the timestamp passed is null
      CURSOR c_ivnstara ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
      ,timestamp
      ,RTRIM(addressarea) addressarea
      ,DECODE(RTRIM(address1),NULL, RPAD('*',LENGTH(address1),'*'), RTRIM(address1)) address1
      ,RTRIM(address2) address2
      ,RTRIM(address3) address3
      ,RTRIM(address4) address4
      ,RTRIM(postcode) postcode
      ,mailsort
      ,RTRIM(telephone) telephone
      ,RTRIM(email) email
      ,RTRIM(homepostcode) homepostcode
      FROM  igs_uc_ivnstara_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivnstara_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivnstara_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istara_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
      log_start( 'IVNSTARA ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVNSTARA', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivnstara_rec IN c_ivnstara(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivnstara_rec.appno,'IVNSTARA','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivnstara_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istara_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = l_appno;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istara_ints (  appno,
                                                    addressarea,
                                                    address1,
                                                    address2,
                                                    address3,
                                                    address4,
                                                    postcode,
                                                    mailsort,
                                                    telephone,
                                                    email,
                                                    homepostcode,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   l_appno,
                                                    c_ivnstara_rec.addressarea,
                                                    c_ivnstara_rec.address1,
                                                    c_ivnstara_rec.address2,
                                                    c_ivnstara_rec.address3,
                                                    c_ivnstara_rec.address4,
                                                    c_ivnstara_rec.postcode,
                                                    c_ivnstara_rec.mailsort,
                                                    c_ivnstara_rec.telephone,
                                                    c_ivnstara_rec.email,
                                                    c_ivnstara_rec.homepostcode,
                                                     'N',
                                                     NULL ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVNSTARA', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete( 'IVNSTARA', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVNSTARA') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVNSTARA_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivnstara_2006  ;


  PROCEDURE load_ivnstara_2007 IS
    /******************************************************************
     Created By      :   jbaber
     Date Created By :   11-Jul-06
     Purpose         :   loads each record in the hercules view ivnstara into the interface table
                         igs_uc_istara_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivnstara ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
      ,timestamp
      ,addressarea
      ,DECODE(RTRIM(address1),NULL, RPAD('*',LENGTH(address1),'*'), RTRIM(address1)) address1
      ,RTRIM(address2) address2
      ,RTRIM(address3) address3
      ,RTRIM(address4) address4
      ,RTRIM(postcode) postcode
      ,mailsort
      ,RTRIM(telephone) telephone
      ,RTRIM(email) email
      ,DECODE(RTRIM(homeaddress1),NULL, RPAD('*',LENGTH(homeaddress1),'*'), RTRIM(homeaddress1)) homeaddress1
      ,RTRIM(homeaddress2) homeaddress2
      ,RTRIM(homeaddress3) homeaddress3
      ,RTRIM(homeaddress4) homeaddress4
      ,RTRIM(homepostcode) homepostcode
      ,RTRIM(mobile) mobile
      ,RTRIM(countrycode) countrycode
      ,RTRIM(homecountrycode) homecountrycode
      FROM  igs_uc_ivnstara_2007_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivnstara_2007_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivnstara_2007_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istara_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
      log_start( 'IVNSTARA ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVNSTARA', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivnstara_rec IN c_ivnstara(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivnstara_rec.appno,'IVNSTARA','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivnstara_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istara_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = l_appno;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istara_ints (  appno,
                                                    addressarea,
                                                    address1,
                                                    address2,
                                                    address3,
                                                    address4,
                                                    postcode,
                                                    mailsort,
                                                    telephone,
                                                    email,
                                                    homeaddress1,
                                                    homeaddress2,
                                                    homeaddress3,
                                                    homeaddress4,
                                                    homepostcode,
                                                    mobile,
                                                    countrycode,
                                                    homecountrycode,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   l_appno,
                                                    c_ivnstara_rec.addressarea,
                                                    c_ivnstara_rec.address1,
                                                    c_ivnstara_rec.address2,
                                                    c_ivnstara_rec.address3,
                                                    c_ivnstara_rec.address4,
                                                    c_ivnstara_rec.postcode,
                                                    c_ivnstara_rec.mailsort,
                                                    c_ivnstara_rec.telephone,
                                                    c_ivnstara_rec.email,
                                                    c_ivnstara_rec.homeaddress1,
                                                    c_ivnstara_rec.homeaddress2,
                                                    c_ivnstara_rec.homeaddress3,
                                                    c_ivnstara_rec.homeaddress4,
                                                    c_ivnstara_rec.homepostcode,
                                                    c_ivnstara_rec.mobile,
                                                    c_ivnstara_rec.countrycode,
                                                    c_ivnstara_rec.homecountrycode,
                                                     'N',
                                                     NULL ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVNSTARA', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete( 'IVNSTARA', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVNSTARA') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVNSTARA_2007');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivnstara_2007  ;


  PROCEDURE load_ivstarc_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :     loads each record in the hercules view ivstarc into the interface table
                           igs_uc_istarc_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     jbaber    15-Sep-05    Replace inst, course and campus values with '*' if NULL
                            and force 2-digit entry year for bug 4589994
     jbaber    11-Jul-06    Truncate detail to 20 characters for UCAS 2007 Support
     anwest    02-AUG-06    Bug #5440216 URGENT - UCAS CLEARING 2006 - PART 2 - CLEARING CHOICE NUMBER NULL
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivstarc ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
            ,NVL(choiceno,9) choiceno -- 02-AUG-2006 anwest Bug #5440216 URGENT - UCAS CLEARING 2006 - PART 2 - CLEARING CHOICE NUMBER NULL
            ,timestamp
            ,NVL(lastchange,SYSDATE) lastchange
            ,NVL(DECODE(RTRIM(inst),NULL, RPAD('*',LENGTH(inst),'*'), RTRIM(inst)),'*') inst
            ,NVL(DECODE(RTRIM(course),NULL, RPAD('*',LENGTH(course),'*'), RTRIM(course)),'*') course
            ,NVL(DECODE(RTRIM(campus),NULL, RPAD('*',LENGTH(campus),'*'), RTRIM(campus)),'*') campus
            ,RTRIM(faculty) faculty
            ,RTRIM(home)  home
            ,RTRIM(decision) decision
            ,decisiondate
            ,decisionnumber
            ,RTRIM(reply) reply
            ,RTRIM(summaryconditions) summaryconditions
            ,entrymonth
            ,SUBSTR(LPAD(entryyear,4,0),3,2) entryyear
            ,entrypoint
            ,RTRIM(choicecancelled) choicecancelled
            ,RTRIM(action) action
            ,RTRIM(substitution) substitution
            ,datesubstituted
            ,DECODE(RTRIM(previousinst),NULL, RPAD('*',LENGTH(previousinst),'*'), RTRIM(previousinst)) previousinst
            ,DECODE(RTRIM(previouscourse),NULL, RPAD('*',LENGTH(previouscourse),'*'), RTRIM(previouscourse)) previouscourse
            ,DECODE(RTRIM(previouscampus),NULL, RPAD('*',LENGTH(previouscampus),'*'), RTRIM(previouscampus)) previouscampus
            ,RTRIM(ucasamendment) ucasamendment
            ,routebpref
            ,routebround
            ,RTRIM(SUBSTR(detail,1,20)) detail
            ,extraround
      FROM  igs_uc_ivstarc_2003_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivstarc_2003_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivstarc_2003_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarc_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVSTARC ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVSTARC', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivstarc_rec IN c_ivstarc(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivstarc_rec.appno,'IVSTARC','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivstarc_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istarc_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = l_appno
                  AND choiceno = c_ivstarc_rec.choiceno AND ucas_cycle = g_cyc_info_rec.configured_cycle ;


                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarc_ints (  appno,
                                                    choiceno,
                                                    lastchange,
                                                    inst,
                                                    course,
                                                    campus,
                                                    faculty,
                                                    home,
                                                    decision,
                                                    decisiondate,
                                                    decisionnumber,
                                                    reply,
                                                    summaryconditions,
                                                    entrymonth,
                                                    entryyear,
                                                    entrypoint,
                                                    choicecancelled,
                                                    action,
                                                    substitution,
                                                    datesubstituted,
                                                    previousinst,
                                                    previouscourse,
                                                    previouscampus,
                                                    ucasamendment,
                                                    routebpref,
                                                    routebround,
                                                    detail,
                                                    extraround,
                                                    residential,
                                                    record_status,
                                                    error_code,
                                                    ucas_cycle
                                                     )
                                         VALUES (   l_appno,
                                                    c_ivstarc_rec.choiceno,
                                                    c_ivstarc_rec.lastchange,
                                                    c_ivstarc_rec.inst,
                                                    c_ivstarc_rec.course,
                                                    c_ivstarc_rec.campus,
                                                    c_ivstarc_rec.faculty,
                                                    c_ivstarc_rec.home,
                                                    c_ivstarc_rec.decision,
                                                    c_ivstarc_rec.decisiondate,
                                                    c_ivstarc_rec.decisionnumber,
                                                    c_ivstarc_rec.reply,
                                                    c_ivstarc_rec.summaryconditions,
                                                    c_ivstarc_rec.entrymonth,
                                                    c_ivstarc_rec.entryyear,
                                                    c_ivstarc_rec.entrypoint,
                                                    c_ivstarc_rec.choicecancelled,
                                                    c_ivstarc_rec.action,
                                                    c_ivstarc_rec.substitution,
                                                    c_ivstarc_rec.datesubstituted,
                                                    c_ivstarc_rec.previousinst,
                                                    c_ivstarc_rec.previouscourse,
                                                    c_ivstarc_rec.previouscampus,
                                                    c_ivstarc_rec.ucasamendment,
                                                    c_ivstarc_rec.routebpref,
                                                    c_ivstarc_rec.routebround,
                                                    c_ivstarc_rec.detail,
                                                    c_ivstarc_rec.extraround,
                                                    NULL,
                                                    'N',
                                                    NULL ,
                                                    g_cyc_info_rec.configured_cycle
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVSTARC',   l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVSTARC', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVSTARC') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVSTARC_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivstarc_2003  ;


  PROCEDURE load_ivnstarc_2006 IS
    /******************************************************************
     Created By      :   jbaber
     Date Created By :   12-Aug-03
     Purpose         :   loads each record in the hercules view ivnstarc into the interface table
                         igs_uc_istarc_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     jbaber    29-Sep-05    Replace inst, course and campus values with '*' if NULL
                            and force 2-digit entry year for bug 4638126
     anwest    02-AUG-06    Bug #5440216 URGENT - UCAS CLEARING 2006 - PART 2 - CLEARING CHOICE NUMBER NULL
    ***************************************************************** */

     -- Get all the records from odbc-link view whose timestamp is > passed timestamp
      -- or get all the records in odbc-link view if the timestamp passed is null
      CURSOR c_ivnstarc ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
            ,NVL(choiceno,9) choiceno -- 02-AUG-2006 anwest Bug #5440216 URGENT - UCAS CLEARING 2006 - PART 2 - CLEARING CHOICE NUMBER NULL
            ,timestamp
            ,NVL(lastchange,SYSDATE) lastchange
            ,NVL(DECODE(RTRIM(inst),NULL, RPAD('*',LENGTH(inst),'*'), RTRIM(inst)),'*') inst
            ,NVL(DECODE(RTRIM(course),NULL, RPAD('*',LENGTH(course),'*'), RTRIM(course)),'*') course
            ,NVL(DECODE(RTRIM(campus),NULL, RPAD('*',LENGTH(campus),'*'), RTRIM(campus)),'*') campus
            ,RTRIM(residential) residential
            ,RTRIM(decision) decision
            ,decisiondate
            ,decisionnumber
            ,RTRIM(reply) reply
            ,entrymonth
            ,SUBSTR(LPAD(entryyear,4,0),3,2) entryyear
            ,RTRIM(choicecancelled) choicecancelled
            ,RTRIM(action) action
            ,RTRIM(substitution) substitution
            ,datesubstituted
            ,DECODE(RTRIM(previousinst),NULL, RPAD('*',LENGTH(previousinst),'*'), RTRIM(previousinst)) previousinst
            ,DECODE(RTRIM(previouscourse),NULL, RPAD('*',LENGTH(previouscourse),'*'), RTRIM(previouscourse)) previouscourse
            ,DECODE(RTRIM(previouscampus),NULL, RPAD('*',LENGTH(previouscampus),'*'), RTRIM(previouscampus)) previouscampus
      FROM  igs_uc_ivnstarc_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivnstarc_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivnstarc_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarc_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVNSTARC ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVNSTARC', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivnstarc_rec IN c_ivnstarc(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivnstarc_rec.appno,'IVNSTARC','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivnstarc_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istarc_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = l_appno
                  AND choiceno = c_ivnstarc_rec.choiceno AND ucas_cycle = g_cyc_info_rec.configured_cycle ;


                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarc_ints (  appno,
                                                    choiceno,
                                                    lastchange,
                                                    inst,
                                                    course,
                                                    campus,
                                                    residential,
                                                    decision,
                                                    decisiondate,
                                                    decisionnumber,
                                                    reply,
                                                    entrymonth,
                                                    entryyear,
                                                    choicecancelled,
                                                    action,
                                                    substitution,
                                                    datesubstituted,
                                                    previousinst,
                                                    previouscourse,
                                                    previouscampus,
                                                    record_status,
                                                    error_code,
                                                    ucas_cycle
                                                     )
                                         VALUES (   l_appno,
                                                    c_ivnstarc_rec.choiceno,
                                                    c_ivnstarc_rec.lastchange,
                                                    c_ivnstarc_rec.inst,
                                                    c_ivnstarc_rec.course,
                                                    c_ivnstarc_rec.campus,
                                                    c_ivnstarc_rec.residential,
                                                    c_ivnstarc_rec.decision,
                                                    c_ivnstarc_rec.decisiondate,
                                                    c_ivnstarc_rec.decisionnumber,
                                                    c_ivnstarc_rec.reply,
                                                    c_ivnstarc_rec.entrymonth,
                                                    c_ivnstarc_rec.entryyear,
                                                    c_ivnstarc_rec.choicecancelled,
                                                    c_ivnstarc_rec.action,
                                                    c_ivnstarc_rec.substitution,
                                                    c_ivnstarc_rec.datesubstituted,
                                                    c_ivnstarc_rec.previousinst,
                                                    c_ivnstarc_rec.previouscourse,
                                                    c_ivnstarc_rec.previouscampus,
                                                    'N',
                                                    NULL ,
                                                    g_cyc_info_rec.configured_cycle
                                                 ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVNSTARC',   l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVNSTARC', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVNSTARC') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVNSTARC_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivnstarc_2006  ;


  PROCEDURE load_ivgstarg_2006 IS
    /******************************************************************
     Created By      :   jbaber
     Date Created By :   12-Aug-03
     Purpose         :   loads each record in the hercules view ivgstarg into the interface table
                         igs_uc_istarg_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     jbaber    29-Sep-05    Replace inst, course and campus values with '*' if NULL
                            and force 2-digit entry year for bug 4638126
     anwest    02-AUG-06    Bug #5440216 URGENT - UCAS CLEARING 2006 - PART 2 - CLEARING CHOICE NUMBER NULL
    ***************************************************************** */

    -- Get all the records from odbc-link view whose timestamp is > passed timestamp
      -- or get all the records in odbc-link view if the timestamp passed is null
      CURSOR c_ivgstarg ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
            ,NVL(roundno,99) roundno -- 02-AUG-2006 anwest Bug #5440216 URGENT - UCAS CLEARING 2006 - PART 2 - CLEARING CHOICE NUMBER NULL
            ,timestamp
            ,NVL(lastchange,SYSDATE) lastchange
            ,NVL(DECODE(RTRIM(inst),NULL, RPAD('*',LENGTH(inst),'*'), RTRIM(inst)),'*') inst
            ,NVL(DECODE(RTRIM(course),NULL, RPAD('*',LENGTH(course),'*'), RTRIM(course)),'*') course
            ,NVL(DECODE(RTRIM(campus),NULL, RPAD('*',LENGTH(campus),'*'), RTRIM(campus)),'*') campus
            ,RTRIM(modular) modular
            ,RTRIM(parttime) parttime
            ,RTRIM(decision) decision
            ,RTRIM(reply) reply
            ,entrymonth
            ,SUBSTR(LPAD(entryyear,4,0),3,2) entryyear
            ,RTRIM(action) action
            ,RTRIM(english) english
            ,RTRIM(maths) maths
            ,RTRIM(science) science
            ,RTRIM(degreestatus) degreestatus
            ,RTRIM(degreesubject) degreesubject
            ,RTRIM(degreeclass) degreeclass
            ,interviewdate
            ,RTRIM(lateapplication) lateapplication
      FROM  igs_uc_ivgstarg_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivgstarg_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivgstarg_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarc_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVGSTARG ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVGSTARG', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivgstarg_rec IN c_ivgstarg(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivgstarg_rec.appno,'IVGSTARG','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivgstarg_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istarg_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = l_appno
                  AND roundno = c_ivgstarg_rec.roundno AND ucas_cycle = g_cyc_info_rec.configured_cycle ;



                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarg_ints (  appno,
                                                    roundno,
                                                    lastchange,
                                                    inst,
                                                    course,
                                                    campus,
                                                    modular,
                                                    parttime,
                                                    decision,
                                                    reply,
                                                    entrymonth,
                                                    entryyear,
                                                    action,
                                                    gcseeng,
                                                    gcsemath,
                                                    gcsesci,
                                                    degreestatus,
                                                    degreesubject,
                                                    degreeclass,
                                                    interview,
                                                    lateapplication,
                                                    record_status,
                                                    error_code,
                                                    ucas_cycle
                                                     )
                                         VALUES (   l_appno,
                                                    c_ivgstarg_rec.roundno,
                                                    c_ivgstarg_rec.lastchange,
                                                    c_ivgstarg_rec.inst,
                                                    c_ivgstarg_rec.course,
                                                    c_ivgstarg_rec.campus,
                                                    c_ivgstarg_rec.modular,
                                                    c_ivgstarg_rec.parttime,
                                                    c_ivgstarg_rec.decision,
                                                    c_ivgstarg_rec.reply,
                                                    c_ivgstarg_rec.entrymonth,
                                                    c_ivgstarg_rec.entryyear,
                                                    c_ivgstarg_rec.action,
                                                    c_ivgstarg_rec.english,
                                                    c_ivgstarg_rec.maths,
                                                    c_ivgstarg_rec.science,
                                                    c_ivgstarg_rec.degreestatus,
                                                    c_ivgstarg_rec.degreesubject,
                                                    c_ivgstarg_rec.degreeclass,
                                                    c_ivgstarg_rec.interviewdate,
                                                    c_ivgstarg_rec.lateapplication,
                                                    'N',
                                                    NULL ,
                                                    g_cyc_info_rec.configured_cycle
                                                 ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVGSTARG',   l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVGSTARG', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVGSTARG') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVGSTARG_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivgstarg_2006  ;


  PROCEDURE load_ivstarh_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :     loads each record in the hercules view ivstarh into the interface table
                           igs_uc_istarh_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     jbaber    15-Sep-05    Load NULL for lasteducation and educationleavedate for bug 4589994
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivstarh ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
           ,timestamp
           ,ethnic
           ,RTRIM(socialclass) socialclass
           ,pocceduchangedate
           ,RTRIM(pocc) pocc
           ,RTRIM(pocctext) pocctext
           ,NULL lasteducation
           ,NULL educationleavedate
           ,NULL lea    -- not used in hercules
           ,socialeconomic
      FROM  igs_uc_ivstarh_2003_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivstarh_2003_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivstarh_2003_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarh_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVSTARH ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVSTARH', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivstarh_rec IN c_ivstarh(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              --Validate varchar to number conversion
              IF  is_valid(c_ivstarh_rec.appno,'IVSTARH','APPNO','NUMBER') AND
                  is_valid(c_ivstarh_rec.ethnic,'IVSTARH','Ethnic','NUMBER')THEN

                  -- Determine actual appno
                  get_appno(c_ivstarh_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istarh_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = l_appno ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarh_ints (   appno,
                                                     ethnic,
                                                     socialclass,
                                                     pocceduchangedate,
                                                     pocc,
                                                     pocctext,
                                                     lasteducation,
                                                     educationleavedate,
                                                     lea,
                                                     socialeconomic,
                                                     dependants,
                                                     married,
                                                     record_status,
                                                     error_code
                                                     )
                                         VALUES (    l_appno,
                                                     c_ivstarh_rec.ethnic,
                                                     c_ivstarh_rec.socialclass,
                                                     c_ivstarh_rec.pocceduchangedate,
                                                     c_ivstarh_rec.pocc,
                                                     c_ivstarh_rec.pocctext,
                                                     c_ivstarh_rec.lasteducation,
                                                     c_ivstarh_rec.educationleavedate,
                                                     c_ivstarh_rec.lea,
                                                     c_ivstarh_rec.socialeconomic,
                                                     NULL ,
                                                     NULL ,
                                                     'N',
                                                     NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

       IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVSTARH', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVSTARH', l_count) ;
       ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVSTARH') ;
       END IF;
       COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVSTARH_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_ivstarh_2003   ;


  PROCEDURE load_ivgstarh_2006 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :   15-Aug-05
     Purpose         :     loads each record in the hercules view ivgstarh into the interface table
                           igs_uc_istarh_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivgstarh ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
           ,timestamp
           ,RTRIM(ethnic) ethnic
      FROM  igs_uc_ivgstarh_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivgstarh_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivgstarh_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarh_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVGSTARH ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVGSTARH', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivgstarh_rec IN c_ivgstarh(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              --Validate varchar to number conversion
              IF  is_valid(c_ivgstarh_rec.appno,'IVGSTARH','APPNO','NUMBER') AND
                  is_valid(c_ivgstarh_rec.ethnic,'IVGSTARH','Ethnic','NUMBER')THEN

                  -- Determine actual appno
                  get_appno(c_ivgstarh_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istarh_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = l_appno ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarh_ints (   appno,
                                                     ethnic,
                                                     record_status,
                                                     error_code
                                                     )
                                         VALUES (    l_appno,
                                                     c_ivgstarh_rec.ethnic,
                                                     'N',
                                                     NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

       IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVGSTARH', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVGSTARH', l_count) ;
       ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVGSTARH') ;
       END IF;
       COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVGSTARH_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_ivgstarh_2006   ;


  PROCEDURE load_ivnstarh_2006 IS
    /******************************************************************
     Created By      :   jbaber
     Date Created By :   15-Aug-05
     Purpose         :   loads each record in the hercules view ivnstarh into the interface table
                          with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivnstarh ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
           ,timestamp
           ,RTRIM(ethnic) ethnic
           ,numberdependants
           ,RTRIM(maritalstatus) maritalstatus
      FROM  igs_uc_ivnstarh_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivnstarh_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivnstarh_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarh_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVNSTARH ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVNSTARH', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivnstarh_rec IN c_ivnstarh(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              --Validate varchar to number conversion
              IF  is_valid(c_ivnstarh_rec.appno,'IVNSTARH','APPNO','NUMBER') AND
                  is_valid(c_ivnstarh_rec.ethnic,'IVNSTARH','Ethnic','NUMBER')THEN

                  -- Determine actual appno
                  get_appno(c_ivnstarh_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istarh_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = l_appno ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarh_ints (   appno,
                                                     ethnic,
                                                     dependants,
                                                     married,
                                                     record_status,
                                                     error_code
                                                     )
                                         VALUES (    l_appno,
                                                     c_ivnstarh_rec.ethnic,
                                                     c_ivnstarh_rec.numberdependants,
                                                     c_ivnstarh_rec.maritalstatus,
                                                     'N',
                                                     NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

       IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVNSTARH', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVNSTARH', l_count) ;
       ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVNSTARH') ;
       END IF;
       COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVNSTARH_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_ivnstarh_2006   ;


  PROCEDURE load_ivstark_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :     loads each record in the hercules view ivstark into the interface table
                           igs_uc_istark_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     smaddali  7-aug-03   Modified value for field EAS for bug#3087852
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      -- converting EAS field ,for bug#3087852
      CURSOR c_ivstark ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
             ,timestamp
             ,applicationdate
             ,sentdate
             ,runsent
             ,codedchangedate
             ,school
             ,RTRIM(rescat) rescat
             ,feelevel
             ,feepayer
             ,RTRIM(feetext) feetext
             ,apr
             ,NULL lea    -- not used in hercules
             ,countrybirth
             ,nationality
             ,dualnationality
             ,RTRIM(withdrawn) withdrawn
             ,withdrawndate
             ,RTRIM(routeb) routeb
             ,examchangedate
             ,NULL alevels   -- not used in hercules
             ,NULL aslevels  -- not used in hercules
             ,NULL highers   -- not used in hercules
             ,NULL csys      -- not used in hercules
             ,winter
             ,previousa
             ,RTRIM(btec) btec
             ,RTRIM(ilc) ilc
             ,RTRIM(aice) aice
             ,RTRIM(ib) ib
             ,RTRIM(manual) manual
             ,RTRIM(regno) regno
             ,RTRIM(oeq) oeq
             ,DECODE(RTRIM(eas),'Y','E',RTRIM(eas) )  eas
             ,RTRIM(roa) roa
             ,specialneeds
             ,RTRIM(status) status
             ,firmnow
             ,firmreply
             ,insurancereply
             ,confhistfirmreply
             ,confhistinsurancereply
             ,gce
             ,vce
             ,RTRIM(sqa) sqa
             ,previousas
             ,RTRIM(keyskills) keyskills
             ,RTRIM(vocational) vocational
             ,NULL gnvq      -- not used in hercules
             ,RTRIM(scn) scn
             ,RTRIM(prevoeq) prevoeq
             ,ukentrydate
             ,RTRIM(criminalconv) criminalconv
             ,RTRIM(choicesalltransparent) choicesalltransparent
             ,extrastatus
             ,RTRIM(extrapassportno) extrapassportno
      FROM  igs_uc_ivstark_2003_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivstark_2003_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivstark_2003_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istark_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVSTARK ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVSTARK', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivstark_rec IN c_ivstark(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              --Validate varchar to number conversion
              IF  is_valid(c_ivstark_rec.appno,'IVSTARK','APPNO','NUMBER') AND
                  is_valid(c_ivstark_rec.runsent,'IVSTARK','RunSent','NUMBER') AND
                  is_valid(c_ivstark_rec.school,'IVSTARK','School','NUMBER') AND
                  is_valid(c_ivstark_rec.feepayer,'IVSTARK','FeePayer','NUMBER') AND
                  is_valid(c_ivstark_rec.apr,'IVSTARK','APR','NUMBER') AND
                  is_valid(c_ivstark_rec.countrybirth,'IVSTARK','CountryBirth','NUMBER') AND
                  is_valid(c_ivstark_rec.nationality,'IVSTARK','Nationality','NUMBER') AND
                  is_valid(c_ivstark_rec.dualnationality,'IVSTARK','DualNationality','NUMBER') AND
                  is_valid(c_ivstark_rec.extrastatus,'IVSTARK','ExtraStatus','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivstark_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istark_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = l_appno   ;


                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istark_ints (   appno,
                                                     applicationdate,
                                                     sentdate,
                                                     runsent,
                                                     codedchangedate,
                                                     school,
                                                     rescat,
                                                     feelevel,
                                                     feepayer,
                                                     feetext,
                                                     apr,
                                                     lea,
                                                     countrybirth,
                                                     nationality,
                                                     dualnationality,
                                                     withdrawn,
                                                     withdrawndate,
                                                     routeb,
                                                     examchangedate,
                                                     alevels,
                                                     aslevels,
                                                     highers,
                                                     csys,
                                                     gce,
                                                     vce,
                                                     sqa,
                                                     winter,
                                                     previousa,
                                                     previousas,
                                                     keyskills,
                                                     vocational,
                                                     gnvq,
                                                     btec,
                                                     ilc,
                                                     aice,
                                                     ib,
                                                     manual,
                                                     regno,
                                                     scn,
                                                     oeq,
                                                     prevoeq,
                                                     eas,
                                                     roa,
                                                     specialneeds,
                                                     criminalconv,
                                                     ukentrydate,
                                                     status,
                                                     firmnow,
                                                     firmreply,
                                                     insurancereply,
                                                     confhistfirmreply,
                                                     confhistinsurancereply,
                                                     choicesalltransparent,
                                                     extrastatus,
                                                     extrapassportno,
                                                     welshspeaker,
                                                     ninumber,
                                                     earlieststart,
                                                     nearinst,
                                                     prefreg,
                                                     qualeng,
                                                     qualmath,
                                                     qualsci,
                                                     mainqual,
                                                     qual5,
                                                     record_status,
                                                     error_code
                                                     )
                                         VALUES (    l_appno,
                                                     c_ivstark_rec.applicationdate,
                                                     c_ivstark_rec.sentdate,
                                                     c_ivstark_rec.runsent,
                                                     c_ivstark_rec.codedchangedate,
                                                     c_ivstark_rec.school,
                                                     c_ivstark_rec.rescat,
                                                     c_ivstark_rec.feelevel,
                                                     c_ivstark_rec.feepayer,
                                                     c_ivstark_rec.feetext,
                                                     c_ivstark_rec.apr,
                                                     c_ivstark_rec.lea,
                                                     c_ivstark_rec.countrybirth,
                                                     c_ivstark_rec.nationality,
                                                     c_ivstark_rec.dualnationality,
                                                     c_ivstark_rec.withdrawn,
                                                     c_ivstark_rec.withdrawndate,
                                                     c_ivstark_rec.routeb,
                                                     c_ivstark_rec.examchangedate,
                                                     c_ivstark_rec.alevels,
                                                     c_ivstark_rec.aslevels,
                                                     c_ivstark_rec.highers,
                                                     c_ivstark_rec.csys,
                                                     c_ivstark_rec.gce,
                                                     c_ivstark_rec.vce,
                                                     c_ivstark_rec.sqa,
                                                     c_ivstark_rec.winter,
                                                     c_ivstark_rec.previousa,
                                                     c_ivstark_rec.previousas,
                                                     c_ivstark_rec.keyskills,
                                                     c_ivstark_rec.vocational,
                                                     c_ivstark_rec.gnvq,
                                                     c_ivstark_rec.btec,
                                                     c_ivstark_rec.ilc,
                                                     c_ivstark_rec.aice,
                                                     c_ivstark_rec.ib,
                                                     c_ivstark_rec.manual,
                                                     c_ivstark_rec.regno,
                                                     c_ivstark_rec.scn,
                                                     c_ivstark_rec.oeq,
                                                     c_ivstark_rec.prevoeq,
                                                     NVL(c_ivstark_rec.eas,'P'), -- converting EAS field ,for bug#3087852
                                                     c_ivstark_rec.roa,
                                                     c_ivstark_rec.specialneeds,
                                                     c_ivstark_rec.criminalconv,
                                                     c_ivstark_rec.ukentrydate,
                                                     c_ivstark_rec.status,
                                                     c_ivstark_rec.firmnow,
                                                     c_ivstark_rec.firmreply,
                                                     c_ivstark_rec.insurancereply,
                                                     c_ivstark_rec.confhistfirmreply,
                                                     c_ivstark_rec.confhistinsurancereply,
                                                     c_ivstark_rec.choicesalltransparent,
                                                     c_ivstark_rec.extrastatus,
                                                     c_ivstark_rec.extrapassportno,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVSTARK',   l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVSTARK', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVSTARK') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVSTARK_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_ivstark_2003   ;

  PROCEDURE load_ivstark_2007 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jul-06
     Purpose         :     loads each record in the hercules view ivstark into the interface table
                           igs_uc_istark_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     smaddali  7-aug-03   Modified value for field EAS for bug#3087852
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      -- converting EAS field ,for bug#3087852
      CURSOR c_ivstark ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
             ,timestamp
             ,applicationdate
             ,sentdate
             ,runsent
             ,codedchangedate
             ,school
             ,RTRIM(rescat) rescat
             ,feelevel
             ,feepayer
             ,RTRIM(feetext) feetext
             ,apr
             ,NULL lea    -- not used in hercules
             ,countrybirth
             ,nationality
             ,dualnationality
             ,RTRIM(withdrawn) withdrawn
             ,withdrawndate
             ,RTRIM(routeb) routeb
             ,examchangedate
             ,NULL alevels   -- not used in hercules
             ,NULL aslevels  -- not used in hercules
             ,NULL highers   -- not used in hercules
             ,NULL csys      -- not used in hercules
             ,winter
             ,previousa
             ,RTRIM(btec) btec
             ,RTRIM(ilc) ilc
             ,RTRIM(aice) aice
             ,RTRIM(ib) ib
             ,RTRIM(manual) manual
             ,RTRIM(regno) regno
             ,RTRIM(oeq) oeq
             ,DECODE(RTRIM(eas),'Y','E',RTRIM(eas) )  eas
             ,RTRIM(roa) roa
             ,disability
             ,RTRIM(status) status
             ,firmnow
             ,firmreply
             ,insurancereply
             ,confhistfirmreply
             ,confhistinsurancereply
             ,gce
             ,vce
             ,RTRIM(sqa) sqa
             ,previousas
             ,RTRIM(keyskills) keyskills
             ,RTRIM(vocational) vocational
             ,NULL gnvq      -- not used in hercules
             ,RTRIM(scn) scn
             ,RTRIM(prevoeq) prevoeq
             ,ukentrydate
             ,RTRIM(criminalconv) criminalconv
             ,RTRIM(choicesalltransparent) choicesalltransparent
             ,extrastatus
             ,RTRIM(extrapassportno) extrapassportno
      FROM  igs_uc_ivstark_2007_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivstark_2007_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivstark_2007_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istark_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVSTARK ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVSTARK', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivstark_rec IN c_ivstark(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              --Validate varchar to number conversion
              IF  is_valid(c_ivstark_rec.appno,'IVSTARK','APPNO','NUMBER') AND
                  is_valid(c_ivstark_rec.runsent,'IVSTARK','RunSent','NUMBER') AND
                  is_valid(c_ivstark_rec.school,'IVSTARK','School','NUMBER') AND
                  is_valid(c_ivstark_rec.feepayer,'IVSTARK','FeePayer','NUMBER') AND
                  is_valid(c_ivstark_rec.apr,'IVSTARK','APR','NUMBER') AND
                  is_valid(c_ivstark_rec.countrybirth,'IVSTARK','CountryBirth','NUMBER') AND
                  is_valid(c_ivstark_rec.nationality,'IVSTARK','Nationality','NUMBER') AND
                  is_valid(c_ivstark_rec.dualnationality,'IVSTARK','DualNationality','NUMBER') AND
                  is_valid(c_ivstark_rec.extrastatus,'IVSTARK','ExtraStatus','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivstark_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istark_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = l_appno   ;


                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istark_ints (   appno,
                                                     applicationdate,
                                                     sentdate,
                                                     runsent,
                                                     codedchangedate,
                                                     school,
                                                     rescat,
                                                     feelevel,
                                                     feepayer,
                                                     feetext,
                                                     apr,
                                                     lea,
                                                     countrybirth,
                                                     nationality,
                                                     dualnationality,
                                                     withdrawn,
                                                     withdrawndate,
                                                     routeb,
                                                     examchangedate,
                                                     alevels,
                                                     aslevels,
                                                     highers,
                                                     csys,
                                                     gce,
                                                     vce,
                                                     sqa,
                                                     winter,
                                                     previousa,
                                                     previousas,
                                                     keyskills,
                                                     vocational,
                                                     gnvq,
                                                     btec,
                                                     ilc,
                                                     aice,
                                                     ib,
                                                     manual,
                                                     regno,
                                                     scn,
                                                     oeq,
                                                     prevoeq,
                                                     eas,
                                                     roa,
                                                     specialneeds,
                                                     criminalconv,
                                                     ukentrydate,
                                                     status,
                                                     firmnow,
                                                     firmreply,
                                                     insurancereply,
                                                     confhistfirmreply,
                                                     confhistinsurancereply,
                                                     choicesalltransparent,
                                                     extrastatus,
                                                     extrapassportno,
                                                     welshspeaker,
                                                     ninumber,
                                                     earlieststart,
                                                     nearinst,
                                                     prefreg,
                                                     qualeng,
                                                     qualmath,
                                                     qualsci,
                                                     mainqual,
                                                     qual5,
                                                     record_status,
                                                     error_code
                                                     )
                                         VALUES (    l_appno,
                                                     c_ivstark_rec.applicationdate,
                                                     c_ivstark_rec.sentdate,
                                                     c_ivstark_rec.runsent,
                                                     c_ivstark_rec.codedchangedate,
                                                     c_ivstark_rec.school,
                                                     c_ivstark_rec.rescat,
                                                     c_ivstark_rec.feelevel,
                                                     c_ivstark_rec.feepayer,
                                                     c_ivstark_rec.feetext,
                                                     c_ivstark_rec.apr,
                                                     c_ivstark_rec.lea,
                                                     c_ivstark_rec.countrybirth,
                                                     c_ivstark_rec.nationality,
                                                     c_ivstark_rec.dualnationality,
                                                     c_ivstark_rec.withdrawn,
                                                     c_ivstark_rec.withdrawndate,
                                                     c_ivstark_rec.routeb,
                                                     c_ivstark_rec.examchangedate,
                                                     c_ivstark_rec.alevels,
                                                     c_ivstark_rec.aslevels,
                                                     c_ivstark_rec.highers,
                                                     c_ivstark_rec.csys,
                                                     c_ivstark_rec.gce,
                                                     c_ivstark_rec.vce,
                                                     c_ivstark_rec.sqa,
                                                     c_ivstark_rec.winter,
                                                     c_ivstark_rec.previousa,
                                                     c_ivstark_rec.previousas,
                                                     c_ivstark_rec.keyskills,
                                                     c_ivstark_rec.vocational,
                                                     c_ivstark_rec.gnvq,
                                                     c_ivstark_rec.btec,
                                                     c_ivstark_rec.ilc,
                                                     c_ivstark_rec.aice,
                                                     c_ivstark_rec.ib,
                                                     c_ivstark_rec.manual,
                                                     c_ivstark_rec.regno,
                                                     c_ivstark_rec.scn,
                                                     c_ivstark_rec.oeq,
                                                     c_ivstark_rec.prevoeq,
                                                     NVL(c_ivstark_rec.eas,'P'), -- converting EAS field ,for bug#3087852
                                                     c_ivstark_rec.roa,
                                                     c_ivstark_rec.disability,
                                                     c_ivstark_rec.criminalconv,
                                                     c_ivstark_rec.ukentrydate,
                                                     c_ivstark_rec.status,
                                                     c_ivstark_rec.firmnow,
                                                     c_ivstark_rec.firmreply,
                                                     c_ivstark_rec.insurancereply,
                                                     c_ivstark_rec.confhistfirmreply,
                                                     c_ivstark_rec.confhistinsurancereply,
                                                     c_ivstark_rec.choicesalltransparent,
                                                     c_ivstark_rec.extrastatus,
                                                     c_ivstark_rec.extrapassportno,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVSTARK',   l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVSTARK', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVSTARK') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVSTARK_2007');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_ivstark_2007   ;


  PROCEDURE load_ivgstark_2006 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :  15-Aug-05
     Purpose         :  loads each record in the hercules view ivgstark into the interface table
                        igs_uc_istark_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      -- converting EAS field ,for bug#3087852
      CURSOR c_ivgstark ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
             ,timestamp
             ,applicationdate
             ,codedchangedate
             ,RTRIM(rescat) rescat
             ,feepayer
             ,apr
             ,countrybirth
             ,nationality
             ,RTRIM(withdrawn) withdrawn
             ,withdrawndate
             ,DECODE(RTRIM(eas),'Y','E',RTRIM(eas) )  eas
             ,specialneeds
             ,ukentrydate
             ,RTRIM(status) status
             ,firmnow
             ,extrastatus
      FROM  igs_uc_ivgstark_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivgstark_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivgstark_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istark_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVGSTARK ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVGSTARK', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivgstark_rec IN c_ivgstark(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              --Validate varchar to number conversion
              IF  is_valid(c_ivgstark_rec.appno,'IVGSTARK','APPNO','NUMBER') AND
                  is_valid(c_ivgstark_rec.feepayer,'IVGSTARK','FeePayer','NUMBER') AND
                  is_valid(c_ivgstark_rec.apr,'IVGSTARK','APR','NUMBER') AND
                  is_valid(c_ivgstark_rec.countrybirth,'IVGSTARK','CountryBirth','NUMBER') AND
                  is_valid(c_ivgstark_rec.nationality,'IVGSTARK','Nationality','NUMBER') AND
                  is_valid(c_ivgstark_rec.extrastatus,'IVGSTARK','ExtraStatus','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivgstark_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istark_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = l_appno   ;


                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istark_ints (   appno,
                                                     applicationdate,
                                                     rescat,
                                                     feepayer,
                                                     apr,
                                                     countrybirth,
                                                     nationality,
                                                     withdrawn,
                                                     withdrawndate,
                                                     eas,
                                                     specialneeds,
                                                     ukentrydate,
                                                     status,
                                                     firmnow,
                                                     extrastatus,
                                                     record_status,
                                                     error_code
                                                     )
                                         VALUES (    l_appno,
                                                     c_ivgstark_rec.applicationdate,
                                                     c_ivgstark_rec.rescat,
                                                     c_ivgstark_rec.feepayer,
                                                     c_ivgstark_rec.apr,
                                                     c_ivgstark_rec.countrybirth,
                                                     c_ivgstark_rec.nationality,
                                                     c_ivgstark_rec.withdrawn,
                                                     c_ivgstark_rec.withdrawndate,
                                                     NVL(c_ivgstark_rec.eas,'P'), -- converting EAS field ,for bug#3087852
                                                     c_ivgstark_rec.specialneeds,
                                                     c_ivgstark_rec.ukentrydate,
                                                     c_ivgstark_rec.status,
                                                     c_ivgstark_rec.firmnow,
                                                     c_ivgstark_rec.extrastatus,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVGSTARK',   l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVGSTARK', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVGSTARK') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVGSTARK_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_ivgstark_2006   ;


  PROCEDURE load_ivgstark_2007 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :  11-Jul-06
     Purpose         :  loads each record in the hercules view ivgstark into the interface table
                        igs_uc_istark_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      -- converting EAS field ,for bug#3087852
      CURSOR c_ivgstark ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
             ,timestamp
             ,applicationdate
             ,codedchangedate
             ,RTRIM(rescat) rescat
             ,feepayer
             ,apr
             ,countrybirth
             ,nationality
             ,RTRIM(withdrawn) withdrawn
             ,withdrawndate
             ,DECODE(RTRIM(eas),'Y','E',RTRIM(eas) )  eas
             ,disability
             ,ukentrydate
             ,RTRIM(status) status
             ,firmnow
             ,extrastatus
      FROM  igs_uc_ivgstark_2007_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivgstark_2007_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivgstark_2007_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istark_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVGSTARK ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVGSTARK', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivgstark_rec IN c_ivgstark(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              --Validate varchar to number conversion
              IF  is_valid(c_ivgstark_rec.appno,'IVGSTARK','APPNO','NUMBER') AND
                  is_valid(c_ivgstark_rec.feepayer,'IVGSTARK','FeePayer','NUMBER') AND
                  is_valid(c_ivgstark_rec.apr,'IVGSTARK','APR','NUMBER') AND
                  is_valid(c_ivgstark_rec.countrybirth,'IVGSTARK','CountryBirth','NUMBER') AND
                  is_valid(c_ivgstark_rec.nationality,'IVGSTARK','Nationality','NUMBER') AND
                  is_valid(c_ivgstark_rec.extrastatus,'IVGSTARK','ExtraStatus','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivgstark_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istark_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = l_appno   ;


                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istark_ints (   appno,
                                                     applicationdate,
                                                     rescat,
                                                     feepayer,
                                                     apr,
                                                     countrybirth,
                                                     nationality,
                                                     withdrawn,
                                                     withdrawndate,
                                                     eas,
                                                     specialneeds,
                                                     ukentrydate,
                                                     status,
                                                     firmnow,
                                                     extrastatus,
                                                     record_status,
                                                     error_code
                                                     )
                                         VALUES (    l_appno,
                                                     c_ivgstark_rec.applicationdate,
                                                     c_ivgstark_rec.rescat,
                                                     c_ivgstark_rec.feepayer,
                                                     c_ivgstark_rec.apr,
                                                     c_ivgstark_rec.countrybirth,
                                                     c_ivgstark_rec.nationality,
                                                     c_ivgstark_rec.withdrawn,
                                                     c_ivgstark_rec.withdrawndate,
                                                     NVL(c_ivgstark_rec.eas,'P'), -- converting EAS field ,for bug#3087852
                                                     c_ivgstark_rec.disability,
                                                     c_ivgstark_rec.ukentrydate,
                                                     c_ivgstark_rec.status,
                                                     c_ivgstark_rec.firmnow,
                                                     c_ivgstark_rec.extrastatus,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVGSTARK',   l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVGSTARK', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVGSTARK') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVGSTARK_2007');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_ivgstark_2007   ;


  PROCEDURE load_ivnstark_2006 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :  15-Aug-05
     Purpose         :  loads each record in the hercules view ivnstark into the interface table
                        igs_uc_istark_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      -- converting EAS field ,for bug#3087852
      CURSOR c_ivnstark ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
             ,timestamp
             ,applicationdate
             ,sentdate
             ,runsent
             ,codedchangedate
             ,RTRIM(rescat) rescat
             ,feelevel
             ,apr
             ,countrybirth
             ,nationality
             ,RTRIM(withdrawn) withdrawn
             ,withdrawndate
             ,qualenglish
             ,qualmaths
             ,qualscience
             ,qual5point
             ,qualmain
             ,nationalinsurance
             ,startdate
             ,nearestinst
             ,prefregion
             ,specialneeds
             ,RTRIM(status) status
             ,firmnow
             ,ukentrydate
             ,DECODE(RTRIM(eas),'Y','E',RTRIM(eas) )  eas
      FROM  igs_uc_ivnstark_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivnstark_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivnstark_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istark_ints.appno%TYPE;
      l_checkdigit NUMBER;

      l_startdate  DATE;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVNSTARK ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVNSTARK', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivnstark_rec IN c_ivnstark(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              --Validate varchar to number conversion
              IF  is_valid(c_ivnstark_rec.appno,'IVNSTARK','APPNO','NUMBER') AND
                  is_valid(c_ivnstark_rec.runsent,'IVNSTARK','RunSent','NUMBER') AND
                  is_valid(c_ivnstark_rec.apr,'IVNSTARK','APR','NUMBER') AND
                  is_valid(c_ivnstark_rec.countrybirth,'IVNSTARK','CountryBirth','NUMBER') AND
                  is_valid(c_ivnstark_rec.nationality,'IVNSTARK','Nationality','NUMBER') AND
                  is_valid(c_ivnstark_rec.prefregion,'IVNSTARK','PrefRegion','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivnstark_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Implicility convert startdate to date to avoid compile errors when pointing to DUMMY
                  l_startdate := c_ivnstark_rec.startdate;

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istark_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = l_appno   ;


                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istark_ints (   appno,
                                                     applicationdate,
                                                     sentdate,
                                                     runsent,
                                                     codedchangedate,
                                                     rescat,
                                                     feelevel,
                                                     apr,
                                                     countrybirth,
                                                     nationality,
                                                     withdrawn,
                                                     withdrawndate,
                                                     qualeng,
                                                     qualmath,
                                                     qualsci,
                                                     qual5,
                                                     mainqual,
                                                     ninumber,
                                                     earlieststart,
                                                     nearinst,
                                                     prefreg,
                                                     specialneeds,
                                                     status,
                                                     firmnow,
                                                     ukentrydate,
                                                     eas,
                                                     record_status,
                                                     error_code
                                                     )
                                         VALUES (    l_appno,
                                                     c_ivnstark_rec.applicationdate,
                                                     c_ivnstark_rec.sentdate,
                                                     c_ivnstark_rec.runsent,
                                                     c_ivnstark_rec.codedchangedate,
                                                     c_ivnstark_rec.rescat,
                                                     c_ivnstark_rec.feelevel,
                                                     c_ivnstark_rec.apr,
                                                     c_ivnstark_rec.countrybirth,
                                                     c_ivnstark_rec.nationality,
                                                     c_ivnstark_rec.withdrawn,
                                                     c_ivnstark_rec.withdrawndate,
                                                     c_ivnstark_rec.qualenglish,
                                                     c_ivnstark_rec.qualmaths,
                                                     c_ivnstark_rec.qualscience,
                                                     c_ivnstark_rec.qual5point,
                                                     c_ivnstark_rec.qualmain,
                                                     c_ivnstark_rec.nationalinsurance,
                                                     TO_CHAR(l_startdate,'mmyy'),
                                                     c_ivnstark_rec.nearestinst,
                                                     c_ivnstark_rec.prefregion,
                                                     c_ivnstark_rec.specialneeds,
                                                     c_ivnstark_rec.status,
                                                     c_ivnstark_rec.firmnow,
                                                     c_ivnstark_rec.ukentrydate,
                                                     NVL(c_ivnstark_rec.eas,'P'), -- converting EAS field ,for bug#3087852
                                                     'N',
                                                     NULL
                                                     ) ;

                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVNSTARK',   l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVNSTARK', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVNSTARK') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVNSTARK_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_ivnstark_2006   ;


  PROCEDURE load_ivnstark_2007 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :  11-Jul-06
     Purpose         :  loads each record in the hercules view ivnstark into the interface table
                        igs_uc_istark_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      -- converting EAS field ,for bug#3087852
      CURSOR c_ivnstark ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
             ,timestamp
             ,applicationdate
             ,sentdate
             ,runsent
             ,codedchangedate
             ,RTRIM(rescat) rescat
             ,feelevel
             ,apr
             ,countrybirth
             ,nationality
             ,RTRIM(withdrawn) withdrawn
             ,withdrawndate
             ,qualenglish
             ,qualmaths
             ,qualscience
             ,qual5point
             ,qualmain
             ,nationalinsurance
             ,startdate
             ,nearestinst
             ,prefregion
             ,disability
             ,RTRIM(status) status
             ,firmnow
             ,ukentrydate
             ,DECODE(RTRIM(eas),'Y','E',RTRIM(eas) )  eas
      FROM  igs_uc_ivnstark_2007_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivnstark_2007_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivnstark_2007_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istark_ints.appno%TYPE;
      l_checkdigit NUMBER;

      l_startdate  DATE;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVNSTARK ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVNSTARK', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivnstark_rec IN c_ivnstark(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              --Validate varchar to number conversion
              IF  is_valid(c_ivnstark_rec.appno,'IVNSTARK','APPNO','NUMBER') AND
                  is_valid(c_ivnstark_rec.runsent,'IVNSTARK','RunSent','NUMBER') AND
                  is_valid(c_ivnstark_rec.apr,'IVNSTARK','APR','NUMBER') AND
                  is_valid(c_ivnstark_rec.countrybirth,'IVNSTARK','CountryBirth','NUMBER') AND
                  is_valid(c_ivnstark_rec.nationality,'IVNSTARK','Nationality','NUMBER') AND
                  is_valid(c_ivnstark_rec.prefregion,'IVNSTARK','PrefRegion','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivnstark_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Implicility convert startdate to date to avoid compile errors when pointing to DUMMY
                  l_startdate := c_ivnstark_rec.startdate;

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istark_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND  appno = l_appno   ;


                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istark_ints (   appno,
                                                     applicationdate,
                                                     sentdate,
                                                     runsent,
                                                     codedchangedate,
                                                     rescat,
                                                     feelevel,
                                                     apr,
                                                     countrybirth,
                                                     nationality,
                                                     withdrawn,
                                                     withdrawndate,
                                                     qualeng,
                                                     qualmath,
                                                     qualsci,
                                                     qual5,
                                                     mainqual,
                                                     ninumber,
                                                     earlieststart,
                                                     nearinst,
                                                     prefreg,
                                                     specialneeds,
                                                     status,
                                                     firmnow,
                                                     ukentrydate,
                                                     eas,
                                                     record_status,
                                                     error_code
                                                     )
                                         VALUES (    l_appno,
                                                     c_ivnstark_rec.applicationdate,
                                                     c_ivnstark_rec.sentdate,
                                                     c_ivnstark_rec.runsent,
                                                     c_ivnstark_rec.codedchangedate,
                                                     c_ivnstark_rec.rescat,
                                                     c_ivnstark_rec.feelevel,
                                                     c_ivnstark_rec.apr,
                                                     c_ivnstark_rec.countrybirth,
                                                     c_ivnstark_rec.nationality,
                                                     c_ivnstark_rec.withdrawn,
                                                     c_ivnstark_rec.withdrawndate,
                                                     c_ivnstark_rec.qualenglish,
                                                     c_ivnstark_rec.qualmaths,
                                                     c_ivnstark_rec.qualscience,
                                                     c_ivnstark_rec.qual5point,
                                                     c_ivnstark_rec.qualmain,
                                                     c_ivnstark_rec.nationalinsurance,
                                                     TO_CHAR(l_startdate,'mmyy'),
                                                     c_ivnstark_rec.nearestinst,
                                                     c_ivnstark_rec.prefregion,
                                                     c_ivnstark_rec.disability,
                                                     c_ivnstark_rec.status,
                                                     c_ivnstark_rec.firmnow,
                                                     c_ivnstark_rec.ukentrydate,
                                                     NVL(c_ivnstark_rec.eas,'P'), -- converting EAS field ,for bug#3087852
                                                     'N',
                                                     NULL
                                                     ) ;

                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVNSTARK',   l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVNSTARK', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVNSTARK') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVNSTARK_2007');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_ivnstark_2007   ;


  PROCEDURE load_ivstarn_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :     loads each record in the hercules view ivstarn into the interface table
                           igs_uc_istarn_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivstarn ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  appno
            ,timestamp
            ,checkdigit
            ,namechangedate
            ,UPPER(RTRIM(title)) title
            ,RTRIM(forenames) forenames
            ,DECODE(RTRIM(surname),NULL, RPAD('*',LENGTH(surname),'*'), RTRIM(surname)) surname
            ,birthdate
            ,sex
      FROM  igs_uc_ivstarn_2003_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivstarn_2003_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivstarn_2003_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarn_ints.appno%TYPE;
      l_checkdigit igs_uc_istarn_ints.checkdigit%TYPE;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVSTARN ON ' ) ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVSTARN',  p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivstarn_rec IN c_ivstarn(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivstarn_rec.appno,'IVSTARN','APPNO','NUMBER') THEN

                  -- Determine actual appno and checkdigit
                  get_appno(c_ivstarn_rec.appno, c_ivstarn_rec.checkdigit, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N / I
                  UPDATE igs_uc_istarn_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND appno = l_appno  ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarn_ints (  appno,
                                                    checkdigit,
                                                    namechangedate,
                                                    title,
                                                    forenames,
                                                    surname,
                                                    birthdate,
                                                    sex,
                                                    ad_batch_id,
                                                    ad_interface_id,
                                                    ad_api_id,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   l_appno,
                                                    l_checkdigit,
                                                    c_ivstarn_rec.namechangedate,
                                                    c_ivstarn_rec.title,
                                                    c_ivstarn_rec.forenames,
                                                    c_ivstarn_rec.surname,
                                                    c_ivstarn_rec.birthdate,
                                                    c_ivstarn_rec.sex,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVSTARN', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVSTARN', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVSTARN') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVSTARN_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivstarn_2003  ;


  PROCEDURE load_ivstarn_2007 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :   11-Jul-06
     Purpose         :     loads each record in the hercules view ivstarn into the interface table
                           igs_uc_istarn_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivstarn ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  appno
            ,RTRIM(personalid) personalid
            ,timestamp
            ,checkdigit
            ,namechangedate
            ,UPPER(RTRIM(title)) title
            ,RTRIM(forenames) forenames
            ,DECODE(RTRIM(surname),NULL, RPAD('*',LENGTH(surname),'*'), RTRIM(surname)) surname
            ,birthdate
            ,sex
      FROM  igs_uc_ivstarn_2007_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivstarn_2007_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivstarn_2007_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarn_ints.appno%TYPE;
      l_checkdigit igs_uc_istarn_ints.checkdigit%TYPE;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVSTARN ON ' ) ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVSTARN',  p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivstarn_rec IN c_ivstarn(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivstarn_rec.appno,'IVSTARN','APPNO','NUMBER') THEN

                  -- Determine actual appno and checkdigit
                  get_appno(c_ivstarn_rec.appno, c_ivstarn_rec.checkdigit, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N / I
                  UPDATE igs_uc_istarn_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND appno = l_appno  ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarn_ints (  appno,
                                                    checkdigit,
                                                    personalid,
                                                    namechangedate,
                                                    title,
                                                    forenames,
                                                    surname,
                                                    birthdate,
                                                    sex,
                                                    ad_batch_id,
                                                    ad_interface_id,
                                                    ad_api_id,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   l_appno,
                                                    l_checkdigit,
                                                    c_ivstarn_rec.personalid,
                                                    c_ivstarn_rec.namechangedate,
                                                    c_ivstarn_rec.title,
                                                    c_ivstarn_rec.forenames,
                                                    c_ivstarn_rec.surname,
                                                    c_ivstarn_rec.birthdate,
                                                    c_ivstarn_rec.sex,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVSTARN', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVSTARN', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVSTARN') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVSTARN_2007');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivstarn_2007  ;


  PROCEDURE load_ivgstarn_2006 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :  16-Aug-05
     Purpose         :  loads each record in the hercules view ivgstarn into the interface table
                        igs_uc_istarn_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivgstarn ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  appno
            ,timestamp
            ,UPPER(RTRIM(title)) title
            ,RTRIM(forenames) forenames
            ,DECODE(RTRIM(surname),NULL, RPAD('*',LENGTH(surname),'*'), RTRIM(surname)) surname
            ,birthdate
            ,sex
      FROM  igs_uc_ivgstarn_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivgstarn_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivgstarn_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarn_ints.appno%TYPE;
      l_checkdigit igs_uc_istarn_ints.checkdigit%TYPE;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVGSTARN ON ' ) ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVGSTARN',  p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivgstarn_rec IN c_ivgstarn(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivgstarn_rec.appno,'IVGSTARN','APPNO','NUMBER') THEN

                  -- Determine actual appno and checkdigit
                  get_appno(c_ivgstarn_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N / I
                  UPDATE igs_uc_istarn_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND appno = l_appno  ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarn_ints (  appno,
                                                    checkdigit,
                                                    title,
                                                    forenames,
                                                    surname,
                                                    birthdate,
                                                    sex,
                                                    ad_batch_id,
                                                    ad_interface_id,
                                                    ad_api_id,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   l_appno,
                                                    l_checkdigit,
                                                    c_ivgstarn_rec.title,
                                                    c_ivgstarn_rec.forenames,
                                                    c_ivgstarn_rec.surname,
                                                    c_ivgstarn_rec.birthdate,
                                                    c_ivgstarn_rec.sex,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVGSTARN', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVGSTARN', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVGSTARN') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVGSTARN_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivgstarn_2006  ;

  PROCEDURE load_ivgstarn_2007 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :  11-Jul-06
     Purpose         :  loads each record in the hercules view ivgstarn into the interface table
                        igs_uc_istarn_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivgstarn ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  appno
            ,personalid
            ,timestamp
            ,UPPER(RTRIM(title)) title
            ,RTRIM(forenames) forenames
            ,DECODE(RTRIM(surname),NULL, RPAD('*',LENGTH(surname),'*'), RTRIM(surname)) surname
            ,birthdate
            ,sex
      FROM  igs_uc_ivgstarn_2007_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivgstarn_2007_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivgstarn_2007_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarn_ints.appno%TYPE;
      l_checkdigit igs_uc_istarn_ints.checkdigit%TYPE;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVGSTARN ON ' ) ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVGSTARN',  p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivgstarn_rec IN c_ivgstarn(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivgstarn_rec.appno,'IVGSTARN','APPNO','NUMBER') THEN

                  -- Determine actual appno and checkdigit
                  get_appno(c_ivgstarn_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N / I
                  UPDATE igs_uc_istarn_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND appno = l_appno  ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarn_ints (  appno,
                                                    checkdigit,
                                                    personalid,
                                                    title,
                                                    forenames,
                                                    surname,
                                                    birthdate,
                                                    sex,
                                                    ad_batch_id,
                                                    ad_interface_id,
                                                    ad_api_id,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   l_appno,
                                                    l_checkdigit,
                                                    c_ivgstarn_rec.personalid,
                                                    c_ivgstarn_rec.title,
                                                    c_ivgstarn_rec.forenames,
                                                    c_ivgstarn_rec.surname,
                                                    c_ivgstarn_rec.birthdate,
                                                    c_ivgstarn_rec.sex,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVGSTARN', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVGSTARN', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVGSTARN') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVGSTARN_2007');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivgstarn_2007  ;


  PROCEDURE load_ivnstarn_2006 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :  16-Aug-05
     Purpose         :  loads each record in the hercules view ivnstarn into the interface table
                        igs_uc_istarn_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivnstarn ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  appno
            ,timestamp
            ,UPPER(RTRIM(title)) title
            ,RTRIM(forenames) forenames
            ,DECODE(RTRIM(surname),NULL, RPAD('*',LENGTH(surname),'*'), RTRIM(surname)) surname
            ,birthdate
            ,sex
      FROM  igs_uc_ivnstarn_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivnstarn_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivnstarn_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarn_ints.appno%TYPE;
      l_checkdigit igs_uc_istarn_ints.checkdigit%TYPE;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVNSTARN ON ' ) ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVNSTARN',  p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivnstarn_rec IN c_ivnstarn(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivnstarn_rec.appno,'IVNSTARN','APPNO','NUMBER') THEN

                  -- Determine actual appno and checkdigit
                  get_appno(c_ivnstarn_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N / I
                  UPDATE igs_uc_istarn_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND appno = l_appno  ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarn_ints (  appno,
                                                    checkdigit,
                                                    title,
                                                    forenames,
                                                    surname,
                                                    birthdate,
                                                    sex,
                                                    ad_batch_id,
                                                    ad_interface_id,
                                                    ad_api_id,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   l_appno,
                                                    l_checkdigit,
                                                    c_ivnstarn_rec.title,
                                                    c_ivnstarn_rec.forenames,
                                                    c_ivnstarn_rec.surname,
                                                    c_ivnstarn_rec.birthdate,
                                                    c_ivnstarn_rec.sex,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVNSTARN', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVNSTARN', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVNSTARN') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVNSTARN_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivnstarn_2006  ;

  PROCEDURE load_ivnstarn_2007 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :  11-Jul-06
     Purpose         :  loads each record in the hercules view ivnstarn into the interface table
                        igs_uc_istarn_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivnstarn ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  appno
            ,personalid
            ,timestamp
            ,UPPER(RTRIM(title)) title
            ,RTRIM(forenames) forenames
            ,DECODE(RTRIM(surname),NULL, RPAD('*',LENGTH(surname),'*'), RTRIM(surname)) surname
            ,birthdate
            ,sex
      FROM  igs_uc_ivnstarn_2007_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivnstarn_2007_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivnstarn_2007_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarn_ints.appno%TYPE;
      l_checkdigit igs_uc_istarn_ints.checkdigit%TYPE;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVNSTARN ON ' ) ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVNSTARN',  p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivnstarn_rec IN c_ivnstarn(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivnstarn_rec.appno,'IVNSTARN','APPNO','NUMBER') THEN

                  -- Determine actual appno and checkdigit
                  get_appno(c_ivnstarn_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N / I
                  UPDATE igs_uc_istarn_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND appno = l_appno  ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarn_ints (  appno,
                                                    checkdigit,
                                                    personalid,
                                                    title,
                                                    forenames,
                                                    surname,
                                                    birthdate,
                                                    sex,
                                                    ad_batch_id,
                                                    ad_interface_id,
                                                    ad_api_id,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   l_appno,
                                                    l_checkdigit,
                                                    c_ivnstarn_rec.personalid,
                                                    c_ivnstarn_rec.title,
                                                    c_ivnstarn_rec.forenames,
                                                    c_ivnstarn_rec.surname,
                                                    c_ivnstarn_rec.birthdate,
                                                    c_ivnstarn_rec.sex,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVNSTARN', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVNSTARN', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVNSTARN') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVNSTARN_2007');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivnstarn_2007  ;


  PROCEDURE load_ivstarpqr_2003  IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :     loads each record in the hercules view ivstarpqr into the interface table
                           igs_uc_istrpqr_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     smaddali  4-sep-03   Modified logic to base loading on ivqualification.timestamp and
                          to obsolete New records in Interface table, for bug#3122898
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivqual ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
      FROM igs_uc_ivqualification_2003_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivstarpqr (cp_appno igs_uc_ivstarpqr_2003_v.appno%TYPE )  IS
      SELECT  appno
        ,timestamp
        ,subjectid
        ,RTRIM(eblresult) eblresult
        ,RTRIM(eblamended) eblamended
        ,RTRIM(claimedresult) claimedresult
      FROM  igs_uc_ivstarpqr_2003_v
      WHERE appno = cp_appno ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_count NUMBER ;

      l_appno_qual      igs_uc_ivqualification_2003_v.appno%TYPE;
      l_checkdigit_qual NUMBER;
      l_appno           igs_uc_istrpqr_ints.appno%TYPE;
      l_checkdigit      NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start( 'IVSTARPQR ON ') ;

      -- smaddali modified logic to load ivstarpqr records based on ivqualification timestamp
      -- instead of ivstarpqr timestamp , for bug#3122898
      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVQUALIFICATION', p_old_timestamp) ;

       -- for each record in the IVQUALIFICATION hercules view whose timestamp > old timestamp of ivqualification
       -- load the StarPQR records belonging to this applicant irrespective of the ivstarpqr timestamp
       FOR c_ivqual_rec IN c_ivqual(p_old_timestamp) LOOP

             IF  is_valid(c_ivqual_rec.appno,'IVQUALIFICATION','APPNO','NUMBER') THEN

                 -- Determine actual appno
                 get_appno(c_ivqual_rec.appno, NULL, l_appno_qual, l_checkdigit_qual);

                  -- smaddali added code to obsolete existing records in starpqr interface table with status N for this applicant, for bug#3122898
                  -- Obsolete all records in interface table for this applicant with status N
                  UPDATE igs_uc_istrpqr_ints SET record_status = 'O' , error_code = NULL
                  WHERE record_status = 'N'  AND appno = l_appno_qual ;

                  -- set all records in interface table for this applicant with status L to processed status
                  UPDATE igs_uc_istrpqr_ints SET record_status = 'D' , error_code = NULL
                  WHERE record_status = 'L'  AND appno = l_appno_qual ;

                   -- create interface records for each record in the hercules view whose timestamp > old timestamp
                   FOR c_ivstarpqr_rec IN c_ivstarpqr(c_ivqual_rec.appno) LOOP
                          -- set x_sync_read to true if the loop is entered even once
                          g_sync_reqd := TRUE;

                          IF  is_valid(c_ivstarpqr_rec.appno,'IVSTARPQR','APPNO','NUMBER') THEN

                              -- Determine actual appno
                              get_appno(c_ivstarpqr_rec.appno, NULL, l_appno, l_checkdigit);

                              -- copy hercules record into interface table with record status N
                              INSERT INTO igs_uc_istrpqr_ints ( appno,
                                                                subjectid,
                                                                eblresult,
                                                                eblamended,
                                                                claimedresult,
                                                                yearofexam,
                                                                sitting,
                                                                examboard,
                                                                eblsubject,
                                                                grade,
                                                                grade1,
                                                                grade2,
                                                                lendingboard,
                                                                matchind,
                                                                marvin_type,
                                                                record_status,
                                                                error_code
                                                                 )
                                                     VALUES (   l_appno,
                                                                c_ivstarpqr_rec.subjectid,
                                                                c_ivstarpqr_rec.eblresult,
                                                                c_ivstarpqr_rec.eblamended,
                                                                c_ivstarpqr_rec.claimedresult,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                'N',
                                                                NULL
                                                                 ) ;
                                -- increment count of records
                                l_count := l_count + 1;

                          END IF;

                   END LOOP ; -- ivstarpqr loop

             END IF;

      END LOOP; -- ivqualifcation applicants loop

      IF g_sync_reqd THEN
              -- log message that this view has been loaded
               log_complete( 'IVSTARPQR', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVSTARPQR') ;
      END IF;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVSTARPQR_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_ivstarpqr_2003   ;


  PROCEDURE load_ivstarpqr_2006  IS
    /******************************************************************
     Created By      :  anwest
     Date Created By :  25-MAY-2006
     Purpose         :  Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
                        Loads each record in the hercules view
                        ivstarpqr into the interface table
                        igs_uc_istrpqr_ints with record status N

     Known limitations,enhancements,remarks:
     Change History
     Who       When         What

    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivqual ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno
      FROM igs_uc_ivqualification_2003_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivstarpqr (cp_appno igs_uc_ivstarpqr_2003_v.appno%TYPE )  IS
      SELECT  appno
        ,timestamp
        ,subjectid
        ,RTRIM(eblresult) eblresult
      FROM  igs_uc_ivstarpqr_2003_v
      WHERE appno = cp_appno ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_count NUMBER ;

      l_appno_qual      igs_uc_ivqualification_2003_v.appno%TYPE;
      l_checkdigit_qual NUMBER;
      l_appno           igs_uc_istrpqr_ints.appno%TYPE;
      l_checkdigit      NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start( 'IVSTARPQR ON ') ;

      -- smaddali modified logic to load ivstarpqr records based on ivqualification timestamp
      -- instead of ivstarpqr timestamp , for bug#3122898
      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVQUALIFICATION', p_old_timestamp) ;

       -- for each record in the IVQUALIFICATION hercules view whose timestamp > old timestamp of ivqualification
       -- load the StarPQR records belonging to this applicant irrespective of the ivstarpqr timestamp
       FOR c_ivqual_rec IN c_ivqual(p_old_timestamp) LOOP

             IF  is_valid(c_ivqual_rec.appno,'IVQUALIFICATION','APPNO','NUMBER') THEN

                 -- Determine actual appno
                 get_appno(c_ivqual_rec.appno, NULL, l_appno_qual, l_checkdigit_qual);

                  -- smaddali added code to obsolete existing records in starpqr interface table with status N for this applicant, for bug#3122898
                  -- Obsolete all records in interface table for this applicant with status N
                  UPDATE igs_uc_istrpqr_ints SET record_status = 'O' , error_code = NULL
                  WHERE record_status = 'N'  AND appno = l_appno_qual ;

                  -- set all records in interface table for this applicant with status L to processed status
                  UPDATE igs_uc_istrpqr_ints SET record_status = 'D' , error_code = NULL
                  WHERE record_status = 'L'  AND appno = l_appno_qual ;

                   -- create interface records for each record in the hercules view whose timestamp > old timestamp
                   FOR c_ivstarpqr_rec IN c_ivstarpqr(c_ivqual_rec.appno) LOOP
                          -- set x_sync_read to true if the loop is entered even once
                          g_sync_reqd := TRUE;

                          IF  is_valid(c_ivstarpqr_rec.appno,'IVSTARPQR','APPNO','NUMBER') THEN

                              -- Determine actual appno
                              get_appno(c_ivstarpqr_rec.appno, NULL, l_appno, l_checkdigit);

                              -- copy hercules record into interface table with record status N
                              INSERT INTO igs_uc_istrpqr_ints ( appno,
                                                                subjectid,
                                                                eblresult,
                                                                eblamended,
                                                                claimedresult,
                                                                yearofexam,
                                                                sitting,
                                                                examboard,
                                                                eblsubject,
                                                                grade,
                                                                grade1,
                                                                grade2,
                                                                lendingboard,
                                                                matchind,
                                                                marvin_type,
                                                                record_status,
                                                                error_code
                                                                 )
                                                     VALUES (   l_appno,
                                                                c_ivstarpqr_rec.subjectid,
                                                                c_ivstarpqr_rec.eblresult,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                'N',
                                                                NULL
                                                                 ) ;
                                -- increment count of records
                                l_count := l_count + 1;

                          END IF;

                   END LOOP ; -- ivstarpqr loop

             END IF;

      END LOOP; -- ivqualifcation applicants loop

      IF g_sync_reqd THEN
              -- log message that this view has been loaded
               log_complete( 'IVSTARPQR', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVSTARPQR') ;
      END IF;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVSTARPQR_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_ivstarpqr_2006;


  PROCEDURE load_ivstarw_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :     loads each record in the hercules view ivstarw into the interface table
                           igs_uc_istarw_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivstarw ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  appno
       , timestamp
       , RTRIM(miscoded) miscoded
       , RTRIM(cancelled) cancelled
       , canceldate
       , RTRIM(remark) remark
       , RTRIM(jointadmission) jointadmission
      FROM  igs_uc_ivstarw_2003_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivstarw_2003_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivstarw_2003_v.timestamp%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVSTARW ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVSTARW', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivstarw_rec IN c_ivstarw(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- Obsolete matching records in interface table with status N
              UPDATE igs_uc_istarw_ints SET record_status = 'O'
              WHERE record_status = 'N' AND appno = c_ivstarw_rec.appno ;

              -- copy hercules record into interface table with record status N
              INSERT INTO igs_uc_istarw_ints (   appno,
                                                 miscoded,
                                                 cancelled,
                                                 jointadmission,
                                                 choice1lost,
                                                 choice2lost,
                                                 choice3lost,
                                                 choice4lost,
                                                 choice5lost,
                                                 choice6lost,
                                                 choice7lost,
                                                 canceldate,
                                                 remark,
                                                record_status,
                                                error_code
                                                 )
                                     VALUES (    c_ivstarw_rec.appno,
                                                 c_ivstarw_rec.miscoded,
                                                 c_ivstarw_rec.cancelled,
                                                 c_ivstarw_rec.jointadmission,
                                                 'N',
                                                 'N',
                                                 'N',
                                                 'N',
                                                 'N',
                                                 'N',
                                                 'N',
                                                 c_ivstarw_rec.canceldate,
                                                 c_ivstarw_rec.remark,
                                                'N',
                                                NULL
                                                 ) ;
        -- increment count of records
        l_count := l_count + 1;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVSTARW',  l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVSTARW', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVSTARW') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVSTARW_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivstarw_2003  ;

  PROCEDURE load_ivstarx_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :     loads each record in the hercules view ivstarx into the interface table
                           igs_uc_istarx_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivstarx ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  appno
           ,timestamp
           ,ethnic
           ,pocceduchangedate
           ,socialclass
           ,RTRIM(pocc) pocc
           ,RTRIM(pocctext) pocctext
           ,RTRIM(socioeconomic) socioeconomic
           ,RTRIM(occbackground) occbackground
      FROM  igs_uc_ivstarx_2003_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivstarx_2003_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivstarx_2003_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarx_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVSTARX ON ' ) ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVSTARX',  p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivstarx_rec IN c_ivstarx(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

             --Validate varchar to number conversion
             IF  is_valid(c_ivstarx_rec.appno,'IVSTARX','APPNO','NUMBER') AND
                 is_valid(c_ivstarx_rec.ethnic,'IVSTARX','Ethnic','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivstarx_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istarx_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND appno = l_appno ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarx_ints (  appno,
                                                    ethnic,
                                                    pocceduchangedate,
                                                    socialclass,
                                                    pocc,
                                                    pocctext,
                                                    socioeconomic,
                                                    occbackground,
                                                    religion,
                                                    dependants,
                                                    married,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   l_appno,
                                                    c_ivstarx_rec.ethnic,
                                                    c_ivstarx_rec.pocceduchangedate,
                                                    c_ivstarx_rec.socialclass,
                                                    c_ivstarx_rec.pocc,
                                                    c_ivstarx_rec.pocctext,
                                                    c_ivstarx_rec.socioeconomic,
                                                    c_ivstarx_rec.occbackground,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVSTARX',  l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVSTARX' , l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVSTARX') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVSTARX_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END    load_ivstarx_2003 ;


  PROCEDURE load_ivgstarx_2006 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :  16-Aug-05
     Purpose         :  loads each record in the hercules view ivgstarx into the interface table
                        igs_uc_istarx_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivgstarx ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  appno
           ,timestamp
           ,ethnic
      FROM  igs_uc_ivgstarx_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivgstarx_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivgstarx_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarx_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVGSTARX ON ' ) ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVGSTARX',  p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivgstarx_rec IN c_ivgstarx(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

             --Validate varchar to number conversion
             IF  is_valid(c_ivgstarx_rec.appno,'IVGSTARX','APPNO','NUMBER') AND
                 is_valid(c_ivgstarx_rec.ethnic,'IVGSTARX','Ethnic','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivgstarx_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istarx_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND appno = l_appno ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarx_ints (  appno,
                                                    ethnic,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   l_appno,
                                                    c_ivgstarx_rec.ethnic,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVGSTARX',  l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVGSTARX' , l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVGSTARX') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVGSTARX_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END    load_ivgstarx_2006 ;


  PROCEDURE load_ivnstarx_2006 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :  16-Aug-05
     Purpose         :  loads each record in the hercules view ivnstarx into the interface table
                        igs_uc_istarx_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivnstarx ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  appno
           ,timestamp
           ,ethnic
           ,numberdependants
           ,RTRIM(maritalstatus) maritalstatus
      FROM  igs_uc_ivnstarx_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivnstarx_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivnstarx_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarx_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVNSTARX ON ' ) ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVNSTARX',  p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivnstarx_rec IN c_ivnstarx(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

             --Validate varchar to number conversion
             IF  is_valid(c_ivnstarx_rec.appno,'IVNSTARX','APPNO','NUMBER') AND
                 is_valid(c_ivnstarx_rec.ethnic,'IVNSTARX','Ethnic','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivnstarx_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istarx_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND appno = l_appno ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarx_ints (  appno,
                                                    ethnic,
                                                    dependants,
                                                    married,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   l_appno,
                                                    c_ivnstarx_rec.ethnic,
                                                    c_ivnstarx_rec.numberdependants,
                                                    c_ivnstarx_rec.maritalstatus,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVNSTARX',  l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVNSTARX' , l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVNSTARX') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVNSTARX_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END    load_ivnstarx_2006 ;


  PROCEDURE load_ivstarz1_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :    loads each record in the hercules view ivstarz1 into the interface table
                           igs_uc_istarz1_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     jbaber    15-Sep-05    Force 2-digit entry year for bug 4589994
     anwest    02-AUG-06    Bug #5440216 URGENT - UCAS CLEARING 2006 - PART 2 - CLEARING CHOICE NUMBER NULL
    ***************************************************************** */


     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivstarz1 ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  appno
        ,timestamp
        ,datecefsent
        ,cefno
        ,RTRIM(centralclearing) centralclearing
        ,DECODE(RTRIM(inst),NULL, RPAD('*',LENGTH(inst),'*'), RTRIM(inst)) inst
        ,DECODE(RTRIM(course),NULL, RPAD('*',LENGTH(course),'*'), RTRIM(course)) course
        ,NVL(DECODE(RTRIM(campus),NULL, RPAD('*',LENGTH(campus),'*'), RTRIM(campus)),'*') campus -- 02-AUG-2006 anwest Bug #5440216 URGENT - UCAS CLEARING 2006 - PART 2 - CLEARING CHOICE NUMBER NULL
        ,faculty
        ,SUBSTR(LPAD(entryyear,4,0),3,2) entryyear
        ,entrymonth
        ,RTRIM(entrypoint) entrypoint
        ,RTRIM(result) result
      FROM  igs_uc_ivstarz1_2003_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivstarz1_2003_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivstarz1_2003_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarz1_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVSTARZ1 ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVSTARZ1', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivstarz1_rec IN c_ivstarz1(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivstarz1_rec.appno,'IVSTARZ1','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivstarz1_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istarz1_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND appno = l_appno ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarz1_ints ( appno,
                                                    datecefsent,
                                                    cefno,
                                                    centralclearing,
                                                    inst,
                                                    course,
                                                    campus,
                                                    faculty,
                                                    entryyear,
                                                    entrymonth,
                                                    entrypoint,
                                                    result,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   l_appno,
                                                    c_ivstarz1_rec.datecefsent,
                                                    c_ivstarz1_rec.cefno,
                                                    c_ivstarz1_rec.centralclearing,
                                                    c_ivstarz1_rec.inst,
                                                    c_ivstarz1_rec.course,
                                                    c_ivstarz1_rec.campus,
                                                    c_ivstarz1_rec.faculty,
                                                    c_ivstarz1_rec.entryyear,
                                                    c_ivstarz1_rec.entrymonth,
                                                    c_ivstarz1_rec.entrypoint,
                                                    c_ivstarz1_rec.result,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVSTARZ1', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVSTARZ1', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVSTARZ1') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVSTARZ1_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END    load_ivstarz1_2003 ;


  PROCEDURE load_ivnstarz1_2006 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :  16-Aug-05
     Purpose         :  loads each record in the hercules view ivnstarz1 into the interface table
                        igs_uc_istarz1_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     jbaber    29-Sep-05    Force 2-digit entry year for bug 4638126
    ***************************************************************** */


     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivnstarz1 ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  appno
        ,timestamp
        ,cefno
        ,DECODE(RTRIM(inst),NULL, RPAD('*',LENGTH(inst),'*'), RTRIM(inst)) inst
        ,DECODE(RTRIM(course),NULL, RPAD('*',LENGTH(course),'*'), RTRIM(course)) course
        ,NVL(DECODE(RTRIM(campus),NULL, RPAD('*',LENGTH(campus),'*'), RTRIM(campus)),'*') campus -- 02-AUG-2006 anwest Bug #5440216 URGENT - UCAS CLEARING 2006 - PART 2 - CLEARING CHOICE NUMBER NULL
        ,SUBSTR(LPAD(entryyear,4,0),3,2) entryyear
        ,entrymonth
        ,RTRIM(result) result
      FROM  igs_uc_ivnstarz1_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivnstarz1_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivnstarz1_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarz1_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVNSTARZ1 ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVNSTARZ1', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivnstarz1_rec IN c_ivnstarz1(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivnstarz1_rec.appno,'IVNSTARZ1','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivnstarz1_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istarz1_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND appno = l_appno ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarz1_ints ( appno,
                                                    cefno,
                                                    inst,
                                                    course,
                                                    campus,
                                                    entryyear,
                                                    entrymonth,
                                                    result,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   l_appno,
                                                    c_ivnstarz1_rec.cefno,
                                                    c_ivnstarz1_rec.inst,
                                                    c_ivnstarz1_rec.course,
                                                    c_ivnstarz1_rec.campus,
                                                    c_ivnstarz1_rec.entryyear,
                                                    c_ivnstarz1_rec.entrymonth,
                                                    c_ivnstarz1_rec.result,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVNSTARZ1', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVNSTARZ1', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVNSTARZ1') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVNSTARZ1_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END    load_ivnstarz1_2006 ;


  PROCEDURE load_ivstarz2_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :    loads each record in the hercules view ivstarz2 into the interface table
                           igs_uc_istarz2_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

    -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivstarz2 ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  appno
        , roundno
        , timestamp
        , DECODE(RTRIM(inst),NULL, RPAD('*',LENGTH(inst),'*'), RTRIM(inst)) inst
        , DECODE(RTRIM(course),NULL, RPAD('*',LENGTH(course),'*'), RTRIM(course)) course
        , DECODE(RTRIM(campus),NULL, RPAD('*',LENGTH(campus),'*'), RTRIM(campus)) campus
        , RTRIM(faculty) faculty
        , RTRIM(roundtype) roundtype
        , RTRIM(result) result
      FROM  igs_uc_ivstarz2_2003_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivstarz2_2003_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivstarz2_2003_v.timestamp%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
        log_start('IVSTARZ2 ON ' ) ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVSTARZ2', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivstarz2_rec IN c_ivstarz2(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- Obsolete matching records in interface table with status N
             UPDATE igs_uc_istarz2_ints SET record_status = 'O'
             WHERE record_status = 'N' AND appno = c_ivstarz2_rec.appno
             AND inst = c_ivstarz2_rec.inst AND course = c_ivstarz2_rec.course
             AND campus = c_ivstarz2_rec.campus;

              -- copy hercules record into interface table with record status N
              INSERT INTO igs_uc_istarz2_ints ( appno,
                                                roundno,
                                                inst,
                                                course,
                                                campus,
                                                faculty,
                                                roundtype,
                                                result,
                                                record_status,
                                                error_code
                                                 )
                                     VALUES (   c_ivstarz2_rec.appno,
                                                c_ivstarz2_rec.roundno,
                                                c_ivstarz2_rec.inst,
                                                c_ivstarz2_rec.course,
                                                c_ivstarz2_rec.campus,
                                                c_ivstarz2_rec.faculty,
                                                c_ivstarz2_rec.roundtype,
                                                c_ivstarz2_rec.result,
                                                'N',
                                                NULL
                                                 ) ;
        -- increment count of records
        l_count := l_count + 1;

       END LOOP ;

       IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVSTARZ2', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVSTARZ2', l_count ) ;
       ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVSTARZ2') ;
       END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVSTARZ2_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivstarz2_2003  ;


  PROCEDURE load_ivstatement_2003 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :    loads each record in the hercules view ivstatement into the interface table
                           igs_uc_istmnt_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */
        -- Get all the applicants whose personal statement is null
        CURSOR c_stmt_appno IS
        SELECT a.appno
        FROM   igs_uc_ivstatement_2003_v a
        WHERE  NOT EXISTS ( SELECT b.app_no
                            FROM IGS_UC_APPLICANTS b
                            WHERE b.app_no = a.appno
                            AND b.personal_statement IS NOT NULL );

        -- Get statement for passed appno
        CURSOR c_stmt (p_appno igs_uc_ivstatement_2003_v.appno%TYPE ) IS
        SELECT appno,statement
        FROM igs_uc_ivstatement_2003_v
        WHERE appno = p_appno ;
        c_stmt_rec  c_stmt%ROWTYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
        log_start('IVSTATEMENT ON ') ;


       -- create interface records for each record in the hercules view which hasn't been imported earlier
       FOR c_stmt_appno_rec IN c_stmt_appno LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- Obsolete matching records in interface table with status N
              UPDATE igs_uc_istmnt_ints  SET record_status = 'O'
              WHERE record_status = 'N' AND appno =  c_stmt_appno_rec.appno;

              -- copy hercules record into interface table with record status N
              c_stmt_rec   := NULL ;
              OPEN c_stmt( c_stmt_appno_rec.appno);
              FETCH c_stmt INTO c_stmt_rec ;
              CLOSE c_stmt ;
              INSERT INTO igs_uc_istmnt_ints (  appno,
                                                statement,
                                                record_status,
                                                error_code
                                                 )
                                     VALUES (   c_stmt_rec.appno,
                                                c_stmt_rec.statement,
                                                'N',
                                                NULL
                                                 ) ;
        -- increment count of records
        l_count := l_count + 1;

       END LOOP ;

      IF g_sync_reqd THEN
              -- log message that this view has been loaded
               log_complete('IVSTATEMENT', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVSTATEMENT') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVSTATEMENT_2003');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivstatement_2003  ;

  PROCEDURE load_ivstatement_2004 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   18-Aug-03
     Purpose         :    loads each record in the hercules view ivstatement into the interface table
                           igs_uc_istmnt_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     smaddali  18-aug-03   Modified to load based on the timestamp field in hercules vew for bug#3098810
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_stmt (p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno,statement
      FROM igs_uc_ivstatement_2004_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivstatement_2004_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivstatement_2004_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istmnt_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
        log_start('IVSTATEMENT ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVSTATEMENT',p_old_timestamp) ;

       -- create interface records for each record in the hercules view which hasn't been imported earlier
       FOR c_stmt_rec IN c_stmt(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_stmt_rec.appno,'IVSTATEMENT','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_stmt_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istmnt_ints  SET record_status = 'O'
                  WHERE record_status = 'N' AND appno =  l_appno;


                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istmnt_ints (  appno,
                                                    statement,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   l_appno,
                                                    c_stmt_rec.statement,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVSTATEMENT', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVSTATEMENT', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVSTATEMENT') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVSTATEMENT_2004');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivstatement_2004  ;


  PROCEDURE load_ivgstatement_2006 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :  16-Aug-05
     Purpose         :  loads each record in the hercules view ivgstatement into the interface table
                        igs_uc_istmnt_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_stmt (p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno,statement
      FROM igs_uc_ivgstatement_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivgstatement_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivgstatement_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istmnt_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
        log_start('IVGSTATEMENT ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVGSTATEMENT',p_old_timestamp) ;

       -- create interface records for each record in the hercules view which hasn't been imported earlier
       FOR c_stmt_rec IN c_stmt(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_stmt_rec.appno,'IVGSTATEMENT','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_stmt_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istmnt_ints  SET record_status = 'O'
                  WHERE record_status = 'N' AND appno =  l_appno;


                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istmnt_ints (  appno,
                                                    statement,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   l_appno,
                                                    c_stmt_rec.statement,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVGSTATEMENT', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVGSTATEMENT', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVGSTATEMENT') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVGSTATEMENT_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivgstatement_2006  ;


  PROCEDURE load_ivnstatement_2006 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :  16-Aug-05
     Purpose         :  loads each record in the hercules view ivnstatement into the interface table
                        igs_uc_istmnt_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_stmt (p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT appno,statement
      FROM igs_uc_ivnstatement_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivnstatement_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivnstatement_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istmnt_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
        log_start('IVNSTATEMENT ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVNSTATEMENT',p_old_timestamp) ;

       -- create interface records for each record in the hercules view which hasn't been imported earlier
       FOR c_stmt_rec IN c_stmt(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_stmt_rec.appno,'IVNSTATEMENT','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_stmt_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istmnt_ints  SET record_status = 'O'
                  WHERE record_status = 'N' AND appno =  l_appno;


                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istmnt_ints (  appno,
                                                    statement,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (   l_appno,
                                                    c_stmt_rec.statement,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVNSTATEMENT', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVNSTATEMENT', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVNSTATEMENT') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVNSTATEMENT_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivnstatement_2006  ;


  PROCEDURE load_uvinstitution_2004 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view uvinstitution into the interface table
                           igs_uc_uinst_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_uinst ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  timestamp
         ,DECODE(RTRIM(updater),NULL, RPAD('*',LENGTH(updater),'*'), RTRIM(updater)) updater
         ,DECODE(RTRIM(insttype),NULL, RPAD('*',LENGTH(insttype),'*'), RTRIM(insttype)) insttype
         ,RTRIM(instshortname) instshortname
         ,RTRIM(instname) instname
         ,RTRIM(instfullname) instfullname
         ,RTRIM(switchboardtelno) switchboardtelno
         ,RTRIM(decisioncards) decisioncards
         ,RTRIM(recordcards) recordcards
         ,RTRIM(labels) labels
         ,RTRIM(weeklymovlistseq) weeklymovlistseq
         ,RTRIM(weeklymovpaging) weeklymovpaging
         ,RTRIM(formseq) formseq
         ,RTRIM(eblrequired) eblrequired
         ,RTRIM(eblmedia1or2) eblmedia1or2
         ,RTRIM(eblmedia3) eblmedia3
         ,RTRIM(ebl1or2merged) ebl1or2merged
         ,RTRIM(ebl1or2boardgroup) ebl1or2boardgroup
         ,RTRIM(ebl3boardgroup) ebl3boardgroup
         ,RTRIM(eblncapp) eblncapp
         ,RTRIM(eblmajorkey1) eblmajorkey1
         ,RTRIM(eblmajorkey2) eblmajorkey2
         ,RTRIM(eblmajorkey3) eblmajorkey3
         ,RTRIM(eblminorkey1) eblminorkey1
         ,RTRIM(eblminorkey2) eblminorkey2
         ,RTRIM(eblminorkey3) eblminorkey3
         ,RTRIM(eblfinalkey) eblfinalkey
         ,RTRIM(odl1) odl1
         ,RTRIM(odl1a) odl1a
         ,RTRIM(odl2) odl2
         ,RTRIM(odl3) odl3
         ,RTRIM(odlsummer) odlsummer
         ,RTRIM(odlrouteb) odlrouteb
         ,RTRIM(monthlyseq) monthlyseq
         ,RTRIM(monthlypaper) monthlypaper
         ,RTRIM(monthlypage) monthlypage
         ,RTRIM(monthlytype) monthlytype
         ,RTRIM(junelistseq) junelistseq
         ,RTRIM(junelabels) junelabels
         ,RTRIM(junenumlabels) junenumlabels
         ,RTRIM(courseanalysis) courseanalysis
         ,RTRIM(campusused) campusused
         ,RTRIM(d3docsrequired) d3docsrequired
         ,RTRIM(clearingacceptcopyform) clearingacceptcopyform
         ,RTRIM(onlinemessage) onlinemessage
         ,RTRIM(ethniclistseq) ethniclistseq
         ,NVL(RTRIM(starx),'N') starx
      FROM igs_uc_u_uvinstitution_2004
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_u_uvinstitution_2004  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_u_uvinstitution_2004.timestamp%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('UVINSTITUTION ON ' ) ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('UVINSTITUTION',p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_uinst_rec IN c_uinst(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- Obsolete all records in interface table with status N
              UPDATE igs_uc_uinst_ints SET record_status = 'O' WHERE record_status = 'N' ;

              -- copy hercules record into interface table with record status N
              INSERT INTO igs_uc_uinst_ints (   updater,
                                                insttype,
                                                instshortname,
                                                instname,
                                                instfullname,
                                                switchboardtelno,
                                                decisioncards,
                                                recordcards,
                                                labels,
                                                weeklymovlistseq,
                                                weeklymovpaging,
                                                formseq,
                                                eblrequired,
                                                eblmedia1or2,
                                                eblmedia3,
                                                ebl1or2merged,
                                                ebl1or2boardgroup,
                                                ebl3boardgroup,
                                                eblncapp,
                                                eblmajorkey1,
                                                eblmajorkey2,
                                                eblmajorkey3,
                                                eblminorkey1,
                                                eblminorkey2,
                                                eblminorkey3,
                                                eblfinalkey,
                                                odl1,
                                                odl1a,
                                                odl2,
                                                odl3,
                                                odlsummer,
                                                odlrouteb,
                                                monthlyseq,
                                                monthlypaper,
                                                monthlypage,
                                                monthlytype,
                                                junelistseq,
                                                junelabels,
                                                junenumlabels,
                                                courseanalysis,
                                                campusused,
                                                d3docsrequired,
                                                clearingacceptcopyform,
                                                onlinemessage,
                                                ethniclistseq,
                                                starx,
                                                record_status,
                                                error_code
                                                 )
                                     VALUES (   c_uinst_rec.updater,
                                                c_uinst_rec.insttype,
                                                c_uinst_rec.instshortname,
                                                c_uinst_rec.instname,
                                                c_uinst_rec.instfullname,
                                                c_uinst_rec.switchboardtelno,
                                                c_uinst_rec.decisioncards,
                                                c_uinst_rec.recordcards,
                                                c_uinst_rec.labels,
                                                c_uinst_rec.weeklymovlistseq,
                                                c_uinst_rec.weeklymovpaging,
                                                c_uinst_rec.formseq,
                                                c_uinst_rec.eblrequired,
                                                c_uinst_rec.eblmedia1or2,
                                                c_uinst_rec.eblmedia3,
                                                c_uinst_rec.ebl1or2merged,
                                                c_uinst_rec.ebl1or2boardgroup,
                                                c_uinst_rec.ebl3boardgroup,
                                                c_uinst_rec.eblncapp,
                                                c_uinst_rec.eblmajorkey1,
                                                c_uinst_rec.eblmajorkey2,
                                                c_uinst_rec.eblmajorkey3,
                                                c_uinst_rec.eblminorkey1,
                                                c_uinst_rec.eblminorkey2,
                                                c_uinst_rec.eblminorkey3,
                                                c_uinst_rec.eblfinalkey,
                                                c_uinst_rec.odl1,
                                                c_uinst_rec.odl1a,
                                                c_uinst_rec.odl2,
                                                c_uinst_rec.odl3,
                                                c_uinst_rec.odlsummer,
                                                c_uinst_rec.odlrouteb,
                                                c_uinst_rec.monthlyseq,
                                                c_uinst_rec.monthlypaper,
                                                c_uinst_rec.monthlypage,
                                                c_uinst_rec.monthlytype,
                                                c_uinst_rec.junelistseq,
                                                c_uinst_rec.junelabels,
                                                c_uinst_rec.junenumlabels,
                                                c_uinst_rec.courseanalysis,
                                                c_uinst_rec.campusused,
                                                c_uinst_rec.d3docsrequired,
                                                c_uinst_rec.clearingacceptcopyform,
                                                c_uinst_rec.onlinemessage,
                                                c_uinst_rec.ethniclistseq,
                                                c_uinst_rec.starx,
                                                 'N',
                                                 NULL) ;
        -- increment count of records
        l_count := l_count + 1;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('UVINSTITUTION', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('UVINSTITUTION', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('UVINSTITUTION') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_UVINSTITUTION_2004');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_uvinstitution_2004  ;


  PROCEDURE load_ivstarw_2004 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :       loads each record in the hercules view ivstarw into the interface table
                           igs_uc_istarw_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */


     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivstarw ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  appno
       , timestamp
       , RTRIM(miscoded) miscoded
       , RTRIM(cancelled) cancelled
       , canceldate
       , RTRIM(remark) remark
       , RTRIM(jointadmission) jointadmission
       , NVL(choice1lost,'N') choice1lost
        , NVL( choice2lost,'N') choice2lost
        , NVL( choice3lost,'N') choice3lost
        , NVL( choice4lost,'N') choice4lost
        , NVL( choice5lost,'N') choice5lost
        , NVL( choice6lost,'N') choice6lost
        , NVL( choice7lost,'N') choice7lost
      FROM  igs_uc_ivstarw_2004_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivstarw_2004_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivstarw_2004_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarw_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVSTARW ON ' ) ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVSTARW',  p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivstarw_rec IN c_ivstarw(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivstarw_rec.appno,'IVSTARW','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivstarw_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istarw_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND appno =  l_appno ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarw_ints (   appno,
                                                     miscoded,
                                                     cancelled,
                                                     jointadmission,
                                                     choice1lost,
                                                     choice2lost,
                                                     choice3lost,
                                                     choice4lost,
                                                     choice5lost,
                                                     choice6lost,
                                                     choice7lost,
                                                     canceldate,
                                                     remark,
                                                    record_status,
                                                    error_code
                                                     )
                                         VALUES (    l_appno,
                                                     c_ivstarw_rec.miscoded,
                                                     c_ivstarw_rec.cancelled,
                                                     c_ivstarw_rec.jointadmission,
                                                     c_ivstarw_rec.choice1lost,
                                                     c_ivstarw_rec.choice2lost,
                                                     c_ivstarw_rec.choice3lost,
                                                     c_ivstarw_rec.choice4lost,
                                                     c_ivstarw_rec.choice5lost,
                                                     c_ivstarw_rec.choice6lost,
                                                     c_ivstarw_rec.choice7lost,
                                                     c_ivstarw_rec.canceldate,
                                                     c_ivstarw_rec.remark,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVSTARW',  l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVSTARW', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVSTARW') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVSTARW_2004');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivstarw_2004  ;


  PROCEDURE load_ivgstarw_2006 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :  16-Aug-05
     Purpose         :  loads each record in the hercules view ivgstarw into the interface table
                        igs_uc_istarw_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */


     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivgstarw ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  appno
       , timestamp
       , RTRIM(miscoded) miscoded
       , RTRIM(cancelled) cancelled
       , canceldate
      FROM  igs_uc_ivgstarw_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivgstarw_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivgstarw_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarw_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVGSTARW ON ' ) ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVGSTARW',  p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivgstarw_rec IN c_ivgstarw(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivgstarw_rec.appno,'IVGSTARW','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivgstarw_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istarw_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND appno =  l_appno ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarw_ints (   appno,
                                                     miscoded,
                                                     cancelled,
                                                     canceldate,
                                                     record_status,
                                                     error_code
                                                     )
                                         VALUES (    l_appno,
                                                     c_ivgstarw_rec.miscoded,
                                                     c_ivgstarw_rec.cancelled,
                                                     c_ivgstarw_rec.canceldate,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVGSTARW',  l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVGSTARW', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVGSTARW') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVGSTARW_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivgstarw_2006  ;


  PROCEDURE load_ivgstarw_2007 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :  11-Jul-06
     Purpose         :  loads each record in the hercules view ivgstarw into the interface table
                        igs_uc_istarw_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */


     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivgstarw ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  appno
       , timestamp
       , RTRIM(miscoded) miscoded
       , RTRIM(cancelled) cancelled
       , canceldate
       , remark
      FROM  igs_uc_ivgstarw_2007_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivgstarw_2007_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivgstarw_2007_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarw_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVGSTARW ON ' ) ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVGSTARW',  p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivgstarw_rec IN c_ivgstarw(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivgstarw_rec.appno,'IVGSTARW','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivgstarw_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istarw_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND appno =  l_appno ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarw_ints (   appno,
                                                     miscoded,
                                                     cancelled,
                                                     canceldate,
                                                     remark,
                                                     record_status,
                                                     error_code
                                                     )
                                         VALUES (    l_appno,
                                                     c_ivgstarw_rec.miscoded,
                                                     c_ivgstarw_rec.cancelled,
                                                     c_ivgstarw_rec.canceldate,
                                                     c_ivgstarw_rec.remark,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVGSTARW',  l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVGSTARW', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVGSTARW') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVGSTARW_2007');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivgstarw_2007  ;


  PROCEDURE load_ivnstarw_2006 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :  16-Aug-05
     Purpose         :  loads each record in the hercules view ivnstarw into the interface table
                        igs_uc_istarw_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */


     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivnstarw ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  appno
       , timestamp
       , RTRIM(miscoded) miscoded
       , RTRIM(cancelled) cancelled
       , canceldate
      FROM  igs_uc_ivnstarw_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivnstarw_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivnstarw_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarw_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVNSTARW ON ' ) ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVNSTARW',  p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivnstarw_rec IN c_ivnstarw(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivnstarw_rec.appno,'IVNSTARW','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivnstarw_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istarw_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND appno =  l_appno ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarw_ints (   appno,
                                                     miscoded,
                                                     cancelled,
                                                     canceldate,
                                                     record_status,
                                                     error_code
                                                     )
                                         VALUES (    l_appno,
                                                     c_ivnstarw_rec.miscoded,
                                                     c_ivnstarw_rec.cancelled,
                                                     c_ivnstarw_rec.canceldate,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVNSTARW',  l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVNSTARW', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVNSTARW') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVNSTARW_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivnstarw_2006  ;


  PROCEDURE load_ivnstarw_2007 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :  11-Jul-06
     Purpose         :  loads each record in the hercules view ivnstarw into the interface table
                        igs_uc_istarw_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */


     -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivnstarw ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT  appno
       , timestamp
       , RTRIM(miscoded) miscoded
       , RTRIM(cancelled) cancelled
       , canceldate
       , remark
      FROM  igs_uc_ivnstarw_2007_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivnstarw_2007_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivnstarw_2007_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_istarw_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVNSTARW ON ' ) ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVNSTARW',  p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivnstarw_rec IN c_ivnstarw(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivnstarw_rec.appno,'IVNSTARW','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivnstarw_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_istarw_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND appno =  l_appno ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_istarw_ints (   appno,
                                                     miscoded,
                                                     cancelled,
                                                     canceldate,
                                                     remark,
                                                     record_status,
                                                     error_code
                                                     )
                                         VALUES (    l_appno,
                                                     c_ivnstarw_rec.miscoded,
                                                     c_ivnstarw_rec.cancelled,
                                                     c_ivnstarw_rec.canceldate,
                                                     c_ivnstarw_rec.remark,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVNSTARW',  l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVNSTARW', l_count ) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVNSTARW') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVNSTARW_2007');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivnstarw_2007  ;


  PROCEDURE load_ivformquals_2004 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view ivformquals into the interface table
                           igs_uc_ifrmqul_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

    -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivformqual ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT     appno
                 ,timestamp
                 ,qualid
                 ,RTRIM(qualtype) qualtype
                 ,RTRIM(awardbody) awardbody
                 ,RTRIM(title) title
                 ,RTRIM(grade) grade
                 ,qualdate
      FROM  igs_uc_ivformquals_2004_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivformquals_2004_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivformquals_2004_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_ifrmqul_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVFORMQUALS ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVFORMQUALS', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivformqual_rec IN c_ivformqual(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivformqual_rec.appno,'IVFORMQUALS','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivformqual_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_ifrmqul_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND appno = l_appno
                  AND qualid = c_ivformqual_rec.qualid ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_ifrmqul_ints (  appno,
                                                     qualid,
                                                     qualtype,
                                                     awardbody,
                                                     title,
                                                     grade,
                                                     qualdate,
                                                     record_status,
                                                     error_code
                                                     )
                                         VALUES (    l_appno,
                                                     c_ivformqual_rec.qualid,
                                                     c_ivformqual_rec.qualtype,
                                                     c_ivformqual_rec.awardbody,
                                                     c_ivformqual_rec.title,
                                                     c_ivformqual_rec.grade,
                                                     c_ivformqual_rec.qualdate,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;


       IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVFORMQUALS', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVFORMQUALS', l_count) ;
       ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVFORMQUALS') ;
       END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVFORMQUALS_2004');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_ivformquals_2004   ;


  PROCEDURE load_ivformquals_2006 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :   15-Sep-05
     Purpose         :   loads each record in the hercules view ivformquals into the interface table
                           igs_uc_ifrmqul_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     jbaber    11-Jul-06    Truncate qualtype to 30 chars for UCAS 2007 Support
    ***************************************************************** */

    -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivformqual ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT     appno
                 ,timestamp
                 ,qualid
                 ,RTRIM(SUBSTR(qualtype,1,30)) qualtype
                 ,RTRIM(awardbody) awardbody
                 ,RTRIM(title) title
                 ,RTRIM(grade) grade
                 ,qualdateyear
                 ,qualdatemonth
      FROM  igs_uc_ivformquals_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivformquals_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivformquals_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_qualdate   igs_uc_ifrmqul_ints.qualdate%TYPE;
      l_appno      igs_uc_ifrmqul_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
       log_start('IVFORMQUALS ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVFORMQUALS', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
       FOR c_ivformqual_rec IN c_ivformqual(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivformqual_rec.appno,'IVFORMQUALS','APPNO','NUMBER') THEN

                  -- Determine actual appno
                  get_appno(c_ivformqual_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_ifrmqul_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND appno = l_appno
                  AND qualid = c_ivformqual_rec.qualid ;

                  -- Construct qualdate from qualdatemonth and qualdateyear
                  IF c_ivformqual_rec.qualdatemonth IS NOT NULL AND
                     c_ivformqual_rec.qualdateyear IS NOT NULL THEN
                      l_qualdate := TO_DATE(LPAD(c_ivformqual_rec.qualdatemonth,2,0) || c_ivformqual_rec.qualdateyear, 'mmyyyy');
                  ELSE
                      l_qualdate := NULL;
                  END IF;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_ifrmqul_ints (  appno,
                                                     qualid,
                                                     qualtype,
                                                     awardbody,
                                                     title,
                                                     grade,
                                                     qualdate,
                                                     record_status,
                                                     error_code
                                                     )
                                         VALUES (    l_appno,
                                                     c_ivformqual_rec.qualid,
                                                     c_ivformqual_rec.qualtype,
                                                     c_ivformqual_rec.awardbody,
                                                     c_ivformqual_rec.title,
                                                     c_ivformqual_rec.grade,
                                                     l_qualdate,
                                                     'N',
                                                     NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

       END LOOP ;


       IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVFORMQUALS', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete('IVFORMQUALS', l_count) ;
       ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVFORMQUALS') ;
       END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVFORMQUALS_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END  load_ivformquals_2006   ;


  PROCEDURE load_ivreference_2004 IS
    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   loads each record in the hercules view ivreference into the interface table
                           igs_uc_irefrnc_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivreference ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT     appno
                 ,timestamp
                 ,DECODE(RTRIM(refereename),NULL, RPAD('*',LENGTH(refereename),'*'), RTRIM(refereename)) refereename
                 ,RTRIM(refereepost) refereepost
                 ,RTRIM(estabname) estabname
                 ,RTRIM(address1) address1
                 ,RTRIM(address2) address2
                 ,RTRIM(address3) address3
                 ,RTRIM(address4) address4
                 ,RTRIM(telephone) telephone
                 ,RTRIM(fax) fax
                 ,RTRIM(email) email
                 ,statement statement
      FROM  igs_uc_ivreference_2004_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivreference_2004_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivreference_2004_v.timestamp%TYPE ;
      l_count NUMBER ;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
      log_start( 'IVREFERENCE ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVREFERENCE', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
      FOR c_ivreference_rec IN c_ivreference(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              -- Obsolete matching records in interface table with status N
              UPDATE igs_uc_irefrnc_ints SET record_status = 'O'
              WHERE record_status = 'N' AND appno = c_ivreference_rec.appno
              AND refereename = c_ivreference_rec.refereename ;

              -- copy hercules record into interface table with record status N
              INSERT INTO igs_uc_irefrnc_ints ( appno,
                                                refereename,
                                                refereepost,
                                                estabname,
                                                address1,
                                                address2,
                                                address3,
                                                address4,
                                                telephone,
                                                fax,
                                                email,
                                                statement,
                                                record_status,
                                                error_code
                                                 )
                VALUES (        c_ivreference_rec.appno,
                                                c_ivreference_rec.refereename,
                                                c_ivreference_rec.refereepost,
                                                c_ivreference_rec.estabname,
                                                c_ivreference_rec.address1,
                                                c_ivreference_rec.address2,
                                                c_ivreference_rec.address3,
                                                c_ivreference_rec.address4,
                                                c_ivreference_rec.telephone,
                                                c_ivreference_rec.fax,
                                                c_ivreference_rec.email,
                                                c_ivreference_rec.statement,
                                                'N',
                                                NULL
                                                 ) ;
        -- increment count of records
        l_count := l_count + 1;

      END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVREFERENCE', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete( 'IVREFERENCE', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVREFERENCE') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVREFERENCE_2004');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivreference_2004  ;


  PROCEDURE load_ivreference_2006 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :  07-Jul-05
     Purpose         :  loads each record in the hercules view ivreference into the interface table
                        igs_uc_irefrnc_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivreference ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT     appno
                 ,timestamp
                 ,DECODE(RTRIM(refereename),NULL, RPAD('*',LENGTH(refereename),'*'), RTRIM(refereename)) refereename
                 ,RTRIM(refereepost) refereepost
                 ,RTRIM(estabname) estabname
                 ,RTRIM(address1) address1
                 ,RTRIM(address2) address2
                 ,RTRIM(address3) address3
                 ,RTRIM(address4) address4
                 ,RTRIM(telephone) telephone
                 ,RTRIM(fax) fax
                 ,RTRIM(email) email
                 ,statement statement
                 ,RTRIM(predictedgrades) predictedgrades
      FROM  igs_uc_ivreference_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivreference_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivreference_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_irefrnc_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
      log_start( 'IVREFERENCE ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVREFERENCE', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
      FOR c_ivreference_rec IN c_ivreference(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivreference_rec.appno,'IVREFERENCE','APPNO','NUMBER') THEN

                  get_appno(c_ivreference_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_irefrnc_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND appno = l_appno
                  AND refereename = c_ivreference_rec.refereename ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_irefrnc_ints ( appno,
                                                    refereename,
                                                    refereepost,
                                                    estabname,
                                                    address1,
                                                    address2,
                                                    address3,
                                                    address4,
                                                    telephone,
                                                    fax,
                                                    email,
                                                    statement,
                                                    predictedgrades,
                                                    record_status,
                                                    error_code
                                                     )
                    VALUES (                        l_appno,
                                                    c_ivreference_rec.refereename,
                                                    c_ivreference_rec.refereepost,
                                                    c_ivreference_rec.estabname,
                                                    c_ivreference_rec.address1,
                                                    c_ivreference_rec.address2,
                                                    c_ivreference_rec.address3,
                                                    c_ivreference_rec.address4,
                                                    c_ivreference_rec.telephone,
                                                    c_ivreference_rec.fax,
                                                    c_ivreference_rec.email,
                                                    c_ivreference_rec.statement,
                                                    c_ivreference_rec.predictedgrades,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

      END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVREFERENCE', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete( 'IVREFERENCE', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVREFERENCE') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVREFERENCE_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivreference_2006  ;


  PROCEDURE load_ivgreference_2006 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :  16-Aug-05
     Purpose         :  loads each record in the hercules view ivgreference into the interface table
                        igs_uc_irefrnc_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivgreference ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT     appno
                 ,timestamp
                 ,DECODE(RTRIM(refereename),NULL, RPAD('*',LENGTH(refereename),'*'), RTRIM(refereename)) refereename
                 ,RTRIM(refereepost) refereepost
                 ,RTRIM(estabname) estabname
                 ,RTRIM(address1) address1
                 ,RTRIM(address2) address2
                 ,RTRIM(address3) address3
                 ,RTRIM(address4) address4
                 ,RTRIM(telephone) telephone
                 ,RTRIM(fax) fax
                 ,RTRIM(email) email
                 ,statement statement
      FROM  igs_uc_ivgreference_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivgreference_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivgreference_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_irefrnc_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
      log_start( 'IVGREFERENCE ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVGREFERENCE', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
      FOR c_ivgreference_rec IN c_ivgreference(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivgreference_rec.appno,'IVGREFERENCE','APPNO','NUMBER') THEN

                  get_appno(c_ivgreference_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_irefrnc_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND appno = l_appno
                  AND refereename = c_ivgreference_rec.refereename ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_irefrnc_ints ( appno,
                                                    refereename,
                                                    refereepost,
                                                    estabname,
                                                    address1,
                                                    address2,
                                                    address3,
                                                    address4,
                                                    telephone,
                                                    fax,
                                                    email,
                                                    statement,
                                                    record_status,
                                                    error_code
                                                     )
                    VALUES (                        l_appno,
                                                    c_ivgreference_rec.refereename,
                                                    c_ivgreference_rec.refereepost,
                                                    c_ivgreference_rec.estabname,
                                                    c_ivgreference_rec.address1,
                                                    c_ivgreference_rec.address2,
                                                    c_ivgreference_rec.address3,
                                                    c_ivgreference_rec.address4,
                                                    c_ivgreference_rec.telephone,
                                                    c_ivgreference_rec.fax,
                                                    c_ivgreference_rec.email,
                                                    c_ivgreference_rec.statement,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

      END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVGREFERENCE', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete( 'IVGREFERENCE', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVGREFERENCE') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVGREFERENCE_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivgreference_2006  ;


  PROCEDURE load_ivnreference_2006 IS
    /******************************************************************
     Created By      :  jbaber
     Date Created By :  16-Aug-05
     Purpose         :  loads each record in the hercules view ivnreference into the interface table
                        igs_uc_irefrnc_ints with record status N
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

      -- Get all the records from hercules  view whose timestamp is > passed timestamp
      -- or get all the records in hercules view if the timestamp passed is null
      CURSOR c_ivnreference ( p_timestamp igs_uc_hrc_timstmps.timestamp%TYPE ) IS
      SELECT     appno
                 ,timestamp
                 ,DECODE(RTRIM(refereename),NULL, RPAD('*',LENGTH(refereename),'*'), RTRIM(refereename)) refereename
                 ,RTRIM(refereepost) refereepost
                 ,RTRIM(estabname) estabname
                 ,RTRIM(address1) address1
                 ,RTRIM(address2) address2
                 ,RTRIM(address3) address3
                 ,RTRIM(address4) address4
                 ,RTRIM(telephone) telephone
                 ,RTRIM(fax) fax
                 ,RTRIM(email) email
                 ,statement statement
      FROM  igs_uc_ivnreference_2006_v
      WHERE ( timestamp > p_timestamp OR p_timestamp IS NULL ) ;

      -- get the max timestamp value of the hercules view
      CURSOR c_max_timestamp IS
      SELECT MAX(timestamp)
      FROM igs_uc_ivnreference_2006_v  ;

      -- Variables
      p_old_timestamp igs_uc_hrc_timstmps.timestamp%TYPE  ;
      l_new_max_timestamp igs_uc_ivnreference_2006_v.timestamp%TYPE ;
      l_count NUMBER ;

      l_appno      igs_uc_irefrnc_ints.appno%TYPE;
      l_checkdigit NUMBER;

  BEGIN
       -- set syncronization required to false
       g_sync_reqd := FALSE;
       l_count := 0 ;

      -- log message that this view is being loaded
      log_start( 'IVNREFERENCE ON ') ;

      -- Get the old timestamp for this view in the configured cycle
      Herc_timestamp_exists('IVNREFERENCE', p_old_timestamp) ;

       -- create interface records for each record in the hercules view whose timestamp > old timestamp
      FOR c_ivnreference_rec IN c_ivnreference(p_old_timestamp) LOOP
              -- set x_sync_read to true if the loop is entered even once
              g_sync_reqd := TRUE;

              IF  is_valid(c_ivnreference_rec.appno,'IVNREFERENCE','APPNO','NUMBER') THEN

                  get_appno(c_ivnreference_rec.appno, NULL, l_appno, l_checkdigit);

                  -- Obsolete matching records in interface table with status N
                  UPDATE igs_uc_irefrnc_ints SET record_status = 'O'
                  WHERE record_status = 'N' AND appno = l_appno
                  AND refereename = c_ivnreference_rec.refereename ;

                  -- copy hercules record into interface table with record status N
                  INSERT INTO igs_uc_irefrnc_ints ( appno,
                                                    refereename,
                                                    refereepost,
                                                    estabname,
                                                    address1,
                                                    address2,
                                                    address3,
                                                    address4,
                                                    telephone,
                                                    fax,
                                                    email,
                                                    statement,
                                                    record_status,
                                                    error_code
                                                     )
                    VALUES (                        l_appno,
                                                    c_ivnreference_rec.refereename,
                                                    c_ivnreference_rec.refereepost,
                                                    c_ivnreference_rec.estabname,
                                                    c_ivnreference_rec.address1,
                                                    c_ivnreference_rec.address2,
                                                    c_ivnreference_rec.address3,
                                                    c_ivnreference_rec.address4,
                                                    c_ivnreference_rec.telephone,
                                                    c_ivnreference_rec.fax,
                                                    c_ivnreference_rec.email,
                                                    c_ivnreference_rec.statement,
                                                    'N',
                                                    NULL
                                                     ) ;
                  -- increment count of records
                  l_count := l_count + 1;

              END IF;

      END LOOP ;

      IF g_sync_reqd THEN
              -- get the max timestamp of this hercules view
              OPEN c_max_timestamp ;
              FETCH c_max_timestamp INTO l_new_max_timestamp ;
              CLOSE c_max_timestamp ;

               -- update /insert the timestamp record with new max timestamp
               ins_upd_timestamp ('IVNREFERENCE', l_new_max_timestamp) ;

              -- log message that this view has been loaded
               log_complete( 'IVNREFERENCE', l_count) ;
      ELSE
                -- log message that this view is already in sync and need not be loaded
               log_already_insync('IVNREFERENCE') ;
      END IF ;
      COMMIT;

  EXCEPTION
      WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_IVNREFERENCE_2006');
               igs_ge_msg_stack.add;
               app_exception.raise_exception ;
  END   load_ivnreference_2006  ;


  PROCEDURE load_main (
     errbuf                     OUT NOCOPY     VARCHAR2
    ,retcode                    OUT NOCOPY     NUMBER
    ,p_load_ref                 IN      VARCHAR2
    ,P_load_ext_ref             IN      VARCHAR2
    ,P_load_ucas_app            IN      VARCHAR2
    ,P_load_gttr_app            IN      VARCHAR2
    ,P_load_nmas_app            IN      VARCHAR2
     ) IS

    /******************************************************************
     Created By      :  smaddali
     Date Created By :   11-Jun-03
     Purpose         :   calls subprocedures to load each hercules view
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     smaddali   18-Aug-03   Calling procedure load_ivstatement_2004 instead of 2003 for bug#3098810
     smaddali   04-Sep-03   Modified order of load_ivstarpqr_2003 call for bug#3122898
     jchakrab   27-Jul-04   Modified for UCFD308 - UCAS - 2005 Regulatory Changes
     jbaber     12-Aug-05   Modified for UC307 - HERCULES Small Systems Support
     anwest     18-JAN-06   Bug# 4950285 R12 Disable OSS Mandate
    ***************************************************************** */

      validate_cycle     BOOLEAN := TRUE;

  BEGIN

      --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
      IGS_GE_GEN_003.SET_ORG_ID;

      -- Get the configured and current cycle information and exit process if not found
      g_cyc_info_rec := NULL ;
      OPEN c_cyc_info ;
      FETCH c_cyc_info INTO g_cyc_info_rec ;
      CLOSE c_cyc_info ;
      IF g_cyc_info_rec.configured_cycle IS NULL OR g_cyc_info_rec.current_cycle IS NULL THEN
            fnd_message.set_name('IGS','IGS_UC_CYCLE_NOT_FOUND');
            errbuf  := fnd_message.get;
            fnd_file.put_line(fnd_file.log, errbuf);
            retcode := 2 ;
            RETURN ;
      END IF;

      -- Validate configured cycle for UCAS system
      IF p_load_ref = 'Y' OR P_load_ext_ref = 'Y' OR P_load_ucas_app = 'Y' THEN
          c_ucas_cycle_rec := NULL ;
          OPEN c_ucas_cycle('U');
          FETCH c_ucas_cycle INTO c_ucas_cycle_rec ;
          CLOSE c_ucas_cycle ;
          -- If hercules and our oss system are not configured to the same cycle then report error
          IF NVL(c_ucas_cycle_rec.entry_year,0) <> Ltrim(Substr(g_cyc_info_rec.configured_cycle,3,2) ) THEN
              fnd_message.set_name('IGS','IGS_UC_CYCLES_NOT_SYNC');
              fnd_message.set_token('UCAS_CYCLE',Ltrim(Substr(g_cyc_info_rec.configured_cycle,3,2) ) );
              fnd_message.set_token('HERC_CYCLE',NVL(c_ucas_cycle_rec.entry_year,0 ) );
              fnd_message.set_token('SYSTEM_CODE','UCAS');
              errbuf := fnd_message.get ;
              fnd_file.put_line(fnd_file.log,errbuf );
              validate_cycle := FALSE;
          END IF ;
      END IF;

      -- Validate configured cycle for GTTR system
      IF P_load_gttr_app = 'Y' THEN
          c_ucas_cycle_rec := NULL ;
          OPEN c_ucas_cycle('G');
          FETCH c_ucas_cycle INTO c_ucas_cycle_rec ;
          CLOSE c_ucas_cycle ;
          -- If hercules and our oss system are not configured to the same cycle then report error
          IF NVL(c_ucas_cycle_rec.entry_year,0) <> Ltrim(Substr(g_cyc_info_rec.configured_cycle,3,2) ) THEN
              fnd_message.set_name('IGS','IGS_UC_CYCLES_NOT_SYNC');
              fnd_message.set_token('UCAS_CYCLE',Ltrim(Substr(g_cyc_info_rec.configured_cycle,3,2) ) );
              fnd_message.set_token('HERC_CYCLE',NVL(c_ucas_cycle_rec.entry_year,0 ) );
              fnd_message.set_token('SYSTEM_CODE','GTTR');
              errbuf := fnd_message.get ;
              fnd_file.put_line(fnd_file.log,errbuf );
              validate_cycle := FALSE;
          END IF ;
      END IF;

      -- Validate configured cycle for NMAS system
      IF P_load_nmas_app = 'Y' THEN
          c_ucas_cycle_rec := NULL ;
          OPEN c_ucas_cycle('N');
          FETCH c_ucas_cycle INTO c_ucas_cycle_rec ;
          CLOSE c_ucas_cycle ;
          -- If hercules and our oss system are not configured to the same cycle then report error
          IF NVL(c_ucas_cycle_rec.entry_year,0) <> Ltrim(Substr(g_cyc_info_rec.configured_cycle,3,2) ) THEN
              fnd_message.set_name('IGS','IGS_UC_CYCLES_NOT_SYNC');
              fnd_message.set_token('UCAS_CYCLE',Ltrim(Substr(g_cyc_info_rec.configured_cycle,3,2) ) );
              fnd_message.set_token('HERC_CYCLE',NVL(c_ucas_cycle_rec.entry_year,0 ) );
              fnd_message.set_token('SYSTEM_CODE','NMAS');
              errbuf := fnd_message.get ;
              fnd_file.put_line(fnd_file.log,errbuf );
              validate_cycle := FALSE;
          END IF ;
      END IF;

      -- If any of the configured cycle validations failed then exit process
      IF NOT validate_cycle THEN
          retcode := 2;
          RETURN;
      END IF;

      -- get the timestamps of hercules views from cvrefamendment
      g_refamend_timestamp := NULL ;
      IF g_cyc_info_rec.configured_cycle < '2007' THEN
          OPEN c_refamend_timestamp ;
          FETCH c_refamend_timestamp INTO g_refamend_timestamp ;
          IF c_refamend_timestamp%NOTFOUND THEN
              CLOSE c_refamend_timestamp ;
              fnd_message.set_name('IGS','IGS_UC_REFTIME_NOT_FOUND');
              errbuf  := fnd_message.get;
              fnd_file.put_line(fnd_file.log, errbuf);
              retcode := 2 ;
              RETURN ;
          ELSE
              CLOSE c_refamend_timestamp ;
          END IF ;
      ELSE
          OPEN c_refamend_timestamp_2007 ;
          FETCH c_refamend_timestamp_2007 INTO g_refamend_timestamp ;
          IF c_refamend_timestamp_2007%NOTFOUND THEN
              CLOSE c_refamend_timestamp_2007 ;
              fnd_message.set_name('IGS','IGS_UC_REFTIME_NOT_FOUND');
              errbuf  := fnd_message.get;
              fnd_file.put_line(fnd_file.log, errbuf);
              retcode := 2 ;
              RETURN ;
          ELSE
              CLOSE c_refamend_timestamp_2007 ;
          END IF ;
      END IF;

      -- get the timestamps of hercules views from cvgrefamendment
      -- for GTTR as per bug 4638126
      -- Only required if GTTR is set to Hercules
      OPEN c_ucas_interface('G');
      FETCH c_ucas_interface INTO c_ucas_interface_rec;
      CLOSE c_ucas_interface;
      IF c_ucas_interface_rec = 'H' THEN
          g_grefamend_timestamp := NULL ;
          OPEN c_grefamend_timestamp ;
          FETCH c_grefamend_timestamp INTO g_grefamend_timestamp ;
          IF c_grefamend_timestamp%NOTFOUND THEN
                CLOSE c_grefamend_timestamp ;
                fnd_message.set_name('IGS','IGS_UC_REFTIME_NOT_FOUND');
                fnd_message.set_token('VIEW_NAME','CvGRefAmendments');
                errbuf  := fnd_message.get;
                fnd_file.put_line(fnd_file.log, errbuf);
                retcode := 2 ;
                RETURN ;
          ELSE
                CLOSE c_grefamend_timestamp ;
          END IF ;
      END IF;


      -- Loading clearing Reference data if  P_load_ref is Y
      -- and the configured cycle is same as the current cycle
      IF (P_load_ref  = 'Y')  AND
         (g_cyc_info_rec.configured_cycle = g_cyc_info_rec.current_cycle) THEN

            -- when configuration cycle is 2003 then call respective sub procedures
            IF g_cyc_info_rec.configured_cycle = '2003'  THEN
                load_cvcourse_2003 ;
                load_cveblsubject_2003 ;
                load_cvinstitution_2003 ;
                load_cvjointadmissions_2003 ;
                load_cvrefapr_2003 ;
                load_cvrefawardbody_2003 ;
                load_cvrefdis_2003 ;
                load_cvreferror_2003 ;
                load_cvrefestgroup_2003 ;
                load_cvrefethnic_2003 ;
                load_cvrefexam_2003 ;
                load_cvreffee_2003 ;
                load_cvrefkeyword_2003 ;
                load_cvrefoeq_2003 ;
                load_cvrefofferabbrev_2003 ;
                load_cvrefoffersubj_2003 ;
                load_cvrefpocc_2003 ;
                load_cvrefrescat_2003 ;
                load_cvrefschooltype_2003 ;
                load_cvrefstatus_2003 ;
                load_cvreftariff_2003 ;
                load_cvrefucasgroup_2003 ;
                load_cvschool_2003 ;
                load_cvschoolcontact_2003 ;
                load_uvcontact_2003 ;
                load_uvcontgrp_2003 ;
                load_uvcourse_2003 ;
                load_uvcoursekeyword_2003 ;
                load_uvcoursevacancies_2003 ;
                load_uvcoursevacoptions_2003 ;
                load_uvofferabbrev_2003 ;
                -- this view is different for 2003 and 2004
                load_uvinstitution_2003 ;

            -- when configuration cycle is 2004 or 2005 then call respective sub procedures
            ELSIF  g_cyc_info_rec.configured_cycle = '2004' OR g_cyc_info_rec.configured_cycle = '2005' THEN
                load_cvcourse_2003 ;
                load_cveblsubject_2003 ;
                load_cvinstitution_2003 ;
                load_cvjointadmissions_2003 ;
                load_cvrefapr_2003 ;
                load_cvrefawardbody_2003 ;
                load_cvrefdis_2003 ;
                load_cvreferror_2003 ;
                load_cvrefestgroup_2003 ;
                load_cvrefethnic_2003 ;
                load_cvrefexam_2003 ;
                load_cvreffee_2003 ;
                load_cvrefkeyword_2003 ;
                load_cvrefoeq_2003 ;
                load_cvrefofferabbrev_2003 ;
                load_cvrefoffersubj_2003 ;
                load_cvrefpocc_2003 ;
                load_cvrefrescat_2003 ;
                load_cvrefschooltype_2003 ;
                load_cvrefstatus_2003 ;
                load_cvreftariff_2003 ;
                load_cvrefucasgroup_2003 ;
                load_cvschool_2003 ;
                load_cvschoolcontact_2003 ;
                load_uvcontact_2003 ;
                load_uvcontgrp_2003 ;
                load_uvcourse_2003 ;
                load_uvcoursekeyword_2003 ;
                load_uvcoursevacancies_2003 ;
                load_uvcoursevacoptions_2003 ;
                load_uvofferabbrev_2003 ;
                -- 2004 specific views processing
                load_uvinstitution_2004 ;

             -- when configuration cycle is 2006 then call respective sub procedures
            ELSIF  g_cyc_info_rec.configured_cycle = '2006' THEN
                load_cvcourse_2003 ;
                load_cveblsubject_2003 ;
                load_cvinstitution_2003 ;
                load_cvjointadmissions_2003 ;
                load_cvrefapr_2003 ;
                load_cvrefawardbody_2003 ;
                load_cvrefdis_2003 ;
                load_cvreferror_2003 ;
                load_cvrefestgroup_2003 ;
                load_cvrefethnic_2003 ;
                load_cvrefexam_2003 ;
                load_cvreffee_2003 ;
                load_cvrefkeyword_2003 ;
                load_cvrefoeq_2003 ;
                load_cvrefofferabbrev_2003 ;
                load_cvrefoffersubj_2003 ;
                load_cvrefpocc_2003 ;
                load_cvrefrescat_2003 ;
                load_cvrefschooltype_2003 ;
                load_cvrefstatus_2003 ;
                load_cvreftariff_2003 ;
                load_cvschool_2003 ;
                load_cvschoolcontact_2003 ;
                load_uvcourse_2003 ;
                load_uvcoursekeyword_2003 ;
                load_uvofferabbrev_2003 ;
                load_uvinstitution_2004 ;

             -- when configuration cycle is 2007 then call respective sub procedures
            ELSIF  g_cyc_info_rec.configured_cycle = '2007' THEN
                load_cvcourse_2003 ;
                load_cveblsubject_2003 ;
                load_cvinstitution_2003 ;
                load_cvjointadmissions_2003 ;
                load_cvrefapr_2003 ;
                load_cvrefawardbody_2003 ;
                load_cvrefdis_2003 ;
                load_cvreferror_2003 ;
                load_cvrefestgroup_2003 ;
                load_cvrefethnic_2003 ;
                load_cvrefexam_2003 ;
                load_cvreffee_2003 ;
                load_cvrefkeyword_2003 ;
                load_cvrefoeq_2003 ;
                load_cvrefofferabbrev_2003 ;
                load_cvrefoffersubj_2003 ;
                load_cvrefpocc_2003 ;
                load_cvrefrescat_2003 ;
                load_cvrefschooltype_2003 ;
                load_cvrefstatus_2003 ;
                load_cvreftariff_2003 ;
                load_cvschool_2003 ;
                load_cvschoolcontact_2003 ;
                load_uvcourse_2003 ;
                load_uvcoursekeyword_2003 ;
                load_uvofferabbrev_2003 ;
                load_uvinstitution_2004 ;
                load_cvrefcountry_2007 ;
                load_cvrefnationality_2007 ;

            -- when configuration cycle is 2008 , currently not coded
            ELSIF  g_cyc_info_rec.configured_cycle = '2008' THEN
                NULL ;
            END IF ;


            -- GTTR Small System Reference Data
            OPEN c_ucas_interface('G');
            FETCH c_ucas_interface INTO c_ucas_interface_rec;
            CLOSE c_ucas_interface;

            -- Check system is configured to HERCULES
            IF c_ucas_interface_rec = 'H' THEN

                IF g_cyc_info_rec.configured_cycle = '2006' THEN
                    -- Added cvgrefdegreesubj_2006 for bug 4638126
                    load_cvgrefdegreesubj_2006 ;
                ELSIF g_cyc_info_rec.configured_cycle = '2007' THEN
                    load_cvgrefdegreesubj_2006 ;
                    load_cvgcourse_2007 ;
                END IF;
            END IF;


            -- NMAS Small System Reference Data
            OPEN c_ucas_interface('N');
            FETCH c_ucas_interface INTO c_ucas_interface_rec;
            CLOSE c_ucas_interface;

            -- Check system is configured to HERCULES
            IF c_ucas_interface_rec = 'H' THEN

                IF g_cyc_info_rec.configured_cycle = '2007' THEN
                    load_cvncourse_2007 ;
                END IF;
            END IF;

      END IF ;


      -- Loading external reference Data if P_load_ext_ref is Y and
      -- the configured cycle is same as the current cycle
      IF   (P_load_ext_ref = 'Y') AND
           (g_cyc_info_rec.configured_cycle = g_cyc_info_rec.current_cycle) THEN

            -- when configuration cycle is 2003 then call respective sub procedures
            IF g_cyc_info_rec.configured_cycle = '2003'  THEN
                load_cvrefpre2000pocc_2003 ;
                load_cvrefsocialclass_2003 ;
                load_cvrefsocioeconomic_2003 ;
                load_cvrefsubj_2003 ;

            -- when configuration cycle is 2004 or 2005 then call respective sub procedures
            ELSIF  g_cyc_info_rec.configured_cycle = '2004' OR g_cyc_info_rec.configured_cycle = '2005' THEN
                load_cvrefpre2000pocc_2003 ;
                load_cvrefsocialclass_2003 ;
                load_cvrefsocioeconomic_2003 ;
                load_cvrefsubj_2003 ;

            -- when configuration cycle is 2006 then call respective sub procedures
            ELSIF  g_cyc_info_rec.configured_cycle = '2006' OR g_cyc_info_rec.configured_cycle = '2007' THEN
                load_cvrefsocialclass_2003 ;
                load_cvrefsocioeconomic_2003 ;
                load_cvrefsubj_2003 ;

            -- when configuration cycle is 2007, currently not coded
            ELSIF  g_cyc_info_rec.configured_cycle = '2008'  THEN
                NULL ;
            END IF;

      END IF ;

      -- Loading UCAS Application Data only when P_load_ucas_app = 'Y'
      IF P_load_ucas_app = 'Y' THEN

            OPEN c_ucas_interface('U');
            FETCH c_ucas_interface INTO c_ucas_interface_rec;
            CLOSE c_ucas_interface;

            IF c_ucas_interface_rec = 'H' THEN

                 -- when configuration cycle is 2003 then call respective sub procedures
                 -- smaddali has changed the order of loading StarPQR records for bug#3122898
                 -- because starpqr is being loaded based on ivqualification.timestamp. So please donot change the order
                 IF  g_cyc_info_rec.configured_cycle = '2003' THEN
                     load_ivoffer_2003 ;
                     load_ivstarpqr_2003 ;
                     load_ivqualification_2003 ;
                     load_ivstara_2003 ;
                     load_ivstarc_2003 ;
                     load_ivstarh_2003 ;
                     load_ivstark_2003 ;
                     load_ivstarn_2003 ;
                     load_ivstarx_2003 ;
                     load_ivstarz1_2003 ;
                     load_ivstarz2_2003 ;
                     -- these views are different for 2003 and 2004
                     load_ivstarw_2003 ;
                     load_ivstatement_2003 ;

                 -- when configuration cycle is 2004 or 2005 then call respective sub procedures
                 ELSIF g_cyc_info_rec.configured_cycle = '2004' OR g_cyc_info_rec.configured_cycle = '2005' THEN
                    load_ivoffer_2003 ;
                    load_ivstarpqr_2003 ;
                    load_ivqualification_2003 ;
                    load_ivstara_2003 ;
                    load_ivstarc_2003 ;
                    load_ivstarh_2003 ;
                    load_ivstark_2003 ;
                    load_ivstarn_2003 ;
                    load_ivstarx_2003 ;
                    load_ivstarz1_2003 ;
                    load_ivstarz2_2003 ;
                    -- 2004 specific views processing
                    load_ivreference_2004 ;
                    load_ivformquals_2004 ;
                    load_ivstarw_2004 ;
                    -- smaddali calling procedure 2004 , for bug#3098810
                    load_ivstatement_2004 ;

                -- when configuration cycle is 2006 then call respective sub procedures
                ELSIF g_cyc_info_rec.configured_cycle = '2006' THEN
                    load_ivoffer_2003 ;
                    load_ivstarpqr_2006 ; -- 29-MAY-2006 anwest Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
                    load_ivqualification_2003 ;
                    load_ivstara_2006 ;  -- updated for 2006
                    load_ivstarc_2003 ;
                    load_ivstarh_2003 ;
                    load_ivstark_2003 ;
                    load_ivstarn_2003 ;
                    load_ivstarx_2003 ;
                    load_ivstarz1_2003 ;
                    load_ivstarw_2004 ;
                    load_ivstatement_2004 ;
                    -- 2006 specific views processing
                    load_ivreference_2006 ;
                    load_ivformquals_2006 ;

            -- when configuration cycle is 2007 then call respective sub procedures
            ELSIF g_cyc_info_rec.configured_cycle = '2007' THEN
                    load_ivoffer_2003 ;
                    load_ivstarpqr_2006 ;
                    load_ivqualification_2003 ;
                    load_ivstarc_2003 ;
                    load_ivstarh_2003 ;
                    load_ivstarx_2003 ;
                    load_ivstarz1_2003 ;
                    load_ivstarw_2004 ;
                    load_ivstatement_2004 ;
                    load_ivreference_2006 ;
                    load_ivformquals_2006 ;
                    -- 2007 specific view processing
                    load_ivstara_2007 ;
                    load_ivstark_2007 ;
                    load_ivstarn_2007 ;

                 -- when configuration cycle is 2008 , currently not coded
                 ELSIF g_cyc_info_rec.configured_cycle = '2008' THEN
                    NULL ;
                 END IF ;

          ELSE

              -- UCAS interface is MARVIN so log warning.
              fnd_message.set_name('IGS','IGS_UC_MARVIN_INTERFACE');
              fnd_message.set_token('SYSTEM_CODE','UCAS');
              fnd_message.set_token('PROCESS','load');
              fnd_file.put_line(fnd_file.log,fnd_message.get );
              retcode := 1;

          END IF;


      END IF;


      -- Loading GTTR Application Data only when P_load_gttr_app = 'Y'
      IF P_load_gttr_app = 'Y' THEN

          OPEN c_ucas_interface('G');
          FETCH c_ucas_interface INTO c_ucas_interface_rec;
          CLOSE c_ucas_interface;

          IF c_ucas_interface_rec = 'H' THEN

              -- When configuration cycle is 2006 then call respective sub procedures
              IF g_cyc_info_rec.configured_cycle = '2006' THEN
                  load_ivgoffer_2006 ;
                  load_ivgstara_2006 ;
                  load_ivgstarg_2006 ;
                  load_ivgstarh_2006 ;
                  load_ivgstark_2006 ;
                  load_ivgstarn_2006 ;
                  load_ivgstarw_2006 ;
                  load_ivgstarx_2006 ;
                  load_ivgstatement_2006 ;
                  load_ivgreference_2006 ;

              -- When configuration cycle is 2007 then call respective sub procedures
              ELSIF g_cyc_info_rec.configured_cycle = '2007' THEN
                  load_ivgoffer_2006 ;
                  load_ivgstara_2007 ;
                  load_ivgstarg_2006 ;
                  load_ivgstarh_2006 ;
                  load_ivgstark_2007 ;
                  load_ivgstarn_2007 ;
                  load_ivgstarw_2007 ;
                  load_ivgstarx_2006 ;
                  load_ivgstatement_2006 ;
                  load_ivgreference_2006 ;

              -- when configuration cycle is 2008 , currently not coded
              ELSIF g_cyc_info_rec.configured_cycle = '2008' THEN
                  NULL ;
              END IF ;

          ELSE

              -- GTTR interface is MARVIN so log warning.
              fnd_message.set_name('IGS','IGS_UC_MARVIN_INTERFACE');
              fnd_message.set_token('SYSTEM_CODE','GTTR');
              fnd_message.set_token('PROCESS','load');
              fnd_file.put_line(fnd_file.log,fnd_message.get );
              retcode := 1;

          END IF;

      END IF;

      -- Loading NMAS Application Data only when P_load_nmas_app = 'Y'
      IF P_load_nmas_app = 'Y' THEN

          OPEN c_ucas_interface('N');
          FETCH c_ucas_interface INTO c_ucas_interface_rec;
          CLOSE c_ucas_interface;

          IF c_ucas_interface_rec = 'H' THEN

              -- When configuration cycle is 2006 then call respective sub procedures
              IF g_cyc_info_rec.configured_cycle = '2006' THEN
                  load_ivnoffer_2006 ;
                  load_ivnstara_2006 ;
                  load_ivnstarc_2006 ;
                  load_ivnstarh_2006 ;
                  load_ivnstark_2006 ;
                  load_ivnstarn_2006 ;
                  load_ivnstarw_2006 ;
                  load_ivnstarx_2006 ;
                  load_ivnstarz1_2006 ;
                  load_ivnstatement_2006 ;
                  load_ivnreference_2006 ;

              -- When configuration cycle is 2007 then call respective sub procedures
              ELSIF g_cyc_info_rec.configured_cycle = '2007' THEN
                  load_ivnoffer_2006 ;
                  load_ivnstara_2007 ;
                  load_ivnstarc_2006 ;
                  load_ivnstarh_2006 ;
                  load_ivnstark_2007 ;
                  load_ivnstarn_2007 ;
                  load_ivnstarw_2007 ;
                  load_ivnstarx_2006 ;
                  load_ivnstarz1_2006 ;
                  load_ivnstatement_2006 ;
                  load_ivnreference_2006 ;

              -- when configuration cycle is 2008 , currently not coded
              ELSIF g_cyc_info_rec.configured_cycle = '2008' THEN
                  NULL ;
              END IF ;

          ELSE

              -- NMAS interface is MARVIN so log warning.
              fnd_message.set_name('IGS','IGS_UC_MARVIN_INTERFACE');
              fnd_message.set_token('SYSTEM_CODE','NMAS');
              fnd_message.set_token('PROCESS','load');
              fnd_file.put_line(fnd_file.log,fnd_message.get );
              retcode := 1;

          END IF;


      END IF;


  EXCEPTION
        WHEN OTHERS THEN
               ROLLBACK;
               write_to_log(SQLERRM);
               retcode := 2;
               Fnd_Message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
               fnd_message.set_token('NAME', 'IGS_UC_LOAD_HERCULES_DATA.LOAD_MAIN');
               errbuf  := fnd_message.get;
               igs_ge_msg_stack.conc_exception_hndl;

  END load_main;

END igs_uc_load_hercules_data;

/
