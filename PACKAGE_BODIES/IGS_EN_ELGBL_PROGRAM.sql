--------------------------------------------------------
--  DDL for Package Body IGS_EN_ELGBL_PROGRAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_ELGBL_PROGRAM" AS
/* $Header: IGSEN79B.pls 120.7 2006/05/02 23:58:10 ckasu ship $ */

  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  -- ckasu       15-Jul-2005     Modified this function inorder to log warning records in to a warnings Table
  --                             when called from selefservice pages as a part of EN317 SS UI Build bug#4377985

  --ayedubat   6-JUN-2002       Changed the functions eval_max_cp,eval_min_cp and eval_unit_forced_type
  --                            to replace the function call Igs_En_Gen_015.get_academic_cal with
  --                            Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd for the bug Fix: 2381603
  --svenkata   4-Jun-02         The Attendance Type validation shows message for Attendance Mode .The message
  --                                          returned by the function eval_unit_forced_type has been modified . Bug # 2396126
  --prchandr    08-Jan-01       Enh Bug No: 2174101, As the Part of Change in IGSEN18B
  --                            Passing NULL as parameters  to ENRP_CLC_SUA_EFTSU
  --                            ENRP_CLC_EFTSU_TOTAL for Key course cd and version number
  --knaraset 14-May-02          Modified CO_REQ to COREQ in eval_program_steps and also the
  --                            cursor cur_coo_id in eval_unit_forced_type to include course_cd
  --                            in WHERE clause.
  -------------------------------------------------------------------------------------------
/******************************************************************
Created By        : Vinay Chappidi
Date Created By   : 19-Jun-2001
Purpose           : When the user tries to finalize the units he has selected
                    for enrolment, program level validations have to be carried
                    on before the user is actuall enroled. These function's are
                    meant for calling from the Self-Service applications
Known limitations,
enhancements,
remarks            :
Change History
Who      When        What
******************************************************************/
  -- Declare global variables
  g_person_type            igs_pe_usr_arg.person_type%TYPE;
  g_enrollment_category    igs_en_cpd_ext.enrolment_cat%TYPE;
  g_comm_type              igs_en_cpd_ext.s_student_comm_type%TYPE;
  g_method_type            igs_en_cpd_ext.enr_method_type%TYPE;
  g_system_person_type     igs_pe_person_types.system_type%TYPE;

FUNCTION eval_program_steps( p_person_id                        NUMBER,
                             p_person_type                      VARCHAR2,
                             p_load_calendar_type               VARCHAR2,
                             p_load_cal_sequence_number         NUMBER,
                             p_uoo_id                           NUMBER,
                             p_program_cd                       VARCHAR2,
                             p_program_version                  VARCHAR2,
                             p_enrollment_category              VARCHAR2,
                             p_comm_type                        VARCHAR2,
                             p_method_type                      VARCHAR2,
                             p_message                      OUT NOCOPY VARCHAR2,
                             p_deny_warn                    OUT NOCOPY VARCHAR2,
                             p_calling_obj                      IN VARCHAR2) RETURN BOOLEAN
  IS
  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created By   : 19-Jun-2001
  Purpose           : This function is a wrapper function which inturn calls the other
                      functions depending on the enrolment step type defined
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who          When          What
  Nishikant    17OCT2002     the call to the function eval_unit_forced_type has got modified
                             as part of Enrl Elgbl and Validation Build. Bug#2616692
 amuthu      27 -MAY-2002   Commented the eval_max_cp and eval_min_Cp and retuning TRUE value (bug 2389462)
 ayedubat    11-APR-2002    Changed the OPEN cursor statement of cur_program_steps to add an extra 'OR'
                            condition(eru.s_student_comm_type = 'ALL') for s_student_comm_type as part of the bug fix: 2315245
  ******************************************************************/

  -- Ref Cursor is used since the select statement is dependent on the type of the person parameter passed to the function
  -- Record Type is defined so that the cursor Return Type is of this Record Type
  TYPE l_program_steps_rec IS RECORD ( s_enrolment_step_type   igs_en_cpd_ext.s_enrolment_step_type%TYPE,
                                       notification_flag       igs_en_cpd_ext.notification_flag%TYPE,
                                       s_rule_call_cd          igs_en_cpd_ext.s_rule_call_cd%TYPE,
                                       rul_sequence_number     igs_en_cpd_ext.rul_sequence_number%TYPE
                                     );
  TYPE cur_ref_program_steps IS REF CURSOR  RETURN l_program_steps_rec;
  cur_program_steps    cur_ref_program_steps;
  l_cur_program_steps  cur_program_steps%ROWTYPE;

  -- Cursor for getting the actual system person type for the person type that is passed
  CURSOR cur_person_types
  IS
  SELECT system_type
  FROM   igs_pe_person_types
  WHERE  person_type_code = p_person_type;

  -- cursor rowtype variable
  l_cur_person_types        cur_person_types%ROWTYPE;
  l_cur_notification_flag   igs_en_cpd_ext.notification_flag%TYPE;

  -- variables
  l_deny_warn    l_cur_program_steps.notification_flag%TYPE;
  l_return_val   BOOLEAN;
  l_message      VARCHAR2(2000);
  l_upd_cp               IGS_PS_UNIT_VER.POINTS_MAX%TYPE;

  l_deny_prg_steps BOOLEAN;
  l_warn_prg_steps BOOLEAN;
  l_calling_obj      VARCHAR2(2000);
BEGIN
  -- Fetch the system person type for the person type passed
  OPEN  cur_person_types;
  FETCH cur_person_types INTO l_cur_person_types;
  CLOSE cur_person_types;
  -- Assign the package body global variables
  g_person_type          := p_person_type;
  g_system_person_type   := l_cur_person_types.system_type;
  g_enrollment_category  := p_enrollment_category;
  g_comm_type            := p_comm_type;
  g_method_type          := p_method_type;

  IF p_calling_obj = 'REINSTATE' THEN
   l_calling_obj := 'JOB'; --l_calling_obj is used to pass to the validation procedures as the job
                           --validations and reinstate validation is same.
  ELSE
   l_calling_obj := p_calling_obj;
  END IF;

  -- Depending on the person type who has tried to register frame the select statement
  IF g_system_person_type = 'STUDENT' THEN
    OPEN cur_program_steps FOR SELECT eru.s_enrolment_step_type,
                                      eru.notification_flag notification_flag,
                                      eru.s_rule_call_cd,
                                      eru.rul_sequence_number
                               FROM   igs_en_cpd_ext  eru,
                                      igs_lookups_view lkup
                               WHERE  eru.s_enrolment_step_type    =  lkup.lookup_code           AND
                                      eru.enrolment_cat            =  p_enrollment_category      AND
                                     (eru.s_student_comm_type      =  p_comm_type  OR
                                      eru.s_student_comm_type      = 'ALL'           )           AND
                                      eru.enr_method_type          =  p_method_type              AND
                                      lkup.lookup_type             =  'ENROLMENT_STEP_TYPE_EXT'  AND
                                      lkup.step_group_type         =  'PROGRAM'
                               ORDER BY eru.step_order_num;
  ELSE
    OPEN cur_program_steps FOR SELECT eru.s_enrolment_step_type,
                                      DECODE(uact.deny_warn,'WARN','WARN',eru.notification_flag) notification_flag,
                                      eru.s_rule_call_cd,
                                      eru.rul_sequence_number
                               FROM   igs_en_cpd_ext  eru,
                                      igs_pe_usr_aval_all uact,
                                      igs_lookups_view lkup
                               WHERE  eru.s_enrolment_step_type    =  lkup.lookup_code          AND
                                      eru.enrolment_cat            =  p_enrollment_category     AND
                                      eru.enr_method_type          =  p_method_type             AND
                                     (eru.s_student_comm_type      =  p_comm_type OR
                                      eru.s_student_comm_type      = 'ALL'          )           AND
                                      lkup.lookup_type             = 'ENROLMENT_STEP_TYPE_EXT'  AND
                                      lkup.step_group_type         = 'PROGRAM'                  AND
                                      eru.s_enrolment_step_type    =  uact.validation(+)        AND
                                      uact.person_type  (+)        =  p_person_type             AND
                                      NVL(uact. override_ind,'N')  = 'N'
                               ORDER BY eru.step_order_num;
  END IF;

  -- Loop through the records that are fetched into the cursor and do the validations
  LOOP
  l_return_val := NULL;
  l_message := NULL;
  FETCH cur_program_steps INTO l_cur_program_steps;
  EXIT WHEN cur_program_steps%NOTFOUND;

     l_cur_program_steps.notification_flag  := igs_ss_enr_details.get_notification(
            p_person_type               => p_person_type,
            p_enrollment_category       => p_enrollment_category ,
            p_comm_type                 => p_comm_type ,
            p_enr_method_type           => p_method_type ,
            p_step_group_type           => 'PROGRAM',
            p_step_type                 => l_cur_program_steps.s_enrolment_step_type,
            p_person_id                 => p_person_id,
            p_message                   => l_message) ;

    IF l_cur_program_steps.s_enrolment_step_type = 'FMAX_CRDT' THEN

          l_return_val := TRUE;

/*         The max cp validation has to be done before each unit is enrolled
           where as the co-req validation will have to be done for each unit that
           was enrolled once after enrolling all the units in the cart.
           The min cp validationa agian has to be done once for each unit after
           the units have been enrolled  and the changes posted to the database,
           but the difference   for min cp valiudation would be that the credit point value parameter
           must be passed explicitly as 0(ZERO) ( not has null, it must be 0)
           Hence the call the function eval_max_cp has been removed*/

    ELSIF l_cur_program_steps.s_enrolment_step_type = 'FMIN_CRDT' THEN

          l_return_val := TRUE;

/*         The min cp validation has to be done before each unit is enrolled
           where as the co-req validation will have to be done for each unit that
           was enrolled once after enrolling all the units in the cart.
           The min cp validationa agian has to be done once for each unit after
           the units have been enrolled  and the changes posted to the database,
           but the difference   for min cp valiudation would be that the credit point value parameter
           must be passed explicitly as 0(ZERO) ( not has null, it must be 0)
            Hence the call the function eval_min_cp has been removed*/

    ELSIF l_cur_program_steps.s_enrolment_step_type = 'FATD_TYPE' THEN
       -- Call the Forced Attendance credit points validations

         -- Below signature of the call to the function has been modified
         -- as part of Enrl Elgbl and Validation Build. Bug#2616692
       l_return_val := igs_en_elgbl_program.eval_unit_forced_type( p_person_id,
                                                                   p_load_calendar_type,
                                                                   p_load_cal_sequence_number,
                                                                   p_uoo_id,
                                                                   p_program_cd,
                                                                   p_program_version,
                                                                   l_message,
                                                                   l_cur_program_steps.notification_flag,
                                                                   p_enrollment_category,
                                                                   p_comm_type,
                                                                   p_method_type,
                                                                   l_calling_obj
                                                                 );
    ELSIF l_cur_program_steps.s_enrolment_step_type = 'TIME_CFTP' THEN
       -- Call the Time Conflict validations
       l_return_val := igs_en_elgbl_unit.eval_time_conflict( p_person_id,
                                                             p_load_calendar_type,
                                                             p_load_cal_sequence_number,
                                                             p_uoo_id,
                                                             p_program_cd,
                                                             p_program_version,
                                                             l_message,
                                                             l_cur_program_steps.notification_flag,
                                                             l_calling_obj
                                                           );
   ELSIF l_cur_program_steps.s_enrolment_step_type = 'CROSS_LOC' THEN
       l_return_val :=   igs_en_elgbl_program.EVAL_CROSS_VALIDATION(
                                          p_person_id                   => p_person_id,
                                          p_course_cd                   =>  p_program_cd,
                                          p_program_version             => p_program_version,
                                          p_uoo_id                      => p_uoo_id,
                                          p_load_cal_type               =>  p_load_calendar_type,
                                          p_load_ci_sequence_number     => p_load_cal_sequence_number,
                                          p_deny_warn                   => l_cur_program_steps.notification_flag ,
                                          p_upd_cp                      => l_upd_cp ,
                                          p_eligibility_step_type       => 'CROSS_LOC' ,
                                          p_message                     => l_message,
                                          p_calling_obj                 => l_calling_obj);

   ELSIF l_cur_program_steps.s_enrolment_step_type = 'CROSS_FAC' THEN
       l_return_val :=   igs_en_elgbl_program.EVAL_CROSS_VALIDATION(
                                          p_person_id                   => p_person_id,
                                          p_course_cd                   =>  p_program_cd,
                                          p_program_version             => p_program_version,
                                          p_uoo_id                      => p_uoo_id,
                                          p_load_cal_type               =>  p_load_calendar_type,
                                          p_load_ci_sequence_number     => p_load_cal_sequence_number,
                                          p_deny_warn                   => l_cur_program_steps.notification_flag ,
                                          p_upd_cp                      => l_upd_cp ,
                                          p_eligibility_step_type       => 'CROSS_FAC' ,
                                          p_message                     => l_message,
                                          p_calling_obj                 => l_calling_obj);

   ELSIF l_cur_program_steps.s_enrolment_step_type = 'CROSS_MOD' THEN

       l_return_val :=   igs_en_elgbl_program.EVAL_CROSS_VALIDATION(
                                          p_person_id                   => p_person_id,
                                          p_course_cd                   =>  p_program_cd,
                                          p_program_version             => p_program_version,
                                          p_uoo_id                      => p_uoo_id,
                                          p_load_cal_type               =>  p_load_calendar_type,
                                          p_load_ci_sequence_number     => p_load_cal_sequence_number,
                                          p_deny_warn                   => l_cur_program_steps.notification_flag ,
                                          p_upd_cp                      => l_upd_cp ,
                                          p_eligibility_step_type       => 'CROSS_MOD' ,
                                          p_message                     => l_message ,
                                          p_calling_obj                 => l_calling_obj);

    END IF;

    -- code added to handle the system errors for self service pages
    IF l_message IS NOT NULL AND p_calling_obj NOT IN ('JOB', 'REINSTATE') THEN
       p_message := l_message;
       p_deny_warn := 'DENY';
       CLOSE cur_program_steps; -- close the cursor before returning FALSE from the function
       RETURN FALSE;
    END IF;

    -- if the function returns FALSE and the notification flag is DENY then the function returns FALSE
    -- if the function returns FALSE and the notification flag is WARN then the function should continue validating
    IF (l_return_val = FALSE AND l_cur_program_steps.notification_flag='DENY') THEN
      l_deny_prg_steps := TRUE;
      -- set the deny_warn variable value
      p_deny_warn := l_cur_program_steps.notification_flag;
      IF l_message IS NOT NULL AND p_calling_obj IN ('JOB', 'REINSTATE') THEN
        IF p_message IS NULL THEN
          p_message := l_message;
        ELSE
          p_message := p_message||';'||l_message;
        END IF;
        CLOSE cur_program_steps; -- close the cursor before returning FALSE from the function
        RETURN FALSE;
      END IF;
    ELSIF ((l_return_val = FALSE AND l_cur_program_steps.notification_flag='WARN') OR l_return_val = TRUE) THEN

      IF NOT l_return_val THEN
        p_deny_warn := l_cur_program_steps.notification_flag;
        l_warn_prg_steps := TRUE;
      END IF;
       --If calling object is reinstate and any warnings occured in the validation then reintialising the
       --the message string so that only errors will be displayed in the schedule page.
      IF p_calling_obj IN ('REINSTATE') AND p_message IS NOT NULL  THEN
      p_message:= NULL;
      END IF;

      -- Continue Validating without returning from the function
      IF l_message IS NOT NULL AND p_calling_obj IN ('JOB') THEN
        -- for avoiding ';' when the p_message parameter is NULL
        IF p_message IS NULL THEN
          p_message := l_message;
        ELSE
          p_message := p_message||';'||l_message;
        END IF;
      END IF;
    END IF;

  END LOOP;
  CLOSE cur_program_steps;



  l_message := NULL;
  l_cur_notification_flag := NULL;
          -- for getting the notification_flag value for step type 'CO_REQ'
          l_cur_notification_flag  := igs_ss_enr_details.get_notification(
                    p_person_type               => p_person_type,
                    p_enrollment_category       => p_enrollment_category ,
                    p_comm_type                 => p_comm_type ,
                    p_enr_method_type           => p_method_type ,
                    p_step_group_type           => 'UNIT',
                    p_step_type                 => 'COREQ',
                    p_person_id                 => p_person_id,
                    p_message                   => l_message) ;

          IF l_cur_notification_flag IS NOT NULL THEN
            -- Call the Unit credit points co-requisite validations
            l_return_val := igs_en_elgbl_unit.eval_coreq( p_person_id,
                                                          p_load_calendar_type,
                                                          p_load_cal_sequence_number,
                                                          p_uoo_id,
                                                          p_program_cd,
                                                          p_program_version,
                                                          l_message, --(In/Out Parameter)
                                                          l_cur_notification_flag,
                                                          l_calling_obj
                                                        );

               -- code added to handle the system errors for self service pages
             IF l_message IS NOT NULL AND p_calling_obj NOT IN ('JOB','REINSTATE') THEN
               p_message := l_message;
               p_deny_warn := 'DENY';
               RETURN FALSE;
             END IF;

           IF NOT l_return_val THEN

              IF l_message IS NOT NULL AND p_calling_obj IN ('JOB','REINSTATE') THEN
                      -- for avoiding ';' when the p_message parameter is NULL
                      IF p_message IS NULL THEN
                            p_message := l_message;
                      ELSE
                            p_message := p_message||';'||l_message;
                      END IF;
              END IF;-- end of l_message IS NOT NULL AND p_calling_obj = 'JOB'
              p_deny_warn := l_cur_notification_flag;

              IF p_deny_warn = 'DENY'  THEN
                 l_deny_prg_steps := TRUE;
                     IF p_calling_obj IN ('JOB','REINSTATE') THEN
                        RETURN FALSE;
                 END IF;
              ELSE
                    l_warn_prg_steps := TRUE;
              END IF;-- end of p_deny_warn = 'DENY' case
           END IF; -- end of NOT l_return_val if case

          END IF; -- end of l_cur_notification_flag IS NOT NULL


  -- evaluate prereq and incompatible unit steps when called from self service pages

  IF p_calling_obj NOT IN ('JOB','REINSTATE') THEN

            /*********** prereq check ***********/
                  l_cur_notification_flag := NULL;
                  -- for getting the notification_flag value for step type 'CO_REQ'
                  l_cur_notification_flag  := igs_ss_enr_details.get_notification(
                            p_person_type               => p_person_type,
                            p_enrollment_category       => p_enrollment_category ,
                            p_comm_type                 => p_comm_type ,
                            p_enr_method_type           => p_method_type ,
                            p_step_group_type           => 'UNIT',
                            p_step_type                 => 'PREREQ',
                            p_person_id                 => p_person_id,
                            p_message                   => l_message) ;

                  IF l_cur_notification_flag IS NOT NULL THEN
                            -- Call the Unit pre-requisite validation
                            l_message := NULL;
                            l_return_val := igs_en_elgbl_unit.eval_prereq( p_person_id => p_person_id,
                                                                        p_load_cal_type=>  p_load_calendar_type,
                                                                        p_load_sequence_number=>  p_load_cal_sequence_number,
                                                                        p_uoo_id=>  p_uoo_id,
                                                                        p_course_cd=>  p_program_cd,
                                                                        p_course_version=>  p_program_version,
                                                                        p_message=>  l_message, --(In/Out Parameter)
                                                                        p_deny_warn=>  l_cur_notification_flag,
                                                                        p_calling_obj => p_calling_obj
                                                                        );
                                -- system error raised
                            IF l_message IS NOT NULL  THEN
                                    p_message := l_message;
                    p_deny_warn := 'DENY';
                                RETURN FALSE;
                            END IF;

                            IF NOT l_return_val THEN
                                    IF l_cur_notification_flag = 'DENY'  THEN
                                            l_deny_prg_steps := TRUE;
                                    ELSE
                                            l_warn_prg_steps := TRUE;
                                    END IF;
                             END IF;

                  END IF;

         /*********** incompatible check ***********/
                  l_cur_notification_flag := NULL;
          l_message := NULL;
                  -- for getting the notification_flag value for step type 'CO_REQ'
                  l_cur_notification_flag  := igs_ss_enr_details.get_notification(
                            p_person_type               => p_person_type,
                            p_enrollment_category       => p_enrollment_category ,
                            p_comm_type                 => p_comm_type ,
                            p_enr_method_type           => p_method_type ,
                            p_step_group_type           => 'UNIT',
                            p_step_type                 => 'INCMPT_UNT',
                            p_person_id                 => p_person_id,
                            p_message                   => l_message) ;

                  IF l_cur_notification_flag IS NOT NULL THEN
                            -- Call the Unit  incompatible validations
                            l_message := NULL;
                            l_return_val := igs_en_elgbl_unit.eval_incompatible( p_person_id => p_person_id,
                                                                         p_load_cal_type =>   p_load_calendar_type,
                                                                         p_load_sequence_number =>  p_load_cal_sequence_number,
                                                                         p_uoo_id  =>   p_uoo_id,
                                                                         p_course_cd =>  p_program_cd,
                                                                         p_course_version =>   p_program_version,
                                                                         p_message =>  l_message, --(In/Out Parameter)
                                                                         p_deny_warn =>  l_cur_notification_flag,
                                                                         p_calling_obj => p_calling_obj
                                                                        );
                                -- system error raised
                            IF l_message IS NOT NULL  THEN
                                  p_message := l_message;
                  p_deny_warn := 'DENY';
                              RETURN FALSE;
                            END IF;

                            IF NOT l_return_val THEN
                                    p_deny_warn := l_cur_notification_flag;
                                    IF p_deny_warn = 'DENY'  THEN
                                            l_deny_prg_steps := TRUE;
                                    ELSE
                                            l_warn_prg_steps := TRUE;
                                    END IF;
                             END IF;
                  END IF;

  END IF;-- end of p_calling_obj NOT IN ('JOB', 'REINSTATE')

  -- If any of the validations had failed with a deny,

  IF l_deny_prg_steps THEN
     p_deny_warn:= 'DENY';
     RETURN FALSE;
  ELSIF l_warn_prg_steps THEN
     p_deny_warn := 'WARN' ;
     RETURN TRUE;
  END IF;-- end of  l_deny_prg_steps IF

  -- no errors/warnings
  p_deny_warn := NULL;
  RETURN TRUE;

END eval_program_steps;


FUNCTION eval_max_cp ( p_person_id                            NUMBER,
                       p_load_calendar_type                   VARCHAR2,
                       p_load_cal_sequence_number             NUMBER,
                       p_uoo_id                               NUMBER,
                       p_program_cd                           VARCHAR2,
                       p_program_version                      VARCHAR2,
                       p_message                          OUT NOCOPY VARCHAR2,
                       p_deny_warn                            VARCHAR2,
                       p_upd_cp                           IN  NUMBER,
                       p_calling_obj                      IN VARCHAR2
                     ) RETURN BOOLEAN
  IS
  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created By   : 19-Jun-2001
  Purpose           : All the validations for the maximum credit points limit
                      will be done in this funtion
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who        When         What
  ckasu       15-Jul-2005     Modified this function inorder to log warning records in to a warnings Table
                              when called from selefservice pages as a part of EN317 SS UI Build bug#4377985

  smanglm    03-02-2003   call igs_en_gen_017.enrp_get_enr_method to decide enrollment method type
  kkillams   05-11-2002   As part of sevis build, Minimum credit point could be defined at person id group level also.
                          If minimum credit points are not set progression level then check at person id group level,
                          then check it at term/load level. Bug#2641905
  Nishikant  17OCT2002    Enrl Elgbl and Validation Build. Bug#2616692
                          The logic of the code modified such that if the Restricted Enrollment Credit Point is not
                          defined in Progression then check the Maximum CP is overriden at the load calendar level
                          If yes then proceed with the value, If not then proceed to check out NOCOPY whether provided at Program level.
  ayedubat   13-JUN-2002  Added the code to find the enrollment category, commencement type and method type
                          if the eval_max_cp function is directly called from any other package for the bug:2142663
  ayedubat   6-JUN-2002   The function call,Igs_En_Gen_015.get_academic_cal is replaced with
                          Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd to get the academic calendar of the given
                          load calendar rather than current academic calendar for the bug fix: 2381603
  knaraset    As part of ENCR013-modified the calculation of Unit Attempts CP
  myoganat 16-JUN-2003    Bug#  2855870 - Added code to return true in case of an audit attempt. Removed the check before the call to
                                                 IGS_EN_PRC_LOAD.ENRP_CLC_SUA_LOAD.
  vkarthik              22-Jul-2004     Added three dummy variables l_audit_cp, l_billing_cp, l_enrolled_cp for all the calls to
                                                igs_en_prc_load.enrp_clc_sua_load towards EN308 Billable credit points build Enh#3782329
  ******************************************************************/

  -- Ref Cursor is used since the select statement is dependent on the type of the person parameter passed to the function
  -- Record Type is defined so that the cursor Return Type is of this Record Type
  TYPE l_program_steps_rec IS RECORD (rul_sequence_number     igs_en_cpd_ext.rul_sequence_number%TYPE);
  TYPE cur_ref_program_steps IS REF CURSOR  RETURN l_program_steps_rec;   -- Defining the Ref Cursor
  cur_program_steps    cur_ref_program_steps;
  l_cur_program_steps  cur_program_steps%ROWTYPE;   -- cursor Row Type variable

  -- Cursor for getting the Teaching Calendar Type and its Sequence number for the UOO_ID passed
  CURSOR cur_uoo_id
  IS
  SELECT unit_cd, version_number, cal_type, ci_sequence_number
  FROM   igs_ps_unit_ofr_opt
  WHERE  uoo_id = p_uoo_id;

  -- added by ckasu as a part EN317 SS UI  bug#4377985

  CURSOR c_get_override_enr_cp
  IS
  SELECT OVERRIDE_ENROLLED_CP
  FROM IGS_EN_SU_ATTEMPT
  WHERE person_id = p_person_id
  AND   course_cd = p_program_cd
  AND   uoo_id = p_uoo_id;
  -- Cursor Row Type Variables
  l_cur_uoo_id              cur_uoo_id%ROWTYPE;

  -- Table.Column Type Variables
  l_override_limit          igs_pe_persenc_effct.restricted_enrolment_cp%TYPE;
  l_max_cp_allowed          igs_pe_persenc_effct.restricted_enrolment_cp%TYPE;
  l_acad_cal_type           igs_ca_inst.cal_type%TYPE;
  l_acad_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
  l_unit_cp                 igs_ps_unit_ver.enrolled_credit_points%TYPE;
  l_rule_message            igs_ru_item.value%TYPE;
  l_acad_message            VARCHAR2(30);
  l_dummy_c                 VARCHAR2(200);

  -- Variables
  l_return_value            BOOLEAN;
  l_total_exist_cp          NUMBER; -- NUMBER as returned from the function
  l_total_eftsu_cp          NUMBER; -- NUMBER as returned from the function
  l_credit_points           NUMBER;
  l_exclude_cp              NUMBER;
  l_rule_return_value       VARCHAR2(30); -- as returned from Rules function
  l_acad_start_dt           IGS_CA_INST.start_dt%TYPE;
  l_acad_end_dt             IGS_CA_INST.end_dt%TYPE;
  l_alternate_code          IGS_CA_INST.alternate_code%TYPE;
  l_dummy                   NUMBER;
  l_unit_incurred_cp        NUMBER;
  l_effective_date          DATE;
  l_message                 VARCHAR2(2000);
  l_return_status           VARCHAR2(10);
 --dummy variable to pick up audit, billing, enrolled credit points
 --due to signature change by EN308 Billing credit hours Bug 3782329
 l_audit_cp             IGS_PS_USEC_CPS.billing_credit_points%TYPE;
 l_billing_cp           IGS_PS_USEC_CPS.billing_hrs%TYPE;
 l_enrolled_cp  IGS_PS_UNIT_VER.enrolled_credit_points%TYPE;

 l_message_text            VARCHAR2(2000);
 l_message_icon            VARCHAR2(1);

  -- Cursor to get the assessment indicator value.
  CURSOR c_assessment IS
    SELECT no_assessment_ind
     FROM  igs_en_su_attempt
    WHERE  person_id = p_person_id
      AND  course_cd = p_program_cd
      AND  uoo_id = p_uoo_id;

  l_enrol_cal_type              igs_ca_type.cal_type%TYPE;
  l_enrol_sequence_number   igs_ca_inst_all.sequence_number%TYPE;
  l_no_assessment_ind       igs_en_su_attempt.no_assessment_ind%TYPE;


BEGIN

  OPEN c_assessment;
  FETCH c_assessment INTO l_no_assessment_ind;
  CLOSE c_assessment;

    -- Checking if the unit section attempt is an audit attempt, if it is then the function will return TRUE
  IF l_no_assessment_ind = 'Y' THEN
       RETURN TRUE;
 END IF;

  l_return_value := igs_en_gen_015.validation_step_is_overridden ( p_eligibility_step_type => 'FMAX_CRDT',
                                                                   p_load_cal_type         => p_load_calendar_type,
                                                                   p_load_cal_seq_number   => p_load_cal_sequence_number,
                                                                   p_person_id             => p_person_id,
                                                                   p_uoo_id                => p_uoo_id,
                                                                   p_step_override_limit   => l_override_limit
                                                                 );
  IF l_return_value = TRUE THEN
    IF l_override_limit IS NOT NULL THEN
      l_max_cp_allowed := l_override_limit;
    ELSE
      -- If the override limit is not specified, then the function returns TRUE
      RETURN TRUE;
    END IF;
  END IF;

  -- get the teaching calendar type and its sequence number for the uoo_id that is passed into the function
  -- unit code and its version number is also captured
  OPEN  cur_uoo_id;
  FETCH cur_uoo_id INTO l_cur_uoo_id;
  CLOSE cur_uoo_id;


  l_max_cp_allowed := calc_max_cp (
                    p_person_id                    => p_person_id ,
                    p_load_calendar_type           => p_load_calendar_type,
                    p_load_cal_sequence_number     => p_load_cal_sequence_number,
                    p_uoo_id                       => p_uoo_id,
                    p_program_cd                   => p_program_cd,
                    p_program_version              => p_program_version ,
                    p_message                      => p_message  ) ;

  IF l_max_cp_allowed IS NULL AND p_message IS NOT NULL THEN
    RETURN FALSE ;
  ELSIF l_max_cp_allowed IS NULL AND p_message IS NULL THEN
     RETURN TRUE;
  END IF;

  -- get the academic calendar of the given Load Calendar
  --
  l_alternate_code := Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd(
                        p_cal_type                => p_load_calendar_type,
                        p_ci_sequence_number      => p_load_cal_sequence_number,
                        p_acad_cal_type           => l_acad_cal_type,
                        p_acad_ci_sequence_number => l_acad_ci_sequence_number,
                        p_acad_ci_start_dt        => l_acad_start_dt,
                        p_acad_ci_end_dt          => l_acad_end_dt,
                        p_message_name            => l_acad_message );

  -- this code handle  the system errors
  IF l_acad_message IS NOT NULL THEN
     p_message  := l_acad_message;
     RETURN  FALSE;
  END IF; -- end of l_message_name IS NOT NULL THEN


  -- if no academic calendar is defined for the program,person then the function
  -- should return FALSE with the message that was thrown from the above procedure
  IF ( l_acad_cal_type IS NOT NULL AND l_acad_ci_sequence_number IS NOT NULL) THEN

    -- Get the total existing credit points for the Units he has already enrolled for the same academic period
    l_total_eftsu_cp := igs_en_prc_load.enrp_clc_eftsu_total( p_person_id             => p_person_id,
                                                              p_course_cd             => p_program_cd,
                                                              p_acad_cal_type         => l_acad_cal_type,
                                                              p_acad_sequence_number  => l_acad_ci_sequence_number,
                                                              p_load_cal_type         => p_load_calendar_type,
                                                              p_load_sequence_number  => p_load_cal_sequence_number,
                                                              p_truncate_ind          => 'N',
                                                              p_include_research_ind  => 'Y',
                                                              p_key_course_cd         => NULL,
                                                              p_key_version_number    => NULL,
                                                              p_credit_points         => l_total_exist_cp);

    -- If the function returns 'FALSE' then check if Unit Exclusion Step is defined at the enrolment validation form
    -- If it is defined as a step then get the rule sequence id associated for the step type 'UNIT_EXCL'
    -- depending on the person type
    -- removes IF NOT l_return_value THEN as apart of EN317 SS UI Build

      -- Findout the enrollment category of enrollment category is not set
      IF g_enrollment_category IS NULL THEN

         g_enrollment_category := Igs_En_Gen_003.enrp_get_enr_cat(
                                    p_person_id             => p_person_id,
                                    p_course_cd             => p_program_cd,
                                    p_cal_type              => l_acad_cal_type,
                                    p_ci_sequence_number    => l_acad_ci_sequence_number,
                                    p_session_enrolment_cat => NULL,
                                    p_enrol_cal_type        => l_enrol_cal_type ,
                                    p_enrol_ci_sequence_number => l_enrol_sequence_number,
                                    p_commencement_type        => g_comm_type,
                                    p_enr_categories        => l_dummy_c
                                   );

           IF g_comm_type = 'BOTH' THEN
             /* if both is returned we have to treat it as all */
             g_comm_type := 'ALL';
           END IF;

      END IF;

      -- Findout the enrollment method type  of enrollment method type is not set
      IF g_method_type IS NULL THEN

        -- call igs_en_gen_017.enrp_get_enr_method to decide enrollment method type
        igs_en_gen_017.enrp_get_enr_method(
          p_enr_method_type => g_method_type,
          p_error_message   => l_message,
          p_ret_status      => l_return_status);

        -- code added to handle the system errors
        IF l_return_status = 'FALSE' OR l_message IS NOT NULL THEN
           p_message  := l_message;
           RETURN FALSE;
        END IF; -- l_return_status = 'FALSE' OR l_message_name IS NOT NULL THEN

      END IF;

      IF g_system_person_type = 'STUDENT' THEN
        OPEN cur_program_steps FOR SELECT eru.rul_sequence_number rul_sequence_number
                                   FROM   igs_en_cpd_ext  eru,
                                          igs_lookups_view lkup
                                   WHERE  eru.s_enrolment_step_type    =  lkup.lookup_code          AND
                                          eru.s_enrolment_step_type    = 'UNIT_EXCL'                AND
                                          eru.enrolment_cat            =  g_enrollment_category     AND
                                          (eru.s_student_comm_type      =  g_comm_type
                                           OR eru.s_student_comm_type   =  'ALL' )                  AND
                                          eru.enr_method_type          =  g_method_type         AND
                                          lkup.lookup_type             = 'ENROLMENT_STEP_TYPE_EXT'  AND
                                          lkup.step_group_type         = 'PROGRAM'
                                   ORDER BY eru.step_order_num;
      ELSE
        OPEN cur_program_steps FOR SELECT eru.rul_sequence_number rul_sequence_number
                                   FROM   igs_en_cpd_ext  eru,
                                          igs_pe_usr_aval_all uact,
                                          igs_lookups_view lkup
                                   WHERE  eru.s_enrolment_step_type    = lkup.lookup_code AND
                                          lkup.lookup_type             = 'ENROLMENT_STEP_TYPE_EXT'  AND
                                          eru.s_enrolment_step_type    = 'UNIT_EXCL'                AND
                                          eru.enrolment_cat            =  g_enrollment_category     AND
                                          eru.enr_method_type          =  g_method_type         AND
                                          (eru.s_student_comm_type      = g_comm_type
                                          OR eru.s_student_comm_type   =  'ALL' )                   AND
                                          lkup.step_group_type         = 'PROGRAM'                  AND
                                          eru.s_enrolment_step_type    =  uact.validation(+)              AND
                                          uact.person_type  (+)        =  g_person_type             AND
                                          NVL(uact. override_ind,'N')  = 'N'
                                   ORDER BY eru.step_order_num;
      END IF;
      FETCH cur_program_steps INTO l_cur_program_steps;
      CLOSE cur_program_steps;

      -- If there is a rule sequence id associated for the step type 'UNIT_EXCL' then get the total excluded credit points
      IF l_cur_program_steps.rul_sequence_number IS NOT NULL THEN
        BEGIN
          l_rule_return_value := igs_ru_gen_001.rulp_val_senna( p_rule_call_name     => 'UNIT_EXCL',
                                                                p_rule_number        => l_cur_program_steps.rul_sequence_number,
                                                                p_person_id          => p_person_id,
                                                                p_course_cd          => p_program_cd,
                                                                p_course_version     => p_program_version,
                                                                p_unit_cd            => l_cur_uoo_id.unit_cd,
                                                                p_unit_version       => l_cur_uoo_id.version_number,
                                                                p_cal_type           => l_cur_uoo_id.cal_type,
                                                                p_ci_sequence_number => l_cur_uoo_id.ci_sequence_number,
                                                                p_message            => l_rule_message ,
                                                                p_param_1            => p_program_cd,
                                                                p_param_2            => p_program_version
                                                              );
          -- If the function returns 'true' then OUT NOCOPY parameter p_message will have the total exclusion credit points
          IF l_rule_return_value = 'true' THEN
            l_exclude_cp := TO_NUMBER(l_rule_message);
          ELSE
            l_exclude_cp := 0;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            l_exclude_cp := 0;
        END;
      END IF;

  -- added by ckasu as a part of EN317 SS UI changes
  IF p_calling_obj <> 'JOB' THEN
      OPEN  c_get_override_enr_cp;
      FETCH c_get_override_enr_cp INTO l_unit_cp;
      CLOSE c_get_override_enr_cp;
  END IF;
-- Added as part of ENCR013
-- Get the Approved credit points defined in Override Steps Table for the Unit Enrolling.
  l_return_value := igs_en_gen_015.validation_step_is_overridden ( p_eligibility_step_type => 'VAR_CREDIT_APPROVAL',
                                                                   p_load_cal_type         => p_load_calendar_type,
                                                                   p_load_cal_seq_number   => p_load_cal_sequence_number,
                                                                   p_person_id             => p_person_id,
                                                                   p_uoo_id                => p_uoo_id,
                                                                   p_step_override_limit   => l_override_limit
                                                                 );

  IF l_return_value = TRUE THEN
    IF l_override_limit IS NOT NULL THEN
      l_unit_cp := l_override_limit;
    END IF;
  END IF;


      -- Calling below method to get Incurred CP for the Unit, from Override Limit If defined, otherwise from Enrolled CP of Unit.
      -- Added this code as part of bug 2401891
      l_unit_incurred_cp := Igs_En_Prc_Load.enrp_clc_sua_load(
                                                      p_unit_cd => l_cur_uoo_id.unit_cd,
                                                      p_version_number => l_cur_uoo_id.version_number,
                                                      p_cal_type => l_cur_uoo_id.cal_type,
                                                      p_ci_sequence_number => l_cur_uoo_id.ci_sequence_number,
                                                      p_load_cal_type => p_load_calendar_type,
                                                      p_load_ci_sequence_number => p_load_cal_sequence_number,
                                                      p_override_enrolled_cp => l_unit_cp,
                                                      p_override_eftsu => NULL,
                                                      p_return_eftsu => l_dummy,
                                                      p_uoo_id =>p_uoo_id,
                                                      -- anilk, Audit special fee build
                                                      p_include_as_audit => 'N',
                                                      p_audit_cp => l_audit_cp,
                                                      p_billing_cp => l_billing_cp,
                                                      p_enrolled_cp => l_enrolled_cp);


    -- Calculate the total credit points
    l_credit_points := NVL(l_total_exist_cp,0) + NVL(p_upd_cp,NVL(l_unit_incurred_cp,0)) - NVL(l_exclude_cp,0);
    -- If the total credit points calculated are less than or equal to the maximum credit points allowed
    -- then the function returns TRUE

    IF l_credit_points <=  l_max_cp_allowed THEN
      RETURN TRUE;
--added by ckasu as a part of EN317 build
    ELSE
      IF p_deny_warn = 'WARN' THEN
             l_message := 'IGS_SS_WARN_MAX_CP_REACHED';
      ELSE

             IF p_calling_obj = 'SCH_UPD' THEN
                l_message := 'IGS_EN_MAXCP_UPD_DENY'||'*'||l_max_cp_allowed;
             ELSE
                l_message := 'IGS_SS_DENY_MAX_CP_REACHED';
             END IF;-- end of p_calling_obj = 'SCH_UPD'  if then

      END IF; -- end of p_deny_warn = 'WARN' if then

      IF p_calling_obj NOT IN ('JOB','SCH_UPD') THEN

          IF p_deny_warn = 'WARN' THEN
             l_message := 'IGS_EN_MAXCP_TAB_WARN';
          ELSE
             l_message := 'IGS_EN_MAXCP_TAB_DENY';
          END IF; -- end of p_deny_warn = 'WARN' THEN

          -- create a warnings record
          l_message_icon := substr(p_deny_warn,1,1);
          IGS_EN_DROP_UNITS_API.create_ss_warning(p_person_id                    => p_person_id,
                                                  p_course_cd                    => p_program_cd,
                                                  p_term_cal_type                => p_load_calendar_type,
                                                  p_term_ci_sequence_number      => p_load_cal_sequence_number,
                                                  p_uoo_id                       => p_uoo_id,
                                                  p_message_for                  => igs_ss_enroll_pkg.enrf_get_lookup_meaning('FMAX_CRDT','ENROLMENT_STEP_TYPE_EXT'),
                                                  p_message_icon                 => l_message_icon,
                                                  p_message_name                 => l_message,
                                                  p_message_rule_text            => NULL,
                                                  p_message_tokens               => 'UNIT_CD:'||l_max_cp_allowed||';',
                                                  p_message_action               => NULL,
                                                  p_destination                  => NULL,
                                                  p_parameters                   => NULL,
                                                  p_step_type                    => 'PROGRAM');
      ELSE
         p_message :=  l_message;
      END IF; -- end of p_calling_obj NOT IN ('JOB','SCH_UPD') if then

    END IF; -- end of l_credit_points <=  l_max_cp_allowed

  END IF; -- end of ( l_acad_cal_type IS NOT NULL AND l_acad_ci_sequence_number IS NOT NULL)  if then

  IF l_acad_message IS NOT NULL THEN
     p_message := l_acad_message;
  END IF; -- end of l_acad_message IS NOTNULL THEN
  RETURN FALSE;

END eval_max_cp;

FUNCTION eval_min_cp( p_person_id                             NUMBER,
                       p_load_calendar_type                   VARCHAR2,
                       p_load_cal_sequence_number             NUMBER,
                       p_uoo_id                               NUMBER,
                       p_program_cd                           VARCHAR2,
                       p_program_version                      VARCHAR2,
                       p_message                          OUT NOCOPY VARCHAR2,
                       p_deny_warn                            VARCHAR2,
                       p_credit_points                 IN OUT NOCOPY NUMBER,
                       p_enrollment_category           IN     VARCHAR2,
                       p_comm_type                     IN     VARCHAR2,
                       p_method_type                   IN     VARCHAR2,
                       p_min_credit_point              IN OUT NOCOPY NUMBER,
                       p_calling_obj                      IN VARCHAR2
                     ) RETURN BOOLEAN
  IS
  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created By   : 19-Jun-2001
  Purpose           : All the validations for the minimum credit points limit
                      will be done in this funtion
  Known limitations,
  enhancements,
  remarks           :
  Change History
  Who        When        What
  ckasu       15-Jul-2005     Modified this function inorder to log warning records in to a warnings Table
                              when called from selefservice pages as a part of EN317 SS UI Build bug#4377985

  kkillams   05-11-2002  As part of sevis build, Minimum credit point could be defined at person id group level also.
                         If minimum credit points are not set progression level then check at person id group level,
                         then check it at term/load level. Bug#2641905
  Nishikant  17OCT2002   Enrl Elgbl and Validation Build. Bug#2616692
                         The logic of the code modified such that if the Restricted Enrollment Credit Point is not
                         defined in Progression then check the Minimum CP is overriden at the load calendar level
                         If yes then proceed with the value, If not then proceed to check out NOCOPY whether provided at
                         Program level. Also the l_deny_warn variable has been set to DENY or WARN according to the
                         setup of The Minimum Credit Point Validation in the Enrollment Catagory Validation Setup form.
  ayedubat   6-JUN-2002  Replaced the function call,Igs_En_Gen_015.get_academic_cal with
                         Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd to get the academic calendar of the given
                         load calendar rather than current academic calendar for the bug fix: 2381603
  msrinivi    removed the Exclusion functionality in eval_min_cp
  knaraset    As part of ENCR013-modified the calculation of Unit Attempts CP
  myoganat 16-JUN-2003   Bug#  2855870 - Added code to return TRUE incase of an Audit Attempt. Removed the check before the call to
                                                 IGS_EN_PRC_LOAD.ENRP_CLC_SUA_LOAD.
  vkarthik              22-Jul-2004     Added three dummy variables l_audit_cp, l_billing_cp, l_enrolled_cp for all the calls to
                                                igs_en_prc_load.enrp_clc_sua_load towards EN308 Billable credit points build Enh#3782329
  ******************************************************************/

  -- Cursor for getting the Teaching Calendar Type and its Sequence number for the UOO_ID passed
  CURSOR cur_uoo_id
  IS
  SELECT unit_cd, version_number, cal_type, ci_sequence_number
  FROM   igs_ps_unit_ofr_opt
  WHERE  uoo_id = p_uoo_id;

  CURSOR cur_min_cp_config IS
  SELECT ecpd.config_min_cp_valdn, ecpd.enforce_date_alias
  FROM   igs_en_cat_prc_dtl ecpd, igs_en_cpd_ext ecpe
  WHERE  ecpe.s_enrolment_step_type IN ( 'FATD_TYPE' ,  'FMIN_CRDT' ) AND
         ecpe.enrolment_cat         = p_enrollment_category AND
         ecpe.enr_method_type       = p_method_type AND
         (ecpe.s_student_comm_type   = p_comm_type
         OR ecpe.s_student_comm_type   =  'ALL' ) AND
         ecpd.enrolment_cat         = ecpe.enrolment_cat       AND
         ecpd.enr_method_type       = ecpe.enr_method_type     AND
         ecpd.s_student_comm_type   = ecpe.s_student_comm_type AND
         ecpd.config_min_cp_valdn   <> 'NONE';

  CURSOR cur_get_alias_val( l_p_date_alias igs_ca_da_inst_v.dt_alias%TYPE ) IS
  SELECT MIN(di.alias_val)
  FROM   igs_ca_da_inst_v di
  WHERE  di.cal_type           = p_load_calendar_type AND
         di.ci_sequence_number = p_load_cal_sequence_number AND
         di.dt_alias           = l_p_date_alias ;

  -- Cursor to get the assessment indicator value.
  CURSOR c_assessment IS
    SELECT no_assessment_ind
     FROM  igs_en_su_attempt
    WHERE  person_id = p_person_id
      AND  course_cd = p_program_cd
      AND  uoo_id = p_uoo_id;


  -- Cursor Row Type Variables
  l_cur_uoo_id              cur_uoo_id%ROWTYPE;


  -- Below local variable added as part of Enrl Elgbl and Validation Build. Bug#2616692
  l_min_cp_config           cur_min_cp_config%ROWTYPE;

  -- Table.Column Type Variables
  l_override_limit          igs_pe_persenc_effct.restricted_enrolment_cp%TYPE;
  l_min_cp_allowed          igs_pe_persenc_effct.restricted_enrolment_cp%TYPE;
  l_acad_cal_type           igs_ca_inst.cal_type%TYPE;
  l_acad_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
  l_unit_cp                 igs_ps_unit_ver.enrolled_credit_points%TYPE;
  l_rule_message            igs_ru_item.value%TYPE;
  -- Below two local variables added as part of Enrl Elgbl and Validation Build. Bug#2616692

  l_get_alias_val           igs_ca_da_inst_v.alias_val%TYPE;

  -- Variables
  l_return_value            BOOLEAN;
  l_effective_date          DATE;
  l_total_exist_cp          NUMBER; -- As defined in the function
  l_total_eftsu_cp          NUMBER; -- As defined in the function
  l_credit_points           NUMBER; -- clarify
  l_rule_return_value       VARCHAR2(30); -- as returned from Rules function
  l_acad_message            VARCHAR2(30); -- as returned from Get Academic Calendar procedure
  l_acad_start_dt           IGS_CA_INST.start_dt%TYPE;
  l_acad_end_dt             IGS_CA_INST.end_dt%TYPE;
  l_alternate_code          IGS_CA_INST.alternate_code%TYPE;
  l_dummy                   NUMBER;
  l_unit_incurred_cp        NUMBER;
  -- Below local variable added as part of Enrl Elgbl and Validation Build. Bug#2616692
  l_deny_warn               igs_en_cpd_ext_v.notification_flag%TYPE;
  l_no_assessment_ind       igs_en_su_attempt.no_assessment_ind%TYPE;
  --dummy variable to pick up audit, billing, enrolled credit points
  --due to signature change by EN308 Billing credit hours Bug 3782329
  l_audit_cp            IGS_PS_USEC_CPS.billing_credit_points%TYPE;
  l_billing_cp          IGS_PS_USEC_CPS.billing_hrs%TYPE;
  l_enrolled_cp IGS_PS_UNIT_VER.enrolled_credit_points%TYPE;

  l_message                 VARCHAR2(2000);
  l_message_text            VARCHAR2(2000);
  l_message_icon            VARCHAR2(1);

BEGIN

  OPEN c_assessment;
  FETCH c_assessment INTO l_no_assessment_ind;
  CLOSE c_assessment;

    -- Checking if the unit section attempt is an audit attempt, if it is then the function will return TRUE
  IF l_no_assessment_ind = 'Y' THEN
      RETURN TRUE;
  END IF;

  l_return_value := igs_en_gen_015.validation_step_is_overridden ( p_eligibility_step_type => 'FMIN_CRDT',
                                                                   p_load_cal_type         => p_load_calendar_type,
                                                                   p_load_cal_seq_number   => p_load_cal_sequence_number,
                                                                   p_person_id             => p_person_id,
                                                                   p_uoo_id                => p_uoo_id,
                                                                   p_step_override_limit   => l_override_limit
                                                                 );

  IF l_return_value = TRUE THEN
    IF l_override_limit IS NOT NULL THEN
      l_min_cp_allowed := l_override_limit;
    ELSE
       RETURN TRUE;
    END IF;
  END IF;


  -- get the teaching calendar type and its sequence number for the uoo_id that is passed into the function
  -- unit code and its version number is also captured
  OPEN  cur_uoo_id;
  FETCH cur_uoo_id INTO l_cur_uoo_id;
  CLOSE cur_uoo_id;

  l_min_cp_allowed := calc_min_cp (
                    p_person_id                    => p_person_id ,
                    p_load_calendar_type           => p_load_calendar_type,
                    p_load_cal_sequence_number     => p_load_cal_sequence_number,
                    p_uoo_id                       => p_uoo_id,
                    p_program_cd                   => p_program_cd,
                    p_program_version              => p_program_version ,
                    p_message                      => p_message  ) ;

  IF l_min_cp_allowed IS NULL AND p_message IS NOT NULL THEN
    RETURN FALSE ;
  ELSIF l_min_cp_allowed IS NULL AND p_message IS NULL THEN
     RETURN TRUE;
  END IF;

     -- get the academic calendar of the gievn load calendar
     -- clarify if this function returns a value ,
     -- if not there is a place in the function which returns a value, confirm the function name
     l_alternate_code := Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd(
                           p_cal_type                => p_load_calendar_type,
                           p_ci_sequence_number      => p_load_cal_sequence_number,
                           p_acad_cal_type           => l_acad_cal_type,
                           p_acad_ci_sequence_number => l_acad_ci_sequence_number,
                           p_acad_ci_start_dt        => l_acad_start_dt,
                           p_acad_ci_end_dt          => l_acad_end_dt,
                           p_message_name            => l_acad_message );

      -- this code handle  the system errors
      IF l_acad_message IS NOT NULL THEN
         p_message  := l_acad_message;
         RETURN  FALSE;
      END IF; -- end of l_message_name IS NOT NULL THEN


     -- if no academic calendar is defined for the program,person then the function
     -- should return FALSE
     IF ( l_acad_cal_type IS NOT NULL AND l_acad_ci_sequence_number IS NOT NULL) THEN
         -- Get the total existing credit points for the Units he has already enrolled for the same academic period
         l_total_eftsu_cp := igs_en_prc_load.enrp_clc_eftsu_total( p_person_id             => p_person_id,
                                                                 p_course_cd             => p_program_cd,
                                                                 p_acad_cal_type         => l_acad_cal_type,
                                                                 p_acad_sequence_number  => l_acad_ci_sequence_number,
                                                                 p_load_cal_type         => p_load_calendar_type,
                                                                 p_load_sequence_number  => p_load_cal_sequence_number,
                                                                 p_truncate_ind          => 'N',
                                                                 p_include_research_ind  => 'Y',
                                                                 p_key_course_cd         => NULL,
                                                                 p_key_version_number    => NULL,
                                                                 p_credit_points         => l_total_exist_cp
                                                               );

         -- Added As part of ENCR013
         -- Get the Approved credit points defined in Override Steps Table for the Unit Enrolling.
         l_return_value := igs_en_gen_015.validation_step_is_overridden ( p_eligibility_step_type => 'VAR_CREDIT_APPROVAL',
                                                                      p_load_cal_type         => p_load_calendar_type,
                                                                      p_load_cal_seq_number   => p_load_cal_sequence_number,
                                                                      p_person_id             => p_person_id,
                                                                      p_uoo_id                => p_uoo_id,
                                                                      p_step_override_limit   => l_override_limit
                                                                    );

         IF l_return_value = TRUE THEN
            IF l_override_limit IS NOT NULL THEN
               l_unit_cp := l_override_limit;
            END IF;
         END IF;


             -- Calling below method to get Incurred CP for the Unit, from Override Limit If defined, otherwise from Enrolled CP of Unit.
             -- Added this code as part of bug 2401891
             l_unit_incurred_cp := Igs_En_Prc_Load.enrp_clc_sua_load(
                                                         p_unit_cd => l_cur_uoo_id.unit_cd,
                                                         p_version_number => l_cur_uoo_id.version_number,
                                                         p_cal_type => l_cur_uoo_id.cal_type,
                                                         p_ci_sequence_number => l_cur_uoo_id.ci_sequence_number,
                                                         p_load_cal_type => p_load_calendar_type,
                                                         p_load_ci_sequence_number => p_load_cal_sequence_number,
                                                         p_override_enrolled_cp => l_unit_cp,
                                                         p_override_eftsu => NULL,
                                                         p_return_eftsu => l_dummy,
                                                         p_uoo_id=>p_uoo_id,
                                                         -- anilk, Audit special fee build
                                                         p_include_as_audit => 'N',
                                                         p_audit_cp => l_audit_cp,
                                                         p_billing_cp => l_billing_cp,
                                                         p_enrolled_cp => l_enrolled_cp);

         -- Calculate the total credit points
         -- msrinivi Added this chnge to check if cp parameter is null,else take l_unit_cp
         l_credit_points := NVL(l_total_exist_cp,0) + NVL(p_credit_points,NVL(l_unit_incurred_cp,0)) ;

         -- If the total credit points calculated are greater than the minimum credit points allowed
         -- and its not called from the eval_unit_forced_type function then the function returns TRUE

         IF l_credit_points >=  l_min_cp_allowed THEN
             p_credit_points := l_credit_points;
             p_min_credit_point := l_min_cp_allowed;
             RETURN TRUE;
         END IF;

     END IF;   -- IF ( l_acad_cal_type IS NOT NULL AND l_acad_ci_sequence_number IS NOT NULL) THEN

     l_deny_warn := p_deny_warn ;
    --Open the cursor defined to find out NOCOPY whether Minimum CP overriden at term level
    OPEN cur_min_cp_config;
    FETCH cur_min_cp_config INTO l_min_cp_config;
    -- If the Min CP is not Overriden at Load Calendar level OR
    -- The Minimum Credit Point Validation is set as the default value 'Every Time' in the Enrollment Catagory
    -- Validation Setup form OR p_deny_warm parameter contains the value DENY_QUERY or WARN_QUERY, which means
    -- the function has been invoked from the form 'Minimum Credit Point Query' then proceed

    IF cur_min_cp_config%NOTFOUND
       OR p_deny_warn IN ('DENY_QUERY', 'WARN_QUERY') THEN --(proceed with the existing functionality)
        CLOSE cur_min_cp_config;
        -- As the parameter p_credit_points made as IN/OUT to have the value of the valriable l_credit_points
        p_credit_points := l_credit_points; -- Totall enrolled Credit Points are returned.
        -- If p_deny_warn is DENY_QUERY then make it DENY and If it is WARN_QUERY make it WARN.
        IF p_deny_warn IN ('DENY_QUERY', 'WARN_QUERY') THEN
            l_deny_warn := SUBSTR(p_deny_warn, 1, 4);
        END IF;

    ELSE  -- Else part of IF cur_min_cp_config%NOTFOUND OR l_min_cp_config.config_min_cp_valdn = 'NONE'.
        CLOSE cur_min_cp_config;
       -- If the Minimum Credit Point has been overirden at Load calendar level AND the The Minimum Credit
       -- Point Validation is set as the other than default value 'Every Time' in the Enrollment Catagory Validation Setup form
       -- AND this function is not invoked from the form 'Minimum Credit Point Query' then Proceed

       -- If the Minimum Credit Point Validation is configured as 'Enforce When First Reached Minimum Credit Point'
       IF l_min_cp_config.config_min_cp_valdn = 'MINCPREACH' THEN
          IF p_min_credit_point IS NOT NULL THEN
             l_credit_points := p_min_credit_point;
          END IF;
          IF l_credit_points >= l_min_cp_allowed THEN
             l_deny_warn := 'DENY';
          ELSE
             l_deny_warn := 'WARN';
          END IF;

       -- If the Minimum Credit Point Validation is set as 'Enforce by Date Only'
       ELSIF l_min_cp_config.config_min_cp_valdn = 'DTALIASRCH' THEN  --Else part of 'IF l_min_cp_config.config_min_cp_valdn = 'MINCPREACH' THEN'

          --open the cursor cur_get_alias_val which will fetch the minimum of the Alias value for the date alias provided
          OPEN cur_get_alias_val( l_min_cp_config.enforce_date_alias);
          FETCH cur_get_alias_val INTO l_get_alias_val;
          CLOSE cur_get_alias_val;

          --If the date alias defined for the Calendar Instance then
          IF l_get_alias_val IS NOT NULL THEN
             --If the alias value has been reached then p_deny_warn is DENY else WARN
             IF TRUNC(l_get_alias_val) <= TRUNC(SYSDATE) THEN
                l_deny_warn := 'DENY';
             ELSE
                l_deny_warn := 'WARN';
             END IF;
          -- If the Date alias is not defined for the Calendar Instance then p_deny_wan is WARN
          ELSE
             RETURN TRUE;
          END IF;

       END IF;   --  IF l_min_cp_config.config_min_cp_valdn = 'MINCPREACH' THEN
    END IF;   --cur_min_cp_config%NOTFOUND OR l_min_cp_config.config_min_cp_valdn = 'NONE'

 IF l_deny_warn = 'WARN' THEN

    IF p_calling_obj = 'DROP' THEN
       l_message := 'IGS_SS_EN_MINIMUM_CP_WARN';
    ELSIF p_calling_obj = 'JOB' THEN
       l_message := 'IGS_SS_WARN_MIN_CP_REACHED';
    END IF; -- end of p_calling_obj = 'SCH_UPD'

 ELSE

    IF p_calling_obj = 'SCH_UPD' THEN
       l_message := 'IGS_EN_MINCP_UPD_DENY'||'*'||l_min_cp_allowed;
    ELSIF p_calling_obj = 'DROP' THEN
       l_message := 'IGS_SS_EN_MINIMUM_CP_DENY';
    ELSIF p_calling_obj = 'JOB' THEN
       l_message := 'IGS_SS_DENY_MIN_CP_REACHED';
    END IF; -- end of p_calling_obj = 'SCH_UPD'


 END IF; -- end of l_deny_warn = 'WARN' IF THEN

 IF p_calling_obj NOT IN ('JOB','DROP','SCH_UPD') THEN

     IF p_deny_warn = 'WARN' THEN
        l_message := 'IGS_EN_MINCP_TAB_WARN';
     ELSE
        l_message := 'IGS_EN_MINCP_TAB_DENY';
     END IF; -- end of p_deny_warn = 'WARN' THEN

     l_message_icon := substr(l_deny_warn,1,1);
      -- create a warnings record
      IGS_EN_DROP_UNITS_API.create_ss_warning(p_person_id                => p_person_id,
                                              p_course_cd                => p_program_cd,
                                              p_term_cal_type            => p_load_calendar_type,
                                              p_term_ci_sequence_number  => p_load_cal_sequence_number,
                                              p_uoo_id                   => p_uoo_id,
                                              p_message_for              => igs_ss_enroll_pkg.enrf_get_lookup_meaning('FMIN_CRDT','ENROLMENT_STEP_TYPE_EXT'),
                                              p_message_icon             => l_message_icon,
                                              p_message_name             => l_message,
                                              p_message_rule_text        => NULL,
                                              p_message_tokens           => 'UNIT_CD:'||l_min_cp_allowed||';',
                                              p_message_action           => NULL,
                                              p_destination              => NULL,
                                              p_parameters               => NULL,
                                              p_step_type                => 'PROGRAM');
 ELSE
     p_message :=  l_message;
 END IF; -- end of p_calling_obj NOT IN ('JOB','SCH_UPD') if then


  p_credit_points := l_credit_points;
  p_min_credit_point := l_min_cp_allowed;
  RETURN FALSE;

END eval_min_cp;

FUNCTION eval_unit_forced_type( p_person_id                 NUMBER,
                                p_load_calendar_type        VARCHAR2,
                                p_load_cal_sequence_number  VARCHAR2,
                                p_uoo_id                    NUMBER,
                                p_course_cd                 VARCHAR2,
                                p_course_version            VARCHAR2,
                                p_message               OUT NOCOPY VARCHAR2,
                                p_deny_warn                 VARCHAR2,
                                p_enrollment_category   IN  VARCHAR2,
                                p_comm_type             IN  VARCHAR2,
                                p_method_type           IN  VARCHAR2,
                                p_calling_obj           IN VARCHAR2
                              ) RETURN BOOLEAN
AS
  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created By   : 19-Jun-2001
  Purpose           : This function validates the program attempt mode against
                      program offering option restriction
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who        When            What
  ckasu       15-Jul-2005     Modified this function inorder to log warning records in to a warnings Table
                              when called from selefservice pages as a part of EN317 SS UI Build bug#4377985

  stutta    18-NOV-2003  Replaced the cursor, which retrieves coo_id from program attempt table, with a call to
                         terms api function to return coo_id. Done as part of Term Records Build.
  svenkata    21-Jan-03  Modified the routine as part of Bug# 2750538 to validate Attendance Type when Min CP Configuration does not exist.
  svenkata    7-Jan-03   Incorporated the logic for 'When first Reach Attendance Type'. The value of p_deny_warn has a value of AttTypReached / AttTypNotReached
                         if called from Drop Unit section / Update Unit section CP / Transfer unit section.-Bug#2737263.If this parameter has a value and a Min CP
                         config exists for 'When First Reach Min CP' , then DENY/WARN is determined programatically based on whether the Att Typ has already been rchd.
  Nishikant  17OCT2002   Enrl Elgbl and Validation Build. Bug#2616692.
                         The Logic modified to check first whether Min CP is Overriden at Load Calendar level
                         then call eval_min_cp and set DENY or WARN messages accordingly.
  ayedubat  6-JUN-2002   Replaced the function call,Igs_En_Gen_015.get_academic_cal with
                       Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd to get the academic calendar of the given
                       load calendar rather than current academic calendar for the bug fix: 2381603
myoganat 16-JUN-2003    Bug# 2855870 Added cursor c_assessment to check for an audit attempt and if it is, the function
                                                   will return TRUE.
  ******************************************************************/

  -- cursor for getting all the program offering option of all the active program attempts
  -- modified the WHERE clause to add condition course_cd = p_course_cd and removed course_attempt_status condition.

  -- Cursor to fetch the Date Alias value.
  CURSOR cur_get_alias_val( l_p_date_alias igs_ca_da_inst_v.dt_alias%TYPE ) IS
  SELECT MIN(di.alias_val)
  FROM   igs_ca_da_inst_v di
  WHERE  di.cal_type           = p_load_calendar_type AND
         di.ci_sequence_number = p_load_cal_sequence_number AND
         di.dt_alias           = l_p_date_alias ;

  -- Below cursor added as part of Enrl Elgbl and Validation Build. Bug#2616692
  CURSOR cur_min_cp_config IS
  SELECT ecpd.config_min_cp_valdn, ecpd.enforce_date_alias
  FROM   igs_en_cat_prc_dtl ecpd, igs_en_cpd_ext ecpe
  WHERE  ecpe.s_enrolment_step_type IN  ( 'FATD_TYPE' ,  'FMIN_CRDT' ) AND
         ecpe.enrolment_cat         = p_enrollment_category AND
         ecpe.enr_method_type       = p_method_type AND
         (ecpe.s_student_comm_type   = p_comm_type
         OR ecpe.s_student_comm_type   =  'ALL' ) AND
         ecpd.enrolment_cat         = ecpe.enrolment_cat       AND
         ecpd.enr_method_type       = ecpe.enr_method_type     AND
         ecpd.s_student_comm_type   = ecpe.s_student_comm_type AND
         ecpd.config_min_cp_valdn   <> 'NONE';


 -- Cursor to get the assessment indicator value.
  CURSOR c_assessment IS
     SELECT no_assessment_ind
     FROM  igs_en_su_attempt
     WHERE  person_id = p_person_id
      AND  course_cd = p_course_cd
      AND  uoo_id = p_uoo_id;

  -- added by ckasu as a part of EN317 SS UI Build bug#4377985
   CURSOR c_get_att_type(p_coo_id IGS_PS_OFR_OPT.coo_id%TYPE) IS
      SELECT attendance_type
      FROM IGS_PS_OFR_OPT
      WHERE coo_id = p_coo_id;



  -- Cursor ROWTYPE variables
  l_min_cp_config  cur_min_cp_config%ROWTYPE;
  l_person_type igs_pe_typ_instances.person_type_code%TYPE;
   l_no_assessment_ind       igs_en_su_attempt.no_assessment_ind%TYPE;

  -- Table.Column Type Variables
  l_coo_id  igs_en_stdnt_ps_att.coo_id%TYPE;
  l_override_limit          igs_en_elgb_ovr_step.step_override_limit%TYPE; -- should be NUMBER(6,3) Instead of NUMBER(5,3)
  l_acad_cal_type           igs_ca_inst.cal_type%TYPE;
  l_acad_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
  l_get_alias_val           igs_ca_da_inst_v.alias_val%TYPE;

  -- Variables
  l_return_value            BOOLEAN;
  l_message_name            VARCHAR2(30);  -- As returned from the function igs_en_val_sca.enrp_val_coo_att
  l_attendance_types        VARCHAR2(100); -- As returned from the function igs_en_val_sca.enrp_val_coo_att
  l_acad_message            VARCHAR2(30);  -- as reutrned from the procedure Get Academic Calendar
  l_acad_start_dt           IGS_CA_INST.start_dt%TYPE;
  l_acad_end_dt             IGS_CA_INST.end_dt%TYPE;
  l_alternate_code          IGS_CA_INST.alternate_code%TYPE;
  --Below Three variables added as part of Enrl Elgbl and Validation Build. Bug#2616692
  l_credit_points           igs_en_config_enr_cp.min_cp_per_term%TYPE;
  l_min_credit_point        igs_en_config_enr_cp.min_cp_per_term%TYPE;
  l_deny_warn               VARCHAR2(20);

  l_att_type                IGS_PS_OFR_OPT.ATTENDANCE_TYPE%TYPE;

  l_message                 VARCHAR2(2000);
  l_message_icon            VARCHAR2(1);

BEGIN

  OPEN c_assessment;
  FETCH c_assessment INTO l_no_assessment_ind;
  CLOSE c_assessment;

    -- Checking if the unit section attempt is an audit attempt, if it is then the function will return TRUE
  IF l_no_assessment_ind = 'Y' THEN
      RETURN TRUE;
  END IF;

  -- Checking if the step is overriden, if it is overriden then the function will return TRUE
  l_return_value :=igs_en_gen_015.validation_step_is_overridden ( p_eligibility_step_type => 'FATD_TYPE',
                                                                  p_load_cal_type         => p_load_calendar_type,
                                                                  p_load_cal_seq_number   => p_load_cal_sequence_number,
                                                                  p_person_id             => p_person_id,
                                                                  p_uoo_id                => p_uoo_id,
                                                                  p_step_override_limit   => l_override_limit
                                                                 );
  IF l_return_value THEN
    RETURN TRUE;
  END IF;

  -- get the academic calendar of the given Load Calendar
  -- clarify if this function returns a value , if not there is a place in the function which returns a value, confirm the function name
      l_alternate_code := Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd(
                        p_cal_type                => p_load_calendar_type,
                        p_ci_sequence_number      => p_load_cal_sequence_number,
                        p_acad_cal_type           => l_acad_cal_type,
                        p_acad_ci_sequence_number => l_acad_ci_sequence_number,
                        p_acad_ci_start_dt        => l_acad_start_dt,
                        p_acad_ci_end_dt          => l_acad_end_dt,
                        p_message_name            => l_acad_message );

  -- if no academic calendar is defined for the program,person then the function
  -- should return FALSE with the message that was thrown from the above procedure
      IF ( l_acad_cal_type IS NOT NULL AND l_acad_ci_sequence_number IS NOT NULL) THEN
    -- validate the attendance type of the program offering option of the active program attempts

        l_coo_id := igs_en_spa_terms_api.get_spat_coo_id( p_person_id => p_person_id,
                                p_program_cd => p_course_cd,
                                p_term_cal_type => p_load_calendar_type,
                                p_term_sequence_number => p_load_cal_sequence_number);
        l_return_value := igs_en_val_sca.enrp_val_coo_att(p_person_id          => p_person_id,
                                                      p_coo_id             => l_coo_id,
                                                      p_cal_type           => l_acad_cal_type,
                                                      p_ci_sequence_number => l_acad_ci_sequence_number,
                                                      p_message_name       => l_message_name,
                                                      p_attendance_types   => l_attendance_types,
                                                      p_load_or_teach_cal_type => p_load_calendar_type,
                                                      p_load_or_teach_seq_number => p_load_cal_sequence_number
                                                     );
        IF l_return_value THEN
           RETURN TRUE;
        END IF;

      END IF;

  l_deny_warn := p_deny_warn;
  OPEN cur_min_cp_config;
  FETCH cur_min_cp_config INTO l_min_cp_config;

  IF cur_min_cp_config%FOUND THEN

        CLOSE cur_min_cp_config;

        -- The MIn CP is configured for Date Alias,then call eval_min_cp to check if the Date Alias has already been reached.
        IF l_min_cp_config.config_min_cp_valdn = 'DTALIASRCH' THEN
          OPEN cur_get_alias_val( l_min_cp_config.enforce_date_alias);
          FETCH cur_get_alias_val INTO l_get_alias_val;
          CLOSE cur_get_alias_val;

          --If the date alias defined for the Calendar Instance then
          IF l_get_alias_val IS NOT NULL THEN
             --If the alias value has been reached then p_deny_warn is DENY else WARN
             IF TRUNC(l_get_alias_val) <= TRUNC(SYSDATE) THEN
                l_deny_warn := 'DENY';
             ELSE
                l_deny_warn := 'WARN';
             END IF;

          -- If the Date alias is not defined for the Calendar Instance then return TRUE.
          ELSE
             RETURN TRUE;
          END IF;

        ELSIF l_min_cp_config.config_min_cp_valdn = 'MINCPREACH' THEN

            -- If Min CP is configured for 'When First Reach Min CP', check if the student has already reached the Attendance Type of the Program.If the Attendance Type
            -- has already reached, DENY the user from dropping below the Forced Attendance Type.The parameter p_deny_warn can have these values only when it is being called
            -- from Transfer section workflow/Update CP/Drop Units.
            IF p_deny_warn = 'AttTypReached' THEN
                l_deny_warn := 'DENY' ;
            ELSIF  p_deny_warn = 'AttTypNotReached' THEN
                l_deny_warn := 'WARN' ;
            END IF ;

        END IF ;
    ELSE
        l_person_type := igs_en_gen_008.enrp_get_person_type(p_course_cd => NULL );

        l_deny_warn  := igs_ss_enr_details.get_notification(
            p_person_type               => l_person_type,
            p_enrollment_category       => p_enrollment_category ,
            p_comm_type                 => p_comm_type ,
            p_enr_method_type           => p_method_type ,
            p_step_group_type           => 'PROGRAM',
            p_step_type                 => 'FATD_TYPE',
            p_person_id                 => p_person_id,
            p_message                   => l_message_name) ;

    END IF ;

  -- code added by ckasu as a part of EN317 SS Build bug# 4377985
  OPEN c_get_att_type(l_coo_id);
  FETCH c_get_att_type INTO l_att_type;
  CLOSE c_get_att_type;

  IF l_deny_warn ='WARN' THEN

    IF p_calling_obj = 'DROP' THEN
       l_message := 'IGS_SS_EN_ATT_TYP_WARN';
    ELSIF p_calling_obj = 'JOB' THEN
       l_message := 'IGS_SS_WARN_ATTYPE_CHK';
    END IF; -- end of p_calling_obj = 'SCH_UPD'

  ELSE

    IF p_calling_obj = 'SCH_UPD' THEN
       l_message := 'IGS_EN_ATTYPE_UPD_DENY' ||'*'||l_att_type;
    ELSIF p_calling_obj = 'DROP' THEN
       l_message := 'IGS_SS_EN_ATT_TYP_DENY';
    ELSIF p_calling_obj = 'JOB' THEN
       l_message := 'IGS_SS_DENY_ATTYPE_CHK';
    END IF; -- end of p_calling_obj = 'SCH_UPD'

  END IF; -- end of l_deny_warn ='WARN' IF THEN

  IF p_calling_obj NOT IN ('JOB','DROP','SCH_UPD') THEN

     IF p_deny_warn = 'WARN' THEN
        l_message := 'IGS_EN_ATTYPE_TAB_WARN';
     ELSE
        l_message := 'IGS_EN_ATTYPE_TAB_DENY';
     END IF; -- end of p_deny_warn = 'WARN' THEN

     l_message_icon := substr(l_deny_warn,1,1);
     -- create a warnings record
     IGS_EN_DROP_UNITS_API.create_ss_warning(p_person_id                 => p_person_id,
                                             p_course_cd                 => p_course_cd,
                                             p_term_cal_type             => p_load_calendar_type,
                                             p_term_ci_sequence_number   => p_load_cal_sequence_number,
                                             p_uoo_id                    => p_uoo_id,
                                             p_message_for               => igs_ss_enroll_pkg.enrf_get_lookup_meaning('FATD_TYPE','ENROLMENT_STEP_TYPE_EXT'),
                                             p_message_icon              => l_message_icon,
                                             p_message_name              => l_message,
                                             p_message_rule_text         => NULL,
                                             p_message_tokens            => 'UNIT_CD:'||l_att_type||';',
                                             p_message_action            => NULL,
                                             p_destination               => NULL,
                                             p_parameters                => NULL,
                                             p_step_type                 => 'PROGRAM');
  ELSE
     p_message :=  l_message;
  END IF; -- end of p_calling_obj NOT IN ('JOB','SCH_UPD') if then

  -- end of code adde dby ckasu as a part of bug# 4377985

 RETURN FALSE;

END eval_unit_forced_type;

FUNCTION eval_fail_min_cp(
     p_person_id                NUMBER,
     p_course_cd                VARCHAR2,
     p_version_number           NUMBER,
     p_acad_cal                 VARCHAR2,
     p_load_cal                 VARCHAR2,
     p_load_ci_sequence_number  NUMBER,
     p_method                   VARCHAR2) RETURN VARCHAR2
AS
  /******************************************************************
  Created By        : Nishikant
  Date Created By   : 21OCT2002
  Purpose           : This function is introduced in Enrollment Eligibility
             and Validation Build. Bug#2616692. This function is being used
             in a cursor in the form IGSEN076. This function calls the function
             eval_min_cp for each ACTIVE unit attempt of the student and
             returns TRUE or FALSE.
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who             When        What
  ckasu       15-Jul-2005     Modified this function inorder to add new parameter p_calling_obj
                              as a part of EN317 SS UI Build bug#4377985
  ******************************************************************/

  CURSOR c_acad_cal IS
  SELECT sup_ci_sequence_number
  FROM   igs_ca_inst_rel
  WHERE  sub_cal_type = p_load_cal AND
         sub_ci_sequence_number = p_load_ci_sequence_number AND
         sup_cal_type = p_acad_cal;

  CURSOR c_chk_min_cp_valdn( p_enrl_cat  igs_en_cat_prc_dtl.enrolment_cat%TYPE,
                             p_enr_meth_type  igs_en_method_type.enr_method_type%TYPE,
                             p_s_stdnt_comm_type  VARCHAR2) IS
  SELECT notification_flag
  FROM   igs_en_cpd_ext
  WHERE  enrolment_cat = p_enrl_cat
  AND    enr_method_type = p_enr_meth_type
  AND    s_enrolment_step_type = 'FMIN_CRDT'
  AND    (s_student_comm_type = p_s_stdnt_comm_type OR
          s_student_comm_type = 'ALL');

  CURSOR c_get_unit_attmpt IS
  SELECT DISTINCT uoo_id
  FROM   igs_en_su_attempt sua,
         igs_ca_load_to_teach_v ltt
  WHERE  sua.person_id = p_person_id
  AND    sua.course_cd = p_course_cd
  AND    sua.unit_attempt_status = 'ENROLLED'
  AND    sua.cal_type = ltt.teach_cal_type
  AND    sua.ci_sequence_number = ltt.teach_ci_sequence_number
  AND    ltt.load_cal_type = p_load_cal
  AND    ltt.load_ci_sequence_number = p_load_ci_sequence_number ;

  l_acad_ci_seq_number    igs_ca_inst_rel.sup_ci_sequence_number%TYPE;
  l_commencement_type     VARCHAR2(10);
  l_enrollment_cat        igs_en_cat_prc_dtl.enrolment_cat%TYPE;
  l_enrol_cal_type        igs_ca_inst_all.cal_type%TYPE;
  l_enrol_sequence_number igs_ca_inst_all.sequence_number%TYPE;
  l_notification_flag     igs_en_cpd_ext.notification_flag%TYPE;
  l_message               fnd_new_messages.message_name%TYPE;
  l_credit_points         igs_en_config_enr_cp.min_cp_per_term%TYPE;
  l_min_credit_point      igs_en_config_enr_cp.min_cp_per_term%TYPE;
  l_ret_value             BOOLEAN;
  l_dummy                 VARCHAR2(200);

BEGIN
   --Getting the sequence number of the passed parameter Acad Calendar Type.
   OPEN c_acad_cal;
   FETCH c_acad_cal INTO l_acad_ci_seq_number;
   CLOSE c_acad_cal;

   --Calling the below function to get the values Enrollment Category, Commencement Type
   l_enrollment_cat := igs_en_gen_003.enrp_get_enr_cat
                         ( p_person_id => p_person_id,
                           p_course_cd => p_course_cd,
                           p_cal_type => p_acad_cal,
                           p_ci_sequence_number => l_acad_ci_seq_number,
                           p_session_enrolment_cat =>NULL,
                           p_enrol_cal_type => l_enrol_cal_type,
                           p_enrol_ci_sequence_number => l_enrol_sequence_number,
                           p_commencement_type => l_commencement_type,
                           p_enr_categories  => l_dummy
                          );
   --If Commencement Type is BOTH is returned we have to treat it as ALL
   IF l_commencement_type = 'BOTH' THEN
          l_commencement_type := 'ALL';
   END IF;

   OPEN c_chk_min_cp_valdn(l_enrollment_cat, p_method, l_commencement_type);
   FETCH c_chk_min_cp_valdn INTO l_notification_flag;
   -- If Min CP validation is defined as a step in the Enrollment Category of the Student then
   -- Proceed inside the If Block.
   IF c_chk_min_cp_valdn%FOUND THEN
      -- We have to pass the value of the variable l_notificetion_flag as either DENY_QUERY or WARN_QUERY
      -- to the function call eval_min_cp.
      IF l_notification_flag = 'DENY' THEN
          l_notification_flag := 'DENY_QUERY';
      ELSIF l_notification_flag = 'WARN' THEN
          l_notification_flag := 'WARN_QUERY';
      END IF;

      -- For each ACTIVE Unit Attempted by the student loop through the block untill the function call
      -- eval_min_cp returns TRUE
      FOR l_cur_uoo_id IN c_get_unit_attmpt
      LOOP
          l_credit_points := NULL;
          l_min_credit_point := NULL;
          -- Call eval_min_cp function for each unit attempt, if it returns FALSE then no need to proceed
          -- further for the rest of the units. Return FALSE.
          l_ret_value := eval_min_cp(
                       p_person_id                =>  p_person_id,
                       p_load_calendar_type       =>  p_load_cal,
                       p_load_cal_sequence_number =>  p_load_ci_sequence_number,
                       p_uoo_id                   =>  l_cur_uoo_id.uoo_id,
                       p_program_cd               =>  p_course_cd,
                       p_program_version          =>  TO_CHAR(p_version_number),
                       p_message                  =>  l_message,
                       p_deny_warn                =>  l_notification_flag,
                       p_credit_points            =>  l_credit_points,
                       p_enrollment_category      =>  l_enrollment_cat,
                       p_comm_type                =>  l_commencement_type,
                       p_method_type              =>  p_method,
                       p_min_credit_point         =>  l_min_credit_point,
                       p_calling_obj              =>  'JOB');
          IF l_ret_value = FALSE AND l_message = 'IGS_SS_DENY_MIN_CP_REACHED' THEN
              RETURN 'FALSE';
          END IF;
      END LOOP;
   END IF;
   RETURN 'TRUE';
END eval_fail_min_cp;

PROCEDURE stdnt_crd_pnt_enrl_workflow(
                            p_user_name             IN VARCHAR2,
                            p_course_cd             IN VARCHAR2,
                            p_version_number        IN NUMBER,
                            p_enrolled_cp           IN NUMBER,
                            p_min_cp                IN NUMBER
                            )AS
  -----------------------------------------------------------------------------
  -- Created by  : Nishikant
  -- Date created: 22OCT2002
  --
  -- Purpose: This procedure introduced to raise a bussiness event to notify the
  --       student that he/she has failed the Min CP Validation.
  --
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  --
  ------------------------------------------------------------------------------
  CURSOR cur_seq_val  IS
  SELECT IGS_EN_WF_BE002_S.nextval seq_val
  FROM   DUAL;

  l_cur_seq_val         cur_seq_val%ROWTYPE;
  l_wf_parameter_list_t WF_PARAMETER_LIST_T:=wf_parameter_list_t();
  l_wf_installed        fnd_lookups.lookup_code%TYPE;

BEGIN

  -- get the profile value that is set for checking if workflow is installed
  fnd_profile.get('IGS_WF_ENABLE',l_wf_installed);

  -- if workflow is installed then carry on with the raising an event
  IF (RTRIM(l_wf_installed) = 'Y' ) THEN

     OPEN cur_seq_val;
     FETCH cur_seq_val INTO l_cur_seq_val;
     CLOSE cur_seq_val;

     -- set the event parameters
     wf_event.addparametertolist(p_Name=>'USER_NAME',      p_Value=>p_user_name      ,p_Parameterlist =>l_wf_parameter_list_t);
     wf_event.addparametertolist(p_Name=>'COURSE_CD',      p_Value=>p_course_cd      ,p_Parameterlist =>l_wf_parameter_list_t);
     wf_event.addparametertolist(p_Name=>'VERSION_NUMBER', p_Value=>p_version_number ,p_Parameterlist =>l_wf_parameter_list_t);
     wf_event.addparametertolist(p_Name=>'ENROLLED_CP',    p_Value=>p_enrolled_cp    ,p_Parameterlist =>l_wf_parameter_list_t);
     wf_event.addparametertolist(p_Name=>'MIN_CP',         p_Value=>p_min_cp         ,p_Parameterlist =>l_wf_parameter_list_t);

     -- raise the event
     WF_EVENT.RAISE(p_event_name=>'oracle.apps.igs.en.be_en002',
                    p_event_key =>'oracle.apps.igs.en.be_en002'||l_cur_seq_val.seq_val,
                    p_event_data=>NULL,
                    p_parameters=>l_wf_parameter_list_t);
    --As part of the bug 2840171 fix, issuing commit after workflow event is raised.
    --Reason, workflow event would successfully complete only after commit(transaction is complete),
    --but there is no explicit commit call in the Minimum Credit point Query form(IGSEN076.fmb) form
    --while calling the this workflow procedure.
    COMMIT;
  END IF;

END stdnt_crd_pnt_enrl_workflow;


FUNCTION calc_min_cp (
 p_person_id                             NUMBER,
 p_load_calendar_type                   VARCHAR2,
 p_load_cal_sequence_number             NUMBER,
 p_uoo_id                               NUMBER,
 p_program_cd                           VARCHAR2,
 p_program_version                      VARCHAR2,
 p_message                      OUT NOCOPY VARCHAR2
) RETURN NUMBER IS
 -----------------------------------------------------------------------------
  -- Created by  : svenkata
  -- Date created: 23-Jan-2003
  --
  -- Purpose: The routine has been created by moving the code from the routine eval_min_cp.This function calculates the Min CP as
  -- defined at any one of the following levels in that order :Override, Holds,Person ID group,Term or Program.
  --
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  --
  ----------------------------------------------------------------------------
  -- Cursor for getting the Teaching Calendar Type and its Sequence number for the UOO_ID passed
  CURSOR cur_uoo_id
  IS
  SELECT unit_cd, version_number, cal_type, ci_sequence_number
  FROM   igs_ps_unit_ofr_opt
  WHERE  uoo_id = p_uoo_id;

  -- Cursor for getting the minimum progression credit points that are defined
  CURSOR cur_min_progression_cp(cp_effective_date DATE)
  IS
  SELECT MIN(restricted_enrolment_cp) restricted_enrolment_cp
  FROM   igs_pe_persenc_effct
  WHERE  person_id            = p_person_id
  AND    s_encmb_effect_type  = 'RSTR_GE_CP'
  AND    pee_start_dt        <= cp_effective_date
  AND    (expiry_dt IS NULL OR expiry_dt >= cp_effective_date);

  -- Cursor for getting the minimum primary program credit points that are defined
  CURSOR cur_min_primary_cp(cp_primary_cd     igs_ps_ver.course_cd%TYPE,
                            cp_version_number igs_ps_ver.version_number%TYPE)
  IS
  SELECT min_cp_per_calendar
  FROM   igs_ps_ver
  WHERE  course_cd      = cp_primary_cd
  AND    version_number = cp_version_number;

  -- Below three cursors added as part of Enrl Elgbl and Validation Build. Bug#2616692
  CURSOR cur_get_min_cp_ovr IS
  SELECT min_cp_per_term
  FROM   igs_en_config_enr_cp
  WHERE  course_cd      = p_program_cd      AND
         version_number = p_program_version AND
         cal_type       = p_load_calendar_type;

  -- Cursor to get the Load Calendar Start Date when the uoo_id is not mentioned.
  CURSOR get_load_cal_st_dt IS
  SELECT start_dt
  FROM igs_ca_inst
  WHERE cal_type = p_load_calendar_type  AND
  sequence_number =  p_load_cal_sequence_number ;

  -- Cursor Row Type Variables
  l_cur_uoo_id              cur_uoo_id%ROWTYPE;
  l_cur_min_progression_cp  cur_min_progression_cp%ROWTYPE;
  l_cur_min_primary_cp      cur_min_primary_cp%ROWTYPE;
  l_message                 VARCHAR2(30) := NULL ;

  -- Table.Column Type Variables
  l_override_limit          igs_pe_persenc_effct.restricted_enrolment_cp%TYPE;
  l_min_cp_allowed          igs_pe_persenc_effct.restricted_enrolment_cp%TYPE := NULL ;

  l_get_min_cp_ovr          igs_en_config_enr_cp.min_cp_per_term%TYPE;
  l_return_value            BOOLEAN;
  l_effective_date          igs_ca_inst.start_dt%TYPE;
  l_prsid_min_cp            igs_en_pig_cp_setup.prsid_min_cp%TYPE;

BEGIN
  l_return_value := igs_en_gen_015.validation_step_is_overridden ( p_eligibility_step_type => 'FMIN_CRDT',
                                                                   p_load_cal_type         => p_load_calendar_type,
                                                                   p_load_cal_seq_number   => p_load_cal_sequence_number,
                                                                   p_person_id             => p_person_id,
                                                                   p_uoo_id                => p_uoo_id,
                                                                   p_step_override_limit   => l_override_limit
                                                                 );
  IF l_return_value = TRUE THEN
    IF l_override_limit IS NOT NULL THEN
      l_min_cp_allowed := l_override_limit;
      RETURN l_min_cp_allowed;
    ELSE
       RETURN NULL;
    END IF;
  END IF;


  -- get the teaching calendar type and its sequence number for the uoo_id that is passed into the function
  -- unit code and its version number is also captured
  OPEN  cur_uoo_id;
  FETCH cur_uoo_id INTO l_cur_uoo_id;
  CLOSE cur_uoo_id;

  -- Once the teaching calendar and its sequence number is found , get the census date as a return value (effective date)
  l_effective_date := igs_en_gen_015.get_effective_census_date( p_load_cal_type        => p_load_calendar_type,
                                                                p_load_cal_seq_number  => p_load_cal_sequence_number,
                                                                p_teach_cal_type       => l_cur_uoo_id.cal_type,
                                                                p_teach_cal_seq_number => l_cur_uoo_id.ci_sequence_number
                                                              );
  --
  -- The Effective Date is the Census Date alias value that is queried at the following levels : Term Cal , Teach Cal. If not defined,
  -- Teach Cal Start date is taken. When called from SS , Teach Cal details are not available.Hence the function
  --igs_en_gen_015.get_effective_census_date may return NULL. So Load Cal start Date is assigned to l_effective_date.
  IF l_effective_date IS NULL THEN
    OPEN get_load_cal_st_dt  ;
    FETCH get_load_cal_st_dt  INTO l_effective_date ;
    CLOSE get_load_cal_st_dt ;
  END IF ;

  -- if the minimum credit points are not fetched till this point,
  -- get the minimum credit points from the progression prespective
  IF l_min_cp_allowed IS NULL THEN
    -- opening the cursor with the effective date fetched, start and expiry date should be between the census date
    OPEN  cur_min_progression_cp (l_effective_date);
    FETCH cur_min_progression_cp INTO l_cur_min_progression_cp;
    CLOSE cur_min_progression_cp;

    -- If the credit points fetched is not null then assign it to the minimum cp allowed variable
    IF l_cur_min_progression_cp.restricted_enrolment_cp IS NOT NULL THEN
      RETURN l_cur_min_progression_cp.restricted_enrolment_cp;
    ELSE

       --If the Restricted Enrollment Credit Point is not defined in Progression then check the Minimum CP then
       --check at person id group level.
       l_prsid_min_cp := igs_en_val_pig.enrf_get_pig_cp(p_person_id,'MIN_CP',l_message);
       IF l_message IS NOT NULL THEN
           --If a person belongs to more than one person grop and
           --Override steps were defined at more than one person id group level.
            p_message := l_message ;
            RETURN NULL  ;
       ELSIF l_prsid_min_cp IS NOT NULL THEN
            RETURN l_prsid_min_cp;
       ELSE
            -- Code added by Nishikant as part of Enrollment Eligibility and Validation Build - Bug#2616692
            -- If the Restricted Enrollment Credit Point is not defined in person id group then check the Minimum CP
            -- is overriden at the load calendar level. If yes then proceed with the value, If not then proceed to
            -- check out NOCOPY whether provided at Program level.
            OPEN cur_get_min_cp_ovr;
            FETCH cur_get_min_cp_ovr INTO l_get_min_cp_ovr;
            CLOSE cur_get_min_cp_ovr;
            IF l_get_min_cp_ovr IS NOT NULL THEN
                   RETURN l_get_min_cp_ovr;
            ELSE
                  OPEN  cur_min_primary_cp (p_program_cd, p_program_version);
                  FETCH cur_min_primary_cp INTO l_cur_min_primary_cp;
                  CLOSE cur_min_primary_cp;
                  -- If the credit points fetched for the primary program is not null
                  -- then assign it to the minimum cp allowed variable
                  IF l_cur_min_primary_cp.min_cp_per_calendar IS NOT NULL THEN
                     RETURN l_cur_min_primary_cp.min_cp_per_calendar;
                  ELSE
                         RETURN NULL ;
                  END IF;
              END IF; --IF cur_get_min_cp_ovr%FOUND AND l_get_min_cp_ovr.min_cp_per_term IS NOT NULL THEN
       END IF;  --If l_message is not null
    END IF;--IF l_cur_min_progression_cp.restricted_enrolment_cp IS NOT NULL THEN
  END IF;--IF l_min_cp_allowed IS NULL THEN

  RETURN NULL ;
END calc_min_cp ;

FUNCTION calc_max_cp (
                       p_person_id                             NUMBER,
                       p_load_calendar_type                   VARCHAR2,
                       p_load_cal_sequence_number             NUMBER,
                       p_uoo_id                               NUMBER,
                       p_program_cd                           VARCHAR2,
                       p_program_version                      VARCHAR2,
                       p_message                      OUT NOCOPY VARCHAR2
                    ) RETURN NUMBER IS
 -----------------------------------------------------------------------------
  -- Created by  : svenkata
  -- Date created: 23-Jan-2003
  --
  -- Purpose: The routine has been created by moving the code from the routine eval_max_cp.This function calculates the Max CP as
  -- defined at any one of the following levels in that order :Override, Holds,Person ID group,Term or Program.
  --
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  --
  ----------------------------------------------------------------------------

  -- Cursor for getting the Teaching Calendar Type and its Sequence number for the UOO_ID passed
  CURSOR cur_uoo_id
  IS
  SELECT unit_cd, version_number, cal_type, ci_sequence_number
  FROM   igs_ps_unit_ofr_opt
  WHERE  uoo_id = p_uoo_id;

  -- Cursor for getting the maximum progression credit points that are defined
  CURSOR cur_max_progression_cp(cp_effective_date DATE)
  IS
  SELECT MAX(restricted_enrolment_cp) restricted_enrolment_cp
  FROM   igs_pe_persenc_effct
  WHERE  person_id            = p_person_id
  AND    s_encmb_effect_type  = 'RSTR_LE_CP'
  AND    pee_start_dt        <= cp_effective_date
  AND    (expiry_dt IS NULL OR expiry_dt >= cp_effective_date);

  -- Cursor for getting the maximum primary program credit points that are defined
  CURSOR cur_max_primary_cp(cp_primary_cd     igs_ps_ver.course_cd%TYPE,
                            cp_version_number igs_ps_ver.version_number%TYPE)
  IS
  SELECT max_cp_per_teaching_period
  FROM   igs_ps_ver
  WHERE  course_cd      = cp_primary_cd
  AND    version_number = cp_version_number;

  -- Below cursor added as part of Enrl Elgbl and Validation Build. Bug#2616692
  CURSOR cur_get_max_cp_ovr IS
  SELECT max_cp_per_term
  FROM   igs_en_config_enr_cp
  WHERE  course_cd      = p_program_cd      AND
         version_number = p_program_version AND
         cal_type       = p_load_calendar_type;

  -- Cursor to get the Load Calendar Start Date when the uoo_id is not mentioned.
  CURSOR get_load_cal_st_dt IS
  SELECT start_dt
  FROM igs_ca_inst
  WHERE cal_type = p_load_calendar_type  AND
  sequence_number =  p_load_cal_sequence_number ;

  l_cur_uoo_id              cur_uoo_id%ROWTYPE;
  l_cur_max_progression_cp  cur_max_progression_cp%ROWTYPE;
  l_cur_max_primary_cp      cur_max_primary_cp%ROWTYPE;
  l_get_max_cp_ovr          cur_get_max_cp_ovr%ROWTYPE;
  l_override_limit          igs_pe_persenc_effct.restricted_enrolment_cp%TYPE;
  l_return_value            BOOLEAN;
  l_effective_date          DATE;
  l_prsid_max_cp            igs_en_pig_cp_setup.prsid_max_cp%TYPE;
  l_message                 VARCHAR2(30);
  l_max_cp_allowed          igs_pe_persenc_effct.restricted_enrolment_cp%TYPE;

  l_enrol_cal_type              igs_ca_type.cal_type%TYPE;
  l_enrol_sequence_number   igs_ca_inst_all.sequence_number%TYPE;

BEGIN

  l_return_value := igs_en_gen_015.validation_step_is_overridden ( p_eligibility_step_type => 'FMAX_CRDT',
                                                                   p_load_cal_type         => p_load_calendar_type,
                                                                   p_load_cal_seq_number   => p_load_cal_sequence_number,
                                                                   p_person_id             => p_person_id,
                                                                   p_uoo_id                => p_uoo_id,
                                                                   p_step_override_limit   => l_override_limit
                                                                 );
  IF l_return_value = TRUE THEN
    IF l_override_limit IS NOT NULL THEN
      l_max_cp_allowed :=  l_override_limit;
      RETURN l_override_limit;
    ELSE
      -- If the override limit is not specified, then the function returns NULL
      RETURN NULL ;
    END IF;
  END IF;

  -- get the teaching calendar type and its sequence number for the uoo_id that is passed into the function
  -- unit code and its version number is also captured
  OPEN  cur_uoo_id;
  FETCH cur_uoo_id INTO l_cur_uoo_id;
  CLOSE cur_uoo_id;

  -- Once the teaching calendar and its sequence number is found , get the census date as a return value (effective date)
  l_effective_date := igs_en_gen_015.get_effective_census_date( p_load_cal_type        => p_load_calendar_type,
                                                                p_load_cal_seq_number  => p_load_cal_sequence_number,
                                                                p_teach_cal_type       => l_cur_uoo_id.cal_type,
                                                                p_teach_cal_seq_number => l_cur_uoo_id.ci_sequence_number
                                                              );

  --
  -- The Effective Date is the Census Date alias value that is queried at the following levels : Term Cal , Teach Cal. If not defined,
  -- Teach Cal Start date is taken. When called from SS , Teach Cal details are not available.Hence the function
  --igs_en_gen_015.get_effective_census_date may return NULL. So Load Cal start Date is assigned to l_effective_date.
  IF l_effective_date IS NULL THEN
    OPEN get_load_cal_st_dt  ;
    FETCH get_load_cal_st_dt  INTO l_effective_date ;
    CLOSE get_load_cal_st_dt ;
  END IF ;

  -- if the maximum credit points are not fetched till this point,
  -- get the maximum credit points from the progression prespective
  IF l_max_cp_allowed IS NULL THEN
    -- opening the cursor with the effective date fetched, start and expiry date should be between the census date
    OPEN  cur_max_progression_cp (l_effective_date);
    FETCH cur_max_progression_cp INTO l_cur_max_progression_cp;
    CLOSE cur_max_progression_cp;

    -- If the credit points fetched is not null then assign it to the maximum cp allowed variable
    IF l_cur_max_progression_cp.restricted_enrolment_cp IS NOT NULL THEN
      RETURN l_cur_max_progression_cp.restricted_enrolment_cp;
    ELSE

       --If the Restricted Enrollment Credit Point is not defined in Progression then check the Maximum CP then
       --check at person id group level.
       l_prsid_max_cp := igs_en_val_pig.enrf_get_pig_cp(p_person_id,'MAX_CP',l_message);

       IF l_message IS NOT NULL THEN

           --If a person belongs to more than one person grop and Override steps were defined at more than one person id group level.
           p_message := l_message ;
            RETURN NULL ;
       ELSIF l_prsid_max_cp IS NOT NULL THEN
            RETURN l_prsid_max_cp;
       ELSE

           --
           -- Enrollment Eligibility and Validation Build - Bug#2616692 .If the Restricted Enrollment Credit Point is not defined in person id group level then check the Maximum CP
           -- is overriden at the load calendar level. If yes then proceed with the value, If not then proceed to check out NOCOPY whether provided at Program level.

           OPEN cur_get_max_cp_ovr;
           FETCH cur_get_max_cp_ovr INTO l_get_max_cp_ovr;
           CLOSE cur_get_max_cp_ovr;

           IF l_get_max_cp_ovr.max_cp_per_term IS NOT NULL THEN
               RETURN  l_get_max_cp_ovr.max_cp_per_term;
           ELSE
           -- If the credit points are not specified then fecth the credit points defined at the program level
              OPEN  cur_max_primary_cp (p_program_cd, p_program_version);
              FETCH cur_max_primary_cp INTO l_cur_max_primary_cp;
              CLOSE cur_max_primary_cp;

              -- If the credit points fetched for the primary program is not null
              -- then assign it to the maximum cp allowed variable
              IF l_cur_max_primary_cp.max_cp_per_teaching_period IS NOT NULL THEN
                RETURN l_cur_max_primary_cp.max_cp_per_teaching_period;
              ELSE
                -- If no credit points are defined at the program level, function should return 'TRUE'
                RETURN NULL ;
              END IF;

           END IF; -- max_cp_per_term
        END IF; -- l_prsid_max_cp
    END IF; -- restricted_enrolment_cp
  END IF; -- l_max_cp_allowed

  RETURN NULL;
END calc_max_cp ;

PROCEDURE get_per_min_max_cp (
 p_person_id                            NUMBER,
 p_load_calendar_type                   VARCHAR2,
 p_load_cal_sequence_number             NUMBER,
 p_program_cd                           VARCHAR2,
 p_program_version                      VARCHAR2,
 p_min_cp                       OUT     NOCOPY VARCHAR2 ,
 p_max_cp                       OUT     NOCOPY VARCHAR2 ,
 p_message                      OUT     NOCOPY VARCHAR2 ) IS
 -----------------------------------------------------------------------------
  -- Created by  : svenkata
  -- Date created: 23-Jan-2003
  --
  -- Purpose: This routine is a wrapper that is being called from SS pages to get the Min and Max Credit points.
  --
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  --
  -----------------------------------------------------------------------------
  l_min_message VARCHAR2(30) := NULL;
  l_max_message VARCHAR2(30) := NULL;

BEGIN
    p_min_cp := calc_min_cp (
         p_person_id                =>  p_person_id   ,
         p_load_calendar_type       =>  p_load_calendar_type ,
         p_load_cal_sequence_number =>  p_load_cal_sequence_number ,
         p_uoo_id                   =>  NULL ,
         p_program_cd               =>  p_program_cd ,
         p_program_version          =>  p_program_version,
         p_message                  =>  l_min_message  );

    -- If the value of Min CP returned by the routine is NULL , a hyphen is returned to SS. This is done
    -- deliberately to indicate to the user that the values of Min/Max CP is not defined.
    IF p_min_cp IS NULL THEN
       p_min_cp := '-' ;
    END IF ;

    p_max_cp := calc_max_cp (
         p_person_id                =>  p_person_id   ,
         p_load_calendar_type       =>  p_load_calendar_type ,
         p_load_cal_sequence_number =>  p_load_cal_sequence_number ,
         p_uoo_id                   =>  NULL ,
         p_program_cd               =>  p_program_cd ,
         p_program_version          =>  p_program_version,
         p_message                  =>  l_max_message );

    -- Though the messages are being passed as OUT parameters, these messages are currently not being shown to the user,
    -- as the routine is expected to calculate only the Min and Max CP values.
    IF l_max_message IS NOT NULL THEN
         p_message := l_max_message ;
    ELSIF l_min_message IS NOT NULL THEN
         p_message := l_min_message ;
    END IF ;

    -- If the value of Max CP returned by the routine is NULL , a hyphen is returned to SS. This is done
    -- deliberately to indicate to the user that the values of Min/Max CP is not defined.
    IF p_max_cp IS NULL THEN
       p_max_cp := '-' ;
    END IF ;

END get_per_min_max_cp;

FUNCTION EVAL_CROSS_VALIDATION(
  p_person_id                   IN NUMBER ,
  p_course_cd                   IN VARCHAR2 ,
  p_program_version             IN VARCHAR2,
  p_uoo_id                      IN NUMBER,
  p_load_cal_type               IN VARCHAR2 ,
  p_load_ci_sequence_number     IN NUMBER ,
  p_deny_warn                   IN VARCHAR2,
  p_upd_cp                      IN  NUMBER ,
  p_eligibility_step_type       IN VARCHAR2 ,
  p_message                     IN OUT NOCOPY VARCHAR2,
  p_calling_obj                 IN VARCHAR2 )
  RETURN boolean AS
  /******************************************************************
  Created By        : svenkata
  Date Created By   : 12-May-2003
  Purpose           : This function would validate the Cross element restriction (cross location / faculty / mode ) Credit points
                      based on the Eligibility Step Type parameter passed to it . It is a generic function that behaves differently
                      according to the value of parameter p_eligibility_step_type.
  Known limitations,
  enhancements,
  remarks           :
  Change History
  Who          When          What
  ckasu       15-Jul-2005     Modified this function inorder to log warning records in to a warnings Table
                              when called from selefservice pages as a part of EN317 SS UI Build bug#4377985

  stutta    18-NOV-2003  Replaced cursor to program attempt table with calls to terms api functions.
                         Done as part of Term Records Build.

   myoganat 16-JUN-2003    Added cursor c_assessment to check for an audit attempt and if it is, the function
                                                   will return TRUE
  vkarthik              22-Jul-2004     Added three dummy variables l_audit_cp, l_billing_cp, l_enrolled_cp for all the calls to
                                                igs_en_prc_load.enrp_clc_sua_load towards EN308 Billable credit points build Enh#3782329
******************************************************************/

--
-- Cursor to fetch the Unit Offering Details
        CURSOR cur_uoo_id IS
        SELECT unit_cd, version_number, cal_type, ci_sequence_number
        FROM   igs_ps_unit_ofr_opt
        WHERE  uoo_id = p_uoo_id;


-- Cursor to fetch the Cross faculty Element restrictions
        CURSOR c_cop (
                cp_sca_coo_id           IGS_EN_STDNT_PS_ATT.coo_id%TYPE,
                cp_cal_type             IGS_EN_STDNT_PS_ATT.cal_type%TYPE,
                cp_ci_sequence_number   IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  cop.max_cross_faculty_cp,
                        cop.max_cross_mode_cp,
                        cop.max_cross_location_cp
                FROM    IGS_PS_OFR_PAT  cop
                WHERE   cop.coo_id = cp_sca_coo_id AND
                        cop.cal_type = cp_cal_type AND
                        cop.ci_sequence_number = cp_ci_sequence_number;

-- Cursor to fetch the Student Unit Attempt Details. The cursor  queries all the Units that are attempted by the student
-- in all the Teaching Calendars that are subordinate to the given Academic Calendar The cursor also selects only Unit Attempts
-- that incur a Load in the given Load Calendar. IGS_EN_PRC_LOAD.ENRP_GET_LOAD_INCUR determines whether a nominated student unit
-- attempt incurs load for a nominated load calendar.

  -- modified this cursor as a part of EN317 Build bug#4377985
  -- CURSOR c_sua_uv was modified to remove academic calendar instance relationship.
  -- Instead fetch all unit attempts which belong to the passed load calendar.

        CURSOR c_sua_uv (
                cp_person_id                    IGS_EN_STDNT_PS_ATT.person_id%TYPE,
                cp_course_cd                    IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                cp_load_cal_type                  IGS_CA_INST.cal_type%TYPE, -- Load Cal
                cp_load_ci_sequence_number           IGS_CA_INST.sequence_number%TYPE) IS-- Load Cal
                SELECT DISTINCT  sua.unit_cd,
                        sua.version_number,
                        sua.cal_type,
                        sua.ci_sequence_number,
                        sua.uoo_id,
                        sua.administrative_unit_status,
                        sua.unit_attempt_status,
                        sua.override_enrolled_cp,
                        sua.override_eftsu,
                        sua.location_cd,
                        sua.unit_class,
                        sua.no_assessment_ind
                FROM    igs_en_su_attempt       sua,
                        igs_ca_load_to_teach_v ltt
                WHERE   sua.person_id = cp_person_id AND
                        sua.course_cd = cp_course_cd AND
                        sua.cal_type = ltt.teach_cal_type AND
                        sua.ci_sequence_number = ltt.teach_ci_sequence_number AND
                        ltt.load_cal_type = cp_load_cal_type  AND
                        ltt.load_ci_sequence_number = cp_load_ci_sequence_number AND
                         ((IGS_EN_PRC_LOAD.ENRP_GET_LOAD_INCUR(
                                                                sua.cal_type,
                                                                sua.ci_sequence_number,
                                                                sua.discontinued_dt,
                                                                sua.administrative_unit_status,
                                                                sua.unit_attempt_status,
                                                                sua.no_assessment_ind,
                                                                cp_load_cal_type,
                                                                cp_load_ci_sequence_number,
                                                                -- anilk, Audit special fee build
                                                                NULL, -- for p_uoo_id
                                                                'N') = 'Y') OR
/* added this for bug 3037043, as unit status would still waitlist when called from auto enroll process*/
                      (sua.uoo_id = p_uoo_id AND
                       sua.unit_attempt_status = 'WAITLISTED') ) AND
                        NVL(sua.no_assessment_ind ,'N') = 'N' ;

        CURSOR c_org_unit (cp_uoo_id igs_en_su_attempt_all.uoo_id%TYPE) IS
        SELECT  uop.owner_org_unit_cd,
                ou.start_dt
        FROM   igs_ps_unit_ofr_opt_all   uop,
               igs_or_inst_org_base_v ou
        WHERE uop.uoo_id  = cp_uoo_id AND
                uop.owner_org_unit_cd = ou.party_number AND
                ou.inst_org_ind = 'O' ;
        c_org_unit_rec  c_org_unit%ROWTYPE;

--
-- Cursor to fetch the system Unit mode once the Unit class is provided.
        CURSOR c_um_ucl (
                cp_sua_unit_class       IGS_EN_SU_ATTEMPT.unit_class%TYPE) IS
                SELECT  um.s_unit_mode
                        FROM    IGS_AS_UNIT_MODE        um,
                        IGS_AS_UNIT_CLASS       ucl
                WHERE   ucl.unit_class = cp_sua_unit_class AND
                        ucl.closed_ind = 'N'               AND
                        ucl.unit_mode = um.unit_mode;

--
-- Cursor to fetch the govt. Attendance mode from the user defined Attendance Mode. Government Attendance Mode of 1
-- means ON CAMPUS , 2 means OFF CAMPUS and 3 means MIXED CAMPUS.
        CURSOR c_am ( cp_sca_attendance_mode    IGS_EN_STDNT_PS_ATT.attendance_mode%TYPE) IS
                SELECT  am.govt_attendance_mode
                FROM    IGS_EN_ATD_MODE am
                WHERE   am.attendance_mode = cp_sca_attendance_mode;
--
-- Cursor to check if the Organization Unit associated with the Course is the same as the Organization associated with the Unit.
        CURSOR c_cow (cp_sca_course_cd          IGS_EN_STDNT_PS_ATT.course_cd%TYPE,
                cp_sca_version_number           IGS_EN_STDNT_PS_ATT.version_number%TYPE,
                cp_uv_owner_org_unit_cd         IGS_PS_UNIT_VER.owner_org_unit_cd%TYPE,
                cp_uv_owner_ou_start_dt         IGS_PS_UNIT_VER.owner_ou_start_dt%TYPE) IS
                SELECT  cow.course_cd,
                        cow.version_number,
                        cow.org_unit_cd,
                        cow.ou_start_dt
                FROM    IGS_PS_OWN cow
                WHERE   cow.course_cd = cp_sca_course_cd AND
                        cow.version_number = cp_sca_version_number AND
                        ((cow.org_unit_cd = cp_uv_owner_org_unit_cd AND
                        cow.ou_start_dt = cp_uv_owner_ou_start_dt) OR
                        (IGS_OR_GEN_001.ORGP_GET_WITHIN_OU(
                                        cow.org_unit_cd,
                                        cow.ou_start_dt,
                                        cp_uv_owner_org_unit_cd,
                                        cp_uv_owner_ou_start_dt,
                                        'N') = 'Y'));

 -- Cursor to get the assessment indicator value.
  CURSOR c_assessment IS
    SELECT no_assessment_ind
     FROM  igs_en_su_attempt
    WHERE  person_id = p_person_id
      AND  course_cd = p_course_cd
      AND  uoo_id = p_uoo_id;
 --
 -- Variables
 l_cop_cross_faculty_cp    IGS_PS_OFR_PAT.max_cross_faculty_cp%TYPE;
 l_cross_faculty_cp        IGS_PS_OFR_PAT.max_cross_faculty_cp%TYPE := 0;
 l_cop_cross_mode_cp       IGS_PS_OFR_PAT.max_cross_mode_cp%TYPE;
 l_cross_mode_cp           IGS_PS_OFR_PAT.max_cross_mode_cp%TYPE := 0 ;
 l_cop_cross_location_cp   IGS_PS_OFR_PAT.max_cross_location_cp%TYPE;
 l_cross_location_cp       IGS_PS_OFR_PAT.max_cross_location_cp%TYPE := 0;
 l_no_assessment_ind       igs_en_su_attempt.no_assessment_ind%TYPE;

 l_sua_cp                  IGS_PS_UNIT_VER.POINTS_MAX%TYPE;
 l_return_value            BOOLEAN;
 l_alternate_code          IGS_CA_INST.alternate_code%TYPE;
 l_override_limit          igs_pe_persenc_effct.restricted_enrolment_cp%TYPE;
 l_return_eftsu            NUMBER := 0;
 v_um_s_unit_mode          IGS_AS_UNIT_MODE.s_unit_mode%TYPE;
 v_am_govt_attendance_mode IGS_EN_ATD_MODE.govt_attendance_mode%TYPE;

 l_sca_course_cd          IGS_EN_STDNT_PS_ATT.course_cd%TYPE;
 l_sca_version_number     IGS_EN_STDNT_PS_ATT.version_number%TYPE;
 l_sca_location_cd        IGS_EN_STDNT_PS_ATT.location_cd%TYPE;
 l_sca_attendance_mode    IGS_EN_STDNT_PS_ATT.attendance_mode%TYPE;
 l_sca_coo_id             IGS_EN_STDNT_PS_ATT.coo_id%TYPE;

 l_cow_course_cd        IGS_PS_OWN.course_cd%TYPE;
 l_cow_version_number   IGS_PS_OWN.version_number%TYPE;
 l_cow_org_unit_cd      IGS_PS_OWN.org_unit_cd%TYPE;
 v_cow_ou_start_dt      IGS_PS_OWN.ou_start_dt%TYPE;

 l_acad_cal_type          IGS_CA_TYPE.CAL_TYPE%TYPE;
 l_acad_ci_sequence_number IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
 l_acad_start_dt          IGS_CA_INST.START_DT%TYPE;
 l_acad_end_dt            IGS_CA_INST.END_DT%TYPE;
 l_acad_message           VARCHAR2(30);
 l_temp NUMBER := 0 ;
--dummy variable to pick up audit, billing, enrolled credit points
--due to signature change by EN308 Billing credit hours Bug 3782329
l_audit_cp              IGS_PS_USEC_CPS.billing_credit_points%TYPE;
l_billing_cp            IGS_PS_USEC_CPS.billing_hrs%TYPE;
l_enrolled_cp   IGS_PS_UNIT_VER.enrolled_credit_points%TYPE;

l_message            VARCHAR2(2000);
l_message_text       VARCHAR2(2000);
l_message_icon       VARCHAR2(1);
l_token_value        IGS_PS_OFR_PAT.max_cross_location_cp%TYPE;
BEGIN

-- This module validates that the student hasn't breached any of  the cross-element restrictions held against the
-- course-offering pattern for the specified academic period.

--
-- Set the default message number
p_message := null;

  OPEN c_assessment;
  FETCH c_assessment INTO l_no_assessment_ind;
  CLOSE c_assessment;

    -- Checking if the unit section attempt is an audit attempt, if it is then the function will return TRUE
  IF l_no_assessment_ind = 'Y' THEN
      RETURN TRUE;
  END IF;

-- Check if the step is overridden
  l_return_value := igs_en_gen_015.validation_step_is_overridden ( p_eligibility_step_type => p_eligibility_step_type  ,
                                                                   p_load_cal_type         => p_load_cal_type,
                                                                   p_load_cal_seq_number   => p_load_ci_sequence_number,
                                                                   p_person_id             => p_person_id,
                                                                   p_uoo_id                => p_uoo_id,
                                                                   p_step_override_limit   => l_override_limit
                                                                 );
  IF l_return_value = TRUE THEN
      RETURN TRUE;
  END IF;

  -- Get student course attempt detail

  l_sca_coo_id := igs_en_spa_terms_api.get_spat_coo_id( p_person_id => p_person_id,
                        p_program_cd => p_course_cd,
                        p_term_cal_type => p_load_cal_type,
                        p_term_sequence_number => p_load_ci_sequence_number);
  l_sca_location_cd := igs_en_spa_terms_api.get_spat_location( p_person_id => p_person_id,
                                p_program_cd => p_course_cd,
                                p_term_cal_type => p_load_cal_type,
                                p_term_sequence_number => p_load_ci_sequence_number);
  l_sca_attendance_mode := igs_en_spa_terms_api.get_spat_att_mode( p_person_id => p_person_id,
                                p_program_cd => p_course_cd,
                                p_term_cal_type => p_load_cal_type,
                                p_term_sequence_number => p_load_ci_sequence_number);
  l_sca_version_number := igs_en_spa_terms_api.get_spat_program_version( p_person_id => p_person_id,
                                p_program_cd => p_course_cd,
                                p_term_cal_type => p_load_cal_type,
                                p_term_sequence_number => p_load_ci_sequence_number);
  IF (l_sca_coo_id IS NULL AND l_sca_location_cd IS NULL
      AND l_sca_attendance_mode IS NULL AND l_sca_version_number IS NULL) THEN
        RETURN TRUE;
  ELSE
        l_sca_course_cd := p_course_cd;
  END IF;
  -- Get the academic calendar of the given Load Calendar
  l_alternate_code := Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd(
                        p_cal_type                => p_load_cal_type,
                        p_ci_sequence_number      => p_load_ci_sequence_number,
                        p_acad_cal_type           => l_acad_cal_type,
                        p_acad_ci_sequence_number => l_acad_ci_sequence_number,
                        p_acad_ci_start_dt        => l_acad_start_dt,
                        p_acad_ci_end_dt          => l_acad_end_dt,
                        p_message_name            => l_acad_message );


  -- Get the course offering pattern detail for the specified  academic period.
  --
  OPEN  c_cop(l_sca_coo_id, L_acad_cal_type, l_acad_ci_sequence_number);
  FETCH c_cop   INTO    l_cop_cross_faculty_cp,
                        l_cop_cross_mode_cp,
                        l_cop_cross_location_cp;
  IF (c_cop%NOTFOUND) THEN
        -- no IGS_PS_OFR_PAT records found
        CLOSE   c_cop;
        RETURN TRUE;
  END IF;
  CLOSE c_cop;

  --If Cross Location /Faculty  / Mode Credit points are mentioned as zero , it means that Cross Credit points are not allowed totally.
  -- The function should not return True in this scenario.

  IF ((l_cop_cross_location_cp IS NULL)) AND p_eligibility_step_type = 'CROSS_LOC'  THEN
        RETURN TRUE;
  ELSIF ((l_cop_cross_mode_cp IS NULL)) AND p_eligibility_step_type = 'CROSS_MOD'  THEN
        RETURN TRUE;
  ELSIF ((l_cop_cross_faculty_cp IS NULL)) AND  p_eligibility_step_type = 'CROSS_FAC'  THEN
        RETURN TRUE;
  END IF;

-- removed by ckasu as apart of bug#4377985   IF ( l_acad_cal_type IS NOT NULL AND l_acad_ci_sequence_number IS NOT NULL) THEN
                FOR v_sua_uv_row IN c_sua_uv(
                                p_person_id,
                                p_course_cd,
                                p_load_cal_type,
                                p_load_ci_sequence_number) LOOP

                        -- Call routine to get the load for the SUA within the 'working' load calendar instance.
                        l_sua_cp := IGS_EN_PRC_LOAD.enrp_clc_sua_load(
                                        v_sua_uv_row.unit_cd,
                                        v_sua_uv_row.version_number,
                                        v_sua_uv_row.cal_type,
                                        v_sua_uv_row.ci_sequence_number,
                                        p_load_cal_type,
                                        p_load_ci_sequence_number,
                                        v_sua_uv_row.override_enrolled_cp,
                                        v_sua_uv_row.override_eftsu,
                                        l_return_eftsu,
                                        p_uoo_id,
                                        -- anilk, Audit special fee build
                                        'N',
                                        p_audit_cp => l_audit_cp,
                                        p_billing_cp => l_billing_cp,
                                        p_enrolled_cp => l_enrolled_cp);

                        IF p_eligibility_step_type = 'CROSS_LOC' THEN
                                --
                                -- If the UA is cross location then add to cross location CP total.
                                IF (v_sua_uv_row.location_cd <> l_sca_location_cd) THEN

                                        IF p_uoo_id = v_sua_uv_row.uoo_id and p_upd_cp IS NOT NULL THEN
                                                l_cross_location_cp := l_cross_location_cp + NVL(p_upd_cp ,NVL( l_sua_cp,0)) ;
                                        ELSE
                                                l_cross_location_cp := l_cross_location_cp + l_sua_cp;
                                        END IF;

                                END IF;

                        ELSIF p_eligibility_step_type = 'CROSS_MOD' THEN

                                OPEN    c_um_ucl(v_sua_uv_row.unit_class);
                                FETCH   c_um_ucl        INTO    v_um_s_unit_mode;
                                CLOSE   c_um_ucl;

                                OPEN    c_am(l_sca_attendance_mode);
                                FETCH   c_am            INTO    v_am_govt_attendance_mode;
                                CLOSE   c_am;

                                IF ((v_um_s_unit_mode = 'ON' AND
                                                v_am_govt_attendance_mode <> '1' AND
                                                v_am_govt_attendance_mode <> '3') OR
                                                (v_um_s_unit_mode = 'OFF' AND
                                                v_am_govt_attendance_mode <> '2' AND
                                                v_am_govt_attendance_mode <> '3')) THEN

                                        IF p_uoo_id = v_sua_uv_row.uoo_id and p_upd_cp IS NOT NULL THEN

                                                l_cross_mode_cp := l_cross_mode_cp +  NVL(p_upd_cp ,NVL( l_sua_cp,0)) ;
                                        ELSE

                                                l_cross_mode_cp := l_cross_mode_cp + l_sua_cp ;
                                        END IF;
                                END IF;

                        ELSIF p_eligibility_step_type = 'CROSS_FAC' THEN

                                -- If the UA is cross faculty then add to cross faculty CP total.
                                -- This is dome by checking whether the unit version ownership
                                -- is within any of the course ownership OUs.
                                c_org_unit_rec := NULL;
                                OPEN c_org_unit (v_sua_uv_row.uoo_id);
                                FETCH c_org_unit INTO c_org_unit_rec;
                                CLOSE c_org_unit;

                                OPEN    c_cow(
                                                l_sca_course_cd,
                                                l_sca_version_number,
                                                c_org_unit_rec.owner_org_unit_cd,
                                                c_org_unit_rec.start_dt);
                                FETCH   c_cow   INTO    l_cow_course_cd,
                                                        l_cow_version_number,
                                                        l_cow_org_unit_cd,
                                                        v_cow_ou_start_dt;
                                IF (c_cow%NOTFOUND) THEN
                                        IF p_uoo_id = v_sua_uv_row.uoo_id and p_upd_cp IS NOT NULL THEN

                                                l_cross_faculty_cp := l_cross_faculty_cp + NVL(p_upd_cp ,NVL( l_sua_cp,0)) ;
                                        ELSE
                                                l_cross_faculty_cp := l_cross_faculty_cp + l_sua_cp;

                                        END IF;
                                END IF;
                                CLOSE   c_cow;
                        END IF;
                END LOOP;


    IF p_eligibility_step_type = 'CROSS_LOC' AND l_cross_location_cp  <=  l_cop_cross_location_cp THEN
      RETURN TRUE;
    ELSIF p_eligibility_step_type = 'CROSS_MOD' AND l_cross_mode_cp  <=  l_cop_cross_mode_cp THEN
      RETURN TRUE;
    ELSIF p_eligibility_step_type = 'CROSS_FAC' AND l_cross_faculty_cp  <=  l_cop_cross_faculty_cp THEN
      RETURN TRUE;
    END IF;

    -- code modfied by ckasu as a part of EN317 SS UI Build bug#4377985

    IF p_deny_warn = 'WARN' AND p_eligibility_step_type = 'CROSS_LOC' THEN
          IF p_calling_obj = 'JOB' THEN
                    l_message := 'IGS_EN_CROSS_LOC_WARN';
          ELSE
                    l_message := 'IGS_EN_CRSLOC_TAB_WARN';
                    l_token_value := l_cop_cross_location_cp;
          END IF;

    ELSIF p_deny_warn = 'DENY' AND p_eligibility_step_type = 'CROSS_LOC' THEN

      IF p_calling_obj = 'SCH_UPD' THEN
                    l_message := 'IGS_EN_CRSLOC_UPD_DENY'  ||'*'||l_cop_cross_location_cp;
       ELSIF p_calling_obj = 'JOB' THEN
                    l_message := 'IGS_EN_STUD_MNY_CRS_LOCCRDPNT';
       ELSE
                    l_message := 'IGS_EN_CRSLOC_TAB_DENY';
                    l_token_value := l_cop_cross_location_cp;
       END IF; -- end of p_calling_obj = 'SCH_UPD'

    ELSIF p_deny_warn = 'WARN' AND p_eligibility_step_type = 'CROSS_MOD' THEN
         IF p_calling_obj = 'JOB' THEN
                    l_message := 'IGS_EN_CROSS_MOD_WARN';
         ELSE
                    l_message := 'IGS_EN_CRSMOD_TAB_WARN';
                    l_token_value := l_cop_cross_mode_cp;
         END IF;
    ELSIF p_deny_warn = 'DENY' AND p_eligibility_step_type = 'CROSS_MOD' THEN

       IF p_calling_obj = 'SCH_UPD' THEN
                    l_message := 'IGS_EN_CRSMOD_UPD_DENY'  ||'*'||l_cop_cross_mode_cp;
       ELSIF p_calling_obj = 'JOB' THEN
                    l_message := 'IGS_EN_STUD_MNY_CRS_MODECRDPN';
        ELSE
                    l_message := 'IGS_EN_CRSMOD_TAB_DENY';
                    l_token_value := l_cop_cross_mode_cp;
       END IF; -- end of p_calling_obj = 'SCH_UPD'


    ELSIF p_deny_warn = 'WARN' AND p_eligibility_step_type = 'CROSS_FAC' THEN
        IF p_calling_obj = 'JOB' THEN
                    l_message := 'IGS_EN_CROSS_FAC_WARN';
        ELSE
                    l_message := 'IGS_EN_CRSFAC_TAB_WARN';
                    l_token_value := l_cop_cross_faculty_cp;
        END IF;
    ELSIF p_deny_warn = 'DENY' AND p_eligibility_step_type = 'CROSS_FAC' THEN

       IF p_calling_obj = 'SCH_UPD' THEN
                    l_message := 'IGS_EN_CRSFAC_UPD_DENY' ||'*'||l_cop_cross_faculty_cp;
       ELSIF p_calling_obj = 'JOB' THEN
                    l_message := 'IGS_EN_STUD_MNY_CRSFACCRDPNT';
       ELSE
                    l_message := 'IGS_EN_CRSFAC_TAB_DENY';
                    l_token_value := l_cop_cross_faculty_cp;
       END IF; -- end of p_calling_obj = 'SCH_UPD'

    END IF; -- end of p_deny_warn = 'WARN' AND p_eligibility_step_type = 'CROSS_LOC' IF THEN

    IF p_calling_obj NOT IN ('JOB','SCH_UPD') THEN

       l_message_icon := substr(p_deny_warn,1,1);
       -- create a warnings record
       IGS_EN_DROP_UNITS_API.create_ss_warning(p_person_id               => p_person_id,
                                             p_course_cd                        => p_course_cd,
                                             p_term_cal_type                => p_load_cal_type,
                                             p_term_ci_sequence_number      => p_load_ci_sequence_number,
                                             p_uoo_id                               => p_uoo_id,
                                             p_message_for                      => igs_ss_enroll_pkg.enrf_get_lookup_meaning(p_eligibility_step_type,'ENROLMENT_STEP_TYPE_EXT'),
                                             p_message_icon                         => l_message_icon,
                                             p_message_name                         => l_message,
                                             p_message_rule_text                => NULL,
                                             p_message_tokens                   => 'UNIT_CD:'||l_token_value||';',
                                             p_message_action                   => NULL,
                                             p_destination                          => NULL,
                                             p_parameters                           => NULL,
                                             p_step_type                            => 'PROGRAM');

    ELSE
       p_message :=  l_message;
    END IF; -- end of p_calling_obj NOT IN ('JOB','SCH_UPD') if then



    RETURN FALSE;

  END eval_cross_validation;

FUNCTION get_applied_min_cp (
                       p_person_id            IN NUMBER,
                       p_term_cal_type        IN VARCHAR2,
                       p_term_sequence_number IN NUMBER,
                       p_program_cd           IN VARCHAR2,
                       p_program_version      IN VARCHAR2
                    ) RETURN NUMBER AS
  l_message VARCHAR2(300);
  l_min_cp_allowed NUMBER;
BEGIN
  l_min_cp_allowed := calc_min_cp (
                            p_person_id                    => p_person_id ,
                            p_load_calendar_type           => p_term_cal_type,
                            p_load_cal_sequence_number     => p_term_sequence_number,
                            p_uoo_id                       => NULL,
                            p_program_cd                   => p_program_cd,
                            p_program_version              => p_program_version ,
                            p_message                      => l_message);
  RETURN l_min_cp_allowed;

END get_applied_min_cp;

FUNCTION get_applied_max_cp (
                       p_person_id            IN NUMBER,
                       p_term_cal_type        IN VARCHAR2,
                       p_term_sequence_number IN NUMBER,
                       p_program_cd           IN VARCHAR2,
                       p_program_version      IN VARCHAR2
                    ) RETURN NUMBER AS
  l_message VARCHAR2(300);
  l_max_cp_allowed NUMBER;
BEGIN
  l_max_cp_allowed := calc_max_cp (
                            p_person_id                    => p_person_id ,
                            p_load_calendar_type           => p_term_cal_type,
                            p_load_cal_sequence_number     => p_term_sequence_number,
                            p_uoo_id                       => NULL,
                            p_program_cd                   => p_program_cd,
                            p_program_version              => p_program_version ,
                            p_message                      => l_message);
  RETURN l_max_cp_allowed;

END get_applied_max_cp;


-- end of package
END igs_en_elgbl_program ;

/
