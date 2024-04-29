--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_APCOOD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_APCOOD" AS
/* $Header: IGSAD41B.pls 115.6 2003/01/08 14:33:59 rghosh ship $ */
  -- Validate admission period calendar instance

--
  -- Validate the adm period course off option date details
  FUNCTION admp_val_apcood_opt(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
     	gv_other_detail		VARCHAR2(255);
  BEGIN	-- admp_val_apcood_opt
  	-- Validate the admission period course offering option date details
  DECLARE
  	v_s_admission_process_type	IGS_AD_PRCS_CAT.s_admission_process_type%TYPE;
  	v_message_name			varchar2(30);
  	v_valid_optn			BOOLEAN DEFAULT NULL;
  	v_apapc_found			BOOLEAN DEFAULT FALSE;
  	CURSOR c_apapc IS
  		SELECT 	s_admission_process_type
  		FROM 	IGS_AD_PRD_AD_PRC_CA
  		WHERE	adm_cal_type 		= p_adm_cal_type AND
  			adm_ci_sequence_number 	= p_adm_ci_sequence_number AND
  			admission_cat 		= p_admission_cat;
  	----------------------------------------- SUBFUNCTION -------------------------
  ------------------------------
  	FUNCTION admpl_val_option (v_s_admission_process_type
  		 IGS_AD_PRCS_CAT.s_admission_process_type%TYPE)
  	RETURN BOOLEAN
  	IS
  	BEGIN 	-- admpl_val_option
  		-- validate options
  	DECLARE
  		v_return_val		BOOLEAN DEFAULT FALSE;
  		v_location_cd		IGS_PS_OFR_PAT.location_cd%TYPE;
  		v_attendance_mode	IGS_PS_OFR_PAT.attendance_mode%TYPE;
  		v_attendance_type	IGS_PS_OFR_PAT.attendance_type%TYPE;
  		-- Validate option
  		CURSOR c_acov (
  				cp_s_admission_process_type
  				IGS_AD_PRCS_CAT.s_admission_process_type%TYPE) IS
  			SELECT	acov.location_cd,
  				acov.attendance_mode,
  				acov.attendance_type
  			FROM	IGS_PS_OFR_PAT_APCOOD_V acov
  			WHERE	acov.adm_cal_type 		= p_adm_cal_type AND
  				acov.adm_ci_sequence_number 	= p_adm_ci_sequence_number AND
  				acov.admission_cat 		= p_admission_cat AND
  				acov.s_admission_process_type 	= cp_s_admission_process_type AND
  				(p_course_cd IS NULL OR
  				(acov.course_cd			= p_course_cd  AND
  				acov.version_number 		= p_version_number AND
  				acov.acad_cal_type 		= p_acad_cal_type)) AND
  				(p_location_cd IS NULL OR
  				acov.location_cd			= p_location_cd) AND
  				(p_attendance_mode IS NULL OR
  				acov.attendance_mode 		= p_attendance_mode) AND
  				(p_attendance_type IS NULL OR
  				acov.attendance_type 		= p_attendance_type);
  	BEGIN
  		OPEN c_acov(v_s_admission_process_type);
  		FETCH c_acov INTO  v_location_cd,
  				   v_attendance_mode,
  			           v_attendance_type;
  		IF (c_acov%FOUND) THEN
  			-- Option is valid
  			v_return_val := TRUE;
  		ELSE
  			-- Option is invalid
  			v_return_val := FALSE;
  		END IF;
  		CLOSE c_acov;
  		RETURN v_return_val;
  	END;
  	EXCEPTION
  		WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APCOOD.admp_val_option');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  	END admpl_val_option;
  ---------------------------- MAIN ---------------------------------
  BEGIN
  	p_message_name := Null;
  	IF p_s_admission_process_type IS NULL AND
  		p_course_cd IS NULL AND
  		p_location_cd IS NULL AND
  		p_attendance_mode IS NULL AND
  		p_attendance_type IS NULL THEN
  		-- At least one of the components must be specified for overrides
  		p_message_name := 'IGS_AD_ONE_COMPONENT_SPECIFY';
  		Return FALSE;
  	END IF;
  	IF p_location_cd IS NOT NULL OR
  			p_attendance_mode IS NOT NULL OR
  			p_attendance_type IS NOT NULL THEN
  		-- Check if the offering option is valid
  		IF p_s_admission_process_type IS NOT NULL THEN
  			v_s_admission_process_type := p_s_admission_process_type;
  			-- Validate option
  			IF admpl_val_option(v_s_admission_process_type) = FALSE THEN
  				v_valid_optn := FALSE;
  			ELSE
  				v_valid_optn := TRUE;
  			END IF;
  		ELSE
  			-- Select s_admission_process_type from dbase
  			FOR v_apapc_rec IN c_apapc LOOP
  				v_apapc_found := TRUE;
  				v_s_admission_process_type := v_apapc_rec.s_admission_process_type;
  				-- Validate option
  				IF NOT admpl_val_option(v_s_admission_process_type) THEN
  					v_valid_optn := FALSE;
  				ELSE
  					v_valid_optn := TRUE;
  					EXIT;
  				END IF;
  			END LOOP;
  			IF v_apapc_found = FALSE THEN
  				RETURN TRUE;
  			END IF;
  		END IF;
  		IF  v_valid_optn = FALSE THEN
  			p_message_name := 'IGS_AD_INVALID_POO_DT_OVERRID';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APCOOD.admp_val_apcood_opt');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_apcood_opt;
  --
  -- Validate the adm period course off option date course offering
  FUNCTION admp_val_apcood_co(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail			VARCHAR2(255);
  BEGIN 	-- admp_val_apcood_co
  	-- Routine to verify that the course offering is valid for the admission
  	-- period course offering option date override.
  DECLARE
  	v_s_adm_proc_type				IGS_AD_PRD_PS_OF_OPT.s_admission_process_type%TYPE;
  	v_cop_cir_rec_found				BOOLEAN DEFAULT FALSE;
  	v_apapc_rec_found				BOOLEAN DEFAULT FALSE;
  	v_crv_valid					BOOLEAN DEFAULT FALSE;
  	v_adm_perd_valid				BOOLEAN DEFAULT FALSE;
  	v_adm_cat_match					BOOLEAN DEFAULT FALSE;
  	v_crv_valid_cnt					NUMBER DEFAULT 0;
  	v_message_name					VARCHAR2(30);
  	CURSOR c_cop_cir (
  			cp_adm_cal_type			IGS_CA_INST.cal_type%TYPE,
  			cp_adm_ci_sequence_number	IGS_CA_INST.sequence_number%TYPE,
  			cp_acad_cal_type		IGS_CA_INST.cal_type%TYPE,
  			cp_course_cd			IGS_PS_OFR.course_cd%TYPE,
  			cp_version_number		IGS_PS_OFR.version_number%TYPE) IS
  		SELECT	cop.course_cd,
  			cop.version_number,
  			cop.cal_type,
  			cop.location_cd,
  			cop.attendance_mode,
  			cop.attendance_type
  		FROM	IGS_PS_OFR_PAT		cop,
  			IGS_CA_INST_REL	cir
  		WHERE	cir.sup_cal_type		= cp_acad_cal_type AND
  			cir.sub_cal_type		= cp_adm_cal_type AND
  			cir.sub_ci_sequence_number	= cp_adm_ci_sequence_number AND
  			cop.course_cd			= cp_course_cd AND
  			cop.version_number		= cp_version_number AND
  			cop.offered_ind			= 'Y' AND
  			cop.entry_point_ind		= 'Y' AND
  			cop.cal_type			= cir.sup_cal_type AND
  			cop.ci_sequence_number		= cir.sup_ci_sequence_number;
  	CURSOR c_apapc (
  			cp_adm_cal_type			IGS_CA_INST.cal_type%TYPE,
  			cp_adm_ci_sequence_number	IGS_CA_INST.sequence_number%TYPE,
  			cp_admission_cat		IGS_AD_PRD_PS_OF_OPT.admission_cat%TYPE) IS
  		SELECT	apapc.s_admission_process_type
  		FROM	IGS_AD_PRD_AD_PRC_CA	apapc
  		WHERE	apapc.adm_cal_type		= cp_adm_cal_type AND
  			apapc.adm_ci_sequence_number	= cp_adm_ci_sequence_number AND
  			apapc.admission_cat		= cp_admission_cat AND
			apapc.closed_ind                = 'N';      --added the closed indicator for bug# 2380108 (rghosh)
  BEGIN
  	p_message_name := Null;
  	-- Check if at least one course offering pattern exists for the admission
  	-- period course offering
  	FOR v_cop_cir_rec IN c_cop_cir(
  				p_adm_cal_type,
  				p_adm_ci_sequence_number,
  				p_acad_cal_type,
  				p_course_cd,
  				p_version_number) LOOP
  		v_cop_cir_rec_found := TRUE;
  		-- Determine if course offering is valid for the admission category
  		IF(IGS_AD_VAL_CRS_ADMPERD.admp_val_coo_adm_cat(
  							v_cop_cir_rec.course_cd,
  							v_cop_cir_rec.version_number,
  							v_cop_cir_rec.cal_type,
  							v_cop_cir_rec.location_cd,
  							v_cop_cir_rec.attendance_mode,
  							v_cop_cir_rec.attendance_type,
  							p_admission_cat,
  							v_message_name) = TRUE) THEN
  			v_adm_cat_match := TRUE;
  			IF(p_s_admission_process_type IS NULL) THEN
  				FOR v_apapc_rec IN c_apapc(
  							p_adm_cal_type,
  							p_adm_ci_sequence_number,
  							p_admission_cat) LOOP
  					v_apapc_rec_found := TRUE;
  					v_s_adm_proc_type := v_apapc_rec.s_admission_process_type;
  					-- Validate course offering
  					-- Determine if course version is valid
  					IF(IGS_AD_VAL_CRS_ADMPERD.admp_val_coo_crv(
  									v_cop_cir_rec.course_cd,
  									v_cop_cir_rec.version_number,
  									v_s_adm_proc_type,
  									'N', -- this is not offer processing
  									v_message_name) = TRUE) THEN
  						-- Valid course version is found
  						v_crv_valid := TRUE;
  						-- Determine if course offering is valid for the admission period
  						-- course offering option restriction
  						IF(IGS_AD_VAL_CRS_ADMPERD.admp_val_coo_admperd(
  											p_adm_cal_type,
  											p_adm_ci_sequence_number,
  											p_admission_cat,
  											v_s_adm_proc_type,
  											v_cop_cir_rec.course_cd,
  											v_cop_cir_rec.version_number,
  											v_cop_cir_rec.cal_type,
  											v_cop_cir_rec.location_cd,
  											v_cop_cir_rec.attendance_mode,
  											v_cop_cir_rec.attendance_type,
  											v_message_name) = TRUE) THEN
  							-- at least one admission period course offering option
  							-- restriction
  							v_adm_perd_valid := TRUE;
  						END IF;
  					END IF;
  					IF(v_crv_valid = TRUE AND
  							v_adm_perd_valid = TRUE) THEN
  						RETURN TRUE;
  					ELSIF(v_crv_valid = TRUE AND v_adm_perd_valid = FALSE) THEN
  						v_crv_valid_cnt := v_crv_valid_cnt + 1;
  						v_crv_valid := FALSE;
  						v_adm_perd_valid := FALSE;
  					END IF;
  				END LOOP;
  				IF(v_apapc_rec_found = FALSE) THEN
  					-- This is an error that will be handled outside this Module
  					-- ADMP_VAL_APCOOD_INS will be called before this module so
  					-- this condition should if happens should be trapped before
  					RETURN TRUE;
  				END IF;
  			ELSE
  				v_s_adm_proc_type := p_s_admission_process_type;
  				-- Validate course offering
  				-- Determine if course version is valid
  				IF(IGS_AD_VAL_CRS_ADMPERD.admp_val_coo_crv(
  								v_cop_cir_rec.course_cd,
  								v_cop_cir_rec.version_number,
  								v_s_adm_proc_type,
  								'N', -- this is not offer processing
  								v_message_name) = TRUE) THEN
  					-- Valid course version is found
  					v_crv_valid := TRUE;
  					-- Determine if course offering is valid for the admission period
  					-- course offering option restriction
  					IF(IGS_AD_VAL_CRS_ADMPERD.admp_val_coo_admperd(
  										p_adm_cal_type,
  										p_adm_ci_sequence_number,
  										p_admission_cat,
  										v_s_adm_proc_type,
  										v_cop_cir_rec.course_cd,
  										v_cop_cir_rec.version_number,
  										v_cop_cir_rec.cal_type,
  										v_cop_cir_rec.location_cd,
  										v_cop_cir_rec.attendance_mode,
  										v_cop_cir_rec.attendance_type,
  										v_message_name) = TRUE) THEN
  						-- at least one admission period course offering option
  						-- restriction
  						v_adm_perd_valid := TRUE;
  					END IF;
  				END IF;
  				IF(v_crv_valid = TRUE AND
  						v_adm_perd_valid = TRUE) THEN
  					RETURN TRUE;
  				ELSIF(v_crv_valid = TRUE AND v_adm_perd_valid = FALSE) THEN
  					v_crv_valid_cnt := v_crv_valid_cnt + 1;
  					v_crv_valid := FALSE;
  					v_adm_perd_valid := FALSE;
  				END IF;
  			END IF;
  		END IF;
  	END LOOP;
  	-- No IGS_PS_COURSE offering records
  	IF(v_cop_cir_rec_found = FALSE) THEN
  		p_message_name := 'IGS_AD_NO_PRGOFOP_ENTRYPOINT';
  		RETURN FALSE;
  	END IF;
  	-- No admission category matches
  	IF(v_adm_cat_match = FALSE) THEN
  		p_message_name := 'IGS_AD_NONE_PRGOFOP_COMPERIOD';
  		RETURN FALSE;
  	END IF;
  	-- No IGS_PS_COURSE version is valid
  	IF(v_crv_valid_cnt = 0) THEN
  		p_message_name := 'IGS_AD_PRGVER_OFR_COMPRD';
  		RETURN FALSE;
  	ELSE
  		p_message_name := 'IGS_AD_NOPOP_COMMENCE_PRD';
  		RETURN FALSE;
  	END IF;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APCOOD.admp_val_apcood_co');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_apcood_co;
  --
  -- Validate the adm period course off option date optional components.
  FUNCTION admp_val_apcood_link(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_apcood_sequence_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- admp_val_apcood_link
  	-- This module will validate that admission period date links do not clash
  	-- with existing admission period date links.
  	-- This module must ensure that this table will result in one and only one
  	-- date match for a course offering pattern in an admission period for a
  	-- specified admission category and system admission process type.
  DECLARE
  	CURSOR c_apcood IS
  		SELECT 	'x'
  		FROM 	IGS_AD_PECRS_OFOP_DT
  		WHERE	adm_cal_type = p_adm_cal_type AND
  			adm_ci_sequence_number = p_adm_ci_sequence_number AND
  			admission_cat = p_admission_cat AND
  			dt_alias = p_dt_alias AND
  			(dai_sequence_number	<> p_dai_sequence_number OR
  			sequence_number		<> p_apcood_sequence_number);
  	CURSOR c_apcood2 IS
  		SELECT 	'x'
  		FROM 	IGS_AD_PECRS_OFOP_DT
  		WHERE 	adm_cal_type 		= p_adm_cal_type AND
  			adm_ci_sequence_number 	= p_adm_ci_sequence_number AND
  			admission_cat 		= p_admission_cat AND
  			dt_alias 			= p_dt_alias AND
  			(sequence_number		<> p_apcood_sequence_number) AND
  			NVL(s_admission_process_type, 'NULL')
  				= NVL(p_s_admission_process_type, 'NULL') AND
  			NVL(course_cd, 'NULL') 			= NVL(p_course_cd, 'NULL') AND
  			NVL(version_number, 0) 			= NVL(p_version_number, 0) AND
  			NVL(acad_cal_type, 'NULL') 		= NVL(p_acad_cal_type, 'NULL') AND
  			NVL(location_cd, 'NULL') 		= NVL(p_location_cd, 'NULL') AND
  			NVL(attendance_mode, 'NULL') 		= NVL(p_attendance_mode, 'NULL') AND
  			NVL(attendance_type, 'NULL') 		= NVL(p_attendance_type, 'NULL');
  	CURSOR c_apcood_rec (
  		cp_field_name				VARCHAR2)IS
  		SELECT 	s_admission_process_type,
  			course_cd,
  			version_number,
  			acad_cal_type,
  			location_cd,
  			attendance_mode,
  			attendance_type
  		FROM 	IGS_AD_PECRS_OFOP_DT
  		WHERE 	adm_cal_type 	= p_adm_cal_type AND
  			adm_ci_sequence_number = p_adm_ci_sequence_number AND
  			admission_cat = p_admission_cat AND
  			dt_alias = p_dt_alias AND
  			(dai_sequence_number	<> p_dai_sequence_number OR
  			sequence_number		<> p_apcood_sequence_number) AND
  			DECODE(cp_field_name,
  				's_admission_process_type', S_ADMISSION_PROCESS_TYPE,
  				'course_cd', COURSE_CD,
  				'location_cd', LOCATION_CD,
  				'attendance_type', attendance_type,
  				'IGS_EN_ATD_MODE', attendance_mode, NULL) IS NULL;
  	v_apcood_exists		VARCHAR2(1);
  	v_field_name		VARCHAR2(20) := NULL;
  	v_null_ind		BOOLEAN := FALSE;
  	v_message_name		varchar2(30);
  	FUNCTION admpl_val_check_conflicts (
  		p_new_s_admission_process_type
  			IGS_AD_PECRS_OFOP_DT.s_admission_process_type%TYPE,
  		p_new_course_cd			IGS_AD_PECRS_OFOP_DT.course_cd%TYPE,
  		p_new_acad_cal_type		IGS_AD_PECRS_OFOP_DT.acad_cal_type%TYPE,
  		p_new_location_cd		IGS_AD_PECRS_OFOP_DT.location_cd%TYPE,
  		p_new_attendance_mode		IGS_AD_PECRS_OFOP_DT.attendance_mode%TYPE,
  		p_new_attendance_type		IGS_AD_PECRS_OFOP_DT.attendance_type%TYPE,
  		p_new_version_number		IGS_AD_PECRS_OFOP_DT.version_number%TYPE)
  	RETURN BOOLEAN
  	IS
  	BEGIN
  		-- IF any of the components do not match, THEN everything is OK,
  		-- continue processing
  		-- * First level conflict
  		-- A first level conflict is when a record already exists with one
  		-- of the optional components having a specific value, and the same
  		-- component in the record being validated is null
  		-- (which equates to everything).
  		-- Allowing this would result in two dates being matched.
               		 IF (p_s_admission_process_type IS NOT NULL AND
                       	 	p_new_s_admission_process_type IS NOT NULL AND
                      	 	(p_s_admission_process_type <>
  				p_new_s_admission_process_type)) OR
                    			(p_course_cd IS NOT NULL AND
                      		p_new_course_cd IS NOT NULL AND
                      		(p_course_cd <> p_new_course_cd OR
                    		  	p_version_number <> p_new_version_number OR
                    		 	p_acad_cal_type <> p_new_acad_cal_type)) OR
                    			(p_location_cd IS NOT NULL AND
                    			p_new_location_cd IS NOT NULL AND
                 		    	(p_location_cd <> p_new_location_cd)) OR
                 		 	(p_attendance_mode IS NOT NULL AND
                 		   	p_new_attendance_mode IS NOT NULL AND
                  		     	(p_attendance_mode <> p_new_attendance_mode)) OR
                 		   	(p_attendance_type IS NOT NULL AND
                  		   	p_new_attendance_type IS NOT NULL AND
                  		    	(p_attendance_type <> p_new_attendance_type)) THEN
                  		     	  -- There is no conflict, continue with next record
                  		     	 NULL;
                	 	ELSE
  		 IF  (p_s_admission_process_type IS NULL AND
  		 			p_new_s_admission_process_type IS NOT NULL) OR
  				(p_course_cd IS NULL AND
  					p_new_course_cd IS NOT NULL) OR
  				(p_location_cd IS NULL AND
  					p_new_location_cd IS NOT NULL) OR
  				(p_attendance_mode IS NULL AND
  					p_new_attendance_mode IS NOT NULL) OR
  				(p_attendance_type IS NULL AND
  					p_new_attendance_type IS NOT NULL) THEN
  			-- * Second level conflict
  			IF NOT IGS_AD_VAL_APCOOD.admp_val_apcood_lnk2(
  								p_adm_cal_type,
  								p_adm_ci_sequence_number,
  								p_acad_cal_type,
  								p_admission_cat,
  								p_dt_alias,
  								p_dai_sequence_number,
  								p_apcood_sequence_number,
  								p_s_admission_process_type,
  								p_course_cd,
  								p_version_number,
  								p_location_cd,
  								p_attendance_mode,
  								p_attendance_type,
  								p_new_s_admission_process_type,
  								p_new_course_cd,
  								p_new_version_number,
  								p_new_location_cd,
  								p_new_attendance_mode,
  								p_new_attendance_type,
  								v_message_name) THEN
  				RETURN FALSE;
  			END IF;
  		END IF;
  		END IF;
  		RETURN TRUE;
  	EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APCOOD.admp_val_check_conflicts');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  	END admpl_val_check_conflicts;
  BEGIN
  	-- Set the default message number
  	p_message_name := Null;
  	-- Check if no records already exist for the particular date alias
  	OPEN c_apcood;
  	FETCH c_apcood INTO v_apcood_exists;
  	IF c_apcood%NOTFOUND THEN
  		-- Record can be inserted, it is the first
  		CLOSE c_apcood;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_apcood;
  	-- Check if this record already exists
  	OPEN c_apcood2;
  	FETCH c_apcood2 INTO v_apcood_exists;
  	IF c_apcood2%FOUND THEN
  		-- This record already exists, do not create a duplicate
  		CLOSE c_apcood2;
  		p_message_name := 'IGS_AD_ADMPRD_DTALIAS_EXISTS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_apcood2;
  	IF p_s_admission_process_type IS NOT NULL THEN
  		FOR v_apcood_rec IN c_apcood_rec(
  						's_admission_process_type') LOOP
  			IF NOT admpl_val_check_conflicts (
  						v_apcood_rec.s_admission_process_type,
  						v_apcood_rec.course_cd,
  						v_apcood_rec.acad_cal_type,
  						v_apcood_rec.location_cd,
  						v_apcood_rec.attendance_mode,
  						v_apcood_rec.attendance_type,
  						v_apcood_rec.version_number) THEN
  				v_message_name := 'IGS_AD_ADMPRDDT_CONFLICT_SYS';
  				EXIT;
  			END IF;
  		END LOOP;
  	END IF;
  	IF v_message_name <> Null THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Check course code component
  	IF p_course_cd IS NOT NULL THEN
  		FOR v_apcood_rec IN c_apcood_rec(
  						'course_cd') LOOP
  			IF NOT admpl_val_check_conflicts (
  						v_apcood_rec.s_admission_process_type,
  						v_apcood_rec.course_cd,
  						v_apcood_rec.acad_cal_type,
  						v_apcood_rec.location_cd,
  						v_apcood_rec.attendance_mode,
  						v_apcood_rec.attendance_type,
  						v_apcood_rec.version_number) THEN
  				v_message_name := 'IGS_AD_ADMPRDDT_CONFLICT_PRGC';
  				EXIT;
  			END IF;
  		END LOOP;
  	END IF;
  	IF v_message_name <> Null THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Check location code component
  	IF p_location_cd IS NOT NULL THEN
  		FOR v_apcood_rec IN c_apcood_rec(
  						'location_cd') LOOP
  			IF NOT admpl_val_check_conflicts (
  						v_apcood_rec.s_admission_process_type,
  						v_apcood_rec.course_cd,
  						v_apcood_rec.acad_cal_type,
  						v_apcood_rec.location_cd,
  						v_apcood_rec.attendance_mode,
  						v_apcood_rec.attendance_type,
  						v_apcood_rec.version_number) THEN
  				v_message_name := 'IGS_AD_ADMPRDDT_CONFLICT_LOCD';
  				EXIT;
  			END IF;
  		END LOOP;
  	END IF;
  	IF v_message_name <> Null THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Check attendance mode component
  	IF p_attendance_mode IS NOT NULL THEN
  		FOR v_apcood_rec IN c_apcood_rec(
  						'attendance_mode') LOOP
  			IF NOT admpl_val_check_conflicts (
  						v_apcood_rec.s_admission_process_type,
  						v_apcood_rec.course_cd,
  						v_apcood_rec.acad_cal_type,
  						v_apcood_rec.location_cd,
  						v_apcood_rec.attendance_mode,
  						v_apcood_rec.attendance_type,
  						v_apcood_rec.version_number) THEN
  				v_message_name := 'IGS_AD_ADMPRDDT_CONFLICT_ATMO';
  				EXIT;
  			END IF;
  		END LOOP;
  	END IF;
  	IF v_message_name <> Null THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Check attendance type component
  	IF p_attendance_type IS NOT NULL THEN
  		FOR v_apcood_rec IN c_apcood_rec(
  						'attendance_type') LOOP
  			IF NOT admpl_val_check_conflicts (
  						v_apcood_rec.s_admission_process_type,
  						v_apcood_rec.course_cd,
  						v_apcood_rec.acad_cal_type,
  						v_apcood_rec.location_cd,
  						v_apcood_rec.attendance_mode,
  						v_apcood_rec.attendance_type,
  						v_apcood_rec.version_number) THEN
  				v_message_name := 'IGS_AD_ADMPRDDT_CONFLICT_ATTY';
  				EXIT;
  			END IF;
  		END LOOP;
  	END IF;
  	IF v_message_name <> Null THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APCOOD.admp_val_apcood_link');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_apcood_link;
  --
  -- Validate the adm period course off option date optional components.
  FUNCTION admp_val_apcood_lnk2(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_apcood_sequence_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_db_s_admission_process_type IN VARCHAR2 ,
  p_db_course_cd IN VARCHAR2 ,
  p_db_version_number IN NUMBER ,
  p_db_location_cd IN VARCHAR2 ,
  p_db_attendance_mode IN VARCHAR2 ,
  p_db_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- admp_val_apcood_lnk2
  	-- This module is called by ADMP_VAL_APCOOD_LINK which validates that
  	-- admission period date link does NOT clash with existing admission
  	-- period date links. This module validates a ?second level conflict?.
  	-- It checks for the existence of  a record with the combination of
  	-- components of the record being validated, AND an existing record
  	-- that has been identified as having a potential conflict. If the
  	-- combination record exists, then there is no conflict AND the record
  	-- can be inserted, updated or deleted.
  	-- Second level conflict
  	-- A second level conflict is when a first level conflict is encountered
  	-- AND a record does NOT already exist to compensate for the first level
  	-- conflict. This is determined by combining the specified components of
  	-- the record being validated AND the record found with a first level
  	-- conflict, AND checking for the existence of a record with this combination.
  DECLARE
  	v_s_admission_process_type
  		IGS_AD_PECRS_OFOP_DT.s_admission_process_type%TYPE;
  	v_course_cd			IGS_AD_PECRS_OFOP_DT.course_cd%TYPE;
  	v_version_number		IGS_AD_PECRS_OFOP_DT.version_number%TYPE;
  	v_location_cd			IGS_AD_PECRS_OFOP_DT.location_cd%TYPE;
  	v_attendance_mode		IGS_AD_PECRS_OFOP_DT.attendance_mode	%TYPE;
  	v_attendance_type		IGS_AD_PECRS_OFOP_DT.attendance_type%TYPE;
  	CURSOR c_apcood IS
  		SELECT 	'x'
  		FROM 	IGS_AD_PECRS_OFOP_DT
  		WHERE	adm_cal_type 		= p_adm_cal_type AND
  			adm_ci_sequence_number 	= p_adm_ci_sequence_number AND
  			admission_cat 		= p_admission_cat AND
  			dt_alias 		= p_dt_alias AND
  			(dai_sequence_number <> p_dai_sequence_number OR
  			sequence_number <> p_apcood_sequence_number) AND
  			acad_cal_type 		= p_acad_cal_type AND
  			(v_s_admission_process_type IS NULL OR
  				s_admission_process_type = v_s_admission_process_type) AND
  			(v_course_cd IS NULL OR
  				course_cd = v_course_cd) AND
  			(v_version_number IS NULL OR
  				version_number = v_version_number) AND
  			(v_location_cd IS NULL OR
  				location_cd = v_location_cd) AND
  			(v_attendance_mode IS NULL OR
  				attendance_mode = v_attendance_mode) AND
  			(v_attendance_type IS NULL OR
  				attendance_type = v_attendance_type);
  	v_exit			BOOLEAN := FALSE;
  	v_apcood_exists		VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	p_message_name := Null;
  	-- Validate parameters
  	IF p_adm_cal_type IS NULL OR
  			p_adm_ci_sequence_number IS NULL OR
  			p_admission_cat IS NULL OR
  			p_dt_alias IS NULL THEN
  		p_message_name := 'IGS_AD_ADMPRD_POO_INVALID';
  		RETURN FALSE;
  	END IF;
  	-- Initialise local variables
  	v_s_admission_process_type :=
  		 NVL(p_db_s_admission_process_type, p_s_admission_process_type);
  	v_course_cd := NVL(p_db_course_cd, p_course_cd);
  	v_version_number := NVL(p_db_version_number, p_version_number);
  	v_location_cd := NVL(p_db_location_cd, p_location_cd);
  	v_attendance_mode := NVL(p_db_attendance_mode, p_attendance_mode);
  	v_attendance_type := NVL(p_db_attendance_type, p_attendance_type);
  	OPEN c_apcood;
  	FETCH c_apcood INTO v_apcood_exists;
  	IF c_apcood%NOTFOUND THEN
  		CLOSE c_apcood;
  		p_message_name := 'IGS_AD_ADMPRD_POO_CONFLICT';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_apcood;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APCOOD.admp_val_apcood_lnk2');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_apcood_lnk2;
  --
  -- Validate insert of adm period course off option date
  FUNCTION admp_val_apcood_ins(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_apcood_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	--admp_val_apcood_ins
  	--This module validates the insert of admission
  	--period course offering option date.
  DECLARE
  	v_apapc_exists		VARCHAR2(1);
  	v_apcood_exists		VARCHAR2(1);
  	v_adm_perd_dt_exists	BOOLEAN DEFAULT FALSE;
  	CURSOR c_apapc IS
  		SELECT	'X'
  		FROM	IGS_AD_PRD_AD_PRC_CA
  		WHERE	adm_cal_type		= p_adm_cal_type		AND
  			adm_ci_sequence_number	= p_adm_ci_sequence_number	AND
  			admission_cat		= p_admission_cat               AND
			closed_ind                = 'N';       --added the closed indicator for bug# 2380108 (rghosh)
  	CURSOR c_dai IS
  		SELECT	sequence_number
  		FROM 	IGS_CA_DA_INST
  		WHERE 	cal_type 		= p_adm_cal_type AND
  			ci_sequence_number 	= p_adm_ci_sequence_number AND
  			dt_alias 		= p_dt_alias;
  	CURSOR c_apcood (
  		cp_sequence_number		IGS_AD_PECRS_OFOP_DT.dai_sequence_number%TYPE) IS
  		SELECT	'x'
  		FROM 	IGS_AD_PECRS_OFOP_DT
  		WHERE 	adm_cal_type 		= p_adm_cal_type AND
  			adm_ci_sequence_number 	= p_adm_ci_sequence_number AND
  			dt_alias 		= p_dt_alias AND
  			dai_sequence_number	= cp_sequence_number AND
  			(sequence_number <> p_apcood_sequence_number);
  BEGIN
  	--Set the default message number
  	p_message_name := Null;
  	--Admission period course offering option date overrides
  	--cannot be inserted if no IGS_AD_PRD_AD_PRC_CA exists
  	OPEN c_apapc;
  	FETCH c_apapc INTO v_apapc_exists;
  	IF (c_apapc%NOTFOUND) THEN
  		CLOSE c_apapc;
  		p_message_name :='IGS_AD_ADMPRD_POODT_CANINS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_apapc;
  	-- Admission Period course offering option date override cannot
  	-- be inserted if this will NOT leave a date alias instance for
  	-- the date alias with no overrides attached.
  	FOR v_dai_rec IN c_dai LOOP
  		IF v_dai_rec.sequence_number <> NVL(p_dai_sequence_number, 0) THEN
  			OPEN c_apcood(
  					v_dai_rec.sequence_number);
  			FETCH c_apcood INTO v_apcood_exists;
  			IF c_apcood%NOTFOUND THEN
  				CLOSE c_apcood;
  				v_adm_perd_dt_exists := TRUE;
  				EXIT;
  			END IF;
  			CLOSE c_apcood;
  		END IF;
  	END LOOP;
  	IF NOT v_adm_perd_dt_exists THEN
  		p_message_name := 'IGS_AD_INVALID_OVERRIDE_DATE';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_apapc%ISOPEN THEN
  			CLOSE c_apapc;
  		END IF;
  		IF c_dai%ISOPEN THEN
  			CLOSE c_dai;
  		END IF;
  		IF c_apcood%ISOPEN THEN
  			CLOSE c_apcood;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_VAL_APCOOD.admp_val_apcood_ins');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_val_apcood_ins;
  --
  -- Validate the adm period course off option date date alias
  FUNCTION admp_val_apcood_da(
  p_dt_alias IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- admp_val_apcood_da
  	-- This module validates the date alias is allowed for the admission
  	-- period date restriction.
  DECLARE
  	CURSOR c_sacc IS
  		SELECT	adm_appl_offer_resp_dt_alias,
  			adm_appl_due_dt_alias,
  			adm_appl_final_dt_alias
  		FROM	IGS_AD_CAL_CONF
  		WHERE	s_control_num = 1;
  	v_sacc_rec	c_sacc%ROWTYPE;
  BEGIN
  	-- Set the default message number
  	p_message_name := Null;
  	-- The admission period date restrictions table only applies to selected dates
  	-- as defined in the system admission calendar configuration table.
  	OPEN c_sacc;
  	FETCH c_sacc INTO v_sacc_rec;
  	IF c_sacc%NOTFOUND THEN
  		CLOSE c_sacc;
  		p_message_name :='IGS_AD_SYSCAL_CONFIG_NOT_DTMN';
  		RETURN FALSE;
  	ELSIF (v_sacc_rec.adm_appl_offer_resp_dt_alias		<> p_dt_alias	AND
  			v_sacc_rec.adm_appl_due_dt_alias	<> p_dt_alias	AND
  			v_sacc_rec.adm_appl_final_dt_alias	<> p_dt_alias)	THEN
  		CLOSE c_sacc;
  		p_message_name := 'IGS_AD_DTALIAS_ADMPRD_POO';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_sacc;
  	RETURN TRUE;
  END;

  END admp_val_apcood_da;


END IGS_AD_VAL_APCOOD;

/
