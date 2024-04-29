--------------------------------------------------------
--  DDL for Package Body IGS_GR_VAL_GR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_VAL_GR" AS
/* $Header: IGSGR10B.pls 120.2 2006/02/21 00:54:09 sepalani noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function GRDP_VAL_AWARD_TYPE removed
  --avenkatr    29-AUG-2001     Bug Id : 1956374. Removed procedure "crsp_val_aw_closed"
  --Nalin Kumar 25-Oct-2002     Bug# 2640799- Modified the grdp_val_gr_rqrd and grdp_val_gr_type procedure
  --				to remove the 'Graduand Type' check - as per the Conferral Date Build.
  --ijeddy      06-Oct-2003    Build  3129913, Program completion Validation.
  -------------------------------------------------------------------------------------------
  -- Check if a specifc encumbrance effect applies to a person encumbrance
  FUNCTION enrp_val_encmb_efct(
  p_person_id  HZ_PARTIES.party_id%TYPE ,
  p_course_cd  IGS_PS_COURSE.course_cd%TYPE ,
  p_effective_dt  DATE ,
  p_encmb_effect_type  IGS_EN_ENCMB_EFCTTYP.s_encmb_effect_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- enrp_val_encmb_efct
  	-- This routines checks if an encumbrance effect applies to a person.
  DECLARE
  	v_pen_found	BOOLEAN;
  	v_effect_exists	BOOLEAN;
  	CURSOR c_pen IS
  		SELECT	pen.encumbrance_type,
  			pen.start_dt
  		FROM	IGS_PE_PERS_ENCUMB	pen
  		WHERE	pen.person_id		= p_person_id AND
  			TRUNC(p_effective_dt)	BETWEEN TRUNC(pen.start_dt) AND
  						TRUNC(NVL(pen.expiry_dt, p_effective_dt));
  	CURSOR c_pee_seet(
  		cp_pen_encumbrance_type	IGS_PE_PERS_ENCUMB.encumbrance_type%TYPE,
  		cp_pen_start_dt		IGS_PE_PERS_ENCUMB.start_dt%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_PE_PERSENC_EFFCT	pee,
  			IGS_EN_ENCMB_EFCTTYP_V	seet
  		WHERE	pee.person_id			= p_person_id AND
  			pee.encumbrance_type		= cp_pen_encumbrance_type AND
  			TRUNC(pee.pen_start_dt)		= TRUNC(cp_pen_start_dt) AND
  			pee.s_encmb_effect_type		= p_encmb_effect_type AND
  			TRUNC(p_effective_dt)		BETWEEN TRUNC(pee.pee_start_dt) AND
  							TRUNC(NVL(expiry_dt, p_effective_dt)) AND
  			seet.s_encmb_effect_type	= pee.s_encmb_effect_type AND
  			((seet.apply_to_course_ind	= 'Y' AND
  			 pee.course_cd			= NVL(p_course_cd, pee.course_cd)) OR
  			 seet.apply_to_course_ind	= 'N');
  	v_pee_seet_exists	VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	--1. Check parameters
  	IF p_person_id IS NULL OR
  			p_effective_dt IS NULL OR
  			p_encmb_effect_type IS NULL THEN
    				Fnd_Message.Set_Name('IGS', 'IGS_GE_INVALID_VALUE');
		    		App_Exception.Raise_Exception;

  	END IF;
  	--2. Look for an encumbrance with a matching encumbrance type effect.
  	v_pen_found := FALSE;
  	v_effect_exists := FALSE;
  	FOR v_pen_rec IN c_pen LOOP
  		v_pen_found := TRUE;
  		OPEN c_pee_seet(
  				v_pen_rec.encumbrance_type,
  				v_pen_rec.start_dt);
  		FETCH c_pee_seet INTO v_pee_seet_exists;
  		IF c_pee_seet%FOUND THEN
  			CLOSE c_pee_seet;
  			--encumbrance effect type exists
  			v_effect_exists := TRUE;
  			Exit; -- quit from for loop
  		END IF;
  		CLOSE c_pee_seet;
  	END LOOP; -- c_pen
  	IF NOT v_pen_found
  			THEN
  		RETURN FALSE;
  	END IF;
  	IF v_effect_exists THEN
  		RETURN TRUE;
  	END IF;
  	--No person_encumbrance_effect's match the effect type
  	p_message_name := 'IGS_EN_PRSN_ENCUMB_EFFECTTYPE';
  	RETURN FALSE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_pen%ISOPEN THEN
  			CLOSE c_pen;
  		END IF;
  		IF c_pee_seet%ISOPEN THEN
  			CLOSE c_pee_seet;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END enrp_val_encmb_efct;
  --
  -- Validate graduand student course attempt is a graduating course.
  FUNCTION grdp_val_gr_sca(
  p_person_id  IGS_GR_GRADUAND_ALL.person_id%TYPE ,
  p_course_cd  IGS_GR_GRADUAND_ALL.course_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gr_sca
  	-- Validate the graduand record student course attempt is for a
  	-- course version that graduates students.
  DECLARE
  	v_sca_version_number	IGS_EN_STDNT_PS_ATT.version_number%TYPE;
  	v_crv_exists		VARCHAR2(1);
  	CURSOR c_sca IS
  		SELECT	sca.version_number
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id	= p_person_id AND
  			course_cd	= p_course_cd;
  	CURSOR c_crv(
  		cp_version_number	IGS_PS_VER.version_number%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_PS_VER	crv
  		WHERE	crv.course_cd = p_course_cd AND
  			crv.version_number = cp_version_number AND
  			crv.graduate_students_ind = 'Y';
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	IF p_person_id IS NULL OR p_course_cd IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- Get the student course attempt course version number
  	OPEN c_sca;
  	FETCH c_sca INTO v_sca_version_number;
  	IF c_sca%NOTFOUND THEN
  		CLOSE c_sca;
  		RAISE NO_DATA_FOUND;
  	END IF;
  	CLOSE c_sca;
  	-- check course version graduates students
  	OPEN c_crv(v_sca_version_number);
  	FETCH c_crv INTO v_crv_exists;
  	IF c_crv%NOTFOUND THEN
  		CLOSE c_crv;
  		p_message_name := 'IGS_GR_DOES_NOT_GRAD_STUDENTS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_crv;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sca%ISOPEN THEN
  			CLOSE c_sca;
  		END IF;
  		IF c_crv%ISOPEN THEN
  			CLOSE c_crv;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gr_sca;
  --
  -- Validate Graduand Ceremony Round calendar instance.
  FUNCTION grdp_val_gr_crd_ci(
  p_grd_cal_type  IGS_GR_AWD_CRMN.grd_cal_type%TYPE ,
  p_grd_ci_sequence_number  IGS_GR_AWD_CRMN.grd_ci_sequence_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gr_crd_ci
  	-- Validate that the graduand is linked
  	-- to a ceremony_round that has an ACTIVE or PLANNED calendar instance.
  DECLARE
  	CURSOR c_ci_cs IS
  		SELECT	'x'
  		FROM	IGS_CA_INST	ci,
  			IGS_CA_STAT	cs
  		WHERE	ci.cal_type		= p_grd_cal_type AND
  			ci.sequence_number	= p_grd_ci_sequence_number AND
  			cs.cal_status		= ci.cal_status AND
  			cs.s_cal_status		IN ('ACTIVE', 'PLANNED');
  	v_ci_cs_exists	VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	IF p_grd_cal_type IS NULL OR p_grd_ci_sequence_number IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_ci_cs;
  	FETCH c_ci_cs INTO v_ci_cs_exists;
  	IF c_ci_cs %NOTFOUND THEN
  		CLOSE c_ci_cs;
  		p_message_name :='IGS_GR_INSTANC_ACTIVE_PLANNED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_ci_cs;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_ci_cs %ISOPEN THEN
  			CLOSE c_ci_cs;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gr_crd_ci;
  --
  -- Validate GRADUAND required details.
  FUNCTION grdp_val_gr_rqrd(
  p_course_cd  IGS_GR_GRADUAND_ALL.course_cd%TYPE ,
  p_graduand_status  IGS_GR_GRADUAND_ALL.graduand_status%TYPE ,
  p_s_graduand_type  IGS_GR_GRADUAND_ALL.s_graduand_type%TYPE ,
  p_award_course_cd  IGS_GR_GRADUAND_ALL.award_course_cd%TYPE ,
  p_award_crs_version_number  IGS_GR_GRADUAND_ALL.award_crs_version_number%TYPE ,
  p_award_cd  IGS_GR_GRADUAND_ALL.award_cd%TYPE ,
  p_honours_level  VARCHAR2 DEFAULT NULL,
  p_sur_for_course_cd  IGS_GR_GRADUAND_ALL.sur_for_course_cd%TYPE ,
  p_sur_for_crs_version_number  IGS_GR_GRADUAND_ALL.sur_for_crs_version_number%TYPE ,
  p_sur_for_award_cd  IGS_GR_GRADUAND_ALL.sur_for_award_cd%TYPE ,
  p_conferral_dt  IGS_GR_GRADUAND_V.conferral_dt%TYPE DEFAULT NULL,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN 	-- grdp_val_gr_rqrd
  	-- Validate the graduand record details:
  	-- * When s_graduand_status = 'GRADUATED' or 'SURRENDER', s_graduand_type
  	--   cannot be 'UNKNOWN'and conferral_dt must be set.
  	-- * When graduand is linked to a student_course_attempt a course_award must
  	--   be specified else an honorary award.
  	-- * An honorary award cannot be surrendered.
  	-- * When s_graduand_status = 'SURRENDER' or s_graduand_type = 'ARTICULATE'
  	--   surrendering course award is required.
  	-- * Honour level can only be specified when a course award is being conferred
  DECLARE
  	cst_graduated		CONSTANT	VARCHAR2(10) := 'GRADUATED';
  	cst_surrender		CONSTANT	VARCHAR2(10) := 'SURRENDER';
  	cst_unknown		CONSTANT	VARCHAR2(10) := 'UNKNOWN';
  	cst_deferred		CONSTANT	VARCHAR2(10) := 'DEFERRED';
  	cst_articulate		CONSTANT	VARCHAR2(10) := 'ARTICULATE';
  	cst_honorary		CONSTANT	VARCHAR2(10) := 'HONORARY';
  	v_s_graduand_status	IGS_GR_STAT.s_graduand_status%TYPE;
  	CURSOR c_gst IS
  		SELECT	gst.s_graduand_status
  		FROM	IGS_GR_STAT	gst
  		WHERE	gst.graduand_status	= p_graduand_status;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Check parameters
  	IF p_graduand_status IS NULL OR
  			p_s_graduand_type IS NULL OR
  			p_award_cd IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- Get the system graduand status
  	BEGIN
  		OPEN c_gst;
  		FETCH c_gst INTO v_s_graduand_status;
  		IF c_gst%NOTFOUND THEN
  			CLOSE c_gst;
  			RAISE NO_DATA_FOUND;
  		ELSE
  			CLOSE c_gst;
  		END IF;
  	EXCEPTION
  		WHEN NO_DATA_FOUND THEN
	       		Fnd_Message.Set_Name('IGS', 'IGS_GE_INVALID_VALUE');
	       		IGS_GE_MSG_STACK.ADD;
       			App_Exception.Raise_Exception;
  	END;
  	-- Check if course award details are required
  	IF p_course_cd IS NULL THEN
  		-- Honorary award
  		IF p_award_course_cd IS NOT NULL OR
  				p_award_crs_version_number IS NOT NULL THEN
  			p_message_name := 'IGS_GR_ONLY_HNRY_AWD';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		-- Course award
  		IF p_award_course_cd IS NULL OR
  				p_award_crs_version_number IS NULL THEN
  			p_message_name := 'IGS_GR_SPECIFY_COURSE_AWD';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Check if surrendering course details are required
  	IF p_course_cd IS NULL THEN
  		-- Honorary award
  		IF p_sur_for_course_cd IS NOT NULL OR
  				p_sur_for_crs_version_number IS NOT NULL OR
  				p_sur_for_award_cd IS NOT NULL THEN
  			p_message_name := 'IGS_GR_INVALID_HNRY_AWD';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	IF v_s_graduand_status = cst_surrender OR
  			p_s_graduand_type = cst_articulate THEN
  		IF p_sur_for_course_cd IS NULL OR
  				p_sur_for_crs_version_number IS NULL OR
  				p_sur_for_award_cd IS NULL THEN
  			p_message_name := 'IGS_GR_COURS_AWD_MUST_BE_SPEC';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		IF p_sur_for_course_cd IS NOT NULL OR
  				p_sur_for_crs_version_number IS NOT NULL OR
  				p_sur_for_award_cd IS NOT NULL THEN
  			p_message_name := 'IGS_GR_CHECK_SURR_COURS_AWD';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_gst%ISOPEN THEN
  			CLOSE c_gst;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gr_rqrd;
  --
  -- Validate graduand status.
  FUNCTION grdp_val_gr_gst(
  p_person_id  IGS_GR_GRADUAND_ALL.person_id%TYPE ,
  p_create_dt  IGS_GR_GRADUAND_ALL.create_dt%TYPE ,
  p_course_cd  IGS_GR_GRADUAND_ALL.course_cd%TYPE ,
  p_graduand_appr_status  IGS_GR_GRADUAND_ALL.graduand_appr_status%TYPE ,
  p_s_graduand_type  IGS_GR_GRADUAND_ALL.s_graduand_type%TYPE ,
  p_award_course_cd  IGS_GR_GRADUAND_ALL.award_course_cd%TYPE ,
  p_award_crs_version_number  IGS_GR_GRADUAND_ALL.award_crs_version_number%TYPE ,
  p_award_cd  IGS_GR_GRADUAND_ALL.award_cd%TYPE ,
  p_new_graduand_status  IGS_GR_GRADUAND_ALL.graduand_status%TYPE ,
  p_old_graduand_status  IGS_GR_GRADUAND_ALL.graduand_status%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gr_gst
  	-- This routine validates the setting of graduand.graduand_status
  DECLARE
  	v_s_graduand_appr_status	IGS_GR_APRV_STAT.s_graduand_appr_status%TYPE;
  	v_new_s_graduand_status		IGS_GR_GRADUAND.graduand_status%TYPE;
  	v_old_s_graduand_status		IGS_GR_GRADUAND.graduand_status%TYPE;
  	cst_potential			CONSTANT VARCHAR2(12) := 'POTENTIAL';
  	cst_graduated			CONSTANT VARCHAR2(12) := 'GRADUATED';
  	cst_eligible 			CONSTANT VARCHAR2(12) := 'ELIGIBLE';
  	cst_approved 			CONSTANT VARCHAR2(12) := 'APPROVED';
  	cst_surrender			CONSTANT VARCHAR2(12) := 'SURRENDER';
  	cst_attending			CONSTANT VARCHAR2(12) := 'ATTENDING';
  	v_exit_loop			BOOLEAN;
  	CURSOR c_gas IS
  		SELECT	gas.s_graduand_appr_status
  		FROM	IGS_GR_APRV_STAT		gas
  		WHERE	gas.graduand_appr_status 	= p_graduand_appr_status;
  	CURSOR c_gst (
  		cp_graduand_status	IGS_GR_GRADUAND.graduand_status%TYPE)
  	IS
  		SELECT	gst.s_graduand_status
  		FROM	IGS_GR_STAT		gst
  		WHERE	gst.graduand_status	= cp_graduand_status;
  	CURSOR	c_gac IS
  		SELECT	gac.grd_cal_type,
  			gac.grd_ci_sequence_number,
  			gac.ceremony_number,
  			gac.us_group_number
  		FROM	IGS_GR_AWD_CRMN	gac
  		WHERE	gac.person_id		= p_person_id AND
  			gac.create_dt		= p_create_dt AND
  			gac.award_course_cd	= p_award_course_cd AND
  			gac.award_crs_version_number
  						= p_award_crs_version_number AND
  			gac.award_cd		= p_award_cd;
  BEGIN
  	p_message_name := NULL;
  	v_exit_loop := FALSE;
  	-- Check parameters
  	IF p_person_id IS NULL OR
  			p_create_dt IS NULL OR
  			p_course_cd IS NULL OR
  			p_graduand_appr_status IS NULL OR
  			p_s_graduand_type IS NULL OR
  			p_award_cd IS NULL OR
  			p_new_graduand_status IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- validate change of graduand status
  	IF p_new_graduand_status = NVL(p_old_graduand_status,'NULL') THEN
  		RETURN TRUE;
  	END IF;
  	-- get the system status values.
  	OPEN c_gas;
  	FETCH c_gas INTO v_s_graduand_appr_status;
  	CLOSE c_gas;
  	OPEN c_gst(p_new_graduand_status);
  	FETCH c_gst INTO v_new_s_graduand_status;
  	CLOSE c_gst;
  	IF p_old_graduand_status IS NOT NULL THEN
  		OPEN c_gst(p_old_graduand_status);
  		FETCH c_gst INTO v_old_s_graduand_status;
  		CLOSE c_gst;
  	END IF;
  	-- validate the graduand status
  	IF v_new_s_graduand_status = cst_potential THEN
  		IF p_old_graduand_status IS NULL THEN
  			RETURN TRUE;
  		END IF;
  		IF v_old_s_graduand_status IN (cst_graduated,
  						cst_surrender) THEN
  			p_message_name := 'IGS_GR_STATUS_CANNOT_BE_CHANG';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	IF v_new_s_graduand_status = cst_eligible THEN
  		IF p_old_graduand_status IS NOT NULL THEN
  			IF v_old_s_graduand_status IN (cst_graduated,
  						cst_surrender) THEN
  				p_message_name := 'IGS_GR_STATUS_CANNOT_BE_CHANG';
  				RETURN FALSE;
  			END IF;
  		END IF;
  		-- check eligibility
  		IF NOT IGS_GR_VAL_GR.grdp_val_aw_eligible(
  					p_person_id,
  					p_course_cd,
  					p_award_course_cd,
  					p_award_crs_version_number,
  					p_award_cd,
  					p_message_name) THEN
  			RETURN FALSE;
  		END IF;
  		IF p_s_graduand_type = cst_attending THEN
  			-- check primary unit sets are complete
  			-- when a determinant for attendance at
  			-- a ceremony.
  			FOR v_gac_rec IN c_gac LOOP
  				IF NOT IGS_GR_VAL_GAC.grdp_val_gac_susa(
  						p_person_id,
  						p_create_dt,
  						v_gac_rec.grd_cal_type,
  						v_gac_rec.grd_ci_sequence_number,
  						p_course_cd,
  						p_new_graduand_status,
  						v_gac_rec.ceremony_number,
  						p_award_course_cd,
  						p_award_crs_version_number,
  						p_award_cd,
  						v_gac_rec.us_group_number,
  						p_message_name) THEN
  					v_exit_loop := TRUE;
  					Exit;
  				END IF;
  			END LOOP;
  			IF v_exit_loop THEN
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	IF v_new_s_graduand_status = cst_graduated THEN
  		IF v_s_graduand_appr_status <> cst_approved THEN
  			p_message_name := 'IGS_GR_SYSTEM_VAL_MUST_BE_APP';
  			RETURN FALSE;
  		END IF;
  		IF p_old_graduand_status IS NULL OR
  				v_old_s_graduand_status NOT IN (cst_eligible,
  								cst_surrender) THEN
  			IF NOT IGS_GR_VAL_GR.grdp_val_aw_eligible(
  					p_person_id,
  					p_course_cd,
  					p_award_course_cd,
  					p_award_crs_version_number,
  					p_award_cd,
  					p_message_name) THEN
  				RETURN FALSE;
  			END IF;
  			IF p_s_graduand_type = cst_attending THEN
  				-- check primary unit sets are complete
  				-- when a determinant for attendance at
  				-- a ceremony.
  				FOR v_gac_rec IN c_gac LOOP
  					IF NOT IGS_GR_VAL_GAC.grdp_val_gac_susa(
  							p_person_id,
  							p_create_dt,
  							v_gac_rec.grd_cal_type,
  							v_gac_rec.grd_ci_sequence_number,
  							p_course_cd,
  							p_new_graduand_status,
  							v_gac_rec.ceremony_number,
  							p_award_course_cd,
  							p_award_crs_version_number,
  							p_award_cd,
  							v_gac_rec.us_group_number,
  							p_message_name) THEN
  						v_exit_loop := TRUE;
  						Exit;
  					END IF;
  				END LOOP;
  				IF v_exit_loop THEN
  					RETURN FALSE;
  				END IF;
  			END IF;
  		END IF;
  	END IF;
  	IF v_new_s_graduand_status = cst_surrender THEN
  		IF p_old_graduand_status IS NULL OR
  				v_old_s_graduand_status <> cst_graduated THEN
  			p_message_name := 'IGS_GR_AWD_NOT_GIVEN_PRIOR';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_gas%ISOPEN THEN
  			CLOSE c_gas;
  		END IF;
  		IF c_gac%iSOPEN THEN
  			CLOSE c_gac;
  		END IF;
  		IF c_gst%ISOPEN THEN
  			CLOSE c_gst;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gr_gst;
  --
  -- Validate graduand approval status.
  FUNCTION grdp_val_gr_gas(
  p_person_id IN HZ_PARTIES.party_id%TYPE ,
  p_course_cd IN IGS_PS_COURSE.course_cd%TYPE ,
  p_graduand_status  IGS_GR_GRADUAND_ALL.graduand_status%TYPE ,
  p_new_graduand_appr_status  IGS_GR_GRADUAND_ALL.graduand_appr_status%TYPE ,
  p_old_graduand_appr_status  IGS_GR_GRADUAND_ALL.graduand_appr_status%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gr_gas
  DECLARE
  	v_gst_s_graduand_status		IGS_GR_STAT.s_graduand_status%TYPE;
  	v_gas_s_graduand_appr_status	IGS_GR_APRV_STAT.s_graduand_appr_status%TYPE;
  	cst_graduated					CONSTANT VARCHAR2(9) := 'GRADUATED';
  	cst_surrender					CONSTANT VARCHAR2(9) := 'SURRENDER';
  	cst_approved					CONSTANT VARCHAR2(8) := 'APPROVED';
  	CURSOR c_gst IS
  		SELECT	gst.s_graduand_status
  		FROM	IGS_GR_STAT gst
  		WHERE	gst.graduand_status = p_graduand_status;
  	CURSOR c_gas IS
  		SELECT	gas.s_graduand_appr_status
  		FROM	IGS_GR_APRV_STAT gas
  		WHERE	gas.graduand_appr_status = p_new_graduand_appr_status;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	--1. Check parameters :
  	IF p_graduand_status IS NULL OR
     		p_new_graduand_appr_status IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- 2.Validate change of graduand approval status
  	IF p_new_graduand_appr_status = NVL(p_old_graduand_appr_status, 'NULL') THEN
  		RETURN TRUE;
  	END IF;
  	--check the graduand hasn't already graduated
  	OPEN c_gst;
  	FETCH c_gst INTO v_gst_s_graduand_status;
  	IF c_gst%NOTFOUND THEN
  		CLOSE c_gst;
  		RAISE NO_DATA_FOUND;
  	END IF;
  	CLOSE c_gst;
  	OPEN c_gas;
  	FETCH c_gas INTO v_gas_s_graduand_appr_status;
  	IF c_gas%NOTFOUND THEN
  		CLOSE c_gas;
  		RAISE NO_DATA_FOUND;
  	END IF;
  	CLOSE c_gas;
  	IF v_gst_s_graduand_status IN (	cst_graduated,
  					cst_surrender) THEN
  		IF v_gas_s_graduand_appr_status <> cst_approved THEN
  			p_message_name := 'IGS_GR_MUST_HAVE_VALUE_APPROV';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- check no encumbrances restrict approval
  	IF v_gas_s_graduand_appr_status = cst_approved THEN
  		IF IGS_GR_VAL_GR.enrp_val_encmb_efct(
  						p_person_id,
  						p_course_cd,
  						SYSDATE,
  						'GRAD_BLK',
  						p_message_name) = TRUE THEN
  			p_message_name := 'IGS_GR_CANNOT_BE_APPROVED';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	--3.	Return no error:
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_gst %ISOPEN THEN
  			CLOSE c_gst;
  		END IF;
  		IF c_gas %ISOPEN THEN
  			CLOSE c_gas;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gr_gas;
  --
  -- Validate system graduand type.
  FUNCTION GRDP_VAL_GR_TYPE(
  p_person_id  IGS_GR_GRADUAND_ALL.person_id%TYPE ,
  p_create_dt  IGS_GR_GRADUAND_ALL.create_dt%TYPE ,
  p_course_cd  IGS_GR_GRADUAND_ALL.course_cd%TYPE ,
  p_graduand_status  IGS_GR_GRADUAND_ALL.graduand_status%TYPE ,
  p_new_s_graduand_type  IGS_GR_GRADUAND_ALL.s_graduand_type%TYPE ,
  p_old_s_graduand_type  IGS_GR_GRADUAND_ALL.s_graduand_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gr_type
  DECLARE
  	v_gst_s_graduand_status		IGS_GR_STAT.s_graduand_status%TYPE;
  	cst_graduated			CONSTANT IGS_GR_STAT.graduand_status%TYPE
  					:= 'GRADUATED';
  	cst_surrender			CONSTANT IGS_GR_STAT.graduand_status%TYPE
  					:= 'SURRENDER';
  	cst_unknown			CONSTANT IGS_GR_STAT.graduand_status%TYPE
  					:= 'UNKNOWN';
  	cst_deferred			CONSTANT IGS_GR_STAT.graduand_status%TYPE
  					:= 'DEFERRED';
  	cst_attending			CONSTANT IGS_GR_STAT.graduand_status%TYPE
  					:= 'ATTENDING';
  	cst_inabsentia			CONSTANT IGS_GR_STAT.graduand_status%TYPE
  					:= 'INABSENTIA';
  	cst_eligible			CONSTANT IGS_GR_STAT.graduand_status%TYPE
  					:= 'ELIGIBLE';
  	v_should_return_false		BOOLEAN;
  	CURSOR c_gst IS
  		SELECT	gst.s_graduand_status
  		FROM	IGS_GR_STAT gst
  		WHERE	gst.graduand_status = p_graduand_status;
  	CURSOR c_gac IS
  		SELECT	'x'
  		FROM	IGS_GR_AWD_CRMN	gac
  		WHERE	gac.person_id = p_person_id AND
  			gac.create_dt = p_create_dt;
  	CURSOR c_gac2 IS
  		SELECT	gac.grd_cal_type,
  			gac.grd_ci_sequence_number,
  			gac.ceremony_number,
  			gac.award_course_cd,
  			gac.award_crs_version_number,
  			gac.award_cd,
  			gac.us_group_number
  		FROM	IGS_GR_AWD_CRMN gac
  		WHERE	gac.person_id = p_person_id AND
  			gac.create_dt = p_create_dt;
  	v_gac_exists			VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	--1. Check parameters :
  	IF p_person_id IS NULL OR
     		p_create_dt IS NULL OR
     		p_graduand_status IS NULL OR
     		p_new_s_graduand_type IS NULL THEN
  			RETURN TRUE;
  	END IF;
  	--2. Validate change of graduand type
  	IF p_new_s_graduand_type = NVL(p_old_s_graduand_type, 'NULL') THEN
  		RETURN TRUE;
  	END IF;
  	--check the graduand hasn't already graduated
  	OPEN c_gst;
  	FETCH c_gst INTO v_gst_s_graduand_status;
  	IF c_gst%NOTFOUND THEN
  		CLOSE c_gst;
  		RAISE NO_DATA_FOUND;
  	END IF;
  	CLOSE c_gst;
 --ijeddy, Bug 2996721, 9 June 2003, commented the following If block
/*	IF v_gst_s_graduand_status IN(
  				cst_graduated,
  				cst_surrender) THEN
  		IF p_old_s_graduand_type IS NOT NULL THEN
  			--not setting the value FOR the first time
  			p_message_name := 'IGS_GR_GRAD_CANNOT_BE_CHANGED';
  			RETURN FALSE;
  		END IF;
  	ELSE
*/
  		IF p_new_s_graduand_type NOT IN(
  					cst_attending,
  					cst_inabsentia,
  					cst_unknown) THEN
  			--check no related graduand award ceremonies exist
  			OPEN c_gac;
  			FETCH c_gac INTO v_gac_exists;
  			IF c_gac%FOUND THEN
  				CLOSE c_gac;
  				p_message_name := 'IGS_GR_CHECK_GRAD_TYPE';
  				RETURN FALSE;
  			END IF;
  			CLOSE c_gac;
  		ELSE
  			IF p_new_s_graduand_type = cst_attending AND
  					v_gst_s_graduand_status = cst_eligible THEN
  				--check primary unit sets are complete when a determinant
  				-- for attendance at a ceremony
  				v_should_return_false :=FALSE;
  				FOR v_gac2_rec IN c_gac2 LOOP
  					IF IGS_GR_VAL_GAC.grdp_val_gac_susa(
  								p_person_id,
  								p_create_dt,
  								v_gac2_rec.grd_cal_type,
  								v_gac2_rec.grd_ci_sequence_number,
  								p_course_cd,
  								p_graduand_status,
  								v_gac2_rec.ceremony_number,
  								v_gac2_rec.award_course_cd,
  								v_gac2_rec.award_crs_version_number,
  								v_gac2_rec.award_cd,
  								v_gac2_rec.us_group_number,
  								p_message_name) = FALSE THEN
  						v_should_return_false :=TRUE;
  						Exit;
  					END IF;
  				END LOOP;
  				IF v_should_return_false THEN
  					RETURN FALSE;
  				END IF;
  			END IF;
  		END IF;
--ijeddy, Bug 2996721, 9 June 2003, commented the following End If
--  	END IF;
  	--3.	Return no error:
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_gst %ISOPEN THEN
  			CLOSE c_gst;
  		END IF;
  		IF c_gac %ISOPEN THEN
  			CLOSE c_gac;
  		END IF;
  		IF c_gac2 %ISOPEN THEN
  			CLOSE c_gac2;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gr_type;
  --
  -- Validate proxy details.
  FUNCTION grdp_val_gr_proxy(
  p_person_id  IGS_GR_GRADUAND_ALL.person_id%TYPE ,
  p_s_graduand_type  IGS_GR_GRADUAND_ALL.s_graduand_type%TYPE ,
  p_proxy_award_ind  IGS_GR_GRADUAND_ALL.proxy_award_ind%TYPE ,
  p_proxy_award_person_id  IGS_GR_GRADUAND_ALL.proxy_award_person_id%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gr_proxy
  	-- Validate the graduand record proxy details.
  DECLARE
  	cst_attending	CONSTANT IGS_GR_GRADUAND.s_graduand_type%TYPE := 'ATTENDING';
  	v_pe_exists	VARCHAR2(1);
  	CURSOR c_pe(
  		cp_id	IGS_PE_PERSON_BASE_V.person_id%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_PE_PERSON_BASE_V	pe
  		WHERE	pe.person_id	= cp_id AND
  			pe.date_of_death is not NULL;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- Check Parameters
  	IF p_person_id IS NULL OR
  			p_s_graduand_type IS NULL OR
  			p_proxy_award_ind IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	IF p_proxy_award_ind = 'Y' THEN
  		IF p_proxy_award_person_id IS NULL THEN
  			p_message_name := 'IGS_GR_SPECIFY_PRXY_AWD_PERS';
  			RETURN FALSE;
  		ELSE
  			-- Check the proxy person is not the graduand.
  			IF p_proxy_award_person_id = p_person_id THEN
  				p_message_name := 'IGS_GR_PRXY_AWD_MUST_BE_DIFF';
  				RETURN FALSE;
  			ELSE
  			-- Check the proxy person is not deceased.
  				OPEN c_pe(p_proxy_award_person_id);
  				FETCH c_pe INTO v_pe_exists;
  				IF c_pe%FOUND THEN
                          		CLOSE c_pe;
  					p_message_name := 'IGS_GR_PRXY_PERS_DECEASED';
                          		RETURN FALSE;
                          	END IF;
                          	CLOSE c_pe;
  			END IF;
  			-- Check the graduand type is ATTENDING
  			IF p_s_graduand_type <> cst_attending THEN
  				p_message_name := 'IGS_GR_TYPE_MUST_BE_ATTENDING';
  				RETURN TRUE;	-- Warning only
  			END IF;
  		END IF;
  	ELSE -- p_proxy_award_ind = 'N'
  		-- no proxy
  		IF p_proxy_award_person_id IS NOT NULL THEN
  			p_message_name := 'IGS_GR_PRXY_AWD_NOT_NEEDED';
  			RETURN FALSE;
  		ELSE
  			OPEN c_pe(p_person_id);
  			FETCH c_pe INTO v_pe_exists;
  			IF c_pe%FOUND AND p_s_graduand_type = cst_attending THEN
                 			CLOSE c_pe;
  				p_message_name := 'IGS_GR_REQUIRES_PRXY_FOR_CERM';
                  		RETURN FALSE;
                  	END IF;
                         	CLOSE c_pe;
  		END IF;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_pe%ISOPEN THEN
  			CLOSE c_pe;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gr_proxy;
  --
  -- Check for multiple instances of the same award for the person.
  FUNCTION grdp_val_gr_unique(
  p_person_id IN IGS_GR_GRADUAND_ALL.person_id%TYPE ,
  p_create_dt IN IGS_GR_GRADUAND_ALL.create_dt%TYPE ,
  p_grd_cal_type IN IGS_CA_TYPE.cal_type%TYPE ,
  p_grd_ci_sequence_num IN NUMBER ,
  p_award_course_cd IN IGS_GR_GRADUAND_ALL.award_course_cd%TYPE ,
  p_award_crs_version_number IN IGS_GR_GRADUAND_ALL.award_crs_version_number%TYPE ,
  p_award_cd IN IGS_GR_GRADUAND_ALL.award_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gr_unique
  	-- Validate that the graduand record is unique.
  	-- 	Note, both warnings and errors may result
  	--	from this routine.
  DECLARE
  	cst_graduated		CONSTANT VARCHAR2(12) := 'GRADUATED';
  	cst_surrender		CONSTANT VARCHAR2(12) := 'SURRENDER';
  	v_gst_found		VARCHAR2(1);
  	CURSOR c_gr IS
  		SELECT	gr.grd_cal_type,
  			gr.grd_ci_sequence_number,
  			gr.graduand_status
  		FROM	IGS_GR_GRADUAND	gr
  		WHERE	gr.person_id				= p_person_id AND
  			gr.create_dt				<> p_create_dt AND
  			gr.award_cd				= p_award_cd  AND
  			NVL(gr.award_course_cd, 'NULL')		= NVL(p_award_course_cd,'NULL') AND
  			NVL(gr.award_crs_version_number,0)	= NVL(p_award_crs_version_number,0);
  	CURSOR c_gst (
  		cp_graduand_status	IGS_GR_GRADUAND.graduand_status%TYPE)
  	IS
  		SELECT	'x'
  		FROM	IGS_GR_STAT		gst
  		WHERE	gst.graduand_status	= cp_graduand_status AND
  			gst.s_graduand_status	IN (cst_graduated,
  							cst_surrender);
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- NULL parameter check
  	IF p_person_id	IS NULL OR
  		p_create_dt IS NULL OR
  		p_grd_cal_type IS NULL OR
  		p_grd_ci_sequence_num IS NULL OR
  		p_award_cd IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- Test for equivalent graduand records
  	FOR v_gr_rec IN c_gr LOOP
  		OPEN c_gst(v_gr_rec.graduand_status);
  		FETCH c_gst INTO v_gst_found;
  		IF c_gst%FOUND THEN
  			CLOSE c_gst;
  			p_message_name := 'IGS_GE_DUPLICATE_VALUE';
  			RETURN FALSE;
  		ELSE
  			CLOSE c_gst;
  			IF v_gr_rec.grd_cal_type = p_grd_cal_type AND
  				v_gr_rec.grd_ci_sequence_number = p_grd_ci_sequence_num THEN
  				p_message_name := 'IGS_GR_GRAD_DETAIL_EXISTS';
  				RETURN FALSE;
  			ELSE
  				-- warning only
  				p_message_name := 'IGS_GR_GRD_AWD_EXISTS';
  			END IF;
  		END IF;
  	END LOOP;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_gr%ISOPEN THEN
  			CLOSE c_gr;
  		END IF;
  		IF c_gst%ISOPEN THEN
  			CLOSE c_gst;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gr_unique;
  --
  -- Validate the update of a graduand with graduand awards ceremonies.
  FUNCTION grdp_val_gr_upd(
  p_person_id  IGS_GR_GRADUAND_ALL.person_id%TYPE ,
  p_create_dt  IGS_GR_GRADUAND_ALL.create_dt%TYPE ,
  p_award_course_cd  IGS_GR_GRADUAND_ALL.award_course_cd%TYPE ,
  p_award_crs_version_number  IGS_GR_GRADUAND_ALL.award_crs_version_number%TYPE ,
  p_award_cd  IGS_GR_GRADUAND_ALL.award_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gr_upd
  	-- Validate that the update of a graduand record does not occur
  	--	 after the graduation_ceremony ceremony or closing date.
  	-- Note, warnings only result from failure of the validations.
  DECLARE
  	CURSOR c_gac IS
  		SELECT	gac.grd_cal_type,
  			gac.grd_ci_sequence_number,
  			gac.ceremony_number
  		FROM	IGS_GR_AWD_CRMN	gac
  		WHERE	gac.person_id		= p_person_id AND
  			gac.create_dt		= p_create_dt AND
  			gac.award_cd		= p_award_cd  AND
  			NVL(gac.award_course_cd, 'NULL')	= NVL(p_award_course_cd,'NULL') AND
  			NVL(gac.award_crs_version_number,0)	= NVL(p_award_crs_version_number,0);
  	v_gac_rec	c_gac%ROWTYPE;
  	CURSOR c_gc(
  		cp_grd_cal_type 		IGS_GR_AWD_CRMN.grd_cal_type%TYPE,
  		cp_grd_ci_sequence_number
  	IGS_GR_AWD_CRMN.grd_ci_sequence_number%TYPE,
  		cp_ceremony_number 		IGS_GR_AWD_CRMN.ceremony_number%TYPE) IS
  		SELECT	gc.ceremony_dt_alias,
  			gc.ceremony_dai_sequence_number,
  			gc.closing_dt_alias,
  			gc.closing_dai_sequence_number
  		FROM	IGS_GR_CRMN		gc
  		WHERE	gc.grd_cal_type			= cp_grd_cal_type AND
  			gc.grd_ci_sequence_number	= cp_grd_ci_sequence_number AND
  			gc.ceremony_number 		= cp_ceremony_number;
  	v_gc_rec	c_gc%ROWTYPE;
  	v_ceremony_dt	DATE DEFAULT NULL;
  	v_closing_dt	DATE DEFAULT NULL;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	-- NULL parameter check
  	IF p_person_id IS NULL OR
  			p_create_dt IS NULL OR
  			p_award_cd IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- NOTE the date checks below are warnings only, hence the return of TRUE
          FOR v_gac_rec IN c_gac LOOP
  		OPEN c_gc(
  			v_gac_rec.grd_cal_type,
  			v_gac_rec.grd_ci_sequence_number,
  			v_gac_rec.ceremony_number);
  		FETCH c_gc INTO v_gc_rec;
      		CLOSE c_gc;
  		v_ceremony_dt := IGS_CA_GEN_001.CALP_GET_ALIAS_VAL(
  						v_gc_rec.ceremony_dt_alias,
  						v_gc_rec.ceremony_dai_sequence_number,
  						v_gac_rec.grd_cal_type,
  						v_gac_rec.grd_ci_sequence_number);
  		IF TRUNC(SYSDATE) > TRUNC(v_ceremony_dt) THEN
  			p_message_name := 'IGS_GR_INV_DT_GRAD_CERM';
  			RETURN TRUE;
  		END IF;
  		v_closing_dt := IGS_CA_GEN_001.CALP_GET_ALIAS_VAL(
  						v_gc_rec.closing_dt_alias,
  						v_gc_rec.closing_dai_sequence_number,
  						v_gac_rec.grd_cal_type,
  						v_gac_rec.grd_ci_sequence_number);
  		IF TRUNC(SYSDATE) > TRUNC(v_closing_dt) THEN
  			p_message_name := 'IGS_GR_CLOSING_DT_REACHED';
  			RETURN TRUE;
  		END IF;
          END LOOP;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_gac %ISOPEN THEN
  			CLOSE c_gac;
  		END IF;
  		IF c_gc %ISOPEN THEN
  			CLOSE c_gc;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gr_upd;
  --
  -- Validate inserting or updating a graduand.
  FUNCTION grdp_val_gr_iu(
  p_grd_cal_type  IGS_GR_AWD_CRMN.grd_cal_type%TYPE ,
  p_grd_ci_sequence_number  IGS_GR_AWD_CRMN.grd_ci_sequence_number%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gac_iu
  	-- Validate that the insert or update of a graduand record
  	-- does not fall outside the ceremony round processing period.
  DECLARE
  	CURSOR c_crd IS
  		SELECT	crd.start_dt_alias,
  			crd.start_dai_sequence_number,
  			crd.end_dt_alias,
  			crd.end_dai_sequence_number
  		FROM	IGS_GR_CRMN_ROUND		crd
  		WHERE	crd.grd_cal_type		= p_grd_cal_type AND
  			crd.grd_ci_sequence_number	= p_grd_ci_sequence_number;
  	v_crd_rec	c_crd%ROWTYPE;
  	v_start_dt	DATE DEFAULT NULL;
  	v_end_dt	DATE DEFAULT NULL;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	IF p_grd_cal_type IS NULL OR p_grd_ci_sequence_number IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	OPEN c_crd;
  	FETCH c_crd INTO v_crd_rec;
  	IF c_crd%FOUND THEN
  		CLOSE c_crd;
  		v_start_dt := IGS_CA_GEN_001.CALP_GET_ALIAS_VAL(
  						v_crd_rec.start_dt_alias,
  						v_crd_rec.start_dai_sequence_number,
  						p_grd_cal_type,
  						p_grd_ci_sequence_number);
  		v_end_dt := IGS_CA_GEN_001.CALP_GET_ALIAS_VAL(
  						v_crd_rec.end_dt_alias,
  						v_crd_rec.end_dai_sequence_number,
  						p_grd_cal_type,
  						p_grd_ci_sequence_number);
  		IF v_start_dt IS NULL OR v_end_dt IS NULL THEN
  			p_message_name := NULL;
  			RETURN TRUE;
  		END IF;
  		IF TRUNC(SYSDATE) < TRUNC(v_start_dt) OR
  				TRUNC(SYSDATE) > TRUNC(v_end_dt) THEN
  			p_message_name := 'IGS_GR_CUR_DT_OUTSIDE_CERROUN';
  			RETURN TRUE;
  		END IF;
  	ELSE
  		CLOSE c_crd;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_crd %ISOPEN THEN
  			CLOSE c_crd;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gr_iu;
  --
  -- Validate the graduand has satisfied academic requirements for an award
  FUNCTION grdp_val_aw_eligible(
  p_person_id  IGS_GR_GRADUAND_ALL.person_id%TYPE ,
  p_course_cd  IGS_GR_GRADUAND_ALL.course_cd%TYPE ,
  p_award_course_cd  IGS_GR_GRADUAND_ALL.award_course_cd%TYPE ,
  p_award_crs_version_number  IGS_GR_GRADUAND_ALL.award_crs_version_number%TYPE ,
  p_award_cd  IGS_GR_GRADUAND_ALL.award_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_aw_eligible
  	-- Validate the graduand is academically eligible for the award.
  DECLARE
  	v_sca_version_number	IGS_EN_STDNT_PS_ATT.version_number%TYPE;
  	v_sca_crs_rqrmnt_ind	IGS_EN_STDNT_PS_ATT.course_rqrmnt_complete_ind%TYPE;
  	CURSOR c_sca IS
  		SELECT	sca.version_number,
  			sca.course_rqrmnt_complete_ind
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id	= p_person_id AND
  			sca.course_cd	= p_course_cd;
  	v_scaae_exists	VARCHAR2(1);
  	CURSOR	c_scaae
  		(cp_sca_version_number		IGS_EN_STDNT_PS_ATT.version_number%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_PS_STDNT_APV_ALT	scaae
  		WHERE	scaae.person_id			= p_person_id AND
  			scaae.course_cd			= p_course_cd AND
  			scaae.version_number		= cp_sca_version_number AND
  			scaae.exit_course_cd		= p_award_course_cd AND
  			scaae.exit_version_number	= p_award_crs_version_number AND
  			scaae.rqrmnts_complete_ind	= 'Y';
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	--1. Check parameters :
  	IF p_person_id IS NULL OR
  			p_award_cd IS NULL OR
  			(p_course_cd IS NOT NULL AND
  			(p_award_course_cd IS NULL OR
  			p_award_crs_version_number IS NULL)) THEN
    				Fnd_Message.Set_Name('IGS', 'IGS_GE_INVALID_VALUE');
    				IGS_GE_MSG_STACK.ADD;
		    		App_Exception.Raise_Exception;
  	END IF;
  	--2. Check if an honorary award rather than a course award is being given
  	IF p_course_cd IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	--3. Match award to student course attempt
  	OPEN c_sca;
  	FETCH c_sca INTO
  			v_sca_version_number,
  			v_sca_crs_rqrmnt_ind;
  	IF c_sca%NOTFOUND THEN
  		CLOSE c_sca;
  		RAISE NO_DATA_FOUND;
  	END IF;
  	CLOSE c_sca;
  	IF p_award_course_cd = p_course_cd AND
  			p_award_crs_version_number = v_sca_version_number THEN
  		IF v_sca_crs_rqrmnt_ind = 'Y' THEN
  			RETURN TRUE;
  		ELSE
  			p_message_name := 'IGS_GR_COURSE_REQIR_NOT_COMPL';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		--check for a match with an approved alternative exit
  		OPEN c_scaae(v_sca_version_number);
  		FETCH c_scaae INTO v_scaae_exists;
  		IF c_scaae%NOTFOUND THEN
  			CLOSE c_scaae;
  			p_message_name := 'IGS_GR_NOT_APPRV_EXIT';
  			RETURN FALSE;
  		ELSE
  			CLOSE c_scaae;
  			RETURN TRUE;
  		END IF;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sca %ISOPEN THEN
  			CLOSE c_sca;
  		END IF;
  		IF c_scaae %ISOPEN THEN
  			CLOSE c_scaae;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_aw_eligible;
  --
  -- Validate graduand course award.
  FUNCTION grdp_val_gr_caw(
  p_person_id  IGS_GR_GRADUAND_ALL.person_id%TYPE ,
  p_course_cd  IGS_GR_GRADUAND_ALL.course_cd%TYPE ,
  p_award_course_cd  IGS_GR_GRADUAND_ALL.award_course_cd%TYPE ,
  p_award_crs_version_number  IGS_GR_GRADUAND_ALL.award_crs_version_number%TYPE ,
  p_award_cd  IGS_GR_GRADUAND_ALL.award_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gr_caw
  	-- Validate the graduand record course award is an award for the
  	-- student course attempt or an alternative exit.
  DECLARE
  	v_sca_version_number	IGS_EN_STDNT_PS_ATT.version_number%TYPE;
  	v_ae_exists		VARCHAR2(1);
  	CURSOR c_sca IS
  		SELECT	sca.version_number
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id	= p_person_id AND
  			course_cd	= p_course_cd;
  	CURSOR c_ae(
  		cp_version_number	IGS_PE_ALTERNATV_EXT.version_number%TYPE) IS
  		SELECT	'x'
  		FROM	IGS_PE_ALTERNATV_EXT	ae
  		WHERE	ae.course_cd		= p_course_cd AND
  			ae.version_number	= cp_version_number AND
  			ae.exit_course_cd	= p_award_course_cd;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	IF p_person_id IS NULL OR
  			p_course_cd IS NULL OR
  			p_award_cd IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	-- Get the student course attempt course version number
  	OPEN c_sca;
  	FETCH c_sca INTO v_sca_version_number;
  	IF c_sca%NOTFOUND THEN
  		CLOSE c_sca;
  		RAISE NO_DATA_FOUND;
  	END IF;
  	CLOSE c_sca;
  	IF p_award_course_cd <> p_course_cd OR
  			p_award_crs_version_number <> v_sca_version_number THEN
  		-- check for a match with an alternative exit
  		OPEN c_ae(v_sca_version_number);
  		FETCH c_ae INTO v_ae_exists;
  		IF c_ae%NOTFOUND THEN
  			CLOSE c_ae;
  			p_message_name := 'IGS_GR_NOT_A_VALID_AWARD';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_ae;
  	END IF;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_sca%ISOPEN THEN
  			CLOSE c_sca;
  		END IF;
  		IF c_ae%ISOPEN THEN
  			CLOSE c_ae;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gr_caw;
  --
  -- Validate if graduand approval status is closed.
  FUNCTION grdp_val_gas_closed(
  p_graduand_appr_status  IGS_GR_APRV_STAT.graduand_appr_status%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gas_closed
  	-- Validate if the graduand approval status is closed
  DECLARE
  	v_gas_found	VARCHAR2(1);
  	CURSOR	c_gas IS
  		SELECT	'x'
  		FROM	IGS_GR_APRV_STAT	gas
  		WHERE	gas.graduand_appr_status	= p_graduand_appr_status AND
  			gas.closed_ind			= 'Y';
  BEGIN
  	p_message_name := NULL;
  	OPEN c_gas;
  	FETCH c_gas INTO v_gas_found;
  	IF (c_gas%FOUND) THEN
  		CLOSE c_gas;
  		p_message_name := 'IGS_GR_GRAD_APPR_STATUS_CLOSE';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_gas;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_gas%ISOPEN THEN
  			CLOSE c_gas;
  		END IF;
  	RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gas_closed;
  --
  -- Validate if graduand status is closed.
  FUNCTION grdp_val_gst_closed(
  p_graduand_status  IGS_GR_STAT.graduand_status%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gst_closed
  	-- Validate if the graduand status is closed
  DECLARE
  	v_gst_found	VARCHAR2(1);
  	CURSOR	c_gst IS
  		SELECT	'x'
  		FROM	IGS_GR_STAT	gst
  		WHERE	gst.graduand_status	= p_graduand_status AND
  			gst.closed_ind		= 'Y';
  BEGIN
  	p_message_name := NULL;
  	OPEN c_gst;
  	FETCH c_gst INTO v_gst_found;
  	IF (c_gst%FOUND) THEN
  		CLOSE c_gst;
  		p_message_name := 'IGS_GR_GRAD_STATUS_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_gst;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_gst%ISOPEN THEN
  			CLOSE c_gst;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gst_closed;
  --
  --validate if IGS_GR_HONOURS_LEVEL.honours_level is closed
  FUNCTION grdp_val_hl_closed(
  p_honours_level IN VARCHAR2 DEFAULT NULL,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
          RETURN FALSE;
  END grdp_val_hl_closed;
  --
  -- Validate graduand surrender for award.
  FUNCTION GRDP_VAL_GR_SUR_CAW(
  p_person_id  IGS_GR_GRADUAND_ALL.person_id%TYPE ,
  p_course_cd  IGS_GR_GRADUAND_ALL.course_cd%TYPE ,
  p_graduand_status  IGS_GR_GRADUAND_ALL.graduand_status%TYPE ,
  p_sur_for_course_cd  IGS_GR_GRADUAND_ALL.sur_for_course_cd%TYPE ,
  p_sur_for_crs_version_num  IGS_GR_GRADUAND_ALL.sur_for_crs_version_number%TYPE ,
  p_sur_for_award_cd  IGS_GR_GRADUAND_ALL.sur_for_award_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- grdp_val_gr_sur_caw
  DECLARE
  	v_gst_s_graduand_status		IGS_GR_STAT.s_graduand_status%TYPE;
  	cst_graduated			CONSTANT VARCHAR2(9) := 'GRADUATED';
  	cst_surrender			CONSTANT VARCHAR2(9) := 'SURRENDER';
  	v_sca_exists			CHAR(1);
  	CURSOR c_gst IS
  		SELECT	gst.s_graduand_status
  		FROM	IGS_GR_STAT gst
  		WHERE	gst.graduand_status = p_graduand_status;
  	CURSOR c_sca IS
  		SELECT	'x'
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.person_id = p_person_id AND
  			sca.course_cd = p_sur_for_course_cd AND
  			sca.version_number = p_sur_for_crs_version_num;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	--1. Check parameters
  	IF p_person_id IS NULL OR
     		p_course_cd IS NULL OR
     		p_graduand_status IS NULL OR
     		p_sur_for_course_cd IS NULL OR
  		p_sur_for_crs_version_num IS NULL OR
  		p_sur_for_award_cd IS NULL THEN
  		RETURN TRUE;
  	END IF;
  	--2. Validate surrending for course is not the same as the
  	--   surrendering course
  	IF p_sur_for_course_cd = p_course_cd THEN
  		p_message_name := 'IGS_GR_CANNOT_SUBMIT_SAME_COU';
  		RETURN FALSE;
  	END IF;
  	--3. When surrendering check the 'surrender for' course matches a
  	--   student course attempt belonging to the graduand
  	OPEN c_gst;
  	FETCH c_gst INTO v_gst_s_graduand_status;
  	IF c_gst%NOTFOUND THEN
  		CLOSE c_gst;
  		RAISE NO_DATA_FOUND;
  	END IF;
  	CLOSE c_gst;
  	IF v_gst_s_graduand_status IN(
  				cst_graduated,
  				cst_surrender) THEN
  		-- check a related student course attempt exist
  		OPEN c_sca;
  		FETCH c_sca INTO v_sca_exists;
  		IF c_sca%NOTFOUND THEN
  			CLOSE c_sca;
  			p_message_name := 'IGS_GR_INVALID_COURSE_ATTEMPT';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_sca;
  	END IF;
  	--4.	Return no error
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_gst %ISOPEN THEN
  			CLOSE c_gst;
  		END IF;
  		IF c_sca %ISOPEN THEN
  			CLOSE c_sca;
  		END IF;
  		RAISE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
       		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       		IGS_GE_MSG_STACK.ADD;
       		App_Exception.Raise_Exception;
  END grdp_val_gr_sur_caw;
END IGS_GR_VAL_GR;

/
