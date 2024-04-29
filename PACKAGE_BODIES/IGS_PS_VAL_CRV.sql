--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_CRV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_CRV" AS
 /* $Header: IGSPS34B.pls 120.2 2006/07/25 15:10:23 sommukhe noship $ */


/* WHO        WHEN         WHAT
sommukhe      19-Jul-2006  Bug#5343926,CIP Design Cganges forward prted from 115.
sommukhe      16-FEB-2006  Bug#3094371, replaced IGS_OR_UNIT by igs_or_inst_org_base_v for cursor c_get_s_org_status in function crsp_val_ou_sys_sts
sarakshi      23-Feb-2003  Enh#2797116,Modified the cursor c_course_offfering_option in crsp_val_crv_quality
                           procedure
*/
   -- Validate IGS_PS_COURSE version government special IGS_PS_COURSE type.
  FUNCTION crsp_val_crv_gsct(
  p_govt_special_course_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind		IGS_PS_GOVT_SPL_TYPE.closed_ind%TYPE;
  	CURSOR	c_govt_special_course_type IS
  		SELECT closed_ind
  		FROM   IGS_PS_GOVT_SPL_TYPE
  		WHERE  govt_special_course_type = p_govt_special_course_type;
  BEGIN
  	OPEN c_govt_special_course_type;
  	FETCH c_govt_special_course_type INTO v_closed_ind;
  	IF c_govt_special_course_type%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_govt_special_course_type;
  		RETURN TRUE;
  	ELSIF (v_closed_ind = 'N') THEN
  		p_message_name := NULL;
  		CLOSE c_govt_special_course_type;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_GOVT_SPLPRGTYPE_CLOSED';
  		CLOSE c_govt_special_course_type;
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CRV.crsp_val_crv_gsct');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_crv_gsct;
  --
  -- Validate IGS_PS_COURSE version IGS_PS_COURSE type.
  FUNCTION crsp_val_crv_type(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_course_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              :
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     smvk     03-Jun-2003   Bug # 2858436. Modified the cursor c_course_award_rec to select open program awards only.
   ***************************************************************/

  	v_closed_ind		IGS_PS_TYPE.closed_ind%TYPE;
  	v_award_course_ind	IGS_PS_TYPE.award_course_ind%TYPE;
  	v_course_award_rec	IGS_PS_AWARD%ROWTYPE;
  	CURSOR	c_course_type IS
  		SELECT	closed_ind,
  			award_course_ind
  		FROM   	IGS_PS_TYPE
  		WHERE  	course_type = p_course_type;
  	CURSOR 	c_course_award_rec IS
  		SELECT 	*
  		FROM	IGS_PS_AWARD
  		WHERE	course_cd = p_course_cd AND
  			version_number = p_version_number AND
                        CLOSED_IND = 'N';
  BEGIN
  	-- validating the IGS_PS_VER.IGS_PS_TYPE
  	OPEN c_course_type;
  	FETCH c_course_type INTO v_closed_ind, v_award_course_ind;
  	IF c_course_type%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_course_type;
  		RETURN TRUE;
  	END IF;
  	IF (v_closed_ind = 'Y') THEN
  		p_message_name := 'IGS_PS_PRGTYPE_CLOSED';
  		CLOSE c_course_type;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_course_type;
  	-- validating the IGS_PS_COURSE IGS_PS_AWDs
  	OPEN c_course_award_rec;
  	FETCH c_course_award_rec INTO v_course_award_rec;
  	IF (c_course_award_rec%NOTFOUND) THEN
  		p_message_name := NULL;
  		CLOSE c_course_award_rec;
  		RETURN TRUE;
  	END IF;
  	IF (c_course_award_rec%FOUND) THEN
  		IF (v_award_course_ind = 'Y') THEN
  			p_message_name := NULL;
  			CLOSE c_course_award_rec;
  			RETURN TRUE;
  		ELSE
  			p_message_name := 'IGS_PS_PRGAWARD_EXISTS_FORPRG';
  			CLOSE c_course_award_rec;
  			RETURN FALSE;
  		END IF;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CRV.crsp_val_crv_type');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_crv_type;


  -- Validate organisational IGS_PS_UNIT system status is ACTIVE
  FUNCTION crsp_val_ou_sys_sts(
  p_org_unit_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_s_org_status	IGS_OR_STATUS.s_org_status%TYPE;
  	CURSOR c_get_s_org_status IS
  		SELECT s_org_status
  		FROM	igs_or_inst_org_base_v,
  			IGS_OR_STATUS
  		WHERE	party_number		= p_org_unit_cd		AND
  			start_dt			= p_start_dt		AND
  			igs_or_inst_org_base_v.org_status	= IGS_OR_STATUS.org_status;
  BEGIN
  	-- Validate organisational IGS_PS_UNIT system status.
  	p_message_name := NULL;
  	OPEN c_get_s_org_status;
  	FETCH c_get_s_org_status INTO v_s_org_status;
  	IF c_get_s_org_status%NOTFOUND THEN
  		CLOSE c_get_s_org_status;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_get_s_org_status;
  	IF (v_s_org_status <> 'INACTIVE') THEN
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_ORGUNIT_STATUS_INACTIV';
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CRV.crsp_val_ou_sys_sts');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_ou_sys_sts;
  --
  -- Validate the IGS_PS_COURSE version end date and status.
  FUNCTION crsp_val_crv_end_sts(
  p_end_dt IN DATE ,
  p_course_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_s_course_status	IGS_PS_STAT.s_course_status%TYPE;
  	CURSOR c_get_s_course_status IS
  		SELECT s_course_status
  		FROM	IGS_PS_STAT
  		WHERE course_status = p_course_status;
  BEGIN
  	p_message_name := NULL;
  	OPEN c_get_s_course_status;
  	FETCH c_get_s_course_status INTO v_s_course_status;
  	IF c_get_s_course_status%NOTFOUND THEN
  		CLOSE c_get_s_course_status;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_get_s_course_status;
  	-- Validate end date and IGS_PS_COURSE status.
  	IF (p_end_dt IS NOT NULL) THEN
  		IF (v_s_course_status = 'INACTIVE') THEN
  			RETURN TRUE;
  		ELSE
  			p_message_name := 'IGS_PS_STSET_INACTIVE_ENDDT';
  			RETURN FALSE;
  		END IF;
  	ELSE -- p_end_dt is null
  		IF (v_s_course_status <> 'INACTIVE') THEN
  			RETURN TRUE;
  		ELSE
  			p_message_name := 'IGS_PS_STNOTSET_INACTIVE_OPDT';
  			RETURN FALSE;
  		END IF;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CRV.crsp_val_crv_end_sts');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_crv_end_sts;
  --
  -- Validate IGS_PS_COURSE version expiry date and status
  FUNCTION crsp_val_crv_exp_sts(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_expiry_dt IN DATE ,
  p_course_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_s_course_status	IGS_PS_STAT.s_course_status%TYPE;
  	v_check		CHAR;
  	CURSOR c_get_s_course_status IS
  		SELECT s_course_status
  		FROM	IGS_PS_STAT
  		WHERE course_status = p_course_status;
  	CURSOR c_check_cv_cs IS
  		SELECT 'x'
  		FROM	IGS_PS_VER	cv,
  			IGS_PS_STAT	cs
  		WHERE
  			course_cd 		 = p_course_cd 		AND
  			version_number		<> p_version_number	AND
  			expiry_dt		IS NULL			AND
  			cv.course_status	 = cs.course_status	AND
  			cs.s_course_status	 = 'ACTIVE';
  BEGIN
  	p_message_name := NULL;
  	OPEN c_get_s_course_status;
  	FETCH c_get_s_course_status INTO v_s_course_status;
  	IF c_get_s_course_status%NOTFOUND THEN
  		CLOSE c_get_s_course_status;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_get_s_course_status;
  	-- Validate expiry date and IGS_PS_COURSE status.
  	IF (v_s_course_status = 'ACTIVE') AND (p_expiry_dt IS NULL) THEN
  		OPEN c_check_cv_cs;
  		FETCH c_check_cv_cs INTO v_check;
  		IF c_check_cv_cs%FOUND THEN
  			CLOSE c_check_cv_cs;
  			p_message_name := 'IGS_PS_ANOTHER_VERSION_EXISTS';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_check_cv_cs;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CRV.crsp_val_crv_exp_sts');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_crv_exp_sts;
  --
  -- Validate the IGS_PS_COURSE version status.
  FUNCTION crsp_val_crv_status(
  p_new_course_status IN VARCHAR2 ,
  p_old_course_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_s_course_status_new		IGS_PS_STAT.s_course_status%TYPE;
  	v_s_course_status_old		IGS_PS_STAT.s_course_status%TYPE;
  	v_closed_ind			IGS_PS_STAT.closed_ind%TYPE;
  	cst_planned			CONSTANT VARCHAR2(8) := 'PLANNED';
  	CURSOR 	c_course_status (cp_course_status IGS_PS_STAT.course_status%TYPE) IS
  		SELECT 	closed_ind,
  			s_course_status
  		FROM   	IGS_PS_STAT
  		WHERE  	course_status = cp_course_status;
  BEGIN
  	-- Validating the closed indicator
  	OPEN c_course_status(p_new_course_status);
  	FETCH c_course_status INTO v_closed_ind, v_s_course_status_new;
  	IF (v_closed_ind = 'Y') THEN
  		p_message_name := 'IGS_PS_PRGSTATUS_CLOSED';
  		CLOSE c_course_status;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_course_status;
  	-- Validating whether IGS_PS_VER.IGS_PS_STAT isn't being changed
  	-- from 'ACTIVE' or 'INACTIVE' to 'PLANNED'.  This is only checked when
  	-- IGS_PS_VER.IGS_PS_STAT
  	-- is being updated.
  	IF (p_old_course_status IS NOT NULL) AND
  	    (p_new_course_status <> p_old_course_status) THEN
  		OPEN c_course_status(p_old_course_status);
  		FETCH c_course_status INTO v_closed_ind, v_s_course_status_old;
  		IF (v_s_course_status_new <> v_s_course_status_old) THEN
  			IF (v_s_course_status_new = cst_planned) THEN
  				p_message_name := 'IGS_PS_PRGSTATUS_NOT_ALTERED';
  				CLOSE c_course_status;
  				RETURN FALSE;
  			END IF;
  		END IF;
  		CLOSE c_course_status;
  	END IF;
  	-- Validating whether p_new_course_status is 'PLANNED' when
  	-- p_old_course_status system IGS_PS_COURSE status isn't set.
  	IF (p_old_course_status IS NULL) AND
  	    (v_s_course_status_new <> cst_planned) THEN
  		p_message_name := 'IGS_PS_NEWVER_STATUS_PLANNED';
  		RETURN FALSE;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CRV.crsp_val_crv_status');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_crv_status;
  --
  -- Perform quality validation checks on a IGS_PS_COURSE version and its details.
  FUNCTION CRSP_VAL_CRV_QUALITY(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_old_course_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
   /***************************************************************
     Created By           :
     Date Created By      :
     Purpose              :
     Known Limitations,Enhancements or Remarks:
     Change History       :
     Who       When         What
     smvk     03-Jun-2003   Bug # 2858436. Modified the cursor c_get_award_cd to select open program awards only.
     skpandey 10-Jul-2006   Bug#5343912,removed the validation of 100% Field of study as this was used as check for updating status to active.
   ***************************************************************/

	v_cv_rec		IGS_PS_VER%ROWTYPE;
  	v_award_cd		IGS_PS_AWARD.award_cd%TYPE;
  	v_funding_source	IGS_FI_FND_SRC_RSTN.funding_source%TYPE;
  	v_award_course_ind	IGS_PS_TYPE.award_course_ind%TYPE;
  	v_field_of_study	IGS_PS_FIELD_STUDY.field_of_study%TYPE;
  	v_course_cat		IGS_PS_CATEGORISE.course_cat%TYPE;
  	v_s_course_status	IGS_PS_STAT.s_course_status%TYPE;
  	v_terminate		BOOLEAN := FALSE;
  	v_coo_exist		BOOLEAN := FALSE;
  	CURSOR c_course_version	IS
  		SELECT *
  		FROM	IGS_PS_VER
  		WHERE	course_cd 	= p_course_cd	AND
  			version_number	= p_version_number;
  	CURSOR c_get_award_course_ind (
  			cp_course_type	IGS_PS_VER.course_type%TYPE) IS
  		SELECT 	award_course_ind
  		FROM	IGS_PS_TYPE
  		WHERE course_type = cp_course_type;
  	CURSOR c_get_award_cd IS
  		SELECT 	award_cd
  		FROM	IGS_PS_AWARD
  		WHERE	course_cd 	= p_course_cd	AND
  			version_number	= p_version_number AND
                        CLOSED_IND = 'N';
  	CURSOR c_get_funding_source IS
  		SELECT	funding_source
  		FROM	IGS_FI_FND_SRC_RSTN
  		WHERE	course_cd	= p_course_cd	AND
  			version_number	= p_version_number;
  	CURSOR c_get_field_of_study IS
  		SELECT field_of_study
  		FROM	IGS_PS_FIELD_STUDY
  		WHERE	course_cd 	= p_course_cd	AND
  			version_number	= p_version_number;
  	CURSOR c_get_course_cat IS
  		SELECT	course_cat
  		FROM	IGS_PS_CATEGORISE
  		WHERE	course_cd 	= p_course_cd	AND
  			version_number	= p_version_number;
  	CURSOR c_get_reference_cd_type IS
  		SELECT reference_cd_type
  		FROM	IGS_PS_REF_CD
  		WHERE	course_cd	= p_course_cd	AND
  			version_number	= p_version_number;
  	CURSOR c_get_course_group_cd IS
  		SELECT	course_group_cd
  		FROM	IGS_PS_GRP_MBR
  		WHERE	course_cd	= p_course_cd	AND
  			version_number	= p_version_number;
  	CURSOR c_course_annual_load_unit_link IS
  		SELECT 	unit_cd,
  			uv_version_number
  		FROM	IGS_PS_ANL_LOAD_U_LN
  		WHERE	course_cd		= p_course_cd	AND
  			crv_version_number	=p_version_number;
  	CURSOR c_get_cal_type IS
  		SELECT cal_type
  		FROM	IGS_PS_OFR
  		WHERE	course_cd	= p_course_cd	AND
  			version_number	= p_version_number;
  	CURSOR c_course_offering_option IS
  		SELECT	location_cd,
  			attendance_type,
  			attendance_mode
  		FROM	IGS_PS_OFR_OPT
  		WHERE	course_cd	= p_course_cd	AND
  			version_number	= p_version_number AND
                        delete_flag = 'N';
  	CURSOR c_get_dist_reference_cd_type IS
  		SELECT DISTINCT reference_cd_type
  		FROM	IGS_PS_ENT_PT_REF_CD
  		WHERE	course_cd	= p_course_cd	AND
  			version_number	= p_version_number;
  	CURSOR c_get_s_course_status IS
  		SELECT	s_course_status
  		FROM	IGS_PS_STAT
  		WHERE	course_status 	= p_old_course_status;
  	CURSOR c_course_offering_instance IS
  		SELECT cal_type, ci_sequence_number
  		FROM	IGS_PS_OFR_INST
  		WHERE	course_cd	= p_course_cd		AND
  			version_number	= p_version_number;
  BEGIN
  	OPEN c_course_version;
  	FETCH c_course_version INTO v_cv_rec;
  	-- no IGS_PS_VER found
  	IF (c_course_version%NOTFOUND) THEN
  		CLOSE c_course_version;
  		p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_course_version;
  	-- Validate that there is only one funding_source_resstriction table
  	-- set to default for a IGS_PS_COURSE version.
  	IF (IGS_PS_VAL_FSr.crsp_val_fsr_default (
  			p_course_cd,
  			p_version_number,
  			p_message_name) = FALSE) THEN
  		RETURN FALSE;
  	END IF;
  	-- validate that all records have there restriction indicator set.
  	IF (IGS_PS_VAL_FSr.crsp_val_fsr_rstrct (
  			p_course_cd,
  			p_version_number,
  			p_message_name) = FALSE) THEN
  		RETURN FALSE;
  	END IF;
  	-- Validate that IGS_PS_GOVT_SPL_TYPE is not closed
  	IF (IGS_PS_VAL_CRV.crsp_val_crv_gsct(
  			v_cv_rec.govt_special_course_type,
  			p_message_name) = FALSE) THEN
  		RETURN FALSE;
  	END IF;
  	-- Validate the IGS_PS_TYPE is not closed
  	IF (IGS_PS_VAL_CRV.crsp_val_crv_type(
  			p_course_cd,
  			p_version_number,
  			v_cv_rec.course_type,
  			p_message_name) = FALSE) THEN
  		RETURN FALSE;
  	END IF;
  	-- Validate that the responsible_org_unit_cd is active
  	IF (IGS_PS_VAL_CRV.crsp_val_ou_sys_sts(
  			v_cv_rec.responsible_org_unit_cd,
  			v_cv_rec.responsible_ou_start_dt,
  			p_message_name) = FALSE) THEN
  		RETURN FALSE;
  	END IF;
  	-- Validate the IGS_PS_FIELD_STUDY record percentage of total 100%. Removed Code

  	-- Validate the IGS_PS_OWN record percentage total 100%
  	IF (IGS_PS_VAL_COw.crsp_val_cow_perc(
  			p_course_cd,
  			p_version_number,
  			p_message_name) = FALSE) THEN
  		RETURN FALSE;
  	END IF;
  	OPEN c_get_award_course_ind(v_cv_rec.course_type);
  	FETCH c_get_award_course_ind INTO v_award_course_ind;
  	CLOSE c_get_award_course_ind;
  	-- If IGS_PS_VER is an IGS_PS_AWD IGS_PS_COURSE, check that the IGS_PS_AWD is open
  	-- and that the IGS_PS_AWD_OWN percentages total 100% for
  	-- a IGS_PS_VER IGS_PS_AWD
  	IF (v_award_course_ind = 'Y') THEN
  		OPEN c_get_award_cd;
  		LOOP
  			FETCH c_get_award_cd INTO v_award_cd;
  			EXIT WHEN c_get_award_cd%NOTFOUND;
  			IF (IGS_PS_VAL_CAW.crsp_val_caw_award(
  					v_award_cd,
  					p_message_name) = FALSE) THEN
  				v_terminate := TRUE;
  				EXIT;
  			END IF;
  			IF (IGS_PS_VAL_CAO.crsp_val_cao_perc(
  					p_course_cd,
  					p_version_number,
  					v_award_cd,
  					p_message_name) = FALSE) THEN
  				v_terminate := TRUE;
  				EXIT;
  			END IF;
  		END LOOP;
  		IF (v_terminate = TRUE) THEN
  			CLOSE c_get_award_cd;
  			RETURN FALSE;
  		END IF;
  		-- IGS_PS_VER is an IGS_PS_AWD IGS_PS_COURSE and no record exist in the
  		-- IGS_PS_AWARD table for p_course_cd and p_version_number
  		IF (c_get_award_cd%ROWCOUNT = 0) THEN
  			CLOSE c_get_award_cd;
  			p_message_name := 'IGS_PS_PRGVER_AWARDPRG';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_get_award_cd;
  	END IF; -- course_award_ind is 'Y'
  	-- Validate the IGS_FI_FND_SRC_RSTN table and that the
  	-- IGS_FI_FUND_SRC is not closed.
  	FOR fs_rec IN c_get_funding_source LOOP
  		IF (IGS_PS_VAL_FSr.crsp_val_fsr_fnd_src(
  				fs_rec.funding_source,
  				p_message_name) = FALSE) THEN
  			v_terminate := TRUE;
  			EXIT; -- premature exit loop
  		END IF;
  	END LOOP;
  	IF (v_terminate = TRUE) THEN
  		RETURN FALSE;
  	END IF;
  	-- validate the IGS_PS_FIELD_STUDY table and that the
  	-- IGS_PS_FLD_OF_STUDY is not closed
  	FOR fos_rec IN c_get_field_of_study LOOP
  		IF (IGS_PS_VAL_CFOS.crsp_val_cfos_fos(
  				fos_rec.field_of_study,
  				p_message_name) = FALSE) THEN
  			v_terminate := TRUE;
  			EXIT; -- premature exit loop
  		END IF;
  	END LOOP;
  	IF (v_terminate = TRUE) THEN
  		RETURN FALSE;
  	END IF;
  	-- Validate the IGS_PS_CATEGORISE table and
  	-- that IGS_PS_CAT is not closed
  	FOR cc_rec IN c_get_course_cat LOOP
  		IF (IGS_PS_VAL_CRC.crsp_val_crc_crs_cat(
  				cc_rec.course_cat,
  				p_message_name) = FALSE) THEN
  			v_terminate := TRUE;
  			EXIT; -- premature exit loop
  		END IF;
  	END LOOP;
  	IF (v_terminate = TRUE) THEN
  		RETURN FALSE;
  	END IF;
  	-- Validate the IGS_PS_REF_CD table and that
  	-- IGS_GE_REF_CD_TYPE is not closed
  	FOR crc_rec IN c_get_reference_cd_type LOOP
  		IF (IGS_PS_VAL_CRFC.crsp_val_ref_cd_type(
  				crc_rec.reference_cd_type,
  				p_message_name) = FALSE) THEN
  			v_terminate := TRUE;
  			EXIT; -- premature exit loop
  		END IF;
  	END LOOP;
  	IF (v_terminate = TRUE) THEN
  		RETURN FALSE;
  	END IF;
  	-- Validate the IGS_PS_GRP_MBR table and that
  	-- course_group_cd is not closed.
  	FOR cgm_rec IN c_get_course_group_cd LOOP
  		IF (IGS_PS_VAL_CGM.crsp_val_cgm_crs_grp(
  				cgm_rec.course_group_cd,
  				p_message_name) = FALSE) THEN
  			v_terminate := TRUE;
  			EXIT; -- premature exit loop
  		END IF;
  	END LOOP;
  	IF (v_terminate = TRUE) THEN
  		RETURN FALSE;
  	END IF;
  	-- Validate that if IGS_PS_ANL_LOAD_U_LN records exist,
  	-- check that the associated IGS_PS_UNIT version(s) is not inactive
  	FOR calul_rec IN c_course_annual_load_unit_link LOOP
  		IF (IGS_PS_VAL_CALul.crsp_val_uv_sys_sts(
  				calul_rec.unit_cd,
  				calul_rec.uv_version_number,
  				p_message_name) = FALSE) THEN
  			v_terminate := TRUE;
  			EXIT; -- premature exit loop
  		END IF;
  	END LOOP;
  	IF (v_terminate = TRUE) THEN
  		RETURN FALSE;
  	END IF;
  	OPEN c_get_s_course_status;
  	FETCH c_get_s_course_status INTO v_s_course_status;
  	-- no IGS_PS_STAT found
  	IF (c_get_s_course_status%NOTFOUND) THEN
  		CLOSE c_get_s_course_status;
  		p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_get_s_course_status;
  	IF (v_s_course_status = 'PLANNED') THEN
  		-- Validate that if IGS_PS_OFR records exist,
  		-- check that the IGS_CA_TYPE is not closed
  		FOR co_rec IN c_get_cal_type LOOP
  			IF (IGS_PS_VAL_CO.crsp_val_co_cal_type(
  					co_rec.cal_type,
  					p_message_name) = FALSE) THEN
  				v_terminate := TRUE;
  				EXIT; -- premature exit loop
  			END IF;
  		END LOOP;
  		IF (v_terminate = TRUE) THEN
  			RETURN FALSE;
  		END IF;
  		-- Validate IGS_PS_OFR_OPT record(s) if it exists and
  		-- the closed indicators associated with the fields of the record
  		FOR coo_rec IN c_course_offering_option LOOP
  		-- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_COO.crsp_val_loc_cd
  			IF (IGS_PS_VAL_UOO.crsp_val_loc_cd(
  					coo_rec.location_cd,
  					p_message_name) = FALSE) THEN
  				v_terminate := TRUE;
  				EXIT; -- premature exit loop
  			END IF;
  			IF (IGS_PS_VAL_COo.crsp_val_coo_am(
  					coo_rec.attendance_mode,
  					p_message_name) = FALSE) THEN
  				v_terminate := TRUE;
  				EXIT; -- premature exit loop
  			END IF;
  			IF (IGS_PS_VAL_COo.crsp_val_coo_att(
  					coo_rec.attendance_type,  					p_message_name) = FALSE) THEN
  				v_terminate := TRUE;
  				EXIT; -- premature exit loop
  			END IF;
  			v_coo_exist := TRUE;
  		END LOOP;
  		IF (v_terminate = TRUE) THEN
  			RETURN FALSE;
  		END IF;
  		-- Validate IGS_PS_ENT_PT_REF_CD record(s) if
  		-- it exists and that IGS_GE_REF_CD_TYPE is not closed.
  		-- Validate IGS_PS_OFR_INST record(s) if
  		-- it exists and the IGS_CA_INST.IGS_CA_STAT is ACTIVE.
  		-- Only perform these if course_offering_records exist.
  		IF (v_coo_exist = TRUE) THEN
  			FOR ceprc_rec IN c_get_dist_reference_cd_type LOOP
  			-- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_CEPRC.crsp_val_ref_cd_type
  				IF (IGS_PS_VAL_CRFC.crsp_val_ref_cd_type(
  						ceprc_rec.reference_cd_type,
  						p_message_name) = FALSE) THEN
  					v_terminate := TRUE;
  					EXIT; -- premature exit loop
  				END IF;
  			END LOOP;
  			IF (v_terminate = TRUE) THEN
  				RETURN FALSE;
  			END IF;
  			FOR coi_rec IN c_course_offering_instance LOOP
  				IF (IGS_as_VAL_uai.crsp_val_crs_ci(
  						coi_rec.cal_type,
  						coi_rec.ci_sequence_number,
  						p_message_name) = FALSE) THEN
  					v_terminate := TRUE;
  					EXIT;
  				END IF;
  			END LOOP;
  			IF (v_terminate = TRUE) THEN
  				RETURN FALSE;
  			END IF;
  		END IF; -- v_coo_exist = TRUE
  	END IF; -- v_s_course_status = 'PLANNED'
  	-- Validation successfull
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CRV.crsp_val_crv_quality');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
   END crsp_val_crv_quality;
  --
  -- Validate that a IGS_PS_COURSE version can end, looking at sca status
  FUNCTION crsp_val_crv_end(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_return_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_crv_end
  	-- Perform checks required prior to the 'ending' of a IGS_PS_COURSE version, being:
  	-- - no IGS_PS_COURSE attempts can be linked to the version with a status in
  	--   'Enrolled', 'Inactive', 'Intermitted',
  	--  A warning is produced if a IGS_PS_COURSE attempt exists with a status of
  	-- 'Lapsed' or 'Unconfirmed'.
  DECLARE
  	cst_enrolled	CONSTANT
  					IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'ENROLLED';
  	cst_inactive	CONSTANT
  					IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'INACTIVE';
  	cst_intermit	CONSTANT
  					IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'INTERMIT';
  	cst_lapsed	CONSTANT
  					IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'LAPSED';
  	cst_unconfirm	CONSTANT
  					IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'UNCONFIRM';
  	cst_error		CONSTANT	VARCHAR2(1) := 'E';
  	cst_warning	CONSTANT	VARCHAR2(1) := 'W';
  	v_dummy		VARCHAR2(1);
  	CURSOR c_sca1 IS
  		SELECT	'X'
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.course_cd = p_course_cd AND
  			sca.version_number = p_version_number AND
  			sca.course_attempt_status IN (
  						cst_enrolled,
  						cst_inactive,
  						cst_intermit);
  	CURSOR c_sca2 IS
  		SELECT	'X'
  		FROM	IGS_EN_STDNT_PS_ATT	sca
  		WHERE	sca.course_cd = p_course_cd AND
  			sca.version_number = p_version_number AND
  			sca.course_attempt_status IN (
  						cst_lapsed,
  						cst_unconfirm);
  BEGIN
  	OPEN c_sca1;
  	FETCH c_sca1 INTO v_dummy;
  	IF (c_sca1%FOUND) THEN
  		CLOSE c_sca1;
  		p_return_type := cst_error;
  		p_message_name := 'IGS_PS_ENDPRG_ENROLLED_INACTV';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_sca1;
  	OPEN c_sca2;
  	FETCH c_sca2 INTO v_dummy;
  	IF (c_sca2%FOUND) THEN
  		CLOSE c_sca2;
  		p_return_type := cst_warning;
  		p_message_name := 'IGS_PS_LAPSED_UNCONFIRMED_LIN';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_sca2;
  	p_return_type := NULL;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_sca1%ISOPEN) THEN
  			CLOSE c_sca1;
  		END IF;
  		IF (c_sca2%ISOPEN) THEN
  			CLOSE c_sca2;
  		END IF;
  		APP_EXCEPTION.RAISE_EXCEPTION;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_VAL_CRV.crsp_val_crv_end');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
  END crsp_val_crv_end;
END IGS_PS_VAL_CRV;

/
