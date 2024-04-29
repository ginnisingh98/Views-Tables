--------------------------------------------------------
--  DDL for Package Body IGS_CA_VAL_DAIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_VAL_DAIO" AS
/* $Header: IGSCA08B.pls 115.4 2002/11/28 22:57:59 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "calp_val_holidat_cat"
  -------------------------------------------------------------------------------------------

  --
  -- Validate insert of IGS_CA_DA_INST_OFST
  FUNCTION CALP_VAL_DAIO_INS(
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_offset_dt_alias IN VARCHAR2 ,
  p_offset_dai_sequence_number IN NUMBER ,
  p_offset_cal_type IN VARCHAR2 ,
  p_offset_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  cst_planned			CONSTANT VARCHAR2(8) := 'PLANNED';
  cst_active			CONSTANT VARCHAR2(8) := 'ACTIVE';
  v_other_detail	VARCHAR(255);
  v_alias_value	DATE;
  v_dt_alias_status IGS_CA_STAT.s_cal_status%TYPE;
  v_offset_dt_alias_status IGS_CA_STAT.s_cal_status%TYPE;
  CURSOR	c_dt_alias_instance_offset (
  			    cp_dt_alias IGS_CA_DA_INST_OFST.dt_alias%TYPE,
  			    cp_dai_sequence_number IGS_CA_DA_INST_OFST.dai_sequence_number%TYPE,
  			    cp_cal_type IGS_CA_DA_INST_OFST.cal_type%TYPE,
  			    cp_ci_sequence_number IGS_CA_DA_INST_OFST.ci_sequence_number%TYPE)
  IS
  SELECT 	*
  FROM	IGS_CA_DA_INST_OFST
  WHERE	dt_alias = cp_dt_alias
  AND	dai_sequence_number = cp_dai_sequence_number
  AND	cal_type = cp_cal_type
  AND	ci_sequence_number = cp_ci_sequence_number
  AND	((offset_dt_alias <> p_offset_dt_alias)
  OR	 (offset_dai_sequence_number <> p_offset_dai_sequence_number)
  OR	 (offset_cal_type <> p_offset_cal_type)
  OR	 (offset_ci_sequence_number <> p_offset_ci_sequence_number));
  CURSOR	c_cal_instance(cp_cal_type IGS_CA_INST.cal_type%TYPE,
  		       cp_sequence_number IGS_CA_INST.sequence_number%TYPE)
  IS
  SELECT	*
  FROM	IGS_CA_INST
  WHERE	cal_type = cp_cal_type and
  	sequence_number = cp_sequence_number;
  CURSOR	c_cal_status(cp_cal_status IGS_CA_STAT.cal_status%TYPE)
  IS
  SELECT	*
  FROM	IGS_CA_STAT
  WHERE	cal_status = cp_cal_status;
  FUNCTION find_daio(
  		  p_org_dt_alias_inst_ofst IGS_CA_DA_INST_OFST.dt_alias%TYPE,
  		   p_org_dai_seq_number IGS_CA_DA_INST_OFST.dai_sequence_number%TYPE,
  		   p_org_cal_type IGS_CA_DA_INST_OFST.cal_type%TYPE,
  		   p_org_ci_seq_number IGS_CA_DA_INST_OFST.ci_sequence_number%TYPE,
  		   p_dt_alias IGS_CA_DA_INST_OFST.dt_alias%TYPE,
  		   p_dai_seq_number IGS_CA_DA_INST_OFST.dai_sequence_number%TYPE,
  		   p_cal_type IGS_CA_DA_INST_OFST.cal_type%TYPE,
  		   p_ci_seq_number IGS_CA_DA_INST_OFST.ci_sequence_number%TYPE)
  RETURN BOOLEAN AS
  v_dt_alias_instance_offset_rec	IGS_CA_DA_INST_OFST%ROWTYPE;
  CURSOR	c_dt_alias_instance_offset (
  				   cp_dt_alias IGS_CA_DA_INST_OFST.dt_alias%TYPE,
  				   cp_dai_sequence_number IGS_CA_DA_INST_OFST.dai_sequence_number%TYPE,
  				   cp_cal_type IGS_CA_DA_INST_OFST.cal_type%TYPE,
  				   cp_ci_sequence_number IGS_CA_DA_INST_OFST.ci_sequence_number%TYPE)
  IS
  SELECT 	*
  FROM	IGS_CA_DA_INST_OFST
  WHERE	dt_alias = cp_dt_alias
  AND	dai_sequence_number = cp_dai_sequence_number
  AND	cal_type = cp_cal_type
  AND	ci_sequence_number = cp_ci_sequence_number;
  BEGIN
  	IF (c_dt_alias_instance_offset%ISOPEN = FALSE) THEN
  		OPEN c_dt_alias_instance_offset(p_dt_alias,
  			     			p_dai_seq_number,
  						p_cal_type,
  						p_ci_seq_number);
  	END IF;
  	LOOP
  		FETCH	c_dt_alias_instance_offset
  		INTO	v_dt_alias_instance_offset_rec;
  		IF (c_dt_alias_instance_offset%NOTFOUND) THEN
  			IF (c_dt_alias_instance_offset%ISOPEN) THEN
  				CLOSE c_dt_alias_instance_offset;
  			END IF;
  			RETURN TRUE;
  		END IF;
  		IF (v_dt_alias_instance_offset_rec.offset_dt_alias =
  							p_org_dt_alias_inst_ofst AND
  		    v_dt_alias_instance_offset_rec.offset_dai_sequence_number =
  							p_org_dai_seq_number AND
  		    v_dt_alias_instance_offset_rec.offset_cal_type = p_org_cal_type AND
  		    v_dt_alias_instance_offset_rec.offset_ci_sequence_number =
  							p_org_ci_seq_number) THEN
  			IF (c_dt_alias_instance_offset%ISOPEN) THEN
  				CLOSE c_dt_alias_instance_offset;
  			END IF;
  			RETURN FALSE;
  		ELSE
  			IF (find_daio(p_org_dt_alias_inst_ofst,
  				      p_org_dai_seq_number,
  				      p_org_cal_type,
  				      p_org_ci_seq_number,
  			    	      v_dt_alias_instance_offset_rec.offset_dt_alias,
  				      v_dt_alias_instance_offset_rec.offset_dai_sequence_number,
  				      v_dt_alias_instance_offset_rec.offset_cal_type,
  				      v_dt_alias_instance_offset_rec.offset_ci_sequence_number) = TRUE) THEN
  				IF (c_dt_alias_instance_offset%ISOPEN) THEN
  					CLOSE c_dt_alias_instance_offset;
  				END IF;
  				RETURN TRUE;
  			ELSE
  				IF (c_dt_alias_instance_offset%ISOPEN) THEN
  					CLOSE c_dt_alias_instance_offset;
  				END IF;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END LOOP;
  END find_daio;
  BEGIN
  	FOR v_dt_alias_instance_offset_rec
  	IN c_dt_alias_instance_offset(p_dt_alias,
  			     	      p_dai_sequence_number,
  				      p_cal_type,
  				      p_ci_sequence_number)
  	LOOP
  		p_message_name := 'IGS_CA_DTALIAS_INST_EXISTS';
  		RETURN FALSE;
  	END LOOP;
  	IF (p_dt_alias = p_offset_dt_alias AND
  	    p_dai_sequence_number = p_offset_dai_sequence_number AND
  	    p_cal_type = p_offset_cal_type AND
  	    p_ci_sequence_number = p_offset_ci_sequence_number) THEN
  		p_message_name := 'IGS_CA_DTALIAS_NOT_OFFSET';
  		RETURN FALSE;
  	END IF;
  	FOR v_cal_istance_rec IN c_cal_instance(p_cal_type, p_ci_sequence_number)
  	LOOP
  		FOR v_cal_status IN c_cal_status(v_cal_istance_rec.cal_status)
  		LOOP
  			v_dt_alias_status := v_cal_status.s_cal_status;
  		END LOOP;
  	END LOOP;
  	FOR v_cal_istance_rec IN c_cal_instance(p_offset_cal_type,
  					     p_offset_ci_sequence_number)
  	LOOP
  		FOR v_cal_status IN c_cal_status(v_cal_istance_rec.cal_status)
  		LOOP
  			v_offset_dt_alias_status := v_cal_status.s_cal_status;
  		END LOOP;
  	END LOOP;
  	IF(v_dt_alias_status = cst_active AND
  	    v_offset_dt_alias_status = cst_planned) THEN
  		p_message_name := 'IGS_CA_DTALIAS_CANNOTBE_OFF';
  		RETURN FALSE;
  	END IF;
  	IF (find_daio(p_dt_alias,
  		     p_dai_sequence_number,
  		     p_cal_type,
  		     p_ci_sequence_number,
  		     p_offset_dt_alias,
  		     p_offset_dai_sequence_number,
  		     p_offset_cal_type,
  		     p_offset_ci_sequence_number) = FALSE) THEN
  		p_message_name := 'IGS_CA_INVALID_DTALIAS_OFF';
  		RETURN FALSE;
  	ELSE
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	EXCEPTION
  	WHEN OTHERS THEN
	 	Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	 	FND_MESSAGE.SET_TOKEN('NAME','IGS_CA_VAL_DAIO.calp_val_daio_ins');
	 	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END calp_val_daio_ins;
  --
  -- Validate if a IGS_CA_DA_INST_OFST can be deleted.
  FUNCTION CALP_VAL_DAIO_DEL(
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_offset_dt_alias IN VARCHAR2 ,
  p_offset_dai_sequence_number IN NUMBER ,
  p_offset_cal_type IN VARCHAR2 ,
  p_offset_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  	cst_planned			CONSTANT VARCHAR2(8) := 'PLANNED';
  	v_dt_alias_instance_rec		IGS_CA_DA_INST%ROWTYPE;
  	v_other_detail			VARCHAR2(255);
  	e_no_dt_alias_instance		EXCEPTION;
  	CURSOR	c_dt_alias_instance
  	IS
  	SELECT	*
  	FROM	IGS_CA_DA_INST
  	WHERE	dt_alias = p_dt_alias and
  		sequence_number = p_dai_sequence_number and
  		cal_type = p_cal_type and
  		ci_sequence_number = p_ci_sequence_number;
  	CURSOR	c_cal_instance(cp_cal_type IGS_CA_INST.cal_type%TYPE,
  		       cp_sequence_number IGS_CA_INST.sequence_number%TYPE)
  	IS
  	SELECT	*
  	FROM	IGS_CA_INST
  	WHERE	cal_type = cp_cal_type and
  		sequence_number = cp_sequence_number;
  	CURSOR	c_cal_status(cp_cal_status IGS_CA_STAT.cal_status%TYPE)
  	IS
  	SELECT	*
  	FROM	IGS_CA_STAT
  	WHERE	cal_status = cp_cal_status;
  BEGIN
  	OPEN 	c_dt_alias_instance;
  	LOOP
  		FETCH 	c_dt_alias_instance
  		INTO	v_dt_alias_instance_rec;
  		IF (c_dt_alias_instance%NOTFOUND) THEN
  			RAISE e_no_dt_alias_instance;
  		END IF;
  		FOR v_cal_istance_rec IN c_cal_instance(p_cal_type, p_ci_sequence_number)
  		LOOP
  			FOR v_cal_status IN c_cal_status(v_cal_istance_rec.cal_status)
  			LOOP
  				IF (v_cal_status.s_cal_status = cst_planned) THEN
  					CLOSE c_dt_alias_instance;
  					p_message_name := NULL;
  					RETURN TRUE;
  				END IF;
  			END LOOP;
  		END LOOP;
  		IF (v_dt_alias_instance_rec.absolute_val IS NULL) THEN
  			CLOSE c_dt_alias_instance;
  			p_message_name := 'IGS_CA_DTALIAS_USEDTO_DERIVE';
  			RETURN FALSE;
  		ELSE
  			CLOSE c_dt_alias_instance;
  			p_message_name := Null;
  			RETURN TRUE;
  		END IF;
  	END LOOP;
  	CLOSE c_dt_alias_instance;
  	p_message_name := NULL;
  	RETURN TRUE;
  	EXCEPTION
  	WHEN e_no_dt_alias_instance THEN
  		CLOSE c_dt_alias_instance;
  		p_message_name := NULL;
  		RETURN TRUE;
  	WHEN OTHERS THEN
	 	Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
	 	FND_MESSAGE.SET_TOKEN('NAME','IGS_CA_VAL_DAIO.calp_val_daio_del');
	 	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END calp_val_daio_del;
END IGS_CA_VAL_DAIO;

/
