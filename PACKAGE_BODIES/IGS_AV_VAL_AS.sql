--------------------------------------------------------
--  DDL for Package Body IGS_AV_VAL_AS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AV_VAL_AS" AS
/* $Header: IGSAV02B.pls 120.2 2006/03/27 01:32:59 shimitta noship $ */
  -- To validate the advanced standing IGS_PS_COURSE code.
  -- shimitta 7-Mar-2006 Modified as in Bug# 5068233
  FUNCTION advp_val_as_crs(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	CURSOR 	c_adv_stnd_v(
  			cp_person_id IGS_AV_ADV_STANDING.person_id%TYPE,
  			cp_course_cd IGS_AV_ADV_STANDING.course_cd%TYPE,
  			cp_version_number IGS_AV_ADV_STANDING.version_number%TYPE) IS
  		SELECT	spa.course_cd
  		FROM	IGS_EN_STDNT_PS_ATT spa
  		WHERE	spa.person_id = cp_person_id AND
  			spa.course_cd = cp_course_cd AND
  			spa.version_number = cp_version_number AND
			spa.course_attempt_status IN
                   ('ENROLLED', 'INACTIVE', 'INTERMIT', 'UNCONFIRM', 'DISCONTIN','COMPLETED');

  BEGIN
  	-- Validate that IGS_AV_ADV_STANDING.course_cd is valid for the purposes of
  	-- Advanced Standing.
  	-- It must be contained within a IGS_EN_STDNT_PS_ATT by the nominated
  	-- person_id, with a status of 'enrolled', 'inactive', 'intermit' or
  	-- 'unconfirm'.
  	 p_message_name := null;
  	-- Validate input parameters.
  	IF(p_person_id IS NULL OR p_course_cd IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	--  Validate that IGS_PS_COURSE code is valid.
  	FOR v_adv_stnd_rec IN c_adv_stnd_v(
  					p_person_id,
  					p_course_cd,
  					p_version_number) LOOP
  		RETURN TRUE;
  	END LOOP;
  	 p_message_name  := 'IGS_GE_INVALID_VALUE';
  	RETURN FALSE;
  EXCEPTION
  	WHEN OTHERS THEN
  	 Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
         Fnd_Message.Set_Token('NAME','IGS_AV_VAL_AS.ADVP_VAL_AS_CRS');
         Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
  END;
  END advp_val_as_crs;
  --
  -- To validate the advanced standing major exemption IGS_OR_INSTITUTION code.
  FUNCTION advp_val_as_inst(
  p_exempt_inst IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN
  DECLARE
  	CURSOR 	c_exempt_inst_v(
  			cp_exempt_inst IGS_AV_ADV_STANDING.exemption_institution_cd%TYPE) IS
		SELECT ihp.oss_org_unit_cd exemption_institution_cd
		FROM igs_pe_hz_parties ihp
		 where ihp.inst_org_ind = 'I'
		 AND ihp.oi_govt_institution_cd IS NOT NULL
		 AND ihp.oss_org_unit_cd = cp_exempt_inst
		UNION ALL
		SELECT lk.lookup_code exemption_institution_cd
		FROM igs_lookup_values lk
		WHERE lk.lookup_type = 'OR_INST_EXEMPTIONS'
		 AND lk.enabled_flag = 'Y'
		 AND lk.lookup_code = cp_exempt_inst;
  BEGIN
  	-- Validate that IGS_AV_ADV_STANDING.exemption_institution_cd) is valid.
  	-- The status is not considered, as it is allowable to select an inactive
  	-- IGS_OR_INSTITUTION for advanced standing basis details.
  	 p_message_name := null;
  	-- Validate input parameters.
  	IF(p_exempt_inst IS NULL) THEN
  		RETURN TRUE;
  	END IF;
  	--  Validate that exemption IGS_OR_INSTITUTION is valid.
  	FOR v_exempt_inst_rec IN c_exempt_inst_v(
  						p_exempt_inst) LOOP
  		RETURN TRUE;
  	END LOOP;
  	 p_message_name := 'IGS_GE_INVALID_VALUE';
  	RETURN FALSE;
  EXCEPTION
  	WHEN OTHERS THEN
  	 Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
         Fnd_Message.Set_Token('NAME','IGS_AV_VAL_AS.ADVP_VAL_AS_INST');
         Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
  END;
  END advp_val_as_inst;
END IGS_AV_VAL_AS;

/
