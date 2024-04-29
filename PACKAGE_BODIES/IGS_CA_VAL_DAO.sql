--------------------------------------------------------
--  DDL for Package Body IGS_CA_VAL_DAO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_VAL_DAO" AS
/* $Header: IGSCA11B.pls 115.3 2002/11/28 22:58:40 nsidana ship $ */
  -- Validate IGS_CA_DA_OFST
  FUNCTION calp_val_dao_ins(
  p_dt_alias IN VARCHAR2 ,
  p_offset_dt_alias IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN boolean AS
  v_other_detail	VARCHAR(255);
  v_alias_value	DATE;
  v_dt_alias_rec	IGS_CA_DA%ROWTYPE;
  CURSOR	c_dt_alias_offset (cp_dt_alias IGS_CA_DA_OFST.dt_alias%TYPE)
  IS
  SELECT 	*
  FROM	IGS_CA_DA_OFST
  WHERE	dt_alias = cp_dt_alias
  AND	(offset_dt_alias <> p_offset_dt_alias);
  CURSOR	c_dt_alias (cp_dt_alias IGS_CA_DA.dt_alias%TYPE)
  IS
  SELECT 	*
  FROM	IGS_CA_DA
  WHERE	dt_alias = cp_dt_alias;
  FUNCTION find_dao(p_org_dt_alias IGS_CA_DA_OFST.dt_alias%TYPE,
  		  p_dt_alias IGS_CA_DA_OFST.dt_alias%TYPE)
  RETURN BOOLEAN AS
  v_dt_alias_offset_rec	IGS_CA_DA_OFST%ROWTYPE;
  CURSOR	c_dt_alias_offset (cp_dt_alias IGS_CA_DA_OFST.dt_alias%TYPE)
  IS
  SELECT 	*
  FROM	IGS_CA_DA_OFST
  WHERE	dt_alias = cp_dt_alias;
  BEGIN
  	IF (c_dt_alias_offset%ISOPEN = FALSE) THEN
  		OPEN c_dt_alias_offset(p_dt_alias);
  	END IF;
  	LOOP
  		FETCH	c_dt_alias_offset
  		INTO	v_dt_alias_offset_rec;
  		IF (c_dt_alias_offset%NOTFOUND) THEN
  			IF (c_dt_alias_offset%ISOPEN) THEN
  				CLOSE c_dt_alias_offset;
  			END IF;
  			RETURN TRUE;
  		END IF;
  		IF (v_dt_alias_offset_rec.offset_dt_alias = p_org_dt_alias) THEN
  			IF (c_dt_alias_offset%ISOPEN) THEN
  				CLOSE c_dt_alias_offset;
  			END IF;
  			RETURN FALSE;
  		ELSE
  			IF (find_dao(p_org_dt_alias,
  			    v_dt_alias_offset_rec.offset_dt_alias) = TRUE) THEN
  				IF (c_dt_alias_offset%ISOPEN) THEN
  					CLOSE c_dt_alias_offset;
  				END IF;
  				RETURN TRUE;
  			ELSE
  				IF (c_dt_alias_offset%ISOPEN) THEN
  					CLOSE c_dt_alias_offset;
  				END IF;
  				RETURN FALSE;
  			END IF;
  		END IF;
  	END LOOP;
  END find_dao;
  BEGIN
  	OPEN c_dt_alias(p_offset_dt_alias);
  	FETCH	c_dt_alias
  	INTO	v_dt_alias_rec;
  	IF (v_dt_alias_rec.closed_ind = 'Y') THEN
  		CLOSE c_dt_alias;
  		p_message_name := 'IGS_CA_DTALIAS_CLOSED';
  		RETURN FALSE;
  	END IF;
  	CLOSE c_dt_alias;
  	FOR v_dt_alias_offset_rec IN c_dt_alias_offset(p_dt_alias)
  	LOOP
  		p_message_name := 'IGS_CA_DTALIAS_EXISTS';
  		RETURN FALSE;
  	END LOOP;
  	IF (p_dt_alias = p_offset_dt_alias) THEN
  		p_message_name := 'IGS_CA_DTALIAS_CANNOT_OFFSET';
  		RETURN FALSE;
  	END IF;
  	IF (find_dao(p_dt_alias, p_offset_dt_alias) = FALSE) THEN
  		p_message_name := 'IGS_CA_INVALID_DTALIAS_OFFSET';
  		RETURN FALSE;
  	ELSE
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  	EXCEPTION
  	WHEN OTHERS THEN
 		Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
 		FND_MESSAGE.SET_TOKEN('NAME','IGS_CA_VAL_DAO.calp_val_dao_ins');
 		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END calp_val_dao_ins;
END IGS_CA_VAL_DAO;

/
