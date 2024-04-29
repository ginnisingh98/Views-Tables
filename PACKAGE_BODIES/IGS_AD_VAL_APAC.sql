--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_APAC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_APAC" AS
/* $Header: IGSAD37B.pls 120.1 2005/10/21 08:36:59 appldev ship $ */
  -- Validate that admission period admission category can be duplicated.
  FUNCTION admp_val_apac_dup(
  p_old_adm_cal_type IN VARCHAR2 ,
  p_old_adm_ci_sequence_number IN NUMBER ,
  p_old_admission_cat IN VARCHAR2 ,
  p_new_admission_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- admp_val_apac_dup
  	-- Routine to validate that at least on IGS_AD_PRD_PS_OF_OPT can be
  	-- duplicated  for the new admission category.
  DECLARE
  	v_apcoo_course_cd	IGS_AD_PRD_PS_OF_OPT.course_cd%TYPE;
  	v_apcoo_version_number	IGS_AD_PRD_PS_OF_OPT.version_number%TYPE;
  	v_apcoo_acad_cal_type	IGS_AD_PRD_PS_OF_OPT.acad_cal_type%TYPE;
  	v_ret_val		BOOLEAN	DEFAULT TRUE;
  	v_message_name		varchar2(30);
  	v_apcoo_found		BOOLEAN DEFAULT FALSE;
  	v_match_found		BOOLEAN DEFAULT FALSE;
  	CURSOR c_apcoo IS
  		SELECT DISTINCT course_cd,
  				version_number,
  				acad_cal_type
  		FROM	IGS_AD_PRD_PS_OF_OPT
  		WHERE	adm_cal_type 		= p_old_adm_cal_type AND
  			adm_ci_sequence_number 	= p_old_adm_ci_sequence_number AND
  			admission_cat 		= p_old_admission_cat;
  BEGIN
  	p_message_name := Null;
  	-- Check that the new admission period admission category combination has at
  	-- least one course offering option restriction that maps to the new
  	-- admission category.
  	FOR v_apcoo_rec IN c_apcoo LOOP
  		v_apcoo_found := TRUE;
  		-- For each record found, validate the course offering option of
  		-- the admission application against the admission cat.
  		IF IGS_AD_VAL_CRS_ADMPERD.admp_val_coo_adm_cat(
  							v_apcoo_rec.course_cd,
  							v_apcoo_rec.version_number,
  							v_apcoo_rec.acad_cal_type,
  							NULL,
  							NULL,
  							NULL,
  							p_new_admission_cat,
  							v_message_name) = TRUE THEN
  			-- At least one match is found, so finish processing
  			v_match_found := TRUE;
  			EXIT;
  		END IF;
  	END LOOP;
  	IF v_apcoo_found = FALSE THEN
  		-- no records found for c_apcoo
  		p_message_name := 'IGS_AD_ADM_PERIOD_PRG_DUPL';
  		RETURN FALSE;
  	END IF;
  	IF v_match_found = TRUE THEN
  		-- existing Admission Period Course Offering Option restrictions map
  		-- to admission category
  		p_message_name := Null;
  		RETURN TRUE;
  	END IF;
  	-- The only way we reach here is if no match has been found against
  	-- admission cat rec
  	p_message_name := 'IGS_AD_ADM_PERIOD_PRG_DUPL';
  	RETURN FALSE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APAC.admp_val_apac_dup');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_apac_dup;

  --
  -- Validate admission period admission category calendar instance.
  FUNCTION admp_val_apac_ci(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_start_dt OUT NOCOPY DATE ,
  p_end_dt OUT NOCOPY DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN -- admp_val_apac_ci
  	  -- Validate that the admission period admission category.
  	  -- Calendar type must have calendar category of ADMISSION
  	  -- Calendar instance must be ACTIVE
  	  -- Calendar instance must have a superior link to one calendar instance of
  	  --  category ?ACADEMIC?.
  	  -- Calendar instance alternate code must not already exist for an admission
  	  -- period with the same admission category linked to the same superior
  	  -- academic calendar instance.
  DECLARE
  	v_alter_found	   	CHAR DEFAULT 'N';
  	v_alter_exist		CHAR DEFAULT 'N';
  	v_sup_cal_type		IGS_CA_INST_REL.sup_cal_type%TYPE;
  	v_sup_ci_seq_no		IGS_CA_INST_REL.sup_ci_sequence_number%TYPE;
  	v_message_name	   	varchar2(30);
  	v_alternate_code		IGS_CA_INST.alternate_code%TYPE;
  	v_start_dt		IGS_CA_INST.start_dt%TYPE;
  	v_end_dt			IGS_CA_INST.end_dt%TYPE;
  	CURSOR  c_sup (
  			 p_adm_cal_type			IGS_AD_PERD_AD_CAT.adm_cal_type%TYPE,
  			 p_adm_ci_sequence_number
  			IGS_AD_PERD_AD_CAT.adm_ci_sequence_number%TYPE)  IS
  		Select  cir1.sup_cal_type,
  			cir1.sup_ci_sequence_number
  		FROM	IGS_CA_INST_REL cir1,
  			IGS_CA_TYPE cat
  		WHERE   cir1.sub_cal_type		= p_adm_cal_type AND
  			cir1.sub_ci_sequence_number 	= p_adm_ci_sequence_number AND
  			cir1.sup_cal_type		= cat.cal_type AND
  			cat.s_cal_cat			= 'ACADEMIC';
  	CURSOR c_alter_code (
  				cp_sup_cal_type			  IGS_CA_INST_REL.sup_cal_type%TYPE,
  				cp_sup_ci_sequence_number
  				IGS_CA_INST_REL.sup_ci_sequence_number%TYPE) IS
  		SELECT DISTINCT ci.alternate_code,
  				cir2.sub_cal_type,
  				cir2.sub_ci_sequence_number
  		FROM   	IGS_CA_INST_REL cir2,
  			IGS_CA_INST ci,
  			IGS_CA_TYPE cat
  		WHERE  	cir2.sup_cal_type		= cp_sup_cal_type AND
  			cir2.sup_ci_sequence_number  	= cp_sup_ci_sequence_number  AND
  			(cir2.sub_cal_type		<> p_adm_cal_type	OR
  			cir2.sub_ci_sequence_number 	<> p_adm_ci_sequence_number) AND
  			cat.s_cal_cat			= 'ADMISSION' AND
  			cat.cal_type			= ci.cal_type AND
  			ci.cal_type			= cir2.sub_cal_type AND
  			ci.sequence_number		= cir2.sub_ci_sequence_number;
  	CURSOR c_apac (
  			cp_sub_cal_type			  IGS_CA_INST_REL.sub_cal_type%TYPE,
  			cp_sub_ci_sequence_number
  			IGS_CA_INST_REL.sub_ci_sequence_number%TYPE) IS
  		SELECT  admission_cat
  		FROM	IGS_AD_PERD_AD_CAT
  		WHERE   adm_cal_type		= cp_sub_cal_type  AND
  			adm_ci_sequence_number 	= cp_sub_ci_sequence_number;
  BEGIN
  	p_message_name := Null;
  	IF IGS_AD_VAL_APAC.admp_val_adm_ci(
  			p_adm_cal_type,
  		   	p_adm_ci_sequence_number,
  			v_start_dt,
  			v_end_dt,
  			v_alternate_code,
  			v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	ELSE
  		p_start_dt:= v_start_dt;
  		p_end_dt := v_end_dt;
  	END IF;
  	OPEN c_sup(
  		p_adm_cal_type,
  	   	p_adm_ci_sequence_number);
  	<<c_sup_loop>>
  	LOOP
  		-- Get superior academic calendar instance
  		FETCH c_sup INTO v_sup_cal_type,
   				 v_sup_ci_seq_no;
  		EXIT WHEN (c_sup%NOTFOUND);
  		-- get alternate_code, sub_cal_type and sub_ci_sequence_number
  		-- from cal_instance using superior cal_cal_type and ci_sequence_no
  		FOR v_rec_alter_code IN c_alter_code(
  			   			v_sup_cal_type,
  			   			v_sup_ci_seq_no) LOOP
  			v_alter_found := 'Y';
  			-- check for same admission category for each record found
  			FOR v_rec_apac IN c_apac(
  						v_rec_alter_code.sub_cal_type,
  						v_rec_alter_code.sub_ci_sequence_number) LOOP
  				-- Check that the alternate code of the admission period does not
  				-- already exist for another admission period linked to the same academic
  				-- period.
  	 			IF  (v_rec_apac.admission_cat = p_admission_cat AND
  			   			v_rec_alter_code.alternate_code = v_alternate_code) THEN
  					v_alter_exist := 'Y';
  					EXIT c_sup_loop;
  				END IF;
  			END LOOP; -- c_apac
  		END LOOP; -- c_alter_code
  		IF (v_alter_found = 'N') THEN
  			-- must fetch twice to force it to return false and 2646 if
  			-- rowcount of c_sup found is > 1
  			FETCH c_sup INTO v_sup_cal_type,
  					 v_sup_ci_seq_no;
  			EXIT c_sup_loop;
  		END IF;
  	END LOOP; -- c_sup
  	-- The admission period should be linked to ONE academic calendar
    -- 20-OCT-2005 akadam modified this validation as per bug #4554718
  	IF (c_sup%ROWCOUNT = 0	) THEN
  		CLOSE c_sup;
  		p_message_name := 'IGS_AD_ADMCAL_SUPLINK_ADMCAL';
  		RETURN FALSE;
  	END IF;
  	IF (v_alter_exist = 'Y') THEN
  		CLOSE c_sup;
  		p_message_name := 'IGS_AD_ADMCAL_ALTCD_ADMCAT';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_sup;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APAC.admp_val_apac_ci');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_apac_ci;

  --
  -- Insert admission period admission process category
  -- Enhancement: 3132406 nsinha 9/25/2003 added new parameter p_prior_adm_ci_seq_number
  --
  FUNCTION admp_ins_dflt_apapc(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_prior_adm_ci_seq_number IN NUMBER  DEFAULT NULL
  )
  RETURN BOOLEAN IS
         gv_other_detail      VARCHAR2(255);
  BEGIN   -- admp_ins_dflt_apapc
  	-- Routine to insert admission period admission process categories.
  	-- This will be fired from the form when saving an admission period
  	-- for an admission category.
	-- Enhancement: 3132406 nsinha 9/25/2003 added new parameter p_prior_adm_ci_seq_number
	-- Added logic related to cursor c_apapc_roll.
  DECLARE
  	CURSOR c_apapc(
  		cp_cal_type	IGS_AD_PRD_AD_PRC_CA.adm_cal_type%TYPE,
  		cp_sequence_number	IGS_AD_PRD_AD_PRC_CA.adm_ci_sequence_number%TYPE,
  		cp_admission_cat	IGS_AD_PRD_AD_PRC_CA.admission_cat%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_AD_PRD_AD_PRC_CA
  		WHERE	adm_cal_type 		= cp_cal_type AND
  			adm_ci_sequence_number 	= cp_sequence_number AND
  			admission_cat 		= cp_admission_cat;
  	CURSOR c_apc(
  		cp_admission_cat         IGS_AD_PRD_AD_PRC_CA.admission_cat%TYPE) IS
  		SELECT	s_admission_process_type
  		FROM	IGS_AD_PRCS_CAT
  		WHERE	admission_cat 	= cp_admission_cat
		AND     closed_ind = 'N';                    --added the closed indicator for bug# 2380108 (rghosh)
  	v_apapc_rec                         c_apapc%ROWTYPE;
    v_rowid	VARCHAR2(25);

	CURSOR c_apapc_roll (
  		cp_cal_type	IGS_AD_PRD_AD_PRC_CA.adm_cal_type%TYPE,
  		cp_sequence_number	IGS_AD_PRD_AD_PRC_CA.adm_ci_sequence_number%TYPE,
  		cp_admission_cat	IGS_AD_PRD_AD_PRC_CA.admission_cat%TYPE) IS
  		SELECT	*
  		FROM	IGS_AD_PRD_AD_PRC_CA
  		WHERE	adm_cal_type 		= cp_cal_type AND
  			adm_ci_sequence_number 	= cp_sequence_number AND
  			admission_cat 		= cp_admission_cat AND
            NVL (closed_ind,'N') = 'N';
	l_single_response_flag igs_ad_prd_ad_prc_ca.single_response_flag%TYPE;

  BEGIN
  	p_message_name := Null;
  	-- Check that an IGS_AD_PRD_AD_PRC_CA record does not already exist
  	OPEN c_apapc(
  		p_adm_cal_type,
  		p_adm_ci_sequence_number,
  		p_admission_cat);
  	FETCH c_apapc INTO v_apapc_rec;
  	IF c_apapc%FOUND THEN
  		CLOSE c_apapc;
  		p_message_name := 'IGS_AD_CAN_DFLT_ADMPRC_TYPES';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_apapc;

	IF p_prior_adm_ci_seq_number IS NULL THEN
		FOR v_apc_rec IN c_apc(p_admission_cat) LOOP

			   IGS_AD_PRD_AD_PRC_CA_PKG.INSERT_ROW(
				  X_ROWID => v_rowid,
				  X_ADM_CAL_TYPE => p_adm_cal_type,
				  X_ADM_CI_SEQUENCE_NUMBER => p_adm_ci_sequence_number,
				  X_ADMISSION_CAT => p_admission_cat,
				  X_S_ADMISSION_PROCESS_TYPE => v_apc_rec.s_admission_process_type,
				  X_MODE => 'R');

		END LOOP;
	ELSE -- p_prior_adm_ci_seq_number parameter IS NOT NULL
	    -- OPEN c_apapc_roll (p_adm_cal_type, p_prior_adm_ci_seq_number, p_admission_cat)
		-- INSERT INTO IGS_AD_PRD_AD_PRC_CA_PKG, the records fetched by above cursor as follows
		FOR v_apapc_rec IN c_apapc_roll (p_adm_cal_type, p_prior_adm_ci_seq_number, p_admission_cat) LOOP
		     --DECODE(v_apapc_rec.include_sr_in_rollover_flag,'Y', v_apapc_rec.single_response_flag ,'N')
			 IF v_apapc_rec.include_sr_in_rollover_flag = 'Y' THEN
			   l_single_response_flag := v_apapc_rec.single_response_flag;
			 ELSE
			   l_single_response_flag := 'N';
			 END IF;

			 IGS_AD_PRD_AD_PRC_CA_PKG.INSERT_ROW (
				  X_ROWID => v_rowid,
				  X_ADM_CAL_TYPE => p_adm_cal_type,
				  X_ADM_CI_SEQUENCE_NUMBER => p_adm_ci_sequence_number,
				  X_ADMISSION_CAT => p_admission_cat,
				  X_S_ADMISSION_PROCESS_TYPE => v_apapc_rec.s_admission_process_type,
				  X_SINGLE_RESPONSE_FLAG => l_single_response_flag,
				  X_INCLUDE_SR_IN_ROLLOVER_FLAG => v_apapc_rec.include_sr_in_rollover_flag, /*Rollover flag from  Prior Admission period should be carried to new Rollover period*/
				  X_MODE => 'R');

		END LOOP;
	END IF;
	RETURN TRUE;

  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APAC.admp_ins_dflt_apapc');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_ins_dflt_apapc;

  --
  -- Validate admission period calendar instance
  FUNCTION admp_val_adm_ci(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_start_dt OUT NOCOPY DATE ,
  p_end_dt OUT NOCOPY DATE ,
  p_alternate_code OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail			VARCHAR2(255);
  BEGIN 	-- admp_val_adm_ci
  	-- Validate that the admission period admission category.
  	-- Calendar type must have calendar category of ?ADMISSION?
  	-- Calendar instance must be ?ACTIVE?
  DECLARE
  	cst_admission	CONSTANT VARCHAR2(9) := 'ADMISSION';
  	cst_active	CONSTANT VARCHAR2(9) := 'ACTIVE';      --removed the planned variable (cst_planned) as per bug#2722785 --rghosh
  	v_s_cal_cat	IGS_CA_TYPE.s_cal_cat%TYPE;
  	v_s_cal_status	IGS_CA_STAT.s_cal_status%TYPE;
  	v_alternate_code	IGS_CA_INST.alternate_code%TYPE;
  	v_start_dt	IGS_CA_INST.start_dt%TYPE;
  	v_end_dt		IGS_CA_INST.end_dt%TYPE;
  	CURSOR c_s_cal_cat (
  			cp_adm_cal_type IGS_AD_PERD_AD_CAT.adm_cal_type%TYPE) IS
  		SELECT	cat.s_cal_cat
  		FROM	IGS_CA_TYPE cat
  		WHERE	cat.cal_type 		= cp_adm_cal_type;
  	CURSOR c_cal_instance_cal_status (
  			cp_adm_cal_type IGS_AD_PERD_AD_CAT.adm_cal_type%TYPE,
  			cp_adm_ci_sequence_number IGS_AD_PERD_AD_CAT.adm_ci_sequence_number%TYPE)
  	 IS
  		SELECT	cs.s_cal_status,
  			ci.alternate_code,
  			ci.start_dt,
  			ci.end_dt
  		FROM	IGS_CA_INST ci,
  			IGS_CA_STAT cs
  		WHERE	ci.cal_type 		= cp_adm_cal_type AND
  			ci.sequence_number 	= cp_adm_ci_sequence_number AND
  			ci.cal_status 		= cs.cal_status;

  BEGIN
  	p_message_name := Null;
  	OPEN	c_s_cal_cat(
  			p_adm_cal_type);
  	FETCH	c_s_cal_cat INTO v_s_cal_cat;
  	IF(c_s_cal_cat%FOUND) THEN
  		IF(v_s_cal_cat <> cst_admission) THEN
  			CLOSE c_s_cal_cat;
  			p_message_name := 'IGS_AD_ADMCAL_CAT_AS_ADM';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_s_cal_cat;
  	p_alternate_code := NULL;
  	p_start_dt := NULL;
  	p_end_dt := NULL;
  	OPEN	c_cal_instance_cal_status(
  				p_adm_cal_type,
  				p_adm_ci_sequence_number);
  	FETCH	c_cal_instance_cal_status INTO
  			v_s_cal_status, v_alternate_code, v_start_dt, v_end_dt;
  	IF(c_cal_instance_cal_status%FOUND) THEN
  		IF(v_s_cal_status <> cst_active) THEN            --removed the planned status as per bug#2722785 --rghosh
  			CLOSE c_cal_instance_cal_status;
  			p_message_name := 'IGS_AD_ADMCAL_PLANNED_ACTIVE';
  			RETURN FALSE;
  		ELSE
  			p_alternate_code := v_alternate_code;
  			p_start_dt := v_start_dt;
  			p_end_dt := v_end_dt;
  		END IF;
  	END IF;
  	CLOSE c_cal_instance_cal_status;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APAC.admp_val_adm_ci');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_adm_ci;
  --
  -- Validate if IGS_AD_CAT.admission_cat is closed.


END IGS_AD_VAL_APAC;

/
