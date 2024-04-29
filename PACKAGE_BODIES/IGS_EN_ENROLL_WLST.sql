--------------------------------------------------------
--  DDL for Package Body IGS_EN_ENROLL_WLST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_ENROLL_WLST" AS
/* $Header: IGSEN73B.pls 120.9 2005/12/12 03:32:10 appldev ship $ */

/*** Enrolling Persons - Called in loop for Validated filtered student PL/SQL tables **/
    PROCEDURE Enroll_Persons(p_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE,
                           p_person_id igs_pe_person.person_id%TYPE,
                           p_course_cd igs_en_su_attempt.course_cd%TYPE,
                           p_waitlist_actual IN OUT NOCOPY igs_ps_unit_ofr_opt.waitlist_actual%TYPE,
                           p_enrollment_actual IN OUT NOCOPY igs_ps_unit_ofr_opt.enrollment_actual%TYPE,
                           p_max_quota IN igs_ps_usec_lim_wlst.enrollment_maximum%TYPE,
                           p_max_stdnts_per_wlst  igs_ps_usec_lim_wlst.max_students_per_waitlist%TYPE,
                           p_enrolled_yn  OUT NOCOPY VARCHAR2 ,
                           p_unit_cd igs_en_su_attempt.unit_cd%TYPE,
                           p_version_number igs_en_su_attempt.version_number%TYPE,
                           p_message_name OUT NOCOPY fnd_new_messages.message_name%TYPE
                           ) AS


      /******************************************************************
      Created By         :Syam
      Date Created By    :
      Purpose            :Enrolling Persons - Called in loop for Validated filtered student PL/SQL tables
      Known limitations,
      enhancements,
      remarks            :


      Change History
      Who         When        What
      jbegum      25-Jun-2003 BUG#2930935 - Modified cursor unit_ver_min_pts_cur
      kkillams    19-June-03  Added code to log messages raised in exception block in Enroll_Persons.
      Nishikant   13jun2002   some commented code were removed as per bug#2413811
      ptandon     26 Jun 2003 Modified to display person_number of students enrolled from Waitlist. - Bug# 2841584
      ptandon     05-SEP-2003 Added to more parameters WLST_PRIORITY_WEIGHT_NUM and
                              WLST_PRIORITY_WEIGHT_NUM in call to igs_en_sua_api.update_unit_attempt
                              as part of Waitlist Enhancements Build. Enh Bug# 3052426.
      ******************************************************************/


    CURSOR c_sua
    IS
      SELECT sua.ROWID,  sua.*
      FROM   IGS_EN_SU_ATTEMPT sua
      WHERE  uoo_id=p_uoo_id
      AND    unit_attempt_status = 'WAITLISTED'
      AND    person_id = p_person_id
      AND    course_cd = p_course_cd;

    CURSOR unit_ver_min_pts_cur
    IS
      SELECT NVL(cps.enrolled_credit_points,uv.enrolled_credit_points),
             uv.points_override_ind
      FROM   igs_ps_unit_ver uv,
             igs_ps_usec_cps cps,
             igs_ps_unit_ofr_opt uoo
      WHERE  uoo.uoo_id = cps.uoo_id(+) AND
             uoo.unit_cd = uv.unit_cd AND
             uoo.version_number = uv.version_number AND
             uoo.uoo_id = p_uoo_id;

    CURSOR usec_min_pts_cur
    IS
      SELECT minimum_credit_points
      FROM igs_ps_usec_cps
      WHERE uoo_id = p_uoo_id;

    lv_rec_ind NUMBER;
    lv_enrolled_yn VARCHAR2(1);
    lv_minimum_credit_points igs_ps_usec_cps.minimum_credit_points%TYPE;
    lv_enrolled_credit_points igs_ps_unit_ver.enrolled_credit_points%TYPE;
    lv_points_override_ind igs_ps_unit_ver.points_override_ind%TYPE;
    l_exp_err  VARCHAR2(2000);

    CURSOR c_find_person_no
    IS
      SELECT party_number
      FROM hz_parties
      WHERE party_id=p_person_id;

    v_person_number igs_pe_person.person_number%TYPE;

  /** Start of enrol persons **/


  BEGIN --Enroll_Persons

         lv_enrolled_yn := 'N';
         p_enrolled_yn := 'N' ;

         OPEN unit_ver_min_pts_cur;
         FETCH unit_ver_min_pts_cur INTO lv_enrolled_credit_points,
                                         lv_points_override_ind;
         CLOSE unit_ver_min_pts_cur;

         OPEN  usec_min_pts_cur;
         FETCH usec_min_pts_cur INTO lv_minimum_credit_points;
         CLOSE usec_min_pts_cur;

      FOR i IN c_sua  LOOP

      -- Commented the following code as part of bug# 2396138.
          /*   IF lv_points_override_ind = 'Y' THEN
                  i.override_enrolled_cp :=lv_minimum_credit_points;
                ELSIF lv_points_override_ind = 'N' THEN
                  i.override_enrolled_cp :=lv_enrolled_credit_points;
                END IF;
       */
                BEGIN

                -- Call the API to update the student unit attempt. This API is a
                -- wrapper to the update row of the TBH.
                igs_en_sua_api.update_unit_attempt(
                                                 x_rowid=>i.ROWID,
                                                 x_person_id=>i.person_id,
                                                 x_course_cd=>i.course_cd,
                                                 x_unit_cd=>i.unit_cd,
                                                 x_cal_type=>i.cal_type,
                                                 x_ci_sequence_number=>i.ci_sequence_number,
                                                 x_version_number=>i.version_number,
                                                 x_location_cd=>i.location_cd,
                                                 x_unit_class=>i.unit_class,
                                                 x_ci_start_dt=>i.ci_start_dt,
                                                 x_ci_end_dt=>i.ci_end_dt,
                                                 x_uoo_id=>i.uoo_id,
                                                 x_enrolled_dt=>SYSDATE,
                                                 x_unit_attempt_status=>'ENROLLED',
                                                 x_administrative_unit_status=>i.administrative_unit_status,
                                                 x_discontinued_dt=>i.discontinued_dt,
                                                 x_dcnt_reason_cd =>i.dcnt_reason_cd ,
                                                 x_rule_waived_dt=>i.rule_waived_dt,
                                                 x_rule_waived_person_id=>i.rule_waived_person_id,
                                                 x_no_assessment_ind=>i.no_assessment_ind,
                                                 x_sup_unit_cd=>i.sup_unit_cd,
                                                 x_sup_version_number=>i.sup_version_number,
                                                 x_exam_location_cd=>i.exam_location_cd,
                                                 x_alternative_title=>i.alternative_title,
                                                 x_override_enrolled_cp=>i.override_enrolled_cp,
                                                 x_override_eftsu=>i.override_eftsu,
                                                 x_override_achievable_cp=>i.override_achievable_cp,
                                                 x_override_outcome_due_dt=>i.override_outcome_due_dt,
                                                 x_override_credit_reason=>i.override_credit_reason,
                                                 x_administrative_priority=>i.administrative_priority,
                                                 x_waitlist_dt=> NULL,          -- i.waitlist_dt, -- Update the waitlist_dt with 'Null'. This is as per the Bug# 2335455.
                                                 x_gs_version_number => i.gs_version_number,
                                                 x_enr_method_type => i.enr_method_type,
                                                 x_failed_unit_rule    => i.failed_unit_rule,
                                                 x_cart => 'N',  -- ( Enrolment Done - so removed from cart )
                                                 x_rsv_seat_ext_id     => i.rsv_seat_ext_id,
                                                 x_mode=>'R',
                                                 x_org_unit_cd => i.org_unit_cd,
                                                 -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
                                                 x_session_id  => i.session_id,
                                                 -- Added the column grading schema as a part pf the bug 2037897. - aiyer
                                                 X_GRADING_SCHEMA_CODE => i.grading_schema_code,
                                                 -- Added the column Deg_Aud_Detail_Id as part of
                                                 -- Degree Audit Interface build. Bug# 2033208 - by pradhakr
                                                 X_DEG_AUD_DETAIL_ID   => i.deg_aud_detail_id ,
                                                 X_SUBTITLE             =>  i.subtitle,
                                                 X_STUDENT_CAREER_TRANSCRIPT =>  i.student_career_transcript,
                                                 X_STUDENT_CAREER_STATISTICS =>  i.student_career_statistics,
                                                 X_ATTRIBUTE_CATEGORY        =>  i.attribute_category,
                                                 X_ATTRIBUTE1                =>  i.attribute1,
                                                 X_ATTRIBUTE2                =>  i.attribute2,
                                                 X_ATTRIBUTE3                =>  i.attribute3,
                                                 X_ATTRIBUTE4                =>  i.attribute4,
                                                 X_ATTRIBUTE5                =>  i.attribute5,
                                                 X_ATTRIBUTE6                =>  i.attribute6,
                                                 X_ATTRIBUTE7                =>  i.attribute7,
                                                 X_ATTRIBUTE8                =>  i.attribute8,
                                                 X_ATTRIBUTE9                =>  i.attribute9,
                                                 X_ATTRIBUTE10               =>  i.attribute10,
                                                 X_ATTRIBUTE11               =>  i.attribute11,
                                                 X_ATTRIBUTE12               =>  i.attribute12,
                                                 X_ATTRIBUTE13               =>  i.attribute13,
                                                 X_ATTRIBUTE14               =>  i.attribute14,
                                                 X_ATTRIBUTE15               =>  i.attribute15,
                                                 X_ATTRIBUTE16               =>  i.attribute16,
                                                 X_ATTRIBUTE17               =>  i.attribute17,
                                                 X_ATTRIBUTE18               =>  i.attribute18,
                                                 X_ATTRIBUTE19               =>  i.attribute19,
                                                 X_ATTRIBUTE20               =>  i.attribute20,
                                                 X_WAITLIST_MANUAL_IND       =>  i.waitlist_manual_ind, --Added by mesriniv for Bug 2554109 Mini Waitlist Build.
                                                 -- Added WLST_PRIORITY_WEIGHT_NUM and WLST_PRIORITY_WEIGHT_NUM as part of Enh. Bug# 3052426 - ptandon
						 X_WLST_PRIORITY_WEIGHT_NUM  =>  i.wlst_priority_weight_num,
                                                 X_WLST_PREFERENCE_WEIGHT_NUM  =>  i.wlst_preference_weight_num,
						 X_CORE_INDICATOR_CODE       =>  i.core_indicator_code
						);
              -- Enrolled:
              OPEN c_find_person_no;
              FETCH c_find_person_no INTO v_person_number;
              CLOSE c_find_person_no;

                Fnd_Message.Set_Name ('IGS','IGS_EN_STDNT_ENRD');
                fnd_file.put_line (fnd_file.LOG, ' '|| fnd_message.get ||': '|| v_person_number);

              /*** Reducing actual waitlist by 1 used for processing only  - table updation done by en_sua TBH***/
                p_waitlist_actual := p_waitlist_actual - 1;

              /** Increasing actual enrolment by 1 used for processing only  - table updation done by en_sua TBH***/
                p_enrollment_actual := p_enrollment_actual + 1;

                        EXCEPTION
                                WHEN OTHERS THEN
                                    p_enrolled_yn := 'N' ;
                                    -- Log the exception raised into the log file
                                    l_exp_err := fnd_message.get();
                                    IF l_exp_err is NOT NULL THEN
                                      fnd_file.put_line (fnd_file.LOG, l_exp_err);
                                    ELSE
                                      fnd_file.put_line (fnd_file.LOG, SQLERRM);
                                    END IF;


                                    p_message_name := 'IGS_EN_STDNT_NOT_ENRD' ;
                                     --  to set message that enrolment failed --
                                           Fnd_Message.Set_Name ('IGS','IGS_EN_STDNT_NOT_ENRD');
                                           fnd_file.put_line (fnd_file.LOG, ' '||fnd_message.get_string ('IGS','IGS_EN_STDNT_NOT_ENRD') ||' '||
                                                         TO_CHAR(i.person_id));
                                     --   to set message that enrolment failed --
                                   RETURN;

                END;
      END LOOP;


     p_enrolled_yn := 'Y' ;

-- some commented code were here and removed as per bug#2413811
  END Enroll_Persons;


/** Procedure to validate the unit -- All existing validations **/
    FUNCTION validate_unit
    (p_unit_cd               IN igs_ps_unit_ofr_opt.unit_cd%TYPE,
     p_version_number        IN igs_ps_unit_ofr_opt.version_number%TYPE,
     p_cal_type              IN igs_ps_unit_ofr_opt.cal_type%TYPE,
     p_ci_sequence_number    IN igs_ps_unit_ofr_opt.ci_sequence_number%TYPE,
     p_location_cd           IN igs_ps_unit_ofr_opt.location_cd%TYPE,
     p_person_id             IN igs_en_su_attempt.person_id%TYPE,
     p_unit_class            IN igs_ps_unit_ofr_opt.unit_class%TYPE,
     p_uoo_id                IN igs_ps_unit_ofr_opt.uoo_id%TYPE,
     p_message_name          OUT NOCOPY fnd_new_messages.message_name%TYPE,
     p_deny_warn             OUT NOCOPY VARCHAR2,
     p_course_cd             IN igs_en_su_attempt.course_cd%TYPE)
      RETURN BOOLEAN AS
      /******************************************************************
            Created By         :Syam
            Date Created By    :
            Purpose            :Validation for Unit- Existing Validations
            Known limitations,
            enhancements,
            remarks            :

            Change History
            Who       When         What
           sarakshi  24-Feb-2003  Enh#2797116,modified cursor igs_ps_ofr_opt_cur to include delete_flag in
                                  the where clause
           ayedubat  30-MAY-2002  Added a new parameter,p_message_name to the Function:Enrp_Get_Rec_Window
                                  call and dsiplaying the returning message for the bug fix:2337161.
           kkillams  28-04-2003   modified igs_en_su_attempt_cur cursor where clause and impacted object,
                                  due to change in  Igs_En_Val_Sua.enrp_val_sua_dupl function signature
                                  w.r.t. bug number 2829262
           kkillams  19-June-03   Modified the validate_unit to add additional parameter p_course_cd, as existing cursor may fetch more than one program
                                  and also modified the cursor igs_en_su_attempt_cur for bug 2937182
      ******************************************************************/

      CURSOR igs_en_su_attempt_cur(cp_person_id igs_en_su_attempt.person_id%TYPE,
                                   cp_course_cd igs_en_su_attempt.course_cd%TYPE,
                                   cp_uoo_id igs_en_su_attempt.uoo_id%TYPE)
      IS
        SELECT unit_attempt_status
        FROM IGS_EN_SU_ATTEMPT
        WHERE person_id = cp_person_id
        AND   course_cd = cp_course_cd
        AND   uoo_id    = cp_uoo_id;


      CURSOR igs_en_stdnt_ps_att_cur (cp_course_cd igs_en_stdnt_ps_att.course_cd%TYPE,
                                      cp_person_id igs_en_stdnt_ps_att.person_id%TYPE)
      IS
        SELECT version_number,
               attendance_mode,
               attendance_type,
               course_attempt_status
      FROM igs_en_stdnt_ps_att
      WHERE course_cd = cp_course_cd
      AND   person_id = cp_person_id;

      CURSOR igs_ps_ofr_opt_cur (cp_course_cd IGS_PS_OFR_OPT.course_cd%TYPE,
                                 cp_version_number IGS_PS_OFR_OPT.version_number%TYPE,
                                 cp_cal_type IGS_PS_OFR_OPT.cal_type%TYPE,
                                 cp_location_cd IGS_PS_OFR_OPT.location_cd%TYPE,
                                 cp_attendance_mode IGS_PS_OFR_OPT.attendance_mode%TYPE,
                                 cp_attendance_type IGS_PS_OFR_OPT.attendance_type%TYPE)
      IS
        SELECT location_cd,
               coo_id
        FROM   IGS_PS_OFR_OPT
        WHERE  course_cd = cp_course_cd
        AND    version_number = cp_version_number
        AND    cal_type = cp_cal_type
        AND    location_cd = cp_location_cd
        AND    attendance_mode = cp_attendance_mode
        AND    attendance_type = cp_attendance_type
        AND    delete_flag = 'N';

      igs_ps_ofr_opt_cur_rec igs_ps_ofr_opt_cur%ROWTYPE;

      v_duplicate_course_cd igs_en_su_attempt.course_cd%TYPE;

    BEGIN

      FOR igs_en_su_attempt_cur_rec IN igs_en_su_attempt_cur(p_person_id,p_course_cd,p_uoo_id) LOOP

        FOR igs_en_stdnt_ps_att_cur_rec IN igs_en_stdnt_ps_att_cur(p_course_cd,
                                                                   p_person_id) LOOP

          IF NOT Igs_En_Val_Sua.enrp_val_sua_advstnd(p_person_id,
                                                     p_course_cd,
                                                     igs_en_stdnt_ps_att_cur_rec.version_number,
                                                     p_unit_cd,
                                                     p_version_number,
                                                     p_message_name ,
                                                     'N' ) THEN
              p_deny_warn := 'DENY';
              RETURN FALSE;
          END IF;
          IF NOT Igs_En_Val_Sua.resp_val_sua_cnfrm(p_person_id,
                                                   p_course_cd,
                                                   p_unit_cd,
                                                   p_version_number,
                                                   p_cal_type,
                                                   p_ci_sequence_number,
                                                   p_message_name ,
                                                   'N' ) THEN
              p_deny_warn := 'DENY';
              RETURN FALSE;
          END IF;
          IF NOT Igs_En_Gen_008.enrp_get_var_window(p_cal_type,
                                                    p_ci_sequence_number,
                                                    SYSDATE,
                                                    p_uoo_id) THEN
              p_message_name := 'IGS_EN_CANT_UPD_OUTS_ENRL';
              p_deny_warn := 'DENY';
              RETURN FALSE;
          END IF;
          IF NOT Igs_En_Gen_004.enrp_get_rec_window(p_cal_type,
                                                    p_ci_sequence_number,
                                                    SYSDATE,
                                                    p_uoo_id,
                                                    p_message_name) THEN
              p_message_name := p_message_name;
              p_deny_warn := 'DENY';
              RETURN FALSE;
          END IF;
          IF NOT Igs_En_Val_Sua.enrp_val_sua_intrmt(p_person_id,
                                                    p_course_cd,
                                                    p_cal_type,
                                                    p_ci_sequence_number,
                                                    p_message_name) THEN
              p_deny_warn := 'DENY';
              RETURN FALSE;
          END IF;
          OPEN igs_ps_ofr_opt_cur(p_course_cd,
                                  igs_en_stdnt_ps_att_cur_rec.version_number,
                                  p_cal_type,
                                  p_location_cd,
                                  igs_en_stdnt_ps_att_cur_rec.attendance_mode,
                                  igs_en_stdnt_ps_att_cur_rec.attendance_type);
          LOOP
            FETCH igs_ps_ofr_opt_cur INTO igs_ps_ofr_opt_cur_rec;
            IF igs_ps_ofr_opt_cur%NOTFOUND THEN
              CLOSE igs_ps_ofr_opt_cur;
              EXIT;
            END IF;

            IF NOT Igs_En_Val_Sua.enrp_val_coo_loc(igs_ps_ofr_opt_cur_rec.coo_id,
                                                   igs_ps_ofr_opt_cur_rec.location_cd,
                                                   p_message_name) THEN

                p_deny_warn := 'WARN';
                fnd_message.set_name('IGS',p_message_name);
                fnd_file.put_line (fnd_file.LOG, ' '||TO_CHAR(igs_ps_ofr_opt_cur_rec.coo_id) || ' ' ||
                                   igs_ps_ofr_opt_cur_rec.location_cd || ' ' ||
                                   fnd_message.get_string ('IGS',p_message_name));

                /**** Not Returning false as it is just a warning ***/
            END IF;


            IF NOT Igs_En_Val_Sua.enrp_val_coo_mode(igs_ps_ofr_opt_cur_rec.coo_id,
                                                    p_unit_class,
                                                    p_message_name) THEN
                p_deny_warn := 'WARN';
                fnd_message.set_name('IGS',p_message_name);
                fnd_file.put_line (fnd_file.LOG, ' '||TO_CHAR(igs_ps_ofr_opt_cur_rec.coo_id) || ' ' ||
                                   p_unit_class || ' ' ||
                                   fnd_message.get_string ('IGS',p_message_name));

                /**** Not Returning false as it is just a warning ***/


            END IF;

          END LOOP;

          IF NOT Igs_En_Val_Sua.enrp_val_sua_dupl(p_person_id,
                                                  p_course_cd,
                                                  p_unit_cd,
                                                  p_version_number,
                                                  p_cal_type,
                                                  p_ci_sequence_number,
                                                  IGS_EN_SU_ATTEMPT_cur_rec.unit_attempt_status,
                                                  v_duplicate_course_cd,
                                                  p_message_name,
                                                  p_uoo_id) THEN
            p_deny_warn := 'DENY';
            RETURN FALSE;
          END IF;

          IF NOT Igs_En_Val_Sua.enrp_val_sua_excld(p_person_id,
                                                   p_course_cd,
                                                   p_unit_cd,
                                                   p_cal_type,
                                                   p_ci_sequence_number,
                                                   p_message_name) THEN
            p_deny_warn := 'DENY';
            RETURN FALSE;
          END IF;


        END LOOP;
      END LOOP;
      p_deny_warn := NULL;
      RETURN TRUE;
  END validate_unit;

  /* Function to validate programs-New Validations - */

  FUNCTION validate_prog  (p_person_id      igs_en_su_attempt.person_id%TYPE,
                           p_cal_type       igs_ca_inst.cal_type%TYPE, --load calendar
                           p_ci_sequence_number igs_ca_inst.sequence_number%TYPE,  --load calendar
                           p_uoo_id     igs_ps_unit_ofr_opt.uoo_id%TYPE,
                           p_course_cd      igs_en_su_attempt.course_cd%TYPE,
                           p_enr_method_type    igs_en_su_attempt.enr_method_type%TYPE,
                           p_message_name   OUT NOCOPY VARCHAR2,
                           p_deny_warn      OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN AS

     /******************************************************************
            Created By         :Syam
            Date Created By    :
            Purpose            :Validation for Program- New Validations
            Known limitations,
            enhancements,
            remarks            :

            Change History
      Who        When           What
      ayedubat   07-JUN-2002   The function call,Igs_En_Gen_015.get_academic_cal is replaced with
                               Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd to get the academic calendar of the given
                               load calendar rather than current academic calendar for the bug fix: 2381603

        prraj      08-Apr-2002

      ******************************************************************/
  lv_person_type igs_pe_person_types.person_type_code%TYPE;

  CURSOR c_version_number
    IS
        SELECT  version_number
        FROM    igs_en_stdnt_ps_att
        WHERE   course_cd = p_course_cd
        AND     person_id = p_person_id;
  -- Cursor to get the Person Type Code corresponding to the System Type
  -- Added as per the bug# 2364461.
  CURSOR cur_per_typ IS
  SELECT person_type_code
  FROM   igs_pe_person_types
  WHERE  system_type = 'OTHER';
  l_cur_per_typ cur_per_typ%ROWTYPE;

  lv_version_number         igs_en_stdnt_ps_att.version_number%TYPE;
  lv_message                VARCHAR2(2000);
  lv_deny_warn              VARCHAR2(20);
  l_commencement_type       igs_en_cat_prc_dtl.S_STUDENT_COMM_TYPE%TYPE;
  l_enrollment_category     igs_en_cat_prc_dtl.enrolment_cat%TYPE;
  l_enrol_cal_type      igs_ca_type.cal_type%TYPE;
  l_enrol_sequence_number   igs_ca_inst_all.sequence_number%TYPE;
  l_acad_cal_type           igs_ca_inst.cal_type%TYPE;
  l_acad_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
  l_acad_start_dt   IGS_CA_INST.start_dt%TYPE;
  l_acad_end_dt     IGS_CA_INST.end_dt%TYPE;
  l_alternate_code  IGS_CA_INST.alternate_code%TYPE;
  l_dummy           VARCHAR2(200);

  BEGIN
    lv_message := NULL;

 /*** To get person type ***/
    OPEN cur_per_typ; --Added as per bug# 2364461
    FETCH cur_per_typ into l_cur_per_typ; --Added as per bug# 2364461
      lv_person_type := NVL(Igs_En_Gen_008.enrp_get_person_type(p_course_cd),l_cur_per_typ.person_type_code);
    CLOSE cur_per_typ; --Added as per bug# 2364461
 /*** To get person type ***/

  l_alternate_code := Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd(
                        p_cal_type                => p_cal_type,
                        p_ci_sequence_number      => p_ci_sequence_number,
                        p_acad_cal_type           => l_acad_cal_type,
                        p_acad_ci_sequence_number => l_acad_ci_sequence_number,
                        p_acad_ci_start_dt        => l_acad_start_dt,
                        p_acad_ci_end_dt          => l_acad_end_dt,
                        p_message_name            => lv_message );

    IF lv_message IS NOT NULL THEN
      p_message_name := lv_message;
      p_deny_warn := 'DENY';
      RETURN FALSE;
    END IF;

    l_enrollment_category := Igs_En_Gen_003.enrp_get_enr_cat(
                                    p_person_id => p_person_id,
                                    p_course_cd => p_course_cd,
                                    p_cal_type => l_acad_cal_type,
                                    p_ci_sequence_number => l_acad_ci_sequence_number,
                                    p_session_enrolment_cat =>NULL,
                                    p_enrol_cal_type => l_enrol_cal_type    ,
                                    p_enrol_ci_sequence_number => l_enrol_sequence_number,
                                    p_commencement_type => l_commencement_type,
                                    p_enr_categories  => l_dummy );



 /*** To get course version ***/
    OPEN  c_version_number;
    FETCH c_version_number INTO lv_version_number;
    CLOSE c_version_number;
 /*** To get course version ***/

    IF   Igs_En_Elgbl_Program.eval_program_steps( p_person_id  =>p_person_id,
                                                  p_person_type    =>lv_person_type,
                                                  p_load_calendar_type=> p_cal_type,
                                                  p_load_cal_sequence_number    =>p_ci_sequence_number,
                                                  p_uoo_id =>p_uoo_id,
                                                  p_program_cd           =>p_course_cd,
                                                  p_program_version       =>lv_version_number,
                                                  p_enrollment_category => l_enrollment_category,
                                                  p_comm_type      => l_commencement_type,
                                                  p_method_type     =>p_enr_method_type,
                                                  p_message  =>lv_message,
                                                  p_deny_warn        =>lv_deny_warn,
                                                  p_calling_obj      => 'JOB' ) THEN

                                   p_message_name := lv_message;
                                   p_deny_warn := lv_deny_warn;
                                   RETURN TRUE;
    ELSE

                                   p_message_name := lv_message;
                                   p_deny_warn := lv_deny_warn;
                                   RETURN FALSE;

    END IF;

  END validate_prog;

  FUNCTION validate_unit_steps  (p_person_id        igs_en_su_attempt.person_id%TYPE,
                                 p_cal_type     igs_ca_inst.cal_type%TYPE,
                                 p_ci_sequence_number   igs_ca_inst.sequence_number%TYPE,
                                 p_uoo_id       igs_ps_unit_ofr_opt.uoo_id%TYPE,
                                 p_course_cd        igs_en_su_attempt.course_cd%TYPE,
                                 p_enr_method_type  igs_en_su_attempt.enr_method_type%TYPE,
                                 p_message_name     OUT NOCOPY VARCHAR2,
                                 p_deny_warn        OUT NOCOPY VARCHAR2,
                                 p_calling_obj      IN VARCHAR2
                                 )
  RETURN BOOLEAN AS
  /*  HISTORY
    WHO       WHEN          WHAT
    stutta    20-Nov-2003   Replaced a cursor which returns program version with a terms api function call
                            to do the same. Done as part of term records build. Bug 2829263
    ayedubat  07-JUN-2002   The function call,Igs_En_Gen_015.get_academic_cal is replaced with
                            Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd to get the academic calendar of the given
                            load calendar rather than current academic calendar for the bug fix: 2381603

  */
  lv_person_type igs_pe_person_types.person_type_code%TYPE;

   -- Cursor to get the Person Type Code corresponding to the System Type
  -- Added as per the bug# 2364461.
  CURSOR cur_per_typ IS
  SELECT person_type_code
  FROM   igs_pe_person_types
  WHERE  system_type = 'OTHER';
  l_cur_per_typ cur_per_typ%ROWTYPE;

  lv_version_number     igs_en_stdnt_ps_att.version_number%TYPE;
  lv_message              VARCHAR2(2000);
  lv_deny_warn          VARCHAR2(20);
  l_commencement_type       igs_en_cat_prc_dtl.S_STUDENT_COMM_TYPE%TYPE;
  l_enrollment_category     igs_en_cat_prc_dtl.enrolment_cat%TYPE;
  l_enrol_cal_type      igs_ca_inst.cal_type%TYPE;
  l_enrol_sequence_number   igs_ca_inst.sequence_number%TYPE;

  l_acad_cal_type       igs_ca_inst.cal_type%TYPE;
  l_acad_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
  l_acad_start_dt   IGS_CA_INST.start_dt%TYPE;
  l_acad_end_dt     IGS_CA_INST.end_dt%TYPE;
  l_alternate_code  IGS_CA_INST.alternate_code%TYPE;
  l_dummy           VARCHAR2(200);


  BEGIN


 /*** To get person type ***/
    OPEN cur_per_typ; --Added as per bug# 2364461
    FETCH cur_per_typ into l_cur_per_typ; --Added as per bug# 2364461
      lv_person_type := NVL(Igs_En_Gen_008.enrp_get_person_type(p_course_cd),l_cur_per_typ.person_type_code);
    CLOSE cur_per_typ; --Added as per bug# 2364461
 /*** To get person type ***/

  l_alternate_code := Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd(
                        p_cal_type                => p_cal_type,
                        p_ci_sequence_number      => p_ci_sequence_number,
                        p_acad_cal_type           => l_acad_cal_type,
                        p_acad_ci_sequence_number => l_acad_ci_sequence_number,
                        p_acad_ci_start_dt        => l_acad_start_dt,
                        p_acad_ci_end_dt          => l_acad_end_dt,
                        p_message_name            => lv_message );

    IF lv_message IS NOT NULL THEN
      p_message_name := lv_message;
      p_deny_warn := 'DENY';
      RETURN FALSE;
    END IF;

    l_enrollment_category := Igs_En_Gen_003.enrp_get_enr_cat(
                                    p_person_id => p_person_id,
                                    p_course_cd => p_course_cd,
                                    p_cal_type => l_acad_cal_type,
                                    p_ci_sequence_number =>  l_acad_ci_sequence_number,
                                    p_session_enrolment_cat =>NULL,
                                    p_enrol_cal_type => l_enrol_cal_type    ,
                                    p_enrol_ci_sequence_number => l_enrol_sequence_number,
                                    p_commencement_type => l_commencement_type,
                                    p_enr_categories  => l_dummy );

 /*** To get course version ***/
    lv_version_number := igs_en_spa_terms_api.get_spat_program_version(
				p_person_id => p_person_id,
				p_program_cd => p_course_cd,
				p_term_cal_type => p_cal_type,
				p_term_sequence_number => p_ci_sequence_number);

    IF   Igs_En_Elgbl_Unit.eval_unit_steps(p_person_id        =>  p_person_id ,
                       p_person_type      =>  lv_person_type,
                       p_load_cal_type    =>  p_cal_type,
                       p_load_sequence_number =>  p_ci_sequence_number,
                       p_uoo_id       =>  p_uoo_id,
                       p_course_cd        =>  p_course_cd,
                       p_course_version   =>  lv_version_number,
                       p_enrollment_category  =>  l_enrollment_category,
                       p_enr_method_type      =>  p_enr_method_type,
                       p_comm_type        =>  l_commencement_type,
                       p_message          =>  lv_message,
                       p_deny_warn        =>  lv_deny_warn,
                       p_calling_obj      =>  p_calling_obj) THEN


       p_message_name := lv_message;
       p_deny_warn := lv_deny_warn;
       RETURN TRUE;
    ELSE

       p_message_name := lv_message;
       p_deny_warn := lv_deny_warn;
       -- if the message name is not null only then should the transaction be rolled back
       -- otherwise further processing should continue hence returning true if is null
       -- and false otherwise.
       IF p_message_name IS NOT NULL THEN
         RETURN FALSE;
       ELSE
         RETURN TRUE;
       END IF;

    END IF;


  END validate_unit_steps;

/**** Main function for validating prg , unit , unit steps ***/

  FUNCTION finalize_unit (p_person_id           igs_en_su_attempt.person_id%TYPE,
                          p_uoo_id              igs_ps_unit_ofr_opt.uoo_id%TYPE,
                          p_called_from_wlst    VARCHAR2,
                          p_unit_cd             igs_ps_unit_ofr_opt.unit_cd%TYPE,
                          p_version_number      igs_ps_unit_ofr_opt.version_number%TYPE,
                          p_cal_type            igs_ca_inst.cal_type%TYPE,
                          p_ci_sequence_number  igs_ca_inst.sequence_number%TYPE,
                          p_location_cd         igs_ps_unit_ofr_opt.location_cd%TYPE,
                          p_unit_class          igs_ps_unit_ofr_opt.unit_class%TYPE,
                          p_enr_method_type     igs_en_su_attempt.enr_method_type%TYPE,
                          p_course_cd           igs_en_su_attempt.course_cd%TYPE,
                          p_rsv_seat_ext_id     igs_en_su_attempt.rsv_seat_ext_id%TYPE,
                          p_message_name        OUT NOCOPY VARCHAR2)


  RETURN BOOLEAN AS
  /******************************************************************
  Created By         :Syam
  Date Created By    :
  Purpose            :Finalizing the Unit Contains Existin + New Unit and Program Validations
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who       When       What
  sommukhe  27-JUL-2005 Bug#4344483,Modified the call to igs_ps_unit_ofr_opt_pkg.update_row to include new parameter
                        abort_flag.
  sarakshi  22-Sep-2003 Enh#3052452, Modified the call to igs_ps_unit_ofr_opt_pkg.update_row to include new parameter
                        sup_uoo_id,relation_type,default_enroll_flag.
  vvutukur  05-Aug-2003 Enh#3045069.PSP Enh Build. Modified the call to igs_ps_unit_ofr_opt_pkg.update_row to include new parameter
                        not_multiple_section_flag.
  kkillams  24-04-2003 Passing NULL/0 depending on the IGS_EN_INCL_WLST_CP profile w.r.t. bug 2889975
  ptandon   26-06-2003 Modified to display Person Number and Unit Code instead of Person Id and Uoo Id in the log.
                     Modified to display Max CP failure Error Message once if the student fails the same. Bug# 2841584
  ******************************************************************/
  lv_validate_unit_message       fnd_new_messages.message_name%TYPE;
  lv_validate_unit_steps_message VARCHAR2(2000);
  lv_validate_prog_message       VARCHAR2(2000);
  lv_dummy_message               fnd_new_messages.message_name%TYPE;

  lv_unit_deny_warn VARCHAR2(100);
  lv_unit_steps_deny_warn VARCHAR2(100);
  lv_prog_deny_warn VARCHAR2(100);

  /*** Boolean variables to decide validation state **/
  lb_validate_unit          BOOLEAN := FALSE;
  lb_validate_unit_steps    BOOLEAN := FALSE;
  lb_validate_prog          BOOLEAN := FALSE;
  ln_message_count          NUMBER(4);
  lv_return_status          VARCHAR2(10);
  l_credit_points           NUMBER(10);
  /*** Boolean variables to decide validation state **/

  /** Cursor for UPDATE dir enrolment /or inq_not_wlst in IGS_PS_UNIT_OFR_OPT **/

        CURSOR c_unit_ofr_opt IS
        SELECT ROWID,
               ofr.*
        FROM  igs_ps_unit_ofr_opt ofr
        WHERE  uoo_id = p_uoo_id;


       v_unit_ofr_opt_rec c_unit_ofr_opt%ROWTYPE;

  /** Cursor for UPDATE dir enrolment  in IGS_PS_UNIT_OFR_OPT **/


  /** Cursor for UPDATE actual enrolment in igs_ps_rsv_ext **/

        CURSOR c_rsv_ext IS
        SELECT ROWID,
               rsv.*
        FROM   igs_ps_rsv_ext rsv
        WHERE  rsv_ext_id  = p_rsv_seat_ext_id;

       v_rsv_ext_rec c_rsv_ext%ROWTYPE;

  /** Cursor for UPDATE actual enrolment in igs_ps_rsv_ext **/

  /** Cursor for Delete record from  igs_en_su_attempt**/

        CURSOR c_del_sua IS
        SELECT ROWID
        FROM   igs_en_su_attempt
        WHERE  uoo_id = p_uoo_id
        AND person_id = p_person_id
        AND course_cd = p_course_cd;

       v_del_sua_rec c_del_sua%ROWTYPE;

  /** Cursor for Delete record from  igs_en_su_attempt**/

       CURSOR c_find_person_no IS
             SELECT party_number
             FROM hz_parties
             WHERE party_id=p_person_id;

       v_person_number igs_pe_person.person_number%TYPE;
       CURSOR c_incl_org_wlst_cp is
          SELECT asses_chrg_for_wlst_stud
          FROM IGS_EN_OR_UNIT_WLST
          WHERE cal_type = p_cal_type AND
          closed_flag = 'N' AND
          org_unit_cd = (SELECT NVL(uoo.owner_org_unit_cd, uv.owner_org_unit_cd)
                         FROM igs_ps_unit_ofr_opt uoo,
                              igs_ps_unit_ver uv
                          WHERE uoo.uoo_id = p_uoo_id AND
                                uv.unit_cd = uoo.unit_cd AND
                                uv.version_number = uoo.version_number);
       CURSOR c_incl_inst_wlst_cp is
         SELECT include_waitlist_cp_flag
         FROM IGS_EN_INST_WL_STPS;
  l_incl_wlst VARCHAR2(2);
  BEGIN

        p_message_name :=  null;

       OPEN c_find_person_no;
       FETCH c_find_person_no INTO v_person_number;
       CLOSE c_find_person_no;

        -- Passing 0 or NULL value to the credit points parameter of ss_eval_min_or_max_cp procedure
        -- depending include waitlist profile.
        l_credit_points := NULL;
        OPEN c_incl_org_wlst_cp;
        FETCH c_incl_org_wlst_cp INTO l_incl_wlst;
        IF (c_incl_org_wlst_cp%FOUND) THEN
              IF NVL(l_incl_wlst,'N') = 'Y' THEN
                 l_credit_points := 0;
              ELSE
                 l_credit_points := NULL;
              END IF;
        ELSE
           OPEN c_incl_inst_wlst_cp;
           FETCH c_incl_inst_wlst_cp INTO l_incl_wlst;
           IF c_incl_inst_wlst_cp%FOUND THEN
               IF (NVL(l_incl_wlst,'N') = 'Y') THEN
                  l_credit_points := 0;
               ELSE
                  l_credit_points := NULL;
               END IF;
           ELSE
               IF fnd_profile.value('IGS_EN_VAL_WLST') = 'Y' THEN
                  l_credit_points := 0;
               ELSE
                  l_credit_points := NULL;
               END IF;
           END IF;
           CLOSE c_incl_inst_wlst_cp;
        END IF;
        CLOSE c_incl_org_wlst_cp;
        /****************************************************************************
        Previously only validate_prog was being called. Since the min cp and max cp
        validation were commented out NOCOPY in the eval_program_steps, explicitly calling the
        same from here
        ****************************************************************************/
       lv_return_status := NULL;
       igs_en_enroll_wlst.ss_eval_min_or_max_cp(
                                p_person_id               => p_person_id,
                                p_load_cal_type           => p_cal_type,
                                p_load_ci_sequence_number => p_ci_sequence_number,
                                p_uoo_id                  => p_uoo_id,
                                p_program_cd              => p_course_cd,
                                p_step_type               => 'FMIN_CRDT',
                                p_credit_points           => l_credit_points,
                                p_message_name            => lv_validate_prog_message,
                                p_deny_warn               => lv_prog_deny_warn,
                                p_return_status           => lv_return_status,
                                p_enr_method              => p_enr_method_type
                            );
        IF lv_return_status = 'TRUE' THEN
          lb_validate_prog := TRUE;
        ELSIF lv_return_status = 'FALSE' AND lv_prog_deny_warn = 'WARN' THEN
      lb_validate_prog := TRUE;
        ELSE
      lb_validate_prog := FALSE;
        END IF;

        IF p_message_name IS NOT NULL AND lv_validate_prog_message IS NOT NULL THEN
          p_message_name := p_message_name || ';' || lv_validate_prog_message;
        ELSIF p_message_name IS NULL AND lv_validate_prog_message IS NOT NULL THEN
          p_message_name := lv_validate_prog_message;
        END IF;

    IF lb_validate_prog THEN
          lv_validate_prog_message :=  NULL;
          lv_return_status := NULL;
          igs_en_enroll_wlst.ss_eval_min_or_max_cp(
                                p_person_id               => p_person_id,
                                p_load_cal_type           => p_cal_type,
                                p_load_ci_sequence_number => p_ci_sequence_number,
                                p_uoo_id                  => p_uoo_id,
                                p_program_cd              => p_course_cd,
                                p_step_type               => 'FMAX_CRDT',
                                p_credit_points           => l_credit_points,
                                p_message_name            => lv_validate_prog_message,
                                p_deny_warn               => lv_prog_deny_warn,
                                p_return_status           => lv_return_status,
                                p_enr_method              => p_enr_method_type

                            );

        IF lv_return_status = 'TRUE' THEN
          lb_validate_prog := TRUE;
        ELSIF lv_return_status = 'FALSE' AND lv_prog_deny_warn = 'WARN' THEN
         lb_validate_prog := TRUE;
        ELSE
          lb_validate_prog := FALSE;
        END IF;

          IF p_message_name IS NOT NULL AND lv_validate_prog_message IS NOT NULL THEN
            p_message_name := p_message_name || ';' || lv_validate_prog_message;
          ELSIF p_message_name IS NULL AND  lv_validate_prog_message IS NOT NULL THEN
            p_message_name := lv_validate_prog_message;
          END IF;

          IF lb_validate_prog THEN
            /****************************************************************************
            Previously only validate_prog was being called. Since the min cp and max cp
            validation were commented out NOCOPY in the eval_program_steps, explicitly calling the
            same from here
            ****************************************************************************/

            lv_validate_prog_message :=  NULL;
            lv_return_status := NULL;
            lb_validate_prog := validate_prog (
                                    p_person_id          => p_person_id,
                                    p_cal_type           => p_cal_type,
                                    p_ci_sequence_number => p_ci_sequence_number,
                                    p_uoo_id             => p_uoo_id,
                                    p_course_cd          => p_course_cd,
                                    p_enr_method_type    => p_enr_method_type,
                                    p_message_name       => lv_validate_prog_message,
                                    p_deny_warn          => lv_prog_deny_warn);
           IF NOT lb_validate_prog AND lv_prog_deny_warn = 'WARN' THEN
              lb_validate_prog := TRUE;
           END IF;

           IF INSTR(lv_validate_prog_message,'*') > 0 THEN
            DECLARE
              v_temp_message_Str VARCHAR2(2000);
           BEGIN
              v_temp_message_Str := NULL;
              ln_message_count := Igs_En_Enroll_Wlst.get_message_count(lv_validate_prog_message);
              IF ln_message_count > 0 THEN
                FOR I IN 1..ln_message_count LOOP
                  lv_dummy_message := Igs_En_Enroll_Wlst.get_message(lv_validate_prog_message,I);
                  IF lv_dummy_message IS NOT NULL THEN
                     IF INSTR(lv_dummy_message,'*') > 0 THEN
                            lv_dummy_message := SUBSTR(lv_dummy_message,1,INSTR(lv_dummy_message,'*')-1) || '_NO_TOKEN' ;
                     END IF;

                     IF v_temp_message_Str IS NULL THEN
                            v_temp_message_Str := lv_dummy_message;
                     ELSE
                            v_temp_message_Str := v_temp_message_Str || ';' || lv_dummy_message;
                     END IF;
                ELSE
                    EXIT;
                  END IF;
                END LOOP;
              lv_validate_prog_message := v_temp_message_Str;
              END IF;
           END;
           END IF;

            IF p_message_name IS NOT NULL AND lv_validate_prog_message IS NOT NULL THEN
              p_message_name := p_message_name || ';' || lv_validate_prog_message;
            ELSIF p_message_name IS NULL AND lv_validate_prog_message IS NOT NULL THEN
              p_message_name := lv_validate_prog_message;
            END IF;

          END IF;
  END IF;


   /*** All program validations to be made here for both Y and N for Call from waitlist***/

        lv_validate_prog_message := p_message_name;
        IF lv_validate_prog_message IS NOT NULL THEN

          ln_message_count := Igs_En_Enroll_Wlst.get_message_count(lv_validate_prog_message);
          IF ln_message_count > 0 THEN
            FOR I IN 1..ln_message_count LOOP
              lv_dummy_message := Igs_En_Enroll_Wlst.get_message(lv_validate_prog_message,I);
              IF lv_dummy_message IS NOT NULL THEN
                fnd_message.set_name('IGS',lv_dummy_message);
                fnd_file.put_line (fnd_file.LOG, ' '|| p_unit_cd || ' ' || v_person_number || ' ' ||fnd_message.get);
              ELSE
                EXIT;
              END IF;
            END LOOP;
          END IF;

        END IF;

   /*** All program validations to be made here ***/

IF p_called_from_wlst = 'Y' THEN
   /*** All existing unit level validations takes place here ***/
        lv_validate_unit_message := null;
        IF  validate_unit (p_unit_cd => p_unit_cd,
                           p_version_number => p_version_number,
                           p_cal_type => p_cal_type,
                           p_ci_sequence_number => p_ci_sequence_number,
                           p_location_cd =>p_location_cd,
                           p_person_id =>p_person_id,
                           p_unit_class =>p_unit_class,
                           p_uoo_id => p_uoo_id,
                           p_message_name => lv_validate_unit_message,
                           p_deny_warn =>   lv_unit_deny_warn,
                           p_course_cd => p_course_cd) THEN

                /*** To set flag***/
                 lb_validate_unit := TRUE;
        ELSE

                /*** To set  flag***/
          IF lv_unit_deny_warn = 'WARN' THEN
            lb_validate_unit := TRUE;
      ELSE
            lb_validate_unit := FALSE;
      END IF;

        END IF;

        ln_message_count := Igs_En_Enroll_Wlst.get_message_count(lv_validate_unit_message);
        IF ln_message_count > 0 THEN
              FOR I IN 1..ln_message_count LOOP
            lv_dummy_message := Igs_En_Enroll_Wlst.get_message(lv_validate_unit_message,I);
            IF lv_dummy_message IS NOT NULL THEN
                      fnd_message.set_name('IGS',lv_dummy_message);
                      fnd_file.put_line (fnd_file.LOG, ' '|| p_unit_cd || ' ' || v_person_number || ' ' ||fnd_message.get);
            ELSE
                      EXIT;
            END IF;
          END LOOP;
        END IF;

                IF p_message_name IS NULL AND lv_validate_unit_message IS NOT NULL THEN
                  p_message_name := lv_validate_unit_message;
        ELSIF p_message_name IS NOT NULL AND lv_validate_unit_message IS NOT NULL THEN
          p_message_name := p_message_name || ';' || lv_validate_unit_message;
        END IF;



   /**** Call new unit step validations -- which returns either WARN DENY***/
   --added a new parameter value JOB_FROM_WAITLIST for bug 4580204
          IF  validate_unit_steps  (p_person_id => p_person_id,
                                    p_cal_type => p_cal_type,
                                    p_ci_sequence_number => p_ci_sequence_number,
                                    p_uoo_id => p_uoo_id,
                                    p_course_cd => p_course_cd,
                                    p_enr_method_type => p_enr_method_type,
                                    p_message_name =>  lv_validate_unit_steps_message,
                                    p_deny_warn => lv_unit_steps_deny_warn,
                                    p_calling_obj => 'JOB_FROM_WAITLIST') THEN


                /*** To set  flag***/
                lb_validate_unit_steps := TRUE;
         ELSE

                /*** To set  flag***/
        IF lv_unit_steps_deny_warn = 'WARN' THEN
          lb_validate_unit_steps := TRUE;
        ELSE
                  lb_validate_unit_steps := FALSE;
        END IF;
         END IF;


         DECLARE
           v_temp_message_Str VARCHAR2(2000);
     BEGIN

           v_temp_message_Str := NULL;
           ln_message_count := Igs_En_Enroll_Wlst.get_message_count(lv_validate_unit_steps_message);
           IF ln_message_count > 0 THEN
             FOR I IN 1..ln_message_count LOOP
               lv_dummy_message := Igs_En_Enroll_Wlst.get_message(lv_validate_unit_steps_message,I);
               IF lv_dummy_message IS NOT NULL THEN
                 IF INSTR(lv_dummy_message,'*') > 0 THEN
                   lv_dummy_message := SUBSTR(lv_dummy_message,1,INSTR(lv_dummy_message,'*')-1) || '_NO_TOKEN' ;
                 END IF;
                 fnd_message.set_name('IGS',lv_dummy_message);
                 fnd_file.put_line (fnd_file.LOG, ' '|| p_unit_cd || ' ' || v_person_number || ' ' ||fnd_message.get);
                 IF v_temp_message_Str IS NULL THEN
                   v_temp_message_Str := lv_dummy_message;
                 ELSE
                   v_temp_message_Str := v_temp_message_Str || ';' || lv_dummy_message;
                 END IF;
               ELSE
                 EXIT;
               END IF;
             END LOOP;
         lv_validate_unit_steps_message := v_temp_message_Str;
           END IF;

     END;

         IF p_message_name IS NULL AND lv_validate_unit_steps_message IS NOT NULL THEN
           p_message_name := lv_validate_unit_steps_message;
         ELSIF p_message_name IS NOT NULL AND lv_validate_unit_steps_message IS NOT NULL THEN
           p_message_name := p_message_name || ';' || lv_validate_unit_steps_message;
         END IF;


END IF;


        IF  (p_called_from_wlst = 'N') THEN
                IF (lb_validate_prog)   THEN

                   /** UPDATE dir enrolment  in IGS_PS_UNIT_OFR_OPT **/

                        OPEN c_unit_ofr_opt;
                        FETCH c_unit_ofr_opt INTO v_unit_ofr_opt_rec;
                        CLOSE c_unit_ofr_opt;

                        BEGIN
    -- Added auditable_ind and audit_permission_ind parameters as part of Bug# 2636716
                                igs_ps_unit_ofr_opt_pkg.update_row
                                        (x_rowid  =>   v_unit_ofr_opt_rec.ROWID,
                                         x_unit_cd =>  v_unit_ofr_opt_rec.unit_cd,
                                         x_version_number =>  v_unit_ofr_opt_rec.version_number ,
                                         x_cal_type  =>   v_unit_ofr_opt_rec.cal_type,
                                         x_ci_sequence_number => v_unit_ofr_opt_rec.ci_sequence_number,
                                         x_location_cd => v_unit_ofr_opt_rec.location_cd,
                                         x_unit_class  => v_unit_ofr_opt_rec.unit_class,
                                         x_uoo_id => v_unit_ofr_opt_rec.uoo_id,
                                         x_ivrs_available_ind  => v_unit_ofr_opt_rec.ivrs_available_ind,
                                         x_call_number  =>  v_unit_ofr_opt_rec.call_number,
                                         x_unit_section_status  =>  v_unit_ofr_opt_rec.unit_section_status,
                                         x_unit_section_start_date   => v_unit_ofr_opt_rec.unit_section_start_date,
                                         x_unit_section_end_date    => v_unit_ofr_opt_rec.unit_section_end_date,
                                         x_enrollment_actual  => v_unit_ofr_opt_rec.enrollment_actual,
                                         x_waitlist_actual  => v_unit_ofr_opt_rec.waitlist_actual,
                                         x_offered_ind  =>  v_unit_ofr_opt_rec.offered_ind,
                                         x_state_financial_aid => v_unit_ofr_opt_rec.state_financial_aid,
                                         x_grading_schema_prcdnce_ind  => v_unit_ofr_opt_rec.grading_schema_prcdnce_ind,
                                         x_federal_financial_aid  =>   v_unit_ofr_opt_rec.federal_financial_aid,
                                         x_unit_quota  =>  v_unit_ofr_opt_rec.unit_quota,
                                         x_unit_quota_reserved_places  =>  v_unit_ofr_opt_rec.unit_quota_reserved_places,
                                         x_institutional_financial_aid =>  v_unit_ofr_opt_rec.institutional_financial_aid,
                                         x_unit_contact    =>  v_unit_ofr_opt_rec.unit_contact,
                                         x_grading_schema_cd   =>   v_unit_ofr_opt_rec.grading_schema_cd,
                                         x_gs_version_number  =>  v_unit_ofr_opt_rec.gs_version_number,
                                         x_owner_org_unit_cd =>   v_unit_ofr_opt_rec.owner_org_unit_cd,
                                         x_attendance_required_ind => v_unit_ofr_opt_rec.attendance_required_ind,
                                         x_reserved_seating_allowed  => v_unit_ofr_opt_rec.reserved_seating_allowed,
                                         x_special_permission_ind  =>   v_unit_ofr_opt_rec.special_permission_ind,
                                         x_ss_display_ind =>   v_unit_ofr_opt_rec.ss_display_ind,
                                         x_mode  => 'R',
                                         x_ss_enrol_ind  => v_unit_ofr_opt_rec.ss_enrol_ind,
                                         x_dir_enrollment   => NVL(v_unit_ofr_opt_rec.dir_enrollment,0) + 1,  -- Only Column Updated to add 1
                                         x_enr_from_wlst   => v_unit_ofr_opt_rec.enr_from_wlst,
                                         x_inq_not_wlst  =>  v_unit_ofr_opt_rec.inq_not_wlst,
                                         x_rev_account_cd    => v_unit_ofr_opt_rec.rev_account_cd,
                     x_anon_unit_grading_ind   =>  v_unit_ofr_opt_rec.anon_unit_grading_ind       ,
                                         x_anon_assess_grading_ind =>  v_unit_ofr_opt_rec.anon_assess_grading_ind,
                     x_non_std_usec_ind => v_unit_ofr_opt_rec.non_std_usec_ind,
                     x_auditable_ind => v_unit_ofr_opt_rec.auditable_ind,
                     x_audit_permission_ind => v_unit_ofr_opt_rec.audit_permission_ind,
		     x_not_multiple_section_flag => v_unit_ofr_opt_rec.not_multiple_section_flag,
		     x_sup_uoo_id => v_unit_ofr_opt_rec.sup_uoo_id,
		     x_relation_type => v_unit_ofr_opt_rec.relation_type,
		     x_default_enroll_flag => v_unit_ofr_opt_rec.default_enroll_flag,
                     x_abort_flag => v_unit_ofr_opt_rec.abort_flag
                     );

                        END;

                   /** UPDATE dir enrolment  in IGS_PS_UNIT_OFR_OPT **/

                   RETURN TRUE;
                END IF;

                IF (NOT lb_validate_prog)  AND (lv_prog_deny_warn = 'DENY') THEN

                        /*** UPDATE  for IGS_PS_RSV_EXT -For actual seat enrolled - 1 **/

                        OPEN c_rsv_ext;
                        FETCH c_rsv_ext INTO v_rsv_ext_rec;
                        CLOSE c_rsv_ext;

                                -- Only x_actual_seat_enrolled Column Updated to substract 1
                        BEGIN
                                 igs_ps_rsv_ext_pkg.update_row(
                                                        x_rowid =>v_rsv_ext_rec.ROWID,
                                                        x_rsv_ext_id=>v_rsv_ext_rec.rsv_ext_id,
                                                        x_uoo_id=>v_rsv_ext_rec.uoo_id,
                                                        x_priority_id=>v_rsv_ext_rec.priority_id,
                                                        x_preference_id=>v_rsv_ext_rec.preference_id,
                                                        x_rsv_level=>v_rsv_ext_rec.rsv_level,
                                                        x_actual_seat_enrolled=>NVL(v_rsv_ext_rec.actual_seat_enrolled,0)  - 1,
                                                        x_mode => 'R');
                        END;
                        /*** UPDATE  for IGS_PS_RSV_EXT -For actual seat enrolled - 1 **/


                        /**** DELETE from igs_en_su_attempt for uoo_id***/

                        OPEN c_del_sua ;
                        FETCH c_del_sua INTO v_del_sua_rec;
                        CLOSE c_del_sua;

                        BEGIN
                                Igs_En_Su_Attempt_Pkg.delete_row(v_del_sua_rec.ROWID);
                        END;

                        /**** DELETE from igs_en_su_attempt for uoo_id***/

                        /*** update igs_ps_unit_ofr inq_not_wlst by 1 **/

                        OPEN c_unit_ofr_opt;
                        FETCH c_unit_ofr_opt INTO v_unit_ofr_opt_rec;
                        CLOSE c_unit_ofr_opt;

                        BEGIN
    -- Added auditable_ind and audit_permission_ind parameters as part of Bug# 2636716
                                igs_ps_unit_ofr_opt_pkg.update_row
                                        (x_rowid  =>   v_unit_ofr_opt_rec.ROWID,
                                         x_unit_cd =>  v_unit_ofr_opt_rec.unit_cd,
                                         x_version_number =>  v_unit_ofr_opt_rec.version_number ,
                                         x_cal_type  =>   v_unit_ofr_opt_rec.cal_type,
                                         x_ci_sequence_number => v_unit_ofr_opt_rec.ci_sequence_number,
                                         x_location_cd => v_unit_ofr_opt_rec.location_cd,
                                         x_unit_class  => v_unit_ofr_opt_rec.unit_class,
                                         x_uoo_id => v_unit_ofr_opt_rec.uoo_id,
                                         x_ivrs_available_ind  => v_unit_ofr_opt_rec.ivrs_available_ind,
                                         x_call_number  =>  v_unit_ofr_opt_rec.call_number,
                                         x_unit_section_status  =>  v_unit_ofr_opt_rec.unit_section_status,
                                         x_unit_section_start_date   => v_unit_ofr_opt_rec.unit_section_start_date,
                                         x_unit_section_end_date    => v_unit_ofr_opt_rec.unit_section_end_date,
                                         x_enrollment_actual  => v_unit_ofr_opt_rec.enrollment_actual,
                                         x_waitlist_actual  => v_unit_ofr_opt_rec.waitlist_actual,
                                         x_offered_ind  =>  v_unit_ofr_opt_rec.offered_ind,
                                         x_state_financial_aid => v_unit_ofr_opt_rec.state_financial_aid,
                                         x_grading_schema_prcdnce_ind  => v_unit_ofr_opt_rec.grading_schema_prcdnce_ind,
                                         x_federal_financial_aid  =>   v_unit_ofr_opt_rec.federal_financial_aid,
                                         x_unit_quota  =>  v_unit_ofr_opt_rec.unit_quota,
                                         x_unit_quota_reserved_places  =>  v_unit_ofr_opt_rec.unit_quota_reserved_places,
                                         x_institutional_financial_aid =>  v_unit_ofr_opt_rec.institutional_financial_aid,
                                         x_unit_contact    =>  v_unit_ofr_opt_rec.unit_contact,
                                         x_grading_schema_cd   =>   v_unit_ofr_opt_rec.grading_schema_cd,
                                         x_gs_version_number  =>  v_unit_ofr_opt_rec.gs_version_number,
                                         x_owner_org_unit_cd =>   v_unit_ofr_opt_rec.owner_org_unit_cd,
                                         x_attendance_required_ind => v_unit_ofr_opt_rec.attendance_required_ind,
                                         x_reserved_seating_allowed  => v_unit_ofr_opt_rec.reserved_seating_allowed,
                                         x_special_permission_ind  =>   v_unit_ofr_opt_rec.special_permission_ind,
                                         x_ss_display_ind =>   v_unit_ofr_opt_rec.ss_display_ind,
                                         x_mode  => 'R',
                                         x_ss_enrol_ind  => v_unit_ofr_opt_rec.ss_enrol_ind,
                                         x_dir_enrollment   => v_unit_ofr_opt_rec.dir_enrollment,
                                         x_enr_from_wlst   => v_unit_ofr_opt_rec.enr_from_wlst,
                                         x_inq_not_wlst  =>  NVL(v_unit_ofr_opt_rec.inq_not_wlst,0) + 1,
                                         x_rev_account_cd   =>  v_unit_ofr_opt_rec.rev_account_cd ,
                     x_anon_unit_grading_ind   =>  v_unit_ofr_opt_rec.anon_unit_grading_ind       ,
                                         x_anon_assess_grading_ind =>  v_unit_ofr_opt_rec.anon_assess_grading_ind,
                                         x_non_std_usec_ind => v_unit_ofr_opt_rec.non_std_usec_ind ,
                     x_auditable_ind => v_unit_ofr_opt_rec.auditable_ind,
                     x_audit_permission_ind => v_unit_ofr_opt_rec.audit_permission_ind,
		     x_not_multiple_section_flag => v_unit_ofr_opt_rec.not_multiple_section_flag,
     		     x_sup_uoo_id => v_unit_ofr_opt_rec.sup_uoo_id,
		     x_relation_type => v_unit_ofr_opt_rec.relation_type,
		     x_default_enroll_flag => v_unit_ofr_opt_rec.default_enroll_flag,
		     x_abort_flag => v_unit_ofr_opt_rec.abort_flag
                     );

                        END;

                        /*** update igs_ps_unit_ofr inq_not_wlst by 1 **/

                        RETURN FALSE;

                END IF;

        END IF;


        IF (p_called_from_wlst = 'Y') THEN

            IF lb_validate_prog   THEN

                IF lb_validate_unit THEN

                        IF lb_validate_unit_steps THEN
                                RETURN TRUE;
                        ELSE
                                RETURN FALSE;

                        END IF;

                ELSE
                        RETURN FALSE;
                END IF;

               ELSE
                RETURN FALSE;
             END IF;
        END IF;

  RETURN TRUE;

  END finalize_unit;


  /** For Combined validations for  Unit Steps and Units - Not used in this package  for external use**/
FUNCTION validate_combined_unit (
                p_person_id     IGS_EN_SU_ATTEMPT.person_id%TYPE,
                p_unit_cd       igs_ps_unit_ofr_opt.unit_cd%TYPE,
                p_version_number    igs_ps_unit_ofr_opt.version_number%TYPE,
                p_cal_type      igs_ca_inst.cal_type%TYPE,  -- load calendar
                p_ci_sequence_number    igs_ca_inst.sequence_number%TYPE,  -- load calendar
                p_location_cd       igs_ps_unit_ofr_opt.location_cd%TYPE,
                p_unit_class        igs_ps_unit_ofr_opt.unit_class%TYPE,
                p_uoo_id        igs_ps_unit_ofr_opt.uoo_id%TYPE,
                p_course_cd     igs_en_su_attempt.course_cd%TYPE,
                p_enr_method_type   igs_en_su_attempt.enr_method_type%TYPE,
                p_message_name      OUT NOCOPY VARCHAR2,
                p_deny_warn     OUT NOCOPY VARCHAR2,
                p_calling_obj   IN VARCHAR2
                )
RETURN BOOLEAN AS

lv_validate_unit_steps_message  VARCHAR2(2000);
lv_unit_steps_deny_warn     VARCHAR2(100);
lv_validate_unit_message    fnd_new_messages.message_name%TYPE;
lv_unit_deny_warn       VARCHAR2(100);

CURSOR c_teach_cal (cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT cal_type, ci_sequence_number
  FROM igs_ps_unit_ofr_opt
  WHERE uoo_id = cp_uoo_id;

lv_teach_cal_type           igs_ca_inst.cal_type%TYPE;
lv_teach_ci_sequence_number igs_ca_inst.sequence_number%TYPE;

BEGIN
/* Call old validate unit first and then  unit steps if true else return false with message */

        /* Cursor that returns the teaching calendar for a given uoo_id */
        OPEN c_teach_Cal(p_uoo_id);
        FETCH c_teach_cal INTO lv_teach_cal_type, lv_teach_ci_sequence_number;
        CLOSE c_teach_Cal;

        IF  validate_unit (p_unit_cd        =>  p_unit_cd,
                           p_version_number =>  p_version_number,
                           p_cal_type       =>  lv_teach_cal_type,  --teach calendar
                           p_ci_sequence_number =>  lv_teach_ci_sequence_number,  -- teach calendar
                           p_location_cd    =>  p_location_cd,
                           p_person_id      =>  p_person_id,
                           p_unit_class     =>  p_unit_class,
                           p_uoo_id         =>  p_uoo_id,
                           p_message_name   =>  lv_validate_unit_message,
                           p_deny_warn      =>  lv_unit_deny_warn,
                           p_course_cd      =>  p_course_cd) THEN


                           -- bypassing this for swap submitswap as unit steps should not
                           -- validated here as this method is called in a autonomous transaction
                           -- while unconfirming units and will not be considering units dropped in swap
                           -- Unit step validation is done before enrolling where it is not
                           -- a autonomous transaction and will be considering the dropped units
                           -- in swap.
                           IF p_calling_obj IN ('SWAP','SUBMITSWAP') THEN

                                 RETURN TRUE;
                           ELSE

                                  /**** Call new unit step validations if unit validations are thru */
                                  IF  validate_unit_steps  (p_person_id      =>  p_person_id,
                                                            p_cal_type       =>  p_cal_type,  --load calendar
                                                            p_ci_sequence_number =>  p_ci_sequence_number,  -- load calendar
                                                            p_uoo_id         =>  p_uoo_id,
                                                            p_course_cd      =>  p_course_cd,
                                                            p_enr_method_type    =>  p_enr_method_type,
                                                            p_message_name   =>  lv_validate_unit_steps_message,
                                                            p_deny_warn      =>  lv_unit_steps_deny_warn,
                                                            p_calling_obj    =>  p_calling_obj
                                                           )  THEN

                                        p_message_name := lv_validate_unit_steps_message;
                                        p_deny_warn  := lv_unit_steps_deny_warn;
                                        RETURN TRUE;
                                 ELSE
                                        p_message_name := lv_validate_unit_steps_message;
                                        p_deny_warn  := lv_unit_steps_deny_warn;
                                        RETURN FALSE;
                                 END IF;
                          END IF;

        ELSE
                  p_message_name := lv_validate_unit_message;
                  p_deny_warn := lv_unit_deny_warn;
                  RETURN FALSE;

        END IF;

END validate_combined_unit;

   -- This routine is used to enroll the student in NON Reserved Category
  PROCEDURE enroll_student_nonreserved (p_tab_succ_mail OUT NOCOPY tab_succ_mail,
                                        p_tab_fail_mail OUT NOCOPY tab_fail_mail,
                                        p_success_yn OUT NOCOPY VARCHAR2,
                                        p_uoo_id IN NUMBER )  AS
  /* History
     WHO        WHEN         WHAT
    kkillams   19-June-2003  Removed the logic of incrementing enr_from_wlst in igs_ps_unit_ofr, as the increment is happenig in SUA API
    pmarada    02-sep-2002   Commented the waitlist priority/preferences part of the code
                             as per of the bug 2526021
    ayedubat   12-JUN-2002   Changed the finalize_unit function call to pass the
                             Load Calendar instead of teaching calendar for the bug:2391510
    ptandon    26-Jun-2003   Modified to display waitlist details once before the enrollment process and once after the process. Bug# 2841584
    ptandon    05-SEP-2003   Removed the commented code. Enh. Bug No. 3052426
    ctyagi     10-OCT-2005   Modified for Bug 4329478
  */
         --for a Unit Section (uoo_id)
         lv_unit_cd igs_ps_unit_ofr_opt.unit_cd%TYPE; --unit code
         lv_version_number igs_ps_unit_ofr_opt.version_number%TYPE; --version number
         lv_cal_type igs_ps_unit_ofr_opt.cal_type%TYPE; --calendar type
         lv_ci_sequence_number igs_ps_unit_ofr_opt.ci_sequence_number%TYPE; --ci sequence number
         lv_location_cd igs_ps_unit_ofr_opt.location_cd%TYPE; --location code
         lv_unit_class igs_ps_unit_ofr_opt.unit_class%TYPE; --unit class
         lv_waitlist_actual igs_ps_unit_ofr_opt.waitlist_actual%TYPE; --actual waitlist
         lv_enrollment_actual igs_ps_unit_ofr_opt.enrollment_actual%TYPE; --actual enrollment

         lv_max_quota igs_ps_usec_lim_wlst.enrollment_maximum%TYPE; --maximun quota
         lv_max_stdnts_per_wlst igs_ps_usec_lim_wlst.max_students_per_waitlist%TYPE; --maximun students per waitlist
         lv_enrolled_yn VARCHAR2(1);
         --unit section (unit offering option -uoo_id)
         CURSOR igs_ps_unit_ofr_opt_cur
         IS
           SELECT unit_cd,
                  version_number,
                  cal_type,
                  ci_sequence_number,
                  location_cd,
                  unit_class,
                  waitlist_actual,
                  enrollment_actual
           FROM   igs_ps_unit_ofr_opt
           WHERE  unit_section_status = 'HOLD'
           AND    uoo_id = p_uoo_id;

          --maximum quota (max_quota) and maximum students per waitlist - Will be setting it to 9999 (unlimited) if null or no row
    CURSOR igs_ps_usec_lim_wlst_cur IS
            SELECT   NVL (usec.enrollment_maximum, NVL(uv.enrollment_maximum,9999) ) enrollment_maximum,
                     usec.max_students_per_waitlist
            FROM     igs_ps_usec_lim_wlst usec,
                     igs_ps_unit_ver uv,
                     igs_ps_unit_ofr_opt uoo
            WHERE    uoo.unit_cd = uv.unit_cd
            AND      uoo.version_number = uv.version_number
            AND      uoo.uoo_id = usec.uoo_id (+)
            AND      uoo.uoo_id = p_uoo_id;

      --- Cursor for Administrative preferences
       CURSOR c_adm_prf_cur
       IS
         SELECT ROWID,
                person_id,
                course_cd,
                unit_cd,
                version_number,
                cal_type,
                ci_sequence_number,
                location_cd,
                unit_class,
                ci_start_dt,
                ci_end_dt,
                uoo_id,
                enrolled_dt,
                unit_attempt_status,
                administrative_unit_status,
                discontinued_dt,
                rule_waived_dt,
                rule_waived_person_id,
                no_assessment_ind,
                sup_unit_cd,
                sup_version_number,
                exam_location_cd,
                alternative_title,
                override_enrolled_cp,
                override_eftsu,
                override_achievable_cp,
                override_outcome_due_dt,
                override_credit_reason,
                administrative_priority,
                waitlist_dt,
                rsv_seat_ext_id,
                enr_method_type
         FROM   igs_en_su_attempt
         WHERE  uoo_id=p_uoo_id
         AND    NVL(administrative_priority,0) <> 0
         AND    unit_attempt_status = 'WAITLISTED'
         ORDER BY administrative_priority;

       /* Declare Variables */
        val_success_adm_persons_tab tab_succ_mail;
        ln_rec_ind_val_success      NUMBER;
        ln_tab_succ_mail_ind        NUMBER;
        ln_tab_fail_mail_ind        NUMBER;
        val_success_nadm_persons_tab    tab_succ_mail;
        ln_nadm_val_success     NUMBER;
        lv_finalize_unit_message    VARCHAR2(2000);
        lv_enroll_message_name      fnd_new_messages.message_name%TYPE;
        filtered_sorted_tab     tab_succ_mail;
        ln_message_count        NUMBER(4);
        lv_dummy_message        fnd_new_messages.message_name%TYPE;

        -- cursor to fetch the First Load Calendar for the Teaching Calendar
        CURSOR cur_teach_to_load(p_cal_type IGS_CA_INST.cal_type%TYPE,
                         p_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
          SELECT load_cal_type,load_ci_sequence_number
          FROM IGS_CA_TEACH_TO_LOAD_V
          WHERE teach_cal_type = p_cal_type AND
                teach_ci_sequence_number = p_sequence_number AND
                load_end_dt >= TRUNC(SYSDATE)
          ORDER BY load_start_dt;

        rec_teach_to_load cur_teach_to_load%ROWTYPE;

       PROCEDURE write_status_to_log
       AS
       BEGIN
           --1) no of students in the waitlist
           Fnd_Message.Set_Name ('IGS','IGS_EN_NO_OF_STDNTS_IN_WLST');
           fnd_file.put_line (fnd_file.LOG, ' '|| fnd_message.get ||' '|| TO_CHAR(lv_waitlist_actual));

           --2) max. enrollments
           Fnd_Message.Set_Name ('IGS','IGS_EN_MAX_ENROLLMENTS');
           fnd_file.put_line (fnd_file.LOG, ' '|| fnd_message.get ||' '|| TO_CHAR(lv_max_quota));

           --3) actual enrollments
           Fnd_Message.Set_Name ('IGS','IGS_EN_ACT_ENROLLMENTS');
           fnd_file.put_line (fnd_file.LOG, ' '|| fnd_message.get ||' '|| TO_CHAR(lv_enrollment_actual));

           --4) max. students per waitlist
           Fnd_Message.Set_Name ('IGS','IGS_EN_MAX_STDNTS_PER_WLST');
           fnd_file.put_line (fnd_file.LOG, ' '|| fnd_message.get ||' '|| TO_CHAR(lv_max_stdnts_per_wlst));
       END write_status_to_log;

      BEGIN
        ln_rec_ind_val_success := 0;
        ln_tab_succ_mail_ind := 0;
        ln_tab_fail_mail_ind := 0;
        ln_nadm_val_success := 0;

        OPEN  igs_ps_unit_ofr_opt_cur;
        FETCH igs_ps_unit_ofr_opt_cur INTO lv_unit_cd,
                                           lv_version_number,
                                           lv_cal_type,
                                           lv_ci_sequence_number,
                                           lv_location_cd,
                                           lv_unit_class,
                                           lv_waitlist_actual,
                                           lv_enrollment_actual;

        OPEN igs_ps_usec_lim_wlst_cur;
        FETCH igs_ps_usec_lim_wlst_cur INTO lv_max_quota,
                                            lv_max_stdnts_per_wlst;
                IF igs_ps_usec_lim_wlst_cur%NOTFOUND THEN
                        lv_max_quota := 9999;
                        lv_max_stdnts_per_wlst := 9999;
                END IF;
        CLOSE igs_ps_usec_lim_wlst_cur;

        IF lv_max_quota IS NULL THEN
                lv_max_quota := 9999;
        END IF;

        IF lv_max_stdnts_per_wlst IS NULL THEN
                lv_max_stdnts_per_wlst := 9999;
        END IF;


          p_tab_fail_mail.DELETE;
          p_tab_succ_mail.DELETE;
          filtered_sorted_tab.DELETE;
          ln_tab_fail_mail_ind      :=NVL(p_tab_fail_mail.FIRST,0);
          ln_tab_succ_mail_ind      :=NVL(p_tab_succ_mail.FIRST,0);

          /********* For Students with administrative preferences ******/

          val_success_adm_persons_tab.DELETE;
          ln_rec_ind_val_success    :=NVL(val_success_adm_persons_tab.FIRST,0);

           -- Before Enrollment
           Fnd_Message.Set_Name ('IGS','IGS_EN_BEFORE_ENRMT');
           fnd_file.put_line (fnd_file.LOG, ' '|| fnd_message.get ||'->');
           write_status_to_log;
           fnd_file.put_line (fnd_file.LOG, ' ');

          FOR v_adm_prf_cur IN c_adm_prf_cur LOOP
                /* Call to finalize_unit to validate the units */

             -- Find the Load Calendar for the teaching calendar of the unit section
             OPEN cur_teach_to_load(v_adm_prf_cur.cal_type ,v_adm_prf_cur.ci_sequence_number );
             FETCH cur_teach_to_load INTO rec_teach_to_load;
             CLOSE cur_teach_to_load;
             SAVEPOINT failed_unit_validation;  -- If any validation failed then rollback, bug 2526021, pmarada.

             IF  finalize_unit( p_person_id     => v_adm_prf_cur.person_id,
                                p_uoo_id        => v_adm_prf_cur.uoo_id,
                                p_called_from_wlst => 'Y',
                                p_unit_cd =>v_adm_prf_cur.unit_cd,
                                p_version_number =>v_adm_prf_cur.version_number,
                                p_cal_type =>rec_teach_to_load.load_cal_type,
                                p_ci_sequence_number =>rec_teach_to_load.load_ci_sequence_number,
                                p_location_cd =>v_adm_prf_cur.location_cd,
                                p_unit_class =>v_adm_prf_cur.unit_class,
                                p_enr_method_type =>v_adm_prf_cur.enr_method_type,
                                p_course_cd =>v_adm_prf_cur.course_cd,
                                p_rsv_seat_ext_id => v_adm_prf_cur.rsv_seat_ext_id,
                                p_message_name => lv_finalize_unit_message ) THEN

                                ln_rec_ind_val_success := NVL(ln_rec_ind_val_success,0) + 1;  /*Increment  record*/
                                val_success_adm_persons_tab(ln_rec_ind_val_success).person_id := v_adm_prf_cur.person_id;
                                val_success_adm_persons_tab(ln_rec_ind_val_success).course_cd := v_adm_prf_cur.course_cd;
                                --    Added by  Chanchal
                                lv_enrolled_yn := 'N';
                                /* check for max quota*/
                                 IF (NVL(lv_max_quota,0) - NVL(lv_enrollment_actual,0))  > 0 THEN

                                    Enroll_Persons( p_uoo_id => p_uoo_id,
                                                    p_person_id => val_success_adm_persons_tab(ln_rec_ind_val_success).person_id ,
                                                    p_course_cd => val_success_adm_persons_tab(ln_rec_ind_val_success).course_cd,
                                                    p_waitlist_actual =>    lv_waitlist_actual,       -- IN OUT NOCOPY
                                                    p_enrollment_actual =>  lv_enrollment_actual,    -- IN OUT NOCOPY
                                                    p_max_quota       =>   lv_max_quota,            -- IN
                                                    p_max_stdnts_per_wlst =>  lv_max_stdnts_per_wlst,
                                                    p_enrolled_yn    =>   lv_enrolled_yn,           -- OUT NOCOPY
                                                    p_unit_cd        =>  lv_unit_cd,
                                                    p_version_number =>  lv_version_number,
                                                    p_message_name => lv_enroll_message_name);

                                     IF lv_enrolled_yn = 'Y' THEN
                                        /****update success mail pl/sql structure***/
                                        ln_tab_succ_mail_ind := NVL(ln_tab_succ_mail_ind,0) + 1; -- Increment succ records by 1
                                        p_tab_succ_mail(ln_tab_succ_mail_ind).person_id  := val_success_adm_persons_tab(ln_rec_ind_val_success).person_id;
                                        p_tab_succ_mail(ln_tab_succ_mail_ind).course_cd  := val_success_adm_persons_tab(ln_rec_ind_val_success).course_cd;
                                        IF (NVL(lv_max_quota,0) - NVL(lv_enrollment_actual,0))  <= 0 THEN
                                            EXIT;
                                        END IF;

                                     ELSIF  lv_enrolled_yn = 'N' THEN
                                        /***Update failure mail pl/sql structure**/
                                        ln_tab_fail_mail_ind := NVL(ln_tab_fail_mail_ind,0) + 1; -- Increment by failure records by 1
                                        p_tab_fail_mail(ln_tab_fail_mail_ind).person_id  := val_success_adm_persons_tab(ln_rec_ind_val_success).person_id;
                                        p_tab_fail_mail(ln_tab_fail_mail_ind).course_cd  := val_success_adm_persons_tab(ln_rec_ind_val_success).course_cd;
                                        p_tab_fail_mail(ln_tab_fail_mail_ind).message_name  := lv_enroll_message_name;
                                     END IF;
                                ELSE
                                    EXIT;
                                END IF;
                                --    Added by   Chanchal

            ELSE
               ln_tab_fail_mail_ind   := NVL(ln_tab_fail_mail_ind,0) + 1; -- Increment by failure records by 1
               p_tab_fail_mail(ln_tab_fail_mail_ind).person_id  := v_adm_prf_cur.person_id;
               p_tab_fail_mail(ln_tab_fail_mail_ind).course_cd  := v_adm_prf_cur.course_cd;
               p_tab_fail_mail(ln_tab_fail_mail_ind).message_name  :=  Igs_En_Enroll_Wlst.get_message(lv_finalize_unit_message,ln_message_count);

               -- Any unit validation failed then rollback. pmarada, bug 2526021
               ROLLBACK TO failed_unit_validation;

            END IF;

          END LOOP;

          /* Log Message if Students with ADMIN Preferences dont exist */

           IF (NVL(ln_rec_ind_val_success,0) =  0  AND NVL(ln_tab_fail_mail_ind,0) = 0) THEN
              fnd_message.set_name('IGS','IGS_EN_NO_ST_WLST_ADM');
              fnd_file.put_line (fnd_file.LOG, ' '|| fnd_message.get || ' ' || TO_CHAR(p_uoo_id));

           END IF;
            -- After Enrollment
           IF NVL(val_success_adm_persons_tab.COUNT,0) > 0 THEN

              fnd_file.put_line (fnd_file.LOG, ' ');
              Fnd_Message.Set_Name ('IGS','IGS_EN_AFTER_ENRMT');
              fnd_file.put_line (fnd_file.LOG, ' '|| fnd_message.get ||'->');
              write_status_to_log;
           END IF;




END enroll_student_nonreserved;

 --  The man Proc called from the CONC
PROCEDURE enroll_from_waitlist (errbuf  OUT NOCOPY VARCHAR2,
                                retcode OUT NOCOPY  NUMBER,
                                p_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE,
                                p_org_id IN NUMBER
                                ) AS
           /******************************************************************
                    Created By         :Syam
                    Date Created By    :
                    Purpose            :The main proc called from Conc Manager -
                    Known limitations,
                    enhancements,
                    remarks            :

                    Change History
                    Who       When         What
                    ayedubat  12-JUN-2002  Removed the messages logging into Log file if enroll_student_nonreserved
                                           or enroll_student_reserved functions are returning 'N' as we are already logging
                                           within the corresponding functions.

                    Procedure Enroll_From_WaitList  - Called from Conc Manager with uoo_id passed
		    ptandon   05-SEP-2003  Added a new validation to call enroll_student_nonreserved to process
		                           waitlisted students only if waitlisting is allowed at institution level and
					   not restricted at term calendar level otherwise log an error message
					   as part of Waitlist Enhancements Buld. Enh Bug# 3052426.
             ******************************************************************/

        /*** Declare PL/SQL structures for Output of enrol processes **/
        lv_tab_succ_mail  tab_succ_mail;
        lv_tab_fail_mail  tab_fail_mail;
        /*** Declare PL/SQL structures for Output of enrol processes **/

	--
	-- Cursor to get Load Calendar Type associated with a Unit Section. Enh Bug# 3052426 (ptandon)
        --
	CURSOR c_get_load_cal_type(cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
	SELECT ctl.load_cal_type
	FROM   igs_ca_teach_to_load_v ctl,
	       igs_ps_unit_ofr_opt uoo
	WHERE  uoo.uoo_id = cp_uoo_id
	AND    ctl.teach_cal_type = uoo.cal_type
	AND    ctl.teach_ci_sequence_number = uoo.ci_sequence_number
	AND    ctl.load_end_dt >= TRUNC(SYSDATE)
	ORDER BY ctl.load_start_dt;

	l_load_cal_type igs_ca_type.cal_type%TYPE;

	--
	-- Cursor to Check if Waitlisting is allowed at the institution level. Enh Bug# 3052426 (ptandon)
	--
	CURSOR c_wait_allow_inst_level IS
	SELECT waitlist_allowed_flag
	FROM igs_en_inst_wl_stps;

	--
	-- Cursor to Check if Waitlisting is allowed at the term calendar level. Enh Bug# 3052426 (ptandon)
	--
	CURSOR c_wait_allow_term_cal(cp_load_cal_type igs_en_inst_wlst_opt.cal_type%TYPE) IS
	SELECT waitlist_alwd
	FROM igs_en_inst_wlst_opt
	WHERE cal_type = cp_load_cal_type;

        l_waitlist_allowed igs_en_inst_wl_stps.waitlist_allowed_flag%TYPE;
        lv_success_yn VARCHAR2(1);

 -- Routine to send mails
PROCEDURE wf_send_mail_stud_adm  (p_tab_succ_mail  IN  tab_succ_mail,
                                  p_tab_fail_mail  IN  tab_fail_mail,
                                  p_uoo_id IN igs_ps_unit_ofr_opt.uoo_id%TYPE,
                                  p_org_id IN NUMBER)  AS

lv_fail_student_string VARCHAR2(4000);

BEGIN

    lv_fail_student_string := NULL;
     -- This section is for sending mails to successfully enrolled students
    IF NVL(p_tab_succ_mail.COUNT,0) > 0 THEN

        FOR succ_mail_rec IN 1..p_tab_succ_mail.COUNT LOOP
                Igs_En_Wlst_Gen_Proc.wf_send_mail_stud (  p_person_id   => p_tab_succ_mail(succ_mail_rec).person_id,
                                                          p_uoo_id      => p_uoo_id,
                                                          p_org_id      => p_org_id);
        END LOOP;

    END IF;

     -- This section is for sending mails to Administrator if student is not successfully enrolled
     IF NVL(p_tab_fail_mail.COUNT,0) > 0 THEN
        FOR fail_mail_rec IN 1..p_tab_fail_mail.COUNT LOOP
           lv_fail_student_string  := NVL(lv_fail_student_string,' ') ||' '|| TO_CHAR(p_tab_fail_mail(fail_mail_rec).person_id) ||':'||p_tab_fail_mail(fail_mail_rec).message_name;
        END LOOP;
        Igs_En_Wlst_Gen_Proc.wf_send_mail_adm   (  p_person_id_list => lv_fail_student_string,
                                                   p_uoo_id         => p_uoo_id,
                                                   p_org_id         => p_org_id  );
    END IF;

END wf_send_mail_stud_adm;

BEGIN -- Start of main procedure
        retcode :=0;
        igs_ge_gen_003.set_org_id(p_org_id);

	-- Check whether waitlisting is allowed at institution level. Bug# 3052426 (ptandon)
        OPEN c_wait_allow_inst_level;
	FETCH c_wait_allow_inst_level INTO l_waitlist_allowed;
	CLOSE c_wait_allow_inst_level;
	IF l_waitlist_allowed = 'Y' THEN
	   -- If allowed at institution level, check whether it is not restricted at term calendar level. Bug# 3052426 (ptandon)

	   -- Get the load calendar type
	   OPEN c_get_load_cal_type(p_uoo_id);
	   FETCH c_get_load_cal_type INTO l_load_cal_type;
	   CLOSE c_get_load_cal_type;

           OPEN c_wait_allow_term_cal(l_load_cal_type);
           FETCH c_wait_allow_term_cal INTO l_waitlist_allowed;
	   CLOSE c_wait_allow_term_cal;
        ELSE
           l_waitlist_allowed := 'N';
        END IF;

        IF l_waitlist_allowed = 'N' THEN
           fnd_message.set_name('IGS','IGS_EN_NO_ENR_WL_NOT_ALWD');
           fnd_file.put_line (fnd_file.LOG, ' '|| fnd_message.get || ' ');
	ELSE
	   -- Call enroll_student_nonreserved to process waitlisted students if waitlisting is allowed at
	   -- institution level and not restricted at term calendar level. Bug# 3052426 (ptandon)
	   enroll_student_nonreserved (p_tab_succ_mail => lv_tab_succ_mail
                                      ,p_tab_fail_mail => lv_tab_fail_mail
                                      ,p_success_yn => lv_success_yn,
                                       p_uoo_id => p_uoo_id); -- Call enroll student in NOT reserved - Out NOCOPY params tables for Succ students and failed students;

	   -- WORK FLOW  Event raised to send mail

	   IF NVL(FND_PROFILE.VALUE('IGS_WF_ENABLE'),'N') = 'Y'  THEN
                      wf_send_mail_stud_adm  (  p_tab_succ_mail  => lv_tab_succ_mail,
                                                p_tab_fail_mail  => lv_tab_fail_mail ,
                                                p_uoo_id         => p_uoo_id,
                                                p_org_id         => p_org_id);
           END IF;
	END IF;
EXCEPTION
    WHEN OTHERS THEN

        retcode:=2;
        fnd_file.put_line(fnd_file.LOG,SQLERRM);
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','Igs_En_Enroll_Wlst.Enroll_From_WaitList');
        IGS_GE_MSG_STACK.ADD;
        igs_ge_msg_stack.conc_exception_hndl;

END Enroll_From_WaitList; -- End of main procedure


FUNCTION  get_message  (p_messages VARCHAR2,
                        p_message_index NUMBER)
RETURN VARCHAR2 AS
    startpos    NUMBER(15) ;
    endpos      NUMBER(15);
    ret_value   NUMBER(15);
    delimit_count   NUMBER(15);
    mesg_count  NUMBER(15);
    req_message VARCHAR2(2000);
    big_message VARCHAR2(2000);
    DELIMITER   CONSTANT VARCHAR2(1) := ';' ;
BEGIN
    startpos := 0;
    endpos  := 0;
    ret_value := 0;
    delimit_count := 0;
    mesg_count := 0;
    req_message := NULL;

    IF (p_message_index < 1) THEN
        req_message := NULL;
        RETURN req_message;
    END IF;

    IF (LENGTH(TRIM(p_messages)) > 0) THEN
        big_message:= p_messages || DELIMITER ;

        LOOP
            delimit_count:= delimit_count + 1;
            ret_value:= INSTR(big_message, DELIMITER, 1, delimit_count);

            IF (ret_value = 0) THEN
               EXIT;
            END IF;

        END LOOP;

        mesg_count:= delimit_count - 1;

        IF (p_message_index <= mesg_count) THEN

            -- getting start delimiter pos for message
            IF (p_message_index = 1) THEN
                startpos:= 0;
            ELSE
                startpos :=  INSTR(big_message, DELIMITER, 1, p_message_index - 1);
            END IF;

            -- getting end delimiter pos for message
            endpos := INSTR(big_message, DELIMITER, 1, p_message_index);
            req_message :=  SUBSTR(big_message, (startpos+1), (endpos-1) - startpos);

        ELSE
            req_message := NULL;
        END IF;

    ELSE
        req_message := NULL;
    END IF;

    RETURN req_message;

END get_message;


FUNCTION get_message_count(p_messages IN VARCHAR2)
RETURN NUMBER AS
    mesg_count  NUMBER(15) ;
    delimit_count   NUMBER(15);
    ret_value   NUMBER(15);
    DELIMITER   CONSTANT VARCHAR2(1) := ';' ;
BEGIN
    mesg_count := 0;
    delimit_count := 0;
    ret_value := 0;

    IF (LENGTH(TRIM(p_messages)) < 1) OR p_messages is NULL THEN
        RETURN 0;
    ELSE
        LOOP
            delimit_count:= delimit_count + 1;
            ret_value:= INSTR(p_messages, DELIMITER, 1, delimit_count);

            IF (ret_value = 0) THEN
               EXIT;
            END IF;
        END LOOP;
        mesg_count:= delimit_count;
        RETURN mesg_count;
    END IF;
    RETURN 0;

END get_message_count;

PROCEDURE ss_eval_min_or_max_cp(
p_person_id                IN  igs_en_su_attempt.person_id%TYPE,
p_load_cal_type            IN  igs_ca_inst.cal_type%TYPE,
p_load_ci_sequence_number  IN  igs_ca_inst.sequence_number%TYPE,
p_uoo_id                   IN  igs_ps_unit_ofr_opt.uoo_id%TYPE,
p_program_cd               IN  igs_en_su_attempt.course_cd%TYPE,
p_step_type                IN  igs_en_cpd_ext.s_enrolment_step_type%TYPE,
p_credit_points            IN  NUMBER,
p_message_name             OUT NOCOPY VARCHAR2,
p_deny_warn                OUT NOCOPY VARCHAR2,
p_return_status            OUT NOCOPY VARCHAR2,
p_enr_method               IN  igs_en_cat_prc_dtl.enr_method_type%TYPE) AS
/*  HISTORY
  WHO         WHEN            WHAT
  stutta      20-Nov-2003     Replaced a cursor which would return a program_version with a terms api function call.
			      Done as part of term records build. Bug 2829263
  smanglm     24-jan-2003     call igs_en_gen_017.enrp_get_enr_method to decide enrollment method type
  Nishikant   18-OCT-2002     The call to the function Igs_En_Elgbl_Program.eval_min_cp got modified since the signatue
                              got modified. Enrl Elgbl and Validation Build. Bug#2616692.
  ayedubat    12-JUN-2002      Initialized the valriable,l_ret_value to TRUE for the bug fix:2391510
  ayedubat    07-JUN-2002      The function call,Igs_En_Gen_015.get_academic_cal is replaced with
                                Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd to get the academic calendar of the
                               given load calendar rather than current academic calendar for the bug fix:2381603
  Nishikant   01NOV2002      The call to the function igs_ss_enr_details.get_notification got modified to add two new
                             parameters p_person_id, p_message.
*/

  lv_person_type igs_pe_person_types.person_type_code%TYPE;

  -- Cursor to get the Person Type Code corresponding to the System Type
  -- Added as per the bug# 2364461.
  CURSOR cur_per_typ IS
  SELECT person_type_code
  FROM   igs_pe_person_types
  WHERE  system_type = 'OTHER';
  l_cur_per_typ cur_per_typ%ROWTYPE;

  lv_version_number         igs_en_stdnt_ps_att.version_number%TYPE;
  lv_message                VARCHAR2(2000);
--  lv_deny_warn              VARCHAR2(20);
  l_commencement_type       igs_en_cat_prc_dtl.S_STUDENT_COMM_TYPE%TYPE;
  l_enrollment_category     igs_en_cat_prc_dtl.enrolment_cat%TYPE;
  l_enr_method              igs_en_cat_prc_dtl.enr_method_type%TYPE;
  l_enrol_cal_type              igs_ca_type.cal_type%TYPE;
  l_enrol_sequence_number   igs_ca_inst_all.sequence_number%TYPE;
  l_acad_cal_type           igs_ca_inst.cal_type%TYPE;
  l_acad_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
  l_notification_flag       igs_en_cpd_ext.notification_flag%TYPE;
  l_ret_value               BOOLEAN := TRUE;
  --  lv_enrolment_step_type    igs_en_cpd_ext.s_enrolment_step_type%TYPE;
  l_acad_start_dt   IGS_CA_INST.start_dt%TYPE;
  l_acad_end_dt     IGS_CA_INST.end_dt%TYPE;
  l_alternate_code      IGS_CA_INST.alternate_code%TYPE;

  -- Below Two local variables added as part of Enrl Elgbl and Validation Build. Bug#2616692
  l_credit_points           igs_en_config_enr_cp.min_cp_per_term%TYPE := NULL;
  l_min_credit_point        igs_en_config_enr_cp.min_cp_per_term%TYPE := NULL;
  l_message                 VARCHAR2(2000);
  l_return_status           VARCHAR2(10);
  l_dummy                   VARCHAR2(200);

  BEGIN
    lv_message := NULL;

 /*** To get person type ***/
    OPEN cur_per_typ; --Added as per bug# 2364461
    FETCH cur_per_typ into l_cur_per_typ; --Added as per bug# 2364461
      lv_person_type := NVL(Igs_En_Gen_008.enrp_get_person_type(p_program_cd),l_cur_per_typ.person_type_code);
    CLOSE cur_per_typ; --Added as per bug# 2364461
 /*** To get person type ***/
    IF p_enr_method IS NULL THEN
       -- call igs_en_gen_017.enrp_get_enr_method to decide enrollment method type
       igs_en_gen_017.enrp_get_enr_method(
          p_enr_method_type => l_enr_method,
          p_error_message   => l_message,
          p_ret_status      => l_return_status);

       IF l_return_status = 'FALSE' THEN
           p_message_name := 'IGS_SS_EN_NOENR_METHOD' ;
           p_return_status := 'FALSE';
           p_deny_warn := 'DENY';
       END IF;
     ELSE
           l_enr_method:= p_enr_method;
     END IF;

    l_alternate_code := Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd(
                          p_cal_type                => p_load_cal_type,
                          p_ci_sequence_number      => p_load_ci_sequence_number,
                          p_acad_cal_type           => l_acad_cal_type,
                          p_acad_ci_sequence_number => l_acad_ci_sequence_number,
                          p_acad_ci_start_dt        => l_acad_start_dt,
                          p_acad_ci_end_dt          => l_acad_end_dt,
                          p_message_name            => lv_message );

    IF lv_message IS NOT NULL THEN
      p_message_name := lv_message;
      p_deny_warn := 'DENY';
            p_return_status := 'FALSE';
      RETURN ;
    END IF;

    l_enrollment_category := Igs_En_Gen_003.enrp_get_enr_cat(
                                    p_person_id                => p_person_id,
                                    p_course_cd                => p_program_cd,
                                    p_cal_type                 => l_acad_cal_type,
                                    p_ci_sequence_number       => l_acad_ci_sequence_number,
                                    p_session_enrolment_cat    => NULL,
                                    p_enrol_cal_type           => l_enrol_cal_type      ,
                                    p_enrol_ci_sequence_number => l_enrol_sequence_number,
                                    p_commencement_type        => l_commencement_type,
                                    p_enr_categories           => l_dummy );


 /*** To get course version ***/
    lv_version_number := igs_en_spa_terms_api.get_spat_program_version(
				p_person_id => p_person_id,
				p_program_cd => p_program_cd,
				p_term_cal_type => p_load_cal_type,
				p_term_sequence_number => p_load_ci_sequence_number);

    IF p_step_type NOT IN ('FMAX_CRDT','FMIN_CRDT') THEN
          p_message_name := 'IGS_TR_SYS_STEP_TY_NOT_EXIST';
          p_deny_warn := 'DENY';
          p_return_status := 'FALSE';
          RETURN ;
    END IF;

        lv_message := null;

    l_notification_flag :=   igs_ss_enr_details.get_notification(
                                   p_person_type         => lv_person_type,
                                   p_enrollment_category => l_enrollment_category,
                                   p_comm_type           => l_commencement_type,
                                   p_enr_method_type     => l_enr_method,
                                   p_step_group_type     => 'PROGRAM',
                                   p_step_type           => p_step_type ,
                                   p_person_id           => p_person_id,
                                   p_message             => lv_message
                                 );
    IF lv_message IS NOT NULL THEN
       p_return_status :=  'FALSE';
       p_message_name  := lv_message;
       RETURN;
    END IF;
        IF l_notification_flag IS NOT NULL THEN
             IF p_step_type = 'FMAX_CRDT' THEN
                   l_ret_value := igs_en_elgbl_program.eval_max_cp( p_person_id,
                                           p_load_cal_type,
                                           p_load_ci_sequence_number,
                                           p_uoo_id,
                                           p_program_cd,
                                           lv_version_number,
                                           lv_message,
                                           l_notification_flag,
                                           p_credit_points,
                                           'JOB'
                                         );
             ELSIF p_step_type = 'FMIN_CRDT' THEN
                   -- The p_credit_points parameter in the below call is made as an IN/OUT parameter
                   -- Four new parameters p_enrollment_category, p_comm_type, p_method_type, p_min_credit_point added
                   -- as part of the Enrl Elgbl and Validation Build. Bug#2616692.
                   -- Hence the variable l_credit_points passed to the call.
                   l_credit_points := p_credit_points;
                   l_ret_value := igs_en_elgbl_program.eval_min_cp( p_person_id,
                                           p_load_cal_type,
                                           p_load_ci_sequence_number,
                                           p_uoo_id,
                                           p_program_cd,
                                           lv_version_number,
                                           lv_message,
                                           l_notification_flag,
                                           l_credit_points,
                                           l_enrollment_category,
                                           l_commencement_type,
                                           l_enr_method,
                                           l_min_credit_point,
                                           'JOB'
                                         );
             END IF;
        END IF;

    IF l_ret_value THEN
          p_message_name := lv_message;
          IF p_message_name IS NOT NULL THEN
              p_deny_warn := l_notification_flag;
          ELSE
            p_deny_warn := NULL;
          END IF;
          p_return_status := 'TRUE';
          RETURN ;
    ELSE
    -- handling of DENY / WARN has been changed. Once the step is configured, the step evaluates to
    -- DENY/WARN programatically , and the initial value gets overriden.
      p_message_name := lv_message;
      IF p_message_name = 'IGS_SS_WARN_MIN_CP_REACHED' OR p_message_name = 'IGS_SS_WARN_MAX_CP_REACHED'  then
        p_deny_warn := 'WARN';
      ELSE
        p_deny_warn := 'DENY';
      END IF ;
      p_return_status := 'FALSE';
      RETURN ;
    END IF;

        -- if the step is not defined then the code will reach this point.
    p_message_name :=  NULL;
    p_deny_warn := NULL;
    p_return_status := 'TRUE';
    RETURN ;

  END ss_eval_min_or_max_cp;

END Igs_En_Enroll_Wlst; -- End of package body

/
