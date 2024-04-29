--------------------------------------------------------
--  DDL for Package Body IGS_RE_VAL_CAH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_VAL_CAH" AS
/* $Header: IGSRE06B.pls 120.0 2005/06/02 03:38:22 appldev noship $ */
 -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function GENP_VAL_SDTT_SESS removed
  --svanukur    08-apr-2004     BUG no 3453123. Removed default declaration in the body since this is
  --                            a GSCC violation
  --                            Removed procedure resp_val_cah_strt_dt as part of bug
  -------------------------------------------------------------------------------------------
  -- Allow for specified IGS_RE_CANDIDATURE trigger validation.
  PROCEDURE RESP_VAL_CA_TRG(
  p_table_name IN VARCHAR2 ,
  p_insert_delete_ind IN VARCHAR2 )
  AS
  	cst_rsup_perc		CONSTANT	VARCHAR2(30) := 'RESP_VAL_RSUP_PERC';
  	cst_cah_hist_dt		CONSTANT	VARCHAR2(30) := 'RESP_VAL_CAH_HIST_DT';
  	cst_insert		CONSTANT	VARCHAR2(1) := 'I';
  	cst_delete		CONSTANT	VARCHAR2(1) := 'D';
  BEGIN
  DECLARE
	L_ROWID VARCHAR2(25);
  BEGIN
  	IF p_table_name IN (cst_rsup_perc, cst_cah_hist_dt) THEN
  		IF p_insert_delete_ind = cst_insert THEN
  			-- Inserts a record into the s_disable_table_trigger
  			-- database table.

			IGS_GE_S_DSB_TAB_TRG_PKG.INSERT_ROW(
				X_ROWID => L_ROWID ,
				X_TABLE_NAME =>p_table_name,
				X_SESSION_ID => userenv('SESSIONID'),
				x_mode => 'R'
				);

  		ELSIF p_insert_delete_ind = cst_delete THEN
  			-- Inserts a record into the s_disable_table_trigger
  			-- database table.
  			IGS_GE_MNT_SDTT.genp_del_sdtt(p_table_name);
  		END IF;
  	END IF;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_ca_trg;
  --
  -- Validate IGS_RE_CANDIDATURE attendance history changes prior to census date.
  FUNCTION resp_val_cah_census(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_effective_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_cah_census
  DECLARE
  	v_ca_sca_course_cd		IGS_RE_CANDIDATURE.sca_course_cd%TYPE;
  	v_daiv_alias_val		IGS_CA_DA_INST_V.alias_val%TYPE;
  	cst_unconfirm	CONSTANT
  		IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE := 'UNCONFIRM';
  	cst_duplicate	CONSTANT
  		IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE := 'DUPLICATE';
  	CURSOR c_ca IS
  		SELECT	ca.sca_course_cd
  		FROM	IGS_RE_CANDIDATURE ca
  		WHERE	ca.person_id		= p_person_id	AND
  			ca.sequence_number	= p_ca_sequence_number;
  	CURSOR c_sua_uv_daiv_sgcc IS
  		SELECT	daiv.alias_val
  		FROM	IGS_EN_SU_ATTEMPT sua,
  			IGS_PS_UNIT_VER uv,
  			IGS_CA_DA_INST_V daiv,
  			IGS_GE_S_GEN_CAL_CON sgcc
  		WHERE	sua.person_id		= p_person_id			AND
  			sua.course_cd		= v_ca_sca_course_cd		AND
  			sua.unit_attempt_status NOT IN (
  							cst_unconfirm,
  							cst_duplicate)		AND
  			sua.unit_cd		= uv.unit_cd			AND
  			sua.version_number	= uv.version_number		AND
  			uv.research_unit_ind	= 'Y'				AND
  			sua.cal_type		= daiv.cal_type			AND
  			sua.ci_sequence_number	= daiv.ci_sequence_number	AND
  			daiv.dt_alias		= sgcc.census_dt_alias		AND
  			sgcc.s_control_num	= 1				AND
  			p_effective_dt		<= daiv.alias_val		AND
  			daiv.alias_val		< trunc(SYSDATE);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	OPEN c_ca;
  	FETCH c_ca INTO v_ca_sca_course_cd;
  	IF c_ca%NOTFOUND OR
  			v_ca_sca_course_cd IS NULL THEN
  		CLOSE c_ca;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_ca;
  	OPEN c_sua_uv_daiv_sgcc;
  	FETCH c_sua_uv_daiv_sgcc INTO v_daiv_alias_val;
  	IF c_sua_uv_daiv_sgcc%FOUND THEN
  		--Changes are after a census date
  		CLOSE c_sua_uv_daiv_sgcc;
  		p_message_name := 'IGS_RE_CAND_ATT_HIST_CHANGES';
  		RETURN TRUE;
  	END IF;
  	CLOSE c_sua_uv_daiv_sgcc;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_ca%ISOPEN THEN
  			CLOSE c_ca;
  		END IF;
  		IF c_sua_uv_daiv_sgcc%ISOPEN THEN
  			CLOSE c_sua_uv_daiv_sgcc;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_cah_census;
  --
  -- Validate IGS_RE_CANDIDATURE update.
  FUNCTION resp_val_ca_childupd(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  --  Change History :
  --  Who       When            What
  -- stutta    05-May-2004   Added c_awd_exists,c_incomp_awd cursors and modified logic to return false
  --                         only if a completed program attempt has all its awards completed.(Bug #3577988)
  BEGIN	-- resp_val_ca_childupd
  	-- This module validates the update of IGS_RE_CANDIDATURE child details.
  	-- Validations are:
  	-- IGS_RE_CANDIDATURE child details cannot be updated if
  	-- IGS_EN_STDNT_PS_ATT.course_attempt_status is 'COMPLETED' with all awards completed.
    -- If atleast one award is incomplete or no award is associated, update is allowed.
  DECLARE
  	cst_completed	CONSTANT	VARCHAR2(10) := 'COMPLETED';
  	v_sca_course_cd			IGS_RE_CANDIDATURE.sca_course_cd%TYPE;
  	v_course_attempt_status		IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
    v_dummy VARCHAR2(1);

  	CURSOR	c_ca IS
  		SELECT 	ca.sca_course_cd
  		FROM	IGS_RE_CANDIDATURE ca
  		WHERE	ca.person_id 		= p_person_id AND
   			ca.sequence_number 	= p_ca_sequence_number;
  	CURSOR c_sca (
  		cp_sca_course_cd	IGS_EN_STDNT_PS_ATT.course_cd%TYPE) IS
  		SELECT	sca.course_attempt_status
  		FROM	IGS_EN_STDNT_PS_ATT sca
  		WHERE	sca.person_id = p_person_id AND
  			sca.course_cd = cp_sca_course_cd;
    CURSOR c_awd_exists(cp_person_id igs_en_stdnt_ps_att.person_id%TYPE,
                           cp_course_cd igs_en_stdnt_ps_att.course_cd%TYPE) IS
       SELECT 'x'
       FROM igs_en_spa_awd_aim
       WHERE person_id = cp_person_id
       AND      course_cd = cp_course_cd
       AND  ( 	end_dt IS NULL OR
              	(end_dt IS NOT NULL AND complete_ind = 'Y')
            );
      CURSOR c_incomp_awd(cp_person_id igs_en_stdnt_ps_att.person_id%TYPE,
                          cp_course_cd igs_en_stdnt_ps_att.course_cd%TYPE) IS
      SELECT 'x'
      FROM igs_en_spa_awd_aim
      WHERE person_id =  cp_person_id
      AND course_cd = cp_course_cd
      AND NVL(complete_ind,'N') = 'N'
      AND end_dt IS NULL;

  BEGIN
  	p_message_name := NULL;
  	OPEN c_ca;
  	FETCH c_ca INTO v_sca_course_cd;
  	IF c_ca%NOTFOUND THEN
  			--Invalid parameters, handled elsewhere
  		CLOSE c_ca;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_ca;
  	IF v_sca_course_cd IS NOT NULL THEN
  		OPEN c_sca(
  				v_sca_course_cd);
  		FETCH c_sca INTO v_course_attempt_status;
  		IF c_sca%NOTFOUND THEN
  			CLOSE c_sca;
  			--This should not occur, this will be handled by database integrity
  			RETURN TRUE;
  		END IF;
  		CLOSE c_sca;
  		IF v_course_attempt_status = cst_completed THEN
          			OPEN c_awd_exists(p_person_id,v_sca_course_cd);
                    FETCH c_awd_exists INTO v_dummy;
                    IF c_awd_exists%FOUND THEN
                    	OPEN c_incomp_awd(p_person_id,v_sca_course_cd);
                        FETCH c_incomp_awd INTO v_dummy;
                    	IF c_incomp_awd%FOUND THEN
                    		CLOSE c_awd_exists;
                    		CLOSE c_incomp_awd;
                    		RETURN TRUE;
                    	ELSE
                    		p_message_name := 'IGS_RE_CANT_UPD_DET_WHEN_COUR';
                    		CLOSE c_awd_exists;
                    		CLOSE c_incomp_awd;
                    		RETURN FALSE;
                    	END IF;
                    ELSE
                    	CLOSE c_awd_exists;
                    	RETURN TRUE;
                    END IF;

  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_ca%ISOPEN) THEN
  			CLOSE c_ca;
  		END IF;
  		IF (c_sca%ISOPEN) THEN
  			CLOSE c_sca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_ca_childupd;
  --
  -- Validate IGS_RE_CANDIDATURE attendance history dates.
  FUNCTION resp_val_cah_hist_dt(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_validate_first_hist_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN 	-- resp_val_cah_hist_dt
  	-- This module validates for IGS_RE_CDT_ATT_HIST for the IGS_RE_CANDIDATURE. The
  	-- following is validated:
  	-- * first hist_start_dt = IGS_EN_STDNT_PS_ATT.commencement_dt
  	-- * IGS_RE_CDT_ATT_HIST do not overlap or have gaps ie. history is
  	--   continuous.
         -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What

  --svanukur    15-apr-2004     BUG no 3453123. Removed the check for commencement date not equal to
  --                            history start date; moved this to the IGSRE013.pld instead
  -------------------------------------------------------------------------------------------
  DECLARE
  	v_sca_commencement_dt			IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
  	v_last_hist_end_dt			IGS_RE_CDT_ATT_HIST.hist_end_dt%TYPE;
  	CURSOR c_cah IS
  		SELECT	cah.person_id,
  			cah.ca_sequence_number,
  			cah.hist_start_dt,
  			cah.hist_end_dt
  		FROM	IGS_RE_CDT_ATT_HIST	cah
  		WHERE	cah.person_id		= p_person_id AND
  			cah.ca_sequence_number	= p_ca_sequence_number
  		ORDER BY cah.hist_start_dt ASC;
  	CURSOR c_ca_sca(
  			cp_person_id		IGS_RE_CDT_ATT_HIST.person_id%TYPE,
  			cp_ca_sequence_number	IGS_RE_CDT_ATT_HIST.ca_sequence_number%TYPE) IS
  		SELECT	sca.commencement_dt
  		FROM	IGS_RE_CANDIDATURE		ca,
  			IGS_EN_STDNT_PS_ATT	sca
  		WHERE	ca.person_id		= cp_person_id AND
  			ca.sequence_number	= cp_ca_sequence_number AND
  			ca.person_id		= sca.person_id AND
  			ca.sca_course_cd	= sca.course_cd;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	FOR v_cah_rec IN c_cah LOOP
  		IF c_cah%ROWCOUNT = 1 THEN
  			IF p_validate_first_hist_ind = 'Y' THEN
  				OPEN c_ca_sca(
  						v_cah_rec.person_id,
  						v_cah_rec.ca_sequence_number);
  				FETCH c_ca_sca INTO v_sca_commencement_dt;
  				IF c_ca_sca%NOTFOUND OR
  						v_sca_commencement_dt IS NULL THEN
  					CLOSE c_ca_sca;
  					p_message_name := 'IGS_RE_CAND_ATTEND_NOT_RELEV';
  					RETURN FALSE;
  				END IF;
  				CLOSE c_ca_sca;
  				END IF;
  			v_last_hist_end_dt := v_cah_rec.hist_end_dt;
  		ELSE
  			IF TRUNC(v_cah_rec.hist_start_dt) <>
  					TRUNC(v_last_hist_end_dt + 1) THEN
  				p_message_name := 'IGS_RE_CAND_ATTEND_NOT_CONTIN';
  				RETURN FALSE;
  			END IF;
  			v_last_hist_end_dt := v_cah_rec.hist_end_dt;
  		END IF;
  	END LOOP;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_cah%ISOPEN THEN
  			CLOSE c_cah;
  		END IF;
  		IF c_ca_sca%ISOPEN THEN
  			CLOSE c_ca_sca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_cah_hist_dt;
  --
  -- Validate IGS_RE_CANDIDATURE attendance history insert.
  FUNCTION resp_val_cah_ca_ins(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_commencement_dt OUT NOCOPY DATE ,
  p_attendance_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN 	-- resp_val_cah_ca_ins
  	-- This module validates IGS_RE_CDT_ATT_HIST insert in the context of
  	-- IGS_RE_CANDIDATURE. The following is validated.
  	-- * IGS_RE_CANDIDATURE.sca_course_cd must exist.
  	-- * research IGS_RE_CANDIDATURE IGS_EN_STDNT_PS_ATT.student_confirmed_ind is
  	-- 'Y' and IGS_EN_STDNT_PS_ATT.commencement_dt exists.
  DECLARE
  	v_sca_course_cd			IGS_RE_CANDIDATURE.sca_course_cd%TYPE;
  	v_sca_student_confirmed_ind
  					IGS_EN_STDNT_PS_ATT.student_confirmed_ind%TYPE;
  	v_sca_commencement_dt		IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
  	v_sca_attendance_type		IGS_EN_STDNT_PS_ATT.attendance_type%TYPE;
  	CURSOR c_ca IS
  		SELECT 	ca.sca_course_cd
  		FROM 	IGS_RE_CANDIDATURE		ca
  		WHERE	ca.person_id 		= p_person_id AND
  			ca.sequence_number 	= p_ca_sequence_number;
  	CURSOR c_sca(cp_sca_course_cd	 IGS_RE_CANDIDATURE.sca_course_cd%TYPE)
  		IS
  		SELECT	sca.student_confirmed_ind,
  			sca.commencement_dt,
  			sca.attendance_type
  		FROM 	IGS_EN_STDNT_PS_ATT 	sca
  		WHERE	sca.person_id 		= p_person_id AND
  			sca.course_cd 		= cp_sca_course_cd;
  BEGIN
  	p_message_name := NULL;
  	p_commencement_dt := NULL;
  	p_attendance_type := NULL;
  	IF p_sca_course_cd IS NULL THEN
  		-- Determine if student IGS_PS_COURSE attempt exists for the research
  		-- IGS_RE_CANDIDATURE
  		OPEN c_ca;
  		FETCH c_ca INTO v_sca_course_cd;
  		IF c_ca%NOTFOUND THEN
  			-- Invalid parameters this will be handled elsewhere
  			CLOSE c_ca;
  			RETURN TRUE;
  		END IF;
  		CLOSE c_ca;
  		IF v_sca_course_cd IS NULL THEN
  			-- Changes to IGS_RE_CANDIDATURE attendance history are not recorded while
  			-- IGS_RE_CANDIDATURE is only associated with an admission IGS_PS_COURSE application
  			p_message_name := 'IGS_RE_CAND_STILL_UNDER_PROC';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		v_sca_course_cd := p_sca_course_cd;
  	END IF;
  	OPEN c_sca(v_sca_course_cd);
  	FETCH c_sca INTO
  			v_sca_student_confirmed_ind,
  			v_sca_commencement_dt,
  			v_sca_attendance_type;
  	IF c_sca%NOTFOUND THEN
  		-- Invalid parameters, this will be handled elsewhere
  		CLOSE c_sca;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_sca;
  	IF v_sca_student_confirmed_ind = 'N' THEN
  		p_message_name := 'IGS_RE_CHK_RSRCH_CAND_HISTOR';
  		RETURN FALSE;
  	END IF;
  	IF v_sca_commencement_dt IS NULL THEN
  		p_message_name := 'IGS_RE_CANT_INS_CAND_ATTEND';
  		RETURN FALSE;
  	END IF;
  	p_commencement_dt := v_sca_commencement_dt;
  	p_attendance_type := v_sca_attendance_type;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_ca%ISOPEN THEN
  			CLOSE c_ca;
  		END IF;
  		IF c_sca%ISOPEN THEN
  			CLOSE c_sca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_cah_ca_ins;
  --
  -- Validate IGS_RE_CANDIDATURE attendance hist start date and SCA commencement.
  FUNCTION resp_val_cah_comm(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_commencement_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_cah_comm
  	-- Description: This module validates that the first IGS_RE_CDT_ATT_HIST.
  	-- hist_start_dt is the same as the research IGS_RE_CANDIDATURE IGS_EN_STDNT_PS_ATT
  	-- commencement_dt.
  	-- This module currently only returns a warning.
  DECLARE
  	v_ca_sequence_number		IGS_RE_CANDIDATURE.sequence_number%TYPE;
  	v_cah_hist_start_dt		IGS_RE_CDT_ATT_HIST.hist_start_dt%TYPE;
  	CURSOR	c_ca IS
  		SELECT 	ca.sequence_number
  		FROM 	IGS_RE_CANDIDATURE 		ca
  		WHERE	ca.person_id 		= p_person_id AND
  			ca.sca_course_cd 	= p_sca_course_cd;
  	CURSOR	c_cah(
  		cp_ca_sequence_number		IGS_RE_CANDIDATURE.sequence_number%TYPE)IS
  		SELECT 	 cah.hist_start_dt
  		FROM 	 IGS_RE_CDT_ATT_HIST 	cah
  		WHERE	 cah.person_id		= p_person_id AND
  			 cah.ca_sequence_number = cp_ca_sequence_number
  		ORDER BY cah.hist_start_dt;
  BEGIN
  	p_message_name := NULL;
  	IF (p_commencement_dt) IS NOT NULL THEN
  		IF (p_ca_sequence_number) IS NULL THEN
  			OPEN c_ca;
  			FETCH c_ca INTO v_ca_sequence_number;
  			IF (c_ca%NOTFOUND) THEN
  					CLOSE c_ca;
  			--Student IGS_PS_COURSE attempt does not have IGS_RE_CANDIDATURE details, or
  			--Parameters are invalid
  				p_message_name := NULL;
  				RETURN TRUE;
  			END IF;
  			CLOSE c_ca;
  		ELSE
  			v_ca_sequence_number := p_ca_sequence_number;
  		END IF;
  		OPEN c_cah(
  			v_ca_sequence_number);
  		FETCH c_cah INTO v_cah_hist_start_dt;
  		IF (c_cah%NOTFOUND) THEN
  				CLOSE c_cah;
  			--No histories, therefore all is valid
  			p_message_name := NULL;
  			RETURN TRUE;
  		END IF;
  		IF (v_cah_hist_start_dt <> p_commencement_dt) THEN
  			--Warn that commencement date and first history start date do not match
  			p_message_name := 'IGS_RE_CHK_CAND_ATND_HIST_DT';
  			RETURN TRUE;
  		END IF;
  		CLOSE c_cah;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_cah_comm;
  --
  -- Validate IGS_RE_CANDIDATURE attendance history end date.
  FUNCTION resp_val_cah_end_dt(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_hist_start_dt IN DATE ,
  p_hist_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- resp_val_cah_end_dt
  	-- Description: This module validates IGS_RE_CDT_ATT_HIST.hist_end_dt.
  	-- Validations are:
  	-- *Hist_end_dt >= hist_start_dt and < current date.
  DECLARE
  BEGIN
  	p_message_name := NULL;
  	IF p_hist_end_dt >= TRUNC(SYSDATE) THEN
  		p_message_name := 'IGS_RE_HIST_EN_DT_LT_CURR_DT';
  		RETURN FALSE;
  	END IF;
  	IF (p_hist_end_dt < p_hist_start_dt) THEN
  		p_message_name := 'IGS_RE_HIST_END_DT_GE_ST_DT';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END resp_val_cah_end_dt;
 END IGS_RE_VAL_CAH;

/
