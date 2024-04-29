--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_UAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_UAP" AS
/* $Header: IGSAS35B.pls 115.10 2003/12/03 08:50:03 ijeddy ship $ */
  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.
  -- Validate the ass_pattern_cd is unique within a IGS_PS_UNIT offering pattern.
  -- Bug No 1956374 , Procedure assp_val_uap_loc_uc is removed
  -- Bug No 1956374 , Procedure crsp_val_iud_uv_dtl is removed
  FUNCTION ASSP_VAL_UAP_UNIQ_CD(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_pattern_id IN NUMBER ,
  p_ass_pattern_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN
        RETURN TRUE;
        --ijeddy, Grade Book . Obsoleted
  END assp_val_uap_uniq_cd;
  --
  -- Validate the IGS_PS_UNIT assessment pattern restrictions can be updated.
  FUNCTION ASSP_VAL_UAP_UOO_UPD(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_ass_pattern_id IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_unit_mode IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN	-- assp_val_uap_uoo_upd
  	-- This module validates that IGS_AD_LOCATION code, IGS_PS_UNIT mode and class are allowed to
  	-- be updated for the IGS_PS_UNIT assessment pattern.
        --no longer inuse - ijeddy Grade Book . Obsoleted
        RETURN FALSE;
  END assp_val_uap_uoo_upd;
  --
  -- Validate IGS_PS_UNIT class and IGS_PS_UNIT mode cannot both be set.
  FUNCTION ASSP_VAL_UC_UM(
  p_unit_mode IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_uc_um
  	-- Do not allow both IGS_PS_UNIT mode and IGS_PS_UNIT class to be specified
  DECLARE
  	v_ret_val	BOOLEAN	DEFAULT TRUE;
  BEGIN
  	 p_message_name := null;
  		IF p_unit_mode IS NOT NULL AND
  				p_unit_class IS NOT NULL THEN
  			p_message_name := 'IGS_AS_UNITMODE_UNITCLASS_LIN';
  			RETURN FALSE;
  		END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	 Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
         Fnd_Message.Set_Token('NAME','IGS_AS_VAL_UAP.ASSP_VAL_UC_UM');
         Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
  END assp_val_uc_um;

  --
  -- Val IGS_PS_UNIT assess pattern applies to stud IGS_PS_UNIT IGS_AD_LOCATION, class and mode.
    --
  -- Val IGS_PS_UNIT assess pattern applies to stud IGS_PS_UNIT IGS_AD_LOCATION, class and mode.
  FUNCTION ASSP_VAL_SUA_UAP(
  p_student_location_cd IN VARCHAR2 ,
  p_student_unit_class IN VARCHAR2 ,
  p_student_unit_mode IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_unit_mode IN VARCHAR2 )
  RETURN CHAR IS
  	  	v_message_name  varchar2(30);
  BEGIN	-- assp_val_sua_uai
  	-- Validate that the IGS_AS_UNTAS_PATTERN's IGS_AD_LOCATION, mode and class
  	-- are applicable for the student
  DECLARE
  BEGIN
  	IF IGS_AS_VAL_SUAAP.assp_val_uap_loc_uc(p_student_location_cd,
  			p_student_unit_class,
  			p_student_unit_mode,
  			p_location_cd,
  			p_unit_class,
  			p_unit_mode,
  			v_message_name) = TRUE THEN
  		RETURN 'TRUE';
  	ELSE
  		RETURN 'FALSE';
  	END IF;
  END;

  END assp_val_sua_uap;

END IGS_AS_VAL_UAP;

/
