--------------------------------------------------------
--  DDL for Package Body IGS_UC_EXT_MARVIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_EXT_MARVIN" AS
/* $Header: IGSUC33B.pls 120.3 2006/08/21 03:52:45 jbaber noship $ */
/* HISTORY
 WHO         WHEN         WHAT
 nalkumar    09-APR-2002  Created the Document
 ayedubat    19-NOV-2002  Changed the procedures: create_file,prepare_data,
                          prepare_trailer and check_sec_len for small systems
                          support build. Enhancement Bug # 2643048
 ayedubat    13-DEC-2002  Changed the procedure,prepare_data for bug # 2711416
 ayedubat    24-DEC-2002  Changed the procedure,create_file for bug, 2711256
 pmarada     11-jun-2003  Added ucas_cycle to transaction table removed the
                          adm_systems references as per UCFD203 Multiple cycles,bug 2669208
 ayedubat    02-JUL-2003  Changed as part of Multiple Cycles Enhancement, 2669208
                          As per the New enhancment only the Transactions for the Configured
                          Cycle will be exported. Also Course Vacancies and Vacancy Options
                          will be exported for SWAS along with the existing FTUG System.
                          Removed the procedure, trunc_tables
 dsridhar    30-SEP-2003  Bug No: 3156212. Code modified to consider only those transactions
                          for systems configured as MARVIN.
 jchakrab    07-Sep-2004  Modified for Bug#3872286
 anwest      18-Jan-2006  Bug# 4950285 R12 Disable OSS Mandate
 anwest      13-Feb-2006  Bug# 4960517 - Replaced profile IGS_PS_EXP_DIR_PATH with UTL_FILE_OUT
 jbaber      11-Jul-2006  Modified for UC325 - UCAS 2007 Support
*/

  l_sequence_number NUMBER(6) DEFAULT 00001;
  l_total_trans     NUMBER(6) DEFAULT 0;
  l_date            VARCHAR2(10) DEFAULT TO_CHAR(SYSDATE,'ddmmyy');
  l_file_name       VARCHAR2(20); --File Name format is AfinUUU.xxxxxx
  l_file_prm        UTL_FILE.FILE_TYPE;

  PROCEDURE open_file ( p_location  IN VARCHAR2,
                        p_filename  IN VARCHAR2) IS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 09-APR-2002
  ||  Purpose : To open the flat file.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    l_file_prm := NULL;
    l_file_prm:= UTL_FILE.FOPEN (p_location,
                                 p_filename,
                                 'w');
  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('IGS', 'IGS_EN_INVALID_PATH');
      FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;

  END open_file;

  PROCEDURE put_line (p_line IN VARCHAR2) IS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 09-APR-2002
  ||  Purpose : To put the line into the flat file.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    UTL_FILE.PUT_LINE (l_file_prm, p_line );
    UTL_FILE.FFLUSH (l_file_prm );
  END put_line;

  PROCEDURE close_file IS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 09-APR-2002
  ||  Purpose : To close the flat file.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    IF (UTL_FILE.IS_OPEN( l_file_prm )) THEN
      UTL_FILE.FCLOSE( l_file_prm );
    END IF;
  END close_file;


  PROCEDURE  prepare_header( p_inst_code IN VARCHAR2,
                             p_sys_ind   IN VARCHAR2) IS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 09-APR-2002
  ||  Purpose : This procedure loads the header data into the Flat file.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who           When          What
  ||  Ayedubat     13_DEC-2002   Changed the herader line to add the RPAD to 4 characters
  ||                             for institution code from 14 to 17 for bug: 2711145
  ||  (reverse chronological order - newest change first)
  */
    l_header    VARCHAR2(100);
  BEGIN
    --
    -- For the Header the sequence Number will be always '00001', because
    -- will be the first line of the data file. The 'Transaction Type' for
    -- the header is '*S' and the 'Length' is '1' and there is no 'Error Code'
    -- for the Header.
    --
    l_header := '000019*S 1   '||RPAD(p_inst_code,4)||'I'||l_date||'00000'||p_sys_ind;
    put_line(l_header);

  EXCEPTION WHEN OTHERS THEN
     Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
     FND_MESSAGE.SET_TOKEN('NAME','IGS_UC_EXT_MARVIN.PREPARE_HEADER'||' - '||SQLERRM);
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;

  END prepare_header;

  PROCEDURE  prepare_trailer(p_inst_code IN VARCHAR2,
                             p_sys_ind   IN VARCHAR2) IS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 09-APR-2002
  ||  Purpose : This procedure loads the trailer data into the flat file.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who        When         What
  ||  ayedubat   19-NOV-2002  Changed the section type to 'E' for
  ||                          End of Section for bug # 2643048
  ||  Ayedubat   13_DEC-2002   Changed the herader line to add the RPAD to 4 characters
  ||                             for institution code from 14 to 17 for bug: 2711145
  ||  (reverse chronological order - newest change first)
  */
    l_trailer    VARCHAR2(100);
  BEGIN

    l_trailer := LPAD((l_sequence_number + 1),5,0)||'9*S 1   '||RPAD(p_inst_code,4)||'E'||l_date||LPAD(l_total_trans,5,0)||p_sys_ind;
    put_line(l_trailer);

  EXCEPTION WHEN OTHERS THEN
     Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
     FND_MESSAGE.SET_TOKEN('NAME','IGS_UC_EXT_MARVIN.PREPARE_TRAILER'||' - '||SQLERRM);
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;

  END prepare_trailer;

  PROCEDURE create_directory ( p_directory OUT NOCOPY VARCHAR2 ) AS
  /**********************************************************
  Created By : ayedubat
  Date Created By : 24-DEC-2002
  Purpose : Private procedure craeted for finding the Directory of the filename.
            This will check the value of profile 'UTL_FILE_OUT'
            (output dir for export data file) matches with the value in v$parameter
	          for the name utl_file_dir.
  Know limitations, enhancements or remarks
  Change History
  Who		When 		What
  (reverse chronological order - newest change first)
  ***************************************************************/

  l_start_str_index  NUMBER := 1;
  l_end_comma_index  NUMBER := 1;
  l_start_comma_index NUMBER := 1;
  l_fndvalue VARCHAR2(80);
  l_dbvalue V$PARAMETER.VALUE%TYPE;
  l_db_directory V$PARAMETER.VALUE%TYPE;

  CURSOR cur_parameter_value IS
    SELECT LTRIM(RTRIM(value))
    FROM V$PARAMETER
    WHERE name ='utl_file_dir';

  CURSOR cur_db_dir IS
    SELECT DECODE( INSTR(l_dbvalue,',',l_start_str_index),0,LENGTH(l_dbvalue)+1, INSTR(l_dbvalue,',',l_start_str_index) )
    FROM DUAL ;

  BEGIN

    -- Initialize the OUT variable
    p_directory := NULL ;

    -- Fetch the Profile value for the directory name used to export flat file
    l_fndvalue := LTRIM(RTRIM(FND_PROFILE.VALUE('UTL_FILE_OUT')));

    -- If the profile is NULL, return the procedure by assigning the NULL value to p_directory
    IF l_fndvalue IS NULL THEN
      p_directory := NULL ;
      RETURN ;
    END IF ;

    -- Fetch the Value of the Database parameter, utl_file_dir
    -- which contains list of out put directories seperated by comma
    OPEN cur_parameter_value ;
    FETCH cur_parameter_value INTO l_dbvalue ;

    IF cur_parameter_value%FOUND AND l_dbvalue IS NOT NULL THEN

      -- Find the starting position of the Profile value with in the database parameter directory's list
      -- If not found, return the procedure by assigning the NULL value to p_directory
      l_start_str_index := INSTR(l_dbvalue,l_fndvalue,l_end_comma_index) ;

      IF l_start_str_index = 0 THEN
        p_directory := NULL ;
        CLOSE cur_parameter_value ;
        RETURN ;
      END IF;

      -- Find the position of the comma, which is just before the
      -- required directory(Profile value) in the database parameter value
      -- If no comma found( if it first in the list), then returns 1
      l_start_comma_index := INSTR(SUBSTR(l_dbvalue,1,l_start_str_index),',',-1) + 1 ;

      -- Find the position of the comma, which is just after the
      -- required directory(Profile value) in the database parameter value
      -- If no comma found( if it last in the list), then returns the length of database parameter value
      OPEN cur_db_dir ;
      FETCH cur_db_dir INTO l_end_comma_index ;
      CLOSE cur_db_dir ;

      -- Find the value of the Database parameter value between l_start_comma_index and l_end_comma_index
      l_db_directory := LTRIM(RTRIM(SUBSTR(l_dbvalue,l_start_comma_index, l_end_comma_index-l_start_comma_index))) ;

      -- If the Profile Value is with in the Database parameter sirectory list, return the value
      IF l_db_directory = l_fndvalue THEN
        p_directory := l_fndvalue ;
      END IF;

    ELSE
      p_directory := NULL ;

    END IF ;
    CLOSE cur_parameter_value ;

  EXCEPTION
    WHEN OTHERS THEN
      p_directory := NULL ;
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGS_UC_EXT_MARVIN.CREATE_DIRECTORY'||' - '||SQLERRM);
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;

  END create_directory ;

  PROCEDURE check_sec_len(tran_len NUMBER,
                          p_sys_ind  IN VARCHAR2) IS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 09-APR-2002
  ||  Purpose : To check if the number of lines in the current section is exceeding the maximum limit
  ||            and if it is exceeding the limit then close the current section
  ||            and open a new section.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who       When          What
  ||  ayedubat  19-NOV-2002   Changed the procedure to add p_sys_ind parameter
  ||                          for the bug # 2643048
  */
    CURSOR cur_c1 IS
    SELECT DISTINCT current_inst_code
    FROM igs_uc_defaults ;

    l_max_line    NUMBER(7) DEFAULT 99999; --DEFAULT 17;
    l_total_lines NUMBER(7);
    l_inst_code   igs_uc_defaults.current_inst_code%TYPE;

  BEGIN

    -- Get the Institution Code
    OPEN cur_c1;
    FETCH cur_c1 INTO l_inst_code;
    CLOSE cur_c1;

    l_total_lines := tran_len + l_sequence_number + 1; -- 1 for the Trailer.
    IF l_total_lines > l_max_line THEN

      -- To prepare the Trailer Information.
      prepare_trailer(p_inst_code => l_inst_code,
                      p_sys_ind   => p_sys_ind);

      -- Reset the Sequence Number and the Total Transaction Numbers.
      l_sequence_number := 00001;
      l_total_trans := 0;

      -- To prepare the Header Information.
      prepare_header(p_inst_code => l_inst_code,
                     p_sys_ind   => p_sys_ind);

    END IF;

  EXCEPTION WHEN OTHERS THEN
    Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME','IGS_UC_EXT_MARVIN.CHECK_SEC_LEN'||' - '||SQLERRM);
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;

  END check_sec_len;


  PROCEDURE  prepare_data ( p_sys_ind  IN VARCHAR2, p_configured_cycle IN NUMBER,
                            p_current_cycle IN NUMBER, p_current_inst_code IN VARCHAR2) IS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 09-APR-2002
  ||  Purpose : This procedure loads the record data into the flat file.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who       When            What
  || ayedubat   18-NOV-2002   Changed the signature of the package to add a
  ||                          new parameter,p_sys_ind. As part of small systems support,
  ||                          now this process is called once for each system.
  ||                          As part of this change, all the transactions are selecting
  ||                          from IGS_UC_TRANSACTIONS table instead of IGS_UC_MV_TRANIN.
  ||                          Created the new 'LE' type of transaction.
  ||                          Enh bug # 2643048
  || ayedubat  13-DEC-2002    Changed the LA and LD transactions to write the Course element,
  ||                          Entry Year and Entry month , Point of Entry, Sumary of Conditions
  ||                          and Comments in Offer elements, for bug# 2711416
  || ayedubat  02-JUL-2003    Changed as part of Multiple Cycles Enhancement, 2669208
  ||                          Replaced the tables igs_uc_mv_uvcrs_vacm, igs_uc_mv_uvcrs_vop and
  ||                          igs_uc_mv_uvofr_abv with igs_uc_crse_dets, igs_uc_crse_vac_ops and
  ||                          igs_uc_ref_off_abrv to fecth the Transactions.
  ||
  ||  (reverse chronological order - newest change first)
  */

    -- Cursor to fetch the pending transactions of a given UCAS System
    CURSOR cur_transactions( p_system_code IGS_UC_TRANSACTIONS.system_code%TYPE ) IS
      SELECT
        ROWID,
        uc_tran_id,
        transaction_id,
        datetimestamp,
        updater,
        error_code,
        transaction_type,
        app_no,
        choice_no,
        decision,
        program_code,
        campus,
        entry_month,
        entry_year,
        entry_point,
        soc,
        comments_in_offer,
        return1,
        return2,
        hold_flag,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        sent_to_ucas,
        test_cond_cat,
        test_cond_name,
        inst_reference ,
        auto_generated_flag,
        system_code,
        ucas_cycle,
        modular,
        part_time
      FROM IGS_UC_TRANSACTIONS
      WHERE system_code = p_system_code
        AND ucas_cycle = p_configured_cycle
        AND sent_to_ucas = 'N'
        AND hold_flag = 'N'
        AND transaction_type NOT IN ('XA','XD')
      ORDER BY transaction_type;
    cur_transactions_rec cur_transactions%ROWTYPE;

    CURSOR cur_get_mon(p_mon NUMBER) IS
      SELECT TO_CHAR(TO_DATE(p_mon,'MM'),'MON') entry_month
      FROM DUAL;
    l_cur_get_mon cur_get_mon%ROWTYPE;

    -- Fetching Course Vacancy Records to be exported
    CURSOR cur_uv_crs_vac(cp_system_code igs_uc_crse_dets.system_code%TYPE) IS
      SELECT
        crse.ROWID,
        REPLACE(crse.ucas_program_code,'*',' ') course,
        REPLACE(crse.ucas_campus, '*', ' ') campus,
        crse.vacancy_status,
        crse.no_of_vacancy,
        crse.score,
        crse.rb_full,
        crse.scot_vac
      FROM igs_uc_crse_dets crse
      WHERE crse.system_code = cp_system_code AND
            crse.institute = p_current_inst_code AND
            crse.sent_to_ucas = 'N' AND
            NVL(crse.imported,'Y') = 'Y'
      ORDER BY crse.ucas_program_code , crse.ucas_campus;
    l_cur_uv_crs_vac cur_uv_crs_vac%ROWTYPE;

    -- Fetching Course Vacancy Record for Update
    CURSOR upd_crs_vac_cur (cp_rowid VARCHAR2) IS
      SELECT
        crse.ROWID,
        crse.*
      FROM igs_uc_crse_dets crse
      WHERE crse.ROWID = cp_rowid;

    -- Fetching Course Vacancy Option Records to be exported
    CURSOR cur_uv_crs_vac_opt(cp_system_code igs_uc_crse_dets.system_code%TYPE,
                              cp_course IGS_UC_MV_UVCRS_VOP.course%TYPE,
                              cp_campus IGS_UC_MV_UVCRS_VOP.campus%TYPE) IS
    SELECT
      crsevac.ROWID,
      REPLACE(crsevac.ucas_program_code, '*', ' ') course,
      REPLACE(crsevac.ucas_campus, '*', ' ') campus,
      REPLACE(crsevac.option_code, '*', ' ') option_code
    FROM igs_uc_crse_vac_ops crsevac
    WHERE crsevac.system_code = cp_system_code AND
          REPLACE(crsevac.ucas_program_code,'*',' ') = cp_course AND
          REPLACE(crsevac.ucas_campus, '*', ' ') = cp_campus AND
          crsevac.institute = p_current_inst_code AND
          crsevac.sent_to_ucas = 'N'
    ORDER BY crsevac.ucas_program_code , crsevac.ucas_campus , crsevac.option_code;
    l_cur_uv_crs_vac_opt cur_uv_crs_vac_opt%ROWTYPE;

    -- Fetching Course Vacancy Option Record for Update
    CURSOR upd_crs_vac_opt_cur (cp_rowid VARCHAR2) IS
    SELECT
      crsevac.ROWID,
      crsevac.*
    FROM igs_uc_crse_vac_ops crsevac
    WHERE crsevac.ROWID = cp_rowid;

    -- Fetching Offer Abbreviations records to deleted and to be exported
    CURSOR cur_uv_offr_abb IS
      SELECT
        roa.ROWID,
        REPLACE(roa.abbrev_code,'*', ' ') abbrev_code,
        roa.abbrev_text ,
        REPLACE(roa.letter_format, '*', ' ') letter_format,
        REPLACE(roa.summary_char, '*', ' ') summary_char,
        roa.deleted
      FROM igs_uc_ref_off_abrv roa
      WHERE roa.sent_to_ucas = 'N' AND roa.deleted = 'N';
    l_cur_uv_offr_abb cur_uv_offr_abb%ROWTYPE;

    -- Fetching Offer Abbreviations record for Update
    CURSOR upd_offr_abb_cur(cp_rowid VARCHAR2) IS
      SELECT
        roa.ROWID,
        roa.*
      FROM igs_uc_ref_off_abrv roa
    WHERE roa.ROWID = cp_rowid;

    l_record    VARCHAR2(1000);
    l_from      NUMBER(3);
    l_cont_flag NUMBER(2);
    l_data_set  VARCHAR2(1000);
    l_data      VARCHAR2(1000);
    l_data_per_line NUMBER(3);
    l_len           NUMBER(3);
    l_len_cd        NUMBER(3);
    l_ext_info_first_line NUMBER(3);
    l_info VARCHAR2(500);
    l_tran_form NUMBER(1);
    l_opt_code VARCHAR2(250);
    l_tran_type IGS_UC_TRANSACTIONS.transaction_type%TYPE;
    l_digital_num NUMBER(2);
    l_choice_no VARCHAR2(1);

  BEGIN

    l_sequence_number := 00001;
    l_total_trans := 0;

    OPEN cur_transactions(p_sys_ind);
    LOOP

      FETCH cur_transactions INTO cur_transactions_rec;
      EXIT WHEN cur_transactions%NOTFOUND;

      -- To get the Check-Digital number
      l_digital_num :=  NVL(igs_uc_mv_data_upld.get_check_digit(cur_transactions_rec.app_no),-1);

      -- While generating the Flat file, the Choice Number column has only one character assigned,
      -- For the systems like GTTR, the choice number can be greater  than 9
      -- So, the choice number should be as A,if it is 10 B for 11, C for 12 like that
      IF NVL(cur_transactions_rec.choice_no,0) > 9 THEN

        l_choice_no := fnd_global.local_chr( ASCII('A') + (cur_transactions_rec.choice_no - 10) ) ;

      ELSE
        l_choice_no :=  LPAD(NVL(cur_transactions_rec.choice_no,0),1,0) ;

      END IF;

      --
      -- Find the Transaction Type and then form the Data Layout
      --

      -- Process LA and LD transactions
      IF cur_transactions_rec.transaction_type IN ('LA','LD') THEN

        l_data_per_line := 67;       -- The actual data per line
        l_ext_info_first_line := 11;
        l_info := NULL;
        l_from := 1;

        -- Prepare the Free Format Area section in l_info varaible

        -- For the course element
        --
        IF cur_transactions_rec.program_code IS NOT NULL AND cur_transactions_rec.program_code <> '*' THEN
          l_info := '*'||cur_transactions_rec.program_code;
        END IF;
        IF cur_transactions_rec.campus IS NOT NULL AND cur_transactions_rec.campus <> '*' AND l_info IS NOT NULL THEN
          l_info := l_info||';'||cur_transactions_rec.campus;
        END IF;

        -- For the Entry Year/Month element
        --
        IF cur_transactions_rec.entry_year IS NOT NULL THEN
          IF l_info IS NOT NULL THEN
            l_info := l_info||',:'||LPAD(cur_transactions_rec.entry_year,2,0);
          ELSE
            l_info := ':'||LPAD(cur_transactions_rec.entry_year,2,0);
          END IF;
        END IF;

        IF cur_transactions_rec.entry_month IS NOT NULL THEN
          OPEN cur_get_mon(cur_transactions_rec.entry_month);
          FETCH cur_get_mon INTO l_cur_get_mon;
          IF l_info IS NOT NULL THEN
            IF cur_transactions_rec.entry_year IS NOT NULL THEN
              l_info := l_info||l_cur_get_mon.entry_month;
            ELSE
              l_info := l_info||',:'||l_cur_get_mon.entry_month;
            END IF;
          ELSE
            l_info := ':'||l_cur_get_mon.entry_month;
          END IF;
          CLOSE cur_get_mon;
        END IF;

        -- For the Point of entry element
        --
        IF cur_transactions_rec.entry_point IS NOT NULL THEN
          IF l_info IS NOT NULL THEN
            l_info := l_info||',!'||cur_transactions_rec.entry_point;
          ELSE
            l_info := '!'||cur_transactions_rec.entry_point;
          END IF;
        END IF;

        -- For Summary of Conditions element
        --
        IF cur_transactions_rec.soc IS NOT NULL THEN
          IF l_info IS NOT NULL THEN
            l_info := l_info||',+'||cur_transactions_rec.soc ;
          ELSE
            l_info := '+'||cur_transactions_rec.soc ;
          END IF;
        END IF;

        -- For Comment element ( Comments in Offer column )
        --
        IF cur_transactions_rec.comments_in_offer IS NOT NULL THEN
          IF l_info IS NOT NULL THEN
            l_info := l_info||','||cur_transactions_rec.comments_in_offer ;
          ELSE
            l_info := cur_transactions_rec.comments_in_offer ;
          END IF ;
        END IF ;
        --
        -- End of Free format data creation

        l_data_set := LPAD(cur_transactions_rec.app_no,8,0)||l_digital_num||l_choice_no||
                      NVL(cur_transactions_rec.decision,' ')||l_info ;

        --
        --  To find the length of the transaction
        --
        l_len  :=  NVL(length(l_info),0) + l_ext_info_first_line;
        l_len_cd := NVL(CEIL(l_len/l_data_per_line),0);
        l_cont_flag := 1;

        --
        -- Check the length of the section
        --
        check_sec_len(l_len_cd, p_sys_ind);

        FOR I IN 1..l_len_cd LOOP

          l_data := SUBSTR(l_data_set,l_from,l_data_per_line);
          l_sequence_number := l_sequence_number + 1;

          IF l_cont_flag = 1 THEN

            IF l_cont_flag = l_len_cd THEN
              l_cont_flag := 9;
            END IF;

            l_record :=
              LPAD((l_sequence_number),5,0)||
              l_cont_flag||                            -- Continutuion Flag
              cur_transactions_rec.transaction_type||  -- Transaction Type
              ' '||                                    -- Transaction Form
              l_len_cd||                               -- Length of the Transaction
              '   '||                                  -- Error Code
              l_data;

          ELSE

            IF l_cont_flag = l_len_cd THEN
              l_cont_flag := 9;
            END IF;
            l_record := LPAD(l_sequence_number,5,0)||
              l_cont_flag||                              -- Continutuion Flag
              '  '||                                     -- Transaction Type
              ' '||                                      -- Transaction Form
              ' '||                                      -- Length of the Transaction
              '   '||                                    -- Error Code
              l_data;

          END IF;

          l_from := l_from + l_data_per_line;
          l_cont_flag := l_cont_flag + 1;
          put_line(l_record);

         END LOOP;
         l_total_trans := l_total_trans + 1;

      ELSIF cur_transactions_rec.transaction_type IN ('LC','RA','RD','RE','RQ','RX') THEN

          l_cont_flag := 9;
          l_len_cd := 1;
          l_info := NULL;
          --
          -- For the course element.
          --
          IF cur_transactions_rec.program_code IS NOT NULL AND cur_transactions_rec.program_code <> '*' THEN
            l_info := '*'||cur_transactions_rec.program_code;
          END IF;
          IF cur_transactions_rec.campus IS NOT NULL AND cur_transactions_rec.campus <> '*' AND
            l_info IS NOT NULL THEN
            l_info := l_info||';'||cur_transactions_rec.campus;
          END IF;

          --
          -- For the Point of entry element.
          -- The Point of entry element is not required for the transaction type 'RE'

          IF cur_transactions_rec.transaction_type NOT IN ('RE','RQ') THEN
            IF cur_transactions_rec.entry_point IS NOT NULL THEN
              IF l_info IS NOT NULL THEN
                l_info := l_info||',!'||cur_transactions_rec.entry_point;
              ELSE
                l_info := '!'||cur_transactions_rec.entry_point;
              END IF;
            END IF;
          END IF;

          --
          -- For the Year/Month element.
          -- For 'RE' and 'RQ' transactions the 'Entry Month' is not required.
          --
          IF cur_transactions_rec.entry_year IS NOT NULL THEN
            IF l_info IS NOT NULL THEN
              l_info := l_info||',:'||LPAD(cur_transactions_rec.entry_year,2,0);
            ELSE
              l_info := ':'||LPAD(cur_transactions_rec.entry_year,2,0);
            END IF;
          END IF;

          IF cur_transactions_rec.transaction_type NOT IN ('RE','RQ') THEN
            IF cur_transactions_rec.entry_month IS NOT NULL THEN
              OPEN cur_get_mon(cur_transactions_rec.entry_month);
              FETCH cur_get_mon INTO l_cur_get_mon;
              IF l_info IS NOT NULL THEN
                IF cur_transactions_rec.entry_year IS NOT NULL THEN
                  l_info := l_info||l_cur_get_mon.entry_month;
                ELSE
                  l_info := l_info||',:'||l_cur_get_mon.entry_month;
                END IF;
              ELSE
                l_info := ':'||l_cur_get_mon.entry_month;
              END IF;
              CLOSE cur_get_mon;
            END IF;
          END IF;

          IF cur_transactions_rec.transaction_type = 'LC' THEN
            l_data := LPAD(cur_transactions_rec.app_no,8,0)||l_digital_num||l_choice_no||l_info;
          ELSIF cur_transactions_rec.transaction_type IN ('RA','RE','RQ') THEN
            l_data := LPAD(cur_transactions_rec.app_no,8,0)||l_digital_num||l_info;
          ELSIF cur_transactions_rec.transaction_type IN ('RD','RX') THEN
            l_data := LPAD(cur_transactions_rec.app_no,8,0)||l_digital_num||l_choice_no||
                NVL(cur_transactions_rec.decision,' ')||l_info;
          END IF;

          -- Check the length of the section.
          check_sec_len(l_len_cd,p_sys_ind);

          l_sequence_number := l_sequence_number + 1;
          l_record := LPAD((l_sequence_number),5,0)||
                l_cont_flag||                              -- Continutuion Flag --
                cur_transactions_rec.transaction_type||    -- Transaction Type --
                ' '||                                      -- Transaction Form --
                l_len_cd||                                 -- Length of the Transaction
                '   '||                                    -- Error Code --
                l_data;
          put_line(l_record);
          l_total_trans := l_total_trans + 1;

      ELSIF cur_transactions_rec.transaction_type IN ('LK','RK') THEN

          l_cont_flag := 9;
          l_len_cd := 1;
          l_data := LPAD(cur_transactions_rec.app_no,8,0)||l_digital_num||l_choice_no;

          -- Check the length of the section.
          check_sec_len(l_len_cd, p_sys_ind);

          l_sequence_number := l_sequence_number + 1;
          l_record := LPAD((l_sequence_number),5,0)||
                l_cont_flag||                             -- Continutuion Flag --
                cur_transactions_rec.transaction_type||   -- Transaction Type --
                ' '||                                     -- Transaction Form --
                l_len_cd||                                -- Length of the Transaction
                '   '||                                   -- Error Code --
                l_data;
                put_line(l_record);
          l_total_trans := l_total_trans + 1;

      ELSIF cur_transactions_rec.transaction_type = 'LE' THEN

          l_cont_flag := 9;
          l_len_cd := 1 ;
          l_data := NULL ;
          l_info := NULL ;

          -- Appending the Application Number and Check Digit
          l_data := LPAD(cur_transactions_rec.app_no,8,0)||l_digital_num ;

          -- Appending the Extra Passport Number and Copy form Required columns
          -- These columns are stored in the 'Comments_in_offer' column in the first 7 characters
          l_data := l_data || RPAD(NVL(SUBSTR(cur_transactions_rec.comments_in_offer,1,7),' '),7,' ') ;

          -- Appending the course and campus elements
          IF cur_transactions_rec.program_code IS NOT NULL AND cur_transactions_rec.program_code <> '*' THEN
            l_info := '*'||cur_transactions_rec.program_code ;
          END IF ;

          IF cur_transactions_rec.campus IS NOT NULL AND cur_transactions_rec.campus <> '*' AND l_info IS NOT NULL THEN
            l_info := l_info||';'||cur_transactions_rec.campus;
          END IF;
          l_data := l_data || l_info ;

          -- Check the length of the section.
          check_sec_len(l_len_cd, p_sys_ind) ;

          l_sequence_number := l_sequence_number + 1 ;

          -- Create the Transaction record
          l_record :=
                LPAD((l_sequence_number),5,0)||          -- Sequence Number
                l_cont_flag||                            -- Continutuion Flag
                cur_transactions_rec.transaction_type||  -- Transaction Type
                ' '||                                    -- Transaction Form
                l_len_cd||                               -- Length of the Transaction
                '   '||                                  -- Error Code
                l_data ;                                  -- Trasaction Data

          -- Write the trasaction record,l_record into Flat file
          put_line(l_record) ;

          -- Increment the number of trasactions records by one
          l_total_trans := l_total_trans + 1 ;

      ELSIF cur_transactions_rec.transaction_type IN ('PE','RR','RW') THEN

          l_cont_flag := 9;
          l_len_cd := 1;

          IF cur_transactions_rec.transaction_type IN ('PE','RW') THEN
            l_data := LPAD(cur_transactions_rec.app_no,8,0)||l_digital_num;
          ELSIF cur_transactions_rec.transaction_type = 'RR' THEN
            l_data := LPAD(cur_transactions_rec.app_no,8,0)||l_digital_num||
                      RPAD(NVL(SUBSTR(cur_transactions_rec.comments_in_offer,1,3),' '),3,' ')
                      ||SUBSTR(cur_transactions_rec.comments_in_offer,4,46);
          END IF;

          -- Check the length of the section.
          check_sec_len(l_len_cd, p_sys_ind);

          l_sequence_number := l_sequence_number + 1;
          l_record := LPAD(l_sequence_number,5,0)||
                l_cont_flag||                            -- Continutuion Flag
                cur_transactions_rec.transaction_type||  -- Transaction Type
                ' '||                                    -- Transaction Form
                l_len_cd||                               -- Length of the Transaction
                '   '||                                  -- Error Code
                l_data;
          put_line(l_record);
          l_total_trans := l_total_trans + 1;

      END IF; -- MAIN IF

      -- Update the sent_to_ucas column of the current Transaction record to 'Y' as the trnsactions has
      -- send to UCAS through flat file

      igs_uc_transactions_pkg.update_row (
        x_mode                              => 'R',
        x_rowid                             => cur_transactions_rec.ROWID,
        x_uc_tran_id                        => cur_transactions_rec.UC_Tran_Id,
        x_transaction_id                    => cur_transactions_rec.transaction_id,
        x_datetimestamp                     => cur_transactions_rec.datetimestamp,
        x_updater                           => cur_transactions_rec.updater,
        x_error_code                        => cur_transactions_rec.error_code,
        x_transaction_type                  => cur_transactions_rec.transaction_type,
        x_app_no                            => cur_transactions_rec.app_no,
        x_choice_no                         => cur_transactions_rec.choice_no,
        x_decision                          => cur_transactions_rec.decision,
        x_program_code                      => cur_transactions_rec.program_code,
        x_campus                            => cur_transactions_rec.campus,
        x_entry_month                       => cur_transactions_rec.entry_month,
        x_entry_year                        => cur_transactions_rec.entry_year,
        x_entry_point                       => cur_transactions_rec.entry_point,
        x_soc                               => cur_transactions_rec.SOC,
        x_comments_in_offer                 => cur_transactions_rec.comments_in_offer,
        x_return1                           => cur_transactions_rec.return1,
        x_return2                           => cur_transactions_rec.return2,
        x_hold_flag                         => cur_transactions_rec.hold_flag,
        x_sent_to_ucas                      => 'Y',
        x_test_cond_cat                     => cur_transactions_rec.test_cond_cat,
        x_test_cond_name                    => cur_transactions_rec.test_cond_name,
        x_inst_reference                    => cur_transactions_rec.inst_reference ,
        x_auto_generated_flag               => cur_transactions_rec.auto_generated_flag,
        x_system_code                       => cur_transactions_rec.system_code,
        x_ucas_cycle                        => cur_transactions_rec.ucas_cycle,
        x_modular                           => cur_transactions_rec.modular,
        x_part_time                         => cur_transactions_rec.part_time);

    END LOOP;

    CLOSE cur_transactions;

    --
    --  Export 'QC' and 'QF' transactions only for FTUG and SWAS Systems
    --
    IF p_sys_ind IN ('U','S') AND p_configured_cycle = p_current_cycle THEN

      OPEN cur_uv_crs_vac(p_sys_ind);
      LOOP
        FETCH cur_uv_crs_vac INTO l_cur_uv_crs_vac;
        EXIT WHEN cur_uv_crs_vac%NOTFOUND;

        --
        -- Processing for the 'QF' Transaction.
        --
        l_cont_flag := 9;
        l_tran_type := 'QF';
        l_tran_form := 1;
        l_from := 1;
        l_len_cd := 1;
        l_data := RPAD(l_cur_uv_crs_vac.course,6,' ')||l_cur_uv_crs_vac.campus||RPAD(NVL(l_cur_uv_crs_vac.vacancy_status,' '),1,' ');
        -- Check the length of the section.
        check_sec_len(l_len_cd, p_sys_ind);

        l_sequence_number := l_sequence_number + 1;
        l_record := LPAD((l_sequence_number),5,0)||
                l_cont_flag||                           -- Continutuion Flag
                l_tran_type||                           -- Transaction Type
                l_tran_form||                           -- Transaction Form
                l_len_cd||                              -- Length of the Transaction
                '   '||                                 -- Error Code
                l_data;
        put_line(l_record);
        l_total_trans := l_total_trans + 1;

        --
        -- Processing for the 'QC' Transaction.
        --
        l_opt_code := NULL;
        l_data := RPAD(l_cur_uv_crs_vac.course,6,' ')||l_cur_uv_crs_vac.campus||
            RPAD(NVL(l_cur_uv_crs_vac.vacancy_status,' '),1,' ')||RPAD(NVL(l_cur_uv_crs_vac.no_of_vacancy,' '),2,' ')||
            LPAD(NVL(l_cur_uv_crs_vac.score,0),2,0);
        --
        --  To get the option code for the 'QC' transaction.
        --
        OPEN cur_uv_crs_vac_opt(p_sys_ind, l_cur_uv_crs_vac.course, l_cur_uv_crs_vac.campus);
        LOOP
          FETCH cur_uv_crs_vac_opt INTO l_cur_uv_crs_vac_opt;
          EXIT WHEN cur_uv_crs_vac_opt%NOTFOUND;
          IF NVL(length(l_opt_code),0) <= 198 THEN
            l_opt_code := l_opt_code||RPAD(l_cur_uv_crs_vac_opt.option_code,2,' ');
          END IF;

          -- Updating the Course Vacancy Option Record with sent_to_ucas as 'Y'
          FOR upd_crs_vac_opt_rec IN upd_crs_vac_opt_cur(l_cur_uv_crs_vac_opt.rowid) LOOP

            igs_uc_crse_vac_ops_pkg.update_row (
              x_mode                    => 'R',
              x_rowid                   => upd_crs_vac_opt_rec.rowid,
              x_ucas_program_code       => upd_crs_vac_opt_rec.ucas_program_code,
              x_institute               => upd_crs_vac_opt_rec.institute,
              x_ucas_campus             => upd_crs_vac_opt_rec.ucas_campus,
              x_option_code             => upd_crs_vac_opt_rec.option_code,
              x_updater                 => upd_crs_vac_opt_rec.updater,
              x_cl_updated              => upd_crs_vac_opt_rec.cl_updated,
              x_cl_date                 => upd_crs_vac_opt_rec.cl_date,
              x_vacancy_status          => upd_crs_vac_opt_rec.vacancy_status,
              x_sent_to_ucas            => 'Y' ,
              x_system_code             => upd_crs_vac_opt_rec.system_code );

          END LOOP;

        END LOOP;

        CLOSE cur_uv_crs_vac_opt;

        l_tran_type := 'QC';
        l_tran_form := 3;
        l_from := 1;
        l_data_set := l_data||l_opt_code;
        l_data_per_line := 67;
        l_len  := LENGTH(l_data_set);
        l_len_cd := NVL(CEIL(l_len/l_data_per_line),0);
        l_cont_flag := 1;
        -- Check the length of the section.
        check_sec_len(l_len_cd, p_sys_ind);

        FOR I IN 1..l_len_cd LOOP
          l_data := SUBSTR(l_data_set,l_from,l_data_per_line);
          l_sequence_number := l_sequence_number + 1;
          IF l_cont_flag = 1 THEN
            IF l_cont_flag = l_len_cd THEN
              l_cont_flag := 9;
            END IF;
            l_record := LPAD((l_sequence_number),5,0)||
              l_cont_flag||                               -- Continutuion Flag --
              l_tran_type||                               -- Transaction Type --
              l_tran_form||                               -- Transaction Form --
              l_len_cd||                                  -- Length of the Transaction --
              '   '||                                     -- Error Code --
              l_data;
          ELSE
            IF l_cont_flag = l_len_cd THEN
              l_cont_flag := 9;
            END IF;
            l_record := LPAD((l_sequence_number),5,0)||
               l_cont_flag||                             -- Continutuion Flag --
               '  '||                                    -- Transaction Type --
               ' '||                                     -- Transaction Form --
               ' '||                                     -- Length of the Transaction --
               '   '||                                   -- Error Code --
               l_data;
          END IF;
          l_from := l_from + l_data_per_line;
          l_cont_flag := l_cont_flag + 1;
          put_line(l_record);
        END LOOP;
        l_total_trans := l_total_trans + 1;

        -- Updating the Course Vacancy Record with sent_to_ucas as 'Y'
        FOR upd_crs_vac_rec IN upd_crs_vac_cur(l_cur_uv_crs_vac.ROWID) LOOP

          igs_uc_crse_dets_pkg.update_row (
            x_mode                              => 'R',
            x_rowid                             => upd_crs_vac_rec.rowid,
            x_ucas_program_code                 => upd_crs_vac_rec.ucas_program_code,
            x_oss_program_code                  => upd_crs_vac_rec.oss_program_code,
            x_oss_program_version               => upd_crs_vac_rec.oss_program_version,
            x_institute                         => upd_crs_vac_rec.institute,
            x_uvcourse_updater                  => upd_crs_vac_rec.uvcourse_updater,
            x_uvcrsevac_updater                 => upd_crs_vac_rec.uvcrsevac_updater,
            x_short_title                       => upd_crs_vac_rec.short_title,
            x_long_title                        => upd_crs_vac_rec.long_title,
            x_ucas_campus                       => upd_crs_vac_rec.ucas_campus,
            x_oss_location                      => upd_crs_vac_rec.oss_location,
            x_faculty                           => upd_crs_vac_rec.faculty,
            x_total_no_of_seats                 => upd_crs_vac_rec.total_no_of_seats,
            x_min_entry_points                  => upd_crs_vac_rec.min_entry_points,
            x_max_entry_points                  => upd_crs_vac_rec.max_entry_points,
            x_current_validity                  => upd_crs_vac_rec.current_validity,
            x_deferred_validity                 => upd_crs_vac_rec.deferred_validity,
            x_term_1_start                      => upd_crs_vac_rec.term_1_start,
            x_term_1_end                        => upd_crs_vac_rec.term_1_end,
            x_term_2_start                      => upd_crs_vac_rec.term_2_start,
            x_term_2_end                        => upd_crs_vac_rec.term_2_end,
            x_term_3_start                      => upd_crs_vac_rec.term_3_start,
            x_term_3_end                        => upd_crs_vac_rec.term_3_end,
            x_term_4_start                      => upd_crs_vac_rec.term_4_start,
            x_term_4_end                        => upd_crs_vac_rec.term_4_end,
            x_cl_updated                        => upd_crs_vac_rec.cl_updated,
            x_cl_date                           => upd_crs_vac_rec.cl_date,
            x_vacancy_status                    => upd_crs_vac_rec.vacancy_status,
            x_no_of_vacancy                     => upd_crs_vac_rec.no_of_vacancy,
            x_score                             => upd_crs_vac_rec.score,
            x_rb_full                           => upd_crs_vac_rec.rb_full,
            x_scot_vac                          => upd_crs_vac_rec.scot_vac,
            x_sent_to_ucas                      => 'Y',
            x_ucas_system_id                    => upd_crs_vac_rec.ucas_system_id,
            x_oss_attendance_type               => upd_crs_vac_rec.oss_attendance_type,
            x_oss_attendance_mode               => upd_crs_vac_rec.oss_attendance_mode,
            x_joint_admission_ind               => upd_crs_vac_rec.joint_admission_ind,
            x_open_extra_ind                    => upd_crs_vac_rec.open_extra_ind,
            x_clearing_options                  => upd_crs_vac_rec.clearing_options,
            x_imported                          => NVL(upd_crs_vac_rec.imported,'Y'),
            x_system_code                       => upd_crs_vac_rec.system_code ,
            x_keywrds_changed                   => upd_crs_vac_rec.keywrds_changed);

        END LOOP;

      END LOOP;
      CLOSE cur_uv_crs_vac;

    END IF; -- End of QC and QF Transactions

    --
    --  Export 'QA' transactions only for FTUG System
    --
    IF p_sys_ind IN ('U') AND p_configured_cycle = p_current_cycle THEN

      OPEN cur_uv_offr_abb;
      LOOP
        FETCH cur_uv_offr_abb INTO l_cur_uv_offr_abb;
        EXIT WHEN cur_uv_offr_abb%NOTFOUND;

        -- Write the Transaction in flat file and update the table with sent_to_ucas as 'Y'
        l_cont_flag := 9;
        l_tran_type := 'QA';
        l_tran_form := 2;
        l_len_cd := 1;
        l_data := LPAD(l_cur_uv_offr_abb.abbrev_code,2,0)||l_cur_uv_offr_abb.letter_format||
                  l_cur_uv_offr_abb.summary_char||RPAD(NVL(l_cur_uv_offr_abb.abbrev_text,' '),57,' ');
        -- Check the length of the section.
        check_sec_len(l_len_cd, p_sys_ind);

        l_sequence_number := l_sequence_number + 1;
        l_record := LPAD((l_sequence_number),5,0)||
          l_cont_flag||                             -- Continutuion Flag --
          l_tran_type||                             -- Transaction Type --
          l_tran_form||                             -- Transaction Form --
          l_len_cd||                                -- Length of the Transaction --
          '   '||                                   -- Error Code --
          l_data;
        put_line(l_record);
        l_total_trans := l_total_trans + 1;

        -- Update the Offer Abbreviations Record
        FOR upd_offr_abb_rec IN upd_offr_abb_cur(l_cur_uv_offr_abb.ROWID) LOOP

          igs_uc_ref_off_abrv_pkg.update_row (
            x_mode                  => 'R',
            x_rowid                 => upd_offr_abb_rec.rowid,
            x_abbrev_code           => upd_offr_abb_rec.abbrev_code,
            x_uv_updater            => upd_offr_abb_rec.uv_updater,
            x_abbrev_text           => upd_offr_abb_rec.abbrev_text,
            x_letter_format         => upd_offr_abb_rec.letter_format,
            x_summary_char          => upd_offr_abb_rec.summary_char,
            x_uncond                => upd_offr_abb_rec.uncond,
            x_withdrawal            => upd_offr_abb_rec.withdrawal,
            x_release               => upd_offr_abb_rec.release,
            x_imported              => upd_offr_abb_rec.imported,
            x_sent_to_ucas          => 'Y',
            x_deleted               => upd_offr_abb_rec.deleted,
            x_tariff                => upd_offr_abb_rec.tariff );

        END LOOP;

      END LOOP;
      CLOSE cur_uv_offr_abb;

    END IF; -- End of QA Transaction

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_UC_EXT_MARVIN.PREPARE_DATA'||' - '||SQLERRM);
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;

  END prepare_data;


  FUNCTION pending_transactions_exist (p_system_code IN VARCHAR2, p_configured_cycle IN NUMBER,
                                       p_current_cycle IN NUMBER, p_current_inst_code IN VARCHAR2)
  RETURN BOOLEAN IS
  /*
  ||  Created By : ayedubat
  ||  Created On : 03-JUL-2003
  ||  Purpose : To check whether any pending transactions exist for any/particular system
  ||            depending on the value passed to p_system_code parameter.
  ||            Created as part of Multiple Cycles Enhancement, 2669208
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  WHO             WHEN            WHAT
  ||  dsridhar        30-SEP-2003     Bug No: 3156212. Code modified to consider only those transactions
  ||                                  for systems configured as MARVIN. Cursor cur_pending_trans_exist
  ||                                  changed to consider only MARVIN interface.
  ||  jchakrab        07-Sep-2004     Modified for Bug#3872286 - simplified logic for checking for pending
  ||                                  transactions for a system
  ||
  */
  -- Cursor to find whether pending transactions exist to send to UCAS
  CURSOR cur_pending_trans_exist(cp_system_code IGS_UC_TRANSACTIONS.system_code%TYPE,
                                 cp_config_cycle IGS_UC_TRANSACTIONS.ucas_cycle%TYPE)IS
    SELECT 'X'
    FROM IGS_UC_TRANSACTIONS
    WHERE
      system_code = NVL(cp_system_code,system_code) AND
      NVL(cp_system_code,system_code) IN (SELECT system_code
                                          FROM igs_uc_cyc_defaults
                                          WHERE ucas_interface = 'M' AND
                                                ucas_cycle = cp_config_cycle) AND
      ucas_cycle = cp_config_cycle AND
      sent_to_ucas = 'N' AND
      hold_flag = 'N' AND
      transaction_type NOT IN ('XA','XD');

  -- Cursor to find whether any couse vacancy transactiions exist to send to UCAS
  CURSOR cur_uv_crs_vac_exist(cp_system_code IGS_UC_CRSE_DETS.system_code%TYPE,
                              cp_current_inst IGS_UC_CRSE_DETS.institute%TYPE)IS
    SELECT 'X'
    FROM igs_uc_crse_dets crse
    WHERE
      ((cp_system_code IS NOT NULL AND system_code = cp_system_code) OR
       (cp_system_code IS NULL AND system_code IN ('U','S'))) AND
      crse.institute =  cp_current_inst AND
      crse.sent_to_ucas = 'N' AND
      NVL(crse.imported,'Y') = 'Y' ;

  -- Cursor to find whether any offer abbreviations exist to send to UCAS
  CURSOR cur_uv_offr_abb_exist IS
    SELECT 'X'
    FROM igs_uc_ref_off_abrv roa
    WHERE roa.sent_to_ucas = 'N' AND roa.deleted = 'N';

  l_dummy VARCHAR2(1);
  l_status BOOLEAN := FALSE;

  BEGIN

      -- Check whether any Pending Transactions for the Configured Cycle exist
      -- i.e. any record with Sent_To_UCAS ='N' and hold_flag ='N'
      OPEN cur_pending_trans_exist(p_system_code, p_configured_cycle) ;
      FETCH cur_pending_trans_exist INTO l_dummy ;

      -- Check whether any Course Vacancies exist for FTUG and SWAS Systems to send to UCAS
      OPEN cur_uv_crs_vac_exist(p_system_code, p_current_inst_code);
      FETCH cur_uv_crs_vac_exist INTO l_dummy ;

      -- Check whether any Offer Abbreviations exist to send to UCAS
      OPEN cur_uv_offr_abb_exist ;
      FETCH cur_uv_offr_abb_exist INTO l_dummy ;

      -- Modified this for Bug#3872286 - simplified logic
      IF p_system_code = 'U' THEN
        IF ((cur_uv_crs_vac_exist%FOUND OR cur_uv_offr_abb_exist%FOUND) AND p_configured_cycle = p_current_cycle)
		  OR cur_pending_trans_exist%FOUND THEN
          l_status := TRUE;
        END IF;

      ELSIF p_system_code = 'S' THEN
        IF (cur_uv_crs_vac_exist%FOUND AND p_configured_cycle = p_current_cycle)
		   OR (cur_pending_trans_exist%FOUND) THEN
          l_status := TRUE;
        END IF;

      ELSIF p_system_code IN ('G','N') THEN
        IF cur_pending_trans_exist%FOUND THEN
          l_status := TRUE;
        END IF;

      END IF ;

      CLOSE cur_pending_trans_exist ;
      CLOSE cur_uv_crs_vac_exist ;
      CLOSE cur_uv_offr_abb_exist ;

      RETURN l_status;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_UC_EXT_MARVIN.PENDING_TRANSACTIONS_EXIST'||' - '||SQLERRM);
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;

  END pending_transactions_exist;


  /***********   Main Procedure called from the Concurrent Manager ****************/

  PROCEDURE create_file(errbuf   OUT NOCOPY  VARCHAR2,
                        retcode  OUT NOCOPY  NUMBER ) IS
  /*
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 09-APR-2002
  ||  Purpose : This is the main procedure, which will get called from the
  ||            concurrent manager in order to create the flat file.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who       When         What
  ||  ayedubat  15-NOV-2002  Added the Logic to loop through all the systems
  ||                         supported by the Institution if any pending transactions
  ||                         exist to send to UCAS for the bug # 2643048
  ||  ayedubat  24-DEC-2002  Removed the p_directory parameter from the procedure and
  ||                         created a new local procedure, create_directory for finding
  ||                         the directory name to write the flat file for bug, 2711256
  ||  ayedubat  02-JUL-2003  Changed as part of Multiple Cycles Enhancement, 2669208
  ||                         Created a new procedure,pending_transactions_exist to check
  ||                         whether any pending transactions exist or not.
  ||  ayedubat  14-JUL-2003  Changed the procedure to make the reserved words ltrim,substr
  ||                         to upper case for the same bug,2669208
  ||  ayedubat  16-JUL-2003  Removed the validation to check whether the configured cycle
  ||                         in our System is equal to the entryyear in the UCAS for bug,2669208
  ||  dsridhar  30-SEP-2003  Bug No: 3156212. Code modified to consider only those transactions
  ||                         for systems configured as MARVIN. Cursor marvin_setup_cur removed.
  ||                         Cursor ucas_systems_cur changed to consider only MARVIN interface.
  ||  jchakrab  07-Sep-2004  Modified for Bug#3872286 - simplified logic for checking for pending
  ||                         transactions for a system and generating the marvin file
  ||  anwest    18-JAN-2006  Bug# 4950285 R12 Disable OSS Mandate
  ||  (reverse chronological order - newest change first)
  */

  -- Find the UCAS System Configured Cycle
  CURSOR ucas_cycles_cur IS
    SELECT MAX(configured_cycle) configured_cycle,
           MAX(current_cycle) current_cycle
    FROM IGS_UC_DEFAULTS ;
  ucas_cycles_rec ucas_cycles_cur%ROWTYPE;

  -- Find the Current Institute Code and Security Key
  CURSOR cur_inst_code  IS
    SELECT DISTINCT current_inst_code, ucas_security_key
    FROM IGS_UC_DEFAULTS ;

  -- Bug No: 3156212. Cursor changed to consider only MARVIN interface.
  -- Fetch all the UCAS Systems setup in the System
  CURSOR ucas_systems_cur (cp_ucas_cycle igs_uc_cyc_defaults.ucas_cycle%TYPE) IS
    SELECT DISTINCT ucd.system_code system_code,
           DECODE(ucd.system_code,'U',1,'G',2,'N',3,'S',4,5)
    FROM IGS_UC_DEFAULTS ucd, IGS_UC_CYC_DEFAULTS uccd
    WHERE ucd.system_code = uccd.system_code AND
          uccd.ucas_cycle = cp_ucas_cycle AND
          uccd.ucas_interface = 'M'
    ORDER BY 2;


  l_inst_code igs_uc_defaults.current_inst_code%TYPE;
  l_sec_key   igs_uc_defaults.ucas_security_key%TYPE;
  l_directory VARCHAR2(240) ;
  l_dummy ucas_systems_cur%ROWTYPE;
  l_trans_exist BOOLEAN := FALSE;  -- addded for bug#3872286

  BEGIN

    --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
    IGS_GE_GEN_003.SET_ORG_ID;

    SAVEPOINT create_file;

    -- Initiliaze the local variables
    l_file_name := NULL;
    l_sec_key := NULL;
    l_inst_code := NULL;
    l_directory := NULL ;

  /*******  Check whether flat file can be generated or not  ********/

    -- Check whether the Current Cycle and Configured Cycles are defined in the UCAS System
    OPEN ucas_cycles_cur;
    FETCH ucas_cycles_cur INTO ucas_cycles_rec;
    CLOSE ucas_cycles_cur;

    IF ucas_cycles_rec.configured_cycle IS NULL OR ucas_cycles_rec.current_cycle IS NULL THEN

      fnd_message.set_name('IGS','IGS_UC_CYCLE_NOT_FOUND');
      errbuf := fnd_message.get;
      fnd_file.put_line(fnd_file.LOG,errbuf);
      retcode:=2;
      RETURN;

    END IF;


    -- Get the Institution Code and Security Code and check for the validity
    OPEN cur_inst_code ;
    FETCH cur_inst_code INTO l_inst_code, l_sec_key;
    CLOSE cur_inst_code ;

    --  If the Security Code or Institution Code is NULL
    --  then log the error message and stop the processing.
    IF l_inst_code IS NULL OR LENGTH(l_inst_code) > 3 THEN
      --
      --  Error message: File cannot be created, as the mentioned Institution Code is invalid.
      --
      fnd_file.put_line(FND_FILE.LOG, ' ');
      fnd_message.set_name('IGS','IGS_UC_INV_INST_CD');
      errbuf := fnd_message.get;
      fnd_file.put_line(fnd_file.LOG, errbuf);
      retcode:=2;
      RETURN;

    ELSIF l_sec_key IS NULL THEN
      --
      --  Error message: File cannot be created, as the mentioned Security Key is invalid.
      --
      fnd_file.put_line(FND_FILE.LOG, ' ');
      fnd_message.set_name('IGS','IGS_UC_INV_SEQ_KEY');
      fnd_file.put_line(FND_FILE.LOG, FND_MESSAGE.GET);
      retcode:=2;
      RETURN;

    END IF;


    -- Check whether any of the Systems have defined the Interface Type as Marvin in the Configured Cycle
    -- If systems have setup the Marvin Interface in the Configured Cycle,
    -- Then Report the Error and stop processing
    -- Bug No: 3156212. Replaced the cursor marvin_setup_cur with ucas_systems_cur.
    OPEN ucas_systems_cur(ucas_cycles_rec.configured_cycle);
    FETCH ucas_systems_cur INTO l_dummy;
    IF ucas_systems_cur%NOTFOUND THEN

      CLOSE ucas_systems_cur;
      fnd_message.set_name('IGS','IGS_UC_NOT_MARV');
      errbuf := fnd_message.get;
      fnd_file.put_line(FND_FILE.LOG,errbuf);
      retcode:=2;
      RETURN;

    END IF;
    CLOSE ucas_systems_cur;


    -- Loop through all the systems in the order of UCAS, GTTR, NMAS and SWAS
    -- Bug No: 3156212. Added an argument to the cursor ucas_systems_cur.
    FOR uacs_systems_rec IN ucas_systems_cur (ucas_cycles_rec.configured_cycle) LOOP

      -- Check whether the system have any pending transactions to export
      IF pending_transactions_exist(uacs_systems_rec.system_code, ucas_cycles_rec.configured_cycle,
                                    ucas_cycles_rec.current_cycle, l_inst_code )  THEN

	    IF NOT l_trans_exist THEN
		    -- Call the local procedure to find the directory name to store the flat file
            create_directory ( l_directory );
            -- If the directory is NULL, log a message and return
            IF l_directory IS NULL THEN
                fnd_message.set_name('IGS','IGS_UC_EXP_INVIAD_DIRECTORY');
                errbuf := fnd_message.get;
                fnd_file.put_line(FND_FILE.LOG,errbuf);
                retcode:=2;
                RETURN;
            END IF ;

			/**********  Create the flat file name  *********/

            -- Create the file name to be sent to UCAS
            -- A data file is being created as filename : AfinUuu.xxxxxx

            l_file_name := 'Afin'||l_inst_code||'.'||l_sec_key;

            -- Print the Flat File Name in the log file
            fnd_file.put_line(FND_FILE.LOG, ' ');
            fnd_message.set_name('IGS','IGS_UC_FILE_NAME');
            fnd_message.set_token('FILE_NAME', l_directory||'/'||l_file_name);
            fnd_file.put_line(FND_FILE.LOG, FND_MESSAGE.GET);

            /********   Writing the data into the flat file  ********/

            -- Call the local procedure, open_file to open the file
            open_file( p_location => l_directory,
                       p_filename => l_file_name );

		    l_trans_exist := TRUE;
		END IF;

		-- Call local procedure to prepare the Header Information
        prepare_header(p_inst_code => l_inst_code,
                       p_sys_ind   => uacs_systems_rec.system_code );

        -- Call the local procedure, prepare_data to prepare UCAS System Transactions
        prepare_data( p_sys_ind           => uacs_systems_rec.system_code,
                      p_configured_cycle  => ucas_cycles_rec.configured_cycle,
                      p_current_cycle     => ucas_cycles_rec.current_cycle,
                      p_current_inst_code => l_inst_code);

        -- Call the procedure to prepare the Trailer Information
        prepare_trailer(p_inst_code => l_inst_code,
                        p_sys_ind   => uacs_systems_rec.system_code );

      END IF;

    END LOOP; /* end of writing data for all systems */

    -- Check whether any Pending Transactions exist
    -- If no system have any pending transactions send to UCAS
    -- Display the Warning Message in the log file and exit the process
    IF NOT l_trans_exist THEN
      fnd_message.set_name('IGS', 'IGS_UC_NO_PENDING_TRANS_EXIST');
      errbuf := fnd_message.get;
      fnd_file.put_line(FND_FILE.LOG,errbuf);
      retcode:=1;
      RETURN;
    END IF ;


    -- Call the local procedure, to close the file.
    close_file;

  EXCEPTION

    WHEN UTL_FILE.INVALID_PATH THEN
      ROLLBACK TO create_file;
      fnd_message.set_name('IGS', 'IGS_EN_INVALID_PATH');
      fnd_file.put_line(FND_FILE.LOG, FND_MESSAGE.GET);

    WHEN UTL_FILE.WRITE_ERROR THEN
      ROLLBACK TO create_file;
      fnd_message.set_name('IGS', 'IGS_EN_WRITE_ERROR');
      fnd_file.put_line(FND_FILE.LOG, FND_MESSAGE.GET);

    WHEN UTL_FILE.INVALID_FILEHANDLE  THEN
      ROLLBACK TO create_file;
      fnd_message.set_name('IGS', 'IGS_EN_INVALID_FILEHANDLE');
      fnd_file.put_line(FND_FILE.LOG, FND_MESSAGE.GET);

    WHEN OTHERS THEN
      ROLLBACK;
      retcode:=2;
      fnd_message.set_name( 'IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGS_UC_EXT_MARVIN.CREATE_FILE'||' - '||SQLERRM);
      errbuf := fnd_message.get;
      igs_ge_msg_stack.conc_exception_hndl;

  END create_file;

END igs_uc_ext_marvin;

/
