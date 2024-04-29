--------------------------------------------------------
--  DDL for Package Body IGS_PS_GEN_005
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_GEN_005" AS
/* $Header: IGSPS05B.pls 115.5 2002/11/29 02:54:25 nsidana ship $ */

FUNCTION CRSP_DEL_TRO_HIST(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
	e_resource_busy_exception		EXCEPTION;
	PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
BEGIN	-- crsp_del_tro_hist
	-- This module will delete the history records associated with a
	-- IGS_PS_TCH_RESP_OVRD record.
DECLARE
	CURSOR	c_troh IS
		SELECT	Rowid,unit_cd
		FROM	IGS_PS_TCH_RSOV_HIST troh
		WHERE	troh.unit_cd		= p_unit_cd		AND
			troh.version_number	= p_version_number	AND
			troh.cal_type		= p_cal_type		AND
			troh.ci_sequence_number = p_ci_sequence_number	AND
			troh.location_cd	= p_location_cd		AND
			troh.unit_class		= p_unit_class		AND
			troh.org_unit_cd	= p_org_unit_cd		AND
			troh.ou_start_dt	= p_ou_start_dt
		FOR UPDATE OF unit_cd NOWAIT;
BEGIN
	p_message_name := NULL;

	FOR v_troh_rec IN c_troh LOOP
		-- Delete the current record.

		IGS_PS_TCH_RSOV_HIST_PKG.Delete_Row(X_ROWID => v_troh_rec.Rowid);

	END LOOP;

	-- If processing successful then
	RETURN TRUE;
EXCEPTION
	-- If an exception raised indicating a lock on any of the records in the
	-- select set, then want to handle the exception by returning false and
	-- an error message from this routine.
	WHEN e_resource_busy_exception THEN
		IF (c_troh%ISOPEN) THEN
			CLOSE c_troh;
		END IF;
		p_message_name := 'IGS_PS_UNABLE_TO_DELETE';
		RETURN FALSE;
	WHEN OTHERS THEN
		IF (c_troh%ISOPEN) THEN
			CLOSE c_troh;
		END IF;
		App_Exception.Raise_Exception;
END;
EXCEPTION
	WHEN OTHERS THEN
	Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
	 Fnd_Message.Set_Token('NAME','IGS_PS_GEN_005.CRSP_DEL_TRO_HIST');
	 IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;

END crsp_del_tro_hist;

FUNCTION crsp_ins_calul(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_yr_num IN NUMBER ,
  p_effective_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
BEGIN -- crsp_ins_calul
	-- copy the IGS_PS_COURSE annual load IGS_PS_UNIT links from the most recent dated
	-- IGS_PS_COURSE annual load to the IGS_PS_COURSE annual load passed to this
	-- module.
DECLARE
	v_effective_start_dt	DATE;
	v_unit_cd		IGS_PS_ANL_LOAD_U_LN.unit_cd%TYPE;
	v_uv_version_number	IGS_PS_ANL_LOAD_U_LN.uv_version_number%TYPE;
	v_s_unit_status		IGS_PS_UNIT_STAT.s_unit_status%TYPE;
	v_rec_inserted_cnt	NUMBER(5)	DEFAULT 0;
	CURSOR	c_max_eff_start_dt IS
		SELECT	max(effective_start_dt)
		FROM	IGS_PS_ANL_LOAD
		WHERE	course_cd	= p_course_cd		AND
			version_number	= p_version_number	AND
			yr_num		= p_yr_num 	AND
			effective_start_dt < p_effective_start_dt;
	CURSOR	c_calul (cp_effective_start_dt	DATE) IS
		SELECT	calul.unit_cd,
			calul.uv_version_number,
			us.s_unit_status
		FROM	IGS_PS_ANL_LOAD_U_LN	calul,
			IGS_PS_UNIT_VER			uv,
			IGS_PS_UNIT_STAT			us
		WHERE	calul.course_cd		 = p_course_cd	AND
			calul.crv_version_number = p_version_number	 AND
			calul.yr_num		 = p_yr_num		 AND
			calul.effective_start_dt = cp_effective_start_dt AND
			calul.unit_cd 		 = uv.unit_cd		 AND
			calul.uv_version_number	 = uv.version_number	 AND
			uv.unit_status		 = us.unit_status;

			x_rowid			Varchar2(25);
BEGIN
	OPEN c_max_eff_start_dt;
	FETCH c_max_eff_start_dt INTO v_effective_start_dt;
	CLOSE c_max_eff_start_dt;
	IF (v_effective_start_dt IS NULL) THEN
		p_message_name := 'IGS_PS_NOPRV_PRGANNUAL_COPY';
		RETURN TRUE;
	END IF;
	v_rec_inserted_cnt := 0;
	-- loop through all selected IGS_PS_UNIT links, insert IGS_PS_COURSE annual load passed in.
	OPEN c_calul(v_effective_start_dt);
	LOOP
		FETCH c_calul INTO v_unit_cd,
				   v_uv_version_number,
				   v_s_unit_status;
		EXIT WHEN c_calul%NOTFOUND;
		-- Do not insert records with system status of 'INACTIVE'
		IF (v_s_unit_status <> 'INACTIVE') THEN
			v_rec_inserted_cnt := v_rec_inserted_cnt + 1;

			IGS_PS_ANL_LOAD_U_LN_PKG.Insert_Row(
							 X_ROWID    		=>	x_rowid,
							 X_COURSE_CD            =>	p_course_cd,
							 X_CRV_VERSION_NUMBER   =>	p_version_number,
							 X_EFFECTIVE_START_DT   =>	p_effective_start_dt,
							 X_YR_NUM               =>	p_yr_num,
							 X_UV_VERSION_NUMBER    =>	v_uv_version_number,
							 X_UNIT_CD              =>	v_unit_cd,
							 X_MODE                 =>	'R');

		END IF;
	END LOOP;
	-- no IGS_PS_ANL_LOAD_U_LN record inserted
	IF (v_rec_inserted_cnt = 0) THEN
		p_message_name := 'IGS_PS_NOPRG_ANNUAL_LOADLINKS';
	-- all IGS_PS_ANL_LOAD_U_LN records inserted
	ELSIF (v_rec_inserted_cnt = c_calul%ROWCOUNT) THEN
		p_message_name := 'IGS_PS_SUCCESS_COPY_PRGANNUAL';
	-- some IGS_PS_ANL_LOAD_U_LN record inserted
	ELSE
		p_message_name := 'IGS_PS_SOME_PRGANNUAL_LOADLIN';
	END IF;
	CLOSE c_calul;
	RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_GEN_005.crsp_ins_calul');
	 	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END;
END crsp_ins_calul;


PROCEDURE CRSP_INS_TRO_HIST(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_new_percentage IN NUMBER ,
  p_old_percentage IN NUMBER ,
  p_new_update_who IN VARCHAR2 ,
  p_old_update_who IN VARCHAR2 ,
  p_new_update_on IN DATE ,
  p_old_update_on IN DATE )
AS
BEGIN	-- crsp_ins_tro_hist
	-- Insert a teaching_responsibility_ovrd_hist record.
DECLARE
	v_hist_start_dt		IGS_PS_TCH_RSOV_HIST.hist_start_dt%TYPE;
	v_hist_end_dt		IGS_PS_TCH_RSOV_HIST.hist_end_dt%TYPE;
	v_hist_who		IGS_PS_TCH_RSOV_HIST.hist_who%TYPE;
	l_org_id		NUMBER(15);
	x_rowid		Varchar2(25);
BEGIN
	IF p_new_percentage <> p_old_percentage THEN
		v_hist_start_dt	:= p_old_update_on;
		v_hist_end_dt 	:= p_new_update_on;
		v_hist_who 	:= p_old_update_who;
		l_org_id 	:= IGS_GE_GEN_003.GET_ORG_ID;
		IGS_PS_TCH_RSOV_HIST_PKG.Insert_Row(
					X_ROWID              =>	      x_rowid,
					X_UNIT_CD            =>  	p_unit_cd,
					X_CAL_TYPE           =>  	p_cal_type,
					X_CI_SEQUENCE_NUMBER =>  	p_ci_sequence_number,
					X_VERSION_NUMBER     =>  	p_version_number,
					X_LOCATION_CD        =>  	p_location_cd,
					X_ORG_UNIT_CD        =>  	p_org_unit_cd,
					X_HIST_START_DT      =>  	v_hist_start_dt,
					X_OU_START_DT        =>  	p_ou_start_dt,
					X_UNIT_CLASS         =>  	p_unit_class,
					X_HIST_END_DT        =>  	v_hist_end_dt,
					X_HIST_WHO           =>  	v_hist_who,
					X_PERCENTAGE         =>  	p_old_percentage,
					X_MODE               =>		'R',
					X_ORG_ID	     =>		l_org_id);
	END IF;
END;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_GEN_005.CRSP_INS_TRO_HIST');
	 	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END crsp_ins_tro_hist;

PROCEDURE crsp_ins_tr_hist(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_last_update_on IN DATE ,
  p_update_on IN DATE ,
  p_last_update_who IN VARCHAR2 ,
  p_percentage IN NUMBER )
AS
	CURSOR	c_unit_status(
			cp_unit_cd IGS_PS_UNIT_VER.unit_cd%TYPE,
			cp_version_number IGS_PS_UNIT_VER.version_number%TYPE) IS
		SELECT	IGS_PS_UNIT_STAT.s_unit_status
		FROM	IGS_PS_UNIT_STAT,IGS_PS_UNIT_VER
		WHERE	IGS_PS_UNIT_VER.unit_cd = cp_unit_cd AND
			IGS_PS_UNIT_VER.version_number = cp_version_number AND
			IGS_PS_UNIT_STAT.unit_status = IGS_PS_UNIT_VER.unit_status;
	cst_active	CONSTANT VARCHAR2(8) := 'ACTIVE';
	v_unit_status	IGS_PS_UNIT_STAT.s_unit_status%TYPE;
	x_rowid		VARCHAR2(25);
	l_org_id		NUMBER(15);
BEGIN
	OPEN c_unit_status(
			p_unit_cd,
			p_version_number);
	FETCH c_unit_status INTO v_unit_status;
	CLOSE c_unit_status;
	IF(v_unit_status = cst_active) THEN

		l_org_id := IGS_GE_GEN_003.GET_ORG_ID;
		IGS_PS_TCH_RESP_HIST_PKG.Insert_Row(
						X_ROWID            =>   	x_rowid,
						X_UNIT_CD          =>  		p_unit_cd,
						X_VERSION_NUMBER	 =>   	p_version_number,
						X_OU_START_DT      =>    	p_ou_start_dt,
						X_HIST_START_DT    =>    	p_last_update_on,
						X_ORG_UNIT_CD      =>    	p_org_unit_cd,
						X_HIST_END_DT      =>    	p_update_on,
						X_HIST_WHO         =>    	p_last_update_who,
						X_PERCENTAGE       =>    	p_percentage,
						X_MODE             =>		'R',
						X_ORG_ID	   =>		l_org_id);
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_GEN_005.crsp_ins_tr_hist');
	 	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END crsp_ins_tr_hist;

PROCEDURE crsp_ins_ud_hist(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_discipline_group_cd IN VARCHAR2 ,
  p_last_update_on IN DATE ,
  p_update_on IN DATE ,
  p_last_update_who IN VARCHAR2 ,
  p_percentage IN NUMBER )
AS
	CURSOR	c_unit_status(
			cp_unit_cd IGS_PS_UNIT_VER.unit_cd%TYPE,
			cp_version_number IGS_PS_UNIT_VER.version_number%TYPE) IS
		SELECT	IGS_PS_UNIT_STAT.s_unit_status
		FROM	IGS_PS_UNIT_STAT,IGS_PS_UNIT_VER
		WHERE	IGS_PS_UNIT_VER.unit_cd = cp_unit_cd AND
			IGS_PS_UNIT_VER.version_number = cp_version_number AND
			IGS_PS_UNIT_STAT.unit_status = IGS_PS_UNIT_VER.unit_status;
	cst_active	CONSTANT VARCHAR2(8) := 'ACTIVE';
	v_unit_status	IGS_PS_UNIT_STAT.s_unit_status%TYPE;
	X_rowid		VARCHAR2(25);
	l_org_id	NUMBER(15);
BEGIN
	OPEN c_unit_status(
			p_unit_cd,
			p_version_number);
	FETCH c_unit_status INTO v_unit_status;
	CLOSE c_unit_status;
	IF(v_unit_status = cst_active) THEN

			l_org_id := IGS_GE_GEN_003.GET_ORG_ID;

			IGS_PS_UNT_DSCP_HIST_PKG.Insert_Row(
						X_ROWID                =>	x_rowid,
						X_UNIT_CD              =>	p_unit_cd,
						X_HIST_START_DT        =>	p_last_update_on,
						X_DISCIPLINE_GROUP_CD  =>	p_discipline_group_cd,
						X_VERSION_NUMBER       =>	p_version_number,
						X_HIST_END_DT          =>	p_update_on,
						X_HIST_WHO             =>	p_last_update_who,
						X_PERCENTAGE           =>	p_percentage,
						X_MODE                 =>	'R',
						X_ORG_ID	       =>	l_org_id);
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_GEN_005.crsp_ins_ud_hist');
	 	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END crsp_ins_ud_hist;

PROCEDURE crsp_ins_urc_hist(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_reference_cd_type IN VARCHAR2 ,
  p_reference_cd IN VARCHAR2 ,
  p_last_update_on IN DATE ,
  p_update_on IN DATE ,
  p_last_update_who IN VARCHAR2 ,
  p_description IN VARCHAR2 )
AS
	CURSOR	c_unit_status(
			cp_unit_cd IGS_PS_UNIT_VER.unit_cd%TYPE,
			cp_version_number IGS_PS_UNIT_VER.version_number%TYPE) IS
		SELECT	IGS_PS_UNIT_STAT.s_unit_status
		FROM	IGS_PS_UNIT_STAT,IGS_PS_UNIT_VER
		WHERE	IGS_PS_UNIT_VER.unit_cd = cp_unit_cd AND
			IGS_PS_UNIT_VER.version_number = cp_version_number AND
			IGS_PS_UNIT_STAT.unit_status = IGS_PS_UNIT_VER.unit_status;
	cst_active	CONSTANT VARCHAR2(8) := 'ACTIVE';
	v_unit_status	IGS_PS_UNIT_STAT.s_unit_status%TYPE;
	x_rowid		VARCHAR2(25);
	l_org_id		NUMBER(15);
BEGIN
	OPEN c_unit_status(
			p_unit_cd,
			p_version_number);
	FETCH c_unit_status INTO v_unit_status;
	CLOSE c_unit_status;
	IF(v_unit_status = cst_active) THEN
		l_org_id  := IGS_GE_GEN_003.GET_ORG_ID;
		IGS_PS_UNIT_REF_HIST_PKG.Insert_Row(
					X_ROWID              =>	      x_rowid,
					X_UNIT_CD            =>  	p_unit_cd,
					X_HIST_START_DT      =>  	p_last_update_on,
					X_REFERENCE_CD       =>  	p_reference_cd,
					X_VERSION_NUMBER     =>  	p_version_number,
					X_REFERENCE_CD_TYPE  =>  	p_reference_cd_type,
					X_HIST_END_DT        =>  	p_update_on,
					X_HIST_WHO           =>  	p_last_update_who,
					X_DESCRIPTION        =>  	p_description,
					X_MODE               =>		'R',
					X_ORG_ID	     =>		l_org_id);
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		 Fnd_Message.Set_Token('NAME','IGS_PS_GEN_005.crsp_ins_urc_hist');
	 	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END crsp_ins_urc_hist;

END IGS_PS_GEN_005;

/
