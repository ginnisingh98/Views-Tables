--------------------------------------------------------
--  DDL for Package Body IGS_HE_VERIFY_RETURN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_VERIFY_RETURN_PKG" AS
/* $Header: IGSHE27B.pls 120.3 2006/06/21 03:00:01 jchin noship $*/


   -- Global variables
   g_he_submsn_return                     igs_he_submsn_return%ROWTYPE;
   g_he_submsn_header                     igs_he_submsn_header%ROWTYPE;



  PROCEDURE check_associations(p_user_return_subclass IN VARCHAR2) IS
  /******************************************************************
   Created By      : Jonathan Baber
   Date Created By : 23-Nov-05
   Purpose         : Checks field associations for given extract.
                     Makes sure every OSS code has corresponding HESA code.
   Known limitations,enhancements,remarks:
   Change History
   Who       When         What
  *******************************************************************/


      TYPE cur_unmapped  IS REF CURSOR;
      l_unmapped  cur_unmapped;

      -- Gets all distinct association codes used in given extract
      -- ordered by the first field they appear in
      CURSOR c_assoc IS
      SELECT MIN(ass.field_number) field, ass.association_code, ass.oss_seq, ass.hesa_seq
        FROM igs_he_usr_rtn_clas urc,
             igs_he_usr_rt_cl_fld fld,
             igs_he_sys_rt_cl_ass ass
       WHERE urc.user_return_subclass = p_user_return_subclass
         AND fld.user_return_subclass = urc.user_return_subclass
         AND ass.system_return_class_type = urc.system_return_class_type
         AND fld.field_number = ass.field_number
         AND fld.include_flag = 'Y'
         AND ass.oss_seq IS NOT NULL
         AND ass.hesa_seq IS NOT NULL
       GROUP BY ass.association_code, ass.oss_seq, ass.hesa_seq
       ORDER BY field;

      -- Gets all the fields affected by a given association code
      CURSOR c_fields(cp_association_code igs_he_sys_rt_cl_ass.association_code%TYPE) IS
      SELECT ass.field_number
        FROM igs_he_usr_rtn_clas urc,
             igs_he_usr_rt_cl_fld fld,
             igs_he_sys_rt_cl_ass ass
       WHERE urc.user_return_subclass = p_user_return_subclass
         AND fld.user_return_subclass = urc.user_return_subclass
         AND ass.system_return_class_type = urc.system_return_class_type
         AND fld.field_number = ass.field_number
         AND fld.include_flag = 'Y'
        AND ass.association_code = cp_association_code
       ORDER BY ass.field_number;

      -- Get the association type of the code (either CODE, DIRECT or INDIRECT)
      CURSOR c_assoc_type(cp_association_code igs_he_code_ass_val.association_code%TYPE,
                          cp_sequence igs_he_code_ass_val.sequence%TYPE) IS
      SELECT association_type, main_source, secondary_source, condition, display_title
        FROM igs_he_code_ass_val
       WHERE association_code = cp_association_code
         AND sequence = cp_sequence;

      l_unmapped_value    igs_he_code_map_val.map2%TYPE;
      l_assoc_type        c_assoc_type%ROWTYPE;
      l_where_stmt        VARCHAR2(100);
      l_stmt              VARCHAR2(400);
      l_affected_fields   VARCHAR2(50);
      l_count             NUMBER := 0;

  BEGIN

      -- Log Header
      fnd_message.set_name('IGS','IGS_HE_VERIFY_CHECK_CODES');
      fnd_message.set_token('DATE',TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
      fnd_file.put_line(fnd_file.log,fnd_message.get());

      -- Loop through all field associations of selected user defined return class
      -- Need to determine every OSS value that doesn't have a corresponding HESA value
      FOR l_assoc IN c_assoc LOOP

          l_stmt := NULL;
          l_where_stmt := NULL;
          l_assoc_type := NULL;

          -- Determine association type of the OSS mapping
          OPEN c_assoc_type(l_assoc.association_code, l_assoc.oss_seq);
          FETCH c_assoc_type INTO l_assoc_type;
          CLOSE c_assoc_type;


          -- Construct query
          IF l_assoc_type.association_type = 'CODE' THEN
              l_stmt := ' SELECT DISTINCT value' ||
                        ' FROM igs_he_code_values ' ||
                        ' WHERE value NOT IN ';
          ELSE
              l_stmt := ' SELECT DISTINCT ' || l_assoc_type.secondary_source ||
                        ' FROM ' || l_assoc_type.main_source ||
                        ' WHERE ' || l_assoc_type.secondary_source || ' NOT IN ';
          END IF;

          -- Construct where clause to get all OSS values which are not mapped
	  l_stmt := l_stmt || ' (SELECT map' || l_assoc.oss_seq ||
	                      '  FROM igs_he_code_map_val ' ||
                              '  WHERE association_code = :ASS_CODE)';

          -- Include any other where conditions
          IF l_assoc_type.association_type = 'CODE' THEN
              l_stmt := l_stmt || ' AND closed_ind = ''N'' AND code_type = :CODE_TYPE ';
          ELSIF l_assoc_type.condition IS NOT NULL THEN
              l_stmt := l_stmt || ' AND ' || l_assoc_type.condition;
          END IF;


          -- Open cursor with appropriate bind variables
          IF l_assoc_type.association_type = 'CODE' THEN
              OPEN l_unmapped FOR l_stmt USING l_assoc.association_code, l_assoc_type.main_source;
          ELSE
              OPEN l_unmapped FOR l_stmt USING l_assoc.association_code;
          END IF;

          -- Find all unmapped OSS values
          FETCH l_unmapped INTO l_unmapped_value;

          IF l_unmapped%FOUND THEN

              -- Get all fields affected by missing association code mapping
              FOR l_fields IN c_fields(l_assoc.association_code) LOOP
                  IF c_fields%ROWCOUNT = 1 THEN
                      l_affected_fields := l_fields.field_number;
                  ELSE
                      IF LENGTH(l_affected_fields || ',' || l_fields.field_number) < 22 THEN
                         l_affected_fields := l_affected_fields || ',' || l_fields.field_number;
                      ELSE
                         l_affected_fields := l_affected_fields || '...';
                         EXIT;
                      END IF;
                  END IF;
              END LOOP; -- affected fields

              -- Insert each unmapped value into temp table
              LOOP

                  INSERT INTO IGS_HE_VERIFY_DATA_T (association_code, fields_affected, display_title, oss_value, creation_date, created_by, last_update_date, last_updated_by)
                  VALUES (l_assoc.association_code, l_affected_fields, l_assoc_type.display_title, l_unmapped_value, sysdate, -1, sysdate, -1);

                  --Increment Counter
                  l_count := l_count + 1;

                  FETCH l_unmapped INTO l_unmapped_value;
                  EXIT WHEN l_unmapped%NOTFOUND;

              END LOOP;

          END IF; -- unmapped found

          CLOSE l_unmapped;

      END LOOP; -- association codes

      -- Log Summary
      fnd_message.set_name('IGS','IGS_HE_VERIFY_MISS_CODES');
      fnd_message.set_token('MISSING',l_count);
      fnd_file.put_line(fnd_file.log,fnd_message.get());

      EXCEPTION
       WHEN OTHERS THEN

          IF l_unmapped%ISOPEN THEN
              CLOSE l_unmapped;
          END IF;

          IF c_assoc%ISOPEN THEN
              CLOSE c_assoc;
          END IF;

          IF c_assoc_type%ISOPEN THEN
              CLOSE c_assoc_type;
          END IF;

          IF c_fields%ISOPEN THEN
              CLOSE c_fields;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','igs_he_verify_setup_pkg.check_associations - ' || SQLERRM);
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          App_Exception.Raise_Exception;

  END check_associations;



  PROCEDURE check_HESA_data(p_submission_name          IN  VARCHAR2,
                            p_user_return_subclass     IN  VARCHAR2,
                            p_return_name              IN  VARCHAR2) IS
  /******************************************************************
   Created By      : Jonathan Baber
   Date Created By : 23-Nov-05
   Purpose         : Makes sure HESA records exist at the correct levels
   Known limitations,enhancements,remarks:
   Change History
   Who       When         What
   jchin     21-Jun-06    Bug 5213152 Modified c_get_yop cursor to
                          conform with IGSHE9AB
  *******************************************************************/


      -- Cursor to determine if course has qual aim
      CURSOR c_award_qualaim
            (cp_course_cd      igs_ps_award.course_cd%TYPE,
             cp_version_number igs_ps_award.version_number%TYPE) IS
      SELECT DECODE(count(award_cd), 0, 'N', 'Y')
        FROM igs_ps_award
       WHERE course_cd = cp_course_cd
         AND version_number = cp_version_number
         AND closed_ind = 'N';


      -- Get Student Program Attempt Records
      -- Similar cursor as IGSHE9AB but with outer join to igs_he_st_spa_all
      CURSOR c_get_spa (cp_awd_conf_start_dt    DATE,
                        cp_awd_conf_end_dt      DATE)  IS
      SELECT DISTINCT sca.person_id,
              pe.party_number person_number,
              sca.course_cd,
              sca.version_number,
              sca.location_cd ,
              sca.attendance_mode,
              sca.attendance_type,
              sca.cal_type sca_cal_type,
              sca.commencement_dt ,
              sca.discontinued_dt,
              sca.course_rqrmnts_complete_dt,
              sca.course_attempt_status,
              hspa.student_inst_number,
              DECODE(hspa.hesa_st_spa_id, NULL, 'N', 'Y')      spa_flag,
              DECODE(hspa.student_inst_number, NULL, 'N', 'Y') sin_flag,
              DECODE(hspa.student_qual_aim, NULL, 'N', 'Y')    spa_qualaim_flag,
              enawd.complete_ind,
              enawd.conferral_date
       FROM   igs_en_stdnt_ps_att_all sca,
              igs_he_st_spa_all       hspa,
              igs_he_st_prog_all      hprog,
              igs_en_spa_awd_aim      enawd,
              hz_parties              pe
       WHERE  sca.person_id          = hspa.person_id (+)
       AND    sca.course_cd          = hspa.course_cd (+)
       AND    sca.course_cd          = hprog.course_cd (+)
       AND    sca.version_number     = hprog.version_number (+)
       AND    NVL(hprog.exclude_flag, 'N') = 'N'
       AND    NVL(hspa.exclude_flag, 'N') = 'N'
       AND    NVL(sca.future_dated_trans_flag,'N') IN ('N','S')
       AND    sca.student_confirmed_ind = 'Y'
       AND    hspa.person_id         = enawd.person_id(+)
       AND    hspa.course_cd         = enawd.course_cd(+)
       AND    sca.person_id          = pe.party_id
       AND  ( ( sca.commencement_dt     <= g_he_submsn_header.enrolment_end_date
                              AND ( sca.discontinued_dt  IS NULL OR  sca.discontinued_dt >= g_he_submsn_header.enrolment_start_date )
                                    AND (sca.course_rqrmnts_complete_dt IS NULL OR
                                         sca.course_rqrmnts_complete_dt >= g_he_submsn_header.enrolment_start_date
                                        )
              )
              OR -- Added for HE309
                 -- check whether award conferral dates are defined first at program level
                 -- or program type level, otherwise hesa submission reporting periods
                enawd.complete_ind  = 'Y' AND
                     (enawd.conferral_date BETWEEN cp_awd_conf_start_dt AND cp_awd_conf_end_dt)
            )
      ORDER BY sca.person_id, hspa.student_inst_number, discontinued_dt DESC,
           course_rqrmnts_complete_dt DESC,  sca.commencement_dt DESC ;


      -- Get SUSA Records
      -- Similar cursor as IGSHE9AB but with outer join to igs_he_en_susa
      CURSOR c_get_yop (cp_person_id            igs_he_st_spa.person_id%TYPE,
                        cp_course_cd            igs_he_st_spa.course_cd%TYPE,
                        cp_enrl_start_dt        DATE,
                        cp_enrl_end_dt          DATE,
                        cp_awd_conf_start_dt    DATE,
                        cp_awd_conf_end_dt      DATE) IS
      SELECT DISTINCT
             susa.unit_set_cd,
             susa.us_version_number,
             DECODE(husa.hesa_en_susa_id, NULL, 'N','Y')     susa_flag
        FROM igs_as_su_setatmpt  susa,
             igs_he_en_susa      husa,
             igs_en_unit_set     us,
             igs_en_unit_set_cat susc,
             igs_en_spa_awd_aim enawd,
             igs_en_stdnt_ps_att_all sca
       WHERE susa.person_id = sca.person_id
         AND susa.course_cd = sca.course_cd
         AND sca.person_id           = enawd.person_id(+)
         AND sca.course_cd           = enawd.course_cd(+)
         AND susa.unit_set_cd        = husa.unit_set_cd(+)
         AND susa.us_version_number  = husa.us_version_number(+)
         AND susa.person_id          = husa.person_id(+)
         AND susa.course_cd          = husa.course_cd(+)
         AND susa.sequence_number    = husa.sequence_number(+)
         AND susa.unit_set_cd        = us.unit_set_cd
         AND susa.us_version_number  = us.version_number
         AND us.unit_set_cat         = susc.unit_set_cat
         AND susa.person_id          = cp_person_id
         AND susa.course_cd          = cp_course_cd
         AND susc.s_unit_set_cat     = 'PRENRL_YR'
         -- the program attempt is overlapping with the submmission period and the yop is also overlapping with the submission period
         AND  ( ( sca.commencement_dt <= cp_enrl_end_dt AND
                   (sca.discontinued_dt  IS NULL OR  sca.discontinued_dt   >= cp_enrl_start_dt ) AND
                   (sca.course_rqrmnts_complete_dt IS NULL OR  sca.course_rqrmnts_complete_dt >= cp_enrl_start_dt ) AND
                    susa.selection_dt <= cp_enrl_end_dt AND
                   (susa.end_dt  IS NULL OR susa.end_dt   >= cp_enrl_start_dt )  AND
                   (susa.rqrmnts_complete_dt IS NULL OR susa.rqrmnts_complete_dt >= cp_enrl_start_dt)
                )
                 OR
                 -- jchin bug 5213152
                -- the program attempt is completed before the submmission period start and award is conferred in the submission period and
                -- the yop is completed before the award conferral date
                ( susa.rqrmnts_complete_dt < cp_enrl_start_dt  AND
                  sca.course_rqrmnts_complete_dt <= cp_enrl_end_dt  AND
                  enawd.complete_ind = 'Y' AND
                  enawd.conferral_date BETWEEN cp_awd_conf_start_dt AND cp_awd_conf_end_dt
                )
              ) ;

      -- Does program have associated HESA record?
      CURSOR c_get_prog(cp_course_cd      igs_he_st_prog_all.course_cd%TYPE,
                        cp_version_number igs_he_st_prog_all.version_number%TYPE) IS
      SELECT DECODE(count(course_cd), 0, 'N', 'Y') prog_flag
        FROM igs_he_st_prog_all
       WHERE course_cd = cp_course_cd
         AND version_number = cp_version_number;


      -- Does POOUS have associated HESA record?
      CURSOR c_get_poous(cp_crv_version_number igs_he_poous_all.crv_version_number%TYPE,
                         cp_course_cd          igs_he_poous_all.course_cd%TYPE,
                         cp_cal_type           igs_he_poous_all.cal_type%TYPE,
                         cp_location_cd        igs_he_poous_all.location_cd%TYPE,
                         cp_attendance_mode    igs_he_poous_all.attendance_mode%TYPE,
                         cp_attendance_type    igs_he_poous_all.attendance_type%TYPE,
                         cp_unit_set_cd        igs_he_poous_all.unit_set_cd%TYPE,
                         cp_us_version_number  igs_he_poous_all.us_version_number%TYPE) IS
      SELECT DECODE(count(crv_version_number), 0, 'N', 'Y') poous_flag
        FROM igs_he_poous_all
       WHERE crv_version_number = cp_crv_version_number
         AND course_cd = cp_course_cd
         AND cal_type = cp_cal_type
         AND location_cd = cp_location_cd
         AND attendance_mode = cp_attendance_mode
         AND attendance_type = cp_attendance_type
         AND unit_set_cd = cp_unit_set_cd
         AND us_version_number = cp_us_version_number;

      -- Determines course type
      CURSOR c_prog_type (cp_course_cd      igs_ps_ver_all.course_cd%TYPE,
                          cp_version_number igs_ps_ver_all.version_number%TYPE) IS
      SELECT course_type
        FROM igs_ps_ver_all
       WHERE course_cd = cp_course_cd
         AND version_number = cp_version_number;

      -- Alternate ID Cursor
      CURSOR c_alternate_id (p_person_id      igs_pe_person.person_id%TYPE,
                             cp_enrl_start_dt igs_he_submsn_header.enrolment_start_date%TYPE,
                             cp_enrl_end_dt   igs_he_submsn_header.enrolment_end_date%TYPE) IS
      SELECT api_person_id,person_id_type, LENGTH(api_person_id) api_length
        FROM igs_pe_alt_pers_id
       WHERE pe_person_id   = p_person_id
         AND person_id_type IN ('HUSID', 'UCASID', 'GTTRID', 'NMASID', 'SWASID')
         AND Start_Dt <= cp_enrl_end_dt
         AND (End_Dt IS NULL OR End_Dt >= cp_enrl_start_dt )
         AND (End_Dt IS NULL OR Start_Dt <> End_Dt)
       ORDER BY person_id_type, Start_Dt DESC ;

      -- Unit Attempt enrollment
      -- returns a row if a SPA has any unit attempts with a status of ENROLLED, COMPLETED, DISCONTIN
      -- or DUPLICATE where the unit attempt enrollment date is less than or equal to the reporting
      -- period end date.
      CURSOR c_enr_su (p_person_id          igs_en_stdnt_ps_att_all.person_id%TYPE,
                       p_course_cd          igs_en_stdnt_ps_att_all.course_cd%TYPE,
                       p_enrolment_end_date igs_he_submsn_header.enrolment_end_date%TYPE)  IS
      SELECT 'X'
        FROM igs_en_su_attempt_all
       WHERE person_id = p_person_id
         AND course_cd = p_course_cd
         AND unit_attempt_status IN ('ENROLLED', 'COMPLETED','DISCONTIN','DUPLICATE')
         AND enrolled_dt <= p_enrolment_end_date;



      l_enrolled_su                          c_enr_su%ROWTYPE ;
      l_prog_type                            igs_ps_ver_all.course_type%TYPE;
      l_prev_pid_type                        igs_pe_alt_pers_id.person_id_type%TYPE := 'X' ;
      l_api_person_id                        igs_pe_alt_pers_id.api_person_id%TYPE;
      l_id                                   NUMBER;
      l_awd_table                            igs_he_extract_fields_pkg.awd_table;
      l_prog_rec_flag                        BOOLEAN := FALSE;
      l_prog_type_rec_flag                   BOOLEAN := FALSE;
      l_awd_conf_start_dt                    igs_he_submsn_awd.award_start_date%TYPE;
      l_awd_conf_end_dt                      igs_he_submsn_awd.award_end_date%TYPE;
      l_prev_person_id                       NUMBER := -1;
      l_prev_student_inst_number             VARCHAR2(100) := '-1';
      l_valid                                BOOLEAN;
      l_verify_data                          igs_he_verify_data_t%ROWTYPE := NULL;
      l_count                                NUMBER;



  BEGIN

      -- Log Header
      fnd_message.set_name('IGS','IGS_HE_VERIFY_CHECK_HESA');
      fnd_message.set_token('DATE',TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
      fnd_file.put_line(fnd_file.log,fnd_message.get());

      -- Get award conferral dates (to be used in c_get_spa)
      igs_he_extract_fields_pkg.get_awd_dtls( p_submission_name, l_awd_table, l_prog_rec_flag, l_prog_type_rec_flag);
      igs_he_extract_fields_pkg.get_min_max_awd_dates( p_submission_name, g_he_submsn_header.enrolment_start_date, g_he_submsn_header.enrolment_end_date, l_awd_conf_start_dt, l_awd_conf_end_dt);

      -- Examine each spa record for eligibility
      FOR l_std_inst IN c_get_spa(l_awd_conf_start_dt, l_awd_conf_end_dt) LOOP

          IF (l_std_inst.person_id <> l_prev_person_id) OR (l_std_inst.student_inst_number <> l_prev_student_inst_number) THEN


              l_verify_data := NULL;

              l_verify_data.person_id           := l_std_inst.person_id;
              l_verify_data.course_cd           := l_std_inst.course_cd;
              l_verify_data.crv_version_number  := l_std_inst.version_number;
              l_verify_data.cal_type           	:= l_std_inst.sca_cal_type;
              l_verify_data.location_cd		:= l_std_inst.location_cd;
              l_verify_data.attendance_mode	:= l_std_inst.attendance_mode;
              l_verify_data.attendance_type	:= l_std_inst.attendance_type;


              /********* Basic Validation  *********/
              -- similar to IGSHE9AB, but without 'Define Extract Criteria'
              -- parameter validation

              l_valid := TRUE;


              -- Award conferral dates
              IF l_valid THEN

                  l_awd_conf_start_dt := g_he_submsn_header.enrolment_start_date;
                  l_awd_conf_end_dt   := g_he_submsn_header.enrolment_end_date;

                  IF NOT ( l_std_inst.commencement_dt <= g_he_submsn_header.enrolment_end_date
                     AND ( l_std_inst.discontinued_dt  IS NULL OR  l_std_inst.discontinued_dt >= g_he_submsn_header.enrolment_start_date )
                     AND (l_std_inst.course_rqrmnts_complete_dt IS NULL OR  l_std_inst.course_rqrmnts_complete_dt >= g_he_submsn_header.enrolment_start_date)
                     ) THEN

                      -- If student has a conferral date
                      IF l_std_inst.complete_ind = 'Y' AND l_std_inst.conferral_date IS NOT NULL THEN

                          IF l_prog_type_rec_flag = TRUE
                          THEN

                              -- If there are award conferral dates specified at the program type
                              -- level only, then check if any relate to this particular student program attempt
                              OPEN c_prog_type(l_std_inst.course_cd, l_std_inst.version_number);
                              FETCH c_prog_type INTO l_prog_type;
                              CLOSE c_prog_type;


                              igs_he_extract_fields_pkg.get_awd_conferral_dates(l_awd_table,
                                                                                p_submission_name,
                                                                                l_prog_rec_flag,
                                                                                l_prog_type_rec_flag,
                                                                                l_std_inst.course_cd,
                                                                                l_prog_type,
                                                                                g_he_submsn_header.enrolment_start_date,
                                                                                g_he_submsn_header.enrolment_end_date,
                                                                                l_awd_conf_start_dt,
                                                                                l_awd_conf_end_dt);

                          ELSE

                              -- If there are award conferral dates specified at the program level only,
                              -- then check if any relate to this particular student program attempt
                              igs_he_extract_fields_pkg.get_awd_conferral_dates(l_awd_table,
                                                                                p_submission_name,
                                                                                l_prog_rec_flag,
                                                                                l_prog_type_rec_flag,
                                                                                l_std_inst.course_cd,
                                                                                NULL,
                                                                                g_he_submsn_header.enrolment_start_date,
                                                                                g_he_submsn_header.enrolment_end_date,
                                                                                l_awd_conf_start_dt,
                                                                                l_awd_conf_end_dt);

                          END IF;  --  l_prog_type_rec_flag

                          IF NOT l_std_inst.conferral_date BETWEEN l_awd_conf_start_dt AND l_awd_conf_end_dt THEN
                              l_valid := FALSE;
                          END IF;

                      END IF;

                  END IF;

              END IF; -- Award conferral dates


              -- Alternate ID Check
              IF l_valid THEN

                  l_prev_pid_type := 'X' ;
                  --TO check that the alternate person id's if present for the person is number (i.e it does not contains non-numeric character)
                  FOR alternate_id_rec IN c_alternate_id( l_std_inst.person_id,
                                                          g_he_submsn_header.enrolment_start_date,
                                                          g_he_submsn_header.enrolment_end_date) LOOP

                      IF (alternate_id_rec.person_id_type <> l_prev_pid_type) THEN

                            l_prev_pid_type := alternate_id_rec.person_id_type;
                            BEGIN

                              l_id := NULL;
                              l_api_person_id := NULL ;
                              l_api_person_id := alternate_id_rec.api_person_id;
                              IF l_api_person_id IS NOT NULL THEN
                                 l_id := TO_NUMBER(l_api_person_id);
                              END IF;

                            EXCEPTION
                              WHEN value_error THEN

                                -- In case the alternate person id contains non-numeric characters
                                -- exclude this record from further processing
                                l_valid := FALSE ;
                            END;

                            IF alternate_id_rec.person_id_type <> 'HUSID' AND alternate_id_rec.api_length > 8 THEN
                                -- HUSID has more than 8 characters so exclude this record
                                l_valid := FALSE ;
                            END IF;

                        END IF; -- validate only latest Person id type record of each type

                  END LOOP;

              END IF; -- Alternate ID Check


              -- Check SPA is enrolled
              IF l_valid THEN
                  -- if the current SPA is not enrolled, check associated unit attempts
                  IF NOT l_std_inst.course_attempt_status = 'ENROLLED' THEN
                      l_enrolled_su := NULL;
                      OPEN c_enr_su(l_std_inst.person_id,
                                    l_std_inst.course_cd,
                                    g_he_submsn_header.enrolment_end_date) ;
                      FETCH c_enr_su INTO l_enrolled_su ;
                      IF c_enr_su%NOTFOUND THEN
                          l_valid := FALSE;
                      END IF;
                      CLOSE c_enr_su;
                END IF;
              END IF;  -- SPA is enrolled


              -- Check offset days
              IF l_valid THEN

                  IF g_he_submsn_header.offset_days IS NOT NULL
                  THEN
                      IF g_he_submsn_header.apply_to_atmpt_st_dt = 'Y'
                        AND l_std_inst.discontinued_dt  < (l_std_inst.commencement_dt + g_he_submsn_header.offset_days)
                      THEN
                          -- Exclude this record
                          l_valid := FALSE;

                      END IF;
                  END IF;

              END IF; -- Offset days


              /*********  Check SUSA Details *********/
              IF l_valid THEN
                  OPEN c_get_yop(l_verify_data.person_id, l_verify_data.course_cd, g_he_submsn_header.enrolment_start_date, g_he_submsn_header.enrolment_end_date, l_awd_conf_start_dt, l_awd_conf_end_dt);
                  FETCH c_get_yop INTO l_verify_data.unit_set_cd,
                                       l_verify_data.us_version_number,
                                       l_verify_data.susa_flag;

                  -- If there is no SUSA record at all, then this SPA is invalid
                  IF c_get_yop%NOTFOUND THEN
                      l_valid := FALSE;
                  END IF;

                  CLOSE c_get_yop;

              END IF;



              IF l_valid THEN
                  -- If this is a module return this is as far as we need to go for the students.
                  -- We assume all these students *could* be in the return so we insert them into temp table
                  IF SUBSTR(g_he_submsn_return.record_id,4,2) = '13' THEN

                      INSERT INTO IGS_HE_VERIFY_DATA_T(person_id,  creation_date, created_by, last_update_date, last_updated_by)
                        VALUES (l_std_inst.person_id, sysdate, 1, sysdate, 1);

                  ELSE

                      -- If this is a student or combined return, we now need to check existence of HESA records...


                      /********* Check SPA Details *********/
                      l_verify_data.spa_flag      := l_std_inst.spa_flag;
                      l_verify_data.qualaim_flag  := l_std_inst.spa_qualaim_flag;
                      l_verify_data.sin_flag      := l_std_inst.sin_flag;

                      -- If spa_qualaim = 'N' at this point, check at the award level
                      IF l_std_inst.spa_qualaim_flag = 'N' THEN
                          OPEN c_award_qualaim(l_std_inst.course_cd, l_std_inst.version_number);
                          FETCH c_award_qualaim INTO l_verify_data.qualaim_flag;
                          CLOSE c_award_qualaim;
                      END IF;

                      /********* Check POOUS Details *********/
                      OPEN c_get_poous(l_verify_data.crv_version_number, l_verify_data.course_cd, l_verify_data.cal_type,
                                       l_verify_data.location_cd, l_verify_data.attendance_mode, l_verify_data.attendance_type,
                      		       l_verify_data.unit_set_cd, l_verify_data.us_version_number);
                      FETCH c_get_poous INTO l_verify_data.poous_flag;
                      CLOSE c_get_poous;


                      /********* Check Program Details *********/
                      OPEN c_get_prog( l_verify_data.course_cd, l_verify_data.crv_version_number);
                      FETCH c_get_prog INTO l_verify_data.prog_flag;
                      CLOSE c_get_prog;

                      -- Insert complete record into temp table
                      INSERT INTO IGS_HE_VERIFY_DATA_T
                         (person_id,
                          course_cd,
                          crv_version_number,
                          cal_type,
			  location_cd,
			  attendance_mode,
                          attendance_type,
                          unit_set_cd,
                          us_version_number,
                          spa_flag,
                          qualaim_flag,
                          sin_flag,
                          susa_flag,
                          poous_flag,
                          prog_flag,
                          creation_date,
                          created_by,
                          last_update_date,
                          last_updated_by)
                       VALUES
                         (l_verify_data.person_id,
                          l_verify_data.course_cd,
                          l_verify_data.crv_version_number,
                          l_verify_data.cal_type,
                          l_verify_data.location_cd,
                          l_verify_data.attendance_mode,
                          l_verify_data.attendance_type,
                          l_verify_data.unit_set_cd,
                          l_verify_data.us_version_number,
                          l_verify_data.spa_flag,
                          l_verify_data.qualaim_flag,
                          l_verify_data.sin_flag,
                          l_verify_data.susa_flag,
                          l_verify_data.poous_flag,
                          l_verify_data.prog_flag,
                          sysdate,
                          1,
                          sysdate,
                          1);


                  END IF; -- MODULE or COMBINED/STUDENT

	      END IF;

              -- Update previous Person ID and Student Instance Number
              l_prev_person_id := l_std_inst.person_id;
              l_prev_student_inst_number := l_std_inst.student_inst_number;

          END IF; -- End of Duplicate HSPA record Check

      END LOOP; -- For each Person ID and Student Instance Number




      -- If this is a module return
      IF SUBSTR(g_he_submsn_return.record_id,4,2) = '13' THEN

          /********* Check Module Details *********/
          -- Insert all units started or completed within the enrolment period
          -- by the students identified above. This is *similar* to the query used in
          -- IGSHE9CB, however the student_inst_number is NOT used so query may select
          -- more units than will appear in the return.
          INSERT INTO IGS_HE_VERIFY_DATA_T
            (unit_cd, u_version_number,  unit_flag, creation_date, created_by, last_update_date, last_updated_by)
              (SELECT DISTINCT
                    ua.unit_cd,
                    ua.version_number,
                    DECODE(hunt.hesa_st_unt_vs_id, NULL, 'N', 'Y') unit_flag, sysdate, 1, sysdate, 1
               FROM igs_en_su_attempt_all ua,
                    igs_he_verify_data_t t,
                    igs_he_st_unt_vs_all hunt
              WHERE t.person_id = ua.person_id
                AND ua.unit_cd = hunt.unit_cd (+)
                AND ua.version_number = hunt.version_number(+)
                AND ua.unit_attempt_status IN ('ENROLLED','DISCONTIN','COMPLETED')
                AND ua.ci_start_dt BETWEEN g_he_submsn_header.enrolment_start_date AND g_he_submsn_header.enrolment_end_date
                AND hunt.hesa_st_unt_vs_id IS NULL -- only get modules with no HESA details
             UNION
             SELECT DISTINCT
                    ua.unit_cd,
                    ua.version_number,
                    DECODE(hunt.hesa_st_unt_vs_id, NULL, 'N', 'Y') unit_flag, sysdate, 1, sysdate, 1
               FROM igs_en_su_attempt_all ua,
                    igs_he_verify_data_t t,
                    igs_he_st_unt_vs_all hunt,
                    igs_as_su_stmptout_all uao
              WHERE t.person_id = ua.person_id
                AND ua.unit_cd = hunt.unit_cd (+)
                AND ua.version_number = hunt.version_number(+)
                AND uao.person_id = ua.person_id
                AND uao.course_cd = ua.course_cd
                AND uao.uoo_id  = ua.uoo_id
                AND uao.finalised_outcome_ind  = 'Y'
                AND ua.unit_attempt_status IN ('ENROLLED','DISCONTIN','COMPLETED')
                AND uao.outcome_dt BETWEEN g_he_submsn_header.enrolment_start_date AND g_he_submsn_header.enrolment_end_date
                AND hunt.hesa_st_unt_vs_id IS NULL -- only get modules with no HESA details
              );

          -- Delete the temporarily stored student records
          DELETE FROM IGS_HE_VERIFY_DATA_T
            WHERE person_id IS NOT NULL;

      END IF; -- Module Return


      /********* Log Summary of Missing HESA Records *********/
      IF SUBSTR(g_he_submsn_return.record_id,4,2) = '13' THEN

          -- Get count of missing Unit HESA Records
          SELECT COUNT(DISTINCT unit_cd || u_version_number)
           INTO l_count
            FROM igs_he_verify_data_t
           WHERE unit_flag = 'N';

          -- Log Summary of Module Results
          fnd_message.set_name('IGS','IGS_HE_VERIFY_MISS_UNIT');
          fnd_message.set_token('MISSING',l_count);
          fnd_file.put_line(fnd_file.log,fnd_message.get());

      ELSE


          -- Get count of missing Program HESA Records
          SELECT COUNT(DISTINCT course_cd || crv_version_number)
            INTO l_count
            FROM igs_he_verify_data_t
           WHERE prog_flag = 'N';

          -- Log Summary of Program Results
          fnd_message.set_name('IGS','IGS_HE_VERIFY_MISS_PROG');
          fnd_message.set_token('MISSING',l_count);
          fnd_file.put_line(fnd_file.log,fnd_message.get());

          -- Get count of missing POOUS HESA Records
          SELECT COUNT(DISTINCT course_cd || crv_version_number || cal_type || location_cd || attendance_mode || attendance_type || unit_set_cd || us_version_number)
            INTO l_count
            FROM igs_he_verify_data_t
           WHERE poous_flag = 'N';

          -- Log Summary of POOUS Results
          fnd_message.set_name('IGS','IGS_HE_VERIFY_MISS_POOUS');
          fnd_message.set_token('MISSING',l_count);
          fnd_file.put_line(fnd_file.log,fnd_message.get());

          -- Get count of missing or incomplete SPA HESA Records
          SELECT COUNT(DISTINCT person_id || course_cd)
            INTO l_count
            FROM igs_he_verify_data_t
           WHERE spa_flag = 'N' OR qualaim_flag = 'N' OR sin_flag = 'N';

          -- Log Summary of POOUS Results
          fnd_message.set_name('IGS','IGS_HE_VERIFY_MISS_SPA');
          fnd_message.set_token('MISSING',l_count);
          fnd_file.put_line(fnd_file.log,fnd_message.get());

          -- Get count of missing or incomplete SPA HESA Records
          SELECT COUNT(DISTINCT person_id || course_cd || unit_set_cd || us_version_number)
            INTO l_count
            FROM igs_he_verify_data_t
           WHERE susa_flag = 'N';

          -- Log Summary of POOUS Results
          fnd_message.set_name('IGS','IGS_HE_VERIFY_MISS_SUSA');
          fnd_message.set_token('MISSING',l_count);
          fnd_file.put_line(fnd_file.log,fnd_message.get());

      END IF;

       EXCEPTION
        WHEN OTHERS THEN

           --Close any open cursors
           IF c_award_qualaim%ISOPEN THEN
               CLOSE c_award_qualaim;
           END IF;

           IF c_get_spa%ISOPEN THEN
               CLOSE c_get_spa;
           END IF;

           IF c_get_yop%ISOPEN THEN
               CLOSE c_get_yop;
           END IF;

           IF c_get_prog%ISOPEN THEN
               CLOSE c_get_prog;
           END IF;

           IF c_get_poous%ISOPEN THEN
               CLOSE c_get_poous;
           END IF;

           IF c_prog_type%ISOPEN THEN
               CLOSE c_prog_type;
           END IF;

           IF c_alternate_id%ISOPEN THEN
               CLOSE c_alternate_id;
           END IF;

           IF c_enr_su%ISOPEN THEN
               CLOSE c_enr_su;
           END IF;

           Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
           Fnd_Message.Set_Token('NAME','igs_he_verify_setup_pkg.check_HESA_data - ' || SQLERRM);
           fnd_file.put_line(fnd_file.log, fnd_message.get);
           App_Exception.Raise_Exception;

  END check_HESA_data;





  PROCEDURE verify_return (errbuf                     OUT NOCOPY VARCHAR2,
                           retcode                    OUT NOCOPY NUMBER,
                           p_submission_name          IN  VARCHAR2,
                           p_sub_rtn_id               IN  NUMBER,
                           p_check_HESA_details       IN  VARCHAR2,
                           p_check_field_associations IN  VARCHAR2) IS
  /******************************************************************
   Created By      : Jonathan Baber
   Date Created By : 23-Nov-05
   Purpose         : Main Function
                     Calls check_HESA_data and check_associations
                     depending on corresponding flags
   Known limitations,enhancements,remarks:
   Change History
   Who       When         What
   anwest    13-FEB-2006  Bug# 4950285 R12 Disable OSS Mandate
  *******************************************************************/

      -- Get extract run details
      CURSOR c_extract_dtls IS
      SELECT rtn.submission_name,
             rtn.user_return_subclass,
             rtn.return_name,
             rtn.record_id,
             shd.enrolment_start_date,
             shd.enrolment_end_date,
             shd.offset_days,
             NVL(shd.apply_to_atmpt_st_dt,'N') apply_to_atmpt_st_dt
        FROM igs_he_submsn_header shd,
             igs_he_submsn_return rtn
       WHERE rtn.sub_rtn_id = p_sub_rtn_id
         AND rtn.submission_name = shd.submission_name;

      l_request_id                     NUMBER;

  BEGIN

      --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
      IGS_GE_GEN_003.SET_ORG_ID;

      -- Get extract details
      -- Store in global variable
      OPEN c_extract_dtls;
      FETCH c_extract_dtls INTO g_he_submsn_return.submission_name,
                                g_he_submsn_return.user_return_subclass,
                                g_he_submsn_return.return_name,
                                g_he_submsn_return.record_id,
                                g_he_submsn_header.enrolment_start_date,
                                g_he_submsn_header.enrolment_end_date,
                                g_he_submsn_header.offset_days,
                                g_he_submsn_header.apply_to_atmpt_st_dt;
      CLOSE c_extract_dtls;


      -- Log Header
      fnd_message.set_name('IGS','IGS_HE_PROC_SUBM');
      fnd_message.set_token('SUBMISSION_NAME',g_he_submsn_return.submission_name);
      fnd_message.set_token('USER_RETURN_SUBCLASS',g_he_submsn_return.user_return_subclass);
      fnd_message.set_token('RETURN_NAME',g_he_submsn_return.return_name);
      fnd_message.set_token('ENROLMENT_START_DATE',g_he_submsn_header.enrolment_start_date);
      fnd_message.set_token('ENROLMENT_END_DATE',g_he_submsn_header.enrolment_end_date);
      fnd_file.put_line(fnd_file.log,fnd_message.get());


      -- Delete Temp Table
      DELETE FROM IGS_HE_VERIFY_DATA_T;

      -- Check HESA details of COMBINED/STUDENT or MODULE return
      IF p_check_HESA_details = 'Y'
        AND SUBSTR(g_he_submsn_return.record_id,4,2) <> '18' THEN
         check_HESA_data(g_he_submsn_return.submission_name, g_he_submsn_return.user_return_subclass, g_he_submsn_return.return_name);
      END IF;


      -- Check field associations of given extract
      IF p_check_field_associations = 'Y' THEN
          check_associations(g_he_submsn_return.user_return_subclass);
      END IF;


      COMMIT;

      -- Submit Report Log
      fnd_message.set_name('IGS','IGS_HE_VERIFY_REPORT_SUB');
      fnd_message.set_token('DATE',TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
      fnd_file.put_line(fnd_file.log,fnd_message.get());


      -- Submit the Report
      l_request_id := NULL ;
      l_request_id := Fnd_Request.Submit_Request
                          ( 'IGS',
                            'IGSHES03',
                            'Verify HESA Return Report',
                            NULL,
                            FALSE,
                            g_he_submsn_return.submission_name,
                            g_he_submsn_return.user_return_subclass,
                            g_he_submsn_return.return_name,
                            p_check_HESA_details,
                            p_check_field_associations);

      EXCEPTION
       WHEN OTHERS THEN

          --Close any open cursors
          IF c_extract_dtls%ISOPEN THEN
              CLOSE c_extract_dtls;
          END IF;

          ROLLBACK;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','igs_he_verify_setup_pkg.verify_setup - ' ||SQLERRM);
          errbuf := fnd_message.get;
          fnd_file.put_line(fnd_file.log, errbuf);
          retcode := 2;
          App_Exception.Raise_Exception;

  END verify_return;


END igs_he_verify_return_pkg ;

/
