--------------------------------------------------------
--  DDL for Package Body IGS_PS_GEN_007
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_GEN_007" AS
/* $Header: IGSPS07B.pls 120.1 2006/04/17 05:59:37 sarakshi noship $ */

FUNCTION crsp_get_rct_srct(
  p_reference_cd_type IN IGS_GE_REF_CD_TYPE_ALL.reference_cd_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN VARCHAR2 AS
BEGIN
	-- crsp_get_rct_srct
	-- This module returns the system reference code type
DECLARE
	v_s_reference_cd_type	IGS_LOOKUPS_VIEW.lookup_code%TYPE;
	CURSOR c_rct_srct IS
		SELECT	srct.lookup_code
		FROM	IGS_GE_REF_CD_TYPE	rct,
			IGS_LOOKUPS_VIEW	srct
		WHERE	rct.reference_cd_type		= p_reference_cd_type AND
			rct.closed_ind			= 'N' AND
			srct.lookup_code        	= rct.s_reference_cd_type AND
			srct.lookup_type			= 'REFERENCE_CD_TYPE' AND
			srct.closed_ind			= 'N';
BEGIN
	OPEN c_rct_srct;
	FETCH c_rct_srct INTO v_s_reference_cd_type;
	IF (c_rct_srct%NOTFOUND) THEN
		CLOSE c_rct_srct;
		p_message_name := 'IGS_PS_NO_OPEN_REFCDTYPE_EXIS';
		RETURN NULL;
	END IF;
	CLOSE c_rct_srct;
	p_message_name := NULL;
	RETURN v_s_reference_cd_type;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_rct_srct%ISOPEN) THEN
			CLOSE c_rct_srct;
		END IF;
		App_Exception.Raise_Exception;
END;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_GEN_007.crsp_get_rct_srct');
	 	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END crsp_get_rct_srct;

PROCEDURE crsp_ins_cow_hist(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_last_update_on IN DATE ,
  p_update_on IN DATE ,
  p_last_update_who IN VARCHAR2 ,
  p_percentage IN NUMBER )
--who        when          what
--sarakshi   12-Apr-2006   Bug#3655441, modified procedure crsp_ins_cow_hist to include PLANNED status also
AS
	v_s_course_status	IGS_PS_STAT.s_course_status%TYPE;
	CURSOR c_get_course_status IS
		SELECT s_course_status
		FROM 	IGS_PS_STAT, IGS_PS_VER
		WHERE	IGS_PS_VER.course_cd	= p_course_cd		AND
			IGS_PS_VER.version_number 	= p_version_number 	AND
			IGS_PS_STAT.course_status	= IGS_PS_VER.course_status;

		x_rowid		Varchar2(25);
		l_org_id        NUMBER(15);
BEGIN
	OPEN c_get_course_status;
	FETCH c_get_course_status INTO v_s_course_status;
	CLOSE c_get_course_status;
	IF v_s_course_status IN ('ACTIVE','PLANNED') THEN

                 l_org_id := igs_ge_gen_003.get_org_id;

		IGS_PS_OWN_HIST_PKG.Insert_Row(
						X_ROWID        	=> x_rowid,
						X_COURSE_CD    	=>p_course_cd,
						X_HIST_START_DT	=>p_last_update_on,
						X_OU_START_DT  	=>p_ou_start_dt,
						X_VERSION_NUMBER	=>p_version_number,
						X_ORG_UNIT_CD  	=>p_org_unit_cd,
						X_HIST_END_DT  	=>p_update_on,
						X_HIST_WHO     	=>p_last_update_who,
						X_PERCENTAGE   	=>p_percentage,
						X_MODE         	=>'R',
						X_ORG_ID        =>l_org_id);
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_GEN_007.crsp_ins_cow_hist');
	 	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END crsp_ins_cow_hist;

PROCEDURE crsp_ins_crc_hist(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_reference_cd_type IN VARCHAR2 ,
  p_reference_cd IN VARCHAR2 ,
  p_last_update_on IN DATE ,
  p_update_on IN DATE ,
  p_last_update_who IN VARCHAR2 ,
  p_description IN VARCHAR2 )
--who        when          what
--sarakshi   12-Apr-2006   Bug#3655441, modified procedure crsp_ins_cow_hist to include PLANNED status also
AS
	CURSOR	c_course_status(
			cp_course_cd IGS_PS_VER.course_cd%TYPE,
			cp_version_number IGS_PS_VER.version_number%TYPE) IS
		SELECT	IGS_PS_STAT.s_course_status
		FROM	IGS_PS_STAT,IGS_PS_VER
		WHERE	IGS_PS_VER.course_cd = cp_course_cd AND
			IGS_PS_VER.version_number = cp_version_number AND
			IGS_PS_STAT.course_status = IGS_PS_VER.course_status;
	v_course_status	IGS_PS_STAT.s_course_status%TYPE;
	x_rowid		VARCHAR2(25);
	l_org_id        NUMBER(15);
BEGIN
	OPEN c_course_status(
			p_course_cd,
			p_version_number);
	FETCH c_course_status INTO v_course_status;
	CLOSE c_course_status;
	IF(v_course_status IN ('ACTIVE','PLANNED')) THEN

                l_org_id := igs_ge_gen_003.get_org_id;

		IGS_PS_REF_CD_HIST_PKG.Insert_Row(
					 X_ROWID      		=>x_rowid,
				       X_COURSE_CD 	 	=>p_course_cd,
					 X_REFERENCE_CD_TYPE    =>p_reference_cd_type,
					 X_REFERENCE_CD         =>p_reference_cd,
					 X_HIST_START_DT        =>p_last_update_on,
					 X_VERSION_NUMBER       =>p_version_number,
					 X_HIST_END_DT          =>p_update_on,
					 X_HIST_WHO             =>p_last_update_who,
					 X_DESCRIPTION          =>p_description,
					 X_MODE                 =>'R',
					 X_ORG_ID               =>l_org_id);

	END IF;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_GEN_007.crsp_ins_crc_hist');
	 	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END crsp_ins_crc_hist;

PROCEDURE crsp_ins_cul_hist(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_course_type  VARCHAR2 DEFAULT NULL,
  p_last_update_on IN DATE ,
  p_update_on IN DATE ,
  p_last_update_who IN VARCHAR2 ,
  p_unit_level IN VARCHAR2 ,
  p_wam_weighting IN NUMBER,
  p_course_cd VARCHAR2,
  p_course_version_number NUMBER)
--who        when          what
--sarakshi   12-Apr-2006   Bug#3655441, modified procedure crsp_ins_cow_hist to include PLANNED status also

AS
	v_s_unit_status		IGS_PS_UNIT_STAT.s_unit_status%TYPE;
	CURSOR c_get_unit_status IS
		SELECT s_unit_status
		FROM 	IGS_PS_UNIT_STAT, IGS_PS_UNIT_VER
		WHERE	IGS_PS_UNIT_VER.unit_cd		= p_unit_cd		AND
			IGS_PS_UNIT_VER.version_number 	= p_version_number 	AND
			IGS_PS_UNIT_STAT.unit_status		= IGS_PS_UNIT_VER.unit_status;

	x_rowid			Varchar2(25);
	l_org_id                NUMBER(15);
BEGIN
	OPEN c_get_unit_status;
	FETCH c_get_unit_status INTO v_s_unit_status;
	CLOSE c_get_unit_status;
	IF v_s_unit_status IN ('ACTIVE','PLANNED') THEN

                l_org_id := igs_ge_gen_003.get_org_id;

-- ijeddy       03-nov-2003     Bug# 3181938; Modified this object as per Summary Measurement Of Attainment TD.

		IGS_PS_UNIT_LVL_HIST_PKG.Insert_Row(
						X_ROWID                  => x_rowid,
						X_UNIT_CD                => p_unit_cd,
						X_VERSION_NUMBER         =>p_version_number,
						X_HIST_START_DT          =>p_last_update_on,
						X_HIST_END_DT            =>p_update_on,
						X_HIST_WHO               =>p_last_update_who,
						X_UNIT_LEVEL             =>p_unit_level,
						X_WAM_WEIGHTING          =>p_wam_weighting,
						X_MODE                   =>'R',
						X_ORG_ID                 =>l_org_id,
						X_COURSE_CD              =>p_course_cd,
                                                X_COURSE_VERSION_NUMBER  =>p_course_version_number
						);

	END IF;
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		Fnd_Message.Set_Token('NAME','IGS_PS_GEN_007.crsp_ins_cul_hist');
	 	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
END crsp_ins_cul_hist;

END IGS_PS_GEN_007;

/
