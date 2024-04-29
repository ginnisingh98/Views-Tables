--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_ECPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_ECPD" AS
/* $Header: IGSEN35B.pls 115.3 2002/11/28 23:57:43 nsidana ship $ */
  --
  -- To validate enr category procedure detail comm type
  FUNCTION ENRP_VAL_ECPD_COMM(
  p_enrolment_cat IN VARCHAR2 ,
  p_enr_method_type IN VARCHAR2 ,
  p_s_student_comm_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN boolean AS

  BEGIN
  DECLARE
    	v_search_comm 			VARCHAR2(30);
    	v_enrolment_cat			IGS_EN_CAT_PRC_DTL.enrolment_cat%TYPE;
    	CURSOR c_ecpd1 IS
    		SELECT	ecpd.enrolment_cat
    		FROM	IGS_EN_CAT_PRC_DTL	ecpd
    		WHERE	ecpd.enrolment_cat = p_enrolment_cat AND
    			ecpd.enr_method_type = p_enr_method_type AND
    			ecpd.s_student_comm_type = 'ALL';
    	CURSOR c_ecpd2 IS
    		SELECT	ecpd.enrolment_cat
    		FROM	IGS_EN_CAT_PRC_DTL	ecpd
    		WHERE	ecpd.enrolment_cat = p_enrolment_cat AND
    			ecpd.enr_method_type = p_enr_method_type AND
    			ecpd.s_student_comm_type in ('NEW','RETURN');
  BEGIN
    	-- Validate the commencement type for the IGS_EN_CAT_PRC_DTL;
    	-- All can not be used when there is a specific (being NEW or RETURN)
    	-- record for the same enrolment_cat/enr_method_type combination.
    	-- Set the default message number
    	p_message_name := null;
    	-- Determine which criteria will clash with the parameters.
    	IF p_s_student_comm_type in  ('NEW','RETURN') THEN
    		OPEN	c_ecpd1;
    		FETCH	c_ecpd1	INTO	v_enrolment_cat;
  	  	IF (c_ecpd1%FOUND) THEN
    			CLOSE	c_ecpd1;
    			p_message_name := 'IGS_EN_INVALID_NEW_RETURNING';
  	  		RETURN FALSE;
    		END IF;
  	  	CLOSE	c_ecpd1;
    	ELSE
    		OPEN	c_ecpd2;
    		FETCH	c_ecpd2	INTO	v_enrolment_cat;
  	  	IF (c_ecpd2%FOUND) THEN
    			CLOSE	c_ecpd2;
    			p_message_name := 'IGS_EN_INVALID_NEW_RETURNING';
  	  		RETURN FALSE;
    		END IF;
  	  	CLOSE	c_ecpd2;
    	END IF;
    	-- Return the default value
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
  		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_ECPD.enrp_val_ecpd_comm');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END enrp_val_ecpd_comm;
  --
  -- To validate the enrol method type for the ecpd
  FUNCTION enrp_val_ecpd_emt(
  p_enrolment_method_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
  RETURN boolean AS
  BEGIN
  DECLARE
  	v_closed_ind	IGS_EN_METHOD_TYPE.closed_ind%TYPE;
  	CURSOR	c_enr_method_type(
  		      	cp_enr_method_type IGS_EN_CAT_PRC_DTL.enr_method_type%TYPE) IS
  		SELECT	closed_ind
  		FROM	IGS_EN_METHOD_TYPE
  		WHERE	enr_method_type = cp_enr_method_type;
  	v_other_detail	VARCHAR2(255);
  BEGIN
  	-- validate enr_method_type.closed_ind for a given p_enrolment_method_type
  	p_message_name := null;
  	OPEN c_enr_method_type(
  			p_enrolment_method_type);
  	FETCH c_enr_method_type INTO v_closed_ind;
  	IF(c_enr_method_type%NOTFOUND) THEN
  		RETURN TRUE;
  	END IF;
  	IF(v_closed_ind = 'N') THEN
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_EN_ENRMTH_TYPE_CLOSED';
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_VAL_ECPD.enrp_val_ecpd_emt');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END;
  END enrp_val_ecpd_emt;
END IGS_EN_VAL_ECPD;

/
