--------------------------------------------------------
--  DDL for Package Body IGS_EN_LGCY_PRC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_LGCY_PRC" AS
/* $Header: IGSEN99B.pls 120.6 2006/04/13 01:55:01 smaddali ship $ */

/*****************************************************************************
 Who     When        What
 amuthu   21-NOV-2002 Modified as per the Legacy Import prcess
                      TD for EN and REC
 ptandon  26-SEP-2003 Modified the procedure process_as_uotcm to pass the value of fields
                      LOCATION_CD and UNIT_CLASS in lr_as_uotcm_rec parameter in call to procedure
                      igs_as_suao_lgcy_pub.create_unit_outcome. Bug# 3149520.
 rvangala 07-OCT-2003 Value for CORE_INDICATOR_CODE passed to IGS_EN_SUA_API.UPDATE_UNIT_ATTEMPT
                      added as part of Prevent Dropping Core Units. Enh Bug# 3052432
 vkarthik 12-DEC-2003 Added process_en_spat to proces term records from the interface table
                      and necessary call
 ptandon  16-DEC-2003 Modified procedure process_en_sua to log warning messages in case of
                      successful unit attempts also so as to show warnings if term record
                      creation fails. Term Based Fee Calc build. Bug# 2829263.
 smaddali 19-OCT-2004 Modified procedure log_err_messages for performance issues
 jtmathew 12-JAN-2005 Modified procedures process_he_spa and process_he_susa
                      to add additional fields to lr_he_spa_rec and lr_he_susa_rec
                      for changes described by HEFD350.
 jhanda   15-July-2005 Changed for build 4327991
 ckasu    17-JAN-2006  Added igs_ge_gen_003.set_org_id(NULL) in LEGACY_BATCH_PROCESS
                        procedure as a part of bug#4958173
 smaddali  10-apr-06         Modified for bug#5091858 BUILD EN324
******************************************************************************/

  -- cursor for find the lookup meaning for a given lookup code and type
  CURSOR gc_lkups (cp_lookup_code igs_lookup_values.lookup_code%TYPE,
                  cp_lookup_type igs_lookup_values.lookup_type%TYPE) IS
  SELECT meaning
  FROM igs_lookup_values
  WHERE lookup_code = cp_lookup_code
  AND   lookup_type = cp_lookup_type;

  -- Table Constants
  g_cst_en_spat   CONSTANT VARCHAR2(30) := 'EN_SPAT';
  g_cst_all       CONSTANT VARCHAR2(30) := 'ALL';
  g_cst_en_spa    CONSTANT VARCHAR2(30) := 'EN_SPA';
  g_cst_en_susa   CONSTANT VARCHAR2(30) := 'EN_SUSA';
  g_cst_en_spi    CONSTANT VARCHAR2(30) := 'EN_SPI';
  g_cst_en_spaa   CONSTANT VARCHAR2(30) := 'EN_SPAA';
  g_cst_re_sprvsr CONSTANT VARCHAR2(30) := 'RE_SPRVSR';
  g_cst_re_the    CONSTANT VARCHAR2(30) := 'RE_THE';
  g_cst_en_sua    CONSTANT VARCHAR2(30) := 'EN_SUA';
  g_cst_he_spa    CONSTANT VARCHAR2(30) := 'HE_SPA';
  g_cst_he_susa   CONSTANT VARCHAR2(30) := 'HE_SUSA';
  g_cst_av_avstdl CONSTANT VARCHAR2(30) := 'AV_AVSTDL';
  g_cst_av_untstd CONSTANT VARCHAR2(30) := 'AV_UNTSTD';
  g_cst_as_uotcm  CONSTANT VARCHAR2(30) := 'AS_UOTCM';
  g_cst_pr_out    CONSTANT VARCHAR2(30) := 'PR_OUT';
  g_cst_pr_cr     CONSTANT VARCHAR2(30) := 'PR_CR';
  g_cst_gr_grd    CONSTANT VARCHAR2(30) := 'GR_GRD';
  -- anilk, transcript comments
  g_cst_as_trncmt CONSTANT VARCHAR2(30) := 'AS_TRNCMT';
 --  bradhakr , reference codes
  g_cst_as_suarc    CONSTANT VARCHAR2(30) := 'AS_SUARC';
  -- constant for the lookup type
  g_cst_tbl_lkup_type CONSTANT VARCHAR2(30) := 'LEGACY_EN_REC_TABLES';
  g_cst_lgcy_status   CONSTANT VARCHAR2(30) := 'LEGACY_STATUS';
  g_cst_en_spi_rcond  CONSTANT VARCHAR2(30) := 'EN_SPIRC';
  -- resource busy exception and its associated pragma
  g_resource_busy  EXCEPTION;
  PRAGMA EXCEPTION_INIT(g_resource_busy,-00054);


-------------------------------------------------------------------------------
  -- function to return last updated by
  FUNCTION get_last_updated_by RETURN NUMBER AS
  BEGIN
        IF FND_GLOBAL.USER_ID IS NULL THEN
          RETURN -1;
        ELSE
          RETURN FND_GLOBAL.USER_ID;
        END IF;
  END get_last_updated_by ;

-------------------------------------------------------------------------------
  -- fucntion to return last update date
  FUNCTION get_last_update_date RETURN DATE AS
  BEGIN
    RETURN SYSDATE;
  END get_last_update_date ;

-------------------------------------------------------------------------------
  -- function ro return last update login
  FUNCTION get_last_update_login RETURN NUMBER AS
  BEGIN
        IF FND_GLOBAL.LOGIN_ID IS NULL THEN
            RETURN -1;
        ELSE
          RETURN FND_GLOBAL.LOGIN_ID;
        END IF;
  END get_last_update_login;

-------------------------------------------------------------------------------
  -- function to return the request id
  FUNCTION get_request_id RETURN NUMBER AS
  BEGIN

    IF FND_GLOBAL.CONC_REQUEST_ID = -1 THEN
      RETURN NULL;
    ELSE
      RETURN FND_GLOBAL.CONC_REQUEST_ID;
    END IF;
  END get_request_id;

-------------------------------------------------------------------------------
  -- function ro get the program application id
  FUNCTION get_program_application_id RETURN NUMBER AS
  BEGIN
    IF (FND_GLOBAL.CONC_REQUEST_ID = -1) THEN
      RETURN NULL;
    ELSE
      RETURN FND_GLOBAL.PROG_APPL_ID;
    END IF;
  END get_program_application_id;

-------------------------------------------------------------------------------
  -- function to return the program id
  FUNCTION get_program_id RETURN NUMBER AS
  BEGIN
    IF (FND_GLOBAL.CONC_REQUEST_ID = -1) THEN
      RETURN NULL;
    ELSE
      RETURN FND_GLOBAL.CONC_PROGRAM_ID;
    END IF;
  END get_program_id;

-------------------------------------------------------------------------------
  -- function to return the program update date
  FUNCTION get_program_update_date RETURN DATE AS
  BEGIN
    IF (FND_GLOBAL.CONC_REQUEST_ID = -1) THEN
      RETURN NULL;
    ELSE
      RETURN SYSDATE;
    END IF;
  END get_program_update_date;


-------------------------------------------------------------------------------
  -- prcedure to delete error messages
  procedure delete_err_messages(
     p_int_table_code IN VARCHAR2,
     p_int_table_id   IN NUMBER
  ) AS
  BEGIN
/*
  This procedure deletes the error message
  records for the particualr interface table corresponding
  to the p_int_table_code and p_int_table_id
*/
    DELETE FROM igs_en_lgcy_err_int
    WHERE int_table_id = p_int_table_id
    AND   int_table_code = p_int_table_code;
  END;
-------------------------------------------------------------------------------
  PROCEDURE log_resource_busy(p_int_table_code IN VARCHAR2) AS
    l_msg_text      FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    l_table_meaning igs_lookup_values.meaning%TYPE;
    l_meaning       igs_lookup_values.meaning%TYPE;
  BEGIN

    FND_MESSAGE.SET_NAME('FND','FND_LOCK_RECORD_ERROR');
    l_msg_text := FND_MESSAGE.GET;

    OPEN gc_lkups (p_int_table_code,g_cst_tbl_lkup_type);
    FETCH gc_lkups INTO l_table_meaning;
    CLOSE gc_lkups;

    OPEN gc_lkups ('E',g_cst_lgcy_status);
    FETCH gc_lkups INTO l_meaning;
    CLOSE gc_lkups;

    FND_FILE.PUT_LINE(FND_FILE.LOG,l_meaning || ' ' || l_table_meaning || ' ' || l_msg_text);

  END log_resource_busy;

-------------------------------------------------------------------------------
  PROCEDURE log_no_data_exists(p_log IN BOOLEAN) AS
    l_msg_text       FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
  BEGIN
    IF p_log THEN
     FND_MESSAGE.SET_NAME('FND','FND_DEF_ALTERNATE_TEXT');
     l_msg_text := FND_MESSAGE.GET;
     FND_FILE.PUT_LINE(FND_FILE.LOG, '          ' || l_msg_text);
    END IF;
  END log_no_data_exists;

-------------------------------------------------------------------------------
  PROCEDURE log_headers(
    p_int_table_code IN VARCHAR2
  ) AS
     l_msg_text5      FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
     l_table_meaning  igs_lookup_values.meaning%TYPE;

     l_msg_text1      FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
     l_msg_text2      FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
     l_msg_text3      FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
     l_msg_text4      FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;


  BEGIN
/*
  This to log the header for each interface table that is processed
  The header would be logged in the following format
  "Row Type    Student Program Attempt"
  The "Row Type" Part comes from a message the table name
  part of it comes from the Lookup meaning of the int_table_cd
*/

    FND_MESSAGE.SET_NAME('IGS','IGS_EN_INTERFACE_ID');
    l_msg_text1 := FND_MESSAGE.GET;

    FND_MESSAGE.SET_NAME('IGS','IGS_EN_MESSAGE_NUM');
    l_msg_text2 := FND_MESSAGE.GET;

    FND_MESSAGE.SET_NAME('IGS','IGS_EN_ROW_STATUS');
    l_msg_text3 := FND_MESSAGE.GET;

    FND_MESSAGE.SET_NAME('IGS','IGS_EN_MSG_TXT');
    l_msg_text4 := FND_MESSAGE.GET;

    FND_MESSAGE.SET_NAME('IGS','IGS_EN_ROW_TYPE');
    l_msg_text5 := FND_MESSAGE.GET;

    OPEN gc_lkups (p_int_table_code,g_cst_tbl_lkup_type);
    FETCH gc_lkups INTO l_table_meaning;
    CLOSE gc_lkups;

    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'--------------------------------------------------------------------------------');
    FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_text5 || '    ' || l_table_meaning);
    FND_FILE.PUT_LINE(FND_FILE.LOG,'--------------------------------------------------------------------------------');
    FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_text1 || '       ' || l_msg_text2 || '    ' || l_msg_text3 || '                 ' || l_msg_text4 );
    FND_FILE.PUT_LINE(FND_FILE.LOG,'--------------------------------------------------------------------------------');

  END log_headers;

-------------------------------------------------------------------------------
  PROCEDURE log_suc_message(
    P_int_table_id   IN NUMBER
  ) AS
    l_msg_text FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    l_meaning  igs_lookup_values.meaning%TYPE;
  BEGIN

    FND_MESSAGE.SET_NAME('IGS','IGS_EN_LGCY_SUCCESS');
    l_msg_text := FND_MESSAGE.GET;

    OPEN gc_lkups ('I',g_cst_lgcy_status);
    FETCH gc_lkups INTO l_meaning;
    CLOSE gc_lkups;

    -- log the error message in the concurrent log
     FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(p_int_table_id,15,' ')
                                || '                     '
                                || ' ' || RPAD(l_meaning,22,' ')
                                || '     ' || l_msg_text);

  END log_suc_message;

-------------------------------------------------------------------------------
  PROCEDURE insert_log_err_msgs(
    p_int_table_code IN VARCHAR2,
    P_int_table_id   IN NUMBER,
    p_err_msg_id     IN NUMBER,
    p_msg_ret_status IN VARCHAR2,
    p_msg_text       IN VARCHAR2,
    p_msg_number     IN NUMBER
  ) AS
    l_created_by             NUMBER;
    l_creation_date          DATE;
    l_last_update_date       DATE ;
    l_last_updated_by        NUMBER;
    l_last_update_login      NUMBER;
    l_request_id             NUMBER;
    l_program_id             NUMBER;
    l_program_application_id NUMBER;
    l_program_update_date    DATE;

    l_status_mean    igs_lookup_values.meaning%TYPE;
    l_msg_ret_status VARCHAR2(1);
  BEGIN

    IF p_msg_ret_status = 'W' THEN
      l_msg_ret_status := 'W';
    ELSE
      l_msg_ret_status := 'E';
    END IF;

    OPEN  gc_lkups (l_msg_ret_status,g_cst_lgcy_status);
    FETCH gc_lkups INTO l_status_mean;
    CLOSE gc_lkups;

    l_created_by             := get_last_updated_by;
    l_creation_date          := SYSDATE;
    l_last_updated_by        := get_last_updated_by;
    l_last_update_date       := get_last_update_date;
    l_last_update_login      := get_last_update_login;
    l_request_id             := get_request_id;
    l_program_application_id := get_program_application_id;
    l_program_id             := get_program_id;
    l_program_update_date    := get_program_update_date;
    INSERT INTO igs_en_lgcy_err_int
    (
      err_message_id,
      int_table_code,
      int_table_id,
      message_num,
      message_text,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date
    )
    VALUES
    (
      p_err_msg_id,
      p_int_table_code,
      p_int_table_id,
      p_msg_number,
      p_msg_text,
      l_created_by,
      l_creation_date,
      l_last_updated_by ,
      l_last_update_date ,
      l_last_update_login ,
      l_request_id,
      l_program_application_id,
      l_program_id,
      l_program_update_date
    );

/* example of the out put
--------------------------------------------------------------------------------
   Interface ID  Message Number  Row Status                 Message Text
--------------------------------------------------------------------------------
..
..
--------------------------------------------------------------------------------
Row Type :    Research Thesis
            999                   Warning                   Thesis already exists for the Student.
..
..
--------------------------------------------------------------------------------
*/
    -- log the error message in the concurrent log
    FND_FILE.PUT_LINE(FND_FILE.LOG,RPAD(p_int_table_id,15,' ')
                        || '    ' || RPAD(NVL(TO_CHAR(p_msg_number),'         '),9,' ')
                        || '         ' || RPAD(l_status_mean,22,' ')
                        || '     ' || p_msg_text);

  END insert_log_err_msgs;
-------------------------------------------------------------------------------
  PROCEDURE log_err_messages(
    p_int_table_code IN VARCHAR2,
    P_int_table_id   IN NUMBER,
    p_msg_count      IN NUMBER,
    p_msg_data       IN VARCHAR2,
    p_msg_ret_status IN VARCHAR2
  ) AS
 /*----------------------------------------------------------------------------
 ||  Created By :
 ||  Created On :
 ||  Purpose :The error message for teh particular row is passed bye the Called API
 ||  using the two standard parametere p_msg_data and p_msg_count. The two
 ||  values are passed to this procedure. In this procedure the error messages
 ||  are decoded/parsed and put into the concurrent manager log file and
 ||  the legacy error message table. For each row in the interface table a new
 ||  error message id would be generated. It is the users responsibility to
 ||  clean up the message table as and when necessary.
 ||
 ||  In case the deletion flag is passed as 'Y' and the record is successfully
 ||  imported then all the associated error messages would also be deleted.
 ||  But the logic for that is coded in the individual procedure
 ||  Known limitations, enhancements or remarks :
 ||  Change History :
 ||  Who             When            What
 ||  kkillams        20-12-2002      Added new validation inside the FOR LOOP
 ||                                  which sets the  l_err_msg_id variable with the
 ||                                  next "legacy error" sequence number, w.r.t. bug :2717455
 || smaddali  19-oct-04      Modified this procedure for bug#3930425, performance issue with cursor c_msg_text_num
 ------------------------------------------------------------------------------*/

    --smaddali: bug#3930425, modified this cursor for performance, to be based on appl_id and message_name as this is the PK
    CURSOR c_msg_text_num (cp_appl_name FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE   ,
            cp_message_name FND_NEW_MESSAGES.MESSAGE_NAME%TYPE) IS
    SELECT message_number
    FROM FND_NEW_MESSAGES msg ,fnd_application apl
    WHERE apl.application_id  = msg.application_id
    AND   apl.application_short_name = cp_appl_name
    AND   message_name = cp_message_name;

    l_msg_count      NUMBER(4);
    l_msg_data       VARCHAR2(4000);
    l_enc_msg        VARCHAR2(2000);
    l_msg_index      NUMBER(4);
    l_appl_name      FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE;
    l_msg_name       FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
    l_msg_number     FND_NEW_MESSAGES.MESSAGE_NUMBER%TYPE;
    l_msg_text       FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    l_err_msg_id     igs_en_lgcy_err_int.err_message_id%TYPE;
    l_app VARCHAR2(10);
  BEGIN

    l_msg_count := p_msg_count;
    l_msg_data := p_msg_data;

    IF l_msg_count =1 THEN
      SELECT igs_en_lgcy_err_int_s.NEXTVAL INTO l_err_msg_id FROM DUAL;
      FND_MESSAGE.SET_ENCODED(l_msg_data);
      l_msg_text := FND_MESSAGE.GET;

      l_msg_number := NULL;
      FND_MESSAGE.PARSE_ENCODED(l_msg_data,l_app,l_msg_name);
      OPEN c_msg_text_num (l_app, l_msg_name);
      FETCH c_msg_text_num INTO l_msg_number;
      CLOSE c_msg_text_num;

      insert_log_err_msgs(
        p_int_table_code => p_int_table_code,
        p_int_table_id   => p_int_table_id,
        p_err_msg_id     => l_err_msg_id,
        p_msg_ret_status => p_msg_ret_status,
        p_msg_text       => l_msg_text,
        p_msg_number     => l_msg_number
      );
    ELSIF l_msg_count > 1 THEN
      FOR l_index IN 1..NVL(l_msg_count,0)
      LOOP
           SELECT igs_en_lgcy_err_int_s.NEXTVAL INTO l_err_msg_id FROM DUAL;
            FND_MSG_PUB.GET(FND_MSG_PUB.G_FIRST,
                            FND_API.G_TRUE,
                            l_enc_msg,
                            l_msg_index);
            FND_MESSAGE.SET_ENCODED(l_enc_msg);
            l_msg_text := FND_MESSAGE.GET;
            FND_MSG_PUB.DELETE_MSG(l_msg_index);

            l_msg_number := NULL;
            FND_MESSAGE.PARSE_ENCODED(l_enc_msg,l_app,l_msg_name);
            OPEN c_msg_text_num (l_app,l_msg_name);
            FETCH c_msg_text_num INTO l_msg_number;
            CLOSE c_msg_text_num;
             insert_log_err_msgs(
              p_int_table_code => p_int_table_code,
              p_int_table_id   => p_int_table_id,
              p_err_msg_id     => l_err_msg_id,
              p_msg_ret_status => p_msg_ret_status,
              p_msg_text       => l_msg_text,
              p_msg_number     => l_msg_number);
      END LOOP;
    END IF;

  END log_err_messages;


 PROCEDURE process_as_suarc(
              p_batch_id      IN NUMBER,
              p_deletion_flag IN BOOLEAN
  ) AS

     CURSOR c_as_suarc IS
      SELECT   suarc.*
        FROM igs_as_lgcy_suarc_int suarc
       WHERE batch_id = p_batch_id AND import_status IN ('U', 'R')
    ORDER BY suarc.person_number ASC
     FOR UPDATE NOWAIT;

    lr_as_suarefcd_rec   IGS_AS_SUARC_LGCY_PUB.sua_refcd_rec_type;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER(4);
    l_msg_data      VARCHAR2(4000);

    l_last_update_date       DATE ;
    l_last_updated_by        NUMBER;
    l_last_update_login      NUMBER;
    l_request_id             NUMBER;
    l_program_id             NUMBER;
    l_program_application_id NUMBER;
    l_program_update_date    DATE;
    l_not_found              BOOLEAN;

  BEGIN
/*
   Process the records in the Student Unit attempt reference code interface table
   where the import status is either 'U' - Unproccessed or 'R' ready for reporccessing

   */

    log_headers(g_cst_as_suarc);
    l_not_found := TRUE;

    FOR l_as_suarefcd_rec IN c_as_suarc LOOP
      BEGIN

        -- create a save point. if there are any errors returned by
        -- the API then rollback to this savepoint before processing
        -- then next record.
        SAVEPOINT savepoint_as_suarc;
        l_not_found := FALSE;


         -- populate the record variable to pass to the API
        lr_as_suarefcd_rec.person_number                 := l_as_suarefcd_rec.person_number ;
        lr_as_suarefcd_rec.program_cd                    := l_as_suarefcd_rec.program_cd ;
        lr_as_suarefcd_rec.unit_cd                       := l_as_suarefcd_rec.unit_cd ;
        lr_as_suarefcd_rec.version_number           := l_as_suarefcd_rec.version_number ;
        lr_as_suarefcd_rec.teach_cal_alt_code            := l_as_suarefcd_rec.teach_cal_alt_code ;
        lr_as_suarefcd_rec.location_cd                   := l_as_suarefcd_rec.location_cd ;
        lr_as_suarefcd_rec.unit_class                    := l_as_suarefcd_rec.unit_class ;
        lr_as_suarefcd_rec.reference_cd_type              := l_as_suarefcd_rec.reference_cd_type ;
        lr_as_suarefcd_rec.reference_cd                  := l_as_suarefcd_rec.reference_cd ;
        lr_as_suarefcd_rec.applied_program_cd            := l_as_suarefcd_rec.applied_program_cd ;

        l_return_status := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;
        IGS_AS_SUARC_LGCY_PUB.create_suarc(
                      P_API_VERSION      => 1.0,
                      P_INIT_MSG_LIST    => FND_API.G_TRUE,
                      P_COMMIT           => FND_API.G_FALSE,
                      P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                      p_suarc_dtls_rec     => lr_as_suarefcd_rec,
                      X_RETURN_STATUS    => l_return_status,
                      X_MSG_COUNT        => l_msg_count,
                      X_MSG_DATA         => l_msg_data
        );


        IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_return_status IS NULL THEN
           ROLLBACK TO savepoint_as_suarc;
       -- log the error message in the error message interface table
           log_err_messages(
             g_cst_as_suarc,
             l_as_suarefcd_rec.legacy_suar_int_id,
             l_msg_count,
             l_msg_data,
             l_return_status
           );
        ELSE
          -- log the success message in the concurrent manager log.
          log_suc_message( l_as_suarefcd_rec.LEGACY_SUAR_INT_ID);
        END IF;

        IF p_deletion_flag AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          -- delete any records in the error message interface table
          delete_err_messages(
            p_int_table_code => g_cst_en_sua,
            p_int_table_id   => l_as_suarefcd_rec.LEGACY_SUAR_INT_ID
          );
          -- delete the interface record
          DELETE FROM igs_as_lgcy_suarc_int
          WHERE LEGACY_SUAR_INT_ID = l_as_suarefcd_rec.LEGACY_SUAR_INT_ID;
        ELSE
          l_last_updated_by        := get_last_updated_by;
          l_last_update_date       := get_last_update_date;
          l_last_update_login      := get_last_update_login;
          l_request_id             := get_request_id;
          l_program_application_id := get_program_application_id;
          l_program_id             := get_program_id;
          l_program_update_date    := get_program_update_date;
          UPDATE igs_as_lgcy_suarc_int
          SET import_status = DECODE(l_return_status,
                                     'S','I',
                                     'U','E',
                                     'W','W',
                                     'E'),
                last_update_date = l_last_update_date,
                last_updated_by = l_last_updated_by,
                last_update_login = l_last_update_login,
                request_id = l_request_id,
                program_id = l_program_id,
                program_application_id = l_program_application_id,
                program_update_date = l_program_update_date
          WHERE LEGACY_SUAR_INT_ID = l_as_suarefcd_rec.LEGACY_SUAR_INT_ID;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK TO savepoint_en_suarefcd;
      END;
    END LOOP;

    log_no_data_exists(l_not_found);

    -- This will commit the changes to the interface table record.
    -- if an error was encountered then all the unwanted changes
    -- would have been rolled back by the rollback to savepoint.
    COMMIT WORK;

  EXCEPTION
    WHEN g_resource_busy THEN
      log_resource_busy(g_cst_en_sua);
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igs_en_lgcy_prc.legacy_batch_process.process_as_suarc');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;


  END process_as_suarc;

  --- end as_suarc

  PROCEDURE process_en_spa(
              p_batch_id      IN NUMBER,
              p_deletion_flag IN BOOLEAN
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  kkillams        20-12-2002      Removed the if clause before calling "ROLLBACK TO savepoint_en_spa;"
  ||                                  which bybass the rollback if return status is 'W', w.r.t. bug no :2717455
  ------------------------------------------------------------------------------*/
    CURSOR c_en_spa IS
    SELECT *
    FROM igs_en_lgcy_spa_int
    WHERE batch_id = p_batch_id
    AND   import_status IN ('U','R')
    ORDER BY person_number ASC,
             NVL(key_program,'N') DESC,
             NVL(primary_program_type,'SECONDARY') ASC,
             commencement_dt ASC
    FOR UPDATE NOWAIT;


    lr_en_spa_rec   igs_en_spa_lgcy_pub.sca_re_rec_type;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER(4);
    l_msg_data      VARCHAR2(4000);

    l_last_update_date       DATE ;
    l_last_updated_by        NUMBER;
    l_last_update_login      NUMBER;
    l_request_id             NUMBER;
    l_program_id             NUMBER;
    l_program_application_id NUMBER;
    l_program_update_date    DATE;
    l_not_found              BOOLEAN;

  BEGIN
/*
   Process the records in the Student program attempt interface table
   where the import status is either 'U' - Unproccessed or 'R' ready for reporccessing

   The Order by Clause in the c_en_spa, orders the records in such a way that
   all key programs are processed first and within the key programs all primary
   programs are processed first.
*/
    -- log the header in the format shown below
    -- "Row Type    Student program Attempt"
    log_headers(g_cst_en_spa);
    l_not_found := TRUE;

    FOR l_en_spa_cur_rec IN c_en_spa LOOP
      BEGIN

        -- create a save point. if there are any errors returned by
        -- the API then rollback to this savepoint before processing
        -- then next record.
        SAVEPOINT savepoint_en_spa;
        l_not_found := FALSE;

        -- populate the record variable to pass to the API
        lr_en_spa_rec.person_number                 := l_en_spa_cur_rec.person_number ;
        lr_en_spa_rec.program_cd                    := l_en_spa_cur_rec.program_cd ;
        lr_en_spa_rec.version_number                := l_en_spa_cur_rec.version_number ;
        lr_en_spa_rec.cal_type                      := l_en_spa_cur_rec.cal_type ;
        lr_en_spa_rec.location_cd                   := l_en_spa_cur_rec.location_cd ;
        lr_en_spa_rec.attendance_mode               := l_en_spa_cur_rec.attendance_mode ;
        lr_en_spa_rec.attendance_type               := l_en_spa_cur_rec.attendance_type ;
        lr_en_spa_rec.student_confirmed_ind         := l_en_spa_cur_rec.student_confirmed_ind ;
        lr_en_spa_rec.commencement_dt               := l_en_spa_cur_rec.commencement_dt ;
        lr_en_spa_rec.primary_program_type          := l_en_spa_cur_rec.primary_program_type ;
        lr_en_spa_rec.primary_prog_type_source      := l_en_spa_cur_rec.primary_prog_type_source ;
        lr_en_spa_rec.key_program                   := l_en_spa_cur_rec.key_program ;
        lr_en_spa_rec.provisional_ind               := l_en_spa_cur_rec.provisional_ind ;
        lr_en_spa_rec.discontinued_dt               := l_en_spa_cur_rec.discontinued_dt ;
        lr_en_spa_rec.discontinuation_reason_cd     := l_en_spa_cur_rec.discontinuation_reason_cd ;
        lr_en_spa_rec.lapsed_dt                     := l_en_spa_cur_rec.lapsed_dt ;
        lr_en_spa_rec.funding_source                := l_en_spa_cur_rec.funding_source ;
        lr_en_spa_rec.exam_location_cd              := l_en_spa_cur_rec.exam_location_cd ;
        lr_en_spa_rec.nominated_completion_yr       := l_en_spa_cur_rec.nominated_completion_yr ;
        lr_en_spa_rec.nominated_completion_perd     := l_en_spa_cur_rec.nominated_completion_perd ;
        lr_en_spa_rec.rule_check_ind                := l_en_spa_cur_rec.rule_check_ind ;
        lr_en_spa_rec.waive_option_check_ind        := l_en_spa_cur_rec.waive_option_check_ind ;
        lr_en_spa_rec.last_rule_check_dt            := l_en_spa_cur_rec.last_rule_check_dt ;
        lr_en_spa_rec.publish_outcomes_ind          := l_en_spa_cur_rec.publish_outcomes_ind ;
        lr_en_spa_rec.course_rqrmnt_complete_ind    := l_en_spa_cur_rec.course_rqrmnt_complete_ind ;
        lr_en_spa_rec.course_rqrmnts_complete_dt    := l_en_spa_cur_rec.course_rqrmnts_complete_dt ;
        lr_en_spa_rec.s_completed_source_type       := l_en_spa_cur_rec.s_completed_source_type ;
        lr_en_spa_rec.advanced_standing_ind         := l_en_spa_cur_rec.advanced_standing_ind ;
        lr_en_spa_rec.fee_cat                       := l_en_spa_cur_rec.fee_cat ;
        lr_en_spa_rec.correspondence_cat            := l_en_spa_cur_rec.correspondence_cat ;
        lr_en_spa_rec.self_help_group_ind           := l_en_spa_cur_rec.self_help_group_ind ;
        lr_en_spa_rec.adm_admission_appl_number     := l_en_spa_cur_rec.adm_admission_appl_number ;
        lr_en_spa_rec.adm_nominated_course_cd       := l_en_spa_cur_rec.adm_nominated_course_cd ;
        lr_en_spa_rec.adm_sequence_number           := l_en_spa_cur_rec.adm_sequence_number ;
        lr_en_spa_rec.class_standing_override       := l_en_spa_cur_rec.class_standing_override ;
        lr_en_spa_rec.catalog_cal_alternate_code    := l_en_spa_cur_rec.catalog_cal_alternate_code ;
        lr_en_spa_rec.override_cmpl_dt              := l_en_spa_cur_rec.override_cmpl_dt ;
        lr_en_spa_rec.manual_ovr_cmpl_dt_ind        := l_en_spa_cur_rec.manual_ovr_cmpl_dt_ind ;
        lr_en_spa_rec.attribute_category            := l_en_spa_cur_rec.attribute_category ;
        lr_en_spa_rec.attribute1                    := l_en_spa_cur_rec.attribute1 ;
        lr_en_spa_rec.attribute2                    := l_en_spa_cur_rec.attribute2 ;
        lr_en_spa_rec.attribute3                    := l_en_spa_cur_rec.attribute3 ;
        lr_en_spa_rec.attribute4                    := l_en_spa_cur_rec.attribute4 ;
        lr_en_spa_rec.attribute5                    := l_en_spa_cur_rec.attribute5 ;
        lr_en_spa_rec.attribute6                    := l_en_spa_cur_rec.attribute6 ;
        lr_en_spa_rec.attribute7                    := l_en_spa_cur_rec.attribute7 ;
        lr_en_spa_rec.attribute8                    := l_en_spa_cur_rec.attribute8 ;
        lr_en_spa_rec.attribute9                    := l_en_spa_cur_rec.attribute9 ;
        lr_en_spa_rec.attribute10                   := l_en_spa_cur_rec.attribute10 ;
        lr_en_spa_rec.attribute11                   := l_en_spa_cur_rec.attribute11 ;
        lr_en_spa_rec.attribute12                   := l_en_spa_cur_rec.attribute12 ;
        lr_en_spa_rec.attribute13                   := l_en_spa_cur_rec.attribute13 ;
        lr_en_spa_rec.attribute14                   := l_en_spa_cur_rec.attribute14 ;
        lr_en_spa_rec.attribute15                   := l_en_spa_cur_rec.attribute15 ;
        lr_en_spa_rec.attribute16                   := l_en_spa_cur_rec.attribute16 ;
        lr_en_spa_rec.attribute17                   := l_en_spa_cur_rec.attribute17 ;
        lr_en_spa_rec.attribute18                   := l_en_spa_cur_rec.attribute18 ;
        lr_en_spa_rec.attribute19                   := l_en_spa_cur_rec.attribute19 ;
        lr_en_spa_rec.attribute20                   := l_en_spa_cur_rec.attribute20 ;
        lr_en_spa_rec.re_attendance_percentage      := l_en_spa_cur_rec.re_attendance_percentage ;
        lr_en_spa_rec.re_govt_type_of_activity_cd   := l_en_spa_cur_rec.re_govt_type_of_activity_cd ;
        lr_en_spa_rec.re_max_submission_dt          := l_en_spa_cur_rec.re_max_submission_dt ;
        lr_en_spa_rec.re_min_submission_dt          := l_en_spa_cur_rec.re_min_submission_dt ;
        lr_en_spa_rec.re_research_topic             := l_en_spa_cur_rec.re_research_topic ;
        lr_en_spa_rec.re_industry_links             := l_en_spa_cur_rec.re_industry_links ;

        l_return_status := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;
        igs_en_spa_lgcy_pub.create_spa(
                      P_API_VERSION      => 1.0,
                      P_INIT_MSG_LIST    => FND_API.G_TRUE,
                      P_COMMIT           => FND_API.G_FALSE,
                      P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                      P_SCA_RE_REC       => lr_en_spa_rec,
                      X_RETURN_STATUS    => l_return_status,
                      X_MSG_COUNT        => l_msg_count,
                      X_MSG_DATA         => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_return_status IS NULL THEN
           ROLLBACK TO savepoint_en_spa;
           -- log the error message in the error message interface table
           log_err_messages(
                            g_cst_en_spa,
                            l_en_spa_cur_rec.legacy_en_spa_int_id,
                            l_msg_count,
                            l_msg_data,
                            l_return_status);
        ELSE
          -- log the warning messages in the concurrent manager log.
          -- spa is a special case since the program attempt may not insert since
          -- that record is already present hence return a warning and the thesis details
          -- would have to be inserted or visa versa.
          IF l_msg_count > 0 THEN
           log_err_messages(
                            g_cst_en_spa,
                            l_en_spa_cur_rec.legacy_en_spa_int_id,
                            l_msg_count,
                            l_msg_data,
                            'W');
          END IF;
          -- log the success message in the concurrent manager log.
          log_suc_message(l_en_spa_cur_rec.legacy_en_spa_int_id);
        END IF;

        IF p_deletion_flag AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          -- delete any records in the error message interface table
          delete_err_messages(
            p_int_table_code => g_cst_en_spa,
            p_int_table_id   => l_en_spa_cur_rec.legacy_en_spa_int_id
          );
          -- delete the interface record
          DELETE FROM igs_en_lgcy_spa_int
          WHERE  legacy_en_spa_int_id  = l_en_spa_cur_rec.legacy_en_spa_int_id;
        ELSE
          l_last_updated_by        := get_last_updated_by;
          l_last_update_date       := get_last_update_date;
          l_last_update_login      := get_last_update_login;
          l_request_id             := get_request_id;
          l_program_application_id := get_program_application_id;
          l_program_id             := get_program_id;
          l_program_update_date    := get_program_update_date;
          UPDATE igs_en_lgcy_spa_int
          SET import_status = DECODE(l_return_status,
                                     'S','I',
                                     'U','E',
                                     'W','W',
                                     'E'),
                last_update_date = l_last_update_date,
                last_updated_by = l_last_updated_by,
                last_update_login = l_last_update_login,
                request_id = l_request_id,
                program_id = l_program_id,
                program_application_id = l_program_application_id,
                program_update_date = l_program_update_date
          WHERE  legacy_en_spa_int_id  = l_en_spa_cur_rec.legacy_en_spa_int_id;
        END IF;

      EXCEPTION -- for the begin end block with in the For loop
        WHEN OTHERS THEN
        ROLLBACK TO savepoint_en_spa;
      END;
    END LOOP;

    log_no_data_exists(l_not_found);

    -- This will commit the changes to the interface table record.
    -- if an error was encountered then all the unwanted changes
    -- would have been rolled back by the rollback to savepoint.
    COMMIT WORK;

  EXCEPTION
    WHEN g_resource_busy THEN
      log_resource_busy(g_cst_en_spa);
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igs_en_lgcy_prc.legacy_batch_process.process_en_spa');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END process_en_spa;


-------------------------------------------------------------------------------------
PROCEDURE process_en_spat(
        p_batch_id              IN      NUMBER,
        p_deletion_flag         IN      BOOLEAN) AS
/*----------------------------------------------------------------------------
||  Created By : vkarthik
||  Created On : 5/Dec/2003
||  Purpose : to proces term records from the interface table
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||
------------------------------------------------------------------------------*/

CURSOR c_lgy_spat_int IS
-- cursor to pick out all records with input batch_id and status = 'ready or unprocessed'
        SELECT * FROM igs_en_lgy_spat_int
        WHERE
                batch_id        =       p_batch_id      AND
                import_status   IN      ('U', 'R')
        ORDER BY
                person_number ASC,
                program_cd ASC,
                legacy_en_spat_int_id ASC
        FOR UPDATE NOWAIT;

l_not_found                     BOOLEAN;
l_return_status                 VARCHAR2(1);
l_msg_count                     NUMBER(4);
l_msg_data                      VARCHAR2(4000);
p_spat_rec                      igs_en_spat_lgcy_pub.spat_rec_type;
l_last_updated_by               NUMBER;
l_last_update_date              DATE;
l_last_update_login             NUMBER;
l_request_id                    NUMBER;
l_program_application_id        NUMBER;
l_program_id                    NUMBER;
l_program_update_date           DATE;

BEGIN
        log_headers(g_cst_en_spat);
        l_not_found     :=      TRUE;
        FOR lc_lgy_spat_int IN c_lgy_spat_int
        LOOP
        BEGIN
                -- create a savepoint so that in case of error, the state can be rolled back
                SAVEPOINT process_en_spat_save;
                l_not_found                     :=      FALSE;
                -- populate the record variable to pass to the api
                p_spat_rec.person_number        :=      lc_lgy_spat_int.person_number;
                p_spat_rec.program_cd           :=      lc_lgy_spat_int.program_cd;
                p_spat_rec.program_version      :=      lc_lgy_spat_int.program_version;
                p_spat_rec.key_program_flag     :=      lc_lgy_spat_int.key_program_flag;
                p_spat_rec.acad_cal_type        :=      lc_lgy_spat_int.acad_cal_type;
                p_spat_rec.location_cd          :=      lc_lgy_spat_int.location_cd;
                p_spat_rec.attendance_mode      :=      lc_lgy_spat_int.attendance_mode;
                p_spat_rec.attendance_type      :=      lc_lgy_spat_int.attendance_type;
                p_spat_rec.class_standing       :=      lc_lgy_spat_int.class_standing;
                p_spat_rec.fee_cat              :=      lc_lgy_spat_int.fee_cat;
                p_spat_rec.term_cal_alternate_cd:=      lc_lgy_spat_int.term_cal_alternate_cd;
                p_spat_rec.attribute_category   :=      lc_lgy_spat_int.attribute_category;
                p_spat_rec.attribute1           :=      lc_lgy_spat_int.attribute1;
                p_spat_rec.attribute2           :=      lc_lgy_spat_int.attribute2;
                p_spat_rec.attribute3           :=      lc_lgy_spat_int.attribute3;
                p_spat_rec.attribute4           :=      lc_lgy_spat_int.attribute4;
                p_spat_rec.attribute5           :=      lc_lgy_spat_int.attribute5;
                p_spat_rec.attribute6           :=      lc_lgy_spat_int.attribute6;
                p_spat_rec.attribute7           :=      lc_lgy_spat_int.attribute7;
                p_spat_rec.attribute8           :=      lc_lgy_spat_int.attribute8;
                p_spat_rec.attribute9           :=      lc_lgy_spat_int.attribute9;
                p_spat_rec.attribute10          :=      lc_lgy_spat_int.attribute10;
                p_spat_rec.attribute11          :=      lc_lgy_spat_int.attribute11;
                p_spat_rec.attribute12          :=      lc_lgy_spat_int.attribute12;
                p_spat_rec.attribute13          :=      lc_lgy_spat_int.attribute13;
                p_spat_rec.attribute14          :=      lc_lgy_spat_int.attribute14;
                p_spat_rec.attribute15          :=      lc_lgy_spat_int.attribute15;
                p_spat_rec.attribute16          :=      lc_lgy_spat_int.attribute16;
                p_spat_rec.attribute17          :=      lc_lgy_spat_int.attribute17;
                p_spat_rec.attribute18          :=      lc_lgy_spat_int.attribute18;
                p_spat_rec.attribute19          :=      lc_lgy_spat_int.attribute19;
                p_spat_rec.attribute20          :=      lc_lgy_spat_int.attribute20;

                l_return_status         :=      NULL;
                l_msg_count             :=      NULL;
                l_msg_data              :=      NULL;

                -- begin processing the record
                igs_en_spat_lgcy_pub.create_spa_t (
                        p_api_version           =>      1.0,
                        p_init_msg_list         =>      FND_API.G_TRUE,
                        p_commit                =>      FND_API.G_FALSE,
                        p_validation_level      =>      FND_API.G_VALID_LEVEL_FULL,
                        p_spat_rec              =>      p_spat_rec,
                        x_return_status         =>      l_return_status,
                        x_msg_count             =>      l_msg_count,
                        x_msg_data              =>      l_msg_data );

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR
                   l_return_status IS NULL         THEN
                         -- rollback due to failure
                        ROLLBACK TO process_en_spat_save;
                        -- logging error messages
                        log_err_messages (
                                g_cst_en_spat,
                                lc_lgy_spat_int.legacy_en_spat_int_id,
                                l_msg_count,
                                l_msg_data,
                                l_return_status);
                ELSE
                   --logging success message
                   log_suc_message(lc_lgy_spat_int.legacy_en_spat_int_id);
                END IF;

                IF p_deletion_flag AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                        -- delete error messages and record from spat if flag set and the process, a success
                        delete_err_messages (
                                p_int_table_code        =>      g_cst_en_spat,
                                p_int_table_id          =>      lc_lgy_spat_int.legacy_en_spat_int_id );
                        DELETE FROM igs_en_lgy_spat_int
                                WHERE legacy_en_spat_int_id = lc_lgy_spat_int.legacy_en_spat_int_id;
                ELSE
                        -- get values for WHO columns
                        l_last_updated_by       :=      get_last_updated_by;
                        l_last_update_date      :=      get_last_update_date;
                        l_last_update_login     :=      get_last_update_login;
                        l_request_id            :=      get_request_id;
                        l_program_id            :=      get_program_id;
                        l_program_application_id:=      get_program_application_id;
                        l_program_update_date   :=      get_program_update_date;
                        UPDATE igs_en_lgy_spat_int
                                SET     import_status           =
                                                DECODE (l_return_status, 'S', 'I',
                                                                         'U', 'E',
                                                                         'W', 'W',
                                                                         'E'),
                                        last_updated_by         =       l_last_updated_by,
                                        last_update_date        =       l_last_update_date,
                                        last_update_login       =       l_last_update_login,
                                        request_id              =       l_request_id,
                                        program_id              =       l_program_id,
                                        program_application_id  =       l_program_application_id,
                                        program_update_date     =       l_program_update_date
                                WHERE
                                        legacy_en_spat_int_id  =       lc_lgy_spat_int.legacy_en_spat_int_id;
                END IF;

        EXCEPTION
                WHEN OTHERS THEN
                        ROLLBACK TO process_en_spat_save;

        END;
        END LOOP;
        log_no_data_exists(l_not_found);
        COMMIT WORK;

        EXCEPTION
                WHEN g_resource_busy THEN
                        log_resource_busy(g_cst_en_spat);
                WHEN OTHERS THEN
                        FND_MESSAGE.SET_NAME ('IGS', 'IGS_GE_UNHANDLED_EXP');
                        FND_MESSAGE.SET_TOKEN ('NAME', 'IGS_EN_LGCY_PRC.LEGACY_BATCH_PROCESS.PROCESS_EN_SPAT');
                        IGS_GE_MSG_STACK.ADD;
                        APP_EXCEPTION.RAISE_EXCEPTION;
END process_en_spat;

-------------------------------------------------------------------------------

  PROCEDURE process_en_susa(
              p_batch_id      IN NUMBER,
              p_deletion_flag IN BOOLEAN
  ) AS
    CURSOR c_en_susa IS
    SELECT *
    FROM igs_en_lgy_susa_int
    WHERE batch_id = p_batch_id
    AND   import_status IN ('U','R')
    ORDER BY person_number ASC,
             program_cd ASC
    FOR UPDATE NOWAIT;


    lr_en_susa_rec  igs_en_susa_lgcy_pub.susa_rec_type ;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER(4);
    l_msg_data      VARCHAR2(4000);

    l_last_update_date       DATE ;
    l_last_updated_by        NUMBER;
    l_last_update_login      NUMBER;
    l_request_id             NUMBER;
    l_program_id             NUMBER;
    l_program_application_id NUMBER;
    l_program_update_date    DATE;
    l_not_found              BOOLEAN;

  BEGIN
/*
   Process the records in the Student Unit Set attempt interface table
   where the import status is either 'U' - Unproccessed or 'R' ready for reporccessing
*/


    log_headers(g_cst_en_susa);
    l_not_found := TRUE;

    FOR l_en_susa_cur_rec IN c_en_susa LOOP
      BEGIN

        -- create a save point. if there are any errors returned by
        -- the API then rollback to this savepoint before processing
        -- then next record.
        SAVEPOINT savepoint_en_susa;
        l_not_found := FALSE;

        -- populate the record variable to pass to the API
        lr_en_susa_rec.person_number                 := l_en_susa_cur_rec.person_number ;
        lr_en_susa_rec.program_cd                    := l_en_susa_cur_rec.program_cd ;
        lr_en_susa_rec.unit_set_cd                   := l_en_susa_cur_rec.unit_set_cd ;
        lr_en_susa_rec.us_version_number             := l_en_susa_cur_rec.us_version_number ;
        lr_en_susa_rec.selection_dt                  := l_en_susa_cur_rec.selection_dt ;
        lr_en_susa_rec.student_confirmed_ind         := l_en_susa_cur_rec.student_confirmed_ind ;
        lr_en_susa_rec.end_dt                        := l_en_susa_cur_rec.end_dt ;
        lr_en_susa_rec.parent_unit_set_cd            := l_en_susa_cur_rec.parent_unit_set_cd ;
        lr_en_susa_rec.primary_set_ind               := l_en_susa_cur_rec.primary_set_ind ;
        lr_en_susa_rec.voluntary_end_ind             := l_en_susa_cur_rec.voluntary_end_ind ;
        lr_en_susa_rec.authorised_person_number      := l_en_susa_cur_rec.authorised_person_number ;
        lr_en_susa_rec.authorised_on                 := l_en_susa_cur_rec.authorised_on ;
        lr_en_susa_rec.override_title                := l_en_susa_cur_rec.override_title ;
        lr_en_susa_rec.rqrmnts_complete_ind          := l_en_susa_cur_rec.rqrmnts_complete_ind ;
        lr_en_susa_rec.rqrmnts_complete_dt           := l_en_susa_cur_rec.rqrmnts_complete_dt ;
        lr_en_susa_rec.s_completed_source_type       := l_en_susa_cur_rec.s_completed_source_type ;
        lr_en_susa_rec.catalog_cal_alternate_code    := l_en_susa_cur_rec.catalog_cal_alternate_code ;
        lr_en_susa_rec.attribute_category            := l_en_susa_cur_rec.attribute_category ;
        lr_en_susa_rec.attribute1                    := l_en_susa_cur_rec.attribute1 ;
        lr_en_susa_rec.attribute2                    := l_en_susa_cur_rec.attribute2 ;
        lr_en_susa_rec.attribute3                    := l_en_susa_cur_rec.attribute3 ;
        lr_en_susa_rec.attribute4                    := l_en_susa_cur_rec.attribute4 ;
        lr_en_susa_rec.attribute5                    := l_en_susa_cur_rec.attribute5 ;
        lr_en_susa_rec.attribute6                    := l_en_susa_cur_rec.attribute6 ;
        lr_en_susa_rec.attribute7                    := l_en_susa_cur_rec.attribute7 ;
        lr_en_susa_rec.attribute8                    := l_en_susa_cur_rec.attribute8 ;
        lr_en_susa_rec.attribute9                    := l_en_susa_cur_rec.attribute9 ;
        lr_en_susa_rec.attribute10                   := l_en_susa_cur_rec.attribute10 ;
        lr_en_susa_rec.attribute11                   := l_en_susa_cur_rec.attribute11 ;
        lr_en_susa_rec.attribute12                   := l_en_susa_cur_rec.attribute12 ;
        lr_en_susa_rec.attribute13                   := l_en_susa_cur_rec.attribute13 ;
        lr_en_susa_rec.attribute14                   := l_en_susa_cur_rec.attribute14 ;
        lr_en_susa_rec.attribute15                   := l_en_susa_cur_rec.attribute15 ;
        lr_en_susa_rec.attribute16                   := l_en_susa_cur_rec.attribute16 ;
        lr_en_susa_rec.attribute17                   := l_en_susa_cur_rec.attribute17 ;
        lr_en_susa_rec.attribute18                   := l_en_susa_cur_rec.attribute18 ;
        lr_en_susa_rec.attribute19                   := l_en_susa_cur_rec.attribute19 ;
        lr_en_susa_rec.attribute20                   := l_en_susa_cur_rec.attribute20 ;


        l_return_status := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;
        igs_en_susa_lgcy_pub.create_unit_set_atmpt(
                      P_API_VERSION      => 1.0,
                      P_INIT_MSG_LIST    => FND_API.G_TRUE,
                      P_COMMIT           => FND_API.G_FALSE,
                      P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                      p_susa_rec             => lr_en_susa_rec,
                      X_RETURN_STATUS    => l_return_status,
                      X_MSG_COUNT        => l_msg_count,
                      X_MSG_DATA         => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_return_status IS NULL THEN
           ROLLBACK TO savepoint_en_susa;
           -- log the error message in the error message interface table
           log_err_messages(
             g_cst_en_susa ,
             l_en_susa_cur_rec.legacy_en_susa_int_id,
             l_msg_count,
             l_msg_data,
             l_return_status
           );
        ELSE
          -- log the success message in the concurrent manager log.
          log_suc_message(l_en_susa_cur_rec.legacy_en_susa_int_id);
        END IF;

        IF p_deletion_flag AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          -- delete any records in the error message interface table
          delete_err_messages(
             p_int_table_code => g_cst_en_susa,
             p_int_table_id   => l_en_susa_cur_rec.legacy_en_susa_int_id
          );
          -- delete the interface record
          DELETE FROM igs_en_lgy_susa_int
          WHERE  legacy_en_susa_int_id  = l_en_susa_cur_rec.legacy_en_susa_int_id;
        ELSE
          l_last_updated_by        := get_last_updated_by;
          l_last_update_date       := get_last_update_date;
          l_last_update_login      := get_last_update_login;
          l_request_id             := get_request_id;
          l_program_application_id := get_program_application_id;
          l_program_id             := get_program_id;
          l_program_update_date    := get_program_update_date;
          UPDATE igs_en_lgy_susa_int
          SET import_status = DECODE(l_return_status,
                                     'S','I',
                                     'U','E',
                                     'W','W',
                                     'E'),
                last_update_date = l_last_update_date,
                last_updated_by = l_last_updated_by,
                last_update_login = l_last_update_login,
                request_id = l_request_id,
                program_id = l_program_id,
                program_application_id = l_program_application_id,
                program_update_date = l_program_update_date
          WHERE  legacy_en_susa_int_id  = l_en_susa_cur_rec.legacy_en_susa_int_id;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK TO savepoint_en_susa;
      END;
    END LOOP;

    log_no_data_exists(l_not_found);

    -- This will commit the changes to the interface table record.
    -- if an error was encountered then all the unwanted changes
    -- would have been rolled back by the rollback to savepoint.
    COMMIT WORK;

  EXCEPTION
    WHEN g_resource_busy THEN
      log_resource_busy(g_cst_en_susa);
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igs_en_lgcy_prc.legacy_batch_process.process_en_susa');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END process_en_susa;



-------------------------------------------------------------------------------
  PROCEDURE process_en_spi(
              p_batch_id      IN NUMBER,
              p_deletion_flag IN BOOLEAN
  ) AS
    CURSOR c_en_spi IS
    SELECT *
    FROM igs_en_lgcy_spi_int
    WHERE batch_id = p_batch_id
    AND   import_status IN ('U','R')
    ORDER BY person_number ASC,
             program_cd ASC
    FOR UPDATE NOWAIT;


    lr_en_spi_rec    igs_en_spi_lgcy_pub.en_spi_rec_type  ;
    l_return_status  VARCHAR2(1);
    l_msg_count      NUMBER(4);
    l_msg_data       VARCHAR2(4000);

    l_last_update_date       DATE ;
    l_last_updated_by        NUMBER;
    l_last_update_login      NUMBER;
    l_request_id             NUMBER;
    l_program_id             NUMBER;
    l_program_application_id NUMBER;
    l_program_update_date    DATE;
    l_not_found              BOOLEAN;

  BEGIN
/*
   Process the records in the Student program intermission interface table
   where the import status is either 'U' - Unproccessed or 'R' ready for reporccessing
*/

    log_headers(g_cst_en_spi);
    l_not_found := TRUE;

    FOR l_en_spi_cur_rec IN c_en_spi LOOP
      BEGIN

        -- create a save point. if there are any errors returned by
        -- the API then rollback to this savepoint before processing
        -- then next record.
        SAVEPOINT savepoint_en_spi;
        l_not_found := FALSE;

        -- populate the record variable to pass to the API
        lr_en_spi_rec.person_number                 := l_en_spi_cur_rec.person_number ;
        lr_en_spi_rec.program_cd                    := l_en_spi_cur_rec.program_cd ;
        lr_en_spi_rec.start_dt                      := l_en_spi_cur_rec.start_dt ;
        lr_en_spi_rec.end_dt                        := l_en_spi_cur_rec.end_dt ;
        lr_en_spi_rec.voluntary_ind                 := l_en_spi_cur_rec.voluntary_ind ;
        lr_en_spi_rec.comments                      := l_en_spi_cur_rec.comments ;
        lr_en_spi_rec.intermission_type             := l_en_spi_cur_rec.intermission_type ;
        lr_en_spi_rec.approved                      := l_en_spi_cur_rec.approved ;
        lr_en_spi_rec.institution_name              := l_en_spi_cur_rec.institution_name ;
        lr_en_spi_rec.max_credit_pts                := l_en_spi_cur_rec.max_credit_pts ;
        lr_en_spi_rec.max_terms                     := l_en_spi_cur_rec.max_terms ;
        lr_en_spi_rec.anticipated_credit_points     := l_en_spi_cur_rec.anticipated_credit_points ;
        lr_en_spi_rec.approver_person_number        := l_en_spi_cur_rec.approver_person_number ;
        lr_en_spi_rec.attribute_category            := l_en_spi_cur_rec.attribute_category ;
        lr_en_spi_rec.attribute1                    := l_en_spi_cur_rec.attribute1 ;
        lr_en_spi_rec.attribute2                    := l_en_spi_cur_rec.attribute2 ;
        lr_en_spi_rec.attribute3                    := l_en_spi_cur_rec.attribute3 ;
        lr_en_spi_rec.attribute4                    := l_en_spi_cur_rec.attribute4 ;
        lr_en_spi_rec.attribute5                    := l_en_spi_cur_rec.attribute5 ;
        lr_en_spi_rec.attribute6                    := l_en_spi_cur_rec.attribute6 ;
        lr_en_spi_rec.attribute7                    := l_en_spi_cur_rec.attribute7 ;
        lr_en_spi_rec.attribute8                    := l_en_spi_cur_rec.attribute8 ;
        lr_en_spi_rec.attribute9                    := l_en_spi_cur_rec.attribute9 ;
        lr_en_spi_rec.attribute10                   := l_en_spi_cur_rec.attribute10 ;
        lr_en_spi_rec.attribute11                   := l_en_spi_cur_rec.attribute11 ;
        lr_en_spi_rec.attribute12                   := l_en_spi_cur_rec.attribute12 ;
        lr_en_spi_rec.attribute13                   := l_en_spi_cur_rec.attribute13 ;
        lr_en_spi_rec.attribute14                   := l_en_spi_cur_rec.attribute14 ;
        lr_en_spi_rec.attribute15                   := l_en_spi_cur_rec.attribute15 ;
        lr_en_spi_rec.attribute16                   := l_en_spi_cur_rec.attribute16 ;
        lr_en_spi_rec.attribute17                   := l_en_spi_cur_rec.attribute17 ;
        lr_en_spi_rec.attribute18                   := l_en_spi_cur_rec.attribute18 ;
        lr_en_spi_rec.attribute19                   := l_en_spi_cur_rec.attribute19 ;
        lr_en_spi_rec.attribute20                   := l_en_spi_cur_rec.attribute20 ;
        lr_en_spi_rec.COND_RETURN_FLAG               := l_en_spi_cur_rec.cond_return_flag;


        l_return_status := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;
        igs_en_spi_lgcy_pub.create_student_intm(
                      P_API_VERSION      => 1.0,
                      P_INIT_MSG_LIST    => FND_API.G_TRUE,
                      P_COMMIT           => FND_API.G_FALSE,
                      P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                      p_intermiss_rec    => lr_en_spi_rec,
                      X_RETURN_STATUS    => l_return_status,
                      X_MSG_COUNT        => l_msg_count,
                      X_MSG_DATA         => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_return_status IS NULL THEN
           ROLLBACK TO savepoint_en_spi;
           -- log the error message in the error message interface table
           log_err_messages(
             g_cst_en_spi   ,
             l_en_spi_cur_rec.legacy_en_spi_int_id,
             l_msg_count,
             l_msg_data,
             l_return_status
           );
        ELSE
          -- log the success message in the concurrent manager log.
          log_suc_message(l_en_spi_cur_rec.legacy_en_spi_int_id );
        END IF;

        IF p_deletion_flag AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          -- delete any records in the error message interface table
          delete_err_messages(
            p_int_table_code => g_cst_en_spi,
            p_int_table_id   => l_en_spi_cur_rec.legacy_en_spi_int_id
          );

          -- delete the interface record
          DELETE FROM igs_en_lgcy_spi_int
          WHERE   legacy_en_spi_int_id  = l_en_spi_cur_rec.legacy_en_spi_int_id  ;
        ELSE
          l_last_updated_by        := get_last_updated_by;
          l_last_update_date       := get_last_update_date;
          l_last_update_login      := get_last_update_login;
          l_request_id             := get_request_id;
          l_program_application_id := get_program_application_id;
          l_program_id             := get_program_id;
          l_program_update_date    := get_program_update_date;
          UPDATE igs_en_lgcy_spi_int
          SET import_status = DECODE(l_return_status,
                                     'S','I',
                                     'U','E',
                                     'W','W',
                                     'E'),
                last_update_date = l_last_update_date,
                last_updated_by = l_last_updated_by,
                last_update_login = l_last_update_login,
                request_id = l_request_id,
                program_id = l_program_id,
                program_application_id = l_program_application_id,
                program_update_date = l_program_update_date
          WHERE  legacy_en_spi_int_id  = l_en_spi_cur_rec.legacy_en_spi_int_id  ;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK TO savepoint_en_spi;
      END;
    END LOOP;

    log_no_data_exists(l_not_found);

    -- This will commit the changes to the interface table record.
    -- if an error was encountered then all the unwanted changes
    -- would have been rolled back by the rollback to savepoint.
    COMMIT WORK;

  EXCEPTION
    WHEN g_resource_busy THEN
      log_resource_busy(g_cst_en_spi);
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igs_en_lgcy_prc.legacy_batch_process.process_en_spi');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END process_en_spi;


-------------------------------------------------------------------------------
  --anilk, modified as per Program Completion Validation build, Bug# 3129913
  PROCEDURE process_en_spaa(
              p_batch_id      IN NUMBER,
              p_deletion_flag IN BOOLEAN
  ) AS
    CURSOR c_en_spaa IS
    SELECT *
    FROM igs_en_lgy_spaa_int
    WHERE batch_id = p_batch_id
    AND   import_status IN ('U','R')
    ORDER BY person_number ASC,
             program_cd ASC
    FOR UPDATE NOWAIT;


    lr_en_spaa_rec   igs_en_spaa_lgcy_pub.awd_aim_rec_type;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER(4);
    l_msg_data      VARCHAR2(4000);

    l_last_update_date       DATE ;
    l_last_updated_by        NUMBER;
    l_last_update_login      NUMBER;
    l_request_id             NUMBER;
    l_program_id             NUMBER;
    l_program_application_id NUMBER;
    l_program_update_date    DATE;
    l_not_found              BOOLEAN;

  BEGIN
/*
   Process the records in the Student program award aim interface table
   where the import status is either 'U' - Unproccessed or 'R' ready for reporccessing
*/


    log_headers(g_cst_en_spaa);
    l_not_found := TRUE;

    FOR l_en_spaa_cur_rec IN c_en_spaa LOOP
      BEGIN

        -- create a save point. if there are any errors returned by
        -- the API then rollback to this savepoint before processing
        -- then next record.
        SAVEPOINT savepoint_en_spaa;
        l_not_found := FALSE;

        -- populate the record variable to pass to the API
        lr_en_spaa_rec.person_number         := l_en_spaa_cur_rec.person_number ;
        lr_en_spaa_rec.program_cd            := l_en_spaa_cur_rec.program_cd ;
        lr_en_spaa_rec.award_cd              := l_en_spaa_cur_rec.award_cd ;
        lr_en_spaa_rec.start_dt              := l_en_spaa_cur_rec.start_dt ;
        lr_en_spaa_rec.end_dt                := l_en_spaa_cur_rec.end_dt ;
        lr_en_spaa_rec.complete_ind          := l_en_spaa_cur_rec.complete_ind ;
        lr_en_spaa_rec.conferral_dt          := l_en_spaa_cur_rec.conferral_dt ;
        lr_en_spaa_rec.award_mark            := l_en_spaa_cur_rec.award_mark        ;
        lr_en_spaa_rec.award_grade           := l_en_spaa_cur_rec.award_grade       ;
        lr_en_spaa_rec.grading_schema_cd     := l_en_spaa_cur_rec.grading_schema_cd ;
        lr_en_spaa_rec.gs_version_number     := l_en_spaa_cur_rec.gs_version_number ;


        l_return_status := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;
        igs_en_spaa_lgcy_pub.create_student_awd_aim(
                      P_API_VERSION      => 1.0,
                      P_INIT_MSG_LIST    => FND_API.G_TRUE,
                      P_COMMIT           => FND_API.G_FALSE,
                      P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                      p_awd_aim_rec      => lr_en_spaa_rec,
                      X_RETURN_STATUS    => l_return_status,
                      X_MSG_COUNT        => l_msg_count,
                      X_MSG_DATA         => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_return_status IS NULL THEN
           ROLLBACK TO savepoint_en_spaa;
           -- log the error message in the error message interface table
           log_err_messages(
             g_cst_en_spaa,
             l_en_spaa_cur_rec.legacy_en_spaa_int_id,
             l_msg_count,
             l_msg_data,
             l_return_status
           );
        ELSE
          -- log the success message in the concurrent manager log.
          log_suc_message(l_en_spaa_cur_rec.legacy_en_spaa_int_id);
        END IF;

        IF p_deletion_flag AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          -- delete any records in the error message interface table
          delete_err_messages(
            p_int_table_code => g_cst_en_spaa,
            p_int_table_id   => l_en_spaa_cur_rec.legacy_en_spaa_int_id
          );
          -- delete the interface record
          DELETE FROM igs_en_lgy_spaa_int
          WHERE legacy_en_spaa_int_id =  l_en_spaa_cur_rec.legacy_en_spaa_int_id;
        ELSE
          l_last_updated_by        := get_last_updated_by;
          l_last_update_date       := get_last_update_date;
          l_last_update_login      := get_last_update_login;
          l_request_id             := get_request_id;
          l_program_application_id := get_program_application_id;
          l_program_id             := get_program_id;
          l_program_update_date    := get_program_update_date;
          UPDATE igs_en_lgy_spaa_int
          SET import_status = DECODE(l_return_status,
                                     'S','I',
                                     'U','E',
                                     'W','W',
                                     'E'),
                last_update_date = l_last_update_date,
                last_updated_by = l_last_updated_by,
                last_update_login = l_last_update_login,
                request_id = l_request_id,
                program_id = l_program_id,
                program_application_id = l_program_application_id,
                program_update_date = l_program_update_date
          WHERE legacy_en_spaa_int_id =  l_en_spaa_cur_rec.legacy_en_spaa_int_id;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK TO savepoint_en_spaa;
      END;
    END LOOP;

    log_no_data_exists(l_not_found);

    -- This will commit the changes to the interface table record.
    -- if an error was encountered then all the unwanted changes
    -- would have been rolled back by the rollback to savepoint.
    COMMIT WORK;

  EXCEPTION
    WHEN g_resource_busy THEN
      log_resource_busy(g_cst_en_spaa);
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igs_en_lgcy_prc.legacy_batch_process.process_en_spaa');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END process_en_spaa;



-------------------------------------------------------------------------------
  PROCEDURE process_re_sprvsr(
              p_batch_id      IN NUMBER,
              p_deletion_flag IN BOOLEAN
  ) AS
    CURSOR c_re_sprvsr IS
    SELECT *
    FROM igs_re_lgcy_spr_int
    WHERE batch_id = p_batch_id
    AND   import_status IN ('U','R')
    ORDER BY ca_person_number ASC,
             START_DT ASC
    FOR UPDATE NOWAIT;


    lr_re_sprvsr_rec   igs_re_sprvsr_lgcy_pub.sprvsr_dtls_rec_type;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER(4);
    l_msg_data      VARCHAR2(4000);

    l_last_update_date       DATE ;
    l_last_updated_by        NUMBER;
    l_last_update_login      NUMBER;
    l_request_id             NUMBER;
    l_program_id             NUMBER;
    l_program_application_id NUMBER;
    l_program_update_date    DATE;
    l_not_found              BOOLEAN;

  BEGIN
/*
   Process the records in the Research Supervisor interface table
   where the import status is either 'U' - Unproccessed or 'R' ready for reporccessing
*/

    log_headers(g_cst_re_sprvsr);
    l_not_found := TRUE;

    FOR l_re_sprvsr_cur_rec IN c_re_sprvsr LOOP
      BEGIN

        -- create a save point. if there are any errors returned by
        -- the API then rollback to this savepoint before processing
        -- then next record.
        SAVEPOINT savepoint_re_sprvsr;
        l_not_found := FALSE;

        -- populate the record variable to pass to the API
        lr_re_sprvsr_rec.ca_person_number              := l_re_sprvsr_cur_rec.ca_person_number ;
        lr_re_sprvsr_rec.program_cd                    := l_re_sprvsr_cur_rec.program_cd ;
        lr_re_sprvsr_rec.person_number                 := l_re_sprvsr_cur_rec.person_number ;
        lr_re_sprvsr_rec.start_dt                      := l_re_sprvsr_cur_rec.start_dt ;
        lr_re_sprvsr_rec.end_dt                        := l_re_sprvsr_cur_rec.end_dt ;
        lr_re_sprvsr_rec.research_supervisor_type      := l_re_sprvsr_cur_rec.research_supervisor_type ;
        lr_re_sprvsr_rec.supervisor_profession         := l_re_sprvsr_cur_rec.supervisor_profession ;
        lr_re_sprvsr_rec.supervision_percentage        := l_re_sprvsr_cur_rec.supervision_percentage ;
        lr_re_sprvsr_rec.funding_percentage            := l_re_sprvsr_cur_rec.funding_percentage ;
        lr_re_sprvsr_rec.org_unit_cd                   := l_re_sprvsr_cur_rec.org_unit_cd ;
        lr_re_sprvsr_rec.replaced_person_number        := l_re_sprvsr_cur_rec.replaced_person_number ;
        lr_re_sprvsr_rec.comments                      := l_re_sprvsr_cur_rec.comments ;


        l_return_status := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;
        igs_re_sprvsr_lgcy_pub.create_sprvsr(
                      P_API_VERSION      => 1.0,
                      P_INIT_MSG_LIST    => FND_API.G_TRUE,
                      P_COMMIT           => FND_API.G_FALSE,
                      P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                      p_sprvsr_dtls_rec  => lr_re_sprvsr_rec,
                      X_RETURN_STATUS    => l_return_status,
                      X_MSG_COUNT        => l_msg_count,
                      X_MSG_DATA         => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_return_status IS NULL THEN
           ROLLBACK TO savepoint_re_sprvsr;
           -- log the error message in the error message interface table
           log_err_messages(
             g_cst_re_sprvsr,
             l_re_sprvsr_cur_rec.legacy_re_sprvsr_int_id,
             l_msg_count,
             l_msg_data,
             l_return_status
           );
        ELSE
          -- log the success message in the concurrent manager log.
          log_suc_message(l_re_sprvsr_cur_rec.legacy_re_sprvsr_int_id);
        END IF;

        IF p_deletion_flag AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          -- delete any records in the error message interface table
          delete_err_messages(
            p_int_table_code => g_cst_re_sprvsr,
            p_int_table_id   => l_re_sprvsr_cur_rec.legacy_re_sprvsr_int_id
          );
          -- delete the interface record
          DELETE FROM igs_re_lgcy_spr_int
          WHERE legacy_re_sprvsr_int_id =  l_re_sprvsr_cur_rec.legacy_re_sprvsr_int_id;
        ELSE
          l_last_updated_by        := get_last_updated_by;
          l_last_update_date       := get_last_update_date;
          l_last_update_login      := get_last_update_login;
          l_request_id             := get_request_id;
          l_program_application_id := get_program_application_id;
          l_program_id             := get_program_id;
          l_program_update_date    := get_program_update_date;
          UPDATE igs_re_lgcy_spr_int
          SET import_status = DECODE(l_return_status,
                                     'S','I',
                                     'U','E',
                                     'W','W',
                                     'E'),
                last_update_date = l_last_update_date,
                last_updated_by = l_last_updated_by,
                last_update_login = l_last_update_login,
                request_id = l_request_id,
                program_id = l_program_id,
                program_application_id = l_program_application_id,
                program_update_date = l_program_update_date
          WHERE legacy_re_sprvsr_int_id =  l_re_sprvsr_cur_rec.legacy_re_sprvsr_int_id;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK TO savepoint_re_sprvsr;
      END;
    END LOOP;

    log_no_data_exists(l_not_found);

    -- This will commit the changes to the interface table record.
    -- if an error was encountered then all the unwanted changes
    -- would have been rolled back by the rollback to savepoint.
    COMMIT WORK;

  EXCEPTION
    WHEN g_resource_busy THEN
      log_resource_busy(g_cst_re_sprvsr);
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igs_en_lgcy_prc.legacy_batch_process.process_re_sprvsr');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END process_re_sprvsr;



-------------------------------------------------------------------------------
  PROCEDURE process_re_the(
              p_batch_id      IN NUMBER,
              p_deletion_flag IN BOOLEAN
  ) AS
    CURSOR c_re_the IS
    SELECT *
    FROM igs_re_lgcy_the_int
    WHERE batch_id = p_batch_id
    AND   import_status IN ('U','R')
    ORDER BY person_number ASC,
             program_cd ASC
    FOR UPDATE NOWAIT;


    lr_re_the_rec   igs_re_the_lgcy_pub.the_dtls_rec_type;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER(4);
    l_msg_data      VARCHAR2(4000);

    l_last_update_date       DATE ;
    l_last_updated_by        NUMBER;
    l_last_update_login      NUMBER;
    l_request_id             NUMBER;
    l_program_id             NUMBER;
    l_program_application_id NUMBER;
    l_program_update_date    DATE;
    l_not_found              BOOLEAN;

  BEGIN
/*
   Process the records in the Research Thesis interface table
   where the import status is either 'U' - Unproccessed or 'R' ready for reporccessing
*/

    log_headers(g_cst_re_the);
    l_not_found := TRUE;

    FOR l_re_the_cur_rec IN c_re_the LOOP
      BEGIN

        -- create a save point. if there are any errors returned by
        -- the API then rollback to this savepoint before processing
        -- then next record.
        SAVEPOINT savepoint_re_the;
        l_not_found := FALSE;

        -- populate the record variable to pass to the API
        lr_re_the_rec.person_number                 := l_re_the_cur_rec.person_number ;
        lr_re_the_rec.program_cd                    := l_re_the_cur_rec.program_cd ;
        lr_re_the_rec.title                         := l_re_the_cur_rec.title ;
        lr_re_the_rec.final_title_ind               := l_re_the_cur_rec.final_title_ind ;
        lr_re_the_rec.short_title                   := l_re_the_cur_rec.short_title ;
        lr_re_the_rec.abbreviated_title             := l_re_the_cur_rec.abbreviated_title ;
        lr_re_the_rec.final_thesis_result_cd        := l_re_the_cur_rec.final_thesis_result_cd ;
        lr_re_the_rec.expected_submission_dt        := l_re_the_cur_rec.expected_submission_dt ;
        lr_re_the_rec.library_lodgement_dt          := l_re_the_cur_rec.library_lodgement_dt ;
        lr_re_the_rec.library_catalogue_number      := l_re_the_cur_rec.library_catalogue_number ;
        lr_re_the_rec.embargo_expiry_dt             := l_re_the_cur_rec.embargo_expiry_dt ;
        lr_re_the_rec.thesis_format                 := l_re_the_cur_rec.thesis_format ;
        lr_re_the_rec.embargo_details               := l_re_the_cur_rec.embargo_details ;
        lr_re_the_rec.thesis_topic                  := l_re_the_cur_rec.thesis_topic ;
        lr_re_the_rec.citation                      := l_re_the_cur_rec.citation ;
        lr_re_the_rec.comments                      := l_re_the_cur_rec.comments ;
        lr_re_the_rec.submission_dt                 := l_re_the_cur_rec.submission_dt ;
        lr_re_the_rec.thesis_exam_type              := l_re_the_cur_rec.thesis_exam_type ;
        lr_re_the_rec.thesis_panel_type             := l_re_the_cur_rec.thesis_panel_type ;
        lr_re_the_rec.thesis_result_cd              := l_re_the_cur_rec.thesis_result_cd ;


        l_return_status := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;
        igs_re_the_lgcy_pub.create_the(
                      P_API_VERSION      => 1.0,
                      P_INIT_MSG_LIST    => FND_API.G_TRUE,
                      P_COMMIT           => FND_API.G_FALSE,
                      P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                      p_the_dtls_rec     => lr_re_the_rec,
                      X_RETURN_STATUS    => l_return_status,
                      X_MSG_COUNT        => l_msg_count,
                      X_MSG_DATA         => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_return_status IS NULL THEN
           ROLLBACK TO savepoint_re_the;
           -- log the error message in the error message interface table
           log_err_messages(
             g_cst_re_the,
             l_re_the_cur_rec.legacy_re_the_int_id,
             l_msg_count,
             l_msg_data,
             l_return_status
           );
        ELSE
          -- log the success message in the concurrent manager log.
          log_suc_message(l_re_the_cur_rec.legacy_re_the_int_id);
        END IF;

        IF p_deletion_flag AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          -- delete any records in the error message interface table
          delete_err_messages(
            p_int_table_code => g_cst_re_the,
            p_int_table_id   => l_re_the_cur_rec.legacy_re_the_int_id
          );
          -- delete the interface record
          DELETE FROM igs_re_lgcy_the_int
          WHERE legacy_re_the_int_id = l_re_the_cur_rec.legacy_re_the_int_id ;
        ELSE
          l_last_updated_by        := get_last_updated_by;
          l_last_update_date       := get_last_update_date;
          l_last_update_login      := get_last_update_login;
          l_request_id             := get_request_id;
          l_program_application_id := get_program_application_id;
          l_program_id             := get_program_id;
          l_program_update_date    := get_program_update_date;
          UPDATE igs_re_lgcy_the_int
          SET import_status = DECODE(l_return_status,
                                     'S','I',
                                     'U','E',
                                     'W','W',
                                     'E'),
                last_update_date = l_last_update_date,
                last_updated_by = l_last_updated_by,
                last_update_login = l_last_update_login,
                request_id = l_request_id,
                program_id = l_program_id,
                program_application_id = l_program_application_id,
                program_update_date = l_program_update_date
          WHERE  legacy_re_the_int_id = l_re_the_cur_rec.legacy_re_the_int_id ;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK TO savepoint_re_the;
      END;
    END LOOP;

    log_no_data_exists(l_not_found);

    -- This will commit the changes to the interface table record.
    -- if an error was encountered then all the unwanted changes
    -- would have been rolled back by the rollback to savepoint.
    COMMIT WORK;

  EXCEPTION
    WHEN g_resource_busy THEN
      log_resource_busy(g_cst_re_the);
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igs_en_lgcy_prc.legacy_batch_process.process_re_the');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END process_re_the;



-------------------------------------------------------------------------------
  PROCEDURE process_en_sua(
              p_batch_id      IN NUMBER,
              p_deletion_flag IN BOOLEAN
  ) AS
  -----------------------------------------------------------------------------------------------------
  --rvangala    07-OCT-2003    Value for CORE_INDICATOR_CODE passed to IGS_EN_SUA_API.UPDATE_UNIT_ATTEMPT
  --                           added as part of Prevent Dropping Core Units. Enh Bug# 3052432
  --ptandon     16-DEC-2003    Added code to log warning messages in the concurrent log in case of
  --                           successful unit attempts also so as to show warnings if term record
  --                           creation fails. Term Based Fee Calc build. Bug# 2829263.
  -----------------------------------------------------------------------------------------------------
    CURSOR c_en_sua IS
    SELECT suai.*
    FROM igs_en_lgcy_sua_int suai,
         igs_ca_inst ci
    WHERE batch_id = p_batch_id
    AND   import_status IN ('U','R')
    AND   suai.teach_calendar_alternate_code = ci.alternate_code(+)
    ORDER BY suai.person_number ASC,
             suai.transfer_dt DESC,
             ci.start_dt ASC
    FOR UPDATE NOWAIT;


    lr_en_sua_rec   igs_en_sua_lgcy_pub.sua_dtls_rec_type;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER(4);
    l_msg_data      VARCHAR2(4000);

    l_last_update_date       DATE ;
    l_last_updated_by        NUMBER;
    l_last_update_login      NUMBER;
    l_request_id             NUMBER;
    l_program_id             NUMBER;
    l_program_application_id NUMBER;
    l_program_update_date    DATE;
    l_not_found              BOOLEAN;

  BEGIN
/*
   Process the records in the Student Unit attempt interface table
   where the import status is either 'U' - Unproccessed or 'R' ready for reporccessing

   The Order by Clause in the c_en_sua, orders the records in such a way that
   First all the records that do not have any tranfer details are processed first
   only then the record with the transfer details are imported.

   Then the records are sorted by the start date of the teaching calender of the unit.
   The teaching calendar is dereived using the alternated code. It is possible that
   the alternate codes is wrong. If is wrong then the record would still be
   fetched since there is an outer join. but this record would cause errors
   to be thrown out by the API since the alternate code is a mandatory field
   and it is validated in the API.
*/

    log_headers(g_cst_en_sua);
    l_not_found := TRUE;

    FOR l_en_sua_cur_rec IN c_en_sua LOOP
      BEGIN

        -- create a save point. if there are any errors returned by
        -- the API then rollback to this savepoint before processing
        -- then next record.
        SAVEPOINT savepoint_en_sua;
        l_not_found := FALSE;

        -- populate the record variable to pass to the API
        lr_en_sua_rec.person_number                 := l_en_sua_cur_rec.person_number ;
        lr_en_sua_rec.program_cd                    := l_en_sua_cur_rec.program_cd ;
        lr_en_sua_rec.unit_cd                       := l_en_sua_cur_rec.unit_cd ;
        lr_en_sua_rec.version_number                := l_en_sua_cur_rec.version_number ;
        lr_en_sua_rec.teach_calendar_alternate_code := l_en_sua_cur_rec.teach_calendar_alternate_code ;
        lr_en_sua_rec.location_cd                   := l_en_sua_cur_rec.location_cd ;
        lr_en_sua_rec.unit_class                    := l_en_sua_cur_rec.unit_class ;
        lr_en_sua_rec.enrolled_dt                   := l_en_sua_cur_rec.enrolled_dt ;
        lr_en_sua_rec.waitlisted_dt                 := l_en_sua_cur_rec.waitlisted_dt ;
        lr_en_sua_rec.dropped_ind                   := l_en_sua_cur_rec.dropped_ind ;
        lr_en_sua_rec.discontinued_dt               := l_en_sua_cur_rec.discontinued_dt ;
        lr_en_sua_rec.administrative_unit_status    := l_en_sua_cur_rec.administrative_unit_status ;
        lr_en_sua_rec.dcnt_reason_cd                := l_en_sua_cur_rec.dcnt_reason_cd ;
        lr_en_sua_rec.no_assessment_ind             := l_en_sua_cur_rec.no_assessment_ind ;
        lr_en_sua_rec.override_enrolled_cp          := l_en_sua_cur_rec.override_enrolled_cp ;
        lr_en_sua_rec.override_achievable_cp        := l_en_sua_cur_rec.override_achievable_cp ;
        lr_en_sua_rec.grading_schema_code           := l_en_sua_cur_rec.grading_schema_code ;
        lr_en_sua_rec.gs_version_number             := l_en_sua_cur_rec.gs_version_number ;
        lr_en_sua_rec.subtitle                      := l_en_sua_cur_rec.subtitle ;
        lr_en_sua_rec.student_career_transcript     := l_en_sua_cur_rec.student_career_transcript ;
        lr_en_sua_rec.student_career_statistics     := l_en_sua_cur_rec.student_career_statistics ;
        lr_en_sua_rec.transfer_dt                   := l_en_sua_cur_rec.transfer_dt ;
        lr_en_sua_rec.transfer_program_cd           := l_en_sua_cur_rec.transfer_program_cd ;
        lr_en_sua_rec.outcome_dt                    := l_en_sua_cur_rec.outcome_dt ;
        lr_en_sua_rec.mark                          := l_en_sua_cur_rec.mark ;
        lr_en_sua_rec.outcome_grading_schema_code   := l_en_sua_cur_rec.outcome_grading_schema_code ;
        lr_en_sua_rec.outcome_gs_version_number     := l_en_sua_cur_rec.outcome_gs_version_number ;
        lr_en_sua_rec.grade                         := l_en_sua_cur_rec.grade ;
        lr_en_sua_rec.incomp_deadline_date          := l_en_sua_cur_rec.incomp_deadline_date ;
        lr_en_sua_rec.incomp_default_grade          := l_en_sua_cur_rec.incomp_default_grade ;
        lr_en_sua_rec.incomp_default_mark           := l_en_sua_cur_rec.incomp_default_mark ;
        lr_en_sua_rec.attribute_category            := l_en_sua_cur_rec.attribute_category ;
        lr_en_sua_rec.attribute1                    := l_en_sua_cur_rec.attribute1 ;
        lr_en_sua_rec.attribute2                    := l_en_sua_cur_rec.attribute2 ;
        lr_en_sua_rec.attribute3                    := l_en_sua_cur_rec.attribute3 ;
        lr_en_sua_rec.attribute4                    := l_en_sua_cur_rec.attribute4 ;
        lr_en_sua_rec.attribute5                    := l_en_sua_cur_rec.attribute5 ;
        lr_en_sua_rec.attribute6                    := l_en_sua_cur_rec.attribute6 ;
        lr_en_sua_rec.attribute7                    := l_en_sua_cur_rec.attribute7 ;
        lr_en_sua_rec.attribute8                    := l_en_sua_cur_rec.attribute8 ;
        lr_en_sua_rec.attribute9                    := l_en_sua_cur_rec.attribute9 ;
        lr_en_sua_rec.attribute10                   := l_en_sua_cur_rec.attribute10 ;
        lr_en_sua_rec.attribute11                   := l_en_sua_cur_rec.attribute11 ;
        lr_en_sua_rec.attribute12                   := l_en_sua_cur_rec.attribute12 ;
        lr_en_sua_rec.attribute13                   := l_en_sua_cur_rec.attribute13 ;
        lr_en_sua_rec.attribute14                   := l_en_sua_cur_rec.attribute14 ;
        lr_en_sua_rec.attribute15                   := l_en_sua_cur_rec.attribute15 ;
        lr_en_sua_rec.attribute16                   := l_en_sua_cur_rec.attribute16 ;
        lr_en_sua_rec.attribute17                   := l_en_sua_cur_rec.attribute17 ;
        lr_en_sua_rec.attribute18                   := l_en_sua_cur_rec.attribute18 ;
        lr_en_sua_rec.attribute19                   := l_en_sua_cur_rec.attribute19 ;
        lr_en_sua_rec.attribute20                   := l_en_sua_cur_rec.attribute20 ;
        -- CORE_INDICATOR added by rvangala 07-OCT-2003. Enh Bug# 3052432
        lr_en_sua_rec.core_indicator                := l_en_sua_cur_rec.core_indicator_code;

        l_return_status := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;
        igs_en_sua_lgcy_pub.create_sua(
                      P_API_VERSION      => 1.0,
                      P_INIT_MSG_LIST    => FND_API.G_TRUE,
                      P_COMMIT           => FND_API.G_FALSE,
                      P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                      p_sua_dtls_rec     => lr_en_sua_rec,
                      X_RETURN_STATUS    => l_return_status,
                      X_MSG_COUNT        => l_msg_count,
                      X_MSG_DATA         => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_return_status IS NULL THEN
           ROLLBACK TO savepoint_en_sua;
           -- log the error message in the error message interface table
           log_err_messages(
             g_cst_en_sua,
             l_en_sua_cur_rec.legacy_en_sua_int_id,
             l_msg_count,
             l_msg_data,
             l_return_status
           );
        ELSE

          -- Log the warning messages in the concurrent manager log.
          -- Since the term record creation might have failed while the unit attempt
          -- was successfully imported.
          IF l_msg_count > 0 THEN
           log_err_messages(
                            g_cst_en_sua,
                            l_en_sua_cur_rec.legacy_en_sua_int_id,
                            l_msg_count,
                            l_msg_data,
                            'W');
          END IF;

          -- log the success message in the concurrent manager log.
          log_suc_message(l_en_sua_cur_rec.legacy_en_sua_int_id);
        END IF;

        IF p_deletion_flag AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          -- delete any records in the error message interface table
          delete_err_messages(
            p_int_table_code => g_cst_en_sua,
            p_int_table_id   => l_en_sua_cur_rec.legacy_en_sua_int_id
          );
          -- delete the interface record
          DELETE FROM igs_en_lgcy_sua_int
          WHERE legacy_en_sua_int_id = l_en_sua_cur_rec.legacy_en_sua_int_id;
        ELSE
          l_last_updated_by        := get_last_updated_by;
          l_last_update_date       := get_last_update_date;
          l_last_update_login      := get_last_update_login;
          l_request_id             := get_request_id;
          l_program_application_id := get_program_application_id;
          l_program_id             := get_program_id;
          l_program_update_date    := get_program_update_date;
          UPDATE igs_en_lgcy_sua_int
          SET import_status = DECODE(l_return_status,
                                     'S','I',
                                     'U','E',
                                     'W','W',
                                     'E'),
                last_update_date = l_last_update_date,
                last_updated_by = l_last_updated_by,
                last_update_login = l_last_update_login,
                request_id = l_request_id,
                program_id = l_program_id,
                program_application_id = l_program_application_id,
                program_update_date = l_program_update_date
          WHERE legacy_en_sua_int_id = l_en_sua_cur_rec.legacy_en_sua_int_id;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK TO savepoint_en_sua;
      END;
    END LOOP;

    log_no_data_exists(l_not_found);

    -- This will commit the changes to the interface table record.
    -- if an error was encountered then all the unwanted changes
    -- would have been rolled back by the rollback to savepoint.
    COMMIT WORK;

  EXCEPTION
    WHEN g_resource_busy THEN
      log_resource_busy(g_cst_en_sua);
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igs_en_lgcy_prc.legacy_batch_process.process_en_sua');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END process_en_sua;



-------------------------------------------------------------------------------
  PROCEDURE process_he_spa(
              p_batch_id      IN NUMBER,
              p_deletion_flag IN BOOLEAN
  ) AS
  -----------------------------------------------------------------------------------------------------
  --jtmathew    21-SEP-2004    Added additional fields to lr_he_spa_rec for
  --                           changes described by HEFD350.
  -----------------------------------------------------------------------------------------------------
    CURSOR c_he_spa IS
    SELECT *
    FROM igs_he_lgcy_spa_int
    WHERE batch_id = p_batch_id
    AND   import_status IN ('U','R')
    ORDER BY person_number ASC,
             program_cd ASC
    FOR UPDATE NOWAIT;


    lr_he_spa_rec  igs_he_spa_lgcy_pub.hesa_spa_rec_type ;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER(4);
    l_msg_data      VARCHAR2(4000);

    l_last_update_date       DATE ;
    l_last_updated_by        NUMBER;
    l_last_update_login      NUMBER;
    l_request_id             NUMBER;
    l_program_id             NUMBER;
    l_program_application_id NUMBER;
    l_program_update_date    DATE;
    l_not_found              BOOLEAN;

  BEGIN
/*
   Process the records in the HESA Student program attempt statistics interface table
   where the import status is either 'U' - Unproccessed or 'R' ready for reporccessing
*/

    log_headers(g_cst_he_spa);
    l_not_found := TRUE;

    FOR l_he_spa_cur_rec IN c_he_spa LOOP
      BEGIN

        -- create a save point. if there are any errors returned by
        -- the API then rollback to this savepoint before processing
        -- then next record.
        SAVEPOINT savepoint_he_spa;
        l_not_found := FALSE;

        -- populate the record variable to pass to the API
        lr_he_spa_rec.person_number                 := l_he_spa_cur_rec.person_number ;
        lr_he_spa_rec.program_cd                    := l_he_spa_cur_rec.program_cd ;
        lr_he_spa_rec.fe_student_marker             := l_he_spa_cur_rec.fe_student_marker ;
        lr_he_spa_rec.domicile_cd                   := l_he_spa_cur_rec.domicile_cd ;
        lr_he_spa_rec.highest_qual_on_entry         := l_he_spa_cur_rec.highest_qual_on_entry ;
        lr_he_spa_rec.occupation_code               := l_he_spa_cur_rec.occupation_code ;
        lr_he_spa_rec.commencement_dt               := l_he_spa_cur_rec.commencement_dt ;
        lr_he_spa_rec.special_student               := l_he_spa_cur_rec.special_student ;
        lr_he_spa_rec.student_qual_aim              := l_he_spa_cur_rec.student_qual_aim ;
        lr_he_spa_rec.student_fe_qual_aim           := l_he_spa_cur_rec.student_fe_qual_aim ;
        lr_he_spa_rec.teacher_train_prog_id         := l_he_spa_cur_rec.teacher_train_prog_id ;
        lr_he_spa_rec.itt_phase                     := l_he_spa_cur_rec.itt_phase ;
        lr_he_spa_rec.bilingual_itt_marker          := l_he_spa_cur_rec.bilingual_itt_marker ;
        lr_he_spa_rec.teaching_qual_gain_sector     := l_he_spa_cur_rec.teaching_qual_gain_sector ;
        lr_he_spa_rec.teaching_qual_gain_subj1      := l_he_spa_cur_rec.teaching_qual_gain_subj1 ;
        lr_he_spa_rec.teaching_qual_gain_subj2      := l_he_spa_cur_rec.teaching_qual_gain_subj2 ;
        lr_he_spa_rec.teaching_qual_gain_subj3      := l_he_spa_cur_rec.teaching_qual_gain_subj3 ;
        lr_he_spa_rec.student_inst_number           := l_he_spa_cur_rec.student_inst_number ;
        lr_he_spa_rec.destination                   := l_he_spa_cur_rec.destination ;
        lr_he_spa_rec.itt_prog_outcome              := l_he_spa_cur_rec.itt_prog_outcome ;
        lr_he_spa_rec.associate_ucas_number         := l_he_spa_cur_rec.associate_ucas_number ;
        lr_he_spa_rec.associate_scott_cand          := l_he_spa_cur_rec.associate_scott_cand ;
        lr_he_spa_rec.associate_teach_ref_num       := l_he_spa_cur_rec.associate_teach_ref_num ;
        lr_he_spa_rec.associate_nhs_reg_num         := l_he_spa_cur_rec.associate_nhs_reg_num ;
        lr_he_spa_rec.nhs_funding_source            := l_he_spa_cur_rec.nhs_funding_source ;
        lr_he_spa_rec.ufi_place                     := l_he_spa_cur_rec.ufi_place ;
        lr_he_spa_rec.postcode                      := l_he_spa_cur_rec.postcode ;
        lr_he_spa_rec.social_class_ind              := l_he_spa_cur_rec.social_class_ind ;
        lr_he_spa_rec.occcode                       := l_he_spa_cur_rec.occcode ;
        lr_he_spa_rec.nhs_employer                  := l_he_spa_cur_rec.nhs_employer ;
        lr_he_spa_rec.return_type                   := l_he_spa_cur_rec.return_type ;
        lr_he_spa_rec.subj_qualaim1                 := l_he_spa_cur_rec.subj_qualaim1 ;
        lr_he_spa_rec.subj_qualaim2                 := l_he_spa_cur_rec.subj_qualaim2 ;
        lr_he_spa_rec.subj_qualaim3                 := l_he_spa_cur_rec.subj_qualaim3 ;
        lr_he_spa_rec.qualaim_proportion            := l_he_spa_cur_rec.qualaim_proportion ;
        lr_he_spa_rec.dependants_cd                 := l_he_spa_cur_rec.dependants_cd ;
        lr_he_spa_rec.implied_fund_rate             := l_he_spa_cur_rec.implied_fund_rate ;
        lr_he_spa_rec.gov_initiatives_cd            := l_he_spa_cur_rec.gov_initiatives_cd ;
        lr_he_spa_rec.units_for_qual                := l_he_spa_cur_rec.units_for_qual ;
        lr_he_spa_rec.disadv_uplift_elig_cd         := l_he_spa_cur_rec.disadv_uplift_elig_cd ;
        lr_he_spa_rec.franch_partner_cd             := l_he_spa_cur_rec.franch_partner_cd ;
        lr_he_spa_rec.units_completed               := l_he_spa_cur_rec.units_completed ;
        lr_he_spa_rec.franch_out_arr_cd             := l_he_spa_cur_rec.franch_out_arr_cd ;
        lr_he_spa_rec.employer_role_cd              := l_he_spa_cur_rec.employer_role_cd ;
        lr_he_spa_rec.disadv_uplift_factor          := l_he_spa_cur_rec.disadv_uplift_factor ;
        lr_he_spa_rec.enh_fund_elig_cd              := l_he_spa_cur_rec.enh_fund_elig_cd ;


        l_return_status := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;
        igs_he_spa_lgcy_pub.create_hesa_spa(
                      P_API_VERSION      => 1.0,
                      P_INIT_MSG_LIST    => FND_API.G_TRUE,
                      P_COMMIT           => FND_API.G_FALSE,
                      P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                      p_hesa_spa_stats_rec => lr_he_spa_rec,
                      X_RETURN_STATUS    => l_return_status,
                      X_MSG_COUNT        => l_msg_count,
                      X_MSG_DATA         => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_return_status IS NULL THEN
           ROLLBACK TO savepoint_he_spa;
           -- log the error message in the error message interface table
           log_err_messages(
             g_cst_he_spa,
             l_he_spa_cur_rec.legacy_hesa_spa_int_id,
             l_msg_count,
             l_msg_data,
             l_return_status
           );
        ELSE
          -- log the success message in the concurrent manager log.
          log_suc_message(l_he_spa_cur_rec.legacy_hesa_spa_int_id);
        END IF;

        IF p_deletion_flag AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          -- delete any records in the error message interface table
          delete_err_messages(
            p_int_table_code => g_cst_he_spa,
            p_int_table_id   => l_he_spa_cur_rec.legacy_hesa_spa_int_id
          );
          -- delete the interface record
          DELETE FROM igs_he_lgcy_spa_int
          WHERE legacy_hesa_spa_int_id = l_he_spa_cur_rec.legacy_hesa_spa_int_id;
        ELSE
          l_last_updated_by        := get_last_updated_by;
          l_last_update_date       := get_last_update_date;
          l_last_update_login      := get_last_update_login;
          l_request_id             := get_request_id;
          l_program_application_id := get_program_application_id;
          l_program_id             := get_program_id;
          l_program_update_date    := get_program_update_date;
          UPDATE igs_he_lgcy_spa_int
          SET import_status = DECODE(l_return_status,
                                     'S','I',
                                     'U','E',
                                     'W','W',
                                     'E'),
                last_update_date = l_last_update_date,
                last_updated_by = l_last_updated_by,
                last_update_login = l_last_update_login,
                request_id = l_request_id,
                program_id = l_program_id,
                program_application_id = l_program_application_id,
                program_update_date = l_program_update_date
          WHERE legacy_hesa_spa_int_id = l_he_spa_cur_rec.legacy_hesa_spa_int_id;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK TO savepoint_he_spa;
      END;
    END LOOP;

    log_no_data_exists(l_not_found);

    -- This will commit the changes to the interface table record.
    -- if an error was encountered then all the unwanted changes
    -- would have been rolled back by the rollback to savepoint.
    COMMIT WORK;

  EXCEPTION
    WHEN g_resource_busy THEN
      log_resource_busy(g_cst_he_spa);
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igs_en_lgcy_prc.legacy_batch_process.process_he_spa');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END process_he_spa;



-------------------------------------------------------------------------------
  PROCEDURE process_he_susa(
              p_batch_id      IN NUMBER,
              p_deletion_flag IN BOOLEAN
  ) AS
  -----------------------------------------------------------------------------------------------------
  --jtmathew    21-SEP-2004    Added additional fields to lr_he_susa_rec for
  --                           changes described by HEFD350.
  -----------------------------------------------------------------------------------------------------
    CURSOR c_he_susa IS
    SELECT *
    FROM igs_he_lgy_susa_int
    WHERE batch_id = p_batch_id
    AND   import_status IN ('U','R')
    ORDER BY person_number ASC,
             program_cd ASC
    FOR UPDATE NOWAIT;


    lr_he_susa_rec  igs_he_susa_lgcy_pub.hesa_susa_rec_type ;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER(4);
    l_msg_data      VARCHAR2(4000);

    l_last_update_date       DATE ;
    l_last_updated_by        NUMBER;
    l_last_update_login      NUMBER;
    l_request_id             NUMBER;
    l_program_id             NUMBER;
    l_program_application_id NUMBER;
    l_program_update_date    DATE;
    l_not_found              BOOLEAN;

  BEGIN
/*
   Process the records in the HESA Student unitset attempt statistics interface table
   where the import status is either 'U' - Unproccessed or 'R' ready for reporccessing
*/

    log_headers(g_cst_he_susa);
    l_not_found := TRUE;

    FOR l_he_susa_cur_rec IN c_he_susa LOOP
      BEGIN

        -- create a save point. if there are any errors returned by
        -- the API then rollback to this savepoint before processing
        -- then next record.
        SAVEPOINT savepoint_he_susa;
        l_not_found := FALSE;

        -- populate the record variable to pass to the API
        lr_he_susa_rec.person_number                 := l_he_susa_cur_rec.person_number ;
        lr_he_susa_rec.program_cd                    := l_he_susa_cur_rec.program_cd ;
        lr_he_susa_rec.unit_set_cd                   := l_he_susa_cur_rec.unit_set_cd ;
        lr_he_susa_rec.new_he_entrant_cd             := l_he_susa_cur_rec.new_he_entrant_cd ;
        lr_he_susa_rec.term_time_accom               := l_he_susa_cur_rec.term_time_accom ;
        lr_he_susa_rec.disability_allow              := l_he_susa_cur_rec.disability_allow ;
        lr_he_susa_rec.additional_sup_band           := l_he_susa_cur_rec.additional_sup_band ;
        lr_he_susa_rec.sldd_discrete_prov            := l_he_susa_cur_rec.sldd_discrete_prov ;
        lr_he_susa_rec.study_mode                    := l_he_susa_cur_rec.study_mode ;
        lr_he_susa_rec.study_location                := l_he_susa_cur_rec.study_location ;
        lr_he_susa_rec.fte_perc_override             := l_he_susa_cur_rec.fte_perc_override ;
        lr_he_susa_rec.franchising_activity          := l_he_susa_cur_rec.franchising_activity ;
        lr_he_susa_rec.completion_status             := l_he_susa_cur_rec.completion_status ;
        lr_he_susa_rec.good_stand_marker             := l_he_susa_cur_rec.good_stand_marker ;
        lr_he_susa_rec.complete_pyr_study_cd         := l_he_susa_cur_rec.complete_pyr_study_cd ;
        lr_he_susa_rec.credit_value_yop1             := l_he_susa_cur_rec.credit_value_yop1 ;
        lr_he_susa_rec.credit_value_yop2             := l_he_susa_cur_rec.credit_value_yop2 ;
        lr_he_susa_rec.credit_value_yop3             := l_he_susa_cur_rec.credit_value_yop3 ;
        lr_he_susa_rec.credit_value_yop4             := l_he_susa_cur_rec.credit_value_yop4 ;
        lr_he_susa_rec.credit_level_achieved1        := l_he_susa_cur_rec.credit_level_achieved1 ;
        lr_he_susa_rec.credit_level_achieved2        := l_he_susa_cur_rec.credit_level_achieved2 ;
        lr_he_susa_rec.credit_level_achieved3        := l_he_susa_cur_rec.credit_level_achieved3 ;
        lr_he_susa_rec.credit_level_achieved4        := l_he_susa_cur_rec.credit_level_achieved4 ;
        lr_he_susa_rec.credit_pt_achieved1           := l_he_susa_cur_rec.credit_pt_achieved1 ;
        lr_he_susa_rec.credit_pt_achieved2           := l_he_susa_cur_rec.credit_pt_achieved2 ;
        lr_he_susa_rec.credit_pt_achieved3           := l_he_susa_cur_rec.credit_pt_achieved3 ;
        lr_he_susa_rec.credit_pt_achieved4           := l_he_susa_cur_rec.credit_pt_achieved4 ;
        lr_he_susa_rec.credit_level1                 := l_he_susa_cur_rec.credit_level1 ;
        lr_he_susa_rec.credit_level2                 := l_he_susa_cur_rec.credit_level2 ;
        lr_he_susa_rec.credit_level3                 := l_he_susa_cur_rec.credit_level3 ;
        lr_he_susa_rec.credit_level4                 := l_he_susa_cur_rec.credit_level4 ;
        lr_he_susa_rec.grad_sch_grade                := l_he_susa_cur_rec.grad_sch_grade ;
        lr_he_susa_rec.mark                          := l_he_susa_cur_rec.mark ;
        lr_he_susa_rec.teaching_inst1                := l_he_susa_cur_rec.teaching_inst1 ;
        lr_he_susa_rec.teaching_inst2                := l_he_susa_cur_rec.teaching_inst2 ;
        lr_he_susa_rec.pro_not_taught                := l_he_susa_cur_rec.pro_not_taught ;
        lr_he_susa_rec.fundability_code              := l_he_susa_cur_rec.fundability_code ;
        lr_he_susa_rec.fee_eligibility               := l_he_susa_cur_rec.fee_eligibility ;
        lr_he_susa_rec.fee_band                      := l_he_susa_cur_rec.fee_band ;
        lr_he_susa_rec.non_payment_reason            := l_he_susa_cur_rec.non_payment_reason ;
        lr_he_susa_rec.student_fee                   := l_he_susa_cur_rec.student_fee ;
        lr_he_susa_rec.fte_intensity                 := l_he_susa_cur_rec.fte_intensity ;
        lr_he_susa_rec.calculated_fte                := l_he_susa_cur_rec.calculated_fte ;
        lr_he_susa_rec.fte_calc_type                 := l_he_susa_cur_rec.fte_calc_type ;
        lr_he_susa_rec.type_of_year                  := l_he_susa_cur_rec.type_of_year ;
        lr_he_susa_rec.year_stu                      := l_he_susa_cur_rec.year_stu ;
        lr_he_susa_rec.enh_fund_elig_cd              := l_he_susa_cur_rec.enh_fund_elig_cd ;
        lr_he_susa_rec.additional_sup_cost           := l_he_susa_cur_rec.additional_sup_cost ;
        lr_he_susa_rec.disadv_uplift_factor          := l_he_susa_cur_rec.disadv_uplift_factor ;

        l_return_status := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;
        igs_he_susa_lgcy_pub.create_hesa_susa(
                      P_API_VERSION      => 1.0,
                      P_INIT_MSG_LIST    => FND_API.G_TRUE,
                      P_COMMIT           => FND_API.G_FALSE,
                      P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                      p_hesa_susa_rec    => lr_he_susa_rec,
                      X_RETURN_STATUS    => l_return_status,
                      X_MSG_COUNT        => l_msg_count,
                      X_MSG_DATA         => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_return_status IS NULL THEN
           ROLLBACK TO savepoint_he_susa;
           -- log the error message in the error message interface table
           log_err_messages(
             g_cst_he_susa,
             l_he_susa_cur_rec.legacy_hesa_susa_int_id,
             l_msg_count,
             l_msg_data,
             l_return_status
           );
        ELSE
          -- log the success message in the concurrent manager log.
          log_suc_message(l_he_susa_cur_rec.legacy_hesa_susa_int_id);
        END IF;

        IF p_deletion_flag AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          -- delete any records in the error message interface table
          delete_err_messages(
            p_int_table_code => g_cst_he_susa,
            p_int_table_id   => l_he_susa_cur_rec.legacy_hesa_susa_int_id
          );
          -- delete the interface record
          DELETE FROM igs_he_lgy_susa_int
          WHERE  legacy_hesa_susa_int_id = l_he_susa_cur_rec.legacy_hesa_susa_int_id ;
        ELSE
          l_last_updated_by        := get_last_updated_by;
          l_last_update_date       := get_last_update_date;
          l_last_update_login      := get_last_update_login;
          l_request_id             := get_request_id;
          l_program_application_id := get_program_application_id;
          l_program_id             := get_program_id;
          l_program_update_date    := get_program_update_date;
          UPDATE igs_he_lgy_susa_int
          SET import_status = DECODE(l_return_status,
                                     'S','I',
                                     'U','E',
                                     'W','W',
                                     'E'),
                last_update_date = l_last_update_date,
                last_updated_by = l_last_updated_by,
                last_update_login = l_last_update_login,
                request_id = l_request_id,
                program_id = l_program_id,
                program_application_id = l_program_application_id,
                program_update_date = l_program_update_date
          WHERE legacy_hesa_susa_int_id = l_he_susa_cur_rec.legacy_hesa_susa_int_id ;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK TO savepoint_he_susa;
      END;
    END LOOP;

    log_no_data_exists(l_not_found);

    -- This will commit the changes to the interface table record.
    -- if an error was encountered then all the unwanted changes
    -- would have been rolled back by the rollback to savepoint.
    COMMIT WORK;

  EXCEPTION
    WHEN g_resource_busy THEN
      log_resource_busy(g_cst_he_susa);
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igs_en_lgcy_prc.legacy_batch_process.process_he_susa');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END process_he_susa;



-------------------------------------------------------------------------------
  PROCEDURE process_av_avstdl(
              p_batch_id      IN NUMBER,
              p_deletion_flag IN BOOLEAN
  ) AS
    CURSOR c_av_avstdl IS
    SELECT *
    FROM igs_av_lgcy_lvl_int
    WHERE batch_id = p_batch_id
    AND   import_status IN ('U','R')
    FOR UPDATE NOWAIT;


    lr_av_avstdl_rec igs_av_lvl_lgcy_pub.lgcy_adstlvl_rec_type  ;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER(4);
    l_msg_data      VARCHAR2(4000);

    l_last_update_date       DATE ;
    l_last_updated_by        NUMBER;
    l_last_update_login      NUMBER;
    l_request_id             NUMBER;
    l_program_id             NUMBER;
    l_program_application_id NUMBER;
    l_program_update_date    DATE;
    l_not_found              BOOLEAN;

  BEGIN
/*
   Process the records in the Advance Standing at Unit Level  interface table
   where the import status is either 'U' - Unproccessed or 'R' ready for reporccessing
*/

    log_headers(g_cst_av_avstdl);
    l_not_found := TRUE;

    FOR l_av_avstdl_cur_rec IN c_av_avstdl LOOP
      BEGIN

        -- create a save point. if there are any errors returned by
        -- the API then rollback to this savepoint before processing
        -- then next record.
        SAVEPOINT savepoint_av_avstdl;
        l_not_found := FALSE;

        -- populate the record variable to pass to the API
        lr_av_avstdl_rec.person_number                 := l_av_avstdl_cur_rec.person_number ;
        lr_av_avstdl_rec.program_cd                    := l_av_avstdl_cur_rec.program_cd ;
        lr_av_avstdl_rec.total_exmptn_approved         := l_av_avstdl_cur_rec.total_exmptn_approved ;
        lr_av_avstdl_rec.total_exmptn_granted          := l_av_avstdl_cur_rec.total_exmptn_granted ;
        lr_av_avstdl_rec.total_exmptn_perc_grntd       := l_av_avstdl_cur_rec.total_exmptn_perc_grntd ;
        lr_av_avstdl_rec.exemption_institution_cd      := l_av_avstdl_cur_rec.exemption_institution_cd ;
        lr_av_avstdl_rec.unit_level                    := l_av_avstdl_cur_rec.unit_level ;
        lr_av_avstdl_rec.prog_group_ind                := l_av_avstdl_cur_rec.prog_group_ind ;
        lr_av_avstdl_rec.load_cal_alt_code             := l_av_avstdl_cur_rec.load_cal_alt_code ;
        lr_av_avstdl_rec.institution_cd                := l_av_avstdl_cur_rec.institution_cd ;
        lr_av_avstdl_rec.s_adv_stnd_granting_status    := l_av_avstdl_cur_rec.s_adv_stnd_granting_status ;
        lr_av_avstdl_rec.credit_points                 := l_av_avstdl_cur_rec.credit_points ;
        lr_av_avstdl_rec.approved_dt                   := trunc(l_av_avstdl_cur_rec.approved_dt) ;
        lr_av_avstdl_rec.authorising_person_number     := l_av_avstdl_cur_rec.authorising_person_number ;
        lr_av_avstdl_rec.granted_dt                    := trunc(l_av_avstdl_cur_rec.granted_dt) ;
        lr_av_avstdl_rec.expiry_dt                     := trunc(l_av_avstdl_cur_rec.expiry_dt) ;
        lr_av_avstdl_rec.cancelled_dt                  := trunc(l_av_avstdl_cur_rec.cancelled_dt) ;
        lr_av_avstdl_rec.revoked_dt                    := trunc(l_av_avstdl_cur_rec.revoked_dt) ;
        lr_av_avstdl_rec.comments                      := rtrim(l_av_avstdl_cur_rec.comments) ;
        lr_av_avstdl_rec.qual_exam_level               := l_av_avstdl_cur_rec.qual_exam_level ;
        lr_av_avstdl_rec.qual_subject_code             := l_av_avstdl_cur_rec.qual_subject_code ;
        lr_av_avstdl_rec.qual_year                     := l_av_avstdl_cur_rec.qual_year ;
        lr_av_avstdl_rec.qual_sitting                  := l_av_avstdl_cur_rec.qual_sitting ;
        lr_av_avstdl_rec.qual_awarding_body            := l_av_avstdl_cur_rec.qual_awarding_body ;
        lr_av_avstdl_rec.approved_result               := l_av_avstdl_cur_rec.approved_result ;
        lr_av_avstdl_rec.prev_unit_cd                  := l_av_avstdl_cur_rec.prev_unit_cd ;
        lr_av_avstdl_rec.prev_term                     := l_av_avstdl_cur_rec.prev_term ;
        lr_av_avstdl_rec.start_date                    := l_av_avstdl_cur_rec.start_date ;
        lr_av_avstdl_rec.end_date                      := l_av_avstdl_cur_rec.end_date ;
        lr_av_avstdl_rec.tst_admission_test_type       := l_av_avstdl_cur_rec.tst_admission_test_type ;
        lr_av_avstdl_rec.tst_test_date                 := l_av_avstdl_cur_rec.tst_test_date ;
        lr_av_avstdl_rec.test_segment_name             := l_av_avstdl_cur_rec.test_segment_name ;
        lr_av_avstdl_rec.basis_program_type            := l_av_avstdl_cur_rec.basis_program_type ;
        lr_av_avstdl_rec.basis_year                    := l_av_avstdl_cur_rec.basis_year ;
        lr_av_avstdl_rec.basis_completion_ind          := l_av_avstdl_cur_rec.basis_completion_ind ;
        lr_av_avstdl_rec.unit_level_mark               := l_av_avstdl_cur_rec.unit_level_mark;


        l_return_status := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;
        igs_av_lvl_lgcy_pub.create_adv_stnd_level(
                      P_API_VERSION      => 1.0,
                      P_INIT_MSG_LIST    => FND_API.G_TRUE,
                      P_COMMIT           => FND_API.G_FALSE,
                      P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                      p_lgcy_adstlvl_rec => lr_av_avstdl_rec,
                      X_RETURN_STATUS    => l_return_status,
                      X_MSG_COUNT        => l_msg_count,
                      X_MSG_DATA         => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_return_status IS NULL THEN
           ROLLBACK TO savepoint_av_avstdl;
           -- log the error message in the error message interface table
           log_err_messages(
             g_cst_av_avstdl,
             l_av_avstdl_cur_rec.legacy_lvl_int_id,
             l_msg_count,
             l_msg_data,
             l_return_status
           );
        ELSE
          -- log the success message in the concurrent manager log.
          log_suc_message(l_av_avstdl_cur_rec.legacy_lvl_int_id);
        END IF;

        IF p_deletion_flag AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          -- delete any records in the error message interface table
          delete_err_messages(
            p_int_table_code => g_cst_av_avstdl,
            p_int_table_id   => l_av_avstdl_cur_rec.legacy_lvl_int_id
          );
          -- delete the interface record
          DELETE FROM igs_av_lgcy_lvl_int
          WHERE legacy_lvl_int_id = l_av_avstdl_cur_rec.legacy_lvl_int_id;
        ELSE
          l_last_updated_by        := get_last_updated_by;
          l_last_update_date       := get_last_update_date;
          l_last_update_login      := get_last_update_login;
          l_request_id             := get_request_id;
          l_program_application_id := get_program_application_id;
          l_program_id             := get_program_id;
          l_program_update_date    := get_program_update_date;
          UPDATE igs_av_lgcy_lvl_int
          SET import_status = DECODE(l_return_status,
                                     'S','I',
                                     'U','E',
                                     'W','W',
                                     'E'),
                last_update_date = l_last_update_date,
                last_updated_by = l_last_updated_by,
                last_update_login = l_last_update_login,
                request_id = l_request_id,
                program_id = l_program_id,
                program_application_id = l_program_application_id,
                program_update_date = l_program_update_date
          WHERE legacy_lvl_int_id = l_av_avstdl_cur_rec.legacy_lvl_int_id;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK TO savepoint_av_avstdl;
      END;
    END LOOP;

    log_no_data_exists(l_not_found);

    -- This will commit the changes to the interface table record.
    -- if an error was encountered then all the unwanted changes
    -- would have been rolled back by the rollback to savepoint.
    COMMIT WORK;

  EXCEPTION
    WHEN g_resource_busy THEN
      log_resource_busy(g_cst_av_avstdl);
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igs_en_lgcy_prc.legacy_batch_process.process_av_avstdl');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END process_av_avstdl;



-------------------------------------------------------------------------------
  PROCEDURE process_av_untstd(
              p_batch_id      IN NUMBER,
              p_deletion_flag IN BOOLEAN
  ) AS
    CURSOR c_av_untstd IS
    SELECT *
    FROM igs_av_lgcy_unt_int
    WHERE batch_id = p_batch_id
    AND   import_status IN ('U','R')
    FOR UPDATE NOWAIT;


    lr_av_untstd_rec  igs_av_unt_lgcy_pub.lgcy_adstunt_rec_type ;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER(4);
    l_msg_data      VARCHAR2(4000);

    l_last_update_date       DATE ;
    l_last_updated_by        NUMBER;
    l_last_update_login      NUMBER;
    l_request_id             NUMBER;
    l_program_id             NUMBER;
    l_program_application_id NUMBER;
    l_program_update_date    DATE;
    l_not_found              BOOLEAN;

  BEGIN
/*
   Process the records in the Advance Standing Unit interface table
   where the import status is either 'U' - Unproccessed or 'R' ready for reporccessing
*/

    log_headers(g_cst_av_untstd);
    l_not_found := TRUE;

    FOR l_av_untstd_cur_rec IN c_av_untstd LOOP
      BEGIN

        -- create a save point. if there are any errors returned by
        -- the API then rollback to this savepoint before processing
        -- then next record.
        SAVEPOINT savepoint_av_untstd;
        l_not_found := FALSE;

        -- populate the record variable to pass to the API
        lr_av_untstd_rec.person_number                 := l_av_untstd_cur_rec.person_number ;
        lr_av_untstd_rec.program_cd                    := l_av_untstd_cur_rec.program_cd ;
        lr_av_untstd_rec.total_exmptn_approved         := l_av_untstd_cur_rec.total_exmptn_approved ;
        lr_av_untstd_rec.total_exmptn_granted          := l_av_untstd_cur_rec.total_exmptn_granted ;
        lr_av_untstd_rec.total_exmptn_perc_grntd       := l_av_untstd_cur_rec.total_exmptn_perc_grntd ;
        lr_av_untstd_rec.exemption_institution_cd      := l_av_untstd_cur_rec.exemption_institution_cd ;
        lr_av_untstd_rec.unit_cd                       := l_av_untstd_cur_rec.unit_cd ;
        lr_av_untstd_rec.version_number                := l_av_untstd_cur_rec.version_number ;
        lr_av_untstd_rec.institution_cd                := l_av_untstd_cur_rec.institution_cd ;
        lr_av_untstd_rec.approved_dt                   := l_av_untstd_cur_rec.approved_dt ;
        lr_av_untstd_rec.authorising_person_number     := l_av_untstd_cur_rec.authorising_person_number ;
        lr_av_untstd_rec.prog_group_ind                := l_av_untstd_cur_rec.prog_group_ind ;
        lr_av_untstd_rec.granted_dt                    := l_av_untstd_cur_rec.granted_dt ;
        lr_av_untstd_rec.expiry_dt                     := l_av_untstd_cur_rec.expiry_dt ;
        lr_av_untstd_rec.cancelled_dt                  := l_av_untstd_cur_rec.cancelled_dt ;
        lr_av_untstd_rec.revoked_dt                    := l_av_untstd_cur_rec.revoked_dt ;
        lr_av_untstd_rec.comments                      := l_av_untstd_cur_rec.comments ;
        lr_av_untstd_rec.credit_percentage             := NULL ;
        lr_av_untstd_rec.s_adv_stnd_granting_status    := l_av_untstd_cur_rec.s_adv_stnd_granting_status ;
        lr_av_untstd_rec.s_adv_stnd_recognition_type   := l_av_untstd_cur_rec.s_adv_stnd_recognition_type ;
        lr_av_untstd_rec.load_cal_alt_code             := l_av_untstd_cur_rec.load_cal_alt_code ;
        lr_av_untstd_rec.grading_schema_cd             := l_av_untstd_cur_rec.grading_schema_cd ;
        lr_av_untstd_rec.grd_sch_version_number        := l_av_untstd_cur_rec.grd_sch_version_number ;
        lr_av_untstd_rec.grade                         := l_av_untstd_cur_rec.grade ;
        lr_av_untstd_rec.achievable_credit_points      := l_av_untstd_cur_rec.achievable_credit_points ;
        lr_av_untstd_rec.prev_unit_cd                  := l_av_untstd_cur_rec.prev_unit_cd ;
        lr_av_untstd_rec.prev_term                     := l_av_untstd_cur_rec.prev_term ;
        lr_av_untstd_rec.tst_admission_test_type       := l_av_untstd_cur_rec.tst_admission_test_type ;
        lr_av_untstd_rec.tst_test_date                 := l_av_untstd_cur_rec.tst_test_date ;
        lr_av_untstd_rec.test_segment_name             := l_av_untstd_cur_rec.test_segment_name ;
        lr_av_untstd_rec.alt_unit_cd                   := l_av_untstd_cur_rec.alt_unit_cd ;
        lr_av_untstd_rec.alt_version_number            := l_av_untstd_cur_rec.alt_version_number ;
        lr_av_untstd_rec.optional_ind                  := l_av_untstd_cur_rec.optional_ind ;
        lr_av_untstd_rec.basis_program_type            := l_av_untstd_cur_rec.basis_program_type ;
        lr_av_untstd_rec.basis_year                    := l_av_untstd_cur_rec.basis_year ;
        lr_av_untstd_rec.basis_completion_ind          := l_av_untstd_cur_rec.basis_completion_ind ;
        lr_av_untstd_rec.start_date                    := l_av_untstd_cur_rec.start_date ;
        lr_av_untstd_rec.end_date                      := l_av_untstd_cur_rec.end_date ;
        lr_av_untstd_rec.reference_cd_type             := l_av_untstd_cur_rec.reference_cd_type;
        lr_av_untstd_rec.reference_cd                  := l_av_untstd_cur_rec.reference_cd      ;
        lr_av_untstd_rec.applied_program_cd            := l_av_untstd_cur_rec.applied_program_cd;


        l_return_status := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;
        igs_av_unt_lgcy_pub.create_adv_stnd_unit(
                      P_API_VERSION      => 1.0,
                      P_INIT_MSG_LIST    => FND_API.G_TRUE,
                      P_COMMIT           => FND_API.G_FALSE,
                      P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                      p_lgcy_adstunt_rec => lr_av_untstd_rec,
                      X_RETURN_STATUS    => l_return_status,
                      X_MSG_COUNT        => l_msg_count,
                      X_MSG_DATA         => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_return_status IS NULL THEN
           ROLLBACK TO savepoint_av_untstd;
           -- log the error message in the error message interface table
           log_err_messages(
             g_cst_av_untstd,
             l_av_untstd_cur_rec.legacy_unt_int_id,
             l_msg_count,
             l_msg_data,
             l_return_status
           );
        ELSE
          -- log the success message in the concurrent manager log.
          log_suc_message(l_av_untstd_cur_rec.legacy_unt_int_id);
        END IF;

        IF p_deletion_flag AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          -- delete any records in the error message interface table
          delete_err_messages(
            p_int_table_code => g_cst_av_untstd,
            p_int_table_id   => l_av_untstd_cur_rec.legacy_unt_int_id
          );
          -- delete the interface record
          DELETE FROM igs_av_lgcy_unt_int
          WHERE legacy_unt_int_id = l_av_untstd_cur_rec.legacy_unt_int_id;
        ELSE
          l_last_updated_by        := get_last_updated_by;
          l_last_update_date       := get_last_update_date;
          l_last_update_login      := get_last_update_login;
          l_request_id             := get_request_id;
          l_program_application_id := get_program_application_id;
          l_program_id             := get_program_id;
          l_program_update_date    := get_program_update_date;
          UPDATE igs_av_lgcy_unt_int
          SET import_status = DECODE(l_return_status,
                                     'S','I',
                                     'U','E',
                                     'W','W',
                                     'E'),
                last_update_date = l_last_update_date,
                last_updated_by = l_last_updated_by,
                last_update_login = l_last_update_login,
                request_id = l_request_id,
                program_id = l_program_id,
                program_application_id = l_program_application_id,
                program_update_date = l_program_update_date
          WHERE legacy_unt_int_id = l_av_untstd_cur_rec.legacy_unt_int_id;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK TO savepoint_av_untstd;
      END;
    END LOOP;

    log_no_data_exists(l_not_found);

    -- This will commit the changes to the interface table record.
    -- if an error was encountered then all the unwanted changes
    -- would have been rolled back by the rollback to savepoint.
    COMMIT WORK;

  EXCEPTION
    WHEN g_resource_busy THEN
      log_resource_busy(g_cst_av_untstd);
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igs_en_lgcy_prc.legacy_batch_process.process_av_untstd');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END process_av_untstd;



-------------------------------------------------------------------------------
  PROCEDURE process_as_uotcm (
              p_batch_id      IN NUMBER,
              p_deletion_flag IN BOOLEAN
  ) AS
    CURSOR c_as_uotcm  IS
    SELECT *
    FROM igs_as_lgcy_suo_int
    WHERE batch_id = p_batch_id
    AND   import_status IN ('U','R')
    FOR UPDATE NOWAIT;


    lr_as_uotcm_rec igs_as_suao_lgcy_pub.lgcy_suo_rec_type ;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER(4);
    l_msg_data      VARCHAR2(4000);

    l_last_update_date       DATE ;
    l_last_updated_by        NUMBER;
    l_last_update_login      NUMBER;
    l_request_id             NUMBER;
    l_program_id             NUMBER;
    l_program_application_id NUMBER;
    l_program_update_date    DATE;
    l_not_found              BOOLEAN;

  BEGIN
/*
   Process the records in the Assessment Outcome interface table
   where the import status is either 'U' - Unproccessed or 'R' ready for reporccessing
*/

    log_headers(g_cst_as_uotcm );
    l_not_found := TRUE;

    FOR l_as_uotcm_cur_rec IN c_as_uotcm  LOOP
      BEGIN

        -- create a save point. if there are any errors returned by
        -- the API then rollback to this savepoint before processing
        -- then next record.
        SAVEPOINT savepoint_as_uotcm ;
        l_not_found := FALSE;

        -- populate the record variable to pass to the API
        lr_as_uotcm_rec.person_number                 := l_as_uotcm_cur_rec.person_number ;
        lr_as_uotcm_rec.program_cd                    := l_as_uotcm_cur_rec.program_cd ;
        lr_as_uotcm_rec.unit_cd                       := l_as_uotcm_cur_rec.unit_cd ;
        lr_as_uotcm_rec.teach_cal_alt_code            := l_as_uotcm_cur_rec.teach_cal_alt_code ;
        lr_as_uotcm_rec.outcome_dt                    := l_as_uotcm_cur_rec.outcome_dt ;
        lr_as_uotcm_rec.grading_schema_cd             := l_as_uotcm_cur_rec.grading_schema_cd ;
        lr_as_uotcm_rec.version_number                := l_as_uotcm_cur_rec.version_number ;
        lr_as_uotcm_rec.grade                         := l_as_uotcm_cur_rec.grade ;
        lr_as_uotcm_rec.s_grade_creation_method_type  := l_as_uotcm_cur_rec.s_grade_creation_method_type ;
        lr_as_uotcm_rec.finalised_outcome_ind         := l_as_uotcm_cur_rec.finalised_outcome_ind ;
        lr_as_uotcm_rec.mark                          := l_as_uotcm_cur_rec.mark ;
        lr_as_uotcm_rec.incomp_deadline_date          := l_as_uotcm_cur_rec.incomp_deadline_date ;
        lr_as_uotcm_rec.incomp_grading_schema_cd      := l_as_uotcm_cur_rec.incomp_grading_schema_cd ;
        lr_as_uotcm_rec.incomp_version_number         := l_as_uotcm_cur_rec.incomp_version_number ;
        lr_as_uotcm_rec.incomp_default_grade          := l_as_uotcm_cur_rec.incomp_default_grade ;
        lr_as_uotcm_rec.incomp_default_mark           := l_as_uotcm_cur_rec.incomp_default_mark ;
        lr_as_uotcm_rec.comments                      := l_as_uotcm_cur_rec.comments ;
        lr_as_uotcm_rec.grading_period_cd             := l_as_uotcm_cur_rec.grading_period_cd ;
        lr_as_uotcm_rec.attribute_category            := l_as_uotcm_cur_rec.attribute_category ;
        lr_as_uotcm_rec.attribute1                    := l_as_uotcm_cur_rec.attribute1 ;
        lr_as_uotcm_rec.attribute2                    := l_as_uotcm_cur_rec.attribute2 ;
        lr_as_uotcm_rec.attribute3                    := l_as_uotcm_cur_rec.attribute3 ;
        lr_as_uotcm_rec.attribute4                    := l_as_uotcm_cur_rec.attribute4 ;
        lr_as_uotcm_rec.attribute5                    := l_as_uotcm_cur_rec.attribute5 ;
        lr_as_uotcm_rec.attribute6                    := l_as_uotcm_cur_rec.attribute6 ;
        lr_as_uotcm_rec.attribute7                    := l_as_uotcm_cur_rec.attribute7 ;
        lr_as_uotcm_rec.attribute8                    := l_as_uotcm_cur_rec.attribute8 ;
        lr_as_uotcm_rec.attribute9                    := l_as_uotcm_cur_rec.attribute9 ;
        lr_as_uotcm_rec.attribute10                   := l_as_uotcm_cur_rec.attribute10 ;
        lr_as_uotcm_rec.attribute11                   := l_as_uotcm_cur_rec.attribute11 ;
        lr_as_uotcm_rec.attribute12                   := l_as_uotcm_cur_rec.attribute12 ;
        lr_as_uotcm_rec.attribute13                   := l_as_uotcm_cur_rec.attribute13 ;
        lr_as_uotcm_rec.attribute14                   := l_as_uotcm_cur_rec.attribute14 ;
        lr_as_uotcm_rec.attribute15                   := l_as_uotcm_cur_rec.attribute15 ;
        lr_as_uotcm_rec.attribute16                   := l_as_uotcm_cur_rec.attribute16 ;
        lr_as_uotcm_rec.attribute17                   := l_as_uotcm_cur_rec.attribute17 ;
        lr_as_uotcm_rec.attribute18                   := l_as_uotcm_cur_rec.attribute18 ;
        lr_as_uotcm_rec.attribute19                   := l_as_uotcm_cur_rec.attribute19 ;
        lr_as_uotcm_rec.attribute20                   := l_as_uotcm_cur_rec.attribute20 ;
        lr_as_uotcm_rec.location_cd                   := l_as_uotcm_cur_rec.location_cd ;
        lr_as_uotcm_rec.unit_class                    := l_as_uotcm_cur_rec.unit_class ;

        l_return_status := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;
        igs_as_suao_lgcy_pub.create_unit_outcome(
                      P_API_VERSION      => 1.0,
                      P_INIT_MSG_LIST    => FND_API.G_TRUE,
                      P_COMMIT           => FND_API.G_FALSE,
                      P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                      p_lgcy_suo_rec     => lr_as_uotcm_rec,
                      X_RETURN_STATUS    => l_return_status,
                      X_MSG_COUNT        => l_msg_count,
                      X_MSG_DATA         => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_return_status IS NULL THEN
           ROLLBACK TO savepoint_as_uotcm;
           -- log the error message in the error message interface table
           log_err_messages(
             g_cst_as_uotcm,
             l_as_uotcm_cur_rec.legacy_suao_int_id,
             l_msg_count,
             l_msg_data,
             l_return_status
           );
        ELSE
          -- log the success message in the concurrent manager log.
          log_suc_message(l_as_uotcm_cur_rec.legacy_suao_int_id);
        END IF;

        IF p_deletion_flag AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          -- delete any records in the error message interface table
          delete_err_messages(
            p_int_table_code => g_cst_as_uotcm,
            p_int_table_id   => l_as_uotcm_cur_rec.legacy_suao_int_id
          );
          -- delete the interface record
          DELETE FROM igs_as_lgcy_suo_int
          WHERE legacy_suao_int_id = l_as_uotcm_cur_rec.legacy_suao_int_id;
        ELSE
          l_last_updated_by        := get_last_updated_by;
          l_last_update_date       := get_last_update_date;
          l_last_update_login      := get_last_update_login;
          l_request_id             := get_request_id;
          l_program_application_id := get_program_application_id;
          l_program_id             := get_program_id;
          l_program_update_date    := get_program_update_date;
          UPDATE igs_as_lgcy_suo_int
          SET import_status = DECODE(l_return_status,
                                     'S','I',
                                     'U','E',
                                     'W','W',
                                     'E'),
                last_update_date = l_last_update_date,
                last_updated_by = l_last_updated_by,
                last_update_login = l_last_update_login,
                request_id = l_request_id,
                program_id = l_program_id,
                program_application_id = l_program_application_id,
                program_update_date = l_program_update_date
          WHERE legacy_suao_int_id = l_as_uotcm_cur_rec.legacy_suao_int_id;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK TO savepoint_as_uotcm ;
      END;
    END LOOP;

    log_no_data_exists(l_not_found);

    -- This will commit the changes to the interface table record.
    -- if an error was encountered then all the unwanted changes
    -- would have been rolled back by the rollback to savepoint.
    COMMIT WORK;

  EXCEPTION
    WHEN g_resource_busy THEN
      log_resource_busy(g_cst_as_uotcm);
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igs_en_lgcy_prc.legacy_batch_process.process_as_uotcm');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END process_as_uotcm ;



-------------------------------------------------------------------------------
  PROCEDURE process_pr_out   (
              p_batch_id      IN NUMBER,
              p_deletion_flag IN BOOLEAN
  ) AS
    CURSOR c_pr_out    IS
    SELECT *
    FROM igs_pr_lgcy_spo_int
    WHERE batch_id = p_batch_id
    AND   import_status IN ('U','R')
    FOR UPDATE NOWAIT;


    lr_pr_out_rec   igs_pr_prout_lgcy_pub.lgcy_prout_rec_type;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER(4);
    l_msg_data      VARCHAR2(4000);

    l_last_update_date       DATE ;
    l_last_updated_by        NUMBER;
    l_last_update_login      NUMBER;
    l_request_id             NUMBER;
    l_program_id             NUMBER;
    l_program_application_id NUMBER;
    l_program_update_date    DATE;
    l_not_found              BOOLEAN;
  BEGIN
/*
   Process the records in the Progression Outcome interface table
   where the import status is either 'U' - Unproccessed or 'R' ready for reporccessing
*/

    log_headers(g_cst_pr_out);
    l_not_found := TRUE;

    FOR l_pr_out_cur_rec IN c_pr_out LOOP
      BEGIN

        -- create a save point. if there are any errors returned by
        -- the API then rollback to this savepoint before processing
        -- then next record.
        SAVEPOINT savepoint_pr_out;
        l_not_found := FALSE;

        -- populate the record variable to pass to the API
        lr_pr_out_rec.person_number                 := l_pr_out_cur_rec.person_number ;
        lr_pr_out_rec.program_cd                    := l_pr_out_cur_rec.program_cd ;
        lr_pr_out_rec.prg_cal_alternate_code        := l_pr_out_cur_rec.prg_cal_alternate_code ;
        lr_pr_out_rec.progression_outcome_type      := l_pr_out_cur_rec.progression_outcome_type ;
        lr_pr_out_rec.duration                      := l_pr_out_cur_rec.duration ;
        lr_pr_out_rec.duration_type                 := l_pr_out_cur_rec.duration_type ;
        lr_pr_out_rec.decision_status               := l_pr_out_cur_rec.decision_status ;
        lr_pr_out_rec.decision_dt                   := l_pr_out_cur_rec.decision_dt ;
        lr_pr_out_rec.decision_org_unit_cd          := l_pr_out_cur_rec.decision_org_unit_cd ;
        lr_pr_out_rec.show_cause_expiry_dt          := l_pr_out_cur_rec.show_cause_expiry_dt ;
        lr_pr_out_rec.show_cause_dt                 := l_pr_out_cur_rec.show_cause_dt ;
        lr_pr_out_rec.show_cause_outcome_dt         := l_pr_out_cur_rec.show_cause_outcome_dt ;
        lr_pr_out_rec.show_cause_outcome_type       := l_pr_out_cur_rec.show_cause_outcome_type ;
        lr_pr_out_rec.appeal_expiry_dt              := l_pr_out_cur_rec.appeal_expiry_dt ;
        lr_pr_out_rec.appeal_dt                     := l_pr_out_cur_rec.appeal_dt ;
        lr_pr_out_rec.appeal_outcome_dt             := l_pr_out_cur_rec.appeal_outcome_dt ;
        lr_pr_out_rec.appeal_outcome_type           := l_pr_out_cur_rec.appeal_outcome_type ;
        lr_pr_out_rec.encmb_program_group_cd        := l_pr_out_cur_rec.encmb_program_group_cd ;
        lr_pr_out_rec.restricted_enrolment_cp       := l_pr_out_cur_rec.restricted_enrolment_cp ;
        lr_pr_out_rec.restricted_attendance_type    := l_pr_out_cur_rec.restricted_attendance_type ;
        lr_pr_out_rec.comments                      := l_pr_out_cur_rec.comments ;
        lr_pr_out_rec.show_cause_comments           := l_pr_out_cur_rec.show_cause_comments ;
        lr_pr_out_rec.appeal_comments               := l_pr_out_cur_rec.appeal_comments ;
        lr_pr_out_rec.expiry_dt                     := l_pr_out_cur_rec.expiry_dt ;
        lr_pr_out_rec.award_cd                      := l_pr_out_cur_rec.award_cd ;
        lr_pr_out_rec.spo_program_cd                := l_pr_out_cur_rec.spo_program_cd ;
        lr_pr_out_rec.unit_cd                       := l_pr_out_cur_rec.unit_cd ;
        lr_pr_out_rec.s_unit_type                   := l_pr_out_cur_rec.s_unit_type ;
        lr_pr_out_rec.unit_set_cd                   := l_pr_out_cur_rec.unit_set_cd ;
        lr_pr_out_rec.us_version_number             := l_pr_out_cur_rec.us_version_number ;
        --anilk, Bug# 3021236, adding fund_code
        lr_pr_out_rec.fund_code                     := l_pr_out_cur_rec.fund_code ;


        l_return_status := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;
        igs_pr_prout_lgcy_pub.create_outcome(
                      P_API_VERSION      => 1.0,
                      P_INIT_MSG_LIST    => FND_API.G_TRUE,
                      P_COMMIT           => FND_API.G_FALSE,
                      P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                      p_lgcy_prout_rec   => lr_pr_out_rec,
                      X_RETURN_STATUS    => l_return_status,
                      X_MSG_COUNT        => l_msg_count,
                      X_MSG_DATA         => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_return_status IS NULL THEN
           ROLLBACK TO savepoint_pr_out;
           -- log the error message in the error message interface table
           log_err_messages(
             g_cst_pr_out,
             l_pr_out_cur_rec.legacy_pr_spo_int_id,
             l_msg_count,
             l_msg_data,
             l_return_status
           );
        ELSE
          -- log the success message in the concurrent manager log.
          log_suc_message(l_pr_out_cur_rec.legacy_pr_spo_int_id);
        END IF;

        IF p_deletion_flag AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          -- delete any records in the error message interface table
          delete_err_messages(
            p_int_table_code => g_cst_pr_out,
            p_int_table_id   => l_pr_out_cur_rec.legacy_pr_spo_int_id
          );
          -- delete the interface record
          DELETE FROM igs_pr_lgcy_spo_int
          WHERE legacy_pr_spo_int_id = l_pr_out_cur_rec.legacy_pr_spo_int_id;
        ELSE
          l_last_updated_by        := get_last_updated_by;
          l_last_update_date       := get_last_update_date;
          l_last_update_login      := get_last_update_login;
          l_request_id             := get_request_id;
          l_program_application_id := get_program_application_id;
          l_program_id             := get_program_id;
          l_program_update_date    := get_program_update_date;
          UPDATE igs_pr_lgcy_spo_int
          SET import_status = DECODE(l_return_status,
                                     'S','I',
                                     'U','E',
                                     'W','W',
                                     'E'),
                last_update_date = l_last_update_date,
                last_updated_by = l_last_updated_by,
                last_update_login = l_last_update_login,
                request_id = l_request_id,
                program_id = l_program_id,
                program_application_id = l_program_application_id,
                program_update_date = l_program_update_date
          WHERE legacy_pr_spo_int_id = l_pr_out_cur_rec.legacy_pr_spo_int_id;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK TO savepoint_pr_out;
      END;
    END LOOP;

    log_no_data_exists(l_not_found);

    -- This will commit the changes to the interface table record.
    -- if an error was encountered then all the unwanted changes
    -- would have been rolled back by the rollback to savepoint.
    COMMIT WORK;

  EXCEPTION
    WHEN g_resource_busy THEN
      log_resource_busy(g_cst_pr_out);
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igs_en_lgcy_prc.legacy_batch_process.process_pr_out');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END process_pr_out;

-------------------------------------------------------------------------------
  PROCEDURE process_pr_cr(
              p_batch_id      IN NUMBER,
              p_deletion_flag IN BOOLEAN
  ) AS
    CURSOR c_pr_cr IS
    SELECT *
    FROM igs_pr_lgy_clsr_int
    WHERE batch_id = p_batch_id
    AND   import_status IN ('U','R')
    FOR UPDATE NOWAIT;


    lr_pr_cr_rec   igs_pr_clsrnk_lgcy_pub.lgcy_clsrnk_rec_type;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER(4);
    l_msg_data      VARCHAR2(4000);

    l_last_update_date       DATE ;
    l_last_updated_by        NUMBER;
    l_last_update_login      NUMBER;
    l_request_id             NUMBER;
    l_program_id             NUMBER;
    l_program_application_id NUMBER;
    l_program_update_date    DATE;
    l_not_found              BOOLEAN;

  BEGIN
/*
   Process the records in the Class Rank interface table
   where the import status is either 'U' - Unproccessed or 'R' ready for reporccessing
*/

    log_headers(g_cst_pr_cr);
    l_not_found := TRUE;

    FOR l_pr_cr_cur_rec IN c_pr_cr LOOP
      BEGIN

        -- create a save point. if there are any errors returned by
        -- the API then rollback to this savepoint before processing
        -- then next record.
        SAVEPOINT savepoint_pr_cr;
        l_not_found := FALSE;

        -- populate the record variable to pass to the API
        lr_pr_cr_rec.person_number                 := l_pr_cr_cur_rec.person_number ;
        lr_pr_cr_rec.program_cd                    := l_pr_cr_cur_rec.program_cd ;
        lr_pr_cr_rec.cohort_name                   := l_pr_cr_cur_rec.cohort_name ;
        lr_pr_cr_rec.calendar_alternate_code       := l_pr_cr_cur_rec.calendar_alternate_code ;
        lr_pr_cr_rec.cohort_rank                   := l_pr_cr_cur_rec.cohort_rank ;
        lr_pr_cr_rec.cohort_override_rank          := l_pr_cr_cur_rec.cohort_override_rank ;
        lr_pr_cr_rec.comments                      := l_pr_cr_cur_rec.comments ;
        lr_pr_cr_rec.as_of_rank_gpa                := l_pr_cr_cur_rec.as_of_rank_gpa ;


        l_return_status := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;
        igs_pr_clsrnk_lgcy_pub.create_class_rank(
                      P_API_VERSION      => 1.0,
                      P_INIT_MSG_LIST    => FND_API.G_TRUE,
                      P_COMMIT           => FND_API.G_FALSE,
                      P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                      p_lgcy_clsrnk_rec  => lr_pr_cr_rec,
                      X_RETURN_STATUS    => l_return_status,
                      X_MSG_COUNT        => l_msg_count,
                      X_MSG_DATA         => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_return_status IS NULL THEN
           ROLLBACK TO savepoint_pr_cr;
           -- log the error message in the error message interface table
           log_err_messages(
             g_cst_pr_cr,
             l_pr_cr_cur_rec.legacy_cls_rank_int_id,
             l_msg_count,
             l_msg_data,
             l_return_status
           );
        ELSE
          -- log the success message in the concurrent manager log.
          log_suc_message(l_pr_cr_cur_rec.legacy_cls_rank_int_id);
        END IF;

        IF p_deletion_flag AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          -- delete any records in the error message interface table
          delete_err_messages(
            p_int_table_code => g_cst_pr_cr,
            p_int_table_id   => l_pr_cr_cur_rec.legacy_cls_rank_int_id
          );
          -- delete the interface record
          DELETE FROM igs_pr_lgy_clsr_int
          WHERE legacy_cls_rank_int_id = l_pr_cr_cur_rec.legacy_cls_rank_int_id;
        ELSE
          l_last_updated_by        := get_last_updated_by;
          l_last_update_date       := get_last_update_date;
          l_last_update_login      := get_last_update_login;
          l_request_id             := get_request_id;
          l_program_application_id := get_program_application_id;
          l_program_id             := get_program_id;
          l_program_update_date    := get_program_update_date;
          UPDATE igs_pr_lgy_clsr_int
          SET import_status = DECODE(l_return_status,
                                     'S','I',
                                     'U','E',
                                     'W','W',
                                     'E'),
                last_update_date = l_last_update_date,
                last_updated_by = l_last_updated_by,
                last_update_login = l_last_update_login,
                request_id = l_request_id,
                program_id = l_program_id,
                program_application_id = l_program_application_id,
                program_update_date = l_program_update_date
          WHERE legacy_cls_rank_int_id = l_pr_cr_cur_rec.legacy_cls_rank_int_id;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK TO savepoint_pr_cr;
      END;
    END LOOP;

    log_no_data_exists(l_not_found);

    -- This will commit the changes to the interface table record.
    -- if an error was encountered then all the unwanted changes
    -- would have been rolled back by the rollback to savepoint.
    COMMIT WORK;

  EXCEPTION
    WHEN g_resource_busy THEN
      log_resource_busy(g_cst_pr_cr);
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igs_en_lgcy_prc.legacy_batch_process.process_pr_cr');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END process_pr_cr;



-------------------------------------------------------------------------------
  PROCEDURE process_gr_grd(
              p_batch_id      IN NUMBER,
              p_deletion_flag IN BOOLEAN
  ) AS
    CURSOR c_gr_grd IS
    SELECT *
    FROM igs_gr_lgcy_grd_int
    WHERE batch_id = p_batch_id
    AND   import_status IN ('U','R')
    FOR UPDATE NOWAIT;


    lr_gr_grd_rec   igs_gr_grd_lgcy_pub.lgcy_grd_rec_type;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER(4);
    l_msg_data      VARCHAR2(4000);

    l_last_update_date       DATE ;
    l_last_updated_by        NUMBER;
    l_last_update_login      NUMBER;
    l_request_id             NUMBER;
    l_program_id             NUMBER;
    l_program_application_id NUMBER;
    l_program_update_date    DATE;
    l_not_found              BOOLEAN;

  BEGIN
/*
   Process the records in the Graduand interface table
   where the import status is either 'U' - Unproccessed or 'R' ready for reporccessing
*/

    log_headers(g_cst_gr_grd);
    l_not_found := TRUE;

    FOR l_gr_grd_cur_rec IN c_gr_grd LOOP
      BEGIN

        -- create a save point. if there are any errors returned by
        -- the API then rollback to this savepoint before processing
        -- then next record.
        SAVEPOINT savepoint_gr_grd;
        l_not_found := FALSE;

        -- populate the record variable to pass to the API
        lr_gr_grd_rec.person_number                 := l_gr_grd_cur_rec.person_number ;
        lr_gr_grd_rec.create_dt                     := l_gr_grd_cur_rec.create_dt ;
        lr_gr_grd_rec.grd_cal_alt_code              := l_gr_grd_cur_rec.grd_cal_alt_code ;
        lr_gr_grd_rec.program_cd                    := l_gr_grd_cur_rec.program_cd ;
        lr_gr_grd_rec.award_program_cd              := l_gr_grd_cur_rec.award_program_cd ;
        lr_gr_grd_rec.award_prog_version_number     := l_gr_grd_cur_rec.award_prog_version_number ;
        lr_gr_grd_rec.award_cd                      := l_gr_grd_cur_rec.award_cd ;
        lr_gr_grd_rec.graduand_status               := l_gr_grd_cur_rec.graduand_status ;
        lr_gr_grd_rec.graduand_appr_status          := l_gr_grd_cur_rec.graduand_appr_status ;
        lr_gr_grd_rec.s_graduand_type               := l_gr_grd_cur_rec.s_graduand_type ;
        lr_gr_grd_rec.graduation_name               := l_gr_grd_cur_rec.graduation_name ;
        lr_gr_grd_rec.proxy_award_person_number     := l_gr_grd_cur_rec.proxy_award_person_number ;
        lr_gr_grd_rec.previous_qualifications       := l_gr_grd_cur_rec.previous_qualifications ;
        lr_gr_grd_rec.convocation_membership_ind    := l_gr_grd_cur_rec.convocation_membership_ind ;
        lr_gr_grd_rec.sur_for_program_cd            := l_gr_grd_cur_rec.sur_for_program_cd ;
        lr_gr_grd_rec.sur_for_prog_version_number   := l_gr_grd_cur_rec.sur_for_prog_version_number ;
        lr_gr_grd_rec.sur_for_award_cd              := l_gr_grd_cur_rec.sur_for_award_cd ;
        lr_gr_grd_rec.comments                      := l_gr_grd_cur_rec.comments ;
        lr_gr_grd_rec.attribute_category            := l_gr_grd_cur_rec.attribute_category ;
        lr_gr_grd_rec.attribute1                    := l_gr_grd_cur_rec.attribute1 ;
        lr_gr_grd_rec.attribute2                    := l_gr_grd_cur_rec.attribute2 ;
        lr_gr_grd_rec.attribute3                    := l_gr_grd_cur_rec.attribute3 ;
        lr_gr_grd_rec.attribute4                    := l_gr_grd_cur_rec.attribute4 ;
        lr_gr_grd_rec.attribute5                    := l_gr_grd_cur_rec.attribute5 ;
        lr_gr_grd_rec.attribute6                    := l_gr_grd_cur_rec.attribute6 ;
        lr_gr_grd_rec.attribute7                    := l_gr_grd_cur_rec.attribute7 ;
        lr_gr_grd_rec.attribute8                    := l_gr_grd_cur_rec.attribute8 ;
        lr_gr_grd_rec.attribute9                    := l_gr_grd_cur_rec.attribute9 ;
        lr_gr_grd_rec.attribute10                   := l_gr_grd_cur_rec.attribute10 ;
        lr_gr_grd_rec.attribute11                   := l_gr_grd_cur_rec.attribute11 ;
        lr_gr_grd_rec.attribute12                   := l_gr_grd_cur_rec.attribute12 ;
        lr_gr_grd_rec.attribute13                   := l_gr_grd_cur_rec.attribute13 ;
        lr_gr_grd_rec.attribute14                   := l_gr_grd_cur_rec.attribute14 ;
        lr_gr_grd_rec.attribute15                   := l_gr_grd_cur_rec.attribute15 ;
        lr_gr_grd_rec.attribute16                   := l_gr_grd_cur_rec.attribute16 ;
        lr_gr_grd_rec.attribute17                   := l_gr_grd_cur_rec.attribute17 ;
        lr_gr_grd_rec.attribute18                   := l_gr_grd_cur_rec.attribute18 ;
        lr_gr_grd_rec.attribute19                   := l_gr_grd_cur_rec.attribute19 ;
        lr_gr_grd_rec.attribute20                   := l_gr_grd_cur_rec.attribute20 ;


        l_return_status := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;
        igs_gr_grd_lgcy_pub.create_graduand(
                      P_API_VERSION      => 1.0,
                      P_INIT_MSG_LIST    => FND_API.G_TRUE,
                      P_COMMIT           => FND_API.G_FALSE,
                      P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                      p_lgcy_grd_rec     => lr_gr_grd_rec,
                      X_RETURN_STATUS    => l_return_status,
                      X_MSG_COUNT        => l_msg_count,
                      X_MSG_DATA         => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_return_status IS NULL THEN
           ROLLBACK TO savepoint_gr_grd;
           -- log the error message in the error message interface table
           log_err_messages(
             g_cst_gr_grd,
             l_gr_grd_cur_rec.legacy_gr_int_id,
             l_msg_count,
             l_msg_data,
             l_return_status
           );
        ELSE
          -- log the success message in the concurrent manager log.
          log_suc_message(l_gr_grd_cur_rec.legacy_gr_int_id);
        END IF;

        IF p_deletion_flag AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          -- delete any records in the error message interface table
          delete_err_messages(
            p_int_table_code => g_cst_gr_grd,
            p_int_table_id   => l_gr_grd_cur_rec.legacy_gr_int_id
          );
          -- delete the interface record
          DELETE FROM igs_gr_lgcy_grd_int
          WHERE legacy_gr_int_id = l_gr_grd_cur_rec.legacy_gr_int_id;
        ELSE
          l_last_updated_by        := get_last_updated_by;
          l_last_update_date       := get_last_update_date;
          l_last_update_login      := get_last_update_login;
          l_request_id             := get_request_id;
          l_program_application_id := get_program_application_id;
          l_program_id             := get_program_id;
          l_program_update_date    := get_program_update_date;
          UPDATE igs_gr_lgcy_grd_int
          SET import_status = DECODE(l_return_status,
                                     'S','I',
                                     'U','E',
                                     'W','W',
                                     'E'),
                last_update_date = l_last_update_date,
                last_updated_by = l_last_updated_by,
                last_update_login = l_last_update_login,
                request_id = l_request_id,
                program_id = l_program_id,
                program_application_id = l_program_application_id,
                program_update_date = l_program_update_date
          WHERE legacy_gr_int_id = l_gr_grd_cur_rec.legacy_gr_int_id;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK TO savepoint_gr_grd;
      END;
    END LOOP;

    log_no_data_exists(l_not_found);

    -- This will commit the changes to the interface table record.
    -- if an error was encountered then all the unwanted changes
    -- would have been rolled back by the rollback to savepoint.
    COMMIT WORK;

  EXCEPTION
    WHEN g_resource_busy THEN
      log_resource_busy(g_cst_gr_grd);
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igs_en_lgcy_prc.legacy_batch_process.process_gr_grd');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END process_gr_grd;

-------------------------------------------------------------------------------
  -- anilk, transcript comments
  PROCEDURE process_as_trncmt(
              p_batch_id      IN NUMBER,
              p_deletion_flag IN BOOLEAN
  ) AS
    CURSOR c_as_trncmt IS
    SELECT *
    FROM igs_as_lgcy_stc_int
    WHERE batch_id = p_batch_id
    AND   import_status IN ('U','R')
    FOR UPDATE NOWAIT;


    lr_as_trncmt_rec   igs_as_trncmt_lgcy_pub.lgcy_trncmt_rec_type;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER(4);
    l_msg_data      VARCHAR2(4000);

    l_last_update_date       DATE ;
    l_last_updated_by        NUMBER;
    l_last_update_login      NUMBER;
    l_request_id             NUMBER;
    l_program_id             NUMBER;
    l_program_application_id NUMBER;
    l_program_update_date    DATE;
    l_not_found              BOOLEAN;

  BEGIN
/*
   Process the records in the Student Transcript Comments interface table
   where the import status is either 'U' - Unproccessed or 'R' ready for reporccessing
*/

    log_headers(g_cst_as_trncmt);
    l_not_found := TRUE;

    FOR l_as_trncmt_cur_rec IN c_as_trncmt LOOP
      BEGIN

        -- create a save point. if there are any errors returned by
        -- the API then rollback to this savepoint before processing
        -- then next record.
        SAVEPOINT savepoint_as_trncmt;
        l_not_found := FALSE;

        -- populate the record variable to pass to the API
        lr_as_trncmt_rec.comment_type_code              := l_as_trncmt_cur_rec.comment_type_code;
        lr_as_trncmt_rec.comment_txt                    := l_as_trncmt_cur_rec.comment_txt;
        lr_as_trncmt_rec.person_number                  := l_as_trncmt_cur_rec.person_number;
        lr_as_trncmt_rec.program_cd                     := l_as_trncmt_cur_rec.program_cd;
        lr_as_trncmt_rec.program_type                   := l_as_trncmt_cur_rec.program_type;
        lr_as_trncmt_rec.award_cd                       := l_as_trncmt_cur_rec.award_cd;
        lr_as_trncmt_rec.load_cal_alternate_cd          := l_as_trncmt_cur_rec.load_cal_alternate_cd;
        lr_as_trncmt_rec.unit_set_cd                    := l_as_trncmt_cur_rec.unit_set_cd;
        lr_as_trncmt_rec.us_version_number              := l_as_trncmt_cur_rec.us_version_number;
        lr_as_trncmt_rec.unit_cd                        := l_as_trncmt_cur_rec.unit_cd;
        lr_as_trncmt_rec.version_number                 := l_as_trncmt_cur_rec.version_number;
        lr_as_trncmt_rec.teach_cal_alternate_cd         := l_as_trncmt_cur_rec.teach_cal_alternate_cd;
        lr_as_trncmt_rec.location_cd                    := l_as_trncmt_cur_rec.location_cd;
        lr_as_trncmt_rec.unit_class                     := l_as_trncmt_cur_rec.unit_class;

        l_return_status := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;
        igs_as_trncmt_lgcy_pub.create_trncmt(
                      p_api_version      => 1.0,
                      p_init_msg_list    => FND_API.G_TRUE,
                      p_commit           => FND_API.G_FALSE,
                      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                      p_lgcy_trncmt_rec => lr_as_trncmt_rec,
                      x_return_status    => l_return_status,
                      x_msg_count        => l_msg_count,
                      x_msg_data         => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_return_status IS NULL THEN
           ROLLBACK TO savepoint_as_trncmt;
           -- log the error message in the error message interface table
           log_err_messages(
             g_cst_as_trncmt,
             l_as_trncmt_cur_rec.legacy_cmts_int_id,
             l_msg_count,
             l_msg_data,
             l_return_status
           );
        ELSE
          -- log the success message in the concurrent manager log.
          log_suc_message(l_as_trncmt_cur_rec.legacy_cmts_int_id);
        END IF;

        IF p_deletion_flag AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          -- delete any records in the error message interface table
          delete_err_messages(
            p_int_table_code => g_cst_as_trncmt,
            p_int_table_id   => l_as_trncmt_cur_rec.legacy_cmts_int_id
          );
          -- delete the interface record
          DELETE FROM igs_as_lgcy_stc_int
          WHERE legacy_cmts_int_id = l_as_trncmt_cur_rec.legacy_cmts_int_id;
        ELSE
          l_last_updated_by        := get_last_updated_by;
          l_last_update_date       := get_last_update_date;
          l_last_update_login      := get_last_update_login;
          l_request_id             := get_request_id;
          l_program_application_id := get_program_application_id;
          l_program_id             := get_program_id;
          l_program_update_date    := get_program_update_date;
          UPDATE igs_as_lgcy_stc_int
          SET import_status = DECODE(l_return_status,
                                     'S','I',
                                     'U','E',
                                     'W','W',
                                     'E'),
                last_update_date = l_last_update_date,
                last_updated_by = l_last_updated_by,
                last_update_login = l_last_update_login,
                request_id = l_request_id,
                program_id = l_program_id,
                program_application_id = l_program_application_id,
                program_update_date = l_program_update_date
          WHERE legacy_cmts_int_id = l_as_trncmt_cur_rec.legacy_cmts_int_id;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK TO savepoint_as_trncmt;
      END;
    END LOOP;

    log_no_data_exists(l_not_found);

  EXCEPTION
    WHEN g_resource_busy THEN
      log_resource_busy(g_cst_as_trncmt);
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igs_en_lgcy_prc.legacy_batch_process.process_as_trncmt');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END process_as_trncmt;



----------------------------------------------------------------------------------------------
  PROCEDURE process_en_spi_rcond(
              p_batch_id      IN NUMBER,
              p_deletion_flag IN BOOLEAN
  ) AS

    CURSOR c_en_spi_rcond IS
    SELECT  * from IGS_EN_SPI_RCOND_INTS
    WHERE import_status IN ('U','R')
    AND batch_id = p_batch_id
    FOR UPDATE NOWAIT;


    lr_en_spi_rcond_rec    IGS_EN_SPI_RCOND_LGCY_PUB.en_spi_rcond_rec_type  ;
    l_return_status  VARCHAR2(1);
    l_msg_count      NUMBER(4);
    l_msg_data       VARCHAR2(4000);

    l_last_update_date       DATE ;
    l_last_updated_by        NUMBER;
    l_last_update_login      NUMBER;
    l_request_id             NUMBER;
    l_program_id             NUMBER;
    l_program_application_id NUMBER;
    l_program_update_date    DATE;
    l_not_found              BOOLEAN;

  BEGIN
/*
   Process the records in the Student program intermission return conditions interface table
   where the import status is either 'U' - Unproccessed or 'R' ready for reporccessing
*/

    log_headers(g_cst_en_spi_rcond);
    l_not_found := TRUE;

    FOR l_en_spi_rcond_cur_rec IN c_en_spi_rcond LOOP
      BEGIN

        -- create a save point. if there are any errors returned by
        -- the API then rollback to this savepoint before processing
        -- then next record.
        SAVEPOINT savepoint_en_spi_rcond;
        l_not_found := FALSE;

        -- populate the record variable to pass to the API
        lr_en_spi_rcond_rec.person_number                 := l_en_spi_rcond_cur_rec.person_number ;
        lr_en_spi_rcond_rec.program_cd                    := l_en_spi_rcond_cur_rec.program_cd ;
        lr_en_spi_rcond_rec.start_dt                      := l_en_spi_rcond_cur_rec.start_dt ;
        lr_en_spi_rcond_rec.RETURN_CONDITION              := l_en_spi_rcond_cur_rec.RETURN_CONDITION;
	lr_en_spi_rcond_rec.status_code                   := l_en_spi_rcond_cur_rec.status_code ;
        lr_en_spi_rcond_rec.approved_dt                   := l_en_spi_rcond_cur_rec.approved_dt ;
        lr_en_spi_rcond_rec.approver_number               := l_en_spi_rcond_cur_rec.approver_number ;

        l_return_status := NULL;
        l_msg_count := NULL;
        l_msg_data := NULL;
        IGS_EN_SPI_RCOND_LGCY_PUB.create_student_intm_rcond(
                      P_API_VERSION      => 1.0,
                      P_INIT_MSG_LIST    => FND_API.G_TRUE,
                      P_COMMIT           => FND_API.G_FALSE,
                      P_VALIDATION_LEVEL => FND_API.G_VALID_LEVEL_FULL,
                      p_intm_rcond_rec   => lr_en_spi_rcond_rec,
                      X_RETURN_STATUS    => l_return_status,
                      X_MSG_COUNT        => l_msg_count,
                      X_MSG_DATA         => l_msg_data
        );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_return_status IS NULL THEN
           ROLLBACK TO savepoint_en_spi_rcond;
           -- log the error message in the error message interface table
           log_err_messages(
             g_cst_en_spi_rcond   ,
             l_en_spi_rcond_cur_rec.LGCY_EN_SPI_RCONS_INT_ID,
             l_msg_count,
             l_msg_data,
             l_return_status
           );
        ELSE
          -- log the success message in the concurrent manager log.
          log_suc_message(l_en_spi_rcond_cur_rec.LGCY_EN_SPI_RCONS_INT_ID );
        END IF;

        IF p_deletion_flag AND l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          -- delete any records in the error message interface table
          delete_err_messages(
            p_int_table_code => g_cst_en_spi_rcond,
            p_int_table_id   => l_en_spi_rcond_cur_rec.LGCY_EN_SPI_RCONS_INT_ID
          );

          -- delete the interface record
          DELETE FROM IGS_EN_SPI_RCOND_INTS
          WHERE   LGCY_EN_SPI_RCONS_INT_ID  = l_en_spi_rcond_cur_rec.LGCY_EN_SPI_RCONS_INT_ID  ;
        ELSE
          l_last_updated_by        := get_last_updated_by;
          l_last_update_date       := get_last_update_date;
          l_last_update_login      := get_last_update_login;
          l_request_id             := get_request_id;
          l_program_application_id := get_program_application_id;
          l_program_id             := get_program_id;
          l_program_update_date    := get_program_update_date;
          UPDATE IGS_EN_SPI_RCOND_INTS
          SET import_status = DECODE(l_return_status,
                                     'S','I',
                                     'U','E',
                                     'W','W',
                                     'E'),
                last_update_date = l_last_update_date,
                last_updated_by = l_last_updated_by,
                last_update_login = l_last_update_login,
                request_id = l_request_id,
                program_id = l_program_id,
                program_application_id = l_program_application_id,
                program_update_date = l_program_update_date
          WHERE  LGCY_EN_SPI_RCONS_INT_ID  = l_en_spi_rcond_cur_rec.LGCY_EN_SPI_RCONS_INT_ID  ;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
        ROLLBACK TO savepoint_en_spi_rcond;
      END;
    END LOOP;

    log_no_data_exists(l_not_found);

    -- This will commit the changes to the interface table record.
    -- if an error was encountered then all the unwanted changes
    -- would have been rolled back by the rollback to savepoint.
    COMMIT WORK;

  EXCEPTION
    WHEN g_resource_busy THEN
      log_resource_busy(g_cst_en_spi_rcond);
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','igs_en_lgcy_prc.legacy_batch_process.process_en_spi_rcond');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
  END process_en_spi_rcond;

-------------------------------------------------------------------------------
  PROCEDURE legacy_batch_process(
              errbuf        OUT NOCOPY VARCHAR2,
              retcode       OUT NOCOPY NUMBER,
              p_batch_id    IN NUMBER,
              p_table_code  IN VARCHAR2,
              p_delete_flag IN VARCHAR2
  ) AS

     CURSOR c_batch_desc IS
     SELECT description
     FROM   igs_en_lgcy_bat_int
     WHERE  batch_id = p_batch_id;

     l_description    igs_en_lgcy_bat_int.description%TYPE;
     l_deletion_flag  BOOLEAN;
     l_msg_text       FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
     l_msg_text0      FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
   BEGIN
/*
  This batch process  has two modes.
  1. When the p_table_code is passed as 'All'
  2. when the p_table_code is passed any other value

  In the first case all the interface tables will processed in the
  order in which the "IF" statments appear. This sequence is very
  important since the student unit attempt cannot be imported
  before the student program attempt is imported.

  It is also import to sort the individual records within the
  interface tables for processing. If a unit is transfered
  from another program then the original unit must be imported
  first and then the one to which it was transfered.
  These are taken care of in the individual procedure written in
  this package by way of the "Order by" clause.

  In the second case mentioned above, only one interface table
  would be processed corresponding to the table code that is passed
*/
     -- initializing the boolean value depending on the p_delete_flag
     -- if the p_delete_flag is 'Y' then set the boolean value to true
     -- other wise set the boolean value to false.

     igs_ge_gen_003.set_org_id(NULL);

     l_deletion_flag := FALSE;
     IF p_delete_flag IS NOT NULL AND p_delete_flag = 'Y' THEN
       l_deletion_flag := TRUE;
     END IF;

     OPEN  c_batch_desc;
     FETCH c_batch_desc INTO l_description;
     CLOSE c_batch_desc;

     FND_MESSAGE.SET_NAME('IGS','IGS_EN_BATCH_ID');
     l_msg_text := FND_MESSAGE.GET;

     FND_MESSAGE.SET_NAME('IGS','IGS_EN_REG_LOG_DESC');
     l_msg_text0 := FND_MESSAGE.GET;

     FND_FILE.PUT_LINE(FND_FILE.LOG,'================================================================================');
     FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
     FND_FILE.PUT_LINE(FND_FILE.LOG,l_msg_text || ': ' || p_batch_id || '    ' || l_msg_text0 || ': ' || l_description);
     FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
     FND_FILE.PUT_LINE(FND_FILE.LOG,'================================================================================');

     -- Call the procedure to process Student Program Attempt interface records
     IF p_table_code = g_cst_all OR p_table_code = g_cst_en_spa THEN
       process_en_spa(
         p_batch_id,
         l_deletion_flag
       );
     END IF;

     -- Call the procedure to process term records interface records
     IF p_table_code = g_cst_all OR p_table_code = g_cst_en_spat THEN
       process_en_spat (
         p_batch_id,
         l_deletion_flag
       );
     END IF;
   -- Call the procedure to process student unit attempt reference codes.

     IF p_table_code = g_cst_all OR p_table_code = g_cst_as_suarc THEN
       process_as_suarc(
         p_batch_id,
         l_deletion_flag
       );
     END IF;

     -- Call the procedure to process unit set attempt interface records.
     IF p_table_code = g_cst_all OR p_table_code = g_cst_en_susa THEN
       process_en_susa(
         p_batch_id,
         l_deletion_flag
       );
     END IF;

     -- Call the procedure to process progarm intermission interface records.
     IF p_table_code = g_cst_all OR p_table_code = g_cst_en_spi THEN
       process_en_spi(
         p_batch_id,
         l_deletion_flag
       );
     END IF;

        -- Call the procedure to process intermission return conditions
     IF p_table_code = g_cst_all OR p_table_code = g_cst_en_spi_rcond THEN
       process_en_spi_rcond(
         p_batch_id,
         l_deletion_flag
       );
     END IF;

     -- Call the procedure to process program award aim interface records.
     IF p_table_code = g_cst_all OR p_table_code = g_cst_en_spaa THEN
      process_en_spaa(
        p_batch_id,
        l_deletion_flag
      );
     END IF;

     -- Call the procedure to process research supervisor interface records.
     IF p_table_code = g_cst_all OR p_table_code = g_cst_re_sprvsr THEN
       process_re_sprvsr(
         p_batch_id,
         l_deletion_flag
       );
     END IF;

     -- Call the procedure to process research thesis interface records.
     IF p_table_code = g_cst_all OR p_table_code = g_cst_re_the THEN
       process_re_the(
         p_batch_id,
         l_deletion_flag
       );
     END IF;

     -- Call the procedure to process unit attempt interface records.
     IF p_table_code = g_cst_all OR p_table_code = g_cst_en_sua THEN
       process_en_sua(
         p_batch_id,
         l_deletion_flag
       );
     END IF;

     -- Call the procedure to process HESA program attempt interface records.
     IF p_table_code = g_cst_all OR p_table_code = g_cst_he_spa THEN
       process_he_spa(
         p_batch_id,
         l_deletion_flag
       );
     END IF;

     -- Call the procedure to process HESA Unit set attempt interface records.
     IF p_table_code = g_cst_all OR p_table_code = g_cst_he_susa THEN
       process_he_susa(
         p_batch_id,
         l_deletion_flag
       );
     END IF;

     -- Call the procedure to process advance standing level interface records.
     IF p_table_code = g_cst_all OR p_table_code = g_cst_av_avstdl THEN
       process_av_avstdl(
         p_batch_id,
         l_deletion_flag
       );
     END IF;

     -- Call the procedure to process advance standing unit interface records.
     IF p_table_code = g_cst_all OR p_table_code = g_cst_av_untstd THEN
       process_av_untstd(
         p_batch_id,
         l_deletion_flag
       );
     END IF;

     -- Call the procedure to process unit outcome interface records.
     IF p_table_code = g_cst_all OR p_table_code = g_cst_as_uotcm THEN
       process_as_uotcm(
         p_batch_id,
         l_deletion_flag
       );
     END IF;

     -- Call the procedure to process progression outcome interface records.
     IF p_table_code = g_cst_all OR p_table_code = g_cst_pr_out THEN
       process_pr_out(
         p_batch_id,
         l_deletion_flag
       );
     END IF;

     -- Call the procedure to process class rank interface records.
     IF p_table_code = g_cst_all OR p_table_code = g_cst_pr_cr THEN
       process_pr_cr(
         p_batch_id,
         l_deletion_flag
       );
     END IF;

     -- Call the procedure to process graduan interface records.
     IF p_table_code = g_cst_all OR p_table_code = g_cst_gr_grd THEN
       process_gr_grd(
         p_batch_id,
         l_deletion_flag
       );
     END IF;

     -- anilk, transcript comments
     -- Call the procedure to process transcript comments interface records.
     IF p_table_code = g_cst_all OR p_table_code = g_cst_as_trncmt THEN
       process_as_trncmt(
         p_batch_id,
         l_deletion_flag
       );
     END IF;


   EXCEPTION
      WHEN OTHERS THEN
        retcode:=2;
        Fnd_File.PUT_LINE(Fnd_File.LOG,SQLERRM);
        ERRBUF := Fnd_Message.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
   END legacy_batch_process;


END igs_en_lgcy_prc;

/
