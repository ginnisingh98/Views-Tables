--------------------------------------------------------
--  DDL for Package Body IGS_AD_VAL_EDTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_VAL_EDTL" AS
/* $Header: IGSAD57B.pls 115.4 2002/11/28 21:36:44 nsidana ship $ */
  --msrinivi    24-AUG-2001     Bug No. 1956374 .The function genp_val_prsn_id removed
  --
  -- Validate either the ou code or employer fld is set
  FUNCTION admp_val_edtl_emplyr(
  p_org_unit_cd IN VARCHAR2 ,
  p_employer IN VARCHAR2 ,
  p_message_name	OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN	-- admp_val_edtl_emplyr
  	-- This module validates that either the org_unit_cd or
  	-- the employer field of an IGS_AD_EMP_DTL record has been set.
    BEGIN
  	p_message_name := null;
  	IF p_org_unit_cd IS NULL AND
  			p_employer IS NULL THEN
		p_message_name := 'IGS_AD_ORGUNIT_EMPFLD_SPECIFY';
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
    END;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME','IGS_AD_VAL_EDTL.admp_val_edtl_emplyr');
		IGS_GE_MSG_STACK.ADD;
  END admp_val_edtl_emplyr;
  --
  -- To validate that end date is greater than or equal to start date.
  FUNCTION GENP_VAL_STRT_END_DT(
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name	OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  BEGIN
  	IF p_end_dt < p_start_dt THEN
		p_message_name := 'IGS_GE_INVALID_DATE';
  		RETURN FALSE;
  	END IF;
  	p_message_name := null;
  	RETURN TRUE;
  END GENP_VAL_STRT_END_DT;
END IGS_AD_VAL_EDTL;

/
