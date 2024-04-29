--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAL_VE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAL_VE" AS
/* $Header: IGSAS37B.pls 115.6 2002/11/28 22:48:31 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function orgp_val_loc_closed removed.Also
  --                            the reference to igs_as_val_ve.orgp_val_loc_closed is
  --                            changed to igs_as_val_els.orgp_val_loc_closed
  -------------------------------------------------------------------------------------------
  --msrinivi    24-AUG-2001     Bug No. 1956374 .The function genp_val_prsn_id removed
  -- Validate IGS_AD_LOCATION closed indicator.
    -- Retrofitted
  FUNCTION assp_val_ve_lot(
  p_exam_location_cd  IGS_GR_VENUE_ALL.exam_location_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_ve_lot
  	-- Validate s_loc_type = EXAM_CTR or GRD_CTR
  DECLARE
  	CURSOR	c_lot IS
  	SELECT	'x'
  	FROM	IGS_AD_LOCATION_TYPE	lot,
  		IGS_AD_LOCATION	loc
  	WHERE	lot.location_type	= loc.location_type AND
  		loc.location_cd		= p_exam_location_cd AND
  		lot.s_location_type = 'EXAM_CTR' OR
  		lot.s_location_type = 'GRD_CTR';
  	v_lot_exists	VARCHAR2(1);
  BEGIN
  	-- Set the default message number
  	 p_message_name := null;
  	OPEN c_lot;
  	FETCH c_lot INTO v_lot_exists;
  	IF (c_lot%NOTFOUND) THEN
  		CLOSE c_lot;
  		-- The system IGS_AD_LOCATION type must be specified as EXAM_CTR or GRD_CTR
  		p_message_name := 'IGS_AS_SYS_LOCTYPE_EXAM_CTR';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_lot;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	 Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
         Fnd_Message.Set_Token('NAME','IGS_AS_VAL_VE.ASSP_VAL_VE_LOT');
         Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
  END assp_val_ve_lot;
  --
  -- Retrofitted
  FUNCTION assp_val_ve_reopen(
  p_exam_location_cd  IGS_GR_VENUE_ALL.exam_location_cd%TYPE ,
  p_closed_ind  IGS_GR_VENUE_ALL.closed_ind%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN IS
  	gv_other_detail		VARCHAR2(255);
  BEGIN	-- assp_val_ve_reopen
  	-- Cannot re-open a IGS_GR_VENUE when the IGS_AD_LOCATION is closed.
  DECLARE
  	v_message_name  varchar2(30);
  BEGIN
  	-- Set the default message number
  	 p_message_name := null;
  	-- If IGS_GR_VENUE is being opened(ie. the p_closed_ind is 'N')
  	IF (p_closed_ind = 'N')	THEN
  		IF igs_as_val_els.orgp_val_loc_closed(
  			p_exam_location_cd,
  			v_message_name)= FALSE THEN
  			p_message_name := 'IGS_AS_CANNOT_REOPEN_VENUE';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  	 Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
         Fnd_Message.Set_Token('NAME','IGS_AS_VAL_VE.ASSP_VAL_VE_REOPEN');
         Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
  END assp_val_ve_reopen;
  --
  --

END IGS_AS_VAL_VE;

/
