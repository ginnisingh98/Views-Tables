--------------------------------------------------------
--  DDL for Package Body IGS_RU_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_GEN_004" AS
/* $Header: IGSRU04B.pls 115.7 2002/11/29 03:39:42 nsidana ship $ */

Procedure Rulp_Ins_Make_Rule(
  p_description_number IN NUMBER DEFAULT NULL,
  p_return_type  VARCHAR2 DEFAULT NULL,
  p_rule_description  VARCHAR2 DEFAULT NULL,
  p_turing_function  VARCHAR2 DEFAULT NULL,
  p_rule_text  VARCHAR2 DEFAULT NULL,
  p_message_rule_text  VARCHAR2 DEFAULT NULL,
  p_description_text  VARCHAR2 ,
  p_group IN NUMBER DEFAULT 1,
  p_select_group IN NUMBER DEFAULT 1)
IS
  ------------------------------------------------------------------
  --Created by  : nsinha, Oracle India
  --Date created: 12-Mar-2001
  --
  --Purpose: Expand description_number to IGS_RU_DESCRIPTION or group_name
  --         if invalid set message number and return NULL
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --nsinha      12-Mar-2002     Bug# 2233951: Moved the content of this
  --                            procedure in Igs_ru_gen_006.Rulp_Ins_Make_Rule
  --                            and called it from there.
  --
  -------------------------------------------------------------------
BEGIN
  Igs_ru_gen_006.Rulp_Ins_Make_Rule (
    p_description_number,
    p_return_type,
    p_rule_description,
    p_turing_function,
    p_rule_text,
    p_message_rule_text,
    p_description_text,
    p_group,
    p_select_group);
END rulp_ins_make_rule;

Function Rulp_Ins_Ur_Rule(
  p_unit_cd IN VARCHAR2 ,
  p_s_rule_call_cd IN VARCHAR2 ,
  p_insert_rule_only IN BOOLEAN ,
  p_rul_sequence_number OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
  ------------------------------------------------------------------
  --Created by  : nsinha, Oracle India
  --Date created: 12-Mar-2002
  --
  --Purpose:
  -- This module inserts a IGS_PS_UNIT_RU asscoaited with a IGS_PS_UNIT.  This involves:
  -- Creating IGS_PS_UNIT_RU IGS_RU_RULE and associated records (IGS_RU_RULE) when the
  -- IGS_PS_UNIT_RU does not already exist.
  -- Set the default message number
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --nsinha      12-Mar-2002     Bug# 2233951: Modified the logic to
  --                            SELECT the next value of the sequence number
  --                            differently when the data is for SEED DB.
  --
  -------------------------------------------------------------------
	gv_other_detail		VARCHAR2(255);
	MORE_THAN_ONE_UNIT_RULE_RECORD	EXCEPTION;
BEGIN
DECLARE
	v_rowid		VARCHAR2(25);
	v_rowid_pur		VARCHAR2(25);
	v_count		NUMBER(6);
	v_ur_sequence_number		IGS_PS_UNIT_RU.rul_sequence_number%TYPE;
	s_n_next		IGS_RU_RULE.sequence_number%TYPE;
	CURSOR c_ur IS
		SELECT	ur.rul_sequence_number
		FROM	IGS_PS_UNIT_RU	ur
		WHERE	ur.unit_cd = p_unit_cd AND
			ur.s_rule_call_cd = p_s_rule_call_cd;
	CURSOR c_ur_count IS
		SELECT	count(*)
		FROM	IGS_PS_UNIT_RU	ur
		WHERE	ur.unit_cd = p_unit_cd AND
			ur.s_rule_call_cd = p_s_rule_call_cd;

	CURSOR C_IGS_RU_RULE_SEQ_NUM_S IS
        SELECT IGS_RU_RULE_SEQ_NUM_S.NEXTVAL
	FROM   DUAL;

	CURSOR cur_max_plus_one IS
          SELECT   MAX (sequence_number) + 1 sequence_number
          FROM     IGS_RU_RULE
	  WHERE    sequence_number < 499999;

BEGIN
	p_message_name := Null;

  -- Validate input parameters.
	IF p_unit_cd IS NULL OR p_s_rule_call_cd IS NULL THEN
		p_rul_sequence_number := 0;
		p_message_name := 'IGS_GE_INVALID_VALUE';
		RETURN FALSE;
	END IF;

  -- Create IGS_PS_UNIT_RU if it doesn't already exist.

    OPEN c_ur;
    FETCH c_ur INTO v_ur_sequence_number;
    p_rul_sequence_number := v_ur_sequence_number;
    IF (c_ur%NOTFOUND) THEN
          --
	  --  New description number
          --  If the User creating this record is DATAMERGE (id = 1) then
          --    Get the sequence as the existing maximum value + 1
          --  Else
          --    Get the next value from the database sequence
          --
          IF (fnd_global.user_id = 1) THEN
            OPEN  cur_max_plus_one;
            FETCH cur_max_plus_one INTO s_n_next;
            CLOSE cur_max_plus_one;
          ELSE
            OPEN C_IGS_RU_RULE_SEQ_NUM_S;
            FETCH C_IGS_RU_RULE_SEQ_NUM_S INTO s_n_next;
            IF C_IGS_RU_RULE_SEQ_NUM_S%NOTFOUND THEN
              RAISE NO_DATA_FOUND;
            END IF;
            CLOSE C_IGS_RU_RULE_SEQ_NUM_S;
          END IF;

      -- Create IGS_PS_UNIT_RU and associated records.

		IGS_RU_RULE_PKG.Insert_Row(
			x_rowid => v_rowid,
			x_sequence_number => s_n_next
			);

		p_rul_sequence_number := s_n_next;
		IF p_insert_rule_only = FALSE THEN
			IGS_PS_UNIT_RU_PKG.Insert_Row(
				x_rowid => v_rowid_pur,
				x_unit_cd => p_unit_cd,
				x_s_rule_call_cd => p_s_rule_call_cd,
				x_rul_sequence_number => s_n_next
				);

		END IF;
	END IF;
	IF (c_ur%FOUND) THEN
		OPEN c_ur_count;
		FETCH c_ur_count INTO v_count;
		IF v_count > 1 THEN
			CLOSE c_ur;
			CLOSE c_ur_count;
			RAISE MORE_THAN_ONE_UNIT_RULE_RECORD;
		END IF;
		CLOSE c_ur_count;
	END IF;
	CLOSE c_ur;
   /*
   Return the default value
   */
	RETURN TRUE;
END;
EXCEPTION
	WHEN MORE_THAN_ONE_UNIT_RULE_RECORD THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_RU_GEN_004.rulp_ins_ur_rule');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END rulp_ins_ur_rule;

Function Rulp_Val_Adm_Status(
  p_letter_parameter_type IN VARCHAR2 ,
  p_adm_appl_status IN VARCHAR2 ,
  p_adm_fee_status IN VARCHAR2 ,
  p_adm_doc_status IN VARCHAR2 ,
  p_adm_entry_qual_status IN VARCHAR2 ,
  p_late_adm_fee_status IN VARCHAR2 ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_reconsideration IN BOOLEAN ,
  p_encumbrance IN BOOLEAN ,
  p_course_invalid IN BOOLEAN ,
  p_late IN BOOLEAN ,
  p_incomplete IN BOOLEAN ,
  p_correspondence_type  VARCHAR2 ,
  p_valid_alternate  BOOLEAN ,
  p_valid_address  BOOLEAN ,
  p_valid_disability  BOOLEAN ,
  p_valid_visa  BOOLEAN ,
  p_valid_finance  BOOLEAN ,
  p_valid_notes  BOOLEAN ,
  p_valid_statistics  BOOLEAN ,
  p_valid_alias  BOOLEAN ,
  p_valid_tertiary  BOOLEAN ,
  p_valid_aus_sec_ed  BOOLEAN ,
  p_valid_os_sec_ed  BOOLEAN ,
  p_valid_employment  BOOLEAN ,
  p_valid_membership  BOOLEAN ,
  p_valid_dob  BOOLEAN ,
  p_valid_title  BOOLEAN ,
  p_valid_referee  BOOLEAN ,
  p_valid_scholarship  BOOLEAN ,
  p_valid_lang_prof  BOOLEAN ,
  p_valid_interview  BOOLEAN ,
  p_valid_exchange  BOOLEAN ,
  p_valid_adm_test IN BOOLEAN ,
  p_valid_fee_assess  BOOLEAN ,
  p_valid_cor_category  BOOLEAN ,
  p_valid_enr_category  BOOLEAN ,
  p_valid_research  BOOLEAN ,
  p_valid_rank_app  BOOLEAN ,
  p_valid_completion  BOOLEAN ,
  p_valid_rank_set  BOOLEAN ,
  p_valid_basis_adm  BOOLEAN ,
  p_valid_crs_international  BOOLEAN ,
  p_valid_ass_tracking  BOOLEAN ,
  p_valid_adm_code  BOOLEAN ,
  p_valid_fund_source IN BOOLEAN ,
  p_valid_location  BOOLEAN ,
  p_valid_att_mode  BOOLEAN ,
  p_valid_att_type  BOOLEAN ,
  p_valid_unit_set  BOOLEAN )
RETURN VARCHAR2 IS
/*

 admission status call stub to senna

*/
v_message	VARCHAR2(2000);
FUNCTION boolean_to_turing (
	p_boolean	BOOLEAN )
RETURN VARCHAR2 IS
BEGIN
	IF p_boolean
	THEN
		RETURN 'true';
	ELSE
		RETURN 'false';
	END IF;
END boolean_to_turing;
/*

rulp_val_adm_status

*/
BEGIN
	RETURN IGS_RU_GEN_001.RULP_VAL_SENNA(p_message=>v_message,
		p_rule_call_name=>'ADM_STATUS',
/*
		 p_person_id=>p_person_id,
		 p_course_cd=>p_course_cd,
		 p_course_version=>p_crs_version_number,
*/
		p_param_1=>p_adm_appl_status,
		p_param_2=>p_adm_fee_status,
		p_param_3=>p_adm_doc_status,
		p_param_4=>p_adm_entry_qual_status,
		p_param_5=>p_late_adm_fee_status,
		p_param_6=>p_adm_outcome_status,
		p_param_7=>p_adm_cndtnl_offer_status,
		p_param_8=>p_adm_offer_resp_status,
		p_param_9=>p_adm_offer_dfrmnt_status,
		p_param_10=>boolean_to_turing(p_reconsideration),
		p_param_11=>boolean_to_turing(p_encumbrance),
		p_param_12=>boolean_to_turing(p_course_invalid),
		p_param_13=>boolean_to_turing(p_late),
		p_param_14=>boolean_to_turing(p_incomplete),
		p_param_15=>p_correspondence_type,
		p_param_16=>boolean_to_turing(p_valid_alternate),
		p_param_17=>boolean_to_turing(p_valid_address),
		p_param_18=>boolean_to_turing( p_valid_disability),
		p_param_19=>boolean_to_turing(p_valid_visa),
		p_param_20=>boolean_to_turing(p_valid_finance),
		p_param_21=>boolean_to_turing(p_valid_notes),
		p_param_22=>boolean_to_turing(p_valid_statistics) ,
		p_param_23=>boolean_to_turing(p_valid_alias),
		p_param_24=>boolean_to_turing(p_valid_tertiary),
		p_param_25=>boolean_to_turing(p_valid_aus_sec_ed),
		p_param_26=>boolean_to_turing(p_valid_os_sec_ed),
		p_param_27=>boolean_to_turing(p_valid_employment),
		p_param_28=>boolean_to_turing(p_valid_membership),
		p_param_29=>boolean_to_turing(p_valid_dob),
		p_param_30=>boolean_to_turing(p_valid_title),
		p_param_31=>boolean_to_turing(p_valid_referee),
		p_param_32=>boolean_to_turing(p_valid_scholarship),
		p_param_33=>boolean_to_turing(p_valid_lang_prof),
		p_param_34=>boolean_to_turing(p_valid_interview),
		p_param_35=>boolean_to_turing(p_valid_exchange),
		p_param_36=>boolean_to_turing(p_valid_fee_assess),
		p_param_37=>boolean_to_turing(p_valid_cor_category),
		p_param_38=>boolean_to_turing(p_valid_enr_category),
		p_param_39=>boolean_to_turing(p_valid_research),
		p_param_40=>boolean_to_turing(p_valid_rank_app),
		p_param_41=>boolean_to_turing(p_valid_completion),
		p_param_42=>boolean_to_turing(p_valid_rank_set),
		p_param_43=>boolean_to_turing(p_valid_basis_adm),
		p_param_44=>boolean_to_turing(p_valid_crs_international),
		p_param_45=>boolean_to_turing(p_valid_ass_tracking),
		p_param_46=>boolean_to_turing(p_valid_adm_code),
		p_param_47=>boolean_to_turing(p_valid_location),
		p_param_48=>boolean_to_turing(p_valid_att_mode),
		p_param_49=>boolean_to_turing(p_valid_att_type),
		p_param_50=>boolean_to_turing(p_valid_unit_set),
		p_param_51=>p_letter_parameter_type,
		p_param_52=>boolean_to_turing(p_valid_adm_test),
		p_param_53=>boolean_to_turing(p_valid_fund_source) );
END rulp_val_adm_status;

Function Rulp_Val_Desc_Rgi(
  p_description_number IN NUMBER ,
  p_description_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2 IS
  ------------------------------------------------------------------
  --Created by  : nsinha, Oracle India
  --Date created: 12-Mar-2001
  --
  --Purpose: Expand description_number to IGS_RU_DESCRIPTION or group_name
  --         if invalid set message number and return NULL
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --nsinha      12-Mar-2002     Bug# 2233951: Moved the content of this
  --                            function in Igs_ru_gen_006.Rulp_Val_Desc_Rgi
  --                            and called it from there.
  --
  -------------------------------------------------------------------
	v_description	igs_ru_description.rule_description%TYPE;
	l_message_name	VARCHAR2(255);
BEGIN
  v_description := Igs_ru_gen_006.Rulp_Val_Desc_Rgi(
                                        p_description_number,
                                        p_description_type,
                                        l_message_name);
  IF l_message_name IS NOT NULL THEN
    p_message_name := l_message_name;
    RETURN NULL;
  ELSE
    RETURN v_description;
  END IF;
END rulp_val_desc_rgi;

Function Rulp_Val_Gpa(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_ci_sequence_number IN NUMBER ,
  p_best_worst IN VARCHAR2 DEFAULT 'N',
  p_recommend_ind IN VARCHAR2 DEFAULT 'N')
RETURN VARCHAR2 IS
/*

 return the gpa for a student

*/
	v_message	VARCHAR2(2000);
BEGIN
	RETURN IGS_RU_GEN_001.RULP_VAL_SENNA (
			p_rule_call_name=>'GPA',
			p_person_id=>p_person_id,
			p_course_cd=>p_course_cd,
			p_cal_type=>p_prg_cal_type,
			p_ci_sequence_number=>p_prg_ci_sequence_number,
			p_param_1=>p_best_worst,
			p_param_2=>p_recommend_ind,
			p_message=>v_message );
END rulp_val_gpa;

Function Rulp_Val_Named_Rule(
  p_return_type  VARCHAR2 ,
  p_rule_name  VARCHAR2 ,
  p_person_id IN NUMBER )
RETURN VARCHAR2 IS
/*

 Execute the IGS_RU_RULE determined using it return type and name

*/
	v_rule_number	NUMBER;
	v_message_text	VARCHAR2(2000);
BEGIN
	SELECT	NR.rul_sequence_number
	INTO	v_rule_number
	FROM	IGS_RU_DESCRIPTION RUD,
		IGS_RU_NAMED_RULE NR
	WHERE	RUD.s_return_type = p_return_type
	AND	RUD.rule_description = p_rule_name
	AND	NR.rud_sequence_number = RUD.sequence_number;
	RETURN IGS_RU_GEN_001.RULP_VAL_SENNA (
			p_rule_number=>v_rule_number,
			p_person_id=>p_person_id,
			p_message=>v_message_text );
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN NULL;
END;

Function Rulp_Val_Wam(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version  NUMBER ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_ci_sequence_number IN NUMBER ,
  p_recommend_ind IN VARCHAR2 DEFAULT 'N',
  p_abort_when_missing IN VARCHAR2 DEFAULT 'N')
RETURN VARCHAR2 IS
/*

 return the wam for a student

*/
	v_message	VARCHAR2(2000);
BEGIN
	RETURN IGS_RU_GEN_001.RULP_VAL_SENNA (
			p_rule_call_name=>'WAM',
			p_person_id=>p_person_id,
			p_course_cd=>p_course_cd,
			p_course_version=>p_course_version,
			p_cal_type=>p_prg_cal_type,
			p_ci_sequence_number=>p_prg_ci_sequence_number,
			p_param_1=>p_abort_when_missing,
			p_param_2=>p_recommend_ind,
			p_message=>v_message );
END rulp_val_wam;

END IGS_RU_GEN_004;

/
