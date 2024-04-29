--------------------------------------------------------
--  DDL for Package Body IGS_HE_CREATE_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_CREATE_EXTRACT_PKG" AS
/* $Header: IGSHE28B.pls 120.3 2006/05/22 00:11:18 jbaber noship $*/

-- Field stat record stores field length and closed_flag
TYPE field_stats_rec IS RECORD (length NUMBER, closed VARCHAR2(1));

-- Lookup table for field stat record
TYPE field_lookup_tbl IS TABLE OF field_stats_rec INDEX BY BINARY_INTEGER;


PROCEDURE create_directory ( p_directory OUT NOCOPY VARCHAR2 ) AS
 /******************************************************************
  Created By      : ayedubat
  Date Created By : 24-Dec-02
  Purpose: Private procedure created for finding the Directory of the filename.
           This will check the value of profile 'UTL_FILE_OUT'
           (output dir for export data file) matches with the value in v$parameter
           for the name utl_file_dir.
  Known limitations,enhancements,remarks:
  Change History
  Who       When         What
 *******************************************************************/

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
      FND_MESSAGE.SET_TOKEN('NAME','IGS_HE_CREATE_EXTRACT_PKG.CREATE_DIRECTORY'||' - '||SQLERRM);
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;

  END create_directory ;


PROCEDURE create_file (errbuf                OUT NOCOPY VARCHAR2,
                       retcode               OUT NOCOPY NUMBER,
                       p_extract_run_id      IN  NUMBER,
                       p_file_format         IN  VARCHAR2,
                       p_use_overrides       IN  VARCHAR2,
                       p_person_id_grp       IN  NUMBER,
                       p_program_group       IN  VARCHAR2,
                       p_created_since_date  IN  VARCHAR2 ) IS
 /******************************************************************
  Created By      : Jonathan Baber
  Date Created By : 23-Nov-05
  Purpose         : Creates extract file
  Known limitations,enhancements,remarks:
  Change History
  Who       When         What
  anwest    13-FEB-2006  Bug# 4950285 R12 Disable OSS Mandate
 *******************************************************************/

    -- Get extract run details
    CURSOR c_extract_dtls IS
    SELECT SUBSTR(srt.record_id,4,2) recid,
           dtls.submission_name,
           dtls.user_return_subclass,
           dtls.return_name,
           dtls.file_location,
           dtls.file_name,
           shd.enrolment_start_date,
           shd.enrolment_end_date
      FROM igs_he_ext_run_dtls dtls,
           igs_he_submsn_header shd,
           igs_he_submsn_return srt
     WHERE dtls.extract_run_id = p_extract_run_id
       AND shd.submission_name = dtls.submission_name
       AND srt.submission_name = dtls.submission_name
       AND srt.user_return_subclass = dtls.user_return_subclass
       AND srt.return_name = dtls.return_name;

    -- Get length and closed_flag of each field in return
    CURSOR c_field_stats (cp_user_return_subclass igs_he_usr_rtn_clas.user_return_subclass%TYPE) IS
    SELECT sfld.field_number,
           NVL(sfld.length,0) length,
           sfld.closed_flag
      FROM igs_he_sys_rt_cl_fld sfld,
           igs_he_usr_rt_cl_fld ufld,
           igs_he_usr_rtn_clas  uclas
     WHERE uclas.user_return_subclass = cp_user_return_subclass
       AND sfld.system_return_class_type = uclas.system_return_class_type
       AND ufld.field_number = sfld.field_number
       AND ufld.user_return_subclass = uclas.user_return_subclass;

    -- Get every field in an extract for given line
    CURSOR c_extract_field(cp_line_number igs_he_ex_rn_dat_ln.line_number%type) IS
    SELECT value, override_value, field_number
      FROM igs_he_ex_rn_dat_fd
     WHERE extract_run_id = p_extract_run_id
       AND line_number = cp_line_number
     ORDER BY field_number ASC;

    -- Determine type (static or dynamic) of persion id group
    CURSOR c_group_type IS
    SELECT group_type
      FROM igs_pe_persid_group_v
    WHERE group_id = p_person_id_grp;


    TYPE ref_extract_line  IS REF CURSOR;
    c_extract_line  ref_extract_line;


    l_filepath            VARCHAR2(270);
    l_field_stat          field_stats_rec;
    l_field_lookup        field_lookup_tbl;
    l_line_count          NUMBER := 0;
    l_final_value         VARCHAR2(200);
    l_field_length        igs_he_sys_rt_cl_fld.length%TYPE;
    l_value_field_length  NUMBER(3);
    l_prs_grp_status      VARCHAR2(1) := NULL;
    l_group_type          igs_pe_persid_group_v.group_type%TYPE;
    l_file                utl_file.file_type := NULL;
    l_sqlstmt             VARCHAR2(32767);
    l_prs_grp_sql         VARCHAR2(32767);
    l_extract_dtls        c_extract_dtls%ROWTYPE;
    l_line_number         igs_he_ex_rn_dat_ln.line_number%TYPE;

    l_bind2               NUMBER;
    l_bind3               DATE;
    l_bind4               DATE;
    l_bind6               DATE;
    l_bind5               VARCHAR2(10);

BEGIN

    --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
    IGS_GE_GEN_003.SET_ORG_ID;

    -- Get extract run details
    OPEN c_extract_dtls;
    FETCH c_extract_dtls INTO l_extract_dtls;
    CLOSE c_extract_dtls;


    -- Log Header
    fnd_message.set_name('IGS','IGS_HE_PROC_SUBM');
    fnd_message.set_token('SUBMISSION_NAME',l_extract_dtls.submission_name);
    fnd_message.set_token('USER_RETURN_SUBCLASS',l_extract_dtls.user_return_subclass);
    fnd_message.set_token('RETURN_NAME',l_extract_dtls.return_name);
    fnd_message.set_token('ENROLMENT_START_DATE',l_extract_dtls.enrolment_start_date);
    fnd_message.set_token('ENROLMENT_END_DATE',l_extract_dtls.enrolment_end_date);
    fnd_file.put_line(fnd_file.log,fnd_message.get());


    -- Get file directory
    create_directory(l_filepath);

    -- If directory is NULL return with error
    IF l_filepath IS NULL THEN
        fnd_message.set_name('IGS','IGS_HE_FILE_DIR_ERROR');
        errbuf := fnd_message.get;
        fnd_file.put_line(fnd_file.log, errbuf);
        retcode:=2;
        RETURN;
    END IF ;


    -- Open file
    BEGIN
        l_file := NULL;
        l_file := UTL_FILE.FOPEN (l_filepath, l_extract_dtls.file_name, 'w');
    EXCEPTION
        WHEN OTHERS THEN
            fnd_message.set_name('IGS','IGS_HE_FILE_OPEN_ERROR');
            fnd_message.set_token('1', l_filepath || '/' || l_extract_dtls.file_name);
            errbuf := fnd_message.get;
            fnd_file.put_line(fnd_file.log, errbuf);
            retcode := 2;
            RETURN;
    END;


    -- Construct Line SQL statement.
    l_sqlstmt := ' SELECT line_number ' ||
                 '   FROM igs_he_ex_rn_dat_ln ln ' ||
                 '  WHERE ln.extract_run_id = :BIND1' ||
                 '    AND ln.exclude_from_file = ''N'' ';



    -- Include person group criteria if required
    -- Does not apply to MODULE return
    IF p_person_id_grp IS NOT NULL AND l_extract_dtls.recid <> '13' THEN

        -- Determine type (static or dynamic) of person id group
        OPEN c_group_type;
        FETCH c_group_type INTO l_group_type;
        CLOSE c_group_type;

        IF l_group_type = 'STATIC' THEN

            -- Could also use the library file to get static group members but the library
            -- uses sysdate instead of enrolment start and end date.

            l_prs_grp_sql :=  '    AND EXISTS ' ||
                              '       (SELECT ''X'' ' ||
                              '          FROM igs_pe_prsid_grp_mem_all a ' ||
                              '         WHERE a.person_id = ln.person_id ' ||
                              '           AND a.group_id = :BIND2 ' ||
                              '           AND (a.start_date IS NULL OR a.start_date <= :BIND3) ' ||
                              '           AND (a.end_date IS NULL OR a.end_date >= :BIND4) ' ||
                              '       )';

            l_sqlstmt := l_sqlstmt || l_prs_grp_sql;

            -- Set bind variables
            l_bind2 := p_person_id_grp;
            l_bind3 := l_extract_dtls.enrolment_end_date;
            l_bind4 := l_extract_dtls.enrolment_start_date;

        ELSE
            -- Use library to get dynamic persion id group members
            l_prs_grp_sql := IGS_PE_DYNAMIC_PERSID_GROUP.IGS_GET_DYNAMIC_SQL(p_person_id_grp, l_prs_grp_status);

            IF l_prs_grp_status <> 'S' THEN
            fnd_message.set_name('IGS','IGS_HE_UT_PRSN_ID_GRP_ERR');
            fnd_message.set_token('PRSNIDGRP',p_person_id_grp);
            errbuf := fnd_message.get();
            fnd_file.put_line(fnd_file.log, errbuf);  -- this message need to be displayed to user.
            retcode := '2';
            RETURN;
            END IF;

            l_sqlstmt := l_sqlstmt || 'AND ln.person_id IN ('|| l_prs_grp_sql || ')';

            -- Need to add consistent number of bind variables even if not used
            l_sqlstmt := l_sqlstmt || ' AND :BIND2 IS NULL AND :BIND3 IS NULL AND :BIND4 IS NULL ';

        END IF; -- Static / Dynamic

    ELSE
            -- No person_id_grp criteria, but need to add some to have consistent number of bind variables
            l_sqlstmt := l_sqlstmt || ' AND :BIND2 IS NULL AND :BIND3 IS NULL AND :BIND4 IS NULL ';


    END IF; -- Person ID Group Criteria


    -- Include program group criteria if required
    -- only applies to COMBINED or STUDENT return
    IF p_program_group IS NOT NULL AND l_extract_dtls.recid IN ('11','12') THEN

        l_sqlstmt := l_sqlstmt ||
                '    AND EXISTS ' ||
                '       (SELECT ''X'' ' ||
                '          FROM igs_ps_grp_mbr b ' ||
                '         WHERE b.course_cd = ln.course_cd ' ||
                '           AND b.version_number = ln.crv_version_number ' ||
                '           AND b.course_group_cd = :BIND5 ' ||
                '       )';

        l_bind5 := p_program_group;

    ELSE

        -- No progam_grp criteria, but need to have consistent number of bind variables
        l_sqlstmt := l_sqlstmt || ' AND :BIND5 IS NULL  ';

    END IF; -- Program Group Criteria


    -- Include created since date criteria if required
    IF p_created_since_date IS NOT NULL THEN

        l_sqlstmt := l_sqlstmt || '    AND ln.last_update_date >= :BIND6 ';

        -- Created since date bind variable is formatted according to concurrent request format.
        l_bind6 := TO_DATE(p_created_since_date,'yyyy/mm/dd HH24:MI:SS');

    ELSE

        -- No created since criteria criteria, but need to have consistent number of bind variables
        l_sqlstmt := l_sqlstmt || ' AND :BIND6 IS NULL ';

    END IF;

    -- Finish constructing Line SQL statement
    l_sqlstmt := l_sqlstmt || ' ORDER BY line_number ASC ';



    OPEN c_extract_line FOR l_sqlstmt USING p_extract_run_id, l_bind2, l_bind3, l_bind4, l_bind5, l_bind6;
    FETCH c_extract_line INTO l_line_number;

    -- Make sure there are some lines in the extract otherwise no point in continuing
    IF c_extract_line%NOTFOUND THEN
        CLOSE c_extract_line;
        fnd_message.set_name('IGS','IGS_HE_NO_DTLS_TO_OP');
        errbuf := fnd_message.get;
        fnd_file.put_line(fnd_file.log, errbuf);
        retcode := 1;
        RETURN;

    ELSE

        -- Get length and closed_flag of each field
        -- Store in l_field_lookup
        -- Should use BULK COLLECT in post 8i database
        FOR l_field IN c_field_stats(l_extract_dtls.user_return_subclass) LOOP
            l_field_stat.length := l_field.length;
            l_field_stat.closed := l_field.closed_flag;
            l_field_lookup(l_field.field_number) := l_field_stat;
        END LOOP;


        -- For every line in the extract
       WHILE c_extract_line%FOUND LOOP

            FOR l_extract_field in c_extract_field(l_line_number) LOOP

                -- Detemine value of field
                  -- If field is closed, value = NULL
                  -- If overrides are to be used and override value not blank, value = overide
                  -- Otherwise just get value
                IF l_field_lookup(l_extract_field.field_number).closed = 'Y' THEN
                    l_final_value := NULL;
                ELSIF p_use_overrides = 'Y' AND l_extract_field.override_value IS NOT NULL THEN
                    IF l_extract_field.override_value = 'NULL' THEN
                        l_final_value := NULL;
                    ELSE
                        l_final_value := ltrim(rtrim(REPLACE(l_extract_field.override_value,'"','') ));
                    END IF;
                ELSE
                    l_final_value := ltrim(rtrim(REPLACE(l_extract_field.value,'"','') ));
                END IF;


                -- Get length of value and length of field
                l_value_field_length := NVL(LENGTH(l_final_value),0) ;
                l_field_length := l_field_lookup(l_extract_field.field_number).length;


                -- Truncate value to field length
                IF ( l_value_field_length > l_field_length) THEN
                     l_final_value :=  SUBSTR( l_final_value,1,l_field_length) ;
                END IF;


                -- If file format = fixed then pad value
                IF p_file_format = 'FIX'  AND ( l_value_field_length < l_field_length) THEN
                       l_final_value := RPAD( NVL(l_final_value,' '),l_field_length) ;
                END IF;


                -- If file format = csv then prepend ',' on all but first field
                IF p_file_format = 'CSV' THEN
                    l_final_value := ltrim(rtrim( REPLACE(l_final_value,',',' ') )) ;
                    IF (c_extract_field%ROWCOUNT > 1) THEN
                        l_final_value := ',' || l_final_value;
                    END IF;
                END IF;

                -- Write field to file
                BEGIN
                    utl_file.put (l_file, l_final_value );
                EXCEPTION
                    WHEN UTL_FILE.WRITE_ERROR THEN
                        fnd_message.set_name('IGS', 'IGS_HE_FILE_WRITE_ERROR');
                        fnd_message.set_token('1', l_filepath || '/' || l_extract_dtls.file_name);
                        fnd_file.put_line(fnd_file.log, fnd_message.get);
                        RAISE;
                END;

                l_final_value :='';

            END LOOP; -- c_extract_field

            -- Append a  new line character at the end and write to file
            utl_file.new_line (l_file);
            utl_file.fflush (l_file);

            -- Get next line
            FETCH c_extract_line INTO l_line_number;

        END LOOP; -- c_extract_line

        -- Get line count
        l_line_count := c_extract_line%ROWCOUNT;

    END IF;

    CLOSE c_extract_line;

    -- Close file
    BEGIN
        IF (utl_file.is_open( l_file )) THEN
            utl_file.fclose( l_file );
        END IF;
    EXCEPTION
     WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_HE_FILE_CLOSE_ERROR');
        fnd_message.set_token('1', l_filepath || '/' || l_extract_dtls.file_name);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        errbuf  := fnd_message.get ;
        retcode := 2;
        RETURN;
    END;

    -- Update extract criteria with location file has been written to
    UPDATE igs_he_ext_run_dtls
    SET file_location = l_filepath
    WHERE extract_run_id = p_extract_run_id;

    -- Log lines written and filename
    fnd_message.set_name('IGS','IGS_HE_FILE_LINES_WRITTEN');
    fnd_message.set_token('NUMLINES', l_line_count);
    fnd_message.set_token('FILE', l_filepath || '/' || l_extract_dtls.file_name);
    fnd_file.put_line(fnd_file.log, fnd_message.get);


    EXCEPTION
     WHEN OTHERS THEN

        -- Close any open cursors
        IF c_extract_field%ISOPEN THEN
            CLOSE c_extract_field;
        END IF;

        IF c_extract_line%ISOPEN THEN
            CLOSE c_extract_line;
        END IF;

        retcode := 2;
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','igs_he_create_extract_pkg.create_file - ' ||SQLERRM);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        App_Exception.Raise_Exception;

END create_file;


END igs_he_create_extract_pkg ;

/
