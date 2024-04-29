--------------------------------------------------------
--  DDL for Package Body IGS_HE_IDENTIFY_TARGET_POP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_IDENTIFY_TARGET_POP" AS
/* $Header: IGSHE25B.pls 120.4 2006/09/12 01:18:21 jtmathew ship $ */

PROCEDURE dlhe_identify_population (errbuf            OUT NOCOPY     VARCHAR2,
                                    retcode           OUT NOCOPY     NUMBER,
                                    p_submission_name IN  igs_he_sub_rtn_qual.submission_name%TYPE,
                                    p_return_name     IN  igs_he_sub_rtn_qual.return_name%TYPE,
                                    p_qual_period     IN  igs_he_sub_rtn_qual.qual_period_code%TYPE
                                  ) IS
 /******************************************************************
  Created By      : prasad marada
  Date Created By : 20-Apr-2003
  Purpose         : In this procedure identify the all qualifying periods
                    and call the identify spa procedure
  Known limitations,enhancements,remarks:
  Change History
  Who       When         What
  anwest    18-JAN-2006  Bug# 4950285 R12 Disable OSS Mandate
 *******************************************************************/

     -- Get the all qualifying periods under the submission order by closed
     CURSOR cur_qual_period (cp_submission_name igs_he_sub_rtn_qual.submission_name%TYPE,
                             cp_return_name     igs_he_sub_rtn_qual.return_name%TYPE,
                             cp_qual_period     igs_he_sub_rtn_qual.qual_period_code%TYPE) IS
     SELECT qual.qual_period_code,
            qual.qual_period_desc,
            qual.qual_period_type,
            qual.qual_period_start_date,
            qual.qual_period_end_date,
            qual.closed_ind
     FROM igs_he_sub_rtn_qual qual,
          igs_he_usr_rtn_clas urc
     WHERE qual.submission_name  = cp_submission_name
       AND qual.return_name      = cp_return_name
       AND qual.qual_period_code = NVL(cp_qual_period, qual.qual_period_code)
       AND qual.qual_period_type IN ('L','R')
       AND qual.user_return_subclass = urc.user_return_subclass
       AND urc.system_return_class_type = 'DLHE'
       ORDER BY qual.closed_ind ASC;

 BEGIN

         --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
         IGS_GE_GEN_003.SET_ORG_ID;

         retcode := 0;
         -- Check if UCAS and HESA are enabled, ie country = UK
        IF NOT Igs_Uc_Utils.is_ucas_hesa_enabled  THEN
          fnd_message.set_name('IGS','IGS_UC_HE_NOT_ENABLED');
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          errbuf  := fnd_message.get ;
          retcode := 2;
          RETURN;
        END IF;


        -- Get the all qualifying periods under the submission and call the identify spa process for each qual period
         FOR cur_qual_period_rec IN cur_qual_period (p_submission_name,
                                                     p_return_name,
                                                     p_qual_period) LOOP

              -- Report the Qualifying period details in the log file
             fnd_message.set_name('IGS','IGS_HE_DLHE_QUAL_PERIOD');
             fnd_message.set_token('QUAL_PERIOD',cur_qual_period_rec.qual_period_code);
             fnd_message.set_token('DESC',cur_qual_period_rec.qual_period_desc);
             fnd_message.set_token('TYPE',cur_qual_period_rec.qual_period_type);
             fnd_file.put_line(fnd_file.log,fnd_message.get);
              -- Call the dlhe_identify_spa procedure for each qualifying period
             igs_he_identify_target_pop.Dlhe_identify_spa(p_submission_name => p_submission_name,
                                                    p_return_name     => p_return_name,
                                                    p_qual_period     => cur_qual_period_rec.qual_period_code,
                                                    p_qual_type       => cur_qual_period_rec.qual_period_type,
                                                    p_qual_start_date => cur_qual_period_rec.qual_period_start_date,
                                                    p_qual_end_date   => cur_qual_period_rec.qual_period_end_date,
                                                    p_closed_ind      => cur_qual_period_rec.closed_ind
                                                   );
         END LOOP;

    EXCEPTION
     WHEN OTHERS THEN
         ROLLBACK;
         Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
         Fnd_Message.Set_Token('NAME','igs_he_identify_target_pop.dlhe_identify_population');
         fnd_file.put_line(fnd_file.log, fnd_message.get);
         errbuf  := fnd_message.get ;
         retcode := 2;

         IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

 END dlhe_identify_population;

 PROCEDURE dlhe_identify_spa (p_submission_name IN  igs_he_sub_rtn_qual.submission_name%TYPE,
                              p_return_name     IN  igs_he_sub_rtn_qual.return_name%TYPE,
                              p_qual_period     IN  igs_he_sub_rtn_qual.qual_period_code%TYPE,
                              p_qual_type       IN  igs_he_sub_rtn_qual.qual_period_type%TYPE,
                              p_qual_start_date IN  igs_he_sub_rtn_qual.qual_period_start_date%TYPE,
                              p_qual_end_date   IN  igs_he_sub_rtn_qual.qual_period_end_date%TYPE,
                              p_closed_ind      IN  igs_he_sub_rtn_qual.closed_ind%TYPE
                            ) IS

 /******************************************************************
  Created By      :  prasad marada
  Date Created By :  20-Apr-2003
  Purpose         :  Identify the Leavers/Research students and call the Process_spa
                     Prcoedure for each student.
  Known limitations,enhancements,remarks:
  Change History
  Who       When         What
  smaddali 07-Jan-04  Modified cursor cur_leavers_std to remove the condition
                      sca.course_attempt_status IN ('COMPLETED','DISCONTIN'), for bug#3335847
  jbaber   29-Jan-06  Modified cur_leavers_std and cur_research_std to exclude flagged
                      Program and POOUS records for HE305 - Extract Improvements
 *******************************************************************/

      -- Get the dlhe rowid for closed qualifying period records
     CURSOR cur_closed_dlhe (cp_submission_name igs_he_sub_rtn_qual.submission_name%TYPE,
                             cp_return_name     igs_he_sub_rtn_qual.return_name%TYPE,
                             cp_qual_period     igs_he_sub_rtn_qual.qual_period_code%TYPE) IS
     SELECT rowid
     FROM igs_he_stdnt_dlhe
     WHERE submission_name  = cp_submission_name
     AND return_name        = cp_return_name
     AND qual_period_code   = cp_qual_period
     AND dlhe_record_status = 'NST';

    -- Get the LEAVERS Students person_id and SPA details
    -- smaddali modified cursor to remove condition course_attempt_status IN 'COMPLETED','DISCONTIN',
    -- because the status need not be only completed/discontinued for a leaver, bug 3335847
     CURSOR cur_leavers_std (cp_qual_start_dt igs_he_sub_rtn_qual.qual_period_start_date%TYPE,
                             cp_qual_end_dt igs_he_sub_rtn_qual.qual_period_end_date%TYPE) IS
     SELECT hst.person_id,
            hst.course_cd,
            sca.version_number
     FROM  igs_en_stdnt_ps_att  sca,
           igs_he_st_spa   hst,
           igs_he_st_prog_all  hpg
     WHERE sca.person_id  = hst.person_id
      AND  sca.course_cd  = hst.course_cd
      AND  sca.course_cd  = hpg.course_cd
      AND  sca.version_number = hpg.version_number
      AND  NVL(hpg.exclude_flag, 'N') = 'N'
      AND  NVL(hst.exclude_flag, 'N') = 'N'
      AND  ((sca.discontinued_dt BETWEEN cp_qual_start_dt AND cp_qual_end_dt)
             OR  (sca.course_rqrmnts_complete_dt BETWEEN cp_qual_start_dt AND cp_qual_end_dt))
      ORDER BY hst.person_id;

       l_leavers_std  cur_leavers_std%ROWTYPE;

       -- Get the RESEARCH students person_id and their SPAs
       CURSOR cur_research_std  IS
       SELECT hst.person_id,
              hst.course_cd,
              sca.version_number,
              hst.student_inst_number,
              hst.commencement_dt  hst_commencement_dt,
              sca.commencement_dt  sca_commencement_dt
       FROM   igs_en_stdnt_ps_att sca,
              igs_he_st_spa hst,
              igs_he_st_prog_all  hpg,
              igs_ps_ver    pv,
              igs_ps_type   pt
       WHERE hst.person_id = sca.person_id
         AND hst.course_cd = sca.course_cd
         AND sca.course_cd      = hpg.course_cd
         AND sca.version_number = hpg.version_number
         AND sca.course_cd      = pv.course_cd
         AND sca.version_number = pv.version_number
         AND pt.course_type     = pv.course_type
         AND pt.research_type_ind = 'Y'
         AND NVL(hpg.exclude_flag, 'N') = 'N'
         AND NVL(hst.exclude_flag, 'N') = 'N'
         ORDER BY hst.person_id;

         l_research_std cur_research_std%ROWTYPE;

         l_comdate igs_he_ex_rn_dat_fd.value%TYPE;
         l_previous_person_id igs_pe_person_base_v.person_id%TYPE;

         -- Local variable holds C(created dlhe), U(Updated dlhe), E(Record Exists with an open qual period), F for field validation failed
         l_cre_upd_dlhe VARCHAR2(1);

         l_tot_ident_pop NUMBER ;     -- total identified students for target population

         l_new_dlhe_cnt  NUMBER;      -- Holds total new student DLHE records created
         l_upd_dlhe_cnt  NUMBER;      -- Holds total student DLHE records updated
         l_fail_std_cnt  NUMBER ;     -- Holds the number of students failed to satisfy the field validation
         l_not_mod_cnt NUMBER;        -- Holds the total number of students not required to update/create student DLHE

  BEGIN

       -- Qualifying period is closed then delete associated student DLHE records with NST dlhe record status
       IF p_closed_ind = 'Y' THEN
           FOR cur_closed_dlhe_rec IN cur_closed_dlhe (p_submission_name,
                                                       p_return_name,
                                                       p_qual_period) LOOP
               igs_he_stdnt_dlhe_pkg.delete_row(x_rowid => cur_closed_dlhe_rec.rowid);
           END LOOP;
       ELSE

              -- Initilazethe local variables
              l_previous_person_id := -1;
              l_cre_upd_dlhe  := NULL;
              l_tot_ident_pop := 0;

              l_new_dlhe_cnt := 0;
              l_upd_dlhe_cnt := 0;
              l_fail_std_cnt := 0;
              l_not_mod_cnt  := 0;

          -- qualifying period is L
          IF p_qual_type = 'L' THEN

          -- Get the person_id and SPA details
              FOR l_leavers_std_rec IN cur_leavers_std(p_qual_start_date,
                                                       p_qual_end_date) LOOP
                -- Call the dlhe_process_spa process for each student program attempt
                -- If student have more than one SPA, and if student record created, updated or not required to edit in dlhe table for any SPA then
                -- skip to pass the successive SPAs else pass the next SPA,

                 IF l_previous_person_id <> l_leavers_std_rec.person_id OR l_cre_upd_dlhe = 'F' THEN

                       IF l_previous_person_id <> l_leavers_std_rec.person_id THEN

               IF l_cre_upd_dlhe = 'C' THEN               -- l_cre_upd_dlhe returned value C means student DLHE record created
                              l_new_dlhe_cnt := l_new_dlhe_cnt +1;
                           ELSIF l_cre_upd_dlhe = 'U'  THEN           -- l_cre_upd_dlhe returned value U means student DLHE record updated
                              l_upd_dlhe_cnt := l_upd_dlhe_cnt + 1;
                           ELSIF l_cre_upd_dlhe = 'F'  THEN           -- l_cre_upd_dlhe returned value F means student failed the field validation
                              l_fail_std_cnt :=l_fail_std_cnt + 1;
                           ELSIF l_cre_upd_dlhe ='E'  THEN            -- Student dlhe is not required to modify
                              l_not_mod_cnt := l_not_mod_cnt + 1;
                           END IF;

               END IF;

                       l_previous_person_id := l_leavers_std_rec.person_id;

                      igs_he_identify_target_pop.dlhe_process_spa(P_submission_name => p_submission_name,
                                       p_return_name     => p_return_name,
                                       p_qual_period     => p_qual_period,
                                       P_qual_type       => 'L',
                                       p_person_id       => l_leavers_std_rec.person_id,
                                       p_course_cd       => l_leavers_std_rec.course_cd,
                                       p_version_number  => l_leavers_std_rec.version_number,
                                       p_cre_upd_dlhe    => l_cre_upd_dlhe
                                     );

                  END IF;
              END LOOP;  -- End loop for cur_leavers_std

                        -- For last student in the loop
                        IF l_cre_upd_dlhe = 'C' THEN               -- l_cre_upd_dlhe returned value C means student DLHE record created
                            l_new_dlhe_cnt := l_new_dlhe_cnt +1;
                        ELSIF l_cre_upd_dlhe = 'U'  THEN           -- l_cre_upd_dlhe returned value U means student DLHE record updated
                            l_upd_dlhe_cnt := l_upd_dlhe_cnt + 1;
                        ELSIF l_cre_upd_dlhe = 'F'  THEN           -- l_cre_upd_dlhe returned value F means student failed the field validation
                             l_fail_std_cnt :=l_fail_std_cnt + 1;
                        ELSIF l_cre_upd_dlhe ='E'  THEN            -- Student dlhe is not required to modify
                             l_not_mod_cnt := l_not_mod_cnt + 1;
                        END IF;

                       -- total number of identified leavers students for the population
                      l_tot_ident_pop := l_tot_ident_pop + l_new_dlhe_cnt + l_upd_dlhe_cnt + l_fail_std_cnt + l_not_mod_cnt;

                      -- Report the total number of Leaver students identifed in the population
                      fnd_message.set_name('IGS','IGS_HE_DLHE_ST_IDENT_POP');
                      fnd_message.set_token('TOTAL_STD_POP',l_tot_ident_pop );
                      fnd_message.set_token('RETURN_NAME',p_return_name);
                      fnd_message.set_token('QUAL_PERIOD',p_qual_period);
                      fnd_file.put_line(fnd_file.log, fnd_message.get);

          ELSIF p_qual_type = 'R' THEN

              -- Get the research students and their SPAs
              FOR l_research_std_rec IN cur_research_std  LOOP

                  -- Derive COMDATE field value for the student and check whether COMDATE value falls in between Qualification period start date and end date
              l_comdate := NULL;
                   igs_he_extract_fields_pkg.get_commencement_dt
                                  ( p_hesa_commdate      =>  l_research_std_rec.hst_commencement_dt,
                                    p_enstdnt_commdate   =>  l_research_std_rec.sca_commencement_dt,
                                    p_person_id          =>  l_research_std_rec.person_id ,
                                    p_course_cd          =>  l_research_std_rec.course_cd,
                                    p_version_number     =>  l_research_std_rec.version_number,
                                    p_student_inst_number => l_research_std_rec.student_inst_number,
                                    p_final_commdate      => l_comdate);

                       -- Check whether the HESA COMDATE falls in between the qualifying period start date and end date,
                       -- if student satisfies the condition then, he is eligible for DLHE return
                       IF TO_DATE(l_comdate,'DD-MM-RRRR') >= p_qual_start_date AND
                          TO_DATE(l_comdate,'DD-MM-RRRR') <= p_qual_end_date THEN

                         -- Call the dlhe_process_spa process for each student program attempt
                         -- If student have more than one SPA, and if student record created, updated or not required to edit in dlhe table for any SPA then
                         -- skip to pass successive SPAs else pass the next SPA,

                          IF l_previous_person_id <> l_research_std_rec.person_id OR l_cre_upd_dlhe = 'F' THEN

                              IF l_previous_person_id <> l_research_std_rec.person_id THEN

                                 IF l_cre_upd_dlhe = 'C' THEN               -- l_cre_upd_dlhe returned value C means student DLHE record created
                                     l_new_dlhe_cnt := l_new_dlhe_cnt +1;
                                 ELSIF l_cre_upd_dlhe = 'U'  THEN           -- l_cre_upd_dlhe returned value U means student DLHE record updated
                                     l_upd_dlhe_cnt := l_upd_dlhe_cnt + 1;
                                 ELSIF l_cre_upd_dlhe = 'F'  THEN           -- l_cre_upd_dlhe returned value F means student failed the field validation
                                     l_fail_std_cnt :=l_fail_std_cnt + 1;
                                 ELSIF l_cre_upd_dlhe ='E'  THEN            -- Student dlhe is not required to modify
                                     l_not_mod_cnt := l_not_mod_cnt + 1;
                                 END IF;

                              END IF;

                                l_previous_person_id := l_research_std_rec.person_id;
                                    -- Call the dlhe_process_spa procedure
                                 igs_he_identify_target_pop.dlhe_process_spa(P_submission_name => p_submission_name,
                                                p_return_name     => p_return_name,
                                                p_qual_period     => p_qual_period,
                                                P_qual_type       => 'R',
                                                p_person_id       => l_research_std_rec.person_id,
                                                p_course_cd       => l_research_std_rec.course_cd,
                                                p_version_number  => l_research_std_rec.version_number,
                                                p_cre_upd_dlhe    => l_cre_upd_dlhe
                                               );

                         END IF;
                    END IF;
              END LOOP;  -- End loop for l_research_std_rec

                        -- Count the last student details
                        IF l_cre_upd_dlhe = 'C' THEN               -- l_cre_upd_dlhe returned value C means student DLHE record created
                            l_new_dlhe_cnt := l_new_dlhe_cnt +1;
                        ELSIF l_cre_upd_dlhe = 'U'  THEN           -- l_cre_upd_dlhe returned value U means student DLHE record updated
                            l_upd_dlhe_cnt := l_upd_dlhe_cnt + 1;
                        ELSIF l_cre_upd_dlhe = 'F'  THEN           -- l_cre_upd_dlhe returned value F means student failed the field validation
                             l_fail_std_cnt :=l_fail_std_cnt + 1;
                        ELSIF l_cre_upd_dlhe ='E'  THEN            -- Student dlhe is not required to modify
                             l_not_mod_cnt := l_not_mod_cnt + 1;
                        END IF;

                       -- total number of identified research students for the population
                       l_tot_ident_pop := l_tot_ident_pop + l_new_dlhe_cnt + l_upd_dlhe_cnt + l_fail_std_cnt + l_not_mod_cnt;

                      -- Report the total number of research students identifed for target population
                      fnd_message.set_name('IGS','IGS_HE_DLHE_ST_IDENT_POP');
                      fnd_message.set_token('TOTAL_STD_POP',l_tot_ident_pop );
                      fnd_message.set_token('RETURN_NAME',p_return_name);
                      fnd_message.set_token('QUAL_PERIOD',p_qual_period);
                      fnd_file.put_line(fnd_file.log, fnd_message.get);

          END IF;    -- End if for qual type

               -- Report the total number of new student DLHE records created
              fnd_message.set_name('IGS','IGS_HE_DLHE_REC_CREATED');
              fnd_message.set_token('CREATED_DLHE', l_new_dlhe_cnt);
              fnd_message.set_token('RETURN_NAME',p_return_name);
              fnd_message.set_token('QUAL_PERIOD',p_qual_period);
              fnd_file.put_line(fnd_file.log, fnd_message.get);

              -- Report the total number of student DLHE records updated with the current qualifying period
              fnd_message.set_name('IGS','IGS_HE_DLHE_REC_UPDATED');
              fnd_message.set_token('UPDATED_DLHE', l_upd_dlhe_cnt);
              fnd_message.set_token('RETURN_NAME',p_return_name);
              fnd_message.set_token('QUAL_PERIOD',p_qual_period);
              fnd_file.put_line(fnd_file.log, fnd_message.get);

               -- Report the total number of students failed to satisfy the field validations
              fnd_message.set_name('IGS','IGS_HE_DLHE_FAILED_STD');
              fnd_message.set_token('FAIL_DLHE', l_fail_std_cnt);
              fnd_message.set_token('RETURN_NAME',p_return_name);
              fnd_message.set_token('QUAL_PERIOD',p_qual_period);
              fnd_file.put_line(fnd_file.log, fnd_message.get);

               -- Report the total number of students have the student DLHE records with open qualifying period,
               -- for them not required to modify student DLHE record.
              fnd_message.set_name('IGS','IGS_HE_DLHE_NOT_MODIFIED');
              fnd_message.set_token('NOT_MOD', l_not_mod_cnt);
              fnd_message.set_token('RETURN_NAME',p_return_name);
              fnd_message.set_token('QUAL_PERIOD',p_qual_period);
              fnd_file.put_line(fnd_file.log, fnd_message.get);

     END IF;  -- End if For closed qual_period

    EXCEPTION
     WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','igs_he_identify_target_pop.dlhe_identify_spa');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        App_Exception.Raise_Exception;

  END  dlhe_identify_spa;


  PROCEDURE dlhe_process_spa( P_submission_name IN  igs_he_sub_rtn_qual.submission_name%TYPE,
                              p_return_name     IN  igs_he_sub_rtn_qual.return_name%TYPE,
                              p_qual_period     IN  igs_he_sub_rtn_qual.qual_period_code%TYPE,
                              P_qual_type       IN  igs_he_sub_rtn_qual.qual_period_type%TYPE,
                              p_person_id       IN  igs_he_st_spa.person_id%TYPE,
                              p_course_cd       IN  igs_he_st_spa.course_cd%TYPE,
                              p_version_number  IN  igs_he_st_spa.version_number%TYPE,
                              p_cre_upd_dlhe    OUT NOCOPY VARCHAR2
                             ) IS
 /******************************************************************
  Created By      :  prasad marada
  Date Created By :  20-Apr-2003
  Purpose         :  For successfull student create/Update the student DLHE table
                     in this procedure
  Known limitations,enhancements,remarks:
  Change History
  Who       When         What
 *******************************************************************/

          -- Cursor to get the Qualification details for validations and update the student dlhe table.
          CURSOR cur_qual_dets (cp_submission_name   igs_he_sub_rtn_qual.submission_name%TYPE,
                                cp_return_name       igs_he_sub_rtn_qual.return_name%TYPE,
                                cp_qual_period_code  igs_he_sub_rtn_qual.qual_period_code%TYPE) IS
          SELECT qual.qual_period_start_date,
                 qual.qual_period_end_date,
                 qual.user_return_subclass,
                 qual.closed_ind
          FROM igs_he_sub_rtn_qual  qual,
               igs_he_usr_rtn_clas urc
          WHERE qual.submission_name     = cp_submission_name
            AND qual.return_name         = cp_return_name
            AND qual.qual_period_code    = cp_qual_period_code
            AND qual.user_return_subclass = urc.user_return_subclass
            AND urc.system_return_class_type = 'DLHE';

          l_qual_dets  cur_qual_dets%ROWTYPE;

          -- Cursor to get the student DLHE record details for validations and for updateing Student DLHE table
          CURSOR cur_stdnt_dlhe(cp_submission_name  igs_he_stdnt_dlhe.submission_name%TYPE,
                                cp_return_name      igs_he_stdnt_dlhe.return_name%TYPE,
                                cp_person_id        igs_he_stdnt_dlhe.person_id%TYPE)  IS
          SELECT sdlhe.rowid,
                 sdlhe.*
          FROM igs_he_stdnt_dlhe sdlhe
          WHERE sdlhe.submission_name = cp_submission_name
            AND sdlhe.return_name     = cp_return_name
            AND sdlhe.person_id       = cp_person_id;

          l_stdnt_dlhe_rec cur_stdnt_dlhe%ROWTYPE;

          l_include VARCHAR2(1);
          l_qualified_teacher  VARCHAR2(1);
          l_pt_study VARCHAR2(1);

          l_rowid VARCHAR2(30);

   BEGIN

           l_include := 'N';
           l_qualified_teacher := 'N';
           l_pt_study := 'N';

                 --Get the Qual details for further processing
                 OPEN cur_qual_dets (p_submission_name,
                                     p_return_name,
                                     p_qual_period);
                 FETCH cur_qual_dets INTO l_qual_dets;
                 CLOSE cur_qual_dets;
            -- Call the dlhe_review_spa procedure
            igs_he_identify_target_pop.dlhe_review_spa(
                             p_submission_name   => p_submission_name,
                             p_return_name       => p_return_name,
                             p_qual_period       => p_qual_period,
                             p_qual_type         => p_qual_type,
                             p_qual_start_dt     => l_qual_dets.qual_period_start_date,
                             p_qual_end_dt       => l_qual_dets.qual_period_end_date,
                             p_person_id         => p_person_id,
                             p_course_cd         => p_course_cd,
                             p_version_number    => p_version_number,
                             p_include           => l_include,
                             p_qualified_teacher => l_qualified_teacher,
                             p_pt_study          => l_pt_study
                            );

             -- dlhe_review_spa process returns include Y means, student satisfied the field validation and
             -- eligible for target population
            IF l_include = 'Y' THEN
                 -- Check whether student have the student dlhe record ubder this submission
                 OPEN cur_stdnt_dlhe (p_submission_name,
                                      p_return_name,
                                      p_person_id);
                 FETCH cur_stdnt_dlhe INTO l_stdnt_dlhe_rec;
                 -- If the student does not have the student DLHE record for the sublission then create new student DLHE record
                 IF cur_stdnt_dlhe%NOTFOUND THEN
                   -- Create student DLHE record

                    igs_he_stdnt_dlhe_pkg.insert_row(
                                            x_rowid                      => l_rowid,
                                            x_person_id                  => p_person_id,
                                            x_submission_name            => p_submission_name,
                                            x_user_return_subclass       => l_qual_dets.user_return_subclass,
                                            x_return_name                => p_return_name,
                                            x_qual_period_code           => p_qual_period,
                                            x_dlhe_record_status         => 'NST',
                                            x_participant_source         => 'I',
                                            x_date_status_changed        => NULL,
                                            x_validation_status          => NULL,
                                            x_admin_coding               => NULL,
                                            x_survey_method              => NULL,
                                            x_employment                 => NULL,
                                            x_further_study              => NULL,
                                            x_qualified_teacher          => l_qualified_teacher,
                                            x_pt_study                   => l_pt_study,
                                            x_employer_business          => NULL,
                                            x_employer_name              => NULL,
                                            x_employer_classification    => NULL,
                                            x_employer_location          => NULL,
                                            x_employer_postcode          => NULL,
                                            x_employer_country           => NULL,
                                            x_job_title                  => NULL,
                                            x_job_duties                 => NULL,
                                            x_job_classification         => NULL,
                                            x_employer_size              => NULL,
                                            x_job_duration               => NULL,
                                            x_job_salary                 => NULL,
                                            x_salary_refused             => 'N',
                                            x_qualification_requirement  => NULL,
                                            x_qualification_importance   => NULL,
                                            x_job_reason1                => 'N',
                                            x_job_reason2                => 'N',
                                            x_job_reason3                => 'N',
                                            x_job_reason4                => 'N',
                                            x_job_reason5                => 'N',
                                            x_job_reason6                => 'N',
                                            x_job_reason7                => 'N',
                                            x_job_reason8                => 'N',
                                            x_other_job_reason           => NULL,
                                            x_no_other_job_reason        => 'N',
                                            x_job_source                 => NULL,
                                            x_other_job_source           => NULL,
                                            x_no_other_job_source        => 'N',
                                            x_previous_job               => NULL,
                                            x_previous_jobtype1          => 'N',
                                            x_previous_jobtype2          => 'N',
                                            x_previous_jobtype3          => 'N',
                                            x_previous_jobtype4          => 'N',
                                            x_previous_jobtype5          => 'N',
                                            x_previous_jobtype6          => 'N',
                                            x_further_study_type         => NULL,
                                            x_course_name                => NULL,
                                            x_course_training_subject    => NULL,
                                            x_research_subject           => NULL,
                                            x_research_training_subject  => NULL,
                                            x_further_study_provider     => NULL,
                                            x_further_study_qualaim      => NULL,
                                            x_professional_qualification => NULL,
                                            x_study_reason1              => NULL,
                                            x_study_reason2              => 'N',
                                            x_study_reason3              => 'N',
                                            x_study_reason4              => 'N',
                                            x_study_reason5              => 'N',
                                            x_study_reason6              => 'N',
                                            x_study_reason7              => 'N',
                                            x_other_study_reason         => NULL,
                                            x_no_other_study_reason      => 'N',
                                            x_employer_sponsored         => 'N',
                                            x_funding_source             => NULL,
                                            x_teacher_teaching           => 'N',
                                            x_teacher_seeking            => 'N',
                                            x_teaching_sector            => NULL,
                                            x_teaching_level             => NULL,
                                            x_reason_for_ptcourse        => NULL,
                                            x_job_while_studying         => 'N',
                                            x_employer_support1          => 'N',
                                            x_employer_support2          => 'N',
                                            x_employer_support3          => 'N',
                                            x_employer_support4          => 'N',
                                            x_employer_support5          => 'N',
                                            x_popdlhe_flag               => 'N'
                                          );
                       -- Return C for successfully created student
                       p_cre_upd_dlhe := 'C';
                ELSE
                   -- If student have the Student DLHE record then check whether the qualifying period is closed or not
                   OPEN cur_qual_dets (p_submission_name,
                                       p_return_name,
                                       l_stdnt_dlhe_rec.qual_period_code);
                   FETCH cur_qual_dets INTO l_qual_dets;
                   CLOSE cur_qual_dets;

                    -- If the student DLHE record qualifying period is closed then update Student DLHE record with current qualifying period
                     IF l_qual_dets.closed_ind = 'Y' THEN
                         -- Update the existing closed qualifying period with current qualifying period
                         igs_he_stdnt_dlhe_pkg.update_row(
                                            x_rowid                     => l_stdnt_dlhe_rec.rowid,
                                            x_person_id                 => l_stdnt_dlhe_rec.person_id,
                                            x_submission_name           => l_stdnt_dlhe_rec.submission_name,
                                            x_user_return_subclass      => l_stdnt_dlhe_rec.user_return_subclass ,
                                            x_return_name               => l_stdnt_dlhe_rec.return_name,
                                            x_qual_period_code          => p_qual_period,
                                            x_dlhe_record_status        => l_stdnt_dlhe_rec.dlhe_record_status,
                                            x_participant_source        => l_stdnt_dlhe_rec.participant_source,
                                            x_date_status_changed       => l_stdnt_dlhe_rec.date_status_changed,
                                            x_validation_status         => l_stdnt_dlhe_rec.validation_status,
                                            x_admin_coding              => l_stdnt_dlhe_rec.admin_coding,
                                            x_survey_method             => l_stdnt_dlhe_rec.survey_method,
                                            x_employment                => l_stdnt_dlhe_rec.employment,
                                            x_further_study             => l_stdnt_dlhe_rec.further_study,
                                            x_qualified_teacher         => l_stdnt_dlhe_rec.qualified_teacher,
                                            x_pt_study                  => l_stdnt_dlhe_rec.pt_study,
                                            x_employer_business         => l_stdnt_dlhe_rec.employer_business,
                                            x_employer_name             => l_stdnt_dlhe_rec.employer_name,
                                            x_employer_classification   => l_stdnt_dlhe_rec.employer_classification,
                                            x_employer_location         => l_stdnt_dlhe_rec.employer_location,
                                            x_employer_postcode         => l_stdnt_dlhe_rec.employer_postcode,
                                            x_employer_country          => l_stdnt_dlhe_rec.employer_country,
                                            x_job_title                 => l_stdnt_dlhe_rec.job_title,
                                            x_job_duties                => l_stdnt_dlhe_rec.job_duties,
                                            x_job_classification        => l_stdnt_dlhe_rec.job_classification,
                                            x_employer_size             => l_stdnt_dlhe_rec.employer_size,
                                            x_job_duration              => l_stdnt_dlhe_rec.job_duration,
                                            x_job_salary                => l_stdnt_dlhe_rec.job_salary,
                                            x_salary_refused            => l_stdnt_dlhe_rec.salary_refused,
                                            x_qualification_requirement => l_stdnt_dlhe_rec.qualification_requirement,
                                            x_qualification_importance  => l_stdnt_dlhe_rec.qualification_importance,
                                            x_job_reason1               => l_stdnt_dlhe_rec.job_reason1,
                                            x_job_reason2               => l_stdnt_dlhe_rec.job_reason2,
                                            x_job_reason3               => l_stdnt_dlhe_rec.job_reason3,
                                            x_job_reason4               => l_stdnt_dlhe_rec.job_reason4,
                                            x_job_reason5               => l_stdnt_dlhe_rec.job_reason5,
                                            x_job_reason6               => l_stdnt_dlhe_rec.job_reason6,
                                            x_job_reason7               => l_stdnt_dlhe_rec.job_reason7,
                                            x_job_reason8               => l_stdnt_dlhe_rec.job_reason8,
                                            x_other_job_reason          => l_stdnt_dlhe_rec.other_job_reason,
                                            x_no_other_job_reason       => l_stdnt_dlhe_rec.no_other_job_reason,
                                            x_job_source                => l_stdnt_dlhe_rec.job_source,
                                            x_other_job_source          => l_stdnt_dlhe_rec.other_job_source,
                                            x_no_other_job_source       => l_stdnt_dlhe_rec.no_other_job_source,
                                            x_previous_job              => l_stdnt_dlhe_rec.previous_job,
                                            x_previous_jobtype1         => l_stdnt_dlhe_rec.previous_jobtype1,
                                            x_previous_jobtype2         => l_stdnt_dlhe_rec.previous_jobtype2,
                                            x_previous_jobtype3         => l_stdnt_dlhe_rec.previous_jobtype3,
                                            x_previous_jobtype4         => l_stdnt_dlhe_rec.previous_jobtype4,
                                            x_previous_jobtype5         => l_stdnt_dlhe_rec.previous_jobtype5,
                                            x_previous_jobtype6         => l_stdnt_dlhe_rec.previous_jobtype6,
                                            x_further_study_type        => l_stdnt_dlhe_rec.further_study_type,
                                            x_course_name               => l_stdnt_dlhe_rec.course_name,
                                            x_course_training_subject   => l_stdnt_dlhe_rec.course_training_subject,
                                            x_research_subject          => l_stdnt_dlhe_rec.research_subject,
                                            x_research_training_subject => l_stdnt_dlhe_rec.research_training_subject,
                                            x_further_study_provider    => l_stdnt_dlhe_rec.further_study_provider,
                                            x_further_study_qualaim     => l_stdnt_dlhe_rec.further_study_qualaim,
                                            x_professional_qualification=> l_stdnt_dlhe_rec.professional_qualification,
                                            x_study_reason1             => l_stdnt_dlhe_rec.study_reason1,
                                            x_study_reason2             => l_stdnt_dlhe_rec.study_reason2,
                                            x_study_reason3             => l_stdnt_dlhe_rec.study_reason3,
                                            x_study_reason4             => l_stdnt_dlhe_rec.study_reason4,
                                            x_study_reason5             => l_stdnt_dlhe_rec.study_reason5,
                                            x_study_reason6             => l_stdnt_dlhe_rec.study_reason6,
                                            x_study_reason7             => l_stdnt_dlhe_rec.study_reason7,
                                            x_other_study_reason        => l_stdnt_dlhe_rec.other_study_reason,
                                            x_no_other_study_reason     => l_stdnt_dlhe_rec.no_other_study_reason,
                                            x_employer_sponsored        => l_stdnt_dlhe_rec.employer_sponsored,
                                            x_funding_source            => l_stdnt_dlhe_rec.funding_source,
                                            x_teacher_teaching          => l_stdnt_dlhe_rec.teacher_teaching,
                                            x_teacher_seeking           => l_stdnt_dlhe_rec.teacher_seeking,
                                            x_teaching_sector           => l_stdnt_dlhe_rec.teaching_sector,
                                            x_teaching_level            => l_stdnt_dlhe_rec.teaching_level,
                                            x_reason_for_ptcourse       => l_stdnt_dlhe_rec.reason_for_ptcourse,
                                            x_job_while_studying        => l_stdnt_dlhe_rec.job_while_studying,
                                            x_employer_support1         => l_stdnt_dlhe_rec.employer_support1,
                                            x_employer_support2         => l_stdnt_dlhe_rec.employer_support2,
                                            x_employer_support3         => l_stdnt_dlhe_rec.employer_support3,
                                            x_employer_support4         => l_stdnt_dlhe_rec.employer_support4,
                                            x_employer_support5         => l_stdnt_dlhe_rec.employer_support5,
                                            x_popdlhe_flag              => l_stdnt_dlhe_rec.popdlhe_flag
                                           );
                              -- Return U means updated the record with current qualifying period successfully
                               p_cre_upd_dlhe := 'U';
                     ELSE
                         -- Return E means not required to update the record, there exists student DLHE record with an open qualifying period
                         p_cre_upd_dlhe := 'E';
                     END IF;    -- End if for closed Y
                 END IF;     -- end if for cur_stdnt_dlhe%NOTFOUND
                 CLOSE cur_stdnt_dlhe;
            ELSE
               -- Return F means, student failed to satisfy the Field validation
               p_cre_upd_dlhe := 'F';
            END IF;    -- End if for include N

   EXCEPTION
     WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','igs_he_identify_target_pop.dlhe_process_spa');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        App_Exception.Raise_Exception;

  END dlhe_process_spa;

  PROCEDURE dlhe_review_spa( p_submission_name   IN  igs_he_sub_rtn_qual.submission_name%TYPE,
                             p_return_name       IN  igs_he_sub_rtn_qual.return_name%TYPE,
                             p_qual_period       IN  igs_he_sub_rtn_qual.qual_period_code%TYPE,
                             P_qual_type         IN  igs_he_sub_rtn_qual.qual_period_type%TYPE,
                             p_qual_start_dt     IN  igs_he_sub_rtn_qual.qual_period_start_date%TYPE,
                             p_qual_end_dt       IN  igs_he_sub_rtn_qual.qual_period_end_date%TYPE,
                             p_person_id         IN  igs_he_st_spa.person_id%TYPE,
                             p_course_cd         IN  igs_he_st_spa.course_cd%TYPE,
                             p_version_number    IN  igs_he_st_spa.version_number%TYPE,
                             p_include           OUT NOCOPY VARCHAR2,
                             p_qualified_teacher OUT NOCOPY VARCHAR2,
                             p_pt_study          OUT NOCOPY VARCHAR2
                          )  IS
 /******************************************************************
  Created By      :  prasad marada
  Date Created By :  20-Apr-2003
  Purpose         :  Derive the Field value for each student and check whether the
                     can be includeed in the target population or not.
  Known limitations,enhancements,remarks:
  Change History
  Who       When         What
  smaddali 09-dec-2003  Modified logic to get Term record details for HECR214 - Term based fees enhancement, bug#3291656
  ayedubat 15-dec-2003  Modified the cursor, c_yop_susa to add a new validation based on the
                        HESA Submission Period Start Date and end date for bug# 3288836
  jbaber   01-sep-2005  Modified for HE310 - Load DLHE Target Population
                        - Removed QualAim check for Reseach students
                        - Added new european countries to allowed domicile codes for Leaver students
 *******************************************************************/

            -- Get the reporting dates for the submission
           CURSOR cur_he_sub_header (cp_submission_name igs_he_submsn_header.submission_name%TYPE) IS
           SELECT enrolment_start_date,
                  enrolment_end_date
           FROM igs_he_submsn_header
           WHERE submission_name = cp_submission_name ;

            l_he_sub_header cur_he_sub_header%ROWTYPE;

            -- Get the Location of study, for deriving LOCSDY (71) value
           CURSOR cur_he_st_prog (cp_course_cd      igs_he_st_prog.course_cd%TYPE,
                                  cp_version_number igs_he_st_prog.version_number%TYPE) IS
           SELECT location_of_study
           FROM igs_he_st_prog
           WHERE course_cd    = cp_course_cd
           AND version_number = cp_version_number;

           l_he_st_prog  cur_he_st_prog%ROWTYPE;

           -- Get the SUSA details for deriving MODE, LOCSDY and MSTUFEE field values
           CURSOR c_yop_susa (cp_person_id  igs_as_su_setatmpt.person_id%TYPE,
                              cp_course_cd  igs_as_su_setatmpt.course_cd%TYPE,
                              cp_enrl_start_dt igs_he_submsn_header.enrolment_start_date%TYPE,
                              cp_enrl_end_dt igs_he_submsn_header.enrolment_end_date%TYPE) IS
           SELECT DISTINCT susa.unit_set_cd,
                  susa.us_version_number,
                  susa.sequence_number,
                  susa.rqrmnts_complete_dt,
                  susa.selection_dt,
                  susa.end_dt,
                  husa.study_mode,
                  husa.study_location ,
                  husa.student_fee
           FROM  igs_as_su_setatmpt  susa,
                 igs_he_en_susa      husa,
                 igs_en_unit_set     us,
                 igs_en_unit_set_cat susc,
                 igs_en_stdnt_ps_att   sca
           WHERE susa.person_id         = sca.person_id
           AND   susa.course_cd         = sca.course_cd
           AND   susa.person_id         = cp_person_id
           AND   susa.course_cd         = cp_course_cd
           AND   susa.unit_set_cd       = husa.unit_set_cd
           AND   susa.us_version_number = husa.us_version_number
           AND   susa.person_id         = husa.person_id
           AND   susa.course_cd         = husa.course_cd
           AND   susa.sequence_number   = husa.sequence_number
           AND   susa.unit_set_cd       = us.unit_set_cd
           AND   susa.us_version_number = us.version_number
           AND   us.unit_set_cat        = susc.unit_set_cat
           AND   susc.s_unit_set_cat    = 'PRENRL_YR'
           AND   (susa.selection_dt <= cp_enrl_end_dt AND
                  (susa.end_dt  IS NULL OR susa.end_dt  >= cp_enrl_start_dt ) AND
                  (susa.rqrmnts_complete_dt IS NULL OR susa.rqrmnts_complete_dt >= cp_enrl_start_dt))
           ORDER BY susa.rqrmnts_complete_dt DESC, susa.end_dt DESC, susa.selection_dt DESC;

           l_yop_susa  c_yop_susa%ROWTYPE;

           -- Get the Student program attempt details for deriving MODE, RSNLEAVE, DOMICILE, QUALAIM etc
           CURSOR c_spa (cp_person_id  igs_en_stdnt_ps_att.person_id%TYPE,
                         cp_course_cd  igs_en_stdnt_ps_att.course_cd%TYPE)IS
           SELECT sca.version_number,
                  sca.cal_type,
                  sca.location_cd ,
                  sca.attendance_mode,
                  sca.attendance_type,
                  sca.commencement_dt  sca_commencement_dt,
                  sca.discontinued_dt,
                  sca.discontinuation_reason_cd,
                  sca.course_rqrmnt_complete_ind,
                  sca.course_rqrmnts_complete_dt,
                  sca.adm_admission_appl_number,
                  sca.adm_nominated_course_cd,
                  sca.adm_sequence_number,
                  hspa.domicile_cd,
                  hspa.commencement_dt hspa_commencement_dt,
                  hspa.special_student,
                  hspa.student_qual_aim,
                  hspa.student_inst_number
           FROM   igs_en_stdnt_ps_att   sca,
                  igs_he_st_spa         hspa
           WHERE  sca.person_id  = cp_person_id
           AND    sca.course_cd  = cp_course_cd
           AND    sca.person_id  = hspa.person_id
           AND    sca.course_cd  = hspa.course_cd;

           l_spa c_spa%ROWTYPE;

           -- Get the location of study and mode of study for deriving LOCSDY and MODE values
           CURSOR cur_he_poous(cp_course_cd          igs_he_poous.course_cd%TYPE,
                               cp_version_number     igs_he_poous.crv_version_number%TYPE,
                               cp_cal_type           igs_he_poous.cal_type%TYPE,
                               cp_location_cd        igs_he_poous.location_cd%TYPE,
                               cp_attendance_mode    igs_he_poous.attendance_mode%TYPE,
                               cp_attendance_type    igs_he_poous.attendance_type%TYPE,
                               cp_unit_set_cd        igs_he_poous.unit_set_cd%TYPE,
                               cp_us_version_number  igs_he_poous.us_version_number%TYPE) IS
           SELECT  location_of_study,
                   mode_of_study
           FROM   igs_he_poous
           WHERE course_cd          = cp_course_cd
            AND  crv_version_number = cp_version_number
            AND  cal_type           = cp_cal_type
            AND  location_cd        = cp_location_cd
            AND  attendance_mode    = cp_attendance_mode
            AND  attendance_type    = cp_attendance_type
            AND  unit_set_cd        = cp_unit_set_cd
            AND  us_version_number  = cp_us_version_number;

            l_he_poous cur_he_poous%ROWTYPE;

           -- get the domicile code and special student code from igs_he_ad_dtl
           CURSOR c_he_ad_dtl (cp_person_id              igs_he_ad_dtl.person_id%TYPE,
                               cp_admission_appl_number  igs_he_ad_dtl.admission_appl_number%TYPE,
                               cp_nominated_course_cd    igs_he_ad_dtl.nominated_course_cd%TYPE ,
                               cp_sequence_number        igs_he_ad_dtl.sequence_number%TYPE) IS
           SELECT  domicile_cd,
                   special_student_cd
           FROM   igs_he_ad_dtl
           WHERE  person_id             = cp_person_id
           AND    admission_appl_number = cp_admission_appl_number
           AND    nominated_course_cd   = cp_nominated_course_cd
           AND    sequence_number       = cp_sequence_number;

           l_he_ad_dtl c_he_ad_dtl%ROWTYPE;

            -- Get the person number for reporting into log file
           CURSOR cur_person_num (cp_person_id  igs_pe_person_base_v.person_id%TYPE) IS
           SELECT person_number
           FROM igs_pe_person_base_v
           WHERE person_id = cp_person_id;

           l_person_number igs_pe_person_base_v.person_number%TYPE;

             -- QUAL1 and QUAL2 out parameter/local variables
            l_oss_qual1   igs_he_ex_rn_dat_fd.value%TYPE;
            l_oss_qual2   igs_he_ex_rn_dat_fd.value%TYPE;
            l_hesa_qual1  igs_he_ex_rn_dat_fd.value%TYPE;
            l_hesa_qual2  igs_he_ex_rn_dat_fd.value%TYPE;
            l_hesa_classification igs_he_ex_rn_dat_fd.value%TYPE;

             -- LOCSDY out parameter/local variables
            l_oss_locsdy    igs_he_ex_rn_dat_fd.value%TYPE;
            l_hesa_locsdy   igs_he_ex_rn_dat_fd.value%TYPE;

             -- RSNLEAVE out parameter/local variables
            l_rsn_inst_left    igs_he_ex_rn_dat_fd.value%TYPE;

             -- DOMICILE out parameter/local variables
            l_hesa_domicile   igs_he_ex_rn_dat_fd.value%TYPE;

              -- MODE out parameter/local variables
            l_mode  igs_he_ex_rn_dat_fd.value%TYPE;

             -- Special Student out parameter/local variables
            l_oss_special_student  igs_he_ex_rn_dat_fd.value%TYPE;
            l_hesa_special_student  igs_he_ex_rn_dat_fd.value%TYPE;

              -- MSTUFEE out parameter/local variables
            l_hesa_mstufee  igs_he_ex_rn_dat_fd.value%TYPE;

            l_include VARCHAR2(1);
            l_qualified_teacher VARCHAR2(1);
            l_pt_study VARCHAR2(1);

      -- smaddali added following cursors for HECR214 - term based fees enhancement build, bug#3291656

      -- Get the latest Term record for the Leavers,where the student left date lies between term start and end dates
      CURSOR c_term_lev( cp_person_id  igs_en_spa_terms.person_id%TYPE,
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
      c_term_lev_rec   c_term_lev%ROWTYPE ;

      -- Get the latest term record for the Continuing students, where the term start date lies in the HESA submission period
      CURSOR c_term_con ( cp_person_id          igs_en_spa_terms.person_id%TYPE,
                          cp_course_cd          igs_en_spa_terms.program_cd%TYPE,
                          cp_sub_start_dt       igs_he_submsn_header.enrolment_start_date%TYPE ,
                          cp_sub_end_dt         igs_he_submsn_header.enrolment_end_date%TYPE) IS
      SELECT  tr.program_version , tr.acad_cal_type, tr.location_cd, tr.attendance_mode, tr.attendance_type
      FROM  igs_en_spa_terms tr , igs_ca_inst_all ca
      WHERE  tr.term_cal_type = ca.cal_type AND
             tr.term_sequence_number = ca.sequence_number AND
             tr.person_id = cp_person_id AND
             tr.program_cd = cp_course_cd AND
             ca.start_dt BETWEEN cp_sub_start_dt AND cp_sub_end_dt
      ORDER BY  ca.start_dt DESC;
      c_term_con_rec    c_term_con%ROWTYPE ;
      l_lev_dt   igs_en_stdnt_ps_att_all.discontinued_dt%TYPE ;

   BEGIN

         -- Get the values to be used as parameters to call HESA field derivation procedures
         -- Get the reporting dates
         l_he_sub_header        := NULL ;
         OPEN cur_he_sub_header (p_submission_name) ;
         FETCH cur_he_sub_header INTO l_he_sub_header;
         CLOSE cur_he_sub_header;

         -- get yop details
         l_yop_susa     := NULL ;
         OPEN c_yop_susa (p_person_id,
                          p_course_cd,
                          l_he_sub_header.enrolment_start_date,
                          l_he_sub_header.enrolment_end_date ) ;
         FETCH c_yop_susa INTO l_yop_susa;
         CLOSE c_yop_susa;

         -- Get the SPA details
         l_spa  := NULL ;
         OPEN c_spa (p_person_id,
                     p_course_cd) ;
         FETCH c_spa INTO l_spa;
         CLOSE c_spa;

           -- smaddali added following code for HECR214 - term based fees enhancement build , Bug#3291656
           -- to get version_number,cal_type,location_cd, attendance_type and mode from the Term record
           -- Get the Leaving date for the student
           l_lev_dt     := NULL;
           l_lev_dt       := NVL(l_spa.course_rqrmnts_complete_dt,l_spa.discontinued_dt) ;

           -- For Leavers students the following is the logic
           IF P_qual_type = 'L' THEN
                -- get the latest term record within which the Leaving date falls
                      c_term_lev_rec        := NULL ;
                      OPEN c_term_lev (p_person_id, p_course_cd, l_lev_dt );
                      FETCH c_term_lev INTO c_term_lev_rec ;
                      IF c_term_lev%FOUND THEN
                             -- Override the location_cd,cal_type,version_number,attendance_type,attendance_mode
                             -- in the SCA record with the term record values
                             l_spa.version_number       := c_term_lev_rec.program_version ;
                             l_spa.cal_type             := c_term_lev_rec.acad_cal_type ;
                             l_spa.location_cd          := c_term_lev_rec.location_cd ;
                             l_spa.attendance_mode      := c_term_lev_rec.attendance_mode ;
                             l_spa.attendance_type      := c_term_lev_rec.attendance_type ;
                      END IF ;
                      CLOSE c_term_lev ;

           -- For Research students the following is the logic
           ELSIF P_qual_type = 'R' THEN
                -- If the research student is a leaver(i.e leaving date falls within the Qualifying period)
                -- then get the latest term rec where the leaving date falls within the term calendar start and end dates
                IF  l_lev_dt BETWEEN p_qual_start_dt AND p_qual_end_dt THEN
                      c_term_lev_rec        := NULL ;
                      OPEN c_term_lev (p_person_id, p_course_cd, l_lev_dt );
                      FETCH c_term_lev INTO c_term_lev_rec ;
                      IF c_term_lev%FOUND THEN
                             -- Override the location_cd,cal_type,version_number,attendance_type,attendance_mode
                             -- in the SCA record with the term record values
                             l_spa.version_number       := c_term_lev_rec.program_version ;
                             l_spa.cal_type             := c_term_lev_rec.acad_cal_type ;
                             l_spa.location_cd          := c_term_lev_rec.location_cd ;
                             l_spa.attendance_mode      := c_term_lev_rec.attendance_mode ;
                             l_spa.attendance_type      := c_term_lev_rec.attendance_type ;
                      END IF ;
                      CLOSE c_term_lev ;

                -- Else the student is continuing student then get the latest term rec
                -- where the Term start date falls within the HESA Submission start and end dates
                ELSE
                        -- Get the latest term record which falls within the FTE period and term start date > commencement dt
                        c_term_con_rec  := NULL ;
                        OPEN c_term_con(p_person_id, p_course_cd,l_he_sub_header.enrolment_start_date,l_he_sub_header.enrolment_end_date);
                        FETCH c_term_con INTO c_term_con_rec ;
                        IF c_term_con%FOUND THEN
                             -- Override the location_cd,cal_type,version_number,attendance_type,attendance_mode
                             -- in the SCA record with the term record values
                             l_spa.version_number       := c_term_con_rec.program_version ;
                             l_spa.cal_type             := c_term_con_rec.acad_cal_type ;
                             l_spa.location_cd          := c_term_con_rec.location_cd ;
                             l_spa.attendance_mode      := c_term_con_rec.attendance_mode ;
                             l_spa.attendance_type      := c_term_con_rec.attendance_type ;
                        END IF ;
                        CLOSE c_term_con ;
                END IF ; -- if student is leaving / continuing

           END IF;   -- if qualifying type is L/R

         -- get the poous details
         -- smaddali modified call to this cursor to pass l_spa.version_number instead of p_version_number
         -- as part of HECR214 - term based fees enhancement, Bug#3291656
         l_he_poous     := NULL ;
         OPEN  cur_he_poous (p_course_cd,
                             l_spa.version_number,
                             l_spa.cal_type,
                             l_spa.location_cd,
                             l_spa.attendance_mode,
                             l_spa.attendance_type,
                             l_yop_susa.unit_set_cd,
                             l_yop_susa.us_version_number);
         FETCH cur_he_poous INTO l_he_poous;
         CLOSE cur_he_poous;

         -- get the he admission details
         l_he_ad_dtl    := NULL ;
         OPEN c_he_ad_dtl (p_person_id,
                           l_spa.adm_admission_appl_number,
                           l_spa.adm_nominated_course_cd,
                           l_spa.adm_sequence_number);
         FETCH c_he_ad_dtl INTO l_he_ad_dtl ;
         CLOSE c_he_ad_dtl;

         --Get the person number for reporting purpose
         l_person_number        := NULL ;
         OPEN cur_person_num (p_person_id);
         FETCH cur_person_num INTO l_person_number;
         CLOSE cur_person_num;

     p_include := 'Y';

           -- For Leavers students the following is the logic
           IF P_qual_type = 'L' THEN

              -- Derive the QUAL1, QUAL2, LOCSDY, RSNLEAVE, DOMICILE and MODE field values
                       l_oss_qual1  := NULL;
                       l_oss_qual2  := NULL;
                       l_hesa_qual1 := NULL;
                       l_hesa_qual2 := NULL;
                       l_hesa_classification := NULL;

          -- Derive the QUAL1 (37) and QUAL2 (38) field values,
                 igs_he_extract_fields_pkg.get_qual_obtained
                      (p_person_id      =>  p_person_id,
                       p_course_cd      =>  p_course_cd,
                       p_enrl_start_dt  =>  l_he_sub_header.enrolment_start_date,
                       p_enrl_end_dt    =>  l_he_sub_header.enrolment_end_date,
                       p_oss_qual_obt1  =>  l_oss_qual1,
                       p_oss_qual_obt2  =>  l_oss_qual2,
                       p_hesa_qual_obt1 =>  l_hesa_qual1,
                       p_hesa_qual_obt2 =>  l_hesa_qual2,
                       p_classification =>  l_hesa_classification);

                     IF  l_hesa_qual1 IS NULL AND l_hesa_qual2 IS NULL THEN
                            p_include:= 'N';
                           fnd_message.set_name('IGS','IGS_HE_QUAL_FAIL_TO_DERIVE');
                           fnd_message.set_token('PERSON_NUMBER', l_person_number);
                           fnd_message.set_token('COURSE', p_course_cd);
                           fnd_file.put_line(fnd_file.log, fnd_message.get);
                 ELSIF (l_hesa_qual1 IS NULL OR l_hesa_qual1 NOT IN ('02','03','04','05','06','07','08','12','13','14','18','20','21','22','23','28','29','30','33','41','42') )
                        AND (l_hesa_qual2 IS NULL OR l_hesa_qual2 NOT IN ('02','03','04','05','06','07','08','12','13','14','18','20','21','22','23','28','29','30','33','41','42')) THEN
                            --Person failed to satisfy the qualification field validation, so report it in the log file
                            p_include:= 'N';
                            fnd_message.set_name('IGS','IGS_HE_QUAL_VALID_FAILED');
                            fnd_message.set_token('PERSON_NUMBER', l_person_number);
                            fnd_message.set_token('COURSE', p_course_cd);
                            fnd_message.set_token('QUAL1', l_hesa_qual1 );
                            fnd_message.set_token('QUAL2', l_hesa_qual2);
                            fnd_file.put_line(fnd_file.log, fnd_message.get);
                      END IF;

                      -- Get the location_of_study
                      -- smaddali modified call to this cursor to pass l_spa.version_number instead of p_version_number
                      -- as part of HECR214 - term based fees enhancement, Bug#3291656
                      l_he_st_prog      := NULL ;
                      OPEN cur_he_st_prog (p_course_cd,
                                           l_spa.version_number) ;
                      FETCH cur_he_st_prog INTO l_he_st_prog;
                      CLOSE cur_he_st_prog;

                        l_oss_locsdy := NULL;
                        l_hesa_locsdy := NULL;

                    -- Derive the LOCSDY (Field 71) value
                   igs_he_extract_fields_pkg.get_study_location (
                             p_susa_study_location  => l_yop_susa.study_location,
                             p_poous_study_location => l_he_poous.location_of_study,
                             p_prg_study_location   => l_he_st_prog.location_of_study,
                             p_oss_study_location   => l_oss_locsdy,
                             p_hesa_study_location  => l_hesa_locsdy);

                        -- If field value null or field value is not in the list then report the message in the log file
                       IF l_hesa_locsdy IS NULL THEN
                           p_include:= 'N';
                          fnd_message.set_name('IGS','IGS_HE_LOCSDY_FAIL_TO_DERIVE');
                          fnd_message.set_token('PERSON_NUMBER', l_person_number);
                          fnd_message.set_token('COURSE', p_course_cd);
                          fnd_file.put_line(fnd_file.log, fnd_message.get);
                       ELSIF  l_hesa_locsdy = '7' THEN
                            p_include:= 'N';
                          fnd_message.set_name('IGS','IGS_HE_LOCSDY_VALID_FAILED');
                          fnd_message.set_token('PERSON_NUMBER', l_person_number);
                          fnd_message.set_token('COURSE', p_course_cd);
                          fnd_message.set_token('LOCSDY', l_hesa_locsdy);
                          fnd_file.put_line(fnd_file.log, fnd_message.get);
                       END IF;

           -- Derive RSNLEAVE (field 33) value
                   l_rsn_inst_left := NULL;
                   igs_he_extract_fields_pkg.get_rsn_inst_left(
                            p_person_id        =>  p_person_id,
                            p_course_cd        =>  P_course_cd,
                            p_crs_req_comp_ind =>  l_spa.course_rqrmnt_complete_ind,
                            p_crs_req_comp_dt  =>  l_spa.course_rqrmnts_complete_dt,
                            p_disc_reason_cd   =>  l_spa.discontinuation_reason_cd,
                            p_disc_dt          =>  l_spa.discontinued_dt,
                            p_enrl_start_dt    =>  l_he_sub_header.enrolment_start_date,
                            p_enrl_end_dt      =>  l_he_sub_header.enrolment_end_date,
                            p_rsn_inst_left    =>  l_rsn_inst_left);

                         -- If the field value is not in the list then report the message in log file
                         IF l_rsn_inst_left = '05' THEN
                             p_include:= 'N';
                            fnd_message.set_name('IGS','IGS_HE_RSNLEAVE_VALID_FAILED');
                            fnd_message.set_token('PERSON_NUMBER', l_person_number);
                            fnd_message.set_token('COURSE', p_course_cd);
                            fnd_message.set_token('RSNLEAVE', l_rsn_inst_left);
                            fnd_file.put_line(fnd_file.log, fnd_message.get);
                         END IF;

                       -- Derive DOMICILE (Field 12) value
                          l_hesa_domicile := NULL;
                    igs_he_extract_fields_pkg.get_domicile(
                           p_ad_domicile    => l_he_ad_dtl.domicile_cd,
                           p_spa_domicile   => l_spa.domicile_cd,
                           p_hesa_domicile  => l_hesa_domicile);

                         -- If field value is null or field value is not in the list then report the message in log file
                         IF l_hesa_domicile IS NULL THEN
                              p_include:= 'N';
                             fnd_message.set_name('IGS','IGS_HE_DOMICILE_FAIL_TO_DERIVE');
                             fnd_message.set_token('PERSON_NUMBER', l_person_number);
                             fnd_message.set_token('COURSE', p_course_cd);
                             fnd_file.put_line(fnd_file.log, fnd_message.get);
                         ELSIF l_hesa_domicile NOT IN ('1610','1614','1641','1651','1653','1656','1659','1661','1676','1678','1693',
                                          '1710','1728','1751','1755','3826','4826','5826','6826','7826','8826',
                                          '1638','1639','1670','1700','1727','1831','1832','1833','1835','1850') THEN
                             p_include:= 'N';
                            fnd_message.set_name('IGS','IGS_HE_DOMICILE_VALID_FAILED');
                            fnd_message.set_token('PERSON_NUMBER', l_person_number);
                            fnd_message.set_token('COURSE', p_course_cd);
                            fnd_message.set_token('DOMICILE', l_hesa_domicile);
                            fnd_file.put_line(fnd_file.log, fnd_message.get);
                         END IF;

           -- Derive MODE (70) field value
                     l_mode := NULL;
                   igs_he_extract_fields_pkg.get_mode_of_study
                              (p_person_id         =>  p_person_id,
                               p_course_cd         =>  P_course_cd,
                               p_version_number    =>  p_version_number,
                               p_enrl_start_dt     =>  l_he_sub_header.enrolment_start_date,
                               p_enrl_end_dt       =>  l_he_sub_header.enrolment_end_date,
                               p_susa_study_mode   =>  l_yop_susa.study_mode,
                               p_poous_study_mode  =>  l_he_poous.mode_of_study,
                               p_attendance_type   =>  l_spa.attendance_type,
                               p_mode_of_study     =>  l_mode);

                         -- If field value is null or field value is not in the list then report the message in log file
                        IF l_mode IS NULL THEN
                             p_include:= 'N';
                            fnd_message.set_name('IGS','IGS_HE_MODE_FAIL_TO_DERIVE');
                            fnd_message.set_token('PERSON_NUMBER', l_person_number);
                            fnd_message.set_token('COURSE', p_course_cd);
                            fnd_file.put_line(fnd_file.log, fnd_message.get);
                         ELSIF l_mode = '63' OR l_mode = '64' THEN
                             p_include:= 'N';
                            fnd_message.set_name('IGS','IGS_HE_MODE_VALID_FAILED');
                            fnd_message.set_token('PERSON_NUMBER', l_person_number);
                            fnd_message.set_token('COURSE', p_course_cd);
                            fnd_message.set_token('MODE', l_mode);
                            fnd_file.put_line(fnd_file.log, fnd_message.get);
                        END IF;

                     -- Check whether the field values satisfies the condition
                      IF  p_include = 'N' THEN

                         -- Student failed to satisfy the field validation
                          p_include := 'N';
                          p_qualified_teacher := 'N';
                          p_pt_study := 'N';
                      ELSE
                          -- Student satisfied the field validations  then return Y
                          p_include := 'Y';
                           -- Get the qualified_teacher column value
                          IF l_hesa_qual1 IN ('12','13','20') OR l_hesa_qual2 IN ('12','13','20') THEN
                             p_qualified_teacher := 'Y';
                          ELSE
                             p_qualified_teacher := 'N';
                          END IF;
                          -- get the PT_study column value
                          IF l_mode IN ('31','33','34','35','38','39','64') THEN
                             p_pt_study := 'Y';
                          ELSE
                             p_pt_study := 'N';
                          END IF;
                      END IF;

            -- for research students derive the field values
           ELSIF P_qual_type = 'R' THEN


                   -- Derive MSTUFEE (68) field value,
                   -- For Deriving MSTUFEE, required to pass special student (28), Mode of study (70) and Amount of tuituin fee (83) field values
                   -- Pass NULL to amount of tuition fee, this is not used while deriving MSTUFEE field value in the code
                   -- So first calculate Special student and MODE field values
                   --  MSTUFEE
                   --         |--- 28 (special student)
                   --         |--- 70 (Mode of study)
                   --         |--- 83 (Amt of tuition fee) Pass null, this value is not used to derive MSTUFEE field in get_maj_src_tu_fee
                   --

                       -- Derive Special Student (28) field value
                       l_oss_special_student := NULL;
                           l_hesa_special_student := NULL;

                       igs_he_extract_fields_pkg.get_special_student
                                  (p_ad_special_student   => l_he_ad_dtl.special_student_cd,
                                   p_spa_special_student  => l_spa.special_student,
                                   p_oss_special_student  => l_oss_special_student,
                                   p_hesa_special_student => l_hesa_special_student);

                        -- Calculate the MODE of study (70) value
                           l_mode := NULL;
                        igs_he_extract_fields_pkg.get_mode_of_study
                                  (p_person_id         =>  p_person_id,
                                   p_course_cd         =>  p_course_cd,
                                   p_version_number    =>  p_version_number,
                                   p_enrl_start_dt     =>  l_he_sub_header.enrolment_start_date,
                                   p_enrl_end_dt       =>  l_he_sub_header.enrolment_end_date,
                                   p_susa_study_mode   =>  l_yop_susa.study_mode,
                                   p_poous_study_mode  =>  l_he_poous.mode_of_study,
                                   p_attendance_type   =>  l_spa.attendance_type,
                                   p_mode_of_study     =>  l_mode);

                      -- Now calculate the major source of tuition fees (68) fieldvalue,
                 l_hesa_mstufee := NULL;
                      igs_he_extract_fields_pkg.get_maj_src_tu_fee
                                          (p_person_id         => p_person_id,
                                           p_enrl_start_dt     => l_he_sub_header.enrolment_start_date,
                                           p_enrl_end_dt       => l_he_sub_header.enrolment_end_date,
                                           p_special_stdnt     => l_hesa_special_student,
                                           p_study_mode        => l_mode,
                                           p_amt_tu_fee        => NULL,
                                           p_susa_mstufee      => l_yop_susa.student_fee,
                                           p_hesa_mstufee      => l_hesa_mstufee);

                             -- If field value is null or field value is not in the list then report the message in log file
                              IF l_hesa_mstufee IS NULL THEN
                                 p_include:= 'N';
                                 fnd_message.set_name('IGS','IGS_HE_MSTUFEE_FAIL_TO_DERIVE');
                                 fnd_message.set_token('PERSON_NUMBER', l_person_number);
                                 fnd_message.set_token('COURSE', p_course_cd);
                                 fnd_file.put_line(fnd_file.log, fnd_message.get);
                              ELSIF l_hesa_mstufee NOT IN ('11','12','13','14','15','16','17','19') THEN
                                 p_include:= 'N';
                                 fnd_message.set_name('IGS','IGS_HE_MSTUFEE_VALID_FAILED');
                                 fnd_message.set_token('PERSON_NUMBER', l_person_number);
                                 fnd_message.set_token('COURSE', p_course_cd);
                                 fnd_message.set_token('MSTUFEE', l_hesa_mstufee);
                                 fnd_file.put_line(fnd_file.log, fnd_message.get);
                              END IF;

                       -- Derive Reason for leaving institution (RSNLEAVE Field 33)
                          l_rsn_inst_left := NULL;
                       igs_he_extract_fields_pkg.get_rsn_inst_left
                                     (p_person_id        => P_person_id,
                                      p_course_cd        => p_course_cd,
                                      p_crs_req_comp_ind => l_spa.course_rqrmnt_complete_ind,
                                      p_crs_req_comp_dt  => l_spa.course_rqrmnts_complete_dt,
                                      p_disc_reason_cd   => l_spa.discontinuation_reason_cd,
                                      p_disc_dt          => l_spa.discontinued_dt,
                                      p_enrl_start_dt    => l_he_sub_header.enrolment_start_date,
                                      p_enrl_end_dt      => l_he_sub_header.enrolment_end_date,
                                      p_rsn_inst_left    => l_rsn_inst_left);

                            -- If field value is not in the list then report the message in log file
                            IF l_rsn_inst_left = '05' THEN
                               p_include:= 'N';
                               fnd_message.set_name('IGS','IGS_HE_RSNLEAVE_VALID_FAILED');
                               fnd_message.set_token('PERSON_NUMBER', l_person_number);
                               fnd_message.set_token('COURSE', p_course_cd);
                               fnd_message.set_token('RSNLEAVE', l_rsn_inst_left);
                               fnd_file.put_line(fnd_file.log, fnd_message.get);
                            END IF;

              -- Check whether the student satisfies the field validation
                      IF  p_include = 'N' THEN
                         -- Student failed to satisfy the field validation
                          p_include := 'N';
                          p_qualified_teacher := 'N';
                          p_pt_study := 'N';
                      ELSE
                          -- Student satisfied the field validations  then return Y
                          p_include := 'Y';
                          p_qualified_teacher := 'N';
                          p_pt_study := 'N';
                      END IF;

           END IF;  -- Qualifying period type

   EXCEPTION
     WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','igs_he_identify_target_pop.dlhe_review_spa');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        App_Exception.Raise_Exception;

   END dlhe_review_spa;

END igs_he_identify_target_pop;

/
