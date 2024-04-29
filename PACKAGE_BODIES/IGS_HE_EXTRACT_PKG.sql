--------------------------------------------------------
--  DDL for Package Body IGS_HE_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_EXTRACT_PKG" AS
/* $Header: IGSHE9AB.pls 120.8 2006/05/02 22:39:01 jtmathew ship $ */

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
   g_he_poous                             igs_he_poous%ROWTYPE;
   g_pe_person                            igs_pe_person%ROWTYPE;
   g_he_ad_dtl                            igs_he_ad_dtl%ROWTYPE;

   g_records_found                        BOOLEAN := FALSE;

   g_prog_rec_flag                        BOOLEAN := FALSE;
   g_prog_type_rec_flag                   BOOLEAN := FALSE;

   g_awd_table                            igs_he_extract_fields_pkg.awd_table;

   /*----------------------------------------------------------------------
   This procedures writes onto the log file
   ----------------------------------------------------------------------*/
   PROCEDURE write_to_log(p_message    IN VARCHAR2)
   IS
   BEGIN

      Fnd_File.Put_Line(Fnd_File.Log, p_message);

   END write_to_log;

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
   ----------------------------------------------------------------------*/
   PROCEDURE log_error
             (p_he_ext_run_exceptions  IN OUT NOCOPY igs_he_ext_run_excp%ROWTYPE)
   IS
   PRAGMA AUTONOMOUS_TRANSACTION;

   l_rowid            VARCHAR2(30) := NULL;

   BEGIN

      Igs_He_Ext_Run_Excp_Pkg.Insert_Row
          (X_Rowid              => l_rowid,
          X_Ext_Exception_Id    => p_he_ext_run_exceptions.ext_exception_id,
          X_Extract_Run_Id      => p_he_ext_run_exceptions.Extract_Run_Id,
          X_Person_Id           => p_he_ext_run_exceptions.Person_Id,
          X_Person_Number       => p_he_ext_run_exceptions.Person_Number,
          X_Course_Cd           => p_he_ext_run_exceptions.Course_Cd,
          X_Crv_Version_Number  => p_he_ext_run_exceptions.Crv_Version_Number,
          X_Unit_Cd             => p_he_ext_run_exceptions.Unit_Cd,
          X_Uv_Version_Number   => p_he_ext_run_exceptions.Uv_Version_Number,
          X_Line_Number         => p_he_ext_run_exceptions.Line_Number,
          X_Field_Number        => p_he_ext_run_exceptions.Field_Number,
          X_Exception_Reason    => p_he_ext_run_exceptions.Exception_Reason);

      -- Commit this insert. Since its an autonomous transaction
      -- it will not affect the main transaction.
      COMMIT;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_PKG.log_error');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

   END log_error;

   -- created by jtmathew
   -- used to filter out students whose awards are not conferred
   -- between the correct award conferral dates.
   FUNCTION validate_award_conferral_dates (p_std_awd_cmp_ind   IN igs_en_spa_awd_aim.complete_ind%TYPE,
                                            p_std_awd_conf_dt   IN igs_en_spa_awd_aim.conferral_date%TYPE,
                                            p_awd_conf_start_dt OUT NOCOPY igs_he_submsn_awd.award_start_date%TYPE,
                                            p_awd_conf_end_dt   OUT NOCOPY igs_he_submsn_awd.award_end_date%TYPE)
            RETURN BOOLEAN
   IS

   -- Only to be run if prog type award conferral dates exist for submission
   -- i.e. g_prog_type_rec_flag is TRUE
   CURSOR c_prog_type IS
   SELECT course_type
   FROM   igs_ps_ver_all
   WHERE  course_cd = g_en_stdnt_ps_att.course_cd
   AND    version_number = g_en_stdnt_ps_att.version_number;

   l_prog_type         igs_ps_ver_all.course_type%TYPE;
   l_awd_conf_start_dt igs_he_submsn_awd.award_start_date%TYPE;
   l_awd_conf_end_dt   igs_he_submsn_awd.award_end_date%TYPE;
   l_valid             BOOLEAN;

   BEGIN

     p_awd_conf_start_dt := g_he_submsn_header.enrolment_start_date;
     p_awd_conf_end_dt   := g_he_submsn_header.enrolment_end_date;
     l_valid             := FALSE;

     IF ( g_en_stdnt_ps_att.commencement_dt <= g_he_submsn_header.enrolment_end_date
          AND ( g_en_stdnt_ps_att.discontinued_dt  IS NULL OR  g_en_stdnt_ps_att.discontinued_dt >= g_he_submsn_header.enrolment_start_date )
          AND (g_en_stdnt_ps_att.course_rqrmnts_complete_dt IS NULL OR  g_en_stdnt_ps_att.course_rqrmnts_complete_dt >= g_he_submsn_header.enrolment_start_date)
        ) THEN
        l_valid := TRUE;
     END IF;


     IF NOT l_valid
     THEN

         -- If student has a conferral date
         IF p_std_awd_cmp_ind = 'Y' AND p_std_awd_conf_dt IS NOT NULL THEN


             IF g_prog_type_rec_flag = TRUE
             THEN
               -- If there are award conferral dates specified at the program type
               -- level only, then check if any relate to this particular student program attempt
                 OPEN c_prog_type;
                 FETCH c_prog_type INTO l_prog_type;
                 CLOSE c_prog_type;

                 igs_he_extract_fields_pkg.get_awd_conferral_dates(g_awd_table,
                                                                   g_he_ext_run_dtls.submission_name,
                                                                   g_prog_rec_flag,
                                                                   g_prog_type_rec_flag,
                                                                   g_en_stdnt_ps_att.course_cd,
                                                                   l_prog_type,
                                                                   g_he_submsn_header.enrolment_start_date,
                                                                   g_he_submsn_header.enrolment_end_date,
                                                                   p_awd_conf_start_dt,
                                                                   p_awd_conf_end_dt);

             ELSE
                -- If there are award conferral dates specified at the program level only,
                -- then check if any relate to this particular student program attempt
                igs_he_extract_fields_pkg.get_awd_conferral_dates(g_awd_table,
                                                                  g_he_ext_run_dtls.submission_name,
                                                                  g_prog_rec_flag,
                                                                  g_prog_type_rec_flag,
                                                                  g_en_stdnt_ps_att.course_cd,
                                                                  NULL,
                                                                  g_he_submsn_header.enrolment_start_date,
                                                                  g_he_submsn_header.enrolment_end_date,
                                                                  p_awd_conf_start_dt,
                                                                  p_awd_conf_end_dt);
             END IF;

             IF p_std_awd_conf_dt BETWEEN p_awd_conf_start_dt AND p_awd_conf_end_dt THEN
                 l_valid := TRUE;
             ELSE
                 l_valid := FALSE;
             END IF;

         END IF;
     END IF;

     RETURN l_valid;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          -- Close Cursors
          IF c_prog_type%ISOPEN
          THEN
              CLOSE c_prog_type;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_PKG.validate_award_conferral_dates');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;


   END validate_award_conferral_dates;

   -- created by jbaber
   -- used when recalculating
   FUNCTION validate_recalc_params (p_extract_run_id       IN NUMBER,
                                    p_person_id            IN igs_en_stdnt_ps_att.person_id%TYPE,
                                    p_course_cd            IN igs_en_stdnt_ps_att.course_cd%TYPE)
            RETURN BOOLEAN
   IS

   CURSOR c_person(cp_person_id IN igs_en_stdnt_ps_att.person_id%TYPE) IS
   SELECT 'X'
   FROM   igs_he_ext_run_prms
   WHERE  extract_run_id = p_extract_run_id
   AND    only = cp_person_id
   AND    param_type = 'RECALC-PERSON';

   CURSOR c_program(cp_person_id IN igs_en_stdnt_ps_att.course_cd%TYPE) IS
   SELECT 'X'
   FROM   igs_he_ext_run_prms
   WHERE  extract_run_id = p_extract_run_id
   AND    only = cp_person_id
   AND    param_type = 'RECALC-PROGRAM';

   l_result  VARCHAR2(1) := NULL;

   BEGIN


      -- Check if this person ID should be recalculated
      OPEN c_person(p_person_id);
      FETCH c_person INTO l_result;
      CLOSE c_person;

      -- If so then return true
      IF l_result IS NOT NULL THEN
          RETURN TRUE;
      END IF;

      -- return false if course_cd is NULL
      -- possible for DLHE recalculation
      IF p_course_cd IS NULL THEN
          RETURN FALSE;
      END IF;

      -- Check if this course cd should be recalculated
      OPEN c_program(p_course_cd);
      FETCH c_program INTO l_result;
      CLOSE c_program;

      -- If so then return true
      IF l_result IS NOT NULL THEN
          RETURN TRUE;
      END IF;


      -- This SPA record doesn't meet the criteria of the recalculate form so exclude
      RETURN FALSE;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          -- Close Cursors
          IF c_person%ISOPEN
          THEN
              CLOSE c_person;
          END IF;

          IF c_program%ISOPEN
          THEN
              CLOSE c_program;
          END IF;


          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_PKG.validate_relalc_params');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

   END validate_recalc_params;



   --smaddali created split this procedure into 2 more procedures for bug 2350730
   --smaddali 11-dec-03   Modified for bug#3235753 , to replace system date comparision with hesa submission period
   --jbaber   19-Jan-06   Support for dynamic person ID groups for bug 3693367
   FUNCTION validate_params (p_extract_run_id       IN NUMBER)
            RETURN BOOLEAN
   IS
   -- Changed the cursor to remove DECODE for bug,3179585
   CURSOR c_prm IS
   SELECT param_type,
          exclude,
          only
   FROM   igs_he_ext_run_prms
   WHERE  extract_run_id = p_extract_run_id
   AND    (exclude IS NOT NULL
   OR     only IS NOT NULL)
   AND param_type IN ('PSN_IDENT_GROUP', 'PSN_ID')
   ORDER BY param_type;

   -- Changed the cursor to replace the multi org view with igs_pe_prsid_grp_mem_all for bug,3179585
   -- smaddali modified this cursor to select group_cd instead of group_id for bug2391473
   --smaddali modified this cursor to add new parameter p_group_cd for bug 2436567
   -- smaddali modified this cursor to get records which are effective in the HESA submission period, bug#3235753
   CURSOR c_psn_grp
          (p_person_id            NUMBER ,
           p_group_cd             VARCHAR2,
           cp_enrl_start_dt      igs_he_submsn_header.enrolment_start_date%TYPE,
           cp_enrl_end_dt        igs_he_submsn_header.enrolment_end_date%TYPE) IS
   SELECT a.group_cd
   FROM   igs_pe_persid_group a ,
          igs_pe_prsid_grp_mem_all b
   WHERE  b.person_id           = p_person_id
   AND    a.group_cd            = p_group_cd
   AND    ( b.Start_Date IS NULL OR b.Start_Date <= cp_enrl_end_dt)
   AND    ( b.End_Date IS NULL OR b.End_Date >= cp_enrl_start_dt )
   AND    a.group_id = b.group_id AND a.closed_ind = 'N' ;

   -- Determine type (static or dynamic) of persion id group
   CURSOR c_group_type (p_group_cd VARCHAR2) IS
   SELECT group_id, group_type
   FROM   igs_pe_persid_group_v
   WHERE  group_cd = p_group_cd;

   l_person_id               NUMBER;
   l_group_id                NUMBER;
   l_group_type              igs_pe_persid_group_v.group_type%TYPE;
   l_psn_group_cd            igs_pe_persid_group.group_cd%TYPE := NULL;

   BEGIN

      FOR l_prm IN c_prm
      LOOP
          IF l_prm.param_type = 'PSN_IDENT_GROUP'
          THEN

              -- Determine type (static or dynamic) of person id group
              OPEN c_group_type(NVL(l_prm.exclude ,l_prm.only));
              FETCH c_group_type INTO l_group_id, l_group_type;
              CLOSE c_group_type;

              IF l_group_type = 'STATIC' THEN

                  -- Person Identity Group
                  --smaddali added new parameter p_group_cd to this cursor for bug 2436567
                  l_psn_group_cd    := NULL;
                  OPEN  c_psn_grp(g_pe_person.person_id , NVL(l_prm.exclude ,l_prm.only),
                                  g_he_submsn_header.enrolment_start_date,
                                  g_he_submsn_header.enrolment_end_date );
                  FETCH c_psn_grp INTO l_psn_group_cd;
                  CLOSE c_psn_grp;

                  IF  l_psn_group_cd IS NOT NULL
                  AND l_prm.exclude IS NOT NULL
                  THEN
                      -- User does not want this Person Group
                      RETURN FALSE;

                  ELSIF l_prm.only IS NOT NULL
                  AND   l_psn_group_cd IS NULL
                  THEN
                      -- User want only this Person Group
                      RETURN FALSE;
                  END IF;

              ELSE


                  -- Is student in dynamic group?
                  l_person_id := IGS_PE_DYNAMIC_PERSID_GROUP.DYN_PIG_MEMBER(l_group_id,g_pe_person.person_id);

                  IF  l_person_id IS NOT NULL
                  AND l_prm.exclude IS NOT NULL
                  THEN
                      --User does not want this Person Group
                      RETURN FALSE;
                  ELSIF l_prm.only IS NOT NULL
                  AND   l_person_id IS NULL
                  THEN
                      --User want only this Person Group
                      RETURN FALSE;
                  END IF;


              END IF;

          ELSIF l_prm.param_type = 'PSN_ID'
          THEN
              -- Person Id
              IF  l_prm.exclude IS NOT NULL
              AND l_prm.exclude = g_pe_person.person_id
              THEN
                  -- User does not want this Person Id
                  RETURN FALSE;

              ELSIF l_prm.only IS NOT NULL
              AND   l_prm.only <> g_pe_person.person_id
              THEN
                  -- User wants only this Person Id
                  RETURN FALSE;
              END IF;

          END IF; -- Parameter Type

      END LOOP;

      -- All ok, pass back TRUE
      RETURN TRUE;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          -- Close Cursors
          IF c_psn_grp%ISOPEN
          THEN
              CLOSE c_psn_grp;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_PKG.validate_params');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

   END validate_params;


  --smaddali created this new procedure by splitting original procedure validate_params
  -- into 3 procedures for bug 2350730
  -- smaddali modified logic for checking PROGRAM_CATEGORY,PROGRAM_TYPE parameters for bug#3166126
  -- AYEDUBAT  29-04-04    Changed the cursor, c_drm to add a new condition to check
  --                       for approved intermissions, if approval is required for Bug, 3494224
  -- jbaber    30-11-04    Removed c_drm, using isDormant function instead for bug# 4037237

   FUNCTION validate_params1 (p_extract_run_id       IN NUMBER)
            RETURN BOOLEAN
   IS
   CURSOR c_prm IS
   SELECT param_type,
          DECODE(exclude, 'YES', 'Y',
                          'NO', 'N',
                          exclude) exclude,
          DECODE(only, 'YES', 'Y',
                       'NO', 'N',
                       only) only
   FROM   igs_he_ext_run_prms
   WHERE  extract_run_id = p_extract_run_id
   AND    (exclude IS NOT NULL
   OR     only IS NOT NULL)
   AND param_type IN ('PROGRAM' ,'DORMANT','VISIT_EXCHANGE','POST_CODE' )
   ORDER BY param_type;

   CURSOR c_specst
         (p_person_id               igs_he_ad_dtl.person_id%TYPE,
          p_admission_appl_number   igs_he_ad_dtl.admission_appl_number%TYPE,
          p_nominated_course_cd     igs_he_ad_dtl.nominated_course_cd%TYPE ,
          p_sequence_number         igs_he_ad_dtl.sequence_number%TYPE) IS
   SELECT special_student_cd
   FROM   igs_he_ad_dtl_all
   WHERE  person_id             = p_person_id
   AND    admission_appl_number = p_admission_appl_number
   AND    nominated_course_cd   = p_nominated_course_cd
   AND    sequence_number       = p_sequence_number;


   l_course_cat              igs_ps_categorise.course_cat%TYPE ;
   l_course_group_cd         igs_ps_grp_mbr.course_group_cd%TYPE  ;
   l_hesa_special_student    igs_he_code_map_val.map1%TYPE ;
   l_ad_special_student      igs_he_code_map_val.map1%TYPE ;
   l_dummy                   VARCHAR2(50);
   l_dormant                 BOOLEAN := FALSE;

           --smaddali added these cursors for bug#3166126
           -- check if exclude / only parameters are setup for Prog cat
           CURSOR c_prg_cat_exst IS
           SELECT exclude,  only
           FROM   igs_he_ext_run_prms
           WHERE  extract_run_id = p_extract_run_id
           AND param_type = 'PROGRAM_CATEGORY' ;
           c_prg_cat_exst_rec  c_prg_cat_exst%ROWTYPE ;

           -- check if exclude / only parameters are setup for Prog group
           CURSOR c_prg_grp_exst IS
           SELECT exclude,  only
           FROM   igs_he_ext_run_prms
           WHERE  extract_run_id = p_extract_run_id
           AND param_type = 'PROGRAM_GROUP' ;
           c_prg_grp_exst_rec  c_prg_grp_exst%ROWTYPE ;

           -- Check if the passed program belongs to an excluded Program category
           CURSOR c_prg_cat_excl
                  (p_course_cd            VARCHAR2,
                   p_version_number       NUMBER ) IS
           SELECT 'X'
           FROM   igs_ps_categorise_all
           WHERE  course_cd      = p_course_cd
           AND    version_number = p_version_number
           AND    course_cat IN  ( SELECT exclude FROM   igs_he_ext_run_prms
                                   WHERE  extract_run_id = p_extract_run_id
                                   AND    exclude IS NOT NULL
                                   AND    param_type ='PROGRAM_CATEGORY') ;
           -- Check if the passed program belongs to any ONLY Program category
           CURSOR c_prg_cat_only
                  (p_course_cd            VARCHAR2,
                   p_version_number       NUMBER ) IS
           SELECT 'X'
           FROM   igs_ps_categorise_all
           WHERE  course_cd      = p_course_cd
           AND    version_number = p_version_number
           AND    course_cat IN ( SELECT only FROM   igs_he_ext_run_prms
                                   WHERE  extract_run_id = p_extract_run_id
                                   AND    only IS NOT NULL
                                   AND    param_type ='PROGRAM_CATEGORY') ;

           -- Check if the passed program belongs to an excluded Program group
           CURSOR c_prg_grp_excl
                  (p_course_cd            VARCHAR2,
                   p_version_number       NUMBER ) IS
           SELECT 'X'
           FROM   igs_ps_grp_mbr
           WHERE  course_cd      = p_course_cd
           AND    version_number = p_version_number
           AND    course_group_cd IN ( SELECT exclude FROM   igs_he_ext_run_prms
                                   WHERE  extract_run_id = p_extract_run_id
                                   AND    exclude IS NOT NULL
                                   AND param_type ='PROGRAM_GROUP') ;
           -- Check if the passed program  belongs to any ONLY Program group
           CURSOR c_prg_grp_only
                  (p_course_cd            VARCHAR2,
                   p_version_number       NUMBER ) IS
           SELECT 'X'
           FROM   igs_ps_grp_mbr
           WHERE  course_cd      = p_course_cd
           AND    version_number = p_version_number
           AND    course_group_cd IN ( SELECT only FROM   igs_he_ext_run_prms
                                   WHERE  extract_run_id = p_extract_run_id
                                   AND    only IS NOT NULL
                                   AND param_type ='PROGRAM_GROUP') ;
           -- end bug#3166126

   BEGIN

      FOR l_prm IN c_prm
      LOOP
          IF l_prm.param_type = 'PROGRAM'
          THEN
              -- Program
              IF  l_prm.exclude IS NOT NULL
              AND l_prm.exclude = g_en_stdnt_ps_att.course_cd
              THEN
                  -- User does not want this Course Code
                  RETURN FALSE;

              ELSIF l_prm.only IS NOT NULL
              AND   l_prm.only <> g_en_stdnt_ps_att.course_cd
              THEN
                  -- User wants only this Course Code
                  RETURN FALSE;
              END IF;

          ELSIF l_prm.param_type = 'DORMANT'
          THEN
              l_dormant := FALSE;

              -- Dormant
              l_dormant := igs_he_extract_fields_pkg.isDormant
                            (p_person_id        => g_en_stdnt_ps_att.person_id,
                             p_course_cd        => g_en_stdnt_ps_att.course_cd,
                             p_version_number   => g_en_stdnt_ps_att.version_number,
                             p_enrl_start_dt    => g_he_submsn_header.enrolment_start_date,
                             p_enrl_end_dt      => g_he_submsn_header.enrolment_end_date);

              IF  l_prm.exclude =  'Y'
              AND l_dormant
              THEN
                  -- User does not want Dormant Students
                  RETURN FALSE;

              ELSIF l_prm.only = 'Y'
              AND NOT l_dormant
              THEN
                  -- User wants only Dormant Student
                  RETURN FALSE;

              ELSIF SUBSTR(g_he_submsn_return.record_id,3,1) = '4'
              AND NOT l_dormant
              THEN
                  -- User wants only Dormant students
                  RETURN FALSE;
              END IF;


          ELSIF l_prm.param_type = 'VISIT_EXCHANGE'
          THEN
              l_ad_special_student      :=  NULL;
              l_hesa_special_student    := NULL;
              OPEN c_specst ( g_en_stdnt_ps_att.person_id,
                              g_en_stdnt_ps_att.adm_admission_appl_number,
                              g_en_stdnt_ps_att.adm_nominated_course_cd,
                              g_en_stdnt_ps_att.adm_sequence_number);
              FETCH c_specst INTO l_ad_special_student;
              CLOSE c_specst;

              -- Visiting Exchange

              igs_he_extract_fields_pkg.get_special_student
                  (p_ad_special_student    => l_ad_special_student,
                   p_spa_special_student   => g_he_st_spa.special_student,
                   p_oss_special_student   => l_dummy,
                   p_hesa_special_student  => l_hesa_special_student);

              IF  l_prm.exclude = 'Y'
              AND l_hesa_special_student IN ('3','4','5','6','7','8')
              THEN
                  -- User does not want Visiting / Exchange students
                  RETURN FALSE;

              ELSIF l_prm.only = 'Y'
              AND   (l_hesa_special_student NOT IN ('3','4','5','6','7','8')
              OR    l_hesa_special_student IS NULL)
              THEN
                  -- User wants only Visiting / Exchange students
                  RETURN FALSE;

              ELSIF SUBSTR(g_he_submsn_return.record_id,3,1) = '3'
              AND   (l_hesa_special_student NOT IN ('3','4','5','6','7','8')
              OR    l_hesa_special_student IS NULL)
              THEN
                  -- User wants only Visiting / Exchange students
                  RETURN FALSE;

              END IF;


          ELSIF l_prm.param_type = 'POST_CODE'
          THEN
              -- Postcode
              IF l_prm.exclude IS NOT NULL
              AND l_prm.exclude = g_he_st_spa.postcode
              THEN
                  -- User does not want this postcode
                  RETURN FALSE;

              ELSIF l_prm.only IS NOT NULL
              AND  (g_he_st_spa.postcode IS NULL
              OR    l_prm.only <> g_he_st_spa.postcode)
              THEN
                  -- User wants only this postcode
                  RETURN FALSE;
              END IF;
          END IF; -- Parameter Type

      END LOOP;

      --smaddali moved group parameters program_group and Program_category check out of the LOOP for bug 3166126
      -- PROGRAM CATEGORY CHECK
      c_prg_cat_exst_rec := NULL ;
      l_course_cat := NULL ;

      OPEN c_prg_cat_exst ;
      FETCH c_prg_cat_exst INTO c_prg_cat_exst_rec ;
      CLOSE c_prg_cat_exst;
      -- check if exclude Program category parameters are setup for this extract
      IF c_prg_cat_exst_rec.exclude IS NOT NULL THEN
              -- If the passed program  belongs to an EXCLUDE Program category then exclude this SPA record
              OPEN  c_prg_cat_excl (g_en_stdnt_ps_att.course_cd,
                               g_en_stdnt_ps_att.version_number );
              FETCH c_prg_cat_excl INTO l_course_cat;
              CLOSE c_prg_cat_excl;

              IF  l_course_cat IS NOT NULL
              THEN
                  -- User does not want this course category
                  RETURN FALSE;
              END IF ;
       -- check if only Program category parameters are setup for this extract
      ELSIF c_prg_cat_exst_rec.only IS NOT NULL THEN
              -- If the passed program  does not belong to any ONLY Program category then exclude this SPA record
              OPEN  c_prg_cat_only (g_en_stdnt_ps_att.course_cd,
                               g_en_stdnt_ps_att.version_number );
              FETCH c_prg_cat_only INTO l_course_cat;
              CLOSE c_prg_cat_only;

              IF  l_course_cat IS NULL
              THEN
                  -- User does not want this course category
                  RETURN FALSE;
              END IF ;
      END IF ;
      --      PROGRAM CATEGORY CHECK

      -- PROGRAM GROUP
      c_prg_grp_exst_rec  := NULL ;
      l_course_group_cd  := NULL ;
      OPEN c_prg_grp_exst ;
      FETCH c_prg_grp_exst INTO c_prg_grp_exst_rec ;
      CLOSE c_prg_grp_exst;

      -- check if 'exclude' Program group parameters are setup for this extract
      IF c_prg_grp_exst_rec.exclude IS NOT NULL THEN
              -- If the passed program  belongs to an EXCLUDE Program group then exclude this SPA record
              OPEN  c_prg_grp_excl (g_en_stdnt_ps_att.course_cd,
                               g_en_stdnt_ps_att.version_number  );
              FETCH c_prg_grp_excl INTO l_course_group_cd;
              CLOSE c_prg_grp_excl ;
              IF  l_course_group_cd IS NOT NULL
              THEN
                  -- User does not want this course Group
                  RETURN FALSE;
              END IF ;
      -- check if 'only' Program group parameters are setup for this extract
      ELSIF c_prg_grp_exst_rec.only IS NOT NULL THEN
              -- If the passed program  does not belong to any ONLY Program group then exclude this SPA record
              OPEN  c_prg_grp_only (g_en_stdnt_ps_att.course_cd,
                               g_en_stdnt_ps_att.version_number  );
              FETCH c_prg_grp_only INTO l_course_group_cd;
              CLOSE c_prg_grp_only ;
              IF  l_course_group_cd IS NULL
              THEN
                  -- User does not want this course Group
                  RETURN FALSE;
              END IF ;
      END IF ;
      --      PROGRAM GROUP CHECK

      -- All ok, pass back TRUE
      RETURN TRUE;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          -- Close Cursors
          IF c_prg_grp_excl%ISOPEN
          THEN
              CLOSE c_prg_grp_excl;
          END IF;

          IF  c_prg_grp_only%ISOPEN
          THEN
              CLOSE c_prg_grp_only;
          END IF;

          IF c_prg_cat_only%ISOPEN
          THEN
              CLOSE c_prg_cat_only;
          END IF;

          IF  c_prg_cat_excl%ISOPEN
          THEN
              CLOSE c_prg_cat_excl;
          END IF;



          IF c_specst%ISOPEN
          THEN
              CLOSE c_specst;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_PKG.validate_params1');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

   END validate_params1;

  --smaddali created this new procedure by splitting original procedure validate_params
  -- into 3 procedures for bug 2350730
   -- smaddali modified logic for checking ORG-UNIT parameter for bug#3166126
   -- jtmathew modified call to get_funding_src to add spa parameter for bug#3962575
   FUNCTION validate_params2 (p_extract_run_id       IN NUMBER)
            RETURN BOOLEAN
   IS
   CURSOR c_prm IS
   SELECT param_type,
          DECODE(exclude, 'YES', 'Y',
                          'NO', 'N',
                          exclude) exclude,
          DECODE(only, 'YES', 'Y',
                       'NO', 'N',
                       only) only
   FROM   igs_he_ext_run_prms
   WHERE  extract_run_id = p_extract_run_id
   AND    (exclude IS NOT NULL
   OR     only IS NOT NULL)
   AND param_type IN ( 'ORG_UNIT' ,'PROGRAM_YEAR','OUTSIDE_UK','FE')
   ORDER BY param_type;

   l_hesa_study_location     igs_he_code_map_val.map1%TYPE ;
   l_dummy                   VARCHAR2(50);

   --smaddali added these variable declarations for bug 2483523
   l_oss_value_64  igs_he_ex_rn_dat_fd.value%TYPE   ;
   l_hesa_value_64  igs_he_ex_rn_dat_fd.value%TYPE  ;
   l_oss_value_65  igs_he_ex_rn_dat_fd.value%TYPE  ;
   l_hesa_value_65  igs_he_ex_rn_dat_fd.value%TYPE  ;
   l_oss_value_6  igs_he_ex_rn_dat_fd.value%TYPE  ;
   l_hesa_value_6  igs_he_ex_rn_dat_fd.value%TYPE  ;
   -- smaddali added these parameters for bug#3166126
   l_only_exists BOOLEAN;
   l_only_matches BOOLEAN ;

   BEGIN
     -- smaddali added initialisation of variables  for bug#3166126
     l_only_exists := FALSE;
     l_only_matches := FALSE ;

      FOR l_prm IN c_prm
      LOOP

          IF l_prm.param_type = 'ORG_UNIT'
          THEN
              -- Organization Unit
              IF  l_prm.exclude IS NOT NULL
              AND l_prm.exclude = g_ps_ver.responsible_org_unit_cd
              THEN
                  -- User does not want this Organisation Unit
                  RETURN FALSE;

              ELSIF l_prm.only IS NOT NULL THEN
                  l_only_exists := TRUE ;
                  IF   l_prm.only = g_ps_ver.responsible_org_unit_cd
                  THEN
                      -- If this program's Org unit matches with an only Organisation Unit then select this person
                      l_only_matches := TRUE ;
                  END IF;
              END IF;


          ELSIF l_prm.param_type = 'PROGRAM_YEAR'
          THEN
              -- Program Year
              IF  l_prm.exclude IS NOT NULL
              AND l_prm.exclude = g_as_su_setatmpt.unit_set_cd
              THEN
                  -- User does not want this Program Year
                  RETURN FALSE;

              ELSIF l_prm.only IS NOT NULL
              AND   l_prm.only <> g_as_su_setatmpt.unit_set_cd
              THEN
                  -- User wants only this Program Year
                  RETURN FALSE;
              END IF;

          ELSIF l_prm.param_type = 'OUTSIDE_UK'
          THEN
              -- Outside UK
              l_hesa_study_location     := NULL;
              igs_he_extract_fields_pkg.get_study_location
                  (p_susa_study_location    => g_he_en_susa.study_location,
                   p_poous_study_location   => g_he_poous.location_of_study,
                   p_prg_study_location     => g_he_st_prog.location_of_study,
                   p_oss_study_location     => l_dummy,
                   p_hesa_study_location    => l_hesa_study_location);

              IF  l_prm.exclude = 'Y'
              AND l_hesa_study_location = '7'
              THEN
                  -- User does not want students outside UK
                  RETURN FALSE;

              ELSIF l_prm.only = 'Y'
              AND   (l_hesa_study_location <> '7'
              OR    l_hesa_study_location IS NULL)
              THEN
                  -- User wants only students outside UK
                  RETURN FALSE;
              END IF;


          ELSIF l_prm.param_type = 'FE'
          THEN
              -- smaddali added this code to calculate field 6 , bug 2483523 ,
              -- if the value of field 6 is '2' then student is not an FE student
              -- FE Student Marker
              -- First get the Funding Source
              -- smaddali Modifed call to add new parameter for hefd208 build , bug#2717751
              l_oss_value_64    := NULL;
              l_hesa_value_64   := NULL;
              l_oss_value_65    := NULL;
              l_hesa_value_65   := NULL;
              l_oss_value_6     := NULL;
              l_hesa_value_6    := NULL;
              igs_he_extract_fields_pkg.get_funding_src
              (p_course_cd             => g_en_stdnt_ps_att.course_cd ,
               p_version_number        => g_en_stdnt_ps_att.version_number,
               p_spa_fund_src          => g_en_stdnt_ps_att.funding_source,
               p_poous_fund_src        => g_he_poous.funding_source,
               p_oss_fund_src          => l_oss_value_64,
               p_hesa_fund_src         => l_hesa_value_64 );

             -- Next get the Fundability Code
             -- smaddali 11-dec-03   Modified for bug#3235753 , added 2 new parameters
             igs_he_extract_fields_pkg.get_fundability_cd
              (p_person_id             => g_en_stdnt_ps_att.person_id,
               p_susa_fund_cd          => g_he_en_susa.fundability_code,
               p_spa_funding_source    => g_en_stdnt_ps_att.funding_source,
               p_poous_fund_cd         => g_he_poous.fundability_cd,
               p_prg_fund_cd           => g_he_st_prog.fundability,
               p_prg_funding_source    => l_oss_value_64,
               p_oss_fund_cd           => l_oss_value_65,
               p_hesa_fund_cd          => l_hesa_value_65 ,
               p_enrl_start_dt         =>  g_he_submsn_header.enrolment_start_date,
               p_enrl_end_dt           =>  g_he_submsn_header.enrolment_end_date);

            -- Now get the FE Student Marker
            igs_he_extract_fields_pkg.get_fe_stdnt_mrker
              (p_spa_fe_stdnt_mrker    =>  g_he_st_spa.fe_student_marker,
               p_fe_program_marker     =>  g_he_st_prog.fe_program_marker,
               p_funding_src           =>  l_oss_value_64,
               p_fundability_cd        =>  l_oss_value_65,
               p_oss_fe_stdnt_mrker    =>  l_oss_value_6,
               p_hesa_fe_stdnt_mrker   =>  l_hesa_value_6 );

              -- Further Education
              -- smaddali modified code to use l_hesa_value_6 instead of g_he_st_spa.fe_student_marker
              -- or g_he_st_prog.fe_program_marker to determine if the student is an fe student ,for bug 2483523
              IF  l_prm.exclude = 'Y'
              AND l_hesa_value_6 <> '2'
              THEN
                  -- User does not want Visiting / Exchange students
                  RETURN FALSE;

              ELSIF l_prm.only = 'Y'
              AND  NVL(l_hesa_value_6,'2') = '2'
              THEN
                  -- User wants only Visiting / Exchange students
                  RETURN FALSE;

              ELSIF SUBSTR(g_he_submsn_return.record_id,3,1) = '2'
              AND   NVL(l_hesa_value_6,'2') = '2'
              THEN
                  -- User wants only Visiting / Exchange students
                  RETURN FALSE;

              END IF;

          END IF; -- Parameter Type

      END LOOP;

      -- All ok, pass back TRUE
      -- If only parameters were setup but the current person's dlhe record status doesnot match any of them
      -- then exclude this person else include this person in this return
      IF l_only_exists AND NOT l_only_matches THEN
         RETURN FALSE ;
      ELSE
         RETURN TRUE;
      END IF;

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_PKG.validate_params2');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

   END validate_params2;



   /*----------------------------------------------------------------------
   This procedure deletes rows from tables before starting the
   process

   Because it uses table handlers, there might be a server
   performance issue as the number of rows being processed
   would be huge

   Parameters :
   p_extract_run_id     IN     The Extract Run Id
   p_line_number        IN     Line Number
   p_table_name         IN     Table Name
                               Values : INTERIM - Igs_He_Ext_Run_Interim
                                        LINE    - Igs_He_Ex_Rn_Dat_Ln
                                        FIELD   - Igs_He_Ex_Rn_Dat_Fd
                                        ERROR   - Igs_He_Ext_Run_Excp
   WHO:  AYEDUBAT
   WHAT: Removed the 'PROCEDURE delete_rows' as all the call to this procedure are placed
         with direct DMLS for bug,3179585
   ----------------------------------------------------------------------*/


   /*----------------------------------------------------------------------
   This procedure fetches the modules that need to be processed
   and inserts them into the temporary procesing table
   Parameters :
   p_extract_run_id     IN     The Extract Run Id
   --smaddali seperated the extract parameters validation into 3 different groups :person,
   --  program attempt and program,program year parameters for bug 2350730
   -- hence the procedure validate_params has been split into 3 procedures
   -- namely validate_params , validate_params1,validate_params2
   -- and calls to these procedures have been added in this procedure at appropriate places

   --Done as a part of HEFD101(2636897)
   --Bayadav  Included in the WHERE clause the graduated student also but who have not awarded ans the conferral_td is set
   --Outer join is to consider the graduation.conferraldt condition only in case the student have graduation rec .
   --The other students(not  graduated) should also be selected
   --smvk     03-Jun-2003   Bug # 2858436.Modified the cursor c_quaim to select open program awards only.
  16-DEC-02   Bayadav Included the conditions in the WHERE clause to consider the students who have been awarded in HESA period but must have comepleted the course earlier as a part of bug 2702117
  20-JAN-2003 Bayadav Included the validations to check if the alternate person id does not contains non-numeric characters for the person in context as a part of 2744808
  03-MAR-2003 bayadav Included check in c_encp  cursor to cehck for the Units
  sarakshi 26-Jun-2003  Enh#2930935,modified cursor c_encp to include unit section level
                        enrolled_credit_points if exists else unit level credit points
  dsridhar 04-Jul-03   Bug No:3079731. Changed the order of setting the tokens for the message IGS_HE_INVALID_PER_ID.
  smaddali 20-Oct-03   Modified procedure for bug#3172980 , skip students whose api person id> 8 digits
  ayedubat 14-Nov-03   Modified the procedure to improve the performance for Bug, 3179585
  smaddali 05-Dec-03   Modified cursors c_get_yop, c_get_spa to add condition complete_ind=Y , for HECR210 build, bug#2874542
  smaddali 10-Dec-03   Modified logic to get Term record details for HECR214 - Term based fees enhancement, bug#3291656
  smaddali 14-Jan-04   Modified cursor c_qulaim for bug#3360646
  ayedubat 09-Mar-04   Modified logic to check the condition, l_std_inst.person_id <> l_prev_person_id only
                       when logging the error message in the log file for Bug, 3491096
  jbaber   04-Nov-04   Modified c_get_spa for HE354 - Program Transfer
                       Replace c_inact_st with c_enr_su for bug 3810280
  slaport  31-Jan-05   Modified cursor c_alternate_id for HE358 to ignore logically deleted records.
  jbaber   15-Apr-05   Modified c_get_spa cursor to include records where future_date_trans_flag = N or S as per bug #4179106
  jtmathew 27-Jan-06   Modified c_get_spa cursor to include award conferral date parameters
  jbaber   15-Mar-06   Added p_recalculate parameter for HE365 - Extract Rerun
  ----------------------------------------------------------------------*/

  PROCEDURE get_students (p_extract_run_id IN NUMBER, p_recalculate IN BOOLEAN) IS

  --smaddali modified where clause for comparing the enrolment dates for bug 2415632
  --dsridhar modified the table form igs_pe_person to igs_pe_person_base_v for the bug 2911738
  --Removed the cursor, c_get_stins for Bug, 3179585
  --smaddali modified where clause for comparing the enrolment dates for bug 2415632
  --smaddali added field hspa.fe_student_marker for bug 2452834
  --Removed the cursor to remove person_id and person_number parameters for Bug, 3179585
  --jbaber added check for exclude flag and removed calendar types for HE305
  CURSOR c_get_spa (
    p_submission_name      igs_he_submsn_header.submission_name%TYPE,
    p_return_name          igs_he_submsn_return.return_name%TYPE,
    p_user_return_subclass igs_he_submsn_return.user_return_subclass%TYPE,
    p_enrl_start_dt        DATE,
    p_enrl_end_dt          DATE,
    p_awd_conf_start_dt    DATE,
    p_awd_conf_end_dt      DATE)  IS
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
          sca.course_rqrmnt_complete_ind,
          sca.course_rqrmnts_complete_dt,
          sca.adm_admission_appl_number,
          sca.adm_nominated_course_cd,
          sca.adm_sequence_number,
          sca.course_attempt_status,
          sca.funding_source,
          hspa.student_inst_number,
          hspa.student_qual_aim,
          hspa.return_type,
          hspa.postcode,
          hspa.special_student,
          hspa.fe_student_marker ,
          enawd.complete_ind,
          enawd.conferral_date
   FROM   igs_en_stdnt_ps_att_all sca,
          igs_he_st_spa_all       hspa,
          igs_he_st_prog_all      hprog,
          igs_en_spa_awd_aim      enawd,
          hz_parties              pe
   WHERE  sca.person_id          = hspa.person_id
   AND    sca.course_cd          = hspa.course_cd
   AND    sca.course_cd          = hprog.course_cd (+)
   AND    sca.version_number     = hprog.version_number (+)
   AND    NVL(hprog.exclude_flag, 'N') = 'N'
   AND    NVL(hspa.exclude_flag, 'N') = 'N'
   AND    NVL(sca.future_dated_trans_flag,'N') IN ('N','S')
   AND    sca.student_confirmed_ind = 'Y'
   AND    hspa.person_id         = enawd.person_id(+)
   AND    hspa.course_cd         = enawd.course_cd(+)
   AND    sca.person_id          = pe.party_id
   AND  ( ( sca.commencement_dt     <= p_enrl_end_dt
                          AND ( sca.discontinued_dt  IS NULL OR  sca.discontinued_dt   >= p_enrl_start_dt )
                                AND (sca.course_rqrmnts_complete_dt IS NULL OR
                                     sca.course_rqrmnts_complete_dt >= p_enrl_start_dt
                                    )
          )
          OR
          (
            enawd.complete_ind  = 'Y' AND
                 (enawd.conferral_date BETWEEN p_awd_conf_start_dt AND p_awd_conf_end_dt))
        )
  ORDER BY sca.person_id, hspa.student_inst_number, discontinued_dt DESC,
           course_rqrmnts_complete_dt DESC,  sca.commencement_dt DESC ;

  -- smaddali modified cursor for bug#3360646, to remove the check for default award
  CURSOR c_quaim
       (p_course_cd            igs_he_st_spa.course_cd%TYPE,
        p_version_number       igs_he_st_spa.version_number%TYPE)
   IS
   SELECT award_cd
   FROM   igs_ps_award
   WHERE  course_cd      = p_course_cd
   AND    version_number = p_version_number
   AND    closed_ind     = 'N' ;

 --smaddali modified where clause for comparing the enrolment dates for bug 2415632
 -- smaddali 27-desc-2002 modified cursor to check for conferral date , bug 2702100
   CURSOR c_get_yop
       (p_person_id            igs_he_st_spa.person_id%TYPE,
        p_course_cd            igs_he_st_spa.course_cd%TYPE,
        p_enrl_start_dt        DATE,
        p_enrl_end_dt          DATE,
        p_awd_conf_start_dt    DATE,
        p_awd_conf_end_dt      DATE)
   IS
   SELECT DISTINCT susa.unit_set_cd,
          susa.us_version_number,
          susa.sequence_number,
          susa.selection_dt,
          susa.end_dt,
          susa.rqrmnts_complete_ind,
          susa.rqrmnts_complete_dt,
          husa.study_location ,
          husa.fte_perc_override,
          husa.credit_value_yop1
   FROM  igs_as_su_setatmpt  susa,
         igs_he_en_susa      husa,
         igs_en_unit_set     us,
         igs_en_unit_set_cat susc,
         igs_en_spa_awd_aim enawd,
         igs_en_stdnt_ps_att_all sca
   WHERE susa.person_id = sca.person_id
   AND   susa.course_cd = sca.course_cd
   AND   sca.person_id           = enawd.person_id(+)
   AND   sca.course_cd           = enawd.course_cd(+)
   AND   susa.unit_set_cd        = husa.unit_set_cd
   AND   susa.us_version_number  = husa.us_version_number
   AND   susa.person_id          = husa.person_id
   AND   susa.course_cd          = husa.course_cd
   AND   susa.sequence_number    = husa.sequence_number
   AND   susa.unit_set_cd        = us.unit_set_cd
   AND   susa.us_version_number  = us.version_number
   AND   us.unit_set_cat         = susc.unit_set_cat
   AND   susa.person_id          = p_person_id
   AND   susa.course_cd          = p_course_cd
   AND   susc.s_unit_set_cat     = 'PRENRL_YR'
   -- the program attempt is overlapping with the submission period and the yop is also overlapping with the submission period
   AND   ( (  sca.commencement_dt     <= p_enrl_end_dt AND
             (sca.discontinued_dt  IS NULL OR  sca.discontinued_dt   >= p_enrl_start_dt ) AND
             (sca.course_rqrmnts_complete_dt IS NULL OR  sca.course_rqrmnts_complete_dt >= p_enrl_start_dt ) AND
              susa.selection_dt           <= p_enrl_end_dt AND
             (susa.end_dt  IS NULL OR susa.end_dt   >= p_enrl_start_dt )  AND
             (susa.rqrmnts_complete_dt IS NULL OR susa.rqrmnts_complete_dt >= p_enrl_start_dt)
           )
           OR
              -- the yop has completed before the start of the submission period
              -- AND the program attempt has completed before the end of the submission period
              -- AND an award has been conferred between the NVL(award conferral dates, submission period)
           (  susa.rqrmnts_complete_dt < p_enrl_start_dt  AND
              sca.course_rqrmnts_complete_dt <= p_enrl_end_dt  AND
              enawd.complete_ind = 'Y' AND
              enawd.conferral_date BETWEEN p_awd_conf_start_dt AND p_awd_conf_end_dt
           )
         )
   ORDER BY susa.rqrmnts_complete_dt DESC, susa.end_dt DESC,  susa.selection_dt DESC;

   -- smaddali Modifed cursor to fetch funding_source for hefd208 build , bug#2717751
   CURSOR c_get_crse
       (p_course_cd           igs_he_st_spa.course_cd%TYPE,
        p_crv_version_number  igs_he_st_spa.version_number%TYPE,
        p_cal_type            igs_ps_ofr_opt.cal_type%TYPE,
        p_attendance_mode     igs_ps_ofr_opt.attendance_mode%TYPE,
        p_attendance_type     igs_ps_ofr_opt.attendance_type%TYPE,
        p_location_cd         igs_ps_ofr_opt.location_cd%TYPE,
        p_unit_set_cd         igs_he_poous_all.unit_set_cd%TYPE,
        p_us_version_number   igs_he_poous_all.us_version_number%TYPE)
   IS
   SELECT crv.title,
          crv.std_annual_load,
          crv.contact_hours,
          crv.govt_special_course_type,
          crv.responsible_org_unit_cd,
          hpr.location_of_study ,
          hpr.return_type,
          hpr.default_award,
          Nvl(hpr.program_calc,'N') ,
          hpr.fe_program_marker,
          hpud.location_of_study,
          hpud.credit_value_yop1,
          hpud.fte_intensity  ,
          hpud.funding_source
   FROM   igs_ps_ver       crv,
          igs_he_st_prog   hpr,
          igs_he_poous     hpud
   WHERE  crv.course_cd             = hpr.course_cd
   AND    crv.version_number        = hpr.version_number
   AND    crv.course_cd             = p_course_cd
   AND    crv.version_number        = p_crv_version_number
   AND    hpud.course_cd            = crv.course_cd
   AND    hpud.crv_version_number   = crv.version_number
   AND    hpud.cal_type             = p_cal_type
   AND    hpud.attendance_mode      = p_attendance_mode
   AND    hpud.attendance_type      = p_attendance_type
   AND    hpud.location_cd          = p_location_cd
   AND    hpud.unit_set_cd          = p_unit_set_cd
   AND    hpud.us_version_number    = p_us_version_number;


    -- jbaber created this cursor for bug 3810280
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
    AND TRUNC(enrolled_dt) <= p_enrolment_end_date;

    -- Changed the cursor to remove the parameter, p_id_type and replacing with the hard coded values
    -- like HUSID, UCASID,'GTTRID', 'NMASID' and 'SWASID' for bug,315
    -- smaddali modified cursor to select length for bug 3172980
    -- smaddali modified this cursor to get records which are effective in the HESA submission period, bug#3235753
   CURSOR c_alternate_id
         ( p_person_id             IN  igs_pe_person.person_id%TYPE,
           cp_enrl_start_dt      igs_he_submsn_header.enrolment_start_date%TYPE,
           cp_enrl_end_dt        igs_he_submsn_header.enrolment_end_date%TYPE) IS
   SELECT api_person_id,person_id_type, LENGTH(api_person_id) api_length
   FROM   igs_pe_alt_pers_id
   WHERE  pe_person_id   = p_person_id
   AND    person_id_type IN ('HUSID', 'UCASID', 'GTTRID', 'NMASID', 'SWASID')
   AND    Start_Dt <= cp_enrl_end_dt
   AND    ( End_Dt IS NULL OR End_Dt >= cp_enrl_start_dt )
   AND    (End_Dt IS NULL OR Start_Dt <> End_Dt)
   ORDER BY person_id_type, Start_Dt DESC ;
   l_prev_pid_type igs_pe_alt_pers_id.person_id_type%TYPE := 'X' ;

   l_awd_min_dt           DATE;
   l_awd_max_dt           DATE;
   l_awd_conf_start_dt    DATE;
   l_awd_conf_end_dt      DATE;

   l_enrolled_su c_enr_su%ROWTYPE ;
   l_valid                         BOOLEAN := TRUE;
   l_rowid                         VARCHAR2(50);
   l_ext_interim_id                NUMBER;
   l_award_cd                      igs_ps_award.award_cd%TYPE;
   l_rec_count                     NUMBER := 0;
   l_message                       VARCHAR2(2000);
   l_return_type                   VARCHAR2(3);
   l_api_person_id                 igs_pe_alt_pers_id.api_person_id%TYPE;
   l_id                            NUMBER;
   l_prev_person_id NUMBER := -1;
   l_prev_student_inst_number  VARCHAR2(100) := '-1';

      -- smaddali added following cursors for HECR214 - term based fees enhancement build, bug#3291656

      -- Get the latest Term record for the Leavers,where the student left date lies between term start and end dates
      CURSOR c_term1_lev( cp_person_id  igs_en_spa_terms.person_id%TYPE,
                          cp_course_cd  igs_en_spa_terms.program_cd%TYPE,
                          cp_lev_dt  DATE ) IS
      SELECT  tr.program_version , tr.acad_cal_type, tr.location_cd, tr.attendance_mode, tr.attendance_type
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
                          cp_lev_dt             DATE ,
                          cp_enrl_start_dt      igs_he_submsn_header.enrolment_start_date%TYPE,
                          cp_enrl_end_dt        igs_he_submsn_header.enrolment_end_date%TYPE) IS
      SELECT  tr.program_version , tr.acad_cal_type, tr.location_cd, tr.attendance_mode, tr.attendance_type
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
                          cp_course_cd          igs_en_spa_terms.program_cd%TYPE  ,
                          cp_enrl_start_dt      igs_he_submsn_header.enrolment_start_date%TYPE,
                          cp_enrl_end_dt        igs_he_submsn_header.enrolment_end_date%TYPE) IS
      SELECT  tr.program_version , tr.acad_cal_type, tr.location_cd, tr.attendance_mode, tr.attendance_type
      FROM  igs_en_spa_terms tr , igs_ca_inst_all ca
      WHERE  tr.term_cal_type = ca.cal_type AND
             tr.term_sequence_number = ca.sequence_number AND
             tr.person_id = cp_person_id AND
             tr.program_cd = cp_course_cd AND
             ca.start_dt BETWEEN cp_enrl_start_dt AND cp_enrl_end_dt
      ORDER BY  ca.start_dt DESC;
      c_term_con_rec    c_term_con%ROWTYPE ;
      l_lev_dt   igs_en_stdnt_ps_att_all.discontinued_dt%TYPE ;

   BEGIN

      -- printing datetimestamp for monitoring performance
      fnd_message.set_name('IGS','IGS_HE_ST_PROC_TIME');
      fnd_message.set_token('PROCEDURE', 'GET_STUDENTS');
      fnd_message.set_token('TIMESTAMP',TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
      fnd_file.put_line(fnd_file.log, fnd_message.get);

      fnd_message.set_name('IGS','IGS_HE_STD_RETURN');
      fnd_file.put_line(fnd_file.log,fnd_message.get());

      l_awd_min_dt          := NULL;
      l_awd_max_dt          := NULL;

      -- get the award conferral details
      igs_he_extract_fields_pkg.get_awd_dtls(g_he_ext_run_dtls.submission_name,
                                             g_awd_table,
                                             g_prog_rec_flag, g_prog_type_rec_flag);

      -- get the minimum award conferral start date and maximum award conferral end date
      igs_he_extract_fields_pkg.get_min_max_awd_dates(g_he_ext_run_dtls.submission_name,
                                                      g_he_submsn_header.enrolment_start_date,
                                                      g_he_submsn_header.enrolment_end_date,
                                                      l_awd_min_dt,
                                                      l_awd_max_dt);

      FOR l_std_inst IN c_get_spa( g_he_ext_run_dtls.submission_name, g_he_ext_run_dtls.return_name,
                                   g_he_ext_run_dtls.user_return_subclass, g_he_submsn_header.enrolment_start_date,
                                   g_he_submsn_header.enrolment_end_date,
                                   l_awd_min_dt, l_awd_max_dt)    LOOP

        IF (l_std_inst.person_id <> l_prev_person_id) OR (l_std_inst.student_inst_number <> l_prev_student_inst_number) THEN

          -- smaddali added initialisation of loop varables , bug#3166126
          g_en_stdnt_ps_att     := NULL;
          g_he_st_spa           := NULL;
          g_as_su_setatmpt      := NULL;
          g_he_en_susa          := NULL;
          g_he_st_prog          := NULL;
          g_ps_ver              := NULL;
          g_he_poous            := NULL;
          g_pe_person           := NULL;
          g_he_ad_dtl           := NULL;
          l_awd_conf_start_dt   := NULL;
          l_awd_conf_end_dt     := NULL;

          g_en_stdnt_ps_att.person_id                  :=  l_std_inst.person_id;
          g_en_stdnt_ps_att.course_cd                  :=  l_std_inst.course_cd;
          g_en_stdnt_ps_att.version_number             :=  l_std_inst.version_number;
          g_en_stdnt_ps_att.location_cd                :=  l_std_inst.location_cd ;
          g_en_stdnt_ps_att.attendance_mode            :=  l_std_inst.attendance_mode;
          g_en_stdnt_ps_att.attendance_type            :=  l_std_inst.attendance_type;
          g_en_stdnt_ps_att.cal_type                   :=  l_std_inst.sca_cal_type;
          g_en_stdnt_ps_att.commencement_dt            :=  l_std_inst.commencement_dt ;
          g_en_stdnt_ps_att.discontinued_dt            :=  l_std_inst.discontinued_dt;
          g_en_stdnt_ps_att.course_rqrmnt_complete_ind :=  l_std_inst.course_rqrmnt_complete_ind;
          g_en_stdnt_ps_att.course_rqrmnts_complete_dt :=  l_std_inst.course_rqrmnts_complete_dt;
          g_en_stdnt_ps_att.adm_admission_appl_number  :=  l_std_inst.adm_admission_appl_number;
          g_en_stdnt_ps_att.adm_nominated_course_cd    :=  l_std_inst.adm_nominated_course_cd;
          g_en_stdnt_ps_att.adm_sequence_number        :=  l_std_inst.adm_sequence_number;
          g_en_stdnt_ps_att.course_attempt_status      :=  l_std_inst.course_attempt_status;
          g_en_stdnt_ps_att.funding_source             :=  l_std_inst.funding_source;
          g_he_st_spa.student_inst_number              :=  l_std_inst.student_inst_number;
          g_he_st_spa.student_qual_aim                 :=  l_std_inst.student_qual_aim;
          g_he_st_spa.return_type                      :=  l_std_inst.return_type;
          g_he_st_spa.postcode                         :=  l_std_inst.postcode;
          g_he_st_spa.special_student                  :=  l_std_inst.special_student;
          g_he_st_spa.fe_student_marker                :=  l_std_inst.fe_student_marker ;

          g_pe_person.person_number := l_std_inst.person_number;
          g_pe_person.person_id := l_std_inst.person_id ;

          -- Flag to keep track of whether a SPA record has passed all validations
          -- if not, processing should continue with the next SPA record.
          l_valid := TRUE;



          IF NOT validate_award_conferral_dates (l_std_inst.complete_ind,
                                                 l_std_inst.conferral_date,
                                                 l_awd_conf_start_dt,
                                                 l_awd_conf_end_dt) THEN
                     l_valid := FALSE;
          END IF;

          -- Validate record with recalculate parameters
          IF l_valid AND p_recalculate THEN

            IF NOT validate_recalc_params(p_extract_run_id, g_en_stdnt_ps_att.person_id, g_en_stdnt_ps_att.course_cd) THEN
                -- exclude this record
                l_valid := FALSE;
            END IF;

          END IF;


          IF l_valid THEN

              -- validate person , person id group parameters
              --these validations have been seperated from the other validations
              -- by smaddali for bug 2350730
              IF NOT validate_params( p_extract_run_id) THEN
                    -- exclude this record
                         l_valid := FALSE ;
              END IF;

          END IF;

          -- for doing the following validations only once for a Person and not for every program attempt of the person
          IF l_valid THEN

             l_prev_pid_type := 'X' ;
             --TO check that the alternate person id's if present for the person is number (i.e it does not contains non-numeric character)
             -- Changed the logic to replace individual calls with in the loop for bug,315
             FOR alternate_id_rec IN c_alternate_id( l_std_inst.person_id,
                                                g_he_submsn_header.enrolment_start_date,
                                                g_he_submsn_header.enrolment_end_date) LOOP
                 -- smaddali added this check for bug#3235753 , because the cursor will bring more than one
                 -- alternate personid record for each person id type, the first record being the valid record.
                 -- so we need to skip this validation from the 2nd record of each person_id_type
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
                           -- added the check l_std_inst.person_id <> l_prev_person_id for Bug, 3491096
                           IF l_std_inst.person_id <> l_prev_person_id THEN
                               fnd_message.set_name('IGS','IGS_HE_INVALID_PER_ID');
                               fnd_Message.Set_Token('PERSON_ID_TYPE',alternate_id_rec.person_id_type);
                               fnd_Message.Set_Token('PERSON',l_std_inst.person_number);
                               fnd_file.put_line(fnd_file.log,fnd_message.get());
                           END IF;

                           --In case the alternate person id contains non-numeric characters ,then log the message and
                           -- exclude this record from furtehr processing
                           l_valid := FALSE ;
                       END;

                       -- smaddali  20-oct-03  added code to log error when alternate person id  > 8 digits. for bug#3172980
                       -- Modified this validation to exclude the HUSID Type for bug, 3296711
                       IF alternate_id_rec.person_id_type <> 'HUSID' AND alternate_id_rec.api_length > 8 THEN
                           -- added the check l_std_inst.person_id <> l_prev_person_id for Bug, 3491096
                           IF l_std_inst.person_id <> l_prev_person_id THEN
                             fnd_message.set_name('IGS','IGS_HE_PERSID_MORE_DIGITS');
                             fnd_Message.Set_Token('PIDTYPE',alternate_id_rec.person_id_type);
                             fnd_Message.Set_Token('PERSON',l_std_inst.person_number);
                             fnd_file.put_line(fnd_file.log,fnd_message.get());
                           END IF;
                             --In case the alternate person id contains more than 8 digits ,then log the message and
                           -- exclude this record from furtehr processing
                           l_valid := FALSE ;
                       END IF;

                   END IF; -- validate only latest Person id type record of each type
             END LOOP;

          END IF; -- if valid

          -- smaddali moved the initialisation if these variables here because l_prev_person_id is  being used by the
          -- alternate person id check also.
          l_prev_person_id := l_std_inst.person_id;
          l_prev_student_inst_number := l_std_inst.student_inst_number;

          --smaddali seperated validations for program attempt parameters ,for bug 2350730
          -- Use the Extract Run Parameters to check if the
          -- record satisfies the program_group,program_category,program,dormant parameter criteria
          IF l_valid
          THEN

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
                         OPEN c_term1_lev (g_en_stdnt_ps_att.person_id, g_en_stdnt_ps_att.course_cd, l_lev_dt );
                         FETCH c_term1_lev INTO c_term1_lev_rec ;
                         IF c_term1_lev%NOTFOUND THEN
                             -- Get the latest term record just before the Leaving date
                             c_term2_lev_rec    := NULL ;
                             OPEN c_term2_lev(g_en_stdnt_ps_att.person_id,
                                                g_en_stdnt_ps_att.course_cd,
                                                l_lev_dt,
                                                g_he_submsn_header.enrolment_start_date,
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
                         END IF ;
                         CLOSE c_term1_lev ;

                -- Else the student is continuing student then get the latest term rec
                -- where the Term start date falls within the HESA Submission start and end dates
                ELSE
                        -- Get the latest term record which falls within the FTE period and term start date > commencement dt
                        c_term_con_rec  := NULL ;
                        OPEN c_term_con(g_en_stdnt_ps_att.person_id,
                                        g_en_stdnt_ps_att.course_cd,
                                        g_he_submsn_header.enrolment_start_date,
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
                        END IF ;
                        CLOSE c_term_con ;
                END IF ; -- if student is leaving / continuing

              IF NOT validate_params1 (p_extract_run_id)
              THEN
                  -- Exclude this record
                  l_valid := FALSE;
              END IF;

          END IF; -- Record is still valid

          -- jbaber added this validation for bug 3810280
          -- Make sure current SPA is enrolled
          IF l_valid THEN
              -- if the current SPA is not enrolled, check associated unit attempts
              IF NOT g_en_stdnt_ps_att.course_attempt_status = 'ENROLLED' THEN
                  l_enrolled_su := NULL;
                  OPEN c_enr_su(g_en_stdnt_ps_att.person_id,
                                g_en_stdnt_ps_att.course_cd,
                                g_he_submsn_header.enrolment_end_date) ;
                  FETCH c_enr_su INTO l_enrolled_su ;
                  IF c_enr_su%NOTFOUND THEN
                      l_valid := FALSE;
                  END IF;
                  CLOSE c_enr_su;
            END IF;
          END IF;

          -- Do all the checks that can be done using the
          -- information got so far.
          IF l_valid
          THEN

              -- Check offset days
              IF g_he_submsn_header.offset_days IS NOT NULL
              THEN
                  -- smaddali modified for bug 2394560 , to apply the offset to spa start date instead of the hesa submission start date
                  IF g_he_submsn_header.apply_to_atmpt_st_dt = 'Y'
                  AND g_en_stdnt_ps_att.discontinued_dt  < (g_en_stdnt_ps_att.commencement_dt + g_he_submsn_header.offset_days)
                  THEN
                      -- Exclude this record
                      l_valid := FALSE;

                  END IF;
              END IF; -- Offset days entered as parameter

          END IF; -- Record is still valid

          IF l_valid
          THEN
              -- Check that the course has qualification aim
              IF g_he_st_spa.student_qual_aim IS NULL
              THEN
                  l_award_cd := NULL ;
                  OPEN c_quaim (g_en_stdnt_ps_att.course_cd,
                                g_en_stdnt_ps_att.version_number);
                  FETCH c_quaim INTO l_award_cd;
                  CLOSE c_quaim;

                  IF l_award_cd IS NULL
                  THEN
                      -- Exclude this record
                      l_valid := FALSE;
                  END IF;
              END IF; -- Qual Aim check

          END IF; -- Record is still valid

          -- For the next set of checks we need the Year of Program
          -- details
          IF l_valid
          THEN
              -- Get Year of Program details
              OPEN  c_get_yop
                  (g_en_stdnt_ps_att.person_id,
                   g_en_stdnt_ps_att.course_cd,
                   g_he_submsn_header.enrolment_start_date,
                   g_he_submsn_header.enrolment_end_date,
                   l_awd_conf_start_dt,
                   l_awd_conf_end_dt);

              FETCH c_get_yop INTO g_as_su_setatmpt.unit_set_cd,
                       g_as_su_setatmpt.us_version_number,
                       g_as_su_setatmpt.sequence_number,
                       g_as_su_setatmpt.selection_dt,
                       g_as_su_setatmpt.end_dt,
                       g_as_su_setatmpt.rqrmnts_complete_ind,
                       g_as_su_setatmpt.rqrmnts_complete_dt,
                       g_he_en_susa.study_location ,
                       g_he_en_susa.fte_perc_override,
                       g_he_en_susa.credit_value_yop1;

              IF c_get_yop%NOTFOUND
              THEN
                  -- If Year of Program details were not found, then log error
                  l_valid := FALSE;

                  Fnd_Message.Set_Name('IGS', 'IGS_HE_EXT_YOP_NOT_FOUND');
                  l_message := Fnd_Message.Get;

                  -- Initialize Record to Null.
                  g_he_ext_run_except := NULL;

                  -- Populate the required fields.
                  g_he_ext_run_except.extract_run_id      := p_extract_run_id;
                  g_he_ext_run_except.exception_reason    := l_message;
                  g_he_ext_run_except.person_id           :=
                                               g_en_stdnt_ps_att.person_id;
                  g_he_ext_run_except.course_cd           :=
                                               g_en_stdnt_ps_att.course_cd;
                  -- smaddali modified this call to pass l_std_inst.version_number instead of g_en_stdnt_ps_att.version_number
                  -- as part of HECR214 build
                  g_he_ext_run_except.crv_version_number  :=
                                               l_std_inst.version_number;
                  g_he_ext_run_except.person_number       :=
                                               g_pe_person.person_number;

                  -- Call procedure to log error
                  log_error (g_he_ext_run_except);

              END IF; -- YOP record not found

              CLOSE c_get_yop;

          END IF; -- Record is still valid

          IF l_valid
          THEN
              -- Get the course details
              OPEN c_get_crse
                  (g_en_stdnt_ps_att.course_cd,
                   g_en_stdnt_ps_att.version_number,
                   g_en_stdnt_ps_att.cal_type,
                   g_en_stdnt_ps_att.attendance_mode,
                   g_en_stdnt_ps_att.attendance_type,
                   g_en_stdnt_ps_att.location_cd,
                   g_as_su_setatmpt.unit_set_cd,
                   g_as_su_setatmpt.us_version_number );
              -- smaddali Modifed cursor to fetch funding_source for hefd208 build , bug#2717751
              FETCH c_get_crse INTO
                        g_ps_ver.title,
                        g_ps_ver.std_annual_load,
                        g_ps_ver.contact_hours,
                        g_ps_ver.govt_special_course_type,
                        g_ps_ver.responsible_org_unit_cd,
                        g_he_st_prog.location_of_study ,
                        g_he_st_prog.return_type,
                        g_he_st_prog.default_award,
                        g_he_st_prog.program_calc ,
                        g_he_st_prog.fe_program_marker,
                        g_he_poous.location_of_study,
                        g_he_poous.credit_value_yop1,
                        g_he_poous.fte_intensity,
                        g_he_poous.funding_source ;

              IF c_get_crse%NOTFOUND
              THEN
                  -- If Course details were not found, then log error
                  l_valid := FALSE;

                  Fnd_Message.Set_Name('IGS', 'IGS_HE_EXT_CRSE_DTL_NOT_FOUND');
                  l_message := Fnd_Message.Get;

                  -- Initialize Record to Null.
                  g_he_ext_run_except := NULL;

                  -- Populate the required fields.
                  g_he_ext_run_except.extract_run_id      := p_extract_run_id;
                  g_he_ext_run_except.exception_reason    := l_message;
                  g_he_ext_run_except.person_id           :=
                                               g_en_stdnt_ps_att.person_id;
                  g_he_ext_run_except.course_cd           :=
                                               g_en_stdnt_ps_att.course_cd;
                  -- smaddali modified this call to pass l_std_inst.version_number instead of g_en_stdnt_ps_att.version_number
                  -- as part of HECR214 build
                  g_he_ext_run_except.crv_version_number  :=
                                               l_std_inst.version_number;
                  g_he_ext_run_except.person_number       :=
                                               g_pe_person.person_number;

                  -- Call procedure to log error
                  log_error (g_he_ext_run_except);

              END IF; -- Crse record not found

              CLOSE c_get_crse;

          END IF; -- Record is still valid

          -- Do the Reduced Return Type Checks..
          IF l_valid
          THEN
              l_return_type := NULL ;
              l_return_type := Nvl(Nvl(g_he_st_spa.return_type,
                                       g_he_st_prog.return_type),'0');

              IF SUBSTR(g_he_submsn_return.record_id,3,1) = '6'
              AND l_return_type <> '6'
              THEN
                  -- User wants only Welsh for adults
                  -- Exclude this record
                  l_valid := FALSE;

              ELSIF SUBSTR(g_he_submsn_return.record_id,3,1) = '1'
              AND l_return_type <> '1'
              THEN
                  -- User wants only Low Credit Bearing Courses
                  -- Exclude this record
                  l_valid := FALSE;

              ELSIF SUBSTR(g_he_submsn_return.record_id,3,1) = '5'
              THEN
                  -- User wants only Late Return
                  IF l_return_type = '5'
                  OR g_en_stdnt_ps_att.course_rqrmnts_complete_dt
                      BETWEEN  g_he_submsn_return.lrr_start_date
                                         AND g_he_submsn_return.lrr_end_date
                  THEN
                      -- Nothing, we need this record
                      NULL;
                  ELSE
                      -- Exclude this record
                      l_valid := FALSE;
                  END IF;

              ELSIF SUBSTR(g_he_submsn_return.record_id,3,1) = '0'
              THEN
                  -- Main Record
                  IF  l_return_type <> '0'
                  THEN
                      -- This record will be returned in a reduce return
                      -- separtely.
                      -- Since its return_type is initialized to 0
                      -- only those that the user has specifically marked
                      -- will get excluded.
                      -- Exclude this record
                      l_valid := FALSE;
                  END IF;
              END IF;
          END IF; -- Record is still valid

          -- validate the program_year,FE,outside_uk,org_unit Extract Run Parameters to check if the
          -- record satisfies the criteria
          --smaddali modified this call to call validate_params2 instead of validate_params for bug 2350730
          IF l_valid
          THEN
              IF NOT validate_params2 (p_extract_run_id)
              THEN
                  -- Exclude this record
                  l_valid := FALSE;
              END IF;

          END IF; -- Record is still valid

          -- This spa record has passed all validation checks
          -- Therefore it needs to be processed further
          -- Insert it into the temporary processing table
          IF l_valid
          THEN
              l_rowid := NULL;
              l_ext_interim_id := NULL ;
              -- smaddali modified this call to pass l_std_inst.version_number instead of g_en_stdnt_ps_att.version_number
              -- as part of HECR214 build
              igs_he_ext_run_interim_pkg.insert_row
                  (X_rowid                => l_rowid,
                   X_ext_interim_id       => l_ext_interim_id,
                   X_extract_run_id       => p_extract_run_id,
                   X_person_id            => g_en_stdnt_ps_att.person_id,
                   X_course_cd            => g_en_stdnt_ps_att.course_cd,
                   X_crv_version_number   => l_std_inst.version_number,
                   X_unit_cd              => NULL,
                   X_uv_version_number    => NULL,
                   X_student_inst_number  => g_he_st_spa.student_inst_number,
                   X_line_number          => NULL);

              g_records_found := TRUE;

          END IF;

        END IF ; -- End of Duplicate HSPA record Check

      END LOOP; -- For Each Person Id and Student Instance Number

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          -- Close open cursors
          IF c_quaim%ISOPEN
          THEN
              CLOSE c_quaim;
          END IF;

          IF c_get_yop%ISOPEN
          THEN
              CLOSE c_get_yop;
          END IF;

          IF c_get_crse%ISOPEN
          THEN
              CLOSE c_get_crse;
          END IF;

          IF c_alternate_id%ISOPEN
          THEN
               CLOSE c_alternate_id;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_PKG.get_students');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

   END get_students;

   /*----------------------------------------------------------------------
   This procedure fetches the modules that need to be processed
   and inserts them into the temporary procesing table
   Parameters :
   p_extract_run_id     IN     The Extract Run Id

   ----------------------------------------------------------------------*/
   PROCEDURE get_modules (p_extract_run_id      IN NUMBER)
   IS

   --smaddali modified this cursor to add NVL 'N' to program_calc, also added ckeck that module_id is not null for bug 2425932
   CURSOR c_get_mod  (p_stdnt_extract_run_id     NUMBER)
   IS
   SELECT DISTINCT Nvl(a.override_value, a.value) module_id
   FROM   igs_he_ex_rn_dat_fd a,
          igs_he_ex_rn_dat_ln b,
          igs_he_st_prog      c
   WHERE  a.extract_run_id = b.extract_run_id
   AND    b.extract_run_id = p_stdnt_extract_run_id
   AND    b.course_cd      = c.course_cd
   AND    b.crv_version_number = c.version_number
   AND    NVL(c.program_calc,'N')   = 'N'
   AND    a.field_number BETWEEN 85 AND 100
   AND   NVL(a.override_value,a.value) IS NOT NULL ;

   CURSOR c_get_exclude_flag(cp_unit_cd         igs_he_st_unt_vs_all.unit_cd%TYPE,
                             cp_version_number  igs_he_st_unt_vs_all.version_number%TYPE) IS
   SELECT NVL(exclude_flag, 'N') exclude_flag
   FROM   igs_he_st_unt_vs_all
   WHERE  unit_cd = cp_unit_cd
   AND    version_number = cp_version_number;

   l_exclude                    igs_he_st_unt_vs_all.exclude_flag%TYPE;
   l_he_ext_run_interim         igs_he_ext_run_interim%ROWTYPE;
   l_rowid                      VARCHAR2(50);
   l_dot_position               NUMBER;

   BEGIN
      -- printing datetimestamp for monitoring performance
      fnd_message.set_name('IGS','IGS_HE_ST_PROC_TIME');
      fnd_message.set_token('PROCEDURE', 'GET_MODULES');
      fnd_message.set_token('TIMESTAMP',TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
      fnd_file.put_line(fnd_file.log, fnd_message.get);

     fnd_message.set_name('IGS','IGS_HE_MOD_RETURN');
     fnd_file.put_line(fnd_file.log,fnd_message.get());

      FOR l_mod IN c_get_mod (g_he_ext_run_dtls.student_ext_run_id)
      LOOP
          g_records_found := TRUE;
          l_he_ext_run_interim := NULL ;
          l_dot_position := NULL ;
          l_rowid := NULL ;

          -- Extract the Unit Cd and Version Number
          -- Module Id would be in format 'UNITABC.1'
          l_dot_position := INSTR(l_mod.module_id,'.') ;
          IF l_dot_position  > 0
          THEN
              l_he_ext_run_interim.unit_cd            := SUBSTR(l_mod.module_id, 1 ,
                                                         l_dot_position - 1);
              l_he_ext_run_interim.uv_version_number  := SUBSTR(l_mod.module_id,
                                                         l_dot_position + 1);
          ELSE
              l_he_ext_run_interim.unit_cd            := l_mod.module_id;
              l_he_ext_run_interim.uv_version_number  := 1;
          END IF;

          OPEN c_get_exclude_flag(l_he_ext_run_interim.unit_cd, l_he_ext_run_interim.uv_version_number);
          FETCH c_get_exclude_flag INTO l_exclude;
          CLOSE c_get_exclude_flag;

          IF l_exclude = 'N' THEN

              l_he_ext_run_interim.extract_run_id := p_extract_run_id;
              l_he_ext_run_interim.line_number    := NULL;

              igs_he_ext_run_interim_pkg.insert_row
                  (X_rowid                  => l_rowid,
                   X_ext_interim_id         => l_he_ext_run_interim.ext_interim_id,
                   X_extract_run_id         => l_he_ext_run_interim.extract_run_id,
                   X_person_id              => NULL,
                   X_course_cd              => NULL,
                   X_crv_version_number     => NULL,
                   X_unit_cd                => l_he_ext_run_interim.unit_cd,
                   X_uv_version_number      => l_he_ext_run_interim.uv_version_number,
                   X_student_inst_number    => NULL,
                   X_line_number            => l_he_ext_run_interim.line_number);

          END IF;

      END LOOP; -- c_get_mod

      EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_PKG.get_modules');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

   END get_modules;



 --smaddali created this procedure for validating dlhe record status , HEFD203 build, bug#2717745
  --  smaddali    16-oct-03    Modified the processing of dlhe_status parameters as part of bug#3166126
   FUNCTION validate_dlhe_status (p_extract_run_id       IN NUMBER,
                                  p_dlhe_record_status  igs_he_stdnt_dlhe.dlhe_record_status%TYPE,
                                  p_popdlhe_flag        igs_he_stdnt_dlhe.popdlhe_flag%TYPE)
            RETURN BOOLEAN
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :   This procedure validates dlhe record status
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
  ***************************************************************/

       --  Get all the DLHE parameters setup for this extract run id
       CURSOR c_dlhe_prm IS
       SELECT param_type,
          exclude,
          only
       FROM   igs_he_ext_run_prms
       WHERE  extract_run_id = p_extract_run_id
       AND    (exclude IS NOT NULL
       OR     only IS NOT NULL)
       AND param_type IN ('DLHE','POPDLHE');

           -- smaddali added these parameters for bug#3166126
           l_only_exists BOOLEAN;
           l_only_matches BOOLEAN ;

   BEGIN
     -- smaddali added initialisation of variables  for bug#3166126
     l_only_exists := FALSE;
     l_only_matches := FALSE ;

      FOR l_dlhe_prm IN c_dlhe_prm
      LOOP

          IF l_dlhe_prm.param_type = 'DLHE' THEN

              IF  l_dlhe_prm.exclude IS NOT NULL AND p_dlhe_record_status = l_dlhe_prm.exclude
              THEN
                  -- User does not want this dlhe_record_status
                  RETURN FALSE;

              -- smaddali modified logic  for bug#3166126
              ELSIF l_dlhe_prm.only IS NOT NULL THEN
                 -- if atleast 1 only parameter has been setup then set the respective flag
                 l_only_exists := TRUE;
                 IF  p_dlhe_record_status = l_dlhe_prm.only THEN
                     -- If current person's dlhe record status is equal to one of the
                     -- Only parameters then this person should be included in the return
                     l_only_matches := TRUE;
                 END IF ;
              END IF;

          ELSIF l_dlhe_prm.param_type = 'POPDLHE' THEN

              IF l_dlhe_prm.exclude IS NOT NULL
              AND UPPER(SUBSTR(l_dlhe_prm.exclude,1,1)) = UPPER(p_popdlhe_flag) THEN
                  -- user does not want this record
                  RETURN FALSE;

              ELSIF l_dlhe_prm.only IS NOT NULL
              AND UPPER(SUBSTR(l_dlhe_prm.only,1,1)) <> UPPER(p_popdlhe_flag) THEN
                  -- user does not want this record
                  RETURN FALSE;

              END IF;

          END IF; -- parameter type


      END LOOP;

      -- All ok, pass back TRUE
      -- If only parameters were setup but the current person's dlhe record status doesnot match any of them
      -- then exclude this person else include this person in this return
      IF l_only_exists AND NOT l_only_matches THEN
         RETURN FALSE;
      ELSE
         RETURN TRUE;
      END IF;

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);

          -- Close Cursors
          IF c_dlhe_prm%ISOPEN
          THEN
              CLOSE c_dlhe_prm;
          END IF;

          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_PKG.validate_dlhe_status');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
   END validate_dlhe_status;



   PROCEDURE get_dlhe (p_extract_run_id IN NUMBER,  p_recalculate IN BOOLEAN)
   IS
   /***************************************************************
   Created By           :       smaddali
   Date Created By      :       9-apr-03
   Purpose              :   This procedure fetches the dlhe records that need to be processed
             and inserts them into the temporary procesing table
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who         When           What
   jchakrab    20-Feb-2006    Modified for 4256498 - removed ORDER BY from c_get_dlhe query
   jbaber      15-Mar-2006    Added p_recalculate_flag for HE365 - Extract Rerun
  ***************************************************************/

       -- Get all the dlhe records belonging to all the qualifying periods in this submission return
       CURSOR c_get_dlhe ( p_submission_name      igs_he_submsn_header.submission_name%TYPE,
        p_return_name          igs_he_submsn_return.return_name%TYPE,
        p_user_return_subclass igs_he_submsn_return.user_return_subclass%TYPE )
       IS
       SELECT  dlhe.person_id , dlhe.dlhe_record_status, dlhe.popdlhe_flag
       FROM   igs_he_stdnt_dlhe dlhe,
          igs_he_sub_rtn_qual qual
       WHERE  qual.submission_name   = dlhe.submission_name
       AND    qual.return_name       = dlhe.return_name
       AND    qual.user_return_subclass  = dlhe.user_return_subclass
       AND    qual.qual_period_code  = dlhe.qual_period_code
       AND    qual.submission_name   = p_submission_name
       AND    qual.return_name       = p_return_name
       AND    qual.user_return_subclass  = p_user_return_subclass
       AND    qual.closed_ind = 'N';

       l_rowid                      VARCHAR2(50);
       l_ext_interim_id                NUMBER;

   BEGIN
      -- printing datetimestamp for monitoring performance
      fnd_message.set_name('IGS','IGS_HE_ST_PROC_TIME');
      fnd_message.set_token('PROCEDURE', 'GET_DLHE');
      fnd_message.set_token('TIMESTAMP',TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
      fnd_file.put_line(fnd_file.log, fnd_message.get);

     fnd_message.set_name('IGS','IGS_HE_DLHE_RETURN');
     fnd_file.put_line(fnd_file.log,fnd_message.get());

      -- loop thru each dlhe record and validate dlhe_record_status
      FOR g_he_stdnt_dlhe IN c_get_dlhe ( g_he_ext_run_dtls.submission_name, g_he_ext_run_dtls.return_name,
             g_he_ext_run_dtls.user_return_subclass )
      LOOP
          g_pe_person.person_id := g_he_stdnt_dlhe.person_id ;
          -- if dlhe_record_status is valid and person_id and person_id_group paramaters are validated
      -- then create an interim record
          IF  validate_dlhe_status( p_extract_run_id,g_he_stdnt_dlhe.dlhe_record_status, g_he_stdnt_dlhe.popdlhe_flag)
             AND validate_params( p_extract_run_id )
             -- jbaber added validation for recalculated extracts for HE365
             AND (NOT p_recalculate OR (p_recalculate AND validate_recalc_params(p_extract_run_id, g_he_stdnt_dlhe.person_id , NULL)))
             THEN

          l_ext_interim_id := NULL;
                  l_rowid  := NULL ;
          igs_he_ext_run_interim_pkg.insert_row
              (X_rowid                  => l_rowid,
               X_ext_interim_id         => l_ext_interim_id ,
               X_extract_run_id         => p_extract_run_id ,
               X_person_id              => g_he_stdnt_dlhe.person_id,
               X_course_cd              => NULL,
               X_crv_version_number     => NULL,
               X_unit_cd                => NULL,
               X_uv_version_number      => NULL,
               X_student_inst_number    => NULL,
               X_line_number            => NULL);
                  g_records_found := TRUE;

          END IF;

      END LOOP; -- c_get_dlhe

   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_PKG.get_dlhe');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

   END get_dlhe;



   /*----------------------------------------------------------------------
   This procedure processes the records that have been processed
   before but have been marked as requiring recalculation

   Parameters :
   p_extract_run_id     IN     The Extract Run Id
   ----------------------------------------------------------------------*/
   PROCEDURE get_marked_rows
          (p_extract_run_id      IN     igs_he_ext_run_dtls.extract_run_id%TYPE)

   IS
   /***************************************************************
   Created By           :       Bidisha S
   Date Created By      :      28-Jan-02
   Purpose              :      This procedure processes the records that have been processed
               before but have been marked as requiring recalculation
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
   smaddali 09-Apr-03   Modified for adding dlhe processing , HEFD203 build , bug#2717745
   jbaber   15-Mar-05   Do NOT delete recalculated fields for HE365
  ***************************************************************/

       CURSOR c_recalc_criteria IS
       SELECT 'X'
         FROM igs_he_ext_run_prms
        WHERE extract_run_id = p_extract_run_id
          AND param_type IN ('RECALC-PERSON', 'RECALC-PROGRAM');

       CURSOR c_mrk_row IS
       SELECT record_id,
          line_number,
          person_id,
          course_cd,
          manually_inserted,
          exclude_from_file,
          student_inst_number,
          crv_version_number,
          unit_cd,
          uv_version_number,
          recalculate_flag
       FROM   igs_he_ex_rn_dat_ln
       WHERE  extract_run_id = p_extract_run_id
       AND    manually_inserted = 'N'
       AND    (recalculate_flag = 'Y'
               OR person_id IN (SELECT only from igs_he_ext_run_prms WHERE param_type = 'RECALC-PERSON' AND extract_run_id = p_extract_run_id)
               OR course_cd IN (SELECT only from igs_he_ext_run_prms WHERE param_type = 'RECALC-PROGRAM'AND extract_run_id = p_extract_run_id));

       l_he_ext_run_interim         igs_he_ext_run_interim%ROWTYPE;
       l_rowid                      VARCHAR2(50);
       l_temp                       VARCHAR2(3);

   BEGIN
      -- printing datetimestamp for monitoring performance
      fnd_message.set_name('IGS','IGS_HE_ST_PROC_TIME');
      fnd_message.set_token('PROCEDURE', 'GET_MARKED_ROWS');
      fnd_message.set_token('TIMESTAMP',TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
      fnd_file.put_line(fnd_file.log, fnd_message.get);

        fnd_message.set_name('IGS','IGS_HE_REC_RECAL');
        fnd_file.put_line(fnd_file.log,fnd_message.get());


      -- Delete from igs_he_ext_run_interim, if rows exist
      -- Replaced the procedure call which calls the TBH for deletion with direct DML for bug,3179585
      DELETE FROM igs_he_ext_run_interim WHERE extract_run_id = p_extract_run_id;


      FOR l_c_mrk_row IN c_mrk_row
      LOOP
          g_records_found      := TRUE;
          l_he_ext_run_interim := NULL;

          -- Insert into temporary table to be processed
          -- later
          IF Substr(g_he_submsn_return.record_id,4,2) = '11'
          OR Substr(g_he_submsn_return.record_id,4,2) = '12'
          THEN
              -- Student or Combined Return
              l_he_ext_run_interim.person_id           := l_c_mrk_row.person_id;
              l_he_ext_run_interim.course_cd           := l_c_mrk_row.course_cd;
              l_he_ext_run_interim.crv_version_number  := l_c_mrk_row.crv_version_number;
              l_he_ext_run_interim.student_inst_number := l_c_mrk_row.student_inst_number ;

          ELSIF Substr(g_he_submsn_return.record_id,4,2) = '13' THEN
              -- Module Return
              l_he_ext_run_interim.unit_cd            := l_c_mrk_row.unit_cd;
              l_he_ext_run_interim.uv_version_number  := l_c_mrk_row.uv_version_number;
      -- smaddali added code for dlhe return , build HEFD203 bug#2717745
      ELSIF Substr(g_he_submsn_return.record_id,4,2) = '18' THEN
              -- dlhe Return
              l_he_ext_run_interim.person_id           := l_c_mrk_row.person_id;
          END IF;

          l_he_ext_run_interim.extract_run_id := p_extract_run_id;
          l_he_ext_run_interim.line_number    := l_c_mrk_row.line_number;

          igs_he_ext_run_interim_pkg.insert_row
              (X_rowid                  => l_rowid,
               X_ext_interim_id         => l_he_ext_run_interim.ext_interim_id,
               X_extract_run_id         => l_he_ext_run_interim.extract_run_id,
               X_person_id              => l_he_ext_run_interim.person_id,
               X_course_cd              => l_he_ext_run_interim.course_cd,
               X_crv_version_number     => l_he_ext_run_interim.crv_version_number,
               X_unit_cd                => l_he_ext_run_interim.unit_cd,
               X_uv_version_number      => l_he_ext_run_interim.uv_version_number,
               X_student_inst_number    => l_he_ext_run_interim.student_inst_number,
               X_line_number            => l_he_ext_run_interim.line_number);

      END LOOP;

      -- Check if person or prorgram criteria.
      OPEN c_recalc_criteria;
      FETCH c_recalc_criteria INTO l_temp;
      CLOSE c_recalc_criteria;

      -- If criteria does exist for this return,
      -- then append lines as appropriate to the return.
      IF l_temp IS NOT NULL THEN

          -- Call the appropriate function (get_students or get_dlhe)
          IF Substr(g_he_submsn_return.record_id,4,2) IN ('11', '12') THEN
              get_students(p_extract_run_id, TRUE);
          ELSIF Substr(g_he_submsn_return.record_id,4,2) = '18' THEN
              get_dlhe(p_extract_run_id, TRUE);
          END IF;

          -- Delete any appended lines that are already marked for recalculation
          DELETE FROM igs_he_ext_run_interim
          WHERE ext_interim_id IN
            (SELECT MAX(ext_interim_id)
               FROM igs_he_ext_run_interim a
           GROUP BY extract_run_id, person_id, course_cd, crv_version_number, unit_cd, uv_version_number, student_inst_number
             HAVING COUNT(ext_interim_id) > 1)
            AND line_number IS NULL;

      END IF;


   EXCEPTION
      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);
          Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
          Fnd_Message.Set_Token('NAME','IGS_HE_EXTRACT_PKG.get_marked_rows');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;

   END get_marked_rows;


   /*----------------------------------------------------------------------
   This procedure processes the records that have been inserted into
   the temporary run table.
   For each student / module, it will derive each of the fields and insert
   the rows into the extarct run data tables.

   Parameters :
   p_extract_run_id     IN     The Extract Run Id
   p_module_called_from IN     Module this process was called from
                               Values : 'IGSHE007' and 'IGSHE008'
   p_new_run_flag       IN     Indicates whether this is a fresh run
                               Values : 'Y', 'N'
   retcode              OUT NOCOPY    Return status of the concurrent program
                               Values : 0 - Success
                                        1 - Warning
                                        2 - Error
   errbuf               OUT NOCOPY    Error Buffer
   ----------------------------------------------------------------------*/
   PROCEDURE extract_main
          (errbuf                   IN OUT NOCOPY VARCHAR2,
           retcode                  IN OUT NOCOPY NUMBER,
           p_extract_run_id         IN     igs_he_ext_run_dtls.extract_run_id%TYPE,
           p_module_called_from     IN     VARCHAR2,
           p_new_run_flag           IN     VARCHAR2)
   IS
   /***************************************************************
   Created By           :       Bidisha S
   Date Created By      :      28-Jan-02
   Purpose              :      This procedure processes the records that have been inserted into
        the temporary run table. For each student / module, it will derive each of the fields and insert
        the rows into the extarct run data tables.
   Known Limitations,Enhancements or Remarks:
   Change History       :
   Who                  When                    What
   smaddali 9-apr-03 modified for adding dlhe processing , HEFD203 build , bug#2717745
   anwest               18-JAN-2006             Bug# 4950285 R12 Disable OSS Mandate
  ***************************************************************/

       CURSOR c_ext_dtl IS
       SELECT a.rowid,
          a.submission_name,
          a.user_return_subclass,
          a.return_name ,
          a.extract_phase,
          a.student_ext_run_id,
          a.conc_request_id,
          a.conc_request_status,
          a.extract_run_date,
          a.file_name ,
          a.file_location ,
          a.date_file_sent ,
          a.extract_override,
          a.validation_kit_result,
          a.hesa_validation_result ,
          b.lrr_start_date,
          b.lrr_end_date,
          b.record_id,
          c.enrolment_start_date,
          c.enrolment_end_date,
          c.offset_days ,
          c.validation_country ,
          Nvl(c.apply_to_atmpt_st_dt,'N') apply_to_atmpt_st_dt,
          Nvl(c.apply_to_inst_st_dt,'N')  apply_to_inst_st_dt
       FROM   igs_he_ext_run_dtls  a,
          igs_he_submsn_return b,
          igs_he_submsn_header c
       WHERE  a.extract_run_id       = p_extract_run_id
       AND    a.submission_name      = b.submission_name
       AND    a.return_name          = b.return_name
       AND    a.User_Return_Subclass = b.user_return_subclass
       AND    a.submission_name      = c.submission_name;

     -- Changed the cursor to COUNT(*) with 1 for bug, 3179585
       CURSOR c_interim_cnt IS
       SELECT 1
       FROM   igs_he_ext_run_interim
       WHERE  extract_run_id = p_extract_run_id;

       l_message                        VARCHAR2(2000);
       l_msg_code                       VARCHAR2(30);
       l_ext_run_dtl_rowid              VARCHAR2(50);
       l_request_id                     NUMBER;
       l_count                          NUMBER := 0;

       IGS_HESA_NOT_ENABLED_EXCEP       EXCEPTION;

   BEGIN

      --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
      IGS_GE_GEN_003.SET_ORG_ID;

      -- printing datetimestamp for monitoring performance
      fnd_message.set_name('IGS','IGS_HE_ST_PROC_TIME');
      fnd_message.set_token('PROCEDURE', 'EXTRACT_MAIN');
      fnd_message.set_token('TIMESTAMP',TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
      fnd_file.put_line(fnd_file.log, fnd_message.get);

      -- Check if UCAS and HESA are enabled, ie country = UK
      IF NOT Igs_Uc_Utils.is_ucas_hesa_enabled
      THEN

          RAISE IGS_HESA_NOT_ENABLED_EXCEP;

      END IF;

      -- smaddali added initialisations
        g_he_ext_run_dtls           := NULL;
        g_he_submsn_return          := NULL;
        g_he_submsn_header          := NULL;

      -- Get the HESA Extract Details
      l_ext_run_dtl_rowid := NULL ;
      OPEN c_ext_dtl;
      FETCH c_ext_dtl INTO l_ext_run_dtl_rowid,
                           g_he_ext_run_dtls.submission_name,
                           g_he_ext_run_dtls.user_return_subclass,
                           g_he_ext_run_dtls.return_name ,
                           g_he_ext_run_dtls.extract_phase,
                           g_he_ext_run_dtls.student_ext_run_id,
                           g_he_ext_run_dtls.conc_request_id,
                           g_he_ext_run_dtls.conc_request_status,
                           g_he_ext_run_dtls.extract_run_date,
                           g_he_ext_run_dtls.file_name ,
                           g_he_ext_run_dtls.file_location ,
                           g_he_ext_run_dtls.date_file_sent ,
                           g_he_ext_run_dtls.extract_override,
                           g_he_ext_run_dtls.validation_kit_result,
                           g_he_ext_run_dtls.hesa_validation_result ,
                           g_he_submsn_return.lrr_start_date,
                           g_he_submsn_return.lrr_end_date,
                           g_he_submsn_return.record_id,
                           g_he_submsn_header.enrolment_start_date,
                           g_he_submsn_header.enrolment_end_date,
                           g_he_submsn_header.offset_days ,
                           g_he_submsn_header.validation_country ,
                           g_he_submsn_header.apply_to_atmpt_st_dt,
                           g_he_submsn_header.apply_to_inst_st_dt;
      IF c_ext_dtl%NOTFOUND
      THEN
          CLOSE c_ext_dtl;
          l_message := NULL ;
          Fnd_Message.Set_Name('IGS', 'IGS_HE_EXT_DTL_NOT_FOUND');
          l_message := Fnd_Message.Get;

          -- Initialize Record to Null.
          g_he_ext_run_except := NULL;

          -- Populate the required fields.
          g_he_ext_run_except.extract_run_id   := p_extract_run_id;
          g_he_ext_run_except.exception_reason := l_message;

          -- Call procedure to log error
          log_error (g_he_ext_run_except);
          App_Exception.Raise_Exception;

      END IF;

      CLOSE c_ext_dtl;


      fnd_message.set_name('IGS','IGS_HE_PROC_SUBM');
      fnd_message.set_token('submission_name',g_he_ext_run_dtls.submission_name);
      fnd_message.set_token('user_return_subclass',g_he_ext_run_dtls.user_return_subclass);
      fnd_message.set_token('return_name',g_he_ext_run_dtls.return_name);
      fnd_message.set_token('enrolment_start_date',g_he_submsn_header.enrolment_start_date);
      fnd_message.set_token('enrolment_end_date',g_he_submsn_header.enrolment_end_date);
      fnd_file.put_line(fnd_file.log,fnd_message.get());


      IF     p_module_called_from = 'IGSHE008'
      THEN
          -- Called from 'Maintain Extract'
          -- Need to process only those rows which are
          -- marked as requiring recalculation
          get_marked_rows (p_extract_run_id);

          -- Delete marked rows exceptions for bug 3166186
          DELETE FROM igs_he_ext_run_excp excp
          WHERE excp.extract_run_id =  p_extract_run_id
            AND excp.line_number IN
               (SELECT line_number
                FROM igs_he_ext_run_interim
                WHERE extract_run_id = excp.extract_run_id);


      ELSIF p_module_called_from  = 'IGSHE007'
      THEN
          -- Called from 'Define Extract'
          -- Check if earlier process needs to be restarted or
          -- if its a new run
          IF p_new_run_flag = 'Y'
          THEN
              -- Do a fresh run.
              -- Therefore, delete all data that was created previously
              -- for the same run.
              -- Delete from igs_he_ext_run_interim
              fnd_message.set_name('IGS','IGS_HE_DELETE_REC');
              fnd_file.put_line(fnd_file.log,fnd_message.get());

              fnd_message.set_name('IGS','IGS_HE_ST_PROC_TIME');
              fnd_message.set_token('PROCEDURE', 'START_DELETE_ROWS');
              fnd_message.set_token('TIMESTAMP',TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
              fnd_file.put_line(fnd_file.log, fnd_message.get);

              -- Changed the logic to replace the call to procedure, delete_rows with the
              -- Direct DMLs to improve performance for bug,3179585

              -- Delete from igs_he_ext_run_interim
              DELETE FROM igs_he_ext_run_interim WHERE extract_run_id = p_extract_run_id;

              -- Delete from  igs_he_ex_rn_dat_fd
              DELETE FROM igs_he_ex_rn_dat_fd WHERE extract_run_id = p_extract_run_id;

              -- Delete from igs_he_ex_rn_dat_ln
              DELETE FROM igs_he_ex_rn_dat_ln WHERE extract_run_id = p_extract_run_id;

              -- Delete from igs_he_ext_run_excp
              DELETE FROM igs_he_ext_run_excp WHERE extract_run_id = p_extract_run_id;

              fnd_message.set_name('IGS','IGS_HE_ST_PROC_TIME');
              fnd_message.set_token('PROCEDURE', 'END_DELETE_ROWS');
              fnd_message.set_token('TIMESTAMP',TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
              fnd_file.put_line(fnd_file.log, fnd_message.get);

              IF Substr(g_he_submsn_return.record_id,4,2) = '11'
              OR Substr(g_he_submsn_return.record_id,4,2) = '12'
              THEN
                  -- Student or Combined Return
                  get_students (p_extract_run_id, FALSE);
              ELSIF Substr(g_he_submsn_return.record_id,4,2) = '13' THEN
                  -- Module Return
                  get_modules  (p_extract_run_id);
          -- smaddali added processing for DLHE return as part of HEFD203 build , bug#2717745
          ELSIF Substr(g_he_submsn_return.record_id,4,2) = '18' THEN
                  -- DLHE Return
                  get_dlhe(p_extract_run_id, FALSE);
              END IF;

          ELSE
              -- Restart from where the process
              -- stopped last time.i.e process
              -- unprocessed rows.
              -- Check if there are rows to process.
              l_count := 0;
              OPEN c_interim_cnt ;
              FETCH c_interim_cnt INTO l_count ;
              CLOSE c_interim_cnt;
              IF l_count > 0
              THEN
                   g_records_found := TRUE;
              END IF;
          END IF; -- check new_run_flag

      ELSE
          -- Unknown p_module_called_from
          Fnd_Message.Set_Name('IGS','IGS_HE_EXT_INV_MOD');
          IGS_GE_MSG_STACK.ADD;

          l_message := Fnd_message.Get_string('IGS','IGS_HE_EXT_INV_MOD');
          write_to_log (l_message);

          App_Exception.Raise_Exception;
      END IF; -- Module called from check

      -- Commit all the rows inserted into the Interim run table
      COMMIT;

      IF g_records_found
      THEN
          fnd_message.set_name('IGS','IGS_HE_VALID_STUD');
          fnd_file.put_line(fnd_file.log,fnd_message.get()|| ' - ' ||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));

          fnd_message.set_name('IGS','IGS_HE_TEMP_REC');
          fnd_file.put_line(fnd_file.log,fnd_message.get());

          -- If records were found that need processing,
          -- call the next procedure to process these
          -- Transaction handling is done within this procedure
          igs_he_extract2_pkg.process_temp_table
              (p_extract_run_id         => p_extract_run_id,
               p_module_called_from     => p_module_called_from,
               p_new_run_flag           => p_new_run_flag);
      ELSE
          IF Substr(g_he_submsn_return.record_id,4,2) = '11'
          OR Substr(g_he_submsn_return.record_id,4,2) = '12'
          THEN
              Fnd_Message.Set_Name('IGS','IGS_HE_EXT_SPA_NOT_FOUND');
          ELSIF Substr(g_he_submsn_return.record_id,4,2) = '13' THEN
              Fnd_Message.Set_Name('IGS','IGS_HE_EXT_MOD_NOT_FOUND');
              Fnd_Message.Set_Token('ST_RUN_ID',g_he_ext_run_dtls.student_ext_run_id,
                                     TRUE);
          -- smaddali added processing for DLHE return as part of HEFD203 build , bug#2717745
      ELSIF Substr(g_he_submsn_return.record_id,4,2) = '18' THEN
              Fnd_Message.Set_Name('IGS','IGS_HE_EXT_DLHE_NOT_FOUND');
          END IF;

          IGS_GE_MSG_STACK.ADD;

          l_message := Fnd_message.Get;
          write_to_log (l_message);

      END IF; -- records found check

      -- Mark Process as completed
      -- smaddali populating conc_request_id and date for bug 2483376
      igs_he_ext_run_dtls_pkg.update_row
          (X_rowid                     => l_ext_run_dtl_rowid,
           X_extract_run_id            => p_extract_run_id,
           X_submission_name           => g_he_ext_run_dtls.submission_name,
           X_user_return_subclass      => g_he_ext_run_dtls.user_return_subclass,
           X_return_name               => g_he_ext_run_dtls.return_name,
           X_extract_phase             => g_he_ext_run_dtls.extract_phase ,
           X_conc_request_id           => FND_GLOBAL.CONC_REQUEST_ID,
           X_conc_request_status       => 'COMPLETE',
           X_extract_run_date          => TRUNC(SYSDATE),
           X_file_name                 => g_he_ext_run_dtls.file_name ,
           X_file_location             => g_he_ext_run_dtls.file_location,
           X_date_file_sent            => g_he_ext_run_dtls.date_file_sent,
           X_extract_override          => g_he_ext_run_dtls.extract_override,
           X_validation_kit_result     => g_he_ext_run_dtls.validation_kit_result,
           X_hesa_validation_result    => g_he_ext_run_dtls.hesa_validation_result,
           X_student_ext_run_id        => g_he_ext_run_dtls.student_ext_run_id );

      -- Commit Transaction
      COMMIT;

      fnd_message.set_name('IGS','IGS_HE_PROC_COMP');
      fnd_file.put_line(fnd_file.log,fnd_message.get()|| ' - ' ||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));

      -- Submit the Extract Run Exception report.
      l_request_id := NULL ;
      l_request_id := Fnd_Request.Submit_Request
                          ( 'IGS',
                            'IGSHES01',
                            'Extract Run Exception Report',
                            NULL,
                            FALSE,
                            p_extract_run_id,
                            'LINE');


      fnd_message.set_name('IGS','IGS_HE_REP_SUBM');
      fnd_file.put_line(fnd_file.log,fnd_message.get()|| ' - ' ||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));

      EXCEPTION
      WHEN IGS_HESA_NOT_ENABLED_EXCEP
      THEN
          Errbuf  := Fnd_message.Get_string('IGS','IGS_UC_HE_NOT_ENABLED');
          retcode := 2;
          IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

      WHEN OTHERS
      THEN
          write_to_log(SQLERRM);
          errbuf  := SQLERRM;
          retcode := 2;
          ROLLBACK;

          -- Close Cursors
          IF c_ext_dtl%ISOPEN
          THEN
              CLOSE c_ext_dtl;
          END IF;

          -- Mark Process as Errored
          -- smaddali populating conc_request_id and date for bug 2483376
          igs_he_ext_run_dtls_pkg.update_row
              (X_rowid                     => l_ext_run_dtl_rowid,
               X_extract_run_id            => p_extract_run_id,
               X_submission_name           => g_he_ext_run_dtls.submission_name,
               X_user_return_subclass      => g_he_ext_run_dtls.user_return_subclass,
               X_return_name               => g_he_ext_run_dtls.return_name,
               X_extract_phase             => g_he_ext_run_dtls.extract_phase ,
               X_conc_request_id           => FND_GLOBAL.CONC_REQUEST_ID,
               X_conc_request_status       => 'ERROR',
               X_extract_run_date          => TRUNC(SYSDATE),
               X_file_name                 => g_he_ext_run_dtls.file_name ,
               X_file_location             => g_he_ext_run_dtls.file_location,
               X_date_file_sent            => g_he_ext_run_dtls.date_file_sent,
               X_extract_override          => g_he_ext_run_dtls.extract_override,
               X_validation_kit_result     => g_he_ext_run_dtls.validation_kit_result,
               X_hesa_validation_result    => g_he_ext_run_dtls.hesa_validation_result,
               X_student_ext_run_id        => g_he_ext_run_dtls.student_ext_run_id );

          -- Commit Transaction
          COMMIT;

          IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

   END extract_main;

END IGS_HE_EXTRACT_PKG;

/
