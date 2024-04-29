--------------------------------------------------------
--  DDL for Package Body IGS_EN_ELGBL_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_ELGBL_PERSON" AS
/* $Header: IGSEN78B.pls 120.10 2006/09/19 12:15:35 amuthu ship $ */

 ------------------------------------------------------------------------------------
  --Created by  : smanglm ( Oracle IDC)
  --Date created: 19-JUN-2001
  --
  --Purpose:  Created as part of the build for DLD Enrollment Setup : Eligibility and Validation
  --          This package deals with the holds and person step validation. It has following
  --          functions:
  --             i)  eval_deny_all_hold - Validate Deny All Enrollment Hold
  --                 one local function vald_deny_all_hold
  --            ii)  eval_person_steps - Validate Person Steps
  --                 one local function vald_person_steps
  --           iii)  eval_timeslot - Validate Time Slot - Person Level
  --                 one local function - vald_timeslot
  --            iv)  a private function get_sys_pers_type - Returns System Person Type
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When           What
  --Nishikant   01NOV2002      SEVIS Build. Enh Bug#2641905.
  --                           The notification flag was being fetched from cursor earlier. now its
  --                           modified to call the function igs_ss_enr_details.get_notification,
  --                           to get the value for it and to make the way common across all the packages.
  --
  --ayedubat    24-JUN-2002    Modified the function,vald_person_steps for the bug fix: 2427528
  --Bayadav     23-OCT-2001    Modified eval_timeslot procedure as a part of self service dld-2043044
  --Nalin Kumar  14-May-2002   Modified the 'get_sys_pers_type' function as per the Bug# 2364461.
  --                           Removed the code logic to check the whether the
  --                           passed person type is not a system person type or not.
  --kkillams    20-01-2003      New procedure eval_ss_deny_all_hold and get_enrl_comm_type are added,
  --                            eval_ss_deny_all_hold is a wrapper procedure to eval_deny_all_hold function
  --                            for self service purpose
  --                            get_enrl_comm_type procedure will derives the enrollment category type and
  --                            enrollment commencement type  w.r.t bug 2737703
  --svenkata    19-jun-2003	Changed the refernce to lookup code from CHK_TIME_UNT to CHK_TIME_UNIT. Bug 2829272
  --vkarthik    1-Jul-2004	Initialized variable l_hold_override to NULL
  --				inside the loop in the function ald_deny_all_hold local to eval_deny_all_hold
  --				for Bug 3449582
  -- smaddali   19-sep-04       Modified procedure eval_deny_all_hold for bug#3930876
  -- rvangala   16-Jul-2005     Logging error/warnings to warnings table
  --                            Created private function create_ss_warning, for Build #4377985
  -- bdeviset   09-SEP-2005     Modified the if condition related census date and hold start/end date in vald_deny_all_hold
  --                            for bug# 4590555
  -- ckasu      15-SEP-2005     Modified eval_person_Steps inoder to delete the warnings/error messages indorder to create
  --                            them during this run as a part  EN318 SS UI Admin Impact Build bug #4402631
  -- jnalam      15-NOV-2005     Modified c_intmsn_details for 4726839
  -- amuthu     18-Sep-2006     Added new function eval_rev_sus_all_hold
  -------------------------------------------------------------------------------------

--
-- forward declaration for function get_sys_pers_type
--
FUNCTION get_sys_pers_type (
                              p_person_type                     IN  VARCHAR2,
                              p_message                        OUT NOCOPY  VARCHAR2
                            )
RETURN VARCHAR2;

FUNCTION eval_deny_all_hold (
                              p_person_id                       IN  NUMBER,
                              p_person_type                     IN  VARCHAR2,
                              p_load_calendar_type              IN  VARCHAR2,
                              p_load_cal_sequence_number        IN  NUMBER,
                              p_enrollment_category             IN  VARCHAR2,
                              p_comm_type                       IN  VARCHAR2,
                              p_enrl_method                     IN  VARCHAR2,
                              p_message                        OUT NOCOPY  VARCHAR2
                            )
 RETURN BOOLEAN
 IS

 ------------------------------------------------------------------------------------
  --Created by  : smanglm ( Oracle IDC)
  --Date created: 19-JUN-2001
  --
  --Purpose:  Created as part of the build for DLD Enrollment Setup : Eligibility and Validation
  --          This function will check whether a hold with Deny All Enrollment acticity effect
  --          exists for the student or not. If yes, whether the hold is overridden or not. If not,
  --          validates the effective hold dates with the census date of Term/Teaching period.
  --          If the hold is effective on the census date then it returns False, meaning the
  --          student has some advising hold in the teaching period or term in which he is going
  --          to enroll
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -- smaddali 19-sep-04  For bug#3930876, removed the condition if l_person_type is not NULL and replaced it with p_person_type
  --                      before deriving the system person type, since this is a local variable
  -------------------------------------------------------------------------------------

    l_enr_method_type     igs_en_method_type.enr_method_type%TYPE;

    --
    -- cursor to check whether the CHKENCUMB is overridden or not
    --
    CURSOR c_chkencumb_override (cp_person_type igs_pe_usr_aval.person_type%TYPE) IS
           SELECT 'Y'
           FROM    igs_pe_usr_aval
           WHERE   validation = 'CHKENCUMB'
           AND     override_ind = 'Y'
           AND     person_type = cp_person_type;
    l_chkencumb_override    VARCHAR2(1) ;

    l_deny_all_hold   BOOLEAN;
    l_step_override   BOOLEAN;

    l_step_override_limit  igs_en_elgb_ovr_step.step_override_limit%TYPE;

    l_person_type          igs_pe_person_types.person_type_code%TYPE;

    FUNCTION vald_deny_all_hold
    RETURN BOOLEAN
    IS

    ------------------------------------------------------------------------------------
    --Created by  : smanglm ( Oracle IDC)
    --Date created: 19-JUN-2001
    --
    --Purpose:  local program unit to function eval_deny_all_hold
    --          This function will check if deny all hold effect is associated with the Hold or not
    --          and check if the hold is effective. If any of the hold type with deny all enrollment
    --          activity is effective return FALSE
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -------------------------------------------------------------------------------------

      --
      -- cursor to fecth all the holds of the student which has the hold effect of Deny all
      -- enrolment activity
      --
      CURSOR c_holds (cp_person_id igs_pe_pers_encumb.person_id%TYPE) IS
             SELECT   ppe.person_id,
                      ppe.encumbrance_type,
                      peff.pee_start_dt hold_start_dt,
                      peff.expiry_dt
             FROM     igs_pe_pers_encumb ppe,
                      igs_pe_persenc_effct peff
             WHERE    ppe.person_id = peff.person_id
             AND      ppe.encumbrance_type = peff.encumbrance_type
             AND      ppe.start_dt=peff.pen_start_dt
             AND      peff.s_encmb_effect_type = 'DENY_EACT'
             AND      ppe.person_id = cp_person_id;
      rec_holds       c_holds%ROWTYPE;

      --
      -- cursor to check whether the particular hold type for a person in a given term/teaching period
      -- is overridden or not
      --
      CURSOR c_hold_override (cp_person_id   igs_en_elgb_ovr_all.person_id%TYPE,
                              cp_hold_type   igs_pe_hold_rel_ovr.hold_type%TYPE) IS
             SELECT hro.hold_rel_or_ovr
             FROM   igs_en_elgb_ovr_all eoa,
                    igs_pe_hold_rel_ovr hro
             WHERE  eoa.elgb_override_id = hro.elgb_override_id
             AND    eoa.person_id = cp_person_id
             AND    eoa.cal_type = p_load_calendar_type
             AND    eoa.ci_sequence_number = p_load_cal_sequence_number
             AND    hro.hold_type = cp_hold_type;
      l_hold_override    igs_pe_hold_rel_ovr.hold_rel_or_ovr%TYPE;

      l_census_date      DATE;

    BEGIN
      --
      -- open the cursor c_hold to get the holds on a student which deny all enrl activity effect
      --
      FOR rec_holds IN c_holds (p_person_id)
      LOOP
        --
        -- check whether the hold is oevrridden for the student in the given load calendar/teaching period
        --
	-- initializing l_hold_override for Bug 3449582
        l_hold_override := NULL;
	OPEN c_hold_override (p_person_id, rec_holds.encumbrance_type);
        FETCH c_hold_override INTO l_hold_override;
        CLOSE c_hold_override;

        --
        -- if the hold type is not overridden i.e. l_hold_override <> 'O', check whether the sysdate
        -- is greater then hold start date and  less than hold expiry date or hold expiry date is null

	      IF nvl(l_hold_override,'Z') <> 'O' THEN
               /*    --
                   -- get the effective date for checking the hold
                   --

             l_census_date := igs_en_gen_015.get_effective_census_date
                                                (
                                                  p_load_cal_type                => p_load_calendar_type,
                                                  p_load_cal_seq_number          => p_load_cal_sequence_number,
                                                  p_teach_cal_type               => NULL,
                                                  p_teach_cal_seq_number         => NULL
                                                );    */

           IF  ((SYSDATE >= rec_holds.hold_start_dt)  AND
                ( rec_holds.expiry_dt IS NULL OR (SYSDATE < rec_holds.expiry_dt) )) THEN
               p_message := 'IGS_EN_ADV_HOLD';

	          RETURN FALSE;
           END IF;
        END IF;
      END LOOP;
      --
      -- the student does not have any hold with the deny all enrollment activity as cursor fetched zero records
      -- hence return TRUE
      --
      RETURN TRUE;
    END vald_deny_all_hold;



  --
  -- main begin for eval_deny_all_hold
  --
  BEGIN
    --
    -- assign the p_enrl_method to l_enr_method_type
    --
    l_enr_method_type := p_enrl_method;

    -- smaddali For bug#3930876, removed the condition if l_person_type is not NULL
    --    before deriving the system person type, since this is a local variable which will always be null
    -- get the system person type
    --
    IF p_person_type IS NOT NULL THEN
          l_person_type := get_sys_pers_type (
                                        p_person_type => p_person_type,
                                        p_message     => p_message
                                      );
    END IF;
    IF p_message IS NOT NULL THEN
       RETURN FALSE;
    END IF;


    --
    -- person type is STUDENT
    -- make a call to procedure to see whether the step is overriden or not
    --
    l_step_override := igs_en_gen_015.validation_step_is_overridden
                                 (
                                   p_eligibility_step_type        => 'CHKENCUMB',
                                   p_load_cal_type                => p_load_calendar_type,
                                   p_load_cal_seq_number          => p_load_cal_sequence_number,
                                   p_person_id                    => p_person_id,
                                   p_uoo_id                       => NULL,
                                   p_step_override_limit          => l_step_override_limit
                                );
    IF l_step_override THEN
      --
      -- return TRUE if the step is overridden for the passed person_type
      --
      RETURN TRUE;
    END IF;


    --
    -- check for the person type passed. If it is not student, check whether CHKENCUMB is overridden or not
    -- for passed person type
    --
    IF l_person_type <> 'STUDENT' THEN
       --
       -- open cursor c_chkencumb_override and see whether the CHKEMCUMB is oevrriden or not for the passed
       -- person_type
       --
       l_chkencumb_override := 'N';
       OPEN c_chkencumb_override (p_person_type);
       FETCH c_chkencumb_override INTO l_chkencumb_override;
       CLOSE c_chkencumb_override;
       IF l_chkencumb_override = 'Y' THEN
          --
          -- return TRUE if the step is overridden for the passed person_type
          --
          RETURN TRUE;
       END IF;
    END IF; -- check for person type

    -- now do validation of Deny All Enrollment Activity Hold
    -- call the function vald_deny_all_hold
    --
    l_deny_all_hold := vald_deny_all_hold;

    --
    -- depending on the return value of l_deny_all_hold, return from the main function
    --
    IF l_deny_all_hold THEN
       --
       -- validation of Deny All Enrollment Activity Hold returns TRUE
       --
       RETURN TRUE;
    ELSIF NOT l_deny_all_hold THEN
       --
       -- validation of Deny All Enrollment Activity Hold returns FALSE
       -- and the p_message has been assigned message in the vald_deny_all_hold
       -- program unit, hence just return FALSE
       --
       RETURN FALSE;
    END IF;
    RETURN TRUE;
  END eval_deny_all_hold;


FUNCTION eval_ss_rev_sus_all_hold (
                              p_person_id                       IN  NUMBER,
                              p_course_cd                       IN  VARCHAR2,
                              p_person_type                     IN  VARCHAR2,
                              p_load_calendar_type              IN  VARCHAR2,
                              p_load_cal_sequence_number        IN  NUMBER,
                              p_message                        OUT NOCOPY  VARCHAR2
                            )
 RETURN BOOLEAN
 IS

 ------------------------------------------------------------------------------------
  --Created by  : smanglm ( Oracle IDC)
  --Date created: 19-JUN-2001
  --
  --Purpose:  Created as part of the build for DLD Enrollment Setup : Eligibility and Validation
  --          This function will check whether a hold with revoke/susped all services effect
  --          exists for the student or not. If yes, whether the hold is overridden or not. If not,
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------------------------

    l_enr_method_type     igs_en_method_type.enr_method_type%TYPE;

    CURSOR get_enr_method IS
    SELECT enr_method_type FROM igs_en_method_type
    WHERE self_service = 'Y'
    AND   closed_ind = 'N';

    --
    -- cursor to check whether the CHKENCUMB is overridden or not
    --
    CURSOR c_chkencumb_override (cp_person_type igs_pe_usr_aval.person_type%TYPE) IS
           SELECT 'Y'
           FROM    igs_pe_usr_aval
           WHERE   validation = 'CHKENCUMB'
           AND     override_ind = 'Y'
           AND     person_type = cp_person_type;
    l_chkencumb_override    VARCHAR2(1) ;

    l_deny_all_hold   BOOLEAN;
    l_step_override   BOOLEAN;

    l_step_override_limit  igs_en_elgb_ovr_step.step_override_limit%TYPE;

    l_person_type          igs_pe_person_types.person_type_code%TYPE;

    FUNCTION vald_rev_sus_hold
    RETURN BOOLEAN
    IS

    ------------------------------------------------------------------------------------
    --Created by  : smanglm ( Oracle IDC)
    --Date created: 19-JUN-2001
    --
    --Purpose:  local program unit to function eval_deny_all_hold
    --          This function will check if deny all hold effect is associated with the Hold or not
    --          and check if the hold is effective. If any of the hold type with deny all enrollment
    --          activity is effective return FALSE
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    -------------------------------------------------------------------------------------

      --
      -- cursor to fecth all the holds of the student which has the hold effect of Deny all
      -- enrolment activity
      --
      CURSOR c_holds ( cp_person_id hz_parties.party_id%TYPE ) IS
                SELECT  ppe.person_id,
                        ppe.encumbrance_type,
                        peff.pee_start_dt hold_start_dt,
                        peff.expiry_dt
                FROM    igs_pe_pers_encumb ppe,
                        IGS_PE_PERSENC_EFFCT peff
                WHERE   ppe.encumbrance_type = peff.encumbrance_type
                AND     ppe.start_dt=peff.pen_start_dt
                AND     s_encmb_effect_type in ('SUS_SRVC','RVK_SRVC')
                AND     ppe.person_id = cp_person_id;

      --
      -- cursor to check whether the particular hold type for a person in a given term/teaching period
      -- is overridden or not
      --
      CURSOR c_hold_override (cp_person_id   igs_en_elgb_ovr_all.person_id%TYPE,
                              cp_hold_type   igs_pe_hold_rel_ovr.hold_type%TYPE) IS
             SELECT hro.hold_rel_or_ovr
             FROM   igs_en_elgb_ovr_all eoa,
                    igs_pe_hold_rel_ovr hro
             WHERE  eoa.elgb_override_id = hro.elgb_override_id
             AND    eoa.person_id = cp_person_id
             AND    eoa.cal_type = p_load_calendar_type
             AND    eoa.ci_sequence_number = p_load_cal_sequence_number
             AND    hro.hold_type = cp_hold_type;
      l_hold_override    igs_pe_hold_rel_ovr.hold_rel_or_ovr%TYPE;

      l_message_name     VARCHAR2(30);

    BEGIN
      --
      -- open the cursor c_hold to get the holds on a student which deny all enrl activity effect
      --
      FOR rec_holds IN c_holds (p_person_id)
      LOOP
        --
        -- check whether the hold is oevrridden for the student in the given load calendar/teaching period
        --
	-- initializing l_hold_override for Bug 3449582
        l_hold_override := NULL;
        OPEN c_hold_override (p_person_id, rec_holds.encumbrance_type);
        FETCH c_hold_override INTO l_hold_override;
        CLOSE c_hold_override;

        --
        -- if the hold type is not overridden i.e. l_hold_override <> 'O', check whether the sysdate
        -- is greater then hold start date and  less than hold expiry date or hold expiry date is null

        IF nvl(l_hold_override,'Z') <> 'O' THEN

          IF NOT IGS_EN_VAL_ENCMB.enrp_val_excld_prsn(
                                           p_person_id           => p_person_id,
                                           p_course_cd           => p_course_cd,
                                           p_effective_dt        => SYSDATE,
                                           p_message_name        => p_message
                                          ) THEN

            RETURN FALSE;

           END IF;
        END IF;
      END LOOP;
      --
      -- the student does not have any hold with the deny all enrollment activity as cursor fetched zero records
      -- hence return TRUE
      --
      RETURN TRUE;
    END vald_rev_sus_hold;



  --
  -- main begin for eval_deny_all_hold
  --
BEGIN
     p_message  := NULL;

     --Get the enrollment method for the self service responsibility.
     OPEN get_enr_method;
     FETCH get_enr_method INTO l_enr_method_type;
     IF get_enr_method%NOTFOUND THEN
        CLOSE get_enr_method;
        p_message := 'IGS_EN_ONE_SS_MTYP';
        RETURN FALSE;
     ELSE
        CLOSE get_enr_method;
     END IF;
    --
    -- assign the p_enrl_method to l_enr_method_type
    --

    -- smaddali For bug#3930876, removed the condition if l_person_type is not NULL
    --    before deriving the system person type, since this is a local variable which will always be null
    -- get the system person type
    --
    IF p_person_type IS NOT NULL THEN
          l_person_type := get_sys_pers_type (
                                        p_person_type => p_person_type,
                                        p_message     => p_message
                                      );
    END IF;
    IF p_message IS NOT NULL THEN
       RETURN FALSE;
    END IF;


    --
    -- person type is STUDENT
    -- make a call to procedure to see whether the step is overriden or not
    --
    l_step_override := igs_en_gen_015.validation_step_is_overridden
                                 (
                                   p_eligibility_step_type        => 'CHKENCUMB',
                                   p_load_cal_type                => p_load_calendar_type,
                                   p_load_cal_seq_number          => p_load_cal_sequence_number,
                                   p_person_id                    => p_person_id,
                                   p_uoo_id                       => NULL,
                                   p_step_override_limit          => l_step_override_limit
                                );
    IF l_step_override THEN
      --
      -- return TRUE if the step is overridden for the passed person_type
      --
      RETURN TRUE;
    END IF;


    --
    -- check for the person type passed. If it is not student, check whether CHKENCUMB is overridden or not
    -- for passed person type
    --
    IF l_person_type <> 'STUDENT' THEN
       --
       -- open cursor c_chkencumb_override and see whether the CHKEMCUMB is oevrriden or not for the passed
       -- person_type
       --
       l_chkencumb_override := 'N';
       OPEN c_chkencumb_override (p_person_type);
       FETCH c_chkencumb_override INTO l_chkencumb_override;
       CLOSE c_chkencumb_override;
       IF l_chkencumb_override = 'Y' THEN
          --
          -- return TRUE if the step is overridden for the passed person_type
          --
          RETURN TRUE;
       END IF;
    END IF; -- check for person type

    -- now do validation of Deny All Enrollment Activity Hold
    -- call the function vald_deny_all_hold
    --
    l_deny_all_hold := vald_rev_sus_hold;

    --
    -- depending on the return value of l_deny_all_hold, return from the main function
    --
    IF l_deny_all_hold THEN
       --
       -- validation of Deny All Enrollment Activity Hold returns TRUE
       --
       RETURN TRUE;
    ELSIF NOT l_deny_all_hold THEN
       --
       -- validation of Deny All Enrollment Activity Hold returns FALSE
       -- and the p_message has been assigned message in the vald_deny_all_hold
       -- program unit, hence just return FALSE
       --
       RETURN FALSE;
    END IF;
    RETURN TRUE;
  END eval_ss_rev_sus_all_hold;


FUNCTION eval_person_steps (
                              p_person_id                       IN  NUMBER,
                              p_person_type                     IN  VARCHAR2,
                              p_load_calendar_type              IN  VARCHAR2,
                              p_load_cal_sequence_number        IN  NUMBER,
                              p_program_cd                      IN  VARCHAR2,
                              p_program_version                 IN  NUMBER,
                              p_enrollment_category             IN  VARCHAR2,
                              p_comm_type                       IN  VARCHAR2,
                              p_enrl_method                     IN  VARCHAR2,
                              p_message                        OUT NOCOPY  VARCHAR2,
                              p_deny_warn                      OUT NOCOPY  VARCHAR2,
                              p_calling_obj                     IN VARCHAR2,
                              p_create_warning                  IN VARCHAR2
                            )
 RETURN BOOLEAN
 IS

 ------------------------------------------------------------------------------------
  --Created by  : smanglm ( Oracle IDC)
  --Date created: 19-JUN-2001
  --
  --Purpose:  Created as part of the build for DLD Enrollment Setup : Eligibility and Validation
  --          This function will validate all of the selected Person Steps based on the rules
  --          setup by the institution in the Enrollment Category Validations form and the
  --          self service user activity set up form.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --ayedubat    11-APR-2002    Changed the cursors,c_non_stud_vald_steps and c_stud_vald_steps to add an extra 'OR'
  --                           condition(eru.s_student_comm_type = 'ALL') for s_student_comm_type as part of the bug fix: 2315245
  --Nishikant    01NOV2002     SEVIS Build. Enh Bug#2641905. notification flag was
  --                           being fetched from cursor, now modified to get it by
  --                           calling the function igs_ss_enr_details.get_notification.
  --
  -------------------------------------------------------------------------------------

    l_enr_method_type     igs_en_method_type.enr_method_type%TYPE;

    --
    -- cursor to fetch validation steps for the person type not equal to STUDENT
    --
    CURSOR c_non_stud_vald_steps (cp_enr_method_type    igs_en_cpd_ext.enr_method_type%TYPE) IS
           SELECT  eru.s_enrolment_step_type, eru.enrolment_cat, eru.s_student_comm_type, eru.enr_method_type, lkup.step_group_type,
                   eru.s_rule_call_cd,
                   eru.rul_sequence_number
           FROM    igs_en_cpd_ext eru,
                   igs_pe_usr_aval_all uact,
                   igs_lookups_view lkup
           WHERE   eru.s_enrolment_step_type = lkup.lookup_code
           AND     lkup.lookup_type = 'ENROLMENT_STEP_TYPE_EXT'
           AND     lkup.step_group_type = 'PERSON'
           AND     eru.s_enrolment_step_type = uact.validation (+)
           AND     uact.person_type (+) = p_person_type
           AND     nvl(uact.override_ind,'N') = 'N'
                 AND     eru.enrolment_cat = p_enrollment_category
           AND    (eru.s_student_comm_type = p_comm_type OR eru.s_student_comm_type = 'ALL')
                 AND     eru.enr_method_type = cp_enr_method_type
           ORDER BY eru.step_order_num;

    --
    -- cursor to fetch validation steps for the person type equal to STUDENT
    --
    CURSOR c_stud_vald_steps (cp_enr_method_type    igs_en_cpd_ext.enr_method_type%TYPE) IS
           SELECT  eru.s_enrolment_step_type, eru.enrolment_cat, eru.s_student_comm_type, eru.enr_method_type, lkup.step_group_type,
                   eru.s_rule_call_cd,
                   eru.rul_sequence_number
           FROM    igs_en_cpd_ext eru,
                   igs_lookups_view lkup
           WHERE   eru.s_enrolment_step_type = lkup.lookup_code
           AND     lkup.lookup_type = 'ENROLMENT_STEP_TYPE_EXT'
           AND     lkup.step_group_type = 'PERSON'
                 AND     eru.enrolment_cat = p_enrollment_category
                 AND    (eru.s_student_comm_type = p_comm_type OR eru.s_student_comm_type = 'ALL')
                 AND     eru.enr_method_type = cp_enr_method_type
           ORDER BY eru.step_order_num;

    rec_vald_steps         c_stud_vald_steps%ROWTYPE;

    l_vald_person_steps    BOOLEAN;
    l_step_override_limit  igs_en_elgb_ovr_step.step_override_limit%TYPE;
    l_person_type          igs_pe_person_types.person_type_code%TYPE;
    l_notification_flag    igs_en_cpd_ext.notification_flag%TYPE; --added by nishikant
    l_message              VARCHAR2(2000);
    l_deny_person_steps BOOLEAN;
    l_warn_person_steps BOOLEAN;
    l_steps             VARCHAR2(100);
   PROCEDURE create_ss_warning(p_message_for	IN IGS_EN_STD_WARNINGS.message_for%TYPE,
   							   p_message_icon	IN IGS_EN_STD_WARNINGS.message_icon%TYPE,
							   p_message_name	IN IGS_EN_STD_WARNINGS.message_name%TYPE,
                               p_message_rule_text IN IGS_PS_UNIT_VER_RU_V.rule_text%TYPE) IS
    ------------------------------------------------------------------------------------
    --Created by  : rvangala
    --Date created: 16-JUN-2005
    --
    --Purpose:  Function to create/update errors/warnings in the warnings table
    --
    --
    ------------------------------------------------------------------------------------

    BEGIN
                IGS_EN_DROP_UNITS_API.create_ss_warning(p_person_id => p_person_id,
                     p_course_cd   => p_program_cd,
                     p_term_cal_type => p_load_calendar_type,
                     p_term_ci_sequence_number => p_load_cal_sequence_number,
		             p_uoo_id  => null,
		             p_message_for => p_message_for,
		             p_message_icon => p_message_icon,
		             p_message_name   => p_message_name,
                     p_message_rule_text => p_message_rule_text,
                     p_message_tokens	=> null,
		             p_message_action => null,
		             p_destination    => null,
		             p_parameters     => null,
		             p_step_type      => 'PERSON');

    END create_ss_warning;


    FUNCTION vald_person_steps
    RETURN BOOLEAN
    IS

    ------------------------------------------------------------------------------------
    --Created by  : smanglm ( Oracle IDC)
    --Date created: 19-JUN-2001
    --
    --Purpose:  local program unit to function eval_person_steps
    --          This function will validate the person steps
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    --ayedubat    24-JUN-2002    Modified the cursor,c_padm_tr_req in vald_person_steps added to new
    --                           parameters: cp_person_id and cp_course_cd which retrieves only the
    --                           records of the student program in context for the bug fix: 2427528
    --svanukur    31-may-03      Added the validation for PersonLevel Timeslot by invoking eval_timeslot
    --                            as part of DENY/WARN behaviour build 2829272.
    -- rnirwani   13-Sep-2004    changed cursor c_intmsn_details  to not consider logically deleted records and
    --				also to avoid un-approved intermission records. Bug# 3885804
    -------------------------------------------------------------------------------------

      l_step_overridden   BOOLEAN;
      l_return_val        VARCHAR2(10);
      l_message_text      VARCHAR2(2000);
      l_message_name      VARCHAR2(2000);

      --
      -- cursor to fetch the adm_appl_number and adm_sequence_number
      --
      CURSOR c_adm_sts IS
             SELECT adm_admission_appl_number,
                    adm_sequence_number
             FROM   igs_en_stdnt_ps_att
             WHERE  person_id = p_person_id
             AND    course_cd = p_program_cd
             AND    version_number = p_program_version;
      rec_adm_sts    c_adm_sts%ROWTYPE;

      --
      -- cursor to check whether the student has completed some post admission tracking requirements
      -- As part of Bug 2343417 modified 'POST-ADM' to 'POST_ADMISSION'
      CURSOR c_padm_tr_req (cp_person_id        igs_en_stdnt_ps_att.person_id%TYPE,
                            cp_course_cd        igs_en_stdnt_ps_att.course_cd%TYPE,
                            cp_adm_appl_number  igs_en_stdnt_ps_att.adm_admission_appl_number%TYPE,
                            cp_adm_seq_number   igs_en_stdnt_ps_att.adm_sequence_number%TYPE) IS
             SELECT 'TRUE'
             FROM   igs_tr_item ti,
                    igs_tr_status ts
             WHERE  ts.tracking_status = ti.tracking_status
             AND    ts.s_tracking_status <> 'COMPLETE'
             AND    ti.tracking_id IN ( SELECT ad.tracking_id
                                          FROM   igs_tr_type tt,
                                                 igs_tr_item ti,
                                                 igs_ad_aplins_admreq ad
                                          WHERE  tt.s_tracking_type = 'POST_ADMISSION'
                                          AND    ad.tracking_id = ti.tracking_id
                                          AND    ti.tracking_type = tt.tracking_type
                                          AND    ad.person_id = cp_person_id
                                          AND    ad.course_cd = cp_course_cd
                                          AND    ad.admission_appl_number = cp_adm_appl_number
                                          AND    ad.sequence_number = cp_adm_seq_number );
       rec_padm_tr_req     c_padm_tr_req%ROWTYPE;

       --
       -- cursor to fetch the intermission records of the program passed
       --
       CURSOR c_intmsn_details IS
              SELECT sci.intermission_type,
                     sci.start_dt
              FROM   igs_en_stdnt_ps_intm sci,
                     IGS_EN_INTM_TYPES eit,
                     igs_en_stdnt_ps_att spa
              WHERE  sci.person_id = p_person_id
              AND    sci.course_cd = p_program_cd
              AND    sci.logical_delete_date = TO_DATE('31-12-4712','DD-MM-YYYY')
              AND    sci.approved  = eit.appr_reqd_ind
              AND    eit.intermission_type = sci.intermission_type
              AND    spa.person_id = sci.person_id
              AND    spa.course_cd = sci.course_cd
              AND    ((trunc(sysdate) between sci.start_dt and sci.end_dt)
                     OR
                     ((trunc(sysdate) > sci.end_dt) AND (spa.course_attempt_status = 'INTERMIT')));

        --
        -- cursor to fetch the visa records of the student
        --
        CURSOR c_visa_details IS
               SELECT visa_type,
                      visa_number
               FROM   igs_pe_visa
               WHERE  person_id = p_person_id;

    --
    -- begin for local program unit vald_person_steps
    --
    l_rule_text VARCHAR2(1000);
    BEGIN
      --
      -- check that the eligibility validation step rec_vald_steps.s_enrolment_step_type is not overridden
      -- else return TRUE
      --
      l_step_overridden := igs_en_gen_015.validation_step_is_overridden
                                     (
                                       p_eligibility_step_type        => rec_vald_steps.s_enrolment_step_type,
                                       p_load_cal_type                => p_load_calendar_type,
                                       p_load_cal_seq_number          => p_load_cal_sequence_number,
                                       p_person_id                    => p_person_id,
                                       p_uoo_id                       => NULL,
                                       p_step_override_limit          => l_step_override_limit
                                    );
      IF l_step_overridden THEN
         RETURN TRUE;
      END IF;
      --
      -- check the step type to be validated from the record type variable rec_vald_steps
      -- if any of the validation procedure encounters a warning message asign the warning messages to the
      -- variable p_message separated by delimiter semicolon (;) and continue validating the other steps
      -- Only if an Error Condition occurs, return to the calling procedure
      --

      IF rec_vald_steps.s_enrolment_step_type = 'ADM_STS' THEN --Admission Status
         --
         -- select the application details of the primary program and check whether the adm status rules are
         -- satisfied by calling the Rules evaluation procedure.
         --
         FOR rec_adm_sts IN c_adm_sts
         LOOP
             IF rec_vald_steps.rul_sequence_number IS NOT NULL AND
                rec_adm_sts.adm_sequence_number IS NOT NULL AND
                rec_adm_sts.adm_admission_appl_number IS NOT NULL  THEN

                l_return_val := null;
                l_message_text := null;
                --
                -- call the rule function rulp_val_senna
                --
                l_return_val := igs_ru_gen_001.rulp_val_senna (
                                                                p_rule_call_name => 'ADM_STS',
                                                                p_rule_number    => rec_vald_steps.rul_sequence_number,
                                                                p_person_id      => p_person_id,
                                                                p_param_1        => nvl(rec_adm_sts.adm_admission_appl_number,-99),
                                                                p_param_2        => p_program_cd,
                                                                p_param_3        => nvl(rec_adm_sts.adm_sequence_number,-99),
                                                                p_message        => l_message_text
                                                              );
                IF upper(l_return_val) = 'TRUE' THEN
                   --
                   -- if any of the application details returns true, no need to check for other records
                   --
                   EXIT;
                END IF;
             END IF; -- check for rec_vald_steps.rul_sequence_number
         END LOOP;


          IF upper(l_return_val) <> 'TRUE' THEN
           l_rule_text := null;
            IF(NVL(fnd_profile.value('IGS_EN_CART_RULE_DISPLAY'),'N')='Y') THEN
              l_rule_text := igs_ru_gen_003.Rulp_Get_Rule(rec_vald_steps.rul_sequence_number );
            END IF;

           IF l_notification_flag = 'DENY' THEN
	    	-- rule validation failed and notification flag is DENY, return FALSE
		   l_deny_person_steps := TRUE;

           IF p_create_warning = 'Y' THEN
		      -- create warning record
              create_ss_warning( igs_ss_enroll_pkg.enrf_get_lookup_meaning
                                   (p_lookup_code => 'ADM_STS',
                                    p_lookup_type => 'ENROLMENT_STEP_TYPE_EXT'),
                                    'D','IGS_SS_DENY_ADM_STAT',l_rule_text);
    	   ELSE
			  p_message := p_message||';'||'IGS_SS_DENY_ADM_STAT';
		   END IF;

		  RETURN FALSE;
         ELSIF  l_notification_flag = 'WARN' THEN
		-- rule validation failed and notification flag is WARN, append the message
	   	   l_warn_person_steps := TRUE;
           IF p_create_warning = 'Y' THEN
		    -- create warning record
            create_ss_warning(igs_ss_enroll_pkg.enrf_get_lookup_meaning
                                   (p_lookup_code => 'ADM_STS',
                                    p_lookup_type => 'ENROLMENT_STEP_TYPE_EXT'),
                                    'W','IGS_SS_WARN_ADM_STAT',l_rule_text);
		  ELSE
			p_message := p_message||';'||'IGS_SS_WARN_ADM_STAT';
          END IF;
   		  RETURN TRUE;
		 END IF;

	    END IF;

      ELSIF rec_vald_steps.s_enrolment_step_type = 'PADM_STS' THEN  -- Post Admission Status
         --
         -- get the student application details
         --
         FOR rec_adm_sts IN c_adm_sts
         LOOP
            l_return_val := null;
            --
            -- select all the tracking type with system defined tracking type = Post Admission Status attached
            -- to the student from the Admission Application Tracking Details.
            --
            -- check whether the student has completed the post admission tracking requirements
            --
            OPEN c_padm_tr_req (p_person_id,
                                p_program_cd,
                                rec_adm_sts.adm_admission_appl_number,
                                rec_adm_sts.adm_sequence_number);

            FETCH c_padm_tr_req INTO l_return_val;
            CLOSE c_padm_tr_req;

            IF upper(NVL(l_return_val,'FALSE'))  = 'TRUE' THEN
               --
               -- if any of the tracking types for application details returns true, no need to check for other records
               --
               EXIT;
            END IF;
         END LOOP;

       IF upper(l_return_val) = 'TRUE' THEN
           l_rule_text := null;
           IF(NVL(fnd_profile.value('IGS_EN_CART_RULE_DISPLAY'),'N')='Y') THEN
              l_rule_text := igs_ru_gen_003.Rulp_Get_Rule(rec_vald_steps.rul_sequence_number );
           END IF;

           IF l_notification_flag = 'DENY' THEN
		-- rule validation failed and notification flag is DENY, return FALSE
   		  l_deny_person_steps := TRUE;
		IF p_create_warning = 'Y' THEN
            -- create warning record
            create_ss_warning(igs_ss_enroll_pkg.enrf_get_lookup_meaning
                                   (p_lookup_code => 'PADM_STS',
                                    p_lookup_type => 'ENROLMENT_STEP_TYPE_EXT'),
                                    'D','IGS_SS_DENY_POST_ADM_STAT',l_rule_text);
		ELSE
			p_message := p_message||';'||'IGS_SS_DENY_POST_ADM_STAT';
		END IF;
		RETURN FALSE;
	    ELSIF  l_notification_flag = 'WARN' THEN
		-- rule validation failed and notification flag is WARN, append the message
		l_warn_person_steps := TRUE;
		IF p_create_warning = 'Y' THEN
            -- create warning record
            create_ss_warning(igs_ss_enroll_pkg.enrf_get_lookup_meaning
                                   (p_lookup_code => 'PADM_STS',
                                    p_lookup_type => 'ENROLMENT_STEP_TYPE_EXT'),
                                    'W','IGS_SS_WARN_POST_ADM_STAT',l_rule_text);
		 ELSE
			p_message := p_message||';'||'IGS_SS_WARN_POST_ADM_STAT';
	 	 END IF;
 		RETURN TRUE;
	    END IF;
	 END IF;


      ELSIF rec_vald_steps.s_enrolment_step_type = 'CONTD_STS' THEN -- Continuing Status
         --
         -- perform the continuing status validation only if the rule is defined
         --
         IF rec_vald_steps.rul_sequence_number IS NOT NULL THEN
           l_return_val:= null;
           l_message_text := null;
                --
                -- call the rule function rulp_val_senna
                --
                l_return_val := igs_ru_gen_001.rulp_val_senna (
                                                                p_rule_call_name => 'CONTD_STS',
                                                                p_rule_number    => rec_vald_steps.rul_sequence_number,
                                                                p_person_id      => p_person_id,
                                                                p_param_1        => p_program_cd,
                                                                p_param_2        => p_program_version,
                                                                p_message        => l_message_text
                                                              );
           IF upper(l_return_val) <> 'TRUE' THEN
            l_rule_text := null;
            IF(NVL(fnd_profile.value('IGS_EN_CART_RULE_DISPLAY'),'N')='Y') THEN
              l_rule_text := igs_ru_gen_003.Rulp_Get_Rule(rec_vald_steps.rul_sequence_number );
            END IF;

		     IF l_notification_flag = 'DENY' THEN
			-- rule validation failed and notification flag is DENY, return FALSE
			  l_deny_person_steps := TRUE;
			  IF p_create_warning = 'Y' THEN
                -- create warning record
                create_ss_warning(igs_ss_enroll_pkg.enrf_get_lookup_meaning
                                   (p_lookup_code => 'CONTD_STS',
                                    p_lookup_type => 'ENROLMENT_STEP_TYPE_EXT'),
                                    'D','IGS_SS_DENY_CONT_ADM_STAT',l_rule_text);
			  ELSE
				p_message := p_message||';'||'IGS_SS_DENY_CONT_ADM_STAT';
			  END IF;
			 RETURN FALSE;
		    ELSIF  l_notification_flag = 'WARN' THEN
			-- rule validation failed and notification flag is WARN, append the message
			l_warn_person_steps := TRUE;
			IF p_create_warning = 'Y' THEN
               -- create warning record
               create_ss_warning(igs_ss_enroll_pkg.enrf_get_lookup_meaning
                                   (p_lookup_code => 'CONTD_STS',
                                    p_lookup_type => 'ENROLMENT_STEP_TYPE_EXT'),
                                    'W','IGS_SS_WARN_CONT_ADM_STAT',l_rule_text);
			ELSE
				p_message := p_message||';'||'IGS_SS_WARN_CONT_ADM_STAT';
			END IF;

			RETURN TRUE;
		    END IF;
          END IF;
         END IF; --end of rec_vald_steps.rul_sequence_number IS NOT NULL


      ELSIF rec_vald_steps.s_enrolment_step_type = 'INTMSN_STS' THEN -- Intermission Status
         --
         -- perform the validation for the intermission status only if the rule is defined.
         --
         IF rec_vald_steps.rul_sequence_number IS NOT NULL THEN
            --
            -- fetch the intermission records of the program passed
            --
            FOR rec_intmsn_details IN c_intmsn_details
            LOOP
              l_return_val := null;
              l_message_text := null;
                --
                -- call the rule function rulp_val_senna
                --
                l_return_val := igs_ru_gen_001.rulp_val_senna (
                                                                p_rule_call_name => 'INTMSN_STS',
                                                                p_rule_number    => rec_vald_steps.rul_sequence_number,
                                                                p_person_id      => p_person_id,
                                                                p_param_1        => p_program_cd,
                                                                p_param_2        => nvl(rec_intmsn_details.intermission_type,'-99'),
                                                                p_param_3        => rec_intmsn_details.start_dt,
                                                                p_param_4        => p_load_calendar_type,
                                                                p_param_5        => p_load_cal_sequence_number,
                                                                p_message        => l_message_text
                                                              );

                IF upper(l_return_val) = 'TRUE' THEN
                   --
                   -- if the student satisfies the rules for any one of the record, do not check for the remaining records
                   --
                   EXIT;
                END IF;
            END LOOP;

            IF upper(l_return_val) <> 'TRUE' THEN
             l_rule_text := null;
             IF(NVL(fnd_profile.value('IGS_EN_CART_RULE_DISPLAY'),'N')='Y') THEN
              l_rule_text := igs_ru_gen_003.Rulp_Get_Rule(rec_vald_steps.rul_sequence_number );
             END IF;

  	    	  IF l_notification_flag = 'DENY' THEN
			-- rule validation failed and notification flag is DENY, return FALSE
			l_deny_person_steps := TRUE;
  		      IF p_create_warning = 'Y' THEN
               -- create warning record
                create_ss_warning(igs_ss_enroll_pkg.enrf_get_lookup_meaning
                                   (p_lookup_code => 'INTMSN_STS',
                                    p_lookup_type => 'ENROLMENT_STEP_TYPE_EXT'),
                                    'D','IGS_SS_DENY_INTERMIT_STAT',l_rule_text);
			  ELSE
				p_message := p_message||';'||'IGS_SS_DENY_INTERMIT_STAT';
			  END IF;
			 RETURN FALSE;
		    ELSIF  l_notification_flag = 'WARN' THEN
			-- rule validation failed and notification flag is WARN, append the message
			l_warn_person_steps := TRUE;
			  IF p_create_warning = 'Y' THEN
                -- create warning record
                create_ss_warning(igs_ss_enroll_pkg.enrf_get_lookup_meaning
                                   (p_lookup_code => 'INTMSN_STS',
                                    p_lookup_type => 'ENROLMENT_STEP_TYPE_EXT'),
                                    'W','IGS_SS_WARN_INTERMIT_STAT',l_rule_text);
			   ELSE
				p_message := p_message||';'||'IGS_SS_WARN_INTERMIT_STAT';
			   END IF;
			  RETURN TRUE;
		      END IF;
	     END IF; -- IF upper(l_return_val) <> 'TRUE'

        END IF;

      ELSIF rec_vald_steps.s_enrolment_step_type = 'VISA_STS' THEN -- Visa Status
         --
         -- perform the validation for the visa status only if the rule is defined.
         --
         IF rec_vald_steps.rul_sequence_number IS NOT NULL THEN
            --
            -- fetch the visa records of the student
            --
            FOR rec_visa_details IN c_visa_details
            LOOP
              l_return_val := null;
              l_message_text := null;
                --
                -- call the rule function rulp_val_senna
                --
                l_return_val := igs_ru_gen_001.rulp_val_senna (
                                                                p_rule_call_name => 'VISA_STS',
                                                                p_rule_number    => rec_vald_steps.rul_sequence_number,
                                                                p_person_id      => p_person_id,
                                                                p_param_1        => rec_visa_details.visa_type,
                                                                p_param_2        => p_load_calendar_type,
                                                                p_param_3        => p_load_cal_sequence_number,
                                                                p_param_6        => rec_visa_details.visa_number,
                                                                p_message        => l_message_text
                                                              );

                IF upper(l_return_val) = 'TRUE' THEN
                   --
                   -- if the student satisfies the rules for any one of the record, do not check for the remaining records
                   --
                   EXIT;
                END IF;
            END LOOP;

           IF upper(l_return_val) <> 'TRUE' THEN
             l_rule_text := null;
             IF(NVL(fnd_profile.value('IGS_EN_CART_RULE_DISPLAY'),'N')='Y') THEN
              l_rule_text := igs_ru_gen_003.Rulp_Get_Rule(rec_vald_steps.rul_sequence_number );
             END IF;

	    	IF l_notification_flag = 'DENY' THEN
			-- rule validation failed and notification flag is DENY, return FALSE
			l_deny_person_steps := TRUE;
			 IF p_create_warning = 'Y' THEN
   		        -- create warning record
                create_ss_warning(igs_ss_enroll_pkg.enrf_get_lookup_meaning
                                   (p_lookup_code => 'VISA_STS',
                                    p_lookup_type => 'ENROLMENT_STEP_TYPE_EXT'),
                                    'D','IGS_SS_DENY_VISA_STAT',l_rule_text);
			ELSE
				p_message := p_message||';'||'IGS_SS_DENY_VISA_STAT';
			END IF;
			RETURN FALSE;
		    ELSIF  l_notification_flag = 'WARN' THEN
			-- rule validation failed and notification flag is WARN, append the message
			l_warn_person_steps := TRUE;
			IF p_create_warning = 'Y' THEN
				-- create warning record
				create_ss_warning(igs_ss_enroll_pkg.enrf_get_lookup_meaning
                                   (p_lookup_code => 'VISA_STS',
                                    p_lookup_type => 'ENROLMENT_STEP_TYPE_EXT'),
                                    'W','IGS_SS_WARN_VISA_STAT',l_rule_text);
			ELSE
				p_message := p_message||';'||'IGS_SS_WARN_VISA_STAT';
			END IF;
			RETURN TRUE;
		    END IF;
  	      END IF;
         END IF;


      ELSIF rec_vald_steps.s_enrolment_step_type = 'CHK_TIME_PER' THEN
        IF p_calling_obj IN ('PLAN','ENROLPEND','JOB') THEN
          RETURN TRUE;
        ELSE

        IF NOT eval_timeslot(
                              p_person_id => p_person_id,
                              p_person_type => p_person_type,
                              p_load_calendar_type => p_load_calendar_type,
                              p_load_cal_sequence_number => p_load_cal_sequence_number,
                              p_uoo_id  => NULL,
                              p_enrollment_category => p_enrollment_category,
                              p_comm_type  => p_comm_type,
                              p_enrl_method => p_enrl_method,
                              p_message => l_message_name,
                  p_notification_flag => l_notification_flag
          ) THEN

          IF l_message_name NOT IN ('IGS_SS_DENY_TSLOT', 'IGS_SS_WARN_TSLOT') then
               p_message := p_message||';'||l_message_name;
               p_deny_warn := 'DENY';
               RETURN FALSE;
          END IF;

		   IF l_notification_flag = 'DENY' AND l_message_name IS NOT NULL THEN
			-- rule validation failed and notification flag is DENY, return FALSE
			l_deny_person_steps := TRUE;
			IF p_create_warning='Y' THEN
              -- create warning record
              create_ss_warning(igs_ss_enroll_pkg.enrf_get_lookup_meaning
                                   (p_lookup_code => 'CHK_TIME_PER',
                                    p_lookup_type => 'ENROLMENT_STEP_TYPE_EXT'),
                                    'D',l_message_name,null);
			ELSE
				p_message := p_message||';'||l_message_name;
			END IF;
			RETURN FALSE;

		    ELSIF  l_notification_flag = 'WARN' AND l_message_name IS NOT NULL THEN
			-- rule validation failed and notification flag is WARN, append the message
			l_warn_person_steps := TRUE;
  			 IF p_create_warning = 'Y' THEN
			    -- create warning record
                create_ss_warning(igs_ss_enroll_pkg.enrf_get_lookup_meaning
                                   (p_lookup_code => 'CHK_TIME_PER',
                                    p_lookup_type => 'ENROLMENT_STEP_TYPE_EXT'),
                                    'W',l_message_name,null);
			 ELSE
				p_message := p_message||';'||l_message_name;
			 END IF;
			RETURN TRUE;

           END IF;
	      END IF; --  IF NOT eval_timeslot
        END IF; --  P_calling_obj = 'PLAN'

      END IF; -- check for rec_vald_steps.s_enrolment_step_type

      --
      -- either the steps have validated or there is some warning message
      --
      RETURN TRUE;
    END vald_person_steps;
 --
 -- main begin for eval_person_steps
 --
 BEGIN
     l_deny_person_steps := FALSE;
     l_warn_person_steps := FALSE;
    --
    -- assign the p_enrl_method to l_enr_method_type
    --
    l_enr_method_type := p_enrl_method;
    IF p_person_type IS NOT NULL THEN
            --
            -- get the system person type
            --
            l_person_type := get_sys_pers_type (
                                                 p_person_type => p_person_type,
                                                 p_message     => p_message
                                               );
            IF p_message IS NOT NULL THEN
               p_deny_warn := 'DENY';
               RETURN FALSE;
            END IF;
    END IF;
    --
    -- check for the person type, if not student select only those steps which are not overridden for
    -- the given person type
    --

    -- added by ckasu as a prt of EN318 SS Admin Impact Build inorder to delete
    -- Person step Warning or Error Record when Create warnings is set to 'Y'.

    IF p_create_warning = 'Y' THEN
         l_steps := 'PERSON';
         igs_en_add_units_api.delete_ss_warnings(p_person_id,
                         p_program_cd,
                         p_load_calendar_type,
                         p_load_cal_sequence_number,
                         NULL, -- uoo_id
                         NULL, -- message_for
                         l_steps);
    END IF; -- end of IF p_create_warning = 'N'


    IF l_person_type <> 'STUDENT' THEN

       FOR  r_vald_steps IN c_non_stud_vald_steps (l_enr_method_type)
       LOOP
         --
         -- make a call to local program unit vald_person_steps
         -- also copy the r_vald_steps to global variable rec_vald_steps as r_vald_steps will
         -- not be visible outside the FOR LOOP and END LOOP
         --
         rec_vald_steps := r_vald_steps;
         l_notification_flag := igs_ss_enr_details.get_notification(
                                   p_person_type         => p_person_type,
                                   p_enrollment_category => rec_vald_steps.enrolment_cat,
                                   p_comm_type           => rec_vald_steps.s_student_comm_type,
                                   p_enr_method_type     => rec_vald_steps.enr_method_type,
                                   p_step_group_type     => rec_vald_steps.step_group_type,
                                   p_step_type           => rec_vald_steps.s_enrolment_step_type,
                                   p_person_id           => p_person_id ,
                                   p_message             => l_message);
         IF l_message IS NOT NULL THEN
            p_message := l_message;
            p_deny_warn := 'DENY';

	    RETURN FALSE;
         END IF;

	 l_vald_person_steps := vald_person_steps;
         --
         -- if any of the step validation returns FALSE, return FALSE and no need to check further records
         --
         IF NOT l_vald_person_steps THEN
          IF p_calling_obj = 'JOB' OR  p_create_warning = 'N' THEN
            EXIT;
          END IF;
         END IF;
       END LOOP;
    ELSE
       FOR  r_vald_steps IN c_stud_vald_steps (l_enr_method_type)
       LOOP
         --
         -- make a call to local program unit vald_person_steps
         -- also copy the r_vald_steps to global variable rec_vald_steps as r_vald_steps will
         -- not be visible outside the FOR LOOP and END LOOP
         --
         rec_vald_steps := r_vald_steps;
         l_notification_flag := igs_ss_enr_details.get_notification(
                                   p_person_type         => p_person_type,
                                   p_enrollment_category => rec_vald_steps.enrolment_cat,
                                   p_comm_type           => rec_vald_steps.s_student_comm_type,
                                   p_enr_method_type     => rec_vald_steps.enr_method_type,
                                   p_step_group_type     => rec_vald_steps.step_group_type,
                                   p_step_type           => rec_vald_steps.s_enrolment_step_type,
                                   p_person_id           => p_person_id,
                                   p_message             => l_message);
         IF l_message IS NOT NULL THEN
            p_message := l_message;
            p_deny_warn := 'DENY';

	    RETURN FALSE;
         END IF;
         l_vald_person_steps := vald_person_steps;
         --
         -- if any of the step validation returns FALSE, return FALSE if called from jobs,and no need to check further records
         -- but if called from self service, we need to log all possible failures
         IF NOT l_vald_person_steps THEN
          IF p_calling_obj = 'JOB' OR  p_create_warning = 'N' THEN
            EXIT ;
          END IF;
         END IF;
       END LOOP;
    END IF;

    IF l_deny_person_steps THEN
       --
       -- validation of person steps returns TRUE
       --
       IF p_message IS NOT NULL THEN
          --
          -- that is there are few warning messages so assign WARN to p_deny_warn and remove ';'
          -- from the beginning and end of p_message
          --
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
    ELSIF l_warn_person_steps THEN
       --
       -- validation of person steps returns FALSE
       -- and the p_message and p_deny_warn have been assigned value in the vald_person_steps
       -- program unit, hence just return FALSE
       --
       -- As part of Bug 2343417 added below code to remove ';' from p_message
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
    RETURN TRUE;

 END eval_person_steps;




 FUNCTION eval_timeslot    (
                              p_person_id                       IN  NUMBER,
                              p_person_type                     IN  VARCHAR2,
                              p_load_calendar_type              IN  VARCHAR2,
                              p_load_cal_sequence_number        IN  NUMBER,
                              p_uoo_id                          IN  NUMBER,
                              p_enrollment_category             IN  VARCHAR2,
                              p_comm_type                       IN  VARCHAR2,
                              p_enrl_method                     IN  VARCHAR2,
                              p_message                          OUT NOCOPY  VARCHAR2,
			      p_notification_flag               IN VARCHAR2
                            )
 RETURN BOOLEAN
 IS

 ------------------------------------------------------------------------------------
  --Created by  : smanglm ( Oracle IDC)
  --Date created: 19-JUN-2001
  --
  --Purpose:  Created as part of the build for DLD Enrollment Setup : Eligibility and Validation
  --          This function validates the time slot registration times assigned to the student
  --          against SYSDATE when the CHK_TIME_PER person step is selected in the Enrollment
  --          Category Procedure Details Form. The function returns DENY or WARN messages if
  --          the student is not eligible to register. The validation is done for the Term
  --          calendar.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --Bayadav    11-OCt-2001      Modified the validation of timeslots as a part of enh bug:2043044
  --Bayadav    30-Oct-2001      Corrected the code comparing date by removing to_char function
  --  svanukur     31-may-03     Converted the person?unit step timeslot validation step which can be configured for DENY or WARN
  --                           Added a new parameter p_notification_flag and modified p_message to IN OUT as per the Deny/Warn behaviour build # 2829272
  -------------------------------------------------------------------------------------------------

    l_enr_method_type     igs_en_method_type.enr_method_type%TYPE;
    l_step                igs_en_cat_prc_step.s_enrolment_step_type%TYPE;
    l_vald_timeslot       BOOLEAN;
    --
    -- cursor to check whether the step is oevrridden or not
    --

    l_step_override    BOOLEAN;

    l_person_type          igs_pe_person_types.person_type_code%TYPE;
    l_step_override_limit  igs_en_elgb_ovr_step.step_override_limit%TYPE;

    FUNCTION vald_timeslot
    RETURN BOOLEAN
    IS

    ------------------------------------------------------------------------------------
    --Created by  : smanglm ( Oracle IDC)
    --Date created: 19-JUN-2001
    --
    --Purpose:  local program unit to function eval_timeslot
    --          this function select all timeslots assigned to the student
    --          either at term level or at teach level
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    --knaraset   20-May-2002    Romoving the validation against census date as per bug 2380758
    -------------------------------------------------------------------------------------

      --
      -- cursor to fetch the timeslot associated with the student
      --
      CURSOR c_stud_timeslot (cp_cal_type           igs_en_timeslot_para.cal_type%TYPE,
                              cp_sequence_number    igs_en_timeslot_para.sequence_number%TYPE) IS
             SELECT tr.start_dt_time,
                    tr.end_dt_time
             FROM   igs_en_timeslot_rslt tr,
                    igs_en_timeslot_para tp
             WHERE  tr.person_id = p_person_id
             AND    tr.igs_en_timeslot_para_id = tp.igs_en_timeslot_para_id
             AND    tp.cal_type = cp_cal_type
             AND    tp.sequence_number = cp_sequence_number;
      rec_stud_timeslot    c_stud_timeslot%ROWTYPE;

      --
      --cursor to fetch cal type and sequnece no when p_uoo_id is not null
      --
      CURSOR c_calendar IS
             SELECT cal_type,
                    ci_sequence_number
             FROM   igs_ps_unit_ofr_opt
             WHERE  uoo_id = p_uoo_id;
      l_cal_type    igs_ps_unit_ofr_opt.cal_type%TYPE DEFAULT NULL;
      l_seq_number  igs_ps_unit_ofr_opt.ci_sequence_number%TYPE DEFAULT NULL;

      --
      -- cursor to fetch load cal type and load seq number based on teach cal type and teach seq number
      --
      CURSOR c_load_cal (cp_teach_cal_type   igs_ca_teach_to_load_v.teach_cal_type%TYPE,
                         cp_teach_ci_seq_no  igs_ca_teach_to_load_v.teach_ci_sequence_number%TYPE) IS
             SELECT load_cal_type,
                    load_ci_sequence_number
             FROM   igs_ca_teach_to_load_v
             WHERE  teach_cal_type = cp_teach_cal_type
             AND    teach_ci_sequence_number = cp_teach_ci_seq_no;
      rec_load_cal   c_load_cal%ROWTYPE;
      lv_validate_timeslot   CONSTANT  VARCHAR2(30) :=  FND_PROFILE.VALUE('IGS_EN_VAL_TIMESLOT');
      lv_timeslot_rec_found BOOLEAN ;
    BEGIN
      --
      -- get the cal type and seq number if p_uoo_id is not null
      --

      IF p_uoo_id IS NOT NULL THEN
         OPEN c_calendar;
         FETCH c_calendar INTO l_cal_type,l_seq_number;
         CLOSE c_calendar;
      END IF;
      --
      -- now fetch the timeslot based on the obtained cal_type and seq number and if the values are null
      -- pass p_load_calendar_type and p_load_cal_sequence_number
      --
      lv_timeslot_rec_found := FALSE;
      FOR rec_stud_timeslot IN c_stud_timeslot (nvl(l_cal_type,p_load_calendar_type),
                                                nvl(l_seq_number,p_load_cal_sequence_number))
      LOOP
        -- check the profile option value .IF profile option 'Validate Timeslots' is 'START_TIME_ONLY' then
        -- get the enrolled census date and check if timeslot current date falls b/w timeslot start and enrolled census date
        -- else if profile option'Validate timeslots' value is 'START_TO_END_TIME' or not set then check if timeslot
        -- current date falls b/w timeslot start and end time.Included code as a part of enhancement bug:2043044

        -- Timeslot record found

        lv_timeslot_rec_found := TRUE;

        IF lv_validate_timeslot = 'START_TIME_ONLY' then
          IF (SYSDATE >=  rec_stud_timeslot.start_dt_time) OR  (rec_stud_timeslot.start_dt_time IS NULL ) THEN
           --Student is eligible
               RETURN TRUE;
          END IF;
    --  profile value is other than start_time_only
      ELSE
        IF (
           ( (SYSDATE >= rec_stud_timeslot.start_dt_time) OR  rec_stud_timeslot.start_dt_time IS NULL )
            AND
           ( ( SYSDATE  <= rec_stud_timeslot.end_dt_time) OR  rec_stud_timeslot.end_dt_time IS NULL)
           ) THEN
              --
              -- student has been assigned at least one timeslot at unit level and hence return TRUE
              --
              RETURN TRUE;
        END IF;
      END IF;
      END LOOP;
      --
      -- check at the load calendar also if it is not defined at teach level and look at term level for the timeslot assignment
      --
      FOR rec_load_cal IN c_load_cal (l_cal_type,l_seq_number)
      LOOP
        FOR rec_stud_timeslot IN c_stud_timeslot (rec_load_cal.load_cal_type,
                                                  rec_load_cal.load_ci_sequence_number)
        LOOP
        -- check the profile option value .IF profile option 'Validate Timeslots' is 'START_TIME_ONLY' then
        -- check if timeslot current date is greater than or equal to timeslot start
        -- else if profile option'Validate timeslots' value is 'START_TO_END_TIME' or not set then check if timeslot
        -- current date falls b/w timeslot start and end time.Included code as a part of enhancement bug:2043044

        -- Timeslot record found

        lv_timeslot_rec_found := TRUE;

         IF lv_validate_timeslot = 'START_TIME_ONLY' then
          IF (SYSDATE >= rec_stud_timeslot.start_dt_time) OR (rec_stud_timeslot.start_dt_time IS NULL ) THEN
             --Student is eligible
               RETURN TRUE;
          END IF;
        ELSE
       -- check if timeslot current date falls b/w timeslot start and end time and profile value is other than start_time_value
          --
          IF (
              ( (SYSDATE >= rec_stud_timeslot.start_dt_time) OR    rec_stud_timeslot.start_dt_time IS NULL ) AND
              ( (SYSDATE <= rec_stud_timeslot.end_dt_time) OR    rec_stud_timeslot.end_dt_time IS NULL )
             ) THEN
               -- student has been assigned at least one timeslot at term level and hence return TRUE
               RETURN TRUE;
          END IF;
        END IF;
       END LOOP;
      END LOOP;

      IF NOT lv_timeslot_rec_found THEN
         --
         -- No Timeslot records defined/alloted for the Student
         -- Added as part of Bug 2380758
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;

    END vald_timeslot;

  --
  -- main begin for eval_timeslot
  --
  BEGIN
    --
    -- assign the p_enrl_method to l_enr_method_type
    --
    l_enr_method_type := p_enrl_method;
    --
    -- decide the step to be used depending on whether the p_uoo_id is null or not. If null, use
    -- CHK_TIME_PER else use CHK_TIME_UNIT
    --
    IF p_uoo_id IS NOT NULL THEN
       l_step := 'CHK_TIME_UNIT';
    ELSE
       l_step := 'CHK_TIME_PER';
    END IF;
    IF p_person_type IS NOT NULL THEN
            --
            -- get the system person type
            --
            l_person_type := get_sys_pers_type (
                                                 p_person_type => p_person_type,
                                                 p_message     => p_message
                                               );
            IF p_message IS NOT NULL THEN
               RETURN FALSE;
            END IF;
    END IF;

    --
    -- check the step is overridden for the given load calendar/teaching period or not
    -- if yes, return true else carry out NOCOPY the rest of validation for timeslot
    --
    l_step_override := igs_en_gen_015.validation_step_is_overridden
                                 (
                                   p_eligibility_step_type        => l_step,
                                   p_load_cal_type                => p_load_calendar_type,
                                   p_load_cal_seq_number          => p_load_cal_sequence_number,
                                   p_person_id                    => p_person_id,
                                   p_uoo_id                       => p_uoo_id,
                                   p_step_override_limit          => l_step_override_limit
                                );
    IF l_step_override THEN
      RETURN TRUE;
    END IF;

    --
    -- depending on the return value of l_vald_timeslot, return from the main function
    --
    -- call the local program unit vald_timeslot for selecting timeslot
    l_vald_timeslot := vald_timeslot;
    IF l_vald_timeslot THEN
       --
       -- validation of timeslots returns TRUE
       --
       RETURN TRUE;
    ELSIF NOT l_vald_timeslot THEN
      IF p_notification_flag = 'DENY' THEN
        p_message := 'IGS_SS_DENY_TSLOT';
      ELSIF p_notification_flag = 'WARN' THEN
        p_message := 'IGS_SS_WARN_TSLOT';
      END IF;
      RETURN FALSE;
    END IF;

    RETURN TRUE;

  END eval_timeslot;

 FUNCTION get_sys_pers_type (
                              p_person_type                     IN  VARCHAR2,
                              p_message                        OUT NOCOPY  VARCHAR2
                            )
    ------------------------------------------------------------------------------------
    --Created by  : smanglm ( Oracle IDC)
    --Date created: 19-JUN-2001
    --
    --Purpose:  private function get_sys_pers_type to get the system person type
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who          When            What
    --Nalin Kumar  14-May-2002     Modified this function as per the Bug# 2364461.
    --                             Removed the code logic to check the whether the
    --                             passed person type is not a system person type or not.
    -- knaraset    20-May-2002     Removed the Upper() in the where clause of cursor
    --                               c_sys_pers_type as part of Bug 2380758.
    -------------------------------------------------------------------------------------
 RETURN VARCHAR2 IS
   --
   -- cursor c_sys_pers_type to fetch the system person type
   --
   CURSOR c_sys_pers_type (cp_person_type igs_pe_person_types.person_type_code%TYPE) IS
          SELECT system_type
          FROM   igs_pe_person_types
          WHERE  person_type_code = cp_person_type;
   l_sys_pers_type  igs_pe_person_types.person_type_code%TYPE;


 BEGIN
   p_message := NULL;
   --
   -- now get the corresponding system person type, if not found return a error message
   --
   OPEN c_sys_pers_type (p_person_type);
   FETCH c_sys_pers_type INTO l_sys_pers_type;
   IF c_sys_pers_type%NOTFOUND THEN
      p_message := 'IGS_EN_NO_SYS_PERS_TYPE';
      RETURN NULL;
   ELSE
      RETURN l_sys_pers_type;
   END IF;
   CLOSE c_sys_pers_type;

 END get_sys_pers_type;

PROCEDURE eval_ss_deny_all_hold( p_person_id                       IN  NUMBER,
                                 p_person_type                     IN  VARCHAR2,
                                 p_course_cd                       IN  VARCHAR2,
                                 p_load_calendar_type              IN  VARCHAR2,
                                 p_load_cal_sequence_number        IN  NUMBER,
                                 p_status                          OUT NOCOPY  VARCHAR2,
                                 p_message                         OUT NOCOPY  VARCHAR2) AS
------------------------------------------------------------------------------------
--Created by  : kkillams ( Oracle IDC)
--Date created: 20-JAN-2002
--
--Purpose:procedure is a wrapper eval_deny_all_hold function for Self Service purpose only.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who          When            What
-------------------------------------------------------------------------------------

CURSOR get_enr_method IS    SELECT enr_method_type FROM igs_en_method_type
                                                   WHERE self_service = 'Y'
                                                   AND   closed_ind = 'N';
l_comm_type          VARCHAR2(100);
l_enrolment_cat      VARCHAR2(100);
l_enr_method_type    igs_en_method_type.enr_method_type%TYPE;
BEGIN
     p_status := 'S';
     p_message  := NULL;
     --Get the enrollment category and enrollment commencement type.
     igs_en_elgbl_person.get_enrl_comm_type(p_person_id         =>p_person_id,
                                            p_course_cd         =>p_course_cd,
                                            p_cal_type          =>p_load_calendar_type,
                                            p_cal_seq_number    =>p_load_cal_sequence_number,
                                            p_enrolment_cat     =>l_enrolment_cat,
                                            p_commencement_type =>l_comm_type ,
                                            p_message           =>p_message);
     --If p_message returns some message means terminate the procedure
     IF p_message IS NOT NULL THEN
        p_status := 'E';
        RETURN;
     END IF;

     --Get the enrollment method for the self service responsibility.
     OPEN get_enr_method;
     FETCH get_enr_method INTO l_enr_method_type;
     IF get_enr_method%NOTFOUND THEN
        CLOSE get_enr_method;
        RETURN;
     ELSE
        CLOSE get_enr_method;

        IF NOT igs_en_elgbl_person.eval_deny_all_hold(
                                                      p_person_id,
                                                      p_person_type,
                                                      p_load_calendar_type,
                                                      p_load_cal_sequence_number,
                                                      l_enrolment_cat,
                                                      l_comm_type,
                                                      l_enr_method_type,
                                                      p_message) THEN
               p_status := 'E';
               RETURN;
        END IF;
     END IF;
END eval_ss_deny_all_hold;

PROCEDURE get_enrl_comm_type(p_person_id                       IN  NUMBER,
                             p_course_cd                       IN  VARCHAR2,
                             p_cal_type                        IN  VARCHAR2,
                             p_cal_seq_number                  IN  NUMBER,
                             p_enrolment_cat                   OUT NOCOPY  VARCHAR2,
                             p_commencement_type               OUT NOCOPY  VARCHAR2,
                             p_message                         OUT NOCOPY  VARCHAR2) AS
------------------------------------------------------------------------------------
--Created by  : kkillams ( Oracle IDC)
--Date created: 20-JAN-2002
--
--Purpose: Procedure derives the Enrollment Category,Commencement Type for
-- a given person, course code and calendar.
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who          When            What
-------------------------------------------------------------------------------------
l_alt_cd                          igs_ca_inst.alternate_code%TYPE;
l_acad_cal_type                   igs_ca_inst.cal_type%TYPE;
l_acad_ci_sequence_number         igs_ca_inst.sequence_number%TYPE;
l_acad_ci_start_dt                igs_ca_inst.start_dt%TYPE;
l_acad_ci_end_dt                  igs_ca_inst.end_dt%TYPE;
l_en_cal_type                     igs_ca_inst.cal_type%TYPE;
l_en_ci_seq_num                   igs_ca_inst.sequence_number%TYPE;
l_message_name                    VARCHAR2(100);
l_dummy                           VARCHAR2(200);
BEGIN

      --Function gets the academic calendar instance details for a sub ordinate calendar
      l_alt_cd := igs_en_gen_002.enrp_get_acad_alt_cd( p_cal_type,
                                                       p_cal_seq_number,
                                                       l_acad_cal_type,
                                                       l_acad_ci_sequence_number,
                                                       l_acad_ci_start_dt,
                                                       l_acad_ci_end_dt,
                                                       l_message_name);
      IF l_message_name IS NOT NULL THEN
          p_message := l_message_name;
          RETURN;
      END IF;

        --Function gets the enrollment category and commencement type for a person and course code.
        p_enrolment_cat:=igs_en_gen_003.enrp_get_enr_cat(
                                                          p_person_id,
                                                          p_course_cd,
                                                          l_acad_cal_type,
                                                          l_acad_ci_sequence_number,
                                                          NULL,
                                                          l_en_cal_type,
                                                          l_en_ci_seq_num,
                                                          p_commencement_type,
                                                          l_dummy);
END get_enrl_comm_type;


END  IGS_EN_ELGBL_PERSON;

/
