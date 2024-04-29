--------------------------------------------------------
--  DDL for Package Body IGS_HE_EXTRACT2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_EXTRACT2_PKG" AS
/* $Header: IGSHE9BB.pls 120.15 2006/09/21 23:56:26 jbaber noship $ */

   -- Variables that will be accessed by any or all the procedures
   -- Extract related records
   g_he_ext_run_dtls                      igs_he_ext_run_dtls%ROWTYPE;
   g_he_ext_run_except                    igs_he_ext_run_excp%ROWTYPE;
   g_he_submsn_return                     igs_he_submsn_return%ROWTYPE;
   g_he_submsn_header                     igs_he_submsn_header%ROWTYPE;

   -- Student / Module related records.
   g_en_stdnt_ps_att                      igs_en_stdnt_ps_att%ROWTYPE;
   g_he_st_spa                            igs_he_st_spa%ROWTYPE;
   g_as_su_setatmpt                       igs_as_su_setatmpt%ROWTYPE;
   g_he_en_susa                           igs_he_en_susa%ROWTYPE;
   g_he_st_prog                           igs_he_st_prog%ROWTYPE;
   g_ps_ver                               igs_ps_ver%ROWTYPE;
   g_ps_type                              igs_ps_type_all%ROWTYPE;
   g_ps_ofr_opt                           igs_ps_ofr_opt%ROWTYPE;
   g_he_poous                             igs_he_poous%ROWTYPE;
   g_pe_person                            igs_pe_person%ROWTYPE;
   g_pe_stat_v                            igs_pe_stat_v%ROWTYPE;
   g_he_ad_dtl                            igs_he_ad_dtl%ROWTYPE;
   g_he_st_unt_vs                         igs_he_st_unt_vs%ROWTYPE;
   g_ps_unit_ver_v                        igs_ps_unit_ver_v%ROWTYPE;
   g_default_pro                          VARCHAR2(1);
   g_he_stdnt_dlhe                        igs_he_stdnt_dlhe%ROWTYPE ;
   l_hesa_method      igs_he_ex_rn_dat_fd.value%TYPE;
   l_hesa_empcir      igs_he_ex_rn_dat_fd.value%TYPE;
   l_hesa_modstudy    igs_he_ex_rn_dat_fd.value%TYPE;
   l_hesa_natstudy    igs_he_ex_rn_dat_fd.value%TYPE;
   l_hesa_empcrse     igs_he_ex_rn_dat_fd.value%TYPE;
   l_hesa_prevemp     igs_he_ex_rn_dat_fd.value%TYPE;
   l_hesa_tchemp      igs_he_ex_rn_dat_fd.value%TYPE;
   g_field_exists       BOOLEAN;
   g_prog_rec_flag      BOOLEAN; -- used as a flag to check whether to search igs_he_submsn_awd table
   g_prog_type_rec_flag BOOLEAN; -- used as a flag to check whether to search igs_he_submsn_awd table
   l_awd_conf_start_dt DATE;
   l_awd_conf_end_dt DATE;
   -- PL/SQL table to hold award conferral dates for a submission
   g_awd_table        igs_he_extract_fields_pkg.awd_table;

   -- Index Table to hold the field definitions.
   TYPE fldnum IS TABLE OF igs_he_usr_rt_cl_fld.field_number%TYPE
        INDEX BY binary_integer;
   TYPE constval IS TABLE OF igs_he_usr_rt_cl_fld.constant_val%TYPE
        INDEX BY binary_integer;
   TYPE defval IS TABLE OF igs_he_usr_rt_cl_fld.default_val%TYPE
        INDEX BY binary_integer;
   TYPE reportnullflag IS TABLE OF igs_he_usr_rt_cl_fld.report_null_flag%TYPE
        INDEX BY binary_integer;
   TYPE value IS TABLE OF igs_he_ex_rn_dat_fd.value%TYPE
        INDEX BY binary_integer;

   TYPE field_defn IS RECORD
      (field_number             fldnum,
       constant_val             constval,
       default_val              defval,
       report_null_flag         reportnullflag,
       hesa_value               value,
       oss_value                value);

   g_field_defn        field_defn;

   g_msg_ext_fld_val_null VARCHAR2(2000);

   -- Structure to hold cost centres
   g_cc_rec           igs_he_extract_fields_pkg.cc_rec;
   g_total_ccs        NUMBER;

   -- Structure to hold Modules
   g_mod_rec          igs_he_extract_fields_pkg.mod_rec;
   g_total_mod        NUMBER;

   /*----------------------------------------------------------------------
   This procedures writes onto the log file
   ----------------------------------------------------------------------*/
   PROCEDURE write_to_log(p_message    IN VARCHAR2)
   IS
   BEGIN

      Fnd_File.Put_Line(Fnd_File.Log, p_message);

   END write_to_log;

   --smaddali added this new local procedure for bug 2452592 to calculte field 76
  PROCEDURE get_pgce_subj
          (p_person_id             IN  igs_pe_person.person_id%TYPE,
           p_pgce_subj             OUT NOCOPY VARCHAR2) IS
 /***************************************************************
   Created By           :       bayadav
   Date Created By      :       25-Mar-2002
   Purpose              :This procedure gets the subject of the previous qualification which
      is also defined as the 1t qualification in igs_he_code_values for code_type 'OSS_QUAL_1ST_DEGREE'
        The govt field of study for the subject is returned
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When            What
   smaddali 19-jul-02  Included new procedure get_pgce_subj as a part  of bug 2452592
  smaddali modified cursor c_subject for bug 2730388
 ***************************************************************/

   --Cursor to  get the subject of the previous qualification which is defined as OSS_QUAL_1ST_DEGREE
   -- smaddali modified cursor to get only open code_values ,bug 2730388
   CURSOR c_subject IS
   SELECT  a.subject_code
   FROM   igs_uc_qual_dets a
   WHERE  a.person_id = p_person_id
   AND    EXISTS (SELECT 'X'
                  FROM   igs_he_code_values b
                  WHERE  b.value = a.exam_level
                  AND    b.code_type = 'OSS_QUAL_1ST_DEGREE'
                  AND    NVL(b.closed_ind,'N') = 'N' )
   ORDER BY a.year DESC;

    -- get the govt field of study for the subject
   CURSOR c_field_of_study(p_subject  igs_he_poous_ou_cc.subject%TYPE) IS
   SELECT govt_field_of_study
   FROM   IGS_PS_FLD_OF_STUDY PFS
   WHERE  field_of_study = p_subject;

   l_subject igs_uc_qual_dets.subject_code%TYPE  ;

  BEGIN
l_subject := NULL;
          OPEN c_subject ;
          FETCH c_subject INTO l_subject ;
          IF c_subject%FOUND THEN
               OPEN c_field_of_study(l_subject) ;
               FETCH c_field_of_study INTO p_pgce_subj ;
               CLOSE c_field_of_study ;
          ELSE
              p_pgce_subj := NULL ;
          END IF ;
          CLOSE c_subject ;

  EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log (SQLERRM);
          -- close open cursors
          IF c_subject%ISOPEN THEN
              CLOSE c_subject ;
          END IF ;
          IF c_field_of_study%ISOPEN THEN
              CLOSE c_field_of_study ;
          END IF ;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_FIELDS_PKG.get_pgce_subj');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

  END get_pgce_subj ;



   /*----------------------------------------------------------------------
   This procedure is called to fetch the data from the HESA mapping
   table. It is used to either get a HESA equivalent value for an OSS
   value or to derive one OSS value dependent on another.

   Parameters :
   p_he_code_map_val   IN     Record containing the association codes
                              and any other value from which the new value
                              needs to be derived
   p_value_from        IN     Column name of what to select from
                              E.g 'map1' or 'map2' etc.
   p_return_value      OUT NOCOPY Return Value

   Change History :
   Who                  When            What
   jchakrab        05-FEB-2005        Modified for 4006205 - SQL queries using literals have been
                                      modified to use bind variables.
                                      Added new internal procedure - get_map_values_from_SQL()
   ----------------------------------------------------------------------*/
   PROCEDURE get_map_values
                 (p_he_code_map_val   IN     igs_he_code_map_val%ROWTYPE,
                  p_value_from        IN     VARCHAR2,
                  p_return_value      OUT NOCOPY igs_he_code_map_val.map1%TYPE)
   IS

   CURSOR cur_map1 (p_assoc igs_he_code_map_val.association_code%TYPE ,
                     p_map2 igs_he_code_map_val.map2%TYPE ) IS
     SELECT  map1
     FROM    igs_he_code_map_val
     WHERE   association_code = p_assoc
     AND     map2  = p_map2;

   CURSOR cur_map2 (p_assoc igs_he_code_map_val.association_code%TYPE ,
                     p_map1 igs_he_code_map_val.map1%TYPE ) IS
     SELECT  map2
     FROM    igs_he_code_map_val
     WHERE   association_code = p_assoc
     AND     map1  = p_map1;

   CURSOR cur_map3 (p_assoc igs_he_code_map_val.association_code%TYPE ,
                     p_map2 igs_he_code_map_val.map2%TYPE ) IS
     SELECT  map3
     FROM    igs_he_code_map_val
     WHERE   association_code = p_assoc
     AND     map2  = p_map2;

   CURSOR cur_map4 (p_assoc igs_he_code_map_val.association_code%TYPE ,
                     p_map2 igs_he_code_map_val.map2%TYPE,
                     p_map3 igs_he_code_map_val.map3%TYPE ) IS
     SELECT  map1
     FROM    igs_he_code_map_val
     WHERE   association_code = p_assoc
     AND     map2  = p_map2
     AND     map3  = p_map3;

   CURSOR cur_map5 (p_assoc igs_he_code_map_val.association_code%TYPE ,
                     p_map2 igs_he_code_map_val.map2%TYPE,
                     p_map3 igs_he_code_map_val.map3%TYPE,
                     p_map4 igs_he_code_map_val.map5%TYPE ) IS
     SELECT  map1
     FROM    igs_he_code_map_val
     WHERE   association_code = p_assoc
     AND     map2  = p_map2
     AND     map3  = p_map3
     AND     map4  = p_map4;


   l_found_map                 BOOLEAN;


   PROCEDURE get_map_values_from_sql(p_he_code_map_val   IN   igs_he_code_map_val%ROWTYPE,
                                    p_value_from        IN   VARCHAR2,
                                    p_return_value      OUT  NOCOPY igs_he_code_map_val.map1%TYPE)
   IS

  /******************************************************************************
    Created By      : JCHAKRAB
    Date Created By : 09-FEB-2005
    Purpose         : Created for 4006205 - HESA performance enhs.

                      As part of 4006205, the get_map_values() procedure was modified
                      to prevent the use of literals in the SQL queries used for lookups.
                      The modified procedure makes use of cursors to make use of
                      bind variables for lookup queries. But the cursors added are limited
                      to the various combinations of lookup queries being performed
                      in the current HESA extraction code.

                      This procedure was added to make the modified get_map_values()
                      procedure to be compatible with any kind of lookup performed.
                      This procedure would only be called when none of the cursors
                      defined in the get_map_values() procedure can be used to get
                      a mapped value.

    Parameters :
    p_he_code_map_val   IN     Record containing the association codes
                                    and any other value from which the new value
                                    needs to be derived
    p_value_from        IN     Column name of what to select from
                                    E.g 'map1' or 'map2' etc.
    p_return_value      OUT NOCOPY Return Value

    Known limitations,enhancements,remarks:

    CHANGE HISTORY:
     WHO        WHEN         WHAT

  ******************************************************************************/

  TYPE cur_mapval  IS REF CURSOR;
      c_mapval                   cur_mapval;
      l_sql_stmt                 VARCHAR2(2000);


  BEGIN

        l_sql_stmt := ' SELECT '||p_value_from ||
                           ' FROM igs_he_code_map_val '||
                      ' WHERE association_code = '''||p_he_code_map_val.association_code ||'''';

        If p_he_code_map_val.map1 IS NOT NULL
        THEN
           l_sql_stmt := l_sql_stmt ||
                         ' AND map1 = '''||p_he_code_map_val.map1||'''';
        END IF;

        If p_he_code_map_val.map2 IS NOT NULL
        THEN
           l_sql_stmt := l_sql_stmt ||
                         ' AND map2 = '''||p_he_code_map_val.map2||'''';
        END IF;

        If p_he_code_map_val.map3 IS NOT NULL
        THEN
           l_sql_stmt := l_sql_stmt ||
                         ' AND map3 = '''||p_he_code_map_val.map3||'''';
        END IF;

        If p_he_code_map_val.map4 IS NOT NULL
        THEN
           l_sql_stmt := l_sql_stmt ||
                         ' AND map4 = '''||p_he_code_map_val.map4||'''';
        END IF;

        If p_he_code_map_val.map5 IS NOT NULL
        THEN
           l_sql_stmt := l_sql_stmt ||
                         ' AND map5 = '''||p_he_code_map_val.map5||'''';
        END IF;

        If p_he_code_map_val.map6 IS NOT NULL
        THEN
           l_sql_stmt := l_sql_stmt ||
                         ' AND map6 = '''||p_he_code_map_val.map6||'''';
        END IF;

        If p_he_code_map_val.map7 IS NOT NULL
        THEN
           l_sql_stmt := l_sql_stmt ||
                         ' AND map7 = '''||p_he_code_map_val.map7||'''';
        END IF;

        If p_he_code_map_val.map8 IS NOT NULL
        THEN
           l_sql_stmt := l_sql_stmt ||
                         ' AND map8 = '''||p_he_code_map_val.map8||'''';
        END IF;

        If p_he_code_map_val.map9 IS NOT NULL
        THEN
           l_sql_stmt := l_sql_stmt ||
                         ' AND map9 = '''||p_he_code_map_val.map9||'''';
        END IF;

        If p_he_code_map_val.map10 IS NOT NULL
        THEN
           l_sql_stmt := l_sql_stmt ||
                         ' AND map10 = '''||p_he_code_map_val.map10||'''';
        END IF;

            OPEN c_mapval FOR l_sql_stmt;
            FETCH c_mapval INTO p_return_value;
            CLOSE c_mapval;

        EXCEPTION
        WHEN OTHERS
        THEN
            write_to_log(SQLERRM);

            -- Close cursor
            IF c_mapval%ISOPEN
            THEN
                CLOSE c_mapval;
            END IF;

            Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT2_PKG.get_map_values_from_sql');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;

   END get_map_values_from_sql;

   BEGIN
       l_found_map := FALSE;
       IF p_value_from = 'MAP1' THEN
           IF p_he_code_map_val.map2 IS NOT NULL and
               p_he_code_map_val.map3 IS NOT NULL and
               p_he_code_map_val.map4 IS NOT NULL THEN

               -- use cur_map5
               OPEN cur_map5(p_he_code_map_val.association_code,
                            p_he_code_map_val.map2,
                            p_he_code_map_val.map3,
                            p_he_code_map_val.map4);
               FETCH cur_map5 INTO p_return_value;
               CLOSE cur_map5;
               l_found_map := TRUE;
            ELSIF p_he_code_map_val.map2 IS NOT NULL and
               p_he_code_map_val.map3 IS NOT NULL THEN

               -- use cur_map4
               OPEN cur_map4(p_he_code_map_val.association_code,
                            p_he_code_map_val.map2,
                            p_he_code_map_val.map3);
               FETCH cur_map4 INTO p_return_value;
               CLOSE cur_map4;
               l_found_map := TRUE;
            ELSIF p_he_code_map_val.map2 IS NOT NULL THEN

               -- use cur_map1
               OPEN cur_map1(p_he_code_map_val.association_code,
                            p_he_code_map_val.map2);
               FETCH cur_map1 INTO p_return_value;
               CLOSE cur_map1;
               l_found_map := TRUE;
            END IF;
       ELSIF p_value_from = 'MAP2' THEN
           IF    p_he_code_map_val.map1 IS NOT NULL THEN
               -- use cur_map2
               OPEN cur_map2(p_he_code_map_val.association_code,
                            p_he_code_map_val.map1);
               FETCH cur_map2 INTO p_return_value;
               CLOSE cur_map2;
               l_found_map := TRUE;
           END IF;
      ELSIF p_value_from = 'MAP3' THEN
           IF    p_he_code_map_val.map2 IS NOT NULL THEN
               -- use cur_map3
               OPEN cur_map3(p_he_code_map_val.association_code,
                          p_he_code_map_val.map2);
               FETCH cur_map3 INTO p_return_value;
               CLOSE cur_map3;
               l_found_map := TRUE;
           END IF;
       END IF;

       IF NOT l_found_map THEN
           --use get_map_values_from_sql() to construct the map lookup query
           get_map_values_from_sql(p_he_code_map_val, p_value_from, p_return_value);
       END IF;


   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          -- Close cursors
          IF cur_map1%ISOPEN
          THEN
              CLOSE cur_map1;
          END IF;

          IF cur_map2%ISOPEN
          THEN
              CLOSE cur_map2;
          END IF;

          IF cur_map3%ISOPEN
          THEN
              CLOSE cur_map3;
          END IF;

          IF cur_map4%ISOPEN
          THEN
              CLOSE cur_map4;
          END IF;

          IF cur_map5%ISOPEN
          THEN
              CLOSE cur_map5;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT2_PKG.get_map_values');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

   END get_map_values;

   /*----------------------------------------------------------------------
   This procedure is called to insert errors into the exception run
   table. The Exception Run Report is run after the Generate Extract
   process completes which reads the data from this table and prints the
   report
   The processing should not stop if any error is encountered unless it
   is fatal.

   Parameters :
   p_he_ext_run_exceptions     IN     Record which contains the values that
                                      need to be inserted into the exception
                                      table.
                                      The field Exception_Reason should
                                      contain the message text not the
                                      message code.

   Change History :
   Who                  When            What
   jchakrab        05-FEB-2005        Modified for 4006205 - Removed Autonomous Transaction.
                                      Replaced TBH call to insert_row() with direct DML.
   ----------------------------------------------------------------------*/
   PROCEDURE log_error
             (p_he_ext_run_exceptions  IN OUT NOCOPY igs_he_ext_run_excp%ROWTYPE)
   IS

   l_rowid VARCHAR2(30) ;
   l_last_update_date           DATE;
   l_last_updated_by            NUMBER;
   l_last_update_login          NUMBER;


   BEGIN

      l_rowid := NULL;

      l_last_update_date := SYSDATE;
      l_last_updated_by := NVL(fnd_global.user_id, -1);
      l_last_update_login := NVL(fnd_global.login_id, -1);

      --jchakrab - 4006205 - replace TBH with direct DML call
      INSERT INTO igs_he_ext_run_excp (
                          ext_exception_id,
                          extract_run_id,
                          person_id,
                          person_number,
                          course_cd,
                          crv_version_number,
                          unit_cd,
                          uv_version_number,
                          line_number,
                          field_number,
                          exception_reason,
                          creation_date,
                          created_by,
                          last_update_date,
                          last_updated_by,
                          last_update_login
                ) VALUES (
                          igs_he_ext_run_excp_s.NEXTVAL,
                          p_he_ext_run_exceptions.Extract_Run_Id,
                          p_he_ext_run_exceptions.Person_Id,
                          p_he_ext_run_exceptions.Person_Number,
                          p_he_ext_run_exceptions.Course_Cd,
                          p_he_ext_run_exceptions.Crv_Version_Number,
                          p_he_ext_run_exceptions.Unit_Cd,
                          p_he_ext_run_exceptions.Uv_Version_Number,
                          p_he_ext_run_exceptions.Line_Number,
                          p_he_ext_run_exceptions.Field_Number,
                          p_he_ext_run_exceptions.Exception_Reason,
                          l_last_update_date,
                          l_last_updated_by,
                          l_last_update_date,
                          l_last_updated_by,
                          l_last_update_login
                );


      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT2_PKG.log_error');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

   END log_error;

   /*----------------------------------------------------------------------
   This procedure gets the field definitions and stores them into
   a global array to be used when deriving the fields.

   Parameters :
   p_extract_run_id     IN     The Extract Run Id

   Name       Date         Comments                                                                                                |
   sjlaport   31 May 2005  Modified cursor c_fld_defn to select the mandatory_flag
                           field from the system return class definition and to
                           exclude fields not included in the user return class
   jbaber     15 Mar 2006  Modified c_fld_defn to use report_null_flag instead of
                           mandatory_flag as per HE365 - Extract Rerun
   ----------------------------------------------------------------------*/
   PROCEDURE get_field_defn
          (p_extract_run_id IN igs_he_ext_run_dtls.extract_run_id%TYPE)
   IS

   CURSOR c_ext_dtl IS
   SELECT a.submission_name,
          a.user_return_subclass,
          a.return_name ,
          a.extract_phase,
          a.student_ext_run_id,
          b.lrr_start_date,
          b.lrr_end_date,
          b.record_id,
          c.enrolment_start_date,
          c.enrolment_end_date,
          c.offset_days ,
          c.validation_country,
          c.apply_to_atmpt_st_dt,
          c.apply_to_inst_st_dt
   FROM   igs_he_ext_run_dtls  a,
          igs_he_submsn_return b,
          igs_he_submsn_header c
   WHERE  a.extract_run_id       = p_extract_run_id
   AND    a.submission_name      = b.submission_name
   AND    a.return_name          = b.return_name
   AND    a.User_Return_Subclass = b.user_return_subclass
   AND    a.submission_name      = c.submission_name;

   CURSOR c_fld_defn
          (p_usr_return_subclass   igs_he_usr_rt_cl_fld.user_return_subclass%TYPE) IS
   SELECT hefld.field_number,
          hefld.constant_val,
          hefld.default_val,
          hefld.report_null_flag
   FROM   igs_he_usr_rt_cl_fld hefld,
          igs_he_usr_rtn_clas hecls
   WHERE  hefld.user_return_subclass = p_usr_return_subclass
   AND    hefld.user_return_subclass = hecls.user_return_subclass
   AND    hefld.include_flag = 'Y';


   l_message               VARCHAR2(2000);

   BEGIN

      -- Get the HESA Extract Details
      OPEN c_ext_dtl;
      FETCH c_ext_dtl INTO g_he_ext_run_dtls.submission_name,
                           g_he_ext_run_dtls.user_return_subclass,
                           g_he_ext_run_dtls.return_name ,
                           g_he_ext_run_dtls.extract_phase,
                           g_he_ext_run_dtls.student_ext_run_id,
                           g_he_submsn_return.lrr_start_date,
                           g_he_submsn_return.lrr_end_date,
                           g_he_submsn_return.record_id,
                           g_he_submsn_header.enrolment_start_date,
                           g_he_submsn_header.enrolment_end_date,
                           g_he_submsn_header.offset_days ,
                           g_he_submsn_header.validation_country,
                           g_he_submsn_header.apply_to_atmpt_st_dt,
                           g_he_submsn_header.apply_to_inst_st_dt;
      CLOSE c_ext_dtl;

      -- Now get the Fields for which extraction needs to be performed.
      FOR l_fld_defn IN c_fld_defn (g_he_ext_run_dtls.user_return_subclass)
      LOOP
          -- Store the values in an array , where the index is the
          -- field number
          g_field_defn.field_number(l_fld_defn.field_number)     := l_fld_defn.field_number;
          g_field_defn.constant_val(l_fld_defn.field_number)     := l_fld_defn.constant_val;
          g_field_defn.default_val(l_fld_defn.field_number)      := l_fld_defn.default_val;
          g_field_defn.report_null_flag(l_fld_defn.field_number) := l_fld_defn.report_null_flag;

      END LOOP;

      IF g_field_defn.field_number.COUNT = 0
      THEN
          Fnd_Message.Set_Name('IGS', 'IGS_HE_EXT_FLDS_NOT_FOUND');
          l_message := Fnd_Message.Get;
          write_to_log(l_message);
          -- Initialize Record to Null.
          g_he_ext_run_except := NULL;

          -- Populate the required fields.
          g_he_ext_run_except.extract_run_id   := p_extract_run_id;
          g_he_ext_run_except.exception_reason := l_message;

          -- Call procedure to log error
          log_error (g_he_ext_run_except);
      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          IF c_ext_dtl%ISOPEN
          THEN
              CLOSE c_ext_dtl;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT2_PKG.get_field_defn');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

   END get_field_defn;


   /*----------------------------------------------------------------------
   This procedure gets values for the individual fields to be
   submitted in the HESA COMBINED and STUDENT returns

   Parameters :
   p_person_id              Person_id for the student
   p_course_cd              Course Code that the student is attempting
   p_crv_version_number     Version Number of the course code
   p_student_inst_number    Student Instance Number
   p_field_number           Field Number currently being processed.
   p_value                  Calculated Value of the field.

      --changed the code for field 26  as a  part of HECR002.
      --If IGS_HE_ST_SPA_ALL.commencement date is NOT NULL then  assign  IGS_HE_ST_SPA_ALL.commencement date to p_value
      --elsif IGS_HE_ST_SPA_ALL.commencement date IS  NULL then  check if program transfer has taken palce
      --If program transfer has taken place then assign get the value of first program in chain for that person
      --(For the person having the same student instance number for the different program transfer are said to be in same chain)
      --and assign the corresponding IGS_EN_STDNT_PS_ATT.commencement_dt value to it
      --else if the program transfer has  not taken palce then get the IGS_EN_STDNT_PS_ATT.commencement_dt value
      --of course in context and assign it to field
   ----------------------------------------------------------------------*/
   PROCEDURE process_comb_fields
             (p_person_id           IN  igs_he_ex_rn_dat_ln.person_id%TYPE,
              p_course_cd           IN   igs_he_ex_rn_dat_ln.course_cd%TYPE,
              p_crv_version_number  IN   igs_he_ex_rn_dat_ln.crv_version_number%TYPE,
              p_student_inst_number IN   igs_he_ex_rn_dat_ln.student_inst_number%TYPE,
              p_field_number        IN   NUMBER,
              p_value               IN OUT NOCOPY   igs_he_ex_rn_dat_fd.value%TYPE)

   IS
  /***************************************************************
   Created By           :
   Date Created By      :
   Purpose              :This procedure gets the value of combined fields
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                   When                   What
   Bayadav   25-MAR-2002     Changed the code for field 26  as a  part of HECR002.
   Bayadav   26-Mar-2002     Changed the code for field 74  as a  part of HECR001.
   Bayadav   26-Mar-2002     Changed the code for field 101,104,107,113,116,119,122,125,128,131,137,140,143 and 146 as a part of HECR004 .
   Bayadav   19-JUL-2002     Changed the call for IGS_HE_EXTRACT_FIELDS_PKG.get_year_of_student proc for fields 27 and 30 as per bug 2449010
   smaddali  23-jul-02       modified field 76 to call new procedure for bug 2452592
   Bayadav   24-OCt-02       modified the logic for field 148,4,33,43,44,45,46,49,50,153,6,14,17,27,29,
                             34,36,42,83,84,85,54,55,56,57,58,59,60,61,62,63,78,155,156,161 as a part of HEFD101(2636897)

   Bayadav    02-DEC-02    Included 'WALES' also in the counrty list for field 155 as a part fo bug 2685091.Also made the default processing TRUE for other countries
   smaddali   3-dec-2002   Modified field 169 to remove dependency on field 148 for bug 2663717
   Bayadav    09-DEC-02    Modified code logic field 29 as a part of bug 2685091
   Bayadav    12-DEC-02    Included exists clause field 148 as a part of bug 2706787
   Bayadav    16-DEC-02    Changed the code for default Processing for field 83 and 161 as a part of bug 2710907
   Bayadav    16-DEC-02    Included 2 new parameters in procedure get_rsn_inst_left for field combined/student field 33 as a part of bug 2702100
   Bayadav    16-DEC-02    Included 2 new parameters in procedure get_qual_obtained  for field combined/student field 37 and 38,39  as a part of bug 2702117
   Bayadav    17-DEC-02    Changed the defualt value processing for combined field 155 and student field 140 as a part of bug 2713527
   Bayadav    17-DEC-02    Changed the default value processing for combined field  34,36,42,83,84,85 and student field 34,36,42,83,84,191 as a part of bug 2714418
   smaddali  18-dec-2002   modified field 85 to give format mask 00000 ,bug 2714010
   smaddali  25-aug-03     modified get_funding_src call to pass funding_source field for hefd208 - bug#2717751
   rbezawad  17-Sep-03     Modified the derivation of field 19 logic w.r.t. UCFD210 Build, Bug 2893542
   smaddali  13-oct-03     Modified calls to get_year_of_student to add 1 new parameter , for bug#3224246
   uudayapr  02-nov-03     Modified get_inst_last_attended procedure by adding two new parameter.
   smaddali  14-jan-04     Modified logic for field 19 for bug#3370979
   jbaber    20-Sep-04     Modified as per HEFD350 - Statutory changes for 2004/05 Reporting
                           Modified fields: 27, 30, 96, 97, 98, 99, 100
                           Created fields:  206-226
   jtmathew  01-Feb-05     Modified get_funding_src call to pass funding_source field at spa level -  bug#3962575
 ***************************************************************/



     l_inst_id          igs_or_institution.govt_institution_cd%TYPE;
     l_index            NUMBER;
     l_dummy            VARCHAR2(50);
     l_prop_not_taught  NUMBER ;
     l_dummy1  igs_ps_fld_of_study.govt_field_of_study%TYPE;
     l_dummy2  igs_ps_fld_of_study.govt_field_of_study%TYPE;
     l_dummy3  igs_ps_fld_of_study.govt_field_of_study%TYPE;
     l_fundlev igs_he_ex_rn_dat_fd.value%TYPE;
     l_spcstu  igs_he_ex_rn_dat_fd.value%TYPE;
     l_notact  igs_he_ex_rn_dat_fd.value%TYPE;
     l_mode    igs_he_ex_rn_dat_fd.value%TYPE;
     l_typeyr  igs_he_ex_rn_dat_fd.value%TYPE;
     l_fmly_name igs_pe_person.surname%TYPE;
     l_disadv_uplift_factor igs_he_st_spa.disadv_uplift_factor%TYPE;

     CURSOR c_subj(cp_field_of_study igs_ps_fld_of_study.field_of_study%TYPE)
     IS
     SELECT govt_field_of_study
     FROM igs_ps_fld_of_study
     WHERE field_of_study = cp_field_of_study;


   BEGIN

      p_value := NULL;
      g_default_pro := 'Y';
      l_prop_not_taught := NULL ;
      l_disadv_uplift_factor := NULL;

      IF      p_field_number = 1
      THEN
          -- Record Type Identifier
          p_value := g_he_submsn_return.record_id;

      ELSIF  p_field_number = 2
      THEN
          -- Hesa Institution Id
          igs_he_extract_fields_pkg.get_hesa_inst_id
              (p_hesa_inst_id => p_value);

      ELSIF  p_field_number = 3
      THEN
          -- Campus Id
          igs_he_extract_fields_pkg.get_campus_id
              (p_location_cd => g_en_stdnt_ps_att.location_cd,
               p_campus_id   => p_value);

      ELSIF  p_field_number = 4
      THEN
          -- Student Identifier
          -- Pass in the Institution Id
          IF g_field_defn.hesa_value.EXISTS(2)
          THEN
              l_inst_id := g_field_defn.hesa_value(2);
          ELSE
              l_inst_id := 0;
          END IF;

          -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
          igs_he_extract_fields_pkg.get_stdnt_id
              (p_person_id              => p_person_id,
               p_inst_id                => l_inst_id,
               p_stdnt_id               => p_value,
               p_enrl_start_dt          =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt            =>  g_he_submsn_header.enrolment_end_date);

      ELSIF  p_field_number = 5
      THEN
          -- Scottish Candidate Number
          IF g_he_st_spa.associate_scott_cand = 'Y'
          THEN
          -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
              igs_he_extract_fields_pkg.get_alt_pers_id
                 (p_person_id           => p_person_id,
                  p_id_type             => 'UCASREGNO',
                  p_api_id              => p_value,
                  p_enrl_start_dt       =>  g_he_submsn_header.enrolment_start_date,
                  p_enrl_end_dt         =>  g_he_submsn_header.enrolment_end_date);
          END IF;

      ELSIF  p_field_number = 6
      THEN
          -- FE Student Marker
          -- First get the Funding Source
          -- smaddali modified this call to pass funding_source field for hefd208 - bug#2717751
          -- jtmathew modified this call to pass funding source from spa level - bug#3962575
          igs_he_extract_fields_pkg.get_funding_src
              (p_course_cd             => p_course_cd,
               p_version_number        => p_crv_version_number,
               p_spa_fund_src          => g_en_stdnt_ps_att.funding_source,
               p_poous_fund_src        => g_he_poous.funding_source,
               p_oss_fund_src          => g_field_defn.oss_value(64),
               p_hesa_fund_src         => g_field_defn.hesa_value(64));

          -- Next get the Fundability Code
          IF  g_field_defn.oss_value.EXISTS(64) THEN
            -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
            igs_he_extract_fields_pkg.get_fundability_cd
              (p_person_id             => p_person_id,
               p_susa_fund_cd          => g_he_en_susa.fundability_code,
               p_spa_funding_source    => g_en_stdnt_ps_att.funding_source,
               p_poous_fund_cd         => g_he_poous.fundability_cd,
               p_prg_fund_cd           => g_he_st_prog.fundability,
               p_prg_funding_source    => g_field_defn.oss_value(64),
               p_oss_fund_cd           => g_field_defn.oss_value(65),
               p_hesa_fund_cd          => g_field_defn.hesa_value(65),
               p_enrl_start_dt         =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt           =>  g_he_submsn_header.enrolment_end_date);

          END IF;

          -- Now get the FE Student Marker
          --Included new param validation_country as a part of HEFD101

          IF  g_he_submsn_header.validation_country IN  ('ENGLAND','WALES') AND g_field_defn.oss_value.EXISTS(64) AND g_field_defn.oss_value.EXISTS(65) THEN
             igs_he_extract_fields_pkg.get_fe_stdnt_mrker
              (p_spa_fe_stdnt_mrker    =>  g_he_st_spa.fe_student_marker,
               p_fe_program_marker     =>  g_he_st_prog.fe_program_marker,
               p_funding_src           =>  g_field_defn.oss_value(64),
               p_fundability_cd        =>  g_field_defn.oss_value(65),
               p_oss_fe_stdnt_mrker    =>  g_field_defn.oss_value(6),
               p_hesa_fe_stdnt_mrker   =>  p_value);

           ELSE
             g_default_pro := 'N';
           END IF;

      ELSIF  p_field_number = 7
      THEN
          -- Family Name
          -- modified the logic to remove the invalid characters /, @, \ for Bug# 3681149
          -- smaddali added translate for bug#3223991
          -- this trasnlate function translates a to a and all other characters in the FROM list to NULL
          -- so all the characters 1234567890~`!#$%^&*()_+={}[]|:;"<>? which are invalid will be removed from p_value
          IF g_pe_person.given_names IS NULL
          THEN
              p_value := TRANSLATE( substr(g_pe_person.full_name,1,40),'a1234567890~`!#$%^&*()_+={}[]|:;"<>?,/@\','a');
              -- Set value of forename = '9'
              g_field_defn.hesa_value(8) := '9';
          ELSE
              p_value := TRANSLATE( substr(g_pe_person.surname,1,40),'a1234567890~`!#$%^&*()_+={}[]|:;"<>?,/@\','a');
          END IF;

      ELSIF  p_field_number = 8
      THEN
          -- Forename
          -- If value set earlier in field 7, use that
          -- modified the logic to remove the invalid characters /, @, \ for Bug# 3681149
          -- smaddali added translate for bug#3223991
          -- this trasnlate function translates a to a and all other characters in the FROM list to NULL
          -- so all the characters 1234567890~`!#$%^&*()_+={}[]|:;"<>? which are invalid will be removed from p_value
          IF g_field_defn.hesa_value.EXISTS(8)
          THEN
              IF g_field_defn.hesa_value(8) = '9'
              THEN
                   p_value := g_field_defn.hesa_value(8);
              ELSE
                   p_value := TRANSLATE( substr(g_pe_person.given_names,1,40),'a1234567890~`!#$%^&*()_+={}[]|:;"<>?,/@\','a');
              END IF;
          ELSE
              p_value := TRANSLATE( substr(g_pe_person.given_names,1,40),'a1234567890~`!#$%^&*()_+={}[]|:;"<>?,/@\','a');
          END IF;


      ELSIF  p_field_number = 9
      THEN
          -- Family Name on 16th Birthday
          -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
          l_fmly_name := NULL;
          igs_he_extract_fields_pkg.get_fmly_name_on_16_bday
              (p_person_id      => p_person_id,
               p_fmly_name      => l_fmly_name,
               p_enrl_start_dt  =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt    =>  g_he_submsn_header.enrolment_end_date);
          -- modified the logic to remove the invalid characters /, @, \ for Bug# 3681149
          -- smaddali added translate for bug#3223991
          -- this trasnlate function translates a to a and all other characters in the FROM list to NULL
          -- so all the characters 1234567890~`!#$%^&*()_+={}[]|:;"<>? which are invalid will be removed from p_value
          p_value := TRANSLATE( substr(l_fmly_name,1,40),'a1234567890~`!#$%^&*()_+={}[]|:;"<>?,/@\','a') ;

      ELSIF  p_field_number = 10
      THEN
          -- Date of Birth
          p_value := To_Char(g_pe_person.birth_dt, 'DD/MM/YYYY');

      ELSIF  p_field_number = 11
      THEN
          -- Gender
          igs_he_extract_fields_pkg.get_gender
              (p_gender           => g_pe_person.sex,
               p_hesa_gender      => p_value);

      ELSIF  p_field_number = 12
      THEN
          -- Domicile
          igs_he_extract_fields_pkg.get_domicile
              (p_ad_domicile       => g_he_ad_dtl.domicile_cd,
               p_spa_domicile      => g_he_st_spa.domicile_cd,
               p_hesa_domicile     => p_value);

      ELSIF  p_field_number = 13
      THEN
          -- Nationality
          -- smaddali 11-dec-03   Modified for bug#3235753 , added 1 new parameter
          igs_he_extract_fields_pkg.get_nationality
              (p_person_id         => p_person_id,
               p_nationality       => p_value,
               p_enrl_start_dt     =>  g_he_submsn_header.enrolment_start_date);

      -- Modified the field derivation to remove the reference of DOMICILE field (12)
      -- as part of HEFD311 - July 2004 Changes enhancement bug, 2956444
      ELSIF  p_field_number = 14
      THEN
         -- Ethnicity
         igs_he_extract_fields_pkg.get_ethnicity (
           p_person_id         => p_person_id,
           p_oss_eth           => g_pe_stat_v.ethnic_origin_id,
           p_hesa_eth          => p_value);

      ELSIF  p_field_number = 15
      THEN
          -- Disability Allowance
          igs_he_extract_fields_pkg.get_disablity_allow
              (p_oss_dis_allow     => g_he_en_susa.disability_allow,
               p_hesa_dis_allow    => p_value);

      ELSIF  p_field_number = 16
      THEN
          -- Diability
          -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
          igs_he_extract_fields_pkg.get_disablity
              (p_person_id         => p_person_id,
               p_disability        => p_value,
               p_enrl_start_dt     =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt       =>  g_he_submsn_header.enrolment_end_date);

      ELSIF  p_field_number = 17
      THEN

         -- Additional Support Band
         IF  ((g_field_defn.hesa_value.EXISTS(6) AND g_field_defn.hesa_value(6) IN (1,3))
               AND   g_he_submsn_header.validation_country = 'ENGLAND') THEN

               igs_he_extract_fields_pkg.get_addnl_supp_band
              (p_oss_supp_band     =>  g_he_en_susa.additional_sup_band,
               p_hesa_supp_band    =>  p_value);
          ELSE
              p_value := NULL;
              g_default_pro := 'N';
          END IF;

      ELSIF  p_field_number = 18
      THEN
           -- Not Used
           p_value := NULL;

      ELSIF  p_field_number = 19
      THEN

          --Get the field 41 value - Qualification Aim
          -- smaddali 21-jan-04  added 2 new parameters for bug#3360646
          igs_he_extract_fields_pkg.get_gen_qual_aim
              (p_person_id           =>  p_person_id,
               p_course_cd           =>  p_course_cd,
               p_version_number      =>  p_crv_version_number,
               p_spa_gen_qaim        =>  g_he_st_spa.student_qual_aim,
               p_hesa_gen_qaim       =>  g_field_defn.hesa_value(41),
               p_enrl_start_dt       =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt         =>  g_he_submsn_header.enrolment_end_date,
               p_awd_conf_start_dt   =>  l_awd_conf_start_dt);

          -- Get the field 70 value - Mode of Study
          igs_he_extract_fields_pkg.get_mode_of_study
              (p_person_id         =>  p_person_id,
               p_course_cd         =>  p_course_cd,
               p_version_number    =>  p_crv_version_number,
               p_enrl_start_dt     =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt       =>  g_he_submsn_header.enrolment_end_date,
               p_susa_study_mode   =>  g_he_en_susa.study_mode,
               p_poous_study_mode  =>  g_he_poous.mode_of_study,
               p_attendance_type   =>  g_en_stdnt_ps_att.attendance_type,
               p_mode_of_study     =>  g_field_defn.hesa_value(70));

          -- Modified the derivation of this field to derive regardless of the value of the HESA MODE field (70)
          -- as part of HEFD311 - July 2004 Changes enhancement bug, 2956444

          -- Get the field 148 value - UCAS NUM
          IF g_he_st_spa.associate_ucas_number = 'Y' THEN
            -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
            igs_he_extract_fields_pkg.get_ucasnum
               (p_person_id             => p_person_id,
                p_ucasnum               => g_field_defn.hesa_value(148),
                p_enrl_start_dt         =>  g_he_submsn_header.enrolment_start_date,
                p_enrl_end_dt           =>  g_he_submsn_header.enrolment_end_date);
            -- smaddali added else logic to create the table index for hesa_value(148), for bug#3370979
          ELSE
             g_field_defn.hesa_value(148) := NULL;
          END IF;

          IF  g_field_defn.hesa_value.EXISTS(148) AND g_field_defn.hesa_value.EXISTS(41) THEN
             -- Calculate the field 19 value - Year left last institution
             igs_he_extract_fields_pkg.get_yr_left_last_inst
              (p_person_id      => p_person_id,
               p_com_dt         => g_en_stdnt_ps_att.commencement_dt,
               p_hesa_gen_qaim  => g_field_defn.hesa_value(41),
               p_ucasnum        => g_field_defn.hesa_value(148),
               p_year           => p_value);
          END IF ;

      ELSIF  p_field_number = 20
      THEN
           -- Not Used
           p_value := NULL;

      ELSIF  p_field_number = 21
      THEN
          -- Highest Qualification on Entry
          p_value := g_he_st_spa.highest_qual_on_entry;

      ELSIF  p_field_number = 22
      THEN
           -- Not Used
           p_value := NULL;

      ELSIF  p_field_number = 23
      THEN
           -- Not Used
           p_value := NULL;

      ELSIF  p_field_number = 24
      THEN
           -- Not Used
           p_value := NULL;

      ELSIF  p_field_number = 25
      THEN

          -- Get the field 148 value - UCAS NUM
          IF NOT g_field_defn.hesa_value.EXISTS(148) THEN
             IF  g_he_st_spa.associate_ucas_number = 'Y' THEN
               igs_he_extract_fields_pkg.get_ucasnum
                  (p_person_id             => p_person_id,
                   p_ucasnum               => g_field_defn.hesa_value(148),
                   p_enrl_start_dt         =>  g_he_submsn_header.enrolment_start_date,
                   p_enrl_end_dt           =>  g_he_submsn_header.enrolment_end_date);
             ELSE
               g_field_defn.hesa_value(148) := NULL;
             END IF;
          END IF;

          -- sjlaporte use date comparison rather than text bug 3933715
          -- Occupation Code
          IF g_en_stdnt_ps_att.commencement_dt  <= TO_DATE('31/07/2002', 'DD/MM/YYYY')
             OR (g_field_defn.hesa_value(148) IS NOT NULL AND g_field_defn.hesa_value(148) BETWEEN '000000010' AND '019999999')
          THEN
              p_value := g_he_st_spa.occcode;
          ELSE
             p_value := NULL;
          END IF;

      ELSIF  p_field_number = 26
      THEN
         -- Commencement Date
         igs_he_extract_fields_pkg.get_commencement_dt( p_hesa_commdate         => g_he_st_spa.commencement_dt,
                                                        p_enstdnt_commdate      => g_en_stdnt_ps_att.commencement_dt,
                                                        p_person_id             => p_person_id ,
                                                        p_course_cd             => p_course_cd  ,
                                                        p_version_number        => p_crv_version_number,
                                                        p_student_inst_number   => p_student_inst_number,
                                                        p_final_commdate        => p_value );

      ELSIF  p_field_number = 27
      THEN
          -- New Entrant to HE
          -- smaddali removed the call to field 72 and added call to field30 for bug 2452551
          -- First get field 30, Year of student

         -- jbaber added p_susa_year_of_student for HEFD350
          igs_he_extract_fields_pkg.get_year_of_student
              (p_person_id            => p_person_id ,
               p_course_cd            => p_course_cd ,
               p_unit_set_cd          => g_as_su_setatmpt.unit_set_cd,
               p_sequence_number      => g_as_su_setatmpt.sequence_number,
               p_year_of_student      => g_field_defn.hesa_value(30),
               p_enrl_end_dt          => g_he_submsn_header.enrolment_end_date,
               p_susa_year_of_student => g_he_en_susa.year_stu);

          --get field 41 value also first as it is required for  this calculation
                    -- Qualification Aim
          IF NOT g_field_defn.hesa_value.EXISTS(41) THEN
            -- smaddali 21-jan-04  added 2 new parameters for bug#3360646
            igs_he_extract_fields_pkg.get_gen_qual_aim
              (p_person_id           =>  p_person_id,
               p_course_cd           =>  p_course_cd,
               p_version_number      =>  p_crv_version_number,
               p_spa_gen_qaim        =>  g_he_st_spa.student_qual_aim,
               p_hesa_gen_qaim       =>  g_field_defn.hesa_value(41),
               p_enrl_start_dt       =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt         =>  g_he_submsn_header.enrolment_end_date,
               p_awd_conf_start_dt   =>  l_awd_conf_start_dt);
          END IF ;



          -- Now calculate New Entrant to HE
          -- smaddali replaced the dependency on field 72 with field 30 for bug 2452551
          IF  g_field_defn.hesa_value.EXISTS(6)
          AND g_field_defn.hesa_value.EXISTS(21)
          AND g_field_defn.hesa_value.EXISTS(30)
          AND g_field_defn.hesa_value.EXISTS(12)
          AND
          (g_field_defn.hesa_value.EXISTS(41) and (
                                                    (g_field_defn.hesa_value(41) >= 02 and g_field_defn.hesa_value(41) <= 52)
                                                                                    OR
                                                     (g_field_defn.hesa_value(41) IN (61,62,97,98))
                                                   )
           )
          THEN
              igs_he_extract_fields_pkg.get_new_ent_to_he
                  (p_fe_stdnt_mrker        => g_field_defn.hesa_value(6),
                   p_susa_new_ent_to_he    => g_he_en_susa.new_he_entrant_cd,
                   p_yop                   => g_field_defn.hesa_value(30),
                   p_high_qual_on_ent      => g_field_defn.hesa_value(21),
                   p_domicile              => g_field_defn.hesa_value(12),
                   p_hesa_new_ent_to_he    => p_value);


            END IF;

            IF   (g_field_defn.hesa_value.EXISTS(41) and (
                                                    (g_field_defn.hesa_value(41) >= 02 and g_field_defn.hesa_value(41) <= 52)
                                                                                    OR
                                                     (g_field_defn.hesa_value(41) IN (61,62,97,98))
                                                   )  ) THEN
                  g_default_pro := 'Y' ;
             ELSE
                    -- The default value should not be calculated for  any other condition
                     g_default_pro := 'N' ;
             END IF;

      ELSIF  p_field_number = 28      THEN
          -- Special students
          igs_he_extract_fields_pkg.get_special_student
              (p_ad_special_student    => g_he_ad_dtl.special_student_cd,
               p_spa_special_student   => g_he_st_spa.special_student,
               p_oss_special_student   => g_field_defn.oss_value(28),
               p_hesa_special_student  => p_value);

      ELSIF  p_field_number = 29 THEN
         --get the quail1 field 37  and 38 value required in calculating field 29 value
         igs_he_extract_fields_pkg.get_qual_obtained
              (p_person_id        => p_person_id,
               p_course_cd        => p_course_cd,
               p_enrl_start_dt    => l_awd_conf_start_dt,
               p_enrl_end_dt      => l_awd_conf_end_dt,
               p_oss_qual_obt1    => g_field_defn.oss_value(37),
               p_oss_qual_obt2    => g_field_defn.oss_value(38),
               p_hesa_qual_obt1   => g_field_defn.hesa_value(37),
               p_hesa_qual_obt2   => g_field_defn.hesa_value(38),
               p_classification   => g_field_defn.hesa_value(39));

         --Calcualting field 53 fierst reuqured fro field 161 calcualtion
         -- Teacher Training Course Identifier
          igs_he_extract_fields_pkg.get_teach_train_crs_id
          (p_prg_ttcid            =>  g_he_st_prog.teacher_train_prog_id,
           p_spa_ttcid            =>  g_he_st_spa.teacher_train_prog_id,
           p_hesa_ttcid           =>  g_field_defn.hesa_value(53));


        --Calculating field 161 first required for field 29
        -- Outcome of ITT Program

       IF g_he_submsn_header.validation_country  IN   ('ENGLAND','WALES') THEN
                   igs_he_extract_fields_pkg.get_itt_outcome
                   (p_oss_itt_outcome     =>  g_he_st_spa.itt_prog_outcome,
                    p_teach_train_prg     =>  g_field_defn.hesa_value(53),
                    p_hesa_itt_outcome    =>  g_field_defn.hesa_value(161));
       END IF;

       --Set the default value of g_deafult_pro flag as N here as the default processing has to be done only in one case
       --for which it is done as written down
       g_default_pro := 'N' ;

     IF g_he_submsn_header.validation_country IN   ('ENGLAND','WALES','SCOTLAND') THEN
          -- Get the value
          IF g_he_st_spa.associate_teach_ref_num = 'Y'
          THEN
          -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
              igs_he_extract_fields_pkg.get_alt_pers_id
                  (p_person_id            => p_person_id,
                   p_id_type              => 'TEACH REF',
                   p_api_id               => p_value,
                   p_enrl_start_dt        =>  g_he_submsn_header.enrolment_start_date,
                   p_enrl_end_dt          =>  g_he_submsn_header.enrolment_end_date);
          END IF;
           --In case the value calculated above is NULL then calculate the defualt value
           IF p_value IS NULL THEN
             IF
              ( (g_field_defn.hesa_value.EXISTS(161)  AND   g_field_defn.hesa_value(161) = '1') OR
                ((g_field_defn.hesa_value.EXISTS(53)  AND g_field_defn.hesa_value(53) IN (1,6,7)) AND
                  ((g_field_defn.hesa_value.EXISTS(37)  AND g_field_defn.hesa_value(37) = 20) OR
                   (g_field_defn.hesa_value.EXISTS(38)  AND g_field_defn.hesa_value(38) = 20))))  THEN
                      g_default_pro := 'Y' ;
             END IF;
           END IF;
       END IF;




      ELSIF  p_field_number = 30
      THEN
          -- Year of Student
          --smaddali added this check to see if it already is calculated
          -- because of bug 2452551 where field 30 is being calculated for field 27
          IF  g_field_defn.hesa_value.EXISTS(30)
          THEN
              -- Calculated earlier, for field 27
              p_value :=   g_field_defn.hesa_value(30);

          ELSE

            -- jbaber added p_susa_year_of_student for HEFD350
            igs_he_extract_fields_pkg.get_year_of_student
              (p_person_id            => p_person_id,
               p_course_cd            => p_course_cd,
               p_unit_set_cd          => g_as_su_setatmpt.unit_set_cd,
               p_sequence_number      => g_as_su_setatmpt.sequence_number,
               p_year_of_student      => p_value,
               p_enrl_end_dt          => g_he_submsn_header.enrolment_end_date,
               p_susa_year_of_student => g_he_en_susa.year_stu);

          END IF ;

           --smaddali 01-jul-2002 lpadding with 0  for bug 2436769
             p_value := LPAD(p_value, 2,'0') ;




      ELSIF  p_field_number = 31
      THEN
          -- Term Time Accomodation
          -- Calculate field 71, location of study first
          igs_he_extract_fields_pkg.get_study_location
              (p_susa_study_location    => g_he_en_susa.study_location,
               p_poous_study_location   => g_he_poous.location_of_study,
               p_prg_study_location     => g_he_st_prog.location_of_study,
               p_oss_study_location     => g_field_defn.oss_value(71),
               p_hesa_study_location    => g_field_defn.hesa_value(71));

          -- Next calcualte TTA
          -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
          igs_he_extract_fields_pkg.get_term_time_acc
              (p_person_id            =>  p_person_id,
               p_susa_term_time_acc   =>  g_he_en_susa.term_time_accom,
               p_study_location       =>  g_field_defn.oss_value(71),
               p_hesa_term_time_acc   =>  p_value,
               p_enrl_start_dt        =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt          =>  g_he_submsn_header.enrolment_end_date);

      ELSIF  p_field_number = 32
      THEN
           -- Not Used
           p_value := NULL;
      ELSIF  p_field_number = 33
      THEN

          -- Reason for leaving institution
          igs_he_extract_fields_pkg.get_rsn_inst_left
              (p_person_id            => p_person_id,
               p_course_cd            => p_course_cd ,
               p_crs_req_comp_ind     => g_en_stdnt_ps_att.course_rqrmnt_complete_ind,
               p_crs_req_comp_dt      => g_en_stdnt_ps_att.course_rqrmnts_complete_dt,
               p_disc_reason_cd       => g_en_stdnt_ps_att.discontinuation_reason_cd,
               p_disc_dt              => g_en_stdnt_ps_att.discontinued_dt,
               p_enrl_start_dt        => l_awd_conf_start_dt,
               p_enrl_end_dt          => l_awd_conf_end_dt,
               p_rsn_inst_left        => p_value);

      ELSIF  p_field_number = 34
      THEN
          --Defualt value processing to be done only if field 6 value is in 1,3,4
          g_default_pro:= 'N';
          -- Completion Status
          -- Need Field 6, FE Student Marker to be completed
           --smaddali added new parameter p_course_cd to this call for bug 2396174
          IF  g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)
          THEN
              -- Calculate Completion Status
              igs_he_extract_fields_pkg.get_completion_status
                  (p_person_id            => p_person_id,
                   p_course_cd            => p_course_cd ,
                   p_susa_comp_status     => g_he_en_susa.completion_status,
                   p_fe_stdnt_mrker       => g_field_defn.hesa_value(6),
                   p_crs_req_comp_ind     => g_en_stdnt_ps_att.course_rqrmnt_complete_ind,
                   p_discont_date         => g_en_stdnt_ps_att.discontinued_dt,
                   p_hesa_comp_status     => p_value);

               g_default_pro:= 'Y';
          END IF;

      ELSIF  p_field_number = 35
      THEN -- DATELEFT - only report this field if SPA completed within current reporting period

          IF g_en_stdnt_ps_att.course_rqrmnt_complete_ind = 'Y'
          AND g_en_stdnt_ps_att.course_rqrmnts_complete_dt <= g_he_submsn_header.enrolment_end_date
          THEN -- report Completion Date
              p_value := To_Char(g_en_stdnt_ps_att.course_rqrmnts_complete_dt, 'DD/MM/YYYY');
          ELSIF g_en_stdnt_ps_att.discontinued_dt IS NOT NULL
            AND g_en_stdnt_ps_att.discontinued_dt <= g_he_submsn_header.enrolment_end_date
          THEN -- report Discontinuation Date
              p_value := To_Char(g_en_stdnt_ps_att.discontinued_dt, 'DD/MM/YYYY');
          END IF;

      ELSIF  p_field_number = 36
      THEN
          --Defualt value processing to be done only if field 6 value is in 1,3,4
          g_default_pro:= 'N';

          -- Good Standing Marker
          IF g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)
          THEN
              igs_he_extract_fields_pkg.get_good_stand_mrkr
                   (p_susa_good_st_mk      => g_he_en_susa.good_stand_marker,
                    p_fe_stdnt_mrker       => g_field_defn.hesa_value(6),
                    p_crs_req_comp_ind     => g_en_stdnt_ps_att.course_rqrmnt_complete_ind,
                    p_discont_date         => g_en_stdnt_ps_att.discontinued_dt,
                    p_hesa_good_st_mk      => p_value);
              g_default_pro:= 'Y';
          END IF;


      ELSIF  p_field_number = 37
      THEN
          -- Qualification Obtained 1
          -- Get fields 37, 38 and 39 together.
          IF  g_field_defn.hesa_value.EXISTS(37)
          THEN
              p_value :=  g_field_defn.hesa_value(37);
          ELSE
            igs_he_extract_fields_pkg.get_qual_obtained
              (p_person_id        => p_person_id,
               p_course_cd        => p_course_cd,
               p_enrl_start_dt    => l_awd_conf_start_dt,
               p_enrl_end_dt      => l_awd_conf_end_dt,
               p_oss_qual_obt1    => g_field_defn.oss_value(37),
               p_oss_qual_obt2    => g_field_defn.oss_value(38),
               p_hesa_qual_obt1   => p_value,
               p_hesa_qual_obt2   => g_field_defn.hesa_value(38),
               p_classification   => g_field_defn.hesa_value(39));
          END IF ;

      ELSIF  p_field_number = 38
      THEN
          -- Qualification Obtained 2
          -- If not calculated earlier, calculate now.
          IF  g_field_defn.hesa_value.EXISTS(38)
          THEN
              p_value :=  g_field_defn.hesa_value(38);
          ELSE
              igs_he_extract_fields_pkg.get_qual_obtained
                  (p_person_id        => p_person_id,
                   p_course_cd        => p_course_cd,
                 p_enrl_start_dt    => l_awd_conf_start_dt,
                 p_enrl_end_dt      => l_awd_conf_end_dt,
                   p_oss_qual_obt1    => g_field_defn.oss_value(37),
                   p_oss_qual_obt2    => g_field_defn.oss_value(38),
                   p_hesa_qual_obt1   => g_field_defn.hesa_value(37),
                   p_hesa_qual_obt2   => p_value,
                   p_classification   => g_field_defn.hesa_value(39));

          END IF;

      ELSIF  p_field_number = 39
      THEN
          -- HESA Classification
          -- If not calculated earlier, calculate now.
          IF  g_field_defn.hesa_value.EXISTS(39)
          THEN
              p_value :=  g_field_defn.hesa_value(39);
          ELSE
              igs_he_extract_fields_pkg.get_qual_obtained
                  (p_person_id        => p_person_id,
                   p_course_cd        => p_course_cd,
                 p_enrl_start_dt    => l_awd_conf_start_dt,
                 p_enrl_end_dt      => l_awd_conf_end_dt,
                   p_oss_qual_obt1    => g_field_defn.oss_value(37),
                   p_oss_qual_obt2    => g_field_defn.oss_value(38),
                   p_hesa_qual_obt1   => g_field_defn.hesa_value(37),
                   p_hesa_qual_obt2   => g_field_defn.hesa_value(38),
                   p_classification   => p_value);

          END IF;

      ELSIF  p_field_number = 40
      THEN
          -- Program of Study Title
          p_value := g_ps_ver.title;

      ELSIF  p_field_number = 41
      THEN

          IF  g_field_defn.hesa_value.EXISTS(41)
          THEN
              -- Calculated earlier, for field 27
              p_value :=   g_field_defn.hesa_value(41);

          ELSE

          -- Qualification Aim
          -- smaddali 21-jan-04  added 2 new parameters for bug#3360646
              igs_he_extract_fields_pkg.get_gen_qual_aim
               (p_person_id           =>  p_person_id,
                p_course_cd           =>  p_course_cd,
                p_version_number      =>  p_crv_version_number,
                p_spa_gen_qaim        =>  g_he_st_spa.student_qual_aim,
                p_hesa_gen_qaim       =>  p_value,
                p_enrl_start_dt       =>  g_he_submsn_header.enrolment_start_date,
                p_enrl_end_dt         =>  g_he_submsn_header.enrolment_end_date,
                p_awd_conf_start_dt   =>  l_awd_conf_start_dt);

          END IF;

      ELSIF  p_field_number = 42
      THEN
          --Defualt value processing to be done only if field 6 value is in 1,3,4
          g_default_pro:= 'N';


          -- FE General Qualification Aim
         IF g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)
          THEN
              igs_he_extract_fields_pkg.get_fe_qual_aim
                   (p_spa_fe_qual_aim      => g_he_st_spa.student_fe_qual_aim,
                    p_fe_stdnt_mrker       => g_field_defn.hesa_value(6),
                    p_course_cd            => p_course_cd,
                    p_version_number       => p_crv_version_number,
                    p_hesa_fe_qual_aim     => p_value);

              g_default_pro:= 'Y';
         END IF;


      ELSIF  p_field_number = 43
      THEN

           -- Check for details at the SPA HESA Details level
           IF g_he_st_spa.qual_aim_subj1 IS NOT NULL THEN
                 OPEN c_subj(g_he_st_spa.qual_aim_subj1);
                 FETCH c_subj INTO p_value;
                 CLOSE c_subj;
           ELSE
             -- Qualification Aim, Subject 1
             igs_he_extract_fields_pkg.get_qual_aim_sbj
               (p_course_cd            => p_course_cd,
                p_version_number       => p_crv_version_number,
                p_subject1             => p_value,
                p_subject2             => g_field_defn.hesa_value(44),
                p_subject3             => g_field_defn.hesa_value(45),
                p_prop_ind             => g_field_defn.hesa_value(46));
           END IF;



      ELSIF  p_field_number = 44
      THEN

            -- Check for details at the SPA HESA Details level
            IF g_he_st_spa.qual_aim_subj1 IS NOT NULL THEN

                IF g_he_st_spa.qual_aim_subj2 IS NOT NULL THEN
                     OPEN c_subj(g_he_st_spa.qual_aim_subj2);
                     FETCH c_subj INTO p_value;
                     CLOSE c_subj;
                ELSE
                    -- derive NULL as there is no value for subj2
                    p_value := NULL;
                END IF;

           ELSE

              -- Qualification Aim, Subject 2
              IF g_field_defn.hesa_value.EXISTS(44)
              THEN
                 -- Calculated earlier..
                 p_value := g_field_defn.hesa_value(44);
              ELSE
                 -- Not calculated earlier, calculate now
                 igs_he_extract_fields_pkg.get_qual_aim_sbj
                  (p_course_cd         => p_course_cd,
                   p_version_number    => p_crv_version_number,
                   p_subject1          => l_dummy1,
                   p_subject2          => p_value,
                   p_subject3          => g_field_defn.hesa_value(45),
                   p_prop_ind          => g_field_defn.hesa_value(46));
              END IF;

           END IF;


      ELSIF  p_field_number = 45
      THEN

           -- Check for details at the SPA HESA Details level
           IF g_he_st_spa.qual_aim_subj1 IS NOT NULL THEN

                IF g_he_st_spa.qual_aim_subj3 IS NOT NULL THEN
                    OPEN c_subj(g_he_st_spa.qual_aim_subj3);
                    FETCH c_subj INTO p_value;
                    CLOSE c_subj;
                ELSE
                    -- derive NULL as there is no value for subj3
                    p_value := NULL;
                END IF;

           ELSE
             -- Qualification Aim, Subject 3
             IF g_field_defn.hesa_value.EXISTS(45)
             THEN
                 -- Calculated earlier..
                 p_value := g_field_defn.hesa_value(45);
             ELSE
                 -- Not calculated earlier, calculate now
                 igs_he_extract_fields_pkg.get_qual_aim_sbj
                  (p_course_cd         => p_course_cd,
                   p_version_number    => p_crv_version_number,
                   p_subject1          => l_dummy1,
                   p_subject2          => l_dummy2,
                   p_subject3          => p_value,
                   p_prop_ind          => g_field_defn.hesa_value(46));
             END IF;
           END IF;

      ELSIF  p_field_number = 46
      THEN

          IF g_he_st_spa.qual_aim_subj1 IS NOT NULL OR
             g_he_st_spa.qual_aim_proportion IS NOT NULL OR
             g_he_st_spa.qual_aim_subj2 IS NOT NULL OR
             g_he_st_spa.qual_aim_subj3 IS NOT NULL
          THEN

              igs_he_extract_fields_pkg.get_qual_aim_sbj1(
                     p_qual_aim_subj1    => g_he_st_spa.qual_aim_subj1,
                     p_qual_aim_subj2    => g_he_st_spa.qual_aim_subj2,
                     p_qual_aim_subj3    => g_he_st_spa.qual_aim_subj3,
                     p_oss_qualaim_sbj   => g_he_st_spa.qual_aim_proportion,
                     p_hesa_qualaim_sbj  => p_value);

          ELSE
                  -- Proportion Indicator
                  IF g_field_defn.hesa_value.EXISTS(46)
                  THEN
                      -- Calculated earlier..
                      p_value := g_field_defn.hesa_value(46);
                  ELSE
                      -- Not calculated earlier, calculate now
                      igs_he_extract_fields_pkg.get_qual_aim_sbj
                          (p_course_cd         => p_course_cd,
                           p_version_number    => p_crv_version_number,
                           p_subject1          => l_dummy1,
                           p_subject2          => l_dummy2,
                           p_subject3          => l_dummy3,
                           p_prop_ind          => p_value);
                  END IF;
          END IF;

      ELSIF  p_field_number = 47
      THEN
          -- Awarding Body 1
          IF  g_field_defn.oss_value.EXISTS(37)
          AND g_field_defn.oss_value.EXISTS(38)
          THEN
              igs_he_extract_fields_pkg.get_awd_body_12
                  (p_course_cd         =>  p_course_cd,
                   p_version_number    =>  p_crv_version_number,
                   p_awd1              =>  g_field_defn.oss_value(37),
                   p_awd2              =>  g_field_defn.oss_value(38),
                   p_awd_body1         =>  p_value,
                   p_awd_body2         =>  g_field_defn.hesa_value(48));

          END IF;

      ELSIF  p_field_number = 48
      THEN
          -- Awarding Body 2
          IF g_field_defn.hesa_value.EXISTS(48)
          THEN
              -- Calculated earlier for field 47..
              p_value := g_field_defn.hesa_value(48);
          ELSIF  g_field_defn.oss_value.EXISTS(37)
          AND    g_field_defn.oss_value.EXISTS(38)
          THEN
              -- Not calculated therefore calculate.
              igs_he_extract_fields_pkg.get_awd_body_12
                  (p_course_cd         =>  p_course_cd,
                   p_version_number    =>  p_crv_version_number,
                   p_awd1              =>  g_field_defn.oss_value(37),
                   p_awd2              =>  g_field_defn.oss_value(38),
                   p_awd_body1         =>  g_field_defn.hesa_value(47),
                   p_awd_body2         =>  p_value);

          END IF;

      ELSIF  p_field_number = 49
      THEN
          -- Length of Program
          igs_he_extract_fields_pkg.get_new_prog_length
          (p_spa_attendance_type           =>  g_en_stdnt_ps_att.attendance_type,
           p_program_length                => g_ps_ofr_opt.program_length,
           p_program_length_measurement    => g_ps_ofr_opt.program_length_measurement,
           p_length                        =>  p_value,
           p_units                         =>  g_field_defn.hesa_value(50));


            --smaddali 01-jul-2002 lpadding with 0  for bug 2436769
            p_value := LPAD(p_value, 2,'0') ;

      ELSIF  p_field_number = 50
      THEN

          -- Units of length of Program
        IF g_field_defn.hesa_value.EXISTS(50)
        THEN
           -- Calculated Earlier ..
           p_value := g_field_defn.hesa_value(50);
        ELSE
           -- Not calculated earlier ..
           igs_he_extract_fields_pkg.get_new_prog_length
          (p_spa_attendance_type           =>  g_en_stdnt_ps_att.attendance_type,
           p_program_length                => g_ps_ofr_opt.program_length,
           p_program_length_measurement    => g_ps_ofr_opt.program_length_measurement,
           p_length                        =>  g_field_defn.hesa_value(49),
           p_units                         => p_value);

        END IF;

      -- This field is classified as 'Not Used' by HESA
      -- Removed the call to the procedure, get_voc_lvl
      -- as part of HEFD311 - July 2004 Changes enhancement bug, 2956444
      ELSIF  p_field_number = 51
      THEN

         -- Not Used
         p_value := NULL;

      ELSIF  p_field_number = 52
      THEN
          -- Spcial Programmes
          p_value := g_ps_ver.govt_special_course_type;

      ELSIF  p_field_number = 53
      THEN
          IF g_field_defn.hesa_value.EXISTS(53)
          THEN
              -- Calculated Earlier ..
              p_value := g_field_defn.hesa_value(53);
          ELSE
              -- Not calculated earlier ..
              -- Teacher Training Course Identifier
              igs_he_extract_fields_pkg.get_teach_train_crs_id
               (p_prg_ttcid            =>  g_he_st_prog.teacher_train_prog_id,
                p_spa_ttcid            =>  g_he_st_spa.teacher_train_prog_id,
                p_hesa_ttcid           =>  p_value);
          END IF;

      ELSIF  p_field_number = 54
      THEN

             IF (g_he_submsn_header.validation_country  in ('ENGLAND','WALES')  AND ( g_field_defn.hesa_value.EXISTS(53)   and g_field_defn.hesa_value(53)  IN(1,2,6,7) ))   THEN
                  -- ITT Phase / Scope
                  igs_he_extract_fields_pkg.get_itt_phsc
                      (p_prg_itt_phsc        =>  g_he_st_prog.itt_phase,
                       p_spa_itt_phsc        =>  g_he_st_spa.itt_phase,
                       p_hesa_itt_phsc       =>  p_value);

             ELSE
                  g_default_pro:= 'N';
             END IF;

      ELSIF  p_field_number = 55
      THEN

               IF (g_he_submsn_header.validation_country  in ('SCOTLAND','WALES','NORTHERN IRELAND')   AND ( g_field_defn.hesa_value.EXISTS(53) AND g_field_defn.hesa_value(53)  IN(1,2)) )   THEN
                  -- Bilingual ITT Marker
                  igs_he_extract_fields_pkg.get_itt_mrker
                      (p_prg_itt_mrker       =>  g_he_st_prog.bilingual_itt_marker,
                       p_spa_itt_mrker       =>  g_he_st_spa.bilingual_itt_marker,
                       p_hesa_itt_mrker      =>  p_value);


                ELSE
                  g_default_pro:= 'N';
               END IF;

      ELSIF  p_field_number = 56
      THEN

                IF ( g_he_submsn_header.validation_country IN ('SCOTLAND','NORTHERN IRELAND')  AND ( g_field_defn.hesa_value.EXISTS(53) and g_field_defn.hesa_value(53)  IN(1,2) ) )   THEN
                  -- Teaching Qualification Sought Sector
                  igs_he_extract_fields_pkg.get_teach_qual_sect
                      (p_oss_teach_qual_sect   => g_he_st_prog.teaching_qual_sought_sector,
                       p_hesa_teach_qual_sect  => p_value);

                ELSE
                  g_default_pro:= 'N';
               END IF;

      ELSIF  p_field_number = 57
      THEN
               IF ( g_he_submsn_header.validation_country = 'SCOTLAND'  AND ( g_field_defn.hesa_value.EXISTS(56)  AND g_field_defn.hesa_value(56)  =2  ) )  THEN
                  -- Teaching Qualification Sought Subject 1
                  igs_he_extract_fields_pkg.get_teach_qual_sbj
                      (p_oss_teach_qual_sbj     =>  g_he_st_prog.teaching_qual_sought_subj1,
                       p_hesa_teach_qual_sbj    =>  p_value);


              ELSE
                  g_default_pro:= 'N';
              END IF;


      ELSIF  p_field_number = 58
      THEN
              IF ( g_he_submsn_header.validation_country = 'SCOTLAND'  AND ( g_field_defn.hesa_value.EXISTS(56)  AND g_field_defn.hesa_value(56)  =2 ))   THEN
                  -- Teaching Qualification Sought Subject 2
                  igs_he_extract_fields_pkg.get_teach_qual_sbj
                      (p_oss_teach_qual_sbj     =>  g_he_st_prog.teaching_qual_sought_subj2,
                       p_hesa_teach_qual_sbj    =>  p_value);
               ELSE
                  g_default_pro:= 'N';
              END IF;

      ELSIF  p_field_number = 59
      THEN
              IF ( g_he_submsn_header.validation_country = 'SCOTLAND'  AND ( g_field_defn.hesa_value.EXISTS(56) AND g_field_defn.hesa_value(56)  =2  ))   THEN
                  -- Teaching Qualification Sought Subject 3
                  igs_he_extract_fields_pkg.get_teach_qual_sbj
                      (p_oss_teach_qual_sbj     =>  g_he_st_prog.teaching_qual_sought_subj3,
                       p_hesa_teach_qual_sbj    =>  p_value);
              ELSE
                  g_default_pro:= 'N';
              END IF;

      ELSIF  p_field_number = 60
      THEN

              IF ( g_he_submsn_header.validation_country IN ('SCOTLAND' , 'NORTHERN IRELAND' )  AND ( g_field_defn.hesa_value.EXISTS(53) AND g_field_defn.hesa_value(53)  in (1,2)) )   THEN
                  -- Teaching Qualification Gained Sector
                  igs_he_extract_fields_pkg.get_teach_qual_sect
                      (p_oss_teach_qual_sect   => g_he_st_spa.teaching_qual_gain_sector,
                       p_hesa_teach_qual_sect  => p_value);

                  IF p_value IS NULL
                  AND g_en_stdnt_ps_att.course_rqrmnts_complete_dt IS NOT NULL
                  AND g_field_defn.hesa_value.EXISTS(56)
                  THEN
                      p_value := g_field_defn.hesa_value(56);
                  END IF;
              ELSE
                  g_default_pro:= 'N';
              END IF;

      ELSIF  p_field_number = 61
      THEN

              IF        (g_he_submsn_header.validation_country = 'SCOTLAND'    AND ( g_field_defn.hesa_value.EXISTS(60)  AND g_field_defn.hesa_value(60) = 2 ) ) THEN
                  -- Teaching Qualification Gained Subject 1
                  igs_he_extract_fields_pkg.get_teach_qual_sbj
                      (p_oss_teach_qual_sbj     =>  g_he_st_spa.teaching_qual_gain_subj1,
                       p_hesa_teach_qual_sbj    =>  p_value);

                  IF p_value IS NULL
                  AND g_en_stdnt_ps_att.course_rqrmnts_complete_dt IS NOT NULL
                  AND g_field_defn.hesa_value.EXISTS(57)
                  THEN
                      p_value := g_field_defn.hesa_value(57);
                  END IF;
              ELSE
                  g_default_pro:= 'N';
              END IF;

      ELSIF  p_field_number = 62
      THEN
              IF       (g_he_submsn_header.validation_country = 'SCOTLAND'   AND ( g_field_defn.hesa_value.EXISTS(60) AND g_field_defn.hesa_value(60) = 2 ) ) THEN
                  -- Teaching Qualification Gained Subject 2
                  igs_he_extract_fields_pkg.get_teach_qual_sbj
                      (p_oss_teach_qual_sbj     =>  g_he_st_spa.teaching_qual_gain_subj2,
                       p_hesa_teach_qual_sbj    =>  p_value);

                  IF p_value IS NULL
                  AND g_en_stdnt_ps_att.course_rqrmnts_complete_dt IS NOT NULL
                  AND g_field_defn.hesa_value.EXISTS(58)
                  THEN
                      p_value := g_field_defn.hesa_value(58);
                  END IF;

              ELSE
                  g_default_pro:= 'N';
              END IF;

      ELSIF  p_field_number = 63
      THEN

              IF        (g_he_submsn_header.validation_country = 'SCOTLAND'  AND ( g_field_defn.hesa_value.EXISTS(60) AND g_field_defn.hesa_value(60) = 2 ) ) THEN
                  -- Teaching Qualification Gained Subject 3
                  igs_he_extract_fields_pkg.get_teach_qual_sbj
                      (p_oss_teach_qual_sbj     =>  g_he_st_spa.teaching_qual_gain_subj3,
                       p_hesa_teach_qual_sbj    =>  p_value);

                  IF p_value IS NULL
                  AND g_en_stdnt_ps_att.course_rqrmnts_complete_dt IS NOT NULL
                  AND g_field_defn.hesa_value.EXISTS(59)
                  THEN
                      p_value := g_field_defn.hesa_value(59);
                  END IF;


              ELSE
                  g_default_pro:= 'N';
              END IF;


      ELSIF  p_field_number = 64
      THEN
          -- Major Source of Funding
          IF  g_field_defn.hesa_value.EXISTS(64)
          THEN
              -- Calculated earlier, for field 6
              p_value :=   g_field_defn.hesa_value(64);
          ELSE
              -- Not calculated earlier.
              -- smaddali modified this call to pass funding_source field for hefd208 - bug#2717751
              -- jtmathew modified this call to pass funding_source at spa level - bug#3962575
              igs_he_extract_fields_pkg.get_funding_src
                  (p_course_cd             => p_course_cd,
                   p_version_number        => p_crv_version_number,
                   p_spa_fund_src          => g_en_stdnt_ps_att.funding_source,
                   p_poous_fund_src        => g_he_poous.funding_source,
                   p_oss_fund_src          => g_field_defn.oss_value(64),
                   p_hesa_fund_src         => p_value);
          END IF;

      ELSIF  p_field_number = 65
      THEN
          -- Fundability Code
          IF  g_field_defn.hesa_value.EXISTS(65)
          THEN
              -- Calculated earlier, for field 6
              p_value :=   g_field_defn.hesa_value(65);
          ELSE
              -- Not calculated earlier, hence derive
              IF  g_field_defn.oss_value.EXISTS(64)
              THEN
                  -- Next get the Fundability Code
                  -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
                  igs_he_extract_fields_pkg.get_fundability_cd
                      (p_person_id             => p_person_id,
                       p_susa_fund_cd          => g_he_en_susa.fundability_code,
                       p_spa_funding_source    => g_en_stdnt_ps_att.funding_source,
                       p_poous_fund_cd         => g_he_poous.fundability_cd,
                       p_prg_fund_cd           => g_he_st_prog.fundability,
                       p_prg_funding_source    => g_field_defn.oss_value(64),
                       p_oss_fund_cd           => g_field_defn.oss_value(65),
                       p_hesa_fund_cd          => p_value,
                       p_enrl_start_dt         =>  g_he_submsn_header.enrolment_start_date,
                       p_enrl_end_dt           =>  g_he_submsn_header.enrolment_end_date);
              ELSE
                  p_value := NULL;
              END IF;

          END IF; -- Not calculated earlier

      ELSIF  p_field_number = 66
      THEN
          -- smaddali modified value passed to p_study_mode for bug 2367167
          -- Fee Eligibility
          IF   g_field_defn.oss_value.EXISTS(6)
          AND  g_field_defn.oss_value.EXISTS(28)
          THEN
          -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
              igs_he_extract_fields_pkg.get_fee_elig
                  (p_person_id          =>  p_person_id,
                   p_susa_fee_elig      =>  g_he_en_susa.fee_eligibility,
                   p_fe_stdnt_mrker     =>  g_field_defn.oss_value(6),
                   p_study_mode         =>  NVL(g_he_en_susa.study_mode,NVL(g_he_poous.mode_of_study,g_en_stdnt_ps_att.attendance_type)) ,
                   p_special_student    =>  g_field_defn.oss_value(28),
                   p_hesa_fee_elig      =>  p_value,
                   p_enrl_start_dt      =>  g_he_submsn_header.enrolment_start_date,
                   p_enrl_end_dt        =>  g_he_submsn_header.enrolment_end_date);
          ELSE
          -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
              igs_he_extract_fields_pkg.get_fee_elig
                  (p_person_id          =>  p_person_id,
                   p_susa_fee_elig      =>  g_he_en_susa.fee_eligibility,
                   p_fe_stdnt_mrker     =>  NULL,
                   p_study_mode         =>  NVL(g_he_en_susa.study_mode,NVL(g_he_poous.mode_of_study,g_en_stdnt_ps_att.attendance_type)),
                   p_special_student    =>  NULL,
                   p_hesa_fee_elig      =>  p_value,
                   p_enrl_start_dt      =>  g_he_submsn_header.enrolment_start_date,
                   p_enrl_end_dt        =>  g_he_submsn_header.enrolment_end_date);
          END IF;

      ELSIF  p_field_number = 67
      THEN
          -- Fee Band
          IF   g_field_defn.hesa_value.EXISTS(66) THEN
              igs_he_extract_fields_pkg.get_fee_band
                  (p_hesa_fee_elig     =>  g_field_defn.hesa_value(66),
                   p_susa_fee_band     =>  g_he_en_susa.fee_band,
                   p_poous_fee_band    =>  g_he_poous.fee_band,
                   p_prg_fee_band      =>  g_he_st_prog.fee_band,
                   p_hesa_fee_band     =>  p_value);
          ELSE

              igs_he_extract_fields_pkg.get_fee_band
                  (p_hesa_fee_elig     =>  NULL,
                   p_susa_fee_band     =>  g_he_en_susa.fee_band,
                   p_poous_fee_band    =>  g_he_poous.fee_band,
                   p_prg_fee_band      =>  g_he_st_prog.fee_band,
                   p_hesa_fee_band     =>  p_value);

          END IF;

      ELSIF  p_field_number = 68
      THEN
          -- Major Source of Tuition Fees
          -- Calculate amount of tuition Fees first
          IF   NOT g_field_defn.hesa_value.EXISTS(6)
          THEN
              g_field_defn.hesa_value(6) := NULL;
          END IF;

          -- smaddali 14-oct-03 added 2 new parameters to the procedure get_amt_tuition_fees, for bug#3179544
          IF   g_field_defn.hesa_value.EXISTS(6)
          AND  g_field_defn.hesa_value.EXISTS(28)
          THEN
              igs_he_extract_fields_pkg.get_amt_tuition_fees
                  (p_person_id         =>  p_person_id,
                   p_course_cd         =>  p_course_cd,
                   p_cal_type          =>  g_en_stdnt_ps_att.cal_type,
                   p_fe_prg_mrker      =>  g_he_st_prog.fe_program_marker,
                   p_fe_stdnt_mrker    =>  g_field_defn.hesa_value(6),
                   p_oss_amt           =>  g_field_defn.oss_value(83),
                   p_hesa_amt          =>  g_field_defn.hesa_value(83),
                   p_enrl_start_dt     =>  g_he_submsn_header.enrolment_start_date,
                   p_enrl_end_dt       =>  g_he_submsn_header.enrolment_end_date
                   );

              -- Calculate Mode of Study
              IF NOT g_field_defn.hesa_value.EXISTS(70) THEN
                 igs_he_extract_fields_pkg.get_mode_of_study
                  (p_person_id         =>  p_person_id,
                   p_course_cd         =>  p_course_cd,
                   p_version_number    =>  p_crv_version_number,
                   p_enrl_start_dt     =>  g_he_submsn_header.enrolment_start_date,
                   p_enrl_end_dt       =>  g_he_submsn_header.enrolment_end_date,
                   p_susa_study_mode   =>  g_he_en_susa.study_mode,
                   p_poous_study_mode  =>  g_he_poous.mode_of_study,
                   p_attendance_type   =>  g_en_stdnt_ps_att.attendance_type,
                   p_mode_of_study     =>  g_field_defn.hesa_value(70));
              END IF ;

              -- Now calculate the major source of tuition fees
              igs_he_extract_fields_pkg.get_maj_src_tu_fee
                  (p_person_id         =>  p_person_id,
                   p_enrl_start_dt     =>  g_he_submsn_header.enrolment_start_date,
                   p_enrl_end_dt       =>  g_he_submsn_header.enrolment_end_date,
                   p_special_stdnt     =>  g_field_defn.hesa_value(28),
                   p_study_mode        =>  g_field_defn.hesa_value(70),
                   p_amt_tu_fee        =>  g_field_defn.oss_value(83),
                   p_susa_mstufee      =>  g_he_en_susa.student_fee,
                   p_hesa_mstufee      =>  p_value);
          END IF;


      ELSIF  p_field_number = 69
      THEN
          -- Not Used
          p_value := NULL;

      ELSIF  p_field_number = 70
      THEN
          -- Mode of Studying
          IF  g_field_defn.hesa_value.EXISTS(70)
          THEN
              -- Calculated earlier, for field 68
              p_value :=   g_field_defn.hesa_value(70);
          ELSE
              igs_he_extract_fields_pkg.get_mode_of_study
                  (p_person_id         =>  p_person_id,
                   p_course_cd         =>  p_course_cd,
                   p_version_number    =>  p_crv_version_number,
                   p_enrl_start_dt     =>  g_he_submsn_header.enrolment_start_date,
                   p_enrl_end_dt       =>  g_he_submsn_header.enrolment_end_date,
                   p_susa_study_mode   =>  g_he_en_susa.study_mode,
                   p_poous_study_mode  =>  g_he_poous.mode_of_study,
                   p_attendance_type   =>  g_en_stdnt_ps_att.attendance_type,
                   p_mode_of_study     =>  p_value);

          END IF;

      ELSIF  p_field_number = 71
      THEN
          -- Location of Study
          IF  g_field_defn.hesa_value.EXISTS(71)
          THEN
              -- Calculated earlier, for field 31
              p_value :=   g_field_defn.hesa_value(71);
          ELSE
              -- Not calculated earlier, hence derive
              igs_he_extract_fields_pkg.get_study_location
                  (p_susa_study_location    => g_he_en_susa.study_location,
                   p_poous_study_location   => g_he_poous.location_of_study,
                   p_prg_study_location     => g_he_st_prog.location_of_study,
                   p_oss_study_location     => g_field_defn.oss_value(71),
                   p_hesa_study_location    => p_value);
          END IF;

      ELSIF  p_field_number = 72
      THEN
           -- Year of Program
          IF  g_field_defn.hesa_value.EXISTS(72)
          THEN
              p_value :=   g_field_defn.hesa_value(72);
          ELSE
              -- Not calculated earlier, hence derive
              igs_he_extract_fields_pkg.get_year_of_prog
                  (p_unit_set_cd          => g_as_su_setatmpt.unit_set_cd,
                   p_year_of_prog         => p_value);

          END IF;

          -- To send to HESA Lpad with 0
          p_value := LPAD(p_value,2,'0');

      ELSIF  p_field_number = 73
      THEN
          -- Length of current year of program
          --smaddali adding LPAD '0' for bug 2437081
          p_value := LPAD(g_he_poous.leng_current_year,2,'0');

      ELSIF  p_field_number = 74
      THEN
          -- Included the below code as a part of HECR001(bug number 2278825)
          -- smaddali added the ltrim and changed format mask from 999.9 to 000.0 for bug 2431845
          -- jtmathew added the check for whether SUSA finishes before the start of reporting period

          IF g_he_en_susa.fte_perc_override  IS NOT NULL THEN
                  p_value := Ltrim(To_Char(g_he_en_susa.fte_perc_override,'000.0'));
          ELSE
              IF g_as_su_setatmpt.rqrmnts_complete_dt IS NOT NULL AND
                 g_as_su_setatmpt.rqrmnts_complete_dt <  g_he_submsn_header.enrolment_start_date
              THEN -- Report FTE of 000.0 as the unit set does not fit within the reporting period
                  p_value := Ltrim(To_Char(0,'000.0'));
              ELSE
                  p_value := Ltrim(To_Char(g_he_en_susa.calculated_fte,'000.0'));
              END IF;
          END IF;

      ELSIF  p_field_number = 75
      THEN

          IF g_field_defn.hesa_value.EXISTS(12) AND  g_field_defn.hesa_value(12) IN ('8826','5826','6826','7826','2826','3826','4826')
          THEN
                  p_value := g_he_st_spa.postcode;

          ELSE
                  g_default_pro:= 'N';

          END IF;

      ELSIF  p_field_number = 76
      THEN
          -- PGCE - Subject of Undergraduate Degree
          -- smaddali added call to the new local procedure for bug 2452592
          IF g_field_defn.hesa_value.EXISTS(41) AND g_field_defn.hesa_value(41) IN ('12','13')
          THEN
              igs_he_extract2_pkg.get_pgce_subj
              (p_person_id         =>  p_person_id,
               p_pgce_subj        =>  p_value);
          ELSE
              p_value := NULL ;
          END IF ;

      ELSIF  p_field_number = 77
      THEN
          -- PGCE - Classification  of Undergraduate Degree
          --smaddali added the dependency on field41 for bug 2436924
          IF g_field_defn.hesa_value.EXISTS(41) AND g_field_defn.hesa_value(41) IN ('12','13')
          THEN
              igs_he_extract_fields_pkg.get_pgce_class
              (p_person_id         =>  p_person_id,
               p_pgce_class        =>  p_value);
          ELSE
              p_value := NULL ;
          END IF ;

      ELSIF  p_field_number = 78
      THEN

        IF (g_he_submsn_header.validation_country  = 'NORTHERN IRELAND'  AND ( g_field_defn.hesa_value.EXISTS(12) AND  g_field_defn.hesa_value(12) = '8826')) THEN
          -- Religion
          igs_he_extract_fields_pkg.get_religion
          (p_oss_religion     =>  g_pe_stat_v.religion,
           p_hesa_religion    =>  p_value);

        ELSE
          g_default_pro := 'N';
        END IF;


      ELSIF  p_field_number = 79
      THEN
          -- Not used
          p_value := NULL;

      ELSIF  p_field_number = 80
      THEN
          -- Not used
          p_value := NULL;

      ELSIF  p_field_number = 81
      THEN
          -- SLDD Discrete Provision
          IF g_field_defn.hesa_value.EXISTS(6)
          THEN
              igs_he_extract_fields_pkg.get_sldd_disc_prv
                  (p_oss_sldd_disc_prv     =>  g_he_en_susa.sldd_discrete_prov,
                   p_fe_stdnt_mrker        =>  g_field_defn.hesa_value(6),
                   p_hesa_sldd_disc_prv    =>  p_value);
          END IF;

      ELSIF  p_field_number = 82
      THEN
          -- Not used
          p_value := NULL;

      ELSIF  p_field_number = 83
      THEN
        -- The default value processng to be done only if field 6 is in 1,3,4
         g_default_pro:= 'N';

         IF g_field_defn.hesa_value.EXISTS(6) AND g_field_defn.hesa_value(6) IN (1,3,4)     THEN

          -- Amount of Tuition fees expected
          IF g_field_defn.hesa_value.EXISTS(83)
          THEN
              -- Calculated earlier. No need to derive
              p_value := g_field_defn.hesa_value(83);
          ELSE

              -- Not calculated earlier. Derive now.
              -- smaddali 14-oct-03 added 2 new parameters to the procedure get_amt_tuition_fees, for bug#3179544
              igs_he_extract_fields_pkg.get_amt_tuition_fees
                  (p_person_id         =>  p_person_id,
                   p_course_cd         =>  p_course_cd,
                   p_cal_type          =>  g_en_stdnt_ps_att.cal_type,
                   p_fe_prg_mrker      =>  g_he_st_prog.fe_program_marker,
                   p_fe_stdnt_mrker    =>  g_field_defn.hesa_value(6),
                   p_oss_amt           =>  g_field_defn.oss_value(83),
                   p_hesa_amt          =>  p_value ,
                   p_enrl_start_dt     =>  g_he_submsn_header.enrolment_start_date,
                   p_enrl_end_dt       =>  g_he_submsn_header.enrolment_end_date);
          END IF;
          g_default_pro:= 'Y';
         END IF;

      ELSIF  p_field_number = 84
      THEN

         -- The default value processng to be done only if field 6 is in 1,3,4
         g_default_pro:= 'N';

         IF g_field_defn.hesa_value.EXISTS(6) AND g_field_defn.hesa_value(6) IN (1,3,4)     THEN
            -- Non Payment Reason
            igs_he_extract_fields_pkg.get_non_payment_rsn
              (p_oss_non_payment_rsn   =>  g_he_en_susa.non_payment_reason,
               p_hesa_non_payment_rsn  =>  p_value,
               p_fe_stdnt_mrker    => g_field_defn.hesa_value(6));

            g_default_pro:= 'Y';
         END IF;

      ELSIF  p_field_number = 85
      THEN
         -- The default value processng to be done only if field 6 is in 1,3,4
         g_default_pro:= 'N';

         IF g_field_defn.hesa_value.EXISTS(6) AND g_field_defn.hesa_value(6) IN (1,3,4)     THEN
            -- Guided Learning Hours
            p_value := To_char(g_ps_ver.contact_hours,'00000');
            g_default_pro:= 'Y';
         END IF;

      ELSIF  p_field_number = 86
      THEN
          -- Other Insitutions Providing Teaching 1
          igs_he_extract_fields_pkg.get_oth_teach_inst
              (p_person_id          =>  p_person_id,
               p_course_cd          =>  p_course_cd,
               p_program_calc       =>  g_he_st_prog.program_calc,
               p_susa_inst1         =>  g_he_en_susa.teaching_inst1,
               p_poous_inst1        =>  g_he_poous.other_instit_teach1,
               p_prog_inst1         =>  g_he_st_prog.other_inst_prov_teaching1,
               p_susa_inst2         =>  g_he_en_susa.teaching_inst2,
               p_poous_inst2        =>  g_he_poous.other_instit_teach2,
               p_prog_inst2         =>  g_he_st_prog.other_inst_prov_teaching2,
               p_hesa_inst1         =>  p_value,
               p_hesa_inst2         =>  g_field_defn.hesa_value(87),
               p_enrl_start_dt      =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt        =>  g_he_submsn_header.enrolment_end_date);

      ELSIF  p_field_number = 87
      THEN
          -- Other Insitutions Providing Teaching 2
          IF  g_field_defn.hesa_value.EXISTS(87)
          THEN
              -- Calculated earlier in field 86
              p_value :=  g_field_defn.hesa_value(87);
          ELSE
              -- Not calculated earlier
              igs_he_extract_fields_pkg.get_oth_teach_inst
                  (p_person_id          =>  p_person_id,
                   p_course_cd          =>  p_course_cd,
                   p_program_calc       =>  g_he_st_prog.program_calc,
                   p_susa_inst1         =>  g_he_en_susa.teaching_inst1,
                   p_poous_inst1        =>  g_he_poous.other_instit_teach1,
                   p_prog_inst1         =>  g_he_st_prog.other_inst_prov_teaching1,
                   p_susa_inst2         =>  g_he_en_susa.teaching_inst2,
                   p_poous_inst2        =>  g_he_poous.other_instit_teach2,
                   p_prog_inst2         =>  g_he_st_prog.other_inst_prov_teaching2,
                   p_hesa_inst1         =>  g_field_defn.hesa_value(86),
                   p_hesa_inst2         =>  p_value,
                   p_enrl_start_dt      =>  g_he_submsn_header.enrolment_start_date,
                   p_enrl_end_dt        =>  g_he_submsn_header.enrolment_end_date);

          END IF;

      ELSIF  p_field_number = 88
      THEN
          -- Proportion of teaching in Welsh
           --smaddali adding format mask '000.0' for bug 2437081
          p_value := Ltrim(To_Char( g_he_st_prog.prop_teaching_in_welsh,'000.0') );

      ELSIF  p_field_number = 89
      THEN
          -- Not used
          p_value := NULL;

      ELSIF  p_field_number = 90
      THEN
          --smaddali added 2 new parameters p_enrl_start_dt and p_enrl_end_dt for bug 2437081
          -- Proportion Not taught by this institution
          igs_he_extract_fields_pkg.get_prop_not_taught
              (p_person_id          =>  p_person_id,
               p_course_cd          =>  p_course_cd,
               p_enrl_start_dt     =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt       =>  g_he_submsn_header.enrolment_end_date ,
               p_program_calc       =>  g_he_st_prog.program_calc,
               p_susa_prop          =>  g_he_en_susa.pro_not_taught,
               p_poous_prop         =>  g_he_poous.prop_not_taught,
               p_prog_prop          =>  g_he_st_prog.prop_not_taught,
               p_hesa_prop          =>  l_prop_not_taught);

           --smaddali adding format mask '000.0' for bug 2437081
           p_value := ltrim( to_char(l_prop_not_taught,'000.0')) ;


      ELSIF  p_field_number = 91
      THEN
          -- Credit Transfer Scheme
          igs_he_extract_fields_pkg.get_credit_trans_sch
          (p_oss_credit_trans_sch   =>  g_he_st_prog.credit_transfer_scheme,
           p_hesa_credit_trans_sch  =>  p_value);

      ELSIF  p_field_number = 92
      THEN
          -- smaddali removed the validation to check for g_he_st_prog.program_calc for bug 2419875
          -- Credit value for Year of Program , 1
              p_value := NVL(g_he_en_susa.credit_value_yop1,g_he_poous.credit_value_yop1 ) ;

          --smaddali 01-jul-2002 lpadding with 0  for bug 2436769
          p_value := LPAD(p_value, 3,'0') ;


      ELSIF  p_field_number = 93
      THEN
          -- smaddali removed the validation to check for g_he_st_prog.program_calc for bug 2419875
          -- Credit value for Year of Program , 2
          -- smaddali added nvl of susa value for bug 2415879
          p_value := NVL(g_he_en_susa.credit_value_yop2,g_he_poous.credit_value_yop2 );

          --smaddali 01-jul-2002 lpadding with 0  for bug 2436769
          p_value := LPAD(p_value, 3,'0') ;


      ELSIF  p_field_number = 94
      THEN
          -- smaddali removed the validation to check for g_he_st_prog.program_calc for bug 2419875
          -- Level of Credit, 1
              igs_he_extract_fields_pkg.get_credit_level
                 (p_susa_credit_level     => g_he_en_susa.credit_level1,
                  p_poous_credit_level     =>  g_he_poous.level_credit1,
                  p_hesa_credit_level    =>  p_value);

      ELSIF  p_field_number = 95
      THEN
          -- smaddali removed the validation to check for g_he_st_prog.program_calc for bug 2419875
          -- Level of Credit, 2
              igs_he_extract_fields_pkg.get_credit_level
                 (p_susa_credit_level    => g_he_en_susa.credit_level2 ,
                  p_poous_credit_level     =>  g_he_poous.level_credit2,
                  p_hesa_credit_level    =>  p_value);

      ELSIF  p_field_number = 96
      THEN

           -- Number of Credit Points Obtained 1
           -- jbaber added crd_pt3-4, lvl_crd_pt3-4 for HEFD350
           igs_he_extract_fields_pkg.get_credit_obtained
               (p_person_id          =>  p_person_id,
                p_course_cd          =>  p_course_cd,
                p_prog_calc          =>  g_he_st_prog.program_calc,
                p_susa_crd_pt1       =>  g_he_en_susa.credit_pt_achieved1,
                p_susa_crd_pt2       =>  g_he_en_susa.credit_pt_achieved2,
                p_susa_crd_pt3       =>  g_he_en_susa.credit_pt_achieved3,
                p_susa_crd_pt4       =>  g_he_en_susa.credit_pt_achieved4,
                p_susa_crd_lvl1      =>  g_he_en_susa.credit_level_achieved1,
                p_susa_crd_lvl2      =>  g_he_en_susa.credit_level_achieved2,
                p_susa_crd_lvl3      =>  g_he_en_susa.credit_level_achieved3,
                p_susa_crd_lvl4      =>  g_he_en_susa.credit_level_achieved4,
                p_no_crd_pt1         =>  p_value,
                p_no_crd_pt2         =>  g_field_defn.hesa_value(97),
                p_no_crd_pt3         =>  g_field_defn.hesa_value(210),
                p_no_crd_pt4         =>  g_field_defn.hesa_value(211),
                p_lvl_crd_pt1        =>  g_field_defn.hesa_value(98),
                p_lvl_crd_pt2        =>  g_field_defn.hesa_value(99),
                p_lvl_crd_pt3        =>  g_field_defn.hesa_value(212),
                p_lvl_crd_pt4        =>  g_field_defn.hesa_value(213),
                p_enrl_start_dt      =>  g_he_submsn_header.enrolment_start_date,
                p_enrl_end_dt        =>  g_he_submsn_header.enrolment_end_date );

            --smaddali 01-jul-2002 lpadding with 0  for bug 2436769
            p_value := LPAD(p_value, 3,'0') ;

      ELSIF  p_field_number = 97
      THEN
           -- Number of Credit Points Obtained 2
           -- jbaber added crd_pt3-4, lvl_crd_pt3-4 for HEFD350
           IF g_field_defn.hesa_value.EXISTS(97)
           THEN
               p_value :=  g_field_defn.hesa_value(97);
           ELSE
               igs_he_extract_fields_pkg.get_credit_obtained
               (p_person_id          =>  p_person_id,
                p_course_cd          =>  p_course_cd,
                p_prog_calc          =>  g_he_st_prog.program_calc,
                p_susa_crd_pt1       =>  g_he_en_susa.credit_pt_achieved1,
                p_susa_crd_pt2       =>  g_he_en_susa.credit_pt_achieved2,
                p_susa_crd_pt3       =>  g_he_en_susa.credit_pt_achieved3,
                p_susa_crd_pt4       =>  g_he_en_susa.credit_pt_achieved4,
                p_susa_crd_lvl1      =>  g_he_en_susa.credit_level_achieved1,
                p_susa_crd_lvl2      =>  g_he_en_susa.credit_level_achieved2,
                p_susa_crd_lvl3      =>  g_he_en_susa.credit_level_achieved3,
                p_susa_crd_lvl4      =>  g_he_en_susa.credit_level_achieved4,
                p_no_crd_pt1         =>  g_field_defn.hesa_value(96),
                p_no_crd_pt2         =>  p_value,
                p_no_crd_pt3         =>  g_field_defn.hesa_value(210),
                p_no_crd_pt4         =>  g_field_defn.hesa_value(211),
                p_lvl_crd_pt1        =>  g_field_defn.hesa_value(98),
                p_lvl_crd_pt2        =>  g_field_defn.hesa_value(99),
                p_lvl_crd_pt3        =>  g_field_defn.hesa_value(212),
                p_lvl_crd_pt4        =>  g_field_defn.hesa_value(213),
                p_enrl_start_dt      =>  g_he_submsn_header.enrolment_start_date,
                p_enrl_end_dt        =>  g_he_submsn_header.enrolment_end_date );


           END IF;
           --smaddali 01-jul-2002 lpadding with 0  for bug 2436769
           p_value := LPAD(p_value, 3,'0') ;

      ELSIF  p_field_number = 98
      THEN
           -- Level of Credit Points Obtained 1
           -- jbaber added crd_pt3-4, lvl_crd_pt3-4 for HEFD350
           IF g_field_defn.hesa_value.EXISTS(98)
           THEN
               p_value :=  g_field_defn.hesa_value(98);
           ELSE
               igs_he_extract_fields_pkg.get_credit_obtained
               (p_person_id          =>  p_person_id,
                p_course_cd          =>  p_course_cd,
                p_prog_calc          =>  g_he_st_prog.program_calc,
                p_susa_crd_pt1       =>  g_he_en_susa.credit_pt_achieved1,
                p_susa_crd_pt2       =>  g_he_en_susa.credit_pt_achieved2,
                p_susa_crd_pt3       =>  g_he_en_susa.credit_pt_achieved3,
                p_susa_crd_pt4       =>  g_he_en_susa.credit_pt_achieved4,
                p_susa_crd_lvl1      =>  g_he_en_susa.credit_level_achieved1,
                p_susa_crd_lvl2      =>  g_he_en_susa.credit_level_achieved2,
                p_susa_crd_lvl3      =>  g_he_en_susa.credit_level_achieved3,
                p_susa_crd_lvl4      =>  g_he_en_susa.credit_level_achieved4,
                p_no_crd_pt1         =>  g_field_defn.hesa_value(96),
                p_no_crd_pt2         =>  g_field_defn.hesa_value(97),
                p_no_crd_pt3         =>  g_field_defn.hesa_value(210),
                p_no_crd_pt4         =>  g_field_defn.hesa_value(211),
                p_lvl_crd_pt1        =>  p_value,
                p_lvl_crd_pt2        =>  g_field_defn.hesa_value(99),
                p_lvl_crd_pt3        =>  g_field_defn.hesa_value(212),
                p_lvl_crd_pt4        =>  g_field_defn.hesa_value(213),
                p_enrl_start_dt      =>  g_he_submsn_header.enrolment_start_date,
                p_enrl_end_dt        =>  g_he_submsn_header.enrolment_end_date );
           END IF;

      ELSIF  p_field_number = 99
      THEN
           -- Level of Credit Points Obtained 2
           -- jbaber added crd_pt3-4, lvl_crd_pt3-4 for HEFD350
           IF g_field_defn.hesa_value.EXISTS(99)
           THEN
               p_value :=  g_field_defn.hesa_value(99);
           ELSE
               igs_he_extract_fields_pkg.get_credit_obtained
               (p_person_id          =>  p_person_id,
                p_course_cd          =>  p_course_cd,
                p_prog_calc          =>  g_he_st_prog.program_calc,
                p_susa_crd_pt1       =>  g_he_en_susa.credit_pt_achieved1,
                p_susa_crd_pt2       =>  g_he_en_susa.credit_pt_achieved2,
                p_susa_crd_pt3       =>  g_he_en_susa.credit_pt_achieved3,
                p_susa_crd_pt4       =>  g_he_en_susa.credit_pt_achieved4,
                p_susa_crd_lvl1      =>  g_he_en_susa.credit_level_achieved1,
                p_susa_crd_lvl2      =>  g_he_en_susa.credit_level_achieved2,
                p_susa_crd_lvl3      =>  g_he_en_susa.credit_level_achieved3,
                p_susa_crd_lvl4      =>  g_he_en_susa.credit_level_achieved4,
                p_no_crd_pt1         =>  g_field_defn.hesa_value(96),
                p_no_crd_pt2         =>  g_field_defn.hesa_value(97),
                p_no_crd_pt3         =>  g_field_defn.hesa_value(210),
                p_no_crd_pt4         =>  g_field_defn.hesa_value(211),
                p_lvl_crd_pt1        =>  g_field_defn.hesa_value(98),
                p_lvl_crd_pt2        =>  p_value,
                p_lvl_crd_pt3        =>  g_field_defn.hesa_value(212),
                p_lvl_crd_pt4        =>  g_field_defn.hesa_value(213),
                p_enrl_start_dt      =>  g_he_submsn_header.enrolment_start_date,
                p_enrl_end_dt        =>  g_he_submsn_header.enrolment_end_date );
           END IF;

      ELSIF  p_field_number = 100
      THEN
          -- Cost Centre1
          --smaddali added the initialisation of variable g_cc_rec for bug 2417370
          --jbaber added p_validation_country for HEFD350
          g_cc_rec := NULL ;
          g_total_ccs := 0;
          igs_he_extract_fields_pkg.get_cost_centres
          (p_person_id           =>  p_person_id,
           p_course_cd           =>  p_course_cd,
           p_version_number      =>  p_crv_version_number,
           p_unit_set_cd         =>  g_as_su_setatmpt.unit_set_cd,
           p_us_version_number   =>  g_as_su_setatmpt.us_version_number,
           p_cal_type            =>  g_en_stdnt_ps_att.cal_type,
           p_attendance_mode     =>  g_en_stdnt_ps_att.attendance_mode,
           p_attendance_type     =>  g_en_stdnt_ps_att.attendance_type,
           p_location_cd         =>  g_en_stdnt_ps_att.location_cd,
           p_program_calc        =>  g_he_st_prog.program_calc,
           p_unit_cd             =>  NULL,
           p_uv_version_number   =>  NULL,
           p_return_type         =>  'C',
           p_cost_ctr_rec        =>  g_cc_rec,
           p_total_recs          =>  g_total_ccs,
           p_enrl_start_dt       =>  g_he_submsn_header.enrolment_start_date,
           p_enrl_end_dt         =>  g_he_submsn_header.enrolment_end_date,
           p_sequence_number     =>  g_as_su_setatmpt.sequence_number,
           p_validation_country  =>  g_he_submsn_header.validation_country);

           IF g_total_ccs >= 1
           THEN
               p_value := g_cc_rec.cost_centre(1);
           END IF;

      ELSIF  p_field_number = 101
      THEN
          -- Subject 1
          IF g_total_ccs >= 1
          THEN
              -- smaddali removed the corsor getting govt field of study for bug 2417454
                  p_value := g_cc_rec.subject(1);
          END IF;

      ELSIF  p_field_number = 102
      THEN
          -- Proportion 1
          IF g_total_ccs >= 1
          THEN
                 --smaddali added format mask '000.0' to this field for bug 2437279
                 p_value := Ltrim(To_Char(g_cc_rec.proportion(1),'000.0') );

          END IF;

      ELSIF  p_field_number = 103
      THEN
           -- Cost Centre 2
           IF g_total_ccs >= 2
           THEN
               p_value := g_cc_rec.cost_centre(2);
           END IF;

      ELSIF  p_field_number = 104
      THEN
          -- Subject 2
          IF g_total_ccs >= 2
          THEN
              -- smaddali removed the corsor getting govt field of study for bug 2417454
                  p_value := g_cc_rec.subject(2) ;
          END IF;

      ELSIF  p_field_number = 105
      THEN
          -- Proportion 2
          IF g_total_ccs >= 2
          THEN
              --smaddali added format mask '000.0' to this field for bug 2437279
              p_value := Ltrim(To_Char(g_cc_rec.proportion(2),'000.0') );
          END IF;

      ELSIF  p_field_number = 106
      THEN
           -- Cost Centre 3
           IF g_total_ccs >= 3
           THEN
               p_value := g_cc_rec.cost_centre(3);
           END IF;

      ELSIF  p_field_number = 107
      THEN
          -- Subject 3
          IF g_total_ccs >= 3
          THEN
              -- smaddali removed the corsor getting govt field of study for bug 2417454
                  p_value := g_cc_rec.subject(3) ;
          END IF;

      ELSIF  p_field_number = 108
      THEN
          -- Proportion 3
          IF g_total_ccs >= 3
          THEN
          --smaddali added format mask '000.0' to this field for bug 2437279
              p_value := Ltrim(To_Char(g_cc_rec.proportion(3),'000.0') );
          END IF;

      ELSIF  p_field_number = 109
      THEN
           -- Cost Centre 4
           IF g_total_ccs >= 4
           THEN
               p_value := g_cc_rec.cost_centre(4);
           END IF;

      ELSIF  p_field_number = 110
      THEN
          -- Subject 4
          IF g_total_ccs >= 4
          THEN
              -- smaddali removed the corsor getting govt field of study for bug 2417454
                  p_value := g_cc_rec.subject(4);
          END IF;

      ELSIF  p_field_number = 111
      THEN
          -- Proportion 4
          IF g_total_ccs >= 4
          THEN
          --smaddali added format mask '000.0' to this field for bug 2437279
              p_value := Ltrim(To_Char(g_cc_rec.proportion(4),'000.0') );
          END IF;

      ELSIF  p_field_number = 112
      THEN
           -- Cost Centre 5
           IF g_total_ccs >= 5
           THEN
               p_value := g_cc_rec.cost_centre(5);
           END IF;

      ELSIF  p_field_number = 113
      THEN
          -- Subject 5
          IF g_total_ccs >= 5
          THEN
              -- smaddali removed the corsor getting govt field of study for bug 2417454
                  p_value := g_cc_rec.subject(5);
          END IF;

      ELSIF  p_field_number = 114
      THEN
          -- Proportion 5
          IF g_total_ccs >= 5
          THEN
          --smaddali added format mask '000.0' to this field for bug 2437279
              p_value := Ltrim(To_Char(g_cc_rec.proportion(5),'000.0') );
          END IF;

      ELSIF  p_field_number = 115
      THEN
           -- Cost Centre 6
           IF g_total_ccs >= 6
           THEN
               p_value := g_cc_rec.cost_centre(6);
           END IF;

      ELSIF  p_field_number = 116
      THEN
          -- Subject 6
          IF g_total_ccs >= 6
          THEN
              -- smaddali removed the corsor getting govt field of study for bug 2417454
                  p_value := g_cc_rec.subject(6);
          END IF;

      ELSIF  p_field_number = 117
      THEN
          -- Proportion 6
          IF g_total_ccs >= 6
          THEN
          --smaddali added format mask '000.0' to this field for bug 2437279
              p_value := Ltrim(To_Char(g_cc_rec.proportion(6),'000.0') );
          END IF;

      ELSIF  p_field_number = 118
      THEN
           -- Cost Centre 7
           IF g_total_ccs >= 7
           THEN
               p_value := g_cc_rec.cost_centre(7);
           END IF;

      ELSIF  p_field_number = 119
      THEN
          -- Subject 7
          IF g_total_ccs >= 7
          THEN
              -- smaddali removed the corsor getting govt field of study for bug 2417454
                  p_value := g_cc_rec.subject(7);
          END IF;

      ELSIF  p_field_number = 120
      THEN
          -- Proportion 7
          IF g_total_ccs >= 7
          THEN
          --smaddali added format mask '000.0' to this field for bug 2437279
              p_value := Ltrim(To_Char(g_cc_rec.proportion(7),'000.0') );
          END IF;

      ELSIF  p_field_number = 121
      THEN
           -- Cost Centre 8
           IF g_total_ccs >= 8
           THEN
               p_value := g_cc_rec.cost_centre(8);
           END IF;

      ELSIF  p_field_number = 122
      THEN
          -- Subject 8
          IF g_total_ccs >= 8
          THEN
              -- smaddali removed the corsor getting govt field of study for bug 2417454
                  p_value := g_cc_rec.subject(8);
          END IF;

      ELSIF  p_field_number = 123
      THEN
          -- Proportion 8
          IF g_total_ccs >= 8
          THEN
          --smaddali added format mask '000.0' to this field for bug 2437279
              p_value := Ltrim(To_Char(g_cc_rec.proportion(8),'000.0') );
          END IF;

      ELSIF  p_field_number = 124
      THEN
           -- Cost Centre 9
           IF g_total_ccs >= 9
           THEN
               p_value := g_cc_rec.cost_centre(9);
           END IF;

      ELSIF  p_field_number = 125
      THEN
          -- Subject 9
          IF g_total_ccs >= 9
          THEN
              -- smaddali removed the corsor getting govt field of study for bug 2417454
                  p_value := g_cc_rec.subject(9);
          END IF;

      ELSIF  p_field_number = 126
      THEN
          -- Proportion 9
          IF g_total_ccs >= 9
          THEN
          --smaddali added format mask '000.0' to this field for bug 2437279
              p_value := Ltrim(To_Char(g_cc_rec.proportion(9),'000.0') );
          END IF;

      ELSIF  p_field_number = 127
      THEN
           -- Cost Centre 10
           IF g_total_ccs >= 10
           THEN
               p_value := g_cc_rec.cost_centre(10);
           END IF;

      ELSIF  p_field_number = 128
      THEN
          -- Subject 10
          IF g_total_ccs >= 10
          THEN
              -- smaddali removed the corsor getting govt field of study for bug 2417454
                  p_value := g_cc_rec.subject(10);
          END IF;

      ELSIF  p_field_number = 129
      THEN
          -- Proportion 10
          IF g_total_ccs >= 10
          THEN
          --smaddali added format mask '000.0' to this field for bug 2437279
              p_value := Ltrim(To_Char(g_cc_rec.proportion(10),'000.0') );
          END IF;

      ELSIF  p_field_number = 130
      THEN
           -- Cost Centre 11
           IF g_total_ccs >= 11
           THEN
               p_value := g_cc_rec.cost_centre(11);
           END IF;

      ELSIF  p_field_number = 131
      THEN
          -- Subject 11
          IF g_total_ccs >= 11
          THEN
              -- smaddali removed the corsor getting govt field of study for bug 2417454
                  p_value := g_cc_rec.subject(11);
          END IF;

      ELSIF  p_field_number = 132
      THEN
          -- Proportion 11
          IF g_total_ccs >= 11
          THEN
          --smaddali added format mask '000.0' to this field for bug 2437279
              p_value := Ltrim(To_Char(g_cc_rec.proportion(11),'000.0') );
          END IF;

      ELSIF  p_field_number = 133
      THEN
           -- Cost Centre 12
           IF g_total_ccs >= 12
           THEN
               p_value := g_cc_rec.cost_centre(12);
           END IF;

      ELSIF  p_field_number = 134
      THEN
          -- Subject 12
          IF g_total_ccs >= 12
          THEN
              -- smaddali removed the corsor getting govt field of study for bug 2417454
                  p_value := g_cc_rec.subject(12);
          END IF;

      ELSIF  p_field_number = 135
      THEN
          -- Proportion 12
          IF g_total_ccs >= 12
          THEN
          --smaddali added format mask '000.0' to this field for bug 2437279
              p_value := Ltrim(To_Char(g_cc_rec.proportion(12),'000.0') );
          END IF;

      ELSIF  p_field_number = 136
      THEN
           -- Cost Centre 13
           IF g_total_ccs >= 13
           THEN
               p_value := g_cc_rec.cost_centre(13);
           END IF;

      ELSIF  p_field_number = 137
      THEN
          -- Subject 13
          IF g_total_ccs >= 13
          THEN
              -- smaddali removed the corsor getting govt field of study for bug 2417454
                  p_value := g_cc_rec.subject(13);
           END IF;

      ELSIF  p_field_number = 138
      THEN
          -- Proportion 13
          IF g_total_ccs >= 13
          THEN
          --smaddali added format mask '000.0' to this field for bug 2437279
              p_value := Ltrim(To_Char(g_cc_rec.proportion(13),'000.0') );
          END IF;

      ELSIF  p_field_number = 139
      THEN
           -- Cost Centre 14
           IF g_total_ccs >= 14
           THEN
               p_value := g_cc_rec.cost_centre(14);
           END IF;

      ELSIF  p_field_number = 140
      THEN
          -- Subject 14
          IF g_total_ccs >= 14
          THEN
              -- smaddali removed the corsor getting govt field of study for bug 2417454
                 p_value := g_cc_rec.subject(14) ;
          END IF;

      ELSIF  p_field_number = 141
      THEN
          -- Proportion 14
          IF g_total_ccs >= 14
          THEN
          --smaddali added format mask '000.0' to this field for bug 2437279
              p_value := Ltrim(To_Char(g_cc_rec.proportion(14),'000.0') );
          END IF;

      ELSIF  p_field_number = 142
      THEN
           -- Cost Centre 15
           IF g_total_ccs >= 15
           THEN
               p_value := g_cc_rec.cost_centre(15);
           END IF;

      ELSIF  p_field_number = 143
      THEN
          -- Subject 15
          IF g_total_ccs >= 15
          THEN
              -- smaddali removed the corsor getting govt field of study for bug 2417454
                  p_value := g_cc_rec.subject(15);
          END IF;

      ELSIF  p_field_number = 144
      THEN
          -- Proportion 15
          IF g_total_ccs >= 15
          THEN
          --smaddali added format mask '000.0' to this field for bug 2437279
              p_value := Ltrim(To_Char(g_cc_rec.proportion(15),'000.0') );
          END IF;

      ELSIF  p_field_number = 145
      THEN
           -- Cost Centre 16
           IF g_total_ccs >= 16
           THEN
               p_value := g_cc_rec.cost_centre(16);
           END IF;

      ELSIF  p_field_number = 146
      THEN
          -- Subject 16
          IF g_total_ccs >= 16
          THEN
              -- smaddali removed the corsor getting govt field of study for bug 2417454
                  p_value := g_cc_rec.subject(16);
          END IF;

      ELSIF  p_field_number = 147
      THEN
          -- Proportion 16
          IF g_total_ccs >= 16
          THEN
          --smaddali added format mask '000.0' to this field for bug 2437279
              p_value := Ltrim(To_Char(g_cc_rec.proportion(16),'000.0') );
          END IF;

      -- Modified the derivation of this field to derive regardless of the value of the HESA MODE field (70)
      -- as part of HEFD311 - July 2004 Changes enhancement bug, 2956444
      ELSIF  p_field_number = 148
      THEN

         IF g_field_defn.hesa_value.EXISTS(148)
         THEN
             p_value :=  g_field_defn.hesa_value(148);
         ELSE

           IF  g_he_st_spa.associate_ucas_number = 'Y' THEN
              -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
              igs_he_extract_fields_pkg.get_ucasnum
              (p_person_id        => p_person_id,
               p_ucasnum          => p_value,
               p_enrl_start_dt    =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt      =>  g_he_submsn_header.enrolment_end_date);

            END IF;

         END IF;

      ELSIF  p_field_number = 149
      THEN
          -- Institutions Own Id for Student
          p_value := g_pe_person.person_number;

      ELSIF  p_field_number = 150
      THEN
          -- Institutes program of study
          p_value := p_course_cd || '.' || To_Char(p_crv_version_number);

      ELSIF  p_field_number = 151
      THEN
          -- Student Instance Number
          p_value := g_he_st_spa.student_inst_number;

      ELSIF  p_field_number = 152
      THEN
          -- Suspension of Active studies
          igs_he_extract_fields_pkg.get_studies_susp
              (p_person_id          =>  p_person_id,
               p_course_cd          =>  p_course_cd,
               p_version_number     =>  p_crv_version_number,
               p_enrl_start_dt      =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt        =>  g_he_submsn_header.enrolment_end_date,
               p_susp_act_std       =>  p_value);

      ELSIF  p_field_number = 153
      THEN
          -- Type of Program year

          igs_he_extract_fields_pkg.get_pyr_type
              (p_oss_pyr_type     =>  NVL(g_he_en_susa.type_of_year,g_he_poous.type_of_year),
               p_hesa_pyr_type    =>  p_value);

      ELSIF  p_field_number = 154
      THEN
          -- Level applicable for funding
          igs_he_extract_fields_pkg.get_lvl_appl_to_fund
              (p_poous_lvl_appl_fund   =>  g_he_poous.level_applicable_to_funding,
               p_prg_lvl_appl_fund     =>  g_he_st_prog.level_applicable_to_funding,
               p_hesa_lvl_appl_fund    =>  p_value);

      -- The derivation of this field has changed majorly to consider the new setup
      -- as part of HEFD311 - July 2004 Changes enhancement bug, 2956444
      ELSIF  p_field_number = 155
      THEN

         -- The default value not to be done for all the cuontries
         g_default_pro := 'N' ;

         IF g_he_submsn_header.validation_country IN ('ENGLAND','WALES','NORTHERN IRELAND')  THEN

            -- Check for the existence of the fields 154, 28, 152, 72 and 153. If not exists pass NULL value
            IF g_field_defn.hesa_value.EXISTS(154) THEN
              l_fundlev := g_field_defn.hesa_value(154);
            ELSE
              l_fundlev := NULL;
            END IF;

            IF g_field_defn.hesa_value.EXISTS(28) THEN
              l_spcstu := g_field_defn.hesa_value(28);
            ELSE
              l_spcstu := NULL;
            END IF;

            IF g_field_defn.hesa_value.EXISTS(152) THEN
              l_notact := g_field_defn.hesa_value(152);
            ELSE
              l_notact := NULL;
            END IF;

            IF g_field_defn.hesa_value.EXISTS(70) THEN
              l_mode := g_field_defn.hesa_value(70);
            ELSE
              l_mode := NULL;
            END IF;
            IF g_field_defn.hesa_value.EXISTS(153) THEN
              l_typeyr := g_field_defn.hesa_value(153);
            ELSE
              l_typeyr := NULL;
            END IF;

            -- Completion of Year of Program of study
            igs_he_extract_fields_pkg.get_comp_pyr_study (
              p_susa_comp_pyr_study  =>  g_he_en_susa.complete_pyr_study_cd,
              p_fundlev              =>  l_fundlev,
              p_spcstu               =>  l_spcstu,
              p_notact               =>  l_notact,
              p_mode                 =>  l_mode,
              p_typeyr               =>  l_typeyr,
              p_crse_rqr_complete_ind => g_en_stdnt_ps_att.course_rqrmnt_complete_ind,
              p_crse_req_complete_dt =>  g_en_stdnt_ps_att.course_rqrmnts_complete_dt,
              p_disc_reason_cd       =>  g_en_stdnt_ps_att.discontinuation_reason_cd,
              p_discont_dt           =>  g_en_stdnt_ps_att.discontinued_dt,
              p_enrl_start_dt        =>  g_he_submsn_header.enrolment_start_date,
              p_enrl_end_dt          =>  g_he_submsn_header.enrolment_end_date,
              p_person_id            =>  p_person_id,
              p_course_cd            =>  p_course_cd,
              p_hesa_comp_pyr_study  =>  p_value);

              g_default_pro := 'Y' ;
         END IF;

      ELSIF  p_field_number = 156
      THEN

         IF (g_he_submsn_header.validation_country =   'WALES'  AND ( g_field_defn.hesa_value.EXISTS(6) and  g_field_defn.hesa_value(6) IN (1,3,4))) THEN
            -- Get the value of Destination
            igs_he_extract_fields_pkg.get_destination
              (p_oss_destination     =>  g_he_st_spa.destination,
               p_hesa_destination    =>  p_value);
         ELSE
            -- The default value should not be calculated for  any other condition
            g_default_pro := 'N' ;

         END IF;

      ELSIF  p_field_number = 157
      THEN
          -- Not used
          p_value := NULL;

      ELSIF  p_field_number = 158
      THEN
          -- Not used
          p_value := NULL;

      ELSIF  p_field_number = 159
      THEN
          -- Not used
          p_value := NULL;

      ELSIF  p_field_number = 160
      THEN
          -- Not used
          p_value := NULL;

      ELSIF  p_field_number = 161
      THEN

        --Set the  default variable value as default value has to be calculated only for the down condition
        g_default_pro := 'N';

        IF g_he_submsn_header.validation_country IN   ('ENGLAND','WALES') THEN
              -- Get the value
              -- Outcome of ITT Program
          IF (g_field_defn.hesa_value.EXISTS(53)  AND g_field_defn.hesa_value(53) IN (1,6,7)) THEN
                IF  g_field_defn.hesa_value.EXISTS(161)     THEN
               -- Calculated earlier, for field 29
                    p_value :=   g_field_defn.hesa_value(161);

                ELSE
                   igs_he_extract_fields_pkg.get_itt_outcome
                    (p_oss_itt_outcome     =>  g_he_st_spa.itt_prog_outcome,
                     p_teach_train_prg     =>  g_field_defn.hesa_value(53),
                     p_hesa_itt_outcome    =>  p_value);

                END IF;
                --If the value is calculated as NULL above then do the default processing for this field
                g_default_pro := 'Y' ;
          END IF;
        END IF;

      ELSIF  p_field_number = 162
      THEN
          -- Not used
          p_value := NULL;

      ELSIF  p_field_number = 163
      THEN
          -- Not used
          p_value := NULL;

      ELSIF  p_field_number = 164
      THEN
          -- UFI Place
          igs_he_extract_fields_pkg.get_ufi_place
              (p_oss_ufi_place     =>  NVL(g_he_st_spa.ufi_place,g_he_poous.ufi_place),
               p_hesa_ufi_place    =>  p_value);

      ELSIF  p_field_number = 165
      THEN
          --Franchising Activity
          igs_he_extract_fields_pkg.get_franchising_activity
              (p_susa_franch_activity   => g_he_en_susa.franchising_activity,
               p_poous_franch_activity  => g_he_poous.franchising_activity,
               p_prog_franch_activity   => g_he_st_prog.franchising_activity,
               p_hesa_franch_activity   =>  p_value);

      ELSIF  p_field_number = 166
      THEN
        -- Institutions own campus identifier
              igs_he_extract_fields_pkg.get_campus_id
              (p_location_cd => g_en_stdnt_ps_att.location_cd,
               p_campus_id   => p_value);

      ELSIF  p_field_number = 167
      THEN
          -- sjlaporte use date comparison rather than text bug 3933715
          -- Social Class Indicator
          IF g_en_stdnt_ps_att.commencement_dt  > TO_DATE('31/07/2002', 'DD/MM/YYYY')
          THEN
              igs_he_extract_fields_pkg.get_social_class_ind
                  (p_spa_social_class_ind   => g_he_st_spa.social_class_ind,
                   p_adm_social_class_ind   => g_he_ad_dtl.social_class_cd,
                   p_hesa_social_class_ind  => p_value);
          END IF;

      ELSIF  p_field_number = 168
      THEN
          -- sjlaporte use date comparison rather than text bug 3933715
          -- Occupation Code
          IF g_en_stdnt_ps_att.commencement_dt  > TO_DATE('31/07/2002', 'DD/MM/YYYY')
          THEN
              igs_he_extract_fields_pkg.get_occupation_code
                  (p_spa_occupation_code   => g_he_st_spa.occupation_code,
                   p_hesa_occupation_code  =>  p_value);

          END IF;

      ELSIF  p_field_number = 169
      THEN

          -- Insitute last attended
        -- smaddali modified this field to remove the dependency on field 148UCASNUM for bug 2663717
                  igs_he_extract_fields_pkg.get_inst_last_attended
                     (p_person_id         =>  p_person_id,
                      p_com_date          =>  g_en_stdnt_ps_att.commencement_dt,
                      p_inst_last_att     =>  p_value,
                      p_enrl_start_dt     =>  g_he_submsn_header.enrolment_start_date,
                      p_enrl_end_dt       =>  g_he_submsn_header.enrolment_end_date
                      );

      ELSIF  p_field_number = 170
      THEN
          -- Regulatory Body
          igs_he_extract_fields_pkg.get_regulatory_body
              (p_course_cd               =>  p_course_cd,
               p_version_number          =>  p_crv_version_number,
               p_hesa_regulatory_body    =>  p_value);

      -- Modified the field derivation to derive a default value based on field numbers 41 and 170
      -- as part of HEFD311 - July 2004 Changes enhancement bug, 2956444
      ELSIF  p_field_number = 171
      THEN

          -- Regulatory Body Registration Number
          -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
          -- and adding validation to derive this field only if associate_nhs_reg_num=Y
          IF g_he_st_spa.associate_nhs_reg_num = 'Y' THEN

            -- Get alternate person id with type 'DH REG REF' which overlaps HESA reporting period
            igs_he_extract_fields_pkg.get_alt_pers_id
                (p_person_id              => p_person_id,
                 p_id_type                => 'DH REG REF',
                 p_api_id                 => p_value,
                 p_enrl_start_dt          => g_he_submsn_header.enrolment_start_date,
                 p_enrl_end_dt            => g_he_submsn_header.enrolment_end_date);

          END IF ;

          -- If the field not derived and
          -- If field 41- QUALAIM  is 18 or 33 and Field 170 - Regulatory body for
          -- health and Social care students is 06 or 07 then use default value, 99999999
          IF p_value IS NULL AND g_field_defn.hesa_value.EXISTS(41) AND g_field_defn.hesa_value(41) IN (18,33) AND
             g_field_defn.hesa_value.EXISTS(170)  AND g_field_defn.hesa_value(170) IN ('06', '07') THEN

            p_value := '99999999';

          END IF;

      ELSIF  p_field_number = 172
      THEN
          -- Source of NHS funding
          igs_he_extract_fields_pkg.get_nhs_fund_src
              (p_spa_nhs_fund_src    =>  g_he_st_spa.nhs_funding_source,
               p_prg_nhs_fund_src    =>  g_he_st_prog.nhs_funding_source,
               p_hesa_nhs_fund_src   =>  p_value);

      ELSIF  p_field_number = 173
      THEN
          -- NHS Employer
          igs_he_extract_fields_pkg.get_nhs_employer
              (p_spa_nhs_employer     => g_he_st_spa.nhs_employer,
               p_hesa_nhs_employer    => p_value);

      ELSIF  p_field_number = 174
      THEN

          g_default_pro := 'N';

          -- Number of GCE AS Levels
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'GCSEAS',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(175));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'GCEASN',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(148) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(148),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                  g_default_pro := 'Y';
              END IF;

          END IF;

      ELSIF  p_field_number = 175
      THEN

          g_default_pro := 'N';

          -- GCE AS level Tariff Score
          IF g_field_defn.hesa_value.EXISTS(175) AND g_field_defn.hesa_value(175) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(175);

              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'GCEASTS',
                                                           p_tariff_score   => p_value);
          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(148) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(148),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 176
      THEN

          g_default_pro := 'N';

          -- Number of VCE AS Levels
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'VCSEAS',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(177));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'VCEASN',
                                                       p_no_of_qual     => p_value);
          END IF;

          IF g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(148) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(148),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;


      ELSIF  p_field_number = 177
      THEN

          g_default_pro := 'N';

          -- GCE AS level Tariff Score
          IF g_field_defn.hesa_value.EXISTS(177) AND g_field_defn.hesa_value(177) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(177);

              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'VCEASTS',
                                                           p_tariff_score   => p_value);
          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(148) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(148),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 178
      THEN

          g_default_pro := 'N';

          -- Number of GCE A Levels
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'GCSEA',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(179));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'GCEAN',
                                                       p_no_of_qual     => p_value);
          END IF;

          IF g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(148) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(148),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 179
      THEN

          g_default_pro := 'N';

          -- GCE A level Tariff Score
          IF g_field_defn.hesa_value.EXISTS(179) AND g_field_defn.hesa_value(179) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(179);

              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'GCEATS',
                                                           p_tariff_score   => p_value);

          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(148) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(148),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;


      ELSIF  p_field_number = 180
      THEN

          g_default_pro := 'N';

          -- Number of VCE A Levels
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'VCSEA',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(181));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'VCEAN',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(148) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(148),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                g_default_pro := 'Y';
              END IF;

          END IF;


      ELSIF  p_field_number = 181
      THEN

          g_default_pro := 'N';

          -- VCE A level Tariff Score
          IF g_field_defn.hesa_value.EXISTS(181) AND g_field_defn.hesa_value(181) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(181);

              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'VCEATS',
                                                           p_tariff_score   => p_value);

          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(148) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(148),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 182
      THEN

          g_default_pro := 'N';

          -- Number of Key Skill Qualifications
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'KEYSKL',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(183));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'KSQN',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(148) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(148),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                g_default_pro := 'Y';
              END IF;

          END IF;

      ELSIF  p_field_number = 183
      THEN

          g_default_pro := 'N';

          -- Key Skills Tariff Score
          IF g_field_defn.hesa_value.EXISTS(183) AND g_field_defn.hesa_value(183) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(183);

              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'KSQTS',
                                                           p_tariff_score   => p_value);

          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(148) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(148),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;


      ELSIF  p_field_number = 184
      THEN

          g_default_pro := 'N';

          -- Number of 1 unit key skill awards
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  '1UNKEYSKL',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(185));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'UKSAN',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(148) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(148),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                g_default_pro := 'Y';
              END IF;

          END IF;

      ELSIF  p_field_number = 185
      THEN

          g_default_pro := 'N';

          -- 1 Unit Key Skill Tariff Score
          IF g_field_defn.hesa_value.EXISTS(185) AND g_field_defn.hesa_value(185) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(185);

              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'UKSATS',
                                                           p_tariff_score   => p_value);

          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(148) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(148),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 186
      THEN

          g_default_pro := 'N';

          -- Number of Scottish Advanced Higher Levels
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'SCOTADH',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(187));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'SAHN',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(148) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(148),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                g_default_pro := 'Y';
              END IF;

          END IF;

      ELSIF  p_field_number = 187
      THEN

          g_default_pro := 'N';

          -- Scottish Advanced Higher level Tariff Score
          IF g_field_defn.hesa_value.EXISTS(187) AND g_field_defn.hesa_value(187) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(187);

              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'SAHTS',
                                                           p_tariff_score   => p_value);
          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(148) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(148),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 188
      THEN

          g_default_pro := 'N';

          -- Number of Scottish Higher Levels
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'SCOTH',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(189));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'SHN',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(148) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(148),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                g_default_pro := 'Y';
              END IF;

          END IF;

      ELSIF  p_field_number = 189
      THEN

          g_default_pro := 'N';

          -- Scottish Higher level Tariff Score
          IF g_field_defn.hesa_value.EXISTS(189) AND g_field_defn.hesa_value(189) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(189);
              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'SHTS',
                                                           p_tariff_score   => p_value);

          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(148) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(148),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 190
      THEN

          g_default_pro := 'N';

          -- Number of Scottish Intermediate Levels
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'SCOTI2',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(191));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'SI2N',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(148) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(148),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                g_default_pro := 'Y';
              END IF;

          END IF;

      ELSIF  p_field_number = 191
      THEN

          g_default_pro := 'N';

          -- Scottish Intermediate level Tariff Score
          IF g_field_defn.hesa_value.EXISTS(191) AND g_field_defn.hesa_value(191) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(191);
              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'SI2TS',
                                                           p_tariff_score   => p_value);

          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(148) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(148),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 192
      THEN

          g_default_pro := 'N';

          -- Number of Scottish Standard Grade Credit Levels
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'SCOTST',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(193));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'SSGCN',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(148) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(148),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                g_default_pro := 'Y';
              END IF;

          END IF;

      ELSIF  p_field_number = 193
      THEN

          g_default_pro := 'N';

          --  Scottish Standard Grade  level Tariff Score
          IF g_field_defn.hesa_value.EXISTS(193) AND g_field_defn.hesa_value(193) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(193);

              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'SSGCTS',
                                                           p_tariff_score   => p_value);

          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(148) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(148),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 194
      THEN

          g_default_pro := 'N';

          -- Number of Scottish Core Skills Levels
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'SCOTCO',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(195));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'SCSN',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(148) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(148),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                g_default_pro := 'Y';
              END IF;

          END IF;

      ELSIF  p_field_number = 195
      THEN

          g_default_pro := 'N';

          -- Scottish Core Skills level Tariff Score
          IF g_field_defn.hesa_value.EXISTS(195) AND g_field_defn.hesa_value(195) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(195);
              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'SCSTS',
                                                           p_tariff_score   => p_value);

          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(148) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(148),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 196
      THEN

          g_default_pro := 'N';

          -- Number of Advanced Extension
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'ADVEXT',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(197));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'AEAN',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(148) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(148),
                      p_min_commdate      => TO_DATE('31/07/2003', 'DD/MM/YYYY'))
              THEN
                g_default_pro := 'Y';
              END IF;

          END IF;

      ELSIF  p_field_number = 197
      THEN

           g_default_pro := 'N';

          -- Advanced Extension Tariff Score
          IF g_field_defn.hesa_value.EXISTS(197) AND g_field_defn.hesa_value(197) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(197);
              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'AENTS',
                                                           p_tariff_score   => p_value);

          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(148) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(148),
                  p_min_commdate      => TO_DATE('31/07/2003', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 198
      THEN

          g_default_pro := 'N';

          -- Total Tariff Score
          p_value :=  g_he_st_spa.total_ucas_tariff;

          IF p_value IS NOT NULL
          THEN
              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'TOTALTS',
                                                           p_tariff_score   => p_value);
          ELSE
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(148) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(148),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                  g_default_pro := 'Y';
              END IF;
          END IF;

      ELSIF  p_field_number = 199
      THEN
          -- Number of CACHE qualifications
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'CACHE',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(200));

      ELSIF  p_field_number = 200
      THEN
          -- CACHE qualifications Tariff Score
          IF g_field_defn.hesa_value.EXISTS(200)
          THEN
              p_value := g_field_defn.hesa_value(200);
          END IF;

      ELSIF  p_field_number = 201
      THEN
          -- Number of BTEC
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'BTEC',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(202));

      ELSIF  p_field_number = 202
      THEN
          -- BTEC Tariff Score
          IF g_field_defn.hesa_value.EXISTS(202)
          THEN
              p_value := g_field_defn.hesa_value(202);
          END IF;

      ELSIF  p_field_number = 203
      THEN
          -- International Baccalaureate Tariff Score
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'INBA',
               p_no_of_qual           =>  l_dummy,
               p_tariff_score         =>  p_value);

      ELSIF  p_field_number = 204
      THEN
          -- Irish Leaving certificate tariff score
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'ILC',
               p_no_of_qual           =>  l_dummy,
               p_tariff_score         =>  p_value);

      ELSIF  p_field_number = 205
      THEN
          -- Music, Drama and Performing Arts
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'MUDRPA',
               p_no_of_qual           =>  l_dummy,
               p_tariff_score         =>  p_value);

      ELSIF  p_field_number = 206
      THEN
          -- Credit value for Year of Program , 3
          p_value := NVL(g_he_en_susa.credit_value_yop3,g_he_poous.credit_value_yop3 ) ;

          p_value := LPAD(p_value, 3,'0') ;


      ELSIF  p_field_number = 207
      THEN
          -- Credit value for Year of Program , 4
          p_value := NVL(g_he_en_susa.credit_value_yop4,g_he_poous.credit_value_yop4 );

          p_value := LPAD(p_value, 3,'0') ;


      ELSIF  p_field_number = 208
      THEN
          -- Level of Credit, 3
              igs_he_extract_fields_pkg.get_credit_level
                 (p_susa_credit_level     =>  g_he_en_susa.credit_level3,
                  p_poous_credit_level    =>  g_he_poous.level_credit3,
                  p_hesa_credit_level     =>  p_value);

      ELSIF  p_field_number = 209
      THEN
          -- Level of Credit, 4
              igs_he_extract_fields_pkg.get_credit_level
                 (p_susa_credit_level    =>  g_he_en_susa.credit_level4 ,
                  p_poous_credit_level   =>  g_he_poous.level_credit4,
                  p_hesa_credit_level    =>  p_value);

      ELSIF  p_field_number = 210
      THEN
           -- Number of Credit Points Obtained 3
           IF g_field_defn.hesa_value.EXISTS(210)
           THEN
               p_value :=  g_field_defn.hesa_value(210);
           ELSE
               igs_he_extract_fields_pkg.get_credit_obtained
               (p_person_id          =>  p_person_id,
                p_course_cd          =>  p_course_cd,
                p_prog_calc          =>  g_he_st_prog.program_calc,
                p_susa_crd_pt1       =>  g_he_en_susa.credit_pt_achieved1,
                p_susa_crd_pt2       =>  g_he_en_susa.credit_pt_achieved2,
                p_susa_crd_pt3       =>  g_he_en_susa.credit_pt_achieved3,
                p_susa_crd_pt4       =>  g_he_en_susa.credit_pt_achieved4,
                p_susa_crd_lvl1      =>  g_he_en_susa.credit_level_achieved1,
                p_susa_crd_lvl2      =>  g_he_en_susa.credit_level_achieved2,
                p_susa_crd_lvl3      =>  g_he_en_susa.credit_level_achieved3,
                p_susa_crd_lvl4      =>  g_he_en_susa.credit_level_achieved4,
                p_no_crd_pt1         =>  g_field_defn.hesa_value(96),
                p_no_crd_pt2         =>  g_field_defn.hesa_value(97),
                p_no_crd_pt3         =>  p_value,
                p_no_crd_pt4         =>  g_field_defn.hesa_value(211),
                p_lvl_crd_pt1        =>  g_field_defn.hesa_value(98),
                p_lvl_crd_pt2        =>  g_field_defn.hesa_value(99),
                p_lvl_crd_pt3        =>  g_field_defn.hesa_value(212),
                p_lvl_crd_pt4        =>  g_field_defn.hesa_value(213),
                p_enrl_start_dt      =>  g_he_submsn_header.enrolment_start_date,
                p_enrl_end_dt        =>  g_he_submsn_header.enrolment_end_date );
           END IF;

           p_value := LPAD(p_value, 3,'0') ;

      ELSIF  p_field_number = 211
      THEN
           -- Number of Credit Points Obtained 4
           IF g_field_defn.hesa_value.EXISTS(211)
           THEN
               p_value :=  g_field_defn.hesa_value(211);
           ELSE
               igs_he_extract_fields_pkg.get_credit_obtained
               (p_person_id          =>  p_person_id,
                p_course_cd          =>  p_course_cd,
                p_prog_calc          =>  g_he_st_prog.program_calc,
                p_susa_crd_pt1       =>  g_he_en_susa.credit_pt_achieved1,
                p_susa_crd_pt2       =>  g_he_en_susa.credit_pt_achieved2,
                p_susa_crd_pt3       =>  g_he_en_susa.credit_pt_achieved3,
                p_susa_crd_pt4       =>  g_he_en_susa.credit_pt_achieved4,
                p_susa_crd_lvl1      =>  g_he_en_susa.credit_level_achieved1,
                p_susa_crd_lvl2      =>  g_he_en_susa.credit_level_achieved2,
                p_susa_crd_lvl3      =>  g_he_en_susa.credit_level_achieved3,
                p_susa_crd_lvl4      =>  g_he_en_susa.credit_level_achieved4,
                p_no_crd_pt1         =>  g_field_defn.hesa_value(96),
                p_no_crd_pt2         =>  g_field_defn.hesa_value(97),
                p_no_crd_pt3         =>  g_field_defn.hesa_value(210),
                p_no_crd_pt4         =>  p_value,
                p_lvl_crd_pt1        =>  g_field_defn.hesa_value(98),
                p_lvl_crd_pt2        =>  g_field_defn.hesa_value(99),
                p_lvl_crd_pt3        =>  g_field_defn.hesa_value(212),
                p_lvl_crd_pt4        =>  g_field_defn.hesa_value(213),
                p_enrl_start_dt      =>  g_he_submsn_header.enrolment_start_date,
                p_enrl_end_dt        =>  g_he_submsn_header.enrolment_end_date );
           END IF;

           p_value := LPAD(p_value, 3,'0') ;

      ELSIF  p_field_number = 212
      THEN
           -- Level of Credit Points Obtained 3
           IF g_field_defn.hesa_value.EXISTS(212)
           THEN
               p_value :=  g_field_defn.hesa_value(212);
           ELSE
               igs_he_extract_fields_pkg.get_credit_obtained
               (p_person_id          =>  p_person_id,
                p_course_cd          =>  p_course_cd,
                p_prog_calc          =>  g_he_st_prog.program_calc,
                p_susa_crd_pt1       =>  g_he_en_susa.credit_pt_achieved1,
                p_susa_crd_pt2       =>  g_he_en_susa.credit_pt_achieved2,
                p_susa_crd_pt3       =>  g_he_en_susa.credit_pt_achieved3,
                p_susa_crd_pt4       =>  g_he_en_susa.credit_pt_achieved4,
                p_susa_crd_lvl1      =>  g_he_en_susa.credit_level_achieved1,
                p_susa_crd_lvl2      =>  g_he_en_susa.credit_level_achieved2,
                p_susa_crd_lvl3      =>  g_he_en_susa.credit_level_achieved3,
                p_susa_crd_lvl4      =>  g_he_en_susa.credit_level_achieved4,
                p_no_crd_pt1         =>  g_field_defn.hesa_value(96),
                p_no_crd_pt2         =>  g_field_defn.hesa_value(97),
                p_no_crd_pt3         =>  g_field_defn.hesa_value(210),
                p_no_crd_pt4         =>  g_field_defn.hesa_value(211),
                p_lvl_crd_pt1        =>  g_field_defn.hesa_value(98),
                p_lvl_crd_pt2        =>  g_field_defn.hesa_value(99),
                p_lvl_crd_pt3        =>  p_value,
                p_lvl_crd_pt4        =>  g_field_defn.hesa_value(213),
                p_enrl_start_dt      =>  g_he_submsn_header.enrolment_start_date,
                p_enrl_end_dt        =>  g_he_submsn_header.enrolment_end_date );
           END IF;

      ELSIF  p_field_number = 213
      THEN
           -- Level of Credit Points Obtained 4
           IF g_field_defn.hesa_value.EXISTS(213)
           THEN
               p_value :=  g_field_defn.hesa_value(213);
           ELSE
               igs_he_extract_fields_pkg.get_credit_obtained
               (p_person_id          =>  p_person_id,
                p_course_cd          =>  p_course_cd,
                p_prog_calc          =>  g_he_st_prog.program_calc,
                p_susa_crd_pt1       =>  g_he_en_susa.credit_pt_achieved1,
                p_susa_crd_pt2       =>  g_he_en_susa.credit_pt_achieved2,
                p_susa_crd_pt3       =>  g_he_en_susa.credit_pt_achieved3,
                p_susa_crd_pt4       =>  g_he_en_susa.credit_pt_achieved4,
                p_susa_crd_lvl1      =>  g_he_en_susa.credit_level_achieved1,
                p_susa_crd_lvl2      =>  g_he_en_susa.credit_level_achieved2,
                p_susa_crd_lvl3      =>  g_he_en_susa.credit_level_achieved3,
                p_susa_crd_lvl4      =>  g_he_en_susa.credit_level_achieved4,
                p_no_crd_pt1         =>  g_field_defn.hesa_value(96),
                p_no_crd_pt2         =>  g_field_defn.hesa_value(97),
                p_no_crd_pt3         =>  g_field_defn.hesa_value(210),
                p_no_crd_pt4         =>  g_field_defn.hesa_value(211),
                p_lvl_crd_pt1        =>  g_field_defn.hesa_value(98),
                p_lvl_crd_pt2        =>  g_field_defn.hesa_value(99),
                p_lvl_crd_pt3        =>  g_field_defn.hesa_value(212),
                p_lvl_crd_pt4        =>  p_value,
                p_enrl_start_dt      =>  g_he_submsn_header.enrolment_start_date,
                p_enrl_end_dt        =>  g_he_submsn_header.enrolment_end_date );
           END IF;

      ELSIF  p_field_number = 214
      THEN
          -- Marital Status
          igs_he_extract_fields_pkg.get_marital_status
              (p_oss_marital_status     =>  g_pe_stat_v.marital_status,
               p_hesa_marital_status    =>  p_value);

      ELSIF  p_field_number = 215
      THEN
          -- Dependants
          igs_he_extract_fields_pkg.get_dependants
              (p_oss_dependants     =>  g_he_st_spa.dependants_cd,
               p_hesa_dependants    =>  p_value);

      ELSIF  p_field_number = 216
      THEN
        -- Eligibility for enhanced funding
        --Set the  default variable value as default value has to be calculated only for the down condition
        g_default_pro := 'N';

        IF g_he_submsn_header.validation_country IN ('ENGLAND') THEN

          -- Student must be FE student
          IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)) THEN

                igs_he_extract_fields_pkg.get_enh_fund_elig
                 (p_susa_enh_fund_elig   => g_he_en_susa.enh_fund_elig_cd,
                  p_spa_enh_fund_elig    => g_he_st_spa.enh_fund_elig_cd,
                  p_hesa_enh_fund_elig   => p_value);

                --If the value is calculated as NULL above then do the default processing for this field
                g_default_pro := 'Y' ;
          END IF;
        END IF;

      ELSIF  p_field_number = 217
      THEN
        --Additional Support Cost
        --Set the  default variable value as default value has to be calculated only for the down condition
        g_default_pro := 'N';

        IF g_he_submsn_header.validation_country IN   ('ENGLAND') THEN

          -- Student must be FE student
          IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)) THEN

                IF (g_he_en_susa.additional_sup_cost IS NOT NULL) THEN
                      -- LPad additional_sup_cost to 6 places
                      p_value := LPAD(g_he_en_susa.additional_sup_cost, 6,'0');
                END IF;

                --If the value is calculated as NULL above then do the default processing for this field
                g_default_pro := 'Y' ;
          END IF;
        END IF;

      ELSIF  p_field_number = 218
      THEN
        -- Learning Difficulty
        --Set the  default variable value as default value has to be calculated only for the down condition
        g_default_pro := 'N';

        IF g_he_submsn_header.validation_country IN   ('ENGLAND') THEN

          -- Student must be FE student
          IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)) THEN

                igs_he_extract_fields_pkg.get_learn_dif
                 (p_person_id            =>  p_person_id,
                  p_enrl_start_dt        =>  g_he_submsn_header.enrolment_start_date,
                  p_enrl_end_dt          =>  g_he_submsn_header.enrolment_end_date,
                  p_hesa_disability_type =>  p_value);

                --If the value is calculated as NULL above then do the default processing for this field
                g_default_pro := 'Y' ;
          END IF;
        END IF;

      ELSIF  p_field_number = 219
      THEN
        --Implied rate of council partial funding
        --Set the  default variable value as default value has to be calculated only for the down condition
        g_default_pro := 'N';

        IF g_he_submsn_header.validation_country IN   ('ENGLAND') THEN

          -- Student must be FE student
          -- AND ESF funded
          IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4))
             AND (g_field_defn.hesa_value.EXISTS(64)  AND g_field_defn.hesa_value(64) IN ('86','87','88','AA','AB','AC','AD'))
          THEN

                p_value := NVL(g_he_st_spa.implied_fund_rate,g_he_st_prog.implied_fund_rate);

                IF (p_value IS NOT NULL) THEN
                      p_value := LPAD(p_value, 3,'0');
                END IF;

                --If the value is calculated as NULL above then do the default processing for this field
                g_default_pro := 'Y' ;
          END IF;
        END IF;

      ELSIF  p_field_number = 220
      THEN
        --Government initiatives
        --Set the  default variable value as default value has to be calculated only for the down condition
        g_default_pro := 'N';

        IF g_he_submsn_header.validation_country IN   ('ENGLAND') THEN

          -- Student must be FE student
          IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)) THEN

                igs_he_extract_fields_pkg.get_gov_init
                 (p_spa_gov_initiatives_cd   => g_he_st_spa.gov_initiatives_cd,
                  p_prog_gov_initiatives_cd  => g_he_st_prog.gov_initiatives_cd,
                  p_hesa_gov_initiatives_cd  => p_value);

                --If the value is calculated as NULL above then do the default processing for this field
                g_default_pro := 'Y' ;
          END IF;
        END IF;

      ELSIF  p_field_number = 221
      THEN
        -- Number of units completed
        --Set the  default variable value as default value has to be calculated only for the down condition
        g_default_pro := 'N';

        IF g_he_submsn_header.validation_country IN   ('ENGLAND') THEN

          -- Student must be FE student
          IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)) THEN

                igs_he_extract_fields_pkg.get_units_completed
                 (p_person_id                => p_person_id,
                  p_course_cd                => p_course_cd,
                  p_enrl_end_dt              => g_he_submsn_header.enrolment_end_date,
                  p_spa_units_completed      => g_he_st_spa.units_completed,
                  p_hesa_units_completed     => p_value);

                IF (p_value IS NOT NULL) THEN
                      p_value := LPAD(p_value, 2,'0');
                END IF;

                --If the value is calculated as NULL above then do the default processing for this field
                g_default_pro := 'Y' ;
          END IF;
        END IF;

      ELSIF  p_field_number = 222
      THEN
        --Number of units to achieve full qualification
        --Set the  default variable value as default value has to be calculated only for the down condition
        g_default_pro := 'N';

        IF g_he_submsn_header.validation_country IN   ('ENGLAND') THEN

          -- Student must be FE student
          IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)) THEN

                p_value := NVL(g_he_st_spa.units_for_qual,g_he_st_prog.units_for_qual);

                IF (p_value IS NOT NULL) THEN
                      p_value := LPAD(p_value, 2,'0');
                END IF;

                --If the value is calculated as NULL above then do the default processing for this field
                g_default_pro := 'Y' ;
          END IF;
        END IF;

      ELSIF  p_field_number = 223
      THEN
        --Eligibility for disadvantage uplift
        --Set the  default variable value as default value has to be calculated only for the down condition
        g_default_pro := 'N';

        IF g_he_submsn_header.validation_country IN   ('ENGLAND') THEN

          -- Student must be FE student
          IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)) THEN

                igs_he_extract_fields_pkg.get_disadv_uplift_elig
                 (p_spa_disadv_uplift_elig_cd   => g_he_st_spa.disadv_uplift_elig_cd,
                  p_prog_disadv_uplift_elig_cd  => g_he_st_prog.disadv_uplift_elig_cd,
                  p_hesa_disadv_uplift_elig_cd  => p_value);

                --If the value is calculated as NULL above then do the default processing for this field
                g_default_pro := 'Y' ;
          END IF;
        END IF;

      ELSIF  p_field_number = 224
      THEN
        --Disadvantage uplift factor
        --Set the  default variable value as default value has to be calculated only for the down condition
        g_default_pro := 'N';

        IF g_he_submsn_header.validation_country IN   ('ENGLAND') THEN

          -- Student must be FE student
          IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)) THEN

                l_disadv_uplift_factor := NVL(g_he_en_susa.disadv_uplift_factor,g_he_st_spa.disadv_uplift_factor);

                IF (l_disadv_uplift_factor IS NOT NULL) THEN
                      p_value := Ltrim(To_Char(l_disadv_uplift_factor,'0.0000'));
                END IF;

                --If the value is calculated as NULL above then do the default processing for this field
                g_default_pro := 'Y' ;
          END IF;
        END IF;

      ELSIF  p_field_number = 225
      THEN
        --Franchised out arrangements
        --Set the  default variable value as default value has to be calculated only for the down condition
        g_default_pro := 'N';

        IF g_he_submsn_header.validation_country IN   ('ENGLAND') THEN

          -- Student must be FE student
          IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)) THEN

                igs_he_extract_fields_pkg.get_franch_out_arr
                 (p_spa_franch_out_arr_cd   => g_he_st_spa.franch_out_arr_cd,
                  p_prog_franch_out_arr_cd  => g_he_st_prog.franch_out_arr_cd,
                  p_hesa_franch_out_arr_cd  => p_value);

                --If the value is calculated as NULL above then do the default processing for this field
                g_default_pro := 'Y' ;
          END IF;
        END IF;

      ELSIF  p_field_number = 226
      THEN
        --Employer role
        --Set the  default variable value as default value has to be calculated only for the down condition
        g_default_pro := 'N';

        IF g_he_submsn_header.validation_country IN   ('ENGLAND','WALES') THEN

          -- Student must be FE student
          IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)) THEN

                igs_he_extract_fields_pkg.get_employer_role
                 (p_spa_employer_role_cd   => g_he_st_spa.employer_role_cd,
                  p_hesa_employer_role_cd  => p_value);

                --If the value is calculated as NULL above then do the default processing for this field
                g_default_pro := 'Y' ;
          END IF;
        END IF;

      -- anwest 19-Dec-2005 (4731723) HE360 - HESA REQUIREMENTS FOR 2005/06 REPORTING
      ELSIF  p_field_number = 227 THEN

        IF p_value IS NULL THEN

          IF g_field_defn.hesa_value.EXISTS(12) AND
             g_field_defn.hesa_value(12) IN ('6826') THEN

            igs_he_extract_fields_pkg.get_welsh_bacc_qual(p_person_id  => p_person_id,
                                                          p_welsh_bacc => p_value);

            IF p_value = '3' THEN

              IF g_he_submsn_header.validation_country = 'WALES' AND
                 g_en_stdnt_ps_att.commencement_dt > TO_DATE('31/07/2005', 'DD/MM/YYYY') AND
                 g_field_defn.hesa_value.EXISTS(41) AND
                 ((g_field_defn.hesa_value(41) >= 18 AND g_field_defn.hesa_value(41) <= 52) OR
                   g_field_defn.hesa_value(41) IN ('61', '97')) THEN

                null; -- Leave field value as '3'

              ELSE

                p_value := NULL;

              END IF;

            END IF;

          ELSE

            g_default_pro := 'N';
            p_value := NULL;

          END IF;

        END IF;

      END IF; -- for each field from 1 to  227

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);
          fnd_message.set_name('IGS','IGS_HE_FIELD_NUM');
          fnd_message.set_token('field_number',p_field_number);
          IGS_GE_MSG_STACK.ADD;
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT2_PKG.process_comb_fields');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

   END process_comb_fields;


   /*----------------------------------------------------------------------
   This procedure gets values for the individual fields to be
   submitted in the HESA STUDENT returns

   Parameters :
   p_person_id              Person_id for the student
   p_course_cd              Course Code that the student is attempting
   p_crv_version_number     Version Number of the course code
   p_student_inst_number    Student Instance Number
   p_field_number           Field Number currently being processed.
   p_value                  Calculated Value of the field.

      --changed the code for field 26  as a  part of HECR002.
      --If IGS_HE_ST_SPA_ALL.commencement date is NOT NULL then  assign  IGS_HE_ST_SPA_ALL.commencement date to p_value
      --elsif IGS_HE_ST_SPA_ALL.commencement date IS  NULL then  check if program transfer has taken palce
      --If program transfer has taken place then assign get the value of first program in chain for that person
      --(For the person having the same student instance number for the different program transfer are said to be in same chain)
      --and assign the corresponding IGS_EN_STDNT_PS_ATT.commencement_dt value to it
      --else if the program transfer has  not taken palce then get the IGS_EN_STDNT_PS_ATT.commencement_dt value
      --of course in context and assign it to field
   ----------------------------------------------------------------------*/
   PROCEDURE process_stdnt_fields
             (p_person_id           IN  igs_he_ex_rn_dat_ln.person_id%TYPE,
              p_course_cd           IN   igs_he_ex_rn_dat_ln.course_cd%TYPE,
              p_crv_version_number  IN   igs_he_ex_rn_dat_ln.crv_version_number%TYPE,
              p_student_inst_number IN   igs_he_ex_rn_dat_ln.student_inst_number%TYPE,
              p_field_number        IN   NUMBER,
              p_value               IN OUT NOCOPY   igs_he_ex_rn_dat_fd.value%TYPE)

   IS
   /***************************************************************
   Created By           :
   Date Created By      :
   Purpose              :This procedure gets the value of stduent related fields
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
   bayadav   25-Mar-02  Changed the code for field 26  as a  part of HECR002.
   bayadav   26-Mar-02  Changed the code for field 74  as a  part of HECR001.
   bayadav   19-Jul-02  Changed the call for IGS_HE_EXTRACT_FIELDS_PKG.get_year_of_student proc for fields 27 and 30 as per bug 2449010
   smaddali  23-Jul-02  Modified field 76 to call new procedure for bug 2452592
   bayadav   24-Oct-02  Modified the logic for field 148,4,33,43,44,45,46,49,50,153,6,14,17,27,29,
                        34,36,42,83,84,85,54,55,56,57,58,59,60,61,62,63,78,140,141,146 as a part of HEFD101(2636897)
   bayadav   02-Dec-02  Included 'WALES' also in the counrty list for field 140 as a part fo bug 2685091.Also made the default processing TRUE for other countries
   smaddali  03-Dec-02  Modified field 169 to remove dependency on field 148 for bug 2663717
   bayadav   09-Dec-02  Modified code logic field 29 as a part of bug 2685091
   bayadav   12-Dec-02  Included exists clause field 133 as a part of bug 2706787
   bayadav   16-Dec-02  Changed the code for default Processing for field 83 and 146 as a part of bug 2710907
   bayadav   16-Dec-02  Included 2 new parameters in procedure get_rsn_inst_left for field combined/student field 33 as a part of bug 2702100
   bayadav   16-Dec-02  Included 2 new parameters in procedure get_qual_obtained  for field combined/student field 37 and 38,39  as a part of bug 2702117
   bayadav   17-Dec-02  Changed the defualt value processing for combined field 155 and student field 140 as a part of bug 2713527
   bayadav   17-Dec-02  Changed the default value processing for combined field  34,36,42,83,84,85 and student field 34,36,42,83,84,191 as a part of bug 2714418
   smaddali  18-Dec-02  Modified field 191 to give format mask 00000 ,bug 2714010
   smaddali  25-Aug-03  Modified get_funding_src call to pass funding_source field for hefd208 - bug#2717751
   rbezawad  17-Sep-03  Modified the derivation of field 19 logic w.r.t. UCFD210 Build, Bug 2893542
   smaddali  13-Oct-03  Modified student fields 101 to 116 for bug#3163324, to derive only for WELSH students.
   smaddali  13-Oct-03  Modified calls to get_year_of_student to add 1 new parameter , for bug#3224246
   uudayapr  02-Nov-03  Modified get_inst_last_attended procedure by adding two new parameter.
   smaddali  14-Jan-04  Modified logic for field 19 , for bug#3370979
   jbaber    20-Sep-04  Modified as per HEFD350 - Statutory changes for 2004/05 Reporting
                        Modified fields: 27, 30
                        Created fields:  192-208
   jtmathew  01-Feb-05  Modified get_funding_src call to pass funding_source field at spa level - bug#3962575
 ***************************************************************/
     l_inst_id          igs_or_institution.govt_institution_cd%TYPE;
     l_index            NUMBER;
     l_dummy            VARCHAR2(50);
     l_dummy1  igs_ps_fld_of_study.govt_field_of_study%TYPE;
     l_dummy2  igs_ps_fld_of_study.govt_field_of_study%TYPE;
     l_dummy3  igs_ps_fld_of_study.govt_field_of_study%TYPE;
     l_fundlev igs_he_ex_rn_dat_fd.value%TYPE;
     l_spcstu  igs_he_ex_rn_dat_fd.value%TYPE;
     l_notact  igs_he_ex_rn_dat_fd.value%TYPE;
     l_mode    igs_he_ex_rn_dat_fd.value%TYPE;
     l_typeyr  igs_he_ex_rn_dat_fd.value%TYPE;
     l_fmly_name igs_pe_person.surname%TYPE;
     l_disadv_uplift_factor igs_he_st_spa.disadv_uplift_factor%TYPE;

     CURSOR c_subj(cp_field_of_study igs_ps_fld_of_study.field_of_study%TYPE)
     IS
     SELECT govt_field_of_study
     FROM igs_ps_fld_of_study
     WHERE field_of_study = cp_field_of_study;



   BEGIN

      p_value := NULL;
      g_default_pro := 'Y';
      l_disadv_uplift_factor := NULL;

      IF      p_field_number = 1
      THEN
          -- Record Type Identifier
          p_value := g_he_submsn_return.record_id;

      ELSIF  p_field_number = 2
      THEN
          -- Hesa Institution Id
          igs_he_extract_fields_pkg.get_hesa_inst_id
              (p_hesa_inst_id => p_value);

      ELSIF  p_field_number = 3
      THEN
          -- Campus Id
          igs_he_extract_fields_pkg.get_campus_id
              (p_location_cd => g_en_stdnt_ps_att.location_cd,
               p_campus_id   => p_value);

      ELSIF  p_field_number = 4
      THEN
          -- Student Identifier
          -- Pass in the Institution Id
          IF g_field_defn.hesa_value.EXISTS(2)
          THEN
              l_inst_id := g_field_defn.hesa_value(2);
          ELSE
              l_inst_id := 0;
          END IF;

         -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
          igs_he_extract_fields_pkg.get_stdnt_id
              (p_person_id              => p_person_id,
               p_inst_id                => l_inst_id,
               p_stdnt_id               => p_value,
               p_enrl_start_dt          =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt            =>  g_he_submsn_header.enrolment_end_date);

      ELSIF  p_field_number = 5
      THEN
          -- Scottish Candidate Number
          IF g_he_st_spa.associate_scott_cand = 'Y'
          THEN
          -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
              igs_he_extract_fields_pkg.get_alt_pers_id
                 (p_person_id           => p_person_id,
                  p_id_type             => 'UCASREGNO',
                  p_api_id              => p_value,
                  p_enrl_start_dt       =>  g_he_submsn_header.enrolment_start_date,
                  p_enrl_end_dt         =>  g_he_submsn_header.enrolment_end_date);
          END IF;

      ELSIF  p_field_number = 6
      THEN
          -- FE Student Marker
          -- First get the Funding Source
          -- smaddali modified this call to pass funding_source field for hefd208 - bug#2717751
          -- jtmathew modified this call to pass funding_source field at spa level - bug#3962575
          igs_he_extract_fields_pkg.get_funding_src
              (p_course_cd             => p_course_cd,
               p_version_number        => p_crv_version_number,
               p_spa_fund_src          => g_en_stdnt_ps_att.funding_source,
               p_poous_fund_src        => g_he_poous.funding_source,
               p_oss_fund_src          => g_field_defn.oss_value(64),
               p_hesa_fund_src         => g_field_defn.hesa_value(64));

          -- Next get the Fundability Code
          IF g_field_defn.oss_value.EXISTS(64) THEN
          -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
           igs_he_extract_fields_pkg.get_fundability_cd
              (p_person_id             => p_person_id,
               p_susa_fund_cd          => g_he_en_susa.fundability_code,
               p_spa_funding_source    => g_en_stdnt_ps_att.funding_source,
               p_poous_fund_cd         => g_he_poous.fundability_cd,
               p_prg_fund_cd           => g_he_st_prog.fundability,
               p_prg_funding_source    => g_field_defn.oss_value(64),
               p_oss_fund_cd           => g_field_defn.oss_value(65),
               p_hesa_fund_cd          => g_field_defn.hesa_value(65),
               p_enrl_start_dt         =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt           =>  g_he_submsn_header.enrolment_end_date);
           END IF;

          -- Now get the FE Student Marker
          IF  g_he_submsn_header.validation_country IN  ('ENGLAND','WALES') AND g_field_defn.oss_value.EXISTS(64) AND g_field_defn.oss_value.EXISTS(65) THEN
           igs_he_extract_fields_pkg.get_fe_stdnt_mrker
              (p_spa_fe_stdnt_mrker    =>  g_he_st_spa.fe_student_marker,
               p_fe_program_marker     =>  g_he_st_prog.fe_program_marker,
               p_funding_src           =>  g_field_defn.oss_value(64),
               p_fundability_cd        =>  g_field_defn.oss_value(65),
               p_oss_fe_stdnt_mrker    =>  g_field_defn.oss_value(6),
               p_hesa_fe_stdnt_mrker   =>  p_value);
           ELSE

              g_default_pro := 'N';

           END IF;


      ELSIF  p_field_number = 7
      THEN
          -- Family Name
          -- smaddali added translate for bug#3223991
          -- modified the logic to remove the invalid characters /, @, \ for Bug# 3681149
          -- this trasnlate function translates a to a and all other characters in the FROM list to NULL
          -- so all the characters 1234567890~`!#$%^&*()_+={}[]|:;"<>? which are invalid will be removed from p_value
          IF g_pe_person.given_names IS NULL
          THEN
              p_value := TRANSLATE( substr(g_pe_person.full_name,1,40),'a1234567890~`!#$%^&*()_+={}[]|:;"<>?,/@\','a') ;
              -- Set value of forename = '9'
              g_field_defn.hesa_value(8) := '9';
          ELSE
              p_value := TRANSLATE( substr(g_pe_person.surname,1,40),'a1234567890~`!#$%^&*()_+={}[]|:;"<>?,/@\','a') ;
          END IF;

      ELSIF  p_field_number = 8
      THEN
          -- Forename
          -- smaddali added translate for bug#3223991
          -- modified the logic to remove the invalid characters /, @, \ for Bug# 3681149
          -- this trasnlate function translates a to a and all other characters in the FROM list to NULL
          -- so all the characters 1234567890~`!#$%^&*()_+={}[]|:;"<>? which are invalid will be removed from p_value
          -- If value set earlier in field 7, use that
          IF g_field_defn.hesa_value.EXISTS(8)
          THEN
              IF g_field_defn.hesa_value(8) = '9'
              THEN
                   p_value := g_field_defn.hesa_value(8);
              ELSE
                   p_value := TRANSLATE( substr(g_pe_person.given_names,1,40),'a1234567890~`!#$%^&*()_+={}[]|:;"<>?,/@\','a') ;
              END IF;
          ELSE
              p_value := TRANSLATE( substr(g_pe_person.given_names,1,40),'a1234567890~`!#$%^&*()_+={}[]|:;"<>?,/@\','a') ;
          END IF;


      ELSIF  p_field_number = 9
      THEN
          -- Family Name on 16th Birthday
          -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
          l_fmly_name := NULL;
          igs_he_extract_fields_pkg.get_fmly_name_on_16_bday
              (p_person_id              => p_person_id,
               p_fmly_name              => l_fmly_name,
               p_enrl_start_dt          => g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt            => g_he_submsn_header.enrolment_end_date);
          -- smaddali added translate for bug#3223991
          -- modified the logic to remove the invalid characters /, @, \ for Bug# 3681149
          -- this trasnlate function translates a to a and all other characters in the FROM list to NULL
          -- so all the characters 1234567890~`!#$%^&*()_+={}[]|:;"<>? which are invalid will be removed from p_value
          p_value := TRANSLATE( substr(l_fmly_name,1,40),'a1234567890~`!#$%^&*()_+={}[]|:;"<>?,/@\','a') ;


      ELSIF  p_field_number = 10
      THEN
          -- Date of Birth
          p_value := To_Char(g_pe_person.birth_dt, 'DD/MM/YYYY');

      ELSIF  p_field_number = 11
      THEN
          -- Gender
          igs_he_extract_fields_pkg.get_gender
              (p_gender           => g_pe_person.sex,
               p_hesa_gender      => p_value);

      ELSIF  p_field_number = 12
      THEN
          -- Domicile
          igs_he_extract_fields_pkg.get_domicile
              (p_ad_domicile       => g_he_ad_dtl.domicile_cd,
               p_spa_domicile      => g_he_st_spa.domicile_cd,
               p_hesa_domicile     => p_value);

      ELSIF  p_field_number = 13
      THEN
          -- Nationality
          -- smaddali 11-dec-03   Modified for bug#3235753 , added 1 new parameter
          igs_he_extract_fields_pkg.get_nationality
              (p_person_id         => p_person_id,
               p_nationality       => p_value,
               p_enrl_start_dt     =>  g_he_submsn_header.enrolment_start_date);

      -- Modified the field derivation to remove the reference of DOMICILE field (12)
      -- as part of HEFD311 - July 2004 Changes enhancement bug, 2956444
      ELSIF  p_field_number = 14
      THEN
         -- Ethnicity
         igs_he_extract_fields_pkg.get_ethnicity (
           p_person_id         => p_person_id,
           p_oss_eth           => g_pe_stat_v.ethnic_origin_id,
           p_hesa_eth          => p_value);

      ELSIF  p_field_number = 15
      THEN
          -- Disability Allowance
          igs_he_extract_fields_pkg.get_disablity_allow
              (p_oss_dis_allow     => g_he_en_susa.disability_allow,
               p_hesa_dis_allow    => p_value);

      ELSIF  p_field_number = 16
      THEN
          -- Diability
          -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
          igs_he_extract_fields_pkg.get_disablity
              (p_person_id         => p_person_id,
               p_disability        => p_value,
               p_enrl_start_dt     =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt       =>  g_he_submsn_header.enrolment_end_date);

      ELSIF  p_field_number = 17
      THEN


        IF (( g_field_defn.hesa_value.EXISTS(6) AND g_field_defn.hesa_value(6) IN (1,3)) AND   g_he_submsn_header.validation_country = 'ENGLAND') THEN
          -- Additional Support Band
          igs_he_extract_fields_pkg.get_addnl_supp_band
              (p_oss_supp_band     =>  g_he_en_susa.additional_sup_band,
               p_hesa_supp_band    =>  p_value);

          ELSE
              p_value := NULL;
              g_default_pro := 'N';
          END IF;


      ELSIF  p_field_number = 18
      THEN
           -- Not Used
           p_value := NULL;

      ELSIF  p_field_number = 19
      THEN

          --Get the field 41 value - Qualification Aim
          -- smaddali 21-jan-04  added 2 new parameters for bug#3360646
          igs_he_extract_fields_pkg.get_gen_qual_aim
              (p_person_id           =>  p_person_id,
               p_course_cd           =>  p_course_cd,
               p_version_number      =>  p_crv_version_number,
               p_spa_gen_qaim        =>  g_he_st_spa.student_qual_aim,
               p_hesa_gen_qaim       =>  g_field_defn.hesa_value(41),
               p_enrl_start_dt       =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt         =>  g_he_submsn_header.enrolment_end_date,
               p_awd_conf_start_dt   =>  l_awd_conf_start_dt);

          -- Get the field 70 value - Mode of Study
          igs_he_extract_fields_pkg.get_mode_of_study
              (p_person_id         =>  p_person_id,
               p_course_cd         =>  p_course_cd,
               p_version_number    =>  p_crv_version_number,
               p_enrl_start_dt     =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt       =>  g_he_submsn_header.enrolment_end_date,
               p_susa_study_mode   =>  g_he_en_susa.study_mode,
               p_poous_study_mode  =>  g_he_poous.mode_of_study,
               p_attendance_type   =>  g_en_stdnt_ps_att.attendance_type,
               p_mode_of_study     =>  g_field_defn.hesa_value(70));

          -- Modified the derivation of this field to derive regardless of the value of the HESA MODE field (70)
          -- as part of HEFD311 - July 2004 Changes enhancement bug, 2956444

          -- Get the field 133 value - UCAS NUM
          IF g_he_st_spa.associate_ucas_number = 'Y' THEN
          -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
            igs_he_extract_fields_pkg.get_ucasnum
               (p_person_id             => p_person_id,
                p_ucasnum               => g_field_defn.hesa_value(133),
                p_enrl_start_dt         =>  g_he_submsn_header.enrolment_start_date,
                p_enrl_end_dt           =>  g_he_submsn_header.enrolment_end_date);
          -- smaddali added else logic to create the table index for hesa_value(133), for bug#3370979
          ELSE
             g_field_defn.hesa_value(133) := NULL;
          END IF;

          IF g_field_defn.hesa_value.EXISTS(41) AND g_field_defn.hesa_value.EXISTS(133) THEN
            -- Calculate the field 19 value - Year left last institution
            igs_he_extract_fields_pkg.get_yr_left_last_inst
              (p_person_id      => p_person_id,
               p_com_dt         => g_en_stdnt_ps_att.commencement_dt,
               p_hesa_gen_qaim  => g_field_defn.hesa_value(41),
               p_ucasnum        => g_field_defn.hesa_value(133),
               p_year           => p_value);
          END IF ;

      ELSIF  p_field_number = 20
      THEN
           -- Not Used
           p_value := NULL;

      ELSIF  p_field_number = 21
      THEN
          -- Highest Qualification on Entry
          p_value := g_he_st_spa.highest_qual_on_entry;

      ELSIF  p_field_number = 22
      THEN
           -- Not Used
           p_value := NULL;

      ELSIF  p_field_number = 23
      THEN
           -- Not Used
           p_value := NULL;

      ELSIF  p_field_number = 24
      THEN
           -- Not Used
           p_value := NULL;

      ELSIF  p_field_number = 25
      THEN

          -- Get the field 133 value - UCAS NUM
          IF NOT g_field_defn.hesa_value.EXISTS(133) THEN
             IF  g_he_st_spa.associate_ucas_number = 'Y' THEN
               igs_he_extract_fields_pkg.get_ucasnum
                  (p_person_id             => p_person_id,
                   p_ucasnum               => g_field_defn.hesa_value(133),
                   p_enrl_start_dt         =>  g_he_submsn_header.enrolment_start_date,
                   p_enrl_end_dt           =>  g_he_submsn_header.enrolment_end_date);
             ELSE
               g_field_defn.hesa_value(133) := NULL;
             END IF;
          END IF;

          -- sjlaporte use date comparison rather than text bug 3933715
          -- Occupation Code
          IF g_en_stdnt_ps_att.commencement_dt  <= TO_DATE('31/07/2002', 'DD/MM/YYYY')
             OR (g_field_defn.hesa_value(133) IS NOT NULL AND g_field_defn.hesa_value(133) BETWEEN '000000010' AND '019999999')
          THEN
              p_value := g_he_st_spa.occcode;
          ELSE
             p_value := NULL;
          END IF;

      ELSIF  p_field_number = 26
      THEN

       -- Commencement Date
         igs_he_extract_fields_pkg.get_commencement_dt( p_hesa_commdate         => g_he_st_spa.commencement_dt,
                                                        p_enstdnt_commdate      => g_en_stdnt_ps_att.commencement_dt,
                                                        p_person_id             => p_person_id ,
                                                        p_course_cd             => p_course_cd  ,
                                                        p_version_number        => p_crv_version_number,
                                                        p_student_inst_number   => p_student_inst_number,
                                                        p_final_commdate        => p_value );


      ELSIF  p_field_number = 27
      THEN
          -- New Entrant to HE
          -- smaddali removed the call to derive field 72 value and added the call to derive field 30
          -- because the dependency should be on field 30 not on 72 , bug 2452551
          -- First get field 30, Year of student
          -- jbaber added p_susa_year_of_student for HEFD350
          igs_he_extract_fields_pkg.get_year_of_student
              (p_person_id            => p_person_id ,
               p_course_cd            => p_course_cd ,
               p_unit_set_cd          => g_as_su_setatmpt.unit_set_cd,
               p_sequence_number      => g_as_su_setatmpt.sequence_number,
               p_year_of_student      => g_field_defn.hesa_value(30),
               p_enrl_end_dt          => g_he_submsn_header.enrolment_end_date,
               p_susa_year_of_student => g_he_en_susa.year_stu);

           --get field 41 value also first as it is required for  this calculation
           -- Qualification Aim
           IF NOT g_field_defn.hesa_value.EXISTS(41) THEN
           -- smaddali 21-jan-04  added 2 new parameters for bug#3360646
             igs_he_extract_fields_pkg.get_gen_qual_aim
              (p_person_id           =>  p_person_id,
               p_course_cd           =>  p_course_cd,
               p_version_number      =>  p_crv_version_number,
               p_spa_gen_qaim        =>  g_he_st_spa.student_qual_aim,
               p_hesa_gen_qaim       =>  g_field_defn.hesa_value(41),
               p_enrl_start_dt       =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt         =>  g_he_submsn_header.enrolment_end_date,
               p_awd_conf_start_dt   =>  l_awd_conf_start_dt);
           END IF ;


          -- Now calculate New Entrant to HE
          -- smaddali replaced dependency with field 72 to field 30 for bug 2452551
          IF  g_field_defn.hesa_value.EXISTS(6)
          AND g_field_defn.hesa_value.EXISTS(21)
          AND g_field_defn.hesa_value.EXISTS(30)
          AND g_field_defn.hesa_value.EXISTS(12)
          AND (g_field_defn.hesa_value.EXISTS(41) and (
                                                    (g_field_defn.hesa_value(41) >= 02 and g_field_defn.hesa_value(41) <= 52)
                                                                                    or
                                                     (g_field_defn.hesa_value(41) IN (61,62,97,98))
                                                   )  )           THEN
              igs_he_extract_fields_pkg.get_new_ent_to_he
                  (p_fe_stdnt_mrker        => g_field_defn.hesa_value(6),
                   p_susa_new_ent_to_he    => g_he_en_susa.new_he_entrant_cd,
                   p_yop                   => g_field_defn.hesa_value(30),
                   p_high_qual_on_ent      => g_field_defn.hesa_value(21),
                   p_domicile              => g_field_defn.hesa_value(12),
                   p_hesa_new_ent_to_he    => p_value);

          END IF;



          IF   (g_field_defn.hesa_value.EXISTS(41) and (
                                                    (g_field_defn.hesa_value(41) >= 02 and g_field_defn.hesa_value(41) <= 52)
                                                                                    or
                                                     (g_field_defn.hesa_value(41) IN (61,62,97,98))
                                                   )  ) THEN
                  g_default_pro := 'Y' ;
          ELSE
                  -- The default value should not be calculated for  any other condition
                  g_default_pro := 'N' ;
          END IF;

      ELSIF  p_field_number = 28
      THEN
          -- Special students
          igs_he_extract_fields_pkg.get_special_student
              (p_ad_special_student    => g_he_ad_dtl.special_student_cd,
               p_spa_special_student   => g_he_st_spa.special_student,
               p_oss_special_student   => g_field_defn.oss_value(28),
               p_hesa_special_student  => p_value);

      ELSIF  p_field_number = 29
      THEN

        --get the quail1 field 37 and 38 value required in calculating field 29 value
        igs_he_extract_fields_pkg.get_qual_obtained
              (p_person_id        => p_person_id,
               p_course_cd        => p_course_cd,
               p_enrl_start_dt    => l_awd_conf_start_dt,
               p_enrl_end_dt      => l_awd_conf_end_dt,
               p_oss_qual_obt1    => g_field_defn.oss_value(37),
               p_oss_qual_obt2    => g_field_defn.oss_value(38),
               p_hesa_qual_obt1   => g_field_defn.hesa_value(37),
               p_hesa_qual_obt2   => g_field_defn.hesa_value(38),
               p_classification   => g_field_defn.hesa_value(39));


        --Calculating field 53 first requred for field 146 calcualtion
        igs_he_extract_fields_pkg.get_teach_train_crs_id
          (p_prg_ttcid            =>  g_he_st_prog.teacher_train_prog_id,
           p_spa_ttcid            =>  g_he_st_spa.teacher_train_prog_id,
           p_hesa_ttcid           =>  g_field_defn.hesa_value(53));


        --Calculating field 146 first required for field 29
        -- Outcome of ITT Program
        IF g_he_submsn_header.validation_country IN   ('ENGLAND','WALES') THEN
              igs_he_extract_fields_pkg.get_itt_outcome
                  (p_oss_itt_outcome     =>  g_he_st_spa.itt_prog_outcome,
                   p_teach_train_prg     =>  g_field_defn.hesa_value(53),
                   p_hesa_itt_outcome    =>   g_field_defn.hesa_value(146));
        END IF;

        --Set the default value of g_default_pro as N here only as default processing has to be done only in one case which is written as below
        g_default_pro := 'N' ;

        --Start calculating value of field 29 as all the required fields have been calculated above
        IF g_he_submsn_header.validation_country IN   ('ENGLAND','WALES','SCOTLAND') THEN
          -- Get Teacher Reference Num
          IF g_he_st_spa.associate_teach_ref_num = 'Y'
          THEN
          -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
              igs_he_extract_fields_pkg.get_alt_pers_id
                  (p_person_id            => p_person_id,
                   p_id_type              => 'TEACH REF',
                   p_api_id               => p_value,
                   p_enrl_start_dt        =>  g_he_submsn_header.enrolment_start_date,
                   p_enrl_end_dt          =>  g_he_submsn_header.enrolment_end_date);

          END IF;
           --In case the value calculated above is NULL then calculate the defualt value
          IF p_value IS NULL THEN
             IF (((g_field_defn.hesa_value.EXISTS(146)  AND g_field_defn.hesa_value(146) = '1') OR
                ((g_field_defn.hesa_value.EXISTS(53)  AND g_field_defn.hesa_value(53) IN (1,6,7)) AND
                 ((g_field_defn.hesa_value.EXISTS(37) AND g_field_defn.hesa_value(37) = 20) OR
                  (g_field_defn.hesa_value.EXISTS(38) AND g_field_defn.hesa_value(38) = 20)))))  THEN
                     g_default_pro := 'Y' ;
              END IF;
          END IF;
        END IF;

     ELSIF  p_field_number = 30
      THEN
          -- Year of Student
          --smaddali added this check to see if it already is calculated
          -- because of bug 2452551 where field 30 is being calculated for field 27
          IF  g_field_defn.hesa_value.EXISTS(30)
          THEN
              -- Calculated earlier, for field 27
              p_value :=   g_field_defn.hesa_value(30);
          ELSE

             -- jbaber added p_susa_year_of_student for HEFD350
             igs_he_extract_fields_pkg.get_year_of_student
              (p_person_id            => p_person_id,
               p_course_cd            => p_course_cd,
               p_unit_set_cd          => g_as_su_setatmpt.unit_set_cd,
               p_sequence_number      => g_as_su_setatmpt.sequence_number,
               p_year_of_student      => p_value,
               p_enrl_end_dt          => g_he_submsn_header.enrolment_end_date,
               p_susa_year_of_student => g_he_en_susa.year_stu);

           END IF ;

            --smaddali 01-jul-2002 lpadding with 0  for bug 2436769
            p_value := LPAD(p_value, 2,'0') ;

      ELSIF  p_field_number = 31
      THEN
          -- Term Time Accomodation
          -- Calculate field 71, location of study first
          igs_he_extract_fields_pkg.get_study_location
              (p_susa_study_location    => g_he_en_susa.study_location,
               p_poous_study_location   => g_he_poous.location_of_study,
               p_prg_study_location     => g_he_st_prog.location_of_study,
               p_oss_study_location     => g_field_defn.oss_value(71),
               p_hesa_study_location    => g_field_defn.hesa_value(71));

          -- Next calcualte TTA
          -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
          igs_he_extract_fields_pkg.get_term_time_acc
              (p_person_id            =>  p_person_id,
               p_susa_term_time_acc   =>  g_he_en_susa.term_time_accom,
               p_study_location       =>  g_field_defn.oss_value(71),
               p_hesa_term_time_acc   =>  p_value,
               p_enrl_start_dt        =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt          =>  g_he_submsn_header.enrolment_end_date);

      ELSIF  p_field_number = 32
      THEN
           -- Not Used
           p_value := NULL;

      ELSIF  p_field_number = 33
      THEN
          -- Reason for leaving institution
          igs_he_extract_fields_pkg.get_rsn_inst_left
              (p_person_id            => p_person_id,
               p_course_cd            => p_course_cd ,
               p_crs_req_comp_ind     => g_en_stdnt_ps_att.course_rqrmnt_complete_ind,
               p_crs_req_comp_dt      => g_en_stdnt_ps_att.course_rqrmnts_complete_dt,
               p_disc_reason_cd       => g_en_stdnt_ps_att.discontinuation_reason_cd,
               p_disc_dt              => g_en_stdnt_ps_att.discontinued_dt,
               p_enrl_start_dt        => l_awd_conf_start_dt,
               p_enrl_end_dt          => l_awd_conf_end_dt,
               p_rsn_inst_left        => p_value);

      ELSIF  p_field_number = 34
      THEN
         g_default_pro:= 'N';

          -- Completion Status
          -- Need Field 6, FE Student Marker to be completed
          IF  g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)
          THEN
              -- Calculate Completion Status
              --smaddali added new parameter p_course_cd to this call for bug 2396174
              igs_he_extract_fields_pkg.get_completion_status
                  (p_person_id            => p_person_id,
                   p_course_cd            => p_course_cd ,
                   p_susa_comp_status     => g_he_en_susa.completion_status,
                   p_fe_stdnt_mrker       => g_field_defn.hesa_value(6),
                   p_crs_req_comp_ind     => g_en_stdnt_ps_att.course_rqrmnt_complete_ind,
                   p_discont_date         => g_en_stdnt_ps_att.discontinued_dt,
                   p_hesa_comp_status     => p_value);
              g_default_pro:= 'Y';
         END IF;

      ELSIF  p_field_number = 35
      THEN -- DATELEFT - only report this field if SPA completed within current reporting period

          IF g_en_stdnt_ps_att.course_rqrmnt_complete_ind = 'Y'
          AND g_en_stdnt_ps_att.course_rqrmnts_complete_dt <= g_he_submsn_header.enrolment_end_date
          THEN -- report Completion Date
              p_value := To_Char(g_en_stdnt_ps_att.course_rqrmnts_complete_dt, 'DD/MM/YYYY');
          ELSIF g_en_stdnt_ps_att.discontinued_dt IS NOT NULL
            AND g_en_stdnt_ps_att.discontinued_dt <= g_he_submsn_header.enrolment_end_date
          THEN -- report Discontinuation Date
              p_value := To_Char(g_en_stdnt_ps_att.discontinued_dt, 'DD/MM/YYYY');
          END IF;

      ELSIF  p_field_number = 36
      THEN
          g_default_pro:= 'N';
          -- Good Standing Marker
          IF  g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)
          THEN
              igs_he_extract_fields_pkg.get_good_stand_mrkr
                   (p_susa_good_st_mk      => g_he_en_susa.good_stand_marker,
                    p_fe_stdnt_mrker       => g_field_defn.hesa_value(6),
                    p_crs_req_comp_ind     => g_en_stdnt_ps_att.course_rqrmnt_complete_ind,
                    p_discont_date         => g_en_stdnt_ps_att.discontinued_dt,
                    p_hesa_good_st_mk      => p_value);
          g_default_pro:= 'Y';
          END IF;

      ELSIF  p_field_number = 37
      THEN
          -- Qualificationa Obtained 1
          -- Get fields 37, 38 and 39 together.
          IF g_field_defn.hesa_value.EXISTS(37)  THEN
             p_value := g_field_defn.hesa_value(37) ;
          ELSE
            igs_he_extract_fields_pkg.get_qual_obtained
              (p_person_id        => p_person_id,
               p_course_cd        => p_course_cd,
               p_enrl_start_dt    => l_awd_conf_start_dt,
               p_enrl_end_dt      => l_awd_conf_end_dt,
               p_oss_qual_obt1    => g_field_defn.oss_value(37),
               p_oss_qual_obt2    => g_field_defn.oss_value(38),
               p_hesa_qual_obt1   => p_value,
               p_hesa_qual_obt2   => g_field_defn.hesa_value(38),
               p_classification   => g_field_defn.hesa_value(39));
          END IF ;

      ELSIF  p_field_number = 38
      THEN
          -- Qualification Obtained 2
          -- If not calculated earlier, calculate now.
          IF  g_field_defn.hesa_value.EXISTS(38)
          THEN
              p_value :=  g_field_defn.hesa_value(38);
          ELSE
              igs_he_extract_fields_pkg.get_qual_obtained
                  (p_person_id        => p_person_id,
                   p_course_cd        => p_course_cd,
                   p_enrl_start_dt    => l_awd_conf_start_dt,
                   p_enrl_end_dt      => l_awd_conf_end_dt,
                   p_oss_qual_obt1    => g_field_defn.oss_value(37),
                   p_oss_qual_obt2    => g_field_defn.oss_value(38),
                   p_hesa_qual_obt1   => g_field_defn.hesa_value(37),
                   p_hesa_qual_obt2   => p_value,
                   p_classification   => g_field_defn.hesa_value(39));

          END IF;

      ELSIF  p_field_number = 39
      THEN
          -- HESA Classification
          -- If not calculated earlier, calculate now.
          IF  g_field_defn.hesa_value.EXISTS(39)
          THEN
              p_value :=  g_field_defn.hesa_value(39);
          ELSE
              igs_he_extract_fields_pkg.get_qual_obtained
                  (p_person_id        => p_person_id,
                   p_course_cd        => p_course_cd,
                   p_enrl_start_dt    => l_awd_conf_start_dt,
                   p_enrl_end_dt      => l_awd_conf_end_dt,
                   p_oss_qual_obt1    => g_field_defn.oss_value(37),
                   p_oss_qual_obt2    => g_field_defn.oss_value(38),
                   p_hesa_qual_obt1   => g_field_defn.hesa_value(37),
                   p_hesa_qual_obt2   => g_field_defn.hesa_value(38),
                   p_classification   => p_value);
          END IF;

      ELSIF  p_field_number = 40
      THEN
          -- Program of Study Title
          p_value := g_ps_ver.title;

      ELSIF  p_field_number = 41
      THEN


               IF  g_field_defn.hesa_value.EXISTS(41)
                  THEN
                      -- Calculated earlier, for field 27
                      p_value :=   g_field_defn.hesa_value(41);

               ELSE
                  -- Qualification Aim
                  -- smaddali 21-jan-04  added 2 new parameters for bug#3360646
                  igs_he_extract_fields_pkg.get_gen_qual_aim
                      (p_person_id           =>  p_person_id,
                       p_course_cd           =>  p_course_cd,
                       p_version_number      =>  p_crv_version_number,
                       p_spa_gen_qaim        =>  g_he_st_spa.student_qual_aim,
                       p_hesa_gen_qaim       =>  p_value,
                       p_enrl_start_dt       =>  g_he_submsn_header.enrolment_start_date,
                       p_enrl_end_dt         =>  g_he_submsn_header.enrolment_end_date,
                       p_awd_conf_start_dt   =>  l_awd_conf_start_dt);
                END IF;


      ELSIF  p_field_number = 42
      THEN
          g_default_pro:= 'N';
          -- FE General Qualification Aim
          IF  g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)
          THEN
              igs_he_extract_fields_pkg.get_fe_qual_aim
                   (p_spa_fe_qual_aim      => g_he_st_spa.student_fe_qual_aim,
                    p_fe_stdnt_mrker       => g_field_defn.hesa_value(6),
                    p_course_cd            => p_course_cd,
                    p_version_number       => p_crv_version_number,
                    p_hesa_fe_qual_aim     => p_value);
             g_default_pro:= 'Y';
           END IF;

      ELSIF  p_field_number = 43
      THEN

           -- Check for details at the SPA HESA Details level
           IF g_he_st_spa.qual_aim_subj1 IS NOT NULL THEN
                 OPEN c_subj(g_he_st_spa.qual_aim_subj1);
                 FETCH c_subj INTO p_value;
                 CLOSE c_subj;

           ELSE
             -- Qualification Aim, Subject 1
             igs_he_extract_fields_pkg.get_qual_aim_sbj
              (p_course_cd            => p_course_cd,
               p_version_number       => p_crv_version_number,
               p_subject1             => p_value,
               p_subject2             => g_field_defn.hesa_value(44),
               p_subject3             => g_field_defn.hesa_value(45),
               p_prop_ind             => g_field_defn.hesa_value(46));

            END IF;

      ELSIF  p_field_number = 44
      THEN

           -- Check for details at the SPA HESA Details level
           IF g_he_st_spa.qual_aim_subj1 IS NOT NULL THEN

                IF g_he_st_spa.qual_aim_subj2 IS NOT NULL THEN
                    OPEN c_subj(g_he_st_spa.qual_aim_subj2);
                    FETCH c_subj INTO p_value;
                    CLOSE c_subj;
                ELSE
                    -- derive NULL as there is no value for subj2
                    p_value := NULL;
                END IF;

           ELSE
                  -- Qualification Aim, Subject 2
                  IF g_field_defn.hesa_value.EXISTS(44)
                  THEN
                      -- Calculated earlier..
                      p_value := g_field_defn.hesa_value(44);
                  ELSE
                      -- Not calculated earlier, calculate now
                      igs_he_extract_fields_pkg.get_qual_aim_sbj
                          (p_course_cd         => p_course_cd,
                           p_version_number    => p_crv_version_number,
                           p_subject1          => l_dummy1,
                           p_subject2          => p_value,
                           p_subject3          => g_field_defn.hesa_value(45),
                           p_prop_ind          => g_field_defn.hesa_value(46));
                  END IF;
          END IF;

      ELSIF  p_field_number = 45
      THEN

           -- Check for details at the SPA HESA Details level
           IF g_he_st_spa.qual_aim_subj1 IS NOT NULL THEN

                IF g_he_st_spa.qual_aim_subj3 IS NOT NULL THEN
                    OPEN c_subj(g_he_st_spa.qual_aim_subj3);
                    FETCH c_subj INTO p_value;
                    CLOSE c_subj;
                ELSE
                    -- derive NULL as there is no value for subj3
                    p_value := NULL;
                END IF;

           ELSE
                  -- Qualification Aim, Subject 3
                  IF g_field_defn.hesa_value.EXISTS(45)
                  THEN
                      -- Calculated earlier..
                      p_value := g_field_defn.hesa_value(45);
                  ELSE
                      -- Not calculated earlier, calculate now
                      igs_he_extract_fields_pkg.get_qual_aim_sbj
                          (p_course_cd         => p_course_cd,
                           p_version_number    => p_crv_version_number,
                           p_subject1          => l_dummy1,
                           p_subject2          => l_dummy2,
                           p_subject3          => p_value,
                           p_prop_ind          => g_field_defn.hesa_value(46));
                  END IF;
          END IF;


      ELSIF  p_field_number = 46
      THEN

          IF g_he_st_spa.qual_aim_subj1 IS NOT NULL OR
             g_he_st_spa.qual_aim_proportion IS NOT NULL OR
             g_he_st_spa.qual_aim_subj2 IS NOT NULL OR
             g_he_st_spa.qual_aim_subj3 IS NOT NULL
          THEN

              igs_he_extract_fields_pkg.get_qual_aim_sbj1(
                     p_qual_aim_subj1    => g_he_st_spa.qual_aim_subj1,
                     p_qual_aim_subj2    => g_he_st_spa.qual_aim_subj2,
                     p_qual_aim_subj3    => g_he_st_spa.qual_aim_subj3,
                     p_oss_qualaim_sbj   => g_he_st_spa.qual_aim_proportion,
                     p_hesa_qualaim_sbj  => p_value);

          ELSE

                  -- Proportion Indicator
                  IF g_field_defn.hesa_value.EXISTS(46)
                  THEN
                      -- Calculated earlier..
                      p_value := g_field_defn.hesa_value(46);
                  ELSE
                      -- Not calculated earlier, calculate now
                      igs_he_extract_fields_pkg.get_qual_aim_sbj
                          (p_course_cd         => p_course_cd,
                           p_version_number    => p_crv_version_number,
                           p_subject1          => l_dummy1,
                           p_subject2          => l_dummy2,
                           p_subject3          => l_dummy3,
                           p_prop_ind          => p_value);
                  END IF;

         END IF;

      ELSIF  p_field_number = 47
      THEN
          -- Awarding Body 1
          IF  g_field_defn.oss_value.EXISTS(37)
          AND g_field_defn.oss_value.EXISTS(38)
          THEN
              igs_he_extract_fields_pkg.get_awd_body_12
                  (p_course_cd         =>  p_course_cd,
                   p_version_number    =>  p_crv_version_number,
                   p_awd1              =>  g_field_defn.oss_value(37),
                   p_awd2              =>  g_field_defn.oss_value(38),
                   p_awd_body1         =>  p_value,
                   p_awd_body2         =>  g_field_defn.hesa_value(48));

          END IF;
      ELSIF  p_field_number = 48
      THEN
          -- Awarding Body 2
          IF g_field_defn.hesa_value.EXISTS(48)
          THEN
              -- Calculated earlier for field 47..
              p_value := g_field_defn.hesa_value(48);
          ELSIF  g_field_defn.oss_value.EXISTS(37)
          AND    g_field_defn.oss_value.EXISTS(38)
          THEN
              -- Not calculated therefore calculate.
              igs_he_extract_fields_pkg.get_awd_body_12
                  (p_course_cd         =>  p_course_cd,
                   p_version_number    =>  p_crv_version_number,
                   p_awd1              =>  g_field_defn.oss_value(37),
                   p_awd2              =>  g_field_defn.oss_value(38),
                   p_awd_body1         =>  g_field_defn.hesa_value(47),
                   p_awd_body2         =>  p_value);

          END IF;
      ELSIF  p_field_number = 49
      THEN
          -- Length of Program
          -- Length of Program
          igs_he_extract_fields_pkg.get_new_prog_length
          (p_spa_attendance_type           =>  g_en_stdnt_ps_att.attendance_type,
           p_program_length                => g_ps_ofr_opt.program_length,
           p_program_length_measurement    => g_ps_ofr_opt.program_length_measurement,
           p_length                        =>  p_value,
           p_units                         =>  g_field_defn.hesa_value(50));

              --smaddali 01-jul-2002 lpadding with 0  for bug 2436769
              p_value := LPAD(p_value, 2,'0') ;


      ELSIF  p_field_number = 50
      THEN
          -- Units of length of Program
          IF g_field_defn.hesa_value.EXISTS(50)
          THEN
              -- Calculated Earlier ..
              p_value := g_field_defn.hesa_value(50);
          ELSE
              -- Not calculated earlier ..
                  igs_he_extract_fields_pkg.get_new_prog_length
                  (p_spa_attendance_type           =>  g_en_stdnt_ps_att.attendance_type,
                   p_program_length                => g_ps_ofr_opt.program_length,
                   p_program_length_measurement    => g_ps_ofr_opt.program_length_measurement,
                   p_length                        =>  g_field_defn.hesa_value(49),
                   p_units                         =>  p_value);
          END IF;

      -- This field is classified as 'Not Used' by HESA
      -- Removed the call to the procedure, get_voc_lvl
      -- as part of HEFD311 - July 2004 Changes enhancement bug, 2956444
      ELSIF  p_field_number = 51
      THEN

         -- Not Used
         p_value := NULL;

      ELSIF  p_field_number = 52
      THEN
          -- Spcial Programmes
          p_value := g_ps_ver.govt_special_course_type;

      ELSIF  p_field_number = 53
      THEN

                  IF g_field_defn.hesa_value.EXISTS(53)
                  THEN
                      -- Calculated Earlier ..
                      p_value := g_field_defn.hesa_value(53);
                  ELSE

                  -- Teacher Training Course Identifier
                  igs_he_extract_fields_pkg.get_teach_train_crs_id
                  (p_prg_ttcid            =>  g_he_st_prog.teacher_train_prog_id,
                   p_spa_ttcid            =>  g_he_st_spa.teacher_train_prog_id,
                   p_hesa_ttcid           =>  p_value);
                 END IF;

      ELSIF  p_field_number = 54
      THEN
               IF (g_he_submsn_header.validation_country  in ('ENGLAND','WALES') AND ( g_field_defn.hesa_value.EXISTS(53)  AND g_field_defn.hesa_value(53)  IN(1,2,6,7) ))   THEN
                  -- ITT Phase / Scope
                  igs_he_extract_fields_pkg.get_itt_phsc
                      (p_prg_itt_phsc        =>  g_he_st_prog.itt_phase,
                       p_spa_itt_phsc        =>  g_he_st_spa.itt_phase,
                       p_hesa_itt_phsc       =>  p_value);
               ELSE
                  g_default_pro:= 'N';
               END IF;

      ELSIF  p_field_number = 55
      THEN
              IF (g_he_submsn_header.validation_country  in ('SCOTLAND','WALES','NORTHERN IRELAND')  AND ( g_field_defn.hesa_value.EXISTS(53) AND g_field_defn.hesa_value(53)  IN(1,2)) )   THEN
                  -- Bilingual ITT Marker
                  igs_he_extract_fields_pkg.get_itt_mrker
                      (p_prg_itt_mrker       =>  g_he_st_prog.bilingual_itt_marker,
                       p_spa_itt_mrker       =>  g_he_st_spa.bilingual_itt_marker,
                       p_hesa_itt_mrker      =>  p_value);

               ELSE
                  g_default_pro:= 'N';
               END IF;

      ELSIF  p_field_number = 56
      THEN

               IF ( g_he_submsn_header.validation_country IN ('SCOTLAND' ,'NORTHERN IRELAND')  AND ( g_field_defn.hesa_value.EXISTS(53) AND g_field_defn.hesa_value(53) IN(1, 2)))   THEN
                  -- Teaching Qualification Sought Sector
                  igs_he_extract_fields_pkg.get_teach_qual_sect
                      (p_oss_teach_qual_sect   => g_he_st_prog.teaching_qual_sought_sector,
                       p_hesa_teach_qual_sect  => p_value);

               ELSE
                  g_default_pro:= 'N';
               END IF;

      ELSIF  p_field_number = 57
      THEN
            IF ( g_he_submsn_header.validation_country = 'SCOTLAND'   AND ( g_field_defn.hesa_value.EXISTS(56)  and g_field_defn.hesa_value(56) = 2 ) )   THEN
                  -- Teaching Qualification Sought Subject 1
                  igs_he_extract_fields_pkg.get_teach_qual_sbj
                    (p_oss_teach_qual_sbj     =>  g_he_st_prog.teaching_qual_sought_subj1,
                     p_hesa_teach_qual_sbj    =>  p_value);
            ELSE
                  g_default_pro:= 'N';
            END IF;


      ELSIF  p_field_number = 58
      THEN
              IF ( g_he_submsn_header.validation_country = 'SCOTLAND' AND ( g_field_defn.hesa_value.EXISTS(56) AND g_field_defn.hesa_value(56) = 2 ))   THEN
                  -- Teaching Qualification Sought Subject 2
                  igs_he_extract_fields_pkg.get_teach_qual_sbj
                      (p_oss_teach_qual_sbj     =>  g_he_st_prog.teaching_qual_sought_subj2,
                       p_hesa_teach_qual_sbj    =>  p_value);
              ELSE
                  g_default_pro:= 'N';
               END IF;

      ELSIF  p_field_number = 59
      THEN
              IF ( g_he_submsn_header.validation_country = 'SCOTLAND' AND ( g_field_defn.hesa_value.EXISTS(56)   and g_field_defn.hesa_value(56) = 2 )  )   THEN
                  -- Teaching Qualification Sought Subject 3
                  igs_he_extract_fields_pkg.get_teach_qual_sbj
                      (p_oss_teach_qual_sbj     =>  g_he_st_prog.teaching_qual_sought_subj3,
                       p_hesa_teach_qual_sbj    =>  p_value);
               ELSE
                  g_default_pro:= 'N';
               END IF;

      ELSIF  p_field_number = 60
      THEN

             IF ( g_he_submsn_header.validation_country IN ('SCOTLAND' , 'NORTHERN IRELAND' ) AND ( g_field_defn.hesa_value.EXISTS(53) AND g_field_defn.hesa_value(53)  in (1,2) ) )   THEN
                  -- Teaching Qualification Gained Sector
                  igs_he_extract_fields_pkg.get_teach_qual_sect
                      (p_oss_teach_qual_sect   => g_he_st_spa.teaching_qual_gain_sector,
                       p_hesa_teach_qual_sect  => p_value);

                  IF p_value IS NULL
                  AND g_en_stdnt_ps_att.course_rqrmnts_complete_dt IS NOT NULL
                  AND g_field_defn.hesa_value.EXISTS(56)
                  THEN
                      p_value := g_field_defn.hesa_value(56);
                  END IF;

               ELSE
                      g_default_pro:= 'N';
               END IF;

      ELSIF  p_field_number = 61
      THEN

               IF ( g_he_submsn_header.validation_country = 'SCOTLAND' AND ( g_field_defn.hesa_value.EXISTS(60) AND g_field_defn.hesa_value(60) = 2  ))   THEN
                  -- Teaching Qualification Gained Subject 1
                  igs_he_extract_fields_pkg.get_teach_qual_sbj
                      (p_oss_teach_qual_sbj     =>  g_he_st_spa.teaching_qual_gain_subj1,
                       p_hesa_teach_qual_sbj    =>  p_value);

                  IF p_value IS NULL
                  AND g_en_stdnt_ps_att.course_rqrmnts_complete_dt IS NOT NULL
                  AND g_field_defn.hesa_value.EXISTS(57)
                  THEN
                      p_value := g_field_defn.hesa_value(57);
                  END IF;


               ELSE
                      g_default_pro:= 'N';
               END IF;

      ELSIF  p_field_number = 62
      THEN

               IF ( g_he_submsn_header.validation_country = 'SCOTLAND' AND ( g_field_defn.hesa_value.EXISTS(60) and g_field_defn.hesa_value(60) = 2 ) )   THEN
                  -- Teaching Qualification Gained Subject 2
                  igs_he_extract_fields_pkg.get_teach_qual_sbj
                      (p_oss_teach_qual_sbj     =>  g_he_st_spa.teaching_qual_gain_subj2,
                       p_hesa_teach_qual_sbj    =>  p_value);

                  IF p_value IS NULL
                  AND g_en_stdnt_ps_att.course_rqrmnts_complete_dt IS NOT NULL
                  AND g_field_defn.hesa_value.EXISTS(58)
                  THEN
                      p_value := g_field_defn.hesa_value(58);
                  END IF;
               ELSE
                      g_default_pro:= 'N';
               END IF;

      ELSIF  p_field_number = 63
      THEN
               IF ( g_he_submsn_header.validation_country = 'SCOTLAND' AND ( g_field_defn.hesa_value.EXISTS(60) AND g_field_defn.hesa_value(60) = 2 ))   THEN
                  -- Teaching Qualification Gained Subject 3
                  igs_he_extract_fields_pkg.get_teach_qual_sbj
                      (p_oss_teach_qual_sbj     =>  g_he_st_spa.teaching_qual_gain_subj3,
                       p_hesa_teach_qual_sbj    =>  p_value);

                  IF p_value IS NULL
                  AND g_en_stdnt_ps_att.course_rqrmnts_complete_dt IS NOT NULL
                  AND g_field_defn.hesa_value.EXISTS(59)
                  THEN
                      p_value := g_field_defn.hesa_value(59);
                  END IF;


               ELSE
                      g_default_pro:= 'N';
               END IF;

      ELSIF  p_field_number = 64
      THEN
          -- Major Source of Funding
          IF  g_field_defn.hesa_value.EXISTS(64)
          THEN
              -- Calculated earlier, for field 6
              p_value :=   g_field_defn.hesa_value(64);
          ELSE
              -- Not calculated earlier.
              -- smaddali modified this call to pass funding_source field for hefd208 - bug#2717751
              -- jtmathew modified this call to pass funding_source field at spa level - bug#3962575
              igs_he_extract_fields_pkg.get_funding_src
                  (p_course_cd             => p_course_cd,
                   p_version_number        => p_crv_version_number,
                   p_spa_fund_src          => g_en_stdnt_ps_att.funding_source,
                   p_poous_fund_src        => g_he_poous.funding_source,
                   p_oss_fund_src          => g_field_defn.oss_value(64),
                   p_hesa_fund_src         => p_value);
          END IF;

      ELSIF  p_field_number = 65
      THEN
          -- Fundability Code
          IF  g_field_defn.hesa_value.EXISTS(65)
          THEN
              -- Calculated earlier, for field 6
              p_value :=   g_field_defn.hesa_value(65);
          ELSE
              -- Not calculated earlier, hence derive
              IF  g_field_defn.oss_value.EXISTS(64)
              THEN
                  -- Next get the Fundability Code
                  -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
                  igs_he_extract_fields_pkg.get_fundability_cd
                      (p_person_id             => p_person_id,
                       p_susa_fund_cd          => g_he_en_susa.fundability_code,
                       p_spa_funding_source    => g_en_stdnt_ps_att.funding_source,
                       p_poous_fund_cd         => g_he_poous.fundability_cd,
                       p_prg_fund_cd           => g_he_st_prog.fundability,
                       p_prg_funding_source    => g_field_defn.oss_value(64),
                       p_oss_fund_cd           => g_field_defn.oss_value(65),
                       p_hesa_fund_cd          => p_value,
                       p_enrl_start_dt         =>  g_he_submsn_header.enrolment_start_date,
                       p_enrl_end_dt           =>  g_he_submsn_header.enrolment_end_date);
              ELSE
                  p_value := NULL;
              END IF;

          END IF; -- Not calculated earlier

      ELSIF  p_field_number = 66
      THEN
          -- smaddali modified the value pased to p_study_mode for bug 2367167
          -- Fee Eligibility
          IF   g_field_defn.oss_value.EXISTS(6)
          AND  g_field_defn.oss_value.EXISTS(28)
          THEN
          -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
              igs_he_extract_fields_pkg.get_fee_elig
                  (p_person_id          =>  p_person_id,
                   p_susa_fee_elig      =>  g_he_en_susa.fee_eligibility,
                   p_fe_stdnt_mrker     =>  g_field_defn.oss_value(6),
                   p_study_mode         =>  NVL(g_he_en_susa.study_mode,NVL(g_he_poous.mode_of_study,g_en_stdnt_ps_att.attendance_type)),
                   p_special_student    =>  g_field_defn.oss_value(28),
                   p_hesa_fee_elig      =>  p_value,
                   p_enrl_start_dt      =>  g_he_submsn_header.enrolment_start_date,
                   p_enrl_end_dt        =>  g_he_submsn_header.enrolment_end_date);
          ELSE
            -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
              igs_he_extract_fields_pkg.get_fee_elig
                  (p_person_id          =>  p_person_id,
                   p_susa_fee_elig      =>  g_he_en_susa.fee_eligibility,
                   p_fe_stdnt_mrker     =>  NULL,
                   p_study_mode         =>  NVL(g_he_en_susa.study_mode,NVL(g_he_poous.mode_of_study,g_en_stdnt_ps_att.attendance_type)),
                   p_special_student    =>  NULL,
                   p_hesa_fee_elig      =>  p_value,
                   p_enrl_start_dt      =>  g_he_submsn_header.enrolment_start_date,
                   p_enrl_end_dt        =>  g_he_submsn_header.enrolment_end_date);
          END IF;

      ELSIF  p_field_number = 67
      THEN
          -- Fee Band
          IF   g_field_defn.hesa_value.EXISTS(66) THEN
              igs_he_extract_fields_pkg.get_fee_band
                  (p_hesa_fee_elig     =>  g_field_defn.hesa_value(66),
                   p_susa_fee_band     =>  g_he_en_susa.fee_band,
                   p_poous_fee_band    =>  g_he_poous.fee_band,
                   p_prg_fee_band      =>  g_he_st_prog.fee_band,
                   p_hesa_fee_band     =>  p_value);
          ELSE

              igs_he_extract_fields_pkg.get_fee_band
                  (p_hesa_fee_elig     =>  NULL,
                   p_susa_fee_band     =>  g_he_en_susa.fee_band,
                   p_poous_fee_band    =>  g_he_poous.fee_band,
                   p_prg_fee_band      =>  g_he_st_prog.fee_band,
                   p_hesa_fee_band     =>  p_value);

          END IF;

      ELSIF  p_field_number = 68
      THEN
          -- Major Source of Tuition Fees
          -- Calculate amount of tuition Fees first
          IF   NOT g_field_defn.hesa_value.EXISTS(6)
          THEN
              g_field_defn.hesa_value(6) := NULL;
          END IF;

          -- smaddali 14-oct-03 added 2 new parameters to the procedure get_amt_tuition_fees, for bug#3179544
          IF   g_field_defn.hesa_value.EXISTS(6)
          AND  g_field_defn.hesa_value.EXISTS(28)
          THEN
              igs_he_extract_fields_pkg.get_amt_tuition_fees
                  (p_person_id         =>  p_person_id,
                   p_course_cd         =>  p_course_cd,
                   p_cal_type          =>  g_en_stdnt_ps_att.cal_type,
                   p_fe_prg_mrker      =>  g_he_st_prog.fe_program_marker,
                   p_fe_stdnt_mrker    =>  g_field_defn.hesa_value(6),
                   p_oss_amt           =>  g_field_defn.oss_value(83),
                   p_hesa_amt          =>  g_field_defn.hesa_value(83),
                   p_enrl_start_dt     =>  g_he_submsn_header.enrolment_start_date,
                   p_enrl_end_dt       =>  g_he_submsn_header.enrolment_end_date);

              -- Calculate Mode of Study
              IF NOT g_field_defn.hesa_value.EXISTS(70) THEN
                igs_he_extract_fields_pkg.get_mode_of_study
                  (p_person_id         =>  p_person_id,
                   p_course_cd         =>  p_course_cd,
                   p_version_number    =>  p_crv_version_number,
                   p_enrl_start_dt     =>  g_he_submsn_header.enrolment_start_date,
                   p_enrl_end_dt       =>  g_he_submsn_header.enrolment_end_date,
                   p_susa_study_mode   =>  g_he_en_susa.study_mode,
                   p_poous_study_mode  =>  g_he_poous.mode_of_study,
                   p_attendance_type   =>  g_en_stdnt_ps_att.attendance_type,
                   p_mode_of_study     =>  g_field_defn.hesa_value(70));
              END IF ;

              -- Now calculate the major source of tuition fees
              igs_he_extract_fields_pkg.get_maj_src_tu_fee
                  (p_person_id         =>  p_person_id,
                   p_enrl_start_dt     =>  g_he_submsn_header.enrolment_start_date,
                   p_enrl_end_dt       =>  g_he_submsn_header.enrolment_end_date,
                   p_special_stdnt     =>  g_field_defn.hesa_value(28),
                   p_study_mode        =>  g_field_defn.hesa_value(70),
                   p_amt_tu_fee        =>  g_field_defn.oss_value(83),
                   p_susa_mstufee      =>  g_he_en_susa.student_fee,
                   p_hesa_mstufee      =>  p_value);
          END IF;

      ELSIF  p_field_number = 69
      THEN
          -- Not Used
          p_value := NULL;

      ELSIF  p_field_number = 70
      THEN
          -- Mode of Studying
          IF  g_field_defn.hesa_value.EXISTS(70)
          THEN
              -- Calculated earlier, for field 68
              p_value :=   g_field_defn.hesa_value(70);
          ELSE
              igs_he_extract_fields_pkg.get_mode_of_study
                  (p_person_id         =>  p_person_id,
                   p_course_cd         =>  p_course_cd,
                   p_version_number    =>  p_crv_version_number,
                   p_enrl_start_dt     =>  g_he_submsn_header.enrolment_start_date,
                   p_enrl_end_dt       =>  g_he_submsn_header.enrolment_end_date,
                   p_susa_study_mode   =>  g_he_en_susa.study_mode,
                   p_poous_study_mode  =>  g_he_poous.mode_of_study,
                   p_attendance_type   =>  g_en_stdnt_ps_att.attendance_type,
                   p_mode_of_study     =>  p_value);

          END IF;

      ELSIF  p_field_number = 71
      THEN
          -- Location of Study
          IF  g_field_defn.hesa_value.EXISTS(71)
          THEN
              -- Calculated earlier, for field 31
              p_value :=   g_field_defn.hesa_value(71);
          ELSE
              -- Not calculated earlier, hence derive
              igs_he_extract_fields_pkg.get_study_location
                  (p_susa_study_location    => g_he_en_susa.study_location,
                   p_poous_study_location   => g_he_poous.location_of_study,
                   p_prg_study_location     => g_he_st_prog.location_of_study,
                   p_oss_study_location     => g_field_defn.oss_value(71),
                   p_hesa_study_location    => p_value);
          END IF;

      ELSIF  p_field_number = 72
      THEN
           -- Year of Program
          IF  g_field_defn.hesa_value.EXISTS(72)
          THEN
              p_value :=   g_field_defn.hesa_value(72);
          ELSE
              -- Not calculated earlier, hence derive
              igs_he_extract_fields_pkg.get_year_of_prog
                  (p_unit_set_cd          => g_as_su_setatmpt.unit_set_cd,
                   p_year_of_prog         => p_value);

          END IF;

          -- To send to HESA Lpad with 0
          p_value := LPAD(p_value,2,'0');

      ELSIF  p_field_number = 73
      THEN
          -- Length of current year of program
          --smaddali adding LPAD '0' for bug 2437081
          p_value := LPAD(g_he_poous.leng_current_year,2,'0') ;

      ELSIF  p_field_number = 74
      THEN
          -- Included the below code as a part of HECR001(bug number 2278825)
          -- smaddali added the ltrim and changed format mask from 999.9 to 000.0 for bug 2431845
          -- jtmathew added the check for whether SUSA finishes before the start of reporting period

          IF g_he_en_susa.fte_perc_override  IS NOT NULL THEN
                  p_value := Ltrim(To_Char(g_he_en_susa.fte_perc_override,'000.0'));
          ELSE
              IF g_as_su_setatmpt.rqrmnts_complete_dt IS NOT NULL AND
                 g_as_su_setatmpt.rqrmnts_complete_dt <  g_he_submsn_header.enrolment_start_date
              THEN -- Report FTE of 000.0 as the unit set does not fit within the reporting period
                  p_value := Ltrim(To_Char(0,'000.0'));
              ELSE
                  p_value := Ltrim(To_Char(g_he_en_susa.calculated_fte,'000.0'));
              END IF;
          END IF;

      ELSIF  p_field_number = 75
      THEN
          -- Postcode
          IF g_field_defn.hesa_value.EXISTS(12) AND  g_field_defn.hesa_value(12) IN ('8826','5826','6826','7826','2826','3826','4826') THEN
                  p_value := g_he_st_spa.postcode;
          ELSE
             g_default_pro:= 'N';
          END IF;

      ELSIF  p_field_number = 76
      THEN
          -- PGCE - Subject of Undergraduate Degree
          -- smaddali added call to the new local procedure for bug 2452592
          IF g_field_defn.hesa_value.EXISTS(41) AND g_field_defn.hesa_value(41) IN ('12','13')
          THEN
              igs_he_extract2_pkg.get_pgce_subj
              (p_person_id         =>  p_person_id,
               p_pgce_subj        =>  p_value);
          ELSE
              p_value := NULL ;
          END IF ;

      ELSIF  p_field_number = 77
      THEN
          -- PGCE - Classification  of Undergraduate Degree
          --smaddali added the whole code instead of NULL statement for bug 2436924
          IF g_field_defn.hesa_value.EXISTS(41) AND g_field_defn.hesa_value(41) IN ('12','13')
          THEN
             igs_he_extract_fields_pkg.get_pgce_class
              (p_person_id         =>  p_person_id,
               p_pgce_class        =>  p_value);
          ELSE
              p_value := NULL ;
          END IF ;

      ELSIF  p_field_number = 78
      THEN
              IF (g_he_submsn_header.validation_country  = 'NORTHERN IRELAND' AND ( g_field_defn.hesa_value.EXISTS(12)  and g_field_defn.hesa_value(12) = '8826'))THEN
                  -- Religion
                  igs_he_extract_fields_pkg.get_religion
                  (p_oss_religion     =>  g_pe_stat_v.religion,
                   p_hesa_religion    =>  p_value);

              ELSE
                 g_default_pro := 'N';
              END IF;

      ELSIF  p_field_number = 79
      THEN
          -- Not used
          p_value := NULL;

      ELSIF  p_field_number = 80
      THEN
          -- Not used
          p_value := NULL;

      ELSIF  p_field_number = 81
      THEN
          -- SLDD Discrete Provision
          IF g_field_defn.hesa_value.EXISTS(6)
          THEN
              igs_he_extract_fields_pkg.get_sldd_disc_prv
                  (p_oss_sldd_disc_prv     =>  g_he_en_susa.sldd_discrete_prov,
                   p_fe_stdnt_mrker        =>  g_field_defn.hesa_value(6),
                   p_hesa_sldd_disc_prv    =>  p_value);
          END IF;

      ELSIF  p_field_number = 82
      THEN
          -- Not used
          p_value := NULL;

      ELSIF  p_field_number = 83
      THEN
         --Set the default processing as N for all the conditions as it is set to Y for the below condition
         g_default_pro:= 'N';

         IF  g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)  THEN

           -- Amount of Tuition fees expected
           IF g_field_defn.hesa_value.EXISTS(83)
           THEN
              -- Calculated earlier. No need to derive
              p_value := g_field_defn.hesa_value(83);
           ELSE

              -- Not calculated earlier. Derive now.
              -- smaddali 14-oct-03 added 2 new parameters to the procedure get_amt_tuition_fees, for bug#3179544
              igs_he_extract_fields_pkg.get_amt_tuition_fees
                  (p_person_id         =>  p_person_id,
                   p_course_cd         =>  p_course_cd,
                   p_cal_type          =>  g_en_stdnt_ps_att.cal_type,
                   p_fe_prg_mrker      =>  g_he_st_prog.fe_program_marker,
                   p_fe_stdnt_mrker    =>  g_field_defn.hesa_value(6),
                   p_oss_amt           =>  g_field_defn.oss_value(83),
                   p_hesa_amt          =>  p_value,
                   p_enrl_start_dt     =>  g_he_submsn_header.enrolment_start_date,
                   p_enrl_end_dt       =>  g_he_submsn_header.enrolment_end_date);
           END IF;
           --Set the default Processing for this condition
           g_default_pro:= 'Y';
         END IF;

      ELSIF  p_field_number = 84
      THEN
         g_default_pro:= 'N';

         IF  g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4) THEN
          -- Non Payment Reason
             igs_he_extract_fields_pkg.get_non_payment_rsn
              (p_oss_non_payment_rsn   =>  g_he_en_susa.non_payment_reason,
               p_hesa_non_payment_rsn  =>  p_value,
               p_fe_stdnt_mrker    => g_field_defn.hesa_value(6));

             g_default_pro:= 'Y';
         END IF;

      ELSIF  p_field_number = 85
      THEN
          -- Module Identifier 1
          --smaddali added the initialisation of variable g_mod_rec for bug 2417370
          g_mod_rec := NULL ;
          g_total_mod := 0;

          IF g_he_st_prog.program_calc = 'N'
          THEN
              igs_he_extract_fields_pkg.get_module_dets
                 (p_person_id            =>  p_person_id,
                  p_course_cd            =>  p_course_cd,
                  p_version_number       =>  p_crv_version_number,
                  p_student_inst_number  =>  g_he_st_spa.student_inst_number,
                  p_cal_type             =>  g_en_stdnt_ps_att.cal_type,
                  p_enrl_start_dt        =>  g_he_submsn_header.enrolment_start_date,
                  p_enrl_end_dt          =>  g_he_submsn_header.enrolment_end_date,
                  p_offset_days          =>  g_he_submsn_header.offset_days,
                  p_module_rec           =>  g_mod_rec,
                  p_total_recs           =>  g_total_mod);

              IF g_total_mod >= 1
              THEN
                  p_value := g_mod_rec.module_id(1);
              END IF;
          END IF;


      ELSIF  p_field_number = 86
      THEN
          -- Module Identifier 2
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 2
          THEN
              p_value := g_mod_rec.module_id(2);
          END IF;

      ELSIF  p_field_number = 87
      THEN
          -- Module Identifier 3
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 3
          THEN
              p_value := g_mod_rec.module_id(3);
          END IF;


      ELSIF  p_field_number = 88
      THEN
          -- Module Identifier 4
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 4
          THEN
              p_value := g_mod_rec.module_id(4);
          END IF;


      ELSIF  p_field_number = 89
      THEN
          -- Module Identifier 5
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 5
          THEN
              p_value := g_mod_rec.module_id(5);
          END IF;


      ELSIF  p_field_number = 90
      THEN
          -- Module Identifier 6
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 6
          THEN
              p_value := g_mod_rec.module_id(6);
          END IF;

      ELSIF  p_field_number = 91
      THEN
          -- Module Identifier 7
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 7
          THEN
              p_value := g_mod_rec.module_id(7);
          END IF;


      ELSIF  p_field_number = 92
      THEN
          -- Module Identifier 8
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 8
          THEN
              p_value := g_mod_rec.module_id(8);
          END IF;


      ELSIF  p_field_number = 93
      THEN
          -- Module Identifier 9
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 9
          THEN
              p_value := g_mod_rec.module_id(9);
          END IF;


      ELSIF  p_field_number = 94
      THEN
          -- Module Identifier 10
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 10
          THEN
              p_value := g_mod_rec.module_id(10);
          END IF;


      ELSIF  p_field_number = 95
      THEN
          -- Module Identifier 11
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 11
          THEN
              p_value := g_mod_rec.module_id(11);
          END IF;


      ELSIF  p_field_number = 96
      THEN
          -- Module Identifier 12
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 12
          THEN
              p_value := g_mod_rec.module_id(12);
          END IF;


      ELSIF  p_field_number = 97
      THEN
          -- Module Identifier 13
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 13
          THEN
              p_value := g_mod_rec.module_id(13);
          END IF;


      ELSIF  p_field_number = 98
      THEN
          -- Module Identifier 14
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 14
          THEN
              p_value := g_mod_rec.module_id(14);
          END IF;


      ELSIF  p_field_number = 99
      THEN
          -- Module Identifier 15
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 15
          THEN
              p_value := g_mod_rec.module_id(15);
          END IF;


      ELSIF  p_field_number = 100
      THEN
          -- Module Identifier 16
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 16
          THEN
              p_value := g_mod_rec.module_id(16);
          END IF;

      -- smaddali 13-oct-03  Modified student fields 101 to 116 for bug#3163324 ,
      --  to derive only for WELSH students
      ELSIF  p_field_number = 101
      THEN
          -- Module 1, Proportion of teaching in Welsh
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 1 AND g_he_submsn_header.validation_country   = 'WALES'
          THEN
              --smaddali adding format mask '000.0' for bug 2437081
              p_value := Ltrim(To_Char(g_mod_rec.prop_in_welsh(1),'000.0') );
          END IF;

      ELSIF  p_field_number = 102
      THEN
          -- Module 2, Proportion of teaching in Welsh
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 2 AND g_he_submsn_header.validation_country   = 'WALES'
          THEN
              --smaddali adding format mask '000.0' for bug 2437081
              p_value := Ltrim(To_Char(g_mod_rec.prop_in_welsh(2),'000.0') );
          END IF;

      ELSIF  p_field_number = 103
      THEN
          -- Module 3, Proportion of teaching in Welsh
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 3 AND g_he_submsn_header.validation_country   = 'WALES'
          THEN
              --smaddali adding format mask '000.0' for bug 2437081
              p_value := Ltrim(To_Char(g_mod_rec.prop_in_welsh(3),'000.0') );
          END IF;

      ELSIF  p_field_number = 104
      THEN
          -- Module 4, Proportion of teaching in Welsh
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 4 AND g_he_submsn_header.validation_country   = 'WALES'
          THEN
               --smaddali adding format mask '000.0' for bug 2437081
              p_value := Ltrim(To_Char(g_mod_rec.prop_in_welsh(4),'000.0') );
          END IF;

      ELSIF  p_field_number = 105
      THEN
          -- Module 5, Proportion of teaching in Welsh
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 5 AND g_he_submsn_header.validation_country   = 'WALES'
          THEN
               --smaddali adding format mask '000.0' for bug 2437081
              p_value := Ltrim(To_Char(g_mod_rec.prop_in_welsh(5),'000.0') );
          END IF;


      ELSIF  p_field_number = 106
      THEN
          -- Module 6, Proportion of teaching in Welsh
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 6 AND g_he_submsn_header.validation_country   = 'WALES'
          THEN
               --smaddali adding format mask '000.0' for bug 2437081
              p_value := Ltrim(To_Char(g_mod_rec.prop_in_welsh(6),'000.0') );
          END IF;

      ELSIF  p_field_number = 107
      THEN
          -- Module 7, Proportion of teaching in Welsh
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 7 AND g_he_submsn_header.validation_country   = 'WALES'
          THEN
               --smaddali adding format mask '000.0' for bug 2437081
              p_value := Ltrim(To_Char(g_mod_rec.prop_in_welsh(7),'000.0') );
          END IF;

      ELSIF  p_field_number = 108
      THEN
          -- Module 8, Proportion of teaching in Welsh
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 8 AND g_he_submsn_header.validation_country   = 'WALES'
          THEN
               --smaddali adding format mask '000.0' for bug 2437081
              p_value := Ltrim(To_Char(g_mod_rec.prop_in_welsh(8),'000.0') );
          END IF;

      ELSIF  p_field_number = 109
      THEN
          -- Module 9, Proportion of teaching in Welsh
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 9 AND g_he_submsn_header.validation_country   = 'WALES'
          THEN
               --smaddali adding format mask '000.0' for bug 2437081
              p_value := Ltrim(To_Char(g_mod_rec.prop_in_welsh(9),'000.0') );
          END IF;

      ELSIF  p_field_number = 110
      THEN
          -- Module 10, Proportion of teaching in Welsh
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 10 AND g_he_submsn_header.validation_country   = 'WALES'
          THEN
               --smaddali adding format mask '000.0' for bug 2437081
              p_value := Ltrim(To_Char(g_mod_rec.prop_in_welsh(10),'000.0') );
          END IF;

      ELSIF  p_field_number = 111
      THEN
          -- Module 11, Proportion of teaching in Welsh
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 11 AND g_he_submsn_header.validation_country   = 'WALES'
          THEN
               --smaddali adding format mask '000.0' for bug 2437081
              p_value := Ltrim(To_Char(g_mod_rec.prop_in_welsh(11),'000.0') );
          END IF;

      ELSIF  p_field_number = 112
      THEN
          -- Module 12, Proportion of teaching in Welsh
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 12 AND g_he_submsn_header.validation_country   = 'WALES'
          THEN
               --smaddali adding format mask '000.0' for bug 2437081
              p_value := Ltrim(To_Char(g_mod_rec.prop_in_welsh(12),'000.0') );
          END IF;

      ELSIF  p_field_number = 113
      THEN
          -- Module 13, Proportion of teaching in Welsh
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 13 AND g_he_submsn_header.validation_country   = 'WALES'
          THEN
               --smaddali adding format mask '000.0' for bug 2437081
              p_value := Ltrim(To_Char(g_mod_rec.prop_in_welsh(13),'000.0') );
          END IF;

      ELSIF  p_field_number = 114
      THEN
          -- Module 14, Proportion of teaching in Welsh
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 14 AND g_he_submsn_header.validation_country   = 'WALES'
          THEN
               --smaddali adding format mask '000.0' for bug 2437081
              p_value := Ltrim(To_Char(g_mod_rec.prop_in_welsh(14),'000.0') );
          END IF;

      ELSIF  p_field_number = 115
      THEN
          -- Module 15, Proportion of teaching in Welsh
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 15 AND g_he_submsn_header.validation_country   = 'WALES'
          THEN
               --smaddali adding format mask '000.0' for bug 2437081
              p_value := Ltrim(To_Char(g_mod_rec.prop_in_welsh(15),'000.0') );
          END IF;

      ELSIF  p_field_number = 116
      THEN
          -- Module 16, Proportion of teaching in Welsh
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 16 AND g_he_submsn_header.validation_country   = 'WALES'
          THEN
               --smaddali adding format mask '000.0' for bug 2437081
              p_value := Ltrim(To_Char(g_mod_rec.prop_in_welsh(16),'000.0') );
          END IF;

      ELSIF  p_field_number = 117
      THEN
          -- Module 1, Result
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 1
          THEN
              p_value := g_mod_rec.module_result(1);
          END IF;

      ELSIF  p_field_number = 118
      THEN
          -- Module 2, Result
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 2
          THEN
              p_value := g_mod_rec.module_result(2);
          END IF;

      ELSIF  p_field_number = 119
      THEN
          -- Module 3, Result
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 3
          THEN
              p_value := g_mod_rec.module_result(3);
          END IF;

      ELSIF  p_field_number = 120
      THEN
          -- Module 4, Result
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 4
          THEN
              p_value := g_mod_rec.module_result(4);
          END IF;

      ELSIF  p_field_number = 121
      THEN
          -- Module 5, Result
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 5
          THEN
              p_value := g_mod_rec.module_result(5);
          END IF;


      ELSIF  p_field_number = 122
      THEN
          -- Module 6, Result
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 6
          THEN
              p_value := g_mod_rec.module_result(6);
          END IF;

      ELSIF  p_field_number = 123
      THEN
          -- Module 7, Result
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 7
          THEN
              p_value := g_mod_rec.module_result(7);
          END IF;

      ELSIF  p_field_number = 124
      THEN
          -- Module 8, Result
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 8
          THEN
              p_value := g_mod_rec.module_result(8);
          END IF;

      ELSIF  p_field_number = 125
      THEN
          -- Module 9, Result
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 9
          THEN
              p_value := g_mod_rec.module_result(9);
          END IF;

      ELSIF  p_field_number = 126
      THEN
          -- Module 10, Result
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 10
          THEN
              p_value := g_mod_rec.module_result(10);
          END IF;

      ELSIF  p_field_number = 127
      THEN
          -- Module 11, Result
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 11
          THEN
              p_value := g_mod_rec.module_result(11);
          END IF;

      ELSIF  p_field_number = 128
      THEN
          -- Module 12, Result
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 12
          THEN
              p_value := g_mod_rec.module_result(12);
          END IF;

      ELSIF  p_field_number = 129
      THEN
          -- Module 13, Result
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 13
          THEN
              p_value := g_mod_rec.module_result(13);
          END IF;

      ELSIF  p_field_number = 130
      THEN
          -- Module 14, Result
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 14
          THEN
              p_value := g_mod_rec.module_result(14);
          END IF;

      ELSIF  p_field_number = 131
      THEN
          -- Module 15, Result
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 15
          THEN
              p_value := g_mod_rec.module_result(15);
          END IF;

      ELSIF  p_field_number = 132
      THEN
          -- Module 16, Result
          IF g_he_st_prog.program_calc = 'N'
          AND g_total_mod >= 16
          THEN
              p_value := g_mod_rec.module_result(16);
          END IF;

      -- Modified the derivation of this field to derive regardless of the value of the HESA MODE field (70)
      -- as part of HEFD311 - July 2004 Changes enhancement bug, 2956444
      ELSIF  p_field_number = 133
      THEN

         IF g_field_defn.hesa_value.EXISTS(133)
         THEN
             p_value :=  g_field_defn.hesa_value(133);
         ELSE

           IF  g_he_st_spa.associate_ucas_number = 'Y' THEN

              -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
              igs_he_extract_fields_pkg.get_ucasnum
                (p_person_id            => p_person_id,
                p_ucasnum              => p_value,
                p_enrl_start_dt        =>  g_he_submsn_header.enrolment_start_date,
                p_enrl_end_dt          =>  g_he_submsn_header.enrolment_end_date);

           END IF;

         END IF;

      ELSIF  p_field_number = 134
      THEN
          -- Institutions Own Id for Student
          p_value := g_pe_person.person_number;

      ELSIF  p_field_number = 135
      THEN
          -- Institutes program of study
          p_value := p_course_cd || '.' || To_Char(p_crv_version_number);

      ELSIF  p_field_number = 136
      THEN
          -- Student Instance Number
          p_value := g_he_st_spa.student_inst_number;

      ELSIF  p_field_number = 137
      THEN
          -- Suspension of Active studies
          igs_he_extract_fields_pkg.get_studies_susp
              (p_person_id          =>  p_person_id,
               p_course_cd          =>  p_course_cd,
               p_version_number     =>  p_crv_version_number,
               p_enrl_start_dt      =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt        =>  g_he_submsn_header.enrolment_end_date,
               p_susp_act_std       =>  p_value);

      ELSIF  p_field_number = 138
      THEN
          -- Type of Program year
          igs_he_extract_fields_pkg.get_pyr_type
              (p_oss_pyr_type     =>  NVL(g_he_en_susa.type_of_year,g_he_poous.type_of_year),
               p_hesa_pyr_type    =>  p_value);

      ELSIF  p_field_number = 139
      THEN
          -- Level applicable for funding
          igs_he_extract_fields_pkg.get_lvl_appl_to_fund
              (p_poous_lvl_appl_fund   =>  g_he_poous.level_applicable_to_funding,
               p_prg_lvl_appl_fund     =>  g_he_st_prog.level_applicable_to_funding,
               p_hesa_lvl_appl_fund    =>  p_value);

      -- The derivation of this field has changed majorly to consider the new setup
      -- as part of HEFD311 - July 2004 Changes enhancement bug, 2956444
      ELSIF  p_field_number = 140
      THEN

         -- The default value not to be done  for all the contries
         g_default_pro := 'N' ;

         IF g_he_submsn_header.validation_country IN ('ENGLAND','WALES','NORTHERN IRELAND')  THEN

            -- Check for the existence of the fields 139, 28, 137, 70 and 138. If not exists pass NULL value
            IF g_field_defn.hesa_value.EXISTS(139) THEN
              l_fundlev := g_field_defn.hesa_value(139);
            ELSE
              l_fundlev := NULL;
            END IF;

            IF g_field_defn.hesa_value.EXISTS(28) THEN
              l_spcstu := g_field_defn.hesa_value(28);
            ELSE
              l_spcstu := NULL;
            END IF;

            IF g_field_defn.hesa_value.EXISTS(137) THEN
              l_notact := g_field_defn.hesa_value(137);
            ELSE
              l_notact := NULL;
            END IF;

            IF g_field_defn.hesa_value.EXISTS(70) THEN
              l_mode := g_field_defn.hesa_value(70);
            ELSE
              l_mode := NULL;
            END IF;

            IF g_field_defn.hesa_value.EXISTS(138) THEN
              l_typeyr := g_field_defn.hesa_value(138);
            ELSE
              l_typeyr := NULL;
            END IF;

            -- Completion of Year of Program of study
            igs_he_extract_fields_pkg.get_comp_pyr_study (
              p_susa_comp_pyr_study  =>  g_he_en_susa.complete_pyr_study_cd,
              p_fundlev              =>  l_fundlev,
              p_spcstu               =>  l_spcstu,
              p_notact               =>  l_notact,
              p_mode                 =>  l_mode,
              p_typeyr               =>  l_typeyr,
              p_crse_rqr_complete_ind => g_en_stdnt_ps_att.course_rqrmnt_complete_ind,
              p_crse_req_complete_dt =>  g_en_stdnt_ps_att.course_rqrmnts_complete_dt,
              p_disc_reason_cd       =>  g_en_stdnt_ps_att.discontinuation_reason_cd,
              p_discont_dt           =>  g_en_stdnt_ps_att.discontinued_dt,
              p_enrl_start_dt        =>  g_he_submsn_header.enrolment_start_date,
              p_enrl_end_dt          =>  g_he_submsn_header.enrolment_end_date,
              p_person_id            =>  p_person_id,
              p_course_cd            =>  p_course_cd,
              p_hesa_comp_pyr_study  =>  p_value);

             -- The default value valid for only thses the contries
             g_default_pro := 'Y' ;
         END IF;

      ELSIF  p_field_number = 141
      THEN

        IF (g_he_submsn_header.validation_country =   'WALES' AND ( g_field_defn.hesa_value.EXISTS(6) and  g_field_defn.hesa_value(6) IN (1,3,4))) THEN
          -- Get the value
          -- Destination
          igs_he_extract_fields_pkg.get_destination
              (p_oss_destination     =>  g_he_st_spa.destination,
               p_hesa_destination    =>  p_value);
        ELSE
                    -- The default value should not be calculated for  any other condition
                     g_default_pro := 'N' ;

        END IF;

      ELSIF  p_field_number = 142
      THEN
          -- Not used
          p_value := NULL;

      ELSIF  p_field_number = 143
      THEN
          -- Not used
          p_value := NULL;

      ELSIF  p_field_number = 144
      THEN
          -- Not used
          p_value := NULL;

      ELSIF  p_field_number = 145
      THEN
          -- Not used
          p_value := NULL;

      ELSIF  p_field_number = 146
      THEN
        --Set the  default variable value as default value has to be calculated only for the down condition
        g_default_pro := 'N';

        IF g_he_submsn_header.validation_country IN   ('ENGLAND','WALES') THEN
              -- Get the value
              -- Outcome of ITT Program
          IF (g_field_defn.hesa_value.EXISTS(53)  AND g_field_defn.hesa_value(53) IN (1,6,7)) THEN
                IF  g_field_defn.hesa_value.EXISTS(146)     THEN
               -- Calculated earlier, for field 29
                    p_value :=   g_field_defn.hesa_value(146);

                ELSE
                   igs_he_extract_fields_pkg.get_itt_outcome
                    (p_oss_itt_outcome     =>  g_he_st_spa.itt_prog_outcome,
                     p_teach_train_prg     =>  g_field_defn.hesa_value(53),
                     p_hesa_itt_outcome    =>  p_value);

                END IF;
                --If the value is calculated as NULL above then do the default processing for this field
                g_default_pro := 'Y' ;
          END IF;
        END IF;

      ELSIF  p_field_number = 147
      THEN
          -- Not used
          p_value := NULL;

      ELSIF  p_field_number = 148
      THEN
          -- Not used
          p_value := NULL;

      ELSIF  p_field_number = 149
      THEN
          -- UFI Place
          igs_he_extract_fields_pkg.get_ufi_place
              (p_oss_ufi_place     =>  NVL(g_he_st_spa.ufi_place,g_he_poous.ufi_place),
               p_hesa_ufi_place    =>  p_value);

      ELSIF  p_field_number = 150
      THEN
          --Franchising Activity
          igs_he_extract_fields_pkg.get_franchising_activity
              (p_susa_franch_activity   => g_he_en_susa.franchising_activity,
               p_poous_franch_activity  => g_he_poous.franchising_activity,
               p_prog_franch_activity   => g_he_st_prog.franchising_activity,
               p_hesa_franch_activity   =>  p_value);

      ELSIF  p_field_number = 151
      THEN
          -- Institutions own campus identifier
          igs_he_extract_fields_pkg.get_campus_id
              (p_location_cd => g_en_stdnt_ps_att.location_cd,
               p_campus_id   => p_value);

      ELSIF  p_field_number = 152
      THEN

          -- sjlaporte use date comparison rather than text bug 3933715
          -- Social Class Indicator
      IF g_en_stdnt_ps_att.commencement_dt  > TO_DATE('31/07/2002', 'DD/MM/YYYY')
          THEN
              igs_he_extract_fields_pkg.get_social_class_ind
                  (p_spa_social_class_ind   => g_he_st_spa.social_class_ind,
                   p_adm_social_class_ind   => g_he_ad_dtl.social_class_cd,
                   p_hesa_social_class_ind  => p_value);
          END IF;

      ELSIF  p_field_number = 153
      THEN

          -- sjlaporte use date comparison rather than text bug 3933715
          -- Occupation Code
          IF g_en_stdnt_ps_att.commencement_dt  > TO_DATE('31/07/2002', 'DD/MM/YYYY')
          THEN
              igs_he_extract_fields_pkg.get_occupation_code
                  (p_spa_occupation_code   => g_he_st_spa.occupation_code,
                   p_hesa_occupation_code  =>  p_value);

          END IF;

      ELSIF  p_field_number = 154
      THEN
          -- Insitute last attended
        -- smaddali modified this field to remove the dependency on field 148UCASNUM for bug 2663717
                  igs_he_extract_fields_pkg.get_inst_last_attended
                     (p_person_id         =>  p_person_id,
                      p_com_date          =>  g_en_stdnt_ps_att.commencement_dt,
                      p_inst_last_att     =>  p_value,
                      p_enrl_start_dt      =>  g_he_submsn_header.enrolment_start_date,
                      p_enrl_end_dt        =>  g_he_submsn_header.enrolment_end_date
                      );

      ELSIF  p_field_number = 155
      THEN
          -- Regulatory Body
          igs_he_extract_fields_pkg.get_regulatory_body
              (p_course_cd               =>  p_course_cd,
               p_version_number          =>  p_crv_version_number,
               p_hesa_regulatory_body    =>  p_value);

      -- Modified the field derivation to derive a default value based on field numbers 41 and 155
      -- as part of HEFD311 - July 2004 Changes enhancement bug, 2956444
      ELSIF  p_field_number = 156
      THEN

          -- Regulatory Body Registration Number
          -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
          -- and adding validation to derive this field only if associate_nhs_reg_num=Y
          IF g_he_st_spa.associate_nhs_reg_num = 'Y' THEN
                  igs_he_extract_fields_pkg.get_alt_pers_id
                      (p_person_id              => p_person_id,
                       p_id_type                => 'DH REG REF',
                       p_api_id                 => p_value,
                       p_enrl_start_dt          =>  g_he_submsn_header.enrolment_start_date,
                       p_enrl_end_dt            =>  g_he_submsn_header.enrolment_end_date);
           END IF ;

          -- If the field not derived and
          -- If field 41- QUALAIM  is 18 or 33 and Field 155 - Regulatory body for
          -- health and Social care students is 06 or 07 then use default value, 99999999
          IF p_value IS NULL AND g_field_defn.hesa_value.EXISTS(41) AND g_field_defn.hesa_value(41) IN (18,33) AND
             g_field_defn.hesa_value.EXISTS(155)  AND g_field_defn.hesa_value(155) IN ('06', '07') THEN

            p_value := '99999999';

          END IF;

      ELSIF  p_field_number = 157
      THEN
          -- Source of NHS funding
          igs_he_extract_fields_pkg.get_nhs_fund_src
              (p_spa_nhs_fund_src    =>  g_he_st_spa.nhs_funding_source,
               p_prg_nhs_fund_src    =>  g_he_st_prog.nhs_funding_source,
               p_hesa_nhs_fund_src   =>  p_value);

      ELSIF  p_field_number = 158
      THEN
          -- NHS Employer
          igs_he_extract_fields_pkg.get_nhs_employer
              (p_spa_nhs_employer     => g_he_st_spa.nhs_employer,
               p_hesa_nhs_employer    => p_value);

      ELSIF  p_field_number = 159
      THEN

          g_default_pro := 'N';

          -- Number of GCE AS Levels
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'GCSEAS',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(160));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'GCEASN',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(133) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(133),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                g_default_pro := 'Y';
              END IF;

          END IF;

      ELSIF  p_field_number = 160
      THEN

          g_default_pro := 'N';

          -- GCE AS level Tariff Score
          IF g_field_defn.hesa_value.EXISTS(160) AND g_field_defn.hesa_value(160) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(160);
              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'GCEASTS',
                                                           p_tariff_score   => p_value);

          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(133) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(133),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 161
      THEN

          g_default_pro := 'N';

          -- Number of VCE AS Levels
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'VCSEAS',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(162));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'VCEASN',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(133) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(133),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                g_default_pro := 'Y';
              END IF;

          END IF;

      ELSIF  p_field_number = 162
      THEN

          g_default_pro := 'N';

          -- VCE AS level Tariff Score
          IF g_field_defn.hesa_value.EXISTS(162) AND g_field_defn.hesa_value(162) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(162);
              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'VCEASTS',
                                                           p_tariff_score   => p_value);

          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(133) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(133),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 163
      THEN

          g_default_pro := 'N';

          -- Number of GCE A Levels
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'GCSEA',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(164));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'GCEAN',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(133) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(133),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                g_default_pro := 'Y';
              END IF;

          END IF;

      ELSIF  p_field_number = 164
      THEN

          g_default_pro := 'N';

          -- GCE A level Tariff Score
          IF g_field_defn.hesa_value.EXISTS(164) AND g_field_defn.hesa_value(164) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(164);

              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'GCEATS',
                                                           p_tariff_score   => p_value);

          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(133) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(133),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 165
      THEN

          g_default_pro := 'N';

          -- Number of VCE A Levels
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'VCSEA',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(166));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'VCEAN',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(133) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(133),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                g_default_pro := 'Y';
              END IF;

          END IF;

      ELSIF  p_field_number = 166
      THEN

          g_default_pro := 'N';

          -- VCE A level Tariff Score
          IF g_field_defn.hesa_value.EXISTS(166) AND g_field_defn.hesa_value(166) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(166);

              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'VCEATS',
                                                           p_tariff_score   => p_value);

          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(133) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(133),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 167
      THEN

          g_default_pro := 'N';

          -- Number of Key Skill Qualifications
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'KEYSKL',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(168));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'KSQN',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(133) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(133),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                g_default_pro := 'Y';
              END IF;

          END IF;

      ELSIF  p_field_number = 168
      THEN

          g_default_pro := 'N';

          -- Key Skills Tariff Score
          IF g_field_defn.hesa_value.EXISTS(168) AND g_field_defn.hesa_value(168) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(168);

              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'KSQTS',
                                                           p_tariff_score   => p_value);

          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(133) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(133),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 169
      THEN

          g_default_pro := 'N';

          -- Number of 1 unit key skill awards
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  '1UNKEYSKL',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(170));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'UKSAN',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(133) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(133),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                g_default_pro := 'Y';
              END IF;

          END IF;
      ELSIF  p_field_number = 170
      THEN

          g_default_pro := 'N';

          -- 1 Unit Key Skill Tariff Score
          IF g_field_defn.hesa_value.EXISTS(170) AND g_field_defn.hesa_value(170) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(170);

              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'UKSATS',
                                                           p_tariff_score   => p_value);

          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(133) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(133),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 171
      THEN

          g_default_pro := 'N';

          -- Number of Scottish Advanced Higher Levels
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'SCOTADH',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(172));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'SAHN',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(133) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(133),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                g_default_pro := 'Y';
              END IF;

          END IF;


      ELSIF  p_field_number = 172
      THEN

          g_default_pro := 'N';

          -- Scottish Advanced Higher level Tariff Score
          IF g_field_defn.hesa_value.EXISTS(172) AND g_field_defn.hesa_value(172) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(172);

              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'SAHTS',
                                                           p_tariff_score   => p_value);

          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(133) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(133),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 173
      THEN

          g_default_pro := 'N';

          -- Number of Scottish Higher Levels
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'SCOTH',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(174));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'SHN',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(133) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(133),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                g_default_pro := 'Y';
              END IF;

          END IF;

      ELSIF  p_field_number = 174
      THEN

          g_default_pro := 'N';

          -- Scottish Higher level Tariff Score
          IF g_field_defn.hesa_value.EXISTS(174) AND g_field_defn.hesa_value(174) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(174);

              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'SHTS',
                                                           p_tariff_score   => p_value);

          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(133) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(133),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 175
      THEN

          g_default_pro := 'N';

          -- Number of Scottish Intermediate Levels
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'SCOTI2',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(176));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'SI2N',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(133) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(133),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                g_default_pro := 'Y';
              END IF;

          END IF;

      ELSIF  p_field_number = 176
      THEN

          g_default_pro := 'N';

          -- Scottish Intermediate level Tariff Score
          IF g_field_defn.hesa_value.EXISTS(176) AND g_field_defn.hesa_value(176) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(176);

              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'SI2TS',
                                                           p_tariff_score   => p_value);

          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(133) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(133),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 177
      THEN

          g_default_pro := 'N';

          -- Number of Scottish Standard Grade Credit Levels
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'SCOTST',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(178));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'SSGCN',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(133) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(133),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                g_default_pro := 'Y';
              END IF;

          END IF;


      ELSIF  p_field_number = 178
      THEN

          g_default_pro := 'N';

          --  Scottish Standard Grade  level Tariff Score
          IF g_field_defn.hesa_value.EXISTS(178) AND g_field_defn.hesa_value(178) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(178);

              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'SSGCTS',
                                                           p_tariff_score   => p_value);

          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(133) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(133),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 179
      THEN

          g_default_pro := 'N';

          -- Number of Scottish Core Skills Levels
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'SCOTCO',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(180));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'SCSN',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(133) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(133),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                g_default_pro := 'Y';
              END IF;

          END IF;

      ELSIF  p_field_number = 180
      THEN

          g_default_pro := 'N';

          -- Scottish Core Skills level Tariff Score
          IF g_field_defn.hesa_value.EXISTS(180) AND g_field_defn.hesa_value(180) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(180);

              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'SCSTS',
                                                           p_tariff_score   => p_value);

          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(133) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(133),
                  p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 181
      THEN

          g_default_pro := 'N';

          -- Number of Advanced Extension
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'ADVEXT',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(182));

          IF p_value IS NOT NULL THEN
            igs_he_extract_fields_pkg.limit_no_of_qual(p_field_number   => p_field_number,
                                                       p_person_number  => g_pe_person.person_number,
                                                       p_course_cd      => p_course_cd,
                                                       p_hesa_qual      => 'AEAN',
                                                       p_no_of_qual     => p_value);
          ELSE
              -- If is a UCAS (FTUG, NMAS or SWAS) student with no qualification details use default value
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(133) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(133),
                      p_min_commdate      => TO_DATE('31/07/2003', 'DD/MM/YYYY'))
              THEN
                g_default_pro := 'Y';
              END IF;

          END IF;

      ELSIF  p_field_number = 182
      THEN

          g_default_pro := 'N';

          -- Advanced Extension Tariff Score
          IF g_field_defn.hesa_value.EXISTS(182) AND g_field_defn.hesa_value(182) IS NOT NULL
          THEN
              p_value := g_field_defn.hesa_value(182);

              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'AENTS',
                                                           p_tariff_score   => p_value);

          END IF;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NULL AND
             g_field_defn.hesa_value.EXISTS(41)  AND
             g_field_defn.hesa_value.EXISTS(26)  AND
             g_field_defn.hesa_value.EXISTS(133) AND
             igs_he_extract_fields_pkg.is_ucas_ftug
                 (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                  p_hesa_commdate     => g_field_defn.hesa_value(26),
                  p_ucasnum           => g_field_defn.hesa_value(133),
                  p_min_commdate      => TO_DATE('31/07/2003', 'DD/MM/YYYY'))
          THEN
              g_default_pro := 'Y';
          END IF;

      ELSIF  p_field_number = 183
      THEN

          g_default_pro := 'N';

          -- Total Tariff Score
          p_value :=  g_he_st_spa.total_ucas_tariff;

          -- If is a UCAS (FTUG, NMAS or SWAS) student with no tariff information use default value
          IF p_value IS NOT NULL
          THEN
              igs_he_extract_fields_pkg.limit_tariff_score(p_field_number   => p_field_number,
                                                           p_person_number  => g_pe_person.person_number,
                                                           p_course_cd      => p_course_cd,
                                                           p_hesa_qual      => 'TOTALTS',
                                                           p_tariff_score   => p_value);
          ELSE
              IF g_field_defn.hesa_value.EXISTS(41)  AND
                 g_field_defn.hesa_value.EXISTS(26)  AND
                 g_field_defn.hesa_value.EXISTS(133) AND
                 igs_he_extract_fields_pkg.is_ucas_ftug
                     (p_hesa_qual_aim     => g_field_defn.hesa_value(41),
                      p_hesa_commdate     => g_field_defn.hesa_value(26),
                      p_ucasnum           => g_field_defn.hesa_value(133),
                      p_min_commdate      => TO_DATE('31/07/2002', 'DD/MM/YYYY'))
              THEN
                  g_default_pro := 'Y';
              END IF;
          END IF;

      ELSIF  p_field_number = 184
      THEN
          -- Number of CACHE qualifications
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'CACHE',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(185));

      ELSIF  p_field_number = 185
      THEN
          -- CACHE qualifications Tariff Score
          IF g_field_defn.hesa_value.EXISTS(185)
          THEN
              p_value := g_field_defn.hesa_value(185);
          END IF;

      ELSIF  p_field_number = 186
      THEN
          -- Number of BTEC
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'BTEC',
               p_no_of_qual           =>  p_value,
               p_tariff_score         =>  g_field_defn.hesa_value(187));

      ELSIF  p_field_number = 187
      THEN
          -- BTEC Tariff Score
          IF g_field_defn.hesa_value.EXISTS(187)
          THEN
              p_value := g_field_defn.hesa_value(187);
          END IF;

      ELSIF  p_field_number = 188
      THEN
          -- International Baccalaureate Tariff Score
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'INBA',
               p_no_of_qual           =>  l_dummy,
               p_tariff_score         =>  p_value);

      ELSIF  p_field_number = 189
      THEN
          -- Irish Leaving certificate tariff score
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'ILC',
               p_no_of_qual           =>  l_dummy,
               p_tariff_score         =>  p_value);

      ELSIF  p_field_number = 190
      THEN
          -- Music, Drama and Performing Arts
          igs_he_extract_fields_pkg.get_qual_dets
              (p_person_id            =>  p_person_id,
               p_course_cd            =>  p_course_cd,
               p_hesa_qual            =>  'MUDRPA',
               p_no_of_qual           =>  l_dummy,
               p_tariff_score         =>  p_value);

      ELSIF  p_field_number = 191
      THEN
               g_default_pro:= 'N';
               IF g_field_defn.hesa_value.EXISTS(6) AND   g_field_defn.hesa_value(6) IN (1,3,4)     THEN
                  -- Guided Learning Hours
                  p_value := To_char(g_ps_ver.contact_hours,'00000');
                  g_default_pro:= 'Y';
               END IF;

      ELSIF  p_field_number = 192
      THEN
          -- Marital Status
          igs_he_extract_fields_pkg.get_marital_status
              (p_oss_marital_status     =>  g_pe_stat_v.marital_status,
               p_hesa_marital_status    =>  p_value);

      ELSIF  p_field_number = 193
      THEN
          -- Dependants
          igs_he_extract_fields_pkg.get_dependants
              (p_oss_dependants     =>  g_he_st_spa.dependants_cd,
               p_hesa_dependants    =>  p_value);

      ELSIF  p_field_number = 194
      THEN
        -- Eligibility for enhanced funding
        --Set the  default variable value as default value has to be calculated only for the down condition
        g_default_pro := 'N';

        IF g_he_submsn_header.validation_country IN   ('ENGLAND') THEN

          -- Student must be FE student
          IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)) THEN

                igs_he_extract_fields_pkg.get_enh_fund_elig
                 (p_susa_enh_fund_elig   => g_he_en_susa.enh_fund_elig_cd,
                  p_spa_enh_fund_elig    => g_he_st_spa.enh_fund_elig_cd,
                  p_hesa_enh_fund_elig   => p_value);

                --If the value is calculated as NULL above then do the default processing for this field
                g_default_pro := 'Y' ;
          END IF;
        END IF;

      ELSIF  p_field_number = 195
      THEN
        --Additional Support Cost
        --Set the  default variable value as default value has to be calculated only for the down condition
        g_default_pro := 'N';

        IF g_he_submsn_header.validation_country IN   ('ENGLAND') THEN

          -- Student must be FE student
          IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)) THEN

                IF (g_he_en_susa.additional_sup_cost IS NOT NULL) THEN
                      -- LPad additional_sup_cost to 6 places
                      p_value := LPAD(g_he_en_susa.additional_sup_cost, 6,'0');
                END IF;

                --If the value is calculated as NULL above then do the default processing for this field
                g_default_pro := 'Y' ;
          END IF;
        END IF;

      ELSIF  p_field_number = 196
      THEN
        -- Learning Difficulty
        --Set the  default variable value as default value has to be calculated only for the down condition
        g_default_pro := 'N';

        IF g_he_submsn_header.validation_country IN   ('ENGLAND') THEN

          -- Student must be FE student
          IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)) THEN

                igs_he_extract_fields_pkg.get_learn_dif
                 (p_person_id            =>  p_person_id,
                  p_enrl_start_dt        =>  g_he_submsn_header.enrolment_start_date,
                  p_enrl_end_dt          =>  g_he_submsn_header.enrolment_end_date,
                  p_hesa_disability_type =>  p_value);

                --If the value is calculated as NULL above then do the default processing for this field
                g_default_pro := 'Y' ;
          END IF;
        END IF;

      ELSIF  p_field_number = 197
      THEN
        --Implied rate of council partial funding
        --Set the  default variable value as default value has to be calculated only for the down condition
        g_default_pro := 'N';

        IF g_he_submsn_header.validation_country IN   ('ENGLAND') THEN

          -- Student must be FE student
          -- AND ESF funded
          IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4))
             AND (g_field_defn.hesa_value.EXISTS(64)  AND g_field_defn.hesa_value(64) IN ('86','87','88','AA','AB','AC','AD'))
          THEN

                p_value := NVL(g_he_st_spa.implied_fund_rate,g_he_st_prog.implied_fund_rate);

                IF (p_value IS NOT NULL) THEN
                      p_value := LPAD(p_value, 3,'0');
                END IF;

                --If the value is calculated as NULL above then do the default processing for this field
                g_default_pro := 'Y' ;
          END IF;
        END IF;


      ELSIF  p_field_number = 198
      THEN
        --Government initiatives
        --Set the  default variable value as default value has to be calculated only for the down condition
        g_default_pro := 'N';

        IF g_he_submsn_header.validation_country IN   ('ENGLAND') THEN

          -- Student must be FE student
          IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)) THEN

                igs_he_extract_fields_pkg.get_gov_init
                 (p_spa_gov_initiatives_cd   => g_he_st_spa.gov_initiatives_cd,
                  p_prog_gov_initiatives_cd  => g_he_st_prog.gov_initiatives_cd,
                  p_hesa_gov_initiatives_cd  => p_value);

                --If the value is calculated as NULL above then do the default processing for this field
                g_default_pro := 'Y' ;
          END IF;
        END IF;

      ELSIF  p_field_number = 199
      THEN
        -- Number of units completed
        --Set the  default variable value as default value has to be calculated only for the down condition
        g_default_pro := 'N';

        IF g_he_submsn_header.validation_country IN   ('ENGLAND') THEN

          -- Student must be FE student
          IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)) THEN

                igs_he_extract_fields_pkg.get_units_completed
                 (p_person_id                => p_person_id,
                  p_course_cd                => p_course_cd,
                  p_enrl_end_dt              => g_he_submsn_header.enrolment_end_date,
                  p_spa_units_completed      => g_he_st_spa.units_completed,
                  p_hesa_units_completed     => p_value);

                IF (p_value IS NOT NULL) THEN
                      p_value := LPAD(p_value, 2,'0');
                END IF;

                --If the value is calculated as NULL above then do the default processing for this field
                g_default_pro := 'Y' ;
          END IF;
        END IF;

        ELSIF  p_field_number = 200
        THEN
         --Number of units to achieve full qualification
          --Set the  default variable value as default value has to be calculated only for the down condition
          g_default_pro := 'N';

          IF g_he_submsn_header.validation_country IN   ('ENGLAND') THEN

            -- Student must be FE student
            IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)) THEN

                  p_value := NVL(g_he_st_spa.units_for_qual,g_he_st_prog.units_for_qual);

                  IF (p_value IS NOT NULL) THEN
                        p_value := LPAD(p_value, 2,'0');
                  END IF;

                  --If the value is calculated as NULL above then do the default processing for this field
                  g_default_pro := 'Y' ;
            END IF;
         END IF;

      ELSIF  p_field_number = 201
      THEN
        --Eligibility for disadvantage uplift
        --Set the  default variable value as default value has to be calculated only for the down condition
        g_default_pro := 'N';

        IF g_he_submsn_header.validation_country IN   ('ENGLAND') THEN

          -- Student must be FE student
          IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)) THEN

                igs_he_extract_fields_pkg.get_disadv_uplift_elig
                 (p_spa_disadv_uplift_elig_cd   => g_he_st_spa.disadv_uplift_elig_cd,
                  p_prog_disadv_uplift_elig_cd  => g_he_st_prog.disadv_uplift_elig_cd,
                  p_hesa_disadv_uplift_elig_cd  => p_value);

                --If the value is calculated as NULL above then do the default processing for this field
                g_default_pro := 'Y' ;
          END IF;
        END IF;

       ELSIF  p_field_number = 202
       THEN
         --Disadvantage uplift factor
         --Set the  default variable value as default value has to be calculated only for the down condition
         g_default_pro := 'N';

         IF g_he_submsn_header.validation_country IN   ('ENGLAND') THEN

           -- Student must be FE student
           IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)) THEN

                 l_disadv_uplift_factor := NVL(g_he_en_susa.disadv_uplift_factor,g_he_st_spa.disadv_uplift_factor) ;

                 IF (l_disadv_uplift_factor IS NOT NULL) THEN
                       p_value := Ltrim(To_Char(l_disadv_uplift_factor,'0.0000'));
                 END IF;

                 --If the value is calculated as NULL above then do the default processing for this field
                 g_default_pro := 'Y' ;
           END IF;
        END IF;

       ELSIF  p_field_number = 203
       THEN
         --Franchised out arrangements
         --Set the  default variable value as default value has to be calculated only for the down condition
         g_default_pro := 'N';

         IF g_he_submsn_header.validation_country IN   ('ENGLAND') THEN

           -- Student must be FE student
           IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)) THEN

                 igs_he_extract_fields_pkg.get_franch_out_arr
                  (p_spa_franch_out_arr_cd   => g_he_st_spa.franch_out_arr_cd,
                   p_prog_franch_out_arr_cd  => g_he_st_prog.franch_out_arr_cd,
                   p_hesa_franch_out_arr_cd  => p_value);

                 --If the value is calculated as NULL above then do the default processing for this field
                 g_default_pro := 'Y' ;
           END IF;
        END IF;

       ELSIF  p_field_number = 204
       THEN
         --Employer role
         --Set the  default variable value as default value has to be calculated only for the down condition
         g_default_pro := 'N';

         IF g_he_submsn_header.validation_country IN   ('ENGLAND','WALES') THEN

           -- Student must be FE student
           IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)) THEN

                 igs_he_extract_fields_pkg.get_employer_role
                  (p_spa_employer_role_cd   => g_he_st_spa.employer_role_cd,
                   p_hesa_employer_role_cd  => p_value);

                 --If the value is calculated as NULL above then do the default processing for this field
                 g_default_pro := 'Y' ;
           END IF;
        END IF;

       ELSIF  p_field_number = 205
       THEN
         --Franchise partner code
         --Set the  default variable value as default value has to be calculated only for the down condition
         g_default_pro := 'N';

         IF g_he_submsn_header.validation_country IN   ('WALES') THEN

           -- Student must be FE student
           IF (g_field_defn.hesa_value.EXISTS(6)  AND g_field_defn.hesa_value(6) IN (1,3,4)) THEN

                 igs_he_extract_fields_pkg.get_franchise_partner
                  (p_spa_franch_partner_cd    => g_he_st_spa.franch_partner_cd,
                   p_hesa_franch_partner_cd   => p_value);

                 --If the value is calculated as NULL above then do the default processing for this field
                 g_default_pro := 'Y' ;
           END IF;
        END IF;

       ELSIF  p_field_number = 206
       THEN
         -- Welsh speaker identifier
         --Set the  default variable value as default value has to be calculated only for the down condition
         g_default_pro := 'N';

         IF g_he_submsn_header.validation_country IN   ('WALES') THEN

           -- Student must be FE student
           IF (g_field_defn.hesa_value.EXISTS(12)  AND g_field_defn.hesa_value(12) IN (6826)) THEN

                 igs_he_extract_fields_pkg.get_welsh_speaker_ind
                  (p_person_id                => p_person_id,
                   p_hesa_welsh_speaker_ind   => p_value);

                 --If the value is calculated as NULL above then do the default processing for this field
                 g_default_pro := 'Y' ;
           END IF;
        END IF;

       ELSIF  p_field_number = 207
       THEN
         -- National ID 1
         --Set the  default variable value as default value has to be calculated only for the down condition
         g_default_pro := 'N';

         IF g_he_submsn_header.validation_country IN   ('WALES') THEN

           -- Student must be FE student
           IF (g_field_defn.hesa_value.EXISTS(12)  AND g_field_defn.hesa_value(12) IN (6826)) THEN

                 igs_he_extract_fields_pkg.get_national_id
                  (p_person_id                => p_person_id,
                   p_hesa_national_id1        => p_value,
                   p_hesa_national_id2        => g_field_defn.hesa_value(208) );

                  --If the value is calculated as NULL above then do the default processing for this field
                 g_default_pro := 'Y' ;
           END IF;
         END IF;

        ELSIF  p_field_number = 208
        THEN

          -- National ID 2
          IF g_field_defn.hesa_value.EXISTS(208)
          THEN
              p_value :=  g_field_defn.hesa_value(208);
          ELSE

             --Set the  default variable value as default value has to be calculated only for the down condition
             g_default_pro := 'N';

             IF g_he_submsn_header.validation_country IN   ('WALES') THEN

               -- Student must be FE student
               IF (g_field_defn.hesa_value.EXISTS(12)  AND g_field_defn.hesa_value(12) IN (6826)) THEN

                     igs_he_extract_fields_pkg.get_national_id
                      (p_person_id                => p_person_id,
                       p_hesa_national_id1        => g_field_defn.hesa_value(207),
                       p_hesa_national_id2        => p_value);

                     --If the value is calculated as NULL above then do the default processing for this field
                     g_default_pro := 'Y' ;
               END IF;
            END IF;
         END IF;

        -- anwest 19-Dec-2005 (4731723) HE360 - HESA REQUIREMENTS FOR 2005/06 REPORTING
        ELSIF  p_field_number = 209 THEN

          IF p_value IS NULL THEN

            IF g_field_defn.hesa_value.EXISTS(12) AND
               g_field_defn.hesa_value(12) IN ('6826') THEN

              igs_he_extract_fields_pkg.get_welsh_bacc_qual(p_person_id  => p_person_id,
                                                            p_welsh_bacc => p_value);

              IF p_value = '3' THEN

                IF g_he_submsn_header.validation_country = 'WALES' AND
                   g_en_stdnt_ps_att.commencement_dt > TO_DATE('31/07/2005', 'DD/MM/YYYY') AND
                   g_field_defn.hesa_value.EXISTS(41) AND
                   ((g_field_defn.hesa_value(41) >= 18 AND g_field_defn.hesa_value(41) <= 52) OR
                     g_field_defn.hesa_value(41) IN ('61', '97')) THEN

                  null; -- Leave field value as '3'

                ELSE

                  p_value := NULL;

                END IF;

              END IF;

            ELSE

              g_default_pro := 'N';
              p_value := NULL;

            END IF;

          END IF;

        END IF; -- for each field from 1 to 209

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);
          fnd_message.set_name('IGS','IGS_HE_FIELD_NUM');
          fnd_message.set_token('field_number',p_field_number);
          IGS_GE_MSG_STACK.ADD;
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT2_PKG.process_stdnt_fields');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

   END process_stdnt_fields;

   /*----------------------------------------------------------------------
   This procedure gets values for the individual fields to be
   submitted in the HESA MODULE Return

   Parameters :
   p_unit_cd                Unit Code
   p_uv_version_number      Unit Code Version Number
   p_field_number           Field Number currently being processed.
   p_value                  Calculated Value of the field.
   ----------------------------------------------------------------------*/
   PROCEDURE process_module_fields
             (p_unit_cd             IN igs_he_ex_rn_dat_ln.unit_cd%TYPE,
              p_uv_version_number   IN igs_he_ex_rn_dat_ln.uv_version_number%TYPE,
              p_field_number        IN igs_he_ex_rn_dat_fd.field_number%TYPE,
              p_value               IN OUT NOCOPY igs_he_ex_rn_dat_fd.value%TYPE)
   IS
 /***************************************************************
   Created By           :
   Date Created By      :
   Purpose              :This procedure gets the value for the module related fields
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                  What
   Bayadav  26-Mar-2002 Changed the logic for field number 3 as a part of HECR001 (Bug number 2278825)
   Bayadav  26-Mar-2002 Changed the logic for field number 13 and 16 as a part of HECR004(Bug number 2278825)
   smaddali 17-dec-03   for field 3 ,removed the code getting campusid from igs_en_stdnt_ps_att.location_cd for bug#3216400  |
   jbaber   20-Sep-04   Modified as per HEFD350 - Statutory changes for 2004/05 Reporting
                        Modified fields: 12
                        Created fields:  21-26
 ***************************************************************/
   l_message               VARCHAR2(2000);
   l_fte_prop    igs_he_st_unt_vs.proportion_of_fte%TYPE  ;
   l_prop_not_taught  NUMBER ;

   BEGIN

      p_value := NULL;
      l_fte_prop := NULL;
      l_prop_not_taught := NULL;

      IF      p_field_number = 1
      THEN
          -- Record Type Identifier
          p_value := g_he_submsn_return.record_id;

      ELSIF  p_field_number = 2
      THEN
          -- Hesa Institution Id
          igs_he_extract_fields_pkg.get_hesa_inst_id
              (p_hesa_inst_id => p_value);

      ELSIF  p_field_number = 3
      THEN

   -- Included the below logic as a part of HECR001(Bug 2278825)
    --Check if location is recroded at unit level .If yes then get the cooressponding HESA mapped campus id
      IF g_he_st_unt_vs.location_cd IS NOT NULL THEN
         igs_he_extract_fields_pkg.get_campus_id
                         (p_location_cd => g_he_st_unt_vs.location_cd,
                          p_campus_id   => p_value);
         -- smaddali removed the code getting campusid from igs_en_stdnt_ps_att.location_cd for bug#3216400
         -- because student is not related to module return
      END IF;

      ELSIF  p_field_number = 4
      THEN
          -- Module Title
          p_value := g_ps_unit_ver_v.title;

      ELSIF  p_field_number = 5
      THEN
          -- Module Identifier
          p_value := p_unit_cd || '.' ||
                     p_uv_version_number;

      ELSIF  p_field_number = 6
      THEN
          -- Proportion of FTE
           --smaddali adding format mask '000.0' for bug 2437081
          IF g_he_st_unt_vs.proportion_of_fte IS NOT NULL
          THEN
              p_value := Ltrim(To_Char(g_he_st_unt_vs.proportion_of_fte,'000.0') );
          ELSE
              igs_he_extract_fields_pkg.get_mod_prop_fte
                  (p_enrolled_credit_points   =>  g_ps_unit_ver_v.enrolled_credit_points,
                   p_unit_level               =>  g_ps_unit_ver_v.unit_level,
                   p_prop_of_fte              =>  l_fte_prop);
               --smaddali adding format mask '000.0' for bug 2437081
               p_value := Ltrim( To_char(l_fte_prop,'000.0') );

          END IF;


      ELSIF  p_field_number = 7
      THEN
          -- Proportion not taught by this institution
          igs_he_extract_fields_pkg.get_mod_prop_not_taught
              (p_unit_cd            =>  p_unit_cd,
               p_version_number     =>  p_uv_version_number,
               p_prop_not_taught    =>  l_prop_not_taught);
           --smaddali adding format mask '000.0' for bug 2437081
           p_value := ltrim(to_char(l_prop_not_taught,'000.0' )) ;

      ELSIF  p_field_number = 8
      THEN
          -- Credit Transfer Scheme
          igs_he_extract_fields_pkg.get_credit_trans_sch
          (p_oss_credit_trans_sch   =>  g_he_st_unt_vs.credit_transfer_scheme,
           p_hesa_credit_trans_sch  =>  p_value);

      ELSIF  p_field_number = 9
      THEN
          -- Credit Value of Module
           --smaddali adding format mask '000' for bug 2437081
          p_value := Ltrim( to_char(g_ps_unit_ver_v.enrolled_credit_points,'000') );

      ELSIF  p_field_number = 10
      THEN
          -- Level of Credit Points
          IF g_field_defn.hesa_value.EXISTS(9)
          THEN
              IF  g_field_defn.hesa_value(9) <> '999'
              THEN
                  igs_he_extract_fields_pkg.get_credit_level
                     (p_susa_credit_level    => NULL ,
                      p_poous_credit_level     =>  g_ps_unit_ver_v.unit_level,
                      p_hesa_credit_level    =>  p_value);
              END IF;
          END IF;

      ELSIF  p_field_number = 11
      THEN
          -- Module length
          p_value := g_he_st_unt_vs.module_length;

      ELSIF  p_field_number = 12
      THEN
          -- Cost Centre 1
          --smaddali added the initialisation of variable g_cc_rec for bug 2417370
          --jbaber added p_validation_country for HEFD350
          g_cc_rec := NULL ;
          g_total_ccs := 0;
          igs_he_extract_fields_pkg.get_cost_centres
          (p_person_id           =>  NULL,
           p_course_cd           =>  NULL,
           p_version_number      =>  NULL,
           p_unit_set_cd         =>  NULL,
           p_us_version_number   =>  NULL,
           p_cal_type            =>  NULL,
           p_attendance_mode     =>  NULL,
           p_attendance_type     =>  NULL,
           p_location_cd         =>  NULL,
           p_program_calc        =>  NULL,
           p_unit_cd             =>  p_unit_cd,
           p_uv_version_number   =>  p_uv_version_number,
           p_return_type         =>  'M',
           p_cost_ctr_rec        =>  g_cc_rec,
           p_total_recs          =>  g_total_ccs,
           p_enrl_start_dt       => NULL,
           p_enrl_end_dt         => NULL,
           p_sequence_number     => NULL,
           p_validation_country  =>  g_he_submsn_header.validation_country);


           IF g_total_ccs >= 1
           THEN
               p_value := g_cc_rec.cost_centre(1);
           END IF;


      ELSIF  p_field_number = 13
      THEN
          -- Subject 1
          IF g_total_ccs >= 1
          THEN
              -- smaddali removed the corsor getting govt field of study for bug 2417454
                    p_value := g_cc_rec.subject(1) ;
          END IF;

      ELSIF  p_field_number = 14
      THEN
          -- Proportion 1
          IF g_total_ccs >= 1
          THEN
              --smaddali added format mask '000.0' to this field for bug 2437279
              p_value := Ltrim(To_Char(g_cc_rec.proportion(1),'000.0') );
          END IF;


      ELSIF  p_field_number = 15
      THEN
          -- Cost centre 2
          IF g_total_ccs >= 2
          THEN
              p_value := g_cc_rec.cost_centre(2);
          END IF;

      ELSIF  p_field_number = 16
      THEN
          -- Subject 2
          IF g_total_ccs >= 2
          THEN
              -- smaddali removed the corsor getting govt field of study for bug 2417454
                   p_value := g_cc_rec.subject(2);
          END IF;

      ELSIF  p_field_number = 17
      THEN
          -- Proportion 2
          --smaddali added format mask '000.0' to this field for bug 2437279
          IF g_total_ccs >= 2
          THEN
              p_value := Ltrim(To_Char(g_cc_rec.proportion(2),'000.0') );
          END IF;

      ELSIF  p_field_number = 18
      THEN
          -- Not Used
          p_value := NULL;

      ELSIF  p_field_number = 19
      THEN
          -- Other Institution Providing teaching 1
          igs_he_extract_fields_pkg.get_mod_oth_teach_inst
              (p_unit_cd             =>  p_unit_cd,
               p_version_number      =>  p_uv_version_number,
               p_oth_teach_inst      =>  p_value);

      ELSIF  p_field_number = 20
      THEN
          -- Not Used
          p_value := NULL;

      -- jbaber - HEFD350 - Added fields 21-26
      ELSIF  p_field_number = 21
      THEN

          -- Value or default only used if validation country is Scotland for bug 4242260
          IF g_he_submsn_header.validation_country IN   ('SCOTLAND') THEN

              g_default_pro := 'Y';

          -- Cost centre 3
          IF g_total_ccs >= 3
          THEN
              p_value := g_cc_rec.cost_centre(3);
          END IF;

          ELSE
              p_value := NULL;
              g_default_pro := 'N';
          END IF;


      ELSIF  p_field_number = 22
      THEN

          -- Value or default only used if validation country is Scotland for bug 4242260
          IF g_he_submsn_header.validation_country IN   ('SCOTLAND') THEN

              g_default_pro := 'Y';

          -- Subject 3
          IF g_total_ccs >= 3
          THEN
              -- smaddali removed the corsor getting govt field of study for bug 2417454
                   p_value := g_cc_rec.subject(3);
          END IF;

          ELSE
              p_value := NULL;
              g_default_pro := 'N';
          END IF;

      ELSIF  p_field_number = 23
      THEN

          -- Value or default only used if validation country is Scotland for bug 4242260
          IF g_he_submsn_header.validation_country IN   ('SCOTLAND') THEN

              g_default_pro := 'Y';

          -- Proportion 3
          --smaddali added format mask '000.0' to this field for bug 2437279
          IF g_total_ccs >= 3
          THEN
              p_value := Ltrim(To_Char(g_cc_rec.proportion(3),'000.0') );
          END IF;

          ELSE
              p_value := NULL;
              g_default_pro := 'N';
          END IF;

      ELSIF  p_field_number = 24
      THEN

          -- Value or default only used if validation country is Scotland for bug 4242260
          IF g_he_submsn_header.validation_country IN   ('SCOTLAND') THEN

              g_default_pro := 'Y';

          -- Cost centre 4
          IF g_total_ccs >= 4
          THEN
              p_value := g_cc_rec.cost_centre(4);
          END IF;

          ELSE
              p_value := NULL;
              g_default_pro := 'N';
          END IF;

      ELSIF  p_field_number = 25
      THEN

          -- Value or default only used if validation country is Scotland for bug 4242260
          IF g_he_submsn_header.validation_country IN   ('SCOTLAND') THEN

              g_default_pro := 'Y';

          -- Subject 4
          IF g_total_ccs >= 4
          THEN
              -- smaddali removed the corsor getting govt field of study for bug 2417454
                   p_value := g_cc_rec.subject(4);
          END IF;

          ELSE
              p_value := NULL;
              g_default_pro := 'N';
          END IF;

      ELSIF  p_field_number = 26
      THEN

          -- Value or default only used if validation country is Scotland for bug 4242260
          IF g_he_submsn_header.validation_country IN   ('SCOTLAND') THEN

              g_default_pro := 'Y';

          -- Proportion 4
          --smaddali added format mask '000.0' to this field for bug 2437279
          IF g_total_ccs >= 4
          THEN
              p_value := Ltrim(To_Char(g_cc_rec.proportion(4),'000.0') );
          END IF;

          ELSE
              p_value := NULL;
              g_default_pro := 'N';
          END IF;

      END IF ; -- p_field_number

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);
          fnd_message.set_name('IGS','IGS_HE_FIELD_NUM');
          fnd_message.set_token('field_number',p_field_number);
          IGS_GE_MSG_STACK.ADD;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT2_PKG.process_module_fields');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END process_module_fields;




   /*----------------------------------------------------------------------
   This procedure gets values for the individual fields to be
   submitted in the HESA DLHE returns

   Parameters :
   p_person_id              Person_id for the student
   p_field_number           Field Number currently being processed.
   p_value                  Calculated Value of the field.

   ----------------------------------------------------------------------*/
   PROCEDURE process_dlhe_fields
             (p_person_id           IN  igs_he_ex_rn_dat_ln.person_id%TYPE,
              p_field_number        IN   NUMBER,
              p_value               IN OUT NOCOPY   igs_he_ex_rn_dat_fd.value%TYPE)

   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :This procedure gets the value of DLHE related fields
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who        When          What
   smaddali   23-sep-03    Modified fields 14 and 37 to 46 for HECR011 build, bug#3051597
 ***************************************************************/

           l_inst_id          igs_or_institution.govt_institution_cd%TYPE;

   BEGIN

      p_value           := NULL;
      g_default_pro     := 'Y';

      -- depending on the field number call the respective procedure to derive its value
      IF      p_field_number = 1
      THEN
          -- Record Type Identifier
          p_value := g_he_submsn_return.record_id;

      ELSIF  p_field_number = 2
      THEN
          -- Hesa Institution Id
          igs_he_extract_fields_pkg.get_hesa_inst_id
              (p_hesa_inst_id => p_value);

      ELSIF  p_field_number = 3
      THEN
          -- Student Identifier
          -- Pass in the Institution Id
          IF g_field_defn.hesa_value.EXISTS(2)
          THEN
              l_inst_id := g_field_defn.hesa_value(2);
          ELSE
              l_inst_id := 0;
          END IF;

        -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
          igs_he_extract_fields_pkg.get_stdnt_id
              (p_person_id              => p_person_id,
               p_inst_id                => l_inst_id,
               p_stdnt_id               => p_value,
               p_enrl_start_dt          =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt            =>  g_he_submsn_header.enrolment_end_date);


      ELSIF  p_field_number = 4
      THEN
          -- Method of data collection
          igs_he_extract_dlhe_fields_pkg.get_survey_method
                 (p_dlhe_method    => g_he_stdnt_dlhe.survey_method,
                  p_hesa_method    => p_value);
          l_hesa_method := p_value ;

      ELSIF  p_field_number = 5
      THEN
          -- Employment circumstances
          igs_he_extract_dlhe_fields_pkg.get_empcir
                 (p_hesa_method     => l_hesa_method,
                  p_dlhe_employment => g_he_stdnt_dlhe.Employment,
                  p_hesa_empcir     => p_value);
          l_hesa_empcir := p_value ;

      ELSIF  p_field_number = 6
      THEN
          -- Mode of Study
          igs_he_extract_dlhe_fields_pkg.get_mode_study
                 (p_hesa_method        => l_hesa_method,
                  p_dlhe_further_study => g_he_stdnt_dlhe.Further_study,
                  p_hesa_modstudy      => p_value);
          l_hesa_modstudy := p_value ;

      ELSIF  p_field_number = 7
      THEN
          -- Nature of employers business
          igs_he_extract_dlhe_fields_pkg.get_makedo
                 (p_hesa_method       => l_hesa_method,
                  p_hesa_empcir       => l_hesa_empcir,
                  p_dlhe_Emp_business => g_he_stdnt_dlhe.Employer_business,
                  p_hesa_makedo       => p_value);

      ELSIF  p_field_number = 8
      THEN
          -- Standard Industrial Classification
          igs_he_extract_dlhe_fields_pkg.get_sic
                 (p_hesa_method    => l_hesa_method,
                  p_hesa_empcir    => l_hesa_empcir,
                  p_dlhe_Emp_class => g_he_stdnt_dlhe.Employer_classification,
                  p_hesa_sic       => p_value);


      ELSIF  p_field_number = 9
      THEN
          -- Location of employment
          igs_he_extract_dlhe_fields_pkg.get_emp_loc
                 (p_hesa_method       => l_hesa_method,
                  p_hesa_empcir       => l_hesa_empcir,
                  p_dlhe_Emp_postcode => g_he_stdnt_dlhe.Employer_postcode,
                  p_dlhe_emp_country  => g_he_stdnt_dlhe.Employer_country,
                  p_hesa_locemp       => p_value);

      ELSIF  p_field_number = 10
      THEN
          -- Job title
          igs_he_extract_dlhe_fields_pkg.get_job_title
                 (p_hesa_method    => l_hesa_method,
                  p_hesa_empcir    => l_hesa_empcir,
                  p_dlhe_jobtitle  => g_he_stdnt_dlhe.Job_title,
                  p_hesa_jobtitle  => p_value);

      ELSIF  p_field_number = 11
      THEN
          -- Standard Occupational Classification
          igs_he_extract_dlhe_fields_pkg.get_occ_class
                 (p_hesa_method    => l_hesa_method,
                  p_hesa_empcir    => l_hesa_empcir,
                  p_dlhe_job_class => g_he_stdnt_dlhe.Job_classification,
                  p_hesa_soc       => p_value);

      ELSIF  p_field_number = 12
      THEN
          -- Employer size
          igs_he_extract_dlhe_fields_pkg.get_emp_size
                 (p_hesa_method    => l_hesa_method,
                  p_hesa_empcir    => l_hesa_empcir,
                  p_dlhe_emp_size  => g_he_stdnt_dlhe.Employer_size,
                  p_hesa_empsize   => p_value);

      ELSIF  p_field_number = 13
      THEN
          -- Duration of employment
          igs_he_extract_dlhe_fields_pkg.get_emp_duration
                 (p_hesa_method       => l_hesa_method,
                  p_hesa_empcir       => l_hesa_empcir,
                  p_dlhe_emp_duration => g_he_stdnt_dlhe.Job_duration,
                  p_hesa_duration     => p_value);

      ELSIF  p_field_number = 14
      THEN
          -- Salary
          igs_he_extract_dlhe_fields_pkg.get_salary
                 (p_hesa_method     => l_hesa_method,
                  p_hesa_empcir     => l_hesa_empcir,
                  p_dlhe_Job_salary => g_he_stdnt_dlhe.Job_salary,
                  p_hesa_salary     => p_value);
          -- smaddali added lpad for HECR11  build , bug#3051597
          p_value := LPAD(p_value,6,0) ;

      ELSIF  p_field_number = 15
      THEN
          -- Qualification required for job
          igs_he_extract_dlhe_fields_pkg.get_qual_req
                 (p_hesa_method    => l_hesa_method,
                  p_hesa_empcir    => l_hesa_empcir,
                  p_dlhe_qual_req  => g_he_stdnt_dlhe.Qualification_requirement,
                  p_hesa_qualreq   => p_value);

      ELSIF  p_field_number = 16
      THEN
          -- Importance to employer
          igs_he_extract_dlhe_fields_pkg.get_emp_imp
                 (p_hesa_method   => l_hesa_method,
                  p_hesa_empcir   => l_hesa_empcir,
                  p_dlhe_emp_imp  => g_he_stdnt_dlhe.Qualification_importance,
                  p_hesa_empimp   => p_value);

      ELSIF  p_field_number BETWEEN 17 AND 24
      THEN

              IF  ( l_hesa_method IN ('3','4','8','9') OR
                    l_hesa_empcir IN ('6','7','8','9','10','11','12','13','14','XX' ) OR
                    ( g_he_stdnt_dlhe.Job_reason1='N' AND  g_he_stdnt_dlhe.Job_reason2='N' AND
                      g_he_stdnt_dlhe.Job_reason3='N' AND g_he_stdnt_dlhe.Job_reason4='N' AND
                      g_he_stdnt_dlhe.Job_reason5='N' AND g_he_stdnt_dlhe.Job_reason6='N' AND
                      g_he_stdnt_dlhe.Job_reason7='N' AND g_he_stdnt_dlhe.Job_reason8='N' AND
                      g_he_stdnt_dlhe.Other_job_reason IS NULL AND  g_he_stdnt_dlhe.No_other_job_reason = 'N'
                    )
                  )  THEN
                      p_value := 'X' ;
              ELSIF  p_field_number = 17
              THEN
                   -- Career related code 1
                   igs_he_extract_dlhe_fields_pkg.get_career
                         (p_hesa_reason    => g_he_stdnt_dlhe.Job_reason1 ,
                          p_hesa_career    => p_value);
              ELSIF  p_field_number = 18
              THEN
                   -- Career related code 2
                   igs_he_extract_dlhe_fields_pkg.get_career
                         (p_hesa_reason    => g_he_stdnt_dlhe.Job_reason2 ,
                          p_hesa_career    => p_value);
              ELSIF  p_field_number = 19
              THEN
                  -- Career related code 3
                      igs_he_extract_dlhe_fields_pkg.get_career
                         (p_hesa_reason    => g_he_stdnt_dlhe.Job_reason3,
                          p_hesa_career    => p_value);
              ELSIF  p_field_number = 20
              THEN
                   -- Career related code 4
                      igs_he_extract_dlhe_fields_pkg.get_career
                         (p_hesa_reason    => g_he_stdnt_dlhe.Job_reason4 ,
                          p_hesa_career    => p_value);

              ELSIF  p_field_number = 21
              THEN
                  -- Career related code 5
                      igs_he_extract_dlhe_fields_pkg.get_career
                         (p_hesa_reason    => g_he_stdnt_dlhe.Job_reason5 ,
                          p_hesa_career    => p_value);

              ELSIF  p_field_number = 22
              THEN
                   -- Career related code 6
                      igs_he_extract_dlhe_fields_pkg.get_career
                         (p_hesa_reason    => g_he_stdnt_dlhe.Job_reason6 ,
                          p_hesa_career    => p_value);

              ELSIF  p_field_number = 23
              THEN
                   -- Career related code 7
                      igs_he_extract_dlhe_fields_pkg.get_career
                         (p_hesa_reason    => g_he_stdnt_dlhe.Job_reason7 ,
                          p_hesa_career    => p_value);

              ELSIF  p_field_number = 24
              THEN
                   -- Career related code 8
                      igs_he_extract_dlhe_fields_pkg.get_career
                         (p_hesa_reason    => g_he_stdnt_dlhe.Job_reason8 ,
                          p_hesa_career    => p_value);
              END IF; -- if default value condition is not satisfied


      ELSIF  p_field_number = 25
      THEN
          -- How found job
          igs_he_extract_dlhe_fields_pkg.get_job_find
                 (p_hesa_method     => l_hesa_method,
                  p_hesa_empcir     => l_hesa_empcir,
                  p_dlhe_job_source => g_he_stdnt_dlhe.Job_source,
                  p_hesa_jobfnd     => p_value);

      ELSIF  p_field_number = 26
      THEN
         -- Previously employed
         igs_he_extract_dlhe_fields_pkg.get_prev_emp
                 (p_hesa_method       => l_hesa_method,
                  p_hesa_empcir       => l_hesa_empcir,
                  p_dlhe_previous_job => g_he_stdnt_dlhe.Previous_job,
                  p_hesa_prevemp      => p_value);
         l_hesa_prevemp  := p_value ;

      ELSIF  p_field_number = 27
      THEN
          -- Category of previous employment 1
          igs_he_extract_dlhe_fields_pkg.get_prev_emp_cat
                 (p_hesa_method           => l_hesa_method,
                  p_hesa_empcir           => l_hesa_empcir,
                  p_hesa_prevemp          => l_hesa_prevemp,
                  p_dlhe_previous_jobtype => g_he_stdnt_dlhe.Previous_jobtype1,
                  p_hesa_prevcat          => p_value);

      ELSIF  p_field_number = 28
      THEN
          -- Category of previous employment 2
          igs_he_extract_dlhe_fields_pkg.get_prev_emp_cat
                 (p_hesa_method           => l_hesa_method,
                  p_hesa_empcir           => l_hesa_empcir,
                  p_hesa_prevemp          => l_hesa_prevemp,
                  p_dlhe_previous_jobtype => g_he_stdnt_dlhe.Previous_jobtype2,
                  p_hesa_prevcat          => p_value);

      ELSIF  p_field_number = 29
      THEN
           --  Category of previous employment 3
           igs_he_extract_dlhe_fields_pkg.get_prev_emp_cat
                 (p_hesa_method           => l_hesa_method,
                  p_hesa_empcir           => l_hesa_empcir,
                  p_hesa_prevemp          => l_hesa_prevemp,
                  p_dlhe_previous_jobtype => g_he_stdnt_dlhe.Previous_jobtype3,
                  p_hesa_prevcat          => p_value);

     ELSIF  p_field_number = 30
      THEN
          -- Category of previous employment 4
          igs_he_extract_dlhe_fields_pkg.get_prev_emp_cat
                 (p_hesa_method           => l_hesa_method,
                  p_hesa_empcir           => l_hesa_empcir,
                  p_hesa_prevemp          => l_hesa_prevemp,
                  p_dlhe_previous_jobtype => g_he_stdnt_dlhe.Previous_jobtype4,
                  p_hesa_prevcat          => p_value);

      ELSIF  p_field_number = 31
      THEN
          -- Category of previous employment 5
          igs_he_extract_dlhe_fields_pkg.get_prev_emp_cat
                 (p_hesa_method           => l_hesa_method,
                  p_hesa_empcir           => l_hesa_empcir,
                  p_hesa_prevemp          => l_hesa_prevemp,
                  p_dlhe_previous_jobtype => g_he_stdnt_dlhe.Previous_jobtype5,
                  p_hesa_prevcat          => p_value);

      ELSIF  p_field_number = 32
      THEN
           -- Category of previous employment 6
           igs_he_extract_dlhe_fields_pkg.get_prev_emp_cat
                 (p_hesa_method           => l_hesa_method,
                  p_hesa_empcir           => l_hesa_empcir,
                  p_hesa_prevemp          => l_hesa_prevemp,
                  p_dlhe_previous_jobtype => g_he_stdnt_dlhe.Previous_jobtype6,
                  p_hesa_prevcat          => p_value);

      ELSIF  p_field_number = 33
      THEN
          -- Nature of study/training
          igs_he_extract_dlhe_fields_pkg.get_nat_study
                 (p_hesa_method     => l_hesa_method,
                  p_hesa_modstudy   => l_hesa_modstudy,
                  p_dlhe_study_type => g_he_stdnt_dlhe.Further_study_type,
                  p_hesa_natstudy   => p_value);
          l_hesa_natstudy := p_value;

      ELSIF  p_field_number = 34
      THEN
          -- Professional subject of training
          igs_he_extract_dlhe_fields_pkg.get_train_subj
                 (p_hesa_method          => l_hesa_method,
                  p_hesa_modstudy        => l_hesa_modstudy,
                  p_hesa_natstudy        => l_hesa_natstudy,
                  p_dlhe_crse_train_subj => g_he_stdnt_dlhe.Course_training_subject,
                  p_dlhe_res_train_subj  => g_he_stdnt_dlhe.Research_training_subject,
                  p_hesa_profsoct        => p_value);

      ELSIF  p_field_number = 35
      THEN
          -- Institution providing study
          igs_he_extract_dlhe_fields_pkg.get_inst_prov
                 (p_hesa_method      => l_hesa_method,
                  p_hesa_modstudy    => l_hesa_modstudy,
                  p_hesa_natstudy    => l_hesa_natstudy,
                  p_dlhe_study_prov  => g_he_stdnt_dlhe.Further_study_provider,
                  p_hesa_instprov    => p_value);

      ELSIF  p_field_number = 36
      THEN
          -- Type of qualification
          -- smaddali removed parameter p_hesa_natstudy from the call for build HECR011 ,bug#3051597
          igs_he_extract_dlhe_fields_pkg.get_type_qual
                 (p_hesa_method         => l_hesa_method,
                  p_hesa_modstudy       => l_hesa_modstudy,
                  p_dlhe_study_qualaim  => g_he_stdnt_dlhe.Further_study_qualaim,
                  p_hesa_typequal       => p_value);

      ELSIF  p_field_number = 37
      THEN
          -- smaddali removed calculation of field 45 EMPPAID for build HECR011 ,bug#3051597
          -- smaddali removed parameter p_hesa_natstudy,p_hesa_emppaid from the call for build HECR011 ,bug#3051597
          -- Reason for taking another course 2
          igs_he_extract_dlhe_fields_pkg.get_study_reason2
                 (p_hesa_method        => l_hesa_method,
                  p_hesa_modstudy      => l_hesa_modstudy,
                  p_dlhe_study_reason  => g_he_stdnt_dlhe.Study_reason1,
                  p_hesa_secint        => p_value);

      ELSIF  p_field_number = 38
      THEN
          -- smaddali removed calculation of field 45 EMPPAID for build HECR011 ,bug#3051597
          -- smaddali removed parameter p_hesa_natstudy,p_hesa_emppaid from the call for build HECR011 ,bug#3051597
          -- Reason for taking another course 2
          igs_he_extract_dlhe_fields_pkg.get_study_reason2
                 (p_hesa_method        => l_hesa_method,
                  p_hesa_modstudy      => l_hesa_modstudy,
                  p_dlhe_study_reason  => g_he_stdnt_dlhe.Study_reason2,
                  p_hesa_secint        => p_value);

      ELSIF  p_field_number = 39
      THEN
          -- smaddali removed calculation of field 45 EMPPAID for build HECR011 ,bug#3051597
          -- smaddali removed parameter p_hesa_natstudy,p_hesa_emppaid from the call for build HECR011 ,bug#3051597
          -- Reason for taking another course 3
          igs_he_extract_dlhe_fields_pkg.get_study_reason2
                 (p_hesa_method        => l_hesa_method,
                  p_hesa_modstudy      => l_hesa_modstudy,
                  p_dlhe_study_reason  => g_he_stdnt_dlhe.Study_reason3,
                  p_hesa_secint        => p_value);

      ELSIF  p_field_number = 40
      THEN
          -- smaddali removed calculation of field 45 EMPPAID for build HECR011 ,bug#3051597
          -- smaddali removed parameter p_hesa_natstudy,p_hesa_emppaid from the call for build HECR011 ,bug#3051597
          -- Reason for taking another course 4
          igs_he_extract_dlhe_fields_pkg.get_study_reason2
                 (p_hesa_method        => l_hesa_method,
                  p_hesa_modstudy      => l_hesa_modstudy,
                  p_dlhe_study_reason  => g_he_stdnt_dlhe.Study_reason4,
                  p_hesa_secint        => p_value);

      ELSIF  p_field_number = 41
      THEN
          -- smaddali removed calculation of field 45 EMPPAID for build HECR011 ,bug#3051597
          -- smaddali removed parameter p_hesa_natstudy,p_hesa_emppaid from the call for build HECR011 ,bug#3051597
          -- Reason for taking another course 5
          igs_he_extract_dlhe_fields_pkg.get_study_reason2
                 (p_hesa_method        => l_hesa_method,
                  p_hesa_modstudy      => l_hesa_modstudy,
                  p_dlhe_study_reason  => g_he_stdnt_dlhe.Study_reason5,
                  p_hesa_secint        => p_value);

      ELSIF  p_field_number = 42
      THEN
          -- smaddali removed calculation of field 45 EMPPAID for build HECR011 ,bug#3051597
          -- smaddali removed parameter p_hesa_natstudy,p_hesa_emppaid from the call for build HECR011 ,bug#3051597
          -- Reason for taking another course 6
          igs_he_extract_dlhe_fields_pkg.get_study_reason2
                 (p_hesa_method         => l_hesa_method,
                  p_hesa_modstudy       => l_hesa_modstudy,
                  p_dlhe_study_reason   => g_he_stdnt_dlhe.Study_reason6,
                  p_hesa_secint         => p_value);

      ELSIF  p_field_number = 43
      THEN
          -- smaddali removed calculation of field 45 EMPPAID for build HECR011 ,bug#3051597
          -- smaddali removed parameter p_hesa_natstudy,p_hesa_emppaid from the call for build HECR011 ,bug#3051597
          -- Reason for taking another course 7
              igs_he_extract_dlhe_fields_pkg.get_study_reason2
                 (p_hesa_method        => l_hesa_method,
                  p_hesa_modstudy      => l_hesa_modstudy,
                  p_dlhe_study_reason  => g_he_stdnt_dlhe.Study_reason7,
                  p_hesa_secint        => p_value);

      ELSIF  p_field_number = 44
      THEN
          -- smaddali removed calculation of field 45 EMPPAID for build HECR011 ,bug#3051597
          -- smaddali removed parameter p_hesa_natstudy,p_hesa_emppaid from the call for build HECR011 ,bug#3051597
          -- Reason for taking another course 8
          igs_he_extract_dlhe_fields_pkg.get_study_reason8
                 (p_hesa_method             => l_hesa_method,
                  p_hesa_modstudy           => l_hesa_modstudy,
                  p_dlhe_other_study_reason => g_he_stdnt_dlhe.Other_study_reason,
                  p_dlhe_no_study_reason    => g_he_stdnt_dlhe.No_other_study_reason,
                  p_hesa_secint8            => p_value);

      ELSIF  p_field_number = 45
      THEN

         -- not used
         p_value := 'X';

      ELSIF  p_field_number = 46
      THEN
          -- smaddali removed parameter p_hesa_natstudy,p_hesa_emppaid from the call for build HECR011 ,bug#3051597
          -- How funding further study
          igs_he_extract_dlhe_fields_pkg.get_funding_source
                 (p_hesa_method          => l_hesa_method,
                  p_hesa_modstudy        => l_hesa_modstudy,
                  p_dlhe_funding_source  => g_he_stdnt_dlhe.Funding_source,
                  p_hesa_fundstudy       => p_value);

      ELSIF  p_field_number = 47
      THEN
          -- Teaching employment marker
          igs_he_extract_dlhe_fields_pkg.get_teaching_emp
                 (p_hesa_method     => l_hesa_method,
                  p_dlhe_qualified  => g_he_stdnt_dlhe.Qualified_teacher,
                  p_dlhe_teaching   => g_he_stdnt_dlhe.Teacher_teaching ,
                  p_dlhe_seeking    => g_he_stdnt_dlhe.Teacher_seeking ,
                  p_hesa_tchemp     => p_value);
          l_hesa_tchemp := p_value ;

      ELSIF  p_field_number = 48
      THEN
          -- Teaching sector
          igs_he_extract_dlhe_fields_pkg.get_teaching_sector
                 (p_hesa_method        => l_hesa_method,
                  p_hesa_tchemp        => l_hesa_tchemp,
                  p_dlhe_teach_sector  => g_he_stdnt_dlhe.Teaching_sector,
                  p_hesa_teachsct      => p_value);

      ELSIF  p_field_number = 49
      THEN
          -- Teaching phase
          igs_he_extract_dlhe_fields_pkg.get_teaching_phase
                 (p_hesa_method        => l_hesa_method,
                  p_hesa_tchemp        => l_hesa_tchemp,
                  p_dlhe_teach_level   => g_he_stdnt_dlhe.Teaching_level,
                  p_hesa_teachphs      => p_value);

      ELSIF  p_field_number = 50
      THEN
          -- Reason for taking original course
          igs_he_extract_dlhe_fields_pkg.get_intent
                 (p_hesa_method         => l_hesa_method,
                  p_dlhe_pt_study       => g_he_stdnt_dlhe.PT_Study,
                  p_dlhe_reason_ptcrse  => g_he_stdnt_dlhe.Reason_for_PTcourse,
                  p_hesa_intent         => p_value);

      ELSIF  p_field_number = 51
      THEN
          -- Employed during course
          igs_he_extract_dlhe_fields_pkg.get_job_while_study
                 (p_hesa_method           => l_hesa_method,
                  p_dlhe_pt_study         => g_he_stdnt_dlhe.PT_Study,
                  p_dlhe_job_while_study  => g_he_stdnt_dlhe.Job_while_studying,
                  p_hesa_empcrse          => p_value);
          l_hesa_empcrse := p_value ;

      ELSIF  p_field_number = 52
      THEN
          -- Employer sponsorship 1
          igs_he_extract_dlhe_fields_pkg.get_emp_sponsorship
                 (p_hesa_method       => l_hesa_method,
                  p_hesa_empcrse      => l_hesa_empcrse,
                  p_dlhe_pt_study     => g_he_stdnt_dlhe.PT_Study,
                  p_dlhe_emp_support  => g_he_stdnt_dlhe.Employer_support1,
                  p_hesa_empspns      => p_value);

      ELSIF  p_field_number = 53
      THEN
          -- Employer sponsorship 2
          igs_he_extract_dlhe_fields_pkg.get_emp_sponsorship
                 (p_hesa_method       => l_hesa_method,
                  p_hesa_empcrse      => l_hesa_empcrse,
                  p_dlhe_pt_study     => g_he_stdnt_dlhe.PT_Study,
                  p_dlhe_emp_support  => g_he_stdnt_dlhe.Employer_support2,
                  p_hesa_empspns      => p_value);

      ELSIF  p_field_number = 54
      THEN
          -- Employer sponsorship 3
          igs_he_extract_dlhe_fields_pkg.get_emp_sponsorship
                 (p_hesa_method       => l_hesa_method,
                  p_hesa_empcrse      => l_hesa_empcrse,
                  p_dlhe_pt_study     => g_he_stdnt_dlhe.PT_Study,
                  p_dlhe_emp_support  => g_he_stdnt_dlhe.Employer_support3,
                  p_hesa_empspns      => p_value);

      ELSIF  p_field_number = 55
      THEN
          -- Employer sponsorship 4
          igs_he_extract_dlhe_fields_pkg.get_emp_sponsorship
                 (p_hesa_method       => l_hesa_method,
                  p_hesa_empcrse      => l_hesa_empcrse,
                  p_dlhe_pt_study     => g_he_stdnt_dlhe.PT_Study,
                  p_dlhe_emp_support  => g_he_stdnt_dlhe.Employer_support4,
                  p_hesa_empspns      => p_value);

      ELSIF  p_field_number = 56
      THEN
          -- Employer sponsorship 5
          igs_he_extract_dlhe_fields_pkg.get_emp_sponsorship
                 (p_hesa_method       => l_hesa_method,
                  p_hesa_empcrse      => l_hesa_empcrse,
                  p_dlhe_pt_study     => g_he_stdnt_dlhe.PT_Study,
                  p_dlhe_emp_support  => g_he_stdnt_dlhe.Employer_support5,
                  p_hesa_empspns      => p_value);

      END IF; -- for each field from 1 to  56

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);
          fnd_message.set_name('IGS','IGS_HE_FIELD_NUM');
          fnd_message.set_token('field_number',p_field_number);
          IGS_GE_MSG_STACK.ADD;
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT2_PKG.process_dlhe_fields');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

   END process_dlhe_fields;


   /*----------------------------------------------------------------------
   This procedure processes each field to be submitted in the HESA return

   Parameters :
   p_extract_run_id         The Extract Run Id
   p_person_id              Person_id for the student
   p_course_cd              Course Code that the student is attempting
   p_crv_version_number     Version Number of the course code
   p_student_inst_number    Student Instance Number
   p_unit_cd              Unit Code
   p_uv_version_number      Unit Code Version Number
   p_line_number            Line Number of the current line being processed
   ----------------------------------------------------------------------*/
   PROCEDURE process_fields
             (p_extract_run_id         igs_he_ext_run_dtls.extract_run_id%TYPE,
              p_person_id              igs_he_ex_rn_dat_ln.person_id%TYPE,
              p_course_cd              igs_he_ex_rn_dat_ln.course_cd%TYPE,
              p_crv_version_number     igs_he_ex_rn_dat_ln.crv_version_number%TYPE,
              p_student_inst_number    igs_he_ex_rn_dat_ln.student_inst_number%TYPE,
              p_unit_cd                igs_he_ex_rn_dat_ln.unit_cd%TYPE,
              p_uv_version_number      igs_he_ex_rn_dat_ln.uv_version_number%TYPE,
              p_line_number            igs_he_ex_rn_dat_ln.line_number%TYPE)
   IS
   /***************************************************************
   Created By           :        Bidisha S
   Date Created By      :        28-Jan-02
   Purpose              :This procedure processes each field to be submitted in the HESA return
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who       When         What
   smaddali  09-Apr-03    modified procedure for HEFD203 build , bug 2717745
   jchakrab  05-Feb-05    Modified for 4006205 -
                          Replaced call to TBH insert_row() with direct DML
   sjlaport  31-May-05    Modified for 4304808 - Error message only created for mandatory
                          fields derived with null value. Removed check for included fields.
   jbaber    15-Mar-2006  Update recalculated fields for HE365 - Extract Rerun
  ***************************************************************/

   l_rowid          VARCHAR2(30);
   l_fld_seq        igs_he_ex_rn_dat_fd.rn_dat_fd_id%TYPE;
   l_index          NUMBER;
   l_value          igs_he_ex_rn_dat_fd.value%TYPE;

   l_last_update_date           DATE;
   l_last_updated_by            NUMBER;
   l_last_update_login          NUMBER;


   BEGIN
      -- Initialize l_index with the first element in the array
      -- This is cause, the user might not have selected all the
      -- fields to be calculated. Therefore we need to travel
      -- through the array stopping at only those Subscripts which
      -- have data in it.
      l_index  := g_field_defn.field_number.FIRST;

      --smaddali added this code to delete plsql tables hesa_value and oss_value so that they are initialized properly
      -- for bug 2417370
      g_field_defn.hesa_value.delete ;
      g_field_defn.oss_value.delete ;
      -- smaddali added code to initialize dlhe return variables, for HEFD203 build , bug#2717745
      l_hesa_method     := NULL;
      l_hesa_empcir     := NULL;
      l_hesa_modstudy   := NULL;
      l_hesa_natstudy   := NULL;
      l_hesa_empcrse    := NULL;
      l_hesa_prevemp    := NULL;
      l_hesa_tchemp     := NULL;

      --jchakrab - added for 4006205 - replace TBH insert_row() with direct DML call
      --set values for WHO columns for all fields
      l_last_update_date := SYSDATE;
      l_last_updated_by := NVL(fnd_global.user_id,-1);
      l_last_update_login := NVL(fnd_global.login_id,-1);

      -- Populate each field for the Student / Combined / Module record
      WHILE l_index IS NOT NULL
      LOOP
              -- Initialize variables.
              l_value := NULL;

              -- Check if constant value has been provided.
              -- We do not need to derive the field if a value has been given
              IF g_field_defn.constant_val(l_index) IS  NOT NULL
              THEN
                  -- Check if constant value should be NULL
                  IF g_field_defn.constant_val(l_index) = 'NULL' THEN
                      l_value := NULL;
                  ELSE
                      l_value := g_field_defn.constant_val(l_index);
                  END IF;
              ELSE
                  -- Constant value not specified, therefore derive the field value
                  -- Do the Combined Return Fields
                  IF Substr(g_he_submsn_return.record_id,4,2) = '11'
                  THEN
                      -- smaddali passing g_en_stdnt_ps_att.version_number instead of p_crv_version_number, for HECR214 build
                      -- the field derivations should use term version number instead of sca.version_number
                      process_comb_fields
                           (p_person_id           => p_person_id,
                            p_course_cd           => p_course_cd,
                            p_crv_version_number  => g_en_stdnt_ps_att.version_number,
                            p_student_inst_number => p_student_inst_number,
                            p_field_number        => g_field_defn.field_number(l_index) ,
                            p_value               => l_value);

                  -- Do the Student Return Fields
                  ELSIF Substr(g_he_submsn_return.record_id,4,2) = '12'
                  THEN
                      -- smaddali passing g_en_stdnt_ps_att.version_number instead of p_crv_version_number, for HECR214 build
                      -- the field derivations should use term version number instead of sca.version_number
                      process_stdnt_fields
                           (p_person_id           => p_person_id,
                            p_course_cd           => p_course_cd,
                            p_crv_version_number  => g_en_stdnt_ps_att.version_number,
                            p_student_inst_number => p_student_inst_number,
                            p_field_number        => g_field_defn.field_number(l_index) ,
                            p_value               => l_value);

                  -- Do the Module Return Fields
                  ELSIF Substr(g_he_submsn_return.record_id,4,2) = '13'
                  THEN
                      process_module_fields
                           (p_unit_cd             => p_unit_cd,
                            p_uv_version_number   => p_uv_version_number,
                            p_field_number        => g_field_defn.field_number(l_index) ,
                            p_value               => l_value);

                  -- Do the DLHE Return Fields
                  -- smaddali added processing for DLHE fields for bug#2717745 HEFD203 build
                  ELSIF Substr(g_he_submsn_return.record_id,4,2) = '18'
                  THEN
                      process_dlhe_fields
                           (p_person_id           => p_person_id,
                            p_field_number        => g_field_defn.field_number(l_index) ,
                            p_value               => l_value);

                  END IF; -- Module Return Fields

                  -- If calculated value was null then use the default value
                  IF l_value IS NULL
                  THEN
                          -- if default value processing validation is satisfied then use default value
                          IF g_default_pro = 'Y' THEN
                              l_value := g_field_defn.default_val(l_index);
                          END IF ;
                  END IF;

              END IF; -- Constant value has not been provided.


              -- If a mandatory field is derived as null with no constant or default value
              -- defined, record error
              IF l_value IS NULL AND g_field_defn.report_null_flag(l_index) = 'Y'
              THEN

                  -- Initialize Record to Null.
                  g_he_ext_run_except := NULL;

                  -- Populate the required fields.
                  g_he_ext_run_except.extract_run_id      := p_extract_run_id;
                  g_he_ext_run_except.exception_reason    := g_msg_ext_fld_val_null;
                  g_he_ext_run_except.person_id           := p_person_id;
                  g_he_ext_run_except.person_number       := g_pe_person.person_number;
                  g_he_ext_run_except.course_cd           := p_course_cd;
                  g_he_ext_run_except.crv_version_number  := p_crv_version_number;
                  g_he_ext_run_except.unit_cd             := p_unit_cd;
                  g_he_ext_run_except.uv_version_number   := p_uv_version_number;
                  g_he_ext_run_except.line_number         := p_line_number;
                  g_he_ext_run_except.field_number        := g_field_defn.field_number(l_index);

                  -- Call procedure to log error
                  log_error (g_he_ext_run_except);
              END IF; -- Field Value is NULL

              l_rowid := NULL;

              -- If field is being recalculated then we should update field rather than insert
              IF g_field_exists  THEN

                  UPDATE igs_he_ex_rn_dat_fd
                  SET value = l_value
                  WHERE extract_run_id = p_extract_run_id
                    AND line_number = p_line_number
                    AND field_number = g_field_defn.field_number(l_index);

              END IF;

              -- SQL%ROWCOUNT = 0 is for exceptional case where users have added a new field
              -- to the extract between runs. This is to be consistent with new lines that are appended
              -- which will pick up the new fields.
              IF NOT g_field_exists OR (SQL%ROWCOUNT = 0) THEN

                  --jchakrab - 4006205 - replace TBH with direct DML call
                  INSERT INTO igs_he_ex_rn_dat_fd (
                                rn_dat_fd_id,
                                extract_run_id,
                                line_number,
                                field_number,
                                value,
                                override_value,
                                creation_date,
                                created_by,
                                last_update_date,
                                last_updated_by,
                                last_update_login
                  ) VALUES (
                                IGS_HE_EX_RN_DAT_FD_S.NEXTVAL,
                                p_extract_run_id,
                                p_line_number,
                                g_field_defn.field_number(l_index),
                                l_value,
                                NULL,
                                l_last_update_date,
                                l_last_updated_by,
                                l_last_update_date,
                                l_last_updated_by,
                                l_last_update_login
                  );

              END IF;

          -- Store the value calculated into the array so that
          -- it can be used in calcualations of other fields.
          g_field_defn.hesa_value(l_index) := l_value;

          -- Get the next subscript for the array
          l_index := g_field_defn.field_number.NEXT(l_index);

          -- Continue with the next field.
      END LOOP; -- Loop for each field to be submitted.

   END process_fields;


   /*----------------------------------------------------------------------
   This function does the processing for a Student / Combined Return
   It will select all the required details and then call the individual
   procedures to derive the field values.

   Parameters :
   p_extract_run_id         The Extract Run Id
   p_person_id              Person_id for the student
   p_course_cd              Course Code that the student is attempting
   p_crv_version_number     Version Number of the course code
   p_student_inst_number    Student Instance Number
   p_line_number            Line Number of the current line being processed
   ----------------------------------------------------------------------*/
   FUNCTION  process_comb_stdnt_return
             (p_extract_run_id         igs_he_ext_run_dtls.extract_run_id%TYPE,
              p_person_id              igs_he_ex_rn_dat_ln.person_id%TYPE,
              p_course_cd              igs_he_ex_rn_dat_ln.course_cd%TYPE,
              p_crv_version_number     igs_he_ex_rn_dat_ln.crv_version_number%TYPE,
              p_student_inst_number    igs_he_ex_rn_dat_ln.student_inst_number%TYPE,
              p_line_number            igs_he_ex_rn_dat_ln.line_number%TYPE)
             RETURN BOOLEAN
 /***************************************************************
   Created By           :
   Date Created By      :
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who       When          What
   pkpatel   27-MAR-2003   Bug No: 2261717
                           These 2 columns are obsolete from igs_pe_person_v and here they are not being used for any processing.
                           Hence removed to avoid confusion.
   smaddali  3-dec-03      modified cursors c_yop to add condition complete_ind=Y , for HECR210 build, bug#2874542
   smaddali 10-dec-03      Modified logic to get Term record details for HECR214 - Term based fees enhancement, bug#3291656
   smaddali 14-jan-04      Modified logic not to stop processing student when igs_pe_stats record is not found : bug#3361317
   ayedubat 11-may-04      Modified the cursor, c_pe_stats to remove the effective dates comparision for Bug, 3614658
   jbaber   20-sep-04      Modified c_spa, c_pe_stats, c_yop, c_crse as per HE350 - Statutory Changes for 2004/05 Reporting
   jtmathew 23-dec-05      Modified c_spa, c_yop for HE309
   jchin    20-jan-06      Modified c_pe_stats and c_pers cursor queries for bug 4251011, 3717086 and 4250923
***************************************************************/
   IS
   -- smaddali selecting version_number for HECR214 build
   CURSOR c_spa IS
   SELECT sca.version_number,
          sca.cal_type,
          sca.location_cd ,
          sca.attendance_mode,
          sca.attendance_type,
          sca.coo_id ,
          sca.student_confirmed_ind,
          sca.commencement_dt ,
          sca.course_attempt_status,
          sca.progression_status ,
          sca.discontinued_dt,
          sca.discontinuation_reason_cd,
          sca.funding_source ,
          sca.exam_location_cd,
          sca.course_rqrmnt_complete_ind,
          sca.course_rqrmnts_complete_dt,
          sca.override_time_limitation,
          sca.advanced_standing_ind,
          sca.fee_cat,
          sca.adm_admission_appl_number,
          sca.adm_nominated_course_cd,
          sca.adm_sequence_number,
          hspa.fe_student_marker,
          hspa.domicile_cd,
          hspa.inst_last_attended,
          hspa.year_left_last_inst ,
          hspa.highest_qual_on_entry ,
          hspa.date_qual_on_entry_calc ,
          hspa.a_level_point_score,
          hspa.highers_points_scores ,
          hspa.occupation_code,
          hspa.commencement_dt,
          hspa.special_student,
          hspa.student_qual_aim,
          hspa.student_fe_qual_aim ,
          hspa.teacher_train_prog_id ,
          hspa.itt_phase,
          hspa.bilingual_itt_marker ,
          hspa.teaching_qual_gain_sector ,
          hspa.teaching_qual_gain_subj1,
          hspa.teaching_qual_gain_subj2,
          hspa.teaching_qual_gain_subj3,
          hspa.hesa_return_name,
          hspa.hesa_return_id,
          hspa.hesa_submission_name,
          hspa.associate_ucas_number,
          hspa.associate_scott_cand ,
          hspa.associate_teach_ref_num,
          hspa.associate_nhs_reg_num,
          hspa.itt_prog_outcome,
          hspa.nhs_funding_source ,
          hspa.ufi_place,
          hspa.postcode ,
          hspa.social_class_ind ,
          hspa.destination,
          hspa.occcode,
          hspa.total_ucas_tariff ,
          hspa.nhs_employer,
          hspa.return_type,
          hspa.student_inst_number,
          hspa.qual_aim_subj1 ,
          hspa.qual_aim_subj2 ,
          hspa.qual_aim_subj3 ,
          hspa.qual_aim_proportion,
          hspa.dependants_cd,
          hspa.enh_fund_elig_cd,
          hspa.implied_fund_rate,
          hspa.gov_initiatives_cd,
          hspa.units_completed,
          hspa.units_for_qual,
          hspa.disadv_uplift_elig_cd,
          hspa.disadv_uplift_factor,
          hspa.franch_out_arr_cd,
          hspa.employer_role_cd,
          hspa.franch_partner_cd,
          pst.course_type
   FROM   igs_en_stdnt_ps_att_all   sca,
          igs_he_st_spa_all         hspa,
          igs_ps_ver_all            psv,
          igs_ps_type_all           pst
   WHERE  sca.person_id          = p_person_id
   AND    sca.course_cd          = p_course_cd
   AND    sca.version_number     = p_crv_version_number
   AND    sca.person_id          = hspa.person_id
   AND    sca.course_cd          = hspa.course_cd
   AND    psv.course_cd          = p_course_cd
   AND    psv.version_number     = p_crv_version_number
   AND    psv.course_type        = pst.course_type;

   -- smaddali modified this cursor to remove join with igs_pe_stat_v for bug#3361317
   -- jchin - bug 4950293
   CURSOR c_pers  IS
     SELECT P.PARTY_NUMBER PERSON_NUMBER,
            P.PARTY_NAME PERSON_NAME,
            P.PERSON_LAST_NAME SURNAME,
            P.PERSON_FIRST_NAME GIVEN_NAMES,
            P.PERSON_MIDDLE_NAME MIDDLE_NAME,
            P.PERSON_TITLE TITLE,
            NVL (P.KNOWN_AS,
              SUBSTR (P.PERSON_FIRST_NAME, 1, DECODE (INSTR (P.PERSON_FIRST_NAME, ' '), 0, LENGTH (P.PERSON_FIRST_NAME),
              (INSTR (P.PERSON_FIRST_NAME, ' ') - 1))))
              || ' '
              || P.PERSON_LAST_NAME PREFERRED_NAME,
            P.KNOWN_AS PREFERRED_GIVEN_NAME,
            PP.GENDER SEX,
            PP.DATE_OF_BIRTH BIRTH_DT,
            PP.PERSON_NAME FULL_NAME
     FROM   HZ_PARTIES P,
            HZ_PERSON_PROFILES PP
     WHERE  P.PARTY_ID = PP.PARTY_ID
     AND    SYSDATE BETWEEN PP.EFFECTIVE_START_DATE
                   AND NVL (PP.EFFECTIVE_END_DATE, SYSDATE)
     AND    P.PARTY_ID = P_PERSON_ID;

   -- smaddali seperated this cursor from c_pers for bug#3361317
   -- jbaber modified for HEFD350 to include marital status
   -- jchin - modified for bug 4251011, 3717086
   CURSOR c_pe_stats(cp_enrl_start_dt      igs_he_submsn_header.enrolment_start_date%TYPE,
           cp_enrl_end_dt        igs_he_submsn_header.enrolment_end_date%TYPE) IS
   SELECT HPP.DECLARED_ETHNICITY ETHNIC_ORIGIN_ID,
          SD.RELIGION_CD RELIGION,
          HPP.MARITAL_STATUS MARITAL_STATUS
   FROM   HZ_PERSON_PROFILES HPP,
          IGS_PE_STAT_DETAILS SD
   WHERE  HPP.PARTY_ID = SD.PERSON_ID(+)
   AND    HPP.PARTY_ID = P_PERSON_ID
   AND    SYSDATE BETWEEN HPP.EFFECTIVE_START_DATE
   AND    NVL(HPP.EFFECTIVE_END_DATE, SYSDATE);

    --smaddali modified where clause for comparing the enrolment dates for bug 2415632
    -- smaddali 27-desc-2002 modified cursor to check for conferral date , bug 2702100
    -- smaddali 4-dec-03 modified cursor to remove igs_gr_graduand table and add conition complete_ind=Y, for HECR210 build
   CURSOR c_yop  (p_start_date          DATE,
                  p_end_date            DATE,
                  p_awd_conf_start_dt   DATE,
                  p_awd_conf_end_dt     DATE) IS
   SELECT DISTINCT susa.unit_set_cd,
          susa.us_version_number,
          susa.sequence_number,
          susa.selection_dt,
          susa.end_dt,
          susa.rqrmnts_complete_ind,
          susa.rqrmnts_complete_dt,
          husa.new_he_entrant_cd,
          husa.term_time_accom ,
          husa.disability_allow,
          husa.additional_sup_band,
          husa.sldd_discrete_prov,
          husa.study_mode,
          husa.study_location ,
          husa.fte_perc_override,
          husa.franchising_activity,
          husa.completion_status,
          husa.good_stand_marker,
          husa.complete_pyr_study_cd,
          husa.credit_value_yop1,
          husa.credit_value_yop2,
          husa.credit_value_yop3,
          husa.credit_value_yop4,
          husa.credit_level_achieved1,
          husa.credit_level_achieved2,
          husa.credit_level_achieved3,
          husa.credit_level_achieved4,
          husa.credit_pt_achieved1,
          husa.credit_pt_achieved2,
          husa.credit_pt_achieved3,
          husa.credit_pt_achieved4,
          husa.credit_level1,
          husa.credit_level2,
          husa.credit_level3,
          husa.credit_level4,
          husa.grad_sch_grade,
          husa.mark,
          husa.teaching_inst1,
          husa.teaching_inst2,
          husa.pro_not_taught,
          husa.fundability_code,
          husa.fee_eligibility,
          husa.fee_band,
          husa.non_payment_reason,
          husa.student_fee,
          husa.calculated_fte,
          husa.fte_intensity,
          husa.type_of_year,
          husa.year_stu,
          husa.enh_fund_elig_cd,
          husa.additional_sup_cost,
          husa.disadv_uplift_factor
   FROM  igs_as_su_setatmpt  susa,
         igs_he_en_susa      husa,
         igs_en_unit_set     us,
         igs_en_unit_set_cat susc,
         igs_en_spa_awd_aim enawd,
         igs_en_stdnt_ps_att_all   sca
   WHERE susa.person_id = sca.person_id
   AND   susa.course_cd = sca.course_cd
   AND    sca.person_id          = enawd.person_id(+)
   AND    sca.course_cd          = enawd.course_cd(+)
   AND    susa.person_id              = p_person_id
   AND   susa.course_cd              = p_course_cd
   AND   susa.unit_set_cd            = husa.unit_set_cd
   AND   susa.us_version_number      = husa.us_version_number
   AND   susa.person_id              = husa.person_id
   AND   susa.course_cd              = husa.course_cd
   AND   susa.sequence_number        = husa.sequence_number
   AND   susa.unit_set_cd            = us.unit_set_cd
   AND   susa.us_version_number      = us.version_number
   AND   us.unit_set_cat             = susc.unit_set_cat
   AND   susc.s_unit_set_cat         = 'PRENRL_YR'
   -- the program attempt is overlapping with the submission period and the yop is also overlapping with the submission period
   AND   ( (  sca.commencement_dt     <= p_end_date AND
             (sca.discontinued_dt  IS NULL OR  sca.discontinued_dt   >= p_start_date ) AND
             (sca.course_rqrmnts_complete_dt IS NULL OR  sca.course_rqrmnts_complete_dt >= p_start_date ) AND
              susa.selection_dt           <= p_end_date AND
             (susa.end_dt  IS NULL OR susa.end_dt   >= p_start_date )  AND
             (susa.rqrmnts_complete_dt IS NULL OR susa.rqrmnts_complete_dt >= p_start_date)
           )
           OR
              -- the yop has completed before the start of the submission period
              -- AND the program attempt has completed before the end of the submission period
              -- AND an award has been conferred between the NVL(award conferral dates, submission period)
           (  susa.rqrmnts_complete_dt < p_start_date AND
              sca.course_rqrmnts_complete_dt <= p_end_date AND
              enawd.complete_ind = 'Y' AND
              enawd.conferral_date BETWEEN p_awd_conf_start_dt AND p_awd_conf_end_dt
           )
         )
   ORDER BY susa.rqrmnts_complete_dt DESC, susa.end_dt DESC,  susa.selection_dt DESC;

   -- smaddali modified this cursor to select funding_source field from igs_he_poous for hefd208 - bug#2717751
   -- smaddali added version_number parameter for HECR214 build, we need to get the Term record program version details
   CURSOR c_crse (p_cal_type            igs_ps_ofr_opt.cal_type%TYPE,
                  p_attendance_mode     igs_ps_ofr_opt.attendance_mode%TYPE,
                  p_attendance_type     igs_ps_ofr_opt.attendance_type%TYPE,
                  p_location_cd         igs_ps_ofr_opt.location_cd%TYPE,
                  p_unit_set_cd         igs_he_poous_all.unit_set_cd%TYPE,
                  p_us_version_number   igs_he_poous_all.us_version_number%TYPE,
                  cp_crv_version_number igs_ps_ver_all.version_number%TYPE ) IS
   SELECT crv.title,
          crv.std_annual_load,
          pop.program_length,
          pop.program_length_measurement,
          crv.contact_hours,
          crv.govt_special_course_type,
          hpr.teacher_train_prog_id,
          hpr.itt_phase ,
          hpr.bilingual_itt_marker ,
          hpr.teaching_qual_sought_sector,
          hpr.teaching_qual_sought_subj1,
          hpr.teaching_qual_sought_subj2,
          hpr.teaching_qual_sought_subj3,
          hpr.location_of_study ,
          hpr.other_inst_prov_teaching1,
          hpr.other_inst_prov_teaching2,
          hpr.prop_teaching_in_welsh ,
          hpr.prop_not_taught,
          hpr.credit_transfer_scheme ,
          hpr.return_type,
          hpr.default_award,
          Nvl(hpr.program_calc,'N') ,
          hpr.level_applicable_to_funding,
          hpr.franchising_activity,
          hpr.nhs_funding_source,
          hpr.fe_program_marker,
          hpr.fee_band  ,
          hpr.fundability,
          hpr.implied_fund_rate,
          hpr.gov_initiatives_cd,
          hpr.units_for_qual,
          hpr.disadv_uplift_elig_cd,
          hpr.franch_out_arr_cd,
          hpud.location_of_study,
          hpud.mode_of_study,
          hpud.ufi_place ,
          hpud.franchising_activity,
          hpud.type_of_year,
          hpud.leng_current_year,
          hpud.grading_schema_cd,
          hpud.gs_version_number,
          hpud.credit_value_yop1,
          hpud.level_credit1    ,
          hpud.credit_value_yop2,
          hpud.level_credit2    ,
          hpud.credit_value_yop3,
          hpud.level_credit3    ,
          hpud.credit_value_yop4,
          hpud.level_credit4    ,
          hpud.fte_intensity  ,
          hpud.other_instit_teach1,
          hpud.other_instit_teach2,
          hpud.prop_not_taught,
          hpud.fundability_cd,
          hpud.fee_band,
          hpud.level_applicable_to_funding,
          hpud.funding_source
   FROM   igs_ps_ver       crv,
          igs_he_st_prog   hpr,
          igs_he_poous     hpud,
          igs_ps_ofr_opt pop
   WHERE  crv.course_cd             = hpr.course_cd
   AND    crv.version_number        = hpr.version_number
   AND    crv.course_cd             = p_course_cd
   AND    crv.version_number        = cp_crv_version_number
   AND    hpud.course_cd            = crv.course_cd
   AND    hpud.crv_version_number   = crv.version_number
   AND    hpud.cal_type             = p_cal_type
   AND    hpud.attendance_mode      = p_attendance_mode
   AND    hpud.attendance_type      = p_attendance_type
   AND    hpud.location_cd          = p_location_cd
   AND    hpud.unit_set_cd          = p_unit_set_cd
   AND    hpud.us_version_number    = p_us_version_number
   AND    pop.course_cd             = p_course_cd
   AND    pop.version_number        = cp_crv_version_number
   AND    pop.cal_type              = p_cal_type
   AND    pop.attendance_mode      = p_attendance_mode
   AND    pop.attendance_type      = p_attendance_type
   AND    pop.location_cd          = p_location_cd  ;

   CURSOR c_adm (p_admission_appl_number   igs_he_ad_dtl.admission_appl_number%TYPE,
                 p_nominated_course_cd     igs_he_ad_dtl.nominated_course_cd%TYPE ,
                 p_sequence_number         igs_he_ad_dtl.sequence_number%TYPE) IS
   SELECT had.occupation_cd,
          had.domicile_cd,
          had.social_class_cd ,
          had.special_student_cd
   FROM   igs_he_ad_dtl        had
   WHERE  had.person_id             = p_person_id
   AND    had.admission_appl_number = p_admission_appl_number
   AND    had.nominated_course_cd   = p_nominated_course_cd
   AND    had.sequence_number       = p_sequence_number;

   l_message              VARCHAR2(2000);

      -- smaddali added following cursors for HECR214 - term based fees enhancement build, bug#3291656

      -- Get the latest Term record for the Leavers,where the student left date lies between term start and end dates
      CURSOR c_term1_lev( cp_person_id  igs_en_spa_terms.person_id%TYPE,
                          cp_course_cd  igs_en_spa_terms.program_cd%TYPE,
                          cp_lev_dt  DATE ) IS
      SELECT  tr.program_version , tr.acad_cal_type, tr.location_cd, tr.attendance_mode, tr.attendance_type, tr.fee_cat
      FROM  igs_en_spa_terms tr , igs_ca_inst_all ca
      WHERE  tr.term_cal_type = ca.cal_type AND
             tr.term_sequence_number = ca.sequence_number AND
             tr.person_id = cp_person_id AND
             tr.program_cd = cp_course_cd AND
             cp_lev_dt BETWEEN ca.start_dt AND ca.end_dt
      ORDER BY  ca.start_dt DESC;
      c_term1_lev_rec   c_term1_lev%ROWTYPE ;

      -- Get the latest Term record for the Leavers just before the student left
      CURSOR c_term2_lev( cp_person_id          igs_en_spa_terms.person_id%TYPE,
                          cp_course_cd          igs_en_spa_terms.program_cd%TYPE,
                          cp_lev_dt             DATE,
                          cp_enrl_start_dt      igs_he_submsn_header.enrolment_start_date%TYPE,
                          cp_enrl_end_dt        igs_he_submsn_header.enrolment_end_date%TYPE ) IS
      SELECT  tr.program_version , tr.acad_cal_type, tr.location_cd, tr.attendance_mode, tr.attendance_type , tr.fee_cat
      FROM  igs_en_spa_terms tr , igs_ca_inst_all ca
      WHERE  tr.term_cal_type = ca.cal_type AND
             tr.term_sequence_number = ca.sequence_number AND
             tr.person_id = cp_person_id AND
             tr.program_cd = cp_course_cd AND
             cp_lev_dt > ca.start_dt AND
             ca.start_dt BETWEEN cp_enrl_start_dt AND cp_enrl_end_dt
      ORDER BY  ca.start_dt DESC;
      c_term2_lev_rec    c_term2_lev%ROWTYPE ;

      -- Get the latest term record for the Continuing students, where the term start date lies in the HESA submission period
      CURSOR c_term_con ( cp_person_id          igs_en_spa_terms.person_id%TYPE,
                          cp_course_cd          igs_en_spa_terms.program_cd%TYPE,
                          cp_enrl_start_dt      igs_he_submsn_header.enrolment_start_date%TYPE,
                          cp_enrl_end_dt        igs_he_submsn_header.enrolment_end_date%TYPE ) IS
      SELECT  tr.program_version , tr.acad_cal_type, tr.location_cd, tr.attendance_mode, tr.attendance_type, tr.fee_cat
      FROM  igs_en_spa_terms tr , igs_ca_inst_all ca
      WHERE  tr.term_cal_type = ca.cal_type AND
             tr.term_sequence_number = ca.sequence_number AND
             tr.person_id = cp_person_id AND
             tr.program_cd = cp_course_cd AND
             ca.start_dt BETWEEN cp_enrl_start_dt AND cp_enrl_end_dt
      ORDER BY  ca.start_dt DESC;
      c_term_con_rec    c_term_con%ROWTYPE ;
      l_lev_dt   igs_en_stdnt_ps_att_all.discontinued_dt%TYPE ;

      -- smaddali added cursor for bug#3361317
      CURSOR c_pers_number ( cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
      SELECT party_number person_number
      FROM hz_parties
      WHERE party_id = cp_person_id ;
      l_person_number igs_pe_Person_base_v.person_number%TYPE;

   BEGIN

      -- Fetch the Person Details
      g_pe_person       := NULL;
      -- smaddali seperated person statistics details from person details cursor c_pers for bug#3361317
      OPEN c_pers ;
      FETCH c_pers INTO g_pe_person.person_number,
                        g_pe_person.person_name,
                        g_pe_person.surname  ,
                        g_pe_person.given_names,
                        g_pe_person.middle_name,
                        g_pe_person.title  ,
                        g_pe_person.preferred_name,
                        g_pe_person.preferred_given_name,
                        g_pe_person.sex,
                        g_pe_person.birth_dt ,
                        g_pe_person.full_name ;
      IF c_pers%NOTFOUND
      THEN
          Fnd_Message.Set_Name('IGS', 'IGS_HE_EXT_PSN_NOT_FOUND');
          l_message := Fnd_Message.Get;

          -- Initialize Record to Null.
          g_he_ext_run_except := NULL;

          -- smaddali added code to derive person number to be shown in the exception report, bug#3361317
          l_person_number := NULL;
          OPEN c_pers_number(p_person_id );
          FETCH c_pers_number INTO l_person_number;
          CLOSE c_pers_number ;

          -- Populate the required fields.
          g_he_ext_run_except.extract_run_id      := p_extract_run_id;
          g_he_ext_run_except.exception_reason    := l_message;
          g_he_ext_run_except.person_id           := p_person_id;
          g_he_ext_run_except.person_number       := l_person_number;
          g_he_ext_run_except.course_cd           := p_course_cd;
          g_he_ext_run_except.crv_version_number  := p_crv_version_number;

          -- Call procedure to log error
          log_error (g_he_ext_run_except);

         -- Dont process this student any further
         CLOSE c_pers;
         RETURN FALSE;
      END IF;

      CLOSE c_pers;

      -- Fetch the Person statistics Details
      -- jbaber modified to include marital status for HEFD350
      g_pe_stat_v       := NULL;
      OPEN c_pe_stats(g_he_submsn_header.enrolment_start_date,
                  g_he_submsn_header.enrolment_end_date);
      FETCH c_pe_stats INTO g_pe_stat_v.ethnic_origin_id,
                        g_pe_stat_v.religion, g_pe_stat_v.marital_status;
      CLOSE c_pe_stats;

      -- Fetch the Student Program Attempt Details
      g_en_stdnt_ps_att := NULL ;
      g_he_st_spa       := NULL;
      g_ps_type         := NULL ;
      OPEN   c_spa;
      FETCH c_spa INTO g_en_stdnt_ps_att.version_number,
                      g_en_stdnt_ps_att.cal_type,
                      g_en_stdnt_ps_att.location_cd ,
                      g_en_stdnt_ps_att.attendance_mode,
                      g_en_stdnt_ps_att.attendance_type,
                      g_en_stdnt_ps_att.coo_id ,
                      g_en_stdnt_ps_att.student_confirmed_ind,
                      g_en_stdnt_ps_att.commencement_dt ,
                      g_en_stdnt_ps_att.course_attempt_status,
                      g_en_stdnt_ps_att.progression_status ,
                      g_en_stdnt_ps_att.discontinued_dt,
                      g_en_stdnt_ps_att.discontinuation_reason_cd,
                      g_en_stdnt_ps_att.funding_source ,
                      g_en_stdnt_ps_att.exam_location_cd,
                      g_en_stdnt_ps_att.course_rqrmnt_complete_ind,
                      g_en_stdnt_ps_att.course_rqrmnts_complete_dt,
                      g_en_stdnt_ps_att.override_time_limitation,
                      g_en_stdnt_ps_att.advanced_standing_ind,
                      g_en_stdnt_ps_att.fee_cat,
                      g_en_stdnt_ps_att.adm_admission_appl_number,
                      g_en_stdnt_ps_att.adm_nominated_course_cd,
                      g_en_stdnt_ps_att.adm_sequence_number,
                      g_he_st_spa.fe_student_marker,
                      g_he_st_spa.domicile_cd,
                      g_he_st_spa.inst_last_attended,
                      g_he_st_spa.year_left_last_inst ,
                      g_he_st_spa.highest_qual_on_entry ,
                      g_he_st_spa.date_qual_on_entry_calc ,
                      g_he_st_spa.a_level_point_score,
                      g_he_st_spa.highers_points_scores ,
                      g_he_st_spa.occupation_code,
                      g_he_st_spa.commencement_dt,
                      g_he_st_spa.special_student,
                      g_he_st_spa.student_qual_aim,
                      g_he_st_spa.student_fe_qual_aim ,
                      g_he_st_spa.teacher_train_prog_id ,
                      g_he_st_spa.itt_phase,
                      g_he_st_spa.bilingual_itt_marker ,
                      g_he_st_spa.teaching_qual_gain_sector ,
                      g_he_st_spa.teaching_qual_gain_subj1,
                      g_he_st_spa.teaching_qual_gain_subj2,
                      g_he_st_spa.teaching_qual_gain_subj3,
                      g_he_st_spa.hesa_return_name,
                      g_he_st_spa.hesa_return_id,
                      g_he_st_spa.hesa_submission_name,
                      g_he_st_spa.associate_ucas_number,
                      g_he_st_spa.associate_scott_cand ,
                      g_he_st_spa.associate_teach_ref_num,
                      g_he_st_spa.associate_nhs_reg_num,
                      g_he_st_spa.itt_prog_outcome,
                      g_he_st_spa.nhs_funding_source ,
                      g_he_st_spa.ufi_place,
                      g_he_st_spa.postcode ,
                      g_he_st_spa.social_class_ind ,
                      g_he_st_spa.destination,
                      g_he_st_spa.occcode,
                      g_he_st_spa.total_ucas_tariff ,
                      g_he_st_spa.nhs_employer,
                      g_he_st_spa.return_type,
                      g_he_st_spa.student_inst_number,
                      g_he_st_spa.qual_aim_subj1,
                      g_he_st_spa.qual_aim_subj2,
                      g_he_st_spa.qual_aim_subj3,
                      g_he_st_spa.qual_aim_proportion,
                      g_he_st_spa.dependants_cd,
                      g_he_st_spa.enh_fund_elig_cd,
                      g_he_st_spa.implied_fund_rate,
                      g_he_st_spa.gov_initiatives_cd,
                      g_he_st_spa.units_completed,
                      g_he_st_spa.units_for_qual,
                      g_he_st_spa.disadv_uplift_elig_cd,
                      g_he_st_spa.disadv_uplift_factor,
                      g_he_st_spa.franch_out_arr_cd,
                      g_he_st_spa.employer_role_cd,
                      g_he_st_spa.franch_partner_cd,
                      g_ps_type.course_type;

      IF c_spa%NOTFOUND
      THEN
          -- If SPA details were not found, then log error
          Fnd_Message.Set_Name('IGS', 'IGS_HE_EXT_SPA_DTL_NOT_FOUND');
          l_message := Fnd_Message.Get;

          -- Initialize Record to Null.
          g_he_ext_run_except := NULL;

          -- Populate the required fields.
          g_he_ext_run_except.extract_run_id      := p_extract_run_id;
          g_he_ext_run_except.exception_reason    := l_message;
          g_he_ext_run_except.person_id           := p_person_id;
          g_he_ext_run_except.course_cd           := p_course_cd;
          g_he_ext_run_except.crv_version_number  := p_crv_version_number;
          g_he_ext_run_except.person_number       := g_pe_person.person_number;

          -- Call procedure to log error
          log_error (g_he_ext_run_except);

         -- Dont process this student any further
         CLOSE c_spa;
         RETURN FALSE;
      END IF; -- SPA record not found

      CLOSE c_spa;


        -- smaddali added following code for HECR214 - term based fees enhancement build , Bug#3291656
        -- to get version_number,cal_type,location_cd, attendance_type and mode from the Term record
        -- Get the Leaving date for the student
        l_lev_dt     := NULL;
        l_lev_dt       := NVL(g_en_stdnt_ps_att.course_rqrmnts_complete_dt,g_en_stdnt_ps_att.discontinued_dt) ;

        -- If the student is a leaver(i.e leaving date falls within the HESA Submission period)
        -- then get the latest term rec where the leaving date falls within the term calendar start and end dates
        IF  l_lev_dt BETWEEN g_he_submsn_header.enrolment_start_date AND g_he_submsn_header.enrolment_end_date THEN
                 -- get the latest term record within which the Leaving date falls
                 c_term1_lev_rec        := NULL ;
                 OPEN c_term1_lev (p_person_id, p_course_cd, l_lev_dt );
                 FETCH c_term1_lev INTO c_term1_lev_rec ;
                 IF c_term1_lev%NOTFOUND THEN
                     -- Get the latest term record just before the Leaving date
                     c_term2_lev_rec    := NULL ;
                     OPEN c_term2_lev(p_person_id, p_course_cd, l_lev_dt,g_he_submsn_header.enrolment_start_date,
                   g_he_submsn_header.enrolment_end_date ) ;
                     FETCH c_term2_lev INTO c_term2_lev_rec ;
                     IF  c_term2_lev%FOUND THEN
                             -- Override the location_cd,cal_type,version_number,attendance_type,attendance_mode
                             -- in the SCA record with the term record values
                             g_en_stdnt_ps_att.version_number       := c_term2_lev_rec.program_version ;
                             g_en_stdnt_ps_att.cal_type             := c_term2_lev_rec.acad_cal_type ;
                             g_en_stdnt_ps_att.location_cd          := c_term2_lev_rec.location_cd ;
                             g_en_stdnt_ps_att.attendance_mode      := c_term2_lev_rec.attendance_mode ;
                             g_en_stdnt_ps_att.attendance_type      := c_term2_lev_rec.attendance_type ;
                             g_en_stdnt_ps_att.fee_cat              := c_term2_lev_rec.fee_cat ;
                     END IF ;
                     CLOSE c_term2_lev ;
                 ELSE
                             -- Override the location_cd,cal_type,version_number,attendance_type,attendance_mode
                             -- in the SCA record with the term record values
                             g_en_stdnt_ps_att.version_number       := c_term1_lev_rec.program_version ;
                             g_en_stdnt_ps_att.cal_type             := c_term1_lev_rec.acad_cal_type ;
                             g_en_stdnt_ps_att.location_cd          := c_term1_lev_rec.location_cd ;
                             g_en_stdnt_ps_att.attendance_mode      := c_term1_lev_rec.attendance_mode ;
                             g_en_stdnt_ps_att.attendance_type      := c_term1_lev_rec.attendance_type ;
                             g_en_stdnt_ps_att.fee_cat              := c_term1_lev_rec.fee_cat ;
                 END IF ;
                 CLOSE c_term1_lev ;

        -- Else the student is continuing student then get the latest term rec
        -- where the Term start date falls within the HESA Submission start and end dates
        ELSE
                -- Get the latest term record which falls within the FTE period and term start date > commencement dt
                c_term_con_rec  := NULL ;
                OPEN c_term_con(p_person_id, p_course_cd, g_he_submsn_header.enrolment_start_date,
                   g_he_submsn_header.enrolment_end_date );
                FETCH c_term_con INTO c_term_con_rec ;
                IF c_term_con%FOUND THEN
                     -- Override the location_cd,cal_type,version_number,attendance_type,attendance_mode
                     -- in the SCA record with the term record values
                     g_en_stdnt_ps_att.version_number       := c_term_con_rec.program_version ;
                     g_en_stdnt_ps_att.cal_type             := c_term_con_rec.acad_cal_type ;
                     g_en_stdnt_ps_att.location_cd          := c_term_con_rec.location_cd ;
                     g_en_stdnt_ps_att.attendance_mode      := c_term_con_rec.attendance_mode ;
                     g_en_stdnt_ps_att.attendance_type      := c_term_con_rec.attendance_type ;
                     g_en_stdnt_ps_att.fee_cat              := c_term_con_rec.fee_cat ;
                END IF ;
                CLOSE c_term_con ;
        END IF ; -- if student is leaving / continuing

      -- Get Award Conferral Dates
      igs_he_extract_fields_pkg.get_awd_conferral_dates
                           (g_awd_table,
                            g_he_ext_run_dtls.submission_name,
                            g_prog_rec_flag,
                            g_prog_type_rec_flag,
                            p_course_cd,
                            g_ps_type.course_type,
                            g_he_submsn_header.enrolment_start_date,
                            g_he_submsn_header.enrolment_end_date,
                            l_awd_conf_start_dt,
                            l_awd_conf_end_dt);

      -- Get Year of Program Details
      g_as_su_setatmpt  := NULL;
      g_he_en_susa      := NULL;
      OPEN  c_yop (g_he_submsn_header.enrolment_start_date,
                   g_he_submsn_header.enrolment_end_date,
                   l_awd_conf_start_dt,
                   l_awd_conf_end_dt);
      FETCH c_yop INTO g_as_su_setatmpt.unit_set_cd,
                       g_as_su_setatmpt.us_version_number,
                       g_as_su_setatmpt.sequence_number,
                       g_as_su_setatmpt.selection_dt,
                       g_as_su_setatmpt.end_dt,
                       g_as_su_setatmpt.rqrmnts_complete_ind,
                       g_as_su_setatmpt.rqrmnts_complete_dt,
                       g_he_en_susa.new_he_entrant_cd,
                       g_he_en_susa.term_time_accom ,
                       g_he_en_susa.disability_allow,
                       g_he_en_susa.additional_sup_band,
                       g_he_en_susa.sldd_discrete_prov,
                       g_he_en_susa.study_mode,
                       g_he_en_susa.study_location ,
                       g_he_en_susa.fte_perc_override,
                       g_he_en_susa.franchising_activity,
                       g_he_en_susa.completion_status,
                       g_he_en_susa.good_stand_marker,
                       g_he_en_susa.complete_pyr_study_cd,
                       g_he_en_susa.credit_value_yop1,
                       g_he_en_susa.credit_value_yop2,
                       g_he_en_susa.credit_value_yop3,
                       g_he_en_susa.credit_value_yop4,
                       g_he_en_susa.credit_level_achieved1,
                       g_he_en_susa.credit_level_achieved2,
                       g_he_en_susa.credit_level_achieved3,
                       g_he_en_susa.credit_level_achieved4,
                       g_he_en_susa.credit_pt_achieved1,
                       g_he_en_susa.credit_pt_achieved2,
                       g_he_en_susa.credit_pt_achieved3,
                       g_he_en_susa.credit_pt_achieved4,
                       g_he_en_susa.credit_level1,
                       g_he_en_susa.credit_level2,
                       g_he_en_susa.credit_level3,
                       g_he_en_susa.credit_level4,
                       g_he_en_susa.grad_sch_grade,
                       g_he_en_susa.mark,
                       g_he_en_susa.teaching_inst1,
                       g_he_en_susa.teaching_inst2,
                       g_he_en_susa.pro_not_taught,
                       g_he_en_susa.fundability_code,
                       g_he_en_susa.fee_eligibility,
                       g_he_en_susa.fee_band,
                       g_he_en_susa.non_payment_reason,
                       g_he_en_susa.student_fee,
                       g_he_en_susa.calculated_fte,
                       g_he_en_susa.fte_intensity,
                       g_he_en_susa.type_of_year,
                       g_he_en_susa.year_stu,
                       g_he_en_susa.enh_fund_elig_cd,
                       g_he_en_susa.additional_sup_cost,
                       g_he_en_susa.disadv_uplift_factor;

      IF c_yop%NOTFOUND
      THEN
          -- If Year of Program details were not found, then log error
          Fnd_Message.Set_Name('IGS', 'IGS_HE_EXT_YOP_NOT_FOUND');
          l_message := Fnd_Message.Get;

          -- Initialize Record to Null.
          g_he_ext_run_except := NULL;

          -- Populate the required fields.
          g_he_ext_run_except.extract_run_id      := p_extract_run_id;
          g_he_ext_run_except.exception_reason    := l_message;
          g_he_ext_run_except.person_id           := p_person_id;
          g_he_ext_run_except.course_cd           := p_course_cd;
          g_he_ext_run_except.crv_version_number  := p_crv_version_number;
          g_he_ext_run_except.person_number       := g_pe_person.person_number;

          -- Call procedure to log error
          log_error (g_he_ext_run_except);

         -- Dont process this student any further
         CLOSE c_yop;
         RETURN FALSE;
      END IF; -- YOP record not found

      CLOSE c_yop;

      g_ps_ver          := NULL;
      g_ps_ofr_opt      := NULL;
      g_he_st_prog      := NULL;
      g_he_poous        := NULL;
      -- smaddali passing g_en_stdnt_ps_att.version_number instead of p_crv_version_number, for HECR214 build
      OPEN c_crse (g_en_stdnt_ps_att.cal_type,
                   g_en_stdnt_ps_att.attendance_mode,
                   g_en_stdnt_ps_att.attendance_type,
                   g_en_stdnt_ps_att.location_cd,
                   g_as_su_setatmpt.unit_set_cd,
                   g_as_su_setatmpt.us_version_number,
                   g_en_stdnt_ps_att.version_number);
     -- smaddali modified this cursor to select funding_source field from igs_he_poous for hefd208 - bug#2717751
      FETCH c_crse INTO g_ps_ver.title,
                        g_ps_ver.std_annual_load,
                        g_ps_ofr_opt.program_length,
                        g_ps_ofr_opt.program_length_measurement,
                        g_ps_ver.contact_hours,
                        g_ps_ver.govt_special_course_type,
                        g_he_st_prog.teacher_train_prog_id,
                        g_he_st_prog.itt_phase ,
                        g_he_st_prog.bilingual_itt_marker ,
                        g_he_st_prog.teaching_qual_sought_sector,
                        g_he_st_prog.teaching_qual_sought_subj1,
                        g_he_st_prog.teaching_qual_sought_subj2,
                        g_he_st_prog.teaching_qual_sought_subj3,
                        g_he_st_prog.location_of_study ,
                        g_he_st_prog.other_inst_prov_teaching1,
                        g_he_st_prog.other_inst_prov_teaching2,
                        g_he_st_prog.prop_teaching_in_welsh ,
                        g_he_st_prog.prop_not_taught,
                        g_he_st_prog.credit_transfer_scheme ,
                        g_he_st_prog.return_type,
                        g_he_st_prog.default_award,
                        g_he_st_prog.program_calc ,
                        g_he_st_prog.level_applicable_to_funding,
                        g_he_st_prog.franchising_activity,
                        g_he_st_prog.nhs_funding_source,
                        g_he_st_prog.fe_program_marker,
                        g_he_st_prog.fee_band  ,
                        g_he_st_prog.fundability,
                        g_he_st_prog.implied_fund_rate,
                        g_he_st_prog.gov_initiatives_cd,
                        g_he_st_prog.units_for_qual,
                        g_he_st_prog.disadv_uplift_elig_cd,
                        g_he_st_prog.franch_out_arr_cd,
                        g_he_poous.location_of_study,
                        g_he_poous.mode_of_study,
                        g_he_poous.ufi_place ,
                        g_he_poous.franchising_activity,
                        g_he_poous.type_of_year,
                        g_he_poous.leng_current_year,
                        g_he_poous.grading_schema_cd,
                        g_he_poous.gs_version_number,
                        g_he_poous.credit_value_yop1,
                        g_he_poous.level_credit1    ,
                        g_he_poous.credit_value_yop2,
                        g_he_poous.level_credit2    ,
                        g_he_poous.credit_value_yop3,
                        g_he_poous.level_credit3    ,
                        g_he_poous.credit_value_yop4,
                        g_he_poous.level_credit4    ,
                        g_he_poous.fte_intensity  ,
                        g_he_poous.other_instit_teach1,
                        g_he_poous.other_instit_teach2,
                        g_he_poous.prop_not_taught,
                        g_he_poous.fundability_cd,
                        g_he_poous.fee_band,
                        g_he_poous.level_applicable_to_funding,
                        g_he_poous.funding_source ;

      IF c_crse%NOTFOUND
      THEN
          -- If Course details were not found, then log error
          Fnd_Message.Set_Name('IGS', 'IGS_HE_EXT_CRSE_DTL_NOT_FOUND');
          l_message := Fnd_Message.Get;

          -- Initialize Record to Null.
          g_he_ext_run_except := NULL;

          -- Populate the required fields.
          g_he_ext_run_except.extract_run_id      := p_extract_run_id;
          g_he_ext_run_except.exception_reason    := l_message;
          g_he_ext_run_except.person_id           := p_person_id;
          g_he_ext_run_except.course_cd           := p_course_cd;
          g_he_ext_run_except.crv_version_number  := p_crv_version_number;
          g_he_ext_run_except.person_number       := g_pe_person.person_number;

          -- Call procedure to log error
          log_error (g_he_ext_run_except);

         -- Dont process this student any further
         CLOSE c_crse;
         RETURN FALSE;
      END IF; -- Crse record not found

      CLOSE c_crse;

      --smaddali added this code to initialize cursor variable for bug 2417370
      g_he_ad_dtl := NULL ;
      OPEN  c_adm (g_en_stdnt_ps_att.adm_admission_appl_number,
                  g_en_stdnt_ps_att.adm_nominated_course_cd,
                  g_en_stdnt_ps_att.adm_sequence_number);
      FETCH c_adm INTO g_he_ad_dtl.occupation_cd,
                       g_he_ad_dtl.domicile_cd,
                       g_he_ad_dtl.social_class_cd ,
                       g_he_ad_dtl.special_student_cd;
      CLOSE c_adm;

      process_fields
             (p_extract_run_id         => p_extract_run_id,
              p_person_id              => p_person_id,
              p_course_cd              => p_course_cd,
              p_crv_version_number     => p_crv_version_number,
              p_student_inst_number    => p_student_inst_number,
              p_unit_cd                => NULL,
              p_uv_version_number      => NULL,
              p_line_number            => p_line_number);

      RETURN TRUE;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);
          -- Close Cursors
          IF c_pers%ISOPEN
          THEN
              CLOSE c_pers;
          END IF;

          IF c_spa%ISOPEN
          THEN
              CLOSE c_spa;
          END IF;

          IF c_yop%ISOPEN
          THEN
              CLOSE c_yop;
          END IF;

          IF c_adm%ISOPEN
          THEN
              CLOSE c_adm;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME',
                                'IGS_HE_EXTRACT2_PKG.process_comb_stdnt_return');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END process_comb_stdnt_return;


   /*----------------------------------------------------------------------
   This function does the processing for a Module Return
   It will select all the required details and then call the individual
   procedures to derive the field values.

   Parameters :
   p_extract_run_id         The Extract Run Id
   p_unit_cd                Unit Code
   p_uv_version_number      Version Number of the Unit Code
   p_line_number            Line Number of the current line being processed
   ----------------------------------------------------------------------*/
   FUNCTION process_module_return
             (p_extract_run_id      igs_he_ext_run_dtls.extract_run_id%TYPE,
              p_unit_cd             igs_he_ex_rn_dat_ln.unit_cd%TYPE,
              p_uv_version_number   igs_he_ex_rn_dat_ln.uv_version_number%TYPE,
              p_line_number         igs_he_ex_rn_dat_ln.line_number%TYPE)
             RETURN BOOLEAN
   IS
   --smaddali modified the order of columns because they donot match that of the Fetch statement bug 2417454
   CURSOR c_moddtl IS
   SELECT a.prop_of_teaching_in_welsh ,
          a.credit_transfer_scheme ,
          a.module_length ,
          a.proportion_of_fte,
          a.location_cd ,
          b.title,
          b.enrolled_credit_points,
          b.unit_level
   FROM   igs_he_st_unt_vs  a,
          igs_ps_unit_ver_v b
   WHERE  a.unit_cd = b.unit_cd
   AND    a.version_number = b.version_number
   AND    a.unit_cd        = p_unit_cd
   AND    a.version_number = p_uv_version_number;

   l_message               VARCHAR2(2000);

   BEGIN

      -- Get the Unit Details
      g_he_st_unt_vs    := NULL;
      g_ps_unit_ver_v   := NULL;
      OPEN c_moddtl;
      FETCH c_moddtl INTO g_he_st_unt_vs.prop_of_teaching_in_welsh ,
                          g_he_st_unt_vs.credit_transfer_scheme ,
                          g_he_st_unt_vs.module_length ,
                          g_he_st_unt_vs.proportion_of_fte,
                          g_he_st_unt_vs.location_cd,
                          g_ps_unit_ver_v.title,
                          g_ps_unit_ver_v.enrolled_credit_points,
                          g_ps_unit_ver_v.unit_level;

      IF c_moddtl%NOTFOUND
      THEN
          -- If Module details were not found, then log error
          Fnd_Message.Set_Name('IGS', 'IGS_HE_EXT_MOD_DTL_NOT_FOUND');
          l_message := Fnd_Message.Get;

          -- Initialize Record to Null.
          g_he_ext_run_except := NULL;

          -- Populate the required fields.
          g_he_ext_run_except.extract_run_id      := p_extract_run_id;
          g_he_ext_run_except.exception_reason    := l_message;
          g_he_ext_run_except.person_id           := NULL;
          g_he_ext_run_except.course_cd           := NULL;
          g_he_ext_run_except.crv_version_number  := NULL;
          g_he_ext_run_except.person_number       := NULL;
          g_he_ext_run_except.unit_cd             := p_unit_cd;
          g_he_ext_run_except.uv_version_number   := p_uv_version_number;

          -- Call procedure to log error
          log_error (g_he_ext_run_except);

         -- Dont process this module any further
         CLOSE c_moddtl;
         RETURN FALSE;
      END IF; -- Module details not found

      CLOSE c_moddtl;

      process_fields
             (p_extract_run_id         => p_extract_run_id,
              p_person_id              => NULL,
              p_course_cd              => NULL,
              p_crv_version_number     => NULL,
              p_student_inst_number    => NULL,
              p_unit_cd                => p_unit_cd,
              p_uv_version_number      => p_uv_version_number,
              p_line_number            => p_line_number);

      RETURN TRUE;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);
          IF c_moddtl%ISOPEN
          THEN
              CLOSE c_moddtl;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME',
                                'IGS_HE_EXTRACT2_PKG.process_module_return');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END process_module_return;



   /*----------------------------------------------------------------------
   This function does the processing for a DLHE Return
   It will select all the required details and then call the individual
   procedures to derive the field values.

   Parameters :
   p_extract_run_id         The Extract Run Id
   p_person_id              Person Id
   p_line_number            Line Number of the current line being processed
   ----------------------------------------------------------------------*/
   FUNCTION process_dlhe_return
             (p_extract_run_id      igs_he_ext_run_dtls.extract_run_id%TYPE,
              p_person_id              igs_he_ex_rn_dat_ln.person_id%TYPE,
              p_line_number         igs_he_ex_rn_dat_ln.line_number%TYPE)
             RETURN BOOLEAN
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :This procedure does the processing for a DLHE Return
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What

   ***************************************************************/
           CURSOR c_dlhe_dtls(cp_submission_name igs_he_submsn_return.submission_name%TYPE ,
                              cp_return_name igs_he_submsn_return.return_name%TYPE ) IS
           SELECT *
           FROM   igs_he_stdnt_dlhe
           WHERE  person_id  = p_person_id
           AND    submission_name = cp_submission_name
           AND    return_name    = cp_return_name ;

           CURSOR c_pers_number IS
           SELECT pe.party_number person_number
           FROM   hz_parties pe
           WHERE  pe.party_id = p_person_id;

           l_message               VARCHAR2(2000);

   BEGIN

      -- Fetch the Person Number
      g_pe_person       := NULL;
      OPEN c_pers_number;
      FETCH c_pers_number INTO g_pe_person.person_number;
      IF c_pers_number%NOTFOUND
      THEN
          Fnd_Message.Set_Name('IGS', 'IGS_HE_EXT_PSN_NOT_FOUND');
          l_message := Fnd_Message.Get;

          -- Initialize Record to Null.
          g_he_ext_run_except := NULL;

          -- Populate the required fields.
          g_he_ext_run_except.extract_run_id      := p_extract_run_id;
          g_he_ext_run_except.exception_reason    := l_message;
          g_he_ext_run_except.person_id           := p_person_id;
          g_he_ext_run_except.person_number       := p_person_id;
          g_he_ext_run_except.course_cd           := NULL;
          g_he_ext_run_except.crv_version_number  := NULL;

          -- Call procedure to log error
          log_error (g_he_ext_run_except);

         -- Dont process this student any further
         CLOSE c_pers_number;
         RETURN FALSE;
      ELSE
         CLOSE c_pers_number;
      END IF;

      -- Get the dlhe student Details
      g_he_stdnt_dlhe   := NULL;
      OPEN c_dlhe_dtls(g_he_ext_run_dtls.submission_name , g_he_ext_run_dtls.return_name);
      FETCH c_dlhe_dtls INTO g_he_stdnt_dlhe;

      IF c_dlhe_dtls%NOTFOUND
      THEN
          -- If dlhe person details were not found, then log error
          Fnd_Message.Set_Name('IGS', 'IGS_HE_EXT_DLHE_DTL_NOT_FOUND');
          l_message := Fnd_Message.Get;

          -- Initialize Record to Null.
          g_he_ext_run_except := NULL;

          -- Populate the required fields.
          g_he_ext_run_except.extract_run_id      := p_extract_run_id;
          g_he_ext_run_except.exception_reason    := l_message;
          g_he_ext_run_except.person_id           := p_person_id;
          g_he_ext_run_except.course_cd           := NULL;
          g_he_ext_run_except.crv_version_number  := NULL;
          g_he_ext_run_except.person_number       := g_pe_person.person_number;
          g_he_ext_run_except.unit_cd             := NULL;
          g_he_ext_run_except.uv_version_number   := NULL;

          -- Call procedure to log error
          log_error (g_he_ext_run_except);

         -- Dont process this Student any further
         CLOSE c_dlhe_dtls;
         RETURN FALSE;
      ELSE
         CLOSE c_dlhe_dtls;
      END IF; -- Student details not found

      process_fields
             (p_extract_run_id         => p_extract_run_id,
              p_person_id              => p_person_id,
              p_course_cd              => NULL,
              p_crv_version_number     => NULL,
              p_student_inst_number    => NULL,
              p_unit_cd                => NULL,
              p_uv_version_number      => NULL,
              p_line_number            => p_line_number);

      RETURN TRUE;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);
          IF c_dlhe_dtls%ISOPEN
          THEN
              CLOSE c_dlhe_dtls;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT2_PKG.process_dlhe_return');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END process_dlhe_return;



   /*----------------------------------------------------------------------
   This procedure processes the records that have been inserted into
   the temporary run table.
   For each student / module, it will derive each of the fields and insert
   the rows into the extarct run data tables.

   Parameters :
   p_extract_run_id     IN     The Extract Run Id
   ----------------------------------------------------------------------*/
   PROCEDURE process_temp_table
          (p_extract_run_id         IN igs_he_ext_run_dtls.extract_run_id%TYPE,
           p_module_called_from     IN VARCHAR2,
           p_new_run_flag           IN VARCHAR2)
   IS
   /***************************************************************
   Created By           :        Bidisha S
   Date Created By      :        28-Jan-02
   Purpose              :This procedure processes the records that have been inserted into
                         the temporary run table.
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who       When       What
   smaddali  09-apr-03  modified procedure for HEFD203 build , bug 2717745
   sjlaport  03-Jun-05  Cache translated error message IGS_HE_EXT_FLD_VAL_NULL bug 4304808
   jbaber    15-Mar-06  Better support for recalculated records as per HE365 - Exract Rerun
  ***************************************************************/
           CURSOR c_get_temp_rows IS
           SELECT rowid,
                  ext_interim_id,
                  person_id,
                  course_cd,
                  crv_version_number ,
                  unit_cd,
                  uv_version_number,
                  student_inst_number,
                  line_number
           FROM   igs_he_ext_run_interim
           WHERE  extract_run_id = p_extract_run_id;

           l_line_number        igs_he_ex_rn_dat_ln.line_number%TYPE;
           l_he_ex_rn_dat_ln    igs_he_ex_rn_dat_ln%ROWTYPE;
           l_rowid              VARCHAR2(30);
           l_message            VARCHAR2(2000);


      -- smaddali added cursor for bug#3361317
      CURSOR c_pers_number ( cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
      SELECT party_number person_number
      FROM hz_parties
      WHERE party_id = cp_person_id ;
      l_person_number igs_pe_Person_base_v.person_number%TYPE;

     TYPE INTRM_RECORDS IS TABLE OF NUMBER(15) NOT NULL INDEX BY BINARY_INTEGER;
     l_rec_list INTRM_RECORDS;
     l_rec_cnt NUMBER;

   BEGIN

      -- Initialize the global variable at the start of the process
      g_default_pro := 'Y';
      g_prog_rec_flag := FALSE;
      g_prog_type_rec_flag := FALSE;

      -- printing datetimestamp for monitoring performance
      fnd_message.set_name('IGS','IGS_HE_ST_PROC_TIME');
      fnd_message.set_token('PROCEDURE', 'PROCESS_TEMP_TABLE');
      fnd_message.set_token('TIMESTAMP',TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
      fnd_file.put_line(fnd_file.log, fnd_message.get);


      Fnd_Message.Set_Name('IGS', 'IGS_HE_EXT_FLD_VAL_NULL');
      g_msg_ext_fld_val_null := Fnd_Message.Get;

      -- Load the field definitions for each field of the return
      -- into an array
      get_field_defn (p_extract_run_id );

      -- If fields are setup for this submission then process interim table
      IF g_field_defn.field_number.COUNT <> 0
      THEN

              SELECT MAX(line_number)
              INTO   l_line_number
              FROM   igs_he_ex_rn_dat_ln
              WHERE  extract_run_id = p_extract_run_id;

              l_line_number := Nvl(l_line_number,0) + 1;

              -- Get the rows from the temporary processing table which
              -- needs to be processed.

            BEGIN

              l_rec_cnt := 0;

              -- Store values in g_prog_rec_flag and g_prog_type_rec_flag global fields
              IF Substr(g_he_submsn_return.record_id,4,2) = '11'
              OR Substr(g_he_submsn_return.record_id,4,2) = '12'
              THEN

                 igs_he_extract_fields_pkg.get_awd_dtls (g_he_ext_run_dtls.submission_name,
                                                         g_awd_table,
                                                         g_prog_rec_flag,
                                                         g_prog_type_rec_flag);
              END IF;

              FOR l_temp_rows IN c_get_temp_rows
              LOOP
                  -- Initialize record to NULL
                  l_he_ex_rn_dat_ln := NULL;

                  SAVEPOINT savepoint_dat_ln_ins;

                  IF Substr(g_he_submsn_return.record_id,4,2) = '11'
                  OR Substr(g_he_submsn_return.record_id,4,2) = '12'
                  THEN
                      -- Student or Combined Return
                      l_he_ex_rn_dat_ln.person_id  := l_temp_rows.person_id;
                      l_he_ex_rn_dat_ln.course_cd  := l_temp_rows.course_cd;
                      l_he_ex_rn_dat_ln.crv_version_number
                                                   := l_temp_rows.crv_version_number;
                      l_he_ex_rn_dat_ln.student_inst_number
                                                   := l_temp_rows.student_inst_number;

                  ELSIF Substr(g_he_submsn_return.record_id,4,2) = '13' THEN
                      -- Module Return
                      l_he_ex_rn_dat_ln.unit_cd            := l_temp_rows.unit_cd;
                      l_he_ex_rn_dat_ln.uv_version_number  := l_temp_rows.uv_version_number;
                  -- smaddali added processing for DLHE return , HEFD203 nuild bug#2717745
                  ELSIF Substr(g_he_submsn_return.record_id,4,2) = '18' THEN
                      -- DLHE return
                      l_he_ex_rn_dat_ln.person_id  := l_temp_rows.person_id;
                  END IF;

                  -- Populate table if line does not exist
                  IF l_temp_rows.line_number IS NULL
                  THEN
                      g_field_exists                           := FALSE;
                      l_he_ex_rn_dat_ln.extract_run_id         := p_extract_run_id;
                      l_he_ex_rn_dat_ln.record_id              := g_he_submsn_return.record_id;
                      l_he_ex_rn_dat_ln.line_number            := l_line_number;
                      l_he_ex_rn_dat_ln.manually_inserted      := 'N';
                      l_he_ex_rn_dat_ln.exclude_from_file      := 'N';

                      -- If process is called from IGSHEE008 then set recalculate flag to Y
                      IF p_module_called_from = 'IGSHE008' THEN
                         l_he_ex_rn_dat_ln.recalculate_flag    := 'Y';
                      ELSE
                         l_he_ex_rn_dat_ln.recalculate_flag    := 'N';
                      END IF;

                      Igs_He_Ex_Rn_Dat_Ln_Pkg.Insert_Row
                           (X_rowid                => l_rowid,
                            X_rn_dat_ln_id         => l_he_ex_rn_dat_ln.rn_dat_ln_id,
                            X_person_id            => l_he_ex_rn_dat_ln.person_id,
                            X_course_cd            => l_he_ex_rn_dat_ln.course_cd,
                            X_crv_version_number   => l_he_ex_rn_dat_ln.crv_version_number,
                            X_student_inst_number  => l_he_ex_rn_dat_ln.student_inst_number,
                            X_unit_cd              => l_he_ex_rn_dat_ln.unit_cd,
                            X_uv_version_number    => l_he_ex_rn_dat_ln.uv_version_number,
                            X_extract_run_id       => l_he_ex_rn_dat_ln.extract_run_id,
                            X_record_id            => l_he_ex_rn_dat_ln.record_id,
                            X_line_number          => l_he_ex_rn_dat_ln.line_number,
                            X_manually_inserted    => l_he_ex_rn_dat_ln.manually_inserted,
                            X_exclude_from_file    => l_he_ex_rn_dat_ln.exclude_from_file,
                            X_recalculate_flag     => l_he_ex_rn_dat_ln.recalculate_flag);

                      -- increment line number
                      l_line_number := l_line_number + 1;

                  ELSE

                      g_field_exists := TRUE;

                      -- Store the line number for the rows marked as 'recalculate'
                      l_he_ex_rn_dat_ln.line_number := l_temp_rows.line_number;

                      -- Update timestamp of recalulated record
                      -- to allow filtering on date when creating the extract file.
                      -- Also update recalculate flag for any records that were picked up from
                      -- person or program criteria.
                      UPDATE igs_he_ex_rn_dat_ln
                      SET    last_update_date = sysdate,
                             recalculate_flag = 'Y'
                      WHERE  extract_run_id = p_extract_run_id
                      AND    line_number = l_he_ex_rn_dat_ln.line_number;

                  END IF; -- Line already exists?

                  -- smaddali added code to derive person number to be shown in the log file., bug#3361317
                  l_person_number := NULL;
                  IF l_he_ex_rn_dat_ln.person_id IS NOT NULL THEN
                     OPEN c_pers_number(l_he_ex_rn_dat_ln.person_id  );
                     FETCH c_pers_number INTO l_person_number;
                     CLOSE c_pers_number ;
                  END IF ;

                  IF Substr(g_he_submsn_return.record_id,4,2) = '11'
                  OR Substr(g_he_submsn_return.record_id,4,2) = '12'
                  THEN
                      --  Combined Return
                      IF NOT process_comb_stdnt_return(p_extract_run_id,
                                          l_he_ex_rn_dat_ln.person_id,
                                          l_he_ex_rn_dat_ln.course_cd,
                                          l_he_ex_rn_dat_ln.crv_version_number,
                                          l_he_ex_rn_dat_ln.student_inst_number,
                                          l_he_ex_rn_dat_ln.line_number)
                      THEN

                        fnd_message.set_name('IGS','IGS_HE_COM_STD_PROC');
                        fnd_message.set_token('person',l_person_number);
                        fnd_file.put_line(fnd_file.log,fnd_message.get());


                          -- Not processed successfully, therefore rollback
                          -- for this student record
                          ROLLBACK TO savepoint_dat_ln_ins;

                          -- Decrement the line number as this line will not
                          -- be processed.
                          l_line_number := l_line_number - 1;
                      END IF;
                  ELSIF Substr(g_he_submsn_return.record_id,4,2) = '13' THEN
                      -- Module Return
                      IF NOT process_module_return(p_extract_run_id,
                                            l_he_ex_rn_dat_ln.unit_cd,
                                            l_he_ex_rn_dat_ln.uv_version_number,
                                            l_he_ex_rn_dat_ln.line_number)
                      THEN
                          -- Not processed successfully, therefore rollback
                          -- for this module record
                          ROLLBACK TO savepoint_dat_ln_ins;

                          fnd_message.set_name('IGS','IGS_HE_MOD_PROC');
                          fnd_message.set_token('unit',l_he_ex_rn_dat_ln.unit_cd);
                          fnd_file.put_line(fnd_file.log,fnd_message.get());

                          -- Decrement the line number as this line will not
                          -- be processed.
                          l_line_number := l_line_number - 1;
                      END IF;
                  -- smaddali added code to process dlhe return , for HEFD203 build , bug#2717745
                  ELSIF SUBSTR(g_he_submsn_return.record_id,4,2) = '18' THEN
                      -- DLHE return
                      IF NOT process_dlhe_return(p_extract_run_id,
                                            l_he_ex_rn_dat_ln.person_id,
                                            l_he_ex_rn_dat_ln.line_number)
                      THEN
                          -- Not processed successfully, therefore rollback
                          -- for this student record
                          ROLLBACK TO savepoint_dat_ln_ins;

                          fnd_message.set_name('IGS','IGS_HE_DLHE_PROC');
                          fnd_message.set_token('unit',l_person_number);
                          fnd_file.put_line(fnd_file.log,fnd_message.get());

                          -- Decrement the line number as this line will not
                          -- be processed.
                          l_line_number := l_line_number - 1;
                      END IF;
                  END IF; -- Process fields.

                  l_rec_list(l_rec_cnt) := l_temp_rows.ext_interim_id;
                  l_rec_cnt := l_rec_cnt + 1;

                  -- Commit transaction for this row.
                  COMMIT;

              END LOOP; -- End Loop for rows from the Interm Processing Table


            EXCEPTION
            WHEN OTHERS THEN
              write_to_log(SQLERRM);
              ROLLBACK;
              -- Delete the records processed before raising the exception
              FOR l_rec IN 0 .. l_rec_cnt -1 LOOP
                DELETE FROM igs_he_ext_run_interim WHERE ext_interim_id = l_rec_list(l_rec_cnt);
              END LOOP;
              -- Commit the Delete Records as they are already processed successfully
              COMMIT;
              -- Raise The exception
              App_Exception.Raise_Exception;
            END;

            -- Delete the records from igs_he_ext_run_interim of the current Run ID, p_extract_run_id
            -- The direct Delete Statement is used against the standards because of performance improvement only.
            -- Same issue was fixed in IGSHE9AB.pls for bug,3179585
            DELETE FROM igs_he_ext_run_interim WHERE extract_run_id = p_extract_run_id;

      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT2_PKG.process_temp_table');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

   END process_temp_table;

END IGS_HE_EXTRACT2_PKG;

/
