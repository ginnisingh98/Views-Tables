--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_UD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_UD" AS
/* $Header: IGSPS61B.pls 115.5 2002/12/12 09:51:41 smvk ship $ */

  --
  -- Validate the IGS_PS_DSCP group code for IGS_PS_UNIT IGS_PS_DSCP.
  FUNCTION crsp_val_ud_dg_cd(
  p_discipline_group_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  	v_closed_ind		IGS_PS_DSCP.closed_ind%TYPE;
  	CURSOR	c_discipline IS
   		SELECT 	closed_ind
  		FROM	IGS_PS_DSCP
  		WHERE	discipline_group_cd = p_discipline_group_cd;
  BEGIN
  	OPEN c_discipline;
  	FETCH c_discipline INTO v_closed_ind;
  	IF c_discipline%NOTFOUND THEN
  		p_message_name := NULL;
  		CLOSE c_discipline;
  		RETURN TRUE;
  	ELSIF (v_closed_ind = 'N') THEN
  		p_message_name := NULL;
  		CLOSE c_discipline;
  		RETURN TRUE;
  	ELSE
  		p_message_name := 'IGS_PS_DISCP_GRP_CLOSED';
  		CLOSE c_discipline;
  		RETURN FALSE;
  	END IF;
  EXCEPTION
  	WHEN OTHERS THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_UD.crsp_val_ud_dg_cd');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END crsp_val_ud_dg_cd;
  --
  -- Validate IGS_PS_UNIT IGS_PS_DSCP percentage for the IGS_PS_UNIT version
  FUNCTION crsp_val_ud_perc(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_b_lgcy_validator IN BOOLEAN )
  RETURN BOOLEAN AS

  /***********************************************************************************************
    Created By     :
    Date Created By:
    Purpose        :

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who		When		What
    smvk      12-Dec-2002      Added a boolean parameter p_b_lgcy_validator to the function call crsp_val_ud_perc.
                               As a part of the Bug # 2696207
  ********************************************************************************************** */

  	gv_percent		NUMBER;
  	gv_unit_discip_exists	CHAR;
  	gv_unit_status		IGS_PS_UNIT_STAT.s_unit_status%TYPE;
  	CURSOR	gc_unit_status IS
  		SELECT	US.s_unit_status
  		FROM	IGS_PS_UNIT_VER UV,
  			IGS_PS_UNIT_STAT US
  		WHERE	UV.unit_cd = p_unit_cd AND
  			UV.version_number = p_version_number AND
  			UV.unit_status = US.unit_status;
  	CURSOR	gc_unit_discip_exists IS
  		SELECT	'x'
  		FROM	IGS_PS_UNIT_DSCP
  		WHERE	unit_cd = p_unit_cd AND
  			version_number = p_version_number;

  	CURSOR cur_percent IS
		SELECT 	SUM(percentage)
	 	FROM 	IGS_PS_UNIT_DSCP
  		WHERE unit_cd = p_unit_cd AND
  		version_number= p_version_number;


  BEGIN
  	-- finding the IGS_PS_UNIT_STAT
  	OPEN  gc_unit_status;
  	FETCH gc_unit_status INTO gv_unit_status;
  	-- finding unit_responsibility records
  	OPEN  gc_unit_discip_exists;
  	FETCH gc_unit_discip_exists INTO gv_unit_discip_exists;
  	-- Find the sum of all percentages

		OPEN cur_percent;
		FETCH cur_percent INTO gv_percent;

		IF cur_percent%NOTFOUND THEN
			RAISE no_data_found;
		END IF;
		CLOSE cur_percent;

   	-- when the percentage totals 100
  	IF gv_percent = 100.00 THEN
  		CLOSE gc_unit_status;
  		CLOSE gc_unit_discip_exists;
  		p_message_name := NULL;
  		RETURN TRUE;
  	ELSE
  		-- when the percentage doesn't total 100 and
  		-- when the IGS_PS_UNIT_STAT.s_unit_status is PLANNED
  		-- and no IGS_PS_UNIT_DSCP records exists
  		IF (gv_unit_status = 'PLANNED' AND gc_unit_discip_exists%NOTFOUND)  AND (NOT p_b_lgcy_validator) THEN
  			CLOSE gc_unit_status;
  			CLOSE gc_unit_discip_exists;
  			p_message_name := NULL;
  			RETURN TRUE;
  		ELSE
  			-- when the percentage doesn't total 100 and
  			-- if the IGS_PS_UNIT_STAT.s_unit_status is not PLANNED
  			-- or no IGS_PS_UNIT responsibility records exists
  			CLOSE gc_unit_status;
  			CLOSE gc_unit_discip_exists;
  			p_message_name := 'IGS_PS_UNITDISCP_NOTTOTAL_100';
  			RETURN FALSE;
  		END IF;
  	END IF;
  EXCEPTION
	WHEN no_data_found THEN
	IF cur_percent%ISOPEN THEN
		CLOSE cur_percent;
	END IF;
	Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
  	WHEN OTHERS THEN
		IF cur_percent%ISOPEN THEN
			CLOSE cur_percent;
		END IF;
		Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_PS_VAL_UD.crsp_val_ud_perc');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

  END crsp_val_ud_perc;
END IGS_PS_VAL_UD;

/
