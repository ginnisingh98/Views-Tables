--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_SCHO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_SCHO" AS
/* $Header: IGSEN63B.pls 115.5 2002/11/29 00:06:19 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function GENP_VAL_STRT_END_DT removed.
  --                            IGS_EN_VAL_SCHO.GENP_VAL_STRT_END_DT  replaced by IGS_AD_VAL_EDTL.GENP_VAL_STRT_END_DT
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function GENP_VAL_SDTT_SESS removed.
  -------------------------------------------------------------------------------------------
  -- Validate the delete of a student course HECS option record.
  FUNCTION enrp_val_scho_trgdel(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
   BEGIN	-- enrp_val_scho_trgdel
  	-- This module validates deletion of IGS_EN_STDNTPSHECSOP in
  	-- the database trigger. This varies from the form validation in
  	-- that it allows deletion of when the student course attempt is
  	-- unconfirmed.
  DECLARE
  	cst_unconfirm		CONSTANT VARCHAR2(10) := 'UNCONFIRM';
  	CURSOR c_sca IS
  		SELECT	sca.course_attempt_status
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id = p_person_id AND
  			sca.course_cd = p_course_cd;
  	v_sca_rec		c_sca%ROWTYPE;
  	v_message_name		varchar2(30) ;
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- Cursor handling
  	OPEN c_sca;
  	FETCH c_sca INTO v_sca_rec;
  	IF c_sca%NOTFOUND THEN
  		CLOSE c_sca;
  		-- This should not occur, resolve elsewhere
  		RETURN TRUE;
  	END IF;
  	CLOSE c_sca;
  	IF v_sca_rec.course_attempt_status = cst_unconfirm THEN
  		RETURN TRUE;
  	END IF;
  	-- Validate against start date
  	IF NOT IGS_EN_VAL_SCHO.enrp_val_scho_delete(
  					p_start_dt,
  					v_message_name) THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sca%ISOPEN THEN
  			CLOSE c_sca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_scho_trgdel');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
END enrp_val_scho_trgdel;
  --
  -- To perform all validations on a scho record
  FUNCTION ENRP_VAL_SCHO_ALL(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_differential_hecs_ind IN VARCHAR2 ,
  p_diff_hecs_ind_update_who IN VARCHAR2 ,
  p_diff_hecs_ind_update_on IN DATE ,
  p_diff_hecs_ind_update_comment IN VARCHAR2 ,
  p_outside_aus_res_ind IN VARCHAR2 ,
  p_nz_citizen_ind IN VARCHAR2 ,
  p_nz_citizen_less2yr_ind IN VARCHAR2 ,
  p_nz_citizen_not_res_ind IN VARCHAR2 ,
  p_safety_net_ind IN VARCHAR2 ,
  p_tax_file_number IN NUMBER ,
  p_tax_file_number_collected_dt IN DATE ,
  p_tax_file_invalid_dt IN DATE ,
  p_tax_file_certificate_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN boolean  AS
   BEGIN	-- enrp_val_scho_all
  	-- Perform all validations associated with the addition of a
  	-- IGS_EN_STDNTPSHECSOP record. This routine is typically called by
  	-- processes which are defaulting or HECS records and need all validations
  	-- to be performed.
  	-- The routine will return a single error, being the first one encountered.
  DECLARE
  	v_message_name		varchar2(30);
  	v_return_type		VARCHAR2(1);
  	cst_error 		CONSTANT VARCHAR2(1) DEFAULT 'E';
  BEGIN
  	-- Set the default message number
  	p_message_name := null;
  	-- Validate START DATE AND END DATE.
  	IF p_end_dt IS NOT NULL THEN
  		IF IGS_AD_VAL_EDTL.GENP_VAL_STRT_END_DT(
  					p_start_dt,
  					p_end_dt,
  					v_message_name) = FALSE THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate the start/end dates against other hecs option records.
  	IF IGS_EN_VAL_SCHO.enrp_val_scho_st_end(
  				p_person_id,
  				p_course_cd,
  				p_start_dt,
  				p_end_dt,
  				v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Validate for overlapping records.
  	IF IGS_EN_VAL_SCHO.enrp_val_scho_ovrlp(
  				p_person_id,
  				p_course_cd,
  				p_start_dt,
  				p_end_dt,
  				v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Validate VISA indicators
  	IF IGS_EN_VAL_SCHO.enrp_val_scho_visa(
  				p_outside_aus_res_ind,
  				p_nz_citizen_ind,
  				p_nz_citizen_less2yr_ind,
  				p_nz_citizen_not_res_ind,
  				v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Validate the tax file number
  	IF IGS_EN_VAL_SCHO.enrp_val_scho_tfn(
  				p_person_id,
  				p_course_cd,
  				p_start_dt,
  				p_tax_file_number,
  				v_message_name,
  				v_return_type) = FALSE THEN
  		IF v_return_type = cst_error THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate the HECS payment option
  	IF IGS_EN_VAL_SCHO.enrp_val_scho_hpo(
  				p_hecs_payment_option,
  				p_outside_aus_res_ind,
  				p_nz_citizen_ind,
  				p_nz_citizen_less2yr_ind,
  				p_nz_citizen_not_res_ind,
  				p_safety_net_ind,
  				p_tax_file_number,
  				p_tax_file_number_collected_dt,
  				p_tax_file_certificate_number,
  				p_differential_hecs_ind,
  				v_message_name,
  				v_return_type) = FALSE THEN
  		IF v_return_type = cst_error THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate the tax file number
  	IF IGS_EN_VAL_SCHO.enrp_val_tfn_invalid(
  				p_tax_file_number,
  				p_tax_file_invalid_dt,
  				v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Validate the tax file certificate number
  	IF IGS_EN_VAL_SCHO.enrp_val_tfn_crtfct(
  				p_tax_file_number,
  				p_tax_file_invalid_dt,
  				p_tax_file_certificate_number,
  				v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Validate END DATE.
  	IF (p_hecs_payment_option IS NOT NULL OR
  				p_end_dt IS NOT NULL) THEN
  		IF IGS_EN_VAL_SCHO.enrp_val_scho_expire (
  				p_person_id,
  				p_course_cd,
  				p_start_dt,
  				p_end_dt,
  				p_hecs_payment_option,
  				v_message_name) = FALSE THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate the student course attempt HECS option HECS payment option,
  	-- and the course type of the course version for the student course attempt.
  	IF (p_hecs_payment_option IS NOT NULL) THEN
  		IF IGS_EN_VAL_SCHO.enrp_val_hpo_crs_typ (
  					p_person_id,
  					p_course_cd,
  					p_hecs_payment_option,
  					v_message_name,
  					v_return_type) = FALSE THEN
  			IF v_return_type = cst_error THEN
  				p_message_name := v_message_name;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	-- Validate the student course attempt HECS option HECS payment option,
  	-- and the special course type of the course version for the student
  	-- course attempt.
  	IF p_hecs_payment_option IS NOT NULL THEN
  		IF IGS_EN_VAL_SCHO.enrp_val_hpo_spc_crs (
  					p_person_id,
  					p_course_cd,
  					p_hecs_payment_option,
  					v_message_name,
  					v_return_type) = FALSE THEN
  			IF v_return_type = cst_error THEN
  				p_message_name := v_message_name;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	-- Validate the student course attempt HECS option HECS payment option,
  	-- the course type of the course version for the student course attempt,
  	-- and the person statistics citizenship code.
  	IF (p_hecs_payment_option IS NOT NULL OR
  				p_end_dt IS NOT NULL) THEN
  		IF IGS_EN_VAL_SCHO.enrp_val_hpo_crs_cic (
  					p_person_id,
  					p_course_cd,
  					p_start_dt,
  					p_end_dt,
  					p_hecs_payment_option,
  					NULL,
  					NULL,
  					NULL,
  					v_message_name,
  					v_return_type) = FALSE THEN
  			IF v_return_type = cst_error THEN
  				p_message_name := v_message_name;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	-- Validate the student course attempt HECS option HECS payment option,
  	-- and the person statistics citizenship code.
  	IF (p_hecs_payment_option IS NOT NULL OR
  				p_end_dt IS NOT NULL) THEN
  		IF IGS_EN_VAL_SCHO.enrp_val_hpo_cic (
  					p_person_id,
  					p_course_cd,
  					p_start_dt,
  					p_end_dt,
  					p_hecs_payment_option,
  					NULL,
  					NULL,
  					NULL,
  					v_message_name,
  					v_return_type) = FALSE THEN
  			IF v_return_type = cst_error THEN
  				p_message_name := v_message_name;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	-- Validate the student course attempt HECS option HECS payment option,
  	-- and the person statistics citizenship code and permanent resident code.
  	IF (p_hecs_payment_option IS NOT NULL OR
  				p_end_dt IS NOT NULL) THEN
  		IF IGS_EN_VAL_SCHO.enrp_val_hpo_cic_prc (
  					p_person_id,
  					p_course_cd,
  					p_start_dt,
  					p_end_dt,
  					p_hecs_payment_option,
  					NULL,
  					NULL,
  					NULL,
  					NULL,
  					v_message_name,
  					v_return_type) = FALSE THEN
  			IF v_return_type = cst_error THEN
  				p_message_name := v_message_name;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	-- Validate the student course attempt HECS option visa indicators,
  	-- and the person statistics citizenship code and permanent resident code.
  	IF (p_outside_aus_res_ind IS NOT NULL			OR
  			p_nz_citizen_ind IS NOT NULL		OR
  			p_nz_citizen_less2yr_ind IS NOT NULL	OR
  			p_nz_citizen_not_res_ind IS NOT NULL	OR
  			p_end_dt is NOT NULL) THEN
  		IF IGS_EN_VAL_SCHO.enrp_val_vis_cic_prc (
  					p_person_id,
  					p_course_cd,
  					p_start_dt,
  					p_end_dt,
  					p_outside_aus_res_ind,
  					p_nz_citizen_ind,
  					p_nz_citizen_less2yr_ind,
  					p_nz_citizen_not_res_ind,
  					NULL,
  					NULL,
  					NULL,
  					NULL,
  					v_message_name,
  					v_return_type) = FALSE THEN
  			IF v_return_type = cst_error THEN
  				p_message_name := v_message_name;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	-- Validate the student course attempt HECS option HECS payment option,
  	-- the student course attempt HECS option visa indicators, and the person
  	-- statistics citizenship code and permanent resident code.
  	IF (p_hecs_payment_option IS NOT NULL			OR
  			p_outside_aus_res_ind IS NOT NULL	OR
  			p_end_dt IS NOT NULL) THEN
  		IF IGS_EN_VAL_SCHO.enrp_val_ho_cic_prc (
  					p_person_id,
  					p_course_cd,
  					p_start_dt,
  					p_end_dt,
  					p_hecs_payment_option,
  					p_outside_aus_res_ind,
  					NULL,
  					NULL,
  					NULL,
  					NULL,
  					v_message_name,
  					v_return_type) = FALSE THEN
  			IF v_return_type = cst_error THEN
  				p_message_name := v_message_name;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	-- Validate the student course attempt HECS option HECS payment option,
  	-- the student course attempt HECS option visa indicators, and the person
  	-- statistics citizenship code.
  	IF (p_outside_aus_res_ind IS NOT NULL			OR
  			p_nz_citizen_ind IS NOT NULL		OR
  			p_nz_citizen_less2yr_ind IS NOT NULL	OR
  			p_nz_citizen_not_res_ind is NOT NULL	OR
  			p_end_dt is NOT NULL) THEN
  		IF IGS_EN_VAL_SCHO.enrp_val_hpo_vis_cic (
  					p_person_id,
  					p_course_cd,
  					p_start_dt,
  					p_end_dt,
  					p_hecs_payment_option,
  					p_outside_aus_res_ind,
  					p_nz_citizen_ind,
  					p_nz_citizen_less2yr_ind,
  					p_nz_citizen_not_res_ind,
  					NULL,
  					NULL,
  					NULL,
  					NULL,
  					v_message_name,
  					v_return_type) = FALSE THEN
  			IF v_return_type = cst_error THEN
  				p_message_name := v_message_name;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	-- Validate the student course attempt HECS option HECS payment option,
  	-- and the person statistics citizenship code and other person statistics
  	-- values including year of arrival and term LOCATION country and postcode.
  	IF (p_hecs_payment_option IS NOT NULL	OR
  			p_end_dt IS NOT NULL) THEN
  		IF IGS_EN_VAL_SCHO.enrp_val_hpo_cic_ps (
  					p_person_id,
  					p_course_cd,
  					p_start_dt,
  					p_end_dt,
  					p_hecs_payment_option,
  					NULL,
  					NULL,
  					NULL,
  					NULL,
  					NULL,
  					NULL,
  					NULL,
  					v_message_name,
  					v_return_type) = FALSE THEN
  			IF v_return_type = cst_error THEN
  				p_message_name := v_message_name;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_scho_all');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END enrp_val_scho_all;
  --


  -- Validate that there are no other open ended student course hecs option
  FUNCTION ENRP_VAL_SCHO_OPEN(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
  DECLARE
   	CURSOR	gc_scho(
  			cp_person_id IGS_EN_STDNTPSHECSOP.person_id%TYPE,
  			cp_course_cd IGS_EN_STDNTPSHECSOP.course_cd%TYPE,
  			cp_start_dt IGS_EN_STDNTPSHECSOP.start_dt%TYPE) IS
  		SELECT	IGS_EN_STDNTPSHECSOP.end_dt
  		FROM	IGS_EN_STDNTPSHECSOP
  		WHERE	IGS_EN_STDNTPSHECSOP.person_id = cp_person_id AND
  			IGS_EN_STDNTPSHECSOP.course_cd = cp_course_cd AND
  			IGS_EN_STDNTPSHECSOP.start_dt <> cp_start_dt;
  BEGIN
  	-- this module validates that there are no other "open ended" scho
  	-- records for the nominated student course attempt
  	p_message_name := null;
  	FOR gc_scho_rec IN gc_scho(
  				p_person_id,
  				p_course_cd,
  				p_start_dt) LOOP
  		IF gc_scho_rec.end_dt IS NULL THEN
  			p_message_name := 'IGS_EN_OPEN_END_ALREADY_EXIST';
  			RETURN FALSE;
  		END IF;
  	END LOOP;
  	RETURN TRUE;
  	EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_scho_open');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END;
  END enrp_val_scho_open;
  --
  -- Check for overlap in a students course hecs option records
  FUNCTION enrp_val_scho_ovrlp(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
   BEGIN
  DECLARE
  	v_exit_loop 	BOOLEAN DEFAULT FALSE;
    	CURSOR c_scho IS
    		SELECT	scho.start_dt,
    			scho.end_dt
    		FROM	IGS_EN_STDNTPSHECSOP	scho
    		WHERE	scho.person_id 	= p_person_id AND
    			scho.course_cd 	= p_course_cd AND
    			scho.start_dt 	<> p_start_dt;
    BEGIN
    	-- this module validates that the IGS_EN_STDNTPSHECSOP record
    	-- being created or updated does not overlap with an existing record
    	-- for the nominated person
    	p_message_name := null;
    	FOR v_scho_rec IN c_scho LOOP
    		IF v_scho_rec.end_dt IS NOT NULL THEN
    			-- Validate the start date is not between an existing
    			-- date range.
    			IF p_start_dt BETWEEN v_scho_rec.start_dt AND v_scho_rec.end_dt THEN
    				p_message_name := 'IGS_EN_HECS_STDT_BTWN_DTRNG';
  				v_exit_loop := TRUE;
  				EXIT;
  			-- Validate the end date is not between an
  			-- existing date range.
  			ELSIF p_end_dt BETWEEN v_scho_rec.start_dt AND v_scho_rec.end_dt THEN
  				p_message_name := 'IGS_EN_HECS_ENDDT_BTWN_DTRNG';
  				v_exit_loop := TRUE;
  				EXIT;
  			-- Validate the current dates do not overlap
  			-- and entire exisitng date range.
  			ELSIF p_start_dt <= v_scho_rec.start_dt AND
  					(p_end_dt IS NULL OR
  					p_end_dt >= v_scho_rec.end_dt) THEN
  				p_message_name := 'IGS_EN_HECS_DT_OVERLAP_DTRNG';
  				v_exit_loop := TRUE;
  				EXIT;
    			END IF;
    		ELSE -- c_scho.end_dt is null
    			-- Validate the new date range does not overlap an
    			-- existing start date.
    			IF p_end_dt IS NULL OR
    				     v_scho_rec.start_dt <= p_end_dt THEN
  				p_message_name := 'IGS_EN_HECS_DT_OVERLAP_STDT';
  				v_exit_loop := TRUE;
  				EXIT;
    			END IF;
    		END IF;
    	END LOOP;
  	IF v_exit_loop THEN
  		RETURN FALSE;
  	END IF;
    	RETURN TRUE;
  END;
  EXCEPTION
    	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_scho_ovrlp');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_scho_ovrlp;
  --
  -- Validate student course HECS option start and end date.
  FUNCTION enrp_val_scho_st_end(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
  DECLARE
  	v_other_detail	 VARCHAR(255);
  	v_message_name 	 varchar2(30);
  BEGIN
  	-- this module validates the start and end date for the
  	-- nominated student course hecs option
  	p_message_name := null;
  	IF (p_end_dt IS NOT NULL) THEN
  		IF (p_end_dt < p_start_dt) THEN
  			p_message_name := 'IGS_EN_HECS_EN_DT_GE_ST_DT';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		IF (IGS_EN_VAL_SCHO.enrp_val_scho_open(
  					p_person_id,
  					p_course_cd,
  					p_start_dt,
  					v_message_name) = FALSE) THEN
  			p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_scho_st_end');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;

  END;
  END enrp_val_scho_st_end;
  --
  -- Validate student course attempt HECS payment option visa indicators.
  FUNCTION enrp_val_scho_visa(
  p_outside_aus_res_ind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_ind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_less2yrind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_not_res_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
  DECLARE

  BEGIN
  	-- This module validates the student course
  	-- attempt visa indicators, in which either
  	-- all must not be set or only one
  	-- may be set
  	p_message_name := 'IGS_EN_ONE_RES_IND';
  	IF (p_outside_aus_res_ind = 'Y' AND
  		p_nz_citizen_ind = 'N' AND
  		p_nz_citizen_less2yrind = 'N' AND
  		p_nz_citizen_not_res_ind = 'N') THEN
  			p_message_name := null;
  			return TRUE;
  	ELSIF(p_nz_citizen_ind = 'Y' AND
  		p_outside_aus_res_ind = 'N' AND
  		p_nz_citizen_less2yrind = 'N' AND
  		p_nz_citizen_not_res_ind = 'N') THEN
  			p_message_name := null;
  			return TRUE;
  	ELSIF (p_nz_citizen_less2yrind = 'Y' AND
  		p_nz_citizen_not_res_ind = 'N' AND
  		p_outside_aus_res_ind = 'N' AND
  		p_nz_citizen_ind = 'N') THEN
  			p_message_name := null;
  			return TRUE;
  	ELSIF (p_nz_citizen_not_res_ind = 'Y' AND
  		p_outside_aus_res_ind = 'N' AND
  		p_nz_citizen_ind = 'N' AND
  		p_nz_citizen_less2yrind = 'N') THEN
  			p_message_name := null;
  			return TRUE;
  	ELSIF (p_nz_citizen_not_res_ind = 'N' AND
  		p_outside_aus_res_ind = 'N' AND
  		p_nz_citizen_ind = 'N' AND
  		p_nz_citizen_less2yrind = 'N') THEN
  			p_message_name := null;
  			return TRUE;
  	END IF;
  	RETURN FALSE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_scho_visa');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END;
  END enrp_val_scho_visa;
  --
  -- Validate student course attempt HECS payment option tax file number.
  FUNCTION enrp_val_scho_tfn(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_tax_file_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN  AS
  BEGIN
            DECLARE
               v_other_detail          VARCHAR2(255);
               v_scho_unique_rec       IGS_EN_STDNTPSHECSOP%ROWTYPE;
               v_scho_same_rec         IGS_EN_STDNTPSHECSOP%ROWTYPE;
               v_count                 NUMBER;
               v_count1                NUMBER;
               v_cnt                   NUMBER;
               v_tfn_digit             NUMBER;
               v_algorithm_total       NUMBER;
  	     cst_factor		     CONSTANT	NUMBER := 11;
  	     CURSOR  c_scho_unique_rec IS
                       SELECT  *
                       FROM    IGS_EN_STDNTPSHECSOP
                       WHERE   person_id <> p_person_id AND
                               tax_file_number = p_tax_file_number;
  	     CURSOR  c_scho_same_rec IS
                       SELECT  *
                       FROM    IGS_EN_STDNTPSHECSOP
                       WHERE   person_id = p_person_id AND
  		tax_file_number is NOT NULL AND
                               tax_file_number <> p_tax_file_number;
  	     TYPE t_algorithm IS TABLE OF NUMBER NOT NULL
                               INDEX BY BINARY_INTEGER;
  	     tax_file_alg_tab t_algorithm;
  	  BEGIN
               -- This module validates the student course attempt
               -- HECS payment option tax file number.
               -- The tax file number must be unique for a person_id
               -- and the same for one person, of length 9 and must
               -- be valid according to the tax file number
               -- algorithm
               p_message_name := null;
               p_return_type := ' ';
  	     -- initialising the total
  	     v_algorithm_total := 0;
  	     -- this checks that the p_tax_file_number is entered
  	     IF (p_tax_file_number IS NULL) THEN
  		     RETURN TRUE;
  	     END IF;
               -- this checks that the tax file number
               -- is of the correct length (ie. 9)
               IF (LENGTH(p_tax_file_number) <> 9) THEN
                       p_message_name := 'IGS_EN_TFN_LENGTH_BE_9';
                       p_return_type := cst_error;
                       RETURN FALSE;
               END IF;
               -- this validates that the tax file number is unique
               -- across a person's id
               v_count  := 0;
               OPEN c_scho_unique_rec;
               LOOP
                       FETCH c_scho_unique_rec INTO v_scho_unique_rec;
                       EXIT WHEN c_scho_unique_rec%NOTFOUND;
                       v_count := v_count + 1;
               END LOOP;
               CLOSE c_scho_unique_rec;
               IF (v_count > 0) THEN
                       p_message_name := 'IGS_GE_DUPLICATE_VALUE';
                       p_return_type := cst_error;
                       RETURN FALSE;
               END IF;
               -- setting the required values for the tax file
               -- number algorithm
               tax_file_alg_tab(1) := 10;
               tax_file_alg_tab(2) := 7;
               tax_file_alg_tab(3) := 8;
               tax_file_alg_tab(4) := 4;
               tax_file_alg_tab(5) := 6;
               tax_file_alg_tab(6) := 3;
               tax_file_alg_tab(7) := 5;
               tax_file_alg_tab(8) := 2;
               tax_file_alg_tab(9) := 1;
  	     -- for each digit of the p_tax_file_number, extract it and
  	     -- apply the tax file number algorithm to the digit
               FOR v_cnt IN 1..9 LOOP
                       v_tfn_digit :=
  		SUBSTR(to_char(p_tax_file_number), v_cnt, 1);
                       v_algorithm_total :=
  		v_algorithm_total + (v_tfn_digit * tax_file_alg_tab(v_cnt));
               END LOOP;
  	     -- if the algorithm returns a number other than zero,
  	     -- then an invalid p_tax_file_number was entered
               IF (MOD(v_algorithm_total, cst_factor) <> 0) THEN
                     p_message_name := 'IGS_EN_TFN_HAS_FAILED';
  		   p_return_type := cst_error;
                     RETURN FALSE;
  	     END IF;
               -- this validates that the tax file number is the
               -- same for a person's id
               v_count1 := 0;
               OPEN c_scho_same_rec;
               LOOP
                       FETCH c_scho_same_rec INTO v_scho_same_rec;
                       EXIT WHEN c_scho_same_rec%NOTFOUND;
  	-- Eliminate the record being updated/inserted.
  	  IF	(v_scho_same_rec.course_cd = p_course_cd AND
  		 v_scho_same_rec.start_dt <> p_start_dt) OR
  		(v_scho_same_rec.course_cd <> p_course_cd) THEN
  	                     v_count1 := v_count1 + 1;
  	END IF;
               END LOOP;
               CLOSE c_scho_same_rec;
               IF (v_count1 > 0) THEN
                       p_message_name := 'IGS_EN_STUD_HAS_DIFF_TFN';
                       p_return_type := cst_warn;
                       RETURN FALSE;
               END IF;
               RETURN TRUE;
  	  EXCEPTION
               WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_scho_tfn');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  	  END;
         END enrp_val_scho_tfn;
  --
  -- To validate the HECS Payment Option for a Student course HECS option
  FUNCTION enrp_val_scho_hpo(
  p_hecs_payment_option IN VARCHAR2 ,
  p_outside_aus_res_ind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_ind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_less2yr_ind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_not_res_ind IN VARCHAR2 DEFAULT 'N',
  p_safety_net_ind IN VARCHAR2 DEFAULT 'N',
  p_tax_file_number IN NUMBER ,
  p_tax_file_number_collected_dt IN DATE ,
  p_tax_file_certificate_number IN NUMBER ,
  p_differential_hecs_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN  AS
   BEGIN	--enrp_val_scho_hpo
  	-- This module validates the student course attempt
  	-- HECS payment_option and associated fields.
  DECLARE
  	CURSOR  c_ghpo_details IS
  		SELECT  ghpo.s_hecs_payment_type
  		FROM	IGS_FI_HECS_PAY_OPTN		hpo,
  			IGS_FI_GOV_HEC_PA_OP	ghpo
  		WHERE	hpo.hecs_payment_option		= p_hecs_payment_option AND
  			ghpo.govt_hecs_payment_option	= hpo.govt_hecs_payment_option;
  	v_ghpo_rec	c_ghpo_details%ROWTYPE;
  BEGIN
  	p_message_name := null;
  	OPEN  c_ghpo_details;
  	FETCH c_ghpo_details INTO v_ghpo_rec;
  	-- exit if no HECS payment option is found
  	IF c_ghpo_details%NOTFOUND THEN
  		CLOSE c_ghpo_details;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_ghpo_details;
  	-- perform validation when the HECS payment option is
  	-- deferred
  	IF v_ghpo_rec.s_hecs_payment_type = cst_hecs_type_deferred THEN
  		-- validating the visa indicators, which
  		-- none must be set
  		IF p_outside_aus_res_ind = 'Y' OR
  				p_nz_citizen_ind = 'Y' OR
  				p_nz_citizen_less2yr_ind = 'Y' OR
  				p_nz_citizen_not_res_ind = 'Y' THEN
  			p_message_name := 'IGS_EN_VISA_IND_MUST_NOT_SET';
  			p_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  		-- validating the safety net indicator, which
  		-- must not be set
  		IF p_safety_net_ind = 'Y' THEN
  			p_message_name := 'IGS_EN_SAFET_IND_MUST_NOT_SET';
  			p_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  		-- validate the tax file number/tax file certificate
  		-- number, of which either must be set.  If the tax
  		-- file number is set, then the tax fiel collected
  		-- date must also be set
  		IF ((p_tax_file_number IS NULL OR
  				(p_tax_file_number IS NOT NULL AND
  				p_tax_file_number_collected_dt IS NULL)) AND
  				p_tax_file_certificate_number IS NULL) THEN
  			p_message_name := 'IGS_EN_TAX_FILE_NO_BE_SET';
  			p_return_type := cst_warn;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- perform validation when the HECS payment option is
  	-- up-front with discount
  	IF v_ghpo_rec.s_hecs_payment_type = cst_hecs_type_upfront_discount THEN
  		-- validating the visa indicators, which
  		-- none must be set
  		IF p_outside_aus_res_ind = 'Y' OR
  				p_nz_citizen_ind = 'Y' OR
  				p_nz_citizen_less2yr_ind = 'Y' OR
  				p_nz_citizen_not_res_ind = 'Y' THEN
  			p_message_name := 'IGS_EN_VISA_IND_NOT_BE_SET';
  			p_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  		-- validating the safety net indicator
  		IF p_safety_net_ind = 'Y' THEN
  			-- validate the tax file number/tax file certificate
  			-- number, of which either must be set.  If the tax
  			-- file number is set, then the tax fiel collected
  			-- date must also be set
  			IF ((p_tax_file_number IS NULL OR
  					(p_tax_file_number IS NOT NULL AND
  					 p_tax_file_number_collected_dt IS NULL)) AND
  					 p_tax_file_certificate_number IS NULL)   THEN
  				p_message_name := 'IGS_EN_CHK_TFN_RECORDED_DT';
  				p_return_type := cst_warn;
  				RETURN FALSE;
  			END IF;
  		ELSE -- p_safety_net_ind = 'N'
  			IF p_tax_file_number IS NOT NULL OR
  					p_tax_file_number_collected_dt IS NOT NULL OR
  					p_tax_file_certificate_number IS NOT NULL THEN
  				p_message_name := 'IGS_EN_CHK_HECS_PAY_OPTION';
  				p_return_type := cst_error;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	-- validate when HECS payment option is up-front with
  	-- no discount
  	IF v_ghpo_rec.s_hecs_payment_type = cst_hecs_type_upfront THEN
  		IF p_outside_aus_res_ind ='Y' OR
  		   p_nz_citizen_ind = 'Y' OR
  		   p_nz_citizen_less2yr_ind = 'Y' OR
  		   p_nz_citizen_not_res_ind = 'Y' THEN
  			-- a visa indicator is set
  			-- validate the safety net indicator, which must
  			-- not be set
  			IF p_safety_net_ind = 'Y' THEN
  				p_message_name := 'IGS_EN_SAFETY_NET_IND_BE_SET';
  				p_return_type := cst_error;
  				RETURN FALSE;
  			END IF;
  			-- validate the tax file number/tax file
  			-- certificate number, which none must be
  			-- set
  			IF p_tax_file_number IS NOT NULL OR
  			   p_tax_file_number_collected_dt IS NOT NULL OR
  			   p_tax_file_certificate_number IS NOT NULL THEN
  				p_message_name := 'IGS_EN_CHK_TFN_TFC';
  				p_return_type := cst_error;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	-- validate when HECS payment option is exempt
  	IF v_ghpo_rec.s_hecs_payment_type = cst_hecs_type_exempt THEN
  		-- validate the visa indicators, safety net indicator
  		-- and tax file number/tax file certificate number,
  		-- which none must be set
  		IF p_outside_aus_res_ind = 'Y' OR
  				p_nz_citizen_ind = 'Y' OR
  				p_nz_citizen_less2yr_ind = 'Y' OR
  				p_nz_citizen_not_res_ind = 'Y' OR
  				p_safety_net_ind = 'Y' OR
  				p_tax_file_number IS NOT NULL OR
  				p_tax_file_number_collected_dt IS NOT NULL OR
  				p_tax_file_certificate_number IS NOT NULL OR
  				p_differential_hecs_ind = 'Y' THEN
  			p_message_name := 'IGS_EN_CHK_DIFF_INDICATORS';
  			p_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_scho_hpo');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_scho_hpo;
  --
  -- Validate the insert of a student course HECS option record.
  FUNCTION enrp_val_scho_insert(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
  DECLARE
  	v_other_detail			VARCHAR2(255);
  	v_course_attempt_status		IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
  	CURSOR  c_attempt_status IS
  		SELECT  course_attempt_status
  		FROM	IGS_EN_STDNT_PS_ATT
  		WHERE	person_id = p_person_id AND
  			course_cd = p_course_cd;
  BEGIN
  	-- This module validates the insertion of a
  	-- IGS_EN_STDNT_PS_HECS_OPTION_V record, in which
  	-- it can't be inserted if it has a status of
  	-- completed or deleted.
  	p_message_name := null;
  	OPEN  c_attempt_status;
  	FETCH c_attempt_status INTO v_course_attempt_status;
  	-- exit successfully if a record isn't found
  	-- therefore, no validation was required
  	IF (c_attempt_status%NOTFOUND) THEN
  		CLOSE c_attempt_status;
  		p_message_name := null;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_attempt_status;
  	-- checking if the attempt_status is set
  	-- to deleted or completed
  	IF (v_course_attempt_status = cst_deleted OR
              v_course_attempt_status = cst_completed) THEN
  		p_message_name := 'IGS_EN_CANT_CREATE_HECS';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_scho_insert');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END;
  END enrp_val_scho_insert;
  --
  -- Validate the update of a student course HECS option record.
  FUNCTION enrp_val_scho_update(
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
  DECLARE

  	v_diff			NUMBER;
  BEGIN
  	-- This module validates whether a IGS_EN_STDNT_PS_HECS_OPTION_V
  	-- record may be updated.  It may only be updated if
  	-- the IGS_EN_STDNTPSHECSOP.start_dt is equal or greater
  	-- than the current date.
  	v_diff := MONTHS_BETWEEN(SYSDATE, p_start_dt);
  	-- start_dt is less than the current date
  	IF (v_diff > 0) THEN
  		p_message_name := 'IGS_EN_CANT_UPD_HECS_PAY_OPT';
  		RETURN FALSE;
  	END IF;
  	-- start_dt is greater than or equal to the
  	-- current date
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_scho_update');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END;
  END enrp_val_scho_update;
  --
  -- Validate the delete of a student course HECS option record.
  FUNCTION enrp_val_scho_delete(
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
  DECLARE

  	v_diff			NUMBER;
  BEGIN
  	-- This module validates whether a IGS_EN_STDNT_PS_HECS_OPTION_V
  	-- record may be deleted.  It may only be deleted if
  	-- the IGS_EN_STDNTPSHECSOP.start_dt is equal or greater
  	-- than the current date.
  	v_diff := MONTHS_BETWEEN(SYSDATE, p_start_dt);
  	-- start_dt is less than the current date
  	IF (v_diff > 0) THEN
  		p_message_name := 'IGS_EN_CANT_DEL_HECS_PAY_OPT';
  		RETURN FALSE;
  	END IF;
  	-- start_dt is greater than or equal to the
  	-- current date
  	p_message_name := null;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_scho_delete');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END;
  END enrp_val_scho_delete;
  --
  -- Validate HECS option, citizenship code and permanent resident.
  FUNCTION enrp_val_ho_cic_prc(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_scho_start_dt IN DATE ,
  p_scho_end_dt IN DATE ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_outside_aus_res_ind IN VARCHAR2 DEFAULT 'N',
  p_ps_start_dt IN DATE ,
  p_ps_end_dt IN DATE ,
  p_citizenship_cd IN VARCHAR2 ,
  p_perm_resident_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN  AS
   BEGIN
  DECLARE
  	v_govt_hecs_payment_option	IGS_FI_HECS_PAY_OPTN.govt_hecs_payment_option%TYPE;
  	v_govt_citizenship_cd		IGS_ST_CITIZENSHP_CD.govt_citizenship_cd%TYPE;
  	v_govt_perm_resident_cd
  		IGS_PE_PERM_RES_CD.govt_perm_resident_cd%TYPE DEFAULT NULL;
  	v_outside_aus_res_ind		IGS_EN_STDNT_PS_HECS_OPTION_V.outside_aus_res_ind%TYPE;
  	v_exit			BOOLEAN DEFAULT FALSE;
  	CURSOR c_ghpo IS
  		SELECT	govt_hecs_payment_option
  		FROM	IGS_FI_HECS_PAY_OPTN
  		WHERE	hecs_payment_option = p_hecs_payment_option AND
  			govt_hecs_payment_option IS NOT NULL;
  	CURSOR c_gcitiz IS
  		SELECT	PS.start_dt,
  			PS.end_dt,
  			CIT.govt_citizenship_cd,
  			PRCD.govt_perm_resident_cd
  		FROM	IGS_PE_STATISTICS PS,
  			IGS_ST_CITIZENSHP_CD CIT,
  			IGS_PE_PERM_RES_CD PRCD
  		WHERE	PS.person_id = p_person_id AND
  			PS.citizenship_cd = CIT.citizenship_cd AND
  			PS.perm_resident_cd = PRCD.perm_resident_cd (+)
  		ORDER BY PS.start_dt,
  			 PS.end_dt;
  	CURSOR c_gccd IS
  		SELECT	govt_citizenship_cd
  		FROM	IGS_ST_CITIZENSHP_CD
  		WHERE	citizenship_cd = p_citizenship_cd;
  	CURSOR c_gprcd IS
  		SELECT	govt_perm_resident_cd
  		FROM	IGS_PE_PERM_RES_CD
  		WHERE	perm_resident_cd = p_perm_resident_cd;
  	CURSOR c_hpo IS
  		SELECT	SCHOV.start_dt,
  			SCHOV.end_dt,
  			SCHOV.outside_aus_res_ind,
  			HPO.govt_hecs_payment_option
  		FROM	IGS_EN_STDNT_PS_HECS_OPTION_V SCHOV,
  			IGS_FI_HECS_PAY_OPTN HPO
  		WHERE	SCHOV.person_id = p_person_id AND
  			SCHOV.hecs_payment_option =
  				HPO.hecs_payment_option AND
  			HPO.govt_hecs_payment_option IS NOT NULL
  		ORDER BY SCHOV.start_dt,
  			 SCHOV.end_dt;
  	FUNCTION enrpl_chk_whether_to_validate (
  		p_p_start_dt	DATE,
  		p_p_end_dt	DATE,
  		p_db_start_dt	DATE,
  		p_db_end_dt	DATE)
  	RETURN BOOLEAN  AS
  	BEGIN
  	DECLARE

  	BEGIN
  		-- this module checks whether further validation
  		-- should be performed, depending on the values
  		-- of certain system and parameter dates
  		-- determining if a record should be validated
  		-- which will occur when the DB effective date(s)
  		-- overlap or match the parameter date(s)
  		IF (p_p_end_dt IS NULL OR
  				p_p_end_dt >= p_db_start_dt) AND
  				(p_db_end_dt IS NULL OR
  				p_p_start_dt <= p_db_end_dt) THEN
  			RETURN TRUE;
  		END IF;
  		RETURN FALSE;
  	EXCEPTION
  		WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrpl_chk_whether_to_validate');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  	END;
  	END enrpl_chk_whether_to_validate;
  	FUNCTION enrpl_do_validations (
  		p_outside_aus_res_ind		IGS_EN_STDNT_PS_HECS_OPTION_V.outside_aus_res_ind%TYPE,
  		p_govt_hecs_payment_option	IGS_FI_HECS_PAY_OPTN.govt_hecs_payment_option%TYPE,
  		p_govt_citizenship_cd		IGS_ST_CITIZENSHP_CD.govt_citizenship_cd%TYPE,
  		p_govt_perm_resident_cd		IGS_PE_PERM_RES_CD.govt_perm_resident_cd%TYPE)
  	RETURN BOOLEAN  AS
  	BEGIN
  	DECLARE
  		v_other_detail			VARCHAR2(255);
  	BEGIN
  		-- this module performs the validation that is
  		-- required, in that if the IGS_FI_GOV_HEC_PA_OP = 12
  		-- then the govt. value for the IGS_ST_CITIZENSHP_CD must be
  		-- 3 and the govt. value for the IGS_PE_PERM_RES_CD must
  		-- be 2
  		-- checking whether the IGS_FI_GOV_HEC_PA_OP = 12
  		IF p_govt_hecs_payment_option = cst_hecs_upfront AND
  				-- checking if the indicator is set
  				p_outside_aus_res_ind = 'Y' THEN
  			-- checking if the IGS_PE_GOVCITIZEN_CD = '3'
  			IF p_govt_citizenship_cd = cst_citizen_perm THEN
  				-- checking if the perm_resdient_cd = 2
  				IF NVL(p_govt_perm_resident_cd, 9) <> cst_perm_out_aust_not_crs THEN
  					RETURN FALSE;
  				END IF;
  			ELSE
  				RETURN FALSE;
  			END IF;
  		END IF;
  		RETURN TRUE;
  	EXCEPTION
  		WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrpl_do_validations');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  	END;
  	END enrpl_do_validations;
  BEGIN
  	-- This is the main module which validates the student_course_hecs_
  	-- option_v.IGS_FI_HECS_PAY_OPTN against the IGS_PE_STATISTICS.
  	-- IGS_ST_CITIZENSHP_CD and the IGS_PE_STATISTICS.IGS_PE_PERM_RES_CD.
  	p_message_name := null;
  	-- validating the input parameters
  	IF p_person_id IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- validating the input parameters
  	IF p_course_cd IS NOT NULL THEN
  		IF p_scho_start_dt IS NULL THEN
  			RETURN TRUE;
  		END IF;
  		-- retrieving the govt. value for the student_course_
  		-- hecs_option_v.IGS_FI_HECS_PAY_OPTN
  		OPEN c_ghpo;
  		FETCH c_ghpo INTO v_govt_hecs_payment_option;
  		-- exit successfully if a record isn't found
  		-- therefore, no validation is required
  		IF c_ghpo%NOTFOUND THEN
  			CLOSE c_ghpo;
  			RETURN TRUE;
  		END IF;
  		CLOSE c_ghpo;
  		-- set the below variable to the input parameter
  		v_outside_aus_res_ind := p_outside_aus_res_ind;
  		-- retrieving the govt. value for the IGS_PE_STATISTICS.
  		-- IGS_ST_CITIZENSHP_CD and the IGS_PE_STATISTICS.IGS_PE_PERM_RES_CD,
  		-- in which more than one may be found
  		FOR v_citz_record IN c_gcitiz LOOP
  			-- execute the rountine which checks whether
  			-- further validation is required.
  			-- if it returns true, perform the validation
  			IF enrpl_chk_whether_to_validate (
  							p_scho_start_dt,
  							p_scho_end_dt,
  							v_citz_record.start_dt,
  							v_citz_record.end_dt) THEN
  				-- execute the validation routine.
  				-- if it returns false, set the message number
  				-- and the return type
  				IF NOT enrpl_do_validations (
  							v_outside_aus_res_ind,
  							v_govt_hecs_payment_option,
  							v_citz_record.govt_citizenship_cd,
  							v_citz_record.govt_perm_resident_cd) THEN
  					v_exit := TRUE;
  					EXIT;
  				END IF;
  			END IF;
  		END LOOP;
  	ELSE	-- p_course_cd IS NULL
  		-- checking the input parameters
  		IF p_ps_start_dt IS NULL THEN
  			RETURN TRUE;
  		END IF;
  		-- retrieving the govt. value for the IGS_PE_STATISTICS.
  		-- IGS_ST_CITIZENSHP_CD
  		OPEN c_gccd;
  		FETCH c_gccd INTO v_govt_citizenship_cd;
  		-- exit successfully if a record isn't found
  		-- therefore, no validation is required
  		IF c_gccd%NOTFOUND THEN
  			CLOSE c_gccd;
  			RETURN TRUE;
  		END IF;
  		CLOSE c_gccd;
  		-- retrieving the govt. value for the IGS_PE_STATISTICS.
  		-- IGS_PE_PERM_RES_CD
  		OPEN c_gprcd;
  		FETCH c_gprcd INTO v_govt_perm_resident_cd;
  		CLOSE c_gprcd;
  		-- retrieving the visa indicators for the student_course_
  		-- hecs_option_v and the govt. value for the
  		-- IGS_EN_STDNT_PS_HECS_OPTION_V.IGS_FI_HECS_PAY_OPTN
  		-- in which more than one record may be found
  		FOR v_scho_record IN c_hpo LOOP
  			-- execute the rountine which checks whether
  			-- furhter validation is required.
  			-- if it returns true, perform the validation
  			IF enrpl_chk_whether_to_validate (
  							p_ps_start_dt,
  							p_ps_end_dt,
  							v_scho_record.start_dt,
  							v_scho_record.end_dt) THEN
  				-- execute the validation routine.
  				-- if it returns false, set the message number
  				-- and the return type
  				IF NOT enrpl_do_validations (
  							v_scho_record.outside_aus_res_ind,
  							v_scho_record.govt_hecs_payment_option,
  							v_govt_citizenship_cd,
  							v_govt_perm_resident_cd) THEN
  					v_exit := TRUE;
  					EXIT;
  				END IF;
  			END IF;
  		END LOOP;
  	END IF;
  	IF v_exit THEN
  		p_message_name := 'IGS_GE_INVALID_VALUE';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_ho_cic_prc');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_ho_cic_prc;
  --
  -- Validate HECS visa indicators, citizenship cd and permanent resident.
  FUNCTION enrp_val_vis_cic_prc(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_scho_start_dt IN DATE ,
  p_scho_end_dt IN DATE ,
  p_outside_aus_res_ind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_ind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_less2yr_ind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_not_res_ind IN VARCHAR2 DEFAULT 'N',
  p_ps_start_dt IN DATE ,
  p_ps_end_dt IN DATE ,
  p_citizenship_cd IN VARCHAR2 ,
  p_perm_resident_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN  AS
   BEGIN
  DECLARE
  	v_govt_citizenship_cd		IGS_ST_CITIZENSHP_CD.govt_citizenship_cd%TYPE
  					DEFAULT NULL;
  	v_govt_perm_resident_cd		IGS_PE_PERM_RES_CD.govt_perm_resident_cd%TYPE
  					DEFAULT NULL;
  	v_return_false 			BOOLEAN DEFAULT FALSE;
  	CURSOR  c_prc IS
  		SELECT  prc.govt_perm_resident_cd
  		FROM	IGS_PE_PERM_RES_CD	prc
  		WHERE	prc.perm_resident_cd = p_perm_resident_cd;
  	CURSOR  c_ps IS
  		SELECT   ps.start_dt,
  			 ps.end_dt,
  			 cic.govt_citizenship_cd,
  			 prcd.govt_perm_resident_cd
  		FROM	 IGS_PE_STATISTICS 	ps,
  			 IGS_ST_CITIZENSHP_CD 	cic,
  			 IGS_PE_PERM_RES_CD 	prcd
  		WHERE	 ps.person_id 		= p_person_id AND
  			 ps.citizenship_cd 	= cic.citizenship_cd AND
  			 ps.perm_resident_cd 	= prcd.perm_resident_cd (+)
  		ORDER BY ps.start_dt,
  			 ps.end_dt;
  	CURSOR  c_cic IS
  		SELECT  cic.govt_citizenship_cd
  		FROM	IGS_ST_CITIZENSHP_CD	cic
  		WHERE	cic.citizenship_cd = p_citizenship_cd;
  	CURSOR c_schov IS
  		SELECT  schov.start_dt,
  			schov.end_dt,
  			schov.outside_aus_res_ind,
  			schov.nz_citizen_ind,
  			schov.nz_citizen_less2yr_ind,
  			schov.nz_citizen_not_res_ind
  		FROM	IGS_EN_STDNT_PS_HECS_OPTION_V 	schov
  		WHERE	schov.person_id = p_person_id
  		ORDER BY
  			schov.start_dt,
  			schov.end_dt;
  	FUNCTION enrpl_chk_whether_to_validate (
  		p_p_start_dt	  DATE,
  		p_p_end_dt	  DATE,
  		p_db_start_dt	  DATE,
  		p_db_end_dt	  DATE)
  	RETURN BOOLEAN  AS
  	BEGIN
  	DECLARE

  	BEGIN
  		-- determining if a record should be validated
  		-- which will occur when the DB effective date(s)
  		-- overlap or match the parameter date(s)
  		IF (p_p_end_dt IS NULL OR
  				p_p_end_dt >= p_db_start_dt) AND
  				(p_db_end_dt IS NULL OR
  				p_p_start_dt <= p_db_end_dt) THEN
  			RETURN TRUE;
  		END IF;
  		-- none of the conditions were true
  		RETURN FALSE;
  	EXCEPTION
  		WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrpl_chk_whether_to_validate');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  	END;
  	END enrpl_chk_whether_to_validate;
  	FUNCTION enrpl_do_validations (
  		p_outside_aus_res_ind		IGS_EN_STDNT_PS_HECS_OPTION_V.outside_aus_res_ind%TYPE,
  		p_nz_citizen_ind		IGS_EN_STDNT_PS_HECS_OPTION_V.nz_citizen_ind%TYPE,
  		p_nz_citizen_less2yr_ind
  				IGS_EN_STDNT_PS_HECS_OPTION_V.nz_citizen_less2yr_ind%TYPE,
  		p_nz_citizen_not_res_ind
  				IGS_EN_STDNT_PS_HECS_OPTION_V.nz_citizen_not_res_ind%TYPE,
  		p_govt_citizenship_cd		IGS_ST_CITIZENSHP_CD.govt_citizenship_cd%TYPE,
  		p_govt_perm_resident_cd		IGS_PE_PERM_RES_CD.govt_perm_resident_cd%TYPE)
  	RETURN BOOLEAN  AS
  	BEGIN
  	DECLARE
  		v_other_detail			VARCHAR2(255);
  	BEGIN
  		-- checking that if the govt. value for the IGS_ST_CITIZENSHP_CD
  		-- is 1, 4, or 5, or it is 3 and the govt. value for the
  		-- IGS_PE_PERM_RES_CD is 1 or 3, then the visa indicators
  		-- must not be set
  		-- checking the IGS_PE_GOVCITIZEN_CD and IGS_PE_GOV_PER_RESCD
  		IF p_govt_citizenship_cd IN (
  					cst_citizen_aust,
  		   			cst_citizen_temp_dip,
  		   			cst_citizen_other) OR
  				(p_govt_citizenship_cd = cst_citizen_perm AND
  				NVL(p_govt_perm_resident_cd, 9) IN (
  		  					cst_perm_in_out_aust_crs,
  		  					cst_perm)) THEN
  			  -- checking the visa indicators
  		   	  IF p_outside_aus_res_ind = 'Y' OR
  			  		p_nz_citizen_ind = 'Y' OR
  			  		p_nz_citizen_less2yr_ind = 'Y' OR
  			  		p_nz_citizen_not_res_ind = 'Y' THEN
  				RETURN FALSE;
  			  END IF;
  		END IF;
  		-- return when one of the above conditions
  		-- didn't hold
  		RETURN TRUE;
  	EXCEPTION
  		WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrpl_do_validations');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  	END;
  	END enrpl_do_validations;
  BEGIN
  	-- This is the main module which validates the student_course_hecs_
  	-- option_v.IGS_FI_HECS_PAY_OPTN against the IGS_PE_STATISTICS.
  	-- IGS_ST_CITIZENSHP_CD.
  	p_message_name := null;
  	-- validating the input parameters
  	IF p_person_id IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- validating the input parameters
  	IF p_course_cd IS NOT NULL THEN
  		IF p_scho_start_dt IS NULL THEN
  			RETURN TRUE;
  		END IF;
  		-- retrieving the govt. value for the IGS_PE_STATISTICS.
  		-- IGS_ST_CITIZENSHP_CD, and the government value for the
  		-- IGS_PE_STATISTICS.IGS_PE_PERM_RES_CD, in which more
  		-- than one may be found
  		FOR v_ps_rec IN c_ps LOOP
  			-- execute the rountine which checks whether
  			-- further validation is required.
  			-- if it returns true, perform the validation
  			IF enrpl_chk_whether_to_validate (
  							p_scho_start_dt,
  							p_scho_end_dt,
  							v_ps_rec.start_dt,
  							v_ps_rec.end_dt) THEN
  				-- execute the validation routine.
  				-- if it returns false, set the message number
  				-- and the return type
  				IF NOT enrpl_do_validations (
  							p_outside_aus_res_ind,
  							p_nz_citizen_ind,
  							p_nz_citizen_less2yr_ind,
  							p_nz_citizen_not_res_ind,
  							v_ps_rec.govt_citizenship_cd,
  							v_ps_rec.govt_perm_resident_cd) THEN
  					p_message_name := 'IGS_EN_VISA_IND_BE_SET';
  					p_return_type := cst_error;
  					v_return_false := TRUE;
  					EXIT;
  				END IF;
  			END IF;
  		END LOOP;
  	ELSE	-- p_course_cd IS NULL
  		IF p_ps_start_dt IS NULL THEN
  			RETURN TRUE;
  		END IF;
  		-- retrieving the govt. value for the IGS_PE_STATISTICS.
  		-- IGS_ST_CITIZENSHP_CD
  		OPEN  c_cic;
  		FETCH c_cic INTO v_govt_citizenship_cd;
  		-- exit successfully if a record isn't found
  		-- therefore, no validation is required
  		IF c_cic%NOTFOUND THEN
  			CLOSE c_cic;
  			RETURN TRUE;
  		END IF;
  		CLOSE c_cic;
  		-- retrieving the govt. value for the IGS_PE_STATISTICS.
  		-- IGS_PE_PERM_RES_CD
  		OPEN  c_prc;
  		FETCH c_prc INTO v_govt_perm_resident_cd;
  		CLOSE c_prc;
  		-- retrieving the visa indicators for the student_course_
  		-- hecs_option_v and the govt. value for the
  		-- IGS_EN_STDNT_PS_HECS_OPTION_V.IGS_FI_HECS_PAY_OPTN
  		-- in which more than one record may be found
  		FOR v_schov_rec IN c_schov LOOP
  			-- execute the rountine which checks whether
  			-- further validation is required.
  			-- if it returns true, perform the validation
  			IF enrpl_chk_whether_to_validate (
  							p_ps_start_dt,
  							p_ps_end_dt,
  							v_schov_rec.start_dt,
  							v_schov_rec.end_dt) THEN
  				-- execute the validation routine.
  				-- if it returns false, set the message number
  				-- and the return type
  				IF NOT enrpl_do_validations (
  							v_schov_rec.outside_aus_res_ind,
  							v_schov_rec.nz_citizen_ind,
  							v_schov_rec.nz_citizen_less2yr_ind,
  							v_schov_rec.nz_citizen_not_res_ind,
  							v_govt_citizenship_cd,
  							v_govt_perm_resident_cd) THEN
  					p_message_name := 'IGS_EN_VISA_IND_BE_SET';
  					p_return_type := cst_error;
  					v_return_false := TRUE;
  					EXIT;
  				END IF;
  			END IF;
  		END LOOP;
  	END IF;
  	IF v_return_false THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_prc%ISOPEN THEN
  			CLOSE c_prc;
  		END IF;
  		IF c_ps%ISOPEN THEN
  			CLOSE c_ps;
  		END IF;
  		IF c_cic%ISOPEN THEN
  			CLOSE c_cic;
  		END IF;
  		IF c_schov%ISOPEN THEN
  			CLOSE c_schov;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_vis_cic_prc');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_vis_cic_prc;
  --
  -- Validate the HECS Payment Option against the course type.
  FUNCTION enrp_val_hpo_crs_typ(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN  AS
   BEGIN
  DECLARE
  	v_govt_hecs_payment_option	IGS_FI_HECS_PAY_OPTN.govt_hecs_payment_option%TYPE;
  	v_govt_course_type		IGS_PS_TYPE.govt_course_type%TYPE;
  	CURSOR c_ghpo IS
  		SELECT	hpo.govt_hecs_payment_option
  		FROM	IGS_FI_HECS_PAY_OPTN	hpo
  		WHERE	hpo.hecs_payment_option = p_hecs_payment_option;
  	CURSOR c_gct IS
  		SELECT	cty.govt_course_type
  		FROM	IGS_EN_STDNT_PS_ATT	sca,
  			IGS_PS_VER		crv,
  			IGS_PS_TYPE		cty
  		WHERE	sca.person_id = p_person_id AND
  			sca.course_cd = p_course_cd AND
  			crv.course_cd = sca.course_cd AND
  			crv.version_number = sca.version_number AND
  			crv.course_type = cty.course_type;
  BEGIN
  	-- This module validates the student_course_hecs_
  	-- option_v.IGS_FI_HECS_PAY_OPTN against the IGS_PS_VER.
  	-- IGS_PS_TYPE.
  	-- Validations are :
  	-- 2.If the government vaue for the
  	-- IGS_EN_STDNT_PS_HECS_OPTION_V.IGS_FI_HECS_PAY_OPTN is 26,
  	-- then the government value for the IGS_PS_VER.IGS_PS_TYPE for the
  	-- IGS_EN_STDNT_PS_HECS_OPTION_V.course_cd must be 50 (DEETYA validation 1294).
  	-- 3.If the government value for the IGS_PS_VER.IGS_PS_TYPE for the
  	-- IGS_EN_STDNT_PS_HECS_OPTION_V.course_cd is 50, then the government value for
  	-- the IGS_EN_STDNT_PS_HECS_OPTION_V.IGS_FI_HECS_PAY_OPTN then must be 22,
  	-- 23, 24, 26, 27, 30, 33, 70or 99 (DEETYA validation 1655).
  	-- set the default message number
  	p_message_name := null;
  	-- retrieving the govt. value for the student_course_
  	-- hecs_option_v.IGS_FI_HECS_PAY_OPTN
  	OPEN c_ghpo;
  	FETCH c_ghpo INTO v_govt_hecs_payment_option;
  	-- exit successfully if a record isn't found
  	-- therefore, no validation is required
  	IF c_ghpo%NOTFOUND THEN
  		CLOSE c_ghpo;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_ghpo;
  	-- retrieving the govt. value for the IGS_PS_VER.
  	-- IGS_PS_GOVT_SPL_TYPE
  	OPEN c_gct;
  	FETCH c_gct INTO v_govt_course_type;
  	-- exit successfully if a record isn't found
  	-- therefore, no validation is required
  	IF c_gct%NOTFOUND THEN
  		CLOSE c_gct;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_gct;
 -- validating non-IGS_PS_AWD course tpye
  	-- DEETYA validation 1294
  	IF v_govt_hecs_payment_option = cst_hecs_non_award_crs AND
  			v_govt_course_type <> cst_crs_non_award THEN
  		p_message_name := 'IGS_EN_CHK_GOV_VAL_26';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	-- DEETYA validation 1655
  	IF v_govt_course_type = cst_crs_non_award AND
  			v_govt_hecs_payment_option NOT IN (
  						cst_hecs_fee_paying_os,
  						cst_hecs_os_student_charge,
  						cst_hecs_fee_paying_os_spnsr,
  						cst_hecs_non_award_crs,
  						cst_hecs_employer_funded_crs,
  						cst_hecs_os_exchange_student,
  						cst_hecs_work_experience,
  						cst_hecs_non_os_spec_crs,
  						cst_hecs_os_spec_crs,
  						cst_hecs_avondale_special)THEN
  		p_message_name := 'IGS_EN_CHK_GOV_VAL_50';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	-- DETYA validation 1729
  	IF v_govt_course_type IN (
  				cst_crs_cross_inst_ug,
  				cst_crs_cross_inst_pg) AND
  			v_govt_hecs_payment_option IN (
  					cst_hecs_fee_paying_os_spnsr,
  					cst_hecs_enabling_crs,
  					cst_hecs_non_award_crs,
  					cst_hecs_employer_funded_crs,
  					cst_hecs_non_os_comm_ug_dis,
  					cst_hecs_comm_industry,
  					cst_hecs_pg_award,
  					cst_hecs_non_os_spec_crs,
  					cst_hecs_os_spec_crs,
  					cst_hecs_avondale_special) THEN
  		p_message_name := 'IGS_EN_GOVT_PRGTYPE_SPA';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	IF v_govt_hecs_payment_option = cst_hecs_fee_paying_pg AND
  			v_govt_course_type NOT IN (
  					cst_crs_higher_doctorate,
  					cst_crs_doctorate_research,
  					cst_crs_masters_research,
  					cst_crs_masters_crs_work,
  					cst_crs_postgrad,
  					cst_crs_grad_dip_pg_dip_new,
  					cst_crs_grad_dip_pg_dip_extend,
  					cst_crs_graduate,
  					cst_crs_doctorate_crs_work,
  					cst_crs_cross_inst_pg) THEN
  		p_message_name := 'IGS_EN_GOVT_HECS_PAYMENT';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	IF v_govt_hecs_payment_option = cst_hecs_non_os_fee_paying_ug AND
  			v_govt_course_type NOT IN (
  					cst_crs_bachelor_graduate,
  					cst_crs_bachelor_honours,
  					cst_crs_bachelor_pass,
  					cst_crs_assoc_degree,
  					cst_crs_adv_diploma,
  					cst_crs_diploma,
  					cst_other_award,
  					cst_crs_cross_inst_ug) THEN
  		p_message_name := 'IGS_EN_GOVTVAL_HECS_PYMNT';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	-- set the default return type
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_ghpo%ISOPEN THEN
  			CLOSE c_ghpo;
  		END IF;
  		IF c_gct%ISOPEN THEN
  			CLOSE c_gct;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_hpo_crs_typ');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_hpo_crs_typ;
  --
  -- Validate the HECS Payment Option against the special course type.
  FUNCTION enrp_val_hpo_spc_crs(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN  AS
   BEGIN
  DECLARE
  	v_govt_hecs_payment_option	IGS_FI_HECS_PAY_OPTN.govt_hecs_payment_option%TYPE;
  	v_govt_special_course_type	IGS_PS_VER.govt_special_course_type%TYPE;
  	v_institution_2239		BOOLEAN DEFAULT FALSE;
  	v_dummy				VARCHAR2(1);
  	CURSOR c_hpo IS
  		SELECT  hpo.govt_hecs_payment_option
  		FROM	IGS_FI_HECS_PAY_OPTN	hpo
  		WHERE	hpo.hecs_payment_option = p_hecs_payment_option;
  	CURSOR c_crv IS
  		SELECT  crv.govt_special_course_type
  		FROM	IGS_EN_STDNT_PS_ATT	sca,
  			IGS_PS_VER		crv
  		WHERE	sca.person_id 		= p_person_id AND
  			sca.course_cd 		= p_course_cd AND
  			crv.course_cd 		= sca.course_cd AND
  			crv.version_number 	= sca.version_number;
  	CURSOR c_ins IS
  		SELECT 	'x'
  		FROM 	IGS_OR_INSTITUTION		ins,
  			IGS_OR_INST_STAT	ist
  		WHERE  	ins.local_institution_ind 	= 'Y' AND
  			ins.govt_institution_cd 	= 2239 AND
  			ist.institution_status 		= ins.institution_status AND
  			ist.s_institution_status 	= 'ACTIVE';
  BEGIN
  	-- This module validates the student_course_hecs_
  	-- option_v.hecs_payment_option against the IGS_PS_VER.
  	-- IGS_PS_GOVT_SPL_TYPE.
  	-- Validations are :
  	-- 1.  If the government value for the
  	-- IGS_EN_STDNT_PS_HECS_OPTION_V.hecs_payment_option
  	-- is 70, then the IGS_PS_VER.govt_special_course_type for the
  	-- IGS_EN_STDNT_PS_HECS_OPTION_V.course_cd must be 15, and vice-versa, and the
  	-- IGS_OR_INSTITUTION code must be 2239 (Australian Maritime College)
  	-- (DEETYA validation 1670, 1671).
  	-- set the default message number
  	p_message_name := null;
  	-- retrieving the govt. value for the student_course_
  	-- hecs_option_v.hecs_payment_option
  	OPEN  c_hpo;
  	FETCH c_hpo INTO v_govt_hecs_payment_option;
  	-- exit successfully if a record isn't found
  	-- therefore, no validation is required
  	IF c_hpo%NOTFOUND THEN
  		CLOSE c_hpo;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_hpo;
  	-- retrieving the govt. value for the IGS_PS_VER.
  	-- IGS_PS_GOVT_SPL_TYPE
  	OPEN  c_crv;
  	FETCH c_crv INTO v_govt_special_course_type;
  	-- exit successfully if a record isn't found
  	-- therefore, no validation is required
  	IF c_crv%NOTFOUND THEN
  		CLOSE c_crv;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_crv;
  	-- retrieving the government INSTITUTION code
  	OPEN c_ins;
  	FETCH c_ins INTO v_dummy;
  	IF c_ins%FOUND THEN
  		v_institution_2239 := TRUE;
  	END IF;
  	CLOSE c_ins;
  	-- checking that if the student_course_hecs
  	-- option_v.hecs_payment_option is set to 70,
  	-- then the course_version_govt_special_course
  	-- type for the IGS_EN_STDNT_PS_HECS_OPTION_V.course_cd
  	-- must be 15, and vice-versa.
  	IF (v_govt_hecs_payment_option IN (
  				cst_hecs_non_os_spec_crs,
  				cst_hecs_os_spec_crs) AND
  			(v_govt_special_course_type <> cst_spcl_crs_amc OR
  			NOT v_institution_2239 )) OR
  			(v_govt_special_course_type = cst_spcl_crs_amc AND
  			(v_govt_hecs_payment_option NOT IN (
  				 		cst_hecs_non_os_spec_crs,
  						cst_hecs_os_spec_crs) OR
  			NOT v_institution_2239)) THEN
          	p_message_name := 'IGS_EN_CHK_GOV_VAL_71_72';
  		p_return_type := cst_error;
  		RETURN FALSE;
  	END IF;
  	-- set the default return type
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_hpo_spc_crs');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END enrp_val_hpo_spc_crs;
  --
  -- Validate HECS payment option, visa indicators and citizenship code.
  FUNCTION enrp_val_hpo_vis_cic(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_scho_start_dt IN DATE ,
  p_scho_end_dt IN DATE ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_outside_aus_res_ind IN VARCHAR2 ,
  p_nz_citizen_ind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_less2yr_ind IN VARCHAR2 DEFAULT 'N',
  p_nz_citizen_not_res_ind IN VARCHAR2 DEFAULT 'N',
  p_ps_start_dt IN DATE ,
  p_ps_end_dt IN DATE ,
  p_yr_arrival IN VARCHAR2 ,
  p_citizenship_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN  AS
   BEGIN
  DECLARE
  	v_govt_hecs_payment_option	IGS_FI_HECS_PAY_OPTN.govt_hecs_payment_option%TYPE;
  	v_govt_citizenship_cd		IGS_ST_CITIZENSHP_CD.govt_citizenship_cd%TYPE;
  	v_return_false			BOOLEAN DEFAULT FALSE;
  	CURSOR  c_hpo IS
  		SELECT  hpo.govt_hecs_payment_option
  		FROM	IGS_FI_HECS_PAY_OPTN		hpo
  		WHERE	hpo.hecs_payment_option 	= p_hecs_payment_option AND
  			hpo.govt_hecs_payment_option	IS NOT NULL;
  	CURSOR  c_ps_cic IS
  		SELECT   ps.start_dt,
  			 ps.end_dt,
  			 cic.govt_citizenship_cd,
  			 ps.yr_arrival
  		FROM	 IGS_PE_STATISTICS 	ps,
  			 IGS_ST_CITIZENSHP_CD 	cic
  		WHERE	 ps.person_id 		= p_person_id AND
  			 ps.citizenship_cd 	= cic.citizenship_cd(+)
  		ORDER BY ps.start_dt,
  			 ps.end_dt;
  	CURSOR  c_gcc IS
  		SELECT  gcc.govt_citizenship_cd
  		FROM	IGS_ST_CITIZENSHP_CD	gcc
  		WHERE	gcc.citizenship_cd 	= p_citizenship_cd;
  	CURSOR c_scho_hpo IS
  		SELECT  scho.start_dt,
  			scho.end_dt,
  			scho.outside_aus_res_ind,
  			scho.nz_citizen_ind,
  			scho.nz_citizen_less2yr_ind,
  			scho.nz_citizen_not_res_ind,
  		 	hpo.govt_hecs_payment_option
  		FROM	IGS_EN_STDNT_PS_HECS_OPTION_V 	scho,
  			IGS_FI_HECS_PAY_OPTN 		hpo
  		WHERE	scho.person_id 			= p_person_id AND
  			scho.hecs_payment_option 	= hpo.hecs_payment_option  AND
  			hpo.govt_hecs_payment_option 	IS NOT NULL
  		ORDER BY scho.start_dt,
  			 scho.end_dt;
  	FUNCTION enrpl_chk_whether_to_validate (
  		p_p_start_dt	  DATE,
  		p_p_end_dt	  DATE,
  		p_db_start_dt	  DATE,
  		p_db_end_dt	  DATE)
  	RETURN BOOLEAN
  	 AS
   	BEGIN
  	DECLARE
  	BEGIN
  		-- this module checks whether further validation
  		-- should be performed, depending on the values
  		-- of certain system and parameter dates
  		-- determining if a record should be validated
  		-- which will occur when the DB effective date(s)
  		-- overlap or match the parameter date(s)
  		IF (p_p_end_dt IS NULL OR
  				p_p_end_dt >= p_db_start_dt) AND
  				(p_db_end_dt IS NULL OR
  				p_p_start_dt <= p_db_end_dt) THEN
  			RETURN TRUE;
  		END IF;
  		-- none of the conditions were true
  		RETURN FALSE;
  	END;
  	EXCEPTION
  		WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrpl_chk_whether_to_validate');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  	END enrpl_chk_whether_to_validate;
  	FUNCTION enrpl_do_validations (
  		p_outside_aus_res_ind	IGS_EN_STDNT_PS_HECS_OPTION_V.outside_aus_res_ind%TYPE,
  		p_nz_citizen_ind	IGS_EN_STDNT_PS_HECS_OPTION_V.nz_citizen_ind%TYPE,
  		p_nz_citizen_less2yr_ind
  					IGS_EN_STDNT_PS_HECS_OPTION_V.nz_citizen_less2yr_ind%TYPE,
  		p_nz_citizen_not_res_ind
  					IGS_EN_STDNT_PS_HECS_OPTION_V.nz_citizen_not_res_ind%TYPE,
  		p_govt_hecs_payment_option
  					IGS_FI_HECS_PAY_OPTN.govt_hecs_payment_option%TYPE,
  		p_govt_citizenship_cd	IGS_ST_CITIZENSHP_CD.govt_citizenship_cd%TYPE,
  		p_yr_arrival		IGS_PE_STATISTICS.yr_arrival%TYPE)
  	RETURN BOOLEAN
  	 AS
   	BEGIN
  	DECLARE
  		v_test_year			NUMBER(6);
  	BEGIN
  		-- this module performs the validation that is
  		-- required, in that if the IGS_FI_GOV_HEC_PA_OP = 12
  		-- and if a New Zealand indicator is set, then the
  		-- government value must be '2'
  		-- checking whether the IGS_FI_GOV_HEC_PA_OP = 12
  		IF p_govt_hecs_payment_option = cst_hecs_upfront AND
  			-- checking if any New Zealand indicators are set
  		   		(p_nz_citizen_ind = 'Y' OR
  		          	p_nz_citizen_less2yr_ind = 'Y' OR
  		           	p_nz_citizen_not_res_ind = 'Y') AND
  				-- checking if the IGS_PE_GOVCITIZEN_CD = '2'
  			 	p_govt_citizenship_cd <> cst_citizen_nz THEN
  			p_message_name := 'IGS_EN_CTZ/RES_STAT_VAL_BE_2';
  			p_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  		IF  p_govt_hecs_payment_option = cst_hecs_upfront AND-- cst_hecs_upfront = 12
      				p_outside_aus_res_ind = 'N' AND
      				p_nz_citizen_ind = 'N' AND
      				p_nz_citizen_less2yr_ind = 'N' AND
      				p_nz_citizen_not_res_ind = 'N' THEN
  			IF p_govt_citizenship_cd IS NULL THEN
  				p_message_name := 'IGS_EN_STUD_PAY_UPFRONT_HECS';
  				p_return_type := cst_warn;
  				RETURN FALSE;
  			ELSIF p_govt_citizenship_cd <> 3 THEN
  				p_message_name := 'IGS_EN_STUD_PAY_UPFRONT_HECS';
  				p_return_type := cst_error;
  				RETURN FALSE;
  			ELSE
  				IF  p_yr_arrival IS NOT NULL AND
  						p_yr_arrival NOT IN (
  								cst_off_shore,		-- '00'
  								cst_no_arrival,		-- '01'
  								cst_arrival_prior_1903, -- '02'
  								cst_arrival_no_info,	-- 'A8'
  								cst_no_info_aust) THEN	-- 'A9'
  					IF TO_NUMBER(substr(IGS_GE_DATE.IGSCHAR(SYSDATE),1,4)) -
  							TO_NUMBER(p_yr_arrival) < 3 THEN
  						p_message_name := 'IGS_EN_STUD_GOVT_VAL3';
  						p_return_type := cst_warn;
  						RETURN FALSE;
  					END IF;
  					IF TO_NUMBER(p_yr_arrival) < 1996 THEN
  						p_message_name := 'IGS_EN_STUD_GOVT_VALUE';
  						p_return_type := cst_warn;
  						RETURN FALSE;
  					END IF;
  				END IF;
  			END IF;
  		END IF;
  		RETURN TRUE;
  	END;
  	EXCEPTION
  		WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrpl_do_validations');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  	END enrpl_do_validations;
  BEGIN
  	-- This is the main module which validates the student_course_hecs_
  	-- option_v.IGS_FI_HECS_PAY_OPTN against the IGS_PE_STATISTICS.
  	-- IGS_ST_CITIZENSHP_CD.
  	p_message_name := null;
  	-- validating the input parameters
  	IF p_person_id IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- validating the input parameters
  	IF p_course_cd IS NOT NULL THEN
  		IF p_scho_start_dt IS NULL THEN
  			RETURN TRUE;
  		END IF;
  		-- retrieving the govt. value for the student_course_
  		-- hecs_option_v.IGS_FI_HECS_PAY_OPTN
  		OPEN  c_hpo;
  		FETCH c_hpo INTO v_govt_hecs_payment_option;
  		-- exit successfully if a record isn't found
  		-- therefore, no validation is required
  		IF c_hpo%NOTFOUND THEN
  			CLOSE c_hpo;
  			RETURN TRUE;
  		END IF;
  		CLOSE c_hpo;
  		-- retrieving the govt. value for the IGS_PE_STATISTICS.
  		-- IGS_ST_CITIZENSHP_CD, in which more than one may be found
  		FOR v_ps_cic_rec IN c_ps_cic LOOP
  			-- execute the rountine which checks whether
  			-- further validation is required
  			-- if it returns true, perform the validation
  			IF enrpl_chk_whether_to_validate (
  						p_scho_start_dt,
  						p_scho_end_dt,
  						v_ps_cic_rec.start_dt,
  						v_ps_cic_rec.end_dt) THEN
  				-- execute the validation routine
  				-- if it returns false, set the message number
  				-- and the return type
  				IF NOT enrpl_do_validations (
  							p_outside_aus_res_ind,
  							p_nz_citizen_ind,
  							p_nz_citizen_less2yr_ind,
  							p_nz_citizen_not_res_ind,
  							v_govt_hecs_payment_option,
  							v_ps_cic_rec.govt_citizenship_cd,
  							v_ps_cic_rec.yr_arrival) THEN
  					v_return_false := TRUE;
  					EXIT;
  				END IF;
  			END IF;
  		END LOOP;
  	ELSE	-- p_course_cd IS NULL
  		-- checking the input parameters
  		IF p_ps_start_dt IS NULL THEN
  			RETURN TRUE;
  		END IF;
  		-- retrieving the govt. value for the IGS_PE_STATISTICS.
  		-- IGS_ST_CITIZENSHP_CD
  		IF p_citizenship_cd IS NOT NULL THEN
  			OPEN  c_gcc;
  			FETCH c_gcc INTO v_govt_citizenship_cd;
  			-- exit successfully if a record isn't found
  			-- therefore, no validation is required
  			IF c_gcc%NOTFOUND THEN
  				CLOSE c_gcc;
  				RETURN TRUE;
  			END IF;
  			CLOSE c_gcc;
  		ELSE
  			v_govt_citizenship_cd := NULL;
  		END IF;
  		-- retrieving the visa indicators for the student_course_
  		-- hecs_option_v and the govt. value for the
  		-- IGS_EN_STDNT_PS_HECS_OPTION_V.IGS_FI_HECS_PAY_OPTN
  		-- in which more than one record may be found
  		FOR v_scho_rec IN c_scho_hpo LOOP
  			-- execute the rountine which checks whether
  			-- furhter validation is required
  			-- if it returns true, perform the validation
  			IF enrpl_chk_whether_to_validate (
  							p_ps_start_dt,
  							p_ps_end_dt,
  							v_scho_rec.start_dt,
  							v_scho_rec.end_dt) THEN
  				-- execute the validation routine
  				-- if it returns false, set the message number
  				-- and the return type
  				IF NOT enrpl_do_validations (
  							v_scho_rec.outside_aus_res_ind,
  							v_scho_rec.nz_citizen_ind,
  							v_scho_rec.nz_citizen_less2yr_ind,
  							v_scho_rec.nz_citizen_not_res_ind,
  							v_scho_rec.govt_hecs_payment_option,
  							v_govt_citizenship_cd,
  							p_yr_arrival)  THEN
  					v_return_false := TRUE;
  					EXIT;
  				END IF;
  			END IF;
  		END LOOP;
  	END IF;
  	IF v_return_false THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_hpo%ISOPEN THEN
  			CLOSE c_hpo;
  		END IF;
  		IF c_ps_cic%ISOPEN THEN
  			CLOSE c_ps_cic;
  		END IF;
  		IF c_gcc%ISOPEN THEN
  			CLOSE c_gcc;
  		END IF;
  		IF c_scho_hpo%ISOPEN THEN
  			CLOSE c_scho_hpo;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_hpo_vis_cic');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_hpo_vis_cic;
  --
  -- Validate HECS payment option, citizenship code and permanent resident.
  FUNCTION enrp_val_hpo_cic_prc(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_scho_start_dt IN DATE ,
  p_scho_end_dt IN DATE ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_ps_start_dt IN DATE ,
  p_ps_end_dt IN DATE ,
  p_citizenship_cd IN VARCHAR2 ,
  p_perm_resident_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN  AS
   BEGIN
  DECLARE
  	v_govt_hecs_payment_option	IGS_FI_HECS_PAY_OPTN.govt_hecs_payment_option%TYPE;
  	v_govt_citizenship_cd		IGS_ST_CITIZENSHP_CD.govt_citizenship_cd%TYPE;
  	v_govt_perm_resident_cd
  		IGS_PE_PERM_RES_CD.govt_perm_resident_cd%TYPE DEFAULT NULL;
  	v_rec_found			BOOLEAN DEFAULT FALSE;
  	v_no_validation_req 		BOOLEAN DEFAULT FALSE;
  	v_scho_rec_found		BOOLEAN DEFAULT FALSE;
  	v_false_val 			BOOLEAN DEFAULT FALSE;
  	CURSOR	c_ghpo IS
  		SELECT govt_hecs_payment_option
  		FROM	IGS_FI_HECS_PAY_OPTN
  		WHERE	hecs_payment_option = p_hecs_payment_option AND
  			govt_hecs_payment_option IS NOT NULL;
  	CURSOR	c_gcitiz_rec IS
  		SELECT PS.start_dt,
  			 PS.end_dt,
  			 CIT.govt_citizenship_cd,
  			 PRCD.govt_perm_resident_cd
  		FROM	 IGS_PE_STATISTICS PS,
  			 IGS_ST_CITIZENSHP_CD CIT,
  			 IGS_PE_PERM_RES_CD PRCD
  		WHERE	 PS.person_id = p_person_id AND
  			 PS.citizenship_cd = CIT.citizenship_cd AND
  			 PS.perm_resident_cd = PRCD.perm_resident_cd (+)
  		ORDER BY PS.start_dt,
  			 PS.end_dt;
  	CURSOR 	c_gccd IS
  		SELECT	govt_citizenship_cd
  		FROM	IGS_ST_CITIZENSHP_CD
  		WHERE	citizenship_cd = p_citizenship_cd;
  	CURSOR	c_gprcd IS
  		SELECT	govt_perm_resident_cd
  		FROM	IGS_PE_PERM_RES_CD
  		WHERE	perm_resident_cd = p_perm_resident_cd;
  	CURSOR c_hpo_rec IS
  		SELECT	SCHOV.start_dt,
  			 SCHOV.end_dt,
  			 HPO.govt_hecs_payment_option
  		FROM	 IGS_EN_STDNT_PS_HECS_OPTION_V SCHOV,
  			 IGS_FI_HECS_PAY_OPTN HPO
  		WHERE	 SCHOV.person_id = p_person_id AND
  			 SCHOV.hecs_payment_option = HPO.hecs_payment_option AND
  			HPO.govt_hecs_payment_option IS NOT NULL
  		ORDER BY SCHOV.start_dt,
  			 SCHOV.end_dt;
  	FUNCTION enrpl_chk_whether_to_validate (
  		p_p_start_dt	DATE,
  		p_p_end_dt	DATE,
  		p_db_start_dt	DATE,
  		p_db_end_dt	DATE)
  	RETURN BOOLEAN  AS
  	BEGIN
  	DECLARE

  	BEGIN
  		-- this module checks whether further validation
  		-- should be performed, depending on the values
  		-- of certain system and parameter dates
  		-- determining if a record should be validated
  		-- which will occur when the DB effective date(s)
  		-- overlap or match the parameter date(s)
  		IF (p_p_end_dt IS NULL OR
  				p_p_end_dt >= p_db_start_dt) AND
  				(p_db_end_dt IS NULL OR
  				p_p_start_dt <= p_db_end_dt) THEN
  			RETURN TRUE;
  		END IF;
  		-- none of the conditions were true
  		RETURN FALSE;
  	EXCEPTION
  		WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrpl_chk_whether_to_validate');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  	END;
  	END enrpl_chk_whether_to_validate;
  	FUNCTION enrpl_do_validations (
  		p_govt_hecs_payment_option	IGS_FI_HECS_PAY_OPTN.govt_hecs_payment_option%TYPE,
  		p_govt_citizenship_cd		IGS_ST_CITIZENSHP_CD.govt_citizenship_cd%TYPE,
  		p_govt_perm_resident_cd		IGS_PE_PERM_RES_CD.govt_perm_resident_cd%TYPE,
  		p_message_name			OUT NOCOPY VARCHAR2,
  		p_return_type			OUT NOCOPY VARCHAR)
  	RETURN BOOLEAN  AS
  	BEGIN
  	DECLARE
  		v_other_detail			VARCHAR2(255);
  	BEGIN
  		-- this module performs the validation that is
  		-- required, in that if the govt. value for
  		-- the IGS_FI_HECS_PAY_OPTN = 10 or 11, then
  		-- the govt. value for the IGS_ST_CITIZENSHP_CD must be
  		-- 1 OR the govt. value for the IGS_PE_PERM_RES_CD must
  		-- be 1
  		-- OR
  		-- if the govt value for the IGS_FI_HECS_PAY_OPTN is 10,
  		-- 11, 19, 20, 25, 26, 27, 32, or 40, then the govt. value for
  		-- the IGS_ST_CITIZENSHP_CD must be 1, 2, or 3, and if it is
  		-- 3, then the govt. value for the IGS_PE_PERM_RES_CD must
  		-- be 1 or 3
  		-- checking whether the IGS_FI_GOV_HEC_PA_OP = 10 or 11
  		-- DETYA validation 1772.  Allow for values being NULL
  		IF p_govt_perm_resident_cd IN (
  					cst_perm_out_aust_not_crs,
  					cst_perm) AND
  				(p_govt_hecs_payment_option IS NULL OR
  				p_govt_hecs_payment_option <> cst_hecs_upfront) THEN
  			p_message_name := 'IGS_EN_PERM_RES_STAT_VAL_2_3';
  			p_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  		-- checking whether the IGS_FI_GOV_HEC_PA_OP = 10, 11, 19, 20, 25, 26,
  		-- 27, 32 or 40
  		-- DETYA validation 1774.  Allow for values being NULL
  		IF (p_govt_hecs_payment_option IS NOT NULL AND
  				p_govt_hecs_payment_option NOT IN (
  						cst_hecs_deferred,
  						cst_hecs_upfront_discount,
  						cst_hecs_upfront)) AND
  				(p_govt_perm_resident_cd IS NOT NULL AND
  				p_govt_perm_resident_cd <> cst_perm_no) THEN
  			p_message_name := 'IGS_EN_CHK_IF_GOV_VAL_GT_12';
  			p_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  		RETURN TRUE;
  	EXCEPTION
  		WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrpl_do_validations');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  	END;
  	END enrpl_do_validations;
  BEGIN
  	-- This is the main module which validates the student_course_hecs_
  	-- option_v.IGS_FI_HECS_PAY_OPTN against the IGS_PE_STATISTICS.
  	-- IGS_ST_CITIZENSHP_CD and the IGS_PE_STATISTICS.IGS_PE_PERM_RES_CD.
  	p_message_name := null;
  	p_return_type := NULL;
  	-- validating the input parameters
  	IF p_person_id IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- validating the input parameters
  	IF p_course_cd IS NOT NULL THEN
  		IF p_scho_start_dt IS NULL THEN
  			RETURN TRUE;
  		END IF;
  		-- retrieving the govt. value for the student_course_
  		-- hecs_option_v.IGS_FI_HECS_PAY_OPTN
  		OPEN c_ghpo;
  		FETCH c_ghpo INTO v_govt_hecs_payment_option;
  		-- exit successfully if a record isn't found
  		-- therefore, no validation is required
  		IF c_ghpo%NOTFOUND THEN
  			CLOSE c_ghpo;
  			RETURN TRUE;
  		END IF;
  		CLOSE c_ghpo;
  		-- retrieving the govt. value for the IGS_PE_STATISTICS.
  		-- IGS_ST_CITIZENSHP_CD and the IGS_PE_STATISTICS.IGS_PE_PERM_RES_CD,
  		-- in which more than one may be found
  		FOR v_citz IN c_gcitiz_rec LOOP
  			-- set that a record was found
  			v_rec_found := TRUE;
  			-- execute the rountine which checks whether
  			-- further validation is required.
  			-- if it returns true, perform the validation
  			IF enrpl_chk_whether_to_validate (
  							p_scho_start_dt,
  							p_scho_end_dt,
  							v_citz.start_dt,
  							v_citz.end_dt) THEN
  				-- execute the validation routine.
  				-- if it returns false, set the message number
  				-- and the return type
  				IF NOT enrpl_do_validations (
  							v_govt_hecs_payment_option,
  							v_citz.govt_citizenship_cd,
  							v_citz.govt_perm_resident_cd,
  							p_message_name,
  							p_return_type) THEN
  					v_false_val := TRUE;
  					EXIT;
  				END IF;
  			END IF;
  		END LOOP;
  	ELSE	-- p_course_cd IS NULL
  		-- checking the input parameters
  		IF p_ps_start_dt IS NULL THEN
  			RETURN TRUE;
  		END IF;
  		-- retrieving the govt. value for the IGS_PE_STATISTICS.
  		-- IGS_ST_CITIZENSHP_CD
  		OPEN c_gccd;
  		FETCH c_gccd INTO v_govt_citizenship_cd;
  		-- exit successfully if a record isn't found
  		-- therefore, no validation is required
  		IF c_gccd%NOTFOUND THEN
  			CLOSE c_gccd;
  			RETURN TRUE;
  		END IF;
  		CLOSE c_gccd;
  		-- retrieving the govt. value for the IGS_PE_STATISTICS.
  		-- IGS_PE_PERM_RES_CD
  		OPEN c_gprcd;
  		FETCH c_gprcd INTO v_govt_perm_resident_cd;
  		CLOSE c_gprcd;
  		-- retrieving govt. value for the
  		-- IGS_EN_STDNT_PS_HECS_OPTION_V.IGS_FI_HECS_PAY_OPTN
  		-- in which more than one record may be found
  		FOR v_scho IN c_hpo_rec LOOP
  			-- set that a record was found
  			v_scho_rec_found := TRUE;
  			-- execute the rountine which checks whether
  			-- further validation is required.
  			-- if it returns true, perform the validation
  			IF enrpl_chk_whether_to_validate (
  							p_ps_start_dt,
  							p_ps_end_dt,
  							v_scho.start_dt,
  							v_scho.end_dt) THEN
  				-- execute the validation routine.
  				-- if it returns false, set the message number
  				-- and the return type
  				IF NOT enrpl_do_validations (
  							v_scho.govt_hecs_payment_option,
  							v_govt_citizenship_cd,
  							v_govt_perm_resident_cd,
  							p_message_name,
  							p_return_type) THEN
  					v_false_val := TRUE;
  					EXIT;
  				END IF;
  			END IF;
  		END LOOP;
  	END IF;
  	-- the validation didn't return TRUE
  	IF v_false_val THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_ghpo%ISOPEN THEN
  			CLOSE c_ghpo;
  		END IF;
  		IF c_gcitiz_rec%ISOPEN THEN
  			CLOSE c_gcitiz_rec;
  		END IF;
  		IF c_gccd%ISOPEN THEN
  			CLOSE c_gccd;
  		END IF;
  		IF c_gprcd%ISOPEN THEN
  			CLOSE c_gprcd;
  		END IF;
  		IF c_hpo_rec%ISOPEN THEN
  			CLOSE c_hpo_rec;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_hpo_cic_prc;
  --
  -- Validate the HECS pay option, the course type and the citizenship cd.
  FUNCTION enrp_val_hpo_crs_cic(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_scho_start_dt IN DATE ,
  p_scho_end_dt IN DATE ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_ps_start_dt IN DATE ,
  p_ps_end_dt IN DATE ,
  p_citizenship_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN  AS
   BEGIN
  	-- validate the IGS_EN_STDNT_PS_HECS_OPTION_V.IGS_FI_HECS_PAY_OPTN against
  	-- the IGS_PS_VER.IGS_PS_TYPE and the IGS_PE_STATISTICS.citizenship_cd
  DECLARE
  	v_govt_hecs_payment_option	IGS_FI_HECS_PAY_OPTN.govt_hecs_payment_option%TYPE;
  	v_govt_course_type		IGS_PS_TYPE.govt_course_type%TYPE;
  	v_govt_citizenship_cd		IGS_ST_CITIZENSHP_CD.govt_citizenship_cd%TYPE;
  	v_validation_failed		BOOLEAN DEFAULT FALSE;
  	CURSOR c_hpo IS
  		SELECT 	hpo.govt_hecs_payment_option
  		FROM	IGS_FI_HECS_PAY_OPTN	hpo
  		WHERE	hpo.hecs_payment_option = p_hecs_payment_option;
  	CURSOR c_ct IS
  		SELECT	ct.govt_course_type
  		FROM	IGS_EN_STDNT_PS_ATT	sca,
  			IGS_PS_VER		cv,
  			IGS_PS_TYPE		ct
  		WHERE	sca.person_id		= p_person_id		AND
  			sca.course_cd		= p_course_cd		AND
  			cv.course_cd		= sca.course_cd		AND
  			cv.version_number	= sca.version_number	AND
  			cv.course_type		= ct.course_type;
  	CURSOR c_ps IS
  		SELECT	ps.start_dt,
  			ps.end_dt,
  			cc.govt_citizenship_cd
  		FROM	IGS_PE_STATISTICS	ps,
  			IGS_ST_CITIZENSHP_CD		cc
  		WHERE	ps.person_id		= p_person_id	AND
  			ps.citizenship_cd	= cc.citizenship_cd
  		ORDER BY
  			start_dt,
  			end_dt;
  	CURSOR c_scho IS
  		SELECT	scho.start_dt,
  			scho.end_dt,
  			hpo.govt_hecs_payment_option,
  			ct.govt_course_type
  		FROM	IGS_EN_STDNT_PS_HECS_OPTION_V	scho,
  			IGS_FI_HECS_PAY_OPTN		hpo,
  			IGS_EN_STDNT_PS_ATT		sca,
  			IGS_PS_VER			cv,
  			IGS_PS_TYPE			ct
  		WHERE	scho.person_id			= p_person_id			AND
  			scho.hecs_payment_option	= hpo.hecs_payment_option	AND
  			sca.person_id			= scho.person_id		AND
  			sca.course_cd			= scho.course_cd		AND
  			cv.course_cd			= sca.course_cd			AND
  			cv.version_number		= sca.version_number		AND
  			cv.course_type			= ct.course_type;
  	CURSOR	c_cic IS
  		SELECT	cic.govt_citizenship_cd
  		FROM	IGS_ST_CITIZENSHP_CD	cic
  		WHERE	cic.citizenship_cd = p_citizenship_cd;
  	FUNCTION enrpl_get_govt_values
  	RETURN BOOLEAN
  	 AS
  	BEGIN
  		-- Get the govt value for the student hecs paymt option
  		OPEN c_hpo;
  		FETCH c_hpo INTO v_govt_hecs_payment_option;
  		IF c_hpo%NOTFOUND THEN
  			CLOSE c_hpo;
  			RETURN FALSE;
  		END IF;
  		CLOSE c_hpo;
  		-- Get the govt value for IGS_PS_TYPE
  		OPEN c_ct;
  		FETCH c_ct INTO v_govt_course_type;
  		IF c_ct%NOTFOUND THEN
  			CLOSE c_ct;
  			RETURN FALSE;
  		END IF;
  		CLOSE c_ct;
  		RETURN TRUE;
  	END enrpl_get_govt_values;
  	FUNCTION enrpl_chk_dates_overlap (
  		p_para_start_dt	DATE,
  		p_para_end_dt		DATE,
  		p_dbase_start_dt	DATE,
  		p_dbase_end_dt	DATE)
  	RETURN BOOLEAN
  	 AS
  	BEGIN 	-- enrpl_chk_dates_overlap
  		-- Check if database effective date(s) overlap or match the parameter date(s)
  	DECLARE

  	BEGIN
  		IF (p_para_end_dt IS NULL OR
  				p_para_end_dt >= p_dbase_start_dt) AND
  				(p_dbase_end_dt IS NULL OR
  				p_para_start_dt <= p_dbase_end_dt) THEN
  			RETURN TRUE;
  		END IF;
  		RETURN FALSE;
  	EXCEPTION
  		WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrpl_chk_dates_overlap');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  	END;
  	END enrpl_chk_dates_overlap;
  	FUNCTION enrpl_perform_validation (
  			p_govt_hecs_payment_option	IGS_FI_HECS_PAY_OPTN.govt_hecs_payment_option%TYPE,
  			p_govt_course_type		IGS_PS_TYPE.govt_course_type%TYPE,
  			p_govt_citizenship_cd		IGS_ST_CITIZENSHP_CD.govt_citizenship_cd%TYPE,
  			p_message_name			OUT NOCOPY VARCHAR2,
  			p_return_type			OUT NOCOPY VARCHAR2)
  	RETURN BOOLEAN
  	 AS
  	BEGIN
  	DECLARE

  	BEGIN
  		p_message_name := null;
  		-- DEETYA validation 1293
  		IF p_govt_hecs_payment_option = cst_hecs_enabling_crs AND
  				(p_govt_course_type <> cst_crs_enabling OR
  				p_govt_citizenship_cd NOT IN (
  								cst_citizen_aust,
  								cst_citizen_nz,
  								cst_citizen_perm)) THEN
  			p_message_name := 'IGS_EN_CHK_GOV_VAL_25';
  			p_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  		-- DEETYA validation 1654.
  		IF p_govt_course_type = cst_crs_enabling AND
  				(p_govt_hecs_payment_option <> cst_hecs_enabling_crs OR
  				p_govt_citizenship_cd NOT IN (
  							cst_citizen_aust,
  							cst_citizen_nz,
  							cst_citizen_perm)) THEN
  			p_message_name := 'IGS_EN_PRGTYPE_STUD_PRGATT';
  			p_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  		-- DEETYA validation 1646.
  		IF p_govt_hecs_payment_option = cst_hecs_pg_award THEN
  			IF p_govt_citizenship_cd IN(
  						cst_citizen_aust,
  						cst_citizen_nz,
  						cst_citizen_perm) AND
  					p_govt_course_type NOT IN (
  								cst_crs_higher_doctorate,
  								cst_crs_doctorate_research,
  								cst_crs_masters_research,
  								cst_crs_masters_crs_work,
  								cst_crs_postgrad,
  								cst_crs_grad_dip_pg_dip_new,
  								cst_crs_grad_dip_pg_dip_extend,
  								cst_crs_bachelor_graduate,
  								cst_crs_bachelor_honours,
  								cst_crs_graduate,
  								cst_crs_doctorate_crs_work) THEN
  				p_message_name := 'IGS_EN_CHK_GOV_CTZ_1_2_3';
  				p_return_type := cst_error;
  				RETURN FALSE;
  			END IF;
  			IF p_govt_citizenship_cd IN(
  						cst_citizen_temp_dip,
  						cst_citizen_other) AND
  					p_govt_course_type NOT IN (
  							cst_crs_higher_doctorate,
  							cst_crs_doctorate_research,
  							cst_crs_masters_research) THEN
  				p_message_name := 'IGS_EN_CHK_GOV_CTZ_1_2_3';
  				p_return_type := cst_error;
  				RETURN FALSE;
  			END IF;
  		END IF;
  		-- DEETYA validation 1645.
  		IF p_govt_hecs_payment_option = cst_hecs_fee_paying_pg AND
  				(p_govt_course_type NOT IN(
  						cst_crs_higher_doctorate,
  						cst_crs_doctorate_research,
  						cst_crs_masters_research,
  						cst_crs_masters_crs_work,
  						cst_crs_postgrad,
  						cst_crs_grad_dip_pg_dip_new,
  						cst_crs_grad_dip_pg_dip_extend,
  						cst_crs_graduate,
  						cst_crs_doctorate_crs_work,
  						cst_crs_cross_inst_pg) OR
  					p_govt_citizenship_cd NOT IN (
  								cst_citizen_aust,
  								cst_citizen_nz,
  								cst_citizen_perm)) THEN
  			p_message_name := 'IGS_EN_HECS_OPTION_GOVTVAK_20';
  			p_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  		IF p_govt_hecs_payment_option = cst_hecs_non_os_fee_paying_ug THEN
  			IF p_govt_course_type NOT IN (
  						cst_crs_bachelor_graduate,
  						cst_crs_bachelor_honours,
  						cst_crs_bachelor_pass,
  						cst_crs_assoc_degree,
  						cst_crs_adv_diploma,
  						cst_crs_diploma,
  						cst_other_award,
  						cst_crs_cross_inst_ug) THEN
  				p_message_name := 'IGS_EN_HECS_OPTION_GOVT_19';
  				p_return_type := cst_error;
  				RETURN FALSE;
  			ELSE	-- course type is a valid value
  				IF p_govt_citizenship_cd NOT IN (
  							cst_citizen_aust,
  							cst_citizen_nz,
  							cst_citizen_perm) THEN
  					p_message_name := 'IGS_EN_HECS_OPTION_GOVT_19';
  					p_return_type := cst_error;
  					RETURN FALSE;
  				END IF;
  			END IF;
  		END IF;
  		RETURN TRUE;
  	EXCEPTION
  		WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrpl_perform_validation');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  	END;
  	END enrpl_perform_validation;
  BEGIN
  	p_message_name := null;
  	-- Validate input parameters
  	IF p_person_id IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	IF p_course_cd IS NOT NULL THEN
  		-- This module has been called when validating
  		-- a IGS_EN_STDNT_PS_HECS_OPTION_V record
  		IF p_scho_start_dt IS NULL THEN
  			RETURN TRUE;
  		END IF;
  		-- get govt values for student hecs paymnt option, IGS_PS_TYPE
  		IF NOT enrpl_get_govt_values THEN
  			RETURN TRUE;
  		END IF;
  		-- Get the govt value for the IGS_ST_CITIZENSHP_CD
  		FOR v_rec IN c_ps LOOP
  			-- For each record that is retrieved, only validate if the
  			-- database effective date(s) overlap or match the parameter date(s)
  			IF enrpl_chk_dates_overlap (
  						p_scho_start_dt,
  						p_scho_end_dt,
  						v_rec.start_dt,
  						v_rec.end_dt) THEN
  				-- premature exit loop if validation fails
  				IF NOT enrpl_perform_validation (
  							v_govt_hecs_payment_option,
  							v_govt_course_type,
  							v_rec.govt_citizenship_cd,
  							p_message_name,
  							p_return_type) THEN
  					v_validation_failed := TRUE;
  					EXIT;
  				END IF;
  			END IF;
  		END LOOP;
  	ELSE -- p_course_cd IS NOT NULL
  		IF p_ps_start_dt IS NULL THEN
  			RETURN TRUE;
  		END IF;
  		OPEN c_cic;
  		FETCH c_cic INTO v_govt_citizenship_cd;
  		IF c_cic%NOTFOUND THEN
  			CLOSE c_cic;
  			RETURN TRUE;
  		END IF;
  		CLOSE c_cic;
  		FOR v_govt_rec IN c_scho LOOP
  			-- For each record that is retrieved, only validate if the
  			-- database effective date(s) overlap or match the parameter date(s)
  			IF enrpl_chk_dates_overlap (
  						p_ps_start_dt,
  						p_ps_end_dt,
  						v_govt_rec.start_dt,
  						v_govt_rec.end_dt) THEN
  				-- premature exit loop if validation fails
  				IF NOT enrpl_perform_validation (
  							v_govt_rec.govt_hecs_payment_option,
  							v_govt_rec.govt_course_type,
  							v_govt_citizenship_cd,
  							p_message_name,
  							p_return_type) THEN
  					v_validation_failed := TRUE;
  					EXIT;
  				END IF;
  			END IF;
  		END LOOP;
  	END IF; -- p_course_cd IS NULL
  	-- Validation fails
  	IF v_validation_failed THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_hpo_crs_cic');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_hpo_crs_cic;
  --
  -- Validate HECS payment option and the citizenship code.
  FUNCTION enrp_val_hpo_cic(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_scho_start_dt IN DATE ,
  p_scho_end_dt IN DATE ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_ps_start_dt IN DATE ,
  p_ps_end_dt IN DATE ,
  p_citizenship_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN  AS
   	-- local function
  	FUNCTION enrpl_val_hpo_cit_cd (
  		pl_govt_hecs_payment_option	IN
  			IGS_EN_STDNT_PS_HECS_OPTION_V.hecs_payment_option%TYPE,
  		pl_govt_citizenship_cd		IN	IGS_ST_CITIZENSHP_CD.govt_citizenship_cd%TYPE,
  		p1_v_inst_3037			IN	BOOLEAN,
  		pl_message_name			OUT NOCOPY	VARCHAR2,
  		pl_return_type			OUT NOCOPY	VARCHAR2 )
  	RETURN
  		BOOLEAN
  	 AS
  	BEGIN
  		pl_message_name := null;
  		pl_return_type := NULL;
  		-- DEETYA validation 1666
  		IF pl_govt_citizenship_cd IN (
  					cst_citizen_aust,
  					cst_citizen_nz,
  					cst_citizen_perm) AND
  				pl_govt_hecs_payment_option NOT IN (
  							cst_hecs_deferred,
  							cst_hecs_upfront_discount,
  							cst_hecs_upfront,
  							cst_hecs_non_os_fee_paying_ug,
  							cst_hecs_fee_paying_pg,
  							cst_hecs_enabling_crs,
  							cst_hecs_non_award_crs,
  							cst_hecs_employer_funded_crs,
  							cst_hecs_non_os_comm_ug_dis,
  							cst_hecs_comm_industry,
  							cst_hecs_work_experience,
  							cst_hecs_pg_award,
  							cst_hecs_non_os_spec_crs,
  							cst_hecs_avondale_special) THEN
  			pl_message_name := 'IGS_EN_CHK_CTZ/RES_STAT_1_2_3';
  			pl_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  		-- DEETYA validation 1574
  		IF pl_govt_citizenship_cd IN (
  					cst_citizen_temp_dip,
  					cst_citizen_other) AND
  				pl_govt_hecs_payment_option NOT IN (
  						cst_hecs_fee_paying_os,
  						cst_hecs_os_student_charge,
  						cst_hecs_fee_paying_os_spnsr,
  						cst_hecs_os_exchange_student,
  						cst_hecs_pg_award,
  						cst_hecs_os_spec_crs,
  						cst_hecs_avondale_special) THEN
  			pl_message_name := 'IGS_EN_CHK_CTZ/RES_STAT_4_5';
  			pl_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  		-- DEETYA validation 1675
  		IF NOT p1_v_inst_3037 AND
  				pl_govt_citizenship_cd = cst_citizen_aust AND
  				pl_govt_hecs_payment_option NOT IN (
  								cst_hecs_deferred,
  								cst_hecs_upfront_discount,
  								cst_hecs_non_os_fee_paying_ug,
  								cst_hecs_fee_paying_pg,
  								cst_hecs_enabling_crs,
  								cst_hecs_non_award_crs,
  								cst_hecs_employer_funded_crs,
  								cst_hecs_non_os_comm_ug_dis,
  								cst_hecs_comm_industry,
  								cst_hecs_work_experience,
  								cst_hecs_pg_award,
  								cst_hecs_non_os_spec_crs,
  								cst_hecs_avondale_special) THEN
  			pl_message_name := 'IGS_EN_INST_NOT_3037';
  			pl_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  		-- DETYA Validation 1759
  		IF pl_govt_hecs_payment_option = cst_hecs_employer_funded_crs AND
  				pl_govt_citizenship_cd NOT IN (
  						cst_citizen_aust,
  						cst_citizen_nz,
  						cst_citizen_perm) THEN
  			pl_message_name := 'IGS_EN_HECS_PYMNT_OPTION_27';
  			pl_return_type := cst_error;
  			RETURN FALSE;
  		END IF;
  		RETURN TRUE;
  	END enrpl_val_hpo_cit_cd;
  BEGIN
  DECLARE
  	TYPE t_govt_cit_cd_details IS RECORD (
  		start_dt		IGS_PE_STATISTICS.start_dt%TYPE,
  		end_dt			IGS_PE_STATISTICS.end_dt%TYPE,
  		IGS_PE_GOVCITIZEN_CD	IGS_ST_CITIZENSHP_CD.govt_citizenship_cd%TYPE );
  	TYPE t_hpo_details IS RECORD (
  		start_dt		IGS_PE_STATISTICS.start_dt%TYPE,
  		end_dt			IGS_PE_STATISTICS.end_dt%TYPE,
  		govt_hpo		IGS_FI_HECS_PAY_OPTN.govt_hecs_payment_option%TYPE );
  	v_govt_hecs_payment_option	IGS_FI_HECS_PAY_OPTN.govt_hecs_payment_option%TYPE;
  	v_govt_citizenship_cd		IGS_ST_CITIZENSHP_CD.govt_citizenship_cd%TYPE;
  	v_cit_cd_details_rec		t_govt_cit_cd_details;
  	v_hpo_details_rec		t_hpo_details;
  	v_institution_3037		BOOLEAN DEFAULT FALSE;
  	v_exit				BOOLEAN DEFAULT FALSE;
  	CURSOR	 c_ins IS
  		SELECT 	ins.govt_institution_cd
  		FROM 	IGS_OR_INSTITUTION		ins,
  			IGS_OR_INST_STAT	ist
  		WHERE  	ins.local_institution_ind 	= 'Y' AND
  			ist.institution_status		= ins.institution_status AND
  			ist.s_institution_status 	= 'ACTIVE';
  	CURSOR	c_govt_hpo IS
  		SELECT	hpo.govt_hecs_payment_option
  		FROM	IGS_FI_HECS_PAY_OPTN	hpo
  		WHERE	hpo.hecs_payment_option 	= p_hecs_payment_option AND
  			hpo.govt_hecs_payment_option 	IS NOT NULL;
  	CURSOR	c_ps IS
  		SELECT	ps.start_dt,
  			ps.end_dt,
  			cic.govt_citizenship_cd
  		FROM	IGS_PE_STATISTICS	ps,
  			IGS_ST_CITIZENSHP_CD		cic
  		WHERE	ps.person_id 		= p_person_id AND
  			cic.citizenship_cd 	= ps.citizenship_cd
  		ORDER BY
  			ps.start_dt,
  			ps.end_dt;
  	CURSOR	c_schov IS
  		SELECT	schov.start_dt,
  			schov.end_dt,
  			hpo.govt_hecs_payment_option
  		FROM	IGS_EN_STDNT_PS_HECS_OPTION_V	schov,
  			IGS_FI_HECS_PAY_OPTN		hpo
  		WHERE	schov.person_id 		= p_person_id AND
  			schov.hecs_payment_option	= hpo.hecs_payment_option AND
  			hpo.govt_hecs_payment_option 	IS NOT NULL
  		ORDER BY
  			schov.start_dt,
  			schov.end_dt;
  	CURSOR	c_gov_details IS
  		SELECT		govt_citizenship_cd
  		FROM		IGS_ST_CITIZENSHP_CD
  		WHERE		citizenship_cd = p_citizenship_cd;
  BEGIN
  	-- This module may be called when validating a IGS_EN_STDNT_PS_HECS_OPTION_V
  	-- record or a IGS_PE_STATISTICS record.  person Id will be the only
  	-- input parameter that will be set when called from either place.  The
  	-- other input parameters will be set depending on where the module is
  	-- called from.  If course code is set, we can assume the module have been
  	-- called when validating a IGS_EN_STDNT_PS_HECS_OPTION_V record, otherwise
  	-- if it is not set, we can assume the module has been called when validating
  	-- a IGS_PE_STATISTICS record.  Because both records are effective dated,
  	-- validation from both places will need to include looping logic to match
  	-- on all records that overlap with the one being validated.  When validating
  	-- a IGS_PE_STATISTICS record, logic is required to loop through all of the
  	-- IGS_EN_STDNT_PS_HECS_OPTION_V records that may exist for the person.
  	-- Looping is required for the different course codes that may exist.
  	-- Therefor, this module validates the IGS_EN_STDNT_PS_HECS_OPTION_V.
  	-- IGS_FI_HECS_PAY_OPTN against the IGS_PE_STATISTICS.citizenship_cd.
  	-- Validations are :
  	-- 1.  If the government value for the IGS_PE_STATISTICS.citizenship_cd is
  	--  1, 2 or 3, then the government value for the
  	--  IGS_EN_STDNT_PS_HECS_OPTION_V.hecs_payment_option must be
  	-- 10, 11, 12, 19, 20, 25, 26, 27, 31, 32, 33, 40,  70 or 99
  	-- (DEETYA validation1666).
  	-- 2.  If the government value for the IGS_PE_STATISTICS.citizenship_cd is 4 or
  	--5, then the government value for the
  	--  IGS_EN_STDNT_PS_HECS_OPTION_V.hecs_payment_option must be 22, 23,
  	--  24, 26, 27, 30, 70 or 99  (DEETYA validation 1574).
  	-- 3.  If the local INSTITUTION is not 3037 (Open Learning Agency of Australia)
  	--  and the government value for the IGS_PE_STATISTICS.citizenship_cd is 1,
  	--  then the government value for the IGS_EN_STDNT_PS_HECS_OPTION_V.
  	--  IGS_FI_HECS_PAY_OPTN must be 10, 11, 19, 20, 25, 26, 27, 31, 32, 33, 40,
  	--  70
  	--  or 99 (DEETYA validation 1675).
  	--- Set the default message number
  	p_message_name := null;
  	--- Validate input parameters
  	IF p_person_id IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- retrieving the government INSTITUTION code
  	FOR v_govt_ins_cd IN c_ins LOOP
  		IF v_govt_ins_cd.govt_institution_cd = 3037 THEN
  			v_institution_3037 := TRUE;
  			EXIT;
  		END IF;
   	END LOOP;
  	--- If the course code is set, then we assume this module has been called to
  	--- validate a IGS_EN_STDNT_PS_HECS_OPTION_V record.  Otherwise we assume we are
  	--- validating a IGS_PE_STATISTICS record.
  	IF p_course_cd IS NOT NULL THEN
  		IF p_scho_start_dt IS NULL THEN
  			RETURN TRUE;
  		END IF;
  		--- Retrieve the government value for
  		--- the IGS_EN_STDNT_PS_HECS_OPTION_V.hecs_payment_option.
  		OPEN c_govt_hpo;
  		FETCH c_govt_hpo INTO v_govt_hecs_payment_option;
  		IF c_govt_hpo%NOTFOUND THEN
  			CLOSE c_govt_hpo;
  			RETURN TRUE;
  		END IF;
  		CLOSE c_govt_hpo;
  		--- Retrieve the government value for the IGS_PE_STATISTICS.citizenship_cd.
  		--- Many records may be retrieved.
  		--- For each record that is retrieved determine if it should be validated.
  		--- Validation is required if the database effective date(s) overlap or match
  		--- the parameter date(s).  Looping logic is required here.
  		FOR v_ps_rec IN c_ps LOOP
  			IF (p_scho_end_dt IS NULL OR
  					p_scho_end_dt >= v_ps_rec.start_dt) AND
  					(v_ps_rec.end_dt IS NULL OR
  					p_scho_start_dt <= v_ps_rec.end_dt) AND
  					NOT enrpl_val_hpo_cit_cd(
  							v_govt_hecs_payment_option,
  							v_ps_rec.govt_citizenship_cd,
  							v_institution_3037,
  							p_message_name,
  							p_return_type ) THEN
  				v_exit := TRUE;
  				EXIT;
  			END IF;
  		END LOOP;
  	ELSE -- p_course_cd IS NULL
  		IF p_ps_start_dt IS NULL THEN
  			RETURN TRUE;
  		END IF;
  		--- Retrieve the government value for the IGS_PE_STATISTICS.citizenship_cd
  		OPEN c_gov_details;
  		FETCH c_gov_details INTO v_govt_citizenship_cd;
  		IF c_gov_details%NOTFOUND THEN
  			CLOSE c_gov_details;
  			RETURN TRUE;
  		END IF;
  		CLOSE c_gov_details;
  		--- Retrieve the government value for the
  		--- IGS_EN_STDNT_PS_HECS_OPTION_V.hecs_payment_option.
  		--- Many records may be retrieved.
  		--- For each record that is retrieved determine IF it should be validated.
  		--- Validation is required IF the database effective date(s) overlap or
  		--- match the parameter date(s).
  		FOR v_schov_rec IN c_schov LOOP
  			IF (p_scho_end_dt IS NULL OR
  					p_scho_end_dt >= v_schov_rec.start_dt) AND
  					(v_schov_rec.end_dt IS NULL OR
  					p_scho_start_dt <= v_schov_rec.end_dt) AND
  					NOT enrpl_val_hpo_cit_cd(
  							v_schov_rec.govt_hecs_payment_option,
  							v_govt_citizenship_cd,
  							v_institution_3037,
  							p_message_name,
  							p_return_type ) THEN
  				v_exit := TRUE;
  				EXIT;
  			END IF;
  		END LOOP;
  	END IF;
  	IF v_exit THEN
  		RETURN FALSE;
  	END IF;
  	--- Return the default values
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_hpo_cic');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_hpo_cic;
  --
  -- Validate the HECS payment option closed indicator.
  FUNCTION enrp_val_hpo_closed(
  p_hecs_payment_option IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
  DECLARE
   	gv_closed_ind		IGS_FI_HECS_PAY_OPTN.closed_ind%TYPE;
  	CURSOR	gc_hecs_payment_option(
  		cp_hecs_payment_option	IGS_FI_HECS_PAY_OPTN.hecs_payment_option%TYPE) IS
  		SELECT	IGS_FI_HECS_PAY_OPTN.closed_ind
  		FROM	IGS_FI_HECS_PAY_OPTN
  		WHERE	IGS_FI_HECS_PAY_OPTN.hecs_payment_option = cp_hecs_payment_option;
  BEGIN
  	-- This module validates if IGS_FI_HECS_PAY_OPTN.hecs_payment_option
  	-- is closed
  	p_message_name := null;
  	OPEN gc_hecs_payment_option(
  			p_hecs_payment_option);
  	FETCH gc_hecs_payment_option INTO gv_closed_ind;
  	IF (gc_hecs_payment_option%FOUND) THEN
  		IF (gv_closed_ind = 'Y' ) THEN
  			CLOSE gc_hecs_payment_option;
  			p_message_name := 'IGS_EN_HECS_PAY_OPT_CLOSED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE gc_hecs_payment_option;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_hpo_closed');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END;
  END enrp_val_hpo_closed;
  --
  -- Validate HECS payment option, citizenship code and other statistics.
  FUNCTION enrp_val_hpo_cic_ps(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_scho_start_dt IN DATE ,
  p_scho_end_dt IN DATE ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_ps_start_dt IN DATE ,
  p_ps_end_dt IN DATE ,
  p_citizenship_cd IN VARCHAR2 ,
  p_yr_arrival IN VARCHAR2 ,
  p_term_location_country IN VARCHAR2 ,
  p_term_location_postcode IN NUMBER ,
  p_collection_yr IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN  AS
   BEGIN	-- ernp_val_hpo_cic_ps
  	-- validate the IGS_EN_STDNT_PS_HECS_OPTION_V.hecs_payment_option
  	-- against the IGS_PE_STATISTICS.citizenship_cd and other IGS_PE_STATISTICS
  	-- values, including IGS_PE_STATISTICS.yr_arrival and
  	-- IGS_PE_STATISTICS.term_location_[country|postcode]
  	-- The IGS_EN_STDNT_PS_ATT.commencement_dt is also used in validations.
  DECLARE
  	v_govt_hecs_payment_option	IGS_FI_HECS_PAY_OPTN.govt_hecs_payment_option%TYPE;
  	v_commencement_dt		IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE;
  	v_govt_citizenship_cd		IGS_ST_CITIZENSHP_CD.govt_citizenship_cd%TYPE;
  	v_validation_failed		BOOLEAN DEFAULT FALSE;
  	CURSOR	c_hpo IS
  		SELECT	hpo.govt_hecs_payment_option
  		FROM	IGS_FI_HECS_PAY_OPTN	hpo
  		WHERE	hpo.hecs_payment_option = p_hecs_payment_option;
  	CURSOR c_sca IS
  		SELECT 	sca.commencement_dt
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id = p_person_id	AND
  			sca.course_cd = p_course_cd;
  	CURSOR c_ps IS
  		SELECT	ps.start_dt,
  			ps.end_dt,
  			ps.yr_arrival,
  			ps.term_location_country,
  			ps.term_location_postcode,
  			cc.govt_citizenship_cd
  		FROM	IGS_PE_STATISTICS	ps,
  			IGS_ST_CITIZENSHP_CD		cc
  		WHERE	ps.person_id	= p_person_id	AND
  			ps.citizenship_cd = cc.citizenship_cd
  		ORDER BY
  			ps.start_dt,
  			ps.end_dt;
  	CURSOR c_cic IS
  		SELECT	cic.govt_citizenship_cd
  		FROM	IGS_ST_CITIZENSHP_CD	cic
  		WHERE	cic.citizenship_cd = p_citizenship_cd;
  	CURSOR c_scho IS
  		SELECT	scho.start_dt,
  			scho.end_dt,
  			hpo.govt_hecs_payment_option,
  			sca.commencement_dt
  		FROM	IGS_EN_STDNT_PS_HECS_OPTION_V	scho,
  			IGS_FI_HECS_PAY_OPTN		hpo,
  			IGS_EN_STDNT_PS_ATT		sca
  		WHERE	scho.person_id		= p_person_id AND
  			scho.hecs_payment_option = hpo.hecs_payment_option AND
  			sca.person_id		= scho.person_id AND
  			sca.course_cd		= scho.course_cd
  		ORDER BY
  			scho.start_dt,
  			scho.end_dt;
  	FUNCTION enrpl_chk_dates_overlap (
  		p_para_start_dt		DATE,
  		p_para_end_dt		DATE,
  		p_dbase_start_dt	DATE,
  		p_dbase_end_dt		DATE)
  	RETURN BOOLEAN
  	 AS
  	BEGIN	-- enrpl_chk_dates_overlap
  		-- Check if database effective date(s) overlap or match the
  		-- parameter date(s)
  	DECLARE
  		v_other_detail	VARCHAR2(255);
  	BEGIN
  		IF (p_para_end_dt IS NULL OR
  				p_para_end_dt >= p_dbase_start_dt) AND
  				(p_dbase_end_dt IS NULL OR
  				p_para_start_dt <= p_dbase_end_dt) THEN
  			RETURN TRUE;
  		END IF;
  		RETURN FALSE;
  	EXCEPTION
  		WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrpl_chk_dates_overlap');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  	END;
  	END enrpl_chk_dates_overlap;
  	FUNCTION enrpl_perform_validation (
  		lp_govt_hecs_payment_option
  				IGS_EN_STDNT_PS_HECS_OPTION_V.hecs_payment_option%TYPE,
  		lp_commencement_dt		IGS_EN_STDNT_PS_ATT.commencement_dt%TYPE,
  		lp_govt_citizenship_cd		IGS_ST_CITIZENSHP_CD.govt_citizenship_cd%TYPE,
  		lp_yr_arrival			IGS_PE_STATISTICS.yr_arrival%TYPE,
  		lp_term_location_country	IGS_PE_STATISTICS.term_location_country%TYPE,
  		lp_term_location_postcode	IGS_PE_STATISTICS.term_location_postcode%TYPE)
  	RETURN BOOLEAN
  	 AS
  		lv_other_detail			VARCHAR2(255);
  	BEGIN
  	DECLARE
  		lv_check			VARCHAR2(1);
  		lv_collection_yr		NUMBER(4);
  		lv_collection_yr_less1_str	VARCHAR2(12);
  		CURSOR c_cnc IS
  			SELECT	'x'
  			FROM	IGS_PE_COUNTRY_CD	cnc
  			WHERE	cnc.country_cd = lp_term_location_country;
  	BEGIN
  		lv_collection_yr := TO_NUMBER(substr(IGS_GE_DATE.IGSCHAR(p_collection_yr),1,4));
  		IF lp_govt_citizenship_cd = cst_citizen_nz THEN
  		IF lp_commencement_dt IS NOT NULL THEN
  			-- perform validations that are dependent on the course commencement date
  			IF lp_commencement_dt >= IGS_GE_DATE.IGSDATE('1996/01/01') THEN
  				-- DEET validation 1676
  				-- HECS payment option must not be deferred or upfront with discount
  				IF lp_govt_hecs_payment_option IN (
  								cst_hecs_deferred,
  								cst_hecs_upfront_discount) THEN
  					p_message_name := 'IGS_EN_HECS_GOV_VAL_10_11';
  					p_return_type := cst_warn;
  					RETURN FALSE;
  				END IF;
  			ELSE	-- commencement date before 1/1/96
  				IF lv_collection_yr IS NOT NULL AND
  						lp_yr_arrival IS NOT NULL AND
  						lp_yr_arrival NOT IN (
  								cst_off_shore,
  								cst_no_arrival,
  								cst_arrival_no_info,
  								cst_no_info_aust) AND
  						lv_collection_yr - lp_yr_arrival >= 3 THEN
  					IF lp_term_location_country = cst_born_os_no_info THEN
  						--Term LOCATION is S999.
  						-- DEET validation 1701
  						-- HECS payment must not be upfront(12).
  						IF lp_govt_hecs_payment_option= cst_hecs_upfront THEN
  							p_message_name := 'IGS_EN_CHK_CTZ/RES_STATUS';
  							p_return_type := cst_warn;
  							RETURN FALSE;
  						END IF;
  					ELSE
  						-- Check if term LOCATION is a country code.
  						OPEN c_cnc;
  						FETCH c_cnc INTO lv_check;
  						IF c_cnc%FOUND AND
  								-- Term LOCATION is an overseas country.
  								-- DEET validation 1701
  								-- HECS payment must not be upfront.
  								lp_govt_hecs_payment_option = cst_hecs_upfront THEN
  							CLOSE c_cnc;
  							p_message_name := 'IGS_EN_CHK_CTZ/RES_STATUS';
  							p_return_type := cst_warn;
  							RETURN FALSE;
  						END IF;
  						CLOSE c_cnc;
  					END IF;
  				END IF;
  			END IF;
  			IF p_collection_yr IS NOT NULL AND
  				lp_commencement_dt <
  					IGS_GE_DATE.IGSDATE(lv_collection_yr_less1_str) THEN
  				-- Perform validations that are dependent on the year of arrival
  				IF lp_yr_arrival IS NOT NULL AND
  						lp_yr_arrival NOT IN (
  								cst_off_shore,
  								cst_no_arrival,
  								cst_arrival_no_info,
  								cst_no_info_aust) THEN
  					IF TO_NUMBER(lp_yr_arrival) IN (
  									lv_collection_yr,
  									lv_collection_yr - 1) AND
  							-- DEET validation 1681
  							-- HECS payment option must not be deferred or
  							-- Upfront with discount
  							lp_govt_hecs_payment_option IN (
  										cst_hecs_deferred,
  										cst_hecs_upfront_discount) THEN
  						p_message_name := 'IGS_EN_CHK_GOV_VAL_CITIZEN';
  						p_return_type := cst_warn;
  						RETURN FALSE;
  					END IF;
  					IF TO_NUMBER(lp_yr_arrival) = lv_collection_yr - 2 AND
  							-- DEET validation 1682
  							-- HECS payment option would not nornally be deferred
  							-- or upfront with discount
  							lp_govt_hecs_payment_option IN (
  										cst_hecs_deferred,
  										cst_hecs_upfront_discount) THEN
  						p_message_name := 'IGS_EN_CHK_GOV_CTZ_STATUS';
  						p_return_type := cst_warn;
  						RETURN FALSE;
  					END IF;
  				END IF; -- lp_yr_arrival IS NOT NULL
  			END IF; -- p_collection_yr IS NOT NULL ...
  		END IF; -- v_commencement_dt IS NOT NULL
  		IF lp_term_location_country = cst_born_os_no_info THEN
  			-- Term LOCATION is S999
  			-- Deet validation 1683
  			-- HECS payment must not be deferred or upfront with discount
  			IF lp_govt_hecs_payment_option IN (
  							cst_hecs_deferred,
  							cst_hecs_upfront_discount) THEN
  				p_message_name := 'IGS_EN_GOVT_VAL_STATUS_2';
  				p_return_type := cst_error;
  				RETURN FALSE;
  			END IF;
  		ELSE
  			-- Check if term LOCATION is a country code
  			OPEN c_cnc;
  			FETCH c_cnc INTO lv_check;
  			IF c_cnc%FOUND THEN
  				-- Term LOCATION is an overseas country
  				-- DEET validation 1683
  				-- HECS payment option must not be deferred or upfront with discount
  				IF lp_govt_hecs_payment_option IN (
  								cst_hecs_deferred,
  								cst_hecs_upfront_discount) THEN
  					CLOSE c_cnc;
  					p_message_name := 'IGS_EN_GOVT_VAL_STATUS_2';
  					p_return_type := cst_error;
  					RETURN FALSE;
  				END IF;
  			END IF;
  			CLOSE c_cnc;
  		END IF;
  		END IF;	-- lp_govt_citizenship_cd = cst_citizen_nz
  		IF lp_govt_citizenship_cd = cst_citizen_perm THEN
  			IF lp_term_location_country = cst_born_os_no_info THEN

  				-- Warning.Payment would not normally be 10 or 11
  				IF lp_govt_hecs_payment_option IN (
  							cst_hecs_upfront_discount,
  							cst_hecs_deferred) THEN
  					p_message_name := 'IGS_EN_CHK_GOV_VAL_CTZN/RES';
  					p_return_type := cst_warn;
  					RETURN FALSE;
  				END IF;
  			ELSE
  				-- Check if term LOCATION is a country code.
  				OPEN c_cnc;
  				FETCH c_cnc INTO lv_check;
  				IF c_cnc%FOUND THEN

  					-- Warning.Payment would not normally be 10 or 11
  					IF lp_govt_hecs_payment_option IN (
  								cst_hecs_upfront_discount,
  								cst_hecs_deferred) THEN
  						CLOSE c_cnc;
  						p_message_name := 'IGS_EN_CHK_GOV_VAL_CTZN/RES';
  						p_return_type := cst_warn;
  						RETURN FALSE;
  					END IF;
  				END IF;
  				CLOSE c_cnc;
  			END IF;
  		END IF;
  		RETURN TRUE;
  	EXCEPTION
  		WHEN OTHERS THEN
  		 	IF c_cnc%ISOPEN THEN
  				CLOSE c_cnc;
  			END IF;
  			RAISE;
  	END;
  	EXCEPTION
  		WHEN OTHERS THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
			FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrpl_perform_validation');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  	END enrpl_perform_validation;
  BEGIN
  	p_message_name := null;
  	IF p_person_id IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	IF p_course_cd IS NOT NULL THEN
  		-- This module has been called when validating
  		-- a IGS_EN_STDNT_PS_HECS_OPTION_V record
  		IF p_scho_start_dt IS NULL THEN
  			RETURN TRUE;
  		END IF;
  		OPEN c_hpo;
  		FETCH c_hpo INTO v_govt_hecs_payment_option;
  		CLOSE c_hpo;
  		IF v_govt_hecs_payment_option IS NULL THEN
  			RETURN TRUE;
  		END IF;
  		OPEN c_sca;
  		FETCH c_sca INTO v_commencement_dt;
  		IF c_sca%NOTFOUND THEN
  			CLOSE c_sca;
  			RETURN TRUE;
  		END IF;
  		CLOSE c_sca;
  		FOR v_ps_rec IN c_ps LOOP
  			-- Only perform validation if dbase date overlap or match parameter dates
  			IF enrpl_chk_dates_overlap (
  						p_scho_start_dt,
  						p_scho_end_dt,
  						v_ps_rec.start_dt,
  						v_ps_rec.end_dt) THEN
  				IF NOT enrpl_perform_validation (
  							v_govt_hecs_payment_option,
  							v_commencement_dt,
  							v_ps_rec.govt_citizenship_cd,
  							v_ps_rec.yr_arrival,
  							NVL(v_ps_rec.term_location_country, 'NULL-VALUE'),
  							NVL(v_ps_rec.term_location_postcode, -1)) THEN
  					v_validation_failed := TRUE;
  					EXIT;
  				END IF;
  			END IF;
  		END LOOP;
  	ELSE -- (p_course_cd IS NULL)
  		-- This module has been called when validating
  		-- a person_statistic record
  		IF p_ps_start_dt IS NULL THEN
  			RETURN TRUE;
  		END IF;
  		OPEN c_cic;
  		FETCH c_cic INTO v_govt_citizenship_cd;
  		IF c_cic%NOTFOUND THEN
  			CLOSE c_cic;
  			RETURN TRUE;
  		END IF;
  		CLOSE c_cic;
  		FOR v_scho_rec IN c_scho LOOP
  			-- Only perform validation if dbase date overlap or match parameter dates
  			IF enrpl_chk_dates_overlap (
  						p_ps_start_dt,
  						p_ps_end_dt,
  						v_scho_rec.start_dt,
  						v_scho_rec.end_dt) THEN
  				IF NOT enrpl_perform_validation (
  							v_scho_rec.govt_hecs_payment_option,
  							v_scho_rec.commencement_dt,
  							v_govt_citizenship_cd,
  							p_yr_arrival,
  							NVL(p_term_location_country, 'NULL-VALUE'),
  							NVL(p_term_location_postcode, -1)) THEN
  					v_validation_failed := TRUE;
  					EXIT;
  				END IF;
  			END IF;
  		END LOOP;
  	END IF;
  	IF v_validation_failed THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  	 	IF c_hpo%ISOPEN THEN
  			CLOSE c_hpo;
  		END IF;
  	 	IF c_sca%ISOPEN THEN
  			CLOSE c_sca;
  		END IF;
  	 	IF c_ps%ISOPEN THEN
  			CLOSE c_ps;
  		END IF;
  	 	IF c_cic%ISOPEN THEN
  			CLOSE c_cic;
  		END IF;
  	 	IF c_scho%ISOPEN THEN
  			CLOSE c_scho;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_hpo_cic_ps');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_hpo_cic_ps;
  --
  -- Validate that scho end date is in accordance with expiry restriction.
  FUNCTION enrp_val_scho_expire(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
  BEGIN
  DECLARE
  	v_expire_aftr_acdmc_perd_ind
  		IGS_FI_HECS_PAY_OPTN.expire_aftr_acdmc_perd_ind%TYPE;
  	v_end_dt		     IGS_CA_INST.end_dt%TYPE;
  	v_cal_type		     IGS_CA_INST.cal_type%TYPE;
  	v_sequence_number	     IGS_CA_INST.sequence_number%TYPE;
  	CURSOR	c_hpo(
  			cp_hpo IGS_EN_STDNTPSHECSOP.hecs_payment_option%TYPE) IS
  		SELECT	expire_aftr_acdmc_perd_ind
  		FROM	IGS_FI_HECS_PAY_OPTN
  		WHERE	hecs_payment_option= cp_hpo;
  	CURSOR	c_cal_instance (
  			cp_cal_type IGS_CA_INST.cal_type%TYPE,
  			cp_cal_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
  		SELECT 	end_dt
  		FROM	IGS_CA_INST
  		WHERE	cal_type = cp_cal_type AND
  			sequence_number = cp_cal_sequence_number ;
  	v_other_detail	 VARCHAR(255);
  	v_message_name 	 varchar2(30);
  BEGIN
  	-- Validate the the end date is allowable according to whether the
  	-- nominated HECS payment option is an "expire before end of academic period"
  	-- option.
  	p_message_name := null;
  	OPEN c_hpo(
  		p_hecs_payment_option);
  	FETCH c_hpo INTO v_expire_aftr_acdmc_perd_ind;
  	IF(c_hpo%NOTFOUND) THEN
  		CLOSE c_hpo;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_hpo;
  	IF(v_expire_aftr_acdmc_perd_ind = 'N') THEN
  		RETURN TRUE;
  	END IF;
  	IF p_end_dt IS NULL THEN
  		p_message_name := 'IGS_EN_HECS_PYMTOP_ENDDT';
  		RETURN FALSE;
  	END IF;
  	IGS_EN_GEN_001.ENRP_CLC_SCA_ACAD(p_person_id,
  			  p_course_cd,
  			  SYSDATE,
  			  v_cal_type,
  			  v_sequence_number);
  	IF(v_cal_type = NULL) THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_cal_instance(
  			v_cal_type,
  			v_sequence_number);
  	FETCH c_cal_instance INTO v_end_dt;
  	CLOSE c_cal_instance;
  	IF (p_end_dt > v_end_dt) THEN
  		p_message_name := 'IGS_EN_HECS_PAY_OPT_CANT_APPL';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_scho_expire');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END;
  END enrp_val_scho_expire;
  --
  --
  -- Validate the HECS option tax file number certificate number.
  FUNCTION enrp_val_tfn_crtfct(
  p_tax_file_number IN NUMBER ,
  p_tax_file_invalid_dt IN DATE ,
  p_tax_file_certificate_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
   BEGIN
  BEGIN
  	-- Validate the IGS_EN_STDNTPSHECSOP.tax_file_certificate_number.
  	-- Set the default message number
  	p_message_name := null;
  	-- Validate the input parameter
  	IF (p_tax_file_certificate_number IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	-- Validate the tax file certificate number.
  	-- Certificate number can only be set when there is no tax file number
  	-- recorded or an invalid tax file number is recorded.
  	IF (p_tax_file_number IS NOT NULL) AND
  			(p_tax_file_invalid_dt IS NULL) THEN
  		p_message_name := 'IGS_EN_CERTNUM_NO_TAX_FILE';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_tfn_crtfct');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  END enrp_val_tfn_crtfct;
  --
  -- Validate the HECS option tax file number invalid date.
  FUNCTION enrp_val_tfn_invalid(
  p_tax_file_number IN NUMBER ,
  p_tax_file_invalid_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN  AS
   BEGIN
  BEGIN
  	-- This module validates the IGS_EN_STDNTPSHECSOP.tax_file_invalid_dt.
  	-- Set the default message number
  	p_message_name := null;
  	-- Validate the input parameter
  	IF (p_tax_file_invalid_dt IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	-- Validate the tax file number invalid date.
  	-- The tax file number must be set when the invalid date is set.
  	IF (p_tax_file_number IS NULL) THEN
  		p_message_name := 'IGS_GE_INVALID_VALUE';
  		RETURN FALSE;
  	END IF;
  	-- Invalid date must not be future dated.
  	IF (p_tax_file_invalid_dt > SYSDATE) THEN
  		p_message_name := 'IGS_EN_TAX_FILE_NUM_INVALID_D';
  		RETURN FALSE;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_SCHO.enrp_val_tfn_invalid');
		IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
END enrp_val_tfn_invalid;
END IGS_EN_VAL_SCHO;

/
