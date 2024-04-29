--------------------------------------------------------
--  DDL for Package Body IGS_EN_ELGBL_UNIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_ELGBL_UNIT" AS
/* $Header: IGSEN80B.pls 120.23 2006/08/24 07:31:50 bdeviset ship $ */

--  This function gets the coreq units for the passsed uoo_id
-- and add quotes so that the string containing units can be used in
-- sql statement
FUNCTION  get_coreq_units(p_uoo_id IN NUMBER)
RETURN VARCHAR2 AS

l_unit_cds VARCHAR2(500);
l_unit_cd VARCHAR2(12);
l_ret_unit_cds VARCHAR2(500);

BEGIN

l_unit_cds := igs_ss_enr_details.Get_coreq_units(p_uoo_id);

WHILE l_unit_cds IS NOT NULL LOOP

  IF (instr(l_unit_cds,',',1)) = 0 THEN
    l_unit_cd := l_unit_cds;
    l_unit_cds := NULL;
  ELSE
     -- get the unit cd for formatting
    l_unit_cd := substr(l_unit_cds,1,instr(l_unit_cds,',')-1);
      -- remove the unit cd from the string
    l_unit_cds := substr(l_unit_cds,instr(l_unit_cds,',')+1);

  END IF;

  -- add auotes to unit cd for it to be used in sql statement
  l_unit_cd := ''''||l_unit_cd||'''';

  IF l_ret_unit_cds IS NULL THEN
    l_ret_unit_cds := l_unit_cd;
  ELSE
    l_ret_unit_cds := l_ret_unit_cds||','||l_unit_cd;
  END IF;

END LOOP;

RETURN   l_ret_unit_cds;

END get_coreq_units;

FUNCTION eval_unit_steps(
p_person_id IN NUMBER,
p_person_type IN VARCHAR2,
p_load_cal_type IN VARCHAR2,
p_load_sequence_number IN VARCHAR2,
p_uoo_id  IN NUMBER,
p_course_cd IN VARCHAR2,
p_course_version IN NUMBER,
p_enrollment_category IN VARCHAR2,
p_enr_method_type IN VARCHAR2,
p_comm_type IN VARCHAR2,
p_message OUT NOCOPY VARCHAR2,
p_deny_warn OUT NOCOPY VARCHAR2,
p_calling_obj IN      VARCHAR2
) RETURN BOOLEAN AS

--------------------------------------------------------------------------------
  --Created by  : knaraset ( Oracle IDC)
  --Date created: 21-JUN-2001
  --
  --Purpose: This function will validate all the unit steps defined for the given combination of
  --         Enrollment Category, Enrollment Method and Commencement Type against the given Student
  --         Unit Attempt. If any unit step validation fails and if notification flag is DENY
  --         then stop validation of further unit steps(exception for Co-Req) and
  --             return FALSE with notification flag and message(s)
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --jbegum      25-jun-03       BUG#2930935
  --                            Modified the cursor c_unit_aud_att.
  --ayedubat    11-APR-2002    Changed the Dynamic SQL Statement storing in l_step_def_query variable to add an extra 'OR'
  --                           condition(eru.s_student_comm_type = 'ALL') for s_student_comm_type as part of the bug fix: 2315245
  -- smanglm   14/08/2001    removed the check for system_type = SS_ENROLL_STAFF so
  --                         that query can be made for all possible person type
  -- pradhakr   27-Oct-2002  Added logic to check whether the Unit Section exists in Cross Listed /
  --                         Meet With classes group. If it exists then by pass the reserve seating
  --                         validation. Added as part of En Cross List / Meet With build.
  --                         Bug# 2599929.
  --Nishikant    01NOV2002   SEVIS Build. Enh Bug#2641905. notification flag was
  --                         being fetched from REF cursor, now modified to get it by
  --                         calling the function igs_ss_enr_details.get_notification.
  --myoganat   12-JUN-2003  Modified the cursor c_audit_sua by adding a clause to check for the statuses of the unit section attempts
  --                                          As part of Bug#  2855870 (ENCR032 Build)
  --bdeviset   20-JUL-2006  While calling eval_intmsn_unit_lvl and eval_visa_unit_lvl in eval_units_steps
  --                        passed l_calling_obj instead of p_calling_obj inorder to avoid logging
  --                        warning msg when called from 'REINSTATE' and instead return a message
  --                        Bug# 5306874
  ------------------------------------------------------------------------------

  CURSOR cur_sys_pers_type(p_person_type_code VARCHAR2) IS
  SELECT system_type
  FROM igs_pe_person_types
  WHERE person_type_code = p_person_type_code;

  -- Cursor to check whether unit is attempted for audit
  CURSOR c_unit_aud_att IS
  SELECT sua.no_assessment_ind,
         sua.unit_attempt_status,
         NVL(sua.override_enrolled_cp,NVL(cps.enrolled_credit_points,uv.enrolled_credit_points)) credit_points
  FROM igs_en_su_attempt sua,
       igs_ps_unit_ver uv ,
       igs_ps_usec_cps cps
  WHERE sua.person_id   = p_person_id
  AND   sua.course_cd   = p_course_cd
  AND   sua.uoo_id      = p_uoo_id
  AND   sua.unit_cd     = uv.unit_cd
  AND   sua.version_number = uv.version_number
  AND   sua.uoo_id         = cps.uoo_id(+);


  --  Cursor to select the number of auditors for the given unit
  CURSOR   c_usec_audit_lim IS
  SELECT   NVL (usec.max_auditors_allowed, NVL(uv.max_auditors_allowed,999999) )
  FROM     igs_ps_usec_lim_wlst usec,
           igs_ps_unit_ver uv,
           igs_ps_unit_ofr_opt uoo
  WHERE    uoo.unit_cd          = uv.unit_cd
  AND      uoo.version_number   = uv.version_number
  AND      uoo.uoo_id           = usec.uoo_id (+)
  AND      uoo.uoo_id           = p_uoo_id;

  CURSOR c_audit_sua IS
  SELECT COUNT(*)
  FROM igs_en_su_attempt
  WHERE uoo_id=p_uoo_id
  AND  no_assessment_ind = 'Y' -- For Audit TD Bug 2641864
  AND (( p_calling_obj <> 'PLAN' AND unit_attempt_status IN ('ENROLLED', 'COMPLETED','INVALID','UNCONFIRM')  ) OR
             (p_calling_obj = 'PLAN' AND unit_attempt_status IN ('ENROLLED', 'COMPLETED','INVALID','UNCONFIRM','PLANNED') )
  OR (unit_attempt_status = 'WAITLISTED' AND FND_PROFILE.VALUE('IGS_EN_VAL_WLST')  ='Y'));



  TYPE step_rec IS RECORD(
    s_enrolment_step_type  igs_en_cpd_ext.s_enrolment_step_type%TYPE ,
    enrolment_cat          igs_en_cpd_ext.enrolment_cat%TYPE,
    s_student_comm_type    igs_en_cpd_ext.s_student_comm_type%TYPE,
    enr_method_type        igs_en_cpd_ext.enr_method_type%TYPE,
    step_group_type        igs_lookups_view.step_group_type%TYPE,
    s_rule_call_cd         igs_en_cpd_ext.s_rule_call_cd%TYPE,
    rul_sequence_number    igs_en_cpd_ext.rul_sequence_number%TYPE,
    stud_audit_lim         igs_en_cpd_ext.stud_audit_lim%TYPE); -- added for Audit build

  TYPE cur_step_def IS REF CURSOR;

  cur_step_def_var cur_step_def; -- REF cursor variable
  cur_step_def_var_rec step_rec;

  l_system_type         igs_pe_person_types.system_type%TYPE;
  l_message             VARCHAR2(30);
  l_usec_status         igs_ps_unit_ofr_opt.unit_section_status%TYPE;
  l_waitlist_ind        VARCHAR2(1);
  l_step_def_query      VARCHAR2(2000);
  l_repeat_tag          VARCHAR2(1);
  l_assessment_ind      VARCHAR2(1);
  l_usec_audit_lim      NUMBER;
  l_audit_sua           NUMBER;
  -- Cursor to check whether the unit section belongs to any cross-listed group or not.
  CURSOR c_cross_list(l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT 'x'
  FROM igs_ps_usec_x_grpmem
  WHERE uoo_id = l_uoo_id;

  -- Cursor to check whether the unit section belongs to any Meet with class group.
  CURSOR c_class_meet (l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT 'x'
  FROM igs_ps_uso_clas_meet
  WHERE uoo_id = l_uoo_id;

  l_cross_list c_cross_list%ROWTYPE;
  l_class_meet c_class_meet%ROWTYPE;
  l_usec_partof_group BOOLEAN;
  l_notification_flag       igs_en_cpd_ext.notification_flag%TYPE; --added by nishikant
  l_unit_attempt_status igs_en_su_attempt_all.unit_attempt_status%TYPE;
  l_credit_points  igs_ps_unit_ver.enrolled_credit_points%type;
  l_deny_unit_steps BOOLEAN;
  l_warn_unit_steps BOOLEAN;
  l_message_icon    VARCHAR2(1);
  l_unit_sec        VARCHAR2(100);
  l_calling_obj      VARCHAR2(2000);
  l_deny_enrollment         VARCHAR2(1);
BEGIN

  l_usec_partof_group := FALSE;

  OPEN cur_sys_pers_type(p_person_type);
  FETCH cur_sys_pers_type INTO l_system_type;
  CLOSE cur_sys_pers_type;

    IF p_calling_obj IN ('REINSTATE','JOB_FROM_WAITLIST') THEN
   l_calling_obj := 'JOB'; --l_calling_obj is used to pass to the validation procedures as the job
                           --validations and reinstate validation is same.
  ELSE
   l_calling_obj := p_calling_obj;
  END IF;

  -- Check whether the unit section belongs to any cross listed group /  Meet With Class group.
  -- if it is a part of these group then set the variable l_usec_partof_group to TRUE.
  --
  OPEN c_cross_list(p_uoo_id);
  FETCH c_cross_list INTO l_cross_list;

  IF c_cross_list%FOUND THEN
     l_usec_partof_group := TRUE;

  ELSE
    OPEN c_class_meet(p_uoo_id);
    FETCH c_class_meet INTO l_class_meet;

    IF c_class_meet%FOUND THEN
       l_usec_partof_group := TRUE;
    END IF;
    CLOSE c_class_meet;

  END IF;
  CLOSE c_cross_list;


  -- if the user log on is a student
  IF l_system_type = 'STUDENT' THEN

     l_step_def_query := 'SELECT eru.s_enrolment_step_type, eru.enrolment_cat, eru.s_student_comm_type, eru.enr_method_type, lkv.step_group_type,
                              eru.s_rule_call_cd,eru.rul_sequence_number,eru.stud_audit_lim
                             FROM igs_en_cpd_ext eru, igs_lookups_view lkv
                                                 WHERE eru.s_enrolment_step_type =lkv.lookup_code AND
                                                 lkv.lookup_type = ''ENROLMENT_STEP_TYPE_EXT'' AND lkv.step_group_type =
                                                 ''UNIT'' AND eru.enrolment_cat = :1 AND eru.enr_method_type = :2
                                                 AND ( eru.s_student_comm_type = :3 OR eru.s_student_comm_type = ''ALL'')
                                                 ORDER BY eru.step_order_num';

  OPEN cur_step_def_var FOR l_step_def_query USING p_enrollment_category, p_enr_method_type, p_comm_type;

  ELSE
  --IF l_system_type = 'SS_ENROLL_STAFF' THEN -- if the log on user is self service enrollment staff
  -- removed the check so as to prepare the query for person type other than STUDENT and SS_ENROLL_STAFF also

     l_step_def_query := 'SELECT eru.s_enrolment_step_type, eru.enrolment_cat, eru.s_student_comm_type, eru.enr_method_type, lkv.step_group_type,
                              eru.s_rule_call_cd,eru.rul_sequence_number,eru.stud_audit_lim
                             FROM igs_en_cpd_ext eru, igs_pe_usr_aval uact, igs_lookups_view lkv
                                                 WHERE eru.s_enrolment_step_type =lkv.lookup_code AND
                                                 lkv.lookup_type = ''ENROLMENT_STEP_TYPE_EXT'' AND lkv.step_group_type = ''UNIT'' AND
                                                 eru.s_enrolment_step_type = uact.validation(+) AND
                                                 uact.person_type(+) = :1 AND NVL(uact.override_ind,''N'') = ''N'' AND
                                                 eru.enrolment_cat = :2 AND eru.enr_method_type = :3
                                                 AND ( eru.s_student_comm_type = :4 OR eru.s_student_comm_type = ''ALL'')
                                                 ORDER BY eru.step_order_num';

  OPEN cur_step_def_var FOR l_step_def_query USING p_person_type, p_enrollment_category, p_enr_method_type, p_comm_type;

  END IF;

  -- Check whether the student attempted the unit for Audit
  OPEN c_unit_aud_att;
  FETCH c_unit_aud_att INTO l_assessment_ind , l_unit_attempt_status ,l_credit_points;
  CLOSE c_unit_aud_att;

  <<loop_unit_steps >> -- loop lable
  LOOP
     FETCH cur_step_def_var INTO cur_step_def_var_rec;

        EXIT WHEN cur_step_def_var%NOTFOUND;
             l_message := NULL;
             l_notification_flag := NULL;
             l_notification_flag  :=  igs_ss_enr_details.get_notification(
                                       p_person_type         => p_person_type,
                                       p_enrollment_category => cur_step_def_var_rec.enrolment_cat,
                                       p_comm_type           => cur_step_def_var_rec.s_student_comm_type,
                                       p_enr_method_type     => cur_step_def_var_rec.enr_method_type,
                                       p_step_group_type     => cur_step_def_var_rec.step_group_type,
                                       p_step_type           => cur_step_def_var_rec.s_enrolment_step_type,
                                       p_person_id           => p_person_id,
                                       p_message             => l_message);
             IF l_message IS NOT NULL THEN
                p_deny_warn := 'DENY';
                IF p_message IS NULL THEN
                    p_message := l_message;
                ELSE
                    p_message := p_message ||';'||l_message;
                END IF;
                RETURN FALSE;
             END IF;

--
-- validate the Enrollment Method Step
--This will not be called while reinstating the units from the schedule page.
--This method will be skipped while rinstating the unit.
         IF cur_step_def_var_rec.s_enrolment_step_type = 'ENR_MTHD' AND p_calling_obj NOT IN('ENROLPEND', 'REINSTATE','JOB_FROM_WAITLIST')  THEN

            IF NOT eval_unit_ss_allowed (
                     p_person_id                    => p_person_id,
                     p_course_cd                    => p_course_cd,
                     p_person_type                  => p_person_type,
                     p_load_cal_type                => p_load_cal_type,
                     p_load_sequence_number         => p_load_sequence_number,
                     p_uoo_id                       => p_uoo_id,
                     p_message                      => p_message,
                     p_deny_warn                    => l_notification_flag,
                     p_calling_obj                  => p_calling_obj
                    ) THEN

                  IF l_notification_flag = 'DENY' THEN

                    l_deny_unit_steps := TRUE;

                    IF p_calling_obj = 'JOB' THEN
                      p_deny_warn := l_notification_flag;
                      RETURN FALSE;
                    END IF;

                  ELSE
                    l_warn_unit_steps := TRUE;
                  END IF; -- IF l_notification_flag = 'DENY' THEN

            END IF; -- IF NOT eval_unit_ss_allowed

--  validate the Program Check
--
         ELSIF cur_step_def_var_rec.s_enrolment_step_type = 'PROG_CHK' THEN
            IF NOT eval_program_check(
                     p_person_id                    => p_person_id,
                     p_load_cal_type                => p_load_cal_type,
                     p_load_sequence_number         => p_load_sequence_number,
                     p_uoo_id                       => p_uoo_id,
                     p_course_cd                    => p_course_cd,
                     p_course_version               => p_course_version,
                     p_message                      => p_message,
                     p_deny_warn                    => l_notification_flag,
                     p_rule_seq_number              => cur_step_def_var_rec.rul_sequence_number,
                     p_calling_obj                  => l_calling_obj
                    ) THEN
                IF l_notification_flag = 'DENY' THEN

                  l_deny_unit_steps := TRUE;

                  IF p_calling_obj IN ('JOB','REINSTATE','JOB_FROM_WAITLIST') THEN
                    p_deny_warn := l_notification_flag;
                    RETURN FALSE;
                  END IF;

                ELSE
                  l_warn_unit_steps := TRUE;
                END IF; -- IF l_notification_flag = 'DENY' THEN

             END IF;
--
-- validate the unit step Forced Location
--
         ELSIF cur_step_def_var_rec.s_enrolment_step_type = 'FLOC_CHK' THEN
            IF NOT eval_unit_forced_location(
                     p_person_id                    => p_person_id,
                     p_load_cal_type                => p_load_cal_type,
                     p_load_sequence_number         => p_load_sequence_number,
                     p_uoo_id                       => p_uoo_id,
                     p_course_cd                    => p_course_cd,
                     p_course_version               => p_course_version,
                     p_message                      => p_message,
                     p_deny_warn                    => l_notification_flag,
                     p_calling_obj                  => l_calling_obj
                    ) THEN
                IF l_notification_flag = 'DENY' THEN

                  l_deny_unit_steps := TRUE;

                  IF p_calling_obj IN ('JOB','REINSTATE','JOB_FROM_WAITLIST') THEN
                    p_deny_warn := l_notification_flag;
                    RETURN FALSE;
                  END IF;

                ELSE
                  l_warn_unit_steps := TRUE;
                END IF; -- IF l_notification_flag = 'DENY' THEN

            END IF;
--
-- validate the unit step Forced Attendance Mode
--
         ELSIF cur_step_def_var_rec.s_enrolment_step_type = 'FATD_MODE' THEN
            IF NOT eval_unit_forced_mode(
                     p_person_id                    => p_person_id,
                     p_load_cal_type                => p_load_cal_type,
                     p_load_sequence_number         => p_load_sequence_number,
                     p_uoo_id                       => p_uoo_id,
                     p_course_cd                    => p_course_cd,
                     p_course_version               => p_course_version,
                     p_message                      => p_message,
                     p_deny_warn                    => l_notification_flag,
                     p_calling_obj                  => l_calling_obj
                    ) THEN
                IF l_notification_flag = 'DENY' THEN

                  l_deny_unit_steps := TRUE;

                  IF p_calling_obj IN ('JOB','REINSTATE','JOB_FROM_WAITLIST') THEN
                    p_deny_warn := l_notification_flag;
                    RETURN FALSE;
                  END IF;

                ELSE
                  l_warn_unit_steps := TRUE;
                END IF; -- IF l_notification_flag = 'DENY' THEN

            END IF;
--
-- validate the unit step Unit Repeat
----This will not be called while reinstating the units from the schedule page.

         ELSIF cur_step_def_var_rec.s_enrolment_step_type = 'REENROLL' AND p_calling_obj <> 'REINSTATE'  THEN
            IF NOT eval_unit_reenroll (
                 p_person_id                    => p_person_id,
                     p_load_cal_type                => p_load_cal_type,
                     p_load_cal_seq_number          => p_load_sequence_number,
                     p_uoo_id                       => p_uoo_id,
                     p_program_cd                   => p_course_cd,
                     p_program_version              => p_course_version,
                     p_message                      => p_message,
                     p_deny_warn                    => l_notification_flag,
                     p_upd_cp                      => l_credit_points,
                     p_val_level               =>'ALL',
                     p_calling_obj                  => l_calling_obj
                    ) THEN
                  IF l_notification_flag = 'DENY' THEN

                    l_deny_unit_steps := TRUE;

                    IF p_calling_obj IN ('JOB','JOB_FROM_WAITLIST') THEN
                      p_deny_warn := l_notification_flag;
                      RETURN FALSE;
                    END IF;

                  ELSE
                    l_warn_unit_steps := TRUE;
                  END IF; -- IF l_notification_flag = 'DENY' THEN
            END IF;

--Unit repeat validation
--This will not be called while reinstating the units from the schedule page.

         ELSIF cur_step_def_var_rec.s_enrolment_step_type = 'UNIT_RPT' AND p_calling_obj <> 'REINSTATE' THEN
            IF NOT eval_unit_repeat (
                     p_person_id                    => p_person_id,
                     p_load_cal_type                => p_load_cal_type,
                     p_load_cal_seq_number          => p_load_sequence_number,
                     p_uoo_id                       => p_uoo_id,
                     p_program_cd                   => p_course_cd,
                     p_program_version              => p_course_version,
                     p_message                      => p_message,
                     p_deny_warn                    => l_notification_flag,
                     p_repeat_tag                   => l_repeat_tag,
                     p_calling_obj                  => l_calling_obj
                    ) THEN

                  IF l_notification_flag = 'DENY' THEN

                    l_deny_unit_steps := TRUE;

                    IF p_calling_obj IN ('JOB','JOB_FROM_WAITLIST') THEN
                      p_deny_warn := l_notification_flag;
                      RETURN FALSE;
                    END IF;

                  ELSE
                    l_warn_unit_steps := TRUE;
                  END IF; -- IF l_notification_flag = 'DENY' THEN

            END IF;
--
-- validate the unit step Time Conflict
--
         ELSIF cur_step_def_var_rec.s_enrolment_step_type = 'TIME_CNFLT' THEN
            IF NOT eval_time_conflict(
                     p_person_id                    => p_person_id,
                     p_load_cal_type                => p_load_cal_type,
                     p_load_cal_seq_number          => p_load_sequence_number,
                     p_uoo_id                       => p_uoo_id,
                     p_program_cd                   => p_course_cd,
                     p_program_version              => p_course_version,
                     p_message                      => p_message,
                     p_deny_warn                    => l_notification_flag,
                     p_calling_obj                  => l_calling_obj
                    ) THEN
                  IF l_notification_flag = 'DENY' THEN

                    l_deny_unit_steps := TRUE;

                    IF p_calling_obj IN ('JOB','REINSTATE','JOB_FROM_WAITLIST') THEN
                      p_deny_warn := l_notification_flag;
                      RETURN FALSE;
                    END IF;

                  ELSE
                    l_warn_unit_steps := TRUE;
                  END IF; -- IF l_notification_flag = 'DENY' THEN

            END IF;
--
-- validate the unit step Pre-Requisite rule
--
         ELSIF cur_step_def_var_rec.s_enrolment_step_type = 'PREREQ' THEN
           -- for self service pages this step will be evaluated along with the program steps
            IF p_calling_obj IN ('JOB','REINSTATE','JOB_FROM_WAITLIST') THEN

              IF NOT eval_prereq (
                             p_person_id => p_person_id,
                             p_load_cal_type => p_load_cal_type,
                             p_load_sequence_number => p_load_sequence_number,
                             p_uoo_id  => p_uoo_id,
                             p_course_cd => p_course_cd,
                             p_course_version => p_course_version,
                             p_message => p_message,
                             p_deny_warn => l_notification_flag,
                             p_calling_obj => l_calling_obj
                      ) THEN
                 IF l_notification_flag = 'DENY' THEN
                   l_deny_unit_steps := TRUE;
                   p_deny_warn := l_notification_flag;
                   RETURN FALSE;
                 ELSE
                   l_warn_unit_steps := TRUE;
                 END IF;

              END IF; -- IF p_calling_obj = 'JOB' THEN

            END IF;

--
-- validate the unit step incompatibility rule
--
         ELSIF cur_step_def_var_rec.s_enrolment_step_type = 'INCMPT_UNT' THEN
           -- for self service pages this step will be evaluated along with the program steps
            IF p_calling_obj IN ('JOB','REINSTATE','JOB_FROM_WAITLIST') THEN

              IF NOT eval_incompatible(
                                     p_person_id => p_person_id,
                             p_load_cal_type => p_load_cal_type,
                             p_load_sequence_number => p_load_sequence_number,
                             p_uoo_id  => p_uoo_id,
                             p_course_cd => p_course_cd,
                             p_course_version => p_course_version,
                             p_message => p_message,
                             p_deny_warn => l_notification_flag,
                             p_calling_obj => l_calling_obj
                             ) THEN

                 IF l_notification_flag = 'DENY' THEN
                   l_deny_unit_steps := TRUE;
                   p_deny_warn := l_notification_flag;
                   RETURN FALSE;
                 ELSE
                   l_warn_unit_steps := TRUE;
                 END IF;

              END IF; -- IF p_calling_obj = 'JOB' THEN

            END IF;


--
-- validate the unit step special permission
--
         ELSIF cur_step_def_var_rec.s_enrolment_step_type = 'SPL_PERM' AND p_calling_obj IN ('JOB','REINSTATE','JOB_FROM_WAITLIST') THEN
         -- spl per  is evaluated in add units api
            IF NOT eval_spl_permission(
                                   p_person_id => p_person_id,
                           p_load_cal_type => p_load_cal_type,
                           p_load_sequence_number => p_load_sequence_number,
                           p_uoo_id  => p_uoo_id,
                           p_course_cd => p_course_cd,
                           p_course_version => p_course_version,
                           p_message => p_message,
                           p_deny_warn => l_notification_flag
                    ) THEN
                IF l_notification_flag = 'DENY' THEN
                  l_deny_unit_steps := TRUE;
                   p_deny_warn := l_notification_flag;
                  RETURN FALSE;
                ELSE
                 l_warn_unit_steps := TRUE;
                END IF;
            END IF;

        --
        -- validate the unit step reserve seating
        -- Call the reserve seating validation only if the unit section is not a part of any group.
        -- Modified as part of Bug# 2599929'
        --
         ELSIF l_usec_partof_group = FALSE AND cur_step_def_var_rec.s_enrolment_step_type = 'RSV_SEAT' THEN

            IF p_calling_obj <> 'PLAN' THEN
            -- for plannig waitlisting is not allowed
                --
                -- If the student is already WAITLISTED then the Unit section status need not be verified when the student is
                -- ENROLLED- beacuse the procedure validate_unit_steps itself would be called only when it is determined that there are
                -- seats avaliavle for the student to move from waitlist to enroll.
                --
              IF l_unit_attempt_status <> 'WAITLISTED' THEN
                  --
                  -- Check whether the student is going to be waitlisted or not
                  -- Added four more parameters as per bug 2417240.
                  Igs_En_Gen_015.get_usec_status( p_uoo_id              => p_uoo_id,
                                      p_person_id               => p_person_id,
                                      p_unit_section_status     => l_usec_status,
                                      p_waitlist_ind            => l_waitlist_ind,
                                      p_load_cal_type           => p_load_cal_type,
                                      p_load_ci_sequence_number => p_load_sequence_number,
                                      p_course_cd               => p_course_cd);
              END IF ;

                --
                -- if student is not going to be waitlisted OR if it is determined that the student is already WAITLISTED , but wants to
                -- ENROL now , then only call the reserve seat validation.
              IF l_unit_attempt_status = 'WAITLISTED' OR l_waitlist_ind = 'N' THEN

                IF NOT eval_rsv_seat(
                               p_person_id => p_person_id,
                               p_load_cal_type => p_load_cal_type,
                               p_load_sequence_number => p_load_sequence_number,
                               p_uoo_id  => p_uoo_id,
                               p_course_cd => p_course_cd,
                               p_course_version => p_course_version,
                               p_message => p_message,
                               p_deny_warn => l_notification_flag,
                               p_calling_obj => l_calling_obj,
                               p_deny_enrollment  => l_deny_enrollment
                               ) THEN

                           IF l_notification_flag = 'DENY' THEN

                              l_deny_unit_steps := TRUE;

                              IF p_calling_obj IN ('JOB','REINSTATE','JOB_FROM_WAITLIST') THEN
                                p_deny_warn := l_notification_flag;
                                RETURN FALSE;
                              END IF;

                            ELSE
                              l_warn_unit_steps := TRUE;
                            END IF; -- IF l_notification_flag = 'DENY' THEN

                 END IF; -- IF NOT eval_unit_ss_allowed

              END IF;  -- l_waitlist_ind

          END IF; -- IF p_calling_obj <> 'PLAN' THEN
--
-- cart maximum step is validated in add_units_api
--
--
-- validate the unit step
--

         ELSIF cur_step_def_var_rec.s_enrolment_step_type = 'INT_STSU' THEN
            IF NOT eval_intmsn_unit_lvl(
                     p_person_id                    => p_person_id,
                     p_load_cal_type                => p_load_cal_type,
                     p_load_cal_seq_number          => p_load_sequence_number,
                     p_uoo_id                       => p_uoo_id,
                     p_program_cd                   => p_course_cd,
                     p_program_version              => p_course_version,
                     p_message                      => p_message,
                     p_deny_warn                    => l_notification_flag,
                     p_rule_seq_number              => cur_step_def_var_rec.rul_sequence_number,
                     p_calling_obj                  => l_calling_obj
                    ) THEN
                  IF l_notification_flag = 'DENY' THEN

                    l_deny_unit_steps := TRUE;

                    IF p_calling_obj IN ('JOB','REINSTATE','JOB_FROM_WAITLIST') THEN
                      p_deny_warn := l_notification_flag;
                      RETURN FALSE;
                    END IF;

                  ELSE
                    l_warn_unit_steps := TRUE;
                  END IF; -- IF l_notification_flag = 'DENY' THEN
            END IF;
--
-- validate the unit step
--
         ELSIF cur_step_def_var_rec.s_enrolment_step_type = 'VISA_STSU' THEN
            IF NOT eval_visa_unit_lvl(
                     p_person_id                    => p_person_id,
                     p_load_cal_type                => p_load_cal_type,
                     p_load_cal_seq_number          => p_load_sequence_number,
                     p_uoo_id                       => p_uoo_id,
                     p_program_cd                   => p_course_cd,
                     p_program_version              => p_course_version,
                     p_message                      => p_message,
                     p_deny_warn                    => l_notification_flag,
                     p_rule_seq_number              => cur_step_def_var_rec.rul_sequence_number,
                     p_calling_obj                  => l_calling_obj
                    ) THEN
                  IF l_notification_flag = 'DENY' THEN

                    l_deny_unit_steps := TRUE;

                    IF p_calling_obj IN ('JOB','REINSTATE','JOB_FROM_WAITLIST') THEN
                      p_deny_warn := l_notification_flag;
                      RETURN FALSE;
                    END IF;

                  ELSE
                    l_warn_unit_steps := TRUE;
                  END IF; -- IF l_notification_flag = 'DENY' THEN
            END IF;

           -- new code added ----------
          ELSIF cur_step_def_var_rec.s_enrolment_step_type = 'AUDIT_PERM' AND l_assessment_ind = 'Y'  THEN
            -- audit per  is evaluated in add units api
            IF p_calling_obj IN ('JOB','REINSTATE','JOB_FROM_WAITLIST') THEN
              IF NOT eval_audit_permission (p_person_id            => p_person_id,
                                        p_load_cal_type        => p_load_cal_type,
                                        p_load_sequence_number => p_load_sequence_number,
                                        p_uoo_id               => p_uoo_id,
                                        p_course_cd            => p_course_cd,
                                        p_course_version       => p_course_version,
                                        p_message              => p_message,
                                        p_deny_warn            => l_notification_flag
                                                ) THEN
                    IF l_notification_flag = 'DENY' THEN
                        l_deny_unit_steps := TRUE;
                        p_deny_warn := l_notification_flag;
                        RETURN FALSE;
                    ELSE
                      l_warn_unit_steps := TRUE;
                    END IF; -- IF l_notification_flag = 'DENY' THEN
              END IF;
            END IF; -- p_calling_obj = 'JOB'

          ELSIF cur_step_def_var_rec.s_enrolment_step_type = 'AUDIT_LIM'  AND l_assessment_ind = 'Y' THEN
              IF NOT eval_student_audit_limit (p_person_id            => p_person_id,
                                         p_load_cal_type        => p_load_cal_type,
                                         p_load_sequence_number => p_load_sequence_number,
                                         p_uoo_id               => p_uoo_id,
                                         p_course_cd            => p_course_cd,
                                         p_course_version       => p_course_version,
                                         p_message              => p_message,
                                         p_deny_warn            => l_notification_flag,
                                         p_stud_audit_lim       => cur_step_def_var_rec.stud_audit_lim,
                                         p_calling_obj          => l_calling_obj
                                              ) THEN
                  IF l_notification_flag = 'DENY' THEN

                    l_deny_unit_steps := TRUE;

                    IF p_calling_obj IN ('JOB','REINSTATE','JOB_FROM_WAITLIST') THEN
                      p_deny_warn := l_notification_flag;
                      RETURN FALSE;
                    END IF;

                  ELSE
                    l_warn_unit_steps := TRUE;
                  END IF; -- IF l_notification_flag = 'DENY' THEN
              END IF;

         ELSIF cur_step_def_var_rec.s_enrolment_step_type = 'CHK_TIME_UNIT' THEN

            IF p_calling_obj NOT IN  ('PLAN','JOB','ENROLPEND','REINSTATE','JOB_FROM_WAITLIST') THEN
            -- When planning, donot need to validate this step. When submiting plan need to validate this step

                l_message := NULL;
               IF NOT igs_en_elgbl_person.eval_timeslot(
                                                   p_person_id => p_person_id,
                                                   p_person_type => p_person_type,
                                                   p_load_calendar_type => p_load_cal_type,
                                                   p_load_cal_sequence_number => p_load_sequence_number,
                                                   p_uoo_id  => p_uoo_id,
                                                   p_enrollment_category => p_enrollment_category,
                                                   p_comm_type  => p_comm_type,
                                                   p_enrl_method => p_enr_method_type,
                                                   p_message => l_message,
                                              p_notification_flag =>l_notification_flag
               ) THEN
                   IF l_message IS NOT NULL THEN

                        -- if calling object is from self service create a warning/deny record
                        l_unit_sec := igs_en_add_units_api.get_unit_sec(p_uoo_id);
                        l_message_icon := substr(l_notification_flag,1,1);

                        igs_en_drop_units_api.create_ss_warning (
                             p_person_id => p_person_id,
                             p_course_cd => p_course_cd,
                             p_term_cal_type=> p_load_cal_type,
                             p_term_ci_sequence_number => p_load_sequence_number,
                             p_uoo_id => p_uoo_id,
                             p_message_for => l_unit_sec,
                             p_message_icon=> l_message_icon,
                             p_message_name => l_message,
                             p_message_rule_text => NULL,
                             p_message_tokens => NULL,
                             p_message_action=> NULL,
                             p_destination =>NULL,
                             p_parameters => NULL,
                             p_step_type => 'UNIT');


                   END IF; -- IF l_message IS NOT NULL THEN

                   IF l_notification_flag = 'DENY' THEN

                      l_deny_unit_steps := TRUE;

                      IF p_calling_obj IN ('JOB','REINSTATE','JOB_FROM_WAITLIST') THEN
                        p_deny_warn := l_notification_flag;
                        RETURN FALSE;
                      END IF;

                   ELSE
                      l_warn_unit_steps := TRUE;
                   END IF; -- IF l_notification_flag = 'DENY' THEN

              END IF; -- IF NOT igs_en_elgbl_person.eval_timeslot

           END IF; -- IF p_calling_obj <> ('PLAN','JOB','ENROLPEND') THEN

        END IF;  -- cur_step_def_var_rec.s_enrolment_step_type

        -- if p_message is not null means it is a system error
        -- so we should stop processing
        IF p_calling_obj NOT IN ('JOB','REINSTATE','JOB_FROM_WAITLIST') AND p_message IS NOT NULL THEN
          p_deny_warn := 'DENY';
          RETURN FALSE;
        END IF;

       --If calling object is reinstate and any warnings occured in the validation then reintialising the
       --the message string so that only errors will be displayed in the schedule page.

        IF p_calling_obj IN ('REINSTATE') AND p_message IS NOT NULL AND l_warn_unit_steps THEN
           p_message:= NULL;
        END IF;

  END LOOP loop_unit_steps;

  l_message := NULL;
  IF NOT eval_award_prog_only(
                     p_person_id                    => p_person_id,
                     p_person_type                  => p_person_type,
                     p_load_cal_type                => p_load_cal_type,
                     p_load_sequence_number         => p_load_sequence_number,
                     p_uoo_id                       => p_uoo_id,
                     p_course_cd                    => p_course_cd,
                     p_course_version               => p_course_version,
                     p_message                      => l_message,
                     p_calling_obj                  => l_calling_obj
       ) THEN
            p_deny_warn := 'DENY';

            IF p_calling_obj NOT IN  ('JOB','SCH_UPD', 'REINSTATE','JOB_FROM_WAITLIST') THEN
                      -- if calling object is from self service create a warning/deny record
                      l_unit_sec := igs_en_add_units_api.get_unit_sec(p_uoo_id);
                      l_message_icon := substr(p_deny_warn,1,1);

                      igs_en_drop_units_api.create_ss_warning (
                           p_person_id => p_person_id,
                           p_course_cd => p_course_cd,
                           p_term_cal_type=> p_load_cal_type,
                           p_term_ci_sequence_number => p_load_sequence_number,
                           p_uoo_id => p_uoo_id,
                           p_message_for => l_unit_sec,
                           p_message_icon=> l_message_icon,
                           p_message_name => l_message,
                           p_message_rule_text => NULL,
                           p_message_tokens => NULL,
                           p_message_action=> NULL,
                           p_destination =>NULL,
                           p_parameters => NULL,
                           p_step_type => 'UNIT');


            ELSE

              IF p_message IS NULL THEN
                      p_message := l_message;
                  ELSE
                      p_message := p_message ||';'||l_message;
              END IF;

            END IF; -- IF p_calling_obj <> 'JOB'

            RETURN FALSE;

         END IF;

     l_message := NULL;
     IF l_assessment_ind = 'Y' THEN
        OPEN c_usec_audit_lim;
            FETCH c_usec_audit_lim INTO l_usec_audit_lim;
        CLOSE c_usec_audit_lim;
        OPEN c_audit_sua;
            FETCH c_audit_sua INTO l_audit_sua;
        CLOSE c_audit_sua;
         IF l_audit_sua  > l_usec_audit_lim THEN

            IF p_calling_obj IN ('JOB','REINSTATE','JOB_FROM_WAITLIST') THEN
              l_message := 'IGS_EN_AU_LIM_UNIT_CROSS';
            ELSE
              l_message := 'IGS_EN_NOOFAUD_TAB_DENY';
            END IF;
            p_deny_warn := 'DENY';

            IF p_calling_obj NOT IN  ('JOB','SCH_UPD', 'REINSTATE','JOB_FROM_WAITLIST') THEN
                      -- if calling object is from self service create a warning/deny record
                      l_unit_sec := igs_en_add_units_api.get_unit_sec(p_uoo_id);
                      l_message_icon := substr(p_deny_warn,1,1);

                      igs_en_drop_units_api.create_ss_warning (
                           p_person_id => p_person_id,
                           p_course_cd => p_course_cd,
                           p_term_cal_type=> p_load_cal_type,
                           p_term_ci_sequence_number => p_load_sequence_number,
                           p_uoo_id => p_uoo_id,
                           p_message_for => l_unit_sec,
                           p_message_icon=> l_message_icon,
                           p_message_name => l_message,
                           p_message_rule_text => NULL,
                           p_message_tokens => NULL,
                           p_message_action=> NULL,
                           p_destination =>NULL,
                           p_parameters => NULL,
                           p_step_type => 'UNIT');


            ELSE

              IF p_message IS NULL THEN
                      p_message := l_message;
                  ELSE
                      p_message := p_message ||';'||l_message;
              END IF;

            END IF; -- IF p_calling_obj <> 'JOB'

            RETURN FALSE;

         END IF; -- IF l_audit_sua  > l_usec_audit_lim THEN

     END IF; -- IF l_assessment_ind = 'Y' THEN

    -- If any of the validations had failed with a deny, i.e.
    -- depending on the return value of l_vald_person_steps, return from the main function
    IF l_deny_unit_steps THEN
       --
       -- validation of person steps returns TRUE
       --
       IF p_message IS NOT NULL THEN

          --
          -- remove ; from beginning
          --
          IF substr(p_message,1,1) = ';' THEN
             p_message := substr(p_message,2);
          END IF;
          --
          -- remove ; from end
          --
          IF substr(p_message,-1,1) = ';' THEN
             p_message := substr(p_message,1,length(p_message)-1);
          END IF;
       END IF;
       p_deny_warn:= 'DENY';
       RETURN FALSE;
    ELSIF l_warn_unit_steps THEN

       IF p_message IS NOT NULL THEN
          -- remove ; from beginning
          --
          IF substr(p_message,1,1) = ';' THEN
             p_message := substr(p_message,2);
          END IF;
          --
          -- remove ; from end
          --
          IF substr(p_message,-1,1) = ';' THEN
             p_message := substr(p_message,1,length(p_message)-1);
          END IF;
        END IF;
        p_deny_warn := 'WARN' ;
        RETURN TRUE;
    END IF;
    -- no errors/warnings
    p_deny_warn := NULL;
    RETURN TRUE;

RETURN TRUE;

END eval_unit_steps;
  --
  --
  --  This function is used to get the effective census date which will be used
  --  to check the effectiveness of the hold.
  --
  --
  FUNCTION eval_unit_ss_allowed
  (
    p_person_id                    IN     NUMBER,
    p_course_cd                    IN     VARCHAR2,
    p_person_type                  IN     VARCHAR2,
    p_load_cal_type                IN     VARCHAR2,
    p_load_sequence_number         IN     VARCHAR2,
    p_uoo_id                       IN     NUMBER,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_deny_warn                    IN     VARCHAR2,
    p_calling_obj                  IN     VARCHAR2
  ) RETURN BOOLEAN AS
    ------------------------------------------------------------------------------------
    --Created by  : knaraset ( Oracle IDC)
    --Date created: 21-JUN-2001
    --
    --Purpose: this function returns whether a student unit attempt can be enrolled or not based on the value of ss_enrol_indicator
    --         but for self service staff can perform enrollment in any case, i.e. even value of ss_enrol_indicator is 'NO'
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -------------------------------------------------------------------------------------
    --
    CURSOR cur_pers_sys_type(p_person_type_code IN VARCHAR2) IS
    SELECT system_type
    FROM igs_pe_person_types
    WHERE person_type_code = p_person_type_code;
  --
    CURSOR cur_ss_enrol_ind(p_uoo_id NUMBER) IS
    SELECT ss_enrol_ind,unit_class,unit_cd
    FROM igs_ps_unit_ofr_opt
    WHERE uoo_id = p_uoo_id;
  --
    l_step_override_limit igs_en_elgb_ovr_step.step_override_limit%TYPE;
    l_system_type igs_pe_person_types.system_type%TYPE ;
    l_ss_enrol_rec cur_ss_enrol_ind%ROWTYPE ;

    l_message VARCHAR2(30);
    l_message_icon VARCHAR2(1);
  --
  -- begin of the function eval_unit_ss_allowed
  --
  BEGIN
  --
  --  Fetch the system type corresponding to the person Type of logged on user
  --
  OPEN cur_pers_sys_type(p_person_type);
  FETCH cur_pers_sys_type INTO l_system_type;
  CLOSE cur_pers_sys_type;
  --
  -- check whether logged on user is self service staff
  --
  IF l_system_type <> 'STUDENT' THEN
    RETURN TRUE;
  END IF;
  --
  --  Check whether Enrollment Method step has been overridden
  --
  IF Igs_En_Gen_015.validation_step_is_overridden (
       'ENR_MTHD',
       p_load_cal_type,
       p_load_sequence_number ,
       p_person_id ,
       p_uoo_id ,
       l_step_override_limit
     ) THEN
      RETURN TRUE;
  END IF;
  --
  -- fetch ss_enrol_ind for the given unit section
  --
  OPEN cur_ss_enrol_ind (p_uoo_id);
  FETCH cur_ss_enrol_ind INTO l_ss_enrol_rec;
  CLOSE cur_ss_enrol_ind;
  --
  -- Check whether ss_enrol_ind is checked for the given unit section
  --
  IF l_ss_enrol_rec.ss_enrol_ind = 'Y' THEN
    RETURN TRUE;
  END IF;
  --
  IF p_deny_warn = 'WARN' THEN
        l_message := 'IGS_SS_WARN_ENR_METHOD';
  ELSE
        l_message := 'IGS_SS_DENY_ENR_METHOD';
  END IF;

  IF p_calling_obj NOT IN  ('JOB','SCH_UPD') THEN

    l_message_icon := substr(p_deny_warn,1,1);
    igs_en_drop_units_api.create_ss_warning (
             p_person_id => p_person_id,
             p_course_cd => p_course_cd,
             p_term_cal_type=> p_load_cal_type,
             p_term_ci_sequence_number => p_load_sequence_number,
             p_uoo_id => p_uoo_id,
             p_message_for => l_ss_enrol_rec.unit_cd||'/'||l_ss_enrol_rec.unit_class,
             p_message_icon=> l_message_icon,
             p_message_name => l_message,
             p_message_rule_text => NULL,
             p_message_tokens => NULL,
             p_message_action=> NULL,
             p_destination =>NULL,
             p_parameters => NULL,
             p_step_type => 'UNIT');

  ELSE
    IF p_message IS NULL THEN
       p_message := l_message;
    ELSE
       p_message := p_message ||';'||l_message;
    END IF;
  END IF;
  --
  RETURN FALSE;
  --
  END eval_unit_ss_allowed;
  --
  --
  --
  FUNCTION  eval_program_check (
  p_person_id IN NUMBER,
  p_load_cal_type IN VARCHAR2,
  p_load_sequence_number IN VARCHAR2,
  p_uoo_id  IN NUMBER,
  p_course_cd IN VARCHAR2,
  p_course_version IN NUMBER,
  p_message IN OUT NOCOPY VARCHAR2,
  p_deny_warn  IN VARCHAR2,
  p_rule_seq_number IN NUMBER,
  p_calling_obj IN  VARCHAR2
  ) RETURN BOOLEAN AS

  ------------------------------------------------------------------------------------
    --Created by  : knaraset ( Oracle IDC)
    --Date created: 21-JUN-2001
    --
    --Purpose:  this function checks whether the student is eligible for enrolling in the given unit
    --          based on the program type of the student.
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -------------------------------------------------------------------------------------
    CURSOR cur_uoo_dtl(p_uoo_id NUMBER) IS
    SELECT unit_cd,version_number, unit_class
    FROM igs_ps_unit_ofr_opt
    WHERE uoo_id = p_uoo_id;
  --
    l_step_override_limit igs_en_elgb_ovr_step.step_override_limit%TYPE;
    l_uoo_dtl_rec cur_uoo_dtl%ROWTYPE;
    l_message VARCHAR2(30);
    l_message_icon VARCHAR2(1);
    l_rule_text VARCHAR2(1000);
  --
  -- begin of the function eval_program_check
  --
  BEGIN
  --
  --  No Program Type Check rule defined.
  --
  IF p_rule_seq_number IS NULL THEN
    RETURN TRUE;
  END IF;
  --
  --  Check whether Program Type Check rule has been overriden for the given student.
  --
  IF Igs_En_Gen_015.validation_step_is_overridden (
       'PROG_CHK',
       p_load_cal_type,
       p_load_sequence_number ,
       p_person_id ,
       p_uoo_id ,
       l_step_override_limit
     ) THEN
    RETURN TRUE;
  END IF;
  --
  --  get the unit section details
  --
  OPEN cur_uoo_dtl(p_uoo_id);
  FETCH cur_uoo_dtl INTO l_uoo_dtl_rec;
  CLOSE cur_uoo_dtl;
  --
  --  check whether student has satisfied the Program Type Check rule by invoking the rule engine.
  --
    IF igs_ru_gen_001.rulp_val_senna (
         p_rule_call_name => 'PROG_CHK',
         p_rule_number => p_rule_seq_number,
         p_person_id => p_person_id,
         p_param_1 => p_course_cd,
         p_param_2 => p_course_version,
         p_param_3 => l_uoo_dtl_rec.unit_cd,
         p_param_4 => l_uoo_dtl_rec.version_number,
         p_message => l_message
       ) = 'true' THEN
       RETURN TRUE;
    END IF;

   IF p_deny_warn = 'WARN' THEN
        IF p_calling_obj = 'JOB' THEN
          l_message := 'IGS_SS_WARN_PRG_CHK';
        ELSE
          l_message := 'IGS_EN_PRGCHK_TAB_WARN';
        END IF;
     ELSE
        IF p_calling_obj = 'JOB' THEN
          l_message := 'IGS_SS_DENY_PRG_CHK';
        ELSE
          l_message := 'IGS_EN_PRGCHK_TAB_DENY';
        END IF;
   END IF;

  l_rule_text := NULL;
  IF p_calling_obj NOT IN  ('JOB','SCH_UPD') THEN

    IF  (NVL(fnd_profile.value('IGS_EN_CART_RULE_DISPLAY'),'N')='Y') THEN
      l_rule_text := igs_ru_gen_003.Rulp_Get_Rule(p_rule_seq_number);
    END IF;
    l_message_icon := substr(p_deny_warn,1,1);
    igs_en_drop_units_api.create_ss_warning (
           p_person_id => p_person_id,
           p_course_cd => p_course_cd,
           p_term_cal_type=> p_load_cal_type,
           p_term_ci_sequence_number => p_load_sequence_number,
           p_uoo_id => p_uoo_id,
           p_message_for => l_uoo_dtl_rec.unit_cd||'/'||l_uoo_dtl_rec.unit_class,
           p_message_icon=> l_message_icon,
           p_message_name => l_message,
           p_message_rule_text => l_rule_text,
           p_message_tokens => NULL,
           p_message_action=> NULL,
           p_destination =>NULL,
           p_parameters => NULL,
           p_step_type => 'UNIT');



  ELSE

      IF p_message IS NULL THEN
        p_message := l_message;
      ELSE
        p_message := p_message || ';' || l_message;
      END IF;

  END IF;
  RETURN FALSE;

  END eval_program_check;
  --
  --
  --
 FUNCTION eval_unit_forced_location(
  p_person_id IN NUMBER,
  p_load_cal_type IN VARCHAR2,
  p_load_sequence_number IN VARCHAR2,
  p_uoo_id  IN NUMBER,
  p_course_cd IN VARCHAR2,
  p_course_version IN NUMBER,
  p_message IN OUT NOCOPY VARCHAR2,
  p_deny_warn  IN VARCHAR2,
  p_calling_obj  IN VARCHAR2
  ) RETURN BOOLEAN AS
    ------------------------------------------------------------------------------------
    --Created by  : knaraset ( Oracle IDC)
    --Date created: 21-JUN-2001
    --
    --Purpose:  this function returns TRUE for a given student and unit attempt
    --          when the Unit attempt's location code AND the Primary program location code are same
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -- pradhakr   23-Dec-2002     Added a call to the function IGS_EN_VAL_SUA.enrp_val_coo_loc.
    --                            This function call validates unit location code against
    --                            course_offering_option location code for the enrolled course.
    --                            Bug# 2689233.
    -- stutta     19-NOV-2003     Replaced a cursor to return coo_id from program attempt table
    --                            with a terms api function call. Term Records Build. Bug 2829263
    -------------------------------------------------------------------------------------
    --
    CURSOR cur_chk_floc(p_coo_id NUMBER, p_uoo_id NUMBER) IS
    SELECT uoo.location_cd
    FROM  igs_ps_ofr_opt coo,
          igs_ps_unit_ofr_opt uoo
    WHERE coo.coo_id = p_coo_id AND
          uoo.uoo_id = p_uoo_id AND
          uoo.location_cd = coo.location_cd;


    CURSOR cur_get_floc(p_coo_id NUMBER) IS
    SELECT location_cd
    FROM igs_ps_ofr_opt
    WHERE coo_id = p_coo_id;


      -- Cursor to get the unit location code
    CURSOR c_location IS
      SELECT location_cd, unit_cd, unit_class
      FROM igs_ps_unit_ofr_opt
      WHERE uoo_id = p_uoo_id;
    l_location_rec c_location%ROWTYPE;

    l_coo_id                    IGS_EN_STDNT_PS_ATT.coo_id%TYPE;
    v_message_name              fnd_new_messages.message_name%TYPE;
    l_step_override_limit       igs_en_elgb_ovr_step.step_override_limit%TYPE;
    l_chk_floc                  igs_ps_unit_ofr_opt.location_cd%TYPE ;
    l_message                   VARCHAR2(30);
    l_message_icon              VARCHAR2(1);
    l_message_token             VARCHAR2(100);

  --
  -- begin of the function eval_unit_forced_location
  --
  BEGIN
  --
  -- check whether the Forced location step is overridden
  --
  IF Igs_En_Gen_015.validation_step_is_overridden (
       'FLOC_CHK',
       p_load_cal_type,
       p_load_sequence_number ,
       p_person_id ,
       p_uoo_id ,
       l_step_override_limit
     ) THEN
      RETURN TRUE;
  END IF;
  --
  -- Check whether the Location code of Unit section and of Primary program attempt are same.
  --
  l_coo_id := igs_en_spa_terms_api.get_spat_coo_id(   p_person_id => p_person_id,
                                p_program_cd => p_course_cd,
                                p_term_cal_type => p_load_cal_type,
                                p_term_sequence_number => p_load_sequence_number );
  OPEN cur_chk_floc(l_coo_id,p_uoo_id);
  FETCH cur_chk_floc INTO l_chk_floc;
  IF cur_chk_floc%FOUND THEN
    CLOSE cur_chk_floc;
    RETURN TRUE;
  END IF;
  CLOSE cur_chk_floc;
  -- Cursor to get the unit location code
  OPEN c_location;
  FETCH c_location INTO l_location_rec;
  CLOSE c_location;

  -- The following call validates unit location code against
  -- course_offering_option location code for the enrolled course
  IF IGS_EN_VAL_SUA.enrp_val_coo_loc(
                    l_coo_id,
                    l_location_rec.location_cd,
                    v_message_name) THEN
        RETURN TRUE;
  END IF;
  --
  OPEN cur_get_floc(l_coo_id);
  FETCH cur_get_floc INTO l_chk_floc;
  CLOSE cur_get_floc;

  IF p_deny_warn = 'WARN' THEN
        IF p_calling_obj = 'JOB' THEN
          l_message := 'IGS_SS_WARN_LOC_CHK';
        ELSE
          l_message := 'IGS_EN_FLOC_TAB_WARN';
        END IF;
  ELSE
        IF p_calling_obj = 'JOB' THEN
          l_message := 'IGS_SS_DENY_LOC_CHK';
        ELSE
          l_message := 'IGS_EN_FLOC_TAB_DENY';
        END IF;

  END IF;
  IF p_calling_obj NOT IN  ('JOB','SCH_UPD') THEN

      l_message_token := 'UNIT_CD'||':'||l_chk_floc||';';
      l_message_icon := substr(p_deny_warn,1,1);
      igs_en_drop_units_api.create_ss_warning (
             p_person_id => p_person_id,
             p_course_cd => p_course_cd,
             p_term_cal_type=> p_load_cal_type,
             p_term_ci_sequence_number => p_load_sequence_number,
             p_uoo_id => p_uoo_id,
             p_message_for => l_location_rec.unit_cd||'/'||l_location_rec.unit_class,
             p_message_icon=> l_message_icon,
             p_message_name => l_message,
             p_message_rule_text => NULL,
             p_message_tokens => l_message_token,
             p_message_action=> NULL,
             p_destination =>NULL,
             p_parameters => NULL,
             p_step_type => 'UNIT');
  ELSE

    IF p_message IS NULL THEN
         p_message := l_message;
    ELSE
         p_message := p_message ||';'||l_message;
    END IF;

  END IF; -- IF p_calling_obj <> 'JOB'
  --
  RETURN FALSE;
  --
  END eval_unit_forced_location;
  -- =================================================================================
  FUNCTION eval_unit_forced_mode (
  p_person_id IN NUMBER,
  p_load_cal_type IN VARCHAR2,
  p_load_sequence_number IN VARCHAR2,
  p_uoo_id  IN NUMBER,
  p_course_cd IN VARCHAR2,
  p_course_version IN NUMBER,
  p_message IN OUT NOCOPY VARCHAR2,
  p_deny_warn  IN VARCHAR2,
  p_calling_obj  IN VARCHAR2
  ) RETURN BOOLEAN AS
  ------------------------------------------------------------------------------------
    --Created by  : knaraset ( Oracle IDC)
    --Date created: 21-JUN-2001
    --
    --Purpose:  this function returns TRUE for a given student and unit attempt
    --          if the unit attempt is in line with students forced
    --         mode (if applicable).
    --          This module validates the nominated unit class against
    --          course_offering_option attandance mode for the Primary Program
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    --stutta      19-NOV-2003     Replaced a cursor to return coo_id from program attempt table
    --                            with a terms api function call. Term Records Build. Bug 2829263
    -------------------------------------------------------------------------------------
    CURSOR cur_unit_class(p_uoo_id NUMBER) IS
    SELECT unit_class,unit_cd
    FROM igs_ps_unit_ofr_opt
    WHERE uoo_id = p_uoo_id;

    CURSOR cur_get_fatt(p_coo_id NUMBER) IS
    SELECT attendance_mode
    FROM igs_ps_ofr_opt
    WHERE coo_id = p_coo_id;


  --
    l_step_override_limit igs_en_elgb_ovr_step.step_override_limit%TYPE;
    l_unit_class_rec cur_unit_class%ROWTYPE ;
    l_coo_id igs_en_stdnt_ps_att.coo_id%TYPE;
    l_forced_att_mode igs_ps_ofr_opt.attendance_mode%TYPE;
    l_message VARCHAR2(30);
    l_message_icon VARCHAR2(1);
    l_message_token   VARCHAR2(100);
  --
  -- begin of the function eval_unit_forced_location
  --
  BEGIN
  --
  -- check whether forced attendance mode step has been overridden.
  --
  IF Igs_En_Gen_015.validation_step_is_overridden (
       'FATD_MODE',
       p_load_cal_type,
       p_load_sequence_number ,
       p_person_id ,
       p_uoo_id ,
       l_step_override_limit
     ) THEN
      RETURN TRUE;
  END IF;
  --
  -- Get the unit class of Unit section
  --
  OPEN cur_unit_class(p_uoo_id);
  FETCH cur_unit_class INTO l_unit_class_rec;
  CLOSE cur_unit_class;
  --
  -- get the coo_id of the primary program
  --
  l_coo_id := igs_en_spa_terms_api.get_spat_coo_id(   p_person_id => p_person_id,
                                p_program_cd => p_course_cd,
                                p_term_cal_type => p_load_cal_type,
                                p_term_sequence_number => p_load_sequence_number );
  --
  --   determine if the unit attempt is in line with students forced
  --   mode (if applicable).
  --
  IF igs_en_val_sua.enrp_val_coo_mode (
       p_coo_id => l_coo_id,
       p_unit_class => l_unit_class_rec.unit_class,
       p_message_name => l_message
     ) THEN
         RETURN TRUE;
  END IF;
  --
  OPEN cur_get_fatt(l_coo_id);
  FETCH cur_get_fatt INTO l_forced_att_mode;
  CLOSE cur_get_fatt;

  IF p_deny_warn = 'WARN' THEN
    IF p_calling_obj  = 'JOB' THEN
        l_message := 'IGS_SS_WARN_ATMODE_CHK';
    ELSE
        l_message := 'IGS_EN_ATMOD_TAB_WARN';
    END IF;
  ELSE
    IF p_calling_obj  = 'JOB' THEN
        l_message := 'IGS_SS_DENY_ATMODE_CHK';
    ELSE
        l_message := 'IGS_EN_ATMOD_TAB_DENY';
    END IF;
  END IF;

  IF p_calling_obj NOT IN  ('JOB','SCH_UPD') THEN

      l_message_token := 'UNIT_CD'||':'||l_forced_att_mode||';';
      l_message_icon := substr(p_deny_warn,1,1);
      igs_en_drop_units_api.create_ss_warning (
             p_person_id => p_person_id,
             p_course_cd => p_course_cd,
             p_term_cal_type=> p_load_cal_type,
             p_term_ci_sequence_number => p_load_sequence_number,
             p_uoo_id => p_uoo_id,
             p_message_for => l_unit_class_rec.unit_cd||'/'||l_unit_class_rec.unit_class,
             p_message_icon=> l_message_icon,
             p_message_name => l_message,
             p_message_rule_text => NULL,
             p_message_tokens => l_message_token,
             p_message_action=> NULL,
             p_destination =>NULL,
             p_parameters => NULL,
             p_step_type => 'UNIT');
  ELSE
    IF p_message IS NULL THEN
       p_message := l_message;
    ELSE
       p_message := p_message ||';'||l_message;
    END IF;
  END IF;
  --
  RETURN FALSE;
  --
END eval_unit_forced_mode;

FUNCTION eval_unit_repeat (
    p_person_id                    IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_cal_seq_number          IN     NUMBER,
    p_uoo_id                       IN     NUMBER,
    p_program_cd                   IN     VARCHAR2,
    p_program_version              IN     NUMBER,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_deny_warn                    IN     VARCHAR2,
    p_repeat_tag                   OUT NOCOPY    VARCHAR2 ,
    p_unit_cd                      IN     VARCHAR2  ,
    p_unit_version                 IN     NUMBER,
    p_calling_obj                  IN VARCHAR2
  ) RETURN BOOLEAN AS
  --------------------------------------------------------------------------------
  --Created by  : pradhakr ( Oracle IDC)
  --Date created: 21-JUN-2001
  --
  --Purpose:This function is used to evaluate if a student is eligible for Unit Repeat.
  --  Parameters Description:
  --
  --  p_person_id                  -> Person ID of the student who wants to enroll or administrator is enrolling.
  --  p_load_cal_type              -> Load (Term) or Teaching Calendar Type.
  --  p_load_cal_seq_number        -> Load Calendar or Teaching Calendar instance sequence number.
  --  p_uoo_id                     -> Unit Section Identifier.
  --  p_program_cd                 -> The Primary Program Code or the Program code selected by the student.
  --  p_program_version            -> The Primary Program version number or the Program version number selected by the student.
  --  p_message                    -> Message from the validation.
  --  p_deny_warn                  -> Deny or Warn Indicator based on the setup.
  --  p_repeat_tag                 -> Indicates whether Unit Section is considered as Repeat or Not.
  -- if p_uoo_id is null then these two parameters are not null and vice versa
  --  p_unit_cd                    -> Indicates the unit being enrolled/advanced standing being granted for
  --  p_unit_version             -> Indicates the version of the unit being attempted for
  --  smaddali removed all the institution logic. When this function is called from advanced standing details(IGSAV003)
  --  form then since there is no uoo_id we pass the new parameters of unit version . So the code has been modified to
  --  consider the new unit version being passed when uoo_id is null.
  --  Modified Cursor to select all the Unit attempts.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --smaddali                    added two new parameters p_unit_cd,p_version_number for ccr PSCR014 (bug1960126)
  --kkillams    26-12-2002      Added NVL to the l_user_hook_successful column in the if clause, after
  --                            igs_en_rpt_prc_uhk.repeat_allowed function call w.r.t. bug no# 2692012.
  -- rvivekan 18-Jun-2003   modified as per Reenrollment and repeat processing enh#2881363
  -- rvivekan    9-Sep-2003     PSP integration build 3052433. modified type of
  --                            local variable l_repeat_allowed
  -- stutta     05-Aug-2004     Added call to user hook depending on profile value IGS_EN_REP_REN.
  --                            As per repeat reenrollment user hook Build # 3807707

  ------------------------------------------------------------------------------


    CURSOR cur_unit_details IS
      SELECT   unit_cd,
               unit_class,
               version_number,
               cal_type,
               ci_sequence_number
      FROM     igs_ps_unit_ofr_opt
      WHERE    uoo_id = p_uoo_id;
    --
    --  Cursor to check if the Organization Unit has "Include Advanced Standing Units" set to Yes.
    --  and also get the max repeats allowed
    --
    CURSOR cur_org_incl_adv_stand (
             cp_org_unit_cd           IN VARCHAR2
           ) IS
      SELECT   include_adv_standing_units,max_repeats_for_credit,max_repeats_for_funding,rp.org_unit_id
      FROM     igs_en_rep_process  rp , igs_or_unit ou
      WHERE    ou.org_unit_cd = cp_org_unit_cd
      AND      ou.party_id = rp.org_unit_id
      AND      rp.org_unit_id IS NOT NULL
      UNION
      SELECT  include_adv_standing_units,max_repeats_for_credit,max_repeats_for_funding,org_unit_id
      FROM igs_en_rep_process
      WHERE org_unit_id IS NULL
      ORDER BY org_unit_id;
    --
    --  Cursor to select all the Unit Attempts of the Student.
      CURSOR cur_student_attempts (
             cp_include_in_adv_stand  IN VARCHAR2 ,
             cp_unit_cd   igs_ps_unit_ver.unit_cd%TYPE,
             cp_version_number igs_ps_unit_ver.version_number%TYPE
           ) IS
      SELECT  sua.unit_cd,
              sua.version_number,
              sua.cal_type,
              sua.ci_sequence_number,
              sua.uoo_id,
              sua.override_enrolled_cp  ,
              sua.course_cd
      FROM     igs_en_su_attempt sua, igs_ps_unit_ver psv
      WHERE    sua.person_id = p_person_id
      AND     ( sua.cart IS NOT NULL AND ( p_calling_obj <> 'SWAP'  OR  (p_calling_obj = 'SWAP' AND sua.uoo_id <> p_uoo_id) ) )
      AND     ((p_calling_obj <> 'PLAN' AND sua.unit_attempt_status IN ('ENROLLED', 'DISCONTIN','COMPLETED','INVALID','UNCONFIRM')  )
              OR (p_calling_obj = 'PLAN' AND sua.unit_attempt_status IN ('ENROLLED', 'DISCONTIN','COMPLETED','INVALID','UNCONFIRM','PLANNED') )
              OR (sua.unit_attempt_status = 'WAITLISTED' AND FND_PROFILE.VALUE('IGS_EN_VAL_WLST')  ='Y'))
      AND      sua.unit_cd = psv.unit_cd
      AND      sua.version_number = psv.version_number
      AND      ( ( sua.unit_cd = cp_unit_cd AND sua.version_number =  cp_version_number)
                OR  psv.rpt_fmly_id = ( SELECT   psu.rpt_fmly_id
                                      FROM igs_ps_unit_ver psu,
                                           igs_ps_rpt_fmly rep
                                      WHERE psu.unit_cd                 = cp_unit_cd
                                      AND   psu.version_number          = cp_version_number
                                      AND   psu.rpt_fmly_id             = rep.rpt_fmly_id
                                      AND   NVL(rep.closed_ind,'N')     = 'N' )
                )
      UNION
      SELECT  adv.unit_cd,
              adv.version_number,
              NULL cal_type,
              TO_NUMBER(NULL) ci_sequence_number,
              TO_NUMBER(NULL) uoo_id,
              adv.achievable_credit_points  override_enrolled_cp  ,
              adv.as_course_cd  course_cd
      FROM     igs_av_stnd_unit adv, igs_ps_unit_ver psv
      WHERE   adv.person_id = p_person_id
      AND     adv.s_adv_stnd_granting_status = 'GRANTED'
      AND    (adv.s_adv_stnd_recognition_type = 'CREDIT'
              AND igs_av_val_asu.granted_adv_standing(adv.person_id,adv.as_course_cd,adv.as_version_number,adv.unit_cd,adv.version_number,'GRANTED',NULL) ='TRUE' )
      AND      cp_include_in_adv_stand = 'Y'
      AND    adv.unit_cd = psv.unit_cd
       AND   adv.version_number = psv.version_number
       AND  (  ( adv.unit_cd = cp_unit_cd AND adv.version_number = cp_version_number )
             OR  psv.rpt_fmly_id = (SELECT   psu.rpt_fmly_id
                                     FROM igs_ps_unit_ver psu,
                                          igs_ps_rpt_fmly rep
                                     WHERE psu.unit_cd                 = cp_unit_cd
                                     AND   psu.version_number          = cp_version_number
                                     AND   psu.rpt_fmly_id             = rep.rpt_fmly_id
                                     AND   NVL(rep.closed_ind,'N')     = 'N')
             );
    --
    -- Cursor to find if the unit version is repeatable and Maximum Repeats for credit
    --
    CURSOR  cur_unit_repeat_for_cp(cp_unit_cd   igs_ps_unit_ver.unit_cd%TYPE,
             cp_version_number igs_ps_unit_ver.version_number%TYPE)  IS
      SELECT  repeatable_ind,max_repeats_for_credit, max_repeats_for_funding
      FROM  igs_ps_unit_ver
      WHERE  unit_cd = cp_unit_cd
      AND  version_number = cp_version_number;

    --  Cursor to find the Organization Unit Code.
    --  Organization Unit Code defined at Unit level is taken if it is not defined at Unit Section level.
    --
    CURSOR cur_organization_unit IS
      SELECT   NVL (usec.owner_org_unit_cd, uv.owner_org_unit_cd) owner_org_unit_cd
      FROM     igs_ps_unit_ofr_opt usec,
               igs_ps_unit_ver uv
      WHERE    usec.uoo_id = p_uoo_id
      AND      usec.unit_cd = uv.unit_cd
      AND      usec.version_number = uv.version_number
      AND p_uoo_id  IS NOT NULL
      UNION
      SELECT uv.owner_org_unit_cd
      FROM igs_ps_unit_ver uv
      WHERE uv.unit_cd = p_unit_cd
      AND   uv.version_number = p_unit_version
      AND  p_uoo_id IS NULL;

    rec_cur_unit_details cur_unit_details%ROWTYPE;
    l_step_override_limit igs_en_elgb_ovr_step.step_override_limit%TYPE;
    l_number_of_repeats NUMBER := 0 ;
    l_include_in_advanced_standing igs_en_rep_process.include_adv_standing_units%TYPE := 'N';
    l_repeat_allowed igs_ps_unit_ver.repeatable_ind%TYPE ;
    l_max_repeats NUMBER;
    l_unit_max_repeats NUMBER;
    l_org_max_repeats NUMBER;
    l_owner_org_unit_cd igs_ps_unit_ver.owner_org_unit_cd%TYPE;
    l_user_hook_successful BOOLEAN;
    l_message         VARCHAR2(100);
    l_org_unit_id    NUMBER;
    l_unit_max_repeats_funding NUMBER;
    l_org_max_repeats_funding NUMBER;
    l_max_repeat_funding NUMBER;
    l_message_icon VARCHAR2(1);
    l_message_token VARCHAR2(100);
  BEGIN

    -- check if all the parameters uoo_id,unit_cd , unit_version are null show a message
     IF p_uoo_id IS NULL AND ( p_unit_cd IS NULL OR p_unit_version IS NULL) THEN
        IF (p_message IS NULL) THEN
           p_message := 'IGS_EN_NO_REPEAT_PAR';
         ELSE
           p_message := p_message || ';' || 'IGS_EN_NO_REPEAT_PAR';
         END IF;
        RETURN FALSE;
     END IF;
    --
    --  Check whether Unit Level Repeat step has been overridden.
    -- this check is performed only when uoo_id is passed
    IF p_uoo_id IS NOT NULL THEN
      IF Igs_En_Gen_015.validation_step_is_overridden (
         'UNIT_RPT',
         p_load_cal_type,
         p_load_cal_seq_number,
         p_person_id,
         p_uoo_id,
         l_step_override_limit
       ) THEN
         RETURN TRUE;
      END IF;
      --
      --  Get the Unit Details for the passed Unit Section.
      --
      OPEN cur_unit_details;
      FETCH cur_unit_details INTO rec_cur_unit_details;
      CLOSE cur_unit_details;
    ELSE --if uoo_id is null use the parameters for unit_cd,version passed to this function
      rec_cur_unit_details.unit_cd := p_unit_cd;
      rec_cur_unit_details.version_number := p_unit_version;
      rec_cur_unit_details.cal_type := NULL;
      rec_cur_unit_details.ci_sequence_number  :=  NULL;
    END IF;

        --
    --  Check if the Unit Section is Repeatable.
    --  at unit level
     OPEN cur_unit_repeat_for_cp(rec_cur_unit_details.unit_cd,
         rec_cur_unit_details.version_number) ;
     FETCH cur_unit_repeat_for_cp INTO l_repeat_allowed,l_unit_max_repeats,l_unit_max_repeats_funding ;
     IF cur_unit_repeat_for_cp%NOTFOUND OR l_repeat_allowed IS NULL THEN
       l_repeat_allowed := 'N';
     END IF;
     CLOSE cur_unit_repeat_for_cp ;

    --If repeatable indicator is 'Y' means unit is setup for reenrollment
    IF (l_repeat_allowed = 'Y' OR l_repeat_allowed = 'X') THEN
       -- Repeat is not allowed, unit is set for Reenrollment.
       RETURN  TRUE;
    END IF;

    --
    --  Check if the "Include Advanced Standing Units" value is 'Y'es for the
    --  Organizaion Unit of the Unit Code (of the passed Unit Section).
    --
    OPEN cur_organization_unit;
    FETCH cur_organization_unit INTO l_owner_org_unit_cd;
    CLOSE cur_organization_unit;
    --
    OPEN cur_org_incl_adv_stand (l_owner_org_unit_cd);
    FETCH cur_org_incl_adv_stand INTO l_include_in_advanced_standing,l_org_max_repeats,l_org_max_repeats_funding,l_org_unit_id;
    IF (cur_org_incl_adv_stand%NOTFOUND) THEN
      l_include_in_advanced_standing := 'N';
    END IF;
    CLOSE cur_org_incl_adv_stand;

    -- if the limit defined at unit level consider the same otherwise take the limit defined at org unit level
    l_max_repeats := NVL(l_unit_max_repeats,l_org_max_repeats);
    l_max_repeat_funding := NVL(l_unit_max_repeats_funding,l_org_max_repeats_funding);


    --  Calculate the Repeat Credit Points and Number of Repeats.
    --  Check if the Unit can be repeated in the same Teaching Period in the "Unit Section" level.
    --  If so calculate the total repats and repeat credit points within the same teach period also
    --
   FOR rec_cur_student_attempts IN cur_student_attempts (
             l_include_in_advanced_standing,
             rec_cur_unit_details.unit_cd,
             rec_cur_unit_details.version_number
           )
   LOOP
       l_number_of_repeats := l_number_of_repeats + 1;
    END LOOP;


    IF  (l_repeat_allowed = 'N') THEN

         IF NVL(FND_PROFILE.VALUE('IGS_EN_REP_REN'),'NONE') = 'BOTH'
         OR NVL(FND_PROFILE.VALUE('IGS_EN_REP_REN'),'NONE') = 'REPEAT_EXTERNAL' THEN
                --
                --  Call User Hook.
                --
                l_user_hook_successful := NULL;
                l_user_hook_successful := IGS_EN_RPT_PRC_UHK.repeat_reenroll_allowed(
                                            p_person_id => p_person_id,
                                            p_program_cd => p_program_cd,
                                            p_unit_cd => rec_cur_unit_details.unit_cd,
                                            P_uoo_id => p_uoo_id,
                                            p_repeat_reenroll => 'REPEAT', -- repeat
                                            p_load_cal_type => p_load_cal_type,
                                            p_load_ci_seq_number => p_load_cal_seq_number,
                                            p_repeat_max => l_max_repeats,
                                            p_repeat_funding => l_max_repeat_funding,
                                            p_mus_ind => NULL,
                                            p_reenroll_max => NULL,
                                            p_reenroll_max_cp => NULL,
                                            p_same_tch_reenroll_max => NULL,
                                            p_same_tch_reenroll_max_cp => NULL,
                                            p_message => l_message);
                IF NVL(l_user_hook_successful,FALSE) THEN
                    p_repeat_tag := 'Y';
                     RETURN TRUE;
                ELSE

                    IF l_message IS NULL THEN
                      l_message_token := 'UNIT_CD:'||l_max_repeats||';';
                    END IF;
                    p_repeat_tag := 'Y';

                    IF p_deny_warn = 'DENY' THEN

                      IF p_calling_obj = 'JOB' THEN
                        l_message := NVL(l_message,'IGS_SS_DENY_REPEAT_CHK');
                      ELSE
                        l_message := NVL(l_message,'IGS_EN_REPEAT_TAB_DENY');
                      END IF;
                    ELSE
                      IF p_calling_obj = 'JOB' THEN
                        l_message :=  NVL(l_message,'IGS_SS_WARN_REPEAT_CHK');
                      ELSE
                        l_message := NVL(l_message,'IGS_EN_REPEAT_TAB_WARN');
                      END IF;
                    END IF;

                    IF p_calling_obj NOT IN  ('JOB','SCH_UPD') THEN

                      l_message_icon := substr(p_deny_warn,1,1);
                        igs_en_drop_units_api.create_ss_warning (
                               p_person_id => p_person_id,
                               p_course_cd => p_program_cd,
                               p_term_cal_type=> p_load_cal_type,
                               p_term_ci_sequence_number => p_load_cal_seq_number,
                               p_uoo_id => p_uoo_id,
                               p_message_for => rec_cur_unit_details.unit_cd||'/'||rec_cur_unit_details.unit_class,
                               p_message_icon=> l_message_icon,
                               p_message_name => l_message,
                               p_message_rule_text => NULL,
                               p_message_tokens => l_message_token,
                               p_message_action=> NULL,
                               p_destination =>NULL,
                               p_parameters => NULL,
                               p_step_type => 'UNIT');

                    ELSE
                        IF (p_message IS NULL) THEN
                          p_message := l_message;
                        ELSE
                          p_message := p_message || ';' || l_message;
                        END IF;
                    END IF; --IF p_calling_obj <> 'JOB'

                  RETURN FALSE;
                END IF; -- user hook successful

         END IF; -- FND_PROFILE.VALUE

    END IF; -- l_repeat_allowed

     --  If there is no student unit attempt then the Unit is not considered as repeat.
    --  So return TRUE.
    IF l_number_of_repeats = 0 THEN
         p_repeat_tag := 'N';
         RETURN TRUE;
    END IF;

    IF l_max_repeats IS NULL THEN
       -- no limits defined means unlimited repeats allowed
       RETURN TRUE;
    END IF;

      IF (l_number_of_repeats <= l_max_repeats)  THEN
            p_repeat_tag := 'Y' ;
            RETURN  TRUE;
      END IF;

       IF p_deny_warn = 'DENY' THEN
           IF p_calling_obj = 'JOB' THEN
            l_message := NVL(l_message,'IGS_SS_DENY_REPEAT_CHK');
          ELSE
            l_message := NVL(l_message,'IGS_EN_REPEAT_TAB_DENY');
            l_message_token := 'UNIT_CD:'||l_max_repeats||';';
          END IF;
        ELSE
          IF p_calling_obj = 'JOB' THEN
            l_message :=  NVL(l_message,'IGS_SS_WARN_REPEAT_CHK');
          ELSE
            l_message := NVL(l_message,'IGS_EN_REPEAT_TAB_WARN');
            l_message_token := 'UNIT_CD:'||l_max_repeats||';';
          END IF;
        END IF;

       IF p_calling_obj NOT IN  ('JOB','SCH_UPD') THEN

          l_message_icon := substr(p_deny_warn,1,1);
          igs_en_drop_units_api.create_ss_warning (
                 p_person_id => p_person_id,
                 p_course_cd => p_program_cd,
                 p_term_cal_type=> p_load_cal_type,
                 p_term_ci_sequence_number => p_load_cal_seq_number,
                 p_uoo_id => p_uoo_id,
                 p_message_for => rec_cur_unit_details.unit_cd||'/'||rec_cur_unit_details.unit_class,
                 p_message_icon=> l_message_icon,
                 p_message_name => l_message,
                 p_message_rule_text => NULL,
                 p_message_tokens => l_message_token,
                 p_message_action=> NULL,
                 p_destination =>NULL,
                 p_parameters => NULL,
                 p_step_type => 'UNIT');

      ELSE
          IF (p_message IS NULL) THEN
            p_message := l_message;
          ELSE
            p_message := p_message || ';' || l_message;
          END IF;
      END IF; --IF p_calling_obj <> 'JOB'

       p_repeat_tag := 'Y';
       RETURN FALSE;

  END eval_unit_repeat;







FUNCTION eval_unit_reenroll (
    p_person_id                    IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_cal_seq_number          IN     NUMBER,
    p_uoo_id                       IN     NUMBER,
    p_program_cd                   IN     VARCHAR2,
    p_program_version              IN     NUMBER,
    p_deny_warn                    IN     VARCHAR2,
    p_upd_cp                       IN     NUMBER,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_val_level                    IN     VARCHAR2,
    p_calling_obj                  IN     VARCHAR2
  ) RETURN BOOLEAN AS
  ------------------------------------------------------------------------------------
    --Created by  : rvivekan ( Oracle IDC)
    --Date created: 18-JUN-2003
    --
    --Purpose:  this function returns TRUE for a given student and unit attempt
    --          if the unit attempt is in line with reenroll validation
    --         (if applicable).Introduced as a prt of reenrollment and repeat build #2881363
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    --jbegum      25-jun-03       BUG#2930935
    --                            Modified the cursor cur_student_attempts.
    --rvivekan    9-sep-03        modified column name in cur_reenroll_in_same_tp_usec
    --                            definitions of l_reenroll_in_same_tp and l_reenroll_allowed #3052433
    -- svanukur   14-jan-2004     Cahnged the condition that checks for l_reenroll_in_same_tp to 'N'
    --                              bug 3368048
    --stutta      05-Aug-2004     Added call to user hook depending on profile value IGS_EN_REP_REN.
    --                            Build # 3807707
    -- smaddali  29-mar-05   Modified this procedure for bug#4262571
    -------------------------------------------------------------------------------------

   -- Cursor to get the unit section details
    CURSOR cur_unit_details IS
      SELECT   unit_cd,
               unit_class,
               version_number,
               cal_type,
               ci_sequence_number
      FROM     igs_ps_unit_ofr_opt
      WHERE    uoo_id = p_uoo_id;

    -- smaddali modified this cursor to add advance standing units also, bug#4262571
    --  Cursor to select all the reenrolled Unit Attempts of the Student.
      CURSOR cur_student_attempts (
             cp_unit_cd   igs_ps_unit_ver.unit_cd%TYPE,
             cp_version_number igs_ps_unit_ver.version_number%TYPE
           ) IS
      SELECT  sua.unit_cd,
              sua.version_number,
              sua.cal_type,
              sua.ci_sequence_number,
              sua.uoo_id,
              NVL(sua.override_enrolled_cp,NVL(cps.enrolled_credit_points,uv.enrolled_credit_points))  override_enrolled_cp ,
              sua.course_cd
      FROM     igs_en_su_attempt sua,
               igs_ps_unit_ver uv,
               igs_ps_usec_cps cps
      WHERE    sua.person_id = p_person_id
      AND      sua.unit_cd = uv.unit_cd
      AND      sua.version_number = uv.version_number
      AND      sua.unit_cd = cp_unit_cd
      AND      sua.version_number = cp_version_number
      AND      sua.uoo_id = cps.uoo_id(+)
      AND      ((p_calling_obj <> 'PLAN' AND unit_attempt_status IN ('ENROLLED', 'DISCONTIN','COMPLETED','INVALID','UNCONFIRM')  )
               OR (p_calling_obj = 'PLAN' AND unit_attempt_status IN ('ENROLLED', 'DISCONTIN','COMPLETED','INVALID','UNCONFIRM','PLANNED') )
               OR (unit_attempt_status = 'WAITLISTED' AND FND_PROFILE.VALUE('IGS_EN_VAL_WLST')  ='Y'))
      AND      ( sua.cart IS NOT NULL AND ( p_calling_obj <> 'SWAP' OR (p_calling_obj = 'SWAP' AND sua.uoo_id <> p_uoo_id) ) )
      UNION
      SELECT  adv.unit_cd,
              adv.version_number,
              NULL cal_type,
              TO_NUMBER(NULL) ci_sequence_number,
              TO_NUMBER(NULL) uoo_id,
              adv.achievable_credit_points  override_enrolled_cp  ,
              adv.as_course_cd  course_cd
      FROM     igs_av_stnd_unit adv
      WHERE   adv.person_id = p_person_id
      AND     adv.s_adv_stnd_granting_status = 'GRANTED'
      AND    (adv.s_adv_stnd_recognition_type = 'CREDIT'
              AND igs_av_val_asu.granted_adv_standing(adv.person_id,adv.as_course_cd,adv.as_version_number,adv.unit_cd,adv.version_number,'GRANTED',NULL) ='TRUE' )
      AND      adv.unit_cd = cp_unit_cd
      AND     adv.version_number = cp_version_number;

    --
    --  Cursor to get the same Teaching Period indicator  at Unit Section  level.
    --
    CURSOR cur_reenroll_in_same_tp_usec IS
      SELECT   not_multiple_section_flag
      FROM     igs_ps_unit_ofr_opt
      WHERE    uoo_id = p_uoo_id;

    --
    -- Cursor to get the reenroll allowed indicator and the reenrollment limits
    --
    CURSOR  cur_unit_reenroll_details(cp_unit_cd   igs_ps_unit_ver.unit_cd%TYPE,
             cp_version_number igs_ps_unit_ver.version_number%TYPE)  IS
      SELECT  repeatable_ind,same_teach_period_repeats,same_teach_period_repeats_cp,
              max_repeats_for_credit,max_repeat_credit_points, same_teaching_period
      FROM  igs_ps_unit_ver
      WHERE  unit_cd = cp_unit_cd
      AND  version_number = cp_version_number;

    --
    rec_cur_unit_details cur_unit_details%ROWTYPE;
    l_step_override_limit igs_en_elgb_ovr_step.step_override_limit%TYPE;
    l_no_of_reenrollments NUMBER := 0 ;
    l_total_reenroll_credit_points NUMBER := 0 ;
    l_reenroll_in_same_tp  igs_ps_unit_ofr_opt.not_multiple_section_flag%TYPE;
    l_reenroll_allowed igs_ps_unit_ver.repeatable_ind%TYPE ;
    l_max_reenrollments_for_credit NUMBER ;
    l_max_renroll_credit_points NUMBER  ;
    l_count  NUMBER := 0;
    l_same_tp_reenrollments NUMBER := 0 ;
    l_same_tp_cp NUMBER := 0;
    l_max_same_tp_reenrollments  NUMBER ;
    l_max_same_tp_cp  NUMBER;
    l_message         VARCHAR2(100);
    l_reenroll_fail BOOLEAN DEFAULT FALSE;
    l_reenroll_cp_fail BOOLEAN DEFAULT FALSE;
    l_reenroll_same_tp_fail BOOLEAN DEFAULT FALSE;
    l_reenroll_same_tp_cp_fail BOOLEAN DEFAULT FALSE;
    l_user_hook_successful BOOLEAN;
    l_unit_mus VARCHAR2(1);
    l_mus_ind VARCHAR2(1);
    l_message_icon VARCHAR2(1);
    l_message_token VARCHAR2(100);
  BEGIN

  --
  --  Check whether Unit Level Reenroll step has been overridden.
  -- this check is performed only when uoo_id is passed
  IF p_uoo_id IS NOT NULL THEN
    IF Igs_En_Gen_015.validation_step_is_overridden (
       'REENROLL',
       p_load_cal_type,
       p_load_cal_seq_number,
       p_person_id,
       p_uoo_id,
       l_step_override_limit
     ) THEN

       RETURN TRUE;
    END IF;
   END IF;
    --
    --  Get the Unit Details for the passed Unit Section.
    --
    OPEN cur_unit_details;
    FETCH cur_unit_details INTO rec_cur_unit_details;
    CLOSE cur_unit_details;

  --  Check if the Unit Section is Reenrollment allowed.
   OPEN cur_unit_reenroll_details(rec_cur_unit_details.unit_cd,
                             rec_cur_unit_details.version_number) ;
   FETCH cur_unit_reenroll_details INTO l_reenroll_allowed,l_max_same_tp_reenrollments,l_max_same_tp_cp,
                  l_max_reenrollments_for_credit, l_max_renroll_credit_points, l_unit_mus;


   IF cur_unit_reenroll_details%NOTFOUND OR l_reenroll_allowed IS NULL THEN
      l_reenroll_allowed := 'N';
   END IF;
   CLOSE cur_unit_reenroll_details ;

     --If repeatable indicator is 'N' means the unit is set for reenroll processing
    IF (l_reenroll_allowed IN ('N','X') ) THEN
      RETURN  TRUE;
    END IF;
    --  Calculate the Reenrollment Credit Points and Number of Reenrollments.
    --
   FOR rec_cur_student_attempts IN cur_student_attempts (
             rec_cur_unit_details.unit_cd,
             rec_cur_unit_details.version_number
           )
   LOOP
       l_count := l_count + 1;

          l_total_reenroll_credit_points := l_total_reenroll_credit_points + rec_cur_student_attempts.override_enrolled_cp;
          l_no_of_reenrollments := l_no_of_reenrollments + 1;
          --
          --  Check whether this Unit has already been taken in the Same Teaching Period selected for Enrollment.
          --
          IF (( rec_cur_unit_details.cal_type = rec_cur_student_attempts.cal_type AND
               rec_cur_unit_details.ci_sequence_number = rec_cur_student_attempts.ci_sequence_number
         ) OR
         ( rec_cur_student_attempts.cal_type IS NULL AND
            rec_cur_student_attempts.ci_sequence_number IS NULL
    )
        ) THEN
             l_same_tp_cp := l_same_tp_cp +  rec_cur_student_attempts.override_enrolled_cp;
             l_same_tp_reenrollments  := l_same_tp_reenrollments + 1 ;
          END IF;

    END LOOP;

    --
    --  get the same Teaching Period indicator  at the  Unit section level.
    -- setting the null value to be 'Y' since a value of 'N' implies unit is
    -- part of MUS.
    OPEN cur_reenroll_in_same_tp_usec;
    FETCH cur_reenroll_in_same_tp_usec INTO l_reenroll_in_same_tp;
    IF  cur_reenroll_in_same_tp_usec%NOTFOUND  OR l_reenroll_in_same_tp IS NULL  THEN
           l_reenroll_in_same_tp := 'Y';
    END IF;
    CLOSE cur_reenroll_in_same_tp_usec;

    IF  (l_reenroll_allowed = 'Y') THEN

         IF NVL(FND_PROFILE.VALUE('IGS_EN_REP_REN'),'NONE') = 'BOTH'
         OR NVL(FND_PROFILE.VALUE('IGS_EN_REP_REN'),'NONE') = 'REENROLL_EXTERNAL' THEN
                --
                --  Call User Hook.
                --
                IF l_unit_mus = 'N' OR l_reenroll_in_same_tp = 'Y' THEN
                  -- if MUS not selected at unit level or Excluded at unit section level
                    l_mus_ind := 'N';
                ELSE
                  --
                    l_mus_ind := 'Y';
                END IF;

                l_user_hook_successful := NULL;
                l_user_hook_successful := IGS_EN_RPT_PRC_UHK.repeat_reenroll_allowed(
                                            p_person_id => p_person_id,
                                            p_program_cd => p_program_cd,
                                            p_unit_cd => rec_cur_unit_details.unit_cd,
                                            P_uoo_id => p_uoo_id,
                                            p_repeat_reenroll => 'REENROLL',
                                            p_load_cal_type => p_load_cal_type,
                                            p_load_ci_seq_number => p_load_cal_seq_number,
                                            p_repeat_max => NULL,
                                            p_repeat_funding => NULL,
                                            p_mus_ind => l_mus_ind,
                                            p_reenroll_max => l_max_reenrollments_for_credit,
                                            p_reenroll_max_cp => l_max_renroll_credit_points,
                                            p_same_tch_reenroll_max => l_max_same_tp_reenrollments,
                                            p_same_tch_reenroll_max_cp => l_max_same_tp_cp,
                                            p_message => l_message);
                IF NVL(l_user_hook_successful,FALSE) THEN
                     RETURN TRUE;
                ELSE
                  -- set the token only when l_message is null
                  IF l_message IS NULL THEN
                    l_message_token := 'UNIT_CD'||':'||l_max_reenrollments_for_credit||';';
                  END IF;
                    -- Check if message is returned from user hook
                  IF p_deny_warn = 'DENY' THEN
                    IF p_calling_obj IN ('JOB','SCH_UPD') THEN
                      l_message := NVL(l_message,'IGS_SS_DENY_REENR_CHK');
                    ELSE
                      l_message := NVL(l_message,'IGS_EN_REENRL_TAB_DENY');
                    END IF;
                  ELSE
                    IF p_calling_obj = 'JOB' THEN
                      l_message := NVL(l_message,'IGS_SS_WARN_REENR_CHK');
                    ELSIF p_calling_obj <> 'SCH_UPD' THEN
                      l_message := NVL(l_message,'IGS_EN_REENRL_TAB_WARN');
                    END IF;

                  END IF; -- p_message = 'DENY'

                  IF p_calling_obj NOT IN  ('JOB','SCH_UPD') THEN

                    l_message_icon := substr(p_deny_warn,1,1);
                    igs_en_drop_units_api.create_ss_warning (
                           p_person_id => p_person_id,
                           p_course_cd => p_program_cd,
                           p_term_cal_type=> p_load_cal_type,
                           p_term_ci_sequence_number => p_load_cal_seq_number,
                           p_uoo_id => p_uoo_id,
                           p_message_for => rec_cur_unit_details.unit_cd||'/'||rec_cur_unit_details.unit_class,
                           p_message_icon=> l_message_icon,
                           p_message_name => l_message,
                           p_message_rule_text => NULL,
                           p_message_tokens => l_message_token,
                           p_message_action=> NULL,
                           p_destination =>NULL,
                           p_parameters => NULL,
                           p_step_type => 'UNIT');

                  ELSE
                      IF (p_message IS NULL) THEN
                        p_message := l_message;
                      ELSE
                        p_message := p_message || ';' || l_message;
                      END IF;
                END IF; --IF p_calling_obj <> 'JOB'
                  RETURN FALSE;
                END IF; -- user hook successful
         END IF; -- FND_PROFILE.VALUE
    END IF; -- l_reenroll_allowed

  --  There are no reenrolled unit attempts or advance standing for this unit
  --  So return TRUE.
  -- smaddali moved this code from before calling the user hook, for bug#4262571
    IF l_count = 0 THEN
         RETURN TRUE;
    END IF;

    -- If limit is NUll  then it means no limit is set
    l_max_reenrollments_for_credit := NVL (l_max_reenrollments_for_credit, 999999);
    l_max_renroll_credit_points := NVL (l_max_renroll_credit_points, 999.999);
    l_max_same_tp_reenrollments := NVL(l_max_same_tp_reenrollments,999999) ;
    l_max_same_tp_cp  :=  NVL(l_max_same_tp_cp,999.999) ;

    -- If the procedure called when user has overriden the unit attempt credit points
    -- then the difference would be passed in to the parameter p_upd_cp
    -- Add this cp to the total credit points
       l_total_reenroll_credit_points := l_total_reenroll_credit_points + NVL(p_upd_cp,0);
       l_same_tp_cp := l_same_tp_cp +  NVL(p_upd_cp,0);

      IF (l_no_of_reenrollments > l_max_reenrollments_for_credit) THEN
        l_reenroll_fail := TRUE;
      END IF;

      IF NOT(p_deny_warn = 'DENY' AND l_reenroll_fail) THEN
          IF (l_total_reenroll_credit_points > l_max_renroll_credit_points) THEN
            l_reenroll_cp_fail := TRUE;
          END IF;
      END IF;
   --check if l_reenroll_in_same_tp is 'N' since this means the unit is partof MUS
      IF l_reenroll_in_same_tp = 'N' THEN
         IF NOT(p_deny_warn = 'DENY' AND (l_reenroll_fail OR l_reenroll_cp_fail)) THEN
              IF (l_same_tp_reenrollments > l_max_same_tp_reenrollments) THEN
                l_reenroll_same_tp_fail := TRUE;
              END IF;

              IF NOT(p_deny_warn = 'DENY' AND l_reenroll_same_tp_fail) THEN
                  IF (l_same_tp_cp > l_max_same_tp_cp) THEN
                    l_reenroll_same_tp_cp_fail := TRUE;
                  END IF;
              END IF;
         END IF;
      END IF;

   IF NOT l_reenroll_fail AND NOT l_reenroll_cp_fail AND NOT l_reenroll_same_tp_fail AND NOT l_reenroll_same_tp_cp_fail THEN
     -- No limit is breached.

     RETURN TRUE;
   END IF;

   IF p_deny_warn = 'WARN' THEN

      -- no warning messages for sch_upd
      IF p_calling_obj <> 'SCH_UPD' THEN

         IF l_reenroll_cp_fail THEN
            IF p_calling_obj = 'JOB' THEN
              l_message := 'IGS_SS_WARN_REENR_CP_CHK';
            ELSIF p_calling_obj <> 'SCH_UPD' THEN
              l_message := 'IGS_EN_REENCP_TAB_WARN';
              l_message_token := 'UNIT_CD'||':'||l_max_renroll_credit_points||';';
            END IF;
         END IF;

         IF l_reenroll_fail AND p_val_level='ALL' THEN
            IF p_calling_obj = 'JOB' THEN
              l_message := 'IGS_SS_WARN_REENR_CHK';
            ELSIF p_calling_obj <> 'SCH_UPD' THEN
              l_message := 'IGS_EN_REENRL_TAB_WARN';
              l_message_token := 'UNIT_CD'||':'||l_max_reenrollments_for_credit||';';
            END IF;
         END IF;

         IF l_reenroll_same_tp_cp_fail THEN
            IF p_calling_obj IN ('JOB','SCH_UPD') THEN
              l_message := 'IGS_SS_WARN_REENR_STP_CP_CHK';
            ELSE
              l_message := 'IGS_EN_REENCP_STP_TAB_WARN';
              l_message_token := 'UNIT_CD'||':'||l_max_same_tp_cp||';';
            END IF;
         END IF;

         IF l_reenroll_same_tp_fail AND p_val_level='ALL' THEN
            IF p_calling_obj IN ('JOB','SCH_UPD') THEN
              l_message := 'IGS_SS_WARN_REENR_STP_CHK';
            ELSE
              l_message := 'IGS_EN_REENR_STP_TAB_WARN';
              l_message_token := 'UNIT_CD'||':'||l_max_same_tp_reenrollments||';';
            END IF;
         END IF;

      END IF; -- IF p_calling_obj <> 'SCH_UPD'

   ELSE
       IF l_reenroll_cp_fail THEN
          IF p_calling_obj = 'SCH_UPD' THEN
            l_message  :=  'IGS_EN_REENR_UPD_DENY'  || '*' || l_max_renroll_credit_points ;
          ELSIF p_calling_obj = 'JOB' THEN
            l_message := 'IGS_SS_DENY_REENR_CP_CHK';
          ELSE
            l_message := 'IGS_EN_REENCP_TAB_DENY';
            l_message_token := 'UNIT_CD'||':'||l_max_renroll_credit_points||';';
          END IF;
       END IF;

       IF l_reenroll_fail AND p_val_level='ALL' THEN
          IF p_calling_obj IN ('JOB','SCH_UPD') THEN
            l_message := 'IGS_SS_DENY_REENR_CHK';
          ELSE
            l_message := 'IGS_EN_REENRL_TAB_DENY';
            l_message_token := 'UNIT_CD'||':'||l_max_reenrollments_for_credit||';';
          END IF;
       END IF;

       IF l_reenroll_same_tp_cp_fail THEN
          IF p_calling_obj = 'SCH_UPD' THEN
            l_message  :=  'IGS_EN_REENSTP_UPD_DENY' || '*' || l_max_same_tp_cp ;
          ELSIF p_calling_obj = 'JOB' THEN
            l_message := 'IGS_SS_DENY_REENR_STP_CP_CHK';
          ELSE
            l_message := 'IGS_EN_REENCP_STP_TAB_DENY';
            l_message_token := 'UNIT_CD'||':'||l_max_same_tp_cp||';';
          END IF;
       END IF;

       IF l_reenroll_same_tp_fail AND p_val_level='ALL' THEN
          IF p_calling_obj IN ('JOB','SCH_UPD') THEN
            l_message := 'IGS_SS_DENY_REENR_STP_CHK';
          ELSE
            l_message := 'IGS_EN_REENR_STP_TAB_DENY';
            l_message_token := 'UNIT_CD'||':'||l_max_same_tp_reenrollments||';';
          END IF;
       END IF;
   END IF;

   IF p_calling_obj NOT IN ('JOB','SCH_UPD') THEN

          l_message_icon := substr(p_deny_warn,1,1);
          igs_en_drop_units_api.create_ss_warning (
                 p_person_id => p_person_id,
                 p_course_cd => p_program_cd,
                 p_term_cal_type=> p_load_cal_type,
                 p_term_ci_sequence_number => p_load_cal_seq_number,
                 p_uoo_id => p_uoo_id,
                 p_message_for => rec_cur_unit_details.unit_cd||'/'||rec_cur_unit_details.unit_class,
                 p_message_icon=> l_message_icon,
                 p_message_name => l_message,
                 p_message_rule_text => NULL,
                 p_message_tokens => l_message_token,
                 p_message_action=> NULL,
                 p_destination =>NULL,
                 p_parameters => NULL,
                 p_step_type => 'UNIT');

    ELSE
            IF (p_message IS NULL) THEN
              p_message := l_message;
            ELSE
              p_message := p_message || ';' || l_message;
            END IF;
    END IF; --IF p_calling_obj <> 'JOB'

   RETURN FALSE;
    --
  END eval_unit_reenroll;

  --
  --
  --  This function is used to evaluate the Time Conflict for the Student's Unit Section Occurrences.
  --
  -- smaddali modified this function for PSP004 bug#2191501
  -- smaddali modified the two cursors ,to remove the NVL( day,'N') for all the days
  -- being selected .Since here the two occurrences conflict only if both have monday = 'Y'
  -- or tuesday = 'Y so on ... By selecting NVL(monday,'N') even though both are not  ='Y'
  -- they are equal to each other because of the NVL and hence is being considered as conflicting
  FUNCTION eval_time_conflict
  (
    p_person_id                    IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_cal_seq_number          IN     NUMBER,
    p_uoo_id                       IN     NUMBER,
    p_program_cd                   IN     VARCHAR2,
    p_program_version              IN     VARCHAR2,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_deny_warn                    IN     VARCHAR2,
    p_calling_obj                  IN     VARCHAR2
  ) RETURN BOOLEAN AS

/*--------------------------------------------------------------------------------+
 | HISTORY                                                                        |
 | Who         When           What                                                |
 |ptandon     1-Sep-2003     Modified the cursor cur_usec_occurs_existing         |
 |                           to consider waitlisted students based on the value   |
 |                           of checkbox 'Waitlist Allowed with Time Conflict'    |
 |                           in institutional waitlist options form and the       |
 |                           profile has been obsolete as part of Waitlist        |
 |                           Enhancements Build - Bug# 3052426                    |
 |ptandon    14-Jan-2004     Modified the cursor cur_usec_occurs_existing to      |
 |                           change the unit attempt status from WAITLIST to      |
 |                           WAITLISTED. Bug# 3371080.                            |
 +-------------------------------------------------------------------------------*/
    --
    --  Parameters Description:
    --
    --  p_person_id                  -> Person ID of the student who wants to enroll or administrator is enrolling.
    --  p_load_cal_type              -> Load (Term) or Teaching Calendar Type.
    --  p_load_cal_seq_number        -> Load Calendar or Teaching Calendar instance sequence number.
    --  p_uoo_id                     -> Unit Section Identifier.
    --  p_program_cd                 -> The Primary Program Code or the Program code selected by the student.
    --  p_program_version            -> The Primary Program version number or the Program version number selected by the student.
    --  p_message                    -> Message from the validation.
    --  p_deny_warn                  -> Deny or Warn Indicator based on the setup.
    --
    --
    --  Cursor to find Unit Section Occurrences for the passed Unit Section.
    --
    CURSOR cur_usec_occurs_new (
             cp_uoo_id                IN NUMBER
           ) IS
    SELECT   uocr.monday ,
             uocr.tuesday ,
             uocr.wednesday,
             uocr.thursday,
             uocr.friday ,
             uocr.saturday ,
             uocr.sunday ,
             uocr.start_time start_time,
             uocr.end_time end_time,
             uoo.unit_cd,
             uoo.unit_class,
             NVL (uocr.start_date, NVL (uoo.unit_section_start_date, ci.start_dt)) start_date,
             NVL (uocr.end_date, NVL (uoo.unit_section_end_date, ci.end_dt)) end_date
    FROM     igs_ps_usec_occurs uocr,
             igs_ps_unit_ofr_opt uoo,
             igs_ca_inst ci
    WHERE    uoo.uoo_id = cp_uoo_id
    AND      uoo.uoo_id = uocr.uoo_id
    AND      uoo.cal_type = ci.cal_type
    AND      uoo.ci_sequence_number = ci.sequence_number;
    --
    --  Cursor to find existing Unit Section Occurrences that the Student has already attempted.
    --
    CURSOR cur_usec_occurs_existing IS
    SELECT   uocur.uoo_id,
             uocur.monday,
             uocur.tuesday,
             uocur.wednesday,
             uocur.thursday,
             uocur.friday,
             uocur.saturday,
             uocur.sunday,
             uocur.start_time,
             uocur.end_time,
             uoo.unit_cd,
             uoo.unit_class,
             NVL (uocur.start_date, NVL (uoo.unit_section_start_date, lt.start_dt)) start_date,
             NVL (uocur.end_date, NVL (uoo.unit_section_end_date, lt.end_dt)) end_date
    FROM     igs_ps_usec_occurs uocur,
             igs_en_su_attempt_all ua,
             igs_ca_inst lt,
             igs_ps_unit_ofr_opt_all uoo
    WHERE    uocur.uoo_id = ua.uoo_id
    AND      uoo.uoo_id = ua.uoo_id
    AND      ua.uoo_id <> p_uoo_id
    AND      ua.cal_type = lt.cal_type
    AND      ua.ci_sequence_number = lt.sequence_number
    AND      ua.person_id = p_person_id
    AND     (
              (  p_calling_obj <>'PLAN' AND
                  ( ua.unit_attempt_status IN ( 'ENROLLED','INVALID') OR
                        ( ua.unit_attempt_status = 'WAITLISTED' AND
                              ( EXISTS(SELECT 'X' FROM IGS_EN_INST_WL_STPS  WHERE TIME_CONFL_ALWD_WLST_FLAG = 'N' ) OR
                                  ( NOT EXISTS(SELECT 'X' FROM IGS_EN_INST_WL_STPS  )  AND FND_PROFILE.VALUE('IGS_EN_VAL_WLST')  ='Y' )
                               )
                         )
                   )
               )
              OR
              ( p_calling_obj ='PLAN' AND
                     (ua.unit_attempt_status IN ( 'ENROLLED','INVALID','PLANNED') OR
                           (ua.unit_attempt_status = 'WAITLISTED' AND (EXISTS(SELECT 'X' FROM IGS_EN_INST_WL_STPS WHERE TIME_CONFL_ALWD_WLST_FLAG = 'N')  )  OR
                                ( NOT EXISTS(SELECT 'X' FROM IGS_EN_INST_WL_STPS  )  AND FND_PROFILE.VALUE('IGS_EN_VAL_WLST')  ='Y' )
                            )
                      )
               )

            );

     --
    rec_cur_usec_occurs_new     cur_usec_occurs_new%ROWTYPE;
    l_step_override_limit       igs_en_elgb_ovr_step.step_override_limit%TYPE;
    d_new_start_time            DATE;
    d_new_end_time              DATE;
    d_existing_start_time       DATE;
    d_existing_end_time         DATE;
    l_time_conflict_found       BOOLEAN := FALSE;
    l_message                   VARCHAR2(30);
    l_message_icon              VARCHAR2(30);
    l_message_token             VARCHAR2(100);

  BEGIN
    --
    --  Check whether Unit Level Time Conflict step has been overridden.
    --
    IF Igs_En_Gen_015.validation_step_is_overridden (
         'TIME_CNFLT',
         p_load_cal_type,
         p_load_cal_seq_number,
         p_person_id,
         p_uoo_id,
         l_step_override_limit
       ) THEN
      RETURN TRUE;
    END IF;
    --
    OPEN cur_usec_occurs_new (p_uoo_id);
    LOOP
      FETCH cur_usec_occurs_new INTO rec_cur_usec_occurs_new;
      IF ((cur_usec_occurs_new%NOTFOUND) AND (cur_usec_occurs_new%ROWCOUNT = 0)) THEN
        CLOSE cur_usec_occurs_new;
        RETURN TRUE;
      ELSIF (cur_usec_occurs_new%NOTFOUND) THEN
        CLOSE cur_usec_occurs_new;
        EXIT;
      END IF;

      --
      --  Loop through all the Unit Section Occurrences that the student attempted,
      --  and check for time conflict.
      --
      FOR rec_cur_usec_occurs_existing IN cur_usec_occurs_existing LOOP
        --
        --  Check if Effective dates of the occurrences for the new and existing Unit Section Occurrences overlap.
        --     S2         E2 S1                  E1 S2        E2
        --      |----------|  |-------------------| |----------|
        --         S2         E2         S2         E2
        --          |----------|          |----------|
        --         S2                               E2
        --          |--------------------------------|
        --
        IF ((rec_cur_usec_occurs_new.start_date BETWEEN rec_cur_usec_occurs_existing.start_date AND rec_cur_usec_occurs_existing.end_date) OR
            (rec_cur_usec_occurs_new.end_date BETWEEN rec_cur_usec_occurs_existing.start_date AND rec_cur_usec_occurs_existing.end_date) OR
            (rec_cur_usec_occurs_existing.start_date BETWEEN rec_cur_usec_occurs_new.start_date AND rec_cur_usec_occurs_new.end_date) OR
            (rec_cur_usec_occurs_existing.end_date BETWEEN rec_cur_usec_occurs_new.start_date AND rec_cur_usec_occurs_new.end_date)) THEN
          --
          --  Check if the same day (MONDAY..SUNDAY) is selected for meetings.
          --
          IF ((rec_cur_usec_occurs_new.monday = 'Y' AND  rec_cur_usec_occurs_existing.monday='Y') OR
              (rec_cur_usec_occurs_new.tuesday = 'Y' AND rec_cur_usec_occurs_existing.tuesday='Y') OR
              (rec_cur_usec_occurs_new.wednesday ='Y' AND  rec_cur_usec_occurs_existing.wednesday='Y') OR
              (rec_cur_usec_occurs_new.thursday ='Y' AND rec_cur_usec_occurs_existing.thursday='Y') OR
              (rec_cur_usec_occurs_new.friday ='Y' AND rec_cur_usec_occurs_existing.friday='Y') OR
              (rec_cur_usec_occurs_new.saturday ='Y' AND rec_cur_usec_occurs_existing.saturday='Y') OR
              (rec_cur_usec_occurs_new.sunday ='Y' AND rec_cur_usec_occurs_existing.sunday='Y')) THEN

            --  Check if Start Time and End Time for the new and existing Unit Section Occurrences overlap.
            --
            -- Extracting the time component alone to create new date-time values
            -- as the date component is not needed
            d_new_start_time        := TO_DATE ('1000/01/01 ' || TO_CHAR (rec_cur_usec_occurs_new.start_time, 'HH24:MI:SS'), 'YYYY/MM/DD HH24:MI:SS');
            d_new_end_time          := TO_DATE ('1000/01/01 ' || TO_CHAR (rec_cur_usec_occurs_new.end_time, 'HH24:MI:SS'), 'YYYY/MM/DD HH24:MI:SS');
            d_existing_start_time   := TO_DATE ('1000/01/01 ' || TO_CHAR (rec_cur_usec_occurs_existing.start_time, 'HH24:MI:SS'), 'YYYY/MM/DD HH24:MI:SS');
            d_existing_end_time     := TO_DATE ('1000/01/01 ' || TO_CHAR (rec_cur_usec_occurs_existing.end_time, 'HH24:MI:SS'), 'YYYY/MM/DD HH24:MI:SS');

            IF ( (d_new_start_time BETWEEN d_existing_start_time AND d_existing_end_time) OR
                 (d_new_end_time BETWEEN d_existing_start_time AND d_existing_end_time) OR
                 (d_existing_start_time BETWEEN d_new_start_time AND d_new_end_time) OR
                 (d_existing_end_time BETWEEN d_new_start_time AND d_new_end_time) ) THEN
              --
              --  Boundary conditions should be treated as no overlap.
              --  For example a class ending at 9 a.m. is not in conflict with another class starting at 9 a.m.
              --
              IF ((d_new_start_time = d_existing_end_time) OR
                  (d_existing_start_time = d_new_end_time)) THEN
                NULL;
              ELSE
                -- smaddali added this new If condition call for Instructor information dld PSP004
                --bug#2191501 to check if there is any time conflict at the date instance level
                IF NOT igs_ps_rlovr_fac_tsk.crsp_chk_inst_time_conft( rec_cur_usec_occurs_existing.start_date ,
                  rec_cur_usec_occurs_existing.end_date,rec_cur_usec_occurs_existing.monday,
                  rec_cur_usec_occurs_existing.tuesday, rec_cur_usec_occurs_existing.wednesday,
                  rec_cur_usec_occurs_existing.thursday, rec_cur_usec_occurs_existing.friday,
                  rec_cur_usec_occurs_existing.saturday, rec_cur_usec_occurs_existing.sunday ,
                  rec_cur_usec_occurs_new.start_date,   rec_cur_usec_occurs_new.end_date ,
                  rec_cur_usec_occurs_new.monday,rec_cur_usec_occurs_new.tuesday,
                  rec_cur_usec_occurs_new.wednesday,rec_cur_usec_occurs_new.thursday,
                  rec_cur_usec_occurs_new.friday,rec_cur_usec_occurs_new.saturday,rec_cur_usec_occurs_new.sunday) THEN
                    NULL ;
                ELSE
                    l_time_conflict_found := TRUE;
                   --
                   --  If the student has satisfied the Time Conflict then return FALSE with a warning/deny message.
                   --
                   IF (p_deny_warn = 'WARN') THEN
                     IF p_calling_obj = 'JOB' THEN
                        l_message := 'IGS_SS_WARN_TCONFLICT_CHK';
                     ELSE
                        l_message := 'IGS_EN_TCONFLICT_TAB_WARN';
                     END IF;
                   ELSE
                     IF p_calling_obj = 'JOB' THEN
                        l_message := 'IGS_SS_DENY_TCONFLICT_CHK';
                     ELSE
                       l_message := 'IGS_EN_TCONFLICT_TAB_DENY';
                     END IF;
                   END IF;

                   IF p_calling_obj NOT IN  ('JOB','SCH_UPD') THEN

                    l_message_token := 'UNIT_CD'||':'||rec_cur_usec_occurs_existing.unit_cd||'/'||rec_cur_usec_occurs_existing.unit_class||';';

                    l_message_icon := substr(p_deny_warn,1,1);
                    igs_en_drop_units_api.create_ss_warning (
                           p_person_id => p_person_id,
                           p_course_cd => p_program_cd,
                           p_term_cal_type=> p_load_cal_type,
                           p_term_ci_sequence_number => p_load_cal_seq_number,
                           p_uoo_id => p_uoo_id,
                           p_message_for => rec_cur_usec_occurs_new.unit_cd||'/'||rec_cur_usec_occurs_new.unit_class,
                           p_message_icon=> l_message_icon,
                           p_message_name => l_message,
                           p_message_rule_text => NULL,
                           p_message_tokens => l_message_token,
                           p_message_action=> NULL,
                           p_destination =>NULL,
                           p_parameters => NULL,
                           p_step_type => 'UNIT');

                   ELSE
                     IF (p_message IS NULL) THEN
                       p_message := l_message;
                     ELSE
                       p_message := p_message || ';' || l_message;
                     END IF;
                   END IF;  -- warn level
                   RETURN FALSE;
                END IF ;  -- conflict exists at date instance level
              END IF;
            END IF;
          END IF;
        END IF;
      END LOOP;
    END LOOP;

    IF cur_usec_occurs_new%ISOPEN THEN
       CLOSE cur_usec_occurs_new;
    END IF;

    --
    --  Return TRUE if no Time Conflict is found.
    --
    IF (NOT l_time_conflict_found) THEN
      RETURN TRUE;
    END IF;
    --
  END eval_time_conflict;
--
-- ================================================================================
FUNCTION eval_prereq (
p_person_id IN NUMBER,
p_load_cal_type IN VARCHAR2,
p_load_sequence_number IN VARCHAR2,
p_uoo_id  IN NUMBER,
p_course_cd IN VARCHAR2,
p_course_version IN NUMBER,
p_message IN OUT NOCOPY VARCHAR2,
p_deny_warn  IN VARCHAR2,
p_calling_obj IN VARCHAR2
) RETURN BOOLEAN AS

--------------------------------------------------------------------------------
  --Created by  : knaraset ( Oracle IDC)
  --Date created: 21-JUN-2001
  --
  --Purpose:
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --stutta    21-Sep-2004    Passing p_parm_5 as 'Y' in rules engine call. This value
  --                         is expected by rule componenet PREDICTED_ENROLLED.Bug#3902375
  --bdeviset  12-DEC-2005    Passing extra parameter p_param_8 ( in which the uoo_is is passed)
  --                         while calling rules engine for Bug# 4304688
  ------------------------------------------------------------------------------
  CURSOR cur_uoo_prereq(p_uoo_id NUMBER) IS
  SELECT rul_sequence_number
  FROM igs_ps_usec_ru
  WHERE uoo_id = p_uoo_id AND
        s_rule_call_cd = 'USECPREREQ';

  CURSOR cur_unit_prereq(p_uoo_id NUMBER) IS
  SELECT rul_sequence_number
  FROM igs_ps_unit_ver_ru uvr,
       igs_ps_unit_ofr_opt uoo
  WHERE uvr.unit_cd = uoo.unit_cd AND
        uvr.version_number = uoo.version_number AND
                uoo_id = p_uoo_id AND
                uvr.s_rule_call_cd = 'PREREQ';

  CURSOR cur_usec_dtl(p_uoo_id NUMBER) IS
  SELECT unit_cd,unit_class,version_number,cal_type,ci_sequence_number
  FROM igs_ps_unit_ofr_opt
  WHERE uoo_id = p_uoo_id;

  l_step_override_limit igs_en_elgb_ovr_step.step_override_limit%TYPE;
  l_rul_sequence_number igs_ps_unit_ver_ru.rul_sequence_number%TYPE;
  l_unit_dtls_rec cur_usec_dtl%ROWTYPE;
  l_version_number igs_ps_unit_ofr_opt.version_number%TYPE;
  l_cal_type igs_ps_unit_ofr_opt.cal_type%TYPE;
  l_ci_sequence_number igs_ps_unit_ofr_opt.ci_sequence_number%TYPE;
  l_message VARCHAR2(30);
  l_rule_text igs_ps_unit_ver_ru_v.rule_text%TYPE;
  l_message_icon VARCHAR2(1);

--
-- begin of the function eval_prereq
--
BEGIN
l_rule_text := NULL;
IF Igs_En_Gen_015.validation_step_is_overridden ('PREREQ',
                                                p_load_cal_type,
                                                p_load_sequence_number ,
                                                p_person_id ,
                                                p_uoo_id ,
                                                l_step_override_limit) THEN
    RETURN TRUE;
END IF;

-- check whether pre-requisite rule are defined at unit section level
OPEN cur_uoo_prereq (p_uoo_id);
FETCH cur_uoo_prereq INTO l_rul_sequence_number;
CLOSE cur_uoo_prereq;

-- if no pre-requisite rule defined at unit section level, check whether defined at Unit level
IF l_rul_sequence_number IS NULL THEN
  OPEN cur_unit_prereq (p_uoo_id);
  FETCH cur_unit_prereq INTO l_rul_sequence_number;
  CLOSE cur_unit_prereq;
END IF;

-- if no pre-requisite rule defined at either levels,
IF l_rul_sequence_number IS NULL THEN
  RETURN TRUE;
END IF;

-- get the details of unit section
OPEN cur_usec_dtl(p_uoo_id);
FETCH  cur_usec_dtl INTO l_unit_dtls_rec;
CLOSE cur_usec_dtl;

--
-- check whether student has satisfied the pre-requisite rule by invoking the rule engine
--
IF igs_ru_gen_001.rulp_val_senna(p_rule_call_name => 'PREREQ',
                                 p_person_id => p_person_id,
                                 p_course_cd => p_course_cd,
                                 p_course_version => p_course_version ,
                                 p_unit_cd => l_unit_dtls_rec.unit_cd,
                                 p_unit_version => l_unit_dtls_rec.version_number,
                                 p_cal_type => l_unit_dtls_rec.cal_type,
                                 p_ci_sequence_number => l_unit_dtls_rec.ci_sequence_number,
                                 p_message => l_message,
                                 p_rule_number => l_rul_sequence_number,
                                 p_param_5 => 'Y',
                                 p_param_8 => p_uoo_id
                                ) = 'true' THEN
   RETURN TRUE;
END IF;

IF(NVL(fnd_profile.value('IGS_EN_CART_RULE_DISPLAY'),'N')='Y') THEN
    l_rule_text :=igs_ru_gen_003.Rulp_Get_Rule(l_rul_sequence_number);
END IF;
IF p_deny_warn = 'WARN' THEN
  IF p_calling_obj = 'JOB' THEN
     l_message := 'IGS_SS_WARN_PREREQ' || '*' || l_unit_dtls_rec.unit_cd;
  ELSE
     l_message := 'IGS_EN_PREREQ_TAB_WARN';
  END IF;
ELSE
  IF p_calling_obj = 'JOB' THEN
     l_message := 'IGS_SS_DENY_PREREQ' || '*' || l_unit_dtls_rec.unit_cd;
  ELSE
     l_message := 'IGS_EN_PREREQ_TAB_DENY';
  END IF;
END IF;


IF p_calling_obj NOT IN  ('JOB','SCH_UPD','DROP') THEN

  l_message_icon := substr(p_deny_warn,1,1);
  igs_en_drop_units_api.create_ss_warning (
         p_person_id => p_person_id,
         p_course_cd => p_course_cd,
         p_term_cal_type=> p_load_cal_type,
         p_term_ci_sequence_number => p_load_sequence_number,
         p_uoo_id => p_uoo_id,
         p_message_for => l_unit_dtls_rec.unit_cd||'/'||l_unit_dtls_rec.unit_class,
         p_message_icon=> l_message_icon,
         p_message_name => l_message,
         p_message_rule_text => l_rule_text,
         p_message_tokens => NULL,
         p_message_action=> NULL,
         p_destination =>NULL,
         p_parameters => NULL,
         p_step_type => 'UNIT');

 -- Incase of DROP only rule text is passed
 -- as the message is set in the drop units api depending on
 -- whether TRUE or FALSE is returned
ELSIF p_calling_obj = 'DROP' THEN
      p_message := l_rule_text;
ELSE

   IF (p_message IS NULL) THEN
     p_message := l_message;
   ELSE
     p_message := p_message || ';' || l_message;
   END IF;

     IF l_rule_text IS NOT NULL THEN
         p_message :=p_message ||';'||'IGS_EN_RULE_TEXT' || '*' || l_rule_text;
    END IF;

END IF;

RETURN FALSE;

END eval_prereq;

-- =================================================================================

FUNCTION eval_coreq(
p_person_id IN NUMBER,
p_load_cal_type IN VARCHAR2,
p_load_sequence_number IN VARCHAR2,
p_uoo_id  IN NUMBER,
p_course_cd IN VARCHAR2,
p_course_version IN NUMBER,
p_message IN OUT NOCOPY VARCHAR2,
p_deny_warn  IN VARCHAR2,
p_calling_obj IN VARCHAR2
) RETURN BOOLEAN AS

------------------------------------------------------------------------------------
  --Created by  : knaraset ( Oracle IDC)
  --Date created: 21-JUN-2001
  --
  --Purpose:
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --bdeviset  12-DEC-2005    Passing extra parameter p_param_8 ( in which the uoo_is is passed)
  --                         while calling rules engine for Bug# 4304688
  -------------------------------------------------------------------------------------
  CURSOR cur_uoo_coreq(p_uoo_id NUMBER) IS
  SELECT rul_sequence_number
  FROM igs_ps_usec_ru
  WHERE uoo_id = p_uoo_id AND
        s_rule_call_cd = 'USECCOREQ';

  CURSOR cur_unit_coreq(p_uoo_id NUMBER) IS
  SELECT rul_sequence_number
  FROM igs_ps_unit_ver_ru uvr,
       igs_ps_unit_ofr_opt uoo
  WHERE uvr.unit_cd = uoo.unit_cd AND
        uvr.version_number = uoo.version_number AND
                uoo_id = p_uoo_id AND
                uvr.s_rule_call_cd = 'COREQ';

  CURSOR cur_usec_dtl(p_uoo_id NUMBER) IS
  SELECT unit_cd,unit_class,version_number,cal_type,ci_sequence_number
  FROM igs_ps_unit_ofr_opt
  WHERE uoo_id = p_uoo_id;

  l_step_override_limit igs_en_elgb_ovr_step.step_override_limit%TYPE;
  l_rul_sequence_number igs_ps_unit_ver_ru.rul_sequence_number%TYPE;
  l_unit_dtls_rec cur_usec_dtl%ROWTYPE;
  l_message VARCHAR2(30);
  l_message_icon VARCHAR2(1);
  l_rule_text igs_ps_unit_ver_ru_v.rule_text%TYPE;
  l_coreq_string VARCHAR2(1000);
  l_destination VARCHAR2(100);
  l_message_action VARCHAR2(100);
--
-- begin of the function eval_coreq
--
BEGIN
l_rule_text := NULL;
IF Igs_En_Gen_015.validation_step_is_overridden ('COREQ',
                                                p_load_cal_type,
                                                p_load_sequence_number ,
                                                p_person_id ,
                                                p_uoo_id ,
                                                l_step_override_limit) THEN
    RETURN TRUE;
END IF;

-- check whether co-requisite rule are defined at unit section level
OPEN cur_uoo_coreq (p_uoo_id);
FETCH cur_uoo_coreq INTO l_rul_sequence_number;
CLOSE cur_uoo_coreq;

-- if no co-requisite rule defined at unit section level, check whether defined at Unit level
IF l_rul_sequence_number IS NULL THEN
  OPEN cur_unit_coreq (p_uoo_id);
  FETCH cur_unit_coreq INTO l_rul_sequence_number;
  CLOSE cur_unit_coreq;
END IF;

-- if no co-requisite rule defined at either levels,
IF l_rul_sequence_number IS NULL THEN
  RETURN TRUE;
END IF;

-- get the details of unit section
OPEN cur_usec_dtl(p_uoo_id);
FETCH  cur_usec_dtl INTO l_unit_dtls_rec;
CLOSE cur_usec_dtl;

--
-- check whether student has satisfied the co-requisite rule by invoking the rule engine

IF igs_ru_gen_001.rulp_val_senna(p_rule_call_name => 'COREQ',
                                 p_person_id => p_person_id,
                                 p_course_cd => p_course_cd,
                                 p_course_version => p_course_version ,
                                 p_unit_cd => l_unit_dtls_rec.unit_cd,
                                 p_unit_version => l_unit_dtls_rec.version_number,
                                 p_cal_type => l_unit_dtls_rec.cal_type,
                                 p_ci_sequence_number => l_unit_dtls_rec.ci_sequence_number,
                                 p_message => l_message,
                                 p_rule_number => l_rul_sequence_number,
                                 p_param_8 => p_uoo_id
   ) = 'true' THEN
   RETURN TRUE;
END IF;

IF(NVL(fnd_profile.value('IGS_EN_CART_RULE_DISPLAY'),'N')='Y')  THEN
    l_rule_text :=igs_ru_gen_003.Rulp_Get_Rule(l_rul_sequence_number);
END IF;

IF p_deny_warn = 'WARN' THEN
  IF p_calling_obj = 'JOB' THEN
     l_message := 'IGS_SS_WARN_COREQ' || '*' || l_unit_dtls_rec.unit_cd;
  ELSE
     l_message := 'IGS_EN_COREQ_TAB_WARN';
  END IF;
ELSE
  IF p_calling_obj = 'JOB' THEN
     l_message := 'IGS_SS_DENY_COREQ' || '*' || l_unit_dtls_rec.unit_cd;
  ELSE
     l_message := 'IGS_EN_COREQ_TAB_DENY';
  END IF;
END IF;

IF p_calling_obj NOT IN  ('JOB','SCH_UPD','DROP') THEN

  l_coreq_string := get_coreq_units(p_uoo_id);
  l_message_icon := substr(p_deny_warn,1,1);

  IF  p_calling_obj IN ('PLAN', 'SUBMITPLAN') THEN
    l_destination := 'IGS_EN_PLAN_COREQ_SUB';
  ELSIF p_calling_obj IN ('CART', 'SUBMITCART','SCHEDULE','ENROLPEND')  THEN
    l_destination :=  'IGS_EN_CART_COREQ_SUB';
  ELSIF p_calling_obj IN ('SWAP','SUBMITSWAP' ) THEN
    l_destination := 'IGS_EN_SCH_COREQ_SUB';
  END IF;

  l_message_action := igs_ss_enroll_pkg.enrf_get_lookup_meaning (
                                                                  p_lookup_code => 'ADD_COREQ',
                                                                  p_lookup_type => 'IGS_EN_WARN_LINKS');
  igs_en_drop_units_api.create_ss_warning (
         p_person_id => p_person_id,
         p_course_cd => p_course_cd,
         p_term_cal_type=> p_load_cal_type,
         p_term_ci_sequence_number => p_load_sequence_number,
         p_uoo_id => p_uoo_id,
         p_message_for => l_unit_dtls_rec.unit_cd||'/'||l_unit_dtls_rec.unit_class,
         p_message_icon=> l_message_icon,
         p_message_name => l_message,
         p_message_rule_text => l_rule_text,
         p_message_tokens => NULL,
         p_message_action=> l_message_action,
         p_destination => l_destination,
         p_parameters => l_coreq_string,
         p_step_type => 'UNIT');


 -- Incase of DROP only rule text is passed
 -- as the message is set in the drop units api depending on
 -- whether TRUE or FALSE is returned
ELSIF p_calling_obj = 'DROP' THEN
      p_message := l_rule_text;
ELSE
   IF (p_message IS NULL) THEN
     p_message := l_message;
   ELSE
     p_message := p_message || ';' || l_message;
   END IF;
 END IF;

RETURN FALSE;

END eval_coreq;

-- =================================================================================

FUNCTION eval_incompatible(
p_person_id IN NUMBER,
p_load_cal_type IN VARCHAR2,
p_load_sequence_number IN VARCHAR2,
p_uoo_id  IN NUMBER,
p_course_cd IN VARCHAR2,
p_course_version IN NUMBER,
p_message IN OUT NOCOPY VARCHAR2,
p_deny_warn  IN VARCHAR2,
p_calling_obj IN VARCHAR2
) RETURN BOOLEAN AS

------------------------------------------------------------------------------------
  --Created by  : knaraset ( Oracle IDC)
  --Date created: 21-JUN-2001
  --
  --Purpose:
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------------------------

  CURSOR cur_unit_incomp(p_uoo_id NUMBER) IS
  SELECT rul_sequence_number
  FROM igs_ps_unit_ver_ru uvr,
       igs_ps_unit_ofr_opt uoo
  WHERE uvr.unit_cd = uoo.unit_cd AND
        uvr.version_number = uoo.version_number AND
                uoo_id = p_uoo_id AND
                uvr.s_rule_call_cd = 'INCOMP';

  CURSOR cur_usec_dtl(p_uoo_id NUMBER) IS
  SELECT unit_cd,unit_class,version_number,cal_type,ci_sequence_number
  FROM igs_ps_unit_ofr_opt
  WHERE uoo_id = p_uoo_id;

  l_step_override_limit igs_en_elgb_ovr_step.step_override_limit%TYPE;
  l_rul_sequence_number igs_ps_unit_ver_ru.rul_sequence_number%TYPE;
  l_unit_dtls_rec   cur_usec_dtl%ROWTYPE;
  l_message VARCHAR2(30);
  l_message_icon VARCHAR2(1);
  l_rule_text igs_ps_unit_ver_ru_v.rule_text%TYPE;

--
-- begin of the function eval_incompatible
--
BEGIN
IF Igs_En_Gen_015.validation_step_is_overridden ('INCMPT_UNT',
                                                p_load_cal_type,
                                                p_load_sequence_number ,
                                                p_person_id ,
                                                p_uoo_id ,
                                                l_step_override_limit) THEN
    RETURN TRUE;
END IF;

-- Check whether incompatibility rule defined at Unit level
  OPEN cur_unit_incomp (p_uoo_id);
  FETCH cur_unit_incomp INTO l_rul_sequence_number;
  CLOSE cur_unit_incomp;

-- if no incompatibility rule defined at unit level,
IF l_rul_sequence_number IS NULL THEN
  RETURN TRUE;
END IF;

-- get the details of unit section
OPEN cur_usec_dtl(p_uoo_id);
FETCH  cur_usec_dtl INTO l_unit_dtls_rec;
CLOSE cur_usec_dtl;

--
-- check whether student has satisfied the incompatibility rule by invoking the rule engine

IF igs_ru_gen_001.rulp_val_senna(p_rule_call_name => 'INCOMP',
                                 p_person_id => p_person_id,
                                 p_course_cd => p_course_cd,
                                 p_course_version => p_course_version ,
                                 p_unit_cd => l_unit_dtls_rec.unit_cd,
                                 p_unit_version => l_unit_dtls_rec.version_number,
                                 p_cal_type => l_unit_dtls_rec.cal_type,
                                 p_ci_sequence_number => l_unit_dtls_rec.ci_sequence_number,
                                 p_message => l_message,
                                 p_rule_number => l_rul_sequence_number
   ) = 'true' THEN
   RETURN TRUE;
END IF;

IF p_deny_warn = 'WARN' THEN
  IF p_calling_obj = 'JOB' THEN
     l_message := 'IGS_SS_WARN_INCOMP' || '*' || l_unit_dtls_rec.unit_cd;
  ELSE
     l_message := 'IGS_EN_INCOMP_TAB_WARN';
  END IF;
ELSE
  IF p_calling_obj = 'JOB' THEN
     l_message := 'IGS_SS_DENY_INCOMP' || '*' || l_unit_dtls_rec.unit_cd;
  ELSE
     l_message := 'IGS_EN_INCOMP_TAB_DENY';
  END IF;
END IF;

IF p_calling_obj NOT IN  ('JOB','SCH_UPD') THEN

  IF(NVL(fnd_profile.value('IGS_EN_CART_RULE_DISPLAY'),'N')='Y')  THEN
    l_rule_text := igs_ru_gen_003.Rulp_Get_Rule(l_rul_sequence_number);
  END IF;
  l_message_icon := substr(p_deny_warn,1,1);
  igs_en_drop_units_api.create_ss_warning (
         p_person_id => p_person_id,
         p_course_cd => p_course_cd,
         p_term_cal_type=> p_load_cal_type,
         p_term_ci_sequence_number => p_load_sequence_number,
         p_uoo_id => p_uoo_id,
         p_message_for => l_unit_dtls_rec.unit_cd||'/'||l_unit_dtls_rec.unit_class,
         p_message_icon=> l_message_icon,
         p_message_name => l_message,
         p_message_rule_text => l_rule_text,
         p_message_tokens => NULL,
         p_message_action=> NULL,
         p_destination =>NULL,
         p_parameters => NULL,
         p_step_type => 'UNIT');

 ELSE
   IF (p_message IS NULL) THEN
     p_message := l_message;
   ELSE
     p_message := p_message || ';' || l_message;
   END IF;
 END IF;

RETURN FALSE;

END eval_incompatible;

-- =================================================================================

FUNCTION eval_spl_permission(
p_person_id IN NUMBER,
p_load_cal_type IN VARCHAR2,
p_load_sequence_number IN VARCHAR2,
p_uoo_id  IN NUMBER,
p_course_cd IN VARCHAR2,
p_course_version IN NUMBER,
p_message IN OUT NOCOPY VARCHAR2,
p_deny_warn  IN VARCHAR2
) RETURN BOOLEAN AS

------------------------------------------------------------------------------------
  --Created by  : knaraset ( Oracle IDC)
  --Date created: 21-JUN-2001
  --
  --Purpose:  this function returns TRUE for a given student and unit attempt
  --          if the student has got special permission override,special permission approval or
  --          special permission functionality is not allowed.Otherwise it returns FALSE with message
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------------------------
  CURSOR cur_chk_sp_allowed(p_uoo_id NUMBER) IS
  SELECT special_permission_ind
  FROM igs_ps_unit_ofr_opt
  WHERE uoo_id = p_uoo_id;

  CURSOR cur_sp_approve(p_person_id NUMBER,p_uoo_id NUMBER) IS
  SELECT approval_status
  FROM igs_en_spl_perm
  WHERE student_person_id = p_person_id AND
        uoo_id =p_uoo_id AND
        request_type    = 'SPL_PERM' AND
        approval_status = 'A';

  l_step_override_limit igs_en_elgb_ovr_step.step_override_limit%TYPE;
  l_sp_approve igs_en_spl_perm.approval_status%TYPE ;
  l_sp_allowed igs_ps_unit_ofr_opt.special_permission_ind%TYPE;

--
-- begin of the function eval_spl_permission
--
BEGIN
IF Igs_En_Gen_015.validation_step_is_overridden ('SPL_PERM',
                                                p_load_cal_type,
                                                p_load_sequence_number ,
                                                p_person_id ,
                                                p_uoo_id ,
                                                l_step_override_limit) THEN
    RETURN TRUE;
END IF;

-- check whether special permission functionality is allowed for the given unit section
-- i.e. special permission allowed check box is checked/unchecked..
OPEN cur_chk_sp_allowed(p_uoo_id);
FETCH cur_chk_sp_allowed INTO l_sp_allowed;
CLOSE cur_chk_sp_allowed;
IF l_sp_allowed = 'N' THEN
  RETURN TRUE;
END IF;

--
-- check whether student got special permission approved
OPEN cur_sp_approve(p_person_id,p_uoo_id);
FETCH cur_sp_approve INTO l_sp_approve;
CLOSE cur_sp_approve;

IF l_sp_approve = 'A' THEN
  RETURN TRUE;
END IF;

IF p_deny_warn = 'WARN' THEN
  IF p_message IS NULL THEN
      p_message := 'IGS_SS_WARN_SPL_PERMIT';
  ELSE
      p_message := p_message ||';'||'IGS_SS_WARN_SPL_PERMIT';
  END IF;
ELSE
  IF p_message IS NULL THEN
     p_message := 'IGS_SS_DENY_SPL_PERMIT';
  ELSE
     p_message := p_message ||';'||'IGS_SS_DENY_SPL_PERMIT';
  END IF;
END IF;

RETURN FALSE;

END eval_spl_permission;

-- ================================================================================

FUNCTION eval_rsv_seat(
p_person_id IN NUMBER,
p_load_cal_type IN VARCHAR2,
p_load_sequence_number IN VARCHAR2,
p_uoo_id  IN NUMBER,
p_course_cd IN VARCHAR2,
p_course_version IN NUMBER,
p_message IN OUT NOCOPY VARCHAR2,
p_deny_warn  IN VARCHAR2,
p_calling_obj IN VARCHAR2,
p_deny_enrollment OUT NOCOPY VARCHAR2
) RETURN BOOLEAN AS

------------------------------------------------------------------------------------
  --Created by  : knaraset ( Oracle IDC)
  --Date created: 21-JUN-2001
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --smadathi    30-JUL-2001     Changes Made as per enhancement Bug No.1869767
  -- svenkata   19-Feb-2003     Merged 2 cursors that were based on the same table.Bug 2749605
  -- stutta     27-Jul-2004     Added a missing join condition sus.person_id = spa.person_id
  --                            in cursor cur_unit_set. Bug #3452321
  -- stutta     23-Aug-2004     Added validation for Class standing(CLASS_STD) priority
  --                            at all three levels. Bug#3803790
  -------------------------------------------------------------------------------------

-- cursor to select the Unit section details
  CURSOR cur_usec_dtl(p_uoo_id NUMBER) IS
  SELECT unit_cd,unit_class,version_number,cal_type,ci_sequence_number,owner_org_unit_cd , reserved_seating_allowed
  FROM igs_ps_unit_ofr_opt
  WHERE uoo_id = p_uoo_id;

-- cursor to fetch priorities defined at unit section level
CURSOR cur_rsv_uoo_pri(p_uoo_id NUMBER) IS
SELECT priority_value, rsv_usec_pri_id priority_id
FROM igs_ps_rsv_usec_pri
WHERE uoo_id = p_uoo_id
ORDER BY priority_order;

-- cursor to fetch preferences defined at unit section level
CURSOR cur_rsv_uoo_prf(p_rsv_usec_pri_id NUMBER) IS
SELECT preference_code,preference_version,group_id,percentage_reserved, rsv_usec_prf_id preference_id
FROM igs_ps_rsv_usec_prf
WHERE rsv_usec_pri_id = p_rsv_usec_pri_id
ORDER BY preference_order;

-- cursor to fetch priorities defined at unit offering pattern level
CURSOR cur_rsv_uop_pri(p_unit_cd VARCHAR2 ,p_version_number NUMBER ,p_cal_type VARCHAR2 ,p_ci_sequence_number NUMBER) IS
SELECT priority_value, rsv_uop_pri_id priority_id
FROM igs_ps_rsv_uop_pri
WHERE unit_cd = p_unit_cd AND
      version_number = p_version_number AND
          calender_type  = p_cal_type AND
          ci_sequence_number = p_ci_sequence_number
ORDER BY priority_order;

-- cursor to fetch preferences defined at unit offering pattern level
CURSOR cur_rsv_uop_prf(p_rsv_uop_pri_id NUMBER) IS
SELECT preference_code,preference_version,group_id,percentage_reserved, rsv_uop_prf_id preference_id
FROM igs_ps_rsv_uop_prf
WHERE rsv_uop_pri_id = p_rsv_uop_pri_id
ORDER BY preference_order;

-- cursor to fetch priorities defined at owner Organizational Unit level
CURSOR cur_rsv_org_pri(p_org_unit_cd varchar2) IS
SELECT priority_value, rsv_org_unit_pri_id priority_id
FROM igs_ps_rsv_ogpri
WHERE org_unit_cd = p_org_unit_cd
ORDER BY priority_order;

-- cursor to fetch preferences defined at owner Organizational Unit level
CURSOR cur_rsv_org_prf(p_rsv_org_unit_pri_id NUMBER) IS
SELECT preference_code,preference_version,group_id,percentage_reserved, rsv_org_unit_prf_id preference_id
FROM igs_ps_rsv_orgun_prf
WHERE rsv_org_unit_pri_id = p_rsv_org_unit_pri_id
ORDER BY preference_order;

CURSOR cur_program(p_person_id NUMBER , p_course_cd VARCHAR2 ,p_version_number NUMBER) IS
SELECT 'X'
FROM igs_en_stdnt_ps_att
WHERE person_id = p_person_id AND
      course_cd = p_course_cd AND
          version_number = p_version_number;

CURSOR cur_org(p_person_id NUMBER , p_org_unit_cd VARCHAR2) IS
SELECT 'X'
FROM igs_en_stdnt_ps_att sca,
       igs_ps_ver pv
WHERE sca.person_id = p_person_id AND
        sca.course_cd = pv.course_cd AND
            sca.version_number = pv.version_number AND
            pv.responsible_org_unit_cd = p_org_unit_cd;

CURSOR cur_unit_set(p_person_id NUMBER , p_unit_set_cd VARCHAR2 ,p_us_version_number NUMBER) IS
SELECT 'X'
FROM igs_en_stdnt_ps_att spa,
     igs_as_su_setatmpt sus
WHERE spa.person_id = p_person_id AND
      sus.person_id = spa.person_id AND
      spa.course_cd = sus.course_cd AND
          sus.unit_set_cd = p_unit_set_cd AND
          sus.us_version_number = p_us_version_number;

CURSOR cur_person_grp(p_person_id NUMBER , p_group_id VARCHAR2) IS
SELECT 'X'
FROM igs_pe_prsid_grp_mem pgm
WHERE pgm.person_id = p_person_id AND
      pgm.group_id = p_group_id ;


  l_unit_cd igs_ps_unit_ofr_opt.unit_cd%TYPE;
  l_unit_class  igs_ps_unit_ofr_opt.unit_class%TYPE;
  l_version_number igs_ps_unit_ofr_opt.version_number%TYPE;
  l_cal_type igs_ps_unit_ofr_opt.cal_type%TYPE;
  l_ci_sequence_number igs_ps_unit_ofr_opt.ci_sequence_number%TYPE;
  l_owner_org_unit_cd  igs_ps_unit_ofr_opt.owner_org_unit_cd%TYPE;

  l_step_override_limit igs_en_elgb_ovr_step.step_override_limit%TYPE;
  l_rsv_allowed igs_ps_unit_ofr_opt.reserved_seating_allowed%TYPE;
  l_pri_satisfied VARCHAR2(1);
  l_unreserved_seats NUMBER;

-- flag variable which stores in which level reserved seat setup found in the hierarchy
   l_rsv_level igs_ps_rsv_ext.rsv_level%TYPE;

   l_message               VARCHAR2(30);
   l_message_icon        VARCHAR2(1);
-- variable which stores the total reserved percentage found in the hierarchy
   l_total_percentage NUMBER;

-- ================================================================================
-- function which validate whether the syudent can enroll under the
-- given priority/preference which student satisfied.
--
FUNCTION enrf_val_reserve_seat(p_priority_id IN VARCHAR2,
                               p_preference_id IN VARCHAR2,
                               p_percentage_reserved IN NUMBER,
                               p_rsv_level IN VARCHAR2)
RETURN BOOLEAN AS
/*----------------------------------------------------------------------------------+
 | HISTORY                                                                          |
 | Who         When           What                                                  |
 |ptandon     1-Sep-2003     Added two new parameters WLST_PRIORITY_WEIGHT_NUM      |
 |                           and WLST_PREFERENCE_WEIGHT_NUM in calls to             |
 |                           igs_en_sua_api.update_unit_attempt as part of Waitlist |
 |                           Enhancements Build - Bug# 3052426
 |rvangala    07-OCT-2003    Value for CORE_INDICATOR_CODE passed to IGS_EN_SUA_API.UPDATE_UNIT_ATTEMPT
 |                          added as part of Prevent Dropping Core Units. Enh Bug# 3052432
 +---------------------------------------------------------------------------------*/

-- cursor to get the enrollment maximum defined at unit section level
CURSOR cur_usec_enr_max IS
SELECT enrollment_maximum
FROM igs_ps_usec_lim_wlst
WHERE uoo_id = p_uoo_id;

-- cursor to get the enrollment maximum defined at unit level
CURSOR cur_unit_enr_max IS
SELECT enrollment_maximum
FROM igs_ps_unit_ver uv,
     igs_ps_unit_ofr_opt uoo
WHERE uoo.uoo_id = p_uoo_id AND -- p_uoo_id is parameter of container function
      uv.unit_cd = uoo.unit_cd AND
          uv.version_number = uoo.version_number;
--
-- cursor to check/get the details of reserve seats utilization against given priority/preference
-- defined at given level.
CURSOR cur_rsv_ext(p_priority_id VARCHAR2, p_preference_id VARCHAR2,
                                   p_rsv_level VARCHAR2)IS
SELECT rsve.ROWID, rsve.*
FROM igs_ps_rsv_ext rsve
WHERE rsve.priority_id = p_priority_id AND
      rsve.preference_id = p_preference_id AND
          rsve.rsv_level = p_rsv_level AND
          rsve.uoo_id = p_uoo_id
          FOR UPDATE ; -- p_uoo_id is parameter of container function

cur_rsv_ext_rec cur_rsv_ext%ROWTYPE;

l_enrollment_max igs_ps_usec_lim_wlst.enrollment_maximum%TYPE;
l_resereved_max NUMBER;
l_rowid VARCHAR2(25);
l_rsv_ext_id NUMBER;
l_rsv_temp_id NUMBER;

CURSOR  c_igs_en_su_attempt (cp_person_id igs_pe_person.person_id%TYPE,
                             cp_uoo_id    igs_ps_unit_ofr_opt.uoo_id%TYPE,
                             cp_course_cd igs_en_su_attempt.course_cd%TYPE
                             ) IS
SELECT   *
FROM     igs_en_su_attempt
WHERE    person_id = cp_person_id
AND      uoo_id    = cp_uoo_id
AND      course_cd = cp_course_cd ;

l_c_igs_en_su_attempt  c_igs_en_su_attempt%ROWTYPE ;


BEGIN
-- fetching the enrollment maximum defined at unit section level
OPEN cur_usec_enr_max;
FETCH cur_usec_enr_max INTO l_enrollment_max;
CLOSE cur_usec_enr_max;

-- if enroolment maximum is not defined at unit section level, check at unit level
IF l_enrollment_max IS NULL THEN
   OPEN cur_unit_enr_max;
   FETCH cur_unit_enr_max INTO l_enrollment_max;
   CLOSE cur_unit_enr_max;
END IF;

--
-- if enrollment maximum is not defined at either levels
IF l_enrollment_max IS NULL THEN
   OPEN cur_rsv_ext(p_priority_id,
                            p_preference_id,
                                    p_rsv_level);
   FETCH cur_rsv_ext INTO cur_rsv_ext_rec;
-- record already exist against given priority/preference
   IF cur_rsv_ext%FOUND THEN
     l_rsv_ext_id := cur_rsv_ext_rec.rsv_ext_id;
     igs_ps_rsv_ext_pkg.update_row(x_rowid => cur_rsv_ext_rec.ROWID,
                                       x_rsv_ext_id => cur_rsv_ext_rec.rsv_ext_id,
                                       x_uoo_id => cur_rsv_ext_rec.uoo_id,
                                                                   x_priority_id => cur_rsv_ext_rec.priority_id,
                                                                   x_preference_id => cur_rsv_ext_rec.preference_id ,
                                                                   x_rsv_level => cur_rsv_ext_rec.rsv_level ,
                                                                   x_actual_seat_enrolled => cur_rsv_ext_rec.actual_seat_enrolled + 1,
                                                                   x_mode => 'R' );
   ELSE -- record is not exist against given priority/preference, so inserting a new record
     igs_ps_rsv_ext_pkg.insert_row(x_rowid => l_rowid,
                                       x_rsv_ext_id => l_rsv_ext_id,
                                       x_uoo_id => p_uoo_id,
                                                                   x_priority_id => p_priority_id,
                                                                   x_preference_id => p_preference_id ,
                                                                   x_rsv_level => p_rsv_level ,
                                                                   x_actual_seat_enrolled => 1,
                                                                   x_mode => 'R');
   END IF; -- cur_rsv_ext
   CLOSE cur_rsv_ext;

   FOR l_c_igs_en_su_attempt IN c_igs_en_su_attempt (cp_person_id  => p_person_id,
                                                     cp_uoo_id     => p_uoo_id,
                                                     cp_course_cd  => p_course_cd)
    LOOP
      IGS_EN_SU_ATTEMPT_PKG.UPDATE_ROW (
                                        X_ROWID                        =>     l_c_igs_en_su_attempt.row_id                         ,
                                        X_PERSON_ID                    =>     l_c_igs_en_su_attempt.person_id                      ,
                                        X_COURSE_CD                    =>     l_c_igs_en_su_attempt.course_cd                      ,
                                        X_UNIT_CD                      =>     l_c_igs_en_su_attempt.unit_cd                        ,
                                        X_CAL_TYPE                     =>     l_c_igs_en_su_attempt.cal_type                       ,
                                        X_CI_SEQUENCE_NUMBER           =>     l_c_igs_en_su_attempt.ci_sequence_number             ,
                                        X_VERSION_NUMBER               =>     l_c_igs_en_su_attempt.version_number                 ,
                                        X_LOCATION_CD                  =>     l_c_igs_en_su_attempt.location_cd                    ,
                                        X_UNIT_CLASS                   =>     l_c_igs_en_su_attempt.unit_class                     ,
                                        X_CI_START_DT                  =>     l_c_igs_en_su_attempt.ci_start_dt                    ,
                                        X_CI_END_DT                    =>     l_c_igs_en_su_attempt.ci_end_dt                      ,
                                        X_UOO_ID                       =>     l_c_igs_en_su_attempt.uoo_id                         ,
                                        X_ENROLLED_DT                  =>     l_c_igs_en_su_attempt.enrolled_dt                    ,
                                        X_UNIT_ATTEMPT_STATUS          =>     l_c_igs_en_su_attempt.unit_attempt_status            ,
                                        X_ADMINISTRATIVE_UNIT_STATUS   =>     l_c_igs_en_su_attempt.administrative_unit_status     ,
                                        X_DISCONTINUED_DT              =>     l_c_igs_en_su_attempt.discontinued_dt                ,
                                        X_RULE_WAIVED_DT               =>     l_c_igs_en_su_attempt.rule_waived_dt                 ,
                                        X_RULE_WAIVED_PERSON_ID        =>     l_c_igs_en_su_attempt.rule_waived_person_id          ,
                                        X_NO_ASSESSMENT_IND            =>     l_c_igs_en_su_attempt.no_assessment_ind              ,
                                        X_SUP_UNIT_CD                  =>     l_c_igs_en_su_attempt.sup_unit_cd                    ,
                                        X_SUP_VERSION_NUMBER           =>     l_c_igs_en_su_attempt.sup_version_number             ,
                                        X_EXAM_LOCATION_CD             =>     l_c_igs_en_su_attempt.exam_location_cd               ,
                                        X_ALTERNATIVE_TITLE            =>     l_c_igs_en_su_attempt.alternative_title              ,
                                        X_OVERRIDE_ENROLLED_CP         =>     l_c_igs_en_su_attempt.override_enrolled_cp           ,
                                        X_OVERRIDE_EFTSU               =>     l_c_igs_en_su_attempt.override_eftsu                 ,
                                        X_OVERRIDE_ACHIEVABLE_CP       =>     l_c_igs_en_su_attempt.override_achievable_cp         ,
                                        X_OVERRIDE_OUTCOME_DUE_DT      =>     l_c_igs_en_su_attempt.override_outcome_due_dt        ,
                                        X_OVERRIDE_CREDIT_REASON       =>     l_c_igs_en_su_attempt.override_credit_reason         ,
                                        X_ADMINISTRATIVE_PRIORITY      =>     l_c_igs_en_su_attempt.administrative_priority        ,
                                        X_WAITLIST_DT                  =>     l_c_igs_en_su_attempt.waitlist_dt                    ,
                                        X_DCNT_REASON_CD               =>     l_c_igs_en_su_attempt.dcnt_reason_cd                 ,
                                        X_MODE                         =>     'R'                                                  ,
                                        X_GS_VERSION_NUMBER            =>     l_c_igs_en_su_attempt.gs_version_number              ,
                                        X_ENR_METHOD_TYPE              =>     l_c_igs_en_su_attempt.enr_method_type                ,
                                        X_FAILED_UNIT_RULE             =>     l_c_igs_en_su_attempt.failed_unit_rule               ,
                                        X_CART                         =>     l_c_igs_en_su_attempt.cart                           ,
                                        X_RSV_SEAT_EXT_ID              =>     l_rsv_ext_id                                         ,
                                        X_ORG_UNIT_CD                  =>     l_c_igs_en_su_attempt.org_unit_cd                    ,
                                        -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
                                        X_SESSION_ID                   =>     l_c_igs_en_su_attempt.session_id,
                                        -- Added the column grading schema as a part of the bug 2037897. - aiyer
                                        X_GRADING_SCHEMA_CODE          =>     l_c_igs_en_su_attempt.grading_schema_code            ,
                                        X_DEG_AUD_DETAIL_ID            =>     l_c_igs_en_su_attempt.deg_aud_detail_id,
                                        X_SUBTITLE                     =>     l_c_igs_en_su_attempt.subtitle,
                                        X_STUDENT_CAREER_TRANSCRIPT    =>     l_c_igs_en_su_attempt.student_career_transcript       ,
                                        X_STUDENT_CAREER_STATISTICS    =>     l_c_igs_en_su_attempt.student_career_statistics,
                                        X_ATTRIBUTE_CATEGORY           =>     l_c_igs_en_su_attempt.attribute_category,
                                        X_ATTRIBUTE1                   =>     l_c_igs_en_su_attempt.attribute1,
                                        X_ATTRIBUTE2                   =>     l_c_igs_en_su_attempt.attribute2,
                                        X_ATTRIBUTE3                   =>     l_c_igs_en_su_attempt.attribute3,
                                        X_ATTRIBUTE4                   =>     l_c_igs_en_su_attempt.attribute4,
                                        X_ATTRIBUTE5                   =>     l_c_igs_en_su_attempt.attribute5,
                                        X_ATTRIBUTE6                   =>     l_c_igs_en_su_attempt.attribute6,
                                        X_ATTRIBUTE7                   =>     l_c_igs_en_su_attempt.attribute7,
                                        X_ATTRIBUTE8                   =>     l_c_igs_en_su_attempt.attribute8,
                                        X_ATTRIBUTE9                   =>     l_c_igs_en_su_attempt.attribute9,
                                        X_ATTRIBUTE10                  =>     l_c_igs_en_su_attempt.attribute10,
                                        X_ATTRIBUTE11                  =>     l_c_igs_en_su_attempt.attribute11,
                                        X_ATTRIBUTE12                  =>     l_c_igs_en_su_attempt.attribute12,
                                        X_ATTRIBUTE13                  =>     l_c_igs_en_su_attempt.attribute13,
                                        X_ATTRIBUTE14                  =>     l_c_igs_en_su_attempt.attribute14,
                                        X_ATTRIBUTE15                  =>     l_c_igs_en_su_attempt.attribute15,
                                        X_ATTRIBUTE16                  =>     l_c_igs_en_su_attempt.attribute16,
                                        X_ATTRIBUTE17                  =>     l_c_igs_en_su_attempt.attribute17,
                                        X_ATTRIBUTE18                  =>     l_c_igs_en_su_attempt.attribute18,
                                        X_ATTRIBUTE19                  =>     l_c_igs_en_su_attempt.attribute19,
                                        X_ATTRIBUTE20                  =>     l_c_igs_en_su_attempt.attribute20,
                                        X_WAITLIST_MANUAL_IND          =>     l_c_igs_en_su_attempt.waitlist_manual_ind, --Added by mesriniv for Bug 2554109.
                                        X_WLST_PRIORITY_WEIGHT_NUM     =>     l_c_igs_en_su_attempt.wlst_priority_weight_num,
                                        X_WLST_PREFERENCE_WEIGHT_NUM   =>     l_c_igs_en_su_attempt.wlst_preference_weight_num,
                                        -- CORE_INDICATOR_CODE added by rvangala 07-OCT-2003. Enh Bug# 3052432
                                        X_CORE_INDICATOR_CODE          =>     l_c_igs_en_su_attempt.core_indicator_code

                                   ) ;
    END LOOP;
-- return TRUE as the given student satisfied some priority/preference and
-- student is eligible to enroll under reserved category
   RETURN TRUE;
ELSE -- l_enrollment_max is not null
  l_resereved_max := FLOOR((l_enrollment_max * p_percentage_reserved ) / 100);
--
-- get the actual seats enrolled under the give priority/ preference.
--
   OPEN cur_rsv_ext(p_priority_id,
                    p_preference_id,
                    p_rsv_level);
   FETCH cur_rsv_ext INTO cur_rsv_ext_rec;
-- record already exist against given priority/preference
   IF cur_rsv_ext%FOUND THEN
     IF NVL(cur_rsv_ext_rec.actual_seat_enrolled,0) + 1 > l_resereved_max THEN
           --
           -- no seat available under the given priority/ preference
        CLOSE cur_rsv_ext;
        RETURN FALSE;
     END IF;
     l_rsv_ext_id := cur_rsv_ext_rec.rsv_ext_id;
     igs_ps_rsv_ext_pkg.update_row(x_rowid => cur_rsv_ext_rec.ROWID,
                                       x_rsv_ext_id => cur_rsv_ext_rec.rsv_ext_id,
                                       x_uoo_id => cur_rsv_ext_rec.uoo_id,
                                       x_priority_id => cur_rsv_ext_rec.priority_id,
                                       x_preference_id => cur_rsv_ext_rec.preference_id ,
                                       x_rsv_level => cur_rsv_ext_rec.rsv_level ,
                                       x_actual_seat_enrolled => cur_rsv_ext_rec.actual_seat_enrolled + 1,
                                       x_mode => 'R' );
   ELSE -- record is not exist against given priority/preference, so inserting a new record
     IF 1 > l_resereved_max THEN
           --
           -- no seat available under the given priority/ preference
        CLOSE cur_rsv_ext;
        RETURN FALSE;
     END IF;
     igs_ps_rsv_ext_pkg.insert_row(x_rowid => l_rowid,
                                   x_rsv_ext_id => l_rsv_ext_id,
                                   x_uoo_id => p_uoo_id,
                                   x_priority_id => p_priority_id,
                                   x_preference_id => p_preference_id ,
                                   x_rsv_level => p_rsv_level ,
                                   x_actual_seat_enrolled => 1,
                                   x_mode => 'R');
   END IF; -- cur_rsv_ext
   IF  cur_rsv_ext%ISOPEN THEN
     CLOSE cur_rsv_ext;
   END IF;

   FOR l_c_igs_en_su_attempt IN c_igs_en_su_attempt (cp_person_id  => p_person_id,
                                                     cp_uoo_id     => p_uoo_id,
                                                     cp_course_cd  => p_course_cd)
    LOOP
      IGS_EN_SU_ATTEMPT_PKG.UPDATE_ROW (
                                        X_ROWID                        =>     l_c_igs_en_su_attempt.row_id                         ,
                                        X_PERSON_ID                    =>     l_c_igs_en_su_attempt.person_id                      ,
                                        X_COURSE_CD                    =>     l_c_igs_en_su_attempt.course_cd                      ,
                                        X_UNIT_CD                      =>     l_c_igs_en_su_attempt.unit_cd                        ,
                                        X_CAL_TYPE                     =>     l_c_igs_en_su_attempt.cal_type                       ,
                                        X_CI_SEQUENCE_NUMBER           =>     l_c_igs_en_su_attempt.ci_sequence_number             ,
                                        X_VERSION_NUMBER               =>     l_c_igs_en_su_attempt.version_number                 ,
                                        X_LOCATION_CD                  =>     l_c_igs_en_su_attempt.location_cd                    ,
                                        X_UNIT_CLASS                   =>     l_c_igs_en_su_attempt.unit_class                     ,
                                        X_CI_START_DT                  =>     l_c_igs_en_su_attempt.ci_start_dt                    ,
                                        X_CI_END_DT                    =>     l_c_igs_en_su_attempt.ci_end_dt                      ,
                                        X_UOO_ID                       =>     l_c_igs_en_su_attempt.uoo_id                         ,
                                        X_ENROLLED_DT                  =>     l_c_igs_en_su_attempt.enrolled_dt                    ,
                                        X_UNIT_ATTEMPT_STATUS          =>     l_c_igs_en_su_attempt.unit_attempt_status            ,
                                        X_ADMINISTRATIVE_UNIT_STATUS   =>     l_c_igs_en_su_attempt.administrative_unit_status     ,
                                        X_DISCONTINUED_DT              =>     l_c_igs_en_su_attempt.discontinued_dt                ,
                                        X_RULE_WAIVED_DT               =>     l_c_igs_en_su_attempt.rule_waived_dt                 ,
                                        X_RULE_WAIVED_PERSON_ID        =>     l_c_igs_en_su_attempt.rule_waived_person_id          ,
                                        X_NO_ASSESSMENT_IND            =>     l_c_igs_en_su_attempt.no_assessment_ind              ,
                                        X_SUP_UNIT_CD                  =>     l_c_igs_en_su_attempt.sup_unit_cd                    ,
                                        X_SUP_VERSION_NUMBER           =>     l_c_igs_en_su_attempt.sup_version_number             ,
                                        X_EXAM_LOCATION_CD             =>     l_c_igs_en_su_attempt.exam_location_cd               ,
                                        X_ALTERNATIVE_TITLE            =>     l_c_igs_en_su_attempt.alternative_title              ,
                                        X_OVERRIDE_ENROLLED_CP         =>     l_c_igs_en_su_attempt.override_enrolled_cp           ,
                                        X_OVERRIDE_EFTSU               =>     l_c_igs_en_su_attempt.override_eftsu                 ,
                                        X_OVERRIDE_ACHIEVABLE_CP       =>     l_c_igs_en_su_attempt.override_achievable_cp         ,
                                        X_OVERRIDE_OUTCOME_DUE_DT      =>     l_c_igs_en_su_attempt.override_outcome_due_dt        ,
                                        X_OVERRIDE_CREDIT_REASON       =>     l_c_igs_en_su_attempt.override_credit_reason         ,
                                        X_ADMINISTRATIVE_PRIORITY      =>     l_c_igs_en_su_attempt.administrative_priority        ,
                                        X_WAITLIST_DT                  =>     l_c_igs_en_su_attempt.waitlist_dt                    ,
                                        X_DCNT_REASON_CD               =>     l_c_igs_en_su_attempt.dcnt_reason_cd                 ,
                                        X_MODE                         =>     'R'                                                  ,
                                        X_GS_VERSION_NUMBER            =>     l_c_igs_en_su_attempt.gs_version_number              ,
                                        X_ENR_METHOD_TYPE              =>     l_c_igs_en_su_attempt.enr_method_type                ,
                                        X_FAILED_UNIT_RULE             =>     l_c_igs_en_su_attempt.failed_unit_rule               ,
                                        X_CART                         =>     l_c_igs_en_su_attempt.cart                           ,
                                        X_RSV_SEAT_EXT_ID              =>     l_rsv_ext_id ,
                                        X_ORG_UNIT_CD                  =>     l_c_igs_en_su_attempt.org_unit_cd                    ,
                                        -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
                                        X_SESSION_ID                   =>     l_c_igs_en_su_attempt.session_id,
                                        -- Added the column grading schema as a part of the bug 2037897. - aiyer
                                        X_GRADING_SCHEMA_CODE          =>     l_c_igs_en_su_attempt.grading_schema_code            ,
                                        X_DEG_AUD_DETAIL_ID            =>     l_c_igs_en_su_attempt.deg_aud_detail_id              ,
                                        X_SUBTITLE                     =>     l_c_igs_en_su_attempt.subtitle   ,
                                        X_STUDENT_CAREER_TRANSCRIPT    =>     l_c_igs_en_su_attempt.student_career_transcript       ,
                                        X_STUDENT_CAREER_STATISTICS    =>     l_c_igs_en_su_attempt.student_career_statistics,
                                        X_ATTRIBUTE_CATEGORY           =>     l_c_igs_en_su_attempt.attribute_category,
                                        X_ATTRIBUTE1                   =>     l_c_igs_en_su_attempt.attribute1,
                                        X_ATTRIBUTE2                   =>     l_c_igs_en_su_attempt.attribute2,
                                        X_ATTRIBUTE3                   =>     l_c_igs_en_su_attempt.attribute3,
                                        X_ATTRIBUTE4                   =>     l_c_igs_en_su_attempt.attribute4,
                                        X_ATTRIBUTE5                   =>     l_c_igs_en_su_attempt.attribute5,
                                        X_ATTRIBUTE6                   =>     l_c_igs_en_su_attempt.attribute6,
                                        X_ATTRIBUTE7                   =>     l_c_igs_en_su_attempt.attribute7,
                                        X_ATTRIBUTE8                   =>     l_c_igs_en_su_attempt.attribute8,
                                        X_ATTRIBUTE9                   =>     l_c_igs_en_su_attempt.attribute9,
                                        X_ATTRIBUTE10                  =>     l_c_igs_en_su_attempt.attribute10,
                                        X_ATTRIBUTE11                  =>     l_c_igs_en_su_attempt.attribute11,
                                        X_ATTRIBUTE12                  =>     l_c_igs_en_su_attempt.attribute12,
                                        X_ATTRIBUTE13                  =>     l_c_igs_en_su_attempt.attribute13,
                                        X_ATTRIBUTE14                  =>     l_c_igs_en_su_attempt.attribute14,
                                        X_ATTRIBUTE15                  =>     l_c_igs_en_su_attempt.attribute15,
                                        X_ATTRIBUTE16                  =>     l_c_igs_en_su_attempt.attribute16,
                                        X_ATTRIBUTE17                  =>     l_c_igs_en_su_attempt.attribute17,
                                        X_ATTRIBUTE18                  =>     l_c_igs_en_su_attempt.attribute18,
                                        X_ATTRIBUTE19                  =>     l_c_igs_en_su_attempt.attribute19,
                                        X_ATTRIBUTE20                  =>     l_c_igs_en_su_attempt.attribute20,
                                        X_WAITLIST_MANUAL_IND          =>     l_c_igs_en_su_attempt.waitlist_manual_ind, --Added by mesriniv for Bug 2554109.
                                        X_WLST_PRIORITY_WEIGHT_NUM     =>     l_c_igs_en_su_attempt.wlst_priority_weight_num,
                                        X_WLST_PREFERENCE_WEIGHT_NUM   =>     l_c_igs_en_su_attempt.wlst_preference_weight_num,
                                        -- CORE_INDICATOR_CODE added by rvangala 07-OCT-2003. Enh Bug# 3052432
                                        X_CORE_INDICATOR_CODE          =>     l_c_igs_en_su_attempt.core_indicator_code
                                   ) ;
    END LOOP ;

-- return TRUE as the given student satisfied some priority/preference and
-- student is eligible to enroll under reserved category
   RETURN TRUE;

END IF; -- l_enrollment_max
   RETURN FALSE;
END enrf_val_reserve_seat;

--
-- begin of the function eval_rsv_seat
--

BEGIN
IF Igs_En_Gen_015.validation_step_is_overridden ('RSV_SEAT',
                                                p_load_cal_type,
                                                p_load_sequence_number ,
                                                p_person_id ,
                                                p_uoo_id ,
                                                l_step_override_limit) THEN
    RETURN TRUE;
END IF;

-- get the details of unit section and check whether reserved seat functionality is allowed for the given unit section
OPEN cur_usec_dtl(p_uoo_id);
FETCH  cur_usec_dtl INTO l_unit_cd,l_unit_class,l_version_number,l_cal_type,l_ci_sequence_number,l_owner_org_unit_cd,l_rsv_allowed;
CLOSE cur_usec_dtl;

IF l_rsv_allowed = 'N' THEN
  RETURN TRUE;
END IF;

--
-- check whether the student satisfies any Priority and Preference, if yes then return true.
--
-- check the priority/preferences at Unit section level
--
FOR cur_rsv_uoo_pri_rec IN cur_rsv_uoo_pri(p_uoo_id) LOOP
  l_rsv_level := 'UNIT_SEC';
  IF cur_rsv_uoo_pri_rec.priority_value = 'PROGRAM' THEN
    FOR cur_rsv_uoo_prf_rec IN cur_rsv_uoo_prf(cur_rsv_uoo_pri_rec.priority_id) LOOP
          OPEN cur_program(p_person_id,cur_rsv_uoo_prf_rec.preference_code ,cur_rsv_uoo_prf_rec.preference_version );
          FETCH cur_program INTO l_pri_satisfied;
          IF cur_program%FOUND THEN
            IF enrf_val_reserve_seat(cur_rsv_uoo_pri_rec.priority_id,
                                     cur_rsv_uoo_prf_rec.preference_id,
                                     cur_rsv_uoo_prf_rec.percentage_reserved,
                                     l_rsv_level) THEN
               CLOSE cur_program;
               RETURN TRUE;
             END IF;
          END IF;
          IF cur_program%ISOPEN THEN
            CLOSE cur_program;
          END IF;
        l_total_percentage := NVL(l_total_percentage,0) + NVL(cur_rsv_uoo_prf_rec.percentage_reserved,0);
        END LOOP; -- cur_rsv_uoo_prf_rec

  ELSIF cur_rsv_uoo_pri_rec.priority_value = 'ORG_UNIT' THEN
    FOR cur_rsv_uoo_prf_rec IN cur_rsv_uoo_prf(cur_rsv_uoo_pri_rec.priority_id) LOOP
          OPEN cur_org(p_person_id,cur_rsv_uoo_prf_rec.preference_code);
          FETCH cur_org INTO l_pri_satisfied;
          IF cur_org%FOUND THEN
            IF enrf_val_reserve_seat(cur_rsv_uoo_pri_rec.priority_id,
                                     cur_rsv_uoo_prf_rec.preference_id,
                                     cur_rsv_uoo_prf_rec.percentage_reserved,
                                     l_rsv_level) THEN
              CLOSE cur_org;
              RETURN TRUE;
            END IF;
          END IF;
          IF cur_org%ISOPEN THEN
             CLOSE cur_org;
          END IF;
     l_total_percentage := NVL(l_total_percentage,0) + NVL(cur_rsv_uoo_prf_rec.percentage_reserved,0);
     END LOOP; -- cur_rsv_uoo_prf_rec

  ELSIF cur_rsv_uoo_pri_rec.priority_value = 'UNIT_SET' THEN
    FOR cur_rsv_uoo_prf_rec IN cur_rsv_uoo_prf(cur_rsv_uoo_pri_rec.priority_id) LOOP
          OPEN cur_unit_set(p_person_id,cur_rsv_uoo_prf_rec.preference_code ,cur_rsv_uoo_prf_rec.preference_version );
          FETCH cur_unit_set INTO l_pri_satisfied;
          IF cur_unit_set%FOUND THEN
            IF enrf_val_reserve_seat(cur_rsv_uoo_pri_rec.priority_id,
                                         cur_rsv_uoo_prf_rec.preference_id,
                                                                 cur_rsv_uoo_prf_rec.percentage_reserved,
                                                         l_rsv_level) THEN
              CLOSE cur_unit_set;
              RETURN TRUE;
            END IF;
          END IF;
          IF cur_unit_set%ISOPEN THEN
            CLOSE cur_unit_set;
          END IF;
        l_total_percentage := NVL(l_total_percentage,0) + NVL(cur_rsv_uoo_prf_rec.percentage_reserved,0);
        END LOOP; -- cur_rsv_uoo_prf_rec

  ELSIF cur_rsv_uoo_pri_rec.priority_value = 'PROGRAM_STAGE' THEN
    FOR cur_rsv_uoo_prf_rec IN cur_rsv_uoo_prf(cur_rsv_uoo_pri_rec.priority_id) LOOP
      --
          -- Call the function to determine whether given student completed the given program stage
          --
          IF igs_en_gen_015.enrp_val_Ps_Stage(p_person_id,
                                              p_course_cd,
                                              p_course_version,
                                              cur_rsv_uoo_prf_rec.preference_code) THEN

            IF enrf_val_reserve_seat(cur_rsv_uoo_pri_rec.priority_id,
                                     cur_rsv_uoo_prf_rec.preference_id,
                                     cur_rsv_uoo_prf_rec.percentage_reserved,
                                     l_rsv_level) THEN
               RETURN TRUE;
            END IF;
          END IF;
     l_total_percentage := NVL(l_total_percentage,0) + NVL(cur_rsv_uoo_prf_rec.percentage_reserved,0);
     END LOOP; -- cur_rsv_uoo_prf_rec

  ELSIF cur_rsv_uoo_pri_rec.priority_value = 'PERSON_GRP' THEN
    FOR cur_rsv_uoo_prf_rec IN cur_rsv_uoo_prf(cur_rsv_uoo_pri_rec.priority_id) LOOP
          OPEN cur_person_grp(p_person_id,cur_rsv_uoo_prf_rec.group_id);
          FETCH cur_person_grp INTO l_pri_satisfied;
          IF cur_person_grp%FOUND THEN
            IF enrf_val_reserve_seat(cur_rsv_uoo_pri_rec.priority_id,
                                     cur_rsv_uoo_prf_rec.preference_id,
                                     cur_rsv_uoo_prf_rec.percentage_reserved,
                                     l_rsv_level) THEN
              CLOSE cur_person_grp;
              RETURN TRUE;
            END IF;
          END IF;
          IF cur_person_grp%ISOPEN THEN
            CLOSE cur_person_grp;
          END IF;
        l_total_percentage := NVL(l_total_percentage,0) + NVL(cur_rsv_uoo_prf_rec.percentage_reserved,0);
        END LOOP; -- cur_rsv_uoo_prf_rec
   ELSIF cur_rsv_uoo_pri_rec.priority_value = 'CLASS_STD' THEN
           FOR cur_rsv_uoo_prf_rec IN cur_rsv_uoo_prf(cur_rsv_uoo_pri_rec.priority_id) LOOP
             IF igs_pr_get_class_std.get_class_standing(p_person_id, p_course_cd, 'Y', SYSDATE, NULL, NULL)
                                                              = cur_rsv_uoo_prf_rec.preference_code THEN
                   IF enrf_val_reserve_seat(cur_rsv_uoo_pri_rec.priority_id,
                                          cur_rsv_uoo_prf_rec.preference_id,
                                          cur_rsv_uoo_prf_rec.percentage_reserved,
                                          l_rsv_level) THEN
                        RETURN TRUE;
                   END IF;
             END IF;
           l_total_percentage := NVL(l_total_percentage,0) + NVL(cur_rsv_uoo_prf_rec.percentage_reserved,0);
           END LOOP;
   END IF; --cur_rsv_uoo_pri_rec.priority_value
END LOOP; -- cur_rsv_uoo_rec

--
-- if no priority/preferences defined at Unit section level,
-- check the priority/preferences at Unit offering pattern level
--
IF l_rsv_level IS NULL THEN
   FOR cur_rsv_uop_pri_rec IN cur_rsv_uop_pri(l_unit_cd,l_version_number,l_cal_type,l_ci_sequence_number) LOOP
     --Assign value changed from 'UNIT_OFR_OPT' TO 'UNIT_PAT', because l_rsv_level variable is stype of IGS_PS_RSV_EXT.RSV_LEVEL
     --which is VARCHAR2(10) but 'UNIT_OFR_OPT' size is 12 chars which throws value numberic value error
     --w.r.t. bug no 2455245 by kkillams
     l_rsv_level := 'UNIT_PAT';
     IF cur_rsv_uop_pri_rec.priority_value = 'PROGRAM' THEN
       FOR cur_rsv_uop_prf_rec IN cur_rsv_uop_prf(cur_rsv_uop_pri_rec.priority_id) LOOP
          OPEN cur_program(p_person_id,cur_rsv_uop_prf_rec.preference_code ,cur_rsv_uop_prf_rec.preference_version );
          FETCH cur_program INTO l_pri_satisfied;
          IF cur_program%FOUND THEN
            IF enrf_val_reserve_seat(cur_rsv_uop_pri_rec.priority_id,
                                     cur_rsv_uop_prf_rec.preference_id,
                                     cur_rsv_uop_prf_rec.percentage_reserved,
                                     l_rsv_level) THEN
               CLOSE cur_program;
               RETURN TRUE;
            END IF;
          END IF;
          IF cur_program%ISOPEN THEN
            CLOSE cur_program;
          END IF;
       l_total_percentage := NVL(l_total_percentage,0) + NVL(cur_rsv_uop_prf_rec.percentage_reserved,0);
       END LOOP; -- cur_rsv_uop_prf_rec

     ELSIF cur_rsv_uop_pri_rec.priority_value = 'ORG_UNIT' THEN
       FOR cur_rsv_uop_prf_rec IN cur_rsv_uop_prf(cur_rsv_uop_pri_rec.priority_id) LOOP
          OPEN cur_org(p_person_id,cur_rsv_uop_prf_rec.preference_code);
          FETCH cur_org INTO l_pri_satisfied;
          IF cur_org%FOUND THEN
            IF enrf_val_reserve_seat(cur_rsv_uop_pri_rec.priority_id,
                                     cur_rsv_uop_prf_rec.preference_id,
                                     cur_rsv_uop_prf_rec.percentage_reserved,
                                     l_rsv_level) THEN
               CLOSE cur_org;
               RETURN TRUE;
            END IF;
          END IF;
          IF cur_org%ISOPEN THEN
             CLOSE cur_org;
          END IF;
       l_total_percentage := NVL(l_total_percentage,0) + NVL(cur_rsv_uop_prf_rec.percentage_reserved,0);
       END LOOP; -- cur_rsv_uop_prf_rec

     ELSIF cur_rsv_uop_pri_rec.priority_value = 'UNIT_SET' THEN
       FOR cur_rsv_uop_prf_rec IN cur_rsv_uop_prf(cur_rsv_uop_pri_rec.priority_id) LOOP
          OPEN cur_unit_set(p_person_id,cur_rsv_uop_prf_rec.preference_code ,cur_rsv_uop_prf_rec.preference_version );
          FETCH cur_unit_set INTO l_pri_satisfied;
          IF cur_unit_set%FOUND THEN
            IF enrf_val_reserve_seat(cur_rsv_uop_pri_rec.priority_id,
                                     cur_rsv_uop_prf_rec.preference_id,
                                     cur_rsv_uop_prf_rec.percentage_reserved,
                                     l_rsv_level) THEN
               CLOSE cur_unit_set;
               RETURN TRUE;
            END IF;
          END IF;
          IF cur_unit_set%ISOPEN THEN
            CLOSE cur_unit_set;
          END IF;
       l_total_percentage := NVL(l_total_percentage,0) + NVL(cur_rsv_uop_prf_rec.percentage_reserved,0);
       END LOOP; -- cur_rsv_uop_prf_rec

     ELSIF cur_rsv_uop_pri_rec.priority_value = 'PROGRAM_STAGE' THEN
       FOR cur_rsv_uop_prf_rec IN cur_rsv_uop_prf(cur_rsv_uop_pri_rec.priority_id) LOOP
          --
              -- Call the function to determine whether given student completed the given program stage
              --
              IF igs_en_gen_015.enrp_val_Ps_Stage(p_person_id,
                                          p_course_cd,
                                          p_course_version,
                                          cur_rsv_uop_prf_rec.preference_code) THEN

             IF enrf_val_reserve_seat(cur_rsv_uop_pri_rec.priority_id,
                                      cur_rsv_uop_prf_rec.preference_id,
                                      cur_rsv_uop_prf_rec.percentage_reserved,
                                      l_rsv_level) THEN
               RETURN TRUE;
                END IF;
          END IF;
        l_total_percentage := NVL(l_total_percentage,0) + NVL(cur_rsv_uop_prf_rec.percentage_reserved,0);
       END LOOP; -- cur_rsv_uop_prf_rec

     ELSIF cur_rsv_uop_pri_rec.priority_value = 'PERSON_GRP' THEN
       FOR cur_rsv_uop_prf_rec IN cur_rsv_uop_prf(cur_rsv_uop_pri_rec.priority_id) LOOP
          OPEN cur_person_grp(p_person_id,cur_rsv_uop_prf_rec.group_id);
          FETCH cur_person_grp INTO l_pri_satisfied;
          IF cur_person_grp%FOUND THEN
            IF enrf_val_reserve_seat(cur_rsv_uop_pri_rec.priority_id,
                                     cur_rsv_uop_prf_rec.preference_id,
                                     cur_rsv_uop_prf_rec.percentage_reserved,
                                     l_rsv_level) THEN
               CLOSE cur_person_grp;
               RETURN TRUE;
            END IF;
          END IF;
          IF cur_person_grp%ISOPEN THEN
            CLOSE cur_person_grp;
          END IF;
       l_total_percentage := NVL(l_total_percentage,0) + NVL(cur_rsv_uop_prf_rec.percentage_reserved,0);
       END LOOP; -- cur_rsv_uop_prf_rec
     ELSIF cur_rsv_uop_pri_rec.priority_value = 'CLASS_STD' THEN
       FOR cur_rsv_uop_prf_rec IN cur_rsv_uop_prf(cur_rsv_uop_pri_rec.priority_id) LOOP
         IF igs_pr_get_class_std.get_class_standing(p_person_id, p_course_cd, 'Y', SYSDATE, NULL, NULL)
                                                          = cur_rsv_uop_prf_rec.preference_code THEN
               IF enrf_val_reserve_seat(cur_rsv_uop_pri_rec.priority_id,
                                      cur_rsv_uop_prf_rec.preference_id,
                                      cur_rsv_uop_prf_rec.percentage_reserved,
                                      l_rsv_level) THEN
                    RETURN TRUE;
               END IF;
         END IF;
        l_total_percentage := NVL(l_total_percentage,0) + NVL(cur_rsv_uop_prf_rec.percentage_reserved,0);
       END LOOP;
     END IF; --cur_rsv_uop_pri_rec.priority_value
   END LOOP; -- cur_rsv_uop_rec
END IF;

--
-- if no priority/preferences defined at Unit section or Unit offering pattern level,
-- check the priority/preferences at Organizational Unit level
--
IF l_rsv_level IS NULL THEN
   FOR cur_rsv_org_pri_rec IN cur_rsv_org_pri(l_owner_org_unit_cd) LOOP
     l_rsv_level := 'ORG_UNIT';
     IF cur_rsv_org_pri_rec.priority_value = 'PROGRAM' THEN
       FOR cur_rsv_org_prf_rec IN cur_rsv_org_prf(cur_rsv_org_pri_rec.priority_id) LOOP
             OPEN cur_program(p_person_id,cur_rsv_org_prf_rec.preference_code ,cur_rsv_org_prf_rec.preference_version );
             FETCH cur_program INTO l_pri_satisfied;
          IF cur_program%FOUND THEN
            IF enrf_val_reserve_seat(cur_rsv_org_pri_rec.priority_id,
                                     cur_rsv_org_prf_rec.preference_id,
                                     cur_rsv_org_prf_rec.percentage_reserved,
                                     l_rsv_level) THEN
                CLOSE cur_program;
                RETURN TRUE;
             END IF;
          END IF;
          IF cur_program%ISOPEN THEN
            CLOSE cur_program;
          END IF;
       l_total_percentage := NVL(l_total_percentage,0) + NVL(cur_rsv_org_prf_rec.percentage_reserved,0);
       END LOOP; -- cur_rsv_org_prf_rec

     ELSIF cur_rsv_org_pri_rec.priority_value = 'ORG_UNIT' THEN
       FOR cur_rsv_org_prf_rec IN cur_rsv_org_prf(cur_rsv_org_pri_rec.priority_id) LOOP
          OPEN cur_org(p_person_id,cur_rsv_org_prf_rec.preference_code);
          FETCH cur_org INTO l_pri_satisfied;
          IF cur_org%FOUND THEN
            IF enrf_val_reserve_seat(cur_rsv_org_pri_rec.priority_id,
                                     cur_rsv_org_prf_rec.preference_id,
                                     cur_rsv_org_prf_rec.percentage_reserved,
                                     l_rsv_level) THEN
               CLOSE cur_org;
               RETURN TRUE;
             END IF;
          END IF;
          IF cur_org%ISOPEN THEN
            CLOSE cur_org;
          END IF;
       l_total_percentage := NVL(l_total_percentage,0) + NVL(cur_rsv_org_prf_rec.percentage_reserved,0);
       END LOOP; -- cur_rsv_org_prf_rec

     ELSIF cur_rsv_org_pri_rec.priority_value = 'UNIT_SET' THEN
       FOR cur_rsv_org_prf_rec IN cur_rsv_org_prf(cur_rsv_org_pri_rec.priority_id) LOOP
          OPEN cur_unit_set(p_person_id,cur_rsv_org_prf_rec.preference_code ,cur_rsv_org_prf_rec.preference_version );
          FETCH cur_unit_set INTO l_pri_satisfied;
          IF cur_unit_set%FOUND THEN
            IF enrf_val_reserve_seat(cur_rsv_org_pri_rec.priority_id,
                                         cur_rsv_org_prf_rec.preference_id,
                                                                 cur_rsv_org_prf_rec.percentage_reserved,
                                                         l_rsv_level) THEN
               CLOSE cur_unit_set;
               RETURN TRUE;
            END IF;
          END IF;
          IF cur_unit_set%ISOPEN THEN
            CLOSE cur_unit_set;
          END IF;
       l_total_percentage := NVL(l_total_percentage,0) + NVL(cur_rsv_org_prf_rec.percentage_reserved,0);
       END LOOP; -- cur_rsv_org_prf_rec

     ELSIF cur_rsv_org_pri_rec.priority_value = 'PROGRAM_STAGE' THEN
       FOR cur_rsv_org_prf_rec IN cur_rsv_org_prf(cur_rsv_org_pri_rec.priority_id) LOOP
          --
              -- Call the function to determine whether given student completed the given program stage
              --
              IF igs_en_gen_015.enrp_val_Ps_Stage(p_person_id,
                                          p_course_cd,
                                          p_course_version,
                                          cur_rsv_org_prf_rec.preference_code) THEN

            IF enrf_val_reserve_seat(cur_rsv_org_pri_rec.priority_id,
                                         cur_rsv_org_prf_rec.preference_id,
                                                                 cur_rsv_org_prf_rec.percentage_reserved,
                                                         l_rsv_level) THEN
               RETURN TRUE;
                END IF;
          END IF;
       l_total_percentage := NVL(l_total_percentage,0) + NVL(cur_rsv_org_prf_rec.percentage_reserved,0);
       END LOOP; -- cur_rsv_org_prf_rec

     ELSIF cur_rsv_org_pri_rec.priority_value = 'PERSON_GRP' THEN
       FOR cur_rsv_org_prf_rec IN cur_rsv_org_prf(cur_rsv_org_pri_rec.priority_id) LOOP
          OPEN cur_person_grp(p_person_id,cur_rsv_org_prf_rec.group_id);
          FETCH cur_person_grp INTO l_pri_satisfied;
          IF cur_person_grp%FOUND THEN
            IF enrf_val_reserve_seat(cur_rsv_org_pri_rec.priority_id,
                                         cur_rsv_org_prf_rec.preference_id,
                                                                 cur_rsv_org_prf_rec.percentage_reserved,
                                                         l_rsv_level) THEN
                CLOSE cur_person_grp;
                RETURN TRUE;
             END IF;
          END IF;
          IF cur_person_grp%ISOPEN THEN
             CLOSE cur_person_grp;
          END IF;
       l_total_percentage := NVL(l_total_percentage,0) + NVL(cur_rsv_org_prf_rec.percentage_reserved,0);
       END LOOP; -- cur_rsv_org_prf_rec
    ELSIF cur_rsv_org_pri_rec.priority_value = 'CLASS_STD' THEN
       FOR cur_rsv_org_prf_rec IN cur_rsv_org_prf(cur_rsv_org_pri_rec.priority_id) LOOP
         IF igs_pr_get_class_std.get_class_standing(p_person_id, p_course_cd, 'Y', SYSDATE, NULL, NULL)
                                                          = cur_rsv_org_prf_rec.preference_code THEN
               IF enrf_val_reserve_seat(cur_rsv_org_pri_rec.priority_id,
                                      cur_rsv_org_prf_rec.preference_id,
                                      cur_rsv_org_prf_rec.percentage_reserved,
                                      l_rsv_level) THEN
                    RETURN TRUE;
               END IF;
         END IF;
        l_total_percentage := NVL(l_total_percentage,0) + NVL(cur_rsv_org_prf_rec.percentage_reserved,0);
       END LOOP;
     END IF; --cur_rsv_org_pri_rec.priority_value
   END LOOP; -- cur_rsv_org_rec
END IF;

--
-- If no priority/preferences defined at any level
--
IF l_rsv_level IS NULL THEN
  RETURN TRUE;
END IF;

--
-- student hasn't satisfied any priority/preference
-- check whether any seats available in unreserved category.
--
 l_unreserved_seats := Igs_En_Gen_015.seats_in_unreserved_category(
                                                                   p_uoo_id => p_uoo_id  ,
                                                                   p_level => l_rsv_level );

-- if unreserved seats available return TRUE
IF l_unreserved_seats >= 1 THEN
  RETURN TRUE;
END IF;

IF p_deny_warn = 'WARN' THEN
  IF p_calling_obj = 'JOB' THEN
     l_message := 'IGS_SS_WARN_RSVSEAT_CHK';
  ELSE
     l_message := 'IGS_EN_RSVSEAT_TAB_WARN';
  END IF;
ELSE
  IF p_calling_obj = 'JOB' THEN
     l_message := 'IGS_SS_DENY_RSVSEAT_CHK';
  ELSE
     l_message := 'IGS_EN_RSVSEAT_TAB_DENY';
  END IF;
  IF l_unreserved_seats < 1 AND NVL(l_total_percentage,-1) >= 100 THEN
    p_deny_enrollment := 'Y';
  END IF;
END IF;

IF p_calling_obj NOT IN  ('JOB','SCH_UPD') THEN

      l_message_icon := substr(p_deny_warn,1,1);
      igs_en_drop_units_api.create_ss_warning (
             p_person_id => p_person_id,
             p_course_cd => p_course_cd,
             p_term_cal_type=> p_load_cal_type,
             p_term_ci_sequence_number => p_load_sequence_number,
             p_uoo_id => p_uoo_id,
             p_message_for => l_unit_cd||'/'||l_unit_class ,
             p_message_icon=> l_message_icon,
             p_message_name => l_message,
             p_message_rule_text => NULL,
             p_message_tokens => NULL,
             p_message_action=> NULL,
             p_destination =>NULL,
             p_parameters => NULL,
             p_step_type => 'UNIT');

ELSE

      IF p_message IS NULL THEN
        p_message := l_message;
      ELSE
        p_message := p_message || ';' || l_message;
      END IF;

END IF;




RETURN FALSE;

END eval_rsv_seat;

-- =================================================================================

FUNCTION eval_cart_max(
p_person_id IN NUMBER,
p_load_cal_type IN VARCHAR2,
p_load_sequence_number IN VARCHAR2,
p_uoo_id  IN NUMBER,
p_course_cd IN VARCHAR2,
p_course_version IN NUMBER,
p_message IN OUT NOCOPY VARCHAR2,
p_deny_warn  IN VARCHAR2,
p_rule_seq_number IN NUMBER
) RETURN BOOLEAN AS

------------------------------------------------------------------------------------
  --Created by  : knaraset ( Oracle IDC)
  --Date created: 21-JUN-2001
  --
  --Purpose:
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -- svenkata                   Call to igs_ru_gen_001.rulp_val_senna has been modified to include 2 new parameters
  --                            p_load_cal_type and p_load_sequence_number . The corresponding named rule has also been
  --                            modified . Bug # 2338013.
  -------------------------------------------------------------------------------------

  l_step_override_limit igs_en_elgb_ovr_step.step_override_limit%TYPE;
  l_message VARCHAR2(30);
--
-- begin of the function eval_coreq
--
BEGIN

-- no cart max rule defined
IF p_rule_seq_number IS NULL THEN
  RETURN TRUE;
END IF;

-- check whether cart max rule has been overriden for the given student.
IF Igs_En_Gen_015.validation_step_is_overridden ('CART_MAX',
                                                p_load_cal_type,
                                                p_load_sequence_number ,
                                                p_person_id ,
                                                p_uoo_id ,
                                                l_step_override_limit) THEN
    RETURN TRUE;
END IF;

--
-- check whether student has satisfied the cart max rule by invoking the rule engine

IF igs_ru_gen_001.rulp_val_senna(p_rule_call_name => 'CART_MAX',
                                 p_person_id => p_person_id,
                                 p_message => l_message,
                                 p_rule_number => p_rule_seq_number,
                                 p_param_1 => p_course_cd,
                                 p_param_2 => p_course_version,
                                 p_param_3 => p_load_cal_type,
                                 p_param_4 => p_load_sequence_number
   ) = 'false' THEN

   IF p_deny_warn = 'WARN' THEN
     IF p_message IS NULL THEN
        p_message := 'IGS_SS_WARN_CART_MAX';
     ELSE
        p_message := p_message ||';'||'IGS_SS_WARN_CART_MAX';
     END IF;
   ELSE
     IF p_message IS NULL THEN
        p_message := 'IGS_SS_DENY_CART_MAX';
     ELSE
        p_message := p_message ||';'||'IGS_SS_DENY_CART_MAX';
     END IF;
   END IF;
   RETURN FALSE;
END IF;

RETURN TRUE;

END eval_cart_max;
  --
  --
  --  This function is used to evaluate the Intermission Unit Level Rule Status.
  --
  --
  FUNCTION eval_intmsn_unit_lvl
  (
    p_person_id                    IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_cal_seq_number          IN     NUMBER,
    p_uoo_id                       IN     NUMBER,
    p_program_cd                   IN     VARCHAR2,
    p_program_version              IN     VARCHAR2,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_deny_warn                    IN     VARCHAR2,
    p_rule_seq_number              IN     NUMBER,
    p_calling_obj                  IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*  HISTORY
    WHO        WHEN         WHAT
    ayedubat   07-JUN-2002   Changed the type of cursor parameter,cp_program_cd from NUMBER to
                             IGS_PS_VER.course_cd%TYPE of the cursor,cur_intermission_details for the bug:2381603
    svenkata   26-JUN-2002   The IF condition for the Intermission records had a logical error . The same has been
                             fixed .Bug # 2423604
  */
    --
    --  Parameters Description:
    --
    --  p_person_id                  -> Person ID of the student who wants to enroll or administrator is enrolling.
    --  p_load_cal_type              -> Load (Term) or Teaching Calendar Type.
    --  p_load_cal_seq_number        -> Load Calendar or Teaching Calendar instance sequence number.
    --  p_uoo_id                     -> Unit Section Identifier.
    --  p_program_cd                 -> The Primary Program Code or the Program code selected by the student.
    --  p_program_version            -> The Primary Program version number or the Program version number selected by the student.
    --  p_message                    -> Message from the validation.
    --  p_deny_warn                  -> Deny or Warn Indicator based on the setup.
    --  p_rule_seq_number            -> Sequence Number of the Unit level Intermission Rules.
    --
    --
    --  Cursor to find Calendar Type and Calendar Sequence Number for a Unit Section.
    --
    CURSOR cur_cal_type_seq_num (
             cp_uoo_id                IN NUMBER
           ) IS
    SELECT   cal_type, ci_sequence_number, unit_cd, unit_class
    FROM     igs_ps_unit_ofr_opt
    WHERE    uoo_id = cp_uoo_id;
    --
    --  Cursor to find Intermission Type and Start Date for a given Person and Program.
    --
    CURSOR cur_intermission_details (
           cp_person_id   IGS_EN_STDNT_PS_ATT.person_id%TYPE,
           cp_program_cd  IGS_PS_VER.course_cd%TYPE
    ) IS
    SELECT   sci.intermission_type,
             sci.start_dt,
             sci.approved
    FROM     igs_en_stdnt_ps_intm sci,
             IGS_EN_INTM_TYPES eit,
             igs_en_stdnt_ps_att spa
    WHERE    sci.person_id = cp_person_id
    AND      sci.course_cd = cp_program_cd
    AND      sci.approved  = eit.appr_reqd_ind
    AND      eit.intermission_type = sci.intermission_type
    AND      sci.logical_delete_date = TO_DATE('31-12-4712','DD-MM-YYYY')
    AND      spa.person_id = sci.person_id
    AND      spa.course_cd = sci.course_cd
    AND      ((trunc(sysdate) between sci.start_dt and sci.end_dt)
               OR
              ((trunc(sysdate) > sci.end_dt) AND (spa.course_attempt_status = 'INTERMIT'))
             );

    --
    l_cal_type_rec cur_cal_type_seq_num%ROWTYPE;
    rec_cur_intermission_details cur_intermission_details%ROWTYPE;
    l_step_override_limit igs_en_elgb_ovr_step.step_override_limit%TYPE;
    l_message VARCHAR2(30);
    l_return_value VARCHAR2(30) := 'true';
    l_rule_text VARCHAR2(1000);
    l_message_icon VARCHAR2(1);
    --

  BEGIN
    --
    --  Check whether Unit Level Intermission Status step has been overridden.
    --
    IF Igs_En_Gen_015.validation_step_is_overridden (
         'INT_STSU',
         p_load_cal_type,
         p_load_cal_seq_number,
         p_person_id,
         p_uoo_id,
         l_step_override_limit
       ) THEN
      RETURN TRUE;
    END IF;

    IF p_rule_seq_number IS  NULL THEN
      RETURN TRUE;
    ELSE

      --
      --  If the Rule is defined then get the Teaching Calendar Type and Teaching Calendar Sequence Number.
      --
      OPEN cur_cal_type_seq_num (p_uoo_id);
      FETCH cur_cal_type_seq_num INTO l_cal_type_rec;
      CLOSE cur_cal_type_seq_num;
      --
      --  Select all the intermission records of the program passed and make a call to the rule for all of them.
      --
      FOR rec_cur_intermission_details IN cur_intermission_details (p_person_id, p_program_cd) LOOP
        --
        --  Check whether student has satisfied the Intermission Status Step rule by invoking the rule engine.
        --
        l_return_value := igs_ru_gen_001.rulp_val_senna (
              p_rule_call_name             => 'INT_STSU',
              p_rule_number                => p_rule_seq_number,
              p_person_id                  => p_person_id,
              p_param_1                    => p_program_cd,
              p_param_2                    => rec_cur_intermission_details.intermission_type,
              p_param_3                    => rec_cur_intermission_details.start_dt,
              p_param_4                    => p_load_cal_type,
              p_param_5                    => p_load_cal_seq_number,
              p_param_6                    => l_cal_type_rec.cal_type,
              p_param_7                    => l_cal_type_rec.ci_sequence_number,
              p_message                    => l_message
            ) ;
        IF l_return_value = 'false'  THEN
          EXIT;
        END IF;
      END LOOP;
      --
      --  If the student has not satisfied the Intermission Status Step rule then return FALSE with a warning/deny message.
      --
      IF l_return_value = 'false'  THEN


        IF p_deny_warn = 'WARN' THEN
             l_message := 'IGS_SS_WARN_INTERMIT_STAT';
        ELSE
             l_message := 'IGS_SS_DENY_INTERMIT_STAT';
        END IF;

        IF p_calling_obj NOT IN  ('JOB','SCH_UPD','JOB_FROM_WAITLIST') THEN

          IF(NVL(fnd_profile.value('IGS_EN_CART_RULE_DISPLAY'),'N')='Y') THEN
            l_rule_text := igs_ru_gen_003.Rulp_Get_Rule(p_rule_seq_number);
          END IF;
          l_message_icon := substr(p_deny_warn,1,1);
          igs_en_drop_units_api.create_ss_warning (
                 p_person_id => p_person_id,
                 p_course_cd => p_program_cd,
                 p_term_cal_type=> p_load_cal_type,
                 p_term_ci_sequence_number => p_load_cal_seq_number,
                 p_uoo_id => p_uoo_id,
                 p_message_for => l_cal_type_rec.unit_cd||'/'||l_cal_type_rec.unit_class ,
                 p_message_icon=> l_message_icon,
                 p_message_name => l_message,
                 p_message_rule_text => l_rule_text,
                 p_message_tokens => NULL,
                 p_message_action=> NULL,
                 p_destination =>NULL,
                 p_parameters => NULL,
                 p_step_type => 'UNIT');

      ELSE

        IF p_message IS NULL THEN
          p_message := l_message;
        ELSE
          p_message := p_message || ';' || l_message;
        END IF;

      END IF; -- IF p_calling_obj <> 'JOB' THEN

      RETURN FALSE;

    ELSE
      RETURN TRUE;
    END IF; -- IF l_return_value = 'false'  THEN

  END IF;  --   IF p_rule_seq_number IS  NULL
    --
  END eval_intmsn_unit_lvl;
  --
  --
  --  This function is used to evaluate the Visa Unit Level Rule Status.
  --
  --
  FUNCTION eval_visa_unit_lvl
  (
    p_person_id                    IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_cal_seq_number          IN     NUMBER,
    p_uoo_id                       IN     NUMBER,
    p_program_cd                   IN     VARCHAR2,
    p_program_version              IN     VARCHAR2,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_deny_warn                    IN     VARCHAR2,
    p_rule_seq_number              IN     NUMBER,
    p_calling_obj                  IN     VARCHAR2
  ) RETURN BOOLEAN AS
------------------------------------------------------------------------------------
  --Created by  : knaraset ( Oracle IDC)
  --Date created: 21-JUN-2001
  --
  --Purpose:
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------------------------
    --
    --  Parameters Description:
    --
    --  p_person_id                  -> Person ID of the student who wants to enroll or administrator is enrolling.
    --  p_load_cal_type              -> Load (Term) or Teaching Calendar Type.
    --  p_load_cal_seq_number        -> Load Calendar or Teaching Calendar instance sequence number.
    --  p_uoo_id                     -> Unit Section Identifier.
    --  p_program_cd                 -> The Primary Program Code or the Program code selected by the student.
    --  p_program_version            -> The Primary Program version number or the Program version number selected by the student.
    --  p_message                    -> Message from the validation.
    --  p_deny_warn                  -> Deny or Warn Indicator based on the setup.
    --  p_rule_seq_number            -> Sequence Number of  the Unit level Visa Status Rules.
    --
    --
    --  Cursor to find Calendar Type and Calendar Sequence Number for a Unit Section.
    --
    CURSOR cur_cal_type_seq_num (
             cp_uoo_id                IN NUMBER
           ) IS
    SELECT   cal_type,
             ci_sequence_number,unit_cd,unit_class
    FROM     igs_ps_unit_ofr_opt
    WHERE    uoo_id = cp_uoo_id;
    --
    --  Cursor to find Visa Type and Visa Number.
    --
    CURSOR cur_visa_details (
             cp_person_id             IN NUMBER
           ) IS
      SELECT   visa_type,
               visa_number
      FROM     igs_pe_visa
      WHERE    person_id = cp_person_id;
    --
    l_cal_type_rec cur_cal_type_seq_num%ROWTYPE;
    rec_cur_visa_details cur_visa_details%ROWTYPE;
    l_step_override_limit igs_en_elgb_ovr_step.step_override_limit%TYPE;
    l_message VARCHAR2(30);
    l_rule_text VARCHAR2(1000);
    l_message_icon VARCHAR2(1);
    --
  BEGIN
    --
    --  Check whether Unit Level Visa Status step has been overridden.
    --
    IF Igs_En_Gen_015.validation_step_is_overridden (
         'VISA_STSU',
         p_load_cal_type,
         p_load_cal_seq_number ,
         p_person_id ,
         p_uoo_id ,
         l_step_override_limit
       ) THEN
      RETURN TRUE;
    END IF;
    IF (p_rule_seq_number IS NULL) THEN
      RETURN TRUE;
    ELSE


      --
      --  If the Rule is defined then get the Teaching Calendar Type and Teaching Calendar Sequence Number.
      --
      OPEN cur_cal_type_seq_num (p_uoo_id);
      FETCH cur_cal_type_seq_num INTO l_cal_type_rec;
      CLOSE cur_cal_type_seq_num;
      --
      --  Select all the Visa records of the student and make a call to the rule for all of them.
      --
      FOR rec_cur_visa_details IN cur_visa_details (p_person_id) LOOP
        --
        --  Check whether student has satisfied the Visa Status rule by invoking the rule engine.
        --
        IF (igs_ru_gen_001.rulp_val_senna (
              p_rule_call_name             => 'VISA_STSU',
              p_rule_number                => p_rule_seq_number,
              p_person_id                  => p_person_id,
              p_param_1                    => rec_cur_visa_details.visa_type,
              p_param_2                    => p_load_cal_type ,
              p_param_3                    => p_load_cal_seq_number      ,
              p_param_4                    => l_cal_type_rec.cal_type,
              p_param_5                    => l_cal_type_rec.ci_sequence_number,
              p_param_6                    => rec_cur_visa_details.visa_number,
              p_message                    => l_message
            ) = 'true' ) THEN
          RETURN TRUE;
        END IF;
      END LOOP;
      --
      --  If the student has not satisfied the Visa Status Step rule then return FALSE with a warning/deny message.
      --
      IF p_deny_warn = 'WARN' THEN
          l_message := 'IGS_SS_WARN_VISA_STAT';
      ELSE
          l_message := 'IGS_SS_DENY_VISA_STAT';
      END IF;


      l_rule_text := NULL;

      IF p_calling_obj NOT IN  ('JOB','SCH_UPD','JOB_FROM_WAITLIST') THEN

        IF(NVL(fnd_profile.value('IGS_EN_CART_RULE_DISPLAY'),'N')='Y') THEN
         l_rule_text := igs_ru_gen_003.Rulp_Get_Rule(p_rule_seq_number);
        END IF;
        l_message_icon := substr(p_deny_warn,1,1);
        igs_en_drop_units_api.create_ss_warning (
               p_person_id => p_person_id,
               p_course_cd => p_program_cd,
               p_term_cal_type=> p_load_cal_type,
               p_term_ci_sequence_number => p_load_cal_seq_number,
               p_uoo_id => p_uoo_id,
               p_message_for => l_cal_type_rec.unit_cd||'/'||l_cal_type_rec.unit_class ,
               p_message_icon=> l_message_icon,
               p_message_name => l_message,
               p_message_rule_text => l_rule_text,
               p_message_tokens => NULL,
               p_message_action=> NULL,
               p_destination =>NULL,
               p_parameters => NULL,
               p_step_type => 'UNIT');



        ELSE
          IF p_message IS NULL THEN
            p_message := l_message;
          ELSE
            p_message := p_message || ';' || l_message;
          END IF;
      END IF; -- IF p_calling_obj <> 'JOB' THEN
    END IF; -- IF (p_rule_seq_number IS NULL) THEN
    RETURN FALSE;
    --
  END eval_visa_unit_lvl;


  FUNCTION eval_audit_permission (p_person_id             IN NUMBER,
                                  p_load_cal_type         IN VARCHAR2,
                                  p_load_sequence_number  IN VARCHAR2,
                                  p_uoo_id                IN NUMBER,
                                  p_course_cd             IN VARCHAR2,
                                  p_course_version        IN NUMBER,
                                  p_message               IN OUT NOCOPY VARCHAR2,
                                  p_deny_warn             IN VARCHAR2
                                 ) RETURN BOOLEAN AS
--------------------------------------------------------------------------------
  --Created by  : prraj ( Oracle IDC)
  --Date created: 23-OCT-2002
  --
  --Purpose: This function will check whether audit permission exist for the
  --         given student and unit section
  --
  --Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  -- prraj       23-Oct          Created
--------------------------------------------------------------------------------

  -- Cursor to check whether the approved audit permission record
  -- exists in the table Igs_En_Spl_Perm for the given student and unit section
  CURSOR c_approv_perm IS
  SELECT 'x'
  FROM Igs_En_Spl_Perm
  WHERE student_person_id = p_person_id
  AND uoo_id            = p_uoo_id
  AND request_type      = 'AUDIT_PERM'
  AND approval_status = 'A';

 CURSOR cur_chk_au_allowed IS
  SELECT NVL(auditable_ind, 'N')
  FROM igs_ps_unit_ofr_opt
  WHERE uoo_id = p_uoo_id;

  CURSOR cur_chk_au_perm_req IS
  SELECT NVL(audit_permission_ind, 'N')
  FROM igs_ps_unit_ofr_opt
  WHERE uoo_id = p_uoo_id;

  -- Local variables
  l_dummy               VARCHAR2(1);
  l_audit_allowed   VARCHAR2(1);
  l_au_perm_req   VARCHAR2(1);
  l_step_override_limit igs_en_elgb_ovr_step.step_override_limit%TYPE;
  BEGIN

      -- Check whether the Audit is allowed in the given unit section
      -- If audit is not allowed return error message.
      OPEN cur_chk_au_allowed;
        FETCH cur_chk_au_allowed INTO l_audit_allowed;
      CLOSE cur_chk_au_allowed;

      IF l_audit_allowed = 'N' THEN

         IF p_message IS NULL THEN
                 p_message := 'IGS_EN_CANNOT_AUDIT';
             ELSE
                 p_message := p_message ||';'||'IGS_EN_CANNOT_AUDIT';
         END IF;
         RETURN FALSE;
      END IF;

    -- For Audit TD Bug 2641864
    --  Check whether Audit Permission step has been overridden.
    --
    IF Igs_En_Gen_015.validation_step_is_overridden (
         'AUDIT_PERM',
         p_load_cal_type,
         p_load_sequence_number ,
         p_person_id ,
         p_uoo_id ,
         l_step_override_limit
       ) THEN
      RETURN TRUE;
    END IF;

    -- check whether audit permission required for the given unit section
    OPEN cur_chk_au_perm_req;
    FETCH cur_chk_au_perm_req INTO l_au_perm_req;
    CLOSE cur_chk_au_perm_req;
    IF l_au_perm_req = 'N' THEN
       RETURN TRUE;
    END IF;

      OPEN c_approv_perm;
        FETCH c_approv_perm INTO l_dummy;

      IF c_approv_perm%FOUND THEN
         CLOSE c_approv_perm;
                RETURN TRUE;
      ELSE
              --  If the student has not satisfied the Audit Permission Step rule
              --  then return FALSE with a warning/deny message.
              --
              IF p_deny_warn = 'WARN' THEN
                  IF p_message IS NULL THEN
                    p_message := 'IGS_EN_WARN_AUDIT_PERM';
                  ELSE
                    p_message := p_message || ';' || 'IGS_EN_WARN_AUDIT_PERM';
                  END IF;
              ELSE
                  IF p_message IS NULL THEN
                    p_message := 'IGS_EN_DENY_AUDIT_PERM';
                  ELSE
                    p_message := p_message || ';' || 'IGS_EN_DENY_AUDIT_PERM';
                  END IF;
              END IF;
      END IF;
      CLOSE c_approv_perm;

    RETURN FALSE;

  END eval_audit_permission;


  FUNCTION eval_student_audit_limit(p_person_id             IN NUMBER,
                                    p_load_cal_type         IN VARCHAR2,
                                    p_load_sequence_number  IN VARCHAR2,
                                    p_uoo_id                IN NUMBER,
                                    p_course_cd             IN VARCHAR2,
                                    p_course_version        IN NUMBER,
                                    p_message               IN OUT NOCOPY VARCHAR2,
                                    p_deny_warn             IN VARCHAR2,
                                    p_stud_audit_lim        IN NUMBER,
                                    p_calling_obj           IN VARCHAR2
                                   ) RETURN BOOLEAN AS
----------------------------------------------------------------------------------------------------------------------------------------------------------------
  --Created by  : prraj ( Oracle IDC)
  --Date created: 23-OCT-2002
  --
  --Purpose: This function will check whether the number of audit units attempted
  --         by the given student is crossing the limit defined
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  -- Who              When                What
  -- prraj             23-Oct                    Created
  --myoganat     12-Jun-2003     Cursor c_car_audit_units  and its usage was removed as part of Bug# 2855870 (ENCR032 Build)
  --                                             The above cursor was used for evaluation of audit points for a student  under career centric approach
  --                                             Now c_prg_audit_units  is used for both program centric and career centric approaches.
  ----------------------------------------------------------------------------------------------------------------------------------------------------------------

        -- Program centric
        -- Cursor to count the number of audit units for the student
        -- under all the program attempts
    CURSOR c_prg_audit_units IS
    SELECT count(*)
    FROM igs_en_su_attempt
    WHERE person_id = p_person_id
    AND no_assessment_ind = 'Y'
    AND ((p_calling_obj <> 'PLAN' AND unit_attempt_status IN ('ENROLLED', 'COMPLETED','INVALID','UNCONFIRM')  )
        OR (p_calling_obj = 'PLAN' AND unit_attempt_status IN ('ENROLLED', 'COMPLETED','INVALID','UNCONFIRM','PLANNED') )
        OR (unit_attempt_status = 'WAITLISTED' AND FND_PROFILE.VALUE('IGS_EN_VAL_WLST')  ='Y'))
    AND (cal_type,ci_sequence_number) IN (SELECT teach_cal_type,teach_ci_sequence_number
                                          FROM igs_ca_load_to_teach_v
                                          WHERE load_cal_type = p_load_cal_type AND
                                                load_ci_sequence_number = p_load_sequence_number);

    -- Local variables
    l_audit_count   NUMBER;
    l_step_override_limit igs_en_elgb_ovr_step.step_override_limit%TYPE;

    CURSOR cur_usec_dtls IS
    SELECT unit_cd,unit_class
    FROM igs_ps_unit_ofr_opt
    WHERE uoo_id = p_uoo_id;

    l_usec_dtls cur_usec_dtls%ROWTYPE;
    l_message VARCHAR2(30);
    l_message_icon VARCHAR2(1);


  BEGIN

    -- For Audit TD Bug 2641864.
    --  Check whether Audit Limit for Student step has been overridden.
    --
    IF Igs_En_Gen_015.validation_step_is_overridden (
         'AUDIT_LIM',
         p_load_cal_type,
         p_load_sequence_number ,
         p_person_id ,
         p_uoo_id ,
         l_step_override_limit
       ) THEN
      RETURN TRUE;
    END IF;

     OPEN c_prg_audit_units;
     FETCH c_prg_audit_units INTO l_audit_count;
     CLOSE c_prg_audit_units;

      -- If the student has not satisfied the Audit Limit Step rule then
      -- return FALSE with a warning/deny message.

      IF l_audit_count > p_stud_audit_lim OR
        ( p_calling_obj ='SCH_UPD' AND l_audit_count >= p_stud_audit_lim ) THEN

          IF p_deny_warn = 'WARN' THEN

                  IF  p_calling_obj = 'JOB' THEN
                    l_message  :=  'IGS_EN_WARN_AUDIT_LIM';
                  ELSIF p_calling_obj = 'CART' THEN
                    l_message := 'IGS_EN_EXCAUDS_TAB_WARN';
                  ELSIF  p_calling_obj <> 'SCH_UPD' THEN
                    l_message := 'IGS_EN_AUDLIM_TAB_WARN';
                  END IF;
          ELSE
                  IF p_calling_obj = 'SCH_UPD' THEN
                    l_message  :=  'IGS_EN_AUDLIM_UPD_DENY';
                  ELSIF  p_calling_obj = 'JOB' THEN
                    l_message  :=  'IGS_EN_DENY_AUDIT_LIM';
                  ELSIF p_calling_obj = 'CART' THEN
                    l_message := 'IGS_EN_EXCAUDS_TAB_DENY';
                  ELSE
                    l_message := 'IGS_EN_AUDLIM_TAB_DENY';
                  END IF;
          END IF;

          IF p_calling_obj NOT IN  ('JOB','SCH_UPD') THEN

            l_message_icon := substr(p_deny_warn,1,1);
            OPEN cur_usec_dtls;
            FETCH cur_usec_dtls INTO l_usec_dtls;
            CLOSE cur_usec_dtls;
            igs_en_drop_units_api.create_ss_warning (
                   p_person_id => p_person_id,
                   p_course_cd => p_course_cd,
                   p_term_cal_type=> p_load_cal_type,
                   p_term_ci_sequence_number => p_load_sequence_number,
                   p_uoo_id => p_uoo_id,
                   p_message_for => l_usec_dtls.unit_cd||'/'||l_usec_dtls.unit_class,
                   p_message_icon=> l_message_icon,
                   p_message_name => l_message,
                   p_message_rule_text => NULL,
                   p_message_tokens => NULL,
                   p_message_action=> NULL,
                   p_destination =>NULL,
                   p_parameters => NULL,
                   p_step_type => 'UNIT');

              IF l_message_icon <> 'D' THEN
                RETURN TRUE;
              END  IF;

           ELSE
               IF (p_message IS NULL) THEN
                 p_message := l_message;
               ELSE
                 p_message := p_message || ';' || l_message;
               END IF;
          END IF;

         RETURN FALSE;

      ELSE
         RETURN TRUE;
      END IF;

  END eval_student_audit_limit;

 FUNCTION eval_award_prog_only(
		p_person_id             IN NUMBER,
        p_person_type       IN VARCHAR2,
        p_load_cal_type         IN VARCHAR2,
		p_load_sequence_number  IN VARCHAR2,
		p_uoo_id                IN NUMBER,
		p_course_cd             IN VARCHAR2,
		p_course_version        IN NUMBER,
		p_message               OUT NOCOPY VARCHAR2,
		p_calling_obj			IN			VARCHAR2
	 ) RETURN BOOLEAN AS

    CURSOR cur_pers_sys_type(cp_person_type_code IN VARCHAR2) IS
    SELECT system_type
    FROM igs_pe_person_types
    WHERE person_type_code = cp_person_type_code;

    CURSOR c_admin_ovr (cp_person_type_code IN VARCHAR2) IS
    SELECT 'X'
    FROM IGS_PE_USR_AVAL
    WHERE PERSON_TYPE = cp_person_type_code
    AND validation = 'AWD_CRS_ONLY'
    AND OVERRIDE_IND = 'Y';

    CURSOR c_prog_award IS
    select NVL(AWARD_COURSE_IND,'N')
    from igs_ps_type ct, igs_ps_ver cv
    where cv.course_cd = p_course_Cd
    and cv.version_number = p_course_version
    and cv.course_type = ct.course_type;


    CURSOR c_unit_award IS
    SELECT NVL(AWARD_COURSE_ONLY_IND,'N')
    FROM igs_ps_unit_ver uv, igs_ps_unit_ofr_opt uoo
    where uv.unit_cd = uoo.unit_cd
    and uv.version_number = uoo.version_number
    and uoo.uoo_id = p_uoo_id;

    l_system_type igs_pe_person_types.system_type%TYPE ;
    v_prog_award_ind igs_ps_type.AWARD_COURSE_IND%TYPE;
    v_unit_award_ind igs_ps_unit_ver.AWARD_COURSE_ONLY_IND%TYPE;
    l_step_override_limit number;
    l_dummy VARCHAR2(1);

  BEGIN

    IF p_person_type IS NOT NULL THEN
      OPEN cur_pers_sys_type(p_person_type);
      FETCH cur_pers_sys_type INTO l_system_type;
      CLOSE cur_pers_sys_type;

      IF l_system_type <> 'STUDENT' THEN
        OPEN c_admin_ovr(p_person_type);
        FETCH c_admin_ovr INTO l_dummy;
        IF c_admin_ovr%FOUND THEN
          CLOSE c_admin_ovr;
          RETURN TRUE;
        ELSE
          CLOSE c_admin_ovr;
        END IF;
      END IF;
    END IF;


      --
      -- check whether the Forced location step is overridden
      --
      IF Igs_En_Gen_015.validation_step_is_overridden (
           'AWD_CRS_ONLY',
           p_load_cal_type,
           p_load_sequence_number ,
           p_person_id ,
           p_uoo_id ,
           l_step_override_limit
         ) THEN
          RETURN TRUE;
      END IF;

      OPEN c_prog_award;
      FETCH c_prog_award INTO v_prog_award_ind;
      CLOSE c_prog_award;

      IF v_prog_award_ind = 'N' THEN
        OPEN c_unit_award;
        FETCH c_unit_award INTO v_unit_award_ind;
        CLOSE c_unit_award;

        IF v_unit_award_ind = 'Y' THEN
          p_message := 'IGS_AD_UNITVER_AWARD_PRG';
          RETURN FALSE;
        ELSE
          p_message := NULL;
        END IF;
      END IF;

      RETURN TRUE;

  END eval_award_prog_only;



END igs_en_elgbl_unit;

/
