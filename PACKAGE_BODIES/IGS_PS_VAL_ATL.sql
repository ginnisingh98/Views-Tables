--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_ATL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_ATL" AS
/* $Header: IGSPS10B.pls 115.7 2002/11/29 02:55:59 nsidana ship $
  Change History:
   WHO                    WHEN            WHAT
   ayedubat            17-MAY-2001  Added one new procedure,chk_mandatory_ref_cd
-- avenkatr    29-AUG-2001    Bug Id : 1956374. Removed Function "crsp_val_att_closed"
  -------------------------------------------------------------------------------------------
*/





  -- Validate the calendar type SI_CA_S_CA_CAT = 'LOAD' and closed_ind
  FUNCTION crsp_val_atl_cat(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  DECLARE
  	v_closed_ind	IGS_CA_TYPE.closed_ind%TYPE;
  	v_s_cal_cat	IGS_CA_TYPE.s_cal_cat%TYPE;
  	CURSOR c_ci_scc_ct IS
  		SELECT	closed_ind,
  			s_cal_cat
  		FROM	IGS_CA_TYPE
  		WHERE	cal_type = p_cal_type;
  BEGIN
  	-- This module validates the clendar category and
  	-- closed indicator for an IGS_EN_ATD_TYPE_LOAD record
  	-- being inserted.
  	p_message_name := NULL;
  	OPEN 	c_ci_scc_ct;
  	FETCH 	c_ci_scc_ct	into	v_closed_ind,
  					v_s_cal_cat;
  	IF (c_ci_scc_ct%NOTFOUND) THEN
  		CLOSE c_ci_scc_ct;
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	IF (v_closed_ind = 'Y') THEN
  		CLOSE c_ci_scc_ct;
  		p_message_name := 'IGS_CA_CALTYPE_CLOSED';
  		RETURN FALSE;
  	END IF;
  	IF (v_s_cal_cat <> 'LOAD') THEN
  		CLOSE c_ci_scc_ct;
  		p_message_name := 'IGS_PS_CALTYPE_MUSTBE_LOADCAL';
  		RETURN FALSE;
  	END IF;
  	--- Return the default value
  	CLOSE c_ci_scc_ct;
  	p_message_name := NULL;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
	  	Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
	 	Fnd_Message.Set_Token('NAME','IGS_PS_GEN_010.CRSP_VAL_ATL_CAT');
	 	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END;
  END CRSP_VAL_ATL_CAT;


  -- To validate the att type load ranges
  FUNCTION crsp_val_atl_range(
  p_attendance_type IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_lower_enr_load_range IN NUMBER ,
  p_upper_enr_load_range IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  BEGIN
  DECLARE
  	v_p_lower_enr_load_range	IGS_EN_ATD_TYPE_LOAD.lower_enr_load_range%TYPE;
  	v_p_upper_enr_load_range	IGS_EN_ATD_TYPE_LOAD.upper_enr_load_range%TYPE;
  	CURSOR c_lelr_uelr IS
  		SELECT	lower_enr_load_range,
  			upper_enr_load_range
  		FROM	IGS_EN_ATD_TYPE_LOAD
  		WHERE	cal_type = p_cal_type AND
  			attendance_type <> p_attendance_type AND
  			((p_lower_enr_load_range >= lower_enr_load_range AND
  			p_lower_enr_load_range <= upper_enr_load_range) OR
  			(p_upper_enr_load_range >= lower_enr_load_range AND
  			p_upper_enr_load_range <= upper_enr_load_range) OR
  			(p_lower_enr_load_range < lower_enr_load_range AND
  			p_upper_enr_load_range > upper_enr_load_range));
  BEGIN
  	-- This module validates the attendance type load range for
  	-- a lower range which exceeds an upper range and
  	-- overlaps between more than one IGS_EN_ATD_TYPE_LOAD record in
  	-- the same load calendar type.
  	p_message_name := NULL;
  	IF (p_lower_enr_load_range > p_upper_enr_load_range) THEN
  		p_message_name := 'IGS_PS_LOW_ENRLOAD_BELOW';
  		RETURN FALSE;
  	END IF;
  	OPEN 	c_lelr_uelr;
  	FETCH	c_lelr_uelr	into	v_p_lower_enr_load_range,
  					v_p_upper_enr_load_range;
  	IF (c_lelr_uelr%FOUND) THEN
  		p_message_name := 'IGS_PS_LOADCAL_NO_OVERLAPP';
  		CLOSE c_lelr_uelr;
  		RETURN FALSE;
  	END IF;
  	CLOSE c_lelr_uelr;
  	-- Return the default value
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
  		Fnd_Message.Set_Token('NAME','IGS_PS_GEN_010.CRSP_VAL_ATL_RANGE');
	 	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END;
  END CRSP_VAL_ATL_RANGE;

  -- Check weather the mandatory reference type is set or not corresponding to a particular reference code type
  FUNCTION chk_mandatory_ref_cd(
     p_reference_type IN VARCHAR2)
  RETURN BOOLEAN AS
  BEGIN
    DECLARE
       l_mandatory_flag IGS_GE_REF_CD_TYPE.mandatory_flag%TYPE;
       CURSOR c_mandatory_flag IS
         SELECT mandatory_flag
         FROM   IGS_GE_REF_CD_TYPE
         WHERE  reference_cd_type = p_reference_type;
    BEGIN
       OPEN c_mandatory_flag;
       FETCH c_mandatory_flag INTO l_mandatory_flag;
       CLOSE c_mandatory_flag;
       IF l_mandatory_flag='Y' THEN
         RETURN TRUE;
       ELSE
         RETURN FALSE;
       END IF;
     EXCEPTION
  	WHEN OTHERS THEN
	  	Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
	  	Fnd_Message.Set_Token('NAME','IGS_PS_VAL_ATL.CHK_MANDATORY_REF_CD');
	 	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
    END;
  END chk_mandatory_ref_cd;

END IGS_PS_VAL_ATL;

/
