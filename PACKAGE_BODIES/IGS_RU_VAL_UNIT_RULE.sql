--------------------------------------------------------
--  DDL for Package Body IGS_RU_VAL_UNIT_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_VAL_UNIT_RULE" AS
/* $Header: IGSRU09B.pls 120.1 2005/12/13 03:58:46 appldev ship $ */
/* smaddali :modified all the functions to add four new parameters
   during enrollment Processes build nov2001 bug#1832130
   smaddali  15-oct-04      Modified for bug#3954071 -
   load calendar being passed to rules engine instead of teaching calendar*/

    -- added new for enrollment processes dld bug#1832130
    -- all thebelow declerations and cursors

    -- selects the rule number defined for a given unit section
    CURSOR cur_usec_rule (cp_uoo_id igs_ps_usec_ru.uoo_id%TYPE ,
                          cp_rul_call_cd igs_ps_usec_ru.s_rule_call_cd%TYPE ) IS
    SELECT s_rule_call_cd , rul_sequence_number
    FROM igs_ps_usec_ru
    WHERE uoo_id = cp_uoo_id
    AND s_rule_call_cd = cp_rul_call_cd;

    --selects the rule number defined for the unit version
    CURSOR cur_uver_rule (cp_unit_cd igs_ps_unit_ver_ru.unit_cd%TYPE,
                          cp_version_number igs_ps_unit_ver_ru.version_number%TYPE,
                          cp_rul_call_cd igs_ps_unit_ver_ru.s_rule_call_cd%TYPE ) IS
    SELECT s_rule_call_cd , rul_sequence_number
    FROM igs_ps_unit_ver_ru
    WHERE unit_cd = cp_unit_cd
    AND version_number = cp_version_number
    AND s_rule_call_cd = cp_rul_call_cd;

    --select all the active program attempts for this student
    CURSOR cur_std_psatt(cp_person_id igs_en_stdnt_ps_att_all.person_id%TYPE) IS
    SELECT ps.course_cd , ps.version_number
    FROM igs_en_stdnt_ps_att ps
    WHERE ps.person_id = cp_person_id
    AND  ps.course_attempt_status IN ('ENROLLED' ,'INACTIVE')
    AND  EXISTS ( SELECT 1 FROM igs_en_su_attempt su
         WHERE  su.person_id=ps.person_id
         AND su.course_cd =ps.course_cd  )
    ORDER BY  course_cd desc;

    cst_active CONSTANT IGS_CA_INST.cal_status%TYPE := 'ACTIVE';
    CURSOR cur_load(cp_teach_cal_type igs_ca_inst.cal_type%TYPE,
                    cp_teach_ci_sequence_number igs_ca_inst.sequence_number%TYPE) IS
        SELECT    cv.load_cal_type ,
                  cv.load_ci_sequence_number
        FROM      igs_ca_teach_to_load_v cv,
                  IGS_CA_INST ci,
                  IGS_CA_STAT cs
        WHERE     cv.teach_cal_type           =  cp_teach_cal_type
        AND       cv.teach_ci_sequence_number =  cp_teach_ci_sequence_number
        AND       ci.cal_type = cv.load_cal_type
        AND       ci.sequence_number = cv.load_ci_sequence_number
        AND       ci.cal_status = cs.cal_status
        AND       cs.s_cal_status = cst_active
        ORDER BY  load_start_dt ASC;

/*
   Validate co-requisite rules for a student unit attempt
   smaddali modified the code for enrollment processes dld
   bug#1832130
*/
/*-------------------------------------------------------------------------------------
  --who           when            what
   smaddali     15-oct-04  Modified the logic for bug#3954071 to pass the load calendar while checking for step override
 --bdeviset  12-DEC-2005    Passing extra parameter p_param_8 ( in which the uoo_is is passed)
 --                         while calling rules engine for Bug# 4304688
 ------------------------------------------------------------------------------------- */

  FUNCTION RULP_VAL_COREQ(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_text OUT NOCOPY VARCHAR2 ,
  -- added new parameters for bug#1832130
  p_course_version IN NUMBER DEFAULT NULL,
  p_unit_ver IN NUMBER DEFAULT NULL,
  p_uoo_id  IN  NUMBER DEFAULT NULL,
  p_rule_failed  OUT NOCOPY VARCHAR2)
  RETURN boolean IS


    l_term_cal igs_ca_inst.cal_type%TYPE;
    l_term_seq_number igs_ca_inst.sequence_number%TYPE;
    v_return_val	VARCHAR2(30);
    l_step_override_limit    IGS_EN_ELGB_OVR_UOO.step_override_limit%TYPE ;
    --l_step_override_limit  igs_en_elgb_ovr_step.step_override_limit%TYPE ;
    l_rule_call_cd igs_ps_usec_ru.s_rule_call_cd%TYPE DEFAULT NULL;
    l_rul_seq_number igs_ps_usec_ru.rul_sequence_number%TYPE DEFAULT NULL;

  BEGIN
     --cursor to fetch the term calendar from the unit section teach calendar
    --this cursor is ordered by the load cal start date to fetch the
    --first term cal if a teching period spans across multiple terms.
    l_term_cal := NULL;
    l_term_seq_number := NULL;
    OPEN cur_load(p_cal_type, p_ci_sequence_number);
    FETCH cur_load INTO l_term_cal, l_term_seq_number;
    CLOSE cur_load;

    --added this code for enrollment processes dld bug#1832130
    -- if the rule validation is overridden for the student then return true
    IF( IGS_EN_GEN_015.validation_step_is_overridden(
      p_eligibility_step_type => 'COREQ',
      p_load_cal_type => l_term_cal,
      p_load_cal_seq_number => l_term_seq_number,
      p_person_id => p_person_id,
      p_uoo_id => p_uoo_id,
      p_step_override_limit => l_step_override_limit)) THEN
      p_rule_failed := NULL;
      p_message_text := NULL ;
      RETURN TRUE ;
    ELSE
      -- check if this rule  is defined for the unit section
      OPEN cur_usec_rule(p_uoo_id,'USECCOREQ' ) ;
      FETCH cur_usec_rule INTO l_rule_call_cd , l_rul_seq_number ;
      IF  cur_usec_rule%NOTFOUND THEN
        -- if this rule is not defined for the unit section then
        --check if this rule is defined for the unit version
        OPEN cur_uver_rule(p_unit_cd,p_unit_ver,'COREQ' ) ;
        FETCH cur_uver_rule INTO l_rule_call_cd , l_rul_seq_number ;
        CLOSE cur_uver_rule ;
      END IF;
      CLOSE cur_usec_rule ;
      -- if no rule is defined for either the unit section or the unit version
      -- then return true
      IF l_rule_call_cd IS NULL THEN
        p_rule_failed := NULL ;
        p_message_text := NULL ;
        RETURN TRUE ;
      END IF;
      -- else check if the rule is satisfied for any of
      -- the active program attempts of the student
      FOR std_psatt_rec IN cur_std_psatt(p_person_id)
      LOOP
  	v_return_val := IGS_RU_GEN_001.RULP_VAL_SENNA(
  	                        p_rule_call_name => l_rule_call_cd,
  				p_person_id => p_person_id,
  				p_course_cd => std_psatt_rec.course_cd,
  				p_course_version  => std_psatt_rec.version_number,
  				p_unit_cd  => p_unit_cd,
  				p_unit_version  => p_unit_ver,
  				p_cal_type => p_cal_type,
  				p_ci_sequence_number => p_ci_sequence_number,
  				p_message  => p_message_text ,
  				p_rule_number  => l_rul_seq_number,
          p_param_8 => p_uoo_id);
        -- if the rule is satisfied for any of the program attemptsthen return true
  	IF v_return_val = 'true'  THEN
  	  p_rule_failed := NULL;
  	  p_message_text := NULL ;
  	  RETURN TRUE ;
  	END IF;
      END LOOP ;
      -- Rule has been checked against all the program attempts and
      --is not satisfied for any
      p_rule_failed := 'CO-REQ' ;
      RETURN FALSE;
    END IF;
  END rulp_val_coreq;
/*
   To validate for incompatible student unit attempts
   smaddali modified the code for enrollment processes dld
   bug#1832130
*/
/*-------------------------------------------------------------------------------------
  --who           when            what
   smaddali     15-oct-04  Modified the logic for bug#3954071 to pass the load calendar while checking for step override
 ------------------------------------------------------------------------------------- */

  FUNCTION RULP_VAL_INCOMP(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_text OUT NOCOPY VARCHAR2 ,
  -- added new parameters for bug#1832130
  p_course_version IN NUMBER DEFAULT NULL,
  p_unit_ver IN NUMBER DEFAULT NULL,
  p_uoo_id  IN  NUMBER DEFAULT NULL,
  p_rule_failed  OUT NOCOPY VARCHAR2)
  RETURN boolean IS

    l_term_cal igs_ca_inst.cal_type%TYPE;
    l_term_seq_number igs_ca_inst.sequence_number%TYPE;
    v_return_val	VARCHAR2(30);
	l_step_override_limit    IGS_EN_ELGB_OVR_UOO.step_override_limit%TYPE ;
     --l_step_override_limit  igs_en_elgb_ovr_step.step_override_limit%TYPE ;
    l_rule_call_cd igs_ps_usec_ru.s_rule_call_cd%TYPE DEFAULT NULL;
    l_rul_seq_number igs_ps_usec_ru.rul_sequence_number%TYPE DEFAULT NULL;

  BEGIN

    --cursor to fetch the term calendar from the unit section teach calendar
    --this cursor is ordered by the load cal start date to fetch the
    --first term cal if a teching period spans across multiple terms.
    l_term_cal := NULL;
    l_term_seq_number := NULL;
    OPEN cur_load(p_cal_type, p_ci_sequence_number);
    FETCH cur_load INTO l_term_cal, l_term_seq_number;
    CLOSE cur_load;

      -- if the rule validation is overridden for the student then return true
    IF( IGS_EN_GEN_015.validation_step_is_overridden(p_eligibility_step_type => 'INCMPT_UNT',
      p_load_cal_type => l_term_cal,
      p_load_cal_seq_number => l_term_seq_number,
      p_person_id => p_person_id,
      p_uoo_id => p_uoo_id,
      p_step_override_limit => l_step_override_limit)) THEN
      p_rule_failed := NULL;
      p_message_text := NULL ;
      RETURN TRUE ;
    ELSE
      --check if this rule is defined for the unit version
      OPEN cur_uver_rule(p_unit_cd,p_unit_ver,'INCOMP' ) ;
      FETCH cur_uver_rule INTO l_rule_call_cd , l_rul_seq_number ;
      CLOSE cur_uver_rule ;

      -- if this rule is not defined for the unit version then return true
      IF l_rule_call_cd IS NULL THEN
        p_rule_failed := NULL ;
        p_message_text := NULL ;
        RETURN TRUE ;
      END IF;
      -- for each of the program attempt of the student check if the
      --rule is satisfied
      FOR std_psatt_rec IN cur_std_psatt(p_person_id)
      LOOP
 	v_return_val := IGS_RU_GEN_001.RULP_VAL_SENNA(p_rule_call_name => l_rule_call_cd,
  				p_person_id => p_person_id,
  				p_course_cd => std_psatt_rec.course_cd,
  				p_course_version  => std_psatt_rec.version_number,
  				p_unit_cd  => p_unit_cd,
  				p_unit_version  => p_unit_ver,
  				p_cal_type => p_cal_type,
  				p_ci_sequence_number => p_ci_sequence_number,
  				p_message  => p_message_text ,
  				p_rule_number  => l_rul_seq_number );
        -- if the rule is not satisfied for any of the program attempts then return false
  	IF v_return_val = 'false'  THEN
           p_rule_failed := 'INCOMP' ;
           RETURN FALSE;
  	END IF;
      END LOOP ;
      -- Rule has been checked against all the program attempts and
      --is  satisfied for all
      p_rule_failed := NULL;
      p_message_text := NULL ;
      RETURN TRUE ;
    END IF;
  END  rulp_val_incomp;
/*
   Validate the pre-requisite rules for a student unit attempt
   smaddali modified the code for enrollment processes dld
   bug#1832130
*/
/*-------------------------------------------------------------------------------------
  --who           when            what
  --svanukur      23-May-2003     Redefined l_step_override_limit to refer to igs_en_elgb_ovr_uoo
  --                                as part of Deny/War behaviour build # 2829272
  --stutta        21-Sep-2004     Passing p_param_5 as 'Y' in call to rulp_val_senna to
  --                              which is used by PREDICTED_ENROLLED rule component to
  --                              include enrolled units. Bug # 3703355
  -- smaddali     15-oct-04       Modified the logic for bug#3954071 to pass the load calendar while checking for step override
  -- bdeviset     12-DEC-2005    Passing extra parameter p_param_8 ( in which the uoo_is is passed)
  --                             while calling rules engine for Bug# 4304688
 ------------------------------------------------------------------------------------- */
  FUNCTION RULP_VAL_PREREQ(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_text OUT NOCOPY VARCHAR2 ,
  -- added new parameters for bug#1832130
  p_course_version IN NUMBER DEFAULT NULL,
  p_unit_ver IN NUMBER DEFAULT NULL,
  p_uoo_id  IN  NUMBER DEFAULT NULL,
  p_rule_failed  OUT NOCOPY VARCHAR2)
  RETURN boolean IS

    l_term_cal igs_ca_inst.cal_type%TYPE;
    l_term_seq_number igs_ca_inst.sequence_number%TYPE;

    v_return_val	VARCHAR2(30);
     l_step_override_limit    IGS_EN_ELGB_OVR_UOO.step_override_limit%TYPE ;
    l_rule_call_cd igs_ps_usec_ru.s_rule_call_cd%TYPE DEFAULT NULL;
    l_rul_seq_number igs_ps_usec_ru.rul_sequence_number%TYPE DEFAULT NULL;

  BEGIN

    --cursor to fetch the term calendar from the unit section teach calendar
    --this cursor is ordered by the load cal start date to fetch the
    --first term cal if a teching period spans across multiple terms.
    l_term_cal := NULL;
    l_term_seq_number := NULL;
    OPEN cur_load(p_cal_type, p_ci_sequence_number);
    FETCH cur_load INTO l_term_cal, l_term_seq_number;
    CLOSE cur_load;

    -- if the rule validation is overridden for the student then return true
    IF( IGS_EN_GEN_015.validation_step_is_overridden(p_eligibility_step_type => 'PREREQ',
      p_load_cal_type => l_term_cal,
      p_load_cal_seq_number => l_term_seq_number,
      p_person_id => p_person_id,
      p_uoo_id => p_uoo_id,
      p_step_override_limit => l_step_override_limit)) THEN
      p_rule_failed := NULL;
      p_message_text := NULL ;
      RETURN TRUE ;
    ELSE
       -- check if this rule  is defined for the unit section
      OPEN cur_usec_rule(p_uoo_id,'USECPREREQ' ) ;
      FETCH cur_usec_rule INTO l_rule_call_cd , l_rul_seq_number ;
      IF cur_usec_rule%NOTFOUND  THEN
        -- if no rule is defined for this unit section then
        --check if this rule is defined for the unit version
        OPEN cur_uver_rule(p_unit_cd,p_unit_ver,'PREREQ' ) ;
        FETCH cur_uver_rule INTO l_rule_call_cd , l_rul_seq_number ;
        CLOSE cur_uver_rule ;
      END IF;
      CLOSE cur_usec_rule ;
      -- if no rule is defined for either the unit section or the unit version
      -- then return true
      IF l_rule_call_cd IS NULL THEN
        p_rule_failed := NULL ;
        p_message_text := NULL ;
        RETURN TRUE ;
      END IF;

      -- for each of the program attempt of the student check if the
      --rule is satisfied

      FOR std_psatt_rec IN cur_std_psatt(p_person_id)
      LOOP
 	v_return_val := IGS_RU_GEN_001.RULP_VAL_SENNA(
 	        p_rule_call_name => l_rule_call_cd,
  		p_person_id => p_person_id,
  		p_course_cd => std_psatt_rec.course_cd,
  		p_course_version  => std_psatt_rec.version_number,
  		p_unit_cd  => p_unit_cd,
  		p_unit_version  => p_unit_ver,
  		p_cal_type => p_cal_type,
  		p_ci_sequence_number => p_ci_sequence_number,
  		p_message  => p_message_text ,
  		p_rule_number  => l_rul_seq_number,
		p_param_5 => 'Y',
    p_param_8 => p_uoo_id);
        -- if the rule is satisfied for any of the program attempts then return true
  	IF v_return_val = 'true'  THEN
  	  p_rule_failed := NULL;
  	  p_message_text := NULL ;
  	  RETURN TRUE ;
  	END IF;
      END LOOP ;
      -- Rule has been checked against all the program attempts and
      --is not satisfied for any
      p_rule_failed := 'PRE-REQ' ;
      RETURN FALSE;
    END IF;
  END  rulp_val_prereq;
/*
   Validate the enrolment rules for a student unit attempt
   smaddali modified the code for enrollment processes dld
   bug#1832130
*/
  FUNCTION RULP_VAL_ENROL_UNIT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version  NUMBER DEFAULT NULL,
  p_unit_cd IN VARCHAR2 ,
  p_unit_version  NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_text OUT NOCOPY VARCHAR2 ,
  -- added new parameters for bug#1832130
  p_uoo_id  IN  NUMBER DEFAULT NULL,
  p_rule_failed  OUT NOCOPY VARCHAR2 )
  RETURN boolean IS
  	v_return_val	BOOLEAN;
  BEGIN
      -- validate pre requisite rule for this unit
  	IF NOT(  RULP_VAL_PREREQ(
  	            p_person_id => p_person_id,
  			    p_course_cd => p_course_cd,
       			p_unit_cd =>  p_unit_cd,
  			    p_cal_type => p_cal_type,
  			    p_ci_sequence_number => p_ci_sequence_number,
  			    p_message_text => p_message_text,
  			    p_course_version => p_course_version,
  			    p_unit_ver => p_unit_version,
  			    p_uoo_id => p_uoo_id,
  			    p_rule_failed => p_rule_failed ))  THEN

  	  RETURN FALSE;
  	END IF;
        -- if prerequisite rule is satisfied then validate corequisite rule for this unit
        IF NOT (  RULP_VAL_COREQ( p_person_id => p_person_id,
  			    p_course_cd => p_course_cd,
       			p_unit_cd =>  p_unit_cd,
  			    p_cal_type => p_cal_type,
  			    p_ci_sequence_number => p_ci_sequence_number,
  			    p_message_text => p_message_text,
  			    p_course_version => p_course_version,
  			    p_unit_ver => p_unit_version,
  			    p_uoo_id => p_uoo_id,
  			    p_rule_failed => p_rule_failed )) THEN

   	  RETURN FALSE;
  	END IF;
        -- if prerequisite and corequisite rules are satisfied then
        -- validate incompatibility rule for this unit
  	IF NOT (  RULP_VAL_INCOMP( p_person_id => p_person_id,
  			    p_course_cd => p_course_cd,
       			p_unit_cd =>  p_unit_cd,
  			    p_cal_type => p_cal_type,
  			    p_ci_sequence_number => p_ci_sequence_number,
  			    p_message_text => p_message_text,
  			    p_course_version => p_course_version,
  			    p_unit_ver => p_unit_version,
  			    p_uoo_id => p_uoo_id,
  			    p_rule_failed => p_rule_failed )) THEN

  	  RETURN FALSE;
  	END IF;
  	-- if all the rules are satisfied then return true
 	RETURN TRUE;
  END  rulp_val_enrol_unit;

END IGS_RU_VAL_UNIT_RULE;

/
