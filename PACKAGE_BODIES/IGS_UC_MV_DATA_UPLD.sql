--------------------------------------------------------
--  DDL for Package Body IGS_UC_MV_DATA_UPLD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_MV_DATA_UPLD" AS
/* $Header: IGSUC31B.pls 120.5 2006/08/21 03:52:35 jbaber ship $ */

/*===============================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA        |
 |                            All rights reserved.                               |
 +===============================================================================+
 |                                                                               |
 | DESCRIPTION                                                                   |
 |      PL/SQL spec for package: IGS_UC_MV_DATA_UPLD                             |
 |                                                                               |
 | NOTES                                                                         |
 |     This is a Concurrent requeset set which segregates the data into          |
 |     dummy hercules table after checking and validating the data.              |
 |     This also rearranges the data in the record data spans more than          |
 |     one record.                                                               |
 |                                                                               |
 | HISTORY                                                                       |
 | Who         When           What                                               |
 | rbezawad    25-Sep-02    Modified w.r.t. UCFD06 Build, Bug No: 2574566.       |
 | rgangara    11-Nov-02    Added *G, *T transaction processing and modified     |
 |                          Acknowledgement/echo transaction processing to       |
 |                          update IGS_UC_TRANSACTIONS table directly as         |
 |                          part of UCFD02_Small_Systems Enh. Bug# 2643048       |
 |                          Also added validation for ensuring that files        |
                            are processed in seqeuence only.                     |
 | rgangara    27-Nov-02    Removed TRIM for CAMPUS fields in *C and *G          |
 |                          Added *G, *T in Checkdigit validation.               |
 | rgangara    28-Nov-02    Fixed review comments.                               |
 |                          Birthdate in (*N, *K) is sent as DDMMYY format       |
 |                          from UCAS.                                           |
 | rbezawad    02-Dec-02    Removed the TO_NUMBER() conversion while             |
 |                          importing data into IGS_UC_MV_IVSTARK.SPECIALNEEDS   |
 |                          column.  This is done w.r.t. Bug 2620166 as          |
 |                          there is change in Hercules data model.              |
 | ayedubat    12-Dec-02    Changed the transfer_to_stara procedure for          |
 |                          bug:2702489                                          |
 | rbezawad    17-Dec-02    Modified the transfer_ack_to_trans procedure to      |
 |                          remove the code which is loggig message              |
 |                          IGS_UC_TRAN_PROC_APPCH for 2nd time. Bug 2711183.    |
 | smaddali    29-jan-03    Modified procedure transfer_to_ivstarpqr ,for        |
 |                          UCCR005 build ,bug # 2749404.                        |
 | rbezawad    25-Feb-03    Modified procedure transfer_to_starpqr() w.r.t. Bug  |
 |                          2810932 for processing Previous results of an        |
 |                          applicant upto maximum 21 sets.                      |
 | rbezawad    06-Mar-03    Corrected the code to properly display the count of  |
 |                          successful records w.r.t Bug 2810665.                |
 | pmarada     11-Jun-03    Added ucas_cycle to uc_transaction table, as per     |
 |                          UCFD203-Multiple cycles build, bug 2669208           |
 | smaddali    30-Jun-03    Modified for Bug#2669208 , UCFD203 -multiple cycles  |
 | dsridhar    25-Jul-03    Bug No: 3022067, part of change request for UCAS     |
 |                          Application Calendar Mapping. Removed references to  |
 |                          calendar fields in igs_uc_cyc_defaults_pkg.          |
 | ayedubat    30-Jul-03    Changed the procedure,transfer_to_starw to replace   |
 |                          the column names substchoice1, substchoice2,         |
 |                          substchoice3, substchoice4, substchoice5,            |
 |                          substchoice6 and substchoice7 with choice1lost,      |
 |                          choice2lost, choice3lost, choice4lost, choice5lost,  |
 |                          choice6lost, choice7lost of igs_uc_istarw_ints for   |
 |                          bug, 2669208.                                        |
 | smaddali    07-Aug-03    Modified procedure logic for updating *N INTS record |
 |                          in *K and *N transaction processing procedures for   |
 |                          bug 3085770                                          |
 | smaddali    26-Aug-03    Modified procedure transfer_to_starpqr ,population of|
 |                          field Grade , as part of bug#3114629                 |
 | smaddali    04-Sep-03    Modified procedure transfer_to_starpqr , bug#3122898 |
 | rbezawad    13-Oct-03    Modified for ucfd209- Substitution Support build     |
 |                          bug#2669228.                                         |
 | jchakrab    27-Jul-04    Modified for UCFD308-UCAS 2005 Regulatory Changes    |
 | jbaber      12-Jul-05    Modified for UC315 - UCAS Support 2006               |
 | jbaber      23-Aug-05    Modified for UC307 - HERCULES Small Systems Support  |
 | anwest      18-Jan-06    Bug# 4950285 R12 Disable OSS Mandate                 |
 | anwest      29-May-06    Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES     |
 | jbaber      12-Jul-06    Modified for UC325 - UCAS Support 2007               |
 *==============================================================================*/

    -- Declare all Global variables and global constants
    g_record_cnt     NUMBER;
    g_success_cnt    NUMBER;

    -- smaddali added these cursors for bug#2669208 , ucfd203  build
    -- Get the current and configured cycles from defaults table
    CURSOR c_cycles IS
    SELECT MAX(configured_cycle) configured_cycle, MAX(current_cycle) current_cycle
    FROM   igs_uc_defaults  ;
    g_c_cycles          c_cycles%ROWTYPE ;

    -- get the cycle to which hercules is configured
    CURSOR c_ucas_cycle IS
    SELECT entry_year
    FROM igs_uc_ucas_control
    WHERE system_code = 'U'
    AND ucas_cycle = g_c_cycles.configured_cycle;
    c_ucas_cycle_rec  c_ucas_cycle%ROWTYPE ;

  FUNCTION is_numeric(
                      p_value  VARCHAR2
                     ) RETURN BOOLEAN AS

    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose    : function which return TRUE if the passed value
    ||               can be convertable into NUMBER else return FALSE.
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
        return_value := FALSE;
    END;

    RETURN return_value;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IS_NUMERIC - '||SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

  END is_numeric;


  FUNCTION get_numeric_choice(
                               p_char  VARCHAR2
                             ) RETURN NUMBER IS
    /*
    ||  Created By : rgangara
    ||  Created On : 11-Nov-02
    ||  Purpose    : Function which return a Numeric Choice Number if the incoming
    ||               Choice Number is an Alphabet
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
      l_num             NUMBER(2);
      l_ascii           NUMBER(2);
      l_a_ascii         NUMBER(2)       := ASCII('A');
    BEGIN

    IF ASCII(p_char) BETWEEN 49 and 57 THEN
        l_num := TO_NUMBER(p_char);

    ELSIF (UPPER(p_char) BETWEEN 'A' AND 'Z' ) THEN

        l_ascii := ASCII(UPPER(p_char));
        l_num := 10 + (l_ascii - l_a_ascii);
    ELSE
        l_num := 0;
        fnd_message.set_name('IGS', 'IGS_UC_INVALID_CHOICE');
        fnd_message.set_token('CHOICE',p_char);
        fnd_file.put_line( fnd_file.log, fnd_message.get());
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
    END IF;

    RETURN (l_num);

   EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','GET_NUMERIC_CHOICE - '||SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
   END get_numeric_choice;


  PROCEDURE validate_file_seq_num(
                                 p_marvin_id igs_uc_load_mv_t.marvin_id%TYPE,
                                 p_curr_seq_num igs_uc_load_mv_t.record_data%TYPE
                                ) is
      /*
    ||  Created By : rgangara
    ||  Created On : 22-Nov-02
    ||  Purpose : To validate that the incoming flat files are being processed in sequence otherwise display suitable error message and stop processing.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  smaddali        30-jun-03       modified for ucfd203 - multiple cycles build ,bug#2669208
    ||                                  to get the marvin seq no from igs_uc_cyc_defaults, since
    ||                                  igs_uc_adm_systems is obsolete
    ||  dsridhar        25-JUL-2003     Bug No: 3022067, part of change request for UCAS Application Calendar Mapping.
    ||                                  Removed references to calendar fields in igs_uc_cyc_defaults_pkg.
    ||  (reverse chronological order - newest change first)
    */

        -- To identify the system to which the file sequence number transaction has come.
        -- 'AE' transactions are the 1st record after header which contains the system to which the section belongs.
        -- The earlier record to the 'AE' transaction contains header info which can be used for system identification.
        CURSOR cur_ae_trans IS
        SELECT file_type
        FROM igs_uc_load_mv_t
        WHERE marvin_id         = p_marvin_id - 1;

        -- Cursor to get the existing sequence number for the coresponding system
        -- smaddali modified cursor for bug #2669208 , ucfd203 build, igs_uc_adm_systems is now merged with igs_uc_defaults
        CURSOR c_cyc_defaults(cp_syscode igs_uc_cyc_defaults.system_code%TYPE) IS
        SELECT a.rowid , a.* , b.name
        FROM   igs_uc_cyc_defaults a , igs_uc_defaults b
        WHERE  a.system_code    = b.system_code
         AND a.system_code      = cp_syscode
         AND a.ucas_cycle       = g_c_cycles.configured_cycle ;

        ae_trans_rec            cur_ae_trans%ROWTYPE;
        cyc_defaults_rec        c_cyc_defaults%ROWTYPE;

  BEGIN
    OPEN cur_ae_trans;
    FETCH cur_ae_trans INTO ae_trans_rec;
    CLOSE cur_ae_trans;

    IF ae_trans_rec.file_type IS NOT NULL THEN
          -- get the earlier marvin seqence number
          OPEN c_cyc_defaults (ae_trans_rec.file_type);
          FETCH c_cyc_defaults INTO cyc_defaults_rec;
          CLOSE c_cyc_defaults;

          -- log a message displaying the system and the section number being processed.
          fnd_message.set_name('IGS', 'IGS_UC_MV_PROC_SEQ');
          fnd_message.set_token('SYSTEM', cyc_defaults_rec.name);
          fnd_message.set_token('SEQ', p_curr_seq_num);
          fnd_file.put_line(fnd_file.log, fnd_message.get());

          --Update the Marvin file seq number in the setup table.
          igs_uc_cyc_defaults_pkg.update_row (
                                             x_rowid              =>   cyc_defaults_rec.rowid,
                                             x_system_code        =>   cyc_defaults_rec.system_code,
                                             x_ucas_cycle         =>   cyc_defaults_rec.ucas_cycle,
                                             x_ucas_interface     =>   cyc_defaults_rec.ucas_interface,
                                             x_marvin_seq         =>   p_curr_seq_num,
                                             x_clearing_flag      =>   cyc_defaults_rec.clearing_flag,
                                             x_extra_flag         =>   cyc_defaults_rec.extra_flag,
                                             x_cvname_flag        =>   cyc_defaults_rec.cvname_flag,
                                             x_mode               =>   'R'
                                             );

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','VALIDATE_FILE_SEQ_NUM - '||SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
  END validate_file_seq_num;


  FUNCTION sequence_validity RETURN BOOLEAN IS
      /*
    ||  Created By : smaddali
    ||  Created On : 9-jul-03
    ||  Purpose : To validate that the incoming flat files have the correct marvin sequence number
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

        -- Get the details of AE transactions
        CURSOR cur_seq IS
        SELECT marvin_id, record_data
        FROM igs_uc_load_mv_t
        WHERE trans_type        = 'AE' ;

        -- To identify the system to which the file sequence number transaction has come.
        -- 'AE' transactions are the 1st record after header which contains the system to which the section belongs.
        -- The earlier record to the 'AE' transaction contains header info which can be used for system identification.
        CURSOR cur_ae_trans (cp_marvin_id igs_uc_load_mv_t.marvin_id%TYPE ) IS
        SELECT file_type
        FROM igs_uc_load_mv_t
        WHERE marvin_id         = cp_marvin_id - 1;

        -- Cursor to get the existing sequence number for the coresponding system
        -- smaddali modified cursor for bug #2669208 , ucfd203 build, igs_uc_adm_systems is now merged with igs_uc_defaults
        CURSOR c_cyc_defaults(cp_syscode igs_uc_cyc_defaults.system_code%TYPE) IS
        SELECT a.rowid , a.* , b.name
        FROM   igs_uc_cyc_defaults a , igs_uc_defaults b
        WHERE  a.system_code    = b.system_code
         AND a.system_code      = cp_syscode
         AND a.ucas_cycle       = g_c_cycles.configured_cycle ;

        ae_trans_rec            cur_ae_trans%ROWTYPE;
        cyc_defaults_rec        c_cyc_defaults%ROWTYPE;
        l_appno                 VARCHAR2(8);
        l_valid                 BOOLEAN ;
        l_curr_seq_num          NUMBER  ;

  BEGIN
       -- initialise variable
       l_valid  := TRUE ;

       -- loop thru all the AE transactions
       FOR cur_seq_rec IN cur_seq LOOP

            l_curr_seq_num      :=  SUBSTR(cur_seq_rec.record_data,4) ;
            ae_trans_rec        :=  NULL ;
            OPEN cur_ae_trans( cur_seq_rec.marvin_id );
            FETCH cur_ae_trans INTO ae_trans_rec;
            CLOSE cur_ae_trans;

            IF ae_trans_rec.file_type IS NOT NULL THEN
               -- check whether the system exists and get the earlier marvin seqence number
               cyc_defaults_rec         := NULL ;
               OPEN c_cyc_defaults (ae_trans_rec.file_type);
               FETCH c_cyc_defaults INTO cyc_defaults_rec;
               IF c_cyc_defaults%NOTFOUND THEN
                          CLOSE c_cyc_defaults;
                          fnd_message.set_name('IGS', 'IGS_UC_MV_SYSTEM_NOT_CONFIG');
                          fnd_message.set_token('SYSTEM', ae_trans_rec.file_type );
                          fnd_file.put_line( fnd_file.log, fnd_message.get());
                          l_valid       := FALSE ;
               ELSE
                          CLOSE c_cyc_defaults;
               END IF;

               -- check whether the current file/section being processed is immediate next to earlier processed seq.
               IF NVL(cyc_defaults_rec.marvin_seq,0) <> (l_curr_seq_num - 1) THEN
                          fnd_message.set_name('IGS', 'IGS_UC_MV_FILE_NOT_SEQ');
                          fnd_message.set_token('SYSTEM', cyc_defaults_rec.name);
                          fnd_message.set_token('OLDSEQ', NVL(cyc_defaults_rec.marvin_seq,0));
                          fnd_message.set_token('CURSEQ', l_curr_seq_num);
                          fnd_file.put_line(fnd_file.log, fnd_message.get());
                          l_valid       := FALSE ;
               END IF;

            END IF;
      END LOOP ;

      RETURN l_valid ;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','SEQUENCE_VALIDITY - '||SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
  END sequence_validity;



  FUNCTION get_check_digit(
                           p_appno  VARCHAR2
                          ) RETURN  NUMBER AS

    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose :
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||  anwest          29-May-2006     Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
    */
    ln_chk_digit        NUMBER          := 0;
    lv_weight           VARCHAR2(8)     := '13791379';
    lv_appno            VARCHAR2(8);

    -- 29-MAY-2006 anwest Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
    --                    This code has been added to accommodate the UCAS
    --                    error in calculating the check digit incorrectly
    --                    for this application range by using the incorrect
    --                    weighting
    lv_weight_alt       VARCHAR2(8) := '03790379';
    lv_appno_alt_min    NUMBER      := 6000999;
    lv_appno_alt_max    NUMBER      := 6009996;


  BEGIN

    -- Calculte the check digit.
    lv_appno            := LPAD(p_appno,8,0);
    FOR i IN 1..8 LOOP

        -- 29-MAY-2006 anwest Bug #5190520 UCTD320 - UCAS 2006 CLEARING ISSUES
        --                    This code has been added to accommodate the UCAS
        --                    error in calculating the check digit incorrectly
        --                    for this application range by using the incorrect
        --                    weighting
        IF TO_NUMBER(lv_appno) >= lv_appno_alt_min AND TO_NUMBER(lv_appno) <= lv_appno_alt_max THEN
            ln_chk_digit := ln_chk_digit + TO_NUMBER(SUBSTR(lv_appno,i,1)) * TO_NUMBER(SUBSTR(lv_weight_alt,i,1));
        ELSE
            ln_chk_digit := ln_chk_digit + TO_NUMBER(SUBSTR(lv_appno,i,1)) * TO_NUMBER(SUBSTR(lv_weight,i,1));
        END IF;

    END LOOP;

       ln_chk_digit     := 10-MOD(ln_chk_digit,10);

    RETURN MOD(ln_chk_digit,10);

  EXCEPTION
    WHEN VALUE_ERROR THEN
      RETURN -1;

  END get_check_digit;


  PROCEDURE transfer_to_stara(
                              p_trans_type     igs_uc_load_mv_t.trans_type%TYPE,
                              p_record_data    igs_uc_load_mv_t.record_data%TYPE
                             ) AS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose    : Inserts the given *A transaction record into igs_uc_mv_ivstara table
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  ayedubat      12-DEC-2002     Passed the SYSDATE for TIMESTAMP column for bug fix:2702489
    || smaddali  30-jun-03            Modified for ucfd203- multiple cycles build , bug#2669208
    ||                                replaced igs_uc_mv_ivstara with igs_uc_istara_ints
    ||  (reverse chronological order - newest change first)
    */

      ln_appno igs_uc_istara_ints.appno%TYPE    := TO_NUMBER(TRIM(SUBSTR(p_record_data,1,8)));

  BEGIN

    fnd_message.set_name('IGS', 'IGS_UC_TRAN_PROC_APP');
    fnd_message.set_token('TTYPE','*A ');
    fnd_message.set_token('APPNO', ln_appno);
    fnd_file.put_line( fnd_file.log, fnd_message.get());

      -- Obsolete matching records in interface table with status N
      UPDATE igs_uc_istara_ints SET record_status = 'O'
      WHERE record_status       = 'N' AND appno = ln_appno ;

      INSERT INTO igs_uc_istara_ints(
                                  appno,
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
                                 VALUES
                                 (
                                  ln_appno,                                             -- APPNO,
                                  TRIM(SUBSTR(p_record_data,17,1)),                     -- ADDRESSAREA,
                                  TRIM(SUBSTR(p_record_data,18,27)),                    -- ADDRESS1,
                                  TRIM(SUBSTR(p_record_data,45,27)),                    -- ADDRESS2,
                                  TRIM(SUBSTR(p_record_data,72,27)),                    -- ADDRESS3,
                                  TRIM(SUBSTR(p_record_data,99,27)),                    -- ADDRESS4,
                                  TRIM(SUBSTR(p_record_data,126,8)),                    -- POSTCODE,
                                  TRIM(SUBSTR(p_record_data,134,5)),                    -- MAILSORT,
                                  TRIM(SUBSTR(p_record_data,139,20)),                   -- TELEPHONE,
                                  NULL,                                                 -- FAX
                                  NULL,                                                 -- EMAIL,
                                  NULL,                                                 -- HOMEADDRESS1,
                                  NULL,                                                 -- HOMEADDRESS2,
                                  NULL,                                                 -- HOMEADDRESS3,
                                  NULL,                                                 -- HOMEADDRESS4,
                                  NULL,                                                 -- HOMEPOSTCODE,
                                  NULL,                                                 -- HOMEPHONE,
                                  NULL,                                                 -- HOMEFAX
                                  NULL,                                                 -- HOMEEMAIL
                                  'N',                                                  -- RECORD_STATUS,
                                  NULL                                                  -- ERROR_CODE,
                                 );

        -- Increase the success record count.
        g_success_cnt := g_success_cnt +1;

  EXCEPTION
    WHEN VALUE_ERROR THEN
        fnd_message.set_name('IGS', 'IGS_UC_NON_NUMERIC_DATA');
        fnd_message.set_token('TTYPE',p_trans_type);
        fnd_file.put_line( fnd_file.log, fnd_message.get());
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_UC_MV_DATA_UPLD.TRANSFER_TO_STARA - '||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END transfer_to_stara;


  PROCEDURE transfer_to_starc(
                              p_trans_type     igs_uc_load_mv_t.trans_type%TYPE,
                              p_record_data    igs_uc_load_mv_t.record_data%TYPE
                             ) AS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose    : Inserts the given *C transaction record into igs_uc_mv_ivstarc table
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||
    ||  rbezawad        24-Sep-2002    Added code to populate igs_uc_mv_ivstarc.EXTRAROUND column value from 58-60 column positions.
    ||                                 Modified w.r.t. UCFD06 Build 2574566.
    ||  rgangara        11-Nov-02      Added logic to insert into IVSTARC extension table to hold
    ||                                 additional *C data for small systems support. Bug 2643048.
    ||                                 Changed the Inst field positions from 18,4 to 18,3 after discussing with Martin
    ||                                 as the table has it as 3 chars and was erroring out.
    || smaddali  30-jun-03              Modified for ucfd203- multiple cycles build , bug#2669208
    ||                                  replaced igs_uc_mv_ivstarc with igs_uc_istarc_ints which
    ||                                  includes columns of igs_uc_ss_ivstarc table also
    || rbezawad  13-Oct-03             Modified for ucfd209- Substitution Support build , bug#2669228
    */

      l_char_choice     VARCHAR2(1)                     := TRIM(SUBSTR(p_record_data,17,1));
      l_num_choice      NUMBER(2);
      ln_appno          igs_uc_istarc_ints.appno%TYPE   := TO_NUMBER(TRIM(SUBSTR(p_record_data,1,8)));
      l_reason_for_transmission VARCHAR2(1)             := TRIM(SUBSTR(p_record_data,10,1));
      l_rowid VARCHAR2(25);
      l_sql_stmt    VARCHAR2(500);

      -- Check any record with passed AppNo exists in IGS_UC_ISTARW_INTS with record_status = 'N'
      CURSOR cur_wrong_app (cp_appno igs_uc_istarw_ints.appno%TYPE) IS
        SELECT w.ROWID
        FROM igs_uc_istarw_ints w
        WHERE w.appno = cp_appno
        AND  w.record_status = 'N';

  BEGIN

      fnd_message.set_name('IGS', 'IGS_UC_TRAN_PROC_APPCH');
      fnd_message.set_token('TTYPE','*C ');
      fnd_message.set_token('APPNO', ln_appno);
      fnd_message.set_token('CHOICENO', l_char_choice);
      fnd_file.put_line( fnd_file.log, fnd_message.get());

      --Added as part of UCFD02 build for GTTR system.
      --If the incoming CHOICE No. is Alphabetic then it has to be converted to appropriate Number and used.
      -- i.e. if the incoming Choice No = 'A' then Choice No = 10, If it is 'F' then Choice = 15 etc.
      IF NOT ASCII(l_char_choice) BETWEEN 49 AND 57 THEN
                l_num_choice := get_numeric_choice(l_char_choice);
      ELSE
                l_num_choice := TO_NUMBER(l_char_choice);
      END IF;

      IF l_reason_for_transmission = 'R' THEN
        --When Reason For Transmission i.e Character position 10 = 'R'

        l_rowid := NULL;
        OPEN  cur_wrong_app (ln_appno);
        FETCH cur_wrong_app INTO l_rowid;
        CLOSE cur_wrong_app;

        --Check any record with this AppNo exists in IGS_UC_ISTARW_INTS with record_status = 'N'
        IF l_rowid IS NOT NULL THEN
          IF l_num_choice BETWEEN 1 AND 7 THEN
            --The update should be such that other choicelost fields should retain their existing values
            -- and only the current choice related choicelost field value should get updated in the IGS_UC_ISTARW_INTS table.
            l_sql_stmt := 'UPDATE igs_uc_istarw_ints SET choice'||l_num_choice||'lost = ''Y'' WHERE ROWID = :1';
            EXECUTE IMMEDIATE l_sql_stmt USING l_rowid;
          END IF;

        ELSE
          --Insert a new record into IGS_UC_ISTARW_INTS
          INSERT INTO igs_uc_istarw_ints(
                                  appno,
                                  miscoded,
                                  cancelled,
                                  canceldate,
                                  remark,
                                  jointadmission,
                                  choice1lost,
                                  choice2lost,
                                  choice3lost,
                                  choice4lost,
                                  choice5lost,
                                  choice6lost,
                                  choice7lost,
                                  record_status,
                                  error_code
                                 )
                                 VALUES
                                 (
                                  ln_appno,                                              -- APPNO,
                                  'N',                                                   -- MISCODED,
                                  'N',                                                   -- CANCELLED,
                                  NULL,                                                  -- CANCELDATE,
                                  NULL,                                                  -- REMARK,
                                  'N',                                                   -- JOINTADMISSION
                                  DECODE(l_num_choice,1,'Y','N'),                        -- CHOICE1LOST
                                  DECODE(l_num_choice,2,'Y','N'),                        -- CHOICE2LOST
                                  DECODE(l_num_choice,3,'Y','N'),                        -- CHOICE3LOST
                                  DECODE(l_num_choice,4,'Y','N'),                        -- CHOICE4LOST
                                  DECODE(l_num_choice,5,'Y','N'),                        -- CHOICE5LOST
                                  DECODE(l_num_choice,6,'Y','N'),                        -- CHOICE6LOST
                                  DECODE(l_num_choice,7,'Y','N'),                        -- CHOICE7LOST
                                  'N',                                                   -- RECORD_STATUS,
                                  NULL                                                   -- ERROR_CODE
                                 );
        END IF;

      ELSE
        --When Reason For Transmission i.e Character position 10 <> 'R'
        -- Obsolete matching records in interface table with status N
        UPDATE igs_uc_istarc_ints SET record_status = 'O'
        WHERE record_status       = 'N' AND appno = ln_appno
        AND choiceno = l_num_choice AND ucas_cycle= g_c_cycles.configured_cycle;

        INSERT INTO igs_uc_istarc_ints(
                                  appno,
                                  choiceno,
                                  ucas_cycle,
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
                                  error_code
                                 )
                                 VALUES
                                 (
                                  ln_appno,                                            -- APPNO,
                                  l_num_choice,                                        -- CHOICENO,
                                  g_c_cycles.configured_cycle,                         -- UCAS_CYCLE,
                                  TO_DATE(TRIM(SUBSTR(p_record_data,11,6)), 'DDMMRR'), -- LASTCHANGE,
                                  TRIM(SUBSTR(p_record_data,18,3)),                    -- INST,
                                  TRIM(SUBSTR(p_record_data,22,6)),                    -- COURSE,
                                  DECODE(RTRIM(SUBSTR(p_record_data,28,1)),NULL,
                                  '*',SUBSTR(p_record_data,28,1)) ,                    -- CAMPUS,
                                  TRIM(SUBSTR(p_record_data,29,1)),                    -- FACULTY,
                                  TRIM(SUBSTR(p_record_data,54,1)),                    -- HOME,
                                  TRIM(SUBSTR(p_record_data,30,1)),                    -- DECISION,
                                  NULL,                                                -- DECISIONDATE,
                                  NULL,                                                -- DECISIONNUMBER,
                                  TRIM(SUBSTR(p_record_data,31,1)),                    -- REPLY,
                                  TRIM(SUBSTR(p_record_data,32,6)),                    -- SUMMARYCONDITIONS,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,40,2))),         -- ENTRYMONTH,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,38,2))),         -- ENTRYYEAR,
                                  TRIM(SUBSTR(p_record_data,55,1)),                    -- ENTRYPOINT,
                                  DECODE(TRIM(SUBSTR(p_record_data,42,1)),'C','Y','N'),-- CHOICECANCELLED,
                                  TRIM(SUBSTR(p_record_data,43,1)),                    -- ACTION,
                                  TRIM(SUBSTR(p_record_data,44,1)),                    -- SUBSTITUTION,
                                  NULL,                                                -- DATESUBSTITUTED,
                                  NULL,                                                -- PREVIOUSINST,
                                  TRIM(SUBSTR(p_record_data,46,6)),                    -- PREVIOUSCOURSE,
                                  NULL,                                                -- PREVIOUSCAMPUS,
                                  TRIM(SUBSTR(p_record_data,45,1)),                    -- UCASAMENDMENT,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,56,1))),         -- ROUTEBPREF,
                                  NULL,                                                -- ROUTEBROUND,
                                  NULL,                                                -- DETAIL
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,58,3))),         -- EXTRAROUND,
                                  DECODE(TRIM(SUBSTR(p_record_data,57,1)),'R','Y','N'),-- RESIDENTIAL,
                                  'N',                                                 -- RECORD_STATUS,
                                  NULL                                                 -- ERROR_CODE
                                 );

      END IF;

      -- Increase the success record count.
      g_success_cnt := g_success_cnt +1;

  EXCEPTION
    WHEN VALUE_ERROR THEN
        fnd_message.set_name('IGS', 'IGS_UC_NON_NUMERIC_DATA');
        fnd_message.set_token('TTYPE',p_trans_type);
        fnd_file.put_line( fnd_file.log, fnd_message.get());
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_UC_MV_DATA_UPLD.TRANSFER_TO_STARC - '||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END transfer_to_starc;


  PROCEDURE transfer_to_starg(
                              p_trans_type     igs_uc_load_mv_t.trans_type%TYPE,
                              p_record_data    igs_uc_load_mv_t.record_data%TYPE
                             ) AS
    /*
    ||  Created By : rgangara
    ||  Created On : 11-Nov-02
    ||  Purpose    : Inserts the given *G (GTTR Referral Details) transaction data into igs_uc_mv_ivstarG table
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    || smaddali  30-jun-03              Modified for ucfd203- multiple cycles build , bug#2669208
    ||                                  replaced igs_uc_mv_ivstarg with igs_uc_istarg_ints
    ||  (reverse chronological order - newest change first)
    ||
    */

      l_char_choice     VARCHAR2(1)                     := TRIM(SUBSTR(p_record_data,17,1));
      l_num_choice      NUMBER(2);
      ln_appno          igs_uc_istarg_ints.appno%TYPE   := TO_NUMBER(TRIM(SUBSTR(p_record_data,1,8)));


  BEGIN

      fnd_message.set_name('IGS', 'IGS_UC_TRAN_PROC_APPCH');
      fnd_message.set_token('TTYPE','*G ');
      fnd_message.set_token('APPNO', ln_appno);
      fnd_message.set_token('CHOICENO', l_char_choice);
      fnd_file.put_line( fnd_file.log, fnd_message.get());

      --Added as part of UCFD02 build for GTTR system.
      --If the incoming CHOICE No. is Alphabetic then it has to be converted to appropriate Number and used.
      -- i.e. if the incoming Choice No = 'A' then Choice No = 10, If it is 'F' then Choice = 15 etc.
      IF NOT ASCII(l_char_choice) BETWEEN 49 and 57 THEN
                l_num_choice := get_numeric_choice(l_char_choice);
      ELSE
                l_num_choice := TO_NUMBER(l_char_choice);
      END IF;

      -- Obsolete matching records in interface table with status N
      UPDATE igs_uc_istarg_ints SET record_status = 'O'
      WHERE record_status       = 'N' AND appno = ln_appno
      AND roundno = l_num_choice ;


      INSERT INTO igs_uc_istarg_ints(
                                  appno            ,
                                  roundno          ,
                                  ucas_cycle        ,
                                  lastchange       ,
                                  inst             ,
                                  course           ,
                                  campus           ,
                                  parttime         ,
                                  decision         ,
                                  reply            ,
                                  entryyear        ,
                                  entrymonth       ,
                                  action           ,
                                  interview        ,
                                  lateapplication  ,
                                  modular          ,
                                  confirmed        ,
                                  gcseeng         ,
                                  gcsemath        ,
                                  degreesubject   ,
                                  degreestatus    ,
                                  degreeclass     ,
                                  gcsesci         ,
                                  record_status,
                                  error_code
                                 )
                                 VALUES
                                 (
                                  ln_appno,                                            -- APPNO,
                                  l_num_choice,                                        -- ROUNDNO
                                  g_c_cycles.configured_cycle,                         -- UCAS_CYCLE,
                                  TO_DATE(TRIM(SUBSTR(p_record_data,11,6)),'DDMMRR'),  -- LASTCHANGE
                                  TRIM(SUBSTR(p_record_data,18,3)),                    -- INST     Though as per Manual 4 chars, take it as 3 since our table has 3
                                  TRIM(SUBSTR(p_record_data,22,6)),                    -- COURSE
                                  DECODE(RTRIM(SUBSTR(p_record_data,28,1)),NULL,
                                  '*',SUBSTR(p_record_data,28,1) ) ,                   -- CAMPUS
                                  DECODE(TRIM(SUBSTR(p_record_data,30,1)),'P','Y','N'),-- PARTTIME
                                  TRIM(SUBSTR(p_record_data,31,1)),                    -- DECISION
                                  TRIM(SUBSTR(p_record_data,32,1)),                    -- REPLY
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,33,2))),         -- ENTRYYEAR
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,53,2))),         -- ENTRYMONTH
                                  TRIM(SUBSTR(p_record_data,35,1)),                    -- ACTION
                                  TO_DATE(TRIM(SUBSTR(p_record_data,44,6)), 'DDMMRR'), -- INTERVIEW
                                  DECODE(TRIM(SUBSTR(p_record_data,51,1)),'L','Y','N'),-- LATEAPPLICATION
                                  DECODE(TRIM(SUBSTR(p_record_data,52,1)),'M','Y','N'),-- MODULAR
                                  TRIM(SUBSTR(p_record_data,36,1)),                    -- CONFIRMED
                                  TRIM(SUBSTR(p_record_data,37,1)),                    -- GCSE_ENG
                                  TRIM(SUBSTR(p_record_data,38,1)),                    -- GCSE_MATH
                                  TRIM(SUBSTR(p_record_data,40,2)),                    -- DEGREE_SUBJECT
                                  TRIM(SUBSTR(p_record_data,39,1)),                    -- DEGREE_STATUS
                                  TRIM(SUBSTR(p_record_data,42,2)),                    -- DEGREE_CLASS
                                  TRIM(SUBSTR(p_record_data,50,1)),                    -- GCSE_SCI
                                  'N',                                                 -- RECORD_STATUS,
                                  NULL                                                 -- ERROR_CODE
                                 );

        -- Increase the success record count.
        g_success_cnt := g_success_cnt +1;

  EXCEPTION
    WHEN VALUE_ERROR THEN
        fnd_message.set_name('IGS', 'IGS_UC_NON_NUMERIC_DATA');
        fnd_message.set_token('TTYPE',p_trans_type);
        fnd_file.put_line( fnd_file.log, fnd_message.get());
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_UC_MV_DATA_UPLD.TRANSFER_TO_STARG - '||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END transfer_to_starg;


  PROCEDURE transfer_to_starh(
                              p_trans_type     igs_uc_load_mv_t.trans_type%TYPE,
                              p_record_data    igs_uc_load_mv_t.record_data%TYPE
                             ) AS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose    : Inserts the given *H transaction record into igs_uc_mv_ivstarh table
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||  rgangara        11-Nov-02       Added logic to insert into IVSTARH extension table to hold
    ||                                  additional *H data for small systems support. Bug 2643048
    || smaddali  30-jun-03    Modified for ucfd203- multiple cycles build , bug#2669208
    ||                                  replaced igs_uc_mv_ivstarh with igs_uc_istarh_ints which
    ||                                  includes columns of igs_uc_ss_ivstarh table also
    */


      ln_appno igs_uc_istarh_ints.appno%TYPE := TO_NUMBER(TRIM(SUBSTR(p_record_data,1,8)));


  BEGIN

      fnd_message.set_name('IGS', 'IGS_UC_TRAN_PROC_APP');
      fnd_message.set_token('TTYPE','*H ');
      fnd_message.set_token('APPNO', ln_appno);
      fnd_file.put_line( fnd_file.log, fnd_message.get());

      -- Obsolete matching records in interface table with status N
      UPDATE igs_uc_istarh_ints SET record_status = 'O'
      WHERE record_status       = 'N' AND appno = ln_appno  ;

      INSERT INTO igs_uc_istarh_ints(
                                  appno,
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
                                 VALUES
                                 (
                                  ln_appno,                                             -- APPNO,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,17,2))),          -- ETHNIC,
                                  TRIM(SUBSTR(p_record_data,19,1)),                     -- SOCIALCLASS,
                                  TO_DATE(TRIM(SUBSTR(p_record_data,11,6)), 'DDMMRR'),  -- POCCEDUCHANGEDATE,
                                  TRIM(SUBSTR(p_record_data,39,4)),                     -- POCC,                      -- 21-Nov-02 changed from 39,3 to 39,4 as it was wrong earlier.
                                  NULL,                                                 -- POCCTEXT,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,23,7))),          -- LASTEDUCATION,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,30,2))),          -- EDUCATIONLEAVEDATE,
                                  NULL,                                                 -- LEA,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,35,1))),          -- SOCIALECONOMIC,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,36,2))),          -- DEPENDANTS,
                                  TRIM(SUBSTR(p_record_data,38,1)),                     -- MARRIED,
                                  'N',                                                  -- RECORD_STATUS,
                                  NULL                                                  -- ERROR_CODE
                                  );

        -- Increase the success record count.
        g_success_cnt := g_success_cnt +1;

  EXCEPTION
    WHEN VALUE_ERROR THEN
         fnd_message.set_name('IGS', 'IGS_UC_NON_NUMERIC_DATA');
         fnd_message.set_token('TTYPE',p_trans_type);
         fnd_file.put_line( fnd_file.log, fnd_message.get());
         igs_ge_msg_stack.add;
         app_exception.raise_exception;

    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_UC_MV_DATA_UPLD.TRANSFER_TO_STARH - '||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END transfer_to_starh;


  PROCEDURE transfer_to_stark(
                              p_trans_type     igs_uc_load_mv_t.trans_type%TYPE,
                              p_record_data    igs_uc_load_mv_t.record_data%TYPE
                             ) AS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose    : Inserts the given *K transactionrecord into igs_uc_mv_ivstark table
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||
    ||  rbezawad        24-Sep-2002    Added code to populate igs_uc_mv_ivstark.CHOICESALLTRANSPARENT column value from 120 column position and
    ||                                   EXTRASTATUS, EXTRAPASSPORTNO columns with NULL values.  Modified w.r.t. UCFD06 Build 2574566.
    ||  rgangara        11-Nov-02       Added logic to insert into IVSTARK extension table to hold
    ||                                  additional *K data for small systems support. Bug 2643048
    ||  rbezawad        02-Dec-2002    Removed the TO_NUMBER() conversion while importing data into IGS_UC_MV_IVSTARK.SPECIALNEEDS column.
    ||                                  This is done w.r.t. Bug 2620166 as there is change in Hercules data model.
    || smaddali  30-jun-03    Modified for ucfd203- multiple cycles build , bug#2669208
    ||                                  replaced igs_uc_mv_ivstark with igs_uc_istark_ints which
    ||                                  includes columns of igs_uc_ss_ivstark table also
    || smaddali  7-aug-03   Modified procedure logic for updating *N INTS record for bug 3085770
    */


      l_scn             igs_uc_istark_ints.scn%TYPE   := NULL;
      l_regno           igs_uc_istark_ints.regno%TYPE := NULL;
      ln_appno          igs_uc_istark_ints.appno%TYPE := TO_NUMBER(TRIM(SUBSTR(p_record_data,1,8)));

      -- Get matching record from starN int table for the passed hercules record
      CURSOR c_starn_int( cp_appno  igs_uc_istarn_ints.appno%TYPE  ) IS
      SELECT a.rowid ,a.namechangedate , a.title , a.forenames, a.surname
      FROM igs_uc_istarn_ints  a
      WHERE record_status  = 'N'
        AND  appno         = cp_appno ;

      c_starn_int_rec           c_starn_int%ROWTYPE ;

      -- get the name details for this applicant
      CURSOR c_app_name (cp_appno  igs_uc_app_names.app_no%TYPE ) IS
      SELECT  name_change_date , title , fore_names , surname
      FROM igs_uc_app_names
      WHERE app_no      = cp_appno ;
      c_app_name_rec            c_app_name%ROWTYPE ;

      -- Get the name details  from the Starn transaction for this applicant
      CURSOR get_n_data( cp_appno  NUMBER  ) IS
      SELECT record_data
      FROM igs_uc_load_mv_t
      WHERE trans_type                                  = '*N'
        AND TO_NUMBER(TRIM(SUBSTR(record_data,1,8)))    = cp_appno;

      l_n_data                  igs_uc_load_mv_t.record_data%TYPE ;

      l_namechangedate          igs_uc_app_names.name_change_date%TYPE ;
      l_title                   igs_uc_app_names.title%TYPE   ;
      l_forenames               igs_uc_app_names.fore_names%TYPE  ;
      l_surname                 igs_uc_app_names.surname%TYPE  ;

  BEGIN

      fnd_message.set_name('IGS', 'IGS_UC_TRAN_PROC_APP');
      fnd_message.set_token('TTYPE','*K ');
      fnd_message.set_token('APPNO', ln_appno);
      fnd_file.put_line( fnd_file.log, fnd_message.get());

      -- If the value stored in the 69th position is Numeric then the data goes into
      -- Regno column else data goes into scn column
      IF is_numeric(TRIM(SUBSTR(p_record_data,69,1))) THEN
                l_regno := TRIM(SUBSTR(p_record_data,69,10));
      ELSE
                l_scn   := TRIM(SUBSTR(p_record_data,69,9));
      END IF;

      -- Obsolete matching records in starK interface table with status N
      UPDATE igs_uc_istark_ints SET record_status = 'O'
      WHERE record_status       = 'N' AND appno = ln_appno  ;

      INSERT INTO igs_uc_istark_ints(
                                  appno,
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
                                  welshspeaker ,
                                  ninumber     ,
                                  earlieststart,
                                  nearinst     ,
                                  prefreg      ,
                                  qualeng      ,
                                  qualmath     ,
                                  qualsci      ,
                                  mainqual     ,
                                  qual5 ,
                                  record_status,
                                  error_code
                                 )
                                 VALUES
                                 (
                                  ln_appno,                                              -- APPNO,
                                  TO_DATE(TRIM(SUBSTR(p_record_data,24,6)), 'DDMMRR'),   -- APPLICATIONDATE,
                                  NULL,                                                  -- SENTDATE,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,30,3))),           -- RUNSENT,
                                  TO_DATE(TRIM(SUBSTR(p_record_data,11,6)), 'DDMMRR'),   -- CODEDCHANGEDATE,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,39,5))),           -- SCHOOL,
                                  TRIM(SUBSTR(p_record_data,45,1)),                      -- RESCAT,
                                  NULL,                                                  -- FEELEVEL,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,56,2))),           -- FEEPAYER,
                                  NULL,                                                  -- FEETEXT,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,47,3))),           -- APR,
                                  NULL,                                                  -- LEA
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,50,3))),           -- COUNTRYBIRTH,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,53,3))),           -- NATIONALITY,
                                  NULL,                                                  -- DUALNATIONALITY,
                                  TRIM(SUBSTR(p_record_data,17,1)),                      -- WITHDRAWN,
                                  TO_DATE(TRIM(SUBSTR(p_record_data,18,6)), 'DDMMRR'),   -- WITHDRAWNDATE,
                                  DECODE(TRIM(SUBSTR(p_record_data,80,1)),'B','Y','N'),  -- ROUTEB,
                                  TO_DATE(TRIM(SUBSTR(p_record_data,11,6)), 'DDMMRR'),   -- EXAMCHANGEDATE,
                                  NULL,                                                  -- ALEVELS,
                                  NULL,                                                  -- ASLEVELS,
                                  NULL,                                                  -- HIGHERS,
                                  NULL,                                                  -- CSYS,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,58,1))),           -- GCE,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,59,1))),           -- VCE,
                                  TRIM(SUBSTR(p_record_data,61,1)),                      -- SQA,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,65,1))),           -- WINTER,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,66,1))),           -- PREVIOUSA,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,119,1))),          -- PREVIOUSAS,
                                  NULL,                                                  -- KEYSKILLS,
                                  NULL,                                                  -- VOCATIONAL,
                                  NULL,                                                  -- GNVQ
                                  DECODE(TRIM(SUBSTR(p_record_data,62,1)),'B','Y','N'),  -- BTEC,
                                  DECODE(TRIM(SUBSTR(p_record_data,64,1)),'I','Y','N'),  -- ILC,
                                  NULL,                                                  -- AICE,
                                  DECODE(TRIM(SUBSTR(p_record_data,63,1)),'I','Y',NULL), -- IB,
                                  NULL,                                                  -- MANUAL,
                                  l_regno,                                               -- REGNO,
                                  l_scn,                                                 -- SCN,
                                  TRIM(SUBSTR(p_record_data,79,1)),                      -- OEQ,
                                  NULL,                                                  -- PREVOEQ,
                                  NVL(TRIM(SUBSTR(p_record_data,105,1)),'P'),            -- EAS,
                                  TRIM(SUBSTR(p_record_data,68,1)),                      -- ROA,
                                  TRIM(SUBSTR(p_record_data,46,1)),                      -- SPECIALNEEDS,
                                  NULL,                                                  -- CRIMINALCONV,
                                  NULL,                                                  -- UKENTRYDATE,
                                  NULL,                                                  -- STATUS,
                                  NULL,                                                  -- FIRMNOW,
                                  NULL,                                                  -- FIRMREPLY,
                                  NULL,                                                  -- INSURANCEREPLY,
                                  NULL,                                                  -- CONFHISTFIRMREPLY,
                                  NULL,                                                  -- CONFHISTINSURANCEREPLY,
                                  DECODE(TRIM(SUBSTR(p_record_data,120,1)),'Y','Y','N'), -- CHOICESALLTRANSPARENT,
                                  NULL,                                                  -- EXTRASTATUS,
                                  NULL,                                                  -- EXTRAPASSPORTNO,
                                  TRIM(SUBSTR(p_record_data,81,1)),                      -- WELSHSPEAKER
                                  TRIM(SUBSTR(p_record_data,82,9)),                      -- NINUMBER
                                  TRIM(SUBSTR(p_record_data,91,4)),                      -- EARLIESTSTART
                                  TRIM(SUBSTR(p_record_data,95,4)),                      -- NEARINST
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,99,1))),           -- PREFREG
                                  TRIM(SUBSTR(p_record_data,100,1)),                     -- QUALENG
                                  TRIM(SUBSTR(p_record_data,101,1)),                     -- QUALMATH
                                  TRIM(SUBSTR(p_record_data,102,1)),                     -- QUALSCI
                                  TRIM(SUBSTR(p_record_data,103,1)),                     -- MAINQUAL
                                  TRIM(SUBSTR(p_record_data,104,1)),                     -- QUAL5
                                  'N',                                                   -- RECORD_STATUS,
                                  NULL                                                   -- ERROR_CODE
                                 );

          IF TO_DATE(TRIM(SUBSTR(p_record_data,33,6)), 'DDMMRR') IS NOT NULL OR
             TRIM(SUBSTR(p_record_data,44,1)) IS NOT NULL THEN


                  l_n_data              := NULL ;
                  l_namechangedate      := NULL;
                  l_title               := NULL ;
                  l_forenames           := NULL ;
                  l_surname             := NULL ;
                  -- Check if *N tran exists in this flat file
                  l_n_data      := NULL ;
                  OPEN get_n_data(ln_appno);
                  FETCH get_n_data INTO l_n_data ;
                  IF get_n_data%NOTFOUND THEN
                        -- if starN tran doesn't exist in this file then , check if *N INTS record
                        -- was created by earlier flat file , if so retain Name fields in  *N INTS table
                        c_starn_int_rec := NULL ;
                        OPEN c_starn_int( ln_appno ) ;
                        FETCH c_starn_int INTO c_starn_int_rec;
                        CLOSE c_starn_int;

                        -- Else if *N INTS record is not present or if name fields are NULL then Get values
                        -- from igs_uc_app_names
                        c_app_name_rec := NULL;
                        OPEN c_app_name( ln_appno ) ;
                        FETCH c_app_name INTO c_app_name_rec ;
                        CLOSE c_app_name ;

                        -- If existing *N INTS record has NULL values for dob  and sex then , overwrite with appnamesvalues
                        l_namechangedate        := NVL(c_starn_int_rec.namechangedate,c_app_name_rec.name_change_date) ;
                        l_title                 := NVL(c_starn_int_rec.title, c_app_name_rec.title) ;
                        l_forenames             := NVL(c_starn_int_rec.forenames, c_app_name_rec.fore_names)  ;
                        l_surname               := NVL(c_starn_int_rec.surname, c_app_name_rec.surname) ;

                  ELSE
                        -- if *N transaction exists for this appno then get name details from there
                        l_namechangedate    :=  TO_DATE(TRIM(SUBSTR(l_n_data,11,6)), 'DDMMRR')  ;
                        l_title             :=  UPPER(TRIM(SUBSTR(l_n_data,17,4)))  ;
                        l_forenames         :=  TRIM(SUBSTR(l_n_data,42,24));
                        l_surname           :=  TRIM(SUBSTR(l_n_data,24,18)) ;

                  END IF ;
                  CLOSE get_n_data;


                  -- check if a *N record already exists for this record , if so update it
                  -- else create a new record with values derived as above
                  c_starn_int_rec       := NULL ;
                  OPEN c_starn_int( ln_appno ) ;
                  FETCH c_starn_int INTO c_starn_int_rec ;
                  IF c_starn_int%FOUND THEN
                      UPDATE igs_uc_istarn_ints SET
                      namechangedate    = NVL(l_namechangedate,namechangedate),
                      title             = NVL(l_title,title),
                      forenames         = NVL(l_forenames,forenames),
                      surname           = NVL(l_surname,surname) ,
                      birthdate         = TO_DATE(TRIM(SUBSTR(p_record_data,33,6)), 'DDMMRR') ,
                      sex               = TRIM(SUBSTR(p_record_data,44,1)),
                      ad_batch_id       = NULL ,
                      ad_interface_id   = NULL ,
                      ad_api_id         = NULL ,
                      error_code        = NULL
                      WHERE rowid = c_starn_int_rec.rowid ;
                  ELSE
                          INSERT INTO igs_uc_istarn_ints (
                                                  appno,
                                                  checkdigit,
                                                  namechangedate,
                                                  title,
                                                  forenames,
                                                  surname,
                                                  birthdate,
                                                  sex,
                                                  ad_batch_id  ,
                                                  ad_interface_id ,
                                                  ad_api_id ,
                                                  record_status,
                                                  error_code
                                                )
                                                 VALUES
                                                 (
                                                  ln_appno,                                             -- APPNO,
                                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,9,1))),           -- CHECKDIGIT,
                                                  l_namechangedate,                                     -- NAMECHANGEDATE,
                                                  l_title,                                              -- TITLE,
                                                  l_forenames,                                          -- FORENAMES,
                                                  l_surname,                                            -- SURNAME,
                                                  TO_DATE(TRIM(SUBSTR(p_record_data,33,6)), 'DDMMRR'),  -- BIRTHDATE,
                                                  TRIM(SUBSTR(p_record_data,44,1)),                     -- SEX,
                                                  NULL,                                                 -- AD_BATCH_ID
                                                  NULL,                                                 -- AD_INTERFACE_ID
                                                  NULL,                                                 -- AD_API_ID
                                                  'N',                                                  -- RECORD_STATUS,
                                                  NULL                                                  -- ERROR_CODE
                                                 );

                  END IF ;
                  CLOSE c_starn_int ;

          END IF ;  -- process birthdate and sex fields

          -- Increase the success record count.
          g_success_cnt := g_success_cnt +1;

  EXCEPTION
    WHEN VALUE_ERROR THEN
        fnd_message.set_name('IGS', 'IGS_UC_NON_NUMERIC_DATA');
        fnd_message.set_token('TTYPE',p_trans_type);
        fnd_file.put_line( fnd_file.log, fnd_message.get());
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_UC_MV_DATA_UPLD.TRANSFER_TO_STARK - '||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END transfer_to_stark;


  PROCEDURE transfer_to_starn(
                              p_trans_type     igs_uc_load_mv_t.trans_type%TYPE,
                              p_record_data    igs_uc_load_mv_t.record_data%TYPE
                             ) AS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose    : Inserts the given *N transaction record into igs_uc_mv_ivstarn table
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||  rgangara  28 Nov 02  For Y2K problem found during testing.
    || smaddali  30-jun-03    Modified for ucfd203- multiple cycles build , bug#2669208
    ||                                  replaced igs_uc_mv_ivstarn with igs_uc_istarn_ints
    || smaddali  7-aug-03   Modified procedure logic for updating *N INTS record for bug 3085770
    */

/*  rgangara  28-Nov-02
   Modified by rgangara to overcome Y2K issue for birthdate. The date of birth data that comes in from UCAS
   is in DDMMYY format. As such when this is converted and populated into the table, it is saved as DDMMYYYY.
   This was causing a problem. For ex a date of birth of say 01-Jan-72 would be 010172 in the flat file coming from
   UCAS since it is in DDMMYY format.  However, when this is stored in a table and queried, it would 01-Jan-2072
   which would through up errors.  Hence since it is assumed that the Applicants in UCAS would have birthdates in
   19's and not beyond 2000, the code here has been modified to do a proper conversion by changing format mask as 'DDMMRR' instead of 'DDMMYY'.
*/

      ln_appno          igs_uc_istarn_ints.appno%TYPE := TO_NUMBER(TRIM(SUBSTR(p_record_data,1,8)));

      -- Get the details of birthdate and sex from the Stark transaction
      CURSOR get_k_data( cp_appno  NUMBER  ) IS
      SELECT record_data
      FROM igs_uc_load_mv_t
      WHERE trans_type = '*K'
        AND TO_NUMBER(TRIM(SUBSTR(record_data,1,8))) = cp_appno;

      l_k_data          igs_uc_load_mv_t.record_data%TYPE ;

      -- Get matching record from starN int table for the passed hercules record
      CURSOR c_starn_int( cp_appno  igs_uc_istarn_ints.appno%TYPE  ) IS
      SELECT a.rowid , a.sex, a.birthdate
      FROM igs_uc_istarn_ints    a
      WHERE record_status  = 'N'
        AND  appno         = cp_appno ;

      c_starn_int_rec   c_starn_int%ROWTYPE ;

      l_birthdate       igs_uc_istarn_ints.birthdate%TYPE ;
      l_sex             igs_uc_istarn_ints.sex%TYPE  ;

      -- get the name details for this applicant
      CURSOR c_app_name (cp_appno  igs_uc_app_names.app_no%TYPE ) IS
      SELECT  birth_date , sex
      FROM igs_uc_app_names
      WHERE app_no      = cp_appno ;
      c_app_name_rec  c_app_name%ROWTYPE ;

  BEGIN

         fnd_message.set_name('IGS', 'IGS_UC_TRAN_PROC_APP');
         fnd_message.set_token('TTYPE','*N');
         fnd_message.set_token('APPNO', ln_appno);
         fnd_file.put_line( fnd_file.log, fnd_message.get());

          -- initialising variables
          l_k_data      := NULL ;
          l_birthdate   := NULL;
          l_sex         :=  NULL ;
          -- Check if *K transation exists in this flat file
          l_k_data      := NULL ;
          OPEN get_k_data(ln_appno);
          FETCH get_k_data INTO l_k_data ;
          IF get_k_data%NOTFOUND THEN

                -- if stark tran doesn't exist in this tran then , check if *N INTS record
                -- was created by earlier flat file , if so retain dob and sex in  *N INTS table
                c_starn_int_rec := NULL;
                OPEN c_starn_int( ln_appno ) ;
                FETCH c_starn_int INTO c_starn_int_rec;
                CLOSE c_starn_int;

                -- Else if *N INTS record is not present or if dob and sex are NULL then Get values from igs_uc_app_names
                c_app_name_rec  := NULL ;
                OPEN c_app_name( ln_appno ) ;
                FETCH c_app_name INTO c_app_name_rec ;
                CLOSE c_app_name ;

                -- If existing *N INTS record has NULL values for dob  and sex then , overwrite with appnamesvalues
                l_birthdate     := NVL(c_starn_int_rec.birthdate, c_app_name_rec.birth_date);
                l_sex           := NVL(c_starn_int_rec.sex, c_app_name_rec.sex) ;

          ELSE
                -- if *K transaction exists for this appno then get dob and sex details from there
                l_birthdate     := TO_DATE(TRIM(SUBSTR(l_k_data,33,6)), 'DDMMRR') ;
                l_sex           := TRIM(SUBSTR(l_k_data,44,1)) ;
          END IF ;
          CLOSE get_k_data;

          -- check if a *N record already exists for this appno with record_status 'N', if so update it
          -- else create a new record with values derived as above and the current transaction
          c_starn_int_rec       := NULL;
          OPEN c_starn_int( ln_appno ) ;
          FETCH c_starn_int INTO c_starn_int_rec;
          IF c_starn_int%FOUND THEN
                    UPDATE igs_uc_istarn_ints SET
                    checkdigit          = TO_NUMBER(TRIM(SUBSTR(p_record_data,9,1))) ,
                    namechangedate      = TO_DATE(TRIM(SUBSTR(p_record_data,11,6)), 'DDMMRR') ,
                    title               = UPPER(TRIM(SUBSTR(p_record_data,17,4))) ,
                    forenames           = TRIM(SUBSTR(p_record_data,42,24)) ,
                    surname             = TRIM(SUBSTR(p_record_data,24,18)) ,
                    birthdate           = NVL(l_birthdate,birthdate),
                    sex                 = NVL(l_sex,sex) ,
                    ad_batch_id         = NULL ,
                    ad_interface_id     = NULL ,
                    ad_api_id           = NULL ,
                    error_code          = NULL
                    WHERE rowid = c_starn_int_rec.rowid ;
          ELSE
                    INSERT INTO igs_uc_istarn_ints (
                                  appno,
                                  checkdigit,
                                  namechangedate,
                                  title,
                                  forenames,
                                  surname,
                                  birthdate,
                                  sex,
                                  ad_batch_id  ,
                                  ad_interface_id ,
                                  ad_api_id ,
                                  record_status,
                                  error_code
                                )
                                 VALUES
                                 (
                                  ln_appno,                                             -- APPNO,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,9,1))),           -- CHECKDIGIT,
                                  TO_DATE(TRIM(SUBSTR(p_record_data,11,6)), 'DDMMRR'),  -- NAMECHANGEDATE,
                                  UPPER(TRIM(SUBSTR(p_record_data,17,4))),              -- TITLE,
                                  TRIM(SUBSTR(p_record_data,42,24)),                    -- FORENAMES,
                                  TRIM(SUBSTR(p_record_data,24,18)),                    -- SURNAME,
                                  l_birthdate,                                          -- BIRTHDATE,
                                  l_sex,                                                -- SEX,
                                  NULL,                                                 -- AD_BATCH_ID
                                  NULL,                                                 -- AD_INTERFACE_ID
                                  NULL,                                                 -- AD_API_ID
                                  'N',                                                  -- RECORD_STATUS,
                                  NULL                                                  -- ERROR_CODE
                                 );

          END IF ;
          CLOSE c_starn_int ;


        -- Increase the success record count.
        g_success_cnt := g_success_cnt +1;

  EXCEPTION
    WHEN VALUE_ERROR THEN
        fnd_message.set_name('IGS', 'IGS_UC_NON_NUMERIC_DATA');
        fnd_message.set_token('TTYPE',p_trans_type);
        fnd_file.put_line( fnd_file.log, fnd_message.get());
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_UC_MV_DATA_UPLD.TRANSFER_TO_STARN - '||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END transfer_to_starn;


  PROCEDURE transfer_to_starpqr(
                              p_trans_type     igs_uc_load_mv_t.trans_type%TYPE,
                              p_record_data    igs_uc_load_mv_t.record_data%TYPE
                               ) AS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose    : Inserts the given *P *R transactions record into igs_uc_mv_ivstarpqr and igs_uc_mv_ivqual tables
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who       When         What
    ||  (reverse chronological order - newest change first)
    ||  rbezawad  25-Sep-2002  Removed code which is populating IGS_UC_MV_IVQUAL.GNVQDATE as the column is obsoleted.
    ||  smaddali  29-jan-03    Enhanced processing for *P and *R transactions to populate subject_id and ebl_result as part of build UCCR005 , bug #2749404
    ||  rbezawad  25-Feb-03    Modified procedure transfer_to_starpqr for processing Previous results of an applicant upto maximum 21 sets w.r.t. Bug 2810932.
    || smaddali  30-jun-03    Modified for ucfd203- multiple cycles build , bug#2669208
    ||                                  replaced igs_uc_mv_ivstarpqr with igs_uc_istrpqr_ints
    || smaddali  26-aug-03    Modified procedure for *P transaction , to populate grade1 and 2 fields instead of Grade field, for bug#3114629
    || smaddali  4-sep-03     Obsoleting existing 'N' records for bug#3122898
    */

      ln_appno          igs_uc_istrpqr_ints.appno%TYPE := TO_NUMBER(TRIM(SUBSTR(p_record_data,1,8)));

    -- smaddali added the declarations for bug# 2749404
      l_sitting         igs_uc_istrpqr_ints.sitting%TYPE;
      l_grade1          igs_uc_istrpqr_ints.grade1%TYPE;
      l_grade2          igs_uc_istrpqr_ints.grade2%TYPE;
      l_ebl_code        igs_uc_istrpqr_ints.eblsubject%TYPE ;
      l_matchind        igs_uc_istrpqr_ints.matchind%TYPE := TRIM(SUBSTR(p_record_data,17,1)) ;
      l_exam_board_code igs_uc_istrpqr_ints.examboard%TYPE;
      l_year_date       igs_uc_istrpqr_ints.yearofexam%TYPE  ;
      l_lending_board   igs_uc_istrpqr_ints.lendingboard%TYPE  ;
      l_pr_start_pos    NUMBER;
    -- end of change by smaddali for  bug#2749404


  BEGIN

    fnd_message.set_name('IGS', 'IGS_UC_TRAN_PROC_APP');
    fnd_message.set_token('TTYPE','*PQR');
    fnd_message.set_token('APPNO', ln_appno);
    fnd_file.put_line( fnd_file.log, fnd_message.get());

      -- update all records in interface table for the current applicant ,marvin type with status L
      -- to status D,i.e processed for this applicant
      UPDATE igs_uc_istrpqr_ints SET record_status = 'D'
      WHERE record_status       = 'L' AND appno = ln_appno
      AND marvin_type           = SUBSTR(p_trans_type,2,1)  ;

      -- update all records in interface table for the current applicant, marvin type with status N
      -- to status O,i.e obsolete for this applicant
      UPDATE igs_uc_istrpqr_ints SET record_status = 'O' , error_code = NULL
      WHERE record_status       = 'N' AND appno = ln_appno
      AND marvin_type           = SUBSTR(p_trans_type,2,1)  ;

      -- reinstate records with status L of the other marvin type for this applicant
      IF p_trans_type = '*R'  THEN
               -- set matching records in interface table with status L to N
                UPDATE igs_uc_istrpqr_ints SET record_status = 'N'
                WHERE record_status     = 'L' AND appno = ln_appno
                AND marvin_type = 'P'  ;
      ELSIF p_trans_type = '*P' THEN
              -- set matching records in interface table with status L to N
                UPDATE igs_uc_istrpqr_ints SET record_status = 'N'
                WHERE record_status     = 'L' AND appno = ln_appno
                AND marvin_type = 'R';
      END IF ;

      --Assign the Previous Result details starting location.
      l_pr_start_pos := 18;

      --To loop through the maximum 21 sets of previous results i.e., from 18 to 227 positions
      --  and insert previous results data into igs_uc_istrpqr_ints table.
      WHILE TRIM(SUBSTR(p_record_data,l_pr_start_pos,2)) IS NOT NULL AND l_pr_start_pos <= 218 LOOP
              -- extract field values
              l_year_date       := LPAD(TRIM(SUBSTR(p_record_data,l_pr_start_pos,2)),2,'0') ;
              l_sitting         := TRIM(SUBSTR(p_record_data,(l_pr_start_pos+2),1)) ;  --Extracts String from Position 20
              l_exam_board_code := TRIM(SUBSTR(p_record_data,(l_pr_start_pos+3),1)) ;  --Extracts String from Position 21
              l_ebl_code        := TRIM(SUBSTR(p_record_data,(l_pr_start_pos+4),3)) ;  --Extracts String from Positions 22,23,24
              -- smaddali moved the population of these fields grade1,2 to be common for both *P and *R transactions, bug#3114629
              l_grade1           := TRIM(SUBSTR(p_record_data,(l_pr_start_pos+7),1)) ;  --Extracts String from Position 25
              l_grade2           := TRIM(SUBSTR(p_record_data,(l_pr_start_pos+8),1)) ;  --Extracts String from Position 26

                IF p_trans_type = '*P' THEN
                     l_matchind         := NULL ;
                     l_lending_board    := NULL ;
                ELSIF p_trans_type = '*R' THEN
                     l_lending_board    := TRIM(SUBSTR(p_record_data,(l_pr_start_pos+9),1)) ;
                END IF ; -- end of *p/*r transaction

                -- Obsolete matching records in interface table with status N
                UPDATE igs_uc_istrpqr_ints SET record_status = 'O'
                WHERE record_status     = 'N' AND appno = ln_appno
                AND yearofexam = l_year_date    AND  sitting = l_sitting
                AND  examboard = l_exam_board_code AND eblsubject = l_ebl_code  ;

                INSERT INTO igs_uc_istrpqr_ints(
                                          appno,
                                          subjectid,
                                          eblresult,
                                          eblamended,
                                          claimedresult,
                                          yearofexam,
                                          sitting,
                                          examboard ,
                                          eblsubject,
                                          grade,
                                          grade1,
                                          grade2,
                                          lendingboard,
                                          matchind ,
                                          marvin_type ,
                                          record_status,
                                          error_code
                                         )
                                         VALUES
                                         (
                                          ln_appno,                                     -- APPNO,
                                          NULL,                                         -- SUBJECTID,
                                          NULL,                                         -- EBLRESULT,
                                          NULL,                                         -- EBLAMENDED,
                                          NULL,                                         -- CLAIMEDRESULT,
                                          l_year_date,                                  -- YEAROFEXAM
                                          l_sitting,                                    -- SITTING
                                          l_exam_board_code,                            -- EXAMBOARD
                                          l_ebl_code,                                   -- EBLSUBJECT
                                          NULL,                                         -- GRADE
                                          l_grade1,                                     -- GRADE1
                                          l_grade2,                                     -- GRADE2
                                          l_lending_board,                              -- LENDINGBOARD
                                          l_matchind,                                   -- MATCHIND
                                          SUBSTR(p_trans_type,2,1),                     -- MARVIN_TYPE
                                          'N',                                          -- RECORD_STATUS,
                                          NULL                                          -- ERROR_CODE
                                         );

                -- Increase the success record count.
                g_success_cnt := g_success_cnt +1;

                l_pr_start_pos  := l_pr_start_pos + 10;

      END LOOP; --Previous Results Loop


  EXCEPTION
    WHEN VALUE_ERROR THEN
        fnd_message.set_name('IGS', 'IGS_UC_NON_NUMERIC_DATA');
        fnd_message.set_token('TTYPE',p_trans_type);
        fnd_file.put_line( fnd_file.log, fnd_message.get());
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_UC_MV_DATA_UPLD.TRANSFER_TO_STARPQR - '||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END transfer_to_starpqr;



  PROCEDURE transfer_to_start(
                              p_trans_type     igs_uc_load_mv_t.trans_type%TYPE,
                              p_record_data    igs_uc_load_mv_t.record_data%TYPE
                             ) AS
    /*
    ||  Created By : rgangara
    ||  Created On : 12-Nov-02
    ||  Purpose    : Inserts the given *T (General Social Care Council Data) transaction data into igs_uc_mv_ivstarT table
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    || smaddali  30-jun-03    Modified for ucfd203- multiple cycles build , bug#2669208
    ||                                  replaced igs_uc_mv_ivstart with igs_uc_istart_ints
    ||  (reverse chronological order - newest change first)
    ||
    */

      ln_appno igs_uc_istart_ints.appno%TYPE := TO_NUMBER(TRIM(SUBSTR(p_record_data,1,8)));

  BEGIN

      fnd_message.set_name('IGS', 'IGS_UC_TRAN_PROC_APP');
      fnd_message.set_token('TTYPE','*T');
      fnd_message.set_token('APPNO', ln_appno);
      fnd_file.put_line( fnd_file.log, fnd_message.get());

      -- Obsolete matching records in interface table with status N
      UPDATE igs_uc_istart_ints SET record_status = 'O'
      WHERE record_status = 'N' AND appno = ln_appno ;

      INSERT INTO igs_uc_istart_ints(
                                    appno       ,
                                    lastchange  ,
                                    futureserv  ,
                                    futureset   ,
                                    presentserv ,
                                    presentset  ,
                                    curremp     ,
                                    eduqual     ,
                                    record_status,
                                    error_code
                                 )
                                 VALUES
                                 (
                                    ln_appno,                                            -- APPNO,
                                    TO_DATE(TRIM(SUBSTR(p_record_data,11,6)),'DDMMRR'),  -- LASTCHANGE
                                    TRIM(SUBSTR(p_record_data,17,1)),                    -- FUTURESERV
                                    TRIM(SUBSTR(p_record_data,18,1)),                    -- FUTUTRESET
                                    TRIM(SUBSTR(p_record_data,19,1)),                    -- PRESENTSERV
                                    TRIM(SUBSTR(p_record_data,20,1)),                    -- PRSENTSET
                                    TRIM(SUBSTR(p_record_data,21,1)),                    -- CURREMP
                                    TRIM(SUBSTR(p_record_data,22,2)),                    -- EDUQUAL
                                    'N',                                                 -- RECORD_STATUS,
                                    NULL                                                 -- ERROR_CODE
                                 );

      -- Increase the success record count.
      g_success_cnt := g_success_cnt +1;

  EXCEPTION
    WHEN VALUE_ERROR THEN
        fnd_message.set_name('IGS', 'IGS_UC_NON_NUMERIC_DATA');
        fnd_message.set_token('TTYPE',p_trans_type);
        fnd_file.put_line( fnd_file.log, fnd_message.get());
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_UC_MV_DATA_UPLD.TRANSFER_TO_START - '||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END transfer_to_start;




  PROCEDURE transfer_to_starw(
                              p_trans_type     igs_uc_load_mv_t.trans_type%TYPE,
                              p_record_data    igs_uc_load_mv_t.record_data%TYPE
                             ) AS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose    : Inserts the given *W transaction record into igs_uc_mv_ivstarw table
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||
    ||  rbezawad        24-Sep-2002    Added code to populate igs_uc_mv_ivstarw.JOINTADMISSION column value based on value in 17 column position.
    ||                                   Modified w.r.t. UCFD06 Build 2574566.
    || smaddali  30-jun-03    Modified for ucfd203- multiple cycles build , bug#2669208
    ||                                  replaced igs_uc_mv_ivstarw with igs_uc_istarw_ints
    */

      ln_appno igs_uc_istarw_ints.appno%TYPE := TO_NUMBER(TRIM(SUBSTR(p_record_data,1,8)));

  BEGIN

      fnd_message.set_name('IGS', 'IGS_UC_TRAN_PROC_APP');
      fnd_message.set_token('TTYPE','*W');
      fnd_message.set_token('APPNO', ln_appno);
      fnd_file.put_line( fnd_file.log, fnd_message.get());

      -- Obsolete matching records in interface table with status N
      UPDATE igs_uc_istarw_ints SET record_status = 'O'
      WHERE record_status = 'N' AND appno = ln_appno  ;

      INSERT INTO igs_uc_istarw_ints(
                                  appno,
                                  miscoded,
                                  cancelled,
                                  canceldate,
                                  remark,
                                  jointadmission,
                                  choice1lost,
                                  choice2lost,
                                  choice3lost,
                                  choice4lost,
                                  choice5lost,
                                  choice6lost,
                                  choice7lost,
                                  record_status,
                                  error_code
                                 )
                                 VALUES
                                 (
                                  ln_appno,                                              -- APPNO,
                                  DECODE(TRIM(SUBSTR(p_record_data,17,1)),'M','Y','N'),  -- MISCODED,
                                  DECODE(TRIM(SUBSTR(p_record_data,17,1)),'C','Y','N'),  -- CANCELLED,
                                  TO_DATE(TRIM(SUBSTR(p_record_data,11,6)), 'DDMMRR'),   -- CANCELDATE,
                                  NULL,                                                  -- REMARK,
                                  DECODE(TRIM(SUBSTR(p_record_data,17,1)),'J','Y','N'),  -- JOINTADMISSION
                                  'N',                                                   -- CHOICE1LOST
                                  'N',                                                   -- CHOICE2LOST
                                  'N',                                                   -- CHOICE3LOST
                                  'N',                                                   -- CHOICE4LOST
                                  'N',                                                   -- CHOICE5LOST
                                  'N',                                                   -- CHOICE6LOST
                                  'N',                                                   -- CHOICE7LOST
                                  'N',                                                   -- RECORD_STATUS,
                                  NULL                                                   -- ERROR_CODE
                                 );

        -- Increase the success record count.
        g_success_cnt := g_success_cnt +1;

  EXCEPTION
    WHEN VALUE_ERROR THEN
        fnd_message.set_name('IGS', 'IGS_UC_NON_NUMERIC_DATA');
        fnd_message.set_token('TTYPE',p_trans_type);
        fnd_file.put_line( fnd_file.log, fnd_message.get());
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_UC_MV_DATA_UPLD.TRANSFER_TO_STARW - '||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END transfer_to_starw;


  PROCEDURE transfer_to_starx(
                              p_trans_type     igs_uc_load_mv_t.trans_type%TYPE,
                              p_record_data    igs_uc_load_mv_t.record_data%TYPE
                             ) AS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose    : Inserts the given *X transaction record into igs_uc_mv_ivstarx table
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    || rbezawad        25-Sep-2002     Modified population of POCC field to get 4 characters.
    ||
    ||  rgangara        11-Nov-02       Added logic to insert into IVSTARX extension table to hold
    ||                                  additional *X data for small systems support. Bug 2643048
    || smaddali  30-jun-03    Modified for ucfd203- multiple cycles build , bug#2669208
    ||                                  replaced igs_uc_mv_ivstarx with igs_uc_istarx_ints which
    ||                                  includes columns of igs_uc_ss_ivstarx table also
    */

      ln_appno igs_uc_istarx_ints.appno%TYPE := TO_NUMBER(TRIM(SUBSTR(p_record_data,1,8)));

  BEGIN

      fnd_message.set_name('IGS', 'IGS_UC_TRAN_PROC_APP');
      fnd_message.set_token('TTYPE','*X');
      fnd_message.set_token('APPNO', ln_appno);
      fnd_file.put_line( fnd_file.log, fnd_message.get());

      -- Obsolete matching records in interface table with status N
      UPDATE igs_uc_istarx_ints SET record_status = 'O'
      WHERE record_status = 'N' AND appno = ln_appno  ;


      INSERT INTO igs_uc_istarx_ints(
                                  appno,
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
                                 VALUES
                                 (
                                  ln_appno,                                             -- APPNO,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,17,2))),          -- ETHNIC,
                                  TO_DATE(TRIM(SUBSTR(p_record_data,11,6)), 'DDMMRR'),  -- POCCEDUCHANGEDATE,
                                  TRIM(SUBSTR(p_record_data,19,1)),                     -- SOCIALCLASS,
                                  TRIM(SUBSTR(p_record_data,28,4)),                     -- POCC,
                                  NULL,                                                 -- POCCTEXT,
                                  TRIM(SUBSTR(p_record_data,27,1)),                     -- SOCIOECONOMIC,
                                  NULL,                                                 -- OCCBACKGROUND,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,23,1))),          -- RELIGION
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,24,2))),          -- DEPENDANTS
                                  TRIM(SUBSTR(p_record_data,26,1)),                     -- MARRIED
                                  'N',                                                  -- RECORD_STATUS,
                                  NULL                                                  -- ERROR_CODE
                                 );

        -- Increase the success record count.
        g_success_cnt := g_success_cnt +1;

  EXCEPTION
    WHEN VALUE_ERROR THEN
        fnd_message.set_name('IGS', 'IGS_UC_NON_NUMERIC_DATA');
        fnd_message.set_token('TTYPE',p_trans_type);
        fnd_file.put_line( fnd_file.log, fnd_message.get());
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_UC_MV_DATA_UPLD.TRANSFER_TO_STARX - '||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END transfer_to_starx;


  PROCEDURE transfer_to_starz(
                              p_trans_type     igs_uc_load_mv_t.trans_type%TYPE,
                              p_record_data    igs_uc_load_mv_t.record_data%TYPE
                             ) AS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose    : Inserts the given *Z transaction record into igs_uc_mv_ivstarz1 and igs_uc_mv_ivstarz2 tables
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    || smaddali  30-jun-03    Modified for ucfd203- multiple cycles build , bug#2669208
    ||                                  replaced igs_uc_mv_ivstarz1 with igs_uc_istarz1_ints and
    ||                                   igs_uc_mv_ivstarz2 with igs_uc_istarz2_ints
    ||  (reverse chronological order - newest change first)
    */

      ln_position       NUMBER;
      l_result          igs_uc_istarz1_ints.result%TYPE := NULL;
      ln_appno          igs_uc_istarz1_ints.appno%TYPE  := TO_NUMBER(TRIM(SUBSTR(p_record_data,1,8)));

  BEGIN

      fnd_message.set_name('IGS', 'IGS_UC_TRAN_PROC_APP');
      fnd_message.set_token('TTYPE','*Z');
      fnd_message.set_token('APPNO', ln_appno);
      fnd_file.put_line( fnd_file.log, fnd_message.get());

      -- Result column contains 'A' if the Institution and course columns has the values
      IF (TRIM(SUBSTR(p_record_data,20,4)) IS NOT NULL) OR
       (TRIM(SUBSTR(p_record_data,24,6)) IS NOT NULL) THEN
                l_result := 'A';
      END IF;

      -- Obsolete matching records in interface table with status N
      UPDATE igs_uc_istarz1_ints SET record_status = 'O'
      WHERE record_status = 'N' AND appno = ln_appno  ;

      -- Each transactio of Z will have 8 detials of Z transactions also.
      -- These detail z transaction shall be stored in igs_uc_mv_ivstarz2 table
      INSERT INTO igs_uc_istarz1_ints(
                                  appno,
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
                                 VALUES
                                 (
                                  ln_appno,                                       -- APPNO,
                                  NULL,                                           -- DATECEFSENT,
                                  NULL,                                           -- CEFNO,
                                  'N',                                            -- CENTRALCLEARING,
                                  TRIM(SUBSTR(p_record_data,20,3)),               -- INST,
                                  TRIM(SUBSTR(p_record_data,24,6)),               -- COURSE,
                                  TRIM(SUBSTR(p_record_data,30,1)),               -- CAMPUS,
                                  TRIM(SUBSTR(p_record_data,31,1)),               -- FACULTY,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,204,2))),   -- ENTRYYEAR,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,206,2))),   -- ENTRYMONTH,
                                  TO_NUMBER(TRIM(SUBSTR(p_record_data,203,1))),   -- ENTRYPOINT,
                                  l_result,                                       -- RESULT,
                                  'N',                                            -- RECORD_STATUS,
                                  NULL                                            -- ERROR_CODE
                                 );

      ln_position := 86;

      FOR i in 1..8 LOOP
           IF TRIM(SUBSTR(p_record_data,ln_position,4)) IS NOT NULL THEN

                -- Obsolete matching records in interface table with status N
                UPDATE igs_uc_istarz2_ints SET record_status = 'O'
                WHERE record_status = 'N' AND appno = ln_appno
                AND  inst       = TRIM(SUBSTR(p_record_data,ln_position,3))
                AND  course     = TRIM(SUBSTR(p_record_data,ln_position+4,6))
                AND  campus     = TRIM(SUBSTR(p_record_data,ln_position+10,1));

                INSERT INTO igs_uc_istarz2_ints(
                                       appno,
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
                                      VALUES
                                      (
                                       ln_appno,    -- APPNO,
                                       NULL,                                          -- ROUNDNO,
                                       TRIM(SUBSTR(p_record_data,ln_position,3)),     -- INST,
                                       TRIM(SUBSTR(p_record_data,ln_position+4,6)),   -- COURSE,
                                       TRIM(SUBSTR(p_record_data,ln_position+10,1)),  -- CAMPUS,
                                       TRIM(SUBSTR(p_record_data,ln_position+11,1)),  -- FACULTY,
                                       'F',                                           -- ROUNDTYPE,
                                       TRIM(SUBSTR(p_record_data,ln_position+12,1)),  -- RESULT,
                                        'N',                                          -- RECORD_STATUS,
                                        NULL                                          -- ERROR_CODE
                                      );
           END IF;
           ln_position := ln_position + 13;

      END LOOP;

      -- Increase the success record count.
      g_success_cnt := g_success_cnt +1;

  EXCEPTION
    WHEN VALUE_ERROR THEN
        fnd_message.set_name('IGS', 'IGS_UC_NON_NUMERIC_DATA');
        fnd_message.set_token('TTYPE',p_trans_type);
        fnd_file.put_line( fnd_file.log, fnd_message.get());
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_UC_MV_DATA_UPLD.TRANSFER_TO_STARZ - '||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END transfer_to_starz;


  PROCEDURE transfer_to_qa(
                           p_trans_type     igs_uc_load_mv_t.trans_type%TYPE,
                           p_record_data    igs_uc_load_mv_t.record_data%TYPE
                          ) AS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose    : Inserts the given QA transaction record into igs_uc_mv_uvofr_abv table
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    || smaddali  30-jun-03    Modified for ucfd203- multiple cycles build , bug#2669208
    ||                                  replaced igs_uc_mv_uvofr_abv with igs_uc_uofabrv_ints
    ||  (reverse chronological order - newest change first)
    */

  BEGIN

      -- Obsolete matching records in interface table with status N
      UPDATE igs_uc_uofabrv_ints SET record_status = 'O'
      WHERE record_status = 'N' AND abbrevid =  TO_NUMBER(TRIM(SUBSTR(p_record_data,1,2)));

      -- copy the marvin record into the ucas interface tables
      INSERT INTO igs_uc_uofabrv_ints(
                                    abbrevid,
                                    updater,
                                    abbrevtext,
                                    letterformat,
                                    summarychar,
                                    abbrevuse,
                                    record_status,
                                    error_code
                                   )
                                   VALUES
                                   (
                                    TO_NUMBER(TRIM(SUBSTR(p_record_data,1,2))),   -- ABBREVID,
                                    NULL,                                         -- UPDATER,
                                    TRIM(SUBSTR(p_record_data,5,57)),             -- ABBREVTEXT,
                                    TRIM(SUBSTR(p_record_data,3,1)),              -- LETTERFORMAT,
                                    TRIM(SUBSTR(p_record_data,4,1)),              -- SUMMARYCHAR,
                                    TRIM(SUBSTR(p_record_data,4,1)),              -- ABBREVUSE,
                                    'N',                                          -- RECORD_STATUS,
                                    NULL                                          -- ERROR_CODE
                                   );

        -- Increase the success record count.
        g_success_cnt := g_success_cnt +1;

  EXCEPTION
    WHEN VALUE_ERROR THEN
        fnd_message.set_name('IGS', 'IGS_UC_NON_NUMERIC_DATA');
        fnd_message.set_token('TTYPE',p_trans_type);
        fnd_file.put_line( fnd_file.log, fnd_message.get());
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_UC_MV_DATA_UPLD.TRANSFER_TO_QA - '||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END transfer_to_qa;


  PROCEDURE transfer_to_qc(
                           p_trans_type     igs_uc_load_mv_t.trans_type%TYPE,
                           p_record_data    igs_uc_load_mv_t.record_data%TYPE
                          ) AS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose    : Inserts the given QC transaction record into igs_uc_mv_uvcrs_vac and igs_uc_mv_uvcrs_vop tables
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    || smaddali  30-jun-03    Modified for ucfd203- multiple cycles build , bug#2669208
    ||                                  replaced igs_uc_mv_uvcrs_vac with igs_uc_ucrsvac_ints and
    ||                                   igs_uc_mv_uvcrs_vop with igs_uc_ucrsvop_ints
    ||  (reverse chronological order - newest change first)
    */

    ln_position     NUMBER;
    lv_course       igs_uc_ucrsvac_ints.course%TYPE;
    lv_campus       igs_uc_ucrsvac_ints.campus%TYPE;
    lv_vac_status   igs_uc_ucrsvac_ints.vacstatus%TYPE;

  BEGIN

      -- Extract the data into the temporary variables
      lv_course     := TRIM(SUBSTR(p_record_data,1,6));
      lv_campus     := TRIM(SUBSTR(p_record_data,7,1));
      lv_vac_status := TRIM(SUBSTR(p_record_data,8,1));

      -- Obsolete matching records in interface table with status N
      UPDATE igs_uc_ucrsvac_ints SET record_status = 'O'
      WHERE record_status = 'N' AND  course = lv_course AND campus = lv_campus ;


      -- Each QC transaction indicates the Vacancy detals and 100 vancancy options details.
      -- All the vacancy option details are stored in igs_uc_mv_uvcrs_vop table
      INSERT INTO igs_uc_ucrsvac_ints(
                                    course,
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
                                   VALUES
                                   (
                                    lv_course,                                   -- COURSE,
                                    lv_campus,                                   -- CAMPUS,
                                    NULL,                                        -- UPDATER,
                                    NULL,                                        -- CLUPDATED,
                                    NULL,                                        -- CLDATE,
                                    lv_vac_status,                               -- VACSTATUS,
                                    TRIM(SUBSTR(p_record_data,9,2)),             -- NOVAC,
                                    TO_NUMBER(TRIM(SUBSTR(p_record_data,11,2))), -- SCORE,
                                    NULL,                                        -- RBFULL,
                                    NULL,                                        -- SCOTVAC,
                                    'N',                                          -- RECORD_STATUS,
                                    NULL                                          -- ERROR_CODE
                                   );

    ln_position := 65;

    FOR i In 1..100 LOOP
      IF TRIM(SUBSTR(p_record_data,ln_position,2)) IS NOT NULL THEN
              -- Obsolete matching records in interface table with status N
              UPDATE igs_uc_ucrsvop_ints SET record_status = 'O'
              WHERE record_status = 'N' AND  course = lv_course
              AND campus = lv_campus AND optioncode = TRIM(SUBSTR(p_record_data,ln_position,2)) ;


        INSERT INTO igs_uc_ucrsvop_ints(
                                        course,
                                        campus,
                                        optioncode,
                                        updater,
                                        clupdated,
                                        cldate,
                                        vacstatus,
                                        record_status,
                                        error_code
                                       )
                                       VALUES
                                       (
                                        lv_course,                                 -- COURSE,
                                        lv_campus,                                 -- CAMPUS,
                                        TRIM(SUBSTR(p_record_data,ln_position,2)), -- OPTIONCODE,
                                        NULL,                                      -- UPDATER,
                                        NULL,                                      -- CLUPDATED,
                                        NULL,                                      -- CLDATE,
                                        lv_vac_status,                             -- VACSTATUS,
                                        'N',                                       -- RECORD_STATUS,
                                        NULL                                       -- ERROR_CODE
                                       );
      END IF;
      ln_position := ln_position + 2;
    END LOOP;

    -- Increase the success record count.
    g_success_cnt := g_success_cnt +1;

  EXCEPTION
    WHEN VALUE_ERROR THEN
        fnd_message.set_name('IGS', 'IGS_UC_NON_NUMERIC_DATA');
        fnd_message.set_token('TTYPE',p_trans_type);
        fnd_file.put_line( fnd_file.log, fnd_message.get());
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_UC_MV_DATA_UPLD.TRANSFER_TO_QC - '||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END transfer_to_qc;


  PROCEDURE transfer_ack_to_trans(
                                  p_trans_type     igs_uc_load_mv_t.trans_type%TYPE,
                                  p_error_code     igs_uc_load_mv_t.error_code%TYPE,
                                  p_record_data    igs_uc_load_mv_t.record_data%TYPE
                                 ) AS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose    : Inserts the given Acknowledgment transactions into igs_uc_mv_tranin table
    ||  Known limitations, enhancements or remarks :
    ||           RGANGARA 11-Nov-02. It is said that all the transaction types for all systems falling
    ||                               under Ack/Echo transactions have the same format and update processing
    ||                               logic and hence using the same procedure for all such transactions.
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||  rgangara        11-Nov-02       Modified the procedure to work for different types of ECHO/
    ||                                  Acknowledgment transactions.
    ||                                  NOTE: Clarified that the processing remains same for all the
    ||                                  different types of Transactions falling under this category
    ||                                  Also to update IGS_UC_TRANSACTIONS table directly instead of
    ||                                  Marvin tranin table.
    ||  rbezawad        17-Dec-02       Modified the procedure to remove the code which is loggig
    ||                                  IGS_UC_TRAN_PROC_APPCH for 2nd time w.r.t. Bug 2711183.
    || smaddali  30-jun-03              Modified for ucfd203- multiple cycles build , bug#2669208
    ||                                  to add ucas_cycle check in the cursor cur_trans
    */

        -- Get transactions for the application, Choice number , ucas_cycle and Transaction Type having NULL error_code.
        -- NULL error code implies that the no response/echo/Ack transaction has been received against it.
        -- smaddali modified this cursor for ucfd203 - multiple cycles build to add ucas_cycle check in where clause
        CURSOR cur_trans(
                      cp_appno     igs_uc_transactions.app_no%TYPE,
                      cp_choiceno  igs_uc_transactions.choice_no%TYPE
                     ) IS
        SELECT rowid              ,
             uc_tran_id         ,
             transaction_id     ,
             datetimestamp      ,
             updater            ,
             error_code         ,
             transaction_type   ,
             app_no             ,
             choice_no          ,
             decision           ,
             program_code       ,
             campus             ,
             entry_month        ,
             entry_year         ,
             entry_point        ,
             soc                ,
             comments_in_offer  ,
             return1            ,
             return2            ,
             hold_flag          ,
             sent_to_ucas       ,
             created_by         ,
             creation_date      ,
             last_updated_by    ,
             last_update_date   ,
             last_update_login  ,
             test_cond_cat      ,
             test_cond_name     ,
             inst_reference     ,
             auto_generated_flag,
             system_code        ,
             ucas_cycle         ,
             modular            ,
             part_time
        FROM igs_uc_transactions
        WHERE app_no    = cp_appno
         AND choice_no = cp_choiceno
         AND transaction_type = p_trans_type
         AND error_code IS NULL
         AND ucas_cycle  = g_c_cycles.configured_cycle
        ORDER BY  uc_tran_id;

        trans_rec       cur_trans%ROWTYPE;
        ln_choiceno     igs_uc_transactions.choice_no%TYPE;
        l_char_choice   VARCHAR2(1) := TRIM(SUBSTR(p_record_data,10,1));
        ln_appno        igs_uc_transactions.app_no%TYPE := TO_NUMBER(TRIM(SUBSTR(p_record_data,1,8)));
  BEGIN

    fnd_message.set_name('IGS', 'IGS_UC_TRAN_PROC_APPCH');
    fnd_message.set_token('TTYPE',p_trans_type);
    fnd_message.set_token('APPNO', ln_appno);
    fnd_message.set_token('CHOICENO', l_char_choice);
    fnd_file.put_line( fnd_file.log, fnd_message.get());

    --Added as part of UCFD02 build for GTTR system.
    --If the incoming CHOICE No. is Alphabetic then it has to be converted to appropriate Number and used.
    -- i.e. if the incoming Choice No = 'A' then Choice No = 10, If it is 'F' then Choice = 15 etc.
    IF NOT ASCII(l_char_choice) BETWEEN 49 and 57 THEN
       ln_choiceno := get_numeric_choice(l_char_choice);
    ELSE
       ln_choiceno := TO_NUMBER(l_char_choice);
    END IF;

    OPEN cur_trans( ln_appno, ln_choiceno);
    FETCH cur_trans INTO trans_rec;

    -- If there is only one instance of the corresponding transaction record then, update the record with the error code
    -- If no record was foung then log a message that "No Transaction record was found - Error codition since a transaction
    -- coming as Echo/Ack a transaction record should be existing in our tranaction table.
    -- If more than one record then update the oldest transaction record.
    IF  cur_trans%NOTFOUND THEN
        fnd_message.set_name('IGS', 'IGS_UC_MV_NO_TRANIN');
        fnd_message.set_token('TTYPE',p_trans_type);
        fnd_message.set_token('APPNO',ln_appno);
        fnd_message.set_token('CHCNO',ln_choiceno);
        fnd_file.put_line( fnd_file.log, fnd_message.get());
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

    ELSE
        -- update the corresponding transaction record with Timestamp and Errorcode
        igs_uc_transactions_pkg.update_row(
                                     x_rowid                => trans_rec.rowid              ,
                                     x_uc_tran_id           => trans_rec.uc_tran_id         ,
                                     x_transaction_id       => trans_rec.transaction_id     ,
                                     x_datetimestamp        => SYSDATE                      ,  -- update
                                     x_updater              => trans_rec.updater            ,
                                     x_error_code           => p_error_code                 ,  -- update
                                     x_transaction_type     => trans_rec.transaction_type   ,
                                     x_app_no               => trans_rec.app_no             ,
                                     x_choice_no            => trans_rec.choice_no          ,
                                     x_decision             => trans_rec.decision           ,
                                     x_program_code         => trans_rec.program_code       ,
                                     x_campus               => trans_rec.campus             ,
                                     x_entry_month          => trans_rec.entry_month        ,
                                     x_entry_year           => trans_rec.entry_year         ,
                                     x_entry_point          => trans_rec.entry_point        ,
                                     x_soc                  => trans_rec.soc                ,
                                     x_comments_in_offer    => trans_rec.comments_in_offer  ,
                                     x_return1              => trans_rec.return1            ,
                                     x_return2              => trans_rec.return2            ,
                                     x_hold_flag            => trans_rec.hold_flag          ,
                                     x_sent_to_ucas         => trans_rec.sent_to_ucas       ,
                                     x_test_cond_cat        => trans_rec.test_cond_cat      ,
                                     x_test_cond_name       => trans_rec.test_cond_name     ,
                                     x_mode                 => 'R'                          ,
                                     x_inst_reference       => trans_rec.inst_reference     ,
                                     x_auto_generated_flag  => trans_rec.auto_generated_flag,
                                     x_system_code          => trans_rec.system_code        ,
                                     x_ucas_cycle           => trans_rec.ucas_cycle         ,
                                     x_modular              => trans_rec.modular            ,
                                     x_part_time            => trans_rec.part_time
                                    );

        -- Increase the success record count.
        g_success_cnt := g_success_cnt +1;
    END IF;

    CLOSE cur_trans;

  EXCEPTION
    WHEN VALUE_ERROR THEN
        fnd_message.set_name('IGS', 'IGS_UC_NON_NUMERIC_DATA');
        fnd_message.set_token('TTYPE',p_trans_type);
        fnd_file.put_line( fnd_file.log, fnd_message.get());
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_UC_MV_DATA_UPLD.TRANSFER_ACK_TO_TRANS - '||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END transfer_ack_to_trans;



  FUNCTION check_validity RETURN BOOLEAN IS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose    : Function returns TRUE if the
    ||                a. Data file contains valid supported file formats specified in the igs_uc_cyc_defaults
    ||                b. Profile interface value is set to Marvin
    ||                c. Data file contains valid data sections with number of Headers and Trailers are equal
    ||               Else this function returns FALSE.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    || smaddali  30-jun-03      Modified for ucfd203- multiple cycles build , bug#2669208
    ||                          replaced profile for interface type by igs_uc_cyc_defaults
    ||  (reverse chronological order - newest change first)
    */

        -- Check for the count of the number of the Headers and trailers
        CURSOR hdr_count IS
        SELECT MOD(COUNT(*),2)
        FROM igs_uc_load_mv_t
        WHERE trans_type = '*S';

        -- Check whether the file type present in the data file and the file
        -- types mentioned in the system are correct.
        CURSOR chk_file_type IS
        SELECT DISTINCT file_type
        FROM igs_uc_load_mv_t
        WHERE file_type IS NOT NULL ;
        chk_file_type_rec  chk_file_type%ROWTYPE ;

        ln_count   NUMBER := 0 ;

        -- smaddali added cursor for bug#2669208 , ucfd203 build
        CURSOR c_interface(cp_sys_code igs_uc_cyc_defaults.system_code%TYPE) IS
        SELECT ucas_interface
        FROM igs_uc_cyc_defaults
        WHERE  system_code = cp_sys_code
        AND  ucas_cycle = g_c_cycles.configured_cycle ;
        c_interface_rec c_interface%ROWTYPE ;

        l_valid BOOLEAN ;

  BEGIN

    l_valid := TRUE ;
    -- Get the Header and Trailer counts from the Marvin data file.
    OPEN hdr_count;
    FETCH hdr_count INTO ln_count;
    CLOSE hdr_count;

    -- If the count is 0 then number of headers is equal to number of trailers
    -- so return TRUE else FALSE
    IF ln_count = 0 THEN

       -- Check whether the Data format type is supported.
       FOR chk_file_type_rec IN chk_file_type LOOP
              -- check if setup is configured for this system
              OPEN c_interface(chk_file_type_rec.file_type) ;
              FETCH c_interface INTO c_interface_rec ;
              IF c_interface%NOTFOUND THEN
                   CLOSE c_interface ;
                   l_valid := FALSE ;
                   fnd_message.set_name('IGS', 'IGS_UC_MV_SYSTEM_NOT_CONFIG');
                   fnd_message.set_token('SYSTEM', chk_file_type_rec.file_type ) ;
                   fnd_file.put_line( fnd_file.log, fnd_message.get());
              ELSE
                 CLOSE c_interface ;
                 -- check for Marvin or Hercules Interface.
                 -- Load Marvin data only if the profile value is Marvin.
                 IF c_interface_rec.ucas_interface <> 'M' THEN
                        l_valid := FALSE ;
                        fnd_message.set_name('IGS', 'IGS_UC_SYS_NOT_MARV');
                        fnd_message.set_token('SYSTEM_CODE' ,chk_file_type_rec.file_type) ;
                        fnd_file.put_line( fnd_file.log, fnd_message.get());
                 END IF ;
              END IF;
       END LOOP ;

    ELSE
        l_valid := FALSE ;
        fnd_message.set_name('IGS', 'IGS_UC_MV_DATA_SEC_WRNG');
        fnd_file.put_line( fnd_file.log, fnd_message.get());
    END IF;

    RETURN l_valid ;

  EXCEPTION
    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_UC_MV_DATA_UPLD.CHECK_VALIDITY - '||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END check_validity;


  FUNCTION merge_data(
                      p_marvin_id  IGS_UC_LOAD_MV_T.marvin_id%TYPE
                     ) RETURN VARCHAR2 AS

    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose    : This is a recursive function which calls itself and appends
    ||               remaining record data if the logical data in the data file
    ||               spans more than one physical record.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

        -- Get the marvin data for the given marvin_id.
        CURSOR cur_ucas (cp_marvin_id  igs_uc_load_mv_t.marvin_id%TYPE) IS
        SELECT *
        FROM igs_uc_load_mv_t
        WHERE marvin_id = cp_marvin_id;

        ucas_rec igs_uc_load_mv_t%ROWTYPE;

  BEGIN

     -- Get the marvin data for processing.
     OPEN cur_ucas(p_marvin_id);
     FETCH cur_ucas INTO ucas_rec;
     CLOSE cur_ucas;

     -- If the continuation flag is 9, means it is already the last record, then return the same record
     -- else merge the data till it finds the last record.
     -- RPAD data for 80 characters so that position of the data is retained if data is merged.
     IF ucas_rec.contd_flag = '9' THEN
           UPDATE igs_uc_load_mv_t SET record_status = 'N' WHERE marvin_id = p_marvin_id;
           RETURN (RPAD(NVL(ucas_rec.record_data,' '),67));
     ELSE
           RETURN (RPAD(NVL(ucas_rec.record_data,' '),67) || merge_data(ucas_rec.marvin_id + 1));
     END IF;

  EXCEPTION
    WHEN app_exception.record_lock_exception THEN
        RAISE;

    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_UC_MV_DATA_UPLD.MERGE_DATA - '||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END merge_data;


  PROCEDURE rearrange_data IS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose    : This procedure checks whether the logical record data spans
    ||               accross more than one physical record in the data file. If
    ||               data is spanned then this funciton calls merge function to
    ||               merge the spanned data.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    || smaddali  30-jun-03    Modified for ucfd203- multiple cycles build , bug#2669208
    ||  (reverse chronological order - newest change first)
    */

        -- Get the details of
        CURSOR cur_ucas IS
        SELECT marvin_id
        FROM igs_uc_load_mv_t
        WHERE contd_flag = '1'
        AND record_status = 'N'
        ORDER BY marvin_id
        FOR UPDATE OF marvin_id NOWAIT;

        lv_record_data    IGS_UC_LOAD_MV_T.record_data%TYPE;

  BEGIN

   -- Loop thru all the records in whcih logical record spanned accross more than one record.
   FOR rec_cur_ucas IN cur_ucas LOOP
        lv_record_data := merge_data(rec_cur_ucas.MARVIN_ID);
        UPDATE IGS_UC_LOAD_MV_T SET record_data = lv_record_data, record_status = 'R' WHERE CURRENT OF cur_ucas;
   END LOOP;

  EXCEPTION
    WHEN app_exception.record_lock_exception THEN
       RAISE;

    WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_UC_MV_DATA_UPLD.REARRANGE_DATA - '||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END rearrange_data;


  PROCEDURE transfer_data(
                               errbuf        OUT NOCOPY  VARCHAR2,
                               retcode       OUT NOCOPY  NUMBER
                        ) IS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose    : Procedure whcih will check for transaction type and calls the
    ||               corresponding procedure for transfer of data into the different tables
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||  rgangara        11-Nov-02       Added call to process *G, *T transaction types
    ||                                  and modified Acknowledgement transaction call to
    ||                                  process different type of ECHO transactions.
    ||                                  as part of UCFD02_Small_SYstems. Bug# 2643048
    ||  rbezawad        06-Mar-03       Removed the code which is increasing the "success record count" after processing "AE" transaction w.r.t Bug 2810665.
    ||  smaddali        30-Jun-03       Modified for ucfd203- multiple cycles build , bug#2669208
    ||                                  forking the process depending on the configured cycle
    ||  jchakrab        27-Jul-04       Modified for UCFD308-UCAS 2005 Regulatory Changes
    ||  jbaber          12-Jul-05       Modified for UC315 - UCAS Support 2006
    */


        -- Get the details of
        CURSOR cur_ucas IS
        SELECT marvin_id, trans_type, error_code, record_data
        FROM igs_uc_load_mv_t
        WHERE record_status = 'R'
        ORDER BY marvin_id ;

        l_valid_rec  BOOLEAN := TRUE;
        l_curr_rec_data igs_uc_load_mv_t.record_data%TYPE;
        l_trans_type igs_uc_load_mv_t.trans_type%TYPE;

  BEGIN

    -- Initialize the flag to TRUE before every run
    l_valid_rec := TRUE;

    -- Loop thru all the records and transfer data into corresponding
    -- interface tables based on the Transaction Type
    FOR rec_cur_ucas IN cur_ucas LOOP

        -- copying the cursor values into temporary variable for logging purposes, in case exceptions are raised.
        l_curr_rec_data := rec_cur_ucas.record_data;
        l_trans_type := rec_cur_ucas.trans_type;

        -- Incarease the global count.
        g_record_cnt := g_record_cnt + 1;


        -- Check whether the Applicaiton number is correct or not for all the Applications tables.
        -- If the Application number is Invalid then the job should log a message and continue with
        -- available transaction
        IF rec_cur_ucas.trans_type IN ( '*A','*C','*G','*H','*K','*N','*P','*R','*T','*W','*X','*Z','LA', 'LC','LD','LE','LK','PE','RA','RD','RE','RK','RQ','RR','RW','RX','XA','XD') THEN
            IF TO_CHAR(get_check_digit(SUBSTR(rec_cur_ucas.record_data,1,8))) <> SUBSTR(rec_cur_ucas.record_data,9,1) THEN
                  l_valid_rec := FALSE;
                  fnd_message.set_name('IGS', 'IGS_UC_INVLD_APPNO');
                  fnd_message.set_token('APPNO',SUBSTR(rec_cur_ucas.record_data,1,8));
                  fnd_message.set_token('TTYPE',rec_cur_ucas.trans_type);
                  fnd_file.put_line(fnd_file.log,fnd_message.get );
            END IF;

        ELSE
             -- if trans type = 'AE' then it carries the file seq num which needs to be validated that the flat files are being processed in sequence.
             IF rec_cur_ucas.trans_type = 'AE' AND SUBSTR(rec_cur_ucas.record_data,1,3) = 'SEQ' THEN
                  validate_file_seq_num(rec_cur_ucas.marvin_id, SUBSTR(rec_cur_ucas.record_data,4));
             END IF;
        END IF;

        -- Transfer all the transactions from the temporary table to corresponding
        -- interface tables based on the transaction type.
        IF l_valid_rec THEN
           -- If system is configured for 2003 cycle then call the procedures for 2003 marvin structure
           IF  g_c_cycles.configured_cycle = '2003' THEN

                IF rec_cur_ucas.trans_type = '*N' THEN
                    transfer_to_starn( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = '*A' THEN
                    transfer_to_stara( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = '*C' THEN
                    transfer_to_starc( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = '*G' THEN
                    transfer_to_starg( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = '*H' THEN
                    transfer_to_starh( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = '*K' THEN
                    transfer_to_stark( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type IN ('*P', '*R')  THEN
                    transfer_to_starpqr( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = '*T' THEN
                    transfer_to_start( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = '*W' THEN
                    transfer_to_starw( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = '*X' THEN
                    transfer_to_starx( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = '*Z' THEN
                    transfer_to_starz( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = 'QA' THEN
                    transfer_to_qa( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = 'QC' THEN
                    transfer_to_qc( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type IN ('LA', 'LC','LD','LE','LK','PE','RA','RD','RE','RK','RQ','RR','RW','RX','XA','XD') THEN
                    transfer_ack_to_trans( rec_cur_ucas.trans_type, rec_cur_ucas.error_code, rec_cur_ucas.record_data);
                END IF;
          ELSIF g_c_cycles.configured_cycle = '2004' OR g_c_cycles.configured_cycle = '2005' OR g_c_cycles.configured_cycle = '2006' OR g_c_cycles.configured_cycle = '2007' THEN
               -- Only *W has changed from 2003 to add new columns,
               -- However this change is only in the Hercules interface and not in marvin interface
               -- Hence the calls for 2003 and 2004 are exactly same
               -- No data model changes for 2005, therefore use same calls for 2005 as in 2004
                IF rec_cur_ucas.trans_type = '*N' THEN
                    transfer_to_starn( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = '*A' THEN
                    transfer_to_stara( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = '*C' THEN
                    transfer_to_starc( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = '*G' THEN
                    transfer_to_starg( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = '*H' THEN
                    transfer_to_starh( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = '*K' THEN
                    transfer_to_stark( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type IN ('*P', '*R')  THEN
                    transfer_to_starpqr( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = '*T' THEN
                    transfer_to_start( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = '*W' THEN
                    transfer_to_starw( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = '*X' THEN
                    transfer_to_starx( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = '*Z' THEN
                    transfer_to_starz( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = 'QA' THEN
                    transfer_to_qa( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type = 'QC' THEN
                    transfer_to_qc( rec_cur_ucas.trans_type, rec_cur_ucas.record_data);
                ELSIF rec_cur_ucas.trans_type IN ('LA', 'LC','LD','LE','LK','PE','RA','RD','RE','RK','RQ','RR','RW','RX','XA','XD') THEN
                    transfer_ack_to_trans( rec_cur_ucas.trans_type, rec_cur_ucas.error_code, rec_cur_ucas.record_data);
                END IF;

          ELSIF g_c_cycles.configured_cycle = '2008' THEN
               NULL ;  -- future use
          END IF ;

        END IF; -- record is valid

   END LOOP;

   IF NOT l_valid_rec THEN
        retcode := 2 ;
        RETURN ;
   END IF ;

  EXCEPTION
    WHEN OTHERS THEN
        fnd_file.put_line( fnd_file.log, 'TRANSACTION: ' ||l_trans_type || ' DATA : ' || l_curr_rec_data);
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_UC_MV_DATA_UPLD.TRANSFER_DATA - '||SQLERRM);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

  END transfer_data;


  PROCEDURE process_marvin_data(
                               errbuf        OUT NOCOPY  VARCHAR2,
                               retcode       OUT NOCOPY  NUMBER
                               ) IS
    /*
    ||  Created By : brajendr
    ||  Created On : 05-Apr-2002
    ||  Purpose    : This is main Procedure which will transfer the Marvin flat file data
    ||               into the corresponding Dummy Hercules tables. This procedures calls
    ||               other prodecures / functions in the given order
    ||               a. check_validity
    ||               b. rearrange_data
    ||               a. transfer_data
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    || anwest    18-JAN-06    Bug# 4950285 R12 Disable OSS Mandate
    || smaddali  30-jun-03    Modified for ucfd203- multiple cycles build , bug#2669208
    ||                     added validations on cycle info
    ||  (reverse chronological order - newest change first)
    */


  BEGIN

      --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
      IGS_GE_GEN_003.SET_ORG_ID;

      fnd_file.put_line( fnd_file.log, ' ');
      retcode           := 0;
      -- Set the global values, which are used to set the WHO Columns.
      g_record_cnt      := 0;
      g_success_cnt     := 0;

      -- Get the current and configured cycles , if not setup then show error and exit
      g_c_cycles        := NULL ;
      OPEN c_cycles ;
      FETCH c_cycles INTO g_c_cycles ;
      CLOSE c_cycles ;
      IF  g_c_cycles.configured_cycle IS NULL OR g_c_cycles.current_cycle IS NULL THEN
           fnd_message.set_name('IGS','IGS_UC_CYCLE_NOT_FOUND');
           errbuf  := fnd_message.get;
           fnd_file.put_line(fnd_file.log, errbuf);
           retcode := 2 ;
           RETURN ;
      END IF ;

      -- get the configured cycle of hercules system
      c_ucas_cycle_rec  := NULL ;
      OPEN c_ucas_cycle ;
      FETCH c_ucas_cycle INTO c_ucas_cycle_rec ;
      CLOSE c_ucas_cycle ;
      -- If hercules and our oss system are not configured to the same cycle then report error and exit
      IF NVL(c_ucas_cycle_rec.entry_year,0) <> LTRIM(SUBSTR(g_c_cycles.configured_cycle,3,2) ) THEN
            fnd_message.set_name('IGS','IGS_UC_CYCLES_NOT_SYNC');
            fnd_message.set_token('UCAS_CYCLE',LTRIM(SUBSTR(g_c_cycles.configured_cycle,3,2) ) );
            fnd_message.set_token('HERC_CYCLE',NVL(c_ucas_cycle_rec.entry_year,0 ) );
            fnd_message.set_token('SYSTEM_CODE','UCAS');
            errbuf := fnd_message.get ;
            fnd_file.put_line(fnd_file.log,errbuf );
            retcode := 2 ;
            RETURN ;
      END IF ;

      -- show the configured cycle information , because the other messages donot show its value
      fnd_message.set_name('IGS','IGS_UC_CYC_INFO');
      fnd_message.set_token('CONF_CYCLE',g_c_cycles.configured_cycle );
      fnd_file.put_line(fnd_file.log, fnd_message.get );
      fnd_file.put_line( fnd_file.log, ' ');

      -- Check for the Validity of the file.
      -- 1.Number of headers in the data file should equal to number of trailers
      -- 2.cycle defaults should be setup for each of the systems present in the flat file
      -- 3.ucas interface should be setup to Marvin for each of the systems present in the flat file
      IF NOT check_validity THEN
            retcode := 2;
            RETURN;
      END IF;

      -- validate if marvin seq for all the systems in the flat file is in sequence
      IF NOT sequence_validity THEN
            retcode := 2;
            RETURN;
      END IF ;

      -- Re-arrange data
      -- If one logical data spans accross more than one physical records, then
      -- Group all related records to one record for further processing.
      rearrange_data;

      -- Move data to actual interface tables.
      transfer_data(errbuf, retcode) ;
      -- If any validations failed while transfering the transactions then rollback and complete in error
      IF retcode = 2 THEN
         ROLLBACK ;
         RETURN ;
      END IF ;

      -- Print Number of records successfully transferred
      fnd_file.put_line( fnd_file.log, ' ');
      fnd_message.set_name('IGS', 'IGS_UC_MV_LOAD_SUCCESS');
      fnd_message.set_token('CNT', g_success_cnt);
      fnd_file.put_line( fnd_file.log, fnd_message.get());

      -- commit the data;
      COMMIT;
      fnd_file.put_line( fnd_file.log, ' ');

  EXCEPTION
     WHEN app_exception.record_lock_exception THEN
        ROLLBACK;
        retcode := 2;
        errbuf := fnd_message.get_string('IGF','IGF_GE_LOCK_ERROR');
        igs_ge_msg_stack.conc_exception_hndl;

     WHEN OTHERS THEN
        ROLLBACK;
        retcode := 2;
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_UC_MV_DATA_UPLD.PROCESS_MARVIN_DATA - '||SQLERRM);
        errbuf := fnd_message.get;
        igs_ge_msg_stack.conc_exception_hndl;

  END process_marvin_data;

 END igs_uc_mv_data_upld;

/
