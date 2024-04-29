--------------------------------------------------------
--  DDL for Package Body IGS_CA_VAL_DAI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_VAL_DAI" AS
/* $Header: IGSCA07B.pls 115.4 2002/12/19 15:38:54 npalanis ship $ */
  -- Validate calendar category is HOLIDAY.
  FUNCTION calp_val_holiday_cat(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_other_detail	VARCHAR2(255);
  	v_s_cal_cat	IGS_CA_TYPE.s_cal_cat%TYPE;
  	CURSOR c_get_holiday_cat IS
  		SELECT s_cal_cat
  		FROM IGS_CA_TYPE
  		WHERE cal_type = p_cal_type;
  BEGIN
  	p_message_name :=NULL;
  	OPEN c_get_holiday_cat;
  	FETCH c_get_holiday_cat INTO v_s_cal_cat;
  	IF (c_get_holiday_cat%NOTFOUND) THEN
  		CLOSE c_get_holiday_cat;
  		RETURN TRUE;
  	END IF;
  	CLOSE c_get_holiday_cat;
  	IF (v_s_cal_cat = 'HOLIDAY') THEN
  		RETURN TRUE;
  	ELSE
  		RETURN FALSE;
  	END IF;

  END calp_val_holiday_cat;
  --
  -- To validate the insert of a IGS_CA_DA_INST record
  FUNCTION calp_val_dai_upd(
  p_dt_alias IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  	v_other_detail		VARCHAR2(255);
  	v_dt_alias_inst_found	BOOLEAN;
  	v_alias_val		IGS_CA_DA_INST_V.alias_val%TYPE;
  	CURSOR	c_dt_alias_instance_1(cp_dt_alias IGS_CA_DA_INST_V.dt_alias%TYPE,
  				      cp_sequence_number IGS_CA_DA_INST_V.sequence_number%TYPE,
  				      cp_cal_type IGS_CA_DA_INST_V.cal_type%TYPE,
  				      cp_ci_sequence_number IGS_CA_DA_INST_V.ci_sequence_number%TYPE)
  	IS
  	SELECT	*
  	FROM	IGS_CA_DA_INST_V
  	WHERE	dt_alias = cp_dt_alias
  	AND	sequence_number = cp_sequence_number
  	AND	cal_type = cp_cal_type
  	AND	ci_sequence_number = cp_ci_sequence_number;
  	CURSOR	c_dt_alias_instance_2(cp_dt_alias IGS_CA_DA_INST_V.dt_alias%TYPE,
  				      cp_sequence_number IGS_CA_DA_INST_V.sequence_number%TYPE,
  				      cp_cal_type IGS_CA_DA_INST_V.cal_type%TYPE,
  				      cp_ci_sequence_number IGS_CA_DA_INST_V.ci_sequence_number%TYPE,
  				      cp_alias_val IGS_CA_DA_INST_V.alias_val%TYPE)
  	IS
  	SELECT	*
  	FROM	IGS_CA_DA_INST_V
  	WHERE	dt_alias = cp_dt_alias
  	AND	sequence_number <> cp_sequence_number
  	AND	cal_type = cp_cal_type
  	AND	ci_sequence_number = cp_ci_sequence_number
  	AND	alias_val IS NOT NULL
  	AND	alias_val = cp_alias_val;
  BEGIN
  	p_message_name := NULL;
  	v_dt_alias_inst_found := FALSE;
  	FOR v_dt_alias_instance_rec_1 IN c_dt_alias_instance_1(
  				p_dt_alias,
  				p_sequence_number,
  				p_cal_type,
  				p_ci_sequence_number)
  	LOOP
  		v_dt_alias_inst_found := TRUE;
  		v_alias_val := v_dt_alias_instance_rec_1.alias_val;
  	END LOOP;
  	IF (v_dt_alias_inst_found AND v_alias_val IS NULL) THEN
  		p_message_name :=NULL;
  		RETURN TRUE;
  	END IF;
  	FOR v_dt_alias_instance_rec_2 IN c_dt_alias_instance_2(
  				p_dt_alias,
  				p_sequence_number,
  				p_cal_type,
  				p_ci_sequence_number,
  				v_alias_val)
  	LOOP
  		p_message_name := 'IGS_CA_DUPLICATE_DTALIAS_INST';
  		RETURN FALSE;
  	END LOOP;
  	RETURN TRUE;
  	EXCEPTION
  	WHEN OTHERS THEN

     Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
     FND_MESSAGE.SET_TOKEN('NAME','IGS_CA_VAL_DAI.calp_val_dai_upd');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
  END calp_val_dai_upd;
  --
  -- Validate the dt_alias of the IGS_CA_DA_INST
  FUNCTION CALP_VAL_DAI_DA(
  p_dt_alias IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  CURSOR	c_dt_alias
  IS
  SELECT 	closed_ind,
  	s_cal_cat
  FROM	IGS_CA_DA
  WHERE	dt_alias = p_dt_alias;
  CURSOR	c_cal_type
  IS
  SELECT 	s_cal_cat
  FROM	IGS_CA_TYPE
  WHERE	cal_type = p_cal_type;
  v_dt_alias_closed_ind	VARCHAR2(1);
  v_dt_alias_s_cal_cat	IGS_CA_DA.S_CAL_CAT%TYPE;
  v_cal_type_s_cal_cat	IGS_CA_TYPE.S_CAL_CAT%TYPE;
  v_other_detail		VARCHAR2(255);
  BEGIN
  	OPEN 	c_dt_alias;
  	LOOP
  		FETCH 	c_dt_alias
  		INTO	v_dt_alias_closed_ind,
  			v_dt_alias_s_cal_cat;
  		EXIT WHEN c_dt_alias%NOTFOUND;
  		IF (v_dt_alias_closed_ind = 'Y') THEN
  			CLOSE c_dt_alias;
  			p_message_name := 'IGS_CA_DTALIAS_CLOSED';
  			RETURN FALSE;
  		END IF;
  	END LOOP;
  	IF (v_dt_alias_s_cal_cat IS NOT NULL) THEN
  		OPEN 	c_cal_type;
  		LOOP
  			FETCH 	c_cal_type
  			INTO	v_cal_type_s_cal_cat;
  			EXIT WHEN c_cal_type%NOTFOUND;
  			IF (v_dt_alias_s_cal_cat <> v_cal_type_s_cal_cat) THEN
  				CLOSE c_dt_alias;
  				CLOSE c_cal_type;
  				p_message_name := 'IGS_CA_DTALIAS_CALCAT_NOMATCH';
  				RETURN FALSE;
  			END IF;
  		END LOOP;
  		CLOSE c_cal_type;
  	END IF;
  	CLOSE c_dt_alias;
  	p_message_name := NULL;
  	RETURN TRUE;
    END calp_val_dai_da;
END IGS_CA_VAL_DAI;

/
