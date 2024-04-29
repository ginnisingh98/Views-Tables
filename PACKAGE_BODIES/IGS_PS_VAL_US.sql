--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_US
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_US" AS
/* $Header: IGSPS68B.pls 115.6 2002/11/29 03:09:51 nsidana ship $ */
/*change history:
 who        when       what
sarakshi    14-nov-2002    bug#2649028,modified function crsp_val_ver_dt,added parameter p_lgcy_validator
                           and corresponding validations
vvutukur    08-apr-2002    modifications done in crsp_val_us_category for bug#2121770.*/
  --
  -- Validate the IGS_PS_UNIT set status closed indicator.
  FUNCTION crsp_val_uss_closed(
  p_unit_set_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_uss_closed
  	-- Validate the IGS_PS_UNIT set status closed indicator
  DECLARE
  	v_closed_ind		IGS_EN_UNIT_SET_STAT.closed_ind%TYPE;
  	CURSOR c_uss IS
  		SELECT	uss.closed_ind
  		FROM	IGS_EN_UNIT_SET_STAT	uss
  		WHERE	uss.unit_set_status = p_unit_set_status;
  BEGIN
  	OPEN c_uss;
  	FETCH c_uss INTO v_closed_ind;
  	IF (c_uss%NOTFOUND) THEN
  		CLOSE c_uss;
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_uss;
  	IF (v_closed_ind = 'Y') THEN
  		p_message_name := 'IGS_PS_UNIT_SET_STATUS_CLOSED';
  		RETURN FALSE;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_uss%ISOPEN) THEN
  			CLOSE c_uss;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_US.crsp_val_uss_closed');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END crsp_val_uss_closed;
  --
  -- Validate the IGS_PS_UNIT set category closed indicator.
  FUNCTION crsp_val_usc_closed(
  p_unit_set_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN   --crsp_val_usc_closed
          -- Validate the IGS_PS_UNIT set closed closed indicator
  DECLARE
          v_closed_ind        IGS_EN_UNIT_SET_CAT.closed_ind%TYPE;
  	CURSOR c_usc IS
  	SELECT  usc.closed_ind
  	FROM    IGS_EN_UNIT_SET_CAT    usc
  	WHERE   usc.unit_set_cat = p_unit_set_cat;
  BEGIN
  	--set default message number
  	p_message_name := NULL;
          OPEN c_usc;
          FETCH c_usc INTO v_closed_ind;
          IF (c_usc%NOTFOUND) THEN
                CLOSE c_usc;
                RETURN TRUE;
          END IF;
          CLOSE c_usc;
          IF (v_closed_ind = 'Y') THEN
  		p_message_name := 'IGS_PS_UNIT_SET_CAT_CLOSED';
                	RETURN FALSE;
          END IF;
          RETURN TRUE ;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_usc%ISOPEN) THEN
  	     		CLOSE c_usc;
         		END IF;
  		App_Exception.Raise_Exception;
  END;
  	EXCEPTION
  		WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_US.crsp_val_usc_closed');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END crsp_val_usc_closed;
  --
  -- Validate version dates for IGS_PS_COURSE and IGS_PS_UNIT versions.
  FUNCTION crsp_val_ver_dt(
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_lgcy_validator IN BOOLEAN)
  RETURN BOOLEAN AS
  l_ret_status   BOOLEAN :=TRUE;
  BEGIN
  	IF (p_end_dt IS NOT NULL) AND (p_start_dt IS NOT NULL) THEN
  		IF (p_end_dt < p_start_dt) THEN
                  IF p_lgcy_validator THEN
                    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_VERENDDT_GE_VERSTARTDT',NULL,NULL,FALSE);
                    l_ret_status:=FALSE;
                  ELSE
  		    p_message_name := 'IGS_PS_VERENDDT_GE_VERSTARTDT';
  		    RETURN FALSE;
                  END IF;
  		END IF;
  	END IF;
  	IF (p_end_dt IS NOT NULL) AND (p_expiry_dt IS NOT NULL) THEN
  		IF (p_end_dt < p_expiry_dt) THEN
                  IF p_lgcy_validator THEN
                    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_VER_ENDDT_GE_VER_EXPDT',NULL,NULL,FALSE);
                    l_ret_status:=FALSE;
                  ELSE
  		    p_message_name := 'IGS_PS_VER_ENDDT_GE_VER_EXPDT';
  		    RETURN FALSE;
                  END IF;
  		END IF;
  	END IF;
  	IF (p_start_dt IS NOT NULL) AND (p_expiry_dt IS NOT NULL) THEN
  		IF (p_expiry_dt < p_start_dt) THEN
                  IF p_lgcy_validator THEN
                    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_VER_EXPDT_GE_VER_STDT',NULL,NULL,FALSE);
                    l_ret_status:=FALSE;
                  ELSE
  		    p_message_name := 'IGS_PS_VER_EXPDT_GE_VER_STDT';
  		    RETURN FALSE;
                  END IF;
  		END IF;
  	END IF;

        IF p_lgcy_validator THEN
  	  p_message_name := NULL;
  	  RETURN l_ret_status;
        ELSE
  	  p_message_name := NULL;
  	  RETURN TRUE;
        END IF;
  EXCEPTION
  	WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_US.crsp_val_ver_dt');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END crsp_val_ver_dt;
  --
  -- Validate IGS_PS_UNIT set end date and IGS_PS_UNIT set status
  FUNCTION crsp_val_us_end_sts(
  p_end_dt IN DATE ,
  p_unit_set_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_us_end_sts
  	-- This module performs cross-field validation on the IGS_PS_UNIT set
  	-- version end date and the IGS_PS_UNIT version status.
  	-- - End date can only be set if the IGS_PS_UNIT set system status is INACTIVE
  DECLARE
  	cst_inactive	CONSTANT	IGS_EN_UNIT_SET_STAT.s_unit_set_status%TYPE := 'INACTIVE';
  	v_s_unit_set_status		IGS_EN_UNIT_SET_STAT.s_unit_set_status%TYPE;
  	CURSOR c_uss IS
  		SELECT	uss.s_unit_set_status
  		FROM	IGS_EN_UNIT_SET_STAT	uss
  		WHERE	uss.unit_set_status = p_unit_set_status;
  BEGIN
  	-- 1. Select the IGS_EN_UNIT_SET_STAT.s_unit_set_status for
  	-- the given p_unit_set_status.
  	OPEN c_uss;
  	FETCH c_uss INTO v_s_unit_set_status;
  	CLOSE c_uss;
  	-- 2. Perform validation when the p_end_dt is set
  	IF (p_end_dt IS NOT NULL) THEN
  		IF (v_s_unit_set_status = cst_inactive) THEN
  			p_message_name := NULL;
  			RETURN TRUE;
  		ELSE
  			p_message_name := 'IGS_PS_STATUS_SET_INACTIVE';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		-- 3. Perform validation when the p_end_dt is not set
  		IF (v_s_unit_set_status <> cst_inactive) THEN
  			p_message_name := NULL;
  			RETURN TRUE;
  		ELSE
  			p_message_name := 'IGS_PS_STATUS_NOTSET_INACTIVE';
  			RETURN FALSE;
  		END IF;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_uss%ISOPEN) THEN
  			CLOSE c_uss;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_US.crsp_val_us_end_sts');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END crsp_val_us_end_sts;
  --
  -- Validate IGS_PS_UNIT set end date and status when active students exist
  FUNCTION crsp_val_us_enr(
  p_unit_set_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_us_enr
  	-- This module validates end date/IGS_PS_UNIT set status of INACTIVE cannot be set
  	-- when there are active students within an offering of the IGS_PS_UNIT set.
  DECLARE
  	cst_enrolled	CONSTANT
  					IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'ENROLLED';
  	cst_intermit	CONSTANT
  					IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'INTERMIT';
  	cst_inactive	CONSTANT
  					IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE := 'INACTIVE';
  	v_course_attempt_status		IGS_EN_STDNT_PS_ATT.course_attempt_status%TYPE;
  	CURSOR c_sca_susa IS
  		SELECT	sca.course_attempt_status
  		FROM	IGS_EN_STDNT_PS_ATT		sca,
  			IGS_AS_SU_SETATMPT	susa
  		WHERE	sca.person_id = susa.person_id AND
  			sca.course_cd = susa.course_cd AND
  			sca.course_attempt_status IN (
  						cst_enrolled,
  						cst_intermit,
  						cst_inactive) AND
  			susa.unit_set_cd		= p_unit_set_cd AND
  			susa.us_version_number		= p_version_number AND
  			susa.student_confirmed_ind	= 'Y';
  BEGIN
  	OPEN c_sca_susa;
  	FETCH c_sca_susa INTO v_course_attempt_status;
  	IF (c_sca_susa%FOUND) THEN
  		CLOSE c_sca_susa;
  		p_message_name := 'IGS_PS_ENDDT_CANNOT_BESET';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_sca_susa;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_sca_susa%ISOPEN) THEN
  			CLOSE c_sca_susa;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
                Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_US.crsp_val_us_enr');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_us_enr;
  --
  -- Validate IGS_PS_UNIT set status changes
  FUNCTION crsp_val_us_status(
  p_old_unit_set_status IN VARCHAR2 ,
  p_new_unit_set_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_us_status
  	-- This module validates the IGS_EN_UNIT_SET.IGS_EN_UNIT_SET_STAT. It is fired at
  	-- item level. The checks are:
  	-- IGS_PS_UNIT_STAT cannot be set back to a system status of 'PLANNED' once
  	-- it is 'ACTIVE' or 'INACTIVE'.
  DECLARE
  	cst_planned	CONSTANT	IGS_EN_UNIT_SET_STAT.s_unit_set_status%TYPE := 'PLANNED';
  	v_new_unit_set_status		IGS_EN_UNIT_SET_STAT.s_unit_set_status%TYPE;
  	v_old_unit_set_status		IGS_EN_UNIT_SET_STAT.s_unit_set_status%TYPE;
  	CURSOR c_uss (
  		cp_unit_set_status	IGS_EN_UNIT_SET_STAT.unit_set_status%TYPE) IS
  		SELECT	uss.s_unit_set_status
  		FROM	IGS_EN_UNIT_SET_STAT	uss
  		WHERE	uss.unit_set_status = cp_unit_set_status;
  BEGIN
  	-- Validate the system status is not being altered to PLANNED from
  	-- ACTIVE or INACTIVE.
  	IF (p_old_unit_set_status IS NOT NULL AND
  			p_new_unit_set_status <> p_old_unit_set_status) THEN
  		-- Fetch new system status
  		OPEN c_uss(
  			p_new_unit_set_status);
  		FETCH c_uss INTO v_new_unit_set_status;
  		CLOSE c_uss;
  		-- Fetch old system status
  		OPEN c_uss(
  			p_old_unit_set_status);
  		FETCH c_uss INTO v_old_unit_set_status;
  		CLOSE c_uss;
  		IF (v_new_unit_set_status <> v_old_unit_set_status AND
  				v_new_unit_set_status = cst_planned) THEN
  			p_message_name := 'IGS_PS_UNIT_SET_STATUS_NOTALT';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_uss%ISOPEN) THEN
  			CLOSE c_uss;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_US.crsp_val_us_status');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END crsp_val_us_status;
  --
  -- Validate IGS_PS_UNIT set expiry date and IGS_PS_UNIT set status
  FUNCTION crsp_val_us_exp_sts(
  p_unit_set_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_unit_set_status IN VARCHAR2 ,
  p_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_us_exp_sts
  	-- This module validates the cross-record validation dependent on the
  	-- IGS_EN_UNIT_SET.expiry_dt and IGS_EN_UNIT_SET.IGS_PS_UNIT_STAT columns.
  	-- . There can only be one version of a IGS_PS_UNIT set which has a system status
  	--    of 'ACTIVE' and the expiry date not set.
  DECLARE
  	cst_active	CONSTANT	VARCHAR2(10) :='ACTIVE';
  	v_dummy		VARCHAR2(1);
  	CURSOR c_uss IS
  		SELECT 'x'
  		FROM	IGS_EN_UNIT_SET_STAT	uss
  		WHERE	uss.unit_set_status	= unit_set_status AND
  			uss.s_unit_set_status	= cst_active;
  	CURSOR c_us_uss IS
  		SELECT 	'X'
  		FROM	IGS_EN_UNIT_SET	us,
  			IGS_EN_UNIT_SET_STAT	uss
  		WHERE	us.unit_set_cd		= p_unit_set_cd		AND
  			us.version_number	<> p_version_number	AND
  			us.expiry_dt		IS NULL			AND
  			us.unit_set_status	= uss.unit_set_status	AND
  		 	uss.s_unit_set_status	= cst_active;
  BEGIN
  	--Set the default message number
  	p_message_name := NULL;
  	-- Check parameters passed in. If the IGS_PS_UNIT set system status (fetch
  	-- s_unit_set_status from IGS_EN_UNIT_SET_STAT table) is ACTIVE and the expiry
  	-- date not set.
  	OPEN c_uss;
  	FETCH c_uss INTO v_dummy;
  	IF c_uss%FOUND THEN
  		CLOSE c_uss;
  		IF p_expiry_dt IS NULL THEN
  			-- Check that no other versions of the IGS_PS_UNIT set exist that have a system
  			-- status of ACTIVE and p_expiry_dt not set
  			OPEN c_us_uss;
  			FETCH c_us_uss INTO v_dummy;
  			IF c_us_uss%FOUND THEN
  				CLOSE c_us_uss;
  				p_message_name := 'IGS_PS_ANOTHERVER_UNITSET_EXI';
  				RETURN FALSE;
  			END IF;
  			CLOSE c_us_uss;
  		END IF;
  	ELSE
  		CLOSE c_uss;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF c_uss%ISOPEN THEN
  			CLOSE c_uss;
  		END IF;
  		IF c_us_uss%ISOPEN THEN
  			CLOSE c_us_uss;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_US.crsp_val_us_exp_sts');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END crsp_val_us_exp_sts;
  --
  -- Validate IGS_PS_UNIT set status for ins/upd/del of IGS_PS_UNIT set details
  FUNCTION crsp_val_iud_us_dtl2(
  p_old_unit_set_status IN VARCHAR2 ,
  p_new_unit_set_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN	-- crsp_val_iud_us_dtl2
  	-- This module validates whether or not inserts and updates can be made to
  	-- IGS_EN_UNIT_SET details
  	-- on the IGS_PS_UNIT set record. It is fired at record level (hence could not be
  	-- incorporated
  	-- in the CRSP_VAL_US_STATUS validation).
  DECLARE
  	v_new_unit_set_status	IGS_EN_UNIT_SET_STAT.s_unit_set_status%TYPE;
  	v_old_unit_set_status	IGS_EN_UNIT_SET_STAT.s_unit_set_status%TYPE;
  	-- Fetch new system status
  	CURSOR c_new_uss IS
  		SELECT	uss.s_unit_set_status
  		FROM 	IGS_EN_UNIT_SET_STAT uss
  		WHERE	uss.unit_set_status = p_new_unit_set_status;
  	-- Fetch old system status
  	CURSOR c_old_uss IS
  		SELECT	uss.s_unit_set_status
  		FROM 	IGS_EN_UNIT_SET_STAT uss
  		WHERE	uss.unit_set_status = p_old_unit_set_status;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	OPEN c_new_uss;
  	FETCH c_new_uss INTO v_new_unit_set_status;
  	OPEN c_old_uss;
  	FETCH c_old_uss INTO v_old_unit_set_status;
  	-- Validate the system status is not being altered when INACTIVE
  	-- unless system status is also being changed (to ACTIVE):
  	IF (c_new_uss%FOUND AND c_old_uss%FOUND) THEN
  		IF v_old_unit_set_status = 'INACTIVE' THEN
  			IF v_new_unit_set_status <> 'ACTIVE' THEN
  				CLOSE c_new_uss;
  				CLOSE c_old_uss;
  				p_message_name := 'IGS_PS_UNIT_SET_INACTIVE';
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END IF;
  	CLOSE c_new_uss;
  	CLOSE c_old_uss;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_new_uss%NOTFOUND) THEN
  			CLOSE c_new_uss;
  		END IF;
  		IF (c_old_uss%NOTFOUND) THEN
  			CLOSE c_old_uss;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_US.crsp_val_iud_us_dtl2');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END crsp_val_iud_us_dtl2;
  --
  --Validate IGS_PS_UNIT set category changes
  FUNCTION crsp_val_us_category(
  p_unit_set_status IN VARCHAR2 ,
  p_old_unit_set_cat IN VARCHAR2 ,
  p_new_unit_set_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
/*  change history:
  who            when             what*/
  BEGIN	-- crsp_val_us_category
  	-- This module provides a warning if the IGS_PS_UNIT set is active
  	-- when the IGS_PS_UNIT set category is being changed.
  DECLARE
  	v_s_unit_set_status	IGS_EN_UNIT_SET_STAT.s_unit_set_status%TYPE;
  	CURSOR c_uss IS
  		SELECT	uss.s_unit_set_status
  		FROM	IGS_EN_UNIT_SET_STAT	uss
  		WHERE	uss.unit_set_status = p_unit_set_status;
  BEGIN
  	-- Set the default message number
  	p_message_name := NULL;
  	IF p_old_unit_set_cat <> p_new_unit_set_cat THEN
  		-- check whether IGS_EN_UNIT_SET_STAT is ACTIVE
  		OPEN c_uss;
  		FETCH c_uss INTO v_s_unit_set_status;
  --if the unit set status is not planned and unit set category is getting changed, throw error message.bug#2121770.
  		IF (c_uss%FOUND) THEN
  			IF v_s_unit_set_status <> 'PLANNED' THEN
  				CLOSE c_uss;
  				p_message_name := 'IGS_PS_UNIT_SET_ACTIVE';
  				RETURN FALSE;
  			END IF;
  		END IF;
  		CLOSE c_uss;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_uss%ISOPEN) THEN
  			CLOSE c_uss;
  		END IF;
  		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
	FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_US.crsp_val_us_category');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  END crsp_val_us_category ;
  --
END IGS_PS_VAL_US;

/
